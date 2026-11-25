# TdevFormatter.FormatMemory —— 停用 UnicodeString→AnsiString 转换（仅本函数）

日期：2026-09-13 20:07 GMT+8
文件：DevCpp-Lazarus\devcfg.pas（TdevFormatter.FormatMemory / TdevFormatter.FormatFile）
编译：lazbuild.exe DevCpp.lpi -B，绿（55320 行，0 error，仅 devcpp.ico 缺失良性）

## 目标
用户要求：在 `FormatMemory` 这一个函数内停用 `UnicodeString→AnsiString` 转换
（原 `AnsiString(Editor.FileName)` 是 SynEdit 时代的写法；改用 ATSynEdit 后不该再做）。
范围限定在 FormatMemory，不波及全项目。

## 改动（全部在 FormatMemory / FormatFile）
1. 局部变量 `FileName: String;` → `FileName: UnicodeString;`（3316 行）。
2. 去掉 `AnsiString(Editor.FileName)` 显式强转，改用纯 `UnicodeString` 手写基名提取
   （3327-3329 行）：`Copy(Editor.FileName, p+1, Length(Editor.FileName)-p)`，
   其中 `p` 反向扫描 `\`/`/` 定位最后一个路径分隔符。无 Ansi 转换。
3. `FormatFile` 形参 `FileName` 改为 `UnicodeString`（实现 3447 + 接口 279，
   接口第 279 行由用户手工同步），使 `FormatMemory` 调用处 `FormatFile(FileName, …)`
   为 Unicode→Unicode，无转换。
4. `SaveToFile` / `LoadFromFile` 调用处加 UTF-8 编码包装（3330 / 3337 行）：
   `SaveToFile(UTF8String(FileName))`、`LoadFromFile(UTF8String(FileName), [])`。

## 关键发现
- **ATSynEdit 的 `SaveToFile` / `LoadFromFile` 文件名参数实际是 `AnsiString` 类型**
  （内部以 UTF-8 存放文本/路径），并非 `UnicodeString`。因此文件 API 边界仍需要一次
  `UnicodeString → AnsiString` 步骤，但必须用 `UTF8String()`（UTF-8 编码，对文件名无损），
  而不是原来的 `AnsiString()` 系统代码页强转（对非 ASCII 文件名有损、且正是要删掉的写法）。
- 原 `AnsiString(Editor.FileName)` 按**系统代码页**截断；`UTF8String(Editor.FileName)`
  按 UTF-8 编码，覆盖全部文件名字符，无损。

## 残留（不在本次范围内 / 按此前决定保留）
- 3329 行 `4104` `AnsiString→UnicodeString`：`devDirs.Exec` / `fAStyleDir` 配置字段
  （AnsiString）在拼接时被拓宽为 UnicodeString，无害（无数据丢失）。
- `FormatFile` 函数体内 3455 行 `4104` + `4105`：`RunCommand: String`（AnsiString）
  与 `FileName: UnicodeString` 拼接所致，属另一函数；此前用户已决定保留 4055/4056 类提示。

## 结论
`FormatMemory` 内对 `Editor.FileName` 的显式有损强转已彻底移除；仅文件 API 边界保留
正确的 UTF-8 编码包装。`4105`（UnicodeString→AnsiString 有损）在 SaveToFile/LoadFromFile
处已清零；`FormatFile` 体内的同类提示按既有口径保留。
