extends Node2D
## FMSR 主控（忠实还原版）
## 顶部事件横幅 + 底部工具栏（生成地图/地图外观/菜单选项/历史记录/统计信息/
## 设为壁纸/地图编辑/暂停游戏/倍速/常见问题）——按钮布局与命名对齐原版截图

var gen: MapGen
var sim: Simulation
var map_render: MapRender
var cam: TouchCamera
var hud: CanvasLayer
var banner: PanelContainer
var banner_label: Label
var speed_label: Button
var panel_stack: Array = []
var time_scale := 0
var edit_mode := false
var edit_target_state := 0
var zh := {}   # 原版官方简中文案（localization.csv 提取）

const SPEEDS := [0.0, 1.0, 2.0, 4.0]
const SPEED_NAMES := ["已暂停", "1倍速", "2倍速", "4倍速"]
const TOOLBAR := ["生成地图", "地图外观", "菜单选项", "历史记录", "统计信息",
	"设为壁纸", "地图编辑", "暂停游戏", "单步", "1倍速", "军队", "常见问题"]

func _ready() -> void:
	var zf := FileAccess.open("res://assets/origin/zh_strings.json", FileAccess.READ)
	if zf:
		var parsed: Variant = JSON.parse_string(zf.get_as_text())
		if parsed is Dictionary:
			zh = parsed
	gen = MapGen.new()
	sim = Simulation.new()
	cam = TouchCamera.new()
	cam.position = Vector2(MapGen.W * MapGen.CELL, MapGen.H * MapGen.CELL) * 0.5
	cam.zoom = Vector2.ONE * 0.9
	cam.tapped.connect(_on_tap)
	cam.long_pressed.connect(_on_long_press)
	add_child(cam)
	map_render = MapRender.new()
	add_child(map_render)
	army_icons = ArmyIconsLayerScript.new()
	army_icons.name = "ArmyIcons"
	add_child(army_icons)
	hud = CanvasLayer.new()
	add_child(hud)
	_build_ui()
	_init_editor()
	# 可复现对照：命令行 `-- seed=42 shot=8` → 固定种子生成 + N 秒后自动截图退出
	var seed_arg := -1
	var shot_after := -1.0
	var panel_arg := ""
	var view_arg := ""
	var demo_arg := ""
	# 截图模式：忽略真实鼠标，避免前台窗口被误点改变画面
	for a in OS.get_cmdline_user_args():
		if a == "noinput":
			_input_disabled = true
		if a.begins_with("seed="):
			seed_arg = int(a.split("=")[1])
		elif a.begins_with("shot="):
			shot_after = float(a.split("=")[1])
		elif a.begins_with("panel="):
			panel_arg = a.split("=")[1]
		elif a.begins_with("view="):
			view_arg = a.split("=")[1]
		elif a.begins_with("editdemo="):
			demo_arg = a.split("=")[1]
		elif a.begins_with("demo="):
			war_demo_mode = a.split("=")[1] == "1"
		elif a.begins_with("shots="):
			for tk in a.split("=")[1].split(","):
				if tk.strip_edges().is_valid_int():
					war_demo_shots.append(int(tk))
	new_world(seed_arg if seed_arg >= 0 else randi())
	if war_demo_mode:
		_start_war_demo()
	if panel_arg == "state":
		_open_state_panel(0)
	elif panel_arg == "armies":
		_toggle_panel(_build_armies_panel())
	elif panel_arg == "province":
		_open_province_panel(0)
	elif panel_arg == "history":
		_toggle_panel(_build_history_panel())
	elif panel_arg == "stats":
		_toggle_panel(_build_stats_panel())
	elif panel_arg == "editor":
		_toggle_editor()
	elif panel_arg == "global":
		_toggle_panel(_build_global_commands_panel())
	elif panel_arg == "sea":
		for pi in gen.provinces.size():
			if gen.provinces[pi].get("is_sea", false):
				_open_sea_province_panel(pi)
				break
	if view_arg == "biome":
		map_render.view_mode = MapRender.View.BIOME
		map_render.mark_dirty()
	elif view_arg == "height":
		map_render.view_mode = MapRender.View.HEIGHT
		map_render.mark_dirty()
	if demo_arg != "":
		_run_edit_demo(demo_arg)
	sim.map_changed.connect(func(): map_render.mark_ownership_dirty())
	if shot_after > 0:
		_shot_after = shot_after

var _shot_after := -1.0
var _shot_elapsed := 0.0

func t(key: String, fallback: String) -> String:
	return zh.get(key, fallback)

var _current_seed := 0
const ArmyIconsLayerScript := preload("res://scripts/army_icons_layer.gd")
var army_icons = null
var _place_mode_si := -1    # 部署模式：待部署国（-1 = 关闭）
var _place_mode_n := 0

# ---- 战争演示模式（通宵指令 P8）：demo=1 自动宣战相邻两国并以最高速推进；
# shots=6,12,30 在对应月度 tick 后自动截图（不退出），序列走完自动退出 ----
var war_demo_mode := false
var war_demo_shots: Array = []
var _demo_tick := 0

func _start_war_demo() -> void:
	# 关自然开战/扩张：战争链完全由演示宣战驱动，可重复
	sim.rules["war_chance_per_month"] = 0.0
	sim.rules["expand_pressure"] = 0.0
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
	if a >= 0 and d >= 0:
		sim.declare_war(a, d, "WarTypeConquest", "WarGoalCedeProvince")
		_push_banner("战争演示：%s 对 %s 宣战" % [gen.states[a].name, gen.states[d].name])
		var bp: int = sim._border_province_of(a, d)
		if bp >= 0:
			var bpos: Vector2 = gen.provinces[bp].burg
			var half := get_viewport_rect().size * 0.5 / maxf(cam.zoom.x, 0.01)
			bpos.x = clampf(bpos.x, half.x * 0.4, MapGen.W * MapGen.CELL - half.x * 0.4)
			bpos.y = clampf(bpos.y, half.y * 0.4, MapGen.H * MapGen.CELL - half.y * 0.4)
			cam.position = bpos
	time_scale = SPEEDS.size() - 1
	_update_speed_label()

func new_world(seed_val: int) -> void:
	_current_seed = seed_val
	gen.generate(26, seed_val)
	sim.setup(gen, seed_val)
	map_render.setup(gen, cam)
	army_icons.setup(gen, sim)
	_push_banner("新世界已生成：%d 年 %d 月，%d 个国家" % [sim.year, sim.month, gen.states.size()])
	_update_speed_label()

# ---------------- UI ----------------
func _paper_style(border := true) -> StyleBoxFlat:
	# 米色羊皮纸风格（与原版横幅/按钮条观感对齐）
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.90, 0.85, 0.72)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	if border:
		sb.border_width_left = 2
		sb.border_width_right = 2
		sb.border_width_top = 2
		sb.border_width_bottom = 2
		sb.border_color = Color(0.25, 0.22, 0.18)
	sb.shadow_color = Color(0.2, 0.17, 0.13, 0.35)
	sb.shadow_size = 3
	return sb

func _build_ui() -> void:
	# 顶部事件横幅（原版样式：居中羊皮纸条幅）
	banner = PanelContainer.new()
	banner.add_theme_stylebox_override("panel", _paper_style())
	banner.anchor_left = 0.5
	banner.anchor_right = 0.5
	banner.offset_left = -560
	banner.offset_right = 560
	banner.offset_top = 14
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner_label = Label.new()
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.add_theme_font_size_override("font_size", 24)
	banner_label.add_theme_color_override("font_color", Color(0.12, 0.10, 0.08))
	banner_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.add_child(banner_label)
	hud.add_child(banner)

	# 底部工具栏（与原版一致的三段式按钮条）
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 6)
	bar.anchor_top = 1.0
	bar.anchor_bottom = 1.0
	bar.anchor_left = 0.5
	bar.anchor_right = 0.5
	bar.offset_left = -660
	bar.offset_right = 660
	bar.offset_top = -52
	bar.offset_bottom = -14
	hud.add_child(bar)
	for name in TOOLBAR:
		var b := Button.new()
		b.text = name
		b.custom_minimum_size = Vector2(96, 38)
		b.add_theme_stylebox_override("normal", _paper_style())
		b.add_theme_stylebox_override("hover", _paper_style())
		b.add_theme_stylebox_override("pressed", _paper_style())
		b.add_theme_color_override("font_color", Color(0.12, 0.10, 0.08))
		b.add_theme_color_override("font_hover_color", Color(0.05, 0.04, 0.03))
		b.add_theme_color_override("font_pressed_color", Color(0.05, 0.04, 0.03))
		b.add_theme_font_size_override("font_size", 17)
		b.pressed.connect(_on_toolbar.bind(name))
		bar.add_child(b)

func _on_toolbar(name: String) -> void:
	match name:
		"生成地图":
			new_world(randi())
		"地图外观":
			_toggle_panel(_build_appearance_panel())
		"菜单选项":
			_toggle_panel(_build_options_panel())
		"历史记录":
			_toggle_panel(_build_history_panel())
		"统计信息":
			_toggle_panel(_build_stats_panel())
		"设为壁纸":
			_save_wallpaper()
		"地图编辑":
			_toggle_editor()
		"暂停游戏":
			time_scale = 0
			_update_speed_label()
			_set_toolbar_text(7, "继续游戏")
			_push_banner("游戏已暂停")
		"继续游戏":
			time_scale = 1
			_update_speed_label()
			_set_toolbar_text(7, "暂停游戏")
			if editor_dock != null:
				_close_editor()
			_push_banner("游戏继续")
		"单步":
			if sim.gen != null and gen.states.size() > 0:
				time_scale = 0
				sim.tick_month()
				_update_speed_label()
				_update_banner()
		"1倍速":
			time_scale = (time_scale + 1) % SPEEDS.size()
			_update_speed_label()
		"军队":
			_toggle_panel(_build_armies_panel())
		"常见问题":
			_toggle_panel(_build_help_panel())

func _set_toolbar_text(idx: int, text: String) -> void:
	var bar := hud.get_child(1)
	if bar != null and idx < bar.get_child_count():
		var b := bar.get_child(idx)
		if b is Button:
			(b as Button).text = text

func _update_speed_label() -> void:
	var b := hud.get_children()[1].get_child(9)
	b.text = SPEED_NAMES[time_scale] if time_scale != 0 else "1倍速"

var _last_event := ""

func _push_banner(text: String) -> void:
	_last_event = text
	_update_banner()

func _update_banner() -> void:
	if banner_label == null:
		return
	if sim != null and sim.gen != null and gen.states.size() > 0:
		banner_label.text = "%d年%d月 | %s" % [sim.year, sim.month, _last_event]
	else:
		banner_label.text = _last_event

# ---------------- 各面板 ----------------
func _close_panels() -> void:
	for p in panel_stack:
		p.queue_free()
	panel_stack.clear()

func _toggle_panel(p: Control) -> void:
	_close_panels()
	panel_stack.append(p)
	hud.add_child(p)

func _base_panel(title: String, size := Vector2(520, 420)) -> Dictionary:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _paper_style())
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -size.x / 2
	panel.offset_right = size.x / 2
	panel.offset_top = -size.y / 2
	panel.offset_bottom = size.y / 2
	var vb := VBoxContainer.new()
	panel.add_child(vb)
	var t := Label.new()
	t.text = title
	t.add_theme_font_size_override("font_size", 26)
	t.add_theme_color_override("font_color", Color(0.12, 0.10, 0.08))
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(t)
	return {"panel": panel, "vbox": vb}

## 面板收尾：底部关闭按钮（原版面板底部操作区）
func _finish(ui: Dictionary) -> void:
	var close := Button.new()
	close.text = t("Close", "关闭")
	close.pressed.connect(_close_panels)
	ui.vbox.add_child(close)

func _kv_s(text: String) -> Label:
	var l := _body_label()
	l.text = text
	l.custom_minimum_size = Vector2(64, 0)
	l.add_theme_font_size_override("font_size", 14)
	return l

func _body_label() -> Label:
	var l := Label.new()
	l.add_theme_color_override("font_color", Color(0.15, 0.13, 0.10))
	l.add_theme_font_size_override("font_size", 16)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l

## 军队面板（通宵指令 P5）：军队 ID/所属国/当前省/兵力/类型/状态/目标，点击行定位地图
## 军队详情 dock（V5 P2 5.4）：点击军事图标 → 该省军队列表（ID/国/兵力/类型/状态/目标）
func _open_armies_at_province(pi: int) -> void:
	var armies: Array = army_icons.armies_at(pi)
	if armies.is_empty():
		return
	var prov_name := str(gen.provinces[pi].get("name", "?"))
	var ui := _base_panel("军队 · %s" % prov_name, Vector2(640, 120 + armies.size() * 34))
	for a in armies:
		var row := HBoxContainer.new()
		var si: int = int(a.get("state", -1))
		var st_name := "?"
		var st_col := Color(0.4, 0.4, 0.4)
		if si >= 0 and si < gen.states.size():
			st_name = str(gen.states[si].name)
			st_col = gen.states[si].color
		var swatch := ColorRect.new()
		swatch.color = st_col
		swatch.custom_minimum_size = Vector2(14, 14)
		row.add_child(swatch)
		var type_zh := str(a.get("army_type", "?")).replace("BorderGuard", "边防").replace("FieldArmy", "野战").replace("Garrison", "驻防")
		var state_zh := str(a.get("current_state", "?")).replace("Marching", "行军").replace("Idle", "待命").replace("Reorganization", "重组").replace("Fighting", "交战")
		var tgt := "—"
		if int(a.get("target_province", -1)) >= 0:
			tgt = str(gen.provinces[int(a["target_province"])].get("name", "?"))
		var l := _body_label()
		l.text = "#%d  %s  %.0f 人  %s  %s → %s" % [
			int(a.get("army_id", 0)), st_name, float(a.get("army_count", 0.0)),
			type_zh, state_zh, tgt]
		l.custom_minimum_size = Vector2(560, 0)
		row.add_child(l)
		var btn := Button.new()
		btn.text = "定位"
		var cc: int = int(a.get("current_cell", 0))
		btn.pressed.connect(func() -> void:
			cam.position = Vector2((cc % MapGen.W) * MapGen.CELL, (cc / MapGen.W) * MapGen.CELL)
			_close_panels())
		row.add_child(btn)
		ui.vbox.add_child(row)
	_finish(ui)
	_toggle_panel(ui.panel)

## —— 玩家宣战面板（V5.1 P0）：目标国列表（关系/兵力/停战标注）→ 战争目标选择 → 确认宣战
func _open_war_declare_panel(si: int) -> void:
	var ui := _base_panel("发起战争 · 选择目标", Vector2(680, 560))
	var targets := sim._neighbor_states(si)
	var body: VBoxContainer = VBoxContainer.new()
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(640, 300)
	body.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	var chosen := -1
	var goal_opt := OptionButton.new()
	goal_opt.add_item("割让行省（WarGoalCedeProvince）")
	goal_opt.add_item("吞并（WarGoalAnnex）")
	goal_opt.add_item("占领计数（WarGoalOccupyCount）")
	goal_opt.add_item("赔款（WarV2_GoalReparations）")
	goal_opt.add_item("附庸（WarV2_GoalVassalize）")
	goal_opt.disabled = true
	var confirm := Button.new()
	confirm.text = "确认宣战"
	confirm.disabled = true
	var my_power := sim._state_power(si)
	for ti in targets:
		var tsi: int = int(ti)
		var tstate: Dictionary = gen.states[tsi]
		var row := HBoxContainer.new()
		var sw := ColorRect.new()
		sw.color = tstate.color
		sw.custom_minimum_size = Vector2(16, 16)
		row.add_child(sw)
		var foe_power := sim._state_power(tsi)
		var ratio := "劣势" if my_power < foe_power * 0.7 else ("优势" if my_power > foe_power * 1.5 else "均势")
		var status := ""
		if sim.is_at_war(tsi):
			status = " [交战中]"
		elif sim._in_truce(si, tsi):
			status = " [停战期]"
		var allied := " [盟友]" if (gen.states[si].get("allies", []) as Array).has(tsi) else ""
		var l := _body_label()
		l.text = "%s · 领土 %d · 国力 %s（%s）%s%s" % [tstate.name, tstate.provinces.size(), _fmt_pop(foe_power), ratio, status, allied]
		l.custom_minimum_size = Vector2(520, 0)
		row.add_child(l)
		var pick := Button.new()
		pick.text = "选择"
		pick.pressed.connect(func() -> void:
			chosen = tsi
			goal_opt.disabled = false
			confirm.disabled = false
			confirm.text = "对 %s 宣战" % gen.states[tsi].name)
		row.add_child(pick)
		list.add_child(row)
	if targets.is_empty():
		var none := _body_label()
		none.text = "没有相邻国家可宣战"
		list.add_child(none)
	ui.vbox.add_child(body)
	var glabel := _body_label()
	glabel.text = "战争目标（原版 WarGoal 键，影响结算条款）："
	ui.vbox.add_child(glabel)
	ui.vbox.add_child(goal_opt)
	confirm.pressed.connect(func() -> void:
		if chosen < 0:
			return
		var goal_keys := ["WarGoalCedeProvince", "WarGoalAnnex", "WarGoalOccupyCount", "WarV2_GoalReparations", "WarV2_GoalVassalize"]
		var msg: String = sim.declare_war_player(si, chosen, goal_keys[goal_opt.selected])
		_push_banner(msg)
		if army_icons != null:
			army_icons.show_war_arrow(si, chosen, 30.0)
			var cap_t: int = int(gen.states[chosen].get("capital", -1))
			if cap_t >= 0:
				var bp2: Vector2 = gen.provinces[cap_t].burg
				var half := get_viewport_rect().size * 0.5 / maxf(cam.zoom.x, 0.01)
				bp2.x = clampf(bp2.x, half.x * 0.4, MapGen.W * MapGen.CELL - half.x * 0.4)
				bp2.y = clampf(bp2.y, half.y * 0.4, MapGen.H * MapGen.CELL - half.y * 0.4)
				cam.position = bp2
		_close_panels())
	ui.vbox.add_child(confirm)
	_finish(ui)
	_toggle_panel(ui.panel)

## —— 玩家结盟面板（V5.1 P0）：现盟友（退出）+ 候选（结盟）
func _open_alliance_panel(si: int) -> void:
	var ui := _base_panel("外交 · 同盟管理", Vector2(680, 560))
	var body: VBoxContainer = VBoxContainer.new()
	ui.vbox.add_child(body)
	var allies_title := _body_label()
	allies_title.text = "当前盟友："
	body.add_child(allies_title)
	var has_ally := false
	for ai in gen.states[si].get("allies", []):
		var asi: int = int(ai)
		if asi < 0 or asi >= gen.states.size() or not gen.states[asi].alive:
			continue
		has_ally = true
		var row := HBoxContainer.new()
		var sw := ColorRect.new()
		sw.color = gen.states[asi].color
		sw.custom_minimum_size = Vector2(16, 16)
		row.add_child(sw)
		var l := _body_label()
		l.text = gen.states[asi].name
		l.custom_minimum_size = Vector2(400, 0)
		row.add_child(l)
		var leave := Button.new()
		leave.text = "解除同盟"
		leave.pressed.connect(func() -> void:
			_push_banner(sim.break_alliance_player(si, asi))
			_close_panels()
			_open_alliance_panel(si))
		row.add_child(leave)
		body.add_child(row)
	if not has_ally:
		var none := _body_label()
		none.text = "无"
		body.add_child(none)
	var cand_title := _body_label()
	cand_title.text = "可结盟国家（相邻、非交战）："
	cand_title.text += ""
	body.add_child(cand_title)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(640, 240)
	body.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	var found := false
	for ti in sim._neighbor_states(si):
		var tsi: int = int(ti)
		if (gen.states[si].get("allies", []) as Array).has(tsi):
			continue
		if sim.is_at_war(tsi) or sim.is_at_war(si):
			continue
		found = true
		var row2 := HBoxContainer.new()
		var sw2 := ColorRect.new()
		sw2.color = gen.states[tsi].color
		sw2.custom_minimum_size = Vector2(16, 16)
		row2.add_child(sw2)
		var l2 := _body_label()
		l2.text = "%s · 领土 %d · 国力 %s" % [gen.states[tsi].name, gen.states[tsi].provinces.size(), _fmt_pop(sim._state_power(tsi))]
		l2.custom_minimum_size = Vector2(520, 0)
		row2.add_child(l2)
		var join := Button.new()
		join.text = "结盟"
		join.pressed.connect(func() -> void:
			_push_banner(sim.make_alliance_player(si, tsi))
			_close_panels()
			_open_alliance_panel(si))
		row2.add_child(join)
		list.add_child(row2)
	if not found:
		var none2 := _body_label()
		none2.text = "无候选（需要相邻且双方未交战）"
		list.add_child(none2)
	_finish(ui)
	_toggle_panel(ui.panel)

func _build_armies_panel() -> Control:
	var ui := _base_panel("军队", Vector2(760, 560))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(720, 400)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(body)
	ui.vbox.add_child(scroll)
	var head := HBoxContainer.new()
	for col in ["ID", "所属国", "当前省份", "兵力", "类型", "状态", "目标"]:
		var l := _body_label()
		l.text = col
		l.custom_minimum_size = Vector2(96, 0)
		head.add_child(l)
	body.add_child(head)
	var shown := 0
	for a in sim.armies:
		if str(a["current_state"]) == "Destroyed":
			continue
		shown += 1
		if shown > 300:
			var more := _body_label()
			more.text = "… 共 %d 支（仅显示前 300）" % sim.armies.size()
			body.add_child(more)
			break
		var row := HBoxContainer.new()
		var prov_name := "—"
		var pi: int = int(gen.cell_province[int(a["current_cell"])])
		if pi >= 0 and pi < gen.provinces.size():
			prov_name = str(gen.provinces[pi].name)
		var tgt_name := "—"
		if int(a["target_province"]) >= 0 and int(a["target_province"]) < gen.provinces.size():
			tgt_name = str(gen.provinces[int(a["target_province"])].name)
		var st_name := "?"
		var si: int = int(a["state"])
		if si >= 0 and si < gen.states.size():
			st_name = str(gen.states[si].name)
		for val in [str(a["army_id"]), st_name, prov_name, "%.0f" % float(a["army_count"]),
				str(a["army_type"]).replace("BorderGuard", "边防").replace("FieldArmy", "野战").replace("Garrison", "驻防"),
				str(a["current_state"]), tgt_name]:
			var l2 := _body_label()
			l2.text = str(val)
			l2.custom_minimum_size = Vector2(96, 0)
			row.add_child(l2)
		var cap := Button.new()
		cap.text = "定位"
		cap.pressed.connect(func() -> void:
			var c2: int = int(a["current_cell"])
			cam.position = Vector2((c2 % MapGen.W) * MapGen.CELL, (c2 / MapGen.W) * MapGen.CELL)
			_close_panels())
		row.add_child(cap)
		body.add_child(row)
	if shown == 0:
		var none := _body_label()
		none.text = "当前没有军队"
		body.add_child(none)
	_finish(ui)
	return ui.panel

func _build_history_panel() -> Control:
	var ui := _base_panel(t("History", "历史记录"), Vector2(700, 560))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(660, 380)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(body)
	ui.vbox.add_child(scroll)
	_history_block(body, -1)
	_finish(ui)
	return ui.panel

const STAT_CATS := ["行省数量", "人口", "综合国力", "军队"]

func _build_stats_panel() -> Control:
	var ui := _base_panel(t("Statistics", "统计信息"), Vector2(620, 540))
	var head := HBoxContainer.new()
	var cat_lab := _body_label()
	cat_lab.text = t("StatisticsCategory", "统计类别")
	cat_lab.custom_minimum_size = Vector2(96, 0)
	head.add_child(cat_lab)
	var opt := OptionButton.new()
	for c in STAT_CATS:
		opt.add_item(c)
	head.add_child(opt)
	var val_lab := _body_label()
	head.add_child(val_lab)
	ui.vbox.add_child(head)
	var holder := VBoxContainer.new()
	ui.vbox.add_child(holder)

	var render := func(cat: int) -> void:
		for ch in holder.get_children():
			ch.queue_free()
		var arr: Array = []
		for si in gen.states.size():
			var st: Dictionary = gen.states[si]
			if not st.alive:
				continue
			var v := 0
			match cat:
				0: v = st.provinces.size()
				1: v = sim._state_power(si)
				2: v = sim._state_power(si) + int(st.get("army", 0)) * 200
				3: v = int(st.get("army", 0))
			arr.append([st.name, st.provinces.size(), v])
		arr.sort_custom(func(a, b): return b[2] > a[2])
		val_lab.text = "（%s）" % STAT_CATS[cat]
		var lines := ["排名  国家  行省数  %s" % STAT_CATS[cat]]
		for i in arr.size():
			lines.append("%d.  %s  %d  %d" % [i + 1, arr[i][0], arr[i][1], arr[i][2]])
		var l := _body_label()
		l.text = "\n".join(lines)
		holder.add_child(l)
	opt.item_selected.connect(func(i: int) -> void: render.call(i))
	render.call(0)
	_finish(ui)
	return ui.panel

## 玩法规则中文标签（V5.2：替换原始键值对界面）
## [键, 中文名, 类型]；bool=开关复选，num=数值步进（显示两位小数）
const RULE_META := [
	["war_chance_per_month", "战争发生率", "num"],
	["expand_pressure", "扩张压力", "num"],
	["pop_growth", "人口增长率", "num"],
	["battle_randomness", "战斗随机性", "num"],
	["allow_rebellion", "允许叛乱", "bool"],
	["allow_civil_war", "允许内战", "bool"],
	["allow_family_rebellion", "允许家族叛乱", "bool"],
	["allow_vassal_rebel", "允许附庸叛乱", "bool"],
	["allow_alliance", "允许结盟", "bool"],
	["enable_vassal", "允许附庸国", "bool"],
	["allow_auto_diplomacy", "自主外交", "bool"],
	["assist_allies_occupy_land", "盟友协助占领", "bool"],
	["allow_auto_abandon_isolated", "自动放弃孤立省", "bool"],
	["generate_desert_and_snow", "生成沙漠与雪原", "bool"],
	["auto_save_enabled", "自动存档", "bool"],
	["auto_save_interval_minutes", "自动存档间隔（分钟）", "num"],
	["max_war_duration_months", "战争最长持续（月）", "num"],
	["min_month_to_begin_another_war", "停战期长度（月）", "num"],
	["rebel_interval_months", "叛乱间隔（月）", "num"],
]

func _build_options_panel() -> Control:
	var ui := _base_panel("菜单选项 · 玩法规则", Vector2(560, 560))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(520, 420)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(body)
	ui.vbox.add_child(scroll)
	var sec_sim := _collapsible(body, "⚖ 模拟参数", true)
	var sec_sw := _collapsible(body, "🔘 全局开关", true)
	var sec_sys := _collapsible(body, "💾 系统", false)
	for meta in RULE_META:
		var key: String = meta[0]
		var cname: String = meta[1]
		var kind: String = meta[2]
		var parent: Node = sec_sim
		if kind == "bool":
			parent = sec_sw if key.begins_with("allow") or key.begins_with("enable") or key.begins_with("assist") or key.begins_with("generate") else sec_sys
		var r := _row(parent)
		var lab := _body_label()
		lab.text = cname
		lab.custom_minimum_size = Vector2(200, 0)
		r.add_child(lab)
		var v: Variant = sim.rules.get(key)
		if kind == "bool":
			var cb := CheckButton.new()
			cb.button_pressed = bool(v)
			cb.pressed.connect(func() -> void:
				sim.rules[key] = not bool(sim.rules.get(key, false))
				_push_banner("%s：%s" % [cname, "开" if bool(sim.rules[key]) else "关"]))
			r.add_child(cb)
		else:
			var val := _body_label()
			val.text = "%.3f" % float(v) if float(v) < 10.0 else str(int(v))
			val.custom_minimum_size = Vector2(80, 0)
			r.add_child(val)
			var minus := Button.new()
			minus.text = "−"
			minus.pressed.connect(func() -> void:
				var nv: float = clampf(float(sim.rules[key]) * 0.8, 0.001, 1e9)
				sim.rules[key] = nv
				val.text = "%.3f" % nv if nv < 10.0 else str(int(nv)))
			r.add_child(minus)
			var plus := Button.new()
			plus.text = "+"
			plus.pressed.connect(func() -> void:
				var nv: float = clampf(float(sim.rules[key]) * 1.25, 0.001, 1e9)
				sim.rules[key] = nv
				val.text = "%.3f" % nv if nv < 10.0 else str(int(nv)))
			r.add_child(plus)
	var hint := _body_label()
	hint.text = "规则改动立即生效并随存档保存"
	hint.add_theme_color_override("font_color", Color(0.35, 0.3, 0.25))
	ui.vbox.add_child(hint)
	_finish(ui)
	return ui.panel

func _adjust_rule(key: String, mult: float) -> void:
	var v: float = sim.rules[key]
	sim.rules[key] = clampf(v * mult, 0.001, 3.0)
	_push_banner("规则 %s = %.3f" % [key, sim.rules[key]])
	_close_panels()

func _build_appearance_panel() -> Control:
	var ui := _base_panel("地图外观", Vector2(480, 300))
	var names_btn := Button.new()
	names_btn.text = "切换：显示全部城邑名（缩放>1.8x 时显示）"
	names_btn.pressed.connect(func(): _push_banner("提示：放大到 1.8 倍以上显示城邑名"))
	ui.vbox.add_child(names_btn)
	var gray := Button.new()
	gray.text = "重绘地图（重新散布地形）"
	gray.pressed.connect(func():
		map_render.mark_dirty()
		_close_panels())
	ui.vbox.add_child(gray)
	_finish(ui)
	return ui.panel

func _build_help_panel() -> Control:
	var ui := _base_panel("常见问题", Vector2(560, 420))
	var l := _body_label()
	l.text = """拖动：鼠标左键/单指拖动
缩放：滚轮 / 双指捏合
选择国家：左键点击任意国土 → 国家信息面板
选择行省：Shift+左键（或触屏长按）→ 行省信息面板
行省操作：设为首都 / 发动叛乱（面板内）
地图编辑：开启后点击省份划给指定国家
存档：user://saves/save1.json（JSON 格式，版本号向前兼容）
规则：菜单选项可实时调整战争频率/扩张压力等参数
Mods：将 *.json 规则文件放入 user://mods/ 即在下局生效
交互与文案对齐原版（localization.csv）；本作为个人研究用逆向重建原型。"""
	ui.vbox.add_child(l)
	_finish(ui)
	return ui.panel

func _save_wallpaper() -> void:
	var img := get_viewport().get_texture().get_image()
	DirAccess.make_dir_recursive_absolute("user://wallpapers")
	var path := "user://wallpapers/wall_%d.png" % [Time.get_ticks_msec()]
	img.save_png(path)
	_push_banner("壁纸已保存：" + ProjectSettings.globalize_path(path))

# ---------------- 交互与心跳 ----------------
func _process(delta: float) -> void:
	if army_icons != null:
		army_icons.process_delta(delta)
	if _shot_after > 0:
		_shot_elapsed += delta
		if _shot_elapsed >= _shot_after:
			_shot_after = -1.0
			var img := get_viewport().get_texture().get_image()
			DirAccess.make_dir_recursive_absolute("user://shots")
			var p := "user://shots/auto_seed%d.png" % [_current_seed]
			img.save_png(p)
			print("[shot] saved ", ProjectSettings.globalize_path(p))
			get_tree().quit()
	if bool(sim.rules.get("auto_save_enabled", false)):
		if _autosave_left < 0.0:
			_autosave_left = float(sim.rules.auto_save_interval_minutes) * 60.0
		_autosave_left -= delta
		if _autosave_left <= 0.0:
			_autosave_left = float(sim.rules.auto_save_interval_minutes) * 60.0
			sim.save("user://saves/autosave.json")
			_push_banner("自动存档已保存：user://saves/autosave.json")
	if time_scale > 0:
		tick_accum += delta * SPEEDS[time_scale]
		var months := int(tick_accum)
		if months > 0:
			tick_accum -= months
			for i in months:
				sim.tick_month()
				_demo_tick += 1
				if war_demo_shots.has(_demo_tick):
					var imgd := get_viewport().get_texture().get_image()
					DirAccess.make_dir_recursive_absolute("user://shots")
					var pd := "user://shots/demo_seed%d_t%d.png" % [_current_seed, _demo_tick]
					imgd.save_png(pd)
					print("[demo shot] ", ProjectSettings.globalize_path(pd))
					war_demo_shots.erase(_demo_tick)
					if war_demo_shots.is_empty():
						get_tree().quit()
						return
			var h: Dictionary = sim.history[sim.history.size() - 1]
			if sim.history.size() > 0:
				_push_banner("%d年%d月：%s" % [sim.year, sim.month, h.text])

var tick_accum := 0.0

func _on_tap(world_pos: Vector2) -> void:
	if _input_disabled:
		return
	# 部署模式（V5.1 P0）：点击本国省 → 真实部署
	if _place_mode_si >= 0:
		var ci_p := gen.cell_index_at(world_pos)
		if ci_p >= 0:
			var pi_p: int = int(gen.cell_province[ci_p])
			_push_banner(sim.deposit_army(_place_mode_si, pi_p, _place_mode_n))
		_place_mode_si = -1
		return
	# 军事图层优先（V5 P2）：命中旗帜 → 军队详情
	if army_icons != null and editor == null:
		var hit_id: int = army_icons.hit_test(world_pos)
		if hit_id >= 0:
			_open_armies_at_province(army_icons.province_of(hit_id))
			return
	var ci := gen.cell_index_at(world_pos)
	if ci < 0:
		return
	# 编辑器模式：Shift+左键 = 选择目标（原版 DrawingProvinceTips / DrawStateTips）
	if editor != null and editor.active:
		if editor.layer == MapEditorNS.Layer.PROVINCE:
			var picked: int = editor.pick_province_at(world_pos)
			if picked >= 0:
				_push_banner("已选择行省：%s" % gen.provinces[picked].name)
			_refresh_editor_ui()
			return
		if editor.layer == MapEditorNS.Layer.STATE:
			var picked2: int = editor.pick_state_at(world_pos)
			if picked2 >= 0:
				_push_banner("已选择国家：%s" % gen.states[picked2].name)
			_refresh_editor_ui()
			return
		if editor.layer == MapEditorNS.Layer.BIOME:
			editor.target_biome = int(gen.biome[ci])
			_push_banner("已选择群系：%s" % gen.biome_label(editor.target_biome))
			_refresh_editor_ui()
			return
		return
	var pi: int = gen.cell_province[ci]
	if pi < 0:
		_push_banner("未归属海域")
		return
	if gen.provinces[pi].get("is_sea", false):
		_open_sea_province_panel(pi)
		return
	if edit_mode:
		var old_si: int = gen.provinces[pi].state
		var new_si := edit_target_state % gen.states.size()
		if old_si != new_si and gen.states[old_si].provinces.has(pi):
			gen.states[old_si].provinces.erase(pi)
			gen.states[new_si].provinces.append(pi)
			gen.provinces[pi].state = new_si
			map_render.mark_dirty()
			_push_banner("地图编辑：省份 %s 划给 %s" % [gen.provinces[pi].name, gen.states[new_si].name])
		return
	# 原版交互：左键国家 → 国家信息面板；Shift+左键行省 → 行省信息面板
	if Input.is_key_pressed(KEY_SHIFT):
		_open_province_panel(pi)
	else:
		_open_state_panel(gen.provinces[pi].state)

func _on_long_press(world_pos: Vector2) -> void:
	var ci := gen.cell_index_at(world_pos)
	if ci < 0:
		return
	var pi: int = gen.cell_province[ci]
	if pi >= 0:
		_open_province_panel(pi)

# ==================== 面板通用小工具 ====================
func _kv(text: String) -> Label:
	var l := _body_label()
	l.text = text
	l.custom_minimum_size = Vector2(96, 0)
	return l

func _row(parent: Node) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", 6)
	parent.add_child(r)
	return r

func _info_row(parent: Node, k: String, v: String) -> void:
	var r := _row(parent)
	r.add_child(_kv(k))
	var val := _body_label()
	val.text = v
	r.add_child(val)

func _section(parent: Node, title: String) -> VBoxContainer:
	var sep := HSeparator.new()
	parent.add_child(sep)
	var ttl := _body_label()
	ttl.text = "—— %s ——" % title
	ttl.add_theme_font_size_override("font_size", 15)
	parent.add_child(ttl)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 3)
	parent.add_child(vb)
	return vb

func _mk_btn(parent: Node, text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.pressed.connect(cb)
	parent.add_child(b)
	return b

## 按"半年"分组历史（原版 HistoryHalfYearPrev/Next 的分页粒度）
func _hy_key(date: String) -> String:
	var y := ""
	var m := 1
	var p := date.find("年")
	if p > 0:
		y = date.substr(0, p)
		var rest := date.substr(p + 1)
		var p2 := rest.find("月")
		if p2 > 0:
			m = int(rest.substr(0, p2))
	return "%s年%s半年" % [y, ("上" if m <= 6 else "下")]

func _history_groups(si: int) -> Array:
	var by := {}
	var order: Array = []
	for h in sim.history:
		if si >= 0 and int(h.get("state", -1)) != si:
			continue
		var k := _hy_key(str(h.date))
		if not by.has(k):
			by[k] = []
			order.append(k)
		by[k].append("%s  %s" % [h.date, h.text])
	order.sort()
	var out: Array = []
	for k in order:
		out.append({"key": k, "lines": by[k]})
	return out

## 历史分页块：前半年 / 后半年 翻页（si = -1 表示全局）
func _history_block(parent: Node, si: int) -> void:
	var groups := _history_groups(si)
	var page := [maxi(groups.size() - 1, 0)]
	var head := _row(parent)
	var prev_btn := Button.new()
	prev_btn.text = t("HistoryHalfYearPrev", "前半年")
	var title := _body_label()
	title.add_theme_font_size_override("font_size", 16)
	var next_btn := Button.new()
	next_btn.text = t("HistoryHalfYearNext", "后半年")
	head.add_child(prev_btn)
	head.add_child(title)
	head.add_child(next_btn)
	_mk_btn(head, "导出", Callable(self, "_export_history"))
	var list := _body_label()
	list.custom_minimum_size = Vector2(0, 150)
	parent.add_child(list)
	var render := func() -> void:
		if groups.is_empty():
			title.text = t("NoHistoryRecords", "没有历史记录")
			list.text = ""
			return
		var idx: int = clampi(page[0], 0, groups.size() - 1)
		page[0] = idx
		title.text = "  %s  (%d/%d)  " % [str(groups[idx].key), idx + 1, groups.size()]
		list.text = "\n".join(PackedStringArray(groups[idx].lines))
	prev_btn.pressed.connect(func() -> void:
		page[0] = maxi(0, page[0] - 1)
		render.call())
	next_btn.pressed.connect(func() -> void:
		page[0] = mini(groups.size() - 1, page[0] + 1)
		render.call())
	render.call()

func _export_history() -> void:
	DirAccess.make_dir_recursive_absolute("user://exports")
	var path := "user://exports/history_%d.txt" % Time.get_ticks_msec()
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		for h in sim.history:
			f.store_line("%s  %s" % [h.date, h.text])
		f.close()
		_push_banner(t("HistoryExportCompleted", "历史记录导出完成！") + " " + ProjectSettings.globalize_path(path))

# ==================== 左侧停靠面板 / 折叠区 / 彩色动作按钮 ====================
## 原版 StateInfoUI / ProvinceInfoUI 都是贴边停靠面板 + 图标折叠标题 + 彩色按钮，
## 这里按截图观感实现通用件（参考原版截图：国家信息面板宽约 300px，占满高度）
func _base_dock(title: String, width := 300.0, side := "left") -> Dictionary:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _paper_style())
	if side == "left":
		panel.anchor_left = 0.0
		panel.anchor_right = 0.0
		panel.offset_left = 8
		panel.offset_right = 8 + width
	else:
		panel.anchor_left = 1.0
		panel.anchor_right = 1.0
		panel.offset_left = -8 - width
		panel.offset_right = -8
	panel.anchor_top = 0.0
	panel.anchor_bottom = 1.0
	panel.offset_top = 8
	panel.offset_bottom = -76
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 4)
	panel.add_child(outer)
	var ttl := Label.new()
	ttl.text = title
	ttl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ttl.add_theme_font_size_override("font_size", 26)
	ttl.add_theme_color_override("font_color", Color(0.12, 0.10, 0.08))
	outer.add_child(ttl)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 5)
	scroll.add_child(vb)
	return {"panel": panel, "vbox": vb}

## 折叠区（原版标题左侧图标 + 右侧 ^/v 箭头）
func _collapsible(parent: Node, title: String, open := true) -> VBoxContainer:
	var head := Button.new()
	head.toggle_mode = false
	head.alignment = HORIZONTAL_ALIGNMENT_LEFT
	head.text = ("⌃ " if open else "⌄ ") + title
	head.add_theme_font_size_override("font_size", 17)
	head.add_theme_color_override("font_color", Color(0.10, 0.09, 0.07))
	head.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	head.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	head.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	parent.add_child(head)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 4)
	body.visible = open
	parent.add_child(body)
	head.pressed.connect(func() -> void:
		body.visible = not body.visible
		head.text = ("⌃ " if body.visible else "⌄ ") + title)
	return body

func _action_btn(parent: Node, text: String, col: Color, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var st := StyleBoxFlat.new()
	st.bg_color = col
	st.corner_radius_top_left = 6
	st.corner_radius_top_right = 6
	st.corner_radius_bottom_left = 6
	st.corner_radius_bottom_right = 6
	st.content_margin_top = 4
	st.content_margin_bottom = 4
	b.add_theme_stylebox_override("normal", st)
	var hov := st.duplicate()
	hov.bg_color = col.lightened(0.12)
	b.add_theme_stylebox_override("hover", hov)
	b.add_theme_stylebox_override("pressed", st)
	b.add_theme_color_override("font_color", Color(0.12, 0.10, 0.08))
	b.add_theme_font_size_override("font_size", 15)
	b.pressed.connect(cb)
	parent.add_child(b)
	return b

func _action_row(parent: Node, a: Array, b: Array) -> HBoxContainer:
	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", 6)
	parent.add_child(r)
	_action_btn(r, a[0], a[1], a[2])
	if b.size() > 0:
		_action_btn(r, b[0], b[1], b[2])
	return r

## 人口显示：原版为"406.8万"这种格式
func _fmt_pop(n: int) -> String:
	if n >= 10000:
		return "%.1f万" % (float(n) / 10000.0)
	return str(n)

# ==================== 国家信息面板（对齐原版 StateInfoUI：左停靠 + 折叠区 + 彩色动作） ====================
func _open_state_panel(si: int) -> void:
	if si < 0 or si >= gen.states.size():
		return
	var s: Dictionary = gen.states[si]
	if not s.alive:
		_push_banner("%s（已灭亡）" % s.name)
		return
	var ui := _base_dock(t("StateInfo", "国家信息"), 306.0, "left")
	var body: VBoxContainer = ui.vbox
	var refresh := func() -> void:
		_close_panels()
		_open_state_panel(si)

	# —— 国名 + 颜色条（原版：灰色输入框 + 一条国家色）——
	var name_edit := LineEdit.new()
	name_edit.text = s.name
	name_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_edit.add_theme_color_override("font_color", Color(0.10, 0.09, 0.07))
	var ns := StyleBoxFlat.new()
	ns.bg_color = Color(0.86, 0.86, 0.86)
	ns.corner_radius_top_left = 3
	ns.corner_radius_top_right = 3
	ns.corner_radius_bottom_left = 3
	ns.corner_radius_bottom_right = 3
	name_edit.add_theme_stylebox_override("normal", ns)
	name_edit.text_changed.connect(func(v: String) -> void:
		s.name = v
		map_render.mark_dirty())
	body.add_child(name_edit)
	var colorbar := ColorPickerButton.new()
	colorbar.color = s.color
	colorbar.custom_minimum_size = Vector2(0, 12)
	colorbar.flat = true
	colorbar.color_changed.connect(func(c: Color) -> void:
		s.color = c
		map_render.mark_dirty())
	body.add_child(colorbar)

	# —— 基本信息 ——
	var sec_basic := _collapsible(body, "⚑ " + t("BasicInfo", "基本信息"), true)
	var polities := ["君主制", "帝制", "共和制", "联邦制", "城邦联盟", "神权政体", "部落制"]
	var r_pol := _row(sec_basic)
	r_pol.add_child(_kv(t("PoliticalSystem", "政治体制")))
	var opt_pol := OptionButton.new()
	for p in polities:
		opt_pol.add_item(p)
	opt_pol.select(maxi(0, polities.find(str(s.polity))))
	opt_pol.custom_minimum_size = Vector2(150, 0)
	opt_pol.item_selected.connect(func(i: int) -> void:
		s.polity = polities[i])
	r_pol.add_child(opt_pol)
	var cul := LineEdit.new()
	cul.text = str(s.get("culture", "—"))
	cul.add_theme_color_override("font_color", Color(0.10, 0.09, 0.07))
	cul.text_changed.connect(func(v: String) -> void: s.culture = v)
	_info_row_edit(sec_basic, t("Culture", "文化"), cul)
	var rel := LineEdit.new()
	rel.text = str(s.get("religion", "—"))
	rel.add_theme_color_override("font_color", Color(0.10, 0.09, 0.07))
	rel.text_changed.connect(func(v: String) -> void: s.religion = v)
	_info_row_edit(sec_basic, t("Religion", "宗教"), rel)
	var tr := LineEdit.new()
	tr.text = str(s.get("trait", "—"))
	tr.add_theme_color_override("font_color", Color(0.10, 0.09, 0.07))
	tr.text_changed.connect(func(v: String) -> void: s.trait = v)
	_info_row_edit(sec_basic, "民族特征", tr)

	# —— 信息表（与原版逐行对应）——
	_info_row(sec_basic, t("StateName", "国家"), str(s.name))
	var founded: int = int(s.get("founded_year", sim.year))
	_info_row(sec_basic, "存在时间", "%d 年" % maxi(0, sim.year - founded))
	var leader: Dictionary = s.get("leader", {})
	_info_row(sec_basic, t("Leader", "皇帝"), str(leader.get("name", "—")))
	var officials: Dictionary = s.get("officials", {})
	for title in ["内阁首辅", "户部尚书", "兵部尚书"]:
		_info_row(sec_basic, title, str(officials.get(title, "—")))
	var cap_name := "—"
	if int(s.capital) >= 0 and int(s.capital) < gen.provinces.size():
		cap_name = gen.provinces[int(s.capital)].name
	_info_row(sec_basic, t("Capital", "首都"), cap_name)
	_info_row(sec_basic, t("Population", "人口"), _fmt_pop(sim._state_power(si)))
	_info_row(sec_basic, "人口上限", _fmt_pop(gen.state_pop_cap(si)))
	_info_row(sec_basic, "腐败度", sim.corruption_label(int(s.get("corruption", 20))))
	_info_row(sec_basic, t("Gold", "金币"), "%.0f" % float(s.get("gold", 0.0)))
	_info_row(sec_basic, "月收入", "%.1f" % float(s.get("gold_per_month", 0.0) if float(s.get("gold_per_month", 0.0)) >= 0 else 0.0))
	var exp_now: float = float(s.get("gold_per_month", 0.0))
	_info_row(sec_basic, "月结余", "%+.1f" % exp_now)
	_info_row(sec_basic, "国库", str(int(s.get("treasury", 0))))
	_info_row(sec_basic, t("Army", "军队数量"), str(int(s.get("army", 0))))
	_info_row(sec_basic, t("WarshipCount", "战舰数量"), str(int(s.get("warships", 0))))
	_info_row(sec_basic, t("ProvinceCount", "行省数量"), str(s.provinces.size()))
	_info_row(sec_basic, "区域数量", str(gen.state_district_count(si)))

	# —— 国家行为（彩色按钮，全部有真实后果）——
	var sec_act := _collapsible(body, "⚑ " + t("StateActions", "国家行为"), true)
	var PINK := Color(0.96, 0.72, 0.80)
	var RED := Color(0.88, 0.36, 0.42)
	var BLUE := Color(0.56, 0.72, 0.91)
	var GREEN := Color(0.66, 0.90, 0.62)
	var YELLOW := Color(0.95, 0.85, 0.54)
	var GRAY := Color(0.73, 0.78, 0.85)
	_action_row(sec_act, ["扩张", PINK, func() -> void:
		_push_banner(sim.act_expand(si))
		refresh.call()],
		["煽动叛乱", PINK, func() -> void:
			_push_banner(sim.act_incite_rebellion(si))
			map_render.mark_dirty()
			refresh.call()])
	_action_row(sec_act, [t("CivilWar", "内战"), RED, func() -> void:
		_push_banner(sim.act_civil_war(si))
		map_render.mark_dirty()
		refresh.call()],
		["吞并", RED, func() -> void:
			_push_banner(sim.act_annex(si))
			map_render.mark_dirty()
			refresh.call()])
	_action_row(sec_act, ["发起战争", PINK, func() -> void:
		_close_panels()
		_open_war_declare_panel(si)],
		["停战", PINK, func() -> void:
			_push_banner(sim.act_peace(si))
			refresh.call()])
	_action_row(sec_act, [t("Alliance", "缔结盟约"), BLUE, func() -> void:
		_close_panels()
		_open_alliance_panel(si)],
		["退出同盟", BLUE, func() -> void:
			_push_banner(sim.act_break_alliance(si))
			refresh.call()])

	var sec_cor := _collapsible(body, "腐败度", true)
	_action_row(sec_cor, ["降低", YELLOW, func() -> void:
		_push_banner(sim.act_corruption(si, -10))
		refresh.call()],
		["加深", YELLOW, func() -> void:
			_push_banner(sim.act_corruption(si, 10))
			refresh.call()])

	var sec_vas := _collapsible(body, t("Vassal", "附庸国"), true)
	_action_row(sec_vas, ["收为附庸", GREEN, func() -> void:
		_push_banner(sim.act_make_vassal(si))
		refresh.call()],
		["独立", GREEN, func() -> void:
			_push_banner(sim.act_release_vassal(si))
			refresh.call()])

	var sec_set := _collapsible(body, "设置", true)
	var dip_row := _row(sec_set)
	var dip_btn := Button.new()
	dip_btn.text = t("AutoDiplomacy", "自主外交") + "：" + ("开" if bool(s.get("auto_diplomacy", true)) else "关")
	dip_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dip_btn.pressed.connect(func() -> void:
		s.auto_diplomacy = not bool(s.get("auto_diplomacy", true))
		dip_btn.text = t("AutoDiplomacy", "自主外交") + "：" + ("开" if bool(s.auto_diplomacy) else "关"))
	dip_row.add_child(dip_btn)

	# —— 军团数量 + 放置军队（原版：输入框 + 按钮）——
	var sec_army := _collapsible(body, "输入军团数量", true)
	var army_edit := LineEdit.new()
	army_edit.text = "1"
	army_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	army_edit.add_theme_color_override("font_color", Color(0.10, 0.09, 0.07))
	army_edit.add_theme_stylebox_override("normal", ns)
	sec_army.add_child(army_edit)
	_action_btn(sec_army, "放置军队", RED, func() -> void:
		var nn: int = maxi(1, mini(int(army_edit.text) if army_edit.text.is_valid_int() else 1, 10))
		_place_mode_si = si
		_place_mode_n = nn
		_close_panels()
		_push_banner("部署模式：点击本国任意省份放置 %d 支野战军（Esc 取消）" % nn))
	_action_btn(sec_army, "生成家族", BLUE, func() -> void:
		s.families = 1 + int(s.get("families", 0))
		_push_banner("已为 %s 生成家族（%d）" % [s.name, int(s.families)]))

	# —— 领土记录 / 战争 / 外交 / 历史 ——
	var sec_land := _collapsible(body, "▤ 领土记录", false)
	_info_row(sec_land, t("ProvinceCount", "行省数量"), str(s.provinces.size()))
	var sea_touch := 0
	for pi in s.provinces:
		for nb in gen.provinces[pi].neighbors:
			if gen.provinces[nb].get("is_sea", false):
				sea_touch += 1
				break
	_info_row(sec_land, "沿海行省", str(sea_touch))
	var sec_war := _collapsible(body, "⚔ 战争", false)
	var ws: Array = sim.state_wars(si)
	if ws.is_empty():
		_info_row(sec_war, t("WarStatus", "战争状态"), "无进行中的战争")
	else:
		for w in ws:
			var foe: int = int(w.d) if int(w.a) == si else int(w.a)
			_info_row(sec_war, t("War", "战争"), "%s · %s · %s · 分数 %.0f" % [
				gen.states[foe].name, t(str(w.type), str(w.type)),
				sim._dur_text(int(w.months)), float(w.score)])
	var recs: Array = sim.war_records.filter(func(x): return int(x.a) == si or int(x.d) == si)
	if recs.size() > 0:
		var last: Dictionary = recs[recs.size() - 1]
		_info_row(sec_war, t("WarRecord", "战争记录"), str(last.text))
	var sec_dip := _collapsible(body, "◇ 外交", false)
	var vassal_of := int(s.get("vassal_of", -1))
	if vassal_of >= 0 and vassal_of < gen.states.size():
		_info_row(sec_dip, "宗主", gen.states[vassal_of].name)
	var vassals: Array = []
	for ti in gen.states.size():
		if int(gen.states[ti].get("vassal_of", -1)) == si:
			vassals.append(gen.states[ti].name)
	_info_row(sec_dip, t("Vassal", "附庸国"), "、".join(PackedStringArray(vassals)) if vassals.size() > 0 else "无")
	var ally_names: Array = []
	for ai in s.get("allies", []):
		if int(ai) >= 0 and int(ai) < gen.states.size():
			ally_names.append(gen.states[int(ai)].name)
	_info_row(sec_dip, t("Alliance", "缔结盟约"), "、".join(PackedStringArray(ally_names)) if ally_names.size() > 0 else "无")
	var sec_hist := _collapsible(body, "▣ 历史记录", false)
	_history_block(sec_hist, si)

	var follow := Button.new()
	follow.text = t("CameraFollow", "镜头跟随（前往首都）")
	follow.pressed.connect(func() -> void:
		if int(s.capital) >= 0 and int(s.capital) < gen.provinces.size():
			cam.position = gen.provinces[int(s.capital)].burg
		_close_panels())
	body.add_child(follow)
	_finish(ui)
	_toggle_panel(ui.panel)

## 带输入框的信息行
func _info_row_edit(parent: Node, k: String, field: Control) -> void:
	var r := _row(parent)
	r.add_child(_kv(k))
	field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.add_child(field)

# ==================== 行省信息面板（对齐原版 ProvinceInfoUI 字段面） ====================
func _open_province_panel(pi: int) -> void:
	if pi < 0 or pi >= gen.provinces.size():
		return
	var p: Dictionary = gen.provinces[pi]
	if p.get("is_sea", false) or int(p.state) < 0:
		_open_sea_province_panel(pi)
		return
	var s: Dictionary = gen.states[p.state]
	# 版式与国家面板一致：左停靠满高 + 折叠区（原版两个面板同一套 UI 骨架）
	var ui := _base_dock(t("ProvinceInfo", "行省信息"), 306.0, "left")
	var body: VBoxContainer = ui.vbox

	var name_edit := LineEdit.new()
	name_edit.text = p.name
	name_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_edit.add_theme_color_override("font_color", Color(0.10, 0.09, 0.07))
	var ns2 := StyleBoxFlat.new()
	ns2.bg_color = Color(0.86, 0.86, 0.86)
	ns2.corner_radius_top_left = 3
	ns2.corner_radius_top_right = 3
	ns2.corner_radius_bottom_left = 3
	ns2.corner_radius_bottom_right = 3
	name_edit.add_theme_stylebox_override("normal", ns2)
	name_edit.text_changed.connect(func(v: String) -> void:
		p.name = v
		map_render.mark_dirty())
	body.add_child(name_edit)

	_info_row(body, t("StateName", "所属国家"), "%s%s" % [s.name, "" if s.alive else "（已灭亡）"])
	_info_row(body, "格数", str(p.cells.size()))

	# —— 行省类型（原版 ProvinceInfoUI：设为城市 / 要塞 / 区域中心）——
	var sec_type := _collapsible(body, "行省类型", true)
	var type_lab := _body_label()
	var kind_now := func() -> String: return str(p.get("kind", ""))
	type_lab.text = "当前：%s" % ("无" if kind_now.call() == "" else str(kind_now.call()))
	sec_type.add_child(type_lab)
	var r_type := _row(sec_type)
	for kind in ["城市", "要塞", "区域中心"]:
		var kk: String = kind
		_mk_btn(r_type, "设为" + kk, func() -> void:
			p.kind = kk
			if kk == "城市":
				p.max_pop = int(p.get("max_pop", 1000)) + 500
				p.max_defense = int(p.get("max_defense", 100)) + 30
			elif kk == "要塞":
				p.max_defense = int(p.get("max_defense", 100)) + 80
			else:
				p.district_max_pop = int(p.get("district_max_pop", 100)) + 200
				p.district_max_defense = int(p.get("district_max_defense", 60)) + 40
			type_lab.text = "当前：%s" % kk
			map_render.mark_dirty())

	# —— 人口（当前/最大 + 自定义人口）——
	var sec_pop := _collapsible(body, t("Population", "人口"), true)
	var pop_lab := _body_label()
	var refresh_pop := func() -> void:
		pop_lab.text = "%s：%d    %s：%d" % [t("CurrentPopulation", "当前人口"), int(p.pop), t("MaxPopulation", "最大人口"), int(p.get("max_pop", 0))]
	refresh_pop.call()
	sec_pop.add_child(pop_lab)
	var r_pop := _row(sec_pop)
	var pop_edit := LineEdit.new()
	pop_edit.placeholder_text = "输入人口"
	pop_edit.custom_minimum_size = Vector2(120, 0)
	pop_edit.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	r_pop.add_child(pop_edit)
	_mk_btn(r_pop, t("btn_SetCustomPopulation", "自定义人口"), func() -> void:
		var v := int(pop_edit.text)
		if v > 0:
			p.pop = v
			if int(p.get("max_pop", 0)) < v:
				p.max_pop = v
			refresh_pop.call()
			map_render.mark_dirty())

	# —— 城防（当前/最大 + 自定义防御）——
	var sec_def := _collapsible(body, t("CurrentCityDefense", "当前城市防御"), true)
	var def_lab := _body_label()
	var refresh_def := func() -> void:
		def_lab.text = "%s：%d    %s：%d" % [t("CurrentCityDefense", "当前城市防御"), int(p.defense), t("MaxCityDefense", "最大城市防御"), int(p.get("max_defense", 0))]
	refresh_def.call()
	sec_def.add_child(def_lab)
	var r_def := _row(sec_def)
	var def_edit := LineEdit.new()
	def_edit.placeholder_text = "输入防御"
	def_edit.custom_minimum_size = Vector2(120, 0)
	def_edit.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	r_def.add_child(def_edit)
	_mk_btn(r_def, t("btn_SetCustomDefense", "自定义防御"), func() -> void:
		var v := int(def_edit.text)
		if v > 0:
			p.defense = v
			if int(p.get("max_defense", 0)) < v:
				p.max_defense = v
			refresh_def.call())

	# —— 区域（原版 District* 字段：区域人口 / 区域防御）——
	var sec_d := _collapsible(body, "区域", true)
	_info_row(sec_d, t("DistrictCurrentPopulation", "区域当前人口"), "%d / %d" % [int(p.get("district_pop", 0)), int(p.get("district_max_pop", 0))])
	_info_row(sec_d, "区域防御", "%d / %d" % [int(p.get("district_defense", 0)), int(p.get("district_max_defense", 0))])
	var r_d := _row(sec_d)
	var d_pop_edit := LineEdit.new()
	d_pop_edit.placeholder_text = "区域人口"
	d_pop_edit.custom_minimum_size = Vector2(110, 0)
	d_pop_edit.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	r_d.add_child(d_pop_edit)
	_mk_btn(r_d, t("btn_SetDistrictCustomPopulation", "区域人口"), func() -> void:
		var v := int(d_pop_edit.text)
		if v >= 0:
			p.district_pop = v
			if int(p.get("district_max_pop", 0)) < v:
				p.district_max_pop = v
			_close_panels()
			_open_province_panel(pi))
	var d_def_edit := LineEdit.new()
	d_def_edit.placeholder_text = "区域防御"
	d_def_edit.custom_minimum_size = Vector2(110, 0)
	d_def_edit.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	r_d.add_child(d_def_edit)
	_mk_btn(r_d, t("btn_SetDistrictCustomDefense", "区域防御"), func() -> void:
		var v := int(d_def_edit.text)
		if v >= 0:
			p.district_defense = v
			if int(p.get("district_max_defense", 0)) < v:
				p.district_max_defense = v
			_close_panels()
			_open_province_panel(pi))

	# —— 操作：设为首都 / 发动叛乱 ——
	var sec_act := _collapsible(body, "操作", true)
	var r_act := _row(sec_act)
	_mk_btn(r_act, t("SetAsCapital", "设为首都"), func() -> void:
		var si2: int = p.state
		gen.states[si2].capital = pi
		for q in gen.provinces.size():
			gen.provinces[q].is_capital_burg = false
		p.is_capital_burg = true
		map_render.mark_dirty()
		_push_banner("%s：%s 设为 %s 首都" % [t("SetAsCapital", "设为首都"), p.name, gen.states[si2].name])
		_close_panels())
	_mk_btn(r_act, t("StartRebellion", "发动叛乱"), func() -> void:
		if gen.states[p.state].provinces.size() > 1:
			var new_si := gen.states.size()
			var old_si: int = p.state
			gen.states[old_si].provinces.erase(pi)
			if gen.states[old_si].provinces.is_empty():
				gen.states[old_si].alive = false
			gen.states.append({"name": p.name + "义军", "color": Color(0.75, 0.2, 0.15),
				"capital": pi, "provinces": [pi], "alive": true,
				"centroid": p.burg, "polity": gen.states[old_si].polity, "auto_diplomacy": true,
				"mult": 1.0, "leader": gen._gen_leader(sim.rng), "culture": gen.states[old_si].culture,
				"religion": gen.states[old_si].religion, "army": 1, "warships": 0,
				"allies": [], "vassal_of": -1})
			p.state = new_si
			p.is_capital_burg = true
			map_render.mark_dirty()
			sim.history.append({"date": sim.date_str(),
				"text": t("Rebellion", "{0}发生叛乱").format({"0": p.name}), "state": new_si})
			_push_banner("%s：%s 独立" % [t("StartRebellion", "发动叛乱"), p.name])
			_close_panels())

	_finish(ui)
	_toggle_panel(ui.panel)

## 海域省面板（原版海洋省：属于"海洋"，不归属任何国家，没有城邑）
func _open_sea_province_panel(pi: int) -> void:
	var p: Dictionary = gen.provinces[pi]
	var ui := _base_panel("海洋省", Vector2(480, 320))
	_info_row(ui.vbox, t("ProvinceName", "行省名"), str(p.name))
	_info_row(ui.vbox, "类型", "海域")
	_info_row(ui.vbox, "格数", str(p.cells.size()))
	_info_row(ui.vbox, t("StateName", "所属国家"), "无（海洋）")
	var coast: Dictionary = p.get("coast_land_provs", {})
	_info_row(ui.vbox, "接壤陆地省", str(coast.size()))
	var hint := _body_label()
	hint.text = "海洋省由 CreateSeaProvinces / ExpandSeaProvinces 生成：按海域建省 + FIFO 洪水填充，不参与国家归属。"
	ui.vbox.add_child(hint)
	_finish(ui)
	_toggle_panel(ui.panel)

# ============================================================================
# 四层地图编辑器（高度 / 群系 / 行省 / 国家）—— UI 与输入接线
# 规格来源：原版 EditPanelUI 成员 + 官方文案（localization.csv）
#   EditMode 编辑模式 / EditHeight 编辑高度 / Biome 植被图 / DrawProvince 绘制行省 /
#   DrawState 绘制国家 / BrushRadius 笔刷半径 / BrushHeight 笔刷高度 / DecayFactor 衰减系数 /
#   PlaceContinent 放置大陆 / EraseContinent 擦除陆地 / PlaceProvince 放置行省 /
#   AddProvince 添加行省 / GlobalCommands 全局指令
# ============================================================================

const EDIT_LAYERS := ["关闭", "编辑高度", "编辑行省", "编辑生态", "编辑国家", "编辑区域", "编辑无人区",
	"编辑文化", "编辑宗教", "编辑标签", "编辑图片", "编辑家族", "全局指令"]
const VIEW_NAMES := ["政治图", "高度图", "植被图"]

const MapEditorNS := preload("res://scripts/map_editor.gd")
var editor: Node
var editor_dock: PanelContainer
var editor_groups := {}
var _editor_labels := {}

func _init_editor() -> void:
	editor = MapEditorNS.new()
	add_child(editor)
	editor.setup(gen, map_render)
	editor.data_changed.connect(_on_editor_changed)
	editor.status_changed.connect(_push_banner)
	cam.paint_started.connect(_on_paint_start)
	cam.paint_moved.connect(_on_paint_move)
	cam.paint_ended.connect(_on_paint_end)
	cam.hover_moved.connect(_on_hover)
	cam.brush_radius_step.connect(_on_brush_step)

func _on_editor_changed() -> void:
	_refresh_editor_ui()
	if editor.layer == MapEditorNS.Layer.PROVINCE or editor.layer == MapEditorNS.Layer.STATE:
		sim.map_changed.emit()

func _on_hover(world_pos: Vector2) -> void:
	if editor == null or not editor.active:
		return
	var col := Color(0.15, 0.13, 0.11, 0.75)
	match editor.layer:
		MapEditorNS.Layer.HEIGHT: col = Color(0.25, 0.20, 0.15, 0.8)
		MapEditorNS.Layer.BIOME: col = MapGen.BIOME_COLORS[editor.target_biome]
		MapEditorNS.Layer.PROVINCE: col = Color(0.15, 0.35, 0.75, 0.85)
		MapEditorNS.Layer.STATE: col = Color(0.75, 0.25, 0.15, 0.85)
	map_render.brush_preview = {"pos": world_pos, "radius": float(editor.brush_radius), "color": col}
	if map_render.overlay:
		map_render.overlay.queue_redraw()

## 编辑器快捷键（原版 BrushManager.IsBrushRadiusShortcutActive / Ctrl / Alt 的语义）
func _unhandled_key_input(event: InputEvent) -> void:
	# Esc 取消部署模式（优先于编辑器快捷键；V5.1 交互规则：取消操作安全退出当前模式）
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if _place_mode_si >= 0:
			_place_mode_si = -1
			_push_banner("已取消部署模式")
			return
	if editor == null or not editor.active:
		return
	var k := event as InputEventKey
	if k == null or not k.pressed or k.echo:
		return
	if k.ctrl_pressed and k.keycode == KEY_Z:
		editor.undo()
		_refresh_editor_ui()
	elif k.ctrl_pressed and k.keycode == KEY_Y:
		editor.redo()
		_refresh_editor_ui()
	elif k.keycode == KEY_BRACKETLEFT:
		_on_brush_step(-1)
	elif k.keycode == KEY_BRACKETRIGHT:
		_on_brush_step(1)
	elif k.keycode == KEY_ESCAPE:
		_close_editor()


func _on_brush_step(d: int) -> void:
	if editor == null:
		return
	editor.brush_radius = clampi(editor.brush_radius + d, 1, 30)
	_refresh_editor_ui()

func _on_paint_start(world_pos: Vector2) -> void:
	if editor == null or _input_disabled:
		return
	if _editor_pending != "":
		match _editor_pending:
			"continent":
				editor.place_continent(world_pos)
			"erase":
				editor.erase_land(world_pos)
			"province":
				editor.place_province(world_pos)
			"state":
				editor.place_state(world_pos)
		_editor_pending = ""
		_refresh_editor_ui()
		return
	if Input.is_key_pressed(KEY_ALT) and editor.layer == MapEditorNS.Layer.PROVINCE:
		editor.set_province_capital_at(world_pos)
		return
	editor.begin_stroke(world_pos)
	_on_hover(world_pos)

func _on_paint_move(world_pos: Vector2) -> void:
	if editor == null:
		return
	editor.move_stroke(world_pos)
	_on_hover(world_pos)

func _on_paint_end() -> void:
	if editor:
		editor.end_stroke()

func _toggle_editor() -> void:
	if editor_dock != null:
		_close_editor()
		return
	# 原版 PauseWhenEditing：进入编辑自动暂停，工具栏按钮显示"继续游戏"
	time_scale = 0
	_update_speed_label()
	_set_toolbar_text(7, "继续游戏")
	editor_dock = _build_editor_dock()
	hud.add_child(editor_dock)
	editor.set_layer(MapEditorNS.Layer.HEIGHT)
	cam.paint_mode = true
	map_render.view_mode = MapRender.View.POLITICAL
	_push_banner("地图编辑已开启：左键绘制，右键拖动平移，Shift+左键选择，Ctrl+滚轮调笔刷半径")
	_refresh_editor_ui()

func _close_editor() -> void:
	_editor_pending = ""
	if editor_dock != null:
		editor_dock.queue_free()
		editor_dock = null
	editor_groups.clear()
	_editor_labels.clear()
	editor.set_layer(MapEditorNS.Layer.NONE)
	cam.paint_mode = false
	map_render.brush_preview = {}
	if map_render.overlay:
		map_render.overlay.queue_redraw()
	map_render.mark_dirty()
	_set_toolbar_text(7, "暂停游戏")
	_push_banner("地图编辑已关闭")

func _build_editor_dock() -> PanelContainer:
	# 版式对照原版截图：右上角窄面板（宽约 200），标题「地图编辑」→ 模式下拉 → 分页 →
	# 随机国家 → 笔刷半径 → 2×2 按钮（编辑/删除/绘制/擦除）→ 提示 / 清空地图 / 关闭面板
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _paper_style())
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.anchor_top = 0.0
	panel.anchor_bottom = 1.0
	panel.offset_left = -262
	panel.offset_right = -12
	panel.offset_top = 12
	panel.offset_bottom = -76
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 5)
	panel.add_child(outer)

	var title := Label.new()
	title.text = t("MapEditing", "地图编辑")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.12, 0.10, 0.08))
	outer.add_child(title)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	var vb := VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 5)
	scroll.add_child(vb)

	# —— 编辑模式下拉（12 项与官方文案一致；未实现的模式点击时提示）——
	var mode_opt := OptionButton.new()
	for n in EDIT_LAYERS:
		mode_opt.add_item(n)
	mode_opt.selected = 1
	mode_opt.custom_minimum_size = Vector2(230, 0)
	_editor_labels["mode_opt"] = mode_opt
	mode_opt.item_selected.connect(func(i: int) -> void:
		_apply_edit_mode(i))
	vb.add_child(mode_opt)

	# —— 分页（原版 Page X of Y：用于国家列表翻页）——
	var page_row := HBoxContainer.new()
	page_row.add_theme_constant_override("separation", 2)
	vb.add_child(page_row)
	var prev_btn := Button.new()
	prev_btn.text = "<<"
	prev_btn.custom_minimum_size = Vector2(30, 0)
	var page_lab := _body_label()
	page_lab.add_theme_font_size_override("font_size", 14)
	page_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page_lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var next_btn := Button.new()
	next_btn.text = ">>"
	next_btn.custom_minimum_size = Vector2(30, 0)
	page_row.add_child(prev_btn)
	page_row.add_child(page_lab)
	page_row.add_child(next_btn)
	_editor_labels["page_lab"] = page_lab
	var state_grid := GridContainer.new()
	state_grid.columns = 3
	state_grid.add_theme_constant_override("h_separation", 3)
	state_grid.add_theme_constant_override("v_separation", 3)
	state_grid.visible = false
	vb.add_child(state_grid)
	_editor_labels["state_grid"] = state_grid
	var render_page := func() -> void:
		var per := 6
		var total: int = maxi(1, int(ceil(float(gen.states.size()) / float(per))))
		editor_page = clampi(editor_page, 0, total - 1)
		page_lab.text = "Page %d of %d" % [editor_page + 1, total]
		for ch in state_grid.get_children():
			ch.queue_free()
		var s0: int = editor_page * per
		for k in per:
			var si: int = s0 + k
			if si >= gen.states.size():
				break
			var st: Dictionary = gen.states[si]
			var b := Button.new()
			b.text = str(st.name)
			b.custom_minimum_size = Vector2(60, 24)
			b.clip_text = true
			if not st.alive:
				b.modulate = Color(1, 1, 1, 0.45)
			else:
				b.add_theme_color_override("font_color", Color(0.12, 0.10, 0.08))
			b.pressed.connect(func() -> void:
				editor.target_state = si
				editor.merge_state_src = -1
				_refresh_editor_ui())
			state_grid.add_child(b)
	prev_btn.pressed.connect(func() -> void:
		editor_page -= 1
		render_page.call())
	next_btn.pressed.connect(func() -> void:
		editor_page += 1
		render_page.call())
	_editor_labels["render_page"] = render_page

	# —— 随机国家（原版蓝色按钮）——
	var rnd_state := _action_btn(vb, "随机国家", Color(0.56, 0.72, 0.91), func() -> void:
		var alive: Array = []
		for si in gen.states.size():
			if gen.states[si].alive:
				alive.append(si)
		if not alive.is_empty():
			editor.target_state = alive[randi() % alive.size()]
			editor.set_layer(3)
			_apply_edit_mode(4)
			_push_banner("随机选中：%s" % gen.states[editor.target_state].name))
	rnd_state.add_theme_font_size_override("font_size", 15)

	# —— 各模式专属控件 ——
	var g_height := VBoxContainer.new()
	vb.add_child(g_height)
	editor_groups["height"] = g_height
	var r_h := _row(g_height)
	r_h.add_child(_kv_s(t("BrushHeight", "笔刷高度")))
	var sl_h := HSlider.new()
	sl_h.min_value = 5
	sl_h.max_value = 100
	sl_h.step = 1
	sl_h.value = editor.brush_height
	sl_h.custom_minimum_size = Vector2(100, 0)
	sl_h.value_changed.connect(func(v: float) -> void:
		editor.brush_height = v
		_refresh_editor_ui())
	r_h.add_child(sl_h)
	var val_h := _body_label()
	val_h.custom_minimum_size = Vector2(30, 0)
	val_h.text = "%d" % int(editor.brush_height)
	_editor_labels["height"] = val_h
	_editor_labels["height_slider"] = sl_h
	r_h.add_child(val_h)
	var r_d := _row(g_height)
	r_d.add_child(_kv_s(t("DecayFactor", "衰减系数")))
	var sl_d := HSlider.new()
	sl_d.min_value = 0.05
	sl_d.max_value = 1.0
	sl_d.step = 0.05
	sl_d.value = editor.decay
	sl_d.custom_minimum_size = Vector2(100, 0)
	sl_d.value_changed.connect(func(v: float) -> void:
		editor.decay = v
		_refresh_editor_ui())
	r_d.add_child(sl_d)
	var val_d := _body_label()
	val_d.custom_minimum_size = Vector2(36, 0)
	val_d.text = "%.2f" % editor.decay
	_editor_labels["decay"] = val_d
	r_d.add_child(val_d)
	_action_btn(g_height, t("GenHeightMap", "生成高度图"), Color(0.86, 0.86, 0.86), func() -> void:
		editor.generate_heightmap(Time.get_ticks_msec() % 100000))
	_action_btn(g_height, t("PlaceContinent", "放置大陆"), Color(0.86, 0.86, 0.86), func() -> void:
		_editor_pending = "continent"
		_push_banner("放置大陆：点击地图落点"))

	var g_biome := VBoxContainer.new()
	vb.add_child(g_biome)
	editor_groups["biome"] = g_biome
	var biome_opt := OptionButton.new()
	for bi in gen.biome_names_zh.size():
		biome_opt.add_item("%d %s" % [bi, gen.biome_names_zh[bi]])
	biome_opt.selected = editor.target_biome
	biome_opt.custom_minimum_size = Vector2(230, 0)
	_editor_labels["biome_opt"] = biome_opt
	biome_opt.item_selected.connect(func(i: int) -> void:
		editor.target_biome = i
		_refresh_editor_ui())
	g_biome.add_child(biome_opt)
	var r_t := _row(g_biome)
	r_t.add_child(_kv_s("温度偏移"))
	var sl_t := HSlider.new()
	sl_t.min_value = -0.4
	sl_t.max_value = 0.4
	sl_t.step = 0.02
	sl_t.value = editor.temperature_modifier
	sl_t.custom_minimum_size = Vector2(120, 0)
	sl_t.value_changed.connect(func(v: float) -> void: editor.temperature_modifier = v)
	r_t.add_child(sl_t)
	var r_p := _row(g_biome)
	r_p.add_child(_kv_s("降水系数"))
	var sl_p := HSlider.new()
	sl_p.min_value = 0.3
	sl_p.max_value = 2.0
	sl_p.step = 0.05
	sl_p.value = editor.precipitation_factor
	sl_p.custom_minimum_size = Vector2(120, 0)
	sl_p.value_changed.connect(func(v: float) -> void: editor.precipitation_factor = v)
	r_p.add_child(sl_p)
	_action_btn(g_biome, "重算生态", Color(0.66, 0.90, 0.62), func() -> void:
		editor.regenerate_biomes(Time.get_ticks_msec() % 100000))

	var g_prov := VBoxContainer.new()
	vb.add_child(g_prov)
	editor_groups["province"] = g_prov
	var lb_prov := _body_label()
	lb_prov.text = ""
	lb_prov.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lb_prov.custom_minimum_size = Vector2(230, 0)
	_editor_labels["province"] = lb_prov
	g_prov.add_child(lb_prov)
	_action_btn(g_prov, t("PlaceProvince", "放置行省"), Color(0.86, 0.86, 0.86), func() -> void:
		_editor_pending = "province"
		_push_banner("放置行省：点击陆地生成 1 格新行省"))

	var g_state := VBoxContainer.new()
	vb.add_child(g_state)
	editor_groups["state"] = g_state
	var lb_state := _body_label()
	lb_state.text = ""
	lb_state.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lb_state.custom_minimum_size = Vector2(230, 0)
	_editor_labels["state"] = lb_state
	g_state.add_child(lb_state)

	# —— 笔刷半径（原版：标签 + 滑杆 + 数值 3.50）——
	var r_radius := _row(vb)
	r_radius.add_child(_kv_s(t("BrushRadius", "笔刷半径")))
	var sl_radius := HSlider.new()
	sl_radius.min_value = 1
	sl_radius.max_value = 30
	sl_radius.step = 1
	sl_radius.value = editor.brush_radius
	sl_radius.custom_minimum_size = Vector2(100, 0)
	sl_radius.value_changed.connect(func(v: float) -> void:
		editor.brush_radius = int(v)
		_refresh_editor_ui())
	r_radius.add_child(sl_radius)
	var val_radius := _body_label()
	val_radius.custom_minimum_size = Vector2(36, 0)
	val_radius.text = "%.2f" % float(editor.brush_radius)
	_editor_labels["radius"] = val_radius
	_editor_labels["radius_slider"] = sl_radius
	r_radius.add_child(val_radius)

	# —— 2×2：编辑 / 删除 / 绘制 / 擦除（与原版同色同序）——
	var grid2 := GridContainer.new()
	grid2.columns = 2
	grid2.add_theme_constant_override("h_separation", 4)
	grid2.add_theme_constant_override("v_separation", 4)
	vb.add_child(grid2)
	_action_btn(grid2, "编辑", Color(0.56, 0.72, 0.91), func() -> void:
		if editor.layer == MapEditorNS.Layer.PROVINCE and editor.target_province >= 0:
			_open_province_panel(editor.target_province)
		elif editor.layer == MapEditorNS.Layer.STATE and editor.target_state >= 0:
			_open_state_panel(editor.target_state)
		else:
			_push_banner("编辑：请先用 Shift+左键选中目标（或切成行省/国家模式）"))
	_action_btn(grid2, "删除", Color(0.88, 0.36, 0.42), func() -> void:
		if editor.layer == MapEditorNS.Layer.STATE and editor.target_state >= 0:
			_push_banner("已删除国家 %s" % gen.states[editor.target_state].name)
			editor.merge_states(editor.target_state, -1) if false else _delete_state(editor.target_state)
		elif editor.layer == MapEditorNS.Layer.PROVINCE and editor.target_province >= 0:
			_delete_province(editor.target_province)
		else:
			_push_banner("删除：请先选中要删除的行省/国家"))
	_action_btn(grid2, "绘制", Color(0.66, 0.90, 0.62), func() -> void:
		editor.paint_erase = false
		if editor.layer == MapEditorNS.Layer.NONE:
			_push_banner("请先选择编辑模式")
		else:
			_push_banner("绘制：" + editor.layer_name()))
	_action_btn(grid2, "擦除", Color(0.96, 0.66, 0.36), func() -> void:
		editor.paint_erase = true
		_push_banner("擦除：笔刷会把目标清成无主/海洋/海洋群系"))

	# —— 提示 / 清空地图 / 关闭面板 ——
	var tip := _body_label()
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.custom_minimum_size = Vector2(230, 0)
	tip.text = "左键绘制 · 右键拖动平移 · Shift+左键选择 · Ctrl+滚轮调半径 · Ctrl+Z 撤销"
	tip.visible = false
	vb.add_child(tip)
	_editor_labels["tip"] = tip
	_action_btn(vb, "提示", Color(0.86, 0.86, 0.86), func() -> void:
		tip.visible = not tip.visible)
	_action_btn(vb, t("ClearMap", "清空地图"), Color(0.86, 0.86, 0.86), func() -> void:
		editor.clear_map_all()
		render_page.call())
	_action_btn(vb, "关闭面板", Color(0.86, 0.86, 0.86), func() -> void:
		_close_editor())
	render_page.call()
	return panel

## 编辑模式下拉 → 内部图层（未实现的模式给出明确提示，不假装可用）
func _apply_edit_mode(i: int) -> void:
	render_page_visible(i)
	match i:
		1:
			editor.set_layer(MapEditorNS.Layer.HEIGHT)
			cam.paint_mode = true
		3:
			editor.set_layer(MapEditorNS.Layer.BIOME)
			cam.paint_mode = true
		2:
			editor.set_layer(MapEditorNS.Layer.PROVINCE)
			cam.paint_mode = true
		4:
			editor.set_layer(MapEditorNS.Layer.STATE)
			cam.paint_mode = true
		0:
			editor.set_layer(MapEditorNS.Layer.NONE)
			cam.paint_mode = false
		12:
			_toggle_panel(_build_global_commands_panel())
		_:
			cam.paint_mode = false
			_push_banner("%s：该模式尚未还原（原版 EditPanelUI 有此项，见 findings §9.1）" % EDIT_LAYERS[i])
	_refresh_editor_ui()

## 下拉索引 ↔ 内部图层：NONE=0, HEIGHT=1, PROVINCE=2, BIOME=3, STATE=4
func _layer_to_mode_index(l: int) -> int:
	match l:
		MapEditorNS.Layer.HEIGHT: return 1
		MapEditorNS.Layer.PROVINCE: return 2
		MapEditorNS.Layer.BIOME: return 3
		MapEditorNS.Layer.STATE: return 4
	return 0

func render_page_visible(mode_idx: int) -> void:
	if _editor_labels.has("state_grid"):
		(_editor_labels["state_grid"] as GridContainer).visible = mode_idx == 4

func _delete_state(si: int) -> void:
	if si < 0 or si >= gen.states.size():
		return
	for pi in gen.provinces.size():
		if int(gen.provinces[pi].state) == si:
			gen.provinces[pi].state = -1
	gen.rebuild_after_state_edit()
	map_render.mark_dirty()
	_refresh_editor_ui()
	_push_banner("已删除国家（其行省变为无主）")

func _delete_province(pi: int) -> void:
	if pi < 0 or pi >= gen.provinces.size():
		return
	for i in MapGen.W * MapGen.H:
		if gen.cell_province[i] == pi:
			gen.cell_province[i] = -1
	gen.rebuild_after_province_edit()
	editor.target_province = -1
	map_render.mark_dirty()
	_refresh_editor_ui()
	_push_banner("已删除行省（格子变为未绘制）")

var _editor_pending := ""
var _input_disabled := false
var editor_page := 0

func _refresh_editor_ui() -> void:
	if editor == null:
		return
	if _editor_labels.has("radius"):
		_editor_labels["radius"].text = "%.2f" % float(editor.brush_radius)
		_editor_labels["radius_slider"].value = editor.brush_radius
	if _editor_labels.has("height"):
		_editor_labels["height"].text = "%d" % int(editor.brush_height)
		_editor_labels["height_slider"].value = editor.brush_height
	if _editor_labels.has("decay"):
		_editor_labels["decay"].text = "%.2f" % editor.decay
	for k in editor_groups:
		var g: VBoxContainer = editor_groups[k]
		var on := false
		match k:
			"height": on = editor.layer == MapEditorNS.Layer.HEIGHT
			"biome": on = editor.layer == MapEditorNS.Layer.BIOME
			"province": on = editor.layer == MapEditorNS.Layer.PROVINCE
			"state": on = editor.layer == MapEditorNS.Layer.STATE
		g.visible = on
	if _editor_labels.has("province"):
		var pname := "（未选择：Shift+左键选择行省）"
		if editor.target_province >= 0 and editor.target_province < gen.provinces.size():
			var pv: Dictionary = gen.provinces[editor.target_province]
			var owner := "无主"
			if int(pv.state) >= 0 and int(pv.state) < gen.states.size():
				owner = gen.states[int(pv.state)].name
			pname = "当前绘制：%s（%d 格 · %s）" % [pv.name, pv.cells.size(), owner]
		if editor.merge_province_src >= 0 and editor.merge_province_src < gen.provinces.size():
			pname += "  ｜ 待并入：%s" % gen.provinces[editor.merge_province_src].name
		_editor_labels["province"].text = pname
	if _editor_labels.has("state"):
		var sname := "（未选择：Shift+左键选择国家）"
		if editor.target_state >= 0 and editor.target_state < gen.states.size():
			sname = "当前绘制：%s（%d 省）" % [gen.states[editor.target_state].name,
				gen.states[editor.target_state].provinces.size()]
		elif editor.target_state == -1:
			sname = "当前：擦除（行省变为无主）"
		if editor.merge_state_src >= 0 and editor.merge_state_src < gen.states.size():
			sname += "  ｜ 待并入：%s" % gen.states[editor.merge_state_src].name
		_editor_labels["state"].text = sname
	if _editor_labels.has("mode_opt"):
		var mo: OptionButton = _editor_labels["mode_opt"]
		var idx := _layer_to_mode_index(int(editor.layer))
		if mo.selected != idx:
			mo.selected = idx
	if _editor_labels.has("biome_opt"):
		var bo: OptionButton = _editor_labels["biome_opt"]
		if bo.selected != editor.target_biome:
			bo.selected = editor.target_biome
	if _editor_labels.has("status"):
		# 笔刷高度以海平面为 0、最高为 100（与原版 0..100 制一致；内部 elevation 为归一值）
		_editor_labels["status"].text = "%s ｜ 笔刷高度 0=海平面·100=最高 ｜ 陆地 %d ｜ 未绘制 %d ｜ 行省 %d ｜ 国家 %d" % [
			editor.layer_name(), editor.land_cell_count(), editor.undrawn_land_count(),
			editor.province_count(), gen.states.size()]

## 全局指令面板：按钮与开关清单直接来自原版 EditPanelUI.GlobalCommandsPanel 成员
func _build_global_commands_panel() -> Control:
	var ui := _base_panel(t("GlobalCommands", "全局指令"), Vector2(760, 600))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(720, 440)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 4)
	scroll.add_child(body)
	ui.vbox.add_child(scroll)

	var sec_toggle := _section(body, "规则开关")
	var toggles := [
		["allow_rebellion", "AllowRebellion", "允许叛乱"],
		["allow_civil_war", "AllowCivilWar", "允许内战"],
		["allow_family_rebellion", "AllowFamilyRebellion", "允许家族叛乱"],
		["allow_vassal_rebel", "AllowVassalRebel", "允许附庸叛乱"],
		["allow_alliance", "AllowAlliance", "允许联盟"],
		["enable_vassal", "EnableVassal", "启用附庸"],
		["allow_auto_diplomacy", "AllowAutoDiplomacy", "允许自主外交"],
		["assist_allies_occupy_land", "AssistAlliesOccupyLand", "协助盟友占领土地"],
		["allow_auto_abandon_isolated", "AllowAutoAbandonIsolatedProvinces", "自动放弃孤立行省"],
		["generate_desert_and_snow", "GenerateDesertAndSnow", "开启雪原和沙漠区域生成"],
	]
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 2)
	sec_toggle.add_child(grid)
	for it in toggles:
		var key: String = it[0]
		var r := HBoxContainer.new()
		var cb := CheckBox.new()
		cb.text = t(it[1], it[2])
		cb.button_pressed = bool(sim.rules.get(key, true))
		cb.add_theme_color_override("font_color", Color(0.15, 0.13, 0.10))
		cb.toggled.connect(func(on: bool) -> void:
			sim.rules[key] = on
			sim.history.append({"date": sim.date_str(),
				"text": "【全局指令】%s = %s" % [cb.text, "开" if on else "关"]})
			_refresh_editor_ui())
		r.add_child(cb)
		grid.add_child(r)

	var sec_action := _section(body, "地图操作")
	var r1 := _row(sec_action)
	_mk_btn(r1, t("ClearMap", "清空地图"), func() -> void:
		gen.clear_map()
		map_render.mark_dirty()
		_refresh_editor_ui()
		_push_banner("地图已清空（只保留海洋）"))
	_mk_btn(r1, "刷新河流与地形", func() -> void:
		gen.refresh_rivers_and_terrain(_current_seed + 17)
		map_render.mark_dirty()
		_push_banner("河流与地形散布已按新高度重算"))
	_mk_btn(r1, t("RegenerateDistricts", "重新生成区域"), func() -> void:
		sim.regenerate_districts()
		_push_banner(t("DistrictRegenerated", "已重新生成所有区域")))
	var r2 := _row(sec_action)
	_mk_btn(r2, "结束所有战争", func() -> void:
		sim.end_all_wars()
		_push_banner("已结束所有战争"))
	_mk_btn(r2, "结束所有联盟", func() -> void:
		sim.end_all_alliances()
		_push_banner("已解除所有联盟"))
	_mk_btn(r2, t("ClearAllHistory", "清空历史"), func() -> void:
		sim.clear_history()
		_push_banner("历史记录已清空"))

	var sec_time := _section(body, "时间与存档")
	var r3 := _row(sec_time)
	r3.add_child(_kv("设置时间"))
	var year_edit := LineEdit.new()
	year_edit.text = str(sim.year)
	year_edit.custom_minimum_size = Vector2(90, 0)
	year_edit.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	r3.add_child(year_edit)
	var month_edit := LineEdit.new()
	month_edit.text = str(sim.month)
	month_edit.custom_minimum_size = Vector2(56, 0)
	month_edit.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	r3.add_child(month_edit)
	_mk_btn(r3, "应用", func() -> void:
		sim.set_time(int(year_edit.text), int(month_edit.text))
		_push_banner("时间已设为 %s" % sim.date_str()))
	var r4 := _row(sec_time)
	_mk_btn(r4, "保存游戏", func() -> void:
		sim.save("user://saves/save1.json")
		_push_banner("已保存到 user://saves/save1.json"))
	_mk_btn(r4, "读取游戏", func() -> void:
		if sim.load("user://saves/save1.json"):
			map_render.mark_dirty()
			_refresh_editor_ui()
			_push_banner("存档已读取")
		else:
			_push_banner("没有可用存档"))
	var cb_auto := CheckBox.new()
	cb_auto.text = "自动存档（每 %d 分钟）" % int(sim.rules.auto_save_interval_minutes)
	cb_auto.button_pressed = bool(sim.rules.auto_save_enabled)
	cb_auto.add_theme_color_override("font_color", Color(0.15, 0.13, 0.10))
	cb_auto.toggled.connect(func(on: bool) -> void:
		sim.rules.auto_save_enabled = on
		_autosave_left = float(sim.rules.auto_save_interval_minutes) * 60.0)
	sec_time.add_child(cb_auto)

	var sec_tip := _section(body, "说明")
	var tip := _body_label()
	tip.text = t("GlobalCommandTutorial", "自动放弃孤立行省 / 协助盟友占领土地：用于防止领土过于破碎。")
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.custom_minimum_size = Vector2(640, 0)
	sec_tip.add_child(tip)

	_finish(ui)
	return ui.panel

var _autosave_left := -1.0


## 编辑器可视化验证（仅调试用）：-- editdemo=height|biome|province|state
## 直接调用编辑器 API 落笔，用于无人值守截图核对"编辑真的改数据 + 真的有反馈"
func _run_edit_demo(kind: String) -> void:
	if editor_dock == null:
		_toggle_editor()
	# 找一块陆地中心（最大国家首都省）
	var anchor_pi := -1
	var best := -1
	for pi in gen.provinces.size():
		if gen.provinces[pi].get("is_sea", false):
			continue
		var n: int = gen.provinces[pi].cells.size()
		if n > best:
			best = n
			anchor_pi = pi
	if anchor_pi < 0:
		return
	var ac: int = gen.provinces[anchor_pi].center
	var apos := Vector2((ac % MapGen.W) * MapGen.CELL + 2, (ac / MapGen.W) * MapGen.CELL + 2)
	match kind:
		"height":
			editor.set_layer(MapEditorNS.Layer.HEIGHT)
			editor.brush_radius = 14
			editor.brush_height = 95.0
			editor.brush_mode = MapEditorNS.BrushMode.MAX
			editor.begin_stroke(apos)
			editor.move_stroke(apos + Vector2(60, 40))
			editor.end_stroke()
			map_render.view_mode = MapRender.View.HEIGHT
		"biome":
			editor.set_layer(MapEditorNS.Layer.BIOME)
			editor.brush_radius = 10
			editor.target_biome = MapGen.BIOME_HOT_DESERT
			editor.begin_stroke(apos)
			editor.move_stroke(apos + Vector2(70, 0))
			editor.end_stroke()
			map_render.view_mode = MapRender.View.BIOME
		"province":
			editor.set_layer(MapEditorNS.Layer.PROVINCE)
			editor.brush_radius = 12
			# 目标：相邻的另一个行省
			var other := -1
			for nb in gen.provinces[anchor_pi].neighbors:
				if not gen.provinces[nb].get("is_sea", false):
					other = nb
					break
			if other >= 0:
				editor.target_province = other
				editor.begin_stroke(apos)
				editor.move_stroke(apos + Vector2(30, 25))
				editor.end_stroke()
		"state":
			editor.set_layer(MapEditorNS.Layer.STATE)
			editor.brush_radius = 10
			var own: int = int(gen.provinces[anchor_pi].state)
			var foe := -1
			for si in gen.states.size():
				if si != own and gen.states[si].alive:
					foe = si
					break
			if foe >= 0:
				editor.target_state = foe
				editor.begin_stroke(apos)
				editor.end_stroke()
	map_render.mark_dirty()
	_refresh_editor_ui()
	print("[editdemo] ", kind, " done")
