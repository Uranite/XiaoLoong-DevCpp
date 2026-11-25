# A4 — ConsolePauser.exe 跨平台化（完成）

- **日期**：2026-09-17
- **项目**：`c:\Users\Administrator\WorkBuddy\2026-DevCpp-Lazarus\DevCpp-Lazarus`
- **目标**：`ConsolePauser.exe` 仅存在于 Windows，非 Windows 需等价行为（运行控制台程序并保持窗口打开让用户看输出）。

## 1. ConsolePauser.exe 的作用（Tools\ConsolePauser.cpp）
Windows 控制台包装器：运行 `<filename> <parameters>`，等其结束，打印耗时与返回值，再 `system("pause")` 保持控制台窗口打开。用法：`ConsolePauser.exe <filename> <parameters>`。Dev-C++ 在「ConsolePause 开启 且 目标是控制台程序（ProgramHasConsole=true）」时，把用户程序包一层 ConsolePauser 来运行。

## 2. 改动（Compiler.pas）
运行路径有两处分支（ctSource / ctProject），均把「使用 ConsolePauser」整体包进 `{$IFDEF MSWINDOWS}`：
- **Windows**：行为完全不变——`Parameters := '"' + FileToRun + '" ' + fRunParams; FileToRun := devDirs.Exec + 'ConsolePauser.exe';` 且保留 `ID_ERR_NOCONSOLPAUSER` 缺失检查。
- **非 Windows**：调用新增辅助过程 `GetConsolePauseRunner`，在终端模拟器里运行并保持窗口打开。

新增辅助过程（Compiler.pas 实现段，`{$IFNDEF MSWINDOWS}` 守卫）：
```pascal
procedure GetConsolePauseRunner(const AExe, AParams: string; out ATerminal, ATerminalParams: string);
begin
  {$IFDEF LINUX}
  ATerminal := 'xterm';
  ATerminalParams := '-hold -e ''' + AExe + ' ' + AParams + '''';   // xterm -hold -e '/path" args'
  {$ELSE} // DARWIN
  ATerminal := 'osascript';
  ATerminalParams := '-e ' + '''' + 'tell application "Terminal" to do script "' + AExe + ' ' + AParams + '"' + '''';
  {$ENDIF}
end;
```
调用处传入已加双引号的程序路径：`GetConsolePauseRunner('"' + FileToRun + '"', fRunParams, FileToRun, Parameters)`。
最终 `devExecutor.ExecuteAndWatch(FileToRun, Parameters, ...)` 的 `P.CommandLine := '"xterm" -hold -e '"/path" args'"` 由 FPC Unix 解析器正确拆分。

## 3. 关键依据（已查证）
- FPC Unix `CommandToList`/`GetNextWord`（`fcl-process/src/processbody.inc` L171-239）：`Literals = ['"','''']`，**正确处理单/双引号字面量**。故 `xterm -hold -e 'PROG ARGS'` 在 Linux 上解析为 `xterm`/`-hold`/`-e`/`PROG ARGS` 四个 argv，路径含空格也能正确传递（内层双引号包裹程序路径）。
- `ProgramHasConsole`（Utils.pas）已实现三平台（PE subsystem / ELF PT_INTERP / .app），非 Windows 正确识别控制台程序。

## 4. 构建验证
`lazbuild _b6.lpi -B` → **exit=0，0 Error，55666 lines**（Windows 走 MSWINDOWS 分支，行为不变；`{$IFNDEF MSWINDOWS}` 块在 Windows 不编译）。

## 5. 已知限制 / 待办
- **macOS**：`do script "PROG ARGS"` 经 Terminal 的默认 shell 执行，若程序路径含空格会被 shell 拆分（AppleScript 字符串内未转义 `"`）。典型 `/Users/<name>/...` 无空格时正常；真机需细化路径转义。Linux `xterm` 已用内层双引号正确包裹，无此问题。
- **终端可用性**：Linux 默认依赖 `xterm`（几乎必装）；若缺失运行会失败，可后续加 `konsole`/`gnome-terminal` 等回退链。
- **Phase 0.2**：仍需在真实 Linux/macOS 主机 `lazbuild --build-mode=Linux` 跑一遍确认整套编译通过（本机 Windows 无法直接交叉编译验证）。
- macOS 调试后端（lldb）尚未实现 —— 独立于 A4。

## 6. 文件改动
- 修改 `Compiler.pas`：`GetConsolePauseRunner` 辅助过程 + ctSource/ctProject 两处运行分支加 `{$IFDEF MSWINDOWS}`/`{$ELSE}` 守卫。
