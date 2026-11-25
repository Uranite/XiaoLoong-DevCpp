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

unit FormatterOptFrm;

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ELSE}
  LCLType,
{$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ExtCtrls, ComCtrls, Spin, ATSynEdit, Editor;

type
  TFormatterOptForm = class(TForm)
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    btnHelp: TBitBtn;
    lblBracketStyle: TLabel;
    cmbBracketStyle: TComboBox;
    synExample: TATSynEdit;
    cmbIndentStyle: TComboBox;
    lblIndentStyle: TLabel;
    grpOptions: TGroupBox;
    lblPoweredBy: TLabel;
    lblTabWidth: TLabel;
    spinTabWidth: TSpinEdit;
    lblCommand: TLabel;
    bvCustom: TBevel;
    lblPreview: TLabel;
    chkClasses: TCheckBox;
    chkSwitches: TCheckBox;
    chkNamespace: TCheckBox;
    chkCases: TCheckBox;
    chkLabels: TCheckBox;
    chkPreprocessor: TCheckBox;
    lblIndentParts: TLabel;
    memFullCommand: TMemo;
    spinMaxLineLength: TSpinEdit;
    chkMaxLineLength: TCheckBox;
    chkAutoFormat: TCheckBox;
    chkAdjustSpaces: TCheckBox;
    chkAdjustLines: TCheckBox;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OptionChange(Sender: TObject);
    procedure CommandChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lblPoweredByClick(Sender: TObject);
  private
    fCreating: Boolean;
    fValid: Boolean;
    procedure LoadText;
    procedure LoadSettings;
    procedure LoadSampleText;
    procedure CreateScratchFile;
    procedure SaveSettings;
    function GetFullCommand: String;
  end;

implementation

uses
  LCLIntf, Main, devcfg, MultiLangSupport;

{$R *.lfm}

procedure TFormatterOptForm.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormatterOptForm.btnOkClick(Sender: TObject);
begin
  SaveSettings;
end;


procedure TFormatterOptForm.btnHelpClick(Sender: TObject);
begin
  if fValid then
    OpenURL(devDirs.Exec + devFormatter.AStyleDir + 'doc' + PathDelim + 'astyle.html');
    //  nil,
    //  nil,
    //  SW_SHOWNORMAL);
end;

procedure TFormatterOptForm.LoadText;
begin
  // Set interface font
  Font.Name := devData.InterfaceFont;
  Font.Size := devData.InterfaceFontSize;

  Caption := Lang[ID_FORMATTER_WINDOW];
  chkAutoFormat.Caption := Lang[ID_FORMATTER_AUTOFORMAT];
  grpOptions.Caption := Lang[ID_FORMATTER_OPTIONS];
  lblBracketStyle.Caption := Lang[ID_FORMATTER_BRACKET];
  lblIndentStyle.Caption := Lang[ID_FORMATTER_INDENT];
  lblTabWidth.Caption := Lang[ID_FORMATTER_TABWIDTH];
  chkMaxLineLength.Caption := Lang[ID_FORMATTER_MAXLINELENGTH];
  chkAdjustLines.Caption := Lang[ID_FORMATTER_LINES];
  chkAdjustSpaces.Caption := Lang[ID_FORMATTER_SPACES];
  lblIndentParts.Caption := Lang[ID_FORMATTER_INDENTPARTS];
  chkClasses.Caption := Lang[ID_FORMATTER_CLASSES];
  chkSwitches.Caption := Lang[ID_FORMATTER_SWITCHES];
  chkCases.Caption := Lang[ID_FORMATTER_CASES];
  chkNamespace.Caption := Lang[ID_FORMATTER_NAMESPACE];
  chkLabels.Caption := Lang[ID_FORMATTER_LABELS];
  chkPreprocessor.Caption := Lang[ID_FORMATTER_PREPROC];
  lblCommand.Caption := Lang[ID_FORMATTER_COMMAND];
  lblPreview.Caption := Lang[ID_FORMATTER_PREVIEW];
  btnOk.Caption := Lang[ID_BTN_OK];
  btnCancel.Caption := Lang[ID_BTN_CANCEL];
  btnHelp.Caption := Lang[ID_BTN_HELP];
  if fValid then
    lblPoweredBy.Caption := Format(Lang[ID_FORMATTER_POWEREDBY], [devFormatter.GetVersion])
  else
    lblPoweredBy.Caption := Lang[ID_FORMATTER_POWEREDBYFAIL];
end;

procedure TFormatterOptForm.FormCreate(Sender: TObject);
begin
  fCreating := True; // prevents spamming of astyle commands when initializing UI
  try
    // If we cannot find AStyle, only issue a warning
    if not devFormatter.Validate then begin
      fValid := False;
      MessageDlg(Lang[ID_FORMATTER_NOTVALID], mtWarning, [mbOK], 0);
    end else
      fValid := True;

    // Translate
    LoadText;

    // Load dummy text from current file or dummy file
    LoadSampleText;

    // Create scratch file
    CreateScratchFile;

    // Load settings
    LoadSettings;
  finally
    fCreating := False;
  end;
end;

procedure TFormatterOptForm.LoadSampleText;
var
  e: TEditor;
  FileName: String;
begin
  // Create a rough copy of the current file
  e := MainForm.EditorList.GetEditor;
  if Assigned(e) then begin
    FileName := AnsiString(e.FileName);
    synExample.Text := e.Text.Text;
  end else
    FileName := 'main.cpp';
  devEditor.AssignEditor(synExample, FileName);
  synExample.Font.Size := devData.InterfaceFontSize;
  // TODO: ATSynEdit - Gutter.Font not available
  //synExample.Gutter.Font.Size := devData.InterfaceFontSize;
  synExample.BorderStyle := bsSingle;
end;

procedure TFormatterOptForm.CreateScratchFile;
begin
  synExample.Strings.SaveToFile(
    devDirs.Exec + devFormatter.AStyleDir + 'DummyInput.txt');
end;

procedure TFormatterOptForm.LoadSettings;
begin
  with devFormatter do begin

    chkAutoFormat.Checked := devData.AutoFormat;

    // Set bracket style
    cmbBracketStyle.ItemIndex := BracketStyle;

    // Set indent style
    cmbIndentStyle.ItemIndex := IndentStyle;

    // Set tab width
    spinTabWidth.Value := OptTabSize;

    // Set max line length
    chkMaxLineLength.Checked := ModifyMaxLineLength;
    spinMaxLineLength.Value := MaxLineLength;

    // Adjust lines and spaces
    chkAdjustLines.Checked := AdjustLines;
    chkAdjustSpaces.Checked := AdjustSpaces;

    // Set indentation options
    chkClasses.Checked := IndentClasses;
    chkSwitches.Checked := IndentSwitches;
    chkNamespace.Checked := IndentNamespaces;
    chkLabels.Checked := IndentLabels;
    chkPreprocessor.Checked := IndentPreprocessor;

    // Set full command
    memFullCommand.Text := FullCommand;
  end;
end;

procedure TFormatterOptForm.SaveSettings;
begin
  devData.AutoFormat := chkAutoFormat.Checked;
  with devFormatter do begin
    // Set bracket style
    BracketStyle := cmbBracketStyle.ItemIndex;

    // Set indent style
    IndentStyle := cmbIndentStyle.ItemIndex;

    // Set tab width
    OptTabSize := spinTabWidth.Value;

    // Set max line length
    ModifyMaxLineLength := chkMaxLineLength.Checked;
    MaxLineLength := spinMaxLineLength.Value;

    // Adjust lines and spaces
    AdjustLines := chkAdjustLines.Checked;
    AdjustSpaces := chkAdjustSpaces.Checked;

    // Set indentation options
    IndentClasses := chkClasses.Checked;
    IndentSwitches := chkSwitches.Checked;
    IndentNamespaces := chkNamespace.Checked;
    IndentLabels := chkLabels.Checked;
    IndentPreprocessor := chkPreprocessor.Checked;

    // Set full command
    FullCommand := memFullCommand.Text;
  end;
end;

procedure TFormatterOptForm.OptionChange(Sender: TObject);
begin
  if fCreating then
    Exit;

  // Update UI
  memFullCommand.Text := GetFullCommand;
end;

procedure TFormatterOptForm.CommandChange(Sender: TObject);
var
  //AStyleOutput: String;
  DummyFileName: String;
begin
  if fCreating then
    Exit;
  // Apply to dummy file
  DummyFileName := devDirs.Exec + devFormatter.AStyleDir + 'DummyInput.txt';
  //AStyleOutput := devFormatter.FormatFile(DummyFileName, memFullCommand.Text);
  devFormatter.FormatFile(DummyFileName, memFullCommand.Text);

  // Check if formatting finished correctly
  if FileExists(DummyFileName) then begin
    synExample.Strings.LoadFromFile(DummyFileName, []);
  end else
    synExample.Text := UnicodeString(Format(Lang[ID_FORMATTER_LOADERROR], [DummyFileName]));
end;

// copy of TdevFormatter.GetFullCommand

function TFormatterOptForm.GetFullCommand: String;
begin
  Result := '';

  // Add bracket style
  if cmbBracketStyle.ItemIndex > 0 then begin
    if (cmbBracketStyle.ItemIndex <= 12) then
      Result := Result + ' -A' + IntToStr(cmbBracketStyle.ItemIndex)
    else
        Result := Result + ' -A' + IntToStr(cmbBracketStyle.ItemIndex +1);
  end;

//  Result := StringReplace(Result, 'A13', 'A12', [rfReplaceAll]);

  // Add indent style and tab width
  case cmbIndentStyle.ItemIndex of
    1: Result := Result + ' --indent=spaces=' + IntToStr(spinTabWidth.Value);
    2: Result := Result + ' --indent=tab=' + IntToStr(spinTabWidth.Value);
    3: Result := Result + ' --indent=force-tab=' + IntToStr(spinTabWidth.Value);
    4: Result := Result + ' --indent=force-tab-x=' + IntToStr(spinTabWidth.Value);
  end;

  // Add line length
  if chkMaxLineLength.Checked then begin
    if spinMaxLineLength.Text <> '' then
      Result := Result + ' --max-code-length=' + IntToStr(spinMaxLineLength.Value)
    else
      Result := Result + ' --max-code-length=' + IntToStr(spinMaxLineLength.MinValue);
  end;


  if chkAdjustLines.Checked then begin
    Result := Result + ' --break-one-line-headers';   // if () aaa
    //Result := Result + ' --break-blocks';             // empty lines
  end;

  if chkAdjustSpaces.Checked then begin
    Result := Result + ' --pad-oper';                 //add space around identifier
    Result := Result + ' --pad-include'; //add space padding after include directives. AStyle v3.6
    Result := Result + ' --pad-header';               //add space between if��while and (
    Result := Result + ' --align-pointer=name';       //*, ^  close to identifier
    Result := Result + ' --align-reference=name';     //&   close to identifier
  end;

   // Add indentation options
  if chkClasses.Checked then
    Result := Result + ' --indent-classes';
  if chkSwitches.Checked then
    Result := Result + ' --indent-switches';
  if chkCases.Checked then
    Result := Result + ' --indent-cases';
  if chkNamespace.Checked then
    Result := Result + ' --indent-namespaces';
  if chkLabels.Checked then
    Result := Result + ' --indent-labels';
  if chkPreprocessor.Checked then
    Result := Result + '  --indent-preproc-block';    //' --indent-preprocessor';

//  Result := Result + ' --exclude="Makefile.mk"';  //exclude makefile

  Result := TrimLeft(Result);
end;

procedure TFormatterOptForm.lblPoweredByClick(Sender: TObject);
begin
  OpenURL('http://astyle.sourceforge.net/');
end;

procedure TFormatterOptForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
end;

procedure TFormatterOptForm.FormActivate(Sender: TObject);
begin
  ActiveControl := nil;
end;

procedure TFormatterOptForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    btnCancel.Click;
  end;
end;

end.

