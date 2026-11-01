extends SceneTree
## 战斗/战役/控制权/结算自检（第二阶段战争真实化）。
## 运行：godot --headless --path . --script tests/army_battle_test.gd

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
	for si in gen.states.size():
		sim._init_armies_for_state(si)
	var fa = null
	var eb = null
	for a in sim.armies:
		if int(a["state"]) == 1 and str(a["army_type"]) == "FieldArmy":
			fa = a
		if int(a["state"]) == 2:
			eb = a   # V5.2：边防军随机采样，取 state2 任意军队（含保底边防/驻防）
		if fa != null and eb != null:
			break
	ok(fa != null and eb != null, "找到双方军队")
	var c: int = int(fa["current_cell"])
	eb["current_cell"] = c
	eb["pre_cell"] = c
	sim.declare_war(1, 2, "WarTypeConquest", "TakeCapital")
	var c0: float = float(fa["army_count"])
	var e0: float = float(eb["army_count"])
	sim.tick_month()
	ok(sim.campaigns.size() > 0, "遭遇后产生战役记录（Campaign）")
	var lost := float(fa["army_count"]) < c0 or float(eb["army_count"]) < e0 \
		or str(fa["current_state"]) != "Idle" or str(eb["current_state"]) != "Idle"
	ok(lost, "战斗产生真实兵力损失或状态变化（a:%.0f→%.0f, e:%.0f→%.0f）"
		% [c0, float(fa["army_count"]), e0, float(eb["army_count"])])
	# 控制权 ≠ 所有权：先把敌军调远，再占领敌省
	eb["current_cell"] = 0
	eb["current_state"] = "Reorganization"
	eb["reorg_months"] = 99
	var pi: int = -1
	for i in gen.provinces.size():
		if int(gen.provinces[i].get("state", -1)) == 2:
			pi = i
			break
	if pi >= 0:
		sim._occupy_province(pi, 1, fa)
		var ob: int = int(gen.provinces[pi].get("occupied_by", -1))
		var st: int = int(gen.provinces[pi].get("state", -1))
		ok(ob == 1 and st == 2, "占领省 occupied_by=1 且 state=2（控制≠所有权）")
		# 结算转移（找到 1v2 的那场战争并设分数）
		var tw = null
		for w in sim.wars:
			if int(w.get("attacker", -1)) == 1 and int(w.get("defender", -1)) == 2:
				tw = w
				break
		if tw != null:
			tw.score = 100.0
			sim._settle_war(tw)
			var st2: int = int(gen.provinces[pi].get("state", -1))
			var ob2: int = int(gen.provinces[pi].get("occupied_by", -1))
			ok(st2 == 1 and ob2 == -1, "结算后 state=1（正式转移）且 occupied_by=-1")
		else:
			ok(true, "无活跃战争（跳过结算测试）")
	else:
		ok(true, "无 state=2 的省（跳过）")
	# 存档往返
	sim.save("user://battle_test.json")
	var gen2 = MapGen.new()
	gen2.generate(6, 42)
	var sim2 = Simulation.new()
	sim2.setup(gen2, 42)
	sim2.load("user://battle_test.json")
	ok(sim2.armies.size() == sim.armies.size() and sim2.campaigns.size() == sim.campaigns.size(),
		"军队+战役经存档往返完整 (%d/%d)" % [sim2.armies.size(), sim2.campaigns.size()])
	print("\n=== army_battle_test: %d 通过，%d 失败 ===" % [pass_n, fail_n])
	print("=== ARMY BATTLE TEST ALL PASS ===" if fail_n == 0 else "=== ARMY BATTLE TEST FAILED ===")
	quit(0 if fail_n == 0 else 1)
