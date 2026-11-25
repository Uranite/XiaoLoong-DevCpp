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

{$H+,J+,I+}
{$mode ObjFPC}{$H+}

{$APPTYPE GUI}
unit main;

interface

uses
{$IFDEF MSWINDOWS}
  Windows, Win32Proc, Registry,
{$ELSE}
  LCLIntf, LCLType,
{$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Process, Menus, StdCtrls, ComCtrls, ExtCtrls, Buttons, ImgList, utils,
  uMetaDarkStyle, uDarkStyleParams, udarkstyleschemes,
  Project, Editor, DateUtils, ActnList, ToolFrm, debugger, ClassBrowser,
  compiler, CodeCompletion,  CppParser, CppTokenizer, SyncObjs,
  StrUtils, ATSynEdit, devFileMonitor, EditorList,
  singleinstance, AdvancedSingleInstance,
  devCFG, UpdateCheck, debugreader, ExceptionFrm, CommCtrl,
  CppPreprocessor, CBUtils, StatementList, FormatterOptFrm, ShortcutsFrm,
  ATSynEdit_Globals;

type
  TRunEndAction = (reaNone, reaProfile);
  TCompSuccessAction = (csaNone, csaRun, csaDebug, csaProfile);

  { TMainForm }

  TMainForm = class(TForm)
    actFileEncoding: TAction;
    actImportCB: TAction;
    actColorAutoMode: TAction;
    actColorDarkMode: TAction;
    actIconThemeClassic: TAction;
    actIconThemeOutline: TAction;
    actColorScheme: TAction;
    actColorLightMode: TAction;
    actShowLineNumber: TAction;
    actShowTopRuler: TAction;
    DeleteToLineBegin: TMenuItem;
    DeleteToLineEnd: TMenuItem;
    EvaluateInput: TComboBox;
    lblEvaluate: TLabel;
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    Encoding: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    ColorSchemeItem: TMenuItem;
    AutoModeItem: TMenuItem;
    DarkModeItem: TMenuItem;
    LightModeItem: TMenuItem;
    IconThemeClassicItem: TMenuItem;
    IconThemeOutlineItem: TMenuItem;
    ShowLineNumberItem: TMenuItem;
    ShowRulerItem: TMenuItem;
    NewprojectItem: TMenuItem;
    NewTemplateItem: TMenuItem;
    N34: TMenuItem;
    OpenprojectItem: TMenuItem;
    ClearhistoryItem: TMenuItem;
    N11: TMenuItem;
    NewSourceFileItem: TMenuItem;
    EvalCmdPanel: TPanel;
    SaveUnitItem: TMenuItem;
    SaveUnitAsItem: TMenuItem;
    SaveallItem: TMenuItem;
    N33: TMenuItem;
    CloseprojectItem: TMenuItem;
    CloseItem: TMenuItem;
    ExportItem: TMenuItem;
    HTMLItem: TMenuItem;
    RTFItem: TMenuItem;
    N19: TMenuItem;
    ProjecttoHTMLItem: TMenuItem;
    PrintItem: TMenuItem;
    PrinterSetupItem: TMenuItem;
    ImportMSVisualCproject: TMenuItem;
    ImportCBCproject: TMenuItem;
    N3: TMenuItem;
    ExitItem: TMenuItem;
    EditMenu: TMenuItem;
    Separator1: TMenuItem;
    Separator2: TMenuItem;
    Separator3: TMenuItem;
    Separator4: TMenuItem;
    UndoItem: TMenuItem;
    RedoItem: TMenuItem;
    N4: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    //ToggleBookmarksItem: TMenuItem;
    //GotoBookmarksItem: TMenuItem;
    ToggleBookmarks: TMenuItem;
    PrevBookmark: TMenuItem;
    NextBookmark: TMenuItem;
    SelectallItem: TMenuItem;
    SearchMenu: TMenuItem;
    FindItem: TMenuItem;
    ReplaceItem: TMenuItem;
    N7: TMenuItem;
    GotolineItem: TMenuItem;
    ViewMenu: TMenuItem;
    ProjectManagerItem: TMenuItem;
    StatusbarItem: TMenuItem;
    ToolMainItem: TMenuItem;
    ProjectMenu: TMenuItem;
    NewunitinprojectItem: TMenuItem;
    AddtoprojectItem: TMenuItem;
    RemovefromprojectItem: TMenuItem;
    N6: TMenuItem;
    ProjectoptionsItem: TMenuItem;
    ExecuteMenu: TMenuItem;
    CompileItem: TMenuItem;
    RunItem: TMenuItem;
    N10: TMenuItem;
    CompileandRunItem: TMenuItem;
    RebuildallItem: TMenuItem;
    N8: TMenuItem;
    CompileroptionsItem: TMenuItem;
    EnvironmentoptionsItem: TMenuItem;
    ToolsMenu: TMenuItem;
    ConfiguretoolsItem: TMenuItem;
    WindowMenu: TMenuItem;
    CloseAllItem: TMenuItem;
    N28: TMenuItem;
    FullscreenmodeItem: TMenuItem;
    N36: TMenuItem;
    NextItem: TMenuItem;
    PreviousItem: TMenuItem;
    N32: TMenuItem;
    HelpMenu: TMenuItem;
    AboutDevCppItem: TMenuItem;
    MessageControl: TPageControl;
    CompSheet: TTabSheet;
    ResSheet: TTabSheet;
    ResourceOutput: TListView;
    LogSheet: TTabSheet;
    ToolbarDock: TControlBar;
    CleanItem: TMenuItem;
    CloseSheet: TTabSheet;
    EditorPopup: TPopupMenu;
    UndoPopItem: TMenuItem;
    RedoPopItem: TMenuItem;
    MenuItem1: TMenuItem;
    CutPopItem: TMenuItem;
    CopyPopItem: TMenuItem;
    PastePopItem: TMenuItem;
    MenuItem2: TMenuItem;
    InsertPopItem: TMenuItem;
    pmInsert: TPopupMenu;
    //TogglebookmarksPopItem: TMenuItem;
    //GotobookmarksPopItem: TMenuItem;
    ToggleBookmarks1: TMenuItem;
    GotoPrevBookmark1: TMenuItem;
    GotoNextBookmark1: TMenuItem;
    SelectAllPopItem: TMenuItem;
    UnitPopup: TPopupMenu;
    RemoveFilefromprojectPopItem: TMenuItem;
    RenamefilePopItem: TMenuItem;
    N30: TMenuItem;
    ClosefilePopItem: TMenuItem;
    ProjectPopup: TPopupMenu;
    NewunitinprojectPopItem: TMenuItem;
    AddtoprojectPopItem: TMenuItem;
    RemovefromprojectPopItem: TMenuItem;
    MenuItem18: TMenuItem;
    ProjectoptionsPopItem: TMenuItem;
    Statusbar: TStatusbar;
    FindSheet: TTabSheet;
    FindOutput: TListView;
    FindinallfilesItem: TMenuItem;
    N20: TMenuItem;
    ActionList: TActionList;
    actNewSource: TAction;
    actNewProject: TAction;
    actNewTemplate: TAction;
    actOpen: TAction;
    actHistoryClear: TAction;
    actSave: TAction;
    actSaveAs: TAction;
    actSaveAll: TAction;
    actClose: TAction;
    actCloseAll: TAction;
    actCloseProject: TAction;
    actExportHTML: TAction;
    actExportRTF: TAction;
    actExportProject: TAction;
    actPrint: TAction;
    actPrintSU: TAction;
    actExit: TAction;
    actUndo: TAction;
    actRedo: TAction;
    actCut: TAction;
    actCopy: TAction;
    actPaste: TAction;
    actSelectAll: TAction;
    actFind: TAction;
    actFindAll: TAction;
    actReplace: TAction;
    actGotoLine: TAction;
    actProjectManager: TAction;
    actShowSpecialChars: TAction;
    actShowMinimap: TAction;
    actShowMacromap: TAction;
    actWordWrap: TAction;
    actScrollUp: TAction;
    actScrollDown: TAction;
    ShowSpecialCharsItem: TMenuItem;
    ShowMinimapItem: TMenuItem;
    ShowMacromapItem: TMenuItem;
    WordWrapItem: TMenuItem;
    ScrollUpItem: TMenuItem;
    ScrollDownItem: TMenuItem;
    actStatusbar: TAction;
    actProjectNew: TAction;
    actProjectAdd: TAction;
    actProjectRemove: TAction;
    actProjectOptions: TAction;
    actCompile: TAction;
    actRun: TAction;
    actCompRun: TAction;
    actRebuild: TAction;
    actClean: TAction;
    actDebug: TAction;
    actCompOptions: TAction;
    actEnviroOptions: TAction;
    actEditorOptions: TAction;
    actConfigTools: TAction;
    actFullScreen: TAction;
    actNextWindow: TAction;
    actPrevWindow: TAction;
    actHelpAbout: TAction;
    actProjectSource: TAction;
    actUnitRemove: TAction;
    actUnitRename: TAction;
    actUnitHeader: TAction;
    actUnitOpen: TAction;
    actUnitClose: TAction;
    EditorOptionsItem: TMenuItem;
    OpenPopItem: TMenuItem;
    actProjectMakeFile: TAction;
    MessagePopup: TPopupMenu;
    MsgCopyItem: TMenuItem;
    MsgCopyAllItem: TMenuItem;
    MsgSaveAllItem: TMenuItem;
    MsgClearItem: TMenuItem;
    actBreakPoint: TAction;
    actIncremental: TAction;
    IncrementalSearch1: TMenuItem;
    actShowBars: TAction;
    EditorPageControlLeft: TPageControl;
    Close1: TMenuItem;
    N16: TMenuItem;
    DebugSheet: TTabSheet;
    actAddWatch: TAction;
    actEditWatch: TAction;
    actNextLine: TAction;
    actContinue: TAction;
    actWatchItem: TAction;
    actRemoveWatch: TAction;
    actStopExecute: TAction;
//    CppParser: TCppParser;
//    CodeCompletion: TCodeCompletion;
    N22: TMenuItem;
    Swapheadersource1: TMenuItem;
    N23: TMenuItem;
    actSwapHeaderSource: TAction;
    InsertItem: TMenuItem;
    SyntaxCheckItem: TMenuItem;
    actSyntaxCheck: TAction;

    //Shortcuts: TdevShortcuts;
    actConfigShortcuts: TAction;
    ConfiguredevShortcuts1: TMenuItem;
    N25: TMenuItem;
    Programreset1: TMenuItem;
    actComment: TAction;
    actUncomment: TAction;
    actIndent: TAction;
    actUnindent: TAction;
    N26: TMenuItem;
    Comment: TMenuItem;
    Uncomment: TMenuItem;
    Indent: TMenuItem;
    Unindent: TMenuItem;
    N27: TMenuItem;
    actGotoFunction: TAction;
    Gotofunction1: TMenuItem;
    BrowserPopup: TPopupMenu;
    mnuBrowserGotoDecl: TMenuItem;
    mnuBrowserGotoImpl: TMenuItem;
    mnuBrowserSep1: TMenuItem;
    mnuBrowserNewClass: TMenuItem;
    mnuBrowserNewMember: TMenuItem;
    mnuBrowserNewVariable: TMenuItem;
    mnuBrowserViewMode: TMenuItem;
    mnuBrowserViewAll: TMenuItem;
    mnuBrowserViewCurrent: TMenuItem;
    actBrowserGotoDeclaration: TAction;
    actBrowserGotoDefinition: TAction;
    actBrowserNewClass: TAction;
    actBrowserNewMember: TAction;
    actBrowserNewVar: TAction;
    actBrowserViewAll: TAction;
    actBrowserViewCurrent: TAction;
    actProfile: TAction;
    N29: TMenuItem;
    Profileanalysis1: TMenuItem;
    N24: TMenuItem;
    N31: TMenuItem;
    actBrowserAddFolder: TAction;
    actBrowserRemoveFolder: TAction;
    actBrowserRenameFolder: TAction;
    actCloseAllButThis: TAction;
    CloseAll2: TMenuItem;
    actStepLine: TAction;
    DebugPopup: TPopupMenu;
    AddwatchPop: TMenuItem;
    RemoveWatchPop: TMenuItem;

    actFileProperties: TAction;
    N35: TMenuItem;
    N1: TMenuItem;
    Properties: TMenuItem;
    actViewToDoList: TAction;
    actAddToDo: TAction;
    AddToDoitem1: TMenuItem;
    N38: TMenuItem;
    ToDolist1: TMenuItem;
    N39: TMenuItem;
    actProjectNewFolder: TAction;
    actProjectRemoveFolder: TAction;
    actProjectRenameFolder: TAction;
    Newfolder1: TMenuItem;
    N40: TMenuItem;
    actImportMSVC: TAction;
    ImportItem: TMenuItem;
    actViewCPU: TAction;
    actExecParams: TAction;
    mnuExecParameters: TMenuItem;
    actHelpTips: TAction;
    ShowTipsItem: TMenuItem;
    N42: TMenuItem;
    actBrowserViewProject: TAction;
    mnuBrowserViewProject: TMenuItem;
    N43: TMenuItem;
    PackageManagerItem: TMenuItem;
    actAbortCompilation: TAction;
    N48: TMenuItem;
    ListItem: TMenuItem;
    mnuFileProps: TMenuItem;
    mnuUnitProperties: TMenuItem;
    actBrowserShowInherited: TAction;
    Showinheritedmembers1: TMenuItem;
    LeftPageControl: TPageControl;
    LeftProjectSheet: TTabSheet;
    ProjectView: TTreeView;
    BrowserView: TTreeView; //

    LeftClassSheet: TTabSheet;
    //ClassBrowser: TClassBrowser;

    FloatingPojectManagerItem: TMenuItem;
    actSaveProjectAs: TAction;
    SaveprojectasItem: TMenuItem;
    mnuOpenWith: TMenuItem;
    LeftDebugSheet: TTabSheet;
    DebugStartPanel: TPanel;
    N67: TMenuItem;
    FloatingReportwindowItem: TMenuItem;
    actAttachProcess: TAction;
    ModifyWatchPop: TMenuItem;
    actModifyWatch: TAction;
    ClearallWatchPop: TMenuItem;
    CompilerOutput: TListView;
    NewClassItem: TMenuItem;
    DeleteProfilingInformation: TMenuItem;
    actDeleteProfile: TAction;
    GotoDefineEditor: TMenuItem;
    GotoDeclEditor: TMenuItem;
    N15: TMenuItem;
    actGotoDeclEditor: TAction;
    actGotoImplEditor: TAction;
    N64: TMenuItem;
    N77: TMenuItem;
    N78: TMenuItem;
    CollapseAll: TMenuItem;
    UncollapseAll: TMenuItem;
    actCollapse: TAction;
    actUnCollapse: TAction;
    actInsert: TAction;
    //actToggle: TAction;
    //actGoto: TAction;
    TEXItem: TMenuItem;
    actExportTex: TAction;
    DebugOutput: TMemo;
    DebugSendPanel: TPanel;
    EvalOutput: TMemo;
    actSkipFunction: TAction;
    actNextIns: TAction;
    actStepIns: TAction;
    MsgPasteItem: TMenuItem;
    actMsgCopy: TAction;
    actMsgCopyAll: TAction;
    actMsgPaste: TAction;
    actMsgClear: TAction;
    actMsgSaveAll: TAction;
    actReplaceAll: TAction;
    ReplaceAll1: TMenuItem;
    N72: TMenuItem;
    actMsgCut: TAction;
    actMsgCut1: TMenuItem;
    N71: TMenuItem;
    N73: TMenuItem;
    N74: TMenuItem;
    MsgSellAllItem: TMenuItem;
    actMsgSelAll: TAction;
    actNewClass: TAction;
    actSearchAgain: TAction;
    actSearchAgain1: TMenuItem;
    N75: TMenuItem;
    SplitterBottom: TSplitter;
    N76: TMenuItem;
    Abortcompilation1: TMenuItem;
    oggleBreakpoint1: TMenuItem;
    actRevSearchAgain: TAction;
    SearchAgainBackwards1: TMenuItem;
    actDeleteLine: TAction;
    actDeleteToLineEnd: TAction;
    actDeleteToLineBegin: TAction;
    N21: TMenuItem;
    actToggleComment: TAction;
    ToggleComment: TMenuItem;
    actDuplicateLine: TAction;
    N37: TMenuItem;
    DuplicateLine: TMenuItem;
    DeleteLine: TMenuItem;
    actBrowserViewIncludes: TAction;
    mnuBrowserViewInclude: TMenuItem;
    actMoveSelUp: TAction;
    actMoveSelDown: TAction;
    N68: TMenuItem;
    MoveSelUp: TMenuItem;
    MoveSelDown: TMenuItem;
    actCodeCompletion: TAction;
    actPackageCheck: TAction;
    actPackageManager: TAction;
    actHelpTutorial: TAction;
    N49: TMenuItem;
    N69: TMenuItem;
    CloseProject1: TMenuItem;
    actShortenCompPaths: TAction;
    actSyntaxCheckFile: TAction;
    SyntaxCheckCurrentFile1: TMenuItem;
    PageControlPanel: TPanel;
    EditorPageControlRight: TPageControl;
    EditorPageControlSplitter: TSplitter;
    actSwapEditor: TAction;
    Movetootherview1: TMenuItem;
    N14: TMenuItem;
    MoveToOtherViewItem: TMenuItem;
    SwapHeaderSourceItem: TMenuItem;
    actOpenFolder: TAction;
    actOpenFolder1: TMenuItem;
    actGotoBreakPoint: TAction;
    Abortcompilation2: TMenuItem;
    actToggleCommentInline: TAction;
    actCommentInlineSel: TMenuItem;
    actFormatCurrentFile: TAction;
    actFormatOptions: TAction;
    actRunTests: TAction;
    N47: TMenuItem;
    HelpGNUCLib: TMenuItem;
    N50: TMenuItem;
    actHelpCLib: TAction;
    actHelpFAQ: TAction;
    actHelpDonate: TAction;
    actMsgTranslate: TAction;
    actHelpHomepage: TAction;
    RunTests: TMenuItem;
    Donate1: TMenuItem;
    actNewFiles: TAction;
    actToggleBookmark: TAction;
    actPrevBookmark: TAction;
    actNextBookmark: TAction;
    actToolbar: TAction;
    N2: TMenuItem;
    tbProjectLeft: TToolBar;
    tbnNewProject: TToolButton;
    ToolButton2: TToolButton;
    tbnProjectNew: TToolButton;
    tbnNewClass: TToolButton;
    tbnProjectAdd: TToolButton;
    tbnProjectRemove: TToolButton;
    ToolButton26: TToolButton;
    tbnProjectOptions: TToolButton;
    tbDebugLeft: TToolBar;
    tbnAddWatch: TToolButton;
    tbnRemoveWatch: TToolButton;
    DebugView: TTreeView;
    SplitterDebug: TSplitter;
    tbnModifyWatch: TToolButton;
    DebugCmdPanel: TPanel;
    lblSendCommandGdb: TLabel;
    cmbGdbCommand: TComboBox;
    btnCmdNext: TSpeedButton;
    btnCmdStep: TSpeedButton;
    btnCmdfinish: TSpeedButton;
    btnCmdContinue: TSpeedButton;
    btnNextIns: TSpeedButton;
    btnIntoIns: TSpeedButton;
    btnViewCPU: TSpeedButton;
    actHelpManual: TAction;
    HelpTutorial: TMenuItem;
    HelpManual: TMenuItem;
    HelpFAQ: TMenuItem;
    HelpHomepage: TMenuItem;
    actRuntoCursor: TAction;
    btnCmdUntil: TSpeedButton;
    txtLocals: TMemo;
    cbWatchLocals: TCheckBox;
    Nextline1: TMenuItem;
    Intoline1: TMenuItem;
    Skipfunction1: TMenuItem;
    ToolFileExplorer: TMenuItem;
    OpenConsole: TMenuItem;
    SetConsoleLarge: TMenuItem;
    SetConsoleDefault: TMenuItem;
    TextDiff: TMenuItem;
    actFileExplorer: TAction;
    actConsoleOpen: TAction;
    actConsoleLarge: TAction;
    actConsoleDefault: TAction;
    actCodeDiff: TAction;
    N5: TMenuItem;
    FolderPopup: TPopupMenu;
    Addfolder2: TMenuItem;
    Renamefolder2: TMenuItem;
    Removefolder2: TMenuItem;
    N44: TMenuItem;
    SourceFile1: TMenuItem;
    Addfile1: TMenuItem;
    tbMain: TToolBar;
    btnNew: TToolButton;
    btnOpen: TToolButton;
    btnSave: TToolButton;
    btnSaveAll: TToolButton;
    btnClose: TToolButton;
    btnSep1: TToolButton;
    btnUndo: TToolButton;
    btnRedo: TToolButton;
    btnCut: TToolButton;
    btnSep2: TToolButton;
    btnCopy: TToolButton;
    btnPaste: TToolButton;
    btnSep3: TToolButton;
    btnInsert: TToolButton;
    btnComment: TToolButton;
    btnFind: TToolButton;
    btnSep4: TToolButton;
    btnCompile: TToolButton;
    btnRun: TToolButton;
    btnCompRun: TToolButton;
    btnSep5: TToolButton;
    btnDebug: TToolButton;
    btnStop: TToolButton;
    btnNext: TToolButton;
    btnStep: TToolButton;
    btnSkipFunc: TToolButton;
    btnSep6: TToolButton;
    btnHomepage: TToolButton;
    MessageManagerItem: TMenuItem;
    //actOutputManager: TAction;
    actMessagePanel: TAction;
    SplitterLeft: TSplitter;
    Splitter2: TBevel;
    FixHiDPI: TMenuItem;
    actFixHighDPI: TAction;
    ShowCodeCompletion: TMenuItem;
    LogLeftPanel: TPanel;
    btnAbortCompilation: TSpeedButton;
    pbCompilation: TProgressBar;
    chkShortenPaths: TCheckBox;
    chkTranslateMsg: TCheckBox;
    LogRightPanel: TPanel;
    LogOutput: TMemo;
    AddToDoitem: TMenuItem;

    //ToggleBookmarks: TMenuItem;
    //GotoPrevBookmark1: TMenuItem;
    //GotoNextBookmark1: TMenuItem;
    procedure actColorAutoModeExecute(Sender: TObject);
    procedure actColorDarkModeExecute(Sender: TObject);
    procedure actFileEncodingExecute(Sender: TObject);
    procedure actIconThemeClassicExecute(Sender: TObject);
    procedure actIconThemeOutlineExecute(Sender: TObject);
    procedure actIconThemeExecute(Sender: TObject);
    procedure actColorLightModeExecute(Sender: TObject);
    procedure actShowTopRulerExecute(Sender: TObject);
    procedure AskRestartAndRestart();
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure actImportCBExecute(Sender: TObject);

    //procedure ToggleBookmarkClick(Sender: TObject);
    //procedure GotoBookmarkClick(Sender: TObject);

    procedure MessageControlChange(Sender: TObject);
    procedure ProjectViewContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure actShowLineNumberExecute(Sender: TObject);
    procedure StatusbarDrawPanel(AStatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure StatusbarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StatusbarResize(Sender: TObject);
    procedure ToolbarDockClick(Sender: TObject);
    procedure ToolbarDockContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure SplitterBottomMoved(Sender: TObject);
    procedure actNewSourceExecute(Sender: TObject);
    procedure actNewProjectExecute(Sender: TObject);
    procedure actNewTemplateExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actHistoryClearExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actSaveAsExecute(Sender: TObject);
    procedure actSaveAllExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actCloseAllExecute(Sender: TObject);
    procedure actCloseProjectExecute(Sender: TObject);
    procedure actExportHTMLExecute(Sender: TObject);
    procedure actExportRTFExecute(Sender: TObject);
    procedure actExportTexExecute(Sender: TObject);
    procedure actExportProjectExecute(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
    procedure actPrintSUExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actUndoExecute(Sender: TObject);
    procedure actRedoExecute(Sender: TObject);
    procedure actCutExecute(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actProjectManagerExecute(Sender: TObject);
    procedure actToolBarExecute(Sender: TObject);
    procedure actStatusBarExecute(Sender: TObject);
    procedure actFullScreenExecute(Sender: TObject);
    procedure actNextWindowExecute(Sender: TObject);
    procedure actPrevWindowExecute(Sender: TObject);
    procedure actCompOptionsExecute(Sender: TObject);
    procedure actEditorOptionsExecute(Sender: TObject);
    procedure actConfigToolsExecute(Sender: TObject);
    procedure actUnitRemoveExecute(Sender: TObject);
    procedure actUnitRenameExecute(Sender: TObject);
    procedure actUnitOpenExecute(Sender: TObject);
    procedure actUnitCloseExecute(Sender: TObject);

    procedure actProjectNewExecute(Sender: TObject);
    procedure actProjectAddExecute(Sender: TObject);
    procedure actProjectRemoveExecute(Sender: TObject);
    procedure actProjectOptionsExecute(Sender: TObject);
    procedure actProjectSourceExecute(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actFindAllExecute(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure actGotoLineExecute(Sender: TObject);
    procedure actCompileExecute(Sender: TObject);
    procedure actRunExecute(Sender: TObject);
    procedure actCompRunExecute(Sender: TObject);
    procedure actRebuildExecute(Sender: TObject);
    procedure actCleanExecute(Sender: TObject);
    procedure actDebugExecute(Sender: TObject);
    procedure actEnviroOptionsExecute(Sender: TObject);
    procedure actProjectMakeFileExecute(Sender: TObject);
    procedure actMsgCopyExecute(Sender: TObject);
    procedure actMsgClearExecute(Sender: TObject);
    procedure actMessagePanelExecute(Sender: TObject);
    procedure ClassicThemeItemClick(Sender: TObject);
    procedure CleanThemeItemClick(Sender: TObject);
    procedure SetIconTheme(const ATitle: String);
    procedure UpdateIconThemeChecks;
    // Editor color scheme sub-menu
    procedure BuildColorSchemeMenu;
    procedure ColorSchemeItemClick(Sender: TObject);
    procedure ApplyBuiltInColorScheme(SchemeIndex: Integer);
    procedure UpdateColorSchemeChecks;
    procedure UpdateShowRulerLineNumber;
    procedure actShowSpecialCharsExecute(Sender: TObject);
    procedure actShowMinimapExecute(Sender: TObject);
    procedure actShowMacromapExecute(Sender: TObject);
    procedure actWordWrapExecute(Sender: TObject);
    procedure actScrollUpExecute(Sender: TObject);
    procedure actScrollDownExecute(Sender: TObject);
    procedure actUpdatePageCount(Sender: TObject); // enable on pagecount> 0
    procedure actUpdateProject(Sender: TObject); // enable on fproject assigned
    procedure actUpdateMakeFile(Sender: TObject); // enable on fproject assigned and compilation allowed
    procedure actUpdatePageorProject(Sender: TObject); // enable on either of above
    procedure actUpdateEmptyEditor(Sender: TObject); // enable on unempty editor
    procedure actUpdateDebuggerRunning(Sender: TObject); // enable when debugger running
    procedure actUpdateDeleteWatch(Sender: TObject); // enable on watch var selection
    procedure actIncrementalExecute(Sender: TObject);
    procedure CompilerOutputDblClick(Sender: TObject);
    procedure FindOutputDblClick(Sender: TObject);
    procedure actShowBarsExecute(Sender: TObject);
    procedure btnFullScrRevertClick(Sender: TObject);
    procedure FormContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure actAddWatchExecute(Sender: TObject);
    procedure ProjectViewClick(Sender: TObject);
    procedure actNextLineExecute(Sender: TObject);
    procedure actRemoveWatchExecute(Sender: TObject);
    procedure actContinueExecute(Sender: TObject);
    procedure actStopExecuteExecute(Sender: TObject);
    procedure actUndoUpdate(Sender: TObject);
    procedure actRedoUpdate(Sender: TObject);
    procedure actCutUpdate(Sender: TObject);
    procedure actCopyUpdate(Sender: TObject);
    procedure actPasteUpdate(Sender: TObject);
    procedure actSaveUpdate(Sender: TObject);
    procedure actSaveAsUpdate(Sender: TObject);
    procedure actFileMenuExecute(Sender: TObject);
    procedure actToolsMenuExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
//    procedure ClassBrowserSelect(Sender: TObject; Filename: TFileName; Line: Integer);
    procedure CppParserTotalProgress(Sender: TObject; const FileName: Ansistring; Total, Current: Integer); //abli
    procedure CodeCompletionResize(Sender: TObject);
    procedure actSwapHeaderSourceExecute(Sender: TObject);
    procedure actSyntaxCheckExecute(Sender: TObject);
    procedure EditorPageControlLeftChange(Sender: TObject);
    procedure actConfigShortcutsExecute(Sender: TObject);
    procedure DateTimeMenuItemClick(Sender: TObject);
    procedure CommentheaderMenuItemClick(Sender: TObject);
    procedure EditorPageControlLeftMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure actNewTemplateUpdate(Sender: TObject);
    procedure actCommentExecute(Sender: TObject);
    procedure actUncommentExecute(Sender: TObject);
    procedure actIndentExecute(Sender: TObject);
    procedure actUnindentExecute(Sender: TObject);
    procedure EditorPageControlLeftDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure EditorPageControlLeftDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept:
      Boolean);
    procedure actGotoFunctionExecute(Sender: TObject);
    procedure actBrowserGotoDeclarationUpdate(Sender: TObject);
    procedure actBrowserGotoDefinitionUpdate(Sender: TObject);
    procedure actBrowserGotoDeclarationExecute(Sender: TObject);
    procedure actBrowserGotoDefinitionExecute(Sender: TObject);
    procedure actBrowserNewClassUpdate(Sender: TObject);
    procedure actBrowserNewMemberUpdate(Sender: TObject);
    procedure actBrowserNewVarUpdate(Sender: TObject);
    procedure actBrowserViewAllUpdate(Sender: TObject);
    procedure actBrowserNewClassExecute(Sender: TObject);
    procedure actBrowserNewMemberExecute(Sender: TObject);
    procedure actBrowserNewVarExecute(Sender: TObject);
    procedure actBrowserViewAllExecute(Sender: TObject);
    procedure actBrowserViewCurrentExecute(Sender: TObject);
    procedure actProfileExecute(Sender: TObject);
    procedure actCloseAllButThisExecute(Sender: TObject);
    procedure actStepLineExecute(Sender: TObject);
    procedure lvBacktraceCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var
      DefaultDraw: Boolean);
    procedure lvBacktraceMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure actRunUpdate(Sender: TObject);
    procedure actCompileRunUpdate(Sender: TObject);
    procedure actCompileUpdate(Sender: TObject);
    procedure FileMonitorNotifyChange(Sender: TObject; ChangeType: TdevMonitorChangeType; Filename: string);
    procedure actFilePropertiesExecute(Sender: TObject);
    procedure actViewToDoListExecute(Sender: TObject);
    procedure actAddToDoExecute(Sender: TObject);
    procedure actProjectNewFolderExecute(Sender: TObject);
    procedure actProjectRemoveFolderExecute(Sender: TObject);
    procedure actProjectRenameFolderExecute(Sender: TObject);
    procedure ProjectViewDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure ProjectViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure actImportMSVCExecute(Sender: TObject);
    procedure ViewCPUItemClick(Sender: TObject);
    procedure cmbGdbCommandKeyPress(Sender: TObject; var Key: Char);
    procedure actExecParamsExecute(Sender: TObject);
    procedure actHelpTipsExecute(Sender: TObject);
    procedure CppParserStartParsing(Sender: TObject);
    procedure CppParserEndParsing(Sender: TObject; Total: Integer);
    procedure actBrowserViewProjectExecute(Sender: TObject);
    procedure actAbortCompilationUpdate(Sender: TObject);
    procedure actAbortCompilationExecute(Sender: TObject);
    procedure ProjectViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RemoveItem(Node: TTreeNode);
    procedure ProjectViewChanging(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
    procedure actOpenEditorByTagExecute(Sender: TObject);
    procedure actWindowMenuExecute(Sender: TObject);
    procedure actGotoProjectManagerExecute(Sender: TObject);
    procedure ListItemClick(Sender: TObject);
    procedure ProjectViewCompare(Sender: TObject; Node1, Node2: TTreeNode; Data: Integer; var Compare: Integer);
    procedure ProjectViewKeyPress(Sender: TObject; var Key: Char);
    procedure ProjectViewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GoToClassBrowserItemClick(Sender: TObject);
    procedure actBrowserShowInheritedExecute(Sender: TObject);
    procedure ReportWindowClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FloatingPojectManagerItemClick(Sender: TObject);
    procedure actSaveProjectAsExecute(Sender: TObject);
    procedure mnuOpenWithClick(Sender: TObject);
    procedure cmbClassesChange(Sender: TObject);
    procedure cmbMembersChange(Sender: TObject);
    procedure CompilerOutputKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CompilerOutputMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure CompilerOutputMouseLeave(Sender: TObject);
    procedure FindOutputKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DebugViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DebugPopupPopup(Sender: TObject);
    procedure FloatingReportwindowItemClick(Sender: TObject);
    procedure actAttachProcessUpdate(Sender: TObject);
    procedure actAttachProcessExecute(Sender: TObject);
    procedure actModifyWatchExecute(Sender: TObject);
    procedure actModifyWatchUpdate(Sender: TObject);
    procedure ClearallWatchPopClick(Sender: TObject);
    procedure actMsgCopyAllExecute(Sender: TObject);
    procedure actMsgSaveAllExecute(Sender: TObject);
    procedure actDeleteProfileExecute(Sender: TObject);
    procedure actGotoImplDeclEditorExecute(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled:
      Boolean);
    procedure cmbGenericDropDown(Sender: TObject);
    procedure actUnCollapseExecute(Sender: TObject);
    procedure actCollapseExecute(Sender: TObject);
    procedure actInsertExecute(Sender: TObject);
    //procedure actToggleExecute(Sender: TObject);
    //procedure actGotoExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditorPageControlLeftMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure actBreakPointExecute(Sender: TObject);
    procedure EvaluateInputKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure actSkipFunctionExecute(Sender: TObject);
    procedure actNextInsExecute(Sender: TObject);
    procedure actStepInsExecute(Sender: TObject);
    procedure actMsgPasteExecute(Sender: TObject);
    procedure actUpdateDebuggerRunningCPU(Sender: TObject);
    procedure actUpdateEmptyEditorFindForm(Sender: TObject);
    procedure actReplaceAllExecute(Sender: TObject);
    procedure BrowserViewAdvancedCustomDraw(Sender: TCustomTreeView;
      const ARect: TRect; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
    procedure BrowserViewAdvancedCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
      Stage: TCustomDrawStage;  var PaintImages, DefaultDraw: Boolean);
    procedure DebugViewAdvancedCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
      Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
    procedure FindOutputAdvancedCustomDrawSubItem(Sender: TCustomListView; Item: TListItem; SubItem: Integer;
      State: TCustomDrawState; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
    procedure FindOutputAdvancedCustomDraw(Sender: TCustomListView; const ARect: TRect; Stage: TCustomDrawStage;
      var DefaultDraw: Boolean);
    procedure CompilerOutputAdvancedCustomDraw(Sender: TCustomListView; const ARect: TRect; Stage: TCustomDrawStage;
      var DefaultDraw: Boolean);
    procedure CompilerOutputAdvancedCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
      Stage: TCustomDrawStage; var DefaultDraw: Boolean);
    procedure actMsgCutExecute(Sender: TObject);
    procedure actMsgSelAllExecute(Sender: TObject);
    procedure actSearchAgainExecute(Sender: TObject);
    procedure FindOutputDeletion(Sender: TObject; Item: TListItem);
    procedure CompilerOutputDeletion(Sender: TObject; Item: TListItem);
    procedure ResourceOutputDeletion(Sender: TObject; Item: TListItem);
    procedure actStopExecuteUpdate(Sender: TObject);
    procedure actUpdateIndent(Sender: TObject);
    procedure actRevSearchAgainExecute(Sender: TObject);
    procedure actDeleteLineExecute(Sender: TObject);
    procedure actDeleteToLineEndExecute(Sender: TObject);
    procedure actDeleteToLineBeginExecute(Sender: TObject);
    procedure actToggleCommentExecute(Sender: TObject);
    procedure cmbCompilers1Change(Sender: TObject);
    procedure actDuplicateLineExecute(Sender: TObject);
    procedure actBrowserViewIncludesExecute(Sender: TObject);
    procedure actMoveSelUpExecute(Sender: TObject);
    procedure actMoveSelDownExecute(Sender: TObject);
    procedure actCodeCompletionUpdate(Sender: TObject);
    procedure actCodeCompletionExecute(Sender: TObject);
    procedure actPackageManagerExecute(Sender: TObject);
    procedure actShortenCompPathsExecute(Sender: TObject);
    procedure actSyntaxCheckFileExecute(Sender: TObject);
    procedure LeftPageControlChange(Sender: TObject);
    procedure LeftPageControlResize(Sender: TObject);
    procedure actSwapEditorExecute(Sender: TObject);
    procedure actSwapEditorUpdate(Sender: TObject);
    procedure actSaveAllUpdate(Sender: TObject);
    procedure PageControlPanelResize(Sender: TObject);
    procedure actOpenFolderExecute(Sender: TObject);
    procedure actGotoBreakPointExecute(Sender: TObject);
    procedure actToggleCommentInlineExecute(Sender: TObject);
    procedure actToggleCommentInlineUpdate(Sender: TObject);
    procedure actFormatCurrentFileExecute(Sender: TObject);
    procedure actFormatOptionsExecute(Sender: TObject);
    procedure FindOutputSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure actRunTestsExecute(Sender: TObject);
    // Linux IPC: receives file-open requests from subsequent instances via socket
    procedure WMLinuxCopyData(var Message: TMessage); message WM_USER + 200;
     procedure WMMenuSwitch(var Message: TMessage); message WM_USER + 300;
    procedure WMTimer(var Message: TMessage); message WM_TIMER;

    procedure actHelpTutorialExecute(Sender: TObject);
    procedure actHelpAboutExecute(Sender: TObject);
    procedure actHelpCLibExecute(Sender: TObject);
    procedure actHelpFAQExecute(Sender: TObject);
    procedure actMsgTranslateExecute(Sender: TObject);
    procedure actHelpHomepageExecute(Sender: TObject);
    procedure actHelpDonateExecute(Sender: TObject);
    procedure actNewFilesExecute(Sender: TObject);
    procedure actToggleBookmarkExecute(Sender: TObject);
    procedure actNextBookmarkExecute(Sender: TObject);
    procedure actPrevBookmarkExecute(Sender: TObject);
    procedure actHelpManualExecute(Sender: TObject);
    procedure actRuntoCursorExecute(Sender: TObject);
    procedure actRuntoCursorUpdate(Sender: TObject);
    procedure MessageControlResize(Sender: TObject);
    procedure cbWatchLocalsClick(Sender: TObject);
    procedure actFileExplorerExecute(Sender: TObject);
    procedure actConsoleOpenExecute(Sender: TObject);
    procedure actConsoleLargeExecute(Sender: TObject);
    procedure actConsoleDefaultExecute(Sender: TObject);
    procedure actCodeDiffExecute(Sender: TObject);
    procedure cmbGdbCommandSelect(Sender: TObject);
    //procedure actOutputManagerExecute(Sender: TObject);
    procedure actFixHighDPIExecute(Sender: TObject);

    procedure BrowserViewClick(Sender: TObject);

  private
    fPreviousHeight: integer; // stores MessageControl height to be able to restore to previous height
    fCompilerHoverIndex: integer; // hovered item index in CompilerOutput (-1 = none)
    fTools: TToolController; // tool list controller
    fProjectToolWindow: TForm; // floating left tab control
    fReportToolWindow: TForm; // floating bottom tab control
    WindowPlacement: TWindowPlacement; // idem
    fFirstShow: boolean; // true for first WM_SHOW, false for others
    fRunEndAction: TRunEndAction; // determines what to do when program execution finishes
    fCompSuccessAction: TCompSuccessAction; // determines what to do when compilation finishes
    fParseStartTime: Cardinal; // TODO: move to CppParser?
    fSingleInstance: TBaseSingleInstance; // single instance component
    fOldCompilerToolbarIndex: integer;
    fAutoSaveTimer: TTimer;
    fProject: TProject;
    fDebugger: TDebugger;
    fCompiler: TCompiler;
    //fAutoLinkList: TStringList; //Auto link
    fTransList: TStringList; //compiling message translation
    fEditorList: TEditorList;
    fCurrentPageHint: String;
    fLogOutputRawData: TStringList;
    fCriticalSection: TCriticalSection; // protects fFilesToOpen
    fFilesToOpen: TStringList; // files to open on show
    fFormClosing: Boolean; // guard against re-entrant FormClose (from Application.Terminate)
    fShortcuts: TdevShortcuts;
    fFileMonitor: TdevFileMonitor;
    fMenuFontSize: Integer; // used by MenuDrawItem/MenuMeasureItem for owner-draw menu
   // fParser: TCppParser;
    //fClassBrowser: TClassBrowser;  //anbangli

//    procedure AddMembersToTree(ParentNode: TTreeNode; Member: TClassMember);  //anbangli

    function ParseToolParams(s: String): String;
    procedure TransMenuMacros(num: integer; flag: boolean);
//    procedure BuildBookMarkMenus;
    procedure SetHints;
    procedure MRUClick(Sender: TObject);
    procedure CodeInsClick(Sender: TObject);
    procedure ToolItemClick(Sender: TObject);
    procedure WMDropFiles(var msg: TMessage); message WM_DROPFILES;
    procedure LogEntryProc(const Msg: String);
    procedure CompOutputProc(const _Line, _Col, _Unit, _Message: String);
    procedure CompResOutputProc(const _Line, _Col, _Unit, _Message: String);
    procedure CompEndProc;
    procedure CompSuccessProc;
    procedure RunEndProc;
    procedure LoadText;
    procedure LoadColor;
    procedure ReloadColor;
    procedure MenuDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; AState: TOwnerDrawState);
    procedure MenuMeasureItem(Sender: TObject; ACanvas: TCanvas; var AWidth, AHeight: Integer);
    function IsTopLevelMenuItem(Item: TMenuItem): Boolean;
    procedure OpenUnit;
    function PrepareForRun(ForcedCompileTarget: TTarget = ctInvalid): Boolean;
    function PrepareForCompile(ForcedCompileTarget: TTarget = ctInvalid): Boolean;
    function PrepareForClean(ForcedCompileTarget: TTarget = ctInvalid): Boolean;
    procedure LoadTheme;
    procedure CheckForDLLProfiling;
    procedure ProjectWindowClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure BuildOpenWith;
    procedure RebuildClassesToolbar;
    procedure PrepareDebugger;
    procedure ClearCompileMessages;
    procedure ClearMessageControl;
    procedure UpdateClassBrowsing;
    function ParseParameters(const Parameters: WideString): Integer;

    procedure SetupEventHandlers;
//    procedure HandleTreeNodeChange(Sender: TObject; Node: TTreeNode);
    procedure UpdateBrowserView;
    procedure HandleBrowserViewUpdate;
  private
    fMenuBar: TToolBar;

    fMenuTrackTimer: TTimer;

    fOpenBtn: TToolButton;  // 褰撳墠灞曞紑鐨勬寜閽甡r


    procedure CreateToolBarMenuBar;
    procedure RefreshToolbarCaptions;
    procedure ToolButtonClick(Sender: TObject);

    procedure SwitchTimerTimer(Sender: TObject);

    function BtnAtMouse: TToolButton;

    function MenuIndexOf(btn: TToolButton): Integer;



  public
    CppParser: TCppParser;
    CppPreprocessor: TCppPreprocessor;
    CppTokenizer: TCppTokenizer;
    ClassBrowser: TClassBrowser;
    CodeCompletion: TCodeCompletion;
    //CodeComplForm: TCodeComplForm;
    ImagesRecord: TImagesRecord; //
    //procedure UpdateBrowserView;   //anbangli
    procedure ScanActiveProject;
    procedure UpdateCompilerList;
    function GetCompileTarget: TTarget;
    procedure UpdateAppTitle;
    procedure OpenCloseMessageSheet(Open: boolean);
    procedure OpenFile(const FileName: String);
    procedure OpenFileList(List: TStringList);
    procedure OpenProject(const s: String);
    procedure GotoBreakpoint(const FileName: String; Line: integer);
    procedure RemoveActiveBreakpoints;
    procedure AddFindOutputItem(const line, col, filename, msg, keyword: String);
    procedure EditorSaveTimer(sender: TObject);
    procedure OnInputEvalReady(const evalvalue: AnsiString);
    procedure SetStatusbarLineCol;
    procedure SetStatusbarMessage(const msg: String);
    procedure UpdateEncodingStatus;
    procedure UpdateLineEndsStatus;
    procedure SingleInstanceReceivedParams(Sender: TBaseSingleInstance; Params: TStringList);
    procedure AppIdle(Sender: TObject; var Done: Boolean);

    // Hide variables
    property AutoSaveTimer: TTimer read fAutoSaveTimer write fAutoSaveTimer;
    property Project: TProject read fProject write fProject;
    property Debugger: TDebugger read fDebugger write fDebugger;
    property EditorList: TEditorList read fEditorList write fEditorList;
    property CurrentPageHint: String read fCurrentPageHint write fCurrentPageHint;
    property Shortcuts: TdevShortcuts read fShortcuts write fShortcuts;
    property FileMonitor: TdevFileMonitor read fFileMonitor write fFileMonitor;
    procedure AssignMenuOwnerDrawHandlers(AParent: TMenuItem);
  end;

var
  MainForm: TMainForm;

implementation

uses ShellAPI, Clipbrd, MultiLangSupport, version, ATStrings, LCLProc,
  DataFrm, NewProjectFrm, AboutFrm, PrintFrm, HomepageFrm,
  CompilerOptFrm, EditorOptFrm, IncrementalFrm, EnvironOptFrm,   //ShortcutsFrm,
  Math, ImageTheme, Types, FindFrm, ProjectTypes, devExec, Tests,
  NewTemplateFrm, FunctionSearchFrm, NewFunctionFrm, NewVarFrm, NewClassFrm,
  ProfileAnalysisFrm, FilePropertiesFrm, FileEncodingFrm, AddToDoFrm, ViewToDoFrm,
  ImportMSVCFrm, ImportCBFrm, CPUFrm, FileAssocs, TipOfTheDayFrm,
  WindowListFrm, RemoveUnitFrm, ParamsFrm,   ProcessListFrm,
  LazUTF8, LCLIntf, CommDlg, Printers, PrintersDlgs;

// Menu hover hook: globals (initialized at startup)
var
  MenuHook: HHOOK = 0;
  MenuHookTimerID: UINT = 0;
  MenuHookLastBtn: TToolButton;

// Forward declarations
function FindMenuItemByCommand(parent: TMenuItem; cmd: Integer): TMenuItem; forward;
function MenuHookProc(code: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall; forward;

const
  SENDDATAID = 12345; // message used for single instance IPC
  
  // TODO: ATSynEdit - moved from function ParseToolParams (was resourcestring)
  cEXEName = '<EXENAME>';
  cPrjName = '<PROJECTNAME>';
  cPrjFile = '<PROJECTFILE>';
  cPrjPath = '<PROJECTPATH>';
  cCurSrc = '<SOURCENAME>';
  cSrcPath = '<SOURCEPATH>';
  cDevVer = '<DEVCPPVERSION>';
  cDefault = '<DEFAULT>';
  cExecDir = '<EXECPATH>';
  cSrcList = '<SOURCESPCLIST>';
  cWordxy = '<WORDXY>';
  cWinDir = '<WINDIR>';
  CPfDir = '<PROGRAMFILES>';


{$R *.lfm}

// ATSynEdit command constants
const
  cCmdFlag_ResetSel = $20000;
  cCommand_Undo = 235 or cCmdFlag_ResetSel;
  cCommand_Redo = 236 or cCmdFlag_ResetSel;
  cCommand_ClipboardCut = 1008;
  cCommand_ClipboardPaste = 1000;
  cCommand_ClipboardCopy = 1006;
  cCommand_SelectAll = 260 or $20000 or $80000; // ATSynEdit: base + cCmdFlag_ResetSel + cCmdFlag_Caret
  cCommand_SelectNone = 261;
  cCommand_SelectWords = 262;
  cCommand_TextInsert = 150;
  cCommand_TextDeleteSelection = 170;
  cCommand_TextDeleteLine = 171;
  cCommand_TextDeleteToLineBegin = 173 or cCmdFlag_ResetSel;
  cCommand_TextDeleteToLineEnd = 174 or cCmdFlag_ResetSel;
  cCommand_TextDuplicateLine = 172;
  cCommand_MoveSelectionUp = 268;
  cCommand_MoveSelectionDown = 269;
  cCommand_FoldAll = 1030;
  cCommand_UnfoldAll = 1029;
  cCommand_ScrollLineUp = 250;
  cCommand_ScrollLineDown = 251;

procedure TMainForm.FormCreate(Sender: TObject);
var
  ID: LangID;
  scale: Real;
begin
  fFirstShow := true;

  // Initialize single instance component
  fSingleInstance := TAdvancedSingleInstance.Create(Self);
  fSingleInstance.OnServerReceivedParams := @SingleInstanceReceivedParams;
  if fSingleInstance.Start = siClient then begin
    // We are a client - there is already a server running
    // Post our command-line parameters to the server and exit
    fSingleInstance.ClientPostParams;
    Application.ShowMainForm := False;
    Application.Terminate;
    Exit;
  end;
  
  // Set up idle handler to check for single instance messages
  Application.OnIdle := @AppIdle;

  // Backup PATH variable
  devDirs.OriginalPath := GetEnvironmentVariable('PATH');

  // Create a compiler
  fCompiler := TCompiler.Create;
  with fCompiler do begin
    OnLogEntry := @LogEntryProc;
    OnOutput := @CompOutputProc;
    //OnTranslate := MsgTranslate;
    OnResOutput := @CompResOutputProc;
    OnCompEnd := @CompEndProc;
    OnCompSuccess := @CompSuccessProc;
    OnRunEnd := @RunEndProc;
  end;
  fTransList := TStringList.Create;
  //fAutoLinkList := TStringList.Create;

  // Remember long version of paths
  fLogOutputRawData := TStringList.Create;

  // Create a debugger
  fDebugger := TDebugger.Create;
  with fDebugger do begin
    DebugView := Self.DebugView;
  end;

  // Create FileMonitor, CodeCompletion
  fFileMonitor := TdevFileMonitor.create(self);  //anbangli, 2026-01-01
  FileMonitor.Parent := Self;
  FileMonitor.OnNotifyChange :=@FileMonitorNotifyChange;

  // Create ClassBrowser, CppParser, CppPreprocessor, CppTokenizer.
  CppParser := TCppParser.Create(self);
 // fParser := CppParser; // ����������ָ��ͬһ��ʵ��
  CppPreprocessor := TCppPreprocessor.Create(self);
  CppTokenizer := TCppTokenizer.Create(self);

  ClassBrowser := TClassBrowser.Create;
  ClassBrowser.OnDataChanged := @HandleBrowserViewUpdate;
  ClassBrowser.SetParser(CppParser);

  CodeCompletion := TCodeCompletion.Create(self); //anbangli, 2026-01-03
  CodeCompletion.Parser := CppParser;

//  ImagesRecord := TImagesRecord.Create;

  // Create an editor manager
  fEditorList := TEditorList.Create;
  with fEditorList do begin
    LeftPageControl := Self.EditorPageControlLeft;
    RightPageControl := Self.EditorPageControlRight;
    Splitter := Self.EditorPageControlSplitter;
    Panel := Self.PageControlPanel;
    DeleteExe := devData.DeleteExe;
  end;

  // Custom tools
  fTools := TToolController.Create;
  with fTools do begin
    Menu := ToolsMenu;
    Offset := ToolsMenu.IndexOf(RunTests);
    ToolClick := @ToolItemClick;
    BuildMenu;
  end;

  //check editor's font exists or not
  if (screen.Fonts.IndexOf(devEditor.Font.Name) = -1) then
    devEditor.Font.Name := 'Consolas';
  if (screen.Fonts.IndexOf(devEditor.Font.Name) = -1) then
    devEditor.Font.Name := 'Courier New';

  // Don't create the autosave timer when we don't need it
  if devEditor.EnableAutoSave then begin
    AutoSaveTimer := TTimer.Create(nil);
    with AutoSaveTimer do begin
      OnTimer := @EditorSaveTimer;
      Interval := devEditor.Interval * 60 * 1000; // miliseconds to minutes
      Enabled := devEditor.EnableAutoSave;
    end;
  end;

  // Create critical section to support a single instance
  fCriticalSection := TCriticalSection.Create;
  fFilesToOpen := TStringList.Create;

  // Apply shortcuts BEFORE TRANSLATING!!!
  fShortcuts:= TdevShortcuts.Create(Self);
  with fShortcuts do begin
    Filename := devDirs.Config + DEV_SHORTCUTS_FILE;
    Load(ActionList);
  end;

  // Accept file drags
  DragAcceptFiles(Self.Handle, true);

  // Set left page control to previous state
  actProjectManager.Checked := devData.ShowLeftPages;
  LeftPageControl.ActivePageIndex := devData.LeftActivePage;
  actProjectManagerExecute(nil);
  LeftPageControl.Width := devData.ProjectWidth;
  if devData.ProjectFloat then begin
    FloatingPojectManagerItem.Click;
    devData.ProjectWindowState.SetPlacement(fProjectToolWindow.Handle);
  end;
  actShowSpecialChars.Checked := devEditor.ShowSpecialChars;
  actShowTopRuler.Checked := devEditor.ShowTopRuler;
  actShowLineNumber.Checked := devEditor.LineNumbers;
  actWordWrap.Checked := devEditor.WordWrap;
  actShowMinimap.Checked := devEditor.ShowMinimap;
  actShowMacromap.Checked := devEditor.ShowMacromap;

  //WinDPI:= Screen.MonitorFromWindow(application.handle).PixelsPerInch;
  scale  := Screen.PixelsPerInch / 96;  //original dpi is 96

  // Set bottom page control to previous state
  fPreviousHeight := devData.OutputHeight;

  if devData.MessageFloat then begin
    FloatingReportwindowItem.Click;
    devData.ReportWindowState.SetPlacement(fReportToolWindow.Handle);
  end;
  actShortenCompPaths.Checked := devData.ShortenCompPaths;
  actMsgTranslate.Checked := devData.TranslateMsg;

  // Set statusbar to previous state
  actStatusbar.Checked := devData.Statusbar;
  actStatusbarExecute(nil);

  // Set toolbars to previous state.
  // 1) position

  // LCL already auto-scales ToolbarDock.Height via Scaled+DesignTimePPI.
  // But RowSize is not auto-scaled by LCL, so we scale it manually here.
  // Without this, CalcBandHeightSnapped snaps to a RowSize(40) that is too small
  // relative to the scaled tbMain.Height, causing bands to round up and create
  // excess vertical space below the toolbar.
//  ToolbarDock.Height := ceil(ToolbarDock.Height * scale);  // double-scaling removed
  ToolbarDock.RowSize := MulDiv(40, Screen.PixelsPerInch, 96);
//  ToolbarDock.Width := ceil(ToolbarDock.Width * scale);
  //tbmain.Height := ceil(tbMain.Height * scale);
  //tbmain.Width := round(tbMain.Width * scale);

  tbMain.Left := (devData.ToolbarMainX * 100) div round(scale * 100);
  //tbMain.Top := devData.ToolbarMainY;

//  tbmain.ButtonHeight := ceil(tbMain.ButtonHeight * scale);
//  tbmain.ButtonWidth := ceil(tbMain.ButtonWidth * scale);
//  LeftPageControl.Width := ceil(LeftPageControl.Width * scale);
//  tbProjectLeft.ButtonHeight := ceil(tbProjectLeft.ButtonHeight * scale);
//  tbProjectLeft.ButtonWidth := ceil(tbProjectLeft.ButtonWidth * scale);
//  tbDebugLeft.ButtonHeight := ceil(tbDebugLeft.ButtonHeight * scale);
//  tbDebugLeft.ButtonWidth := ceil(tbDebugLeft.ButtonWidth * scale);

  //There are some cases on Windows 10/11 with update package 21H2,
  //the toolbar doesnot wholely display itself. Should adjust.

//  if ToolbarDock.Height < btnHomepage.Height then //
//  begin
//    ToolbarDock.AutoSize := false;
//    tbmain.AutoSize := false;
//    tbMain.Height := btnHomepage.Height;
//    ToolbarDock.Height := tbMain.Height + 4;
//  end;
//  if tbMain.Width < btnHomepage.Left then
//  begin
    //ToolbarDock.AutoSize := false;
    //tbmain.AutoSize := false;
//    tbMain.Width := btnHomepage.Left + btnHomepage.Width + 8;
//  end;
  //adjust other controls on message panel
// if CompLogLeftPanel.Width < 200 then
//  begin
//    CompLogLeftPanel.Width := 200;
{
  LogLeftPanel.Width := ceil(LogLeftPanel.Width * scale);
    btnAbortCompilation.top := 5;
    btnAbortCompilation.Height := ceil(btnAbortCompilation.Height * scale);
    btnAbortcompilation.Width := ceil(btnAbortCompilation.Width * scale);
    pbCompilation.top := btnAbortCompilation.top + btnAbortCompilation.Height +5;;
    pbCompilation.Width := ceil(pbCompilation.Width * scale);
    pbCompilation.Height := ceil(pbCompilation.Height *scale);
    chkShortenPaths.top := pbCompilation.top + pbCompilation.Height + 10;
    chkShortenPaths.Width := ceil( chkShortenPaths.Width * scale);
    chkShortenPaths.Height := ceil( chkShortenPaths.Height * scale);
    chkTranslateMsg.top := chkShortenPaths.top + chkShortenPaths.Height + 5;
    chkTranslateMsg.Width := ceil(chkTranslateMsg.Width * scale);
    chkTranslateMsg.Height := ceil(chkTranslateMsg.Height * scale);
    LogOutput.Top := btnAbortCompilation.top;
    LogOutput.Left := pbCompilation.Left + pbCompilation.Width +10;
//    LogOutput.right :=
//    LogOutput.height :=

    DebugStartPanel.Width := ceil(DebugStartPanel.Width * scale);
    lblEvaluate.Font := MessageControl.Font;
  //len := Canvas.TextWidth(lblEvaluate.Caption) + 10;
  lblEvaluate.Width := 90; //I don't know why its width is 45. here assign 90 . //by Anbang
  lblEvaluate.Width := ceil(lblEvaluate.Width * scale);
  lblEvaluate.Height := ceil(lblEvaluate.Height * scale);

  //EvaluateInput.Left := lblEvaluate.Left; // + lblEvaluate.Width + ceil(10*scale);
  //EvaluateInput.Width := ceil(EvaluateInput.Width * scale);
  //EvaluateInput.Height:= ceil(EvaluateInput.Height * scale);
  //EvalOutput.Top := EvaluateInput.Top + ceil(EvaluateInput.Height*scale) + ceil(5*scale);
  //EvalOutput.Left := ceil(EvaluateInput.Left*scale);
  //EvalOutput.Width := ceil(EvalOutput.Width * scale);
  //DebugSendPanel need not change
  DebugCmdPanel.Height := ceil(DebugCmdPanel.Height * scale);
  lblSendCommandGdb.top := ceil(lblSendCommandGdb.top *scale);
  lblSendCommandGdb.Width := 120; //I don't know why its width is 45. here assign 90 . //by Anbang
  lblSendCommandGdb.Width := ceil(lblSendCommandGdb.Width * scale);
  lblSendCommandGdb.Height := ceil(lblSendCommandGdb.Height * scale);

  cmbGdbCommand.Top := lblSendCommandGdb.Top;
  cmbGdbCommand.Left := lblSendCommandGdb.Left + lblSendCommandGdb.Width + ceil(5*scale);
  cmbGdbCommand.Height := lblSendCommandGdb.Height + 5;
  cmbGdbCommand.Width := ceil(cmbGdbCommand.Width *scale);

  btnCmdNext.Top := lblSendCommandGdb.Top;
  btnCmdNext.Left := cmbGdbCommand.Left + cmbGdbCommand.Width + ceil(5*scale);
  btnCmdNext.Width := ceil(btnCmdNext.Width * scale);
  btnCmdNext.Height:= ceil(btnCmdNext.Height * scale);
    btnCmdStep.Top := lblSendCommandGdb.Top;
  btnCmdStep.Left := btnCmdNext.Left + btnCmdNext.Width + ceil(5*scale);
  btnCmdStep.Width := ceil(btnCmdStep.Width * scale);
  btnCmdStep.Height:= ceil(btnCmdStep.Height * scale);
  btnCmdfinish.Top := lblSendCommandGdb.Top;
  btnCmdfinish.Left := btnCmdStep.Left + btnCmdStep.Width + ceil(5*scale);
  btnCmdfinish.Width := ceil(btnCmdfinish.Width * scale);
  btnCmdfinish.Height:= ceil(btnCmdfinish.Height * scale);
  btnCmdContinue.Top := lblSendCommandGdb.Top;
  btnCmdContinue.Left := btnCmdfinish.Left + btnCmdfinish.Width + ceil(5*scale);
  btnCmdContinue.Width := ceil(btnCmdContinue.Width * scale);
  btnCmdContinue.Height:= ceil(btnCmdContinue.Height * scale);
  btnCmdUntil.Top := lblSendCommandGdb.Top;
  btnCmdUntil.Left := btnCmdContinue.Left + btnCmdContinue.Width + ceil(5*scale);
  btnCmdUntil.Width := ceil(btnCmdUntil.Width * scale);
  btnCmdUntil.Height:= ceil(btnCmdUntil.Height * scale);
  btnNextIns.Top := lblSendCommandGdb.Top;
  btnNextIns.Left := btnCmdUntil.Left + btnCmdUntil.Width + ceil(5*scale);
  btnNextIns.Width := ceil(btnNextIns.Width * scale);
  btnNextIns.Height:= ceil(btnNextIns.Height * scale);
  btnIntoIns.Top := lblSendCommandGdb.Top;
  btnIntoIns.Left := btnNextIns.Left + btnNextIns.Width + ceil(5*scale);
  btnIntoIns.Width := ceil(btnIntoIns.Width * scale);
  btnIntoIns.Height:= ceil(btnIntoIns.Height * scale);
  btnViewCPU.Top := lblSendCommandGdb.Top;
  btnViewCPU.Left := btnIntoIns.Left + btnIntoIns.Width + ceil(5*scale);
  btnViewCPU.Width := ceil(btnViewCPU.Width * scale);
  btnViewCPU.Height:= ceil(btnViewCPU.Height * scale);

  DebugOutput.Top := lblSendCommandGdb.Top + lblSendCommandGdb.Height +5;
}

//  end;

//  if ((pbCompilation.Top -btnAbortCompilation.Top) < devData.InterfaceFontSize * 2)  then begin
//      btnAbortCompilation.Top := 5;
//      pbCompilation.Top := btnAbortCompilation.Top + devData.InterfaceFontSize * 3 ;
//      chkShortenPaths.top :=  pbCompilation.Top + devData.InterfaceFontSize * 3 ;
//      chkTranslateMsg.top := chkShortenPaths.top + devData.InterfaceFontSize * 2;
//  end;


  //Adjust Statusbar
  //Statusbar.Height := devData.InterfaceFontSize * 2 + 4;
  Statusbar.AutoSize := False;
  Statusbar.Height := ceil(Statusbar.Height * scale) + 4;
  statusbar.panels[0].Width := 250;  //col, line
  // statusbar.panels[1].Width := 200;    message
  statusbar.panels[2].Width := 80;  //line end symbol
  statusbar.panels[3].Width := 80;  //Encode
  statusbar.panels[4].Width := 80;  //Insert/overwite/readonly
  StatusbarResize(sender);
  StatusBar.Panels[1].Style := psOwnerDraw;

//  Statusbar.Panels[0].Width := ceil(Statusbar.Panels[0].Width * scale);

//  ToolbarDock.Width := Mainform.Width;
//  tbMain.Width := ToolbarDock.Width;
//  cmbCompilers.Left := cmbCompilers.Left+100;
  //tbEdit.Left := devData.ToolbarEditX;
  //tbEdit.Top := devData.ToolbarEditY;
  //tbCompile.Left := devData.ToolbarCompileX;
  //tbCompile.Top := devData.ToolbarCompileY;
//  tbProject.Left := devData.ToolbarProjectX;
//  tbProject.Top := devData.ToolbarProjectY;
  //tbSpecials.Left := devData.ToolbarSpecialsX;
  //tbSpecials.Top := devData.ToolbarSpecialsY;
  //tbSearch.Left := devData.ToolbarSearchX;
  //tbSearch.Top := devData.ToolbarSearchY;
//  tbClasses.Left := devData.ToolbarClassesX;
//  tbClasses.Top := devData.ToolbarClassesY;
  //tbCompilers.Left := devData.ToolbarCompilersX;
  //tbCompilers.Top := devData.ToolbarCompilersY;

  // Set toolbars to previous state.
  // 2) Visibility
  tbMain.Visible := devData.ToolbarMain;
  //tbEdit.Visible := devData.ToolbarEdit;
  //tbCompile.Visible := devData.ToolbarCompile;
  //tbProject.Visible := false; //devData.ToolbarProject;
  //tbSpecials.Visible := devData.ToolbarSpecials;
  //tbSearch.Visible := devData.ToolbarSearch;
  //tbClasses.Visible := false; //devData.ToolbarClasses;
  //tbCompilers.Visible := devData.ToolbarCompilers;

  // Set toolbars to previous state.
  // 3) UI components
  ToolMainItem.Checked := devData.ToolbarMain;
  //ToolEditItem.Checked := devData.ToolbarEdit;
  //ToolCompileandRunItem.Checked := devData.ToolbarCompile;
  //ToolProjectItem.Checked := devData.ToolbarProject;
  //ToolSpecialsItem.Checked := devData.ToolbarSpecials;
  //ToolSearchItem.Checked := devData.ToolbarSearch;
  //ToolClassesItem.Checked := devData.ToolbarClasses;
  //ToolCompilersItem.Checked := devData.ToolbarCompilers;
  if devData.AppMode = 2 then
    DarkModeItem.Checked := True
  else if devData.AppMode = 3 then
    LightModeItem.Checked:= True
  else
    AutoModeItem.Checked := True;

  // PageControl settings
  fEditorList.SetPreferences(devData.MsgTabs, devData.MultiLineTab);

  // Create datamod
  dmMain := TdmMain.Create(Self);
  with dmMain do begin
    MRUMenu := ClearhistoryItem;
    MRUClick := @Self.MRUClick;
    CodeMenu := InsertItem;
    CodePop := InsertPopItem;
    CodeClick := @CodeInsClick;
    CodeOffset := 0;
    LoadDataMod;
  end;

  // Create icon themes
  devImageThemes := TDevImageThemeFactory.Create;
  devImageThemes.LoadFromDirectory(devDirs.Themes);
  LoadTheme;
  UpdateIconThemeChecks; // reflect the active icon theme in the View menu

  // Set languages and other first time stuff
  if devData.First or (devData.Language = '') then begin
    ID := GetSystemDefaultLangID;
    Case(ID) OF
    //Arabic	1025
    //Basque	1069
    1027: Lang.Open('Catalan.lng');  //Catalan
    2052: Lang.Open('Chinese.lng');  //Chinese (Simplified)
    1028: Lang.Open('Chinese_TC.lng'); //Chinese (Traditional)
    1029: Lang.Open('Czech.lng'); //Czech
    1030: Lang.Open('Danish.lng'); //Danish
    1043: Lang.Open('Dutch.lng');  //Dutch
    1033: Lang.Open('English.lng');  //English (United States)
    //Finnish	1035
    1036: Lang.Open('French.lng');  //French
    1031: Lang.Open('German.lng');  //German
    1032: Lang.Open('Greek.lng');   //Greek
    1037: Lang.Open('Hebrew.lng');  //Hebrew
    1038: Lang.Open('Hungarian.lng'); //Hungarian
    1040: Lang.Open('Italian.lng');  //Italian
    1041: Lang.Open('Japanese.lng'); //Japanese
    1042: Lang.Open('Korean.lng');   //Korean
    1044: Lang.Open('Norwegian.lng'); //Norwegian
    1045: Lang.Open('Polish.lng');    //Polish
    2070: Lang.Open('Portuguese.lng'); //Portuguese
    1046: Lang.Open('Portuguese.lng'); //Portuguese (Brazil)
    1049: Lang.Open('Russian.lng');    //Russian
    1051: Lang.Open('Slovak.lng');     //Slovakian
    1060: Lang.Open('lovenian.lng');    //Slovenian
    3082: Lang.Open('Spanish.lng');    //Spanish
    1053: Lang.Open('Swedish.lng');  //Swedish
    1055: Lang.Open('Turkish.lng');  //Turkish
    //Bulgarian.lng
    //Croatian.lng
    //Estonian.lng
    //Galego.lng
    //Latvian.lng
    //Romanian.lng
    //SpanishCastellano.lng
    //SpanishColombia.lng
    //Ukrainian.lng
    else
      Lang.SelectLanguage;
    end;
  end else
  Lang.Open(devData.Language);
  Lang.LoadTrans(devData.Language, fTransList);

  // Populate the View -> Editor Color Scheme submenu now that the UI language is loaded
  BuildColorSchemeMenu;

  // Load bookmarks, captions and hints
  LoadText;

  // Load the current compiler set
  devCompilerSets.LoadSets;
  //devCompilerSets.LoadAutoLinks(fAutoLinkList);

  //translate code snippets to UI language ("true").
  TransMenuMacros(1, true); //"1" means only deal with compilersets.

  // Update toolbar
  UpdateCompilerList;

{  // Try to fix the file associations. Needs write access to registry,
  //which might cause exceptions to be thrown.
  DDETopic := 'DevCpp';
  if devData.CheckAssocs then begin
    try
      CheckAssociations(true); // check and fix
    except
      Application.MessageBox(PChar(Lang[ID_ENV_UACERROR]), PChar(Lang[ID_ERROR]), MB_OK);
      devData.CheckAssocs := false; // don't bother again
    end;
  end;
} //move to FormClose

  // Configure parser, code completion, class browser
  UpdateClassBrowsing;

  // Showing for the first time? Maximize
  if devData.First then
    WindowState := wsMaximized
  else // Remember window placement
    devData.WindowState.SetPlacement(Self.Handle);

  // We need this variable during the whole startup process
  devData.First := FALSE;
  //Load Colors
  LoadColor;
  // Owner-draw menu: bind handlers to every TMenuItem so we can use devData.InterfaceFontSize
  fMenuFontSize := devData.InterfaceFontSize;
  // MainMenu hidden; OwnerDraw no longer needed here
  // MainMenu hidden; OwnerDraw no longer needed here
  // Right-click context menus: also owner-draw so their font follows InterfaceFontSize
  AssignMenuOwnerDrawHandlers(EditorPopup.Items);
  AssignMenuOwnerDrawHandlers(UnitPopup.Items);
  AssignMenuOwnerDrawHandlers(ProjectPopup.Items);
  AssignMenuOwnerDrawHandlers(MessagePopup.Items);
  AssignMenuOwnerDrawHandlers(BrowserPopup.Items);
  AssignMenuOwnerDrawHandlers(DebugPopup.Items);
  AssignMenuOwnerDrawHandlers(FolderPopup.Items);
  CreateToolBarMenuBar;

end;

procedure TMainForm.LoadTheme;
begin
  if devImageThemes.IndexOf(devData.Theme) = -1 then
    devData.Theme := devImageThemes.Themes[0].Title; // 0 = Classick (see ImageTheme.pas)

  // make sure the theme in question is in the list
  if devImageThemes.IndexOf(devData.Theme) <> -1 then begin
    devImageThemes.ActivateTheme(devData.Theme);


    with devImageThemes do begin
      // Misc items images
      ActionList.Images := CurrentTheme.MenuImages;
      MainMenu.Images := CurrentTheme.MenuImages;
      MessageControl.Images := CurrentTheme.MenuImages;

      // Set toolbar images
      tbMain.Images := CurrentTheme.MenuImages32;  //!!
      tbProjectLeft.Images := CurrentTheme.MenuImages;
      tbDebugLeft.Images := CurrentTheme.MenuImages;

      //tbCompile.Images := CurrentTheme.MenuImages;
      //tbProject.Images := CurrentTheme.MenuImages;
      //tbClasses.Images := CurrentTheme.MenuImages;
      //tbedit.Images := CurrentTheme.MenuImages;
      //tbSearch.Images := CurrentTheme.MenuImages;
      //tbSpecials.Images := CurrentTheme.MenuImages;
      //tbCompilers.Images := CurrentTheme.MenuImages;

      // Set left control images
      ProjectView.Images := CurrentTheme.ProjectImages;
      BrowserView.Images := CurrentTheme.BrowserImages;
      //BrowserView.StateImages := CurrentTheme.BrowserImages;
      //ClassView.OverlayImages := CurrentTheme.BrowserImages;
      BrowserView.OnClick := @BrowserViewClick;
      BrowserView.PopupMenu := BrowserPopup;

      //BrowserView.OnCustomDrawItem := BrowserViewCustomDrawItem;  // 自定义绘�?
      BrowserView.OnAdvancedCustomDraw := @BrowserViewAdvancedCustomDraw;
      BrowserView.OnAdvancedCustomDrawItem := @BrowserViewAdvancedCustomDrawItem;
      CompilerOutput.OnAdvancedCustomDraw := @CompilerOutputAdvancedCustomDraw;
      CompilerOutput.OnAdvancedCustomDrawItem := @CompilerOutputAdvancedCustomDrawItem;
      CompilerOutput.OwnerDraw := True;
      CompilerOutput.ViewStyle := vsReport;
      CompilerOutput.AutoWidthLastColumn:= True;  //Auto-adjust the width of Last Column
      //CompilerOutput.DefaultDraw := False;

      DebugView.Images := CurrentTheme.MenuImages;

      // Set left control and editor popup images
      ProjectPopup.Images := CurrentTheme.MenuImages;
      UnitPopup.Images := CurrentTheme.MenuImages;
      FolderPopup.Images := CurrentTheme.MenuImages;
      BrowserPopup.Images := CurrentTheme.MenuImages;
      DebugPopup.Images := CurrentTheme.MenuImages;
      EditorPopup.Images := CurrentTheme.MenuImages;
    end;
  end;

end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  i: integer;
  e: TEditor;
begin
  // Guard against re-entrant FormClose (Application.Terminate calls MainForm.Close)
  if fFormClosing then
  begin
    CloseAction := caFree;
    Exit;
  end;
  fFormClosing := True;

  // Set Application.Terminated so EControl parser threads exit early
  // during editor destruction (actCloseAllExecute below)
  if not Application.Terminated then
    Application.Terminate;

  actStopExecuteExecute(nil); //ABLI
  if fCompiler.Compiling then begin
    //MessageDlg("Compiling!  Can't close now!", mtInformation, [mbOK], 0);
    Exit;
  end;

  // Try to close the current project.
  if Assigned(fProject) then begin
    devData.LastProject := fProject.FileName;
    actCloseProjectExecute(Self);
  end else
    devData.LastProject := '';
  if Assigned(fProject) then begin //If it stays open (user says cancel), stop quitting
    CloseAction := caNone;
    Exit;
  end;
  //TODO: Here is a known bug. If we open a project and then directly close the main form,

  // Remember editor states.
  devData.LastFiles := fEditorList.PageCount;
  for i:=0 to EditorList.PageCount-1 do begin
    if (i < EditorPageControlLeft.PageCount) then
      e := EditorList.GetEditor(i, EditorPageControlLeft)
    else
      e := EditorList.GetEditor(i - EditorPageControlLeft.PageCount, EditorPageControlRight);
    if assigned(e) and e.Text.Focused then
      devData.LastActive := i;
  end;

  actCloseAllExecute(Self);   // Try to close all editors.
  if fEditorList.PageCount > 0 then begin  //If someone are left open, stop quitting
    CloseAction := caNone;
    Exit;
  end;

  // Remember toolbar placement
  devData.LeftActivePage := LeftPageControl.ActivePageIndex;
  devData.ToolbarMainX := tbMain.Left;
  devData.ToolbarMainY := tbMain.Top;
  //devData.ToolbarMainH := tbMain.Height;
  //devData.ToolbarEditX := tbEdit.Left;
  //devData.ToolbarEditY := tbEdit.Top;
  //devData.ToolbarCompileX := tbCompile.Left;
  //devData.ToolbarCompileY := tbCompile.Top;
  //devData.ToolbarProjectX := tbProject.Left;
  //devData.ToolbarProjectY := tbProject.Top;
  //devData.ToolbarSpecialsX := tbSpecials.Left;
  //devData.ToolbarSpecialsY := tbSpecials.Top;
  //devData.ToolbarSearchX := tbSearch.Left;
  //devData.ToolbarSearchY := tbSearch.Top;
  //devData.ToolbarClassesX := tbClasses.Left;
  //devData.ToolbarClassesY := tbClasses.Top;
  //devData.ToolbarCompilersX := tbCompilers.Left;
  //devData.ToolbarCompilersY := tbCompilers.Top;

  // Save left page control states
  //scale  := Screen.PixelsPerInch / 96;  //original dpi is 96
  devData.ProjectWidth := ceil(LeftPageControl.Width /(Screen.PixelsPerInch / 96));
  devData.OutputHeight := fPreviousHeight;
  devData.ProjectFloat := Assigned(fProjectToolWindow) and fProjectToolWindow.Visible;
  devData.MessageFloat := Assigned(fReportToolWindow) and fReportToolWindow.Visible;

  // Remember window placement
  devData.WindowState.GetPlacement(Self.Handle);
  if Assigned(fProjectToolWindow) then
    devData.ProjectWindowState.GetPlacement(fProjectToolWindow.Handle);
  if Assigned(fReportToolWindow) then
    devData.ReportWindowState.GetPlacement(fReportToolWindow.Handle);
  //translate code snippets(4), custom tools(2) and compilerSets(1) to inner macros("false")
  TransMenuMacros(7, false);
  SaveOptions;

  // Try to fix the file associations. Needs write access to registry,
  //which might cause exceptions to be thrown.
  DDETopic := 'DevCpp';
  if devData.CheckAssocs then begin
    try
      CheckAssociations(true); // check and fix
    except
      Application.MessageBox(PChar(Lang[ID_ENV_UACERROR]), PChar(Lang[ID_ERROR]), MB_OK);
      devData.CheckAssocs := false; // don't bother again
    end;
  end;

  // Windows: drop any obsolete DDE registration left behind by older builds.
  // Opening a file in a running instance is done through the FCL single
  // instance component, not DDE. A stale 'ddeexec' key makes Explorer on
  // Windows 7/8 wait ~10 s for a DDE conversation that never succeeds and then
  // report "向程序发送命令时出现问题". Done at shutdown to keep startup fast;
  // safe on Linux (no-op) and when the registry is not writable (errors are
  // swallowed).
  RemoveDDERegistrations;

  CloseAction := caFree;
end;

procedure TMainForm.actFileEncodingExecute(Sender: TObject);
var
  e: TEditor;
  newEnc: integer;
  newEolIndex: integer;
begin
  e := fEditorList.GetEditor;
  if not Assigned(e) then Exit;

  with TFileEncodingForm.Create(nil) do try
    listEncoding.ItemIndex := e.FileEncoding;
    listEolSymbol.ItemIndex := e.GetFileLineEndsIndex;

    if ShowModal = mrOK then begin
      newEnc := listEncoding.ItemIndex;
      newEolIndex := listEolSymbol.ItemIndex;

      // Apply encoding change if needed
      if newEnc <> e.FileEncoding then begin
        try
          e.ConvertEncoding(newEnc);
        except
          on E: Exception do
            MessageDlg(Format('Encoding conversion failed: %s', [E.Message]), mtError, [mbOk], 0);
        end;
      end;

      // Apply line endings change if needed
      if newEolIndex <> e.GetFileLineEndsIndex then begin
        try
          e.ConvertLineEnds(newEolIndex);
        except
          on E: Exception do
            MessageDlg(Format('Line endings conversion failed: %s', [E.Message]), mtError, [mbOk], 0);
        end;
      end;
    end;
  finally
    Free;
  end;
  e.Text.Invalidate;
end;

procedure TMainForm.SetIconTheme(const ATitle: String);
begin
  if not Assigned(devImageThemes) then Exit;
  // Theme not available (e.g. images missing) -> nothing to do.
  if devImageThemes.IndexOf(ATitle) < 0 then Exit;

  UpdateIconThemeChecks;
  if SameText(devData.Theme, ATitle) then Exit; // already active

  devData.Theme := ATitle;
  LoadTheme; // applies images to the main menu, popup menus and toolbars

  // Keep the custom top menu bar (fMenuBar) pointing at the new image list.
  if Assigned(fMenuBar) then
    fMenuBar.Images := MainMenu.Images;

  UpdateIconThemeChecks;
  SaveOptions; // persist the choice immediately
end;

// Radio-style check marks for the two icon-theme menu items.
procedure TMainForm.UpdateIconThemeChecks;
begin
  if Assigned(IconThemeClassicItem) then
    IconThemeClassicItem.Checked := SameText(devData.Theme, 'Classic');
  if Assigned(IconThemeOutlineItem) then
    IconThemeOutlineItem.Checked := SameText(devData.Theme, 'Outline');
end;

procedure TMainForm.actIconThemeClassicExecute(Sender: TObject);
begin
  SetIconTheme('Classic');
end;

procedure TMainForm.actIconThemeOutlineExecute(Sender: TObject);
begin
  SetIconTheme('Outline');
end;

procedure TMainForm.actIconThemeExecute(Sender: TObject);
begin
  //nothing to do
end;

// Shows a dialog asking whether to save all files and restart Dev-C++.
// Called when the user changes AppMode (dark/light/auto) which requires a restart.
procedure TMainForm.AskRestartAndRestart;
var
  CmdFile, CmdContent: String;
  i: integer;
  e: TEditor;
{$IFDEF MSWINDOWS}
  Stream: TFileStream;
  AnsiBuf: AnsiString;
  WideParams: WideString;
{$ENDIF}
begin
  if MessageDlg(Lang[ID_ERR_COLORMODECHANGED] + #13#10 + #13#10 + Lang[ID_ERR_NEEDRESTART],
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes
  then
    Exit;

  actSaveAllExecute(nil);

  // 逐个关闭当前打开的项目与文件，再退出。
  //
  // 原因：dmMain.AddtoHistory（把文件/项目写进 File 菜单的"历史文件"列表）只在
  // "关闭"路径里被调用——actCloseProjectExecute 负责项目本身，
  // TEditorList.CloseEditor 负责普通文件。Application.Terminate 不会触发
  // TMainForm.FormClose 里的那套关闭清理，所以直接 Terminate 会让当前打开的
  // 文件和项目全部漏出历史列表，下次启动 File 菜单里就看不到它们了。
  //
  // 顺序与 FormClose 一致（记最后项目 -> 关项目 -> 记文件数与激活项 -> 关全部文件），
  // 让"重启"与"正常关闭后再打开"在状态上等价。
  // 上面的 actSaveAllExecute 已把所有已修改的缓冲区落盘，因此这里的关闭
  // 不会弹出任何"是否保存"的对话框。

  // 1) 记住最后打开的项目（FormClose 同款），否则下次启动不会重新打开它
  if Assigned(fProject) then
    devData.LastProject := fProject.FileName
  else
    devData.LastProject := '';

  // 2) 关闭项目（会把项目本身加进历史列表）
  if Assigned(fProject) then
    actCloseProjectExecute(Self);

  // 3) 记住已打开文件的数量与当前激活项——必须在关闭之前取，FormClose 同样如此
  devData.LastFiles := fEditorList.PageCount;
  for i := 0 to EditorList.PageCount - 1 do begin
    if i < EditorPageControlLeft.PageCount then
      e := EditorList.GetEditor(i, EditorPageControlLeft)
    else
      e := EditorList.GetEditor(i - EditorPageControlLeft.PageCount, EditorPageControlRight);
    if Assigned(e) and e.Text.Focused then
      devData.LastActive := i;
  end;

  // 4) 关闭所有文件（每关一个都会通过 CloseEditor 加入历史列表）
  actCloseAllExecute(Self);

  // 关闭动作刚刚扩充了 MRU 历史列表，这里再落盘一次才算真正写入配置
  // （FormClose 里也是在关闭动作之后才调用 SaveOptions 的）。
  saveoptions();

  // 写临时 bat 文件
{$IFDEF MSWINDOWS}
  CmdFile := GetTempDir(False) + 'restart_devcpp.bat';

  CmdContent :=
    '@echo off' + #13#10 +
    'ping -n 3 127.0.0.1 >nul' + #13#10 +
    'start "" "' + Application.ExeName + '"' + #13#10 +
    'del "%~f0"' + #13#10; // 自删除

  // bat 文件必须用系统 ANSI 代码页（中文为 GBK/CP936）保存，
  // 因为 cmd.exe 按控制台代码页解析批处理文件。
  //
  // 注意：不能用 UTF8ToSys —— 它内部有 `NeedRTLAnsi` 判断，
  // 当系统 DefaultSystemCodePage = CP_UTF8 时会直接原样返回（不转换）。
  // 改用 UTF8ToWinCP：它无条件执行 UTF8->CP_ACP 转换（仅跳过纯 ASCII），
  // 不受全局代码页设置影响。
  AnsiBuf := UTF8ToWinCP(CmdContent);

  // 文件名同样转 ANSI，因为 TFileStream 走的是 ANSI 文件 API
  Stream := TFileStream.Create(AnsiString(UTF8ToWinCP(CmdFile)), fmCreate);
  try
    Stream.WriteBuffer(AnsiBuf[1], Length(AnsiBuf));
  finally
    Stream.Free;
  end;

  // 用 ShellExecute 启动（独立进程）
  // 注意：不能直接 ShellExecute 一个 .bat，否则会弹出控制台窗口。
  // 改为通过 cmd.exe /c 调用，并隐藏窗口。
  // 用 ShellExecuteW（宽字符版），彻底避开 ANSI 代码页转换问题。
  // CmdFile 是 UTF-8 字节，需先 UTF8Decode 成 WideString 再传给 W 版 API。
  WideParams := UTF8Decode('/c "' + CmdFile + '"');
  ShellExecuteW(0, nil, PWideChar(WideString('cmd.exe')),
    PWideChar(WideParams), nil, SW_HIDE);

{$ELSE}
  // 写临时 shell 脚本到 /tmp
  CmdFile := GetTempDir(False) + 'restart_devcpp.sh';
  CmdContent :=
    '#!/bin/sh' + #10 +
    'sleep 2' + #10 +
    '"' + Application.ExeName + '" &' + #10 +
    'rm -f "' + CmdFile + '"' + #10;

  with TStringList.Create do
  try
    Text := CmdContent;
    SaveToFile(CmdFile);
  finally
    Free;
  end;

  // 给脚本加执行权限
  fpChmod(CmdFile, &755);

  // 用 TProcess 启动脚本（后台运行，立即返回）
  with TProcess.Create(nil) do
  try
    Executable := '/bin/sh';
    Parameters.Add(CmdFile);
    Options := [poNoConsole];
    Execute;
  finally
    Free;
  end;
{$ENDIF}

  Application.Terminate;
end;

procedure TMainForm.actColorAutoModeExecute(Sender: TObject);
begin
//PreferredAppMode := pamAllowDark;
  //ApplyMetaDarkStyle(DefaultDark);
  // 通知所有窗口重绘
  AutoModeItem.checked := true;
  if devData.AppMode <> 1 then begin
    devData.AppMode := 1;
    AskRestartAndRestart;
  end;

  //Invalidate;
end;

procedure TMainForm.actColorDarkModeExecute(Sender: TObject);
begin
{$IFDEF MSWINDOWS}
  // Dark mode cann't be applied under Windows 10.
  if Ord(WindowsVersion) < Ord(wv10) then begin  //Comes from Win32proc
    Application.MessageBox(PChar(Lang[ID_ERR_DARKMODEWIN7]), PChar(Application.Name),
      MB_OK or MB_ICONWARNING);
    Exit;
  end;
{$ENDIF}
  //PreferredAppMode := pamForceDark;
  //ApplyMetaDarkStyle(DefaultDark);

  DarkModeItem.checked := True;
  if devData.AppMode <> 2 then begin
    devData.AppMode := 2;
    if devEditor.SchemeIndex < 7 then begin
      devEditor.SchemeIndex := 7;  //modern dark
      devEditor.SetColorScheme(devEditor.SchemeIndex);
    end;
    AskRestartAndRestart;
  end;
end;

procedure TMainForm.actColorLightModeExecute(Sender: TObject);
begin
  //PreferredAppMode := pamForceLight;
  //ApplyMetaDarkStyle(DefaultLight);
  LightModeItem.checked := True;
  if devData.AppMode <> 3 then begin
    devData.AppMode := 3;
    if devEditor.SchemeIndex >= 7 then begin
      devEditor.SchemeIndex := 1;  //classic light improved
      devEditor.SetColorScheme(devEditor.SchemeIndex);
    end;
    AskRestartAndRestart;
  end;
  //Invalidate;   // 通知所有窗口重绘
end;



procedure TMainForm.SingleInstanceReceivedParams(Sender: TBaseSingleInstance; Params: TStringList);
var
  I: Integer;
  FilePath: String;
  hCurThread, hFgThread: DWORD;
begin
  // This is called when a second instance passes command-line parameters to us
  // Params[0] is the executable path, Params[1+] are the file paths to open
  
  if Params.Count > 1 then begin
    fCriticalSection.Acquire;
    try
      for I := 1 to Params.Count - 1 do begin
        FilePath := Params[I];
        if FileExists(FilePath) then
          fFilesToOpen.Add(FilePath);
      end;
      
      if not fFirstShow then begin
        OpenFileList(fFilesToOpen);
        fFilesToOpen.Clear;
      end;
      
      // Bring window to foreground.
      // Plain SetForegroundWindow fails here because of the Windows
      // foreground lock: this process is not the foreground process when
      // the IPC message arrives. Standard workaround: attach our input
      // queue to the foreground thread's input queue, then activate.
      hCurThread := GetCurrentThreadId;
      hFgThread := GetWindowThreadProcessId(GetForegroundWindow, nil);
      keybd_event(VK_MENU, 0, 0, 0); // simulate Alt press to bypass the lock
      AttachThreadInput(hCurThread, hFgThread, True);
      try
        if IsIconic(Self.Handle) then
          ShowWindow(Self.Handle, SW_RESTORE)
        else
          ShowWindow(Self.Handle, SW_SHOW);
        SetForegroundWindow(Self.Handle);
        SetWindowPos(Self.Handle, HWND_TOP, 0, 0, 0, 0,
          SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
      finally
        AttachThreadInput(hCurThread, hFgThread, False);
        keybd_event(VK_MENU, 0, KEYEVENTF_KEYUP, 0);
      end;
    finally
      fCriticalSection.Release;
    end;
  end;
end;

procedure TMainForm.AppIdle(Sender: TObject; var Done: Boolean);
begin
  // Check for single instance messages
  if Assigned(fSingleInstance) and fSingleInstance.IsServer then
    fSingleInstance.ServerCheckMessages;
  Done := True;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fSingleInstance);
  FreeAndNil(fFilesToOpen);

  FreeAndNil(fCriticalSection);
  FreeAndNil(fLogOutputRawData);
  FreeAndNil(fTools);
  FreeAndNil(fAutoSaveTimer);
  FreeAndNil(devImageThemes);
  FreeAndNil(fEditorList);
  FreeAndNil(fCompiler);
  FreeAndNil(fTransList);
  //FreeAndNil(fAutoLinkList);
  FreeAndNil(fDebugger);
  FreeAndNil(dmMain);
  devExecutor.Free; // sets itself to nil
  Lang.Free; // sets itself to nil
  // fMenuItemMap removed
  DestroyOptions;


  FreeAndNil(fFileMonitor);
  FreeAndNil(ClassBrowser);
//  FreeAndNil(fClassBrowser);

  BrowserView.Images.Free; //
  BrowserView.Free;          //
//  ImagesRecord.Free;      //
  FreeAndNil(CodeCompletion);
  FreeAndNil(CppParser);
  FreeAndNil(CppPreprocessor);
  FreeAndNil(CppTokenizer);

end;

procedure TMainForm.actImportCBExecute(Sender: TObject);
begin
    with TImportCBForm.Create(Self) do begin
    if ShowModal = mrOK then
      OpenProject(GetFilename);
  end;
end;



//procedure TMainForm.BuildBookMarkMenus;
//var
//  idx: integer;
//  Text: String;
//  Shortcutnumber: Word;
//  GItem, TItem: TMenuItem;
//begin
//  Text := Lang[ID_MARKTEXT];
//  //ToggleBookMarksItem.Clear;
//  //GotoBookmarksItem.Clear;
//  for idx := 1 to 9 do begin
//    Shortcutnumber := Ord(inttostr(idx)[1]);
//
//    TItem := TMenuItem.Create(ToggleBookmarksItem);
//    TItem.Caption := format('%s &%d', [Text, idx]);
//    TItem.OnClick := ToggleBookmarkClick;
//    TItem.Tag := idx;
//    TItem.ShortCut := ShortCut(Shortcutnumber, [ssCtrl]);
//    ToggleBookmarksItem.Add(TItem);
//
//    GItem := TMenuItem.Create(GotoBookmarksItem);
//    GItem.Caption := TItem.Caption;
//    GItem.OnClick := GotoBookmarkClick;
//    GItem.Tag := idx;
//    GItem.ShortCut := ShortCut(Shortcutnumber, [ssAlt]);
//    GotoBookmarksItem.Add(GItem);
//  end;
//
//  CloneMenu(ToggleBookmarksItem, TogglebookmarksPopItem);
//  CloneMenu(GotoBookmarksItem, GotobookmarksPopItem);
//end;

procedure TMainForm.SetHints;
var
  idx: integer;
begin
  for idx := 0 to pred(ActionList.ActionCount) do
    TCustomAction(ActionList.Actions[idx]).Hint := StripHotKey(TCustomAction(ActionList.Actions[idx]).Caption);
  //cmbCompilers.Hint := Lang[ID_COMPILERSET];
end;

procedure TMainForm.WMDropFiles(var msg: TMessage);
var
  I, Count: integer;
  FileNameBuffer: array[0..260] of char;
  MessageHandle: THandle;
  FileList: TStringList;
begin
  try
    // Get drop information
    MessageHandle := THandle(msg.wParam);
    Count := DragQueryFile(MessageHandle, $FFFFFFFF, nil, 0);

    // Build file list
    FileList := TStringList.Create;
    try
      for I := 0 to Count - 1 do begin
        DragQueryFile(MessageHandle, I, FileNameBuffer, SizeOf(FileNameBuffer));
        FileList.Add(FileNameBuffer);
      end;
      OpenFileList(FileList);
      Application.BringToFront;
    finally
      FileList.Free;
    end;
  finally
    msg.Result := 0;
    DragFinish(THandle(msg.WParam));
  end;
end;

procedure TMainForm.LoadColor;
var
  //selectedTC: TThemeColor;
  //panelTC:TThemeColor;
  ForegroundColor: TColor;
  WindowColor    : TColor;
  BackgroundColor: TColor;
  //tc: TThemeColor;
begin
  //strToThemeColor(panelTC, devEditor.ColorScheme.Values[cPNL]);
  // TODO: ATSynEdit - dmMain.Cpp no longer exists (was TSynCppSyn)
  //BackgroundColor := TColor(RGB(100, 100,100) or dmMain.Cpp.WhitespaceAttribute.Background);
  //ForegroundColor := dmMain.Cpp.IdentifierAttribute.Foreground;

  BackgroundColor := clForm;  //clWindow;
  WindowColor     := clWindow;
  ForegroundColor := clWindowText;

  MainForm.Color := BackgroundColor;  //panelTC.Background;
  MainForm.Font.Name := devData.InterfaceFont;
  MainForm.Font.Size := devData.InterfaceFontSize;
  MainForm.Font.Color := ForegroundColor;

  EditorPageControlLeft.ParentFont := true;
  EditorPageControlRight.parentfont := true;

  //LeftPageControl.OwnerDraw := True;
  //EditorPageControlLeft.OwnerDraw := True;
  //MessageControl.OwnerDraw := True;


  // TODO: ATSynEdit - dmMain.Cpp no longer exists (was TSynCppSyn)
  //BackgroundColor := dmMain.Cpp.WhitespaceAttribute.Background;
  // Left panel
  //LeftPageControl.OwnerDraw := True;    // need to write code for PageControl's DrawTab events
  //MessageControl.OwnerDraw :=True; // need to write code for PageControl's DrawTab events

  //tbProjectLeft.Color := BackgroundColor;  // project toolbar
  //tbProjectLeft.GradientStartColor := BackgroundColor;
  //tbProjectLeft.GradientEndColor := BackgroundColor;

  ////tbProjectLeft.Color := BackgroundColor;
  ProjectView.Color := WindowColor;
  ProjectView.Font := MainForm.Font;  //devEditor.Font
  ProjectView.Font.Size := devData.InterfaceFontSize;
  ProjectView.Font.Color := ForegroundColor;

  BrowserView.Color := WindowColor;
  BrowserView.Font.Name := devData.InterfaceFont;
  BrowserView.Font.Size := devData.InterfaceFontSize;
  BrowserView.Font.Color := ForegroundColor;
  // Set item height explicitly �?must be done after removing tvoAutoItemHeight;
  // otherwise SetDefaultItemHeight is a no-op (see LCL treeview.inc line 4727)
  BrowserView.DefaultItemHeight := Abs(BrowserView.Font.Height) + 6;

  ////tbDebugLeft.Color := BackgroundColor;
  DebugView.Color := WindowColor;
  DebugView.Font := MainForm.Font;
  DebugView.Font.Size := devData.InterfaceFontSize;
  DebugView.Font.Color := ForegroundColor;

  txtLocals.Color := WindowColor;
  txtLocals.Font := MainForm.Font;
  txtLocals.Font.Size := devData.InterfaceFontSize;
  txtLocals.Font.Color := ForegroundColor;

  //DebugViews.OwnerDraw:=True;
  //cmbCompilers.Color := panelTC.Background;
  //cmbCompilers.Font := mainForm.Font;


  //strToThemeColor(selectedTC, devEditor.ColorScheme.Values[cSel]);


  {WatchView.Color := BackgroundColor;
  WatchView.Font := MainForm.Font;
  WatchView.Font.Color := ForegroundColor;
  LocalSheet.Color := BackgroundColor;
  LocalSheet.Font := MainForm.Font;
  LocalSheet.Font.Color := ForegroundColor;

  ProjectView.Color := BackgroundColor;
  ProjectView.Font := MainForm.Font;
  ProjectView.Font.Color := ForegroundColor;
  ClassBrowser.Font := MainForm.Font;
  ClassBrowser.Font.Color := ForegroundColor;
  ClassBrowser.TreeColors[ForeColor]:=ForegroundColor;
  ClassBrowser.TreeColors[BackColor]:=BackgroundColor;
  ClassBrowser.TreeColors[SelectedBackColor]:= selectedTC.Background;
  ClassBrowser.TreeColors[SelectedForeColor]:=selectedTC.Foreground;
  ClassBrowser.TreeColors[FunctionColor] := dmMain.Cpp.FunctionAttri.Foreground;
  ClassBrowser.TreeColors[ClassColor] := dmMain.Cpp.ClassAttri.Foreground;
  ClassBrowser.TreeColors[VarColor] := dmMain.Cpp.VariableAttri.Foreground;
  ClassBrowser.TreeColors[NamespaceColor] := dmMain.Cpp.StringAttribute.Foreground;
  ClassBrowser.TreeColors[TypedefColor] := dmMain.Cpp.ClassAttri.Foreground;
  ClassBrowser.TreeColors[PreprocessorColor] := dmMain.Cpp.DirecAttri.Foreground;
  ClassBrowser.TreeColors[EnumColor] := dmMain.Cpp.IdentifierAttribute.Foreground;
  ClassBrowser.TreeColors[KeywordColor] := dmMain.Cpp.KeywordAttribute.Foreground;
  ClassBrowser.TreeColors[LocalVarColor] := dmMain.Cpp.LocalVarAttri.Foreground;
  ClassBrowser.TreeColors[GlobalVarColor] := dmMain.Cpp.GlobalVarAttri.Foreground;
  ClassBrowser.TreeColors[InheritedColor] := dmMain.Cpp.LocalVarAttri.Foreground;

  fileBrowser.Font := MainForm.Font;
  fileBrowser.Font.Color := ForegroundColor;
  fileBrowser.Color := BackgroundColor;
  fileBrowser.Colors.SelectionTextColor := selectedTC.Foreground;
  fileBrowser.Colors.SelectionRectangleBlendColor := selectedTC.Background;
  fileBrowser.Colors.SelectionRectangleBorderColor := selectedTC.Background;
  //fileBrowser.Colors.UnfocusedColor := selectedTC.Background;
  //fileBrowser.Colors.UnfocusedSelectionColor := selectedTC.Background;
  //fileBrowser.Colors.UnfocusedSelectionBorderColor := selectedTC.Background;

  //Set CompletionBox Color
  strToThemeColor(tc, devEditor.ColorScheme.Values[cPNL]);
  if tc.Background = dmMain.Cpp.WhitespaceAttribute.Background then begin
    strToThemeColor(tc, devEditor.ColorScheme.Values[cAl]);
  end;
  CodeCompletion.Colors[BackColor] := tc.Background;
  CodeCompletion.Colors[ForeColor] := dmMain.Cpp.IdentifierAttribute.Foreground;
  CodeCompletion.Colors[FunctionColor] := dmMain.Cpp.FunctionAttri.Foreground;
  CodeCompletion.Colors[ClassColor] := dmMain.Cpp.ClassAttri.Foreground;
  CodeCompletion.Colors[VarColor] := dmMain.Cpp.VariableAttri.Foreground;
  CodeCompletion.Colors[NamespaceColor] := dmMain.Cpp.StringAttribute.Foreground;
  CodeCompletion.Colors[TypedefColor] := dmMain.Cpp.ClassAttri.Foreground;
  CodeCompletion.Colors[PreprocessorColor] := dmMain.Cpp.DirecAttri.Foreground;
  CodeCompletion.Colors[EnumColor] := dmMain.Cpp.DirecAttri.Foreground;
  CodeCompletion.Colors[KeywordColor] := dmMain.Cpp.KeywordAttribute.Foreground;
  CodeCompletion.Colors[LocalVarColor] := dmMain.Cpp.LocalVarAttri.Foreground;
  CodeCompletion.Colors[GlobalVarColor] := dmMain.Cpp.GlobalVarAttri.Foreground;
  

  CodeCompletion.Colors[SelectedBackColor] := BackgroundColor;
  CodeCompletion.Colors[SelectedForeColor] := ForegroundColor;
  CodeCompletion.Color := dmMain.Cpp.WhitespaceAttribute.Background;

  HeaderCompletion.Colors[BackColor] := tc.Background;
  HeaderCompletion.Colors[ForeColor] := dmMain.Cpp.IdentifierAttribute.Foreground;
  HeaderCompletion.Colors[PreprocessorColor] := dmMain.Cpp.DirecAttri.Foreground;
  HeaderCompletion.Colors[SelectedBackColor] := BackgroundColor;
  HeaderCompletion.Color := dmMain.Cpp.WhitespaceAttribute.Background;

  if Assigned(fTabnine) then begin
    fTabnine.Colors[BackColor] := tc.Background;
    fTabnine.Colors[ForeColor] := dmMain.Cpp.IdentifierAttribute.Foreground;
    fTabnine.Colors[FunctionColor] := dmMain.Cpp.CommentAttribute.Foreground;
    fTabnine.Colors[ClassColor] := dmMain.Cpp.KeywordAttribute.Foreground;
    fTabnine.Colors[VarColor] := dmMain.Cpp.IdentifierAttribute.Foreground;
    fTabnine.Colors[NamespaceColor] := dmMain.Cpp.StringAttribute.Foreground;
    fTabnine.Colors[TypedefColor] := dmMain.Cpp.SymbolAttribute.Foreground;
    fTabnine.Colors[PreprocessorColor] := dmMain.Cpp.IdentifierAttribute.Foreground;
    fTabnine.Colors[EnumColor] := dmMain.Cpp.IdentifierAttribute.Foreground;
    fTabnine.Colors[SelectedBackColor] := BackgroundColor;
    fTabnine.Colors[SelectedForeColor] := ForegroundColor;
    fTabnine.Color := dmMain.Cpp.WhitespaceAttribute.Background;
  end;

  StackTrace.Color := BackgroundColor;
  StackTrace.Font := MainForm.Font;
  StackTrace.Font.Color := ForegroundColor;
  BreakpointsView.Color := BackgroundColor;
  BreakpointsView.Font := MainForm.Font;
  BreakpointsView.Font.Color := ForegroundColor;
  }

  //resource panel
  ResourceOutput.Color := WindowColor;
  ResourceOutput.Font := devEditor.Font;  //MainForm.Font;
  ResourceOutput.Font.Size := devData.InterfaceFontSize;
  ResourceOutput.Font.Color := ForegroundColor;

  //compiler panal
  CompilerOutput.Color := WindowColor;
  CompilerOutput.Font := devEditor.Font;  //MainForm.Font;
  CompilerOutput.Font.Size := devData.InterfaceFontSize;
  CompilerOutput.Font.Color := ForegroundColor;

  //compile log  panel
  //chkShortenPaths.Color := BackGroundColor;
  chkShortenPaths.Font := MainForm.Font;
  chkShortenPaths.Font.Size := devData.InterfaceFontSize;
  chkShortenPaths.Font.Color := ForegroundColor;
  //chkTranslateMsg.Color := BackgroundColor;
  chkTranslateMsg.Font := MainForm.Font;
  chkTranslateMsg.Font.Size := devData.InterfaceFontSize;
  chkTranslateMsg.Font.Color := ForegroundColor;

  LogOutput.Color := WindowColor;
  LogOutput.Font := devEditor.Font; //MainForm.Font;
  LogOutput.Font.Size := devData.InterfaceFontSize;
  LogOutput.Font.Color := ForegroundColor;

  //debug  panel
  evaluateInput.Color := WindowColor; //panelTC.Background;
  evaluateInput.Font := MainForm.Font;
  evaluateInput.Font.Size := devData.InterfaceFontSize;
  evaluateInput.Font.Color := ForegroundColor;
  EvalOutput.Color := WindowColor;
  EvalOutput.Font := MainForm.Font;
  EvalOutput.Font.Size := devData.InterfaceFontSize;
  EvalOutput.Font.Color := ForegroundColor;
  cmbGdbCommand.Color := WindowColor;
  cmbGdbCommand.Font := MainForm.Font;
  cmbGdbCommand.Font.Size := devData.InterfaceFontSize;
  //cmbGdbCommand.Font.Color := ForegroundColor;
  debugOutput.Color := WindowColor;
  debugOutput.Font := MainForm.Font;
  debugOutput.Font.Size := devData.InterfaceFontSize;
  //debugOutput.Font.Color := ForegroundColor;

  //find  panel
  FindOutput.Color := WindowColor;
  FindOutput.Font := MainForm.Font;
  FindOutput.Font.Size := devData.InterfaceFontSize;
  FindOutput.Font.Color := ForegroundColor;

end;

procedure TMainForm.AssignMenuOwnerDrawHandlers(AParent: TMenuItem);
// Recursively bind OnDrawItem/OnMeasureItem to every TMenuItem.
// OwnerDraw on TMainMenu must have per-item handlers (Sender = TMenuItem).
var
  I: Integer;
  SubItem: TMenuItem;
begin
  for I := 0 to AParent.Count - 1 do begin
    SubItem := AParent.Items[I];
    SubItem.OnDrawItem := @MenuDrawItem;
    SubItem.OnMeasureItem := @MenuMeasureItem;
    // Recursively handle sub-menu items
    if SubItem.Count > 0 then
      AssignMenuOwnerDrawHandlers(SubItem);
  end;
end;

procedure TMainForm.MenuDrawItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; AState: TOwnerDrawState);
var
  Item: TMenuItem;
  S: String;
  Flags: LongInt;
  ImgList: TCustomImageList;
  TextRect: TRect;
  X: Integer;
begin
  Item := Sender as TMenuItem;

  // Separator line
  if Item.IsLine then begin
    ACanvas.Pen.Color := clBtnShadow;
    ACanvas.MoveTo(ARect.Left + 4, ARect.Top + ARect.Height div 2);
    ACanvas.LineTo(ARect.Right - 4, ARect.Top + ARect.Height div 2);
    Exit;
  end;

  // Background
  if (Integer(AState) and (1 shl Ord(odSelected))) <> 0 then
    ACanvas.Brush.Color := clHighlight
  else
    ACanvas.Brush.Color := clMenu;
  ACanvas.FillRect(ARect);

  // Font settings
  if (Integer(AState) and (1 shl Ord(odSelected))) <> 0 then
    ACanvas.Font.Color := clHighlightText
  else if not Item.Enabled then
    ACanvas.Font.Color := clGrayText
  else
    ACanvas.Font.Color := clMenuText;
  ACanvas.Font.Size  := fMenuFontSize;
  ACanvas.Font.Name  := devData.InterfaceFont;
  ACanvas.Font.Style := [];
  if Item.Default then
    ACanvas.Font.Style := [fsBold];

  // Draw icon and calculate text position
  // Top-level menu items (File, Edit, etc.) have Parent=nil or MainMenu.Items
  // Only dropdown menu items need icon space alignment

  //ImgList := Item.GetParentMenu.Images;
  //if not Assigned(ImgList) then
    ImgList := MainMenu.Images;
  if not IsTopLevelMenuItem(Item) and Assigned(ImgList) then begin
    // Dropdown menu item - always reserve space for icon area
    if Item.ImageIndex >= 0 then
      ImgList.Draw(ACanvas, ARect.Left + 2, ARect.Top + 2, Item.ImageIndex, Item.Enabled)
    else if Item.Checked then begin
      // Draw checkmark for checked items without icon
      ACanvas.Pen.Color := clMenuText;
      ACanvas.Brush.Style := bsClear;
      ACanvas.Rectangle(ARect.Left + 3, ARect.Top + 3, ARect.Left + 16, ARect.Top + 16);
      if Item.Enabled then begin
        ACanvas.Pen.Width := 2;
        ACanvas.MoveTo(ARect.Left + 5, ARect.Top + 9);
        ACanvas.LineTo(ARect.Left + 8, ARect.Top + 12);
        ACanvas.LineTo(ARect.Left + 13, ARect.Top + 6);
        ACanvas.Pen.Width := 1;
      end;
    end;
    // Always leave space equal to icon width for alignment
    X := ARect.Left + ImgList.Width + 6;
  end else
    X := ARect.Left + 4;

  // Draw caption
  S := Item.Caption;
  TextRect := ARect;
  TextRect.Left := X;
  Flags := DT_LEFT or DT_VCENTER or DT_SINGLELINE;
  DrawText(ACanvas.Handle, PChar(S), Length(S), TextRect, Flags);

  // Draw shortcut on the right side (dropdown menu items only)
  if not IsTopLevelMenuItem(Item) and (Item.ShortCut <> 0) then begin
    S := ShortCutToText(Item.ShortCut);
    if S <> '' then begin
      TextRect := ARect;
      TextRect.Right := ARect.Right - 8;
      Flags := DT_RIGHT or DT_VCENTER or DT_SINGLELINE;
      DrawText(ACanvas.Handle, PChar(S), Length(S), TextRect, Flags);
    end;
  end;
end;

procedure TMainForm.MenuMeasureItem(Sender: TObject; ACanvas: TCanvas;
  var AWidth, AHeight: Integer);
var
  Item: TMenuItem;
  ImgList: TCustomImageList;
  ShortCutText: String;
begin
  Item := Sender as TMenuItem;
  ImgList := Item.GetParentMenu.Images;
  if not Assigned(ImgList) then
    ImgList := MainMenu.Images;
  ACanvas.Font.Size := fMenuFontSize;
  ACanvas.Font.Name := devData.InterfaceFont;

  // Base dimensions from caption
  AWidth := ACanvas.TextWidth(Item.Caption) + 16;

  // Add space for image area (all dropdown menu items)
  if not IsTopLevelMenuItem(Item) and Assigned(ImgList) then begin
    if AHeight < ImgList.Height + 4 then
      AHeight := ImgList.Height + 4;
    // Add icon width + margin
    AWidth := AWidth + ImgList.Width + 8;
  end;

  // Add space for shortcut text
  if not IsTopLevelMenuItem(Item) and (Item.ShortCut <> 0) then begin
    ShortCutText := ShortCutToText(Item.ShortCut);
    if ShortCutText <> '' then
      AWidth := AWidth + ACanvas.TextWidth(ShortCutText) + 16;
  end;

  // Separator line height
  if Item.IsLine then
    AHeight := 6;
end;


function TMainForm.IsTopLevelMenuItem(Item: TMenuItem): Boolean;
var
  I: Integer;
begin
  Result := False;
  if not Assigned(Item) or not Assigned(MainMenu) then Exit;
  for I := 0 to MainMenu.Items.Count - 1 do
    if Item = MainMenu.Items[I] then begin
      Result := True;
      Exit;
    end;
end;

procedure TMainForm.CreateToolBarMenuBar;
var
  I: Integer;
  btn: TToolButton;
  maxW: Integer;
  w: Integer;
begin
  fMenuBar := TToolBar.Create(Self);
  fMenuBar.Parent := Self;
  fMenuBar.Align := alTop;
  fMenuBar.AutoSize := True;
  fMenuBar.Flat := True;
  fMenuBar.Transparent := False;
  fMenuBar.Color := clMenu;
  fMenuBar.ShowCaptions := True;
  fMenuBar.Height := fMenuFontSize + 12;
  fMenuBar.Images := MainMenu.Images;
  fMenuBar.Font.Size := fMenuFontSize;
  fMenuBar.Font.Name := devData.InterfaceFont;
  fMenuBar.List := True;

  maxW := 0;
  for I := 0 to MainMenu.Items.Count - 1 do begin
    btn := TToolButton.Create(fMenuBar);
    btn.Parent := fMenuBar;
    btn.Caption := MainMenu.Items[I].Caption;
    btn.Style := tbsButton;
    btn.OnClick := @ToolButtonClick;
    btn.Tag := I;  // Store menu index

    w := fMenuBar.Canvas.TextWidth(StringReplace(btn.Caption, '&', '', [rfReplaceAll]));
    if w > maxW then maxW := w;
  end;
  fMenuBar.ButtonWidth := maxW + 8;

  fMenuTrackTimer := TTimer.Create(Self);
  fMenuTrackTimer.Interval := 80;
  fMenuTrackTimer.OnTimer := @SwitchTimerTimer;
  fMenuTrackTimer.Enabled := False;

  fOpenBtn := nil;
  Menu := nil;  // Hide the native menu bar
end;

procedure TMainForm.RefreshToolbarCaptions;
var
  I: Integer;
begin
  if not Assigned(fMenuBar) then Exit;
  for I := 0 to fMenuBar.ButtonCount - 1 do
    fMenuBar.Buttons[I].Caption := MainMenu.Items[I].Caption;
end;

procedure TMainForm.ToolButtonClick(Sender: TObject);
var
  idx: Integer;
  subMenu: HMENU;
  p: TPoint;
  selID: Integer;
  item: TMenuItem;
begin
  if not (Sender is TToolButton) then Exit;
  idx := MenuIndexOf(TToolButton(Sender));
  if idx < 0 then Exit;

  if Assigned(fOpenBtn) then
    fOpenBtn.Down := False;
  fOpenBtn := TToolButton(Sender);
  fOpenBtn.Down := True;

  // Get native Windows submenu HMENU from the real TMainMenu
  subMenu := GetSubMenu(MainMenu.Handle, idx);
  if subMenu = 0 then Exit;

  // Install WH_MOUSE hook to detect hover over other top-level buttons
  // while the native popup menu is displayed (TrackPopupMenu runs its own msg loop).
  MenuHookLastBtn := fOpenBtn;
  MenuHook := SetWindowsHookEx(WH_MOUSE, @MenuHookProc, 0, GetCurrentThreadId);

  p := TToolButton(Sender).ClientToScreen(Point(0, TToolButton(Sender).Height));

  // TPM_RETURNCMD: return the selected menu-item command ID instead of
  // posting WM_COMMAND (which is lost because Menu := nil suppresses LCL processing).
  selID := Integer(TrackPopupMenu(subMenu,
    TPM_LEFTALIGN or TPM_TOPALIGN or TPM_RETURNCMD, p.X, p.Y, 0, Handle, nil));

  UnhookWindowsHookEx(MenuHook);
  MenuHook := 0;

  fMenuTrackTimer.Enabled := False;
  if Assigned(fOpenBtn) then fOpenBtn.Down := False;
  fOpenBtn := nil;

  // Execute the item selected via TPM_RETURNCMD
  if selID <> 0 then begin
    item := FindMenuItemByCommand(MainMenu.Items, selID);
    if Assigned(item) then begin
      if Assigned(item.Action) then
        (item.Action as TAction).Execute
      else if Assigned(item.OnClick) then
        item.OnClick(item);
    end;
  end;
end;


function TMainForm.MenuIndexOf(btn: TToolButton): Integer;
begin
  Result := btn.Tag;
end;


procedure TMainForm.WMMenuSwitch(var Message: TMessage);
var
  btn: TToolButton;
begin
  btn := TToolButton(PtrUInt(Message.WParam));
  if Assigned(btn) then begin
    fOpenBtn := nil;
    ToolButtonClick(btn);
  end;
end;


procedure TMainForm.WMTimer(var Message: TMessage);
var
  newBtn: TToolButton;
begin
  if MenuHookTimerID = 0 then Exit;
  KillTimer(Handle, MenuHookTimerID);
  MenuHookTimerID := 0;
  if MenuHook = 0 then Exit;
  newBtn := MenuHookLastBtn;
  if not Assigned(newBtn) or (newBtn = fOpenBtn) then Exit;
  Windows.EndMenu;
  PostMessage(Handle, WM_USER + 300, PtrUInt(newBtn), 0);
end;


function TMainForm.BtnAtMouse: TToolButton;
var
  pt: TPoint;
  i: Integer;
  btnRect: TRect;
begin
  Result := nil;
  pt := default(TPoint);
  if not Assigned(fMenuBar) then Exit;
  GetCursorPos(pt);
  pt := fMenuBar.ScreenToClient(pt);  // Convert to toolbar client coords
  for i := 0 to fMenuBar.ButtonCount - 1 do begin
    btnRect := fMenuBar.Buttons[i].BoundsRect;  // BoundsRect is in parent (toolbar) client coords
    if PtInRect(btnRect, pt) then begin
      Result := fMenuBar.Buttons[i];
      Exit;
    end;
  end;
end;


procedure TMainForm.SwitchTimerTimer(Sender: TObject);
var
  newBtn: TToolButton;
begin
  newBtn := BtnAtMouse;
  if not Assigned(newBtn) or (newBtn = fOpenBtn) then Exit;
  Windows.EndMenu;
  PostMessage(Handle, WM_USER + 300, PtrUInt(newBtn), 0);
end;

procedure TMainForm.ReloadColor;
begin
  LoadColor;
  debugOutput.Repaint;
  //WatchView.Repaint;
  //LocalSheet.Repaint;
  ProjectView.Repaint;
  BrowserView.Repaint;
  //fileBrowser.Repaint;
  //StackTrace.Repaint;
  //BreakpointsView.Repaint;
  CompilerOutput.Repaint;
  ResourceOutput.Repaint;
  LogOutput.Repaint;
  FindOutput.Repaint;
  EvalOutput.Repaint;
  //txtLocals.Repaint;
  MainForm.Repaint;
  PageControlPanel.Repaint;
  EditorPageControlLeft.Invalidate;
  EditorPageControlRight.Invalidate;
  chkShortenPaths.Invalidate;
end;

procedure TMainForm.LoadText;
var
  i, len: integer;
  s: String;
begin
  // Set interface font
  Font.Name := devData.InterfaceFont;
  Font.Size := devData.InterfaceFontSize;
  MessageControl.Font.Size := devData.InterfaceFontSize;

  // Menus
  FileMenu.Caption := Lang[ID_MNU_FILE];
  EditMenu.Caption := Lang[ID_MNU_EDIT];
  SearchMenu.Caption := Lang[ID_MNU_SEARCH];
  ViewMenu.Caption := Lang[ID_MNU_VIEW];
  ProjectMenu.Caption := Lang[ID_MNU_PROJECT];
  ExecuteMenu.Caption := Lang[ID_MNU_EXECUTE];
  ToolsMenu.Caption := Lang[ID_MNU_TOOLS];
  WindowMenu.Caption := Lang[ID_MNU_WINDOW];
  HelpMenu.Caption := Lang[ID_MNU_HELP];

  // File menu
  //mnuNew.Caption := Lang[ID_SUB_NEW];

  // New submenu
  //NewFileBtn.Hint := Lang[ID_HINT_NEW];
  actNewFiles.Caption := Lang[ID_SUB_NEW];
  actNewSource.Caption := Lang[ID_ITEM_NEWSOURCE];
  actNewProject.Caption := Lang[ID_ITEM_NEWPROJECT];
  actNewTemplate.Caption := Lang[ID_ITEM_NEWTEMPLATE];
  actNewClass.Caption := Lang[ID_ITEM_NEWCLASS];

  // Top level
  actOpen.Caption := Lang[ID_ITEM_OPEN];
  actSave.Caption := Lang[ID_ITEM_SAVEFILE];
  actSaveAs.Caption := Lang[ID_ITEM_SAVEAS];
  actSaveProjectAs.Caption := Lang[ID_ITEM_SAVEASPROJECT];
  actSaveAll.Caption := Lang[ID_ITEM_SAVEALL];
  actClose.Caption := Lang[ID_ITEM_CLOSEFILE];
  actCloseProject.Caption := Lang[ID_ITEM_CLOSEPROJECT];
  actCloseAll.Caption := Lang[ID_ITEM_CLOSEALL];

  actFileProperties.Caption := Lang[ID_ITEM_PROPERTIES];
  actFileEncoding.caption := Lang[ID_ENCODE_ENCODE];

  // Import submenu
  ImportItem.Caption := Lang[ID_SUB_IMPORT];
  actImportMSVC.Caption := Lang[ID_MSVC_MENUITEM];
  actImportCB.Caption := Lang[ID_CB_MENUITEM];

  // Exprt submenu
  ExportItem.Caption := Lang[ID_SUB_EXPORT];
  actExportHTML.Caption := Lang[ID_ITEM_EXPORTHTML];
  actExportRTF.Caption := Lang[ID_ITEM_EXPORTRTF];
  actExportTex.Caption := Lang[ID_ITEM_EXPORTTEX];
  actExportProject.Caption := Lang[ID_ITEM_EXPORTPROJECT];

  // Top level
  actPrint.Caption := Lang[ID_ITEM_PRINT];
  actPrintSU.Caption := Lang[ID_ITEM_PRINTSETUP];
  actHistoryClear.Caption := Lang[ID_ITEM_CLEARHISTORY];
  actExit.Caption := Lang[ID_ITEM_EXIT];

  actMsgCut.Caption := Lang[ID_ITEM_CUT];
  actMsgCopy.Caption := Lang[ID_ITEM_COPY];
  actMsgCopyAll.Caption := Lang[ID_ITEM_COPYALL];
  actMsgPaste.Caption := Lang[ID_ITEM_PASTE];
  actMsgSelAll.Caption := Lang[ID_ITEM_SELECTALL];
  actMsgSaveAll.Caption := Lang[ID_ITEM_SAVEALL];
  actMsgClear.Caption := Lang[ID_ITEM_CLEAR];

  // Edit menu
  actUndo.Caption := Lang[ID_ITEM_UNDO];
  actRedo.Caption := Lang[ID_ITEM_REDO];
  actCut.Caption := Lang[ID_ITEM_CUT];
  actCopy.Caption := Lang[ID_ITEM_COPY];
  actPaste.Caption := Lang[ID_ITEM_PASTE];
  actSelectAll.Caption := Lang[ID_ITEM_SELECTALL];

  // Insert submenu
  actInsert.Caption := Lang[ID_TB_INSERT];
  //DateTimeMenuItem.Caption := Lang[ID_ITEM_DATETIME];
  //CommentHeaderMenuItem.Caption := Lang[ID_ITEM_COMMENTHEADER];

  // Top level
  //actToggle.Caption := Lang[ID_TB_TOGGLE];
  //actGoto.Caption := Lang[ID_TB_GOTO];

  actToggleBookmark.Caption := Lang[ID_ITEM_TOGGLEBOOKMARK];
  actPrevBookmark.Caption := Lang[ID_ITEM_PREVBOOKMARK];
  actNextBookmark.Caption := Lang[ID_ITEM_NEXTBOOKMARK];
  actComment.Caption := Lang[ID_ITEM_COMMENTSELECTION];
  actUncomment.Caption := Lang[ID_ITEM_UNCOMMENTSELECTION];
  actToggleComment.Caption := Lang[ID_ITEM_TOGGLECOMMENT];
  actToggleCommentInline.Caption := Lang[ID_ITEM_TOGGLECOMMENTINLINE];
  actIndent.Caption := Lang[ID_ITEM_INDENTSELECTION];
  actUnindent.Caption := Lang[ID_ITEM_UNINDENTSELECTION];
  actCollapse.Caption := Lang[ID_ITEM_COLLAPSEALL];
  actUnCollapse.Caption := Lang[ID_ITEM_UNCOLLAPSEALL];
  actDuplicateLine.Caption := Lang[ID_ITEM_DUPLICATELINE];
  actDeleteLine.Caption := Lang[ID_ITEM_DELETELINE];
  actDeleteToLineEnd.Caption := Lang[ID_ITEM_DELETETOEND];
  actDeleteToLineBegin.Caption := Lang[ID_ITEM_DELETETOBEGIN];
  actMoveSelUp.Caption := Lang[ID_ITEM_MOVESELUP];
  actMoveSelDown.Caption := Lang[ID_ITEM_MOVESELDOWN];
  actCodeCompletion.Caption := Lang[ID_ITEM_SHOWCODECOMPLETION];

  // Search Menu
  actFind.Caption := Lang[ID_ITEM_FIND];
  actFindAll.Caption := Lang[ID_ITEM_FINDINALL];
  actReplace.Caption := Lang[ID_ITEM_REPLACE];
  actReplaceAll.Caption := Lang[ID_ITEM_REPLACEFILES];
  actSearchAgain.Caption := Lang[ID_ITEM_FINDNEXT];
  actRevSearchAgain.Caption := Lang[ID_ITEM_FINDPREV];
  actIncremental.Caption := Lang[ID_ITEM_INCREMENTAL];
  actGotoFunction.Caption := Lang[ID_ITEM_GOTOFUNCTION];
  actGotoLine.Caption := Lang[ID_ITEM_GOTO];

  // View Menu
  //AppearModeItem.Caption := Lang[ID_ITEM_APPEARMODE];
  actColorAutoMode.Caption := Lang[ID_ITEM_AUTOMODE];
  actColorDarkMode.Caption := Lang[ID_ITEM_DARKMODE];
  actColorLightMode.Caption := Lang[ID_ITEM_LIGHTMODE];

  //IconThemeItem.Caption := Lang[ID_ITEM_ICONTHEME];
  actIconThemeClassic.Caption := Lang[ID_ITEM_ICONCLASSIC];
  actIconThemeOutline.Caption := Lang[ID_ITEM_ICONCLEAN];
  ColorSchemeItem.Caption := Lang[ID_ITEM_COLORSCHEME];

  for i := 0 to (BuiltinSchemes) do begin  // "BuiltinSchemes" built-in + 1 custom
    ColorSchemeItem[i].Caption := Lang[ID_COLOR_SCHEME + i];
  end;


  actProjectManager.Caption := Lang[ID_ITEM_PROJECTVIEW];
  actMessagePanel.Caption := Lang[ID_ITEM_MESSAGEPANEL];
  actStatusbar.Caption := Lang[ID_ITEM_STATUSBAR];
  actShowSpecialChars.Caption := Lang[ID_ITEM_WITESPACETAB];
  actShowTopRuler.Caption := Lang[ID_ITEM_TOPRULER];
  actShowLineNumber.Caption := Lang[ID_ITEM_LINENUMBER];
  //actShowEndOfLine.Caption := Lang[ID_ITEM_ENDOFLINE];
  actShowMinimap.Caption := Lang[ID_ITEM_MINIMAP];
  actShowMacromap.Caption := Lang[ID_ITEM_MICROMAP];
  actWordWrap.Caption := Lang[ID_ITEM_WORDWRAP];
  actScrollUp.Caption := Lang[ID_ITEM_SCROLLUP];
  actScrollDown.Caption := Lang[ID_ITEM_SCROLLDOWN];
  actSwapHeaderSource.Caption := Lang[ID_ITEM_SWAPHEADERSOURCE];
  actSwapEditor.Caption := Lang[ID_ITEM_SWAPEDITOR];


  // Toolbar submenu
  //ToolBarsItem.Caption := Lang[ID_SUB_TOOLBARS];
  ToolMainItem.Caption := Lang[ID_TOOLMAIN];
  //ToolEditItem.Caption := Lang[ID_TOOLEDIT];
  //ToolSearchItem.Caption := Lang[ID_TOOLSEARCH];
  //ToolCompileAndRunItem.Caption := Lang[ID_TOOLCOMPRUN];
  //ToolProjectItem.Caption := Lang[ID_TOOLPROJECT];
  //ToolSpecialsItem.Caption := Lang[ID_TOOLSPECIAL];
  //ToolClassesItem.Caption := Lang[ID_LP_CLASSES];
  //ToolCompilersItem.Caption := Lang[ID_TOOLCOMPILERS];

  // Top level
  actViewToDoList.Caption := Lang[ID_VIEWTODO_MENUITEM];
  FloatingPojectManagerItem.Caption := Lang[ID_ITEM_FLOATWINDOW];
  FloatingReportWindowItem.Caption := Lang[ID_ITEM_FLOATREPORT];

  // Project menu
  actProjectNew.Caption := Lang[ID_ITEM_NEWFILE];
  actProjectAdd.Caption := Lang[ID_ITEM_ADDFILE];
  actProjectRemove.Caption := Lang[ID_ITEM_REMOVEFILE];
  actProjectOptions.Caption := Lang[ID_ITEM_PROJECTOPTIONS];
  actProjectMakeFile.Caption := Lang[ID_ITEM_EDITMAKE];
  actProjectSource.Caption := Lang[ID_ITEM_OPENSOURCE];

  // Execute menu
  actCompile.Caption := Lang[ID_ITEM_COMP];
  actRun.Caption := Lang[ID_ITEM_RUN];
  actCompRun.Caption := Lang[ID_ITEM_COMPRUN];
  actRebuild.Caption := Lang[ID_ITEM_REBUILD];
  actExecParams.Caption := Lang[ID_ITEM_EXECPARAMS];
  actSyntaxCheck.Caption := Lang[ID_ITEM_SYNTAXCHECK];
  actSyntaxCheckFile.Caption := Lang[ID_ITEM_SYNTAXCHECKFILE];
  actClean.Caption := Lang[ID_ITEM_CLEAN];
  actProfile.Caption := Lang[ID_ITEM_PROFILE];
  actDebug.Caption := Lang[ID_ITEM_DEBUG];
  actAttachProcess.Caption := LANG[ID_ITEM_ATTACHPROCESS];
  actGotoBreakPoint.Caption := Lang[ID_ITEM_GOTOBREAKPOINT];
  actBreakPoint.Caption := Lang[ID_ITEM_TOGGLEBREAK];
  actDeleteProfile.Caption := Lang[ID_ITEM_DELPROFINFORMATION];
  actAbortCompilation.Caption := Lang[ID_ITEM_ABORTCOMP];
  actShortenCompPaths.Caption := Lang[ID_ITEM_SHORTENCOMPPATHS];
  actMsgTranslate.Caption := Lang[ID_ITEM_TRANSLATEMSG];
  actViewCPU.Caption := Lang[ID_CPU_CAPTION];

  // Tools menu
  actCompOptions.Caption := Lang[ID_ITEM_COMPOPTIONS];
  actEnviroOptions.Caption := Lang[ID_ITEM_ENVIROOPTIONS];
  actEditorOptions.Caption := Lang[ID_ITEM_EDITOROPTIONS];
  actConfigTools.Caption := Lang[ID_ITEM_TOOLCONFIG];
  actConfigShortcuts.Caption := Lang[ID_ITEM_SHORTCUTSCONFIG];
  actFixHighDPI.Caption := Lang[ID_ITEM_FIXHIGHDPI];

  actFileExplorer.Caption := Lang[ID_ITEM_FILEEXPLORER];
  actConsoleOpen.Caption := Lang[ID_ITEM_CONSOLEOPEN];
  actConsoleLarge.Caption := Lang[ID_ITEM_CONSOLELARGE];
  actConsoleDefault.Caption := Lang[ID_ITEM_CONSOLEDEFAULT];
  actCodeDiff.Caption := Lang[ID_ITEM_TEXTDIFF];

  actPackageCheck.Caption := Lang[ID_ITEM_UPDATECHECK];
  actPackageManager.Caption := Lang[ID_ITEM_PACKMAN];

  TransMenuMacros(6, true);  //translate "Insert" sub menu(4) and "Tools" menu items(2).

  // Formatter menu
  actFormatCurrentFile.Caption := Lang[ID_FORMATTER_FORMATCURFILE];
  actFormatOptions.Caption := Lang[ID_FORMATTER_MENU];

  // Window menu
  if devData.FullScreen then
    actFullScreen.Caption := Lang[ID_ITEM_FULLSCRBACK]
  else
    actFullScreen.Caption := Lang[ID_ITEM_FULLSCRMODE];
  actNextWindow.Caption := Lang[ID_ITEM_NEXT];
  actPrevWindow.Caption := Lang[ID_ITEM_PREV];
  ListItem.Caption := Lang[ID_ITEM_LIST];
  actShowBars.Caption := Lang[ID_FULLSCREEN_SHOWBARS];

  // Help menu
  actHelpTutorial.Caption := Lang[ID_ITEM_TUTORIAL];
  actHelpManual.Caption := Lang[ID_ITEM_MANUAL];

  actHelpCLib.Caption := Lang[ID_ITEM_CLIB];
  actHelpFAQ.Caption := Lang[ID_ITEM_FAQ];
  actHelpAbout.Caption := Lang[ID_ITEM_ABOUT];
  actHelpTips.Caption := Lang[ID_ITEM_TIP];
  actHelpHomepage.Caption := Lang[ID_ITEM_HOMEPAGE];
  actHelpDonate.Caption := Lang[ID_ITEM_DONATE];

  // Debugging buttons
  actAddWatch.Caption := Lang[ID_ITEM_WATCHADD];
  actEditWatch.Caption := Lang[ID_ITEM_WATCHEDIT];
  actModifyWatch.Caption := Lang[ID_ITEM_MODIFYVALUE];
  actRemoveWatch.Caption := Lang[ID_ITEM_WATCHREMOVE];
  actNextLine.Caption := Lang[ID_ITEM_STEPNEXT];
  actStepLine.Caption := Lang[ID_ITEM_STEPINTO];
  actRuntoCursor.Caption := Lang[ID_ITEM_RUNTOCURSOR];
  actContinue.Caption := Lang[ID_ITEM_CONTINUE];
  actWatchItem.Caption := Lang[ID_ITEM_WATCHITEMS];
  actStopExecute.Caption := Lang[ID_ITEM_STOPEXECUTION];
  //actViewCPU.Caption := Lang[ID_ITEM_CPUWINDOW];
  ClearallWatchPop.Caption := Lang[ID_ITEM_CLEARALL];
  actNextIns.Caption := Lang[ID_ITEM_NEXTINS];
  actStepIns.Caption := Lang[ID_ITEM_STEPINS];
  actSkipFunction.Caption := Lang[ID_ITEM_SKIPFUNCTION];

  // Project/Unit/Folder popup
  actUnitRemove.Caption := Lang[ID_POP_REMOVE];
  actUnitRename.Caption := Lang[ID_POP_RENAME];
  actUnitOpen.Caption := Lang[ID_POP_OPEN];
  actUnitHeader.Caption := Lang[ID_POP_OPEN2];
  actUnitClose.Caption := Lang[ID_POP_CLOSE];
  actProjectNewFolder.Caption := Lang[ID_POP_ADDFOLDER];
  actProjectRemoveFolder.Caption := Lang[ID_POP_REMOVEFOLDER];
  actProjectRenameFolder.Caption := Lang[ID_POP_RENAMEFOLDER];
  mnuOpenWith.Caption := Lang[ID_POP_OPENWITH];

  // Editor popup
  actGotoDeclEditor.Caption := Lang[ID_POP_GOTODECL];
  actGotoImplEditor.Caption := Lang[ID_POP_GOTOIMPL];
  actCloseAllButThis.Caption := Lang[ID_POP_CLOSEALLBUTTHIS];
  actOpenFolder.Caption := Lang[ID_POP_OPENCONTAINING];
  actAddToDo.Caption := Lang[ID_POP_ADDTODOITEM];

  // Class Browser Popup
  actBrowserGotoDeclaration.Caption := Lang[ID_POP_GOTODECL];
  actBrowserGotoDefinition.Caption := Lang[ID_POP_GOTOIMPL];
  actBrowserNewClass.Caption := Lang[ID_POP_NEWCLASS];
  actBrowserNewMember.Caption := Lang[ID_POP_NEWMEMBER];
  actBrowserNewVar.Caption := Lang[ID_POP_NEWVAR];
  mnuBrowserViewMode.Caption := Lang[ID_POP_VIEWMODE];
  actBrowserViewAll.Caption := Lang[ID_POP_VIEWALLFILES];
  actBrowserViewProject.Caption := Lang[ID_POP_VIEWPROJECT];
  actBrowserViewCurrent.Caption := Lang[ID_POP_VIEWCURRENT];
  actBrowserViewIncludes.Caption := Lang[ID_POP_VIEWINCLUDES];
  actBrowserAddFolder.Caption := Lang[ID_POP_ADDFOLDER];
  actBrowserRemoveFolder.Caption := Lang[ID_POP_REMOVEFOLDER];
  actBrowserRenameFolder.Caption := Lang[ID_POP_RENAMEFOLDER];
  actBrowserShowInherited.Caption := Lang[ID_POP_SHOWINHERITED];

  // Message Control tabs
  CompSheet.Caption := Lang[ID_SHEET_COMP];
  ResSheet.Caption := Lang[ID_SHEET_RES];
  LogSheet.Caption := Lang[ID_SHEET_COMPLOG];
  DebugSheet.Caption := Lang[ID_SHEET_DEBUG];
  FindSheet.Caption := Lang[ID_SHEET_FIND];
  CloseSheet.Caption := Lang[ID_SHEET_CLOSE];

  // Compiler Tab
  CompilerOutput.Columns[0].Caption := Lang[ID_COL_LINE];
  CompilerOutput.Columns[1].Caption := Lang[ID_COL_COL];
  CompilerOutput.Columns[2].Caption := Lang[ID_COL_FILE];
  CompilerOutput.Columns[3].Caption := Lang[ID_COL_MSG];
  //I don't know why the Columns' width is shrink too narrow, so have to set width.    --Anbang
  CompilerOutput.Columns[0].Width := ResourceOutput.Columns[0].Width;
  CompilerOutput.Columns[1].Width := ResourceOutput.Columns[1].Width;

  // Resource Tab
  ResourceOutput.Columns[0].Caption := Lang[ID_COL_LINE];
  ResourceOutput.Columns[1].Caption := Lang[ID_COL_COL];
  ResourceOutput.Columns[2].Caption := Lang[ID_COL_FILE];
  ResourceOutput.Columns[3].Caption := Lang[ID_COL_MSG];

  // Debug Tab
  lblSendCommandGdb.Caption := Lang[ID_DEB_SENDGDBCOMMAND];
  lblEvaluate.Caption := Lang[ID_DEB_EVALUATE];

  // Adapt UI spacing to translation text length
  lblSendCommandGdb.Font:= MessageControl.Font;
  len := Canvas.TextWidth(lblSendCommandGdb.Caption) + 10;
  lblSendCommandGdb.Width := len;
  //cmbGdbCommand.Left := lblSendCommandGdb.Left+ len ;
  //cmbGdbCommand.Width := DebugOutput.Width - len - 6;
  DebugOutput.Left := lblSendCommandGdb.Left;

  // Find Results Tab
  FindOutput.Columns[0].Caption := '';
  FindOutput.Columns[1].Caption := Lang[ID_COL_LINE];
  FindOutput.Columns[2].Caption := Lang[ID_COL_COL];
  FindOutput.Columns[3].Caption := Lang[ID_COL_FILE];
  FindOutput.Columns[4].Caption := Lang[ID_COL_MSG];

  // Left page control
  LeftProjectSheet.Caption := Lang[ID_LP_PROJECT];
  LeftClassSheet.Caption := Lang[ID_LP_CLASSES];
  LeftDebugSheet.Caption := Lang[ID_SHEET_DEBUG];
  cbWatchLocals.Caption := Lang[ID_ENV_WATCHLOCALS];
  cbWatchLocals.Checked := devData.WatchLocals;

  // File Associate
  for I := 0 to AssociationsCount - 1 do begin
    s := Associations[I, 1];
    s := StringReplace(s, 'Resource Source File', Lang[ID_ASSO_RESOURCE], []);
    s := StringReplace(s, 'Source File', Lang[ID_ASSO_SOURCE], []);
    s := StringReplace(s, 'Header File', Lang[ID_ASSO_HEADER], []);
    s := StringReplace(s, 'Project File', Lang[ID_ASSO_PROJECT], []);
    s := StringReplace(s, 'Template File', Lang[ID_ASSO_TEMPLATE], []);
    Associations[I, 1] := s;
  end;

//  BuildBookMarkMenus;  //discard
  SetHints;

end;

procedure TMainForm.SetStatusbarLineCol;
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    //Statusbar.Panels[1].Text := Format(Lang[ID_STATUSBARPLUS],
    Statusbar.Panels[0].Text := Format(Lang[ID_COL_LINE] + ': %d / %d  ' + Lang[ID_COL_COL] + ': %d',
        [e.Text.Carets[0].PosY + 1, e.Text.Strings.Count, e.Text.Carets[0].PosX + 1]);
    if (e.Text.TextSelected <> '' ) then
      Statusbar.Panels[1].Text := Format(Lang[ID_COL_SELECT] + ': %d', [Length(e.Text.TextSelected)])
    else
      Statusbar.Panels[1].Text := '';

      //0]); // ATSynEdit: Lines.Capacity not supported (ATStrings uses dynamic storage)
  end else begin
    StatusBar.Panels.BeginUpdate;
    try
      Statusbar.Panels[0].Text := '';
      Statusbar.Panels[1].Text := '';
      StatusBar.Panels[2].Text := '';
      StatusBar.Panels[3].Text := '';
      StatusBar.Panels[4].Text := '';
    finally
      StatusBar.Panels.EndUpdate; // redraw once
    end;
  end;
end;

procedure TMainForm.SetStatusbarMessage(const msg: String);
begin
  Statusbar.Panels[1].Text := msg;
end;

//procedure TMainForm.ToggleBookmarkClick(Sender: TObject);
//var
//  e: TEditor;
//begin
//  e := fEditorList.GetEditor;
//  with Sender as TMenuItem do
//    if Assigned(e) then begin
//      Checked := not Checked;
//      if (Parent = ToggleBookmarksItem) then
//        TogglebookmarksPopItem.Items[Tag - 1].Checked := Checked
//      else
//        TogglebookmarksItem.Items[Tag - 1].Checked := Checked;
//      GotobookmarksPopItem.Items[Tag - 1].Checked := Checked;
//      GotobookmarksItem.Items[Tag - 1].Checked := Checked;
//      if Checked then
//        e.Text.SetBookMark(Tag, e.Text.CaretX, e.Text.CaretY)
//      else
//        e.Text.ClearBookMark(Tag);
//    end;
//end;


//procedure TMainForm.GotoBookmarkClick(Sender: TObject);
//var
//  e: TEditor;
//begin
//  e := fEditorList.GetEditor;
//  if assigned(e) then
//    e.Text.GotoBookMark(TMenuItem(Sender).Tag);
//end;

procedure TMainForm.OpenCloseMessageSheet(Open: boolean);
begin
  if Assigned(fReportToolWindow) then
    Exit;

  // Switch between open and close
  with MessageControl do
    if Open then
      Height := fPreviousHeight // remember height
    else begin
      Height := Height - CompSheet.Height; // only show the tab captions
      ActivePageIndex := -1;
    end;

  if Open then begin    //the font of these two controls often automatically change. Fix it. by Anbang
    lblEvaluate.Font := MessageControl.Font;
    lblSendCommandGdb.Font:= MessageControl.Font;
    if (MessageControl.ActivePage = CloseSheet) or (MessageControl.ActivePage = nil) then
      MessageControl.ActivePage := LogSheet;
  end;

  CloseSheet.TabVisible := Open;
  SplitterBottom.Visible := Open;
  Statusbar.Top := Self.ClientHeight;
end;

procedure TMainForm.MessageControlChange(Sender: TObject);
begin
  if MessageControl.ActivePage = CloseSheet then begin
    if Assigned(fReportToolWindow) then begin
      fReportToolWindow.Close;
      MessageControl.ActivePageIndex := 0;
    end else
      OpenCloseMessageSheet(false);
  end else begin
    OpenCloseMessageSheet(true);

//    if MessageControl.ActivePage = DebugSheet then begin
//      EvalOutput.Left :=   EvaluateInput.Left;
//      EvalOutput.Width :=   EvaluateInput.Width;
//      EvalOutput.Visible := TRUE;
//      EvalOutput.Show;
//      EvalOutput.Repaint;
//      DebugOutput.Visible := true;
//      DebugOutput.Show;
//      DebugOutput.Repaint;
//    end;
  end;
end;

procedure TMainForm.MessageControlResize(Sender: TObject);
begin
  //EvalOutput.Height := DebugStartPanel.Height - EvalOutput.top - 5;
end;



procedure TMainForm.MRUClick(Sender: TObject);
var
  s: String;
  e: TEditor;
begin
  s := PMRUItem(dmMain.MRU[TMenuItem(Sender).Tag])^.FileName;
  if FileExists(s) then begin
    if fEditorList.PageCount = 1 then begin //close the empty source file created on startup
        e := fEditorList.GetEditor;
        //if Assigned(e) and (not e.Text.Modified) and (e.Text.GetTextLen = 0) then
        if Assigned(e) and (not e.Modified) and (e.Text.Strings.Count = 1) and (trim(e.Text.Text) = '') then
          fEditorList.CloseEditor(e);
      end;
    if GetFileTyp(s) = utPrj then
      OpenProject(s)
    else
      OpenFile(s);
  end else
    MessageDlg(Format(Lang[ID_ERR_RENAMEDDELETED], [s]), mtInformation, [mbOK], 0);

end;


//todo
procedure TMainForm.CodeInsClick(Sender: TObject);
var
  e: TEditor;
  s: String;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    s := dmMain.CodeInserts[TMenuItem(Sender).Tag]^.Line;
    e.InsertString(s, TRUE);
  end;
end;

procedure TMainForm.ToolItemClick(Sender: TObject);
var
  idx: integer;
begin // TODO: ask on SO
  idx := (Sender as TMenuItem).Tag;

  with fTools.ToolList[idx]^ do
    ExecuteFile(ParseToolParams(Exec), ParseToolParams(Params), ParseToolParams(WorkDir), SW_SHOW);
end;

procedure TMainForm.OpenProject(const s: String);
var
  s2: String;
begin
  if Assigned(fProject) then begin
    if fProject.Name = '' then
      s2 := fProject.FileName
    else
      s2 := fProject.Name;
    if MessageDlg(format(Lang[ID_MSG_CLOSEPROJECTPROMPT], [s2]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      actCloseProject.Execute
    else
      exit;
  end;

  BrowserView.BeginUpdate;    // Only update class browser once
  //UpdateBrowserView;

  if not FileExists(s) then begin
    Application.MessageBox(PChar(Format(Lang[ID_ERR_FILENOTFOUND], [s])), PChar(Lang[ID_ERROR]),
      MB_ICONHAND);
    Exit;
  end;

  try
    fProject := TProject.Create(s, DEV_INTERNAL_OPEN);
    if fProject.FileName <> '' then begin
      dmMain.RemoveFromHistory(s);

      // if project manager isn't open then open it
      if not devData.ShowLeftPages then
        actProjectManager.Execute;

      CheckForDLLProfiling;
      UpdateAppTitle;
      UpdateCompilerList;
      ScanActiveProject;
      LeftPageControl.ActivePage := LeftProjectSheet;
    end else begin
      fProject.Free;
      fProject := nil;
    end;
  finally
    BrowserView.EndUpdate;
    //UpdateBrowserView;
  end;
end;

procedure TMainForm.OpenFile(const FileName: String);
var
  e: TEditor;
begin
  // Don't bother opening duplicates
  e := fEditorList.FileIsOpen(FileName);
  if Assigned(e) then begin
    e.Activate;
    Exit;
  end;

  // Issue an error if it doesn't exist
  if not FileExists(FileName) then begin
    Application.MessageBox(PChar(Format(Lang[ID_ERR_FILENOTFOUND], [FileName])), PChar(Lang[ID_ERROR]),
      MB_ICONHAND);
    Exit;
  end;

  // Open the file in an editor
  e := fEditorList.NewEditor(FileName, False, False);
  filemonitor.Monitor(FileName); //
  if Assigned(fProject) then begin
    if (not SameFileName(fProject.FileName, FileName)) and (fProject.GetUnitFromString(FileName) = -1) then
      dmMain.RemoveFromHistory(FileName);
  end else begin
    dmMain.RemoveFromHistory(FileName);
  end;
  e.Activate;

  // Parse it after is has been shown so the user will not see random unpainted stuff for a while.
  if not Assigned(fProject) then begin
    CppParser.ParseFile(AnsiString(e.FileName), e.InProject, True);
    ClassBrowser.CurrentFile := AnsiString(e.FileName);
    // Force rebuild of ClassBrowser data model from parser (which now has the
    // newly parsed file's symbols). UpdateFromParser calls NotifyDataChanged
    // which triggers UpdateBrowserView. Without this, fRootItems stays stale
    // because SetCurrentFile skips UpdateFromParser when sfAll, and even for
    // other filters the EditorEnter-triggered UpdateFromParser ran before ParseFile.
    ClassBrowser.UpdateFromParser(CppParser);
  end;
end;

procedure TMainForm.OpenFileList(List: TStringList);
var
  I: integer;
begin
  if List.Count = 0 then
    Exit;

  // Check if there is a project file inside the list
  for I := 0 to List.Count - 1 do begin
    if GetFileTyp(List[I]) = utPrj then begin
      OpenProject(List[I]); // open only the first found project
      Exit;
    end;
  end;

  // Didn't find a project? Open the whole list
//  ClassBrowser.BeginUpdate;
  UpdateBrowserView;
  try
    fEditorList.BeginUpdate;
    try
      for I := 0 to List.Count - 1 do
        OpenFile(List[I]); // open all files
    finally
      fEditorList.EndUpdate;
    end;
  finally
    //ClassBrowser.EndUpdate;
  end;
  //Application.BringToFront;
end;

procedure TMainForm.AddFindOutputItem(const line, col, filename, msg, keyword: String);
var
  NewItem: TListItem;
  BoldLenRef: Pointer;
begin
  NewItem := FindOutput.Items.Add;
  NewItem.Caption := '';
  GetMem(BoldLenRef, SizeOf(Integer));
  PInteger(BoldLenRef)^ := Length(keyword);
  NewItem.Data := BoldLenRef;
  NewItem.SubItems.Add(line);
  NewItem.SubItems.Add(col);
  NewItem.SubItems.Add(filename);
  NewItem.SubItems.Add(msg);
end;

procedure TMainForm.TransMenuMacros(num: integer; flag: boolean);
var
  i, j: integer;
  s, s2: string;
begin
  //num: 4 for insert submenu, 2 for tool menu, 1 for compilerset
  if (num div 4 > 0) then begin  //translate code snippets
    j := dmMain.CodeOffset - 1;
    for i := 0 to dmMain.CodeInserts.Count - 1 do begin
      s := dmMain.CodeInserts.Items[i]^.Caption;
      s2 := '';
      repeat
        j := j + 1;
        if j >= dmMain.CodeMenu.count then //validate j
          break;
        s2 := dmMain.CodeMenu.Items[j].Caption;
      until samestr(s, s2);
      if not samestr(s, s2) then //validate s and s2
        break;

      if (flag = true) then begin
        s := StringReplace(s, '$COMMENTHEADER$', Lang[ID_ITEM_COMMENTHEADER], []);
        s := StringReplace(s, '$DATETIME$', Lang[ID_ITEM_DATETIME], []);
      end else begin
        s := StringReplace(s, Lang[ID_ITEM_COMMENTHEADER], '$COMMENTHEADER$', []);
        s := StringReplace(s, Lang[ID_ITEM_DATETIME], '$DATETIME$', []);
      end;
      dmMain.CodeInserts.Items[i]^.Caption := s;
      dmMain.CodeMenu.Items[j].Caption := s;
    end;
  end;

  if ((num mod 4) div 2 > 0) then begin  //translate custom tools under "tool" menu
    for i := 0 to fTools.ToolList.Count - 1 do begin
      s := fTools.ToolList.Items[i]^.Title;
      //s := fTools.Menu.Items[ftools.Offset + i + 1].Caption;
      if (flag = true) then begin
        s := StringReplace(s, '$TOOL1$', Lang[ID_MENU_TOOL1], []);
        s := StringReplace(s, '$TOOL2$', Lang[ID_MENU_TOOL2], []);
        s := StringReplace(s, '$TOOL3$', Lang[ID_MENU_TOOL3], []);
        s := StringReplace(s, '$TOOL4$', Lang[ID_MENU_TOOL4], []);
        s := StringReplace(s, '$TOOL5$', Lang[ID_MENU_TOOL5], []);
      end else begin
        s := StringReplace(s, Lang[ID_MENU_TOOL1], '$TOOL1$', []);
        s := StringReplace(s, Lang[ID_MENU_TOOL2], '$TOOL2$', []);
        s := StringReplace(s, Lang[ID_MENU_TOOL3], '$TOOL3$', []);
        s := StringReplace(s, Lang[ID_MENU_TOOL4], '$TOOL4$', []);
        s := StringReplace(s, Lang[ID_MENU_TOOL5], '$TOOL5$', []);
      end;
      fTools.ToolList.Items[i]^.Title := s;
      if (fTools.Offset + i + 1 < fTools.Menu.Count) then
        fTools.Menu.Items[ftools.Offset + i + 1].Caption := s;
    end;
  end;

  if (num mod 2 > 0) then begin  //translate compiler sets
     for i := 0 to devCompilerSets.Count - 1 do begin
      s := devCompilerSets.Sets[i].Name;
      //s := fTools.Menu.Items[ftools.Offset + i + 1].Caption;
      if (flag = true) then begin
        s := StringReplace(s, '-bit', Lang[ID_BIT], []);
        s := StringReplace(s, 'Release', Lang[ID_RELEASE], []);
        s := StringReplace(s, 'Debug', Lang[ID_DEBUG], []);
        s := StringReplace(s, 'Profiling', Lang[ID_PROFILING], []);
      end else begin
        s := StringReplace(s, Lang[ID_BIT], '-bit', []);
        s := StringReplace(s, Lang[ID_RELEASE], 'Release', []);
        s := StringReplace(s, Lang[ID_DEBUG], 'Debug', []);
        s := StringReplace(s, Lang[ID_PROFILING], 'Profiling', []);
      end;
      devCompilerSets.Sets[i].Name := s;
      //fTools.Menu.Items[ftools.Offset + i + 1].Caption := s;
    end;
  end;
end;

function TMainForm.ParseToolParams(s: String): String;

var
  e: TEditor;
  windir: string;
  pfdir: string;
begin
  e := fEditorList.GetEditor;

  // <DEFAULT>
  s := StringReplace(s, cDefault, devDirs.Default, [rfReplaceAll]);

  // <EXECPATH>
  s := Stringreplace(s, cExecDir, devDirs.Exec, [rfReplaceAll]);

  // <DEVCPPVERISON>
  s := StringReplace(s, cDevVer, DEVCPP_VERSION, [rfReplaceAll]);

  // <WINDIR>
  windir := GetEnvironmentVariable('WINDIR');
  s := StringReplace(s, cWinDir, windir, [rfReplaceAll]);

  // <PROGRAMFILES>
  pfdir := GetEnvironmentVariable('PROGRAMFILES');
  s := StringReplace(s, CPfDir, pfdir, [rfReplaceAll]);


  if assigned(fProject) then begin
    // <EXENAME>
    s := StringReplace(s, cEXEName, '"' + fProject.Executable + '"', [rfReplaceAll]);

    // <PROJECTNAME>
    s := StringReplace(s, cPrjName, fProject.Name, [rfReplaceAll]);

    // <PROJECTFILE>
    s := StringReplace(s, cPrjFile, fProject.FileName, [rfReplaceAll]);

    // <PROJECTPATH>
    s := StringReplace(s, cPrjPath, fProject.Directory, [rfReplaceAll]);

    if Assigned(e) then begin
      // <SOURCENAME>
      s := StringReplace(s, cCurSrc, AnsiString(e.FileName), [rfReplaceAll]);

      // <SOURCEPATH>
      s := StringReplace(s, cSrcPath, ExtractFilePath(AnsiString(e.FileName)), [rfReplaceAll]);
    end;

    // <SOURCESPCLIST>
    s := StringReplace(s, cSrcList, fProject.ListUnitStr(' '), [rfReplaceAll]);
  end else if assigned(e) then begin
    // <EXENAME>
    s := StringReplace(s, cEXEName, '"' + ChangeFileExt(AnsiString(e.FileName), EXE_EXT) + '"', [rfReplaceAll]);

    // <PROJECTNAME>
    s := StringReplace(s, cPrjName, AnsiString(e.FileName), [rfReplaceAll]);

    // <PRJECTFILE>
    s := StringReplace(s, cPrjFile, AnsiString(e.FileName), [rfReplaceAll]);

    // <PROJECTPATH>
    s := StringReplace(s, cPrjPath, ExtractFilePath(AnsiString(e.FileName)), [rfReplaceAll]);

    // <SOURCENAME>
    s := StringReplace(s, cCurSrc, AnsiString(e.FileName), [rfReplaceAll]);

    // <SOURCEPATH>
    s := StringReplace(s, cSrcPath, ExtractFilePath(AnsiString(e.FileName)), [rfReplaceAll]);

    // <WORDXY>
    // ATSynEdit: use TextCurrentWord instead of WordAtCursor
    s := StringReplace(s, cWordXY, String(e.Text.TextCurrentWord), [rfReplaceAll]);
  end;

  // clear unchanged macros

  if not assigned(fProject) then
    s := StringReplace(s, cSrcList, '', [rfReplaceAll]);

  if not assigned(e) then begin
    s := StringReplace(s, cCurSrc, '', [rfReplaceAll]);
    // ATSynEdit: use empty string since no editor
    s := StringReplace(s, cWordXY, '', [rfReplaceAll]);
    // if no editor assigned return users default directory
    s := StringReplace(s, cSrcPath, devDirs.Default, [rfReplaceAll]);
  end;

  if not assigned(fProject) and not assigned(e) then begin
    s := StringReplace(s, cEXEName, '', [rfReplaceAll]);
    s := StringReplace(s, cPrjName, '', [rfReplaceAll]);
    s := StringReplace(s, cPrjFile, '', [rfReplaceAll]);
    s := StringReplace(s, cPrjPath, '', [rfReplaceAll]);
  end;

  Result := s;
end;

procedure TMainForm.CompOutputProc(const _Line, _Col, _Unit, _Message: String);
var
  msg : String;
  i : integer;
begin
  //�󲿷ֱ�����Ϣ�Ѿ��ǰ� GCC ��Ϣʵ���˱��ػ����롣����������Ҫ�滻�����з��롣

  msg := _Message;

  if devData.TranslateMsg then begin
    for I := 0 to fTransList.count div 2 - 1 do
      msg := StringReplace(msg, fTransList[i*2] , fTransList[i*2+1], []);
  end;

  msg := StringReplace(msg, '[Warning]', '[' + Lang[ID_WARN] + ']', []);
  msg := StringReplace(msg, '[Error]',   '[' + Lang[ID_ERROR] + ']', []);
  msg := StringReplace(msg, '[Hint]' ,   '[' + Lang[ID_HINT] + ']', []);
  msg := StringReplace(msg, '[Note]' ,   '[' + Lang[ID_NOTE] + ']', []);

  with CompilerOutput.Items.Add do begin
    Caption := _Line;
    SubItems.Add(_Col);
    SubItems.Add(GetRealPath(_Unit));
    SubItems.Add(msg);  //(_Message);
  end;

  // Update tab caption
  CompSheet.Caption := Lang[ID_SHEET_COMP] + ' (' + IntToStr(CompilerOutput.Items.Count) + ')'
end;

procedure TMainForm.CompResOutputProc(const _Line, _Col, _Unit, _Message: String);
begin
  with ResourceOutput.Items.Add do begin
    Caption := _Line;
    SubItems.Add(_Col);
    SubItems.Add(GetRealPath(_Unit));
    SubItems.Add(_Message);
  end;

  // Update tab caption
  ResSheet.Caption := Lang[ID_SHEET_RES] + ' (' + IntToStr(ResourceOutput.Items.Count) + ')'
end;

procedure TMainForm.CompEndProc;
var
  I: integer;
  sErr, sWarn: string;
begin
  // Close it if there's nothing to show
  if  (CompilerOutput.Items.Count = 0) and (ResourceOutput.Items.Count = 0)
    and devData.AutoCloseProgress then begin
    OpenCloseMessageSheet(FALSE);

    // Or open it if there is anything to show
  end else begin
    if (CompilerOutput.Items.Count > 0) then begin
      if MessageControl.ActivePage <> CompSheet then
        MessageControl.ActivePage := CompSheet;
    end else if (ResourceOutput.Items.Count > 0) then begin
      if MessageControl.ActivePage <> ResSheet then
        MessageControl.ActivePage := ResSheet;
    end else
      MessageControl.ActivePage := LogSheet;
    OpenCloseMessageSheet(TRUE);
  end;

  sErr := '[' + Lang[ID_ERROR] + ']';  //'[Error]';
  sWarn := '[' + Lang[ID_WARN] + ']';  //'[Warning]';

//  if devData.TranslateMsg and (Pos('Chinese', devData.Language) > 0) then begin
//    for I := 0 to fTransList.count div 2 - 1 do begin  //Find the translated string
//      if samestr('[Error]', fTransList[i*2]) then sErr := fTransList[i*2+1];
//      if samestr('[Warning]', fTransList[i*2]) then sWarn := fTransList[i*2+1];
//    end;
//  end;

  // Jump to problem location, sorted by significance
  if fCompiler.ErrorCount > 0 then begin

    // First try to find errors
    for I := 0 to CompilerOutput.Items.Count - 1 do begin

      // Caption equals the 'Line' column
      if not SameStr(CompilerOutput.Items[I].Caption, '') then begin

        if StartsStr(sErr, CompilerOutput.Items[I].SubItems[2]) then begin  //'[Error]'

          // This item has a line number, proceed to set cursor properly
          CompilerOutput.Selected := CompilerOutput.Items[I];
          CompilerOutput.Selected.MakeVisible(False);
          CompilerOutputDblClick(CompilerOutput);
          Exit;
        end;
      end;
    end;

    // Then try to find warnings
    for I := 0 to CompilerOutput.Items.Count - 1 do begin
      if not SameStr(CompilerOutput.Items[I].Caption, '') then begin
        if StartsStr(sWarn, CompilerOutput.Items[I].SubItems[2]) then begin  //'[Warning]'
          CompilerOutput.Selected := CompilerOutput.Items[I];
          CompilerOutput.Selected.MakeVisible(False);
          CompilerOutputDblClick(CompilerOutput);
          Exit;
        end;
      end;
    end;

    // Then try to find anything with a line number...
    for I := 0 to CompilerOutput.Items.Count - 1 do begin
      if not SameStr(CompilerOutput.Items[I].Caption, '') then begin
        CompilerOutput.Selected := CompilerOutput.Items[I];
        CompilerOutput.Selected.MakeVisible(False);
        CompilerOutputDblClick(CompilerOutput);
        Exit;
      end;
    end;

    // Then try to find a resource error
    if ResourceOutput.Items.Count > 0 then begin
      ResourceOutput.Selected := ResourceOutput.Items[0];
      ResourceOutput.Selected.MakeVisible(False);
      CompilerOutputDblClick(ResourceOutput);
    end;
  end;
end;

procedure TMainForm.CompSuccessProc;
begin
  case fCompSuccessAction of
    csaRun: begin
        fCompiler.Run;
      end;
    csaDebug: begin
        actDebug.Execute;
      end;
    csaProfile: begin
        actProfile.Execute
      end;
  end;
  fCompSuccessAction := csaNone;
end;

procedure TMainForm.RunEndProc;
begin
  case fRunEndAction of
    reaProfile: begin
        if not Assigned(ProfileAnalysisForm) then
          ProfileAnalysisForm := TProfileAnalysisForm.Create(Self);
        ProfileAnalysisForm.Show;
      end;
  end;
  fRunEndAction := reaNone;
end;

procedure TMainForm.LogEntryProc(const Msg: String);
var
  BackSlashMsg: String;
  Msg2: String;
//  MsgList: TStringList;   //split to lines
//  I: integer;
begin
  // Keep original, but use backslash everywhere
  BackSlashMsg := StringReplace(Msg, '/', '\', [rfReplaceAll]);
  BackSlashMsg := StringReplace(BackSlashMsg, #$A, #13#10, [rfReplaceAll]); //替换为换行符
  fLogOutputRawData.Add(BackSlashMsg);

//  MsgList := TStringList.Create;
//  ExtractStrings([#$A], [], PChar(Msg), MsgList);

  // Immediately add to UI component

  if devData.ShortenCompPaths then begin
    LogOutput.Lines.Add(BackSlashMsg) // ShortenLogOutput not available; BackSlashMsg has normalized slashes
  end
  else begin
    BackSlashMsg := StringReplace(Msg, #$A, #13#10, [rfReplaceAll]); //替换为换行符
    LogOutput.Lines.Add(BackSlashMsg);
  end;
//    begin
//    for I := 0 to MsgList.Count-1 do
//      LogOutput.Lines.Add(MsgList.Strings[I]);
//    end;
//    MsgList.Free;
end;

procedure TMainForm.ProjectViewContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
var
  pt: TPoint;
  Node: TTreeNode;
begin
  if not assigned(fProject) or devData.FullScreen then
    exit;

  pt := ProjectView.ClientToScreen(MousePos);
  Node := ProjectView.GetNodeAt(MousePos.X, MousePos.Y);
  if not assigned(Node) then
    exit;
  ProjectView.Selected := Node;

  // Is this the project node?
  if Node.Level = 0 then
    ProjectPopup.Popup(pt.x, pt.Y)

    // This is either a folder or a file
  else if Node.Data <> Pointer(-1) then begin
    BuildOpenWith;
    UnitPopup.Popup(pt.X, pt.Y);
  end else begin
    FolderPopup.Popup(pt.X, pt.Y);
  end;
  Handled := TRUE;
end;



procedure TMainForm.StatusbarDrawPanel(AStatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
  if Panel.Index = 1 then begin
    if AStatusBar.tag = 1 then begin
      AStatusBar.Canvas.Brush.Color := clLime;
      AStatusBar.Canvas.Font.Color := clBlack;
    end else if AStatusBar.tag = 2 then begin
      AStatusBar.Canvas.Brush.Color := clAqua; //clYellow;
      AStatusBar.Canvas.Font.Color := clBlack;
    end else if AStatusBar.tag = 3 then begin
      AStatusBar.Canvas.Brush.Color := clRed;
      AStatusBar.Canvas.Font.Color := clWhite;
    end else begin
      AStatusBar.Canvas.Brush.Color := clBtnFace;
      AStatusBar.Canvas.Font.Color := clBtnText;
    end;
    AStatusBar.tag := 0;
  end else begin
    AStatusBar.Canvas.Brush.Color := clBtnFace;
    AStatusBar.Canvas.Font.Color := clBtnText;
  end;

  AStatusBar.Canvas.FillRect(Rect);
  AStatusBar.Canvas.TextRect(Rect, Rect.Left + 2, Rect.Top, Panel.Text);
end;

procedure TMainForm.StatusbarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i, sumW: Integer;
begin
  if Button <> mbLeft then Exit;
  if not (ssDouble in Shift) then Exit;

  sumW := 0;
  for i := 0 to Statusbar.Panels.Count - 1 do begin
    Inc(sumW, Statusbar.Panels[i].Width);
    if X < sumW then begin
      if i in [2, 3] then
        actFileEncoding.Execute;
      Exit;
    end;
  end;
end;

procedure TMainForm.StatusbarResize(Sender: TObject);
begin
   Statusbar.Panels[1].Width := Statusbar.Width - Statusbar.Panels[0].Width
    - Statusbar.Panels[2].Width - Statusbar.Panels[3].Width - Statusbar.Panels[4].Width;
end;

procedure TMainForm.UpdateEncodingStatus;
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    Statusbar.Panels[2].Text := e.GetFileEncodingName
  else
    Statusbar.Panels[2].Text := '';
end;

procedure TMainForm.UpdateLineEndsStatus;
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    Statusbar.Panels[3].Text := e.GetFileLineEndsName
  else
    Statusbar.Panels[3].Text := '';
end;

procedure TMainForm.OpenUnit;
var
  Node: TTreeNode;
  i: integer;
  pt: TPoint;
  e: TEditor;
begin
  // Determine what node we have clicked on
  if Assigned(ProjectView.Selected) then
    Node := ProjectView.Selected
  else begin
    pt := ProjectView.ScreenToClient(Mouse.CursorPos);
    Node := ProjectView.GetNodeAt(pt.x, pt.y);
  end;

  // Open the file that belongs to said node
  if Assigned(Node) and (integer(Node.Data) <> -1) then begin

    // Do not accept the project node
    if (Node.Level >= 1) then begin
      i := integer(Node.Data);

      // Only open the file if it hasn't been opened yet
      e := fEditorList.FileIsOpen(fProject.Units[i].FileName, TRUE);
      if not Assigned(e) then
        e := fProject.OpenUnit(i);

      // Activate it
      if Assigned(e) then
        e.Activate;
    end;
  end;
end;

procedure TMainForm.ProjectViewClick(Sender: TObject);
var
  e: TEditor;
begin
  if not Assigned(ProjectView.Selected) then
    Exit;
  if ProjectView.Selected.Data <> Pointer(-1) then
    OpenUnit
  else begin
    e := fEditorList.GetEditor;
    if Assigned(e) then
      e.Activate;
  end;
end;

procedure TMainForm.actNewSourceExecute(Sender: TObject);
var
  NewEditor: TEditor;
begin
  if Assigned(fProject) then begin
    if MessageDlg(Lang[ID_MSG_NEWFILE], mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
      actProjectNewExecute(Sender);
      exit;
    end;
  end;

  NewEditor := fEditorList.NewEditor('', False, True);
  NewEditor.InsertDefaultText;
  NewEditor.Activate;
end;

procedure TMainForm.actNewFilesExecute(Sender: TObject);
//var
//  pt: TPoint;
begin
  //pt := tbProject.ClientToScreen(point(NewFileBtn.Left, NewFileBtn.Top + NewFileBtn.Height));
  //TrackPopupMenu(mnuNew.Handle, TPM_LEFTALIGN or TPM_LEFTBUTTON, pt.X, pt.y, 0, Self.Handle, nil);
end;

procedure TMainForm.actNewProjectExecute(Sender: TObject);
var
  s: String;
begin
  with TNewProjectForm.Create(nil) do try
    rbCpp.Checked := devData.DefCpp;
    rbC.Checked := not rbCpp.Checked;
    if ShowModal = mrOk then begin
      if cbDefault.Checked then
        devData.DefCpp := rbCpp.Checked;

      // Take care of the currently opened project
      if Assigned(fProject) then begin
        if fProject.Name = '' then
          s := fProject.FileName
        else
          s := fProject.Name;

        // Ask if the user wants to close the current one. If not, abort
        if MessageDlg(format(Lang[ID_MSG_CLOSECREATEPROJECT], [s]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
          actCloseProject.Execute
        else
          Exit;
      end;

      // Ask the user where he wants to save
      with TSaveDialog.Create(nil) do try
        Filter := FLT_PROJECTS;
        InitialDir := devDirs.Default;
        FileName := edProjectName.Text + DEV_EXT; // guess initial name
        Options := Options + [ofOverwritePrompt];
        DefaultExt := 'dev';

        // The user pressed the OK key. Save initial copy to disk
        if Execute then begin
          s := FileName;

          // Create an empty project
          fProject := TProject.Create(s, edProjectName.Text);

          // Assign the selected template to it
          if not fProject.AssignTemplate(s, GetTemplate) then begin
            FreeAndNil(fProject);
            Application.MessageBox(PChar(Lang[ID_ERR_TEMPLATE]), PChar(Lang[ID_ERROR]), MB_OK or
              MB_ICONERROR);
            Exit;
          end;

          // Save project preferences to disk. Don't force save all editors yet
          fProject.SaveOptions;
          // switch LeftPageControl to ProjectSheet and fullexpand it.
          LeftPageControl.ActivePage := LeftProjectSheet;
          ProjectView.FullExpand;
        end;
      finally
        Free;
      end;
    end;
  finally
    Free;
  end;
end;

procedure TMainForm.actNewTemplateExecute(Sender: TObject);
begin
  // change to save cur project as template maybe?
  with TNewTemplateForm.Create(Self) do begin
    TempProject := fProject;
    ShowModal;
  end;
end;

procedure TMainForm.actOpenExecute(Sender: TObject);
var
  e: TEditor;
begin
  with TOpenDialog.Create(Self) do try
    Filter := BuildFilter([FLT_PROJECTS, FLT_CS, FLT_CPPS, FLT_RES, FLT_HEADS, FLT_FORTRAN]);
    Title := Lang[ID_NV_OPENFILE];
    Options := Options + [ofAllowMultiSelect];

    // Open all provided files
    if Execute then begin
      if fEditorList.PageCount = 1 then begin //close the empty source file created on startup
        e := fEditorList.GetEditor;
        //if Assigned(e) and (not e.Text.Modified) and (e.Text.GetTextLen = 0) then
        //if Assigned(e) and (not e.Modified) and (e.Text.Strings.Count = 0) then
        if Assigned(e) and (not e.Modified) and (e.Text.Strings.Count = 1) and (trim(e.Text.Text) = '') then
              fEditorList.CloseEditor(e);
      end;
      OpenFileList(TStringList(Files));  // open files
    end;
  finally
    Free;
  end;
end;

procedure TMainForm.actHistoryClearExecute(Sender: TObject);
begin
  dmMain.ClearHistory;
end;

procedure TMainForm.actSaveExecute(Sender: TObject);
var
  e: TEditor;
//  i, n: integer;
  ext: string;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    if  (not FileExists(e.FileName)) then begin
      actSaveAsExecute(Sender);
    //end else if (e.Text.Modified) then begin
    end else if (e.Modified) then begin
      ext := LowerCase(ExtractFileExt(AnsiString(e.FileName)));
      if (devData.AutoFormat and (pos(ext,'.c.cpp.cxx.h.hpp.hxx') > 0)) then
        actFormatCurrentFileExecute(Sender); //automatically format current file
      e.Save;
    end;
  end;
  UpdateAppTitle;
end;

procedure TMainForm.actSaveAsExecute(Sender: TObject);
var
  e: TEditor;
  ext: string;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    if (e.SaveAs) and devData.AutoFormat then begin
      ext := LowerCase(ExtractFileExt(AnsiString(e.FileName)));
      if pos(ext,'.c.cpp.cxx.h.hpp.hxx') > 0 then

        actFormatCurrentFileExecute(Sender); //automatically format current file
        e.Save;
    end;
  end;
  UpdateAppTitle;
end;

procedure TMainForm.actSaveAllExecute(Sender: TObject);
var
  I: integer;
  e: TEditor;
begin
  // Pause the change notifier
  FileMonitor.BeginUpdate;
  try
    // Make changes to files
    if Assigned(fProject) then begin
      fProject.SaveAll;
      UpdateAppTitle;
      if CppParser.Statements.Count = 0 then // only scan entire project if it has not already been scanned...
        ScanActiveProject;
    end;

    // Make changes to files
    for I := 0 to pred(EditorList.PageCount) do begin
      e := fEditorList[I];
      //if e.Text.Modified and not e.InProject then
      if e.Modified and not e.InProject then
        if not e.Save then
          Break;
    end;
  finally
    FileMonitor.EndUpdate;
  end;
end;

procedure TMainForm.actCloseExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    actStopExecuteExecute(Sender);
    // Clear compile messages/log if they belong to the file being closed
    if SameText(fCompiler.SourceFile, e.FileName) then begin
      fCompiler.SourceFile := '';
      ClearCompileMessages;
    end;
    fFileMonitor.UnMonitor(AnsiString(e.FileName)); //
    fEditorList.CloseEditor(e);
    BrowserView.Items.Clear;
  end;
end;

procedure TMainForm.actCloseAllExecute(Sender: TObject);
begin
  //actCleanExecute(Sender);
  ClassBrowser.BeginUpdate;
  UpdateBrowserView;
  try
    fEditorList.CloseAll; // PageControlChange triggers other UI updates
  finally
    ClassBrowser.EndUpdate;
  end;
end;

procedure TMainForm.actCloseProjectExecute(Sender: TObject);
var
  s: String;
begin
  // Stop executing program
  actStopExecuteExecute(Self);

  // Only update file monitor once (and ignore updates)
  FileMonitor.BeginUpdate;
  try
    // TODO: should we save watches?
    if fProject.Modified then begin
      if fProject.Name = '' then
        s := fProject.FileName
      else
        s := fProject.Name;

      case MessageDlg(Format(Lang[ID_MSG_SAVEPROJECT], [s]), mtConfirmation, mbYesNoCancel, 0) of
        mrYes: begin
            fProject.SaveAll; // do NOT save layout twice
          end;
        mrNo: begin
            fProject.Modified := FALSE;
            fProject.SaveLayout;
          end;
        mrCancel: begin
            fProject.SaveLayout;
            Exit;
          end;
      end;
    end else
      fProject.SaveLayout; // always save layout, but not when SaveAll has been called

    if devData.DeleteExe and FileExists(ChangeFileExt(fProject.FileName, EXE_EXT)) then begin
      DeleteFile(ChangeFileExt(fProject.FileName, EXE_EXT)); //delete executable file
    end;

    // Remember it
    dmMain.AddtoHistory(fProject.FileName);

    // Only update class browser once
//    ClassBrowser.BeginUpdate;
    UpdateBrowserView;
    try
      // Only update page control once
      // Clear compile messages/log if they belong to the project being closed
      // (compare BEFORE FreeandNil, and reset fCompiler.Project so it does not
      // keep pointing at the freed object)
      if fCompiler.Project = fProject then begin
        ClearCompileMessages;
        fCompiler.Project := nil;
      end;
      fEditorList.BeginUpdate;
      try
        FreeandNil(fProject);
      finally
        fEditorList.EndUpdate;
      end;

      // Clear project browser
      ProjectView.Items.Clear;

      // Clear class browser
//      BrowserView.ProjectDir := '';
      CppParser.Reset;

      // Because fProject was assigned during editor closing, force update trigger again
      EditorPageControlLeft.OnChange(EditorPageControlLeft);
    finally
      //ClassBrowser.EndUpdate;
    end;
  finally
    FileMonitor.EndUpdate;
  end;
end;

procedure TMainForm.actExportHTMLExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if assigned(e) then
    e.ExportToHTML;
end;

procedure TMainForm.actExportRTFExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if assigned(e) then
    e.ExportToRTF;
end;

procedure TMainForm.actExportTexExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if assigned(e) then
    e.ExportToTEX;
end;

procedure TMainForm.actExportProjectExecute(Sender: TObject);
begin
  if assigned(fProject) then
    fProject.ExportToHTML;
end;

procedure TMainForm.actPrintExecute(Sender: TObject);
var
  e: TEditor;
  dlg: TPrintDialog;
  Lines: TStringList;
  i, Y, LineHeight, LineNumWidth, TextStartX: Integer;
  LeftMargin, TopMargin, RightEdge, BottomEdge: Integer;
  PageNum: Integer;
  LineStr, RemainingStr, FitStr: String;
  PrintLn, WrapLines, PrintSel: Boolean;
  FitLen: Integer;

begin
  e := fEditorList.GetEditor;
  if not Assigned(e) then
    Exit;

//  Application.MessageBox(PChar(Lang[ID_ENV_UACERROR]), PChar(Lang[ID_INFO]), MB_ICONINFORMATION or MB_OK);

  with TPrintForm.Create(Self) do try
    if ShowModal = mrOk then begin
      // Show system Print dialog to select printer
      dlg := TPrintDialog.Create(nil);
      try
        dlg.Copies := seCopies.Value;
        dlg.MinPage := 1;
        dlg.MaxPage := 1;
        dlg.FromPage := 1;
        dlg.ToPage := 1;
        if not dlg.Execute then Exit;
      finally
        dlg.Free;
      end;

      PrintLn := rbLN.Checked or rbLNMargin.Checked;
      WrapLines := cbWordWrap.Checked;
      PrintSel := cbSelection.Checked and (String(e.Text.TextSelected) <> '');

      // Build the list of lines to print
      Lines := TStringList.Create;
      try
        if PrintSel then
          Lines.Text := String(e.Text.TextSelected)
        else
          for i := 0 to e.Text.Strings.Count - 1 do
            Lines.Add(String(e.Text.Strings.Lines[i]));

        if Lines.Count = 0 then Exit;

        Printer.BeginDoc;
        try
          Printer.Title := AnsiString(ExtractFileName(e.FileName));

          // Use editor font, slightly smaller for printing (10pt)
          Printer.Canvas.Font.Name := devEditor.Font.Name;
          Printer.Canvas.Font.Size := 10;
          Printer.Canvas.Font.Color := clBlack;

          LineHeight := Printer.Canvas.TextHeight('Ag') + 2;

          // Margins: ~1 inch = 10% of page on each side
          LeftMargin := Round(Printer.PageWidth * 0.1);
          TopMargin := Round(Printer.PageHeight * 0.08);
          RightEdge := Printer.PageWidth - Round(Printer.PageWidth * 0.1);
          BottomEdge := Printer.PageHeight - Round(Printer.PageHeight * 0.08);

          // Line number column width
          if PrintLn then begin
            LineNumWidth := Printer.Canvas.TextWidth(
              IntToStr(Lines.Count)) + 40;
          end else
            LineNumWidth := 0;

          TextStartX := LeftMargin + LineNumWidth;
          PageNum := 1;
          Y := TopMargin;

          // Print header on first page
          Printer.Canvas.Font.Style := [fsBold];
          Printer.Canvas.TextOut(LeftMargin, Y,
            AnsiString(ExtractFileName(e.FileName)) + '  -  Page ' + IntToStr(PageNum));
          Printer.Canvas.Font.Style := [];
          Y := Y + LineHeight + 6;

          for i := 0 to Lines.Count - 1 do begin
            LineStr := Lines[i];

            // Page break
            if Y + LineHeight > BottomEdge then begin
              Printer.NewPage;
              Inc(PageNum);
              Y := TopMargin;
              // Header on new page
              Printer.Canvas.Font.Style := [fsBold];
              Printer.Canvas.TextOut(LeftMargin, Y,
                AnsiString(ExtractFileName(e.FileName)) + '  -  Page ' + IntToStr(PageNum));
              Printer.Canvas.Font.Style := [];
              Y := Y + LineHeight + 6;
            end;

            // Print line number
            if PrintLn then begin
              Printer.Canvas.TextOut(LeftMargin + LineNumWidth - Printer.Canvas.TextWidth(IntToStr(i + 1))-40, Y, IntToStr(i + 1));
            end;

            // Print text with optional word wrap
            if WrapLines then begin
              RemainingStr := LineStr;
              while Length(RemainingStr) > 0 do begin
                // Check for page break within wrapped lines
                if Y + LineHeight > BottomEdge then begin
                  Printer.NewPage;
                  Inc(PageNum);
                  Y := TopMargin;
                  Printer.Canvas.Font.Style := [fsBold];
                  Printer.Canvas.TextOut(LeftMargin, Y,
                    AnsiString(ExtractFileName(e.FileName)) + '  -  Page ' + IntToStr(PageNum));
                  Printer.Canvas.Font.Style := [];
                  Y := Y + LineHeight + 6;
                end;

                // Find how many chars fit in the remaining width
                FitLen := Length(RemainingStr);
                while (FitLen > 0) and
                  (Printer.Canvas.TextWidth(Copy(RemainingStr, 1, FitLen)) >
                   RightEdge - TextStartX) do
                  Dec(FitLen);

                if FitLen = 0 then
                  FitLen := 1; // at least one char to avoid infinite loop

                FitStr := Copy(RemainingStr, 1, FitLen);
                Printer.Canvas.TextOut(TextStartX, Y, FitStr);
                Delete(RemainingStr, 1, FitLen);

                if Length(RemainingStr) > 0 then
                  Y := Y + LineHeight;
              end;
            end else begin
              // No word wrap - just print, clip long lines
              Printer.Canvas.TextOut(TextStartX, Y, LineStr);
            end;

            Y := Y + LineHeight;
          end;

        finally
          Printer.EndDoc;
        end;
      finally
        Lines.Free;
      end;
    end;

    devData.PrintColors := cbColors.Checked;
    devData.PrintHighlight := cbHighlight.Checked;
    devData.PrintWordWrap := cbWordWrap.Checked;
    devData.PrintLineNumbers := rbLN.Checked;
    devData.PrintLineNumbersMargins := rbLNMargin.Checked;
  finally
    Close;
  end;
end;

procedure TMainForm.actPrintSUExecute(Sender: TObject);
var
  psd: TPAGESETUPDLG;
begin
  psd := default(TPAGESETUPDLG);
  FillChar(psd, SizeOf(psd), 0);
  psd.lStructSize := SizeOf(psd);
  psd.hwndOwner := Self.Handle;
  psd.Flags := PSD_MARGINS or PSD_INTHOUSANDTHSOFINCHES;
  PageSetupDlg(@psd);
end;

procedure TMainForm.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.actUndoExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    e.Text.DoCommand(cCommand_Undo, ATSynEdit.TATCommandInvoke(0), '');
end;

procedure TMainForm.actRedoExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    e.Text.DoCommand(cCommand_Redo, ATSynEdit.TATCommandInvoke(0), '');
end;

procedure TMainForm.actCutExecute(Sender: TObject);
var
  e: TEditor;
  oldbottomline: integer;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    // ATSynEdit: LineBottom replaces TopLine + LinesInWindow
    oldbottomline := e.Text.LineBottom;
    e.Text.DoCommand(cCommand_ClipboardCut, ATSynEdit.TATCommandInvoke(0), '');
    if e.Text.LineBottom <> oldbottomline then
      e.Text.Repaint; // fix for repaint fail
  end;
end;

procedure TMainForm.actCopyExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    e.Text.DoCommand(cCommand_ClipboardCopy, ATSynEdit.TATCommandInvoke(0), '');
end;

procedure TMainForm.actPasteExecute(Sender: TObject);
var
  e: TEditor;
  oldbottomline: integer;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    // ATSynEdit: LineBottom replaces TopLine + LinesInWindow
    oldbottomline := e.Text.LineBottom;
    e.Text.DoCommand(cCommand_ClipboardPaste, ATSynEdit.TATCommandInvoke(0), '');
    if e.Text.LineBottom <> oldbottomline then
      e.Text.Repaint; // fix for repaint fail
  end;
end;

procedure TMainForm.actSelectAllExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if assigned(e) then
    e.Text.DoCommand(cCommand_SelectAll, ATSynEdit.TATCommandInvoke(0), '');
end;

procedure TMainForm.actDeleteExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  // ATSynEdit: use DoSelect_None instead of ClearSelection
  if Assigned(e) then
    e.Text.DoCommand(cCommand_SelectNone, TATCommandInvoke(0), '');
end;

procedure TMainForm.actProjectManagerExecute(Sender: TObject);
begin
  // Hide/show this first, or otherwhise it'll show up to the left of ProjectToolWindow
  SplitterLeft.Visible := actProjectManager.Checked;
  if Assigned(fProjectToolWindow) then
    fProjectToolWindow.Close;
  LeftPageControl.Visible := actProjectManager.Checked;
  devData.ShowLeftPages := actProjectManager.Checked;
end;

procedure TMainForm.actToolBarExecute(Sender: TObject);
begin
  tbMain.Visible := ToolMainItem.Checked;
  ToolbarDock.Visible := ToolMainItem.Checked;
  devData.ToolbarMain := ToolMainItem.Checked;
end;



procedure TMainForm.ApplyBuiltInColorScheme(SchemeIndex: Integer);
begin
{  if (SchemeIndex < 0) or (SchemeIndex > High(BuiltInColorSchemes)) then Exit;

  // Write regular element colors into devEditor.ColorScheme
  for i := 0 to High(ColorElemNames) do
    devEditor.ColorScheme.Values[ColorElemNames[i]] := BuiltInColorSchemes[SchemeIndex][i];

  // Write special element colors
  for i := 0 to High(SpecialElemNames) do
    devEditor.ColorScheme.Values[SpecialElemNames[i]] := BuiltInColorSchemes[SchemeIndex][High(ColorElemNames) + 1 + i];
 }
  devEditor.SchemeIndex := SchemeIndex;
  devEditor.SetColorScheme(SchemeIndex);

  // Apply to all open editors. ApplyColorSchemeToAllEditors now lives in devCFG.pas,
  // so no scratch TEditorOptForm instance is needed any more.
  ApplyColorSchemeToAllEditors;
  SaveOptions;
  UpdateColorSchemeChecks;
end;

// Build the 14 Editor Color Scheme sub-menu items (called once from FormCreate).
// Items 0..BuiltinSchemes are built-in schemes, another item is "Custom".
procedure TMainForm.BuildColorSchemeMenu;
var
  i: Integer;
  Item: TMenuItem;
begin
  if not Assigned(ColorSchemeItem) then Exit;

  // Clear any stale children (e.g. from a re-run)
  ColorSchemeItem.Clear;

  // Create BuiltinSchemes menu items
  for i := 0 to (BuiltinSchemes - 1) do begin
    Item := TMenuItem.Create(ColorSchemeItem);
    Item.Caption := 'Built-in Scheme';  //Exact caption will be given in LoadText
    Item.Tag := i;  // store scheme index for lookup in OnClick
    Item.OnClick := @ColorSchemeItemClick;
    ColorSchemeItem.Add(Item);
  end;

  //Last Item: "Custom" – clicking it hints where a custom scheme can be defined
  Item := TMenuItem.Create(ColorSchemeItem);
  Item.Caption := 'Custom Scheme';
  Item.Tag := -1;
  Item.OnClick := @ColorSchemeItemClick;
  ColorSchemeItem.Add(Item);

  UpdateColorSchemeChecks;
end;

// OnClick handler shared by all 13 color scheme items.
// Tag >= 0: built-in scheme index -> apply it.
// Tag <  0: the "Custom" item   -> show a hint, do not change the scheme.
procedure TMainForm.ColorSchemeItemClick(Sender: TObject);
begin
  if not (Sender is TMenuItem) then Exit;
  if TMenuItem(Sender).Tag < 0 then begin
    // "Custom": user-defined schemes are created in Editor Options -> Colors tab
    MessageDlg(Lang[ID_ERR_CUSTOMCOLORSCHEME], mtInformation, [mbOK], 0);
    Exit;
  end;
  ApplyBuiltInColorScheme(TMenuItem(Sender).Tag);
end;

// Radio-style check marks for the Editor Color Scheme sub-menu.
procedure TMainForm.UpdateColorSchemeChecks;
var
  i, CustomIdx: Integer;
begin
  if not Assigned(ColorSchemeItem) then Exit;
  CustomIdx := ColorSchemeItem.Count - 1; // last item = user-defined ("Custom") scheme
  for i := 0 to ColorSchemeItem.Count - 1 do begin
    if ColorSchemeItem[i].Tag >= 0 then
      ColorSchemeItem[i].Checked := (devEditor.SchemeIndex = ColorSchemeItem[i].Tag)
    else
      ColorSchemeItem[i].Checked := False; // reset "Custom"; re-set below if it is active
  end;
  // SchemeIndex >= BuiltinSchemes means a user-defined scheme is active (the first
  // saved scheme gets index BuiltinSchemes), so the last ("Custom") item is checked.
  if devEditor.SchemeIndex >= BuiltinSchemes then
    ColorSchemeItem[CustomIdx].Checked := True;
end;


procedure TMainForm.actStatusbarExecute(Sender: TObject);
begin
  devData.Statusbar := actStatusbar.Checked;
  Statusbar.Visible := actStatusbar.Checked;
  Statusbar.Top := Self.ClientHeight;
end;

procedure TMainForm.actShowSpecialCharsExecute(Sender: TObject);
var
  i: integer;
  e: TEditor;
begin
  devEditor.ShowSpecialChars := not devEditor.ShowSpecialChars;
  actShowSpecialChars.Checked := devEditor.ShowSpecialChars;
  for i := 0 to fEditorList.PageCount - 1 do begin
    e := fEditorList[i];
    if Assigned(e) then begin
      e.Text.OptUnprintedVisible := actShowSpecialChars.Checked;  //Total Switch
      e.Text.OptUnprintedSpaces := actShowSpecialChars.Checked;  //Space, Tab
      e.Text.OptUnprintedEnds := actShowSpecialChars.Checked;    //EOL
      e.Text.OptUnprintedEof := actShowSpecialChars.Checked;     //EOF
      e.Text.OptUnprintedEndsDetails := False; //actShowSpecialChars.Checked;  //CRLF
      e.Text.Invalidate;
    end;
  end;
end;

// Applies the current devEditor.ShowRuler / devEditor.LineNumbers settings to
// every open editor and syncs the menu check marks. Called both by the two
// menu actions (after toggling) and by the editor-options dialog (after the
// user changed those options).
procedure TMainForm.UpdateShowRulerLineNumber;
var
  i, NBand: integer;
  e: TEditor;
begin
  actShowSpecialChars.Checked := devEditor.ShowSpecialChars;
  actShowTopRuler.Checked := devEditor.ShowTopRuler;
  actShowLineNumber.Checked := devEditor.LineNumbers;
  actWordWrap.Checked := devEditor.WordWrap;
  actShowMinimap.Checked := devEditor.ShowMinimap;
  actShowMacromap.Checked := devEditor.ShowMacromap;

  for i := 0 to fEditorList.PageCount - 1 do begin
    e := fEditorList[i];
    if Assigned(e) then begin

      e.Text.OptUnprintedVisible := actShowSpecialChars.Checked;  //Total Switch
       e.Text.OptUnprintedSpaces := actShowSpecialChars.Checked;  //Space, Tab
       e.Text.OptUnprintedEnds := actShowSpecialChars.Checked;    //EOL
       e.Text.OptUnprintedEof := actShowSpecialChars.Checked;     //EOF
       e.Text.OptUnprintedEndsDetails := False; //actShowSpecialChars.Checked;  //CRLF

      if actWordWrap.Checked then
        e.Text.OptWrapMode := TATEditorWrapMode.ModeOn
      else
        e.Text.OptWrapMode := TATEditorWrapMode.ModeOff;

      // Ruler: OptRulerVisible controls the top ruler band. Setting it to
      // False makes GetRectRuler return an empty rect, so the ruler is hidden
      // and the gutter shifts up to the top.
      e.Text.OptRulerVisible := devEditor.ShowTopRuler;
      // Line numbers: show/hide only the gutter "numbers" band. The other
      // bands (line states, folding) always stay visible. Setting the band's
      // Visible to False makes Gutter.Update() give it zero width, and
      // GetRectGutterNumbers() paints nothing for it.
      NBand := e.Text.Gutter.FindIndexByTag(ATEditorOptions.GutterTagNumbers);
      if NBand >= 0 then
        e.Text.Gutter[NBand].Visible := devEditor.LineNumbers;
      e.Text.OptMinimapVisible := actShowMinimap.Checked;
      e.Text.OptMicromapVisible := actShowMacromap.Checked;

      e.Text.Gutter.Update;
      e.Text.Invalidate;
    end;
  end;
end;

procedure TMainForm.actShowTopRulerExecute(Sender: TObject);
begin
  devEditor.ShowTopRuler := not devEditor.ShowTopRuler;
  UpdateShowRulerLineNumber;
end;

procedure TMainForm.actShowLineNumberExecute(Sender: TObject);
begin
  devEditor.LineNumbers := not devEditor.LineNumbers;
  UpdateShowRulerLineNumber;
end;

procedure TMainForm.actShowMinimapExecute(Sender: TObject);
begin
  devEditor.ShowMinimap := not devEditor.ShowMinimap;
  UpdateShowRulerLineNumber;
end;

procedure TMainForm.actShowMacromapExecute(Sender: TObject);
var
  i: integer;
  e: TEditor;
begin
  devEditor.ShowMacromap := not devEditor.ShowMacromap;
  UpdateShowRulerLineNumber;
end;

procedure TMainForm.actWordWrapExecute(Sender: TObject);

begin
  devEditor.WordWrap := not devEditor.WordWrap;
  UpdateShowRulerLineNumber;
end;

procedure TMainForm.actScrollUpExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    e.Text.DoCommand(cCommand_ScrollLineUp, TATCommandInvoke(0), '');
end;

procedure TMainForm.actScrollDownExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    e.Text.DoCommand(cCommand_ScrollLineDown, TATCommandInvoke(0), '');
end;

procedure TMainForm.btnFullScrRevertClick(Sender: TObject);
begin
  actFullScreen.Execute;
end;

procedure TMainForm.actFullScreenExecute(Sender: TObject);
var
  ActiveCtrl: TWinControl;
begin
  // Remember focus
  ActiveCtrl := Screen.ActiveControl;

  devData.FullScreen := FullScreenModeItem.Checked;
  if devData.FullScreen then begin

    // Remember old window position
    WindowPlacement.length := sizeof(WINDOWPLACEMENT);
    GetWindowPlacement(Self.Handle, @WindowPlacement);

    // Hide stuff the user has hidden
    BorderStyle := bsNone;
    FullScreenModeItem.Caption := Lang[ID_ITEM_FULLSCRBACK];
    //FileMenu.Visible := devData.ShowMenu;
    ToolbarDock.Visible := devData.ShowBars;

    // set size to hide form menu
    // works with multi monitors now.
    SetBounds(
      (Left + Monitor.WorkAreaRect.Left) - ClientOrigin.X,
      (Top + Monitor.WorkAreaRect.Top) - ClientOrigin.Y,
      Monitor.Width + (Width - ClientWidth),
      Monitor.Height + (Height - ClientHeight));

    // Put hint in status bar
    SetStatusbarMessage(Format(Lang[ID_FULLSCREEN_MSGNEW], [ShortCutToText(actFullScreen.ShortCut),
      ShortCutToText(actShowBars.ShortCut)]));
  end else begin

    // Reset old window position
    WindowPlacement.length := sizeof(WINDOWPLACEMENT);
    SetWindowPlacement(Self.Handle, @WindowPlacement);

    // Reset borders etc
    BorderStyle := bsSizeable;
    FullScreenModeItem.Caption := Lang[ID_ITEM_FULLSCRMODE];
    ToolbarDock.Visible := TRUE;
  end;

  // Remember focus
  if ActiveCtrl.CanFocus then
    ActiveCtrl.SetFocus;
end;

procedure TMainForm.actNextWindowExecute(Sender: TObject);
begin
  EditorList.SelectNextPage;
end;

procedure TMainForm.actPrevWindowExecute(Sender: TObject);
begin
  EditorList.SelectPrevPage;
end;

procedure TMainForm.actCompOptionsExecute(Sender: TObject);
begin
  with TCompilerOptForm.Create(nil) do try
    if ShowModal = mrOk then begin
      CheckForDLLProfiling;
      UpdateCompilerList;
    end;
  finally
    Free;
  end;
end;

procedure TMainForm.actEditorOptionsExecute(Sender: TObject);
var
  I: integer;
  e1, e2: TEditor;
  s: string;
begin
  //translate code snippets to inner macros.
  TransMenuMacros(4, false); //"4" means only deal with code snippets.
  with TEditorOptForm.Create(nil) do try
    if ShowModal = mrOk then begin
      // Apply editor options
      //dmMain.UpdateHighlighter;
      actShowSpecialChars.Checked := devEditor.ShowSpecialChars;
      for I := 0 to EditorList.PageCount - 1 do begin
        e1 := EditorList.Editors[i];
        if Assigned(e1) then begin
          devEditor.AssignEditor(e1.Text, AnsiString(e1.FileName));
          e1.InitCompletion;
        end;
      end;

      ReLoadColor;
      // Repaint current editor to show new colors
      fEditorList.GetVisibleEditors(e1, e2);
      if Assigned(e1) then
        e1.Text.Repaint;
      if Assigned(e2) then
        e2.Text.Repaint;

      // Only do a lengthy reparse if completion options have changed
      if taCompletion in AccessedTabs then begin
        UpdateClassBrowsing;
        ScanActiveProject;
      end;
    end;
    //translation code snippets to UI current lanugage.
    TransMenuMacros(4, true); //"4" means only deal with code snippets.
    UpdateColorSchemeChecks;
  finally
    Free;
  end;
end;

procedure TMainForm.actConfigToolsExecute(Sender: TObject);
//var
//  idx: integer;
//  s: string;
begin
  fTools.Edit;    //

  //translate custom tools to inner macros.
  TransMenuMacros(2, true); //"2" means only deal with custom tools

end;


procedure TMainForm.actFileExplorerExecute(Sender: TObject);
var
  Exec, Params, WorkDir: String;
begin
  Exec := '<WINDIR>\explorer.exe';
  Params := '/select, <PROJECTFILE>';
  WorkDir := '<PROJECTPATH>';
  ExecuteFile(ParseToolParams(Exec), ParseToolParams(Params), ParseToolParams(WorkDir), SW_SHOW);
end;

procedure TMainForm.actConsoleOpenExecute(Sender: TObject);
var
  Exec, Params, WorkDir: String;
begin
  Exec := '<WINDIR>\system32\cmd.exe';
  Params := '';
  WorkDir := '<PROJECTPATH>';
  ExecuteFile(ParseToolParams(Exec), ParseToolParams(Params), ParseToolParams(WorkDir), SW_SHOW);
end;

procedure TMainForm.actConsoleLargeExecute(Sender: TObject);
var
  Exec, Params, WorkDir: String;
begin
  Exec := '<EXECPATH>Tools\ConsoleLarge.cmd';
  Params := '';
  WorkDir := '<EXECPATH>Tools\';
  ExecuteFile(ParseToolParams(Exec), ParseToolParams(Params), ParseToolParams(WorkDir), SW_SHOW);
end;

procedure TMainForm.actConsoleDefaultExecute(Sender: TObject);
var
  Exec, Params, WorkDir: String;
begin
  Exec := '<EXECPATH>Tools\ConsoleDefault.cmd';
  Params := '';
  WorkDir := '<EXECPATH>Tools\';
  ExecuteFile(ParseToolParams(Exec), ParseToolParams(Params), ParseToolParams(WorkDir), SW_SHOW);
end;

procedure TMainForm.actCodeDiffExecute(Sender: TObject);
var
  Exec, Params, WorkDir: String;
  i: integer = 0;
  e: TEditor;
begin
  Exec := '<EXECPATH>Tools\CodeDiff.exe';
  Params := '';
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    e.Save;
    Params := '"'+AnsiString(e.FileName)+'"';
    if fEditorList.PageCount > 1 then begin
      for i := 0 to pred(fEditorList.PageCount) do begin
        if EditorList[i].FileName = e.FileName then
          break;
      end;
      if i < pred(fEditorList.PageCount) then begin
        fEditorList[i+1].Save;
        Params := Params + ' "' + AnsiString(fEditorList[i+1].FileName) + '"'
      end else if i > 0 then begin
        fEditorList[i-1].Save;
        Params := '"' + AnsiString(fEditorList[i-1].FileName) + '" ' +  Params;
      end;
    end;
  end;

  WorkDir := '<EXECPATH>Tools\';
  ExecuteFile(ParseToolParams(Exec), ParseToolParams(Params), ParseToolParams(WorkDir), SW_SHOW);
end;

procedure TMainForm.actUnitRemoveExecute(Sender: TObject);
var
  idx: integer;
  node: TTreeNode;
begin
  if not assigned(fProject) then
    exit;
  while ProjectView.SelectionCount > 0 do begin
    node := ProjectView.Selections[0];
    if not assigned(node) or (node.Level < 1) then
      Continue;
    if node.Data = Pointer(-1) then
      Continue;

    idx := integer(node.Data);

    if not fProject.RemoveEditor(idx, true) then
      exit;
  end;
end;

procedure TMainForm.actUnitRenameExecute(Sender: TObject);
var
  I, ProjIndex: integer;
  OldName, NewName, CurDir: String;
  e: TEditor;
begin
  if not assigned(fProject) then
    exit;
  if not assigned(ProjectView.Selected) or
    (ProjectView.Selected.Level < 1) then
    exit;

  if ProjectView.Selected.Data = Pointer(-1) then
    Exit;

  // Get the original name
  I := integer(ProjectView.Selected.Data);
  OldName := fProject.Units[I].FileName;
  NewName := ExtractFileName(OldName);
  CurDir := ExtractFilePath(OldName);

  // Do we want to rename?
  if InputQuery(Lang[ID_RENAME], Lang[ID_MSG_FILERENAME], NewName) and (ExtractFileName(NewName) <> '') then begin

    NewName := ExpandFileto(NewName, CurDir);

    // Only continue if the user says so...
    if FileExists(NewName) and not SameFileName(OldName, NewName) then
      begin // don't remove when changing case for example
      if MessageDlg(Lang[ID_MSG_FILEEXISTS], mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin

        // Close the target file...
        e := fEditorList.FileIsOpen(NewName);
        if Assigned(e) then
          fEditorList.CloseEditor(e);

        // Remove it from the current project...
        projindex := fProject.Units.IndexOf(NewName);
        if projindex <> -1 then
          fProject.RemoveEditor(projindex, false);

        // All references to the file are removed. Delete the file from disk
        DeleteFile(NewName);

        // User didn't want to overwrite
      end else
        Exit;
    end;

    // Target filename does not exist anymore. Do a rename
    try
      // change name in project file first (no actual file renaming on disk)
      fProject.SaveUnitAs(I, NewName);

      // remove old file from monitor list
      FileMonitor.UnMonitor(OldName);

      // Finally, we can rename without issues
      RenameFile(OldName, NewName);

      // Add new filename to file monitor
      FileMonitor.Monitor(NewName);
    except
      MessageDlg(Format(Lang[ID_ERR_RENAMEFILE], [OldName]), mtError, [mbok], 0);
    end;
  end;
end;

procedure TMainForm.actUnitOpenExecute(Sender: TObject);
var
  I: integer;
  e: TEditor;
begin
  if not Assigned(fProject) then
    Exit;
  if not Assigned(ProjectView.Selected) or (ProjectView.Selected.Level < 1) then
    Exit;
  if ProjectView.Selected.Data = Pointer(-1) then
    Exit;

  I := integer(ProjectView.Selected.Data);
  e := fEditorList.FileIsOpen(fProject.Units[I].FileName, TRUE);
  if Assigned(e) then
    e.Activate
  else
    fProject.OpenUnit(I);
end;

procedure TMainForm.actUnitCloseExecute(Sender: TObject);
var
  e: TEditor;
begin
  if Assigned(fProject) and Assigned(ProjectView.Selected) then begin
    e := fEditorList.FileIsOpen(fProject.Units[integer(ProjectView.Selected.Data)].FileName, TRUE);
    if Assigned(e) then
      fEditorList.CloseEditor(e);
  end;
end;

procedure TMainForm.actHelpAboutExecute(Sender: TObject);
begin
  with TAboutForm.Create(Self) do begin
    ShowModal;
  end;
end;

procedure TMainForm.actProjectNewExecute(Sender: TObject);
var
  idx: integer;
  FolderNode: TTreeNode;
begin
  idx := -1;
  if Assigned(fProject) then begin
    if Assigned(ProjectView.Selected) and (ProjectView.Selected.Data = Pointer(-1)) then
      FolderNode := ProjectView.Selected
    else
      FolderNode := fProject.Node;
    idx := fProject.NewUnit(FALSE, FolderNode);
  end;
  if idx <> -1 then
    with fProject.OpenUnit(idx) do begin
      Activate;
      Text.Modified := True;
      Modified := True;
    end;
end;

procedure TMainForm.actProjectAddExecute(Sender: TObject);
var
  idx: integer;
  FolderNode: TTreeNode;
begin
  if not Assigned(fProject) then
    Exit;

  // Let the user point to a file
  with TOpenDialog.Create(nil) do try
    Title := Lang[ID_NV_OPENADD];
    Filter := BuildFilter([FLT_CS, FLT_CPPS, FLT_RES, FLT_HEADS]);
    Options := Options + [ofAllowMultiSelect];

    // If sucessful, add to selected node
    if Execute then begin
      if Assigned(ProjectView.Selected) and (ProjectView.Selected.Data = Pointer(-1)) then
        FolderNode := ProjectView.Selected
      else
        FolderNode := fProject.Node;

      // Add all files
      for idx := 0 to Files.Count - 1 do begin
        fProject.AddUnit(Files[idx], FolderNode, false); // add under folder
        CppParser.AddFileToScan(Files[idx], true);
      end;

      // Rebuild project tree and parse
      fProject.RebuildNodes;
      CppParser.ParseFileList;
    end;
  finally
    Free;
  end;
end;

{ end XXXKF changed }

procedure TMainForm.actProjectRemoveExecute(Sender: TObject);
var
  I: integer;
begin
  with TRemoveUnitForm.Create(MainForm) do begin

    // Add list of project files
    for i := 0 to fProject.Units.Count - 1 do
      UnitList.Items.Add(fProject.Units[i].FileName);

    ShowModal;
  end;
end;

procedure TMainForm.actProjectOptionsExecute(Sender: TObject);
begin
  if Assigned(fProject) then begin
    if fProject.ShowOptions = mrOk then begin
      UpdateAppTitle;
      UpdateCompilerList;
    end;
  end;
end;

procedure TMainForm.actProjectSourceExecute(Sender: TObject);
begin
  if assigned(fProject) then
    OpenFile(fProject.FileName);
end;

procedure TMainForm.actFindExecute(Sender: TObject);
var
  e: TEditor;
  s: String;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then begin

    // Create it when needed!
    if not Assigned(FindForm) then
      FindForm := TFindForm.Create(Self);

    s := String(e.Text.TextSelected); // ATSynEdit: use TextSelected instead of SelText
    if s = '' then
      s := String(e.Text.TextCurrentWord); // ATSynEdit: use TextCurrentWord instead of WordAtCursor

    FindForm.TabIndex := 0;
    FindForm.cboFindText.Text := s;
    FindForm.Show;
  end;
end;

procedure TMainForm.actFixHighDPIExecute(Sender: TObject);
{$IFDEF MSWINDOWS}
var
  lReg: TRegistry;
begin
  // open registry, set root and key
  lReg := TRegistry.Create;
  try
    lReg.RootKey := HKEY_CURRENT_USER;
    lReg.OpenKey('\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers', True);
    // write last Left, Top, Width and Height
    lReg.WriteString(Application.ExeName, '~ HIGHDPIAWARE');
    lReg.CloseKey;
  finally
    lReg.Free;
  end;
  Application.MessageBox(PChar(Lang[ID_MSG_HIGHDPIFIXED]), 'Dev-C++', MB_ICONINFORMATION);
{$ELSE}
begin
  // High DPI fix is Windows-specific; no-op on Linux
  Application.MessageBox(
    PChar('This feature is only available on Windows.' + LineEnding + LineEnding +
          'On Linux, Dev-C++ respects your desktop environment''s HiDPI settings.'),
    PChar('Dev-C++'), MB_ICONINFORMATION);
{$ENDIF}
end;

procedure TMainForm.actFindAllExecute(Sender: TObject);
var
  e: TEditor;
  s: String;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then begin

    // Create it when needed!
    if not Assigned(FindForm) then
      FindForm := TFindForm.Create(Self);

    s := '';
//    s := e.Text.SelText; // TODO: ATSynEdit - SelText
    if s = '' then
//      s := e.Text.WordAtCursor; // TODO: ATSynEdit

    FindForm.TabIndex := 1;
    FindForm.cboFindText.Text := s;
    FindForm.Show;
  end;
end;

procedure TMainForm.actReplaceExecute(Sender: TObject);
var
  e: TEditor;
  s: String;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then begin

    // Create it when needed!
    if not Assigned(FindForm) then
      FindForm := TFindForm.Create(Self);

    s := String(e.Text.TextSelected); // ATSynEdit: use TextSelected instead of SelText
    if s = '' then
      s := String(e.Text.TextCurrentWord); // ATSynEdit: use TextCurrentWord instead of WordAtCursor

    FindForm.TabIndex := 2;
    FindForm.cboFindText.Text := s;
    FindForm.Show;
  end;
end;

procedure TMainForm.actReplaceAllExecute(Sender: TObject);
var
  e: TEditor;
  s: String;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then begin

    // Create it when needed!
    if not Assigned(FindForm) then
      FindForm := TFindForm.Create(Self);

    s := String(e.Text.TextSelected); // ATSynEdit: use TextSelected instead of SelText
    if s = '' then
      s := String(e.Text.TextCurrentWord); // ATSynEdit: use TextCurrentWord instead of WordAtCursor

    FindForm.TabIndex := 3;
    FindForm.cboFindText.Text := s;
    FindForm.Show;
  end;
end;

procedure TMainForm.actGotoLineExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    e.GotoLine;
end;

procedure TMainForm.actNextBookmarkExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
	  e.GotoNextBookmark;
end;

function TMainForm.GetCompileTarget: TTarget;
var
  e: TEditor;
begin
  // Check if the current file belongs to a project
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    // Treat makefiles as InProject files too
    if Assigned(fProject) and (e.InProject or (fProject.MakeFileName = AnsiString(e.FileName))) then begin
      Result := ctProject;
    end else begin
      Result := ctFile;
    end;

    // No editors have been opened. Check if a project is open
  end else if Assigned(fProject) then begin
    Result := ctProject;

    // No project, no editor...
  end else begin
    Result := ctNone;
  end;
end;



function TMainForm.PrepareForRun(ForcedCompileTarget: TTarget = ctInvalid): Boolean;
begin
  Result := False;

  // Determine what to run
  fCompiler.Project := nil;
  fCompiler.SourceFile := '';
  fCompiler.CompilerSet := devCompilerSets.CompilationSet;
  if ForcedCompileTarget <> ctInvalid then
    fCompiler.Target := ForcedCompileTarget
  else
    fCompiler.Target := GetCompileTarget;
  case fCompiler.Target of
    ctInvalid:
      Exit;
    ctNone:
      Exit;
    ctFile: begin
        fCompiler.SourceFile := AnsiString(fEditorList.GetEditor.FileName);
      end;
    ctProject: begin
        fCompiler.Project := fProject;
      end;
  end;

  Result := True;
end;

function TMainForm.PrepareForCompile(ForcedCompileTarget: TTarget = ctInvalid): Boolean;
var
  i: Integer;
  e: TEditor;
begin
  Result := False;

  ClearCompileMessages;

  // always show compilation log (no intrusive windows anymore)
  if devData.ShowProgress then begin
    OpenCloseMessageSheet(True);
    MessageControl.ActivePage := LogSheet;
  end else
    OpenCloseMessageSheet(False);


  // Set PATH variable (not overriden by SetCurrentDir)
  if Assigned(devCompilerSets.CompilationSet) then begin // should NOT be false
    if devCompilerSets.CompilationSet.BinDir.Count > 0 then begin
      SetPath(devCompilerSets.CompilationSet.BinDir[0], TRUE);
      for i := 1 to devCompilerSets.CompilationSet.BinDir.Count - 1 do
        SetPath(devCompilerSets.CompilationSet.BinDir[i], FALSE);
      end
    else begin
      LogEntryProc(Format(Lang[ID_LOG_NOBINDIRABORT], [devCompilerSets.CompilationSet.Name]));
      Exit; // returns false
    end;
  end;

  // Determine what to compile
  fCompiler.Project := nil;
  fCompiler.SourceFile := '';
  fCompiler.CompilerSet := devCompilerSets.CompilationSet;
  if ForcedCompileTarget <> ctInvalid then
    fCompiler.Target := ForcedCompileTarget
  else
    fCompiler.Target := GetCompileTarget;
  case fCompiler.Target of
    ctInvalid: begin
        Exit;
      end;
    ctNone: begin
        LogEntryProc(Lang[ID_LOG_NOTHINGABORT]);
        Exit;
      end;
    ctFile: begin
        e := fEditorList.GetEditor; // always succeeds if ctFile is returned
        actSaveExecute(Self); //save file, and automaticlly format.
        if not e.Save then
          Exit;
        fCompiler.SourceFile := AnsiString(e.FileName);
      end;
    ctProject: begin
        fCompiler.Project := fProject;

        // Save all files that are in a project
        if not fProject.SaveUnits then
          Exit;
        UpdateAppTitle;
        if CppParser.Statements.Count = 0 then // only scan entire project if it has not already been scanned...
          ScanActiveProject;

        // Check if saves have been succesful
        for i := 0 to EditorList.PageCount - 1 do begin // check if saving failed
          e := fEditorList.Editors[i];
          //if e.InProject and e.Text.Modified then
          if e.InProject and e.Modified then
            Exit;
        end;

        // Increment build number automagically
        if fProject.Options.VersionInfo.AutoIncBuildNr then
          fProject.IncrementBuildNumber;
        fProject.BuildPrivateResource;
      end;
  end;

  Result := True;
end;

function TMainForm.PrepareForClean(ForcedCompileTarget: TTarget = ctInvalid): Boolean;
var
  i: Integer;
  e: TEditor;
begin
  Result := False;

  ClearCompileMessages;

  // always show compilation log (no intrusive windows anymore)
  if devData.ShowProgress then begin
    OpenCloseMessageSheet(True);
    MessageControl.ActivePage := LogSheet;
  end;

  // Set PATH variable (not overriden by SetCurrentDir)
  if Assigned(devCompilerSets.CompilationSet) then begin // should NOT be false
    if devCompilerSets.CompilationSet.BinDir.Count > 0 then begin
      SetPath(devCompilerSets.CompilationSet.BinDir[0], TRUE);
      for i := 1 to devCompilerSets.CompilationSet.BinDir.Count - 1 do
        SetPath(devCompilerSets.CompilationSet.BinDir[i], FALSE);
      end
    else begin
      LogEntryProc(Format(Lang[ID_LOG_NOBINDIRABORT], [devCompilerSets.CompilationSet.Name]));
      Exit; // returns false
    end;
  end;

  // Determine what to compile
  fCompiler.Project := nil;
  fCompiler.SourceFile := '';
  fCompiler.CompilerSet := devCompilerSets.CompilationSet;
  if ForcedCompileTarget <> ctInvalid then
    fCompiler.Target := ForcedCompileTarget
  else
    fCompiler.Target := GetCompileTarget;
  case fCompiler.Target of
    ctInvalid: begin
        Exit;
      end;
    ctNone: begin
        LogEntryProc(Lang[ID_LOG_NOTHINGABORT]);
        Exit;
      end;
    ctFile: begin
        e := fEditorList.GetEditor; // always succeeds if ctFile is returned
        fCompiler.SourceFile := AnsiString(e.FileName);
      end;
    ctProject: begin
        fCompiler.Project := fProject;
      end;
  end;

  Result := True;
end;

procedure TMainForm.actCompileExecute(Sender: TObject);
var
  i, n, posi: integer;
  e: TEditor;
  line, param: String;
begin
  actStopExecuteExecute(nil);
  if fCompiler.Compiling then begin
    MessageDlg(Lang[ID_MSG_ALREADYCOMP], mtInformation, [mbOK], 0);
    Exit;
  end;
  if not PrepareForCompile then
    Exit;
  //screen.Cursor := crhourglass; //crAppStart;

  //check preprocess "#pragma comment()"
  fCompiler.PragmaCompileParams := '';
  fCompiler.PragmaLinkerParams := '';
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    n := e.Text.Strings.Count;
    if n > 50 then
      n := 50;
    for i := 0 to n-1 do begin
      //if fCompiler.CompilerSet.AutoLink and (pos('#include', e.Text.Lines[i])> 0) then begin      //#include
      //  line := Copy(e.Text.Lines[i], 1, length(e.Text.Lines[i]));
      //  line := LowerCase(stringreplace(line, ' ', '', [rfReplaceAll]));
      //  for k := 0 to ((fAutoLinkList.Count div 2)-1) do begin
      //    if (pos('#include', line) = 1) and (pos(fAutoLinkList[2*k], line) >0)  then
      //      fCompiler.PragmaLinkerParams := fCompiler.PragmaLinkerParams + ' '  + fAutoLinkList[2*k+1];
      //  end;
      //end;
      if (pos('#pragma', e.Text.Strings.Lines[i])> 0) and (pos('comment', e.Text.Strings.Lines[i])> 0) then begin  //#pragma comment
        line := AnsiString(Copy(e.Text.Strings.Lines[i], 1, length(e.Text.Strings.Lines[i])));
        //example: #pragma comment(lib, "libgraphics64.lib libuuid.lib libmsimg32.lib libgdi32.lib")
        posi := Pos('"', line);
        param := Copy(line, posi+1, Length(line)-posi);
        posi := Pos('"', param);
        param := LeftStr(param, posi-1);
        //example: libgraphics64.lib libuuid.lib libmsimg32.lib libgdi32.lib

        line := LowerCase(stringreplace(line, ' ', '', [rfReplaceAll]));
        if Pos('#pragmacomment(compiler,', line) = 1 then  begin
          fCompiler.PragmaCompileParams := fCompiler.PragmaCompileParams + ' ' + param;
        end;
        if Pos('#pragmacomment(lib,', line) = 1 then  begin
          //example: libraylib libopengl32 libgdi32 libwinmm
          param := ' ' + param; //add space at beginning
          param := stringreplace(param, '.lib', '', [rfReplaceAll]);
          param := stringreplace(param, ' lib', ' -l', [rfReplaceAll]);
          //example: -lraylib -lopengl32 -lgdi32 -lwinmm
//          if (devCompilerSets.CompilationSet.GetOption('-') = '1') then   //0 or a: 64-bit; 1: 32-bit;
//            param := stringreplace(param, '64', '', [rfReplaceAll]);
          fCompiler.PragmaLinkerParams := fCompiler.PragmaLinkerParams + ' ' + param;
          //ShowMessage(param);
        end;
        if Pos('#pragmacomment(linker,', line) = 1 then  begin
           fCompiler.PragmaLinkerParams := fCompiler.PragmaLinkerParams + ' ' + param;
        end;
      end;
    end;
    if (devCompilerSets.CompilationSet.GetOption('-') = '1') then   //0 or 1: 64-bit; 1: 32-bit;
        fCompiler.PragmaLinkerParams := stringreplace(fCompiler.PragmaLinkerParams, '64', '', [rfReplaceAll]); //eg: graphics64
  end;

  fCompiler.Compile;
  //fCompiler.Run;

end;

procedure TMainForm.actRunExecute(Sender: TObject);
begin
  actStopExecuteExecute(nil);
  if fCompiler.Compiling then begin
    MessageDlg(Lang[ID_MSG_ALREADYCOMP], mtInformation, [mbOK], 0);
    Exit;
  end;
  if not PrepareForRun then
    Exit;
  fCompiler.Run;
end;

procedure TMainForm.actCompRunExecute(Sender: TObject);
begin
  actStopExecuteExecute(nil);
  if fCompiler.Compiling then begin
    MessageDlg(Lang[ID_MSG_ALREADYCOMP], mtInformation, [mbOK], 0);
    Exit;
  end;
  if not PrepareForCompile then
    Exit;

  fCompSuccessAction := csaRun;
  actSaveExecute(Sender);
  fCompiler.Compile;
end;

procedure TMainForm.actRebuildExecute(Sender: TObject);
begin
  actStopExecuteExecute(nil);
  if fCompiler.Compiling then begin
    MessageDlg(Lang[ID_MSG_ALREADYCOMP], mtInformation, [mbOK], 0);
    Exit;
  end;
  if not PrepareForCompile then
    Exit;
  fCompiler.RebuildAll;
end;

procedure TMainForm.actCleanExecute(Sender: TObject);
begin
  actStopExecuteExecute(nil);
  if fCompiler.Compiling then begin
    MessageDlg(Lang[ID_MSG_ALREADYCOMP], mtInformation, [mbOK], 0);
    Exit;
  end;
  if not PrepareForClean then
    Exit;
  fCompiler.Clean;
end;

procedure TMainForm.PrepareDebugger;
begin
  fDebugger.Stop;

  // Clear logs
  DebugOutput.Clear;
  EvalOutput.Clear;

  // Restore when no watch vars are shown
  fDebugger.LeftPageIndexBackup := MainForm.LeftPageControl.ActivePageIndex;

  // Focus on the debugging buttons
  LeftPageControl.ActivePage := LeftDebugSheet;
  MessageControl.ActivePage := DebugSheet;
  OpenCloseMessageSheet(True);

  // Reset watch vars
  fDebugger.DeleteWatchVars(false);
end;

procedure TMainForm.actDebugExecute(Sender: TObject);
var
  e: TEditor;
  i: integer;
  filepath: String = '';
  DebugEnabled, StripEnabled: boolean;
  OptDebug, OptOptimize, OptStrip: char;
begin

  if fDebugger.Executing then begin  //running debug
    fDebugger.SendCommand('continue', '', true);
    Exit;
  end;

  // if not running debug, then start debugging.
  case GetCompileTarget of  // is target project or file?

    ctProject: begin      //project

        // Check if we enabled proper options
      //DebugEnabled := fProject.GetCompilerOption('-g3') <> '0';
      //Optimize := fProject.GetCompilerOption('-O');
      //StripEnabled := fProject.GetCompilerOption('-s') <> '0';
      OptDebug := fProject.GetCompilerOption('-g3');
      OptOptimize := fProject.GetCompilerOption('-O');
      OptStrip := fProject.GetCompilerOption('-s');

        // Ask the user if he wants to enable debugging...
      //if (not DebugEnabled or StripEnabled) and (MessageDlg(Lang[ID_MSG_NODEBUGSYMBOLS],
      //  mtConfirmation, [mbYes, mbNo], 0) = mrYes) then begin
      //if (not DebugEnabled or StripEnabled) then begin
      if (fProject.LastCompileParams <> '-g3 -O0') then begin
        // Enable debugging, disable stripping
        fProject.SetCompilerOption('-g3', '1');
        fProject.SetCompilerOption('-O', '0'); //'e');
        fProject.SetCompilerOption('-s', '0');
        fProject.LastCompileParams := '-g3 -O0';
        fCompSuccessAction := csaDebug;
        actRebuildExecute(nil);
        //restore options
        fProject.SetCompilerOption('-g3', OptDebug);
        fProject.SetCompilerOption('O', OptOptimize);
        fProject.SetCompilerOption('-s', OptStrip);
        Exit;
      end;
{
        if Pos('-g3', fCompiler.LastCompileParams) <= 0 then begin
          if Pos('-Og', fCompiler.LastCompileParams) <> 0 then
            //only add '-g3' if there is '-Og' in LastCompileParams
            fCompiler.DebugCompileParams:= '-g3'
          else  //add '-g3' and '-O0'
            fCompiler.DebugCompileParams:= '-g3 -O0';  //'-Og'
          fCompiler.DebugLinkerParams := '-g3';
        end;
        if (devCompilerSets.CompilationSet.GetOption('-s') <> '0' ) then begin
           devCompilerSets.CompilationSet.SetOption('-s', '0');
        end;
}

        // Did we compile?
        if not FileExists(fProject.Executable) then begin
          //if MessageDlg(Lang[ID_ERR_PROJECTNOTCOMPILEDSUGGEST], mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
            actCompileExecute(nil);
          //end;
          exit;
        end;

        // Did we choose a host application for our DLL?
        if fProject.Options.typ = dptDyn then begin
          if fProject.Options.HostApplication = '' then begin
            MessageDlg(Lang[ID_ERR_HOSTMISSING], mtWarning, [mbOK], 0);
            exit;
          end else if not FileExists(fProject.Options.HostApplication) then begin
            MessageDlg(Lang[ID_ERR_HOSTNOTEXIST], mtWarning, [mbOK], 0);
            exit;
          end;
        end;

        // Reset UI, remove invalid breakpoints
        PrepareDebugger;

        filepath := fProject.Executable;

        fDebugger.Start;
        fDebugger.SendCommand('file', '"' + StringReplace(UTF8ToWinCP(filepath), '\', '/', [rfReplaceAll]) + '"', true);

        if fProject.Options.typ = dptDyn then
          fDebugger.SendCommand('exec-file', '"' + StringReplace(UTF8ToWinCP(fProject.Options.HostApplication), '\', '/',
            [rfReplaceAll])
            + '"', true);
      end;

    ctFile: begin    // file
        // Check if we enabled proper options

//        with devCompilerSets.CompilationSet do begin
//          DebugEnabled := GetOption('-g3') <> '0';
//          StripEnabled := GetOption('-s') <> '0';
//        end;

        // if debugging not enabled, then display message and exit.
//        if (not DebugEnabled or StripEnabled) then begin
//          MessageDlg(L ang[ID_MSG_NODEBUGSYMBOLS], mtConfirmation, [mbOK], 0);
//          exit;
//        end;

//      检查上一次的编译参数 LastCompileParams 是否包含 -g3 �?-s
//      如果没有就添�?-g3 -Og，并移除编译配置方案中的 -s �?

      // https://gcc.gnu.org/onlinedocs/gcc/Debugging-Options.html
      //-glevel Request debugging information and also use level to specify how much information.
      //-g0:  Level 0 produces no debug information at all. Thus, -g0 negates -g.
      //-g1:  Level 1 produces minimal information, enough for making backtraces
      //      in parts of the program that you don’t plan to debug.
      //      This includes descriptions of functions and external variables,
      //      and line number tables, but no information about local variables.
      //-g2:  Level 2 is the normal setting to produce debuggable code.
      //      The debug output includes all the information from level 1,
      //      plus information about local variables and typedefs to allow stepping
      //      through code and examining its state. For C++ code, additional information
      //      is also emitted to assist in debugging namespace, class, and template functions.
      //-g3   Level 3 includes extra information, such as all the macro definitions
      //      present in the program. Some debuggers support macro expansion when you use -g3.

      //-glevel 与优化级�?-Ox 有关。在 -O1, -O2, -O3, -Ofast 这些选项时，会导致调试时对单语句循环一句跳过�?
      //如果使用 -Og (optimize for debug)，则已定义而未使用的变量会被优化为不显示（Optimized out），令初学者困惑�?

        if Pos('-g3', fCompiler.LastCompileParams) <= 0 then begin
          if Pos('-Og', fCompiler.LastCompileParams) <> 0 then
            //only add '-g3' if there is '-Og' in LastCompileParams
            fCompiler.DebugCompileParams:= '-g3'
          else  //add '-g3' and '-O0'
            fCompiler.DebugCompileParams:= '-g3 -O0';  //'-Og'
          fCompiler.DebugLinkerParams := '-g3';
        end;
        if (devCompilerSets.CompilationSet.GetOption('-s') <> '0' ) then begin
           devCompilerSets.CompilationSet.SetOption('-s', '0');
        end;


        // Ask the user if he wants to enable debugging...
        //if (not DebugEnabled or StripEnabled) and (MessageDlg(Lang[ID_MSG_NODEBUGSYMBOLS],
        //  mtConfirmation, [mbYes, mbNo], 0) = mrYes) then begin

//          // Enable debugging, disable stripping
//          //with devCompilerSets.CompilationSet do begin
//          //  SetOption('-g3', '1');
//          //  SetOption('-s', '0');
//          //end;
//
//          // Save changes to compiler set
//          //devCompilerSets.SaveSet(devCompilerSets.CompilationSetIndex);
//
//        //  for I := 0 to devCompilerSets.Count - 2 do begin
//            DebugEnabled := devCompilerSets[I].GetOption('-g3') <> '0';
//            StripEnabled := devCompilerSets[I].GetOption('-s') <> '0';
//
//            if (DebugEnabled and not StripEnabled) then  begin
//              devCompilerSets.DefaultSetIndex := I;
//                  //devCompilerSets.DefaultSetIndex := index;
//              devCompilerSets.SaveSetList;
//              cmbCompilers.Update;
//              break;
//            end;
//          end;
//
//          fCompSuccessAction := csaDebug;
//          actRebuildExecute(nil); //compile again
          //Exit;
//        end else
//          Exit;

        e := fEditorList.GetEditor;
        if Assigned(e) then begin
          // Did we save?
          //if e.Text.Modified then // if file is modified
          if e.Modified then // if file is modified
            if not e.Save then // save it first
              Exit;

          // Did we compile?
          // EXE file doesn't exist, or no option '-g3' in last compiling command.
          // No need to check time stamp here. See TDebugReader.SyncFinishedParsing
          filepath := ChangeFileExt(AnsiString(e.FileName), EXE_EXT);
          if (not FileExists(filepath)) or (Pos('-g3', fCompiler.LastCompileParams) <= 0) then begin
            //if MessageDlg(Lang[ID_ERR_SRCNOTCOMPILEDSUGGEST], mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
              fCompSuccessAction := csaDebug;
              actCompileExecute(nil);
            //end;
            Exit;
          end;
          fCompiler.DebugCompileParams:= '';
          fCompiler.DebugLinkerParams := '';
          PrepareDebugger;//?

          fDebugger.Start;
          fDebugger.SendCommand('file', '"' + StringReplace(UTF8ToWinCP(filepath), '\', '/', [rfReplaceAll]) + '"', true);
        end;
      end;
    ctNone: Exit;
  end;

  // Add library folders
  with devCompilerSets.CompilationSet do begin
    for I := 0 to LibDir.Count - 1 do
      fDebugger.SendCommand('dir', '"' + StringReplace(UTF8ToWinCP(LibDir[i]), '\', '/', [rfReplaceAll]) + '"', true);

    // Add include folders
    for I := 0 to CDir.Count - 1 do
      fDebugger.SendCommand('dir', '"' + StringReplace(UTF8ToWinCP(CDir[i]), '\', '/', [rfReplaceAll]) + '"', true);

    // Add more include folders, duplicates will be added/moved to front of list
    for I := 0 to CppDir.Count - 1 do
      fDebugger.SendCommand('dir', '"' + StringReplace(UTF8ToWinCP(CppDir[i]), '\', '/', [rfReplaceAll]) + '"', true);
  end;

  // Add watch vars
  for i := 0 to fDebugger.WatchVarList.Count - 1 do
    fDebugger.AddWatchVar(i);
  // Add breakpoints
  for i := 0 to fDebugger.BreakPointList.Count - 1 do
    fDebugger.AddBreakpoint(i);
  //if (fDebugger.BreakPointList.Count = 0) then
  //  MessageDlg(Lang[ID_ERR_NOBREAKPOINT], mtWarning, [mbOK], 0);

  // Run the debugger
  fDebugger.SendCommand('set', 'width 0'); // don't wrap output, very annoying
  fDebugger.SendCommand('set', 'new-console on');
  fDebugger.SendCommand('set', 'confirm off');

  filepath := ExtractFileDir(filepath);
  fDebugger.SendCommand('cd', StringReplace(UTF8ToWinCP(filepath), '\', '/', [rfReplaceAll]) , true); // restore working directory
  case GetCompileTarget of
    ctNone:
      Exit;
    ctFile:
      if fDebugger.BreakPointList.Count = 0 then  // if no breakpoints
        fDebugger.SendCommand('start', fCompiler.RunParams, true) // run to the first line
      else
        fDebugger.SendCommand('run', fCompiler.RunParams, true);  // run to the first breakpoint line
    ctProject:
      if fDebugger.BreakPointList.Count = 0 then  // if no breakpoints
        fDebugger.SendCommand('start', fProject.Options.CmdLineArgs, true) // run to the first line
      else
      fDebugger.SendCommand('run', fProject.Options.CmdLineArgs, true);
  end;
end;

procedure TMainForm.actEnviroOptionsExecute(Sender: TObject);
var
  bool: boolean;
begin
  //translate code snippets(4), custom tools(2) and compilerset(1) to inner macros.
  TransMenuMacros(7, false);

  with TEnvironOptForm.Create(nil) do try
    if ShowModal = mrOk then begin
      // Update pagecontrol
      EditorList.SetPreferences(devData.MsgTabs, devData.MultiLineTab);
      EditorList.DeleteExe := devData.DeleteExe;

      // Update fullscreen options
      if devData.FullScreen then
        ToolbarDock.Visible := devData.ShowBars;

      // Pick new language if we have to (long process)
      if devData.LangChange then begin
        Lang.SetLang(devData.Language);
        LoadText;
        RefreshToolbarCaptions;
      end;


      // Load new icons, also only if we have to
      if devData.ThemeChange then
        Loadtheme;
      UpdateIconThemeChecks;
      fShortcuts.Filename := devDirs.Config + DEV_SHORTCUTS_FILE;

      // Rebuild recent file list (max count could have changed
      dmMain.RebuildMRU;
    end;
    //translate code snippets, custom tools and compilerset to UI language.
    TransMenuMacros(7, true);
    UpdateCompilerList;
  finally
    Close;
  end;
end;

procedure TMainForm.actUpdatePageCount(Sender: TObject);
begin
  TCustomAction(Sender).Enabled := fEditorList.PageCount > 0;
end;

procedure TMainForm.actUpdateDeleteWatch(Sender: TObject);
begin
  TCustomAction(Sender).Enabled := Assigned(DebugView.Selected);
end;

procedure TMainForm.actUpdatePageorProject(Sender: TObject);
begin
  TCustomAction(Sender).Enabled := Assigned(fProject) or (fEditorList.PageCount > 0);
end;

procedure TMainForm.actCompileUpdate(Sender: TObject);
begin
  TCustomAction(Sender).Enabled := (not fCompiler.Compiling) and (GetCompileTarget <> ctNone) and
    Assigned(devCompilerSets.CompilationSet);
  //if TCustomAction(Sender).Enabled  then
  //  screen.Cursor:=crdefault;
end;

procedure TMainForm.actUpdateProject(Sender: TObject);
begin
  TCustomAction(Sender).Enabled := assigned(fProject);
end;

procedure TMainForm.actUpdateMakeFile(Sender: TObject);
begin
  TCustomAction(Sender).Enabled := assigned(fProject) and (not fCompiler.Compiling) and (GetCompileTarget <> ctNone) and
    Assigned(devCompilerSets.CompilationSet);
end;

procedure TMainForm.actUpdateEmptyEditor(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  TCustomAction(Sender).Enabled := Assigned(e); // ATSynEdit: always enable when there's an editor
end;

procedure TMainForm.actUpdateDebuggerRunning(Sender: TObject);
begin
  TCustomAction(Sender).Enabled := fDebugger.Executing;
end;

procedure TMainForm.actUpdateDebuggerRunningCPU(Sender: TObject);
begin
  TCustomAction(Sender).Enabled := fDebugger.Executing and not Assigned(CPUForm);
end;

procedure TMainForm.actUpdateEmptyEditorFindForm(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  TCustomAction(Sender).Enabled := Assigned(e) and (not Assigned(FindForm) or not FindForm.Showing);
end;

procedure TMainForm.actRunUpdate(Sender: TObject);
begin
  if Assigned(fProject) then
    TCustomAction(Sender).Enabled := (GetCompileTarget <> ctNone) and (fProject.Options.typ <> dptStat)
                                      and (not fCompiler.Compiling)
  else
    TCustomAction(Sender).Enabled := (GetCompileTarget <> ctNone) and (not fCompiler.Compiling);
end;

procedure TMainForm.actCompileRunUpdate(Sender: TObject);
begin
  if Assigned(fProject) then
    TCustomAction(Sender).Enabled := (fProject.Options.typ <> dptStat) and (not fCompiler.Compiling) and
      (GetCompileTarget <> ctNone) and Assigned(devCompilerSets.CompilationSet)
  else
    TCustomAction(Sender).Enabled := (not fCompiler.Compiling) and (GetCompileTarget <> ctNone) and
      Assigned(devCompilerSets.CompilationSet)
end;

procedure TMainForm.ToolbarDockClick(Sender: TObject);
begin
  tbMain.Visible := ToolMainItem.Checked;
  //tbEdit.Visible := ToolEditItem.Checked;
  //tbCompile.Visible := ToolCompileandRunItem.Checked;
  //tbProject.Visible := ToolProjectItem.Checked;
  //tbSpecials.Visible := ToolSpecialsItem.Checked;
  //tbSearch.Visible := ToolSearchItem.Checked;
  //tbClasses.Visible := false; //ToolClassesItem.Checked;
  //tbCompilers.Visible := ToolCompilersItem.Checked;

  devData.ToolbarMain := ToolMainItem.Checked;
  //devData.ToolbarEdit := ToolEditItem.Checked;
  //devData.ToolbarCompile := ToolCompileandRunItem.Checked;
  //devData.ToolbarProject := false;  //ToolProjectItem.Checked;
  //devData.ToolbarSpecials := ToolSpecialsItem.Checked;
  //devData.ToolbarSearch := ToolSearchItem.Checked;
  //devData.ToolbarClasses := false;  //ToolClassesItem.Checked;
  //devData.ToolbarCompilers := ToolCompilersItem.Checked;
end;

procedure TMainForm.ToolbarDockContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  //TrackPopupMenu(ToolbarsItem.Handle, TPM_LEFTALIGN or TPM_LEFTBUTTON,
  //  pt.x, pt.y, 0, Self.Handle, nil);
  //Handled := TRUE;
end;


procedure TMainForm.SplitterBottomMoved(Sender: TObject);
begin
  fPreviousHeight := MessageControl.Height;
end;

procedure TMainForm.actProjectMakeFileExecute(Sender: TObject);
begin
  // Fake a project compilation step
  ClearCompileMessages;
  fCompiler.Target := ctProject;
  fCompiler.Project := fProject;
  fCompiler.CompilerSet := devCompilerSets.CompilationSet;
  fCompiler.BuildMakeFile;

  // Show the results
  OpenFile(fCompiler.MakeFile);
end;

procedure TMainForm.actMsgCutExecute(Sender: TObject);
begin
  case MessageControl.ActivePageIndex of
    3: begin
        if EvaluateInput.Focused then begin
          Clipboard.AsText := EvaluateInput.SelText;
          EvaluateInput.SelText := '';
        end else if cmbGdbCommand.Focused then begin
          Clipboard.AsText := cmbGdbCommand.SelText;
          cmbGdbCommand.SelText := '';
        end;
      end;
  end;
end;

procedure TMainForm.actMsgCopyExecute(Sender: TObject);
begin
  case MessageControl.ActivePageIndex of
    0:
      Clipboard.AsText := GetPrettyLine(ResourceOutput);
    1:
      Clipboard.AsText := GetPrettyLine(CompilerOutput);
    2: begin
        if LogOutput.Focused then
          LogOutput.CopyToClipboard;
      end;
    3: begin
        if EvaluateInput.Focused then
          Clipboard.AsText := EvaluateInput.SelText
        else if EvalOutput.Focused then
          EvalOutput.CopyToClipboard
        else if cmbGdbCommand.Focused then
          Clipboard.AsText := cmbGdbCommand.SelText
        else if DebugOutput.Focused then
          DebugOutput.CopyToClipboard;
      end;
    4:
      Clipboard.AsText := GetPrettyLine(FindOutput);
  end;
end;

procedure TMainForm.actMsgCopyAllExecute(Sender: TObject);
var
  i: integer;
begin
  case MessageControl.ActivePageIndex of
    0: begin
        ClipBoard.AsText := '';
        for i := 0 to pred(CompilerOutput.Items.Count) do
          Clipboard.AsText := Clipboard.AsText + GetPrettyLine(CompilerOutput, i) + #13#10;
      end;
    1: begin
        ClipBoard.AsText := '';
        for i := 0 to pred(ResourceOutput.Items.Count) do
          Clipboard.AsText := Clipboard.AsText + GetPrettyLine(ResourceOutput, i) + #13#10;
      end;
    2:
      LogOutput.CopyToClipboard;
    3: begin
        if EvaluateInput.Focused then
          Clipboard.AsText := EvaluateInput.Text
        else if EvalOutput.Focused then
          Clipboard.AsText := EvalOutput.Text
        else if cmbGdbCommand.Focused then
          Clipboard.AsText := cmbGdbCommand.Text
        else if DebugOutput.Focused then
          Clipboard.AsText := DebugOutput.Text
      end;
    4: begin
        ClipBoard.AsText := '';
        for i := 0 to pred(FindOutput.Items.Count) do
          Clipboard.AsText := Clipboard.AsText + GetPrettyLine(FindOutput, i) + #13#10;
      end;
  end;
end;

procedure TMainForm.actMsgPasteExecute(Sender: TObject);
begin
  case MessageControl.ActivePageIndex of
    3: begin
        if EvaluateInput.Focused then
          EvaluateInput.SelText := ClipBoard.AsText
        else if cmbGdbCommand.Focused then
          cmbGdbCommand.SelText := ClipBoard.AsText
      end;
  end;
end;

procedure TMainForm.actMsgSelAllExecute(Sender: TObject);
begin
  case MessageControl.ActivePageIndex of
    2: begin
        if LogOutput.Focused then
          LogOutput.SelectAll;
      end;
    3: begin
        if EvaluateInput.Focused then
          EvaluateInput.SelectAll
        else if cmbGdbCommand.Focused then
          cmbGdbCommand.SelectAll
        else if EvalOutput.Focused then
          EvalOutput.SelectAll
        else if DebugOutput.Focused then
          DebugOutput.SelectAll;
      end;
  end;
end;

procedure TMainForm.actMsgTranslateExecute(Sender: TObject);
begin
  devData.TranslateMsg := not devData.TranslateMsg;  //chkTranslateMsg
end;

procedure TMainForm.actMsgSaveAllExecute(Sender: TObject);
var
  i: integer;
  fulloutput: String;
  Stream: TFileStream;
  e: TEditor;
begin
  fulloutput := '';
  with TSaveDialog.Create(self) do try
    case MessageControl.ActivePageIndex of
      0: begin
          FileName := 'Formatted Compiler Output';
          for i := 0 to CompilerOutput.Items.Count - 1 do
            fulloutput := fulloutput + GetPrettyLine(CompilerOutput, i) + #13#10;
        end;
      1: begin
          FileName := 'Resource Error Log';
          for i := 0 to ResourceOutput.Items.Count - 1 do
            fulloutput := fulloutput + GetPrettyLine(ResourceOutput, i) + #13#10;
        end;
      2: begin
          FileName := 'Raw Build Log';
          if Length(LogOutput.Text) > 0 then
            fulloutput := LogOutput.Text;
        end;
      3: begin
          FileName := 'Raw GDB Output';
          if Length(DebugOutput.Text) > 0 then
            fulloutput := DebugOutput.Text;
        end;
      4: begin
          FileName := 'Find Results';
          for i := 0 to FindOutput.Items.Count - 1 do
            fulloutput := fulloutput + GetPrettyLine(FindOutput, i) + #13#10;
        end;
    end;

    if Length(fulloutput) > 0 then begin

      Title := Lang[ID_NV_SAVEFILE];
      Filter := BuildFilter([FLT_TEXTS]);
      DefaultExt := 'txt';
      FilterIndex := 1;
      Options := Options + [ofOverwritePrompt];

      if Assigned(fProject) then begin
        InitialDir := fProject.Directory;
      end else begin
        e := fEditorList.GetEditor;
        if Assigned(e) then
          InitialDir := AnsiString(ExtractFilePath(e.FileName))
        else
          InitialDir := 'C:\';
      end;

      if Execute then begin
        Stream := TFileStream.Create(FileName, fmCreate);
        try
          Stream.Write(fulloutput[1], Length(fulloutput));
        finally
          Stream.Free;
        end;
      end;
    end;
  finally
    Free;
  end;
end;

procedure TMainForm.actMsgClearExecute(Sender: TObject);
begin
  case MessageControl.ActivePageIndex of
    0:
      CompilerOutput.Items.Clear;
    1:
      ResourceOutput.Items.Clear;
    2:
      LogOutput.Clear;
    3: begin
        if EvaluateInput.Focused then
          EvaluateInput.Clear
        else if EvalOutput.Focused then
          EvalOutput.Clear
        else if cmbGdbCommand.Focused then
          cmbGdbCommand.Clear
        else if DebugOutput.Focused then
          DebugOutput.Clear;
      end;
    4: begin
        FindOutput.Clear;
      end;
  end;
end;

procedure TMainForm.actMessagePanelExecute(Sender: TObject);
begin
  if fPreviousHeight <= devData.InterfaceFontSize then
    fPreviousHeight :=  devData.InterfaceFontSize * 8; // only show the tab captions

  OpenCloseMessageSheet(MessageControl.Height <> fPreviousHeight);
end;

procedure TMainForm.ClassicThemeItemClick(Sender: TObject);
begin

end;

procedure TMainForm.CleanThemeItemClick(Sender: TObject);
begin

end;

procedure TMainForm.actIncrementalExecute(Sender: TObject);
var
  pt: TPoint;
  e: TEditor;
  PageControl: TPageControl;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then begin

    // Only create the form when we need to do so
    if not Assigned(IncrementalForm) then
      IncrementalForm := TIncrementalForm.Create(self);

    PageControl := e.PageControl;
    pt := ClienttoScreen(point(PageControl.Left + PageControl.Width - IncrementalForm.Width - 10, PageControl.Top));

    IncrementalForm.Left := pt.x;
    IncrementalForm.Top := pt.y;
    IncrementalForm.editor := e.Text;
    IncrementalForm.Show;
  end;
end;

procedure TMainForm.CompilerOutputDblClick(Sender: TObject);
var
  Col, Line: integer;
  selection: TListItem;
  errorfiletab: TEditor;
  FileExt: String;
  url: String;
  s1, s2, msg: String;
  FileName, FilePath: String;
begin
  selection := TListView(Sender).Selected; // used by compile and resource lists
  if Assigned(selection) then begin
    Line := StrToIntDef(selection.Caption, 0);
    Col := StrToIntDef(selection.SubItems[0], 0);

    if (Line = 0) and (Col = 0) then begin
      s1 := selection.SubItems[1];
      s2 := selection.SubItems[2];

      if Assigned(fProject) then begin
        FilePath := fProject.Executable;
        FileName := ExtractFileName(FilePath);
      end
      else begin
        FilePath := ChangeFileExt(fCompiler.SourceFile, EXE_EXT);
        FileName := FilePath;
      end;

      if (pos('collect2.exe', s1) > 0) and (pos('ld', s2)>0 ) then
        //collect2.exe	[ERROR] Linker (ld) return 1 exit status
	Application.MessageBox(PChar(Lang[ID_ERR_COLLECT]), PChar(Lang[ID_ERROR]), MB_ICONINFORMATION or MB_OK)
      else if (pos('ld.exe', s1) > 0 ) and (pos('libmingw', s2)> 0) and (pos('ain', s2)>0) then
        // MinGW64\bin/ld.exe	d:\...\MinGW64\x86_64-w64-mingw32\lib/libmingw32.a(...): undefined reference to `WinMain'
	Application.MessageBox(PChar(Lang[ID_ERR_NOMAIN]), PChar(Lang[ID_ERROR]), MB_ICONINFORMATION or MB_OK)
      else if (pos('ld.exe', s1) > 0 ) and (pos(FileName, s2)> 0) and FileExists(FilePath) then begin
        // MinGW64\bin/ld.exe	cannot open output file D:\cc\Hello.exe: Permission denied
        msg := format(Lang[ID_ERR_PERMDENIED1], [FileName]) + sLineBreak + sLineBreak + Lang[ID_ERR_PERMDENIED2];
        Application.MessageBox(PChar(msg), PChar(Lang[ID_ERROR]), MB_ICONINFORMATION or MB_OK);
//      end else begin
//        url := 'https://www.baidu.com/s?wd=' + URLEncode(s1 + ', ' + s2);
//        ShellExecute(GetDesktopWindow(), 'open', PChar(url), nil, nil, SW_SHOWNORMAL);
      end;
      exit;
    end;

    //if filename extension is '.exe' (ld.exe, collect.exe), do not open the file.
    FileExt := ExtractFileExt(selection.SubItems[1]);
    if (FileExt = '.exe') then
      exit;

    errorfiletab := fEditorList.GetEditorFromFileName(selection.SubItems[1]);

    if Assigned(errorfiletab) then begin
      errorfiletab.SetErrorFocus(Col, Line);
      errorfiletab.Activate;
    end;
  end;
end;

procedure TMainForm.FindOutputDblClick(Sender: TObject);
var
  col, line, logicalcol: integer;
  e: TEditor;
  selected: TListItem;
  LineText: String;
begin
  selected := FindOutPut.Selected;
  if Assigned(selected) and not SameStr(selected.Caption, '') then begin
    Col := StrToIntDef(selected.SubItems[1], 1);
    Line := StrToIntDef(selected.SubItems[0], 1);

    // And open up
    e := fEditorList.GetEditorFromFileName(selected.SubItems[2]);
    if Assigned(e) then begin

      // Convert display column (Tab-expanded) to logical column (Tab=1 char)
      // Stored values are 1-based; clamp defensively so that a bad value can
      // never produce an invalid caret (PosX/PosY = -1).
      if Col < 1 then
        Col := 1;
      if Line < 1 then
        Line := 1
      else if Line > e.Text.Strings.Count then
        Line := e.Text.Strings.Count;

      if (Line >= 1) and (Line <= e.Text.Strings.Count) then begin
        LineText := AnsiString(e.Text.Strings.Lines[Line - 1]);
        LogicalCol := DisplayColToLogicalCol(LineText, Col, 8);
      end else
        LogicalCol := Col;
      if LogicalCol < 1 then
        LogicalCol := 1;

      // Position the caret
      e.SetCaretPosAndActivate(Line, LogicalCol);

      // Then select the word we searched for
      e.Text.DoCommand(cCommand_SelectWords, TATCommandInvoke(0), '');
    end;
  end;
end;

procedure TMainForm.actShowBarsExecute(Sender: TObject);
begin
  if devData.FullScreen then
    ToolbarDock.Visible := not ToolbarDock.Visible;
end;

procedure TMainForm.FormContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
//var
//  pt: TPoint;
begin
//  pt := ClientToScreen(MousePos);
//  TrackPopupMenu(ViewMenu.Handle, TPM_LEFTALIGN or TPM_LEFTBUTTON, pt.x, pt.y, 0, Self.Handle, nil);
//  Handled := TRUE;
end;

procedure TMainForm.actAddWatchExecute(Sender: TObject);
var
  s: String;
  e: TEditor;
begin
  s := '';
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    // ATSynEdit: use CaretsSel + TextSelected + TextCurrentWord
    if not e.Text.CaretsSel.IsEmpty then
      s := Trim(String(e.Text.TextSelected))
    else
      s := String(e.Text.TextCurrentWord);
  end;
  if not InputQuery(Lang[ID_NV_ADDWATCH], Lang[ID_NV_ENTERVAR], s) then
    Exit;
  if s <> '' then
    fDebugger.AddWatchVar(s);
end;

procedure TMainForm.actNextLineExecute(Sender: TObject);
begin
  if fDebugger.Executing then begin
    fDebugger.SendCommand('next', '', true);
  end;
end;

procedure TMainForm.actStepLineExecute(Sender: TObject);
begin
  if fDebugger.Executing then begin
    fDebugger.SendCommand('step', '', true);
  end;
end;

procedure TMainForm.actRemoveWatchExecute(Sender: TObject);
var
  node: TTreeNode;
begin
  node := DebugView.Selected;
  if Assigned(node) then begin

    // Retrieve topmost node
    while Assigned(node.Parent) do
      node := node.Parent;

    fDebugger.RemoveWatchVar(node);
  end;
end;

procedure TMainForm.RemoveActiveBreakpoints;
var
  i: integer;
begin
  for i := 0 to EditorList.PageCount - 1 do
    fEditorList[i].RemoveBreakpointFocus;
end;

procedure TMainForm.GotoBreakpoint(const FileName: String; Line: integer);
var
  e: TEditor;
begin
  // Remove line focus in files left behind
  RemoveActiveBreakpoints;

  // Then active the current line in the current file
  e := fEditorList.GetEditorFromFileName(StringReplace(FileName, '/', '\', [rfReplaceAll]));
  if Assigned(e) then begin
    e.SetActiveBreakpointFocus(Line);
    e.Activate;
  end;
  Application.BringToFront;
end;

procedure TMainForm.actContinueExecute(Sender: TObject);
begin
  if fDebugger.Executing then begin
    RemoveActiveBreakpoints;
    fDebugger.SendCommand('continue', '', true);
  end;
end;

procedure TMainForm.actStopExecuteExecute(Sender: TObject);
begin
  if fDebugger.Executing then
    fDebugger.Stop
  else if devExecutor.Running then
    devExecutor.Reset;  //todo: should stop running
end;

procedure TMainForm.actUndoUpdate(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  actUndo.Enabled := assigned(e) and (e.Text.UndoCount > 0);
end;

procedure TMainForm.actRedoUpdate(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  actRedo.enabled := assigned(e) and (e.Text.RedoCount > 0);
end;

procedure TMainForm.actCutUpdate(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  // ATSynEdit: use CaretsSel (not IsEmpty = has selection) instead of SelAvail
  actCut.Enabled := Assigned(e) and not e.Text.CaretsSel.IsEmpty;
end;

procedure TMainForm.actCopyUpdate(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  // ATSynEdit: use CaretsSel (not IsEmpty = has selection) instead of SelAvail
  actCopy.Enabled := Assigned(e) and not e.Text.CaretsSel.IsEmpty;
end;

procedure TMainForm.actPasteUpdate(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  actPaste.Enabled := Assigned(e) and true;
end;

procedure TMainForm.actSaveUpdate(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  actSave.Enabled := Assigned(e) and (e.Text.Modified or (e.FileName = ''));
end;

procedure TMainForm.actSaveAsUpdate(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  actSaveAs.Enabled := Assigned(e);
end;

procedure TMainForm.ClearCompileMessages;
begin
  CompilerOutput.Clear;
  ResourceOutput.Clear;
  LogOutput.Clear;
  fLogOutputRawData.Clear;
  DebugOutput.Clear;
end;

procedure TMainForm.ClearMessageControl;
begin
  FindOutput.Items.Clear; // don't clear this when compiling...
  ClearCompileMessages;
end;

procedure TMainForm.actFileMenuExecute(Sender: TObject);
begin
  //	dummy event to keep menu active
end;

procedure TMainForm.actToolsMenuExecute(Sender: TObject);
var
  I, J: integer;
begin
  for I := (ToolsMenu.IndexOf(PackageManagerItem) + 2) to ToolsMenu.Count - 1 do begin
    J := ToolsMenu.Items[I].tag;
    ToolsMenu.Items[I].Enabled := FileExists(ParseToolParams(fTools.ToolList[J]^.Exec));
    if not ToolsMenu.Items[I].Enabled then
      ToolsMenu.Items[I].Caption := fTools.ToolList[J]^.Title + ' (Tool not found)';
  end;
end;

procedure TMainForm.UpdateCompilerList;
var
  I: integer;
begin
  //cmbCompilers.Items.BeginUpdate;
  //try
    //cmbCompilers.Clear;

    // Populate list
    //for I := 0 to devCompilerSets.Count - 1 do
    //  cmbCompilers.Items.Add(devCompilerSets[i].Name);

    // Select current compiler
    //cmbCompilers.ItemIndex := devCompilerSets.CompilationSetIndex;

    // Mention change to compiler sets
    //devCompilerSets.OnCompilerSetChanged(
    //  devCompilerSets[fOldCompilerToolbarIndex],
    //  devCompilerSets[cmbCompilers.ItemIndex]);

    // Remember current index
  //  fOldCompilerToolbarIndex := cmbCompilers.ItemIndex;
  //finally
  //  cmbCompilers.Items.EndUpdate;
  //end;
end;

procedure TMainForm.UpdateClassBrowsing;
var
  I: integer;
  SavedOnBusy: TNotifyEvent;
  Directory: AnsiString;
begin
  // Configure parser - suppress OnBusy during Reset to avoid
  // unbalanced BeginUpdate (Reset triggers OnBusy �?ClassBrowser.BeginUpdate)
  SavedOnBusy := CppParser.OnBusy;
  CppParser.OnBusy := nil;
  CppParser.Reset;
  CppParser.OnBusy := SavedOnBusy;
  CppParser.Tokenizer := CppTokenizer;
  CppParser.Preprocessor := CppPreprocessor;
  CppParser.Enabled := devCodeCompletion.Enabled;
  CppParser.ParseLocalHeaders := devCodeCompletion.ParseLocalHeaders;
  CppParser.ParseGlobalHeaders := devCodeCompletion.ParseGlobalHeaders;
  CppParser.OnStartParsing := @CppParserStartParsing;
  CppParser.OnEndParsing := @CppParserEndParsing;
  CppParser.OnTotalProgress := @CppParserTotalProgress;

  // Set options depending on the current compiler set
  // TODO: do this every time OnCompilerSetChanged
  if Assigned(devCompilerSets.DefaultSet) then
    with devCompilerSets.DefaultSet do begin
      CppParser.ClearIncludePaths;
      for I := 0 to CDir.Count - 1 do
        CppParser.AddIncludePath(CDir[I]);
      for I := 0 to CppDir.Count - 1 do
        CppParser.AddIncludePath(CppDir[I]);
      for I := 0 to DefInclude.Count - 1 do // Add default include dirs last, just like gcc does
        CppParser.AddIncludePath(DefInclude[I]);

      // Set defines
      CppParser.ResetDefines;
      for I := 0 to Defines.Count - 1 do
        CppParser.AddHardDefineByLine(Defines[i]); // predefined constants from -dM -E
    end;

  // Configure code completion
  CodeCompletion.Color := devCodeCompletion.BackColor;
  CodeCompletion.Width := devCodeCompletion.Width;
  CodeCompletion.Height := devCodeCompletion.Height;
  CodeCompletion.Fontsize := devEditor.Font.Size;  //devData.InterfaceFontSize;

  //BrowserView.Font.Size := devData.InterfaceFontSize;

  // Only attempt to redraw once
  ClassBrowser.BeginUpdate;
  UpdateBrowserView;
  try
    ClassBrowser.ShowFilter := TShowFilter(devClassBrowsing.ShowFilter);
    ClassBrowser.ShowInheritedMembers := devClassBrowsing.ShowInheritedMembers;
    ClassBrowser.TabVisible := LeftPageControl.ActivePageIndex = 1;
  finally
    ClassBrowser.EndUpdate;
  end;

  // Configure class browser actions
  actBrowserViewAll.Checked := ClassBrowser.ShowFilter = sfAll;
  actBrowserViewProject.Checked := ClassBrowser.ShowFilter = sfProject;
  actBrowserViewCurrent.Checked := ClassBrowser.ShowFilter = sfCurrent;
  actBrowserViewIncludes.Checked := ClassBrowser.ShowFilter = sfSystemFiles;
  actBrowserShowInherited.Checked := ClassBrowser.ShowInheritedMembers;
end;

procedure TMainForm.ScanActiveProject;
var
  I: integer;
  e: TEditor;
  SavedOnBusy: TNotifyEvent;
begin
  SavedOnBusy := CppParser.OnBusy;
  CppParser.OnBusy := nil; // Suppress during Reset to avoid unbalanced BeginUpdate
  try
    with CppParser do begin
      Reset;
      if Assigned(fProject) then begin
        ProjectDir := fProject.Directory;
        for I := 0 to fProject.Units.Count - 1 do
          AddFileToScan(fProject.Units[I].FileName, True);
        ClearProjectIncludePaths;
        for I := 0 to fProject.Options.Includes.Count - 1 do
          AddProjectIncludePath(fProject.Options.Includes[I]);
      end else begin
        e := fEditorList.GetEditor;
        if Assigned(e) then begin
          ProjectDir := AnsiString(ExtractFilePath(e.FileName));
          AddFileToScan(AnsiString(e.FileName));
        end else
          ProjectDir := '';
      end;
      CppParser.OnBusy := SavedOnBusy; // Restore before ParseFileList
      ParseFileList;
    end;
  finally
    CppParser.OnBusy := SavedOnBusy;
  end;
end;


procedure TMainForm.CodeCompletionResize(Sender: TObject);
begin
  devCodeCompletion.Width := CodeCompletion.Width;
  devCodeCompletion.Height := CodeCompletion.Height;
end;

procedure TMainForm.actSwapHeaderSourceExecute(Sender: TObject);
var
  FromEditor, ToEditor: TEditor;
  CFile, HFile, ToFile: UnicodeString;
  iscfile, ishfile: boolean;
begin
  FromEditor := fEditorList.GetEditor;
  CFile := '';
  HFile := '';
  if not Assigned(FromEditor) then
    Exit;

  iscfile := CppParser.IsCfile(FromEditor.FileName);
  ishfile := CppParser.IsHfile(FromEditor.FileName);

  CppParser.GetSourcePair(FromEditor.FileName, CFile, HFile);
  if iscfile then begin
    ToFile := HFile
  end else if ishfile then begin
    ToFile := CFile
  end else begin
    Exit; // don't know file type, don't bother searching
  end;

  // Fetch the file we want to go to
  ToEditor := fEditorList.FileIsOpen(AnsiString(ToFile));
  if Assigned(ToEditor) then
    ToEditor.Activate
  else begin
    // We need to open a new editor
    ToEditor := fEditorList.GetEditorFromFileName(AnsiString(ToFile));
    if Assigned(ToEditor) then begin

      // Move the editors next to each other if possible
      // Do not try to do so if they are visible in separate editors
      if FromEditor.PageControl = ToEditor.PageControl then begin

        // Move source file to the left of the header file
        if iscfile then begin
          ToEditor.TabSheet.PageIndex := min(FromEditor.PageControl.PageCount - 1, FromEditor.TabSheet.PageIndex + 1);
        end else begin
          ToEditor.TabSheet.PageIndex := max(0, FromEditor.TabSheet.PageIndex);
        end;
      end;
      ToEditor.Activate;
    end else if iscfile then begin
      SetStatusBarMessage(Lang[ID_MSG_CORRESPONDINGHEADER]);
    end else if ishfile then begin
      SetStatusBarMessage(Lang[ID_MSG_CORRESPONDINGSOURCE]);
    end;
  end;
end;

procedure TMainForm.actSyntaxCheckExecute(Sender: TObject);
begin
  actStopExecuteExecute(nil);
  if fCompiler.Compiling then begin
    MessageDlg(Lang[ID_MSG_ALREADYCOMP], mtInformation, [mbOK], 0);
    Exit;
  end;
  if not PrepareForCompile then
    Exit;
  fCompiler.CheckSyntax;
end;


procedure TMainForm.actSyntaxCheckFileExecute(Sender: TObject);
begin
  actStopExecuteExecute(Self);
  if fCompiler.Compiling then begin
    MessageDlg(Lang[ID_MSG_ALREADYCOMP], mtInformation, [mbOK], 0);
    Exit;
  end;
  if not PrepareForCompile(ctFile) then  //
    Exit;
  fCompiler.CheckSyntax;
end;

procedure TMainForm.EditorSaveTimer(Sender: TObject);
var
  e: TEditor;
  i: integer;
  EditorSaveList: TList;
  NewFileName: String;
begin
  EditorSaveList := TList.Create;
  try
    // Assemble a list of files that need saving
    case devEditor.AutoSaveFilter of
      0: begin // Save current file
          e := fEditorList.GetEditor;
          if Assigned(e) and not e.New then // don't save untitled files
            EditorSaveList.Add(e);
        end;
      1: begin // Save all open files
          for I := 0 to EditorList.PageCount - 1 do begin
            e := fEditorList[i];
            if Assigned(e) and not e.New then
              EditorSaveList.Add(e);
          end;
        end;
      2: begin // Save all project files
          for I := 0 to EditorList.PageCount - 1 do begin
            e := fEditorList[i];
            if Assigned(e) and e.InProject and not e.New then
              EditorSaveList.Add(e);
          end;
        end;
    end;

    // Then process the list
    // For each file, get original filename, determine copy filename, and save the copy
    for I := 0 to EditorSaveList.Count - 1 do begin
      e := TEditor(EditorSaveList[i]);
      case devEditor.AutoSaveMode of
        0: begin // overwrite (standard save)
            //if e.Text.Modified and e.Save then
            if e.Modified and e.Save then
              SetStatusbarMessage(Format(Lang[ID_AUTOSAVEDFILE], [e.FileName]));
          end;
        1: begin // append UNIX timestamp (backup copy, don't update class browser)
            NewFileName := ChangeFileExt(AnsiString(e.FileName), '.' + IntToStr(DateTimeToUnix(Now)) + ExtractFileExt(AnsiString(e.FileName)));
            e.Text.Strings.SaveToFile(NewFileName);
            SetStatusbarMessage(Format(Lang[ID_AUTOSAVEDFILEAS], [e.FileName, NewFileName]));
          end;
        2: begin // append formatted timestamp (backup copy, don't update class browser)
            NewFileName := ChangeFileExt(AnsiString(e.FileName), '.' + FormatDateTime('yyyy mm dd hh mm ss', Now) +
              ExtractFileExt(AnsiString(e.FileName)));
            e.Text.Strings.SaveToFile(NewFileName);
            SetStatusbarMessage(Format(Lang[ID_AUTOSAVEDFILEAS], [e.FileName, NewFileName]));
          end;
      end;
    end;
  finally
    // Do not save members.
    EditorSaveList.Free;
  end;
end;

procedure TMainForm.EditorPageControlLeftChange(Sender: TObject);
var
  e: TEditor;
  PageControl: TPageControl;
//  I: integer;
begin
  // Determine who sent this message
  PageControl := TPageControl(Sender);
  e := fEditorList.GetEditor(-1, PageControl);
  if Assigned(e) then begin
    // Update focus so user can keep typing
    if e.Text.CanFocus then // TODO: can fail for some reason
      e.Text.SetFocus; // this should trigger then OnEnter even of the Text control

    // No editors are visible
  end else begin
    // Set title bar to current file
    UpdateAppTitle;

    // Set classbrowser to current file
//    ClassBrowser.CurrentFile := '';

    // Set compiler selector to current file
    UpdateCompilerList;

    // Update status bar
    SetStatusbarLineCol;

    // Update bookmark menu
//    for i := 1 to 9 do begin
//      TogglebookmarksPopItem.Items[i - 1].Checked := false;
//      TogglebookmarksItem.Items[i - 1].Checked := false;
//      GotobookmarksPopItem.Items[i - 1].Checked := false;
//      GotobookmarksItem.Items[i - 1].Checked := false;
//    end;

    // Update focus of incremental search
    if Assigned(IncrementalForm) and IncrementalForm.Showing then
      IncrementalForm.Close;
  end;
end;

procedure TMainForm.actConfigShortcutsExecute(Sender: TObject);

var
  shortfrm: TShortcutsForm;
  I : integer;
  item: PShortcutItem;
begin
  shortfrm := TShortcutsForm.Create(Self);
  // Use the preloaded list, do not walk the Components list again
  shortfrm.BeginUpdate;
  try
    for I := 0 to fShortcuts.Shtcuts.Count -1 do begin
      item := PShortcutItem(fShortcuts.Shtcuts[i]);
      if Assigned(item^.MenuItem) then
        item^.ListEntry := fShortcuts.GetItemDescription(item^.MenuItem)
      else if Assigned(item^.Action) then
        item^.ListEntry := '(' + Lang[ID_SC_BUTTON] + ') > ' + StripHotkey(item^.Action.Caption)
      else
        item^.ListEntry := '';
      shortfrm.AddShortcut(item); // display translated caption
    end;;
  finally
   shortfrm.EndUpdate; // repaint once
  end;

  if shortfrm.ShowModal = mrOk then begin
    try
      for I := 0 to fShortcuts.Shtcuts.Count - 1 do begin
        item := PShortcutItem(fShortcuts.Shtcuts[i]);
        // Apply to Menu
        if Assigned(item^.MenuItem) then
          item^.MenuItem.ShortCut := shortfrm.ShortCuts[I]^.Temporary;
        // Apply to action
        if Assigned(item^.Action) then
          item^.Action.ShortCut := shortfrm.ShortCuts[I]^.Temporary;
      end;
    finally
     fShortcuts.Save;
    end;

  end;

end;

procedure TMainForm.DateTimeMenuItemClick(Sender: TObject);   //discard
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    e.InsertString(FormatDateTime( Lang[ID_ITEM_DATETIMEFORMAT], Now) + '*|*', TRUE);
//    e.InsertString(FormatDateTime('dd/mm/yy hh:nn', Now), TRUE);
end;

procedure TMainForm.CommentheaderMenuItemClick(Sender: TObject);  //discard
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    e.InsertString('/*********************************************************************' + #13#10 +
      '	'+Lang[ID_ITEM_PROGRAM] + #13#10 +
      '	'+Lang[ID_ITEM_COPYRIGHT] + #13#10 +
      '	'+Lang[ID_ITEM_AUTHOR] + #13#10 +
      '	'+Lang[ID_ITEM_DATEANDTIME] + FormatDateTime(Lang[ID_ITEM_DATETIMEFORMAT], Now) + #13#10 +
      '	'+Lang[ID_ITEM_DESCRIPTION] + #13#10 +
      '*********************************************************************/' + #13#10 + '*|*', true);
//    e.InsertString('/*' + #13#10 +
//      '	Name: ' + #13#10 +
//      '	Copyright: ' + #13#10 +
//      '	Author: ' + #13#10 +
//      '	Date: ' + FormatDateTime('dd/mm/yy hh:nn', Now) + #13#10 +
//      '	Description: ' + #13#10 +
//      '*/' + #13#10, true);
  end;
end;

procedure TMainForm.EditorPageControlLeftMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y:
  Integer);
var
  PageIndex: integer;
  SenderPageControl: TPageControl;
  e: TEditor;
begin
  SenderPageControl := TPageControl(Sender);
  if Button = mbRight then begin // select new tab even with right mouse button
    PageIndex := SenderPageControl.IndexOfTabAt(X, Y);
    if PageIndex <> -1 then begin
      SenderPageControl.ActivePageIndex := PageIndex;
      SenderPageControl.OnChange(SenderPageControl);
    end;
  end else if Button = mbMiddle then begin
    PageIndex := SenderPageControl.IndexOfTabAt(X, Y);
    if PageIndex <> -1 then begin
      e := fEditorList.GetEditor(PageIndex, SenderPageControl);
      if Assigned(e) then
        fEditorList.CloseEditor(e);
    end;
  end else // see if it's a drag operation
    SenderPageControl.Pages[SenderPageControl.ActivePageIndex].BeginDrag(False);
end;

procedure TMainForm.actNewTemplateUpdate(Sender: TObject);
begin
  actNewTemplate.Enabled := Assigned(fProject);
end;

procedure TMainForm.actCommentExecute(Sender: TObject);
var
  e: TEditor;
  SelText, NewText, LineText: String;
  Lines: TStringList;
  i, LineIdx: integer;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    SelText := String(e.Text.TextSelected);
    if (SelText = '') or (e.Text.Carets.Count = 0) then begin
      // No selection or no carets: comment current line(s)
      for i := 0 to e.Text.Carets.Count - 1 do begin
        LineIdx := e.Text.Carets[i].PosY;
        if (LineIdx >= 0) and (LineIdx < e.Text.Strings.Count) then begin
          LineText := AnsiString(e.Text.Strings.Lines[LineIdx]);
          e.Text.Strings.Lines[LineIdx] := UnicodeString('//' + LineText);
        end;
      end;
      e.Text.Invalidate;
    end else begin
      // Has selection: comment each line
      Lines := TStringList.Create;
      try
        Lines.Text := SelText;
        // Remove trailing empty line if original had no trailing newline
        if (Length(SelText) > 0) and (SelText[Length(SelText)] <> #10) and (Lines.Count > 0) and
           (Lines[Lines.Count - 1] = '') then
          Lines.Delete(Lines.Count - 1);
        for i := 0 to Lines.Count - 1 do begin
          Lines[i] := '//' + Lines[i];
        end;
        NewText := Lines.Text;
        // TStringList.Text always appends a trailing LineEnding (#13#10 on Windows).
        // Remove it if the original SelText did not end with a line break.
        if (Length(SelText) > 0) and (SelText[Length(SelText)] <> #10) and (Length(NewText) > 0) and
           (NewText[Length(NewText)] = #10) then begin
          if (Length(NewText) >= 2) and (NewText[Length(NewText) - 1] = #13) then
            Delete(NewText, Length(NewText) - 1, 2)  // Remove trailing CRLF
          else
            Delete(NewText, Length(NewText), 1);      // Remove trailing LF only
        end;
      finally
        Lines.Free;
      end;
      // Replace selection with commented text
      e.Text.DoCommand(cCommand_TextInsert, TATCommandInvoke(0), UnicodeString(NewText));
    end;
  end;
end;

procedure TMainForm.actUncommentExecute(Sender: TObject);
var
  e: TEditor;
  SelText, NewText, LineText: String;
  Lines: TStringList;
  i, LineIdx, CommentLen: integer;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    SelText := String(e.Text.TextSelected);
    if (SelText = '') or (e.Text.Carets.Count = 0) then begin
      // No selection: uncomment current line(s)
      for i := 0 to e.Text.Carets.Count - 1 do begin
        LineIdx := e.Text.Carets[i].PosY;
        if (LineIdx >= 0) and (LineIdx < e.Text.Strings.Count) then begin
          LineText := AnsiString(e.Text.Strings.Lines[LineIdx]);
          // Find position of // after leading whitespace
          CommentLen := 0;
          while (CommentLen + 1 <= Length(LineText)) and CharInSet(LineText[CommentLen + 1], [#9, ' ']) do
            Inc(CommentLen);
          if Copy(LineText, CommentLen + 1, 2) = '//' then
            e.Text.Strings.Lines[LineIdx] := UnicodeString(Copy(LineText, 1, CommentLen) + Copy(LineText, CommentLen + 3, MaxInt));
        end;
      end;
      e.Text.Invalidate;
    end else begin
      // Has selection: uncomment each line
      Lines := TStringList.Create;
      try
        Lines.Text := SelText;
        // Remove trailing empty line if needed
        if (Length(SelText) > 0) and (SelText[Length(SelText)] <> #10) and (Lines.Count > 0) and
           (Lines[Lines.Count - 1] = '') then
          Lines.Delete(Lines.Count - 1);
        for i := 0 to Lines.Count - 1 do begin
          LineText := Lines[i];
          CommentLen := 0;
          while (CommentLen + 1 <= Length(LineText)) and CharInSet(LineText[CommentLen + 1], [#9, ' ']) do
            Inc(CommentLen);
          if Copy(LineText, CommentLen + 1, 2) = '//' then
            Lines[i] := Copy(LineText, 1, CommentLen) + Copy(LineText, CommentLen + 3, MaxInt);
        end;
        NewText := Lines.Text;
        // TStringList.Text always appends a trailing LineEnding (#13#10 on Windows).
        // Remove it if the original SelText did not end with a line break.
        if (Length(SelText) > 0) and (SelText[Length(SelText)] <> #10) and (Length(NewText) > 0) and
           (NewText[Length(NewText)] = #10) then begin
          if (Length(NewText) >= 2) and (NewText[Length(NewText) - 1] = #13) then
            Delete(NewText, Length(NewText) - 1, 2)  // Remove trailing CRLF
          else
            Delete(NewText, Length(NewText), 1);      // Remove trailing LF only
        end;
      finally
        Lines.Free;
      end;
      e.Text.DoCommand(cCommand_TextInsert, TATCommandInvoke(0), UnicodeString(NewText));
    end;
  end;
end;

procedure TMainForm.actToggleBookmarkExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    e.ToggleBookmark;
end;

procedure TMainForm.actToggleCommentExecute(Sender: TObject);
var
  e: TEditor;
  SelText, NewText, LineText: String;
  Lines: TStringList;
  i, CommentLen: integer;
  AllCommented: boolean;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    SelText := String(e.Text.TextSelected);
    if SelText = '' then begin
      // No selection: toggle comment on current line
      LineText := AnsiString(e.Text.Strings.Lines[e.Text.Carets[0].PosY]);
      CommentLen := 0;
      while (CommentLen + 1 <= Length(LineText)) and CharInSet(LineText[CommentLen + 1], [#9, ' ']) do
        Inc(CommentLen);
      if Copy(LineText, CommentLen + 1, 2) = '//' then
        e.Text.Strings.Lines[e.Text.Carets[0].PosY] := UnicodeString(Copy(LineText, 1, CommentLen) + Copy(LineText, CommentLen + 3, MaxInt))
      else
        e.Text.Strings.Lines[e.Text.Carets[0].PosY] := UnicodeString('//' + Copy(LineText, 1, CommentLen) +  Copy(LineText, CommentLen + 1, MaxInt));
    end else begin
      // Has selection: check if all lines are commented
      Lines := TStringList.Create;
      try
        Lines.Text := SelText;
        if (Length(SelText) > 0) and (SelText[Length(SelText)] <> #10) and (Lines.Count > 0) and
           (Lines[Lines.Count - 1] = '') then
          Lines.Delete(Lines.Count - 1);

        // Check if ALL lines start with //
        AllCommented := True;
        for i := 0 to Lines.Count - 1 do begin
          LineText := TrimLeft(Lines[i]);
          if Copy(LineText, 1, 2) <> '//' then begin
            AllCommented := False;
            Break;
          end;
        end;

        // Toggle
        for i := 0 to Lines.Count - 1 do begin
          LineText := Lines[i];
          CommentLen := 0;
          while (CommentLen + 1 <= Length(LineText)) and CharInSet(LineText[CommentLen + 1], [#9, ' ']) do
            Inc(CommentLen);
          if AllCommented then begin
            // Uncomment
            if Copy(LineText, CommentLen + 1, 2) = '//' then
              Lines[i] := Copy(LineText, 1, CommentLen) + Copy(LineText, CommentLen + 3, MaxInt);
          end else begin
            // Comment
            Lines[i] := '//' + Copy(LineText, 1, CommentLen) + Copy(LineText, CommentLen + 1, MaxInt);
            LineText := Lines[i];  //debug
          end;
        end;

        NewText := Lines.Text;
        // TStringList.Text always appends a trailing LineEnding (#13#10 on Windows).
        // Remove it if the original SelText did not end with a line break.
        if (Length(SelText) > 0) and (SelText[Length(SelText)] <> #10) and (Length(NewText) > 0) and
           (NewText[Length(NewText)] = #10) then begin
          if (Length(NewText) >= 2) and (NewText[Length(NewText) - 1] = #13) then
            Delete(NewText, Length(NewText) - 1, 2)  // Remove trailing CRLF
          else
            Delete(NewText, Length(NewText), 1);      // Remove trailing LF only
        end;
      finally
        Lines.Free;
      end;
      e.Text.DoCommand(cCommand_TextInsert, TATCommandInvoke(0), UnicodeString(NewText));
    end;
    e.Text.Update(true,true, false, false);
  end;
end;

procedure TMainForm.actIndentExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    e.IndentSelection;
end;

procedure TMainForm.actUnindentExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    e.UnindentSelection;
end;

procedure TMainForm.EditorPageControlLeftDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  I: integer;
  SenderPageControl: TPageControl;
begin
  SenderPageControl := TPageControl(Sender);
  I := SenderPageControl.IndexOfTabAt(X, Y);
  if (Source is TTabSheet) and (I <> SenderPageControl.ActivePageIndex) then
    SenderPageControl.Pages[SenderPageControl.ActivePageIndex].PageIndex := I;
end;

procedure TMainForm.EditorPageControlLeftDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept:
  Boolean);
var
  I: integer;
  SenderPageControl: TPageControl;
begin
  SenderPageControl := TPageControl(Sender);
  I := SenderPageControl.IndexOfTabAt(X, Y);
  Accept := (Source is TTabSheet) and (I <> SenderPageControl.ActivePageIndex);
end;

procedure TMainForm.actGotoFunctionExecute(Sender: TObject);
var
  e: TEditor;
  st: PStatement;
begin
  e := fEditorList.GetEditor;
  if not Assigned(e) then
    Exit;

  with TFunctionSearchForm.Create(Self) do try

    fFileName := AnsiString(e.FileName);
    fParser := CppParser;

    if ShowModal = mrOK then begin
      st := PStatement(lvEntries.Selected.Data);
      if Assigned(st) then begin
        if st^._HasDefinition then
          e.SetCaretPosAndActivate(st^._DefinitionLine, 1)
        else
          e.SetCaretPosAndActivate(st^._Line, 1);
      end;
    end;
  finally
    Free;
  end;
end;

procedure TMainForm.actBrowserGotoDeclarationUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(BrowserView.Selected);
end;

procedure TMainForm.actBrowserGotoDefinitionUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(BrowserView.Selected);
end;

procedure TMainForm.actBrowserNewClassUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(fProject);
end;

procedure TMainForm.actBrowserNewMemberUpdate(Sender: TObject);
begin
  if Assigned(BrowserView.Selected) and Assigned(BrowserView.Selected.Data) then
    TCustomAction(Sender).Enabled := (PStatement(BrowserView.Selected.Data)^._Kind = skClass)
  else
    TCustomAction(Sender).Enabled := False;
end;

procedure TMainForm.actBrowserNewVarUpdate(Sender: TObject);
begin
  if Assigned(BrowserView.Selected) and Assigned(BrowserView.Selected.Data) then
    TCustomAction(Sender).Enabled := (PStatement(BrowserView.Selected.Data)^._Kind = skClass)
  else
    TCustomAction(Sender).Enabled := False;
end;

procedure TMainForm.actBrowserViewAllUpdate(Sender: TObject);
begin
  TCustomAction(Sender).Enabled := True;
end;

procedure TMainForm.actBrowserGotoDeclarationExecute(Sender: TObject);
var
  Member: TClassMember;
  e: TEditor;
begin
  if Assigned(BrowserView.Selected) then begin
    Member := TClassMember(BrowserView.Selected.Data);
    if Assigned(Member) then begin
      e := fEditorList.GetEditorFromFilename(Member.FileName);
      if Assigned(e) then
        e.SetCaretPosAndActivate(Member.Line, 1);
    end;
  end;
end;
{
var
  Editor: TEditor;
  Node: TTreeNode;
  FileName: String;
  Line: integer;
  Statement: PStatement;
begin
  Node := BrowserView.Selected;
  Statement := PStatement(Node.Data);
  FileName := Statement^._FileName;
  Line := Statement^._Line;
  Editor := fEditorList.GetEditorFromFileName(FileName);
  if Assigned(Editor) then begin
    Editor.SetCaretPosAndActivate(Line, 1);
  end;
end;
}
procedure TMainForm.actBrowserGotoDefinitionExecute(Sender: TObject);

var
  Member: TClassMember;
  e: TEditor;
begin
  if Assigned(BrowserView.Selected) then begin
    Member := TClassMember(BrowserView.Selected.Data);
    if Assigned(Member) then begin
      e := fEditorList.GetEditorFromFilename(Member.DefinitionFileName);
      if Assigned(e) then
        e.SetCaretPosAndActivate(Member.DefinitionLine, 1);
    end;
  end;
end;
{
var
  Editor: TEditor;
  Node: TTreeNode;
  FileName: String;
  Line: integer;
  Statement: PStatement;
begin
  Node := BrowserView.Selected;
  Statement := PStatement(Node.Data);
  FileName := Statement^._DefinitionFileName;
  Line := Statement^._DefinitionLine;
  Editor := fEditorList.GetEditorFromFileName(FileName);
  if Assigned(Editor) then begin
    Editor.SetCaretPosAndActivate(Line, 1);
  end;
end;
}


procedure TMainForm.actBrowserNewClassExecute(Sender: TObject);
begin
  with TNewClassForm.Create(Self) do try
    ShowModal;
  finally
    Close;
  end;
end;

procedure TMainForm.actBrowserNewMemberExecute(Sender: TObject);
begin
  with TNewFunctionForm.Create(Self) do try
    ShowModal;
  finally
    Close;
  end;
end;

procedure TMainForm.actBrowserNewVarExecute(Sender: TObject);
begin
  with TNewVarForm.Create(Self) do try
    ShowModal;
  finally
    Close;
  end;
end;

procedure TMainForm.actBrowserViewAllExecute(Sender: TObject);
var
  e: TEditor;
begin
  ClassBrowser.ShowFilter := sfAll;
  actBrowserViewAll.Checked := True;
  actBrowserViewProject.Checked := False;
  actBrowserViewCurrent.Checked := False;
  actBrowserViewIncludes.Checked := False;
  e := fEditorList.GetEditor;
  if Assigned(e) then
    ClassBrowser.CurrentFile := AnsiString(e.FileName)
  else
    ClassBrowser.CurrentFile := '';
  devClassBrowsing.ShowFilter := Ord(ClassBrowser.ShowFilter);
  ClassBrowser.UpdateFromParser(CppParser);
end;

procedure TMainForm.actBrowserViewProjectExecute(Sender: TObject);
var
  e: TEditor;
begin
  ClassBrowser.ShowFilter := sfProject;
  actBrowserViewAll.Checked := False;
  actBrowserViewProject.Checked := True; //
  actBrowserViewCurrent.Checked := False;
  actBrowserViewIncludes.Checked := False;
  e := fEditorList.GetEditor;
  if Assigned(e) then
    ClassBrowser.CurrentFile := AnsiString(e.FileName)
  else
    ClassBrowser.CurrentFile := '';
  devClassBrowsing.ShowFilter := Ord(ClassBrowser.ShowFilter);
  ClassBrowser.UpdateFromParser(CppParser);
end;

procedure TMainForm.actBrowserViewCurrentExecute(Sender: TObject);
var
  e: TEditor;
begin
  ClassBrowser.ShowFilter := sfCurrent;
  actBrowserViewAll.Checked := False;
  actBrowserViewProject.Checked := False;
  actBrowserViewCurrent.Checked := True;
  actBrowserViewIncludes.Checked := False;
  e := fEditorList.GetEditor;
  if Assigned(e) then
    ClassBrowser.CurrentFile := AnsiString(e.FileName)
  else
    ClassBrowser.CurrentFile := '';
  devClassBrowsing.ShowFilter := Ord(ClassBrowser.ShowFilter);
  ClassBrowser.UpdateFromParser(CppParser);
end;

procedure TMainForm.actBrowserViewIncludesExecute(Sender: TObject);
var
  e: TEditor;
begin
  ClassBrowser.ShowFilter := sfSystemFiles;
  actBrowserViewAll.Checked := False;
  actBrowserViewProject.Checked := False;
  actBrowserViewCurrent.Checked := False;
  actBrowserViewIncludes.Checked := True;
  e := fEditorList.GetEditor;
  if Assigned(e) then
    ClassBrowser.CurrentFile := AnsiString(e.FileName)
  else
    ClassBrowser.CurrentFile := '';
  devClassBrowsing.ShowFilter := Ord(ClassBrowser.ShowFilter);
  ClassBrowser.UpdateFromParser(CppParser);
end;

procedure TMainForm.actBrowserShowInheritedExecute(Sender: TObject);
begin
  actBrowserShowInherited.Checked := not actBrowserShowInherited.Checked;
  devClassBrowsing.ShowInheritedMembers := actBrowserShowInherited.Checked;
  ClassBrowser.ShowInheritedMembers := actBrowserShowInherited.Checked;
  BrowserView.Refresh;
end;

procedure TMainForm.actProfileExecute(Sender: TObject);
var
  ProfilingEnabled, StripEnabled: boolean;
  path: String;
  e: TEditor;
begin
  case GetCompileTarget of
    ctProject: begin
        // Check if we enabled proper options
        ProfilingEnabled := fProject.GetCompilerOption('-pg') <> '0';
        StripEnabled := fProject.GetCompilerOption('-s') <> '0';

        // Ask the user if he wants to enable profiling
        if (not ProfilingEnabled or StripEnabled) and (MessageDlg(Lang[ID_MSG_NOPROFILE], mtConfirmation, [mbYes, mbNo],
          0) = mrYes) then begin

          // Enable profiling, disable stripping
          fProject.SetCompilerOption('-pg', '1');
          fProject.SetCompilerOption('-no-pie', '1');
          fProject.SetCompilerOption('-s', '0');

          fCompSuccessAction := csaProfile;
          actRebuildExecute(nil);
          Exit;
        end;
      end;
    ctFile: begin
        // Check if we enabled proper options
        with devCompilerSets.CompilationSet do begin
          ProfilingEnabled := GetOption('-pg') <> '0';
          StripEnabled := GetOption('-s') <> '0';
        end;

        if (not ProfilingEnabled or StripEnabled) then begin
          MessageDlg(Lang[ID_MSG_NOPROFILE], mtConfirmation, [mbOK], 0);
          exit;
        end;

        // Ask the user if he wants to enable profiling
//        if (not ProfilingEnabled or StripEnabled) and (MessageDlg(Lang[ID_MSG_NOPROFILE],
//          mtConfirmation, [mbYes, mbNo], 0) = mrYes) then begin
//
//          // Enable profiling, disable stripping
//          with devCompilerSets.CompilationSet do begin
//            SetOption('-pg', '1');
//            SetOption('-s', '0');
//          end;
//
//          // Save changes to compiler set
//          devCompilerSets.SaveSet(devCompilerSets.CompilationSetIndex);
//
//          fCompSuccessAction := csaProfile;
//          actRebuildExecute(nil);
//          Exit;
//        end;
      end;
  end;

  // If we're done setting up options, check if there's profiling data already
  path := '';
  case GetCompileTarget of
    ctProject: begin
        path := ExtractFilePath(fProject.Executable) + GPROF_CHECKFILE;
      end;
    ctFile: begin
        e := fEditorList.GetEditor;
        if Assigned(e) then
          path := ExtractFilePath(ChangeFileExt(AnsiString(e.FileName), EXE_EXT)) + GPROF_CHECKFILE;
      end;
    ctNone: Exit;
  end;

  //Gather data by running our project...
  fRunEndAction := reaProfile;
  if not FileExists(path) then begin
    fRunEndAction := reaProfile;
    actRunExecute(nil);
  end else begin // If the data is there, open up the form
    RunEndProc;
  end;
end;

procedure TMainForm.actCloseAllButThisExecute(Sender: TObject);
begin
//  ClassBrowser.BeginUpdate;
  UpdateBrowserView;

  try
    fEditorList.CloseAllButThis;
  finally
//    ClassBrowser.EndUpdate;
  end;
end;

procedure TMainForm.lvBacktraceCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if not (cdsSelected in State) then begin
    if Assigned(Item.Data) then
      Sender.Canvas.Font.Color := clBlue
    else
      Sender.Canvas.Font.Color := clWindowText;
  end;
end;

procedure TMainForm.lvBacktraceMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  It: TListItem;
begin
  with Sender as TListView do begin
    It := GetItemAt(X, Y);
    if Assigned(It) and Assigned(It.Data) then
      Cursor := crHandPoint
    else
      Cursor := crDefault;
  end;
end;

procedure TMainForm.FileMonitorNotifyChange(Sender: TObject; ChangeType: TdevMonitorChangeType; Filename: string);
var
  e: TEditor;
  p: TPoint;
begin
  // Deactivate monitoring for this file. One message is enough
  FileMonitor.BeginUpdate;
  try
    case ChangeType of
      mctChanged: begin
          Application.Restore;
          if MessageDlg(Format(Lang[ID_ERR_FILECHANGED], [Filename]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
            begin
            e := fEditorList.GetEditorFromFileName(Filename);
            if Assigned(e) then begin
              p.X := e.Text.Carets[0].PosX;
              p.Y := e.Text.Carets[0].PosY;
              e.Text.Strings.LoadFromFile(Filename, []);
              if (p.Y < e.Text.Strings.Count) then begin
                e.Text.Carets[0].PosX := p.X;
                e.Text.Carets[0].PosY := p.Y;
              end;
            end;
          end;
        end;
      mctDeleted: begin
          Application.Restore;
          case MessageDlg(Format(Lang[ID_ERR_RENAMEDDELETEDKEEP], [Filename]), mtInformation, [mbYes, mbNo], 0) of
            mrYes: begin
                e := fEditorList.FileIsOpen(Filename);
                if Assigned(e) then begin
                  e.Text.Modified := True;
                  e.Modified := True;
                end;
              end;
            mrNo: begin
                e := fEditorList.FileIsOpen(Filename);
                if Assigned(e) then
                  fEditorList.CloseEditor(e);
              end;
          end;
        end;
    end;
  finally
    FileMonitor.EndUpdate;
  end;
end;

procedure TMainForm.actFilePropertiesExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  e.Save;   //save file before check its property
  with TFilePropertiesForm.Create(Self) do begin
    if TAction(Sender).ActionComponent = mnuUnitProperties then
      if Assigned(fProject) and
        Assigned(ProjectView.Selected) and
        (ProjectView.Selected.Data <> Pointer(-1)) then
        SetFile(fProject.Units[integer(ProjectView.Selected.Data)].FileName);
    ShowModal;
  end;
end;

procedure TMainForm.actViewToDoListExecute(Sender: TObject);
begin
  TViewToDoForm.Create(Self).ShowModal;
end;

procedure TMainForm.actAddToDoExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if not Assigned(e) then Exit;
  with TAddToDoForm.Create(Application) do begin
    if ShowModal = mrOk then
      e.InsertString(fInsertionText, TRUE);
    Free;
  end;
end;

procedure TMainForm.actProjectNewFolderExecute(Sender: TObject);
var
  fp, S: String;
begin
  S := 'New folder';
  if InputQuery(Lang[ID_POP_ADDFOLDER], Lang[ID_MSG_ADDBROWSERFOLDER], S) and (S <> '') then begin
    fp := fProject.GetFolderPath(ProjectView.Selected);
    if fp <> '' then
      fProject.AddFolder(fp + '/' + S)
    else
      fProject.AddFolder(S);
  end;
end;

procedure TMainForm.actProjectRemoveFolderExecute(Sender: TObject);
begin
  // Useless check...
  if not Assigned(fProject) then
    exit;

  // Check if the current item is a folder
  if Assigned(ProjectView.Selected) and (ProjectView.Selected.Data = Pointer(-1)) then

    // Ask if we want to remove...
    if MessageDlg(Lang[ID_MSG_REMOVEBROWSERFOLDER], mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
      ProjectView.Items.BeginUpdate;
      try
        fProject.RemoveFolder(ProjectView.Selected);
      finally
        ProjectView.Items.EndUpdate;
      end;
    end;
end;

procedure TMainForm.actProjectRenameFolderExecute(Sender: TObject);
var
  S: String;
begin
  if Assigned(ProjectView.Selected) and (ProjectView.Selected.Data = Pointer(-1)) then begin
    S := ProjectView.Selected.Text;
    if InputQuery(Lang[ID_POP_RENAMEFOLDER], Lang[ID_MSG_RENAMEBROWSERFOLDER], S) and (S <> '') then begin
      ProjectView.Selected.Text := S;
      fProject.UpdateFolders;
    end;
  end;
end;

{ begin XXXKF changed }

procedure TMainForm.ProjectViewDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  Item: TTreeNode;
  Hits: THitTests;
begin
  Hits := ProjectView.GetHitTestInfoAt(X, Y);
  if ([htOnItem, htOnRight, htToRight] * Hits) <> [] then
    Item := ProjectView.GetNodeAt(X, Y)
  else
    Item := nil;
  Accept :=
    (
    (Sender = ProjectView) and Assigned(ProjectView.Selected) and Assigned(Item) //and
    // drop node is a folder or the project
    and ((Item.Data = Pointer(-1)) or (Item.SelectedIndex = 0))
    );
end;

procedure TMainForm.ProjectViewDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  Item: TTreeNode;
  srcNode: TTreeNode;
  WasExpanded: Boolean;
  I: integer;
begin
  if not (Source is TTreeView) then
    exit;
  if ([htOnItem, htOnRight, htToRight] * ProjectView.GetHitTestInfoAt(X, Y)) <> [] then
    Item := ProjectView.GetNodeAt(X, Y)
  else
    Item := nil;
  for I := 0 to ProjectView.SelectionCount - 1 do begin
    srcNode := ProjectView.Selections[I];
    if not Assigned(Item) then begin
      fProject.Units[Integer(srcNode.Data)].Folder := '';
      srcNode.MoveTo(ProjectView.Items[0], naAddChild);
    end else begin
      if srcNode.Data <> Pointer(-1) then begin
        if Item.Data = Pointer(-1) then
          fProject.Units[Integer(srcNode.Data)].Folder := fProject.GetFolderPath(Item)
        else
          fProject.Units[Integer(srcNode.Data)].Folder := '';
      end;
      WasExpanded := Item.Expanded;
      ProjectView.Items.BeginUpdate;
      srcNode.MoveTo(Item, naAddChild);
      if not WasExpanded then
        Item.Collapse(False);
      Item.AlphaSort;
      ProjectView.Items.EndUpdate;

      fProject.UpdateFolders;
    end;
  end;
end;

procedure TMainForm.actImportMSVCExecute(Sender: TObject);
begin
  with TImportMSVCForm.Create(Self) do begin
    if ShowModal = mrOK then
      OpenProject(GetFilename);
  end;
end;

procedure TMainForm.ViewCPUItemClick(Sender: TObject);
begin
  if not Assigned(CPUForm) then begin
    CPUForm := TCPUForm.Create(self);
    CPUForm.Show;
  end;
end;



procedure TMainForm.cmbGdbCommandKeyPress(Sender: TObject; var Key: Char);
begin
  if fDebugger.Executing then begin
    if Key = Chr(VK_RETURN) then begin
      if Length(cmbGdbCommand.Text) > 0 then begin

        // Disable key, but make sure not to remove selected text
        EvaluateInput.SelStart := 0;
        EvaluateInput.SelLength := 0;
        Key := #0;

        fDebugger.SendCommand(cmbGdbCommand.Text, '', true);

        if cmbGdbCommand.Items.IndexOf(cmbGdbCommand.Text) = -1 then
          cmbGdbCommand.AddItem(cmbGdbCommand.Text, nil);
      end;
    end;

    // View command examples only when edit is empty or when the UI itself added the current command
    fDebugger.CommandChanged := true;
    cmbGdbCommand.SetFocus;
  end;
end;

procedure TMainForm.cmbGdbCommandSelect(Sender: TObject);
begin
  if Length(cmbGdbCommand.Text) > 0 then begin
    fDebugger.SendCommand(cmbGdbCommand.Text, '', true);
  end;
end;

procedure TMainForm.CheckForDLLProfiling;
var
  prof: boolean;
begin
  if not Assigned(fProject) then
    Exit;

  // If this is a DLL / static link library project, then check for profiling
  if (fProject.Options.typ in [dptDyn, dptStat]) then begin

    // Check if profiling is enabled
    prof := fProject.GetCompilerOption('-pg') <> '0';

    // Check for the existence of "-lgmon" in project's linker options
    if prof and (Pos('-lgmon', fProject.Options.LinkerCmd) = 0) then begin

      // Warn the user that we should update its project options and include
      // -lgmon in linker options, or else the compilation will fail
      if MessageDlg('You have profiling enabled in Compiler Options and you are ' +
        'working on a dynamic or static library. Do you want to add a special ' +
        'linker option in your project to allow compilation with profiling enabled? ' +
        'If you choose No, and you do not disable profiling from the Compiler Options ' +
        'chances are that your library''s compilation will fail...', mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
        fProject.Options.LinkerCmd := fProject.Options.LinkerCmd + ' -lgmon';
        fProject.Modified := True;
      end;
    end;
  end;
end;

procedure TMainForm.actExecParamsExecute(Sender: TObject);
begin
  with TParamsForm.Create(self) do try
    case GetCompileTarget of
      ctNone, ctFile:
        ParamEdit.Text := fCompiler.RunParams;
      ctProject: begin
          HostEdit.Text := fProject.Options.HostApplication;
          ParamEdit.Text := fProject.Options.CmdLineArgs;
        end;
    end;
    if not Assigned(fProject) or (fProject.Options.typ <> dptDyn) then
      DisableHost;
    if (ShowModal = mrOk) then begin
      case GetCompileTarget of
        ctNone, ctFile:
          fCompiler.RunParams := ParamEdit.Text;
        ctProject: begin
            if (HostEdit.Enabled) then
              fProject.Options.HostApplication := HostEdit.Text;
            fProject.Options.CmdLineArgs := ParamEdit.Text;
            fProject.Modified := true;
          end;
      end;
    end;
  finally
    Free;
  end;
end;

procedure TMainForm.actHelpTipsExecute(Sender: TObject);
begin
  with TTipOfTheDayForm.Create(Self) do
    ShowModal;
end;

procedure TMainForm.CppParserStartParsing(Sender: TObject);
var
  e: TEditor;
begin
  // Update UI before the parser starts working
  Application.ProcessMessages;

  // Loading...
  Screen.Cursor := crHourglass;

  // Pause updating the class browser (which will be invalidated)
//  ClassBrowser.BeginUpdate;
  UpdateBrowserView;

  // Hide anything that uses the database (which will be invalidated)
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    e.FunctionTip.ReleaseHandle;
    e.CompletionBox.Hide;
  end;

  fParseStartTime := GetTickCount;
end;

procedure TMainForm.CppParserTotalProgress(Sender: TObject; const FileName: ansistring; Total, Current: Integer);
var
  ShowStep: Integer;
begin
  // Mention every 5% progress
  ShowStep := Total div 20;

  // For Total = 1, avoid division by zero
  if ShowStep = 0 then
    ShowStep := 1;

  // Only show if needed (it's a very slow operation)
  if (Current mod ShowStep = 0) or (Current = 1) then begin
    SetStatusBarMessage(Format(Lang[ID_PARSINGFILECOUNT], [Current, Total, Filename]));
    Application.ProcessMessages;
  end;
end;

procedure TMainForm.CppParserEndParsing(Sender: TObject; Total: Integer);
var
  ParseTimeFloat, ParsingFrequency: Extended;
begin
  Screen.Cursor := crDefault;

  // Done. Rebuild stuff that uses the database
  RebuildClassesToolbar;

  // The class browser can redraw again
//  ClassBrowser.EndUpdate;

  // do this work only if this was the last file scanned
  ParseTimeFloat := (GetTickCount - fParseStartTime) / 1000;
  if Total > 1 then begin
    if ParseTimeFloat <> 0 then
      ParsingFrequency := Total / ParseTimeFloat
    else
      ParsingFrequency := 999;
    SetStatusbarMessage(Format(Lang[ID_DONEPARSINGINCOUNT], [Total, ParseTimeFloat, ParsingFrequency]))
  end else
    SetStatusbarMessage(Format(Lang[ID_DONEPARSINGIN], [ParseTimeFloat]));
end;

procedure TMainForm.UpdateAppTitle;
var
  e: TEditor;
begin
  if Assigned(fProject) then begin
    if fDebugger.Executing then begin
      Caption := Format('%s - [%s] - [Debugging] - %s %s',
        [fProject.Name, ExtractFilename(fProject.Filename), DEVCPP, DEVCPP_VERSION]);
      Application.Title := Format('%s - [Debugging] - %s', [fProject.Name, DEVCPP]);
    end else if devExecutor.Running then begin
      Caption := Format('%s - [%s] - [Executing] - %s %s',
        [fProject.Name, ExtractFilename(fProject.Filename), DEVCPP, DEVCPP_VERSION]);
      Application.Title := Format('%s - [Executing] - %s', [fProject.Name, DEVCPP]);
    end else if fCompiler.Compiling then begin
      Caption := Format('%s - [%s] - [Compiling] - %s %s',
        [fProject.Name, ExtractFilename(fProject.Filename), DEVCPP, DEVCPP_VERSION]);
      Application.Title := Format('%s - [Compiling] - %s', [fProject.Name, DEVCPP]);
    end else begin
      Caption := Format('%s - [%s] - %s %s',
        [fProject.Name, ExtractFilename(fProject.Filename), DEVCPP, DEVCPP_VERSION]);
      Application.Title := Format('%s - %s', [fProject.Name, DEVCPP]);
    end;
  end else begin
    e := fEditorList.GetEditor;
    if Assigned(e) then begin
      if fDebugger.Executing then begin
        Caption := Format('%s - [Debugging] - %s %s', [e.FileName, DEVCPP, DEVCPP_VERSION]);
        Application.Title := Format('%s - [Debugging] - %s', [ExtractFileName(e.FileName), DEVCPP]);
      end else if devExecutor.Running then begin
        Caption := Format('%s - [Executing] - %s %s', [e.FileName, DEVCPP, DEVCPP_VERSION]);
        Application.Title := Format('%s - [Executing] - %s', [ExtractFileName(e.FileName), DEVCPP]);
      end else if fCompiler.Compiling then begin
        Caption := Format('%s - [Compiling] - %s %s', [e.FileName, DEVCPP, DEVCPP_VERSION]);
        Application.Title := Format('%s - [Compiling] - %s', [ExtractFileName(e.FileName), DEVCPP]);
      end else begin
        Caption := Format('%s - %s %s', [e.FileName, DEVCPP, DEVCPP_VERSION]);
        Application.Title := Format('%s - %s', [ExtractFileName(e.FileName), DEVCPP]);
      end;
    end else begin
      Caption := Format('%s %s', [DEVCPP, DEVCPP_VERSION]);
      Application.Title := Format('%s', [DEVCPP]);
    end;
  end;
end;

procedure TMainForm.actAbortCompilationUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := fCompiler.Compiling;
end;

procedure TMainForm.actAbortCompilationExecute(Sender: TObject);
begin
  fCompiler.AbortThread;
end;

{ begin XXXKF }

procedure TMainForm.actWindowMenuExecute(Sender: TObject);
var
  Item: TMenuItem;
  E: TEditor;
  i: integer;
  Act: TAction;
begin
  // Remove old items
  while WindowMenu.Count > 8 do begin
    Item := WindowMenu.Items[7];
    WindowMenu.Remove(Item);
    Item.Destroy;
  end;

  // Add new items, 9 at most
  for i := 0 to min(9, pred(EditorList.PageCount)) do begin
    e := fEditorList[i];
    if Assigned(e) then begin
      Item := TMenuItem.Create(self);

      // Create an action that executes when clicking on the item
      Act := TAction.Create(Item);
      Act.Name := 'dynactOpenEditorByTag';
      Act.Tag := PtrInt(e);
      Act.OnExecute := @actOpenEditorByTagExecute;

      // Attach it to the new menu item
      Item.Action := Act;
      Item.Caption := '&' + IntToStr(i) + ' ' + AnsiString(e.FileName);
      //if e.Text.Modified then
      if e.Modified then
        Item.Caption := Item.Caption + ' *';
      WindowMenu.Insert(WindowMenu.Count - 1, Item);
    end;
  end;
end;

procedure TMainForm.RemoveItem(Node: TTreeNode);
begin
  if Assigned(Node) and (Node.Level >= 1) then begin
    if Node.Data = Pointer(-1) then
      actProjectRemoveFolderExecute(nil)
    else
      fProject.RemoveEditor(integer(Node.Data), true);
  end;
end;

procedure TMainForm.ProjectViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_DELETE) and Assigned(ProjectView.Selected) then
    RemoveItem(ProjectView.Selected)
  else if (Key = VK_ESCAPE) and (Shift = []) then begin
    if (EditorList.PageCount > 0) then
      fEditorList.GetEditor(-1).Activate;
  end else if (Key = VK_ESCAPE) and (Shift = [ssShift]) then begin
    actProjectManager.Checked := False;
    actProjectManagerExecute(nil);
    if (EditorList.PageCount > 0) then
      fEditorList.GetEditor(-1).Activate;
  end else if (Key = VK_RETURN) and Assigned(ProjectView.Selected) then begin
    if ProjectView.Selected.Data <> Pointer(-1) then begin { if not a directory }
      OpenUnit;
      if Shift = [ssShift] then begin
        {
         crap hack, SHIFT+ENTER=open file and close projman
         I *really* don't think it's the acceptable interface idea.
         Can't find a better one though.
        }
        actProjectManager.Checked := False;
        actProjectManagerExecute(nil);
      end;
    end;
  end;
end;

procedure TMainForm.ProjectViewChanging(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
begin
  Node.MakeVisible;
end;

procedure TMainForm.actOpenEditorByTagExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditorFromTag(TAction(Sender).Tag);
  if Assigned(e) then
    e.Activate;
end;

{ end XXXKF }

procedure TMainForm.actPrevBookmarkExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
	  e.GotoPrevBookmark;
end;

procedure TMainForm.actGotoProjectManagerExecute(Sender: TObject);
begin
  if not actProjectManager.Checked then begin
    actProjectManager.Checked := True;
    actProjectManagerExecute(nil);
  end;
  LeftPageControl.ActivePageIndex := 0;
  ProjectView.SetFocus;
end;

procedure TMainForm.ListItemClick(Sender: TObject);
var
  I: integer;
  e: TEditor;
  item: TListItem;
begin
  with TWindowListForm.Create(self) do try
    // Fill here instead of in Window itself?
    UnitList.Items.BeginUpdate;
    try
      for I := 0 to fEditorList.PageCount - 1 do begin
        e := fEditorList[i];

        item := UnitList.Items.Add;
        item.Caption := AnsiString(ExtractFileName(e.FileName));
        item.SubItems.Add(AnsiString(e.FileName));
      end;
    finally
      UnitList.Items.EndUpdate;
    end;

    if (ShowModal = mrOk) and (UnitList.ItemIndex <> -1) then begin
      e := fEditorList[UnitList.ItemIndex];
      if Assigned(e) then
        e.Activate;
    end;
  finally
    Close;
  end;
end;

procedure TMainForm.ProjectViewCompare(Sender: TObject; Node1,
  Node2: TTreeNode; Data: Integer; var Compare: Integer);
begin
  if (Node1.Data = pointer(-1)) and (Node2.Data = pointer(-1)) then
    Compare := CompareStr(Node1.Text, Node2.Text)
  else if Node1.Data = pointer(-1) then
    Compare := -1
  else if Node2.Data = pointer(-1) then
    Compare := +1
  else
    Compare := CompareStr(Node1.Text, Node2.Text);
end;

procedure TMainForm.ProjectViewKeyPress(Sender: TObject; var Key: Char);
begin
  // fixs an annoying bug/behavior of the tree ctrl (a beep on enter key)
  if Key = #13 then
    Key := #0;
end;

procedure TMainForm.ProjectViewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  // bug-fix: when *not* clicking on an item, re-opens the last clicked file-node
  // this was introduced in the latest commit by XXXKF (?)
  if (Button = mbLeft) and not (htOnItem in ProjectView.GetHitTestInfoAt(X, Y)) then
    ProjectView.Selected := nil;
end;

procedure TMainForm.GoToClassBrowserItemClick(Sender: TObject);
begin
  if not actProjectManager.Checked then begin
    actProjectManager.Checked := True;
    actProjectManagerExecute(nil);
  end;
  LeftPageControl.ActivePageIndex := 1;
  if BrowserView.Visible then
    BrowserView.SetFocus;
end;


procedure TMainForm.ProjectWindowClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
  FloatingPojectManagerItem.Checked := False;
  LeftPageControl.Visible := false;
  (Sender as TForm).RemoveControl(LeftPageControl);

  LeftPageControl.Left := 0;
  LeftPageControl.Top := ToolbarDock.Height;
  LeftPageControl.Align := alLeft;
  LeftPageControl.Visible := true;
  InsertControl(LeftPageControl);
  fProjectToolWindow := nil;

  if assigned(fProject) then
    fProject.SetNodeValue(ProjectView.TopItem); // nodes needs to be recreated
end;

procedure TMainForm.ReportWindowClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
  FloatingReportWindowItem.Checked := False;
  MessageControl.Visible := false;
  (Sender as TForm).RemoveControl(MessageControl);

  MessageControl.Left := 0;
  MessageControl.Top := SplitterBottom.Top;
  MessageControl.Align := alBottom;
  MessageControl.Visible := true;
  InsertControl(MessageControl);
  Statusbar.Top := MessageControl.Top + MessageControl.Height;
  fReportToolWindow := nil;
end;

procedure TMainForm.FloatingPojectManagerItemClick(Sender: TObject);
begin
  FloatingPojectManagerItem.Checked := not FloatingPojectManagerItem.Checked;
  if Assigned(fProjectToolWindow) then
    fProjectToolWindow.Close
  else begin
    fProjectToolWindow := TForm.Create(self);
    with fProjectToolWindow do begin
      Caption := Lang[ID_TB_PROJECT];
      Top := self.Top + LeftPageControl.Top;
      Left := self.Left + LeftPageControl.Left;
      Height := LeftPageControl.Height;
      Width := LeftPageControl.Width;
      FormStyle := fsStayOnTop;
      OnClose := @ProjectWindowClose;
      BorderStyle := bsSizeable;
      BorderIcons := [biSystemMenu];
      LeftPageControl.Visible := false;
      self.RemoveControl(LeftPageControl);

      LeftPageControl.Left := 0;
      LeftPageControl.Top := 0;
      LeftPageControl.Align := alClient;
      LeftPageControl.Visible := true;
      fProjectToolWindow.InsertControl(LeftPageControl);

      fProjectToolWindow.Show;
      if assigned(fProject) then
        fProject.SetNodeValue(ProjectView.TopItem); // nodes needs to be recreated
    end;
  end;
end;

procedure TMainForm.actSaveProjectAsExecute(Sender: TObject);
begin
  if not Assigned(fProject) then
    Exit;

  with TSaveDialog.Create(nil) do try

    Filter := FLT_PROJECTS;
    Options := Options + [ofOverwritePrompt];
    Title := Lang[ID_NV_SAVEPROJECT];

    if Execute then begin
      fProject.FileName := FileName;
      fProject.SaveAll;
      UpdateAppTitle;
    end;
  finally
    Free;
  end;
end;

procedure TMainForm.BuildOpenWith;
var
  idx, idx2: integer;
  item: TMenuItem;
  ext, s, s1: String;
begin
  mnuOpenWith.Clear;
  s := '';
  s1 := '';
  if not assigned(fProject) then
    exit;
  if not assigned(ProjectView.Selected) or
    (ProjectView.Selected.Level < 1) then
    exit;
  if ProjectView.Selected.Data = Pointer(-1) then
    Exit;
  idx := integer(ProjectView.Selected.Data);

  ext := ExtractFileExt(fProject.Units[idx].FileName);
  idx2 := devExternalPrograms.AssignedProgram(ext);
  if idx2 <> -1 then begin
    item := TMenuItem.Create(nil);
    item.Caption := ExtractFilename(devExternalPrograms.ProgramName[idx2]);
    item.Tag := idx2;
    item.OnClick := @mnuOpenWithClick;
    mnuOpenWith.Add(item);
  end;
  if GetAssociatedProgram(ext, s, s1) then begin
    item := TMenuItem.Create(nil);
    item.Caption := '-';
    item.Tag := -1;
    item.OnClick := @mnuOpenWithClick;
    mnuOpenWith.Add(item);
    item := TMenuItem.Create(nil);
    item.Caption := s1;
    item.Tag := -1;
    item.OnClick := @mnuOpenWithClick;
    mnuOpenWith.Add(item);
  end;
end;

procedure TMainForm.cbWatchLocalsClick(Sender: TObject);
begin
  devData.WatchLocals := cbWatchLocals.Checked;
  if NOT devData.WatchLocals then
    txtLocals.Lines.Text := '';

end;

procedure TMainForm.mnuOpenWithClick(Sender: TObject);
var
  idx, idx2: integer;
  item: TMenuItem;
  e: TEditor;
begin
  if (Sender = mnuOpenWith) and (mnuOpenWith.Count > 0) then
    Exit;
  if not Assigned(fProject) then
    Exit;
  if not assigned(ProjectView.Selected) or
    (ProjectView.Selected.Level < 1) then
    exit;
  if ProjectView.Selected.Data = Pointer(-1) then
    Exit;
  idx2 := integer(ProjectView.Selected.Data);

  item := TMenuItem(Sender);
  if item = mnuOpenWith then begin
    idx := -2;
    with TOpenDialog.Create(Self) do try
      Filter := FLT_ALLFILES;
      if Execute then
        idx := devExternalPrograms.AddProgram(ExtractFileExt(fProject.Units[idx2].FileName), Filename);
    finally
      Free;
    end;
  end else
    idx := item.Tag;

  e := fEditorList.FileIsOpen(fProject.Units[idx2].FileName, TRUE);
  if Assigned(e) then
    fEditorList.CloseEditor(e);

  if idx > -1 then // devcpp-based
    OpenDocument(fProject.Units[idx2].FileName)
      // idx=-2 means we prompted the user for a program, but didn't select one
  else if idx <> -2 then // registry-based
    OpenDocument(fProject.Units[idx2].FileName);
end;

procedure TMainForm.RebuildClassesToolbar;
var
  Node: PStatementNode;
  Statement: PStatement;
  OldSelection: String;
begin
//  OldSelection := cmbClasses.Text;

//  cmbClasses.Items.BeginUpdate;
//  try
//    cmbClasses.Clear;

    // Add globals list
//    cmbClasses.Items.AddObject('(globals)', nil);

    // Add all classes inside the current project
//    Node := CppParser.Statements.FirstNode;
//    while Assigned(Node) do begin
//      Statement := Node^.Data;
//      if Statement^._InProject and (Statement^._Kind = skClass) then // skClass equals struct + typedef struct + class
//        cmbClasses.Items.AddObject(Statement^._Command, Pointer(Statement));
//      Node := Node^.NextNode;
//    end;

    // if we can't find the old selection anymore (-> -1), default to 0 (globals)
//    cmbClasses.ItemIndex := max(0, cmbClasses.Items.IndexOf(OldSelection));
//    cmbClassesChange(cmbClasses);
//  finally
//    cmbClasses.Items.EndUpdate;
//  end;
end;

procedure TMainForm.cmbClassesChange(Sender: TObject);
var
  Node: PStatementNode;
  Statement, ParentStatement: PStatement;

//  procedure AddStatementKind(AddKind: TStatementKind);
//  begin
//    Node := CppParser.Statements.FirstNode;
//    while Assigned(Node) do begin
//      Statement := Node^.Data;
//      if (Statement^._Parent = ParentStatement) and Statement^._InProject and (Statement^._Kind = AddKind) then
//        cmbMembers.Items.AddObject(CppParser.StatementKindStr(AddKind) + ' ' + Statement^._Command + Statement^._Args +
//          ' : ' + Statement^._Type,
//          Pointer(Statement));
//      Node := Node^.NextNode;
//    end;
//  end;
begin
//  cmbMembers.Items.BeginUpdate;
//  try
//    cmbMembers.Clear;

    // Select what parent we need to display info for
//    if cmbClasses.ItemIndex > 0 then
//      ParentStatement := PStatement(cmbClasses.Items.Objects[cmbClasses.ItemIndex]) // any class
//    else if cmbClasses.ItemIndex = 0 then
//      ParentStatement := nil // '(globals)'
//    else
//      Exit; // -1?

    // Show functions that belong to this scope or class/struct
//    AddStatementKind(skConstructor);
//    AddStatementKind(skDestructor);
//    AddStatementKind(skFunction);
//  finally
//    cmbMembers.Items.EndUpdate;
//  end;
end;

procedure TMainForm.cmbMembersChange(Sender: TObject);
var
  Statement: PStatement;
  Line: Integer;
  e: TEditor;
  FileName: String;
begin
//  if cmbMembers.ItemIndex = -1 then // sometimes happens too?
//    Exit;

//  Statement := PStatement(cmbMembers.Items.Objects[cmbMembers.ItemIndex]);
//  if not Assigned(Statement) then
//    Exit;

  // Go to definition if applicable
//  Line := Statement^._DefinitionLine;
//  FileName := Statement^._DefinitionFileName;

//  e := fEditorList.GetEditorFromFilename(FileName);
//  if Assigned(e) then begin
//    e.SetCaretPosAndActivate(Line, 1);
//  end;
end;

procedure TMainForm.CompilerOutputKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    CompilerOutputDblClick(sender);
end;

procedure TMainForm.CompilerOutputMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Item: TListItem;
  NewIndex, OldIndex: Integer;
  LV: TListView;
  R: TRect;
begin
  LV := TListView(Sender);
  Item := LV.GetItemAt(X, Y);
  if Assigned(Item) then
    NewIndex := Item.Index
  else
    NewIndex := -1;

  if NewIndex <> fCompilerHoverIndex then begin
    OldIndex := fCompilerHoverIndex;
    fCompilerHoverIndex := NewIndex;
    // Only repaint the two rows that changed, not the entire control
    if (OldIndex >= 0) and (OldIndex < LV.Items.Count) then begin
      R := LV.Items[OldIndex].DisplayRect(drBounds);
      InvalidateRect(LV.Handle, @R, LongBool(0));
    end;
    if (NewIndex >= 0) and (NewIndex < LV.Items.Count) then begin
      R := LV.Items[NewIndex].DisplayRect(drBounds);
      InvalidateRect(LV.Handle, @R, LongBool(0));
    end;
  end;
end;

procedure TMainForm.CompilerOutputMouseLeave(Sender: TObject);
var
  OldIndex: Integer;
  LV: TListView;
  R: TRect;
begin
  LV := TListView(Sender);
  OldIndex := fCompilerHoverIndex;
  fCompilerHoverIndex := -1;
  if (OldIndex >= 0) and (OldIndex < LV.Items.Count) then begin
    R := LV.Items[OldIndex].DisplayRect(drBounds);
    InvalidateRect(LV.Handle, @R, LongBool(0));
  end;
end;

procedure TMainForm.FindOutputKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    FindOutputDblClick(sender);
end;

procedure TMainForm.DebugViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
    actRemoveWatchExecute(sender);
end;



procedure TMainForm.DebugPopupPopup(Sender: TObject);
begin
  RemoveWatchPop.Enabled := Assigned(DebugView.Selected);
end;

procedure TMainForm.FloatingReportwindowItemClick(Sender: TObject);
begin
  FloatingReportWindowItem.Checked := not FloatingReportWindowItem.Checked;
  if assigned(fReportToolWindow) then
    fReportToolWindow.Close
  else begin
    OpenCloseMessageSheet(true);
    if MessageControl.ActivePage = CloseSheet then
      MessageControl.ActivePageIndex := 0;
    fReportToolWindow := TForm.Create(self);
    with fReportToolWindow do begin
      Caption := Lang[ID_TB_REPORT];
      Top := self.Top + MessageControl.Top;
      Left := self.Left + MessageControl.Left;
      Height := MessageControl.Height;
      Width := MessageControl.Width;
      FormStyle := fsStayOnTop;
      OnClose := @ReportWindowClose;
      BorderStyle := bsSizeable;
      BorderIcons := [biSystemMenu];
      MessageControl.Visible := false;
      self.RemoveControl(MessageControl);

      MessageControl.Left := 0;
      MessageControl.Top := 0;
      MessageControl.Align := alClient;
      MessageControl.Visible := true;
      fReportToolWindow.InsertControl(MessageControl);

      fReportToolWindow.Show;
    end;
  end;
end;

procedure TMainForm.actAttachProcessUpdate(Sender: TObject);
begin
  if assigned(fProject) and (fProject.Options.typ = dptDyn) then begin
    TCustomAction(Sender).Visible := true;
    TCustomAction(Sender).Enabled := not devExecutor.Running;
  end else
    TCustomAction(Sender).Visible := false;
end;

procedure TMainForm.actAttachProcessExecute(Sender: TObject);
var
  s: String;
begin
  PrepareDebugger;
  if assigned(fProject) then begin
    if not FileExists(fProject.Executable) then begin
      MessageDlg(Lang[ID_ERR_PROJECTNOTCOMPILED], mtWarning, [mbOK], 0);
      exit;
    end;

    try
      ProcessListForm := TProcessListForm.Create(self);
      if (ProcessListForm.ShowModal = mrOK) and (ProcessListForm.ProcessCombo.ItemIndex > -1) then begin
        s := IntToStr(integer(ProcessListForm.ProcessList[ProcessListForm.ProcessCombo.ItemIndex]));

        fDebugger.Start;
        fDebugger.SendCommand('file', '"' + StringReplace(UTF8ToWinCP(fProject.Executable), '\', '\\', [rfReplaceAll]) + '"');
        fDebugger.SendCommand('attach', s);
      end
    finally
      ProcessListForm.Free;
    end;
  end;
end;

//procedure TMainForm.actOutputManagerExecute(Sender: TObject);
//begin
//  //fOutputHeight
//  Statusbar.Top := Self.ClientHeight;
//end;

procedure TMainForm.actModifyWatchExecute(Sender: TObject);
var
  curnode: TTreeNode;
  fullname: String;
  value: String;

  function GetNodeName(node: TTreeNode): String;
  var
    epos: integer;
  begin
    Result := '';
    epos := Pos(' = ', node.Text);
    if epos > 0 then
      Result := Copy(node.Text, 1, epos - 1);
  end;

  function GetNodeValue(node: TTreeNode): String;
  var
    epos: integer;
  begin
    Result := '';
    epos := Pos(' = ', node.Text);
    if epos > 0 then
      Result := Copy(node.Text, epos + 3, Length(node.Text) - epos);
  end;

begin
  curnode := DebugView.Selected;
  if Assigned(curnode) then begin // only edit members

    fullname := GetNodeName(curnode);

    // Assemble full name including parents
    while Assigned(curnode.Parent) do begin
      curnode := curnode.Parent;
      if not StartsStr('{', GetNodeName(curnode)) then
        fullname := GetNodeName(curnode) + '.' + fullname;
    end;

    value := GetNodeValue(DebugView.Selected);

    if InputQuery(Lang[ID_NV_MODIFYVALUE], fullname, value) then
      fDebugger.SendCommand('set variable', fullname + ' = ' + value, true);
  end;
end;

procedure TMainForm.actModifyWatchUpdate(Sender: TObject);
begin
  TCustomAction(Sender).Enabled := Assigned(DebugView.Selected) and fDebugger.Executing;
end;

procedure TMainForm.ClearallWatchPopClick(Sender: TObject);
begin
  fDebugger.DeleteWatchVars(true);
end;

procedure TMainForm.actDeleteProfileExecute(Sender: TObject);
var
  path: String;
  e: TEditor;
begin
  path := '';
  case GetCompileTarget of
    ctProject: begin
        path := ExtractFilePath(fProject.Executable) + GPROF_CHECKFILE;
      end;
    ctFile: begin
        e := fEditorList.GetEditor;
        if Assigned(e) then
          path := ExtractFilePath(ChangeFileExt(AnsiString(e.FileName), EXE_EXT)) + GPROF_CHECKFILE;
      end;
    ctNone: Exit;
  end;

  if path <> '' then begin
    if DeleteFile(PChar(path)) then begin
      SetStatusbarMessage(Format(Lang[ID_DELETEDPROFDATA], [path]));
    end else
      SetStatusbarMessage(Format(Lang[ID_COULDNOTFINDPROFDATA], [path]));
  end;
end;

procedure TMainForm.actGotoImplDeclEditorExecute(Sender: TObject);
var
  statement: PStatement;
  filename, phrase: String;
  line: integer;
  M: TMemoryStream;
  e: TEditor;
begin
  e := fEditorList.GetEditor;

  if Assigned(e) then begin

    // Exit early, don't bother creating a stream (which is slow)
    phrase := e.GetWordAtPosition(Point(e.Text.Carets[0].PosX, e.Text.Carets[0].PosY), wpInformation);
    if Phrase = '' then
      Exit;

    // When searching using menu shortcuts, the caret is set to the proper place
    // When searching using ctrl+click, the cursor is set properly too, so do NOT use WordAtMouse
    M := TMemoryStream.Create;
    try
      e.Text.Strings.SaveToStream(M, TATFileEncoding.ANSI, true);
      statement := CppParser.FindStatementOf(
        AnsiString(e.FileName),
        phrase, e.Text.Carets[0].PosY + 1, M);
    finally
      M.Free;
    end;

    // Otherwise scan the returned class browser statement
    if Assigned(statement) then begin

      // If the caret position was used
      if Sender = e then begin // Ctrl+Click from current editor

        // Switching between declaration and definition
        if (e.Text.Carets[0].PosY + 1 = statement^._DefinitionLine) and SameFileName(AnsiString(e.FileName), statement^._DefinitionFileName) then
          begin // clicked on declaration, move to definition
          filename := statement^._FileName;
          line := statement^._Line;
        end else begin // clicked anywhere, go to declaration
          filename := statement^._DefinitionFileName;
          line := statement^._DefinitionLine;
        end;

        // Menu item or mouse cursor
      end else begin

        // Switching between declaration and definition
        if Pos('Decl', TCustomAction(Sender).Name) > 0 then begin
          filename := statement^._FileName;
          line := statement^._Line;
        end else begin
          filename := statement^._DefinitionFileName;
          line := statement^._DefinitionLine;
        end;
      end;

      // Go to the location
      e := fEditorList.GetEditorFromFileName(filename);
      if Assigned(e) then begin
        e.SetCaretPosAndActivate(line, 1);
      end;

      SetStatusbarMessage('');
    end else
      SetStatusbarMessage(Format(Lang[ID_INFONOTFOUND], [phrase]));
  end;
end;

procedure TMainForm.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var
  Handled: Boolean);
var
  e: TEditor;
  State: TKeyboardState;
  I: integer;
begin

  // Check if control is pressed
  State := default(TKeyboardState);
  GetKeyboardState(State);
  e := fEditorList.GetEditor;

  // Check if we're focussing on an editor and holding ctrl
  if Assigned(e) and (Screen.ActiveControl = e.Text) and ((State[vk_Control] and 128) <> 0) then begin

    for I := 0 to pred(EditorList.PageCount) do begin
      e := fEditorList[I];

      // If so, set the font size of all editors...
      if WheelDelta > 0 then begin
        e.Text.Font.Size := Max(1, e.Text.Font.Size + 1);
        // ATSynEdit: no separate gutter font, gutter uses editor's main Font
      end else begin
        e.Text.Font.Size := Max(1, e.Text.Font.Size - 1);
        // ATSynEdit: no separate gutter font, gutter uses editor's main Font
      end;
    end;

    // And set the corresponding option
    if WheelDelta > 0 then begin
      devEditor.Font.Size := Max(1, devEditor.Font.Size + 1);
      devEditor.Gutterfont.Size := Max(1, devEditor.Gutterfont.Size + 1);
    end else if WheelDelta < 0 then begin
      devEditor.Font.Size := Max(1, devEditor.Font.Size - 1);
      devEditor.Gutterfont.Size := Max(1, devEditor.Gutterfont.Size - 1);
    end;
    CodeCompletion.Fontsize := devEditor.Font.Size;

    // We don't like to send the actual scrolling message to the editor when zooming
    Abort;
  end;
end;


procedure TMainForm.CompilerOutputAdvancedCustomDraw(Sender: TCustomListView;
  const ARect: TRect; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
begin
  SendMessage(CompilerOutput.Handle, WM_CHANGEUISTATE,
    MAKEWPARAM(UIS_SET, UISF_HIDEFOCUS), 0);
end;


procedure TMainForm.CompilerOutputAdvancedCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
  var DefaultDraw: Boolean);
var
  sErr, sWarn, sHint, sNote: String;
  R, ColRect: TRect;
  i, X: Integer;
  S: String;
  TextColor, BGColor: TColor;
  TS: TTextStyle;
  LV: TListView;
begin
  sErr  := '[' + Lang[ID_ERROR] + ']';
  sWarn := '[' + Lang[ID_WARN]  + ']';
  sHint := '[' + Lang[ID_HINT]  + ']';
  sNote := '[' + Lang[ID_NOTE]  + ']';

  // Determine text color based on message type (SubItems[2] = Message column)
  if StartsStr(sWarn, Item.SubItems[2]) then
    TextColor := $0066CC   //$0066CC 深橙 // //clPurple
  else if StartsStr(sErr, Item.SubItems[2]) then
    TextColor := RGBToColor(238, 8, 8)  // $2222B2 砖红 //clRed
  else if StartsStr(sHint, Item.SubItems[2]) or StartsStr(sNote, Item.SubItems[2]) then
    TextColor := clGray  //$A75E7B 紫罗兰  //clNavy
  else
    TextColor := clWindowText;

  // OwnerDraw=True: must draw everything ourselves
  DefaultDraw := False;
  LV := TListView(Sender);

  // Select background color
  if Item.Index = fCompilerHoverIndex then
    BGColor := devEditor.HighColor  //clHighLight
  else if Item.Selected then
    BGColor := clBtnFace
  else
    BGColor := LV.Color;

  R := Item.DisplayRect(drBounds);

  // 1. Draw background
  LV.Canvas.Brush.Color := BGColor;
  LV.Canvas.FillRect(R);

  // 2. Draw text for each column
  TS := default(TTextStyle);
  FillChar(TS, SizeOf(TS), 0);
  TS.Alignment   := taLeftJustify;
  TS.Layout      := tlCenter;
  TS.SingleLine  := True;
  TS.EndEllipsis := True;
  TS.Opaque      := False;

  LV.Canvas.Brush.Style := bsClear;
  LV.Canvas.Font.Color  := TextColor;

  X := R.Left;
  for i := 0 to LV.Columns.Count - 1 do begin
    ColRect.Left   := X + 2;
    if i = LV.Columns.Count - 1 then
      ColRect.Right := R.Right - 2   // last column extends to row right edge
    else
      ColRect.Right  := X + LV.Columns[i].Width - 2;
    ColRect.Top    := R.Top + 1;
    ColRect.Bottom := R.Bottom - 1;

    if i = 0 then
      S := Item.Caption
    else if i - 1 < Item.SubItems.Count then
      S := Item.SubItems[i - 1]
    else
      S := '';

    // Bold for "in " / "at " direction lines in the Message column (col 3)
    if (i = 3) and
       (StartsStr('in ', Trim(LowerCase(S))) or
        StartsStr('at ', Trim(LowerCase(S)))) then
      LV.Canvas.Font.Style := [fsBold]
    else
      LV.Canvas.Font.Style := [];

    LV.Canvas.TextRect(ColRect, ColRect.Left, ColRect.Top, S, TS);
    Inc(X, LV.Columns[i].Width);
  end;
end;

procedure TMainForm.cmbGenericDropDown(Sender: TObject);
var
  widestwidth, I: integer;
  ComboBox: TComboBox;
begin
  ComboBox := TComboBox(Sender);

  // Set to default width first...
  SendMessage(ComboBox.Handle, CB_SETDROPPEDWIDTH, 0, 0);

  widestwidth := 0;

  // Fix, cmbMembers.Canvas.Font was set to Tahoma for some reason?
  ComboBox.Canvas.Font.Name := 'Courier New';

  // get the max needed with of the items in dropdown state
  for I := 0 to ComboBox.Items.Count - 1 do
    widestwidth := Max(widestwidth, ComboBox.Canvas.TextWidth(ComboBox.Items[I]) + 8); // padding

  if (widestwidth > ComboBox.Width) then begin

    // Add scrollbar width
    if ComboBox.DropDownCount < ComboBox.Items.Count then
      widestwidth := widestwidth + GetSystemMetrics(SM_CXVSCROLL);

    SendMessage(ComboBox.Handle, CB_SETDROPPEDWIDTH, widestwidth, 0);
  end;
end;

procedure TMainForm.actUnCollapseExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    // ATSynEdit: use DoCommand with UnfoldAll command
    e.Text.DoCommand(cCommand_UnfoldAll, TATCommandInvoke(0), '');
end;

procedure TMainForm.actCollapseExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    // ATSynEdit: use DoCommand with FoldAll command
    e.Text.DoCommand(cCommand_FoldAll, TATCommandInvoke(0), '');
end;

procedure TMainForm.actInsertExecute(Sender: TObject);
var
  pt: TPoint;
begin
  pt := tbMain.ClientToScreen(point(btnInsert.Left, btnInsert.Top + btnInsert.Height));
  // Use a dedicated TPopupMenu that wraps InsertPopItem's sub-items
  if not Assigned(pmInsert) then begin
    pmInsert := TPopupMenu.Create(Self);
    pmInsert.Name := 'pmInsert';
    CloneMenu(InsertItem, pmInsert.Items);
    AssignMenuOwnerDrawHandlers(pmInsert.Items);
  end;
  pmInsert.PopUp(pt.X, pt.Y);
end;

//procedure TMainForm.actToggleExecute(Sender: TObject);
//var
//  pt: TPoint;
//begin
//  pt := tbProject.ClientToScreen(point(Togglebtn.Left, Togglebtn.Top + togglebtn.Height));
//  TrackPopupMenu(ToggleBookmarksItem.Handle, TPM_LEFTALIGN or TPM_LEFTBUTTON, pt.x, pt.y, 0, Self.Handle, nil);
//end;

//procedure TMainForm.actGotoExecute(Sender: TObject);
//var
//  pt: TPoint;
//begin
//  pt := tbProject.ClientToScreen(point(Gotobtn.Left, Gotobtn.Top + Gotobtn.Height));
//  TrackPopupMenu(GotoBookmarksItem.Handle, TPM_LEFTALIGN or TPM_LEFTBUTTON, pt.x, pt.y, 0, Self.Handle, nil);
//end;

procedure TMainForm.EditorPageControlLeftMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  PageIndex: integer;
  newhint: String;
  e: TEditor;
  SenderPageControl: TPageControl;
begin
  SenderPageControl := TPageControl(Sender);
  PageIndex := SenderPageControl.IndexOfTabAt(X, Y);
  if PageIndex <> -1 then begin
    e := fEditorList.GetEditor(PageIndex, SenderPageControl);
    if Assigned(e) then
      newhint := AnsiString(e.FileName)
    else
      newhint := '';
  end else
    newhint := '';

  // Only call CancelHint when the hint changes
  if (newhint <> fCurrentPageHint) then begin
    Application.CancelHint;
    fCurrentPageHint := newhint;
    SenderPageControl.Hint := newhint;
  end;
end;

procedure TMainForm.actBreakPointExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    e.ToggleBreakPoint(e.Text.Carets[0].PosY + 1);
end;

procedure TMainForm.OnInputEvalReady(const evalvalue: AnsiString);
begin
  EvalOutput.Text := evalvalue;
  EvalOutput.Font.Color := clWindowText;
  MainForm.fDebugger.OnEvalReady := nil;
end;

procedure TMainForm.EvaluateInputKeyPress(Sender: TObject; var Key: Char);
begin
  if fDebugger.Executing then begin
    if Key = Chr(VK_RETURN) then begin
      if Length(EvaluateInput.Text) > 0 then begin

        // Disable key, but make sure not to remove selected text
        EvaluateInput.SelStart := 0;
        EvaluateInput.SelLength := Length(EvaluateInput.Text);  //0;
        Key := #0;

        fDebugger.OnEvalReady := @OnInputEvalReady;
        fDebugger.SendCommand('print', EvaluateInput.Text, true);

        // Tell the user we're updating...
        EvalOutput.Font.Color := clGrayText;

        // Add to history
        if EvaluateInput.Items.IndexOf(EvaluateInput.Text) = -1 then
          EvaluateInput.AddItem(EvaluateInput.Text, nil);
      end;
    end;
  end;
end;

procedure TMainForm.FormShow(Sender: TObject);
var
  FileCount, start, number: Integer;
  //k, k0: Integer;
  LastActive: integer;
  s: string;
  UpdateChecker: TUpdateChecker;
begin
  if not fFirstShow then
    Exit;

  fFirstShow := false;

  // Restore window position and size (including maximized/normal state)
  devData.WindowState.SetPlacement(Self.Handle);
  if Assigned(fProjectToolWindow) then
    devData.ProjectWindowState.SetPlacement(fProjectToolWindow.Handle);
  if Assigned(fReportToolWindow) then
    devData.ReportWindowState.SetPlacement(fReportToolWindow.Handle);

  // Below a possible fix for the disappearing of controls in MessageControl is given:
  // Toggle visibility of bottom page control here.
  // If we do this in OnCreate, it messes with alignment options
  OpenCloseMessageSheet(False);

  // Open files passed to us (HAS to be done at FormShow)
  // This includes open file commands send to us via WMCopyData
  FileCount := ParseParameters({$IFDEF MSWINDOWS}GetCommandLineW{$ELSE}CmdLine{$ENDIF});
  start := ParseParameters({$IFDEF MSWINDOWS}GetCommandLineW{$ELSE}CmdLine{$ENDIF});
  number := ParseParameters({$IFDEF MSWINDOWS}GetCommandLineW{$ELSE}CmdLine{$ENDIF});

  // Open them according to OpenFileList rules
  OpenFileList(fFilesToOpen);
  fFilesToOpen.Clear;
  if ((FileCount = 0) and devData.AutoLoadLast) then begin
    if devData.LastProject <> '' then   //Load last project
      OpenProject (devData.LastProject)
    else begin //load last source files
      for start := 0 to dmMain.MRU.Count-1 do begin
        s := PMRUItem(dmMain.MRU.Items[start])^.FileName;
        if FileExists(s) and (GetFileTyp(s) <> utPrj) then
          break;
      end;
      LastActive := devData.LastActive;
      for number := devData.LastFiles - 1 downto 0  do begin
        if (start + number) > (dmMain.MRU.Count - 1) then    //check to avoid list overflow
          continue;
        s := PMRUItem(dmMain.MRU.Items[start + number])^.FileName;
        if FileExists(s) and (GetFileTyp(s) <> utPrj) then
          OpenFile(s)
        else
          dec(LastActive);
      end;
      if (LastActive >= 0) and (LastActive < EditorList.PageCount -1) then
        EditorList.Editors[LastActive].Activate;
    end;
  end;

  if EditorList.PageCount = 0 then begin
    actNewSourceExecute(Sender); // new source file
    LeftPageControl.ActivePageIndex := 1;
  end;

  //UpdateAppTitle;

  // Do not show tips if Dev-C++ is launched with a file and only slow
  // when the form shows for the first time, not when going fullscreen too
  if devData.ShowTipsOnStart and (FileCount = 0) then
    actHelpTips.Execute;

    //devData.AutoCheckUpdate := 1;   //debug
  Randomize; //initialize random
  if (devData.AutoCheckUpdate = 1) and (Random(20) = 0)then begin
//  if (devData.AutoCheckUpdate = 1) then begin
    UpdateChecker := TUpdateChecker.Create(DEVCPP_VERSION);
    UpdateChecker.LatestVersion := UpdateChecker.GetLatestReleaseVersionGitee();
    s := 'https://gitee.com/devcpp/devcpp/releases';
    if UpdateChecker.LatestVersion = '' then  //failed check update from Gitee
    begin
      UpdateChecker.LatestVersion := UpdateChecker.GetLatestReleaseVersionGitCode();
      s := 'https://gitcode.com/devcpp/devcpp/releases';
    end;

    if (UpdateChecker.LatestVersion <> '') and (CompareText(UpdateChecker.LatestVersion, 'v'+DEVCPP_VERSION) > 0) then
    begin
      if MessageDlg(Lang[ID_HP_GOTODOWNLOAD], mtInformation, [mbYes, mbNo], 0) = mrYes then
        OpenURL(s);
    end;
    UpdateChecker.Free;
  end;
end;

procedure TMainForm.actSkipFunctionExecute(Sender: TObject);
begin
  if fDebugger.Executing then begin
    fDebugger.SendCommand('finish', '', true);
  end;
end;

procedure TMainForm.actNextInsExecute(Sender: TObject);
begin
  if fDebugger.Executing then begin
    fDebugger.SendCommand('nexti', '', true);
  end;
end;

procedure TMainForm.actStepInsExecute(Sender: TObject);
begin
  if fDebugger.Executing then begin
    fDebugger.SendCommand('stepi', '', true);
  end;
end;

procedure TMainForm.DebugViewAdvancedCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
var
  curnode: TTreeNode;
begin
  curnode := node;
  while Assigned(curnode.Parent) do
    curnode := curnode.Parent;

  // TODO: why does this happen?
  if not Assigned(curnode.Data) then
    Exit;

  // Paint top level items in red if they aren't found
  if (curnode.Level = 0) and (PWatchVar(curnode.Data)^.gdbindex = -1) then begin
    if cdsSelected in State then
      Sender.Canvas.Font.Color := clWhite
    else
      Sender.Canvas.Font.Color := clRed;
  end else begin
    if cdsSelected in State then
      Sender.Canvas.Font.Color := clWhite
    else
      Sender.Canvas.Font.Color := clBlack;
  end;
end;

procedure TMainForm.FindOutputAdvancedCustomDrawSubItem(Sender: TCustomListView; Item: TListItem; SubItem: Integer;
  State: TCustomDrawState; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
var
  LineToDraw: String;
  BoldStart, BoldLen, i: integer;
  Rect: TRect;
  OldBrushColor, OldFontColor: TColor;

  procedure Draw(const s: String);
  var
    sizerect: TRect = (Left: 0; Top: 0; Right: 0; Bottom: 0);
  begin
    DrawText(Sender.Canvas.Handle, PChar(s), Length(s), rect, DT_EXPANDTABS or DT_NOCLIP or DT_NOPREFIX);

    // Get text extent
    DrawText(Sender.Canvas.Handle, PChar(s), Length(s), sizerect, DT_CALCRECT or DT_EXPANDTABS or DT_NOCLIP or
      DT_NOPREFIX);
    Inc(rect.Left, sizerect.Right - sizerect.Left + 1); // 1 extra pixel for extra width caused by bold
  end;
begin
  // Draw the current line marker in bold
  {if SubItem = 0 then begin
    Sender.Canvas.Font.Style := [fsBold];
    Sender.Canvas.Refresh;
    DefaultDraw := True;

  // Draw the find result in bold
  end else}
  if SubItem = 4 then begin

    // Get rect of subitem to draw
    Rect := Item.DisplayRect(drBounds);
    for i := 0 to SubItem - 1 do begin
      Rect.Left := Rect.Left + Sender.Column[i].Width;
      Rect.Right := Rect.Right + Sender.Column[i].Width;
    end;

    // Draw blue highlight
    OldBrushColor := Sender.Canvas.Brush.Color;
    OldFontColor := Sender.Canvas.Font.Color;
    if (cdsSelected in State) then begin
      Sender.Canvas.Brush.Color := clHighlight;
      Sender.Canvas.Font.Color := clWhite;
      Sender.Canvas.FillRect(rect);
    end;

    // Get text to draw
    LineToDraw := Item.SubItems[SubItem - 1];

    // Make text location appear 'native', like Windows would draw it
    Types.OffsetRect(Rect, 4, 2);

    // Get location of bold part
    BoldStart := StrToIntDef(Item.SubItems[1], 1);
    if Assigned(Item.Data) then
      BoldLen := PInteger(Item.Data)^
    else
      BoldLen := 0;

    // Draw part before bold highlight
    Draw(Copy(LineToDraw, 1, BoldStart - 1));

    // Enable bold
    Sender.Canvas.Font.Style := [fsBold];
    Sender.Canvas.Refresh;

    // Draw bold highlight
    Draw(Copy(LineToDraw, BoldStart, BoldLen));

    // Disable bold
    Sender.Canvas.Font.Style := [];
    Sender.Canvas.Refresh;

    // Draw part after bold highlight
    Draw(Copy(LineToDraw, BoldStart + BoldLen, MaxInt));

    // Restore colors
    Sender.Canvas.Brush.Color := OldBrushColor;
    Sender.Canvas.Font.Color := OldFontColor;

    DefaultDraw := false;
  end else
    DefaultDraw := true;
end;

procedure TMainForm.FindOutputAdvancedCustomDraw(Sender: TCustomListView; const ARect: TRect; Stage: TCustomDrawStage;
  var DefaultDraw: Boolean);
begin
  SendMessage(FindOutput.Handle, WM_CHANGEUISTATE, MAKEWPARAM(UIS_SET, UISF_HIDEFOCUS), 0);
end;

procedure TMainForm.actSearchAgainExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if not Assigned(e) then
    Exit;

  // Repeat action if it was a finding action
  if Assigned(FindForm) then begin
    with FindForm do begin
      if FindTabs.TabIndex < 2 then begin // it's a find action

        // Disable entire scope searching
        if grpOrigin.Visible then
          rbEntireScope.Checked := false;

        // Always search forwards
        if grpDirection.Visible then
          rbForward.Checked := true;

        btnFind.Click;
        e.Text.SetFocus;
      end;
    end;
  end;
end;

procedure TMainForm.actRevSearchAgainExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if not Assigned(e) then
    Exit;

  // Repeat action if it was a finding action
  if Assigned(FindForm) then begin
    with FindForm do begin
      if FindTabs.TabIndex < 2 then begin // it's a find action

        // Disable entire scope searching
        if grpOrigin.Visible then
          rbEntireScope.Checked := false;

        // Always search backwards
        if grpDirection.Visible then
          rbBackward.Checked := true;

        btnFind.Click;
        e.Activate;
      end;
    end;
  end;
end;

procedure TMainForm.FindOutputDeletion(Sender: TObject; Item: TListItem);
begin
  // FindOutput items carry a heap-allocated keyword length (see AddFindOutputItem)
  if Assigned(Item) and Assigned(Item.Data) then begin
    FreeMem(Item.Data);
    Item.Data := nil;
  end;

  // Form is being destroyed, don't use Lang which has been freed already
  // TODO: however, for some reason Lang might already have been destroyed
  // before Terminated is set to true. This causes the Lang singleton to be
  // recreated, which in turn fails because it needs a valid devDirs, which
  // has also already been deleted.
  // FIX: check for Assigned(devDirs) here
  if Application.Terminated or not Assigned(devDirs) then
    Exit;
  if FindOutput.Items.Count > 1 then
    FindSheet.Caption := Lang[ID_SHEET_FIND] + ' (' + IntToStr(FindOutput.Items.Count - 1) + ')'
  else
    FindSheet.Caption := Lang[ID_SHEET_FIND];
end;

procedure TMainForm.CompilerOutputDeletion(Sender: TObject; Item: TListItem);
begin
  if Application.Terminated or not Assigned(devDirs) then
    Exit;
  if CompilerOutput.Items.Count > 1 then
    CompSheet.Caption := Lang[ID_SHEET_COMP] + ' (' + IntToStr(CompilerOutput.Items.Count - 1) + ')'
  else
    CompSheet.Caption := Lang[ID_SHEET_COMP];
end;

procedure TMainForm.ResourceOutputDeletion(Sender: TObject; Item: TListItem);
begin
  if Application.Terminated or not Assigned(devDirs) then
    Exit;
  if ResourceOutput.Items.Count > 1 then
    ResSheet.Caption := Lang[ID_SHEET_RES] + ' (' + IntToStr(ResourceOutput.Items.Count - 1) + ')'
  else
    ResSheet.Caption := Lang[ID_SHEET_RES];
end;

procedure TMainForm.actStopExecuteUpdate(Sender: TObject);
begin
  if Assigned(fProject) then
    TCustomAction(Sender).Enabled := (not (fProject.Options.typ = dptStat) and devExecutor.Running) or
      fDebugger.Executing
  else
    TCustomAction(Sender).Enabled := ((EditorList.PageCount > 0) and devExecutor.Running) or fDebugger.Executing;
end;

procedure TMainForm.actUpdateIndent(Sender: TObject);
begin // special action to prevent tabs from being processed when using the find form
  TCustomAction(Sender).Enabled := (EditorList.PageCount > 0) and (not Assigned(FindForm) or not FindForm.Showing);
end;

procedure TMainForm.actDeleteLineExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    // ATSynEdit: use DoCommand with TextDeleteLine command
    e.Text.DoCommand(cCommand_TextDeleteLine, TATCommandInvoke(0), '');
end;

procedure TMainForm.actDeleteToLineEndExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    e.Text.DoCommand(cCommand_TextDeleteToLineEnd, TATCommandInvoke(0), '');
end;

procedure TMainForm.actDeleteToLineBeginExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    e.Text.DoCommand(cCommand_TextDeleteToLineBegin, TATCommandInvoke(0), '');
end;

procedure TMainForm.cmbCompilers1Change(Sender: TObject);
var
  index: integer;
  e: TEditor;

  procedure ChangeProjectCompilerSet;
  begin
    // If true, continue, otherwise, revert selection change
    if MessageDlg(Lang[ID_POPT_DISCARDCUSTOM], mtConfirmation, [mbYes, mbNo], 0) = mrNo then begin // user cancels change
      TComboBox(Sender).ItemIndex := fOldCompilerToolbarIndex; // undo index change
      Exit;
    end;

    // Notify project
    // Discard changes made to the old set...
    fProject.Options.CompilerSet := index;
    fProject.Options.CompilerOptions := devCompilerSets[index].INIOptions;
    fProject.Modified := true;
  end;

  procedure ChangeNonProjectCompilerSet;
  begin
    // Notify compiler list
    devCompilerSets.DefaultSetIndex := index;
    devCompilerSets.SaveSetList;
  end;
begin
  index := TComboBox(Sender).ItemIndex;
  if index = fOldCompilerToolbarIndex then
    Exit;

  // Check if the current file belongs to a project
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    if e.InProject and Assigned(fProject) then begin
      ChangeProjectCompilerSet;
    end else begin
      ChangeNonProjectCompilerSet;
    end;

    // No editors have been opened. Check if a project is open
  end else if Assigned(fProject) then begin
    ChangeProjectCompilerSet;

    // No project, no editor, modify global
  end else begin
    ChangeNonProjectCompilerSet;
  end;

  // Mention change to compiler sets
  //devCompilerSets.OnCompilerSetChanged(
  //  devCompilerSets[fOldCompilerToolbarIndex],
  //  devCompilerSets[index]);

  fOldCompilerToolbarIndex := index;
end;

procedure TMainForm.actDuplicateLineExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    // ATSynEdit: use DoCommand with TextDuplicateLine command
    e.Text.DoCommand(cCommand_TextDuplicateLine, TATCommandInvoke(0), '');
end;

procedure TMainForm.actMoveSelUpExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    // ATSynEdit: use DoCommand with MoveSelectionUp command
    e.Text.DoCommand(cCommand_MoveSelectionUp, TATCommandInvoke(0), '');
end;

procedure TMainForm.actMoveSelDownExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    // ATSynEdit: use DoCommand with MoveSelectionDown command
    e.Text.DoCommand(cCommand_MoveSelectionDown, TATCommandInvoke(0), '');
end;

procedure TMainForm.actCodeCompletionUpdate(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  TCustomAction(Sender).Enabled := Assigned(e) and e.Text.Focused;
end;

procedure TMainForm.actCodeCompletionExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    e.ShowCompletion;
end;

procedure TMainForm.actPackageManagerExecute(Sender: TObject);
var
  s: String;
begin
  s := IncludeTrailingBackslash(devDirs.Exec) + PACKMAN_PROGRAM;
  if FileExists(s) then
    ExecuteFile(s, '', IncludeTrailingBackslash(devDirs.Exec), SW_SHOW);
end;


procedure TMainForm.actHelpTutorialExecute(Sender: TObject);
begin
//  if Pos('Chinese', devData.Language) > 0 then
//    OpenhelpFile('tutorial-cn.html')
//  else
//    OpenHelpFile('tutorial.html');
  if Pos('Chinese', devData.Language) > 0 then
    //ShellExecute(GetDesktopWindow(), 'open',
    //  PChar('https://devcpp.gitee.io/tutorial.html'), nil, nil, SW_SHOWNORMAL)
    OpenhelpFile('tutorial-cn.html')
  else
    //ShellExecute(GetDesktopWindow(), 'open',
    //  PChar('https://devcpp.gitee.io/tutorial-en.html'), nil, nil, SW_SHOWNORMAL)
    OpenhelpFile('tutorial-en.html')
end;

procedure TMainForm.actHelpManualExecute(Sender: TObject);
begin
  if Pos('Chinese', devData.Language) > 0 then
//    ShellExecute(GetDesktopWindow(), 'open',
//      PChar('https://devcpp.gitee.io/manual.html'), nil, nil, SW_SHOWNORMAL)
    OpenhelpFile('manual-cn.html')
  else
    OpenHelpFile('orwelldevcpp\index.htm');
end;

procedure TMainForm.actHelpDonateExecute(Sender: TObject);
begin
  if Pos('Chinese', devData.Language) > 0 then
    OpenURL('https://anbangli.github.io/XiaoLoong-DevCpp/donate.html')
  else
    OpenURL('https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=7FD675DNV8KKJ');
end;

procedure TMainForm.actHelpHomepageExecute(Sender: TObject);
var
  HomepageForm: THomepageForm;
begin
  HomepageForm := THomepageForm.Create(Self);
//  devData.AutoCheckUpdate := -1;  //debug
  if devData.AutoCheckUpdate <> -1 then
    HomepageForm.AutoCheckUpdate := boolean(devData.AutoCheckUpdate);

  HomepageForm.ShowModal;
  devData.AutoCheckUpdate := integer(HomepageForm.AutoCheckUpdate);
{
  if Pos('Chinese', devData.Language) > 0 then
    //ShellExecute(GetDesktopWindow(), 'open',
    //  PChar('https://devcpp.gitee.io'), nil, nil, SW_SHOWNORMAL)
    OpenhelpFile('homepage.html')
  else
    ShellExecute(GetDesktopWindow(), 'open',
      PChar('https://anbangli.github.io/XiaoLoong-DevCpp/'),
      nil, nil, SW_SHOWNORMAL);
 }
end;

procedure TMainForm.actHelpCLibExecute(Sender: TObject);
begin
  if Pos('Chinese', devData.Language) > 0 then
    OpenhelpFile('CFunctions-cn.html')
  else
    OpenURL('http://www.gnu.org/software/libc/manual/html_node/index.html');
end;

procedure TMainForm.actHelpFAQExecute(Sender: TObject);
begin
  if Pos('Chinese', devData.Language) > 0 then
    OpenhelpFile('FAQ-cn.html')
    //ShellExecute(GetDesktopWindow(), 'open',
    //  PChar('https://devcpp.gitee.io/faq.html'), nil, nil, SW_SHOWNORMAL)
  else
    OpenhelpFile('FAQ-en.html')
  //ShellExecute(GetDesktopWindow(), 'open', PChar('http://c-faq.com/'), nil, nil, SW_SHOWNORMAL);
end;


procedure TMainForm.actShortenCompPathsExecute(Sender: TObject);
var
  I: integer;
begin
  devData.ShortenCompPaths := not devData.ShortenCompPaths;

  // Re-add data to undo/redo shortening
  LogOutput.Lines.BeginUpdate;
  try
    LogOutput.Lines.Clear;
    for I := 0 to fLogOutputRawData.Count - 1 do begin
      // ShortenLogOutput not available; switching shortened/unshortened not supported
      LogOutput.Lines.Add(fLogOutputRawData[i]);
    end;
  finally
    LogOutput.Lines.EndUpdate;
  end;
end;


procedure TMainForm.LeftPageControlChange(Sender: TObject);
begin
  ClassBrowser.TabVisible := LeftPageControl.ActivePage = LeftClassSheet;
end;



procedure TMainForm.LeftPageControlResize(Sender: TObject);
begin
  if LeftPageControl.Width< 210 then
    LeftPageControl.Width := 210;
  if LeftPageControl.Width >1000 then
    LeftPageControl.Width := 1000;
end;


procedure TMainForm.actSwapEditorExecute(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then
    fEditorList.SwapEditor(e);
end;

procedure TMainForm.actSwapEditorUpdate(Sender: TObject);
begin
  TCustomAction(Sender).Enabled := fEditorList.PageCount > 1;
end;

procedure TMainForm.actSaveAllUpdate(Sender: TObject);
var
  e: TEditor;
  I: integer;
begin
  for I := 0 to fEditorList.PageCount - 1 do begin
    e := fEditorList[i];
    //if Assigned(e) and (e.Text.Modified or (e.FileName = '')) then begin
    if Assigned(e) and (e.Modified or (e.FileName = '')) then begin
      TCustomAction(Sender).Enabled := True;
      Exit;
    end;
  end;
  TCustomAction(Sender).Enabled := False;
end;

procedure TMainForm.PageControlPanelResize(Sender: TObject);
begin
  fEditorList.OnPanelResize(Sender);
end;

procedure TMainForm.actOpenFolderExecute(Sender: TObject);
{var
  e: TEditor;
  Folder: String;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    Folder := ExtractFilePath(e.FileName);
    if Folder <> '' then
      ShellExecute(Application.Handle, 'open', 'explorer.exe', PChar(Folder), nil, SW_SHOWNORMAL);
  end;
}
var
  Exec, Params, WorkDir: String;
begin
  Exec := '<WINDIR>\explorer.exe';
  Params := '/select, <PROJECTFILE>';
  WorkDir := '<PROJECTPATH>';
  ExecuteFile(ParseToolParams(Exec), ParseToolParams(Params), ParseToolParams(WorkDir), SW_SHOW);
end;



procedure TMainForm.actGotoBreakPointExecute(Sender: TObject);
var
  e: TEditor;
  FileName: String;
begin
  FileName := fDebugger.BreakPointFile;
  if FileName <> '' then begin
    e := fEditorList.GetEditorFromFileName(FileName);
    if Assigned(e) then begin
      e.GotoActiveBreakpoint;
      e.Activate;
    end;
  end;
end;





procedure TMainForm.actToggleCommentInlineExecute(Sender: TObject);
var
  e: TEditor;
  SelText: String;
begin
  e := fEditorList.GetEditor;
  if Assigned(e) then begin
    SelText := String(e.Text.TextSelected);
    if SelText <> '' then begin
      // Wrap selection in /* */
      // First check if it's already wrapped - if so, unwrap
      if (Copy(SelText, 1, 2) = '/*') and (Copy(SelText, Length(SelText) - 1, 2) = '*/') then
        SelText := Copy(SelText, 3, Length(SelText) - 4)
      else
        SelText := '/*' + SelText + '*/';

      e.Text.DoCommand(cCommand_TextInsert, TATCommandInvoke(0), UnicodeString(UTF8Encode(SelText)));
    end;
  end;
end;

procedure TMainForm.actToggleCommentInlineUpdate(Sender: TObject);
var
  e: TEditor;
begin
  e := fEditorList.GetEditor;
  // ATSynEdit: use CaretsSel instead of SelAvail
  TCustomAction(Sender).Enabled := Assigned(e) and not e.Text.CaretsSel.IsEmpty;
end;

procedure TMainForm.actFormatCurrentFileExecute(Sender: TObject);
var
  e: TEditor;
  OldCaretXY: TPoint;
  OldTopLine: integer;
  i: integer;
  BreakList: TList;   //BreakPoint list in current file
  APBreakPoint: PBreakPoint;

begin
  if devFormatter.Validate then begin
    e := fEditorList.GetEditor;
    if Assigned(e) then begin
      // Save breakpoint line numbers for this editor, then clean stale entries
      BreakList := TList.Create;
      for i := Debugger.BreakPointList.Count - 1 downto 0 do begin
        if PBreakPoint(Debugger.BreakPointList.Items[i])^.editor = e then begin
          APBreakPoint := new(PBreakPoint);
          APBreakPoint^.line := PBreakPoint(Debugger.BreakPointList.Items[i])^.line;
          APBreakPoint^.editor := e;
          BreakList.Add(APBreakPoint);
          // Remove from global list to avoid duplicates
          Dispose(PBreakPoint(Debugger.BreakPointList.Items[i]));
          Debugger.BreakPointList.Delete(i);
        end;
      end;

      // Save for undo list creation
      OldTopLine := e.Text.LineTop;
      // ATSynEdit: save caret position through Carets[0]
      OldCaretXY := Point(e.Text.Carets[0].PosX, e.Text.Carets[0].PosY);

      devFormatter.FormatMemory(e, devFormatter.FullCommand);  //!!!
      e.ResetBookMarks;

      // Restore breakpoints to debugger's list (now clean, no duplicates)
      for i := 0 to BreakList.Count - 1 do begin
        APBreakPoint := new(PBreakPoint);
        APBreakPoint^.line := PBreakPoint(BreakList.Items[i])^.line;
        APBreakPoint^.editor := e;
        Debugger.BreakPointList.Add(APBreakPoint);
        Dispose(PBreakPoint(BreakList.Items[i]));
      end;
      BreakList.Free;

      // Restore breakpoint background colors and gutter icons
      e.RestoreBreakpointBackgrounds;

      // Attempt to not scroll view
      e.Text.LineTop := OldTopLine;
      // ATSynEdit: restore caret position through Carets[0]
      e.Text.Carets[0].PosX := OldCaretXY.X;
      e.Text.Carets[0].PosY := OldCaretXY.Y;
      e.UpdateCurrentLineMarker; // Re-add BK_CURRENTLINE after Bookmarks2 was cleared
      e.Modified := True;
      e.Text.Invalidate;
    end;
  end else
    MessageDlg(Lang[ID_FORMATTER_NOTVALID], mtWarning, [mbOK], 0);
end;

procedure TMainForm.actFormatOptionsExecute(Sender: TObject);
begin
  with TFormatterOptForm.Create(nil) do try
    if ShowModal = mrOk then begin
    end;
  finally
    Free;
  end;
end;

procedure TMainForm.FindOutputSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Selected then
    Item.Caption := '>'
  else
    Item.Caption := '';
end;

procedure TMainForm.actRunTestsExecute(Sender: TObject);
begin
  with TTestClass.Create do try
    TestAll;
  finally
    Free;
  end;
end;

procedure TMainForm.actRuntoCursorExecute(Sender: TObject);
begin
  if fDebugger.Executing then begin
    fDebugger.SendCommand('u', '', true);
  end;
end;

procedure TMainForm.actRuntoCursorUpdate(Sender: TObject);
begin
  TCustomAction(Sender).Enabled := fDebugger.Executing;
end;

// Linux IPC handler: receives file-open commands from subsequent instances
// via a Unix TCP socket (see Instances.pas). On Linux, the command-line
// arguments sent via the socket are re-parsed the same way as WM_COPYDATA.
procedure TMainForm.WMLinuxCopyData(var Message: TMessage);
var
  MessageData: String;
begin
  // WParam = SENDDATAID identifier, LParam = PChar to received string
  if Message.WParam = SENDDATAID then begin
    MessageData := PChar(Message.LParam);
    if MessageData <> '' then begin
      fCriticalSection.Acquire;
      try
        ParseParameters(WideString(MessageData));
        if not fFirstShow then begin
          OpenFileList(fFilesToOpen);
          fFilesToOpen.Clear;
        end;
        Application.BringToFront;
      finally
        fCriticalSection.Release;
      end;
    end;
    // Free the string allocated by the sender (Instances.pas RecvSocketData)
    StrDispose(PChar(Message.LParam));
  end;
end;

function TMainForm.ParseParameters(const Parameters: WideString): Integer;
type
  TPWideCharArray = array[0..0] of PWideChar;
var
  I, ParameterCount: Integer;
  ParameterList: PPWideChar;
  Item: WideString;
begin
  Result := 0;

  // Convert string to list of items
  ParameterList := CommandLineToArgvW(PWideChar(Parameters), @ParameterCount);
  if not Assigned(ParameterList) then
    Exit;

  // Walk the list
  I := 1; // skip first one
  while I < ParameterCount do begin
    Item := TPWideCharArray(ParameterList^)[i];

    // Skip the configuration redirect stuff
    if Item = '-c' then begin
      I := I + 2;
      Continue;
    end;

    fFilesToOpen.Add(AnsiString(Item));
    Inc(I);
  end;
  Result := fFilesToOpen.Count;

  // Free list of pointers
  LocalFree(Cardinal(ParameterList));
end;

procedure TMainForm.SetupEventHandlers;
begin
  ClassBrowser.OnDataChanged := @Self.UpdateBrowserView; // ֱ�������෽��

  // ����2��ʹ�ñ�׼�¼���������
  // BrowserView.OnChange := HandleTreeNodeChange; // ָ���෽��
end;

// �����Ľڵ�����������
//procedure TMainForm.HandleTreeNodeChange(Sender: TObject; Node: TTreeNode);
//begin
//  if Assigned(Node) and Assigned(Node.Data) then
//    ClassBrowser.HandleNodeSelection(PStatement(Node.Data));
//end;


procedure TMainForm.UpdateBrowserView;
var
  I, J: Integer;
  RootMember, ChildMember: TClassMember;
  RootNode: TTreeNode;
begin
  BrowserView.Items.BeginUpdate;
  try
    BrowserView.Items.Clear;

    // ���Ӹ��ڵ�
    for I := 0 to ClassBrowser.GetRootCount - 1 do
    begin
      RootMember := ClassBrowser.GetRootItem(I);
      RootNode := BrowserView.Items.AddObject(nil, RootMember.Name, RootMember);

//      RootNode.ImageIndex := Ord(RootMember.ImageIndex);  //Set Node Icon
//      RootNode.SelectedIndex := Ord(RootMember.ImageIndex);

      // �����ӽڵ�
      for J := 0 to RootMember.GetChildCount - 1 do
      begin
        ChildMember := RootMember.GetChild(J);
        BrowserView.Items.AddChildObject(RootNode, ChildMember.Name, ChildMember);
//        ChildNode.ImageIndex := Ord(ChildMember.ImageIndex);   //Set Node Icon
//        ChildNode.SelectedIndex := Ord(ChildMember.ImageIndex);
      end;
    end;
  finally
    BrowserView.Items.EndUpdate;
  end;

  // Remember selection.  TODO.
//  if fLastSelection <> '' then
//    ReSelect;


end;

procedure TMainForm.HandleBrowserViewUpdate;
begin
  UpdateBrowserView;
end;

{
procedure TMainForm.AddMembersToTree(ParentNode: TTreeNode; Member: TClassMember);
var
  Node: TTreeNode;
  i: Integer;
  Kind: TMemberKind;
begin
  // ȷ����Ա���ͣ�����Ǽ̳г�Ա��ʹ������ͼ��?
  if Member.IsInherited then
    Kind := mkInherited
  else
    Kind := Member.Kind;

  // �������ڵ㲢����ͼ������
  Node := BrowserView.Items.AddChild(ParentNode, Member.Name);
  Node.Data := Member;
//  Node.ImageIndex := ClassBrowser.ImagesRecord.GetImageIndex(Kind);
  Node.SelectedIndex := Node.ImageIndex; // ѡ��ʱʹ����ͬͼ��

  // �ݹ������ӳ�Ա
  for i := 0 to Member.Children.Count - 1 do
    AddMembersToTree(Node, TClassMember(Member.Children[i]));
end;
}

procedure TMainForm.BrowserViewClick(Sender: TObject);
var
  Member: TClassMember;
  e: TEditor;
begin
  if Assigned(BrowserView.Selected) then
  begin
    Member := TClassMember(BrowserView.Selected.Data);
    if Assigned(Member) then begin
      e := fEditorList.GetEditorFromFilename(Member.FileName);
      if Assigned(e) then
        e.SetCaretPosAndActivate(Member.Line, 1);
    end;
  end;
end;

//procedure TMainForm.ClassBrowserSelect(Sender: TObject; Filename: TFileName; Line: Integer);
//var
//  e: TEditor;
//begin
//  e := fEditorList.GetEditorFromFilename(FileName);
//  if Assigned(e) then begin
//    e.SetCaretPosAndActivate(Line, 1);
//  end;
//end;

procedure TMainForm.BrowserViewAdvancedCustomDraw(Sender: TCustomTreeView;
    const ARect: TRect; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
var
  ItemH: Integer;
begin
  if Stage = cdPrePaint then begin
    // Sync canvas font with the control's own font for correct text measurement
    Sender.Canvas.Font.Assign(Sender.Font);
    // Calculate desired item height: font pixel height + 6px vertical padding (3px top + 3px bottom)
    ItemH := Abs(Sender.Canvas.Font.Height) + 6;
    // Set the default height for all tree items �?guard against recursive repaint
    if (Sender is TTreeView) and (TTreeView(Sender).DefaultItemHeight <> ItemH) then
      TTreeView(Sender).DefaultItemHeight := ItemH;
  end;
end;

procedure TMainForm.BrowserViewAdvancedCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
    State: TCustomDrawState; Stage: TCustomDrawStage;  var PaintImages, DefaultDraw: Boolean);
var
  DrawRect: TRect;
  DrawPoint: TPoint;
  Member: TClassMember;
  bInherited: boolean;
  TypeText: AnsiString;
begin
  Member := TClassMember(Node.Data);
  if not Assigned(Member) then
    Exit;

  //Set Node's ImageIndex
  //TODO: Shoud bInherited be initialized here?  --Anbang LI
  bInherited := ClassBrowser.ShowInheritedMembers and Member.IsInherited;

  case Member.Kind of
    mkClass: begin
        Node.ImageIndex := Ord(ClassesImg);
      end;
    mkVariable, mkEnum: case Member.ClassScope of
        scsPrivate: Node.ImageIndex := Ord(VariablePrivateImg);
        scsProtected: if not bInherited then
            Node.ImageIndex := Ord(VariableProtectedImg)
          else
            Node.ImageIndex := Ord(InheritedVariableProtectedImg);
        scsPublic: if not bInherited then
            Node.ImageIndex := Ord(VariablePublicImg)
          else
            Node.ImageIndex := Ord(InheritedVariablePublicImg);
        scsNone: Node.ImageIndex := Ord(VariablePublicImg);
      end;
    mkFunction: case Member.ClassScope of
        scsPrivate: Node.ImageIndex := Ord(MethodPrivateImg);
        scsProtected: if not bInherited then
            Node.ImageIndex := Ord(MethodProtectedImg)
          else
            Node.ImageIndex := Ord(InheritedMethodProtectedImg);
        scsPublic: if not bInherited then
            Node.ImageIndex := Ord(MethodPublicImg)
          else
            Node.ImageIndex := Ord(InheritedMethodPublicImg);
        scsNone: Node.ImageIndex := Ord(MethodPublicImg);
      end;
  end;
  Node.SelectedIndex := Node.ImageIndex ;

  bInherited := ClassBrowser.ShowInheritedMembers and  Member.IsInherited;
//  bInherited := ClassBrowser.ShowInheritedMembers and (Node.ImageIndex in [
//    Ord(InheritedMethodProtectedImg),
//    Ord(InheritedMethodPublicImg),
//    Ord(InheritedVariableProtectedImg),
//    Ord(InheritedVariablePublicImg) ]);

  if Stage = cdPrePaint then begin  //before draw the node's main text
    Sender.Canvas.Font.size := devData.InterfaceFontSize;
    Sender.Canvas.Font.Color := Font.Color; // clWindowText;   //ABLI added
    Sender.Canvas.Font.Style := [fsBold];
    if bInherited then
      Sender.Canvas.Font.Color := clGrayText;  //clGray; //ABLI modi
    //the node's main text is drawn by TCustomTreeView (Not discribed here)
  end else if Stage = cdPostPaint then begin //draw the node's other text
    try
      // Start drawing at top right corner of DisplayRect
      DrawRect := Node.DisplayRect(true);
      DrawPoint := Point(DrawRect.Right, DrawRect.Top);

      // Draw function arguments to the right of the already drawn text
      if Member.Args <> '' then begin
        Sender.Canvas.Brush.Color := Color;
        Sender.Canvas.Font.size := Font.size - 2;
        if (Font.Size >= 9) and (Sender.Canvas.Font.Size < 9) then
           Sender.Canvas.Font.Size := 9;

        if bInherited then
          Sender.Canvas.Font.Color := Font.Color //clGrayText //ABLI
        else
          Sender.Canvas.Font.Color := Font.Color; //clGrayText;
        Inc(DrawPoint.X, 4);
        Sender.Canvas.TextOut(DrawPoint.X, DrawPoint.Y + 2, Member.Args); // center vertically     //TODO. something may be wrong here
        Inc(DrawPoint.X, Sender.Canvas.TextWidth(Member.Args) + 2); // add some right padding
      end;

      if Member.TypeType <> '' then
        TypeText := Member.TypeType
      else
        TypeText := Member.MemberKindStr(Member.Kind);

      // Then draw node type to the right of the arguments
      if TypeText <> '' then begin
        Sender.Canvas.Font.Color := Font.Color;  //clGrayText; //ABLI
        Sender.Canvas.TextOut(DrawPoint.X + 2, DrawPoint.Y + 2, ': ' + TypeText); // center vertically
      end;
      DrawRect := Node.DisplayRect(true); ////
    except // stick head into sand method. sometimes during painting, the PStatement is invalid
           // this is caused by repainting while the CppParser is busy.
           // (Anbangli, 2026-1) Now we draw the Node according to TClassMember. Safer.
    end;
  end;
end;



// FindMenuItemByCommand: recursively search for a TMenuItem by command ID.
function FindMenuItemByCommand(parent: TMenuItem; cmd: Integer): TMenuItem;
var i: Integer;
begin Result := nil;
  for i := 0 to parent.Count - 1 do begin
    if parent.Items[i].Command = cmd then begin Result := parent.Items[i]; Exit; end;
    if parent.Items[i].Count > 0 then begin
      Result := FindMenuItemByCommand(parent.Items[i], cmd);
      if Assigned(Result) then Exit;
    end;
  end;
end;

// MenuHookProc: WH_MOUSE hook callback to detect hover over other toolbar buttons
// while the native TrackPopupMenu is running its own message loop.
function MenuHookProc(code: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  pt: TPoint;
  i: Integer;
  btnRect: TRect;
  btn: TToolButton;
begin
  pt := default(TPoint);
  Result := LongInt(CallNextHookEx(MenuHook, code, wParam, lParam));
  if code < 0 then Exit;
  if wParam = WM_MOUSEMOVE then begin
    GetCursorPos(pt);
    if Assigned(MainForm) and Assigned(MainForm.fMenuBar) then begin
      pt := MainForm.fMenuBar.ScreenToClient(pt);
      btn := nil;
      for i := 0 to MainForm.fMenuBar.ButtonCount - 1 do begin
        btnRect := MainForm.fMenuBar.Buttons[i].BoundsRect;
        if PtInRect(btnRect, pt) then begin btn := MainForm.fMenuBar.Buttons[i]; Break; end;
      end;
      if Assigned(btn) and (btn <> MenuHookLastBtn) then begin
        MenuHookLastBtn := btn;
        // Kill any pending timer and start a fresh 80ms delay
        if MenuHookTimerID <> 0 then KillTimer(MainForm.Handle, MenuHookTimerID);
        MenuHookTimerID := SetTimer(MainForm.Handle, 12345, 80, nil);
      end;
    end;
  end;
end;

end.
