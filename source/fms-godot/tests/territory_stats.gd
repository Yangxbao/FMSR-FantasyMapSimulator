extends SceneTree
## 国家领土连通性统计（V5 P1 4.1）：多种子输出碎片指标，验收"国家领土自然"修复效果。
## 指标：国家数/每国省数、省邻接图上的最大连通块占比、独立连通块数、孤立单省数、
##       海洋省数、跨海飞地数（与主块不连通但同国）。
## 运行：godot --headless --path . --script tests/territory_stats.gd -- seeds=42,1337,2026,7,9527

const MapGen := preload("res://scripts/mapgen.gd")

func _stats(gen) -> Dictionary:
	var n_states: int = gen.states.size()
	var land_prov := 0
	var sea_prov := 0
	for p in gen.provinces:
		if p.get("is_sea", false):
			sea_prov += 1
		else:
			land_prov += 1
	# 省邻接图连通块（陆地省）
	var visited := {}
	var comps: Array = []
	for pi0 in gen.provinces.size():
		if gen.provinces[pi0].get("is_sea", false) or visited.has(pi0):
			continue
		var comp: Array[int] = []
		var q: Array[int] = [pi0]
		visited[pi0] = true
		while q.size() > 0:
			var cur: int = q.pop_back()
			comp.append(cur)
			for nb in gen.provinces[cur].neighbors:
				var nbi: int = int(nb)
				if visited.has(nbi) or gen.provinces[nbi].get("is_sea", false):
					continue
				visited[nbi] = true
				q.append(nbi)
		comps.append(comp)
	comps.sort_custom(func(a, b): return a.size() > b.size())
	var biggest: int = comps[0].size() if comps.size() > 0 else 0
	var singletons := 0
	for c in comps:
		if c.size() == 1:
			singletons += 1
	# 每国跨海/碎块：国家省集合在省邻接图上的连通块数
	var frag_total := 0
	var per_state := []
	for si in gen.states.size():
		var provs: Array = gen.states[si].provinces
		var inner_visited := {}
		var blocks := 0
		var biggest_block := 0
		for p0 in provs:
			var p0i: int = int(p0)
			if inner_visited.has(p0i):
				continue
			blocks += 1
			var cnt := 0
			var q2: Array[int] = [p0i]
			inner_visited[p0i] = true
			while q2.size() > 0:
				var cur2: int = q2.pop_back()
				cnt += 1
				for nb2 in gen.provinces[cur2].neighbors:
					var nb2i: int = int(nb2)
					if inner_visited.has(nb2i):
						continue
					if int(gen.provinces[nb2i].get("state", -1)) != si:
						continue
					inner_visited[nb2i] = true
					q2.append(nb2i)
			biggest_block = maxi(biggest_block, cnt)
		frag_total += blocks - 1 if blocks > 0 else 0
		if provs.size() > 0:
			per_state.append([si, provs.size(), blocks, biggest_block])
	return {
		"states": n_states, "land_prov": land_prov, "sea_prov": sea_prov,
		"comps": comps.size(), "biggest_comp": biggest,
		"biggest_ratio": (float(biggest) / float(land_prov) if land_prov > 0 else 0.0),
		"singletons": singletons, "frag_total": frag_total, "per_state": per_state,
	}

func _init() -> void:
	var seeds := [42, 1337, 2026, 7, 9527]
	for a in OS.get_cmdline_user_args():
		if a.begins_with("seeds="):
			seeds = []
			for sv in a.split("=")[1].split(","):
				if sv.is_valid_int():
					seeds.append(int(sv))
	var agg_big := 0.0
	var agg_frag := 0
	var agg_single := 0
	for sv in seeds:
		var gen = MapGen.new()
		gen.generate(26, sv)
		var st: Dictionary = _stats(gen)
		agg_big += float(st["biggest_ratio"])
		agg_frag += int(st["frag_total"])
		agg_single += int(st["singletons"])
		print("SEED %d | 国 %d 陆省 %d 海省 %d | 省图连通块 %d 最大块 %.1f%% | 孤单省 %d | 国土碎块总数 %d" % [
			sv, st["states"], st["land_prov"], st["sea_prov"], st["comps"],
			100.0 * float(st["biggest_ratio"]), st["singletons"], st["frag_total"]])
		# 最碎的 3 国明细
		var worst: Array = (st["per_state"] as Array).duplicate()
		worst.sort_custom(func(a, b): return int(a[1]) > 0 and (int(a[2]) - 1) * 100.0 / int(a[1]) > (int(b[2]) - 1) * 100.0 / maxi(int(b[1]), 1))
		for i in mini(3, worst.size()):
			var w: Array = worst[i]
			if int(w[1]) > 3 and int(w[2]) > 1:
				print("   碎国 si=%s 省=%s 块=%s 最大块=%s" % [w[0], w[1], w[2], w[3]])
	print("AGG | 平均最大连通块 %.1f%% | 碎块总数 %d | 孤单省 %d" % [100.0 * agg_big / seeds.size(), agg_frag, agg_single])
	quit(0)
