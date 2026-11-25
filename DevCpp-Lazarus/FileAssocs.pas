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

unit FileAssocs;

interface

uses
  {$IFDEF MSWINDOWS}
    {$IFDEF MSWINDOWS}Registry{$ENDIF}, {$IFDEF MSWINDOWS}ShlObj{$ENDIF},
  {$ENDIF}
  SysUtils, Classes, Forms;

procedure RegisterFiletype(const extension, filetype, description, verb, serverapp, IcoNum: String);
procedure RegisterDDEServer(const filetype, verb, topic, servername, macro: String);
procedure UnregisterDDEServer(const filetype, verb: String);
procedure RemoveDDERegistrations;
procedure CheckAssociations(FixAssocs: boolean);
procedure Associate(Index: integer);
procedure UnAssociate(Index: integer);
function IsAssociated(Index: integer): boolean;
function MustAssociate(Index: integer): boolean;
function CheckFiletype(const extension, filetype, description, verb, serverapp: String): boolean;

var
  DDETopic: String;

const
  // if you change anything here, update devcfg.pas, specifically devData...
  // and update MustAssociate(), Associate() and UnAssociate() below
  AssociationsCount = 11;
  // field 1 is the extension (no dot)
  // field 2 is the description
  // field 3 is the icon number
  // field 4 is obsolete. It used to mean: "" = register a DDE server,
  // non-empty = launch a new instance. Dev-C++ no longer uses DDE: a running
  // instance is reused via the FCL single-instance component (TAdvancedSingleInstance
  // in main.pas). The field is kept only to preserve the array layout.
  Associations: array[0..10, 0..3] of String = (
    ('dev', 'Dev-C++ Project File', '3', 'xxx'),
    ('c',   'C Source File', '4', ''),
    ('cpp', 'C++ Source File', '5', ''),
    ('cxx', 'C++ Source File', '5', ''),
    ('h',   'C Header File', '6', ''),
    ('hpp', 'C++ Header File', '7', ''),
    ('hxx', 'C++ Header File', '7', ''),
    ('rc',  'Resource Source File', '8', ''),
    ('devt', 'Dev-C++ Template File', '11', ''),
    ('f77', 'FORTRAN 77 Source File', '12', ''),
    ('f90', 'FORTRAN 90/95 Source File', '13', '')
     );

// Linux only: map file extensions to XDG MIME types
{$IFDEF LINUX}
function ExtToMimeType(const Ext: String): String;
function GetDesktopFilePath(const ext: String): String;
procedure RefreshLinuxIcons;
{$ENDIF}

implementation

uses devcfg;

var
  Associated: array[0..AssociationsCount - 1] of boolean;

// ─── Linux helpers (skipped on Windows) ───────────────────────────────────────
{$IFDEF LINUX}

uses Process;

function ExtToMimeType(const Ext: String): String;
var
  PureExt: String;
begin
  // Remove leading dot if present
  if Pos('.', Ext) = 1 then
    PureExt := Copy(Ext, 2, Length(Ext))
  else
    PureExt := Ext;
  // Map known extensions to XDG MIME types (cannot use case on string in FPC)
  if PureExt = 'c' then
    Result := 'text/x-csrc'
  else if (PureExt = 'cpp') or (PureExt = 'cxx') then
    Result := 'text/x-c++src'
  else if PureExt = 'h' then
    Result := 'text/x-chdr'
  else if (PureExt = 'hpp') or (PureExt = 'hxx') then
    Result := 'text/x-c++hdr'
  else if PureExt = 'dev' then
    Result := 'application/x-dev-cpp-project'
  else if PureExt = 'rc' then
    Result := 'text/x-rc'
  else if PureExt = 'template' then
    Result := 'application/x-dev-cpp-template'
  else if (PureExt = 'f77') or (PureExt = 'f90') then
    Result := 'text/x-fortran'
  else
    Result := 'text/plain';
end;

function GetDesktopFilePath(const ext: String): String;
begin
  Result := GetEnvironmentVariable('HOME') + '/.local/share/applications/dev-cpp-' + ext + '.desktop';
end;

procedure RefreshLinuxIcons;
var
  P: TProcess;
  HomeDir, IconDir: String;
begin
  // Try to update icon cache so new file type icons appear immediately
  HomeDir := GetEnvironmentVariable('HOME');
  IconDir := HomeDir + '/.local/share/icons/hicolor';
  P := TProcess.Create(nil);
  try
    P.Executable := 'gtk-update-icon-cache';
    P.Parameters.Add('-f');
    P.Parameters.Add('-t');
    P.Parameters.Add(IconDir);
    P.Options := [poWaitOnExit];
    try
      P.Execute;
    except
      // Silently ignore if gtk-update-icon-cache is not available
    end;
  finally
    P.Free;
  end;
end;

{$ENDIF} // LINUX

// ─── Shared ─────────────────────────────────────────────────────────────────

procedure RefreshIcons;
begin
{$IFDEF MSWINDOWS}
  SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
{$ELSE}
  RefreshLinuxIcons;
{$ENDIF}
end;

function IsAssociated(Index: integer): boolean;
begin
  Result := Associated[Index];
end;

function MustAssociate(Index: integer): boolean;
begin
  case Index of
    0: Result := devData.AssociateC;
    1: Result := devData.AssociateCpp;
    2: Result := devData.AssociateCxx;
    3: Result := devData.AssociateH;
    4: Result := devData.AssociateHpp;
    5: Result := devData.AssociateHxx;
    6: Result := devData.AssociateDev;
    7: Result := devData.AssociateRc;
    8: Result := devData.AssociateTemplate;
    9: Result := devData.AssociateF77;
    10: Result := devData.AssociateF90;
  else
    Result := False;
  end;
end;

// ─── Windows implementation ───────────────────────────────────────────────────

{$IFDEF MSWINDOWS}

procedure UnAssociate(Index: integer);
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.Rootkey := HKEY_CLASSES_ROOT;
    if reg.KeyExists('DevCpp.' + Associations[Index, 0]) then begin
      reg.DeleteKey('.' + Associations[Index, 0]);
      reg.DeleteKey('DevCpp.' + Associations[Index, 0]);
    end;
  finally
    reg.free;
  end;
  Associated[Index] := False;
  case Index of
    0: devData.AssociateC := False;
    1: devData.AssociateCpp := False;
    2: devData.AssociateCxx := False;
    3: devData.AssociateH := False;
    4: devData.AssociateHpp := False;
    5: devData.AssociateHxx := False;
    6: devData.AssociateDev := False;
    7: devData.AssociateRc := False;
    8: devData.AssociateTemplate := False;
    9: devData.AssociateF77 := False;
    10: devData.AssociateF90 := False;
  end;
  RefreshIcons;
end;

procedure Associate(Index: integer);
//var
//  s: String;
begin

  RegisterFiletype(
    '.' + Associations[Index, 0],
    'DevCpp.' + Associations[Index, 0],
    Associations[Index, 1],
    'open',
    Application.Exename + ' "%1"',
    Associations[Index, 2]);
  // Dev-C++ is not a DDE server: a running instance is reused through the FCL
  // single-instance component (TAdvancedSingleInstance in main.pas), which
  // forwards the file name via IPC. A leftover 'ddeexec' key is actively
  // harmful: on Windows 7/8 Explorer starts a DDE conversation first, waits
  // ~10 s for a server that never answers, shows "向程序发送命令时出现问题"
  // and only then falls back to the plain command line (which is why the file
  // opens so late). Windows 10/11 ignore DDE, so the bug is invisible there.
  // Remove any stale key left behind by earlier versions.
  UnregisterDDEServer('DevCpp.' + Associations[Index, 0], 'open');
  Associated[Index] := True;
  case Index of
    0: devData.AssociateC := True;
    1: devData.AssociateCpp := True;
    2: devData.AssociateCxx := True;
    3: devData.AssociateH := True;
    4: devData.AssociateHpp := True;
    5: devData.AssociateHxx := True;
    6: devData.AssociateDev := True;
    7: devData.AssociateRc := True;
    8: devData.AssociateTemplate := True;
    9: devData.AssociateF77 := True;
    10: devData.AssociateF90 := True;
  end;
  RefreshIcons;
end;

function CheckFiletype(const extension, filetype, description,
  verb, serverapp: String): boolean;
var
  reg: TRegistry;
  keystring: String;
  regdfile: String;
begin
  reg := TRegistry.Create;
  try
    Result := False;
    reg.Rootkey := HKEY_CLASSES_ROOT;
    if not reg.OpenKey(extension, False) then // does not prevent exception throwing
      Exit;
    reg.CloseKey;
    if not reg.OpenKey(filetype, False) then
      Exit;
    reg.closekey;
    keystring := Format('%s\shell\%s\command', [filetype, verb]);
    if not reg.OpenKey(keystring, False) then
      Exit;
    regdfile := reg.ReadString('');
    reg.CloseKey;
    if CompareText(regdfile, serverapp) <> 0 then
      Exit;
    Result := True;
  finally
    reg.free;
  end;
end;

procedure RegisterFiletype(const extension, filetype, description,
  verb, serverapp, IcoNum: String);
var
  reg: TRegistry;
  keystring: String;
begin
  reg := TRegistry.Create;
  try
    reg.Rootkey := HKEY_CLASSES_ROOT;
    if not reg.OpenKey(extension, True) then
      Exit;
    reg.WriteString('', filetype);
    reg.CloseKey;
    if not reg.OpenKey(filetype, True) then
      Exit;
    reg.WriteString('', description);
    reg.closekey;
    keystring := Format('%s\shell\%s\command', [filetype, verb]);
    if not reg.OpenKey(keystring, True) then
      Exit;
    reg.WriteString('', serverapp);
    reg.CloseKey;
    if not reg.OpenKey(filetype + '\DefaultIcon', True) then
      Exit;
    reg.WriteString('', Application.ExeName + ',' + IcoNum);
    reg.CloseKey;
    RefreshIcons;
  finally
    reg.free;
  end;
end;

// Deletes the obsolete 'ddeexec' key for a file type. Dev-C++ is not a DDE
// server (see Associate), so any such key must be removed; otherwise Explorer
// on Windows 7/8 waits ~10 s for a DDE conversation and then reports
// "向程序发送命令时出现问题". Silently does nothing when the key is absent.
procedure UnregisterDDEServer(const filetype, verb: String);
var
  reg: TRegistry;
  sub: TStringList;
  key: String;
  I: Integer;
begin
  reg := TRegistry.Create;
  try
    reg.Rootkey := HKEY_CLASSES_ROOT;
    key := Format('%s\shell\%s\ddeexec', [filetype, verb]);
    if not reg.KeyExists(key) then
      Exit;
    // Delete the subkeys first: some Windows versions refuse to remove a key
    // that still has subkeys ('ddeexec' normally holds \Application & \topic).
    sub := TStringList.Create;
    try
      if reg.OpenKey(key, False) then
      try
        reg.GetKeyNames(sub);
      finally
        reg.CloseKey;
      end;
      for I := 0 to sub.Count - 1 do
        reg.DeleteKey(key + '\' + sub[I]);
    finally
      sub.Free;
    end;
    reg.DeleteKey(key);
  finally
    reg.free;
  end;
end;

// Removes the obsolete DDE registration for every file type we know about.
// Called once at shutdown (right after CheckAssociations), so there is no
// need for a fast probe path: all 11 file types are checked and cleaned.
// Safe to call unconditionally: registry errors are swallowed because the
// process may not have write access to HKEY_CLASSES_ROOT.
procedure RemoveDDERegistrations;
var
  I: Integer;
begin
  for I := 0 to AssociationsCount - 1 do
    try
      UnregisterDDEServer('DevCpp.' + Associations[I, 0], 'open');
    except
      // Registry not writable (e.g. not elevated) - nothing we can do here.
    end;
end;

procedure RegisterDDEServer(const filetype, verb, topic, servername, macro:
  String);
var
  reg: TRegistry;
  keystring: String;
begin
  reg := TRegistry.Create;
  try
    reg.Rootkey := HKEY_CLASSES_ROOT;
    keystring := Format('%s\shell\%s\ddeexec', [filetype, verb]);
    if not reg.OpenKey(keystring, True) then
      Exit;
    reg.WriteString('', macro);
    reg.CloseKey;
    if not reg.OpenKey(keystring + '\Application', True) then
      Exit;
    reg.WriteString('', servername);
    reg.CloseKey;
    if not reg.OpenKey(keystring + '\topic', True) then
      Exit;
    reg.WriteString('', topic);
    reg.CloseKey;
  finally
    reg.free;
  end;
end;

procedure CheckAssociations(FixAssocs: boolean);  //MS-Windows
var
  I: integer;
begin
  if FixAssocs then
    for I := 0 to AssociationsCount - 1 do begin
      if MustAssociate(I) then
        Associate(I);
      // Also drop any obsolete DDE registration left by an earlier version,
      // including for types that are no longer associated (see Associate).
      UnregisterDDEServer('DevCpp.' + Associations[I, 0], 'open');
    end;
end;

{$ENDIF}  // close MSWINDOWS

{$IFDEF LINUX}  // ─────────────── Linux implementation ───────────────────────────────

procedure UnAssociate(Index: integer);
var
  DesktopPath, MIMEType: String;
  Ext: String;
  P: TProcess;
begin
  Ext := Associations[Index, 0];
  DesktopPath := GetDesktopFilePath(Ext);
  // Remove desktop file
  if FileExists(DesktopPath) then
    DeleteFile(DesktopPath);
  // Clear MIME default via xdg-mime
  MIMEType := ExtToMimeType('.' + Ext);
  P := TProcess.Create(nil);
  try
    P.Executable := 'xdg-mime';
    P.Parameters.Add('default');
    P.Parameters.Add('none');
    P.Parameters.Add(MIMEType);
    P.Options := [poWaitOnExit];
    try
      P.Execute;
    except
      // Silently ignore if xdg-mime fails
    end;
  finally
    P.Free;
  end;
  Associated[Index] := False;
  case Index of
    0: devData.AssociateC := False;
    1: devData.AssociateCpp := False;
    2: devData.AssociateCxx := False;
    3: devData.AssociateH := False;
    4: devData.AssociateHpp := False;
    5: devData.AssociateHxx := False;
    6: devData.AssociateDev := False;
    7: devData.AssociateRc := False;
    8: devData.AssociateTemplate := False;
    9: devData.AssociateF77 := False;
    10: devData.AssociateF90 := False;
  end;
  RefreshIcons;
end;

procedure WriteDesktopFile(const Ext, Description, ExeCmd, MIMEType: String);
var
  DesktopPath, AppsDir, MIMETypeFile: String;
  F: TextFile;
  IconName: String;
begin
  // Ensure ~/.local/share/applications/ exists
  AppsDir := GetEnvironmentVariableUTF8('HOME') + '/.local/share/applications/';
  if not DirectoryExists(AppsDir) then
    ForceDirectories(AppsDir);

  DesktopPath := GetDesktopFilePath(Ext);
  IconName := 'devcpp';  // Use the app's default icon name

  AssignFile(F, DesktopPath);
  Rewrite(F);
  try
    WriteLn(F, '[Desktop Entry]');
    WriteLn(F, 'Type=Application');
    WriteLn(F, 'Version=1.0');
    WriteLn(F, 'Name=Dev-C++ (' + Description + ')');
    WriteLn(F, 'Comment=Dev-C++ IDE - ' + Description);
    WriteLn(F, 'Exec=' + ExeCmd);
    WriteLn(F, 'Icon=' + IconName);
    WriteLn(F, 'MimeType=' + MIMEType + ';');
    WriteLn(F, 'Terminal=false');
    WriteLn(F, 'Categories=Development;IDE;');
    WriteLn(F, 'StartupNotify=true');
  finally
    CloseFile(F);
  end;
end;

procedure RegisterMimeType(const MIMEType, DesktopFile: String);
var
  P: TProcess;
begin
  // xdg-mime default dev-cpp-<ext>.desktop <mime-type>
  P := TProcess.Create(nil);
  try
    P.Executable := 'xdg-mime';
    P.Parameters.Add('default');
    P.Parameters.Add(ExtractFilename(DesktopFile));
    P.Parameters.Add(MIMEType);
    P.Options := [poWaitOnExit];
    try
      P.Execute;
    except
      // Silently ignore if xdg-mime fails
    end;
  finally
    P.Free;
  end;
end;

procedure Associate(Index: integer);
var
  Ext, MIMEType, DesktopPath, ExeCmd: String;
begin
  Ext := Associations[Index, 0];
  MIMEType := ExtToMimeType('.' + Ext);
  DesktopPath := GetDesktopFilePath(Ext);
  // Build Exec command with proper quoting for Linux
  ExeCmd := Application.Exename + ' %F';

  WriteDesktopFile(Ext, Associations[Index, 1], ExeCmd, MIMEType);
  RegisterMimeType(MIMEType, DesktopPath);

  Associated[Index] := True;
  case Index of
    0: devData.AssociateC := True;
    1: devData.AssociateCpp := True;
    2: devData.AssociateCxx := True;
    3: devData.AssociateH := True;
    4: devData.AssociateHpp := True;
    5: devData.AssociateHxx := True;
    6: devData.AssociateDev := True;
    7: devData.AssociateRc := True;
    8: devData.AssociateTemplate := True;
    9: devData.AssociateF77 := True;
    10: devData.AssociateF90 := True;
  end;
  RefreshIcons;
end;

function CheckFiletype(const extension, filetype, description,
  verb, serverapp: String): boolean;
begin
  // Linux: check if our desktop file exists for this extension
  // 'extension' here is e.g. '.c', we strip the dot for the desktop file name
  Result := FileExists(GetDesktopFilePath(Copy(extension, 2, Length(extension))));
end;

procedure RegisterFiletype(const extension, filetype, description,
  verb, serverapp, IcoNum: String);
begin
  // On Linux: the desktop file + MIME registration is handled entirely
  // in Associate(). This is a no-op on Linux since we don't do per-type
  // registration separately from the full Associate() flow.
end;

procedure RegisterDDEServer(const filetype, verb, topic, servername, macro:
  String);
begin
  // DDE has no equivalent on Linux; no-op
end;

procedure UnregisterDDEServer(const filetype, verb: String);
begin
  // DDE has no equivalent on Linux; no-op
end;

procedure RemoveDDERegistrations;
begin
  // DDE has no equivalent on Linux; no-op
end;

procedure CheckAssociations(FixAssocs: boolean);  //Linux
var
  I: integer;
begin
  // Check if each association's desktop file exists
  for I := 0 to AssociationsCount - 1 do
    Associated[I] := FileExists(GetDesktopFilePath(Associations[I, 0]));

  if FixAssocs then
    for I := 0 to AssociationsCount - 1 do
      if MustAssociate(I) and not Associated[I] then
        Associate(I);
end;

{$ENDIF}  // ─────────── end Linux implementation ───────────────────────────────

end.
