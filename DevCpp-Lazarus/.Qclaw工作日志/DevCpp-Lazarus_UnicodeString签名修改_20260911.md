# DevCpp-Lazarus: GetHeaderFileName / IsIncludeLine UnicodeString 签名修改

日期：2026-09-11
操作：执行

## 目标
消除 Editor.pas 中以下两处 Warning 4105：
- `Editor.pas(3586,20)` `hdrFile := MainForm.CppParser.GetHeaderFileName(AnsiString(fFileName), AnsiString(line))`
- `Editor.pas(3496,...)` `MainForm.CppParser.IsIncludeLine(s)` （s 为 UnicodeString）

根因：ATSynEdit 侧全部使用 UnicodeString，CBUtils/CppParser 侧用 AnsiString，每次调用都触发隐式转换。

## 改动方案
将 `GetHeaderFileName`/`IsIncludeLine`/`GetSystemHeaderFileName`/`GetLocalHeaderFileName`
的参数和返回值从 AnsiString 改为 UnicodeString，使 Editor.pas 侧调用自然匹配。

## 改动文件

### CBUtils.pas
修改了 4 个函数的接口（参数+返回值）和实现（局部变量类型）：

| 函数 | 改前 | 改后 |
|---|---|---|
| `IsSystemHeaderFile` | `AnsiString` | `UnicodeString` |
| `GetSystemHeaderFileName` | `AnsiString` | `UnicodeString` |
| `GetLocalHeaderFileName` | `AnsiString` | `UnicodeString` |
| `GetHeaderFileName` | `AnsiString` | `UnicodeString` |
| `IsIncludeLine` | `AnsiString` | `UnicodeString` |

`IsSystemHeaderFile` 的 `FileName[2] = ':'` 改为 `FileName[2] = ':'`（FPC 支持 AnsiChar/WideChar 直接比较，无警告）。

### CppParser.pas
TCppParser 类方法的接口（interface 区）和实现（implementation 区）共 5 个方法：
`GetSystemHeaderFileName`、`GetLocalHeaderFileName`、`GetHeaderFileName`、`IsIncludeLine`、`IsSystemHeaderFile`。
全部参数和返回值从 `AnsiString` 改为 `UnicodeString`。

### Editor.pas
删除了 `GetHeaderFileName(AnsiString(fFileName), AnsiString(line))` 的显式 cast，
因类型匹配自然消除：
```pascal
// 改前：
hdrFile := MainForm.CppParser.GetHeaderFileName(AnsiString(fFileName), AnsiString(line));
// 改后：
hdrFile := MainForm.CppParser.GetHeaderFileName(fFileName, line);
```

## 编译结果
```
lazbuild DevCpp.lpi
0 Error
Editor.pas(3586): 原有 Warning 4105 ✓ 消除
Editor.pas(3588): 原有 Warning 4105 ✓ 消除
输出：d:\cc\devcpp\release发行\DevCpp.exe (8.8MB)
```

## 残余警告（CBUtils 内部实现层）
CBUtils 的 4 个函数内部使用了 `ExtractFileDir`/`FileExists`/`SameText`/`StartsStr` 等
返回 `AnsiString` 的 RTL 函数，局部变量改为 `UnicodeString` 后产生了连锁警告：
- CBUtils.pas(291-295): `IsSystemHeaderFile` FilePath/IncPath 相关
- CBUtils.pas(305): `IsIncludeLine` TrimmedLine
- CBUtils.pas(319,333): `GetLocalHeaderFileName`
- CBUtils.pas(347,348,362,369,370): `GetSystemHeaderFileName` / `GetHeaderFileName`

这些属于 CBUtils 内部实现细节警告，不影响 Editor.pas 的正确性，后续可选择：
1. 将 CBUtils 内部局部变量改回 `AnsiString`，在 API 边界显式 cast
2. 或保持现状（警告在内部，不影响用户可见行为）

## 未涉及改动的调用点（保持 AnsiString 环境，未受影响）
- `CppPreprocessor.pas(947)`: `cbutils.GetHeaderFileName(..., fIncludePaths, fProjectIncludePaths)`
  参数为 `AnsiString`，调用方内部已是 AnsiString 环境，无需改动
- `Compiler.pas(1309)`: `e.CppParser.GetHeaderFileName(e.FileName, ...)`
  e.FileName 为 `AnsiString`，需 cast，但该代码块被注释，未激活
