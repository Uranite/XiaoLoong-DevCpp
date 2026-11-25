# 跨平台编译器检测：Linux/macOS 联动 GCC（FindSets）

- **日期**：2026-09-17
- **项目**：`c:\Users\Administrator\WorkBuddy\2026-DevCpp-Lazarus\DevCpp-Lazarus`
- **目标**：Windows 下 Dev-C++ 在自身安装目录的 `mingw64` 内自带 MinGW64 GCC，`FindSets` 自动扫描并建编译器集；Linux/macOS 上 GCC 由系统/用户装在别处，需用 `which gcc`（回退 `command -v gcc`）检测、取安装目录、设定可执行文件路径，并据 `gdb` 是否存在决定是否启用调试档。

## 1. 改动一：Version.pas 编译器常量改为平台相关（去掉非 Windows 的 .exe）
原常量全部带 `.exe`（如 `GCC_PROGRAM='gcc.exe'`、`MAKE_PROGRAM='mingw32-make.exe'`），仅适用于 Windows。改为 `{$IFDEF MSWINDOWS}` / `{$ELSE}` 两份：

| 常量 | Windows | Linux/macOS |
|---|---|---|
| MAKE_PROGRAM | mingw32-make.exe | make |
| GCC_PROGRAM | gcc.exe | gcc |
| GPP_PROGRAM | g++.exe | g++ |
| GDB_PROGRAM | gdb.exe | gdb |
| GDB32_PROGRAM | gdb32.exe | gdb32 |
| WINDRES_PROGRAM | windres.exe | windres |
| GPROF_PROGRAM | gprof.exe | gprof |
| PACKMAN_PROGRAM | packman.exe | packman |
| CLEAN_PROGRAM | del /q | rm -f |

`SetExecutables`（devcfg.pas）用这些常量填 `fgccName/fgppName/...`，故非 Windows 自动获得无后缀名。`CLEAN_PROGRAM` 用于生成 makefile 的 `RM=` 与解析清理输出，`rm -f` 符合 Linux make 约定。

## 2. 改动二：devcfg.pas FindSets 增加非 Windows 检测分支
新增独立过程 `AddSystemGCCSet`（`{$IFNDEF MSWINDOWS}` 守卫，放在 `FindSets` 之前），由 `FindSets` 首行调用 `{$IFNDEF MSWINDOWS} AddSystemGCCSet; {$ENDIF}`。

逻辑：
1. **gcc 检测 + 回退**：`RunAndGetOutput('which gcc', '', nil, nil)`；若返回空或非绝对路径（说明 `which` 缺失/报错，如极简 Linux 未装 `which`），回退到 POSIX shell 内建 `RunAndGetOutput('sh -c "command -v gcc"', ...)`（`command -v` 是 shell 内建，须 `sh -c` 包装才能由 TProcess 运行）。取第一行；仅当结果以 `/` 开头（绝对路径）才视为真正找到 gcc，否则视为未安装、安全跳过。
2. `ExtractFileDir` 得 `binDir`（如 `/usr/bin`），再取父目录 `folder`（如 `/usr`）。
3. `devCompilerSets.AddSet(folder)`：
   - `Create('/usr')` → `SetProperties('/usr/bin','gcc')`：检查 `FileExists('/usr/bin/gcc')` 后自动跑 `gcc -dumpfullversion` / `gcc -dumpmachine`，填 `fVersion`/`fDumpMachine`；
   - `SetDirectories` 自动加入 `folder/bin`(=/usr/bin) 与 `folder/include`(=/usr/include)，以及 `folder/<dumpmachine>/bin`（Linux 不存在则跳过）。
4. 设定友好名 `GCC (Linux)/GCC (macOS) <version>`。
5. **调试档门控**：`gdbAvailable := FileExists(binDir + pd + GDB_PROGRAM)`（即 Dev-C++ 实际会调用的 `BinDir[0]/gdb`）。
   - gdb 存在：建 `(Debug)`（-g3 开）与 `(Release)`（-O2）两档，镜像 Windows 分支写法；
   - gdb 缺失：只建 `(Release)` 一档（编译/发布可用，但无调试器故不提供调试档）。

Windows 分支（`TDM-GCC-64`/`MinGW64`/`MinGW32` 目录扫描）完全不变；因 Linux 安装目录不含这些文件夹，原分支在 Linux 上自然不命中。

## 3. 关键依据（已查证）
- `TdevCompilerSet.Create(const CompilerFolder)`：以 `CompilerFolder + pd + 'bin'` 为 BinDir 调 `SetProperties`，再以 `CompilerFolder` 为 `fFolder` 调 `SetDirectories`。故传 `folder=/usr` 时 `SetDirectories` 加 `fFolder/bin=/usr/bin`、`fFolder/include=/usr/include`，天然匹配 Linux 布局。
- `RunAndGetOutput`（Utils.pas，接口段，跨平台 TProcess）签名：`(Cmd, WorkDir, LineOutputFunc, CheckAbortFunc; ShowReturnValue=True; LineOutputData; CheckAbortData): String`，后三参有默认值，可 `RunAndGetOutput('which gcc','',nil,nil)` 调用。
- 嵌套块内 `var` 声明在 `{$MODE Delphi}` 不被 FPC 3.2.2 支持（已实测报错），故用独立过程收纳跨平台局部变量，避免 Windows 上出现未使用变量提示。

## 4. 构建验证
`lazbuild _b6.lpi -B` → **exit=0，0 Error，55752 行**（Windows 走 MSWINDOWS 分支，`AddSystemGCCSet` 不被编译；非 Windows 代码仅用跨平台 API，语法与 Windows 分支同源）。

## 5. 已知限制 / 待办
- **`which` 缺失已处理**：极简 Linux 未装 `which` 时自动回退 `command -v gcc`；两者皆失败（gcc 确实未装）则非绝对路径检查不通过，安全跳过不建集。
- **macOS gcc 常为 clang 垫片**：`which gcc` 返回 `/usr/bin/gcc`（Xcode CLT 垫片），检测照常工作，集名显示 `GCC (macOS)`。
- **gdb 缺失则不建调试档**：仅当 `BinDir[0]/gdb` 存在才建 `(Debug)`；gdb 未装时只提供 `(Release)`。若希望即使无 gdb 也保留调试符号档，可改为始终建调试档（当前按指示门控）。
- **32-bit 配置档未自动建**：Linux/macOS 默认用系统原生位宽；32-bit 需 multilib gcc，超出本次范围。
- **Phase 0.2**：仍需真实 Linux/macOS 主机 `lazbuild --build-mode=Linux` 跑一遍确认整套编译通过（本机 Windows 无法直接交叉验证非 Windows 分支，但其仅用跨平台 API）。

## 6. 文件改动
- `Version.pas`：编译器常量按 `{$IFDEF MSWINDOWS}` 分平台。
- `devcfg.pas`：新增 `AddSystemGCCSet`（`{$IFNDEF MSWINDOWS}`），`FindSets` 首行调用之；gcc 检测带 `command -v` 回退；调试档按 `gdb` 存在性门控。
