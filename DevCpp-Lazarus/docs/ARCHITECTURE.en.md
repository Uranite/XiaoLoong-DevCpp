# DevCpp (XiaoLoong Dev-C++) Architecture Analysis

> Version: v7.0.5 | Framework: Lazarus 4.6 | Language: Object Pascal (Delphi mode)
> Last updated: 2026-11-25
>
> Chinese version: [ARCHITECTURE.md](ARCHITECTURE.md)

---

## 1. Project Overview

### 1.1 Background

DevCpp is the classic C/C++ integrated development environment originally created by Bloodshed Software and later maintained by Orwell. **The current version is being maintained by the XiaoLoong team on the Lazarus/Free Pascal platform.**

The project has completed the **SynEdit -> ATSynEdit refactor** and the **Delphi -> Lazarus platform migration**. It is now in a phase of feature completion, EControl adaptation, and stabilization.

### 1.2 Basic information

| Property | Value |
|----------|-------|
| Project name | XiaoLoong Dev-C++ (XL7) |
| Version | 7.0.5 |
| Source directory | `DevCpp-Lazarus/` |
| Entry file | `DevCpp.lpr` |
| Project file | `DevCpp.lpi` (Lazarus Project) |
| Main form | `main.pas` -> `TMainForm` |
| Target output | `d:\cc\devcpp\release\DevCpp.exe` |
| Compiler | Free Pascal 3.2.2 |
| IDE | Lazarus 4.6 |

---

## 2. Project Size

```
Pascal source files:      73 .pas + 39 .lfm
Core logic files:        ~70
Total code size:         ~2,100 KB (.pas)
Main form (main.pas):    ~349 KB (largest single file)
Editor (Editor.pas):     ~144 KB
Configuration (devcfg):  ~155 KB
Parser (CppParser.pas):  ~102 KB
Compiler (Compiler.pas): ~56 KB
Project (Project.pas):   ~70 KB
Editor options:          ~79 KB
```

The `.pas` count includes a few legacy/backup units kept in the tree.

---

## 3. Core Technology Stack

### 3.1 Third-party packages

The project installs the following packages through the **Lazarus Online Package Manager**:

| Package | Purpose |
|---------|---------|
| **ATSynEdit** | Modern syntax-highlighting editor control (`TATSynEdit`), the editor engine behind CudaText; replaces SynEdit |
| **ATSynEdit_Ex** | ATSynEdit extension package (additional features) |
| **ATSynEdit_Cmp** | ATSynEdit component collection |
| **EControl** | Syntax highlighting and code-editing component library used with ATSynEdit |
| **EncConv** | Character-encoding conversion library (UTF-8 <-> ANSI <-> Unicode) |
| **ATFlatControls** | Flat control set required by ATSynEdit/EControl |
| **BGRABitmap** | 2D graphics library used for themes and icons |
| **MetaDarkStyle** | Windows dark-theme support |
| **LCLExtensions** | Lazarus control extensions |

### 3.2 Bundled helper tools

| Tool | Location | Purpose |
|------|----------|---------|
| `ConsolePauser.exe` | `Tools\` | Pauses console programs after they exit |
| `devcppPortable.exe` | `Tools\` | Portable-mode launcher |
| `Packman.exe` | `Tools\` | `.pak` plugin package manager (legacy) |
| `GitPush.exe` | `Tools\` | Automatic Git commit/push helper |
| `KeywordHighlighter.exe` | `Tools\` | Keyword hash-table generator |
| `TextDiff.exe` | `Tools\` | File diff tool |

### 3.3 External compiler integration

DevCpp is an IDE: it invokes an external MinGW GCC toolchain.

| Tool | Default executable | Purpose |
|------|--------------------|---------|
| C compiler | `gcc.exe` | Compile C sources |
| C++ compiler | `g++.exe` | Compile C++ sources |
| Debugger | `gdb.exe` / `gdb32.exe` | GDB debugging |
| Resource compiler | `windres.exe` | Compile Windows resource files |
| Make program | `mingw32-make.exe` | Build automation |
| Profiler | `gprof.exe` | Performance profiling |

---

## 4. Module Architecture

```
DevCpp.lpr (entry point)
│  single-instance check, INI path resolution, config load, main form creation
│
└── main.pas (TMainForm) - central dispatcher (~349 KB)
    │
    ├── Editor.pas (TEditor) / EditorList.pas (TEditorList)
    │   ├── ATSynEdit (TATSynEdit) + EControl adapter
    │   └── CodeToolTip.pas / CodeCompletion.pas
    │
    ├── Compiler.pas (TCompiler)
    │
    ├── Debugger.pas + DebugReader.pas (TDebugger, TDebugReader)
    │
    ├── Project.pas (TProject, TProjUnit, TUnitList)
    │
    ├── ClassBrowser.pas (TClassBrowser)
    │   └── CppParser.pas (TCppParser)
    │       ├── CppTokenizer.pas (TCppTokenizer)
    │       ├── CppPreprocessor.pas (TCppPreprocessor)
    │       ├── StatementList.pas (TStatementList)
    │       └── CBUtils.pas
    │
    └── Core support
        ├── devcfg.pas (TdevData, TdevCompilerSet)
        ├── CFGData.pas
        ├── Utils.pas
        ├── DevRun.pas
        ├── devExec.pas
        └── Macros.pas
```

### UI forms

| Group | Forms |
|-------|-------|
| File operations | `NewProjectFrm`, `RemoveUnitFrm`, `FileAssocs` |
| Editing helpers | `EditorOptFrm`, `CodeInsList`, `IncrementalFrm` |
| Search and replace | `FindFrm`, `GotoLineFrm` |
| Project configuration | `ProjectOptFrm`, `CompilerOptFrm`, `CompOptionsFrm` |
| Environment and tools | `EnvironOptfrm`, `ToolFrm`, `ShortcutsFrm` |
| Debug views | `CPUFrm`, `ExceptionFrm`, `ProcessListFrm` |
| Import and export | `ImportMSVCFrm`, `ImportCBFrm`, `PrintFrm` |
| Class/code generation | `NewClassFrm`, `NewFunctionFrm`, `NewVarFrm`, `NewTemplateFrm` |
| Other tools | `LangFrm`, `AboutFrm`, `TipOfTheDayFrm`, `ViewToDoFrm`, `AddToDoFrm`, `FilePropertiesFrm`, `FileEncodingFrm`, `HomepageFrm`, `IconFrm`, `CodeCompletionForm`, `FormatterOptionsFrm` |

### Data module

`DataFrm` contains `dmMain`, including image lists and toolbar images.

### Configuration, resources, and localization

```
devcfg.pas            - devCFG unit (global configuration, ~155 KB)
CFGData.pas           - configuration data structures
LangIDs.inc           - language string constants (66 KB, multi-language support)
MultiLangSupport.pas  - language switching support
Images/               - theme image resources (Gnome/Modern/NewLook)
lexers/               - EControl lexer definitions (.lcf: C++, RC)
Tools/                - helper executables
Templates/            - new-project/new-file templates
Tests/                - unit test code
```

---

## 5. Detailed Module Analysis

### 5.1 Program entry point - `DevCpp.lpr`

```pascal
program DevCpp;
uses
  LCLIntf, LCLType, Forms, Interfaces, sysUtils, Windows,
  main,           // main form
  devcfg,         // global configuration
  CFGData,        // configuration data structures
  FileAssocs,     // file associations
  ExceptionFrm,   // exception handling form
  Instances,      // single-instance management
  CodeToolTip,    // code hints
  CppPreprocessor // preprocessor support
```

**Startup sequence:**

1. `GetPreviousInstance` - detect an existing instance.
2. Resolve the INI configuration path (supports `-c <dir>` portable mode and the default `%APPDATA%\Dev-Cpp` mode).
3. `devData.ReadSelf` - load configuration.
4. `CreateOptions` - initialize options.
5. `Application.CreateForm(TMainForm, MainForm)` - create the main form.

### 5.2 Main form - `main.pas` (`TMainForm`, ~349 KB)

The central dispatcher and **the largest module in the project**. It contains:

- **Menu system**: File, Edit, Search, View, Project, Execute, Tools, Window, Help.
- **Editor management**: multi-document interface with tabs and split layouts.
- **Project management**: project tree view.
- **Debug control**: breakpoints, watches, and stack views.
- **Compiler integration**: one-click compile, run, and debug.
- **File monitoring**: hot reload and external-change detection.

### 5.3 Editor module - `Editor.pas` (`TEditor`, ~144 KB)

Wraps the ATSynEdit editor core:

```
TEditor
  ├── fInProject: boolean
  ├── fText: TATSynEdit                    <- core editor control
  ├── fText.AdapterForHilite: TATAdapterEControl <- EControl syntax highlighter
  ├── fCompletionBox: TCodeCompletion
  ├── fFunctionTip: TCodeToolTip
  ├── fCompletionTimer / fFunctionTipTimer
  ├── breakpoint management (Debugger.BreakPointList + GutterDecor + Bookmarks2)
  ├── bookmark management (Bookmarks2)
  ├── code folding (OptFoldEnabled)
  ├── multiple carets (ATSynEdit Carets)
  └── event handling (OnChange, OnKeyDown, OnCalcBookmarkColor, ...)
```

### 5.4 Compiler module - `Compiler.pas` (`TCompiler`, ~56 KB)

```
TCompiler
  ├── fCompilerSet: TdevCompilerSet     <- compiler configuration set
  ├── fTarget: TTarget                  <- ctInvalid/ctNone/ctFile/ctProject
  ├── fMakefile: String
  ├── compiler argument construction
  ├── compiler output parsing (GCC error format)
  └── events: OnLogEntry, OnOutput, OnCompEnd, OnCompSuccess
```

### 5.5 Debugger module - `Debugger.pas` + `DebugReader.pas`

```
TDebugger
  ├── fReader: TDebugReader        <- reads the GDB output pipe
  ├── fBreakPointList: TList       <- breakpoint list
  ├── fWatchVarList: TList         <- watch-variable list
  ├── breakpoint management
  ├── variable evaluation
  └── stack tracing
```

### 5.6 C++ parser - `CppParser.pas` (~102 KB)

```
TCppParser
  ├── fTokenizer: TCppTokenizer        <- lexical tokenization
  ├── fPreprocessor: TCppPreprocessor  <- preprocessing
  ├── fStatementList: TStatementList   <- parse results
  ├── fIncludesList: TList             <- #include dependencies
  ├── fScannedFiles: TStringList
  ├── fProjectIncludePaths / fIncludePaths
  └── parse entry points: ParseFile(), ParseSource()
```

Parsing pipeline: `CppTokenizer` (tokenize) -> `CppPreprocessor` (preprocess) -> `TCppParser` (semantic analysis) -> `StatementList` (result storage).

### 5.7 Code completion - `CodeCompletion.pas` (~25 KB)

Uses `CppParser` results to provide:

- Automatic member-list popup.
- Symbol lookup.
- Parameter hints.

### 5.8 Code hints - `CodeToolTip.pas` (~31 KB)

- Function signature display.
- Variable type hints.
- Hover recognition (identifiers and preprocessor directives).

### 5.9 Class browser - `ClassBrowser.pas` (~30 KB)

Displays the C++ code structure as a tree:

```
Classes
  ├── Functions
  ├── Variables (members)
  ├── Enums
  ├── Structs
  └── Inherited
Namespaces
Macros
...
```

### 5.10 Configuration management - `devcfg.pas` (~155 KB)

```
devCFG unit (central configuration)
  ├── TdevData (global data class)
  │    ├── CompilerSet[0..9]    <- up to 10 compiler configurations
  │    ├── DefaultCompiler      <- default compiler
  │    ├── INIFileName          <- configuration file path
  │    └── editor/environment/shortcut settings
  │
  └── TdevCompilerSet (compiler configuration class)
       ├── Executables: gcc/g++/gdb/make/windres/gprof
       ├── Directories: Bin/C/Include/Lib
       ├── Predefined: fDefines (predefined macros: __cplusplus, WIN32, etc.)
       └── fOptions: TList<TCompilerOption>
```

### 5.11 Project management - `Project.pas` (~70 KB)

```
TProject
  ├── TProjUnit (one source file in the project)
  │    ├── fFileName, fEditor, fCompile, fLink
  │    └── fBuildCmd (custom build command)
  └── TUnitList (file list)
       ├── Add/Remove/IndexOf
       └── file ordering (priority)
```

---

## 6. Data Flow and Interactions

### 6.1 Build flow

```
User clicks "Compile"
    |
    v
MainForm.actCompileExecute()
    |
    v
TCompiler.Compile()
    |-> TdevCompilerSet.GetCompilerCmd()   <- read compiler arguments
    |-> TProject.GetMakeFile()             <- generate Makefile
    |-> RunAndGetOutput()                  <- invoke gcc/g++/make
    |
    v
GDB parses error output
    |
    v
MainForm.UpdateCaption / highlight error lines
```

### 6.2 Code completion flow

```
User types "obj." in the editor
    |
    v
ATSynEdit detects the trigger character '.'
    |
    v
CodeCompletion.RequestCompletion()
    |-> CppParser.LocateToken()            <- locate the current symbol
    |-> CppParser.GetStatement()           <- get context
    |-> StatementList looks up members
    |
    v
CodeCompletionForm displays the list
    |
    v
User selects an entry -> TEditor.InsertCompletion()
```

### 6.3 Debug flow

```
User clicks "Debug"
    |
    v
MainForm.actDebugExecute()
    |-> TDebugger.Start(gdb)               <- start GDB
    |-> fReader.BeginRead()                <- asynchronously read GDB output
    |
    v
GDB hits a breakpoint
    |
    v
TDebugger.ParseBreakPoint()
    |
    v
MainForm updates the breakpoint view / jumps to the source line
```

---

## 7. File Type Associations

| Extension | File type | Handling |
|-----------|-----------|----------|
| `.dev` | DevCpp project file | Parsed by `Project.pas` |
| `.cpp/.c/.cc/.cxx` | C++/C source | `CppParser` + ATSynEdit |
| `.h/.hpp/.hh` | Header | `CppParser` + ATSynEdit |
| `.rc` | Resource script | Compiled by `windres` |
| `.template` | New-project template | `Templates.pas` |
| `.lcf` | EControl lexer definition | Syntax highlighting |
| `.ini` | Configuration file | `devcfg.pas` |
| `.dev` (legacy) | Project file | Imported by `ImportCBFrm` / `ImportMSVCFrm` |

---

## 8. Architecture Characteristics

### 8.1 Clear layering

| Layer | Modules | Responsibility |
|-------|---------|----------------|
| UI | `main.pas` + all `*Frm` units | Forms and user interaction |
| Business | `Editor`, `Compiler`, `Debugger`, `Project` | Core feature logic |
| Parsing | `CppParser`, `CppTokenizer`, `CppPreprocessor` | Code analysis |
| Data | `devcfg`, `CFGData`, `Project` | Configuration and project data |
| Utilities | `Utils`, `CBUtils`, `StatementList` | Shared helpers |

### 8.2 Event-driven design

The codebase makes extensive use of `procedure of object` callbacks:

```pascal
TLogEntryEvent = procedure(const Msg: String) of object;
TOutputEvent = procedure(const _Line, _Col, _Unit, _Message: String) of object;
TCompEndEvent = procedure of object;
TEvalReadyEvent = procedure(const evalvalue: AnsiString) of object;
```

### 8.3 Single-instance design

On Windows, the application uses the `FindWindow` API to detect an existing instance, ensuring that only one DevCpp process runs at a time.

### 8.4 Portable configuration

The `-c <directory>` command-line option stores configuration in the program directory instead of `%APPDATA%`, enabling true portable use.

### 8.5 Multiple compiler configurations

The IDE supports up to **10 different compiler toolchains** (MinGW, TDM-GCC, etc.) and allows switching between them at any time.

---

## 9. Current Status and TODO

### 9.1 Completed (2026-11-25)

- Delphi -> Lazarus 4.6 migration.
- SynEdit -> ATSynEdit editor replacement.
- EControl syntax-highlighting integration.
- EncConv encoding-conversion support.
- Multi-language UI framework.
- HTML / RTF / TeX export.
- Comment / uncomment / toggle comment (line and inline).
- Highlight all occurrences of the selected word.
- Project unit rename.
- Breakpoint gutter, active-breakpoint, and error-line colors.
- Printing and print setup.
- Linux port Phase 1/2 (conditional compilation, XDG configuration, and file associations).

### 9.2 In progress / TODO

- Finish EControl color/attribute mapping (3 EControl TODO markers and fold colors in `EditorOptFrm.pas`).
- Reimplement ClassBrowser argument/type rendering (the old custom-draw path is disabled).
- Find/replace: regex search and conditional search (ticket #143).
- TODO: conditional breakpoints (condition editor + `break file:line if expr`).
- TODO: jump to a stack frame in the CPU window (ticket #151).
- TODO: reparse open files after the compiler set changes.
- TODO: bind and verify FindOutput custom drawing.
- TODO: customizable highlighter keywords (ticket #145).
- TODO: verify and fix Explorer drag-and-drop (GitHub issue #5).
- TODO: web-update proxy support.
- TODO: Linux port Phase 3 (GDB paths, compiler output paths, theme icons, help paths).
- TODO: move update-check API credentials out of `UpdateCheck.pas` and rotate exposed tokens.

---

## 10. Quick Build Guide

```powershell
# 1. Install dependencies (Lazarus IDE -> Packages -> Online Package Manager)
#    ATSynEdit, ATSynEdit_Cmp, ATSynEdit_Ex, EControl, EncConv,
#    ATFlatControls, BGRABitmap, MetaDarkStyle, LCLExtensions

# 2. Add project requirements (Project -> Project Inspector -> Add Requirement)
#    atsynedit_cmp, atsynedit_ex, atsynedit, econtrol, encconv, metadarkstyle

# 3. Download lexer files (required by EControl)
#    https://sourceforge.net/projects/cudatext/files/addons/lexers/
#    -> put C++.lcf into the lexers/ directory

# 4. Open DevCpp.lpi in Lazarus and build; or build from the command line:
lazbuild DevCpp.lpi
```

---

*Document generated: 2026-07-07*
*Last updated: 2026-11-25*
*Method: manual code review + directory scan*
