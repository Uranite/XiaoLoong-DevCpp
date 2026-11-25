# 改造任务卡：Phase 0 + A1/A2 — 进程执行统一封装（跨平台）

- **项目**：`c:\Users\Administrator\WorkBuddy\2026-DevCpp-Lazarus\DevCpp-Lazarus`
- **建立日期**：2026-09-14
- **目标**：把 Windows 专有的进程执行（`CreateProcessW`/`CreatePipe`/`ShellExecuteW`）统一收敛到 LCL 跨平台 `TProcess`，使编译构建与运行用户程序在 Linux（继而 macOS）下可用。
- **前置评估文档**：`DevCpp-Lazarus_跨平台改进评估_20260914.md`（A 组 = A1/A2/A3/A5/A6）

---

## 0. 范围与 DoD

**在本卡内完成**
- Phase 0：在 `.lpi` 加 Linux/macOS 构建模式，跑一次真实 Linux 编译拿到错误清单。
- A1：重写 `Utils.RunAndGetOutput`（编译/构建/工具调用的核心）为 `TProcess`。
- A1.0（A1 前置）：把 `AnsiBytesToUnicode` 解码器改为跨平台。
- A2：重写 `devExec.pas`（运行用户程序）为 `TProcess`。

**不在本卡（跨阶段，已记录于评估文档）**
- A3 `Compiler.LaunchThread`，A4 `ConsolePauser.exe` 平台化，A5 `SetPath` PATH 注入，A6 `GetTickCount`，B 调试器，C/D/E/F/G 各组。
- 仅"封装"，不改任何**调用方**签名（编译器/运行入口语义保持等价）。

**Definition of Done（验收）**
1. 在 Linux 主机 `lazbuild --build-mode=Linux DevCpp.lpi` 可编译到底（本卡三处零 Windows API 依赖）。
2. Windows 下重建 `0 Error`，且编译/运行用户程序行为与改造前等价（回归测试）。
3. `RunAndGetOutput` 逐行输出回调、中止回调、退出码返回语义不变（见 §3.3）。

---

## 1. Phase 0 — 构建基础设施（前置，约 3~5 天，风险：中）

**目的**：不改业务代码，先暴露 Linux 下所有编译错误，作为 A1/A2 的"编译靶标"。

### P0.1 在 `.lpi` 新增构建模式
`DevCpp.lpi` 当前结构（已核实）：
- `<BuildModes>`（31）含两个 `<BuildMode>`（34-73 Release、76-108 Debug），各 `<CompilerOptions>` 内含 `<Win32>`（65/100，选 win32 widgetset）+ `<CustomOptions Value="-dCompiler6_Up -dPUREPASCAL"/>`。
- 默认 `<CompilerOptions>`（555）同样含 `<Win32>`（570）。

**操作（推荐在 Lazarus IDE 做，最稳）**：
- Project Options → Build Modes → 复制 Release 为 `Linux`，设 Target OS=Linux、Target CPU=x86_64、Widgetset=gtk2。
- 再复制为 `macOS`，Target OS=Darwin、CPU=x86_64、Widgetset=cocoa。
- 若手工改 `.lpi`，在 `<BuildModes>` 内新增：
```xml
<BuildMode Name="Linux">
  <CompilerOptions>
    <TargetOS Value="Linux"/>
    <TargetCPU Value="x86_64"/>
    <CustomOptions Value="-dCompiler6_Up -dPUREPASCAL"/>
  </CompilerOptions>
</BuildMode>
<BuildMode Name="macOS">
  <CompilerOptions>
    <TargetOS Value="Darwin"/>
    <TargetCPU Value="x86_64"/>
    <CustomOptions Value="-dCompiler6_Up -dPUREPASCAL"/>
  </CompilerOptions>
</BuildMode>
```
> widgetset 由 IDE 的 Widgetset 组合决定（写入 `.lpi`/LCL 包依赖），`<Win32>` 块对 Linux 自动不生效；无需手工删。

### P0.2 在 Linux 主机构建，产出错误清单
```bash
# 必须 cd 到项目目录（否则资源编译器找不到 devcpp.ico，见 devcpp_ico 根因文档）
cd /path/to/DevCpp-Lazarus
lazbuild DevCpp.lpi --build-mode=Linux      # 或 lazbuild --widgetset=gtk2 --build-mode=Linux
```
- 将 stderr+stdout 落盘：`lazbuild ... 2>&1 | tee build_linux.txt`。
- **产出"未知标识符/未声明"清单**：所有仍依赖 `Windows`/`TStartupInfoW`/`CreateProcessW` 等的位置——本卡只负责其中 `Utils.pas` 与 `devExec.pas` 两处，其余（Debugger、main、devcfg 等）登记为后续阶段。

### P0.3 编译守卫策略（可选）
- 对暂未移植的单元，可临时用 `{$IFDEF MSWINDOWS}` 包住其 Windows-only 段，使 Linux 构建先"绿"再逐步放开。本卡不强制。

**出口**：一份 `build_linux.txt`，含确定性的错误行清单。

---

## 2. A1.0 — 移植 `AnsiBytesToUnicode` 解码器（A1 前置，风险：中）

**位置**：`Utils.pas:748` `function AnsiBytesToUnicode(Buf: PAnsiChar; BufLen: Integer): UnicodeString`

**问题**：实现用 `MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, …)` 再回退 `CP_ACP`——这两个是 Windows API，Linux/macOS 编译不过，会拖垮所有调用方（含 `RunAndGetOutput`）。

**改造**：保留签名，按平台分支：
```pascal
function AnsiBytesToUnicode(Buf: PAnsiChar; BufLen: Integer): UnicodeString;
begin
  if BufLen <= 0 then begin Result := ''; Exit; end;
  {$IFDEF MSWINDOWS}
    // 原逻辑不变：先 UTF-8，失败回退 CP_ACP
    ... MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, ...) ...
  {$ELSE}
    // Linux/macOS：编译器/工具输出默认为 UTF-8
    Result := UTF8ToUnicodeString(UTF8String(AnsiString(Buf, BufLen)));
    // 如需更稳，可用 TEncoding.UTF8.GetString(Bytes)，但 UTF8ToUnicodeString 足够
  {$ENDIF}
end;
```
- 非 Windows 分支 `uses` 增加 `LazUTF8`（或 `SysUtils` 的 `TEncoding`）。
- 注意 `RunAndGetOutput` 行解码链为 `AnsiBytesToUnicode → UTF8Encode → String(UTF8String)`（见 §3.3），跨平台后该链对合法 UTF-8 输入保持恒等，无需改。

---

## 3. A1 — 重写 `Utils.RunAndGetOutput`（核心，风险：中高）

**位置**：`Utils.pas:59`（声明）/ `:770`（实现，约 770-1010 行）
**当前依赖（纯 Windows）**：`Windows.TStartupInfoW`、`TProcessInformation`、`CreatePipe`、`DuplicateHandle`、`CreateProcessW`、`ReadFile`、`GetExitCodeProcess`、`TerminateProcess`、`CloseHandle`，以及 `AnsiBytesToUnicode`（Windows-only，由 A1.0 解决）。

**签名（保持不变）**：
```pascal
function RunAndGetOutput(const Cmd, WorkDir: String;
  LineOutputFunc: TLineOutputFunc; CheckAbortFunc: TCheckAbortFunc;
  ShowReturnValue: Boolean = True; LineOutputData: Pointer = nil;
  CheckAbortData: Pointer = nil): String;
// TLineOutputFunc = procedure(const Line: String; Data: Pointer);   (Utils.pas:52)
// TCheckAbortFunc = procedure(var AbortThread: boolean; Data: Pointer); (Utils.pas:53)
```

### A1.1 新实现骨架（用 `TProcess`）
```pascal
function RunAndGetOutput(const Cmd, WorkDir: String;
  LineOutputFunc: TLineOutputFunc; CheckAbortFunc: TCheckAbortFunc;
  ShowReturnValue: Boolean; LineOutputData, CheckAbortData: Pointer): String;
var
  P: TProcess;
  Buf: array[0..8191] of Byte;
  nRead: Integer;
  RawBuf: RawByteString;
  p: Integer;
  LineBytes: RawByteString;
  s: String;
  bAbort: Boolean;
begin
  Result := '';
  RawBuf := '';
  P := TProcess.Create(nil);
  try
    P.Options := [poUsePipes, poStderrToOutPut];   // stderr 合并到 stdout，等同原 DuplicateHandle 行为
    P.CommandLine := Cmd;                           // 原 CreateProcessW 的命令行串，保持原样
    P.CurrentDirectory := WorkDir;
    try
      P.Execute;
    except
      on E: Exception do begin Result := 'Execute error: ' + E.Message; Exit; end;
    end;
    bAbort := False;
    repeat
      if Assigned(CheckAbortFunc) then CheckAbortFunc(bAbort, CheckAbortData);
      if bAbort then begin P.Terminate(1); Break; end;   // 原 TerminateProcess(pi.hProcess,1)
      nRead := P.Output.Read(Buf, SizeOf(Buf));
      if nRead <= 0 then Break;                          // 管道关闭，正常结束
      // —— 以下字节缓冲/行切分逻辑 1:1 照搬原函数（原 909-935）——
      SetLength(RawBuf, Length(RawBuf) + nRead);
      Move(Buf[0], RawBuf[Length(RawBuf) - nRead + 1], nRead);
      while True do begin
        p := Pos(#10, RawBuf);
        if p = 0 then Break;
        LineBytes := Copy(RawBuf, 1, p - 1);
        Delete(RawBuf, 1, p);
        s := String(UTF8String(UTF8Encode(AnsiBytesToUnicode(PAnsiChar(LineBytes), Length(LineBytes)))));
        Result := Result + s + #10;
        if Assigned(LineOutputFunc) then LineOutputFunc(s, LineOutputData);
      end;
    until False;
    // 冲刷末尾无 LF 的残留字节（原 937-944）
    if Length(RawBuf) > 0 then begin
      s := String(UTF8String(UTF8Encode(AnsiBytesToUnicode(PAnsiChar(RawBuf), Length(RawBuf)))));
      Result := Result + s;
      if Assigned(LineOutputFunc) then LineOutputFunc(s, LineOutputData);
    end;
    // 退出码（原 GetExitCodeProcess → TProcess.ExitStatus）
    if ShowReturnValue then
      Result := Result + ' ' + IntToStr(P.ExitStatus);
  finally
    P.Free;
  end;
end;
```

### A1.2 关键等价点（务必保持，否则编译器解析会乱）
- **逐行回调**：`LineOutputFunc` 对每条以 `#10` 结尾的**完整行**调用一次；多字节 UTF-8 序列不得被拆分（原 `RawBuf` 累积逻辑）。→ 直接复用原 909-944 代码，仅把 `ReadFile(hOutputRead,aBuf,…)` 换成 `P.Output.Read(Buf,…)`。
- **中止**：`CheckAbortFunc` 返回 `bAbort=True` → `P.Terminate(1)`（原 `TerminateProcess(pi.hProcess,1)`）。
- **返回值**：成功 = 累积输出 +（ShowReturnValue 时）` ' ' + 退出码`；失败 = 错误串。→ 与原 946-1010 语义一致。
- **stderr 合并**：`poStderrToOutPut` 等价于原 `DuplicateHandle(hOutputWrite→hErrorWrite)`。

### A1.3 清理
- `uses` 移除 `Windows`（或仅保留被其他函数使用项，需核对本单元其他函数）。
- 删除 `TStartupInfoW`/`TProcessInformation`/`CreatePipe`/`DuplicateHandle`/`ReadFile`/`GetExitCodeProcess`/`TerminateProcess`/`CloseHandle` 等声明与代码。
- 增加 `Process` 单元（已在 `FileAssocs.pas` 用，确认可引）。

### A1.4 调用方（均不变，仅作回归核对）
| 调用点 | 用途 |
|------|------|
| `devrun.pas:83` | **编译构建主路径**（带行输出+中止回调） |
| `devcfg.pas:1699` | 工具探测（无回调） |
| `devcfg.pas:3456/3465` | 运行命令（无回调） |
| `ProfileAnalysisFrm.pas:141/235` | gprof 分析（无回调） |
> `Utils.old.pas` 为废弃副本，忽略。

---

## 4. A2 — 重写 `devExec.pas`（运行用户程序，风险：低）

**位置**：`devExec.pas`（全文件约 150 行；`uses Windows, Classes, Forms;`）
**当前依赖（纯 Windows）**：`TStartupInfoW`、`TProcessInformation`、`CreateProcessW`（:93）、`WaitForSingleObject`、`CloseHandle`、`TerminateProcess`（Reset）。
**外部调用方（不变）**：`Compiler.pas:839/862/877`（运行编译产物，含 `ConsolePauser.exe`）；`main.pas` 用 `.Running`/`.Reset`/`.Free`（:1845/6080/6081/7567/7586/8176/8984/8987）。`main-ownerdraw.pas` 为未进 `.lpi` 的实验副本，忽略。

### A2.1 设计
- `TExecThread`（`: TThread`）持有 `P: TProcess`（在 `Execute` 内创建/释放）。
- 删除 `fExec: TProcessInformation`、`TStartupInfoW` 相关字段。

### A2.2 `TExecThread.ExecAndWatch`（原 Windows 启动+等待）
```pascal
procedure TExecThread.ExecAndWatch;
var
  P: TProcess;
begin
  P := TProcess.Create(nil);
  try
    P.Executable := fFile;
    P.Parameters.Text := fParams;     // 原 '"fFile" fParams' 字符串拆开；若想保留整串可用 P.CommandLine
    P.CurrentDirectory := fPath;
    P.ShowWindow := IfThen(fVisible, swoShow, swoHide);  // 原 STARTF_USESHOWWINDOW
    P.Options := [];                   // 不在 Windows 下强加控制台窗口
    P.Execute;                         // 同步阻塞至进程退出（等同原 WaitForSingleObject(...,INFINITE)）
    fExitCode := P.ExitStatus;
  finally
    P.Free;
  end;
  if Assigned(fOnTerm) then Synchronize(nil, @DoTerm);   // 原 OnTermEvent
end;
```
- **超时**：原 `WaitForSingleObject(pi.hProcess, fTimeOut)`，`Compiler.pas` 实际传 `INFINITE`。若需非零超时，改用异步 `P.Active := True` + 轮询 `P.Running` + `Sleep`，超时则 `P.Terminate`；本卡默认 `P.Execute`（覆盖 INFINITE 主场景）。

### A2.3 `Reset`（中止运行）
- 原 `TerminateProcess(fExec.Process, 0)`（:145 附近）。
- 改为终止仍存活的 `TProcess`：在 `TdevExecutor` 持有 `TExecThread` 引用，调用 `TExecThread.TerminateProcess`（线程内 `P.Terminate(0)`）。
- **跨线程注意**：`TProcess.Terminate` 用进程句柄，原 `Reset` 本就跨线程调 `TerminateProcess`；为稳妥，`TExecThread` 设 `fTerminateFlag`，线程循环检测后 `P.Terminate`。保留 `property Process: Cardinal read fProcess`，`fProcess` 在 `P.Execute` 后由 `P.ProcessID` 赋值。

### A2.4 可见性 / OnTerminate
- `fVisible` → `P.ShowWindow`（swoShow/swoHide）。
- `OnTermEvent: TNotifyEvent` → `Execute` 结束后 `Synchronize` 触发（GUI 线程安全）。

### A2.5 清理
- `uses` 移除 `Windows`；保留 `Classes, Forms`（及 `Process`）。
- 删除 `TStartupInfoW`/`TProcessInformation`/`CreateProcessW`/`WaitForSingleObject`/`CloseHandle`/`TerminateProcess` 相关代码。

### A2.6 关联（不在本卡，标记待办）
- `ConsolePauser.exe`（Compiler.pas:828/869）为 Windows 控制台暂停器，Linux/macOS 不需要；A4 阶段改为"非 Windows 直接运行用户程序"。

---

## 5. 统一封装说明（为何这样改）

- **收敛目标**：用 `TProcess` 作为唯一进程原语，替换散布的 `CreateProcessW`/`CreatePipe`/`ShellExecuteW`。本卡覆盖"编译执行（A1）"与"运行程序（A2）"两条主链路。
- **可选后续合并**：A1/A2 各自就地改写后，若要把"字节→行流式读取"提取为单一共享助手，可新增 `devProcess.pas`（私有 `ReadProcessLines`），供两者复用——但属 Phase 1 打磨，非本卡必交付，以免引入 `Utils↔devProcess` 单元环依赖。
- **不破坏调用方**：`RunAndGetOutput` 与 `devExecutor` 的公开签名/语义完全保持，编译器与运行入口零改动。

---

## 6. 执行顺序与命令

```
1) P0.1  在 .lpi 加 Linux/macOS 构建模式（IDE 或手工 XML）
2) P0.2  Linux 主机 lazbuild --build-mode=Linux → build_linux.txt（错误清单）
3) A1.0  改 AnsiBytesToUnicode 跨平台（否则 RunAndGetOutput 编不过）
4) A1    重写 RunAndGetOutput 为 TProcess；删除 Windows API；保留行切分
5) A2    重写 devExec.pas 为 TProcess；Reset→Terminate；删 Windows uses
6) 验证  Windows: C:\lazarus\lazbuild.exe DevCpp.lpi -B  → 0 Error，跑一次编译+运行程序回归
7) 验证  Linux:  lazbuild --build-mode=Linux            → 本卡两处 0 未声明错误（其余登记）
```

**强制**：所有 `lazbuild` 调用前先 `cd` 到项目目录（资源编译器相对路径解析依赖 cwd，否则误报 `devcpp.ico not found`）。

---

## 7. 风险与回退

| 风险 | 等级 | 缓解 |
|------|:---:|------|
| `AnsiBytesToUnicode` 跨平台后解码不一致（尤其 GBK 编译器输出） | 中 | 保留原 UTF-8→ACP 回退语义；Windows 分支不动；非 Windows 仅 UTF-8 |
| `TProcess.Output.Read` 阻塞/分帧与原 `ReadFile` 行为微差 | 中 | 字节缓冲+按 `#10` 切行逻辑 1:1 复用，不改语义 |
| `devExec` 跨线程 `Terminate` 句柄失效 | 低-中 | 采用 `fTerminateFlag` 在线程内 `P.Terminate`，避免主线程直调 |
| `poStderrToOutPut` 与 Windows 合并行为差异 | 低 | 与原 `DuplicateHandle` 合并等价；编译日志核对 |
| 回归 Windows | 中 | 改造后 Windows 全量 `-B` 重建 + 手动编译/运行一次 |

**回退**：A1/A2 均为局部改写，可整体 revert 对应函数；调用方不受影响。建议在独立 commit/分支进行。

---

## 8. 关键文件:行清单（checklist）

- `DevCpp.lpi`：31 `<BuildModes>`；34-73/76-108 现有模式；65/100/570 `<Win32>`；71/106/576 `<CustomOptions>`
- `Utils.pas`：52/53 回调类型；59 声明；748 `AnsiBytesToUnicode`（Windows-only）；770 `RunAndGetOutput` 实现；870 `CreateProcessW`；909-944 行切分；946-1010 返回值/句柄清理
- `devExec.pas`：全文件 `uses Windows`；93 `CreateProcessW`；145 `Reset`/`TerminateProcess`；`TExecThread`/`TdevExecutor` 结构
- 调用方：`devrun.pas:83`、`devcfg.pas:1699/3456/3465`、`ProfileAnalysisFrm.pas:141/235`、`Compiler.pas:839/862/877`、`main.pas:1845/6080/6081/7567/7586/8176/8984/8987`

---

## 9. 实施状态（2026-09-14）

- **A1 已完成并验证**：`Utils.pas` 基于 14:14 备份（真正的 pre-corruption 状态）落地，全量 `lazbuild DevCpp.lpi -B` → 0 Error / 55204 lines。`RunAndGetOutput` 改写为 `TProcess` 异步模式、`AnsiBytesToUnicode` 改写为 `{$IFDEF MSWINDOWS}`(MultiByteToWideChar) / `{$ELSE}`(UTF8ToUnicodeString) 分支、`Process` 改为无条件 uses。等价约束（逐行回调 / 中止回调 / stderr 合并 / 返回值语义）全部保留。详细见 `DevCpp-Lazarus_A1_进程执行封装落地_20260914.md`。
- 骨架修正（实施中发现，原卡内简化骨架需更新）：① `Process` 必须无条件 uses，原 `{$ELSE}` 分支在 Windows 下取不到 `TProcess`；② `RunAndGetOutput` 必须用 `P.Active := True` 异步排空管道，绝不能用 `P.Execute` 同步 + `poUsePipes`（管道缓冲满会死锁）。
- 实施教训：函数替换必须最后才做 uses 补丁（避免 1 行位移导致索引错位、函数被重复插入）；`Select-String` 正则的模式 `(` 必须转义；定位函数结尾用"注释感知的 begin/try/case vs end 深度平衡"查找器。
- A2（devExec.pas 整文件改 TProcess）尚未实施。
- **A2 已完成并验证（2026-09-14）**：`devExec.pas` 整文件改写为 `TProcess`，移除 `Windows` 依赖（uses 改为 `Classes, Forms, Process, LCLIntf`）。`TExecThread.ExecAndWait` 用 `P.Active := True` + 轮询 `P.Running`（自检 `Terminated` + 超时，不用阻塞式 `WaitOnExit`，以便 `Reset` 可外部中断）；`TdevExecutor.Reset` 调用 `fExec.Terminate`（置 `Terminated`），由执行线程自身 `P.Terminate(0)` 杀进程（规避跨线程句柄失效）；新增 `fIsRunning` 守卫避免 `FreeOnTerminate` 后悬垂调用。`devExecutor` 公开 API（ExecuteAndWatch/Running/Reset/Free）与 `TExecThread.Process` 属性完全保留，调用方（Compiler.pas:839/862/877、main.pas 状态查询）零改动。全量构建 0 Error / 55216 lines。仅新增良性 5043（P.CommandLine 弃用）与原有 5024（Sender）提示，按保留口径不抑制。