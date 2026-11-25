# ObjFPC 迁移完成（2026-08-25 08:13）

## 目标达成
DevCpp-Lazarus 项目（Dev-C++ 7.0 测试版，Delphi→Lazarus 移植）从 Delphi 模式切换 ObjFPC 模式的编译错误**全部修复，编译链接成功**。
- 编译命令：`c:\lazarus\lazbuild.exe -B DevCpp.lpi --build-mode=Release`
- 输出：`D:\cc\devcpp\release发布\DevCpp.exe`（9,155,584 字节，2026-08-25 08:13:41）
- EXITCODE 0；唯一残留错误为已知非阻断 `Error: File "devcpp.ico" not found`（DevCpp.lpi 路径大小写，文件存在）

## 本轮（08:11-08:13）修复清单

### ToolFrm.pas（编译通过）
- `Count` 局部变量 ×7 → `iCount`（与 `TToolList.Count` 属性冲突）
- PToolItem 指针解引用 ×30：`Item.`/`NewItem.`/`fToolList.Items[I].`/`fController.ToolList[idx].` → `^.`
- 关键教训：`_fix_toolfrm.ps1` 初版函数内 `$content`/`$total` 是 PowerShell 局部副本，**文件未写入**（"OK" 输出是假象）；改用 `$script:` 作用域后生效

### ProjectOptFrm.pas（编译通过）
- 6 处事件赋值缺 `@`：chkCompile/OnChange 系（`txtOverrideBuildCmd.OnChange` 出现 2 次）

### Project.pas（编译通过，40 行改动）
- 3 个方法内局部 `NewUnit` → `NewUnitVar`（与类方法 `TProject.NewUnit` 冲突）
- CreateFolderNodes 内 `node` → `treeNode`（与 TTreeNode.Node 属性冲突，注意 Pascal 大小写不敏感，`Node.GetFirstChild` 中的 Node 也要改）
- ExportToHTML 内 `fName` → `htmlName`、`UnitName` → `UnitFileName`（类字段/方法冲突）；**范围限定 L1458-1566**，L1599/1600（ShowOptions）的 `fName` 是类字段合法引用，未动

### devcfg.pas（编译通过，长期卡点突破）
- **根因**：L3303 孤立行 `{` 开启 FPC 嵌套注释（Comment level 2→5），直到 EOF 未闭合 → `(3499) Fatal: (2000) Unexpected end of file`
- 修复：删除 L3303 `{` 和 L3393 `}` 两个误留花括号（中间是 `//` 行注释 + 实际代码，非注释块）
- 诊断方法：lazbuild 输出 `Warning: (2005) Comment level N found`（L3308/3352/3354/3357/3432）暴露嵌套注释；状态机扫描 `{`/`}` 差 6 个
- 文件时间戳 8/6 未变但 8/24 能编译——历史差异未深究（可能 9:17 的 ppu 是旧产物）

### Editor.pas（编译通过）
- 事件赋值加 `@` ×20：OnKeyUp/OnClick/OnClickDouble/OnMouseMove/OnMouseUp/OnChangeCaretPos/OnChangeBookmarks/OnContextPopup/OnChange/OnClickGutter/OnCalcBookmarkColor/OnEnter/OnExit/OnKeyPress/OnCommand/OnKeyDown/OnTimer×2/OnKeyPress/OnEvalReady
- `integer(PBreakPoint(...)^.editor) = integer(Self)` ×4 → `PtrInt(...)`
- `fTabSheet.Tag := integer(Self)` → `PtrInt(Self)`
- EditorMouseUp 局部 `FileName` → `hdrFile`（与类属性 `TEditor.FileName` 冲突）

### CodeToolTip.pas（编译通过）
- DummyPaint/Paint 两方法内局部 `Width` → `TipWidth` ×22（与类 `property Width` 冲突）
- 误伤修正 ×6：`FUpButton.TipWidth`/`FDownButton.TipWidth`/`Pen.TipWidth` → 还原 `.Width`（正则 `\bWidth\b` 匹配了成员访问）
- L255 `Width := Screen.Width`（`with FBmp do` 内属性赋值）保留未动

### Utils.pas（编译通过）
- L1384 `BrowseInfo.lpfn := NewSelectDirectoryCallback;` → `:= @NewSelectDirectoryCallback;`（函数指针赋值 ObjFPC 需 @）

## 迁移全程累计（8/24-8/25 多轮）
- lpi：SyntaxMode Delphi→ObjFPC ×3、CustomOptions 去 `-dBorland -dVer150 -dDelphi7`（保留 `-dCompiler6_Up -dPUREPASCAL`）
- 24 文件批量 `var Action: TCloseAction` → `CloseAction`
- 通用规律：事件/方法指针赋值需 `@`；`of object` 回调改普过程+`Data: Pointer`+桥接函数（utils/devrun）；指针字段 `^` 解引用；`integer(Pointer)`→`PtrInt`；局部变量遮蔽类属性/方法 → 改名；published 段 TObject 字段触发 $M+ 错误（删字段解决）；函数作用域 PowerShell 变量需 `$script:`

## 待办（可选）
1. 运行 DevCpp.exe 验证 OwnerDraw 菜单字号跟随 `devData.InterfaceFontSize`（迁移的原始目标）
2. 修 devcpp.ico 路径大小写（DevCpp.lpi），消除每次编译的非阻断错误
3. 遗留功能项：BrowserView 保存后不刷新、`C.lcf` 正则 `#` 截断、`lexers.rc` 指向 C++.orig.lcf、Editor.pas 删除首行崩溃
