extends RefCounted
## 原版文化包加载器（数据层）
##
## 【数据来源】原版 StreamingAssets/Base/Culture/<文化名>/ 已复制为 assets/origin/Culture/
##   （CultureData.json + 5 份 15 列 CSV：StateNames/CityNames/CharacterFirstNames_Male/
##    CharacterFirstNames_Female/CharacterLastNames）。文件内容逐字节来自原版。
##
## 【证据边界】
##   - 数据结构与取值 = 原版文件实测（真）。
##   - 「文化如何分配给国家 / 概率表如何被使用」的原版规则在 CultureGenerator/MapCultureManager
##     （反编译待做）。本类只提供数据与加权工具；当前 mapgen 的均匀随机分配是**重建版自定规则**，
##     已在调用处显式标注，不得当作原版行为引用。

const CULTURE_DIR := "res://assets/origin/Culture"

var cultures := {}   ## dir_name -> entry（见 load_all 注释）
var order := []      ## dir_name 顺序（稳定遍历用）
var _loaded := false

## 读取全部文化包。返回解析失败的包数（正常 0）。
func load_all() -> int:
	if _loaded:
		return 0
	var dir := DirAccess.open(CULTURE_DIR)
	if dir == null:
		push_error("文化包目录缺失: " + CULTURE_DIR)
		return -1
	var bad := 0
	dir.list_dir_begin()
	var sub := dir.get_next()
	while sub != "":
		if dir.current_is_dir() and not sub.begins_with("."):
			var entry := _load_one(sub)
			if entry.is_empty():
				bad += 1
			else:
				cultures[sub] = entry
				order.append(sub)
		sub = dir.get_next()
	dir.list_dir_end()
	_loaded = true
	return bad

func _load_one(id: String) -> Dictionary:
	var jpath := CULTURE_DIR + "/" + id + "/CultureData.json"
	var f := FileAccess.open(jpath, FileAccess.READ)
	if f == null:
		## 特例：WorldII 是「通用名字包」——无 CultureData.json，只有名字 CSV 与
		## PoliticalSystems.json（原版目录实测）。作为 has_culture_data=false 的条目保留。
		return _load_name_only(id)
	var txt := f.get_as_text()
	f.close()
	var data: Variant = JSON.parse_string(txt)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("CultureData.json 不是合法 JSON: " + id)
		return {}
	var e := {
		"id": id,
		"has_culture_data": true,
		"color_hex": str(data.get("CultureColorHex", "#ffffff")),
		"name_order": str(data.get("NameOrder", "FirstNameFirst")),
		"political_systems": data.get("PoliticalSystems", []),
		"political_system_probabilities": data.get("PoliticalSystemProbabilities", {}),
		"ethnic_attribute_probabilities": data.get("EthnicAttributeProbabilities", {}),
		"trait_probabilities": data.get("TraitProbabilities", {}),
		"official_titles": data.get("OfficialTitles", []),
		"desc_zh": "", "desc_en": "",
		"state_names": [], "city_names": [],
		"male_names": [], "female_names": [], "last_names": [],
	}
	var tr: Variant = data.get("CultureDescriptionTranslations", [])
	if typeof(tr) == TYPE_ARRAY and tr.size() >= 1:
		e["desc_zh"] = str(tr[0])
		if tr.size() >= 2:
			e["desc_en"] = str(tr[1])
	# MapCultureTranslations = 14 语言的文化显示名（[0]=Chinese, [1]=English）
	e["display_zh"] = id
	e["display_en"] = id
	var mt: Variant = data.get("MapCultureTranslations", [])
	if typeof(mt) == TYPE_ARRAY and mt.size() >= 2:
		e["display_zh"] = str(mt[0])
		e["display_en"] = str(mt[1])
	# CSV：列 0=Key, 1=Chinese, 2=English（15 列固定表头）
	e["state_names"] = _load_csv_names(id, "StateNames")
	e["city_names"] = _load_csv_names(id, "CityNames")
	e["male_names"] = _load_csv_names(id, "CharacterFirstNames_Male")
	e["female_names"] = _load_csv_names(id, "CharacterFirstNames_Female")
	e["last_names"] = _load_csv_names(id, "CharacterLastNames")
	return e

## 通用名字包（WorldII）：无 CultureData.json，只有名字 CSV + PoliticalSystems.json。
func _load_name_only(id: String) -> Dictionary:
	var e := {
		"id": id, "has_culture_data": false,
		"color_hex": "#ffffff", "name_order": "FirstNameFirst",
		"political_systems": [], "political_system_probabilities": {},
		"ethnic_attribute_probabilities": {}, "trait_probabilities": {},
		"official_titles": {}, "desc_zh": "", "desc_en": "",
		"display_zh": id, "display_en": id,
		"state_names": [], "city_names": [],
		"male_names": [], "female_names": [], "last_names": [],
	}
	var pf := FileAccess.open(CULTURE_DIR + "/" + id + "/PoliticalSystems.json", FileAccess.READ)
	if pf != null:
		var pd: Variant = JSON.parse_string(pf.get_as_text())
		pf.close()
		if typeof(pd) == TYPE_DICTIONARY and typeof(pd.get("PoliticalSystems")) == TYPE_ARRAY:
			e["political_systems"] = pd["PoliticalSystems"]
	e["state_names"] = _load_csv_names(id, "StateNames")
	e["city_names"] = _load_csv_names(id, "CityNames")
	e["male_names"] = _load_csv_names(id, "CharacterFirstNames_Male")
	e["female_names"] = _load_csv_names(id, "CharacterFirstNames_Female")
	e["last_names"] = _load_csv_names(id, "CharacterLastNames")
	return e

## 读一份名字 CSV → [{key,zh,en}, ...]；带引号的字段按 RFC4180 处理。
func _load_csv_names(id: String, base: String) -> Array:
	var path := CULTURE_DIR + "/" + id + "/" + base + ".csv"
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return []
	var out := []
	var header_skipped := false
	while not f.eof_reached():
		var line := f.get_line()
		if line.strip_edges() == "":
			continue
		var fields := _split_csv(line)
		if not header_skipped:
			header_skipped = true    # 表头行（Key,Chinese,...）
			continue
		var zh: String = fields[1] if fields.size() > 1 else ""
		var en: String = fields[2] if fields.size() > 2 else ""
		out.append({"key": fields[0] if fields.size() > 0 else "", "zh": zh, "en": en})
	f.close()
	return out

## 最小 CSV 行解析：支持双引号包裹（内含逗号/双引号转义）。
static func _split_csv(line: String) -> Array:
	var fields := []
	var cur := ""
	var in_quotes := false
	var i := 0
	while i < line.length():
		var c := line[i]
		if in_quotes:
			if c == "\"":
				if i + 1 < line.length() and line[i + 1] == "\"":
					cur += "\""
					i += 1
				else:
					in_quotes = false
			else:
				cur += c
		else:
			if c == "\"":
				in_quotes = true
			elif c == ",":
				fields.append(cur)
				cur = ""
			else:
				cur += c
		i += 1
	fields.append(cur)
	return fields

## 按概率表加权随机取 key（工具函数）。
## 【证据边界】原版使用该表的函数尚未反编译；加权本身由数据表含义直接得出。
func weighted_pick(probs: Dictionary, rng: RandomNumberGenerator) -> String:
	var total := 0.0
	for k in probs:
		total += absf(float(probs[k]))
	if total <= 0.0:
		return ""
	var roll := rng.randf() * total
	for k in probs:
		roll -= absf(float(probs[k]))
		if roll <= 0.0:
			return str(k)
	return str(probs.keys()[0]) if probs.size() > 0 else ""

func get_culture(id: String) -> Dictionary:
	return cultures.get(id, {})
