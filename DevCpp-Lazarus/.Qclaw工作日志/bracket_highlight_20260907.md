# 配对括号高亮（DevCpp-Lazarus）— 2026-09-07

## 目标
为 Dev-C++（ATSynEdit 版）编辑器增加「光标贴近括号时高亮匹配括号对」功能，行为对齐原 Dev-C++。

## 最终方案
- 高亮方式：**淡黄背景**（`$00C8FFFF`），不使用粗体。
- 通过 `fText.Attribs` 给两个括号各加一个 `TATLinePart`（tag = `cBracketHiliteTag`），背景设为淡黄；不画边框、不设粗体。

## 关键技术结论（重要）
- **这套 ATSynEdit 不绘制 Attribs 标记的 `FontStyles=afsFontBold` 字形**。决定性测试：把 `ColorBG` 设为 `clRed` 时红色背景能渲染，但括号字符**不变粗** → 确认底层 `ExtTextOut` 未采用 `C.Font` 加粗字体（`_PrepareCanvasProps` 虽设了 `C.Font.Style:=[fsBold]`，行 ~939，但字形无差）。
- 根因链：Attr → `DoPartCalc_ApplyAttribsOver` → `DoPartInsert(..., AKeepFontStyles=false)` → `AddPart(APart)`（整条 record 含 FontStyles 一并插入），part 确实带 bold，但画布层不画。
- 因此纯粗体在本构建走不通；改用背景高亮（现代编辑器标配对括号的标准做法，稳且明显）。
- `ColorBG=clNone`（含 `fText.Colors.TextBG` 若解析为 clNone）时标记**完全不渲染**（Windows `ExtTextOut`+`ETO_OPAQUE` 把 clNone 画刷当透明跳过字形），所以必须用真实背景色。

## 实现要点（Editor.pas）
1. `HighlightBrackets`（~1002）：`DeleteWithTag(cBracketHiliteTag)` 清除旧高亮 → `CaretPosToOffset` 取光标绝对偏移 → 看光标左/右字符是否为 `()[]{}` → 调 `FindBracketMatch` → `OffsetToCaretPos` 定位两端 → 加 Attribs → `Invalidate`。
2. 字符串/注释内括号通过 `FindBracketMatch` 内的字符串/注释状态机跳过，不会误高亮。
3. **bug 修复（`FindBracketMatch` 闭合符分支）**：起点为闭合符时，原代码在扫描到该位置时**无条件**把栈顶 opener 当作匹配项，未校验括号类型。例如 `printf("Hello"))` 末尾多余 `)`，扫描到它时栈顶是 `int main() {` 的 `{`（`printf(` 已被自己的 `)` 闭合），导致 `)` 错误配到 `{`。
   - 修复：仅当栈顶 opener 与闭合符**同类型**时才匹配（`)`↔`(`、`]`↔`[`、`}`↔`{`），否则视为不平衡、不高亮。

## 调试残留
- 调试期临时文件（`_*.ps1`/`_*.txt`、`d:\bracket_dbg.txt`）已由用户自行删除。
- `BracketDbg` 调试过程与调用已从 Editor.pas 移除（编译 0 error）。

## 验证
- 多余 `)` 不再错误配对 `{`；正确 `)` 配 `printf(`；`{}` 正常配对；字符串/注释内括号不高亮。

## 尖括号 `<>` 高亮（2026-09-07 追加）
- 需求：`#include <stdio.h>` 这类尖括号配对也淡黄高亮；但仅当内部为「连续标识符式内容」时高亮，以区分关系运算符 `a < b`。
- 实现：
  1. `FindBracketMatch` 把 `<`/`>` 当作一类括号纳入栈匹配（含同类型校验），复用已有的字符串/注释跳过逻辑。
  2. `HighlightBrackets` 的 leftCh/rightCh 判定扩展 `<`（opener）与 `>`（closer）。
  3. 新增 `AngleBracketInteriorOk(const s; startOffs, matchOffs)`：仅当匹配对是 `<>` 时，检查两括号之间的内部字符；若全部为「标识符字符 + 路径分隔符（`.` `/` `\`）」则允许高亮，否则（含空格/运算符）返回 False → 不高亮。
- **规则解释（重要）**：用户原话「内部只含有标识符」。但示例 `#include <stdio.h>` 内含 `.`，若严格只认 `[A-Za-z0-9_]`，则 `stdio.h` 反而不会高亮。故实现允许 `.` `/` `\`，使 `stdio.h`、`path/to/h` 这类头文件名通过，而 `a < b`（空格）等关系运算被排除。如需更严格（不含 `.`、仅纯标识符），一行即可收紧。
- 区分示例：
  - `#include <stdio.h>` → 高亮（内部 `stdio.h` 全为标识/路径字符）。
  - `a < b` / `x < y + 1` → 不高亮（内部含空格/运算符）。
  - `a<b>` → 高亮（内部 `b` 为标识符）。
  - `vector<int>`（模板）→ 内部含 `<`/`>` 及空格？`vector<int>` 内部 `int` 无空格 → 高亮（边缘情况，符合规则）。
- 编译：0 error（仅预存 devcpp.ico 警告）。

## 触发位置扩展到括号外侧（2026-09-07 13:24 追加）
- 需求：除原有的「左括号右侧 / 右括号左侧」外，还应在「左括号左侧 / 右括号右侧」时也高亮。
- 实现：`HighlightBrackets` 的相邻判定由 2 个分支扩展到 4 个（沿用 `or` 比较，避免 FPC 对 WideChar 用 `in` 集合的兼容坑）。offset 映射：
  - 左括号在光标左（leftCh=opener）→ startOffs := offs-1
  - 右括号在光标右（rightCh=closer）→ startOffs := offs
  - 左括号在光标右（rightCh=opener）→ startOffs := offs
  - 右括号在光标左（leftCh=closer）→ startOffs := offs-1
- 四种位置均落到已有的 `FindBracketMatch`（含 opener/closer 双分支与同类型校验）与 `AngleBracketInteriorOk`（尖括号内部校验），无需额外逻辑。
- 编译：0 error。

## 遗留 / 可选
- 若日后需要真正「粗体」效果，需改 ATSynEdit 源码（canvasproc 字体选择逻辑），属改第三方库，风险较大，未做。
- 尖括号规则如需更严格（仅纯标识符、不含 `.`），收紧 `AngleBracketInteriorOk` 的允许字符集即可。
- 引号高亮目前仅做成对分隔符定位；如需要把整段字符串内容也淡黄高亮（而非仅两端引号），需额外加宽 Attribs 范围，属可选增强。
- **2026-09-07 13:15 用户确认**：放宽到「标识符 + `.` `/` `\`」的方案可以接受，维持现状。

## 双引号/单引号配对高亮（2026-09-07 13:56 追加）
- 需求：光标置于成对 `"` 或 `'` 相邻位置时，高亮该字符串/字符字面量的两个引号。
- 实现：引号不是嵌套结构（与 `()[]{}<>` 不同），用独立函数 `FindQuoteMatch` 处理：
  - 从文本头做字符串状态机扫描：`inString`/`stringChar`/`inBlockComment`/`inLineComment`。
  - 引号分隔符判定：不在字符串内 → 开分隔符；在字符串内且等于 `stringChar` → 闭分隔符；在字符串内但不等于 `stringChar`（如 `'...'` 里的 `"`）→ 忽略。
  - 转义 `\"` / `\'`：`inString` 时遇到 `\` 跳过下一字符，避免把转义引号当分隔符。
  - 注释内的引号：块注释 `/* */` 与行注释 `//` 整体跳过，不触发高亮。
  - 起点是开分隔符 → 找其后最近的同型闭分隔符；起点是闭分隔符 → 取其记录的 opener；未闭合字符串 → 不高亮。
- 集成：`HighlightBrackets` 四位置触发分支加入 `"`/`'`，按 `startCh` 分派 `FindBracketMatch`（括号）或 `FindQuoteMatch`（引号），高亮绘制共用；尖括号内部校验仅对 `<`/`>` 生效。
- 编译：0 error。

## 流运算符 / 关系运算符尖括号不再污染括号栈（2026-09-10）

- 需求：编写 C++ 时 cout << "Hello"; / cin >> x; 这类流运算符，以及 a < b 这类关系运算符，不应误当作可配对的尖括号；否则会让 FindBracketMatch 的栈被悬空的 < 占据，挡住后面的 {} / () / [] 配对（例如 cout << 导致 int main() { } 的 } 无法匹配 {，花括号不亮）。
- 根因：FindBracketMatch 把 < 当作 opener 直接压栈，而 << 的两个 < 都没有对应的 > 弹出，悬在栈上；cin >> 的 > 是 closer（从不压栈），其实不会污染，但 << 会。
- 修复（仅改 FindBracketMatch，HighlightBrackets / AngleBracketInteriorOk 不动）：
  1. 相邻 << 跳过两个 <：遇到 < 且紧邻下一个也是 <（流插入/提取运算符）。模板里绝不会出现相邻的 <<，此判定安全；用 skipNextAngle 标志把第二个 < 也跳过，二者都不入栈。
  2. 孤立 < 仅当真正分隔符才入栈：< 后紧跟的字符必须是以字母或 _ 开头的标识符（如 vector<int> 、 #include <x> ）才当作 opener 压栈；a < b（空格）、1 < 2（数字）、if (x < (y))（左括号）、<< 等一律跳过不入栈。悬空 < 不再挡住后续 {} / () 。
  3. 起点即 < 时的同样判定：i=StartOffs 的 opener 注册处，若 < 属于 << 或关系运算符（前/后一个是 <，或后一个不是标识符起始），直接 Exit（不产生匹配），保证 << 本身也不被当作可配对括号。
- 模板不受影响验证：vector<pair<int,int>> 等嵌套模板的 < > 仍正常成对（< 后接标识符、>> 时栈顶为 < 正常弹出两次）。
- 编译：lazbuild DevCpp.lpi 通过，0 error（仅有历史遗留的字符串类型转换 warning）。
