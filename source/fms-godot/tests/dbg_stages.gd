extends SceneTree
## 临时调试：分段计时定位卡死阶段（文件直写+flush，避免 stdout 缓冲丢失）

var logf: FileAccess

func _log(msg: String) -> void:
	logf.store_line(msg)
	logf.flush()

func _init() -> void:
	logf = FileAccess.open("user://dbg_stages.txt", FileAccess.WRITE)
	_log("start")
	var gen := MapGen.new()
	_log("MapGen.new ok")
	var t := Time.get_ticks_msec()
	gen._gen_elevation(42)
	_log("elevation: %d ms" % (Time.get_ticks_msec() - t))
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	gen.cell_province.resize(gen.W * gen.H)
	gen.cell_province.fill(-1)
	t = Time.get_ticks_msec()
	gen._seed_provinces(rng)
	_log("seed: %d ms, provinces=%d" % [Time.get_ticks_msec() - t, gen.provinces.size()])
	t = Time.get_ticks_msec()
	gen._expand_provinces_dijkstra()
	_log("dijkstra: %d ms" % (Time.get_ticks_msec() - t))
	t = Time.get_ticks_msec()
	gen._rebuild_province_cells()
	_log("rebuild: %d ms" % (Time.get_ticks_msec() - t))
	t = Time.get_ticks_msec()
	gen._ensure_province_connectivity()
	_log("connectivity: %d ms" % (Time.get_ticks_msec() - t))
	gen._rebuild_province_cells()
	var orphan := 0
	for i in gen.cell_province.size():
		if gen.is_land[i] == 1 and gen.cell_province[i] < 0:
			orphan += 1
	_log("orphan land cells: %d" % orphan)
	_log("done")
	quit(0)
