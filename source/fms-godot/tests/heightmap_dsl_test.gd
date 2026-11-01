extends SceneTree
## DSL 解释器测试：
##   1) Smooth 数值与伪代码手算完全一致（反编译逐字核对过）
##   2) 区间解析 getNumberInRange / getPointInRange 符合原版语义
##   3) 模板能整体跑通，产出合理高度场
## 运行：godot --headless --path . --script tests/heightmap_dsl_test.gd

const DSL := preload("res://scripts/heightmap_dsl.gd")
const Tpl := preload("res://scripts/heightmap_template.gd")

var pass_n := 0
var fail_n := 0

func _init() -> void:
	_test_smooth_a1()
	_test_smooth_a3()
	_test_smooth_offset()
	_test_neighbors()
	_test_number_in_range()
	_test_point_in_range()
	_test_full_template()
	print("\n=== heightmap_dsl_test: %d 通过，%d 失败 ===" % [pass_n, fail_n])
	print("=== DSL TEST ALL PASS ===" if fail_n == 0 else "=== DSL TEST FAILED ===")
	quit(0 if fail_n == 0 else 1)

func ok(cond: bool, msg: String) -> void:
	if cond:
		print("[PASS] " + msg)
		pass_n += 1
	else:
		print("[FAIL] " + msg)
		fail_n += 1

## 3×3，仅中心 = 100 → smooth(1,0)
## 角：(0+0+0+100)/4 = 25；边：100/6 = 16.67→16；中心：100/9 = 11.11→11
func _test_smooth_a1() -> void:
	var d := DSL.new(1, 3, 3)
	d.heights[4] = 100
	d._smooth(1, 0)
	var exp := [25, 16, 25, 16, 11, 16, 25, 16, 25]
	var got := []
	for i in 9:
		got.append(d.heights[i])
	ok(got == exp, "smooth(1,0) 3x3 单峰 → %s" % str(got))

## smooth(3,0)：v = max(0, (cur*2 + avg)/3)
## 角：(0+25)/3 = 8.33→8；边：(0+16.67)/3 = 5.5→5；中心：(200+11.11)/3 = 70.37→70
func _test_smooth_a3() -> void:
	var d := DSL.new(1, 3, 3)
	d.heights[4] = 100
	d._smooth(3, 0)
	var exp := [8, 5, 8, 5, 70, 5, 8, 5, 8]
	var got := []
	for i in 9:
		got.append(d.heights[i])
	ok(got == exp, "smooth(3,0) 3x3 单峰 → %s" % str(got))

## smooth(1,5) 在空白图上 → 全 5
func _test_smooth_offset() -> void:
	var d := DSL.new(1, 3, 3)
	d._smooth(1, 5)
	var allv := true
	for i in 9:
		if d.heights[i] != 5:
			allv = false
	ok(allv, "smooth(1,5) 空白图 → 全 5")

## 邻居拓扑：角 3 个、边 5 个、内部 8 个
func _test_neighbors() -> void:
	var d := DSL.new(1, 4, 4)
	var n00 := d._nbrs(0).size()
	var nedge := d._nbrs(1).size()
	var nin := d._nbrs(1 * 4 + 1).size()
	ok(n00 == 3 and nedge == 5 and nin == 8, "8 邻域拓扑：角=%d 边=%d 内=%d（应 3/5/8）" % [n00, nedge, nin])

## getNumberInRange：整数原样；小数是概率进位；a-b 为闭区间
func _test_number_in_range() -> void:
	var d := DSL.new(7, 8, 8)
	var ok_int := true
	for _i in 50:
		if d._num("3") != 3:
			ok_int = false
	ok(ok_int, "_num(\"3\") 恒为 3")

	var frac_vals := {}
	for _i in 400:
		frac_vals[d._num("0.5")] = true
	var ok_frac := frac_vals.has(0) and frac_vals.has(1) and frac_vals.size() == 2
	ok(ok_frac, "_num(\"0.5\") 只产生 0/1（概率进位）")

	var ok_range := true
	for _i in 400:
		var v := d._num("1-4")
		if v < 1 or v > 4:
			ok_range = false
	ok(ok_range, "_num(\"1-4\") 落在 1..4 闭区间")

	var ok_range2 := true
	for _i in 400:
		var v := d._num("6-7")
		if v != 6 and v != 7:
			ok_range2 = false
	ok(ok_range2, "_num(\"6-7\") 只产生 6/7")

## getPointInRange（main.dec.js ★A 镜像语义）：center + (len/2 − rand(min·len, max·len))
## 本工程 center=len/2 → 结果 = len − rand(min·len, max·len)
func _test_point_in_range() -> void:
	var d := DSL.new(3, 480, 280)
	var okx := true
	for _i in 300:
		var x := d._point("60-80", 480)
		if x < 96 or x > 192:
			okx = false
	ok(okx, "_point(\"60-80\",480) 落在 96..192（镜像）")
	var oky := true
	for _i in 300:
		var y := d._point("40-60", 280)
		if y < 112 or y > 168:
			oky = false
	ok(oky, "_point(\"40-60\",280) 落在 112..168（镜像对称带）")

## 整份模板（#3 = 原版 Templates[3]，20 步，2026-10-31 证实）在 120×70 上跑通：无未识别算子、产出非平凡高度场
func _test_full_template() -> void:
	var p := Tpl.new()
	p.load_all()
	var t := p.get_template_by_order(3)
	var d := DSL.new(42, 120, 70)
	var unknown := d.run_steps(t["steps"])
	ok(unknown.is_empty(), "模板#3 全部算子均已实现（未识别: %s）" % str(unknown))
	var st := d.stats()
	ok(st["max"] > 30 and st["max"] <= 100, "模板#3 最高点 = %d（0..100 内且有意义）" % st["max"])
	ok(st["land_ratio"] > 0.02 and st["land_ratio"] < 0.98, "模板#3 陆地占比 = %.3f（非退化）" % st["land_ratio"])
	print("      模板#3 统计：%s" % str(st))
