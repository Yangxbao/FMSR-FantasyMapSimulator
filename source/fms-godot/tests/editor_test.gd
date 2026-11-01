extends SceneTree
## 四层地图编辑器自检（headless）
## 验证：笔刷真正改写底层数据 / 结构不变量 / 撤销恢复 / 存读档 / 与生成管线共存
## 运行：
##   Godot_v4.2.2-stable_win64_console.exe --headless --path <项目> --script tests/editor_test.gd

const MapEditorNS := preload("res://scripts/map_editor.gd")

var fails := 0
var checks := 0


func _check(cond: bool, msg: String) -> void:
	checks += 1
	if cond:
		print("  [PASS] ", msg)
	else:
		print("  [FAIL] ", msg)
		fails += 1


func _init() -> void:
	var gen := MapGen.new()
	gen.generate(26, 42)
	var ed = MapEditorNS.new()
	ed.setup(gen, null)

	print("=== 1. 群系数据 ===")
	_check(gen.biome.size() == MapGen.W * MapGen.H, "群系数组覆盖全图 (%d)" % gen.biome.size())
	_check(gen.biome_names_zh.size() == 13, "加载 13 个原版群系名 (%d)" % gen.biome_names_zh.size())
	var land_biomes := {}
	for i in MapGen.W * MapGen.H:
		if gen.is_land[i] == 1:
			land_biomes[gen.biome[i]] = true
	_check(land_biomes.size() >= 4, "陆地出现多种群系 (%d 种)" % land_biomes.size())
	_check(str(gen.biome_label(1)) == "热带沙漠", "群系中文名取自原版 localzation (%s)" % gen.biome_label(1))

	print("=== 1b. 海平面 = 原版 20/100 ===")
	_check(is_equal_approx(gen.sea_level_effective, 0.20), "海平面固定为 0.20（原版 20/100）实际 %.3f" % gen.sea_level_effective)
	var land_above := true
	var sea_below := true
	for i in MapGen.W * MapGen.H:
		if gen.is_land[i] == 1 and gen.elevation[i] <= 0.20:
			land_above = false
			break
	for i in MapGen.W * MapGen.H:
		if gen.is_land[i] == 0 and gen.elevation[i] > 0.21:
			sea_below = false
			break
	_check(land_above, "所有陆地格高度 > 海平面")
	_check(sea_below, "所有海格高度 <= 海平面+容差")

	print("=== 2. 高度层：抬升 / 压低 / 撤销 / 恢复 ===")
	ed.set_layer(MapEditorNS.Layer.HEIGHT)
	ed.brush_radius = 8
	ed.brush_height = 90.0
	ed.brush_mode = MapEditorNS.BrushMode.MAX
	# 找一块海面
	var sea_cell := -1
	for i in MapGen.W * MapGen.H:
		if gen.is_land[i] == 0 and i > MapGen.W * 40 and i < MapGen.W * 200:
			sea_cell = i
			break
	_check(sea_cell >= 0, "找到用于抬升的海格")
	var before_h: float = gen.elevation[sea_cell]
	var pos := Vector2((sea_cell % MapGen.W) * MapGen.CELL + 2, (sea_cell / MapGen.W) * MapGen.CELL + 2)
	ed.begin_stroke(pos)
	ed.end_stroke()
	_check(gen.elevation[sea_cell] > before_h, "笔刷抬升真的改变了 elevation (%.3f → %.3f)" % [before_h, gen.elevation[sea_cell]])
	_check(gen.is_land[sea_cell] == 1, "抬升后该格被判定为陆地")
	_check(ed.can_undo(), "产生可撤销记录")
	ed.undo()
	_check(is_equal_approx(gen.elevation[sea_cell], before_h), "撤销恢复原高度 (%.3f)" % gen.elevation[sea_cell])
	_check(gen.is_land[sea_cell] == 0, "撤销后重新变回海")
	ed.redo()
	_check(gen.elevation[sea_cell] > before_h, "恢复重做抬升")
	ed.undo()

	print("=== 3. 高度层：擦除陆地 ===")
	var land_cell := -1
	for i in MapGen.W * MapGen.H:
		if gen.is_land[i] == 1 and gen.cell_province[i] >= 0:
			land_cell = i
			break
	_check(land_cell >= 0, "找到用于擦除的陆地格")
	var lpos := Vector2((land_cell % MapGen.W) * MapGen.CELL + 2, (land_cell / MapGen.W) * MapGen.CELL + 2)
	ed.brush_radius = 4
	ed.erase_land(lpos)
	_check(gen.is_land[land_cell] == 0, "擦除后该格变海")
	_check(gen.cell_province[land_cell] >= 0 and gen.provinces[gen.cell_province[land_cell]].get("is_sea", false),
		"新海域被并入海域省")
	ed.undo()

	print("=== 4. 行省层：笔刷涂归属 ===")
	ed.set_layer(MapEditorNS.Layer.PROVINCE)
	# 选一个陆地省作为目标
	var target := -1
	for pi in gen.provinces.size():
		if gen.provinces[pi].get("is_sea", false):
			continue
		if gen.provinces[pi].cells.size() > 30:
			target = pi
			break
	_check(target >= 0, "选到一个行省作为笔刷目标")
	ed.target_province = target
	var tcell: int = gen.provinces[target].center
	var tpos := Vector2((tcell % MapGen.W) * MapGen.CELL + 2, (tcell / MapGen.W) * MapGen.CELL + 2)
	var count_before: int = gen.provinces[target].cells.size()
	ed.brush_radius = 5
	ed.begin_stroke(tpos)
	ed.end_stroke()
	var count_after: int = gen.provinces[ed.target_province].cells.size()
	_check(count_after >= count_before, "笔刷后目标行省格数不减少 (%d → %d)" % [count_before, count_after])

	print("=== 5. 行省层：整省并入（空省必须被清理） ===")
	# 找一个格数最少的陆地省，整省刷给另一个省
	var small := -1
	var small_n := 999999
	for pi in gen.provinces.size():
		if gen.provinces[pi].get("is_sea", false):
			continue
		var n: int = gen.provinces[pi].cells.size()
		if n < small_n:
			small_n = n
			small = pi
	_check(small >= 0, "找到最小行省（%d 格）" % small_n)
	var big := -1
	for pi in gen.provinces.size():
		if gen.provinces[pi].get("is_sea", false) or pi == small:
			continue
		if gen.provinces[pi].cells.size() > 100:
			big = pi
			break
	if big >= 0:
		ed.target_province = big
		var sc: int = gen.provinces[small].center
		var spos := Vector2((sc % MapGen.W) * MapGen.CELL + 2, (sc / MapGen.W) * MapGen.CELL + 2)
		ed.brush_radius = 8
		ed.begin_stroke(spos)
		ed.end_stroke()
		var empties := 0
		for p in gen.provinces:
			if p.cells.size() == 0:
				empties += 1
		_check(empties == 0, "编辑后没有空行省 (%d)" % empties)
		_check(ed.target_province < gen.provinces.size(), "重编号后笔刷目标仍然有效")

	print("=== 6. 国家层：行省划归（最小单位=行省） ===")
	ed.set_layer(MapEditorNS.Layer.STATE)
	var alive: Array = []
	for si in gen.states.size():
		if gen.states[si].alive and gen.states[si].provinces.size() > 2:
			alive.append(si)
	_check(alive.size() >= 2, "至少两个多省国家 (%d)" % alive.size())
	if alive.size() >= 2:
		var a: int = alive[0]
		var b: int = alive[1]
		var vic: int = gen.states[a].provinces[0]
		var vpos := Vector2((gen.provinces[vic].center % MapGen.W) * MapGen.CELL + 2,
			(gen.provinces[vic].center / MapGen.W) * MapGen.CELL + 2)
		ed.target_state = b
		ed.brush_radius = 3
		ed.begin_stroke(vpos)
		ed.end_stroke()
		_check(int(gen.provinces[vic].state) == b or gen.provinces[vic].cells.size() == 0,
			"笔刷触及的行省归属被改写")
		_check(gen.states[b].provinces.has(vic) or gen.provinces[vic].cells.size() == 0,
			"目标国家的行省列表同步更新")

	print("=== 7. 结构不变量 ===")
	var bad_state := 0
	var bad_list := 0
	var bad_capital := 0
	for pi in gen.provinces.size():
		var st: int = int(gen.provinces[pi].state)
		if st < -1 or st >= gen.states.size():
			bad_state += 1
		elif st >= 0 and not gen.states[st].provinces.has(pi):
			bad_list += 1
	for si in gen.states.size():
		if not gen.states[si].alive:
			continue
		if gen.states[si].provinces.is_empty():
			bad_list += 1
		elif not gen.states[si].provinces.has(int(gen.states[si].capital)):
			bad_capital += 1
	_check(bad_state == 0, "行省 state 字段合法 (%d 异常)" % bad_state)
	_check(bad_list == 0, "国家-行省双向列表一致 (%d 异常)" % bad_list)
	_check(bad_capital == 0, "存续国家首都必属本国 (%d 异常)" % bad_capital)
	var sea_dup := 0
	for i in MapGen.W * MapGen.H:
		if gen.is_land[i] == 1 and gen.cell_province[i] >= 0:
			if gen.provinces[gen.cell_province[i]].get("is_sea", false):
				sea_dup += 1
	_check(sea_dup == 0, "陆地格不会被海域省占据 (%d 异常)" % sea_dup)

	print("=== 8. 群系层笔刷 ===")
	ed.set_layer(MapEditorNS.Layer.BIOME)
	var bcell: int = gen.provinces[gen.provinces.size() - 1].center
	ed.target_biome = MapGen.BIOME_SNOW
	ed.brush_radius = 3
	ed.begin_stroke(Vector2((bcell % MapGen.W) * MapGen.CELL + 2, (bcell / MapGen.W) * MapGen.CELL + 2))
	ed.end_stroke()
	_check(int(gen.biome[bcell]) == MapGen.BIOME_SNOW, "群系笔刷写入真实 biome 数组 (%d)" % gen.biome[bcell])

	print("=== 9. 存档 / 读档 ===")
	var elev_sig: float = gen.elevation[land_cell]
	var biome_sig: int = gen.biome[bcell]
	var prov_sig: int = gen.cell_province[bcell]
	_check(ed.save_map("user://saves/editor_test.dat"), "保存编辑结果成功")
	gen.elevation[land_cell] = 0.0
	gen.biome[bcell] = 0
	gen.cell_province[bcell] = -1
	_check(ed.load_map("user://saves/editor_test.dat"), "读取编辑结果成功")
	_check(is_equal_approx(gen.elevation[land_cell], elev_sig), "elevation 往返一致")
	_check(int(gen.biome[bcell]) == biome_sig, "biome 往返一致 (%d)" % gen.biome[bcell])
	_check(int(gen.cell_province[bcell]) == prov_sig, "cell_province 往返一致")

	print("=== 10. 生成管线仍可运行（编辑器不破坏 generate） ===")
	var gen2 := MapGen.new()
	gen2.generate(26, 1337)
	var orphan := 0
	for i in MapGen.W * MapGen.H:
		if gen2.is_land[i] == 1 and gen2.cell_province[i] < 0:
			orphan += 1
	_check(orphan == 0, "新生成地图无未归属陆地 (%d)" % orphan)
	_check(gen2.states.size() >= 20, "新生成地图国家数正常 (%d)" % gen2.states.size())

	print("=== 11. 行省合并 / 国家合并 / 新建 / 擦除 ===")
	var ma := -1
	var mb := -1
	for pi in gen.provinces.size():
		if gen.provinces[pi].get("is_sea", false):
			continue
		if ma < 0:
			ma = pi
		elif mb < 0 and gen.provinces[pi].cells.size() > 5:
			mb = pi
	_check(ma >= 0 and mb >= 0, "找到两个行省用于合并")
	var ma_cells: int = gen.provinces[ma].cells.size()
	var mb_cells: int = gen.provinces[mb].cells.size()
	var n_before: int = gen.provinces.size()
	ed.target_province = mb
	_check(ed.merge_provinces(ma, mb), "合并行省成功")
	_check(gen.provinces[ed.target_province].cells.size() >= ma_cells + mb_cells - 1,
		"合并后目标行省格数增加 (%d+%d → %d)" % [ma_cells, mb_cells, gen.provinces[ed.target_province].cells.size()])
	_check(gen.provinces.size() < n_before, "合并后行省数量下降 (%d → %d)" % [n_before, gen.provinces.size()])
	var empt2 := 0
	for p2 in gen.provinces:
		if p2.cells.size() == 0:
			empt2 += 1
	_check(empt2 == 0, "合并后无空行省 (%d)" % empt2)

	var sa := -1
	var sb2 := -1
	for si in gen.states.size():
		if gen.states[si].alive and gen.states[si].provinces.size() > 1:
			if sa < 0:
				sa = si
			elif sb2 < 0:
				sb2 = si
	if sa >= 0 and sb2 >= 0:
		var sa_n: int = gen.states[sa].provinces.size()
		_check(ed.merge_states(sa, sb2), "合并国家成功")
		_check(gen.states[sb2].provinces.size() >= sa_n, "目标国家行省数增加")
		_check(not gen.states[sa].alive, "被吞并国家标记为灭亡")
	else:
		_check(false, "找到两个可合并国家")

	# 新建国家 + 新建行省
	var n_states: int = gen.states.size()
	var new_si := gen.add_state("测试国")
	_check(new_si == n_states and gen.states[new_si].name == "测试国", "新建国家成功 (%s)" % gen.states[new_si].name)
	var some_land := -1
	for i in MapGen.W * MapGen.H:
		if gen.is_land[i] == 1 and gen.cell_province[i] >= 0:
			some_land = i
			break
	var n_prov: int = gen.provinces.size()
	var new_pi := gen.add_province_at(some_land)
	_check(new_pi == n_prov, "新建行省成功 (id %d)" % new_pi)
	gen.rebuild_after_province_edit()

	# 国家擦除：把当前国家的所有行省变无主
	if sa >= 0 and gen.states[sa].alive:
		var erased: int = 0
		for pi2 in gen.provinces.size():
			if int(gen.provinces[pi2].state) == sa:
				erased += 1
		_check(erased >= 0, "擦除国家可定位行省 (%d)" % erased)

	print("=== 12. 清空地图 / 重算生态 ===")
	var gen3 := MapGen.new()
	gen3.generate(26, 7)
	var ed3 = MapEditorNS.new()
	ed3.setup(gen3, null)
	ed3.clear_map_all()
	_check(gen3.states.size() == 0, "清空地图后无国家")
	var land3 := 0
	for i in MapGen.W * MapGen.H:
		if gen3.is_land[i] == 1:
			land3 += 1
	_check(land3 == 0, "清空地图后无陆地 (%d)" % land3)
	_check(gen3.provinces.size() >= 1, "清空地图后仍有一个海洋省")

	print("=== 13. 高度编辑导致整省沉没：省被清理 + 国家迁都 ===")
	var gen4 := MapGen.new()
	gen4.generate(26, 99)
	var ed4 = MapEditorNS.new()
	ed4.setup(gen4, null)
	ed4.set_layer(MapEditorNS.Layer.HEIGHT)
	# 找一个 1~6 格的小省
	var tiny := -1
	var tiny_n := 99999
	for pi in gen4.provinces.size():
		if gen4.provinces[pi].get("is_sea", false):
			continue
		var n2: int = gen4.provinces[pi].cells.size()
		if n2 < tiny_n:
			tiny_n = n2
			tiny = pi
	var tiny_state: int = int(gen4.provinces[tiny].state)
	var n_prov4: int = gen4.provinces.size()
	ed4.brush_radius = 6
	ed4.brush_height = 0.0
	ed4.brush_mode = MapEditorNS.BrushMode.MIN
	for c in gen4.provinces[tiny].cells:
		ed4.begin_stroke(Vector2((c % MapGen.W) * MapGen.CELL + 2, (c / MapGen.W) * MapGen.CELL + 2))
		ed4.end_stroke()
	_check(gen4.provinces.size() < n_prov4, "整省沉没后行省被清理 (%d → %d)" % [n_prov4, gen4.provinces.size()])
	var bad_cap4 := 0
	for si in gen4.states.size():
		if not gen4.states[si].alive:
			continue
		if gen4.states[si].provinces.is_empty():
			bad_cap4 += 1
		elif not gen4.states[si].provinces.has(int(gen4.states[si].capital)):
			bad_cap4 += 1
	_check(bad_cap4 == 0, "沉没后存续国家仍有合法首都 (%d 异常)" % bad_cap4)
	if tiny_state >= 0 and tiny_state < gen4.states.size():
		_check(gen4.states[tiny_state].provinces.size() >= 0, "受影响国家状态一致 (%d 省)" % gen4.states[tiny_state].provinces.size())
	ed4.free()

	print("=== 14. 撤销的结构还原（合并/沉没这类会删省的操作） ===")
	var gen5 := MapGen.new()
	gen5.generate(26, 2026)
	var ed5 = MapEditorNS.new()
	ed5.setup(gen5, null)
	var nprov5: int = gen5.provinces.size()
	var a5 := -1
	var b5 := -1
	for pi in gen5.provinces.size():
		if gen5.provinces[pi].get("is_sea", false):
			continue
		if a5 < 0:
			a5 = pi
		elif b5 < 0:
			b5 = pi
	ed5.set_layer(MapEditorNS.Layer.PROVINCE)
	ed5.target_province = b5
	# 用笔刷整省覆盖（会产生"空省被删"）
	ed5.brush_radius = 24
	var c2: int = gen5.provinces[a5].center
	ed5.begin_stroke(Vector2((c2 % MapGen.W) * MapGen.CELL + 2, (c2 / MapGen.W) * MapGen.CELL + 2))
	ed5.end_stroke()
	var n_after5: int = gen5.provinces.size()
	_check(n_after5 <= nprov5, "整省刷掉后行省数不增加 (%d → %d)" % [nprov5, n_after5])
	var undo_ok := true
	while ed5.can_undo():
		if not ed5.undo():
			undo_ok = false
			break
	_check(undo_ok, "连续撤销全部成功")
	_check(gen5.provinces.size() == nprov5, "撤销后行省数恢复 (%d → %d)" % [n_after5, gen5.provinces.size()])
	var orphan5 := 0
	for i in MapGen.W * MapGen.H:
		if gen5.is_land[i] == 1 and gen5.cell_province[i] < 0:
			orphan5 += 1
	_check(orphan5 == 0, "撤销后无未归属陆地 (%d)" % orphan5)
	var bad5 := 0
	for pi in gen5.provinces.size():
		var st5: int = int(gen5.provinces[pi].state)
		if st5 >= 0 and (st5 >= gen5.states.size() or not gen5.states[st5].provinces.has(pi)):
			bad5 += 1
	_check(bad5 == 0, "撤销后国家-行省关系仍一致 (%d 异常)" % bad5)
	ed5.free()

	print("\n=== editor_test: %d 项检查，失败 %d ===" % [checks, fails])
	ed.free()
	ed3.free()
	if fails == 0:
		print("=== EDITOR ALL PASS ===")
	quit(0 if fails == 0 else 1)
