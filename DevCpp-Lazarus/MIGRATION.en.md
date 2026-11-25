# DevCpp SynEdit -> ATSynEdit Migration Record

> Chinese version: [MIGRATION.md](MIGRATION.md)

## Migration Goals

- Delphi -> Lazarus 4.6
- SynEdit 2.1.1 -> ATSynEdit

## 2026-11-25 Status Audit

> The sections below preserve the migration log from May 2026. Some "remaining TODO" items listed there were completed in later versions. For the current TODO list, see `!todo(orwell).txt` and section 9.2 of `docs/ARCHITECTURE.md`.

Implemented, but still listed as TODO in the old checklist:

- [x] HTML / RTF / TeX export - `TEditor.ExportToHTML`, `TEditor.ExportToRTF`, `TEditor.ExportToTEX`
- [x] Comment / uncomment / toggle comment (line and inline) - `actCommentExecute`, `actUncommentExecute`, `actToggleCommentExecute`, and `actToggleCommentInlineExecute` in `main.pas`
- [x] Highlight all occurrences of the selected word - `TEditor.UpdateSelectionHighlight`
- [x] Project unit rename - `TMainForm.actUnitRenameExecute`
- [x] Breakpoint gutter and line backgrounds - ATSynEdit `GutterDecor` + `Bookmarks2` + `OnCalcBookmarkColor`
- [x] Bookmarks, folding, and bracket matching - native ATSynEdit capabilities

Still to do:

- [ ] EControl color/attribute mapping (3 `TODO: EControl adapter` markers and fold colors in `EditorOptFrm.pas`)
- [ ] EControl highlighter-attribute filtering in completion logic (currently falls back to a plain search when attributes are unavailable)
- [ ] Remove or consolidate `TDebugGutter` / `DebugAfterPaint`, which no longer serve a runtime purpose
- [ ] See `!todo(orwell).txt` for the remaining feature items

## Key Files

- `Editor.pas` - core editor wrapper (~3,650 lines)
- `main.pas` - main form (~9,100 lines)
- `devcfg.pas` - configuration management (~3,600 lines)
- `CodeToolTip.pas` - code hints
- `CodeCompletion.pas` - code completion

## `uses` Replacement Map

### Editor.pas replacement table

| Original SynEdit unit | Replacement | Notes |
|-----------------------|-------------|-------|
| `SynEdit` | `ATSynEdit` | Core component |
| `SynEditKeyCmds` | `ATSynEdit` | Commands are built in |
| `SynEditCodeFolding` | `ATSynEdit` | Folding is built in |
| `SynHighlighterCpp` | `EControl` or custom | Needs adaptation |
| `SynEditTextBuffer` | Standard `Classes` | ATSynEdit uses standard `TStrings` |
| `SynEditTypes` | `ATSynEdit` | Types are built in |
| `SynEditHighlighter` | `ATSynEdit` | Highlighter interface |
| `SynEditExport` | Temporarily disabled | Export functionality |
| `SynExportHTML` | Temporarily disabled | HTML export |
| `SynExportRTF` | Temporarily disabled | RTF export |
| `SynExportTeX` | Temporarily disabled | TeX export |
| `SynEditMiscClasses` | `ATSynEdit` | Miscellaneous classes |

## Type Replacement Map

| Original type | Replacement | Notes |
|---------------|-------------|-------|
| `TSynEdit` | `TATSynEdit` | Main editor component |
| `TBufferCoord` | `TPoint` | Coordinate type |
| `TSynEditPlugin` | `TATSynEdit_PluginBase` | Plugin base class |
| `TSynStatusChanges` | `TATStatusChanges` | Status changes |
| `TSynReplaceAction` | `TATReplaceAction` | Replace action |
| `TSynEditMark` | Custom bookmarks | ATSynEdit uses a different system |
| `TSynEditSearch` | `TATSearch` | Search component |
| `TSynFoldRanges` | `TATFold` | Code folding |
| `TSynGutter` | Built-in property | Gutter is property-based |

## Event Replacement Map

| Original event | Replacement | Notes |
|----------------|-------------|-------|
| `OnStatusChange` | `OnStatusChanged` | Similar signature |
| `OnReplaceText` | Different event system | Needs adaptation |
| `OnDropFiles` | `OnDropFiles` | May exist |
| `OnGutterClick` | `OnClickGutter` | Different signature |
| `OnSpecialLineColors` | `OnPaintLine` | Needs rewriting |
| `OnScanForFoldRanges` | `OnFoldWasChanged` | Fold provider |
| `OnPaintTransient` | `OnPaintLine` | Drawing logic must be rewritten |

## Migration Progress

### Completed - full Editor.pas migration

- [x] `Editor.pas` `uses` clause updated
- [x] `TDebugGutter` class migrated (`TSynEditPlugin` -> `TATSynEdit_PluginBase`)
- [x] `TEditor` type definitions updated (`TSynEdit` -> `TATSynEdit`)
- [x] Event signatures updated (`EditorStatusChange`, `EditorGutterClick`, `EditorPaintLine`, etc.)
- [x] Constructor updated (`TSynEdit.Create` -> `TATSynEdit.Create`)
- [x] `SetCaretPosAndActivate` -> ATSynEdit `CaretPos` (`TPoint`, 0-based)
- [x] `InvalidateGutterLine` -> `InvalidateLine` (ATSynEdit does not support the former)
- [x] `BufferCoord()` -> `Point()` / `TPoint` (all replaced)
- [x] `TBufferCoord` -> `TPoint` (all replaced)
- [x] `TDisplayCoord` -> `TPoint` (replaced)
- [x] `TSynHighlighterAttributes` -> `TATSynHighlighterAttributes`
- [x] `TSynStateFlags` / `sfWaitForDragging` -> removed (not supported)
- [x] `InsertString` updated (`CaretXY` -> `CaretPos`)
- [x] `ExportToHTML`/`RTF`/`TEX` -> initially disabled, later reimplemented with ATSynEdit line-part APIs
- [x] Bookmark API -> `BookmarkSet`/`BookmarkDelete`/`BookmarkGoto` (ATSynEdit)
- [x] `HandleSymbolCompletion` -> `BufferCoord` -> `TPoint`, `CaretXY` -> `CaretPos`
- [x] `HandleCodeCompletion` -> ATSynEdit `GetHighlighterAttriAtRowCol` (`TPoint`)
- [x] `CompletionKeyPress` -> ATSynEdit type updates
- [x] `CompletionTimer` -> ATSynEdit `CaretPos` comparison logic
- [x] `ShowCompletion` -> `CaretPosToClientXY` replaces `RowColumnToPixels`
- [x] `GetWordAtPosition` (`TBufferCoord` -> `TPoint`) -> 0-based `TPoint` handling
- [x] `CompletionInsert` -> `GetWordStartAtCaretPos` / `CaretPosToStrPos`
- [x] `EditorDblClick` / `EditorClick` -> `TBufferCoord` -> `TPoint`, remove `TSynStateFlags`
- [x] `EditorMouseMove` -> `TBufferCoord` -> `TPoint`, `GetWordUnderCaret`, etc.
- [x] `HandpointAllowed` -> `TBufferCoord` -> `TPoint`, `TSynHighlighterAttr` -> `TAT`
- [x] `EditorKeyDown` -> `TBufferCoord` -> `TPoint`
- [x] `EditorMouseUp` -> `TDisplayCoord` -> `TPoint`, `PixelsToRowColumn` -> `ClientPosToCaretPos`
- [x] `EditorDropFiles` -> `DisplayToBufferPos` -> `ClientPosToCaretPos`
- [x] `EditorReplaceText` -> `CaretPosToDisplay` -> `CaretPosToClientXY`
- [x] `FunctionTipAllowed` -> remove `IsScrolling`
- [x] `IndentSelection` / `UnindentSelection` -> `BlockBegin/End` -> `SelAvail`
- [x] `ScanForFoldRanges` -> stub (ATSynEdit has built-in folding; callback not needed)
- [x] `EditorPaintTransient` -> stub (bracket matching is built into ATSynEdit)

### Completed - bulk `.dfm` -> `.lfm` conversion (38 files)

- [x] All Delphi text-format `.dfm` files converted to Lazarus `.lfm` format
- [x] All `{$R *.dfm}` directives in `.pas` files updated to `{$R *.lfm}`
- [x] `CPUFrm.dfm` -> `CPUFrm.lfm` (manual `TSynEdit` -> `TATSynEdit` update)
- [x] `FormatterOptionsFrm.lfm` automatically updated from `TSynEdit` to `TATSynEdit`
- [x] All original `.dfm` files deleted (`EditorOptFrm.bak.dfm` backup kept)
- [x] `EditorOptFrm.lfm` / `LangFrm.lfm` kept `TSynEdit` (pending `.pas` migration)

### Completed - remaining forms: `TSynEdit` -> `TATSynEdit`

- [x] `LangFrm.pas`: `synExample` type `TSynEdit` -> `TATSynEdit`; removed `SynEditTypes` from `uses`
- [x] `Project.pas`: temporary `workeditor` changed to `TStringList`; removed `SynEdit` from `uses`
- [x] `EditorOptFrm.pas`: 3 `TSynEdit` -> `TATSynEdit`; `TSynCppSyn` -> `TObject` (placeholder); event signatures updated
- [x] `EditorOptFrm.lfm`: all `TSynEdit` -> `TATSynEdit`
- [x] Other API calls: `CaretXY` -> `CaretPos`, `TSynStatusChanges` -> `TATStatusChanges`, etc.

### Completed - comprehensive Editor.pas ATSynEdit API fixes (2026-05-15)

- [x] Event binding fixes: `OnClickGutter` updated to the `TATSynEditClickGutterEvent` signature
- [x] `OnDblClick` -> `OnClickDouble` (using the `TATSynEditClickEvent` signature)
- [x] Code folding enabled: `OptFoldEnabled := True`
- [x] `InvalidateLine` -> `Invalidate` (all 7 call sites)
- [x] Bookmark API migration: `BookmarkSet` -> `BookmarkSetForLine` (full parameters)
- [x] `BookmarkDelete` -> `BookmarkDeleteForLine`
- [x] `BookmarkGoto` -> direct `CaretPos` jump
- [x] `EnsureCaretVisible` -> `DoGotoCaret`
- [x] `SelText` -> `DoCommand(cCommand_TextInsert, ...)`
- [x] `GetWordUnderCaret` -> `TextCurrentWord`
- [x] `SelText` (read) -> `TextSelected` function
- [x] `ClientPosToCaretPos` enabled
- [x] `CaretPosToClientXY` -> `CaretPosToClientPos` (partially fixed)
- [x] `IndentSelection`/`UnindentSelection` -> `DoCommand(cCommand_TextIndent/Unindent)`
- [x] `HandpointAllowed` rewritten (removed dependency on `TATSynHighlighterAttributes`)
- [x] `hprNone` enum and `case` branch restored
- [x] `LineText` -> `Strings.Lines[]` (3 places)
- [x] `SelectLineAtCaret` -> `DoSelect_Line` (triple-click line selection)
- [x] `CompletionInsert`: manual word-boundary calculation replaces `GetWordStartAtCaretPos`
- [x] `EditorDropFiles` fixed (`ClientPosToCaretPos` + `DoCommand`)
- [x] `EditorDblClick`/`EditorClick` event signatures updated
- [x] `LineText` in `EditorKeyDown` fixed
- [x] `LineText` in `UndoSymbolCompletion` fixed
- [x] `Result := hprNone` default return value fixed
- **Total: 40 TODOs fixed (65 -> 25)**

### Completed - Editor.pas old TODO review (2026-11-25)

The export and positioning items from the early checklist are complete. The remaining items have either been downgraded to fallbacks or still need EControl adaptation:

- [x] Export functionality (HTML/RTF/TEX) - implemented with ATSynEdit line-part APIs
- [x] `ShowCompletion` / `EditorReplaceText` positioning - switched to `CaretPosToClientPos`
- [x] `HandleSymbolCompletion` line-text retrieval - switched to `Strings.Lines`
- [ ] EControl highlighter attribute check (`dmMain.Cpp` -> `AdapterForHilite`)
- [ ] Completion filter logic (`CompletionKeyPress`) - currently falls back to a plain search when no highlighter attributes are available
- [ ] `HandleCodeCompletion` highlighter-based trigger logic - currently uses a simplified fallback

### Completed - main.pas ATSynEdit API fixes (2026-05-15)

- [x] `SelAvail` checks -> `CaretsSel.IsEmpty` (4 places: `actCut`/`actCopy`/`actToggleCommentInline`/`AddWatch`)
- [x] `SelText` reads -> `TextSelected` (5 places: find/replace/find-in-files/`AddWatch`)
- [x] `WordAtCursor` -> `TextCurrentWord` (5 places: same as above plus `ParseToolParams`)
- [x] Delete line: `ecDeleteLine` -> `DoCommand(cCommand_TextDeleteLine)`
- [x] Duplicate line: `ecDuplicateLine` -> `DoCommand(cCommand_TextDuplicateLine)`
- [x] Move up: `ecMoveSelUp` -> `DoCommand(cCommand_MoveSelectionUp)`
- [x] Move down: `ecMoveSelDown` -> `DoCommand(cCommand_MoveSelectionDown)`
- [x] Unfold all: `UncollapseAll` -> `DoCommand(cCommand_UnfoldAll)`
- [x] Fold all: `CollapseAll` -> `DoCommand(cCommand_FoldAll)`
- [x] `SetSelWord` -> `DoCommand(cCommand_SelectWords)`
- [x] `BlockBegin` -> direct `Carets[0]` access
- [x] `ClearSelection` -> `DoCommand(cCommand_SelectNone)`
- [x] `LinesInWindow` -> `LineBottom` replacement (2 places)
- [x] `OldCaretXY` -> `Carets[0].PosX/Y` reads/writes (format restore)
- [x] **Total: 30 TODOs fixed (46 -> 16)**

### Completed - main.pas old TODO review (2026-11-25)

- [x] Comment/Uncomment/ToggleComment - implemented manually in `actCommentExecute` / `actUncommentExecute` / `actToggleCommentExecute`
- [x] CommentInline - implemented in `actToggleCommentInlineExecute`
- [x] PrinterSetup - printing and print setup are implemented
- [ ] `dmMain.Cpp` references - placeholders remain in `LoadColor` and elsewhere; EControl must provide the colors
- [ ] `SelLength` / `Lines.Capacity` - Delphi-specific properties with no ATSynEdit equivalent; intentionally removed
- [ ] `ShortenLogOutput` - currently a no-op
- [ ] `Gutter.Font` - replaced by ATSynEdit's independent gutter-font settings; old calls still need cleanup

### Key API mapping (ATSynEdit vs SynEdit)

| SynEdit | ATSynEdit | Notes |
|---------|-----------|-------|
| `BufferCoord(col, line)` | `Point(col-1, line-1)` | **0-based** |
| `CaretXY` | `CaretPos` (`TPoint`, 0-based) | Caret position |
| `CaretXY.Char` | `CaretPos.X + 1` | Column conversion |
| `CaretXY.Line` | `CaretPos.Y + 1` | Line conversion |
| `CaretX` (1-based) | `CaretX` (1-based) | Compatible |
| `CaretY` (1-based) | `CaretY` (1-based) | Compatible |
| `Lines[i-1]` (0-based) | `Lines[i-1]` (0-based) | Same |
| `GetHighlighterAttriAtRowCol(BufferCoord)` | `GetHighlighterAttriAtRowCol(TPoint, 0-based)` | Signature changed |
| `BlockBegin/BlockEnd` | `SelAvail` | Whether a selection exists |
| `SetBookmark(n,col,line)` | `BookmarkSetForLine(line-1, 0, '', True, True, n)` | Bookmark set (completely different parameters) |
| `ClearBookMark(n)` | `BookmarkDeleteForLine(line-1)` | Bookmark delete (by line) |
| `GotoBookMark(n)` | `Carets[0].PosY := BookmarkLines[n]-1; DoGotoCaret()` | Bookmark jump (set caret directly) |
| `RowColumnToPixels(DisplayXY)` | `CaretPosToClientPos(CaretPos)` | Caret pixel position (returns `TATPoint`) |
| `PixelsToRowColumn(x,y)` | `ClientPosToCaretPos(Point(x,y))` | Pixel to text position |
| `SelText` (get) | `TextSelected` | Get selected text (function) |
| `SelText` (set) | `DoCommand(cCommand_TextInsert, ...)` | Set selected text |
| `Lines[i-1]` (0-based) | `Strings.Lines[i-1]` (0-based) | Same |
| `LineText` | `Strings.Lines[CaretY-1]` | Read line text |
| `GetWordUnderCaret` | `TextCurrentWord` | Word under caret |
| `SelectLineAtCaret` | `DoSelect_Line(CaretPos)` | Select line |
| `CollapseAll` | `DoCommand(cCommand_FoldAll, ...)` | Fold all |
| `UncollapseAll` | `DoCommand(cCommand_UnfoldAll, ...)` | Unfold all |
| `IsScrolling` | **Not supported; removed** | Scrolling-state check |
| `InvalidateGutterLine(n)` | `Invalidate` | Full repaint |
| `InvalidateLine(n)` | `Invalidate` | Full repaint |
| `OnDblClick` | `OnClickDouble` | Double-click event (different signature) |
| `OnClickSpecialLine` | `OnDrawLine` | Special-line click/draw |
| `OnGutterClick` | `OnClickGutter` | Signature changed to `(Sender, ABand, ALineNum, var AHandled)` |
| `SynExporterHTML/RTF/TEX` | **Reimplemented with ATSynEdit line-part APIs** | See `TEditor.ExportToHTML/RTF/TEX` |
| `TSynHighlighterAttributes` | `TATSynHighlighterAttributes` | Obtained through the EControl adapter |
| `InvalidateGutterLine(n)` | *(not supported; use `InvalidateLine`)* | |
| `IsScrolling` | *(not supported; removed)* | |
| `WordStart/WordEnd.Char` | `GetWordStartAtCaretPos` | Word boundaries |
| `RowColToCharIndex` | `CaretPosToStrPos` | Character index |

## Completed Changes

### Editor.pas change list

| Change type | Count |
|-------------|-------|
| Unit (`uses`) replacements | All complete |
| Type replacements | 30+ |
| Method signature updates | 20+ |
| API call replacements | 50+ |
| `TDebugGutter` rewrite | Complete |
| Export functionality disabled | Complete |
| Bookmark API update | Complete |

## Change Log

| Date | File | Change |
|------|------|--------|
| 2026-05-12 | Editor.pas | `uses` clause: SynEdit -> ATSynEdit |
| 2026-05-12 | Editor.pas | `TDebugGutter` migrated to ATSynEdit |
| 2026-05-12 | Editor.pas | `TEditor` type definitions updated |
| 2026-05-12 | Editor.pas | Event-handler signatures updated |
| 2026-05-12 | Editor.pas | Constructor updated |
| 2026-05-12 | Editor.pas | `HandleSymbolCompletion` fully updated |
| 2026-05-12 | Editor.pas | All `BufferCoord` -> `TPoint` replacements complete |
| 2026-05-12 | Editor.pas | Bookmark API updated (`SetBookmark` -> `BookmarkSet`, etc.) |
| 2026-05-12 | Editor.pas | Export methods disabled (`SynExporter` unavailable) |
| 2026-05-12 | Editor.pas | `ScanForFoldRanges` / `EditorPaintTransient` stubbed |
| 2026-05-12 | Editor.pas | All SynEdit-specific APIs cleaned up |
