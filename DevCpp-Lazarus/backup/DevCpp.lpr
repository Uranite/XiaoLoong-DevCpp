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

program DevCpp;

{$MODE Delphi}

// TODO: ATSynEdit - disabled resource compilation (needs windres setup)
{$R 'icons.res' 'icons.rc'}
//{$R 'DefaultFiles.res'}
//{$R 'mainicon.res'}

uses
  LCLIntf, LCLType, Forms, printer4lazarus, Interfaces, sysUtils,
  uMetaDarkStyle, uDarkStyleParams, udarkstyleschemes,
{$IFDEF MSWINDOWS}
  Windows, ShlObj, //SHFolder,
{$ENDIF}
  CBUtils,
  main in 'main.pas' {MainForm},
  CodeToolTip in 'CodeToolTip.pas',
  ExceptionFrm in 'ExceptionFrm.pas' {ExceptionFrm},
  FileAssocs in 'FileAssocs.pas',
  //Instances in 'Instances.pas',
  //MultiLangSupport in 'MultiLangSupport.pas',
  //Utils in 'Utils.pas',
  //Tests in 'Tests.pas',
  //LangFrm in 'LangFrm.pas' {LangForm},
  //Project in 'Project.pas',
  //Templates in 'Templates.pas',
  //NewProjectFrm in 'NewProjectFrm.pas' {NewProjectForm},
  //RemoveUnitFrm in 'RemoveUnitFrm.pas' {RemoveUnitForm},
  //GotoLineFrm in 'GotoLineFrm.pas' {GotoLineForm},
  //PrintFrm in 'PrintFrm.pas' {PrintForm},
  //AboutFrm in 'AboutFrm.pas' {AboutForm},
  //Compiler in 'Compiler.pas',
  //devrun in 'devrun.pas',
  //ProjectOptionsFrm in 'ProjectOptionsFrm.pas' {ProjectOptionsForm},
  //ToolFrm in 'ToolFrm.pas' {ToolFrom},
  //ToolEditFrm in 'ToolEditFrm.pas' {ToolEditForm},
  //IconFrm in 'IconFrm.pas' {IconForm},
  //DataFrm in 'DataFrm.pas' {dmMain: TDataModule},
  //EditorOptFrm in 'EditorOptFrm.pas' {EditorOptForm},
  //CodeInsList in 'CodeInsList.pas',
  //IncrementalFrm in 'IncrementalFrm.pas' {IncrementalForm},
  //FindFrm in 'FindFrm.pas' {FindForm},
  //Editor in 'Editor.pas',
  //EnviroFrm in 'EnviroFrm.pas' {EnviroForm},
  //DebugReader in 'DebugReader.pas',
  //Debugger in 'Debugger.pas',
  //EditorList in 'EditorList.pas',
  //ProjectTypes in 'ProjectTypes.pas',
  //Macros in 'Macros.pas',
  //devExec in 'devExec.pas',
  //NewTemplateFrm in 'NewTemplateFrm.pas' {NewTemplateForm},
  //FunctionSearchFrm in 'FunctionSearchFrm.pas' {FunctionSearchForm},
  //NewVarFrm in 'NewVarFrm.pas' {NewVarForm},
  //NewFunctionFrm in 'NewFunctionFrm.pas' {NewFunctionForm},
  //NewClassFrm in 'NewClassFrm.pas' {NewClassForm},
  //ProfileAnalysisFrm in 'ProfileAnalysisFrm.pas' {ProfileAnalysisForm},
  //FilePropertiesFrm in 'FilePropertiesFrm.pas' {FilePropertiesForm},
  //AddToDoFrm in 'AddToDoFrm.pas' {AddToDoForm},
  //ViewToDoFrm in 'ViewToDoFrm.pas' {ViewToDoForm},
  //ImportMSVCFrm in 'ImportMSVCFrm.pas' {ImportMSVCForm},
  //ImportCBFrm in 'ImportCBFrm.pas' {ImportCBForm},
  //CPUFrm in 'CPUFrm.pas' {CPUForm},
  //TipOfTheDayFrm in 'TipOfTheDayFrm.pas' {TipOfTheDayForm},
  //WindowListFrm in 'WindowListFrm.pas' {WindowListForm},
  //ParamsFrm in 'ParamsFrm.pas' {ParamsForm},
  //CompOptionsFrm in 'CompOptionsFrm.pas' {CompOptionsForm},
  //FormatterOptionsFrm in 'FormatterOptionsFrm.pas' {FormatterOptionsForm},
  //ProcessListFrm in 'ProcessListFrm.pas' {ProcessListForm},
  //ImageTheme in 'ImageTheme.pas',
  // TODO: ATSynEdit - Vcl.Themes and Vcl.Styles are Delphi-specific
  //Vcl.Themes,
  //Vcl.Styles,
  //ShortcutsFrm in 'ShortcutsFrm.pas' {ShortcutsForm},
  //devFileMonitor in 'devFileMonitor.pas',
  //ClassBrowser in 'ClassBrowser.pas',
  //CodeCompletion in 'CodeCompletion.pas',
  //CodeCompletionForm in 'CodeCompletionForm.pas' {CodeComplForm},
  //CppParser in 'CppParser.pas',
  //CppTokenizer in 'CppTokenizer.pas',
  //StatementList in 'StatementList.pas',
  //UpdateCheck, HomepageFrm, EnvironOptfrm,
  //FormatterOptFrm, CompilerOptFrm, FileEncodingFrm,
  CppPreprocessor in 'CppPreprocessor.pas',
  devcfg in 'devcfg.pas',
  Version in 'Version.pas', ConfigData;

{$R *.res}
{$R 'lexers.res' 'lexers.rc'}

var
  AppData, INIFileName, ExeFolder: String;
  Buffer: array[0..MAX_PATH] of char = '';

begin
  // Single instance check is now handled by TSingleInstance component in main.pas
  // No need to check here anymore

  // Read INI filename
  INIFileName := 'XL7' + ChangeFileExt(ExtractFileName(Application.ExeName), INI_EXT);  //XLDevCpp.ini
  ExeFolder := ExtractFilePath(Application.ExeName);

  // Create config files directory
  // Set devData.INIFileName, ConfigMode
  // Did someone pass the -c command to us?
  if (ParamCount >= 2) and (CompareStr(ParamStr(1),'-c') = 0) { *Converted from SameStr* } then begin
    if not DirectoryExists(ParamStr(2)) then
      CreateDir(ParamStr(2));

    // Store the INI file in the directory given to us
    if ParamStr(2)[2] <> ':' then // if a relative path is specified...
      devData.INIFileName := ExeFolder + IncludeTrailingPathDelimiter(ParamStr(2)) + INIFileName
    else
      devData.INIFileName := IncludeTrailingPathDelimiter(ParamStr(2)) + INIFileName;
  end else begin
    // Default config directory
{$IFDEF MSWINDOWS}
    AppData := '';
    if SUCCEEDED(SHGetFolderPath(0, CSIDL_APPDATA, 0, 0, Buffer)) then
      AppData := IncludeTrailingBackslash(Buffer);
    if (AppData <> '') and (DirectoryExists(AppData + 'Dev-Cpp') or CreateDir(AppData + 'Dev-Cpp')) then
      devData.INIFileName := AppData + 'Dev-Cpp\' + INIFileName
    else
      devData.INIFileName := ExeFolder + 'config\' + INIFileName;
{$ELSE}
    // Linux/macOS: use XDG_CONFIG_HOME (falls back to $HOME/.config)
    AppData := GetEnvironmentVariable('XDG_CONFIG_HOME');
    if (AppData = '') or not DirectoryExists(AppData) then
      AppData := GetEnvironmentVariable('HOME') + '/.config';
    if DirectoryExists(AppData + '/Dev-Cpp') or CreateDir(AppData + '/Dev-Cpp') then
      devData.INIFileName := AppData + '/Dev-Cpp/' + INIFileName
    else
      devData.INIFileName := ExeFolder + 'config/' + INIFileName;
{$ENDIF}
  end;

  // free ansistrings...
  SetLength(AppData, 0);
  SetLength(INIFileName, 0);
  SetLength(ExeFolder, 0);

  // Load settings
  devData.ReadSelf;
  CreateOptions;

  // Create main window
  Application.Scaled:=True;

  // ===== 深色模式初始化（必须在 Application.Initialize 之前）=====
  // PreferredAppMode 必须在 Initialize 内部主题检测之前设置，否则无效
  if devData.AppMode = 2 then
    PreferredAppMode := pamForceDark;
  else if devData.AppMode = 3 then
    PreferredAppMode := pamForceLight;
  else
    PreferredAppMode := pamAllowDark;
  // 可选值：
  //   pamDefault      = 不干预（浅色）
  //   pamAllowDark    = 跟随系统深色（推荐）
  //   pamForceDark    = 强制深色（无视系统）
  //   pamForceLight   = 强制浅色

  Application.Initialize;
  ApplyMetaDarkStyle(DefaultDark);

  Application.CreateForm(TMainForm, MainForm);
  //Application.CreateForm(TCodeComplForm, CodeComplForm);
  //Application.CreateForm(TShortcutsForm, ShortcutsForm);
  Application.Run;

end.

