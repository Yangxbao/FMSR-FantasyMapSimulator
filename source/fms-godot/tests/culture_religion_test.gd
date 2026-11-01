extends SceneTree
## 文化/宗教数据层自检：验证原版数据包（已复制进 assets/origin）能被完整加载与解析。
## 数据 = 原版文件逐字节复制（真）；本测试不涉及分配规则（规则在 mapgen，另有标注）。
## 运行：godot --headless --path . --script tests/culture_religion_test.gd

const CulturePacks := preload("res://scripts/culture_pack.gd")
const ReligionPacks := preload("res://scripts/religion_pack.gd")

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
	var packs = CulturePacks.new()
	packs.load_all()
	_test_cultures(packs)
	_test_religions()
	print("\n=== culture_religion_test: %d 通过，%d 失败 ===" % [pass_n, fail_n])
	print("=== CULTURE RELIGION TEST ALL PASS ===" if fail_n == 0 else "=== CULTURE RELIGION TEST FAILED ===")
	quit(0 if fail_n == 0 else 1)

func _test_cultures(packs) -> void:
	ok(packs.cultures.size() == 7, "文化目录数量 = 7 (%d)" % packs.cultures.size())
	var names := ["Ciestundu", "EasternFantasy", "Leffathou", "Oeczea", "WesternFantasy", "WorldII", "Wristhos"]
	var all_present := true
	var with_data := 0
	for n in names:
		if not packs.cultures.has(n):
			all_present = false
		elif bool(packs.cultures[n].get("has_culture_data", false)):
			with_data += 1
	ok(all_present, "七个原版文化目录全部加载")
	ok(with_data == 6, "含 CultureData.json 的文化 = 6 (%d)" % with_data)
	var c: Dictionary = packs.cultures.get("Ciestundu", {})
	ok(str(c.get("color_hex", "")) == "#fb8072", "Ciestundu 颜色 = #fb8072")
	var probs: Dictionary = c.get("political_system_probabilities", {})
	ok(int(probs.get("Kingdom", 0)) == 70, "Ciestundu Kingdom 概率 = 70")
	ok(int(probs.get("Theocracy", 0)) == 40, "Ciestundu Theocracy 概率 = 40")
	ok(str(c.get("desc_zh", "")).length() > 20, "Ciestundu 中文描述已加载 (%d 字)" % str(c.get("desc_zh", "")).length())
	ok(str(c.get("display_zh", "")).length() > 0 and str(c.get("display_zh", "")) != "Ciestundu",
		"Ciestundu 显示名（MapCultureTranslations[0]）非空且非目录名 = %s" % c.get("display_zh", ""))
	var ef: Dictionary = packs.cultures.get("EasternFantasy", {})
	ok(ef.get("official_titles", {}) is Dictionary and not (ef.get("official_titles", {}) as Dictionary).is_empty(),
		"EasternFantasy OfficialTitles 已加载")
	var ts: Dictionary = c.get("trait_probabilities", {})
	ok(ts.size() >= 13, "Ciestundu TraitProbabilities ≥ 13 项 (%d)" % ts.size())
	var wi: Dictionary = packs.cultures.get("WorldII", {})
	ok(bool(wi.get("has_culture_data", true)) == false, "WorldII 为通用名字包（无 CultureData.json）")
	ok((wi.get("political_systems", []) as Array).size() == 6, "WorldII PoliticalSystems.json = 6 制度")
	ok((wi.get("state_names", []) as Array).size() > 0, "WorldII StateNames 非空")
	var all_names_ok := true
	for id in packs.cultures:
		var e: Dictionary = packs.cultures[id]
		if (e["state_names"] as Array).is_empty() or (e["city_names"] as Array).is_empty():
			all_names_ok = false
		if bool(e.get("has_culture_data", false)):
			if (e["male_names"] as Array).is_empty() or (e["female_names"] as Array).is_empty() \
				or (e["last_names"] as Array).is_empty():
				all_names_ok = false
	ok(all_names_ok, "文化包 4 类名字非空；WorldII 通用包仅要求州名/城市名")
	# 加权工具
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var hits := {}
	for i in 200:
		hits[packs.weighted_pick(probs, rng)] = true
	var only_valid := true
	for k in hits:
		if not probs.has(k):
			only_valid = false
	ok(only_valid and hits.size() >= 3, "weighted_pick 只返回表中键且多键可达（%d 键）" % hits.size())
	var det: Dictionary = {"Always": 100.0, "Never": 0.0}
	ok(packs.weighted_pick(det, rng) == "Always", "weighted_pick 概率 0 的键不可达")

func _test_religions() -> void:
	var rp = ReligionPacks.new()
	rp.load_all()
	ok(rp.packs.size() == 3, "宗教包数量 = 3 (%d)" % rp.packs.size())
	var allp := ["Atheism", "FantasyReligion", "ReligionRealWorld"]
	var all_ok := true
	for p in allp:
		if not rp.packs.has(p):
			all_ok = false
	ok(all_ok, "三个原版宗教包全部加载")
	var fr: Dictionary = rp.packs.get("FantasyReligion", {})
	var rels: Array = fr.get("religions", [])
	ok(rels.size() >= 4, "FantasyReligion ≥ 4 宗教 (%d)" % rels.size())
	var first: Dictionary = rels[0] if rels.size() > 0 else {}
	ok(str(first.get("book_zh", "")).length() > 0, "FantasyReligion[0] 圣典中文名已本地化 = %s" % first.get("book_zh", ""))
	ok(str(first.get("desc_zh", "")).length() > 10, "FantasyReligion[0] 描述已本地化")
	var flat: Array = rp.all_religions()
	ok(flat.size() >= 6, "跨包宗教总数 ≥ 6 (%d)" % flat.size())
	var colored := true
	for r in flat:
		if str(r.get("color_hex", "")).begins_with("#") == false:
			colored = false
	ok(colored, "全部宗教带颜色值")
