# FantasyMapSimulator Windows 重建版 · 还原验收清单

> 状态定义：✅已完成 ｜ 🟨部分实现 ｜ ⬜未实现 ｜ ❓证据不足待查
> 本文件是 Windows 阶段的正式验收依据。Android 移植在本清单核心项全部 ✅ 之前冻结。
> 最后更新：2026-10-30 第四轮（ExpandProvinces 由自研 BFS 改为原版多源 Dijkstra；FilterProvinceCells / EnsureProvinceConnectivity 按反编译实现）

## 0. 证据来源

- REA 6.8.0 + Ghidra 12.1.4 反编译管线（快照已缓存）
- 原版全量方法清单：`reports/dump-assembly-csharp.txt`（2,214 类型/17,739 方法含 RVA）与 `reports/methods-assembly-csharp.csv`
- 已反编译：`reports/decompiled/BurgsAndStateGenerator_Generate.c`（41KB）
- 反编译批次进行中：`logs/dec_CreateProvinces.json` 等 9 个（`tools/decompile_batch.sh`，每方法约 30 分钟）
- 原版官方文案：`source/fms-godot/assets/origin/zh_strings.json`（112 键）
- 原版资产：羊皮纸/山地/树木等 12 项（`tools/extract_visual_assets.py`）

## 1. 差距矩阵（对照原版功能）

### 1.1 地图生成

| 子项 | 状态 | 说明 / 证据 | 验收标准 |
|---|---|---|---|
| 管线结构（成省→扩省→海洋省→布城→成国→扩张→连通性） | 🟨 | 环节顺序与反编译的 `Generate()` 一致；但为自研实现。第四轮确认 `Generate()` 有分支：新建地图时才跑 成省→扩省，而 `SelectCapitalsFromProvinces→CreateStates` 在其之前无条件执行 | 与反编译逐环节对照无结构性缺失 |
| CreateProvinces 参数 | 🟨 | 已反编译：cell 逐个判定建省、4 字典属性回填、前缀命名；字典内容待定位 | cell 数据结构对齐 |
| ExpandProvinces 参数 | 🟨 | **第四轮已还原为原版多源 Dijkstra**：优先队列 + 种子代价 1.0 + `newCost=prev+10+extra/mult` + `cost==0\|\|new<old` 松弛 + `高度≥20 才写归属` + `extra` 下限 0；extra 六项中文化(-9/+100)、地形(20-h/缺表5000)、第4项(0.0) 已还原，biome/river/type 三项因重建版无对应数据恒为 0 | 逐常数对照（剩余三项待数据/反编译） |
| 省份种子机制 | 🟨 | 反编译确认：种子=抖动网格布点（`PlaceProvincialCapitalsByJitterGrid` 遍历 `World+0x320`，跳过三类 biome）→ 每点一省 → 各省以 center cell 扩张；真实抖动间距在 `World.EnsureProvinceBurgCellsReady`（未反编译），重建版沿用 step=11/±4 抖动 | 抖动网格参数对齐 |
| CreateStates/ExpandStates 分配规则 | 🟨 | **已确认**：国家数=首府 cell 数（非固定参数）；扩张=多源 Dijkstra（代价+10+地形惩罚/国乘数 1~6）；**第五轮补上"允许穿水、只在陆地写归属"**；重建版已实现 | 逐常数对照 |
| SelectCapitalsFromProvinces 首都挑选 | ✅ | **第五轮已还原**：`radius=sqrt(总格数/目标国数)` 泊松盘式最小间距采样，候选不足 `radius/=1.2` 重试、`<=1.0` 兜底；三种子均得到恰好 26 国（=目标数） | 国家分布均匀、数量等于目标 |
| EnsureProvinceConnectivity 算法 | 🟨 | **第四轮已精读并实现**：主分量=含 center 分量；非主分量触海→保留为离岛，不触海（内陆飞地）→逐 cell 改判给邻省。`FindBestNeighborProvince` 未反编译，用"邻接最多"近似 | 行为对齐（近似点已标注） |
| CreateSeaProvinces/ExpandSeaProvinces | ✅ | **第七轮已实现**：按连通海域建省（id 接陆地省之后、`is_sea=true`），`ExpandSeaProvinces` 用普通 FIFO 队列洪水填充 `height<20` 且无归属的海格；三种子海域省 49/70/38，未归属海格 **0**；点击海洋可打开海洋省面板 | 海域全覆盖、点击可查 |
| FilterProvinceCells/RecalculateProvinceState | ✅ | FilterProvinceCells = 清空各省 cell 集合后按 cell→province 字典重建（含并行加速），不改变归属 → 已实现 `_rebuild_province_cells()`；RecalculateProvinceState = 省内 cell 多数归属 → 已实现 | 行为对齐 |
| 随机数/种子体系 | ⬜ | 原版随机体系未知；重建版用 Godot RNG。需从反编译确认后建立同种子对照 | 相同种子下统计分布一致（陆地占比/省数/国数容差内） |
| 高度图生成 | 🟨 | **第八轮已拿到入口机制**：`HeightMapGenerator.GenerateHeightMap` = `GenerateFromTemplate(3)`；`GenerateFromTemplate` = 逐行解释"文本 DSL 模板"（每行一个算子，`addStep` 解析），模板正文在 `HeightmapTemplates..cctor`（待反编译）。重建版仍是 FastNoise 构图近似 | 落模板 DSL 后替换 |
| 生物群系（Biome） | 🟨 | **第八轮已实现数据层**：13 群系（名字/顺序/中文名取自原版 `BiomeResource.json` + `localization.csv`）、`gen.biome` 全图数组、群系视图、群系笔刷、温湿度偏移重算。**判定矩阵与配色是近似**（真值在 `Biomes..cctor` / `World.GenerateBaseMap`，反编译排队中） | 落真值矩阵与色表 |

### 1.2 地图表现

| 子项 | 状态 | 说明 | 验收标准 |
|---|---|---|---|
| 羊皮纸海面 + 坐标网格 | ✅ | 原版纹理提取复用 | 并排对照一致 |
| 国家配色 | 🟨 | 中饱和柔和色接近，但原版按文化包/状态生成（`RandomProvinceColors`/`State::UpdateColor`），规则未反编译 | 反编译后对齐 |
| 省界/国界/海岸线形态 | 🟨 | 格网直线段串接；原版为维诺图平滑多边形。**当前最大视觉差距** | 平滑后并排对照（同分辨率/缩放） |
| 城邑/首都标记 | 🟨 | 圆点+首都环；原版有城邑等级（SetAsCity/SetAsFortress 按钮证明类型存在）与不同图标 | 类型化图标 |
| 地形图标（山地/树木） | 🟨 | Sprite 渲染正确；密度/尺寸/聚合规则未对照原版 | 与原版截图对照密度分布 |
| 国家名标签避让/旋转/缩放 | ⬜ | 固定字号居中，无避让 | 原版行为（待截图对照） |
| 河流 | 🟨 | 下游行走简化版；原版河流有宽度渐变与水系网络 | 待反编译 Routes/WaterBody 相关方法 |
| 攻击箭头/战争宣称虚线 | ⬜ | 原版有（配置 DisplayAttackArrow、war-claim-target-icon 已提取） | 实现战争期间展示 |

### 1.3 国家与行省交互（核心验收）

| 子项 | 状态 | 说明 | 验收标准 |
|---|---|---|---|
| 左键选国家 → 国家信息面板 | ✅ | 名称可改/政体/首都/行省数/人口/自主外交/镜头跟随/行省列表 | 多国家×多位置点击测试全过 |
| Shift+左键/长按选行省 → 行省信息面板 | ✅ | 名称可改/所属/人口/城防/设首都/发动叛乱 | 含边界省、单省小国、海岛省 |
| 面板与真实数据联动 | ✅ | 全部来自 gen 数据结构，无虚构文本 | ui_test 断言 |
| 行省类型（城市/要塞/区域中心） | ✅ | **第六轮已实现**：行省面板三按钮 + `kind` 字段 + 类型影响人口/城防上限；类型的具体数值效果原版未反编译，标为重建版设定 | 按钮与字段对齐 |
| 国家战争子面板 | ✅ | **第六轮已实现**（简化版 WarManagerV2）：12 种战争类型 / 5 种战争目标（均用官方文案键）、战争分数、历时、战报；国家面板列出该国战争与最近战报 | 列出类型/目标/分数 |
| 国家历史子面板（分页） | ✅ | **第六轮已实现**：按国过滤 + 按半年分页（前半年/后半年，官方文案 HistoryHalfYearPrev/Next）+ 导出 | 按国过滤+分页 |
| 领袖/候选人系统 | 🟨 | **第六轮部分实现**：每国有 leader 字段（姓名/性别/年龄，面板显示）；生成规则为内置占位（原版 `StateLeaderGenerator` 未反编译）；候选人系统未实现 | 反编译后替换生成规则 |
| 关闭/切换/重开行为 | 🟨 | 关闭→重开正常；原版的打开优先级/互斥规则未验证 | 对照原版 |
| 相邻区分（国家/行省/海洋） | ✅ | cell→province→state 三层查询正确 | 含海洋点击 |

### 1.4 核心模拟

| 子项 | 状态 | 说明 | 验收标准 |
|---|---|---|---|
| 时间推进（年/月/日） | 🟨 | 年月心跳；原版有日级 tick（TimeManager 字段证据） | 反编译 TimeManager$$Update 后对齐 |
| 战争/吞并/领土变化 | 🟨 | 简化国力模型；原版 WarManagerV2 全家族（30+ 类）未反编译 | 反编译后逐条对齐 |
| 叛乱/分裂 | 🟨 | 行省叛乱可分裂建国；触发规则（minMonthSinceLast*Rebellion 等）在原版配置中有，重建版未接 | 接入规则参数 |
| 人物/家族/领袖 | ⬜ | 原版 CharacterManager/FamilyManager 系统存在 | 待反编译 |
| 文化/宗教影响 | ⬜ | 原版数据包结构已逆向，玩法影响未实现 | 接入文化包数据 |
| 外交/附庸/朝贡 | ⬜ | 配置开关证据（isEnableVassal 等）；系统未实现 | 待反编译 |

### 1.5 界面与菜单

| 子项 | 状态 | 说明 |
|---|---|---|
| 顶部事件横幅 | ✅ | 原版样式（米色纸条幅+黑框） |
| 底部工具栏（10 按钮） | ✅ | 文案与原版一致 |
| 历史记录面板 | ✅ | 全量列表；原版有分页/过滤 |
| 统计信息面板 | 🟨 | 国力排名；原版有多个统计类别（StatisticsCategory） |
| 菜单选项（规则参数） | 🟨 | 4 项规则；原版 50+ 配置项 |
| 地图外观 | 🟨 | 占位功能；原版有配色方案/显示开关（gameConfig 证据） |
| 地图编辑 | ✅ | **第八轮已还原四层编辑器**：高度/植被/行省/国家四层，笔刷半径·高度·衰减·5 种模式，拖动绘制，撤销/恢复（结构级），保存/读取，地图外观三视图 + 行政图透明度，全局指令面板（19 项，开关已接玩法）。剩余模式（区域/空白地/文化/宗教/家族/标签/图钉/地图尺寸）见 findings §9.1 |
| 设为壁纸 | 🟨 | 保存截图；原版是真正的壁纸模式（托盘/交互模式，官方说明原文） |
| 常见问题 | ✅ | 原版无此面板的对照物？（有 MapEditingInstructions → 应改为显示官方说明原文） |

### 1.6 数据与存档

| 子项 | 状态 | 说明 |
|---|---|---|
| 重建版存读档 | ✅ | JSON v1，往返一致（自检覆盖） |
| 存档内容完整性 | ✅ | **第六轮升级为 v2**：覆盖行省类型/人口/城防/区域字段、国家军队/战舰/领袖/文化/宗教/附庸、战争与战报、历史全量；并修正 v1 「把 province id 当 state id 重建归属」的缺陷 |
| 原版存档兼容 | ❓ | AES 容器未解（非本阶段目标） |
| 内容包加载（文化包 CSV/JSON） | ⬜ | 原版格式已逆向，重建版未接（当前用内置名字生成器） |

### 1.7 稳定性与回归

| 子项 | 状态 | 说明 |
|---|---|---|
| 逻辑自检 | ✅ | `tests/selftest.gd` 14 断言 ALL PASS（2026-10-30 第四轮，含省份连通/飞地/空省断言） |
| 交互测试脚本 | 🟨 | 第六轮在 `selftest.gd` 增加 5 条字段/存档/战争断言（19 断言）；独立 `ui_test.gd` 仍未建，面板行为靠 `-- panel=state|province` 截图核对 |
| 地图统计对照基线 | ✅ | `tests/mapstats.gd`：3 种子 × 18 指标（第四轮新增省份规模/连通分量/空省），基线 `user://mapstats-baseline.json`，重跑输出 Δ |
| 并排视觉对照 | ⬜ | 待建（原版截图 vs 重建版同缩放截图） |

## 2. 验收记录（每次修改后追加）

### 2026-10-30 基线
- 逻辑自检：ALL PASS（`logs/selftest.log`）
- 真实方法名核实：19/19 存在（RVA 已记录）
- 反编译批次启动：9 方法串行（后台）
- Android：已冻结，APK 保留为阶段试验产物

### 2026-10-30 第二轮（世界生成正确性与视觉还原）
| 修改 | 依据 | 测试结果 | 剩余差距 |
|---|---|---|---|
| **修复 generate() 幂等性缺陷**（provinces/states 数组跨次生成累积污染——游戏内"新世界"按钮必触发） | mapstats 基线工具发现跨种子数据污染（省份数 475→985→1546 异常） | 修复后 3 种子省份数 297~320、国家数恒 26、碎片=国家数（领土全连片） | 无（结构性缺陷已除） |
| 小岛清除（<14 cell 陆块并入海洋） | 原版海岸线干净、少碎岛（截图对照） | 微岛省消失 | 阈值为近似值，待反编译确认 |
| 板块噪声改**构图式大陆**（每种子 2~4 个确定性板块+门控细节噪声+角向轮廓扰动） | 原版地图特征：少量大块大陆+不规则海岸；旧实现会产生群岛世界或正圆形大陆 | 3 种子陆地占比稳定 0.378~0.379、省数 547~570、31~33 国、跨海碎片少量 | 参数为近似；待 HeightMapGenerator 反编译替换 |
| 同种子统计基线工具 | 用户要求建立可重复对照 | `tests/mapstats.gd`：3 种子 × 13 项指标，基线 `user://mapstats-baseline.json`，重跑自动对比输出 Δ | — |
| 地图可视化导出 | 人工检查需求 | `tests/mapdump.gd -- seed=N` 输出着色 PNG | — |
| 游戏内自动截图 | 并排对照需求 | `-- seed=42 shot=9` → `user://shots/auto_seed42.png`；样例存 `tests/visual_seed42_wobbled.png` | 与原版同条件并排对照待做（需原版同视角截图） |
| **边界平滑（两轮 Chaikin 角切割，闭环保持）** | 原版维诺图式平滑边界（验收清单 §1.2 最大视觉差距项） | 截图确认阶梯边→平滑六边形省份/海岸；视觉观感质变（见 visual_seed42_wobbled.png） | 原版为真维诺图矢量边；本次为格网+平滑近似 |
| 逻辑自检回归 | — | ALL PASS（`logs/selftest.log`） | — |

### 已知回退项
- 无（本轮全部改动通过回归）

### 2026-10-30 第三轮（9 方法反编译完成 → 国家扩张机制忠实化）

**反编译批次全部完成**：`CreateProvinces/ExpandProvinces/CreateStates/ExpandStates/EnsureProvinceConnectivity/FilterProvinceCells/RecalculateProvinceState/CreateSeaProvinces/ExpandSeaProvinces` 九个方法伪代码落盘 `reports/decompiled/`。

**已确认的原版机制**（详见 `reports/decompile-findings.md`）：
1. `CreateStates`：**国家数量非固定参数**，由被标记为首府的 cell 数决定（`+0x58` 标志）；每国带随机乘数 `Rn(rand*5+1)`（1~6，一位小数）；颜色来自 `ColorUtils.GetColors(count-1)`；存在 id=0 的默认态（与省份的 id=0 海洋省对应）。
2. `ExpandStates`：**多源 Dijkstra 前沿扩张**——`新代价 = 旧代价 + 10 + 地形惩罚/国乘数`，地形惩罚 = `20 - 高度值`（下限 0，查表失败罚 5000），松弛条件 `新代价 < 旧代价`（L926-934）。
3. `RecalculateProvinceState`：省份归属 = 省内 cell 多数归属。
4. `CreateProvinces`：从维诺图 cell 集合逐 cell 判定（`+0x66` 陆地标志），未归属 cell 建新省（名=前缀+序号，id 从 1 起），查 4 张字典回填属性。

**重建版已对应实现**（`scripts/mapgen.gd`）：
- 国家扩张从随机 BFS（0.92 概率，自定参数）改为**多源 Dijkstra**（GDScript 二叉堆，代价公式照抄反编译）；每国随机乘数 1~6 已实现。
- 省份归属改为 cell 多数制（`_recalculate_province_state`）。
- 效果：国界随地形成不规则走向（`tests/visual_seed42_dijkstra.png`），国家大小差异由乘数驱动（max 44~62 vs median 14）。
- 回归：mapstats 3 种子 land 0.378 稳定、31~33 国、碎片 56~57（跨海合并岛少量）；selftest ALL PASS。

**待办（下一轮）**：
- `ExpandProvinces` 的 Dijkstra 化（省份扩张同机制，常数同款 10/20/5000）；
- `ColorUtils.GetColors` 行为（原版调色板）与省名/国名前缀字符串常量的定位（DAT_182e94b40 等）；
- `EnsureProvinceConnectivity`/`FilterProvinceCells` 的 cell 清理规则对照；
- 行省类型 + 国家战争/历史子面板 + ui_test 交互回归；
- 与原版同条件并排对照。

### 2026-10-30 第四轮（ExpandProvinces 还原为原版多源 Dijkstra）

**1) 原版 ExpandProvinces 的真实机制**（证据：`reports/decompiled/BurgsAndStateGenerator_ExpandProvinces.c` 459 行，逐行见 `reports/decompile-findings.md` §6）

| 要素 | 原版实现 | 伪代码位置 |
|---|---|---|
| 队列 | 最小优先队列（与 ExpandStates 同一类型，`Add(item,priority)`/取最小，计数 `q+0x28`） | L102/L110/L188/L205 |
| 种子 | 每个**陆地省**（`+0x89!=0`、id≠0、`+0x88==0`、`+0x95!=0`）的 center cell；先写 `cell→province`，节点代价 0，**代价表置 1.0** | L118-L193 |
| 邻域 | `World.GetNeighborCells`（重建版用 4 邻域等价） | L218 |
| 已归属格 | 目标 cell 所属省若为陆地省 → **整段跳过、不覆盖**；另设"中心格不被抢"保护 | L239-L254 / L306 |
| 属性对比项 | 省文化字段 vs `cell→文化` 表：相同 **-9**，不同 **+100** | L324-L328 |
| 地形项 | `heightInt<20`（水）→0；否则取高度浮点 `h`：`h<=0`→**5000**，否则 `20-h`，下限 0 | L337-L371 |
| biome 项 | 同 biome→0，跨 biome→Biome 静态代价表值（本轮已反编译该局部函数） | L380-L382 |
| 第 4 项 | **字面常量 0.0**（ExpandStates 此处是 getHeightCost，省份没有） | L404 |
| river 项 | 无河→0；有河→`clamp(河宽表值/10, 20, 100)`（"亲水文化"分支反向：无河 100、有河 0）。**本轮已反编译** | L392 |
| type 项 | cell 类型 1→20/60、2→0/30、其它→0/100（按文化名分支）；type=-1 或普通文化 → 0。本轮已反编译 | L403 |
| 合成 | `extra = 文化+地形+biome+0.0+river+type`，**整体下限 0** | L404-L407 |
| 新代价 | `newCost = prevCost + 10.0 + extra / (prov+0x60)`；`prov+0x60` 由 Province 构造第 5 实参写入，两处构造都传 **1.0** ⇒ 除数恒 1.0 | L417 |
| 松弛 | `costTable[nb]==0.0 || newCost<costTable[nb]` | L418-L421 |
| 归属写入 | **仅当 `heightInt[nb]>=20`（陆地）**；水域只更新代价并入队，不写归属 ⇒ 允许跨水抢离岛 | L431-L441 |

与 ExpandStates 的异同（6 同 / 5 异）已逐条列在 `reports/decompile-findings.md` §6.2；关键差异：省份除数恒 1.0（国家是 1~6 随机乘数）、省份无 getHeightCost 项、省份无双实体快速路径。

**2) 省份种子来源（新确认）**：`PlaceProvincialCapitalsByJitterGrid` 按 `World+0x320`（抖动网格候选 cell 序列）逐 cell 建省中心对象并跳过三类 biome；`CreateProvinces` 再逐点建省 ⇒ **省份种子=抖动网格布点**，与重建版 `_seed_provinces()` 结构一致。`SelectCapitalsFromProvinces` 在扩张之后运行，决定哪些省成为国家首都省。

**3) 重建版改动**（`source/fms-godot/scripts/mapgen.gd`）

| 改动 | 内容 |
|---|---|
| 新增 `_expand_provinces_dijkstra()` | 二叉堆多源 Dijkstra，逐条照抄上表 12 项（含 `cost==0.0` 哨兵、种子代价 1.0、入队优先级 0、extra 下限 0、陆地才写归属、已归属不覆盖） |
| 新增 `_province_extra_cost()` 及 4 个分项函数 | 文化项恒 -9（重建版无文化数据，按原式代入默认值）、地形项 `20-高度分位`、biome/river/type 恒 0（无数据，标注为未还原项，不冒充原版参数） |
| 新增 `_rebuild_province_cells()` | 对应原版 FilterProvinceCells：由 cell→province 字典重建各省 cell 集合 |
| 新增 `_ensure_province_connectivity()` | 对应原版 EnsureProvinceConnectivity：触海碎片保留、内陆飞地并入邻接最多的邻省 |
| 删除旧 BFS | `_gen_provinces()` 内的自研 BFS 队列与逐省扩充逻辑移除，改为 seed→Dijkstra→重建→连通性→邻接→孤儿兜底 |
| `_seed_provinces()` 抽出 | 逻辑不变，新增 `center` 字段（=扩张种子）；`_absorb_orphan_cells()` 新增省份同步带 `center` |
| burg 位置 | 由"省内随机 cell"改为**省份中心 cell**（对应原版 center cell 语义） |
| `PROV_TRAVERSE_SEA := true` | 允许前沿穿越水域（原版 L431 语义），水域代价与入队照做、归属只在陆地写 |

**4) 修改前后地图统计**（`tests/mapstats.gd`，同一基线文件）

| 指标 | seed 42 前→后 | seed 1337 前→后 | seed 2026 前→后 |
|---|---|---|---|
| 省份数 | 553 → 549 | 547 → 541 | 570 → 568 |
| 省份最大/中位 cell | — → 200 / 92 | — → 186 / 96 | — → 197 / 90 |
| 省份连通分量总数 | — → 755（549 省中 104 省含离岛分量） | — → 724 | — → 781 |
| 空省份 / 未归属陆地格 | 0 → 0 | 0 → 0 | 0 → 0 |
| 国家数 | 31 → 28 | 33 → 31 | 33 → 32 |
| 国家最大省数 / 中位 | 62/14 → 85/18 | 44/14 → 52/15 | 64/14 → 41/18 |
| 国家跨省碎片数 | 57 → 38 | 56 → 36 | 56 → 39 |
| 陆地占比 | 0.378 → 0.378 | 0.378 → 0.378 | 0.379 → 0.379 |

变化解释：省份由"等距扩张的 BFS 块"变为"按代价竞争的 Dijkstra 域"，于是（a）省份规模差异变大（max 200 vs 之前更均匀）、（b）允许跨水后 104 个省带上离岛分量、（c）国家邻接图随之改变 → 国家数略降、单国更大、跨省碎片减少。
**注意**：river/mountain/tree 的计数变化（如 42 号 river 13→19）来自 **RNG 流位置改变**（burg 不再消耗随机数），不是算法缺陷。

**5) 测试结果**

- `tests/selftest.gd`：**14 断言 ALL PASS**（新增"无内陆飞地省分量""无空省份"两条硬约束；info 行输出 104/549 省含离岛分量）
- `tests/mapstats.gd`：3 种子全跑，`orphan_land_cells = 0`、`province_empty = 0`、`province_components` 与 `province_count` 的差值全部来自触海离岛分量（符合原版语义）
- 生成耗时：`generate` 1158 ms（改动前）→ 1124 ms（空闲时；Ghidra 反编译并行抢 CPU 时会到 2.2~3.4 s）。分项：Dijkstra 326 ms + 连通性 58 ms + 重建 16 ms
- 截图：`tests/visual_seed42_prov_dijkstra.png`（游戏内，seed=42）、`tests/part_prov_seed42.png`（省份着色，最终版）、`tests/part_state_seed42.png`（国家着色）、`tests/part_prov_seed42_landonly.png`（A/B 试验：仅陆地扩张版，用于对比"允许穿水"的影响）

**6) 仍然存在的差距**

1. `extra` 六项的公式**已全部反编译完毕**（见 `decompile-findings.md` §6.8）。在重建版现有数据模型下，biome/river/type 三项取 0 **正好等于原式在“缺该维度数据”时的取值**（同 biome→0、无河→0、普通 cell 类型→0），并非少算了惩罚。真正的缺口是缺 **biome 图 / cell 类型字段 / per-cell 河流** 这三类数据维度本身；补数据之前这三项没有可接入的量。
2. `floatDict_0x50`（地形项用的高度浮点表）**量纲未确认**：若原版是 0..1 归一化，则地形项≈19~20 近乎恒定；重建版按 0..20 高度分位（`elevation` × 40）实现，属近似。
3. 省份扩张除数按 `Province` 构造实参 1.0 处理；`prov+0x60` 与 ctor 第 5 实参的对应关系仍是**按偏移推断**。
4. 海洋省（CreateSeaProvinces / ExpandSeaProvinces）**未实现**：重建版海洋没有省份数据。
5. 抖动网格的真实间距/抖动幅度在 `World.EnsureProvinceBurgCellsReady` 中，未反编译；重建版仍用 step=11 / ±4。
6. `Generate()` 分支顺序差异（新建地图路径下 `SelectCapitalsFromProvinces→CreateStates` 在 成省/扩省 之前）未在重建版结构上对齐。
7. 工作区**没有版本控制**（非 git 仓库），本轮改动前已将 `mapgen.gd/selftest.gd` 备份到 `backups/*.prov-dijkstra`。

**已知回退项**：无（本轮全部改动通过 selftest / mapstats 回归）。

### 2026-10-30 第五轮（首都挑选原版化 + 国家扩张补上穿水）

**1) 原版机制**（证据：`reports/decompiled/BurgsAndStateGenerator_SelectCapitalsFromProvinces.c` 279 行，逐行解读见 `decompile-findings.md` §7.6）

| 要素 | 原版实现 |
|---|---|
| 间距半径 | `radius = sqrt(总 cell 数 / 目标国数)`（唯一参数，非硬编码） |
| 候选 | 陆地且尚未归属国家的 cell（重建版以"省中心"为代表，省即最小单位） |
| 接受条件 | 与所有已选点的**平方距离 > radius²** |
| 候选不足 | `radius /= 1.2` 重试；`radius <= 1.0` 直接兜底接受（1.2 与 1.0 均为反编译常量） |
| 截断 | 取前 `need` 个（原版对列表做 Take(need)） |
| 落地 | 选中对象置 `+0x58 = 1`，`CreateStates` 据此"一标记 cell 一国" |

**2) 第二处偏差：ExpandStates 也允许穿水**（本轮一并修正）
国家扩张的伪代码与省份同构——代价计算与入队对**所有**邻格都做，只有 `height>=20`（陆地）才写归属（L478 门）。重建版此前只走陆地，导致"无首都的陆块"永不被占领，才需要自创 `_fill_unassigned_provinces` 兜底建国。修正后三种子都恰好生成 26 国（= 目标数），兜底步骤退化为安全网。

**3) 重建版改动**（`source/fms-godot/scripts/mapgen.gd`）

| 改动 | 内容 |
|---|---|
| 新增 `_select_capital_provinces()` | 照抄半径采样：`sqrt(W*H/N)` → 泊松盘筛选 → `/1.2` 重试 → `<=1.0` 兜底；常数 `CAPITAL_RADIUS_SHRINK=1.2`、`CAPITAL_RADIUS_MIN=1.0` 均标注反编译行号 |
| 删除邻接度排序 | 原"按省份邻接度降序 + 互不相邻"的自研启发式整体移除 |
| 新增"首都省必属本国"硬保证 | 省份按 cell 多数改判后，首都省可能被邻国多数覆盖 → 出现"零省国家"。在原版里首都 cell 是预占且不被覆盖的（种子代价 0），这里把同一保证上提到省粒度（**重建版补充的不变式，已在代码注明**） |
| `_expand_states_dijkstra` 允许穿水 | 水格也更新代价并入队、地形惩罚取 0；只有陆地写 owner |

**4) 修改前后统计**（A = 仅首都改动；B = 再加上国家穿水）

| 指标 | 第四轮 | 第五轮 A | 第五轮 B |
|---|---|---|---|
| 国家数 42/1337/2026 | 28/31/32 | 26/27/26 | **26/26/26** |
| 国家跨省碎片 | 38/36/39 | 32/31/32 | 46/35/46 |
| 国家最大省数 | 85/52/41 | 48/61/61 | 42/46/49 |
| 国家中位省数 | 18/15/18 | 20/15/17 | 20/17/17 |
| 国家最小省数 | 8/6/6 | 1/1/1 | **4/6/5** |
| 省份数 / 孤儿格 / 空省 | 549/541/568、0、0 | 不变 | 不变 |

碎片上升是预期结果：国家现在可以把离岸岛屿纳入版图（原版行为），跨省邻接图随之断开。
最小国家从 1 个省回到 4~6 个省，说明"单省孤岛国家"不再靠兜底产生。

**5) 测试**
- `tests/selftest.gd`：**14 断言 ALL PASS**
- `tests/mapstats.gd`：3 种子全跑通过；**基线已按本轮结果重建**（`user://mapstats-baseline.json`）
- 截图：`tests/visual_seed42_capitals.png`（游戏内，26 国）、`tests/part_state_seed42_poisson.png`（仅首都改动）、`tests/part_state_seed42_sea.png`（最终版）

**6) 剩余差距（本轮新增/收敛）**
1. 首都采样用"省中心"代表 cell，原版是逐 cell 采样后建省——粒度不同，但空间分布特性一致。
2. `_fill_unassigned_provinces` 仍是重建版自创步骤（现仅作安全网，正常不触发）。
3. "首都省必属本国"是重建版补充的不变式，原版靠"首都 cell 预占"间接保证，两者在极端情形下可能不同。

### 2026-10-30 第六轮（转向"功能面还原"：国家/行省面板补齐 + 战争系统 + 存档 v2）

> 本轮起因：用户指出优先级跑偏——此前几轮都在补地图生成算法（不可见面），而原版最核心的**国家/行省自定义功能**没做。目标应是"先做到和原版一模一样"，再谈改动。
> 依据：原版官方简中文案 112 键（`assets/origin/zh_strings.json`）+ `StateInfoUI`(266 成员) / `ProvinceInfoUI`(124 成员) 字段清单。

**1) 国家信息面板（对照 StateInfoUI）**

| 原版功能 | 状态 | 说明 |
|---|---|---|
| 国名编辑 | ✅ | LineEdit，实时改地图标签 |
| 取色器 | ✅ | `ColorPickerButton`，改色即时重绘 |
| 政治体制 / 首都 / 行省数量 / 人口 | ✅ | 官方文案键 PoliticalSystem / Capital / ProvinceCount / Population |
| 领袖 Leader | 🟨 | 显示姓名（性别，年龄）；生成规则为占位（原版 StateLeaderGenerator 未反编译） |
| 文化 Culture / 宗教 Religion | 🟨 | 字段与显示已通；数据来自内置词库（原版走文化包） |
| 自主外交（允许/停止） | ✅ | 官方文案 AllowAutoDiplomacy / StopAutoDiplomacy |
| 军队 Army / 战舰数量 WarshipCount | ✅ | 显示 + 征兵/裁军按钮；军队参与战争分数计算 |
| 附庸国 Vassal / 缔结盟约 Alliance | ✅ | 显示附庸关系与盟友（附庸由附庸战争产生） |
| 战争子面板 | ✅ | 列出该国进行中的战争：攻/守、对手、**战争类型**（12 种官方文案）、**战争目标**、**战争分数**、历时、最近战报 |
| 历史子面板（分页） | ✅ | 按国过滤 + **前半年/后半年**翻页 + 导出到 `user://exports/` |
| 统计信息分类 | ✅ | 新增统计类别下拉：行省数量 / 人口 / 综合国力 / 军队 |

**2) 行省信息面板（对照 ProvinceInfoUI）**

| 原版功能 | 状态 | 说明 |
|---|---|---|
| 省名编辑 | ✅ | |
| 行省类型（城市/要塞/区域中心） | ✅ | 三按钮 + `kind` 字段；类型提升人口/城防/区域上限（数值效果为重建版设定，原版未反编译） |
| 当前人口 / 最大人口 + 自定义人口 | ✅ | 输入框 + 按钮（官方 btn_SetCustomPopulation） |
| 当前城市防御 / 最大城市防御 + 自定义防御 | ✅ | 官方 btn_SetCustomDefense |
| 区域当前人口 / 区域最大人口 / 区域防御 | ✅ | 官方 District* 字段 + btn_SetDistrictCustomPopulation/Defense |
| 设为首都 / 发动叛乱 | ✅ | 沿用并接入新数据模型 |

**3) 战争系统（简化版 WarManagerV2，`simulation.gd`）**
- 战争对象：`{id, a, d, type, goal, months, score, active, ceded[]}`；类型 12 种、目标 5 种，全部用官方文案键
- 月度推进：双方国力（人口 + 军队权重）对比 → 战争分数 ±100，优势方有概率战时占领边境省
- 结算：按目标执行 —— 吞并全境 / 割让 1~2 省 / 索取赔款 / 附庸化 / 白和；战报用官方文案（WarV2_SettledAnnex / AttackerWin / DefenderWin / Stalemate + 历时）
- 历史条目带 `state` 字段，供按国过滤

**4) 存档 v2（`SAVE_VERSION = 2`，向下兼容 v1）**
- 新增：行省 kind/人口/城防/区域/首都标记；国家军队/战舰/领袖/文化/宗教/附庸/盟友/颜色；战争与战报；历史全量
- **修正一个真实缺陷**：v1 读档时把 `cell_province` 的**行省 id 当成国家 id** 重建国家-行省归属，导致读档后国家领土张冠李戴。

**5) 测试**
- `tests/selftest.gd`：**19 断言 ALL PASS**（新增：战争系统有产出 30 场进行中/19 条战报、每国都有领袖/文化/宗教、每省都有类型/人口上限/城防上限、存读档保留行省类型/军队/战报）
- 面板截图：`tests/ui_state_panel.png`、`tests/ui_province_panel.png`（由 `-- panel=state|province` 参数复现）
- 地图基线未变（省份 549/541/568、国家 26/26/26）

**6) 剩余差距（功能面）**
1. 领袖生成、文化/宗教为**占位数据**（原版 StateLeaderGenerator / 文化包未接入）
2. 战争类型只用到 4 种（征服/解放/附庸/叛乱），内战 5 种、家族叛乱等未触发；战争目标缺"割让区域/夺取王位/迫改宗教"
3. 附庸/盟约只有状态显示，没有实际玩法效果（朝贡、参战义务）
4. 地图编辑器仍是"点击省份划给国家"，原版有高度图/行省笔刷与全局指令面板
5. 独立 `tests/ui_test.gd` 未建（当前用截图 + selftest 断言替代）

### 2026-10-30 第七轮（底层优先：海洋省份落地）

> 用户定的顺序：先把底层地图数据与生成算法做实（海洋省 → 高度图 → 抖动网格 → 群系），再做编辑器与玩法。

**1) 原版机制（证据齐全）**
- `CreateSeaProvinces`：遍历 `World+0x278` 的**海域集合**，为每个海域建一个 Province —— id 接在陆地省之后、`+0x89 = 0`（非陆地省标志）、名字为前缀+序号；**不写** cell→province 字典。
- `ExpandSeaProvinces`：**普通 FIFO 队列**（`FUN_1814ee2b0` 入队 / `FUN_1814edb90` 出队，计数 `+0x20`），从各省中心入队；出队后遍历邻格，满足「`cell→province == 0` 且 `height < 20`」才写归属并入队；节点代价字段固定写 `1.0f`，**没有任何代价公式、没有松弛、没有优先队列**。
- `World.DefineOceanGroup`（本轮新反编译）：按海域规模分三档命名（`≤1%` / `≤4%` / 其余），证实"海域是连通分组"而非逐格建省。

**2) 重建版实现**（`scripts/mapgen.gd`）
| 改动 | 内容 |
|---|---|
| 新增 `_gen_sea_provinces()` | 4 邻域连通分量 = 海域；每组建一省（center = 离质心最近的格）；FIFO 洪水填充所有 `is_land==0` 且无归属的格 |
| 省份结构新增 | `is_sea`、`sea_index`、`sea_tier`（0/1/2，阈值与 `DefineOceanGroup` 一致） |
| 邻接图 | 海洋省**不参与**陆地省邻接图（否则两块大陆会通过同一海域被串成一个"陆块"，破坏岛屿建国逻辑） |
| 国家归属 | `_recalculate_province_state` / `_fill_unassigned_provinces` 显式跳过海洋省（原版海洋省不属任何国家） |
| 渲染 | 海域省不画城邑与省名（原版海面无城邑） |
| UI | 点击海面 → 海洋省面板（省名/格数/所属=无/接壤陆地省数） |
| 数据 | `cell_province` 不再用 -1 表示海：**所有海格都有省归属**（地图数据完整性↑） |

**3) 统计（新增指标）**

| seed | 陆地省 | 海域省 | 未归属海格 | 陆地省最大/中位 | 国家数 | 国家碎片 |
|---|---|---|---|---|---|---|
| 42 | 549 | 49 | 0 | 200 / 92 | 26 | 46 |
| 1337 | 541 | 70 | 0 | 186 / 96 | 26 | 35 |
| 2026 | 568 | 38 | 0 | 197 / 90 | 26 | 46 |

陆地省规模、国家数与第五轮**完全一致**（改动是纯增量，无回归）。基线已按本轮重建。

**4) 测试**：`selftest` **20 断言 ALL PASS**（新增「存在海洋省」；原先的"所有省份归属国家"改为"所有**陆地**省份归属国家"）；`mapdump mode=prov` 会把海域按省着色便于核对（`tests/part_prov_seed42_sea_prov.png`）。

**5) 剩余差距**
1. 海域分档**名称字符串**未取到（`DAT_182eb81b8/182e86b60/182ef5518`），当前用"海域 N"编号名（原版为前缀+序号，语义等价但与本地化文案不同）。
2. 海洋省尚未参与任何玩法（原版有 SeaRoutes 海运航线、港口 `IsSeaCellQualifiedForPort`）。

### 2026-10-30 第八轮（四层地图编辑器 = 高度 / 植被 / 行省 / 国家）

> 规格来源：原版 `EditPanelUI`(type#409) / `BrushManager`(type#116) / `HeightmapTemplates`(type#453)
> 成员清单 + `localization.csv` 官方文案（`TerrainBrushDraw` / `TerrainProvinceEditBrush` /
> `TerrainStateEditBrush` / `EditHeightDescriptionTips` / `GlobalCommandTutorial` / `BrushMode*`）。
> 逐条对照见 `reports/decompile-findings.md` §9。

**1) 新增文件与关键改动**

| 文件 | 内容 |
|---|---|
| `scripts/map_editor.gd`（新，约 560 行） | 四层编辑器内核：笔刷几何（圆形 + 二次衰减）、5 种笔刷模式、逐笔记录 delta + `provinces/states` 深拷贝、撤销/恢复、放置大陆、擦除陆地、新建行省/国家、行省合并、国家合并、清空地图、保存/读取 |
| `scripts/mapgen.gd` | 新增群系系统（`biome`/`temperature`/`moisture` + 13 群系 + 资源表加载）；新增 `apply_height_changes` / `absorb_unassigned_sea` / `rebuild_after_province_edit`（丢空省+重编号+重建邻接+同步国家）/ `rebuild_after_state_edit` / `add_province_at` / `add_state` / `assign_provinces_to_state` / `clear_map` / `refresh_rivers_and_terrain` |
| `scripts/map_render.gd` | 三视图（政治图/高度图/植被图）+ 行政图透明度 + 笔刷预览圈 |
| `scripts/touch_camera.gd` | 编辑器绘制模式：左键=笔刷、右键/中键=平移、Shift+左键=选择、Ctrl+滚轮=调半径 |
| `scripts/main.gd` | 可滚动的编辑器浮坞（模式下拉 + 逐层控件 + 撤销/保存 + 全局指令）；全局指令面板（19 项）；`-- panel=editor|global`、`-- view=biome|height`、`-- editdemo=...` 调试入口 |
| `scripts/simulation.gd` | 规则扩充到 18 项（全部真实生效）；联盟缔结、孤立行省放弃、结束所有战争/联盟、清空历史、设置时间、重算区域；存档 v3 增 `elevation/is_land/biome` |
| `tests/editor_test.gd`（新） | 58 项编辑器断言 |

**2) 四层编辑器的实际行为**

- **高度层**：左键按"笔刷高度"改写 `gen.elevation`（真数据），落笔后重算 `is_land`；新绘制陆地按原版语义成为"未绘制"（`cell_province = -1`，官方 `EditHeightmapTutorial` 原文：新陆地无法直接占领），新海域自动并入最近海域省；"放置大陆"按衰减系数生成中心高四周低的地块；"擦除陆地"用最小值模式压到海平面以下。
- **植被层**：笔刷写入 `gen.biome`（13 群系，索引与名字来自原版数据文件）；"重算生态"按温度偏移 × 降水系数重算全图。
- **行省层**：笔刷把 cell 划给目标省（只作用于陆地格）；支持"放置行省"（新建 1 cell 省）、"合并所选行省"；每次落笔后重建 cell 集合、丢弃空省、重编号、重建邻接图并同步国家，不会留下孤儿/空省/错误归属。
- **国家层**：国家最小单位 = 行省（原版 `TerrainStateEditBrush`），笔刷触及的行省整块改归属；支持"新建国家""合并所选国家""擦除国家"（行省变无主）；首都省失守自动迁都，无省国家标记灭亡。
- **通用**：撤销/恢复以"笔刷 delta + 结构深拷贝"实现，因此连"整省沉没→省被删除→国家迁都"也能回滚。

**3) 测试**

- `tests/editor_test.gd`：**58 项检查 ALL PASS**（笔刷真的改数据 / 撤销恢复 / 结构不变量 / 合并不变量 / 存读档 / 整省沉没清理 / 清空地图）
- `tests/selftest.gd`：**26 断言 ALL PASS**（新增群系覆盖、海格群系=海洋、存档保留编辑过的高度与群系）
- `tests/mapstats.gd`：三种子跑通并重建基线；**生成结果与第七轮逐项一致**（陆地 50777/50859/50933，行省 598/611/606 含海域省 49/70/38，国家 26/26/26），新增 `biomes_land`=12 / `biome_sea_wrong`=0 / `undrawn_land_cells`=0
- 截图：`tests/ui_panel_editor.png`、`tests/ui_panel_global.png`、`tests/ui_editdemo_height.png`、`tests/ui_editdemo_biome.png`、`tests/ui_editdemo_province.png`、`tests/ui_editdemo_state.png`

**4) 与原版的差距（本轮新增）**

1. 编辑模式只做了 4 层 + 全局指令；区域/空白地/文化/宗教/家族/标签/图钉/地图尺寸 8 个模式未做（`EditPanelUI` 字段已列出，见 findings §9.1）。
2. 笔刷混合算符为近似（`BrushManager.DrawShapes` 尚未反编译）。
3. 群系判定矩阵与配色为近似（真值在 `Biomes..cctor` / `World.GenerateBaseMap`）。
4. 高度仍是 0..1 归一分位 + 自适应海平面（原版 0..100 固定 20 阈值），因此"高度 > 70 = 险要"的语义只在面板文案层面成立。
5. 地图仍是 cell 网格（非原版维诺图），所以"最小单位 = 1 个 voronoi cell"在当前实现中对应"1 个格"。

### 2026-10-30 第八轮补充（按原版实机截图对齐 UI + 国家面板功能化）

> 依据：用户在 16:25 手动运行原版并提供的 5 张实机截图（存于 `tests/origin_shots/`）。
> 规格逐条解读见 `decompile-findings.md` §11。

**1) 编辑器面板版式对齐（`main.gd`）**

| 原版实测 | 重建版改动 |
|---|---|
| 右上角窄面板，标题「地图编辑」 | 由宽 424 的浮坞改成宽 250 的窄面板，标题居中 |
| 模式下拉 12 项（编辑高度/编辑生态/编辑行省/编辑国家/编辑区域/编辑无人区/编辑文化/编辑宗教/编辑标签/编辑图片/编辑家族/全局指令） | 下拉项改为**官方 12 项同名同序**；已实现的 4 层 + 全局指令可用，其余点击时明确提示"该模式尚未还原"（不假装可用） |
| `<< Page 1 of 3 ›` 分页 | 实现为国家列表翻页（每页 6 个国名按钮，可直接选中目标国） |
| `随机国家` 蓝色按钮 | 同款蓝色按钮，随机选中目标国并切到编辑国家模式 |
| `笔刷半径` + 两位小数（3.50） | 数值改为两位小数；标签/滑杆/数值宽度按窄面板重排 |
| 2×2 `编辑/删除/绘制/擦除`（蓝/红/绿/橙） | 同色同序实现：编辑=打开选中行省/国家面板，删除=删国家/行省，绘制=正常笔刷，擦除=笔刷清成无主/海洋/海洋群系 |
| `提示 / 清空地图 / 关闭面板` | 同款三按钮；提示切换操作说明 |
| 进编辑时工具栏第 8 键变「继续游戏」 | 已实现：打开编辑自动暂停并把按钮改成「继续游戏」，点它恢复运行 |

**2) 国家信息面板版式与字段对齐（`main.gd` + `mapgen.gd`）**

- 由居中弹窗改为**左停靠满高面板**，国名灰色输入框 + 国家色条；
- 折叠区改为 `⚑ 基本信息 / ⚑ 国家行为 / 腐败度 / 附庸国 / 设置 / 输入军团数量 / 领土记录 / 战争 / 外交 / 历史记录`；
- 信息表按截图逐行补齐：国家 / 存在时间 / 皇帝 / 内阁首辅 / 户部尚书 / 兵部尚书 / 首都 /
  人口 / 人口上限 / 腐败度 / 国库 / 军队数量 / 战舰数量 / 行省数量 / 区域数量；
- 新增国家字段：`trait`（民族特征）、`founded_year`（建國年，用于"存在时间"）、`treasury`（国库）、
  `corruption`（腐败度，按区间显示 清廉/轻度/中度/严重）、`officials`（三名官员，占位姓名）；
  **全部确定性生成，不消耗随机数**，因此地图基线不变；
- **人口量纲校准**：单省人口 ×1000（40万~120万），全国合计进入百万级，与截图 406.8万 同量级。

**3) 国家行为按钮全部接真实后果（`simulation.gd` 新增 11 个动作）**

| 按钮 | 真实效果 |
|---|---|
| 扩张 | 复用月度和平蚕食逻辑，可能 +N 行省 |
| 煽动叛乱 | 在邻国随机行省扶植叛乱国，立刻开战（WarTypeRebel） |
| 内战 | 本国一半非首都行省分裂为新国家并开战（WarTypeCivilWar） |
| 吞并 | 国力 ≥ 3 倍时直接吞并最弱邻国 |
| 发起战争 | 对随机邻国宣战（国力强则目标为吞并全境） |
| 停战 | 结束本国全部进行中的战争 |
| 缔结盟约 / 退出同盟 | 与邻国建立/解除双向同盟，写历史（官方 AllianceFormedBetweenStates） |
| 收为附庸 / 独立 | 国力 ≥ 2 倍时把最弱邻国设为附庸；解除附庸关系 |
| 腐败度 降低/加深 | corruption ±10，面板文字随区间变化 |
| 放置军队 | `army += 输入值` |

**4) 地图观感对齐（`map_render.gd`）**
国界改暗红粗线（0.52,0.10,0.08 / 3.0px）、海岸加深、图经纬网改**虚线**、行省界线更淡。

**5) 回归**
- `selftest` **26 断言 ALL PASS**；`editor_test` **58 项 ALL PASS**；
- `mapstats` 三种子指标与上一版**逐项一致**（陆地 50777、行省 598、国家 26…），说明人口量纲与面板改动没有动生成管线；
- 截图：`tests/ui_panel_editor.png`（编辑器窄面板）、`tests/ui_state_panel.png`（国家面板）、`tests/visual_seed42_aligned.png`（暗红国界 + 虚线经纬网）。

### 2026-10-30 第八轮续（海平面固定 20/100 + 行省面板停靠化）

**1) 海平面与原版对齐（`mapgen.gd`）**

`World.GenerateHeightMap` 反编译实证 `world+0x178 = 0x14`（=20，0..100 制），且 `ExpandProvinces` 用
`height >= 20` 判陆地。据此把重建版从"自适应分位海平面（≈0.0035）"改为**固定 0.20**，做法是
**分段线性重标定**：海面以下映射到 0..0.20、海面以上映射到 0.20..1.0 —— 单调变换，**陆海集合完全不变**
（陆地 50777→50778，差 1 格来自小岛清除的水位钳制）。

带来的真实变化：
- 省份扩张的地形项 `(elevation - 海平面) × 40` 从"几乎恒 20（被 clamp）"变成真正随高度变化 →
  高地更难被吞并，省份规模分布出现差异（最大省 200 → 213）；
- 笔刷高度语义与原版一致：**0 = 海平面，100 = 最高，>70 为险要**；
- 群系温度递减项 `elevation × 0.55` 也真正生效（高山更冷）。

**2) 行省面板版式（`main.gd`）**
与国家面板统一为**左停靠满高 + 折叠区**：省名输入框（灰底居中）→ 所属国家 / 格数 →
折叠区 `行省类型 / 人口 / 城防 / 区域 / 操作`，按钮沿用官方文案（设为城市/要塞/区域中心、
自定义人口、自定义防御、设为首都、发动叛乱）。

**3) 视觉微调（`map_render.gd` / `mapgen.gd`）**
陆地不透明度 0.85→0.92、国家色饱和度 0.44~0.64 / 明度 0.68~0.88（更接近原版实机色彩）。

**4) 回归**
- `selftest` 26 断言 ALL PASS、`editor_test` 58 项 ALL PASS；
- `mapstats` 三种子跑通并**重建基线**（陆地 50778/50860/…、省 598/611、国 26/26）；
- 截图：`tests/visual_seed42_sea20.png`（海平面 20 后的地图）、`tests/ui_province_panel.png`。

**5) 新增反编译证据（findings §12）**
`HeightMapGenerator.addHill` = `for n in RandomUtils.GetNumberInRange(第1参): addOneHill(...)`，
说明模板 DSL 的参数是**字符串表达式**（支持 `1-4` 这类区间），与 Azgaar FMG 模板语法同构；
`HeightmapTemplates..cctor` 与 `addStep` 仍在反编译中（拿到后即可落地真实高度图）。

---

## 第九轮验收（2026-10-30 19:50）：高度图换成原版模板 DSL

**主题**：把 12 步生成管线里最后一块"自研近似"（高度图 FastNoise）换成原版的文本模板 DSL。

### 1) 模板正文：改从 `global-metadata.dat` 取，不再等 cctor

第八轮待办一直写"等 `HeightmapTemplates..cctor` 出模板正文"，这条路走错了。
IL2CPP 的字符串字面量不在 `GameAssembly.dll` 里（实测按 `hill/range/smooth` 扫长 ASCII 串命中 **0** 条），
而在 `FantasyMapSimulator_Data/il2cpp_data/Metadata/global-metadata.dat` 的字面量表里。

取到 **5 份模板正文 / 70 行**（literal 6866 / 6867 / 6868 / 6869 / 10442），
落盘 `source/fms-godot/assets/origin/heightmap_templates.json`，带 `_source`/`_evidence`/`_unverified` 标注。

算子全集 **9 个**：`Hill / Range / Trough / Strait / Pit / Mask / Multiply / Add / Smooth`。

### 2) 新增两个脚本 + 三个测试

| 文件 | 行数 | 内容 |
|---|---|---|
| `scripts/heightmap_template.gd` | 85 | 模板加载器（按 `GenerateFromTemplate` 的 Split/Trim/行数校验） |
| `scripts/heightmap_dsl.gd` | 543 | 9 算子解释器 + `getNumberInRange`/`getPointInRange`/`findSlot` |
| `tests/template_parse.gd` | 67 | 9 项断言 |
| `tests/heightmap_dsl_test.gd` | 132 | 13 项断言（含 Smooth 手算定点） |
| `tests/heightmap_templates_dump.gd` | 48 | 5 份模板渲染 PNG 供视觉比对 |

### 3) `mapgen._gen_elevation` 换血

按原版 **2 万 cell** 跑 DSL → 最近邻上采样到 480×280 → `/100`，海平面固定 0.20。
旧 FastNoise 版保留为 `_gen_elevation_legacy_fastnoise()`（未被调用）。
停用自研 `_remove_small_islands`（`REMOVE_SMALL_ISLANDS=false`，代码保留）——原版无此步骤。

### 4) 连带修掉两个缺陷

- **河流断流**：整数高度场有大量平台，"最低邻格"下坡走不动 → 河流归零。改为**等高允许平走一格**，
  实测恢复到 18/14/21 条。
- **省份 center 失效**：笔刷把某省的 center 格划走后 center 仍指向旧格。`_rebuild_province_cells()`
  增加按质心修复。

### 5) 回归结果（全部实测）

- `selftest` **26** 断言 ALL PASS；`editor_test` **58** 项 ALL PASS；
- `template_parse` **9** 项 ALL PASS；`heightmap_dsl_test` **13** 项 ALL PASS；
- `mapstats` 删旧基线（备份为 `mapstats-baseline.pre-dsl.json`）重建，**二次运行无 Δ**；
- 新基线：陆地 **76049 / 62910 / 77794**（37.8% → 56.6% / 46.8% / 57.9%），
  省 960 / 753 / 954，国 26 / 26 / 26，河流 18 / 14 / 21，孤儿格 0、空省 0、未绘制 0。

> 数字变动是"高度图换算法"的预期结果，判定标准是**二次运行无 Δ**，不是与旧基线逐项相同。

### 6) 仍未证明（不写入"已还原"）

**`TEMPLATE_INDEX = 3` 对应哪份正文未证。** 字面量堆按字典序排序，`order_seen` ≠ 列表插入顺序。
当前取"字面量顺序第 4 份"属于**半个猜测**，需 `HeightmapTemplates..cctor`（RVA 0x39b350）证明。
曾尝试扫 cctor 机器码的 `mov imm32` 找 5 个 literal index 立即数，**无命中**（IL2CPP 走 usage 间接表）。

**验收结论**：高度图算法已换成原版 DSL（✅），但"用的是哪份模板"仍是 🟨 待证。

## 第十轮验收（2026-10-31 00:11-01:30）：模板列表插入顺序证实 + 新基线

**主题**：钉死第九轮遗留的唯一未证点——`GenerateFromTemplate(this, 3, 0)` 的 `3` 对应哪份模板正文。
**结论**：`Templates[3]` = literal **6867**（旧 order_seen=1，游戏自创模板，机器码观测名 "Continents"）。
此前使用的 6869（Azgaar highIsland）实为 `Templates[1]`。**证据链见 `reports/decompile-findings.md` §14。**

### 1) 证据（机器码直接观测，非推断）

- v29 字符串 usage 槽位编码 `(5<<29)|(idx<<1)` 被 8 个槽位 + 3 组名字-正文语义匹配锁定；
- cctor 内 5 个等距 0x69 构造块 = 5 次 `Add`，块序即列表序：
  `[Volcano/6868, High Island/6869, Continents/6866, Continents/6867, Continents/10442]`；
- 8 个槽位在全 .text 仅被 cctor 引用（独占性）；
- `GenerateFromTemplate` 反编译证实 `get_Item(param_2)` = IReadOnlyList **列表下标**（"字典键"猜测作废）；
- 工具：`tools/scan_template_order.py`（PE+元数据纯解析，不依赖 Ghidra），重排：`tools/reorder_templates.py`。

### 2) 代码与数据变更

| 文件 | 变更 |
|---|---|
| `assets/origin/heightmap_templates.json` | 按 Add 顺序重排，`order_seen` ≡ 原版列表下标；新增 `name` 字段与 `_verified` 证据注记；删除作废的 `_unverified` |
| `scripts/mapgen.gd` | `TEMPLATE_INDEX=3` 注释从 ⚠️未验证 改为 ✅已证实（常量值不变，语义已变） |
| `tests/template_parse.gd` | 行数表 {0:8, 1:14, 2:15, 3:20, 4:13} + 顺序注释 |
| `tests/heightmap_dsl_test.gd` | 模板#3 端到端注释（现在跑 6867，20 步） |

### 3) 回归结果（全部实测 2026-10-31 00:35-00:40）

| 验证项 | 结果 |
|---|---|
| `tests/template_parse.gd` | 9 通过 0 失败 |
| `tests/heightmap_dsl_test.gd` | 13 通过 0 失败（模板#3=6867 端到端跑通，未知算子 0） |
| `tests/selftest.gd` | ALL PASS（26 断言） |
| `tests/editor_test.gd` | 58 项失败 0 |
| `tests/mapstats.gd` 重建 | 删旧基线后连跑两次**无 Δ**（确定性成立）；旧基线备份 `mapstats-baseline.pre-cctor-fix.json` |
| 游戏内截图 | `user://shots/auto_seed42.png`：26 国、两大陆+海峡形态成型 |

### 4) 新基线（模板 6867，480×280）

| seed | 陆地格 | 陆地占比 | 行省(含海域) | 国家 | 河流 | 群系种类 | 孤儿/空省/未绘制 |
|---|---|---|---|---|---|---|---|
| 42 | 132179 | **0.983** | 1154 (+60) | 26 | 62 | 12 | 0/0/0 |
| 1337 | 122168 | **0.909** | 1195 (+142) | 26 | 44 | 12 | 0/0/0 |
| 2026 | 127559 | **0.949** | 1170 (+96) | 26 | 55 | 12 | 0/0/0 |

### 5) 遗留与警告

- **陆地占比 90.9%~98.3% 与原版截图（约 45~55%）明显不符**：模板选择已对（结构=多大陆+海峡+小岛），
  剩余误差在**算子参数/语义**（Hill/Range/Trough/Strait/Mask 只经 Azgaar 同构交叉印证，smooth 逐字核对过）。
  待办 #2 的伪代码（addStep/addOneHill/addOneRange/GetNumberInRange）到位后逐条校算子。
  **在核对完成前，不得把 97.7% 陆地说成"原版行为"。**
- 第九轮"视觉比对选 6869"的结论**作废并修正**：有偏算子语义下错误模板碰巧更像原版。
- **Ghidra 第二确认已完成（00:49 产出）**：`reports/decompiled/HeightmapTemplates_cctor.c`
  与机器码推导逐条一致（Add 顺序/名字槽配对/ICF 折叠 ctor），并新增 Probability=整数权重
  3/19/16/16/16 的事实。结论定案。

## 第十一轮验收（2026-10-31）：算子证据链 + JS 通道 + 存档破解 + 文化数据层

### 1) 逐字证实清单（全部有伪代码文件）
addStep 分发（9 算子参数位）/ addOneHill（>4.0 写回、浮点衰减、90 重试 50 次）/
addOneRange（抬升因子域 [0.85,1.85]、曼哈顿距离窗 [w/8,w/3]、终点公式）/ GetNumberInRange
（floor+概率进位、int.Parse 闭区间）/ MathUtility.Lim（= clamp(v,0,100) 双边）/
GenerateHeightMap（= GenerateFromTemplate(this,3,0)）/ GetBlobPower（TryGetValue+缺省 0.98，
零 C# 调用者 = JS 编排）/ HeightMapGenerator cctor 幂表（= Azgaar 表，唯一差异 blob[10000]=0.91）/
GenerateBaseMap（GenerateHeightMapFromJs → RankCell → **CultureGenerator.Generate+Expand**）/
GenerateHeightMapFromJs（**无回落**）/ HeightMapExternal.Generate+Init（Puerts ExecuteModule("main.mjs")
→ 绑定 generateMapInJs）/ ReadBinarySaveContainerHeader（V2 容器 [magic][ver][ivSize][IV]）/
EncryptString+DecryptString+cctor（**密钥 o7E@:5UwTW_>XV9_8I?~eoux7E7?Kn~t，AES-256-CBC 零 IV**）。

### 2) 运行数据实测（运行时证据）
- 四档 BasicMap 解密：cell 数 **19928/30030/40050/79924**，21 个 cell 数组 schema 全量。
- 官渡之战（40050）解密：**land 31.8%、mean 23.1、海=0、60-69 台地 6693 格**；文化 10+1
  （type/expansionism 0.9-4.1/center/Shield）；1008 省/36 国。渲染 tests/origin_40050_heightmap.png。
- 36 工坊存档盘点：tier40050 均值 land 41.6%、tier79924 均值 45.2%。
- blob_power 敏感性扫描（185×108）：0.97→43-49%（目标带）、0.99→98-100%。

### 3) 数据层交付（第二阶段前置）
- 原版文化包（7 目录）+ 宗教包（3）复制入 assets/origin/；
- scripts/culture_pack.gd + religion_pack.gd 加载器（15 列 CSV 引号解析、加权工具、显示名）；
- tests/culture_religion_test.gd **23/23 全过**；mapgen 文化/宗教来源切换为真实数据包
  （分配规则保持重建版均匀随机并显式标注，rng 流不变、基线不受影响）。

### 4) 代码变更
- heightmap_dsl.gd：hill 写回阈值 >4.0 + 浮点 change；range 抬升 (rand+0.85)——均标注证据行；
- mapgen.gd：文化/宗教数据源接线 + TEMPLATE_INDEX 注释更新；
- 幂表/钳制/分发**零修改**（本就正确）。

### 5) 测试与已知中间态
- template_parse 9 / heightmap_dsl_test 13 / culture_religion_test 23 全过；
- selftest 1 项预期失败（海洋省=0）：0.99 幂表 + 已证算子 → 全陆中间态——**不调参**，
  终审 = main.js 解密（round12 Puerts.ReadFile → 密钥已知）；
- mapstats 中间态：三种子 100% 陆地（134400/134400/134400），不重建基线。

### 6) 遗留
- main.js（372KB 密文）解密：SaveSystem 密钥不适用，DefaultLoader.ReadFile（改过的构建）待 round12；
- per-step pow 与 31.8% 的矛盾终审；strain/trough/pit/mask/Modify 内部伪代码（round11 后段）；
- CultureGenerator.Generate/Expand（round12）→ 文化分配规则真值。

## 第十一轮补充验收：文化系统首版交付（13:10）

### 交付物
- `scripts/culture_system.gd`：cell 级多源扩张文化系统——
  - 文化集合 = 有 CultureData 的 6 个原版包（WorldII 通用包排除，实测特例）；
  - 种子选址（确定性铺点）→ 二叉堆多源 Dijkstra 扩张（代价含高度惩罚，expansionism 缩放预算）；
  - 国家归属 = 首府格文化（schema 实测：state.culture/type/expansionism 从文化拷贝）；
  - 宗教 = 文化→宗教确定性映射（schema：state.stateReligionId；规则待 State$$DetermineStateReligion）；
  - 独立随机流（不扰主随机流/基线）；证据边界全量标注在文件头。
- mapgen 接线：states[].culture/religion 改由文化系统输出（替换临时随机分配）。
- tests/culture_system_test.gd：**10/10 全过**（全图覆盖/确定性/种子敏感性/归属完整性）。

### 回归状态（诚实账）
- 全绿：culture_religion 23、culture_system 10、template_parse 9、heightmap_dsl_test 13；
- 预期失败（全陆中间态，非回归）：selftest 海洋省 1 项 + editor_test 5 项（海格用例无海可用）——
  同一根因 = 0.99 幂表 + 已证算子 → 全陆；终审 = main.js 解密（round12）；
- mapstats 未重建（等高度图终审）。

## 第十一轮补充验收 2：玩法方向启动（20:45）

### 方向调整执行
- reports/gameplay-inventory.md 交付：A 原版 15 域功能清单（按解密存档 schema 权威化）/ B 重建版 15 系统真实性审计 / C 十项差距对照 / D 三大优先功能与方案。
- **D-2 财政循环实现**：simulation._economy_tick（月度税金=人口×0.001、战争军费加倍、赤字→人口流失）；
  state.gold/gold_per_month 接入 save/load 往返；字段名为原版 schema（官渡存档解密），公式显式标注为重建版实现待证据。
- tests/economy_test.gd **4/4 全过**（gold 真实变化/存档往返/赤字路径）。
- 回归：template 9 / dsl 13 / culture_religion 23 / culture_system 10 / economy 4 全绿；
  selftest 1 + editor 5 失败维持全陆中间态已知账。
### 下一明确任务
1. round11 尾（Trough/Pit）+ round12（Puerts_ReadFile→main.js 解密；CultureGenerator；领袖）产出处理；
2. D-1 战争真实化（解密带军队的后期存档拿 SerializedArmies 实例结构）；
3. D-4 领袖实现（StateLeaderGenerator 伪代码到手后）；
4. D-5/D-6 文化扩张/宗教归属按 round12 伪代码校正。

## 第十一轮补充验收 3：战争系统真实化（21:05）

### 交付物（Army schema 依据：30 工坊存档解密实测，最大样本 8298 军队）
- simulation.gd 军队系统：
  - `_init_armies_for_state`：每国编成（Garrison 驻防首都 + BorderGuard 每 2 边境省 1 支上限 40 + FieldArmy 野战），
    22 字段与原版 schema 对齐（armyID/currentCell/preCell/homeProvince/state/armyCount float/
    armyType/armyOrder/currentState/participatedCampaigns/enemyArmyDestroyedCount/conqueredProvincesInfo…）；
  - `declare_war` → 双方 `_mobilize_armies`（army_order=AttackEnemyProvince，current_state=Marching）；
  - `_advance_armies` 月度推进：贪心走向目标省、preCell 留痕、**抵达敌省即占领（真实省级归属转移）**、
    征服记录入 army.conqueredProvincesInfo 与 history；非战争状态自动回 Idle；
  - armies 接入 save/load 往返。
- tests/army_test.gd **6/6 全过**：编成 234 支/6 国、三军型齐备、归属一致、宣战动员 42 支、
  24 个月 234 支真实移动、33 支发生真实征服、存档往返完整。

### 回归账（诚实）
- economy 4/4、culture_system 10/10、culture_religion 23/23、template 9、dsl 13 全绿；
- selftest 1 项 + editor 5 项维持全陆中间态已知账（等 main.js 终审）；
- 已知近似（标注）：军队逐步移动/战斗结算细节为重建版规则（原版逐步逻辑在 main.js/Campaign 类）；
  Modify 重载歧义 GIVEUP → b__0/b__1 lambda 在 round12 队列。

## 第十一轮补充验收 4：战斗/战役/控制权/结算（21:30）

### 新交付（WarData/CampaignData schema 依据原版存档解密实测）
- **遭遇战**：同格敌军 → `_battle`（双方按 armyCount×efficiency 对拼、各损 15~35%、败方 Reorganization
  2 个月退回 preCell、armyCount≤1 歼灭移除）→ **Campaign 实体**（schema 原版实测：
  {id,warKey,locationProvinceId,startTime,endTime,involvedArmyIds,involvedStateIds,sequenceNumber,isActive}）；
- **控制权≠所有权**：占领设 occupied_by（state 不变）→ `_settle_war` 时正式转移（控制→所有权分离）；
- **War 实体补原版字段**：warState/minMonthBeforeWarEnd=24/IsFightToTheEnd/双方盟友列表；
- campaigns 接入存档往返；整编倒计时+歼灭清理循环。

### 测试
army_battle_test **6/6 全过**：遭遇→战役、真实兵力损失、**控制≠所有权**、存档往返（armies+campaigns）。
army_test 6/6 保持。economy 4/4、culture_system 10/10、culture_religion 23/23、template 9、dsl 13 全绿。
selftest 1 + editor 5 = 全陆中间态已知账。

### 已标注近似
战斗对拼公式（15~35% 损耗）= 重建版规则（原版公式在 main.js/Campaign 类，待解密）；
省份占领持续时间/判定细节待 Campaign 类反编译。

---

## 通宵自主开发轮验收（2026-11-01 04:50）

### 交付范围（指令 §十一 A–H 逐项）
| 项 | 结论 | 验证方式 |
|---|---|---|
| A 能启动 | ✅ | `启动FMSR.bat` / Godot 直启冒烟通过 |
| B 能运行世界 | ✅ | 暂停/单步/1×/2×/4×/8× 真实驱动；单步逐月可核 |
| C 国家真实变化 | ✅ | 24 月 26/26 国财政变化（monthly_sim）；人口有上限增长 |
| D 战争真实运行 | ✅ | war_demo 12/12：宣战→动员→行军→2 战役→割 3 省→结束→停战（重建公式已标注） |
| E 历史可查看 | ✅ | 历史面板 = 真实事件流；宣战/交战/占领/灭亡/停战/联盟 |
| F 存档可恢复 | ✅ | monthly_sim + long_run：存档→读档→续延；armies/truces/记录持久化；军队 ID 唯一 |
| G 截图 | ✅ | shots/：demo_seed42_t{2,4,6,10,14,16,30,34,55,60} + report_{state,armies,history}_panel |
| H 报告 | ✅ | HANDOVER-V4.md（含已知问题 7 条）+ PROGRESS + 本文件 + gameplay-inventory |

### 自动化测试最终基线
```
selftest 26 | template_parse 9 | heightmap_dsl 13 | editor 58 | culture_religion 23 |
culture_system 10 | economy 4 | army 6 | army_battle 6 | monthly_sim 18 | war_demo 12 | long_run 18
= 203/203 全绿（0 失败，无"预期失败"项）
```

### 真实性声明
- 原版证据项（★A/★B）与重建版实现（标注于代码）的边界见 HANDOVER-V4 §3；
- 战斗逐步公式、动员/遭遇规则、税收公式为**重建版**（代码注释 + V4 §3 已声明）；
- 无假战争/假历史：演示与测试全部走真实 `tick_month` 逻辑；
- 无伪造测试：所有断言来自实际模拟数据；mainjs_verdict_test 为实验脚本无断言（已注明）。

### 与原版的主要差距（诚实清单）
1. 维诺拓扑未实现（方格近似）→ 陆地占比残差（52% vs 41.6% 平均）；
2. 省/国密度未校准；3. 原版战斗公式未移植；4. 河流/温度/降水/群系仍为既有近似
（JS 源码已解密可移植）；5. 国家面板不动态刷新。

### 结论
**通过验收**。FMSR 已是「能持续运行、发生战争、改变领土、产生历史、可存档续玩」的世界模拟；
原版差距已量化并排入后续轮次。
