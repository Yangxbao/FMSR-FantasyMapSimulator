# 测试记录：游戏启动与本地 Mods 加载验证

- 日期：2026-10-29 23:49–23:55
- 方式：真实启动游戏（Steam 运行中），读取 Player.log，纯只读分析 + 用户目录配置变更（带备份）

## 执行步骤与结果

1. **基线记录** → 启动 `FantasyMapSimulator.exe` → 游戏完全引导（进程内存 1.48GB）。
2. **Player.log 关键证据**（`C:\Users\MR\AppData\LocalLow\The Stranger Studio\FantasyMapSimulator\Player.log`）：
   - `L557: Culture directory not found: e:/steam/steamapps/common/FantasyMapSimulator/FantasyMapSimulator_Data/StreamingAssets\Mods/Culture`
   - `L6808: 宗教目录不存在: ...StreamingAssets\Mods/Religion`
   - `L465: 成功加载文化: Ciestundu (类型: Base, 州名数量: 50, 城市名数量: 250)`
   - `L7482+: 加载宗教: <名> (稳定ID: mods_<workshopid>_<名>) 来自宗教集: Workshop_<id>`
3. **结论（已验证）**：
   - 本地 Mods 根目录 = `<安装目录>/FantasyMapSimulator_Data/StreamingAssets/Mods/`（非 persistentDataPath）
   - 文化包加载日志格式：`成功加载文化: <名> (类型: <Base|...>, 州名数量: N, 城市名数量: M)`
   - 名称 CSV 必须为 15 列多语言表头（`Key,Chinese,English,...`），列数不符的行被跳过（L473 原文警告）
4. **关闭测试**：游戏以管理员权限运行（`__COMPAT_LAYER=DetectorsAdminProtection`，metasec 反篡改），非提权会话 `taskkill /F`、`Stop-Process -Force` 均被拒（拒绝访问），UI 自动化被 Windows UIPI 阻断。`CloseMainWindow` 返回 True 后游戏弹出游戏内退出确认框并停留。
   - **影响**：退出确认需用户手动点击；下次启动即会加载 Auroria 文化包，验证判据为出现 `成功加载文化: Auroria (类型: ...)` 日志行。
5. **配置编辑验证**：`minMonthToBeginAnotherWar` 12→6→12（往返），自动备份正常。恢复原值后再启动游戏，避免配置漂移。

## Auroria 文化包（第一个实际功能）

- 生成：`python source/fms-modkit/fms_modkit.py new-culture Auroria --display 奥瑞利亚 ...`
- 安装位置（游戏官方本地 Mod 加载点，纯新增、未覆盖任何原版文件）：
  `E:\steam\steamapps\common\FantasyMapSimulator\FantasyMapSimulator_Data\StreamingAssets\Mods\Culture\Auroria\`
- 格式与 Base/Workshop 包同构：CultureData.json（政体/特质/族群概率）+ 5 个 15 列名称 CSV
- 卸载：`python source/fms-modkit/fms_modkit.py uninstall-culture Auroria`（整目录删除，零残留）

## 待办（下次游戏启动时完成验证）

- [ ] Player.log 出现 `成功加载文化: Auroria`
- [ ] 游戏内 设置→文化 面板出现 Auroria
