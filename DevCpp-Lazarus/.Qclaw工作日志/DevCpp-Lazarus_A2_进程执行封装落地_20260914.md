# DevCpp-Lazarus — A2 进程执行封装落地（devExec.pas → TProcess）

日期：2026-09-14
状态：**完成（0 Error）**
产物：`c:\Users\Administrator\WorkBuddy\2026-DevCpp-Lazarus\DevCpp-Lazarus\devExec.pas`

## 目标
跨平台评估任务卡 A2：把 `devExec.pas` 从纯 Windows `CreateProcessW` 体系整文件改写为跨平台 `TProcess`，同时保留 `devExecutor` 公开 API（调用方零改动）。

## 关键结论
- 全量构建 `lazbuild DevCpp.lpi -B`：**0 Error**，55216 lines，4865024 bytes code。
- `devExec.pas` 已无 Windows 进程 API 残留（`CreateProcessW`/`TerminateProcess`/`TStartupInfoW`/`TProcessInformation`/`WaitForSingleObject`/`CloseHandle` 等均移除；唯一出现的 `WaitForSingleObject` 是注释）。`uses` 由 `Windows, Classes, Forms` 改为 `Classes, Forms, Process, LCLIntf`。
- 仅新增良性 Warning(5043) `P.CommandLine`/`SetCommandLine` 弃用（来自 `P.CommandLine := ...`，与 A1 同口径），以及原有 Hint(5024) `Sender` 未用——按既定"保留良性提示"口径不抑制。

## 落地改动
1. **uses**：`Windows` → `Process`(TProcess) + `LCLIntf`(GetTickCount 跨平台超时)；保留 `Classes`(TThread)、`Forms`(Application.Terminated)。
2. **TExecThread.ExecAndWait**：
   - `TProcess.Create` + `P.CommandLine := '"'+fFile+'" '+fParams`（逐字命令行，等价原 `CreateProcessW` 的 lpCommandLine，引号保护含空格路径）+ `P.CurrentDirectory := fPath`。
   - 可见性：`P.ShowWindow := swoShow/swoHIDE`（替换 `STARTF_USESHOWWINDOW`+`wShowWindow`）。
   - **异步** `P.Active := True`，随后轮询 `while P.Running do`：
     - `if Terminated then P.Terminate(0); Break;` —— Reset 由执行线程**自身**杀进程，规避跨线程句柄失效（任务卡要求的 fTerminateFlag 等价物）。
     - `if fTimeOut <> INFINITE then if GetTickCount-StartTick >= fTimeOut then Break;` —— 超时即停止等待、保留进程运行（等价原 `WaitForSingleObject(hProcess, fTimeOut)` 语义）。`INFINITE` 本地定义为 `$FFFFFFFF`。
   - 不用阻塞式 `WaitOnExit`（否则 Reset 无法从外部中断）。
3. **TdevExecutor.Reset**：`if fIsRunning and Assigned(fExec) then fExec.Terminate;` 置 `Terminated`，由执行线程循环内 `P.Terminate(0)` 杀进程；并 `fIsRunning := False`。新增 `fIsRunning` 守卫，避免 `FreeOnTerminate` 后悬垂 `fExec` 被误调（比原 `TerminateProcess(fExec.Process,0)` 更安全）。
4. 保留：`TExecThread.Process: Cardinal` 属性（填充 `Cardinal(P.ProcessID)`，外部未使用）；`devExecutor` 单例；`ExecuteAndWatch`/`Running`/`TerminateEvent` 原样。

## 调用方零改动（已验证编译）
- `Compiler.pas:839/862/877` `devExecutor.ExecuteAndWatch(..., INFINITE, ...)`。
- `main.pas` 状态查询 `devExecutor.Running` / `devExecutor.Reset` / `devExecutor.Free`（5703/5704/6080/6081/7190/7209/7567/7586/7797/8176/8599/8602/8984/8987/1845/1724 等）。

## 教训 / 备注
- `devExecutor` 公开 API 必须原样保留：先 grep 全项目 `devExecutor.` 用法确认仅用到 ExecuteAndWatch/Running/Reset/Free，再改写。
- 整文件重写（小文件 ~150 行）比数组切片更安全，规避了 A1 期间遇到的索引漂移/正则未转义类问题。
- 任务卡 `DevCpp-Lazarus_任务卡_Phase0_A1A2_进程执行封装_20260914.md` §9 已追加 A2 状态。
- 后续：ConsolePauser.exe 处理（Compiler.pas 引用）标记为 A4，未在本轮处理；Debugger.pas（GDB 启动）仍纯 Windows，属独立硬阻塞。
