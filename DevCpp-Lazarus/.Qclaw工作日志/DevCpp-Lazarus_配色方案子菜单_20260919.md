# View → Editor Color Scheme 子菜单（2026-09-19）

## 目标
在 `main.lfm` 的 `ColorSchemeItem`（View 菜单下）下动态生成 13 个内置配色方案菜单项 +
一个禁用的 "Custom" 项；点击前 13 项即把对应内置配色写入 `devEditor.Syntax` 并应用到所有已打开编辑器。

## 关键事实与修复
- **菜单项名字 = 配色方案名**（不是颜色元素名），取自 `Lang[ID_COLOR_SYNTAX]` … `Lang[ID_COLOR_SYNTAX12]`
  （ID 26080–26092，均在 `LangIDs.inc` 定义）。`Lang` 是 `TdevMultiLangSupport` 单例的默认整数索引属性，
  `GetString` 先取选中语言、再回退 English.lng，不会显示 "translation missing"。
- `devEditor.Syntax` 中特殊颜色的真实 key 来自 `Version.pas`：`cBP='Breakpoint'`、`cErr='ErrorLine'`、
  `cABP='ActiveBpt'`、`cBM='Bookmarks'`、`cSel='SelectText'`、`cCur='CurrentLine'`、
  `cGut='GutterNum'`、`cEdt='EditState'`、`cFld='FoldLine1'`（顺序对应配色数据 [14..22]）。
  **之前误用了对话框里的显示名（'Breakpoints'/'SelectedText'/…），已纠正。**

## 改动（main.pas）
- `ColorElemNames[0..13]`：14 个常规元素名（Space/Comment/…/Incorrect），与 `EditorOptFrm.fColorElems[0..13]` 一致。
- `SpecialElemNames[0..8]`：上述 9 个真实 key。
- `ApplyBuiltInColorScheme(SchemeIndex)`：把 23 个颜色串写入 `devEditor.Syntax`，置 `SyntaxIndex`，
  再建一个临时 `TEditorOptForm` 调其 `ApplySyntaxToAllEditors`（复用已验证逻辑，写入时 `devEditor.Syntax`
  已含特殊色，`fGutColor` 等会被 `FormCreate` 正确初始化），然后 `SaveOptions` + `UpdateColorSchemeChecks`。
  - 注：`devEditor.Syntax` 写入后，特殊色（书签/错误行/当前行等）由 `TEditor.EditorCalcBookmarkColor`
    动态读取，无需额外应用到编辑器。
- `BuildColorSchemeMenu`：`ColorSchemeItem.Clear` 后创建 13 项（Caption=`Lang[ID_COLOR_SYNTAXi]`、Tag=i、
  OnClick=`ColorSchemeItemClick`）+ 1 个禁用 "Custom"。
- `ColorSchemeItemClick`/`UpdateColorSchemeChecks`：Tag<0 跳过；按 `devEditor.SyntaxIndex` 同步勾选。
- `FormCreate` 末尾（在 `Lang.Open` 加载完语言、`LoadText` 之后）调用 `BuildColorSchemeMenu`。

## 验证
- `lazbuild _b6.lpi -B`（输出路径已改纯 ASCII 避免中文编码链接失败）→ exit 0，56423 行，0 Error。
- 待用户实测：① 菜单项名称是否为各配色方案名（中文/英文）；② 点选是否即时改变所有编辑器配色；
  ③ 勾选状态是否随 `devEditor.SyntaxIndex` 反映。
