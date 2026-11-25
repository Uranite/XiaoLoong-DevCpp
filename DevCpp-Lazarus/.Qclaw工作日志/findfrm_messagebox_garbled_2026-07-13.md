# FindFrm.pas MessageBox 中文乱码修复（含全项目同类修复）

## 日期
2026-07-13

## 根因（两层）
1. 裸 `MessageBox`（`uses` 第一单元为 `Windows` → `MessageBoxA` / ANSI 版）只认 CP_ACP 字节，
   而 `Lang[...]` 是 **UTF-8** `String`，`PChar(Lang[...])` 得到 UTF-8 字节 → 被当 CP936 解释 → 乱码。
2. 改用 `MessageBoxW` + `PWideChar(Lang[...])` 仍乱码（形式不同）：
   `MultiLangSupport.Open` 中 `fStrings.Text := String(AnsiBytesToUnicode(...))` 赋给 `TStringList` 后，
   字符串**丢失 CP_UTF8 代码页标签**（退化为 CP_ACP）。`PWideChar` 依赖代码页标签做 UTF-8→UTF-16，
   因标签错误把 UTF-8 字节当 CP936 字符转 → 另一种乱码。

## 统一修复方案
改用 `Application.MessageBox(PChar(Lang[...]), PChar(Lang[...]), Flags)`（LCL 标准函数，显式 UTF8ToUTF16）。
`Application` 来自 `Forms`（uses 已有）；`MB_*` 来自 `Windows`（uses 已有），无需新增 unit。

## 已修复文件清单
- FindFrm.pas: 221 / 296 / 300 / 404（查找对话框）
- Compiler.pas: 939 / 983（clean / rebuild，用唯一注释区分）
- EnviroFrm.pas: 173 / 205（多行标签错误 / UAC 关联失败）
- Project.pas: 1033（文件未找到）
- Templates.pas: 111 / 266（模板文件未找到 / 无模板）

## 验证
全项目扫描：`CodeInsList.pas` 中仅剩示例 C++ 代码片段字符串（`MessageBox(NULL, ...)`），非 API 调用。
其余真实 `MessageBox` 调用已全部改为 `Application.MessageBox`。
建议编译后在中文语言包下逐一触发上述提示确认中文正常显示。
