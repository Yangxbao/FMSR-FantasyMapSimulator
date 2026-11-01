# FantasyMapSimulator 游戏架构分析报告

> 生成日期：2026-10-29 ｜ 分析方式：只读静态分析（REA 6.8.0 + UnityPy + 文件系统取证）
> 原始游戏：`E:\steam\steamapps\common\FantasyMapSimulator`（Steam AppID **3035500**，"Fantasy Map Simulator"，开发商 The Stranger Studio）
> 本文档所有结论均来自实际文件检查与工具输出，未经证实的推断会明确标注。

## 1. 引擎与编译方式（已验证）

| 项目 | 结论 | 证据 |
|---|---|---|
| 引擎 | Unity 2021.3.36f1 (LTS) | `globalgamemanagers` 头部字节含版本字符串 `2021.3.36f1` |
| 脚本后端 | **IL2CPP**（非 Mono） | 存在 `GameAssembly.dll`（53.4MB）+ `il2cpp_data/Metadata/global-metadata.dat`（12.2MB）；无 Managed 目录 |
| 元数据版本 | 29 | REA `inspect-il2cpp-metadata` 解码输出 `metadata_version: 29` |
| CPU 架构 | x86_64 (Windows) | PE 头 + `Plugins/x86_64/` 目录 |
| 渲染 | D3D11（Windows 标准） | boot.config `gfx-enable-native-gfx-jobs=1` |
| 脚本层 | **Puerts + TypeScript loader**（腾讯 JS 引擎） | `puerts.dll`、`libnode.dll`(76MB)、程序集 `com.tencent.puerts.core.dll`、`com.tencent.puerts.ts-loader.dll` |
| Steam 集成 | Steamworks.NET | `Plugins/x86_64/steam_api64.dll`、`Steamworks.NET.txt`、`com.rlabrecque.steamworks.net.dll` |
| 第三方 SDK | 字节跳动直播开放平台 SDK（抖音弹幕互动）、-perf 性能监控、metasec 安全组件 | `ByteDance.*` 程序集族、`parfait.dll`、`metasecml.dll`、`sscronet.dll`、`gameConfigDyV2.json` |

## 2. 关键文件地图

```
FantasyMapSimulator/
├── FantasyMapSimulator.exe            # Unity 播放器启动器
├── GameAssembly.dll                   # IL2CPP 编译的全部 C# 代码（53.4MB）
├── UnityPlayer.dll / baselib.dll      # Unity 运行时
├── envs.log                           # 游戏自身的环境诊断日志（含各系统路径）
└── FantasyMapSimulator_Data/
    ├── globalgamemanagers(.assets)    # 引擎设置
    ├── level0                         # 主场景（46,370 个对象）
    ├── resources.assets (+.resS)      # 12,373 对象：图标/字体/SVG/UI + 加密主脚本包
    ├── sharedassets0.assets (+.resS)  # 1,051 对象：地图 Cell/UI/音乐
    ├── il2cpp_data/Metadata/global-metadata.dat   # IL2CPP 元数据（v29）
    ├── ScriptingAssemblies.json       # 118 个程序集清单
    ├── boot.config / app.info
    ├── Plugins/x86_64/                # 原生插件（见上表）
    ├── Resources/                     # unity 内建资源
    └── StreamingAssets/               # ★ 数据驱动内容（纯文本可读）
        ├── gameConfigDyV2.json        # 出厂默认配置（颜色/显示/玩法开关）
        ├── localization.csv           # 本地化文本（1.85MB，含中文）
        ├── JS/relatives-tree.bundle.js# 亲属关系树 webpack 包（明文 JS）
        └── Base/                      # 内置数据包
            ├── BiomeResource/BiomeResource.json
            ├── Buff/BuffDef.json
            ├── Culture/<包名>/{CultureData.json, StateNames.csv, CityNames.csv, Character*.csv}
            ├── Military/Default/
            ├── Religion/<集合>/
            └── Traits/{CharacterTraits, StateTraits}/*.json
```

用户数据（可写）目录：`C:\Users\MR\AppData\LocalLow\The Stranger Studio\FantasyMapSimulator\`
- `gameConfig.json`（v6）：用户配置 + 玩法规则开关（内战/叛乱/附庸/战争节奏/自动存档等 50+ 项）
- `savebackup_v6/`：存档备份（含 workshop 子目录）
- `Player.log`：运行日志

## 3. 运行时架构（由类结构推断，方法与 RVA 已确认）

```
┌────────────────────────── Unity Player (UnityPlayer.dll) ──────────────────────────┐
│  GameAssembly.dll (IL2CPP)                                                        │
│   ├── Assembly-CSharp (2,024 个类型) — 游戏全部核心逻辑                             │
│   │    生成层: HeightMapGenerator → BurgsAndStateGenerator → CultureGenerator      │
│   │    数据层: World / WorldSerializationData / Province / BurgData / State        │
│   │    模拟层: TimeManager(心跳) → WarManagerV2 / ArmyManager / Diplomacy /         │
│   │            RebellionSystem / FamilySystem / HistoryManager                     │
│   │    表现层: 自绘地图网格(Shapes/VectorGraphics/SDF) + UGUI + MPUIKit             │
│   │    存档层: SaveSystem(加密二进制容器) + AutoSaveManager                        │
│   ├── Puerts(ts-loader): 解密并执行 TS/JS 主逻辑包                                  │
│   └── Steamworks.NET: Workshop 读写/上传、成就                                      │
│  puerts.dll + libnode.dll  ← V8 引擎，执行 JS                                       │
└───────────────────────────────────────────────────────────────────────────────────┘
```

### 3.1 地图生成管线（`BurgsAndStateGenerator`，方法+RVA 已恢复）
`Generate()` 编排：`CreateProvinces` → `ExpandProvinces`（含海洋省份 `ExpandSeaProvinces`）→ `FilterProvinceCells` → `EnsureProvinceConnectivity`（连通性修复）→ `PlaceCapitals` / `PlaceProvincialCapitalsByJitterGrid`（抖动网格布城）→ `PlaceTowns` → `CreateStates(ViaProvince)` → `ExpandStates(ByProvince)` → `NormalizeStates` → `RandomProvinceColors/Name`。辅助：`HeightMapGenerator`、`SDFTextureGenerator`（ComputeShader 生成 SDF 边线纹理）、`NameGenerator`。
> 该管线与开源项目 **Azgaar's Fantasy Map Generator** 的领域模型（burgs/states/provinces/biomes/cultures/religions）高度同源，游戏 Steam 页面也标注灵感来源。这为路线 C（独立重建）提供了可参考的公开算法资料。

### 3.2 模拟心跳（`TimeManager`，字段已确认）
- 每日 tick：Provinces / States / Families / Vassals
- 每月 tick：Diplomacy / WarV1 / WarV2 / Characters / Families / PopulationVisualizer / PopulationMedian / AssignUpdateDays
- 每年 tick：CaptureHistory / States / Families
- 时间参数：`secondsPerDay`、`startYear/Month/Day`、`gameTime`；支持 `GlobalTimeScaleManager` 变速

### 3.3 战争系统 V2（活跃开发中）
`WarManagerV2` 全家族（30+ 类）：`WarDeclarationV2`、`WarGoalDefinitionV2/InstanceV2`、`WarClaimResolverV2`、`WarAIV2`、`CivilWar*`、`SettlementWarFrame/Scope`、`WarReparationsEffectV2`、`WarCompatibilityServiceV2`（兼容 V1）。存档有 `WarManagerV2SaveData`，配置项 `useWarSystemV2NewGame`。

### 3.4 存档系统（`SaveSystem`，重要）
- **二进制加密容器**：`BinarySaveContainerHeader`、`c_BinarySaveContainerMagic`、`c_BinarySaveIvSizeBytes`、`c_SaveEncryptionKey`（AES 类加密，IV 存在）→ **第三方直接解析存档需要先恢复密钥与容器格式（后续工作）**
- 版本管理：`CurrentSaveFormatVersion`、`LegacySaveFormatVersion`、`CurrentLogicDataVersion`、`WarSystemVersionV1/V2/LegacyMixed`
- `WriteRootV2` / `TryDeserializeRootV2` / `DeserializeRootWithCompatibility`
- Workshop 存档：`GetWorkshopSaveDirectory()`、`SaveInfo.IsWorkshopItem`
- 自动备份：`BackupAllSavesCoroutine` → `savebackup_v6/`
- 存量证据：用户存档位于 persistentDataPath，本地尚未生成玩家存档目录结构（用户未创建过存档或存于 workshop 目录）

### 3.5 资源加载方式
- **无 Addressables**；使用传统 `resources.assets/sharedassets0.assets` + `Resources` API + 场景对象
- 地图渲染：矢量方案（`Unity.VectorGraphics` + Freya Holmér `Shapes` + 自研 `SDFTextureGenerator` ComputeShader）
- 字体：TMP 动态字体（Noto 全家族 CJK 支持）
- 音频：`AudioClip` 内嵌（5 首音乐 + 音效）
- Puerts 主逻辑包：`resources.assets` 内 TextAsset `main`（485KB，**base64 编码的加密 TS/JS 包**，运行时解密；解密逻辑位于 IL2CPP 侧 ts-loader 程序集——恢复密钥为后续调查项）

## 4. 官方扩展/Mod 体系（重大发现，已验证）

游戏内置三层内容加载，**本地 Mods 目录无需 Steam 即可生效**：

| 层 | 位置 | 证据 |
|---|---|---|
| Base | `StreamingAssets/Base/` | 字面量 `'Base/Culture'`、`'Base/Religion'`、`'Base/BiomeResource'`、`'Base/Traits'` |
| **Local Mods** | `<数据根>/Mods/{Culture,Religion,Military}` | 字面量 `'Mods/Culture'`、`'Mods/Military'`、`'Mods/Religion'`、`'MilitaryProfileEditorImportSourceLocalMods'`；`CultureManager` 有 `modPath` 字段与 `GetCultureDataIncludingMods()` |
| Steam Workshop | Steam UGC | `CultureManager.GetWorkshopDirectory()`、`MilitaryProfileModManager.GetWorkshopPackages()`、游戏内上传 UI |

冲突规则（字面量原文）：*"当前将优先使用Mods版本"* —— **本地 Mods 优先级高于 Workshop**。

Mod 内容格式（与 Base 同构，已由已安装的 Workshop 包证实）：
- 文化包：`<目录名>/{CultureData.json, StateNames.csv, CityNames.csv, CharacterFirstNames_Male.csv, CharacterFirstNames_Female.csv, CharacterLastNames.csv, 1.png, bg.png}`
- 宗教集、军事包：类似 JSON+CSV 结构（`Mods/Religion/`、`Mods/Military`）
- 启用方式：`gameConfig.json` 的 `EnabledCultureIDs: ["Workshop_<id>_<名>", ...]`、`EnabledReligionIDs`

## 5. 修改面评估（与 reports/technical-feasibility.md 呼应）

| 修改面 | 难度 | 状态 |
|---|---|---|
| 本地 Mods 内容包（文化/宗教/军事/特质/Buff/生物群系） | 低 | ✅ 官方接口，格式已逆向 |
| gameConfig.json 参数调整 | 低 | ✅ 50+ 官方玩法开关 |
| 加密主脚本包（TS/JS）解密 | 中 | ⏳ 需恢复 ts-loader 解密逻辑（后续） |
| IL2CPP 代码级修改（BepInEx/Harmony） | 中高 | ⏳ Unity 2021.3 IL2CPP 属 BepInEx 6 支持范围 |
| 存档格式第三方读写 | 中 | ⏳ 需恢复容器加密（密钥在 IL2CPP 内） |

## 6. 未确认事项与下一步

1. `Mods/` 根目录到底是 persistentDataPath 还是安装目录 —— 需要实测（放置测试包后启动游戏观察）。另可通过 Ghidra 反编译 `CultureManager.GetWorkshopDirectory()`（RVA 0x71a4f0）确认。
2. Puerts `main` 包的解密算法与密钥 —— 反编译 ts-loader 程序集（元数据中已定位该程序集）。
3. 存档容器 `c_SaveEncryptionKey` 的使用方式 —— 反编译 `SaveSystem.WriteRootV2`（RVA 0x4c2a20）。
4. Workshop 本地回退目录规则（字面量 "Could not build a valid workshop path from install directory"）。
