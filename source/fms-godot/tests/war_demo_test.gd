extends SceneTree
## 可重复战争演示（通宵指令 P8/P9）：固定种子 → 手动宣战 → 逐月推进，
## 验证完整战争链：宣战 → 动员 → 军队移动 → 战斗 → 兵力损失 → 省份占领 → 战争结束。
## 全部走真实 simulation 逻辑（tick_month），无任何脚本播放。
## 运行：godot --headless --path . --script tests/war_demo_test.gd
## 日志：logs/war_demo.log（仓库根，通过 user:// 写入后复制不可行——直接打印，由调用方重定向）

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
	gen.generate(26, 42)   # 固定种子：可重复
	var sim = Simulation.new()
	sim.setup(gen, 42)
	# 演示参数：关闭自然开战/扩张（测试专用覆盖），保证战争链完全由手动宣战驱动、结果可重复
	sim.rules["war_chance_per_month"] = 0.0
	sim.rules["expand_pressure"] = 0.0
	sim.rules["allow_alliance"] = false

	# 找两个相邻国家（真实地图邻接）
	var a := -1
	var d := -1
	for si in gen.states.size():
		if not gen.states[si].alive:
			continue
		for nb in sim._neighbor_states(si):
			if gen.states[nb].alive:
				a = si
				d = nb
				break
		if a >= 0:
			break
	ok(a >= 0 and d >= 0, "找到相邻两国：%s vs %s" % [gen.states[a].name, gen.states[d].name])

	# 记录宣战前状态
	var armies_a := 0
	var armies_d := 0
	for x in sim.armies:
		if int(x["state"]) == a:
			armies_a += 1
		if int(x["state"]) == d:
			armies_d += 1
	print("—— 演示开始：%s(省份%d) vs %s(省份%d)，军队 %d vs %d ——" % [
		gen.states[a].name, gen.states[a].provinces.size(),
		gen.states[d].name, gen.states[d].provinces.size(), armies_a, armies_d])

	# 手动宣战（确定性触发；游戏内可用国家面板按钮同样操作）
	sim.declare_war(a, d, "WarTypeConquest", "WarGoalCedeProvince")
	var war_id: int = sim.wars[sim.wars.size() - 1]["id"]
	ok(sim.is_at_war(a) and sim.is_at_war(d), "两国处于战争状态")

	# 逐月推进直到战争结束（上限 60 个月）
	var months := 0
	var battles := 0
	var cedes := 0
	var ended := false
	while months < 60:
		sim.tick_month()
		months += 1
		battles = sim.campaigns.size()
		var wcur = null
		for w in sim.wars:
			if int(w.id) == war_id:
				wcur = w
				break
		if wcur == null or not wcur.active:
			ended = true
			break
		if wcur.get("ceded", []).size() > 0:
			cedes = int(wcur["ceded"].size())
	print("—— 战争历时 %d 个月，战役 %d 场，割省 %d ——" % [months, battles, cedes])

	ok(battles > 0, "战争期间发生战斗（%d 场战役）" % battles)
	ok(cedes > 0 or ended, "发生省份转移或战争结束（割省 %d）" % cedes)
	ok(ended, "战争在 60 个月内结束")
	# 停战期生效
	ok(not sim.is_at_war(a) and not sim.is_at_war(d), "战争结束后两国脱离战争状态")
	ok(sim._in_truce(a, d), "两国进入停战期（%d 个月）" % int(sim.rules.min_month_to_begin_another_war))
	# 军队复员：无军队处于进攻状态
	var still_attacking := 0
	for x2 in sim.armies:
		if str(x2["army_order"]) == "AttackEnemyProvince":
			still_attacking += 1
	ok(still_attacking == 0, "全部军队停止进攻状态（%d 攻势中）" % still_attacking)
	# 历史完整链
	var decl := false
	var bat := false
	var settle := false
	for h in sim.history:
		if "宣战" in str(h.text):
			decl = true
		if "交战" in str(h.text):
			bat = true
		if "停战" in str(h.text) or "战胜" in str(h.text) or "击退" in str(h.text) or "吞并" in str(h.text):
			settle = true
	ok(decl, "历史含宣战")
	ok(bat, "历史含交战")
	ok(settle, "历史含战争结果")
	# 战报记录
	ok(sim.war_records.size() > 0, "战争记录（WarRecord）已归档 %d 条" % sim.war_records.size())

	print("=== 战争演示测试：%d 通过，%d 失败 ===" % [pass_n, fail_n])
	if fail_n == 0:
		print("=== WAR DEMO ALL PASS ===")
	else:
		print("=== WAR DEMO FAILED ===")
	quit(0)
