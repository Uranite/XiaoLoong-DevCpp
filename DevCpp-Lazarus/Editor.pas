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

unit Editor;

interface

uses
  {$IFDEF MSWINDOWS}Windows{$ELSE}LCLIntf, LCLType{$ENDIF}, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, CodeCompletion, CppParser,
  Menus, ImgList, ComCtrls, ExtCtrls, ATSynEdit, ATSynEdit_Adapter_EControl, //ATSynEdit_Adapters,
  ATSynEdit_LineParts, ATSynEdit_Bookmarks, ATSynEdit_Gutter_Decor, ATSynEdit_Carets, ATStringProc, LCLIntf,
  StrUtils, DateUtils, //Math,
  CodeToolTip, CBUtils, LazUTF8, Version, ATStrings;

// Convert a "display column" (1-based, where Tab expands to tab-stop positions)
// to a "logical column" (1-based, where each character including Tab counts as 1).
// GCC/grep report column numbers in display-column format;
// ATSynEdit uses logical columns (PosX = logical-1).
function DisplayColToLogicalCol(const LineText: String; DisplayCol: Integer;
  TabSize: Integer): Integer;

const
  cCommand_TextInsert = 150;
  cCommand_KeyBackspace = 152;
  cCommand_KeyTab = 155;
  cCommand_TextIndent = 240;
  cCommand_TextUnindent = 241;
  cCommand_SelectNone = 261;
  cCommand_ToggleOverwrite = 300;

type
  TEditor = class;
  TDebugGutter = class
  protected
    e: TEditor;
  public
    constructor Create(editor: TEditor);
  end;

  // Define what we want to see of the word at any position
  TWordPurpose = (
    wpCompletion, // walk backwards over words, array, functions, parents, no forward movement
    wpEvaluation, // walk backwards over words, array, functions, parents, forwards over words, array
    wpInformation // walk backwards over words, array, functions, parents, forwards over words
    );

  // Define why we are allowed to change the cursor to a handpoint
  THandPointReason = (
    hprPreprocessor, // cursor hovers above preprocessor line
    hprIdentifier, // cursor hovers above identifier
    hprSelection,  //, // cursor hovers above selection
    hprNone // mouseover not allowed
    );

  // Define what we want to skip
  TSymbolCompleteState = (
    scsSkipped, // skipped over completed symbol
    scsInserted, // opening symbol has been inserted
    scsFinished // keystroke that triggered insertion has completed
    );

  TEditor = class(TObject)
  private
    fInProject: boolean;
    fFileName: UnicodeString;
    fNew: boolean;
    fText: TATSynEdit;
    fModified: boolean; //Added by Anbangli
    fTabSheet: TTabSheet;
    fErrorLine: integer;
    fErrorWasBreakpoint: Boolean; // Whether BK_ERROR replaced BK_BREAKPOINT via Kind promotion
    fLastLineCount: Integer; // Track line count for stale BK_BREAKPOINT cleanup
    fRestoringBreakpoints: Boolean; // Guard flag for OnChangeBookmarks during RestoreBreakpointBackgrounds
    fActiveLine: integer;
    fDebugGutter: TDebugGutter;
    fCurrentWord: String;
    fCurrentEvalWord: String;
    fIgnoreCaretChange: boolean;
    fPreviousEditors: TList;
    fDblClickTime: Cardinal;
    fDblClickMousePos: TPoint;

    fCompletionTimer: TTimer;
    fCompletionBox: TCodeCompletion;
    fCompletionInitialPosition: TPoint;

    fFunctionTipTimer: TTimer;
    fFunctionTip: TCodeToolTip;

    fParenthCompleteState: TSymbolCompleteState;
    fArrayCompleteState: TSymbolCompleteState;
    fNeedReparse: boolean; // Set when text inserted before editor is visible
    fBraceCompleteState: TSymbolCompleteState;
    fSingleQuoteCompleteState: TSymbolCompleteState;
    fDoubleQuoteCompleteState: TSymbolCompleteState;
        fFileEncoding: integer; // 0=ANSI, 1=UTF-8 BOM, 2=UTF-8
    fLastSelHighlightText: string; // Last selected text used for occurrence highlighting
    procedure EditorKeyPress(Sender: TObject; var Key: Char);
    procedure EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditorMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure EditorMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint; var Handled: Boolean);

    procedure EditorDblClick(Sender: TObject; var AHandled: boolean);
    procedure EditorClick(Sender: TObject);
    procedure EditorStatusChange(Sender: TObject);
    procedure EditorReplaceText(Sender: TObject; const aSearch, aReplace: String; Line, Column: integer);
    procedure EditorDropFiles(Sender: TObject; x, y: integer; aFiles: TStrings);
    procedure EditorMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure EditorExit(Sender: TObject);
    procedure EditorDrawLine(Sender: TObject; C: TCanvas;
      ALineIndex: integer; AX, AY: integer; const AStr: atString;
      const ACharSize: TATEditorCharSize; constref AExtent: TATIntFixedArray);
    procedure EditorCalcBookmarkColor(Sender: TObject; ABookmarkKind: integer; var AColor: TColor);
    procedure EditorGutterClick(Sender: TObject; ABand: integer; ALineNum: integer; var AHandled: boolean);
    // ATSynEdit migration: EditorPaintTransient stub (SynEdit-only, bracket matching now handled natively)
    procedure EditorPaintTransient(Sender: TObject; Canvas: TCanvas; TransientType: integer);
    procedure EditorContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure EditorEnter(Sender: TObject);
    procedure EditorCaretChange(Sender: TObject);
    procedure EditorBookmarksChange(Sender: TObject);
    procedure UpdateSelectionHighlight;
    procedure HighlightBrackets;
    function FindBracketMatch(StartOffs: integer; out MatchOffs: integer): boolean;
    function AngleBracketInteriorOk(const s: UnicodeString; startOffs, matchOffs: integer): boolean;
    function FindQuoteMatch(const s: UnicodeString; StartOffs: integer; out MatchOffs: integer): boolean;
    procedure EditorCommand(Sender: TObject; ACommand: integer; AInvoke: TATCommandInvoke; const AText: string; var AHandled: boolean);
    procedure CompletionKeyPress(Sender: TObject; var Key: Char);
    procedure CompletionInsert(const append: String);
    procedure CompletionTimer(Sender: TObject);
    function FunctionTipAllowed: boolean;
    procedure FunctionTipTimer(Sender: TObject);
    procedure HandleSymbolCompletion(var Key: Char);
    procedure HandleSymbolCompletionFromVK(Key: Word; Shift: TShiftState);
    procedure HandleCodeCompletion(var Key: Char);
    function HandpointAllowed(var MousePos: TPoint; ShiftState: TShiftState): THandPointReason;
    procedure SetFileName(const value: UnicodeString);
    procedure OnMouseOverEvalReady(const evalvalue: AnsiString);
    function HasBreakPoint(Line: integer): integer;
    procedure DebugAfterPaint(ACanvas: TCanvas; AClip: TRect; FirstLine, LastLine: integer);
    // ATSynEdit migration: ScanForFoldRanges stub (SynEdit-only, kept as no-op)
    procedure ScanForFoldRanges(Sender: TObject; TopFoldRanges: Pointer; LinesToScan: TStrings; FromLine, ToLine: Integer);
    function GetPageControl: TPageControl;
    procedure SetPageControl(Value: TPageControl);
  public
    BookmarkLines: array [0..10] of integer;  //bookmark lines. //by abli
    procedure ResetBookMarks;
    procedure ToggleBookMark;
    procedure GotoPrevBookmark;
    procedure GotoNextBookmark;
    procedure MarkInvalidIdentifiers;
    procedure UpdateCurrentLineMarker;
    procedure RestoreBreakpointBackgrounds;
    constructor Create(const Filename: String; InProject, NewFile: boolean; ParentPageControl: TPageControl);
    destructor Destroy; override;
    function Save: boolean;
    function SaveAs: boolean;
    //function is_UTF8_CODE(BB: TBytes): Boolean;
    procedure Activate;
    procedure GotoLine;
    procedure SetCaretPosAndActivate(Line, Col: integer); // needs to activate in order to place cursor properly
    procedure ExportToHTML;
    procedure ExportToRTF;
    procedure ExportToTEX;
    procedure InsertString(Value: String; MoveCursor: boolean);
    procedure SetErrorFocus(Col, Line: integer);
    procedure GotoActiveBreakpoint;
    procedure SetActiveBreakpointFocus(Line: integer);
    procedure RemoveBreakpointFocus;
    procedure UpdateCaption(const NewCaption: String);
    procedure InsertDefaultText;
    procedure ForceSyntaxRefresh;
    procedure ToggleBreakPoint(Line: integer);
    function GetWordAtPosition(P: TPoint; Purpose: TWordPurpose): String;
    procedure IndentSelection;
    procedure UnindentSelection;
    procedure InitCompletion;
    procedure ShowCompletion;
    procedure DestroyCompletion;
    property PreviousEditors: TList read fPreviousEditors;
    property FileName: UnicodeString read fFileName write SetFileName;
    property InProject: boolean read fInProject write fInProject;
    property New: boolean read fNew write fNew;
    property Text: TATSynEdit read fText write fText;
    property Modified: Boolean read fModified write fModified; //added by Anbangli
    property TabSheet: TTabSheet read fTabSheet write fTabSheet;
    property FunctionTip: TCodeToolTip read fFunctionTip;
    property CompletionBox: TCodeCompletion read fCompletionBox;
    property FileEncoding: integer read fFileEncoding;
    property PageControl: TPageControl read GetPageControl write SetPageControl;
    function GetFileEncodingName: String; // 'ANSI', 'UTF-8 BOM', or 'UTF-8'
    function GetFileLineEndsName: String; // 'CR', 'LF', or 'CR+LF'
    function GetFileLineEndsIndex: integer; // 0=CR+LF(Windows), 1=LF(Unix)
    procedure ConvertEncoding(newEncoding: integer);
    procedure ConvertLineEnds(newLineEndsIndex: integer); // 0=CR+LF(Windows), 1=LF(Unix)
  end;

implementation

uses
  main, project, MultiLangSupport, devcfg, utils,
  DataFrm, GotoLineFrm, debugreader, IncrementalFrm, //Macros, CodeCompletionForm,
  ATSynEdit_Markers;

const
  // Bookmark kind constants for breakpoint/error line background display
  // Using Bookmarks2 to avoid conflict with user bookmarks (Kind=0)
  BK_BREAKPOINT       = 102;
  BK_ACTIVEBREAKPOINT = 103;
  BK_ERROR            = 104;
  BK_BOOKMARK         = 105;
  BK_CURRENTLINE      = 106;

  cInvalidIdentTag    = 200; // Tag for CJK-in-identifier markers
  cSelHighlightTag    = 201; // Tag for selection-occurrence highlight markers
  cBracketHiliteTag   = 202; // Tag for matching-bracket bold markers (Attribs)
  cCurrentLineTag     = 1;   // Tag for BK_CURRENTLINE in Bookmarks2

{ TDebugGutter }

constructor TDebugGutter.Create(editor: TEditor);
begin
  e := editor;
end;

{ TEditor }

constructor TEditor.Create(const Filename: String; InProject, NewFile: boolean; ParentPageControl: TPageControl);
var
  s: String;
  I: integer;
  e: TEditor;

  //fs: TFileStream;
  //len: int64;
  //buf, buf2: TBytes;
  //code: integer; //0 - ANSI;  1- UTF-8 BOM; 2 - UTF-8
  //tss: TStrings;
begin
  // Set generic options
  fErrorLine := -1;
  fErrorWasBreakpoint := False;
  fLastLineCount := 0;
  fRestoringBreakpoints := False;
  fActiveLine := -1;
  fLastSelHighlightText := '';
  fInProject := InProject;
  if FileName <> '' then
    fFileName := UnicodeString(Filename)
  else
    fFileName := UnicodeString(Lang[ID_UNTITLED] + IntToStr(dmMain.GetNewFileNumber));

  // Remember previous tabs
  fPreviousEditors := TList.Create;
  if Assigned(ParentPageControl.ActivePage) then begin
    e := TEditor(ParentPageControl.ActivePage.Tag); // copy list of previous editor
    for I := 0 to e.PreviousEditors.Count - 1 do
      fPreviousEditors.Add(e.PreviousEditors[i]);
    fPreviousEditors.Add(Pointer(e)); // make current editor history too
  end;

  // Create a new tab
  fTabSheet := TTabSheet.Create(ParentPageControl);
  fTabSheet.Caption := AnsiString(ExtractFileName(fFilename)); // UntitlexX or main.cpp
  fTabSheet.PageControl := ParentPageControl;
  fTabSheet.Tag := PtrInt(Self); // Define an index for each tab

  // Create an editor and set static options
  fText := TATSynEdit.Create(fTabSheet);

  // Load the file using Lines
  if not NewFile and FileExists(FileName) then begin
    {
    //SynEdit support ANSI code or "UTF-8 BOM" code, but doesn't support UTF-8 code.
    //Need to convert UTF-8 to ANSI code.
    //check file code is UTF-8 or not //by Anbang LI
    fs := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    len := fs.Size;
    code := 0; //0 - ANSI;  1- UTF-8 BOM; 2 - UTF-8
    try
      SetLength(buf, len);
      if fs.Read(buf[0], len) >= 3 then //Check UTF-8 BOM (byte order mark) in the first 3 bytes
        begin
          if (buf[0] = $EF) and (buf[1] = $BB) and (buf[2] = $BF) then
          begin
            //isUTF8 := False //UTF-8 BOM found. this is "UTF-8 BOM" code, not "UTF-8" code
            code := 1; //0 - ANSI;  1- UTF-8 BOM; 2 - UTF-8
            SetLength(buf2, len-3);
            for I := 0 to len-3 do
              buf2[I] := buf[I+3];
          end
          else
            //isUTF8 := is_UTF8_CODE(buf); //detailed check
            if (is_UTF8_CODE(buf)) then //detailed check
              code := 2 //0 - ANSI;  1- UTF-8 BOM; 2 - UTF-8
            else
              code := 0; //ANSI
        end;
    finally
      fs.Free;
    end;
    }
    //convert file from "UTF-8" or "UTF-8 BOM" to "ANSI" coding. //by Anbang LI
    //In fact, SynEdit can deal with ANSI and "UTF-8 BOM" but not "UTF-8",
    //but Astyle can only deal with ANSI. So we have to convert to ANSI.
    {
    if (code > 0) then  //0 - ANSI;  1- UTF-8 BOM; 2 - UTF-8
      begin
       tss := TStringList.Create;
        try
          begin
            //tss.LoadFromFile(FileName);
            //tss.Text := Utf8ToAnsi(tss.Text);  //UTF8 ת��Ϊ Ansi����ĩ���ֳ���
            if (code = 1) then //1- UTF-8 BOM; 2 - UTF-8
            begin
              //convert UTF-8 coded TBytes array ANSI code
              buf2 := TEncoding.Convert(TEncoding.UTF8, TEncoding.Default, buf2);
              //convert ANSI coded TBytes array to strings
              tss.Text := TEncoding.Default.GetString(buf2);
            end
            else //2 - UTF-8
            begin
              buf := TEncoding.Convert(TEncoding.UTF8, TEncoding.Default, buf);
              tss.Text := TEncoding.Default.GetString(buf);
            end;
            //tss.WriteBOM := False;
            tss.SaveToFile(FileName, TEncoding.Default);

//            tss.Text := TEncoding.UTF8.GetString(buf);
//            tss.WriteBOM := True;
//            tss.SaveToFile(FileName, TEncoding.UTF8);  //UTF-8 BOM
          end;
        finally
          tss.Free;
      end;
    end;
    }

    fText.Strings.LoadFromFile(FileName, []);
    fNew := False;

    // Derive fFileEncoding from ATSynEdit's detected encoding (don't force to ANSI).
    // ATSynEdit detects encoding from the file content on disk.
    if fText.Strings.Encoding = TATFileEncoding.UTF8 then
      if fText.Strings.SaveSignUtf8 then
        fFileEncoding := 1  // UTF-8 BOM
      else
        fFileEncoding := 2  // UTF-8 (no BOM)
    else
      fFileEncoding := 0;   // ANSI

    // Save main.cpp as main.123456789.cpp
    if devData.Backups then begin
      s := '.' + IntToStr(DateTimeToUnix(Now)) + ExtractFileExt(FileName);
      fText.Strings.SaveToFile(ChangeFileExt(FileName, s));
    end;
  end else begin
    fNew := True;
    fFileEncoding := 0; // New file defaults to ANSI

    // Force ANSI encoding for new files so SaveToFile writes ANSI without BOM.
    fText.Strings.Encoding := TATFileEncoding.ANSI;
    fText.Strings.SaveSignUtf8 := False;
  end;

  // Set constant options
  fText.Parent := fTabSheet;
  fText.Visible := True;
  fText.Align := alClient;
  fText.TabStop := True; // Ensure editor can receive keyboard focus
  fText.PopupMenu := MainForm.EditorPopup;
  fText.OnContextPopup := @EditorContextPopup;
  fText.ShowHint := True;
  fText.OptFoldEnabled := True; // Enable code folding in ATSynEdit
  fText.OnChange := @EditorStatusChange;
  // ATSynEdit: OnClickGutter uses TATSynEditClickGutterEvent(Sender; ABand; ALineNum; var AHandled)
  // We bind EditorGutterClick with a wrapper that matches the new signature
  fText.OnClickGutter := @EditorGutterClick;
  // Breakpoint/active/error line backgrounds now handled by Bookmarks2 + OnCalcBookmarkColor
  // (renders BEFORE text, avoiding the "background covers text" issue)
  // OnDrawLine is no longer bound — it's kept as a no-op declaration for backward compatibility.
  // Set up GutterDecor for breakpoint indicators using existing GutterImages
  // ATSynEdit 2.27.0: GutterBandDecor property removed; decor icons now paint
  // in the bookmarks gutter band by default (bookmark icons shift right).
  fText.ImagesGutterDecor := dmMain.GutterImages;
  fText.Strings.GutterDecor1 := fText.GutterDecor;
  // Use Bookmarks2 for breakpoint/error line backgrounds (renders BEFORE text)
  fText.OnCalcBookmarkColor := @EditorCalcBookmarkColor;
  // Disable built-in current line highlight — we manage it via Bookmarks2 instead
  // so special line backgrounds (breakpoints, errors, bookmarks) take priority.
  // Note: must be set AFTER AssignEditor below (which re-enables it).
  //fText.OptShowCurLine := False; // moved after AssignEditor
  fText.OnEnter := @EditorEnter;
  fText.OnExit := @EditorExit;
  fText.OnKeyPress := @EditorKeyPress;
  fText.OnCommand := @EditorCommand;
  fText.OnKeyDown := @EditorKeyDown;
  fText.OnKeyUp := @EditorKeyUp;
  fText.OnClick := @EditorClick;
  // ATSynEdit: use OnClickDouble instead of OnDblClick
  fText.OnClickDouble := @EditorDblClick;
  fText.OnMouseMove := @EditorMouseMove;
  fText.OnMouseUp := @EditorMouseUp;
  fText.OnChangeCaretPos := @EditorCaretChange;
  fText.OnChangeBookmarks := @EditorBookmarksChange;

  //fText.Highlighter.Assign(devEditor.ColorScheme); //debug

  // Set the variable options
  devEditor.AssignEditor(fText, AnsiString(fFileName));

  // Disable built-in current line highlight AFTER AssignEditor (which re-enables it)
  fText.OptShowCurLine := False;

  // Disable mouse column-selection frame (dashed rectangle)
  fText.OptShowMouseSelFrame := False;

  // Disable auto-detection of URLs and email addresses in text
  fText.OptShowURLs := False;

  // Disable mouse click at the end of line and allow input there. (VirtualSpace)
  fText.OptCaretVirtual := False;

  // Ensure caret is visible and blinking (must be after AssignEditor)
  fText.OptCaretBlinkEnabled := True;
  fText.OptCaretHideUnfocused := False;
  fText.CaretShowEnabled := True; // Force caret to be visible

  // Create a gutter
  fDebugGutter := TDebugGutter.Create(self);

  // Function parameter tips
  fFunctionTip := TCodeToolTip.Create(Application);
  fFunctionTip.Editor := fText;
  fFunctionTip.Parser := MainForm.CppParser;

  // Initialize code completion stuff
  InitCompletion;

  // Setup a monitor which keeps track of outside-of-editor changes
  MainForm.FileMonitor.Monitor(AnsiString(fFileName));

  // Set read-only for system header files (standard library headers)
  if not fNew and MainForm.CppParser.IsSystemHeaderFile(fFileName) then
    fText.ModeReadOnly := True;

  // Force internal state calculation (wrap info, scroll state, etc.).
  // Without this, a new blank editor has FWrapInfo uncalculated,
  // causing 'List index (-1)' in atsynedit_fgl.pas when typing at pos (0,0).
  fText.Update(True, False);

  // Set status bar for the first time
  EditorStatusChange(Self);
  // Initialize current line marker
  UpdateCurrentLineMarker;

  // Set Completions States for the first time
  fParenthCompleteState := scsSkipped;    // )
  fArrayCompleteState := scsSkipped;      // ]
  fBraceCompleteState := scsSkipped;      // }
  fSingleQuoteCompleteState := scsSkipped;   // '
  fDoubleQuoteCompleteState := scsSkipped;   // "

  //bookmarks lines. Only use 0..9. The 10th is always set as 9999.
  for I := 0 to 10 do
    BookMarkLines[I] := 9999;
end;

destructor TEditor.Destroy;
begin
  // Deactivate the file change monitor
  MainForm.FileMonitor.UnMonitor(AnsiString(fFileName));

  // Delete breakpoints in this editor
  MainForm.Debugger.DeleteBreakPointsOf(self);

  // Destroy code completion stuff
  DestroyCompletion;

  // Free everything
  FreeAndNil(fFunctionTip);
  FreeAndNil(fDebugGutter);
  // Free EControl adapter (each editor gets its own instance from GetHighlighter)
  if Assigned(fText.AdapterForHilite) and (fText.AdapterForHilite is TATAdapterEControl) then
    TATAdapterEControl(fText.AdapterForHilite).Free;
  fText.AdapterForHilite := nil;
  FreeAndNil(fText);
  FreeAndNil(fTabSheet);
  FreeAndNil(fPreviousEditors);

  // Move into TObject.Destroy...
  inherited;
end;

function TEditor.GetPageControl: TPageControl;
begin
  if Assigned(fTabSheet) then
    Result := fTabSheet.PageControl
  else
    Result := nil;
end;

procedure TEditor.SetPageControl(Value: TPageControl);
begin
  if Assigned(fTabSheet) then
    fTabSheet.PageControl := Value;
end;

procedure TEditor.OnMouseOverEvalReady(const evalvalue: AnsiString);
begin
  fText.Hint := fCurrentEvalWord + ' = ' + evalvalue;
  MainForm.Debugger.OnEvalReady := nil;
end;

procedure TEditor.Activate;
begin
  // Don't waste time refocusing
  if fText.Focused then
    Exit;

  // Allow the user to start typing right away
  fTabSheet.PageControl.ActivePage := fTabSheet;
  fTabSheet.PageControl.OnChange(fTabSheet.PageControl); // event is not fired when changing ActivePage

  // If text was inserted before the editor was visible (e.g. InsertDefaultText),
  // reparse now so syntax highlighting appears immediately.
  if fNeedReparse then begin
    fNeedReparse := False;
    if Assigned(fText.AdapterForHilite) and (fText.AdapterForHilite is TATAdapterEControl) then begin
      TATAdapterEControl(fText.AdapterForHilite).ParseFromLine(0, True);
      fText.Update(True, False);
    end;
  end;
end;

procedure TEditor.EditorGutterClick(Sender: TObject; ABand: integer; ALineNum: integer; var AHandled: boolean);
begin
  // ATSynEdit line numbers are 0-based, convert to 1-based for ToggleBreakPoint
  ToggleBreakPoint(ALineNum + 1);
  AHandled := True; // mark as handled
end;

procedure TEditor.ToggleBreakpoint(Line: integer);
var
  thisbreakpoint: integer;
  decor: TATGutterDecorData;
  bm: TATBookmarkData;
begin
  thisbreakpoint := HasBreakPoint(Line);

  if thisbreakpoint <> -1 then begin
    MainForm.Debugger.RemoveBreakpoint(Line, self);
    fText.GutterDecor.DeleteForLine(Line - 1); // 0-based line
    // Remove bookmark background from Bookmarks2
    fText.Strings.Bookmarks2.DeleteForLine(Line - 1);
  end else begin
    MainForm.Debugger.AddBreakpoint(Line, self);
    decor := Default(TATGutterDecorData);
    decor.DeleteOnDelLine := True;
    decor.LineNum := Line - 1; // 0-based
    decor.ImageIndex := 0; // red circle
    fText.GutterDecor.Add(decor);
    // Add bookmark for line background (renders BEFORE text)
    bm := Default(TATBookmarkData);
    bm.LineNum := Line - 1;
    bm.Kind := BK_BREAKPOINT;
    bm.AutoDelete := TATBookmarkAutoDelete.Delete; // Auto-remove when line is deleted
    fText.Strings.Bookmarks2.Add(bm, False);
  end;

  fText.Invalidate;
end;

function TEditor.HasBreakPoint(Line: integer): integer;
var
  I: integer;
begin
  result := -1;
  for I := 0 to MainForm.Debugger.BreakPointList.Count - 1 do
    if PtrInt(PBreakPoint(MainForm.Debugger.BreakPointList.Items[I])^.editor) = PtrInt(Self) then
      if PBreakPoint(MainForm.Debugger.BreakPointList.Items[I])^.line = Line then begin
        Result := I;
        break;
      end;
end;

procedure TEditor.EditorDrawLine(Sender: TObject; C: TCanvas;
  ALineIndex: integer; AX, AY: integer; const AStr: atString;
  const ACharSize: TATEditorCharSize; constref AExtent: TATIntFixedArray);
begin
  // Breakpoint/active/error line backgrounds now handled by Bookmarks2 + OnCalcBookmarkColor
  // (renders BEFORE text, avoiding the "background covers text" issue)
end;

procedure TEditor.EditorCalcBookmarkColor(Sender: TObject; ABookmarkKind: integer; var AColor: TColor);
var
  pt: TPoint;
begin
  pt := default(TPoint);
  case ABookmarkKind of
    BK_ACTIVEBREAKPOINT: begin
      StrtoPoint(pt, devEditor.ColorScheme.Values[cABP]);
      AColor := pt.X;
    end;
    BK_BREAKPOINT: begin
      StrtoPoint(pt, devEditor.ColorScheme.Values[cBP]);
      AColor := pt.X;
    end;
    BK_ERROR: begin
      StrtoPoint(pt, devEditor.ColorScheme.Values[cErr]);
      AColor := pt.X;
    end;
    BK_BOOKMARK: begin
      StrtoPoint(pt, devEditor.ColorScheme.Values[cBM]);
      AColor := pt.X;
    end;
    BK_CURRENTLINE: begin
      StrtoPoint(pt, devEditor.ColorScheme.Values[cCur]);
      AColor := pt.X;
    end;
  end;
end;

procedure TEditor.DebugAfterPaint(ACanvas: TCanvas; AClip: TRect; FirstLine, LastLine: integer);
begin
  // Debug gutter painting - TODO: integrate via OnPaintLine event
end;

procedure TEditor.EditorDropFiles(Sender: TObject; x, y: integer; aFiles: TStrings);
var
  sl: TStringList;
  I: integer;
begin
  // Insert into current editor
  if devEditor.InsDropFiles then begin
    // ATSynEdit: set caret to drop position using ClientPosToCaretPos
    fText.Carets[0].PosX := x;
    fText.Carets[0].PosY := y;

    sl := TStringList.Create;
    try
      for I := 0 to pred(aFiles.Count) do begin
        sl.LoadFromFile(aFiles[I]);
        // ATSynEdit: insert file content at caret using DoCommand
        fText.DoCommand(cCommand_TextInsert, TATCommandInvoke(0), UnicodeString(sl.Text));
      end;
    finally
      sl.Free;
    end;
    // Open list of provided files
  end else begin
    MainForm.OpenFileList(TStringList(aFiles));
  end;
end;

procedure TEditor.EditorReplaceText(Sender: TObject; const aSearch, aReplace: String; Line, Column: integer);
var
  pt: TPoint;
begin
  // ATSynEdit: CaretPosToClientPos returns TATPoint - use with to access coordinates
  with fText.CaretPosToClientPos(Point(fText.Carets[0].PosX, fText.Carets[0].PosY)) do
    pt := fText.ClientToScreen(Point(Integer(X), Integer(Y)));
  MessageBeep(MB_ICONQUESTION);
  case MessageDlgPos(format(Lang[ID_MSG_SEARCHREPLACEPROMPT], [aSearch]), mtConfirmation, [mbYes, mbNo, mbCancel, mbAll], 0, pt.x, pt.y + fText.TextCharSize.Y) of
    mrYes: ; // Replace
    mrNo: ; // Skip
    mrCancel: ; // Cancel
    mrAll: ; // Replace all
  end;
end;

// Handle WM_KILLFOCUS instead of all the special cases to hide the code tooltip

procedure TEditor.EditorExit(Sender: TObject);
begin
  if Assigned(fFunctionTip) then
    fFunctionTip.ReleaseHandle;
end;

// Handling this here instead of in PageControlChange because when switching between two active editors side by side
// PageControlChange will not happen, but the editor will be entered and this will be executed

procedure TEditor.EditorEnter(Sender: TObject);
begin
  // Set title bar to current file
  MainForm.UpdateAppTitle;

  // Set classbrowser to current file
  MainForm.ClassBrowser.CurrentFile := AnsiString(fFileName);

  // Set compiler selector to current file
  MainForm.UpdateCompilerList;

  // Update status bar
  MainForm.SetStatusbarLineCol;
  MainForm.UpdateEncodingStatus;
  MainForm.UpdateLineEndsStatus;

  // Update focus of incremental search
  if Assigned(IncrementalForm) and IncrementalForm.Showing then
    IncrementalForm.Editor := fText;
end;

procedure TEditor.ResetBookMarks;  //reset bookmark after formatting
var
  i, n: integer;
  Data: TATBookmarkData;
begin
  n := Text.Strings.Count;

  // Clear ATSynEdit's built-in bookmarks (they were invalidated by text replacement)
  fText.Strings.Bookmarks.Clear;

  // Re-add valid bookmarks from local BookmarkLines array
  for I := 0 to 9 do begin
    if (BookmarkLines[I] <> 9999) then begin
      if (BookmarkLines[I] < n) then begin
        // Valid bookmark - re-add to ATSynEdit's gutter system
        Data.LineNum := BookmarkLines[I];
        Data.Kind := 0;
        Data.Tag := 0;
        Data.AutoDelete := TATBookmarkAutoDelete.DontDelete;
        Data.ShowInBookmarkList := True;
        Data.Hint := nil;
        fText.Strings.Bookmarks.Add(Data, True);
        // Also add to Bookmarks2 with BK_BOOKMARK kind for background color
        // Remove old entry first, then add fresh one
        fText.Strings.Bookmarks2.DeleteForLine(BookmarkLines[I]);
        Data.Kind := BK_BOOKMARK;
        fText.Strings.Bookmarks2.Add(Data, False);
      end else begin
        // Bookmark past end of file - clear it
        BookmarkLines[I] := 9999;
      end;
    end;
  end;
  fText.Invalidate;
end;

procedure TEditor.ToggleBookMark;
var
  i, j, line: integer;
  Data: TATBookmarkData;
  //BookmarkIndex: integer;
begin
  line := fText.Carets[0].PosY; // ATSynEdit 0-based line

  // Toggle via ATSynEdit's bookmark API (gutter display)
  Data.LineNum := line;
  Data.Kind := 0;
  Data.Tag := 0;
  Data.AutoDelete := TATBookmarkAutoDelete.DontDelete;
  Data.ShowInBookmarkList := True;
  Data.Hint := nil;
  fText.Strings.Bookmarks.Add(Data, True);
  fText.Invalidate;

  // Sync local BookmarkLines array (1-based) for GotoPrev/GotoNext navigation
  line := line + 1; // convert to 1-based
  for I := 0 to 9 do begin
    if (BookmarkLines[I] = line) then begin // bookmark exists, remove it
      BookmarkLines[I] := 9999;
      // Also remove from Bookmarks2 background
      fText.Strings.Bookmarks2.DeleteForLine(line - 1);
      for J := I to 9 do begin
        BookmarkLines[J] := BookmarkLines[J+1];
      end;
      Exit;
    end;
  end;

  // Bookmark doesn't exist in local array, add it
  // Ensure we have space
  if (BookmarkLines[9] <> 9999) then
    BookmarkLines[9] := 9999;
  // Find insertion point (sorted ascending)
  for I := 8 downto 0 do begin
    if BookmarkLines[I] < line then
      Break
    else begin
      BookmarkLines[I+1] := BookmarkLines[I];
    end;
  end;
  BookmarkLines[I+1] := line;

  // Add to Bookmarks2 for background color
  Data.LineNum := line - 1;
  Data.Kind := BK_BOOKMARK;
  Data.Tag := 0;
  Data.AutoDelete := TATBookmarkAutoDelete.DontDelete;
  Data.ShowInBookmarkList := False;
  Data.Hint := nil;
  fText.Strings.Bookmarks2.Add(Data, False);
end;

procedure TEditor.GotoPrevBookmark;
var
  I, line: integer;
begin
  line := fText.Carets[0].PosY; // 0-based
  for I := 9 downto 0 do begin
    if (BookmarkLines[I] < 9999) and (BookmarkLines[I] < line + 1) then begin
      fText.Carets[0].PosX := 0;
      fText.Carets[0].PosY := BookmarkLines[I] - 1;
      fText.Invalidate;
      Exit;
    end;
  end;
  // wrap around: go to last bookmark
  for I := 9 downto 0 do begin
    if BookmarkLines[I] < 9999 then begin
      fText.Carets[0].PosX := 0;
      fText.Carets[0].PosY := BookmarkLines[I] - 1;
      fText.Invalidate;
      Exit;
    end;
  end;
end;

procedure TEditor.GotoNextBookmark;
var
  I, line: integer;
begin
  line := fText.Carets[0].PosY; // 0-based
  for I := 0 to 9 do begin
    if (BookmarkLines[I] < 9999) and (BookmarkLines[I] > line + 1) then begin
      fText.Carets[0].PosX := 0;
      fText.Carets[0].PosY := BookmarkLines[I] - 1;
      fText.Invalidate;
      Exit;
    end;
  end;

  // wrap around: go to first bookmark
  for I := 0 to 9 do begin
    if BookmarkLines[I] < 9999 then begin
      fText.Carets[0].PosX := 0;
      fText.Carets[0].PosY := BookmarkLines[I] - 1;
      Exit;
    end;
  end;
end;

procedure TEditor.MarkInvalidIdentifiers;

  function IsCharNonASCII(c: WideChar): Boolean;
  begin
    Result := Ord(c) > 127;
  end;

var
  i, j, wordStart: Integer;
  s: UnicodeString;
  Part: TATLinePart;
  hasNonASCII: Boolean;
  inBlockComment: Boolean;
  commentActive: Boolean;
  lineCommentActive: Boolean;
  inString: Boolean;
  stringChar: WideChar;
  sl: TStringList;
  incFg: TColor;
  incBg: TColor;
  incStyles: Byte;
begin
  if not Assigned(fText) then Exit;
  fText.Attribs.DeleteWithTag(cInvalidIdentTag);

  // Parse "Incorrect" style from syntax highlight scheme
  incFg := clRed;
  incBg := clNone;
  incStyles := afsFontBold or afsFontItalic;
  sl := TStringList.Create;
  try
    sl.CommaText := devEditor.ColorScheme.Values['Incorrect'];
    if sl.Count >= 5 then begin
      incFg := StringToColor(Trim(sl[0]));
      incBg := StringToColor(Trim(sl[1]));
      incStyles := 0;
      if Trim(sl[2]) = '1' then incStyles := incStyles or afsFontBold;
      if Trim(sl[3]) = '1' then incStyles := incStyles or afsFontItalic;
    end;
  finally
    sl.Free;
  end;

  inBlockComment := False;

  for i := 0 to fText.Strings.Count - 1 do begin
    s := fText.Strings.Lines[i];
    if s = '' then begin
      // Block comment state carries over even on empty lines
      Continue;
    end;

    commentActive := inBlockComment;
    lineCommentActive := False;
    inString := False;
    stringChar := #0;
    j := 1;

    while j <= Length(s) do begin
      // Detect block comment end
      if commentActive then begin
        if (j < Length(s)) and (s[j] = '*') and (s[j + 1] = '/') then begin
          commentActive := False;
          Inc(j, 2);
          Continue;
        end;
        Inc(j);
        Continue;
      end;

      // If inside line comment, skip rest of line
      if lineCommentActive then
        Break; // rest of line is line comment

      // Inside string/char literal: skip content (incl. CJK chars),
      // handle backslash escapes, detect closing quote.
      // Must be checked BEFORE comment markers, so that "//" or "/*"
      // inside a string literal is not mistaken for a comment.
      if inString then begin
        if (s[j] = '\') and (j < Length(s)) then
          Inc(j, 2) // skip escaped char (e.g. \" \\ \n)
        else begin
          if s[j] = stringChar then
            inString := False;
          Inc(j);
        end;
        Continue;
      end;

      // Detect string/char literal start
      if (s[j] = '"') or (s[j] = '''') then begin
        inString := True;
        stringChar := s[j];
        Inc(j);
        Continue;
      end;

      // Detect comment markers (only when not in comment/string)
      if (j < Length(s)) and (s[j] = '/') and (s[j + 1] = '*') then begin
        commentActive := True;
        Inc(j, 2);
        Continue;
      end;
      if (j < Length(s)) and (s[j] = '/') and (s[j + 1] = '/') then begin
        lineCommentActive := True;
        Inc(j, 2);
        Continue;
      end;

      // Not in comment: scan for words containing non-ASCII characters
      if IsCharWordInIdentifier(s[j]) or IsCharNonASCII(s[j]) then begin
        wordStart := j;
        hasNonASCII := IsCharNonASCII(s[j]);
        Inc(j);
        while (j <= Length(s)) and
          (IsCharWordInIdentifier(s[j]) or IsCharNonASCII(s[j])) do begin
          if IsCharNonASCII(s[j]) then
            hasNonASCII := True;
          Inc(j);
        end;

        if hasNonASCII then begin
          InitLinePart(Part);
          Part.ColorFont := incFg;
          Part.ColorBG := incBg;
          Part.ColorBorder := incFg;
          Part.FontStyles := incStyles;
          Part.BorderDown := TATLineStyle.Solid;

          fText.Attribs.Add(
            Point(wordStart - 1, i),       // 0-based column, line
            Point(j - wordStart, 0),        // length, single line
            TATMarkerTags.Init(cInvalidIdentTag, 0),
            @Part
          );
        end;
      end else
        Inc(j);
    end;

    // Save block comment state for next line
    inBlockComment := commentActive;
  end;
end;

procedure TEditor.HighlightBrackets;
var
  cx, cy: integer;
  offs, startOffs, matchOffs: integer;
  TextUni: UnicodeString;
  leftCh, rightCh: Char;
  pStart, pMatch: TPoint;
  Part: TATLinePart;
  found: Boolean;
  startCh: WideChar;
begin
  if not Assigned(fText) then Exit;
  if fText.Carets.Count = 0 then Exit;

  // Remove previous bracket highlight (don't touch URL/selection markers)
  fText.Attribs.DeleteWithTag(cBracketHiliteTag);

  cx := fText.Carets[0].PosX;   // 0-based logical column
  cy := fText.Carets[0].PosY;   // 0-based line

  // Convert the caret position to an absolute char offset inside the editor text.
  // ATSynEdit stores text with LF line endings and CaretPosToOffset counts each
  // line break as 1 char, which matches fText.Text (LF-only UnicodeString).
  offs := fText.CaretPosToOffset(Point(cx, cy));
  if offs < 0 then Exit;

  TextUni := fText.Text;        // UnicodeString, LF line endings
  if Length(TextUni) = 0 then Exit;

  // Char immediately to the left of the caret (P[offs-1])
  if offs > 0 then
    leftCh := TextUni[offs]      // 1-based index offs == 0-based char offs-1
  else
    leftCh := #0;
  // Char immediately to the right of the caret (P[offs])
  if offs + 1 <= Length(TextUni) then
    rightCh := TextUni[offs + 1] // 1-based index offs+1 == 0-based char offs
  else
    rightCh := #0;

  // Dev-C++ behaviour: highlight the bracket adjacent to the caret. Trigger on all
  // four adjacent positions: right of an opener, left of a closer, left of an
  // opener, and right of a closer. Angle brackets '<' '>' are also handled
  // (e.g. #include <stdio.h>), but only when their interior is a continuous
  // identifier/path run (see interior check below).
  if (leftCh = '(') or (leftCh = '[') or (leftCh = '{') or (leftCh = '<') or
     (leftCh = '"') or (leftCh = '''') then
    startOffs := offs - 1        // bracket/quote immediately to the LEFT of caret
  else if (rightCh = ')') or (rightCh = ']') or (rightCh = '}') or (rightCh = '>') or
          (rightCh = '"') or (rightCh = '''') then
    startOffs := offs           // closer immediately to the RIGHT of caret
  else if (rightCh = '(') or (rightCh = '[') or (rightCh = '{') or (rightCh = '<') or
          (rightCh = '"') or (rightCh = '''') then
    startOffs := offs           // opener immediately to the RIGHT of caret
  else if (leftCh = ')') or (leftCh = ']') or (leftCh = '}') or (leftCh = '>') or
          (leftCh = '"') or (leftCh = '''') then
    startOffs := offs - 1       // closer immediately to the LEFT of caret
  else
    Exit;

  startCh := TextUni[startOffs + 1];
  if (startCh = '"') or (startCh = '''') then
    found := FindQuoteMatch(TextUni, startOffs, matchOffs)
  else
    found := FindBracketMatch(startOffs, matchOffs);

  if found then
  begin
    // Angle brackets are only highlighted when their interior is a continuous
    // identifier/path run (no whitespace or operator chars), so "<stdio.h>"
    // highlights but relational "a < b" does not.
    if (startCh = '<') or (startCh = '>') then
      if not AngleBracketInteriorOk(TextUni, startOffs, matchOffs) then
        Exit;
    pStart := fText.OffsetToCaretPos(startOffs);
    pMatch := fText.OffsetToCaretPos(matchOffs);
    InitLinePart(Part);
    // Light-yellow background to mark the matching pair. Distinct from the
    // light-blue "selected text" highlight (cSelHighlightTag) used elsewhere.
    Part.ColorBG := $00C8FFFF;
    fText.Attribs.Add(Point(pStart.X, pStart.Y), Point(1, 0), TATMarkerTags.Init(cBracketHiliteTag, 0), @Part);
    fText.Attribs.Add(Point(pMatch.X, pMatch.Y), Point(1, 0), TATMarkerTags.Init(cBracketHiliteTag, 0), @Part);
    fText.Invalidate;
  end;
end;

function TEditor.FindBracketMatch(StartOffs: integer; out MatchOffs: integer): boolean;
var
  i: integer;
  ch: WideChar;
  s: UnicodeString;
  stack: array of record c: WideChar; offs: integer; end;
  inString, inBlockComment, inLineComment: Boolean;
  stringChar: WideChar;
  startDepth: integer;
  startProcessed: Boolean;
  startIsOpener: Boolean;
  skipNextAngle: Boolean;
  cPrev, cNext: WideChar;
begin
  Result := False;
  MatchOffs := -1;
  if not Assigned(fText) then Exit;
  s := fText.Text;              // UnicodeString, LF line endings (matches CaretPosToOffset)
  if Length(s) = 0 then Exit;
  if (StartOffs < 0) or (StartOffs >= Length(s)) then Exit;

  ch := s[StartOffs + 1];      // 1-based index into UnicodeString
  case ch of
    '(', '[', '{', '<': startIsOpener := True;
    ')', ']', '}', '>': startIsOpener := False;
  else
    Exit;
  end;

  inString := False;
  stringChar := #0;
  inBlockComment := False;
  inLineComment := False;
  startDepth := 0;
  startProcessed := False;
  skipNextAngle := False;
  SetLength(stack, 0);

  i := 0;
  while i < Length(s) do
  begin
    ch := s[i + 1];

    // Register the start bracket itself once (skip string/comment handling for it)
    if i = StartOffs then
    begin
      startProcessed := True;
      if startIsOpener then
      begin
        // A '<' that is part of a stream "<<" operator, or a relational "<"
        // comparison, is NOT a real delimiter. Do not register it as an opener
        // (otherwise a dangling '<' would block matching of later { } ( ) [ ]).
        if ch = '<' then
        begin
          cPrev := #0;
          if StartOffs > 0 then
            cPrev := s[StartOffs];          // char at 0-based offset (StartOffs-1)
          cNext := #0;
          if StartOffs + 1 < Length(s) then
            cNext := s[StartOffs + 2];      // char at 0-based offset (StartOffs+1)
          if (cPrev = '<') or (cNext = '<') or
             not (((cNext >= 'a') and (cNext <= 'z')) or
                  ((cNext >= 'A') and (cNext <= 'Z')) or (cNext = '_')) then
            Exit;                           // not a template/include delimiter -> no match
        end;
        startDepth := Length(stack);
        SetLength(stack, Length(stack) + 1);
        stack[High(stack)].c := ch;
        stack[High(stack)].offs := i;
      end
      else
      begin
        // Start is a closer: its match is the opener currently on top of the stack,
        // but only if it is the SAME bracket type. If the nearest unmatched opener
        // is a different type (e.g. ')' resting on top of '{'), the closer is
        // unbalanced and must not be highlighted.
        if Length(stack) > 0 then
        begin
          if ((ch = ')') and (stack[High(stack)].c = '(')) or
             ((ch = ']') and (stack[High(stack)].c = '[')) or
             ((ch = '}') and (stack[High(stack)].c = '{')) or
             ((ch = '>') and (stack[High(stack)].c = '<')) then
          begin
            MatchOffs := stack[High(stack)].offs;
            Result := True;
          end;
        end;
        Exit;
      end;
      Inc(i);
      Continue;
    end;

    // String / comment state machine
    if inBlockComment then
    begin
      if (ch = '*') and (i + 1 < Length(s)) and (s[i + 2] = '/') then
      begin
        inBlockComment := False;
        Inc(i); // skip the '/'
      end;
      Inc(i);
      Continue;
    end;
    if inLineComment then
    begin
      if ch = #10 then inLineComment := False;
      Inc(i);
      Continue;
    end;
    if inString then
    begin
      if (ch = '\') and (i + 1 < Length(s)) then
      begin
        Inc(i); // skip escaped char
      end
      else if ch = stringChar then
        inString := False;
      Inc(i);
      Continue;
    end;

    case ch of
      '/':
        begin
          if (i + 1 < Length(s)) and (s[i + 2] = '/') then
          begin
            inLineComment := True;
            Inc(i); // skip '/'
          end
          else if (i + 1 < Length(s)) and (s[i + 2] = '*') then
          begin
            inBlockComment := True;
            Inc(i); // skip '*'
          end;
        end;
      '"', '''':
        begin
          inString := True;
          stringChar := ch;
        end;
      '(', '[', '{', '<':
        begin
          if ch = '<' then
          begin
            // Stream insertion/extraction operator "<<" : skip this '<' and the
            // next one. Templates never contain adjacent "<<", so this is safe.
            if (i + 1 < Length(s)) and (s[i + 2] = '<') then
            begin
              skipNextAngle := True;
              Inc(i);
              Continue;
            end;
            // Second '<' of a "<<" we flagged in the previous iteration.
            if skipNextAngle then
            begin
              skipNextAngle := False;
              Inc(i);
              Continue;
            end;
            // A lone '<' is only a real template/include delimiter when it is
            // immediately followed by an identifier (e.g. vector<int>,
            // #include <x>). Relational "a < b" / "1 < 2" / "if (x < (y))" must
            // NOT be pushed, otherwise the dangling '<' blocks matching of later
            // { } ( ) [ ].
            if (i + 1 < Length(s)) then
            begin
              cNext := s[i + 2];
              if not (((cNext >= 'a') and (cNext <= 'z')) or
                      ((cNext >= 'A') and (cNext <= 'Z')) or (cNext = '_')) then
              begin
                Inc(i);
                Continue;
              end;
            end
            else
            begin
              Inc(i);
              Continue;
            end;
          end;
          SetLength(stack, Length(stack) + 1);
          stack[High(stack)].c := ch;
          stack[High(stack)].offs := i;
        end;
      ')', ']', '}', '>':
        begin
          if Length(stack) > 0 then
          begin
            if ((ch = ')') and (stack[High(stack)].c = '(')) or
               ((ch = ']') and (stack[High(stack)].c = '[')) or
               ((ch = '}') and (stack[High(stack)].c = '{')) or
               ((ch = '>') and (stack[High(stack)].c = '<')) then
            begin
              SetLength(stack, Length(stack) - 1);
              if startProcessed and (Length(stack) = startDepth) then
              begin
                MatchOffs := i;
                Result := True;
                Exit;
              end;
            end;
            // Mismatched closer (unbalanced) -> leave stack, no match
          end;
        end;
    end;

    Inc(i);
  end;
end;

function TEditor.AngleBracketInteriorOk(const s: UnicodeString; startOffs, matchOffs: integer): boolean;
var
  lo, hi, k: integer;
  c: WideChar;
begin
  Result := True;
  // Not an angle-bracket pair -> nothing to restrict (()[]{} always allowed)
  if not (((s[startOffs + 1] = '<') and (s[matchOffs + 1] = '>')) or
          ((s[startOffs + 1] = '>') and (s[matchOffs + 1] = '<'))) then
    Exit;
  lo := startOffs;
  hi := matchOffs;
  if lo > hi then
  begin
    lo := matchOffs;
    hi := startOffs;
  end;
  // Interior chars only (exclusive of the two brackets). Allow identifier chars plus
  // path separators so header names like "stdio.h" / "path/to/h" pass; whitespace or
  // operator chars (e.g. 'a < b') disqualify the highlight.
  for k := lo + 1 to hi - 1 do
  begin
    c := s[k + 1];
    if not (((c >= 'a') and (c <= 'z')) or ((c >= 'A') and (c <= 'Z')) or
            ((c >= '0') and (c <= '9')) or (c in ['_', '.', '/', '\'])) then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

function TEditor.FindQuoteMatch(const s: UnicodeString; StartOffs: integer; out MatchOffs: integer): boolean;
var
  i: integer;
  ch: WideChar;
  inString, inBlockComment, inLineComment: Boolean;
  stringChar: WideChar;
  openOffs: integer;
  startIsOpener: Boolean;
begin
  Result := False;
  MatchOffs := -1;
  if (StartOffs < 0) or (StartOffs >= Length(s)) then Exit;

  ch := s[StartOffs + 1];
  if not ((ch = '"') or (ch = '''')) then Exit;

  inString := False;
  stringChar := #0;
  inBlockComment := False;
  inLineComment := False;
  openOffs := -1;
  startIsOpener := False;

  i := 0;
  while i < Length(s) do
  begin
    ch := s[i + 1];

    // Block comment: skip until */
    if inBlockComment then
    begin
      if (ch = '*') and (i + 1 < Length(s)) and (s[i + 2] = '/') then
        inBlockComment := False
      else
      begin
        Inc(i);
        Continue;
      end;
    end;

    // Line comment: skip until end of line
    if inLineComment then
    begin
      if ch = #10 then
        inLineComment := False
      else
      begin
        Inc(i);
        Continue;
      end;
    end;

    // Start of a comment (only when not already inside a string)
    if not inString then
    begin
      if (ch = '/') and (i + 1 < Length(s)) then
      begin
        if s[i + 2] = '/' then
        begin
          inLineComment := True;
          Inc(i);
          Continue;
        end
        else if s[i + 2] = '*' then
        begin
          inBlockComment := True;
          Inc(i);
          Continue;
        end;
      end;
    end;

    // Quote delimiter handling
    if (ch = '"') or (ch = '''') then
    begin
      if not inString then
      begin
        // Opening delimiter
        inString := True;
        stringChar := ch;
        openOffs := i;
        if i = StartOffs then
          startIsOpener := True;
      end
      else if ch = stringChar then
      begin
        // Closing delimiter for the current string literal
        inString := False;
        if startIsOpener then
        begin
          // The start quote was the opener; its closer is here
          MatchOffs := i;
          Result := True;
          Exit;
        end;
        if i = StartOffs then
        begin
          // The start quote was the closer; its opener was recorded
          MatchOffs := openOffs;
          Result := openOffs >= 0;
          Exit;
        end;
        openOffs := -1;
      end;
      // else: a quote of the other kind inside a string/char literal -> ignore
      Inc(i);
      Continue;
    end;

    // Inside a string, a backslash escapes the next character (e.g. \" or \')
    if inString and (ch = '\') then
    begin
      Inc(i);   // skip the backslash
      Inc(i);   // skip the escaped character
      Continue;
    end;

    Inc(i);
  end;
  // Unterminated string (opener with no closer) -> Result stays False
end;

procedure TEditor.UpdateSelectionHighlight;
var
  SelText: string;
  LineText: string;
  i, p, lineLen: Integer;
  Part: TATLinePart;
begin
  if not Assigned(fText) then Exit;
  if fText.Carets.Count = 0 then Exit;

  // Check if there's a selection (use Carets[0] directly, NOT CaretsSel which is stale)
  if not fText.Carets[0].IsSelection then
  begin
    // No selection - clear highlights
    if fLastSelHighlightText <> '' then
    begin
      fText.Attribs.DeleteWithTag(cSelHighlightTag);
      fLastSelHighlightText := '';
      fText.Invalidate;
    end;
    Exit;
  end;

  // Get selected text
  SelText := AnsiString(fText.TextSelected);
  if SelText = '' then
  begin
    if fLastSelHighlightText <> '' then
    begin
      fText.Attribs.DeleteWithTag(cSelHighlightTag);
      fLastSelHighlightText := '';
      fText.Invalidate;
    end;
    Exit;
  end;

  // Skip if selected text spans multiple lines (contains newlines)
  if (Pos(#10, SelText) > 0) or (Pos(#13, SelText) > 0) then
  begin
    if fLastSelHighlightText <> '' then
    begin
      fText.Attribs.DeleteWithTag(cSelHighlightTag);
      fLastSelHighlightText := '';
      fText.Invalidate;
    end;
    Exit;
  end;

  // Skip if selection text hasn't changed
  if SelText = fLastSelHighlightText then
    Exit;

  // Clear old highlights
  fText.Attribs.DeleteWithTag(cSelHighlightTag);
  fLastSelHighlightText := SelText;

  // Scan all lines for occurrences
  InitLinePart(Part);
  Part.ColorFont := clNavy;       // Dark blue text
  Part.ColorBG := $E0ECFF;        // Light blue background
  Part.ColorBorder := $C0D0F0;    // Slightly darker border
  Part.FontStyles := 0;            // No extra font styles
  Part.BorderDown := TATLineStyle.Solid;

  for i := 0 to fText.Strings.Count - 1 do
  begin
    LineText := AnsiString(fText.Strings.Lines[i]);
    if LineText = '' then
      Continue;

    // Find all occurrences of SelText in this line
    p := 1;
    lineLen := Length(SelText);
    while True do
    begin
      p := Pos(SelText, LineText, p);
      if p = 0 then
        Break;

      fText.Attribs.Add(
        Point(p - 1, i),               // 0-based column, line
        Point(lineLen, 0),             // length, single line
        TATMarkerTags.Init(cSelHighlightTag, 0),
        @Part
      );

      Inc(p, lineLen);
    end;
  end;

  fText.Invalidate;
end;

procedure TEditor.EditorCaretChange(Sender: TObject);
var
  i: integer;
begin
  // Clear error line highlight when caret moves to a different line
  if fErrorLine <> -1 then begin
    if fText.Carets[0].PosY <> fErrorLine - 1 then begin
      for i := 0 to fText.Strings.Bookmarks2.Count - 1 do begin
        if fText.Strings.Bookmarks2[i]^.Data.LineNum = fErrorLine - 1 then begin
          if fErrorWasBreakpoint then
            fText.Strings.Bookmarks2[i]^.Data.Kind := BK_BREAKPOINT
          else
            fText.Strings.Bookmarks2.Delete(i);
          Break;
        end;
      end;
      fErrorLine := -1;
      fErrorWasBreakpoint := False;
      fText.Invalidate;
    end;
  end;
  UpdateCurrentLineMarker;

  // Update status bar (caret-only moves do not fire OnChange)
  MainForm.SetStatusbarLineCol;

  // Update function tip when caret moves (arrow keys, mouse click, etc.)
  // OnChange is NOT fired for caret-only moves, so we drive the tip here.
  if Assigned(fFunctionTip) and FunctionTipAllowed then
    fFunctionTip.Show;

  // Highlight all occurrences of selected text
  UpdateSelectionHighlight;

  // Bold the matching bracket pair near the caret
  HighlightBrackets;
end;

procedure TEditor.EditorBookmarksChange(Sender: TObject);
var
  i, j: integer;
  found: Boolean;
begin
  // Skip during RestoreBreakpointBackgrounds (clears then re-adds BK_BREAKPOINT)
  if fRestoringBreakpoints then Exit;
  // When a BK_BREAKPOINT entry is removed from Bookmarks2 by AutoDelete=Delete,
  // also remove the corresponding breakpoint from Debugger.BreakPointList.
  // This prevents formatting from resurrecting breakpoints whose lines were deleted.
  if not Assigned(fText) then Exit;
  if not Assigned(MainForm.Debugger) or not Assigned(MainForm.Debugger.BreakPointList) then Exit;

  for i := MainForm.Debugger.BreakPointList.Count - 1 downto 0 do begin
    if PtrInt(PBreakPoint(MainForm.Debugger.BreakPointList.Items[$1])^.editor) = PtrInt(Self) then begin
      found := False;
      for j := 0 to fText.Strings.Bookmarks2.Count - 1 do begin
        if (fText.Strings.Bookmarks2[j]^.Data.Kind = BK_BREAKPOINT) and
          (fText.Strings.Bookmarks2[j]^.Data.LineNum = PBreakPoint(MainForm.Debugger.BreakPointList.Items[i])^.line - 1) then begin
          found := True;
          Break;
        end;
      end;
      if not found then begin
        Dispose(PBreakPoint(MainForm.Debugger.BreakPointList.Items[i]));
        MainForm.Debugger.BreakPointList.Delete(i);
      end;
    end;
  end;
end;

procedure TEditor.UpdateCurrentLineMarker;
var
  curLine: integer;
  i: integer;
  hasSpecial: Boolean;
  bm: TATBookmarkData;
begin
  if not Assigned(fText) then Exit;

  // Remove old current line marker
  fText.Strings.Bookmarks2.DeleteByTag(cCurrentLineTag);

  // Check if current line highlighting is enabled
  if not devEditor.HighCurrLine then Exit;

  curLine := fText.Carets[0].PosY; // 0-based

  // Check if the current line already has a special marker
  // (breakpoint, active breakpoint, error, user bookmark BG)
  hasSpecial := False;
  for i := 0 to fText.Strings.Bookmarks2.Count - 1 do begin
    if (fText.Strings.Bookmarks2[i]^.Data.LineNum = curLine) and
      (fText.Strings.Bookmarks2[i]^.Data.Kind <> BK_CURRENTLINE) then begin
      hasSpecial := True;
      Break;
    end;
  end;

  // Also check if this line is the active breakpoint line (via fActiveLine)
  if not hasSpecial and (fActiveLine <> -1) and (curLine = fActiveLine - 1) then
    hasSpecial := True;

  if hasSpecial then
    Exit;

  // Add current line marker
  bm := Default(TATBookmarkData);
  bm.Tag := cCurrentLineTag;
  bm.LineNum := curLine;
  bm.Kind := BK_CURRENTLINE;
  fText.Strings.Bookmarks2.Add(bm, False);
end;

procedure TEditor.EditorStatusChange(Sender: TObject);
var
  i: integer;
begin
  // Mark invalid identifiers (CJK chars in identifier positions)
  MarkInvalidIdentifiers;

  fModified := fText.Modified;
  // Check modified state
  if fText.Modified then
  //if fModified then
    UpdateCaption('[*] ' + ExtractFileName(AnsiString(fFileName)))
  else
    UpdateCaption(ExtractFileName(AnsiString(fFileName)));

  // Remove BreakPointList entries at lines past end of file.
  // (Bookmarks2 BK_BREAKPOINT entries are auto-removed by AutoDelete=Delete,
  // but BreakPointList must be synced separately.)
  if fText.Strings.Count <> fLastLineCount then begin
    fLastLineCount := fText.Strings.Count;
    if Assigned(MainForm.Debugger) and Assigned(MainForm.Debugger.BreakPointList) then begin
      for i := MainForm.Debugger.BreakPointList.Count - 1 downto 0 do begin
        if (PtrInt(PBreakPoint(MainForm.Debugger.BreakPointList.Items[$1])^.editor) = PtrInt(Self)) and
          (PBreakPoint(MainForm.Debugger.BreakPointList.Items[i])^.line >= fText.Strings.Count) then begin
          Dispose(PBreakPoint(MainForm.Debugger.BreakPointList.Items[i]));
          MainForm.Debugger.BreakPointList.Delete(i);
        end;
      end;
    end;
  end;


  // Update status bar
  MainForm.SetStatusbarLineCol;

  // Finish symbol completion
  if fParenthCompleteState = scsInserted then
    fParenthCompleteState := scsFinished;
  if fArrayCompleteState = scsInserted then
    fArrayCompleteState := scsFinished;
  if fBraceCompleteState = scsInserted then
    fBraceCompleteState := scsFinished;

  // Update the function tip
  if Assigned(fFunctionTip) then begin
    fFunctionTip.ForceHide := false;
  if Assigned(fFunctionTipTimer) then begin
      if fFunctionTip.Activated and FunctionTipAllowed then
      fFunctionTip.Show
    else begin // Reset the timer
      fFunctionTipTimer.Enabled := false;
      fFunctionTipTimer.Enabled := true;
    end;
  end;
  end;

  // Remove error line colors
  if not fIgnoreCaretChange then begin
  if (fErrorLine <> -1) then begin
    // Restore BK_BREAKPOINT or delete BK_ERROR entry
    for i := 0 to fText.Strings.Bookmarks2.Count - 1 do begin
      if fText.Strings.Bookmarks2[i]^.Data.LineNum = fErrorLine - 1 then begin
        if fErrorWasBreakpoint then
          fText.Strings.Bookmarks2[i]^.Data.Kind := BK_BREAKPOINT
        else
          fText.Strings.Bookmarks2.Delete(i);
        Break;
      end;
    end;
    fErrorLine := -1;
    fErrorWasBreakpoint := False;
    UpdateCurrentLineMarker; // Refresh current line marker after error cleared
    fText.Invalidate; // redraw all to remove old error highlight
  end;
  end else
    fIgnoreCaretChange := false;

  // Update insert/overwrite mode
  if fText.ModeReadOnly then
    MainForm.Statusbar.Panels[4].Text := Lang[ID_READONLY]
  else if not fText.ModeOverwrite then
    MainForm.Statusbar.Panels[4].Text := Lang[ID_INSERT]
  else
    MainForm.Statusbar.Panels[4].Text := Lang[ID_OVERWRITE];

end;

function TEditor.FunctionTipAllowed: boolean;
begin
  Result :=
    Assigned(fFunctionTip) and
    // ATSynEdit: IsScrolling not available, removed
    fText.Focused and // don't update other editors
    fText.CaretsSel.IsEmpty and // don't update when a selection is available
    devCodeCompletion.ShowFunctionHints and
    //devEditor.ShowFunctionTip and // only update when option is enabled
    Assigned(fText.AdapterForHilite) and // don't update in plaintext files
    not fFunctionTip.ForceHide; // don't update when user force hides it using ESC
end;

procedure TEditor.FunctionTipTimer(Sender: TObject);
begin
  // Stop the one-shot timer
  fFunctionTipTimer.Enabled := False;
  // The timer itself is the "user stopped typing" signal.
  // Reset Activated so FunctionTipAllowed's first condition passes.
  fFunctionTip.Activated := False;
  if FunctionTipAllowed then
    fFunctionTip.Show;
end;

procedure TEditor.ExportToHTML;

  function ColorToHTML(AColor: TColor): string;
  var
    R, G, B: Byte;
  begin
    R := GetRValue(AColor);
    G := GetGValue(AColor);
    B := GetBValue(AColor);
    Result := '#' + IntToHex(R, 2) + IntToHex(G, 2) + IntToHex(B, 2);
  end;

  function HtmlEscape(const s: string): string;
  begin
    Result := StringReplace(s, '&', '&amp;', [rfReplaceAll]);
    Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
    Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
  end;

var
  sl: TStringList;
  HtmlLine: String;
  LineIndex, PartIndex, CharIndex: integer;
  Parts: TATLineParts;
  ColorAfter: TColor;
  PartCount: integer;
begin
  with TSaveDialog.Create(nil) do try
    Title := 'Export to HTML';
    DefaultExt := '.html';
    Filter := 'HTML files (*.html)|*.html|All files (*.*)|*.*';
    FileName := ChangeFileExt(ExtractFileName(AnsiString(fFileName)), '.html');
    if not Execute then
      Exit;
    sl := TStringList.Create;
    Parts := default(TATLineParts);
    try
      // HTML header
      sl.Add('<!DOCTYPE html>');
      sl.Add('<html><head><meta charset="UTF-8"><title>' + HtmlEscape(ExtractFileName(AnsiString(fFileName))) + '</title></head>');
      sl.Add('<body style="background-color:#FFFFFF; font-family:Consolas,monospace; font-size:14px;">');
      sl.Add('<pre>');

      // Process each line
      // Note: Parts[].Offset/Len are WideChar offsets (not byte offsets),
      // so we must use LineSub (which operates on WideChar positions) instead of
      // Copy(LineText, ...) which would break UTF-8 multi-byte characters.
      for LineIndex := 0 to fText.Strings.Count - 1 do begin
        // Get colored parts for this line
        fText.DoCalcLineHiliteEx(LineIndex, Parts, clNone, ColorAfter, False);
        PartCount := DoPartsGetCount(Parts);

        HtmlLine := '';
        if PartCount > 0 then begin
          CharIndex := 1;
          for PartIndex := 0 to PartCount - 1 do begin
            // Output uncolored text before this part
            if Parts[PartIndex].Offset + 1 > CharIndex then begin
              HtmlLine := HtmlLine + HtmlEscape(
                AnsiString(fText.Strings.LineSub(LineIndex, CharIndex,
                Parts[PartIndex].Offset + 1 - CharIndex)));
              CharIndex := Parts[PartIndex].Offset + 1;
            end;

            // Get colored text for this part
            HtmlLine := HtmlLine + '<span style="color:' +
              ColorToHTML(Parts[PartIndex].ColorFont);
            if (Parts[PartIndex].FontStyles and (1 shl Ord(fsBold))) <> 0 then
              HtmlLine := HtmlLine + ';font-weight:bold';
            if (Parts[PartIndex].FontStyles and (1 shl Ord(fsItalic))) <> 0 then
              HtmlLine := HtmlLine + ';font-style:italic';
            if (Parts[PartIndex].FontStyles and (1 shl Ord(fsUnderline))) <> 0 then
              HtmlLine := HtmlLine + ';text-decoration:underline';
            HtmlLine := HtmlLine + '">' +
              HtmlEscape(AnsiString(fText.Strings.LineSub(LineIndex, CharIndex, Parts[PartIndex].Len))) +
              '</span>';

            CharIndex := CharIndex + Parts[PartIndex].Len;
          end;

          // Remaining uncolored text after last part
          HtmlLine := HtmlLine + HtmlEscape(
            AnsiString(fText.Strings.LineSub(LineIndex, CharIndex, MaxInt)));
        end else begin
          // No colored parts
          HtmlLine := HtmlEscape(AnsiString(fText.Strings.LineSub(LineIndex, 1, MaxInt)));
        end;

        sl.Add(HtmlLine);
      end;

      // HTML footer
      sl.Add('</pre>');
      sl.Add('</body></html>');

      sl.SaveToFile(FileName);

      // Show success dialog with option to open file
      if QuestionDlg(Lang[ID_NV_EXPORT],
        Lang[ID_EXPORTHTML_MSG] + sLineBreak + FileName,
        mtInformation,
        [mrYes, Lang[ID_BTN_OPEN], mrNo, Lang[ID_BTN_CLOSE]], '') = mrYes then
        OpenDocument(FileName);
    finally
      sl.Free;
    end;
  finally
    Free;
  end;
end;

procedure TEditor.ExportToRTF;

  function RtfEscape(const s: string): string;
  var
    U: WideString;
    i: Integer;
    c: WideChar;
  begin
    Result := '';
    U := UTF8ToUTF16(s);   // convert UTF-8 to UTF-16 for safe char iteration
    for i := 1 to Length(U) do begin
      c := U[i];
      case Word(c) of
        92: Result := Result + '\\';   // backslash
        123: Result := Result + '\{';    // {
        125: Result := Result + '\}';    // }
      else
        if (Word(c) < 128) then
          Result := Result + AnsiString(c)
        else
          Result := Result + '\u' + IntToStr(Integer(c)) + '?';  // Unicode escape with '?' fallback
      end;
    end;
  end;

var
  sl: TStringList;
  RtfLine: String;
  LineIndex, PartIndex, CharIndex, PartCount: integer;
  Parts: TATLineParts;
  ColorAfter: TColor;
  ColorIdx: integer;
  AllColors: array of TColor;
  i: integer;
  Found: boolean;
  R, G, B: Byte;
begin
  with TSaveDialog.Create(nil) do try
    Title := 'Export to RTF';
    DefaultExt := '.rtf';
    Filter := 'RTF files (*.rtf)|*.rtf|All files (*.*)|*.*';
    FileName := ChangeFileExt(ExtractFileName(AnsiString(fFileName)), '.rtf');
    if not Execute then
      Exit;

    // First pass: collect unique colors
    SetLength(AllColors, 0);
    Parts := default(TATLineParts);
    for LineIndex := 0 to fText.Strings.Count - 1 do begin
      fText.DoCalcLineHiliteEx(LineIndex, Parts, clNone, ColorAfter, False);
      PartCount := DoPartsGetCount(Parts);
      for PartIndex := 0 to PartCount - 1 do begin
        Found := False;
        for i := 0 to Length(AllColors) - 1 do
          if AllColors[i] = Parts[PartIndex].ColorFont then begin
            Found := True;
            Break;
          end;
        if not Found then begin
          SetLength(AllColors, Length(AllColors) + 1);
          AllColors[High(AllColors)] := Parts[PartIndex].ColorFont;
        end;
      end;
    end;

    sl := TStringList.Create;
    try
      // RTF header (Unicode mode: \ansicpg65001 = UTF-8 codepage, \fcharset0 = ANSI charset)
      sl.Add('{\rtf1\ansi\ansicpg65001\deff0');
      // Font table (Consolas with UTF-8 charset)
      sl.Add('{\fonttbl{\f0\fmodern\fcharset0 Consolas;}}');
      // Color table
      sl.Add('{\colortbl;');
      for i := 0 to Length(AllColors) - 1 do begin
        R := GetRValue(AllColors[i]);
        G := GetGValue(AllColors[i]);
        B := GetBValue(AllColors[i]);
        sl.Add('\red' + IntToStr(R) + '\green' + IntToStr(G) + '\blue' + IntToStr(B) + ';');
      end;
      sl.Add('}');
      sl.Add('\f0\fs21'); // Font Consolas, 10.5pt
      sl.Add('\viewkind4\uc1\pard\sl0\slmult1');

      // Process each line
      // Note: Parts[].Offset/Len are WideChar offsets, use LineSub not Copy.
      for LineIndex := 0 to fText.Strings.Count - 1 do begin
        fText.DoCalcLineHiliteEx(LineIndex, Parts, clNone, ColorAfter, False);
        PartCount := DoPartsGetCount(Parts);

        RtfLine := '';
        if PartCount > 0 then begin
          CharIndex := 1;
          for PartIndex := 0 to PartCount - 1 do begin
            // Plain text before this part
            if Parts[PartIndex].Offset + 1 > CharIndex then begin
              RtfLine := RtfLine + RtfEscape(
                AnsiString(fText.Strings.LineSub(LineIndex, CharIndex,
                Parts[PartIndex].Offset + 1 - CharIndex)));
              CharIndex := Parts[PartIndex].Offset + 1;
            end;

            // Color
            ColorIdx := -1;
            for i := 0 to Length(AllColors) - 1 do
              if AllColors[i] = Parts[PartIndex].ColorFont then begin
                ColorIdx := i + 1; // RTF color table is 1-based
                Break;
              end;

            RtfLine := RtfLine + '{\cf' + IntToStr(ColorIdx);
            if (Parts[PartIndex].FontStyles and (1 shl Ord(fsBold))) <> 0 then
              RtfLine := RtfLine + '\b';
            if (Parts[PartIndex].FontStyles and (1 shl Ord(fsItalic))) <> 0 then
              RtfLine := RtfLine + '\i';
            if (Parts[PartIndex].FontStyles and (1 shl Ord(fsUnderline))) <> 0 then
              RtfLine := RtfLine + '\ul';
            RtfLine := RtfLine + ' ' +
              RtfEscape(AnsiString(fText.Strings.LineSub(LineIndex, CharIndex, Parts[PartIndex].Len))) + '}';

            CharIndex := CharIndex + Parts[PartIndex].Len;
          end;

          // Remaining plain text
          RtfLine := RtfLine + RtfEscape(
            AnsiString(fText.Strings.LineSub(LineIndex, CharIndex, MaxInt)));
        end else
          RtfLine := RtfEscape(AnsiString(fText.Strings.LineSub(LineIndex, 1, MaxInt)));

        sl.Add(RtfLine + '\par');
      end;

      sl.Add('}');
      sl.SaveToFile(FileName, TEncoding.UTF8);

      if QuestionDlg(Lang[ID_NV_EXPORT],
        Lang[ID_EXPORTRTF_MSG] + sLineBreak + FileName,
        mtInformation,
        [mrYes, Lang[ID_BTN_OPEN], mrNo, Lang[ID_BTN_CLOSE]], '') = mrYes then
        OpenDocument(FileName);
    finally
      sl.Free;
    end;
  finally
    Free;
  end;
end;

procedure TEditor.ExportToTEX;

  function TexEscape(const s: string): string;
  begin
    Result := StringReplace(s, '\', '\textbackslash{}', [rfReplaceAll]);
    Result := StringReplace(Result, '{', '\{', [rfReplaceAll]);
    Result := StringReplace(Result, '}', '\}', [rfReplaceAll]);
    Result := StringReplace(Result, '$', '\$', [rfReplaceAll]);
    Result := StringReplace(Result, '%', '\%', [rfReplaceAll]);
    Result := StringReplace(Result, '&', '\&', [rfReplaceAll]);
    Result := StringReplace(Result, '#', '\#', [rfReplaceAll]);
    Result := StringReplace(Result, '_', '\_', [rfReplaceAll]);
    Result := StringReplace(Result, '~', '\textasciitilde{}', [rfReplaceAll]);
    Result := StringReplace(Result, '^', '\textasciicircum{}', [rfReplaceAll]);
  end;

var
  sl: TStringList;
  TexLine: String;
  LineIndex, PartIndex, CharIndex, PartCount: integer;
  Parts: TATLineParts;
  ColorAfter: TColor;
  R, G, B: Byte;
begin
  with TSaveDialog.Create(nil) do try
    Title := 'Export to LaTeX';
    DefaultExt := '.tex';
    Filter := 'LaTeX files (*.tex)|*.tex|All files (*.*)|*.*';
    FileName := ChangeFileExt(ExtractFileName(AnsiString(fFileName)), '.tex');
    if not Execute then
      Exit;

    sl := TStringList.Create;
    Parts := default(TATLineParts);
    try
      // LaTeX header
      sl.Add('\documentclass{article}');
      sl.Add('\usepackage[utf8]{inputenc}');
      sl.Add('\usepackage{color}');
      sl.Add('\usepackage{geometry}');
      sl.Add('\geometry{margin=1in}');
      sl.Add('\begin{document}');
      sl.Add('\begin{ttfamily}');
      sl.Add('\noindent');

      // Process each line
      for LineIndex := 0 to fText.Strings.Count - 1 do begin
        fText.DoCalcLineHiliteEx(LineIndex, Parts, clNone, ColorAfter, False);
        PartCount := DoPartsGetCount(Parts);

        TexLine := '';
        if PartCount > 0 then begin
          CharIndex := 1;
          for PartIndex := 0 to PartCount - 1 do begin
            // Plain text before this part
            if Parts[PartIndex].Offset + 1 > CharIndex then begin
              TexLine := TexLine + TexEscape(
                AnsiString(fText.Strings.LineSub(LineIndex, CharIndex,
                Parts[PartIndex].Offset + 1 - CharIndex)));
              CharIndex := Parts[PartIndex].Offset + 1;
            end;

            R := GetRValue(Parts[PartIndex].ColorFont);
            G := GetGValue(Parts[PartIndex].ColorFont);
            B := GetBValue(Parts[PartIndex].ColorFont);

            TexLine := TexLine + '{\color[RGB]{' +
              IntToStr(R) + ',' + IntToStr(G) + ',' + IntToStr(B) + '}';
            if (Parts[PartIndex].FontStyles and (1 shl Ord(fsBold))) <> 0 then
              TexLine := TexLine + '\textbf{';
            if (Parts[PartIndex].FontStyles and (1 shl Ord(fsItalic))) <> 0 then
              TexLine := TexLine + '\textit{';
            if (Parts[PartIndex].FontStyles and (1 shl Ord(fsUnderline))) <> 0 then
              TexLine := TexLine + '\underline{';
            TexLine := TexLine + TexEscape(
              AnsiString(fText.Strings.LineSub(LineIndex, CharIndex, Parts[PartIndex].Len)));
            // Close style braces (reverse order)
            if (Parts[PartIndex].FontStyles and (1 shl Ord(fsUnderline))) <> 0 then
              TexLine := TexLine + '}';
            if (Parts[PartIndex].FontStyles and (1 shl Ord(fsItalic))) <> 0 then
              TexLine := TexLine + '}';
            if (Parts[PartIndex].FontStyles and (1 shl Ord(fsBold))) <> 0 then
              TexLine := TexLine + '}';
            TexLine := TexLine + '}'; // close color

            CharIndex := CharIndex + Parts[PartIndex].Len;
          end;

          // Remaining plain text
          TexLine := TexLine + TexEscape(
            AnsiString(fText.Strings.LineSub(LineIndex, CharIndex, MaxInt)));
        end else
          TexLine := TexEscape(AnsiString(fText.Strings.LineSub(LineIndex, 1, MaxInt)));

        sl.Add(TexLine + '\\');
      end;

      // LaTeX footer
      sl.Add('\end{ttfamily}');
      sl.Add('\end{document}');
      sl.SaveToFile(FileName, TEncoding.UTF8);

      if QuestionDlg(Lang[ID_NV_EXPORT],
        Lang[ID_EXPORTTEX_MSG] + sLineBreak + FileName,
        mtInformation,
        [mrYes, Lang[ID_BTN_OPEN], mrNo, Lang[ID_BTN_CLOSE]], '') = mrYes then
        OpenDocument(FileName);
    finally
      sl.Free;
    end;
  finally
    Free;
  end;
end;

procedure TEditor.GotoLine;
begin
  with TGotoLineForm.Create(nil) do try
    if ShowModal = mrOK then
      SetCaretPosAndActivate(Line.Value, 1);
  finally
    Free;
  end;
end;

// Convert a "display column" (1-based, where Tab expands to tab-stop positions)
// to a "logical column" (1-based, where each character including Tab counts as 1).
// GCC reports column numbers in display-column format; ATSynEdit uses logical columns.
function DisplayColToLogicalCol(const LineText: String; DisplayCol: Integer;
  TabSize: Integer): Integer;
var
  DispCol, LogCol, TabStop: Integer;
  Ch: Char;
begin
  // Both DispCol and LogCol start at 1 (1-based)
  DispCol := 1;
  LogCol  := 1;
  for Ch in LineText do begin
    if DispCol >= DisplayCol then
      Break;
    if Ch = #9 then begin // Tab character
      TabStop := ((DispCol - 1) div TabSize + 1) * TabSize + 1;
      DispCol := TabStop;
    end else
      Inc(DispCol);
    Inc(LogCol);
  end;
  // If DisplayCol is beyond the end of visible characters, place at end of line
  Result := LogCol;
end;

procedure TEditor.SetErrorFocus(Col, Line: integer);
var
  bm: TATBookmarkData;
  i, LogicalCol: integer;
  LineText: String;
begin
  // Convert GCC's display column to ATSynEdit's logical column
  // GCC treats Tab as expanding to tab-stop positions; ATSynEdit treats Tab as 1 char
  if (Line >= 1) and (Line <= fText.Strings.Count) then begin
    LineText := AnsiString(fText.Strings.Lines[Line - 1]); // 0-based index
    LogicalCol := DisplayColToLogicalCol(LineText, Col, 8);
  end else
    LogicalCol := Col;

  fIgnoreCaretChange := true;

  // Clear any existing selection before jumping to error position
  fText.DoCommand(cCommand_SelectNone, TATCommandInvoke(0), '');

  // Restore previous error line: if it was a promoted BK_BREAKPOINT, restore it
  if (fErrorLine <> -1) then begin
    for i := 0 to fText.Strings.Bookmarks2.Count - 1 do begin
      if (fText.Strings.Bookmarks2[i]^.Data.LineNum = fErrorLine - 1) then begin
        if fErrorWasBreakpoint then
          fText.Strings.Bookmarks2[i]^.Data.Kind := BK_BREAKPOINT
        else
          fText.Strings.Bookmarks2.Delete(i);
        Break;
      end;
    end;
  end;

  // Remove current line marker so error background takes priority
  fText.Strings.Bookmarks2.DeleteByTag(cCurrentLineTag);

  fErrorLine := Line;

  // Try to promote existing BK_BREAKPOINT to BK_ERROR (avoids overwrite via Add)
  fErrorWasBreakpoint := False;
  for i := 0 to fText.Strings.Bookmarks2.Count - 1 do begin
    if (fText.Strings.Bookmarks2[i]^.Data.LineNum = fErrorLine - 1) and
      (fText.Strings.Bookmarks2[i]^.Data.Kind = BK_BREAKPOINT) then begin
      fText.Strings.Bookmarks2[i]^.Data.Kind := BK_ERROR;
      fErrorWasBreakpoint := True;
      // No need to add a new entry
      SetCaretPosAndActivate(fErrorLine, LogicalCol);
      fText.Invalidate;
      Exit;
    end;
  end;

  // No BK_BREAKPOINT at error line, add fresh BK_ERROR
  bm := Default(TATBookmarkData);
  bm.LineNum := fErrorLine - 1; // 0-based
  bm.Kind := BK_ERROR;
  fText.Strings.Bookmarks2.Add(bm, False);

  // Set new error focus (SetCaretPosAndActivate expects 1-based)
  SetCaretPosAndActivate(fErrorLine, LogicalCol);

  // Redraw all to show new error highlight
  fText.Invalidate;
end;

procedure TEditor.GotoActiveBreakpoint;
begin
  if fActiveLine <> -1 then
    SetCaretPosAndActivate(fActiveLine, 1);
end;

procedure TEditor.SetActiveBreakpointFocus(Line: integer);
var
  bm: TATBookmarkData;
  i, oldLine: integer;
begin
  if Line <> fActiveLine then begin

    // Handle old active line: restore BK_BREAKPOINT or delete entry
    if fActiveLine <> -1 then begin
      oldLine := fActiveLine - 1; // 0-based
      for i := 0 to fText.Strings.Bookmarks2.Count - 1 do begin
        if fText.Strings.Bookmarks2[i]^.Data.LineNum = oldLine then begin
          if HasBreakPoint(fActiveLine) <> -1 then
            fText.Strings.Bookmarks2[i]^.Data.Kind := BK_BREAKPOINT
          else
            fText.Strings.Bookmarks2.Delete(i);
          Break;
        end;
      end;
    end;

    // Remove old current line marker before moving caret
    fText.Strings.Bookmarks2.DeleteByTag(cCurrentLineTag);

    fActiveLine := Line;

    // Try to promote existing BK_BREAKPOINT to BK_ACTIVEBREAKPOINT
    // (avoids two entries at the same line)
    for i := 0 to fText.Strings.Bookmarks2.Count - 1 do begin
      if (fText.Strings.Bookmarks2[i]^.Data.LineNum = fActiveLine - 1) and
        (fText.Strings.Bookmarks2[i]^.Data.Kind = BK_BREAKPOINT) then begin
        fText.Strings.Bookmarks2[i]^.Data.Kind := BK_ACTIVEBREAKPOINT;
        // Move caret and redraw, no need to add a new entry
        SetCaretPosAndActivate(fActiveLine, 1);
        UpdateCurrentLineMarker; // Ensure correct current line state
        fText.Invalidate;
        Exit;
      end;
    end;

    // No BK_BREAKPOINT at new line, add fresh BK_ACTIVEBREAKPOINT
    bm := Default(TATBookmarkData);
    bm.LineNum := fActiveLine - 1; // 0-based
    bm.Kind := BK_ACTIVEBREAKPOINT;
    fText.Strings.Bookmarks2.Add(bm, False);

    // Move caret to the active breakpoint (fires OnChangeCaretPos)
    SetCaretPosAndActivate(fActiveLine, 1);

    // Redraw all to show new active line
    UpdateCurrentLineMarker; // Ensure correct current line state
    fText.Invalidate;
  end;
end;

procedure TEditor.RemoveBreakpointFocus;
var
  i: integer;
begin
  if fActiveLine <> -1 then begin
    // Find the entry at the old active line
    for i := 0 to fText.Strings.Bookmarks2.Count - 1 do begin
      if fText.Strings.Bookmarks2[i]^.Data.LineNum = fActiveLine - 1 then begin
        // Restore BK_BREAKPOINT if the line has a real breakpoint, otherwise delete
        if HasBreakPoint(fActiveLine) <> -1 then
          fText.Strings.Bookmarks2[i]^.Data.Kind := BK_BREAKPOINT
        else
          fText.Strings.Bookmarks2.Delete(i);
        Break;
      end;
    end;
    fActiveLine := -1;
    fText.Invalidate;
  end;
end;

procedure TEditor.RestoreBreakpointBackgrounds;
var
  bm: TATBookmarkData;
  decor: TATGutterDecorData;
  i, line: integer;
begin
  if not Assigned(fText) then Exit;

  // Suppress OnChangeBookmarks handler during clear+rebuild
  fRestoringBreakpoints := True;
  try

  // First, remove all stale BK_BREAKPOINT entries left behind by ATSynEdit
  // after paste/delete operations (AutoDelete=DontDelete entries survive line changes).
  // Also remove all gutter decor for this editor (will be re-added below).
  for i := fText.Strings.Bookmarks2.Count - 1 downto 0 do begin
    if fText.Strings.Bookmarks2[i]^.Data.Kind = BK_BREAKPOINT then
      fText.Strings.Bookmarks2.Delete(i);
  end;
  fText.GutterDecor.Clear;

  // Re-add BK_BREAKPOINT and gutter decor from the debugger's current breakpoint list
  // Also remove breakpoints whose line numbers are now past the end of file
  for i := MainForm.Debugger.BreakPointList.Count - 1 downto 0 do begin
    if PtrInt(PBreakPoint(MainForm.Debugger.BreakPointList.Items[$1])^.editor) = PtrInt(Self) then begin
      line := PBreakPoint(MainForm.Debugger.BreakPointList.Items[i])^.line; // 1-based
      if (line < 1) or (line - 1 >= fText.Strings.Count) then begin
        // Breakpoint line no longer exists - remove from debugger's list
        Dispose(PBreakPoint(MainForm.Debugger.BreakPointList.Items[i]));
        MainForm.Debugger.BreakPointList.Delete(i);
        Continue;
      end;

      // Restore background color via Bookmarks2
      bm := Default(TATBookmarkData);
      bm.LineNum := line - 1; // 0-based
      bm.Kind := BK_BREAKPOINT;
      bm.AutoDelete := TATBookmarkAutoDelete.Delete;
      fText.Strings.Bookmarks2.Add(bm, False);

      // Restore gutter icon (red circle)
      decor := Default(TATGutterDecorData);
      decor.DeleteOnDelLine := True;
      decor.LineNum := line - 1; // 0-based
      decor.ImageIndex := 0; // red circle
      fText.GutterDecor.Add(decor);
    end;
  end;
  finally
    fRestoringBreakpoints := False;
  end;
end;

procedure TEditor.UpdateCaption(const NewCaption: String);
var
  FullCaption: String;
begin
  if Assigned(fTabSheet) then begin
    FullCaption := NewCaption;
    if fText.ModeReadOnly then
      FullCaption := FullCaption + '[' + Lang[ID_READONLY] +']';
    if FullCaption <> fTabSheet.Caption then
      fTabSheet.Caption := FullCaption;
  end;
end;

procedure TEditor.SetFileName(const value: UnicodeString);
begin
  if value <> fFileName then begin
    fFileName := value;
    UpdateCaption(ExtractFileName(AnsiString(fFileName)));
  end;
end;


procedure TEditor.InsertString(Value: String; MoveCursor: boolean);
var
  NewCursorPos: TPoint; // ATSynEdit: TPoint instead of TBufferCoord
  Char, Line, I: integer;
  P: PChar;
  HadMarker: Boolean;
begin
  // prevent lots of repaints
  Value := StringReplace(Value, '$PROGRAM$', Lang[ID_ITEM_PROGRAM], [rfReplaceAll]);
  Value := StringReplace(Value, '$COPYRIGHT$', Lang[ID_ITEM_COPYRIGHT], [rfReplaceAll]);
  Value := StringReplace(Value, '$AUTHOR$', Lang[ID_ITEM_AUTHOR], [rfReplaceAll]);
  Value := StringReplace(Value, '$DATETIME$', Lang[ID_ITEM_DATEANDTIME], [rfReplaceAll]);
  Value := StringReplace(Value, '$DESCRIPTION$', Lang[ID_ITEM_DESCRIPTION], [rfReplaceAll]);
  Value := StringReplace(Value, '<DATETIME>', FormatDateTime(Lang[ID_ITEM_DATETIMEFORMAT], Now), [rfReplaceAll]);

  fText.BeginUpdate;
  try
    NewCursorPos.X := fText.Carets[0].PosX;
    NewCursorPos.Y := fText.Carets[0].PosY;
    HadMarker := False;
    if MoveCursor then begin
      P := PChar(value);
      // Convert 0-based caret position to 1-based for scan tracking
      Char := fText.Carets[0].PosX + 1;
      Line := fText.Carets[0].PosY + 1;
      I := 0;
      while P[I] <> #0 do begin

        // Assume DOS newlines
        if (P[I] = #13) and (P[I + 1] = #10) then begin
          Inc(I, 2);
          Inc(Line);
          Char := 1;
        end else if (P[I] = '*') and (P[I + 1] = '|') and (P[I + 2] = '*') then begin
          // ATSynEdit: TPoint is 0-based (X=col-1, Y=line-1)
          NewCursorPos := Point(Char - 1, Line - 1);
          Delete(value, I + 1, 3);
          HadMarker := True;
          break;
        end else begin
          Inc(Char);
          Inc(I);
        end;
      end;
    end;
    // Insert text at caret using DoCommand (handles repaint correctly)
    fText.DoCommand(cCommand_TextInsert, TATCommandInvoke(0), UnicodeString(value));

    // Update the cursor:
    // - If *|* marker was found, NewCursorPos has the marker position
    // - If no marker, keep DoCommand's end-of-insert position
    if HadMarker then begin
      fText.Carets[0].PosX := NewCursorPos.X;
      fText.Carets[0].PosY := NewCursorPos.Y;
    end;

  finally
    fText.EndUpdate;
  end;
  // Update current line highlight after programmatic caret move
  UpdateCurrentLineMarker;
end;

procedure TEditor.InsertDefaultText;
var
  tmp: TStrings;
begin
  if devEditor.DefaultCode and FileExists(devDirs.Config + DEV_DEFAULTCODE_FILE) then begin
    tmp := TStringList.Create;
    try
      tmp.LoadFromFile(devDirs.Config + DEV_DEFAULTCODE_FILE);
      //InsertString(ParseMacros(tmp.Text), true);
      InsertString(tmp.Text, true);
    finally
      tmp.Free;
    end;
  end;

  // Defer reparse until Activate (editor must be visible for UpdateEditors to repaint)
  fNeedReparse := True;
end;

procedure TEditor.ForceSyntaxRefresh;
begin
  // Force EControl adapter to re-parse from line 0 and repaint.
  // Used after LoadFromFile / InsertString when content is loaded after
  // the constructor's initial ParseFromLine(0, True) ran on an empty buffer.
  if Assigned(fText.AdapterForHilite) and (fText.AdapterForHilite is TATAdapterEControl) then begin
    TATAdapterEControl(fText.AdapterForHilite).ParseFromLine(0, True);
    fText.Update(True, False);
    fText.Invalidate;
  end;
end;

procedure TEditor.SetCaretPosAndActivate(Line, Col: integer);
begin
  // ATSynEdit: UncollapseAroundLine �?use DoUnfoldNearLine equivalent
  // fText.UncollapseAroundLine(Line); // SynEdit only
  // Guard: clamp Line and Col to the editor's valid range so ATSynEdit does
  // not throw when the caller passes an out-of-bounds value (e.g. GotoLine
  // with a line number larger than the file).  Also skip entirely when the
  // file has no content.
  if (fText.Strings.Count <= 0) then Exit;
  if (Line < 1) then Line := 1;
  if (Line > fText.Strings.Count) then Line := fText.Strings.Count;
  if (Col < 1) then Col := 1;

  // Set caret position FIRST so any events triggered by Activate see correct position
  fText.Carets[0].PosX := Col - 1;
  fText.Carets[0].PosY := Line - 1;

  // fText needs to be focused for TopLine and LinesInWindow to be correct
  if not fText.Focused then
    Self.Activate;

  // Scroll to make the caret visible (even if it's outside the visible area)
  fText.DoGotoCaret(TATCaretEdge.Top);

  // Refresh current line highlight (BK_CURRENTLINE bookmark), so any caret
  // movement — GotoLine, GotoError, NavigateToActive, etc. — always keeps the
  // highlight on the correct line.
  UpdateCurrentLineMarker;

  fText.Invalidate;
end;

procedure TEditor.CompletionKeyPress(Sender: TObject; var Key: Char);
var
  s: String;
begin

  // We received a key from the completion box...
  if fCompletionBox.Enabled then begin
    if CharInSet(Key, ['A'..'Z', 'a'..'z', '0'..'9', '_']) then begin // Continue filtering
      // ATSynEdit: insert typed character using DoCommand
      fText.DoCommand(cCommand_TextInsert, TATCommandInvoke(0), UnicodeString(Key));
      // Without highlighter attributes, default to 'normal' search
      fCompletionBox.Search('normal', GetWordAtPosition(Point(fText.Carets[0].PosX, fText.Carets[0].PosY), wpCompletion), AnsiString(fFileName));
    end else if Key = Char(VK_BACK) then begin
      // ATSynEdit: use DoCommand for backspace
      fText.DoCommand(cCommand_KeyBackspace, TATCommandInvoke(0), '');

      s := GetWordAtPosition(Point(fText.Carets[0].PosX, fText.Carets[0].PosY), wpCompletion);
      if s.length = 0 then begin
        fCompletionBox.Hide;
        exit;
      end;
      // Without highlighter attributes, default to 'normal' search
      fCompletionBox.Search('normal', GetWordAtPosition(Point(fText.Carets[0].PosX, fText.Carets[0].PosY), wpCompletion), AnsiString(fFileName));

    end else if Key = Char(VK_ESCAPE) then begin
      fCompletionBox.Hide;
    end else if CharInSet(Key, [Char(VK_RETURN), '(']) then begin // Ending chars, don't insert
      CompletionInsert('');
      fCompletionBox.Hide;
    end else begin
      CompletionInsert(Key);
      fCompletionBox.Hide;
    end;
  end;
end;

procedure TEditor.HandleSymbolCompletion(var Key: Char);
var
// TODO: ATSynEdit - removed Attr: TATSynHighlighterAttributes (SynEdit specific type)
  //Token: String;
  HighlightPos: TPoint;

  procedure HandleParentheseCompletion;   // ( )
  begin
    fParenthCompleteState := scsInserted; // Set state BEFORE InsertString to survive recursive DoCommand
    InsertString('()', false);
    fText.Carets[0].PosX := fText.Carets[0].PosX - 1; // caret between ()
    Key := #0; // cancel original key (ATSynedit inserts char after OnKeyPress)
    if FunctionTipAllowed then
      fFunctionTip.Activated := true;
  end;

  procedure HandleParentheseSkip;     // )
  var
    LineText: String;
  begin
    // Check if there's a ')' to the right of the caret (from auto-completion)
    LineText := AnsiString(fText.Strings.Lines[fText.Carets[0].PosY]);
    if (fText.Carets[0].PosX < Length(LineText)) and (LineText[fText.Carets[0].PosX + 1] = ')') then begin
      fText.Carets[0].PosX := fText.Carets[0].PosX + 1; // skip over
      fParenthCompleteState := scsSkipped;
      Key := #0; // remove key press
    end;
  end;

  procedure HandleArrayCompletion;
  begin
    fArrayCompleteState := scsInserted;
    InsertString('[]', false);
    fText.Carets[0].PosX := fText.Carets[0].PosX - 1; // caret between []
    Key := #0;
    fArrayCompleteState := scsInserted;
  end;

  procedure HandleArraySkip;         // ]
  var
    LineText: String;
  begin
    LineText := AnsiString(fText.Strings.Lines[fText.Carets[0].PosY]);
    if (fText.Carets[0].PosX < Length(LineText)) and (LineText[fText.Carets[0].PosX + 1] = ']') then begin
      fText.Carets[0].PosX := fText.Carets[0].PosX + 1; // skip over
      fArrayCompleteState := scsSkipped;
      Key := #0; // remove key press
    end;
  end;

  procedure HandleMultilineCommentCompletion;
  begin
    if (fText.Carets[0].PosX > 1) and (Length(AnsiString(fText.Strings.Lines[fText.Carets[0].PosY])) >= fText.Carets[0].PosX - 1) and
       (AnsiString(fText.Strings.Lines[fText.Carets[0].PosY])[fText.Carets[0].PosX - 1] = '/') then
      InsertString('*/', false);
  end;

  procedure HandleBraceCompletion;    // {
  var
    LineBeforeCaret, Indent, MoreIndent, ExtraIndent: String;
    IndentCount: integer;
    LineTxt: String;
    //OrigPosX: integer;
    OrigPosY: integer;
  begin
    // Determine what word is before us
    LineTxt := AnsiString(fText.Strings.Lines[fText.Carets[0].PosY]);
    LineBeforeCaret := Trim(Copy(LineTxt, 1, fText.Carets[0].PosX));

    // Determine current indent
    IndentCount := 0;
    while (IndentCount + 1 <= Length(LineTxt)) and CharInSet(LineTxt[IndentCount + 1], [#9, ' ']) do
      Inc(IndentCount);

    // Get indentation string (preserve exact indent from current line)
    Indent := Copy(LineTxt, 1, IndentCount);

    // One additional indent level for lines inside the block
    if fText.OptTabSpaces then
      ExtraIndent := StringOfChar(#32, fText.OptTabSize)
    else
      ExtraIndent := #9;

    // Save original caret position before InsertString moves it
    //OrigPosX := fText.Carets[0].PosX;
    OrigPosY := fText.Carets[0].PosY;

    // For case/default: extra indent for the line inside the block
    if StartsStr('case', LineBeforeCaret) or
      StartsStr('default', LineBeforeCaret) then begin

      // Get extra indentation string
      if fText.OptTabSpaces then
        MoreIndent := Indent + StringOfChar(#32, fText.OptTabSize)
      else
        MoreIndent := Indent + StringOfChar(#9, 1);

      InsertString('{' + #10 + MoreIndent + 'break;' + #10 + Indent + '}', false);
      // Position caret on the break; line after indent
      fText.Carets[0].PosY := OrigPosY + 1;
      fText.Carets[0].PosX := Length(MoreIndent);
      Key := #0; // cancel original key insertion

      // For other valid block starts, do the following:
      // { + enter + indent + extra + enter + indent + }
    end else if EndsStr(')', LineBeforeCaret) or
      SameStr('', LineBeforeCaret) or
      EndsStr('else', LineBeforeCaret) or
      EndsStr('try', LineBeforeCaret) or
      EndsStr('catch', LineBeforeCaret) or
      StartsStr('namespace', LineBeforeCaret) or
      EndsStr('do', LineBeforeCaret) then begin

      InsertString('{' + #10 + Indent + ExtraIndent + #10 + Indent + '}', false);
      // Position caret on the indented line after extra indent
      fText.Carets[0].PosY := OrigPosY + 1;
      fText.Carets[0].PosX := IndentCount + Length(ExtraIndent);
      Key := #0; // cancel original key insertion

      // For structs and derivatives, do the following:
      // { + enter + indent + extra + enter + indent + };
    end else if
      StartsStr('struct', LineBeforeCaret) or
      StartsStr('union', LineBeforeCaret) or
      StartsStr('class', LineBeforeCaret) or
      StartsStr('enum', LineBeforeCaret) or
      StartsStr('typedef ', LineBeforeCaret) then begin

      InsertString('{' + #10 + Indent + ExtraIndent + #10 + Indent + '};', false);
      // Position caret on the indented line after extra indent
      fText.Carets[0].PosY := OrigPosY + 1;
      fText.Carets[0].PosX := IndentCount + Length(ExtraIndent);
      Key := #0; // cancel original key insertion
    end else begin
      InsertString('}', false);
      fBraceCompleteState := scsInserted;
    end;
  end;

  procedure HandleBraceSkip;      // }
  var
    LineText: String;
  begin
    LineText := AnsiString(fText.Strings.Lines[fText.Carets[0].PosY]);
    if (fText.Carets[0].PosX < Length(LineText)) and (LineText[fText.Carets[0].PosX + 1] = '}') then begin
      // ATSynEdit: advance caret by 1 column using CaretPos (0-based)
      fText.Carets[0].PosX := fText.Carets[0].PosX + 1;
      fBraceCompleteState := scsSkipped;
      Key := #0; // remove key press
    end;
  end;

  procedure HandleLocalIncludeCompletion;
  begin
    // ATSynEdit: use Strings.Lines instead of LineText
    if StartsStr('#include', TrimLeft(AnsiString(fText.Strings.Lines[fText.Carets[0].PosY]))) then begin
      InsertString('""', false);
      fText.Carets[0].PosX := fText.Carets[0].PosX - 1; // caret between quotes
      Key := #0;
    end;
  end;

  procedure HandleGlobalIncludeCompletion;
  begin
    // ATSynEdit: use Strings.Lines instead of LineText
    if StartsStr('#include', TrimLeft(AnsiString(fText.Strings.Lines[fText.Carets[0].PosY]))) then begin
      InsertString('<>', false);
      fText.Carets[0].PosX := fText.Carets[0].PosX - 1;
      Key := #0;
    end;
  end;

  procedure HandleSingleQuoteCompletion;
  begin
    InsertString('''''', false); // two single quotes; escape: '''' in Pascal = '' (two chars)
    fText.Carets[0].PosX := fText.Carets[0].PosX - 1;
    fSingleQuoteCompleteState := scsInserted;
    Key := #0;
  end;

  procedure HandleDoubleQuoteCompletion;
  begin
    InsertString('""', false);
    fText.Carets[0].PosX := fText.Carets[0].PosX - 1;
    fDoubleQuoteCompleteState := scsInserted;
    Key := #0;
  end;

begin
  if not devEditor.CompleteSymbols or not fText.CaretsSel.IsEmpty then
    Exit;

  // Find the end of the first nonblank line above us
  // ATSynEdit: TPoint is 0-based (X=col-1, Y=line-1); CaretX/CaretY remain 1-based helpers
  HighlightPos := Point(fText.Carets[0].PosX, fText.Carets[0].PosY); // ATSynEdit Carets are 0-based
  while (HighlightPos.Y > 0) and (Length(fText.Strings.Lines[HighlightPos.Y]) = 0) do
    Dec(HighlightPos.Y);
  HighlightPos.X := Length(fText.Strings.Lines[HighlightPos.Y]);

  // Without EControl adapter for highlighter attributes, skip string/comment detection.
  // Symbol completion will work but may insert pairs inside strings/comments.
  // This is acceptable for the current migration state.

  case Key of
    '(': begin
        if devEditor.ParentheseComplete then
          HandleParentheseCompletion;
      end;
    ')': begin
        if devEditor.ParentheseComplete then
          HandleParentheseSkip;
      end;
    '[': begin
        if devEditor.ArrayComplete then
          HandleArrayCompletion;
      end;
    ']': begin
        if devEditor.ArrayComplete then
          HandleArraySkip;
      end;
    '*': begin
        if devEditor.CommentComplete then
          HandleMultilineCommentCompletion;
      end;
    '{': begin
        if devEditor.BraceComplete then
          HandleBraceCompletion;
      end;
    '}': begin
        if devEditor.BraceComplete then
          HandleBraceSkip;
      end;
    '<': begin
        if devEditor.IncludeComplete then // include <>
          HandleGlobalIncludeCompletion;
      end;
    '''': begin
        if devEditor.SingleQuoteComplete then // characters
          HandleSingleQuoteCompletion;
      end;
    '"': begin
        if devEditor.IncludeComplete and
          StartsStr('#include', TrimLeft(AnsiString(fText.Strings.Lines[fText.Carets[0].PosY]))) then
          HandleLocalIncludeCompletion
        else if devEditor.DoubleQuoteComplete then // strings
          HandleDoubleQuoteCompletion;
      end;
  else begin
//      fParenthCompleteState := scsSkipped;
//      fArrayCompleteState := scsSkipped;
//      fBraceCompleteState := scsSkipped;
//      fSingleQuoteCompleteState := scsSkipped;
//      fDoubleQuoteCompleteState := scsSkipped;
    end;
  end;
end;

procedure TEditor.HandleSymbolCompletionFromVK(Key: Word; Shift: TShiftState);
var
  Ch: Char;
  KbdState: TKeyboardState;
begin
  // Convert virtual key code + shift state to an actual character
  // using WinAPI (keyboard-layout independent)
  KbdState[VK_SHIFT] := 0;
  KbdState[VK_CONTROL] := 0;
  KbdState[VK_MENU] := 0;
  if ssShift in Shift then KbdState[VK_SHIFT] := $80;
  if ssCtrl in Shift then KbdState[VK_CONTROL] := $80;
  if ssAlt in Shift then KbdState[VK_MENU] := $80;
  if ToAscii(Key, 0, KbdState, @Ch, 0) <> 1 then Exit;

  HandleSymbolCompletion(Ch);
  if Ch = #0 then
    Key := 0; // consumed, prevent further processing
end;

procedure TEditor.HandleCodeCompletion(var Key: Char);
var
  s: String;
  LineText: String;
  ChBefore: String;
begin
  fCompletionTimer.Enabled := False;
  if fCompletionBox.Enabled then begin
    // Use a timer to show the completion window when we just typed trigger chars
    // OnCommand fires BEFORE insertion, so PosX is where the trigger char will be inserted.
    // UTF8Copy(LineText, PosX, 1) gets the char at 1-based index = PosX, which is the
    // character immediately before the caret (since PosX is 0-based char count before caret).
    case Key of
      '.': if devCodeCompletion.ShowMemberCompletion and (fText.Carets[0].PosX > 0) then begin
        // Only trigger if the char before "." is a valid identifier ending char.
        // This prevents triggering after Chinese/other non-ASCII characters.
        LineText := AnsiString(fText.Strings.Lines[fText.Carets[0].PosY]);
        ChBefore := UTF8Copy(LineText, fText.Carets[0].PosX, 1);
        if (Length(ChBefore) = 1) and CharInSet(ChBefore[1], ['a'..'z', 'A'..'Z', '0'..'9', '_', ')', ']']) then begin
          fCompletionInitialPosition := Point(fText.Carets[0].PosX + 1, fText.Carets[0].PosY);
          fCompletionTimer.Enabled := True;
        end;
      end;
      '>': if devCodeCompletion.ShowMemberCompletion and (fText.Carets[0].PosX > 0) then begin
            LineText := AnsiString(fText.Strings.Lines[fText.Carets[0].PosY]);
            ChBefore := UTF8Copy(LineText, fText.Carets[0].PosX, 1);
            if (Length(ChBefore) = 1) and (ChBefore[1] = '-') then begin
              fCompletionInitialPosition := Point(fText.Carets[0].PosX + 1, fText.Carets[0].PosY);
              fCompletionTimer.Enabled := True;
            end;
           end;
      ':': if devCodeCompletion.ShowMemberCompletion and (fText.Carets[0].PosX > 0) then begin
             LineText := AnsiString(fText.Strings.Lines[fText.Carets[0].PosY]);
             ChBefore := UTF8Copy(LineText, fText.Carets[0].PosX, 1);
             if (Length(ChBefore) = 1) and (ChBefore[1] = ':') then begin
               fCompletionInitialPosition := Point(fText.Carets[0].PosX + 1, fText.Carets[0].PosY);
               fCompletionTimer.Enabled := True;
             end;
           end;
      else begin  //other cases
        // Without highlighter attributes, show completion for identifier chars
        if devCodeCompletion.ShowIdentCompletion and (Key in ['A'..'Z', 'a'..'z', '_', '0'..'9']) then begin
          // OnCommand fires BEFORE insertion, so GetWordAtPosition won't include Key.
          // Append Key to get the effective word after insertion.
          s := GetWordAtPosition(Point(fText.Carets[0].PosX, fText.Carets[0].PosY), wpCompletion) + Key;
          // Min word length for completion: use devCodeCompletion.Delay threshold or default 3
          if (s.Length >= 3) then begin
            fCompletionInitialPosition := Point(fText.Carets[0].PosX + 1, fText.Carets[0].PosY);
            fCompletionTimer.Enabled := True;
          end else
            fCompletionTimer.Enabled := False;
        end;
      end; //else
    end; //case
  end;
end;

procedure TEditor.EditorKeyPress(Sender: TObject; var Key: Char);
begin
  // ATSynEdit: OnKeyPress is NOT fired for text insertion (ATSynEdit uses OnCommand instead).
  // Symbol completion and code completion are handled in EditorCommand.
end;

procedure TEditor.EditorCommand(Sender: TObject; ACommand: integer; AInvoke: TATCommandInvoke;
          const AText: string; var AHandled: boolean);
var
  Ch: Char;
  CompletionCh: Char;
begin
  // Update insert/overwrite status bar panel when mode is toggled (Insert key)
  if ACommand = cCommand_ToggleOverwrite then begin
    // ModeOverwrite is toggled AFTER OnCommand fires, so we check the future state
    with MainForm.Statusbar do begin
      if fText.ModeReadOnly then
        Panels[1].Text := Lang[ID_READONLY]
      else if fText.ModeOverwrite then
        // currently overwrite → will become insert
        Panels[1].Text := Lang[ID_INSERT]
      else
        // currently insert → will become overwrite
        Panels[1].Text := Lang[ID_OVERWRITE];
    end;
    Exit;
  end;

  // Intercept single-character text insertion for symbol completion and code completion.
  // ATSynEdit fires OnCommand (not OnKeyPress) for text input; OnCommand fires BEFORE insertion.
  if (ACommand <> cCommand_TextInsert) or (Length(AText) <> 1) then Exit;
  if not Assigned(fText.AdapterForHilite) then Exit;
  if not fText.CaretsSel.IsEmpty then Exit;

  // Symbol completion (brackets, quotes, etc.) — only if enabled
  Ch := AText[1];
  if devEditor.CompleteSymbols then
    HandleSymbolCompletion(Ch);
  if Ch = #0 then begin
    AHandled := True; // symbol completion consumed the key
    fText.Invalidate; // Force repaint (DoCommand exits early, skipping normal display update)
  end;


  // Code completion (. , -> , :: , 3+ char identifiers)
  // HandleCodeCompletion checks fCompletionBox.Enabled internally
  CompletionCh := AText[1];
  HandleCodeCompletion(CompletionCh);
end;


// ATSynEdit migration: ScanForFoldRanges was a SynEdit-specific callback for custom fold range detection.
// ATSynEdit uses its own built-in fold detection. This method is intentionally left empty.
// The original SynEdit implementation used TSynFoldRanges and SynHighlighterCpp.TRangeState
// which are not available in ATSynEdit.
procedure TEditor.ScanForFoldRanges(Sender: TObject;
  TopFoldRanges: Pointer; LinesToScan: TStrings; FromLine,
  ToLine: Integer);
begin
  // Not implemented: ATSynEdit handles fold ranges natively
end;



procedure TEditor.EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  p: TPoint; // ATSynEdit: TPoint instead of TBufferCoord
  DeletedChar, NextChar: Char;
  S: String;
  Reason: THandPointReason = hprNone;

  procedure UndoSymbolCompletion;
  var
    LineText: String;
  begin
    if devEditor.DeleteSymbolPairs then begin
      if (devEditor.ArrayComplete and (DeletedChar = '[') and (NextChar = ']')) or
        (devEditor.ParentheseComplete and (DeletedChar = '(') and (NextChar = ')')) or
        (devEditor.BraceComplete and (DeletedChar = '{') and (NextChar = '}')) or
        (devEditor.SingleQuoteComplete and (DeletedChar = '''') and (NextChar = '''')) or
        (devEditor.DoubleQuoteComplete and (DeletedChar = '"') and (NextChar = '"')) then begin
        // ATSynEdit: use Strings.Lines to get and set line text
        LineText := AnsiString(fText.Strings.Lines[fText.Carets[0].PosY - 1]);
        fText.Strings.Lines[fText.Carets[0].PosY - 1] := UnicodeString(
          Copy(LineText, 1, fText.Carets[0].PosX - 1) +
          Copy(LineText, fText.Carets[0].PosX + 1, MaxInt));
      end;
    end;
  end;
begin
  p := Point(0, 0);
  // Don't offer completion functions for plain text files
  if not Assigned(fText.AdapterForHilite) then
    Exit;

  // See if we can undo what has been inserted by HandleSymbolCompletion
  case (Key) of
    VK_CONTROL: begin
        Reason := HandpointAllowed(p, Shift);
        if Reason <> hprNone then
          fText.Cursor := crHandPoint
        else
          fText.Cursor := crIBeam;
      end;
    VK_RETURN: begin
      //todo
      end;
    VK_ESCAPE: begin // Update function tip
        if ttoHideOnEsc in fFunctionTip.Options then begin
          fFunctionTip.ReleaseHandle;
          fFunctionTip.ForceHide := true;
        end;
      end;
    VK_DELETE: begin // remove completed character
       if not fText.CaretsSel.IsEmpty then begin
          // ATSynEdit: use Strings.Lines instead of LineText
          S := AnsiString(fText.Strings.Lines[fText.Carets[0].PosY]);
          if fText.Carets[0].PosX < Length(S) then begin
            DeletedChar := S[fText.Carets[0].PosX];
            NextChar := S[fText.Carets[0].PosX + 1];
            UndoSymbolCompletion;
          end;
        end;
      end;
    VK_BACK: begin // remove completed character
        if not fText.CaretsSel.IsEmpty then begin
          // ATSynEdit: use Strings.Lines instead of LineText
          S := AnsiString(fText.Strings.Lines[fText.Carets[0].PosY]);
          if (fText.Carets[0].PosX > 1) and (fText.Carets[0].PosX <= Length(S)) then begin
            DeletedChar := S[fText.Carets[0].PosX - 1];
            NextChar := S[fText.Carets[0].PosX];
            UndoSymbolCompletion;
          end;
        end;
      end;
  end;
end;

procedure TEditor.EditorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_CONTROL) then
    fText.Cursor := crIBeam;
end;

procedure TEditor.CompletionTimer(Sender: TObject);
begin
  // ATSynEdit: CaretPos is 0-based TPoint; fCompletionInitialPosition stores (CaretX_before+1, CaretPos.Y)
  // OnKeyPress fires BEFORE char insertion; CompletionTimer fires AFTER char insertion.
  // Stored: PosX_before + 1 = PosX_after (since 1 char was inserted)
  // So compare raw PosX_after with stored value (no extra +1 in comparison)
  if (fText.Carets[0].PosX <> fCompletionInitialPosition.X) or
    (fText.Carets[0].PosY <> fCompletionInitialPosition.Y) then
    Exit;

  ShowCompletion;
end;

procedure TEditor.InitCompletion;
begin
  fCompletionBox := MainForm.CodeCompletion;
  fCompletionBox.Enabled := devCodeCompletion.Enabled;

  //  if devEditor.ShowFunctionTip then begin
  if devCodeCompletion.ShowFunctionHints then begin
    if not Assigned(fFunctionTipTimer) then
      fFunctionTipTimer := TTimer.Create(nil);
    fFunctionTipTimer.Enabled := True;
    fFunctionTipTimer.OnTimer := @FunctionTipTimer;
    fFunctionTipTimer.Interval := 2 * GetCaretBlinkTime; // fancy
  end else begin
    fFunctionTip.ReleaseHandle; // hide
    FreeAndNil(fFunctionTipTimer); // remove timer, because we only have a limited number avaiable
  end;

  // The other stuff is fully completion dependant
  if fCompletionBox.Enabled then begin
    fCompletionBox.Width := devCodeCompletion.Width;
    fCompletionBox.Height := devCodeCompletion.Height;

    if not Assigned(fCompletionTimer) then
      fCompletionTimer := TTimer.Create(nil);

    fCompletionTimer.Enabled := False;
    fCompletionTimer.OnTimer := @CompletionTimer;
    fCompletionTimer.Interval := devCodeCompletion.Delay;
  end else begin
    FreeAndNil(fCompletionTimer);
  end;
end;

procedure TEditor.ShowCompletion;
var
  P: TPoint;
  M: TMemoryStream;
  s, ParentWord, OperatorToken: String;
  LineText: String;
  PosX: Integer;
  Stmt: PStatement;
  IsPointerType: Boolean;
  WordBegin: Integer;
  // Without EControl highlighter attributes, skip filtering by token type.
  // Completion will be offered in all contexts (including preprocessor).
begin
  if not devCodeCompletion.Enabled then
    Exit;
  if not MainForm.CppParser.Enabled then
    Exit;
  fCompletionTimer.Enabled := False;

  if fCompletionBox.Visible then // already in search, don't do it again
    Exit;

  // ATSynEdit: get pixel position of caret for completion box placement using CaretPosToClientPos
  with fText.CaretPosToClientPos(Point(fText.Carets[0].PosX, fText.Carets[0].PosY)) do
    P := Point(Integer(X), Integer(Y));
  Inc(P.Y, fText.TextCharSize.Y + 2);
  fCompletionBox.Position := fText.ClientToScreen(P);

  M := TMemoryStream.Create;
  try
    fText.Strings.SaveToStream(M, TATFileEncoding.ANSI, true);

    // Reparse whole file (not function bodies) if it has been modified.
    //if fText.Modified then begin
    if fModified then begin
      MainForm.CppParser.ParseFile(AnsiString(fFileName), InProject, False, True, M);
    end;

    // Scan the current function body (ATSynEdit: CaretY is 1-based)
    fCompletionBox.CurrentStatement := MainForm.CppParser.FindAndScanBlockAt(AnsiString(fFileName), fText.Carets[0].PosY, M);
  finally
    M.Free;
  end;

  // Redirect key presses to completion box if applicable
  fCompletionBox.OnKeyPress := @CompletionKeyPress;

  // At this point the trigger char has already been inserted. Detect the operator
  // just before the caret and check whether it is valid for the variable's declared type.
  PosX := fText.Carets[0].PosX; // 0-based column index
  if (PosX >= 2) then begin
    LineText := AnsiString(fText.Strings.Lines[fText.Carets[0].PosY]);

    // Detect the operator: check if last 2 chars are '->' or last 1 char is '.'
    OperatorToken := '';
    if (PosX >= 2) and (PosX <= Length(LineText)) then begin
      // LineText[PosX] = char at 0-based PosX = 1-based index PosX+1
      if (LineText[PosX] = '>') and (LineText[PosX - 1] = '-') then
        OperatorToken := '->'
      else if (LineText[PosX] = '.') then
        OperatorToken := '.';
    end;

    // If an operator was found, validate it against the variable's declared type.
    if OperatorToken <> '' then begin
      // Extract the word before the operator (the variable or type name).
      // Scan backward from the char before the operator until a non-identifier char.
      WordBegin := PosX - Length(OperatorToken); // position of char before operator
      while (WordBegin >= 1) and CharInSet(LineText[WordBegin], ['a'..'z', 'A'..'Z', '0'..'9', '_']) do
        Dec(WordBegin);
      Inc(WordBegin);
      ParentWord := Copy(LineText, WordBegin, PosX - WordBegin - Length(OperatorToken) + 1);

      // Look up the variable's statement to get its declared type.
      Stmt := MainForm.CppParser.FindStatementOf(ParentWord, fCompletionBox.CurrentStatement);
      if Assigned(Stmt) and (Stmt^._Type <> '') then begin
        // A type ending with '*' (or '* &' etc.) is a pointer type.
        IsPointerType := (Stmt^._Type[Length(Stmt^._Type)] = '*');
        // Member access rules:
        //   Pointer type  -> only '->' is valid
        //   Non-pointer   -> only '.'  is valid
        if IsPointerType and (OperatorToken = '.') then begin
          // ptr. on a pointer variable — suppress. User should type ->
          Exit;
        end else if not IsPointerType and (OperatorToken = '->') then begin
          // obj-> on a non-pointer variable — suppress. User should type .
          Exit;
        end;
        // Operator matches type — fall through to normal member completion
      end else begin
        // Cannot determine type — let the completion proceed; let the user decide
      end;
    end;
  end;

  // Normal completion: identifier, or valid member access operator.
  s := GetWordAtPosition(Point(fText.Carets[0].PosX, fText.Carets[0].PosY), wpCompletion);
  if (s <> '') then
    fCompletionBox.Search('normal', s, AnsiString(fFileName));
end;

procedure TEditor.DestroyCompletion;
begin
  FreeAndNil(fCompletionTimer);
  FreeAndNil(fFunctionTipTimer);
end;


function TEditor.GetWordAtPosition(P: TPoint; Purpose: TWordPurpose): String;
var
  WordBegin, WordEnd, ParamBegin, ParamEnd, len: integer;
  s: UnicodeString;
  LineIdx, ColIdx: integer;
begin
  Result := '';
  ColIdx := P.X + 1;
  LineIdx := P.Y + 1;

  if (LineIdx >= 1) and (LineIdx <= fText.Strings.Count) then
  begin
    s := fText.Strings.Lines[LineIdx - 1];
    len := Length(s);
    WordBegin := ColIdx - 1;
    WordEnd := ColIdx - 1;

    // Copy forward until end of word
    if Purpose in [wpEvaluation, wpInformation] then
    begin
      while (WordEnd + 1 <= len) do
      begin
        if (Purpose = wpEvaluation) and (s[WordEnd + 1] = '[') then
        begin
          if not FindComplement(AnsiString(s), '[', ']', WordEnd, 1) then
            break;
        end
        else if CharInSet(s[WordEnd + 1], ['a'..'z','A'..'Z','0'..'9','_']) then
          Inc(WordEnd)
        else
          break;
      end;
    end;

    // Copy backward until end of word
    if Purpose in [wpCompletion, wpEvaluation, wpInformation] then
    begin
      while (WordBegin > 0) and (WordBegin <= len) do
      begin
        if (s[WordBegin] = ']') then
        begin
          if not FindComplement(AnsiString(s), ']', '[', WordBegin, -1) then
            break
          else
            Dec(WordBegin);
        end
        else if CharInSet(s[WordBegin], ['a'..'z','A'..'Z','0'..'9','_']) then
          Dec(WordBegin)
        else if CharInSet(s[WordBegin], ['.', ':', '~', '#']) then
          Dec(WordBegin)
        else if (WordBegin > 1) and (s[WordBegin - 1] = '-') and (s[WordBegin] = '>') then
          Dec(WordBegin, 2)
        else if (WordBegin > 1) and (s[WordBegin] = ')') then
        begin
          if not FindComplement(AnsiString(s), ')', '(', WordBegin, -1) then
            break
          else
            Dec(WordBegin);
        end
        else
          break;
      end;
    end;

    // Strip function parameters
    while true do
    begin
      ParamBegin := Pos('(', Result);
      if ParamBegin > 0 then
      begin
        ParamEnd := ParamBegin;
        if FindComplement(Result, '(', ')', ParamEnd, 1) then
          Delete(Result, ParamBegin, ParamEnd - ParamBegin + 1)
        else
          break;
      end
      else
        break;
    end;

    // Strip array stuff
    if not (Purpose = wpEvaluation) then
      while true do
      begin
        ParamBegin := Pos('[', Result);
        if ParamBegin > 0 then
        begin
          ParamEnd := ParamBegin;
          if FindComplement(Result, '[', ']', ParamEnd, 1) then
            Delete(Result, ParamBegin, ParamEnd - ParamBegin + 1)
          else
            break;
        end
        else
          break;
      end;

    // Get end result
    if (WordBegin < 0) or (WordEnd < WordBegin) then
      Exit;
    Result := AnsiString(Copy(s, WordBegin + 1, WordEnd - WordBegin));
  end
  else
  begin
    WordBegin := 0;
    WordEnd := 0;
  end;
end;
procedure TEditor.CompletionInsert(const append: String);
var
  Statement: PStatement;
  FuncAddOn: String;
  Command: String;
  S: String;
  WordStartPos, WordEndPos: TPoint; // ATSynEdit: TPoint (0-based)
begin
  Statement := fCompletionBox.SelectedStatement;
  if not Assigned(Statement) then
    Exit;

  // ATSynEdit: check for existing '(' using Strings.Lines
  if (Statement^._Kind in [skFunction, skConstructor, skDestructor])
     or ((Statement^._Kind = skKeyword) and (Statement^._Command = 'for'))
     or ((Statement^._Kind = skKeyword) and (Statement^._Command = 'while'))
     or ((Statement^._Kind = skKeyword) and (Statement^._Command = 'if'))
     or ((Statement^._Kind = skKeyword) and (Statement^._Command = 'switch'))
     or ((Statement^._Kind = skKeyword) and (Statement^._Command = 'catch')) then begin
    S := AnsiString(fText.Strings.Lines[fText.Carets[0].PosY]);
    if (fText.Carets[0].PosX >= Length(S)) or (S[fText.Carets[0].PosX + 1] <> '(') then begin
      FuncAddOn := '()';
    end else
      FuncAddOn := '';
  end else
    FuncAddOn := '';

  // ATSynEdit: use current line to determine word boundaries and replace
  // Use current caret position (0-based) to determine what word to replace
  WordEndPos := Point(fText.Carets[0].PosX, fText.Carets[0].PosY); // 0-based
  // Find the start and end of the current word by walking backward and forward
  WordStartPos := WordEndPos;
  S := '';
  if (WordEndPos.Y >= 0) and (WordEndPos.Y < fText.Strings.Count) then begin
    S := AnsiString(fText.Strings.Lines[WordEndPos.Y]);
    // Walk backward from caret to find start of word (S is 1-based, caret is 0-based)
    // 0-based position X corresponds to 1-based index X+1 in S
    while (WordStartPos.X > 0) and (WordStartPos.X <= Length(S)) and
          CharInSet(S[WordStartPos.X], ['A'..'Z', 'a'..'z', '0'..'9', '_']) do
      Dec(WordStartPos.X);
    // Now WordStartPos.X is the 0-based index of the last non-ident char before the word
    // Walk forward to find end of word (from caret position)
    while (WordEndPos.X < Length(S)) and (WordEndPos.X >= 0) and
          CharInSet(S[WordEndPos.X + 1], ['A'..'Z', 'a'..'z', '0'..'9', '_']) do
      Inc(WordEndPos.X);
  end;

  Command := Statement^._Command;
  if StartsStr('#', Command) then
    Command := ReplaceFirstStr(Command, '#', '');

  // Replace the word in the line using Strings manipulation
  // Keep chars before word: S[1..WordStartPos.X] (1-based), which is Copy(S, 1, WordStartPos.X)
  // Replace word with: Command + FuncAddOn + append
  // Keep chars after word: S[WordEndPos.X+1..] (1-based), which is Copy(S, WordEndPos.X + 1, MaxInt)
  fText.Strings.Lines[WordEndPos.Y] := UnicodeString(
    Copy(S, 1, WordStartPos.X) +
    Command + FuncAddOn + append +
    Copy(S, WordEndPos.X + 1, MaxInt));

  // Default: place caret after the inserted completion text
  fText.Carets[0].PosX := WordStartPos.X + Length(Command + FuncAddOn + append);

  // Move caret inside the ()'s, only when the user has something to do there...
  if (FuncAddOn <> '') and (Statement^._Args <> '()') and (Statement^._Args <> '(void)') then begin

    fText.Carets[0].PosX := WordStartPos.X + Length(Command) + 1; // right after '('

    // immediately activate function hint (only for actual functions, not keywords)
    if Statement^._Kind in [skFunction, skConstructor, skDestructor] then begin
    //if devEditor.ShowFunctionTip and Assigned(fText.AdapterForHilite) then begin
    if devCodeCompletion.ShowFunctionHints and Assigned(fText.AdapterForHilite) then begin
      fText.SetFocus;
      fFunctionTip.Show;
    end;
  end;
end;

  // Force repaint so inserted text (and text after it) is visible immediately.
  // We modified Strings.Lines[] outside of DoCommand -> DoCommandResults flow.
  // Need to replicate what DoCommandResults does after text change:
  // 1. DoEventChange - fires FOnChange (EditorStatusChange) and notifies highlighter
  // 2. Update(true, true) - updates wrap info AND queues forced repaint
  //    (AForceRepaint=true bypasses flicker-reducing / IsDataReadyPartially checks)
  // 3. TWinControl(fText).Update - forces immediate processing of WM_PAINT
  //    (cast to TWinControl because ATSynEdit uses reintroduce on Update)
  fText.DoEventChange(WordEndPos.Y);
  fText.Update(true, true);
  TWinControl(fText).Update;
end;

procedure TEditor.EditorDblClick(Sender: TObject; var AHandled: boolean);
var
  i: integer;
begin
  fDblClickTime := Cardinal(GetTickCount64);
  // ATSynEdit: CaretPosToClientPos returns caret pixel position
  fDblClickMousePos := Point(fText.Carets[0].PosX, fText.Carets[0].PosY);

  // Clear error line highlight on double-click
  if fErrorLine <> -1 then begin
    for i := 0 to fText.Strings.Bookmarks2.Count - 1 do begin
      if fText.Strings.Bookmarks2[i]^.Data.LineNum = fErrorLine - 1 then begin
        if fErrorWasBreakpoint then
          fText.Strings.Bookmarks2[i]^.Data.Kind := BK_BREAKPOINT
        else
          fText.Strings.Bookmarks2.Delete(i);
        Break;
      end;
    end;
    fErrorLine := -1;
    fErrorWasBreakpoint := False;
    UpdateCurrentLineMarker;
    fText.Invalidate;
  end;

  AHandled := False; // Let default double-click behavior (word selection) proceed
end;

procedure TEditor.EditorClick(Sender: TObject);
var
  fTripleClickTime: Cardinal;
  fTripleClickMousePos: TPoint; // ATSynEdit: TPoint instead of TBufferCoord
begin
  fTripleClickTime := GetTickCount64;
  fTripleClickMousePos := Point(fText.Carets[0].PosX, fText.Carets[0].PosY);
  if (fTripleClickTime > fDblClickTime) and
    (fTripleClickTime - GetDoubleClickTime < fDblClickTime) and
    (fTripleClickMousePos.X = fDblClickMousePos.X) and
    (fTripleClickMousePos.Y = fDblClickMousePos.Y) then begin

    // ATSynEdit: triple-click selects current line using DoSelect_Line
    if fText.Carets[0].PosY < fText.Strings.Count then begin
      fText.DoSelect_Line(Point(fText.Carets[0].PosX, fText.Carets[0].PosY));
    end else begin
      fText.DoSelect_Line(Point(fText.Carets[0].PosX, fText.Carets[0].PosY));
    end;
  end;
end;

procedure TEditor.EditorMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  s: String = '';
  p: TPoint; // ATSynEdit: TPoint (0-based) instead of TBufferCoord
  st: PStatement;
  M: TMemoryStream;
  Reason: THandPointReason = hprNone;
  IsIncludeLine: boolean;

  procedure ShowFileHint;
  var
    FileName: String;
  begin
    FileName := AnsiString(MainForm.CppParser.GetHeaderFileName(fFileName, UnicodeString(s)));
    if (FileName <> '') and FileExists(FileName) then begin
      MainForm.SetStatusbarMessage(Format('%s - %s', [FileName, Lang[ID_MSG_CLICKFORMOREINFO]]));
      //fText.Hint := FileName + ' - ' + Lang[ID_MSG_CLICKFORMOREINFO]
    end
    else
      fText.Hint := '';

  end;

  procedure ShowDebugHint;
  begin
    // Add to list
    if devData.WatchHint then
      MainForm.Debugger.AddWatchVar(s);

    // Evaluate s
    fCurrentEvalWord := s; // remember name when debugger finishes
    MainForm.Debugger.OnEvalReady := @OnMouseOverEvalReady;
    MainForm.Debugger.SendCommand('print', s, true);
  end;

  procedure ShowParserHint;
  var
    msg: String;
  begin
    M := TMemoryStream.Create;
    try
      fText.Strings.SaveToStream(M, TATFileEncoding.ANSI, true);
      // ATSynEdit: p.Y+1 converts 0-based to 1-based line
      st := MainForm.CppParser.FindStatementOf(AnsiString(fFileName), s, p.Y + 1, M);
    finally
      M.Free;
    end;

    if Assigned(st) then begin
      //fText.Hint := MainForm.CppParser.PrettyPrintStatement(st) + ' - ' + ExtractFileName(st^._FileName) +
      //  ' (' + IntToStr(st^._Line) + ') - ' + Lang[ID_MSG_CLICKFORMOREINFO];
      //fText.Hint := StringReplace(fText.Hint, '|', #5, [rfReplaceAll]);
      msg := MainForm.CppParser.PrettyPrintStatement(st) + ' - ' + ExtractFileName(st^._FileName) +
        ' (' + IntToStr(st^._Line) + ')';
      MainForm.SetStatusbarMessage(Format('%s - %s', [msg, Lang[ID_MSG_CLICKFORMOREINFO]]));
    end;
  end;

  procedure CancelHint;
  begin
    MainForm.Debugger.OnEvalReady := nil;

    // disable editor hint
    Application.CancelHint;
    fCurrentWord := '';
    fText.Hint := '';

    // disable page control hint
    MainForm.CurrentPageHint := '';
    fTabSheet.PageControl.Hint := '';
  end;
begin
  // Initialize p from current caret position
  p := Point(fText.Carets[0].PosX, fText.Carets[0].PosY);

  //exit; //debug

  // Leverage Ctrl-Clickability to determine if we can show any information
  Reason := HandpointAllowed(p, Shift);

  // Get subject
  IsIncludeLine := False;
  s := '';
  case Reason of
    // When hovering above a preprocessor line, determine if we want to show an include or a identifier hint
    hprPreprocessor: begin
        // ATSynEdit: p.Y is 0-based, Lines[] is 0-based
        s := AnsiString(fText.Strings.Lines[p.Y]);
        IsIncludeLine := MainForm.CppParser.IsIncludeLine(UnicodeString(s)); // show filename hint
        if not IsIncludeLine then
          // ATSynEdit: TextCurrentWord returns word under caret
          s := AnsiString(fText.TextCurrentWord);
      end;
    hprIdentifier: begin
        if MainForm.Debugger.Executing then
          s := GetWordAtPosition(p, wpEvaluation) // debugging
        else if devEditor.ParserHints and not fCompletionBox.Visible then
          s := GetWordAtPosition(p, wpInformation) // information during coding
        else
          s := '';
      end;
    hprSelection: begin
        s := AnsiString(fText.TextSelected); // ATSynEdit: use TextSelected instead of SelText
      end;
    hprNone: begin
        fText.Cursor := crIBeam;
        CancelHint;
      end;
  end;

  // Don't rescan the same stuff over and over again (that's slow)
  if s = fCurrentWord then
    Exit; // do NOT remove hint when subject stays the same

  // Remove hint
  CancelHint;
  fCurrentWord := s;

  // We are allowed to change the cursor
  if (ssCtrl in Shift) then
    fText.Cursor := crHandPoint
  else
    fText.Cursor := crIBeam;

  // Determine what to do with subject
  case Reason of
    hprPreprocessor: begin
        if IsIncludeLine then
          ShowFileHint
        else if devEditor.ParserHints and not fCompletionBox.Visible then
          ShowParserHint;
      end;
    hprIdentifier, hprSelection: begin
        if MainForm.Debugger.Executing then
          ShowDebugHint
        else if devEditor.ParserHints and not fCompletionBox.Visible then
          ShowParserHint;
      end;
  end;
end;

procedure TEditor.IndentSelection;
begin
  // ATSynEdit: use DoCommand with indent command
  if not fText.CaretsSel.IsEmpty then
    fText.DoCommand(cCommand_TextIndent, TATCommandInvoke(0), '')
  else
    fText.DoCommand(cCommand_KeyTab, TATCommandInvoke(0), '');
end;

procedure TEditor.UnindentSelection;
begin
  // ATSynEdit: use DoCommand with unindent command
  if not fText.CaretsSel.IsEmpty then
    fText.DoCommand(cCommand_TextUnindent, TATCommandInvoke(0), '')
  else
    fText.DoCommand(cCommand_KeyTab, TATCommandInvoke(0), '');
  // Shift+Tab not directly available as command, use unindent
end;

procedure TEditor.EditorMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  p: TPoint; // ATSynEdit: use TPoint for mouse position
  line, hdrFile: UnicodeString;
  e: TEditor;
begin
  // if ctrl+clicked
  if (ssCtrl in Shift) and (Button = mbLeft) and fText.CaretsSel.IsEmpty then begin

    // ATSynEdit: ClientPosToCaretPos requires TATPoint type which is not in scope.
    // Fall back to current caret position for Ctrl+Click navigation.
    p := Point(fText.Carets[0].PosX, fText.Carets[0].PosY);
    if p.Y < fText.Strings.Count then begin

      // reset the cursor
      fText.Cursor := crIBeam;

      // Try to open the header (p.Y is 0-based, Lines[] is 0-based)
      line := fText.Strings.Lines[p.Y];
      if MainForm.CppParser.IsIncludeLine(Line) then begin
        hdrFile := MainForm.CppParser.GetHeaderFileName(fFileName, line);
        e := MainForm.EditorList.GetEditorFromFileName(AnsiString(hdrFile));
        if Assigned(e) then begin
          e.SetCaretPosAndActivate(1, 1);
        end;
      end else
        MainForm.actGotoImplDeclEditorExecute(self);
    end;
  end;
end;

procedure TEditor.EditorMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
   MainForm.FormMouseWheel(Sender, Shift, WheelDelta, MousePos, Handled);
end;

// ATSynEdit migration: EditorPaintTransient was a SynEdit-specific paint callback.
// ATSynEdit uses OnDrawLine/OnDrawGap for custom painting.
// Bracket matching highlight is now handled by ATSynEdit natively via BracketHighlightEnabled.
// This method is kept as a stub for reference and removed from event binding.
procedure TEditor.EditorContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  // ATSynEdit.DoContextPopup always shows its built-in menus.
  // Setting Handled:=True skips that code path, then we manually show
  // our own popup menu so TControl.DoContextPopup doesn't fire.
  Handled := True;
  if Assigned(MainForm.EditorPopup) then
    MainForm.EditorPopup.PopUp;
end;

procedure TEditor.EditorPaintTransient(Sender: TObject; Canvas: TCanvas; TransientType: integer);
begin
  // Not implemented: ATSynEdit handles bracket matching natively.
  // See fText.OptShowBrackets and related options.
end;

function TEditor.HandpointAllowed(var MousePos: TPoint; ShiftState: TShiftState): THandPointReason;
var
  s: UnicodeString;
begin
  // ATSynEdit: Use caret position as mouse position approximation
  // Get the word under the caret for hover behavior
  MousePos := Point(fText.Carets[0].PosX, fText.Carets[0].PosY);

  // Check if we have a selection and the mouse is over it
  if not fText.CaretsSel.IsEmpty then begin
    Result := hprSelection; // allow selection
    Exit;
  end;

  // Safety: check that Lines is populated and caret is within valid range.
  // When a project is loaded, LoadUnitLayout may restore a cursor position
  // from an outdated or incompatible layout file, causing PosY to be out of
  // bounds. TextCurrentWord would then crash on Strings.Lines[Caret.PosY].
  if (fText.Strings.Count = 0)
    or (fText.Carets[0].PosY < 0)
    or (fText.Carets[0].PosY >= fText.Strings.Count) then begin
    Result := hprNone;
    Exit;
  end;

  // Use the current word to determine highlight type
  s := fText.TextCurrentWord;
  if s = '' then begin
    Result := hprNone;
    Exit;
  end;

  // Identify preprocessor directives
  if (Length(s) > 0) and (s[1] = '#') then
    Result := hprPreprocessor
  else
    Result := hprIdentifier;
end;

function TEditor.Save: boolean;
begin
  Result := True;

  // We will be changing files. Stop monitoring
  MainForm.FileMonitor.BeginUpdate;
  try

    // Is this file read-only?
    if FileExists(fFileName) and (FileGetAttr(fFileName) and faReadOnly <> 0) then begin

      // Yes, ask the user if he wants us to fix that
      if MessageDlg(Format(Lang[ID_MSG_FILEISREADONLY], [fFileName]), mtConfirmation, [mbYes, mbNo], 0) = mrNo then
        Exit;

      // Yes, remove read-only attribute
      if FileSetAttr(fFileName, FileGetAttr(fFileName) - faReadOnly) <> 0 then begin
        MessageDlg(Format(Lang[ID_MSG_FILEREADONLYERROR], [fFileName]), mtError, [mbOk], 0);
        Exit;
      end;
    end;

    // Filename already present? Save without dialog
    //if (not fNew) then begin //and fText.Modified then begin
    if (not fNew) and fModified then begin
      // Save contents directly
      try
        fText.Strings.SaveToFile(AnsiString(fFileName));
        fText.Modified := false;
        fModified := false;
        // Derive fFileEncoding from actual saved encoding (don't force to ANSI)
        if fText.Strings.Encoding = TATFileEncoding.UTF8 then
          if fText.Strings.SaveSignUtf8 then
            fFileEncoding := 1  // UTF-8 BOM
          else
            fFileEncoding := 2  // UTF-8 (no BOM)
        else
          fFileEncoding := 0;   // ANSI
        EditorStatusChange(Self);
        MainForm.UpdateEncodingStatus;
        MainForm.UpdateLineEndsStatus;
      except
        MessageDlg(Format(Lang[ID_ERR_SAVEFILE], [fFileName]), mtError, [mbOk], 0);
        Result := False;
      end;

      MainForm.CppParser.ParseFile(AnsiString(fFileName), InProject);
      MainForm.ClassBrowser.UpdateFromParser(MainForm.CppParser);
    end else if fNew then
      Result := SaveAs; // we need a file name, use dialog
  finally
    MainForm.FileMonitor.EndUpdate;
  end;
end;

function TEditor.SaveAs: boolean;
var
  UnitIndex: integer;
  SaveFileName: String;
begin
  Result := True;
  with TSaveDialog.Create(nil) do try
    Title := Lang[ID_NV_SAVEAS];
    Filter := BuildFilter([FLT_CS, FLT_CPPS, FLT_HEADS, FLT_RES, FLT_FORTRAN]);
    Options := Options + [ofOverwritePrompt];

    // select appropriate filter
    if GetFileTyp(AnsiString(fFileName)) in [utcHead, utcppHead] then begin
      FilterIndex := 4; // .h
      DefaultExt := 'h';
    end else begin
      if Assigned(MainForm.Project) and fInProject then begin
        if MainForm.Project.Options.useGPP then begin
          FilterIndex := 3; // .cpp
          DefaultExt := 'cpp';
        end else begin
          FilterIndex := 2; // .c
          DefaultExt := 'c';
        end;
      end else begin
        FilterIndex := 3; // .cpp
        DefaultExt := 'cpp';
      end;
    end;

    // Set save box options
    FileName := AnsiString(fFileName);
    if (fFileName <> '') then
      InitialDir := ExtractFilePath(AnsiString(fFileName))
    else if Assigned(MainForm.Project) then
      InitialDir := MainForm.Project.Directory;

    // Open the save box
    if Execute then
      SaveFileName := FileName // prevent collision between TEditor.FileName and Dialog.FileName
    else begin
      Result := False;
      Exit;
    end;
  finally
    Free;
  end;

  // Remove *old* file from statement list
  MainForm.CppParser.InvalidateFile(AnsiString(FileName));

  // Try to save to disk
  try
    fText.Strings.SaveToFile(SaveFileName);
    fText.Modified := False;
    fModified := False;
    fNew := False;
    // Derive fFileEncoding from actual saved encoding (don't force to ANSI)
    if fText.Strings.Encoding = TATFileEncoding.UTF8 then
      if fText.Strings.SaveSignUtf8 then
        fFileEncoding := 1  // UTF-8 BOM
      else
        fFileEncoding := 2  // UTF-8 (no BOM)
    else
      fFileEncoding := 0;   // ANSI
    MainForm.UpdateEncodingStatus;
    MainForm.UpdateLineEndsStatus;
  except
    MessageDlg(Lang[ID_ERR_SAVEFILE] + '"' + SaveFileName + '"', mtError, [mbOk], 0);
    Result := False;
  end;

  // Update highlighter
  devEditor.AssignEditor(fText, SaveFileName);

  // Update project information
  if Assigned(MainForm.Project) and Self.InProject then begin
    UnitIndex := MainForm.Project.Units.IndexOf(AnsiString(FileName)); // index of *old* filename
    if UnitIndex <> -1 then
      MainForm.Project.SaveUnitAs(UnitIndex, SaveFileName); // save as new filename
  end else
    UpdateCaption(ExtractFileName(SaveFileName));

  // Update window captions
  MainForm.UpdateAppTitle;

  // Update class browser, redraw once
  //MainForm.ClassBrowser.BeginUpdate;
//  MainForm.UpdateClassView;
  try
    MainForm.CppParser.ParseFile(SaveFileName, InProject);
    MainForm.ClassBrowser.CurrentFile := SaveFileName;
  finally
    //MainForm.ClassBrowser.EndUpdate;

  end;

  // Set new file name
  FileName := UnicodeString(SaveFileName);
end;

//https://blog.csdn.net/sensor_WU/article/details/125199637
//seems to be reversed True/False
{
function TEditor.is_UTF8_CODE(BB: TBytes): Boolean;
var
  B : Byte;
  Len,i : Int64;
  //D80 : Int64;
begin
  Result := True;
  Len := Length(BB);
  i := 0;
  while (i < Len - 1) do
    begin
      B := BB[i];
      if B < $80 then
        begin
          i := i + 1;
          Continue;
        end;
      if B < $C0 then  // (11000000):
        begin
          Exit(False);
        end;

      if B < $E0 then  // (11100000):
        begin
          if i >= (Len - 1) then  Exit(False);
          if (BB[ i + 1 ] and $C0) <> $80 then Exit(False);
          i := i + 2;
        end;

      if B < $F0 then  // (11110000):
        begin
          if i >= (Len - 1 - 1) then  Exit(False);
          if ((BB[ i + 1 ] and $C0) <> $80) and ((BB[ i + 2 ] and $C0) <> $80) then Exit(False);
          i := i + 3;
        end
      else
        Exit(False);
    end;

end;
}

function TEditor.GetFileEncodingName: String;
begin
  case fFileEncoding of
    1: Result := 'UTF-8 BOM';
    2: Result := 'UTF-8';
  else
    Result := 'ANSI';
  end;
end;

function TEditor.GetFileLineEndsName: String;
var
  i: integer;
  nCR, nLF, nCRLF: integer;
  le: TATLineEnds;
begin
  nCR := 0;
  nLF := 0;
  nCRLF := 0;
  for i := 0 to fText.Strings.Count - 1 do
  begin
    le := fText.Strings.LinesEnds[i];
    case le of
      TATLineEnds.Windows: Inc(nCRLF);
      TATLineEnds.Unix: Inc(nLF);
      TATLineEnds.Mac: Inc(nCR);
    end;
  end;
  if (nCRLF >= nLF) and (nCRLF >= nCR) and (nCRLF > 0) then
    Result := 'CR+LF'
  else if (nLF >= nCR) and (nLF > 0) then
    Result := 'LF'
  else if nCR > 0 then
    Result := 'CR'
  else begin
    // No line endings in content (empty/new file): use Strings.Endings as default.
    // On Windows, Endings = TATLineEnds.Windows (CRLF); on Unix, TATLineEnds.Unix (LF).
    case fText.Strings.Endings of
      TATLineEnds.Windows: Result := 'CR+LF';
      TATLineEnds.Unix: Result := 'LF';
      TATLineEnds.Mac: Result := 'CR';
    else
      Result := 'CR+LF'; // safe fallback
    end;
  end;
end;

function TEditor.GetFileLineEndsIndex: integer;
var
  i: integer;
  nCR, nLF, nCRLF: integer;
  le: TATLineEnds;
begin
  nCR := 0;
  nLF := 0;
  nCRLF := 0;
  for i := 0 to fText.Strings.Count - 1 do
  begin
    le := fText.Strings.LinesEnds[i];
    case le of
      TATLineEnds.Windows: Inc(nCRLF);
      TATLineEnds.Unix: Inc(nLF);
      TATLineEnds.Mac: Inc(nCR);
    end;
  end;
  if (nCRLF >= nLF) and (nCRLF >= nCR) and (nCRLF > 0) then
    Result := 0  // CR+LF (Windows)
  else if (nLF >= nCR) and (nLF > 0) then
    Result := 1  // LF (Unix)
  else if nCR > 0 then
    Result := 0  // CR (rare) - default to Windows on Windows platform
  else begin
    // No line endings in content (empty/new file): use Strings.Endings as default
    case fText.Strings.Endings of
      TATLineEnds.Windows: Result := 0;
      TATLineEnds.Unix: Result := 1;
    else
      Result := 0; // safe fallback
    end;
  end;
end;

procedure TEditor.ConvertLineEnds(newLineEndsIndex: integer);
// newLineEndsIndex: 0=CR+LF (Windows), 1=LF (Unix)
var
  fs: TFileStream;
  le: TATLineEnds;
begin
  if fNew or (fFileName = '') then Exit;

  // Map integer index to TATLineEnds
  case newLineEndsIndex of
    0: le := TATLineEnds.Windows;
    1: le := TATLineEnds.Unix;
  else
    le := TATLineEnds.Windows;
  end;

  if fText.Strings.Endings = le then Exit; // no change needed

  try
    // SetEndings also converts all existing line endings to the new type
    fText.Strings.Endings := le;

    fs := TFileStream.Create(AnsiString(fFileName), fmCreate);
    try
      fText.Strings.SaveToStream(fs, fText.Strings.Encoding, fText.Strings.SaveSignUtf8);
    finally
      fs.Free;
    end;

    fText.Modified := false;
    fModified := false;
    MainForm.UpdateEncodingStatus;
    MainForm.UpdateLineEndsStatus;
  except
    on E: Exception do
      MessageDlg(Lang[ID_ERR_SAVEFILE] + '"' + AnsiString(fFileName) + '"', mtError, [mbOk], 0);
  end;
end;

procedure TEditor.ConvertEncoding(newEncoding: integer);
var
  fs: TFileStream;
  oldEncoding: integer;
  enc: TATFileEncoding;
  withBOM: boolean;
begin
  if fNew or (fFileName = '') then Exit;
  if newEncoding = fFileEncoding then Exit; // no change needed

  oldEncoding := fFileEncoding;

  case newEncoding of
    1: begin // UTF-8 BOM
      enc := TATFileEncoding.UTF8;
      withBOM := True;
    end;
    2: begin // UTF-8
      enc := TATFileEncoding.UTF8;
      withBOM := False;
    end;
  else // 0: ANSI
    enc := TATFileEncoding.ANSI;
    withBOM := False;
  end;

  try
    fs := TFileStream.Create(AnsiString(fFileName), fmCreate);
    try
      fText.Strings.SaveToStream(fs, enc, withBOM);
    finally
      fs.Free;
    end;

    // Update ATSynEdit's internal encoding so subsequent SaveToFile uses the new encoding
    fText.Strings.Encoding := enc;
    fText.Strings.SaveSignUtf8 := withBOM;

    fFileEncoding := newEncoding;
    MainForm.UpdateEncodingStatus;
    MainForm.UpdateLineEndsStatus;
  except
    fFileEncoding := oldEncoding; // restore on failure
    raise;
  end;
end;

end.

