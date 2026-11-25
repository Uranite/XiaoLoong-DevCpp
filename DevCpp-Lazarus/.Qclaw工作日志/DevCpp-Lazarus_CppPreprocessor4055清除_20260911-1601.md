# CppPreprocessor.pas：消除 4055「ordinal<->pointer 转换不可移植」（4 处）

时间：2026-09-11 15:57-16:01
环境：Lazarus 4.6 / FPC 3.2.2，lazbuild.exe DevCpp.lpi -B

## 用户报告（1 Warning + 3 Hint，均为 4055）
- CppPreprocessor.pas(289,22) **Warning** 4055  BranchResults.Add(Pointer(LongInt(value)));
- CppPreprocessor.pas(282,15) Hint 4055  Result := PtrUInt(fBranchResults[...]) <> 0
- CppPreprocessor.pas(914,10) Hint 4055  if PtrUInt(fBranchResults[i]) = 0 then
- CppPreprocessor.pas(924,10) Hint 4055  同上

## 根因
fBranchResults 是 Classes.TList，用「布尔值存成指针」的旧写法：
True/False 经 Pointer(LongInt(value)) 压栈，读取时用 PtrUInt(ptr)<>0 判断。
FPC 对 ordinal<->pointer 转换一律发 4055（32 位 LongInt→指针升级为 Warning，指针大小的
PtrUInt→Hint）。实测：Pointer(PtrInt(x))、PtrUInt(p) 等任何变体都仍报 4055 —— 只能消除转换本身。

## 修复（保持 TList，改用非空哨兵指针，零转换）
1. implementation 段新增单元级哨兵：
   ar cTrueBranchResult: Byte;（取它的地址 @cTrueBranchResult 作为“True”标记）
2. GetCurrentBranch：Result := fBranchResults[fBranchResults.Count - 1] <> nil;
3. SetCurrentBranch：
   `
   if value then fBranchResults.Add(@cTrueBranchResult)
   else fBranchResults.Add(nil);
   `
4. else/elif 两处循环：if fBranchResults[i] = nil then Exit;

语义不变（True=非空指针, False=nil），无 ordinal<->pointer 转换 → 4055 全消。

## 构建结果
- 55298 lines，0 error（仅 benign File "devcpp.ico" not found）
- **CppPreprocessor.pas 编译消息 = 0**
- Warning 46 → 45（消除 4055 Warning）；Hint 753 → 750（消除 3 个 4055 Hint）；Note 29 不变
- 产物 D:\cc\devcpp\release发行\DevCpp.exe（9,235,968 bytes）已重建

## 剩余 4055（11 处，均在其它文件，性质不同，暂未动）
多为 WinAPI 指针<->整数转换（属此前已接受的一类）：
- devFileMonitor.pas 273 / 306 / 307：LPARAM(P)、PChar(Message.LParam)（WinAPI 消息传指针）
- main.pas 9455 / 9470：PChar(Message.LParam)、StrDispose(PChar(Message.LParam))
- Utils.pas 1673：BrowseInfo.lParam := PtrInt(PChar(Directory))
- ExceptionFrm.pas 177 / 179：PtrUInt(@tmpSP)、pointer(tmpSP)（栈地址技巧）
- devFileMonitor.pas 149：QWord(fShouldQuit.Handle)（句柄入 QWord 数组）
另有 2 处「整数塞进 TList/ListItem.Data」：CppParser.pas 1221、main.pas 3144
（与本次同类，但改它们需同步改读取端，风险较高，未动）

## 教训
PowerShell 双引号里 "...$nlvar..." 会被解析成变量名 $nlvar（把 ar 关键字吞掉）→ 必须写
` ${nl}var ` 或用字符串拼接。另：把带 Write-Output 的函数返回值赋值给变量时，输出会被一起捕获，
污染结果 → 批处理脚本中函数只应 eturn，日志应在外部打印。