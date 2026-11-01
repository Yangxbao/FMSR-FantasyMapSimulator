class_name ArmyIconsLayer
extends Node2D
## 军事图层 V5.3：每支军队一面旗帜（全部节点渲染——Sprite2D 旗面/旗杆/徽标 + Label 兵力）。
## ★A ArmyShape_SVG 几何 + part:State 国色染色语义。
## 行军可视化：preCell→currentCell 插值动画（moving 节点每帧插值）。
## 战场 ⚔️ 标记：活跃战役省显示脉动图标（Label 节点）。
## 宣战箭头：Line2D+Polygon2D 节点（大尺寸、高对比），指向目标国。
## 性能：节点池（按 army_id 增删）；静止旗零开销；行军节点仅插值 position。
## 注：V5.2 实测 _draw() 自绘内容在部分环境不可见——本版全部改节点渲染。

const CELL := 26
var gen: MapGen
var sim: Simulation
var _nodes := {}                 # army_id -> ArmyFlagNode
var _battle_marks := {}          # pi -> {node}
var _arrow_node: Node2D = null
var _last_sync_ms := 0
var _interp_t := 1.0
var _sync_period_ms := 400
var _dirty := true
var war_arrows: Array = []       # {from_si, to_si, until_ms}

func setup(g: MapGen, s: Simulation) -> void:
	gen = g
	sim = s
	z_index = 30
	sim.map_changed.connect(func(): _dirty = true)
	_sync()

func show_war_arrow(from_si: int, to_si: int, seconds := 30.0) -> void:
	war_arrows.append({"from_si": from_si, "to_si": to_si,
		"until_ms": Time.get_ticks_msec() + int(seconds * 1000)})
	_rebuild_arrow()

func process_delta(delta: float) -> void:
	_interp_t = clampf(_interp_t + delta * 1000.0 / float(_sync_period_ms), 0.0, 1.0)
	var now := Time.get_ticks_msec()
	if now - _last_sync_ms >= _sync_period_ms:
		_last_sync_ms = now
		_sync()
	_interp_positions()
	_update_battle_marks()
	if _arrow_node != null:
		if war_arrows.is_empty():
			_arrow_node.queue_free()
			_arrow_node = null

func _interp_positions() -> void:
	for id in _nodes:
		var n: ArmyFlagNode = _nodes[id]
		if n.moving:
			n.position = n.pos_from.lerp(n.pos_to, _interp_t)

func _sync() -> void:
	var seen := {}
	for a in sim.armies:
		if str(a.get("current_state", "")) == "Destroyed" or float(a.get("army_count", 0.0)) <= 0.0:
			continue
		var id: int = int(a["army_id"])
		seen[id] = true
		var n: ArmyFlagNode = _get_node(id)
		var cur: int = int(a["current_cell"])
		var pre: int = int(a.get("pre_cell", -1))
		var to_pos := _cell_center(cur)
		var from_pos := _cell_center(pre) if pre >= 0 else to_pos
		var marching: bool = str(a.get("current_state", "")) == "Marching" and pre >= 0 and pre != cur
		if n.army_state != str(a.get("current_state", "")) or n.cell_to != cur:
			n.cell_from = pre
			n.cell_to = cur
			n.pos_from = from_pos
			n.pos_to = to_pos
			n.army_state = str(a.get("current_state", ""))
			n.moving = marching
			n.position = from_pos
		n.count = int(round(float(a.get("army_count", 0.0))))
		n.setup_flag(_state_color(int(a.get("state", -1))),
			str(a.get("army_type", "")), str(a.get("current_state", "")), marching)
	for id in _nodes.keys():
		if not seen.has(id):
			(_nodes[id] as Node).queue_free()
			_nodes.erase(id)
	var new_marks := {}
	for c in sim.campaigns:
		if bool(c.get("is_active", false)):
			var pi: int = int(c.get("location_province_id", -1))
			if pi >= 0:
				new_marks[pi] = true
	for pi in new_marks:
		if not _battle_marks.has(pi):
			var mk := BattleMark.new()
			mk.position = _cell_center(_prov_center_cell(pi))
			mk.z_index = 40
			add_child(mk)
			_battle_marks[pi] = {"node": mk}
	for pi in _battle_marks.keys():
		if not new_marks.has(pi):
			var bnode: Node = (_battle_marks[pi] as Dictionary).get("node")
			if bnode != null:
				bnode.queue_free()
			_battle_marks.erase(pi)
	_dirty = false

func _prov_center_cell(pi: int) -> int:
	var cells: PackedInt32Array = gen.provinces[pi].get("cells", PackedInt32Array())
	if cells.size() == 0:
		return 0
	return cells[cells.size() / 2]

func _cell_center(cell: int) -> Vector2:
	return Vector2((cell % gen.W + 0.5) * CELL, (cell / gen.W + 0.5) * CELL)

func _state_color(si: int) -> Color:
	if si >= 0 and si < gen.states.size():
		return gen.states[si].color
	return Color(0.4, 0.4, 0.4)

func _get_node(id: int) -> ArmyFlagNode:
	if _nodes.has(id):
		return _nodes[id]
	var n := ArmyFlagNode.new()
	n.name = "army_%d" % id
	n.z_index = 31
	add_child(n)
	_nodes[id] = n
	return n

func _update_battle_marks() -> void:
	for pi in _battle_marks:
		var node: BattleMark = (_battle_marks[pi] as Dictionary).get("node")
		if node != null:
			node.phase = fmod(node.phase + 0.08, TAU)
			node.scale = Vector2.ONE * (1.0 + 0.25 * sin(node.phase))

func hit_test(world_pos: Vector2) -> int:
	var best_id := -1
	var best_d := 1e9
	for id in _nodes:
		var n: ArmyFlagNode = _nodes[id]
		var d: float = world_pos.distance_to(n.position)
		if d < 20.0 and d < best_d:
			best_d = d
			best_id = id
	return best_id

func province_of(army_id: int) -> int:
	for a in sim.armies:
		if int(a["army_id"]) == army_id:
			return int(gen.cell_province[int(a["current_cell"])])
	return -1

func armies_at(pi: int) -> Array:
	var out: Array = []
	for a in sim.armies:
		if int(gen.cell_province[int(a["current_cell"])]) == pi \
				and str(a.get("current_state", "")) != "Destroyed":
			out.append(a)
	return out

## —— 宣战箭头（大尺寸 Line2D + Polygon2D 箭头头 + ⚔️ Label，全节点渲染）——
func _rebuild_arrow() -> void:
	if _arrow_node == null:
		_arrow_node = Node2D.new()
		_arrow_node.name = "WarArrow"
		_arrow_node.z_index = 45
		add_child(_arrow_node)
	for c in _arrow_node.get_children():
		c.queue_free()
	if war_arrows.is_empty():
		return
	for ar in war_arrows:
		var fpos := _state_anchor(int(ar["from_si"]))
		var tpos := _state_anchor(int(ar["to_si"]))
		if fpos == Vector2.INF or tpos == Vector2.INF:
			continue
		var dir := (tpos - fpos).normalized()
		var start := fpos + dir * 40.0
		var end := tpos - dir * 60.0
		var line := Line2D.new()
		line.add_point(start)
		line.add_point(start.lerp(end, 0.55))
		line.width = 14.0
		line.default_color = Color(0.9, 0.08, 0.05, 0.95)
		_arrow_node.add_child(line)
		var head := Polygon2D.new()
		var left := end - dir.rotated(0.45) * 70.0
		var right := end - dir.rotated(-0.45) * 70.0
		head.polygon = PackedVector2Array([end, left, right])
		head.color = Color(0.9, 0.08, 0.05, 0.98)
		_arrow_node.add_child(head)
		var mark := Label.new()
		mark.text = "⚔"
		mark.position = end + Vector2(10, -50)
		mark.add_theme_font_size_override("font_size", 64)
		mark.add_theme_color_override("font_color", Color(0.9, 0.08, 0.05))
		mark.add_theme_color_override("font_outline_color", Color(0.95, 0.93, 0.85))
		mark.add_theme_constant_override("outline_size", 8)
		_arrow_node.add_child(mark)

func _state_anchor(si: int) -> Vector2:
	if si < 0 or si >= gen.states.size():
		return Vector2.INF
	var cap: int = int(gen.states[si].get("capital", -1))
	if cap < 0:
		return Vector2.INF
	var cells: PackedInt32Array = gen.provinces[cap].get("cells", PackedInt32Array())
	if cells.size() == 0:
		return Vector2.INF
	return _cell_center(cells[cells.size() / 2])

## —— 战场 ⚔️ 标记（Label 节点，脉动缩放）——
class BattleMark:
	extends Node2D
	var phase := 0.0
	func _ready() -> void:
		var l := Label.new()
		l.text = "⚔"
		l.position = Vector2(-14, -22)
		l.add_theme_font_size_override("font_size", 30)
		l.add_theme_color_override("font_color", Color(0.85, 0.1, 0.06))
		l.add_theme_color_override("font_outline_color", Color(0.95, 0.93, 0.85))
		l.add_theme_constant_override("outline_size", 6)
		add_child(l)
	func _process(_d: float) -> void:
		phase = fmod(phase + 0.08, TAU)
		scale = Vector2.ONE * (1.0 + 0.25 * sin(phase))

## —— 军旗节点（全节点渲染：旗面/旗杆/徽标/文字）——
class ArmyFlagNode:
	extends Node2D
	var col := Color(0.4, 0.4, 0.4)
	var army_state := ""
	var moving := false
	var marching := false
	var fighting := false
	var count := 0
	var cell_from := -1
	var cell_to := -1
	var pos_from := Vector2.ZERO
	var pos_to := Vector2.ZERO
	var _built_color: Color = Color(-1, -1, -1)
	var _march_dot: Sprite2D = null
	var _fight_dot: Sprite2D = null
	var _label: Label = null

	func _build() -> void:
		for c in get_children():
			c.queue_free()
		var face := Sprite2D.new()
		var img := Image.create(22, 14, false, Image.FORMAT_RGBA8)
		for y in 14:
			for x in 22:
				if x == 0 or y == 0 or x == 21 or y == 13:
					img.set_pixel(x, y, Color(0.14, 0.12, 0.10))
				else:
					img.set_pixel(x, y, col)
		face.texture = ImageTexture.create_from_image(img)
		face.centered = false
		face.position = Vector2(-11, -30)
		face.z_index = 31
		add_child(face)
		var pole := Sprite2D.new()
		var pimg := Image.create(6, 36, false, Image.FORMAT_RGBA8)
		pimg.fill(Color(0, 0, 0, 0))
		for y in 36:
			for x in range(2, 4):
				pimg.set_pixel(x, y, Color(0.2, 0.17, 0.14))
		pole.texture = ImageTexture.create_from_image(pimg)
		pole.centered = false
		pole.position = Vector2(-3, -30)
		pole.z_index = 32
		add_child(pole)
		var mi := Image.create(10, 10, false, Image.FORMAT_RGBA8)
		mi.fill(Color(0, 0, 0, 0))
		for y in 10:
			for x in 10:
				var dx := x - 4.5
				var dy := y - 4.5
				if dx * dx + dy * dy <= 20.0:
					mi.set_pixel(x, y, Color(0.15, 0.45, 0.95))
		_march_dot = Sprite2D.new()
		_march_dot.texture = ImageTexture.create_from_image(mi)
		_march_dot.position = Vector2(16, -24)
		_march_dot.z_index = 34
		add_child(_march_dot)
		var fi := Image.create(14, 14, false, Image.FORMAT_RGBA8)
		fi.fill(Color(0, 0, 0, 0))
		for y in 14:
			for x in 14:
				var dx := x - 6.5
				var dy := y - 6.5
				if dx * dx + dy * dy <= 40.0:
					fi.set_pixel(x, y, Color(0.9, 0.12, 0.08))
		_fight_dot = Sprite2D.new()
		_fight_dot.texture = ImageTexture.create_from_image(fi)
		_fight_dot.position = Vector2(0, -38)
		_fight_dot.z_index = 34
		add_child(_fight_dot)
		_label = Label.new()
		_label.position = Vector2(18, -26)
		_label.add_theme_font_size_override("font_size", 13)
		_label.add_theme_color_override("font_color", Color(0.08, 0.06, 0.04))
		_label.add_theme_color_override("font_outline_color", Color(0.95, 0.93, 0.88))
		_label.add_theme_constant_override("outline_size", 3)
		_label.z_index = 35
		add_child(_label)
		_apply()

	func setup_flag(c: Color, _atype: String, astate: String, march: bool) -> void:
		marching = march
		fighting = astate == "Fighting"
		if _built_color != c:
			col = c
			_built_color = c
			_build()
		else:
			_apply()

	func _apply() -> void:
		if _march_dot != null:
			_march_dot.visible = marching
		if _fight_dot != null:
			_fight_dot.visible = fighting
		if _label != null:
			_label.visible = count > 0
			_label.text = str(count)
		var zl := 1.0
		var vp := get_viewport()
		if vp != null and vp.get_camera_2d() != null:
			zl = clampf(1.0 / maxf(vp.get_camera_2d().zoom.x, 0.05), 0.9, 2.0)
		scale = Vector2.ONE * zl

	func _process(_d: float) -> void:
		_apply()
