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

unit ProjectOptFrm;

interface

uses
{$IFDEF MSWINDOWS}
  {$IFDEF MSWINDOWS}Windows{$ELSE}LCLIntf, LCLType{$ENDIF},
{$ELSE}
  LCLType,
{$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtDlgs, StdCtrls, ExtCtrls, Buttons, ComCtrls, main, project,
  ProjectTypes, Spin, ValEdit, LCLIntf, Grids;

type

  { TProjectOptForm }

  TProjectOptForm = class(TForm)
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    btnHelp: TBitBtn;
    cbMaxerror: TCheckBox;
    cbPedantic: TCheckBox;
    cbReturnType: TCheckBox;
    cbUninitialized: TCheckBox;
    cbVLA: TCheckBox;
    cbWfatal: TCheckBox;
    cmbBuiltin: TComboBox;
    cmbOptimize: TComboBox;
    dlgOpen: TOpenDialog;
    dlgPic: TOpenPictureDialog;
    lblBuiltin: TLabel;
    lblOptimize: TLabel;
    PageControl: TPageControl;
    Panel2: TPanel;
    PanelBackground: TPanel;
    tabGeneral: TTabSheet;
    tabFilesDir: TTabSheet;
    lblPrjName: TLabel;
    grpIcon: TGroupBox;
    btnIconBrowse: TBitBtn;
    btnIconLib: TBitBtn;
    grpType: TGroupBox;
    lstType: TListBox;
    edProjectName: TEdit;
    btnDirUp: TSpeedButton;
    btnDirDown: TSpeedButton;
    SubTabs: TTabControl;
    lstDirList: TListBox;
    btnDirAdd: TButton;
    btnDirDelete: TButton;
    btnDirReplace: TButton;
    edDirEntry: TEdit;
    btnDirDelInval: TButton;
    btnRemoveIcon: TBitBtn;
    Panel1: TPanel;
    IconPreview: TImage;
    tabOutputDir: TTabSheet;
    lblExeOutput: TLabel;
    lblObjOutput: TLabel;
    edExeOutput: TEdit;
    edObjOutput: TEdit;
    tabMakefile: TTabSheet;
    IncMakeLabel: TLabel;
    lbMakeIncludes: TListBox;
    btnMakUp: TSpeedButton;
    btnMakDown: TSpeedButton;
    edMakeInclude: TEdit;
    btnMakReplace: TButton;
    btnMakAdd: TButton;
    btnMakDelete: TButton;
    btnMakDelInval: TButton;
    dlgMakeInclude: TOpenDialog;
    InfoMakeBtn: TSpeedButton;
    edOverridenOutput: TEdit;
    chkOverrideOutput: TCheckBox;
    tabFiles: TTabSheet;
    lvFiles: TTreeView;
    grpUnitOptions: TGroupBox;
    chkCompile: TCheckBox;
    chkCompileCpp: TCheckBox;
    tabVersion: TTabSheet;
    chkVersionInfo: TCheckBox;
    grpVersion: TGroupBox;
    lblVerMajor: TLabel;
    lblVerMinor: TLabel;
    lblVerRel: TLabel;
    lblVerBuild: TLabel;
    lblVerLang: TLabel;
    spnMajor: TSpinEdit;
    spnMinor: TSpinEdit;
    spnRelease: TSpinEdit;
    spnBuild: TSpinEdit;
    vleVersion: TValueListEditor;
    cmbLangID: TComboBox;
    tabCompiler: TTabSheet;
    chkSupportXP: TCheckBox;
    chkOverrideBuildCmd: TCheckBox;
    txtOverrideBuildCmd: TMemo;
    lblFname: TLabel;
    lblPrjFname: TLabel;
    lblUnits: TLabel;
    lblPrjUnits: TLabel;
    lblPrjOutputFname: TLabel;
    lblPrjOutput: TLabel;
    chkLink: TCheckBox;
    lblPriority: TLabel;
    spnPriority: TSpinEdit;
    chkAutoIncBuild: TCheckBox;
    chkSyncProduct: TCheckBox;
    tabCompOpts: TTabSheet;
    cmbCompiler: TComboBox;
    lblCompilerSet: TLabel;
    lblAdditions: TLabel;
    lblCompiler: TLabel;
    edCompiler: TMemo;
    lblCppCompiler: TLabel;
    edCppCompiler: TMemo;
    lblLinker: TLabel;
    edLinker: TMemo;
    btnAddLib: TBitBtn;
    cbUseCustomMakefile: TCheckBox;
    edCustomMakefile: TEdit;
    dlgCustomMake: TOpenDialog;
    btnBrowse: TSpeedButton;
    btnExeOutDir: TSpeedButton;
    btnObjOutDir: TSpeedButton;
    btnCustomMakeBrowse: TSpeedButton;
    btnMakeBrowse: TSpeedButton;
    edLogOutput: TEdit;
    btnLogOutputDir: TSpeedButton;
    chkLogOutput: TCheckBox;
    chkDefCpp: TCheckBox;
    lblCompilerHint: TLabel;
    PageControl1: TPageControl;
    tabCompGeneral: TTabSheet;
    lblLangStd: TLabel;
    cmbLangStd: TComboBox;
    cmbLangStd2: TComboBox;
    cbStatic: TCheckBox;
    tabCompOptions1: TTabSheet;
    cbDebug: TCheckBox;
    cbProfile: TCheckBox;
    cbWall: TCheckBox;
    cbWextra: TCheckBox;
    cbNoasm: TCheckBox;
    cbTradional: TCheckBox;
    tabCompOptions2: TTabSheet;
    cbStrip: TCheckBox;
    cbPipe: TCheckBox;
    OptionsTip: TLabel;
    OptionsLink: TLabel;
    cbANSI: TCheckBox;
    lblPtrWidth: TLabel;
    cmbPtrWidth: TComboBox;
    cbShadow: TCheckBox;
    cbFloatEqual: TCheckBox;
    procedure ListClick(Sender: TObject);
    procedure EditChange(SEnder: TObject);
    procedure ButtonClick(Sender: TObject);
    procedure UpDownClick(Sender: TObject);
    procedure BrowseClick(Sender: TObject);
    procedure SubTabsChange(Sender: TObject);
    procedure SubTabsChanging(Sender: TObject; NewIndex: Integer; var AllowChange: Boolean);
    procedure btnIconLibClick(Sender: TObject);
    procedure btnIconBrowseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnRemoveIconClick(Sender: TObject);
    procedure BrowseExecutableOutDirClick(Sender: TObject);
    procedure BrowseLogDirClick(Sender: TObject);
    procedure btnMakeBrowseClick(Sender: TObject);
    procedure btnMakClick(Sender: TObject);
    procedure MakButtonClick(Sender: TObject);
    procedure edMakeIncludeChange(Sender: TObject);
    procedure lbMakeIncludesClick(Sender: TObject);
    procedure InfoMakeBtnClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure chkOverrideOutputClick(Sender: TObject);
    procedure chkCompileClick(Sender: TObject);
    procedure chkVersionInfoClick(Sender: TObject);
    procedure lvFilesChange(Sender: TObject; Node: TTreeNode);
    procedure cmbCompilerChange(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure lstTypeClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnAddLibClick(Sender: TObject);
    procedure txtOverrideBuildCmdChange(Sender: TObject);
    procedure spnPriorityChange(Sender: TObject);
    procedure btnCustomMakeBrowseClick(Sender: TObject);
    procedure cbUseCustomMakefileClick(Sender: TObject);
    procedure lbMakeIncludesDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure SetFileVersion(Sender: TObject);
    procedure btnLogOutputDirClick(Sender: TObject);
    procedure chkLogOutputClick(Sender: TObject);
    procedure OptionsLinkClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure cbANSIClick(Sender: TObject);
  private
    procedure UpdateDirButtons;
    procedure UpdateMakButtons;
    procedure LoadText;
    procedure InitVersionInfo;
    function DefaultBuildCommand(idx: integer): String;
    procedure SaveDirSettings;
  public
    fOldIndex: integer;
    fProjectCopy: TProject; // do work on this copy and assign it to the original when the user presses OK
    procedure FillOptions(Sender: TObject);
    procedure SetInterface(Source: TProject); // fProjectCopy -> UI
    procedure GetInterface(Destination: TProject); // UI -> fProjectCopy
  end;

implementation

uses
  devcfg, IconFrm, utils, MultiLangSupport, version, Math;

{$R *.lfm}

procedure TProjectOptForm.UpdateDirButtons;
begin
  btnDirAdd.Enabled := edDirEntry.Text <> '';
  if lstDirList.ItemIndex >= 0 then begin
    btnDirDelete.Enabled := true;
    btnDirReplace.Enabled := btnDirAdd.Enabled;
    btnDirUp.Enabled := lstDirList.ItemIndex > 0;
    btnDirDown.Enabled := lstDirList.ItemIndex<(lstDirList.Items.Count - 1);
  end else begin
    btnDirDelete.Enabled := false;
    btnDirReplace.Enabled := false;
    btnDirUp.Enabled := false;
    btnDirDown.Enabled := false;
  end;
  btnDirDelInval.Enabled := lstDirList.Items.Count > 0;
end;

procedure TProjectOptForm.UpdateMakButtons;
begin
  btnMakAdd.Enabled := edMakeInclude.Text <> '';
  if lbMakeIncludes.ItemIndex >= 0 then begin
    btnMakDelete.Enabled := true;
    btnMakReplace.Enabled := btnMakAdd.Enabled;
    btnMakUp.Enabled := lbMakeIncludes.ItemIndex > 0;
    btnMakDown.Enabled := lbMakeIncludes.ItemIndex<(lbMakeIncludes.Items.Count - 1);
  end else begin
    btnMakDelete.Enabled := false;
    btnMakReplace.Enabled := false;
    btnMakUp.Enabled := false;
    btnMakDown.Enabled := false;
  end;
  btnMakDelInval.Enabled := lbMakeIncludes.Items.Count > 0;
end;

procedure TProjectOptForm.BrowseClick(Sender: TObject);
var
  NewItem: String;
begin
  NewItem := Trim(edDirEntry.Text);
  if (NewItem <> '') and SysUtils.DirectoryExists(NewItem) then
    newitem := edDirEntry.Text
  else
    newitem := fProjectCopy.Directory;

  case SubTabs.TabIndex of
    0: begin // Lib tab
        if SelectDirectory('Library Directory', '', NewItem) then
          edDirEntry.Text := NewItem;
      end;
    1: begin // Include tab
        if SelectDirectory('Include Directory', '', NewItem) then
          edDirEntry.Text := NewItem;
      end;
    2: begin // Resource dir Tab
        if SelectDirectory('Resource Directory', '', NewItem) then
          edDirEntry.Text := NewItem;
      end;
  end;
  edDirEntry.SetFocus;
end;

procedure TProjectOptForm.ButtonClick(Sender: TObject);
var
  idx: integer;
  item: String;
begin
  item := TrimRight(edDirEntry.Text);
  case TComponent(Sender).Tag of
    1: begin
        lstDirList.Items[lstDirList.ItemIndex] := item;
        case SubTabs.TabIndex of
          0: fProjectCopy.Options.Libs[lstDirList.ItemIndex] := item;
          1: fProjectCopy.Options.Includes[lstDirList.ItemIndex] := item;
          2: fProjectCopy.Options.ResourceIncludes[lstDirList.ItemIndex] := item;
        end;
      end;
    2: begin
        lstDirList.Items.Add(item);
        case SubTabs.TabIndex of
          0: fProjectCopy.Options.Libs.Add(item);
          1: fProjectCopy.Options.Includes.Add(item);
          2: fProjectCopy.Options.ResourceIncludes.Add(item);
        end;
      end;
    3: begin
        case SubTabs.TabIndex of
          0: fProjectCopy.Options.Libs.Delete(lstDirList.ItemIndex);
          1: fProjectCopy.Options.Includes.Delete(lstDirList.ItemIndex);
          2: fProjectCopy.Options.ResourceIncludes.Delete(lstDirList.ItemIndex);
        end;
        lstDirList.DeleteSelected;
      end;
    4: begin
        if lstDirList.Items.Count > 0 then
          for idx := lstDirList.Items.Count - 1 downto 0 do
            if not SysUtils.DirectoryExists(lstDirList.Items[idx]) then begin
              case SubTabs.TabIndex of
                0: fProjectCopy.Options.Libs.Delete(idx);
                1: fProjectCopy.Options.Includes.Delete(idx);
                2: fProjectCopy.Options.ResourceIncludes.Delete(idx);
              end;
              lstDirList.Items.Delete(idx);
            end;
      end;
  end;
  edDirEntry.Clear;
  UpdateDirButtons;
end;

procedure TProjectOptForm.EditChange(Sender: TObject);
begin
  UpdateDirButtons;
end;

procedure TProjectOptForm.ListClick(Sender: TObject);
begin
  UpdateDirButtons;
  if lstDirList.Itemindex <> -1 then
    edDirEntry.Text := lstDirList.Items[lstDirList.Itemindex];
end;

procedure TProjectOptForm.UpDownClick(Sender: TObject);
var
  idx: integer;
begin
  idx := lstDirList.ItemIndex;
  if Sender = btnDirUp then begin
    lstDirList.Items.Exchange(lstDirList.ItemIndex, lstDirList.ItemIndex - 1);
    lstDirList.ItemIndex := idx - 1;
  end else if Sender = btnDirDown then begin
    lstDirList.Items.Exchange(lstDirList.ItemIndex, lstDirList.ItemIndex + 1);
    lstDirList.ItemIndex := idx + 1;
  end;
  UpdateDirButtons;
end;

procedure TProjectOptForm.GetInterface(Destination: TProject);
var
  I, index: integer;
  option: TCompilerOption;
begin
  with Destination.Options do begin

    // General tab
    SupportXPThemes := chkSupportXP.Checked;
    useGPP := chkDefCpp.Checked;
    Icon := fProjectCopy.Options.Icon;
    typ := lstType.ItemIndex;

    // Files tab

    // Compiler tab
    index := cmbCompiler.ItemIndex;
    if (index < devCompilerSets.Count) and (index >= 0) then begin
      //Options' value
      for I := 0 to devCompilerSets[index].Options.Count - 1 do begin  //Options in CompileSet
        option := PCompilerOption(devCompilerSets[index].Options[I])^;  //Current option
        if SameStr(option.Setting, '-std=') then begin
          option.Value := cmbLangStd.ItemIndex;
        end else if SameStr(option.Setting, '-std') then begin
          option.Value := cmbLangStd2.ItemIndex;
        end else if SameStr(option.Setting, '-') then begin  //m64 or m32
          option.Value := cmbPtrWidth.ItemIndex;
        end else if SameStr(option.Setting, '-static-libstdc++ -static-libgcc') then begin
          option.Value := Integer(cbStatic.Checked);
        end else if SameStr(option.Setting, '-g3') then begin
          option.Value := Integer(cbDebug.Checked);
        end else if SameStr(option.Setting, '-pg') then begin
          option.Value := Integer(cbProfile.Checked);
        end else if SameStr(option.Setting, '-no-pie') then begin
          option.Value := Integer(cbProfile.Checked);
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
//        end else if SameStr(option.Setting, '-m') then begin  //builtin process
//          option.Value := cmbBuiltin.ItemIndex;
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

      CompilerOptions := devCompilerSets[index].INIOptions;
    end;
    CompilerSet := cmbCompiler.ItemIndex;

    // Options tab
    CompilerCmd := '';
    for I := 0 to edCompiler.Lines.Count - 1 do
      CompilerCmd := CompilerCmd + edCompiler.Lines[I] + '_@@_';

    CppCompilerCmd := '';
    for I := 0 to edCppCompiler.Lines.Count - 1 do
      CppCompilerCmd := CppCompilerCmd + edCppCompiler.Lines[I] + '_@@_';

    LinkerCmd := '';
    for I := 0 to edLinker.Lines.Count - 1 do
      LinkerCmd := LinkerCmd + edLinker.Lines[I] + '_@@_';

    // Directories tab
    SaveDirSettings;

    // Build tab
    ExeOutput := edExeOutput.Text;
    ObjectOutput := edObjOutput.Text;
    LogOutput := edLogOutput.Text;
    LogOutputEnabled := chkLogOutput.Checked;
    OverrideOutput := chkOverrideOutput.Checked;
    OverridenOutput := edOverridenOutput.Text;

    // Makefile tab
    if cbUseCustomMakefile.Checked and FileExists(edCustomMakefile.Text) then
      UseCustomMakefile := true
    else
      UseCustomMakefile := false;
    CustomMakefile := edCustomMakefile.Text;
    MakeIncludes.Clear;
    MakeIncludes.AddStrings(lbMakeIncludes.Items);

    // Version tab
    IncludeVersionInfo := chkVersionInfo.Checked;

    VersionInfo.Major := spnMajor.Value;
    VersionInfo.Minor := spnMinor.Value;
    VersionInfo.Release := spnRelease.Value;
    VersionInfo.Build := spnBuild.Value;
    VersionInfo.AutoIncBuildNr := chkAutoIncBuild.Checked;
    VersionInfo.SyncProduct := chkSyncProduct.Checked;

    VersionInfo.FileDescription := vleVersion.Cells[1, 0];
    VersionInfo.FileVersion := vleVersion.Cells[1, 1];
    VersionInfo.ProductName := vleVersion.Cells[1, 2];
    VersionInfo.ProductVersion := vleVersion.Cells[1, 3];
    VersionInfo.OriginalFilename := vleVersion.Cells[1, 4];
    VersionInfo.InternalName := vleVersion.Cells[1, 5];
    VersionInfo.CompanyName := vleVersion.Cells[1, 6];
    VersionInfo.LegalCopyright := vleVersion.Cells[1, 7];
    VersionInfo.LegalTrademarks := vleVersion.Cells[1, 8];

    // Get international language ID (1026 ...)
    if cmbLangID.Visible then begin // no exception has occurred on show...
      try
        // TODO: ATSynEdit - Languages not available in FPC
        //for I := 0 to Languages.Count - 1 do begin
        //  if SameText(Languages.Name[I], cmbLangID.Text) then begin
        //    VersionInfo.LanguageID := Languages.LocaleID[I];
        //    Break;
        //  end;
        //end;
      except // no messageboxes this time, the user has received the message already
      end;
    end;
  end;
end;

procedure TProjectOptForm.SetFileVersion(Sender: TObject);
begin
  with fProjectCopy.Options do begin
    VersionInfo.FileVersion := Format('%d.%d.%d.%d', [spnMajor.Value, spnMinor.Value, spnRelease.Value,
      spnBuild.Value]);
    if chkSyncProduct.Checked then
      VersionInfo.ProductVersion := Format('%d.%d.%d.%d', [spnMajor.Value, spnMinor.Value, spnRelease.Value,
        spnBuild.Value]);

    vleVersion.Values['File Version'] := VersionInfo.FileVersion;
    vleVersion.Values['Product Version'] := VersionInfo.ProductVersion;
  end;
end;

procedure TProjectOptForm.FillOptions(Sender: TObject);
var
  I, J: integer;
  option: TCompilerOption;
begin
   // fill options to controls
  for I := 0 to devCompilerSets[cmbCompiler.ItemIndex].Options.Count - 1 do begin  //���뷽���еĸ���ѡ��
    option := PCompilerOption(devCompilerSets[cmbCompiler.ItemIndex].Options[I])^;  //��ǰѡ��
    if SameStr(option.Setting, '-std=') then begin
      lblLangStd.Caption := Lang[option.Name];
      for J := 0 to option.Choices.Count -1 do
         cmbLangStd.AddItem(option.Choices.Names[J], nil);
      cmbLangStd.ItemIndex := option.Value;
    end
    else if SameStr(option.Setting, '-std') then begin
      for J := 0 to option.Choices.Count -1 do
         cmbLangStd2.AddItem(option.Choices.Names[J], nil);
      cmbLangStd2.ItemIndex := option.Value;
    end
    else if SameStr(option.Setting, '-') then begin   //m64 or m32
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
    end
    else if SameStr(option.Setting, '-Wall') then begin
      cbWall.Caption := Lang[option.Name];
      cbWall.Checked := Boolean(option.Value);
    end
    else if SameStr(option.Setting, '-Wextra') then begin
      cbWextra.Caption := Lang[option.Name];
      cbWextra.Checked := Boolean(option.Value);
    end

    else if SameStr(option.Setting, '-ansi') then begin
      cbANSI.Caption := Lang[option.Name];
      cbANSI.Checked := Boolean(option.Value);
    end
    else if SameStr(option.Setting, '-fno-asm') then begin
      cbNoasm.Caption := Lang[option.Name];
      cbNoasm.Checked := Boolean(option.Value);
    end
    else if SameStr(option.Setting, '-traditional-cpp') then begin
      cbTradional.Caption := Lang[option.Name];
      cbTradional.Checked := Boolean(option.Value);
    end
//    else if SameStr(option.Setting, '-m') then begin  //builtin process
//      lblBuiltin.Caption := Lang[option.Name];
//      for J := 0 to option.Choices.Count -1 do
//         cmbBuiltin.AddItem(option.Choices.Names[J], nil);
//      cmbBuiltin.ItemIndex := option.Value;
//    end
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
  cbANSIClick(Self);


end;

procedure TProjectOptForm.SetInterface(Source: TProject);
var
  I, cntSrc, cntHdr, cntRes, cntOther: integer;
  IconTmp: String;
begin
  fProjectCopy := Source;

  with fProjectCopy.Options do begin

    // General Tab
    lstType.ItemIndex := typ;
    edProjectName.Text := fProjectCopy.Name;
    lblPrjFname.Caption := fProjectCopy.FileName;
    lblPrjOutputFname.Caption := fProjectCopy.Executable;
    chkSupportXP.Checked := SupportXPThemes;
    chkDefCpp.Checked := useGPP;

    // Load icon if possible
    IconTmp := GetRealPath(fProjectCopy.Options.Icon, fProjectCopy.Directory);
    if (IconTmp <> '') and FileExists(IconTmp) then try
      IconPreview.Picture.LoadFromFile(IconTmp);  //fProjectCopy.Options.Icon);
      Icon := IconTmp;
    except
      Icon := '';
    end;
    btnRemoveIcon.Enabled := Length(Icon) > 0;

    cntSrc := 0;
    cntHdr := 0;
    cntRes := 0;
    cntOther := 0;
    for I := 0 to fProjectCopy.Units.Count - 1 do
      case GetFileTyp(fProjectCopy.Units[I].FileName) of
        utcSrc, utcppSrc: Inc(cntSrc);
        utcHead, utcppHead: Inc(cntHdr);
        utResSrc: Inc(cntRes);
      else
        Inc(cntOther);
      end;
    lblPrjUnits.Caption := Format(Lang[ID_POPT_UNITSFORMAT], [fProjectCopy.Units.Count, cntSrc, cntHdr, cntRes,
      cntOther]);

    // Files tab

    // Compiler tab
    for I := 0 to devCompilerSets.Count - 1 do
      cmbCompiler.Items.Add(devCompilerSets[i].Name);
    cmbCompiler.ItemIndex := CompilerSet;
    //CompOptionsFrame1.Enabled := (devCompilerSets.Count > 0);
    fOldIndex := CompilerSet;
    if (CompilerSet < devCompilerSets.Count) and (CompilerSet >= 0) then begin
      devCompilerSets[CompilerSet].INIOptions := fProjectCopy.Options.CompilerOptions;
      FillOptions(Self);
      //CompOptionsFrame1.fCurrentIndex := cmbCompiler.ItemIndex;
      //CompOptionsFrame1.FillOptions;
    end;

    // Options tab
    edCompiler.Lines.Text := StringReplace(CompilerCmd, '_@@_', #13#10, [rfReplaceAll]);
    edCppCompiler.Lines.Text := StringReplace(CppCompilerCmd, '_@@_', #13#10, [rfReplaceAll]);
    edLinker.Lines.Text := StringReplace(LinkerCmd, '_@@_', #13#10, [rfReplaceAll]);

    // Directories tab
    SubTabsChange(Self);

    // Build tab
    edExeOutput.Text := ExeOutput;
    edObjOutput.Text := ObjectOutput;
    edLogOutput.Text := LogOutput;
    chkLogOutput.Checked := LogOutputEnabled;
    chkOverrideOutput.Checked := OverrideOutput;
    if not chkLogOutput.Checked then
      edLogOutput.Enabled := false;
    if OverrideOutput and (OverridenOutput <> '') then
      edOverridenOutput.Text := ExtractFilename(OverridenOutput)
    else
      edOverridenOutput.Text := ExtractFilename(fProjectCopy.Executable);
    edOverridenOutput.Enabled := OverrideOutput;

    // Makefile tab
    UpdateMakButtons;
    cbUseCustomMakefile.Checked := fProjectCopy.Options.UseCustomMakefile;
    edCustomMakefile.Text := fProjectCopy.Options.CustomMakefile;
    cbUseCustomMakefileClick(nil);
    lbMakeIncludes.Items.AddStrings(MakeIncludes);

    // Version tab
    InitVersionInfo;
  end;
end;

procedure TProjectOptForm.SaveDirSettings;
var
  sl: TStrings;
begin
  sl := nil;
  case SubTabs.TabIndex of
    0: sl := fProjectCopy.Options.Libs;
    1: sl := fProjectCopy.Options.Includes;
    2: sl := fProjectCopy.Options.ResourceIncludes;
  end;
  if assigned(sl) then begin
    sl.Clear;
    sl.AddStrings(lstDirList.Items);
  end;
end;

procedure TProjectOptForm.SubTabsChanging(Sender: TObject; NewIndex: Integer; var AllowChange: Boolean);
begin
  SaveDirSettings;
end;

procedure TProjectOptForm.SubTabsChange(Sender: TObject);
//var
//  I, MaxWidth: Integer;
begin
  case SubTabs.TabIndex of
    0: lstDirList.Items := fProjectCopy.Options.Libs;
    1: lstDirList.Items := fProjectCopy.Options.Includes;
    2: lstDirList.Items := fProjectCopy.Options.ResourceIncludes;
  end;
  UpdateDirButtons;
    //adjust ScrollWidth
//  MaxWidth := -1;
//  lstDirList.Canvas.Font := lstDirList.Font;    // assign control's font to canvas
//  for I := 0 to lstDirList.Items.Count - 1 do
//    MaxWidth := Max(MaxWidth, lstDirList.Canvas.TextWidth(lstDirList.Items[I]));
//  if MaxWidth <> -1 then    // consider non-client area
//    lstDirList.ScrollWidth := MaxWidth + lstDirList.Width - lstDirList.ClientWidth + 10;

end;

procedure TProjectOptForm.btnIconLibClick(Sender: TObject);
begin
  with TIconForm.Create(Self) do try
    if ShowModal = mrOk then
      if Selected <> '' then begin
        fProjectCopy.Options.Icon := Selected;
        IconPreview.Picture.LoadFromFile(Selected);
        btnRemoveIcon.Enabled := Length(Selected) > 0;
      end;
  finally
    Free;
  end;
end;

procedure TProjectOptForm.btnIconBrowseClick(Sender: TObject);
begin
  if dlgPic.Execute then begin
    if FileExists(dlgPic.FileName) then begin
      fProjectCopy.Options.Icon := dlgPic.FileName;
      IconPreview.Picture.LoadFromFile(dlgPic.FileName);
      btnRemoveIcon.Enabled := Length(dlgPic.FileName) > 0;
    end else
      MessageDlg(format(Lang[ID_MSG_COULDNOTOPENFILE], [dlgPic.FileName]), mtError, [mbOK], 0);
  end;
end;

procedure TProjectOptForm.FormCreate(Sender: TObject);
var
  scale: Real;
begin
  //adjust components' size for screen HighDPI
  scale := Screen.PixelsPerInch / 96;  //original dpi is 96
  cmbLangStd.Height := ceil(cmbLangStd.Height * scale);
  cmbLangStd2.Height := ceil(cmbLangStd2.Height * scale);
  cmbPtrWidth.Height := ceil(cmbPtrWidth.Height * scale);
  cmbBuiltin.Height := ceil(cmbBuiltin.Height * scale);
  cmbOptimize.Height := ceil(cmbOptimize.Height * scale);

  LoadText;

  // Set default compiler set selection
  fOldIndex := -1;

  // Create file tree
  lvFiles.Images := MainForm.ProjectView.Images;
  lvFiles.Items.Assign(MainForm.ProjectView.Items);
  lvFiles.Items[0].Expand(False);
end;

procedure TProjectOptForm.LoadText;
begin
  // Set interface font
  Font.Name := devData.InterfaceFont;
  Font.Size := devData.InterfaceFontSize;

  Caption := Lang[ID_POPT];

  // Tab captions
  tabGeneral.Caption := Lang[ID_POPT_GENTAB];
  tabFiles.Caption := Lang[ID_POPT_FILESTAB];
  tabCompiler.Caption := Lang[ID_SHEET_COMP];
  tabCompOpts.Caption := Lang[ID_PARAM_CAPTION];
  tabFilesDir.Caption := Lang[ID_POPT_DIRTAB];
  tabOutputDir.Caption := Lang[ID_POPT_OUTTAB];
  tabMakefile.Caption := Lang[ID_POPT_MAKTAB];
  tabVersion.Caption := Lang[ID_POPT_VERTAB];

  // General tab
  lblPrjName.Caption := Lang[ID_POPT_PRJNAME];
  lblFname.Caption := Lang[ID_PROPS_FILENAME];
  lblPrjOutput.Caption := Lang[ID_POPT_OUTPUTFILENAME];
  lblUnits.Caption := Lang[ID_POPT_FILES];
  grpIcon.Caption := Lang[ID_POPT_GRP_ICON];
  btnIconLib.Caption := Lang[ID_POPT_ICOLIB];
  btnIconBrowse.Caption := Lang[ID_BTN_BROWSE];
  btnRemoveIcon.Caption := Lang[ID_BTN_REMOVEICON];
  grpType.Caption := Lang[ID_POPT_GRP_TYPE];
  chkSupportXP.Caption := Lang[ID_POPT_SUPPORTXP];
  chkDefCpp.Caption := Lang[ID_POPT_DEFCPP];
  dlgPic.Title := Lang[ID_POPT_OPENICO];
  dlgOpen.Title := Lang[ID_POPT_OPENOBJ];

  // Populate project type list
  lstType.Clear;
  lstType.Items.Add(Lang[ID_POPT_TYPE1]);
  lstType.Items.Add(Lang[ID_POPT_TYPE2]);
  lstType.Items.Add(Lang[ID_POPT_TYPE3]);
  lstType.Items.Add(Lang[ID_POPT_TYPE4]);

  // Files tab
  grpUnitOptions.Caption := Lang[ID_POPT_UNITOPTS];
  lblPriority.Caption := Lang[ID_POPT_BUILDPRIORITY];
  chkCompile.Caption := Lang[ID_POPT_COMPUNIT];
  chkCompileCpp.Caption := Lang[ID_POPT_UNITUSEGPP];
  chkOverrideBuildCmd.Caption := Lang[ID_POPT_OVERRIDEBUILDCMD];
  chkLink.Caption := Lang[ID_POPT_LINKUNIT];

  // Compiler tab
  lblCompilerSet.Caption := Lang[ID_POPT_COMP];
  lblCompilerHint.Caption := Lang[iD_POPT_COMPCUSTOMHINT];
  OptionsTip.Caption := Lang[ID_COPT_COMPILERTIP];
  tabCompGeneral.Caption := Lang[ID_COPT_COMPTAB];
  tabCompOptions1.Caption := Lang[ID_COPT_OPTIONSTAB] + ' 1';
  tabCompOptions2.Caption := Lang[ID_COPT_OPTIONSTAB] + ' 2';

  // Options tab
  lblAdditions.Caption := Lang[ID_POPT_ADDITIONAL];
  lblCompiler.Caption := Lang[ID_POPT_CCOMP];
  lblCppCompiler.Caption := Lang[ID_POPT_CPPCOMP];
  lblLinker.Caption := Lang[ID_POPT_LINKER];
  btnAddLib.Caption := Lang[ID_POPT_ADDLIBRARY];

  // Directories tab
  SubTabs.Tabs.Clear;
  SubTabs.Tabs.Append(Lang[ID_POPT_LIBDIRS]);
  SubTabs.Tabs.Append(Lang[ID_POPT_INCDIRS]);
  SubTabs.Tabs.Append(Lang[ID_POPT_RESDIRS]);
  btnDirReplace.Caption := Lang[ID_BTN_REPLACE];
  btnDirAdd.Caption := Lang[ID_BTN_ADD];
  btnDirDelete.Caption := Lang[ID_BTN_DELETE];
  btnDirDelInval.Caption := Lang[ID_BTN_DELINVAL];

  // Output tab
  lblExeOutput.Caption := Lang[ID_POPT_EXEOUT];
  lblObjOutput.Caption := Lang[ID_POPT_OBJOUT];
  chkLogOutput.Caption := Lang[ID_POPT_LOGAUTOSAVE];
  chkOverrideOutput.Caption := Lang[ID_POPT_OVERRIDEOUT];

  // Makefile tab
  cbUseCustomMakefile.Caption := Lang[ID_POPT_USECUSTOMMAKEFILE];
  InfoMakeBtn.Caption := Lang[ID_POPT_INFOCUSTOMMAKEFILE];
  IncMakeLabel.Caption := Lang[ID_POPT_INCFILEMAKEFILE];
  btnMakReplace.Caption := Lang[ID_BTN_REPLACE];
  btnMakAdd.Caption := Lang[ID_BTN_ADD];
  btnMakDelete.Caption := Lang[ID_BTN_DELETE];
  btnMakDelInval.Caption := Lang[ID_BTN_DELINVAL];

  // version info tab
  chkVersionInfo.Caption := Lang[ID_POPT_INCLUDEVERSION];
  grpVersion.Caption := Lang[ID_POPT_VDETAILS];
  lblVerMajor.Caption := Lang[ID_POPT_VMAJOR];
  lblVerMinor.Caption := Lang[ID_POPT_VMINOR];
  lblVerRel.Caption := Lang[ID_POPT_VRELEASE];
  lblVerBuild.Caption := Lang[ID_POPT_VBUILD];
  lblVerLang.Caption := Lang[ID_POPT_VLANG];
  chkAutoIncBuild.Caption := Lang[ID_POPT_VAUTOINCBUILDNR];
  chkSyncProduct.Caption := Lang[ID_POPT_SYNCPRODUCT];

  // Misc. buttons
  btnOk.Caption := Lang[ID_BTN_OK];
  btnCancel.Caption := Lang[ID_BTN_CANCEL];
  btnHelp.Caption := Lang[ID_BTN_HELP];
end;

procedure TProjectOptForm.btnRemoveIconClick(Sender: TObject);
begin
  btnRemoveIcon.Enabled := False;
  fProjectCopy.Options.Icon := '';
  IconPreview.Picture.Graphic := nil;
end;

procedure TProjectOptForm.BrowseExecutableOutDirClick(Sender: TObject);
var
  Dir: String;
begin
  if fProjectCopy.Options.ExeOutput <> '' then
    Dir := ExpandFileto(fProjectCopy.Options.ExeOutput, fProjectCopy.Directory)
  else
    Dir := fProjectCopy.Directory;
  if SelectDirectory('Select Directory', '', Dir) then
    edExeOutput.Text := ExtractRelativePath(fProjectCopy.Directory, Dir);
end;

procedure TProjectOptForm.BrowseLogDirClick(Sender: TObject);
var
  Dir: String;
begin
  if fProjectCopy.Options.ObjectOutput <> '' then
    Dir := ExpandFileto(fProjectCopy.Options.ObjectOutput, fProjectCopy.Directory)
  else
    Dir := fProjectCopy.Directory;
  if SelectDirectory('Select Directory', '', Dir) then
    edObjOutput.Text := ExtractRelativePath(fProjectCopy.Directory, Dir);
end;

procedure TProjectOptForm.btnLogOutputDirClick(Sender: TObject);
var
  Dir: String;
begin
  if fProjectCopy.Options.LogOutput <> '' then
    Dir := ExpandFileto(fProjectCopy.Options.LogOutput, fProjectCopy.Directory)
  else
    Dir := fProjectCopy.Directory;
  if SelectDirectory('Select Directory', '', Dir) then
    edLogOutput.Text := ExtractRelativePath(fProjectCopy.Directory, Dir);
end;

procedure TProjectOptForm.btnMakeBrowseClick(Sender: TObject);
begin
  if dlgMakeInclude.Execute then
    edMakeInclude.Text := ExtractRelativePath(fProjectCopy.FileName, dlgMakeInclude.FileName);
  edMakeInclude.SetFocus;
end;

procedure TProjectOptForm.btnMakClick(Sender: TObject);
var
  i: Integer;
begin
  i := lbMakeIncludes.ItemIndex;
  if i < 0 then
    exit;
  if Sender = btnMakUp then begin
    lbMakeIncludes.Items.Exchange(lbMakeIncludes.ItemIndex, lbMakeIncludes.ItemIndex - 1);
    lbMakeIncludes.ItemIndex := i - 1;
  end else if Sender = btnMakDown then begin
    lbMakeIncludes.Items.Exchange(lbMakeIncludes.ItemIndex, lbMakeIncludes.ItemIndex + 1);
    lbMakeIncludes.ItemIndex := i + 1;
  end;

  UpdateMakButtons;
end;

procedure TProjectOptForm.MakButtonClick(Sender: TObject);
var
  i: Integer;
begin
  case (Sender as TComponent).Tag of
    1: begin
        lbMakeIncludes.Items[lbMakeIncludes.ItemIndex] := (edMakeInclude.Text);
      end;
    2: begin
        lbMakeIncludes.Items.Add(edMakeInclude.Text);
      end;
    3: begin
        lbMakeIncludes.DeleteSelected;
      end;
    4: begin
        i := 0;
        while i < lbMakeIncludes.Items.Count do begin
          if not FileExists(lbMakeIncludes.Items[i]) then begin
            lbMakeIncludes.Items.Delete(i);
            i := -1;
          end;
          i := i + 1;
        end;
      end;
  end;
  edMakeInclude.Clear;
  UpdateMakButtons;
end;

procedure TProjectOptForm.edMakeIncludeChange(Sender: TObject);
begin
  UpdateMakButtons;
end;

procedure TProjectOptForm.lbMakeIncludesClick(Sender: TObject);
begin
  UpdateMakButtons;
  edMakeInclude.Text := lbMakeIncludes.Items[lbMakeIncludes.Itemindex];
end;

procedure TProjectOptForm.InfoMakeBtnClick(Sender: TObject);
begin
  Application.MessageBox(
    'Dev-C++''s Makefile has two important targets:' + #13#10 +
    '- all (which builds the executable)' + #13#10 +
    '- clean (which cleans up object files)' + #13#10 + #13#10 +
    '''all'' depends on 2 targets: all-before and all-after. All-before' + #13#10 +
    'gets called before the compilation process, and all-after gets' + #13#10 +
    'called after the compilation process.' + #13#10 +
    '''clean'' depends on the target clean-custom, which gets called' + #13#10 +
    'before the cleaning process.' + #13#10 + #13#10 +
    'You can change the Makefile''s behavior by defining the targets' + #13#10 +
    'that ''all'' and ''clean'' depend on.',
    'Information', MB_ICONINFORMATION);
end;

procedure TProjectOptForm.btnHelpClick(Sender: TObject);
begin
  OpenHelpFile('index.html');
end;

procedure TProjectOptForm.chkOverrideOutputClick(Sender: TObject);
begin
  edOverridenOutput.Enabled := chkOverrideOutput.Checked;
end;

procedure TProjectOptForm.lvFilesChange(Sender: TObject; Node: TTreeNode);
var
  idx: integer;
  filetype: TExUnitType;
begin
  if not Assigned(Node) then begin
    chkCompile.Enabled := False;
    chkCompileCpp.Enabled := False;
    chkLink.Enabled := False;
    chkOverrideBuildCmd.Enabled := False;
    txtOverrideBuildCmd.Enabled := False;
    spnPriority.Enabled := False;
    Exit;
  end;

  // disable events
  chkCompile.OnClick := nil;
  chkCompileCpp.OnClick := nil;
  chkLink.OnClick := nil;
  chkOverrideBuildCmd.OnClick := nil;
  txtOverrideBuildCmd.OnChange := nil;
  spnPriority.OnChange := nil;

  idx := Integer(Node.Data);
  if (Node.Level > 0) and (idx <> -1) then begin // unit

    // Check once instead of a lot of times...
    filetype := GetFileTyp(fProjectCopy.Units[idx].FileName);

    if fProjectCopy.Units[idx].OverrideBuildCmd then
      txtOverrideBuildCmd.Text := StringReplace(fProjectCopy.Units[idx].BuildCmd, '<CRTAB>', #13#10, [rfReplaceAll])
    else
      txtOverrideBuildCmd.Text := DefaultBuildCommand(idx);
    chkOverrideBuildCmd.Checked := fProjectCopy.Units[idx].OverrideBuildCmd;

    chkCompile.Enabled := not (filetype in [utcHead, utcppHead]);
    chkCompile.Checked := fProjectCopy.Units[idx].Compile;
    chkCompileCpp.Enabled := chkCompile.Checked and (filetype in [utcSrc, utcppSrc]);
    chkCompileCpp.Checked := fProjectCopy.Units[idx].CompileCpp;
    chkLink.Enabled := chkCompile.Enabled and (filetype <> utResSrc);
    chkLink.Checked := fProjectCopy.Units[idx].Link;
    spnPriority.Enabled := chkCompile.Checked and chkCompile.Enabled;
    spnPriority.Value := fProjectCopy.Units[idx].Priority;
    chkOverrideBuildCmd.Enabled := chkCompile.Checked and (lvFiles.SelectionCount = 1) and not (filetype in [utcHead,
      utcppHead, utResSrc]);
    txtOverrideBuildCmd.Enabled := chkOverrideBuildCmd.Enabled and chkOverrideBuildCmd.Checked;
  end else begin // project parent node
    chkCompile.Enabled := False;
    chkCompileCpp.Enabled := False;
    chkLink.Enabled := False;
    chkOverrideBuildCmd.Enabled := False;
    txtOverrideBuildCmd.Enabled := False;
    spnPriority.Enabled := False;
  end;

  // enable events
  chkCompile.OnClick := @chkCompileClick;
  chkCompileCpp.OnClick := @chkCompileClick;
  chkLink.OnClick := @chkCompileClick;
  chkOverrideBuildCmd.OnClick := @chkCompileClick;
  txtOverrideBuildCmd.OnChange := @txtOverrideBuildCmdChange;
  spnPriority.OnChange := @spnPriorityChange;
end;

procedure TProjectOptForm.chkCompileClick(Sender: TObject);
  procedure DoNode(Node: TTreeNode);
  var
    I: integer;
    idx: integer;
  begin
    for I := 0 to Node.Count - 1 do begin
      idx := Integer(Node[I].Data);
      if idx <> -1 then begin // unit
        fProjectCopy.Units[idx].Compile := chkCompile.Checked;
        fProjectCopy.Units[idx].CompileCpp := chkCompileCpp.Checked;
      end else if Node[I].HasChildren then
        DoNode(Node[I]);
    end;
  end;
var
  I: integer;
  idx: integer;
begin
  for I := 0 to lvFiles.SelectionCount - 1 do begin
    idx := Integer(lvFiles.Selections[I].Data);
    if idx <> -1 then begin // unit
      fProjectCopy.Units[idx].Compile := chkCompile.Checked;
      fProjectCopy.Units[idx].CompileCpp := chkCompileCpp.Checked;
      fProjectCopy.Units[idx].Link := chkLink.Checked;
      if lvFiles.SelectionCount = 1 then begin
        fProjectCopy.Units[idx].OverrideBuildCmd := chkOverrideBuildCmd.Checked;

        txtOverrideBuildCmd.OnChange := nil;
        txtOverrideBuildCmd.Text := StringReplace(txtOverrideBuildCmd.Text, '<CRTAB>', #13#10, [rfReplaceAll]);

        spnPriority.Enabled := chkCompile.Checked;
        chkOverrideBuildCmd.Enabled := chkCompile.Checked and (GetFileTyp(fProjectCopy.Units[idx].FileName) <>
          utResSrc);
        if chkCompile.Checked and (GetFileTyp(fProjectCopy.Units[idx].FileName) = utOther) then begin
          // non-standard source files, *must* override the build command
          chkCompileCpp.Enabled := False;
          txtOverrideBuildCmd.Enabled := True;
          chkOverrideBuildCmd.Checked := True;
          if txtOverrideBuildCmd.Text = '' then
            txtOverrideBuildCmd.Text := '<override this command>';
        end else begin
          chkCompileCpp.Enabled := chkCompile.Checked and (GetFileTyp(fProjectCopy.Units[idx].FileName) <> utResSrc);
          if chkCompileCpp.Checked then begin
            txtOverrideBuildCmd.Text := StringReplace(txtOverrideBuildCmd.Text, '$(CC)', '$(CPP)', [rfReplaceAll]);
            txtOverrideBuildCmd.Text := StringReplace(txtOverrideBuildCmd.Text, '$(CFLAGS)', '$(CXXFLAGS)',
              [rfReplaceAll]);
          end else begin
            txtOverrideBuildCmd.Text := StringReplace(txtOverrideBuildCmd.Text, '$(CPP)', '$(CC)', [rfReplaceAll]);
            txtOverrideBuildCmd.Text := StringReplace(txtOverrideBuildCmd.Text, '$(CXXFLAGS)', '$(CFLAGS)',
              [rfReplaceAll]);
          end;
          txtOverrideBuildCmd.Enabled := chkOverrideBuildCmd.Enabled and chkOverrideBuildCmd.Checked;
        end;
        fProjectCopy.Units[idx].BuildCmd := txtOverrideBuildCmd.Text;
        txtOverrideBuildCmd.OnChange := @txtOverrideBuildCmdChange;
      end;
    end else if lvFiles.Selections[I].HasChildren then
      DoNode(lvFiles.Selections[I]);
  end;
end;

procedure TProjectOptForm.InitVersionInfo;
//var
//  I: integer;
begin
  with fProjectCopy.Options.VersionInfo do begin
    chkVersionInfo.Checked := fProjectCopy.Options.IncludeVersionInfo;
    chkVersionInfoClick(nil);

    vleVersion.Strings.Clear;
//    vleVersion.DefaultRowHeight := 24;
    vleVersion.InsertRow('File Description', FileDescription, True);
    vleVersion.InsertRow('File Version', FileVersion, True);
    vleVersion.InsertRow('Product Name', ProductName, True);
    vleVersion.InsertRow('Product Version', ProductVersion, True);
    vleVersion.InsertRow('Original Filename', OriginalFilename, True);
    vleVersion.InsertRow('Internal Name', InternalName, True);
    vleVersion.InsertRow('Company Name', CompanyName, True);
    vleVersion.InsertRow('Legal Copyright', LegalCopyright, True);
    vleVersion.InsertRow('Legal Trademarks', LegalTrademarks, True);

    spnMajor.Value := Major;
    spnMinor.Value := Minor;
    spnRelease.Value := Release;
    spnBuild.Value := Build;
    chkAutoIncBuild.Checked := AutoIncBuildNr;
    chkSyncProduct.Checked := SyncProduct;

    cmbLangID.Items.Clear;
    cmbLangID.Items.BeginUpdate; // prevent redraws
    try
//      for I := 0 to Languages.Count - 1 do // TODO: ATSynEdit - Languages not available in FPC
//        cmbLangID.Items.Add(Languages.Name[i]); // TODO: ATSynEdit - Languages not available in FPC
//      cmbLangID.ItemIndex := cmbLangID.Items.IndexOf(Languages.NameFromLocaleID[LanguageID]); // TODO: ATSynEdit - Languages not available in FPC
    except
      MessageDlg(Lang[ID_POPT_LANGUAGEDEP], mtInformation, [mbOK], 0);
      cmbLangID.Visible := false;
      lblVerLang.Visible := false;
    end;
    cmbLangID.Items.EndUpdate;
  end;
end;

procedure TProjectOptForm.chkVersionInfoClick(Sender: TObject);
begin
  spnMajor.Enabled := chkVersionInfo.Checked;
  spnMinor.Enabled := chkVersionInfo.Checked;
  spnRelease.Enabled := chkVersionInfo.Checked;
  spnBuild.Enabled := chkVersionInfo.Checked;
  cmbLangID.Enabled := chkVersionInfo.Checked;
  vleVersion.Enabled := chkVersionInfo.Checked;
  chkAutoIncBuild.Enabled := chkVersionInfo.Checked;
  chkSyncProduct.Enabled := chkVersionInfo.Checked;
end;

procedure TProjectOptForm.cmbCompilerChange(Sender: TObject);

begin
  if fOldIndex = cmbCompiler.ItemIndex then
    Exit;

  // If true, continue, otherwise, revert selection change
  if (fOldIndex <> -1) and (MessageDlg(Lang[ID_POPT_DISCARDCUSTOM], mtConfirmation, [mbYes, mbNo], 0) = mrNo) then begin
    cmbCompiler.ItemIndex := fOldIndex;
    Exit;
  end;

  // Discard changes made to the old set...
  if fOldIndex <> -1 then
    devCompilerSets.LoadSet(fOldIndex);

  // And update UI
  //CompOptionsFrame1.fCurrentIndex := cmbCompiler.ItemIndex;
  //CompOptionsFrame1.FillOptions;
  FillOptions(Self);

  fOldIndex := cmbCompiler.ItemIndex;
end;

procedure TProjectOptForm.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TProjectOptForm.btnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TProjectOptForm.lstTypeClick(Sender: TObject);
begin
  chkSupportXP.Enabled := (lstType.ItemIndex = 0);
end;

procedure TProjectOptForm.btnAddLibClick(Sender: TObject);
var
  s: String;
  i: integer;
begin
  with TOpenDialog.Create(Self) do try
    Filter := BuildFilter([FLT_LIBRARIES]);
    Options := Options + [ofAllowMultiSelect];

    // Start in the lib folder
    if Assigned(devCompilerSets.CompilationSet) and (devCompilerSets.CompilationSet.LibDir.Count > 0) then
      InitialDir := devCompilerSets.CompilationSet.LibDir[0];

    if Execute then begin
      for i := 0 to Files.Count - 1 do begin
        S := ExtractRelativePath(fProjectCopy.Directory, Files[i]);
        S := GenMakePath1(S);
        edLinker.Lines.Add(S);
      end;
    end;
  finally
    Free;
  end;
end;

function TProjectOptForm.DefaultBuildCommand(idx: integer): String;
var
  tfile, ofile: String;
begin
  Result := '';
  if not (GetFileTyp(fProjectCopy.Units[idx].FileName) in [utcSrc, utcppSrc]) then
    Exit;

  tfile := ExtractFileName(fProjectCopy.Units[idx].FileName);
  if fProjectCopy.Options.ObjectOutput <> '' then begin
    ofile := IncludeTrailingPathDelimiter(fProjectCopy.Options.ObjectOutput) + ExtractFileName(tfile);
    ofile := GenMakePath1(ExtractRelativePath(fProjectCopy.FileName, ChangeFileExt(ofile, OBJ_EXT)));
  end else
    ofile := GenMakePath1(ChangeFileExt(tfile, OBJ_EXT));
  if fProjectCopy.Units[idx].CompileCpp then
    Result := '$(CPP) -c ' + GenMakePath1(tfile) + ' -o ' + ofile + ' $(CXXFLAGS)'
  else
    Result := '$(CC) -c ' + GenMakePath1(tfile) + ' -o ' + ofile + ' $(CFLAGS)';
end;

procedure TProjectOptForm.txtOverrideBuildCmdChange(Sender: TObject);
var
  idx: integer;
begin
  if not Assigned(lvFiles.Selected) or not txtOverrideBuildCmd.Enabled then
    Exit;
  idx := Integer(lvFiles.Selected.Data);
  if (lvFiles.Selected.Level > 0) and (idx <> -1) then // unit
    fProjectCopy.Units[idx].BuildCmd := StringReplace(txtOverrideBuildCmd.Text, #13#10, '<CRTAB>', [rfReplaceAll]);
end;

procedure TProjectOptForm.spnPriorityChange(Sender: TObject);
var
  I, idx: integer;
begin
  if not Assigned(lvFiles.Selected) or not spnPriority.Enabled then
    Exit;
  for I := 0 to lvFiles.SelectionCount - 1 do begin
    idx := Integer(lvFiles.Selections[I].Data);
    if (lvFiles.Selections[I].Level > 0) and (idx <> -1) then // unit
      fProjectCopy.Units[idx].Priority := spnPriority.Value;
  end;
end;

procedure TProjectOptForm.btnCustomMakeBrowseClick(Sender: TObject);
begin
  if dlgCustomMake.Execute then
    edCustomMakefile.Text := ExtractRelativePath(fProjectCopy.FileName, dlgCustomMake.FileName);
  edCustomMakefile.SetFocus;
end;

procedure TProjectOptForm.cbANSIClick(Sender: TObject);
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

procedure TProjectOptForm.cbUseCustomMakefileClick(Sender: TObject);
  procedure ColorDisabled(W: TWinControl);
  begin
    if not W.Enabled then
      W.Brush.Color := clBtnFace
    else
      W.Brush.Color := clDefault;  //clWindow;
    W.Repaint;
  end;
begin
  edCustomMakefile.Enabled := cbUseCustomMakefile.Checked;
  btnCustomMakeBrowse.Enabled := cbUseCustomMakefile.Checked;
  InfoMakeBtn.Enabled := not cbUseCustomMakefile.Checked;
  lbMakeIncludes.Enabled := not cbUseCustomMakefile.Checked;
  edMakeInclude.Enabled := not cbUseCustomMakefile.Checked;
  btnMakUp.Enabled := not cbUseCustomMakefile.Checked;
  btnMakDown.Enabled := not cbUseCustomMakefile.Checked;
  btnMakeBrowse.Enabled := not cbUseCustomMakefile.Checked;
  btnMakReplace.Enabled := not cbUseCustomMakefile.Checked;
  btnMakAdd.Enabled := not cbUseCustomMakefile.Checked;
  btnMakDelete.Enabled := not cbUseCustomMakefile.Checked;
  btnMakDelInval.Enabled := not cbUseCustomMakefile.Checked;

  // I want the disabled controls to be *shown* as disabled...
  ColorDisabled(edCustomMakefile);
  ColorDisabled(edMakeInclude);
  ColorDisabled(lbMakeIncludes);

  UpdateMakButtons;
end;

procedure TProjectOptForm.lbMakeIncludesDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State:
  TOwnerDrawState);
begin
  btnMakUp.Enabled := lbMakeIncludes.Items.Count > 0;
  btnMakDown.Enabled := lbMakeIncludes.Items.Count > 0;
end;

procedure TProjectOptForm.chkLogOutputClick(Sender: TObject);
begin
  edLogOutput.Enabled := chkLogOutput.Checked;
end;

procedure TProjectOptForm.OptionsLinkClick(Sender: TObject);
begin
  OpenURL(TLabel(Sender).Caption);
end;

procedure TProjectOptForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  // Correct memory leak in VCL
  //CompOptionsFrame1.vle.Strings.Clear;

  CloseAction := caFree;
end;

end.

