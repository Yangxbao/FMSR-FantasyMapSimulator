class_name MapGen
## 世界生成（忠实版）：高度图 → 陆地 → 细网格多源BFS省份 → 首都生长国家
## 附加：城邑点位 / 下游河流 / 山地与植被散布 / 国家质心
## 算法结构参考 Azgaar's Fantasy Map Generator 公开资料（burgs/states/provinces 领域模型），
## 实现为本项目原创 GDScript；数值参数待 Ghidra 反编译原版后校准（见 reports/）。

const W := 480
const H := 280
const CELL := 4.0
const SEA_LEVEL := 0.30
## 原版海平面高度 = 20 / 100（World.GenerateHeightMap: world+0x178 = 0x14）
const SEA_LEVEL_FIXED := 0.20
const PROVINCE_STEP := 11

var elevation := PackedFloat32Array()
var is_land := PackedByteArray()
var sea_level_effective := SEA_LEVEL
var cell_province := PackedInt32Array()   # 陆地格->省份id, -1=海
var provinces: Array = []                 # {cells, state, name, neighbors, pop, burg:Vector2, is_capital_burg:bool}
var states: Array = []                    # {name, color, capital:int(省), provinces:[], alive, centroid:Vector2}
var rivers: Array = []                    # [PackedVector2Array]
var mountain_spots: Array = []            # [Vector2, scale, flip]
var tree_spots: Array = []

func generate(state_count: int, seed_val: int) -> void:
	_world_seed = seed_val
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	# 幂等：多次生成（换种子/新世界）必须完全重置（否则旧数据追加导致省份/国家暴涨）
	var _t0 := Time.get_ticks_msec()
	provinces.clear()
	states.clear()
	rivers.clear()
	mountain_spots.clear()
	tree_spots.clear()
	_gen_elevation(seed_val)
	_gen_biomes(seed_val)   # 原版管线：高度图 → 生态（群系） → 行省 → 国家
	if OS.is_debug_build() and OS.get_cmdline_user_args().has("perftime"):
		printerr("[gen] elevation+biomes %d ms" % (Time.get_ticks_msec() - _t0))
	_gen_provinces(rng)
	_gen_rivers(rng)
	_scatter_terrain(rng)
	if OS.is_debug_build() and OS.get_cmdline_user_args().has("perftime"):
		printerr("[gen] provinces %d ms" % (Time.get_ticks_msec() - _t0))
	_gen_states(rng, state_count)
	if OS.is_debug_build() and OS.get_cmdline_user_args().has("perftime"):
		printerr("[gen] states %d ms" % (Time.get_ticks_msec() - _t0))
	_assign_names(rng)

## ===== 高度图：原版模板 DSL（HeightMapGenerator）=====
## 证据链（2026-11-01 main.js 解密终审，findings §15.36）：
##   新游戏路径 = JS HeightmapGenerator.generate → fromTemplate(名字) → JS heightmapTemplates
##   （44+ 模板，extracted_js/main.dec.js L193 起；已提取到 assets/origin/heightmap_templates_js.json）。
##   C# HeightmapTemplates cctor 的 5 块是编辑器列表；其 Templates[3]（20 行 Range 轰炸变体）
##   不在 JS 库中——不再作为新游戏模板。
##   C# GenerateHeightMap 的「两个模板池」（5+7 个名字常量）待解析后接入真随机选模板。
const HeightmapTemplateScript := preload("res://scripts/heightmap_template.gd")
const HeightmapDslScript := preload("res://scripts/heightmap_dsl.gd")

## 新游戏默认模板（JS 库键名；池解析前的确定性占位）
const TEMPLATE_JS_NAME := "continents"

## 原版每局在 10000/20000/30000（大地图 40000）cell 间随机（World.GenerateHeightMap 实证）；
## blob/linePower 按 cellsDesired 查表（DSL 内部）。高度场直接在全分辨率网格上生成
## （2026-11-01 实测：480×280 + JS continents → 43.5% 陆地，落原版 31.8~45.2% 区间；
## 20000-cell 粗网格 + 方格拓扑 → 78%（维诺 hop 覆盖差异），故弃用粗网格上采样）。
const TEMPLATE_CELLS := 20000

## 小岛清除：原版无此步骤的证据，属历史近似。DSL 高度图接入后停用，保留代码备查。
const REMOVE_SMALL_ISLANDS := false

func _gen_elevation(seed_val: int) -> void:
	## 全分辨率生成（2026-11-01 实测最贴近原版陆地占比；粗网格上采样已弃用，见常量区注记）
	var cw := W
	var ch := H
	var parser := HeightmapTemplateScript.new()
	var lib: Dictionary = parser.load_js_library()
	if lib.is_empty() or not lib.has(TEMPLATE_JS_NAME):
		push_error("JS 高度图模板库缺失或缺模板: " + TEMPLATE_JS_NAME)
		return
	var tpl: Dictionary = lib[TEMPLATE_JS_NAME]
	var dsl := HeightmapDslScript.new(seed_val, cw, ch, TEMPLATE_CELLS)
	var unknown: Array = dsl.run_steps(tpl["steps"])
	if not unknown.is_empty():
		push_error("高度图模板含未实现算子: %s" % str(unknown))
	elevation.resize(W * H)
	for i in W * H:
		elevation[i] = float(dsl.heights[i]) / 100.0
	# 海平面 = 20/100（World.GenerateHeightMap: world+0x178 = 0x14）
	sea_level_effective = SEA_LEVEL_FIXED
	is_land.clear()
	for i in W * H:
		is_land.append(1 if elevation[i] > sea_level_effective else 0)
	if REMOVE_SMALL_ISLANDS:
		_remove_small_islands()

func _gen_elevation_legacy_fastnoise(seed_val: int) -> void:
	var noise := FastNoiseLite.new()
	noise.seed = seed_val
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 5
	noise.frequency = 0.012
	var warp := FastNoiseLite.new()
	warp.seed = seed_val + 999
	warp.frequency = 0.01
	# 构图式大陆：每种子确定性放置 2~4 个大板块 + 细节噪声
	# （近似实现：保证"少量大块大陆+沿岸岛屿"的原版地图特征；正式算法待反编译 HeightMapGenerator）
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val + 555
	var k := 2 + (seed_val % 3)
	var centers: Array[Vector2] = []
	var radii: Array[float] = []
	for ci in k:
		var cx := rng.randf_range(W * 0.22, W * 0.78)
		var cy := rng.randf_range(H * 0.25, H * 0.75)
		var cr := minf(W, H) * rng.randf_range(0.22, 0.34)
		centers.append(Vector2(cx, cy))
		radii.append(cr)
	# 大陆轮廓扰动：按角向低频噪声摆动半径，消除正圆形人工感
	var blob := FastNoiseLite.new()
	blob.seed = seed_val + 31337
	blob.frequency = 0.05
	elevation.resize(W * H)
	for y in H:
		for x in W:
			var i := y * W + x
			var wx := x + warp.get_noise_2d(x * 2.0, y * 2.0) * 30.0
			var wy := y + warp.get_noise_2d(x * 2.0 + 500.0, y * 2.0 + 500.0) * 30.0
			var detail := noise.get_noise_2d(wx, wy) * 0.5 + 0.5
			# 板块场：取各大陆的衰减最大值
			var field := 0.0
			for ci in k:
				var dv := Vector2(x, y) - centers[ci]
				var ang := atan2(dv.y, dv.x)
				var rr := radii[ci] * (1.0 + 0.38 * blob.get_noise_2d(cos(ang) * 30.0 + ci * 91.0, sin(ang) * 30.0))
				var d := dv.length() / rr
				var f := 1.0 - clampf(d * d, 0.0, 1.0)
				field = maxf(field, f)
			# 细节噪声仅在大陆近旁生效（门控），避免开阔海域喷出岛链
			var detail_gated := detail * smoothstep(0.05, 0.45, field)
			var n := clampf(field * 0.85 + detail_gated * 0.55 - 0.18, 0.0, 1.0)
			# 微量基底：打破海面并列值，保证分位数海平面可控
			n = maxf(n, detail * 0.004 + 0.001)
			# 地图边缘淡出为海
			var edge := minf(minf(x, W - 1 - x) / 24.0, minf(y, H - 1 - y) / 18.0)
			n *= clampf(edge, 0.0, 1.0)
			elevation[i] = n
	# 陆地占比按分位数确定（保持 ~38%），然后把高度场**重标定到原版的 0..1 制、海平面固定 0.20**
	# 证据：World.GenerateHeightMap 中 `world+0x178 = 0x14`（=20，0..100 制），
	#       与 ExpandProvinces 的「height>=20 才算陆地」完全一致（findings §10）。
	var sample: Array[float] = []
	for i in range(0, W * H, 7):
		sample.append(elevation[i])
	sample.sort()
	var cut := 0.001
	if sample.size() > 0:
		var idx := int(sample.size() * 0.62)
		cut = clampf(sample[idx], 0.0005, 0.42)
	# 分段线性重标定：海面以下 → 0..0.20，海面以上 → 0.20..1.0（单调，陆海集合完全不变）
	var sea_fixed := SEA_LEVEL_FIXED
	for i in W * H:
		var e := elevation[i]
		if e <= cut:
			elevation[i] = (e / maxf(cut, 0.00001)) * sea_fixed
		else:
			elevation[i] = sea_fixed + ((e - cut) / maxf(1.0 - cut, 0.00001)) * (1.0 - sea_fixed)
	sea_level_effective = sea_fixed
	is_land.clear()
	for i in W * H:
		is_land.append(1 if elevation[i] > sea_level_effective else 0)
	_remove_small_islands()

## 小岛清除：连通面积 < MIN_ISLAND_CELLS 的陆块并入海洋
## （近似：原版海岸线干净、少碎岛；正式参数待反编译确认 —— restoration-acceptance.md §1.1）
const MIN_ISLAND_CELLS := 14

func _remove_small_islands() -> void:
	var visited := PackedByteArray()
	visited.resize(W * H)
	var stack: Array[int] = []
	for start in W * H:
		if is_land[start] == 0 or visited[start] == 1:
			continue
		var region: Array[int] = []
		var size := 0
		stack.append(start)
		visited[start] = 1
		while not stack.is_empty():
			var i: int = stack.pop_back()
			region.append(i)
			size += 1
			var x := i % W
			var y := i / W
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx := x + int(d.x)
				var ny := y + int(d.y)
				if nx < 0 or ny < 0 or nx >= W or ny >= H:
					continue
				var ni := ny * W + nx
				if is_land[ni] == 1 and visited[ni] == 0:
					visited[ni] = 1
					stack.append(ni)
		if size < MIN_ISLAND_CELLS:
			for i in region:
				is_land[i] = 0
				elevation[i] = minf(elevation[i], sea_level_effective - 0.02)

func _smoothstep(a: float, b: float, x: float) -> float:
	var t := clampf((x - a) / (b - a), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)

func _gen_provinces(rng: RandomNumberGenerator) -> void:
	cell_province.resize(W * H)
	cell_province.fill(-1)
	_seed_provinces(rng)
	# 省份扩张：多源 Dijkstra（忠实还原原版 ExpandProvinces，见 reports/decompiled/）
	_expand_provinces_dijkstra()
	# 原版 FilterProvinceCells：由 cell→province 字典重建各省 cell 集合
	_rebuild_province_cells()
	# 原版 EnsureProvinceConnectivity：内陆断裂碎片并入邻省（跨海碎片保留）
	_ensure_province_connectivity()
	_rebuild_province_cells()
	# 原版 CreateSeaProvinces + ExpandSeaProvinces：按海域建省并洪水填充
	_gen_sea_provinces()
	_rebuild_province_cells()
	for y in H:
		for x in range(W - 1):
			_link(x + y * W, (x + 1) + y * W)
	for y in range(H - 1):
		for x in W:
			_link(x + y * W, x + (y + 1) * W)
	_absorb_orphan_cells()
	# 城邑：设在省份中心 cell（原版 prov+0x64 center cell，即扩张种子），首都省标记
	for pi in provinces.size():
		if provinces[pi].get("is_sea", false):
			provinces[pi].burg = Vector2(-1, -1)  # 海域省无城邑（不消耗随机数，保持随机流不变）
			continue
		var c: int = provinces[pi].center
		if c < 0 and provinces[pi].cells.size() > 0:
			c = provinces[pi].cells[0]
		provinces[pi].burg = Vector2(c % W, c / W) * CELL + Vector2(CELL, CELL) * 0.5
		provinces[pi].defense = rng.randi_range(20, 90)  # 城市防御力（原版字段 CityDefense）

## 省份种子：抖动网格布点（对应原版 PlaceProvincialCapitalsByJitterGrid 的等距抖动网格思想）
## 每省记录 center = 种子 cell（原版 prov+0x64，ExpandProvinces 的扩张起点）
func _seed_provinces(rng: RandomNumberGenerator) -> void:
	var step := PROVINCE_STEP
	var pid := 0
	for sy in range(3, H - 3, step):
		for sx in range(3, W - 3, step):
			for _try in 14:
				var px := sx + rng.randi_range(-4, 4)
				var py := sy + rng.randi_range(-4, 4)
				if px < 1 or py < 1 or px >= W - 1 or py >= H - 1:
					continue
				var i := py * W + px
				if is_land[i] == 1 and cell_province[i] == -1:
					cell_province[i] = pid
					var pop0 := rng.randi_range(400, 1200)
					# 人口量纲对齐原版（原版单个行省数十万~百万级，见截图 406.8万/57 省）
					provinces.append({"cells": PackedInt32Array([i]), "center": i, "state": -1,
						"name": "", "neighbors": {}, "pop": pop0 * 1000,
						"burg": Vector2.ZERO, "is_capital_burg": false, "defense": 20 + (pop0 % 40),
						# 原版 ProvinceInfoUI 字段：行省类型 / 人口与城防的上限 / 区域(子区域)人口与防御
						"kind": "", "max_pop": pop0 * 3000, "max_defense": 100,
						"district_pop": pop0 * 1000 / 6, "district_max_pop": pop0 * 1000 / 2,
						"district_defense": 20, "district_max_defense": 60})
					pid += 1
					break

## ===== 省份扩张代价常数（全部来自反编译，见 reports/decompiled/BurgsAndStateGenerator_ExpandProvinces.c）=====
const PROV_BASE_COST := 10.0        # L417: prevCost + 10.0 + extra/mult
const PROV_TERRAIN_MAX := 20.0      # L366: 20.0 - 高度值；L338: 高度<0x14(20) 视为水
const PROV_TERRAIN_MISS := 5000.0   # L353: 高度浮点表缺失(<=0) → 罚 5000
const PROV_CULTURE_SAME := -9.0     # L325: 与省份文化相同 → -9
const PROV_CULTURE_DIFF := 100.0    # L327: 文化不同 → +100
const PROV_SEED_COST := 1.0         # L193: 种子 cell 代价表置 1.0（0x3f800000）
const PROV_MULT := 1.0              # 省份扩张除数：Province 构造第 5 实参恒为 1.0（CreateProvinces/CreateSeaProvinces）
const PROV_TERRAIN_SCALE := 40.0    # 近似：elevation(0..1) → 原版 0..20 高度分位
## 原版允许前沿穿越水域：L431 只在 height>=20 时写归属，而代价计算与入队对所有邻格都做，
## 因此省份可以越过水面抢到离岛（EnsureProvinceConnectivity 专门保留"触海碎片"亦为佐证）。
## 注：原版的海洋代价会额外叠加 biome 项（跨 biome 时取 Biome 代价表值），该项尚未接入。
const PROV_TRAVERSE_SEA := true

## ===== 海洋省：忠实还原 CreateSeaProvinces + ExpandSeaProvinces =====
## 证据：reports/decompiled/BurgsAndStateGenerator_CreateSeaProvinces.c（逐海域建省）
##       reports/decompiled/BurgsAndStateGenerator_ExpandSeaProvinces.c（FIFO 洪水填充）
## CreateSeaProvinces：为每个海域建一个 Province，id 接在陆地省之后，isLand 标志写 0；
##                     只写 cell→对象索引，**不**写 cell→province（留给扩张阶段）。
## ExpandSeaProvinces：普通 Queue（非优先队列）；从各省中心入队，出队后遍历邻格，
##                     满足 "cell→province == 0 且 height < 20（海）" 才写入归属并入队；
##                     节点代价字段固定填 1.0f，**没有任何代价公式、没有松弛**。
func _gen_sea_provinces() -> void:
	# 1) 海域分组：4 邻域连通的海格（对应 World+0x278 的海域集合）
	var mark := PackedByteArray()
	mark.resize(W * H)
	var groups: Array = []
	for start in W * H:
		if is_land[start] == 1 or mark[start] == 1:
			continue
		var cells: Array[int] = []
		var stack: Array[int] = [start]
		mark[start] = 1
		while not stack.is_empty():
			var cur: int = stack.pop_back()
			cells.append(cur)
			var x := cur % W
			var y := cur / W
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx := x + int(d.x)
				var ny := y + int(d.y)
				if nx < 0 or ny < 0 or nx >= W or ny >= H:
					continue
				var ni := ny * W + nx
				if is_land[ni] == 0 and mark[ni] == 0:
					mark[ni] = 1
					stack.append(ni)
		if cells.size() > 0:
			groups.append(cells)
	# 2) 每组建一个海洋省；center = 离组质心最近的格
	var n_land := provinces.size()
	for gi in groups.size():
		var cells: Array = groups[gi]
		var acc := Vector2.ZERO
		for c in cells:
			acc += Vector2(int(c) % W, int(c) / W)
		var centroid := acc / float(cells.size())
		var best := int(cells[0])
		var bd := INF
		for c2 in cells:
			var cc: int = c2
			var d2 := Vector2(cc % W, cc / W).distance_squared_to(centroid)
			if d2 < bd:
				bd = d2
				best = cc
		provinces.append({"cells": PackedInt32Array(), "center": best, "state": -1,
			"name": "", "neighbors": {}, "pop": 0,
			"burg": Vector2(-1, -1), "is_capital_burg": false, "defense": 0,
			"kind": "", "max_pop": 0, "max_defense": 0,
			"district_pop": 0, "district_max_pop": 0,
			"district_defense": 0, "district_max_defense": 0,
			"is_sea": true, "sea_index": gi,
			# 海域规模分级：World.DefineOceanGroup 用 size 与 总格数 的比值分三档
			# （<=1% → 最小档，<=4% → 中档，其余 → 大档；对应 DAT_182eb81b8/182e86b60/182ef5518 三个字符串常量）
			"sea_tier": (2 if float(cells.size()) > float(W * H) * 0.04 else (1 if float(cells.size()) > float(W * H) * 0.01 else 0))})
	# 3) ExpandSeaProvinces：普通 FIFO 队列从各省中心洪水填充
	var queue: Array[int] = []
	for pi in range(n_land, provinces.size()):
		var c0: int = provinces[pi].center
		if c0 >= 0 and is_land[c0] == 0:
			cell_province[c0] = pi
			queue.append(c0)
	var head := 0
	while head < queue.size():
		var cur2: int = queue[head]
		head += 1
		var pid: int = cell_province[cur2]
		var x2 := cur2 % W
		var y2 := cur2 / W
		for d3 in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nx3 := x2 + int(d3.x)
			var ny3 := y2 + int(d3.y)
			if nx3 < 0 or ny3 < 0 or nx3 >= W or ny3 >= H:
				continue
			var ni3 := ny3 * W + nx3
			if is_land[ni3] == 0 and cell_province[ni3] < 0:
				cell_province[ni3] = pid
				queue.append(ni3)

## 省份扩张：多源 Dijkstra（忠实还原 ExpandProvinces）
## 与原版逐条对应：
##   队列      = 最小优先队列（FUN_1814e95d0 Add(item,priority) / FUN_1814e6c30 Dequeue 取最小）
##   种子      = 每个陆地省的 center cell，代价表 1.0，入队优先级 0
##   松弛      = costTable[nb]==0.0 || newCost<costTable[nb]（L418-421）
##   代价      = prevCost + 10.0 + max(0, 文化项+地形项+biome+0.0+river+type)/provMult（L404-417）
##   归属      = 仅当目标为陆地（height>=20）才写 cell→province（L431）
##   已归属格  = 目标省为陆地省（id>=1）则整段跳过，不覆盖（L306 门 + L300 中心格保护）
func _expand_provinces_dijkstra() -> void:
	var n := W * H
	var cost := PackedFloat32Array()
	cost.resize(n)
	cost.fill(0.0)  # 原版 0.0 = 未访问（与 state 扩张用 -1 哨兵不同）
	var owner := PackedInt32Array()
	owner.resize(n)
	owner.fill(-1)
	_heap_cost = PackedFloat32Array()
	_heap_cell = PackedInt32Array()
	for pi in provinces.size():
		var c0: int = provinces[pi].center
		if c0 < 0 or c0 >= n or is_land[c0] == 0:
			continue
		cost[c0] = PROV_SEED_COST
		owner[c0] = pi
		cell_province[c0] = pi
		_heap_push(0.0, c0)
	while not _heap_empty():
		var c := _heap_cost[0]
		var i := _heap_pop()
		if cost[i] != 0.0 and c > cost[i] + 0.001:
			continue
		var pi2: int = owner[i]
		if pi2 < 0:
			continue
		var x := i % W
		var y := i / W
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nx := x + int(d.x)
			var ny := y + int(d.y)
			if nx < 0 or ny < 0 or nx >= W or ny >= H:
				continue
			var ni := ny * W + nx
			if cell_province[ni] >= 0:
				continue  # 已归属省份的 cell（含各省中心）不覆盖
			if is_land[ni] == 0 and not PROV_TRAVERSE_SEA:
				continue
			var extra := _province_extra_cost(i, ni, pi2)
			var nc: float = c + PROV_BASE_COST + extra / PROV_MULT
			if cost[ni] == 0.0 or nc < cost[ni]:
				if is_land[ni] == 1:
					cell_province[ni] = pi2
				cost[ni] = nc
				owner[ni] = pi2
				_heap_push(nc, ni)

## 单步附加代价：按反编译的 6 项顺序相加，最后整体下限 0（L404-407）
## 已确认：文化项（同-9/异+100）、地形项（20-高度, 下限0, 缺表5000）
## 未接入：biome 项（原版=同 biome 记 0、跨 biome 取 Biome 代价表值；重建版无生物群系数据）
##         river / type 项（原版 = g__getRiverCost|27_2 / g__getTypeCost|27_3，重建版无对应 cell 数据）
## 这三项当前恒为 0，是明确的未还原项，不是原版参数。
func _province_extra_cost(_origin: int, target: int, pi: int) -> float:
	var e := 0.0
	e += _culture_cost(pi, target)
	e += _terrain_cost(target)
	e += _biome_cost(target)
	e += 0.0  # 原版此处第 4 项 ExpandProvinces 特有的是字面 0.0（ExpandStates 对应项为 getHeightCost）
	e += _river_cost(target)
	e += _type_cost(target)
	return maxf(e, 0.0)

## 文化项：原版 dict_0x88[cell]（cell→文化）与省份文化字段比较，相同 -9 / 不同 +100
## 重建版尚无文化系统（文化包未接入）→ 全图同文化，取相同分支 -9（按原式代入默认数据，非猜测参数）
func _culture_cost(_pi: int, _target: int) -> float:
	return PROV_CULTURE_SAME

## 地形项：高度<20（水）→ 0；否则 20-高度（下限 0）；查表失败 → 5000
func _terrain_cost(target: int) -> float:
	if is_land[target] == 0:
		return 0.0
	var v := clampf((elevation[target] - sea_level_effective) * PROV_TERRAIN_SCALE, 0.0, PROV_TERRAIN_MAX)
	if v <= 0.0:
		return PROV_TERRAIN_MISS
	return maxf(PROV_TERRAIN_MAX - v, 0.0)

## biome 项：已反编译（reports/decompiled/BurgsAndStateGenerator_getBiomeCost_27_0.c）
##   原版：起点与目标 biome 相同 → 0；不同 → 查 Biomes 静态代价表（表值在运行时数据里，未取到）
##   重建版无 biome 图（Biome 系统未实现）→ 恒 0
func _biome_cost(_target: int) -> float:
	return 0.0

## 河流项：原版 <ExpandProvinces>g__getRiverCost|27_2（反编译进行中），重建版无 cell→river id 数据 → 0
func _river_cost(_target: int) -> float:
	return 0.0

## cell 类型项：原版 <ExpandProvinces>g__getTypeCost|27_3（反编译进行中），重建版无 cell→type 数据 → 0
func _type_cost(_target: int) -> float:
	return 0.0

## 原版 FilterProvinceCells 语义：清空各省 cell 集合后，按 cell→province 字典逐 cell 回填
func _rebuild_province_cells() -> void:
	for pi in provinces.size():
		provinces[pi].cells = PackedInt32Array()
	for i in W * H:
		var p := cell_province[i]
		if p >= 0 and p < provinces.size():
			provinces[p].cells.append(i)
	# center 修复：笔刷可能把某省的 center 格划给了别的省，此时 center 指向别省（首都/扩张起点都会错）。
	# 只在 center 已失效时改，取离质心最近的格，因此对正常生成流程零影响。
	for pi in provinces.size():
		var pr: Dictionary = provinces[pi]
		var c: int = int(pr.get("center", -1))
		if c >= 0 and c < W * H and int(cell_province[c]) == pi:
			continue
		var cs: PackedInt32Array = pr.cells
		if cs.is_empty():
			pr.center = -1
			continue
		var sx := 0
		var sy := 0
		for ci in cs:
			sx += ci % W
			sy += ci / W
		var mx := float(sx) / float(cs.size())
		var my := float(sy) / float(cs.size())
		var best_i: int = cs[0]
		var best_d := INF
		for ci in cs:
			var dx := float(ci % W) - mx
			var dy := float(ci / W) - my
			var d2 := dx * dx + dy * dy
			if d2 < best_d:
				best_d = d2
				best_i = ci
		pr.center = best_i

## 原版 EnsureProvinceConnectivity：
##   每省取主分量（含 center 者）；非主分量若触海 → 保留为离岛；若不触海（内陆飞地）→ 逐 cell 并入邻接最多的省
##   （原版 FindBestNeighborProvince/CollectComponent 为局部函数未反编译，"邻接最多"为可观测量下的等价近似）
func _ensure_province_connectivity() -> void:
	var dirs := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	var mark := PackedByteArray()
	mark.resize(W * H)
	for pi in provinces.size():
		var cells: PackedInt32Array = provinces[pi].cells
		if cells.size() <= 1:
			continue
		var comps: Array = []
		for start in cells:
			if mark[start] == 1:
				continue
			var comp: Array[int] = []
			var stack: Array[int] = [start]
			mark[start] = 1
			while not stack.is_empty():
				var cur: int = stack.pop_back()
				comp.append(cur)
				var x := cur % W
				var y := cur / W
				for d in dirs:
					var nx := x + int(d.x)
					var ny := y + int(d.y)
					if nx < 0 or ny < 0 or nx >= W or ny >= H:
						continue
					var ni := ny * W + nx
					if mark[ni] == 0 and cell_province[ni] == pi:
						mark[ni] = 1
						stack.append(ni)
			comps.append(comp)
		if comps.size() <= 1:
			continue
		var main := 0
		for ci in comps.size():
			var c_arr: Array = comps[ci]
			if c_arr.has(provinces[pi].center):
				main = ci
				break
		for ci in comps.size():
			if ci == main:
				continue
			var comp2: Array = comps[ci]
			var touches_sea := false
			for cv in comp2:
				var cur2: int = cv
				var x2 := cur2 % W
				var y2 := cur2 / W
				for d2 in dirs:
					var nx2 := x2 + int(d2.x)
					var ny2 := y2 + int(d2.y)
					if nx2 < 0 or ny2 < 0 or nx2 >= W or ny2 >= H:
						continue
					if is_land[ny2 * W + nx2] == 0:
						touches_sea = true
						break
				if touches_sea:
					break
			if touches_sea:
				continue
			for cv3 in comp2:
				var cur3: int = cv3
				var counts := {}
				var x3 := cur3 % W
				var y3 := cur3 / W
				for d3 in dirs:
					var nx3 := x3 + int(d3.x)
					var ny3 := y3 + int(d3.y)
					if nx3 < 0 or ny3 < 0 or nx3 >= W or ny3 >= H:
						continue
					var np := cell_province[ny3 * W + nx3]
					if np >= 0 and np != pi:
						counts[np] = int(counts.get(np, 0)) + 1
				var best := -1
				var bn := 0
				for k in counts:
					if counts[k] > bn:
						bn = counts[k]
						best = k
				if best >= 0:
					cell_province[cur3] = best

func _link(a: int, b: int) -> void:
	var pa := cell_province[a]
	var pb := cell_province[b]
	if pa == pb or pa < 0 or pb < 0:
		return
	# 海洋省不参与陆地省邻接图（重建版的"陆块编号/岛屿建国"依赖陆地邻接，
	# 混入海域会把两块大陆串成一块），但单独记录"海岸相邻"的陆地省，供海洋省面板使用
	var sa: bool = provinces[pa].get("is_sea", false)
	var sb: bool = provinces[pb].get("is_sea", false)
	if sa and sb:
		return
	if sa or sb:
		var sea_p: int = pa if sa else pb
		var land_p: int = pb if sa else pa
		if not provinces[sea_p].has("coast_land_provs"):
			provinces[sea_p].coast_land_provs = {}
		provinces[sea_p].coast_land_provs[land_p] = true
		return
	provinces[pa].neighbors[pb] = true
	provinces[pb].neighbors[pa] = true

func _absorb_orphan_cells() -> void:
	var guard := 0
	while guard < 64:
		guard += 1
		var changed := false
		for y in H:
			for x in W:
				var i := y * W + x
				if is_land[i] == 1 and cell_province[i] == -1:
					var take := -1
					for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
						var nx := x + int(d.x)
						var ny := y + int(d.y)
						if nx < 0 or ny < 0 or nx >= W or ny >= H:
							continue
						var np := cell_province[ny * W + nx]
						if np >= 0:
							take = np
							break
					if take >= 0:
						cell_province[i] = take
						provinces[take].cells.append(i)
						changed = true
		if not changed:
			break
	var pid_next := provinces.size()
	for y in H:
		for x in W:
			var i2 := y * W + x
			if is_land[i2] == 1 and cell_province[i2] == -1:
				cell_province[i2] = pid_next
				provinces.append({"cells": PackedInt32Array([i2]), "center": i2, "state": -1,
					"name": "", "neighbors": {}, "pop": 300000,
					"burg": Vector2(x, y) * CELL, "is_capital_burg": false, "defense": 30,
					"kind": "", "max_pop": 900000, "max_defense": 100,
					"district_pop": 50, "district_max_pop": 150,
					"district_defense": 20, "district_max_defense": 60})
				var stack: Array[int] = [i2]
				while not stack.is_empty():
					var j: int = stack.pop_back()
					for d2 in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
						var nx2 := (j % W) + int(d2.x)
						var ny2 := (j / W) + int(d2.y)
						if nx2 < 0 or ny2 < 0 or nx2 >= W or ny2 >= H:
							continue
						var nj := ny2 * W + nx2
						if is_land[nj] == 1 and cell_province[nj] == -1:
							cell_province[nj] = pid_next
							provinces[pid_next].cells.append(nj)
							stack.append(nj)
				pid_next += 1
	for y in H:
		for x in range(W - 1):
			_link(x + y * W, (x + 1) + y * W)
	for y in range(H - 1):
		for x in W:
			_link(x + y * W, x + (y + 1) * W)

## 河流：从高地格 downhill 走到海，形成细蓝线
func _gen_rivers(rng: RandomNumberGenerator) -> void:
	rivers.clear()
	var sources: Array[int] = []
	for _i in 90:
		var x := rng.randi_range(4, W - 5)
		var y := rng.randi_range(4, H - 5)
		var i := y * W + x
		if is_land[i] == 1 and elevation[i] > sea_level_effective + 0.24:
			sources.append(i)
	for s in sources:
		var pts := PackedVector2Array()
		var cur := s
		var guard := 0
		var seen := {s: true}
		while guard < 400:
			guard += 1
			pts.append(Vector2(cur % W, cur / W) * CELL + Vector2(CELL, CELL) * 0.5)
			var best := -1
			var flat := -1
			var be := elevation[cur]
			var x := cur % W
			var y := cur / W
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
				var nx := x + int(d.x)
				var ny := y + int(d.y)
				if nx < 0 or ny < 0 or nx >= W or ny >= H:
					continue
				var ni := ny * W + nx
				if seen.has(ni):
					continue
				if elevation[ni] < be:
					be = elevation[ni]
					best = ni
				elif flat < 0 and is_equal_approx(elevation[ni], elevation[cur]):
					# 原版高度是 0..100 整数，天然存在等高平台；没有更低格时允许平走一格，
					# 否则在平台上直接断流（重建版河流算法自研，此为适配整数高度场的确定性放行）
					flat = ni
			if best < 0:
				best = flat
			if best < 0:
				break
			cur = best
			seen[cur] = true
			if is_land[cur] == 0:
				pts.append(Vector2(cur % W, cur / W) * CELL + Vector2(CELL, CELL) * 0.5)
				break
		if pts.size() > 6:
			rivers.append(pts)

## 地形散布：山地在高海拔，树木在中海拔带
func _scatter_terrain(rng: RandomNumberGenerator) -> void:
	mountain_spots.clear()
	tree_spots.clear()
	var mnoise := FastNoiseLite.new()
	mnoise.seed = rng.seed + 31
	mnoise.frequency = 0.03
	var tnoise := FastNoiseLite.new()
	tnoise.seed = rng.seed + 77
	tnoise.frequency = 0.04
	for y in range(2, H - 2, 9):
		for x in range(2, W - 2, 9):
			var i := y * W + x
			if is_land[i] == 0:
				continue
			var pos := Vector2(x, y) * CELL
			var e := elevation[i]
			var m := mnoise.get_noise_2d(x, y)
			var mountain_line := sea_level_effective + 0.22
			var tree_low := sea_level_effective + 0.06
			if e > mountain_line and m > 0.30:
				mountain_spots.append([pos + Vector2(rng.randf_range(-5, 5), rng.randf_range(-5, 5)),
					rng.randf_range(0.50, 0.68), rng.randf() < 0.5])
			elif e > tree_low and e < mountain_line and tnoise.get_noise_2d(x, y) > 0.30:
				tree_spots.append([pos + Vector2(rng.randf_range(-5, 5), rng.randf_range(-5, 5)),
					rng.randf_range(0.18, 0.26), rng.randf() < 0.5])

## ===== 首都挑选（忠实还原 SelectCapitalsFromProvinces）=====
## 证据：reports/decompiled/BurgsAndStateGenerator_SelectCapitalsFromProvinces.c
##   radius = sqrt(总 cell 数 / 目标国数)                     （L88-100）
##   候选 = 陆地且尚未归属国家的 cell（重建版以"省中心"为代表，省即最小单位）
##   接受条件 = 与所有已选点 平方距离 > radius²               （L175-201）
##   候选不足 = radius /= 1.2 重试；radius <= 1.0 直接兜底接受（L150-212）
##   取前 need 个（原版对列表做 Take(need) 截断）
const CAPITAL_RADIUS_SHRINK := 1.2  # L211: dVar17 / 1.2000000476837158
const CAPITAL_RADIUS_MIN := 1.0     # L139: dVar17 <= 1.0 兜底

func _select_capital_provinces(state_count: int) -> Array:
	var cand: Array[int] = []
	for pi in provinces.size():
		var c: int = provinces[pi].center
		if c >= 0 and is_land[c] == 1:
			cand.append(pi)
	var want := maxi(state_count, 1)
	var radius := sqrt(float(W * H) / float(want))
	var chosen: Array[int] = []
	var guard := 0
	while guard < 64:
		guard += 1
		chosen.clear()
		var pos: Array[Vector2] = []
		var r2 := radius * radius
		for pi in cand:
			var c2: int = provinces[pi].center
			var p := Vector2(c2 % W, c2 / W)
			var ok := true
			for q in pos:
				if p.distance_squared_to(q) <= r2:
					ok = false
					break
			if ok:
				chosen.append(pi)
				pos.append(p)
				if chosen.size() >= want:
					break
		if chosen.size() >= want or radius <= CAPITAL_RADIUS_MIN:
			break
		radius /= CAPITAL_RADIUS_SHRINK
	return chosen

func _gen_states(rng: RandomNumberGenerator, state_count: int) -> void:
	_label_landmasses()
	states.clear()
	# 首都挑选：忠实还原 SelectCapitalsFromProvinces（伪代码见 reports/decompiled/）
	var capitals := _select_capital_provinces(state_count)
	var polities := ["君主制", "帝制", "共和制", "联邦制", "城邦联盟", "神权政体", "部落制"]
	# 文化/宗教：数据来自原版 StreamingAssets/Base 的真实数据包（CultureData.json / Religion.json）。
	# 【证据边界】数据与 schema 为真（官渡工坊存档解密实测：state.culture/type/expansionism 从文化
	# 拷贝、stateReligionId、province.cultureID/religionDistribution）；文化生成+扩张的机制族
	# （GenerateBaseMap 证实 CultureGenerator.Generate+Expand，与省/国扩张同族）按已反编译的
	# 多源扩张模式重建；种子选址与代价细节待 round12 CultureGenerator 伪代码（culture_system.gd 内标注）。
	_load_culture_religion_data()
	var cultures: Array = _culture_display_names
	var religions: Array = _religion_display_names
	for si in capitals.size():
		provinces[capitals[si]].state = si
		provinces[capitals[si]].is_capital_burg = true
		var col := Color.from_hsv(rng.randf(), rng.randf_range(0.44, 0.64), rng.randf_range(0.68, 0.88))
		# 每国随机扩张乘数 1~6（一位小数）——反编译 ExpandStates L926：惩罚/该乘数
		var mult := snappedf(rng.randf() * 5.0 + 1.0, 0.1)
		states.append({"name": "", "color": col, "capital": capitals[si], "provinces": [], "alive": true,
			"centroid": Vector2.ZERO, "polity": polities[rng.randi() % polities.size()],
			"auto_diplomacy": true, "mult": mult,
			"army": 0, "warships": 0, "allies": [], "vassal_of": -1})
	# 第二遍补领袖/文化/宗教：放在所有国家的 mult 抽取之后，保证扩张乘数序列不被新字段打乱。
	# 文化系统：cell 级多源扩张（独立随机流，不扰主随机流/基线）；国家=首府格文化（schema 实测）。
	if _culture_sys == null:
		_culture_sys = preload("res://scripts/culture_system.gd").new()
	_culture_sys.generate(self, _world_seed)
	for si2 in states.size():
		states[si2].leader = _gen_leader(rng)
		states[si2].culture = _culture_sys.state_culture_display(si2)
		states[si2].religion = _culture_sys.state_religion_display(si2)
	# 第三遍：面板需要但不需要随机数的字段（用确定性派生，避免打乱随机流改变地图基线）
	for si3 in states.size():
		_init_state_meta(si3)
	# 国家扩张：多源 Dijkstra（忠实还原 ExpandStates 机制）
	#   新代价 = 当前代价 + 10 + 地形惩罚/国乘数；地形惩罚 = 20-高度值（下限0）
	#   松弛：新代价 < 旧代价（或首次到达）时占用该 cell
	_expand_states_dijkstra()
	# 省份归属 = 省内 cell 的多数归属（忠实还原 RecalculateProvinceState 语义）
	_recalculate_province_state()
	# 硬保证：首都省必须归本国。
	# 依据：原版 ExpandStates 里首都 cell 是"预占且不被覆盖"的（种子代价 0），所以首都省体内
	# 必然含本国 cell；但省份按 cell 多数改判时，小省可能被邻国多数覆盖 → 出现"零省国家"。
	# 这里把同一保证上提到省粒度，避免出现无领土国家。
	for si in states.size():
		var cap: int = states[si].capital
		if cap >= 0 and cap < provinces.size():
			provinces[cap].state = si
	_fill_unassigned_provinces()
	# V5.3 碎点清理（用户反馈：地图散落小色点）：孤立陆地省（与同国省不邻接）
	# 并入邻国多数归属——保留真正的海岛（无陆路邻居时不强并）。
	_merge_orphan_provinces()
	# 汇总各国行省与质心（含填充阶段追加的岛国）
	for si in states.size():
		states[si].provinces.clear()
	for pi in provinces.size():
		var s: int = provinces[pi].state
		if s >= 0 and s < states.size():
			states[s].provinces.append(pi)
	for si in states.size():
		states[si].centroid = _state_centroid(states[si].provinces)

## 碎省合并（V5.3）：与本国其它省完全不邻接的陆地省 → 并入"邻国中出现最多的国家"
## 迭代两轮（链式碎片）；真正的海岛省（邻居全是海/异国岛）保留——海岛是合理地理。
func _merge_orphan_provinces() -> void:
	for _round in 2:
		var moved := 0
		for pi in provinces.size():
			var p: Dictionary = provinces[pi]
			if p.get("is_sea", false):
				continue
			var mys: int = int(p.get("state", -1))
			if mys < 0:
				continue
			var land_nbrs: Array[int] = []
			for nb in p.neighbors:
				var nbi: int = int(nb)
				if nbi < 0 or nbi >= provinces.size():
					continue
				if provinces[nbi].get("is_sea", false):
					continue
				land_nbrs.append(nbi)
			if land_nbrs.is_empty():
				# V5.3 补充：小离岛（cell < 8）无陆路归属 → 降为海域省（消除海面碎点）
				if (p.get("cells", PackedInt32Array()) as PackedInt32Array).size() < 8 						and p.get("state", -1) != -1:
					p["state"] = -1
					p["is_sea"] = true
					p["occupied_by"] = -1
				continue   # 真海岛（或已降级）：保留
			var has_buddy := false
			var owner_count := {}
			for nbi in land_nbrs:
				var os: int = int(provinces[nbi].get("state", -1))
				if os == mys:
					has_buddy = true
					break
				if os >= 0:
					owner_count[os] = int(owner_count.get(os, 0)) + 1
			if has_buddy:
				continue
			# 完全孤立：并入出现最多的邻国
			var best_os := -1
			var best_n := 0
			for k in owner_count:
				if int(owner_count[k]) > best_n:
					best_n = int(owner_count[k])
					best_os = int(k)
			if best_os >= 0:
				_move_province_raw(pi, mys, best_os)
				moved += 1
		if moved == 0:
			break

## 裸归属转移（不动 alive/历史——孤省合并是美化，不是战争）
func _move_province_raw(pi: int, from_si: int, to_si: int) -> void:
	provinces[pi].state = to_si
	provinces[pi]["occupied_by"] = -1
	if from_si >= 0 and from_si < states.size():
		states[from_si].provinces.erase(pi)
	if to_si >= 0 and to_si < states.size() and not states[to_si].provinces.has(pi):
		states[to_si].provinces.append(pi)

## 二叉小顶堆（GDScript 实现，服务 Dijkstra）
var _heap_cost := PackedFloat32Array()
var _heap_cell := PackedInt32Array()

func _heap_push(c: float, cell: int) -> void:
	_heap_cost.append(c)
	_heap_cell.append(cell)
	var i := _heap_cost.size() - 1
	while i > 0:
		var parent := (i - 1) / 2
		if _heap_cost[parent] <= _heap_cost[i]:
			break
		var tc := _heap_cost[parent]; var tx := _heap_cell[parent]
		_heap_cost[parent] = _heap_cost[i]; _heap_cell[parent] = _heap_cell[i]
		_heap_cost[i] = tc; _heap_cell[i] = tx
		i = parent

func _heap_pop() -> int:
	var top := _heap_cell[0]
	var lc := _heap_cost[_heap_cost.size() - 1]
	var lx := _heap_cell[_heap_cell.size() - 1]
	_heap_cost.resize(_heap_cost.size() - 1)
	_heap_cell.resize(_heap_cell.size() - 1)
	if _heap_cost.size() == 0:
		return top
	_heap_cost[0] = lc
	_heap_cell[0] = lx
	var i := 0
	while true:
		var l := i * 2 + 1
		var r := i * 2 + 2
		var m := i
		if l < _heap_cost.size() and _heap_cost[l] < _heap_cost[m]:
			m = l
		if r < _heap_cost.size() and _heap_cost[r] < _heap_cost[m]:
			m = r
		if m == i:
			break
		var tc := _heap_cost[m]; var tx := _heap_cell[m]
		_heap_cost[m] = _heap_cost[i]; _heap_cell[m] = _heap_cell[i]
		_heap_cost[i] = tc; _heap_cell[i] = tx
		i = m
	return top

func _heap_empty() -> bool:
	return _heap_cost.size() == 0

## 多源 Dijkstra 国家扩张（忠实还原 ExpandStates 机制）
## 海岸层级 t（★A cells.t）：1=沿岸陆地，2=离海一层，3=更远（封顶），内陆 -1（本工程无内陆标记语义时用 3）
func _compute_coast_layers() -> PackedInt32Array:
	var n := W * H
	var t := PackedInt32Array()
	t.resize(n)
	t.fill(-1)
	var q: Array[int] = []
	for i in n:
		if is_land[i] == 0:
			continue
		var x0: int = i % W
		var y0: int = i / W
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nx0: int = x0 + int(d.x)
			var ny0: int = y0 + int(d.y)
			if nx0 < 0 or ny0 < 0 or nx0 >= W or ny0 >= H:
				continue
			if is_land[ny0 * W + nx0] == 0:
				t[i] = 1
				q.append(i)
				break
	var layer := 1
	while q.size() > 0 and layer < 3:
		var nq: Array[int] = []
		for c2 in q:
			var x1: int = c2 % W
			var y1: int = c2 / W
			for d1 in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx1: int = x1 + int(d1.x)
				var ny1: int = y1 + int(d1.y)
				if nx1 < 0 or ny1 < 0 or nx1 >= W or ny1 >= H:
					continue
				var nb: int = ny1 * W + nx1
				if is_land[nb] == 1 and t[nb] == -1:
					t[nb] = layer + 1
					nq.append(nb)
		q = nq
		layer += 1
	return t

func _expand_states_dijkstra() -> void:
	## ★A 移植 main.dec.js expandStates（L5474）：完整代价函数 + 海格永不归属 + neutral 上限。
	## 数据源：culture_system.assignment（cell 文化）、gen.biome（0..12）、elevation(0..1)。
	## 简化项（标注）：riverCost 缺 river/flux 数据 → 0；populationCost 用省人口均/格 <=0 → 5000。
	var n := W * H
	var cost := PackedFloat32Array()
	cost.resize(n)
	cost.fill(-1.0)
	var owner := PackedInt32Array()
	owner.resize(n)
	owner.fill(-1)
	_heap_cost = PackedFloat32Array()
	_heap_cell = PackedInt32Array()
	# cells.t 海岸层级（★A t 定义：1=沿岸陆地 2=离海一层 …，BFS 3 层封顶，内陆 -1）
	var t := _compute_coast_layers()
	# 群系移动代价（★A Biomes.getDefault cost，13 群系）
	const BIOME_COST := [10.0, 200.0, 150.0, 60.0, 50.0, 70.0, 70.0, 80.0, 90.0, 200.0, 1000.0, 5000.0, 150.0]
	var neutral: float = float(n) / 2.0   # ★A neutral = cellCount/2 × 1 × 1
	# 文化分配（cell→文化序号），供 cultureCost
	var cul: PackedInt32Array = _culture_sys.assignment
	# state.type 从文化拷贝（★A schema：state.type(从文化拷贝)）
	for si in states.size():
		states[si].type = _culture_sys.culture_type[si] if si < _culture_sys.culture_type.size() else "Generic"
		states[si].expansionism = _culture_sys.culture_expansionism[si] if si < _culture_sys.culture_expansionism.size() else 1.0
	# 首都 cell 锁定（★A capital cell 不被覆盖）：先记录
	var cap_cell: PackedInt32Array = PackedInt32Array()
	cap_cell.resize(states.size())
	for si0 in states.size():
		var cc: PackedInt32Array = provinces[states[si0].capital].cells
		cap_cell[si0] = cc[cc.size() / 2]
	# 种子：首都省中心 cell（原版 state.center 为文化中心；本工程用首都近似，已标注）
	_heap_cost = PackedFloat32Array()
	_heap_cell = PackedInt32Array()
	for si2 in states.size():
		_heap_push(0.0, cap_cell[si2])
		cost[cap_cell[si2]] = 0.0
		owner[cap_cell[si2]] = si2
	while not _heap_empty():
		var c: float = _heap_cost[0]
		var e: int = _heap_pop()
		if cost[e] != -1.0 and c > cost[e] + 0.001:
			continue
		var s_owner: int = owner[e]
		if s_owner < 0:
			continue
		var st: Dictionary = states[s_owner]
		var stype: String = str(st.get("type", "Generic"))
		var exp_mul: float = float(st.get("expansionism", 1.0))
		if exp_mul <= 0.0:
			exp_mul = 1.0
		var native_biome: int = int(biome[e])   # ★A b = cells.biome[cultureCenter]；本工程用出发格群系近似
		var x2 := e % W
		var y2 := e / W
		for d2 in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]:
			var nx2: int = x2 + int(d2.x)
			var ny2: int = y2 + int(d2.y)
			if nx2 < 0 or ny2 < 0 or nx2 >= W or ny2 >= H:
				continue
			var ni: int = ny2 * W + nx2
			# cultureCost（★A：同文化 -9 / 异 +100）
			var cci: int = cul[ni] if ni < cul.size() else -1
			var culture_cost: float = -9.0 if (cci == _culture_sys.state_culture[s_owner]) else 100.0
			var pop_cost: float = 0.0
			if is_land[ni] == 1:
				var pi_c: int = int(cell_province[ni])
				if pi_c >= 0 and float(provinces[pi_c].get("pop", 0)) <= 0.0:
					pop_cost = 5000.0   # ★A 无人陆地
			# biomeCost（★A）
			var biome_i: int = int(biome[ni])
			var biome_cost: float = 10.0
			if biome_i != native_biome:
				if stype == "Hunting":
					biome_cost = BIOME_COST[clampi(biome_i, 0, 12)] * 2.0
				elif stype == "Nomadic" and biome_i > 4 and biome_i < 10:
					biome_cost = BIOME_COST[clampi(biome_i, 0, 12)] * 3.0
				else:
					biome_cost = BIOME_COST[clampi(biome_i, 0, 12)]
			# heightCost（★A；h = elevation×100 的 0..100 制）
			var h100: float = float(elevation[ni]) * 100.0
			var height_cost := 0.0
			if h100 < 20.0:
				if stype == "Naval":
					height_cost = 300.0
				elif stype == "Nomadic":
					height_cost = 10000.0
				else:
					height_cost = 1000.0
			elif stype == "Highland":
				height_cost = 0.0 if h100 >= 62.0 else 1100.0
			elif h100 >= 67.0:
				height_cost = 2200.0
			elif h100 >= 44.0:
				height_cost = 300.0
			# typeCost（★A；riverCost 无数据 → 0，标注）
			var type_cost := 0.0
			var ti: int = t[ni]
			if ti == 1:
				if stype == "Naval":
					type_cost = 0.0
				elif stype == "Nomadic":
					type_cost = 60.0
				else:
					type_cost = 20.0
			elif ti == 2:
				type_cost = 30.0 if (stype == "Naval" or stype == "Nomadic") else 0.0
			elif ti != -1:
				type_cost = 100.0 if (stype == "Naval") else 0.0
			var cell_cost: float = maxf(culture_cost + pop_cost + biome_cost + height_cost + type_cost, 0.0)
			var total: float = c + 10.0 + cell_cost / exp_mul
			if total > neutral:
				continue   # ★A neutral 上限
			# 松弛阈值 1e-3：cellCost 含 /exp 浮点除，同代价平台上 float32 回写精度（~1e-5）
			# 会造成虚假"改善"→ 堆振荡爆炸（V5 事故：堆 400 万/pop 300 万）。epsilon 截断。
			if cost[ni] == -1.0 or total < cost[ni] - 0.001:
				cost[ni] = total
				if is_land[ni] == 1:
					owner[ni] = s_owner   # ★A 只有陆地写归属（h>=20 才 state 赋值）
				_heap_push(total, ni)
	# cell 归属缓存（省份多数计算用）
	_cell_state_owner = owner
	_normalize_states_cells(owner)
	for i2 in n:
		_cell_state_owner[i2] = owner[i2]

## ★A normalizeStates（L5573）逐义移植（cell 级，burg/capital 保护）：
## 陆地格（非首都省格）若异国邻居 ≥2 且同国邻居 ≤2 且 异≥同 → 并入第一个异国邻居（清除细碎飞地）
func _normalize_states_cells(owner: PackedInt32Array) -> void:
	var cap_cells := {}
	for si in states.size():
		for cc in provinces[states[si].capital].cells:
			cap_cells[cc] = true
	var n := W * H
	for i in n:
		if is_land[i] == 0:
			continue
		if cap_cells.has(i):
			continue
		var mys: int = owner[i]
		if mys < 0:
			continue
		var x := i % W
		var y := i / W
		var adversaries: Array[int] = []
		var buddies: Array[int] = []
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]:
			var nx: int = x + int(d.x)
			var ny: int = y + int(d.y)
			if nx < 0 or ny < 0 or nx >= W or ny >= H:
				continue
			var nb: int = ny * W + nx
			if is_land[nb] == 0 or cap_cells.has(nb):
				continue
			var os: int = owner[nb]
			if os < 0 or os == mys:
				buddies.append(nb)
			else:
				adversaries.append(nb)
		if adversaries.size() < 2:
			continue
		if buddies.size() > 2:
			continue
		if adversaries.size() <= buddies.size():
			continue
		owner[i] = owner[adversaries[0]]

var _cell_state_owner := PackedInt32Array()

## 省份归属 = 省内 cell 的多数归属（RecalculateProvinceState 语义）
func _recalculate_province_state() -> void:
	for pi in provinces.size():
		if provinces[pi].get("is_sea", false):
			provinces[pi].state = -1
			continue
		var counts := {}
		for ci in provinces[pi].cells:
			var s: int = _cell_state_owner[ci]
			if s >= 0:
				counts[s] = int(counts.get(s, 0)) + 1
		var best := -1
		var bn := 0
		for k in counts:
			if counts[k] > bn:
				bn = counts[k]
				best = k
		provinces[pi].state = best

func _state_centroid(plist: Array) -> Vector2:
	var acc := Vector2.ZERO
	var n := 0
	for pi in plist:
		acc += provinces[pi].burg
		n += 1
	return acc / maxf(n, 1)

## 陆块编号：省份邻接图的连通分量 = 地理陆块（国家不跨海，对齐原版岛屿国家表现）
func _label_landmasses() -> void:
	for p in provinces:
		p.landmass = -1
	var lm := 0
	for pi in provinces.size():
		if provinces[pi].landmass != -1:
			continue
		var stack: Array[int] = [pi]
		provinces[pi].landmass = lm
		while not stack.is_empty():
			var cur: int = stack.pop_back()
			for nb in provinces[cur].neighbors:
				if provinces[nb].landmass == -1:
					provinces[nb].landmass = lm
					stack.append(nb)
		lm += 1

func _landmass_of(pi: int) -> int:
	return provinces[pi].get("landmass", 0)

## 生长概率留下的空洞省份：先按邻接膨胀；再在同陆块内就近并入；
## 整块无主的陆块自成新国家（原版岛屿国家表现；国家总数相应增加）
func _fill_unassigned_provinces() -> void:
	var guard := 0
	while guard < 128:
		guard += 1
		var changed := false
		for pi in provinces.size():
			if provinces[pi].state != -1 or provinces[pi].get("is_sea", false):
				continue
			for nb in provinces[pi].neighbors:
				if provinces[nb].state != -1:
					provinces[pi].state = provinces[nb].state
					changed = true
					break
		if not changed:
			break
	# 同陆块内就近并入
	for pi in provinces.size():
		if provinces[pi].state != -1 or provinces[pi].get("is_sea", false):
			continue
		var best := -1
		var bd := INF
		var a := _province_center(pi)
		for pj in provinces.size():
			if provinces[pj].state == -1 or _landmass_of(pj) != _landmass_of(pi):
				continue
			var d := a.distance_squared_to(_province_center(pj))
			if d < bd:
				bd = d
				best = pj
		if best >= 0:
			provinces[pi].state = provinces[best].state
	# 仍整块无主的陆块 → 自成新国家（两段式：先分组后追加，保证 ID 连续）
	var rng := RandomNumberGenerator.new()
	rng.seed = 777
	var new_states := {}
	for pi in provinces.size():
		if provinces[pi].state != -1 or provinces[pi].get("is_sea", false):
			continue
		var lm := _landmass_of(pi)
		if not new_states.has(lm):
			new_states[lm] = []
		new_states[lm].append(pi)
	for lm in new_states:
		var still: Array = new_states[lm]
		if still.size() < 6:
			# 小岛群并入最近国家（原版表现：少量岛国，小岛归入既有国家）
			var best := -1
			var bd := INF
			var a := _province_center(still[0])
			for pj in provinces.size():
				var s: int = provinces[pj].state
				if s < 0:
					continue
				var d := a.distance_squared_to(_province_center(pj))
				if d < bd:
					bd = d
					best = s
			if best >= 0:
				for pi in still:
					provinces[pi].state = best
				continue
		var new_si := states.size()
		var col := Color.from_hsv(rng.randf(), rng.randf_range(0.44, 0.64), rng.randf_range(0.68, 0.88))
		var acc := Vector2.ZERO
		for pi in still:
			provinces[pi].state = new_si
			acc += provinces[pi].burg
		states.append({"name": "", "color": col, "capital": still[0], "provinces": still.duplicate(),
			"alive": true, "centroid": acc / still.size(), "polity": "城邦联盟", "auto_diplomacy": true,
			"mult": 3.0, "leader": _gen_leader(rng),
			# 确定性下标（不抽 rng，避免改变随机流/基线）
			"culture": _culture_display_names[still.size() % _culture_display_names.size()],
			"religion": _religion_display_names[still.size() % _religion_display_names.size()],
			"army": 0, "warships": 0, "allies": [], "vassal_of": -1})

## 原版文化/宗教数据包的显示名与 id（懒加载，见 _load_culture_religion_data）
var _culture_display_names: Array = []
var _religion_display_names: Array = []
var _culture_ids: Array = []
## 文化系统实例（cell 级文化扩张 + 国家归属；见 scripts/culture_system.gd 的证据边界标注）
var _culture_sys = null
var _world_seed := 0   ## generate() 记录的世界种子（文化系统独立随机流用）

## 文化/宗教数据懒加载（原版数据包 → 显示名列表）。加载失败时退回空表，分配处自行兜底。
func _load_culture_religion_data() -> void:
	if not _culture_display_names.is_empty():
		return
	var cp = preload("res://scripts/culture_pack.gd").new()
	cp.load_all()
	for cid in cp.order:
		_culture_ids.append(cid)
		_culture_display_names.append(str(cp.cultures[cid].get("display_zh", cid)))
	var rp = preload("res://scripts/religion_pack.gd").new()
	rp.load_all()
	for r in rp.all_religions():
		_religion_display_names.append(str(r.get("name_zh", r.get("key", ""))))
	if _culture_display_names.is_empty():
		_culture_display_names = ["—"]
	if _religion_display_names.is_empty():
		_religion_display_names = ["—"]

func _province_center(pi: int) -> Vector2:
	var cells: PackedInt32Array = provinces[pi].cells
	var i := cells[cells.size() / 2]
	return Vector2(i % W, i / W)

## 领袖生成占位：原版 StateLeaderGenerator 未反编译，但字段已确凿（StateInfoUI 有男女按钮色与最小年龄）
func _gen_leader(rng: RandomNumberGenerator) -> Dictionary:
	var clan := ["嬴", "芈", "姬", "姜", "妫", "姒", "子", "妘"]
	var given := ["昭", "武", "文", "桓", "穆", "襄", "悼", "简", "灵", "惠", "成", "康", "幽", "厉", "平", "献"]
	return {"name": clan[rng.randi() % clan.size()] + given[rng.randi() % given.size()],
		"gender": "男" if rng.randf() < 0.78 else "女",
		"age": rng.randi_range(18, 62)}

func _assign_names(rng: RandomNumberGenerator) -> void:
	# 双字/三字汉风国名 + 单字省名（贴近原版中文观感；正式命名集走 Mods 数据）
	var pre := ["东", "西", "南", "北", "大", "小", "安", "定", "平", "远", "镇", "朔", "临", "武", "文", "昭"]
	var core := ["魏", "蜀", "吴", "晋", "秦", "楚", "燕", "赵", "齐", "鲁", "梁", "陈", "汉", "唐", "周", "隋", "明", "凉", "雍", "并"]
	var suffix := ["侯", "公", "伯", "国", "郡", "州"]
	var single := ["丰", "沛", "昆", "陵", "兰", "桂", "榆", "松", "泓", "渭", "汾", "沂", "岱", "岚", "泸", "淇"]
	for si in states.size():
		var n := ""
		if rng.randf() < 0.6:
			n += pre[rng.randi() % pre.size()]
		n += core[rng.randi() % core.size()]
		if rng.randf() < 0.55:
			n += suffix[rng.randi() % suffix.size()]
		states[si].name = n
	var sea_n := 0
	for pi in provinces.size():
		if provinces[pi].get("is_sea", false):
			sea_n += 1
			provinces[pi].name = "海域 %d" % sea_n
		else:
			provinces[pi].name = single[rng.randi() % single.size()]

func cell_index_at(world_pos: Vector2) -> int:
	var x := int(world_pos.x / CELL)
	var y := int(world_pos.y / CELL)
	if x < 0 or y < 0 or x >= W or y >= H:
		return -1
	return y * W + x

# ============================================================================
# 生物群系（Biome）—— 数据与显示
# 证据：
#   · 13 个群系的名字与顺序 = 原版 Base/BiomeResource/BiomeResource.json 的
#     biomeDistribution 顺序，中文名取自原版 StreamingAssets/localization.csv
#     （已落盘 assets/origin/biomes.json）。
#   · Biomes 类型字段（dump-assembly-csharp.txt type#84）：colors / cost /
#     habitability / biomesMatrix / speedModifier / populationInitRange ...
#     → 原版确有"每群系颜色 + 移动代价 + 宜居度 + 温湿矩阵"。
# ⚠️ 未还原部分：群系**判定规则**（温度×湿度矩阵）与**颜色表**在 `Biomes..cctor`
#    （0x363f20）与 `World.GenerateBaseMap`（0x6ad5d0）里，两者已排队反编译
#    （logs/dec5_*）。当前矩阵与颜色是显式标注的近似，落到真值后替换本段函数。
# ============================================================================

## 群系索引（顺序与原版 biomeDistribution 一致）
const BIOME_MARINE := 0
const BIOME_HOT_DESERT := 1
const BIOME_COLD_DESERT := 2
const BIOME_SAVANNA := 3
const BIOME_STEPPE := 4
const BIOME_TROPICAL_SEASONAL := 5
const BIOME_TEMPERATE_DECIDUOUS := 6
const BIOME_TROPICAL_RAINFOREST := 7
const BIOME_SUBTROPICAL_EVERGREEN := 8
const BIOME_TAIGA := 9
const BIOME_TUNDRA := 10
const BIOME_SNOW := 11
const BIOME_WETLAND := 12
const BIOME_COUNT := 13

## 近似配色（原版真实色表在 Biomes..cctor，未取到）——仅用于显示，不参与任何判定
const BIOME_COLORS := [
	Color(0.34, 0.44, 0.55),  # 0 海洋
	Color(0.85, 0.76, 0.50),  # 1 热带沙漠
	Color(0.72, 0.70, 0.63),  # 2 寒带沙漠
	Color(0.78, 0.72, 0.42),  # 3 热带草原
	Color(0.72, 0.70, 0.48),  # 4 草原
	Color(0.47, 0.62, 0.36),  # 5 热带季节性森林
	Color(0.38, 0.58, 0.33),  # 6 温带落叶林
	Color(0.24, 0.52, 0.28),  # 7 热带雨林
	Color(0.30, 0.55, 0.32),  # 8 亚热带常绿阔叶林
	Color(0.32, 0.47, 0.38),  # 9 针叶林
	Color(0.62, 0.66, 0.62),  # 10 苔原
	Color(0.92, 0.93, 0.95),  # 11 积雪地带
	Color(0.40, 0.55, 0.48),  # 12 湿地
]

var biome := PackedByteArray()          # 每 cell 群系索引（0..12）
var biome_names: Array = []             # 英文名（来自 biomes.json）
var biome_names_zh: Array = []          # 中文名（原版 localization.csv）
var biome_resources: Array = []         # 每群系资源表（来自 BiomeResource.json）
var temperature := PackedFloat32Array() # 0..1（供面板显示与群系判定）
var moisture := PackedFloat32Array()    # 0..1

func load_biome_data() -> void:
	biome_names.clear()
	biome_names_zh.clear()
	var f := FileAccess.open("res://assets/origin/biomes.json", FileAccess.READ)
	if f:
		var d: Variant = JSON.parse_string(f.get_as_text())
		if d is Dictionary and d.has("biomes"):
			for e in d.biomes:
				biome_names.append(str(e.get("name", "")))
				biome_names_zh.append(str(e.get("name_zh", e.get("name", ""))))
	var rf := FileAccess.open("res://assets/origin/BiomeResource.json", FileAccess.READ)
	if rf:
		var rd: Variant = JSON.parse_string(rf.get_as_text())
		if rd is Dictionary and rd.has("biomeDistribution"):
			for b in rd.biomeDistribution:
				var res: Array = []
				for r in b.get("Resources", []):
					res.append({"name": str(r.get("Name", "")), "prob": float(r.get("Probability", 0.0))})
				biome_resources.append(res)

## 群系中文名（面板/工具提示用）
func biome_label(b: int) -> String:
	if b >= 0 and b < biome_names_zh.size():
		return str(biome_names_zh[b])
	return "群系 %d" % b

## 群系生成：温度（纬度 + 海拔递减）× 湿度（噪声 + 距海）→ 13 群系矩阵
## ⚠️ 近似实现：真实规则在 World.GenerateBaseMap（反编译排队中），落真值后替换本函数
func _gen_biomes(seed_val: int) -> void:
	load_biome_data()
	biome.resize(W * H)
	temperature.resize(W * H)
	moisture.resize(W * H)
	var noise := FastNoiseLite.new()
	noise.seed = seed_val + 4242
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.018
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 4
	# 距海距离场（BFS 从海格出发），用于湿度衰减：内陆更干
	var dist_sea := PackedInt32Array()
	dist_sea.resize(W * H)
	dist_sea.fill(-1)
	var queue: Array[int] = []
	for i in W * H:
		if is_land[i] == 0:
			dist_sea[i] = 0
			queue.append(i)
	var head := 0
	while head < queue.size():
		var cur: int = queue[head]
		head += 1
		var x := cur % W
		var y := cur / W
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nx := x + int(d.x)
			var ny := y + int(d.y)
			if nx < 0 or ny < 0 or nx >= W or ny >= H:
				continue
			var ni := ny * W + nx
			if dist_sea[ni] == -1:
				dist_sea[ni] = dist_sea[cur] + 1
				queue.append(ni)
	var max_dist := 1
	for i in W * H:
		max_dist = maxi(max_dist, dist_sea[i])
	for y in H:
		for x in W:
			var i := y * W + x
			# 纬度：0=赤道（地图中线） 1=两极（上下边）
			var lat := absf(float(y) / float(H - 1) * 2.0 - 1.0)
			var h := maxf(elevation[i] - sea_level_effective, 0.0)
			var t := clampf(1.0 - lat * 1.08 - h * 0.55, 0.0, 1.0)
			var dsea := float(dist_sea[i]) / float(max_dist)
			var m := clampf(noise.get_noise_2d(x, y) * 0.5 + 0.55 - dsea * 0.45, 0.0, 1.0)
			temperature[i] = t
			moisture[i] = m
			biome[i] = _biome_from_climate(i, t, m)

## 温湿矩阵（13 群系）。近似：与原版 biomesMatrix 结构一致（温度×湿度→群系），阈值未反编译
func _biome_from_climate(cell: int, t: float, m: float) -> int:
	if is_land[cell] == 0:
		return BIOME_MARINE
	var h := elevation[cell] - sea_level_effective
	if t < 0.12:
		return BIOME_SNOW
	if t < 0.26:
		if m < 0.35:
			return BIOME_COLD_DESERT
		return BIOME_TUNDRA
	if t < 0.42:
		if m < 0.30:
			return BIOME_STEPPE
		if m < 0.55:
			return BIOME_TAIGA
		return BIOME_WETLAND if h < 0.06 else BIOME_TAIGA
	if t < 0.62:
		if m < 0.30:
			return BIOME_STEPPE
		if m < 0.52:
			return BIOME_TEMPERATE_DECIDUOUS
		if m < 0.74:
			return BIOME_SUBTROPICAL_EVERGREEN
		return BIOME_WETLAND if h < 0.05 else BIOME_TEMPERATE_DECIDUOUS
	# 暖区
	if m < 0.28:
		return BIOME_HOT_DESERT
	if m < 0.46:
		return BIOME_SAVANNA
	if m < 0.68:
		return BIOME_TROPICAL_SEASONAL
	if m < 0.85:
		return BIOME_TROPICAL_RAINFOREST
	return BIOME_WETLAND if h < 0.05 else BIOME_TROPICAL_RAINFOREST

## 群系被编辑后重算该 cell（供编辑器调用）
func set_biome(cell: int, b: int) -> void:
	if cell < 0 or cell >= W * H:
		return
	biome[cell] = clampi(b, 0, BIOME_COUNT - 1)

# ============================================================================
# 编辑器支持：结构重建与一致性修复
# ============================================================================

## 高度被编辑后：重算陆海判定，并处理因此产生的未绘制陆地/待并入海域
## 原版语义：新绘制的陆地"无法直接占领"，需要在行省面板中放置行省（EditHeightmapTutorial）
func apply_height_changes(changed: Array) -> void:
	for cv in changed:
		var i: int = cv
		var land := 1 if elevation[i] > sea_level_effective else 0
		if land != is_land[i]:
			is_land[i] = land
			cell_province[i] = -1
	absorb_unassigned_sea()

## 未被任何海域省覆盖的海格 → 按最近的海域省归属；若一个海域省都没有则新建一个
func absorb_unassigned_sea() -> void:
	var queue: Array[int] = []
	var has_sea := false
	for pi in provinces.size():
		if provinces[pi].get("is_sea", false) and provinces[pi].cells.size() > 0:
			has_sea = true
			break
	if not has_sea:
		# 全图没有海域省（例如清空地图后）：建一个覆盖全图的海洋省
		var cells: Array[int] = []
		var center := -1
		for i in W * H:
			if is_land[i] == 0:
				cells.append(i)
				cell_province[i] = provinces.size()
				if center < 0:
					center = i
		if cells.is_empty():
			return
		provinces.append({"cells": PackedInt32Array(cells), "center": center, "state": -1,
			"name": "海域 1", "neighbors": {}, "pop": 0, "burg": Vector2(-1, -1),
			"is_capital_burg": false, "defense": 0, "kind": "", "max_pop": 0, "max_defense": 0,
			"district_pop": 0, "district_max_pop": 0, "district_defense": 0,
			"district_max_defense": 0, "is_sea": true, "sea_index": 0, "sea_tier": 2})
		return
	for i in W * H:
		if is_land[i] == 0 and cell_province[i] < 0:
			queue.append(i)
	var guard := 0
	while not queue.is_empty() and guard < 64:
		guard += 1
		var next: Array[int] = []
		for cur in queue:
			if cell_province[cur] >= 0:
				continue
			var x := cur % W
			var y := cur / W
			var take := -1
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx := x + int(d.x)
				var ny := y + int(d.y)
				if nx < 0 or ny < 0 or nx >= W or ny >= H:
					continue
				var np := cell_province[ny * W + nx]
				if np >= 0 and provinces[np].get("is_sea", false):
					take = np
					break
			if take >= 0:
				cell_province[cur] = take
			else:
				next.append(cur)
		queue = next

## 行省结构重建：丢弃空省 → 重编号 → 重建邻接/海岸 → 同步国家
## 返回 {旧省id: 新省id}（被丢弃的为空省 → -1），供编辑器重映射选中项
func rebuild_after_province_edit() -> Dictionary:
	_rebuild_province_cells()
	var remap := {}
	var kept: Array = []
	for pi in provinces.size():
		if provinces[pi].cells.size() == 0:
			remap[pi] = -1
			continue
		remap[pi] = kept.size()
		kept.append(provinces[pi])
	provinces = kept
	for i in W * H:
		var p := cell_province[i]
		if p >= 0:
			var np2: int = int(remap.get(p, -1))
			cell_province[i] = np2
	# 重建邻接图与海岸记录
	for p2 in provinces:
		p2.neighbors = {}
		if p2.get("is_sea", false):
			p2.coast_land_provs = {}
	for y in H:
		for x in range(W - 1):
			_link(x + y * W, (x + 1) + y * W)
	for y in range(H - 1):
		for x in W:
			_link(x + y * W, x + (y + 1) * W)
	_sync_states_from_provinces()
	return remap

## 国家结构重建：行省的 state 字段为唯一真相，重建 states[i].provinces、
## 迁都（首都省失守时）、灭亡判定、质心
func rebuild_after_state_edit() -> void:
	_sync_states_from_provinces()

func _sync_states_from_provinces() -> void:
	for si in states.size():
		states[si].provinces = []
	for pi in provinces.size():
		var st: int = provinces[pi].state
		if st >= 0 and st < states.size():
			states[st].provinces.append(pi)
		else:
			provinces[pi].state = -1
	for si in states.size():
		var s: Dictionary = states[si]
		for pi2 in s.provinces:
			provinces[pi2].is_capital_burg = false
		if s.provinces.is_empty():
			s.alive = false
			continue
		if not s.provinces.has(s.capital):
			var best: int = s.provinces[0]
			var bc := -1
			for pi3 in s.provinces:
				var n: int = provinces[pi3].cells.size()
				if n > bc:
					bc = n
					best = pi3
			s.capital = best
		provinces[s.capital].is_capital_burg = true
		s.centroid = _state_centroid(s.provinces)
		_map_state_color_if_needed(si)

## 新建国家/复活国家时补颜色（原有颜色不动）
func _map_state_color_if_needed(si: int) -> void:
	var s: Dictionary = states[si]
	if not s.has("color") or s.color == null:
		s.color = Color.from_hsv(fmod(float(si) * 0.37, 1.0), 0.45, 0.72)

## 新增一个行省（原版 AddProvince：点击陆地生成只占 1 cell 的新省，随后进入笔刷绘制）
func add_province_at(cell: int) -> int:
	if cell < 0 or is_land[cell] == 0:
		return -1
	var pid := provinces.size()
	provinces.append({"cells": PackedInt32Array([cell]), "center": cell, "state": -1,
		"name": "新行省 %d" % (pid + 1), "neighbors": {}, "pop": 300000,
		"burg": Vector2(cell % W, cell / W) * CELL + Vector2(CELL, CELL) * 0.5,
		"is_capital_burg": false, "defense": 30, "kind": "",
		"max_pop": 900000, "max_defense": 100, "district_pop": 50000, "district_max_pop": 150000,
		"district_defense": 20, "district_max_defense": 60})
	cell_province[cell] = pid
	return pid

## 新增一个国家（原版 PlaceState / DrawState 的"空白国家"入口）
func add_state(name_hint := "") -> int:
	var si := states.size()
	states.append({"name": name_hint if name_hint != "" else "新国家 %d" % (si + 1),
		"color": Color.from_hsv(fmod(0.11 + float(si) * 0.37, 1.0), 0.45, 0.72),
		"capital": -1, "provinces": [], "alive": true, "centroid": Vector2.ZERO,
		"polity": "君主制", "auto_diplomacy": true, "mult": 1.0,
		"leader": {"name": "—", "gender": "男", "age": 30},
		"culture": "—", "religion": "—", "army": 0, "warships": 0,
		"allies": [], "vassal_of": -1})
	return si

## 把一批行省划给某国（行省是国家的最小单位——原版 TerrainStateEditBrush）
func assign_provinces_to_state(plist: Array, si: int) -> void:
	for pi in plist:
		if pi < 0 or pi >= provinces.size():
			continue
		provinces[pi].state = si
	rebuild_after_state_edit()

## 清空地图（原版 ClearMap / WorldClearMap）：高度归零、清空行政与群系，只留海
func clear_map() -> void:
	elevation.fill(0.0)
	is_land.fill(0)
	cell_province.fill(-1)
	biome.fill(BIOME_MARINE)
	var _t0 := Time.get_ticks_msec()
	provinces.clear()
	states.clear()
	rivers.clear()
	mountain_spots.clear()
	tree_spots.clear()
	for i in W * H:
		cell_province[i] = -1
	absorb_unassigned_sea()

## 刷新河流与地形散布（原版全局指令"刷新河流与航线"的河流部分）
func refresh_rivers_and_terrain(seed_val: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	_gen_rivers(rng)
	_scatter_terrain(rng)


## 国家面板字段（对齐原版 StateInfoUI 的信息表）：国库 / 腐败度 / 建立年份 / 官员 / 民族特征
## ⚠️ 官员姓名与民族特征为占位词库（原版走 StateLeaderGenerator / 文化包），数值为按国力派生
const STATE_TRAITS := ["海洋", "尚武", "商业", "农耕", "游牧", "山地", "航海", "学术"]
const OFFICE_TITLES := ["内阁首辅", "户部尚书", "兵部尚书"]

func _init_state_meta(si: int) -> void:
	if si < 0 or si >= states.size():
		return
	var s: Dictionary = states[si]
	var pop := 0
	for pi in s.provinces:
		pop += int(provinces[pi].pop)
	s.trait = STATE_TRAITS[si % STATE_TRAITS.size()]
	s.founded_year = 846 + (si * 7) % 15
	s.treasury = 20000 + pop / 45 + (si * 137) % 5000
	s.corruption = 8 + (si * 13) % 55          # 0..100，面板按区间显示 清廉/轻度腐败/严重腐败
	# 官员（占位姓名：取自同一汉风词库，标注为占位）
	var officials := {}
	for k in OFFICE_TITLES.size():
		var surnames := ["俞", "邹", "王", "李", "赵", "陈", "周", "孙"]
		var givens := ["泽", "霖", "子龙", "焕", "安", "亭", "武", "文"]
		var nm: String = surnames[(si * 3 + k) % surnames.size()]
		var gn: String = givens[(si * 5 + k * 2) % givens.size()]
		officials[OFFICE_TITLES[k]] = nm + gn
	s.officials = officials

## 国家人口上限 = 各行省 max_pop 之和
func state_pop_cap(si: int) -> int:
	var cap := 0
	if si < 0 or si >= states.size():
		return 0
	for pi in states[si].provinces:
		cap += int(provinces[pi].get("max_pop", 0))
	return cap

## 区域数量：重建版把"有区域数据的行省"计为一个区域（原版区域是行省的父级）
func state_district_count(si: int) -> int:
	var n := 0
	if si < 0 or si >= states.size():
		return 0
	for pi in states[si].provinces:
		if int(provinces[pi].get("district_max_pop", 0)) > 0:
			n += 1
	return n
