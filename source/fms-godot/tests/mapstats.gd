extends SceneTree
## 地图统计基线工具：固定种子 → 输出可对照的统计 JSON
## 用途：每次修改 mapgen 后重跑，与 baseline 对比，量化改动影响
## 运行：godot --headless --path . --script tests/mapstats.gd
## 输出：user://mapstats-baseline.json（首次）/ 对比结果（之后）

const SEEDS := [42, 1337, 2026]
const STATE_COUNT := 26

var gen: MapGen

func _init() -> void:
	gen = MapGen.new()
	var out := {"generated_at": Time.get_datetime_string_from_system(), "seeds": []}
	for seed_val in SEEDS:
		gen.generate(STATE_COUNT, seed_val)
		var land := 0
		for i in gen.is_land.size():
			land += gen.is_land[i]
		var total := gen.is_land.size()
		var sizes: Array[int] = []
		for s in gen.states:
			sizes.append(s.provinces.size())
		sizes.sort()
		var biggest: int = sizes[sizes.size() - 1] if sizes.size() > 0 else 0
		var smallest: int = sizes[0] if sizes.size() > 0 else 0
		var median: int = sizes[sizes.size() / 2] if sizes.size() > 0 else 0
		var fragments := 0
		for s in gen.states:
			if s.provinces.is_empty():
				continue
			fragments += _count_fragments(s.provinces)
		var orphans := 0
		for i in gen.cell_province.size():
			if gen.is_land[i] == 1 and gen.cell_province[i] < 0:
				orphans += 1
		# 省份规模与连通性（本轮新增：验证 ExpandProvinces Dijkstra 的划分质量）
		var psizes: Array[int] = []
		var pempty := 0
		for p in gen.provinces:
			if p.get("is_sea", false):
				continue
			psizes.append(p.cells.size())
			if p.cells.size() == 0:
				pempty += 1
		psizes.sort()
		var pbig: int = psizes[psizes.size() - 1] if psizes.size() > 0 else 0
		var pmed: int = psizes[psizes.size() / 2] if psizes.size() > 0 else 0
		var pcomp := 0
		for pi in gen.provinces.size():
			if gen.provinces[pi].get("is_sea", false):
				continue
			pcomp += _count_components(pi)
		var sea_provs := 0
		for p in gen.provinces:
			if p.get("is_sea", false):
				sea_provs += 1
		var sea_unassigned := 0
		for i in gen.cell_province.size():
			if gen.is_land[i] == 0 and gen.cell_province[i] < 0:
				sea_unassigned += 1
		var land_biomes := {}
		var undrawn_land := 0
		var biome_sea_wrong := 0
		for i in gen.is_land.size():
			if gen.is_land[i] == 1:
				land_biomes[int(gen.biome[i])] = true
				if gen.cell_province[i] < 0:
					undrawn_land += 1
			elif gen.biome.size() > i and int(gen.biome[i]) != MapGen.BIOME_MARINE:
				biome_sea_wrong += 1
		var entry := {
			"seed": seed_val,
			"biomes_land": land_biomes.size(),
			"biome_sea_wrong": biome_sea_wrong,
			"undrawn_land_cells": undrawn_land,
			"sea_provinces": sea_provs,
			"sea_cells_unassigned": sea_unassigned,
			"land_cells": land,
			"land_ratio": snappedf(float(land) / total, 0.001),
			"province_count": gen.provinces.size(),
			"province_size_max": pbig,
			"province_size_median": pmed,
			"province_empty": pempty,
			"province_components": pcomp,
			"state_count": gen.states.size(),
			"state_size_max": biggest,
			"state_size_min": smallest,
			"state_size_median": median,
			"state_fragments": fragments,
			"orphan_land_cells": orphans,
			"rivers": gen.rivers.size(),
			"mountains": gen.mountain_spots.size(),
			"trees": gen.tree_spots.size(),
		}
		out.seeds.append(entry)
		print(JSON.stringify(entry))
	var baseline_path := "user://mapstats-baseline.json"
	if FileAccess.file_exists(baseline_path):
		var old: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(baseline_path))
		print("=== 与基线对比 ===")
		for e in out.seeds:
			var o := _find_seed(old, e.seed)
			if o.is_empty():
				print("  seed %d: 基线无此种子（新增）" % e.seed)
				continue
			for k in e:
				if k == "seed":
					continue
				var diff: float = float(e[k]) - float(o.get(k, 0))
				if absf(diff) > 0.0001:
					print("  seed %d %s: %s -> %s (Δ%s)" % [e.seed, k, str(o[k]), str(e[k]), str(snappedf(diff, 0.001))])
		print("=== 对比结束（基线不变；确认改动合理后删除 user://mapstats-baseline.json 重建） ===")
	else:
		var f := FileAccess.open(baseline_path, FileAccess.WRITE)
		f.store_string(JSON.stringify(out))
		f.close()
		print("baseline saved: ", ProjectSettings.globalize_path(baseline_path))
	quit(0)

func _find_seed(data: Dictionary, seed_val: int) -> Dictionary:
	for e in data.get("seeds", []):
		if int(e.seed) == seed_val:
			return e
	return {}

## 国家的行省集合在省份邻接图上的连通分量数（1=领土完整）
func _count_fragments(prov_ids: Array) -> int:
	var idset := {}
	for p in prov_ids:
		idset[p] = true
	var seen := {}
	var fragments := 0
	for start in prov_ids:
		if seen.has(start):
			continue
		fragments += 1
		var stack: Array = [start]
		seen[start] = true
		while not stack.is_empty():
			var cur: int = stack.pop_back()
			for nb in gen.provinces[cur].neighbors:
				if idset.has(nb) and not seen.has(nb):
					seen[nb] = true
					stack.append(nb)
	return fragments

## 单个省份的连通分量数（基于 cell 4 邻域，直接看真实几何连通性）
func _count_components(pi: int) -> int:
	var cells: PackedInt32Array = gen.provinces[pi].cells
	if cells.size() == 0:
		return 0
	var W: int = MapGen.W
	var H: int = MapGen.H
	var inset := {}
	for c in cells:
		inset[c] = true
	var seen := {}
	var comps := 0
	for c in cells:
		if seen.has(c):
			continue
		comps += 1
		var stack: Array[int] = [c]
		seen[c] = true
		while not stack.is_empty():
			var cur: int = stack.pop_back()
			var x := cur % W
			var y := cur / W
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx := x + int(d.x)
				var ny := y + int(d.y)
				if nx < 0 or ny < 0 or nx >= W or ny >= H:
					continue
				var ni := ny * W + nx
				if inset.has(ni) and not seen.has(ni):
					seen[ni] = true
					stack.append(ni)
	return comps
