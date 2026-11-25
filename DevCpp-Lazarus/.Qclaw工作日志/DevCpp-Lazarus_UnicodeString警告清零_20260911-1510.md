# DevCpp-Lazarus：UnicodeString 迁移连锁警告（4104/4105）清零

时间：2026-09-11（延续此前 DelphiUnicode 回退 + per-cast 方案）
环境：Lazarus 4.6 / FPC 3.2.2，lazbuild.exe -B，输出 D:\cc\devcpp\release发行\DevCpp.exe

## 目标
清理 fFileName 改 UnicodeString 及 CBUtils 函数族签名改 UnicodeString 引发的 Warning: (4104)/(4105)
（AnsiString<->UnicodeString 隐式转换）连锁警告。

## 关键决策
- 放弃 { DelphiUnicode}（与 LCL 不兼容，Char 变 WideChar 导致事件处理器签名不匹配、PChar/set of Char/
  ExtractStrings 成片报错 —— 已回退）。
- 采用 per-cast：在调用点用 AnsiString(...)（传向 AnsiString 接口）或 UnicodeString(...)（传向 ATSynEdit
  UnicodeString 文本）显式包裹。

## 本次完成的修复（main.pas 主导）
main.pas 共修约 67 处，全部为 e.FileName/ATSynEdit 文本边界的显式 cast：
- e.FileName → AnsiString 包裹（传 ClassBrowser.CurrentFile / fCompiler.SourceFile / Printer.Title /
  Item.Caption / SubItems.Add / ParseFile / FindStatementOf / SameFileName / fFilesToOpen / 各种
  ExtractFilePath/ChangeFileExt/ExtractFileExt/StringReplace 参数等）。
- ATSynEdit Text.Strings.Lines[] / TextCurrentWord / TextSelected 读出的 UnicodeString → 赋给
  AnsiString 局部变量时 AnsiString(...) 包裹；反向赋给 Lines[]（UnicodeString）时用 UnicodeString(...) 包裹
  （如行注释 toggle：6612/6668/6734/6736）。
- DoCommand(..., string(NewText)) → UnicodeString(NewText)（6642/6702/6786）。
- UTF8Encode(SelText) → UnicodeString(UTF8Encode(SelText))（9334，RawByteString→UnicodeString）。
- ParseParameters(MessageData) → WideString(MessageData)、FilesToOpen.Add(Item) → AnsiString(Item)
  （9503，WideString→AnsiString）。
- ViewToDoFrm.pas:168 sl.Text := e.Text.Text → AnsiString(e.Text.Text)。
- Editor.pas:3522 补 s := AnsiString(fText.TextCurrentWord)；3673 去掉多余 AnsiString(...)（该处 s 为
  UnicodeString）。

## 构建结果
- 55302 lines compiled，0 error（仅 benign File "devcpp.ico" not found 资源提示，不影响 exe 产出）。
- 4104/4105：**0 条**（从回退后基线 313 条 → 270 → 201 → 125 → 69 → 6 → 0）。
- 总警告 46 条，全部为非转换类（4056 未初始化变量提示 x40 等），不属于本次迁移范围。

## 工具教训（重要）
- PowerShell 脚本块 & {  = .Replace(...) } 在子作用域运行，外层 $c 不变 → 替换“静默失败”。必须
  在**同一作用域**内联 $c = .Replace(...)。
- [char]34 + [char]39 当左操作数非 string 时会做整数加法（34+39=73）而非拼接，且引号顺序易错。
  **稳妥做法：避开引号字符拼接**，改为替换不含引号的子串（如 EditorList[i+1].FileName →
  AnsiString(fEditorList[i+1].FileName)、ChangeFileExt(e.FileName, EXE_EXT) → ChangeFileExt(AnsiString(e.FileName), EXE_EXT)）。
- 每次批量替换后用 ReadAllLines 抽样核验磁盘实际内容，避免“报告成功但未生效”。

## 待办/未决
- 剩余 46 条非转换警告（多为 4056 未初始化变量）可后续单独处理，与本次迁移无关。
- devcpp.ico 缺失为资源文件问题，需补回图标或调整 .lpi 资源引用（不影响编译/运行）。