# FantasyMapSimulator 技术可行性与路线决策报告

> 日期：2026-10-29 ｜ 前置：game-architecture.md / code-analysis.md / asset-catalog.md

## 1. 修改路线评估（Windows 端）

### 路线 M1：官方数据层 Mod（已验证可行 ✅ 推荐起步）
- **机制**：`StreamingAssets/Base/` 同构目录放入 `<数据根>/Mods/{Culture,Religion,Military,Traits,...}`，游戏按 `CultureManager.LoadCultures()/GetCultureDataIncludingMods()` 加载，且**本地 Mods 优先于 Workshop**（游戏内字符串证据）。
- **已证实**：格式由已安装 Workshop 包与 Base 目录双重复证；`gameConfig.json` 的 `EnabledCultureIDs/EnabledReligionIDs` 控制启用。
- **优点**：零注入、不碰游戏文件、官方机制、绝对不破坏存档兼容。
- **限制**：只能改数据（命名/文化/宗教/军事/特质/Buff/群系/配置），不能改代码行为。

### 路线 M2：用户配置参数扩展（已验证可行 ✅）
- `gameConfig.json` 已暴露 50+ 玩法规则开关与数值。修改它即可改变模拟行为（战争频率、叛乱、附庸、自动存档等）。
- 游戏重写此文件时以内存值为准，因此"运行前修改"是正确用法；工具链必须做备份。

### 路线 M3：BepInEx 6 IL2CPP 插件（技术可行，工程量中 ⏳）
- Unity 2021.3.36f1 + IL2CPP x64 属于 BepInEx 6（bleeding edge, Unity.IL2CPP win-x64）支持矩阵；游戏未加壳（GameAssembly.dll 可被 Il2CppDumper 系工具读取，元数据未加密——REA 已直接解码成功，这是"无防逆向加固"的直接证据）。
- 用途：代码级行为修改（如解除时间倍率上限、注入自定义 UI/参数面板、暴露内部调试接口）。
- 风险：BepInEx 6 为预发布；Il2CppInterop 首次运行需生成交互程序集（耗时长但一次性）。**与 M1/M2 并行不冲突**。
- 决策：作为第二阶段实施，先做 M1/M2 积累可验证成果。

### 路线 M4：解密 Puerts main 包（中期目标 ⏳）
- 若恢复解密逻辑，可直接阅读/修改高层 TS/JS 逻辑，修改成本低于 IL2CPP。
- 前置：Ghidra 反编译 ts-loader 程序集（或运行时 dump 解密后字节）。

### 路线 M5：完整源码重建（= Android 路线 C，见下）

## 2. Android 移植路线评估

### 路线 A：原项目跨平台构建 ❌
- 证据：不存在 Unity 工程文件（无 Assets/ProjectSettings；level0/resources 为编译产物）；C# 源码不可用（IL2CPP 编译，仅可恢复签名级信息）；美术源文件不可用。
- 结论：**不可行**（无源项目，反向重建 Unity 工程成本极高且法律风险高）。

### 路线 B：Winulator/Wine/Box64 类兼容层 ⚠️ 不推荐
- 该游戏依赖 D3D11 + libnode.dll(V8) + x64 IL2CPP，Android 侧需要 x86→ARM 转译 + Windows API 层（Wine/Box64/Winlator 组合），复杂度极高且性能不可控；抖音 SDK/Steam 依赖会进一步阻塞启动。无成熟公开案例支持"IL2CPP x64 Windows 游戏在 Android 兼容层可靠运行"。
- 结论：**放弃**。

### 路线 C：独立重建（✅ 选定）
- **选型：Godot 4.2.2**（本机已有 `E:\Godot\Godot_v4.2.2-stable_win64.exe`）+ 已有 Android SDK（`%LOCALAPPDATA%\Android\Sdk`，含 build-tools/platforms/emulator）+ JDK17（Liberica 17 已装）。
- 对比 Unity：本机无 Unity 编辑器（安装体积大、许可证流程重）；Godot 轻量、2D/矢量地图能力强、支持 headless CLI 导出 APK、单代码库同时出 Windows+Android。
- **重建范围（最小可运行 → 逐步扩大）**：
  1. 六边形/网格世界生成（参考 Azgaar 公开算法思想：抖动网格布点 → 阶梯扩张省份 → 国家生长）
  2. 地图渲染（Polygon2D/自定义 Mesh + 边界线 + 地名标签）
  3. 触屏交互：单指拖动、双指缩放、点选省份
  4. 模拟心跳：国家扩张/战争简化模型，逐月 tick
  5. 本地存档（JSON，无加密，保持前向兼容版本号）
  6. 自定义模块钩子（mods 目录 + 数据驱动规则，与 M1 同构）
- **数据复用决策**：不复制厂商资产；名称数据用自制生成器 + 自由许可名单；存档格式自研。
- **法律边界**：个人本地研究用途；不分发游戏文件；重建代码原创。

## 3. 功能需求清单（自定义功能 v1，可持续追加）

| # | 需求 | 实现路线 | 状态 |
|---|---|---|---|
| F1 | 保留原版玩法与视觉风格 | 不修改原版文件；Mod 走官方接口 | 基线保证 |
| F2 | 改善交互效率 | M3 插件（如自定义热键/快捷时间控制） | 规划 |
| F3 | 更多可配置玩法参数 | M2（gameConfig 扩展管理器）+ M1（规则数据）+ 重建版内置规则面板 | **首批实施** |
| F4 | 扩展模块可独立启停 | M1 Mods 目录天然支持独立启停；重建版设计 mods/ 加载器 | **首批实施** |
| F5 | 不破坏原版数据与存档 | 所有写入仅限 `Mods/`、`gameConfig.json`（带备份）；存档目录只读备份 | 架构约束 |

## 4. 风险登记

| 风险 | 等级 | 缓解 |
|---|---|---|
| Mods 根目录位置未实测确认 | 低 | 实测协议（放置探针包→启动→观察日志）；必要时 Ghidra 确认 |
| BepInEx 与该游戏兼容性未知 | 中 | 先用 M1/M2 交付；BepInEx 做隔离试验（不影响原版启动） |
| Godot Android 导出模板未下载 | 低 | 通过代理下载 4.2.2 模板（一次性） |
| 加密存档第三方解析 | 中 | 不阻塞主线；仅影响"跨端读原版存档"这一子目标 |
| 反编译产物的法律边界 | 低 | 仅个人研究、不分发；优先使用官方 Mod 接口 |
