# FantasyMapSimulator 代码结构分析报告

> 工具：REA 6.8.0 `inspect-il2cpp-metadata`（元数据 v29 + GameAssembly.dll 地址关联）
> 证据包：`reports/il2cpp-evidence.json`（33.5MB，含 SHA-256 溯源）
> 可读清单：`reports/dump-assembly-csharp.txt`（2,214 个游戏类型 / 17,739 个方法）
> 方法索引：`reports/methods-assembly-csharp.csv`（含 RVA 与状态）

## 1. 恢复规模（全部为已验证的静态事实）

| 指标 | 数量 |
|---|---|
| 元数据中的类型 | 13,681 |
| 方法（含**原生地址 RVA 关联**） | 101,296（state=code 占绝大多数） |
| 字段 | 60,691 |
| 属性 | 17,071 |
| 程序集（images） | 88 |
| 字符串字面量 | 22,375 |
| 其中游戏主程序集 Assembly-CSharp | 2,024 类型 / 17,739 方法 |
| 泛型实例地址 | 未启用（--generic-instances 可后续开启） |

REA 报告的 5 条分析限制（元数据解密、地址匹配机制、类型渲染规则、二进制配对证明方式、嵌套类型推导）详见证据包 `limitations`。

## 2. 已确认的核心类与其职责

### 2.1 世界与生成
| 类 | 关键成员（节选） | RVA 已确认 |
|---|---|---|
| `World` / `WorldSerializationData` / `WorldSettings` / `WorldState` | 世界数据根对象 | ✅ |
| `HeightMapGenerator` | 高度图生成（`DisplayBiomHeightMap`） | ✅ |
| `BurgsAndStateGenerator` | `Generate()` 0x48b9a0；`CreateProvinces` 0x4846a0；`ExpandProvinces` 0x486c90；`ExpandStates` 0x4890a0；`PlaceCapitals` 0x490d80；`PlaceProvincialCapitalsByJitterGrid` 0x491500；`EnsureProvinceConnectivity` 0x485cd0；`RecalculateProvinceState` 0x493820 等 40+ 方法 | ✅ |
| `CultureGenerator` / `NameGenerator` / `StateLeaderGenerator` / `RebellionReasonGenerator` | 文化与命名生成 | ✅ |
| `SDFTextureGenerator` (+ComputeShader) | 边线 SDF 纹理生成 | ✅ |

### 2.2 实体与数据
| 类 | 说明 |
|---|---|
| `Province` / `ProvinceObject` / `ProvinceSerializeData` / `ProvinceHistroy`(原文拼写) / `ProvinceExpansionRuntimeSnapshot` | 省份运行时+序列化 |
| `BurgData` | 城市 |
| `State` / `StateHistory` / `SerializedStateHistoryPoint` | 国家与历史 |
| `MapCulture(Manager|SerializeData)` / `MapReligion(Manager|SerializeData)` | 文化/宗教运行时 |
| `Army(Manager|Pathfinding|Order|Organization|State|Type)` | 军队与寻路 |
| `CharacterManagerSaveData` / `FamilyManagerSaveData` | 人物/家族 |
| `War` / `WarManager(V2)` / 30+ War*V2 类 | 战争系统 |

### 2.3 模拟心跳与规则
- `TimeManager`：`secondsPerDay`、`gameTime`；静态标记字段显示 tick 分层——每日（Provinces/States/Families/Vassals）、每月（Diplomacy/WarV1/WarV2/Characters/Families/Population）、每年（CaptureHistory/States/Families）
- `GlobalTimeScaleManager` / `TimeScaleChangeHandler`：全局时间倍率
- `AutoSaveManager`：`isEnableAutoSave` + `autoSaveIntervalMinutes`（配置可见）
- 玩法规则开关（gameConfig.json 实证）：`isAllowRebel`、`isAllowCivilWar`、`isAllowFamilyRebellion`、`isAllowAlliance`、`isEnableVassal`、`isAllowVassalAutoRebel`、`IsAssistAlliesOccupyLand`、`IsAutoAbandonIsolatedProvinces`、`minMonthSinceLast*Rebellion`、`minMonthToBeginAnotherWar`、`maxMonthBeforeForceEndWar` 等

### 2.4 UI 与交互
- `UIManager`（超大类，含全部面板引用：`WorkshopPanel`、`CultureSetWorkshopPanel`、`HistoryTimelineUI` 等）
- `MPUIKit`（自制 UI 框架）、`LeTai.TrueShadow`、`DOTween`、`TextMeshPro`
- 相机：`cameraZoomSpeed` 配置、`FantasyMapTransformScaleChanger`、`TimeLineDrag`
- 地图交互：`CustomMapImage(DragHandler|Layer|Manager)`（自定义地图图片导入与拖放）、`MapCoordinates`、`MapScreenshotTool`

### 2.5 平台与扩展
- `DouyinFantasyMapStartup` + ByteDance LiveOpenSdk 族：抖音直播弹幕互动模式
- `CultureWorkShopUI.UploadCultureSetToWorkshop`、`MilitaryProfileModManager.GetWorkshopPackages`：游戏内可直接上传 Mod 到创意工坊
- `SaveSystem.GetWorkshopSaveDirectory`：Workshop 订阅存档管理

## 3. PUERTS 双层逻辑架构（重要）

- `resources.assets` 中 TextAsset `main`（485KB）为 **base64 编码的加密内容**，运行时由 `com.tencent.puerts.ts-loader.dll` 解密并作为 TS/JS 逻辑执行；`world.d`/`script.d` 为 40 字节的声明标记资产
- `StreamingAssets/JS/relatives-tree.bundle.js` 为明文 webpack 包（亲属树 UI），导出模块名 `RelativesTree`，内含 `arrangeFamiliesFunc` 等函数 —— 证明该游戏 UI 子模块确实是 JS 实现
- **含义**：游戏逻辑分两层——C#（IL2CPP）承担模拟核心与渲染，TS/JS 承担部分逻辑/UI。解密 `main` 后可获得更高层的可读逻辑与更低的修改成本（列入下一步）

## 4. 方法地址样例（可用于 Ghidra/调试器断点）

```
BurgsAndStateGenerator.Generate()                     RVA 0x48b9a0
BurgsAndStateGenerator.CreateProvinces()              RVA 0x4846a0
BurgsAndStateGenerator.ExpandStates()                 RVA 0x4890a0
SaveSystem.GetSaveDirectory()                         RVA 0x4b0620
SaveSystem.WriteRootV2()                              RVA 0x4c2a20
SaveSystem.EncryptString()                            RVA 0x4aee10
CultureManager.LoadCultures()                         RVA 0x71d9d0
CultureManager.GetWorkshopDirectory()                 RVA 0x71a4f0
ReligionManager.LoadWorkshopReligionSets()            RVA 0x4a3620
完整索引见 methods-assembly-csharp.csv（17,739 行）
```

## 5. 尚未恢复 / 下一步

1. **方法体反编译**：当前拥有全部签名+地址，但函数体为原生 x64 机器码。要得到伪 C 源码需配置 Ghidra 12.1.x 并让 REA 用 `--ghidra-seeds` 种子文件做符号化分析（REA 已内置该管线；Ghidra 未安装，安装步骤见 docs）。
2. **Puerts main 包解密**：定位 ts-loader 程序集中解密调用（元数据已可定位类与方法，同样需 Ghidra 看实现）。
3. **存档容器加密**：`c_SaveEncryptionKey` 的 KDF/模式需反编译确认。
4. 泛型实例地址关联（`--generic-instances`）未开启。
