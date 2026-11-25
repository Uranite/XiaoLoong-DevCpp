# ordinal<->pointer 转换清理（第一轮：两处）

时间：2026-09-11 16:08-16:16 GMT+8
环境：Lazarus 4.6 / FPC 3.2.2，lazbuild.exe DevCpp.lpi -B
项目：c:\Users\Administrator\WorkBuddy\2026-DevCpp-Lazarus\DevCpp-Lazarus

## 缘起
用户指出 "Conversion between ordinals and pointers is not portable" 是 Delphi 时代 32 位做法的遗留，
转向 64 位需全部清理，先改两处：CppParser.pas:1221 与 main.pas:3144。

## 关键发现（重要）
1. 该类消息有**两个代码、同一文本**：
   - Hint  4055（如 `fSkipList.Add(Pointer(I+1))`、`main.pas 3144`）
   - Warning 4056（如 `fSkipList.IndexOf(Pointer(fIndex))`、`integer(Node.Data)`）
   之前只按 `4055` 过滤，漏掉了 4056。**实测全项目：39 × 4056(Warning) + 11 × 4055(Hint) = 50 处。**
2. LCL 里 `Tag: PtrInt` 只存在于 **TListColumn**（comctrls.pp:1253），
   **TListItem 与 TTreeNode 都没有 Tag**；它们唯一可挂用户数据的是 `Data: Pointer`。
3. LCL 的 `TListItem.OnDeletion` 在**每一次删除都触发**（`TListItems.Clear` 也是循环 Delete，
   customlistview.inc:775 ItemDeleted -> DoDeletion -> FOnDeletion），可安全用于释放挂载数据。

## 修复 1：CppParser.pas — fSkipList（TList 存整数下标）
把 `fSkipList: TList` 改为 `array of Integer`，消除全部指针<->序数转换：
- 41  `fSkipList: array of Integer;`
- 219 `SetLength(fSkipList, 0);`（原 TList.Create）
- 231 删除 `FreeAndNil(fSkipList);`（动态数组自动释放）
- 678（原 4056 Warning）改为显式线性查找：
      iSkip := -1;
      for j := 0 to High(fSkipList) do
        if fSkipList[j] = fIndex then begin iSkip := j; Break; end;
      （var 段 `iSkip, j: integer;`）
- 684 `fSkipList.Delete(iSkip)` 改为尾部移位 + SetLength(-1)
- 1221（原 4055 Hint）改为追加：
      SetLength(fSkipList, Length(fSkipList) + 1);
      fSkipList[High(fSkipList)] := I + 1;
- 1814 `fSkipList.Clear` => `SetLength(fSkipList, 0);`

## 修复 2：main.pas — FindOutput 结果项的加粗长度
原：`NewItem.Data := Pointer(Length(keyword));`（写，4055） / `BoldLen := Integer(Item.Data);`（读，4056）。
`keyword` 即搜索词（见 FindFrm.pas:432/452），BoldLen 用于在消息行里加粗匹配片段。
由于 TListItem 只有 Data:Pointer 一个槽，改为**挂载堆分配的整数（真正的指针，无序数转换）**：
- AddFindOutputItem（3138）：新增 `BoldLenRef: Pointer;`，改为
      GetMem(BoldLenRef, SizeOf(Integer));
      PInteger(BoldLenRef)^ := Length(keyword);
      NewItem.Data := BoldLenRef;
- 绘制（8847 附近）：
      if Assigned(Item.Data) then BoldLen := PInteger(Item.Data)^ else BoldLen := 0;
- FindOutputDeletion（8939）开头释放：
      if Assigned(Item) and Assigned(Item.Data) then begin FreeMem(Item.Data); Item.Data := nil; end;
  （LCL 每次删除/清空都会触发 OnDeletion，无泄漏；已确认无其它代码读取 FindOutput 项 Data）
  注意：绘制用 `PInteger(Item.Data)^`、写用 `NewItem.Data := BoldLenRef` 均为指针<->指针，无 4055/4056。

## 构建结果
- 55318 lines，**0 error**（仅 benign `File "devcpp.ico" not found`）
- Warning 45 -> **43**；Hint 750 -> **746**；Note 29 -> 28
- CppParser.pas 已无 4055/4056；main.pas 3144/8843 已消
- 产物 D:\cc\devcpp\release发行\DevCpp.exe（9,236,480 bytes，16:16 重建）

## 剩余同类（46 处，待用户确认是否继续）
- 4056 Warning（37）：main 15（多为 ProjectView 树节点 Data 存下标）、Project 6、ProjectOptFrm 5、
  ExceptionFrm 4、NewProjectFrm 4、ProcessListFrm 1、EditorList 1、devcfg 1
- 4055 Hint（9）：devFileMonitor 4、ExceptionFrm 2、main 2、Utils 1（多为 WinAPI LPARAM/句柄、栈地址）
- 评估：WinAPI 传指针（LPARAM/handle）在 Pascal 中必须 cast，属 API 约束，只能局部 `{$WARN 4055/4056 OFF}`
  标注或以 PtrInt 包装；TTreeNode.Data 存下标因无 Tag 槽，需要设计层改动。

## 教训
- 统计此类告警必须同时匹配 4055 与 4056。
- LCL：TListColumn 有 Tag，TListItem/TTreeNode 没有；本项目 LCL 版本下勿用 Item.Tag。
- 判断 OnDeletion 语义要看 lcl/include/customlistview.inc + listitems.inc。
- PowerShell 单引号串里写 `Caption := '';`（两个单引号）极易错；改用不含该行的锚点最稳。