# TdevFormatter.FormatMemory 分析（2026-09-13）

文件：DevCpp-Lazarus\devcfg.pas:3309-3464（类 TdevFormatter 定义于 :254）

## 职责
对当前编辑器文件用 AStyle 做"内存式"重排（实际走磁盘临时文件），再把结果贴回编辑器，
用 选全→删→插 + BeginUndoGroup/EndUndoGroup 让整次重排可被用户一步 Undo。

## 流程
1. 编辑器文本存到 AStyle 目录临时文件（文件名仅 ExtractFileName，含 UnicodeString→AnsiString 转换）。
2. FormatFile 拼 `astyle <opts> "<file>"` 重写该文件。
3. LoadFromFile 进 DummyEditor(TATSynEdit)，跑手写词法状态机（SOURCE/LINE/BLOCK/CSTRING），
   在顶层 '{' 前补空行（fAdjustLines 开关）。
4. 选全删选→TextInsertAtCarets(DummyEditor.Text) 贴回；Modified/Invalidate。返回 ''。

## 关键问题
A. 【真 bug】行注释 `//` 未被识别：进入 LINE 状态条件误写为 ch1=#42 ch2=#42（"**"），
   应为 #47 #47（"//"）。后果：LINE 状态形同虚设；内联 // 注释里的 {} " 被当源码，
   layer 计数与字符串状态错乱 → 含引号/花括号的 // 注释附近补空行启发式出错。
   `int **pp;` 的 ** 也会触发该分支 break 跳过本行剩余扫描。不崩溃但边缘情况不正确。
B. 不检查 FormatFile 返回值；AStyle 失败会静默用旧/空内容覆盖编辑器。
C. 临时文件名仅基名 → 不同目录同名文件互相覆盖。
D. fAdjustspaces 整段注释掉（旧 AStyle 无 --pad-include，现已内置），遗留死代码。
E. 整段自写词法器可废弃：新版 AStyle --break-blocks 已实现"函数间空行"，~120 行脆弱代码可替代。
F. ch1,ch2: char(AnsiChar) 从 Lines[i][j](WideChar) 赋值，WideChar→AnsiChar 收窄（4104/4056 同类）。
G. cCommand_SelectAll 第二参用 TATCommandInvoke(0) 而非具名枚举。

## 与迁移关系
- AnsiString(Editor.FileName) 是此前 UnicodeString 清理为消 4104 加的包裹，正确。
- 本函数不在保留的 46 处 4056 清单（devcfg.pas 的 4056 在 2331，别处）。

## 建议
- 修 A（#42→#47）或按 E 用 AStyle --break-blocks 替代整段自定义逻辑（推荐 E）。
- 加健壮性：检查 FormatFile 返回、临时文件名加唯一性。
- 当前普通代码基本可用，仅 // 注释含 {} / " 的边界情况出错。

## 待用户决策
是否修 A（真 bug）/ 按 E 重构 / 保持原样。

## 修复记录（2026-09-13 19:31）
最小修复已应用（devcfg.pas:3370）：
- 触发条件 #42/#42（"**"）改为 #47/#47（"//"），使 // 行注释被正确识别。
- 删除被立即覆盖的死代码 state := LINE;，分支现行为 ch1 := #0; state := SOURCE; break;（检测到 // 后跳过本行剩余字符，下一行恢复 SOURCE）。
- 副作用：原 LINE + #13 -> SOURCE 分支现完全死代码（不再有代码置 state:=LINE），保留未动（最小改动）。
- 验证：全量 -B 构建 55317 行，0 真实 error，未引入新 4055/4056，exe 已重建。

## 更正（2026-09-13 19:36）—— 方案 E 作废
用户核对 AStyle 官方文档（astyle.sourceforge.net/astyle.html）后指出：--break-blocks 仅对
if/for/while 等控制流块、label、class 周围加空行，官方说明明确"不包括函数块"。
AStyle 全选项无任何"函数前加空行"开关。故：
- 方案 E（用 --break-blocks 替代整段自写词法器）不成立，作废。
- FormatMemory 的自写词法器是补 AStyle 缺失能力的正经功能代码，必须保留。
- 唯一合适改动仍是方案 A（最小修复 // 识别 bug），已完成并验证。
- 佐证：代码内原注释"AStyle 3.5.2 has had option --break-blocks, but not functional"已表明原作者早验证过。
