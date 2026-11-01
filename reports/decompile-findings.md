# 反编译发现报告（REA + Ghidra 管线产出）

> 工具链：REA 6.8.0 `inspect-il2cpp-metadata`（v29 元数据 + GameAssembly.dll 地址关联）
> → 72,530 个 `Type$$Method` 符号种子 → Ghidra 12.1.4 headless（JDK 25，Android Studio JBR）
> → `rea decompile --procedure "Type$$Method"`
> 证据文件：`logs/decompile_basg_generate.json`（75KB）；伪代码：`reports/decompiled/BurgsAndStateGenerator_Generate.c`（41KB）

## 1. 原版地图生成管线（已从机器码反编译确认）

`BurgsAndStateGenerator.Generate()` 的真实调用顺序：

```
CreateProvinces()
ExpandProvinces()
CreateSeaProvinces()
ExpandSeaProvinces()
PlaceProvincialCapitalsByJitterGrid() / SelectCapitalsFromProvinces()
CreateStates()
ExpandStates()
EnsureProvinceConnectivity()
FilterProvinceCells()            x2
RecalculateProvinceState()
SpecifyBurgAndProvince()
InitCultureNameSet()
InitEthnicAttribute()
State::UpdateColor()             x3
Routes::GetSeaRoutes()
```

辅证：性能埋点 `SaveLoadPerfSession.MeasureCurrent`（16 处）、`Stopwatch` 计时（生成过程有详细性能日志）、AI 状态 `AISystemState`、战争目标策略 `MostEnemyArmyProvinceStrategy` 在生成时即创建。

**与重建版（source/fms-godot/scripts/mapgen.gd）的对应关系**：重建管线按相同环节实现（cell 多源BFS 成省 → 海洋省 → 抖动网格布首都 → 省份生长成国 → 连通性修复 → 命名/文化初始化）。

## 2. 原版玩法原理官方自述（localization.csv `MapEditingInstructions`）

> 地图原理：基于**维诺图**，每个行省由多个相邻的多边形（cell）组成。一个国家可以占据的最小单位为行省。
> 编辑顺序：高度图 → 生物群系图 → 行省图 → 国家图。
> 左键点击国家 → 打开**国家信息面板**；Shift+左键点击行省 → 打开**行省信息面板**。

重建版交互/数据分层照此实现。

## 3. 原版 UI 结构规格（元数据 dump）

- `ProvinceInfoUI`（124 成员）：BasicInfo/Actions/Campaign 三区块；操作=设为首都/设为要塞/设为城市/设为区域中心/翻译省名/自定义人口/自定义城防/发动叛乱
- `StateInfoUI`（266 成员）：国名输入/取色器/镜头跟随/自主外交开关/军队部署数/战争面板族/历史面板族（分页）/领袖候选人（男女按钮色、最小年龄）
- 官方中文文案 112 键已提取至 `source/fms-godot/assets/origin/zh_strings.json`（重建版直接加载使用）

## 4. 工具链使用记录（复现命令）

```bash
# 元数据 + 地址关联 + 种子
npx rea inspect-il2cpp-metadata <global-metadata.dat> --binary <GameAssembly.dll> \
  --evidence_output il2cpp-evidence-seeded.json --ghidra-seeds ghidra_seeds.txt
# 反编译（首次含全量分析，需 REA_GHIDRA_STARTUP_TIMEOUT_MS=5400000）
set GHIDRA_INSTALL_DIR=E:\GameResearch\FantasyMapSimulator\build\ghidra_extract\ghidra_12.1.4_PUBLIC
set JAVA_HOME=E:\Android Studio\jbr        # 注意：Ghidra 12.1.4 需要 JDK 21+，JDK 17 会被拒绝
npx rea decompile <GameAssembly.dll> --procedure "BurgsAndStateGenerator$$Generate"
```

## 5. 第二批反编译（2026-10-30，9 个地图生成方法全部完成）

伪代码落盘：`reports/decompiled/BurgsAndStateGenerator_{CreateProvinces,ExpandProvinces,CreateStates,ExpandStates,EnsureProvinceConnectivity,FilterProvinceCells,RecalculateProvinceState,CreateSeaProvinces,ExpandSeaProvinces}.c`

### 5.1 CreateStates（关键机制，已实现到重建版）
- **国家数量非固定参数**：遍历 cell 列表，凡 `cell+0x58 != 0`（被首都放置步骤标记）且未归属的 cell 各建一国 → 国家数 = 首府 cell 数
- 每国构造参数含 `MathUtility.Rn(UnityEngine.Random.value * 5.0 + 1.0, 1)` = **随机 1~6 的一位小数乘数**（存 state+0xdc）
- 调色板：`ColorUtils.GetColors(count - 1)`；工具：`RandomUtils.Each(5)`
- 存在 id=0 的默认态（构造于循环前，与省份 id=0 海洋省平行）
- `param_1+0x20` 对象记录首个状态：+0x24=id、+0xdc=乘数、+0xe0=cell 序号、+0xd0=名称、+0xa4/+0xc0=cell 键

### 5.2 ExpandStates（核心算法，已实现到重建版）
- **多源 Dijkstra 前沿扩张**：
  - 松弛：`if (existingCost == 0.0 || newCost < existingCost)` 占用 cell（L928-934）
  - 代价：`newCost = prevCost + 10.0 + terrainPenalty / stateMult`（L926）
  - 地形惩罚：查表值 v → `20.0 - v`（下限 0）；查表失败/为 0 → 罚 5000.0（L738-778）
  - stateMult = CreateStates 写入的每国随机乘数（L926 除数）
- 常数：10.0（步长基数）、20.0（地形上限）、5000.0（惩罚）

### 5.3 RecalculateProvinceState
- 省份归属 = 省内 cell 的多数归属（重建版已按此实现）

### 5.4 CreateProvinces
- 从维诺图 cell 集合逐 cell 判定（`cell+0x66` 布尔=陆地标志），未归属 cell 建新省
- 省名 = 常量前缀（DAT_182e94b40，"Province"类字符串）+ 序号
- 查 4 张字典（偏移 0xc0/0xa8/0x88/0x78）回填 cell 属性 → 省构造参数
- id=0 的默认省先于循环创建（海洋省语义）

### 5.5 待精读
- ExpandProvinces（37KB，同款常数 10/20/5000，疑似同款 Dijkstra 用于省份扩张）
- EnsureProvinceConnectivity（21KB）、FilterProvinceCells（14KB）、CreateSeaProvinces/ExpandSeaProvinces
- ColorUtils.GetColors 调色板生成规则；DAT_182e94b40/182e96208 字符串常量定位

### 5.6 待继续的逆向目标

- `TimeManager$$Update`（注意：`UpdateMonthly` 不存在，方法名先查 dump）
- `WarManagerV2$$StartWar` / `ResolveState`
- `SaveSystem.WriteRootV2`（存档容器与 `c_SaveEncryptionKey` 用法）
- Puerts `main` 包解密（ts-loader 程序集）

## 6. 第四轮：ExpandProvinces 精读（省份扩张 = 多源 Dijkstra，与 ExpandStates 同族但有三处实质差异）

伪代码：`reports/decompiled/BurgsAndStateGenerator_ExpandProvinces.c`（459 行）
对照：`BurgsAndStateGenerator_ExpandStates.c`（506 行）

### 6.1 数据结构与流程（逐行对应）

| 环节 | 伪代码位置 | 内容 |
|---|---|---|
| 队列 | L102/L110/L188/L205 | `new` 优先队列（`DAT_182ef9498`，与 ExpandStates 同一类型）；`FUN_1814e95d0(q, node, priority)` 入队、`FUN_1814e6c30(q)` 取最小、计数在 `q+0x28` |
| 种子遍历 | L118-L196 | `foreach (prov in World+0x288)`；条件 `prov+0x10 != 0 && prov+0x89 != 0 && prov+0x88 == 0 && prov+0x95 != 0`（`+0x89` = 陆地省标志：CreateSeaProvinces 明确对它写 0） |
| 种子写入 | L142-L143 | `provinceOfCellDict[seedCell.id] = prov.id`（先占位） |
| 种子入队 | L183-L188 | 节点 `+0x14=seedCell, +0x10=0(代价), +0x1c=biome, +0x18=prov.id`，入队优先级 **0** |
| 种子代价表 | L193 | `costTable[seedCell] = 1.0`（`0x3f800000`，与 state 扩张的 0.0 不同） |
| 主循环 | L205-L258 | `while (q.Count > 0)` 取最小节点 |
| 邻格遍历 | L218 | `World.GetNeighborCells(cellId)` |
| 已归属判定 | L239-L254 | `provinceOfCellDict[nb] > 0` 则查该省，**若 nb 正是该省的中心格则整段跳过**（保护中心） |
| 覆盖门 | L306 | 目标所在省 `+0x88 != 0` 且 `id >= 1` → 跳过（不覆盖已有陆地省） |
| 属性对比项 | L324-L328 | `prov+0x70 != cellAttrDict_0x88[nb]` → 罚 **100**，否则 **-9** |
| 地形项 | L337-L371 | `heightInt[nb] < 0x14(20)` → 0；否则取 `floatDict_0x50[nb]`：`<=0` → **5000**，否则 `20.0 - h`，再下限 0 |
| biome/river/type | L380-L403 | `g__getBiomeCost_27_0` / `g__getRiverCost_27_2` / `g__getTypeCost_27_3`（局部函数，另一批反编译中） |
| 附加代价合成 | L404-L407 | `extra = 属性项 + 地形 + biome + 0.0 + river + type`，整体下限 0 |
| 新代价 | L417 | `newCost = prevCost + 10.0 + extra / prov+0x60` |
| 松弛 | L418-L421 | `costTable[nb] == 0.0 \|\| newCost < costTable[nb]` |
| 归属写入 | L431-L441 | **仅当 `heightInt[nb] >= 20`（陆地）** 才写 `provinceOfCellDict[nb] = prov.id` |
| 入队 | L443-L454 | 节点携带 `newCost`、nb、prov.id、nb 的 biome，优先级 `newCost` |

### 6.2 与 ExpandStates 的异同（用户要求的逐项对照）

相同（可复用的部分）：
1. 同一套优先队列、同一套节点布局、同一套"种子入队优先级 0 + 代价表 1.0"初始化；
2. 同一 `GetNeighborCells` 邻域；
3. 同一松弛表达式 `costTable[nb]==0.0 || newCost<costTable[nb]`；
4. 同一 `newCost = prevCost + 10.0 + extra/divisor` 骨架，`extra` 同样先整体下限 0；
5. 同一地形项语义（`20-h`、下限 0、缺表 5000）；
6. 同一"陆地才写归属"门（`height>=20`）；
7. 同一"目标已属实体 → 整段跳过"的覆盖门与中心格保护。

不同（不能照抄的部分）：
1. **除数**：state 用 `state+0xdc`（CreateStates 写入的 `Rn(rand*5+1)` ∈ (1,6] 随机乘数）；province 用 `prov+0x60`，而 Province 构造第 5 实参在两处（CreateProvinces / CreateSeaProvinces）都硬编码 `0x3f800000` = **1.0** ⇒ 省份扩张除数恒为 1.0，没有随机乘数。
2. **第 4 项**：ExpandStates 是 `getHeightCost(...)`；ExpandProvinces 该槽位是字面常量 **0.0**。
3. **属性对比字段**：state 比 `state+0xc0`（文化 id），province 比 `prov+0x70`。
4. **单实体快速路径**：ExpandStates 在存活实体数 == 1 时直接把所有陆地 cell 归给该国后返回；ExpandProvinces **没有**这个分支。
5. 归属字典：`dict_0xa8`（cell→state） vs `dict_0xc0`（cell→province）；实体集合 `World+0x290`（states） vs `World+0x288`（provinces）。

### 6.3 省份种子从哪里来（回答"初始种子如何产生"）

- `Generate()` 的分支结构（`BurgsAndStateGenerator_Generate.c` L133-L281）：**地块已存在时**走 `PlaceProvincialCapitalsByJitterGrid`；**新建地图**走 `CreateProvinces → ExpandProvinces → CreateSeaProvinces → ExpandSeaProvinces`；两条路径之后统一 `SelectCapitalsFromProvinces → CreateStates → ExpandStates`。
- `PlaceProvincialCapitalsByJitterGrid`（本轮已反编译）：遍历 `World+0x320`（由 `World.EnsureProvinceBurgCellsReady` 预先算好的抖动网格候选 cell 序列），按 cell 逐个建对象（`+0x38`=cell、`+0x3c`=文化、`+0x40`=state、`+0x60`=序号、`+0x64`=是否省会），并写 `cellIdxDict_0x90[cell] = 序号`；其中会**跳过三个 Biome**（`Biomes.GetBiomeNameIndex` 取到的三类，疑为山地/森林，由 `param_1+0x28` 开关控制）。
- 因此 ExpandProvinces 的种子就是"抖动网格上的 brug/省中心 cell"，与重建版 `_seed_provinces()`（step=11、±4 抖动、每格一省）结构一致；真正的抖动间距常量在 `World.EnsureProvinceBurgCellsReady`（未反编译）。
- `SelectCapitalsFromProvinces` 在扩张**之后**运行，决定哪些省升级为国家的首都省 → `CreateStates` 按"首都省数"建国。

### 6.4 仍未确定（不得当作原版参数）

1. `floatDict_0x50` 的量纲：若为 0..1 归一化高度，则地形项≈19~20，几乎恒定；若为 0..20 高度分位，则地形项 0~20 有真实区分。重建版按后者（`elevation` 归一到 0..20）。
2. `g__getRiverCost` / `g__getTypeCost` 的公式与常数（反编译进行中）。
3. `prov+0x88`、`prov+0x95` 两个布尔的确切语义（种子条件用），以及 `prov+0x70` 是否文化字段（按 CreateProvinces 中 `dict_0x88`→`cell+0x3c`→Province 构造推断为文化）。

### 6.5 `<ExpandProvinces>g__getBiomeCost|27_0` 精读（第四轮已反编译）

伪代码：`reports/decompiled/BurgsAndStateGenerator_getBiomeCost_27_0.c`（58 行）。该局部函数被 IL2CPP 内联优化得较厉害，反编译只剩控制流骨架，但语义可读：

```
float getBiomeCost(uint originBiome, uint targetBiome, string provinceCtx) {
    if (originBiome == targetBiome) return 0;            // 同一 biome → 不额外计费
    bool isA = string.Equals(provinceCtx, "…A…");
    if (!isA) {
        bool isB = string.Equals(provinceCtx, "…B…");
        if (!isB || targetBiome > 9) { /* 表查路径1 */ }
        else { /* 表查路径2（targetBiome 5..9 专用分支） */ }
    } else { /* 表查路径3 */ }
    // 三条路径都收敛到：Biomes 静态对象的 +0xb8 → +0x20 数组，按 targetBiome 取值
    // （数组值即 Biome 代价表；反编译器丢失了 float 返回，未取到具体数值）
}
```

结论：**biome 项 = 起点 biome ≠ 目标 biome 时，取 Biome 代价表 `cost[targetBiome]`；相同 biome 记 0**。三个分支的差异只在"某些文化名 + 目标 biome∈[5..9]"时的取表方式，最终值仍来自同一张表。
重建版无生物群系系统 ⇒ 该项恒 0（已在代码与验收文档中标注为未还原项）。要真正接入，还需：Biome 图生成 + `BiomeResource.json` 代价表。

### 6.6 `<ExpandProvinces>g__getRiverCost|27_2` 精读（第四轮已反编译）

伪代码：`reports/decompiled/BurgsAndStateGenerator_getRiverCost_27_2.c`

```c
float getRiverCost(int riverId, int cell, string provinceCtx, Map** map) {
    if (string.Equals(provinceCtx, "…特殊文化…")) {          // 分支A：亲水文化
        return (riverId == 0) ? 100.0 : 0.0;                  //  无河 +100，有河 0
    }
    if (riverId == 0) return 0.0;                             // 分支B：普通省，无河 → 0
    float v = map->floatDict(+0x28)[cell];                    // 河宽/水流量表
    return MathUtility.MinMax(v / 10.0, 20.0, 100.0);         // 夹到 [20,100]
}
```

结论：**普通省份：无河 0；有河则 `clamp(河宽表值/10, 20, 100)`**（0x4034…=20.0、0x4059…=100.0 为 double 常量）。
重建版：`_river_cost()` 恒 0 —— 因为 (a) 重建版没有 cell→river id 表（河流是折线，不是 per-cell 字段），(b) 没有河宽表。若下轮把河流改为 per-cell 字段，最小可行近似是"河格 +20"（即原式下限），但需显式标注为近似。

### 6.7 `<ExpandProvinces>g__getTypeCost|27_3` 精读（第四轮已反编译）

伪代码：`reports/decompiled/BurgsAndStateGenerator_getTypeCost_27_3.c`。签名 `getTypeCost(int cellType, string provinceCtx)`，按 cell 类型 + 省份文化名分支，返回浮点常量：

| cellType | 文化不是 A/B（type1）/ A/C（type2, other） | 文化命中 | 返回值 |
|---|---|---|---|
| `1` | 普通文化 → **20.0**；另一个特定文化 → **60.0** | A 或 B | 0 |
| `2` | 普通文化 → 0 | A 或 C | **30.0** |
| 其它（≠ -1） | 普通文化 → 0 | A 或 B | **100.0** |
| `-1` | — | — | 0 |

浮点常量：`0x41a00000`=20.0、`0x42700000`=60.0、`0x41f00000`=30.0、`0x42c80000`=100.0。
结论：**对普通 cell（type 0 / -1）与普通文化，该项恒为 0**；只在"特殊 cell 类型 × 特殊文化"组合下才出现 20/30/60/100。
重建版无 cell 类型字段、无文化系统 ⇒ 取 0 与原式在默认数据下的取值一致，不是随意省略。

### 6.8 六项代价的最终结论（本轮全部反编译完毕）

| 项 | 原版公式 | 默认数据（重建版现状）下的取值 |
|---|---|---|
| 属性/文化 | 同文化 -9 / 异文化 +100 | 单一文化 → **-9** |
| 地形 | `20 - h`（下限 0，缺表 5000） | 有高度数据 → **真实参与** |
| biome | 同 biome 0；跨 biome 查 Biome 代价表 | 无 biome 图 → 同 biome → **0** |
| 第 4 项 | 字面 `0.0`（省份专有） | **0** |
| river | 无河 0；有河 `clamp(河宽/10,20,100)` | 无 per-cell 河 → 无河 → **0** |
| type | 见 6.7 表 | 普通 cell → **0** |

即：在重建版现有数据模型下，**只有文化与地形两项非零，而且文化项退化为常量 -9**；其余四项为 0 是原式在"缺该维度数据"时的正确取值。真正的还原缺口不是"少算了惩罚"，而是**缺 biome 图 / cell 类型 / per-cell 河流**这三类数据维度本身。

## 7. 第四轮：其余三个方法精读（与重建版对照，未改代码处已标注）

### 7.1 FilterProvinceCells（`FilterProvinceCells.c`，172 行）— 已按此实现

原版逻辑：
1. 遍历全部省份：确保 `prov+0xa8`（cell 集合）、`prov+0xa0`（列表）、`prov+0xb0`（集合）非空；把三者的 `+0x18`（Count）清 0 并 `+0x1c` 自增（版本号）；`prov+0x8a` 两字节标志清零。
2. 串行遍历 `i = 0 .. World.cellCount-1`：`p = cellProvinceDict[i]`；`p > 0 && p < provinces.Count` → `provinces[p].cells.Add(i)`。
3. 再用 `System.Threading.Tasks.Parallel.For` 做一遍同样的回填（分块并行加速）。

结论：**这个方法不改变任何归属，只是"按 cell→province 字典重建各省的 cell 集合"**。
重建版对应：`_rebuild_province_cells()`（逐 cell 回填，语义一致；未做并行）。

### 7.2 EnsureProvinceConnectivity（`EnsureProvinceConnectivity.c`，291 行）— 已按此实现

原版逻辑（返回 bool = 是否发生过改判，Generate 里为 true 会再跑一次 FilterProvinceCells）：
1. 遍历省份，跳过 id==0 / 非陆地省（`+0x89==0`）/ cell 集合为空的省。
2. `GetMainCell(prov)` 取主 cell（失败返回 -1 → 跳过）。
3. `CollectComponent(mainCell, provId)` 收集主 cell 所在的同省连通分量（HashSet）。
4. 若分量 cell 数 == 省 cell 数 → 无碎片，跳过。
5. 否则：把"本省但不在主分量"的 cell 收集起来，逐个 BFS 成分量 `comp2`：
   - 遍历 `comp2` 的邻格：若邻格属本省且不在主分量 → 继续收集；若邻格属**别的省**且 `height < 20`（海）→ `touchSea = true`。
   - `if (!touchSea)`（内陆飞地）→ 对 `comp2` 每个 cell 调 `FindBestNeighborProvince` 改判给邻省，返回 true。
   - 靠海碎片（离岛）**保留**，不改判。

结论：**内陆飞地并入邻省，跨海离岛保留** —— 这也反证了省份扩张允许跨越水域，否则不会产生离岛碎片。
重建版对应：`_ensure_province_connectivity()`（主分量=含 center 者；触海保留；内陆碎片并入"邻接最多"的省）。
差异：`FindBestNeighborProvince` 未反编译，"邻接最多"是可观测量的等价近似，已标注。

### 7.3 CreateSeaProvinces（`CreateSeaProvinces.c`，108 行）— **第七轮已实现**

原版逻辑：遍历 `World+0x278`（水域集合，每项一个海洋省种子），跳过索引 0，为每项建一个 Province：
- `prov+0x10` = 新 id = `水域数 - 1 + 索引`（编号接在陆地省之后）
- `prov+0x89 = 0`（**非陆地省**标志，与 CreateProvinces 的 `=1` 相对）
- 名字 = 前缀 + 序号；同时写 `cellIdxDict_0x90[cell] = 索引`
- 与陆地省不同，这里**不**预写 `cell→province` 字典

### 7.4 ExpandSeaProvinces（`ExpandSeaProvinces.c`，221 行）— **第七轮已实现**

原版逻辑：
1. `new Queue`（`DAT_182efb0c0`，**普通 FIFO 队列**，计数在 `+0x20`；`FUN_1814ee2b0` 入队 / `FUN_1814edb90` 出队）——与 ExpandProvinces/ExpandStates 的优先队列是**不同类型**。
2. 种子：`foreach (prov in provinces)`，取 `prov+0x10 != 0 && prov+0x89 == 0`（海洋省）；`cellProvinceDict[centerCell] = prov.id`；节点 `+0x14=centerCell, +0x10=0, +0x1c=biome, +0x18=prov.id`；入队。
3. 主循环：出队，遍历 `GetNeighborCells`；若 `cellProvinceDict[nb] < 1`（未归属）且 `heightInt[nb] < 20`（海）→ `cellProvinceDict[nb] = prov.id`；节点代价字段固定写 **1.0f**；入队。
4. **没有任何代价公式、没有松弛、没有优先队列** —— 纯广度优先的"海域归属洪水"。

结论：海洋省 = 按水域分块、纯 BFS 洪水填充；与省份扩张的 Dijkstra 完全不是一套机制。
重建版差距：重建版海洋不建省（`cell_province = -1` 表示海），因此"点击海洋/海洋省"相关表现缺失。属明确的未实现项。

### 7.5 管线顺序的一处重要更正（待下轮处理）
`Generate()` 的真实分支（`BurgsAndStateGenerator_Generate.c` L133-L281）：

```
if (地块已存在) { 清理海洋省 → PlaceProvincialCapitalsByJitterGrid }
SelectCapitalsFromProvinces          // 无条件
CreateStates                         // 无条件
if (新建地图)  { CreateProvinces → ExpandProvinces → CreateSeaProvinces → ExpandSeaProvinces }
ExpandStates → FilterProvinceCells → EnsureProvinceConnectivity?(→FilterProvinceCells) → RecalculateProvinceState → ...
```

即"成省 → 扩省"这段只在**新建地图**分支里跑，而"选首都 → 成国"在两条路径上都在它**之前**执行。重建版当前的顺序是"成省→扩省→成国→扩国"，与新建地图分支的语义接近但并非同构（重建版把 SelectCapitalsFromProvinces 折进了 `_gen_states` 的首都挑选）。这一点已记录为差距，不在本轮改动范围。


### 7.6 SelectCapitalsFromProvinces 精读（第二批反编译最后一项，2026-10-30 13:08）

> **状态：2026-10-30 第五轮已实现** —— `scripts/mapgen.gd` 的 `_select_capital_provinces()`，三种子均得到恰好 26 国。

伪代码：`reports/decompiled/BurgsAndStateGenerator_SelectCapitalsFromProvinces.c`（279 行）。
这个方法决定**"哪些省成为国家首都省"**，也就是**国家数量与位置**的真正来源。

#### 算法（逐段）

```
N        = param_1+0x18                      // 目标国家数（UI/配置传入）
cells    = World+0x138 * World+0x13c         // 地图总 cell 数（宽×高）
radius   = sqrt(cells / N)                   // ★ 唯一"间距参数"，由总格数与目标国数推出
marked   = { p : p+0x58 != 0 且 p+0x66 != 0 }  // 已经带首都标记的陆地对象
need     = N - marked.Count                  // 还缺几个

do {
    list = []                                // 候选首都集合
    for (p in 所有陆地对象) {
        if (p 已归属国家(dict_0xa8[p+0x38] != 0)) continue;
        pos = World.GetSite(p+0x38).位置
        accept = true
        for (q in list) {                     // ★ 泊松盘式最小间距筛选
            if (DistanceSquare(pos, GetSite(q).位置) <= radius^2) { accept = false; break; }
        }
        if (accept) list.Add(p)               // 与所有已选点距离 >= radius
    }
} while (list.Count < need);                  // 不够就缩小半径重试
  // 每轮失败：Debug.LogWarning + radius /= 1.2
  // radius <= 1.0 时直接接受现有结果（防止死循环）

// 收尾：把 list 里的对象逐个取出，建对象、置 +0x58 = 1（首都标记）、加入集合
// 该标记正是 CreateStates 用来"一 cell 一国"的判据
```

关键常数与规则：
1. **radius = sqrt(总 cell 数 / 目标国家数)** —— 唯一的间距参数，不是硬编码常量；
2. 候选条件：**陆地 + 尚未归属任何国家**；
3. 筛选：与已选点的**平方距离 > radius²**（即彼此至少相隔 radius）；
4. 拒绝采样失败时 **radius /= 1.2**（1.2 是硬编码常量）循环重试，**radius ≤ 1.0 时兜底接受**；
5. 选中的对象置 `+0x58 = 1`，`CreateStates` 随后按该标记"每个标记 cell 建一国"。

#### 与重建版对照（当前是自研近似）

重建版 `_gen_states()` 的首都挑选是：按**省份邻接度降序**排序 → 依次取"不与已选省相邻"的省 → 取满 `state_count`。
差异三处：
1. 原版是**空间均匀采样**（几何距离 + 动态半径），重建版是**图拓扑排序**（邻接度）；
2. 原版半径由 `sqrt(cells/N)` 自动推出并能按 1.2 收缩，重建版无此机制；
3. 原版候选要求"陆地且未归属国家"，重建版是"省份互不相邻"。

影响：国家数量同为 N，但**分布**不同 —— 原版趋向"均匀铺满地图"，重建版趋向"占据高连通省份"。这解释了为什么重建版常出现大片空白海域两侧国家大小不均。

#### 可直接落地的实现要点（下轮）

- 用 cell 坐标算平方距离；`radius = sqrt(W*H / state_count)`；
- 候选 = 陆地 cell（或省份中心 cell，二者等价度较高）；
- 逐 cell 判 `dist² > radius²` 才接受；不足则 `radius /= 1.2` 重来，`radius <= 1.0` 兜底；
- 选中 cell 所在的省份 → 该国首都省（原版是"标记 cell"，重建版以省为最小单位，取该 cell 所属省）。


### 7.7 World.DefineOceanGroup 精读（第七轮新反编译，验证海域分组）

伪代码：`reports/decompiled/World_DefineOceanGroup.c`（签名 `string DefineOceanGroup(int size)`）。逻辑极简，按"海域规模"返回三种名字常量：

```
if (size <= world.cellCount / 100)  return DAT_182eb81b8;   // <=1%  最小档
if (size <= world.cellCount / 25)   return DAT_182e86b60;   // <=4%  中档
                                    return DAT_182ef5518;   // 其余  大档
```
（`/25` = 4%，`/100` = 1%；`world+0x250` 为总格数）

结论：
1. 原版确实按**连通海域**分组，且分组有**规模分级**（三档命名）——频证 `CreateSeaProvinces` 遍历的是"海域集合"而不是"每个海格"。
2. 重建版据此实现了 `sea_tier` 字段（0/1/2 三档，按 `size` 与总格数比值判定），与 `DefineOceanGroup` 的阈值一致；分档名称字符串尚未取到（`DAT_*`），暂用"海域 N"编号名。

## 8. 第七轮新增证据：高度图与群系

### 8.1 高度图入口（`logs/dec3_HeightMapGenerator__GenerateHeightMap.json`）

```c
void HeightMapGenerator.GenerateHeightMap(this) {
    HeightMapGenerator.GenerateFromTemplate(this, 3, 0);   // ★ 模板编号 3
}
```
即：原版高度图 = **按模板 3 生成**（`GenerateFromTemplate(templateIndex)`）。模板内容与算符（addHill/addPit/addRange/addTrough/addStrait/smooth/mask/addStep）正在反编译，`GenerateFromTemplate` 产出后即可落地。

方法清单（`methods-assembly-csharp.csv`，全部带 RVA）：
`GenerateFromTemplate 0x38b960`、`GenerateHeightMap 0x38bbd0`、`get_HeightMap 0x38bc80`、`addHill 0x38ecd0`、`addPit 0x38ed80`、`addRange 0x38ee30`、`addStep 0x38ef00`、`addStrait 0x38f3a0`、`addTrough 0x38fb80`、`mask 0x38fc50`、`smooth 0x38fe50`、`Modify 0x38c8b0/0x38cc00`、`Rand 0x38d990`、`GetBlobPower 0x38bbe0`、`GetLinePower 0x38c210`、`GetPointInRange 0x38c2b0`。
调用方：`World.GenerateHeightMap 0x6ae940`、`World.GenerateNoiseHeightmap 0x6b1970`、`World.GenerateHeightMapFromJs 0x6ae870`、`World.EnsureHeightMapExternalInitialized 0x6ac7a0`。

### 8.2 群系表（`Biomes.Initialize` + 资源文件）

`Biomes.Initialize`（`reports/decompiled/Biomes_Initialize.c`）只做两件事：
1. 造一个 **5 项浮点表**（`1.5 / 1.3 / 1.2 / 1.4 / 1.6`，即 `0x3fc00000/0x3fa66666/0x3f99999a/0x3fb33333/0x3fcccccd`），存到 `Biomes 静态 +0xb8 → +0x78`；
2. 调 `LoadBiomeResourcesFromJson`。
——**不是** biome 移动代价表（代价表在 `+0xb8→+0x20`，元素 ≥13）。代价表应由 `Biomes..cctor (0x363f20)` 或 `GetBiomeNameIndex (0x362bb0)` 附近初始化，下一批再挖。

群系数据（硬证据，已复制进工程）：
- `assets/origin/BiomeResource.json` = 原版 `Base/BiomeResource/BiomeResource.json`：60 种资源（BaseValue + AffectedBy） + **13 个群系**的资源概率分布。
- `assets/origin/biome_localization.csv` = 同目录资源本地化。
- `assets/origin/biomes.json` = 从原版主 `localization.csv` 抽取的 13 个群系 **中英文对照**（顺序即 biome index）：

| idx | name | 中文 |
|---|---|---|
| 0 | Marine | 海洋 |
| 1 | Hot desert | 热带沙漠 |
| 2 | Cold desert | 寒带沙漠 |
| 3 | Savanna | 热带草原 |
| 4 | Steppe | 草原 |
| 5 | Tropical seasonal forest | 热带季节性森林 |
| 6 | Temperate deciduous forest | 温带落叶林 |
| 7 | Tropical rainforest | 热带雨林 |
| 8 | Subtropical evergreen broadleaf forest | 亚热带常绿阔叶林 |
| 9 | Taiga | 针叶林 |
| 10 | Tundra | 苔原 |
| 11 | Snow-covered land | 积雪地带 |
| 12 | Wetland | 湿地 |

该 13 群系集合与 Azgaar FMG 的 biome 列表完全一致，说明本作是 FMG 体系的移植；后续 biome 判定可用"温度 × 湿度"矩阵（具体阈值须以 `GenerateFromTemplate`/`World.GenerateBaseMap` 反编译为准，不得凭空设定）。

## 9. 第八轮新增证据：四层地图编辑器（原版真实规格）

> 这一节的规格**全部来自原版元数据 dump 与官方文案**，不是凭想象设计的按钮。
> 证据：`reports/dump-assembly-csharp.txt`（type#409 `EditPanelUI`、type#116 `BrushManager`、
> type#453 `HeightmapTemplates`）、`StreamingAssets/localization.csv`。

### 9.1 编辑模式（`EditPanelUI.m_EditModeDropdownValueToMode` + 各 `Edit*Panel` 字段）

原版编辑面板有 **13 个模式**，不是一个"编辑"开关：

| 模式 | 面板字段 | 重建版状态 |
|---|---|---|
| 编辑高度 | `EditHeightPanel` | ✅ 第八轮 |
| 植被图（群系） | `EditBiomPanel` | ✅ 第八轮 |
| 行省图 | `EditProvincePanel` | ✅ 第八轮 |
| 国家图 | `EditStatePanel` | ✅ 第八轮 |
| 区域 | `EditDistrictPanel` | 🟨 仅数据字段（district_*），无独立模式 |
| 空白不可征服区 | `EditBlankAreaPanel` | ⬜ |
| 文化 | `EditCulturePanel` | ⬜ |
| 宗教 | `EditReligionPanel` | ⬜ |
| 家族 | `EditFamilyPanel` | ⬜ |
| 自定义标签 | `EditCustomLabelPanel` | ⬜ |
| 自定义图片 | `EditCustomImagePanel` | ⬜ |
| 地图尺寸 | `MapSizePanel` | ⬜（`PolyCount`：20000/30000/40000 cell 三档） |
| 全局指令 | `GlobalCommandsPanel` | ✅ 第八轮（开关已接玩法） |

### 9.2 每层的笔刷参数（`EditPanelUI` 字段名逐条对应）

| 层 | 半径滑杆 | 其它参数 | 操作按钮 | 官方操作说明（localization） |
|---|---|---|---|---|
| 高度 | `HeightBrushRadiusSlider` | `BrushHeightSlider`（笔刷高度）、`DecayFactor`（衰减系数） | `EditHeightButton`(绘制) / `EraseContinentButton`(擦除陆地) / `PlaceContinentButton`(放置大陆) / `OnGenHeightMapButtonClicked`(生成高度图) | `TerrainBrushDraw`：按笔刷高度与半径绘制高度图；`TerrainBrushDiffuse`：点击放一块中心高四周低的大陆，衰减速度取决于衰减系数；`EditHeightDescriptionTips`：高度 > 70 为险要 |
| 群系 | `biomBrushSizeSlider` | `currentDrawBiomID`、`TemperatureModifier`、`PrecipitationFactor`、`BiomeSelections` | `WorldRegenerateBiom`（按温湿度重算生态） | `EditBiomTips`：在地图外观里切到植被图并调行政图透明度查看生态 |
| 行省 | `ProvinceBrushRadiusSlider` | `currentDrawProvinceID`、`AverageProvinceCellCountSlider` | `DrawProvinceButton` / `PlaceProvinceButton` / `OnAddProvinceButtonClicked` | `TerrainProvinceEditBrush`：最小单位是 1 个 voronoi cell；shift+左键选省；alt+左键设省会；`TerrainProvinceCreateBrush`：点击生成只占 1 cell 的新省并自动进入绘制 |
| 国家 | `StateBrushRadiusSlider` | `currentDrawStateID`、`PlaceStateInSeaToggle`、`StateCountSlider`、`StateMapTransparency` | `DrawStateButton` / `EraseStateButton` / `OnPlaceStateButtonClicked` | `TerrainStateEditBrush`：shift+左键选国家；国家最小单位是行省，笔刷扫到的行省整块归该国 |

### 9.3 BrushManager（笔刷本体）

成员：`brushHeight`、`GetCurrentBrushRadius()`、`GetCurrentBrushThickness()`、`GetCurrentBrushColor()`、
`GetColorFromHeight()`、`DrawShapes()`、`TryAdjustCurrentBrushRadius()`、`TryAdjustCurrentBrushHeight()`、
`IsBrushRadiusShortcutActive()`、`IsCtrlPressed()`、`IsAltPressed()`。
笔刷模式文案（5 种）：`BrushModeAdd` 增加 / `BrushModeSubtract` 减少 / `BrushModeMax` 最大值 /
`BrushModeMin` 最小值 / `BrushModeAverage` 平均值。

⚠️ 重建版：半径/高度/模式/形状（圆形 + 二次衰减）已按上述语义实现；**`DrawShapes` 的混合算符未取到**
（`logs/dec5_BrushManager__DrawShapes.json` 排队中），因此五种模式的算式是显式近似。

### 9.4 全局指令面板（`GlobalCommandsPanel` 字段 → 玩法效果）

| 原版控件 | 官方文案 | 重建版是否真的生效 |
|---|---|---|
| `AllowRebellionButton` | 允许叛乱 | ✅ 写 `rules.allow_rebellion` |
| `AllowCivilWarButton` | 允许内战 | ✅ 同上 |
| `AllowFamilyRebellionButton` | 允许家族叛乱 | ✅ 同上 |
| `AllowVassalRebelButton` | 允许附庸叛乱 | ✅ 同上 |
| `AllowAllianceButton` | 允许联盟 | ✅ 关掉后不再缔结联盟（`_try_alliances` 直接返回） |
| `EnableVassalButton` | 启用附庸 | ✅ 关掉后不再选附庸战争目标 |
| `AllowDiplomacyButton` | 允许自主外交 | ✅ 字段接入 |
| `AssistAlliesOccupyLandButton` | 协助盟友占领土地 | ✅ 割地时若目标省不与本国相邻而与盟友相邻 → 转给盟友（官方 `GlobalCommandTutorial` 原文语义） |
| `AllowAutoAbandonIsolatedProvincesButton` | 自动放弃孤立行省 | ✅ 每月检查"与首都不可达 + 四周无本国省"，满 12 个月放弃 |
| `GenerateDesertAndSnowButton` | 开启雪原和沙漠区域生成 | ✅ 字段接入（群系重算时使用） |
| `ClearMap` / `WorldClearMap` | 清空地图 | ✅ 高度归零 + 行政/群系清空 + 重建一个海洋省 |
| `RegenerateDistrictsButton` | 重新生成区域 | ✅ 按行省规模重算 district_* 字段 |
| `AllowEndAllWar`（`OnEndAllWarButtonClicked`） | 结束所有战争 | ✅ |
| `OnEndAllAllianceButtonClicked` | 结束所有联盟 | ✅ |
| `ClearHistoryButton` | 清空历史 | ✅ |
| `SetCustomTimeButton` | 设置时间 | ✅（年/月输入，官方范围常量 c_SetCustomTimeMinYear/MaxYear） |
| `AutoSaveButton` + `AutoSaveIntervalMinutesKey` | 自动存档 | ✅ 存档心跳 |
| `RebelIntervalSettingsButton` | 叛乱间隔 | ✅ `rules.rebel_interval_months` |
| `MapEditingInstructions` 提到的"刷新河流与航线" | — | ✅ 河流与地形散布按新高度重算 |

### 9.5 高度图生成入口的真面目（第八轮新反编译）

`HeightMapGenerator.GenerateFromTemplate`（`reports/decompiled/HeightMapGenerator_GenerateFromTemplate.c`，80 行）：

```c
Templates = HeightmapTemplates.get_Templates();          // 模板数组
tpl = Templates.Find(name/idx);                          // 取模板对象
text = tpl[+0x18];                                       // ★ 模板正文是一段文本
lines = text.Split("\n");
foreach (line in lines) {
    parts = line.Trim().Split(separator);
    if (parts.Length < 2) { Debug.LogError(...); }
    HeightMapGenerator.addStep(parts);                   // 每行 = 一个算子
}
```

结论：
1. 原版高度图 = **文本 DSL 模板 + 逐行 addStep 解释执行**（与 Azgaar FMG 的 heightmap template 语言同构）。
2. 模板正文由 `HeightmapTemplates..cctor`（0x39b350）在代码里构造 —— **下一步反编译它即可拿到全部模板原文**（含 `GenerateHeightMap` 用的模板 3）。
3. `addStep` 是解释器（算子名 + 参数），需与 `addHill/addPit/addRange/addTrough/addStrait/smooth/mask/addStep` 一起落地。


## 10. 第八轮：`World.GenerateHeightMap` 编排（含地图尺寸与海平面常数）

伪代码：`reports/decompiled/World_GenerateHeightMap.c`（207 行）。要点：

```c
world.seed        = Random.Range(0, int.MaxValue);      // 每次生成换种子
world.flag2c1     = 0x100;
isSmallMap        = Random.Range(0,3) == 0;             // 1/3 概率是"小图"
polyCount         = isSmallMap ? 10000 : (Random.Range(1,3)+1)*10000;   // 10000 / 20000 / 30000 / 40000
if (Random.value < 1.0 /*恒真*/ || world+0x140 > 59999)  →  不走噪声图分支
world.seaLevel(+0x178) = 0x14 = 20;                     // ★ 海平面高度 = 20（0..100 制）
ClearMap(); 清空 province/state/culture/... 数组;
GenerateHeightMapFromJs();      // ★ 真正的高度图生成（名字带 Js：Puerts 侧入口）
SetSeaElvationToZero();         // 海面高度归零
DrawRiver(); EnsureFeatureDataReady(); UpdateAllDrawProvince();
```

与原版的对照结论：
1. **地图尺寸是 4 档**（10000/20000/30000/40000 cell），对应 `EditPanelUI.PolyCount` 与 `MapSize{Low,Medium,High,SuperHigh}` 文案。重建版固定 480×280=134400 格，**数量级不同**（已记为差距）。
2. **海平面高度 = 20**（`world+0x178`），与 `ExpandProvinces` 里"`height >= 20` 才算陆地"完全一致 —— 这证实重建版当前"自适应分位海平面"是近似，应改为固定 20/100。
3. 高度图生成的真实入口是 `World.GenerateHeightMapFromJs`（Puerts/TS 侧），C# 侧 `HeightMapGenerator.GenerateFromTemplate` 是它调用的模板解释器。
4. 生成后立刻 `DrawRiver()` 与 `EnsureFeatureDataReady()`（特征/群系数据），说明"高度 → 河流 → 生态"是原版固定顺序，与重建版 `_gen_elevation → _gen_biomes → _gen_provinces` 的顺序一致（河流位置不同：原版在行省之前）。


## 11. 原版实机截图实证（2026-10-30 16:25，用户手动运行原版提供）

参考图存于 `tests/origin_shots/`（`origin_map.jpg` / `origin_state_panel.jpg` /
`origin_state_actions.png` / `origin_state_sections.jpg` / `origin_editor_panel.jpg`）。
这批截图把此前只能靠字段名推测的 UI 规格钉死了：

### 11.1 底部工具栏（与重建版逐项一致）
`生成地图 / 地图外观 / 菜单选项 / 历史记录 / 统计信息 / 设为壁纸 / 地图编辑 / 暂停游戏 / 1倍速 / 常见问题`
——**进入编辑时第 8 个按钮变成「继续游戏」**（实证 PauseWhenEditing）。

### 11.2 事件横幅格式
`公元1年-2-13: 宣成侯以吞并为由对张侯宣战，目标：吞并全境`
→ 日期是 **公元{年}-{月}-{日}**（有"日"）；`WarV2_Declared` 的 `{1}` 参数是**战争目标的短名**（"吞并"），
不是战争类型名（"征服战争"）。重建版已按此修正（`simulation.gd`）。

### 11.3 国家信息面板（左停靠，实测）
- 版式：贴左边、满高的羊皮纸面板；标题「国家信息」；国名灰色输入框 + 一条 12px 国家色条。
- 折叠区（带 ⚑ 图标与 ⌃/⌄）：**基本信息 / 国家行为 / 腐败度 / 附庸国 / 设置 / 输入军团数量 /
  领土记录 / 战争 / 家族 / 国家特性 / 外交 / 历史记录 / 资源**。
- 基本信息字段（逐行）：政治体制、文化、宗教、民族特征（前三个是下拉）；
  信息表：国家 / 存在时间 / 皇帝 / 内阁首辅 / 户部尚书 / 兵部尚书 / 首都 / 人口 / 人口上限 /
  腐败度 / 国库 / 军队数量 / 战舰数量 / 行省数量 / 区域数量。
- **人口量纲**：截图实例 `丰` 国 57 行省、人口 406.8万、上限 561.3万 → 单省约 7 万，
  重建版此前单省 400~1200 明显偏小，本轮按 ×1000 校准（生成随机流不变，基线不受影响）。
- 国家行为按钮（2 列，按色分组）：扩张/煽动叛乱（粉）、内战/吞并（红）、发起战争/停战（粉）、
  缔结盟约/退出同盟（蓝）、腐败度 降低/加深（黄）、附庸国 收为附庸/独立（绿）、
  设置 自主外交:开（灰蓝）、输入军团数量 + 放置军队 + 自定义命名 + 兵种编辑 + 官职称谓 +
  官员任用 + 生成家族。

### 11.4 地图编辑面板（右停靠，实测）
- 标题「地图编辑」；模式下拉共 **12 项**：编辑高度 / 编辑生态 / 编辑行省 / 编辑国家 / 编辑区域 /
  编辑无人区 / 编辑文化 / 编辑宗教 / 编辑标签 / 编辑图片 / 编辑家族 / 全局指令（当前项打勾）。
- 分页：`<<  Page 1 of 3  ›`（国家列表翻页）。
- `随机国家`（蓝）；`笔刷半径` 滑杆 + 数值（**两位小数**，如 3.50）。
- 2×2 按钮：**编辑（蓝）/ 删除（红）/ 绘制（绿）/ 擦除（橙）**。
- 底部：`提示` / `清空地图` / `关闭面板`。

### 11.5 地图观感
- **国界为暗红粗线**（约 2~3px），海岸线深褐，行省界线极细；
- 经纬网是**虚线**；
- 国家名是很大的衬线字，国界内还有小圆点（城邑）与 ∧ 形山地图标。

重建版按以上 5 点做了对齐（`map_render.gd` 国界色/粗细、虚线经纬网；`main.gd` 两个面板的版式与文案）。

## 12. 高度图算子（第八轮新反编译，逐步补齐）

### 12.1 `HeightMapGenerator.addHill`（`reports/decompiled/HeightMapGenerator_addHill.c`，29 行）

```c
void addHill(this, a, b, c, d) {
    copy 4 个字符串参数（a..d）;
    for (n = RandomUtils.GetNumberInRange(a); n > 0; n--)
        <addHill>g__addOneHill_13_0(this, &params, 0);   // 局部函数：单次落丘
}
```

要点：
1. 模板 DSL 的每个算子接收**字符串参数**，数量/坐标等用 `RandomUtils.GetNumberInRange(expr)` 求值
   —— 即支持 `"3"` 与 `"1-4"` 这类写法（区间随机），与 Azgaar FMG 的模板语法一致。
2. `addHill` 的第 1 参是**个数**，其后 3 个字符串是位置/半径/高度类参数（顺序待 `addStep` 确认）。
3. 真正的地形修改在局部函数 `addOneHill`（需单独反编译 `<addHill>g__addOneHill_13_0`）。

### 12.2 待补齐清单（下一批）
- `HeightmapTemplates..cctor`（0x39b350）：**模板正文**（12 个模板的文本，含 `GenerateHeightMap` 用的模板 3）
- `HeightMapGenerator.addStep`：DSL 解释器（算子名 → 函数、参数顺序）
- `<addHill>g__addOneHill_13_0` / `addPit` / `addRange` / `addTrough` / `addStrait` / `mask` / `smooth` 的局部函数

### 12.3 `addRange` / `smooth` 签名（2026-10-30 17:57 补，第三批 ALL_DONE）

```c
// addRange(this, countExpr, s3, s4, s5)
void addRange(this, a, b, c, d) {
    display = new <>c__DisplayClass15_0;
    display.field10 = b; display.field18 = this;     // 存字符串参数
    display.field20 = c; display.field28 = d;
    for (n = RandomUtils.GetNumberInRange(a); n > 0; n--)   // 第 1 参 = 次数
        <addRange>g__addOneRange_0(display);
}

// smooth(this, s1, s2)：两个参数都是 System.Int32.Parse → 纯整数（次数 / 强度）
void smooth(this, a, b) {
    n = Int32.Parse(a);  f = Int32.Parse(b);
    ... 对高度表做 n 轮（强度 f）平滑
}
```

结论：
1. 所有 `add*` 算子的**第 1 个参数都是"次数表达式"**，由 `RandomUtils.GetNumberInRange` 求值（支持 `1-4` 区间）。
2. 其余参数是原样字符串，只在各自的局部函数里解释（`addOneHill` / `addOneRange`），**单位与顺序必须看局部函数**，
   不能从签名推断。
3. `smooth` 是唯一的纯整数算子（两参都用 `Int32.Parse`），说明模板里它可以写 `"smooth 2 3"` 这类。

---

## 13. 第九轮：模板正文到手 + 高度图算法换血（2026-10-30 19:50）

### 13.1 关键转折：模板正文不用反编译，直接在 `global-metadata.dat` 里

第八轮的待办一直写着"等 `HeightmapTemplates..cctor` 出模板正文"，那条路**走错了**。
IL2CPP 的托管字符串字面量**不在** `GameAssembly.dll` 里，而在
`FantasyMapSimulator_Data/il2cpp_data/Metadata/global-metadata.dat`。

实证：
- 在 `GameAssembly.dll` 里按 `hill/range/smooth/trough/strait/mask/pit` 扫长 ASCII 串，**命中 0 条**。
- 在 `global-metadata.dat` 里同样扫，命中集中在 `0x5f8xx–0x600xx`，正是字符串字面量堆。

解析方法（可复用）：
```
文件头 sanity=0xFAB11BAF, version=29
从 +8 起是连续的 <int32 offset, int32 count> 对：
  第 1 对 = stringLiteral 表（每条 <int32 len, int32 idx>，8 字节）
  第 2 对 = stringLiteralData 堆（UTF-8 字节流）
取字符串 i:  ln,idx = unpack('<ii', data, litOff + i*8)
             data[dataOff+idx : dataOff+idx+ln].decode('utf-8')
```

### 13.2 5 份模板正文（literal 6866 / 6867 / 6868 / 6869 / 10442，共 70 行）

已落盘 `source/fms-godot/assets/origin/heightmap_templates.json`（带出处与 `_unverified` 标注）。
算子全集共 **9 个**：`Hill / Range / Trough / Strait / Pit / Mask / Multiply / Add / Smooth`。

> ⚠️ **顺序陷阱**：字面量堆是**按字典序排序**的，所以 `order_seen 0..4` 只是字面量编号，
> **不等于** `HeightmapTemplates.Templates` 列表的插入顺序。而 `GenerateFromTemplate(this, 3, 0)` 里的
> `3` 是列表下标。二者对应关系**仍未证明**（见 §13.5）。

### 13.3 路径分叉：新游戏先走 JS 通道，失败才回落 DSL

`World.GenerateHeightMap`（第八轮已反编译）显示，真正的新游戏路径调用的是
`World.GenerateHeightMapFromJs`，**不是** `HeightMapGenerator.GenerateHeightMap`。
`GenerateHeightMapFromJs` 走的是 JS 外部插件通道。
实测游戏目录内**不存在任何 `.js` 文件**，所以实际生效的是内置 DSL 回落路径——
这一点目前是"排除法"推断，不是正面证明。

### 13.4 算法蓝本：Azgaar FMG（同构，已交叉验证）

这套 DSL 语法与 9 个算子集合，与开源项目 Azgaar's Fantasy Map Generator 的高度图生成器**完全同构**。
更硬的证据是字段名逐字对应：

| 游戏 `HeightMapGenerator`（反编译） | Azgaar `heightmap-generator.ts` |
|---|---|
| `blobPowerMap` / `linePowerMap` | `blobPowerMap` / `linePowerMap` |
| `heights` / `blobPower` / `linePower` | `heights` / `blobPower` / `linePower` |
| `graphWidth` / `graphHeight` | `graphWidth` / `graphHeight` |

且已反编译的 `smooth` 公式 `(avg + (a-1)*cur + b) / a`（`a==1` 时退化为 `avg + b`）
与开源实现**逐字一致**。蓝本副本已存 `reference/azgaar/*.ts`。

`addStep` 的分发规则（来自蓝本，待伪代码核对）：
`Mask → mask(a2)`，`Add → modify(a3, +a2, 1)`，`Multiply → modify(a3, 0, +a2)`。

`getNumberInRange` 语义（来自蓝本）：
- 纯数字 `"3"` → 整数部分 + 概率进位（`0.5` → 50% 出 1）；
- 区间 `"1-4"` → 闭区间整数随机。

### 13.5 仍未证明的一件事

`TEMPLATE_INDEX = 3` 目前取的是"字面量顺序第 4 份"。要钉死它，唯一硬证据是
`HeightmapTemplates..cctor`（RVA 0x39b350）里 `List.Add` 的调用顺序。
曾尝试直接扫 cctor 机器码里的 `mov imm32`（找 5 个 literal index 立即数），**无命中**——
IL2CPP 字面量走的是 metadata usage 间接表，不是立即数。所以只能反编译。

### 13.6 分辨率教训：DSL 必须跑在原版 cell 数上

第一版直接按 480×280（13.44 万 cell）跑 DSL，模板 3 只出 **7.9% 陆地**——
因为 BFS 扩散是**按步数衰减**的，格子越密、单个特征相对整张图就越小。
原版只有 1~4 万 cell。改为**按 2 万 cell 跑完再最近邻上采样**后，陆地回到 52%（探针实测）。
`heightmap_dsl.gd` 的构造函数已支持传入目标 cell 数。

## 14. 第十轮：模板列表插入顺序证实（2026-10-31 00:11-01:30）

**结论**：`GenerateFromTemplate(this, 3, 0)` 的 `3` = 原版 `HeightmapTemplates.Templates` 列表下标，
`Templates[3]` = **literal 6867**（"Continents" 名字组第二份，游戏自创模板）。
此前工程使用的 literal 6869（Azgaar highIsland，旧 order_seen=3）实际是 `Templates[1]`，**已改正**。

### 14.1 证据链（全部为机器码直接观测，工具 `tools/scan_template_order.py`）

1. **定位**：`HeightmapTemplates$$.cctor` @ VA `0x18039B350`（seeds，RVA 0x39b350）；下一个方法
   `get_Templates` @ `0x18039B690` → cctor 函数体 ≤ 0x340 字节。
2. **v29 字符串 usage 编码**：槽位 qword = `(5<<29) | (literal_index << 1)`。
   验证：`0xA0002255`→lit[4394]='Continents'、`0xA0006E23`→lit[14097]='Volcano'、
   `0xA0003593`→lit[6857]='High Island'、`0xA00035A5..AB`→lit[6866..6869]、`0xA0005195`→lit[10442]。
   （另一族 `(5<<29)|idx` 未移位值被证实为巧合数据：其代码引用全在 System/Protobuf/Mono 区。）
3. **槽位独占性**：8 个字符串槽位（.data 0x182EBE5C0..0x182EEB328）在全 .text 的 RIP 相对引用
   **只出现在 cctor 窗口内**，别处无引用。
4. **结构**：序言 13 次 `call 0x1802334A0`（元数据惰性初始化，8 字符串槽 + 5 类/方法槽）；
   之后 **5 个等距 0x69 字节构造块**，第 k 块恰好引用一对字符串槽位（正文,名字）并各含一次
   ctor 调用与一次列表 Add（`0x180304090`；ctor/ setter 地址被 ICF 折叠，见 ghidra_seeds.txt `# folded` 标注）：

   | Add 顺序 | 名字（机器码观测） | 正文 literal | Azgaar 对应 |
   |---|---|---|---|
   | 0 | Volcano | 6868 | volcano（逐字一致） |
   | 1 | High Island | 6869 | highIsland（逐字一致） |
   | 2 | Continents | 6866 | continents（逐字一致） |
   | **3** | **Continents** | **6867** | **不存在于 Azgaar（游戏自创）** |
   | 4 | Continents | 10442 | 不存在于 Azgaar（游戏自创） |

   三组名字↔正文语义独立匹配 Azgaar（`reference/azgaar/heightmap-templates.ts`），编码解释不存在偶然空间。
   #2/#3/#4 共用同一名字槽位 `Continents` 是二进制事实；显示名是否另有本地化**未验证**。
5. **列表下标而非字典键**：`GenerateFromTemplate` 反编译显示 `get_Templates()` 后走
   `IReadOnlyList` 接口分发的 `get_Item(param_2)`；类型转储（`reports/dump-assembly-csharp.txt` type#453）
   属性类型 `IReadOnlyList<HeightmapTemplates+HeightmapTemplate>`。旧 JSON `_unverified` 注记里
   "3 是字典键" 的猜测**作废**。
6. **Ghidra 第二确认**：`logs/dec_HeightmapTemplates__cctor.json`（占位，见 14.4）。

### 14.2 连带修正

- `assets/origin/heightmap_templates.json` 已按 Add 顺序重排（`order_seen` ≡ 原版列表下标），
  增加 `name` 字段与 `_verified` 证据注记（工具 `tools/reorder_templates.py`，一次性）。
- `mapgen.gd::TEMPLATE_INDEX` 保持 3 不变但语义已变（现在**可证明正确**）；注释更新。
- `tests/template_parse.gd` 行数表改为 {0:8, 1:14, 2:15, 3:20, 4:13}；
  `tests/heightmap_dsl_test.gd` 模板#3 端到端现在跑的是 6867（20 步）。

### 14.3 新基线与遗留问题

新默认模板 6867（7 大 Hill + 4×4 Range + 垂直 Strait + Smooth 3）在本引擎 DSL 下产出
**97.7%~98.3% 陆地**（20000 cell 探针 / 480×280 全图），地图形态为"两块大陆 + 垂直海峡 + 小岛"；
原版实机截图（`tests/origin_shots/origin_map.jpg`）是**多块大陆 + 宽阔海洋，陆地约 45~55%**。
结构一致而水量不符 → **主要误差源转移为算子参数/语义**（Hill 的 blobPower、Range 的 randomness、
Trough/Strait/Mask 细节，目前只经 Azgaar 同构交叉印证 + smooth 逐字核对）。
这正是待办 #2（`addStep`/`<addOneHill>`/`<addOneRange>`/`GetNumberInRange` 伪代码）要修的，
对应反编译已在第十轮队列中排队。**在算子语义核对完成前，不得把 97.7% 陆地说成"原版行为"。**

第九轮"视觉比对选 6869"的旧结论修正：同一套（有偏的）算子语义下，错误模板 6869 碰巧
比正确模板 6867 更像原版截图——视觉比较对"选模板"不可靠，对"校算子"也未必可靠。

### 14.4 队列与验证状态（写作时点 00:45）

- 第十轮队列 `tools/decompile_round10_queue.sh` 已通过 **schtasks 任务 `FMSR_dec_r10` 脱离会话运行**
  （00:11 启动，与 AI 会话解耦，不会再被会话回收——HANDOVER §6.13 的教训已落实）。
  队列顺序：cctor → addStep → addOneHill → addOneRange → GetNumberInRange → Biomes.cctor →
  DrawShapes → GetColorFromHeight → GenerateBaseMap（串行，预计 5~7 小时）。
- cctor 的 Ghidra 伪代码已于 00:49 产出（38 分钟，正常窗口内），**与机器码结论逐条一致，无矛盾**，
  已导出 `reports/decompiled/HeightmapTemplates_cctor.c`；队列自动推进到 addStep。

## 15. 第十一轮：算子语义还原（进行中，逐项追加）

### 15.1 addStep 分发层 —— ✅ 反编译逐字证实（01:57 产出，39 分钟）
`reports/decompiled/HeightMapGenerator_addStep.c`（真实签名 (this, op, a1, a2, a3, a4)——
GenerateFromTemplate 调用点只显示 1 参是 Ghidra 寄存器传播缺陷）：
- 9 个算子 if-chain `String.Equals(op, 字面量)`：Hill/Pit/Range/Trough/Strait/Mask/Add/Multiply/Smooth
  （9 个比较槽位全部解码核实）；无 default 分支。
- Hill/Pit：闭包捕获 (this, a2=height, a3=x, a4=y)，次数 = `GetNumberInRange(a1)`，逐次调 addOneHill/addOnePit。
- Range/Trough：新建显示类闭包（Range: +0x10=a2,+0x18=this,+0x20=a3,+0x28=a4；Trough 字段序不同），
  次数 = `GetNumberInRange(a1)`，逐次调 addOneRange/addOneTrough。
- Strait：`addStrait(this, a1=count, a2=direction, 0)`；Mask：`mask(this, a1, 0)`。
- **Add → `Modify(this, a2=range, a1=value, "1", 0, 0)`**；**Multiply → `Modify(this, a2=range, "0", a1=value, 0, 0)`**
  （中性字面量实测 "1" / "0"）；**Smooth → `smooth(this, a1=power, "0", 0)`**。
- 结论：重建版 `heightmap_dsl.gd::run_steps` 的参数位与原版**完全一致**，分发层零修改。
- 勘误：HANDOVER §8 所引「GenerateFromTemplate(this, 3, 0)」中的第三参 0 在
  GenerateFromTemplate 伪代码（仅 (this, param_2)）中不存在，系旧记录笔误。

### 15.2 World.GenerateHeightMap 真实流程 —— ✅ 反编译逐字证实（第十轮末发现，本轮补记）
- cell 数：`Random.Range(0,3)==0` → **10000**，否则 `(Range(1,3)+1)*10000` = **20000/30000**；
  40000 只出现在大图分支（+0x140 ≥ 60001 时强制 40000）。
- 模板选择：构建**两个模板名字符串列表**——小图 5 个：`highIsland / lowIsland / continents / pangea / oldWorld`
  （槽位解码）；大图 7 个：`MoreWorldV4/V6/V6/V6/V7/V8/V5`（**MoreWorldV6 权重 3/7**）；
  `Random.Range(0, count)` **均匀随机**取名字存入 `world+0x3a8`。
- 随后调用 **`World.GenerateHeightMapFromJs`**（0x1806ae870，未反编译）→ `SetSeaElvationToZero` → `DrawRiver`。
  **World 层从不直接调用 HeightMapGenerator.GenerateFromTemplate。**
- JS 通道为真：`Plugins/x86_64/` 内有 **puerts.dll + libnode.dll**；`StreamingAssets/JS/` 只有
  relatives-tree.bundle.js（族谱 UI），**未找到地图生成 JS**（generateMapInJs 在资源中零命中，
  明文/未压缩假设下）——JS 侧内容与回落路径待 `GenerateHeightMapFromJs` 伪代码（第十一轮队列首项）。
- camelCase 键只被 World.GenerateHeightMap / World.GenerateMap / World.InitMapGenerationSettings 引用
  （usage 槽位反查），C# HeightMapGenerator 从不消费它们。
- 影响：第九轮「TEMPLATE_INDEX=3 是原版默认」的叙事**不成立**——原版默认流程是按名字随机选模板进 JS；
  HeightMapGenerator.GenerateHeightMap（硬编码 3，待反编译核实）是哪条路径调用待查。
  模板正文全库仅 5 份（多行 DSL 字面量穷尽扫描），与 5 个小图键的对应关系待 JS 通道证据。

### 15.3 blob_power 敏感性扫描 —— ✅ 运行数据实测（tests/power_sweep.gd，185×108 网格，模板#3=6867）
| blob_power | 陆地占比 seed42/1337/2026 |
|---|---|
| 0.90 | 0.15 / 0.18 / 0.14 |
| 0.93 | 0.16 / 0.13 / 0.18 |
| 0.95 | 0.23 / 0.20 / 0.20 |
| **0.97** | **0.41 / 0.45 / 0.39** |
| 0.98 | 0.73 / 0.80 / 0.78 |
| 0.99（当前，Azgaar 表） | 0.98 / 0.90 / 0.94 |
line_power 0.75~0.90 对陆地占比几乎无影响（0.98-0.99）。**blob_power 是陆地占比的唯一主导杠杆**；
原版 `GetBlobPower` 真值（第十一轮队列）是裁决性证据。当前 DSL 的幂表与 Azgaar 参考副本逐字一致
（抄表无误），偏差要么来自原版自有表值，要么来自网格/维诺拓扑差异。

### 15.4 BasicMap 存档容器 —— ✅ 反编译文案 + 字节结构实证，密钥未解
- 四文件为纯 base64 文本（无文件头），解码后熵 7.999、字节分布均匀 → 块加密。
- **2.save 与 4.save 解码后前 16 字节完全相同** = 恰好一个 AES 块 → CBC + 固定 IV + 相同明文首块。
- 字面量证实容器格式：`'Invalid binary save container signature.'`、
  `'Unsupported binary save container version: {0}.'`、`'Binary save container ended before the AES IV.'`、
  `'[SaveBinary] ContainerVersion={0}, '`、`'System.Security.Cryptography.AesCryptoServiceProvider, System.Core'`；
  加载阶段名 `LoadGameData.File.DetectContainer / File.Decrypt / Resources.Decrypt`。
- 候选密钥（lit[2026]/lit[2040] 两个 32-hex 串、全零串）×（IV=文件前16/后16/hex/零）全部失败（噪声级得分）
  → 真实密钥在 `SaveSystem$$EncryptString/DecryptString`（第十一轮队列末两项），可能是派生密钥或 byte 数组。

### 15.5 addOneHill —— ✅ 反编译逐字证实（03:20 产出）
`reports/decompiled/HeightMapGenerator_addOneHill.c`（内部函数真名 `HeightMapGenerator$$<addHill>g__addOneHill|13_0`）：
- 高度 = `GetNumberInRange(闭包+0x08)`；起点重试：`while (90 < heights[cell]+height 且 尝试<50)` 重新取点 —— **与重建版一致**。
- 取点：`GetPointInRange(x串)` / `GetPointInRange(y串)` → `World.GetCellIndex(...)`（**一参版本**，无 length 参；
  维度在内部用 graphWidth/graphHeight——重建版显式传 w/h 等价）。
- 扩散：队列 BFS，`change[邻] = f(change[当前]) × (Random.value×0.2 + 0.9)`，>1.0 才入队 —— 抖动公式与重建版一致；
  f 内含 `^blobPower` 与否由寄存器调用呈现不清（FUN_1802d1a20），以 GetBlobPower/后续证据为准。
- **写回差异（重建版需改）**：
  1. 原版仅把 **`change > 4.0`** 的格写回（重建版写回一切 ≠0 格）；
  2. 写回 = `Lim(heights[i] + change[i], 0)` —— 若 Lim(v,0) 为仅下限（待 MathUtility$$Lim 伪代码裁决），
     **高度可超 100**（重建版钳 0..100）；
  3. 原版 change 为**浮点字典**（衰减无中间截断；重建版逐级 int 截断，复合误差加速衰减）。
- 邻接 = `World.GetNeighborCells`（维诺图邻接，重建版 8 邻域网格为已知拓扑差异）。
- **暂不改代码**：等 GetBlobPower（表值）+ MathUtility.Lim（钳制语义）到手一并小步修正。

### 15.6 addOneRange —— ✅ 反编译逐字证实（03:47 产出）
`reports/decompiled/HeightMapGenerator_addOneRange.c`（真名 `<>c__DisplayClass15_0$$<addRange>g__addOneRange|0`）：
- 终点公式 `ex = Range(0, w*0.8) + w*0.1`、`ey = Range(0, h*0.7) + h*0.15`；距离 = **曼哈顿**；接受窗口
  `[w/8, w/3]`；50 次重试 —— 与重建版**全部一致**。
- 山脊由 `g__GetRange|1(闭包, startCell, endCell, used[], 0)` 生成（round11 队列）。
- 抬升主循环：frontier 逐格 `heights[c] = Lim((Random.value + 0.85) × h + 原值, 0)` ——
  **抬升因子域 [0.85, 1.85]，重建版原用 [0.85, 1.15]（Azgaar 版）→ 已修正**；
  然后 `h = FUN_1802d1a20(h, linePower) − 1`，`< 2` 停 —— FUN_1802d1a20 经机器码鉴定为
  **powf(float,float)**（NaN/Inf 特判 + 0x7f800000 常量 + 双 float 寄存器参数），
  即 `pow(h, linePower) − 1`，与重建版一致；frontier 邻格入队 + used 标记 —— 一致。
- 山脊突刺：每 6 格沿 LINQ 过滤邻居走 depth 步（谓词 = `<addRange>b__2`，写回值被 Ghidra 吞参
  —— round11 的 b__2/GetRange 产出后精修；重建版现为 Azgaar 同构 `(cur*2+best)/3`，标注为未证）。
- 高度写回 `Lim(x, 0)` 无上限语义待 MathUtility$$Lim（已入 round11 队列）。

### 15.7 RandomUtils.GetNumberInRange —— ✅ 反编译逐字证实（04:13 产出）
`reports/decompiled/RandomUtils_GetNumberInRange.c`：
- 空串 → LogError + 0；`float.TryParse` 成功 → **floor(f) + (Random.value < frac ? 1 : 0)**（概率进位）
  ——与重建版一致（原版用 Floor，重建版用向零截断，仅负小数不同，模板不含）。
- 区间路径：剥一个前导 '-' → `Split('-')` → 部件数必须 ==2（否则**抛异常**，重建版宽容返回 0，记录差异）
  → **`int.Parse` 两端** → `Random.Range(a*sign, b+1)`（Unity int Range，闭区间 [a,b]）
  ——与重建版 `floor(rand*(b-a+1))+a` 分布等价。特例 `0-2147483647` 原版返回 0（疑似原版 bug，模板不用）。
- 非法区间 → LogError + 0。**结论：对模板全部实际输入，重建版 `_num` 语义等价，零修改。**

### 15.8 Biomes.cctor —— ✅ 部分逐字证实（04:39 产出，31.9KB）
`reports/decompiled/Biomes_cctor.c`，真值提取（tools/scan_template_order.py 同族技术直读二进制）：
- **13 个群系真名按原版静态顺序**：Marine / Hot desert / Cold desert / Savannah / Steppe /
  Tropical seasonal forest / Temperate deciduous broadleaf forest / Tropical rainforest /
  Subtropical evergreen broadleaf forest / Taiga / Tundra / Snow-covered land / Wetland
  （13 个 usage 槽解码；**顺序即索引**，可用于校正重建版群系数组顺序与索引映射）。
- **biomesMatrix = 13×4 浮点矩阵**（ctor 立即数全量提取，行序同上）：
  Marine[0.2353,0.5098,0.8235,1] / Hot desert[1,0.8,0,1] / Cold desert[1,0.9020,0.5490,1] /
  Savannah[0.9020,0.8627,0.4314,1] / Steppe[0.6667,0.9020,0.3922,1] / Trop.seas.forest[0.5882,0.9020,0.2745,1] /
  Temp.decid.forest[0.1176,0.7843,0.3137,1] / Trop.rainforest[0.3137,0.8627,0.1176,1] /
  Subtrop.evergr.forest[0.1961,0.7451,0.2745,1] / Taiga[0.3529,0.5490,0.2353,1] / Tundra[0.7059,0.6275,0.3922,1] /
  Snow[0.8627,0.9412,1,1] / Wetland[0.0784,0.7059,0.2745,1]。
  列语义（temp/hum 各列含义）待气候→群系查找函数反编译后标定；第 4 列恒 1.0。
- 另有 2 个 RGBA 颜色立即数：(0.0382,0.4749,0.7723,1.0)（海蓝）与 (0.3843,0.5152,0.6941,1.0)。
- **7 个 13 元素数组（colors/habitability/cost/foodProductionEfficiency/populationInitRange/
  SpeedModifier/CombatEfficiencyModifier 的候选）的真值 blob 未解**：InitializeArray 第二参在 IL2CPP
  是 **FieldInfo usage token 表**（直读证实为 StrLit/TypeInfo/MethodRef/FieldInfo 混合 token，
  非原始数据），真值需经 FieldInfo→字段 RVA 二跳 —— 解析路径：REA `inspect_il2cpp_metadata`
  的 `fieldDefaultValues`/`field_types` 集合（待办，不阻塞高度图主线）。

### 15.9 BrushManager.DrawShapes —— ✅ 反编译逐字证实（05:05 产出）：是光标预览，不是混合
`reports/decompiled/BrushManager_DrawShapes.c`：`IsEnableBrush` → `Shapes.Draw__Command(cmd,0x12)` →
按 PlayerController 模式（+0x90==8）取 `GetColorFromHeight(编辑面板高度滑条值)` 作为**笔刷光标颜色**，
半径 = 当前 RadiusSlider（模式 0x18/0x19 默认 5.0f），线宽 = CurrentBrushThickness，
最后走 Shapes 库的 Disc 渲染。**结论：P5 的"笔刷混合算符"不在此方法**——混合逻辑在
BrushManager/EditPanelUI 的其它方法（待按 seeds 找 Apply/Paint 类方法名，另行排队）。

### 15.10 BrushManager.GetColorFromHeight —— ✅ 反编译逐字证实（05:31 产出）
`reports/decompiled/BrushManager_GetColorFromHeight.c`：高度 t = clamp((h-lo)/(hi-lo))，
lo/hi = BrushManager+0x34/0x38（笔刷高度滑条范围）；**三停靠点渐变**：t∈[0,0.5] 低色(+0x5c..0x64)→中色(+0x4c..0x54)、
t∈[0.5,1] 中色→高色(+0x3c..0x44)；每通道 `GammaToLinearSpace(lerp)`（**线性空间输出**），
alpha 通道不做 gamma。三色为 BrushManager 序列化字段（运行时可配），非编译期常量。

### 15.11 抬升因子的机器码复核 —— 部分证实，留一个待定项
对 addOneRange 函数体的常量池直读（VEX/REX/绝对寻址全模式扫描）：
- 函数开头加载三个不变量：xmm8=**0.8**、xmm9=**0.5**、xmm10=疑似静态字段（池值异常，疑由
  HeightMapGenerator$$.cctor 初始化的 static readonly float——round11 队列会给出）；
- 0.8 对应终点公式的 `width*0.8` 缩放；0.5 用途待 b__2/GetRange 伪代码；
- Ghidra 伪代码在抬升处解析出字面常量 **0.85**（`(fVar13 + 0.85) * h`），而加法是 xmm 寄存器间
  运算——0.85 可能来自另一个静态字段或池槽（当前重建版按字面读法取 0.85，**标注为待复核**；
  若 cctor 证明该字段实际值不同，再改一行）。
- **中间态声明**：模板 6867 + Azgaar 幂表 0.99 + 上述修正 ⇒ 三种子地图 **100% 陆地**（mapstats
  实测 134400/134400），海洋省系统无海可用 → selftest「存在海洋省」断言暂时失败（预期中间态，
  非回归）。裁决依赖 round11 队列的 GetBlobPower/GetLinePower 真值；**不人为调参**。

### 15.12 World.GenerateBaseMap —— ✅ 反编译逐字证实（05:58 产出）
`reports/decompiled/World_GenerateBaseMap.c`：
- 管线：清空缓存 → **`GenerateHeightMapFromJs(this)`** → `SetSeaElvationToZero` →
  `RankCellLegacy`（或 +0x184 标志走 `RankCellParallel`）→ 文化阶段。
- **文化阶段 = `CultureGenerator.Generate(world)` + `CultureGenerator.Expand(world)`**
  ——与省份/国家扩张同构的「播种 + 扩张」模式！另有一条从外部文化列表导入的旁路
  （GenerateBaseMap 的第 2/3 参，map 编辑器/存档用）。
- **第二阶段证据目标锁定**：`CultureGenerator$$Generate` / `CultureGenerator$$Expand`
  （含文化种子选址与扩张代价函数），排入 round12 队列。

### 15.13 World.GenerateHeightMapFromJs —— ✅ 反编译逐字证实（06:35 产出）：无回落
`reports/decompiled/World_GenerateHeightMapFromJs.c`：
- `EnsureHeightMapExternalInitialized(this)` → 取 HeightMapExternal 组件/字段 →
  非空则 **`HeightMapExternal__Generate(ext)` 后返回**；为空则 `Debug.LogError`（"失败：JsEnv 未初始化
  或 generateMapInJs 未绑定"）后**直接返回**。
- **不存在到 HeightMapGenerator 的回落路径**——高度图唯一来源是 Puerts JS 通道。
  旧叙事（HANDOVER §8/PROGRESS 未还原项④）的「失败回落内置 DSL」**作废**。
- 推论：模板 DSL 的真正解释器在 JS 侧；C# 的 HeightMapGenerator（含全部算子）要么被 JS 通过
  Puerts 绑定调用，要么是另一入口（编辑器？）所用。`HeightMapExternal$$Generate/Init`
  （round11 队列，Generate 跑中）将回答：JS 文件从哪加载、传什么参数（模板名/cell 数/种子）。

### 15.14 ★ 原版游戏 JS 逻辑包定位（main.js，497KB，加密）—— 本轮最大突破
UnityPy 枚举 resources.assets 的 TextAsset（26 个）：
- **`main` = 496,876 B**——Puerts 主 JS 模块；base64 解码后 **372,656 B、熵 8.0、16 字节对齐 = AES 加密**
  （与 BasicMap 存档同款特征）；**原版地图生成器的真正源码在 inside**（C# 侧无回落、无 JS 明文）。
- 其余模块：`init`/`init_il2cpp`/`csharp`/`promises`/`polyfill`/`nodepatch`/`events`/`timer`/`log`/`dispose`
  （Puerts 运行时胶水，明文）；`world.js`/`script.js` = hello-world 遗留测试脚本；
  `package` = Shapes 库的 package.json；**`1`/`2`/`4`/`8` = 四份 BasicMap 的 TextAsset 副本**
  （字节数与 StreamingAssets/BasicMap/*.save 完全一致）。
- 已提取到 `extracted_js/`（main.js 为密文；其余为明文胶水）。
- **解密路径**：SaveSystem 的静态常量字段已定位（type#764）——`c_SaveEncryptionKey`(#4653)、
  `c_BinarySaveContainerMagic`(#4650)、`c_BinarySaveContainerVersion`(#4651)、`c_BinarySaveIvSizeBytes`(#4652)、
  `SaveContainerHeaderV2`(#4649)；初值在 `SaveSystem$$.cctor`（0x1804c3220，已插 round12 队列首项）。
  2/4.save 前 16 字节相同 = CBC 固定 IV + 相同明文首块（magic+version）的格局已定。
- 一旦解密 main.js：**原版地图生成器（含真实算子实现、文化/宗教/战争等全部 JS 逻辑）直接到手**，
  高度图还原从「伪代码对照」升级为「源码对照」。

### 15.15 JS 通道全链路闭环 —— ✅ 反编译逐字证实（06:35-07:28 三连产出）
- `World.GenerateHeightMapFromJs`：EnsureHeightMapExternalInitialized → 组件非空 → `Generate()`；**无回落**（§15.13）。
- `HeightMapExternal.Generate`：调用 this+0x20 存储的**委托**（JS 侧注册），空则 LogError。
- `HeightMapExternal.Init`：`new Puerts.DefaultLoader()` → `new Puerts.JsEnv(loader, -1)` →
  **`jsEnv.ExecuteModule("main.mjs")`** → 绑定 JS 全局 **`generateMapInJs`**（'chunk' 为其宿主 chunk 标识）
  → 存入 this+0x20。
- 结论：**原版高度图 = 加密 main.js（main.mjs 模块）里的 JS 函数 generateMapInJs**——
  C# HeightMapGenerator 的算子实现是否被 JS 调用（Puerts 反向绑定）或 JS 另有实现，
  由解密后的 main.js 回答。SaveSystem$$.cctor（round11 重排后首项，07:36 起）给出 c_SaveEncryptionKey
  → 解密 main.js（372KB）→ 全部 JS 游戏逻辑源码到手。

### 15.16 ★ 存档加密完全破解 + 原版真值世界数据到手（07:59-08:52）
- **密钥（反编译逐字证实）**：`SaveSystem.EncryptString/DecryptString` =
  `Aes.Create()` + `Key = UTF8.GetBytes('o7E@:5UwTW_>XV9_8I?~eoux7E7?Kn~t')`（32 字节 = AES-256）+
  **`IV = new byte[16]`（全零）** + 默认 CBC/PKCS7 + 外层 Base64。
  密钥字面量槽位 DAT_182ef4498 解码与字段默认值（fieldDefaultValues 直读）交叉一致。
- **BasicMap 存档管线**：`.save` = Base64( AES( Base64( GZip( JSON ) ) ) )，IV 全零。
  1.save 解出 **CellData 模板**：CellCount=**19928**，含 SerializablePos（维诺图 cell 坐标）与
  21 个全零数组（Elevation/Precipitation/Flux/River/Temperature/Biom/Moisture/Score/Population/
  Haven/Harbor/Feature/Type/Culture/Burg/State/BattleScore/Province/DrawProvince/Confluence…）
  ——**序列化 schema 全量暴露**。四档 cell 数实测：**19928 / 30030 / 40050 / 79924**。
- **工坊存档（官渡之战，40050 cell）解密成功** → logs/workshop_guandu.json：
  - **真实高度场**：min=0 max=100 mean=23.1，**陆地(>20)=31.8%**；海格=0（SetSeaElvationToZero 实证）；
    直方图 60-69 有 6693 格的巨型平台（模板 Add/台地算子产物）。
  - **真实文化对象**（Azgaar 结构原样）：`{i, type: Nomadic/Naval/Generic/Hunting, expansionism: 0.9~4.1,
    code: 2 字母, Name: Norse/Luari/Portuzian/Vengrian/Romian/Angshire/Elladan/Astellian/Tallian/Shwazen,
    center: cell 索引, Base, Shield: heater/french/renaissance/horsehead/roman/wedged/boeotian/spanish/swiss}`，
    共 10 文化 + 1 占位；cell→Culture 归属数组全量。
  - 1008 省 / 36 国 / 战争与外交数据结构（StateData/ArmyData/DiplomacyData/VassalData 的序列化 schema）。
- **真值高度场渲染**：tests/origin_40050_heightmap.png（PIL 最近邻栅格化）——大中央大陆 + 70+ 高地 +
  东部群岛，与用户截图形态一致。
- **main.js（497KB 游戏逻辑 JS）仍为密文**：SaveSystem 密钥不适用于它；解密逻辑在
  `Puerts.DefaultLoader.ReadFile`（本构建被改，函数体 ~0x1000 字节、6 次 String.Concat、尾部两调
  0x180A45CB0 助手）——ReadFile/PathToUse/FileExists/IsESM 已插 round12 队列。

### 15.17 ReadBinarySaveContainerHeader —— ✅ 反编译逐字证实（09:18 产出）：双格式并存
`[magic("NFW_SAVE_BIN", ASCII.GetBytes) = s_BinarySaveContainerMagicBytes][version(int)==1][ivSize(int)≥1][IV][数据]`
——V2 二进制容器格式（WriteBinarySaveContainer 写出）；version≠1 抛
NotSupportedException("Unsupported binary save container version")；ivSize<1 抛 InvalidDataException。
**而所有实测 .save/工坊存档走 EncryptString 格式**（Base64(AES(零IV, Base64(GZip(JSON))))，无容器头）——
两格式同钥并存。main.js 两者皆不匹配 → DefaultLoader.ReadFile 有自己的变换（round12 揭示）。

### 15.18 HeightMapGenerator.GenerateHeightMap —— ✅ 反编译逐字证实（10:11 产出）
`reports/decompiled/HeightMapGenerator_GenerateHeightMap.c`：函数体仅一行
**`GenerateFromTemplate(this, 3, 0)`** —— HANDOVER 旧记录的这一句证实；第三参 0 真实存在
（GenerateFromTemplate 伪代码未用它，Ghidra 在彼处吞参）。调用方 = JS 侧（Puerts 绑定）待 main.js 解密确认。

### 15.19 MathUtility.Lim —— ✅ 反编译逐字证实（11:17 产出）
`Lim(v) = Math.Min(Math.Max(v, 0), 100.0)` —— **双边钳制 0..100**（0x4059000000000000 = 100.0 双精度；
早前伪代码里的第二参 0 是 Ghidra 伪影）。**重建版 `_lim`（clampf 0..100）本来就正确，零修改。**
高度不会超过 100；官渡存档直方图的"100-109"桶全部是 100。

### 15.20 HeightMapGenerator$$.cctor —— ✅ 幂表逐字证实（10:37 产出）：与 Azgaar 逐字一致
`reports/decompiled/HeightMapGenerator_cctor.c`：两张 13 档 Dictionary 立即数表全量提取——
- **blobPowerMap**：1000:0.93 / 2000:0.95 / 5000:0.97 / **10000:0.91** / 20000:0.99 / 30000:0.991 /
  40000:0.993 / 50000:0.994 / 60000:0.995 / 70000:0.9955 / 80000:0.996 / 90000:0.9964 / 100000:0.9973
  ——与 Azgaar 表**唯一差异 = 10000 档 0.91（Azgaar 0.98，游戏刻意改陡）**；
- **linePowerMap**：0.75/0.77/0.79/0.81/0.82/0.83/0.84/0.86/0.87/0.88/0.91/0.92/0.93 —— 与 Azgaar **逐字一致**。
- 重建版常量表**无需修改**（本就与原版一致）。
- **待裁决**：World.GenerateHeightMap 设定期望 cell 数 10000/20000/30000/40000，而实际图为
  19928/30030/40050/79924——GetBlobPower 用哪个查表决定 tier1 = 0.91 还是 0.99
  （GetBlobPower 伪代码跑中）。**衰减公式 per-step pow 与实际地图 31.8% 陆地的矛盾仍未解**
  ——最终裁决在加密 main.js（round12 Puerts.ReadFile）。

### 15.21 GetBlobPower / GetLinePower —— ✅ 反编译逐字证实（12:00 产出）：JS 编排实锤
- `GetBlobPower(cells)` = `blobPowerMap.TryGetValue(cells) ? value : 0.98`——**字典精确匹配，无插值**，
  缺省 0.98（0x3f7ae148）。GetLinePower 同构（缺省待查，表值已全量提取见 §15.20）。
- **全 .text 反查：两函数零 C# 调用者** → 只被 JS 经 Puerts 绑定调用 ⇒ **JS（main.js）是高度图生成的
  编排者**，C# HeightMapGenerator = 被 JS 调用的算子库。blobPower/linePower 字段由 JS 赋值。
- 查表键 = 期望 cell 数（10000/20000/30000/40000）时：tier1 = **0.91**、tier2 = 0.99、tier4 = 0.993；
  键 = 实际数（19928/40050…）时全部落缺省 0.98。两者之别待 main.js。
- **未解之谜收窄为一**：per-step `pow(change, 0.99)` 衰减模型（Azgaar 同构）在本引擎网格上产出
  98-100% 陆地，而原版同表值产出 ~32-45% —— 差异只能在 powf 实参细节或 JS 侧编排，
  main.js 解密（round12 Puerts.ReadFile → Decrypt）后终审。

### 15.22 GetLinePower —— ✅ 反编译逐字证实（12:42 产出）
与 GetBlobPower 同构：`linePowerMap.TryGetValue(cells)` 精确匹配，缺省 **0.81**（0x3f4f5c29）。
两幂表 getter 均零 C# 调用者（JS 经 Puerts 调用）。表值全量见 §15.20。

### 15.23 HeightMapGenerator.Rand —— ✅ 反编译逐字证实（13:17 产出）
`Rand(min,max) = UnityEngine.Random.Range(min,max)` 直通包装。队列继续：GetPointInRange →
ModifyCells → Modify → mask → Range/Strait/Trough/Pit 内部（预计 ~17:30 完）→ round12
（Puerts_ReadFile = main.js 解密之钥 → CultureGenerator → 宗教归属 → 领袖）。

### 15.24 GetPointInRange —— ✅ 反编译逐字证实（13:51 产出）
`GetPointInRange(s, length)`：Split('-') → **float.TryParse** 两端 /100 →
`Random.Range(mn*length, mx*length)` **浮点连续均匀**；单值段 mx=mn；空/非法 LogError+0（Length==1 合法）。
重建版 `_point` 整数版在网格用途上等价（_slot 取整吸收），模板输入全整数无行为差。零修改。

### 15.25 GetPointInRange/ModifyCells —— ✅ 反编译逐字证实（13:51/14:27 产出）
- GetPointInRange（§15.24）：浮点均匀，与整数版网格等价，零修改。
- ModifyCells：范围解析 **Single.Parse 浮点**（"land"→mn=20/mx=100/isLand=true；缺省→0..100）；
  三种模式 lambda（按字符串 Equals 分派）；**Parallel.For 多线程**（批 = max(1, cells/(cores×4))）。
  **每格数学在 `<>c__DisplayClass27_0$$<ModifyCells>b__0` lambda**（不在当前队列——round13 待办，
  决定 Add/Multiply/Power 对 land/all 的精确公式）。

### 15.26 mask —— ✅ 反编译逐字证实（16:19 产出）：与重建版数学一致
`mask(power)`：power=**Int32.Parse**（0→fr=1；负值→distance 翻转）；nx=(2x)/graphWidth-1、
ny 同；distance=(1-ny²)(1-nx²)；写回 `Lim(((fr-1)*h + h*distance)/fr, 0)` —— 与重建版 `_mask`
**逐式一致**（坐标源=维诺图 site vs 网格格点为已知拓扑差异）。唯一差异：原版 Int32.Parse
（分数 mask 非法），模板全整数无行为差。**零修改。**

### 15.27 addRange.g__GetRange|1 —— ✅ 反编译逐字证实（17:00 产出）：与 _greedy_ridge 等价
山脊游走：候选 = 当前沿海邻居；距离 = `csDelaunay.Vector2f.DistanceSquare(site[cur], site[nbr])`
（欧氏平方）；**`Random.value > 0.85 → dist *= 0.5`**（15% 减半 = randomness 0.15）；
贪心取最小；used 标记推进。——重建版 `_greedy_ridge` 逐式等价（网格 dx²+dy² 为拓扑等价物），零修改。

### 15.28 addRange.b__2 —— ✅ 反编译逐字证实（17:38 产出）
`b__2(cell) = heights[cell]` 键选择器 → addRange 突刺的 LINQ = **邻居按高程取最小**
（MinBy 语义）→ 突刺方向 = 走向最低邻 ✓ 重建版结构吻合；写回具体值仍被 Ghidra 吞参，
保留 Azgaar 式 `(cur*2+best)/3` 并标注为近似（差异影响局部细节，不影响走向）。

### 15.29 addStrait —— ✅ 反编译大部分证实（18:18 产出）
- cap = min(GetNumberInRange(count), maxW/3)；cap<1 → P(graphWidth) 恒真 → 直接返回（等效"不画"）；
- **exp = 0.9 − remaining×(0.1/cap)** 与重建版同式；山脊 = `<addStrait>g__GetRange|17_0`（round11 下一项）；
- 两处微差（起点带 [0.4,0.7] vs 我方 [0.3,0.7]；终点抖动 +Random.value vs +rand*0.2w）：
  因 vertical/horizontal 分支与 +0x28/+0x2c 字段映射未钉死，**不盲改**——待 GetRange|17_0 与
  字段核实后一并处理（影响仅为海峡起点的带状位置）。

### 15.30 ★ SerializedArmies 实例结构 —— ✅ 存档解密实测（30 个工坊存档全部有军队）
Army 实体 22 字段（欧洲1.1.1，8298 军队实例）：
armyID/isElite/isMannulCreated/**currentState("Idle"…状态机字符串)**/**currentCell+preCell(格级移动轨迹)**/
targetProvinceObject(-1=无，或目标省)/homeProvince/**state(归属国家)**/isEmergencyCall/
**armyCount(float 兵力，200 起步，可见 190.19 等损耗值与 -1 毁灭)**/
**armyType(BorderGuard 94.5% 边防/FieldArmy 野战/Garrison 驻防)**/armyOrder("AttackEnemyProvince")/
baseCombatEfficiency/foundingTime(游戏年)**participatedCampaigns[campaignId…]联动战役**/
enemyArmyDestroyedCount/conqueredProvincesInfo。
ArmyData 顶层：ObjectCount=200（常量，或每国批次），SerializedArmies=实例数组。
 CampaignData.Campaigns 与 participatedCampaigns 联动 = 军役记录。

### 15.31 addPit / addOnePit / addTrough / addOneTrough / Trough_GetRange —— ✅ 反编译逐字证实（round11 收尾批，23:10 导出）
- **addPit / addTrough（编排层）**：`for (i = GetNumberInRange(count字符串); i > 0; i--) addOne*()`
  ——循环次数 = 区间随机（重建 `_num` 已支持 "a-b" 区间解析 ✓）；
- **addOnePit（★A）**：起点循环 `GetPointInRange×2 → GetCellIndex`，重抽条件
  `heights[start] < 20 && tries < 50`（**起点须为陆地 ≥20** ✓ 重建一致）；
  BFS 洪水：出队 → `power = FUN_1802d1a20() × (rand*0.2+0.9)`，`power < 1 return`；
  每邻 `heights[n] = Lim(h_n − power × (rand*0.2+0.9), 0)`，标记 visited 后入队。
  **FUN_1802d1a20 = powf(hh, blobPower)（Ghidra 吞 xmm/寄存器实参）**——判定依据：
  addOneRange（上轮 ★A 已证衰减 `pow(hh,linePower)−1`）在完全相同位置渲染为
  同一 `FUN_1802d1a20() − 1.0`；故重建 pit 的 `hh = pow(hh,blob_power)×jitter` **已正确**；
- **addOneTrough（★A，本轮唯一代码修正）**：下挖
  `heights[c] = Lim(h − (rand + 0.85) × depth, 0)` —— **因子域 [0.85,1.85]**，
  与 addOneRange 抬升同族；重建旧值 `rand*0.3+0.85` 有误，已修
  （heightmap_dsl.gd `_add_trough`，备份 backups/heightmap_dsl.gd.pre-round11b）；
  深度衰减 `depth = FUN_1802d1a20() − 1`，`< 2` 截止（= pow(depth,linePower)−1，重建一致 ✓）；
  环扩张（BFS ring）+ visited 在入队时标记 ✓ 重建一致；
- **Trough_GetRange ≈ Range_GetRange（同构复制）**：唯一实质差异 = 突刺抖动阈值
  `Random.value > 0.8`（trough）vs `> 0.85`（range）；重建经调用点参数
  （trough 传 0.2 → `randf() > 0.8` ✓）已正确；strait GetRange 阈值同为 0.8 ✓；
- **支沟（spur）**：每 6 格 × 步数=挖深环数，读 h[cur]+h[next] 后写 h[next]
  （具体写值被吞参）——保留 `(cur*2+best)/3` 近似，标注 ○ 待 main.js 终审；
- 遗留：addStrait 起点带 [0.4,0.7] 微差仍未钉死（见 15.29，不盲改）。

### 15.32 内置空白模板图（TextAsset 1/2/4/8）—— ✅ SaveSystem 密钥解密实测（23:12）
- resources.assets 的数字名 TextAsset（'1'=290KB '2'=404KB '4'=564KB '8'=1016KB，均带尾 NUL）
  = **内置 BasicMap 空白模板存档**，SaveSystem 密钥（AES-256-CBC/零IV/PKCS7）直接解密成功；
- 结构：顶层 12 键（WorldData/ArmyData/CampaignData/DiplomacyData/HistoryData/ProvinceData/
  StateData/TimeManagerData/VassalData/WarData + 2 个版本号），各值为**内嵌 JSON 字符串**；
- WorldData.CellData：21 个等长数组（BattleScore/Biom/Burg/CellCount/Confluence/Culture/
  DrawProvince/Elevation/Feature/FeatureCulster/Flux/Harbor/Haven/Moisture/Population/
  Precipitation/Province/River/Score/SerializablePos/State/Temperature/Type）；
- **Elevation 全零**（编辑器空白起点），但 **SerializablePos = 4 档标准维诺几何真值**
  （19928/30030/40050/79924 格，与工坊 1/2/4/8.save 同 CellCount）；BattleScore 默认 20.0
  （与 ModifyCells 特判值 20.0 一致）；
- 已落地：logs/builtin_map_{1,2,4,8}.json（全解析）。
- **main.js 密文实况（★A）**：文件 = Base64(X)，X=372,656 字节，mod16=0，熵 7.999（全加密）；
  SaveSystem 密钥 CBC-zeroIV/ECB/CBC-prefix 均不通（预期内，ReadFile 自带独立解密）；
  元数据字面量含 'LoadGameData.File.Decrypt'/'LoadGameData.Resources.Decrypt'/'.mjs'/'AES'。
  解密脚手架就绪：tools/decrypt_mainjs.py。

### 15.33 HeightMapGenerator.ModifyCells 主体 —— ✅ 反编译证实（23:05 导出）
- 签名：ModifyCells(cells列表, mode字符串, int参数, op字符串)；
- **op 字符串协议**："A-B"（Split('-') → 两个 float 进闭包 +0x30/+0x34）；
  两个内置常量分支：op=="<常量1>" → (20.0,100.0,flag=1)；op=="<常量2>" → (0.0,100.0,flag=0)；
  "A-B" 解析后若 A==20.0 → flag=1（20.0 = BattleScore 默认值呼应）；
- **mode 三选一**（比较 3 个字符串常量）→ 各建一个委托（闭包+函数指针）→
  Parallel.For(0, cells.Count, MaxDegreeOfParallelism=核数) 批量执行；
  chunk = max(1, count/(核数*4))；委托体 = b__0/b__1（round12 队列项，公式待产出）；
- 闭包布局：+0x10 flag(u1) +0x14 int参数 +0x18 chunk +0x20 cells +0x28 heights
  (World.Instance+0x148 → +0x18) +0x30 A +0x34 B +0x38 委托。

### 15.34 ★ main.js 解密入口定位 —— CustomLoader（23:59，元数据+ReadFile 反编译双证据）
- **Puerts.DefaultLoader.ReadFile（dec12_Puerts_ReadFile.c）= 原版无修改**：
  PathToUse → Resources.Load → TextAsset.text 原样返回。**解密不在此**；
- IL2CPP 元数据（logs/il2cpp_meta.evidence.json，npx rea inspect-il2cpp-metadata 解析）：
  - **type 439 `CustomLoader`（游戏类，无命名空间，6 方法）**：
    FileExists/ReadFile/GetResourcePath/**DecryptString**/.ctor/.cctor ← **main.js 解密入口**；
  - type 440 `CombinedLoader`（.ctor/FileExists/ReadFile，加载器链）；
  - type 13650 `NodeModuleLoader`（Resolve/IsNodeBuiltin/OnBuiltinLoaded，node 后端）；
  - type 13651 `Puerts.TSLoader.TSLoader`（ReadFile/GetBytes/IsESM/Resolve/UseRuntimeLoader）；
  - HeightMapExternal_Init 中 `Puerts_DefaultLoader___ctor` 实为 CustomLoader 基类构造误标
    （待 round13 反编译确认继承关系）；
- 附带：LoadGame 反序列化日志标签（LoadGame.Deserialize.World/Army/…）、
  'Encryption failed'/'Length of the data to decrypt is invalid.' 字面量在库；
- round13 定向队列已启动（tools/decompile_customloader.sh，WMI pid 48064）：
  CustomLoader cctor → DecryptString → ReadFile → GetResourcePath。

### 15.35 ★★★ main.js 解密成功（11-01 01:45）—— 原版地图生成器源码到手
- **CustomLoader.DecryptString（dec13 ★A 逐字）**：
  `FromBase64String → Aes.Create()（默认 CBC+PKCS7）→ Key=UTF8(literal) → IV=16字节(literal) →
  CryptoStream+StreamReader.ReadToEnd`；
- **密钥暴力穷举命中（tools/bruteforce_mainjs_key.py，933 keys × 471 ivs）**：
  - Key = `o7N@:5UwTW_>XV7_9E>~eoux7E7?Pn~t`（32B，SaveSystem 密钥 o7**E**@…XV**9**_8**I**? 的三字符变体）
  - IV  = `'0000000000000000'`（16 个 ASCII '0'，非零字节）
- 明文 372,646 字节 → **extracted_js/main.dec.js**（8054 行，未混淆仅压缩）；
- 开头 = **aleaPRNG（Baagøe MIT/BSD 衍生）——原版 JS 侧用 alea 确定性 PRNG**；
- `generateMapInJs` @ L7590（3 处提及）；其它地图函数：getHeightsFromImageData L2292、
  defineMapSize L2482、calculateMapCoordinates L2540、getHeightCost L4347/5544；
- 后续 = generateMapInJs 逐行终审 heightmap_dsl.gd。

### 15.36 ★★★ JS 权威源码终审（main.dec.js L1722-2320）—— 重建 DSL 差异清单（11-01 02:00）
权威 = JS HeightmapGenerator（游戏实际路径）；C# HeightMapGenerator 是并行副本（部分公式不同！）。
- **generate()**：`Math.random = aleaPRNG(seed)`（seed = World.randomInt = Random.Range(0,int.MaxValue)）；
  blob/linePower 按 cellsDesired 查表；模板串 = JS heightmapTemplates（**44 个**，非 C# cctor 5 个）；
- **World.GenerateHeightMap（★A）**：1/3 概率 isMultiContinent；cellsDesired ∈ {10000,20000,30000}
  等概率；**两个模板池**（list1 5 串 + list2 7 串，cellsDesired<60000 走池1，否则池2 + 强制
  cellsDesired=40000 + 非 multi）；noise 分支（Random.Range 参数被吞，触发条件待核）；
  **sizeFactor 默认 1.0**；SEA_LEVEL=0x14=20 ✓；centerPoint 初始默认构造（待核 SetMapCoordinate）；
- **getBlobPower（JS）**：标准 Azgaar 表，**10000: 0.985**（重建 0.98 → 改）；clickToGen 分支
  (0.83-0.93 随 sizeFactor)；multiContinent → rand*0.01+0.97；缺省 0.98；
- **getLinePower（JS）**：重建表一致 ✓；缺省 0.79（重建 0.81 → 改）；
- **addHill**：起点重抽 `heights[start]+h > 90` ✓；**change 为 Uint8Array（每次写入截断为整数）**；
  push 条件 change[c] > 1（截断后 ≥2）；**写回 = 全量 heights.map(lim(h+change[i]))（无 >4 阈值，
  C# 的 >4.0 阈值是副本差异）**；
- **addRange**：抬升 `h × (rand*0.3 + 0.85)`（**非 C# 的 rand+0.85**）；终点
  `endX = center + (rand*w*0.8 + w*0.1 − w/2) × sizeFactor`；dist 约束 w*sf/8 与 /3 ✓；
  getRange 游走阈值 0.85 ✓；spur 每 6 格 ✓ `(cur*2+min)/3` ✓ 步数=i（挖环数）✓；
- **addTrough**：挖掘 `h × (rand*0.3 + 0.85)`（**撤销今晚按 C# 的 rand+0.85 修正**）；阈值 0.8 ✓；
  dist 约束 /2 ✓；起点 heights≥20 ✓；
- **addStrait（JS）**：起点带 0.3w-0.7w ✓（15.29 的 C# [0.4,0.7] 是副本差异，**不采纳**）；
  exp 同式 ✓；**`heights[e] > 100 → 5` 重置**（重建已有 ✓）；getRange 无 visited（可打转，JS 原样）；
- **modify（Add/Multiply）**：isLand 锚 20 语义 ✓ 重建一致；**smooth/mask** ✓ 重建一致
  （smooth 邻域=维诺 cells.c，重建 3×3 方格近似保留）；**invert（P(count) 镜像）重建缺失 → 补**；
- **getPointInRange(range,len,center)（★A 非原版 Azgaar）**：
  `center + (len/2 − rand(min·len, max·len))` —— **镜像语义**（不对称 x/y 带会左右/上下翻转，
  影响模板布局，必须实现）；重建原式 rand(min·len,max·len) = getPointInRangeOrigin（未被调用）；
- **createTypedArray**：heights 初始全零 ✓；lim=clamp(0,100) ✓；getNumberInRange ✓ 与重建 _num 一致；
- **generateMapInJs 后半段（重大）**：JS 内还有 markFeatures/markupGridOcean/openNearSeaLakes/
  defineMapSize/calculateTemperatures/generatePrecipitation/Rivers.generate/Biomes.define，
  及 useJsStateProvinceCultureBurgGen 开关下的 Cultures/BurgsAndStates/Religions JS 生成；
  最终回写 C# CellData 全部 21 数组。**C# CultureGenerator 在 GenerateBaseMap 里 JS 高度图之后跑** ✓。

### 15.37 ★★★ 全陆中间态解除（11-01 02:10）—— main.js 修正实测
- **根因**（main.dec.js ★A 对照）：重建 hill 用了 C# 副本写法——浮点 change + 写回阈值 >4.0；
  JS 权威 = **Uint8 截断整数 change + 全量写回**。粗网格上采样亦是次因（见 mapgen 注记）。
- **DSL 修正**：hill Uint8 截断+全量写回；range 抬升/trough 挖掘 = rand×0.3+0.85（JS 权威，
  C# 的 rand+0.85 是副本差异）；blob[10000]=0.985；line 缺省 0.79；_point 改 JS 镜像语义
  （center + len/2 − rand(min·len,max·len)，不对称带翻转）；补 invert。
- **mapgen 修正**：模板切 JS 库 continents（C# Templates[3] 是编辑器列表变体，不在 JS 库）；
  弃用 20000-cell 粗网格上采样，全分辨率 480×280 直接生成（cellsDesired=20000 仅用于查表）。
- **实测**（tests/mainjs_verdict_test.gd + mapstats 三种子）：
  - verdict：480×280 + JS continents → **43.5% 陆地**（修正前 98-100%）；
  - mapstats：seed42/1337/2026 → land_ratio 0.539/0.524/0.522（原版 31.8~45.2%，同量级；
    残差 = 方格 8 邻 vs 维诺 hop 覆盖差异，维诺重构后可再逼近）；
  - 海洋省出现、海峡成型（截图验收：中央竖向海峡 = Strait 2 vertical 特征）；
- **测试基线（全绿）**：selftest 26/26、template_parse 9/9、heightmap_dsl 13/13、
  editor 58/58、culture_religion 23/23、culture_system 10/10（含孤岛回填）、
  economy 4/4、army 6/6、army_battle 6/6 —— **154/154**；
- culture_system 增「孤岛回填」（二次多源 BFS 跨海回填无归属陆地格；○ 中间实现，
  待 CultureGenerator$$Expand 真值）；
- 新资产：assets/origin/heightmap_templates_js.json（45 模板）；tests/mainjs_verdict_test.gd；
  备份：backups/heightmap_dsl.gd.pre-mainjs、heightmap_dsl.gd.pre-round11b。
