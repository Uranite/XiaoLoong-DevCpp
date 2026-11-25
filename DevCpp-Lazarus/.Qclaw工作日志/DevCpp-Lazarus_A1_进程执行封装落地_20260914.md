# DevCpp-Lazarus — A1 进程执行封装落地（RunAndGetOutput / AnsiBytesToUnicode）

日期：2026-09-14
状态：**完成（0 Error）**
产物：`c:\Users\Administrator\WorkBuddy\2026-DevCpp-Lazarus\DevCpp-Lazarus\Utils.pas`（基于 14:14 备份）

## 目标
跨平台评估任务卡（Phase0_A1A2_进程执行封装）中的 **A1**：把 `Utils.RunAndGetOutput` 从 Windows `CreateProcessW` 体系改写为跨平台 `TProcess`，并把 `AnsiBytesToUnicode` 改为跨平台（Windows 用 `MultiByteToWideChar`，其它平台用 `UTF8ToUnicodeString`）。调用方零改动。

## 关键结论
- 全量构建 `lazbuild DevCpp.lpi -B`：**0 Error**，55204 lines，4865152 bytes code。
- A1 仅新增 2 条 Warning(5043) `Symbol "CommandLine"/"SetCommandLine" is deprecated`（来自 `P.CommandLine := Cmd`，是 `CreateProcessW(lpCommandLine)` 的等价写法），属良性弃用提示，按既定"保留良性提示"口径不抑制。
- `CreateProcessW` / `TStartupInfoW` / `TProcessInformation` 已从代码中彻底移除（跨平台 `TProcess` 就位）。
- 9/13 已知保留的 43 条 warning + 28 note + 744 hint 口径不变。

## 落地改动（最终版，落在 14:14 备份基底上）
1. **uses**：`{$IFDEF MSWINDOWS} Registry, {$ELSE} Process, {$ENDIF}` → `Process,` 无条件 + `{$IFDEF MSWINDOWS} Registry, {$ENDIF}`（Windows 下也必须能拿到 `TProcess`）。
2. **AnsiBytesToUnicode**（impl，~749 行）：整体包 `{$IFDEF MSWINDOWS}`（`MultiByteToWideChar`，UTF-8 优先、CP_ACP 回退）/`{$ELSE}`（`SetString`+`UTF8ToUnicodeString`）分支。
3. **RunAndGetOutput**（impl，~785 行）：整函数改写为 `TProcess`——
   - `P.Options := [poUsePipes, poStderrToOutPut]`（stderr 合并进 stdout，等价于原 `DuplicateHandle` 合并）
   - `P.CommandLine := Cmd;` + `P.CurrentDirectory := WorkDir;`
   - **异步** `P.Active := True`（绝不用 `P.Execute` 同步 + `poUsePipes`，否则管道满会死锁）
   - 循环 `P.Output.Read(Buf, SizeOf(Buf))` 边读边排空；`CheckAbortFunc` 置位时 `P.Terminate(1)` 后 `Break`
   - 行缓冲按 `#10` 切整行 → `AnsiBytesToUnicode` 解码 → 逐行回调（等价约束全部保留：逐行回调 / 中止回调 / stderr 合并 / 返回值语义）
   - `ShowReturnValue` 时 `Result := Result + ' ' + IntToStr(P.ExitStatus)`
4. 局部变量 `p: Integer`（行位置索引）改名为 `LinePos`，避免与 `P: TProcess` 在大小写不敏感 Pascal 下冲突。

## 过程中踩的坑（重要教训）
1. **必须用正确的 pre-corruption 备份**：项目 `backup\Utils.pas` 是 9/11 **9:05** 旧备份，其 `ProgramHasConsole` 接口声明缺 `UsePrecise` 默认参数（实现处有），本身编不过。我从它还原 + 手工补接口才编过，但少包含了 9/05→14:14 之间的 ~113 行差异代码（构建 55207 行 vs 正确 55320 行）。
   - 用户提供了 `Utils-2026-0911-1414.pas`（真正的 pre-corruption 状态，55320 行、0 Error 已验证）。**最终以 14:14 为基底重做 A1**。
2. **索引漂移 bug**：函数替换若用"uses 补丁之前的"行号，而 uses 补丁（删 1 行）会把数组整体下移 1 行，导致替换范围错位、函数被**重复插入**（出现 2 个 `function AnsiBytesToUnicode`）。修正：先替换函数（再重算 RunAndGetOutput 索引），**最后**才做 uses 补丁（仅顶部 1 行位移，对已落地函数无害）。
3. **正则未转义**：`Select-String -Pattern 'function RunAndGetOutput('` 的 `(` 未转义 → 非法正则 → 索引回 0 → 把文件前 200 行（interface/uses/type）整体删掉。修正：模式写为 `'function RunAndGetOutput\('`。
4. **稳健函数定位**：用"注释感知"的 begin/try/case vs end 深度平衡查找器定位函数结尾（跳过 `//` 与 `{ }` 块注释，保留 `{$...}` 指令），替代之前误判的 `{$ENDIF}` 规则。写盘前加校验门：声明计数必须各=2、不得残留 Windows 进程 API。

## 验证
- `Select-String` 校验：无 `CreateProcessW(`/`TStartupInfoW`/`TProcessInformation`；`RunAndGetOutput`/`AnsiBytesToUnicode` 各 2 处声明（interface+impl）。
- 全量构建 0 Error（55204 lines）。`Utils.pas` 内 A1 相关提示仅 5043×2。

## 待办 / 备注
- A2（devExec.pas 整文件改 TProcess）未做（用户仅要求落地 A1）。
- `Utils-2026-0911-1414.pas` 是用户放入项目的 14:14 备份，未删除（作保险）。当前 `Utils.pas` 已是其 + A1 的正确状态。
- 任务卡 `DevCpp-Lazarus_任务卡_Phase0_A1A2_进程执行封装_20260914.md` 中的简化骨架需按本实现修正：① `Process` 必须无条件 uses；② `RunAndGetOutput` 必须用 `P.Active := True` 异步模式（非 `P.Execute`+`poUsePipes`）。
