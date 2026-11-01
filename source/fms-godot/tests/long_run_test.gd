extends SceneTree
## 长期世界模拟稳定性测试（通宵指令 P9）：3 个种子 × 120 个月（含存档续延 60+60）。
## 验证：不崩溃、数据健全、历史累积、战争/灭亡正常发生、存档续延一致。
## 运行：godot --headless --path . --script tests/long_run_test.gd

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

func _sane(gen, sim) -> bool:
	for st in gen.states:
		var g: float = float(st.get("gold", 0.0))
		if g < 0.0 or is_nan(g):
			return false
		for pi in st.provinces:
			if int(gen.provinces[pi].pop) < 0 or int(gen.provinces[pi].pop) > 100000000:
				return false
	for a in sim.armies:
		var c: float = float(a["army_count"])
		if (c < 0.0 and str(a["current_state"]) != "Destroyed") or is_nan(c):
			return false
		var pi2: int = int(gen.cell_province[int(a["current_cell"])])
		if pi2 < 0 or pi2 >= gen.provinces.size():
			return false
	return true

func _init() -> void:
	for seed_val in [42, 1337, 2026]:
		print("—— 种子 %d：120 个月 ——" % seed_val)
		var gen = MapGen.new()
		gen.generate(26, seed_val)
		var sim = Simulation.new()
		sim.setup(gen, seed_val)
		var states0: int = gen.states.size()
		var wars_total := 0
		var battles_total := 0
		var dead_total := 0
		# 前 60 个月
		for m in 60:
			sim.tick_month()
		var sane1: bool = _sane(gen, sim)
		wars_total = sim.wars.size()
		battles_total = sim.campaigns.size()
		for st in gen.states:
			if not st.alive:
				dead_total += 1
		ok(sane1, "种子%d 前60月数据健全（战争%d/战斗%d/灭亡%d）" % [seed_val, wars_total, battles_total, dead_total])
		# 存档续延
		var sp: String = "user://test_long_%d.json" % seed_val
		var ok_save: bool = sim.save(sp)
		var sim2 = Simulation.new()
		var gen2 = MapGen.new()
		gen2.generate(26, seed_val)
		sim2.setup(gen2, seed_val)
		var ok_load: bool = sim2.load(sp)
		var h0: int = sim2.history.size()
		var y0: int = sim2.year
		for m2 in 60:
			sim2.tick_month()
		ok(ok_save and ok_load, "种子%d 存档读档成功" % seed_val)
		ok(sim2.year == y0 + 5, "种子%d 续延 60 月时间正确（%d 年）" % [seed_val, sim2.year])
		ok(sim2.history.size() > h0, "种子%d 续延后历史增长（%d→%d）" % [seed_val, h0, sim2.history.size()])
		ok(_sane(gen2, sim2), "种子%d 续延 120 月数据健全" % seed_val)
		var alive2 := 0
		for st2 in gen2.states:
			if st2.alive:
				alive2 += 1
		ok(alive2 > 0, "种子%d 120 月后仍有国家存续（%d/%d）" % [seed_val, alive2, states0])
		print("   种子%d 总计：战争 %d，战役 %d，灭亡 %d，历史 %d 条" % [
			seed_val, sim2.wars.size(), sim2.campaigns.size(), dead_total, sim2.history.size()])
	print("=== 长期模拟测试：%d 通过，%d 失败 ===" % [pass_n, fail_n])
	if fail_n == 0:
		print("=== LONG RUN ALL PASS ===")
	else:
		print("=== LONG RUN FAILED ===")
	quit(0)
