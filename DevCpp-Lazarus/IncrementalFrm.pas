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

unit IncrementalFrm;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ActnList, ATSynEdit, ExtCtrls, Menus;

type
  // Local types for ATSynEdit search compatibility
  TATSearchOption = set of (ssoMatchCase, ssoBackwards);
  TATSearchOptions = TATSearchOption;

const
  cSearchWrapAround: TATSearchOption = [];
  cSearchCaseSensitive: TATSearchOption = [ssoMatchCase];

type

  { TIncrementalForm }

  TIncrementalForm = class(TForm)
    Edit: TEdit;
    btnPrev: TButton;
    btnNext: TButton;
    IncrementalPop: TPopupMenu;
    IncrementalCut: TMenuItem;
    IncrementalCopy: TMenuItem;
    IncrementalPaste: TMenuItem;
    IncrementalSelAll: TMenuItem;
    IncrementalUndo: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    PanelGround: TPanel;
    procedure EditChange(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure IncrementalCutClick(Sender: TObject);
    procedure IncrementalCopyClick(Sender: TObject);
    procedure IncrementalPasteClick(Sender: TObject);
    procedure IncrementalSelAllClick(Sender: TObject);
    procedure IncrementalUndoClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditKeyPress(Sender: TObject; var Key: Char);
  private
    fOptions: TATSearchOption;
    fOriginalColor: TColor;
    fEditor: TATSynEdit;
    fSearchCaretOrigin: TPoint;
    fLastSearchText: string;
    procedure DoSearch(AResetCaret: Boolean);
    procedure SetEditor(value: TATSynEdit);
  public
    property Editor: TATSynEdit read fEditor write SetEditor;
  end;

var
  IncrementalForm: TIncrementalForm = nil;

implementation

{$R *.lfm}

uses
  main, MultilangSupport, ATSynEdit_Finder;

procedure TIncrementalForm.SetEditor(value: TATSynEdit);
begin
  fEditor := value;
end;

procedure TIncrementalForm.DoSearch(AResetCaret: Boolean);
var
  Finder: TATEditorFinder;
  Found: Boolean;
  AChanged: Boolean;
begin
  if Length(Edit.Text) = 0 then begin
    Edit.Color := fOriginalColor;
    Exit;
  end;

  // When text changes (typing more chars), reset caret to the original search origin
  // so we don't skip the first match
  if AResetCaret then begin
    fEditor.Carets[0].PosX := fSearchCaretOrigin.X;
    fEditor.Carets[0].PosY := fSearchCaretOrigin.Y;
  end;

  Finder := TATEditorFinder.Create;
  try
    Finder.Editor := fEditor;
    Finder.StrFind := UnicodeString(Edit.Text);
    Finder.OptCase := (ssoMatchCase in fOptions);
    Finder.OptBack := (ssoBackwards in fOptions);
    Finder.OptWrapped := True; // always wrap for incremental search
    Finder.OptFromCaret := True;

    Found := Finder.DoAction_FindOrReplace(False, False, AChanged, True);
    if Found then begin
      Edit.Color := fOriginalColor;
      fEditor.Invalidate;
    end else
      Edit.Color := clRed; // indicate "not found"
  finally
    Finder.Free;
  end;
end;

procedure TIncrementalForm.EditChange(Sender: TObject);
begin
  if Length(Edit.Text) > 0 then begin
    // Save original caret as search origin only on first typed character
    // Subsequent characters should reuse this origin to avoid skipping first match
    if (fLastSearchText = '') and Assigned(fEditor) then begin
      fSearchCaretOrigin.X := fEditor.Carets[0].PosX;
      fSearchCaretOrigin.Y := fEditor.Carets[0].PosY;
    end;
    fOptions := [];
    DoSearch(True);
    fLastSearchText := Edit.Text;
  end else begin
    Edit.Color := fOriginalColor;
    fLastSearchText := '';
  end;
end;

procedure TIncrementalForm.btnPrevClick(Sender: TObject);
begin
  if Length(Edit.Text) > 0 then begin
    // Update origin to current caret for subsequent nav operations
    if Assigned(fEditor) then begin
      fSearchCaretOrigin.X := fEditor.Carets[0].PosX;
      fSearchCaretOrigin.Y := fEditor.Carets[0].PosY;
    end;
    fOptions := [ssoBackwards];
    DoSearch(False);
  end;
end;

procedure TIncrementalForm.btnNextClick(Sender: TObject);
begin
  if Length(Edit.Text) > 0 then begin
    // Update origin to current caret for subsequent nav operations
    if Assigned(fEditor) then begin
      fSearchCaretOrigin.X := fEditor.Carets[0].PosX;
      fSearchCaretOrigin.Y := fEditor.Carets[0].PosY;
    end;
    fOptions := [];
    DoSearch(False);
  end;
end;

procedure TIncrementalForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
  IncrementalForm := nil;
end;

procedure TIncrementalForm.FormCreate(Sender: TObject);
begin
  if Assigned(MainForm) then
    MainForm.AssignMenuOwnerDrawHandlers(IncrementalPop.Items);
  Caption := Lang[ID_ITEM_INCREMENTAL];
  IncrementalUndo.Caption := Lang[ID_ITEM_UNDO];
  IncrementalCut.Caption := Lang[ID_ITEM_CUT];
  IncrementalCopy.Caption := Lang[ID_ITEM_COPY];
  IncrementalPaste.Caption := Lang[ID_ITEM_PASTE];
  IncrementalSelAll.Caption := Lang[ID_ITEM_SELECTALL];
end;

procedure TIncrementalForm.FormShow(Sender: TObject);
begin
  ActiveControl := Edit;
  fOriginalColor := Edit.Color;
  fLastSearchText := '';
end;

procedure TIncrementalForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Chr(VK_ESCAPE) then begin // Esc
    Key := #0; // Mute beep
    Close;
  end;
end;

procedure TIncrementalForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then begin
    Key := 0; // Stop processing by input window
    if Shift = [ssShift] then
      btnPrevClick(nil)
    else
      btnNextClick(nil);
  end;
end;

procedure TIncrementalForm.IncrementalUndoClick(Sender: TObject);
begin
  Edit.Undo;
end;

procedure TIncrementalForm.IncrementalCutClick(Sender: TObject);
begin
  Edit.CutToClipboard;
end;

procedure TIncrementalForm.IncrementalCopyClick(Sender: TObject);
begin
  Edit.CopyToClipboard;
end;

procedure TIncrementalForm.IncrementalPasteClick(Sender: TObject);
begin
  Edit.PasteFromClipboard;
end;

procedure TIncrementalForm.IncrementalSelAllClick(Sender: TObject);
begin
  Edit.SelectAll;
end;

procedure TIncrementalForm.EditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Chr(VK_RETURN) then
    Key := #0;
end;

end.

