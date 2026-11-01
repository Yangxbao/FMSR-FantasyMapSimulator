extends SceneTree
## 渲染 5 份模板的地图（按原版 cell 数跑 → 最近邻上采样到 480×280），用于与原版实机截图比对形态。
## 运行：godot --headless --path . --script tests/heightmap_templates_dump.gd -- seed=42 [cells=20000]
## 输出：tests/dsl_tpl{0..4}.png

const DSL := preload("res://scripts/heightmap_dsl.gd")
const Tpl := preload("res://scripts/heightmap_template.gd")
const W := 480
const H := 280

func _init() -> void:
	var seed_val := 42
	var cells := 20000
	for a in OS.get_cmdline_user_args():
		if a.begins_with("seed="):
			seed_val = int(a.substr(5))
		elif a.begins_with("cells="):
			cells = int(a.substr(6))
	var p := Tpl.new()
	p.load_all()
	var ratio := sqrt(float(cells) / float(W * H))
	var cw := maxi(8, int(round(float(W) * ratio)))
	var ch := maxi(8, int(round(float(H) * ratio)))
	print("=== 模板高度图渲染 seed=%d cells=%d 网格=%dx%d ===" % [seed_val, cells, cw, ch])
	for t in p.templates:
		var idx: int = int(t["order_seen"])
		var d := DSL.new(seed_val, cw, ch, cells)
		var unknown := d.run_steps(t["steps"])
		var st := d.stats()
		var img := Image.create(W, H, false, Image.FORMAT_RGB8)
		for y in H:
			var cy := clampi(int(float(y) * float(ch) / float(H)), 0, ch - 1)
			for x in W:
				var cx := clampi(int(float(x) * float(cw) / float(W)), 0, cw - 1)
				var v: int = d.heights[cy * cw + cx]
				var g := float(v) / 100.0
				var col: Color
				if v <= DSL.SEA_LEVEL:
					col = Color(0.10 + 0.18 * g, 0.16 + 0.24 * g, 0.34 + 0.30 * g)
				else:
					col = Color(0.30 + 0.62 * g, 0.28 + 0.60 * g, 0.22 + 0.55 * g)
				img.set_pixel(x, y, col)
		var path := "res://tests/dsl_tpl%d.png" % idx
		img.save_png(path)
		print("模板#%d steps=%2d land=%.3f max=%3d mean=%.1f unknown=%s" % [
			idx, t["steps"].size(), st["land_ratio"], st["max"], st["mean"], str(unknown)])
	print("=== 渲染完成 ===")
	quit(0)
