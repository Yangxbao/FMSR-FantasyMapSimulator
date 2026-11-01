extends SceneTree
## 取证：Godot 运行时加载 mount16_64.png 后的真实像素（与 PIL 看到的对比）

func _init() -> void:
	var t: Texture2D = load("res://assets/origin/mount16_64.png")
	print("tex=", t)
	if t == null:
		print("LOAD FAILED")
		quit(1)
		return
	print("size=", t.get_size())
	var img: Image = t.get_image()
	print("image format=", img.get_format(), " size=", img.get_size())
	for p in [Vector2i(0, 0), Vector2i(32, 32), Vector2i(32, 10), Vector2i(10, 40)]:
		print("pixel ", p, " = ", img.get_pixelv(p))
	# 存回 PNG 看实际内容
	img.save_png("user://tex_probe.png")
	print("saved user://tex_probe.png")
	quit(0)
