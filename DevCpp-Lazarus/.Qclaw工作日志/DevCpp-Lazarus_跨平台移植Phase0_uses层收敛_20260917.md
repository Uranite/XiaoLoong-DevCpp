# 跨平台移植 — Phase 0（uses 层收敛）+ 剩余 Windows 调用清零

- **日期**：2026-09-17
- **项目**：`c:\Users\Administrator\WorkBuddy\2026-DevCpp-Lazarus\DevCpp-Lazarus`
- **目标**：消除 Linux/macOS 编译在"单元/符号"层面的硬阻塞，使 `lazbuild --build-mode=Linux` 能启动编译（Phase 0.2 的编译靶标）。

## 1. 已完成（本轮）

### 1.1 Phase 0.1 — `.lpi` 增加构建模式
`DevCpp.lpi` 的 `<BuildModes>` 新增两项（共 5 个：Default/Debug/Release/Linux/macOS）：
- `Linux`：`TargetOS=Linux` / `TargetCPU=x86_64` / `TargetWidgetType=gtk2`
- `macOS`：`TargetOS=Darwin` / `TargetCPU=x86_64` / `TargetWidgetType=cocoa`
- `<Win32>` 块对 Linux/macOS 自动不生效（LCL 行为）。
- 验证：`.lpi` 仍为合法 XML（5 个模式解析通过）。

### 1.2 7 处"未守卫"的 Windows 专有调用（IFDEF 感知扫描确认，非注释）
| 文件:行 | 原调用 | 跨平台改法 |
|---|---|---|
| EnvironOptfrm.pas:491 | `TerminateProcess(GetCurrentProcess,0)` | `{$IFDEF MSWINDOWS}…{$ELSE}Halt(0){$ENDIF}` |
| ExceptionFrm.pas:603 | `TerminateProcess(GetCurrentProcess,0)` | 同上 |
| FilePropertiesFrm.pas:206-207 | `GetWindowLong/SetWindowLong`(右对齐编辑框) | `window.Alignment := taRightJustify`（删除 `currentstyle` 变量） |
| main.pas:8690-8692 | `GetCommandLineW` ×3 | `{$IFDEF MSWINDOWS}GetCommandLineW{$ELSE}CmdLine{$ENDIF}`（`CmdLine` 为 System 全局 PChar，跨平台） |
| NewTemplateFrm.pas:174 | `DrawIcon(Handle,…)` | `Canvas.Draw(Rect.Left+XOffset, Rect.Top+XOffset, Icons[Index])` |

### 1.3 `uses` 层 Windows 单元收敛（字节级替换，不破坏编码）
- 33 个文件的 `uses Windows` → `{$IFDEF MSWINDOWS}Windows{$ELSE}LCLIntf, LCLType{$ENDIF}`。
  - Windows 构建因 `{$IFDEF MSWINDOWS}` 走原 `Windows` 分支，行为完全不变。
  - `HomepageFrm.pas` 本就用 `LCLIntf, LCLType`，无需改；`IconFrm.pas` 的 `Windows` 已在注释内，无需改。
- 守卫其余 Windows 专有单元（避免 Linux 下"unit not found"）：
  - `ShellAPI`：Utils.pas、devcfg.pas
  - `ShlObj`：devcfg.pas、FileAssocs.pas
  - `Registry`：devcfg.pas、FileAssocs.pas、main.pas、Utils.pas
- 已确认跨平台安全、无需处理的单元：`ComCtrls`、`CommCtrl`、`Messages`（均为 LCL 自带）。

### 1.4 构建验证
`lazbuild _b6.lpi -B` → **exit=0，0 Error，55637 lines**（Windows 行为不变，仅多了条件分支字节）。

## 2. 关键结论（静态扫描结果）

- **`TRegistry` 不是阻塞**：devcfg/main/FileAssocs 的全部 `TRegistry` 用法早已在 `{$IFDEF MSWINDOWS}` 内（main.pas 还有 `{$ELSE}` 空操作分支）。仅 `uses Registry` 需守卫（已做）。
- **`ShellExecute` 不是阻塞**：`Utils.ExecuteFile` 已有 `{$ELSE}` TProcess 分支；`main.pas`/`HomepageFrm.pas` 的相关调用全在 `//` 或 `{ }` 注释内，运行期早已用 `OpenURL`/`OpenDocument`。
- **进程执行/调试器已跨平台**（前序会话 A1/A2/A4）：`Utils.RunAndGetOutput`、`devExec`、`Debugger`/`DebugReader` 均改用 `TProcess`，`poUsePipes` 等已修正。
- **真正的剩余硬阻塞 = 功能层（需真实 Linux/macOS 运行验证，非单纯编译）**：
  1. **A4 `ConsolePauser.exe`**（Compiler.pas:828/869）：Windows 控制台暂停器，非 Windows 应直接运行用户程序。
  2. **macOS 调试后端**：无 GDB，需另写 `lldb` 后端（DebugReader 抽象层已就位，可加 `TLldbReader`）。
  3. **Phase 0.2**：真实 Linux 主机 `lazbuild --build-mode=Linux` 跑一遍，拿到权威错误清单（可能仍有 LCLType 未覆盖的类型/常量，需个别补 `$IFDEF`）。
  4. **字符串编码**：保持 `AnsiString` 为主，仅在 OS/文件/进程边界统一 UTF-8（既定口径，勿改 `{$MODE DelphiUnicode}`）。

## 3. 待办 / 下一步

- **Phase 0.2（最高优先，需 Linux 主机）**：在 Linux 上 `cd` 项目目录后 `lazbuild DevCpp.lpi --build-mode=Linux`，把 stderr+stdout 落盘为 `build_linux.txt`，据此逐个修剩余（若有）。本机为 Windows，无法直接交叉编译到 Linux（缺 FPC Linux 目标单元），需用户在有 Lazarus 的 Linux 环境执行。
- 可选：本机尝试安装 FPC Linux 交叉编译单元后跑 Phase 0.2（较重，需 fpcupdeluxe/cross 包）。
- A4 `ConsolePauser.exe` 跨平台化（非 Windows 跳过）。
- macOS `lldb` 后端（最大系统性风险点）。

## 4. 文件改动清单（本轮）
- 修改 `.lpi`：新增 Linux/macOS 构建模式
- 修改 33 个 .pas：`uses Windows` → 条件（LCLIntf/LCLType）
- 修改 Utils.pas/devcfg.pas/FileAssocs.pas：守卫 `ShellAPI`/`ShlObj`/`Registry`
- 修改 EnvironOptfrm.pas / ExceptionFrm.pas / FilePropertiesFrm.pas / main.pas / NewTemplateFrm.pas：7 处未守卫 Windows 调用跨平台化
- 未改动：DebugReader.pas、Debugger.pas（前序会话产物保持）
