# 查找后滚动到匹配文本（FindFrm.pas）

## 日期
2026-07-13

## 需求
在查找对话框中执行查找时，如果所找到的文本不在编辑器当前显示区域，则需要滚动显示区域以显示所找到的文本。

## 思路（用户提供的参考资料方案）
1. 在查找逻辑中得到匹配位置的行索引（PosY）和列偏移（PosX）（均 0-based）。
2. 通过 Carets[0] 设置光标位置。
3. 调用 DoGotoPos 或 DoShowCaret 让控件滚动到光标所在处。

## 实现
ATSynEdit 的 `TATEditorFinder.DoAction_FindOrReplace` 找到匹配后，本身就把光标（Carets[0]）设在匹配起点并设置选区。
因此只需在 `Found` 后补一步"滚动到光标"，即满足条件。在 `FindFrm.pas` 的 `Execute` 函数中：

- `faFind` 分支：找到后 `editor.DoShowCaret;`
- `faReplace` 分支：替换后找到下一处 / 直接找到时，成功导航后 `editor.DoShowCaret;`

`DoShowCaret` 仅在光标（匹配处）位于当前可视区之外时才滚动，已在可视区则无操作，正好符合需求。

## 改动文件
- FindFrm.pas：Execute 的 faFind、faReplace 两分支各加 `editor.DoShowCaret;`
- 未改动 faFindFiles / faReplaceFiles（在多个文件中搜索/替换，不应逐个文件滚动跳动）。

## 验证
- 本机未找到 ATSynEdit 包源码（不在 C:\lazarus 与项目目录内），无法从源码核对方法签名；
  按用户参考资料确认 DoShowCaret / DoGotoPos 为该版本可用方法，采用 DoShowCaret。
- main.pas 已用 `e.Text.DoCommand(cCommand_ScrollLineUp, ...)` 证明 e.Text 即 ATSynEdit 控件，方法调用形式一致。
- 建议编译后在含长文件的编辑器内查找一个远在屏幕外的文本，确认视图自动滚动到匹配处。
