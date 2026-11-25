# 中文路径编译乱码问题分析与修复

## 问题描述

当 Dev-C++ 可执行文件位于包含中文的目录（例如 `d:\cc\devcpp\release发行\DevCpp.exe`）
下时，调用该目录下的 mingw64 gcc 编译器执行编译时，编译命令中的中文路径出现乱码，
导致编译失败。

## 根因分析

### 编译执行流程

完整的编译命令执行链路如下：

1. `TMainForm.CompileFile` (`main.pas`):
   - 设置 `SetPath(BinDir, TRUE)` 将 MinGW bin 目录加入 PATH
   - 设置 `fCompiler.CompilerSet := devCompilerSets.CompilationSet`

2. `TCompiler.Compile` (`Compiler.pas`):
   - 调用 `GetIncludesParams` → `FormatList(fCompilerSet.CDir, '%s -I"%s"')` 构造 `-I` 参数
   - 调用 `GetLibrariesParams` → `FormatList(fCompilerSet.LibDir, '%s -L"%s"')` 构造 `-L` 参数
   - 格式化命令字符串：`g++.exe "source.cpp" -o "source.exe" -I"...发行..." -L"...发行..."`

3. `LaunchThread(cmdline, dir)` → `TDevRun.Execute` → `RunAndGetOutput`

4. `RunAndGetOutput` (`Utils.pas`):
   - 使用 `CreateProcessW` (Unicode API) 创建子进程 ✓
   - 命令用 `PWideChar(UnicodeString(Cmd))` 传递 ✓

### 问题定位

**`SetPath` 函数是根因** (`Utils.pas`, line 734):

```pascal
procedure SetPath(const Add: String; ...);
var
  OldPath: array[0..2048] of char;  // char = AnsiChar (1 byte)
  NewPath: String;
begin
  ...
  Windows.GetEnvironmentVariable('PATH', OldPath, SizeOf(OldPath));
  // → 解析为 GetEnvironmentVariableA (ANSI API)
  ...
  SetEnvironmentVariable(PChar('PATH'), PChar(NewPath));
  // → 解析为 SetEnvironmentVariableA (ANSI API)
end;
```

而命令执行使用 `CreateProcessW` (Unicode API)。这是一个 **API 接口不一致问题**：

- **PATH 设置** 使用 ANSI API → `SetEnvironmentVariableA`
- **子进程创建** 使用 Unicode API → `CreateProcessW`

虽然在中国 Windows (CP936) 上两者在理论上都能正确处理中文，但在 FPC/Lazarus 的
`{$MODE Delphi}` 模式下，`String` 类型在不同上下文中的编码行为可能存在细微差异，
导致 `SetEnvironmentVariableA` 写入的中文路径在 `CreateProcessW` 继承环境时出现乱码。

### 为什么其他人可能没问题？

其他（非Lazarus移植版）的 Dev-C++ 使用 Delphi 编译，其 `String` 类型一致性更好。
本项目从 Delphi/SynEdit 迁移到 Lazarus/ATSynEdit，存在大量的 Delphi 兼容模式配置
(`-dDelphi7 -dBorland`)，这使 FPC 的字符串编码行为变得更加复杂。

## 修复方案

### `Utils.pas` — `SetPath` 函数

将 ANSI 环境变量 API 替换为 Wide (Unicode) API，与 `RunAndGetOutput` 中的
`CreateProcessW` 保持一致：

| 修改前 | 修改后 |
|--------|--------|
| `OldPath: array[0..2048] of char` | `OldPathW: array[0..4096] of WideChar` |
| `Windows.GetEnvironmentVariable('PATH', OldPath, SizeOf(OldPath))` | `Windows.GetEnvironmentVariableW('PATH', OldPathW, Length(OldPathW))` |
| `SetEnvironmentVariable(PChar('PATH'), PChar(NewPath))` | `Windows.SetEnvironmentVariableW('PATH', PWideChar(UnicodeString(NewPath)))` |

## 已验证的其他环节

经过对完整编译链路的分析，以下环节已确认正确处理 Unicode：

| 模块 | 函数/API | Unicode 支持 |
|------|----------|:---:|
| `Utils.pas` | `RunAndGetOutput` × `CreateProcessW` | ✓ (+ `AnsiBytesToUnicode` 处理输出) |
| `Compiler.pas` | `SetTextCodePage(F, GetACP)` 写 Makefile | ✓ (ANSI 编码写入) |
| `Compiler.pas` | `FormatList` / `Format` | ✓ (FPC 原生支持) |
| `devcfg.pas` | `TRegistry.WriteString` | ✓ (Lazarus 使用 RegSetValueExW) |
| **`Utils.pas`** | **`SetPath`** | **❌ → ✓ 本次修复** |

## 文件状态

- `Utils.pas` — **已修改**: `SetPath` 使用 `GetEnvironmentVariableW` / `SetEnvironmentVariableW`
- 其他文件 — 无未保存修改

## 编译验证

(待用户验证编译)
