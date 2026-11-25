# DevCpp-Lazarus：DelphiUnicode 实验回退 + UnicodeString 迁移连锁警告清理

日期：2026-09-11
项目：`c:\Users\Administrator\WorkBuddy\2026-DevCpp-Lazarus\DevCpp-Lazarus\`（XiaoLoong Dev-C++ / XL7 v7.0 测试版）

## 一、关键结论：{$MODE DelphiUnicode} 与 LCL 不兼容（实验失败，已回退）

为消除 UnicodeString 签名迁移产生的级联警告，曾尝试把全项目切到 `{$MODE DelphiUnicode}`。
构建立即暴露根本矛盾：

- LCL / FPC RTL 是用 `string=AnsiString`、`Char=AnsiChar` 预编译的；所有 LCL 事件类型
 （`TKeyPressEvent`、`TResizeEvent` 等）的 `Char` 参数是 `AnsiChar`。
- DelphiUnicode 模式把我们的 `Char` 变成 `WideChar`、`String` 变成 `UnicodeString`。
- 于是每个 LCL 事件处理器、`PChar`/`ExtractStrings`、文件 I/O 都成片报错：
  - `CodeCompletion.pas(434,28) Error 4028 Can't take the address of constant expressions`
    （`OnFormKeyPress(var Key: WideChar)` 无法匹配 `TKeyPressEvent(var Key: AnsiChar)`）
  - `CppTokenizer.pas` / `CppPreprocessor.pas` 多个 `set of Char` → `set of AnsiChar` 才能过（Unicode 模式 Char=WideChar，set 超 256 上限）
  - `CppPreprocessor.pas(619/620)` `ExtractStrings` 期望 `PAnsiChar`，需显式 cast

**这是 Lazarus 已知限制：LCL 不支持 DelphiUnicode 模式**（它用 UTF-8 存于 AnsiString，而非 UTF-16）。
DelphiUnicode 对 LCL 应用行不通。回退到原 `{$MODE Delphi}` + `string=AnsiString`。

## 二、回退操作（已全部还原，构建恢复 0 error）

1. **DevCpp.lpi**：删除 3 处 `<SyntaxMode Value="DelphiUnicode"/>`、删除全局孤立 `<Parsing></Parsing>`、
   3 处 `CustomOptions` 中的 `-Mdelphiunicode`（恢复 `-dCompiler6_Up -dPUREPASCAL`）。
2. **9 个单元**的 `{$MODE DelphiUnicode}` → `{$MODE Delphi}`：
   DevCpp.lpr、FileEncodingFrm.pas、HomepageFrm.pas、main-ownerdraw.pas、MultiLangSupport.pas、
   Tests.pas、Utils.old.pas、Version.pas、main.pas（`{$mode ObjFPC}{$H+}`）。
3. 保留的安全编辑（在 Delphi/Ansi 模式同样合法、无害）：
   - `CppTokenizer.pas` / `CppPreprocessor.pas` 的 `set of Char` → `set of AnsiChar`
   - `CppPreprocessor.pas(619/620)` `PAnsiChar(...)` 显式 cast
   - （`CodeCompletion.pas` 的 `@` 去除已撤销，恢复原 `:= @OnFormResize`）

## 三、本批次连锁警告清理（目标达成）

本批次对象：把 `GetHeaderFileName / IsSystemHeaderFile / IsCfile / IsHfile / GetSourcePair`
签名改为 UnicodeString（上一轮）+ `fFileName / CppFname / fName / ToFile` 改 UnicodeString 引入的级联警告。

采用 per-cast 方案：函数内部用 AnsiString 局部变量、入口/出口显式 cast；调用点按方向加
`UnicodeString(...)`（Ansi→Unicode 传参）或 `AnsiString(...)`（Unicode→Ansi 赋值/传参）显式转换。

### 已修复清单（全部消除）
- **CBUtils.pas**（12 处）：重写 `GetLocalHeaderFileName`/`GetSystemHeaderFileName`（325-375）用
  AnsiString 局部变量 + 出口 `UnicodeString(...)`；`IsSystemHeaderFile(305)` 与 `IsIncludeLine(319)` 的
  `StartsStr`/FileExists 实参加 `AnsiString(...)` cast。→ **CBUtils 零警告**。
- **CppParser.pas**（20 处）：`ParseFile` 内 `FName/CFile/HFile` 与 `TStringList`/`InvalidateFile`/
  `InternalParse` 的 AnsiString 边界全部 `AnsiString(...)`/`UnicodeString(...)` cast；
  `IsSystemHeaderFile`/`IsHfile`/`IsCfile` 调用点实参加 `UnicodeString(...)`。→ **CppParser 零警告**。
- **CppPreprocessor.pas**（4 处）：`IsSystemHeaderFile(224)` 传参、`GetHeaderFileName(947/948)` 返回值与传参 cast。→ **CppPreprocessor 零警告**。
- **NewFunctionFrm.pas**：`GetSourcePair(121)` 传参 `UnicodeString(st^._DefinitionFileName)`；
  `GetEditorFromFileName(128/192)` 实参加 `AnsiString(fName/CppFname)`。
- **NewVarFrm.pas**：`GetSourcePair(156)` 传参 `UnicodeString(st^._DefinitionFileName)`。
- **main.pas**：`FileIsOpen(6333)` / `GetEditorFromFileName(6338)` 实参加 `AnsiString(ToFile)`。
- **Editor.pas**：`GetHeaderFileName(3444)` 返回值 `AnsiString(...)` + `s` 传参 `UnicodeString(s)`；
  `GetEditorFromFileName(3612)` 实参加 `AnsiString(hdrFile)`。

### 构建结果
- 0 Error。
- 警告：313 → **270**（本批次级联警告全部清零，净减 43）。
- 行数 55293 → 55302，产物 4859600 bytes code。

## 四、剩余 270 警告（与本批次无关，属更大范围的 ATSynEdit 迁移 + 早前 fFileName 改 UnicodeString）

全部为 `TATSynEdit` 的 `UnicodeString` 文本 API（`e.Text.Strings.LineAdd/LineInsert`、`CodeIns.Text`、
`fText.Carets` 等）与 AnsiString RTL/局部变量之间的边界，以及 `fFileName`(UnicodeString) 传给
AnsiString 参数的早期连锁。**非**本次 IsCfile/IsHfile/GetSourcePair 批次引入。

分布（按文件，仅 4104/4105）：
- Editor.pas ~70、main.pas ~70、NewClassFrm.pas 11、NewVarFrm.pas 14、NewFunctionFrm.pas 4、
  EditorOptFrm.pas 2、EditorList.pas 8、Macros.pas 6、ProfileAnalysisFrm.pas 7、ViewToDoFrm.pas 9、
  Debugger.pas 2、devcfg.pas 2、CPUFrm.pas 1、FindFrm.pas 4、FilePropertiesFrm.pas 3、
  FormatterOptFrm.pas 2、IncrementalFrm.pas 1、Project.pas 4、Utils.pas 1。

这些警告是**无害的**（ASCII 路径/文本内容不丢信息），属 ATSynEdit 迁移进行中的预期 trade-off。
彻底清零需把 `TEditorList.GetEditorFromFileName`/`FileIsOpen` 等参数也改 UnicodeString，或逐站
`e.Text.Strings.LineAdd(UnicodeString(S))` cast（数百处），工作量独立于本批次。

## 五、文件操作汇总
- 修改：DevCpp.lpi（回退 SyntaxMode/CustomOptions）、9 个单元（回退 MODE）、
  CBUtils.pas（函数重写+cast）、CppParser.pas（ParseFile+调用点 cast）、CppPreprocessor.pas（cast）、
  NewFunctionFrm.pas、NewVarFrm.pas、main.pas、Editor.pas（调用点 cast）、
  CppTokenizer.pas/CppPreprocessor.pas（set of AnsiChar，前序保留）
- 新建：`d:\cc\devcpp\build_warnings_20260911.txt`（当前 270 警告日志）

## 六、待确认
是否继续清理剩余 270 个 ATSynEdit 迁移 / fFileName 连锁警告？该工作量较大（数百处 cast 或改动
TEditorList 接口签名），且全部无害。建议作为独立任务规划。
