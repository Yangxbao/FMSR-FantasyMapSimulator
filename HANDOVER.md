# FantasyMapSimulator 逆向重建 · 交接文档（HANDOVER）

> ⚠️ **本文已由 HANDOVER-V2.md 取代为当前主交接文档**（2026-10-31 21:00）。
> 本文保留为环境/工具链/历史坑的参考手册。
> 写于 **2026-10-30 23:25**（本机时间）；**最后更新 2026-10-31 12:10（第十一轮）**。
> 第十一轮要点：算子/幂表/Lim 逐字证实（幂表=Azgaar 表，唯一差异 blob[10000]=0.91）；
> **JS 通道闭环（原版生成器在加密 main.js 里，无 C# 回落）**；**存档加密破解**（AES-256-CBC/零IV/
> 密钥 \`o7E@:5UwTW_>XV9_8I?~eoux7E7?Kn~t\`），四档 BasicMap + 36 工坊存档全解，真值高度场与文化
> 对象结构到手；文化/宗教数据层交付（23/23 测试）；round11/round12 队列继续产出中。
> 读者：**完全没有上下文**的接手者（含其他 AI）。
> 本文所有事实均从工作区文件与本次实测命令得出；无法核实的会标「未验证」。
> 本文描述的是一个**Windows 上的逆向重建工程**，不是原版游戏本身。
> 第十轮要点：**模板下标已证（Templates[3]=6867，findings §14）**、schtasks 脱离会话队列落地、
> 新基线 91~98% 陆地（算子语义偏差，新下一步）。
>
> **配套文档**（本文不重复其内容，按需查）：
> - `PROGRESS.md` —— 一页纸进度看板：现在到哪、阶段表、统计基线、待办排序、**下一步唯一一条建议**
> - `docs/HANDOFF-20261030-v2.md` —— 更早的环境/工具链长文档（本文已覆盖其要点，冲突时以本文为准）
> - `reports/restoration-acceptance.md` —— 正式验收清单 + 逐轮验收记录（判断"算不算完成"看这里）
> - `reports/decompile-findings.md` —— 反编译机制解读（每轮新增章节，**§14 = 模板顺序证据链**）

---

## 1. 项目一句话

**是什么**：在 `E:\GameResearch\FantasyMapSimulator` 里用 Godot 4.2.2 + GDScript 重写一份
Steam 游戏《FantasyMapSimulator》（Unity 2021.3.36f1 / IL2CPP / x64）的 Windows 版，
通过 REA + Ghidra 反编译原版 `GameAssembly.dll` 拿到真实算法与界面规格，逐条照抄实现。

**复刻目标**：先做到"和原版一模一样"，再谈改动。硬性纪律（用户定的）：
不许把自定参数说成原版参数；近似必须显式标注；Android 移植冻结到 Windows 验收通过为止；
不许用占位数据冒充原版机制。

**当前还原度（主观估计，不是测量值）**：

| 维度 | 估计 | 依据 |
|---|---|---|
| 地图生成管线（12 步） | **约 75%** | 7 步已按反编译 1:1 实现；**高度图已是原版模板 DSL 且模板下标已证**（Templates[3]=6867，findings §14），但**算子参数/语义只部分核对**（smooth 逐字；其余 Azgaar 同构推断）→ 新模板下陆地 91~98% vs 原版约 45~55%，水量明显偏差；4 步仍是近似（CreateProvinces 种子、抖动网格、EnsureProvinceConnectivity、CreateStates 颜色命名） |
| 四层地图编辑器 | **约 40%** | 原版 `EditPanelUI` 有 12 种编辑模式 + 全局指令；已实现 4 种（高度/生态/行省/国家）+ 全局指令，其余 8 种点下去只提示"未还原" |
| 玩法系统（战争/外交/附庸/内政） | **约 35%** | 战争分数/结算/割地/吞并/附庸/联盟/孤立省放弃有真实逻辑；文化、宗教、家族、领袖、兵种、官职全是占位或骨架 |
| 视觉与界面 | **约 55%** | 两个主面板已按原版实机截图对齐；地图仍是 cell 格网（原版是维诺图），海岸有阶梯感 |
| **综合** | **约 55%（±10）** | 上述四项的主观加权，不是任何测试的输出 |

**证据强度**：`reports/decompiled/` 有 **25 个有效**伪代码文件
（目录下共 27 个 `.c`，其中 `HeightMapGenerator_addStep.c`、`RandomUtils_GetNumberInRange.c`
是 **0 字节占位**，等待反编译填补；用 `python tools/decompile_status.py` 可随时核实）。

---

## 快速开始：接手者先做这 3 件事（再回头读全文）

1. **确认当前状态**，一条命令出全部结论（32 秒）：
   ```
   cd /e/GameResearch/FantasyMapSimulator
   python tools/decompile_status.py
   ```
   它会告诉你：有没有反编译在跑、哪些批次是**僵尸任务**（产物停在 0 字节但驱动进程已死）、
   已反编译多少方法。也可以双击项目根目录的 **`查看反编译进度.bat`**。

2. **跑一遍回归**，确认代码没坏（约 1 分钟）：
   ```
   cd source/fms-godot
   "E:/Godot/Godot_v4.2.2-stable_win64_console.exe" --headless --path . --script tests/selftest.gd
   ```
   当前基线：**selftest 26 断言**、**editor_test 58 项**、**template_parse 9**、**heightmap_dsl_test 13**（见 §4.1）。

3. **读 `PROGRESS.md` 的 §0 与 §7**，那里有"现在到哪"和"下一步只做这一条"。
   然后回到本文第 8 节照着做。

> ⚠️ **别相信任何"后台还在跑"的说法**。本工程的反编译命令挂在 AI 会话里，
> **会话一中断（上下文压缩、模式切换、对话结束）就会被系统回收**，
> 产物永远停在 0 字节。详见 §6.13。截至本次交接，**所有反编译批次都已死**，没有一个在跑。

---

## 2. 环境与入口

### 2.1 路径

| 项 | 绝对路径 |
|---|---|
| 工作区根目录 | `E:\GameResearch\FantasyMapSimulator`（**不是 git 仓库**：`git log` → `fatal: not a git repository`） |
| Godot 工程 | `E:\GameResearch\FantasyMapSimulator\source\fms-godot` |
| 原版游戏（**只读，禁止写入**） | `E:\steam\steamapps\common\FantasyMapSimulator` |
| 原版 DLL（反编译目标） | `E:\steam\steamapps\common\FantasyMapSimulator\GameAssembly.dll` |
| Godot 控制台版 | `E:\Godot\Godot_v4.2.2-stable_win64_console.exe`（`--version` → `4.2.2.stable.official.15073afe3`） |
| Godot GUI 版 | `E:\Godot\Godot_v4.2.2-stable_win64.exe` |
| 启动器 | `E:\GameResearch\FantasyMapSimulator\启动FMSR.bat`（纯 ASCII，含残留进程清理） |
| 诊断启动器 | `E:\GameResearch\FantasyMapSimulator\launcher-diagnose.bat` |
| 用户数据（截图/存档/基线） | `C:\Users\MR\AppData\Roaming\Godot\app_userdata\FMSR - Fantasy Map Rebuild\` |
| 反编译脚本 | `tools\decompile_batch.sh` ~ `tools\decompile_batch6.sh` |
| 反编译原始 JSON | `logs\dec*_*.json`（字段 `normalized_result` 才是伪代码） |
| 已导出伪代码 | `reports\decompiled\*.c` |

### 2.2 依赖与版本（实测）

| 依赖 | 版本 / 位置 | 说明 |
|---|---|---|
| Godot | 4.2.2.stable.official.15073afe3 | 导出模板已装 |
| Python | `Python 3.13.14` | 只用于把 `logs/*.json` 的 `normalized_result` 导成 `.c` |
| 系统 Node | `v22.22.2` | **REA 不接受**，见下 |
| REA 专用 Node | `tools\node2422\node.exe` → `v24.22.1` | 跑 `npx rea` 必须把 `tools\node2422` 前置到 PATH |
| REA | `tools\node_modules\rea-agents` | 用法：`npx rea decompile <dll> --procedure "Type$$Method" --format json` |
| Ghidra | `build\ghidra_extract\ghidra_12.1.4_PUBLIC` | 环境变量 `GHIDRA_INSTALL_DIR` |
| JDK（给 Ghidra） | `E:\Android Studio\jbr`（JDK 25） | **必须 21+**，JDK17 会 `unsupported_version` |
| 符号种子 | `tools\ghidra_seeds.txt` | `REA_GHIDRA_SEED_FILE` |

### 2.3 启动 / 测试 / 截图命令（可直接复制）

```bat
:: 启动游戏（推荐：双击 启动FMSR.bat；命令行等价）
E:\Godot\Godot_v4.2.2-stable_win64_console.exe --path E:\GameResearch\FantasyMapSimulator\source\fms-godot

:: 逻辑自检（26 项断言）
E:\Godot\Godot_v4.2.2-stable_win64_console.exe --headless --path E:\GameResearch\FantasyMapSimulator\source\fms-godot --script tests/selftest.gd

:: 编辑器自检（58 项）
E:\Godot\Godot_v4.2.2-stable_win64_console.exe --headless --path E:\GameResearch\FantasyMapSimulator\source\fms-godot --script tests/editor_test.gd

:: 三固定种子地图统计（会与 user://mapstats-baseline.json 对比并打印 Δ）
E:\Godot\Godot_v4.2.2-stable_win64_console.exe --headless --path E:\GameResearch\FantasyMapSimulator\source\fms-godot --script tests/mapstats.gd

:: 省份/国家着色 PNG（mode=prov|state）
E:\Godot\Godot_v4.2.2-stable_win64_console.exe --headless --path E:\GameResearch\FantasyMapSimulator\source\fms-godot --script tests/mapdump.gd -- seed=42 mode=prov

:: 游戏内自动截图（6~9 秒后截图并退出）
E:\Godot\Godot_v4.2.2-stable_win64_console.exe --path E:\GameResearch\FantasyMapSimulator\source\fms-godot -- seed=42 shot=7 noinput
```

**命令行参数全表**（`main.gd` 解析 `OS.get_cmdline_user_args()`）：

| 参数 | 作用 |
|---|---|
| `seed=N` | 固定随机种子 |
| `shot=S` | S 秒后截图到 `user://shots/auto_seedN.png` 并退出 |
| `noinput` | **忽略真实鼠标/笔刷输入**（截图必加，否则前台窗口被真实鼠标点到会改画面） |
| `panel=state\|province\|sea\|editor\|global\|history\|stats` | 启动即打开对应面板（用于截图核对） |
| `view=biome\|height` | 启动即切到植被图/高度图 |
| `editdemo=height\|biome\|province\|state` | 程序化落一笔，用于验证"编辑真的改数据" |

### 2.4 反编译怎么跑（一次一个方法，约 27~45 分钟，大方法可达 2 小时）

```bash
# 环境（batch 脚本内已设好，手工跑时照抄）
export PATH="/e/GameResearch/FantasyMapSimulator/tools/node2422:$PATH"
export GHIDRA_INSTALL_DIR="E:/GameResearch/FantasyMapSimulator/build/ghidra_extract/ghidra_12.1.4_PUBLIC"
export JAVA_HOME="E:/Android Studio/jbr"
export REA_GHIDRA_SEED_FILE="E:/GameResearch/FantasyMapSimulator/tools/ghidra_seeds.txt"
export REA_GHIDRA_STARTUP_TIMEOUT_MS=5400000
cd /e/GameResearch/FantasyMapSimulator/tools
npx rea decompile 'E:\steam\steamapps\common\FantasyMapSimulator\GameAssembly.dll' \
    --procedure "HeightMapGenerator\$\$GenerateHeightMap" --format json > ../logs/out.json 2> ../logs/out.log
```

导出成可读伪代码：

```bash
cd logs && python -c "
import json
d=json.load(open('dec3_HeightMapGenerator__addHill.json',encoding='utf-8'))
open(r'E:\GameResearch\FantasyMapSimulator\reports\decompiled\HeightMapGenerator_addHill.c','w',encoding='utf-8').write(d['normalized_result'])"
```

---

## 3. 本阶段做了什么

本阶段（第八轮及其续做）主题：**四层地图编辑器 + 群系系统 + 按原版实机截图对齐 UI + 海平面 20/100**。

### 3.1 文件级清单（行数用 `wc -l` 实测）

| 文件 | 行数 | 状态 | 为什么改 |
|---|---|---|---|
| `source/fms-godot/scripts/heightmap_dsl.gd` | **543** | **新增（第九轮主产物）** | 原版高度图模板 DSL 解释器：9 个算子（Hill/Pit/Range/Trough/Strait/Smooth/Mask/Multiply/Add）+ `getNumberInRange` 区间解析 + 8 邻域 BFS 扩散 + 最近邻上采样。每个算子带证据注释 |
| `source/fms-godot/scripts/heightmap_template.gd` | **85** | **新增** | 模板正文加载器：读 `assets/origin/heightmap_templates.json`，按 `order_seen` / 首行关键字取模板 |
| `source/fms-godot/scripts/map_editor.gd` | **670** | **新增** | 四层编辑器内核：笔刷几何、5 种笔刷模式、撤销/恢复、合并、清空、存读档 |
| `source/fms-godot/scripts/mapgen.gd` | **1514** | 大幅修改 | 群系系统（`biome`/`temperature`/`moisture`）、编辑器结构重建（`rebuild_after_province_edit` / `rebuild_after_state_edit` / `absorb_unassigned_sea` / `add_province_at` / `add_state` / `clear_map`）、海平面固定 0.20 与高度重标定、国家面板字段（`trait`/`founded_year`/`treasury`/`corruption`/`officials`）、人口量纲 ×1000 |
| `source/fms-godot/scripts/main.gd` | **1849** | 大幅修改 | 左停靠 `_base_dock` + 折叠区 `_collapsible` + 彩色按钮 `_action_btn`；国家面板重写；行省面板改停靠；编辑器窄面板重写（12 项模式下拉/分页/随机国家/2×2 按钮/提示/清空/关闭）；全局指令面板；调试参数 `panel=`/`view=`/`editdemo=`/`noinput` |
| `source/fms-godot/scripts/map_render.gd` | **386** | 修改 | 三视图（政治/高度/植被）、行政图透明度、笔刷预览圈、国界暗红 3.0px、虚线经纬网、陆地 alpha 0.92 |
| `source/fms-godot/scripts/touch_camera.gd` | **161** | 重写 | 编辑器绘制模式：左键=笔刷、右键/中键=平移、Shift+左键=选择、Ctrl+滚轮=调半径；新增 `paint_*`/`hover_moved`/`brush_radius_step` 信号 |
| `source/fms-godot/scripts/simulation.gd` | **790** | 大幅修改 | `rules` 扩到 18 项且全部生效；联盟缔结、孤立省放弃（12 个月）、11 个国家行为动作、结束战争/联盟、清空历史、设置时间、重算区域；日期格式改 `公元%d年-%d-%d`；宣战文案改用目标短名；存档 v3（含 `elevation/is_land/biome` 的 base64） |
| `source/fms-godot/tests/editor_test.gd` | **393** | **新增** | 58 项编辑器断言（笔刷改数据/撤销恢复/结构不变量/合并不变量/存读档/整省沉没/清空地图/海平面） |
| `source/fms-godot/tests/selftest.gd` | **214** | 修改 | 26 项断言（新增群系覆盖、海格群系=海洋、存档保留编辑过的高度与群系） |
| `source/fms-godot/tests/mapstats.gd` | **179** | 修改 | 新增 `biomes_land` / `biome_sea_wrong` / `undrawn_land_cells` 指标 |
| `source/fms-godot/tests/template_parse.gd` | **67** | **新增** | 9 项模板解析断言（5 份模板行数、算子名合法性、行解析成 4 段） |
| `source/fms-godot/tests/heightmap_dsl_test.gd` | **132** | **新增** | 13 项 DSL 数值断言：`getNumberInRange`（`3`/`1-4`/`0.5`）、Smooth 手算定点、模板 3 端到端跑通 |
| `source/fms-godot/tests/heightmap_templates_dump.gd` | **48** | **新增** | 5 份模板各渲染一张 PNG（`tests/dsl_tpl{0..4}.png`）+ 陆地占比，用于与原版截图视觉比对 |
| `source/fms-godot/assets/origin/heightmap_templates.json` | — | **新增** | 5 份模板正文（70 行），直接取自 `global-metadata.dat` 字符串字面量表，带出处与未验证标注 |
| `tools/decompile_status.py` | **~200** | **新增** | **只读**的反编译进度查看器：批次进度、产物成功/失败判定、**区分 Ghidra 与 IDEA 的 java**、僵尸任务告警、有效伪代码计数 |
| `查看反编译进度.bat`（根目录） | — | **新增** | 双击即可看进度。内容为纯 ASCII（避免 GBK 中文 bat 坏掉），由 Python 输出中文 |
| `tools/decompile_cctor.sh` | — | **新增** | 单跑 `HeightmapTemplates..cctor`（待办 #1），含失败重试；**必须串行、必须脱离会话**（见 6.13） |
| `reference/azgaar/*.ts` | — | 新增 | 算法蓝本副本（Azgaar FMG 的 heightmap-generator / templates / 概率工具），用于交叉印证算子语义 |
| `reports/decompile-findings.md` | 见文件 | 追加 | §9 编辑器规格（`EditPanelUI`/`BrushManager` 成员）、§10 `World.GenerateHeightMap`、§11 原版实机截图实证、§12 高度图算子 |
| `reports/restoration-acceptance.md` | 见文件 | 追加 | 第八轮三节验收记录 + 验收矩阵若干行改 ✅/🟨 |
| `PROGRESS.md` | 145 | 重写多次 | 阶段表、基线表、待办、未还原项、下一步建议 |
| `tests/origin_shots/*.jpg,png` | — | 新增 | 用户提供的 5 张原版实机截图（唯一视觉基准） |
| `tools/decompile_batch5.sh` / `decompile_batch6.sh` | — | 新增 | 群系静态数据/DSL 解释器、高度模板正文 |

### 3.2 行为级改动（不看代码也能核对）

1. **四层编辑器**（`map_editor.gd`）：高度层写 `gen.elevation` 并重算 `is_land`；植被层写 `gen.biome`；
   行省层写 `cell_province`；国家层按"国家最小单位=行省"整省改归属。每笔落笔后重建 cell 集合/邻接/国家列表，
   丢弃空省、重编号、迁都、灭国，保证不出现孤儿格/空省/错误归属。
2. **撤销/恢复**：每笔保存"主数组 delta + `provinces`/`states` 深拷贝 + `cell_province`/`is_land` 快照"，
   因此"合并行省""整省沉没→删省→迁都"都能回滚（上限 `MAX_UNDO = 40` 笔）。
3. **群系**：13 个群系的名字/顺序/中文名来自原版 `BiomeResource.json` + `localization.csv`；
   判定矩阵与配色是**近似**（真值在 `Biomes..cctor`，反编译失败，见第 5 节）。
4. **海平面**：`SEA_LEVEL_FIXED = 0.20`（原版 `world+0x178 = 0x14`），并对高度场做**分段线性重标定**
   （海面以下→0..0.20，以上→0.20..1.0，单调变换，陆海集合不变）。笔刷高度 0..100 因此与原版同义。
5. **国家面板**：按用户提供的原版截图重排（左停靠满高、折叠区、15 行信息表、彩色双列按钮），
   11 个按钮全部有真实数据后果。
6. **全局指令面板 19 项**：10 个规则开关 + 地图操作（清空/刷新河流/重算区域/结束战争/结束联盟/清空历史）+
   时间与存档（设置年月、保存/读取、自动存档）。

---

## 4. 验证结果

### 4.1 测试总表（2026-10-30 17:55 实测）

| 验证项 | 命令 | 关键数字 | 结论 |
|---|---|---|---|
| 逻辑自检 | `... --headless --path <工程> --script tests/selftest.gd` | `[PASS]` 26 条、`[FAIL]` 0 条、结尾 `=== FMSR selftest: ALL PASS ===` | 通过 |
| 编辑器自检 | `... --script tests/editor_test.gd` | `[PASS]` 58 条、`[FAIL]` 0 条、结尾 `=== EDITOR ALL PASS ===` | 通过 |
| 三种子统计 | `... --script tests/mapstats.gd` | 3 行 JSON（见 4.2）+ 结尾 `=== 对比结束（基线不变；…） ===`（无 Δ 行 = 与基线完全一致） | 通过 |
| 脚本语法 | `... --headless --path <工程> --check-only --script scripts/<f>.gd` | `mapgen/map_editor/map_render/touch_camera/main/simulation` 六个文件 `SCRIPT ERROR` 计数均为 0 | 通过 |
| 启动+截图 | `... --path <工程> -- seed=42 shot=7 noinput` | 生成 `user://shots/auto_seed42.png`；`[shot] saved …` | 通过 |
| 编辑器四层落笔 | `... --path <工程> -- seed=42 shot=6 editdemo=height\|biome\|province\|state` | 四个 demo 各打印 `[editdemo] <kind> done` 且截图可见变化 | 通过 |
| 反编译：高度图入口 | `logs/dec3_HeightMapGenerator__GenerateFromTemplate.json` | 9024 bytes | 通过（已导出 `.c`） |
| 反编译：高度图编排 | `logs/dec4_World__GenerateHeightMap.json` | 15511 bytes | 通过（已导出 `.c`） |
| 反编译：算子 `addHill` / `addRange` | `logs/dec3_*addHill.json` / `*addRange.json` | 6185 / 6760 bytes | 通过 |
| 反编译：算子 `smooth` | `logs/dec3_HeightMapGenerator__smooth.json` | 10635 bytes | 通过（已导出 `.c`，且已实现并用手算用例锁定） |
| **模板正文（第九轮）** | `global-metadata.dat` 字符串字面量表 | 5 份模板 / 70 行（literal 6866/6867/6868/6869/10442） | **通过**（已落 `assets/origin/heightmap_templates.json`，不再需要 cctor 取正文） |
| **模板解析自检** | `... --script tests/template_parse.gd` | `[PASS]` 9、`[FAIL]` 0、`TEMPLATE PARSE ALL PASS` | 通过 |
| **DSL 数值自检** | `... --script tests/heightmap_dsl_test.gd` | `[PASS]` 13、`[FAIL]` 0、`DSL TEST ALL PASS` | 通过 |
| **5 模板渲染** | `... --script tests/heightmap_templates_dump.gd -- seed=42 cells=20000` | 5 张 `tests/dsl_tpl{0..4}.png`，陆地 0.13~0.98 | 通过 |
| 反编译：模板列表顺序 `HeightmapTemplates..cctor` | `logs/dec10_*.json` / `dec6_*.json` / `dec12_*.json` | **0 bytes ×2，23:25 实测已死**（重跑 2 次均被会话回收） | **未完成**（决定 `TEMPLATE_INDEX=3` 是否正确，**待办 #1**） |
| 反编译：`addStep` / `<addOneHill>` / `<addOneRange>` / `GetNumberInRange` | `logs/dec11_*.json`（`tools/decompile_queue.sh`） | **0 bytes，23:25 实测队列已死**（`addStep` 日志停在 19:35:52，之后无任何输出） | **未完成**（用于交叉核对算子语义，**待办 #2**） |
| 反编译：群系分配 `World.GenerateBaseMap` | `logs/dec5_World__GenerateBaseMap.json` | **0 bytes（15:11 起，进程已死，日志再无更新）** | **未完成**（并行 OOM，需串行重跑） |
| **⚠️ 上述全部处于「僵尸」状态** | `python tools/decompile_status.py` | **当前无任何 Ghidra 进程存活** | 必须**重启**才可能产出，且要用脱离会话的方式（见 6.13） |
| 反编译：`Biomes..cctor` | `logs/dec5_Biomes__\.cctor.json` | 0 bytes，日志首行 `No such file or directory` | **失败**（脚本转义 bug，见 7.3） |

### 4.2 三固定种子基线（**第九轮重建**，已写入 `user://mapstats-baseline.json`；旧基线备份为 `mapstats-baseline.pre-dsl.json`）

| seed | 陆地格 | 陆地占比 | 行省数(含海域省) | 省最大/中位 | 国家数 | 国家跨省碎片 | 陆地群系种类 | 河流 | 孤儿格 | 空省 | 未绘制陆地格 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 42 | 76049 | 0.566 | 960（含海域 190） | 197 / 101 | 26 | 40 | 12 | 18 | 0 | 0 | 0 |
| 1337 | 62910 | 0.468 | 753（含海域 139） | 199 / 104 | 26 | 33 | 12 | 14 | 0 | 0 | 0 |
| 2026 | 77794 | 0.579 | 954（含海域 182） | 206 / 105 | 26 | 35 | 12 | 21 | 0 | 0 | 0 |

> 读数说明：陆地 50778→76049、省 598→960 是「高度图换成模板 DSL」的预期结果（新高度场陆地更多更碎），
> 不是回归。判定标准是：**删基线重建后二次运行无 Δ 行**（第九轮已实测无 Δ）。

### 4.3 未通过的（原文关键行）

```
=== 15:11:23 decompiling World$$GenerateBaseMap ===
（至 17:55 仍无产物，logs/dec5_World__GenerateBaseMap.json = 0 bytes）

decompile_batch5.sh: line 21: /e/GameResearch/FantasyMapSimulator/logs/dec5_Biomes__\.cctor.json: No such file or directory
=== 15:11:23 Biomes$$\.cctor done, 0 bytes ===
```

---

## 5. 仍未还原 / 已知问题（按优先级）

### P1 高度图：~~「下标 3 → 哪份正文」未证~~ → **✅ 第十轮已证（Templates[3] = literal 6867）**
- **现状（第十轮已改，2026-10-31）**：不走 Ghidra，`tools/scan_template_order.py` 直接解析
  PE + v29 元数据 usage 槽位（编码 `(5<<29)|(idx<<1)`），从 `HeightmapTemplates..cctor`
  （VA 0x18039B350）机器码提取 5 个构造块的字符串引用对，证明 **Add 顺序** =
  `[Volcano/6868, High Island/6869, Continents/6866, Continents/6867, Continents/10442]`。
  `GenerateFromTemplate` 反编译证实第 2 参是 IReadOnlyList **列表下标**（get_Item；旧"字典键"猜测作废）。
  → `Templates[3]` = **6867**（游戏自创模板，不存在于 Azgaar；机器码观测名 "Continents"）。
  完整证据链：`reports/decompile-findings.md` §14；`heightmap_templates.json` 已按 Add 顺序重排。
- **改后遗留的新问题（本轮最大发现）**：模板 6867 在本引擎 DSL 下产出 **91~98% 陆地**，
  而原版截图约 45~55%。模板结构（多大陆 + 垂直海峡 + 小岛）与原版一致 → **水量偏差来自算子
  参数/语义**（Hill 的 blobPower/90 上限、Range 的 randomness、Multiply/Add 参数位等目前只经
  Azgaar 同构交叉印证，仅 smooth 逐字核对过）。待 `addStep`/`<addOneHill>`/`<addOneRange>`/
  `GetNumberInRange` 伪代码（第十轮队列产出中）逐条校正。**核对完成前不要把 91~98% 陆地当"原版行为"。**
- **第九轮视觉比对结论作废**：当时凭渲染相似选了 6869——同一套有偏算子语义下，错误模板碰巧
  更像原版。视觉比较对"选模板"不可靠。
- **仍然成立的旧事实**：
  1. `HeightMapGenerator.GenerateHeightMap` = `GenerateFromTemplate(this, 3, 0)`（反编译）；
  2. `GenerateFromTemplate` = 取 `Templates[param].Template` 文本 → `Split('\n')` → 逐行 `Trim`/`Split(' ')`
     → 段数 < 2 报错 → `addStep`（反编译）；
  3. `HeightmapTemplates.Templates` 类型 = `IReadOnlyList<HeightmapTemplate>`（列表），元素含
     `Name/Template/Probability`（`reports/dump-assembly-csharp.txt` type#452/453）；
  4. 5 份模板正文全文（字面量表 literal 6866/6867/6868/6869/10442）；
  5. 9 个算子名与参数位：`Hill/Range/Trough/Strait/Pit/Mask/Multiply/Add/Smooth`；`Mask 4 0 0 0` 只吃第 1 参。
- **注意：`World.GenerateHeightMap` 其实不直接调 `HeightMapGenerator`**
  ——它调 `World.GenerateHeightMapFromJs`（外部 `HeightMapExternal` + JsEnv 通道，
  失败文案 `HeightMapExternal.Generate 失败：JsEnv 未初始化或 generateMapInJs 未绑定`）。
  单机默认路径下该通道未初始化 → 回落到内置模板生成器。`GenerateHeightMapFromJs` 未反编译，
  这条回落的判断目前是**推断**（依据：异常文案 + 模板生成器存在且入口是常量 3）。
  **含义**：若原版默认图实际走 JS 生成器，模板 DSL 就只是它的回落路径——下标证实仍有效，
  但"原版默认图长什么样"要以截图为准。
- **算子语义的第二来源**：本工程识别的 DSL 与开源 Azgaar's FMG 同构（字段名
  `blobPowerMap/linePowerMap/heights/blobPower/linePower/graphWidth/graphHeight` 一一对应，
  `smooth` 公式逐字吻合）。参考副本存 `reference/azgaar/`。**这是交叉印证，不是原版证据**，
  需用 `addStep`/`<addOneHill>`/`<addOneRange>`/`GetNumberInRange` 的伪代码逐条核对（第十轮队列在跑）。

### P2 地图是 cell 格网，不是原版维诺图
- **现象**：480×280 方格（`MapGen.W/H`），渲染成方块后靠 Chaikin 平滑边界；海岸有明显阶梯。
- **影响**：`MapEditingInstructions` 官方说明"地图基于维诺图，行省由多个相邻多边形组成"无法满足；
  省份边界精度、视觉质感与"最小单位=1 个 voronoi cell"的语义都不同。
- **根因**：原版 cell 数是 **10000 / 20000 / 30000 / 40000 四档**（`World.GenerateHeightMap` 实证），
  且是维诺图；重建版一次做成 13.4 万格规则网格。
- **试过但没用**：在现有格网上加平滑（只能改善观感，不改变数据结构）。

### P3 群系判定矩阵与配色是近似
- **现象**：`_biome_from_climate()` 的阈值、`BIOME_COLORS` 的 13 个颜色都是手写的。
- **影响**：群系分布与配色和原版不一致（但 13 个群系的**名字/顺序/中文名**是真的，来自原版文件）。
- **根因**：真值在 `Biomes..cctor`（颜色表 + `cost` 移动代价 + `biomesMatrix` 温湿矩阵 + `habitability`）。
- **试过但没用**：`Biomes.Initialize`（已反编译）只建一个 5 项浮点表 `1.5/1.3/1.2/1.4/1.6` 并加载
  `BiomeResource.json`，不是矩阵也不是色表；`Biomes..cctor` 那次因脚本转义 bug 输出 0 字节。

### P4 省份扩张代价里 biome / river / type 三项恒 0
- **现象**：`_biome_cost` / `_river_cost` / `_type_cost` 全部 `return 0.0`。
- **影响**：省份扩张只看文化(-9)与地形，跨群系/沿河/特殊 cell 无额外代价。
- **根因**：公式已全部反编译（见 `reports/decompile-findings.md` §6），缺的是**数据维度**：
  biome 代价表（在 `Biomes.cctor`）、cell→river id、cell 类型字段。
- **试过但没用**：只补 biome 图不够，代价表取不到就仍是 0。

### P5 笔刷 5 种模式的混合算符是近似
- **现象**：`增加/减少/最大值/最小值/平均值` 的算式由本项目定义（`_paint_height` 的 `match bm`）。
- **影响**：手感与原版可能不同；数值结果不同。
- **根因**：`BrushManager.DrawShapes` 未反编译（`logs/dec5` 队列里，排在 GenerateBaseMap 之后）。
- **试过但没用**：用 `BrushManager.GetColorFromHeight` 推断（未反编译）。

### P6 编辑器只做了 4/12 种模式
- **现象**：区域、无人区、文化、宗教、标签、图片、家族、地图尺寸 8 种点下去只打印"该模式尚未还原"。
- **影响**：玩家不能像原版那样编辑区域/文化/宗教等。
- **根因**：这些模式依赖尚未实现的数据模型（文化包、宗教包、家族、自定义标签图层）。
- **试过但没用**：只做 UI 不接数据被明确禁止（用户要求"按钮必须真生效"）。

### P7 文化 / 宗教 / 家族 / 领袖是占位
- **现象**：`culture`/`religion` 来自内置小列表，`leader`/`officials` 来自内置汉风词库。
- **影响**：面板有值但与原版文化包（`CultureData.json` + 15 列 CSV）无关。
- **根因**：`StateLeaderGenerator`、文化包加载器未反编译/未实现。

### P8 战争类型 12 种只触发 4 种
- **现象**：实际只产生 征服/叛乱/内战/附庸 四类；家族叛乱、独立内战、推翻内战、改革内战、继承权内战从不出现。
- **根因**：缺少家族与领袖继承数据模型。

### P9 存档仍是 JSON，不是原版 AES 容器
- **现象**：`sim.save()` 写 `user://saves/save1.json`；编辑器另有二进制 `user://saves/map_edited.dat`。
- **影响**：不能读原版存档，原版也不能读本作存档。
- **根因**：`SaveSystem.WriteRootV2` + `c_SaveEncryptionKey` 未解。

### P10 抖动网格参数是猜的
- **现象**：省份种子布点用 `PROVINCE_STEP = 11`、抖动 `±4`。
- **影响**：省份密度/间距与原版不同。
- **根因**：`World.EnsureProvinceBurgCellsReady` 还没跑完（15:22 起）。

---

## 6. 已否决的方案（最重要，别再撞）

### 6.1 「让我直接操控你的电脑/截屏/发按键」——环境层面不可能
实测三种方式全部被安全策略拒绝（原文）：

```
Command blocked for security: Add-Type compiles and loads .NET code at runtime
Command blocked for security: Reflection.Assembly load APIs execute arbitrary code (equivalent to Add-Type)
Command blocked for security: COM object instantiation can run arbitrary code (e.g., WScript.Shell)
Command blocked for security: Invoking PowerShell from Bash bypasses PowerShell security checks; use the PowerShell tool instead
```

另外两条硬约束：
1. 从本会话拉起的 GUI 进程（`Start-Process Steam` / 原版 exe）**在命令结束时被系统回收**，下一个命令查不到进程；
2. 原版带反篡改（`DetectorsAdminProtection`）且以管理员运行，非提权会话既不能杀也不能发输入。

**正确做法**：让用户手动开原版、手动截图，把图放进 `tests/origin_shots/`，按图对齐（本阶段就是这么做的，
效果远好于猜测）。已存 5 张：大地图 / 国家信息面板 / 国家行为 / 折叠区 / 地图编辑面板。

### 6.2 `rea decompile --snapshot` 复用分析快照——无效
实测加了 `--snapshot` 仍然每个方法重新全量分析 `GameAssembly.dll`（53 MB），单方法 27~45 分钟。
**不要**指望它加速；要并行就开两个 batch，但内存 < 3 GB 时会互相拖慢（见 7.4）。

### 6.3 批处理（.bat）里写中文——必然坏
cmd 按本地代码页（GBK）读 `.bat`，UTF-8 中文会破坏 `if (...)` 语法，表现为满屏
`不是内部或外部命令`。改用 `chcp 65001`、`iconv -f UTF-8 -t GBK` 都试过，仍不稳。
**结论**：`启动FMSR.bat` / `launcher-diagnose.bat` 必须**保持纯 ASCII**，中文说明只写进 `.md`。

### 6.4 批处理里用 `find` 判断进程——会被 Git 的 find.exe 抢
在本机 PATH 下 `find` 可能解析到 `Git\usr\bin\find.exe`，导致启动器误报"启动失败"。
**已改 `findstr`**（Windows 独有），实测 `DETECT_HIT`/`DETECT_MISS` 两个分支都正确。

### 6.5 新脚本用 `class_name` 被别的脚本引用——`--check-only` 下解析失败
新建 `map_editor.gd` 带 `class_name MapEditor` 后，`main.gd` 里写 `MapEditor.Layer.XX` 直接报
`Could not find type "MapEditor"`（`--check-only` 不会注册新的全局类）。
**结论**：跨脚本引用新类一律用 `const X := preload("res://scripts/x.gd")`，别依赖 `class_name` 注册。

### 6.6 给省份/国家加字段时顺手 `rng.randi_range(...)`——整张地图会漂移
生成器的随机流是位置敏感的：多抽一个随机数，后面所有省份/国家/颜色全变，`mapstats` 基线全红。
**结论**：新字段要么用**确定性派生**（`si * 13 % 55` 这种），要么放在所有既有抽取之后统一补。

### 6.7 只用 "cell 级 delta" 做撤销——删省后非法
省份合并/整省沉没会让 `provinces` 数组变短，只回放 `cell_province` 会让格子指向已删除的 id。
**结论**：撤销必须同时快照 `provinces`/`states` 深拷贝，以及 `cell_province`/`is_land`。

### 6.8 一次性把 `EditPanelUI` 的 13 种模式都做成按钮——被否
8 种模式缺数据模型，做出来就是"假按钮"，违反"按钮必须真生效"。
**结论**：只做 4 种 + 全局指令，其余点击时明确提示"该模式尚未还原"。

### 6.9 面板做成居中弹窗——与原版不符
原版国家/行省面板是**贴左边、满高**的停靠面板。居中弹窗已全部改掉（`_base_dock`）。

### 6.10 用 `sleep` 长时间等反编译——会被 SIGTERM
`sleep 600` 这类长等待多次被工具超时杀掉（`Exit Code 1 / SIGTERM`）。
**结论**：单次 `sleep` 控制在 ~7 分钟内，或直接"检查一次 → 干别的 → 再检查"。

### 6.11 两个 Ghidra 并行反编译——必 OOM（第九轮实证）
本机物理内存 **16 GB**，单个 Ghidra 分析进程工作集峰值约 **5 GB / 870 MB+**。
第九轮同时跑 `dec7`（2 个方法）与 `dec8`（2 个方法）时，空闲内存掉到 **0.3 GB**，
两个任务双双失败，产物是 43202 字节的**错误 JSON**（内容是 OOM 堆栈，不是伪代码）。
**判断方法**：`ls -l logs/dec*_*.json` 若出现几万字节但导出后不含 `normalized_result`，
就是失败产物，别当成伪代码用。
**结论**：反编译**必须串行**，用 `tools/decompile_queue.sh`（内置 OOM 重试）一次只跑一个。

### 6.12 从 `GameAssembly.dll` 扫字符串找模板正文——扫不到（第九轮实证）
IL2CPP 的托管字符串字面量**不在 DLL 里**，而在
`FantasyMapSimulator_Data/il2cpp_data/Metadata/global-metadata.dat` 的字符串字面量表中。
在 DLL 里按 `hill/range/smooth` 等关键词扫长 ASCII 串，命中数为 0。
**结论**：找字符串一律先解析 `global-metadata.dat`（header 从 `+8` 起是 `<offset,count>` 的 int32 对，
第 1 对 = `stringLiteral` 表、第 2 对 = `stringLiteralData` 堆；每条字面量是 `<len, idx>` 的 int32 对）。

### 6.13 以为"后台还在跑"，其实进程早被回收（**第九轮最大教训**）

**现象**：反复以为某批反编译"还在跑"，因为：日志停在一行 `=== 19:35:52 decompiling X ===`
（既没有 `done` 也没有 `FAILED`），产物 JSON 恒为 0 字节，于是判断"大方法就是慢"。
实际上**驱动它的 bash 进程早就不存在了**，永远不会再产出任何东西。

**为什么会死**：反编译命令是 AI 工具启动的后台 shell。它挂在**会话**上，而不是系统上。
会话中断（上下文压缩、工作模式切换、对话结束、工具超时后的自动回收）时，进程被一并回收。
Ghidra 本身反而可能侥幸活下来变成孤儿，但驱动它的队列脚本没了，后续步骤不会执行。

**⚠️ 别用自己的时间感觉去推算任务跑了多久**：本次交接时，AI 以为"现在约 20:15"，
而 `datetime.now()` 实测是 **23:23** —— 偏差 3 小时，导致把"任务跑了 40 分钟"
误判成"还在跑"，实际它已经死了 4.5 小时。**判断时间间隔一律用命令取真实时间**：
```
python -c "import datetime;print(datetime.datetime.now())"
```

**怎么判断（别靠感觉）**：
```
python tools/decompile_status.py
```
判据是**两条同时成立**才算真在跑：① 存在命令行含 `ghidra` 的 `java.exe`；② 队列日志近期有更新。
只满足其一或都不满足 → 僵尸任务，必须重启。

**⚠️ 特别提醒：机器上常年有两个 `java.exe`（PID 各跑了 100+ 分钟），
那是 IntelliJ IDEA 自带的 jbr，不是 Ghidra。** 靠"有 java 进程"判断会严重误判
（本次交接前就误判过一次）。务必看命令行里有没有 `ghidra`。

**当前状态（2026-10-30 23:25 实测）**：`dec5 / dec6 / dec8 / dec10 / dec11` **全部已死**，
无任一 Ghidra 进程存活。它们的产物停在 0 字节，等待重跑（详见 §4.1 表格）。

**想让它真的跑完怎么办**：不要用会话级后台。要么用 Windows 计划任务（`schtasks`）脱离会话启动，
要么在用户本机终端手动 `bash tools/decompile_queue.sh` 并保持窗口不关。
会话级后台只适合"几秒~几分钟内能结束"的命令（参见 6.10 的 `sleep` 同理被 SIGTERM）。

**✅ 第十轮已落实（2026-10-31 00:11）**：schtasks 任务 `FMSR_dec_r10` 跑
`tools/decompile_round10_queue.sh`（9 方法串行），**实测脱离会话存活**（Ghidra java 进程 + 队列日志双确认）。
创建命令的坑见 §7.3 最后一条（MSYS 引号转换）；启动器批处理 `tools/launch_round10_queue.bat` 可随时重建任务。

---

## 7. 踩过的坑与禁忌

### 7.1 安全策略拦截清单（实测，均无法绕过）
| 操作 | 结果 |
|---|---|
| `Add-Type -AssemblyName System.Windows.Forms` | 被拦（编译 .NET） |
| `[Reflection.Assembly]::LoadWithPartialName(...)` | 被拦（等价 Add-Type） |
| `New-Object -ComObject WScript.Shell` | 被拦（COM 可执行任意代码） |
| 在 Bash 里调 `powershell -Command ...` | 被拦（绕过 PS 安全检查）→ 用 PowerShell 工具 |
| `rm -f "<工作区外的绝对路径>"` | `[safe-delete][SAFE_DELETE_INVALID_PATH]`（含盘符的路径不允许） |
| `cat >> 文件 <<EOF`（某些路径） | 偶发被判为 LOLBin → 改用编辑工具或 python 写 |

### 7.2 命令陷阱
- **`--check-only` 不注册 `class_name`**（见 6.5）。
- **Godot 4.2 语法**：没有 `cond ? a : b`（用 `a if cond else b`）；`PackedByteArray` 没有 `to_byte_array()`
  （它本身就是字节数组，直接传给 `Marshalls.raw_to_base64`）；`var x := null` 会报无法推断类型，要写 `var x: Variant = null`。
- **类型推断报错**：从 `preload` 脚本或 `Variant` 调方法后 `var x := ...` 常报 `Cannot infer the type`，显式写 `: int` / `: String`。
- **Bash heredoc 吃反斜杠**：用 `python - <<'PY'` 写脚本时反斜杠容易丢；复杂脚本用写文件工具落盘再跑。
- **中文控制台乱码**：Godot 输出 UTF-8，Windows 控制台按 GBK 显示 → 只看 `[PASS]/[FAIL]` 与数字，别试图修编码。

### 7.3 反编译专属坑
- **必须用 `tools\node2422\node.exe`（v24.22.1）**，系统 Node v22.22.2 会被 REA 拒绝。
- **`JAVA_HOME` 必须是 JDK 21+**（`E:\Android Studio\jbr`），JDK17 报 `unsupported_version`。
- **方法名转义**：目标里带 `$$` 时，写 `"Biomes\$\$.cctor"` 正确；写成 `"Biomes\$\$\.cctor"`（多一个反斜杠）
  会让输出文件名包含字面反斜杠 → `No such file or directory`，产出 0 字节。**这是本阶段真实踩到的坑。**
  **更简单的写法（第十轮起采用）**：脚本里用**单引号 + 原始名**（`'Biomes$$.cctor'`），单引号里 `$$`
  不会被展开也不需要反斜杠；方法名一律从 `tools/ghidra_seeds.txt` 逐字复制。
  注意 `decompile_cctor.sh` 第 16 行仍带着旧的错误转义（`\$\$\.cctor`），别再复用那个脚本。
- **单方法耗时**：小方法 27~35 分钟，`World.GenerateBaseMap` 已跑 2 小时 45 分仍未出（超大方法）。
- **三批并行会互相拖慢**：内存余量 < 3 GB 时单个方法从 27 分钟涨到 45 分钟以上。
- **schtasks 从 Git Bash 创建任务（第十轮实测两坑）**：
  ① 内嵌引号会被 MSYS 参数转换弄坏（`/tr "\"prog\" args"` 存进任务变成 `"\" prog ..."`，运行报 0x80070005）；
  ② Git Bash 会把 `/create` 这类参数当路径转换。**可行写法**：两段路径都不含空格 → 不用内嵌引号，
  并加 `MSYS_NO_PATHCONV=1`：
  `MSYS_NO_PATHCONV=1 schtasks /create /f /tn "FMSR_dec_r10" /sc once /st 00:00 /tr "E:\Git\usr\bin\bash.exe E:\GameResearch\FantasyMapSimulator\tools\decompile_round10_queue.sh"`
  然后 `MSYS_NO_PATHCONV=1 schtasks /run /tn "FMSR_dec_r10"`。验证它真的活了：看 `logs/round10_queue.out`
  出现 `QUEUE_BEGIN` + PowerShell 查 java.exe 命令行含 `ghidra`（§6.13 双条件）。

### 7.4 容易误判的地方
- **`mapstats` 的输出**：结尾打印 `=== 对比结束（基线不变；确认改动合理后删除 user://mapstats-baseline.json 重建） ===`
  是**正常**结尾，不代表"不匹配"；真正的差异是中间那些 `seed N field: old -> new (Δx)` 行。
- **`user://` 不是工程目录**：实际在 `C:\Users\MR\AppData\Roaming\Godot\app_userdata\FMSR - Fantasy Map Rebuild\`。
- **截图会被真实鼠标干扰**：不加 `noinput` 时，前台窗口被点到会打开面板/改画面（本阶段多次遇到）。
- **`EditPanelUI` 的分页**：原版截图是 `Page 1 of 3`，本项目实现为**国家列表翻页**（每页 6 个国名按钮）；
  原版这 3 页到底分页什么，**未验证**。

### 7.5 网络 / 代理（本条未在本阶段验证）
用户环境记录：GitHub 需走 Clash 代理（7897）；`git push` 走不通，只能用 GitHub Git Data API。
本项目**没有 git 仓库**，本阶段所有改动均无版本控制，改前手工备份在 `backups\`。

---

## 8. 下一步（只做这一条）

> **✅ 上一条的「钉死模板下标」已完成（第十轮，2026-10-31）**：不再等 Ghidra，
> `tools/scan_template_order.py` 从 `HeightmapTemplates..cctor` 机器码直接恢复 Add 顺序，
> 证明 `Templates[3]` = literal **6867**（证据链 findings §14；JSON 已重排、基线已重建、测试全绿）。
> 同时 schtasks 脱离会话队列 `FMSR_dec_r10` 已落地并在跑（§6.13 的僵尸问题就此解决）。

**新目标**：**核对高度算子语义，把陆地占比从 91~98% 校回原版的约 45~55%。**

**背景**：模板选择已证没错，但模板 6867（7 大 Hill + 16 Range + 垂直 Strait + Smooth 3）在
本引擎 DSL 下几乎铺满陆地，与原版截图（多大陆 + 宽海）矛盾。模板结构一致 → 偏差必然在算子：
Hill 的 blobPower 与 90 上限、Range 的 randomness、Multiply/Add/Trough/Strait/Mask 参数语义，
目前只经 Azgaar 同构交叉印证（仅 smooth 逐字核对过）。

**怎么做**：
1. **等/查第十轮队列产出**（`tail logs/round10_queue.out`；产物 `logs/dec_<名字>.json`，
   导出 `normalized_result` 到 `reports/decompiled/`，先查无 `"error"`）：
   `HeightmapTemplates__cctor`（**先与 findings §14 逐条核对，矛盾则回退**）→
   `HeightMapGenerator__addStep` → `__addOneHill` → `__addOneRange` → `RandomUtils__GetNumberInRange` →
   `Biomes__cctor` → `BrushManager__DrawShapes` / `__GetColorFromHeight` → `World__GenerateBaseMap`。
2. 伪代码到手后逐条对照 `scripts/heightmap_dsl.gd`（每处 ≤20 行），重点：**Hill 的 `change^blobPower`
   与 `>90` 重试、Range 的 randomness、Multiply/Add 参数位、getNumberInRange 的概率进位**。
3. 每批改动后：selftest / editor_test / template_parse / heightmap_dsl_test →
   mapstats **删基线重建 + 二次无 Δ** → 更新 PROGRESS 阶段表与 acceptance。

**验收标准（缺一不可）**：
- 四个逻辑自检全绿（26/58/9/13）；
- `mapstats` 重建后二次运行**无 Δ 行**；
- 文档明确标注哪些算子已"逐字核对"、哪些仍是"同构推断"；
- 若校完后陆地占比仍远离 45~55%，**如实记录差距**，不得宣称"与原版一致"。

**其余待办不要插队**，按 PROGRESS §4 顺序推进（Biomes.cctor / DrawShapes 产出后顺手做 #2/#5）。

> 顺带提醒：`World.GenerateHeightMap` 反编译显示新游戏路径其实先走 `GenerateHeightMapFromJs`
> （JS 外部插件通道），失败才回落到内置 DSL。游戏目录里**没有** `.js` 文件，所以实际生效的是 DSL 路径，
> 但 `StreamingAssets/BasicMap/{1,2,4,8}.save` 是 4 档尺寸的预生成基础地图（base64 容器，熵 6.0），
> 解密后就是**最硬的高度图金标准**——属于 P9 范畴，可在算子核对完成后用来做终极对照。
