# DevCpp-Lazarus：清理 5027「Local variable 赋值但未使用」Note（共 5 处）

时间：2026-09-11 15:50-15:56
环境：Lazarus 4.6 / FPC 3.2.2，lazbuild.exe DevCpp.lpi -B
输出：D:\cc\devcpp\release发行\DevCpp.exe（9,235,968 bytes）

## 起因
用户报 ToolFrm.pas(326,3) Note: Local variable "s" is assigned but never used。
排查后同类（Note 5027）共 5 处，一并清理。

## 逐处处理（全部行为等价，保留有副作用的调用）
1. ToolFrm.pas TToolController.BuildMenu：s: String（326）+ s := StringReplace(...Icon...)
   （349）删除。该值唯一消费者是下一行已注释的 //Item.Bitmap.LoadFromFile (s);，图标现由
   Item.ImageIndex 处理 → 纯死代码。
2. EditorOptFrm.pas TEditorOptForm.EditorOptDrawLine：局部 FG: TColor（1821）及其 6 处赋值
   （clNone/fSel/fCur/fBP/fABP/fErr 的 .Y）删除；仅 BG 参与绘制（if BG<>clNone 填背景），
   FG 从未被读取 → 等价。
3. main.pas TMainForm.ToolbarDockContextPopup：ar pt: TPoint（5623-5624）与
   pt := ToolbarDock.ClientToScreen(MousePos);（5626）删除（后续 TrackPopupMenu 全为注释）→
   函数本就是空实现，等价。
4. main.pas TMainForm.UpdateBrowserView：ChildNode 从声明 RootNode, ChildNode: TTreeNode;
   中移除；**保留** BrowserView.Items.AddChildObject(RootNode, ChildMember.Name, ChildMember);
   这一有副作用的调用（去掉左侧赋值）→ 树填充行为不变。
5. Compiler.pas TCompiler.GetCommandLine（或同类）：OptStrip 从
   OptDebug, OptOptimize, OptStrip: char; 移除，删除 OptStrip := fProject.GetCompilerOption('-s');。
   已确认 TProject.GetCompilerOption 是纯 getter（仅读 fOptions，无副作用）→ 等价。

## 构建结果
- 55289 lines compiled，0 error（仅 benign File "devcpp.ico" not found）。
- Note 5027：**0**（原 5 处全清）。
- 46 warning(s) 不变；note 由 33 → 29；hint 753（编辑区域经全量 grep 确认未新增任何 hint，
  差值属无关/计数层面）。

## 结论
本次 5 处删除均为行为等价（只删“只写不读”的局部变量；对有副作用的 AddChildObject 保留调用）。
如需恢复 SpecialLine 的前景色（FG）或类浏览器节点图标，可从备份 zip 或原 Dev-C++ 源重新引入。