extends SceneTree
## 地图可视化导出：把指定种子的省份/国家着色为 PNG，供人工检查
## godot --headless --path . --script tests/mapdump.gd -- seed=1337

func _init() -> void:
	var seed_val := 1337
	var mode := "state"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("seed="):
			seed_val = int(a.split("=")[1])
		elif a.begins_with("mode="):
			mode = a.split("=")[1]
	var gen := MapGen.new()
	gen.generate(26, seed_val)
	var W := MapGen.W
	var H := MapGen.H
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	var prov_cols: Array[Color] = []
	for pi in gen.provinces.size():
		prov_cols.append(Color.from_hsv(fmod(float(pi) * 0.61803398875, 1.0), 0.55, 0.92))
	for y in H:
		for x in W:
			var i := y * W + x
			var col := Color(0.93, 0.88, 0.75)
			var pi: int = gen.cell_province[i]
			if gen.is_land[i] == 0:
				# 海域：有海域省的格用蓝色系区分（核对 CreateSeaProvinces 的划分）
				if pi >= 0:
					var hue := 0.52 + fmod(float(pi) * 0.137, 0.09)
					col = Color.from_hsv(hue, 0.28, 0.80)
			elif pi >= 0:
				if mode == "prov":
					col = prov_cols[pi % prov_cols.size()]
				else:
					var s: int = gen.provinces[pi].state
					if s >= 0 and s < gen.states.size():
						col = gen.states[s].color
						col = Color(col.r, col.g, col.b, 1.0)
					else:
						col = Color(0.8, 0.2, 0.2)
			else:
				col = Color(0.1, 0.1, 0.1)
			img.set_pixel(x, y, col)
	var path := "user://map_%s_seed%d.png" % [mode, seed_val]
	img.save_png(path)
	print("saved: ", ProjectSettings.globalize_path(path))
	print("provinces=", gen.provinces.size(), " states=", gen.states.size())
	gen._label_landmasses()
	var lm_sizes := {}
	for p in gen.provinces:
		var lm: int = p.landmass
		lm_sizes[lm] = int(lm_sizes.get(lm, 0)) + p.cells.size()
	var big := 0
	var small := 0
	for lm in lm_sizes:
		if lm_sizes[lm] >= 200:
			big += 1
		else:
			small += 1
	print("landmasses: big(>=200 province cells)=", big, " small=", small)
	quit(0)
