extends SceneTree
## 诊断脚本（临时）：blob_power / line_power 敏感性扫描 —— 模板#3 (6867) 陆地占比随幂值变化
## 只读实验，不改任何产品代码。运行：godot --headless --path . --script tests/power_sweep.gd

const DSL := preload("res://scripts/heightmap_dsl.gd")
const Tpl := preload("res://scripts/heightmap_template.gd")

func _init() -> void:
	var p := Tpl.new()
	p.load_all()
	var t := p.get_template_by_order(3)
	for bp in [0.90, 0.93, 0.95, 0.97, 0.98, 0.99]:
		var row := []
		for seed_v in [42, 1337, 2026]:
			var d := DSL.new(seed_v, 185, 108, 20000)
			d.blob_power = bp
			d.line_power = 0.82
			d.run_steps(t["steps"])
			var st := d.stats()
			row.append("%.2f" % st["land_ratio"])
		print("blob_power=%.2f  land: seed42=%s 1337=%s 2026=%s" % [bp, row[0], row[1], row[2]])
	for lp in [0.75, 0.82, 0.90]:
		var row2 := []
		for seed_v in [42]:
			var d2 := DSL.new(seed_v, 185, 108, 20000)
			d2.blob_power = 0.99
			d2.line_power = lp
			d2.run_steps(t["steps"])
			row2.append("%.2f" % d2.stats()["land_ratio"])
		print("line_power=%s (bp=0.99, seed42) land=%s" % ["%.2f" % lp, row2[0]])
	quit(0)
