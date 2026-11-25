# Linux Port Phase 1 - Core Blocking Fixes

> Status: Complete (2026-07-16) -> [Phase 2 document](LINUX_PORT_PHASE2.en.md)
> Goal: eliminate compile-time blockers on Linux/FPC
>
> Chinese version: [LINUX_PORT_PHASE1.md](LINUX_PORT_PHASE1.md)

---

## Background

The project `C:\Users\Administrator\WorkBuddy\2026-DevCpp-Lazarus\DevCpp-Lazarus\` was migrated from Delphi/SynEdit to Lazarus/ATSynEdit (v7.0 beta) and previously supported Windows only. This document records the Phase 1 core blocking fixes that make the project compile on Linux/FPC.

---

## Fixed Files

### 1. `Instances.pas` (single instance and file associations)

**Problem:** Windows mutexes plus the `RegisterFileAssoc` API are meaningless on Linux.

**Fix:** fully rewritten to be cross-platform.

- Windows: keep `CreateMutex` + `RegisterFileAssoc`.
- Linux: use `/tmp/dev-cpp-{hash}.lock` file locks plus a Unix domain socket (`/tmp/dev-cpp-{hash}.sock`).
- Added a cross-platform declaration for `SendToPreviousInstance(Instance: THandle; CmdLine: String)`.

### 2. `devFileMonitor.pas` (file-change monitoring)

**Problem:** `FindFirstChangeNotification`, a Windows-only API.

**Fix:** added a `{$IFDEF MSWINDOWS}` branch.

- Windows: native `FindFirstChangeNotificationW` (Unicode path support).
- Linux: polling (check file timestamps every 500 ms).

### 3. `ImageTheme.pas` (icon themes)

**Problem:** `uses Windows` for GDI functions used by the UI.

**Fix:** removed `Windows`; switched to LCL `TBitmap` + `TCanvas`.

- Before: GDI `BitBlt`, `CreateCompatibleDC`, `SelectObject`, etc.
- Now: `TBitmap.Canvas.CopyRect`, `TBitmap.LoadFromFile`, `TBitmap.SaveToFile`.

### 4. `devcfg.pas` (global configuration)

**Problem:** `SHGetSpecialFolderPath` (`ShlObj`) and `SHFileOperation` (`ShellAPI`).

**Fix:**

- `interface uses`: `Windows` -> `{$IFDEF MSWINDOWS} Windows {$ELSE} LCLType {$ENDIF}`.
- `ShlObj`: moved into a `{$IFDEF MSWINDOWS}` block.
- `TdevDirs.SettoDefaults`: `SHGetSpecialFolderPath` moved into `{$IFDEF MSWINDOWS}`.
- `RemoveOptionsDir`: `SHFileOperation` moved into `{$IFDEF MSWINDOWS}`; the `{$ELSE}` branch uses `RenameFile` + `DeleteDirectory`.
- Added `FileUtil` to the `implementation uses` clause.

### 5. `DevCpp.lpr` (program entry point)

**Problem:** hard-coded Windows configuration directory `%APPDATA%\Dev-Cpp`.

**Fix:**

- `SHGetFolderPath` + `CSIDL_APPDATA` moved into `{$IFDEF MSWINDOWS}`.
- Linux: use `XDG_CONFIG_HOME` (`$HOME/.config/Dev-Cpp/`).
- Linux: use `PathDelim` (`/`) consistently for path separators.

### 6. `Utils.pas` (utility functions)

**Problem:** Windows-only `ShellExecute` and `ExecuteFile`, plus missing `ShlObj`/`ActiveX` conditionals.

**Fix:**

- `ShlObj`/`ActiveX`: moved into `{$IFDEF MSWINDOWS}` blocks.
- `OpenHelpFile`: `ShellExecute` -> `OpenURL` (cross-platform).
- `ExecuteFile`: keep the Windows `ShellExecute` branch; added a Linux `TProcess` branch.
- Added `LCLIntf` to the `implementation uses` clause.
- `NewSelectDirectory`: keep native `BrowseForFolder` on Windows; use Lazarus `SelectDirectory` in the `{$ELSE}` branch.

### 7. `main.pas` (main form)

**Problem:** fixed during the early part of Phase 1.

- `LCLIntf` added to the `interface uses` clause.
- All `ShellExecute` calls commented out or replaced with `OpenURL`.
- Added handling for the `WMLinuxCopyData` message.

### 8. Form units (UI layer)

**Problem:** hard-coded Windows `ShellExecute` calls.

**Fix:** `ShellAPI` -> `LCLIntf`; all `ShellExecute(..., 'open', URL, ...)` -> `OpenURL(URL)`.

| File | Change |
|------|--------|
| `AboutFrm.pas` | `ShellAPI` -> `LCLIntf`; 2x `ShellExecute` -> `OpenURL` |
| `ExceptionFrm.pas` | `Windows` made conditional; `ShellAPI` -> `LCLIntf` |
| `FormatterOptionsFrm.pas` | `Windows` made conditional; `ShellAPI` -> `LCLIntf`; 2x `ShellExecute` -> `OpenURL` |
| `ProjectOptionsFrm.pas` | `Windows` + `ShellApi` made conditional -> `LCLIntf` |
| `CompOptionsFrm.pas` | `Windows` made conditional; `ShellAPI` -> `LCLIntf` |
| `TipOfTheDayFrm.pas` | `Windows` made conditional; `ShellAPI` -> `LCLIntf` |

---

## Deferred to Phase 2

The following files were identified during Phase 1 but intentionally left for Phase 2:

| File | Problem | Proposed solution |
|------|---------|-------------------|
| `FileAssocs.pas` | Global use of `Windows` + `ShlObj` + `ShellAPI` | Phase 2 complete: XDG desktop files + `xdg-mime` |
| `main.pas` `actFixHighDPIExecute` | `TRegistry` writes to the Windows registry | Phase 2 complete: conditional + Linux no-op |

---

## Key Technical Decisions

1. **Conditional compilation instead of refactoring:** wrap Windows-specific code in `{$IFDEF MSWINDOWS}` and preserve the original logic.
2. **Path separators:** use `PathDelim` (automatic `\`/`/`); never hard-code backslashes.
3. **Configuration directory:** Linux uses `$XDG_CONFIG_HOME/Dev-Cpp/` (FHS convention).
4. **`OpenURL` instead of `ShellExecute`:** `LCLIntf.OpenURL` is the simplest cross-platform way to open URLs/files.
5. **`TProcess` instead of `ShellExecute`:** `ExecuteFile` uses `TProcess` on Linux (from the `Process` unit).

---

## Verification

```bash
# Linux (requires FPC + Lazarus LCL)
cd DevCpp-Lazarus
fpc -Mobjfpc -Sh -gl -vewnhi -Fu. -Fulcl/units/linux -XXs DevCpp.lpr

# Windows (original environment)
lazbuild DevCpp.lpi
```
