extends SceneTree
## 图标渲染最小测试（窗口模式运行）：验证提取图标 alpha 是否生效
## godot --path . --script tests/icon_test.gd

var frames := 0

func _init() -> void:
	var scene := Node2D.new()
	root.add_child(scene)
	var bg := ColorRect.new()
	bg.color = Color(1, 1, 1)
	bg.size = Vector2(900, 400)
	scene.add_child(bg)
	var drawer := Node2D.new()
	scene.add_child(drawer)
	var tex512: Texture2D = load("res://assets/origin/mount16.png")
	var tex64: Texture2D = load("res://assets/origin/mount16_64.png")
	print("tex512=", tex512, " tex64=", tex64)
	if tex512:
		print("512 imported alpha? image size=", tex512.get_size())
	drawer.draw.connect(func():
		# 先画抗锯齿折线（复现游戏内的绘制序列）
		var pl := PackedVector2Array([Vector2(20, 380), Vector2(300, 360), Vector2(600, 390)])
		drawer.draw_polyline(pl, Color(0.2, 0.2, 0.2, 0.9), 2.2, true)
		if tex512:
			drawer.draw_texture_rect(tex512, Rect2(30, 60, 240, 240), false, Color(0.25, 0.23, 0.20, 0.85))
		if tex64:
			drawer.draw_texture_rect(tex64, Rect2(320, 60, 240, 240), false, Color(0.25, 0.23, 0.20, 0.85))
		if tex64:
			drawer.draw_texture_rect(tex64, Rect2(610, 60, 240, 240), false, Color(0.25, 0.23, 0.20, 1.0))
		# 小尺寸 + 翻转（与游戏内一致）
		if tex64:
			drawer.draw_set_transform(Vector2(80, 340), 0.0, Vector2(-1, 1))
			drawer.draw_texture_rect(tex64, Rect2(-16, -16, 32, 32), false, Color(0.25, 0.23, 0.20, 0.85))
			drawer.draw_set_transform(Vector2(160, 340), 0.0, Vector2(1, 1))
			drawer.draw_texture_rect(tex64, Rect2(-16, -16, 32, 32), false, Color(0.25, 0.23, 0.20, 0.85))
			drawer.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	)
	drawer.queue_redraw()

func _process(_d: float) -> bool:
	frames += 1
	if frames == 12:
		var img := root.get_viewport().get_texture().get_image()
		img.save_png("user://icon_test.png")
		print("saved: ", ProjectSettings.globalize_path("user://icon_test.png"))
		quit(0)
	return false
