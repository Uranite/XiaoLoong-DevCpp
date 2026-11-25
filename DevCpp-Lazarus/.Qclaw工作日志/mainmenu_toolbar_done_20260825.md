# DevCpp-Lazarus 主菜单 TToolBar 改造（2026-08-25）

## 目标
Dev-C++ 从 Delphi 移植到 Lazarus/ObjFPC 后，主菜单需：自定义字号跟随 `devData.InterfaceFontSize`、图标/快捷键显示、以及用 TToolBar 替代原生 TMainMenu 实现可控制的顶级菜单间距与 hover 跟踪切换。

## 最终实现（`main.pas`）

### 菜单栏（TToolBar 替代 TMainMenu）
- `CreateToolBarMenuBar`：创建 `fMenuBar`（TToolBar，Align=alTop，Flat，Transparent=False，Color=clMenu，ShowCaptions，Font 跟随 fMenuFontSize/devData.InterfaceFont，List=True，Images=MainMenu.Images），遍历 `MainMenu.Items` 为每个顶级项创建 `tbsButton`（无下拉箭头），末尾 `Menu := nil` 隐藏原生主菜单栏。
- 间距控制：LCL 中手动设 `TToolButton.Width` 不生效（被工具栏布局重算覆盖），改用工具栏级属性 **`fMenuBar.ButtonWidth := maxW + 8`**（循环测量各标题文字宽度取最大值 maxW，统一宽度 → 相邻项约 8px 均匀间隙）。顶级项均为 2 汉字，统一宽度呈标准菜单栏外观。
- `CreatePopupMenuFromMenuItem`：为每个顶级项复制出 TPopupMenu（图标/快捷键/Enabled/Checked/Visible/Default/OnDrawItem/OnMeasureItem），菜单项点击唯一入口 `PopupMenuItemClick`。

### 菜单项点击路由
- `PopupMenuItemClick`：优先执行原始项 `Action.Execute`，否则 `OnClick`（`fOriginalMenuItems` 保存原始项引用）。

### hover 跟踪切换下拉
- `ToolButtonClick` → `PopupForButton(btn)`：用 `TrackPopupMenu(TPM_RETURNCMD)` 弹出，`fOpenBtn` 记录当前展开按钮。
- `SwitchTimerTimer`（TTimer，Interval=80）：仅在下拉打开时启用（`fMenuTrackTimer.Enabled := True/False` 在 PopupForButton 开/关处控制），轮询 `BtnAtMouse` 命中另一按钮 → `Windows.EndMenu` + `PostMessage(WM_USER+300,...)` → `WMMenuSwitch` 关闭旧菜单并 `PopupForButton(新按钮)`。
- `BtnAtMouse`：用 `GetCursorPos` + `ScreenToClient` + `PtInRect(fMenuBar.Buttons[i].BoundsRect)` 命中检测（坐标系统一为工具栏客户端坐标）。
- **关键约束**：Timer 仅在打开下拉时启用；未打开时 hover 不弹菜单（用户确认符合预期）。

### 激活项高亮
- `PopupForButton` 打开时 `btn.Down := True`（凹陷/按下态），关闭时 `fOpenBtn.Down := False`；切换时先复位旧项再高亮新项（用户确认符合预期）。

### 早期已完成的 ObjFPC 迁移（背景）
- `{$mode ObjFPC}{$H+}` 切换、`-dDelphi7` 移除；大量文件修复（事件赋值加 `@`、指针 `^`、TObject 强转、参数名遮蔽、泛型→TList、`$M+`、回调桥接等），`devcfg.pas` 嵌套注释等。编译链已打通（Release 模式 EXITCODE 0）。

## 验证状态（2026-08-25 17:01 用户确认完成）
- 字号跟随 `devData.InterfaceFontSize` ✓
- 下拉菜单图标/快捷键/文本对齐 ✓
- 顶级项间距约 8px、无分隔线、无空按钮悬停高亮 ✓
- 点击弹下拉 ✓；hover 切到另一项自动切换 ✓；点击项后 hover 跟踪停止 ✓
- 激活顶级项高亮显示 ✓

## 已知非阻断项
- `Error: File "devcpp.ico" not found.`（路径大小写，编译不阻断，待清理）。

## 关键文件
- `C:\Users\Administrator\WorkBuddy\2026-DevCpp-Lazarus\DevCpp-Lazarus\main.pas`（主改动）
- 稳定备份：`main-2026.08.25.1037-final.pas`、本轮增量备份 `DevCpp-main-bak2-20260825_160956.pas`
- 工作区遗留大量临时 `_fix_*.ps1` 脚本（可清理，不影响编译）
