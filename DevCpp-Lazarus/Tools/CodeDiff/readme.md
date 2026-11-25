https://github.com/rickard67/TextDiff

# Text compare component for Delphi and Free Pascal

Source code for the freeware component TDiff is written in Delphi. This
component dramatically simplify programming tasks that require calculations
of 'shortest path' or 'longest common sequence' as typically required in file
compare utilities.

PDF documents fully describing the principle algorithms used in both the new and
the older TDiff component ... The original TDiff component was based on:
"An O(ND) Difference Algorithm and its Variations" by E Myers -
Algorithmica Vol. 1 No. 2, 1986, pp. 251-266
The current TDiff component is based on: "An O(NP) Sequence Comparison Algorithm"
by Sun Wu, Udi Manber & Gene Myers

### Getting Started

Download the files and include the Pascal files in your project.

### Demo applications

Two very simple demo applications (with full source code) are include to
demonstrate how the 'TDiff' component can be used in Delphi and Lazarus programs.

### Lazarus migration (2026-09-02)

This repository has been fully migrated to a **pure Lazarus / Free Pascal** project:

- `CodeDiff.lpi` is now a standalone Lazarus project; open and
  build it directly with Lazarus 4.8 (`lazbuild CodeDiff.lpi`).
- All Delphi conditional-compilation branches (`{$IFDEF FPC}` / `{$IFnDEF FPC}` /
  `{$ifndef fpc}`) have been removed — only the FPC/LCL code path remains.
- Delphi project files (`.dpr`, `.dproj`, `.dproj.local`, `.dfm`, `.identcache`) have
  been deleted.
- The old `src/Diff_O_(ND).pas` (Myers O(ND) reference implementation) has been removed;
  the current O(NP) implementation in `Diff.pas` is the only TDiff core.
- Delphi-specific items replaced for LCL/FPC: `Windows` → `LCLIntf, LCLType`,
  `System.Character` → `Character`, `TList<Cardinal>` (Generics.Collections) →
  `TFPGList<Cardinal>` (FGL), `s.ToUpper` → `UpperCase(s)`, `clWebKhaki` → `clYellow`.

### Renamed to CodeDiff (2026-09-27)

The demo application was renamed from `TextDiffBasic` to **`CodeDiff`**:

- Folder `TextDiffBasic/` → `CodeDiff/` (project root `Tools/CodeDiff/`).
- Project files `TextDiffBasic.lpr` / `.lpi` / `.lps` → `CodeDiff.lpr` / `.lpi` / `.lps`;
  target executable is now `CodeDiff.exe`.
- `CodeDiff.lpi` title, main window caption and `HashUnit.pas` header updated.
- The application icon is `CodeDiff.ico` (16/24/32 px); the old `.lpi` referenced a
  missing `TextDiffBasic_Icon.ico`, which produced a build error.

Note: nothing in the build depends on the identifier `TextDiffBasic` any more. It
survives only in `backup/` as `TextDiffBasic.lpi.old` / `.lps.old`, kept for
reference. The names **TextDiff** and **TDiff** are retained deliberately — they
refer to the upstream repository (`github.com/rickard67/TextDiff`) and to Angus
Johnson's `TDiff` component, whose source files (`Diff.pas`, `HashUnit.pas`) are
third-party code and are still used as-is.

#### Application icon and XP manifest

On Windows the icon and the XP manifest reach the executable through a generated
resource file, `CodeDiff.res`, included from `CodeDiff.lpr` via `{$R *.res}`.
`lazbuild` regenerates `CodeDiff.res` on every build (log line
`(9022) Compiling resource ...\lib\x86_64-win64\CodeDiff.obj`) and the linker
folds it into the `.rsrc` section.

Two rules follow from this, and both are easy to get wrong:

1. Do **not** remove `{$R *.res}` from `CodeDiff.lpr`. Without it the `.res` is
   written to disk but never linked, so the program silently loses its icon and
   manifest while still compiling cleanly.
2. Do **not** add a `<Resources>` block to `CodeDiff.lpi` while `<Icon Value="0"/>`
   is present. The two mechanisms each inject `MAINICON`, and the duplicate
   aborts the build with `EResourceDuplicateException` (exit code 217).

`<Icon Value="0"/>` plus `<UseXPManifest Value="True"/>` in the `.lpi` is the
correct and sufficient configuration.

### Authors
Author        : Angus Johnson - angusj-AT-myrealbox-DOT-com\
Copyright     : © 2001-2008 Angus Johnson\
Updated by    : Rickard Johansson ([RJ TextEd](https://www.rj-texted.se))

### Version history
- **December 2001**\
  Original release (used Myer O(ND) Difference Algorithm)
- **22 April 2008**\
  Complete rewrite to greatly improve the code and provide a much simpler view of differences through a new 'Compares' property.
- **21 May 2008**\
  Another complete code rewrite to use Sun Wu et al. O(NP) Sequence Comparison Algorithm which more than halves times of typical comparisons.
- **24 May 2008**\
  Reimplemented "divide-and-conquer" technique (which was omitted in 21 May release) so memory use is again minimal.
- **25 May 2008**\
  Removed recursion to avoid the possibility of running out of stack memory during massive comparisons.
- **2 June 2008**\
  Minor bugfixes.
- **11 November 2018**\
  Added TList<Cardinal> to store hash values.\
  Made some minor code formatting and code changes\
  Fixed Unicode string issues
- **19 May 2020**\
  Added Lazarus support
- **23 May 2020**\
  Replaced almost all code in demo 1. It should be much easier to understand now.\
  Fixed a few issues in demo 2.

