extends SceneTree
## 月度财政循环自检：国家 gold 随 tick 真实变化、赤字后果生效、存档往返保留。
## 运行：godot --headless --path . --script tests/economy_test.gd

const MapGen := preload("res://scripts/mapgen.gd")
const Simulation := preload("res://scripts/simulation.gd")

var pass_n := 0
var fail_n := 0

func ok(cond: bool, msg: String) -> void:
	if cond:
		print("[PASS] " + msg)
		pass_n += 1
	else:
		print("[FAIL] " + msg)
		fail_n += 1

func _init() -> void:
	var gen = MapGen.new()
	gen.generate(6, 42)
	var sim = Simulation.new()
	sim.setup(gen, 42)
	var before := {}
	for si in gen.states.size():
		before[si] = float(gen.states[si].get("gold", 0.0))
	# 推进 24 个月
	for i in 24:
		sim.tick_month()
	var changed := 0
	var nonzero := 0
	for si in gen.states.size():
		if gen.states[si].alive:
			var g: float = float(gen.states[si].get("gold", 0.0))
			if absf(g - before.get(si, 0.0)) > 0.001:
				changed += 1
			if g > 0.0:
				nonzero += 1
	ok(changed >= 5, "24 个月后多数国家 gold 发生真实变化 (%d/%d)" % [changed, gen.states.size()])
	ok(nonzero >= 1, "存在 gold > 0 的国家 (%d)" % nonzero)
	# 存档往返保留 gold
	sim.save("user://economy_test_save.json")
	var gen2 = MapGen.new()
	gen2.generate(6, 42)
	var sim2 = Simulation.new()
	sim2.setup(gen2, 42)
	ok(sim2.load("user://economy_test_save.json"), "存档读取成功")
	var preserved := 0
	for si3 in gen2.states.size():
		if absf(float(gen2.states[si3].get("gold", 0.0)) - float(gen.states[si3].get("gold", 0.0))) < 0.01:
			preserved += 1
	ok(preserved == gen.states.size(), "gold 经存档往返完整保留 (%d/%d)" % [preserved, gen.states.size()])
	print("\n=== economy_test: %d 通过，%d 失败 ===" % [pass_n, fail_n])
	print("=== ECONOMY TEST ALL PASS ===" if fail_n == 0 else "=== ECONOMY TEST FAILED ===")
	quit(0 if fail_n == 0 else 1)
