# poNoConsole 移除 — 调试修复
## 2026-09-14 | Debugger/DevExec/Utils poNoConsole 移除

## 问题（第二轮）

移除 `poNoConsole` 后调试仍然不工作（无任何响应）。

## 根因（第二轮）

`poNoConsole` 在 Windows 上会让 TProcess 使用 `CREATE_NO_WINDOW` 标志（0x08000000）创建进程。这个标志设计给 GUI 程序用，对控制台程序（如 GDB）会破坏标准 I/O 重定向。

原 Windows API 实现使用 `CREATE_NEW_CONSOLE`（0x00000010），强制为子进程创建独立控制台子系统——这是让 GDB（控制台程序）管道 stdin/stdout 正常工作的关键。

`ShowWindow := swoHIDE`（`SW_HIDE = 0`）只隐藏已创建的窗口，不影响子进程的控制台子系统分配。

**结论：`CREATE_NO_WINDOW` + 控制台程序 + 管道重定向 = 管道损坏（stdin 读 EOF，stdout 无输出）**

## 修复（第三轮：分类处理）

按进程类型分别处理：

| 进程 | 需求 | 方案 |
|------|------|------|
| GDB（调试器） | 必须 `CREATE_NEW_CONSOLE`，否则 stdin/stdout 管道损坏 | 不加 `poNoConsole`，仅 `swoHIDE` |
| 用户程序（devExec） | `CREATE_NEW_CONSOLE` + `swoHIDE` | 不加 `poNoConsole` |
| 编译器输出（RunAndGetOutput） | 纯 stdout 捕获，不写 stdin，`CREATE_NO_WINDOW` 无害 | 加回 `poNoConsole` |

| 文件 | 最终 Options |
|------|-------------|
| Debugger.pas | `[poStderrToOutPut]`（无 poNoConsole） |
| devExec.pas | 不用 Options（默认 `CREATE_NEW_CONSOLE`），`swoHIDE` 隐藏窗口 |
| Utils.pas RunAndGetOutput | `[poUsePipes, poStderrToOutPut, poNoConsole]` |

窗口隐藏由 `ShowWindow := swoHIDE` 负责；TProcess 默认的 `CREATE_NEW_CONSOLE` 确保管道 I/O 正常。

## 构建结果

```
exit code = 0
55199 lines compiled, 8.1 sec
4942560 bytes code, 1050628 bytes data
53 Warning, 28 Note, 762 Hint
DevCpp.exe: 80,277,674 bytes ✓
```

## 技术说明

`CREATE_NO_WINDOW` vs `CREATE_NEW_CONSOLE`：
- `CREATE_NO_WINDOW`（poNoConsole）：不给进程分配控制台窗口；但若进程本身是控制台子系统（SUBSYSTEM:CONSOLE），系统仍会分配控制台，只是窗口不可见——同时 stdin/stdout 管道可能指向错误的句柄
- `CREATE_NEW_CONSOLE`：强制为进程创建新的控制台子系统，正确初始化 stdin/stdout 管道；再设 `ShowWindow := swoHIDE` 让窗口隐藏

GDB（`gdb.exe`）是 SUBSYSTEM:CONSOLE 程序，管道 I/O 必须依赖 `CREATE_NEW_CONSOLE`。
