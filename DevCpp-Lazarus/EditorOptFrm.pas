{
{$M+}
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

unit EditorOptFrm;

interface

uses
  {$IFDEF MSWINDOWS}Windows{$ELSE}LCLIntf, LCLType{$ENDIF}, SysUtils, Variants, Classes, Graphics, Controls, Forms, //Messages,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Spin,
  ATSynEdit, ATSynEdit_Gutter, ATSynEdit_Gutter_Decor,
  ATSynEdit_Adapter_EControl, ATSynEdit_Adapters, ATSynEdit_Colors, ATSynEdit_Bookmarks, ATStringProc,
  ColorBox, Buttons, StrUtils, Grids, //ClassBrowser, CppParser, CppTokenizer,
  CppPreprocessor;

type
  // Keep history of what we have accessed (does not mean changed)
  TEditorOptFormTabs = (taGeneral, taFonts, taColors, taSnippets, taCompletion, taAutosave);
  TEditorOptFormHistory = set of TEditorOptFormTabs;

  { TEditorOptForm }
  {$M+}
  TEditorOptForm = class(TForm)
    cbFirstZero: TCheckBox;
    cbLeadZero: TCheckBox;
    cbShowLineNumber: TCheckBox;
    cbMarginVis: TCheckBox;
    cbShowTopRuler: TCheckBox;
    cbShowMinimap: TCheckBox;
    cbShowMacromap: TCheckBox;
    cbWordWrap: TCheckBox;
    cbShowSpecialChars: TCheckBox;
    edMarginWidth: TSpinEdit;
    lblGutterWidth: TLabel;
    lblMarginWidth: TLabel;
    Memo1: TMemo;
    PagesMain: TPageControl;
    PanelBackground: TPanel;
    ScrollHint: TLabel;
    tabDisplay: TTabSheet;
    grpGutter: TGroupBox;
    cbGutterAuto: TCheckBox;
    cbGutterFnt: TCheckBox;
    lblGutterFont: TLabel;
    cboGutterFont: TComboBox;
    lblGutterFontSize: TLabel;
    edGutterSize: TSpinEdit;
    tabGeneral: TTabSheet;
    tabColor: TTabSheet;
    lblForeground: TLabel;
    lblBackground: TLabel;
    CodeEdit: TATSynEdit;
    ElementList: TListBox;
    grpStyle: TGroupBox;
    cbBold: TCheckBox;
    cbItalic: TCheckBox;
    cbUnderlined: TCheckBox;
    grpEditorFont: TGroupBox;
    lblEditorSize: TLabel;
    lblEditorFont: TLabel;
    cboEditorFont: TComboBox;
    edEditorSize: TSpinEdit;
    grpCaret: TGroupBox;
    lblInsertCaret: TLabel;
    lblOverCaret: TLabel;
    cboInsertCaret: TComboBox;
    cboOverwriteCaret: TComboBox;
    tabCPInserts: TTabSheet;
    tabCPDefault: TTabSheet;
    btnAdd: TButton;
    btnRemove: TButton;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    btnHelp: TBitBtn;
    cboColorScheme: TComboBox;
    lblSpeed: TLabel;
    SnippetEdit: TATSynEdit;
    btnSaveSyntax: TSpeedButton;
    cbMatch: TCheckBox;
    grpEditorOpts: TGroupBox;
    edGutterWidth: TSpinEdit;
    cbSmartScroll: TCheckBox;
    cbScrollHint: TCheckBox;
    cbPastEOL: TCheckBox;
    cbPastEOF: TCheckBox;
    cbParserHints: TCheckBox;
    cbInsertMode: TCheckBox;
    cbHalfPage: TCheckBox;
    cbGroupUndo: TCheckBox;
    cbFindText: TCheckBox;
    cbEHomeKey: TCheckBox;
    cbDropFiles: TCheckBox;
    cbAddIndent: TCheckBox;
    cbAutoIndent: TCheckBox;
    cbTrimTrailingSpaces: TCheckBox;
    tabAutosave: TTabSheet;
    cbAutoSave: TCheckBox;
    cbFunctionHint: TCheckBox;
    edSyntaxExt: TEdit;
    cbSyntaxHighlight: TCheckBox;
    grpTabs: TGroupBox;
    seTabSize: TSpinEdit;
    lblTabSize: TLabel;
    cbUseTabs: TCheckBox;
    cbSmartTabs: TCheckBox;
    cbDefaultCode: TCheckBox;
    DefaultEdit: TATSynEdit;
    lvCodeIns: TStringGrid;
    cpForeground: TColorBox;
    cpBackground: TColorBox;
    cbHighCurrLine: TCheckBox;
    grpDisplay: TGroupBox;
    lblMarginColor: TLabel;
    cpMarginColor: TColorBox;
    cbUseCodeFold: TCheckBox;
    cbClickCodeFold: TCheckBox;
    lblMacros: TLabel;
    GroupBox1: TGroupBox;
    seSaveInteval: TSpinEdit;
    lblSaveInterval: TLabel;
    lblSaveFiles: TLabel;
    cmbSaveFiles: TComboBox;
    lblFileName: TLabel;
    cmbFileName: TComboBox;
    lblTimeStampExample: TLabel;
    GroupBox2: TGroupBox;
    chkEnableCompletion: TCheckBox;
    chkFunctionHints: TCheckBox;
    chkMemberCompletion: TCheckBox;
    chkIdentCompletion: TCheckBox;
    seCompletionDelay: TSpinEdit;
    lblCompletionDelay: TLabel;
    gbCBEngine: TGroupBox;
    chkCBParseLocalH: TCheckBox;
    chkCBParseGlobalH: TCheckBox;
    lblCompletionColor: TLabel;
    lblCompletionColor2: TLabel;
    lblCompletionColor3: TLabel;
    cpCompletionBackground: TColorBox;
    cpCompletionTextColor: TColorBox;
    cpCompletionHighColor: TColorBox;
    GroupBox3: TGroupBox;
    cbSymbolComplete: TCheckBox;
    cbBraces: TCheckBox;
    cbParenth: TCheckBox;
    cbArray: TCheckBox;
    cbInclude: TCheckBox;
    cbSingleQuotes: TCheckBox;
    cbDoubleQuotes: TCheckBox;
    cbComments: TCheckBox;
    cbDeleteCompleted: TCheckBox;
    lblTest: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure SetGutter(ed: TATSynEdit);
    procedure ApplyCurLineColors;
    procedure SetupPreviewBookmarks(Ed: TATSynEdit);
    procedure SetupPreviewGutterDecor(Ed: TATSynEdit);
    procedure ApplyColorSchemeToEditors;
    procedure ElementListClick(Sender: TObject);
    procedure EditorStatusChange(Sender: TObject);
    procedure StyleChange(Sender: TObject);
    procedure cbShowLineNumberClick(Sender: TObject);
    procedure cbSyntaxHighlightClick(Sender: TObject);
    procedure cbGutterFntClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure CodeInsStatusChange(Sender: TObject);
    procedure cboColorSchemeSelect(Sender: TObject);
    procedure EditorOptDrawLine(Sender: TObject; C: TCanvas;
      ALineIndex: integer; AX, AY: integer; const AStr: atString;
      const ACharSize: TATEditorCharSize; constref AExtent: TATIntFixedArray);
    procedure EditorCalcBookmarkColor(Sender: TObject; ABookmarkKind: integer; var AColor: TColor);
    procedure CppEditSpecialLineColors(Sender: TObject; Line: Integer; var Special: Boolean; var FG, BG: TColor);
    procedure chkEnableCompletionClick(Sender: TObject);
    procedure btnSaveSyntaxClick(Sender: TObject);
    procedure OnGutterClick(Sender: TObject; Button: TMouseButton; X, Y, Line: Integer; Mark: Integer);
    procedure cbAutoSaveClick(Sender: TObject);
    procedure cbSymbolCompleteClick(Sender: TObject);
    procedure cboEditorFontDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cboGutterFontDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure edEditorSizeChange(Sender: TObject);
    procedure edGutterSizeChange(Sender: TObject);
    procedure cboEditorFontChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure lvCodeInsSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure PagesMainChange(Sender: TObject);
    procedure cbUseCodeFoldClick(Sender: TObject);
    procedure cmbFileNameChange(Sender: TObject);
  private
    ffgColor: TColor;
    fbgColor: TColor;
    fBPColor: TPoint;
    fErrColor: TPoint;
    fABPColor: TPoint;
    fBMColor: TPoint;
    fSelColor: TPoint;
    fCurColor: TPoint;
    fGutColor: TPoint;
    fEditColor: TPoint;
    fFoldColor: TPoint;
    fFoldColor2: TPoint;
    fColorElems: array[0..26] of string;
    procedure LoadFonts;
    procedure LoadText;
    procedure LoadCodeIns;
    procedure SaveCodeIns;
    procedure ClearCodeIns;
    procedure UpdateCIButtons;
    procedure LoadColorScheme(const Value: String);
    procedure FillColorSchemes;
  public
    AccessedTabs: TEditorOptFormHistory;
  end;

implementation

uses
  MultiLangSupport, devcfg, version, utils, CommCtrl, DateUtils, CodeInsList, DataFrm, IniFiles, editor,
  ec_syntanal, ec_syntax_format, main;

{$R *.lfm}
const


  cABreakLine = 7;  // 0-based (was 8)
  cBreakLine = 8;   // 0-based (was 9)
  cErrorLine = 10;  // 0-based (was 11)
  cSelection = 2;  // 0-based (was 3)
  cCurrentLine = 4;  // 0-based (was 14)
  cBookmarkLine = 1; // 0-based, line for bookmark preview

  // Bookmark kind constants for preview special line backgrounds
  BK_SELECTION       = 100;
  BK_CURRENT         = 101;
  BK_BREAKPOINT      = 102;
  BK_ACTIVEBREAKPOINT= 103;
  BK_ERROR           = 104;
  BK_BOOKMARK        = 105;



procedure TEditorOptForm.FormCreate(Sender: TObject);
var
  AttrName: String;
  pt: TPoint;
  I: integer;
//  scale: Real;
//  sample: TStringList;
//  gp: TATGutterPartLineNumbers;
begin
  tabGeneral.Font.Name := devdata.InterfaceFont;
  tabGeneral.Font.Size := devdata.InterfaceFontSize;
  tabDisplay.Font.Name := devdata.InterfaceFont;
  tabDisplay.Font.Size := devdata.InterfaceFontSize;

  //adjust components' size for screen HighDPI
  //now handled by LCL auto-scaling (Scaled=True, DesignTimePPI=96 in LFM)
//  scale := Screen.PixelsPerInch / 96;  //original dpi is 96
//  cboInsertCaret.Height := ceil(cboInsertCaret.Height * scale);
//  cboOverwriteCaret.Height := ceil(cboOverwriteCaret.Height * scale);
//  cboColorScheme.Height := ceil(cboColorScheme.Height * scale);
//  cpForeground.Height := ceil(cpForeground.Height * scale);
//  cpBackground.Height := ceil(cpBackground.Height * scale);
//  cpCompletionBackground.Height := ceil(cpCompletionBackground.Height * scale);
//  cpCompletionTextColor.Height := ceil(cpCompletionTextColor.Height * scale);
//  cpCompletionHighColor.Height := ceil(cpCompletionHighColor.Height * scale);
//  lvCodeIns.DefaultRowHeight := ceil(lvCodeIns.DefaultRowHeight * scale);

  LoadText;

  // Set up EControl adapters for syntax highlighting preview editors
  with CodeEdit do begin
    AdapterForHilite := TATAdapterHilite(dmMain.GetHighlighter('preview.cpp'));
    if Assigned(AdapterForHilite) and (AdapterForHilite is TATAdapterEControl) then begin
      TATAdapterEControl(AdapterForHilite).AddEditor(CodeEdit);
    end;
  end;
  with SnippetEdit do begin
    AdapterForHilite := TATAdapterHilite(dmMain.GetHighlighter('preview.cpp'));
    if Assigned(AdapterForHilite) and (AdapterForHilite is TATAdapterEControl) then begin
      TATAdapterEControl(AdapterForHilite).AddEditor(SnippetEdit);
    end;
  end;
  with DefaultEdit do begin
    AdapterForHilite := TATAdapterHilite(dmMain.GetHighlighter('preview.cpp'));
    if Assigned(AdapterForHilite) and (AdapterForHilite is TATAdapterEControl) then begin
      TATAdapterEControl(AdapterForHilite).AddEditor(DefaultEdit);
    end;
  end;

  //Sample source code for syntax highlighting preview
  CodeEdit.Text :=
    '/* Sample source code */'#13#10 +
    '#include <stdio.h> //bookmark'#13#10 +
    '//selected text  '#13#10 +
    'int main() { '#13#10 +
    '  int a = 1, b = 1; //current line'#13#10 +
    '  int n = 20.0ABC;  //illegal'#13#10 +
    '  for (i = 0; i < n; i++) {'#13#10 +
    '    b = a + b; //active breakpoint'#13#10 +
    '    a = b - a; //breakpoint'#13#10 +
    '  }'#13#10 +
    '    a + b;  //error line'#13#10 +
    '    printf("last=%d", b); //string'#13#10 +
    '    putchar(''\n''); //char'#13#10 +
    '    return 0;    '#13#10 +
    '}';
  for I := 0 to CodeEdit.Strings.Count -1 do
    CodeEdit.Strings.LinesState[I] := TATLineState.Saved;

  CodeEdit.Strings.LinesState[3] := TATLineState.Changed;
  CodeEdit.Strings.LinesState[4] := TATLineState.Changed;

  CodeEdit.Strings.LinesState[5] := TATLineState.Added;
  CodeEdit.Strings.LinesState[6] := TATLineState.Added;

  // Force initial parse after text is loaded for all preview editors
  pt := Point(0, 0);  //initialize
  if Assigned(CodeEdit.AdapterForHilite) and (CodeEdit.AdapterForHilite is TATAdapterEControl) then begin
    TATAdapterEControl(CodeEdit.AdapterForHilite).ParseFromLine(0, True);
    with devEditor do
      if ColorScheme.IndexOfName('Space') >= 0 then begin
        StrtoPoint(pt, ColorScheme.Values['Space']);
        if pt.X <> clNone then
          CodeEdit.Colors.TextBG := pt.X;
      end;
    CodeEdit.Invalidate;
  end;
  if Assigned(SnippetEdit.AdapterForHilite) and (SnippetEdit.AdapterForHilite is TATAdapterEControl) then begin
    TATAdapterEControl(SnippetEdit.AdapterForHilite).ParseFromLine(0, True);
    with devEditor do
      if ColorScheme.IndexOfName('Space') >= 0 then begin
        StrtoPoint(pt, ColorScheme.Values['Space']);
        if pt.X <> clNone then
          SnippetEdit.Colors.TextBG := pt.X;
      end;
    SnippetEdit.Invalidate;
  end;
  if Assigned(DefaultEdit.AdapterForHilite) and (DefaultEdit.AdapterForHilite is TATAdapterEControl) then begin
    TATAdapterEControl(DefaultEdit.AdapterForHilite).ParseFromLine(0, True);
    with devEditor do
      if ColorScheme.IndexOfName('Space') >= 0 then begin
        StrtoPoint(pt, ColorScheme.Values['Space']);
        if pt.X <> clNone then
          DefaultEdit.Colors.TextBG := pt.X;
      end;
    DefaultEdit.Invalidate;
  end;

  // Use bookmark system for special line backgrounds (ATSynedit renders bookmark BG BEFORE text)
  SetupPreviewBookmarks(CodeEdit);
  //SetupPreviewBookmarks(SnippetEdit);
  //SetupPreviewBookmarks(DefaultEdit);

  // Set up GutterDecor for all three preview editors (breakpoint icons on line numbers)
  SetupPreviewGutterDecor(CodeEdit);
  //SetupPreviewGutterDecor(SnippetEdit);
  //SetupPreviewGutterDecor(DefaultEdit);

  // Move caret to cCurrentLine line so OptShowCurLine / CurrentLineBG highlights it
  if CodeEdit.Carets.Count > 0 then
    CodeEdit.Carets[0].PosY := cCurrentLine;

  with devEditor do begin
    // Make editors look similar to main ones (assign same font)
    CodeEdit.Font.Assign(Font);
    CodeEdit.Font.Name := Font.Name;  //WideFontName;
    CodeEdit.Font.Size := 11;  //devData.InterfaceFontSize;

    //sample source code written in CodeEdit.Lines
    //CodeEdit.Lines:= sample;

    SnippetEdit.Font.Assign(devEditor.Font);
    SnippetEdit.Font.Size := devData.InterfaceFontSize;
    SnippetEdit.Font.Name := Font.Name;   //WideFontName;
    DefaultEdit.Font.Assign(devEditor.Font);
    DefaultEdit.Font.Size := devData.InterfaceFontSize;
    DefaultEdit.Font.Name := Font.Name; //WideFontName;

    // Gutters too - set font via Parts API

//      gp := TATGutterPartLineNumbers(CodeEdit.Gutter.Parts.ByClass(TATGutterPartLineNumbers));
//      if Assigned(gp) then gp.Font.Assign(Gutterfont);
//      gp := TATGutterPartLineNumbers(SnippetEdit.Gutter.Parts.ByClass(TATGutterPartLineNumbers));
//      if Assigned(gp) then gp.Font.Assign(Gutterfont);
//      gp := TATGutterPartLineNumbers(DefaultEdit.Gutter.Parts.ByClass(TATGutterPartLineNumbers));
//      if Assigned(gp) then gp.Font.Assign(Gutterfont);


    //1. General
    cbGutterAuto.Checked := GutterAuto;
    edGutterWidth.Value := GutterSize;
    cbAutoIndent.Checked := AutoIndent;
    cbAddIndent.Checked := AddIndent;
    cbInsertMode.Checked := InsertMode;
    cbUseTabs.Checked := UseTabs;
    cbSmartTabs.Checked := SmartTabs;
    cbGroupUndo.Checked := GroupUndo;
    cbEHomeKey.Checked := EHomeKey;
    cbPastEOF.Checked := PastEOF;
    cbPastEOL.Checked := PastEOL;
    cbFindText.Checked := FindText;
    cbSmartScroll.Checked := Scrollbars;
    cbHalfPage.Checked := HalfPageScroll;
    cbScrollHint.Checked := ScrollHint;

    //cbShowEndOfLine.Checked := ShowEndOfLine;

//    cbFunctionHint.Checked := ShowFunctionTip;

    cbUseCodeFold.Checked := UseCodeFold;
    cbClickCodeFold.Checked := ClickCodeFold;
    cbClickCodeFold.Enabled := UseCodefold;
    cbTrimTrailingSpaces.Checked := TrimTrailingSpaces;
    cbMarginVis.Checked := MarginVis;
    edMarginWidth.Value := MarginSize;
    cpMarginColor.Selected := MarginColor;
    seTabSize.Value := TabSize;
    cbSyntaxHighlight.Checked := UseSyntax;
    edSyntaxExt.Text := SyntaxExt;
    cboInsertCaret.ItemIndex := InsertCaret;
    cboOverwriteCaret.ItemIndex := OverwriteCaret;
    cbDropFiles.Checked := InsDropFiles;
    cbParserHints.Checked := ParserHints;
    cbMatch.Checked := Match;
    cbDefaultCode.Checked := DefaultCode;
    cbHighCurrLine.Checked := HighCurrLine;

    //2. Display
    LoadFonts; // fill dropdowns
    cboEditorFont.ItemIndex := cboEditorFont.Items.IndexOf(Font.Name);
    edEditorSize.Value := Font.Size;
    cbGutterFnt.Checked := Gutterfnt;
    cboGutterFont.ItemIndex := cboGutterFont.Items.IndexOf(Gutterfont.Name);
    edGutterSize.Value := GutterFont.Size;

    cbShowSpecialChars.Checked := ShowSpecialChars;
    cbWordWrap.checked := WordWrap;
    cbShowTopRuler.checked := ShowTopRuler;
    cbShowMinimap.checked := ShowMinimap;
    cbShowMacromap.checked := ShowMacromap;

    cbShowLineNumber.Checked := LineNumbers;
    cbLeadZero.Checked := LeadZero;
    cbFirstZero.Checked := FirstLineZero;

    //3. Colors (Syntax Highlighter)
    FillColorSchemes; // Load Color Schemes

    cboColorScheme.ItemIndex := SchemeIndex;
    StrtoPoint(fBPColor, ColorScheme.Values[cBP]);
    StrtoPoint(fErrColor, ColorScheme.Values[cErr]);
    StrtoPoint(fABPColor, ColorScheme.Values[cABP]);
    StrtoPoint(fBMColor, ColorScheme.Values[cBM]);
    StrtoPoint(fSelColor, ColorScheme.Values[cSel]);
    StrtoPoint(fCurColor, ColorScheme.Values[cCur]);
    StrtoPoint(fGutColor, ColorScheme.Values[cGut]);
    StrtoPoint(fEditColor, ColorScheme.Values[cEdt]);
    StrtoPoint(fFoldColor, ColorScheme.Values[cFld]);
    StrtoPoint(fFoldColor2, ColorScheme.Values[cFld2]);
  end;

  // Apply Current line colors to preview editors
  ApplyCurLineColors;

  //3. Colors (Syntax Highlighter), cont.
  ElementList.Items.BeginUpdate;
  try
    ElementList.Clear;
    // Initialize known syntax element names
    //在 fColorElems 中存放了 语法高亮 的槽位（英文），
    for I := 0 to ColorSyntax + ColorSpecial - 1 do begin
      fColorElems[I] := ColorElemNames[I];
    end;
    //Must be consistent with the ColorElemNames constant in devCFG.pas

    // Populate ElementList from known syntax element names
    //These names should be same as in TdevEditor.SettoDefaults !
    //Items have to add to ElementList by hand. LangID is not sequenial
    //列表框 ElementList 中存放相应的本地语言名称（必须手工添加。因为语言词条未按顺序）
    ElementList.Items.Add(Lang[ID_COLOR_SPACE]);
    ElementList.Items.Add(Lang[ID_COLOR_COMMENT]);
    ElementList.Items.Add(Lang[ID_COLOR_PREPROCESS]);
    ElementList.Items.Add(Lang[ID_COLOR_RESERVEDWORD]);
    ElementList.Items.Add(Lang[ID_COLOR_IDENTIFIER]);
    ElementList.Items.Add(Lang[ID_COLOR_SYMBOL]);
    ElementList.Items.Add(Lang[ID_COLOR_NUMFLOAT]);
    ElementList.Items.Add(Lang[ID_COLOR_NUMBER]);
    ElementList.Items.Add(Lang[ID_COLOR_NUMOCTAL]);
    ElementList.Items.Add(Lang[ID_COLOR_NUMHEX]);
    ElementList.Items.Add(Lang[ID_COLOR_STRING]);
    ElementList.Items.Add(Lang[ID_COLOR_CHARACTER]);
    ElementList.Items.Add(Lang[ID_COLOR_ASSEMBLER]);
    ElementList.Items.Add(Lang[ID_COLOR_INCORRECT]);

    ElementList.Items.Add(Lang[ID_COLOR_BREAKPOINTS]);
    ElementList.Items.Add(Lang[ID_COLOR_ERRORLINE]);
    ElementList.Items.Add(Lang[ID_COLOR_ACTIVEBREAK]);
    ElementList.Items.Add(Lang[ID_COLOR_BOOKMARK]);
    ElementList.Items.Add(Lang[ID_COLOR_SELECTED]);
    ElementList.Items.Add(Lang[ID_COLOR_CURRENT]);
    ElementList.Items.Add(Lang[ID_COLOR_GUTTER]);
    ElementList.Items.Add(Lang[ID_COLOR_EDITSTAT]);
    ElementList.Items.Add(Lang[ID_COLOR_FOLDINGLINE]);
    ElementList.Items.Add(Lang[ID_COLOR_FOLDINGLINE2]);



    // TODO: EControl adapter - use default colors
    ffgColor := clNone;
    fbgColor := clNone;
  finally
     ElementList.Items.EndUpdate; // redraw once
  end;

  // Ensure UI is set correctly
  if (ElementList.Items.Count > 0) and (ElementList.Items.Count > devEditor.ElemIndex) then begin
    ElementList.ItemIndex := devEditor.ElemIndex;   //focus on item clicked last time
    ElementListClick(nil);
  end;

  //4. Snippets, Inserts
  LoadCodeIns;
  UpdateCIButtons;

  // Snippets, Default Insert
  if FileExists(devDirs.Config + DEV_DEFAULTCODE_FILE) then begin
    DefaultEdit.Strings.LoadFromFile(devDirs.Config + DEV_DEFAULTCODE_FILE, []);
    // Re-parse for syntax highlighting after loading text
    if Assigned(DefaultEdit.AdapterForHilite) and (DefaultEdit.AdapterForHilite is TATAdapterEControl) then
      TATAdapterEControl(DefaultEdit.AdapterForHilite).ParseFromLine(0, True);
  end;

  //5. Code Completion
  chkEnableCompletion.Checked := devCodeCompletion.Enabled;
  chkFunctionHints.Checked := devCodeCompletion.ShowFunctionHints;
  chkMemberCompletion.Checked := devCodeCompletion.ShowMemberCompletion;
  chkIdentCompletion.Checked := devCodeCompletion.ShowIdentCompletion;
  chkCBParseLocalH.Checked := devCodeCompletion.ParseLocalHeaders;
  chkCBParseGlobalH.Checked := devCodeCompletion.ParseGlobalHeaders;
  seCompletionDelay.value := devCodeCompletion.Delay;
  cpCompletionBackground.Selected := devCodeCompletion.BackColor;
  cpCompletionTextColor.Selected := devCodeCompletion.TextColor;
  cpCompletionHighColor.Selected := devCodeCompletion.HighColor;
  chkEnableCompletionClick(nil);

  // Symbol Completion
  with devEditor do begin
    cbSymbolComplete.Checked := CompleteSymbols;
    cbDeleteCompleted.Checked := DeleteSymbolPairs;
    cbArray.Checked := ArrayComplete;
    cbBraces.Checked := BraceComplete;
    cbComments.Checked := CommentComplete;
    cbInclude.Checked := IncludeComplete;
    cbParenth.Checked := ParentheseComplete;
    cbSingleQuotes.Checked := SingleQuoteComplete;
    cbDoubleQuotes.Checked := DoubleQuoteComplete;

    // Completion. Only enable if CompleteSymbols is true
    cbSymbolCompleteClick(nil);

    //7. Autosave
    cbAutoSave.Checked := devEditor.EnableAutoSave;
    seSaveInteval.Value := devEditor.Interval;
    cmbSaveFiles.ItemIndex := devEditor.AutoSaveFilter;
    cmbFileName.ItemIndex := devEditor.AutoSaveMode;

    cbAutoSaveClick(nil);
    cmbFileNameChange(nil);
  end;

  //3. Colors (Syntax Highlighter), cont. 2
  SetGutter(CodeEdit);
  SetGutter(SnippetEdit);
  SetGutter(DefaultEdit);

  // Set defaults of color buttons, don't want all system colors too
  cpMarginColor.Items.InsertObject(1, 'Default', TObject(PtrInt(cpMarginColor.DefaultColorColor)));
  cpCompletionBackground.Items.InsertObject(1, 'Default', TObject(PtrInt(cpCompletionBackground.DefaultColorColor)));
  cpCompletionTextColor.Items.InsertObject(1, 'Default', TObject(PtrInt(cpCompletionTextColor.DefaultColorColor)));
  cpCompletionHighColor.Items.InsertObject(1, 'Default', TObject(PtrInt(cpCompletionHighColor.DefaultColorColor)));

end;

procedure TEditorOptForm.cboEditorFontDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State:
  TOwnerDrawState);
var
  alignleft: integer;
  aligntop: integer;
begin
  with TComboBox(Control) do begin
    Canvas.Font.Name := Items.Strings[Index];
    Canvas.Font.Size := edEditorSize.Value;
    Canvas.FillRect(Rect);
    alignleft := (Rect.Right - Rect.Left) div 2 - Canvas.TextWidth(Canvas.Font.Name) div 2;
    aligntop := Rect.Top + (Rect.Bottom - Rect.Top) div 2 - Canvas.TextHeight(Canvas.Font.Name) div 2;
    Canvas.TextOut(alignleft, aligntop, Canvas.Font.Name);
  end;
end;

procedure TEditorOptForm.cboGutterFontDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State:
  TOwnerDrawState);
var
  alignleft: integer;
  aligntop: integer;
begin
  with TComboBox(Control) do begin

    if cbGutterFnt.Checked then begin
      Canvas.Font.Name := Items.Strings[Index];
      Canvas.Font.Size := edGutterSize.Value;
    end else begin
      Canvas.Font.Name := cboEditorFont.Text;
      Canvas.Font.Size := edEditorSize.Value;
    end;
    Canvas.FillRect(Rect);
    alignleft := (Rect.Right - Rect.Left) div 2 - Canvas.TextWidth(Canvas.Font.Name) div 2;
    aligntop := Rect.Top + (Rect.Bottom - Rect.Top) div 2 - Canvas.TextHeight(Canvas.Font.Name) div 2;
    Canvas.TextOut(alignleft, aligntop, Canvas.Font.Name);
  end;
end;

procedure TEditorOptForm.cboEditorFontChange(Sender: TObject);
begin
  if not cbGutterfnt.Checked then
    cboGutterFont.ItemIndex := cboEditorFont.ItemIndex;
  cboGutterFont.Repaint;
end;

procedure TEditorOptForm.edEditorSizeChange(Sender: TObject);
begin
  if not cbGutterfnt.Checked then
    edGutterSize.Value := edEditorSize.Value;
  cboEditorFont.Repaint;
  cboGutterFont.Repaint;
end;

procedure TEditorOptForm.edGutterSizeChange(Sender: TObject);
begin
  cboGutterFont.Repaint;
end;

procedure TEditorOptForm.cbGutterFntClick(Sender: TObject);
begin
  cboGutterFont.Enabled := cbGutterFnt.Checked;
  edGutterSize.Enabled := cbGutterfnt.Checked;
  if not cbGutterfnt.Checked then begin
    cboGutterFont.ItemIndex := cboEditorFont.ItemIndex;
    edGutterSize.Value := edEditorSize.Value;
  end;
end;

// Fill listboxes with available fonts

{$IFDEF MSWINDOWS}
type
  // 字体枚举回调用的数据块（回调函数不能访问外层局部变量，故由 LPARAM 传入）
  TFontEnumData = record
    Names: TStringList;
  end;
  PFontEnumData = ^TFontEnumData;

// EnumFontFamiliesExW 回调：只收集"等宽、且适合代码编辑"的字体。
//
// 这里必须用 W（Unicode）版而不是默认的 A 版：A 版回调里 lfFaceName 是 CP_ACP 字节
// （本机即 GBK），而 LCL 内部字符串一律是 UTF-8，把 GBK 字节直接当 UTF-8 用就是非法序列，
// 界面上"宋体"/"楷体"这类中文字体名会显示成 "????"。W 版直接给 UTF-16 字体名，
// UTF8Encode 后即为合法 UTF-8，与 LCL 自己的 Screen.Fonts 完全同源同编码。
//
// 判据全部取自 Windows 对字体自身的描述，与 DPI、字号无关：
//   1) FIXED_PITCH      lfPitchAndFamily 低位。等宽字体（Consolas / Courier New / Lucida Console /
//                       Cascadia Mono / 各种 CJK 等宽字体）为 1；比例字体（Segoe UI / Arial）以及
//                       Marlett / Wingdings / Webdings / Symbol 等符号字体为 0，直接排除。
//   2) SYMBOL_CHARSET   符号字体，其"字符"不是文字。
//   3) '@' 开头的名字   竖排（旋转 90°）字体。
//   4) RASTER_FONTTYPE  位图字体（Fixedsys / Terminal / Courier），不能缩放，编辑器用不上。
function EnumFixedPitchFontProc(var LogFont: ENUMLOGFONTEXW; var TextMetric: NEWTEXTMETRICEXW;
  FontType: LongInt; Data: LPARAM): LongInt; stdcall;
var
  Info: PFontEnumData;
  WS: WideString;
  FaceName: String;
begin
  Result := 1; // 返回值非 0：继续枚举
  Info := PFontEnumData(Data);
  // UTF-16 字体名 -> UTF-8。套一层 String(...) 强制转型，避免 FPC 的代码页自动转换再改一次字节
  WS := LogFont.elfLogFont.lfFaceName;
  FaceName := String(UTF8Encode(WS));
  if (FaceName = '') or (FaceName[1] = '@') then Exit;
  if LogFont.elfLogFont.lfCharSet = SYMBOL_CHARSET then Exit;
  if (LogFont.elfLogFont.lfPitchAndFamily and FIXED_PITCH) = 0 then Exit;
  if (FontType and RASTER_FONTTYPE) <> 0 then Exit;
  if Info^.Names.IndexOf(FaceName) < 0 then
    Info^.Names.Add(FaceName);
end;

// 直接向 Windows 枚举"适合代码编辑器"的等宽字体，写入 List。
//
// 不用 Screen.Fonts + 文本宽度启发式过滤，原因：Screen.Fonts 会列出全部两百多种字体
// （含 Arial / Segoe UI 等比例字体、'@' 竖排字体、Wingdings 等符号字体），随后只能靠
// Canvas 的像素宽度阈值去筛，而阈值随字号 / DPI 变化——窗体字体为 10pt 时 Consolas 的
// 'W' 只有 7px，会被 "<= 8 (Fixedsys)" 那一条误删（Courier New / Lucida Console 的 8px
// 同样被误删），于是列表中看不到 Consolas。改用字体自带的 FIXED_PITCH 标志即可与 DPI 无关。
procedure FillMonospaceFonts(List: TStrings);
var
  Info: TFontEnumData;
  LogFont: LOGFONTW;
  DC: HDC;
begin
  List.BeginUpdate;
  try
    List.Clear;
    Info.Names := TStringList.Create;
    try
      Info.Names.CaseSensitive := False;
      Info.Names.Duplicates := dupIgnore;
      Info.Names.Sorted := True;
      FillChar(LogFont, SizeOf(LogFont), 0);
      LogFont.lfCharSet := DEFAULT_CHARSET; // 枚举所有字符集，CJK 字体名也要收
      LogFont.lfFaceName[0] := #0;
      LogFont.lfPitchAndFamily := 0;
      DC := GetDC(0);
      try
        EnumFontFamiliesExW(DC, LogFont, @EnumFixedPitchFontProc, LPARAM(@Info), 0);
      finally
        ReleaseDC(0, DC);
      end;
      List.Assign(Info.Names);
    finally
      Info.Names.Free;
    end;
  finally
    List.EndUpdate;
  end;
end;
{$ENDIF}

// 列表里只剩等宽字体，若某个字体名不在其中则补进去，免得下拉框显示成空白。
procedure EnsureFontInList(List: TStrings; const FontName: String);
begin
  if (FontName = '') or (List.IndexOf(FontName) >= 0) then Exit;
  List.Add(FontName); // 列表是 Sorted 的，Add 会自动插到正确位置
end;

procedure TEditorOptForm.LoadFonts;
begin
  // 只列"适合代码编辑器"的等宽字体（见 FillMonospaceFonts 的说明）
{$IFDEF MSWINDOWS}
  FillMonospaceFonts(cboEditorFont.Items);
{$ELSE}
  // Sum up all the available fonts
  cboEditorFont.Items.Assign(Screen.Fonts);  //Editor Fonts list
  //Screen.Fonts: Lists the face names for all fonts supported by the screen.
{$ENDIF}

  // 当前设置的两个字体（编辑器字体 / 行号字体）若不是等宽字体则补进列表，免得下拉框空白。
  // 这两个名字与 FormCreate 里"2. Fonts"段的写法一致（那里在 with devEditor do 内，
  // Font / Gutterfont 指的是 devEditor 的成员）。
  // 两个列表必须完全一致：cboEditorFontChange / cbGutterFntClick 依赖两者的下标对应。
  EnsureFontInList(cboEditorFont.Items, devEditor.Font.Name);
  EnsureFontInList(cboEditorFont.Items, devEditor.Gutterfont.Name);

  cboGutterFont.Items := cboEditorFont.Items;  //Gutter Fonts list

  cbShowLineNumberClick(nil);
  cbGutterFntClick(nil);
end;

{ ---------- Form Init/Done Methods ----------}

procedure TEditorOptForm.LoadText;
begin
  // Set interface font
  Font.Name := devData.InterfaceFont;
  Font.Size := devData.InterfaceFontSize;

  btnOk.Caption := Lang[ID_BTN_OK];
  btnCancel.Caption := Lang[ID_BTN_CANCEL];
  btnHelp.Caption := Lang[ID_BTN_HELP];

  // Top level tabs
  Caption := Lang[ID_EOPT];
  tabGeneral.Caption := Lang[ID_EOPT_GENTAB];
  tabDisplay.Caption := Lang[ID_EOPT_DISPLAYTAB];
  tabColor.Caption := Lang[ID_EOPT_COLORTAB];
  //tabCode.Caption := Lang[ID_EOPT_CODETAB];
  //tabCBCompletion.Caption := Lang[ID_EOPT_COMPLETIONTAB];
  //tabCodeCompletion.Caption := Lang[ID_EOPT_CODECOMPLETIONTAB];
  tabAutosave.Caption := Lang[ID_EOPT_AUTOSAVETAB];

  // Sub tabs (inserts)
  tabCPInserts.Caption := Lang[ID_EOPT_CODETAB];  //ID_EOPT_CPINSERTS];
  tabCPDefault.Caption := Lang[ID_EOPT_CPDEFAULT];

  // Sub tabs (completion)
  //tabSymbolCompletion.Caption := Lang[ID_EOPT_CPSYMBOLS];

  // General Tab
  grpEditorOpts.Caption := Lang[ID_EOPT_EDOPTIONS];
  cbAutoIndent.Caption := Lang[ID_EOPT_AUTOINDENT2];
  cbInsertMode.Caption := Lang[ID_EOPT_INSERTMODE];

  cbGroupUndo.Caption := Lang[ID_EOPT_GROUPUNDO];
  cbDropFiles.Caption := Lang[ID_EOPT_DROPFILES];
  //cbShowEndOfLine.Caption := Lang[ID_ITEM_ENDOFLINE];

  cbTrimTrailingSpaces.Caption := Lang[ID_EOPT_TRIMTRAILINGSPACES];
  cbEHomeKey.Caption := Lang[ID_EOPT_EHOMEKEY];
  cbPastEOF.Caption := Lang[ID_EOPT_PASTEOF];
  cbPastEOL.Caption := Lang[ID_EOPT_PASTEOL];
  cbAddIndent.Caption := Lang[ID_EOPT_ADDINDENT];
  cbFindText.Caption := Lang[ID_EOPT_FINDTEXT];
  cbSmartScroll.Caption := Lang[ID_EOPT_SMARTSCROLL];
  cbHalfPage.Caption := Lang[ID_EOPT_HALFPAGE];
  cbScrollHint.Caption := Lang[ID_EOPT_SCROLLHINT];
  cbParserHints.Caption := Lang[ID_EOPT_PARSERHINTS];
  cbFunctionHint.Caption := Lang[ID_EOPT_CLOSEBRACE];
  ScrollHint.Caption := Lang[ID_EOPT_CTRLSCROLLHINT];
  cbSyntaxHighlight.Caption := Lang[ID_EOPT_USESYNTAX];

  cbUseCodeFold.Caption := Lang[ID_EOPT_USECODEFOLDING];
  cbClickCodeFold.Caption := Lang[ID_EOPT_CLICKCODEFOLDING];

  grpCaret.Caption := Lang[ID_EOPT_CARET];
  lblInsertCaret.Caption := Lang[ID_EOPT_INSCARET];
  lblOverCaret.Caption := Lang[ID_EOPT_OVERCARET];
  cbMatch.Caption := Lang[ID_EOPT_MATCH];

  grpTabs.Caption := Lang[ID_EOPT_TABS];
  lblTabSize.Caption := Lang[ID_EOPT_TABSIZE];
  cbUseTabs.Caption := Lang[ID_EOPT_TAB2SPC];
  cbSmartTabs.Caption := Lang[ID_EOPT_SMARTTABS];

  cbHighCurrLine.Caption := Lang[ID_EOPT_HIGHCURLINE];

  cboInsertCaret.Clear;
  cboInsertCaret.Items.Add(Lang[ID_EOPT_CARET1]);
  cboInsertCaret.Items.Add(Lang[ID_EOPT_CARET2]);
  cboInsertCaret.Items.Add(Lang[ID_EOPT_CARET3]);
  cboInsertCaret.Items.Add(Lang[ID_EOPT_CARET4]);

  cboOverwriteCaret.Clear;
  cboOverwriteCaret.Items.Add(Lang[ID_EOPT_CARET1]);
  cboOverwriteCaret.Items.Add(Lang[ID_EOPT_CARET2]);
  cboOverwriteCaret.Items.Add(Lang[ID_EOPT_CARET3]);
  cboOverwriteCaret.Items.Add(Lang[ID_EOPT_CARET4]);

  // Display Tab
  grpEditorFont.Caption := Lang[ID_EOPT_EDFONT];
  lblEditorFont.Caption := Lang[ID_EOPT_FONT];
  lblEditorSize.Caption := Lang[ID_EOPT_SIZE];

  grpDisplay.Caption := Lang[ID_EOPT_DISPLAY];
  cbShowSpecialChars.Caption := Lang[ID_EOPT_SHOWSPECIAL];

  cbWordWrap.Caption := Lang[ID_EOPT_WORDWRAP];
  cbShowTopRuler.Caption := Lang[ID_EOPT_SHOWRULER];
    cbShowLineNumber.Caption := Lang[ID_EOPT_SHOWLINENUMBER];
  cbShowMinimap.Caption := Lang[ID_EOPT_SHOWMINIMAP];
  cbShowMacromap.Caption := Lang[ID_EOPT_SHOWMACROMAP];

  cbMarginVis.Caption := Lang[ID_EOPT_MARGINVISIBLE];
  lblMarginWidth.Caption := Lang[ID_EOPT_WIDTH];
  lblMarginColor.Caption := Lang[ID_EOPT_COLOR];
  //grpHighCurLine.Caption := Lang[ID_EOPT_HIGHCURLINE];
  //cbHighlightColor.Caption := Lang[ID_EOPT_COLOR];

  grpGutter.Caption := Lang[ID_EOPT_GUTTERRULER];
  cbShowTopRuler.Caption := Lang[ID_EOPT_SHOWRULER];
  cbGutterAuto.Caption := Lang[ID_EOPT_GUTTERAUTO];
  cbLeadZero.Caption := Lang[ID_EOPT_LEADZERO];
  cbFirstZero.Caption := Lang[ID_EOPT_FIRSTZERO];
  cbGutterFnt.Caption := Lang[ID_EOPT_GUTTERFNT];
  lblGutterWidth.Caption := Lang[ID_EOPT_GUTTERWIDTH];
  lblGutterFont.Caption := Lang[ID_EOPT_FONT];
  lblGutterFontSize.Caption := Lang[ID_EOPT_SIZE];



  // Colors tab
  lblForeground.Caption := Lang[ID_EOPT_FORE];
  lblBackground.Caption := Lang[ID_EOPT_BACK];
  grpStyle.Caption := Lang[ID_EOPT_STYLE];
  cbBold.Caption := Lang[ID_EOPT_BOLD];
  cbItalic.Caption := Lang[ID_EOPT_ITALIC];
  cbUnderlined.Caption := Lang[ID_EOPT_UNDERLINE];
  lblSpeed.Caption := Lang[ID_EOPT_SPEED];
  btnSaveSyntax.Hint := Lang[ID_EOPT_SAVECOLORSCHEME];

  cboColorScheme.Clear;
  //add "BuiltinSchemes" numbers of built-in syntax theme names
  cboColorScheme.Items.Add(Lang[ID_COLOR_SCHEME]);
  cboColorScheme.Items.Add(Lang[ID_COLOR_SCHEME1]);
  cboColorScheme.Items.Add(Lang[ID_COLOR_SCHEME2]);
  cboColorScheme.Items.Add(Lang[ID_COLOR_SCHEME3]);
  cboColorScheme.Items.Add(Lang[ID_COLOR_SCHEME4]);
  cboColorScheme.Items.Add(Lang[ID_COLOR_SCHEME5]);
  cboColorScheme.Items.Add(Lang[ID_COLOR_SCHEME6]);
  cboColorScheme.Items.Add(Lang[ID_COLOR_SCHEME7]);
  cboColorScheme.Items.Add(Lang[ID_COLOR_SCHEME8]);
  cboColorScheme.Items.Add(Lang[ID_COLOR_SCHEME9]);
  cboColorScheme.Items.Add(Lang[ID_COLOR_SCHEME10]);
  cboColorScheme.Items.Add(Lang[ID_COLOR_SCHEME11]);
  cboColorScheme.Items.Add(Lang[ID_COLOR_SCHEME12]);
  cboColorScheme.Items.Add(Lang[ID_COLOR_SCHEME13]);

  // Snippets tab
  btnAdd.Caption := Lang[ID_BTN_ADD];
  btnRemove.Caption := Lang[ID_BTN_REMOVE];
  lvCodeIns.Cols[0][0] := Lang[ID_EOPT_CIMENU];
  lvCodeIns.Cols[1][0] := Lang[ID_EOPT_CISECTION];
  lvCodeIns.Cols[2][0] := Lang[ID_EOPT_CIDESC];
  lblMacros.Caption := Lang[ID_EOPT_MACROS];
  cbDefaultCode.Caption := Lang[ID_EOPT_DEFCODE];

  // Completion tab, code
  chkEnableCompletion.Caption := Lang[ID_EOPT_COMPLETIONENABLE];
  lblTest.Caption := 'TT' + chkEnableCompletion.Caption;   //AutoSize
  chkEnableCompletion.Width := lblTest.Width;
  chkFunctionHints.Caption :=Lang[ID_EOPT_FUNCTIONHINTS];
  chkMemberCompletion.caption :=Lang[ID_EOPT_MEMBERCOMPLETION];
  chkIdentCompletion.caption :=Lang[ID_EOPT_IDENTCOMPLETION];

  lblCompletionDelay.Caption := Lang[ID_EOPT_COMPLETIONDELAY];
  lblCompletionColor.Caption := Lang[ID_EOPT_COMPLETIONCOLOR];
  lblCompletionColor2.Caption := Lang[ID_EOPT_COMPLETIONCOLOR2];
  lblCompletionColor3.Caption := Lang[ID_EOPT_COMPLETIONCOLOR3];
  gbCBEngine.Caption := Lang[ID_EOPT_BROWSERENGINE];
  chkCBParseLocalH.Caption := Lang[ID_EOPT_BROWSERLOCAL];
  chkCBParseGlobalH.Caption := Lang[ID_EOPT_BROWSERGLOBAL];

  // Completion tab, symbol
  cbSymbolComplete.Caption := Lang[ID_EOPT_SYMBOLCOMPLETE];
  lblTest.Caption := 'TT' + cbSymbolComplete.Caption;   //AutoSize
  cbSymbolComplete.Width := lblTest.Width;
  //grpSpecific.Caption := Lang[ID_EOPT_SYMBOLGROUP];
  cbBraces.Caption := Lang[ID_EOPT_SYMBOLBRACES];
  cbParenth.Caption := Lang[ID_EOPT_SYMBOLPARENT];
  cbInclude.Caption := Lang[ID_EOPT_SYMBOLINCLUDE];
  cbArray.Caption := Lang[ID_EOPT_SYMBOLSQUARE];
  cbComments.Caption := Lang[ID_EOPT_SYMBOLCOMMENT];
  cbSingleQuotes.Caption := Lang[ID_EOPT_SYMBOLSINGLEQUOTE];
  cbDoubleQuotes.Caption := Lang[ID_EOPT_SYMBOLDOUBLEQUOTE];
  cbDeleteCompleted.Caption := Lang[ID_EOPT_DELETESYMBOLPAIRS];

  // Autosave. Using lblTest as intermedia, adjust its Width?
  cbAutoSave.Caption := Lang[ID_EOPT_ENABLEAUTOSAVE];
  lblTest.Caption := 'TT' + cbAutoSave.Caption;   //AutoSize
  cbAutoSave.Width := lblTest.Width;

  //OptionsGroup.Caption := Lang[ID_EOPT_OPTIONS];

  lblSaveFiles.Caption := Lang[ID_EOPT_AUTOSAVEFILE];
  cmbSaveFiles.Clear;
  cmbSaveFiles.Items.Add(Lang[ID_EOPT_AUTOSAVEONLYOPENFILE]);
  cmbSaveFiles.Items.Add(Lang[ID_EOPT_AUTOSAVEALLFILES]);
  cmbSaveFiles.Items.Add(Lang[ID_EOPT_AUTOSAVEPROJECT]);
  lblSaveInterval.Caption := Lang[ID_EOPT_AUTOSAVEINTERNAL];
  lblFileName.Caption := Lang[ID_EOPT_AUTOSAVEMODE];
  cmbFileName.Clear;
  cmbFileName.Items.Add(Lang[ID_EOPT_AUTOSAVEOVERWRITE]);
  cmbFileName.Items.Add(Lang[ID_EOPT_AUTOSAVEUNIX]);
  cmbFileName.Items.Add(Lang[ID_EOPT_AUTOSAVETIME]);

  lblTimeStampExample.Caption := Lang[ID_EOPT_AUTOSAVEEXAMPLE];
  lblTimeStampExample.Font.Size := 10;

end;

procedure TEditorOptForm.btnOkClick(Sender: TObject);
var
  s: String;
  a: integer;
begin
  with devEditor do begin
    //1. general
    AutoIndent := cbAutoIndent.Checked;
    AddIndent := cbAddIndent.Checked;
    InsertMode := cbInsertMode.Checked;
    UseTabs := cbUseTabs.Checked;
    SmartTabs := cbSmartTabs.Checked;
    GroupUndo := cbGroupUndo.Checked;
    EHomeKey := cbEHomeKey.Checked;
    PastEOF := cbPastEOF.Checked;
    PastEOL := cbPastEOL.Checked;
    FindText := cbFindText.Checked;
    Scrollbars := cbSmartScroll.Checked;
    HalfPageScroll := cbHalfPage.Checked;
    ScrollHint := cbScrollHint.Checked;

    //ShowEndOfLine  := cbShowEndOfLine.Checked;
    //ShowFunctionTip := cbFunctionHint.Checked;
    TrimTrailingSpaces := cbTrimTrailingSpaces.Checked;
    UseCodeFold := cbUseCodeFold.Checked;
    ClickCodeFold := cbClickCodeFold.Checked;

    MarginVis := cbMarginVis.Checked;
    MarginSize := edMarginWidth.Value;
    MarginColor := cpMarginColor.Selected;
    InsertCaret := cboInsertCaret.ItemIndex;
    OverwriteCaret := cboOverwriteCaret.ItemIndex;
    Match := cbMatch.Checked;

    UseSyntax := cbSyntaxHighlight.Checked;
    SyntaxExt := edSyntaxExt.Text;
    TabSize := seTabSize.Value;

    //2. Display
    Font.Name := cboEditorFont.Text;
    Font.Size := edEditorSize.Value;
    //WideFontName := 'NSimSun';
    Gutterfont.Name := cboGutterFont.Text;
    GutterFont.Size := edGutterSize.Value;

        ShowSpecialChars := cbShowSpecialChars.Checked;
        cbWordWrap.checked := WordWrap;
    cbShowTopRuler.checked := ShowTopRuler;
    cbShowMinimap.checked := ShowMinimap;
    cbShowMacromap.checked := ShowMacromap;


    Gutterfnt := cbGutterFnt.Checked;
    GutterAuto := cbGutterAuto.Checked;
    GutterSize := edGutterWidth.Value;

    ShowTopRuler:= cbShowTopRuler.Checked;
    LineNumbers := cbShowLineNumber.Checked;
    LeadZero := cbLeadZero.Checked;
    FirstLineZero := cbFirstZero.Checked;
    InsDropFiles := cbDropFiles.Checked;

    ParserHints := cbParserHints.Checked;

    //5.2 Completion: Symbol
    CompleteSymbols := cbSymbolComplete.Checked;
    ArrayComplete := cbArray.Checked;
    BraceComplete := cbBraces.Checked;
    CommentComplete := cbComments.Checked;
    IncludeComplete := cbInclude.Checked;
    ParentheseComplete := cbParenth.Checked;
    SingleQuoteComplete := cbSingleQuotes.Checked;
    DoubleQuoteComplete := cbDoubleQuotes.Checked;
    DeleteSymbolPairs := cbDeleteCompleted.Checked;

    //6. Autosave
    EnableAutoSave := cbAutoSave.Checked;
    Interval := seSaveInteval.value;
    AutoSaveFilter := cmbSaveFiles.ItemIndex;
    AutoSaveMode := cmbFileName.ItemIndex;

    //3. Colors (Syntax Highlighter)
    SchemeIndex := cboColorScheme.ItemIndex;
    ElemIndex := ElementList.ItemIndex;
    // Color Scheme element colors are already in devEditor.ColorScheme from cboQuickColorSelect,
    // keep them (don't clear like the old SynEdit code did)
    // Special element colors below are saved from local f*Color fields

    // seved in [Editor.ColorScheme] section

    //TODO: 下面这一段写得太复杂了，可以改为用一个循环即可实现。
    // breakpoints
    s := PointtoStr(fBPColor);
    a := ColorScheme.IndexOfName(cBP);
    if a = -1 then
      ColorScheme.Append(format('%s=%s', [cBP, s]))
    else
      ColorScheme.Values[cBP] := s;

    // error line
    s := PointtoStr(fErrColor);
    a := ColorScheme.IndexOfName(cErr);
    if a = -1 then
      ColorScheme.Append(format('%s=%s', [cErr, s]))
    else
      ColorScheme.Values[cErr] := s;

    // active breakpoint
    s := PointtoStr(fAbpColor);
    a := ColorScheme.IndexOfName(cABP);
    if a = -1 then
      ColorScheme.Append(format('%s=%s', [cABP, s]))
    else
      ColorScheme.Values[cABP] := s;

    // bookmark background
    s := PointtoStr(fBMColor);
    a := ColorScheme.IndexOfName(cBM);
    if a = -1 then
      ColorScheme.Append(format('%s=%s', [cBM, s]))
    else
      ColorScheme.Values[cBM] := s;

    // selected text
    s := PointtoStr(fSelColor);
    a := ColorScheme.IndexOfName(cSel);
    if a = -1 then
      ColorScheme.Append(format('%s=%s', [cSel, s]))
    else
      ColorScheme.Values[cSel] := s;

    // Current Line text
    s := PointtoStr(fCurColor);
    a := ColorScheme.IndexOfName(cCur);
    if a = -1 then
      ColorScheme.Append(format('%s=%s', [cCur, s]))
    else
      ColorScheme.Values[cCur] := s;
    HighCurrLine := cbHighCurrLine.Checked;
    HighColor := fCurColor.x;

    // gutter
    s := PointtoStr(fGutColor);
    a := ColorScheme.IndexOfName(cGut);
    if a = -1 then
      ColorScheme.Append(format('%s=%s', [cGut, s]))
    else
      ColorScheme.Values[cGut] := s;

    // Edit State
    s := PointtoStr(fEditColor);
    a := ColorScheme.IndexOfName(cEdt);
    if a = -1 then
      ColorScheme.Append(format('%s=%s', [cEdt, s]))
    else
      ColorScheme.Values[cEdt] := s;

    // fold bar
    s := PointtoStr(fFoldColor);
    a := ColorScheme.IndexOfName(cFld);
    if a = -1 then
      ColorScheme.Append(format('%s=%s', [cFld, s]))
    else
      ColorScheme.Values[cFld] := s;

    // fold bar 2
    s := PointtoStr(fFoldColor2);
    a := ColorScheme.IndexOfName(cFld2);
    if a = -1 then
      ColorScheme.Append(format('%s=%s', [cFld2, s]))
    else
      ColorScheme.Values[cFld2] := s;

  end;

  //4. Snippets
  //4.1 Save our code snippet even if we opted not to use it (user may want to keep it)
  //if DefaultEdit.GetTextLen > 0 then //if not DefaultEdit.IsEmpty then //abli
  if DefaultEdit.Strings.Count > 0 then
    DefaultEdit.Strings.SavetoFile(devDirs.Config + DEV_DEFAULTCODE_FILE)
  else
    DeleteFile(devDirs.Config + DEV_DEFAULTCODE_FILE);
  SaveCodeIns;
  //4.2 Default source
  devEditor.DefaultCode := cbDefaultCode.Checked;

  //5.1 Code Completion
  with devCodeCompletion do begin
    Enabled := chkEnableCompletion.Checked;
    ShowFunctionHints := chkFunctionHints.Checked;
    ShowMemberCompletion := chkMemberCompletion.Checked;
    ShowIdentCompletion := chkIdentCompletion.Checked;
    Delay := seCompletionDelay.value;
    BackColor := cpCompletionBackground.Selected;
    TextColor := cpCompletionTextColor.Selected;
    HighColor := cpCompletionHighColor.Selected;
    ParseLocalHeaders := chkCBParseLocalH.Checked;
    ParseGlobalHeaders := chkCBParseGlobalH.Checked;
  end;

  // Only create the timer if autosaving is enabled
  if devEditor.EnableAutoSave then begin
    if not Assigned(MainForm.AutoSaveTimer) then
      MainForm.AutoSaveTimer := TTimer.Create(nil);
    MainForm.AutoSaveTimer.Interval := devEditor.Interval * 60 * 1000; // miliseconds to minutes
    MainForm.AutoSaveTimer.Enabled := devEditor.EnableAutoSave;
    MainForm.AutoSaveTimer.OnTimer := @MainForm.EditorSaveTimer;
  end else begin
    MainForm.AutoSaveTimer.Free;
    MainForm.AutoSaveTimer := nil;
  end;

  SaveOptions;
  dmMain.LoadDataMod;

  // Apply selected Color scheme to all open editors
  ApplyColorSchemeToAllEditors;

  // Refresh the main menu's color-scheme check marks. When SchemeIndex falls
  // outside the built-in range (a user-defined scheme is selected), the last
  // ("Custom") item must be the checked one.
  if Assigned(MainForm) then
    MainForm.UpdateColorSchemeChecks;

  // The dialog may have changed ShowTopRuler / LineNumbers: re-apply them to all
  // open editors and sync the "Show top ruler" / "Show line numbers" menu marks.
  if Assigned(MainForm) then
    MainForm.UpdateShowRulerLineNumber;
end;

procedure TEditorOptForm.btnHelpClick(Sender: TObject);
begin
  OpenHelpFile('index.html');
end;

procedure TEditorOptForm.btnCancelClick(Sender: TObject);
begin
  Close;
end;

{ ---------- Color SCheme Style Methods ---------- }
procedure TEditorOptForm.SetGutter(ed: TATSynEdit);
begin
  ed.Colors.RulerBG := fGutColor.x;
  ed.Colors.RulerFont := fGutColor.y;
  ed.Colors.GutterBG := fGutColor.x;
  ed.Colors.GutterFont := fGutColor.y;
  //ed.Colors.GutterFontActive := fgutColor.y; // 当前行的 gutter 字体颜色（如果有）
  ed.Colors.StateSaved := fEditColor.x;
  ed.Colors.StateChanged := fEditColor.y;
  ed.Colors.StateAdded := fEditColor.y;
  ed.Colors.GutterFoldBG := fFoldColor.x;
  ed.Colors.GutterFoldLine := fFoldColor.y;
  ed.Colors.GutterFoldLine2 := fFoldColor2.y;
end;

procedure TEditorOptForm.ApplyCurLineColors;
begin
  // Special colors are already loaded in f*Color fields (from ColorScheme.Values)
  // (fBPColor, fErrColor, fABPColor, BGcolor of fSelColor)

  // Show Selected-Text and Current-line highlight using built-in ATSynEdit support
  if fSelColor.X <> clNone then begin
    CodeEdit.Colors.TextSelBG := fSelColor.X;   //BGcolor
    CodeEdit.Colors.TextSelFont := fSelColor.Y; //FGColor
    SnippetEdit.Colors.TextSelBG := fSelColor.X;
    SnippetEdit.Colors.TextSelFont := fSelColor.Y;
    DefaultEdit.Colors.TextSelBG := fSelColor.X;
    DefaultEdit.Colors.TextSelFont := fSelColor.Y;
  end;

  if fCurColor.X <> clNone then begin
    CodeEdit.Colors.CurrentLineBG := fCurColor.X;
    CodeEdit.OptShowCurLine := True;
    SnippetEdit.Colors.CurrentLineBG := fCurColor.X;
    SnippetEdit.OptShowCurLine := True;
    DefaultEdit.Colors.CurrentLineBG := fCurColor.X;
    DefaultEdit.OptShowCurLine := True;
  end;
  // Invalidate to refresh special line backgrounds from bookmark system
  CodeEdit.Invalidate;
  SnippetEdit.Invalidate;
  DefaultEdit.Invalidate;
end;

procedure TEditorOptForm.SetupPreviewBookmarks(Ed: TATSynEdit);
var
  bm: TATBookmarkData;
begin
  // Clear existing bookmarks and add our own for special lines.
  // ATSynEdit renders line BG from bookmarks BEFORE text rendering.
  Ed.Strings.Bookmarks.Clear;
  bm := Default(TATBookmarkData);  //initialize
  FillChar(bm, SizeOf(bm), 0);

  bm.LineNum := cSelection;
  bm.Kind := BK_SELECTION;
  Ed.Strings.Bookmarks.Add(bm, False);

  bm.LineNum := cBreakLine;
  bm.Kind := BK_BREAKPOINT;
  Ed.Strings.Bookmarks.Add(bm, False);

  bm.LineNum := cABreakLine;
  bm.Kind := BK_ACTIVEBREAKPOINT;
  Ed.Strings.Bookmarks.Add(bm, False);

  bm.LineNum := cErrorLine;
  bm.Kind := BK_ERROR;
  Ed.Strings.Bookmarks.Add(bm, False);

  bm.LineNum := cBookmarkLine;
  bm.Kind := BK_BOOKMARK;
  Ed.Strings.Bookmarks.Add(bm, False);

  // Connect OnCalcBookmarkColor to return per-kind colors
  Ed.OnCalcBookmarkColor := @EditorCalcBookmarkColor;
end;

// ATSynEdit 2.27.0.0: TEditor.GutterBandDecor property was removed.
// Decor icons are now painted in the bookmarks gutter band by default
// (internal fallback: FGutterBandDecor<0 -> bookmarks band); on the same
// line the bookmark icon is shifted right automatically.
procedure TEditorOptForm.SetupPreviewGutterDecor(Ed: TATSynEdit);
var
  decor: TATGutterDecorData;
begin
  // Set up GutterDecor for breakpoint icons (same image list as main editor)
  Ed.ImagesGutterDecor := dmMain.GutterImages;
  Ed.Strings.GutterDecor1 := Ed.GutterDecor;

  // Add decor items for breakpoint/active/error lines
  decor := Default(TATGutterDecorData);
  decor.DeleteOnDelLine := True;
  decor.LineNum := cBreakLine; // 0-based
  decor.ImageIndex := 0;
  Ed.GutterDecor.Add(decor);

  decor := Default(TATGutterDecorData);
  decor.DeleteOnDelLine := True;
  decor.LineNum := cABreakLine; // 0-based
  decor.ImageIndex := 1;
  Ed.GutterDecor.Add(decor);

  decor := Default(TATGutterDecorData);
  decor.DeleteOnDelLine := True;
  decor.LineNum := cErrorLine; // 0-based
  decor.ImageIndex := 2;
  Ed.GutterDecor.Add(decor);
end;


procedure TEditorOptForm.EditorCalcBookmarkColor(Sender: TObject; ABookmarkKind: integer; var AColor: TColor);
begin
  case ABookmarkKind of
    BK_SELECTION:        AColor := fSelColor.X;
    BK_BREAKPOINT:       AColor := fBPColor.X;
    BK_ACTIVEBREAKPOINT: AColor := fABPColor.X;
    BK_ERROR:            AColor := fErrColor.X;
    BK_BOOKMARK:         AColor := fBMColor.X;
  end;
end;

procedure TEditorOptForm.ApplyColorSchemeToEditors;
var
  Adapter: TATAdapterEControl;
  Lexer: TecSyntAnalyzer;
  pt: TPoint;
begin
  pt := Point(0, 0);  //initialize
  if not (Assigned(CodeEdit.AdapterForHilite) and (CodeEdit.AdapterForHilite is TATAdapterEControl)) then
    Exit;
  Adapter := TATAdapterEControl(CodeEdit.AdapterForHilite);
  Lexer := Adapter.Lexer;
  if not Assigned(Lexer) then
    Exit;

  // 应用颜色元素到 CodeEdit 的 lexer；SpaceBG=clNone 表示不做背景回退
  ApplyColorElemsToLexer(Lexer, clNone);

  // Set overall editor background from Space element's background color
  StrtoPoint(pt, devEditor.ColorScheme.Values['Space']);
  if pt.X <> clNone then
    CodeEdit.Colors.TextBG := pt.X;
  // Force full re-parse by triggering TextChangedOnLine for all content
  Adapter.ParseFromLine(0, True);

  SetGutter(CodeEdit);
  CodeEdit.Invalidate;

  // Apply same background to SnippetEdit and DefaultEdit, re-parse
  with devEditor do
    if ColorScheme.IndexOfName('Space') >= 0 then begin
      StrtoPoint(pt, ColorScheme.Values['Space']);
      if pt.X <> clNone then begin
        SnippetEdit.Colors.TextBG := pt.X;
        DefaultEdit.Colors.TextBG := pt.X;
      end;
    end;

  if Assigned(SnippetEdit.AdapterForHilite) and (SnippetEdit.AdapterForHilite is TATAdapterEControl) then
    TATAdapterEControl(SnippetEdit.AdapterForHilite).ParseFromLine(0, True);
  if Assigned(DefaultEdit.AdapterForHilite) and (DefaultEdit.AdapterForHilite is TATAdapterEControl) then
    TATAdapterEControl(DefaultEdit.AdapterForHilite).ParseFromLine(0, True);

  SetGutter(SnippetEdit);
  SetGutter(DefaultEdit);

  SnippetEdit.Invalidate;
  DefaultEdit.Invalidate;
end;

procedure TEditorOptForm.ElementListClick(Sender: TObject);
var
  pt: TPoint;
  s: string;
begin
  // Special additions not directly exposed by TSynHighlighter
  if ElementList.ItemIndex > pred(ElementList.Items.Count) - ColorSpecial then begin
    // Select proper color for special items. Disable background for fold colors?
    // TODO: support specific colors for folds
    //if SameText(ElementList.Items[ElementList.ItemIndex], cSel) then begin
    if SameText(fColorElems[ElementList.ItemIndex], cBP) then begin
      pt := fBPColor;
      cpBackground.Enabled := True;
    end else if SameText(fColorElems[ElementList.ItemIndex], cErr) then begin
      pt := fErrColor;
      cpBackground.Enabled := True;
    end else if SameText(fColorElems[ElementList.ItemIndex], cABP) then begin
      pt := fABPColor;
      cpBackground.Enabled := True;
    end else if SameText(fColorElems[ElementList.ItemIndex], cBM) then begin
      pt := fBMColor;
      cpBackground.Enabled := True;
    end else if SameText(fColorElems[ElementList.ItemIndex], cSel) then begin
      pt := fSelColor;
      cpBackground.Enabled := True;
    end else if SameText(fColorElems[ElementList.ItemIndex], cCur) then begin
      pt := fCurColor;
      cpBackground.Enabled := True;
    end else if SameText(fColorElems[ElementList.ItemIndex], cGut) then begin
      pt := fGutColor;
      cpBackground.Enabled := True;
    end else if SameText(fColorElems[ElementList.ItemIndex], cEdt) then begin
      pt := fGutColor;
      cpBackground.Enabled := True;
    end else if SameText(fColorElems[ElementList.ItemIndex], cFld) then begin
      pt := fFoldColor;
      cpBackground.Enabled := True;
   end else if SameText(fColorElems[ElementList.ItemIndex], cFld2) then begin
      pt := fFoldColor2;
      cpBackground.Enabled := False;
    end;

    cpBackground.Selected := pt.x;
    cpForeground.Selected := pt.y;

    cbBold.Checked := False;
    cbItalic.Checked := False;
    cbUnderlined.Checked := False;

    // regular SynEdit attributes
  end else if ElementList.ItemIndex <> -1 then begin
    // Read Color Scheme element colors from devEditor.ColorScheme (stored as "fore, back, bold, italic, underline")
    s := devEditor.ColorScheme.Values[fColorElems[ElementList.ItemIndex]];
    if s = '' then begin
      // Default values if not yet saved
      cpForeground.Selected := ffgColor;
      cpBackground.Selected := fbgColor;
      cbBold.Checked := False;
      cbItalic.Checked := False;
      cbUnderlined.Checked := False;
    end else begin
      with TStringList.Create do try
        CommaText := s;
        if Count >= 2 then begin
          cpForeground.Selected := StringToColor(Trim(Strings[0]));
          cpBackground.Selected := StringToColor(Trim(Strings[1]));
        end else begin
          cpForeground.Selected := ffgColor;
          cpBackground.Selected := fbgColor;
        end;
        if Count >= 5 then begin
          cbBold.Checked := Trim(Strings[2]) = '1';
          cbItalic.Checked := Trim(Strings[3]) = '1';
          cbUnderlined.Checked := Trim(Strings[4]) = '1';
        end else begin
          cbBold.Checked := False;
          cbItalic.Checked := False;
          cbUnderlined.Checked := False;
        end;
      finally
        Free;
      end;
    end;
    // Fallback from clNone to default colors
    if cpForeground.Selected = clNone then
      cpForeground.Selected := ffgColor;
    if cpBackground.Selected = clNone then
      cpBackground.Selected := fbgColor;

    cpBackground.Enabled := True;

  end;
end;

procedure TEditorOptForm.StyleChange(Sender: TObject);
var
  pt: TPoint;
  s: String;
begin
    // Don't process changes triggered by ElementListClick setting values programmatically
  if ElementList.Focused then
    Exit;

  if (ElementList.ItemIndex < 0) or (ElementList.ItemIndex >= ElementList.Items.Count) then
    Exit;

  // Special additions not directly exposed by TSynHighlighter
  // TODO: EControl adapter - was pred(cpp.AttrCount)
  if ElementList.ItemIndex > pred(ElementList.Items.Count) - ColorSpecial then begin
  //if ElementList.ItemIndex > pred(cpp.AttrCount) then begin
    pt.x := cpBackground.Selected;
    pt.y := cpForeground.Selected;

    // use local String just to ease readability
    //s := ElementList.Items[ElementList.ItemIndex];
    s := fColorElems[ElementList.ItemIndex];

    // if either value is clnone set to Whitespace color values
    if pt.x = clNone then
      pt.x := fbgColor;
    if pt.y = clNone then
      pt.y := ffgColor;

    if SameText(s, cBP) then
      fBPColor := pt
    else if SameText(s, cABP) then
      fABPColor := pt
    else if SameText(s, cerr) then
      fErrColor := pt
    else if SameText(s, cBM) then
      fBMColor := pt
    else if SameText(s, cSel) then begin
      fSelColor := pt;
      CodeEdit.Colors.TextSelBG := pt.X;
      CodeEdit.Colors.TextSelFont := pt.Y;
    end
    else if SameText(s, cCur) then begin
      fCurColor := pt;
      // Update preview editors immediately
      if pt.X <> clNone then begin
        CodeEdit.Colors.CurrentLineBG := pt.X;
        CodeEdit.OptShowCurLine := True;
        SnippetEdit.Colors.CurrentLineBG := pt.X;
        SnippetEdit.OptShowCurLine := True;
        DefaultEdit.Colors.CurrentLineBG := pt.X;
        DefaultEdit.OptShowCurLine := True;
      end else begin
        CodeEdit.OptShowCurLine := False;
        SnippetEdit.OptShowCurLine := False;
        DefaultEdit.OptShowCurLine := False;
      end;
    end else if SameText(s, cGut) then begin
      fGutColor := pt;
      SetGutter(CodeEdit);
      SetGutter(SnippetEdit);
      SetGutter(DefaultEdit);
    end else if SameText(s, cEdt) then begin
      fEditColor := pt;
      SetGutter(CodeEdit);
      SetGutter(SnippetEdit);
      SetGutter(DefaultEdit);
    end else if SameText(s, cFld) then begin
      fFoldColor := pt;
      //fFoldColort
      SetGutter(CodeEdit);
      SetGutter(SnippetEdit);
      SetGutter(DefaultEdit);
    end else if SameText(s, cFld2) then begin
      fFoldColor2 := pt;
      SetGutter(CodeEdit);
      SetGutter(SnippetEdit);
      SetGutter(DefaultEdit);

    end;
  // regular SynEdit attributes
  end else begin
    // Save element colors and style to devEditor.ColorScheme
    s := Format('%s, %s, %d, %d, %d', [
      ColorToString(cpForeground.Selected),
      ColorToString(cpBackground.Selected),
      Ord(cbBold.Checked),
      Ord(cbItalic.Checked),
      Ord(cbUnderlined.Checked)]);

    devEditor.ColorScheme.Values[fColorElems[ElementList.ItemIndex]] := s;

    // Update Space background defaults for fallback
    if SameText(fColorElems[ElementList.ItemIndex], 'Space') then begin
      ffgColor := cpForeground.Selected;
      fbgColor := cpBackground.Selected;
      CodeEdit.Colors.TextBG := cpBackground.Selected;
      SnippetEdit.Colors.TextBG := cpBackground.Selected;
      DefaultEdit.Colors.TextBG := cpBackground.Selected;
    end;

    // Apply changes to preview editor immediately
    ApplyColorSchemeToEditors;
  end;

  //CodeEdit.Repaint;
  CodeEdit.Invalidate;
  CodeEdit.Update(True);
end;

procedure TEditorOptForm.EditorStatusChange(Sender: TObject);
var
  //Token: String;
  idx: integer;
begin
  //todo: here need to change to translated text //abli
  case Integer(CodeEdit.Carets[0].PosY) of
      cBreakLine: begin
          //ElementList.ItemIndex := ElementList.Items.Indexof(cBP);
          for idx := 0 to 25 do
            if sametext(fColorElems[idx], cBP) then  break;
          ElementList.ItemIndex := idx;
          ElementListClick(Self);
        end;
      cABreakLine: begin
          for idx := 0 to 25 do
            if sametext(fColorElems[idx], cABP) then  break;
          //ElementList.ItemIndex := ElementList.Items.Indexof(cABP);
          ElementList.ItemIndex := idx;
          ElementListClick(Self);
        end;
      cErrorLine: begin
          for idx := 0 to 25 do
            if sametext(fColorElems[idx], cErr) then  break;
          //ElementList.ItemIndex := ElementList.Items.Indexof(cErr);
          ElementList.ItemIndex := idx;
          ElementListClick(Self);
        end;
      cSelection: begin
          //ElementList.ItemIndex := ElementList.Items.Indexof(cSel);
          for idx := 0 to 25 do
            if sametext(fColorElems[idx], cSel) then  break;
          ElementList.ItemIndex := idx;
          ElementListClick(Self);
        end;
      cCurrentLine: begin
          //ElementList.ItemIndex := ElementList.Items.Indexof(cCur);
          for idx := 0 to 25 do
            if sametext(fColorElems[idx], cCur) then  break;
          ElementList.ItemIndex := idx;
          ElementListClick(Self);
        end;

    else begin
        // TODO: EControl adapter - color from Syntax values handled in StyleChange/ElementListClick
        // Element selection already handled by cpBPosition tracking above
      end;
    end;
end;


procedure TEditorOptForm.EditorOptDrawLine(Sender: TObject; C: TCanvas;
  ALineIndex: integer; AX, AY: integer; const AStr: atString;
  const ACharSize: TATEditorCharSize; constref AExtent: TATIntFixedArray);
var
  w, i: integer;
  BG: TColor;
begin
  // Calculate display width from character extents
  w := 0;
  for i := 0 to AExtent.Len - 1 do
    Inc(w, AExtent.Data[i]);
  if w <= 0 then
    w := Length(AStr) * (ACharSize.XScaled div 100);

  BG := clNone;

  case ALineIndex of
    cSelection: begin
      BG := fSelColor.X;
    end;
    cCurrentLine: begin
      BG := fCurColor.X;
    end;
    cBreakLine: begin
      BG := fBPColor.X;
    end;
    cABreakLine: begin
      BG := fABPColor.X;
    end;
    cErrorLine: begin
      BG := fErrColor.X;
    end;
  end;

  if BG <> clNone then begin
    C.Brush.Color := BG;
    C.Pen.Style := psClear;
    C.FillRect(Rect(AX, AY, AX + w, AY + ACharSize.Y));
  end;
end;

procedure TEditorOptForm.CppEditSpecialLineColors(Sender: TObject;
  Line: Integer; var Special: Boolean; var FG, BG: TColor);
begin
  // Stub: superseded by EditorOptDrawLine (ATSynEdit OnDrawLine)
  Special := False;
end;

procedure TEditorOptForm.cbShowLineNumberClick(Sender: TObject);
begin
  cbLeadZero.Enabled := cbShowLineNumber.Checked;
  cbFirstZero.Enabled := cbShowLineNumber.Checked;
end;

procedure TEditorOptForm.cbSyntaxHighlightClick(Sender: TObject);
begin
  edSyntaxExt.Enabled := cbSyntaxHighlight.Checked;
end;

procedure TEditorOptForm.cbUseCodeFoldClick(Sender: TObject);
begin
  cbClickCodeFold.Enabled := cbUseCodeFold.Checked;
end;


procedure TEditorOptForm.cboColorSchemeSelect(Sender: TObject);
var
  idx: integer;
  i, offset: integer;
  s: string; //debug
begin
  idx := cboColorScheme.ItemIndex;
  if idx < BuiltinSchemes then begin
    //todo: 这里直接修改了全局的 devEditor 的 ColorScheme，但是也许用户不想修改，点击“取消”按钮。
    //所以这里可能需要设置一个只在此对话框内有效的局部变量。
    devEditor.SetColorScheme(idx);

    StrtoPoint(fBPColor,  devEditor.ColorScheme.ValueFromIndex[ColorSyntax + 0]); // breakpoints
    StrtoPoint(fErrColor, devEditor.ColorScheme.ValueFromIndex[ColorSyntax + 1]); // error line
    StrtoPoint(fABPColor, devEditor.ColorScheme.ValueFromIndex[ColorSyntax + 2]); // active breakpoint
    StrtoPoint(fBMColor,  devEditor.ColorScheme.ValueFromIndex[ColorSyntax + 3]); // BookMark line
    StrtoPoint(fSelColor, devEditor.ColorScheme.ValueFromIndex[ColorSyntax + 4]); // selected text
    StrtoPoint(fCurColor, devEditor.ColorScheme.ValueFromIndex[ColorSyntax + 5]); // Current line
    StrtoPoint(fGutColor, devEditor.ColorScheme.ValueFromIndex[ColorSyntax + 6]); // gutter
    StrtoPoint(fEditColor, devEditor.ColorScheme.ValueFromIndex[ColorSyntax + 7]); // Edit State
    StrtoPoint(fFoldColor, devEditor.ColorScheme.ValueFromIndex[ColorSyntax + 8]); // folding bar lines
    StrtoPoint(fFoldColor2,devEditor.ColorScheme.ValueFromIndex[ColorSyntax + 9]); // folding bar lines 2
  end else begin
    LoadColorScheme(cboColorScheme.Items[cboColorScheme.ItemIndex]);
  end;
  ApplyColorSchemeToEditors;
  ApplyCurLineColors;

  CodeEdit.Repaint;
  ElementListClick(nil);
end;

{ ---------- Code insert methods ---------- }

procedure TEditorOptForm.btnAddClick(Sender: TObject);
begin
  SnippetEdit.Strings.Clear; // ATSynEdit

  lvCodeIns.RowCount := lvCodeIns.RowCount + 1; // add blank row, assume fixedrows remains at 1

  // Fill
  lvCodeIns.Objects[0, lvCodeIns.RowCount - 1] := TStringList.Create;
  lvCodeIns.Cells[0, lvCodeIns.RowCount - 1] := '';
  lvCodeIns.Cells[1, lvCodeIns.RowCount - 1] := '';
  lvCodeIns.Cells[2, lvCodeIns.RowCount - 1] := '';

  lvCodeIns.Row := lvCodeIns.RowCount - 1; // set selection
  lvCodeIns.Col := 0; // set selection
  lvCodeIns.SetFocus;

  UpdateCIButtons;
end;

procedure TEditorOptForm.btnRemoveClick(Sender: TObject);
var
  I: integer;
  sl: TStringList;
begin
  if (lvCodeIns.Row >= lvCodeIns.FixedRows) then begin
    if (lvCodeIns.RowCount > 2) then begin // remove completely
      dmMain.CodeInserts.Delete(lvCodeIns.Row);

      // Delete object containing text too
      TStringList(lvCodeIns.Objects[0, lvCodeIns.Row]).Free;
      lvCodeIns.Objects[0, lvCodeIns.Row] := nil;

      for I := lvCodeIns.Row to lvCodeins.RowCount - 2 do
        lvCodeIns.Rows[i].Assign(lvCodeIns.Rows[i + 1]); // moves objects too

      lvCodeIns.RowCount := lvCodeIns.RowCount - 1;
    end else begin // leave blank row
      sl := TStringList(lvCodeIns.Objects[0, lvCodeIns.Row]); // leave blank data
      sl.Clear;
      lvCodeIns.Rows[lvCodeIns.RowCount - 1].Text := ''; // removes data pointer
      lvCodeIns.Objects[0, lvCodeIns.Row] := sl;
    end;

    lvCodeIns.Repaint;
    SnippetEdit.Strings.Clear;
    UpdateCIButtons;
  end;
end;

procedure TEditorOptForm.UpdateCIButtons;
begin
  btnAdd.Enabled := true;
  btnRemove.Enabled := lvCodeIns.Row > 0;
end;


procedure TEditorOptForm.lvCodeInsSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  SnippetEdit.Strings.Clear;
  if (lvCodeIns.Row >= lvCodeIns.FixedRows) and (lvCodeIns.Objects[0, ARow] <> nil) then begin
    // store code in first column object
    SnippetEdit.Text := UnicodeString(StrToCodeIns(TStringList(lvCodeIns.Objects[0, ARow]).Text));

    // Reset caret to first line and invalidate to force complete refresh
    //if SnippetEdit.Carets.Count > 0 then begin
    //  SnippetEdit.Carets[0].PosX := 0;
    //  SnippetEdit.Carets[0].PosY := 0;
    //end;
    SnippetEdit.Invalidate;
    SnippetEdit.Update(True);

    UpdateCIButtons;
  end;
end;

procedure TEditorOptForm.CodeInsStatusChange(Sender: TObject);
begin
  if (lvCodeIns.Row >= lvCodeIns.FixedRows) then begin
    // store text in hidden field
    TStringList(lvCodeIns.Objects[0, lvCodeIns.Row]).Text := String(CodeInstoStr(AnsiString(SnippetEdit.Text)));
    SnippetEdit.Modified := false;
  end;
end;

procedure TEditorOptForm.LoadCodeIns;
var
  ins: PCodeIns;
  I: integer;
  sl: TStringList;
  canselect: boolean;
begin
  lvCodeIns.FixedRows := 0;
  lvCodeIns.RowCount := 1; // re-add fixed row later on

  for I := 0 to dmMain.CodeInserts.Count - 1 do begin
    lvCodeIns.RowCount := lvCodeIns.RowCount + 1; // add new blank row

    // Don't forget to delete!
    sl := TStringList.Create;

    // Fill cols
    ins := dmMain.CodeInserts[I];
    sl.Text := ins^.Line;
    lvCodeIns.Objects[0, lvCodeIns.RowCount - 1] := sl;
    lvCodeIns.Cells[0, lvCodeIns.RowCount - 1] := ins^.Caption;
    lvCodeIns.Cells[1, lvCodeIns.RowCount - 1] := IntToStr(ins^.Sep);
    lvCodeIns.Cells[2, lvCodeIns.RowCount - 1] := ins^.Desc;
  end;

  // Add empty, but configured row
  if lvCodeIns.RowCount = 1 then begin
    lvCodeIns.RowCount := lvCodeIns.RowCount + 1;

    // Fill
    lvCodeIns.Objects[0, lvCodeIns.RowCount - 1] := TStringList.Create;
    lvCodeIns.Cells[0, lvCodeIns.RowCount - 1] := '';
    lvCodeIns.Cells[1, lvCodeIns.RowCount - 1] := '';
    lvCodeIns.Cells[2, lvCodeIns.RowCount - 1] := '';
  end;

  lvCodeIns.FixedRows := 1; // gets reset to 0 when removing all editable rows
  canselect := True;
  lvCodeInsSelectCell(nil, 0, 1, canselect);
end;

procedure TEditorOptForm.SaveCodeIns;
var
  I: integer;
  Item: PCodeIns;
begin
  dmMain.CodeInserts.Clear;
  for I := lvCodeIns.FixedRows to lvCodeIns.RowCount - 1 do begin
    if lvCodeIns.Cells[0, I] <> '' then begin
      Item := new(PCodeIns);

      // Get snippet from attached object
      Item^.Caption := lvCodeIns.Cells[0, I];
      Item^.Sep := StrToIntDef(lvCodeIns.Cells[1, I], 0);
      Item^.Desc := lvCodeIns.Cells[2, I];
      Item^.Line := TStringList(lvCodeIns.Objects[0, I]).Text;

      dmMain.CodeInserts.AddItem(Item);
    end;
  end;
  dmMain.CodeInserts.SaveCode;
end;

procedure TEditorOptForm.ClearCodeIns;
var
  I: integer;
begin
  // Clear the code insertion string grid objects
  for I := 1 to lvCodeIns.RowCount - 1 do begin
    if Assigned(lvCodeIns.Objects[0, I]) then begin
      TStringList(lvCodeIns.Objects[0, I]).Free;
      lvCodeIns.Objects[0, I] := nil;
    end;
  end;
end;

procedure TEditorOptForm.cmbFileNameChange(Sender: TObject);
begin
  case cmbFileName.ItemIndex of  //Format(Lang[ID_EOPT_AUTOSAVEEXAMPLE], ['example.cpp']
    0: begin
        lblTimeStampExample.Caption := 'example.cpp';
      end;
    1: begin
        lblTimeStampExample.Caption := 'example.' + IntToStr(DateTimeToUnix(Now)) + '.cpp';
      end;
    2: begin
        lblTimeStampExample.Caption := 'example.' + FormatDateTime('yyyy mm dd hh mm ss', Now) + '.cpp';
      end;
  end;
end;

{ ---------- Code completion ---------- }

procedure TEditorOptForm.chkEnableCompletionClick(Sender: TObject);
begin
  with chkEnableCompletion do begin
    chkFunctionHints.Enabled := Checked;
    chkMemberCompletion.Enabled := Checked;
    chkIdentCompletion.Enabled := Checked;
    seCompletionDelay.Enabled := Checked;
    cpCompletionBackground.Enabled := Checked;
    cpCompletionTextColor.Enabled := Checked;
    cpCompletionHighColor.Enabled := Checked;
    chkCBParseGlobalH.Enabled := Checked;
    chkCBParseLocalH.Enabled := Checked;
  end;
end;

procedure TEditorOptForm.btnSaveSyntaxClick(Sender: TObject);
var
  idx: integer;
  fINI: TIniFile;
  S: String;
  pt: TPoint;
begin
  s := 'New_scheme';
  if not InputQuery(Lang[ID_EOPT_SAVECOLORSCHEME], Lang[ID_EOPT_SAVESCHEMEQUESTION], s) or (s = '') then
    Exit;

  fINI := TIniFile.Create(devDirs.Config + s + COLORSCHEME_EXT);
  try
    // Save regular Color Scheme elements for lexer(Space, Comment, Preprocessor, etc.)
    for idx := 0 to ColorSyntax - 1 do begin
      if fColorElems[idx] = '' then Continue;
      fINI.WriteString('Editor.Custom', fColorElems[idx],
        devEditor.ColorScheme.Values[fColorElems[idx]]);
    end;

    // Save special items (breakpoints, selection, cursor, gutter, etc.)
    for idx := ColorSyntax to pred(ElementList.Items.Count) do begin
      //if CompareText(ElementList.Items[idx], cSel) = 0 then
      if CompareText(fColorElems[idx], cBP) = 0 then
        pt := fBPColor
      else if CompareText(fColorElems[idx], cErr) = 0 then
        pt := fErrColor
      else if CompareText(fColorElems[idx], cABP) = 0 then
        pt := fABPColor
      else if CompareText(fColorElems[idx], cBM) = 0 then
        pt := fBMColor
      else if CompareText(fColorElems[idx], cSel) = 0 then
        pt := fSelColor
      else if CompareText(fColorElems[idx], cCur) = 0 then
        pt := fCurColor
      else if CompareText(fColorElems[idx], cGut) = 0 then
        pt := fGutColor
      else if CompareText(fColorElems[idx], cEdt) = 0 then
        pt := fEditColor
      else if CompareText(fColorElems[idx], cFld) = 0 then
        pt := fFoldColor
      else if CompareText(fColorElems[idx], cFld2) = 0 then
        pt := fFoldColor2;

      fINI.WriteString('Editor.Custom', fColorElems[idx], PointtoStr(pt));
    end;
  finally
    fINI.Free;
  end;
  if cboColorScheme.Items.IndexOf(S) = -1 then
    cboColorScheme.Items.Add(S);
  cboColorScheme.ItemIndex := cboColorScheme.Items.IndexOf(S);

  // The newly saved scheme is now the selected one. Its index lies beyond the
  // BuiltinSchemes built-in schemes, so sync SchemeIndex and refresh the main
  // menu check marks: the last ("Custom") item must become the checked one.
  devEditor.SchemeIndex := cboColorScheme.ItemIndex;
  if Assigned(MainForm) then
    MainForm.UpdateColorSchemeChecks;
end;

procedure TEditorOptForm.LoadColorScheme(const Value: String);
var
  idx: integer;
  fINI: TIniFile;
  pt: TPoint;
begin
  fINI := TIniFile.Create(devDirs.Config + Value + COLORSCHEME_EXT);
  pt := Point(0, 0);  //initialize
  try
    // Load regular Color Scheme elements for Lexer(Space, Comment, Preprocessor, etc.)
    for idx := 0 to ElementList.Items.Count - 8 - 1 do begin
      if fColorElems[idx] = '' then Continue;
      devEditor.ColorScheme.Values[fColorElems[idx]] :=
        fINI.ReadString('Editor.Custom', fColorElems[idx],
          devEditor.ColorScheme.Values[fColorElems[idx]]);
    end;

    // Load special items (breakpoints, selection, cursor, gutter, etc.)
    for idx := ElementList.Items.Count - 8 to pred(ElementList.Items.Count) do begin
      StrToPoint(pt, fINI.ReadString('Editor.Custom', ElementList.Items[idx], PointToStr(Point(clNone, clNone))));
      if CompareText(ElementList.Items[idx], cBP) = 0 then
        fBPColor := pt
      else if CompareText(ElementList.Items[idx], cErr) = 0 then
        fErrColor := pt
      else if CompareText(ElementList.Items[idx], cABP) = 0 then
        fABPColor := pt
      else if CompareText(ElementList.Items[idx], cBM) = 0 then
        fBMColor := pt
      else if CompareText(ElementList.Items[idx], cSel) = 0 then
        fSelColor := pt
      else if CompareText(ElementList.Items[idx], cCur) = 0 then
        fCurColor := pt
      else if CompareText(ElementList.Items[idx], cGut) = 0 then begin
        fGutColor := pt;
        SetGutter(CodeEdit);
        SetGutter(SnippetEdit);
        SetGutter(DefaultEdit);
      end else if CompareText(ElementList.Items[idx], cEdt) = 0 then begin
        fEditColor := pt;
        SetGutter(CodeEdit);
        SetGutter(SnippetEdit);
        SetGutter(DefaultEdit);
      end else if CompareText(ElementList.Items[idx], cFld) = 0 then begin
        fFoldColor := pt;
        SetGutter(CodeEdit);
        SetGutter(SnippetEdit);
        SetGutter(DefaultEdit);
      end else if CompareText(ElementList.Items[idx], cFld2) = 0 then begin
        fFoldColor2 := pt;
        SetGutter(CodeEdit);
        SetGutter(SnippetEdit);
        SetGutter(DefaultEdit);
      end;
    end;
  finally
    fINI.Free;
  end;
  ElementListClick(nil);
end;

procedure TEditorOptForm.FillColorSchemes;
var
  SR: TSearchRec;
begin
  if FindFirst(devDirs.Config + '*' + COLORSCHEME_EXT, faAnyFile, SR) = 0 then
    repeat
      cboColorScheme.Items.Add(StringReplace(SR.Name, COLORSCHEME_EXT, '', [rfIgnoreCase]));
    until FindNext(SR) <> 0;
end;

procedure TEditorOptForm.OnGutterClick(Sender: TObject; Button: TMouseButton; X, Y, Line: Integer; Mark: Integer);
var
  idx: integer;
begin
  idx := ElementList.Items.IndexOf(cGut);
  if idx <> -1 then begin
    ElementList.ItemIndex := idx;
    ElementListClick(Self);
  end;
end;


procedure TEditorOptForm.cbAutoSaveClick(Sender: TObject);
begin
  seSaveInteval.Enabled := cbAutoSave.Checked;
  //lblSaveInterval.Enabled := cbAutoSave.Checked;
  cmbSavefiles.Enabled := cbAutoSave.Checked;

  cmbFileName.Enabled := cbAutoSave.Checked;
  lblTimeStampExample.Enabled := cbAutoSave.Checked;
end;



procedure TEditorOptForm.cbSymbolCompleteClick(Sender: TObject);
begin
  cbArray.Enabled := cbSymbolComplete.Checked;
  cbBraces.Enabled := cbSymbolComplete.Checked;
  cbComments.Enabled := cbSymbolComplete.Checked;
  cbInclude.Enabled := cbSymbolComplete.Checked;
  cbParenth.Enabled := cbSymbolComplete.Checked;
  cbSingleQuotes.Enabled := cbSymbolComplete.Checked;
  cbDoubleQuotes.Enabled := cbSymbolComplete.Checked;
  cbDeleteCompleted.Enabled := cbSymbolComplete.Checked;
end;

procedure TEditorOptForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  ClearCodeIns;
  // Our caller needs the form, so let it call Free instead
  CloseAction := caHide;
end;


procedure TEditorOptForm.PagesMainChange(Sender: TObject);
begin
  case PagesMain.ActivePageIndex of
    0:
      AccessedTabs := AccessedTabs + [taGeneral];
    1:
      AccessedTabs := AccessedTabs + [taFonts];
    2:
      AccessedTabs := AccessedTabs + [taColors];
    3:
      AccessedTabs := AccessedTabs + [taSnippets];
    4:
      AccessedTabs := AccessedTabs + [taCompletion];
    5:
      AccessedTabs := AccessedTabs + [taAutosave];
  end;
end;


end.

