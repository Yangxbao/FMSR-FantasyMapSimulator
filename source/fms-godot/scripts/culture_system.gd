extends RefCounted
## 文化系统（数据=原版数据包；机制=按原版 schema 重建）
##
## 【证据边界】
##   真（原版数据/反编译）：
##   - 文化对象字段 {Name,type,expansionism,code,center,Shield,...} —— 官渡工坊存档解密实测
##     （logs/workshop_guandu.json，logs/_prov_schema.txt）；
##   - cell→Culture 归属数组、state.culture/cultureName/type/ethnicAttribute/expansionism 拷贝、
##     province.cultureID/religionDistribution、state.stateReligionId —— 序列化 schema 实测；
##   - 扩张机制与省/国扩张同族（GenerateBaseMap 证实 CultureGenerator.Generate+Expand；
##     ExpandStates/ExpandProvinces 已反编译，多源 Dijkstra 模式）。
##   待证（round12 CultureGenerator$$Generate/Expand 伪代码落地后校正）：
##   - 种子数量与选址规则、扩张代价函数细节、国家→文化的归属规则（现按首府文化多数）、
##   - 宗教分配规则（现按文化→宗教确定性映射，待 State$$DetermineStateReligion）。

const CulturePacks := preload("res://scripts/culture_pack.gd")
const ReligionPacks := preload("res://scripts/religion_pack.gd")

var assignment := PackedInt32Array()   ## cell -> 文化序号（-1 = 海/未归属）
var culture_ids := []                  ## 序号 -> 包目录名
var culture_display := []              ## 序号 -> 显示名（MapCultureTranslations[0]）
var culture_type := []                 ## 序号 -> PoliticalSystems 之外的文化类型（待证，暂空）
var culture_expansionism := []         ## 序号 -> 扩张倾向（包内 TraitProbabilities 均值代理，见下）
var state_culture := []                ## 国家序号 -> 文化序号
var state_religion := []               ## 国家序号 -> 宗教序号（-1 无）
var religion_names := []               ## 宗教序号 -> 显示名
var _rng := RandomNumberGenerator.new()

## 主入口：在 mapgen 生成国家之后调用。gen 需提供 is_land/W/H/states/provinces。
var _packs = null   ## 名字池缓存（领袖继承用；generate 后可用）

func generate(gen, seed_val: int) -> void:
	var packs = CulturePacks.new()
	packs.load_all()
	_packs = packs
	_rng.seed = seed_val * 7919 + 13      ## 独立随机流：不扰动主地图随机流/基线
	# ---- 1) 文化集合：取有 CultureData 的包（原版含通用名字包 WorldII，不作为文化实体）----
	culture_ids.clear()
	culture_display.clear()
	culture_expansionism.clear()
	for cid in packs.order:
		var e: Dictionary = packs.cultures[cid]
		if not bool(e.get("has_culture_data", false)):
			continue
		culture_ids.append(cid)
		culture_display.append(str(e.get("display_zh", cid)))
		# type/expansionism 在种子选址后统一按 ★A defineCultureType 推导（此处先占位 0）
		culture_type.append("Generic")
		culture_expansionism.append(1.0)
	var n := culture_ids.size()
	if n == 0:
		assignment.resize(gen.W * gen.H)
		assignment.fill(-1)
		return
	# ---- 2) 种子选址：陆地格均匀铺点（确定性；规则待 CultureGenerator$$Generate）----
	var W: int = gen.W
	var H: int = gen.H
	assignment.resize(W * H)
	assignment.fill(-1)
	var land_cells := []
	for i in W * H:
		if gen.is_land[i]:
			land_cells.append(i)
	var seeds := []
	if land_cells.size() > 0:
		var step := land_cells.size() / float(n)
		for k in n:
			var jitter := int(_rng.randf() * float(step) * 0.5)
			var idx := int(float(k) * step + float(step) * 0.5) + jitter
			idx = clampi(idx, 0, land_cells.size() - 1)
			seeds.append(land_cells[idx])
	# ---- 2b) 文化 type / expansionism（★A main.dec.js defineCultureType/defineCultureExpansionism）----
	#   type 由种子格地形推导；expansionism = ((rand*5)/2 + 1) × type 系数。
	#   简化项（标注）：Lake/River 分支需 haven/flux 数据（重建网格未建）→ 落 Generic/River 不可判时取 Generic。
	for k2 in seeds.size():
		var sc: int = seeds[k2]
		var ct := _define_culture_type(sc, gen)
		culture_type[k2] = ct
		var base := 1.0
		if ct == "Lake":
			base = 0.8
		elif ct == "Naval":
			base = 1.5
		elif ct == "River":
			base = 0.9
		elif ct == "Nomadic":
			base = 1.5
		elif ct == "Hunting":
			base = 0.7
		elif ct == "Highland":
			base = 1.2
		culture_expansionism[k2] = snappedf(((_rng.randf() * 5.0) / 2.0 + 1.0) * base, 0.1)

	# ---- 3) 多源扩张：同时 BFS，代价 = 1 + 高度惩罚/扩张倾向（扩张倾向高走得远）----
	#     机制族证据：ExpandStates/ExpandProvinces（已反编译，多源优先队列）；
	#     culture 特有代价待 CultureGenerator$$Expand。
	# 二叉最小堆（与 ExpandStates 的优先队列同义；13.4 万格需要 O(log n)）
	var dist := {}
	var heap := _BinHeap.new()
	for k in n:
		if k >= seeds.size():
			continue
		heap.push(seeds[k], 0.0, k)
		dist[seeds[k]] = 0.0
		assignment[seeds[k]] = k
	while heap.size() > 0:
		var cur: Dictionary = heap.pop_min()
		var ccell: int = cur["c"]
		var cd: float = cur["d"]
		var ck: int = cur["k"]
		if cd > float(dist.get(ccell, INF)) + 0.001:
			continue
		var budget: float = 1.0 + culture_expansionism[ck] * 0.35
		for nb in _neighbors(ccell, W, H):
			if not gen.is_land[nb]:
				continue
			var step_cost: float = 1.0 + float(gen.elevation[nb]) * 0.02
			var nd: float = cd + step_cost / budget
			if nd < float(dist.get(nb, INF)):
				dist[nb] = nd
				assignment[nb] = ck
				heap.push(nb, nd, ck)
	# ---- 3b) 孤岛回填（○ 中间实现，待 round12 CultureGenerator$$Expand 真值）----
	#     与文化种子陆地不连通的格子（海峡隔断的小岛）BFS 不可达；原版存档不变量
	#     「全部陆地格有文化归属」要求回填。二次多源 BFS：已归属格全部作种子，
	#     允许跨海（海格平代价 4×陆格），保证任何陆地格最终都有归属。
	var leftover := 0
	for i in W * H:
		if gen.is_land[i] and assignment[i] < 0:
			leftover += 1
	if leftover > 0:
		var dist2 := {}
		var heap2 := _BinHeap.new()
		for i in W * H:
			if assignment[i] >= 0:
				heap2.push(i, 0.0, assignment[i])
				dist2[i] = 0.0
		while heap2.size() > 0:
			var cur2: Dictionary = heap2.pop_min()
			var c2: int = cur2["c"]
			var d2: float = cur2["d"]
			var k2: int = cur2["k"]
			if d2 > float(dist2.get(c2, INF)) + 0.001:
				continue
			for nb2 in _neighbors(c2, W, H):
				var sc2: float = (1.0 + float(gen.elevation[nb2]) * 0.02) if gen.is_land[nb2] else 4.0
				var nd2: float = d2 + sc2
				if nd2 < float(dist2.get(nb2, INF)):
					dist2[nb2] = nd2
					if gen.is_land[nb2] and assignment[nb2] < 0:
						assignment[nb2] = k2
					heap2.push(nb2, nd2, k2)
	# ---- 4) 国家归属：首府所在格的文化（多数规则待证）----
	#     实测 schema：state.culture=文化序号、type/ethnicAttribute/expansionism 从文化拷贝。
	state_culture.clear()
	for si in gen.states.size():
		var st: Dictionary = gen.states[si]
		var cap: int = int(st.get("capital", -1))
		var cid := -1
		if cap >= 0:
			var prov: Dictionary = gen.provinces[cap]
			var cells: PackedInt32Array = prov.get("cells", PackedInt32Array())
			if cells.size() > 0:
				cid = assignment[cells[cells.size() / 2]]
		state_culture.append(cid)
	# ---- 5) 宗教：文化→宗教确定性映射（规则待 State$$DetermineStateReligion）----
	var rp = ReligionPacks.new()
	rp.load_all()
	religion_names.clear()
	var all_rel: Array = rp.all_religions()
	for r in all_rel:
		religion_names.append(str(r.get("name_zh", r.get("key", ""))))
	state_religion.clear()
	for si2 in gen.states.size():
		var cid2: int = state_culture[si2] if si2 < state_culture.size() else -1
		if cid2 >= 0 and all_rel.size() > 0:
			## 确定性：文化序号 → 宗教序号（不用主随机流）
			state_religion.append((cid2 * 7 + 3) % all_rel.size())
		else:
			state_religion.append(-1)

## 国家 culture 显示值（供 mapgen/simulation 落到 state 字典）
## V5.1：后建国家（孤岛建国等）超出初始数组时惰性补齐，取确定性派生的已有文化
func state_culture_display(si: int) -> String:
	while si >= state_culture.size():
		var base: int = state_culture.size()
		state_culture.append(state_culture[base % maxi(state_culture.size(), 1)] if state_culture.size() > 0 else -1)
	var cid: int = state_culture[si]
	if cid >= 0 and cid < culture_display.size():
		return culture_display[cid]
	return "—"

func state_religion_display(si: int) -> String:
	while si >= state_religion.size():
		var base: int = state_religion.size()
		state_religion.append(state_religion[base % maxi(state_religion.size(), 1)] if state_religion.size() > 0 else -1)
	var rid: int = state_religion[si]
	if rid >= 0 and rid < religion_names.size():
		return religion_names[rid]
	return "—"

## 文化类型推导（★A defineCultureType，简化标注：Lake/River 分支依赖 haven/flux 未建数据）
## biome 索引：1 湿漠 2 干漠 3 稀草 4 草原 5 热落 6 温落 7 北林 8 湿林 9 泰加 10 苔原 11 冰川 12 湿地
func _define_culture_type(seed_cell: int, gen) -> String:
	var W: int = gen.W
	var h100: float = float(gen.elevation[seed_cell]) * 100.0
	var biome: int = int(gen.biome[seed_cell])
	# 海岸判定：4 邻有海（原版 harbor>=1）
	var coast := false
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var nx: int = seed_cell % W + int(d.x)
		var ny: int = seed_cell / W + int(d.y)
		if nx < 0 or ny < 0 or nx >= W or ny >= gen.H:
			continue
		if int(gen.is_land[ny * W + nx]) == 0:
			coast = true
	if h100 < 70.0 and (biome == 1 or biome == 2 or biome == 4):
		return "Nomadic"
	if h100 > 50.0:
		return "Highland"
	if coast and _rng.randf() < 0.6:
		return "Naval"
	if biome == 3 or biome == 7 or biome == 8 or biome == 9 or biome == 10 or biome == 12:
		return "Hunting"
	return "Generic"

## 领袖名字池（原版文化包 CSV 逐字节：CharacterFirstNames_M/F + CharacterLastNames）
## si 国家无文化时回退任意有数据的包；返回 {male:[], female:[], last:[]}（可能为空数组）
func leader_name_pools(si: int) -> Dictionary:
	var out := {"male": [], "female": [], "last": []}
	if _packs == null:
		return out
	var cid: int = state_culture[si] if si < state_culture.size() else -1
	if cid >= 0 and cid < culture_ids.size():
		var e: Dictionary = _packs.cultures.get(str(culture_ids[cid]), {})
		for k in out:
			var arr: Array = e.get({"male": "male_names", "female": "female_names", "last": "last_names"}[k], [])
			if arr.size() > 0:
				out[k] = arr
	if (out["male"] as Array).is_empty():
		for cid2 in _packs.order:
			var e2: Dictionary = _packs.cultures.get(str(cid2), {})
			var m2: Array = e2.get("male_names", [])
			if m2.size() > 0:
				out["male"] = m2
				out["female"] = e2.get("female_names", [])
				out["last"] = e2.get("last_names", [])
				break
	return out

func _neighbors(i: int, W: int, H: int) -> Array:
	var out := []
	var x := i % W
	var y := i / W
	if x > 0: out.append(i - 1)
	if x < W - 1: out.append(i + 1)
	if y > 0: out.append(i - W)
	if y < H - 1: out.append(i + W)
	return out


## 最小二叉堆（键=距离，负载=cell+文化序号）
class _BinHeap:
	var keys := PackedFloat64Array()
	var cells := PackedInt32Array()
	var kinds := PackedInt32Array()

	func size() -> int:
		return keys.size()

	func push(c: int, d: float, k: int) -> void:
		keys.append(d)
		cells.append(c)
		kinds.append(k)
		var i := keys.size() - 1
		while i > 0:
			var p := (i - 1) / 2
			if keys[p] <= keys[i]:
				break
			_swap(i, p)
			i = p

	func pop_min() -> Dictionary:
		var top := {"c": cells[0], "d": keys[0], "k": kinds[0]}
		var last := keys.size() - 1
		keys[0] = keys[last]
		cells[0] = cells[last]
		kinds[0] = kinds[last]
		keys.resize(last)
		cells.resize(last)
		kinds.resize(last)
		var i := 0
		while true:
			var l := i * 2 + 1
			var r := i * 2 + 2
			var m := i
			if l < keys.size() and keys[l] < keys[m]:
				m = l
			if r < keys.size() and keys[r] < keys[m]:
				m = r
			if m == i:
				break
			_swap(i, m)
			i = m
		return top

	func _swap(a: int, b: int) -> void:
		var td := keys[a]
		keys[a] = keys[b]
		keys[b] = td
		var tc := cells[a]
		cells[a] = cells[b]
		cells[b] = tc
		var tk := kinds[a]
		kinds[a] = kinds[b]
		kinds[b] = tk
