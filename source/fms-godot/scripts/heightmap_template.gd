extends RefCounted
## 高度图模板 DSL 解析器（忠实实现）
##
## 证据链（全部来自反编译，见 reports/decompiled/）：
##   World.GenerateHeightMap  → HeightMapGenerator.GenerateHeightMap → GenerateFromTemplate(this, 3, 0)
##   GenerateFromTemplate：取 HeightmapTemplates.Templates[3].Template（字符串）→
##       Split('\n') → 逐行 Trim → Split(' ') → 要求分段数 >= 2 → addStep(line)
##   模板正文来自 global-metadata.dat 字符串字面量表（assets/origin/heightmap_templates.json）
##
## 本文件只做「文本 → 步骤列表」的解析，不含算子数值语义（那部分在 heightmap_dsl.gd）。
## 行格式：<算子名> <参数1> <参数2> <参数3> <参数4>
##   例：Hill 1 80-85 60-80 40-60 / Smooth 3 0 0 0 / Strait 2 vertical 0 0

const TEMPLATES_PATH := "res://assets/origin/heightmap_templates.json"

var templates: Array = []       ## [{order_seen, literal_index, lines, steps}]
var _loaded := false

## 读取并解析全部模板。返回解析失败的模板数（正常应为 0）。
func load_all() -> int:
	if _loaded:
		return 0
	var f := FileAccess.open(TEMPLATES_PATH, FileAccess.READ)
	if f == null:
		push_error("模板资产缺失: " + TEMPLATES_PATH)
		return -1
	var txt := f.get_as_text()
	f.close()
	var data: Variant = JSON.parse_string(txt)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("模板资产不是合法 JSON")
		return -1
	var bad := 0
	templates.clear()
	for t in (data as Dictionary)["templates"]:
		var lines: Array = t["lines"]
		var steps: Array = []
		var ok := true
		for ln in lines:
			var st: Variant = parse_line(str(ln))
			if st == null:
				ok = false
				push_warning("无法解析的行: " + str(ln))
			else:
				steps.append(st)
		if not ok:
			bad += 1
		templates.append({
			"order_seen": int(t["order_seen"]),
			"literal_index": int(t["literal_index"]),
			"lines": lines,
			"steps": steps,
		})
	_loaded = true
	return bad

## JS 权威模板库（main.dec.js const heightmapTemplates，45 个；findings §15.36）
## 返回 {name: {lines, steps}}；找不到文件或解析失败返回空字典。
const JS_TEMPLATES_PATH := "res://assets/origin/heightmap_templates_js.json"

func load_js_library() -> Dictionary:
	var f := FileAccess.open(JS_TEMPLATES_PATH, FileAccess.READ)
	if f == null:
		push_error("JS 模板库缺失: " + JS_TEMPLATES_PATH)
		return {}
	var txt := f.get_as_text()
	f.close()
	var data: Variant = JSON.parse_string(txt)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("JS 模板库不是合法 JSON")
		return {}
	var out := {}
	for t in (data as Dictionary)["templates"]:
		var lines: Array = t["lines"]
		var steps: Array = []
		var ok := true
		for ln in lines:
			var st: Variant = parse_line(str(ln))
			if st == null:
				ok = false
				push_warning("JS 模板 %s 含无法解析的行: %s" % [str(t["name"]), str(ln)])
			else:
				steps.append(st)
		if ok:
			out[str(t["name"])] = {"lines": lines, "steps": steps}
	return out

## 解析单行 → {op:String, args:PackedStringArray}；失败返回 null。
## 与原版一致：按空格切分后段数必须 >= 2（GenerateFromTemplate 的校验）。
static func parse_line(line: String) -> Variant:
	var parts := line.strip_edges().split(" ", false)
	if parts.size() < 2:
		return null
	var args := PackedStringArray()
	for i in range(1, parts.size()):
		args.append(parts[i])
	return {"op": parts[0], "args": args}

## 按 order_seen 取模板（注意：order_seen 不等于原版列表下标，详见 _unverified 说明）
func get_template_by_order(order_seen: int) -> Dictionary:
	load_all()
	for t in templates:
		if int(t["order_seen"]) == order_seen:
			return t
	return {}

## 已解析出的算子名集合（用于自检与文档）
func operator_names() -> Array:
	load_all()
	var seen := {}
	for t in templates:
		for st in t["steps"]:
			seen[String(st["op"])] = true
	var out := seen.keys()
	out.sort()
	return out
