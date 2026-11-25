# DevCpp-Lazarus：光标处配对括号「粗体」高亮（2026-09-07）

## 目标
把原 SynEdit 的「光标移到括号字符处，配对括号变为粗体」效果恢复。项目已从 SynEdit 迁移到 ATSynEdit，迁移注释（`Editor.pas` 的 `EditorPaintTransient`）错误声称「括号匹配由 ATSynEdit 原生处理」——实际此版本 ATSynEdit 没有内置括号高亮（ATSynEdit 作者论坛也确认需自己用代码做）。

## 关键调研结论
- 此版本 ATSynEdit 无 `OnCaretMove` 事件；光标移动事件名为 `OnChangeCaretPos`（已绑到 `EditorCaretChange`，`Editor.pas` L414）。
- 高亮机制用 `fText.Attribs`（`TATMarkers`）。`Attribs.Add(APos: TPoint, ASel: TPoint, const ATags: TATMarkerTags, ALinePart: PATLinePart=nil, ...)`；绘制的粗体由 `LinePart.FontStyles := afsFontBold`（`atsynedit_lineparts.pas`：`afsFontBold=1`）控制，`DoPartCalc_ApplyAttribsOver`（`atsynedit_hilite.inc` L407）按 `Attr^.SelX` 作为长度把样式覆盖到行内。颜色保持 `clNone` 则只加粗不清色。
- 项目内 `MarkInvalidIdentifiers` / `UpdateSelectionHighlight` 已用完全相同的 `InitLinePart` + `fText.Attribs.Add(Point(col0,line0), Point(len,0), TATMarkerTags.Init(tag,0), @Part)` 模式，所需类型（`TATLinePart`、`afsFontBold`、`TATMarkerTags`、`InitLinePart`）与单元已在 Editor.pas 作用域内，直接复用。
- 用独立 tag `cBracketHiliteTag = 202`（避开 `cSelHighlightTag=201`、URL 标记 `UrlMarkerTag=-100`），`DeleteWithTag` 清除，不干扰 URL/选区标记。
- **坐标系统（关键！）**：`fText.Strings.Lines[i]` 返回的是 UTF-8 字节串（按字节计），而 `CaretPosToOffset` 与 `Attribs` 的坐标按**字符**计，`LenEOL=1`（LF）且 `fText.Text` 也是 LF 拼接的 `UnicodeString`——二者一致。**必须在绝对偏移域工作**（`CaretPosToOffset` → 扫 `fText.Text` → `OffsetToCaretPos`），绝不能用 `Lines[cy][cx]` 逐行字节索引，否则中文（CJK 多字节）行会错位。参照 `TCodeToolTip.Show`（`CodeToolTip.pas`）的做法。

## 实现（Editor.pas，最终版＝绝对偏移方案）
1. const 区（L228 后）：`cBracketHiliteTag = 202;`
2. 类声明：`procedure HighlightBrackets;` + `function FindBracketMatch(StartOffs: integer; out MatchOffs: integer): boolean;`
3. `EditorCaretChange` 末尾（原 `UpdateSelectionHighlight;` 之后）：加 `HighlightBrackets;`
4. 新增两方法（位于 `UpdateSelectionHighlight` 实现前）：
   - **`HighlightBrackets`**：
     - `cx,cy := Caret[0].PosX/PosY`（0 基）；`offs := fText.CaretPosToOffset(Point(cx,cy))`。
     - `TextUni := fText.Text`（UnicodeString，LF 换行）；用 `TextUni[offs]`/`TextUni[offs+1]` 取光标左/右字符（1 基索引）。
     - 左字符是 `(`/`[`/`{` → `startOffs := offs-1`；右字符是 `)`/`]`/`}` → `startOffs := offs`；否则退出。
     - 命中则 `FindBracketMatch(startOffs, matchOffs)`；配对成功时 `pStart := OffsetToCaretPos(startOffs)`、`pMatch := OffsetToCaretPos(matchOffs)`，给两端各 `Attribs.Add(Point(p.X,p.Y), Point(1,0), Init(cBracketHiliteTag,0), @Part)`（`Part.FontStyles := afsFontBold`），再 `fText.Invalidate`。
     - 仍保留 `BracketDbg` 调试输出（写 `d:\bracket_dbg.txt`，文件不存在自动创建）便于验证；确认无坐标错位后可撤除。
   - **`FindBracketMatch(StartOffs, out MatchOffs)`**：
     - 直接扫描 `fText.Text`（绝对偏移 `0..Len-1`），带字符串/注释状态机（跳过 `"`/`'`/`//`/`/* */`，处理 `\` 转义与 `*/` 结束）。
     - 起点 `s[StartOffs+1]`：开括号 `startIsOpener:=True`，闭括号 `startIsOpener:=False`。
     - `startProcessed` 标志：仅当真正处理过起始括号后，栈深度回到 `startDepth` 才判为配对成功（修复「起点前的更早闭括号把栈弹空误判配对」的 bug）。
     - 起点是闭括号且栈非空 → 配对即栈顶开括号偏移，立即 `Exit`。
     - 用 `while i < Length(s)` 循环（FPC 不允许在 `for` 循环体内 `Inc(i)` 修改循环变量）；每个 `Continue` 路径都显式 `Inc(i)` 或 `Inc(i,2)` 推进。

## 编译与验证
- `c:\lazarus\lazbuild.exe ... DevCpp.lpi --build-mode=Release` 通过，只剩已知非阻断警告 `Error: File "devcpp.ico" not found`。
- 产物 `D:\cc\devcpp\release发布\DevCpp.exe` 已更新（2026-09-07 11:37），已启动供测试。
- 待用户实测：光标贴括号时配对端变粗体、跨行配对、字符串/注释内括号不误高亮（重点测含中文注释/中文标识符的行，确认不再错位）。

## 备注 / 取舍
- 每次光标移动做一次全文档前向扫描（典型文件数千行，亚毫秒级，可接受）。超大生成文件（10万+行）每次方向键会有开销，如需可后续优化（从当前行向前估算注释状态）。
- 未改 `EditorStatusChange`（OnChange）：打字必然移动光标，由 `OnChangeCaretPos` 覆盖；避免每次按键双重计算。
- 本轮临时文件（`_new_hb.txt`/`_new_fbm.txt`/`_splice.ps1`/`_replace_fbm*.ps1`/`_dbg_fbm.ps1`）待清理（删除需用户确认）。
