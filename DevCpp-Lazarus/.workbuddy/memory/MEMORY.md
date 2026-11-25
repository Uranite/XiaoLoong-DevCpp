# MEMORY.md - DevCpp ATSynEdit 迁移工作记录

## 标准库头文件只读打开（2026-06-29）
- Editor.pas `TEditor.Create` 构造函数中，`EditorStatusChange` 之前添加判断
- `if not fNew and MainForm.CppParser.IsSystemHeaderFile(fFileName) then fText.ModeReadOnly := True`
- `IsSystemHeaderFile` → `cbutils.IsSystemHeaderFile`：检查文件目录是否在编译器 include paths 中
- 参考 RedPanda 版（Editor.panda.pas:480-483）

## BrowserView 字体与间距修复（2026-06-11/12）
- **问题1**（鼠标移入字体变小）：BrowserView LFM 中 `ParentFont=False`, `Font.Height=-16`（≈8pt）。`LoadColor` 仅设 `Font.Size`+`Color` 不足，widgetset handle 重建时 LFM 默认值被重新应用
- **修复1**：`LoadColor` 中显式 `ParentFont:=False`，逐个设 Name/Size/Color/Style/CharSet（不用 Assign）
- **问题2**（垂直间距变小）：用户分析根因在 `BrowserViewAdvancedCustomDrawItem` 的 `cdPrePaint` 阶段，只设 `Canvas.Font.size` 不影响 item 高度计算。TTreeView item 高度由控件自身 `Font` 驱动
- **修复2**：新增 `BrowserViewAdvancedCustomDraw` 树级事件，`cdPrePaint` 阶段 `Sender.Canvas.Font.Assign(Sender.Font)` + 计算 `ItemH:=Abs(Font.Height)+6`，设 `DefaultItemHeight:=ItemH`。用 `DefaultItemHeight <> ItemH` 守卫防递归重绘
