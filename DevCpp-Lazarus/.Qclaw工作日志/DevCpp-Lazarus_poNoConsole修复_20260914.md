# poNoConsole 控制台窗口修复 — 2026-09-14

## 问题

执行 `TMainForm.actCompileExecute` 时弹出命令行窗口（用户程序执行），而之前使用 Windows API 时不弹。

## 根因

TProcess 的默认行为是：若创建的是控制台子系统程序（.exe 入口为 main/C），即使调用者进程是 GUI，也会为子进程分配新的控制台窗口。

旧实现（CreateProcessW）：
- 默认 `CREATE_NO_WINDOW`（`dwCreationFlags` 默认 0）→ 不弹出窗口

TProcess 默认：
- 无 `poNoConsole` → 允许子进程创建控制台窗口

`P.ShowWindow := swoHIDE` 仅隐藏已存在的窗口，不阻止窗口创建。

## 修复

### 1. devExec.pas（主要修复：用户程序执行）

**文件：** `devExec.pas` 第 92-93 行

```pascal
if not fVisible then
  P.Options := P.Options + [poNoConsole]; // suppress console window for background processes
```

仅对 `fVisible=False`（后台执行）加 `poNoConsole`；`fVisible=True` 时保持原行为。

### 2. Utils.pas RunAndGetOutput（编译输出捕获）

**文件：** `Utils.pas` 第 800 行

```diff
- P.Options := [poUsePipes, poStderrToOutPut];
+ P.Options := [poUsePipes, poStderrToOutPut, poNoConsole];
```

编译输出捕获永远不需要可见控制台窗口，直接加。

### 3. Debugger.pas GDB 启动

**文件：** `Debugger.pas` 第 146 行

```diff
- fGDBProcess.Options := [poStderrToOutPut];
+ fGDBProcess.Options := [poStderrToOutPut, poNoConsole];
```

GDB 是后台进程，不应有可见窗口。

## 验证

```
exit code = 0
55192 lines compiled, 7.9 sec
4942656 bytes code, 1050628 bytes data
53 Warning, 28 Note, 762 Hint
DevCpp.exe: 80,277,674 bytes ✓
```

## 其他 TProcess 调用点（已确认无需修改）

| 文件 | 行 | 场景 | 原因 |
|------|-----|------|------|
| Utils.pas | 514 | macOS otool (ProgramHasConsole) | 仅 macOS 触发，Windows 不执行 |
| Utils.pas | 736 | Linux RunCommand | 仅 Linux 触发 |
| Utils.pas | 1453 | Linux MIME 查询 | 仅 Linux 触发 |
| FileAssocs.pas | 127,409,479 | 文件关联操作 | 条件编译分支内，Windows 行为不同 |

## 技术注记

`Include(P.Options, poNoConsole)` 报错 `Can't take the address of constant expressions`，因为 `P.Options` 是属性（返回临时集合），不能作为 `Include` 的 var 参数。正确写法：`P.Options := P.Options + [poNoConsole]`。
