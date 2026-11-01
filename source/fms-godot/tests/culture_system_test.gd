extends SceneTree
## 文化系统自检：cell 级扩张 + 国家归属 + 宗教映射（确定性、真实数据包）。
## 运行：godot --headless --path . --script tests/culture_system_test.gd

const MapGen := preload("res://scripts/mapgen.gd")

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
	var cs = gen._culture_sys
	ok(cs != null, "文化系统已运行")
	var n: int = cs.assignment.size()
	ok(n == gen.W * gen.H, "归属数组覆盖全图 (%d)" % n)
	var land_assigned := 0
	var land_total := 0
	for i in n:
		if gen.is_land[i]:
			land_total += 1
			if cs.assignment[i] >= 0:
				land_assigned += 1
	ok(land_assigned == land_total, "全部陆地格有文化归属 (%d/%d)" % [land_assigned, land_total])
	var used := {}
	for i in n:
		if cs.assignment[i] >= 0:
			used[cs.assignment[i]] = true
	ok(used.size() >= 5, "实际使用的文化数 ≥ 5 (%d)" % used.size())
	ok(cs.culture_ids.size() == 6, "文化实体 = 6 个（7 目录 - WorldII 通用包）")
	ok(cs.culture_display.size() == cs.culture_ids.size(), "显示名与 id 对齐")
	# 国家归属
	var states_ok := true
	for si in gen.states.size():
		var disp: String = cs.state_culture_display(si)
		if disp == "" or disp == "—":
			states_ok = false
	ok(states_ok and gen.states.size() > 0, "全部国家拿到文化显示名 (%d 国)" % gen.states.size())
	# 宗教映射
	var rel_ok := true
	for si2 in gen.states.size():
		if cs.state_religion_display(si2) == "—":
			rel_ok = false
	ok(rel_ok, "全部国家拿到宗教显示名")
	# 确定性：同种子两次生成结果一致
	var gen2 = MapGen.new()
	gen2.generate(6, 42)
	var same := true
	for i in n:
		if gen2._culture_sys.assignment[i] != cs.assignment[i]:
			same = false
			break
	ok(same, "同种子两次生成归属完全一致（确定性）")
	# 不同种子不同结果
	var gen3 = MapGen.new()
	gen3.generate(6, 1337)
	var diff := false
	for i2 in n:
		if gen3._culture_sys.assignment[i2] != cs.assignment[i2]:
			diff = true
			break
	ok(diff, "不同种子归属不同（有随机性）")
	print("\n=== culture_system_test: %d 通过，%d 失败 ===" % [pass_n, fail_n])
	print("=== CULTURE SYSTEM ALL PASS ===" if fail_n == 0 else "=== CULTURE SYSTEM FAILED ===")
	quit(0 if fail_n == 0 else 1)
