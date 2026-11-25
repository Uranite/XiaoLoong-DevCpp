# DevCpp SynEdit → ATSynEdit 迁移记录

## 迁移目标
- Delphi → Lazarus 4.6
- SynEdit 2.1.1 → ATSynEdit

## 2026-11-25 状态审计

> 下文保留了 2026-05 的迁移过程记录,其中部分“剩余 TODO”已在后续版本完成。当前待办以 `!todo(orwell).txt` 和 `docs/ARCHITECTURE.md` 第 9.2 节为准。

已实现但旧清单仍列为待办:

- [x] HTML / RTF / TeX 导出 — `TEditor.ExportToHTML`、`TEditor.ExportToRTF`、`TEditor.ExportToTEX`
- [x] 注释 / 取消注释 / 切换注释(整行与行内)— `main.pas` 中 `actCommentExecute`、`actUncommentExecute`、`actToggleCommentExecute`、`actToggleCommentInlineExecute`
- [x] 选中词全部高亮 — `TEditor.UpdateSelectionHighlight`
- [x] 工程单元重命名 — `TMainForm.actUnitRenameExecute`
- [x] 断点 gutter 与行背景 — ATSynEdit `GutterDecor` + `Bookmarks2` + `OnCalcBookmarkColor`
- [x] 书签、折叠、括号匹配 — 使用 ATSynEdit 原生能力

仍需处理:

- [ ] EControl 颜色/属性映射（`EditorOptFrm.pas` 中 3 处 `TODO: EControl adapter` 及折叠颜色）
- [ ] 补全逻辑中的 EControl 高亮属性过滤(当前无属性时回退为普通搜索)
- [ ] 删除或整合已无运行时用途的 `TDebugGutter` / `DebugAfterPaint`
- [ ] 其余功能项见 `!todo(orwell).txt`

## 关键文件
- `Editor.pas` - 核心编辑器封装（约 3650 行）
- `main.pas` - 主窗体（约 9100 行）
- `devcfg.pas` - 配置管理（约 3600 行）
- `CodeToolTip.pas` - 函数提示
- `CodeCompletion.pas` - 代码补全

## uses 替换映射

### Editor.pas 替换对照表

| 原 SynEdit 单元 | 替换为 | 备注 |
|-----------------|--------|------|
| `SynEdit` | `ATSynEdit` | 核心组件 |
| `SynEditKeyCmds` | `ATSynEdit` | 命令已内置 |
| `SynEditCodeFolding` | `ATSynEdit` | 折叠已内置 |
| `SynHighlighterCpp` | `EControl` 或自定义 | 需要适配 |
| `SynEditTextBuffer` | 标准 `Classes` | ATSynEdit 使用标准 TStrings |
| `SynEditTypes` | `ATSynEdit` | 类型已内置 |
| `SynEditHighlighter` | `ATSynEdit` | 高亮器接口 |
| `SynEditExport` | 暂时禁用 | 导出功能 |
| `SynExportHTML` | 暂时禁用 | HTML 导出 |
| `SynExportRTF` | 暂时禁用 | RTF 导出 |
| `SynExportTeX` | 暂时禁用 | TeX 导出 |
| `SynEditMiscClasses` | `ATSynEdit` | 杂项类 |

## 类型替换映射

| 原类型 | 替换为 | 备注 |
|--------|--------|------|
| `TSynEdit` | `TATSynEdit` | 主编辑器组件 |
| `TBufferCoord` | `TPoint` | 坐标类型 |
| `TSynEditPlugin` | `TATSynEdit_PluginBase` | 插件基类 |
| `TSynStatusChanges` | `TATStatusChanges` | 状态变更 |
| `TSynReplaceAction` | `TATReplaceAction` | 替换动作 |
| `TSynEditMark` | 自定义书签 | ATSynEdit 使用不同系统 |
| `TSynEditSearch` | `TATSearch` | 搜索组件 |
| `TSynFoldRanges` | `TATFold` | 代码折叠 |
| `TSynGutter` | 内置属性 | Gutter 属性化 |

## 事件替换映射

| 原事件 | 替换为 | 备注 |
|--------|--------|------|
| `OnStatusChange` | `OnStatusChanged` | 签名类似 |
| `OnReplaceText` | 事件系统不同 | 需要适配 |
| `OnDropFiles` | `OnDropFiles` | 可能存在 |
| `OnGutterClick` | `OnClickGutter` | 签名不同 |
| `OnSpecialLineColors` | `OnPaintLine` | 需要重写 |
| `OnScanForFoldRanges` | `OnFoldWasChanged` | 折叠提供者 |
| `OnPaintTransient` | `OnPaintLine` | 绘制逻辑重写 |

## 迁移进度

### ✅ 已完成 — Editor.pas 全部迁移
- [x] Editor.pas uses 子句更新
- [x] TDebugGutter 类迁移（TSynEditPlugin → TATSynEdit_PluginBase）
- [x] TEditor 类型定义更新（TSynEdit → TATSynEdit）
- [x] 事件签名更新（EditorStatusChange, EditorGutterClick, EditorPaintLine 等）
- [x] 构造函数更新（TSynEdit.Create → TATSynEdit.Create）
- [x] SetCaretPosAndActivate → ATSynEdit CaretPos (TPoint, 0-based)
- [x] InvalidateGutterLine → InvalidateLine（ATSynEdit 不支持）
- [x] BufferCoord() → Point() / TPoint（全部替换）
- [x] TBufferCoord → TPoint（全部替换）
- [x] TDisplayCoord → TPoint（替换）
- [x] TSynHighlighterAttributes → TATSynHighlighterAttributes
- [x] TSynStateFlags / sfWaitForDragging → 移除（ATSynEdit 不支持）
- [x] InsertString 更新（CaretXY → CaretPos）
- [x] ExportToHTML/RTF/TEX → 禁用（ATSynEdit 无 SynExporter）
- [x] Bookmark API → BookmarkSet/BookmarkDelete/BookmarkGoto（ATSynEdit）
- [x] HandleSymbolCompletion → BufferCoord → TPoint，CaretXY → CaretPos
- [x] HandleCodeCompletion → ATSynEdit GetHighlighterAttriAtRowCol (TPoint)
- [x] CompletionKeyPress → ATSynEdit 类型更新
- [x] CompletionTimer → ATSynEdit CaretPos 比较逻辑
- [x] ShowCompletion → CaretPosToClientXY 替换 RowColumnToPixels
- [x] GetWordAtPosition(TBufferCoord→TPoint) → 0-based TPoint 处理
- [x] CompletionInsert → GetWordStartAtCaretPos / CaretPosToStrPos
- [x] EditorDblClick / EditorClick → TBufferCoord → TPoint，移除 TSynStateFlags
- [x] EditorMouseMove → TBufferCoord → TPoint，GetWordUnderCaret 等
- [x] HandpointAllowed → TBufferCoord → TPoint，TSynHighlighterAttr → TAT
- [x] EditorKeyDown → TBufferCoord → TPoint
- [x] EditorMouseUp → TDisplayCoord → TPoint，PixelsToRowColumn → ClientPosToCaretPos
- [x] EditorDropFiles → DisplayToBufferPos → ClientPosToCaretPos
- [x] EditorReplaceText → CaretPosToDisplay → CaretPosToClientXY
- [x] FunctionTipAllowed → 移除 IsScrolling
- [x] IndentSelection / UnindentSelection → BlockBegin/End → SelAvail
- [x] ScanForFoldRanges → 存根（ATSynEdit 内置折叠，不需要回调）
- [x] EditorPaintTransient → 存根（括号匹配由 ATSynEdit 内置）

### ✅ 已完成 — 批量 .dfm → .lfm 格式转换（38个）
- [x] 所有 Delphi 文本格式 .dfm 转换为 Lazarus .lfm 格式
- [x] 对应 .pas 中 `{$R *.dfm}` → `{$R *.lfm}` 全部更新
- [x] CPUFrm.dfm → CPUFrm.lfm（手动更新 TSynEdit → TATSynEdit）
- [x] FormatterOptionsFrm.lfm 自动更新 TSynEdit → TATSynEdit
- [x] 原始 .dfm 文件全部删除（保留 EditorOptFrm.bak.dfm 备份文件）
- [x] EditorOptFrm.lfm / LangFrm.lfm 保留 TSynEdit（等待 .pas 迁移完成后再更新）

### ✅ 已完成 — 其余表单文件 TSynEdit → TATSynEdit
- [x] LangFrm.pas：synExample 类型 TSynEdit → TATSynEdit，移除 SynEditTypes uses
- [x] Project.pas：临时 workeditor 改为 TStringList，移除 SynEdit uses
- [x] EditorOptFrm.pas：3个 TSynEdit → TATSynEdit，TSynCppSyn → TObject（占位符），事件签名更新
- [x] EditorOptFrm.lfm：所有 TSynEdit → TATSynEdit
- [x] 其他 API 调用：CaretXY→CaretPos，TSynStatusChanges→TATStatusChanges 等

### ✅ 已完成 — Editor.pas ATSynEdit API 全面修复（2026-05-15）
- [x] 事件绑定修复：OnClickGutter 更新为 TATSynEditClickGutterEvent 签名
- [x] OnDblClick → OnClickDouble（使用 TATSynEditClickEvent 签名）
- [x] 代码折叠启用：OptFoldEnabled := True
- [x] InvalidateLine → Invalidate（所有 7 处调用）
- [x] Bookmark API 迁移：BookmarkSet → BookmarkSetForLine（带完整参数）
- [x] BookmarkDelete → BookmarkDeleteForLine
- [x] BookmarkGoto → CaretPos 直接跳转
- [x] EnsureCaretVisible → DoGotoCaret
- [x] SelText → DoCommand(cCommand_TextInsert, ...)
- [x] GetWordUnderCaret → TextCurrentWord
- [x] SelText（读取）→ TextSelected 函数
- [x] ClientPosToCaretPos 启用
- [x] CaretPosToClientXY → CaretPosToClientPos（部分修复）
- [x] IndentSelection/UnindentSelection → DoCommand(cCommand_TextIndent/Unindent)
- [x] HandpointAllowed 重写（移除 TATSynHighlighterAttributes 依赖）
- [x] hprNone 枚举和 case 恢复
- [x] LineText → Strings.Lines[]（3 处）
- [x] SelectLineAtCaret → DoSelect_Line（三击选行）
- [x] CompletionInsert：手动词边界计算替代 GetWordStartAtCaretPos
- [x] EditorDropFiles 修复（ClientPosToCaretPos + DoCommand）
- [x] EditorDblClick/EditorClick 事件签名更新
- [x] EditorKeyDown 中 LineText 修复
- [x] UndoSymbolCompletion 中 LineText 修复
- [x] Result := hprNone 默认返回值修复
- **总计：40 个 TODO 已修复（65→25）**

### ✅ Editor.pas 旧 TODO 复核（2026-11-25）

早期清单中的导出与定位项已完成，剩余项已改为降级实现或仍需 EControl 适配：
- [x] 导出功能（HTML/RTF/TEX）— 已用 ATSynEdit 行片段 API 实现
- [x] ShowCompletion / EditorReplaceText 定位 — 已改用 `CaretPosToClientPos`
- [x] HandleSymbolCompletion 行文本获取 — 已改用 `Strings.Lines`
- [ ] EControl 高亮器属性检查（dmMain.Cpp → AdapterForHilite）
- [ ] 代码补全过滤逻辑（CompletionKeyPress）— 当前无高亮属性时回退为普通搜索
- [ ] HandleCodeCompletion 基于高亮器的触发逻辑 — 当前使用简化回退

### ✅ 已完成 — main.pas ATSynEdit API 修复（2026-05-15）
- [x] SelAvail 检查 → CaretsSel.IsEmpty（4 处：actCut/actCopy/actToggleCommentInline/AddWatch）
- [x] SelText 读取 → TextSelected（5 处：查找/替换/文件中查找/AddWatch）
- [x] WordAtCursor → TextCurrentWord（5 处：同上 + ParseToolParams）
- [x] 删除行 ecDeleteLine → DoCommand(cCommand_TextDeleteLine)
- [x] 复制行 ecDuplicateLine → DoCommand(cCommand_TextDuplicateLine)
- [x] 上移 ecMoveSelUp → DoCommand(cCommand_MoveSelectionUp)
- [x] 下移 ecMoveSelDown → DoCommand(cCommand_MoveSelectionDown)
- [x] 全部展开 UncollapseAll → DoCommand(cCommand_UnfoldAll)
- [x] 全部折叠 CollapseAll → DoCommand(cCommand_FoldAll)
- [x] SetSelWord → DoCommand(cCommand_SelectWords)
- [x] BlockBegin → Carets[0] 直接操作
- [x] ClearSelection → DoCommand(cCommand_SelectNone)
- [x] LinesInWindow → LineBottom 替换（2 处）
- [x] OldCaretXY → Carets[0].PosX/Y 读写（格式化恢复）
- [x] **总计：30 个 TODO 已修复（46→16）**

### ✅ main.pas 旧 TODO 复核（2026-11-25）

- [x] Comment/Uncomment/ToggleComment — 已在 `actCommentExecute` / `actUncommentExecute` / `actToggleCommentExecute` 中手动实现
- [x] CommentInline — 已在 `actToggleCommentInlineExecute` 中实现
- [x] PrinterSetup — 已实现打印与打印设置
- [ ] dmMain.Cpp 引用 — `LoadColor` 等仍有占位，需 EControl 适配器提供颜色
- [ ] SelLength / Lines.Capacity — Delphi 专有属性，ATSynEdit 无等价物，保持移除
- [ ] ShortenLogOutput — 当前为 no-op
- [ ] Gutter.Font — 已由 ATSynEdit 的独立 gutter 字体设置替代，旧调用需清理

### 关键 API 对照表（ATSynEdit vs SynEdit）

| SynEdit | ATSynEdit | 说明 |
|---------|-----------|------|
| `BufferCoord(col, line)` | `Point(col-1, line-1)` | **0-based** |
| `CaretXY` | `CaretPos` (TPoint, 0-based) | 光标位置 |
| `CaretXY.Char` | `CaretPos.X + 1` | 列号转换 |
| `CaretXY.Line` | `CaretPos.Y + 1` | 行号转换 |
| `CaretX` (1-based) | `CaretX` (1-based) | 兼容 |
| `CaretY` (1-based) | `CaretY` (1-based) | 兼容 |
| `Lines[i-1]` (0-based) | `Lines[i-1]` (0-based) | 相同 |
| `GetHighlighterAttriAtRowCol(BufferCoord)` | `GetHighlighterAttriAtRowCol(TPoint 0-based)` | 签名变 |
| `BlockBegin/BlockEnd` | `SelAvail` | 判断是否有选区 |
| `SetBookmark(n,col,line)` | `BookmarkSetForLine(line-1, 0, '', True, True, n)` | 书签设置（参数完全不同） |
| `ClearBookMark(n)` | `BookmarkDeleteForLine(line-1)` | 书签删除（按行删除） |
| `GotoBookMark(n)` | `Carets[0].PosY := BookmarkLines[n]-1; DoGotoCaret()` | 书签跳转（直接设光标） |
| `RowColumnToPixels(DisplayXY)` | `CaretPosToClientPos(CaretPos)` | 光标像素位置（返回 TATPoint） |
| `PixelsToRowColumn(x,y)` | `ClientPosToCaretPos(Point(x,y))` | 像素转文本位置 |
| `SelText (get)` | `TextSelected` | 获取选中文本（函数） |
| `SelText (set)` | `DoCommand(cCommand_TextInsert, ...)` | 设置选中文本 |
| `Lines[i-1]` (0-based) | `Strings.Lines[i-1]` (0-based) | 相同 |
| `LineText` | `Strings.Lines[CaretY-1]` | 行文本读取 |
| `GetWordUnderCaret` | `TextCurrentWord` | 光标下单词 |
| `SelectLineAtCaret` | `DoSelect_Line(CaretPos)` | 选择行 |
| `CollapseAll` | `DoCommand(cCommand_FoldAll, ...)` | 全部折叠 |
| `UncollapseAll` | `DoCommand(cCommand_UnfoldAll, ...)` | 全部展开 |
| `IsScrolling` | **不支持，移除** | 滚动中判断 |
| `InvalidateGutterLine(n)` | `Invalidate` | 使用全量重绘 |
| `InvalidateLine(n)` | `Invalidate` | 使用全量重绘 |
| `OnDblClick` | `OnClickDouble` | 双击事件（签名不同） |
| `OnClickSpecialLine` | `OnDrawLine` | 特殊行点击/绘制 |
| `OnGutterClick` | `OnClickGutter` | 签名变为 (Sender, ABand, ALineNum, var AHandled) |
| `SynExporterHTML/RTF/TEX` | **不支持** | 需要重新实现 |
| `TSynHighlighterAttributes` | `TATSynHighlighterAttributes` | 通过 EControl 适配器获取 |
| `InvalidateGutterLine(n)` | *(不支持，用 InvalidateLine)* | |
| `IsScrolling` | *(不支持，移除)* | |
| `WordStart/WordEnd.Char` | `GetWordStartAtCaretPos` | 词边界 |
| `RowColToCharIndex` | `CaretPosToStrPos` | 字符索引 |

## 已完成的修改

### Editor.pas 修改清单

| 修改类型 | 数量 |
|---------|------|
| uses 单元替换 | 全部完成 |
| 类型替换 | 30+ 处 |
| 方法签名更新 | 20+ 处 |
| API 调用替换 | 50+ 处 |
| TDebugGutter 重写 | 完成 |
| Export 功能禁用 | 完成 |
| Bookmark API 更新 | 完成 |

## 修改记录

| 日期 | 文件 | 修改内容 |
|------|------|----------|
| 2026-05-12 | Editor.pas | uses 子句 SynEdit → ATSynEdit |
| 2026-05-12 | Editor.pas | TDebugGutter 迁移到 ATSynEdit |
| 2026-05-12 | Editor.pas | TEditor 类型定义更新 |
| 2026-05-12 | Editor.pas | 事件处理签名更新 |
| 2026-05-12 | Editor.pas | 构造函数更新 |
| 2026-05-12 | Editor.pas | HandleSymbolCompletion 全部更新 |
| 2026-05-12 | Editor.pas | 全部 BufferCoord → TPoint 替换完成 |
| 2026-05-12 | Editor.pas | Bookmark API 更新（SetBookmark → BookmarkSet 等）|
| 2026-05-12 | Editor.pas | Export 方法禁用（SynExporter 不可用）|
| 2026-05-12 | Editor.pas | ScanForFoldRanges / EditorPaintTransient 存根化 |
| 2026-05-12 | Editor.pas | 所有 SynEdit 专有 API 清理完毕 ✅ |