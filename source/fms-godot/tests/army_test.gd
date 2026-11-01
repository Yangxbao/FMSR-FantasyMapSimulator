extends SceneTree
## 军队系统自检：编成/动员/推进/真实占领（schema 依据原版存档解密）。
## 运行：godot --headless --path . --script tests/army_test.gd

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
	# 强制初始化全部国家的军队
	for si in gen.states.size():
		sim._init_armies_for_state(si)
	var armies: Array = sim.armies
	ok(armies.size() >= gen.states.size() * 2, "军队已编成 (%d 支 / %d 国)" % [armies.size(), gen.states.size()])
	var types := {}
	for a in armies:
		types[a["army_type"]] = true
	ok(types.has("Garrison") and types.has("BorderGuard") and types.has("FieldArmy"),
		"三种军型齐备 (Garrison/BorderGuard/FieldArmy)")
	var owner_ok := true
	for a2 in armies:
		var si: int = int(a2["state"])
		if si < 0 or si >= gen.states.size():
			owner_ok = false
			break
		var home: int = int(a2["home_province"])
		if home >= 0 and int(gen.provinces[home].get("state", -1)) != si:
			owner_ok = false
			break
	ok(owner_ok, "军队归属国家与 homeProvince 一致")
	# 宣战动员
	sim.declare_war(1, 2, "WarTypeConquest", "TakeCapital")
	var marching := 0
	for a3 in sim.armies:
		if int(a3["state"]) == 1 and str(a3["army_order"]) == "AttackEnemyProvince":
			marching += 1
	ok(marching > 0, "宣战后 1 号国军队进入 AttackEnemyProvince (%d 支)" % marching)
	# 推进 24 个月：军队真实移动 + 可能的占领
	var before_cells := {}
	for a4 in sim.armies:
		before_cells[a4["army_id"]] = int(a4["current_cell"])
	for i in 24:
		sim.tick_month()
	var moved := 0
	var occupied := 0
	for a5 in sim.armies:
		if int(a5["current_cell"]) != int(before_cells.get(a5["army_id"], -1)):
			moved += 1
		if (a5["conquered_provinces_info"] as Array).size() > 0:
			occupied += 1
	ok(moved > 0, "24 个月后有军队真实移动 (%d 支)" % moved)
	print("   [info] 征服过省份的军队: %d 支" % occupied)
	# 存档往返（armies 数组整体）
	sim.save("user://army_test_save.json")
	var gen2 = MapGen.new()
	gen2.generate(6, 42)
	var sim2 = Simulation.new()
	sim2.setup(gen2, 42)
	sim2.load("user://army_test_save.json")
	ok(sim2.armies.size() == armies.size(), "军队经存档往返完整保留 (%d)" % sim2.armies.size())
	print("\n=== army_test: %d 通过，%d 失败 ===" % [pass_n, fail_n])
	print("=== ARMY TEST ALL PASS ===" if fail_n == 0 else "=== ARMY TEST FAILED ===")
	quit(0 if fail_n == 0 else 1)
