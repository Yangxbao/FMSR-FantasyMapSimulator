extends SceneTree
## 玩家交互后端测试（V5.1 P0）：宣战对象选择 / 战争目标 / 结盟 / 退出同盟 / 军队部署。
## 全部走真实 simulation 后端（declare_war_player / make_alliance_player / deposit_army）。
## 运行：godot --headless --path . --script tests/player_action_test.gd

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
	gen.generate(26, 42)
	var sim = Simulation.new()
	sim.setup(gen, 42)
	sim.rules["war_chance_per_month"] = 0.0
	sim.rules["expand_pressure"] = 0.0
	sim.rules["allow_alliance"] = true

	# ---- 宣战对象选择（面板逻辑的后端等价）----
	var targets := sim._neighbor_states(0)
	ok(targets.size() > 0, "国家 0 有可宣战邻国（%d 个）" % targets.size())
	var ti: int = int(targets[0])
	# 非法：不相邻国家
	var far := -1
	for si in gen.states.size():
		if si != 0 and not sim._neighbor_states(0).has(si) and gen.states[si].alive:
			far = si
			break
	if far >= 0:
		var msg_far: String = sim.declare_war_player(0, far, "WarGoalCedeProvince")
		ok("不相邻" in msg_far, "不相邻宣战被拒绝（%s）" % msg_far)
	# 非法：停战期（先打一场再结算）
	sim.declare_war(0, ti, "WarTypeConquest", "WarGoalCedeProvince")
	var wid: int = sim.wars[sim.wars.size() - 1]["id"]
	for w in sim.wars:
		if int(w.id) == wid:
			w.score = 100.0
			sim._settle_war(w)
	ok(sim._in_truce(0, ti), "战后进入停战期")
	var msg_truce: String = sim.declare_war_player(0, ti, "WarGoalCedeProvince")
	ok("停战" in msg_truce, "停战期宣战被拒绝（%s）" % msg_truce)
	# 合法：选另一个邻国 + 指定战争目标
	var ti2 := -1
	for t2 in sim._neighbor_states(0):
		var t2i: int = int(t2)
		if t2i != ti and not sim._in_truce(0, t2i) and not sim.is_at_war(0):
			ti2 = t2i
			break
	if ti2 >= 0:
		var armies_before: int = sim.armies.size()
		var msg: String = sim.declare_war_player(0, ti2, "WarGoalAnnex")
		ok("宣战" in msg, "自主宣战成功（%s）" % msg)
		ok(sim.wars[sim.wars.size() - 1]["goal"] == "WarGoalAnnex", "战争目标=玩家所选（Annex）")
		ok(sim.armies.size() > armies_before, "宣战动员新增军队（%d→%d）" % [armies_before, sim.armies.size()])
		sim.rules["war_chance_per_month"] = 0.0

	# ---- 结盟选择（用未参战国家对：任意 alive 且非战且互邻的一对）----
	var si_a := -1
	var ai := -1
	for sa in gen.states.size():
		if not gen.states[sa].alive or sim.is_at_war(sa):
			continue
		for t3 in sim._neighbor_states(sa):
			var t3i: int = int(t3)
			if t3i > sa and gen.states[t3i].alive and not sim.is_at_war(t3i) \
					and not (gen.states[sa].get("allies", []) as Array).has(t3i):
				si_a = sa
				ai = t3i
				break
		if si_a >= 0:
			break
	if ai >= 0:
		var msg_a: String = sim.make_alliance_player(si_a, ai)
		ok("同盟" in msg_a, "自主结盟成功（%s）" % msg_a)
		ok((gen.states[ai].get("allies", []) as Array).has(si_a), "对方盟友列表包含本国")
		var msg_break: String = sim.break_alliance_player(si_a, ai)
		ok("解除" in msg_break, "退出同盟成功（%s）" % msg_break)
		ok(not (gen.states[ai].get("allies", []) as Array).has(si_a), "退出后对方列表已移除")
	else:
		ok(false, "找不到可结盟邻国（跳过结盟断言）")

	# ---- 军队部署 ----
	var home_prov: int = int(gen.states[0].capital)
	var armies0: int = sim.armies.size()
	var msg_d: String = sim.deposit_army(0, home_prov, 2)
	ok("部署" in msg_d, "本国领土部署成功（%s）" % msg_d)
	ok(sim.armies.size() == armies0 + 2, "部署新增 2 支军队实体")
	var new_army: Dictionary = sim.armies[sim.armies.size() - 1]
	ok(str(new_army["army_type"]) == "FieldArmy" and int(new_army["home_province"]) == home_prov
		and float(new_army["army_count"]) == 200.0, "部署军队字段正确（FieldArmy/200/该省）")
	# 非法：外国领土
	var foe_prov := -1
	for pi in gen.provinces.size():
		var os: int = int(gen.provinces[pi].get("state", -1))
		if os >= 0 and os != 0 and gen.states[os].alive:
			foe_prov = pi
			break
	var msg_f: String = sim.deposit_army(0, foe_prov, 1)
	ok("只能在本国" in msg_f, "外国领土部署被拒绝（%s）" % msg_f)
	# 部署后军队参与存档往返
	ok(sim.save("user://test_player_save.json"), "存档成功")
	var sim2 = Simulation.new()
	var gen2 = MapGen.new()
	gen2.generate(26, 42)
	sim2.setup(gen2, 42)
	sim2.load("user://test_player_save.json")
	ok(sim2.armies.size() == sim.armies.size(), "部署军队经存档往返一致（%d）" % sim2.armies.size())

	print("=== 玩家交互测试：%d 通过，%d 失败 ===" % [pass_n, fail_n])
	if fail_n == 0:
		print("=== PLAYER ACTION ALL PASS ===")
	else:
		print("=== PLAYER ACTION FAILED ===")
	quit(0)
