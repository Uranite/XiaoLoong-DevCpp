# A4/Debugger 跨平台 TProcess 化 — 落地记录
## 2026-09-14 | DevCpp-Lazarus 跨平台评估 Phase A4

---

## 目标

将 `Debugger.pas`（TDebugger）与 `DebugReader.pas`（TDebugReader）中的 Windows 专用 API 替换为跨平台 LCL `TProcess`，为后续 Linux/macOS 移植扫除最后一个核心硬阻塞。

---

## 涉及文件

| 文件 | 改动内容 |
|------|---------|
| `Debugger.pas` (471 行) | uses 去 Windows；句柄字段 → TProcess；Start/Stop/SendCommand 三方法重写 |
| `DebugReader.pas` (1155 行) | uses 去 Windows；fPipeRead → fProcess: TProcess；Execute 改 TProcess.Output.Read；MessageBeep → LCLIntf.Beep |

---

## 核心设计决策

### DebugReader（TDebugReader 后端线程）

**原实现（Windows）：**
- `ReadFile(fPipeRead, Buf, ...)` 同步阻塞读 GDB pipe
- `fOutputWrite / fInputWrite / fInputRead` 四个 THandle 管道
- `MessageBeep(MB_ICONERROR)` Windows 专用

**新实现（TProcess）：**
- `fProcess: TProcess` 替代四个 THandle
- `fProcess.Output.Read(Buf[0], SizeOf(Buf))` 非阻塞轮询读（`Sleep(10)` 空轮询）
- `fProcess.Terminate(0)` 杀 GDB
- `LCLIntf.Beep` 替代 `MessageBeep`
- `uses Process, LCLIntf`（替代 `Windows`）

### Debugger（TDebugger 主控）

**Start：**
- `P.CommandLine := GDBCommand`（含 `--annotate=2 --silent`）
- `P.CurrentDirectory := WorkingDir`
- `P.Options := [poStderrToOutPut]`（合并 stderr 到 stdout）
- `P.Active := True` 启动（try/except 捕获启动失败）
- `fProcess := P`（注入 DebugReader）
- `DebugReader := TDebugReader.Create(True)` + `PipeRead := fProcess.Output` + `Resume`

**Stop：**
- `fProcess.Terminate(0)` 杀进程（替代 `TerminateProcess(fProcessID, 0)`）
- `fProcess.Free`（替代 `CloseHandle`×4 + `TerminateProcess`）
- `fProcess := nil`

**SendCommand（跨线程安全）：**
- 线程安全队列：私有 `CommandQueue: TQueueAnsiString`
- `SendCommand` → 入队，不直接写 pipe
- `Execute` 线程内每次轮询读前先检查队列，有则 `fProcess.Input.Write`

### 外部接口保持不变

- 外部调用方（main.pas 等）只用 `TDebugger.Start / Stop / SendCommand`，无感知内部替换
- `TExecThread` 保留 `Process` 属性（填 ProcessID）

---

## 构建结果

```
exit code = 0
55190 lines compiled, 10.1 sec
4942624 bytes code, 1050628 bytes data
53 Warning, 28 Note, 762 Hint
```

**Debugger/DebugReader 相关残留提示（均良性）：**
- `Debugger.pas(145,15/27)` Warning 5043: `CommandLine` / `SetCommandLine` deprecated
- `Debugger.pas(167,16)` Warning 5043: `Resume` deprecated
- `DebugReader.pas(1114,15)` Hint 5057: `Buf` does not seem to be initialized
  - 代码逻辑正确（TProcess.Output.Read 填 Buf），FPC 数据流分析无法追踪；无害

---

## 构建路径问题说明

`.lpi` 中 Release 模式 Target Filename 路径含中文"release发行"，PowerShell 调用 lazbuild 时该路径在链接器参数中乱码导致 `error 9003: Can't create object file (error code 5)`。

**根因**：与 devcpp.ico 根因相同（lazbuild 从非项目目录调用时 cwd 落在 agent workspace），非代码错误。

**验证方式**：临时替换 `.lpi` 中所有输出路径为 `C:\Users\Administrator\.qclaw\workspace\_buildout3\DevCpp.exe`，构建成功（80,277,674 bytes），确认编译阶段 0 Error。

从 Lazarus IDE 构建（cwd=项目目录）不受此问题影响。

---

## A4 完成后的跨平台状态

### 已完成（本次）

| 编号 | 组件 | 旧实现 | 新实现 |
|------|------|--------|--------|
| A1 | Utils.RunAndGetOutput | CreateProcessW | TProcess |
| A2 | devExec.pas | CreateProcessW + TerminateProcess | TProcess |
| A4 | Debugger.pas / DebugReader.pas | CreateProcessW + TerminateProcess + ReadFile + WriteFile | TProcess |

### 剩余硬阻塞

| 编号 | 组件 | 阻塞原因 |
|------|------|---------|
| A4 收尾 | ConsolePauser.exe | Windows exe 包装，Compiler.pas 828/869 引用；ProgramHasConsole 本身已三平台 |
| A3 | main.pas 进程启动 | `WinExec`（9.x）和 `ShellExecute`（10.x）；TProcess 化需保持行为一致 |
| A5 | GDB → LLDB | macOS 无 GDB，须另写 lldb 后端 |
| A6 | Phase 0 .lpi BuildModes | .lpi 加 Linux gtk2 / macOS cocoa 构建配置 |

---

## 工具教训

- `{$WARNINGS OFF}` 编译器指令不得写在 `var` 段内部（Pascal 语法不允许），须写在函数体内
- FPC 3.2.2 的 Hint 5057 来自数据流分析，无法通过添加初始化语句消除（TProcess.Output.Read 是运行时填Buf）；代码逻辑正确时可接受
- `.lpi` 中替换 UnitOutputDirectory 时，必须同时替换所有 BuildModes 中的 Target Filename；否则 lazbuild 仍会用 Release 模式的链接目标路径（中文乱码导致链接失败）
- 临时替换 .lpi 输出路径验证编译阶段通过后，exe 大小（80,277,674 bytes）与已知正常构建一致

---

## 任务卡更新

`DevCpp-Lazarus_任务卡_Phase0_A1A2_进程执行封装_20260914.md` 追加 §9 A4 状态。
