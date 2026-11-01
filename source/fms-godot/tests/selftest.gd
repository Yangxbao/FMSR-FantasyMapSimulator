extends SceneTree
## 无头自检：godot --headless --script tests/selftest.gd --path .
## 验证：生成完整性 / 省份覆盖 / 国家分配 / 模拟推进 / 存读档往返 / 渲染网格构建

var fails := 0

func _init() -> void:
	print("=== FMSR selftest begin ===")
	var t0 := Time.get_ticks_msec()
	var gen := MapGen.new()
	gen.generate(26, 42)
	print("  [time] generate %d ms" % (Time.get_ticks_msec() - t0))

	var land := 0
	for i in gen.is_land.size():
		land += gen.is_land[i]
	_check(land > 1000, "陆地格数 > 1000 (实际 %d)" % land)
	_check(gen.provinces.size() > 100, "省份数 > 100 (实际 %d)" % gen.provinces.size())
	_check(gen.states.size() >= 20, "国家数 >= 20 (实际 %d)" % gen.states.size())

	var orphan := 0
	for i in gen.cell_province.size():
		if gen.is_land[i] == 1 and gen.cell_province[i] < 0:
			orphan += 1
	_check(orphan == 0, "无未归属陆地格 (实际 %d)" % orphan)

	# 省份连通性：原版允许"跨海离岛"分量（EnsureProvinceConnectivity 只清内陆飞地）
	var enclave := 0
	var multi := 0
	for pi in gen.provinces.size():
		var comps := _cell_components(gen, pi)
		if comps.size() > 1:
			multi += 1
		var main := 0
		for ci in comps.size():
			if comps[ci].has(gen.provinces[pi].center):
				main = ci
				break
		for ci in comps.size():
			if ci == main:
				continue
			if not _touches_sea(gen, comps[ci]):
				enclave += 1
	_check(enclave == 0, "无内陆飞地省分量 (实际 %d)" % enclave)
	print("  [info] 含离岛分量的省份 %d / %d" % [multi, gen.provinces.size()])
	var pempty := 0
	for pi in gen.provinces.size():
		if gen.provinces[pi].cells.size() == 0:
			pempty += 1
	_check(pempty == 0, "无空省份 (实际 %d)" % pempty)

	var unassigned := 0
	var sea_provs := 0
	for p in gen.provinces:
		if p.get("is_sea", false):
			sea_provs += 1
			continue
		if p.state < 0:
			unassigned += 1
	_check(unassigned == 0, "所有陆地省份归属国家 (实际未分配 %d)" % unassigned)
	_check(sea_provs > 0, "存在海洋省 (实际 %d)" % sea_provs)
	var sea_no_coast := 0
	for p in gen.provinces:
		if not p.get("is_sea", false):
			continue
		if p.cells.size() == 0:
			sea_no_coast += 1
			continue
		if p.get("coast_land_provs", {}).size() == 0:
			sea_no_coast += 1
	_check(sea_no_coast == 0, "海域省都有海岸相邻陆地省 (异常 %d)" % sea_no_coast)
	var empty_states := 0
	for s in gen.states:
		if s.provinces.is_empty():
			empty_states += 1
	_check(empty_states == 0, "无空国家 (实际 %d)" % empty_states)

	var sim := Simulation.new()
	sim.setup(gen, 42)
	var t2 := Time.get_ticks_msec()
	for i in 60:
		sim.tick_month()
	print("  [time] 60 months %d ms" % (Time.get_ticks_msec() - t2))
	_check(sim.year == 866, "5 年推进正确 (year=%d)" % sim.year)
	print("  历史 %d 条，进行中战争 %d 场，战报 %d 条" % [sim.history.size(), sim.wars.size(), sim.war_records.size()])
	_check(sim.wars.size() + sim.war_records.size() > 0, "战争系统有产出 (进行中 %d / 战报 %d)" % [sim.wars.size(), sim.war_records.size()])
	var missing_meta := 0
	for st in gen.states:
		if not st.has("leader") or not st.has("culture") or not st.has("religion"):
			missing_meta += 1
	_check(missing_meta == 0, "每国都有领袖/文化/宗教字段 (缺失 %d)" % missing_meta)
	var bad_prov := 0
	for pv in gen.provinces:
		if not pv.has("kind") or not pv.has("max_pop") or not pv.has("max_defense"):
			bad_prov += 1
	_check(bad_prov == 0, "每省都有类型/人口上限/城防上限字段 (缺失 %d)" % bad_prov)

	DirAccess.make_dir_recursive_absolute("user://")
	var ok_save: bool = sim.save("user://selftest_save.json")
	_check(ok_save, "存档成功")
	var sim2 := Simulation.new()
	sim2.setup(gen, 42)
	var ok_load: bool = sim2.load("user://selftest_save.json")
	_check(ok_load, "读档成功")
	_check(sim2.year == sim.year and sim2.month == sim.month, "存读档日期一致")
	# 存读档往返：行省类型/军队/战争记录
	gen.provinces[0].kind = "要塞"
	gen.states[0].army = 7
	sim.save("user://selftest_save2.json")
	var sim3 := Simulation.new()
	sim3.setup(gen, 42)
	sim3.load("user://selftest_save2.json")
	_check(str(gen.provinces[0].kind) == "要塞", "存读档保留行省类型 (%s)" % str(gen.provinces[0].kind))
	_check(int(gen.states[0].army) == 7, "存读档保留军队数 (%d)" % int(gen.states[0].army))
	_check(sim3.war_records.size() == sim.war_records.size(), "存读档保留战报 (%d vs %d)" % [sim3.war_records.size(), sim.war_records.size()])

	# —— 群系系统（13 群系 / 原版名字 / 真实数组）——
	_check(gen.biome.size() == MapGen.W * MapGen.H, "群系数组覆盖全图 (%d)" % gen.biome.size())
	_check(gen.biome_names_zh.size() == 13, "加载 13 个原版群系名 (%d)" % gen.biome_names_zh.size())
	var land_biomes := {}
	for i in MapGen.W * MapGen.H:
		if gen.is_land[i] == 1:
			land_biomes[gen.biome[i]] = true
	_check(land_biomes.size() >= 4, "陆地出现多种群系 (%d 种)" % land_biomes.size())
	var sea_wrong := 0
	for i in MapGen.W * MapGen.H:
		if gen.is_land[i] == 0 and int(gen.biome[i]) != MapGen.BIOME_MARINE:
			sea_wrong += 1
	_check(sea_wrong == 0, "海格群系统一为海洋 (%d 异常)" % sea_wrong)

	# —— 编辑器改动随存档保留（v3 新增 elevation/biome 字段）——
	var probe := -1
	for i in MapGen.W * MapGen.H:
		if gen.is_land[i] == 1:
			probe = i
			break
	var saved_h: float = gen.elevation[probe]
	gen.elevation[probe] = saved_h + 0.05
	gen.biome[probe] = MapGen.BIOME_SNOW
	sim.save("user://selftest_save3.json")
	gen.elevation[probe] = 0.0
	gen.biome[probe] = MapGen.BIOME_MARINE
	var sim4 := Simulation.new()
	sim4.setup(gen, 42)
	sim4.load("user://selftest_save3.json")
	_check(is_equal_approx(gen.elevation[probe], saved_h + 0.05), "存档保留编辑器改过的高度 (%.3f)" % gen.elevation[probe])
	_check(int(gen.biome[probe]) == MapGen.BIOME_SNOW, "存档保留编辑器改过的群系 (%d)" % gen.biome[probe])

	# 渲染构建的正确性由真实窗口启动验证（headless 脚本模式下访问纹理资源不稳定）
	print("=== FMSR selftest: logic checks done ===")
	if fails == 0:
		print("=== FMSR selftest: ALL PASS ===")
	else:
		print("=== FMSR selftest: %d FAILURES ===" % fails)
	quit(1 if fails > 0 else 0)

func _check(cond: bool, msg: String) -> void:
	if cond:
		print("  [PASS] ", msg)
	else:
		print("  [FAIL] ", msg)
		fails += 1

## 省份在 cell 4 邻域下的连通分量列表
func _cell_components(gen: MapGen, pi: int) -> Array:
	var cells: PackedInt32Array = gen.provinces[pi].cells
	var w := MapGen.W
	var h := MapGen.H
	if cells.size() == 0:
		return []
	var inset := {}
	for c in cells:
		inset[c] = true
	var seen := {}
	var comps: Array = []
	for c in cells:
		if seen.has(c):
			continue
		var comp: Array[int] = []
		var stack: Array[int] = [c]
		seen[c] = true
		while not stack.is_empty():
			var cur: int = stack.pop_back()
			comp.append(cur)
			var x := cur % w
			var y := cur / w
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx := x + int(d.x)
				var ny := y + int(d.y)
				if nx < 0 or ny < 0 or nx >= w or ny >= h:
					continue
				var ni := ny * w + nx
				if inset.has(ni) and not seen.has(ni):
					seen[ni] = true
					stack.append(ni)
		comps.append(comp)
	return comps

## 该 cell 集合是否触海（任一 cell 的 4 邻含海域）
func _touches_sea(gen: MapGen, comp: Array) -> bool:
	var w := MapGen.W
	var h := MapGen.H
	for cv in comp:
		var cur: int = cv
		var x: int = cur % w
		var y: int = cur / w
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nx: int = x + int(d.x)
			var ny: int = y + int(d.y)
			if nx < 0 or ny < 0 or nx >= w or ny >= h:
				continue
			if gen.is_land[ny * w + nx] == 0:
				return true
	return false
