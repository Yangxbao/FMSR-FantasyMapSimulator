extends SceneTree
func _log(m: String) -> void:
	var f := FileAccess.open("user://mini.log", FileAccess.WRITE)
	f.store_string(m)
	f.close()
func _init() -> void:
	_log("A begin")
	var MG = load("res://scripts/mapgen.gd")
	_log("B mapgen loaded")
	var gen = MG.new()
	_log("C MapGen.new")
	gen.generate(6, 42)
	_log("D generate(6) done")
	quit(0)
