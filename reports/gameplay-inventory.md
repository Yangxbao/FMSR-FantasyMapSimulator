# FantasyMapSimulator 玩法功能清单 · 重建版真实性审计 · 差距对照

> 写于 2026-10-31 20:15（第十一轮期间，方向调整后第一份文档）。
> **证据等级**：★A=原版反编译/存档解密逐字证实；★B=原版运行数据实测（解密存档/截图）；
> ★C=原版存在性确认（方法名/字段名在二进制中，行为未读）；○=推测/未见证据。
> 重建侧：✅真实实现 / 🟨部分实现或近似 / 🎨仅界面 / ❌未实现。

## 0. 权威依据：原版存档顶层系统清单（★A，logs/workshop_guandu.json 解密实测）

能进原版序列化的系统 = 真实存在的系统。顶层键与内部结构：

| 存档键 | 内部结构（解密实测） | 结论 |
|---|---|---|
| CellDataVersion/LogicDataVersion | "1.0"/"3.0" | 版本化存档 |
| WorldData | CellData(21数组+SerializablePos)/Riverline/OceanRoutes/Burgs/Seaburgs/Cultures/MannualRiver | 地图与 cell 数据、城镇、文化 |
| HistoryData | {}（开局为空，历史在游玩中产生） | 历史记录系统 |
| CampaignData | Campaigns[], StateProvinceCampaignCount{} | **战役系统（军事行动）** |
| ProvinceData | provinces[1008] 40+字段/updateBatchSize/updateIndex | 省份+批量模拟推进 |
| WarData | SerializedWars[], ActiveWarIds[] | 战争系统 |
| TimeManagerData | SecondsPerDay=0.1, StartYear/Month/Day, GameTime | 时间系统 |
| StateData | SerializedStates 40+字段/UpdateBatchSize/UpdateIndex | 国家系统+批量模拟 |
| ArmyData | SerializedArmies[], ObjectCount=200, UpdateIndex/BatchSize | **军队系统** |
| DiplomacyData | StateRelations[], SerializedAlliances[], LastRebelDesitinyRecalTimestamp, IsSuperSuperpowerExists, StrengthSum | 外交/联盟/叛乱 destined 重算 |
| VassalData | {}（开局空，出现附庸后有数据） | 附庸系统 |

State 序列化字段（40+，实测）：culture/cultureName/type/ethnicAttribute/expansionism（自文化拷贝）、
stateReligionId、politicalSystem(int)、diplomacyPower(+StartWar/EndWar 变体)、foundingTime、
timeStampLastWar/Alliance/Rebel/Born/EmergencyMobilize、foodReserve、population、gold、goldPerMonth、
destiny、restorationCount、isDead、rebelWar、initialPopulationPercentage、recentRebellionTimesArray、
perimeterAreaRatio、features[]、allianceID、armyCostGold、maniFestDestinyCount、stateHistorys{}。

Province 字段（节选）：cultureID、stateID、nameCellIndex、isLand/isSeaNeighbor/isAllCellsConnected、
battleScore/maxBattleScore、currentCampaign、isConnectedToCapital、provincePower、
provinceDiplomacyPower、provinceLoyalty、**religionDistribution{religionId:%}**、foodProductionEfficiency、
foodReserve、population/maxPopulation、distanceFieldToCapital、timeStampLastConquered、
combatEfficiencyModifier、biomeCounts、provinceResources。

Culture 对象：{i,type(Nomadic/Naval/Generic/Hunting…),expansionism,code,center(cell),Name,Base,Odd,Shield}。

## A. 原版功能清单（15 域逐项）

| # | 功能域 | 原版证据 | 等级 |
|---|---|---|---|
| 1 | 地图选择/世界初始化 | World.GenerateHeightMap 随机 tier+模板名；BasicMap 四档模板；GenerateBaseMap | ★A |
| 2 | 时间系统 | TimeManagerData(SecondsPerDay/GameTime)；SpeedButton/TimerLineMover 类 | ★A |
| 3 | 国家/省份 | StateData/ProvinceData 全 schema + ExpandStates/Provinces/CreateStates 反编译 | ★A |
| 4 | 人口增长 | state.population/province.population/maxPopulation；增长函数待读 | ★B |
| 5 | 经济资源 | gold/goldPerMonth/foodReserve/armyCostGold/provinceResources/biomeCounts | ★B |
| 6 | 扩张与领土变化 | ExpandStates/ExpandProvinces/MoveProvince(transfer) 反编译；workshop 存档国界变化 | ★A |
| 7 | 外交/联盟/附庸 | DiplomacyData(StateRelations/SerializedAlliances)+VassalData+Alliance 类全套+act_ 方法 | ★A |
| 8 | 战争/战斗/占领/灭亡 | WarData+SerializedWars+CampaignData+ArmyData+WarClaimMarker+State.isDead+rebelWar | ★A |
| 9 | 文化/宗教传播 | CultureGenerator.Generate/Expand+cell.Culture+province.religionDistribution+MapReligionManager | ★A |
| 10 | 领袖/继承/家族/官员 | StateLeaderGenerator.GenerateLeaderForState/AllStates+LeaderDeath/AscensionEvent+FamilyTreeNode+OfficialTitles | ★C(结构)/★B(数据) |
| 11 | 内政政策 | politicalSystem(int)+SettingsUIInfo+Buff/Traits 目录+provinceLoyalty | ★C |
| 12 | 随机事件/历史 | stateHistorys{}+HistoryTimelineNode+HistoryEventType+LeaderHistoryRecord | ★B |
| 13 | 玩家编辑/干预 | EditPanelUI 12 模式+BrushManager+act_ 按钮+MapEditRuntimePreservation | ★A |
| 14 | 存档/读档/恢复 | SaveSystem 全套（已破解）：V2 容器/流式/备份/创意工坊 | ★A |
| 15 | 设置与规则 | gameConfig.json+SettingsUIInfo+规则按钮（RebelIntervalSettingsButton 等） | ★B |

## B. 重建版真实性审计（代码 grep + 既有测试证据）

| 系统 | 重建状态 | 审计结论 |
|---|---|---|
| 地图生成 | ✅ | DSL 逐字还原度最高（本轮再证实 6 处零修改）；**全陆中间态待 main.js 终审** |
| 时间 | 🟨 | tick_month 驱动人口/战争/外交/历史 → 多系统 ✓；但 SecondsPerDay 语义/日粒度未还原 |
| 国家面板 | ✅(11 按钮真实) | act_expand/incite_rebellion/civil_war/annex/declare_war/peace/alliance 等改真实状态（有测试） |
| 人口 | 🟨 | _grow_population 存在且入存档；增长公式与原版对齐待证据 |
| 经济 | 🎨→🟨 | gold/goldPerMonth 字段在，**收入/支出模拟缺失**（无月度财政循环） |
| 扩张/领土 | ✅ | 多源 Dijkstra（反编译还原）+ _transfer/_move_province 真改归属 |
| 外交 | 🟨 | StateRelations 有 allianceID/vassal_of/宣战关系；**朝贡/参战义务/外交 Power 未实现** |
| 战争 | 🎨→🟨 | 12 类型**实际只触发 3-4 种**（Conquest/Liberation/Vassalization+rebel）；战役/军队/占领推进无 |
| 文化/宗教 | 🟨→✅ | 本轮：数据层+cell 级扩张+国家归属 10/10 测试；**传播/冲突/对稳定性的影响未实现** |
| 领袖/家族 | 🎨 | _gen_leader 占位词库；无生命周期/继承/家族势力（round12 队列有生成器证据） |
| 内政 | 🎨 | 字段在（gold/foodReserve），无政策/稳定性/腐败循环 |
| 事件/历史 | 🟨 | _record_war 历史分页真实写入；事件系统无 |
| 编辑器 | ✅ | 四层笔刷+撤销+存读档（58 项测试）真实 |
| 存档 | ✅ | save/load v3 往返测试通过；**格式与原版不同**（无 AES，字段覆盖不全） |
| 设置规则 | 🎨 | rules 字典 18 项真实生效（联盟开关等），但与原版 gameConfig 对齐未做 |

## C. 差距对照（按可玩闭环排序）

| 差距 | 原版证据 | 补齐难度 | 对可玩性影响 |
|---|---|---|---|
| D1 军队与战斗推进 | ArmyData(ObjectCount=200)+CampaignData+WarClaimMarker | 高 | 战争从"回合结算"变"真实推进" |
| D2 战争类型 12 种触发条件 | SerializedWars 实例（工坊存档可统计每类触发频次） | 中 | 战争多样性 |
| D3 财政循环（gold/foodReserve 月度收支） | state.gold/goldPerMonth/foodReserve/biomeCounts(税基) | 中 | 国家兴衰动力 |
| D4 领袖生成/死亡/继承 | StateLeaderGenerator 反编译（round12 队列）+LeaderDeath/AscensionEvent | 中 | 人物系统起点 |
| D5 文化扩张真值 | CultureGenerator.Generate/Expand（round12 队列） | 低（伪代码到手即改） | 归属规则去近似 |
| D6 宗教归属+分布 | State.DetermineStateReligion+province.religionDistribution | 低-中 | 宗教系统落地 |
| D7 外交 Power/朝贡/参战义务 | state.diplomacyPower(+War/EndWar 变体)+VassalData | 中 | 外交真实化 |
| D8 历史事件类型 | HistoryEventType 枚举+stateHistorys | 低 | 历史记录丰富度 |
| D9 批量模拟架构 | updateBatchSize/UpdateIndex（分帧推进） | 中 | 大地图性能 |
| D10 存档格式对齐原版 | SaveSystem 已破解（密钥+格式） | 中 | 可互读原版存档 |

## D. 三大优先可玩功能（下一阶段执行序）

### D-1 战争真实化（战役+军队+占领推进）
原版证据：ArmyData(ObjectCount=200)+CampaignData+province.currentCampaign+WarClaimMarker+BattleSword/AttackArrow 类。
方案：①WarManagerV2 挂接 Army 实体（每战争生成军队对象，位置=前线省）；②月度 tick 中军队向敌方省份推进（campaign=占领进度）；③占领省临时归属（currentCampaign）→战争结束按战争分数正式转移（已有 _settle_war/_transfer）；④12 类型按 SerializedWars 实测频次补触发条件。测试：战争结束后省份数/归属断言。

### D-2 财政+人口月度循环（国家兴衰引擎）
原版证据：state.gold/goldPerMonth/foodReserve/armyCostGold/province.population/maxPopulation/biomeCounts(税基)/foodProductionEfficiency。
方案：①月度：每省税金=f(population, biomeScores)→汇总 gold；②军队月耗 armyCostGold；③粮食赤字→population 下降/忠诚下降；④gold<0→稳定事件。公式细节待原版证据（Town/经济类反编译或运行时对照），先按字段语义实现并标注。测试：100 年模拟后 gold/population 单调性/均衡性断言。

### D-3 领袖与继承（人物系统起点）
原版证据：StateLeaderGenerator.GenerateLeaderForState/ForAllStates（round12 队列）+LeaderDeathEvent/LeaderAscensionEvent+CharacterManager.GetStateLeader+FamilyTreeNode。
方案：①round12 伪代码到手后按原版字段建 Leader 对象（姓名来自文化包 CSV——已加载）；②领袖死亡事件→继承（家族内优先）；③state 面板显示真实领袖。测试：200 年模拟领袖更替次数>0、继承链断言。

### 执行说明
D-2 最先（无外部依赖、立刻可写、效果全局）；D-3 等反编译（队列中）；D-1 需 Army schema 深挖（下一批解密一个带军队的后期存档即可得 SerializedArmies 实例结构——密钥已有！）。round12 完成后插入 D-5/D-6（低成本高价值）。

---

## 十二轮增补（2026-11-01 通宵自主开发：世界模拟闭环）

> 本节对照第十一轮的差距清单，记录闭环打通后的真实状态。证据等级约定沿用 §0。

### E-1 军队真实运行（第十一轮 D-1 的落地 + 缺口修复）✅
- **致命缺口修复**：`armies` 实体此前只在测试中初始化，真实模拟 `setup()` 后为空——军队从未移动。
  现为每国初始化（26 国 513 支：驻防 1 + 边防 ~20 + 野战 1；兵力 200 起步 = ★B 存档统计）。
- 动员（🟨 重建规则）：宣战仅 `FieldArmy` 获 `AttackEnemyProvince`；边防/驻防留守
  （方向对齐原版 BorderGuard 94.5% 常态）；
- 行军（🟨）：逐格贪心向目标省；只穿越己方/盟友/交战国领土；超 18 月自动收兵；目标失效自动重选；
- **遭遇战（🟨）**：省级同省即战（移动前后双检查）；战斗 15%~35% 损耗、败方重组 2 月或覆灭、
  战果联动战争分数 ±3——公式为重建版（原版逐步逻辑在 main.js Campaign 类）；
- **占领/吞并（✅ 结构对齐）**：`occupied_by`（控制）与 `state`（所有权）分离；结算时
  `settled_occupation` 正式转移并清控制标记；
- **战争结束（✅）**：分数 ±100 / 超时 120 月（★A gameConfig 字段）→ 按目标割省/吞并/赔款/附庸；
  参战盟友一并复员；**停战期 12 月**（★A gameConfig `minMonthToBeginAnotherWar`）登记并持久化；
- **国家灭亡清理 `_kill_state`（✅）**：军队 Destroyed、活跃战争终止写战报、外交清空、历史记录。

### E-2 外交最小闭环 🟨（新增）
- 盟友参战：宣战时双方盟友各 ≤2 国 50% 概率卷入（写原版 War schema 的
  `aggressor_allies/defender_allies`）——🟨 概率为重建参数，字段为 ★A；
- 统一敌对判定 `_are_hostile`（跨阵营遭遇可用）；停战期登记/倒计时/持久化；灭亡清理外交。
- 未做：朝贡、外交 Power 数值、附庸义务细化（不阻塞闭环，原样保留在 D 清单）。

### E-3 UI 可玩化 ✅
- 时间控制：暂停/**单步**/1×/2×/4×/8×（真实驱动 `tick_month`）；横幅常显日期+最新事件；
- **军队面板**（新增）：ID/国/省/兵力/类型/状态/目标 + 定位跳转；
- 国家面板：金币/月收入/月结余（新增行）+ 战争历时/分数 + 领袖/内阁（原有）+ 外交区（原有）；
- 历史面板：真实事件流（宣战/交战/占领/灭亡/停战/联盟/战争结果）。

### E-4 可重复战争演示 ✅（通宵指令硬性交付）
- `tests/war_demo_test.gd` 12/12：固定种子 42 南吴 vs 明郡，宣战→2 战役→割 3 省→60 月内结束→
  停战→全军复员→历史三阶段→战报归档；
- 游戏内一键：`-- seed=42 demo=1 shots=6,16,34`（自动宣战相邻两国 + 8× + 战场镜头 + 序列截图）。

### E-5 验证强度 ✅
- 新增 monthly_sim_test 18/18（24 月：战争/移动/战斗/占领/历史/健全/灭亡清理/存档续延/军队 ID 唯一）；
- long_run_test 18/18（**3 种子 × 120 月**，存档中断续延 60+60：健全、有灭亡、国家存续、时间正确）；
- 全量基线 **203/203**（原 154 + 新 48 + army_battle 修复 1）。

### 遗留（按优先级）
1. 国家面板数值为打开时快照（需重开刷新）；
2. 省/国密度偏离原版（3577 省/2619 海省 vs 官渡 1008/0）——对照 BurgsAndStateGenerator + JS 调参；
3. 原版战斗公式（main.dec.js Campaign/Battle）替换 `_battle` 重建公式；
4. 文化/宗教/领袖真值收割（round12 + main.dec.js）；verdict vs mapstats 陆地差记录在案（§15.37）。
