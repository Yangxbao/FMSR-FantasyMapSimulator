extends SceneTree
## 月度世界模拟闭环测试（通宵指令 P9）：连续 24 个月多国模拟，
## 验证战争发生/军队移动/战斗/占领/历史记录/数据健全性/存档续延。
## 运行：godot --headless --path . --script tests/monthly_sim_test.gd

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
	# 加速战争触发（测试专用参数覆盖：rules 是真实模拟读取的唯一参数面）
	sim.rules["war_chance_per_month"] = 0.5
	sim.rules["expand_pressure"] = 0.3
	sim.rules["max_war_duration_months"] = 36

	ok(sim.armies.size() > 0, "真实模拟中军队实体已初始化（%d 支）" % sim.armies.size())
	var field_armies := 0
	for a in sim.armies:
		if str(a["army_type"]) == "FieldArmy":
			field_armies += 1
	ok(field_armies >= gen.states.size() / 2, "野战军数量合理（%d 支）" % field_armies)

	var start_gold: Dictionary = {}
	for si in gen.states.size():
		start_gold[si] = float(gen.states[si].get("gold", 0.0))
	var init_cells: Dictionary = {}
	for a in sim.armies:
		init_cells[int(a["army_id"])] = int(a["current_cell"])

	# ---- 连续 36 个月模拟（V5.2：原版 minMonthBeforeWarEnd=24，前 24 月不结算 → 需更长窗口观察割省）----
	var war_seen := false
	var battle_seen := false
	var occupy_seen := false
	var move_seen := false
	var death_seen := false
	for m in 36:
		sim.tick_month()
		if sim.wars.size() > 0:
			war_seen = true
		if sim.campaigns.size() > 0:
			battle_seen = true
		for w in sim.wars:
			if int(w.get("ceded", []).size()) > 0:
				occupy_seen = true
		for a in sim.armies:
			if int(init_cells.get(int(a["army_id"]), -1)) != int(a["current_cell"]):
				move_seen = true
		for st in gen.states:
			if not st.alive:
				death_seen = true
	print("—— 24 个月结果：wars=%d campaigns=%d records=%d 灭亡=%s ——" % [
		sim.wars.size(), sim.campaigns.size(), sim.war_records.size(), str(death_seen)])

	ok(war_seen, "36 个月内发生过战争")
	ok(move_seen, "有军队发生移动")
	ok(battle_seen, "发生过战斗（Campaign 记录 %d）" % sim.campaigns.size())
	ok(occupy_seen, "发生过领土转移（ceded 记录）")
	ok(sim.history.size() > 10, "历史记录持续累积（%d 条）" % sim.history.size())
	var war_text := false
	var battle_text := false
	for h in sim.history:
		if "宣战" in str(h.text):
			war_text = true
		if "交战" in str(h.text):
			battle_text = true
	ok(war_text, "历史含宣战事件")
	ok(battle_text, "历史含交战事件")

	# ---- 数据健全性 ----
	var sane := true
	for st in gen.states:
		if float(st.get("gold", 0.0)) < 0.0 or is_nan(float(st.get("gold", 0.0))):
			sane = false
		for pi in st.provinces:
			if int(gen.provinces[pi].pop) < 0:
				sane = false
	for a in sim.armies:
		var c: float = float(a["army_count"])
		if c < 0.0 and str(a["current_state"]) != "Destroyed":
			sane = false
		if is_nan(c):
			sane = false
		var pi2: int = int(gen.cell_province[int(a["current_cell"])])
		if pi2 < 0 or pi2 >= gen.provinces.size():
			sane = false
	ok(sane, "财政/人口/军队数据健全（无负数/NaN/越界）")

	# 灭亡清理一致性：灭亡国家的军队必须全部 Destroyed
	var dead_ok := true
	for si in gen.states.size():
		if not gen.states[si].alive:
			for a in sim.armies:
				if int(a["state"]) == si and str(a["current_state"]) != "Destroyed":
					dead_ok = false
					print("[diag] 亡国 si=%d 军队 #%d state=%s count=%.0f" % [
						si, int(a["army_id"]), str(a["current_state"]), float(a["army_count"])])
	ok(dead_ok, "灭亡国家军队全部覆灭标记")

	# 财政真实变化：至少一半存活国家的 gold 与开局不同
	var changed := 0
	var alive_n := 0
	for si in gen.states.size():
		if not gen.states[si].alive:
			continue
		alive_n += 1
		if absf(float(gen.states[si].get("gold", 0.0)) - float(start_gold[si])) > 0.01:
			changed += 1
	ok(changed >= alive_n / 2, "国家财政发生真实变化（%d/%d 国）" % [changed, alive_n])

	# ---- 存档 → 读档 → 继续 6 个月 ----
	var save_path := "user://test_monthly_save.json"
	ok(sim.save(save_path), "存档成功")
	var year_before: int = sim.year
	var armies_before: int = sim.armies.size()
	var sim2 = Simulation.new()
	var gen2 = MapGen.new()
	gen2.generate(26, 42)
	sim2.setup(gen2, 42)
	ok(sim2.load(save_path), "读档成功")
	ok(sim2.year == year_before and sim2.armies.size() == armies_before,
		"读档后时间/军队数一致（%d 年, %d 支）" % [sim2.year, sim2.armies.size()])
	var id_seen := {}
	var id_unique := true
	for a in sim2.armies:
		if id_seen.has(int(a["army_id"])):
			id_unique = false
		id_seen[int(a["army_id"])] = true
	ok(id_unique, "读档后军队 ID 无重复")
	var history_len: int = sim2.history.size()
	for m2 in 6:
		sim2.tick_month()
	ok(sim2.history.size() > history_len, "读档后世界继续演进（历史 %d→%d）" % [history_len, sim2.history.size()])
	var sane2 := true
	for st2 in gen2.states:
		if float(st2.get("gold", 0.0)) < 0.0 or is_nan(float(st2.get("gold", 0.0))):
			sane2 = false
	ok(sane2, "续延模拟数据健全")

	# ---- 领袖生命周期（P6）：80 岁必死 + 原版文化包名字继承 + 历史记录 ----
	var gen3 = MapGen.new()
	gen3.generate(26, 99)
	var sim3 = Simulation.new()
	sim3.setup(gen3, 99)
	var test_st = gen3.states[0]
	test_st.leader = {"name": "测试寿星", "gender": "男", "age": 80}
	sim3.month = 2
	sim3._leader_tick()
	var nk: Dictionary = test_st.get("leader", {})
	ok(str(nk.get("name", "")) != "测试寿星" and str(nk.get("name", "")) != "",
		"80 岁领袖死亡并由原版名字池继承（新领袖：%s，%d 岁）" % [str(nk.get("name", "?")), int(nk.get("age", 0))])
	var leader_hist := false
	for h in sim3.history:
		if "领袖" in str(h.text) and "去世" in str(h.text):
			leader_hist = true
	ok(leader_hist, "领袖死亡写入历史记录")
	# 存档往返含领袖
	ok(sim3.save("user://test_leader_save.json"), "领袖存档成功")
	var sim4 = Simulation.new()
	var gen4 = MapGen.new()
	gen4.generate(26, 99)
	sim4.setup(gen4, 99)
	sim4.load("user://test_leader_save.json")
	ok(str(gen4.states[0].get("leader", {}).get("name", "")) == str(nk.get("name", "")),
		"领袖经存档往返一致（%s）" % str(gen4.states[0].get("leader", {}).get("name", "?")))

	print("=== 月度模拟测试：%d 通过，%d 失败 ===" % [pass_n, fail_n])
	if fail_n == 0:
		print("=== MONTHLY SIM ALL PASS ===")
	else:
		print("=== MONTHLY SIM FAILED ===")
	quit(0)
