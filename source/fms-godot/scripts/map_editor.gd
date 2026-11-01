class_name MapEditor
extends Node
## 四层地图编辑器（高度 / 群系 / 行省 / 国家）—— 对齐原版 EditPanelUI + BrushManager
##
## 证据（原版元数据 dump-assembly-csharp.txt + 官方文案 localization.csv）：
##   EditPanelUI 成员：EditHeightPanel / EditBiomPanel / EditProvincePanel / EditStatePanel /
##     GlobalCommandsPanel / MapSizePanel / EditModeDropdown
##   高度层：BrushHeightSlider、DecayFactor、HeightBrushRadiusSlider、EditHeightButton、
##     EraseContinentButton、PlaceContinentButton、OnGenHeightMapButtonClicked、WorldGenerateHeightMap
##   行省层：DrawProvinceButton、PlaceProvinceButton、ProvinceBrushRadiusSlider、currentDrawProvinceID、
##     AverageProvinceCellCountSlider、OnAddProvinceButtonClicked
##   国家层：DrawStateButton、EraseStateButton、StateBrushRadiusSlider、currentDrawStateID、
##     PlaceStateInSeaToggle、StateCountSlider
##   群系层：currentDrawBiomID、biomBrushSizeSlider、TemperatureModifier、PrecipitationFactor、
##     WorldRegenerateBiom
##   笔刷：BrushManager.GetCurrentBrushRadius / DrawShapes / GetColorFromHeight；
##     笔刷模式文案 BrushModeAdd(增加) / BrushModeSubtract(减少) / BrushModeMax(最大值) /
##     BrushModeMin(最小值) / BrushModeAverage(平均值)
##   操作提示（官方文案）：DrawingProvinceTips = "当前正在绘制 {0} 行省，shift + 左键选择其他行省，
##     alt + 左键单击更改行省首府位置"
##
## ⚠️ 未反编译部分：BrushManager.DrawShapes 的**混合算符**与 HeightMapGenerator 的落笔细节
##   已排队反编译（logs/dec5_BrushManager__DrawShapes.json）。当前混合公式为显式近似。

signal data_changed
signal status_changed(text: String)

enum Layer { NONE, HEIGHT, BIOME, PROVINCE, STATE }
enum BrushMode { ADD, SUBTRACT, MAX, MIN, AVERAGE }

const BRUSH_MODE_NAMES := ["增加", "减少", "最大值", "最小值", "平均值"]
const HEIGHT_SCALE := 100.0        # 原版高度是 0..100（官方文案：大陆高度 > 70 视为险要）
const MAX_UNDO := 40
const CELL := 4.0

var gen: MapGen
var render: MapRender

var active := false
var layer := Layer.NONE
var brush_radius := 6              # 单位：cell
var brush_height := 55.0           # 原版 BrushHeight（0..100）
var decay := 0.35                  # 原版 DecayFactor
var brush_mode := BrushMode.ADD
var target_province := -1
var target_state := -1
var target_biome := 0   # MapGen.BIOME_MARINE
var merge_province_src := -1   # Shift+左键选中的"待并入"行省
var merge_state_src := -1      # Shift+左键选中的"待并入"国家
var paint_erase := false       # 原版「擦除」按钮：笔刷改为清除
var temperature_modifier := 0.0    # 原版 TemperatureModifier（群系重算用）
var precipitation_factor := 1.0    # 原版 PrecipitationFactor（群系重算用）

var undo_stack: Array = []
var redo_stack: Array = []

var _stroke_cells := {}
var _stroke_layer := Layer.NONE
var _painting := false


func setup(g: MapGen, r: MapRender) -> void:
	gen = g
	render = r


func set_layer(l: int) -> void:
	layer = l
	active = l != Layer.NONE
	undo_stack.clear()
	redo_stack.clear()
	status_changed.emit(layer_name())


func layer_name() -> String:
	match layer:
		Layer.HEIGHT: return "编辑高度"
		Layer.BIOME: return "植被图"
		Layer.PROVINCE: return "行省图"
		Layer.STATE: return "国家图"
	return "关闭"


func brush_mode_name() -> String:
	return BRUSH_MODE_NAMES[brush_mode]


# ---------------------------------------------------------------- 输入入口
func begin_stroke(world_pos: Vector2) -> void:
	if not active or gen == null:
		return
	_painting = true
	_stroke_layer = layer
	_stroke_cells = {}
	_before = _snapshot(layer)
	_struct_before = _snapshot_struct() if layer != Layer.BIOME else {}
	_apply_at(world_pos)


func move_stroke(world_pos: Vector2) -> void:
	if _painting:
		_apply_at(world_pos)


func end_stroke() -> void:
	if not _painting:
		return
	_painting = false
	_commit_stroke()


func cell_at(world_pos: Vector2) -> int:
	return gen.cell_index_at(world_pos)


# ---------------------------------------------------------------- 笔刷核心
func _brush_cells(world_pos: Vector2) -> Array:
	var cx := int(world_pos.x / CELL)
	var cy := int(world_pos.y / CELL)
	var r := maxi(1, brush_radius)
	var out: Array = []
	for y in range(maxi(0, cy - r), mini(MapGen.H - 1, cy + r) + 1):
		for x in range(maxi(0, cx - r), mini(MapGen.W - 1, cx + r) + 1):
			var d := Vector2(float(x - cx), float(y - cy)).length()
			if d > float(r):
				continue
			var t := d / float(r)
			var w := 1.0 - t * t
			out.append({"i": y * MapGen.W + x, "w": w})
	return out


func _apply_at(world_pos: Vector2) -> void:
	match layer:
		Layer.HEIGHT: _paint_height(world_pos)
		Layer.BIOME: _paint_biome(world_pos)
		Layer.PROVINCE: _paint_province(world_pos)
		Layer.STATE: _paint_state(world_pos)


func _paint_height(world_pos: Vector2) -> void:
	var bm := brush_mode
	if paint_erase:
		bm = BrushMode.MIN
	var v := clampf(brush_height / HEIGHT_SCALE, 0.0, 1.0)
	if paint_erase:
		v = 0.0
	for c in _brush_cells(world_pos):
		var i: int = c.i
		if _stroke_cells.has(i):
			continue
		_stroke_cells[i] = true
		var e: float = gen.elevation[i]
		var w: float = c.w
		match bm:
			BrushMode.ADD:
				e = minf(1.0, e + v * w * 0.20)
			BrushMode.SUBTRACT:
				e = maxf(0.0, e - v * w * 0.20)
			BrushMode.MAX:
				e = maxf(e, v * w)
			BrushMode.MIN:
				# 最小值：把高于笔刷高度的部分削平（中心削到笔刷高度，边缘按衰减保留）
				e = minf(e, v + (1.0 - w))
			BrushMode.AVERAGE:
				e = lerpf(e, v, w)
		gen.elevation[i] = e


func _paint_biome(world_pos: Vector2) -> void:
	for c in _brush_cells(world_pos):
		var i: int = c.i
		if _stroke_cells.has(i):
			continue
		_stroke_cells[i] = true
		gen.set_biome(i, MapGen.BIOME_MARINE if paint_erase else target_biome)


func _paint_province(world_pos: Vector2) -> void:
	if target_province < 0 or target_province >= gen.provinces.size():
		return
	for c in _brush_cells(world_pos):
		var i: int = c.i
		if gen.is_land[i] == 0:
			continue  # 行省只存在于陆地
		if _stroke_cells.has(i):
			continue
		_stroke_cells[i] = true
		gen.cell_province[i] = -1 if paint_erase else target_province


func _paint_state(world_pos: Vector2) -> void:
	# target_state == -1 表示"擦除国家"（原版 EraseStateButton）：行省变无主
	if target_state >= gen.states.size():
		return
	# 国家的最小单位是行省（原版 TerrainStateEditBrush）：笔刷触及的行省整体划归
	var touched := {}
	for c in _brush_cells(world_pos):
		var i: int = c.i
		var pi: int = gen.cell_province[i]
		if pi >= 0 and not gen.provinces[pi].get("is_sea", false):
			touched[pi] = true
	for pi in touched:
		if _stroke_cells.has(pi):
			continue
		_stroke_cells[pi] = true
		gen.provinces[pi].state = -1 if paint_erase else target_state


# ---------------------------------------------------------------- 快照 / 提交
## 结构型图层（高度/行省/国家）会改动 provinces/states 数组本身（可能删省、迁都、灭国），
## 只回放 cell 级 delta 无法还原，因此每笔额外保存 provinces/states 的深拷贝。
var _before: Variant = null
var _struct_before: Dictionary = {}

func _snapshot(l: int) -> Variant:
	match l:
		Layer.HEIGHT: return gen.elevation.duplicate()
		Layer.BIOME: return gen.biome.duplicate()
		Layer.PROVINCE: return gen.cell_province.duplicate()
		Layer.STATE:
			var arr := PackedInt32Array()
			arr.resize(gen.provinces.size())
			for i in gen.provinces.size():
				arr[i] = int(gen.provinces[i].state)
			return arr
	return null


func _snapshot_struct() -> Dictionary:
	# cell_province / is_land 也会被高度编辑的后处理改写（沉没→并入海域省），必须一起快照
	return {
		"provinces": gen.provinces.duplicate(true),
		"states": gen.states.duplicate(true),
		"cell_province": gen.cell_province.duplicate(),
		"is_land": gen.is_land.duplicate(),
	}


func _commit_stroke() -> void:
	var after: Variant = _snapshot(_stroke_layer)
	var before: Variant = _before
	if before == null or after == null:
		return
	var idx := PackedInt32Array()
	var bvals: Array = []
	var avals: Array = []
	if _stroke_layer == Layer.STATE:
		for i in gen.provinces.size():
			var b: int = int(before[i]) if i < before.size() else 0
			var a: int = int(after[i]) if i < after.size() else 0
			if b != a:
				idx.append(i)
				bvals.append(b)
				avals.append(a)
	else:
		var n: int = mini(before.size(), after.size())
		for i in n:
			if before[i] != after[i]:
				idx.append(i)
				bvals.append(before[i])
				avals.append(after[i])
	if idx.size() == 0:
		return
	var entry := {"layer": _stroke_layer, "idx": idx, "before": bvals, "after": avals}
	if _stroke_layer != Layer.BIOME:
		entry["struct_before"] = _struct_before
		entry["struct_after"] = _snapshot_struct()
	undo_stack.append(entry)
	if undo_stack.size() > MAX_UNDO:
		undo_stack.remove_at(0)
	redo_stack.clear()
	_post_process(_stroke_layer, idx)
	data_changed.emit()


# ---------------------------------------------------------------- 撤销 / 恢复
func can_undo() -> bool:
	return not undo_stack.is_empty()


func can_redo() -> bool:
	return not redo_stack.is_empty()


func undo() -> bool:
	if undo_stack.is_empty():
		return false
	var e: Dictionary = undo_stack.pop_back()
	_apply_delta(e, true)
	redo_stack.append(e)
	data_changed.emit()
	return true


func redo() -> bool:
	if redo_stack.is_empty():
		return false
	var e: Dictionary = redo_stack.pop_back()
	_apply_delta(e, false)
	undo_stack.append(e)
	data_changed.emit()
	return true


## 每次落笔后的结构修复（保证不产生孤儿/空省/错误归属）
func _post_process(l: int, changed: Variant) -> void:
	match l:
		Layer.HEIGHT:
			var cells: Array = []
			for i in changed:
				cells.append(int(i))
			gen.apply_height_changes(cells)
			gen.rebuild_after_province_edit()
			_remap_targets()
		Layer.PROVINCE:
			var remap: Dictionary = gen.rebuild_after_province_edit()
			_remap_targets(remap)
		Layer.STATE:
			gen.rebuild_after_state_edit()
	if render:
		render.mark_dirty()


func _remap_targets(remap: Dictionary = {}) -> void:
	if target_province >= 0 and not remap.is_empty():
		target_province = int(remap.get(target_province, -1))
	if target_province >= gen.provinces.size():
		target_province = -1
	if merge_province_src >= gen.provinces.size():
		merge_province_src = -1
	if target_state >= gen.states.size():
		target_state = -1
	if merge_state_src >= gen.states.size():
		merge_state_src = -1


func _apply_delta(e: Dictionary, use_before: bool) -> void:
	var l: int = int(e.layer)
	var idx: PackedInt32Array = e.idx
	var vals: Array = e.before if use_before else e.after
	# 1) 先还原结构（provinces/states 深拷贝），再回放 cell 级 delta
	if e.has("struct_before"):
		var st: Dictionary = e.struct_before if use_before else e.struct_after
		gen.provinces = st.provinces.duplicate(true)
		gen.states = st.states.duplicate(true)
		if st.has("cell_province"):
			gen.cell_province = st.cell_province.duplicate()
		if st.has("is_land"):
			gen.is_land = st.is_land.duplicate()
	# 2) 主数组 delta
	match l:
		Layer.HEIGHT:
			for k in idx.size():
				gen.elevation[idx[k]] = float(vals[k])
			if not e.has("struct_before"):
				for k2 in idx.size():
					var i2: int = idx[k2]
					gen.is_land[i2] = 1 if gen.elevation[i2] > gen.sea_level_effective else 0
		Layer.BIOME:
			for k3 in idx.size():
				gen.biome[idx[k3]] = int(vals[k3])
		Layer.PROVINCE:
			for k4 in idx.size():
				gen.cell_province[idx[k4]] = int(vals[k4])
		Layer.STATE:
			for k5 in idx.size():
				var pi: int = idx[k5]
				if pi < gen.provinces.size():
					gen.provinces[pi].state = int(vals[k5])
	if l != Layer.BIOME:
		# 结构已整体还原，只需重建派生数据（cell 集 / 邻接 / 国家列表）
		gen.rebuild_after_province_edit()
	_remap_targets()
	if render:
		render.mark_dirty()


# ---------------------------------------------------------------- 高度层专用操作
## 原版 OnGenHeightMapButtonClicked → WorldGenerateHeightMap：生成一张"纯粹的高度图"
## （官方文案：生成高度图 = 生成一张纯粹的高度图，因此行政层被清空）
func generate_heightmap(seed_val: int) -> void:
	gen._gen_elevation(seed_val)
	gen.provinces.clear()
	gen.states.clear()
	gen.cell_province.fill(-1)
	gen._gen_biomes(seed_val)
	gen.absorb_unassigned_sea()
	undo_stack.clear()
	redo_stack.clear()
	target_province = -1
	target_state = -1
	if render:
		render.mark_dirty()
	data_changed.emit()
	status_changed.emit("已生成高度图（seed %d）" % seed_val)


## 原版 PlaceContinent：点击处随机放置一块"中间高四周低"的大陆，衰减系数控制形状
func place_continent(world_pos: Vector2) -> void:
	var cx := int(world_pos.x / CELL)
	var cy := int(world_pos.y / CELL)
	var r := maxi(8, brush_radius * 3)
	var rng := RandomNumberGenerator.new()
	rng.seed = Time.get_ticks_usec()
	var lump := FastNoiseLite.new()
	lump.seed = rng.randi()
	lump.frequency = 0.12
	var peak := brush_height / HEIGHT_SCALE
	for y in range(maxi(0, cy - r), mini(MapGen.H - 1, cy + r) + 1):
		for x in range(maxi(0, cx - r), mini(MapGen.W - 1, cx + r) + 1):
			var d := Vector2(float(x - cx), float(y - cy)).length() / float(r)
			if d > 1.0:
				continue
			# 衰减系数：越大边缘越陡（原版 DecayFactor 语义）
			var falloff := pow(1.0 - d, 1.0 + decay * 2.0)
			var jitter := 1.0 + lump.get_noise_2d(x, y) * 0.35
			var h := clampf(peak * falloff * jitter, 0.0, 1.0)
			var i := y * MapGen.W + x
			if h > gen.elevation[i]:
				gen.elevation[i] = h
	gen.apply_height_changes(_all_cells())
	gen.rebuild_after_province_edit()
	if render:
		render.mark_dirty()
	data_changed.emit()
	status_changed.emit("已放置大陆")


func _all_cells() -> Array:
	var out: Array = []
	out.resize(MapGen.W * MapGen.H)
	for i in MapGen.W * MapGen.H:
		out[i] = i
	return out


## 原版 EraseContinent（擦除陆地）：把笔刷范围内陆地压到海平面以下
func erase_land(world_pos: Vector2) -> void:
	var prev_mode := brush_mode
	var prev_h := brush_height
	brush_mode = BrushMode.MIN
	brush_height = 0.0
	begin_stroke(world_pos)
	end_stroke()
	brush_mode = prev_mode
	brush_height = prev_h


## 编辑后重算生态（原版 WorldRegenerateBiom / RegenerateEcosystem）
func regenerate_biomes(seed_val: int) -> void:
	for i in MapGen.W * MapGen.H:
		var t := clampf(gen.temperature[i] + temperature_modifier, 0.0, 1.0)
		var m := clampf(gen.moisture[i] * precipitation_factor, 0.0, 1.0)
		gen.temperature[i] = t
		gen.moisture[i] = m
		gen.biome[i] = gen._biome_from_climate(i, t, m)
	if render:
		render.mark_dirty()
	data_changed.emit()
	status_changed.emit("已按温度/湿度重算生态图（seed %d）" % seed_val)


# ---------------------------------------------------------------- 行省 / 国家层操作
func place_province(world_pos: Vector2) -> void:
	var i := gen.cell_index_at(world_pos)
	if i < 0:
		return
	var pid := gen.add_province_at(i)
	if pid >= 0:
		var remap := gen.rebuild_after_province_edit()
		target_province = int(remap.get(pid, pid))
		if render:
			render.mark_dirty()
		data_changed.emit()
		status_changed.emit("已新建行省 %d，可继续用笔刷绘制" % (target_province + 1))


func place_state(world_pos: Vector2) -> void:
	var si := gen.add_state()
	gen.rebuild_after_state_edit()
	target_state = si
	# 原版 PlaceState：点击处生成国家，随后自动进入绘制模式
	layer = Layer.STATE
	active = true
	if render:
		render.mark_dirty()
	data_changed.emit()
	status_changed.emit("已新建国家 %d" % (si + 1))


func pick_province_at(world_pos: Vector2) -> int:
	var i := gen.cell_index_at(world_pos)
	if i < 0:
		return -1
	var pi: int = gen.cell_province[i]
	if pi >= 0 and not gen.provinces[pi].get("is_sea", false):
		if target_province != pi:
			merge_province_src = target_province
		target_province = pi
		return pi
	return -1


func pick_state_at(world_pos: Vector2) -> int:
	var pi := pick_province_at(world_pos)
	if pi >= 0:
		var st := int(gen.provinces[pi].state)
		if target_state != st:
			merge_state_src = target_state
		target_state = st
		return target_state
	return -1


## 原版 alt+左键：把行省首府移到点击位置
func set_province_capital_at(world_pos: Vector2) -> void:
	var i := gen.cell_index_at(world_pos)
	if i < 0 or target_province < 0 or target_province >= gen.provinces.size():
		return
	if gen.is_land[i] == 0:
		return
	gen.provinces[target_province].center = i
	gen.provinces[target_province].burg = Vector2(i % MapGen.W, i / MapGen.W) * CELL + Vector2(CELL, CELL) * 0.5
	if render:
		render.mark_dirty()
	status_changed.emit("行省 %s 首府已移动" % gen.provinces[target_province].name)


## 行省合并（原版把一行省并入另一行省）：把 src 的全部 cell 划给 dst
func merge_provinces(src: int, dst: int) -> bool:
	if src < 0 or dst < 0 or src == dst:
		return false
	if src >= gen.provinces.size() or dst >= gen.provinces.size():
		return false
	if gen.provinces[src].get("is_sea", false) or gen.provinces[dst].get("is_sea", false):
		return false
	var moved := 0
	for i in MapGen.W * MapGen.H:
		if gen.cell_province[i] == src:
			gen.cell_province[i] = dst
			moved += 1
	if moved == 0:
		return false
	var remap: Dictionary = gen.rebuild_after_province_edit()
	target_province = int(remap.get(dst, -1))
	merge_province_src = -1
	if render:
		render.mark_dirty()
	data_changed.emit()
	status_changed.emit("已合并行省（%d 格）" % moved)
	return true


## 国家合并（原版把一国并入另一国）：src 的全部行省划给 dst，src 灭亡
func merge_states(src: int, dst: int) -> bool:
	if src < 0 or dst < 0 or src == dst:
		return false
	if src >= gen.states.size() or dst >= gen.states.size():
		return false
	var moved := 0
	for pi in gen.provinces.size():
		if int(gen.provinces[pi].state) == src:
			gen.provinces[pi].state = dst
			moved += 1
	if moved == 0:
		return false
	gen.rebuild_after_state_edit()
	merge_state_src = -1
	if render:
		render.mark_dirty()
	data_changed.emit()
	status_changed.emit("已合并国家（%d 行省）" % moved)
	return true


## 清空地图（原版 ClearMap）：地形归零 + 行政/群系清空，只保留一个海洋省
func clear_map_all() -> void:
	gen.clear_map()
	undo_stack.clear()
	redo_stack.clear()
	target_province = -1
	target_state = -1
	merge_province_src = -1
	merge_state_src = -1
	if render:
		render.mark_dirty()
	data_changed.emit()
	status_changed.emit("地图已清空")


# ---------------------------------------------------------------- 保存 / 读取
const SAVE_PATH := "user://saves/map_edited.dat"

func save_map(path := SAVE_PATH) -> bool:
	DirAccess.make_dir_recursive_absolute("user://saves")
	var data := {
		"version": 1,
		"elevation": gen.elevation,
		"is_land": gen.is_land,
		"cell_province": gen.cell_province,
		"biome": gen.biome,
		"temperature": gen.temperature,
		"moisture": gen.moisture,
		"provinces": gen.provinces,
		"states": gen.states,
		"rivers": gen.rivers,
	}
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_var(data)
	f.close()
	return true


func load_map(path := SAVE_PATH) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return false
	var data: Variant = f.get_var()
	f.close()
	if not (data is Dictionary):
		return false
	gen.elevation = data.get("elevation", gen.elevation)
	gen.is_land = data.get("is_land", gen.is_land)
	gen.cell_province = data.get("cell_province", gen.cell_province)
	gen.biome = data.get("biome", gen.biome)
	gen.temperature = data.get("temperature", gen.temperature)
	gen.moisture = data.get("moisture", gen.moisture)
	gen.provinces = data.get("provinces", gen.provinces)
	gen.states = data.get("states", gen.states)
	gen.rivers = data.get("rivers", gen.rivers)
	gen.rebuild_after_province_edit()
	undo_stack.clear()
	redo_stack.clear()
	target_province = -1
	target_state = -1
	if render:
		render.mark_dirty()
	data_changed.emit()
	status_changed.emit("已读取编辑结果")
	return true


# ---------------------------------------------------------------- 统计（供面板显示）
func land_cell_count() -> int:
	var n := 0
	for i in gen.is_land.size():
		if gen.is_land[i] == 1:
			n += 1
	return n


func undrawn_land_count() -> int:
	var n := 0
	for i in gen.is_land.size():
		if gen.is_land[i] == 1 and gen.cell_province[i] < 0:
			n += 1
	return n


func province_count() -> int:
	var n := 0
	for p in gen.provinces:
		if not p.get("is_sea", false):
			n += 1
	return n
