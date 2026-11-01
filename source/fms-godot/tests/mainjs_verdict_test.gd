extends SceneTree
## main.js 终审实验：JS 权威 continents 模板 × 原版 cell 数档位 → 陆地占比
## 判据：原版实测陆地 31.8%（官渡 40050 cell）/ 工坊 tier 平均 41.6%/45.2%
## 重建旧网格 480×280=134400 cell 下 98-100% 全陆（power_sweep 记录）
## 期望：改用原版 cell 数档位 + main.js 修正后 land% 落回 30-50% 区间

const DSL = preload("res://scripts/heightmap_dsl.gd")

const CONTINENTS := [
	"Hill 1 80-85 60-80 40-60",
	"Hill 1 80-85 20-30 40-60",
	"Hill 6-7 15-30 25-75 15-85",
	"Multiply 0.6 land 0 0",
	"Hill 8-10 5-10 15-85 20-80",
	"Range 1-2 30-60 5-15 25-75",
	"Range 1-2 30-60 80-95 25-75",
	"Range 0-3 30-60 80-90 20-80",
	"Strait 2 vertical 0 0",
	"Strait 1 vertical 0 0",
	"Smooth 3 0 0 0",
	"Trough 3-4 15-20 15-85 20-80",
	"Trough 3-4 5-10 45-55 45-55",
	"Pit 3-4 10-20 15-85 20-80",
	"Mask 4 0 0 0",
]

func _parse(lines: Array) -> Array:
	var steps: Array = []
	for ln in lines:
		var parts: PackedStringArray = ln.strip_edges().split(" ", false)
		if parts.size() < 2:
			continue
		var args := PackedStringArray()
		for i in range(1, parts.size()):
			args.append(parts[i])
		steps.append({"op": parts[0], "args": args})
	return steps

func _run_case(label: String, ww: int, hh: int, cells_desired: int, seed_val: int) -> void:
	var d = DSL.new(seed_val, ww, hh, cells_desired)
	var steps := _parse(CONTINENTS)
	var unknown: Array = d.run_steps(steps)
	var s: Dictionary = d.stats()
	var land_pct: float = 100.0 * float(s["land"]) / float(ww * hh)
	print("CASE %-22s %5dx%-5d cells=%6d blob=%.4f line=%.4f | land=%5.1f%% mean=%5.1f max=%3d unknown=%s" % [
		label, ww, hh, ww * hh, d.blob_power, d.line_power, land_pct, float(s["mean"]), int(s["max"]), str(unknown)])

func _init() -> void:
	print("=== MAINJS VERDICT: continents template across grid sizes ===")
	# 旧网格（全陆记录源）
	_run_case("old_134400", 480, 280, 20000, 42)
	# 原版 cellsDesired 档位（GenerateHeightMap ★A：10000/20000/30000）
	_run_case("orig_10080", 160, 63, 10000, 42)
	_run_case("orig_20000", 200, 100, 20000, 42)
	_run_case("orig_30104", 212, 142, 30000, 42)
	_run_case("orig_20000_b", 200, 100, 20000, 1337)
	_run_case("orig_30104_b", 212, 142, 30000, 1337)
	print("=== MAINJS VERDICT DONE ===")
	quit(0)
