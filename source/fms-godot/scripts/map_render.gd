class_name MapRender
extends Node2D
## 忠实版地图渲染（对齐原版观感）
## 层级（canvas item 顺序）：羊皮纸(0) → 坐标网格(1) → 陆地色块(2) →
## 河流/省界/国界/海岸/图标/城邑/国家名(3, overlay 子节点)
## 网格重建节流：脏标记 + 最小间隔

const COAST_COLOR := Color(0.22, 0.17, 0.13, 0.95)
const STATE_BORDER_COLOR := Color(0.52, 0.10, 0.08, 0.92)   # 原版国界为暗红粗线（截图为证）
const PROV_BORDER_COLOR := Color(0.42, 0.30, 0.22, 0.42)
const RIVER_COLOR := Color(0.30, 0.50, 0.66, 0.8)
const GRID_COLOR := Color(0.52, 0.46, 0.36, 0.30)
const LAND_ALPHA := 0.92
const LABEL_COLOR := Color(0.13, 0.11, 0.09, 0.9)
const GRID_STEP := 220.0

var gen: MapGen
var cam: Camera2D
var land_mesh := MeshInstance2D.new()
var underlay: DrawLayer
var overlay: DrawLayer
var label_font: SystemFont
var small_font: SystemFont
var _dirty := true
var _dirty_terrain := true
var _last_build_ms := 0
var _dbg_printed := false

## 地图外观：政治图 / 高度图 / 植被图（原版 EditBiomTips：在地图外观中从高度图切换成植被图）
enum View { POLITICAL, HEIGHT, BIOME }
var view_mode := View.POLITICAL
var admin_alpha := 1.0          # 行政图透明度（原版 StateMapTransparency）
## 笔刷预览（编辑器开启时由 MapEditor 写入）
var brush_preview := {}         # {"pos": Vector2, "radius": float, "color": Color}


func setup(g: MapGen, camera: Camera2D) -> void:
	gen = g
	cam = camera
	label_font = SystemFont.new()
	label_font.font_names = PackedStringArray(["Noto Serif CJK SC", "Source Han Serif SC", "SimSun", "NSimSun", "serif"])
	small_font = SystemFont.new()
	small_font.font_names = PackedStringArray(["Noto Sans CJK SC", "Microsoft YaHei", "SimHei", "sans-serif"])
	for c in get_children():
		c.queue_free()
	var paper := Sprite2D.new()
	paper.texture = load("res://assets/origin/1600x900Parchment.png")
	paper.centered = false
	var world_size := Vector2(MapGen.W * MapGen.CELL, MapGen.H * MapGen.CELL)
	paper.scale = world_size / Vector2(paper.texture.get_size())
	paper.z_index = 0
	add_child(paper)
	underlay = DrawLayer.new()
	underlay.z_index = 1
	underlay.owner_render = self
	underlay.kind = "grid"
	add_child(underlay)
	land_mesh = MeshInstance2D.new()
	land_mesh.z_index = 2
	add_child(land_mesh)
	overlay = DrawLayer.new()
	overlay.z_index = 3
	overlay.owner_render = self
	overlay.kind = "map"
	add_child(overlay)
	_build_icon_sprites()
	_dirty = true

## 地形图标改用 Sprite2D 节点（draw_set_transform + 纹理在部分画布状态下渲染异常，
## Sprite 节点由引擎原生管线保证正确）
func _build_icon_sprites() -> void:
	var holder := Node2D.new()
	holder.name = "Icons"
	holder.z_index = 4
	add_child(holder)
	var mtex: Texture2D = load("res://assets/origin/mount16_64.png")
	var ttex: Texture2D = load("res://assets/origin/tree1png_64.png")
	for spot in gen.mountain_spots:
		var sp := Sprite2D.new()
		sp.texture = mtex
		sp.position = spot[0]
		sp.scale = Vector2.ONE * spot[1]
		sp.flip_h = spot[2]
		sp.modulate = Color(0.22, 0.20, 0.17, 0.85)
		sp.z_index = 4
		holder.add_child(sp)
	for spot in gen.tree_spots:
		var sp := Sprite2D.new()
		sp.texture = ttex
		sp.position = spot[0]
		sp.scale = Vector2.ONE * spot[1]
		sp.flip_h = spot[2]
		sp.modulate = Color(0.24, 0.30, 0.20, 0.7)
		sp.z_index = 4
		holder.add_child(sp)

## 脏标记分级（V5.1 性能）：terrain = 地形/视图（全量重建）
## ownership = 省份归属/边界（只重算边界与 overlay，跳过 134400 格 mesh 重建）
func mark_dirty() -> void:
	_dirty = true
	_dirty_terrain = true

func mark_ownership_dirty() -> void:
	_dirty = true

func _process(_delta: float) -> void:
	if _dirty and Time.get_ticks_msec() - _last_build_ms > 120:
		rebuild()

func rebuild() -> void:
	if gen == null or underlay == null:
		return
	_last_build_ms = Time.get_ticks_msec()
	_dirty = false
	var _t0 := Time.get_ticks_msec()
	if not _dbg_printed and gen.mountain_spots.size() > 0:
		_dbg_printed = true
		print("[dbg] spots=", gen.mountain_spots.size(), " first=", gen.mountain_spots[0],
			" zoom=", cam.zoom.x if cam else -1.0)
	_build_land_mesh()
	var _t1 := Time.get_ticks_msec()
	_extract_borders()
	var _t2 := Time.get_ticks_msec()
	underlay.queue_redraw()
	overlay.queue_redraw()
	var f := FileAccess.open("user://rebuild_perf.log", FileAccess.READ_WRITE)
	var prev := f.get_as_text() if f != null else ""
	var f2 := FileAccess.open("user://rebuild_perf.log", FileAccess.WRITE)
	f2.store_string(prev + "mesh=%d borders=%d total=%d
" % [_t1 - _t0, _t2 - _t1, _t2 - _t0])
	f2.close()

## 陆地色块：仅陆地格入 Mesh（海面透出羊皮纸）
func _build_land_mesh() -> void:
	var W := MapGen.W
	var H := MapGen.H
	var CS := MapGen.CELL
	var verts := PackedVector3Array()
	var colors := PackedColorArray()
	var idxs := PackedInt32Array()
	for y in H:
		for x in W:
			var ci := y * W + x
			if gen.is_land[ci] == 0 and view_mode != View.HEIGHT and view_mode != View.BIOME:
				continue
			var si: int = gen.cell_province[ci]
			var col: Color
			if view_mode == View.BIOME:
				var b: int = gen.biome[ci] if ci < gen.biome.size() else 0
				col = MapGen.BIOME_COLORS[b]
				col = Color(col.r, col.g, col.b, 0.92)
			elif view_mode == View.HEIGHT:
				# 高度图：海面以下深蓝→浅蓝，海平面以上褐→近白（原版高度图是浮雕灰阶观感）
				var sea := gen.sea_level_effective
				var e2: float = gen.elevation[ci]
				if e2 <= sea:
					var td := clampf(e2 / maxf(sea, 0.0001), 0.0, 1.0)
					col = Color(0.16, 0.22, 0.30).lerp(Color(0.42, 0.52, 0.60), td)
					col.a = 0.96
				else:
					var h: float = clampf((e2 - sea) / maxf(1.0 - sea, 0.001), 0.0, 1.0)
					h = pow(h, 1.9)   # 提对比：低地压暗，高地才发白（接近原版浮雕观感）
					col = Color(0.42, 0.36, 0.27).lerp(Color(0.99, 0.98, 0.95), h)
					col.a = 0.96
			elif si >= 0:
				var st: int = gen.provinces[si].state
				if st >= 0 and st < gen.states.size():
					col = gen.states[st].color
				else:
					col = Color(0.62, 0.58, 0.50)
				col = Color(col.r, col.g, col.b, LAND_ALPHA * admin_alpha)
				var e := gen.elevation[ci]
				col = col.lightened(clampf((e - gen.sea_level_effective) * 0.6, 0.0, 0.2))
			else:
				col = Color(0.62, 0.58, 0.50, 0.5)
			var vbase := verts.size()
			var px := x * CS
			var py := y * CS
			verts.push_back(Vector3(px, py, 0))
			verts.push_back(Vector3(px + CS, py, 0))
			verts.push_back(Vector3(px + CS, py + CS, 0))
			verts.push_back(Vector3(px, py + CS, 0))
			for k in 4:
				colors.push_back(col)
			idxs.push_back(vbase)
			idxs.push_back(vbase + 1)
			idxs.push_back(vbase + 2)
			idxs.push_back(vbase)
			idxs.push_back(vbase + 2)
			idxs.push_back(vbase + 3)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = idxs
	var m := ArrayMesh.new()
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	m.surface_set_material(0, mat)
	land_mesh.mesh = m

## 从格网提取三类边界并焊接成折线
func _extract_borders() -> void:
	var W := MapGen.W
	var H := MapGen.H
	var CS := MapGen.CELL
	var coast_segs := {}
	var state_segs := {}
	var prov_segs := {}
	for y in H:
		for x in W:
			var ci := y * W + x
			if gen.is_land[ci] == 0 and view_mode != View.HEIGHT and view_mode != View.BIOME:
				continue
			var pi: int = gen.cell_province[ci]
			var si: int = gen.provinces[pi].state if pi >= 0 else -1
			var right := -1
			if x + 1 < W:
				right = y * W + (x + 1)
			var down := -1
			if y + 1 < H:
				down = (y + 1) * W + x
			for dir in 2:
				var nb := right if dir == 0 else down
				var kind := ""
				if nb < 0 or gen.is_land[nb] == 0:
					kind = "coast"
				else:
					var pn: int = gen.cell_province[nb]
					var sn: int = gen.provinces[pn].state if pn >= 0 else -1
					if sn != si:
						kind = "state"
					elif pn != pi:
						kind = "prov"
				if kind == "":
					continue
				var a: Vector2
				var b: Vector2
				if dir == 0:
					a = Vector2((x + 1) * CS, y * CS)
					b = Vector2((x + 1) * CS, (y + 1) * CS)
				else:
					a = Vector2(x * CS, (y + 1) * CS)
					b = Vector2((x + 1) * CS, (y + 1) * CS)
				var target := coast_segs if kind == "coast" else (state_segs if kind == "state" else prov_segs)
				_add_seg(target, a, b)
	overlay.coast_lines = _smooth_all(_chain(coast_segs))
	overlay.state_lines = _smooth_all(_chain(state_segs))
	overlay.prov_lines = _smooth_all(_chain(prov_segs))
	overlay.river_lines = gen.rivers

## 边界平滑：两轮 Chaikin 角切割，把格网阶梯边变成平滑斜线
## （对齐原版维诺图式平滑观感；闭环折线保持闭合）
func _smooth_all(lines: Array) -> Array:
	var out: Array = []
	for l in lines:
		if l.size() >= 5:
			out.append(_smooth_line(l))
		else:
			out.append(l)
	return out

func _smooth_line(src: PackedVector2Array) -> PackedVector2Array:
	var pts := src.duplicate()
	var closed := pts[0].distance_to(pts[pts.size() - 1]) < 3.0
	if closed:
		# 闭环：首点复制到尾部参与切割
		pts.append(pts[0])
	for _pass in 2:
		var out := PackedVector2Array()
		out.append(pts[0])
		for i in pts.size() - 1:
			var p := pts[i]
			var q := pts[i + 1]
			out.append(p * 0.75 + q * 0.25)
			out.append(p * 0.25 + q * 0.75)
		out.append(pts[pts.size() - 1])
		pts = out
	if closed:
		pts.remove_at(pts.size() - 1)
	return pts

func _add_seg(store: Dictionary, a: Vector2, b: Vector2) -> void:
	var ka := Vector2i(a)
	var kb := Vector2i(b)
	if not store.has(ka):
		store[ka] = []
	store[ka].append(kb)
	if not store.has(kb):
		store[kb] = []
	store[kb].append(ka)

## 端点邻接表 → 折线串接
func _chain(segs: Dictionary) -> Array:
	var visited := {}
	var out: Array = []
	for start in segs:
		if visited.has(start):
			continue
		var line := PackedVector2Array()
		line.append(Vector2(Vector2i(start)))
		visited[start] = true
		for way in 2:
			var cur: Vector2i = start
			while true:
				var ext := Vector2i(-1, -1)
				var found := false
				for nb in segs[cur]:
					if not visited.has(nb):
						ext = nb
						found = true
						break
				if not found:
					break
				visited[ext] = true
				if way == 0:
					line.append(Vector2(ext))
				else:
					line.insert(0, Vector2(ext))
				cur = ext
		if line.size() >= 2:
			out.append(line)
	return out


class DrawLayer:
	extends Node2D
	var owner_render: MapRender
	var kind := "map"
	var coast_lines: Array = []
	var state_lines: Array = []
	var prov_lines: Array = []
	var river_lines: Array = []

	func _draw() -> void:
		if owner_render == null or owner_render.gen == null:
			return
		var g := owner_render.gen
		if kind == "grid":
			# 虚线经纬网（原版截图为虚线；此处用短段+间隔模拟）
			var Wf := MapGen.W * MapGen.CELL
			var Hf := MapGen.H * MapGen.CELL
			var dash := 14.0
			var gap := 10.0
			var x := MapRender.GRID_STEP
			while x <= Wf:
				var y2 := 0.0
				while y2 < Hf:
					draw_line(Vector2(x, y2), Vector2(x, minf(y2 + dash, Hf)), MapRender.GRID_COLOR, 1.0, true)
					y2 += dash + gap
				x += MapRender.GRID_STEP
			var y := MapRender.GRID_STEP
			while y <= Hf:
				var x2 := 0.0
				while x2 < Wf:
					draw_line(Vector2(x2, y), Vector2(minf(x2 + dash, Wf), y), MapRender.GRID_COLOR, 1.0, true)
					x2 += dash + gap
				y += MapRender.GRID_STEP
			return
		# ---- map 层（河流/边界/城邑/文字；地形图标改由 Sprite 节点层绘制） ----
		for r in river_lines:
			draw_polyline(r, MapRender.RIVER_COLOR, 1.6, true)
		for l in prov_lines:
			draw_polyline(l, MapRender.PROV_BORDER_COLOR, 1.0, true)
		for l in state_lines:
			draw_polyline(l, MapRender.STATE_BORDER_COLOR, 3.0, true)
		for l in coast_lines:
			draw_polyline(l, MapRender.COAST_COLOR, 3.2, true)
		var zoom := 1.0
		if owner_render.cam:
			zoom = owner_render.cam.zoom.x
		for pi in g.provinces.size():
			var p: Dictionary = g.provinces[pi]
			if p.get("is_sea", false):
				continue  # 海域省无城邑
			var bp: Vector2 = p.burg
			draw_circle(bp, 2.6, Color(0.95, 0.93, 0.88, 0.9))
			draw_circle(bp, 1.6, Color(0.15, 0.13, 0.11, 0.95))
			if p.is_capital_burg and g.states[p.state].alive:
				draw_arc(bp, 4.2, 0, TAU, 12, Color(0.15, 0.13, 0.11, 0.9), 1.2, true)
			if zoom > 1.8:
				draw_string(owner_render.small_font, bp + Vector2(5, -4), p.name,
					HORIZONTAL_ALIGNMENT_LEFT, -1, 9, MapRender.LABEL_COLOR)
		for s in g.states:
			if not s.alive or s.provinces.is_empty():
				continue
			var c: Vector2 = s.centroid
			var text: String = s.name
			var fs := 42
			var w: float = owner_render.label_font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
			draw_string(owner_render.label_font, c - Vector2(w * 0.5, -fs * 0.35), text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, fs, MapRender.LABEL_COLOR)
		# ---- 编辑器笔刷预览（原版 BrushManager.DrawShapes 的可见反馈） ----
		var bp: Dictionary = owner_render.brush_preview
		if not bp.is_empty():
			var bpos: Vector2 = bp.get("pos", Vector2.ZERO)
			var br: float = float(bp.get("radius", 0.0)) * MapGen.CELL
			var bc: Color = bp.get("color", Color(0.2, 0.2, 0.2, 0.7))
			if br > 0.5:
				draw_arc(bpos, br, 0.0, TAU, 48, bc, 2.0, true)
				draw_arc(bpos, br * 0.55, 0.0, TAU, 32, Color(bc.r, bc.g, bc.b, bc.a * 0.45), 1.2, true)
