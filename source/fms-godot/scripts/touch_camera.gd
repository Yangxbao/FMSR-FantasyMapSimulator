class_name TouchCamera
extends Camera2D
## 触屏/鼠标相机：单指拖动、双指捏合缩放、滚轮缩放、点击选择信号
## 对应验收标准：触屏拖动、缩放、点击选择
##
## 编辑器模式（paint_mode = true）：左键 = 笔刷（原版 BrushManager 的绘制手感），
## 右键/中键拖动 = 平移，Shift+左键 = 选择（原版 DrawingProvinceTips：shift + 左键选择行省），
## Ctrl+滚轮 = 调笔刷半径（原版 TryAdjustCurrentBrushRadius 的快捷键语义）。

signal tapped(world_pos: Vector2)
signal long_pressed(world_pos: Vector2)
signal paint_started(world_pos: Vector2)
signal paint_moved(world_pos: Vector2)
signal paint_ended
signal hover_moved(world_pos: Vector2)
signal brush_radius_step(delta: int)

const MIN_ZOOM := 0.35
const MAX_ZOOM := 8.0
const DRAG_SLOP := 12.0
const LONG_PRESS_MS := 550

var paint_mode := false

var _touches := {}            # index -> pos
var _dragging := false
var _panning := false
var _painting := false
var _moved := false
var _pinch_dist := -1.0
var _press_pos := Vector2.ZERO
var _press_time_ms := 0
var _long_fired := false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			if paint_mode and mb.ctrl_pressed:
				brush_radius_step.emit(1)
			else:
				zoom_at(mb.position, 1.15)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			if paint_mode and mb.ctrl_pressed:
				brush_radius_step.emit(-1)
			else:
				zoom_at(mb.position, 1.0 / 1.15)
		elif mb.button_index == MOUSE_BUTTON_RIGHT or mb.button_index == MOUSE_BUTTON_MIDDLE:
			_panning = mb.pressed
			_moved = false
		elif mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_press_pos = mb.position
				_moved = false
				_long_fired = false
				_press_time_ms = Time.get_ticks_msec()
				if paint_mode and not mb.shift_pressed:
					_painting = true
					paint_started.emit(get_global_mouse_position())
				else:
					_dragging = true
			else:
				_dragging = false
				if _painting:
					_painting = false
					paint_ended.emit()
				elif not _moved:
					tapped.emit(get_global_mouse_position())
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		hover_moved.emit(get_global_mouse_position())
		if _painting:
			paint_moved.emit(get_global_mouse_position())
		elif _panning or _dragging:
			if mm.position.distance_to(_press_pos) > DRAG_SLOP:
				_moved = true
			position -= mm.relative / zoom.x
			_clamp_position()
	elif event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			_touches[st.index] = st.position
			if _touches.size() == 1:
				_press_pos = st.position
				_moved = false
				_long_fired = false
				_press_time_ms = Time.get_ticks_msec()
				if paint_mode:
					_painting = true
					paint_started.emit(get_global_mouse_position())
				else:
					_dragging = true
			elif _touches.size() == 2:
				_dragging = false
				_painting = false
				_pinch_dist = _two_touch_dist()
		else:
			_touches.erase(st.index)
			_pinch_dist = -1.0
			if _touches.size() == 1:
				_dragging = not paint_mode
				_press_pos = _touches.values()[0]
			elif _touches.size() == 0:
				if _painting:
					_painting = false
					paint_ended.emit()
				elif not _moved:
					tapped.emit(get_global_mouse_position())
	elif event is InputEventScreenDrag:
		var sd := event as InputEventScreenDrag
		_touches[sd.index] = sd.position
		if _touches.size() == 2:
			var d := _two_touch_dist()
			if _pinch_dist > 0.0 and d > 0.0:
				var pts: Array = _touches.values()
				var a: Vector2 = pts[0]
				var b: Vector2 = pts[1]
				zoom_at((a + b) * 0.5, d / _pinch_dist)
			_pinch_dist = d
		elif _touches.size() == 1:
			if _painting:
				paint_moved.emit(get_global_mouse_position())
			elif _dragging:
				if sd.position.distance_to(_press_pos) > DRAG_SLOP:
					_moved = true
				position -= sd.relative / zoom.x
				_clamp_position()

func _two_touch_dist() -> float:
	var pts: Array = _touches.values()
	if pts.size() < 2:
		return -1.0
	var a: Vector2 = pts[0]
	var b: Vector2 = pts[1]
	return a.distance_to(b)

func zoom_at(screen_pos: Vector2, factor: float) -> void:
	# 以屏幕点为锚点缩放（相机 anchor=中心：世界坐标 = position + (screen - vs/2)/zoom）
	var vs := get_viewport_rect().size
	var old_zoom := zoom.x
	var new_zoom := clampf(old_zoom * factor, MIN_ZOOM, MAX_ZOOM)
	if is_equal_approx(new_zoom, old_zoom):
		return
	var world := position + (screen_pos - vs * 0.5) / old_zoom
	zoom = Vector2.ONE * new_zoom
	position = world - (screen_pos - vs * 0.5) / new_zoom
	_clamp_position()

func _clamp_position() -> void:
	var half := get_viewport_rect().size * 0.5 / zoom.x
	var lim := Vector2(MapGen.W * MapGen.CELL, MapGen.H * MapGen.CELL)
	position.x = clampf(position.x, -half.x * 0.5, lim.x + half.x * 0.5)
	position.y = clampf(position.y, -half.y * 0.5, lim.y + half.y * 0.5)

func _process(_delta: float) -> void:
	# 长按（触屏的 Shift+点击等价物）：单指按住不动超过阈值
	if _dragging and not _moved and not _long_fired and _touches.size() <= 1:
		if Time.get_ticks_msec() - _press_time_ms > LONG_PRESS_MS:
			_long_fired = true
			_dragging = false
			long_pressed.emit(get_global_mouse_position())
