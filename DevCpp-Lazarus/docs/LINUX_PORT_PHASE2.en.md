# Linux Port Phase 2 - Feature Parity

> Status: Complete (2026-07-16)
> Goal: eliminate Windows-specific runtime calls and provide controlled feature degradation on Linux
>
> Chinese version: [LINUX_PORT_PHASE2.md](LINUX_PORT_PHASE2.md)

---

## Background

Phase 1 fixed compile-time blockers by replacing Windows APIs with conditional compilation. Phase 2 handles runtime platform-specific features so that each one has a reasonable fallback or no-op on Linux.

---

## Fixed Files

### 1. `devcfg.pas` (global configuration - PATH registration)

**Problem:** `TdevCompilerSets.Load` used `TRegistry` to write the compiler `bin` directory into the Windows system PATH.

**Fix:**

- Windows: keep the original `TRegistry` write to `HKEY_LOCAL_MACHINE\...\Environment`.
- Linux: show an `Application.MessageBox` prompt asking the user to add the path to `~/.profile` or `~/.bashrc`.
- On Linux, the compiler can still be used by injecting PATH through `TProcess.Environment` at runtime.

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

### 2. `Utils.pas` (utility functions - associated program lookup)

**Problem:** `GetAssociatedProgram` used `TRegIniFile` to read the Windows registry for file associations.

**Fix:**

- Windows: keep the original `TRegIniFile` implementation.
- Linux: query the default application with `xdg-mime query default <mime-type>`; fall back to reading `~/.config/mimeapps.list`.
- `uses Registry` moved into a `{$IFDEF MSWINDOWS}` block; `uses Process` moved into the `{$ELSE}` branch.

### 3. `FileAssocs.pas` (file associations - full rewrite)

**Problem:** the entire file depended on the Windows registry (`TRegistry`, `ShlObj`, `SHChangeNotify`).

**Fix:** refactor every function with platform branches.

| Function | Windows | Linux |
|----------|---------|-------|
| `RegisterFiletype` | Write `HKEY_CLASSES_ROOT` | Write `~/.local/share/applications/dev-cpp-{ext}.desktop` |
| `RegisterDDEServer` | Write DDE registry entries | no-op (DDE has no Linux equivalent) |
| `Associate(Index)` | Registry + DDE | Write desktop file + `xdg-mime default` |
| `UnAssociate(Index)` | Delete registry entries | Delete desktop file + `xdg-mime default none` |
| `CheckFiletype` | Read registry | Check whether the desktop file exists |
| `CheckAssociations` | Check/repair registry | Check/repair desktop files |
| `RefreshIcons` | `SHChangeNotify` | `gtk-update-icon-cache` (silently ignore failure) |

**Linux desktop file format:**

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

### 4. `main.pas` (main form - HiDPI fix)

**Problem:** `actFixHighDPIExecute` used `TRegistry` to write Windows `AppCompatFlags`.

**Fix:**

- Windows: keep the original registry write.
- Linux: show an `Application.MessageBox` explaining that this feature is Windows-only.
- `Registry` moved from the `interface uses` clause into a `{$IFDEF MSWINDOWS}` block.

---

## Deferred (Phase 3 or later)

| Item | Problem | Suggested approach |
|------|---------|--------------------|
| Compiler output parsing | Windows path format `\` vs Linux `/` | Normalize with `PathDelim` |
| GDB debugger | Windows `mingw64\bin\gdb.exe` vs Linux `gdb` | Conditional compiler settings |
| Theme icon paths | Windows bitmap resources; Linux needs XPM/PNG | Embed the icons or download them |
| External help documents | `manual\*.html` uses Windows path separators | Normalize with `PathDelim` |

---

## Verification

```bash
# Linux
fpc -Mobjfpc -Sh -gl -vewnhi -Fu. -Fulcl/units/linux DevCpp.lpr

# Key runtime checks on Linux:
# 1. File-association UI -> creates ~/.local/share/applications/dev-cpp-*.desktop
# 2. Compiler loading -> shows the PATH prompt
# 3. HiDPI fix -> shows the Windows-only prompt
# 4. Code completion / editor -> should work normally
```
