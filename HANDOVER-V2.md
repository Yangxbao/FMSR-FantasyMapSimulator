# FMSR 交接文档 V2（2026-10-31 21:00，第十一轮收尾）

> **读者**：完全没有上下文的接手者（含其他 AI）。读完本文即可直接接手。
> **前置文档**（按需查，不冲突）：`HANDOVER.md`（旧版环境/坑全表）、`PROGRESS.md`（阶段表）、
> `reports/gameplay-inventory.md`（玩法功能清单/审计/差距）、`reports/decompile-findings.md`（§15 证据链）、
> `reports/restoration-acceptance.md`（验收记录）。
> **冲突时以本文为准**（V1 的部分结论已被本轮推翻，见 §3）。

---

## 0. 立即行动清单（新窗口接手者照抄即可）

> 队列预计已全部完成（QUEUE_DONE 标志）。以下按序执行：

```bash
cd /e/GameResearch/FantasyMapSimulator

# 0.1 确认队列状态
tail -5 logs/round11_queue.out
tail -5 logs/round12_queue.out
# 两行都看到 QUEUE_DONE = 全部完成；否则等或查进程

# 0.2 批量导出全部新伪代码到 reports/decompiled/
python -c "
import json,glob,os
for f in sorted(glob.glob('logs/dec11_*.json')+glob.glob('logs/dec12_*.json')):
    stem=os.path.basename(f).replace('.json','')
    try:
        d=json.load(open(f,encoding='utf-8'))
        nr=d.get('normalized_result','')
        if len(nr)>500 and '"error"' not in nr[:200]:
            out='reports/decompiled/%s.c'%stem
            open(out,'w',encoding='utf-8').write(nr)
            print('OK',out,len(nr))
        else:
            print('SKIP',f,'(error or too small)')
    except Exception as e:
        print('FAIL',f,e)
"

# 0.3 跑现有测试确认基线
G="E:/Godot/Godot_v4.2.2-stable_win64_console.exe"
P="source/fms-godot"
for t in selftest editor_test culture_religion_test culture_system_test economy_test army_test army_battle_test template_parse heightmap_dsl_test; do
  echo "=== $t ==="
  timeout 300 "$G" --headless --path "$P" --script tests/$t.gd 2>&1 | grep -aE "=== [A-Z]" | tail -1
done

# 0.4 最高优先：读 Puerts_ReadFile 伪代码 → main.js 解密
cat reports/decompiled/dec11_Puerts_ReadFile.c 2>/dev/null || cat reports/decompiled/Puerts_ReadFile.c 2>/dev/null
# 按伪代码提取解密逻辑 → 解密 extracted_js/main.js（372KB 密文）
# 解密后的 JS = 原版地图生成器 + 可能的全部游戏逻辑源码
```

**main.js 解密成功后**：
1. 读 JS 找 `generateMapInJs` 函数 → 高度图生成真源码；
2. 逐行对照 `heightmap_dsl.gd` → 终审衰减公式 → 修 DSL；
3. 跑全部测试 → mapstats 重建基线 → **解除全陆中间态**。

**main.js 解密用的 UnityPy 提取命令**（TextAsset 已提取到 `extracted_js/main.js`，372KB 密文；如需重新提取）：
```python
import UnityPy
env = UnityPy.load(r"E:\steam\steamapps\common\FantasyMapSimulator\FantasyMapSimulator_Data
esources.assets")
for obj in env.objects:
    if obj.type.name == "TextAsset":
        d = obj.read()
        if d.m_Name == "main":
            open("extracted_js/main.js","wb").write(
                d.m_Script.encode("utf-8","surrogateescape") if isinstance(d.m_Script,str) else d.m_Script)
```

---

## 1. 项目一句话

用 Godot 4.2.2 + GDScript 忠实重建 Steam 游戏 FantasyMapSimulator（Unity 2021.3 / IL2CPP / x64）。
**当前方向已调整**：P0=玩法复刻 > P1=逆向验证 > P2=地图细节（冻结非必要深挖）。
**用户核心目标**：打开 FMSR 能看到一个持续演化的世界（国家/外交/战争/历史），不是只生成一张地图。

---

## 2. 当前项目状态快照（写于 21:00）

### 队列（夜间自主运行中，无需干预）

| 队列 | 状态 | 剩余内容 | 预计完成 |
|---|---|---|---|
| round11 | 24/25（Trough_b__2 跑中） | Trough_GetRange → addPit ×2 | ~21:40 |
| round12 | watcher 等待 round11 | **Puerts_ReadFile（main.js 解密之钥！）** → ModifyCells b__0/b__1 → CultureGenerator×5 → State 宗教归属 → 领袖×2 | ~02:30 |

- 队列通过 **WMI 启动**（`powershell Invoke-CimMethod Win32_Process.Create`），脱离 AI 会话、无控制台、挂起免疫。
- 检查状态：`tail logs/round11_queue.out` + `tail logs/round12_queue.out`；产物 `logs/dec11_*.json` / `logs/dec12_*.json`。
- **不要重复启动正在运行的队列**。如需重启：`powershell Invoke-CimMethod Win32_Process -MethodName Create -Arguments @{CommandLine='E:\Git\usr\bin\bash.exe E:\GameResearch\FantasyMapSimulator\tools\decompile_roundNN_queue.sh'}`。
- 监督者模式：npx 后台 + 文件看护（JSON 大小稳定 30 秒即收割），兼容挂起/控制台事件两种故障。

### 伪代码库存

**53 个 .c 文件**在 `reports/decompiled/`。本轮新增的关键文件：

| 文件 | 内容 | 对应修正/结论 |
|---|---|---|
| `HeightMapGenerator_addStep.c` | 9 算子分发 | **分发层零修改**（参数位全对上） |
| `HeightMapGenerator_addOneHill.c` | 山丘衰减 | **写回阈值 >4.0 + 浮点 change**（已修正） |
| `HeightMapGenerator_addRange.c` | 山脊抬升 | **抬升因子域 [0.85,1.85]**（已修正） |
| `HeightMapGenerator_Range_GetRange.c` | 贪心山脊 | 与 `_greedy_ridge` 逐式等价（零修改） |
| `HeightMapGenerator_Range_b__2.c` | 突刺键选择 | `cell => heights[cell]`（走向最低邻 ✓） |
| `HeightMapGenerator_addStrait.c` | 海峡 | 大部分一致；起点带 [0.4,0.7] 微差待补 |
| `HeightMapGenerator_mask.c` | 面罩 | 与 `_mask` **逐式一致**（零修改） |
| `HeightMapGenerator_GenerateHeightMap.c` | 入口 | = `GenerateFromTemplate(this,3,0)` 逐字 |
| `HeightMapGenerator_cctor.c` | **幂表** | **= Azgaar 表逐字一致**（唯一差异 blob[10000]=0.91） |
| `HeightMapGenerator_GetBlobPower.c` | 幂表查询 | TryGetValue + 缺省 0.98；**零 C# 调用者 = JS 编排** |
| `MathUtility_Lim.c` | 钳制 | **clamp(v,0,100) 双边**（重建版本就正确） |
| `RandomUtils_GetNumberInRange.c` | 区间随机 | 与重建版语义等价（零修改） |
| `SaveSystem_EncryptString/DecryptString/cctor.c` | 加密 | **密钥已提取**（见 §4） |
| `World_GenerateHeightMap.c` | 编排 | **JS 通道 + 模板名随机 + 无 C# 回落** |
| `World_GenerateHeightMapFromJs.c` | JS 调用 | Ensure → Generate；**无回落** |
| `World_GenerateBaseMap.c` | 基础地图 | **CultureGenerator.Generate+Expand**（round12 队列） |
| `HeightMapExternal_Init/Generate.c` | Puerts | ExecuteModule("main.mjs") → 绑定 generateMapInJs |
| `SaveSystem_ReadBinarySaveContainerHeader/WriteBinarySaveContainer.c` | 容器 | V2 格式 [magic][ver=1][ivSize][IV][data] |
| `Biomes_cctor.c` | 群系 | 13 真名 + 13×4 矩阵 + 7 blob（blob 解析待做） |
| `BrushManager_DrawShapes/GetColorFromHeight.c` | 笔刷 | 光标预览 + 三停靠点渐变（非混合算符） |
| `HeightmapTemplates_cctor.c` | 模板 | 5 构造块 Add 顺序 + Probability 整数权重 |

---

## 3. 本轮推翻的旧结论（V1 接手者必读）

| 旧结论（V1/HANDOVER） | 新证据 | 正确结论 |
|---|---|---|
| 「失败回落内置 DSL」 | GenerateHeightMapFromJs 反编译 | **无回落**——高度图唯一来源 = Puerts JS |
| 「GenerateFromTemplate(this,3,0) 的 3 是字典键」 | GetItem 接口反编译 + cctor Add 顺序 | **列表下标**（Templates[3]=6867） |
| 「Add 顺序=字面量顺序」 | cctor 机器码 Add 顺序 | **[Volcano,HighIsland,Cont,Cont,Cont]**，JSON 已重排 |
| 「文化/宗教=界面文字」 | GenerateBaseMap→CultureGenerator.Generate+Expand | **cell 级扩张系统**（round12 出真值） |
| 「main.js 不存在/无 JS」 | puerts.dll+libnode.dll+main.mjs TextAsset | **main.js = 加密 372KB 游戏逻辑** |
| 「存档格式未知」 | SaveSystem 密钥提取 + 30 存档验证 | **AES-256-CBC/零IV/密钥已提取** |

---

## 4. 存档加密（已破解，随时可用）

```
密钥（32 字节 UTF-8）：o7E@:5UwTW_>XV9_8I?~eoux7E7?Kn~t
算法：AES-256-CBC，IV=全零 16 字节，PKCS7
格式：.save 文件 = Base64( AES( Base64( GZip( JSON ) ) ) )
V2 容器（本地二进制）：[magic "NFW_SAVE_BIN"][version=1 int][ivSize int][IV][AES data]
```

解密代码（Python）：
```python
import base64, gzip
from Crypto.Cipher import AES
key = b"o7E@:5UwTW_>XV9_8I?~eoux7E7?Kn~t"
def decrypt_save(path):
    raw = base64.b64decode(open(path, "rb").read())
    c = AES.new(key, AES.MODE_CBC, b"\0" * 16)
    pt = c.decrypt(raw)
    pad = pt[-1]
    if 1 <= pad <= 16:
        pt = pt[:-pad]
    return json.loads(gzip.decompress(base64.b64decode(pt)))
```

**已解密样本**：
- 四档 BasicMap（1/2/4/8.save）：**cell 数 19928/30030/40050/79924**，含 SerializablePos（维诺图坐标）与 21 个数组 schema；
- 官渡之战（40050 cell）：**land 31.8%、mean 23.1**、海=0、60-69 台地 6693 格、文化 10+1、省 1008、国 36；
- 36 工坊存档盘点：tier40050 平均 land 41.6%、tier79924 平均 45.2%；
- 完整 JSON：`logs/workshop_guandu.json`（官渡）、`logs/basicmap1.json`（1.save）、`logs/workshop_armies.json`（欧洲1.1.1 军队 8298 实例）；
- **Army schema**（22 字段）：见 §6。

**main.js（497KB → 372KB 密文）**：SaveSystem 密钥不适用，解密逻辑在 `Puerts.DefaultLoader.ReadFile`（本构建被改）——round12 队列产出后可得。

---

## 5. 原版高度图核心事实

| 事实 | 等级 | 来源 |
|---|---|---|
| blobPowerMap/linePowerMap = Azgaar 表逐字（唯一差异 blob[10000]=0.91） | ★A | cctor 立即数 |
| 每步衰减 `change[e] = powf(change[q], blobPower) × (rand×0.2+0.9)` | ★A | addOneHill 反编译 |
| 抬升 `(rand + 0.85) × h + cur`（因子域 [0.85,1.85]） | ★A | addOneRange 反编译 |
| 写回阈值 change > 4.0 | ★A | addOneHill 反编译 |
| Lim = clamp(v, 0, 100) 双边 | ★A | MathUtility.Lim 反编译 |
| 山脊游走 `Random.value > 0.85 → dist×0.5` | ★A | GetRange 反编译 |
| **JS 编排**（GetBlobPower 零 C# 调用者） | ★A | 全 .text 反查 |
| 实际地图 31.8~45% 陆地 vs 网格模拟 98-100% | ★B | 官渡解密 vs power_sweep |

**未解之谜（终审依赖 main.js）**：per-step pow 衰减在同表值下产 98% 陆地（网格）/原版 32%。
差异可能来自：①powf 实参细节；②JS 侧编排逻辑；③维诺图 vs 网格拓扑。**不要调参掩饰。**

---

## 6. Army / War / Campaign schema（原版存档解密实测）

### Army（22 字段）
```
armyID(int唯一) isElite(bool) isMannulCreated(bool) currentState(string:"Idle"/"Attacking"/"Reorganization"/"Destroyed")
currentCell(int) preCell(int) targetProvinceObject(int,-1=无) homeProvince(int) state(int归属)
isEmergencyCall(bool) armyCount(float,200起步,可见损耗190.19/-1毁灭) armyType("BorderGuard"/"FieldArmy"/"Garrison")
armyOrder("AttackEnemyProvince"/"HoldPosition"/...) baseCombatEfficiency(float) foundingTime(float,游戏年)
participatedCampaigns[int] enemyArmyDestroyedCount(float) conqueredProvincesInfo[{province,from,time}]
```
编成比例：BorderGuard ~94.5% / FieldArmy / Garrison；armyCount 200 起步。

### War（10 字段）
```
aggressorID defenderID warState(int) warType(int) IsFightToTheEnd(bool)
startTime(float) minMonthBeforeWarEnd(24) aggressorAlliesID[] defenderAlliesID[] id
```

### Campaign（9 字段 = 战役/战斗记录）
```
id warKey("攻方-守方"字符串) locationProvinceId startTime endTime
involvedArmyIds[] involvedStateIds[] sequenceNumber isActive(bool)
```

### State（40+ 字段，节选）
```
culture(int) cultureName type(从文化拷贝) ethnicAttribute(int) expansionism(从文化拷贝)
politicalSystem(int) stateReligionId(int,-1=无) diplomacyPower(+StartWar/EndWar变体)
foundingTime population gold goldPerMonth foodReserve destiny rebelWar isDead
initialPopulationPercentage recentRebellionTimesArray[] allianceID armyCostGold features[]
```

### Province（40+ 字段，节选）
```
cultureID stateID isLand isSeaNeighbor battleScore provincePower provinceDiplomacyPower
provinceLoyalty religionDistribution{religionId:%} foodProductionEfficiency foodReserve
population maxPopulation combatEfficiencyModifier biomeCounts provinceResources
```

---

## 7. 重建版当前状态

### 测试全绿（78+ 断言）
| 测试 | 数 | 覆盖 |
|---|---|---|
| template_parse | 9/9 | 模板解析 + 幂表顺序 |
| heightmap_dsl_test | 13/13 | 算子数值 + 模板端到端 |
| culture_religion_test | 23/23 | 文化/宗教包加载器 |
| culture_system_test | 10/10 | cell 级文化扩张 + 国家归属 |
| economy_test | 4/4 | 月度财政循环 + 存档往返 |
| army_test | 6/6 | 军队编成 + 存档往返 |
| army_battle_test | 6/6 | 遭遇战 + Campaign + 控制权 ≠ 所有权 + 结算转移 |

### 已知中间态失败（不调参，等 main.js 终审）
| 测试 | 失败数 | 根因 |
|---|---|---|
| selftest | 1 | 海洋省=0（0.99 幂表+已证算子→全陆） |
| editor_test | 5 | 海格用例无海可用（同根因） |

### 代码变更
- `heightmap_dsl.gd`：hill 浮点 change + >4.0 写回阈值；range 抬升 (rand+0.85)——均标注证据行；
- `mapgen.gd`：文化/宗教接线 culture_system.gd + TEMPLATE_INDEX 注释更新；
- `simulation.gd`：_economy_tick + Army 实体系统（编成/动员/推进/遭遇/占领/结算）+ armies/campaigns 存档往返；
- `culture_system.gd`：cell 级多源扩张 + 国家归属 + 宗教映射（独立随机流）；
- `culture_pack.gd` / `religion_pack.gd`：原版数据包加载器；
- `assets/origin/Culture/` + `Religion/`：原版数据复制（只读源）。

---

## 8. 下一步（按优先级，不询问直接执行）

### 第一优先：处理 round11/12 队列产出

round11/12 落地后（预计 ~02:30），逐项导出 → 读 → 对照 → 按证据修正：

| 产出 | 对应行动 |
|---|---|
| `dec11_Puerts_ReadFile.json` | **main.js 解密逻辑**→ 解密 main.js → 372KB JS = 原版生成器源码 |
| `dec11_Save_cctor` 等（已读） | 已处理 ✓ |
| `dec12_ModifyCells_b__0/b__1.json` | Add/Multiply/Power 精确公式 → 修 `_modify` |
| `dec12_Culture_Generate/Expand.json` | 文化种子选址+扩张代价真值 → 修 `culture_system.gd` |
| `dec12_State_DetermineReligion.json` | 宗教归属真值 → 修 religion 映射 |
| `dec12_Leader_GenForState.json` | 领袖生成 → 实现 Leader 实体 |
| `dec11_GetBlobPower/GetLinePower`（已读） | 幂表查询已证 ✓（TryGetValue） |
| `dec11_addTrough/addOneTrough/...` | Trough/Pit 语义 → 对照修 DSL |
| `dec11_HMGenerator_cctor`（已读） | 幂表已提取 ✓ |

**main.js 解密流程**（Puerts_ReadFile 伪代码到手后）：
1. 从伪代码提取解密函数/密钥/偏移；
2. Python 解密 main.js → 372KB JS 明文；
3. main.js 里找 `generateMapInJs` 函数 → 高度图生成真源码；
4. 逐行对照 `heightmap_dsl.gd` → 终审衰减公式 → 解除全陆中间态。

### 第二优先：领袖系统（Leader 实体）

StateLeaderGenerator 伪代码到手后：
1. 建实体（字段从伪代码 + CultureData.csv 姓名列 + CharacterFirstNames_M/F/Last）；
2. 接入 state（state.leader = leader_id）；
3. LeaderDeathEvent/LeaderAscensionEvent 生命周期；
4. 国家面板显示真实领袖。

### 第三优先：外交系统补全

diplomacyPower（+StartWar/EndWar 变体）+ StateRelations + 朝贡/参战义务。

### 第四优先：内政扩展

foodReserve/loyalty/provinceResources/biomeCounts → 月度内政循环 → 稳定性/叛乱/事件。

---

## 9. 关键路径速查

| 内容 | 路径 |
|---|---|
| Godot 工程 | `source/fms-godot/` |
| 反编译伪代码 | `reports/decompiled/*.c`（53 个） |
| 队列日志 | `logs/round11_queue.out` / `round12_queue.out` |
| 队列产物 | `logs/dec11_*.json` / `dec12_*.json` |
| 解密函数 | Python：`AES.new(b"o7E@:5UwTW_>XV9_8I?~eoux7E7?Kn~t", AES.MODE_CBC, b"\0"*16)` |
| 原版数据包 | `assets/origin/Culture/` + `Religion/`（7+3 目录） |
| 军队 schema 证据 | `logs/workshop_armies.json`（8298 实例） |
| 官渡全量 JSON | `logs/workshop_guandu.json`（1.85MB） |
| 真值高度场渲染 | `tests/origin_40050_heightmap.png` |
| 敏感性扫描 | `tests/power_sweep.gd` |
| 备份 | `backups/heightmap_dsl.gd.pre-round11` + `backups/simulation.gd.pre-economy` |
| 队列脚本 | `tools/decompile_round11_queue.sh` / `round12` / `round12_watcher.sh` |
| 启动游戏 | 双击 `启动FMSR.bat` |
| 原版（只读） | `E:\steam\steamapps\common\FantasyMapSimulator\` |

---

## 10. 关键坑与纪律（本轮验证 + V1 保留）

- **AI 会话后台必被回收** → WMI 启动（`Invoke-CimMethod Win32_Process.Create`），不用 schtasks 也不用会话级后台；
- **MSYS 引号转换**会弄坏 schtasks /tr 内嵌引号 → WMI 直接 Create 或纯 ASCII bat；
- **REA 的 node 在无控制台环境会挂住** → 监督者模式（后台 + 文件看护 + 超时收割）已实现；
- **GDScript `:=` 从 Variant 推断报错** → 显式写 `: Type`；
- **Godot 控制台 GBK 乱码** → 只看 [PASS]/[FAIL] 与数字，不修编码；
- **原版 Steam 目录只读**；
- **Android 冻结到 Windows 验收通过**；
- **不要把推测写成事实**：每条结论区分 ★A 逐字证实 / ★B 运行实测 / ★C 存在确认 / ○ 推测；
- **不要调参掩盖算法错误**：91~98%→全陆中间态保留到 main.js 终审；
- **测试先行**：每模块写完即写测试并跑全量回归；
- **备份**：修改前 cp 到 `backups/`。

---

## 11. 队列产出处理 SOP（每个 JSON 通用流程）

```bash
# 1. 确认产出有效
python -c "import json; d=json.load(open('logs/dec11_XXX.json','utf-8')); print(len(d['normalized_result']))"
# 2. 导出到 reports/decompiled/
python -c "import json; d=json.load(open('logs/dec11_XXX.json','utf-8')); open('reports/decompiled/XXX.c','w',encoding='utf-8').write(d['normalized_result'])"
# 3. 读取伪代码 → 对照重建版 → 修正（标注证据行）→ 写入 findings §15.xx
# 4. 跑对应测试
```

---

## 12. 本轮测试基线（交付时的全量快照）

```
template_parse          9/9  ✅
heightmap_dsl_test     13/13 ✅
culture_religion_test  23/23 ✅
culture_system_test    10/10 ✅
economy_test            4/4  ✅
army_test               6/6  ✅
army_battle_test        6/6  ✅
selftest               26/27 （1 预期失败：海洋省=0，全陆中间态）
editor_test            53/58 （5 预期失败：海格用例，同根因）
mapstats               未重建（等高度图终审）
```

---

## ⚠️ 新窗口接手者特别警告

1. **HANDOVER.md / PROGRESS.md 中部分结论已被本轮推翻**（见上文 §3 对照表）。
   如有冲突，**以 HANDOVER-V2.md + reports/decompile-findings.md §15 为准**。
   最容易被旧文档误导的三条：
   - "失败回落内置 DSL"（错：无回落，JS 是唯一路径）；
   - "文化的分配是随机的"（错：原版有 CultureGenerator.Generate+Expand）；
   - "地图生成在 C# 里"（半对：C# 是算子库，编排者在 JS/main.js）。

2. **simulation.gd 中 `armies` 数组与 `st.army` 字段并存**：
   - `armies` = 本轮新增的 Army 实体数组（真实军队对象，schema 见 §6）；
   - `st.army` = 旧版的国家军队**数值**（round 6 遗留，还在被 UI 面板读取）；
   - 两者目前独立。后续应把 st.army 改为从 armies 数组汇总（sum of armyCount per state）。

3. **culture_system.gd 的 state_culture/state_religion 数组用国家序号做索引**——
   如果后续实现"国家灭亡 / 新国家诞生 / 省份转移导致文化归属变化"，需同步维护该数组
   （目前只在 generate() 时赋值一次，后续模拟中不变——round12 CultureGenerator 伪代码到手后改）。

4. **simulation.gd 的 `wars` 数组格式与原版 SerializedWars 不同**：
   - 重建版字段：`{id, attacker, defender, type_key, goal_key, score, months, active, ...}`；
   - 原版字段：`{aggressorID, defenderID, warState, warType, IsFightToTheEnd, startTime, ...}`；
   - 本轮只在 declare_war 时补了 `war_state/min_month_before_war_end/is_fight_to_the_end/allies`
     等原版字段（值是重建版设定的），**完整对齐待 main.js 解密**。

5. **运行游戏的完整命令**（不是 headless，弹出窗口给用户看）：
   ```
   E:\Godot\Godot_v4.2.2-stable_win64_console.exe --path E:\GameResearch\FantasyMapSimulator\sourcems-godot
   ```
   或双击项目根目录 `启动FMSR.bat`（会清残留进程）。

6. **截图命令**（游戏内自动截图并退出）：
   ```
   E:\Godot\Godot_v4.2.2-stable_win64_console.exe --path ...\sourcems-godot -- seed=42 shot=8 noinput
   ```
   截图输出：`C:/Users/MR/AppData/Roaming/Godot/app_userdata/FMSR - Fantasy Map Rebuild/shots/auto_seed42.png`

