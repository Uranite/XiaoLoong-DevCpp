# DevCpp-Lazarus 调试器 TProcess 缺 poUsePipes 根因修复（2026-09-15 11:45 GMT+8）

## 问题现象
GDB 跨平台 TProcess 化后，启动调试时：
- 不弹任何错误对话框
- DebugOutput 文本框完全无输出
- 疑似 DebugReader 未连上 GDB 输出流，或 GDB 未启动

## 排查过程
1. 在 `DebugReader.pas Execute` 加诊断日志（写 `_debug_reader.log`），确认 Reader 线程是否读到数据。
2. 用户实测：**日志文件不存在** → Reader 线程在写日志前就已停止（既没进"读到数据"分支，也没进"进程退出"分支）。
3. 查 FPC RTL 源码（`C:\lazarus\fpc\3.2.2\source\packages\fcl-process\src`）确认机制：
   - `win/process.inc:274` — `If poUsePipes in Options then CreatePipes(HI,HO,HE,...)`
   - `win/process.inc:291-298` — 同样以 `poUsePipes` 为条件才调用 `CreateStreams`（该函数里才 `FOutputStream := TInputPipeStream.Create(...)`）
   - `processbody.inc:133` — `Property Output : TInputPipeStream Read FOutputStream;`
   - `win/process.inc:48,141` — 只有 `poUsePipes` 才置 `Startf_UseStdHandles`（重定向标准句柄）
   - 结论：**没有 poUsePipes ⇒ 不建管道、不重定向 std 句柄，`Output`/`Input` 均为 nil**。

## 根因
`Debugger.pas` 的 GDB 启动处写成：
```pascal
fGDBProcess.Options := [poStderrToOutPut];   // 缺 poUsePipes
```
（该缺失自 A4 首次 TProcess 化起就存在）
于是 Reader 线程 `fProcess.Output.Read(...)` 对 nil 取用 → 线程 AV 退出（FreeOnTerminate 静默销毁）→ 无输出、无日志。`SendCommand` 的 `Input.Write` 同理对 nil 报错（此前弹 ID_ERR_WRITEGDB 对话框的真正原因也是这个，而非 poNoConsole）。

## 修复
`Debugger.pas` Start：
```pascal
fGDBProcess.Options := [poUsePipes, poStderrToOutPut];
```
并补注释说明 poUsePipes 为必需项、poNoConsole 不可加（CREATE_NO_WINDOW 破坏控制台程序 stdin）。

## 验证
- `lazbuild _b4.lpi -B` → exit 0，55212 lines，Warning=53，exe 80279880 bytes。
- 功能待用户实测（DebugOutput 是否有输出 / `_debug_reader.log` 是否生成）。

## 顺带澄清（Windows 控制台窗口行为）
FPC TProcess 创建标志（`win/process.inc GetCreationFlags`）：
- `poNoConsole` → CREATE_NO_WINDOW
- `poNewConsole` → CREATE_NEW_CONSOLE
- 都不加 → 从 GUI 进程启动控制台子程序时，Windows 会**新建控制台窗口**（因无控制台可继承）。
  故交互式程序需 `ShowWindow := swoHIDE`（置 Startf_UseShowWindow）隐藏该窗口；
  纯输出捕获程序（编译器）可加 `poNoConsole` 免窗口。

## 现状文件
- 已改：`Debugger.pas`（Options 加 poUsePipes）
- 临时保留：`DebugReader.pas` Execute 内的诊断日志（验证通过后删除）
- 其余 TProcess Options：`Utils.pas:800 [poUsePipes,poStderrToOutPut,poNoConsole]`（编译器，正确）；`Utils.pas:514/1453` LINUX/DARWIN 分支；`devExec.pas` 无需管道（运行用户程序）。
