extends SceneTree
## 性能探针：逐 tick 计时定位慢点
const MapGen := preload("res://scripts/mapgen.gd")
const Simulation := preload("res://scripts/simulation.gd")

func _init() -> void:
	var gen = MapGen.new()
	var t0 := Time.get_ticks_msec()
	gen.generate(26, 42)
	print("generate: %d ms" % (Time.get_ticks_msec() - t0))
	print("[probe] creating Simulation...")
	var sim = Simulation.new()
	print("[probe] Simulation created")
	t0 = Time.get_ticks_msec()
	sim.setup(gen, 42)
	print("[probe] setup returned")
	print("setup: %d ms (armies=%d)" % [Time.get_ticks_msec() - t0, sim.armies.size()])
	for m in 12:
		t0 = Time.get_ticks_msec()
		sim.tick_month()
		print("tick %02d: %d ms (wars=%d armies=%d)" % [m, Time.get_ticks_msec() - t0, sim.wars.size(), sim.armies.size()])
	# 确定性单测：80 岁领袖必死 + 继承（P6 领袖生命周期）
	var sim3 = Simulation.new()
	var gen3 = MapGen.new()
	gen3.generate(26, 99)
	sim3.setup(gen3, 99)
	var test_st = gen3.states[0]
	test_st.leader = {"name": "测试寿星", "gender": "男", "age": 80}
	sim3.month = 2   # 非年初，跳过 +1 岁
	var alive_before: bool = test_st.alive
	sim3._leader_tick()
	var nk: Dictionary = test_st.get("leader", {})
	print("[probe] leader-test: alive=%s old=测试寿星 new=%s age=%d died=%s" % [
		str(alive_before), str(nk.get("name", "?")), int(nk.get("age", 0)), str(str(nk.get("name","")) != "测试寿星")])
	var leader_events := 0
	for h in sim.history:
		if "领袖" in str(h.text):
			leader_events += 1
	print("[probe] 领袖事件: %d / 历史总数 %d" % [leader_events, sim.history.size()])
	for h in sim.history:
		if "领袖" in str(h.text):
			print("   ", h.date, " ", h.text)
	quit(0)
