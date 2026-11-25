# Linux 移植 Phase 1 — 核心阻断修复

> English version: [LINUX_PORT_PHASE1.en.md](LINUX_PORT_PHASE1.en.md)

> 状态：✅ 已完成（2026-07-16）→ [Phase 2 文档 →](LINUX_PORT_PHASE2.md)
> 目标：消除编译阶段在 Linux/FPC 上的阻塞性问题

---

## 背景

项目 `C:\Users\Administrator\WorkBuddy\2026-DevCpp-Lazarus\DevCpp-Lazarus\` 从 Delphi/SynEdit 迁移至 Lazarus/ATSynEdit（v7.0 测试版），目前仅支持 Windows。本文档记录 Phase 1 的核心阻断修复，将项目改造为可在 Linux/FPC 上通过编译。

---

## 已修复文件清单

### 1. `Instances.pas`（单实例 & 文件关联）
**问题**：Windows 互斥锁 + `RegisterFileAssoc` API，Linux 上无意义  
**修复**：完全重写为跨平台
- Windows：保留 `CreateMutex` + `RegisterFileAssoc`
- Linux：使用 `/tmp/dev-cpp-{hash}.lock` 文件锁 + Unix Domain Socket (`/tmp/dev-cpp-{hash}.sock`)
- 新增 `SendToPreviousInstance(Instance: THandle; CmdLine: String)` 跨平台声明

### 2. `devFileMonitor.pas`（文件变更监控）
**问题**：`FindFirstChangeNotification` Windows 专用 API  
**修复**：新增 `{$IFDEF MSWINDOWS}` 分支
- Windows：原生 `FindFirstChangeNotificationW`（支持 Unicode 路径）
- Linux：轮询方式（每 500ms 检查文件时间戳）

### 3. `ImageTheme.pas`（图标主题）
**问题**：`uses Windows`（界面用途的 GDI 函数）  
**修复**：移除 `Windows`，改用 LCL 的 `TBitmap` + `TCanvas`
- 原来：使用 GDI `BitBlt`, `CreateCompatibleDC`, `SelectObject` 等
- 现在：使用 `TBitmap.Canvas.CopyRect`, `TBitmap.LoadFromFile`, `TBitmap.SaveToFile`

### 4. `devcfg.pas`（全局配置）
**问题**：`SHGetSpecialFolderPath`（`ShlObj`）+ `SHFileOperation`（`ShellAPI`）  
**修复**：
- `interface uses`：`Windows` → `{$IFDEF MSWINDOWS} Windows {$ELSE} LCLType {$ENDIF}`
- `ShlObj`：移至 `{$IFDEF MSWINDOWS}` 条件块
- `TdevDirs.SettoDefaults`：`SHGetSpecialFolderPath` 移入 `{$IFDEF MSWINDOWS}`
- `RemoveOptionsDir`：`SHFileOperation` 移入 `{$IFDEF MSWINDOWS}`，`{$ELSE}` 分支使用 `RenameFile` + `DeleteDirectory`
- 新增 `FileUtil` 到 `implementation uses`

### 5. `DevCpp.lpr`（项目入口）
**问题**：硬编码 Windows 配置目录路径 `%APPDATA%\Dev-Cpp`  
**修复**：
- `SHGetFolderPath` + `CSIDL_APPDATA` 移入 `{$IFDEF MSWINDOWS}`
- Linux：使用 `XDG_CONFIG_HOME`（`$HOME/.config/Dev-Cpp/`）
- Linux：路径分隔符统一用 `PathDelim`（`/`）

### 6. `Utils.pas`（工具函数）
**问题**：`OpenHelpFile` 中的 `ShellExecute`，`ExecuteFile` 专用 Windows，`ShlObj`/`ActiveX` 条件缺失  
**修复**：
- `ShlObj`/`ActiveX`：移入 `{$IFDEF MSWINDOWS}` 条件块
- `OpenHelpFile`：`ShellExecute` → `OpenURL`（跨平台）
- `ExecuteFile`：`ShellExecute` → Windows 分支保留，新增 Linux 分支（`TProcess`）
- 新增 `LCLIntf` 到 `implementation uses`
- `NewSelectDirectory`：`{$IFDEF MSWINDOWS}` 保留原生 BrowseForFolder，`{$ELSE}` 使用 `SelectDirectory`（Lazarus 跨平台）

### 7. `main.pas`（主窗体）
**问题**：已修复（Phase 1 早期完成）
- `LCLIntf` 已加入 `interface uses`
- 所有 ShellExecute 调用已注释或用 `OpenURL` 替代
- `WMLinuxCopyData` 消息处理已添加

### 8. 各 Form 文件（UI 层）
**问题**：`ShellExecute` 调用硬编码 Windows  
**修复**：`ShellAPI` → `LCLIntf`，所有 `ShellExecute(..., 'open', URL, ...)` → `OpenURL(URL)`

| 文件 | 修改内容 |
|------|---------|
| `AboutFrm.pas` | `ShellAPI`→`LCLIntf`，2×`ShellExecute`→`OpenURL` |
| `ExceptionFrm.pas` | `Windows`条件化，`ShellAPI`→`LCLIntf` |
| `FormatterOptionsFrm.pas` | `Windows`条件化，`ShellAPI`→`LCLIntf`，2×`ShellExecute`→`OpenURL` |
| `ProjectOptionsFrm.pas` | `Windows`+`ShellApi`条件化→`LCLIntf` |
| `CompOptionsFrm.pas` | `Windows`条件化，`ShellAPI`→`LCLIntf` |
| `TipOfTheDayFrm.pas` | `Windows`条件化，`ShellAPI`→`LCLIntf` |

---

## 保留暂缓项（Phase 2）

以下文件在 Phase 1 中识别但未修改，留待 Phase 2：

| 文件 | 问题 | 建议方案 |
|------|------|---------|
| `FileAssocs.pas` | `Windows` + `ShlObj` + `ShellAPI` 全局使用 | ✅ Phase 2 已完成：XDG desktop 文件 + xdg-mime |
| `main.pas` 中 `actFixHighDPIExecute` | `TRegistry` 写 Windows 注册表 | ✅ Phase 2 已完成：条件化 + Linux no-op |

---

## 关键技术决策

1. **条件编译 vs 重构**：`{$IFDEF MSWINDOWS}` 包裹 Windows 专用代码，保留原有逻辑
2. **路径分隔符**：`PathDelim`（自动 `\`/`/`），不硬编码反斜杠
3. **配置目录**：Linux 使用 `$XDG_CONFIG_HOME/Dev-Cpp/`（FHS 标准）
4. **`OpenURL` 替代 `ShellExecute`**：`LCLIntf.OpenURL` 是最简跨平台 URL/文件启动方案
5. **`TProcess` 替代 `ShellExecute`**：`ExecuteFile` 在 Linux 使用 `TProcess`（`Process` 单元）

---

## 验证方法

```bash
# Linux (需要 FPC + Lazarus LCL)
cd DevCpp-Lazarus
fpc -Mobjfpc -Sh -gl -vewnhi -Fu. -Fulcl/units/linux -XXs DevCpp.lpr

# Windows (原环境)
lazbuild DevCpp.lpi
```
