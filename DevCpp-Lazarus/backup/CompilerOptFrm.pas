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

unit CompilerOptFrm;

interface

uses
{$IFDEF MSWINDOWS}
  {$IFDEF MSWINDOWS}Windows{$ELSE}LCLIntf, LCLType{$ENDIF},
{$ELSE}
  LCLType,
{$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ExtCtrls, ComCtrls, Math;

type

  { TCompilerOptForm }

  TCompilerOptForm = class(TForm)
    btnAdd: TButton;
    btnBrowse: TSpeedButton;
    btnDelete: TButton;
    btnDelInval: TButton;
    btnDown: TSpeedButton;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    btnHelp: TBitBtn;
    btnReplace: TButton;
    btnUp: TSpeedButton;
    cbUninitialized: TCheckBox;
    cbVLA: TCheckBox;
    cbPedantic: TCheckBox;
    cbNoPie: TCheckBox;
    cbReturnType: TCheckBox;
    cmbOptimize: TComboBox;
    Commands: TEdit;
    edEntry: TEdit;
    lblOptimize: TLabel;
    lblOptimize1: TLabel;
    Linker: TEdit;
    //CompOptionsFrame1: TCompOptionsFrame;
    grpCompSet: TGroupBox;
    btnAddBlankCompilerSet: TSpeedButton;
    btnDelCompilerSet: TSpeedButton;
    btnRenameCompilerSet: TSpeedButton;
    btnFindCompilers: TSpeedButton;
    cmbCompilerSetComp: TComboBox;
    btnAddCompilerSet: TSpeedButton;
    lstDirs: TListBox;
    MainPages: TPageControl;
    Memo2: TMemo;
    Memo3: TMemo;
    Panel1: TPanel;
    PanelBack: TPanel;
    tabCompiler: TTabSheet;
    lblLangStd: TLabel;
    cbCompAdd: TCheckBox;
    cbLinkerAdd: TCheckBox;
    cbWall: TCheckBox;
    cbWextra: TCheckBox;
    cbProfile: TCheckBox;
    cbDebug: TCheckBox;
    cmbLangStd2: TComboBox;
    cbStatic: TCheckBox;
    tabSettings: TTabSheet;
    OptionsTip: TLabel;
    OptionsLink: TLabel;
    cbNoasm: TCheckBox;
    cbTradional: TCheckBox;
    cbShadow: TCheckBox;
    cbWfatal: TCheckBox;
    cbPipe: TCheckBox;
    cbStrip: TCheckBox;
    cbMaxerror: TCheckBox;
    tabDirectories: TTabSheet;
    DirTabs: TTabControl;
    tabPrograms: TTabSheet;
    lblProgramsText: TLabel;
    lblgcc: TLabel;
    lblgpp: TLabel;
    lblmake: TLabel;
    lblgdb: TLabel;
    lblwindres: TLabel;
    lblgprof: TLabel;
    btnBrowse2: TSpeedButton;
    btnBrowse3: TSpeedButton;
    btnBrowse4: TSpeedButton;
    btnBrowse5: TSpeedButton;
    btnBrowse6: TSpeedButton;
    btnBrowse8: TSpeedButton;
    GccEdit: TEdit;
    GppEdit: TEdit;
    MakeEdit: TEdit;
    GdbEdit: TEdit;
    WindresEdit: TEdit;
    GprofEdit: TEdit;
    cbANSI: TCheckBox;
    lblPtrWidth: TLabel;
    cmbPtrWidth: TComboBox;
    cbFloatEqual: TCheckBox;
    cmbLangStd: TComboBox;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure DirTabsChange(Sender: TObject);
    procedure lstDirsClick(Sender: TObject);
    procedure lstDirsDblClick(Sender: TObject);
    procedure edEntryChange(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure ButtonClick(Sender: TObject);
    procedure UpDownClick(Sender: TObject);
    procedure edEntryKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure btnBrws1Click(Sender: TObject);
    procedure cmbCompilerSetCompChange(Sender: TObject);
    procedure btnAddBlankCompilerSetClick(Sender: TObject);
    procedure btnDelCompilerSetClick(Sender: TObject);
    procedure btnRenameCompilerSetClick(Sender: TObject);
    procedure OptionsLinkClick(Sender: TObject);
    procedure cbCompAddClick(Sender: TObject);
    procedure cbLinkerAddClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure btnFindCompilersClick(Sender: TObject);
    procedure cmbCompilerSetCompEnter(Sender: TObject);
    procedure InterfaceChange(Sender: TObject);
    procedure InterfaceSave(Sender: TObject);
    procedure btnAddCompilerSetClick(Sender: TObject);
    procedure cbANSIClick(Sender: TObject);

  private
    fOldIndex: integer;
    fBinDirCopy: TStringList;
    fLibDirCopy: TStringList;
    fCDirCopy: TStringList;
    fCppDirCopy: TStringList;
    procedure LoadSet(Index: integer);
    procedure SaveSet(Index: integer);
    procedure UpdateButtons;
    procedure LoadText;
  end;

implementation

uses
  LCLIntf, version, devcfg, utils, MultiLangSupport;

{$R *.lfm}

procedure TCompilerOptForm.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TCompilerOptForm.btnOkClick(Sender: TObject);
var
  I: integer;
begin
  // Update names and current selection
  for I := 0 to cmbCompilerSetComp.Items.Count - 1 do
    devCompilerSets[i].Name := cmbCompilerSetComp.Items[i];
  devCompilerSets.DefaultSetIndex := cmbCompilerSetComp.ItemIndex;

  // Save the current set to disk
  SaveSet(cmbCompilerSetComp.ItemIndex);

  // Save list of sets only
  devCompilerSets.SaveSetList;
end;

procedure TCompilerOptForm.LoadSet(Index: integer);
var
  I, J: integer;
  option: TCompilerOption;
begin
  // Load the new set from disk or clear
  devCompilerSets.DefaultSetIndex := index;
  if index = -1 then begin // erase all
    fBinDirCopy.Clear;
    fCDirCopy.Clear;
    fCppDirCopy.Clear;
    fLibDirCopy.Clear;
    Commands.Text := '';
    Linker.Text := '';
    cbCompAdd.Checked := false;
    cbLinkerAdd.Checked := false;
    //cbAutoLink.Checked := false;
    GccEdit.Text := '';
    GppEdit.Text := '';
    GdbEdit.Text := '';
    MakeEdit.Text := '';
    WindresEdit.Text := '';
    GprofEdit.Text := '';
  end else begin

    // Apply the new set to the UI
    with devCompilerSets[index] do begin
      fBinDirCopy.Assign(BinDir); // use copies
      fCDirCopy.Assign(CDir);
      fCppDirCopy.Assign(CppDir);
      fLibDirCopy.Assign(LibDir);
      Commands.Text := CompOpts;
      Linker.Text := LinkOpts;
      cbCompAdd.Checked := AddtoComp;
      Commands.Enabled := AddtoComp;
      cbLinkerAdd.Checked := AddtoLink;
      Linker.Enabled := AddtoLink;
      //cbAutoLink.Checked := AutoLink;
      GccEdit.Text := gccName;
      GppEdit.Text := gppName;
      GdbEdit.Text := gdbName;
      MakeEdit.Text := makeName;
      WindresEdit.Text := windresName;
      GprofEdit.Text := gprofName;
    end;
  end;

  // fill options to controls
  for I := 0 to devCompilerSets[index].Options.Count - 1 do begin  //���뷽���еĸ���ѡ��
    option := PCompilerOption(devCompilerSets[index].Options[I])^;  //��ǰѡ��
    if SameStr(option.Setting, '-std=') then begin   //C standard
      lblLangStd.Caption := Lang[option.Name];
      for J := 0 to option.Choices.Count -1 do
         cmbLangStd.AddItem(option.Choices.Names[J], nil);
      cmbLangStd.ItemIndex := option.Value;
    end
    else if SameStr(option.Setting, '-std') then begin  //C++ standard
      for J := 0 to option.Choices.Count -1 do
         cmbLangStd2.AddItem(option.Choices.Names[J], nil);
      cmbLangStd2.ItemIndex := option.Value;
    end
    else if SameStr(option.Setting, '-ansi') then begin
      cbANSI.Caption := Lang[option.Name];
      cbANSI.Checked := Boolean(option.Value);
      cmbLangStd.Enabled := not cbANSI.checked;
      cmbLangStd2.Enabled := not cbANSI.Checked;
      if cbANSI.checked then begin
        cmbLangStd.ItemIndex := cmbLangStd.Items.IndexOf('ISO C90');
        cmbLangStd2.ItemIndex := cmbLangStd2.Items.IndexOf('ISO C++');
      end;
    end
    else if SameStr(option.Setting, '-') then begin
      lblPtrWidth.Caption := Lang[option.Name];
      for J := 0 to option.Choices.Count -1 do
         cmbPtrWidth.AddItem(option.Choices.Names[J], nil);
      cmbPtrWidth.ItemIndex := option.Value;
    end
    else if SameStr(option.Setting, '-static-libstdc++ -static-libgcc') then begin
      cbStatic.Caption := Lang[option.Name];
      cbStatic.Checked := Boolean(option.Value);
    end
    else if SameStr(option.Setting, '-g3') then begin
      cbDebug.Caption := Lang[option.Name];
      cbDebug.Checked := Boolean(option.Value);
    end
    else if SameStr(option.Setting, '-pg') then begin
      cbProfile.Caption := Lang[option.Name];
      cbProfile.Checked := Boolean(option.Value);
      //cbProfile.Caption := Lang[option.Name];  //invisible, no need to set caption
      cbNoPie.Checked := Boolean(option.Value);  //same with
    end
    else if SameStr(option.Setting, '-Wall') then begin
      cbWall.Caption := Lang[option.Name];
      cbWall.Checked := Boolean(option.Value);
    end
    else if SameStr(option.Setting, '-Wextra') then begin
      cbWextra.Caption := Lang[option.Name];
      cbWextra.Checked := Boolean(option.Value);
    end
    else if SameStr(option.Setting, '-fno-asm') then begin
      cbNoasm.Caption := Lang[option.Name];
      cbNoasm.Checked := Boolean(option.Value);
    end
    else if SameStr(option.Setting, '-traditional-cpp') then begin
      cbTradional.Caption := Lang[option.Name];
      cbTradional.Checked := Boolean(option.Value);
    end
    else if SameStr(option.Setting, '-O') then begin
      lblOptimize.Caption := Lang[option.Name];
      for J := 0 to option.Choices.Count -1 do
         cmbOptimize.AddItem(option.Choices.Names[J], nil);
      cmbOptimize.ItemIndex := option.Value;
    end
    else if SameStr(option.Setting, '-pedantic') then begin
      cbPedantic.Caption := Lang[option.Name];
      cbPedantic.Checked := Boolean(option.Value);
    end
    else if SameStr(option.Setting, '-Wshadow') then begin
      cbShadow.Caption := Lang[option.Name];
      cbShadow.Checked := Boolean(option.Value);
    end
    else if SameStr(option.Setting, '-Wfloat-equal') then begin
      cbFloatEqual.Caption := Lang[option.Name];
      cbFloatEqual.Checked := Boolean(option.Value);
    end
    else if SameStr(option.Setting, '-Werror=uninitialized') then begin
      cbUninitialized.Caption := Lang[option.Name];
      cbUninitialized.Checked := Boolean(option.Value);
    end
    else if SameStr(option.Setting, '-Werror=return-type') then begin
      cbReturnType.Caption := Lang[option.Name];
      cbReturnType.Checked := Boolean(option.Value);
    end
    else if SameStr(option.Setting, '-Werror=vla') then begin
      cbVLA.Caption := Lang[option.Name];
      cbVLA.Checked := Boolean(option.Value);
    end
    else if SameStr(option.Setting, '-Wfatal-errors') then begin
      cbWfatal.Caption := Lang[option.Name];
      cbWfatal.Checked := Boolean(option.Value);
    end
    else if SameStr(option.Setting, '-fmax-errors=10') then begin
      cbMaxerror.Caption := Lang[option.Name];
      cbMaxerror.Checked := Boolean(option.Value);
    end
    else if SameStr(option.Setting, '-s') then begin
      cbStrip.Caption := Lang[option.Name];
      cbStrip.Checked := Boolean(option.Value);
    end
    else if SameStr(option.Setting, '-pipe') then begin
      cbPipe.Caption := Lang[option.Name];
      cbPipe.Checked := Boolean(option.Value);
    end;
  end;

  //CompOptionsFrame1.FillOptions;     //discard by Anbangli, 2024

  DirTabsChange(Self);

  // Mark unmodified
  cmbCompilerSetComp.Tag := 0;
end;

procedure TCompilerOptForm.SaveSet(Index: integer);
var
  I: integer;
  option: TCompilerOption;
begin
  if (index >= devCompilerSets.Count) or (index < 0) then
    Exit;

  // Save the set to disk (can't be undone by Cancel...)
  with devCompilerSets[index] do begin
    // General
    AddtoComp := cbCompAdd.Checked;
    CompOpts := Commands.Text;
    AddtoLink := cbLinkerAdd.Checked;
    LinkOpts := Linker.Text;
    //AutoLink := cbAutoLink.Checked;

    // Directories
    BinDir.Assign(fBinDirCopy);
    LibDir.Assign(fLibDirCopy);
    CDir.Assign(fCDirCopy);
    CppDir.Assign(fCppDirCopy);

    // Programs
    gccName := GccEdit.Text;
    gppName := gppEdit.Text;
    makeName := MakeEdit.Text;
    gdbName := GdbEdit.Text;
    windresName := WindresEdit.Text;
    gprofName := GprofEdit.Text;
  end;

  //Options' value
  for I := 0 to devCompilerSets[index].Options.Count - 1 do begin  //���뷽���еĸ���ѡ��
    option := PCompilerOption(devCompilerSets[index].Options[I])^;  //��ǰѡ��
    if SameStr(option.Setting, '-std=') then begin
      option.Value := cmbLangStd.ItemIndex;
    end else if SameStr(option.Setting, '-std') then begin
      option.Value := cmbLangStd2.ItemIndex;
    end else if SameStr(option.Setting, '-') then begin
      option.Value := cmbPtrWidth.ItemIndex;
    end else if SameStr(option.Setting, '-static-libstdc++ -static-libgcc') then begin
      option.Value := Integer(cbStatic.Checked);
    end else if SameStr(option.Setting, '-g3') then begin
      option.Value := Integer(cbDebug.Checked);
    end else if SameStr(option.Setting, '-pg') then begin
      option.Value := Integer(cbProfile.Checked);
    end else if SameStr(option.Setting, '-no-pie') then begin
      option.Value := Integer(cbProfile.Checked);  //same as '-pg'
    end else if SameStr(option.Setting, '-Wall') then begin
      option.Value := Integer(cbWall.Checked);
    end else if SameStr(option.Setting, '-Wextra') then begin
      option.Value := Integer(cbWextra.Checked);
    end else if SameStr(option.Setting, '-ansi') then begin
      option.Value := Integer(cbANSI.Checked);
    end else if SameStr(option.Setting, '-fno-asm') then begin
      option.Value := Integer(cbNoasm.Checked);
    end else if SameStr(option.Setting, '-traditional-cpp') then begin
      option.Value := Integer(cbTradional.Checked);
    end else if SameStr(option.Setting, '-O') then begin
      option.Value := cmbOptimize.ItemIndex;
    end else if SameStr(option.Setting, '-pedantic') then begin
      option.Value := Integer(cbPedantic.Checked);
    end else if SameStr(option.Setting, '-Wshadow') then begin
      option.Value := Integer(cbShadow.Checked);
    end else if SameStr(option.Setting, '-Wfloat-equal') then begin
      option.Value := Integer(cbFloatEqual.Checked);
    end else if SameStr(option.Setting, '-Werror=uninitialized') then begin
      option.Value := Integer(cbUninitialized.Checked);
    end else if SameStr(option.Setting, '-Werror=return-type') then begin
      option.Value := Integer(cbReturnType.Checked);
    end else if SameStr(option.Setting, '-Werror=vla') then begin
      option.Value := Integer(cbVLA.Checked);
    end else if SameStr(option.Setting, '-Wfatal-errors') then begin
      option.Value := Integer(cbWfatal.Checked);
    end else if SameStr(option.Setting, '-fmax-errors=10') then begin
      option.Value := Integer(cbMaxerror.Checked);
    end else if SameStr(option.Setting, '-s') then begin
      option.Value := Integer(cbStrip.Checked);
    end else if SameStr(option.Setting, '-pipe') then begin
      option.Value := Integer(cbPipe.Checked);
    end;
    PCompilerOption(devCompilerSets[index].Options[I])^.Value := option.Value;
  end;


  // Save to disk...
  devCompilerSets.SaveSet(index);

  // Mark unmodified
  cmbCompilerSetComp.Tag := 0;
end;

procedure TCompilerOptForm.btnHelpClick(Sender: TObject);
begin
  OpenHelpFile('Interface\Dialog Windows\Compiler Options\index.htm'); // TODO: open iframe instead of page
end;

procedure TCompilerOptForm.DirTabsChange(Sender: TObject);
var
  I, MaxWidth: Integer;
begin
  case DirTabs.TabIndex of
    0: lstDirs.Items.Assign(fBinDirCopy);
    1: lstDirs.Items.Assign(fLibDirCopy);
    2: lstDirs.Items.Assign(fCDirCopy);
    3: lstDirs.Items.Assign(fCppDirCopy);
  end;
  edEntry.Clear;
  UpdateButtons;

  //adjust ScrollWidth
  MaxWidth := -1;
  lstDirs.Canvas.Font := lstDirs.Font;    // assign control's font to canvas
  for I := 0 to lstDirs.Items.Count - 1 do
    MaxWidth := Max(MaxWidth, lstDirs.Canvas.TextWidth(lstDirs.Items[I]));
  if MaxWidth <> -1 then    // consider non-client area
    lstDirs.ScrollWidth := MaxWidth + lstDirs.Width - lstDirs.ClientWidth + 10;
end;

procedure TCompilerOptForm.lstDirsClick(Sender: TObject);
begin
  UpdateButtons;
end;

procedure TCompilerOptForm.lstDirsDblClick(Sender: TObject);
begin
  if lstDirs.ItemIndex <> -1 then
    edEntry.Text := lstDirs.Items[lstDirs.ItemIndex];
end;


procedure TCompilerOptForm.edEntryChange(Sender: TObject);
begin
  UpdateButtons;
end;

procedure TCompilerOptForm.btnBrowseClick(Sender: TObject);
var
  NewItem: String; 
begin
  NewItem := Trim(edEntry.Text);
  if (NewItem <> '') and SysUtils.DirectoryExists(edEntry.Text) then
    NewItem := edEntry.Text
  else
    NewItem := devDirs.Default;
  if SelectDirectory('', '', NewItem) then
    edEntry.Text := NewItem;
end;

procedure TCompilerOptForm.ButtonClick(Sender: TObject);
var
  idx: integer;
begin
  case TComponent(Sender).Tag of
    1: lstDirs.Items[lstDirs.ItemIndex] := TrimRight(edEntry.Text);
    2: lstDirs.Items.Add(TrimRight(edEntry.Text));
    3: lstDirs.DeleteSelected;
    4:
      for idx := pred(lstDirs.Items.Count) downto 0 do
        if not SysUtils.DirectoryExists(lstDirs.Items[idx]) then
          lstDirs.Items.Delete(idx);
  end; { case }
  edEntry.Clear;

  case DirTabs.TabIndex of
    0: fBinDirCopy.Assign(lstDirs.Items);
    1: fLibDirCopy.Assign(lstDirs.Items);
    2: fCDirCopy.Assign(lstDIrs.Items);
    3: fCppDirCopy.Assign(lstDirs.Items);
  end;
  edEntry.SetFocus;
end;

procedure TCompilerOptForm.UpDownClick(Sender: TObject);
var
  idx: integer;
begin
  idx := lstDirs.ItemIndex;
  if Sender = btnUp then begin
    lstDirs.Items.Exchange(lstDirs.ItemIndex, lstDirs.ItemIndex - 1);
    lstDirs.ItemIndex := idx - 1;
  end else begin
    if Sender = btnDown then begin
      lstDirs.Items.Exchange(lstDirs.ItemIndex, lstDirs.ItemIndex + 1);
      lstDirs.ItemIndex := idx + 1;
    end;
  end;

  case DirTabs.TabIndex of
    0: fBinDirCopy.Assign(lstDirs.Items);
    1: fLibDirCopy.Assign(lstDirs.Items);
    2: fCDirCopy.Assign(lstDIrs.Items);
    3: fCppDirCopy.Assign(lstDirs.Items);
  end;
  UpdateButtons;
end;

procedure TCompilerOptForm.UpdateButtons;
begin
  btnAdd.Enabled := edEntry.Text <> '';
  if lstDirs.ItemIndex >= 0 then begin
    btnDelete.Enabled := TRUE;
    btnReplace.Enabled := btnAdd.Enabled;
    btnUp.Enabled := lstDirs.ItemIndex > 0;
    btnDown.Enabled := lstDirs.ItemIndex<(lstDirs.Items.Count - 1);
  end else begin
    btnDelete.Enabled := FALSE;
    btnReplace.Enabled := FALSE;
    btnUp.Enabled := FALSE;
    btnDown.Enabled := FALSE;
  end;
  btnDelInval.Enabled := lstDirs.Items.Count > 0;
end;

procedure TCompilerOptForm.edEntryKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key = VK_RETURN then
    ButtonClick(btnAdd);
end;

procedure TCompilerOptForm.FormCreate(Sender: TObject);
var
  I: integer;
  scale: Real;
begin
  LoadText;

    //adjust components' size for screen HighDPI
  scale := Screen.PixelsPerInch / 96;  //original dpi is 96
  cmbLangStd.Height := ceil(cmbLangStd.Height * scale);
  cmbLangStd2.Height := ceil(cmbLangStd2.Height * scale);
  cmbPtrWidth.Height := ceil(cmbPtrWidth.Height * scale);
  //cmbBuiltin.Height := ceil(cmbBuiltin.Height * scale);
  cmbOptimize.Height := ceil(cmbOptimize.Height * scale);

  // Create local copies we can modify
  fBinDirCopy := TStringList.Create;
  fLibDirCopy := TStringList.Create;
  fCDirCopy := TStringList.Create;
  fCppDirCopy := TStringList.Create;

  // fill compiler lists
  cmbCompilerSetComp.Items.BeginUpdate;
  try
    // Populate
    for I := 0 to devCompilerSets.Count - 1 do
      cmbCompilerSetComp.Items.Add(devCompilerSets[i].Name);

    // Set current index
    fOldIndex := -1;
    if devCompilerSets.DefaultSetIndex < cmbCompilerSetComp.Items.Count then
      cmbCompilerSetComp.ItemIndex := devCompilerSets.DefaultSetIndex
    else if cmbCompilerSetComp.Items.Count > 0 then
      cmbCompilerSetComp.ItemIndex := 0;
  finally
    cmbCompilerSetComp.Items.EndUpdate; // paint once
  end;

  // Load the current set
  cmbCompilerSetCompChange(nil);
end;

procedure TCompilerOptForm.LoadText;
begin
  // Set interface font
  Font.Name := devData.InterfaceFont;
  Font.Size := devData.InterfaceFontSize;

  Caption := Lang[ID_COPT];

  // Tabs
  tabCompiler.Caption := Lang[ID_COPT_COMPTAB];
  tabSettings.Caption := Lang[ID_COPT_OPTIONSTAB];
  tabDirectories.Caption := Lang[ID_COPT_DIRTAB];
  tabPrograms.Caption := Lang[ID_COPT_PROGRAMSTAB];
  btnFindCompilers.Caption := Lang[ID_COPT_FINDCOMPILES];
  btnAddCompilerSet.Caption := Lang[ID_COPT_ADDCOMPILES];
  //btnAddBlankCompilerSet.Caption := Lang[];
  //btnRenameCompilerSet.Caption := Lang[];
  //btnDelCompilerSet.Caption := Lang[];

  // Directories, subtabs
  DirTabs.Tabs.Clear;
  DirTabs.Tabs.Add(Lang[ID_COPT_BIN]);
  DirTabs.Tabs.Add(Lang[ID_COPT_LIB]);
  DirTabs.Tabs.Add(Lang[ID_COPT_INCC]);
  DirTabs.Tabs.Add(Lang[ID_COPT_INCCPP]);

  // Buttons for all tabs
  btnReplace.Caption := Lang[ID_BTN_REPLACE];
  btnAdd.Caption := Lang[ID_BTN_ADD];
  btnDelete.Caption := Lang[ID_BTN_DELETE];
  btnDelInval.Caption := Lang[ID_BTN_DELINVAL];
  btnOk.Caption := Lang[ID_BTN_OK];
  btnCancel.Caption := Lang[ID_BTN_CANCEL];
  btnHelp.Caption := Lang[ID_BTN_HELP];

  // Checkboxes and delay
  cbCompAdd.Caption := Lang[ID_COPT_ADDCOMP];
  cbLinkerAdd.Caption := Lang[ID_COPT_LINKADD];
  OptionsTip.Caption := Lang[ID_COPT_COMPILERTIP];
  //cbAutoLink.Caption := Lang[ID_COPT_AUTOLINK];

  // Programs (you may want to...)
  lblProgramsText.Caption := Lang[ID_COPT_PROGRAMS];

  // Text above compiler select
  grpCompSet.Caption := Lang[ID_COPT_COMPSETS];

  // Set some hints too
  BtnFindCompilers.Hint := Lang[ID_COPT_FINDCOMPHINT];
  btnAddBlankCompilerSet.Hint := Lang[ID_COPT_ADDCOMPHINT];
  btnAddCompilerSet.Hint := Lang[ID_COPT_ADDFOLDERCOMPHINT];
  btnDelCompilerSet.Hint := Lang[ID_COPT_DELCOMPHINT];
  btnRenameCompilerSet.Hint := Lang[ID_COPT_RENAMECOMPHINT];
end;

procedure TCompilerOptForm.btnBrws1Click(Sender: TObject);
var
  Obj: TEdit;
begin
  Obj := nil;
  case TSpeedButton(Sender).Tag of
    2: Obj := GccEdit; //gcc
    3: Obj := GppEdit; //gpp
    4: Obj := MakeEdit; //make
    5: Obj := GdbEdit; //gdb
    6: Obj := WindresEdit; //windres
    7: Obj := GprofEdit; //gprof
  end;

  if not Assigned(Obj) then
    Exit;

  with TOpenDialog.Create(Self) do try
    Filter := FLT_ALLFILES;

    // Start in the bin folder
    if fBinDirCopy.Count > 0 then
      InitialDir := fBinDirCopy[0]
    else if devCompilerSets[cmbCompilerSetComp.ItemIndex].BinDir.Count > 0 then
      InitialDir := devCompilerSets[cmbCompilerSetComp.ItemIndex].BinDir[0];

    // Select the current filename by default...
    if Obj.Text <> '' then
      FileName := IncludeTrailingPathDelimiter(InitialDir) + Obj.Text;

    // When accepted, replace
    if Execute then
      Obj.Text := ExtractFileName(FileName);
  finally
    Free;
  end;
end;

procedure TCompilerOptForm.cmbCompilerSetCompChange(Sender: TObject);
begin
  // Don't allow browsing
  MainPages.Enabled := cmbCompilerSetComp.Items.Count > 0;
  btnDelCompilerSet.Enabled := cmbCompilerSetComp.Items.Count > 0;
  btnRenameCompilerSet.Enabled := cmbCompilerSetComp.Items.Count > 0;
  if cmbCompilerSetComp.Items.Count = 0 then
    MainPages.ActivePageIndex := 0;

  if fOldIndex = cmbCompilerSetComp.ItemIndex then
    Exit; // why the hell is this event firing anyway?

  // Save old if it still exists
  if (fOldIndex >= 0) and (fOldIndex < devCompilerSets.Count) then
    if (cmbCompilerSetComp.Tag = 1) and (MessageDlg(Format(Lang[ID_MSG_ASKSAVECLOSE],
      [cmbCompilerSetComp.Items[fOldIndex]]), mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
      SaveSet(fOldIndex);

  fOldIndex := cmbCompilerSetComp.ItemIndex;
  //CompOptionsFrame1.fCurrentIndex := fOldIndex;

  // Load the new set, apply new set to UI
  LoadSet(fOldIndex);

end;

procedure TCompilerOptForm.btnAddBlankCompilerSetClick(Sender: TObject);
var
  S: String; 
begin
  S := 'New compiler';
  if not InputQuery(Lang[ID_COPT_NEWCOMPSET], Lang[ID_COPT_PROMPTNEWCOMPSET], S) or (S = '') then
    Exit;

  // Add empty compiler set
  devCompilerSets.AddSet;

  // Add name to list
  cmbCompilerSetComp.ItemIndex := cmbCompilerSetComp.Items.Add(S);
  cmbCompilerSetCompChange(nil);

  // Mark modified
  InterfaceChange(nil);
end;

procedure TCompilerOptForm.btnAddCompilerSetClick(Sender: TObject);
var
  Directory: String; 
begin
  if devDirs.Default <> '' then
    Directory := devDirs.Default
  else
    Directory := devDirs.Exec;
  if not SelectDirectory('', '', Directory) then
    Exit;

  // Add empty compiler set
  devCompilerSets.AddSet(Directory);

  // Add name to list
  cmbCompilerSetComp.ItemIndex := cmbCompilerSetComp.Items.Add(devCompilerSets[devCompilerSets.Count - 1].Name);
  cmbCompilerSetCompChange(nil);

  // Mark modified
  InterfaceChange(nil);
end;

procedure TCompilerOptForm.btnDelCompilerSetClick(Sender: TObject);
var
  deleteindex: integer;
begin
  if cmbCompilerSetComp.ItemIndex <> -1 then begin

    // Politely ask first
    if MessageDlg(Lang[ID_COPT_DELETECOMPSET], mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      Exit;

    // Remove from list
    deleteindex := cmbCompilerSetComp.ItemIndex;
    devCompilerSets.DeleteSet(deleteindex);
    cmbCompilerSetComp.Items.Delete(deleteindex);

    // load previous (if it exists)
    if cmbCompilerSetComp.Items.Count > 0 then
      cmbCompilerSetComp.ItemIndex := max(0, deleteindex - 1)
    else
      cmbCompilerSetComp.ItemIndex := -1;
    cmbCompilerSetCompChange(nil);
    cmbCompilerSetComp.Repaint;
  end;
end;

procedure TCompilerOptForm.btnRenameCompilerSetClick(Sender: TObject);
var
  S: String; 
  selindex: integer;
begin
  if cmbCompilerSetComp.ItemIndex <> -1 then begin
    S := cmbCompilerSetComp.Text;
    if not InputQuery(Lang[ID_COPT_RENAMECOMPSET], Lang[ID_COPT_PROMPTRENAMECOMPSET], S) or (S = '') or (S =
      cmbCompilerSetComp.Text) then
      Exit;

    // Selection index is set to -1 when renaming...
    selindex := cmbCompilerSetComp.ItemIndex;
    cmbCompilerSetComp.Items[cmbCompilerSetComp.ItemIndex] := S;
    cmbCompilerSetComp.ItemIndex := selindex;
  end;
end;

procedure TCompilerOptForm.OptionsLinkClick(Sender: TObject);
begin
  OpenURL(TLabel(Sender).Caption);
end;

procedure TCompilerOptForm.cbANSIClick(Sender: TObject);
begin
  cmbLangStd.Enabled := not cbANSI.checked;
  cmbLangStd2.Enabled := not cbANSI.Checked;
  if cbANSI.checked then begin
    cmbLangStd.ItemIndex := cmbLangStd.Items.IndexOf('ISO C90');
    cmbLangStd2.ItemIndex := cmbLangStd2.Items.IndexOf('ISO C++');
  end
  else begin
    cmbLangStd.ItemIndex := 0;
    cmbLangStd2.ItemIndex := 0;
  end;
end;

procedure TCompilerOptForm.cbCompAddClick(Sender: TObject);
begin
  Commands.Enabled := TCheckBox(Sender).Checked;
  InterfaceChange(nil);
end;

procedure TCompilerOptForm.cbLinkerAddClick(Sender: TObject);
begin
  Linker.Enabled := TCheckBox(Sender).Checked;
  InterfaceChange(nil);
end;



procedure TCompilerOptForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  // Fix bug in VCL (http://qc.embarcadero.com/wc/qcmain.aspx?d=5265)
  //CompOptionsFrame1.vle.Strings.Clear;

  // Destroy local copies we can modify
  fBinDirCopy.Free;
  fLibDirCopy.Free;
  fCDirCopy.Free;
  fCppDirCopy.Free;

  CloseAction := caFree;
end;

procedure TCompilerOptForm.btnFindCompilersClick(Sender: TObject);
var
  dlgresult, I: integer;
begin
  dlgresult := MessageDlg(
    Format(Lang[ID_COPT_ADDCOMPILERS], [devDirs.Exec + 'MinGW32', devDirs.Exec + 'MinGW64']),
      mtConfirmation, [mbYes, mbNo, mbCancel], 0);

  if dlgresult = mrCancel then
    Exit;

  // Dialog asked to clear the current compiler list...
  if dlgresult = mrYes then
    devCompilerSets.ClearSets;

  // Find a bunch of compilers
  devCompilerSets.FindSets;

  // Add names to selection box
  cmbCompilerSetComp.Clear;
  for I := 0 to devCompilerSets.Count - 1 do
    cmbCompilerSetComp.Items.Add(devCompilerSets[i].Name);

  // Set a default selection
  fOldIndex := -1;
  if cmbCompilerSetComp.Items.Count > 0 then
    //cmbCompilerSetComp.ItemIndex := 0
    cmbCompilerSetComp.ItemIndex := DevCompilersets.DefaultSetIndex
  else
    cmbCompilerSetComp.ItemIndex := -1;

  // Change event does not happen when changing ItemIndex...
  cmbCompilerSetCompChange(nil);

  // Save them to disk immediately
  devCompilerSets.SaveSets; // save the list too
end;

procedure TCompilerOptForm.cmbCompilerSetCompEnter(Sender: TObject);
begin
  fOldIndex := cmbCompilerSetComp.ItemIndex;
end;



// Unite into one function?

procedure TCompilerOptForm.InterfaceChange(Sender: TObject);
begin
  cmbCompilerSetComp.Tag := 1;
end;

procedure TCompilerOptForm.InterfaceSave(Sender: TObject);
begin
  cmbCompilerSetComp.Tag := 0;
end;

end.

