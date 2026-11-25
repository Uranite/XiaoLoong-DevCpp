# DevCpp-Lazarus 图标主题菜单项实现（ClassicThemeItem / CleanThemeItem）

日期：2026-09-19
项目：c:\Users\Administrator\WorkBuddy\2026-DevCpp-Lazarus\DevCpp-Lazarus（Dev-C++ / XL7）

## 目标
主菜单 View 下新增的 `IconThemeItem`（子项 `ClassicThemeItem` / `CleanThemeItem`）
实现"切换主菜单与工具栏图标集"的功能，等价于 EnvironOptForm 中 cboTheme 下拉框的图标主题设置。

## 主题映射（用户 12:19 明确）
- ClassicThemeItem → Imageset_Modern  → 主题标题 `'FatCow Modern'`（TTangoImageTheme：
  MenuImages_Modern / ToolImages_Modern32 / ProjectImage_Modern）
- CleanThemeItem   → Imageset_NewLook → 主题标题 `'Basic Outline'`（TNewLookImageTheme：
  MenuImages_NewLook / ToolImages_NewLook32 / ProjectImage_NewLook）

> 说明：`devImageThemes` 实际注册的活跃主题只有两个——Tango('FatCow Modern')、
> NewLook('Basic Outline')；Gnome 已被注释禁用（ImageTheme.pas L551-553）。
> 菜单文案 Classic/Clean 即映射这两个标题。

## 机制调研结论
- 主题应用入口：`TMainForm.LoadTheme`（main.pas L1576+）——依据 `devData.Theme` 标题，
  把 `CurrentTheme.MenuImages/MenuImages32/ProjectImages` 赋给 `ActionList.Images`、
  `MainMenu.Images`、`tbMain.Images`、`tbProjectLeft.Images`、`tbDebugLeft.Images`、
  `ProjectView/BrowserView.Images` 及各弹出菜单 Images。
- 持久化：`devData.Theme`（devcfg.pas L656，published，随 `devData.SaveSelf`）；
  `SaveOptions`（devcfg.pas L843）写盘。启动时 main.pas L1471 调用 `LoadTheme`。
- 顶部菜单栏 `fMenuBar`（CreateToolBarMenuBar，main.pas L2335+）为 LCL TToolBar，按钮为纯文字
  （ShowCaptions），弹出菜单仍走原生 `TrackPopupMenu`；其 `fMenuBar.Images := MainMenu.Images`。
- 菜单项点击路径：fMenuBar 按钮 → `ToolButtonClick`（main.pas L2388+），
  `TrackPopupMenu(subMenu, ... or TPM_RETURNCMD, ...)` 返回选中项 ID，
  再 `FindMenuItemByCommand(MainMenu.Items, selID)`（递归按 `Command` 匹配，main.pas L9828）
  找到 TMenuItem，**若有 Action 则 Execute，否则调用 `item.OnClick(item)`**（L2432-2434）。
  LCL 在创建菜单句柄时为每个 TMenuItem 分配唯一非零 `Command`（menuitem.inc L112
  → OpenCommand/UniqueCommand），故该路径对 OnClick-only 菜单项有效。

## 改动
### main.pas
1. 类声明（L684-687，published 段）新增：
   - `procedure ClassicThemeItemClick(Sender: TObject);`
   - `procedure CleanThemeItemClick(Sender: TObject);`
   - `procedure SetIconTheme(const ATitle: String);`
   - `procedure UpdateIconThemeChecks;`
2. 实现在 actToolBarExecute 之后（L4286+）：
   - `ClassicThemeItemClick` → `SetIconTheme('FatCow Modern')`
   - `CleanThemeItemClick`   → `SetIconTheme('Basic Outline')`
   - `SetIconTheme(ATitle)`：校验 `devImageThemes` 存在与 `IndexOf(ATitle)>=0`；
     若与当前 `devData.Theme` 相同则仅刷新勾选并退出；否则设 `devData.Theme := ATitle`，
     调 `LoadTheme` 应用图标，同步 `fMenuBar.Images := MainMenu.Images`，刷新勾选，
     调 `SaveOptions` 立即持久化。
   - `UpdateIconThemeChecks`：按当前主题标题设置两项的 `Checked`（单选式勾选）。
3. 启动初始化：`LoadTheme;`（L1471）后追加 `UpdateIconThemeChecks;`（L1476）。
4. 环境选项联动：`actEnviroOptionsExecute` 内 `if devData.ThemeChange then Loadtheme;` 之后
   追加 `UpdateIconThemeChecks;`（L5575），使经 cboTheme 改主题后菜单勾选同步。

### main.lfm
- `ClassicThemeItem` 增加 `OnClick = ClassicThemeItemClick`（L1375）
- `CleanThemeItem`   增加 `OnClick = CleanThemeItemClick`（L1379）

## 构建验证
- `cd 项目目录` → `C:\lazarus\lazbuild.exe _b6.lpi -B`
- 结果：exit code 0，`55985 lines compiled, 7.8 sec, 5017840 bytes code, 1055412 bytes data`
- 无新增 Error；仅既有 Warning（4056/4104/5043/5044 等，按既定口径保留）。
- 产物：C:\Users\Administrator\.qclaw\workspace\_b6\DevCpp.exe

## 待用户实测
1. View → Icon Theme → Classic / Clean，确认主菜单弹出图标与工具栏
   （tbMain 32px / tbProjectLeft / tbDebugLeft）图标即时切换。
2. 确认两项勾选状态正确（单选）。
3. 重启后主题保持（SaveOptions 已写盘）。
4. 经环境选项 cboTheme 改主题后，菜单勾选同步。

## 备注
- `SaveOptions` 每次点击即写 ini，行为与传统"退出时保存"略有差异，属预期（即时生效）。
- 若某项主题缺失（图片未加载，IndexOf<0），`SetIconTheme` 直接返回、不做任何变更。
