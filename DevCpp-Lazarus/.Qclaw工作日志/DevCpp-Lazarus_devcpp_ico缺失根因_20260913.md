# DevCpp-Lazarus：devcpp.ico "not found" 误报根因

日期：2026-09-13

## 现象
- 通过 PowerShell 调 `lazbuild.exe DevCpp.lpi -B` 构建时，日志末尾出现
  `Error: File "devcpp.ico" not found.`（良性，exe 仍生成）。
- 用户在 Lazarus IDE 中构建（default/debug/release 三种配置）**均无此错误**。

## 根因
- `.lpi` 第 20 行：`<Resource_0 FileName="devcpp.ico" Type="ICON" ResourceName="DEVCPP"/>`
  这是应用图标资源，编译进 `DevCpp.res`，由 `DevCpp.lpr` 的 `{$R *.res}` 链接。
- `devcpp.ico`（34494 字节）位于项目根目录，文件本身存在、无损坏。
- Lazarus 资源编译器解析该外部 `FileName` 时，相对路径基于**进程工作目录（cwd）**：
  - IDE 构建：cwd = 项目目录 → 能找到 `devcpp.ico` → 无错误。
  - 我的 `lazbuild` 调用：PowerShell 默认 cwd = agent 工作区
    `C:\Users\Administrator\.qclaw\workspace`（非项目目录）→ 相对名解析失败 → 报 not found。
- 结论：**这是构建调用方式问题，不是项目缺陷。**

## 验证
以项目目录为 cwd 重新构建：
```
Set-Location "c:\Users\Administrator\WorkBuddy\2026-DevCpp-Lazarus\DevCpp-Lazarus"
& "C:\lazarus\lazbuild.exe" "DevCpp.lpi" -B 2>&1 | Out-File ...\build_cwd.txt
```
结果：`Error:` 行 0 条；55320 lines compiled，4859360 bytes code（与干净基线一致）。错误消失。

## 结论 / 后续做法
- 项目文件无需改动（`.lpi` 保持原始裸名 `devcpp.ico` 即可）。
- 后续用 `lazbuild` 验证构建前，**必须先 `Set-Location` 到项目目录**，与 IDE 行为一致。
- 之前"改 `.lpi` 为绝对路径"的尝试未真正落盘（读回仍是裸名），无需回退，因为本就不需要改。
- 注意：早期曾在 `D:\cc\devcpp\output\` 复制过一个 `devcpp.ico`（第一次排查时放的），
  该副本现已多余、且可能掩盖 cwd 问题，建议删除（用户尚未确认，暂留）。

## 临时文件
- 诊断日志：`d:\cc\devcpp\build_fix.txt`（旧，含错误）、`d:\cc\devcpp\build_cwd.txt`（新，干净）。
  二者均可删，待用户确认。
