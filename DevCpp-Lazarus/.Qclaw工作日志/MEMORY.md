# 记忆

## 用户身份与偏好

- 使用 Lazarus/FPC 开发，代码风格为 {$MODE Delphi}
- 要求先逐项点清待核实事项再产出文档，偏好结构化、分模块分阶段并含工作量与风险的评估结果
- 项目：XiaoLoong Dev-C++ / XL7（c:\Users\Administrator\WorkBuddy\2026-DevCpp-Lazarus\DevCpp-Lazarus），
  非 git 仓库；构建一律先 cd 项目目录再 `C:\lazarus\lazbuild.exe`（从别的目录调会误报 devcpp.ico 缺失）

## 经验与决策

- LCL 不支持 DelphiUnicode 模式，不要再尝试改 {$MODE DelphiUnicode}
- 对无害编译告警（4055/4056/5024）保持原样，不做过度修改/压制
- TProcess 三条管线口径：GDB=`[poUsePipes,poStderrToOutPut]`+swoHIDE（绝不加 poNoConsole，
  CREATE_NO_WINDOW 会破坏交互式 stdio 管道）；用户程序=不建管道+swoHIDE/swoShow；
  编译器 RunAndGetOutput=`[poUsePipes,poStderrToOutPut,poNoConsole]`
- GDB `--annotate=2` 每条响应以 `\032\032prompt`（#26#26+精确词 prompt）行结束，须以此分块

## 工具教训（重要）

- edit 工具对大文件可能静默失败/误改相邻行，改后必须用 read 或 PowerShell ReadAllLines 复核磁盘
- Select-String 正则含 `(`、`{` 须 -SimpleMatch 或转义；勿同时管道传对象又带 -Path
- PowerShell 调 lazbuild 输出路径含中文（如 release发行）会乱码致链接 Error 9003；
  验证编译用临时 .lpi 正则替换全部输出路径（含各 BuildMode 的 Target.Filename）到干净路径
- FPC 不允许 {$WARNINGS OFF} 写在 var 声明段内（Fatal 2003）
- 排障优先"原始字节转储到文件"，比猜测协议高效
