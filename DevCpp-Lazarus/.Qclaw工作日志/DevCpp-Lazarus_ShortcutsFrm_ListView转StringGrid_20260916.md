# ShortcutsForm TListView → TStringGrid 迁移

## 日期
2026-09-16

## 原因
TListView 不自动适应 MetaDarkStyle 深色模式，TStringGrid 作为 LCL 原生控件可正确响应主题色。

## 修改文件

### ShortcutsFrm.lfm
- `lvShortcuts: TListView` → `TStringGrid`
- 删除 `Columns` / `ColumnClick` / `ReadOnly` / `RowSelect` / `ViewStyle` 等 TListView 属性
- 新增 `ColCount=2` / `FixedCols=0` / `FixedRows=1` / `DefaultRowHeight=18` / `Options=[goFixedHorzLine,goFixedVertLine,goHorzLine,goVertLine,goDrawFocusSelected,goRowSelect,goSmoothLoading]`
- `OnCustomDrawItem` → `OnPrepareCanvas`

### ShortcutsFrm.pas
- uses 增补 `Grids`
- `lvShortcuts: TListView` → `TStringGrid`
- `lvShortcutsCustomDrawItem` → `lvShortcutsPrepareCanvas`（斑马纹逻辑改用 `gdSelected` / `Row mod 2`）
- LoadText：`Columns[N].Caption` → `Columns[N].Title.Caption` + 显式设 `Width`
- BeginUpdate/EndUpdate：`lvShortcuts.Items.BeginUpdate` → `lvShortcuts.BeginUpdate`
- AddShortcut：`Items.Add` + `Caption`/`SubItems.Add`/`Data` → `RowCount+1` + `Cells[0,Row]`/`Cells[1,Row]` + `Objects[0,Row]`
- Clear：`lvShortcuts.Clear` → `RowCount:=1` + `Clean(0,1,1,0,[gzNormal])`
- Count：`Items.Count` → `RowCount - 1`
- GetShortCut：`Items[Index].Data` → `Objects[0, Index+1]`（+1 跳 fixed row）
- lvShortcutsKeyDown：`lvShortcuts.Selected`/`ItemIndex`/`Items[I].Caption`/`Items[I].Data`/`SubItems[0]` → `lvShortcuts.Row`/`Cells[0,I]`/`Objects[0,I]`/`Cells[1,Row]`；行号从 1 开始（跳 fixed row）
- btnResetAllClick：同上模式转换
- btnResetCurrentClick：`lvShortcuts.ItemIndex` → `lvShortcuts.Row`；`Items[...].Caption/Data/SubItems[0]` → `Cells[0,...]`/`Objects[0,...]`/`Cells[1,...]`

### main.pas
- 无改动（调用接口 `BeginUpdate`/`EndUpdate`/`AddShortcut`/`Count`/`ShortCuts[I]` 保持不变）

## 构建验证
- exit code 0，55509 lines compiled，0 Error

## 设计口径
- PShortCutItem 指针存于 `lvShortcuts.Objects[0, Row]`
- 数据行从 Row=1 开始（Row=0 是 fixed header）
- GetShortCut(Index) 内部做 Index+1 转换，对外仍 0-based
- 斑马纹：偶数行 clWindow，奇数行 $E0E0E0（与原 TListView 逻辑一致）
