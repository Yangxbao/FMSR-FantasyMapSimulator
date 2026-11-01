# FantasyMapSimulator 资源目录报告

> 工具：UnityPy（只读扫描，未解包到游戏目录）
> 完整机器可读清单：`reports/asset-inventory.json`；人类可读摘要：`reports/asset-inventory-summary.md`

## 1. 总览

| 文件 | 对象数 | 主要内容 |
|---|---|---|
| `resources.assets` (+resS 175MB) | 12,373 | UI 图标（2451 GameObject）、SVG 图标、16+ 字体族、204 Sprite、168 Shader、**加密脚本包 `main`**、名称文本 |
| `sharedassets0.assets` (+resS 102MB) | 1,051 | 地图 Cell/Border/Highlighted 预制、UI Sprite、5 首背景音乐、RenderTexture(Biom/SDFLine) |
| `level0` | 46,370 | 主场景全部对象（UI 面板层级庞大） |
| `Resources/unity default resources` | 85 | Unity 内建 |
| `StreamingAssets/` | 纯文本 | **数据驱动内容（Mod 主战场）**：Base 数据包、localization.csv、gameConfigDyV2.json、JS 包 |

## 2. 重点资源明细

### 2.1 字体（16+，全 CJK 覆盖）
NotoSans/NotoSerif CJK(简繁日韩) 变量字体、GenJyuuGothic、微軟正黑體、TW-Kai、MoriaCitadel、PlayfairDisplay、Inconsolata、Roboto 族、LiberationSans —— 全部为 TMP SDF Atlas 动态字体。**含义**：汉化/换字体的官方路径是 TMP 资产，Mod 换字体需重建 SDF。

### 2.2 图标与 UI
- 军事图标：`sword-icon`、`recurve-bow-arrow-icon`、`crossbow-icon`、`NavyIcon_SVG`、`NavyWarshipIcon_SVG`（SVG 源内嵌 TextAsset）
- UI 骨架：`UISprite`、`Checkmark`、`Knob`、`InputFieldBackground`、`UIMask`
- 特效：Fireball 流（Meteor/Burst 动画帧）、卡通水面序列帧（`Water_Cartoon_Min_*`）

### 2.3 地图渲染管线资产
- `RenderTexture: Biom`（生物群系底图）、`SDFLine`（SDF 边线）
- `ComputeShader: SDFTextureGeneratorCompute`
- `Shader` 168 个（含 Shapes/VectorGraphics 运行时 shader）
- Mesh：`triangle_0`、`quad_0`、`sphere/cone/capsule` 基元 —— 地图由三角剖分网格绘制（`SimpleTriangulator` 类佐证）

### 2.4 音频
`sharedassets0.assets`：Guild of Adventurers、Deplasa Pe、Final Stance、Wonders And Mysteries Alt、Land of Heroes（BGM）；`espannol`（resources）。

### 2.5 数据与文本（非打包资源，直接可编辑）
| 文件 | 用途 |
|---|---|
| `StreamingAssets/Base/Culture/*/CultureData.json` | 文化定义（政体、命名集） |
| `StreamingAssets/Base/Culture/*/*Names.csv` | 国家/城市/人物名池 |
| `StreamingAssets/Base/Religion/*` | 宗教集 |
| `StreamingAssets/Base/Military/Default` | 军事编制 |
| `StreamingAssets/Base/Traits/{Character,State}Traits/*.json` | 人物/国家特质 |
| `StreamingAssets/Base/Buff/BuffDef.json` | Buff 定义 |
| `StreamingAssets/Base/BiomeResource/BiomeResource.json` | 生物群系资源 |
| `StreamingAssets/localization.csv` | 全部 UI 文本（含 zh-CN 列） |
| `StreamingAssets/gameConfigDyV2.json` | 出厂默认设置 |
| `%USERPROFILE%\AppData\LocalLow\The Stranger Studio\FantasyMapSimulator\gameConfig.json` | 用户设置（v6） |

## 3. 资源加载机制结论

1. **无 AssetBundle / 无 Addressables** —— 全部传统 Resources+场景序列化；Mod 不能以 AssetBundle 形式注入内容。
2. 内容扩展的官方通道是 **StreamingAssets/Base 同构的 JSON+CSV 目录**（Base/Mods/Workshop 三层）。
3. 图片类 Mod 资产（文化旗 `1.png`、`bg.png`）按目录约定直接放置。
4. 主逻辑脚本包以 TextAsset 形式打包（加密），不是可读资源。

## 4. 复用许可说明（针对路线 C 重建）

- JSON/CSV 数据结构与《Azgaar's Fantasy Map Generator》（AGPL-3.0 开源）的公开算法资料可用于自研实现参考（注意 AGPL 传染性：自研代码应原创，仅参考公开文档/机制而非直接抄源码；或选择遵守 AGPL 开源）。
- 游戏内美术/音频/字体为厂商资产，**不复制**到重建项目；重建项目使用自绘或自由许可资源。
- localization.csv 等厂商文本不复制。
