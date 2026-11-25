# XiaoLoong Dev-C++ / XL7 — 跨平台（Windows / Linux / macOS）改进评估

- **项目**：`c:\Users\Administrator\WorkBuddy\2026-DevCpp-Lazarus\DevCpp-Lazarus`（Lazarus 4.6 / FPC 3.2.2，Delphi 模式）
- **评估日期**：2026-09-14
- **评估基线**：对照 2026-07-16 的《Linux 移植可行性评估报告》，并**逐项校核当前磁盘代码的真实状态**
- **评估方法**：全项目 grep 量化（`Windows` 单元引用、WinAPI 符号、条件编译指令）+ 关键模块逐行阅读
- **规模**：72 个 `.pas`、约 62,800 行

---

## 一、结论摘要（TL;DR）

1. **技术可行，且比 2026-07 评估时近了很多。** 当时列出的多数"红色阻塞"已在本轮迁移中顺手修掉（单实例、图标主题、文件关联、文件监控、配置路径、`pd` 分隔符）。
2. **核心编辑/解析/补全层天然跨平台**（LCL + ATSynEdit + 纯 Pascal），这是最大优势。
3. **剩余硬阻塞高度集中在"进程执行 + 调试器 + 构建系统"三处**：
   - `Utils.pas:RunAndGetOutput`（编译执行核心）—— 纯 Windows `CreateProcessW`，**无任何条件编译守卫**；
   - `devExec.pas`（运行用户程序）—— 纯 Windows；
   - `Debugger.pas`（GDB）—— 纯 Windows 进程 + 代码页；
   - `Compiler.pas` 的 `ConsolePauser.exe` 与工具链默认值（MinGW）；
   - `DevCpp.lpi` 仅 Win32 widgetset，无 gtk2/cocoa/目标 OS。
4. **最大系统性风险是字符串/编码**：全项目 `{$MODE Delphi}` ⇒ `String = AnsiString`（Windows ANSI 代码页），而 Linux/macOS 路径是 UTF-8。`DelphiUnicode` 迁移已因与 LCL 不兼容而回退（2026-09-11）。
5. **工作量估算（1 名有经验 Lazarus 开发者）**：
   - Linux 得到"基本可用版"：**约 4~6 周**
   - 三平台完整（含 macOS + 打包/签名）：**约 11~16 周**
6. **风险最高两项**：UTF-8 路径编码策略（高）、macOS 调试器（macOS 已弃用 GDB，须改 lldb，高）。

---

## 二、当前状态盘点（已跨平台 vs 待改造）

> 图例：✅ 已跨平台 / 🟡 部分（有分支但实现不完整）/ 🔴 纯 Windows 无守卫

| 模块 | 现状 | 证据（文件:行） | 结论 |
|------|------|----------------|------|
| 编辑器核心 `Editor.pas`（ATSynEdit/EControl） | LCL 组件 | — | ✅ |
| C++ 解析链 `CppParser/CppPreprocessor/CppTokenizer/StatementList` | 纯 Pascal | — | ✅ |
| 代码补全 / 类浏览 `CodeCompletion/ClassBrowser` | 纯 Pascal | — | ✅ |
| 项目文件 `Project.pas` | `TIniFile` | — | ✅ |
| 图标主题 `ImageTheme.pas` | 已改用 LCL `TBitmap`（无 GDI） | `TBitmap` 40/163/274；未见 `StretchBlt` | ✅ 已移植 |
| 单实例 `Instances.pas` | **已退化为空壳**，逻辑移至 `main.pas` 的 `TSingleInstance`（套接字） | `Instances.pas` 全文；`main.pas:9460` 注释 | ✅ 已移植 |
| 文件监控 `devFileMonitor.pas` | `{$IFDEF MSWINDOWS}` + 非 Windows 时间戳轮询兜底 | 101/160/199；注释 104 | ✅ 已移植 |
| 路径分隔符 `Version.pas` | `pd` 双分支（`\` / `/`） | 29/31 | ✅ |
| 入口配置路径 `DevCpp.lpr` | `{$IFDEF MSWINDOWS}`（Windows/ShlObj/APPDATA）+ 非 Win 分支 | 31/32/135 | 🟡 有分支，需核非 Win 是否落 `~/.config` |
| 文件关联 `FileAssocs.pas` | Win：`TRegistry`+`SHChangeNotify`；Linux：XDG MIME+`.desktop`；**无 macOS** | W 150/183，LINUX 66/80/394 | 🟡 缺 macOS（会误走 gtk 路径） |
| 配置删除 `devcfg.pas:RemoveOptionsDir` | Win `SHFileOperation`；Linux `FileUtil.DeleteDirectory` | 871 `{$IFDEF}`…`{$ELSE}` | ✅ 已移植 |
| 打开外部文件 `Utils.pas:ExecuteFile` | Win `ShellExecuteW`；非 Win `TProcess` | 711/712/720/724/739 | ✅ 已移植 |
| 文件夹/文档位置 `devcfg.pas` | `SHGetSpecialFolderPath`（含 ELSE） | 2701/2704 | 🟡 ELSE 需确认 |
| PATH 自动注入 `devcfg.pas` | Win 写注册表 HKLM Path；Linux 仅弹提示（功能降级） | 2322 `{$IFDEF}`…`{$ELSE}` | 🟡 Linux 为 stub |
| **编译执行 `Utils.pas:RunAndGetOutput`** | **纯 Windows `CreateProcessW` + `TProcessInformation`，无守卫** | 770/774/870 | 🔴 **核心阻塞** |
| **PATH 设置 `Utils.pas:SetPath`** | Windows `Get/SetEnvironmentVariableW` | 984/990/1012/1015/1021 | 🔴 |
| **运行程序 `devExec.pas`** | 纯 `CreateProcessW`/`TStartupInfoW`/`TerminateProcess` | 93/145；`uses Windows` 无守卫 | 🔴 |
| **调试器 `Debugger.pas` / `DebugReader.pas`** | 纯 `CreateProcessW` 启 GDB；`UTF8ToWinCP` 路径 | 170/208/284 | 🔴 |
| 编译器包装 `Compiler.pas` | `LaunchThread → TDevRun → RunAndGetOutput`；`ConsolePauser.exe` | 1002/1008/750/839；828/869 | 🔴 |
| 包管理器 `Version.pas` | `PACKMAN_PROGRAM = 'packman.exe'` | 102 | 🔴 |
| 计时 `GetTickCount` | Compiler 1398/1458、Editor 3386/3415、main 7513/7547 | — | 🔴（跨平台替换见下） |
| 打印 `Printer4Lazarus` | 跨平台包 | — | ✅ |

**量化证据（全项目 grep 计数）**
- `Windows`/`Winapi` 单元引用：**109 次**（38 个模块 `uses Windows`，其中多数仅在 `uses` 处被 `{$IFDEF MSWINDOWS}` 守卫）
- `ShellExecute` 26 / `ShellExecuteW`（Utils）；`HKEY` 13；`GetCurrentProcess` 9；`GetTickCount` 8；`CopyFile` 6；`TerminateProcess` 5；`GetShortPathName` 3
- 真正的功能级条件编译分支仅集中在：`FileAssocs.pas`、`devFileMonitor.pas`、`Utils.pas`、`devcfg.pas`、`DevCpp.lpr`、`Version.pas`；**其余文件的 `{$IFDEF MSWINDOWS}` 基本只用于守卫 `uses`**

---

## 三、分模块改进清单（改造方案 / 工作量 / 风险）

### A. 进程执行链（最优先，全部指向同一套解法）

统一的解决方案：**用 LCL 跨平台 `TProcess` 替换所有 `CreateProcessW` / `ShellExecute` 直接调用**（项目内 `FileAssocs.pas` 已有成功用例可参照）。

| 任务 | 现状 | 改造 | 工作量 | 风险 |
|------|------|------|:---:|:---:|
| A1 `Utils.pas:RunAndGetOutput` | `CreateProcessW`，读 stdout/stderr 重定向（`CreatePipe`） | 改 `TProcess`：`Options:=[poUsePipes,poStderrToOutPut]`，逐行回调保持 `TLineOutputFunc` 语义 | 2~3 天 | 中（管道分帧/编码/超时语义） |
| A2 `devExec.pas`（整个） | `CreateProcessW` + `WaitForSingleObject` + `TerminateProcess` | `TExecThread` 内部持有 `TProcess`；`Reset` → `TProcess.Terminate`；`Process` 属性改为暴露 `TProcess` 句柄 | 1~2 天 | 低（单文件 ~150 行） |
| A3 `Compiler.pas:LaunchThread` / `TDevRun` | 经 A1 走 Windows | 随 A1 自动解决；`ConsolePauser.exe`（828/869）需平台化 | 1~2 天 | 中 |
| A4 `ConsolePauser.exe` | 仅 Windows 控制台暂停器 | Linux/macOS 不需要（终端自带）；改为在非 Windows 下**直接运行用户程序**（可选：macOS 用 `.command`/`.app` 包装） | 1 天 | 中（运行行为差异） |
| A5 `Utils.pas:SetPath` | Windows `*EnvironmentVariableW` | 非 Windows 下用 `TProcess.Environment` 注入，或写入进程环境；避免全局改 PATH | 1~2 天 | 中 |
| A6 `GetTickCount`（Compiler/Editor/main） | Windows API | 改 `TThread.GetTickCount64` 或基于 `Now`/`GetTickCount64`（FPC 已有跨平台版本） | 0.5~1 天 | 低 |

### B. 调试器（跨平台难度最高，macOS 尤甚）

| 任务 | 现状 | 改造 | 工作量 | 风险 |
|------|------|------|:---:|:---:|
| B1 `Debugger.pas` 起停 GDB | `CreateProcessW` 启 `gdb --annotate=2`，`TerminateProcess` 停止 | 改用 `TProcess`；GDB 可执行文件路径按平台检测（Win: `CompilerSet.gdbName`；Linux: `/usr/bin/gdb`） | 2~3 天 | 中 |
| B2 GDB 通信/路径 | `UTF8ToWinCP` 转换源文件路径；`\`→`/` | 非 Windows 下原生 UTF-8，去掉 WinCP 转换（**与 F 编码策略联动**） | 1~2 天 | 中 |
| B3 macOS 调试 | 无 | **macOS 无可用 GDB（已弃用/受 SIP+签名限制）**，须新增 **lldb 后端**（`lldb` 的 MI 或 DAP 协议，与 GDB/MI 注解模型差异较大） | 3~5 周 | **高** |
| B4 调试器版本检测 | 依 `CompilerSet.gdbName` | 平台化 `gdbName`/`lldbName`，缺失时优雅降级（禁用调试而非崩溃） | 1 天 | 低 |

### C. 配置存储与外壳集成

| 任务 | 现状 | 改造 | 工作量 | 风险 |
|------|------|------|:---:|:---:|
| C1 `FileAssocs.pas` macOS | Linux 分支用 XDG/gtk，macOS 会误用 | 新增 `{$IFDEF DARWIN}`：用 `open` + LaunchServices/UTI，或 `duti`；不写 `~/.local` | 2~3 天 | 中 |
| C2 `devcfg.pas` PATH 注入 | Linux 仅弹提示（stub） | 可选增强：写 shell profile 片段 / 提供"复制命令"按钮；或维持提示 | 1~2 天 | 低 |
| C3 `devcfg.pas:DocumentsPath` | `SHGetSpecialFolderPath`（含 ELSE） | 确认 ELSE 落到 `$XDG_DOCUMENTS_DIR` 或 `$HOME/Documents`；macOS `$HOME/Documents` | 0.5 天 | 低 |
| C4 `main.pas:4795` TRegistry | 启动时读注册表 | 核对是否已被 `{$IFDEF}` 守卫；非 Windows 走 INI/`devData` | 0.5~1 天 | 中 |
| C5 单实例 | 已改套接字 | Linux/macOS 验证套接字/文件锁行为一致 | 1 天 | 低 |

### D. 工具链与路径

| 任务 | 现状 | 改造 | 工作量 | 风险 |
|------|------|------|:---:|:---:|
| D1 编译器默认集 | 假设 MinGW（`gccName`/`BinDir`/`gdbName`） | 新增平台预设：Linux 用 `/usr/bin/gcc`、`g++`、`gdb`、`make`；macOS 用 `clang`/`clang++`/`make`（+可选 `llvm`） | 2~3 天 | 中 |
| D2 Makefile 生成 | 生成 MinGW Makefile | 生成 GNU Make 兼容 Makefile（去掉 Windows 专有规则/路径转义） | 2~3 天 | 中 |
| D3 `packman.exe` | 硬编码 Windows 程序名 | 平台化（Linux/macOS 通常无对应；菜单项降级/隐藏） | 1 天 | 低 |
| D4 语法检查/美化工具 | 依赖 MinGW gcc、`AStyle` | 按平台探测外部工具路径；`AStyle` 提供各平台二进制 | 1~2 天 | 中 |
| D5 `GetShortName` 等 8.3 名 | Win `GetShortPathName` | 非 Windows 直接返回原名（已有分支，确认即可） | 0.5 天 | 低 |

### E. 构建系统（`.lpi` / 打包）

| 任务 | 现状 | 改造 | 工作量 | 风险 |
|------|------|------|:---:|:---:|
| E1 Widgetset/目标 OS | `.lpi` 仅 `<Win32>` widgetset，无 gtk2/cocoa/qt | 新增构建模式：Linux `LCLWidgetType=gtk2`（或 qt5/qt6）、目标 OS+CPU；macOS `cocoa` | 2~3 天 | 中（可能触发 Windows 单元编译错误后回修） |
| E2 交叉/本机构建 | 仅 Windows 本机构建 | 在 Linux 主机构建 `lazbuild DevCpp.lpi`；建议 CI（GitHub Actions 多平台矩阵） | 2~3 天 | 中 |
| E3 分发打包 | 仅 Windows exe | Linux：`.deb`/`.rpm`/AppImage；macOS：`.app` bundle + **codesign + notarization** | 3~5 天 | 中（macOS 签名/公证流程） |

### F. 字符串与编码（系统性，贯穿全项目）

| 任务 | 现状 | 改造 | 工作量 | 风险 |
|------|------|------|:---:|:---:|
| F1 字符串类型策略 | `{$MODE Delphi}` ⇒ `String=AnsiString`；`DelphiUnicode` 与 LCL 不兼容已回退 | 保持 AnsiString，但与 OS/文件/进程交互的**边界**统一走 UTF-8（`UTF8String`）或无损失转换；**禁止**再用 `UTF8ToWinCP` 之类 Windows 代码页强转于非 Windows 路径 | 全局，5~10 天 | **高** |
| F2 文件读写编码 | `SetTextCodePage(F, GetACP)`（写 Makefile）等 | 非 Windows 下用 UTF-8（无 BOM） | 1~2 天 | 中 |
| F3 外部进程 I/O | 依赖 A1 管道解码 | `TProcess` + 明确 stdout 编码（GCC/GDB 默认 UTF-8） | 1~2 天 | 中 |

### G. 平台专属（macOS 重点）

| 任务 | 改造 | 工作量 | 风险 |
|------|------|:---:|:---:|
| G1 应用程序菜单栏 | macOS 全局菜单栏 + `About/Preferences/Quit` 归位（LCL Cocoa 多数自动处理） | 1~2 天 | 低 |
| G2 控制台判定 `Utils.ProgramHasConsole` | **DARWIN 分支已存在**（`.app` + `otool`） | 复核 | 低 |
| G3 HiDPI/暗色模式/字体 | 各 widgetset 差异调优 | 2~3 天 | 中 |
| G4 快捷键/路径显示 | `pd`、快捷键文案（`Cmd` vs `Ctrl`） | 1~2 天 | 低 |

---

## 四、三平台差异矩阵（功能视角）

| 功能 | Windows（现状） | Linux（缺口） | macOS（缺口） |
|------|----------------|--------------|--------------|
| 编辑器/解析/补全 | ✅ | ✅ 直接可用 | ✅ 直接可用 |
| 编译执行 | ✅ `CreateProcessW` | 🔴 改 `TProcess`（A1/A2/A3） | 🔴 同 Linux |
| PATH 注入 | ✅ 注册表 | 🟡 提示/可选增强 | 🟡 同 Linux |
| 运行用户程序 | ✅ ConsolePauser | 🔴 平台化（A4） | 🔴 同 Linux（+`.app` 语义） |
| 调试 | ✅ GDB | 🟡 改 `TProcess`+系统 GDB（B1/B2） | 🔴 **须 lldb**（B3） |
| 文件关联 | ✅ 注册表 | ✅ `.desktop`（已有） | 🔴 新增 UTI（C1） |
| 单实例 | ✅ | ✅ 套接字（已有，待验证） | 🟡 待验证 |
| 文档/配置目录 | ✅ APPDATA/CSIDL | 🟡 确认 XDG | 🟡 确认 |
| 文件监控 | ✅ `FindFirstChangeNotification` | ✅ 轮询兜底（已有） | 🟡 轮询（macOS 有 FSEvents，可选优化） |
| 打包分发 | ✅ exe | 🔴 deb/rpm/AppImage | 🔴 **app+签名+公证** |

---

## 五、分阶段路线图（含工作量与风险）

### Phase 0 — 构建基础设施（前置）｜约 3~5 天｜风险 中
- 在 `.lpi` 增加 Linux（gtk2）与 macOS（cocoa）构建模式与目标 OS/CPU（E1）。
- 在 Linux 主机跑通 `lazbuild`，暴露所有非 Windows 编译错误清单（作为 Phase 1 输入）。
- 建立三平台 CI 骨架（E2）。
- **出口标准**：Linux 下能"编译到底"（哪怕运行前崩溃），得到确定性的错误清单。

### Phase 1 — Linux 编译通过 + 进程执行打通｜约 2~3 周｜风险 中高
- A1 `RunAndGetOutput→TProcess`、A2 `devExec→TProcess`、A3 `LaunchThread`、A5 `SetPath`、A6 `GetTickCount`。
- B1/B2 `Debugger` 改 `TProcess` + 系统 GDB + UTF-8 路径。
- A4 `ConsolePauser` 平台化；D1/D2 工具链默认值与 GNU Makefile。
- F2/F3 编码边界（与 A1 联动）。
- **出口标准**：Linux 下可新建/打开工程、编译、运行、基本调试。

### Phase 2 — Linux 功能对齐｜约 2~3 周｜风险 中
- C1~C5 配置/外壳/单实例收尾；D3~D5 外部工具与路径。
- 文件关联、文档目录、PATH 行为对齐（或在 UI 明确降级）。
- 稳定性与 UI 差异（G3/G4）。
- **出口标准**：Linux 版可日常使用；已知差异有文档记录。

### Phase 3 — macOS 支持｜约 4~6 周｜风险 高
- E1 cocoa 构建；B3 **lldb 调试后端**（最大工作量与风险）；C1 UTI 文件关联；G1~G4。
- **出口标准**：macOS 下可编译/运行；调试功能以 lldb 或"暂不支持"降级上线。

### Phase 4 — 打磨与分发｜约 2~3 周｜风险 中
- 三平台打包（E3）、签名/公证、CI 全绿、单元测试覆盖核心路径、迁移/使用文档。

**累计（1 人）**：Linux 可用约 **4~6 周**；三平台完整约 **11~16 周**。
（并行投入 2 人且 macOS/调试可拆分时可显著压缩。）

---

## 六、总风险登记

| 风险 | 等级 | 说明与缓解 |
|------|:---:|------|
| 字符串/编码（AnsiString vs UTF-8） | **高** | 全项目深植；`DelphiUnicode` 已证明不可行（LCL 不兼容）。缓解：保持 AnsiString，仅在 OS/文件/进程边界统一 UTF-8，禁止非 Win 路径上的代码页强转（F1） |
| macOS 调试器（须 lldb） | **高** | macOS 无可用 GDB；lldb 与 GDB/MI 模型差异大。缓解：先以"不调试"降级上线，lldb 后端独立迭代（B3） |
| 跨平台进程执行语义 | 中 | 管道分帧、超时、终止、子进程树 kill 在 3 平台行为不同。缓解：统一封装到一层 `TProcess` 包装（A1/A2） |
| 工具链差异（编译器/参数/Makefile） | 中 | MinGW vs GCC/clang、Makefile 方言。缓解：平台预设 + 生成器分支（D1/D2） |
| Widgetset UI 差异（字体/DPI/菜单） | 中 | gtk2/cocoa 与 win32 渲染差异。缓解：Phase 2/3 集中调优（G3） |
| 第三方二进制（AStyle 等） | 低 | 提供各平台二进制或允许缺失 |
| `.lpi` 平台配置遗漏 | 低 | Phase 0 用真实构建暴露 |

---

## 七、建议

1. **先做 Phase 0**：在不改业务代码的前提下，把 Linux/macOS 构建模式加进 `.lpi` 并跑一次编译，用真实错误清单驱动 Phase 1，避免纸上估工。
2. **统一进程执行抽象**：A1/A2 合并为"一层 `TProcess` 包装"，供编译、运行、调试、外部工具共用——这是投入产出比最高的一步。
3. **先冻结编码策略（F1）**：这是唯一会"横切全项目"的风险，必须在动手移植前定案（推荐：内部 `AnsiString` + 边界 `UTF8String`）。
4. **macOS 分阶段**：先上"编译/运行可用、调试暂缺"，把 lldb 后端作为独立里程碑，避免拖累 Linux 交付。
5. **保留既有 `{$IFDEF MSWINDOWS}` 框架**：延续 `FileAssocs.pas` / `devFileMonitor.pas` 的既有范式，新增 `{$IFDEF DARWIN}`，为三平台一次性隔离。

---

## 附录：本轮校核的关键证据（文件:行）

- 进程执行：`devExec.pas:93`（`CreateProcessW`）、`Utils.pas:770/870`（`RunAndGetOutput`）、`Utils.pas:984/990/1012/1015/1021`（`SetPath`）、`Compiler.pas:1002/1008`（`LaunchThread→TDevRun`）、`Compiler.pas:828/869`（`ConsolePauser.exe`）
- 调试器：`Debugger.pas:170`（`CreateProcessW` 启 GDB）、`:208`（`TerminateProcess`）、`:161`（`--annotate=2`）、`:284`（`UTF8ToWinCP`）
- 配置/外壳：`devcfg.pas:871`（`SHFileOperation`）、`:2322`（注册表 PATH）、`:2701/2704`（`SHGetSpecialFolderPath`）、`main.pas:4795/4798`（`TRegistry`）、`FileAssocs.pas:150/183`(Win)+`66/80/394`(Linux)、`main.pas:9188/9294`（`ShellExecute`/`explorer.exe`）
- 已跨平台：`Instances.pas`（空壳）、`ImageTheme.pas`（`TBitmap`）、`devFileMonitor.pas:101/160/199`、`DevCpp.lpr:31/135`、`Version.pas:29/31`、`Utils.pas:712/724/739`（`ExecuteFile`）、`Utils.pas:488`（`ProgramHasConsole` DARWIN）
- 量化：`uses Windows` 109；`ShellExecute` 26；`HKEY` 13；`GetTickCount` 8；`TerminateProcess` 5；功能级平台分支仅 6 个文件
