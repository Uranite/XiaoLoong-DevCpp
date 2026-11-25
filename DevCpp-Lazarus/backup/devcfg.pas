{
    This file is part of Dev-C++
    Copyright (c) 2004 Bloodshed Software

    Dev-C++ is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Dev-C++ is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Dev-C++; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

unit devCFG;

interface

uses
  Dialogs,
{$IFDEF MSWINDOWS}
  {$IFDEF MSWINDOWS}Windows{$ELSE}LCLIntf, LCLType{$ENDIF},
{$ELSE}
  LCLType,
{$ENDIF}
  Messages, Classes, Graphics, Version,
  ATSynEdit, editor, ConfigData, ProjectTypes, {$IFDEF MSWINDOWS}ShellAPI{$ENDIF}, {$IFDEF MSWINDOWS}Registry{$ENDIF},
{$IFDEF MSWINDOWS}
  {$IFDEF MSWINDOWS}ShlObj{$ENDIF},
{$ENDIF}
  ComCtrls,
  ATSynEdit_Adapter_EControl,
  ATSynEdit_Adapters,
  ATSynEdit_Commands,
  ATSynEdit_Globals,
  ec_syntanal, ec_syntax_format;

const
  BoolValYesNo: array[boolean] of String = ('No', 'Yes');
  ValueToChar: array[0..27] of char = ('0', '1', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h',
    'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r',
    's', 't', 'u', 'v', 'w', 'x', 'y', 'z');

  // ---- Editor colour-element constants ----
  // These used to be instance properties of TdevEditor (ColorElemNames/ColorSyntax/
  // ColorSpecial/BuiltinSchemes). They never actually vary, so they live here as
  // plain constants instead of being stored (and persisted) per editor object.
  //
  // Number of syntax ("lexer") colour elements: indices 0 .. ColorSyntax-1
  ColorSyntax = 14;   // space, comment, reservedword ...
  // Number of extra ("special") colour elements: indices ColorSyntax .. ColorSyntax+ColorSpecial-1
  ColorSpecial = 10; // bookmark, selected text, current line, breakpoint, gutter, ...
  // Total number of built-in syntax colour schemes
  BuiltinSchemes = 14;
  // Colour-element names, in the exact order they are stored in TdevEditor.Colors.
  // The first ColorSyntax entries are lexer elements, the remaining ColorSpecial
  // entries are the special elements defined in Version.pas (cBP, cErr, ...).

  cBP  = 'Breakpoint';  //BreakPoint
  cErr = 'ErrorLine';   //Error Line
  cABP = 'ActiveBpt';   //active BreakPoint
  cBM  = 'Bookmarks';   //Book marks
  cSel = 'SelectText';
  cCur = 'CurrentLine';
  cGut = 'GutterNum';   //Gutter and line number
  cEdt = 'EditState';    //Edit State (Saved, changed or Added)
  cFld = 'FoldLine1';   //Folding area and current folding Line
  cFld2 = 'FoldLine2';  //Second Folding line


  ColorElemNames: array[0..ColorSyntax + ColorSpecial - 1] of string = (
    // Lexer element names
    'Space', 'Comment', 'Preprocessor', 'ReservedWord', 'Identifier',
    'Symbol', 'Number Float', 'Number', 'Number Oct', 'Number Hex/Bin',
    'String', 'Char', 'Asm BG', 'Incorrect',
    // Special element names (const in Version.pas)
    cBP, cErr, cABP, cBM, cSel, cCur, cGut, cEdt, cFld, cFld2
  );

type
  // the comments are an example of the record
  PCompilerOption = ^TCompilerOption;
  TCompilerOption = record
    Name: integer; // language table index of "Generate debugging info"
    Section: integer; // language table index of "C options"
    IsC: boolean;
    IsCpp: boolean; // True (C++ option?) - can be both C and C++ option...
    IsLinker: boolean; // Is it a linker param
    Value: Integer; // True
    Setting: String; // "-g3"
    Choices: TStringList; // replaces "Yes/No" standard choices (max 30 different choices)
  end;

  TdevCompilerSet = class(TPersistent)
  private
    // Executables, most are hardcoded
    fgccName: String;
    fgppName: String;
    fmakeName: String;
    fgdbName: String;
    fwindresName: String;
    fgprofName: String;

    // Directories, mostly hardcoded too
    fBinDir: TStringList;
    fCDir: TStringList;
    fCppDir: TStringList;
    fLibDir: TStringList;

    // Misc. properties
    fDumpMachine: String; // "x86_64-w64-mingw32", "mingw32" etc
    fVersion: String; // "4.7.1"
    fType: String; // "TDM-GCC", "MinGW"
    fName: String; // "TDM-GCC 4.7.1 Release"
    fFolder: String; // TDM-GCC-64, MinGW64, MinGW32
    fDefInclude: TStringList; // default include dir
    fDefines: TStringList; // list of predefined constants

    // User settings
    fCompAdd: boolean;
    fLinkAdd: boolean;
    //fAutoLink: boolean;
    fCompOpt: String;
    flinkOpt: String;

    // Options
    fOptions: TList;

    // Initialization
    procedure SetProperties(const BinDir, BinFile: String);
    procedure SetExecutables;
    procedure SetDirectories;
    procedure SetUserInput;
    procedure SetOptions;

    // Converts to and from memory format
    function GetINIOptions: String;
    procedure SetINIOptions(const value: String);

    // Validation
    function Validate: boolean; // returns true if valid
    function ValidateDirs: boolean; // idem
    function ValidateExes: boolean; // idem
  public
    constructor Create; overload; // create empty shell
    constructor Create(const CompilerFolder: String); overload; // create, and let if configure itself
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    // Clearing and saving to disk is done by TdevCompilerSet
    procedure Clear;

    // Option utils
    procedure AddOption(Name, Section: integer; IsC, IsCpp, IsLinker: boolean;
      Value: integer; const Setting: String; Choices: TStringList);
    function GetOption(const Option: String): Char;
    function FindOption(const Option: String; var opt: PCompilerOption; var Index: integer): boolean;
    procedure SetOption(const Option: String; Value: Char); overload;
    procedure SetOption(Option: PCompilerOption; Value: char); overload;

    // Obtain response from compiler
    function GetCompilerOutput(const BinDir, BinFile, Input: String): String;

    // Executables
    property gccName: String read fgccName write fgccName;
    property gppName: String read fgppName write fgppName;
    property makeName: String read fmakeName write fmakeName;
    property gdbName: String read fgdbName write fgdbName;
    property windresName: String read fwindresName write fwindresName;
    property gprofName: String read fgprofName write fgprofName;

    // Directories
    property BinDir: TStringList read fBinDir write fBinDir;
    property CDir: TStringList read fCDir write fCDir;
    property CppDir: TStringList read fCppDir write fCppDir;
    property LibDir: TStringList read fLibDir write fLibDir;

    // Properties
    property Name: String read fName write fName;
    property DefInclude: TStringList read fDefInclude;
    property Defines: TStringList read fDefines;

    // Options
    property Options: TList read fOptions write fOptions;
    property INIOptions: String read GetINIOptions write SetINIOptions;

    // User settings
    property AddtoComp: boolean read fCompAdd write fCompAdd;
    property AddtoLink: boolean read fLinkAdd write fLinkAdd;
    //property AutoLink: boolean read fAutoLink write fAutoLink;
    property CompOpts: String read fCompOpt write fCompOpt;
    property LinkOpts: String read fLinkOpt write fLinkOpt;
  end;

  // compiler-set configuration
  TdevCompilerSets = class(TPersistent)
  private
    fList: TList; // list of TdevCompilerSet
    fDefaultIndex: integer;
    function GetCompilationSet: TdevCompilerSet;
    function GetCompilationSetIndex: Integer;
    function GetDefaultSet: TdevCompilerSet; // returns regular current set
  public
    constructor Create;
    destructor Destroy; override;

    // sigle set management in memory
//    procedure OnCompilerSetChanged(OldSet, NewSet: TdevCompilerSet);
    procedure LoadSet(Index: integer; const SetName: String = '');
    procedure SaveSet(Index: integer);
    function AddSet: TdevCompilerSet; overload; // add empty shell
    function AddSet(const Folder: String): TdevCompilerSet; overload; // add empty shell, let it configure itself
    function AddSet(compilerset: TdevCompilerSet): TdevCompilerSet; overload; // add deep copy
    function GetSet(Index: integer): TdevCompilerSet;
    procedure DeleteSet(Index: integer);
    function Count: integer;

    // all set management on disk
    procedure LoadSets; // load everything of Compiler Sets from disk
    procedure SaveSets; // save everything to disk
    procedure SaveSetList; // only save the CompilerSets section
    procedure FindSets;
    procedure ClearSets;
    //procedure LoadAutoLinks(var strlist: TStringList); // load Auto Links from disk

    // access to list
    property CompilationSet: TdevCompilerSet read GetCompilationSet;
    property CompilationSetIndex: Integer read GetCompilationSetIndex;
    property DefaultSet: TdevCompilerSet read GetDefaultSet;
    property DefaultSetIndex: Integer read fDefaultIndex write fDefaultIndex;
    property Sets[index: integer]: TdevCompilerSet read GetSet; default;
  end;

  // code-completion window size and other config
  TdevCodeCompletion = class(TPersistent)
  private
    fWidth: integer;
    fHeight: integer;
    fDelay: integer;
    fBackColor: integer;
    fTextColor: integer;
    fHighColor: integer;
    fEnabled: boolean;
    fShowFunctionHints: boolean;
    fShowMemberCompletion: boolean;
    fShowIdentCompletion: boolean;
    fParseLocalHeaders: boolean;
    fParseGlobalHeaders: boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SettoDefaults;
    procedure SaveSettings;
    procedure LoadSettings;
  published
    property Width: integer read fWidth write fWidth;
    property Height: integer read fHeight write fHeight;
    property Delay: integer read fDelay write fDelay;
    property BackColor: integer read fBackColor write fBackColor;
    property TextColor: integer read fTextColor write fTextColor;
    property HighColor: integer read fHighColor write fHighColor;
    property Enabled: boolean read fEnabled write fEnabled;
    property ShowFunctionHints: boolean read fShowFunctionHints write fShowFunctionHints;
    property ShowMemberCompletion: boolean read fShowMemberCompletion write fShowMemberCompletion;
    property ShowIdentCompletion: boolean read fShowIdentCompletion write fShowIdentCompletion;
    property ParseLocalHeaders: boolean read fParseLocalHeaders write fParseLocalHeaders;
    property ParseGlobalHeaders: boolean read fParseGlobalHeaders write fParseGlobalHeaders;
  end;

  // class-browsing view style
  TdevClassBrowsing = class(TPersistent)
  private
    fShowFilter: integer;
    fShowInheritedMembers: boolean;
  public
    constructor Create;
    procedure SettoDefaults;
    procedure SaveSettings;
    procedure LoadSettings;
  published
    property ShowFilter: integer read fShowFilter write fShowFilter;
    property ShowInheritedMembers: boolean read fShowInheritedMembers write fShowInheritedMembers;
  end;

  // Options for AStyle
  TdevFormatter = class(TPersistent)
  private
    fBracketStyle: Integer;
    fIndentStyle: Integer;
    fTabWidth: Integer;
    fMaxLineLength: Integer;
    fModifyMaxLineLength: Boolean;
    fAdjustLines: Boolean;
    fAdjustSpaces: Boolean;
    fIndentClasses: Boolean;
    fIndentSwitches: Boolean;
    fIndentCases: Boolean;
    fIndentNamespaces: Boolean;
    fIndentLabels: Boolean;
    fIndentPreprocessor: Boolean;
    fFullCommand: String; // includes customizations
    fAStyleDir: String;
    fAStyleFile: String;
  public
    constructor Create;
    procedure SettoDefaults;
    procedure SaveSettings;
    procedure LoadSettings;
    function Validate: Boolean; // check if AStyle.exe can be found
    function FormatMemory(Editor: TEditor; const OverrideCommand: String): String; // apply formatting
    function FormatFile(const FileName: UnicodeString; const OverrideCommand: String): String; // apply formatting
    function GetVersion: String;
    function GetFullCommand: String;
  published
    property BracketStyle: Integer read fBracketStyle write fBracketStyle;
    property IndentStyle: Integer read fIndentStyle write fIndentStyle;
    property OptTabSize: Integer read fTabWidth write fTabWidth;
    property MaxLineLength: Integer read fMaxLineLength write fMaxLineLength;
    property ModifyMaxLineLength: Boolean read fModifyMaxLineLength write fModifyMaxLineLength;
    property AdjustLines: Boolean read fAdjustLines write fAdjustLines;
    property AdjustSpaces: Boolean read fAdjustSpaces write fAdjustSpaces;
    property IndentClasses: Boolean read fIndentClasses write fIndentClasses;
    property IndentSwitches: Boolean read fIndentSwitches write fIndentSwitches;
    property IndentCases: Boolean read fIndentCases write fIndentCases;
    property IndentNamespaces: Boolean read fIndentNamespaces write fIndentNamespaces;
    property IndentLabels: Boolean read fIndentLabels write fIndentLabels;
    property IndentPreprocessor: Boolean read fIndentPreprocessor write fIndentPreprocessor;
    property FullCommand: String read fFullCommand write fFullCommand;
    property AStyleDir: String read fAStyleDir write fAStyleDir;
    property AStyleFile: String read fAStyleFile write fAStyleFile;
  end;

  // List of programs to use for unknown file extensions
  TdevExternalPrograms = class(TPersistent)
  private
    fDummy: boolean;
    fPrograms: TStrings;
    function GetProgramName(Index: integer): String;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SettoDefaults;
    procedure SaveSettings;
    procedure LoadSettings;

    property ProgramName[Index: integer]: String read GetProgramName;
    function AssignedProgram(const ext: String): integer;
    function AddProgram(ext, prog: String): integer;
  published
    property Dummy: boolean read fDummy write fDummy;
    property Programs: TStrings read fPrograms write fPrograms;
  end;

  // global directories
  TdevDirs = class(TPersistent)
  private
    fThemes: String; // Themes Directory
    fIcons: String; // Icon Library
    fHelp: String; // Help
    fLang: String; // Language
    fTemp: String; // Templates
    fDefault: String; // user defined default
    fExec: String; // dev-c start
    fConfig: String; // config files directory
    fOldPath: String; // Enviroment Path at program start
  public
    constructor Create;
    procedure SettoDefaults;
    procedure SaveSettings;
    procedure LoadSettings;

    // don't bother to remember, read on startup
    property OriginalPath: String read fOldPath write fOldPath;
    property Exec: String read fExec write fExec;
    property Config: String read fConfig write fConfig;
  published
    property Default: String read fDefault write fDefault;
    property Help: String read fHelp write fHelp;
    property Icons: String read fIcons write fIcons;
    property Lang: String read fLang write fLang;
    property Templates: String read fTemp write fTemp;
    property Themes: String read fThemes write fThemes;
  end;

  // editor options -- syntax, synedit options, etc...
  TdevEditor = class(TPersistent)
  private
    fUseSyn: boolean; // use syntax highlighting
    fSynExt: String; // semi-colon seperated list of highlight ext's
    fFont: TFont;   // Editor Font for ansi characters
    //fWideFontName: String;  // Font name for wide characters
    fGutterFont: TFont; // Gutter font
    fInsertCaret: integer; // Editor insert caret
    fOverwriteCaret: integer; // Editor overwrite caret
    fTabSize: integer; // Editor Tab Size
    fGutterSize: integer; // Width of Left margin gutter
    fMarginSize: integer; // Width of right margin

    fCustomGutter: boolean; // Use Selected Gutter font
    fGutterAuto: boolean; // Gutter Auto Sizes
    fShowTopRuler: boolean; // Show Left gutter in editor
    fWordWrap: boolean;
    fShowMinimap: boolean;
    fShowMacromap: boolean;
    fLineNumbers: boolean; // Show Line Numbers
    fLeadZero: boolean; // Show leading zero's in line nums
    fFirstisZero: boolean; // First line is zero

    fMarginVis: boolean; // Toggle right margin line

    fShowScrollHint: boolean; // Show line number when scrolling
    fShowScrollbars: boolean; // Show Scroll bars
    fHalfPage: boolean; // PgUp/PgDn move half a page

    fPastEOF: boolean; // Cursor moves past end of file
    fPastEOL: boolean; // Cursor moves past end of lines
    fFindText: boolean; // Text at cursor defaults in find dialog
    fEHomeKey: boolean; // Home key like visual studio
    fGroupUndo: boolean; // treat same undo's as single undo
    fInsDropFiles: boolean; // Insert files when drag/dropped else open
    fInsertMode: boolean; // Editor defaults to insert mode
    fAutoIndent: boolean; // Auto-indent code lines
    fAddIndent: boolean; // Add indent when typing { and :
    fSmartTabs: boolean; // Tab to next no whitespace char
    fShowSpecialChars: boolean; // special line characters visible
    //fShowEndOfLine: boolean; // EOL and EOF characters visible
    fUseTabs: boolean; // convert tabs to spaces
    fShowFunctionTip: boolean; // show function tip
    fUseCodeFold: boolean;  // show code folding on gutter
    fClickCodeFold: boolean;  //click to fold/unfold code
    fMarginColor: TColor; // Color of right margin
    fColorScheme: TStrings; // Holds Color attributes settings
    fSchemeIndex: integer; //Build-in Syntax scheme current used.
    fElemIndex: integer;   //Last Element index in ElemList listbox
    fDefaultCode: boolean; // Insert Default Source Code into new files
    fParserHints: boolean; // Show parser's hint for the word under the cursor
    fMatch: boolean; // Highlight matching parenthesis
    fHighCurrLine: boolean; // Highlight current line
    fHighColor: TColor; // Color of current line when highlighted
    fTrimTrailingSpaces: boolean;

    // Autosave
    fEnableAutoSave: boolean;
    fInterval: integer;
    fAutoSaveFilter: integer;
    fAutoSaveMode: integer;

    // Symbol completion
    fBraceComplete: boolean;
    fParentheseComplete: boolean;
    fIncludeComplete: boolean;
    fCommentComplete: boolean;
    fArrayComplete: boolean;
    fSingleQuoteComplete: boolean;
    fDoubleQuoteComplete: boolean;
    fCompleteSymbols: boolean;
    fDeleteSymbolPairs: boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetColorScheme(idx: integer);
    procedure SettoDefaults;
    procedure SaveSettings;
    procedure LoadSettings;
    procedure AssignEditor(editor: TATSynEdit; const FileName: String);
  published
    property AutoIndent: boolean read fAutoIndent write fAutoIndent;
    property AddIndent: boolean read fAddIndent write fAddIndent;
    property InsertMode: boolean read fInsertMode write fInsertMode;
    property UseTabs: boolean read fUseTabs write fUseTabs;
    property SmartTabs: boolean read fSmartTabs write fSmartTabs;
    property GroupUndo: boolean read fGroupUndo write fGroupUndo;
    property EHomeKey: boolean read fEHomeKey write fEHomeKey;
    property PastEOF: boolean read fPastEOF write fPastEOF;
    property PastEOL: boolean read fPastEOL write fPastEOL;
    property FindText: boolean read fFindText write fFindText;
    property Scrollbars: boolean read fShowScrollbars write fShowScrollbars;
    property HalfPageScroll: boolean read fHalfPage write fHalfPage;
    property ScrollHint: boolean read fShowScrollHint write fShowScrollHint;
    property ShowSpecialChars: boolean read fShowSpecialChars write fShowSpecialChars;
    //property ShowEndOfLine: boolean read fShowEndOfLine write fShowEndOfLine;
//    property ShowFunctionTip: boolean read fShowFunctionTip write fShowFunctionTip;
    property UseCodeFold: boolean read fUseCodeFold write fUseCodeFold;
    property ClickCodeFold: boolean read fClickCodeFold write fClickCodeFold;
    property TrimTrailingSpaces: boolean read fTrimTrailingSpaces write fTrimTrailingSpaces;

    property TabSize: integer read fTabSize write fTabSize;
    property MarginVis: boolean read fMarginVis write fMarginVis;
    property MarginSize: integer read fMarginSize write fMarginSize;
    property MarginColor: TColor read fMarginColor write fMarginColor;
    property InsertCaret: integer read fInsertCaret write fInsertCaret;
    property OverwriteCaret: integer read fOverwriteCaret write fOverwriteCaret;
    property InsDropFiles: boolean read fInsDropFiles write fInsDropFiles;
    property Font: TFont read fFont write fFont;
    //property WideFontName: String read fWideFontName write fWideFontName;

    // Gutter options
    property ShowTopRuler: boolean read fShowTopRuler write fShowTopRuler;
    property WordWrap: boolean read fWordWrap write fWordWrap;
    property ShowMinimap: boolean read fShowMinimap write fShowMinimap;
    property ShowMacromap: boolean read fShowMacromap write fShowMacromap;

    property GutterAuto: boolean read fGutterAuto write fGutterAuto;
    property LineNumbers: boolean read fLineNumbers write fLineNumbers;
    property LeadZero: boolean read fLeadZero write fLeadZero;
    property FirstLineZero: boolean read fFirstisZero write fFirstisZero;
    property Gutterfnt: boolean read fCustomGutter write fCustomGutter;
    property GutterSize: integer read fGutterSize write fGutterSize;
    property Gutterfont: TFont read fGutterfont write fGutterFont;

    // Color Scheme
    property UseSyntax: boolean read fUseSyn write fUseSyn;
    property SyntaxExt: String read fSynExt write fSynExt;
    property ColorScheme: TStrings read fColorScheme write fColorScheme;
    property SchemeIndex: integer read fSchemeIndex write fSchemeIndex;


    property ElemIndex: integer read fElemIndex write fElemIndex;

    // other
    property DefaultCode: boolean read fDefaultCode write fDefaultCode;
    property ParserHints: boolean read fParserHints write fParserHints;
    property Match: boolean read fMatch write fMatch;
    property HighCurrLine: boolean read fHighCurrLine write fHighCurrLine;
    property HighColor: TColor read fHighColor write fHighColor;

    // Autosave
    property EnableAutoSave: boolean read fEnableAutoSave write fEnableAutoSave;
    property Interval: integer read fInterval write fInterval;
    property AutoSaveFilter: integer read fAutoSaveFilter write fAutoSaveFilter;
    property AutoSaveMode: integer read fAutoSaveMode write fAutoSaveMode;

    // Brace completion
    property BraceComplete: boolean read fBraceComplete write fBraceComplete;
    property ParentheseComplete: boolean read fParentheseComplete write fParentheseComplete;
    property IncludeComplete: boolean read fIncludeComplete write fIncludeComplete;
    property CommentComplete: boolean read fCommentComplete write fCommentComplete;
    property ArrayComplete: boolean read fArrayComplete write fArrayComplete;
    property SingleQuoteComplete: boolean read fSingleQuoteComplete write fSingleQuoteComplete;
    property DoubleQuoteComplete: boolean read fDoubleQuoteComplete write fDoubleQuoteComplete;
    property CompleteSymbols: boolean read fCompleteSymbols write fCompleteSymbols;
    property DeleteSymbolPairs: boolean read fDeleteSymbolPairs write fDeleteSymbolPairs;
  end;

  TWindowState = class(TPersistent)
  private
    fLeft: integer;
    fTop: integer;
    fRight: integer;
    fBottom: integer;
    fShowCmd: integer;
    fFlags: integer;
    fStruct: TWindowPlacement; // don't store on disk!
  public
    constructor Create;
    procedure GetPlacement(Source: HWND);
    procedure SetPlacement(Destination: HWND);
  published
    property Left: integer read fLeft write fLeft; // TWindowPlacement parts
    property Top: integer read fTop write fTop;
    property Right: integer read fRight write fRight;
    property Bottom: integer read fBottom write fBottom;
    property ShowCmd: integer read fShowCmd write fShowCmd;
    property Flags: integer read fFlags write fFlags;
  end;

  // master option object -- contains program globals
  TdevData = class(TConfigData)
  private
    fLang: String; // Language file
    fAppMode: integer;  //Appearance mode (0-Default, 1-AllowDark, 2-ForceDark, 3-ForceLight)
    fTheme: String; // Theme file
    fFindCols: String; // Find Column widths (comma sep)
    fCompCols: String; // Compiler Column Widths (comma sep)
    fMsgTabs: TTabPosition; // Editor Tabs
    fMinOnRun: boolean; // Minimize IDE on run
    fMRUMax: integer; // Max number of files in history list
    fBackup: boolean; // Create backup files
    fAutoFormat: Boolean;   //Auto Formate Source files
    fDeleteExe: boolean;  //Delete .exe file before close
    fAutoOpen: integer; // Auto Open Project Files Style
    fAutoCheckUpdate: integer; //Auto check update at start up: -1, 0, 1

    fAutoLoadLast: boolean; // Auto Load Last project or files
    fLastProject: String;   // Last closed project;
    fLastFiles: integer;    // Last closed files;
    fLastActive: integer;   // Last active file;

    fShowLeftPages: boolean; // Show the left page control
    fProjectWidth: integer; // Width of project browser
    fLeftActivePage: integer; // 0 == project, 1 == class, 2 == debug
    fOutputHeight: integer; // the height of the output window
    fStatusbar: boolean; // Statusbar Visible
    fFullScr: boolean; // IDE is Full screen
    fShowMenu: boolean; // Show Menu in FullScreen mode
    fShowBars: boolean; // Show toolbars in FullScreen mode
    fMultiLineTab: boolean; // Show multiline tabs
    fDefCpp: boolean; // Default to C++ project (compile with g++)
    fFirst: boolean; // first run of dev-c
    fSplash: String; // user selected splash screen
    fdblFiles: boolean; // double click opens files out of project manager
    fLangChange: boolean; // flag for language change
    fthemeChange: boolean; // did the theme change?
    fInterfaceFont: String; // UI font
    fInterfaceFontSize: integer; // UI font size
    fConsolePause: boolean; // pause console program after return
    fShortenCompPaths: boolean; // shorten compiler paths in compiler log
    fTranslateMsg: boolean; // Translate compiling message

    // TWindowPlacement parts
    fWindowState: TWindowState;
    fReportWindowState: TWindowState;
    fProjectWindowState: TWindowState;

    fToolbarMain: boolean; // These ones follow the enable/x-offset/y-offset patern
    fToolbarMainX: integer;
    fToolbarMainY: integer;
    //fToolbarMainH: integer;
    fToolbarEdit: boolean;
    fToolbarEditX: integer;
    fToolbarEditY: integer;
    fToolbarCompile: boolean;
    fToolbarCompileX: integer;
    fToolbarCompileY: integer;
    fToolbarProject: boolean;
    fToolbarProjectX: integer;
    fToolbarProjectY: integer;
    fToolbarSpecials: boolean;
    fToolbarSpecialsX: integer;
    fToolbarSpecialsY: integer;
    fToolbarSearch: boolean;
    fToolbarSearchX: integer;
    fToolbarSearchY: integer;
    fToolbarClasses: boolean;
    fToolbarClassesX: integer;
    fToolbarClassesY: integer;
    fToolbarCompilers: boolean;
    fToolbarCompilersX: integer;
    fToolbarCompilersY: integer;

    // file associations (see FileAssocs.pas)
    fAssociateC: boolean;
    fAssociateCpp: boolean;
    fAssociateCxx: boolean;
    fAssociateH: boolean;
    fAssociateHpp: boolean;
    fAssociateHxx: boolean;
    fAssociateDev: boolean;
    fAssociateRc: boolean;
    fAssociateTemplate: boolean;
    fAssociateF77: boolean;
    fAssociateF90: boolean;
    fCheckAssocs: boolean;

    // More misc stuff
    fShowTipsOnStart: boolean;
    fLastTip: integer;
    fShowProgress: boolean; // Show progress window during compile
    fAutoCloseProgress: boolean; // Auto close progress bar window after compile

    // Printer
    fPrintColors: boolean; // print colors
    fPrintHighlight: boolean;
    fPrintWordWrap: boolean;
    fPrintLineNumbers: boolean;
    fPrintLineNumbersMargins: boolean;

    // Some debug options
    fWatchLocals: boolean; //Auto watch local variables
    fWatchHint: boolean; // watch variable under mouse
    fUseATTSyntax: boolean;
    fShowCPUSignal: boolean; // show CPU window on signal
    fCPURegisterCol1: integer; // width of column 1
    fCPURegisterCol2: integer; // width of column 1
    fCPURegisterCol3: integer; // width of column 1

    // Search preferences
    fCaseSensitive: boolean;
    fWholewords: boolean;
    fPromptReplace: boolean;
    fScopeIsSelected: boolean; // false == Global
    fOriginEntireScope: boolean; // false == from cursor
    fSearchWhere: integer; // 0 == project files, 1 == open files, 2 == current file
    fDirBackward: boolean;

    // Floating windows
    fProjectFloat: boolean;
    fMessageFloat: boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SettoDefaults; override;
    property LangChange: boolean read fLangChange write fLangChange;
    property ThemeChange: boolean read fThemeChange write fThemeChange;
  published
    property Language: String read fLang write fLang;
    property Theme: String read fTheme write fTheme;
    property AppMode: integer read fAppMode write fAppMode;
    property First: boolean read fFirst write fFirst;
    property Splash: String read fSplash write fSplash;
    property MRUMax: integer read fMRUMax write fMRUMax;
    property ShortenCompPaths: boolean read fShortenCompPaths write fShortenCompPaths;
    property TranslateMsg: boolean read fTranslateMsg write fTranslateMsg;

    //Execution
    property MinOnRun: boolean read fMinOnRun write fMinOnRun;
    property ConsolePause: boolean read fConsolePause write fConsolePause;
    property BackUps: boolean read fBackup write fBackup;
    property AutoFormat: Boolean read fAutoFormat write fAutoFormat;
    property DeleteExe: boolean read fDeleteExe write fDeleteExe;
    property AutoOpen: integer read fAutoOpen write fAutoOpen;
    property AutoCheckUpdate: integer read fAutoCheckUpdate write fAutoCheckUpdate;
    property AutoLoadLast: boolean read fAutoLoadLast write fAutoLoadLast;
    property LastProject: String read fLastProject write fLastProject;
    property LastFiles: integer read fLastFiles write fLastFiles;
    property LastActive: integer read fLastActive write fLastActive;

    //Windows
    property MsgTabs: TTabPosition read fMsgTabs write fMsgTabs;
    property InterfaceFont: String read fInterfaceFont write fInterfaceFont;
    property InterfaceFontSize: integer read fInterfaceFontSize write fInterfaceFontSize;
    property ShowMenu: boolean read fShowMenu write fShowMenu;
    property ShowBars: boolean read fShowbars write fShowbars;
    property MultiLineTab: boolean read fMultiLineTab write fMultiLineTab;

    // TWindowPlacement parts
    property WindowState: TWindowState read fWindowState write fWindowState;
    property ReportWindowState: TWindowState read fReportWindowState write fReportWindowState;
    property ProjectWindowState: TWindowState read fProjectWindowState write fProjectWindowState;

    //Running Status Options
    property DefCpp: boolean read fDefCpp write fDefCpp;
    property OutputHeight: integer read fOutputHeight write fOutputHeight;
    property ShowLeftPages: boolean read fShowLeftPages write fShowLeftPages;
    property LeftActivePage: integer read fLeftActivePage write fLeftActivePage;
    property ProjectWidth: integer read fProjectWidth write fProjectWidth;
    property Statusbar: boolean read fStatusbar write fStatusbar;
    property FullScreen: boolean read fFullScr write fFullScr;
    property FindCols: String read fFindCols write fFindCols;
    property CompCols: String read fCompCols write fCompCols;

    //Toolbars
    property ToolbarMain: boolean read fToolbarMain write fToolbarMain;
    property ToolbarMainX: integer read fToolbarMainX write fToolbarMainX;
    property ToolbarMainY: integer read fToolbarMainY write fToolbarMainY;
    //property ToolbarMainH: integer read fToolbarMainH write fToolbarMainH;
    property ToolbarEdit: boolean read fToolbarEdit write fToolbarEdit;
    property ToolbarEditX: integer read fToolbarEditX write fToolbarEditX;
    property ToolbarEditY: integer read fToolbarEditY write fToolbarEditY;
    property ToolbarCompile: boolean read fToolbarCompile write fToolbarCompile;
    property ToolbarCompileX: integer read fToolbarCompileX write fToolbarCompileX;
    property ToolbarCompileY: integer read fToolbarCompileY write fToolbarCompileY;
    property ToolbarProject: boolean read fToolbarProject write fToolbarProject;
    property ToolbarProjectX: integer read fToolbarProjectX write fToolbarProjectX;
    property ToolbarProjectY: integer read fToolbarProjectY write fToolbarProjectY;
    property ToolbarSpecials: boolean read fToolbarSpecials write fToolbarSpecials;
    property ToolbarSpecialsX: integer read fToolbarSpecialsX write fToolbarSpecialsX;
    property ToolbarSpecialsY: integer read fToolbarSpecialsY write fToolbarSpecialsY;
    property ToolbarSearch: boolean read fToolbarSearch write fToolbarSearch;
    property ToolbarSearchX: integer read fToolbarSearchX write fToolbarSearchX;
    property ToolbarSearchY: integer read fToolbarSearchY write fToolbarSearchY;
    property ToolbarClasses: boolean read fToolbarClasses write fToolbarClasses;
    property ToolbarClassesX: integer read fToolbarClassesX write fToolbarClassesX;
    property ToolbarClassesY: integer read fToolbarClassesY write fToolbarClassesY;
    property ToolbarCompilers: boolean read fToolbarCompilers write fToolbarCompilers;
    property ToolbarCompilersX: integer read fToolbarCompilersX write fToolbarCompilersX;
    property ToolbarCompilersY: integer read fToolbarCompilersY write fToolbarCompilersY;

    // file associations
    property AssociateC: boolean read fAssociateC write fAssociateC;
    property AssociateCpp: boolean read fAssociateCpp write fAssociateCpp;
    property AssociateCxx: boolean read fAssociateCxx write fAssociateCxx;
    property AssociateH: boolean read fAssociateH write fAssociateH;
    property AssociateHpp: boolean read fAssociateHpp write fAssociateHpp;
    property AssociateHxx: boolean read fAssociateHxx write fAssociateHxx;
    property AssociateDev: boolean read fAssociateDev write fAssociateDev;
    property AssociateRc: boolean read fAssociateRc write fAssociateRc;
    property AssociateTemplate: boolean read fAssociateTemplate write fAssociateTemplate;
    property AssociateF77: boolean read fAssociateF77 write fAssociateF77;
    property AssociateF90: boolean read fAssociateF90 write fAssociateF90;

    property CheckAssocs: boolean read fCheckAssocs write fCheckAssocs;

    // tip of the day
    property ShowTipsOnStart: boolean read fShowTipsOnStart write fShowTipsOnStart;
    property LastTip: integer read fLastTip write fLastTip;

    // progress window
    property ShowProgress: boolean read fShowProgress write fShowProgress;
    property AutoCloseProgress: boolean read fAutoCloseProgress write fAutoCloseProgress;

    //  Printer
    property PrintColors: boolean read fPrintColors write fPrintColors;
    property PrintHighlight: boolean read fPrintHighlight write fPrintHighlight;
    property PrintWordWrap: boolean read fPrintWordWrap write fPrintWordWrap;
    property PrintLineNumbers: boolean read fPrintLineNumbers write fPrintLineNumbers;
    property PrintLineNumbersMargins: boolean read fPrintLineNumbersMargins write fPrintLineNumbersMargins;

    // General debugging options
    property WatchHint: boolean read fWatchHint write fWatchHint;
    property WatchLocals: boolean read fWatchLocals write fWatchLocals;
    property UseATTSyntax: boolean read fUseATTSyntax write fUseATTSyntax;
    property ShowCPUSignal: boolean read fShowCPUSignal write fShowCPUSignal;
    property CPURegisterCol1: integer read fCPURegisterCol1 write fCPURegisterCol1;
    property CPURegisterCol2: integer read fCPURegisterCol2 write fCPURegisterCol2;
    property CPURegisterCol3: integer read fCPURegisterCol3 write fCPURegisterCol3;

    // Search preferences
    property CaseSensitive: boolean read fCaseSensitive write fCaseSensitive;
    property Wholewords: boolean read fWholewords write fWholewords;
    property PromptReplace: boolean read fPromptReplace write fPromptReplace;
    property ScopeIsSelected: boolean read fScopeIsSelected write fScopeIsSelected;
    property OriginEntireScope: boolean read fOriginEntireScope write fOriginEntireScope;
    property SearchWhere: integer read fSearchWhere write fSearchWhere;
    property DirBackward: boolean read fDirBackward write fDirBackward;

    // Floating windows
    property ProjectFloat: boolean read fProjectFloat write fProjectFloat;
    property MessageFloat: boolean read fMessageFloat write fMessageFloat;
  end;

function devData: TdevData;

procedure CreateOptions;
procedure SaveOptions;
procedure DestroyOptions;
procedure RemoveOptionsDir(const Directory: String);

var
  devCompilerSets: TdevCompilerSets = nil;
  devDirs: TdevDirs = nil;
  devEditor: TdevEditor = nil;
  devCodeCompletion: TdevCodeCompletion = nil;
  devClassBrowsing: TdevClassBrowsing = nil;
  devExternalPrograms: TdevExternalPrograms = nil;
  devFormatter: TdevFormatter = nil;

procedure ApplyColorSchemeToLexer(Lexer: TecSyntAnalyzer; Adapter: TATAdapterEControl);

// 把 devEditor.ColorScheme 中的颜色元素应用到指定 Lexer 的各个语法格式。
// SpaceBG：某元素自身背景色为 clNone 时使用的回退背景色（传 clNone 表示不回退）。
// 由 EditorOptFrm（编辑器选项对话框中的预览编辑框）和 ApplyColorSchemeToAllEditors（主窗口中所有打开的编辑器）共用。
procedure ApplyColorElemsToLexer(Lexer: TecSyntAnalyzer; SpaceBG: TColor);

// 把当前配色方案(devEditor.ColorScheme)应用到当前打开的所有编辑器(MainForm.EditorList)。
procedure ApplyColorSchemeToAllEditors;

implementation

uses
  MultiLangSupport, DataFrm, SysUtils, StrUtils, Forms, main, compiler, Controls, utils,
  FileAssocs, TypInfo, DateUtils, Types, FileUtil, EditorList;

procedure CreateOptions;
//var
//  I: integer;
begin
  if not Assigned(devDirs) then
    devDirs := TdevDirs.Create;
  devDirs.LoadSettings;

  if not Assigned(devCompilerSets) then
    devCompilerSets := TdevCompilerSets.Create;

  // load available compiler sets on first run
//  if devData.First then begin
    // Obtain list of default compilers
//    devCompilerSets.FindSets;
//    devCompilerSets.SaveSets; // save everything to disk
//  end;

  if not assigned(devEditor) then
    devEditor := TdevEditor.Create;
  devEditor.LoadSettings;

  if not Assigned(devCodeCompletion) then
    devCodeCompletion := TdevCodeCompletion.Create;
  devCodeCompletion.LoadSettings;

  if not Assigned(devClassBrowsing) then
    devClassBrowsing := TdevClassBrowsing.Create;
  devClassBrowsing.LoadSettings;

  if not Assigned(devExternalPrograms) then
    devExternalPrograms := TdevExternalPrograms.Create;

  if not Assigned(devFormatter) then
    devFormatter := TdevFormatter.Create;
  devFormatter.LoadSettings;
end;

procedure SaveOptions;
begin
  devData.BeginBatch;
  try
    devData.SaveSelf;
    devDirs.SaveSettings;
    // devCompiler saving is done by CompOptForm
    devEditor.SaveSettings;
    devCodeCompletion.SaveSettings;
    devClassBrowsing.SaveSettings;
    devExternalPrograms.SaveSettings;
    devFormatter.SaveSettings;
  finally
    devData.EndBatch; // flush all writes in a single file operation
  end;
end;

procedure DestroyOptions;
begin
  devData.Free;
  FreeAndNil(devDirs);
  FreeAndNil(devCompilerSets);
  FreeAndNil(devEditor);
  FreeAndNil(devCodeCompletion);
  FreeAndNil(devClassBrowsing);
  FreeAndNil(devExternalPrograms);
  FreeAndNil(devFormatter);
end;

procedure RemoveOptionsDir(const Directory: String);
{$IFDEF MSWINDOWS}
var
  fostruct: SHFILEOPSTRUCT;
  DirFrom, DirTo: array[0..MAX_PATH] of char;
begin
  fostruct := default(SHFILEOPSTRUCT);
  DirFrom := '';
  DirTo := '';

  // Copy to Backup, then delete original (Windows: SHFileOperation)
  FillChar(DirFrom, Sizeof(DirFrom), 0);
  StrPCopy(DirFrom, Directory);
  FillChar(DirTo, Sizeof(DirFrom), 0);
  StrPCopy(DirTo, ExcludeTrailingBackslash(Directory) + 'Backup' + pd);
  FillChar(fostruct, Sizeof(fostruct), 0);
  with fostruct do begin
    Wnd := 0;
    pFrom := @DirFrom;
    pTo := @DirTo;
    wFunc := FO_COPY;
    fFlags := FOF_ALLOWUNDO or FOF_SILENT or FOF_NOCONFIRMATION;
  end;
  SHFileOperation(fostruct);
  FillChar(fostruct, Sizeof(fostruct), 0);
  with fostruct do begin
    Wnd := 0;
    pFrom := @DirFrom;
    wFunc := FO_DELETE;
    fFlags := FOF_ALLOWUNDO or FOF_SILENT or FOF_NOCONFIRMATION;
  end;
  SHFileOperation(fostruct);
end;
{$ELSE}
// Linux: use FreePascal's FileUtil.DeleteDirectory recursively
var
  BackupDir: String;
begin
  BackupDir := IncludeTrailingPathDelimiter(Directory) + 'Backup' + pd;
  // Rename original directory to Backup
  if DirectoryExists(Directory) then begin
    if DirectoryExists(BackupDir) then
      DeleteDirectory(BackupDir, False);
    RenameFile(Directory, BackupDir);
  end;
end;
{$ENDIF}

var
  fdevDataSingleton: TdevData = nil;

function devData: TdevData;
begin
  if not Assigned(fdevDataSingleton) and not Application.Terminated then
    fdevDataSingleton := TdevData.Create;
  result := fdevDataSingleton; // assume constructor succeeded
end;

constructor TdevData.Create;
begin
  inherited Create;
  fWindowState := TWindowState.Create;
  fReportWindowState := TWindowState.Create;
  fProjectWindowState := TWindowState.Create;
  SettoDefaults;
end;

destructor TdevData.Destroy;
begin
  fWindowState.Free;
  fReportWindowState.Free;
  fProjectWindowState.Free;
  fdevDataSingleton := nil;
  inherited;
end;

procedure TdevData.SettoDefaults;
var
  osinfo: TOSVersionInfo;

  function getAssociation(I: integer): Boolean;
  begin
    Result := CheckFiletype('.' + Associations[I, 0],
      'DevCpp.' + Associations[I, 0],
      Associations[I, 1],
      'open',
      Application.Exename + ' "%1"');
  end;

begin
  fFirst := TRUE;
  fLang  := '';  //'English.lng';
  fTheme := '';
  fAppMode := 1; //(0-Default, 1-AllowDark, 2-ForceDark, 3-ForceLight)
  fFindCols := '75, 75, 120, 150';
  fCompCols := '75, 75, 120, 150';
  fMsgTabs := tpTop; // Top
  fMRUMax := 15;
  fMinOnRun := FALSE;
  fBackup := FALSE;
  fAutoFormat := TRUE;
  fDeleteExe := FALSE;
  fAutoOpen := 2; // Reopen
  fAutoLoadLast := FALSE; // Auto Load Last project or files
  fAutoCheckUpdate := -1; // not set value 0/1 yet
  fLastProject := ''; // Last closed project;
  fLastFiles := 0;    // Last closed files;
  fLastActive:= -1;   // Last active file;

  fShowLeftPages := TRUE;
  fLeftActivePage := 1;
  fProjectWidth := 161;
  fOutputHeight := 183;
  fStatusbar := TRUE;
  fShowMenu := TRUE;
  fShowBars := FALSE;
  fMultiLineTab := TRUE;
  fDefCpp := TRUE;
  fdblFiles := FALSE;
  fConsolePause := TRUE;
  fShortenCompPaths := False;
  fTranslateMsg := TRUE;

  // TODO: retrieve directly from visual editor
  fToolbarMain := TRUE;
  fToolbarMainX := 11;
  fToolbarMainY := 2;
  //fToolbarMainH := 40;
  fToolbarEdit := TRUE;
  fToolbarEditX := 166;
  fToolbarEditY := 2;
  fToolbarCompile := TRUE;
  fToolbarCompileX := 414;
  fToolbarCompileY := 2;
  fToolbarCompilers := TRUE;
  fToolbarCompilersX := 636;
  fToolbarCompilersY := 2;

  fToolbarProject := TRUE;
  fToolbarProjectX := 11; //373;
  fToolbarProjectY := 30; //2;
  fToolbarClasses := TRUE;
  fToolbarClassesX := 95;
  fToolbarClassesY := 30;
  fToolbarSearch := TRUE;
  fToolbarSearchX := 233;
  fToolbarSearchY := 2;

  fToolbarSpecials := TRUE;
  fToolbarSpecialsX := 373; //11;
  fToolbarSpecialsY := 2;   //30;

  // Office 2007 / Vista support
  osinfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(osinfo);
  if (Screen.Fonts.IndexOf('Segoe UI') <> -1) and (osinfo.dwMajorVersion >= 6) then begin
    fInterfaceFontSize := 11;
    fInterfaceFont := 'Segoe UI';
  end else begin
    fInterfaceFontSize := 11;
    fInterfaceFont := 'MS Sans Serif';
  end;

  //read associations set by installer as defaults
  fAssociateC := getAssociation(0);
  fAssociateCpp := getAssociation(1);
  fAssociateCxx := getAssociation(2);
  fAssociateH := getAssociation(3);
  fAssociateHpp := getAssociation(4);
  fAssociateHxx := getAssociation(5);
  fAssociateDev := getAssociation(6);
  fAssociateRc := getAssociation(7);
  fAssociateTemplate := getAssociation(8);
  fCheckAssocs := TRUE;

  fShowTipsOnStart := FALSE; // due to popular demand
  fLastTip := 0;
  fShowProgress := TRUE;
  fAutoCloseProgress := FALSE;
  fPrintColors := TRUE;
  fPrintHighlight := TRUE;
  fPrintWordWrap := FALSE;
  fPrintLineNumbers := TRUE;
  fPrintLineNumbersMargins := FALSE;

  // Debug stuff
  fWatchLocals := true;
  fWatchHint := false;
  fUseATTSyntax := true;
  fShowCPUSignal := true;
  fCPURegisterCol1 := 70;
  fCPURegisterCol2 := 104;
  fCPURegisterCol3 := 10;

  // Search stuff
  fCaseSensitive := false;
  fWholewords := false;
  fPromptReplace := false;
  fScopeIsSelected := false;
  fOriginEntireScope := false;
  fSearchWhere := 1;
  fDirBackward := false;

  // Floating windows
  fMessageFloat := false;
  fProjectFloat := false;
end;

{ TWindowState }

constructor TWindowState.Create;
begin
  inherited Create;
  fStruct.length := sizeof(WINDOWPLACEMENT);
  flags := -1; // -1 means GetWindowPlacement isn't called yet
end;

procedure TWindowState.GetPlacement(Source: HWND);
begin
  if GetWindowPlacement(Source, @fStruct) then begin
    fShowCmd := fStruct.showCmd;
    fFlags := fStruct.flags;

    // Attempt to correct for Aero Snap. GetWindowPlacement ignores this functionality
    // Only do that if the window is not minimized/maximized
    if fStruct.showCmd = SW_SHOWNORMAL then
      GetWindowRect(Source, fStruct.rcNormalPosition);

    // Apply fixed aero values
    fLeft := fStruct.rcNormalPosition.Left;
    fTop := fStruct.rcNormalPosition.Top;
    fRight := fStruct.rcNormalPosition.Right;
    fBottom := fStruct.rcNormalPosition.Bottom;
  end;
end;

procedure TWindowState.SetPlacement(Destination: HWND);
begin
  if flags <> -1 then begin
    fStruct.rcNormalPosition.Left := fLeft;
    fStruct.rcNormalPosition.Top := fTop;
    fStruct.rcNormalPosition.Right := fRight;
    fStruct.rcNormalPosition.Bottom := fBottom;
    fStruct.showCmd := fShowCmd;
    fStruct.flags := fFlags;
    SetWindowPlacement(Destination, @fStruct);
  end;
end;

{ TdevCompilerSet }

constructor TdevCompilerSet.Create;
begin
  inherited Create;

  // Create stuff on heap
  fBinDir := TStringList.Create;
  fCDir := TStringList.Create;
  fCppDir := TStringList.Create;
  fLibDir := TStringList.Create;
  fOptions := TList.Create;

  // Misc.
  fDefInclude := TStringList.Create;
  fDefines := TStringList.Create;

  // Do not set properties yet, as we don't know where to look for gcc.exe

  // Add default options list though, no info needed
  SetOptions;
end;

constructor TdevCompilerSet.Create(const CompilerFolder: String);
begin
  inherited Create;

  // Create stuff on heap
  fBinDir := TStringList.Create;
  fCDir := TStringList.Create;
  fCppDir := TStringList.Create;
  fLibDir := TStringList.Create;
  fOptions := TList.Create;

  // Misc.
  fDefInclude := TStringList.Create;
  fDefines := TStringList.Create;

  // Set properties, assume bin\gcc.exe exists (it is our helper)
  SetProperties(CompilerFolder + pd + 'bin', GCC_PROGRAM);

  // Depending on properties, set default exes
  SetExecutables;

  // Again depending on properties, set directories
  fFolder := CompilerFolder;
  SetDirectories;

  // Same story, user input
  SetUserInput;

  // load options
  SetOptions;
end;

destructor TdevCompilerSet.Destroy;
var
  I: integer;
begin
  // delete options
  for I := 0 to fOptions.Count - 1 do begin
    if Assigned(PCompilerOption(fOptions[I])^.Choices) then
      PCompilerOption(fOptions[I])^.Choices.Free;
    Dispose(PCompilerOption(fOptions[I]));
  end;
  fOptions.Free;

  // delete directories
  fBinDir.Free;
  fCDir.Free;
  fCppDir.Free;
  fLibDir.Free;

  // Etc.
  fDefInclude.Free;
  fDefines.Free;

  inherited;
end;

procedure TdevCompilerSet.Assign(Source: TPersistent);
var
  input: TdevCompilerSet;
begin
  input := TdevCompilerSet(Source);

  // Executables
  fgccName := input.fgccName;
  fgppName := input.fgppName;
  fmakeName := input.fmakeName;
  fgdbName := input.fgdbName;
  fwindresName := input.windresName;
  fgprofName := input.fgprofName;

  // Directories
  fBinDir.Assign(input.fBinDir);
  fCDir.Assign(input.fCDir);
  fCppDir.Assign(input.fCppDir);
  fLibDir.Assign(input.fLibDir);

  // Misc. properties
  fDumpMachine := input.fDumpMachine;
  fVersion := input.fVersion;
  fType := input.fType;
  fName := input.fName;
  fFolder := input.fFolder;
  fDefInclude.Assign(input.fDefInclude);
  fDefines.Assign(input.fDefines);

  // User input
  fCompAdd := input.fCompAdd;
  fCompOpt := input.fCompOpt;
  fLinkAdd := input.fLinkAdd;
  //fAutoLink:= input.fAutoLink;
  flinkOpt := input.fLinkOpt;

  // Option list
  INIOptions := input.INIOptions;
end;

procedure TdevCompilerSet.SetProperties(const BinDir, BinFile: String);
var
  output {,DummyFileName,Cmd}: String;
  //elimPos1, DelimPos2 {,DummyHandle}: integer;
begin
  // GCC binaries not found../
  if not FileExists(BinDir + pd + BinFile) then
    Exit;

  //Obtain compiler version by command "gcc -dumpversion"
  fVersion := GetCompilerOutput(BinDir + pd, BinFile, '-dumpfullversion');

  // Obtain compiler target by command "gcc -dumpmachine" and "gcc --version"
  fDumpMachine := GetCompilerOutput(BinDir + pd, BinFile, '-dumpmachine');
  //The target triplet consists of three fields that are separated by a hyphen (-).
  //Name of CPU family/model (eg. x86_64), The vendor (eg. linux) and Operating system name (eg. gnu)
  //MinGW: mingw32 or i686-w64-mingw32
  //MinGW-w64: x86_64-w64-mingw32
  //TDM-GCC-64: x86_64-w64-mingw32
  if fName = '' then begin
    if ContainsStr(fDumpMachine, 'x86_64-w64-mingw32') then
      fName := 'MinGW64 GCC ' + fVersion   //maybe MinGW-w64 or TDM-GCC. Need to check further
    else if ContainsStr(fDumpMachine, 'mingw32') then
      fName := 'MinGW32 GCC ' + fVersion
    else
      fName := 'Unknown ' + fVersion;
    output := GetCompilerOutput(BinDir + pd, BinFile, '--version');
    //MinGW: gcc (MinGW.org GCC Build-2) 9.2.0
    //MinGW-w64: gcc (x86_64-win32-seh-rev0, Built by MinGW-W64 project) 8.1.0
    //TDM-GCC-64: gcc (tdm64-1) 9.2.0
    if ContainsStr(output, 'tdm') then
      fName := 'TDM-GCC ' + fVersion;
  end;
  fVersion := GetCompilerOutput(BinDir + pd, BinFile, '-dumpversion');


  //In previous verion, get compiler name and version by command "gcc -v".
  //Discarded by Anbangli

{  // Obtain version number and compiler distro etc
  output := GetCompilerOutput(BinDir + pd, BinFile, '-v');
  DelimPos1 := Pos('gcc version ', output);
  if DelimPos1 > 0 then
    Inc(DelimPos1, Length('gcc version '));
  if DelimPos1 = 0 then begin   //'gcc 版本 13.2.0'
    DelimPos1 := Pos('gcc ', output);
    if DelimPos1 = 0 then
      Exit; // unknown binary
    while (DelimPos1 <= Length(output)) and not CharInSet(output[DelimPos1], [#48..#57]) do
      Inc(DelimPos1);
  end;

  // Find version number
//  Inc(DelimPos1, Length('gcc version '));
  DelimPos2 := DelimPos1;
  while (DelimPos2 <= Length(output)) and not CharInSet(output[DelimPos2], [#0..#32]) do
    Inc(DelimPos2);
  fVersion := Copy(output, DelimPos1, DelimPos2 - DelimPos1);

  // Set compiler folder
//  DelimPos1 := RPos(pd, BinDir);
//  if DelimPos1 > 0 then
//    fFolder := Copy(BinDir, 1, DelimPos1 - 1);

  // Find compiler builder
  DelimPos1 := DelimPos2;
  while (DelimPos1 <= Length(output)) and not (output[DelimPos1] = '(') do
    Inc(DelimPos1);
  while (DelimPos2 <= Length(output)) and not (output[DelimPos2] = ')') do
    Inc(DelimPos2);
  fType := Copy(output, DelimPos1 + 1, DelimPos2 - DelimPos1 - 1);

  // Assemble user friendly name if we don't have one yet
  if fName = '' then begin
    if ContainsStr(fType, 'tdm64') then
      fName := 'TDM-GCC ' + fVersion
    else if ContainsStr(fType, 'tdm') then
      fName := 'TDM-GCC ' + fVersion
    //else if ContainsStr(fType, 'MinGW-W64') or ContainsStr(fType, 'MinGW-w64')then
    //  fName := 'MinGW-w64 ' + fVersion
    else if ContainsStr(fType, 'x86_64-') and ContainsStr(fType, 'MinGW-')then
    //gcc version 8.1.0 (x86_64-win32-seh-rev0, Built by MinGW-W64 project)
    //gcc version 11.4.0 (x86_64-posix-seh, Built by MinGW-Builds project)
    //gcc version 13.2.0 (x86_64-posix-seh-rev0, Built by MinGW-Builds project)
      fName := 'MinGW-w64 GCC ' + fVersion
    else if ContainsStr(fType, 'MinGW') then
    //gcc version 8.1.0 (i686-posix-dwarf-rev0, Built by MinGW-W64 project)
    //gcc version 9.2.0 (MinGW.org GCC Build-2)
      fName := 'MinGW GCC ' + fVersion;
  end;

  // Obtain compiler target
  fDumpMachine := GetCompilerOutput(BinDir + pd, BinFile, '-dumpmachine');
}
  // Find default include directories
  {if FileExists(BinDir + pd + "cpp.exe") then begin
   output := GetCompilerOutput(BinDir + pd,"cpp.exe","-v");
   DelimPos1 := Pos("#include <...> search starts here:",output);
   if DelimPos1 > 0 then begin
    DelimPos2 := ("End of search list.",output);
    if DelimPos2 > 0 then begin
     S := Copy(output,DelimPos1,DelimPos2-DelimPos1);
     fDefInclude.Clear;
     ExtractStrings([#10],[],PChar(S),fDefInclude);
    end;
   end;
  end;}

  // Obtain default includes when changing current file?
  // Don't use CommaText:
  // http://stackoverflow.com/questions/1335027/delphi-stringlist-delimiter-is-always-a-space-character-even-if-delimiter-is-se
//  output := GetCompilerOutput(BinDir + pd, 'cpp.exe', '-dM -E -x c++ -std=gnu++11 NUL');
  // TODO: use command of current file
//  ExtractStrings([#10], [], PChar(output), fDefines);
end;

procedure TdevCompilerSet.SetExecutables;
begin
  // Set executables
  fgccName := GCC_PROGRAM;
  fgppName := GPP_PROGRAM;
  fgdbName := GDB_PROGRAM;
  fmakeName := MAKE_PROGRAM;
  fwindresName := WINDRES_PROGRAM;
  fgprofName := GPROF_PROGRAM;
end;

procedure TdevCompilerSet.SetDirectories;
  procedure AddExistingDirectory(var list: TStringList; const Directory: String);
  begin
    if DirectoryExists(Directory) then
      list.Add(Directory);
  end;
begin
  // Add both the default and the autoconf directories
  AddExistingDirectory(fBinDir, fFolder + pd + 'bin');              // ./bin
  AddExistingDirectory(fBinDir, fFolder + pd + 'opt'+ pd + 'bin');  // ./opt/bin

  //AddExistingDirectory(fLibDir, fFolder + pd + 'lib');
  //AddExistingDirectory(fCDir, fFolder + pd + 'include');
  //AddExistingDirectory(fCppDir, fFolder + pd + 'include');
  AddExistingDirectory(fDefInclude, fFolder + pd + 'include');

  // Try to obtain our target/autoconf folder
  if fDumpMachine <> '' then begin
    AddExistingDirectory(fBinDir, fFolder + pd + fDumpMachine + pd + 'bin');
    //AddExistingDirectory(fLibDir, fFolder + pd + fDumpMachine + pd + 'lib');
    //AddExistingDirectory(fLibDir, fFolder + pd + 'opt' + pd + 'lib');    // by Anbang LI

    // Regular include folder
    //AddExistingDirectory(fCDir, fFolder + pd + fDumpMachine + pd + 'include');
    //AddExistingDirectory(fCppDir, fFolder + pd + fDumpMachine + pd + 'include');
    AddExistingDirectory(fDefInclude, fFolder + pd + fDumpMachine + pd + 'include');

    // Other include folder?
    //AddExistingDirectory(fCDir,
    //  fFolder + pd + 'lib' + pd + 'gcc' + pd + fDumpMachine + pd + fVersion + pd + 'include');
    //AddExistingDirectory(fCppDir,
    //  fFolder + pd + 'lib' + pd + 'gcc' + pd + fDumpMachine + pd + fVersion + pd + 'include');

    // C++ only folder
    //AddExistingDirectory(fCppDir,
    //  fFolder + pd + 'lib' + pd + 'gcc' + pd + fDumpMachine + pd + fVersion + pd + 'include' + pd + 'c++');
  end;
    //AddExistingDirectory(fCDir,  fFolder + pd + 'opt' + pd + 'include');
    //AddExistingDirectory(fCppDir,fFolder + pd + 'opt' + pd + 'include');
    AddExistingDirectory(fDefInclude, fFolder + pd + 'opt' + pd + 'include');

end;

procedure TdevCompilerSet.SetUserInput;
begin
  // User input
  fCompAdd := FALSE;
  fLinkAdd := FALSE; //TRUE;
  fCompOpt := '';
  //fAutoLink:= FALSE;

  fLinkOpt := '';
  // MinGW64 & MinGW32 requires special treatment
//  if ContainsStr(fName, 'MinGW') then
//    fLinkOpt := '-static-libstdc++ -static-libgcc'
//  else
//    fLinkOpt := '-static-libgcc';
end;

procedure TdevCompilerSet.SetOptions;
var
  sl: TStringList;
begin

  //AddOption(Name, Section: integer; IsC, IsCpp, IsLinker: boolean;
  //    Value: integer; const Setting: String; Choices: TStringList);

  // C options
  AddOption(ID_COPT_ANSIC, ID_COPT_GRP_C, True, True, False, 0, '-ansi', nil);   //general
  AddOption(ID_COPT_NOASM, ID_COPT_GRP_C, True, True, False, 0, '-fno-asm', nil);
  AddOption(ID_COPT_TRADITIONAL, ID_COPT_GRP_C, True, True, False, 0, '-traditional-cpp', nil);

  // Optimization
  sl := TStringList.Create;
  sl.Add('none='); // /!\ Must contain a starting empty value in order to do not have always to pass the parameter
  sl.Add('This CPU=native');
  sl.Add('i386=i386');
  sl.Add('i486=i486');
  sl.Add('i586=i586');
  sl.Add('i686=i686');
  sl.Add('Pentium=pentium');
  sl.Add('Pentium MMX=pentium-mmx');
  sl.Add('Pentium Pro=pentiumpro');
  sl.Add('Pentium 2=pentium2');
  sl.Add('Pentium 3=pentium3');
  sl.Add('Pentium 4=pentium4');
  sl.Add('Conroe=core2');
  sl.Add('Nehalem=corei7');
  sl.Add('Sandy=corei7-avx');
  sl.Add('K6=k6');
  sl.Add('K6-2=k6-2');
  sl.Add('K6-3=k6-3');
  sl.Add('Athlon=athlon');
  sl.Add('Athlon Tbird=athlon-tbird');
  sl.Add('Athlon 4=athlon-4');
  sl.Add('Athlon XP=athlon-xp');
  sl.Add('Athlon MP=athlon-mp');
  sl.Add('K8=k8');
  sl.Add('K8 Rev.E=k8-sse3');
  sl.Add('K10=barcelona');
  sl.Add('Bulldozer=bdver1');
  AddOption(ID_COPT_ARCH, ID_COPT_GRP_CODEGEN, True, True, False, 0, '-march=', sl);   //discard. not show

  // Optimization
  sl := TStringList.Create;
  sl.Add('none='); // /!\ Must contain a starting empty value in order to do not have always to pass the parameter
  sl.Add('This CPU=native');
  sl.Add('i386=i386');
  sl.Add('i486=i486');
  sl.Add('i586=i586');
  sl.Add('i686=i686');
  sl.Add('Pentium=pentium');
  sl.Add('Pentium MMX=pentium-mmx');
  sl.Add('Pentium Pro=pentiumpro');
  sl.Add('Pentium 2=pentium2');
  sl.Add('Pentium 3=pentium3');
  sl.Add('Pentium 4=pentium4');
  sl.Add('Conroe=core2');
  sl.Add('Nehalem=corei7');
  sl.Add('Sandy=corei7-avx');
  sl.Add('K6=k6');
  sl.Add('K6-2=k6-2');
  sl.Add('K6-3=k6-3');
  sl.Add('Athlon=athlon');
  sl.Add('Athlon Tbird=athlon-tbird');
  sl.Add('Athlon 4=athlon-4');
  sl.Add('Athlon XP=athlon-xp');
  sl.Add('Athlon MP=athlon-mp');
  sl.Add('K8=k8');
  sl.Add('K8 Rev.E=k8-sse3');
  sl.Add('K10=barcelona');
  sl.Add('Bulldozer=bdver1');
  AddOption(ID_COPT_TUNE, ID_COPT_GRP_CODEGEN, True, True, False, 0, '-mtune=', sl);   //discard. not show

  // Built-in processor functions
  sl := TStringList.Create;
  sl.Add('none='); // /!\ Must contain a starting empty value in order to do not have always to pass the parameter
  sl.Add('MMX=mmx');
  sl.Add('3D Now=3dnow');
  sl.Add('SSE=sse');
  sl.Add('SSE2=sse2');
  sl.Add('SSE3=sse3');
  sl.Add('SSSE3=ssse3');
  sl.Add('SSE4=sse4');
  sl.Add('SSE4A=sse4a');
  sl.Add('SSE4.1=sse4.1');
  sl.Add('SSE4.2=sse4.2');
  sl.Add('AVX=avx');
  sl.Add('FMA4=fma4');
  sl.Add('XOP=xop');
  sl.Add('AES=aes');
  AddOption(ID_COPT_BUILTINPROC, ID_COPT_GRP_CODEGEN, True, True, False, 0, '-m', sl);  //discard. not show

  // Optimization
  sl := TStringList.Create;
  sl.Add('none(0)=');
  sl.Add('Low(1)=1');
  sl.Add('Med(2)=2');
  sl.Add('High(3)=3');
  sl.Add('Highest (fast)=fast');
  sl.Add('Size (s)=s');
  sl.Add('Debug (g)=g');
  AddOption(ID_COPT_OPTIMIZE, ID_COPT_GRP_CODEGEN, True, True, False, 0, '-O', sl);

  // 32bit/64bit
  sl := TStringList.Create;
  sl.Add('auto=');
  sl.Add('32-bit=m32');
  sl.Add('64-bit=m64');
  AddOption(ID_COPT_PTRWIDTH, ID_COPT_GRP_CODEGEN, True, True, True, 0, '-', sl);

  // C Standards: see https://gcc.gnu.org/onlinedocs/gcc/C-Dialect-Options.html
  sl := TStringList.Create;
  sl.Add('auto='); // Passing nothing effectively lets the compiler decide
  sl.Add('ISO C90=c90');    //ISO C
  sl.Add('ISO C99=c99');
  sl.Add('ISO C11=c11');
  sl.Add('ISO C17=c17');
  sl.Add('ISO C23=c23');

  sl.Add('GNU C90=gnu90');  //GNU C
  sl.Add('GNU C99=gnu99');
  sl.Add('GNU C11=gnu11');
  sl.Add('GNU C17=gnu17');
  sl.Add('GNU C23=gnu23');
  AddOption(ID_COPT_STD, ID_COPT_GRP_CODEGEN, True, False, False, 0, '-std=', sl); //general

  // C++ Standards: see https://gcc.gnu.org/onlinedocs/gcc/C-Dialect-Options.html
  sl := TStringList.Create;
  sl.Add('auto='); // Passing nothing effectively lets the compiler decide
  sl.Add('ISO C++==c++98');  //ISO C++
  sl.Add('ISO C++11==c++11');
  sl.Add('ISO C++14==c++14');
  sl.Add('ISO C++17==c++17');
  sl.Add('ISO C++20==c++20');
  sl.Add('ISO C++23==c++23');
  sl.Add('ISO C++26==c++26');
  sl.Add('GNU C++==gnu++98'); //GNU C++
  sl.Add('GNU C++11==gnu++11');
  sl.Add('GNU C++14==gnu++14');
  sl.Add('GNU C++17==gnu++17');
  sl.Add('GNU C++20==gnu++20');
  sl.Add('GNU C++23==gnu++23');
  sl.Add('GNU C++26==gnu++26');
  AddOption(ID_COPT_STD, ID_COPT_GRP_CODEGEN, False, True, False, 0, '-std', sl); //general

  // Warnings, Errors, Profiling
//  AddOption(ID_COPT_WARNING, ID_INFO, True, True, False, 0, '-w', nil);   //ID_COPT_GRP_WARN
  AddOption(ID_COPT_WARNINGPLUS, ID_INFO, True, True, False, 1, '-Wall', nil);  //general
  AddOption(ID_COPT_WARNINGEX, ID_INFO, True, True, False, 1, '-Wextra', nil);  //general

  AddOption(ID_COPT_ISOCONFORM, ID_INFO, True, True, False, 1, '-pedantic', nil);
  //Strict ISO standard

  AddOption(ID_COPT_SHADOW, ID_INFO, True, True, False, 1, '-Wshadow', nil);  //Added by Anbang LI
  //Warn whenever a local variable or type declaration shadows another variable,
  //parameter, type, class member (in C++), or instance variable (in Objective-C)
  //or whenever a built-in function is shadowed.  [-Wshadow]

  //AddOption(ID_COPT_SYNTAXONLY, ID_INFO, True, True, False, 0, '-fsyntax-only', nil);  //discarded by Anbang LI

  //Warn if floating-point values are used in equality comparisons. [float-equal]
  AddOption(ID_COPT_FLOATEQUAL, ID_INFO, True, True, False, 1, '-Wfloat-equal', nil);  //Added by Anbang LI

  //Promote Warning "Variable uninitialized" to Error.
  AddOption(ID_COPT_UNINITIALIZED, ID_INFO, True, True, False, 1, '-Werror=uninitialized', nil); //added by Anbang LI

  //Promote Warning "function has no return" to Error.
  AddOption(ID_COPT_RETURNTYPE, ID_INFO, True, True, False, 1, '-Werror=return-type', nil); //added by Anbang LI

  //Regard using Variable-Length-Array as ERROR
  AddOption(ID_COPT_VLA, ID_INFO, True, True, False, 1, '-Werror=vla', nil);  //Added by Anbang LI

  //AddOption(ID_COPT_TREATASERROR, ID_INFO, True, True, False, 0, '-Werror', nil); //Make all warnings into errors.  //discarded by Anbang LI
  AddOption(ID_COPT_FAILONFIRST, ID_INFO, True, True, False, 0, '-Wfatal-errors', nil);  //stop for the first error
  AddOption(ID_COPT_ERRMAX10, ID_INFO, True, True, False, 0, '-fmax-errors=10', nil); //added by Anbang LI

  // Profiling
  AddOption(ID_COPT_PROFILE, ID_INFO, True, True, True, 0, '-pg', nil);         //general
  AddOption(ID_COPT_NOPIE, ID_INFO, True, True, True, 0, '-no-pie', nil);
  // option '-pg' should acompanied with '-no-pie'.

  // Linker
  AddOption(ID_COPT_OBJC, ID_COPT_LINKERTAB, False, False, True, 0, '-lobjc', nil);
  AddOption(ID_COPT_DEBUG, ID_COPT_LINKERTAB, True, True, True, 0, '-g3', nil); //general
  AddOption(ID_COPT_NOLIBS, ID_COPT_LINKERTAB, True, True, True, 0, '-nostdlib', nil);
  //AddOption(ID_COPT_WIN32, ID_COPT_LINKERTAB, True, True, True, 0, '-mwindows', nil);
  AddOption(ID_COPT_STRIP, ID_COPT_LINKERTAB, False, False, True, 0, '-s', nil);
  AddOption(ID_COPT_STATIC, ID_COPT_LINKERTAB, False, False, True, 0, '-static-libstdc++ -static-libgcc', nil);  //general //added by Anbang

  // Output
  AddOption(ID_COPT_MEM, ID_COPT_GRP_OUTPUT, True, True, False, 0, '-fverbose-asm', nil);
  AddOption(ID_COPT_ASSEMBLY, ID_COPT_GRP_OUTPUT, True, True, False, 0, '-S', nil);
  AddOption(ID_COPT_PIPES, ID_COPT_GRP_OUTPUT, True, True, False, 1, '-pipe', nil);

end;

procedure TdevCompilerSet.AddOption(Name, Section: integer; IsC, IsCpp, IsLinker: boolean; Value: integer; const
  Setting: String; Choices: TStringList);
var
  option: PCompilerOption;
begin
  option := New(PCompilerOption);
  option^.Name := Name;
  option^.Section := Section;
  option^.IsC := IsC;
  option^.IsCpp := IsCpp;
  option^.IsLinker := IsLinker;
  option^.Value := Value;
  option^.Setting := Setting;
  option^.Choices := Choices;
  fOptions.Add(option);
end;

function TdevCompilerSet.GetOption(const Option: String): Char;
var
  OptionStruct: PCompilerOption;
  OptionIndex: integer;
begin
  OptionStruct := default(PCompilerOption);
  OptionIndex := 0;
  if FindOption(Option, OptionStruct, OptionIndex) then
    result := ValueToChar[OptionStruct^.Value]
  else
    result := '0';
end;

function TdevCompilerSet.FindOption(const Option: String; var opt: PCompilerOption; var Index: integer): boolean;
var
  I: integer;
begin
  Result := False;
  for I := 0 to fOptions.Count - 1 do
    if SameStr(PCompilerOption(fOptions[I])^.Setting, Option) then begin
      opt := PCompilerOption(fOptions[I]);
      Index := I;
      Result := True;
      Break;
    end;
end;

function TdevCompilerSet.GetINIOptions: String;
var
  I: integer;
begin
  Result := '';
  for I := 0 to fOptions.Count - 1 do
    Result := Result + ValueToChar[PCompilerOption(fOptions[I])^.Value];
end;

procedure TdevCompilerSet.SetINIOptions(const value: String);
var
  I: integer;
begin
  for I := 0 to fOptions.Count - 1 do
    if I < Length(value) then
      PCompilerOption(fOptions[I])^.Value := CharToValue(value[I + 1]);
end;

procedure TdevCompilerSet.SetOption(const Option: String; Value: Char);
var
  OptionStruct: PCompilerOption = nil;
  OptionIndex: integer = 0;
begin
  if FindOption(Option, OptionStruct, OptionIndex) then
    SetOption(Option, Value);
end;

procedure TdevCompilerSet.SetOption(Option: PCompilerOption; Value: char);
begin
  Option^.Value := CharToValue(Value);
end;

function TdevCompilerSet.GetCompilerOutput(const BinDir, BinFile, Input: String): String;
begin
  result := Trim(RunAndGetOutput(BinDir + pd + BinFile + ' ' + Input, BinDir, nil, nil, false))
end;

function TdevCompilerSet.ValidateDirs: boolean;
var
  msg, goodbin, badbin, goodlib, badlib, goodinc, badinc, goodinccpp, badinccpp: String;

  procedure CheckDirs(dirlist: TStringList; var gooddirs: String; var baddirs: String);
  var
    i: integer;
  begin
    gooddirs := '';
    baddirs := '';

    for I := 0 to dirlist.Count - 1 do begin
      if not DirectoryExists(dirlist[i]) then begin
        if Length(baddirs) > 0 then
          baddirs := baddirs + ';' + dirlist[i]
        else
          baddirs := dirlist[i];
      end else begin
        if Length(gooddirs) > 0 then
          gooddirs := gooddirs + ';' + dirlist[i]
        else
          gooddirs := dirlist[i];
      end;
    end;
  end;

  procedure RemoveDirs(var dirlist: TStringList; baddirs: String);
  var
    i, index: integer;
    baddirlist: TStringList;
  begin
    baddirlist := TStringList.Create;
    try
      ExtractStrings([';'], [], PChar(baddirs), baddirlist);
      for I := 0 to baddirlist.Count - 1 do begin
        index := dirlist.IndexOf(baddirlist[i]);
        if index <> -1 then
          dirlist.Delete(index);
      end;
    finally
      baddirlist.Free;
    end;
  end;

  procedure AddUnique(var list: TStringList; const entry: String);
  begin
    if (list.IndexOf(entry) = -1) and DirectoryExists(entry) then
      list.Add(entry);
  end;

begin
  result := true;

  // Check if we can find the directories the user pointed to
  msg := '';
  goodbin := '';
  badbin  := '';
  goodlib := '';
  badlib  := '';
  goodinc := '';
  badinc  := '';
  goodinccpp := '';
  badinccpp  := '';

  if fBinDir.Count > 0 then begin // we need some bin dir, so treat count=0 as an error too
    CheckDirs(fBinDir, goodbin, badbin);
    if badbin <> '' then begin
      msg := msg + Format(Lang[ID_COMPVALID_DIRNOTFOUND], [Lang[ID_COMPVALID_BINARY]]) + #13#10;
      msg := msg + StringReplace(badbin, ';', #13#10, [rfReplaceAll]);
      msg := msg + #13#10 + #13#10;
    end;
  end else begin
    msg := msg + Format(Lang[ID_COMPVALID_DIRNOTSET], [Lang[ID_COMPVALID_BINARY]]);
    msg := msg + #13#10 + #13#10;
  end;

  CheckDirs(fCDir, goodinc, badinc);
  if badinc <> '' then begin
    msg := msg + Format(Lang[ID_COMPVALID_DIRNOTFOUND], [Lang[ID_COMPVALID_CINCLUDE]]) + #13#10;
    msg := msg + StringReplace(badinc, ';', #13#10, [rfReplaceAll]);
    msg := msg + #13#10 + #13#10;
  end;
  CheckDirs(fCppDir, goodinccpp, badinccpp);
  if badinccpp <> '' then begin
    msg := msg + Format(Lang[ID_COMPVALID_DIRNOTFOUND], [Lang[ID_COMPVALID_CPPINCLUDE]]) + #13#10;
    msg := msg + StringReplace(badinccpp, ';', #13#10, [rfReplaceAll]);
    msg := msg + #13#10 + #13#10;
  end;
  CheckDirs(fLibDir, goodlib, badlib);
  if badlib <> '' then begin
    msg := msg + Format(Lang[ID_COMPVALID_DIRNOTFOUND], [Lang[ID_COMPVALID_LIBRARY]]) + #13#10;
    msg := msg + StringReplace(badlib, ';', #13#10, [rfReplaceAll]);
    msg := msg + #13#10 + #13#10;
  end;
  if msg <> '' then begin
    msg := Format(Lang[ID_COMPVALID_CHECKINGSET], [Name]) + #13#10#13#10 + msg + Lang[ID_COMPVALID_DIRFIXSUGGESTION];

    // If confirmed, insert working dirs into default path list
    if MessageDlg(msg, mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin

      // Remove invalid
      RemoveDirs(fBinDir, badbin);
      RemoveDirs(fLibDir, badlib);
      RemoveDirs(fCDir, badinc);
      RemoveDirs(fCppDir, badinccpp);

      // If we know the folder, we should be able to predict dirs (copy from SetDirectories)
      if fFolder <> '' then begin

        // Add both the default and the autoconf directories
        AddUnique(fBinDir, fFolder + pd + 'bin');   // MinGW64\bin
        AddUnique(fBinDir, fFolder + pd + 'opt'+ pd + 'bin'); // MinGW64\opt\bin
        AddUnique(fLibDir, fFolder + pd + 'lib');
        AddUnique(fCDir, fFolder + pd + 'include');
        AddUnique(fCppDir, fFolder + pd + 'include');

        // Try to obtain our target/autoconf folder
        if fDumpMachine <> '' then begin   //x86_64-w64-mingw32
          AddUnique(fBinDir, fFolder + pd + fDumpMachine + pd + 'bin');
          AddUnique(fLibDir, fFolder + pd + fDumpMachine + pd + 'lib');
          AddUnique(fCDir,   fFolder + pd + fDumpMachine + pd + 'include');
          AddUnique(fCppDir, fFolder + pd + fDumpMachine + pd + 'include');

          AddUnique(fLibDir, devDirs.fExec + 'MinGW64' + pd + 'opt' + pd + 'lib');
          AddUnique(fCDir,   devDirs.fExec + 'MinGW64' + pd + 'opt' + pd + 'include');
          AddUnique(fCppDir, devDirs.fExec + 'MinGW64' + pd + 'opt' + pd + 'include');

          // Custom STL folder?
          // Currently, Dev-C++ is a bit slow at parsing this shit
          AddUnique(fCppDir, fFolder + pd + 'lib' + pd + 'gcc' + pd + fDumpMachine + pd
            + fVersion + pd + 'include' + pd + 'c++');
        end;

        // Otherwise, make some guesses based on the set name...
      end else if ContainsStr(fName, 'MinGW') and ContainsStr(fName, '32') then begin

        // Add defaults
        if (badbin <> '') or (fBinDir.Count = 0) then
          AddUnique(fBinDir, devDirs.fExec + 'MinGW32' + pd + 'bin');
        if badlib <> '' then
          AddUnique(fLibDir, devDirs.fExec + 'MinGW32' + pd + 'lib');
        if badinc <> '' then
          AddUnique(fCDir, devDirs.fExec + 'MinGW32' + pd + 'include');
        if badinccpp <> '' then
          AddUnique(fCppDir, devDirs.fExec + 'MinGW32' + 'include');

      end else begin

        // Add defaults
        if (badbin <> '') or (fBinDir.Count = 0) then
          AddUnique(fBinDir, devDirs.fExec + 'MinGW64\bin');
        if badlib <> '' then begin
          if ContainsStr(fName, 'TDM-GCC') and ContainsStr(fName, '32') then
            AddUnique(fLibDir, devDirs.fExec + 'MinGW64' + pd + 'x86_64-w64-mingw32' + pd + 'lib32')
          else begin
            AddUnique(fLibDir, devDirs.fExec + 'MinGW64' + pd + 'x86_64-w64-mingw32' + pd + 'lib');
            end;
        end;
        if badinc <> '' then begin
          AddUnique(fCDir, devDirs.fExec + 'MinGW64' + 'x86_64-w64-mingw32' + pd + 'include');
        end;
        if badinccpp <> '' then begin
          AddUnique(fCppDir, devDirs.fExec + 'MinGW64' + pd + 'x86_64-w64-mingw32' + pd + 'include');
        end;
      end;

      result := false; // not valid
    end;
  end;
end;

function TdevCompilerSet.ValidateExes: boolean;
var
  msg: String;
  I: integer;

  function FindFile(dirlist: TStringList; const FileName: String): boolean;
  var
    i: integer;
  begin
    result := false;
    if FileName = '' then begin
      Result := True;
      Exit;
    end; // Accept if filename is empty (when no binary is set)

    for I := 0 to dirlist.Count - 1 do begin
      if FileExists(dirlist[i] + pd + FileName) then begin
        result := true;
        Exit;
      end;
    end;
  end;
begin
  result := true;

  // Don't bother checking exes if the dir is not set
  if fBinDir.Count = 0 then
    Exit;

  // now check some exes
  msg := '';
  if not FindFile(fBinDir, fgccName) then begin
    msg := msg + Format(Lang[ID_COMPVALID_BINNOTFOUND], [Lang[ID_COMPVALID_CCOMP], fgccName]) + #13#10;
  end;
  if not FindFile(fBinDir, fgppName) then begin
    msg := msg + Format(Lang[ID_COMPVALID_BINNOTFOUND], [Lang[ID_COMPVALID_CPPCOMP], fgppName]) + #13#10;
  end;
  if not FindFile(fBinDir, fgdbName) then begin
    msg := msg + Format(Lang[ID_COMPVALID_BINNOTFOUND], [Lang[ID_COMPVALID_DEBUGGER], fgdbName]) + #13#10;
  end;
  if not FindFile(fBinDir, fgprofName) then begin
    msg := msg + Format(Lang[ID_COMPVALID_BINNOTFOUND], [Lang[ID_COMPVALID_PROFILER], fgprofName]) + #13#10;
  end;
  if not FindFile(fBinDir, fmakeName) then begin
    msg := msg + Format(Lang[ID_COMPVALID_BINNOTFOUND], [Lang[ID_COMPVALID_MAKE], fmakeName]) + #13#10;
  end;
  if not FindFile(fBinDir, fwindresName) then begin
    msg := msg + Format(Lang[ID_COMPVALID_BINNOTFOUND], [Lang[ID_COMPVALID_WINDRES], fwindresName]) + #13#10;
  end;
  if msg <> '' then begin
    msg := Format(Lang[ID_COMPVALID_CHECKINGSET], [Name]) + #13#10#13#10 + msg + #13#10 + Lang[ID_COMPVALID_DIRSEARCHED]
      + #13#10;
    for I := 0 to fBinDir.Count - 1 do
      msg := msg + fBinDir[i] + #13#10;
    msg := msg + #13#10 + Lang[ID_COMPVALID_BINFIXSUGGESTION];
    MessageDlg(msg, mtWarning, [mbOK], 0);
    result := false; // not valid
  end;
end;

function TdevCompilerSet.Validate: boolean;
begin
  result := ValidateDirs and ValidateExes; // return true if valid
end;

procedure TdevCompilerSet.Clear;
begin
  fgccName := '';
  fgppName := '';
  fgdbName := '';
  fmakeName := '';
  fwindresName := '';
  fgprofName := '';

  fCompOpt := '';
  fLinkOpt := '';
  fCompAdd := false;
  fLinkAdd := false;
  //fAutoLink:= false;

  fBinDir.Clear;
  fCDir.Clear;
  fCppDir.Clear;
  fLibDir.Clear;
end;

{ TdevCompilerSets }

constructor TdevCompilerSets.Create;
begin
  inherited;
  fList := TList.Create;
  fDefaultIndex := -1;
end;

destructor TdevCompilerSets.Destroy;
begin
  ClearSets;
  fList.Free;
  inherited;
end;

function TdevCompilerSets.GetCompilationSet: TdevCompilerSet;
var
  Index: integer;
begin
  Index := GetCompilationSetIndex;

  // Range check...
  if (index >= 0) and (index < fList.Count) then
    result := TdevCompilerSet(fList[index])
  else
    result := nil;
end;

function TdevCompilerSets.GetCompilationSetIndex: Integer;
begin
  Result := -1;
  if Assigned(MainForm) then begin
    case MainForm.GetCompileTarget of
      ctNone:
        Result := fDefaultIndex;
      ctFile:
        Result := fDefaultIndex;
      ctProject:
        Result := MainForm.Project.Options.CompilerSet;
    end;
  end else
    Result := fDefaultIndex;
end;

function TdevCompilerSets.GetDefaultSet: TdevCompilerSet;
var
  Index: integer;
begin
  Index := fDefaultIndex;

  // Range check...
  if (index >= 0) and (index < fList.Count) then
    result := TdevCompilerSet(fList[index])
  else
    result := nil;
end;
{
procedure TdevCompilerSets.OnCompilerSetChanged(OldSet, NewSet: TdevCompilerSet);
var
  I: Integer;
  OldGCCPath, NewGCCPath: String;
begin
  // Get old gcc directory
  if Assigned(OldSet) and (OldSet.BinDir.Count > 0) then
    OldGCCPath := IncludeTrailingPathDelimiter(OldSet.BinDir[0]) + OldSet.gccName;

  // Get new gcc directory
  if Assigned(NewSet) and (NewSet.BinDir.Count > 0) then
    NewGCCPath := IncludeTrailingPathDelimiter(NewSet.BinDir[0]) + NewSet.gccName;

  // If not equal, rescan because it's a different compiler installation
  if NewGCCPath = OldGCCPath then
    Exit;

  with MainForm do begin
    CppParser.Reset;

    // Set include paths
    CppParser.ClearIncludePaths;
    for I := 0 to NewSet.CDir.Count - 1 do
      CppParser.AddIncludePath(NewSet.CDir[I]);
    for I := 0 to NewSet.CppDir.Count - 1 do
      CppParser.AddIncludePath(NewSet.CppDir[I]);
    for I := 0 to NewSet.DefInclude.Count - 1 do // Add default include dirs last, just like gcc does
      CppParser.AddIncludePath(NewSet.DefInclude[I]); // TODO: retrieve those directories in devcfg

    // Set defines
    CppParser.ResetDefines;
    for I := 0 to NewSet.Defines.Count - 1 do
      CppParser.AddHardDefineByLine(NewSet.Defines[i]); // predefined constants from -dM -E

    // Rescan work
    ScanActiveProject;
  end;
end;
}

procedure TdevCompilerSets.LoadSet(index: integer; const SetName: String = '');
var
  key: String;
  I: Integer;
  Item: TdevCompilerSet;

  procedure ReadDirList(list: TStringList; const entry: String);
  var
    i: integer;
  begin
    devData.ReadDelimitedString(key, entry, list);

    // Resolve relative paths
    for I := 0 to list.Count - 1 do
      list[i] := ReplaceFirstStr(list[i], '%path%\', devDirs.Exec);
  end;
begin
  // Can be caused by read error
  if (index < 0) or (index >= fList.Count) then
    Exit;

  // Load the current index from disk
  key := 'CompilerSets_' + IntToStr(index);

  // Programs
  with TdevCompilerSet(fList[index]) do begin

    // Load name from elsewhere in settings file (backward compat etc.)
    if SetName <> '' then begin
      fName := SetName;
      //fName := StringReplace(fName, '-bit', Lang[ID_BIT], [rfReplaceAll]);
      //fName := StringReplace(fName, 'Release', Lang[ID_RELEASE], [rfReplaceAll]);
      //fName := StringReplace(fName, 'Debug', Lang[ID_DEBUG], [rfReplaceAll]);
      //fName := StringReplace(fName, 'Profiling', Lang[ID_PROFILING], [rfReplaceAll]);
    end;

    // Load executable names
    fgccName := devData.ReadS(key, GCC_PROGRAM);
    fgppName := devData.ReadS(key, GPP_PROGRAM);
    fgdbName := devData.ReadS(key, GDB_PROGRAM);
    fmakeName := devData.ReadS(key, MAKE_PROGRAM);
    fwindresName := devData.ReadS(key, WINDRES_PROGRAM);
    fgprofName := devData.ReadS(key, GPROF_PROGRAM);

    // Load the option in string format
    INIOptions := devData.ReadS(key, 'Options');

    // Extra parameters
    fCompOpt := devData.ReadS(key, 'CompOpt');
    fLinkOpt := devData.ReadS(key, 'LinkOpt');
    fCompAdd := devData.ReadB(key, 'CompAdd');
    fLinkAdd := devData.ReadB(key, 'LinkAdd');
    //fAutoLink:= devData.ReadB(key, 'AutoLink');

    // Directories, undo relative stuff
    ReadDirList(fBinDir, 'Bins');
    ReadDirList(fLibDir, 'Lib');
    ReadDirList(fCDir, 'C');
    ReadDirList(fCppDir, 'Cpp');
    ReadDirList(fDefInclude, 'Def');

    // Set properties for current gcc path
    if fBinDir.Count > 0 then begin
      // Check if this directory has already been used to set properties
      for I := 0 to devCompilerSets.Count - 1 do begin
        if I <> index then begin
          Item := devCompilerSets[i];
          if (Item.BinDir.Count > 0) and (Item.BinDir[0] = fBinDir[0]) and (Item.gccName = fgccName) then begin
            fVersion := Item.fVersion;
            fFolder := Item.fFolder;
            fType := Item.fType;
            if fName = '' then
              fName := Item.fName;
            fDumpMachine := Item.fDumpMachine;
            //fDefInclude.Assign(Item.fDefInclude);
            fDefines.Assign(Item.fDefines);
          end else
            SetProperties(fBinDir[0], fgccName); // read properties from disk
        end;
      end;
    end;
  end;
end;

procedure TdevCompilerSets.SaveSet(Index: integer);
var
  key: String;

  procedure WriteDirList(list: TStringList; const entry: String);
  var
    I: integer;
    sl: TStringList;
  begin
    sl := TStringList.Create;
    try
      sl.Assign(list); // work on a local copy
      for I := 0 to sl.Count - 1 do
        sl[i] := ReplaceFirstStr(sl[i], devDirs.Exec, '%path%\');

      // Convert stringlist to string
      devData.WriteDelimitedString(key, entry, sl);
    finally
      sl.Free;
    end;
  end;

begin
  key := 'CompilerSets_' + IntToStr(Index);

  with TdevCompilerSet(fList[index]) do begin

    // Programs
    devData.Write(key, GCC_PROGRAM, fgccName);
    devData.Write(key, GPP_PROGRAM, fgppName);
    devData.Write(key, GDB_PROGRAM, fgdbName);
    devData.Write(key, MAKE_PROGRAM, fmakeName);
    devData.Write(key, WINDRES_PROGRAM, fwindresName);
    devData.Write(key, GPROF_PROGRAM, fgprofName);

    // Save option string
    devData.Write(key, 'Options', INIOptions);

    // Save extra 'general' options
    devData.Write(key, 'CompOpt', fCompOpt);
    devData.Write(key, 'LinkOpt', fLinkOpt);
    devData.Write(key, 'CompAdd', fCompAdd);
    devData.Write(key, 'LinkAdd', fLinkAdd);
    //devData.Write(key, 'AutoLink', fAutoLink);

    // Paths
    WriteDirList(fBinDir, 'Bins');
    WriteDirList(fCDir, 'C');
    WriteDirList(fCppDir, 'Cpp');
    WriteDirList(fLibDir, 'Lib');
    WriteDirList(fDefInclude, 'Def');
  end;
end;

function TdevCompilerSets.AddSet: TdevCompilerSet;
begin
  result := TdevCompilerSet.Create;
  fList.Add(result);
end;

function TdevCompilerSets.AddSet(const Folder: String): TdevCompilerSet;
begin
  result := TdevCompilerSet.Create(Folder);
  fList.Add(result);
end;

function TdevCompilerSets.AddSet(compilerset: TdevCompilerSet): TdevCompilerSet;
begin
  result := TdevCompilerSet.Create;
  result.Assign(compilerset); // deep copy
  fList.Add(result);
end;

function TdevCompilerSets.GetSet(index: integer): TdevCompilerSet;
begin
  result := TdevCompilerSet(fList[index]);
end;

procedure TdevCompilerSets.DeleteSet(Index: integer);
var
  I: integer;
begin
  // Erase all sections at and above from disk
  for I := Index to fList.Count - 1 do
    devData.EraseSection('CompilerSets_' + IntToStr(I));

  // Update memory
  TdevCompilerSet(fList[index]).Free;
  fList.Delete(index);

  // Save new memory
  for I := Index to fList.Count - 1 do
    SaveSet(I);
end;

function TdevCompilerSets.Count: integer;
begin
  result := fList.Count;
end;

procedure TdevCompilerSets.LoadSets;
const
  REG_LOCATION = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';
  //REG_LOCATION='Environment';
var
  I, SetToActivate: integer;
  slist: TStringList;
  CurrentSet: TdevCompilerSet;
//  ch: char;
  strPath: string;
begin
  // Don't append, but replace
  ClearSets;

  slist := TStringList.Create;
  try
    // First list, then current index
    devData.ReadStrings('CompilerSets', slist);

    // Populate list
    SetToActivate := -1;
    for I := 0 to slist.Count - 1 do begin
      if not SameStr(slist.Names[I], 'Current') then begin
        fList.Add(TdevCompilerSet.Create); // add empty shell
        LoadSet(StrToInt(slist.Names[I]), slist.Values[slist.Names[I]]); // backwards compatibility: save Name here and pass it
      end else begin
        SetToActivate := StrToIntDef(slist.Values[slist.Names[I]], -1);
      end;
    end;

    while True do begin
      if SetToActivate < 0 then
        break;
      // Activate the current set after everything has been loaded
      DefaultSetIndex := SetToActivate;
      // Validate and load the current set
      CurrentSet := GetDefaultSet;
      if Assigned(CurrentSet) and (CurrentSet.Validate) then begin
        break;
      end else begin
        DeleteSet(SetToActivate); //delete invalide compilerSet
        if (SetToActivate > (FList.Count - 1)) then
          dec(SetToActivate);
      end;
    end;

    if SetToActivate = -1 then begin
      FindSets;
      SaveSets;
      SetToActivate := DefaultSetIndex;
    end;

//    if (not iswindows64) and (SetToActivate = -1) then  begin  //check, notice to download
//        ShellExecute(GetDesktopWindow(), 'open',
//          'https://devcpp.gitee.io/manual/win-32-bit.html', nil, nil, SW_SHOWNORMAL);
//          OpenhelpFile('manual\win-32-bit.html');
//    end;

    // if it is win32 with "64-bit" compilation, then change to "32-bit debug"
    if (not iswindows64) and (SetToActivate > -1) and (TdevCompilerSet(fList[SetToActivate]).GetOption('-') <> '1') then begin
      for I := 0 to slist.Count - 2 do begin
        if (TdevCompilerSet(fList[I]).GetOption('-') = '1') and   //-1: 32-bit; -a: 64-bit
            (TdevCompilerSet(fList[I]).GetOption('-O') = 'e') then begin   //-Oa: run; -Oe:debug
          SetToActivate := I;
          break;
        end;
      end;
    end;

    // Activate the current set after everything has been loaded
    DefaultSetIndex := SetToActivate;

    // Validate and load the current set
    CurrentSet := GetDefaultSet;

    // Check if it is usable
    if Assigned(CurrentSet) and CurrentSet.Validate then begin
      SaveSet(DefaultSetIndex);
      if CurrentSet.BinDir.Count > 0 then begin
        CurrentSet.SetProperties(CurrentSet.BinDir[0], CurrentSet.gccName);
        //Add DinDir to global enviroment path.
        {$IFDEF MSWINDOWS}
        with TRegistry.Create do
        try
          RootKey := HKEY_LOCAL_MACHINE;  //HKEY_CURRENT_USER;  ;
          if OpenKey(REG_LOCATION, True) then begin
            strPath := ReadString('Path');
            if (Pos(CurrentSet.BinDir[0], strPath) = 0) then begin
              strPath := strPath + ';'+ CurrentSet.BinDir[0];    // ./MinGW64/bin
              WriteString('Path', strPath);   //write, and broacast the change to take effection.
              SendMessage(HWND_BROADCAST, WM_SETTINGCHANGE, 0, integer(Pchar('Environment')));
            end;
            //if (CurrentSet.BinDir.Count > 1) and (Pos(CurrentSet.BinDir[0], strPath) = 0) then begin
            //  strPath := strPath + ';'+ CurrentSet.BinDir[1];  // ./MinGW64/opt/bin
            //  WriteString('Path', strPath);   //write, and broacast the change to take effection.
            //  SendMessage(HWND_BROADCAST, WM_SETTINGCHANGE, 0, integer(Pchar('Environment')));
            //end;

            CloseKey();
          end;
        finally
         Free;
        end;
        {$ELSE}
        // Linux: PATH modification requires user to manually add the compiler
        // bin directory to their shell profile (~/.profile, ~/.bashrc).
        // The IDE will set PATH at compile-time via TProcess.Environment.
        // Show a non-blocking hint to the user instead.
        Application.MessageBox(
          PChar('To use the compiler from the terminal, add the following line to ~/.profile or ~/.bashrc, then restart your shell:' + LineEnding + LineEnding +
          '  export PATH="' + CurrentSet.BinDir[0] + ':$PATH"'),
          PChar('Compiler PATH'), MB_OK or MB_ICONINFORMATION);
        {$ENDIF}
      end;
    end;
  finally
    slist.Free;
  end;
end;

{
procedure TdevCompilerSets.LoadAutoLinks(var strlist: TStringList);
var
  filename: String;
begin
  filename := devDirs.Config + DEV_LINKER_FILE;
  if not FileExists (filename) then begin
    strlist.Add('#Auto link parameters');
    strlist.Add('egegraphics.h');
    strlist.Add('-lgraphics64 -luuid -lmsimg32 -lgdi32 -limm32 -lole32 -loleaut32 -lgdiplus -mwindows');
    strlist.Add('easyxgraphics.h');
    strlist.Add('-lEasyX -lgdi32 -lole32');
    strlist.Add('raylib.h');
    strlist.Add('-lraylib -lopengl32 -lgdi32 -lwinmm');
    strlist.SaveToFile(filename);
  end else begin
    strlist.LoadFromFile(filename);
    strlist.Delete(0);
  end;
end;
}

procedure TdevCompilerSets.SaveSets;
var
  I: integer;
begin
  // Write all sets separately
  for I := 0 to fList.Count - 1 do
    SaveSet(i);

  // Then save the summary
  SaveSetList;
end;

procedure TdevCompilerSets.SaveSetList;
var
  sl: TStringList;
  s: String;
  I: integer;
begin
  // For the summary, compiler list first
  sl := TStringList.Create;
  try
    for I := 0 to fList.Count - 1 do  begin
      s := TdevCompilerSet(fList[i]).Name;
      s := StringReplace(s, Lang[ID_BIT], '-bit', []);
      s := StringReplace(s, Lang[ID_RELEASE], 'Release', []);
      s := StringReplace(s, Lang[ID_DEBUG], 'Debug', []);
      s := StringReplace(s, Lang[ID_PROFILING], 'Profiling', []);
      //sl.Add(TdevCompilerSet(fList[i]).Name);
      sl.Add(s);
    end;
    devData.WriteStrings('CompilerSets', sl);
  finally
    sl.Free;
  end;

  // Then current index
  if fDefaultIndex >= fList.Count then
    fDefaultIndex := -1;
  devData.Write('CompilerSets', 'Current', fDefaultIndex);
end;

{$IFNDEF MSWINDOWS}
// Register the system-wide GCC (detected via "which gcc") as a compiler set.
// Kept as a separate routine so the cross-platform locals don't trigger
// unused-var hints on Windows, where this whole block is not compiled.
procedure AddSystemGCCSet;
var
  gccLine, gccPath, binDir, folder: String;
  gdbAvailable: Boolean;
  BaseSet: TdevCompilerSet;
  BaseName: String;
  option: PCompilerOption;
  index: integer;
begin
  option := default(PCompilerOption);
  index := 0;
  // Detect gcc via "which gcc"; fall back to the POSIX shell builtin
  // "command -v gcc" (some minimal Linux installs ship without "which").
  gccLine := Trim(RunAndGetOutput('which gcc', '', nil, nil));
  if (gccLine = '') or ((Length(gccLine) > 0) and (gccLine[1] <> '/')) then
    gccLine := Trim(RunAndGetOutput('sh -c "command -v gcc"', '', nil, nil));
  if Pos(#10, gccLine) > 0 then // keep only the first match if several lines
    gccLine := Trim(Copy(gccLine, 1, Pos(#10, gccLine) - 1));
  gccPath := Trim(gccLine);
  // A real binary path is absolute (starts with '/'); otherwise "which"/
  // "command -v" printed an error message and gcc is not installed.
  if (gccPath <> '') and (gccPath[1] = '/') then begin
    binDir := ExtractFileDir(gccPath);                  // e.g. /usr/bin
    folder := ExtractFileDir(binDir);                  // e.g. /usr (SetDirectories adds folder/bin, folder/include)
    if DirectoryExists(binDir) then begin
      BaseSet := devCompilerSets.AddSet(folder);
      {$IFDEF LINUX}
      BaseSet.fName := 'GCC (Linux) ' + BaseSet.fVersion;
      {$ELSE} // DARWIN
      BaseSet.fName := 'GCC (macOS) ' + BaseSet.fVersion;
      {$ENDIF}
      BaseName := BaseSet.fName;
      // Only offer a Debug profile when a debugger (gdb) is actually present,
      // since Dev-C++ launches BinDir[0]/gdb and cannot debug otherwise.
      gdbAvailable := FileExists(binDir + pd + GDB_PROGRAM);
      if gdbAvailable then begin
        with BaseSet do begin
          Name := BaseName + ' (Debug)';
          if FindOption('-g3', option, index) then
            SetOption(option, '1');   // include debug information
          AddtoLink := false;
        end;
        with devCompilerSets.AddSet(BaseSet) do begin
          Name := BaseName + ' (Release)';
          if FindOption('-O', option, index) then
            SetOption(option, 'a');   // -O2
          if FindOption('-g3', option, index) then
            SetOption(option, '0');
          AddtoLink := false;
        end;
      end else begin
        with BaseSet do begin
          Name := BaseName + ' (Release)';
          if FindOption('-O', option, index) then
            SetOption(option, 'a');   // -O2
          if FindOption('-g3', option, index) then
            SetOption(option, '0');
          AddtoLink := false;
        end;
      end;
    end;
  end;
end;
{$ENDIF}

procedure TdevCompilerSets.FindSets;
// Automatically find compiler sets in folder 'TDM-GCC-64', 'MinGW64' or 'MinGW32'.
var
  BaseSet: TdevCompilerSet;
  BaseName: String;
  option: PCompilerOption;
  index, I: integer;
begin
  option := default(PCompilerOption);
  index := 0;

  {$IFNDEF MSWINDOWS}
  AddSystemGCCSet; // detect system GCC via "which gcc" and register a set
  {$ENDIF}

  // Assume 64-bit and 32-bit compilers are put in the TDM-GCC-64 folder
  if DirectoryExists(devDirs.Exec + 'TDM-GCC-64' + pd) then begin
    // we only require GCC.exe to be present
    if FileExists(devDirs.Exec + 'TDM-GCC-64' + pd + 'bin' + pd + GCC_PROGRAM) then begin
      //The differences between profiles are: Optimization level, 64-bit or 32-bit,
      //debug information and profiling information.

      // 64-bit Debug
      BaseSet := AddSet(devDirs.Exec + 'TDM-GCC-64');
      BaseName := BaseSet.Name;
      with BaseSet do begin
        Name := BaseName + ' 64-bit Debug';
        if FindOption('-O', option, index) then
          SetOption(option, 'e');   //-Og  //optimization for debug
        if FindOption('-', option, index) then
          SetOption(option, 'a');   //-m64
        if FindOption('-g3', option, index) then  //debug information level 3
          SetOption(option, '1');
      end;
      //64-bit release
      with AddSet(BaseSet) do begin
        Name := BaseName + ' 64-bit Release';
        if FindOption('-O', option, index) then //optimization level
          SetOption(option, 'a');   //-O2  //optimization level 2 (med)
        //to check variables "uninitialized", must turn on optimization
        if FindOption('-', option, index) then //64-bit or 32-bit
        //-m is used my -mINSTRUCTIONSET, so use - instead
          SetOption(option, 'a');   //a: -m64, 1: -m32
        //AddtoLink := true;   //add static compiling parameters
      end;
      //todo: release 版本应该自动增加勾选“包含以下命令”

      // 64-bit Profiling
      with AddSet(BaseSet) do begin
        Name := BaseName + ' 64-bit Profiling';
        if FindOption('-O', option, index) then
          SetOption(option, 'a'); //-O2 //optimization level 2 (med)
        if FindOption('-', option, index) then
          SetOption(option, 'a'); //-m64
        if FindOption('-pg', option, index) then //profiling information
          SetOption(option, '1');
      end;

      //32-bit Debug
      with AddSet(BaseSet) do begin
        Name := BaseName + ' 32-bit Debug';
        if FindOption('-O', option, index) then
          SetOption(option, 'e'); //-Og //optimization for debug
        if FindOption('-', option, index) then
          SetOption(option, '1');  //-m32
        if FindOption('-g3', option, index) then  //debug information level 3
          SetOption(option, '1');
      end;

      //32-bit release
      BaseSet := AddSet(BaseSet);
      with BaseSet do begin
        Name := BaseName + ' 32-bit Release';
        if FindOption('-O', option, index) then
          SetOption(option, 'a');  //-O2  optimization level 2 (med)
        if FindOption('-', option, index) then
          SetOption(option, '1'); //-m32

        // Hack fix, but works...
        fgdbName := GDB32_PROGRAM;
        for I := fLibDir.Count - 1 downto 0 do
          if DirectoryExists(fLibDir[i] + '32') then
            fLibDir[i] := fLibDir[i] + '32'
          else
            fLibDir.Delete(i);
        AddtoLink := true;   //add static compiling parameters
      end;

      // 32-bit Profiling
      with AddSet(BaseSet) do begin
        Name := BaseName + ' 32-bit Profiling';
        if FindOption('-O', option, index) then
          SetOption(option, 'a');   //-O2  optimization level 2 (med)
        if FindOption('-', option, index) then
          SetOption(option, '1');   //-m32
        if FindOption('-pg', option, index) then  //profiling information
          SetOption(option, '1');
      end;
    end;
  end;  //TDM-GCC-64

  //The following codes are for folder "MinGW64". Not completely set the parameters.
  // Assume 64-bit compilers are put in the MinGW64 folder
  if DirectoryExists(devDirs.Exec + 'MinGW64' + pd) then begin
    // we only require GCC.exe to be present
    if FileExists(devDirs.Exec + 'MinGW64' + pd + 'bin' + pd + GCC_PROGRAM) then begin

      // 64-bit Default,     64-bit Debug profile
      BaseSet := AddSet(devDirs.Exec + 'MinGW64');
      BaseName := BaseSet.Name;
      with BaseSet do begin
        Name := BaseName + ' 64-bit Debug';
        if FindOption('-O', option, index) then //optimization level
          SetOption(option, 'e');   //-Og  //optimization for debug
        if FindOption('-', option, index) then //64-bit or 32-bit
        //-m is used my -mINSTRUCTIONSET, so use - instead
          SetOption(option, 'a');   //a: -m64, 1: -m32
        if FindOption('-g3', option, index) then    //debug information level 3
          SetOption(option, '1');  //1: ON;  0: OFF
        AddtoLink := false;
      end;

      //64-bit release profile
      with AddSet(BaseSet) do begin
        Name := BaseName + ' 64-bit Release';
        //Name := BaseName;  //Only add an base set. //by Anbang LI, 2026-06-17
        if FindOption('-O', option, index) then //optimization level
          SetOption(option, 'a');   //-O2  //optimization level 2 (med)
        //To check variables "uninitialized", must turn on optimization
        //But, this is not correct?
        if FindOption('-', option, index) then //64-bit or 32-bit
        //-m is used my -mINSTRUCTIONSET, so use - instead
          SetOption(option, 'a');   //a: -m64; 1: -m32
        if FindOption('-g3', option, index) then    //debug information level 3
          SetOption(option, '0');  //1: ON;  0: OFF
        AddtoLink := false;   //add static compiling parameters
      end;

       // 64-bit Profiling profile
{      with AddSet(BaseSet) do begin
        Name := BaseName + ' 64-bit Profiling';
        if FindOption('-O', option, index) then //optimization level
          SetOption(option, 'a');   //-O2  //optimization level 2 (med)
        if FindOption('-', option, index) then //64-bit or 32-bit
        //-m is used my -mINSTRUCTIONSET, so use - instead
          SetOption(option, 'a');   //a: -m64, 1: -m32
        AddtoComp := true;
        CompOpts := '-no-pie';
        AddtoLink := false;
        if FindOption('-pg', option, index) then
          SetOption(option, '1');
      end;
 }

      if FileExists(devDirs.Exec + 'MinGW64' + pd + 'bin' + pd + GDB32_PROGRAM) then begin
        // 32-bit Debug profile
        BaseSet := AddSet(BaseSet);
        with BaseSet do begin
                    Name := BaseName + ' 32-bit Debug';
          AddtoLink := false;
          if FindOption('-O', option, index) then //optimization level
          SetOption(option, 'e');   //-Og  //optimization for debug
          if FindOption('-g3', option, index) then
            SetOption(option, '1');
        end;

        //32-bit release profile
        with AddSet(BaseSet) do begin
          Name := BaseName + ' 32-bit Release';
          AddtoLink := true;   //add static compiling parameters
          if FindOption('-O', option, index) then //optimization level
            SetOption(option, 'a');   //-O2  //optimization level 2 (med)
          if FindOption('-', option, index) then // -m is used my -mINSTRUCTIONSET, so use - instead
            SetOption(option, '1');
          // Hack fix, but works...
          fgdbName := GDB32_PROGRAM;
          for I := fLibDir.Count - 1 downto 0 do
            if DirectoryExists(fLibDir[i] + '32') then
              fLibDir[i] := fLibDir[i] + '32'
            else
              fLibDir.Delete(i);
        end;

        // 32-bit Profiling profile
        with AddSet(BaseSet) do begin
          Name := BaseName + ' 32-bit Profiling';
          AddtoLink := false;
          if FindOption('-O', option, index) then //optimization level
            SetOption(option, 'a');   //-O2  //optimization level 2 (med)
          if FindOption('-pg', option, index) then
            SetOption(option, '1');
        end;
      end;
    end;
  end;

  // And assume 32bit compilers are put in the MinGW32 folder
  if DirectoryExists(devDirs.Exec + 'MinGW32' + pd) then begin
    if FileExists(devDirs.Exec + 'MinGW32' + pd + 'bin' + pd + 'gcc.exe') then begin

      // Default, 32-bit Debug profile
      BaseSet := AddSet(devDirs.Exec + 'MinGW32');
      BaseName := BaseSet.Name;
      with BaseSet do begin
        Name := BaseName + ' 32-bit Debug';
        AddtoLink := false;
        if FindOption('-g3', option, index) then
          SetOption(option, '1');
      end;

      // 32-bit Release profile
      with AddSet(BaseSet) do begin
        Name := BaseName + ' 32-bit Release';
        AddtoLink := true;   //add static compiling parameters
      end;

      // 32-bit Profiling profile
      with AddSet(BaseSet) do begin
        Name := BaseName + ' 32-bit Profiling';
        AddtoLink := false;
        if FindOption('-pg', option, index) then
          SetOption(option, '1');
      end;
    end;
  end;

  //Set default set
  //devCompilerSets.DefaultSetIndex := 0;
  devCompilerSets.DefaultSetIndex := -1;
  if isWindows64 then begin
    for I := 0 to devCompilerSets.Count - 1 do begin
      if ContainsText(devCompilerSets[i].Name, 'debug') then begin
        devCompilerSets.DefaultSetIndex := i;
        break;
      end;
    end;
  end else begin
    for I := 0 to devCompilerSets.Count - 1 do begin
      if ContainsText(devCompilerSets[i].Name, '32') and ContainsText(devCompilerSets[i].Name, 'debug') then begin
        devCompilerSets.DefaultSetIndex := i;
        break;
      end;
    end;
  end;

end;

procedure TdevCompilerSets.ClearSets;
var
  I: integer;
begin
  for I := 0 to fList.Count - 1 do
    TdevCompilerSet(fList[i]).Free;
  fList.Clear;
end;

{ TDevDirs }

constructor TdevDirs.Create;
begin
  inherited Create;
  SettoDefaults;
  LoadSettings;
end;

procedure TdevDirs.SettoDefaults;
var
  DocumentsPath: array[0..MAX_PATH] of Char;
const
  CSIDL_MYDOCUMENTS = $05;
begin
  fExec := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  fConfig := fExec;

  fHelp := fExec + HELP_DIR;
  fIcons := fExec + ICON_DIR;
  fLang := fExec + LANGUAGE_DIR;
  fTemp := fExec + TEMPLATE_DIR;
  fThemes := fExec + THEME_DIR;

  // Get my documents folder
{$IFDEF MSWINDOWS}
  DocumentsPath := '';  //initialize
  FillChar(DocumentsPath, SizeOf(DocumentsPath), 0);  //initialize
  if SHGetSpecialFolderPath(Application.Handle, DocumentsPath, CSIDL_MYDOCUMENTS, false) then
    fDefault := DocumentsPath
  else
{$ENDIF}
    fDefault := fExec;
end;

procedure TdevDirs.LoadSettings;
begin
  devData.ReadObject('Directories', Self);

  fConfig := ExtractFilePath(devData.INIFileName);
  fHelp := ReplaceFirstStr(fHelp, '%path%\', fExec);
  fIcons := ReplaceFirstStr(fIcons, '%path%\', fExec);
  fLang := ReplaceFirstStr(fLang, '%path%\', fExec);
  fTemp := ReplaceFirstStr(fTemp, '%path%\', fExec);
  fThemes := ReplaceFirstStr(fThemes, '%path%\', fExec);
end;

procedure TdevDirs.SaveSettings;
begin
  fHelp := ReplaceFirstStr(fHelp, fExec, '%path%\');
  fIcons := ReplaceFirstStr(fIcons, fExec, '%path%\');
  fLang := ReplaceFirstStr(fLang, fExec, '%path%\');
  fTemp := ReplaceFirstStr(fTemp, fExec, '%path%\');
  fThemes := ReplaceFirstStr(fThemes, fExec, '%path%\');

  devData.WriteObject('Directories', Self);

  fHelp := ReplaceFirstStr(fHelp, '%path%\', fExec);
  fIcons := ReplaceFirstStr(fIcons, '%path%\', fExec);
  fLang := ReplaceFirstStr(fLang, '%path%\', fExec);
  fTemp := ReplaceFirstStr(fTemp, '%path%\', fExec);
  fThemes := ReplaceFirstStr(fThemes, '%path%\', fExec);
end;

constructor TdevEditor.Create;
begin
  inherited;

  fFont := TFont.Create;
  fGutterfont := TFont.Create;
  fColorScheme := TStringList.Create;
  TStringList(fColorScheme).Duplicates := dupIgnore;

  SettoDefaults;
  LoadSettings;
end;

destructor TdevEditor.Destroy;
begin
  fFont.Free;
  fGutterfont.Free;
  fColorScheme.Free;

  inherited;
end;

procedure TdevEditor.LoadSettings;
begin
  devData.ReadObject('Editor', Self);
end;

procedure TdevEditor.SaveSettings;
begin
  devData.WriteObject('Editor', Self);
end;

//set build-in Color Scheme NO. idx
procedure TdevEditor.SetColorScheme(idx: integer);
var
  slist: TStringList;
  offset: integer;
  i: integer;
  s : String; //debug
begin
  slist := TStringList.Create;
  if idx < 0 then
    idx := 1;
  if idx > BuiltinSchemes - 1 then
    idx := 5;

  // The element-name list is now the ColorElemNames constant (see interface consts).

  try
    //0-13: colors for SynTax highlighting. Format: forecolor, backcolor, bold, italic, underline
    //Space,  Comment,  Preprocessor,
    //ReservedWord;  Identifier, Symbol, //ReservedWord: Id keyword, Id type, Id special,Id templated
    //Number Float, Number, Number Oct,
    //Number Hex/Bin,  String,  Char,
    //Asm BG,  Incorrect
    //14-23: special element colors for Editor. Format: forecolor, backcolor
    //Breakpoints, ErrorLine, ActiveBreakpoints,
    //Bookmarks, SelectedText, CurrentLine,
    //Gutter, EditState, FoldingLines1, FoldingLines2,
    case idx of
    0: slist.AddStrings([ // Scheme 0: Classic light
      'clBlack, clWhite, 0, 0, 0', 'clHighlight, clNone, 0, 0, 0', 'clGreen, clNone, 0, 0, 0',
      'clBlack, clNone, 1, 0, 0',  'clBlack, clNone, 0, 0, 0', 'clBlack, clNone, 0, 0, 0',
      'clPurple, clNone, 0, 0, 0', 'clPurple, clNone, 0, 0, 0', 'clPurple, clNone, 0, 0, 0',
      'clPurple, clNone, 0, 0, 0', 'clRed, clNone, 0, 0, 0', 'clFuchsia, clNone, 0, 0, 0',
      'clBlue, clNone, 0, 0, 0',  'clRed, clYellow, 1, 0, 1',
      'clNone, 5197823',  'clNone, 10461183', 'clNone, 16755027',
      'clNone, 12639424', 'clWhite, clNavy',   'clNone, 16774376',
      'clGray, $00E0E0E0','$00A8E0, clGreen', 'clGray, $00F0F0F0', 'clGreen, $00F0F0F0']);
    1: slist.AddStrings([   // Scheme 1: Classic light Plus
      'clBlack, clWhite, 0, 0, 0', 'clGreen, clNone, 0, 0, 0','$000000B4, clNone, 0, 0, 0',
      'clNavy, clNone, 1, 0, 0',   'clBlack, clNone, 0, 0, 0','clMaroon, clNone, 1, 0, 0',
      'clPurple, clNone, 0, 0, 0', 'clPurple, clNone, 0, 0, 0', 'clPurple, clNone, 0, 0, 0',
      'clPurple, clNone, 0, 0, 0', '$00D26900, clNone, 0, 0, 0', '$00F900F9, clNone, 0, 0, 0',
      'clTeal, clWhite, 0, 0, 0', 'clRed, clYellow, 1, 0, 1',
      'clNone, 5197823',   'clNone, 10461183', 'clNone, 16755027',
      'clNone, 12639424',  'clWhite, clNavy',   'clNone, 16774376',
      'clGray, $00E0E0E0', '$00A8E0, clGreen', 'clGray, $00F0F0F0', 'clGreen, $00F0F0F0']);
    2: slist.AddStrings([// Scheme 2: light green
      'clBlack, $00F5FFF5, 0, 0, 0', 'clGray, clNone, 0, 0, 0','$000000B4, clNone, 0, 0, 0',
      'clNavy, clNone, 1, 0, 0',   'clBlack, clNone, 0, 0, 0','clMaroon, clNone, 1, 0, 0',
      'clPurple, clNone, 0, 0, 0', 'clPurple, clNone, 0, 0, 0', 'clPurple, clNone, 0, 0, 0',
      'clPurple, clNone, 0, 0, 0', '$00D26900, clNone, 0, 0, 0', '$00F900F9, clNone, 0, 0, 0',
      'clTeal, clWhite, 0, 0, 0', 'clRed, clYellow, 1, 0, 1',
      'clNone, 5197823',   'clNone, 10461183', 'clNone, 16755027',
      'clNone, 12639424',  'clWhite, clNavy',   'clNone, 16774376',
      'clGray, $00E0E0E0', '$00A8E0, clGreen', 'clGray, $00F0F0F0', 'clGreen, $00F0F0F0' ]);
    3: slist.AddStrings([// Scheme 3: Pale Blue
      'clBlack, $00FFFCF2, 0, 0, 0', 'clGray, clNone, 0, 0, 0','$000000B4, clNone, 0, 0, 0',
      'clNavy, clNone, 1, 0, 0',   'clBlack, clNone, 0, 0, 0','clMaroon, clNone, 1, 0, 0',
      'clPurple, clNone, 0, 0, 0', 'clPurple, clNone, 0, 0, 0', 'clPurple, clNone, 0, 0, 0',
      'clPurple, clNone, 0, 0, 0', '$00D26900, clNone, 0, 0, 0', '$00F900F9, clNone, 0, 0, 0',
      'clTeal, clWhite, 0, 0, 0', 'clRed, clYellow, 1, 0, 1',
      'clNone, 5197823',   'clNone, 10461183', 'clNone, 16755027',
      'clNone, 12639424',  'clWhite, clNavy',   'clNone, 16774376',
      'clGray, 16380631', '$00A8E0, clGreen', 'clGray, 16512998', 'clGreen, $00F0F0F0' ]);

    4: slist.AddStrings([ // Scheme 4: soft pink
      'clBlack, $00FFF0FE, 0, 0, 0', 'clGreen, clNone, 0, 0, 0', '$000000B4, clNone, 0, 0, 0',
      'clPurple, clNone, 1, 0, 0', 'clBlack, clNone, 0, 0, 0', 'clMaroon, clNone, 1, 0, 0',
      'clPurple, clNone, 0, 0, 0', 'clPurple, clNone, 0, 0, 0', 'clPurple, clNone, 0, 0, 0',
      'clPurple, clNone, 0, 0, 0', '$00C60000, clNone, 0, 0, 0', 'clFuchsia, clNone, 0, 0, 0',
      'clTeal, clWhite, 0, 0, 0',  'clRed, clYellow, 1, 0, 1',
      'clNone, 10461183', 'clNone, 5197823',   '536870911, 16761220',
      'clNone, 15204302', '16777215, 12615935','536870911, 16769520',
      '8421504, 16116991', '8421504, 16116991', '8421504, 16769535','32768, 15790320' ]);
    5: slist.AddStrings([ // Scheme 5: Github light
      'clBlack, clWhite, 0, 0, 0','$006F6459, clWhite, 0, 0, 0','$003022D9, clWhite, 0, 0, 0',
      '$003022D9, clWhite, 0, 0, 0', '$00AD5905, clWhite, 0, 0, 0','$0027231F, clWhite, 1, 0, 0',
      'clMaroon, clWhite, 0, 0, 0',  'clMaroon, clWhite, 0, 0, 0', 'clMaroon, clWhite, 0, 0, 0',
      'clMaroon, clWhite, 0, 0, 0',  'clPurple, clWhite, 0, 0, 0', '$00FF37FF, clWhite, 0, 0, 0',
      'clTeal, clWhite, 0, 0, 0',  'clRed, clYellow, 1, 0, 1',
      '4210752, 12581119', 'clnone, 6855167',   'clNone, 13107086',
      'clNone, 12639424',  'clWhite, clNavy',  'clNone, 16774376',
      '8421504, 16252919', '$00A8E0, clGreen', 'clGray, $00FAF8F6', 'clGreen, $00FAF8F6'  ]);
    6: slist.AddStrings([ // Scheme 6: tradition Light (similiar to Visual C++ 6)
      'clBlack, clWhite, 0, 0, 0','clGreen, clNone, 0, 0, 0', 'clBlue, clNone, 0, 0, 0',
      'clBlue, clNone, 0, 0, 0', 'clBlack, clNone, 0, 0, 0', 'clTeal, clNone, 0, 0, 0',
      'clBlack, clNone, 0, 0, 0', 'clBlack, clNone, 0, 0, 0', 'clBlack, clNone, 0, 0, 0',
      'clBlack, clNone, 0, 0, 0', 'clPurple, clNone, 0, 0, 0', 'clBlack, clNone, 0, 0, 0',
      'clBlack, clNone, 0, 0, 0','clRed, clYellow, 1, 0, 1',
      'clnone, 4227327',    'clNone, 255', 'clNone, 65535',
      'clNone, 12639424',   '536870911, 8421504',  'clNone, 16774376',
      'clGray, $00E0E0E0',  '$00A8E0, clGreen', 'clGray, $00F0F0F0', 'clGreen, $00F0F0F0']);

    7: slist.AddStrings([ // Scheme 7: Modern Dark (similiar to Visual Studio Code Dark)
      '$00D4D4D4, $001E1E1E, 0, 0, 0','$0055996A, clNone, 0, 0, 0', '$00D6C556, clNone, 0, 0, 0',
      '$00D6C556, clNone, 0, 0, 0', '$00C086C5, clNone, 0, 0, 0', '$00AADCDC, clNone, 0, 0, 0',
      '$00A8CEB5, clNone, 0, 0, 0', '$00A8CEB5, clNone, 0, 0, 0', '$00A8CEB5, clNone, 0, 0, 0',
      '$00A8CEB5, clNone, 0, 0, 0', '$007891CE, clNone, 0, 0, 0', 'clTeal, clNone, 0, 0, 0',
      'clGreen, clNone, 0, 0, 0',   '$004C4CF1, clYellow, 1, 0, 1',
      'clNone, 1908058', 'clnone, 179', 'clNone, 8388608',
      'clNone, $003D2913', 'clnone, $00784F26',  'clNone, 3750201',
      'clGray, $001E1E1E', '$00A8E0, clGreen','clMoneyGreen, $002E2D2A', 'clYellow, $002E2D2A' ]);
    8: slist.AddStrings([ // Scheme 8: Plastic Code Wrap
      '$1F1D160B, $021D160B, 0, 0, 0', '$00E09A1E, $001D160B, 0, 0, 0', '$0000AAFF, $021D160B, 0, 0, 0',
      '$0080F0F6, $021D160B, 0, 0, 0', 'clWhite, $021D160B, 0, 0, 0','$0000AAFF, $021D160B, 0, 0, 0',
      '$00833AFF, $021D160B, 0, 0, 0', '$00833AFF, $021D160B, 0, 0, 0', '$00833AFF, $021D160B, 0, 0, 0',
      '$00833AFF, $021D160B, 0, 0, 0', '$0039E455, $021D160B, 0, 0, 0', '$0039E455, $001D160B, 0, 0, 0',
      'clFuchsia, $021D160B, 0, 0, 0', '$000000FB, $021D160B, 1, 0, 1',
      'clnone, clMaroon', 'clnone, 52377', 'clnone, 1184469',
      'clnone, 8082176',   'clnone, 8421376', 'clnone, 3091750',
      '536870911, 1387264', '536870911, 792320','clSkyBlue, 3483411', 'clYellow, 1906187']);
    9: slist.AddStrings([// Scheme 9: Obisidian
      'clNone, $02343129, 0, 0, 0','$007b7466, clNone, 0, 0, 0', '$00bd82a0, clNone, 0, 0, 0',
      '$0000D500, clNone, 0 0, 0', '$00e4e2e0, clNone, 0, 0, 0','$00b7e2e8, clNone, 0, 0, 0',
      '$0022cdff, clNone, 0, 0, 0','$0022cdff, clNone, 0, 0, 0', '$0022cdff, clNone, 0, 0, 0',
      '$0022cdff, clNone, 0, 0, 0','clOlive, clNone, 0, 0, 0', '$000984ff, clNone, 0, 0, 0',
      '$0063c793, clNone, 0, 0, 0', 'clYellow, clRed, 1, 0, 1',
      'clWhite, clMaroon', 'clnone, $0000cc99', 'clnone, $001212d5',
      'clnone, 5712896',   '16777215, 32896', 'clGray, $00514e40',
      '536870911, 5197647','$00A8E0, clGreen','clSkyBlue, 5328448',  'clYellow, $00514e40']);

    10: slist.AddStrings([ // Scheme 10: Twilight
      'clWhite, clBlack, 0, 0, 0',  'clSilver, clNone, 0, 0, 0','$0000D200, clNone, 0, 0, 0',
      'clAqua, clNone, 0, 0, 0',   'clWhite, clNone, 0, 0, 0', 'clAqua, clNone, 0, 0, 0',
      'clFuchsia, clNone, 0, 0, 0', 'clFuchsia, clNone, 0, 0, 0', 'clFuchsia, clNone, 0, 0, 0',
      'clFuchsia, clNone, 0, 0, 0','clYellow, clNone, 0, 0, 0', 'clYellow, clNone, 0, 0, 0',
      'clLime, clNone, 0, 0, 0',  'clYellow, clRed, 1, 0, 1',
      'clWhite, clMaroon',  'clWhite, clRed', 'clWhite, clMaroon',
      'clnone, 2631720',    '12632256, 11010048',  'clGray, $00514e40',
      '16777215, 2626560', '$00A8E0, clGreen','clGray, 4596480',  'clYellow, 4596480']);
    11: slist.AddStrings([ // Scheme 11: Matrix
      'clWhite, clBlack, 0, 0, 0','clOlive, clBlack, 0, 0, 0', '$00CCCC33, clNone, 0, 0, 0',
      '$00DD6F00, clBlack, 1, 0, 0','clLime, clNone, 0, 0, 0','clSilver, clBlack, 0, 0, 0',
      '$00FF8080, clBlack, 0, 0, 0','$000075EA, clBlack, 0, 0, 0', 'clFuchsia, clNone, 0, 0, 0',
      '$00FF80FF, clBlack, 0, 0, 0', '$00C3C3C3, clNone, 0, 0, 0', '$00FF6633, clNone, 0, 0, 0',
      'clLime, clNone, 0, 0, 0', 'clYellow, clRed, 1, 0, 1',
      'clnone, 27607',    'clnone, 136', 'clnone, 8388736',
      '8421504, 8388608', '16776960, 34304',  '8421504, 5439488',
      '12632256, 3604480','$00A8E0, clGreen','16777215, 13056','clYellow, 8388608']);

    12: slist.AddStrings([// Scheme 12: GSS Hacker
      'clWhite, $00714228, 0, 0, 0', '$00719971, $00714228, 0, 0, 0', '$00FF9C00, $00714228, 0, 0, 0',
      '$0080FFAF, $00714228, 0, 0, 0', 'clWhite, $00714228, 0, 0, 0','clWhite, $00714228, 0, 0, 0',
      '$0000B5B5, $00724227, 0, 0, 0', '$004080FF, $00714228, 0, 0, 0', '$00c9deee, $00171717, 0, 0, 0',
      '$004242FF, $00724227, 0, 0, 0', '$00B0CAFF, $00714228, 0, 0, 0', 'clYellow, $00714228, 0, 0, 0',
      '$00ff9c00, $00171717, 0, 0, 0', 'clYellow, clRed, 1, 0, 1',
      'clWhite, clMaroon', '$00000000, $0000ad41', '$00ffffff, $002620c2',
      'clnone, 8736304',   '16777088, 8388608',  '12615808, 5848320',
      '8421504, 8736304', '$00A8E0, clGreen','16777215, 8865093', 'clYellow, $001c5f4e']);
    13: slist.AddStrings([ // Scheme 13: Borland
      'clWhite, clNavy, 0, 0, 0', 'clTeal, clNone, 0, 0, 0', 'clWhite, clTeal, 0, 0, 0',
      'clWhite, clNone, 0, 0, 0', 'clLime, clNone, 0, 0, 0','$0000C8C8, clNone, 0, 0, 0',
      'clSilver, clNone, 0, 0, 0', 'clSilver, clNone, 0, 0, 0', 'clSilver, clNone, 0, 0, 0',
      'clSilver, clNone, 0, 0, 0', '$008080FF, clNone, 0, 0, 0', 'clFuchsia, clNone, 0, 0, 0',
      'clLime, clNone, 0, 0, 0', 'clYellow, clRed, 1, 0, 1',
      'clnone, 8388736',      'clnone, 128', 'clnone, 2510080',
      '65535, 32896',  '65535, 8421376', '65535, 11141120',
      '12632256, 8213760','43232, 32768','16777215, 6303744', '65408, 6303744'
    ]);
    end;  //case

    ColorScheme.Clear;
    for i := 0  to (ColorSyntax + ColorSpecial) - 1 do begin
      ColorScheme.add('%s=%s', [ColorElemNames[i], slist[i]]);
      //'Space=clBlack, clWhite, 0, 0, 0'
    end;
  finally
    slist.Free;
  end;

  //i := ColorScheme.Count;  //debug
  //for I := 0 to ColorScheme.count -1 do begin //debug
  //  s := fColorElemNames[i]; //debug
  //  s := ColorScheme[i];  //debug
  //end;  //debug
end;

procedure TdevEditor.SettoDefaults;
begin
  // General
  fAutoIndent := TRUE;
  fAddIndent := TRUE;
  fInsertMode := TRUE;
  fUseTabs := TRUE;
  fSmartTabs := FALSE;
  fGroupUndo := TRUE;
  fInsDropFiles := FALSE;
  fShowSpecialChars := FALSE;
  //fShowEndOfLine := FALSE;

  // General #2
  fEHomeKey := TRUE;
  fPastEOF := FALSE;
  fPastEOL := FALSE;
  fFindText := TRUE;
  fShowScrollbars := TRUE; // Show as needed
  fHalfPage := FALSE;
  fShowScrollHint := TRUE;
  fParserHints := TRUE; // Editor hints
  fShowFunctionTip := TRUE;
  fUseCodeFold := TRUE;
  fClickCodeFold := FALSE;
  fTrimTrailingSpaces := FALSE;

  // Caret
  fInsertCaret := 0;
  fOverwriteCaret := 3;
  fMatch := TRUE;

  // Margin
  fMarginVis := False;
  fMarginSize := 80; // disable by default, receiving lots of complaints about it enabled
  fMarginColor := cl3DLight;

  // Misc.
  fUseSyn := TRUE;
  fSynExt := 'c;cpp;h;hpp;cc;cxx;cp;hp;rh;fx;inl;tcc;'; //last ; is for files with no extension
  fHighCurrLine := TRUE;
  fHighColor := $FFFFCC; // Light Turquoise
  fTabSize := 4;

  // Display
  fFont.name := 'Consolas';   //'Courier New';
  fFont.Size := 16;
  //WideFontName := 'NSimSun';  // New Simplified Song for Chinese

  // Display #2
  fShowtopRuler := TRUE;
  fWordWrap := False;
  fShowMinimap := False;
  fShowMacromap: False;
  fGutterAuto := TRUE;
  fCustomGutter := FALSE;
  fLineNumbers := TRUE;
  fFirstisZero := FALSE;
  fLeadZero := FALSE;
  fGutterFont.Name := 'Courier New';
  fGutterFont.Size := 12;
  fGutterSize := 1;

  // ColorSyntax / ColorSpecial are constants now (see interface consts).

  SetColorScheme(1); //set default Color Scheme as 1 (Class Plus)
  ElemIndex := ColorScheme.Count; //debug

  // BuiltinSchemes is a constant now (see interface consts).
  fSchemeIndex := 1;   // 1: Classic plus
  ElemIndex := 4;     // 4: Reserved words

  // Symbol completion
  fCompleteSymbols := TRUE;
  fBraceComplete := TRUE;
  fParentheseComplete := TRUE;
  fIncludeComplete := TRUE;
  fArrayComplete := TRUE;
  fCommentComplete := FALSE;
  fSingleQuoteComplete := TRUE;
  fDoubleQuoteComplete := TRUE;
  fDeleteSymbolPairs := TRUE;

  // Autosave
  fEnableAutoSave := FALSE;
  Interval := 10;
  fAutoSaveFilter := 0;
  fAutoSaveMode := 0;
end;

procedure TdevEditor.AssignEditor(editor: TATSynEdit; const FileName: String);
var
  pt: TPoint;
  CaretShape: TATCaretShape;
  fn: String;
  NBand: integer;
begin
  pt := default(TPoint);
  fn := FileName; // save parameter before 'with' shadows it

  with Editor do begin
    BeginUpdate;
    try
      Modified := False;
      // Set text area properties
      WantTabs := True;
      //OptMaxScrollWidth := 4096; // TODO: ATSynEdit
      OptUndoLimit := 4096;
      BorderStyle := bsNone;

      // Select highlighter based on filename (a lot depends on this)
      AdapterForHilite := TATAdapterHilite(dmMain.GetHighlighter(fn));

      // If EControl adapter returned, add editor to it
      if Assigned(AdapterForHilite) and (AdapterForHilite is TATAdapterEControl) then begin
        TATAdapterEControl(AdapterForHilite).AddEditor(Editor);
        // Populate buffer from editor text and force initial parse
        // (must be after AddEditor so EdList is populated)
        TATAdapterEControl(AdapterForHilite).ParseFromLine(0, True);
        // Apply saved ColorSheme element to lexer formats
        ApplyColorSchemeToLexer(TATAdapterEControl(AdapterForHilite).Lexer,
          TATAdapterEControl(AdapterForHilite));
        // Force editor to repaint with parsed highlighting
        Editor.Invalidate;
      end;
      OptTabSize := fTabSize;
      Font.Assign(fFont);

      // Set selection color (ATSynEdit uses Colors.TextSelBG/TextSelFont)
      if Assigned(AdapterForHilite) then begin
        StrtoPoint(pt, devEditor.ColorScheme.Values[cSel]);
        Colors.TextSelBG := pt.X;
        Colors.TextSelFont := pt.Y;
      end else begin // editor not colored, pick defaults
        Colors.TextSelBG := clNavy;
        Colors.TextSelFont := clWhite;
      end;

      // Set overall editor background from Space element
      StrtoPoint(pt, devEditor.ColorScheme.Values['Space']);
      if pt.X <> clNone then
        Colors.TextBG := pt.X
      else
        Colors.TextBG := clWhite;

      // Set code folding (ATSynEdit uses Opt* properties)
      // Only enable folding when a highlighter adapter is available
      // EControl provides efficient folding; without EControl it's very slow
      OptFoldEnabled := UseCodeFold and Assigned(AdapterForHilite);

      // Set right margin
      if fMarginVis then begin
        OptMarginRight := fMarginSize;
        Colors.MarginRight := fMarginColor; // set margin line color when enabled
      end else begin
        OptMarginRight := 200; // far beyond visible area to effectively hide
        Colors.MarginRight := clNone; // also hide by color
      end;

      OptUnprintedVisible := ShowSpecialChars;// or ShowEndOfLine;  //total switched of unprinted chars
      OptUnprintedSpaces := ShowSpecialChars;   //white-spaces

      OptUnprintedEnds := ShowSpecialChars; //ShowEndOfLine;     //EOL
      OptUnprintedEof := ShowSpecialChars;  //ShowEndOfLine;      //EOF
      OptUnprintedEndsDetails := False; //ShowEndOfLine;   //CRLF


      // Set caret shapes (ATSynEdit uses TATCaretShape objects)
      // Note: fInsertCaret values: 0=HorizontalLine, 1=VerticalLine, 2=HalfVerticalLine
      CaretShape := TATCaretShape.Create;
      try
        case fInsertCaret of
          0: begin // ctHorizontalLine equivalent (thin line at bottom)
            CaretShape.Width := -20; // 25% full character width
            CaretShape.Height := -100; // 100% full character height
            CaretShape.EmptyInside := False;
          end;
          1: begin // ctVerticalLine equivalent (standard I-beam)
            CaretShape.Width := -20; // 20% full width
            CaretShape.Height := -100; // 100% full character height
            CaretShape.EmptyInside := False;
          end;
          2: begin // ctHalfVerticalLine equivalent
            CaretShape.Width := -20;
            CaretShape.Height := -100;
            CaretShape.EmptyInside := True;
          end;
        else
          CaretShape.Width := -20;
          CaretShape.Height := -100;
          CaretShape.EmptyInside := False;
        end;
        CaretShapeNormal.Assign(CaretShape);
      finally
        CaretShape.Free;
      end;

      CaretShape := TATCaretShape.Create;
      try
        case fOverwriteCaret of
          0: begin // ctHorizontalLine equivalent
            CaretShape.Width := -20;
            CaretShape.Height := -100;
            CaretShape.EmptyInside := False;
          end;
          1: begin // ctVerticalLine equivalent
            CaretShape.Width := -20;
            CaretShape.Height := -100;
            CaretShape.EmptyInside := False;
          end;
          2: begin // ctHalfVerticalLine equivalent
            CaretShape.Width := -20;
            CaretShape.Height := -100;
            CaretShape.EmptyInside := True;
          end;
        else
          CaretShape.Width := -100;
          CaretShape.Height := -40;
          CaretShape.EmptyInside := false;
        end;
        CaretShapeOverwrite.Assign(CaretShape);
      finally
        CaretShape.Free;
      end;

      OptShowCurLine := False; // Disable built-in current line highlight;
      // BK_CURRENTLINE bookmark (via EditorCalcBookmarkColor) handles this,
      // and it correctly defers to BK_BREAKPOINT/BK_ERROR/BK_ACTIVEBREAKPOINT colors
      // when those are present on the current line.

      // Set gutter properties
      // NOTE: TATEditorNumbersStyle enum values may vary by version.
      // If numbers don't show, try swapping the integer values.
      OptGutterVisible := True;
      with Gutter do begin
        Visible := True;
        AutoSize := fGutterAuto;
        //if not fGutterAuto and (fGutterSize > 0) then
        //  Width := fGutterSize;
        // ATSynEdit: use OptNumbersStyle instead of separate properties (integer cast)
        if fLineNumbers then
          OptNumbersStyle := TATEditorNumbersStyle(0) // Try 0=All instead of 1
        else
          OptNumbersStyle := TATEditorNumbersStyle(1); // Try 1=None instead of 0
        OptNumbersShowFirst := fFirstisZero; // Show first line number as 0
        // ATSynEdit: line number leading zeros not supported, leave as default
        if Assigned(AdapterForHilite) then begin
          StrtoPoint(pt, fColorScheme.Values[cGut]);
          Color := pt.x;
          Font.Color := pt.y;
        end else begin // editor not colored, pick defaults
          Color := clBtnFace;
          Font.Color := clBlack;
        end;
        // Apply the user's "show line numbers" preference to the numbers band.
        // The other bands (line states, folding) always stay visible.
        NBand := FindIndexByTag(ATEditorOptions.GutterTagNumbers);
        if NBand >= 0 then
          Items[NBand].Visible := fLineNumbers;
      end;
      // Apply the user's "show top ruler" preference
      OptRulerVisible := fShowTopRuler;
      //Set Gutter colors
      if Assigned(AdapterForHilite) then begin
        StrtoPoint(pt, fColorScheme.Values[cGut]);
        Colors.RulerBG := pt.x;
        Colors.RulerFont := pt.y;
        Colors.GutterBG := pt.x;
        Colors.GutterFont := pt.y;
        //Colors.GutterFontActive := fgutColor.y; // 当前行的 gutter 字体颜色（如果有）
        StrtoPoint(pt, fColorScheme.Values[cEdt]);
        Colors.StateSaved := pt.x;
        Colors.StateChanged := pt.y;
        Colors.StateAdded := pt.y;
        StrtoPoint(pt, fColorScheme.Values[cFld]);
        Colors.GutterFoldBG := pt.x;
        Colors.GutterFoldLine := pt.y;
        StrtoPoint(pt, fColorScheme.Values[cFld2]);
        Colors.GutterFoldLine2 := pt.y;
      end;

      // Set option enum (ATSynEdit TATOptionsEdit)
      // Note: Some SynEdit options have no direct ATSynEdit equivalent
      // Original: eoAltSetsColumnMode, eoDisableScrollArrows, eoDragDropEditing,
      //   eoDropFiles, eoKeepCaretX, eoTabsToSpaces, eoRightMouseMovesCursor, eoAutoSizeMaxScrollWidth
      if fAutoIndent then
        OptAutoIndent := True;
      if fSmartTabs then
        OptTabSmart := True; // ATSynEdit: use OptTabSmart
      if fUseTabs then begin
        OptTabSpaces := False; // ATSynEdit: OptTabSpaces=True means spaces instead of tabs
        OptIndentSize := -1; // use 1 tab character per indent level (negative = tabs)
      end else begin
        OptTabSpaces := True;
        OptIndentSize := 2; // use 2 spaces per indent level
      end;
    finally
      EndUpdate;
    end;
  end;
end;

constructor TdevCodeCompletion.Create;
begin
  inherited Create;
  SettoDefaults;
  LoadSettings;
end;

destructor TdevCodeCompletion.Destroy;
begin
end;

procedure TdevCodeCompletion.LoadSettings;
begin
  devData.ReadObject('CodeCompletion', Self);
end;

procedure TdevCodeCompletion.SaveSettings;
begin
  devData.WriteObject('CodeCompletion', Self);
end;

procedure TdevCodeCompletion.SettoDefaults;
begin
  fWidth := 320;
  fHeight := 240;
  fDelay := 180;
  fBackColor := TColor($E1FFFF);  //clWindow;
  fTextColor := clBlack;
  fHighColor := clRed;
  fEnabled := True;
  fShowFunctionHints := True;
  fShowMemberCompletion := True;
  fShowIdentCompletion := False;

  fParseLocalHeaders := True;
  fParseGlobalHeaders := True;
end;

{ TdevClassBrowsing }

constructor TdevClassBrowsing.Create;
begin
  inherited Create;
  SettoDefaults;
  LoadSettings;
end;

procedure TdevClassBrowsing.LoadSettings;
begin
  devData.ReadObject('ClassBrowsing', Self);
end;

procedure TdevClassBrowsing.SaveSettings;
begin
  devData.WriteObject('ClassBrowsing', Self);
end;

procedure TdevClassBrowsing.SettoDefaults;
begin
  fShowFilter := 2; // sfCurrent
  fShowInheritedMembers := False;
end;

{ TdevFormatter }

constructor TdevFormatter.Create;
begin
  inherited Create;
  SettoDefaults;
  LoadSettings;
end;

// 前向声明：ApplyFontStylesFromSyntax 的完整定义在本过程之后，
// 先用 forward 让 ApplyColorSchemeToLexer 及其内嵌过程可以调用它。
procedure ApplyFontStylesFromSyntax(Fmt: TecSyntaxFormat; const SyntaxValue: string); forward;

procedure ApplyColorSchemeToLexer(Lexer: TecSyntAnalyzer; Adapter: TATAdapterEControl);
var
  Fmt: TecSyntaxFormat;
  pt: TPoint;

  procedure SetFmt(const FmtName: string);
  begin
    if devEditor.ColorScheme.IndexOfName(FmtName) < 0 then Exit;
    Fmt := TecSyntaxFormat(Lexer.Formats.ItemByName(FmtName));
    if Assigned(Fmt) then begin
      StrtoPoint(pt, devEditor.ColorScheme.Values[FmtName]);
      Fmt.Font.Color := pt.Y; Fmt.BgColor := pt.X;
      // 字体样式（粗体/斜体/下划线）统一交给 ApplyFontStylesFromSyntax
      ApplyFontStylesFromSyntax(Fmt, devEditor.ColorScheme.Values[FmtName]);
    end;
  end;

  procedure SetFmtFromElem(const ElemName, FmtName: string);
  begin
    if devEditor.ColorScheme.IndexOfName(ElemName) < 0 then Exit;
    Fmt := TecSyntaxFormat(Lexer.Formats.ItemByName(FmtName));
    if Assigned(Fmt) then begin
      StrtoPoint(pt, devEditor.ColorScheme.Values[ElemName]);
      Fmt.Font.Color := pt.Y; Fmt.BgColor := pt.X;
      // 字体样式（粗体/斜体/下划线）统一交给 ApplyFontStylesFromSyntax
      ApplyFontStylesFromSyntax(Fmt, devEditor.ColorScheme.Values[ElemName]);
    end;
  end;

begin
  if not Assigned(Lexer) then Exit;

  // ReservedWord -> Id keyword, Id type, Id special, Id templated
  // 注：C lexer 的类型格式名是 'Id types'（复数，见 lexers/C.lcf），
  //     C++ lexer 是 'Id type'（单数）。两个都找，找不到时 ItemByName 返回 nil。
  SetFmtFromElem('ReservedWord', 'Id keyword');
  SetFmtFromElem('ReservedWord', 'Id type');
  SetFmtFromElem('ReservedWord', 'Id types');
  SetFmtFromElem('ReservedWord', 'Id special');
  SetFmtFromElem('ReservedWord', 'Id templated');

  // Preprocessor -> Preprocessor, Label
  SetFmtFromElem('Preprocessor', 'Preprocessor');
  SetFmtFromElem('Preprocessor', 'Label');

  // Symbol -> Symbol, Operator XX
  SetFmtFromElem('Symbol', 'Symbol');
  SetFmtFromElem('Symbol', 'Operator XX');

  // Direct name matches (element name = format name)
  SetFmt('Asm BG');
  SetFmt('Char');
  SetFmt('Comment');
  SetFmt('Number Float');
  SetFmt('Number Hex/Bin');
  SetFmt('Identifier');
  SetFmt('Incorrect');
  SetFmt('Number');
  SetFmt('Number Oct');
  SetFmt('String');

  if Assigned(Adapter) then
    Adapter.ParseFromLine(0, True);
end;

// 把形如 "clRed,clNone,0,1,0" 的 5 段式颜色值中的字体样式部分
// （第 3/4/5 段 = 粗体/斜体/下划线）应用到 TecSyntaxFormat。
procedure ApplyFontStylesFromSyntax(Fmt: TecSyntaxFormat; const SyntaxValue: string);
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.CommaText := SyntaxValue;
    if sl.Count >= 5 then begin
      Fmt.Font.Style := [];
      if Trim(sl[2]) = '1' then
        Fmt.Font.Style := Fmt.Font.Style + [fsBold];
      if Trim(sl[3]) = '1' then
        Fmt.Font.Style := Fmt.Font.Style + [fsItalic];
      if Trim(sl[4]) = '1' then
        Fmt.Font.Style := Fmt.Font.Style + [fsUnderline];
    end else
      Fmt.Font.Style := [];
  finally
    sl.Free;
  end;
end;

// 把 devEditor.ColorScheme 中记录的各颜色元素应用到指定 Lexer 的各个语法格式上。
// 这是一般化的“配色应用到词法器”过程，供以下两处共用：
//   · TEditorOptForm.ApplyColorSchemeToEditors  —— 应用到选项对话框里的预览编辑器；
//   · ApplyColorSchemeToAllEditors              —— 应用到当前打开的所有编辑器。
// SpaceBG：当某元素自身的背景色为 clNone 时使用的回退背景色；
//          传 clNone 表示不做回退（保持 clNone 不变）。
// 说明：元素名表取单元级常量 ColorElemNames（原 TdevEditor.ColorElemNames 属性已移除）。
procedure ApplyColorElemsToLexer(Lexer: TecSyntAnalyzer; SpaceBG: TColor);
var
  Fmt: TecSyntaxFormat;
  i: integer;
  pt: TPoint;
  ElemName: string;
begin
  if not Assigned(Lexer) then Exit;
  pt := Point(0, 0);  //initialize
  for i := 0 to (ColorSyntax - 1) do begin // apply known syntax element colors to lexer formats
    if i > High(ColorElemNames) then Break;
    ElemName := ColorElemNames[i];
    if ElemName = '' then Continue;

    if SameText(ElemName, 'Space') then
      Continue; // Space is editor background, not a format

    if SameText(ElemName, 'ReservedWord') then begin
      // Apply ReservedWord color to all keyword formats.
      // 'Id type'（单数）= C++ lexer；'Id types'（复数）= C lexer（lexers/C.lcf）。
      // 两个都找，不存在时 ItemByName 返回 nil。
      Fmt := TecSyntaxFormat(Lexer.Formats.ItemByName('Id keyword'));
      if Assigned(Fmt) then begin
        StrtoPoint(pt, devEditor.ColorScheme.Values[ElemName]);
        Fmt.Font.Color := pt.Y; Fmt.BgColor := pt.X;
        ApplyFontStylesFromSyntax(Fmt, devEditor.ColorScheme.Values[ElemName]);
      end;
      Fmt := TecSyntaxFormat(Lexer.Formats.ItemByName('Id type'));
      if Assigned(Fmt) then begin
        StrtoPoint(pt, devEditor.ColorScheme.Values[ElemName]);
        Fmt.Font.Color := pt.Y; Fmt.BgColor := pt.X;
        ApplyFontStylesFromSyntax(Fmt, devEditor.ColorScheme.Values[ElemName]);
      end;
      Fmt := TecSyntaxFormat(Lexer.Formats.ItemByName('Id types'));
      if Assigned(Fmt) then begin
        StrtoPoint(pt, devEditor.ColorScheme.Values[ElemName]);
        Fmt.Font.Color := pt.Y; Fmt.BgColor := pt.X;
        ApplyFontStylesFromSyntax(Fmt, devEditor.ColorScheme.Values[ElemName]);
      end;
      Fmt := TecSyntaxFormat(Lexer.Formats.ItemByName('Id special'));
      if Assigned(Fmt) then begin
        StrtoPoint(pt, devEditor.ColorScheme.Values[ElemName]);
        Fmt.Font.Color := pt.Y; Fmt.BgColor := pt.X;
        ApplyFontStylesFromSyntax(Fmt, devEditor.ColorScheme.Values[ElemName]);
      end;
      Fmt := TecSyntaxFormat(Lexer.Formats.ItemByName('Id templated'));
      if Assigned(Fmt) then begin
        StrtoPoint(pt, devEditor.ColorScheme.Values[ElemName]);
        Fmt.Font.Color := pt.Y; Fmt.BgColor := pt.X;
        ApplyFontStylesFromSyntax(Fmt, devEditor.ColorScheme.Values[ElemName]);
      end;
      Continue;
    end;

    if SameText(ElemName, 'Preprocessor') then begin
      Fmt := TecSyntaxFormat(Lexer.Formats.ItemByName('Preprocessor'));
      if Assigned(Fmt) then begin
        StrtoPoint(pt, devEditor.ColorScheme.Values[ElemName]);
        Fmt.Font.Color := pt.Y; Fmt.BgColor := pt.X;
        ApplyFontStylesFromSyntax(Fmt, devEditor.ColorScheme.Values[ElemName]);
      end;
      Fmt := TecSyntaxFormat(Lexer.Formats.ItemByName('Label'));
      if Assigned(Fmt) then begin
        StrtoPoint(pt, devEditor.ColorScheme.Values[ElemName]);
        Fmt.Font.Color := pt.Y; Fmt.BgColor := pt.X;
        ApplyFontStylesFromSyntax(Fmt, devEditor.ColorScheme.Values[ElemName]);
      end;
      Continue;
    end;

    if SameText(ElemName, 'Symbol') then begin
      Fmt := TecSyntaxFormat(Lexer.Formats.ItemByName('Symbol'));
      if Assigned(Fmt) then begin
        StrtoPoint(pt, devEditor.ColorScheme.Values[ElemName]);
        Fmt.Font.Color := pt.Y; Fmt.BgColor := pt.X;
        ApplyFontStylesFromSyntax(Fmt, devEditor.ColorScheme.Values[ElemName]);
      end;
      Fmt := TecSyntaxFormat(Lexer.Formats.ItemByName('Operator XX'));
      if Assigned(Fmt) then begin
        StrtoPoint(pt, devEditor.ColorScheme.Values[ElemName]);
        Fmt.Font.Color := pt.Y; Fmt.BgColor := pt.X;
        ApplyFontStylesFromSyntax(Fmt, devEditor.ColorScheme.Values[ElemName]);
      end;
      Continue;
    end;

    // Direct name match for all other elements
    Fmt := TecSyntaxFormat(Lexer.Formats.ItemByName(ElemName));
    if Assigned(Fmt) then begin
      StrtoPoint(pt, devEditor.ColorScheme.Values[ElemName]);
      Fmt.Font.Color := pt.Y;
      // If background is clNone, use the fallback background when provided
      if pt.X = clNone then
        Fmt.BgColor := SpaceBG
      else
        Fmt.BgColor := pt.X;
      ApplyFontStylesFromSyntax(Fmt, devEditor.ColorScheme.Values[ElemName]);
    end;
  end;
end;



// 把当前配色方案(devEditor.ColorScheme)应用到当前打开的所有编辑器(MainForm.EditorList)。
// 原为 TEditorOptForm.ApplyColorSchemeToAllEditors，移至本单元，
// 使 EditorOptFrm 与 MainForm 都能直接调用，无需创建窗体实例。
procedure ApplyColorSchemeToAllEditors;
var
  Adapter: TATAdapterEControl;
  Lexer: TecSyntAnalyzer;
  j: integer;
  pt: TPoint;
  Ed: TEditor;
  SpaceBG: TColor;
begin
  if not Assigned(MainForm) then Exit;
  if not Assigned(MainForm.EditorList) then Exit;

  pt := Point(0, 0);  //initialize
  // Get Space element's background color as default
  if devEditor.ColorScheme.IndexOfName('Space') >= 0 then begin
    StrtoPoint(pt, devEditor.ColorScheme.Values['Space']);
    if pt.X <> clNone then
      SpaceBG := pt.X
    else
      SpaceBG := clWhite;
  end else
    SpaceBG := clWhite;

  // Apply colors in Color Scheme to each open editor's adapter
  for j := 0 to MainForm.EditorList.PageCount - 1 do begin
    Ed := MainForm.EditorList[j];
    if not Assigned(Ed) then Continue;
    if not (Assigned(Ed.Text.AdapterForHilite) and (Ed.Text.AdapterForHilite is TATAdapterEControl)) then
      Continue;
    Adapter := TATAdapterEControl(Ed.Text.AdapterForHilite);
    Lexer := Adapter.Lexer;
    if not Assigned(Lexer) then Continue;

    // Apply colors to each format（背景为 clNone 时回退到 Space 的背景色）
    ApplyColorElemsToLexer(Lexer, SpaceBG);

    // Update editor background
    Ed.Text.Colors.TextBG := SpaceBG;

        // Update Bookmark colors from cBM
    if devEditor.ColorScheme.IndexOfName(cBM) >= 0 then begin
      StrtoPoint(pt, devEditor.ColorScheme.Values[cBM]);
      Ed.Text.Colors.BookmarkBG := pt.X;
      //Ed.Text.Colors.TextSelFont := pt.Y;
    end;

    // Update selection colors from cSel
    if devEditor.ColorScheme.IndexOfName(cSel) >= 0 then begin
      StrtoPoint(pt, devEditor.ColorScheme.Values[cSel]);
      Ed.Text.Colors.TextSelBG := pt.X;
      Ed.Text.Colors.TextSelFont := pt.Y;
    end;

    //cCur
    // Disable built-in current line highlight (BK_CURRENTLINE bookmark handles it)
    Ed.Text.OptShowCurLine := False;

    // Refresh current line marker so BK_CURRENTLINE picks up new cCur color
    Ed.UpdateCurrentLineMarker;

    //Apply colors to Editor Gutter;
    // 把当前配色方案中的 gutter/行号/折叠栏/编辑状态颜色应用到单个编辑器。
    // 等价于 TEditorOptForm.SetGutter，但直接读取 devEditor.ColorScheme，不依赖窗体缓存字段。
    StrtoPoint(pt, devEditor.ColorScheme.Values[cGut]);
    Ed.Text.Colors.RulerBG := pt.X;
    Ed.Text.Colors.RulerFont := pt.Y;
    Ed.Text.Colors.GutterBG := pt.X;
    Ed.Text.Colors.GutterFont := pt.Y;
    StrtoPoint(pt, devEditor.ColorScheme.Values[cEdt]);
    Ed.Text.Colors.StateSaved := pt.X;
    Ed.Text.Colors.StateChanged := pt.Y;
    Ed.Text.Colors.StateAdded := pt.Y;
    StrtoPoint(pt, devEditor.ColorScheme.Values[cFld]);
    Ed.Text.Colors.GutterFoldBG := pt.X;
    Ed.Text.Colors.GutterFoldLine := pt.Y;
    StrtoPoint(pt, devEditor.ColorScheme.Values[cFld2]);
    Ed.Text.Colors.GutterFoldLine2 := pt.Y;



    // Force re-parse and repaint
    Adapter.ParseFromLine(0, True);
    Ed.Text.Invalidate;
  end;
end;

procedure TdevFormatter.LoadSettings;
begin
  devData.ReadObject('Formatter', Self);
end;

procedure TdevFormatter.SaveSettings;
begin
  devData.WriteObject('Formatter', Self);
end;

procedure TdevFormatter.SettoDefaults;
begin
  fBracketStyle := 2; // Java
  fIndentStyle := 2; // Tabs
  fTabWidth := 4;
  fModifyMaxLineLength := true;
  fMaxLineLength := 120;
  fAdjustLines := True;
  fAdjustSpaces := True;
  fIndentClasses := True;
  fIndentSwitches := True;
  fIndentCases := False;
  fIndentNamespaces := True;
  fIndentLabels := False;
  fIndentPreprocessor := True;
  fFullCommand := GetFullCommand; // includes customizations
  fAStyleDir := 'AStyle\';
  fAStyleFile := 'AStyle.exe';
end;

function TdevFormatter.GetFullCommand: String;
begin
  Result := '';

  // Add bracket style
  if fBracketStyle > 0 then
    Result := Result + ' -A' + IntToStr(fBracketStyle);

  // Add indent style and tab width
  case fIndentStyle of
    1: Result := Result + ' --indent=spaces=' + IntToStr(fTabWidth);
    2: Result := Result + ' --indent=tab=' + IntToStr(fTabWidth);
    3: Result := Result + ' --indent=force-tab=' + IntToStr(fTabWidth);
    4: Result := Result + ' --indent=force-tab-x=' + IntToStr(fTabWidth);
  end;

  // Add line length
  if fModifyMaxLineLength then
    Result := Result + ' --max-code-length=' + IntToStr(fMaxLineLength);
  // Adjust lines and spaces
  if fAdjustLines then begin
    Result := Result + ' --break-one-line-headers';   // if () aaa
    //Result := Result + ' --break-blocks';    // empty lines before blocks (if, while, for)
  end;

  if fAdjustSpaces then begin
    Result := Result + ' --pad-oper';                 //add space around identifier
    Result := Result + ' --pad-include'; //add space padding after include directives. AStyle v3.6
    Result := Result + ' --pad-header';               //add space between if��while and (
    Result := Result + ' --align-pointer=name';       //*, ^  close to identifier
    Result := Result + ' --align-reference=name';     //&   close to identifier
  end;

  // Add indentation options
  if fIndentClasses then
    Result := Result + ' --indent-classes';
  if fIndentSwitches then
    Result := Result + ' --indent-switches';
  if fIndentCases then
    Result := Result + ' --indent-cases';
  if fIndentNamespaces then
    Result := Result + ' --indent-namespaces';
  if fIndentLabels then
    Result := Result + ' --indent-labels';
  if fIndentPreprocessor then
    Result := Result + '  --indent-preproc-block';   //' --indent-preprocessor';

  Result := TrimLeft(Result);
end;

function TdevFormatter.Validate: Boolean;
begin
  Result := False;

  // Check if AStyle.exe is where it should be
  if not DirectoryExists(devDirs.Exec + fAStyleDir) then
    Exit;
  if not FileExists(devDirs.Exec + fAStyleDir + fAStyleFile) then
    Exit;

  Result := True;
end;

function TdevFormatter.FormatMemory(Editor: TEditor; const OverrideCommand: String): String;
const
  SOURCE = 0;  //SOURCE code
  LINE = 1;    //LINE comment
  BLOCK = 2;   //BLOCK Comment
  CSTRING = 3; //C STRING
var
  FileName: UnicodeString;
  DummyEditor: TATSynEdit;

  i, j, k, n, len, p: integer;
  layer: integer;   //layers of "{"
  emptyline: boolean;
  state: integer;
  ch1, ch2: char ;	//two chars to judge state
begin
  // Store file backup in AStyle dir and format that file
  // Unicode-safe base-name extraction (Editor.FileName is UnicodeString; avoid Ansi conversion)
  p := Length(Editor.FileName);
  while (p > 0) and (Editor.FileName[p] <> '\') and (Editor.FileName[p] <> '/') do Dec(p);
  FileName := devDirs.Exec + fAStyleDir + Copy(Editor.FileName, p + 1, Length(Editor.FileName) - p);
  Editor.Text.Strings.SaveToFile(UTF8String(FileName));
  FormatFile(FileName, OverrideCommand);   //Format the file with AStyle

  // Load formatted file into dummy
  DummyEditor := TATSynEdit.Create(nil);
  try
    // Use replace selection trick to preserve undo list
    DummyEditor.Strings.LoadFromFile(UTF8String(FileName), []);  //load file

    //{ (removed stray brace that opened unterminated comment)
    //Do some replaces and add some empty lines.
    state := SOURCE;
    //n := min(e.Text.Lines.Count, 100);
    n := DummyEditor.Strings.Count;
    layer := 0;   //number of left parenthesis mark {
    ch1 := #0;
    for i := 0 to n-1 do begin
        //replace '#include<' with '#include <', replace '#include"' with '#include "'
        //// AStyle 3.6.0 has had option "--pad-include".
//      if (fAdjustspaces and (pos('#include', DummyEditor.Lines[i])> 0)) then begin
//        DummyEditor.Lines[i] := stringreplace (DummyEditor.Lines[i], '#include<', '#include <', []);
//       DummyEditor.Lines[i] := stringreplace (DummyEditor.Lines[i], '#include"', '#include "', []);
//      end;

      // Add empty line between functions
      //// AStyle 3.5.2 has had option"--break-blocks", but not functional.   //by Anbang LI
      if (fAdjustLines) then begin
        len := length(DummyEditor.Strings.Lines[i]);
        if (len = 0) then
          emptyline := true  //here has a empty line
        else
          emptyline := false;
        j := 1;
        while (j <= len) do begin
          ch2 := DummyEditor.Strings.Lines[i][j];   //read one new char
          if ((state = SOURCE) and (ch1 = #47) and (ch2 = #42)) then // get /*, SOURCE -> BLOCK comment
            state := BLOCK
          else if ((state = BLOCK) and (ch1 = #42) and (ch2 = #47)) then begin // get */, BLOCK -> SOURCE
            state := SOURCE;
            inc(j);   //j++
            ch2 := DummyEditor.Strings.Lines[i][j];
            ch1 := ch2; //�����������ַ��жϲ�������һ��״̬ת���������ȡһ���ַ�?
            //continue;	//��ע��ĩβ�ַ�������?
          end else if ((state = SOURCE) and (ch1 = #47) and (ch2 = #47)) then begin //SOURCE->LINE (// line comment)
            ch1 := #0;
            state := SOURCE;
            break;  //jump over this line
          end else if ((state = LINE) and (ch2 = #13)) then begin	//LINE ->SOURCE
            state := SOURCE;
            ch1 := ch2;
            inc(j);
            ch2 := DummyEditor.Strings.Lines[i][j];	//read one more character
          end else if ((state = SOURCE) and (ch1 <> #92) and (ch2 = #34)) then//SOURCE -> CSTRING��exclude \"
            state := CSTRING
          else if ((state = CSTRING) and (ch1 <> #92) and (ch2 = #34) ) then // " but not \" CSTRING ->SOURCE��exclude \"
            state := SOURCE;

          if ((state = SOURCE) and (ch2 = #123)) then begin //'{'   //e.Text.Lines[i][j]
            layer := layer + 1;
            if ((i > 0) and (layer = 1) and (not emptyline)) then begin //only one layer of "{"
              k := i - 1;   //upward one line

              if (k > 0) and (j = 1) then    //if "{" located at line head, then upward one more line
                dec(k);
              // upward, find no-comment line
              if (pos('*/', DummyEditor.Strings.Lines[k])> 0) then  // block comments
                while ((k > 0) and (pos('/*', DummyEditor.Strings.Lines[k]) <= 0)) do
                  dec(k);    // find the line contains /*
              if (pos('/*', DummyEditor.Strings.Lines[k]) > 0) then //block comment beginning
                if (k > 0) then  // not line 0
                  dec(k)      // upward one line from block comments
                else begin          // line 0 contains "/*"
                  k := i - 1;    //jump to line i - 1
                  if (k > 0) and (j = 1) then
                    dec (k);
                end;
              while ((k > 0) and (pos('//', DummyEditor.Strings.Lines[k])= 1)) do  //line comments
                dec(k); //upward jump over line comments
              //e.Text.CaretX := 1;
              //e.Text.CaretY := k;
              //e.InsertString (#13#10, true);
              len := length(DummyEditor.Strings.Lines[k]);
              if length(DummyEditor.Strings.Lines[k]) <> 0 then
                DummyEditor.Strings.Lines[k] := DummyEditor.Strings.Lines[k] + #13#10 ;  //add emptyline
            end;
          end;

          if ((state = SOURCE) and (ch2 = #125)) then begin //' right big brace'
            layer := layer - 1;
            if (layer = 0) then
              emptyline := False;   //reset empty lines
          end;

          ch1 := ch2;
          inc(j);
        end;  //while column j
      end; //if (fAdjustLines)
    end; // for line i
    //} (removed stray brace)

    //DummyEditor.Strings.SaveToFile(FileName);
    //DummyEditor.Strings.LoadFromFile(FileName, []);

    // ATSynEdit: replace all text via select+delete+insert to create undo history
    Editor.Text.Strings.BeginUndoGroup;
    try
      Editor.Text.DoCommand(cCommand_SelectAll, TATCommandInvoke(0), '');
      Editor.Text.DoCommand(cCommand_TextDeleteSelection, TATCommandInvoke(0), '');
      Editor.Text.TextInsertAtCarets(DummyEditor.Text, False, False, False);
    finally
      Editor.Text.Strings.EndUndoGroup;
    end;
    Editor.Text.Modified := True;
    Editor.Text.Invalidate;
  finally
    DummyEditor.Free;
  end;
  result := '';
end;

function TdevFormatter.FormatFile(const FileName: UnicodeString; const OverrideCommand: String): String;
var
  RunCommand, WorkingDir: String;
begin
  WorkingDir := devDirs.Exec + fAStyleDir;
  RunCommand := fAStyleFile + ' ' + OverrideCommand + ' "' + FileName + '"';
  Result := RunAndGetOutput(WorkingDir + RunCommand, WorkingDir, nil, nil, False);
end;

function TdevFormatter.GetVersion: String;
var
  RunCommand, WorkingDir: String;
begin
  WorkingDir := devDirs.Exec + fAStyleDir;
  RunCommand := fAStyleFile + ' --version';
  Result := RunAndGetOutput(WorkingDir + RunCommand, WorkingDir, nil, nil, False);
end;

{ TdevExternalPrograms }

function TdevExternalPrograms.AddProgram(ext, prog: String): integer;
var
  idx: integer;
begin
  if ext = '' then begin
    Result := -1;
    Exit;
  end;

  idx := AssignedProgram(ext);
  if idx = -1 then
    Result := fPrograms.Add(ext + '=' + prog)
  else begin
    fPrograms.Values[fPrograms.Names[idx]] := prog;
    Result := idx;
  end;
end;

function TdevExternalPrograms.AssignedProgram(const ext: String): integer;
var
  I: integer;
begin
  Result := -1;
  for I := 0 to fPrograms.Count - 1 do
    if SameText(fPrograms.Names[I], ext) then begin
      Result := I;
      Break;
    end;
end;

constructor TdevExternalPrograms.Create;
begin
  inherited Create;
  fPrograms := TStringList.Create;
  SettoDefaults;
  LoadSettings;
end;

destructor TdevExternalPrograms.Destroy;
begin
  fPrograms.Free;
end;

function TdevExternalPrograms.GetProgramName(Index: integer): String;
begin
  Result := fPrograms.Values[fPrograms.Names[Index]];
end;

procedure TdevExternalPrograms.LoadSettings;
begin
  devData.ReadObject('ExternalPrograms', Self);
end;

procedure TdevExternalPrograms.SaveSettings;
begin
  devData.WriteObject('ExternalPrograms', Self);
end;

procedure TdevExternalPrograms.SetToDefaults;
begin
  inherited;
end;

end.

