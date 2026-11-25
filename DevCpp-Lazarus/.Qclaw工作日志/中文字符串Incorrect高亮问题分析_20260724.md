# C++ 字符串中的中文被标为 Incorrect 的原因分析（2026-07-24）

## 结论
问题**不在 EControl**，而在 DevCpp 自己的代码：`Editor.pas` 中的 `TEditor.MarkInvalidIdentifiers`。

## 证据链

### 1. 真正的元凶：Editor.pas 的 MarkInvalidIdentifiers（约 851 行）
- 由 `EditorStatusChange`（1178 行）在每次编辑器状态变化时调用。
- 注释明确写着 "Mark invalid identifiers (CJK chars in identifier positions)"。
- 逻辑：逐行扫描字符，只跳过行注释 `//` 和块注释 `/* */`，完全没有跳过字符串字面量 `"..."` 和字符 `'...'`。
- 凡是包含非 ASCII 字符（`Ord(c) > 127`）的"单词"，一律用 `fText.Attribs.Add`（tag=cInvalidIdentTag）叠加 Incorrect 样式（红色，取自 `devEditor.Syntax.Values['Incorrect']`）。
- `Attribs` 是 ATSynEdit 的属性覆盖层，优先级高于 lexer 高亮，所以即使 EControl 正确把整个字符串识别为 String token，中文部分仍被红色 Incorrect 覆盖。

### 2. EControl 本身对中文无问题
- `TCharSetNode.HasChar`/`Match`：按 WideChar 比较，`[^...]` 取反类 Unicode 安全。
- `TSpecCheckNode.Match` 中 `.`（无 (?s) 时为 ':' 类型）= `not IsLineBreakChar(C)`，中文可匹配。
- 实际加载的 C++ 词法是 `C++.orig.lcf`（lexers.rc：`LEXER_CPP RCDATA "lexers/C++.orig.lcf"`），String 规则 `(u8|L|u|U)?"(\\.|.)*?("s?|$)` 能整体匹配含中文的字符串。

### 3. 附带发现的两个隐患
a) lexers.rc 嵌的是 `C++.orig.lcf`，不是改过的 `C++.lcf`——对 C++.lcf 的修改根本没生效。
b) `[^"#13#10]` 写法在 EControl 中是致命的：`TecRegExpr.SetExpression` 会调用 `_MultilineToString`，把未转义 `#` 后面直到行尾的内容当作正则注释删除，正则被截断为 `"(\\.|[^"`，编译失败，规则永不匹配。而 `C.lcf`（已嵌入资源）的 String 规则 `"(\\.|[^"#13#10])*"` 正是这种写法，实际已失效。正确写法应为 `[^"\x0D\x0A]`。
c) 今天在 `ec_strutils.pas` 中对 `IsWordChar` 的修改（>= $0080 一律放行）与本 bug 无关，且副作用大（影响 \w、\b、分词边界），建议回滚。

## 已实施修复（2026-07-24）

在 `Editor.pas` 的 `TEditor.MarkInvalidIdentifiers` 中：
- 新增局部变量 `inString: Boolean; stringChar: WideChar;`。
- 每行扫描初始化 `inString := False; stringChar := #0;`。
- 字符串状态必须在注释检测之前判定：
  1. 若 `inString` 为真：遇到 `\` 跳 2 个字符（转义），否则遇到 `stringChar` 关闭字符串；其余字符（含中文）一律 `Continue` 跳过，不做非 ASCII 标记。
  2. 否则若当前字符是 `"` 或 `'`，置 `inString := True; stringChar := s[j];`，`Continue`。
  3. 最后才做 `/* */`、`//` 注释检测（字符串闭合判定前置，避免把字符串内的 `"//"`、`"/*"` 误当注释）。
- 注释检测逻辑从 `if not commentActive and not lineCommentActive` 嵌套改为无前置条件的直接判定（字符串已先行排除，不会误判）。

### 编译验证
- `lazbuild DevCpp.lpi`（工作目录切到项目目录，否则 `devcpp.ico` 报 not found）——退出码 0，Linking 成功。
- 仅剩与本次无关的 Hint/Note（如未初始化 managed 局部变量、未用参数等）。

### 未处理（非本次范围，供参考）
- `C++.lcf` 的修改未生效：`lexers.rc` 嵌的是 `C++.orig.lcf`。如需用修改版需重编资源。
- `C.lcf` 的 String 规则 `[^"#13#10]` 在 EControl 中会导致正则被注释截断失效；正确写法是 `[^"\x0D\x0A]`。
- `ec_strutils.pas` 的 `IsWordChar` 修改（>=$0080 放行）与本 bug 无关且副作用大，建议回滚。
