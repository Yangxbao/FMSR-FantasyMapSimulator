# FMSR 交接文档 V3（2026-11-01 02:20，第十二轮收尾：main.js 破译 + 全陆解除）

> **读者**：完全没有上下文的接手者（含其他 AI）。读完本文即可直接接手。
> **前置文档**（按需查，不冲突）：`HANDOVER-V2.md`（上一轮全景）、`reports/decompile-findings.md`
> （§15.31–37 为本轮证据链）、`reports/gameplay-inventory.md`、`PROGRESS.md`。
> **冲突时以本文为准**。V2 的「全陆中间态」等表述已过时。

---

## 0. 立即行动清单（新窗口接手者照抄即可）

```bash
cd /e/GameResearch/FantasyMapSimulator

# 0.1 检查夜间队列是否完成（round12 + round13）
tail -3 logs/round12_queue.out
tail -3 logs/round13_customloader.out
# 两行都看到 QUEUE_DONE = 完成；否则等待或按 V2 §10 的 WMI 方式续跑

# 0.2 导出夜间新伪代码（dec12_* / dec13_* 中未导出的）
python -c "
import json,glob,os
for f in sorted(glob.glob('logs/dec12_*.json')+glob.glob('logs/dec13_*.json')):
    stem=os.path.basename(f).replace('.json','')
    if os.path.exists('reports/decompiled/%s.c'%stem): continue
    try:
        d=json.load(open(f,encoding='utf-8'))
        nr=d.get('normalized_result','')
        if len(nr)>500 and '\"error\"' not in nr[:200]:
            open('reports/decompiled/%s.c'%stem,'w',encoding='utf-8').write(nr)
            print('OK',stem,len(nr))
    except Exception as e: print('FAIL',f,e)
"

# 0.3 跑全量测试确认基线（应 154/154 全绿）
G="E:/Godot/Godot_v4.2.2-stable_win64_console.exe"
for t in selftest template_parse heightmap_dsl_test editor_test culture_religion_test \
         culture_system_test economy_test army_test army_battle_test; do
  P=$(timeout 300 "$G" --headless --path source/fms-godot --script tests/$t.gd 2>&1 | grep -acE "\[PASS\]")
  F=$(timeout 300 "$G" --headless --path source/fms-godot --script tests/$t.gd 2>&1 | grep -acE "\[FAIL\]")
  echo "$t: PASS=$P FAIL=$F"
done

# 0.4 收割 round12 产出（第一优先，见 §3 对照表逐项处理）
```

---

## 1. 本轮三大突破（全部 ★A 实证）

### 1.1 main.js 破译（原版地图生成器/游戏逻辑源码到手）

```
链条：main.js(TextAsset) = Base64( AES-256-CBC( JS明文 ) )
密钥：o7N@:5UwTW_>XV7_9E>~eoux7E7?Pn~t   （32 字节 UTF-8；SaveSystem 密钥的三字符变体）
IV  ：'0000000000000000'                   （16 个 ASCII '0'，不是零字节！）
算法：Aes.Create() 默认 = CBC + PKCS7（CustomLoader.DecryptString 反编译逐字）
明文：372,646 字节 → extracted_js/main.dec.js（8054 行，未混淆仅压缩）
工具：tools/decrypt_mainjs.py（脚手架）、tools/bruteforce_mainjs_key.py（穷举命中）
```

解密入口的定位过程（重要教训）：`Puerts.DefaultLoader.ReadFile` 是**原版无修改**（Resources.Load
→ TextAsset.text 原样返回）；真正的解密在游戏自定义的 **`CustomLoader`（type 439）**——
元数据用 `npx rea inspect-il2cpp-metadata <global-metadata.dat>` 解析（快、不开 Ghidra）找到的。

### 1.2 JS 权威终审 → DSL 修正 → 全陆解除

- 权威 = **JS HeightmapGenerator**（main.dec.js L1722 起）；C# HeightMapGenerator 是并行副本，
  若干公式与 JS 不同（C# 的 rand+0.85、>4.0 写回阈值都是副本差异，**不采纳**）。
- 修正清单（详见 findings §15.36/37）：
  hill Uint8 截断 + 全量写回（根因）；range/trough 因子 rand×0.3+0.85；blob[10000]=0.985；
  line 缺省 0.79；`_point` 改 JS 镜像语义（center + len/2 − rand(min·len,max·len)）；补 invert。
- mapgen：模板切 **JS 库 continents**（C# Templates[3] 是编辑器列表变体，不在 JS 库）；
  **弃用 20000-cell 粗网格上采样**，全分辨率 480×280 直接生成。
- 实测：陆地 98-100% → **43.5%**（verdict）/ mapstats 三种子 0.522~0.539（原版 31.8~45.2%）。
- **测试基线 154/154 全绿**（V2 的 selftest 1 失败 + editor 5 失败全部解除）。

### 1.3 JS 里还有整个游戏（下一阶段的金矿）

generateMapInJs 后半段（L7780+）：markFeatures/markupGridOcean/openNearSeaLakes/defineMapSize/
calculateTemperatures/generatePrecipitation/**Rivers.generate**/**Biomes.define**，以及
`useJsStateProvinceCultureBurgGen` 开关下的 **Cultures/BurgsAndStates/Religions** 全套 JS 生成。
 Culture/Religion/Province/State/Burg 的 JS 源码就在 main.dec.js 里——**优先读 JS 而不是等反编译**。

---

## 2. main.js 速查（关键位置）

| 内容 | main.dec.js 位置 |
|---|---|
| aleaPRNG（原版随机流） | L1-60 |
| createTypedArray/rand/P/getNumberInRange/lim/minmax | L60-190 |
| **heightmapTemplates（45 模板）** | L193-1700（已提取 assets/origin/heightmap_templates_js.json） |
| **HeightmapGenerator（全部算子）** | L1722-2320 |
| d3range/d3scan/d3mean | L1442-1520 |
| generateMapInJs（入口/编排） | L7590-7790 |
| JS 全流水线（features/temp/prec/rivers/biomes/cultures/states） | L7790-7900+ |

---

## 3. 夜间队列收割对照表（round12/round13 产出 → 行动）

| 产出 | 行动 |
|---|---|
| dec13_CustomLoader_ReadFile / GetResourcePath | 证实 CustomLoader 双轨（磁盘明文/Resources 解密）→ findings 补记 |
| dec12_Puerts_FileExists / IsESM | 原版确认即可 |
| dec12_ModifyCells_b__0/b__1 | 编辑器笔刷公式（对照 §15.33 闭包布局；JS 侧 modify 已是权威） |
| dec12_PlaceHill_b__0 | 编辑器 PlaceHill |
| **dec12_Culture_Generate/Expand/DefineType/Select/GetDefault** | **文化真值 → 替换 culture_system.gd 的 ○ 代理（种子选址/扩张代价/孤岛回填）** |
| dec12_State_DetermineReligion | 宗教归属真值 → 修 religion 映射 |
| dec12_Leader_GenForState / GenAll | 领袖生成 → 实现 Leader 实体（姓名列在 assets/origin/Culture/*/CharacterFirstNames_*） |

注意：Culture/Religion/Leader 优先查 **main.dec.js 里的同名 JS 实现**（Cultures.generate/expand、
Religions.generate），C# 反编译用于交叉验证（两套都在，useJsStateProvinceCultureBurgGen 决定
新游戏用哪套；GenerateBaseMap 实测 = JS 高度图之后跑 C# CultureGenerator）。

---

## 4. 下一步（按优先级）

1. **收割 round12**（§3 对照表）——Culture/Religion/Leader 真值落地。
2. **模板池解析**：C# GenerateHeightMap 用两个模板池（5+7 个名字常量，list1 @ DAT_182ee3460 邻域，
   名字常量 DAT_182ebab10/ede180/e89890/efe7a0/ef6820 + e9ef70/e9f110×3/e9f1e0/e9f2b0/e9f040）。
   解析后把 mapgen 的 TEMPLATE_JS_NAME 占位改为「池内随机」。方法：反编译
   `FUN_180304090` 的调用点或用 il2cpp metadata usage 槽解析（tools/mdump.py 可续写）。
3. **维诺拓扑评估**：残差 52% vs 41.6% 来自方格 8 邻 hop 覆盖（(2d+1)² vs 维诺 ~3d²）。
   builtin_map_{1,2,4,8}.json 的 SerializablePos + Delaunay 邻接（Python 可烘焙）→ DSL 换邻接表。
   架构级改动，单独立项。
4. **省/国密度**：mapstats 显示 province_count 3577 / sea_provinces 2619（原版官渡省 1008、海省 0）。
   对照 BurgsAndStateGenerator_*（reports/decompiled/ 已有 13 个文件）+ JS BurgsAndStates 调参。
5. **河流/温度/降水/生物群系**：直接移植 JS（Rivers.generate/Biomes.define 等）。
6. 领袖/外交/内政（V2 §8 的二三优先不变）。

---

## 5. 当前代码状态

- 测试基线 **154/154 全绿**（详见 §0.3 命令输出；无预期失败项）；
- mapstats 基线已重建（seed42/1337/2026 land_ratio 0.539/0.524/0.522）；
- 截图验收通过（shots/auto_seed42.png：26 国 + 海峡 + 大陆结构）；
- 本轮代码变更：
  - `scripts/heightmap_dsl.gd`：hill 截断+全量写回、因子 0.3、blob/line 表值、_point 镜像、_invert；
  - `scripts/mapgen.gd`：JS 库模板 + 全分辨率生成（粗网格上采样弃用）；
  - `scripts/heightmap_template.gd`：load_js_library()；
  - `scripts/culture_system.gd`：孤岛回填（○ 待真值）；
  - 新资产：`assets/origin/heightmap_templates_js.json`（45 模板）；
  - 新测试：`tests/mainjs_verdict_test.gd`；
  - 新工具：`tools/decrypt_mainjs.py`、`tools/bruteforce_mainjs_key.py`、`tools/mdump.py`；
  - 备份：`backups/heightmap_dsl.gd.pre-mainjs`、`heightmap_dsl.gd.pre-round11b`；
- 队列脚本：`tools/decompile_round12_queue.sh`（夜间）、`tools/decompile_customloader.sh`（定向）。

---

## 6. 关键坑与纪律（V2 §10 全部继承，新增）

- **JS 权威原则**：C# 反编译与 main.dec.js 冲突时，**以 JS 为准**（游戏实际执行路径）；
  C# 伪代码标注的公式若与 JS 不同，是并行副本差异（rand+0.85、>4.0 阈值都是前车之鉴）。
- **CustomLoader 双轨**：StreamingAssets/JS 磁盘文件明文直读；Resources 里的 TextAsset 走
  DecryptString（Base64→AES-CBC）。密钥/IV 见 §1.1。
- **V2 §3 的旧结论对照表继续有效**；新增一条：
  「main.js 需要逆向 ReadFile 解密」→ 错：ReadFile 原版，解密在 CustomLoader.DecryptString。
- 文档链：findings §15.31–37 = 本轮全部证据；冲突以 findings + 本文为准。

---

## ⚠️ 新窗口接手者特别警告

1. **不要再调 blob/line 幂表**——它已经是 JS 逐字值；陆地占比残差来自拓扑（§4.3），不是幂表。
2. **修改 DSL 前先跑 mainjs_verdict_test**（tests/mainjs_verdict_test.gd，43.5% 基线）。
3. **文化/宗教/领袖的真值先查 main.dec.js**（Cultures/Religions/BurgsAndStates 对象），
   round12 的 C# 伪代码用于交叉验证——别像高度图那样被 C# 副本公式带偏。
4. 运行游戏：`E:\Godot\Godot_v4.2.2-stable_win64_console.exe --path E:\GameResearch\FantasyMapSimulator\source\fms-godot`
   或双击 `启动FMSR.bat`；截图：`-- seed=42 shot=8 noinput`。
5. 队列纪律（WMI 启动、监督者收割、不重复启动）照 V2 §2/§10。
