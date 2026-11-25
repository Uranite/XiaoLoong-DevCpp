# Linux 移植 Phase 2 — 功能对齐

> English version: [LINUX_PORT_PHASE2.en.md](LINUX_PORT_PHASE2.en.md)

> 状态：✅ 已完成（2026-07-16）
> 目标：消除 Windows 平台特定的功能调用，使 Linux 上功能降级可控

---

## 背景

Phase 1 修复了编译阻断项（Windows API 替换为条件编译）。Phase 2 处理运行时的平台特定功能，使每个功能在 Linux 上有合理的降级方案或 no-op。

---

## 已修复文件清单

### 1. `devcfg.pas`（全局配置 — PATH 注册）
**问题**：`TdevCompilerSets.Load` 中使用 `TRegistry` 将编译器 bin 目录写入 Windows 系统 PATH  
**修复**：
- Windows：保留原有 `TRegistry` 写入 `HKEY_LOCAL_MACHINE\...\Environment`
- Linux：`Application.MessageBox` 提示用户手动将路径加入 `~/.profile` 或 `~/.bashrc`
- Linux 上编译器仍可通过 `TProcess.Environment` 在运行时注入 PATH

```pascal
{$IFDEF MSWINDOWS}
  with TRegistry.Create do
    try ... // write to Windows registry
    finally Free; end;
{$ELSE}
  Application.MessageBox(
    PChar('To use the compiler from the terminal, add to ~/.profile:' + LineEnding +
          '  export PATH="' + CurrentSet.BinDir[0] + ':$PATH"'),
    PChar('Compiler PATH'), MB_OK or MB_ICONINFORMATION);
{$ENDIF}
```

### 2. `Utils.pas`（工具函数 — 获取关联程序）
**问题**：`GetAssociatedProgram` 使用 `TRegIniFile` 读取 Windows 注册表查找文件关联  
**修复**：
- Windows：保留原有 `TRegIniFile` 实现
- Linux：使用 `xdg-mime query default <mime-type>` 查询默认应用，回退读 `~/.config/mimeapps.list`
- `uses Registry` 移至 `{$IFDEF MSWINDOWS}` 条件块，`uses Process` 移至 `{$ELSE}` 分支

### 3. `FileAssocs.pas`（文件关联 — 完整重写）
**问题**：整个文件依赖 Windows 注册表（`TRegistry`、`ShlObj`、`SHChangeNotify`）  
**修复**：按平台分支重构所有函数

| 函数 | Windows | Linux |
|------|---------|-------|
| `RegisterFiletype` | 写 `HKEY_CLASSES_ROOT` | 写 `~/.local/share/applications/dev-cpp-{ext}.desktop` |
| `RegisterDDEServer` | 写 DDE 注册表项 | no-op（DDE 无 Linux 等价） |
| `Associate(Index)` | 注册表 + DDE | 写 desktop 文件 + `xdg-mime default` |
| `UnAssociate(Index)` | 删注册表项 | 删除 desktop 文件 + `xdg-mime default none` |
| `CheckFiletype` | 读注册表 | 检查 desktop 文件是否存在 |
| `CheckAssociations` | 检查/修复注册表 | 检查/修复 desktop 文件 |
| `RefreshIcons` | `SHChangeNotify` | `gtk-update-icon-cache`（失败时静默忽略）|

**Linux desktop 文件格式**：
```ini
[Desktop Entry]
Type=Application
Version=1.0
Name=Dev-C++ (C Source File)
Comment=Dev-C++ IDE - C Source File
Exec=/path/to/dev-cpp %F
Icon=devcpp
MimeType=text/x-csrc;
Terminal=false
Categories=Development;IDE;
StartupNotify=true
```

### 4. `main.pas`（主窗体 — HiDPI 修复）
**问题**：`actFixHighDPIExecute` 使用 `TRegistry` 写 Windows AppCompatFlags 注册表  
**修复**：
- Windows：保留原有注册表写入
- Linux：`Application.MessageBox` 提示此功能仅 Windows 可用
- `Registry` 从 interface `uses` 移至 `{$IFDEF MSWINDOWS}` 条件块

---

## 暂缓项（Phase 3 或后续）

| 项 | 问题 | 建议 |
|----|------|------|
| 编译器输出解析 | Windows 路径格式 `\`，Linux `/` | `PathDelim` 统一处理 |
| GDB 调试器 | Windows `mingw64\bin\gdb.exe`，Linux `gdb` | 条件化编译器设置 |
| 主题图标路径 | Windows 位图资源，Linux 需要 XPM/PNG | 将图标资源嵌入或下载 |
| 外部帮助文档 | `manual\*.html` Windows 路径分隔符 | `PathDelim` 统一 |

---

## 验证方法

```bash
# Linux
fpc -Mobjfpc -Sh -gl -vewnhi -Fu. -Fulcl/units/linux DevCpp.lpr

# 关键检查点（Linux 运行时）
# 1. 文件关联 UI 调用 -> 生成 ~/.local/share/applications/dev-cpp-*.desktop
# 2. 编译器加载 -> 弹出 PATH 提示
# 3. HiDPI 修复 -> 弹出仅 Windows 可用提示
# 4. 代码补全/编辑器 -> 应完全正常
```
