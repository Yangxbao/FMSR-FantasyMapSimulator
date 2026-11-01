# FantasyMapSimulator 重建 · 进度看板（PROGRESS）

> **⚠️ 主交接文档已迁移至 HANDOVER-V4.md**（2026-11-01 通宵交付）——先读那个。
> **用途**：给"下一个接手的 AI"看的一页纸。看完这份就能知道现在到哪、下一步做什么。
> **约定**：每个阶段收尾都必须更新本文件（阶段表 + 当前状态 + 待办 + 下一条建议）。
> 最后更新：**2026-11-01 04:40（通宵自主开发轮：世界模拟闭环打通，203/203 全绿）**
>
> ## ✅ 通宵轮成果（详见 HANDOVER-V4.md）
> - **main.js 破译**（AES 密钥/IV 已知，`extracted_js/main.dec.js` 8054 行 = 原版全部生成逻辑源码）
> - **全陆中间态解除**（JS 权威终审 + DSL 修正，陆地 43.5%，findings §15.31–37）
> - **世界模拟闭环打通**：armies 实体接入真实模拟（此前为空，军队从未动过！）+ 战争全链
>   （宣战→动员→行军→省级遭遇战→占领→停战→战报）+ 盟友参战 + 国家灭亡清理 + 财政人口循环
> - **UI 可玩化**：暂停/单步/1×/2×/4×/8×、军队面板、国家面板财政与战争区、历史事件流
> - **可重复战争演示**：`-- seed=42 demo=1 shots=6,16,34`；测试 **203/203 全绿**
>   （新增 monthly_sim 18 / war_demo 12 / long_run 18 = 3 种子×120 月）
> - 下一步：收割 round12 文化/宗教/领袖（先查 main.dec.js）、原版战斗公式、省/国密度校准
>
> ## 历史轮次要点（旧文保留在下）
> - 第十一轮（10-31）：53+24 伪代码、存档密钥破解、文化/宗教/军队/经济四大系统、模板顺序证实
> - 第十轮（10-31）：反编译队列基建（WMI 脱离会话）、BurgsAndStateGenerator 12 件套
>
> ## ✅ 第十轮反编译队列（已完成，产物已收割）
>
> **与以往不同**：本队列通过 Windows 计划任务启动（`tools/launch_round10_queue.bat` →
> `tools/decompile_round10_queue.sh`），**不挂在 AI 会话上**，不会被会话回收（HANDOVER §6.13 教训已落实）。
> 串行顺序：`HeightmapTemplates..cctor` → `addStep` → `addOneHill` → `addOneRange` →
> `GetNumberInRange` → `Biomes..cctor` → `DrawShapes` → `GetColorFromHeight` → `World.GenerateBaseMap`，
> 产物 `logs/dec_<名字>.json`，进度看 `logs/round10_queue.out`（预计 5~7 小时跑完）。
>
> **判断有没有在跑**：`tail logs/round10_queue.out` + 用 PowerShell 查 `java.exe` 命令行里有没有
> `ghidra`（机器上 IDEA 的 jbr 也叫 java.exe，别误判）。**必须串行**（并行必 OOM，HANDOVER §6.11）。
>
> **已成功拿到（25 个方法的伪代码在 `reports/decompiled/`）** —— 这些不用再跑：
> `HeightMapGenerator.GenerateFromTemplate` / `GenerateHeightMap` / `addHill` / `addRange` / `smooth`、
> `World.GenerateHeightMap` / `GenerateNoiseHeightmap` / `GeneratePoints` / `DefineOceanGroup`、
> `BurgsAndStateGenerator.*` 全部 12 个、`Biomes_Initialize`、`getTimeCost 三兄弟` 等。
>
> **注意**：dec7 时代的失败曾留下两个 **0 字节占位文件**
> （`reports/decompiled/HeightMapGenerator_addStep.c`、`RandomUtils_GetNumberInRange.c`），
> 新队列产出后用其内容替换（导出前务必检查 JSON 是否含 `"error"`）。
>
> 配套长文档（本文件不重复其内容）：
> - `docs/HANDOFF-20261030-v2.md` —— 环境、工具链、坑、项目事实（**先读这个再动手**）
> - `reports/restoration-acceptance.md` —— 正式验收清单 + 逐轮验收记录（判断"能不能算完成"看这里）
> - `reports/decompile-findings.md` —— 反编译机制解读（每轮新增章节，**§14 = 模板顺序证据链**）

---

## 0. 当前状态一句话

**第十一轮完成高度图证据大扫荡**：算子层（addStep/addOneHill/addOneRange/GetNumberInRange/Lim/
GenerateHeightMap）与幂表（cctor 立即数 = Azgaar 表逐字一致，唯一差异 blob[10000]=0.91）全部逐字证实；
**JS 通道闭环实锤**——原版生成器在加密 main.js（Puerts main.mjs 模块）里，C# 算子库被 JS 编排
（GetBlobPower 零 C# 调用者）；**存档加密破解**（AES-256-CBC/零IV/密钥已提取），四档 BasicMap + 36
工坊存档全解，真值高度场（land 31.8%@40050）与文化对象结构到手并渲染对照。
**当前最大未解**：per-step pow 衰减模型与原版 31.8% 陆地的矛盾——终审在 main.js 解密
（round12 Puerts.ReadFile → 密钥已知，SaveSystem 加密套件已全部反编译）。
第二阶段（文化/宗教）数据层已交付并测试（23/23），分配规则证据（CultureGenerator.Generate/Expand）在 round12 队列。

## 1. 阶段进度表

| 阶段 | 日期 | 完成内容 | 验证结果 | 证据/产物 |
|---|---|---|---|---|
| 基线 | 10-30 | 管线骨架、国家/行省面板、地形 Sprite、羊皮纸海面、存读档 | selftest 12 断言 PASS | `reports/restoration-acceptance.md` 基线节 |
| 第二轮 | 10-30 | 修 `generate()` 幂等性缺陷；构图式大陆；小岛清除；边界两轮 Chaikin 平滑；建 mapstats/mapdump/自动截图 | 3 种子稳定；视觉质变 | `tests/visual_seed42_wobbled.png` |
| 第三轮 | 10-30 | 9 个生成方法反编译完成；国家扩张改为原版多源 Dijkstra；省份归属改为 cell 多数制 | 国界随地形不规则；31~33 国 | `reports/decompiled/*.c`、`tests/visual_seed42_dijkstra.png` |
| **第四轮** | **10-30** | **省份扩张改为原版多源 Dijkstra**（优先队列、种子代价 1.0、`+10+extra/1.0`、`cost==0‖new<old`、陆地才写归属、允许穿水、中心格保护）；新增 FilterProvinceCells / EnsureProvinceConnectivity；删除自研 BFS；反编译 biome/river/type 三个代价 helper（六项公式已全部拿到）；第二批反编译 5/5 全部完成（10:47→13:08，含 `PlaceProvincialCapitalsByJitterGrid` 与 `SelectCapitalsFromProvinces`） | **selftest 14 断言 ALL PASS**；省份 549/541/568、国家 28/31/32、孤儿 0、空省 0、内陆飞地 0 | `tests/visual_seed42_prov_dijkstra.png`、`tests/part_prov_seed42.png`、`decompile-findings.md` §6/§7 |
| **第五轮** | **10-30** | **首都挑选改为原版泊松盘半径采样**（`radius=sqrt(总格数/目标国数)`，不足 `/1.2` 重试，`<=1.0` 兜底），删除"邻接度排序"启发式；**国家扩张补上穿水**（代价/入队对所有邻格、只在陆地写归属）；新增"首都省必属本国"不变式 | **selftest 14 断言 ALL PASS**；三种子国家数 **26/26/26 = 目标值**；国家最小省数 1→4~6；省份 549/541/568 不变 | `tests/visual_seed42_capitals.png`、`tests/part_state_seed42_sea.png`、`acceptance` 第五轮节 |
| **第六轮** | **10-30** | **转向功能面还原**：国家面板补齐（国名/取色器/政体/首都/人口/领袖/文化/宗教/军队/战舰/附庸/盟约/战争子面板/历史分页/统计分类）、行省面板补齐（类型三按钮/自定义人口/自定义防御/区域人口与防御）、**简化版战争系统 WarManagerV2**（12 类型 + 5 目标 + 战争分数 + 战报）、存档 v2（含归属重建缺陷修复） | **selftest 19 断言 ALL PASS**（含战争产出 30 场/19 战报）；面板截图 `ui_state_panel.png` / `ui_province_panel.png`；地图基线未变 | `acceptance` 第六轮节 |
| **第七轮** | **10-30** | **底层优先**：海洋省份落地（按连通海域建省 + FIFO 洪水填充，`is_sea/sea_index/sea_tier` 字段；海洋省不进陆地邻接图、不属任何国家；点击海面可查）；新反编译 `World.DefineOceanGroup` 验证海域分组与三档阈值 | **selftest 20 断言 ALL PASS**；海域省 49/70/38、未归属海格 **0**；陆地省与国家指标与第五轮完全一致 | `tests/part_prov_seed42_sea_prov.png`、`acceptance` 第七轮节、`findings` §7.7 |
| **第八轮** | **10-30** | **四层地图编辑器**：高度/植被/行省/国家四层笔刷（半径·高度·衰减·5 模式·拖动绘制·笔刷预览）、撤销/恢复（delta+结构深拷贝）、保存/读取、地图外观三视图 + 行政图透明度；**群系系统**（13 群系数据来自原版文件、全图 biome 数组、群系笔刷、温湿度重算）；**全局指令面板 19 项且开关真实生效**（联盟/孤立省放弃/协助盟友/结束战争联盟/清空地图/重算区域/设时间/自动存档）；存档 v3 增地形与群系 | **editor_test 58 项 ALL PASS**；**selftest 26 断言 ALL PASS**；三种子生成结果与第七轮**逐项一致**（陆地 50777/50859/50933，行省 598/611/606，国家 26/26/26）；`biomes_land=12`、`biome_sea_wrong=0` | `tests/ui_panel_editor.png`、`ui_panel_global.png`、`ui_editdemo_{height,biome,province,state}.png`、`acceptance` 第八轮节、`findings` §9/§10 |
| **第八轮补充** | **10-30** | **按原版实机截图对齐**：编辑器窄面板（官方 12 项模式名 / 分页 / 随机国家 / 两位小数 / 2×2 编辑·删除·绘制·擦除 / 提示·清空·关闭 / 进编辑自动暂停且按钮变「继续游戏」）；国家面板改左停靠 + 折叠区 + 截图同款 15 行信息表 + 彩色按钮组；新增国家字段（民族特征/建国年/国库/腐败度/官员，确定性生成不动基线）；**人口量纲 ×1000**；11 个国家行为按钮全部真实生效；国界改暗红粗线 + 虚线经纬网 | **selftest 27 / editor_test 55 全过**；mapstats 三种子指标与上版**逐项一致** | `tests/origin_shots/*`（原版截图）、`tests/ui_panel_editor.png`、`tests/ui_state_panel.png`、`findings` §11 |
| **第八轮续** | **10-30** | **海平面改成原版固定 20/100**（`World.GenerateHeightMap` 实证 `+0x178=0x14`）：高度场做分段线性重标定（陆海集合不变），地形项因此真正参与省份扩张；行省面板改左停靠 + 折叠区；国家色饱和度上调、陆地不透明度 0.92；新增 `noinput` 截图参数 | **selftest 27 / editor_test 55 全过**；mapstats 已按新基线重建（陆地 50778、省 598、国 26，省最大 200→213 属预期） | `tests/visual_seed42_sea20.png`、`tests/ui_province_panel.png`、`findings` §12 |
| **第九轮** | **10-30** | **高度图换成原版模板 DSL**：① 从 `global-metadata.dat` 字面量表取到 5 份模板正文（literal 6866/6867/6868/6869/10442，共 70 行），落到 `assets/origin/heightmap_templates.json`；② 新增 `scripts/heightmap_template.gd`（按 `GenerateFromTemplate` 的 Split/Trim/行数校验解析）；③ 新增 `scripts/heightmap_dsl.gd`（9 个算子 + `getNumberInRange`/`getPointInRange`/`findSlot` 的 JS 语义逐个对齐）；④ `mapgen._gen_elevation` 改为：按原版 **20000 cell** 跑 DSL → 最近邻上采样到 480×280 → `/100`，海平面固定 0.20；⑤ 停用自研 `_remove_small_islands`（`REMOVE_SMALL_ISLANDS=false`，代码保留）；⑥ 修两个连带缺陷：河流在整数高度平台上断流（等高放行）、笔刷划走 center 格后省份 center 失效（rebuild 时按质心修复） | **selftest 26 / editor_test 58 / template_parse 9 / heightmap_dsl_test 13 全过**；mapstats 重建新基线、二次运行**无 Δ**；陆地 76049/62910/77794（37.8%→56.6%/46.8%/57.9%），省 960/753/954，国 26/26/26，河流 18/14/21 | `tests/dsl_tpl{0..4}.png`、`reference/azgaar/`（算法蓝本副本）、`findings` §13 |
| **第十轮** | **10-31** | **模板列表插入顺序证实**：不走 Ghidra，直接写 `tools/scan_template_order.py` 解析 PE + v29 元数据 usage 槽位（编码 `(5<<29)\|(idx<<1)`），从 `HeightmapTemplates..cctor`（VA 0x18039B350）机器码提取 5 个构造块的字符串引用对，证明 Add 顺序 = `[Volcano/6868, High Island/6869, Continents/6866, Continents/6867, Continents/10442]` → **Templates[3]=6867**；`GenerateFromTemplate` 反编译证实是 IReadOnlyList 列表下标（"字典键"猜测作废）；JSON 按 Add 顺序重排 + `name` 字段 + `_verified` 注记；旧基线备份 `.pre-cctor-fix.json` 后重建；同时建立 **schtasks 脱离会话队列** `FMSR_dec_r10`（9 个方法串行，解决 §6.13 僵尸问题） | **template_parse 9 / dsl_test 13 / selftest 26 / editor_test 58 全过**；mapstats 重建后二次**无 Δ**；新基线陆地 132179/122168/127559（**91~98%**，水量偏差待算子核对）；`heightmap_dsl_test` 的模板#3 现在跑的是真身 6867 | `findings` §14、`acceptance` 第十轮节、`tools/scan_template_order.py`、`logs/round10_queue.out` |
| **第十一轮** | **10-31** | **算子证据链 + JS 通道全景 + 存档加密破解**：①addStep 分发/addOneHill（>4.0 写回阈值、浮点衰减、90 重试）/addOneRange（抬升因子域 [0.85,1.85]）/GetNumberInRange/Lim(clamp 0..100)/GenerateHeightMap(=GenerateFromTemplate(this,3,0)) 全部逐字证实，DSL 按证据小步修正（hill 浮点+阈值、range 抬升）；②**幂表从 cctor 立即数全量提取 = Azgaar 表逐字一致**（唯一差异 blob[10000]=0.91），重建版常量表本来就对；③**JS 通道闭环**：GenerateHeightMapFromJs → HeightMapExternal.Generate → Puerts ExecuteModule("main.mjs") → 绑定 generateMapInJs——**无 C# 回落**，生成器在加密 main.js（497KB）里，GetBlobPower/GetLinePower **零 C# 调用者**（JS 编排实锤）；④**存档加密破解**：AES-256-CBC/零IV/密钥 \`o7E@:5UwTW_>XV9_8I?~eoux7E7?Kn~t\`，四档 BasicMap + 36 工坊存档全解——**19928/30030/40050/79924 cell 真值图 + 文化对象（type/expansionism/center/Shield）+ 省/国/战争 schema 全量到手**；⑤原版 40050 真值高度场渲染 tests/origin_40050_heightmap.png（land 31.8%）；⑥战争真实化二阶段：**遭遇战+Campaign 实体+控制权≠所有权+结算转移**（army_battle_test 6/6）+文化/宗教系统首版：culture_system.gd（cell 级多源扩张+国家归属+宗教映射，二叉堆）+ 加载器×2 + 测试 33/33（23+10）+ mapgen 接线（分配规则待 round12） | **template_parse 9 / dsl_test 13 / culture_religion 23 全过**；selftest 海洋省断言预期性失败（0.99 幂表+已证算子 → 全陆中间态，不调参等 main.js 终审）；mapstats 中间态 100% 陆地已记录 | findings §15（15.1-15.21）、acceptance 第十一轮节、extracted_js/、logs/workshop_guandu.json、tools/decompile_round11_queue.sh |


## 2. 现在能跑通什么（复现命令）

> **数字勘误（第九轮实测）**：阶段表里第八轮/第八轮续写的「selftest 27 / editor_test 55」有误，
> 第九轮开工时实测复核为 **selftest 26 / editor_test 58**（HANDOVER 的 26/58 才是对的）。以实测为准。

**启动游戏**：双击 `启动FMSR.bat`（项目根目录）。它会先清掉残留实例再启动，并回报"成功/进程已退出"。
若报"进程已退出"，改用 `launcher-diagnose.bat`（控制台模式 + `--verbose` + 退出后暂停），错误会直接打印在窗口里。

> ⚠️ 批处理文件必须保持**纯 ASCII**。cmd 按本地代码页（GBK）读取 .bat，写入 UTF-8 中文会破坏 `if (...)` 语法。

```bat
:: 逻辑自检（当前基线：26 断言 ALL PASS）
E://Godot//Godot_v4.2.2-stable_win64_console.exe --headless --path E://GameResearch//FantasyMapSimulator//source//fms-godot --script tests/selftest.gd

:: 编辑器自检（58 项：笔刷改数据 / 撤销恢复 / 结构不变量 / 合并不变量 / 存读档 / 沉没清理）
... --headless --path ... --script tests/editor_test.gd

:: 3 种子地图统计（基线在 user://mapstats-baseline.json，重跑输出 Δ）
... --headless --path ... --script tests/mapstats.gd

:: 省份/国家着色图（mode=prov|state）
... --headless --path ... --script tests/mapdump.gd -- seed=42 mode=prov

:: 游戏内自动截图
... --path ... -- seed=42 shot=9
:: 编辑器面板截图 / 全局指令 / 视图切换 / 四层编辑演示
... --path ... -- seed=42 shot=6 panel=editor
... --path ... -- seed=42 shot=6 panel=global
... --path ... -- seed=42 shot=6 view=biome
"... --path ... -- seed=42 shot=6 editdemo=height|biome|province|state
:: 截图时加 noinput 可忽略真实鼠标（前台窗口被误点会改变画面）
... --path ... -- seed=42 shot=7 noinput
```

**原版参考图**：`tests/origin_shots/`（用户 2026-10-30 手动运行原版提供，含大地图 / 国家面板 /
国家行为 / 折叠区 / 地图编辑面板五张）——对齐规格见 `reports/decompile-findings.md` §11。

当前统计基线（**第十轮重建**，模板 6867；旧基线备份 `user://mapstats-baseline.pre-cctor-fix.json`，
第九轮基线备份 `user://mapstats-baseline.pre-dsl.json`）：

| seed | 陆地 | 陆地占比 | 陆地省(+海域省) | 省最大/中位 | 国家 | 国家碎片 | 群系种类 | 河流 | 孤儿格 | 空省 | 未绘制 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 42 | 132179 | **0.983** | 1154 (+60) | 275 / 118 | 26 | 26 | 12 | 62 | 0 | 0 | 0 |
| 1337 | 122168 | **0.909** | 1195 (+142) | 268 / 115 | 26 | 31 | 12 | 44 | 0 | 0 | 0 |
| 2026 | 127559 | **0.949** | 1170 (+96) | 268 / 118 | 26 | 27 | 12 | 55 | 0 | 0 | 0 |

> 读数说明：模板从 6869（High Island）换成**原版真身 6867** 后陆地暴涨到 91~98% —— 这是
> 「算子参数/语义尚未与原版伪代码逐字核对」的体现（见 §0 与 findings §14.3），不是回归；
> 结构上地图已是"多大陆 + 垂直海峡 + 小岛"。判定标准仍是二次运行**无 Δ 行**。
> ⚠️ 在 addStep/addOneHill/addOneRange 核对完成前，**不要**把这组数字当"原版行为"。

## 3. 常见问题（启动/运维）

| 现象 | 原因 | 处理 |
|---|---|---|
| 双击启动"没反应"/没窗口 | 上次异常退出或自动截图（`-- seed=N shot=S`）留下**僵死 Godot 实例**，与新窗口抢焦点/音频设备 | `启动FMSR.bat` 已内置 `taskkill` 清理；也可手动结束 `Godot_v4.2.2-stable_win64*.exe` |
| 启动后窗口秒退 | 脚本解析错误（改过 mapgen.gd 之后最常见） | 跑 `launcher-diagnose.bat` 看 `SCRIPT ERROR`；或先跑 `tests/selftest.gd` 验证脚本能编译 |
| 启动很慢、地图要等好几秒，机器发烫 | 反编译（Ghidra 的 java.exe）在跑，约占 2 GB 内存 + 单核满载；地图生成本身约 1~3 s | 反编译结束后自动释放；跑游戏时不要同时开反编译 |
| 控制台中文乱码 | Godot/脚本输出是 UTF-8，终端按 GBK 显示 | 只看 PASS/FAIL 与数字即可；不影响功能 |
| 启动器误报"启动失败" | `.bat` 里用 `find` 判进程时，若 PATH 里 Git 的 `find.exe` 排在 System32 前面会解析错 | 已改用 `findstr`（Windows 独有）；**注意：在 Git Bash 里测试会复现此问题，正常双击不受影响** |

## 4. 待办（按"价值/成本"排序）

| # | 事项 | 为什么值得做 | 成本 | 阻塞/前置 |
|---|---|---|---|---|
| ~~1~~ | ~~证实模板下标 3~~ | **✅ 第十轮已完成**（机器码证明 Templates[3]=6867，见 findings §14） | — | — |
| **1** | **算子参数/语义逐条核对**：`addStep` / `<addOneHill>` / `<addOneRange>` / `GetNumberInRange`（**伪代码由第十轮队列产出中**，`logs/dec_HeightMapGenerator__*.json`） | 新模板 6867 下陆地 91~98% vs 原版约 45~55%，模板选择已证没错，**剩下的水量偏差必然来自算子语义**（Hill 的 blobPower/90 上限、Range 的 randomness、Multiply/Add 参数位）。逐条对照 `scripts/heightmap_dsl.gd` 校正后重跑 mapstats 重建基线 | 低（对照改代码，每处 ≤20 行） | 等队列产出（在跑） |
| 2 | **群系真值**：`Biomes..cctor`（队列中）+ 读 `World.GenerateBaseMap`（队列中，超大方法） | 给出群系**颜色表 / 移动代价表 / 温湿矩阵 / 宜居度**，替换近似矩阵，并解锁省份扩张的 biome 代价项 | 低（等队列）+ 中（替换矩阵） | 无 |
| 3 | **剩余编辑模式**：区域 / 空白不可征服区 / 文化 / 宗教 / 家族 / 自定义标签 / 地图尺寸 | `EditPanelUI` 字段已列出（findings §9.1），玩家可见 | 高 | 文化/宗教系统先落地 |
| 4 | 真实抖动网格 `World.EnsureProvinceBurgCellsReady` | 决定省份密度；现在 step=11/±4 是猜的 | 低（伪代码已在 `reports/decompiled/`，只差读） | 无 |
| 5 | 笔刷混合算符 `BrushManager.DrawShapes` / `GetColorFromHeight` | 把 5 种笔刷模式从近似改成原式（两者都已在队列中） | 低（等队列） | 无 |
| 6 | 战争类型细分 / 附庸朝贡参战义务 / 领袖家族文化宗教 | 用户排在第三位；当前多为占位 | 高 | 稳定底层后 |
| 7 | 省份边界真维诺图化（含 cell 数量改 1w/2w/3w/4w） | 原版是维诺图 + 4 档地图尺寸；现在固定 480×280 格网。**高度图 DSL 已按 2 万 cell 跑再上采样，只要换掉网格就能直接吃到原版分辨率** | 高 | 与数据结构改造耦合 |

> **视觉比对的历史结论已修正（第十轮）**：第九轮曾凭渲染相似度选了 6869（"最像原版"）——
> 机器码证明那是 `Templates[1]`。同一套有偏算子语义下，错误模板碰巧更像原版截图。
> 视觉比较对"选模板"不可靠；新渲染 `tests/dsl_tpl{0..4}.png` 顺序已按原版列表下标排列。

## 5. 未还原项清单（**这些不是原版参数，别当真相引用**）

1. **高度图：模板选择已证（第十轮），剩余偏差在算子语义**。已证：模板正文（字面量表真值）、
   模板列表顺序（cctor 机器码，`Templates[3]`=6867）、`3` 是列表下标（get_Item 反编译）。
   仍未证/未对齐：①**Hill/Range/Trough/Strait/Mask/Pit/Multiply/Add 的参数语义与数值细节**
   （只经 Azgaar 同构交叉印证，`smooth` 逐字核对过）——当前 91~98% 陆地 vs 原版约 45~55% 的主因；
   ②原版跑在维诺图的 1~4 万 cell 上，本工程是「2 万 cell 网格算完再最近邻上采样到 480×280」；
   ③随机流是本工程 `RandomNumberGenerator`，**同 seed 不可能逐格重现原版**；
   ④原版 `World.GenerateHeightMap` 先试 `GenerateHeightMapFromJs`（外部 JS 通道），失败才回落
   模板 DSL——这条回落路径是推断，游戏目录无 .js 文件，**不能完全排除原版默认图走 JS 生成器**。
2. ~~海平面用自适应分位~~ → **第八轮续已改为固定 20/100**：高度场重标定后 `elevation` 0.20 即海平面，笔刷高度 0..100 与原版同义（0=海平面，100=最高，>70 为险要）。
3. **群系判定矩阵与配色是近似**：13 群系的**名字/顺序/中文名**来自原版文件（真），但"温度×湿度→群系"的阈值与色表未取到（在 `Biomes..cctor`）。
4. **省份扩张代价的 biome / river / type 三项恒 0**（公式已全部反编译）：缺的是数据维度（biome 图已补，但代价表未取；无 cell→river id / cell type）。补 biome 代价表后 biome 项即可接入。
5. **笔刷 5 种模式的混合算符是近似**（`BrushManager.DrawShapes` 未反编译）。
6. **地图是 cell 格网（480×280），不是原版维诺图**；原版 4 档尺寸 10000/20000/30000/40000 cell。
7. **抖动网格间距/抖动幅度是猜的**（step=11、±4），真实值在 `World.EnsureProvinceBurgCellsReady`。
8. **文化项恒取 -9**（同文化分支）：重建版无文化系统。
9. **领袖/文化/宗教是占位数据**（字段与面板已通，数据来自内置词库）。
10. **战争类型 12 种里只触发 4 种**；附庸/盟约已有真实效果（联盟缔结、孤立省放弃、协助盟友），但缺朝贡与参战义务。
11. **编辑模式只做了 4 层 + 全局指令**，其余 8 个模式（区域/空白地/文化/宗教/家族/标签/图钉/地图尺寸）未做。
12. 工作区**无版本控制**（非 git 仓库）；改动前手工备份在 `backups/`。
13. **小岛清除已停用**（`mapgen.gd::REMOVE_SMALL_ISLANDS = false`）：原版无此步骤的证据，此前是自研近似；
    DSL 高度图会自然产出大量小岛，保留算法产物而不是清理掉。
14. **河流算法仍是自研**（`_gen_rivers`：90 个随机源 + 最低邻格下坡）。本轮为适配整数高度场加了
    「等高平台允许平走一格」，否则坡度平台会直接断流（实测河流 18/14/21 条）。原版是 `World.DrawRiver`，未反编译。

## 6. 文件索引（改动最频繁的几个）

| 路径 | 作用 |
|---|---|
| `source/fms-godot/scripts/mapgen.gd` | 世界生成全部算法 + 群系系统 + 编辑器所需的结构重建（`rebuild_after_province_edit` 等）；`_gen_elevation` 现在跑模板 DSL，旧 FastNoise 版留作 `_gen_elevation_legacy_fastnoise` |
| `source/fms-godot/scripts/heightmap_template.gd` | **新增**：模板 DSL 解析器（读 `assets/origin/heightmap_templates.json`，按 Split/Trim/行数校验切行） |
| `source/fms-godot/scripts/heightmap_dsl.gd` | **新增**：9 个高度算子的解释器 + `getNumberInRange`/`getPointInRange`/`findSlot` 的 JS 语义 |
| `source/fms-godot/assets/origin/heightmap_templates.json` | **第十轮已重排**：5 份模板正文按原版 Add 顺序排列（`order_seen` ≡ 原版列表下标），含 `name` 字段与 `_verified` 证据注记 |
| `tools/scan_template_order.py` | **第十轮新增**：PE + v29 元数据纯解析，从 cctor 机器码 RIP 引用恢复模板顺序（不需要 Ghidra） |
| `tools/reorder_templates.py` | **第十轮新增**（一次性）：按证明的 Add 顺序重排模板 JSON |
| `tools/decompile_round10_queue.sh` + `launch_round10_queue.bat` | **第十轮新增**：schtasks 脱离会话的串行反编译队列（9 方法）及其启动器 |
| `reference/azgaar/*.ts` | **新增**：算法蓝本副本（Azgaar FMG 的 heightmap-generator / templates / utils），用于交叉印证 |
| `source/fms-godot/scripts/map_editor.gd` | **四层编辑器内核**：笔刷、撤销/恢复、合并、清空、存读档 |
| `source/fms-godot/scripts/main.gd` | UI：工具栏、各面板、编辑器浮坞、全局指令面板、调试参数（`panel=` / `view=` / `editdemo=`） |
| `source/fms-godot/scripts/map_render.gd` | 渲染：三视图、行政图透明度、笔刷预览、边界平滑 |
| `source/fms-godot/scripts/simulation.gd` | 月度模拟 + 战争 + 全局指令效果 + 存档 v3 |
| `source/fms-godot/tests/selftest.gd` | 逻辑自检（26 断言） |
| `source/fms-godot/tests/editor_test.gd` | 编辑器自检（58 项） |
| `source/fms-godot/tests/template_parse.gd` | **新增**：模板解析自检（9 项） |
| `source/fms-godot/tests/heightmap_dsl_test.gd` | **新增**：DSL 数值自检（13 项，含 smooth 手算对照、区间解析语义） |
| `source/fms-godot/tests/heightmap_templates_dump.gd` | **新增**：5 份模板渲染成 PNG 供视觉比对 |
| `source/fms-godot/tests/mapstats.gd` | 3 种子统计 + 基线 Δ |
| `reports/decompiled/*.c` | 已反编译伪代码（25 个方法） |
| `reports/decompile-findings.md` | 机制解读（§9 编辑器规格、§10 高度图编排、§13 高度图模板 DSL、**§14 模板顺序证据链**） |
| `logs/dec*_*.json` | 反编译原始证据 |

## 7. 给下一个 AI 的一条建议

**只做一件事：等第十轮队列产出后，逐条核对高度算子语义并修水量。**
模板下标已经钉死（findings §14），地图"长什么样"的下一层误差在算子语义：

1. 队列（schtasks `FMSR_dec_r10`，脱离会话）按序产出 `logs/dec_<名字>.json`：
   `HeightmapTemplates__cctor`（Ghidra 第二确认，与 §14 逐条核对，矛盾则回退）→
   `HeightMapGenerator__addStep` → `HeightMapGenerator__addOneHill` →
   `HeightMapGenerator__addOneRange`（注意真名是 `HeightMapGenerator.<>c__DisplayClass15_0$$<addRange>g__addOneRange|0`）→
   `RandomUtils__GetNumberInRange` → `Biomes__cctor` → `BrushManager__DrawShapes` / `__GetColorFromHeight` →
   `World__GenerateBaseMap`（超大，最后）。
2. 伪代码到手后用 `logs/*.json` 的 `normalized_result` 字段导出 `.c` 到 `reports/decompiled/`（先查无 `"error"`），
   然后逐条对照 `scripts/heightmap_dsl.gd`：重点核对 **Hill 的 blobPower 与 90 上限、Range 的 randomness、
   Multiply/Add 参数位、Trough/Strait/Mask** —— 目标是把新模板 6867 的陆地占比从 91~98% 校到原版截图的
   约 45~55%。每处改动 ≤20 行；改完重跑 selftest/editor_test/dsl_test 并**重建 mapstats 基线**。
3. `Biomes..cctor` 产出后顺手替换群系近似矩阵（待办 #2），`DrawShapes` 产出后校笔刷混合（待办 #5）。

做完再回来更新本文件的阶段表与 `restoration-acceptance.md`。
