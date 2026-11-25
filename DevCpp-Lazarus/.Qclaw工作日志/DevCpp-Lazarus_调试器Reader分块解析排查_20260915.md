# DevCpp-Lazarus 调试器 Reader 分块/解析修复（2026-09-15 12:00–15:15 GMT+8）

## 结论（已由用户实测确认）
用户 15:10 确认：**调试时 DebugOutput 正常显示 GDB 信息，编辑器正常高亮当前执行行。** 修复完成。

## 症状链
1. poUsePipes 修复后 GDB 有输出，但 Reader 几乎不处理。
2. 加日志发现：`GetLastAnnotation(tmp,total,total) in [TErrorBegin,TPrompt]` 只检查缓冲区**最末**注解，
   末尾常是 `post-prompt`/`source` 等，导致长期不 flush，直到进程退出才 drain。
3. 改为"见第一个 `##` 即切"：DebugOutput 有内容但大量 annotation 名（pre-prompt/prompt/...）裸露、信息缺失。

## 关键：GDB `--annotate=2` 真实字节流（用户回传 _debug_reader.log）
`#26`=0x1A（日志记 `<1A>`）。样例：
```
<1A><1A>pre-prompt
(gdb)
<1A><1A>prompt

<1A><1A>post-prompt
Reading symbols from D:/cc/fibonacci.exe...

<1A><1A>breakpoint 1

Thread 1 hit Temporary breakpoint 1,
<1A><1A>frame-begin 0 0x7ff6974d1492
<1A><1A>frame-function-name
main
<1A><1A>frame-source-file
D:\cc\fibonacci.cpp
<1A><1A>frame-source-line
10
<1A><1A>source D:\cc\fibonacci.cpp:10:406:beg:0x7ff6974d1492
<1A><1A>frame-end

<1A><1A>stopped
<1A><1A>pre-prompt
(gdb)
<1A><1A>prompt
```
**核心规律：每条命令响应都以 `\032\032prompt`（精确单词 prompt）行结束。**
（`pre-prompt`/`post-prompt` 不是同词，不能误匹配。）

## 修复内容（DebugReader.pas）
1. **Execute 按响应边界分块**：
   - 累积原始字节到 `tmp`；
   - `FindPromptEnd(tmp)`：找 `#26#26` 后注解名 `SameStr(nm,'prompt')` 命中，返回该行 LF 位置；
   - 循环把每个完整响应 `Copy(tmp,1,r)` 交给 `ProcessDebugOutput`，随后 `tmp := Copy(tmp,r+1,...)`；
   - `fOutput := AnsiString(AnsiBytesToUnicode(PAnsiChar(part),Length(part)))`（AnsiString 天然 #0 结尾，
     满足 `ProcessDebugOutput` 的 `fIndex:=1` + `until TEOF(fOutput[fIndex]=#0)` 契约）；
   - 进程退出后 drain 残余 tail。
2. **恢复被注释的输出清理**：`SyncFinishedParsing` 中 `#26→'>'` + 剥离 `>>prompt/post-prompt/pre-prompt/...`
   的整段（L227-293）当前文件被 `{ }` 注释掉了（13:05 备份为启用状态），已还原。
   这是此前 DebugOutput 显示原始标注名的直接原因。
3. **移除诊断代码**：Execute 内的 logFS/Log/RawView 全量转储与 `_debug_reader.log` 已删除，恢复干净实现。

## 构建
- `_b4.lpi`（正则替换 `D:\cc\devcpp\output` → workspace\_b4，替换 release 中文路径 `...\release[^"]*\DevCpp\.exe` → `_b4\DevCpp.exe`）+ `lazbuild -B`。
- 最终：exit 0，**55233 lines compiled, 4943056 bytes code, exe 80279062 bytes**，0 Error。

## 相关文件
- 修改：`c:\Users\Administrator\WorkBuddy\2026-DevCpp-Lazarus\DevCpp-Lazarus\DebugReader.pas`
  （Execute 分块重写 + 恢复清理块）
- 参照：`...\DevCpp-Lazarus\backup\DebugReader.pas`（2026-09-15 13:05，清理块启用状态）
- 关联：`DevCpp-Lazarus_调试器poUsePipes根因修复_20260915.md`、`DevCpp-Lazarus_poNoConsole移除_调试修复_20260914.md`

## 三条进程管线最终口径（回顾）
- GDB 调试器：`Options=[poUsePipes, poStderrToOutPut]` + `ShowWindow:=swoHIDE`，**不加** poNoConsole
  （CREATE_NO_WINDOW 破坏交互式 stdio 管道）。
- 用户程序（devExec）：无 poUsePipes、无 poNoConsole、swoHIDE/swoShow。
- 编译器（Utils.RunAndGetOutput）：`[poUsePipes, poStderrToOutPut, poNoConsole]`（纯输出捕获，安全免弹窗）。

## 工具教训
- 排障优先做"原始字节转储"（含控制字节十六进制视图）到文件，比猜测协议高效得多。
- FPC/AnsiString 天然在 `[Length+1]` 置 #0，解析循环 `until fOutput[fIndex]=#0` 依赖此性质。
- GDB annotation 以 `\032\032prompt` 结束响应；切勿用 `GetLastAnnotation` 只查末尾，也不能见 ## 就切。
