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

unit FindFrm;

interface

uses
  Windows, editor, SysUtils, Classes, Graphics, Controls, Forms,
  ATSynEdit, StdCtrls, Clipbrd, ComCtrls, Menus,
  ExtCtrls, Buttons;

type
  // Local search types for ATSynEdit compatibility
  TATSearchOption = set of (ssoMatchCase, ssoBackwards, ssoWholeWord, ssoEntireScope,
    ssoSelectedOnly, ssoReplace, ssoReplaceAll, ssoPrompt);
  TATReplaceAction = (raReplace, raSkip, raAbort);
  TATReplaceTextEvent = procedure(Sender: TObject; const aSearch, aReplace: String;
    Line, Column: integer; var ReplaceAction: TATReplaceAction) of object;

const
  cSearchCaseSensitive: TATSearchOption = [ssoMatchCase];
  cSearchBackwards: TATSearchOption = [ssoBackwards];
  cSearchWholeWords: TATSearchOption = [ssoWholeWord];
  cSearchWrapAround: TATSearchOption = [ssoEntireScope];
  cSearchInSelection: TATSearchOption = [ssoSelectedOnly];
  cSearchReplace: TATSearchOption = [ssoReplace];
  cSearchReplaceAll: TATSearchOption = [ssoReplaceAll];
  cSearchPrompt: TATSearchOption = [ssoPrompt];

type
  TFindAction = (faFind, faFindFiles, faReplace, faReplaceFiles);

  { TFindForm }

  TFindForm = class(TForm)
    btnClose: TButton;
    btnFind: TButton;
    btnReplace: TButton;
    cbMatchCase: TCheckBox;
    cboFindText: TComboBox;
    cboReplaceText: TComboBox;
    cbPrompt: TCheckBox;
    cbSelectedOnly: TCheckBox;
    cbWholeWord: TCheckBox;
    FindPopup: TPopupMenu;
    FindCopy: TMenuItem;
    FindPaste: TMenuItem;
    FindCut: TMenuItem;
    FindTabs: TTabControl;
    grpDirection: TGroupBox;
    grpOptions: TGroupBox;
    grpOrigin: TGroupBox;
    grpScope: TGroupBox;
    grpWhere: TGroupBox;
    lblFind: TLabel;
    lblReplace: TLabel;
    N1: TMenuItem;
    FindSelAll: TMenuItem;
    PanelTabs: TPanel;
    PanelGround: TPanel;
    PanelGround: TPanel;
    rbBackward: TRadioButton;
    rbCurFile: TRadioButton;
    rbEntireScope: TRadioButton;
    rbForward: TRadioButton;
    rbFromCursor: TRadioButton;
    rbGlobal: TRadioButton;
    rbOpenFiles: TRadioButton;
    rbProjectFiles: TRadioButton;
    rbSelectedOnly: TRadioButton;
    procedure btnFindClick(Sender: TObject);
    procedure btnReplaceClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure FindTabsChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FindCutClick(Sender: TObject);
    procedure FindCopyClick(Sender: TObject);
    procedure FindPasteClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FindSelAllClick(Sender: TObject);
    procedure cboFindTextKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cboReplaceTextKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cboFindTextKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cboReplaceTextKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    fSearchOptions: TATSearchOption;
    fCurFile: String;
    fTabIndex: integer;
    fTempSynEdit: TATSynEdit;
    procedure LoadText;
    procedure FindAllAction(Sender: TObject; const aSearch, aReplace: String; Line, Column: integer; var ReplaceAction:
      TATReplaceAction);
    procedure FinderOnFound(Sender: TObject; APos1, APos2: TPoint);
    function Execute(editor: TATSynEdit; aFindAction: TFindAction): integer;
  public
    property TabIndex: integer read fTabIndex write fTabIndex;
  end;

var
  FindForm: TFindForm = nil;

implementation

uses
  Main, Dialogs, MultiLangSupport, devcfg, ATSynEdit_Finder;

{$R *.lfm}

function TFindForm.Execute(editor: TATSynEdit; aFindAction: TFindAction): integer;
var
  Finder: TATEditorFinder;
  AChanged: Boolean;
  Found: Boolean;
  //StartPos: TPoint;
  P: TPoint;
begin
  Result := 0;

  // Create the finder
  Finder := TATEditorFinder.Create;
  try
    Finder.Editor := editor;
    Finder.StrFind := UnicodeString(cboFindText.Text);
    Finder.StrReplace := UnicodeString(cboReplaceText.Text);

    // Set options from fSearchOptions (local type)
    Finder.OptCase := (ssoMatchCase in fSearchOptions);
    Finder.OptWords := (ssoWholeWord in fSearchOptions);
    Finder.OptBack := (ssoBackwards in fSearchOptions);
    Finder.OptWrapped := not (ssoEntireScope in fSearchOptions);
    Finder.OptFromCaret := not (ssoEntireScope in fSearchOptions);
    Finder.OptInSelection := (ssoSelectedOnly in fSearchOptions);
    Finder.OptConfirmReplace := (ssoPrompt in fSearchOptions);

    case aFindAction of
      faFindFiles, faReplaceFiles: begin
          // Set callback for adding results to the find output list
          Finder.OnFound := @FinderOnFound;
      end;
    end;

    case aFindAction of
      faFind: begin
          // Find first/next occurrence
          Found := Finder.DoAction_FindOrReplace(False, False, AChanged, True);
          if Found then begin
            Result := 1;
            // Scroll the editor so the found text becomes visible even when it
            // currently lies outside the visible area.
            P := Point(editor.Carets[0].PosX, editor.Carets[0].PosY);
            editor.DoShowPos(p, 3, 3, True, True, True);  //or DoGotoPos
          end else
            Result := 0;
        end;

      faReplace: begin
          // ATSynEdit semantics (TATEditorFinder.DoAction_ReplaceSelected):
          //  * if the current selection is exactly a match -> it is replaced,
          //    the function returns True and the caret is NOT moved on;
          //  * otherwise -> it searches and selects the next match and returns
          //    False (i.e. it has already advanced).
          // So only advance to the next match when a replacement actually
          // happened; searching again in the other case skips one occurrence.
          Found := Finder.DoAction_ReplaceSelected(True);
          if Found then begin
            Result := 1;
            if Finder.DoAction_FindOrReplace(False, False, AChanged, True) then
              Inc(Result);
          end else if Finder.MatchEdPos.Y >= 0 then
            // ReplaceSelected already found and selected the next occurrence
            Result := 1;

          if Result > 0 then begin
            //editor.DoShowCaret; // scroll the match into view
            P := Point(editor.Carets[0].PosX, editor.Carets[0].PosY);
            editor.DoShowPos(p, 3, 3, True, True, True);
          end;
        end;

      faFindFiles: begin
          // Count matches in the editor and add results
          Result := Finder.DoAction_CountAll(True);
        end;

      faReplaceFiles: begin
          // Replace all in the given editor
          Result := Finder.DoAction_ReplaceAll;
        end;
    end;
  finally
    Finder.Free;
  end;
end;

procedure TFindForm.btnFindClick(Sender: TObject);
var
  I, findcount: integer;
  e: TEditor;
  actiontype: TFindAction;
begin
  findcount := 0;
  case FindTabs.TabIndex of
    0: actiontype := faFind;
    1: actiontype := faFindFiles;
    2: actiontype := faReplace;
    3: actiontype := faReplaceFiles;
  else
    Exit;
  end;

  // Add input to history
  if (cboFindText.Text <> '') then begin
    if cboFindText.Items.IndexOf(cboFindText.Text) = -1 then
      cboFindText.AddItem(cboFindText.Text, nil);
  end else begin
    Application.MessageBox(PChar(Lang[ID_ERR_SEARCHCANNOTBEEMPTY]), PChar(Lang[ID_INFO]), MB_ICONINFORMATION or MB_TOPMOST);
    cboFindText.SetFocus;
    Exit;
  end;

  // Add nonempty strings to history
//  if (cboReplaceText.Text <> '') and (actiontype in [faReplace, faReplaceFiles]) then
//    if cboReplaceText.Items.IndexOf(cboReplaceText.Text) = -1 then
//      cboReplaceText.AddItem(cboReplaceText.Text, nil);

  fSearchOptions := [];

  // Apply options
  if cbMatchCase.Checked then
    Include(fSearchOptions, ssoMatchCase);
  if cbWholeWord.Checked then
    Include(fSearchOptions, ssoWholeWord);
  if cbPrompt.Checked or (actiontype = faFindFiles) then // do a fake prompted replace when using find in files
    Include(fSearchOptions, ssoPrompt);

  // Apply scope, when visible
  //if grpScope.Visible then begin
  //  if rbSelectedOnly.Checked then
  //    Include(fSearchOptions, ssoSelectedOnly);
  //end;
  if cbSelectedOnly.enabled and cbSelectedOnly.Checked then
    Include(fSearchOptions, ssoSelectedOnly);

  // Apply direction, when visible
  if grpDirection.Visible then begin
    if rbBackward.Checked then
      Include(fSearchOptions, ssoBackwards);
  end;

  // Apply origin, when visible
  if grpOrigin.Visible then begin
    if rbEntireScope.Checked then
      Include(fSearchOptions, ssoEntireScope);
  end;

  // Use entire scope for file finding/replacing
  if actiontype in [faFindFiles, faReplaceFiles] then
    Include(fSearchOptions, ssoEntireScope);

  // do a fake prompted replace when using find in files
  if actiontype in [faFindFiles, faReplace, faReplaceFiles] then
    Include(fSearchOptions, ssoReplace);

  if actiontype in [faFindFiles, faReplaceFiles] then
    Include(fSearchOptions, ssoReplaceAll);

  MainForm.FindOutput.Items.BeginUpdate;
  try
    //"Find" tab: Find the first one, then quit
    if actiontype = faFind then begin
      e := MainForm.EditorList.GetEditor;
      if Assigned(e) then begin
        Inc(findcount, Execute(e.Text, faFind));
        if findcount > 0 then begin
          e.Text.Invalidate;
          e.Text.SetFocus;
        end;
      end;

    //"Replace" tab: only find to next
    end else if actiontype = faReplace then begin
      e := MainForm.EditorList.GetEditor;
      if Assigned(e) then begin
        Exclude(fSearchOptions, ssoReplace);
        try
          Inc(findcount, Execute(e.Text, faFind));  //only find
        except
          on E: Exception do
            Application.MessageBox(PChar('Exception: ' + E.Message), PChar('Find Error'), MB_ICONERROR);
        end;
      end;

      //"Find in Files" or "Replace in Files": find everything
    end else begin
      // Enumerate results in message view when finding in files
      if actiontype = faFindFiles then
        MainForm.FindOutput.Clear;

      //Find in all opened files: loop through pagecontrol
      if rbOpenFiles.Checked then begin //
        // loop through editors, add results to message control
        for I := 0 to MainForm.EditorList.PageCount - 1 do begin
          e := MainForm.EditorList[i];
          if Assigned(e) then begin
            fCurFile := AnsiString(e.FileName);

            // Bring an editor up front if we use prompting
            if (actiontype = faReplaceFiles) and (ssoPrompt in fSearchOptions) then
              e.Activate;

            //Inc(findcount, Execute(e.Text, actiontype));
            Inc(findcount, Execute(e.Text, faFind)); //only find
          end;
        end;

        //Find in project: loop through project
      end else if rbProjectFiles.Checked then begin
        for I := 0 to MainForm.Project.Units.Count - 1 do begin
          e := MainForm.Project.Units[i].Editor;
          fCurFile := MainForm.Project.Units[i].FileName;

          // file is already open, use memory
          if Assigned(e) then begin
            // Bring an editor up front if we use prompting
            if (actiontype = faReplaceFiles) and (ssoPrompt in fSearchOptions) then
              e.Activate;

            //Inc(findcount, Execute(e.Text, actiontype));
            Inc(findcount, Execute(e.Text, faFind));  //only find
            // not open? load from disk
          end else if FileExists(fCurFile) then begin

            if (actiontype = faReplaceFiles) then begin

              // we have to open an editor...
              if ssoPrompt in fSearchOptions then begin
                e := MainForm.EditorList.GetEditorFromFileName(fCurFile);
                if Assigned(e) then begin
                  e.Activate;

                  //Inc(findcount, Execute(e.Text, actiontype));
                  Inc(findcount, Execute(e.Text, faFind));  //only find

                  // Save and close
                  e.Save;
                  MainForm.Project.CloseUnit(MainForm.Project.Units.Indexof(e));
                end;
              end else begin

                // Stealth replace
                // ATSynEdit: use Strings.LoadFromFile with options
                fTempSynEdit.Strings.LoadFromFile(fCurFile, []);
                //Inc(findcount, Execute(fTempSynEdit, actiontype));
                Inc(findcount, Execute(e.Text, faFind));  //only find
                fTempSynEdit.Strings.SaveToFile(fCurFile);
              end;
            end else begin

              // Only finding...
              // ATSynEdit: use Strings.LoadFromFile with options
              fTempSynEdit.Strings.LoadFromFile(fCurFile, []);
              //Inc(findcount, Execute(fTempSynEdit, actiontype));
              Inc(findcount, Execute(e.Text, faFind));  //only find
            end;
          end;
        end;

        // Don't loop, only pass single file
      end else if rbCurFile.Checked then begin
        e := MainForm.EditorList.GetEditor;

        if Assigned(e) then begin

          fCurFile := AnsiString(e.FileName);

          //Inc(findcount, Execute(e.Text, actiontype));
          Inc(findcount, Execute(e.Text, faFind));  //only find
        end;
      end;
    end;
  finally
    MainForm.FindOutput.Items.EndUpdate;
  end;

  if actiontype = faFindFiles then begin
    MainForm.MessageControl.ActivePageIndex := 4; // Find Tab
    MainForm.FindSheet.Caption := Lang[ID_SHEET_FIND] + ' (' + IntToStr(findcount) + ')';
    MainForm.OpenCloseMessageSheet(TRUE);
  end else if findcount = 0 then begin
    Application.MessageBox(PChar(Format(Lang[ID_MSG_TEXTNOTFOUND], [cboFindText.Text])), PChar(Lang[ID_INFO]), MB_ICONINFORMATION or MB_TOPMOST);
    cboFindText.SetFocus;
  end;

  if Self.Showing then
    btnFind.SetFocus;

end;

//In previous version before 7.0, "Find" and "Replace" are merged in one button.
//However, we need to seperate the two actions.
//"btnFindClick" and "btnReplaceClick" are very similar the each other.
//"btnFindClick" only do Findig job.
procedure TFindForm.btnReplaceClick(Sender: TObject);
var
  I, findcount: integer;
  e: TEditor;
  actiontype: TFindAction;
begin

  findcount := 0;

  case FindTabs.TabIndex of
    0: actiontype := faFind;
    1: actiontype := faFindFiles;
    2: actiontype := faReplace;
    3: actiontype := faReplaceFiles;
  else
    Exit;
  end;

  // Add input to history
  if (cboFindText.Text <> '') then begin
    if cboFindText.Items.IndexOf(cboFindText.Text) = -1 then
      cboFindText.AddItem(cboFindText.Text, nil);
  end else begin
    Application.MessageBox(PChar(Lang[ID_ERR_SEARCHCANNOTBEEMPTY]), PChar(Lang[ID_INFO]), MB_ICONINFORMATION or MB_TOPMOST);
    cboFindText.SetFocus;
    Exit;
  end;

  // Add nonempty strings to history
  if (cboReplaceText.Text <> '') and (actiontype in [faReplace, faReplaceFiles]) then
    if cboReplaceText.Items.IndexOf(cboReplaceText.Text) = -1 then
      cboReplaceText.AddItem(cboReplaceText.Text, nil);

  fSearchOptions := [];

  // Apply options
  if cbMatchCase.Checked then
    Include(fSearchOptions, ssoMatchCase);
  if cbWholeWord.Checked then
    Include(fSearchOptions, ssoWholeWord);
  if cbPrompt.Checked or (actiontype = faFindFiles) then // do a fake prompted replace when using find in files
    Include(fSearchOptions, ssoPrompt);

  // Apply scope, when visible
  //if grpScope.Visible then begin
  //  if rbSelectedOnly.Checked then
  //    Include(fSearchOptions, ssoSelectedOnly);
  //end;
  if cbSelectedOnly.enabled and cbSelectedOnly.Checked then
    Include(fSearchOptions, ssoSelectedOnly);

  // Apply direction, when visible
  if grpDirection.Visible then begin
    if rbBackward.Checked then
      Include(fSearchOptions, ssoBackwards);
  end;

  // Apply origin, when visible
  if grpOrigin.Visible then begin
    if rbEntireScope.Checked then
      Include(fSearchOptions, ssoEntireScope);
  end;

  // Use entire scope for file finding/replacing
  if actiontype in [faFindFiles, faReplaceFiles] then
    Include(fSearchOptions, ssoEntireScope);

  // do a fake prompted replace when using find in files
  if actiontype in [faFindFiles, faReplace, faReplaceFiles] then
    Include(fSearchOptions, ssoReplace);

  if actiontype in [faFindFiles, faReplaceFiles] then
    Include(fSearchOptions, ssoReplaceAll);

  MainForm.FindOutput.Items.BeginUpdate;
  try
    // Find the first one, then quit
    if actiontype = faFind then begin
      e := MainForm.EditorList.GetEditor;
      if Assigned(e) then begin
        Inc(findcount, Execute(e.Text, faFind));
        if findcount > 0 then begin
          e.Text.Invalidate;
          e.Text.SetFocus;
        end;
      end;

      // Replace first, find to next
    end else if actiontype = faReplace then begin
      e := MainForm.EditorList.GetEditor;

      if Assigned(e) then begin
        try
          Inc(findcount, Execute(e.Text, faReplace));
        except
          on E: Exception do
            Application.MessageBox(PChar('Exception: ' + E.Message), PChar('Find Error'), MB_ICONERROR);
        end;
        {
        if findcount > 0 then begin
          Exclude(fSearchOptions, ssoReplace);
          try
            Inc(findcount, Execute(e.Text, faFind));
          except
            on E: Exception do
              Application.MessageBox(PChar('Exception: ' + E.Message), PChar('Find Error'), MB_ICONERROR);
          end;
        end;
        }
      end;

      // Or find everything
    end else begin

      // Enumerate results in message view when finding in files
      if actiontype = faFindFiles then
        MainForm.FindOutput.Clear;

      // loop through pagecontrol
      if rbOpenFiles.Checked then begin

        // loop through editors, add results to message control
        for I := 0 to MainForm.EditorList.PageCount - 1 do begin
          e := MainForm.EditorList[i];
          if Assigned(e) then begin
            fCurFile := AnsiString(e.FileName);

            // Bring an editor up front if we use prompting
            if (actiontype = faReplaceFiles) and (ssoPrompt in fSearchOptions) then
              e.Activate;

            Inc(findcount, Execute(e.Text, actiontype));
          end;
        end;

        // loop through project
      end else if rbProjectFiles.Checked then begin
        for I := 0 to MainForm.Project.Units.Count - 1 do begin
          e := MainForm.Project.Units[i].Editor;
          fCurFile := MainForm.Project.Units[i].FileName;

          // file is already open, use memory
          if Assigned(e) then begin

            // Bring an editor up front if we use prompting
            if (actiontype = faReplaceFiles) and (ssoPrompt in fSearchOptions) then
              e.Activate;

            Inc(findcount, Execute(e.Text, actiontype));

            // not open? load from disk
          end else if FileExists(fCurFile) then begin

            if (actiontype = faReplaceFiles) then begin

              // we have to open an editor...
              if ssoPrompt in fSearchOptions then begin
                e := MainForm.EditorList.GetEditorFromFileName(fCurFile);
                if Assigned(e) then begin
                  e.Activate;

                  Inc(findcount, Execute(e.Text, actiontype));

                  // Save and close
                  e.Save;
                  MainForm.Project.CloseUnit(MainForm.Project.Units.Indexof(e));
                end;
              end else begin

                // Stealth replace
                // ATSynEdit: use Strings.LoadFromFile with options
                fTempSynEdit.Strings.LoadFromFile(fCurFile, []);
                Inc(findcount, Execute(fTempSynEdit, actiontype));
                fTempSynEdit.Strings.SaveToFile(fCurFile);
              end;
            end else begin

              // Only finding...
              // ATSynEdit: use Strings.LoadFromFile with options
              fTempSynEdit.Strings.LoadFromFile(fCurFile, []);
              Inc(findcount, Execute(fTempSynEdit, actiontype));
            end;
          end;
        end;

        // Don't loop, only pass single file
      end else if rbCurFile.Checked then begin
        e := MainForm.EditorList.GetEditor;

        if Assigned(e) then begin

          fCurFile := AnsiString(e.FileName);

          Inc(findcount, Execute(e.Text, actiontype));
        end;
      end;
    end;
  finally
    MainForm.FindOutput.Items.EndUpdate;
  end;

  if actiontype = faFindFiles then begin
    MainForm.MessageControl.ActivePageIndex := 4; // Find Tab
    MainForm.FindSheet.Caption := Lang[ID_SHEET_FIND] + ' (' + IntToStr(findcount) + ')';
    MainForm.OpenCloseMessageSheet(TRUE);
  end else if findcount = 0 then begin
    Application.MessageBox(PChar(Format(Lang[ID_MSG_TEXTNOTFOUND], [cboFindText.Text])), PChar(Lang[ID_INFO]), MB_ICONINFORMATION or MB_TOPMOST);
    cboFindText.SetFocus;
  end;

  if Self.Showing then
    btnFind.SetFocus;

end;

procedure TFindForm.FindAllAction(Sender: TObject; const aSearch, aReplace: String; Line, Column: integer; var
  ReplaceAction: TATReplaceAction);
//var
//  p: TPoint;
begin
//  p.X := Column - 1;  // 0-based
//  p.Y := Line - 1;  // 0-based
  //TODO: Maybe here is a bug related to 1-based or 0-based.

  // Convert to display coords
  MainForm.AddFindOutputItem(IntToStr(Line), IntToStr(Column), fCurFile,
    String(TATSynEdit(Sender).Strings.Lines[Line - 1]), aSearch);
  ReplaceAction := raSkip;
end;

procedure TFindForm.FinderOnFound(Sender: TObject; APos1, APos2: TPoint);
var
  Finder: TATEditorFinder;
  SenderEditor: TATSynEdit;
  SearchText: string = '';
begin
  SenderEditor := nil;
  if Sender is TATEditorFinder then begin
    Finder := TATEditorFinder(Sender);
    SenderEditor := Finder.Editor;
    SearchText := string(Finder.StrFind);
  end;

  if Assigned(SenderEditor) then begin
    // OnFound reports 0-based positions (verified), but every consumer of the
    // Find output list expects 1-based values:
    //   * FindOutputDblClick uses Lines[Line-1] and SetCaretPosAndActivate
    //     (both 1-based), and original Dev-C++ stored "Line"/"Column" 1-based;
    //   * the result list's bold highlight uses SubItems[1] as a 1-based
    //     character offset ("BoldStart").
    // So convert here: +1 for display, 0-based index for the line text.
    MainForm.AddFindOutputItem(
      IntToStr(APos1.Y + 1),     // Line (1-based)
      IntToStr(APos1.X + 1),     // Column (1-based)
      fCurFile,
      String(SenderEditor.Strings.Lines[APos1.Y]),
      SearchText);
  end;
end;

procedure TFindForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  // update devData
  devData.CaseSensitive := cbMatchCase.Checked;
  devData.Wholewords := cbWholeWord.Checked;
  devData.PromptReplace := cbPrompt.Checked;

  devData.ScopeIsSelected := cbSelectedOnly.Checked;
  devData.DirBackward := rbBackward.Checked;
  devData.OriginEntireScope := rbEntireScope.Checked;

  if rbProjectFiles.Checked then
    devData.SearchWhere := 0
  else if rbOpenFiles.Checked then
    devData.SearchWhere := 1
  else if rbCurFile.Checked then
    devData.SearchWhere := 2;

  // Save some memory
  fTempSynEdit.Strings.Clear;

  CloseAction := caHide;
end;

procedure TFindForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFindForm.FindTabsChange(Sender: TObject);
var
  isfind, isfindfiles, isreplace, isreplacefiles: boolean;
begin
  isfind := (FindTabs.TabIndex = 0);
  isfindfiles := (FindTabs.TabIndex = 1);
  isreplace := (FindTabs.TabIndex = 2);
  isreplacefiles := (FindTabs.TabIndex = 3);

  lblReplace.Visible := isreplace or isreplacefiles;
  cboReplaceText.Visible := isreplace or isreplacefiles;
  btnReplace.visible := isreplace or isreplacefiles;


  //grpOrigin.Visible := isfind or isreplace;
  //grpScope.Visible := isfind or isreplace;
  cbSelectedOnly.enabled := isfind or isreplace;
  grpWhere.Visible := isfindfiles or isreplacefiles;
  grpDirection.Visible := isfind or isreplace;
  // grpOption is always visible

  // Disable project search option when none is open
  rbProjectFiles.Enabled := Assigned(MainForm.Project);
  if not Assigned(MainForm.Project) then
    rbOpenFiles.Checked := true;

  // Disable prompt when doing finds
  cbPrompt.Enabled := isreplace or isreplacefiles;

  if not isreplace and not isreplacefiles then begin
    Caption := Lang[ID_FIND_FINDTAB];
    //btnFind.Caption := Lang[ID_BTN_FIND]
  end else begin
    Caption := Lang[ID_FIND_REPLACE];
    //btnFind.Caption := Lang[ID_BTN_REPLACE];
  end;
end;

procedure TFindForm.LoadText;
begin
  // Set interface font
  Font.Name := devData.InterfaceFont;
  Font.Size := devData.InterfaceFontSize;

  Caption := Lang[ID_FIND];

  //tabs
  FindTabs.Tabs.Clear;
  FindTabs.Tabs.Add(Lang[ID_FIND_FINDTAB]);
  FindTabs.Tabs.Add(Lang[ID_FIND_FINDALLTAB]);
  FindTabs.Tabs.Add(Lang[ID_FIND_REPLACE]);
  FindTabs.Tabs.Add(Lang[ID_FIND_REPLACEFILES]);

  //controls
  lblFind.Caption := Lang[ID_FIND_TEXT];
  lblReplace.Caption := Lang[ID_FIND_REPLACEWITH];
  grpOptions.Caption := Lang[ID_FIND_GRP_OPTIONS];
  cbMatchCase.Caption := Lang[ID_FIND_CASE];
  cbWholeWord.Caption := Lang[ID_FIND_WWORD];
  cbPrompt.Caption := Lang[ID_FIND_PROMPTREPLACE];

  grpWhere.Caption := Lang[ID_FIND_GRP_WHERE];
  rbProjectFiles.Caption := Lang[ID_FIND_PRJFILES];
  rbOpenFIles.Caption := Lang[ID_FIND_OPENFILES];
  rbCurFile.Caption := Lang[ID_FIND_CURRENTFILE];

  //grpScope.Caption := Lang[ID_FIND_GRP_SCOPE];
  //rbGlobal.Caption := Lang[ID_FIND_GLOBAL];
  //rbSelectedOnly.Caption := Lang[ID_FIND_SELONLY];
  cbSelectedOnly.Caption := Lang[ID_FIND_SELONLY];

  grpOrigin.Caption := Lang[ID_FIND_GRP_ORIGIN];
  rbFromCursor.Caption := Lang[ID_FIND_CURSOR];
  rbEntireScope.Caption := Lang[ID_FIND_ENTIRE];

  grpDirection.Caption := Lang[ID_FIND_GRP_DIRECTION];
  rbForward.Caption := Lang[ID_FIND_FORE];
  rbBackward.Caption := Lang[ID_FIND_BACK];

  //buttons
  btnFind.Caption := Lang[ID_BTN_FIND];
  btnReplace.Caption := Lang[ID_BTN_REPLACE];
  btnClose.Caption := Lang[ID_BTN_CLOSE];

  FindCut.Caption := Lang[ID_ITEM_CUT];
  FindCopy.Caption := Lang[ID_ITEM_COPY];
  FindPaste.Caption := Lang[ID_ITEM_PASTE];
  FindSelAll.Caption := Lang[ID_ITEM_SELECTALL];
end;

procedure TFindForm.FormCreate(Sender: TObject);
begin
  if Assigned(MainForm) then
    MainForm.AssignMenuOwnerDrawHandlers(FindPopup.Items);
  //LoadText;

  // Create a temporary editor for closed file searching
  fTempSynEdit := TATSynEdit.Create(Self);

  fTempSynEdit.WantTabs := devEditor.UseTabs;
  // ATSynEdit: use OptTabSize instead of TabWidth
  fTempSynEdit.OptTabSize := devEditor.TabSize;
end;

procedure TFindForm.FormShow(Sender: TObject);
begin
  LoadText;
  FindTabs.TabIndex := fTabIndex;

  // apply previous settings
  cbMatchCase.Checked := devData.CaseSensitive;
  cbWholeWord.Checked := devData.Wholewords;
  cbPrompt.Checked := devData.PromptReplace;

  cbSelectedOnly.Checked := devData.ScopeIsSelected;
  rbBackward.Checked := devData.DirBackward;
  rbEntireScope.Checked := devData.OriginEntireScope;

  case devData.SearchWhere of
    0: rbProjectFiles.Checked := true;
    1: rbOpenFIles.Checked := true;
    2: rbCurFile.Checked := true;
  end;

  ActiveControl := cboFindText;

  FindTabsChange(nil);
end;

procedure TFindForm.FindCutClick(Sender: TObject);
begin
  if cboFindText.Focused then begin
    Clipboard.AsText := cboFindText.SelText;
    cboFindText.SelText := '';
  end else if cboReplaceText.Focused then begin
    Clipboard.AsText := cboReplaceText.SelText;
    cboReplaceText.SelText := '';
  end;
end;

procedure TFindForm.FindCopyClick(Sender: TObject);
begin
  if cboFindText.Focused then
    Clipboard.AsText := cboFindText.SelText
  else if cboReplaceText.Focused then
    Clipboard.AsText := cboReplaceText.SelText;
end;

procedure TFindForm.FindPasteClick(Sender: TObject);
begin
  if cboFindText.Focused then
    cboFindText.SelText := Clipboard.AsText
  else if cboReplaceText.Focused then
    cboReplaceText.SelText := Clipboard.AsText;
end;

procedure TFindForm.FindSelAllClick(Sender: TObject);
begin
  if cboFindText.Focused then
    cboFindText.SelectAll
  else if cboReplaceText.Focused then
    cboReplaceText.SelectAll;
end;

procedure TFindForm.FormDestroy(Sender: TObject);
begin
  fTempSynEdit.Free;
end;


procedure TFindForm.cboFindTextKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_TAB then begin
    //cboFindText.SelText := #9;
    Key := 0; // prevent propagation
    if cboReplaceText.Visible then
      cboReplaceText.SetFocus
    else
      cbMatchCase.SetFocus;
   end;
end;

procedure TFindForm.cboFindTextKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//  if Key = VK_TAB then begin
//    cboFindText.SelText := #9;
//    Key := 0; // prevent propagation
//  end;
end;

procedure TFindForm.cboReplaceTextKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //if Key = VK_TAB then begin
  //  cboReplaceText.SelText := #9;
  //  Key := 0; // prevent propagation
  //end;
  if Key = VK_TAB then
  begin
    Key := 0;
    if Shift = [ssShift] then
      SelectNext(ActiveControl, False, True) //
    else
      SelectNext(ActiveControl, True, True); //
  end;

end;

procedure TFindForm.cboReplaceTextKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//  if Key = VK_TAB then begin
//    cboReplaceText.SelText := #9;
//    Key := 0; // prevent propagation
//  end;
end;

end.

