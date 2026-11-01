extends SceneTree
## 模板 DSL 解析自检：验证 5 份模板正文能被正确切成步骤，且算子集合与反编译一致。
## 运行：godot --headless --path . --script tests/template_parse.gd

const TemplateParser := preload("res://scripts/heightmap_template.gd")

func _init() -> void:
	var p := TemplateParser.new()
	var bad := p.load_all()
	var pass_n := 0
	var fail_n := 0

	# 1) 5 份模板，全部可解析
	if bad == 0:
		push_line("[PASS] 5 份模板全部解析成功")
		pass_n += 1
	else:
		push_line("[FAIL] 有 %d 份模板解析失败" % bad)
		fail_n += 1
	if p.templates.size() == 5:
		push_line("[PASS] 模板数量 = 5")
		pass_n += 1
	else:
		push_line("[FAIL] 模板数量 = %d（应为 5）" % p.templates.size())
		fail_n += 1

	# 2) 每份模板的行数（与 global-metadata.dat 字面量原文一致）
	#    顺序 = 原版 Templates 列表 Add 顺序（2026-10-31 由 ..cctor 机器码证实，见 JSON _verified）：
	#    0=Volcano(6868) 1=High Island(6869) 2=Continents(6866) 3=Continents(6867) 4=Continents(10442)
	var expect_lines := {0: 8, 1: 14, 2: 15, 3: 20, 4: 13}
	for k in expect_lines:
		var t := p.get_template_by_order(k)
		var n: int = t["steps"].size()
		if n == int(expect_lines[k]):
			push_line("[PASS] 模板#%d 步骤数 = %d" % [k, n])
			pass_n += 1
		else:
			push_line("[FAIL] 模板#%d 步骤数 = %d（应为 %d）" % [k, n, expect_lines[k]])
			fail_n += 1

	# 3) 算子集合：正版 9 个，一个不多一个不少
	var ops := p.operator_names()
	var expect_ops := ["Add", "Hill", "Mask", "Multiply", "Pit", "Range", "Smooth", "Strait", "Trough"]
	if ops == expect_ops:
		push_line("[PASS] 算子集合 = %s" % str(expect_ops))
		pass_n += 1
	else:
		push_line("[FAIL] 算子集合 = %s" % str(ops))
		fail_n += 1

	# 4) 每行至少 2 段（原版 addStep 的硬校验）
	var min_ok := true
	for t in p.templates:
		for st in t["steps"]:
			if int(st["args"].size()) < 1:
				min_ok = false
	if min_ok:
		push_line("[PASS] 所有步骤均含算子名 + 至少 1 个参数")
		pass_n += 1
	else:
		push_line("[FAIL] 存在无参数步骤")
		fail_n += 1

	push_line("\n=== template_parse: %d 通过，%d 失败 ===" % [pass_n, fail_n])
	push_line("=== TEMPLATE PARSE ALL PASS ===" if fail_n == 0 else "=== TEMPLATE PARSE FAILED ===")
	quit(0 if fail_n == 0 else 1)

func push_line(s: String) -> void:
	print(s)
