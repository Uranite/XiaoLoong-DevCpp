# 菜单弹出窗口白边修复（MetaDarkStyle NC 边框）

## 日期
2026-09-16

## 问题
启用 MetaDarkStyle 深色模式后，主菜单下拉弹出的菜单窗口四周有明显的白色边框。

## 根因
项目已用 TToolBar（fMenuBar）替代原生菜单条，点击按钮后调用 Win32 `TrackPopupMenu` 弹出下拉菜单。这个弹出窗口是系统原生 `#32768` 类 MENU 窗口，其非客户区（NC border）由系统 `WM_NCPAINT` 画，使用浅色系统颜色。MetaDarkStyle hook 了 `DrawThemeBackground`（客户区绘制）和 `SetMenuInfo`（背景色），但**没有 hook 弹出菜单窗口的 `WM_NCPAINT`**，因此 NC 边框保持白色。

MetaDarkStyle 的 `FormWndProc2` 只处理主窗口（TCustomForm）的 `WM_NCPAINT`，不处理系统创建的菜单 popup 窗口（`_CreateWindowExW` hook 也只拦截 LCL TCustomForm 的创建）。

网络资料提到的 `TMainMenuToolBar` 是 Delphi VCL 组件，LCL 中不存在。且 LCL 的 `TPopupMenu.PopUp` 在 Win32 后端底层同样调 `TrackPopupMenuEx`，换 TPopupMenu 不能解决 NC 白边。

## 修复方案
在 `ToolButtonClick` 中 `TrackPopupMenu` 调用前安装 `WH_CALLWNDPROC` hook，拦截菜单 popup 窗口的 `WM_CREATE`，subclass 其窗口 proc；在 `WM_NCPAINT`/`WM_NCACTIVATE` 时用深色（RGB 35,35,35）填充非客户区。`TrackPopupMenu` 返回后卸载 hook。

## 修改文件

### main.pas
1. **新增全局变量**（~L1058）：
   - `MenuNCHook: HHOOK = 0`
   - `MenuNCOldProc: Windows.WNDPROC = nil`

2. **新增 forward 声明**（~L1066-1067）：
   - `MenuNCHookProc`
   - `MenuNCWndProc`

3. **新增实现**（~L9794）：
   - `MenuNCHookProc`：`WH_CALLWNDPROC` 回调，检测 `WM_CREATE` + 类名 `#32768`，subclass 窗口 proc
   - `MenuNCWndProc`：处理 `WM_NCPAINT`/`WM_NCACTIVATE`，先让默认 proc 画，再用深色 FillRect 覆盖非客户区（排除客户区 clip）

4. **ToolButtonClick 修改**（~L2406/2419）：
   - 调用前：`MenuNCHook := SetWindowsHookEx(WH_CALLWNDPROC, @MenuNCHookProc, 0, GetCurrentThreadId)`
   - 调用后：`UnhookWindowsHookEx(MenuNCHook); MenuNCHook := 0; MenuNCOldProc := nil`

### uWin32WidgetSetDark.pas（MetaDarkStyle 包）
- L1151：`MENU_POPUPSEPARATOR` 加入排除列表（分隔线背景填充修复，保留）
  - 原：`if not (iPartId in [MENU_POPUPSUBMENU, MENU_POPUPCHECK, MENU_POPUPCHECKBACKGROUND]) then`
  - 改：`if not (iPartId in [MENU_POPUPSUBMENU, MENU_POPUPCHECK, MENU_POPUPCHECKBACKGROUND, MENU_POPUPSEPARATOR]) then`
  - 这个修复让分隔线也获得深色背景填充（之前跳过，直接画线在白底上），与 NC 边框修复互补

## 构建验证
- exit code 0，55566 lines compiled，exe 81MB+
- 0 Error

## 设计口径
- NC 边框颜色 RGB(35,35,35) 与 DefaultDark 的 COLOR_BTNSHADOW 一致
- hook 生命周期：仅在 TrackPopupMenu 调用期间安装，调用后立即卸载
- subclass 恢复：hook 卸载后菜单窗口已销毁，MenuNCOldProc 置 nil
- 不影响 LCL TPopupMenu（它底层也走 TrackPopupMenuEx，但通常不经过 ToolButtonClick 路径）
