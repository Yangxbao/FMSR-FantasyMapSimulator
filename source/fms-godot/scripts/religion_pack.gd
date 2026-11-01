extends RefCounted
## 原版宗教包加载器（数据层）
##
## 【数据来源】原版 StreamingAssets/Base/Religion/<包名>/ 已复制为 assets/origin/Religion/
##   （Religion.json 的 religions[] + localization.csv 15 列翻译）。
##   文件内容逐字节来自原版。
##
## 【证据边界】数据结构 = 原版文件实测（真）；宗教的分配/传播规则原版逻辑待反编译，
##   本类只提供数据解析与本地化解析。

const RELIGION_DIR := "res://assets/origin/Religion"

var packs := {}     ## pack_name -> {"religions":[...], "loc":{key:{zh,en}}}
var order := []     ## pack 顺序
var _loaded := false

## 读取全部宗教包。返回解析失败的包数（正常 0）。
func load_all() -> int:
	if _loaded:
		return 0
	var dir := DirAccess.open(RELIGION_DIR)
	if dir == null:
		push_error("宗教包目录缺失: " + RELIGION_DIR)
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
				packs[sub] = entry
				order.append(sub)
		sub = dir.get_next()
	dir.list_dir_end()
	_loaded = true
	return bad

func _load_one(pack: String) -> Dictionary:
	var jpath := RELIGION_DIR + "/" + pack + "/Religion.json"
	var f := FileAccess.open(jpath, FileAccess.READ)
	if f == null:
		push_error("Religion.json 缺失: " + jpath)
		return {}
	var data: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	var rels: Array = []
	if typeof(data) == TYPE_DICTIONARY and typeof(data.get("religions")) == TYPE_ARRAY:
		rels = data["religions"]
	elif typeof(data) == TYPE_ARRAY:
		rels = data
	var loc := _load_localization(pack)
	var out := []
	for r in rels:
		if typeof(r) != TYPE_DICTIONARY:
			continue
		var key := str(r.get("name", ""))
		out.append({
			"key": key,
			"name_zh": _loc(loc, key, "zh"),
			"name_en": _loc(loc, key, "en"),
			"color_hex": str(r.get("colorHex", "#ffffff")),
			"desc_zh": _loc(loc, str(r.get("description", "")), "zh"),
			"desc_en": _loc(loc, str(r.get("description", "")), "en"),
			"book_zh": _loc(loc, str(r.get("holyBookName", "")), "zh"),
			"practices_zh": _loc_list(loc, r.get("practices", []), "zh"),
		})
	return {"religions": out, "loc": loc}

func _load_localization(pack: String) -> Dictionary:
	var path := RELIGION_DIR + "/" + pack + "/localization.csv"
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var loc := {}
	var header: Array = []
	var first := true
	while not f.eof_reached():
		var line := f.get_line()
		if line.strip_edges() == "":
			continue
		var fields := _split_csv(line)
		if first:
			header = fields
			first = false
			continue
		if fields.size() < 3:
			continue
		var zh: String = fields[1]
		var en: String = fields[2] if fields.size() > 2 else ""
		loc[fields[0]] = {"zh": zh, "en": en}
	f.close()
	return loc

func _loc(loc: Dictionary, key: String, lang: String) -> String:
	var e: Dictionary = loc.get(key, {})
	return str(e.get(lang, ""))

func _loc_list(loc: Dictionary, keys: Variant, lang: String) -> Array:
	var out := []
	if typeof(keys) == TYPE_ARRAY:
		for k in keys:
			out.append(_loc(loc, str(k), lang))
	return out

## 全部宗教的扁平列表（跨包）：[{pack, ...religion}]，用于随机分配。
func all_religions() -> Array:
	var out := []
	for p in order:
		for r in packs[p]["religions"]:
			var e: Dictionary = r.duplicate(true)
			e["pack"] = p
			out.append(e)
	return out

## 最小 CSV 行解析（同 culture_pack； religious 描述含引号逗号）。
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
