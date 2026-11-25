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

unit Debugger;

interface

uses
  Sysutils, Forms, Classes, Controls, Process,
  debugreader, version, editor, ComCtrls, Dialogs, MultiLangSupport;

type

  TEvalReadyEvent = procedure(const evalvalue: AnsiString) of object;

  TDebugger = class(TObject)
  private
    fGDBProcess: TProcess;
    fExecuting: boolean;
    fCommandChanged: boolean;
    fDebugView: TTreeView;
    fLeftPageIndexBackup: integer;
    fBreakPointList: TList;
    fWatchVarList: TList;
    fOnEvalReady: TEvalReadyEvent;
    fReader: TDebugReader;
    function GetBreakPointFile: AnsiString;
  public
    constructor Create;
    destructor Destroy; override;

    // Play/pause
    procedure Start;
    procedure Stop;
    procedure SendCommand(const command, params: AnsiString; viewinui: boolean = false);

    // breakpoints
    procedure AddBreakPoint(i: integer); overload;
    procedure RemoveBreakPoint(i: integer); overload;
    procedure AddBreakPoint(Linein: integer; e: TEditor); overload;
    procedure RemoveBreakPoint(Linein: integer; e: TEditor); overload;
    procedure DeleteBreakPointsOf(editor: TEditor);

    // watch var
    procedure AddWatchVar(i: integer); overload;
    procedure RemoveWatchVar(i: integer); overload;
    procedure AddWatchVar(const namein: AnsiString); overload;
    procedure RemoveWatchVar(nodein: TTreeNode); overload;
    procedure RefreshWatchVars;
    procedure WatchLocals;

    procedure DeleteWatchVars(deleteparent: boolean);

    // Access
    property Executing: boolean read fExecuting write fExecuting;
    property LeftPageIndexBackup: integer read fLeftPageIndexBackup write fLeftPageIndexBackup;
    property WatchVarList: TList read fWatchVarList write fWatchVarList;
    property BreakPointList: TList read fBreakPointList write fBreakPointList;
    property CommandChanged: boolean read fCommandChanged write fCommandChanged;
    property DebugView: TTreeView read fDebugView write fDebugView;
    property OnEvalReady: TEvalReadyEvent read fOnEvalReady write fOnEvalReady;
    property Reader: TDebugReader read fReader write fReader;
    property BreakPointFile: AnsiString read GetBreakPointFile;
  end;

implementation

uses
  main, devcfg, utils, cpufrm, LazUTF8;

constructor TDebugger.Create;
begin
  inherited;
  BreakPointList := TList.Create;
  WatchVarList := TList.Create;
end;

destructor TDebugger.Destroy;
var
  I: integer;
begin
  Stop;

  // Remove watch vars
  for i := 0 to WatchVarList.Count - 1 do
    Dispose(PWatchVar(WatchVarList.Items[i]));
  WatchVarList.Free;

  // Remove the breakpoints
  for i := 0 to BreakPointList.Count - 1 do
    Dispose(PBreakPoint(BreakPointList.Items[i]));
  BreakPointList.Free;

  inherited;
end;

procedure TDebugger.Start;
var
  GDBFile, GDBCommand: String;
  CompilerSet: TdevCompilerSet;
begin
  Executing := true;

  // Use the GDB provided in the project if needed
  CompilerSet := devCompilerSets.CompilationSet;

  if CompilerSet.BinDir.Count > 0 then begin
    GDBFile := CompilerSet.BinDir[0] + pd + CompilerSet.gdbName;
    if not FileExists(GDBFile) then begin
      MessageDlg(Format(Lang[ID_ERR_ERRORLAUNCHINGGDB],
        [GDBFile, 'GDB executable not found']), mtError, [mbOK], 0);
      Executing := false;
      Exit;
    end;
    GDBCommand := '"' + GDBFile + '" --annotate=2 --silent';
  end else begin
    MessageDlg(Lang[ID_ERR_GDBNOUTFOUND], mtError, [mbOK], 0);
    Executing := false;
    Exit;
  end;

  // --quiet, --silent
  // GDB starts an interactive session without displaying its version and copyright information.
  // --annotate=2
  // To produce annotations, start GDB with the --annotate=2 option.
  // https://ftp.gnu.org/old-gnu/Manuals/gdb/html_chapter/gdb_21.html

  fGDBProcess := TProcess.Create(nil);
  // TProcess.CommandLine is deprecated; split into Executable + Parameters
  // (MSVCRT tokenization, FPC re-quotes each token — effective command line unchanged)
  SplitCommandLine(GDBCommand, fGDBProcess.Parameters);
  if fGDBProcess.Parameters.Count > 0 then begin
    fGDBProcess.Executable := fGDBProcess.Parameters[0];
    fGDBProcess.Parameters.Delete(0);
  end;
  // poUsePipes is MANDATORY: FPC's TProcess only creates the stdin/stdout/stderr
  // pipes when poUsePipes is set (win/process.inc: CreatePipes/CreateStreams).
  // Without it, .Output/.Input are nil and the reader thread would fault.
  // do NOT add poNoConsole here: CREATE_NO_WINDOW breaks console programs' stdin.
  // ShowWindow := swoHIDE hides the console window that would otherwise appear.
  fGDBProcess.Options := [poUsePipes, poStderrToOutPut];
  fGDBProcess.ShowWindow := swoHIDE;
  try
    fGDBProcess.Active := True;
  except
    on E: Exception do begin
      MessageDlg(Format(Lang[ID_ERR_ERRORLAUNCHINGGDB],
        [GDBFile, E.Message]), mtError, [mbOK], 0);
      FreeAndNil(fGDBProcess);
      Executing := false;
      Exit;
    end;
  end;

  // Create a thread that will read GDB output from the TProcess pipes.
  Reader := TDebugReader.Create(true);
  Reader.PipeRead := fGDBProcess;
  Reader.FreeOnTerminate := True;
  Reader.BreakpointList := BreakPointList;
  Reader.WatchVarList := WatchVarList;
  Reader.DebugView := DebugView;
  Reader.Resume;

  MainForm.UpdateAppTitle;
  Application.HintHidePause := 5000;
end;

procedure TDebugger.Stop;
begin
  if Executing then begin
    Executing := false;

    if WatchVarList.Count = 0 then
      MainForm.LeftPageControl.ActivePageIndex := LeftPageIndexBackup;

    if Assigned(CPUForm) then
      CPUForm.Close;

    if Assigned(Reader) then begin
      Reader.Terminate;
      Reader := nil;
    end;

    if Assigned(fGDBProcess) then begin
      fGDBProcess.Terminate(0);
      FreeAndNil(fGDBProcess);
    end;

    MainForm.RemoveActiveBreakpoints;
    MainForm.UpdateAppTitle;
    MainForm.txtLocals.Clear;
    Application.HintHidePause := 2500;
  end;
end;

procedure TDebugger.SendCommand(const Command, Params: AnsiString; ViewInUI: boolean);
var
  CmdLine: AnsiString;
  Buf: array[0..1023] of Byte;
  i, n: Integer;
begin
  if not Executing then
    Exit;

  if Length(params) > 0 then
    CmdLine := command + ' ' + params + #10
  else
    CmdLine := command + #10;

  Reader.LastCmd := command + ' ' + params;

  // Write the command to GDB's stdin via TProcess.Input pipe.
  n := Length(CmdLine);
  if n > SizeOf(Buf) then
    n := SizeOf(Buf);
  for i := 1 to n do
    Buf[i - 1] := Ord(CmdLine[i]);
  // Guard: GDB may have exited while commands were queued in the reader thread.
  // Silently skip rather than showing a dialog — failing to write to a dead pipe is benign.
  if Assigned(fGDBProcess) and fGDBProcess.Running then begin
    try
      fGDBProcess.Input.Write(Buf[0], n);
    except
      // Stream closed or process gone; nothing to do
    end;
  end;

  if ViewInUI then
    if (not CommandChanged) or (MainForm.cmbGdbCommand.Text = '') then begin
      if Length(params) > 0 then
        MainForm.cmbGdbCommand.Text := Command + ' ' + params
      else
        MainForm.cmbGdbCommand.Text := Command;

      if (command <> 'file') and (command <> 'cd') and (command <> 'dir')
        and (MainForm.cmbGdbCommand.Items.IndexOf(MainForm.cmbGdbCommand.Text) = -1) then
        MainForm.cmbGdbCommand.AddItem(MainForm.cmbGdbCommand.Text, nil);

      CommandChanged := false;
    end;
end;

function TDebugger.GetBreakPointFile: AnsiString;
begin
  if Executing then
    Result := fReader.BreakPointFile
  else
    Result := '';
end;

procedure TDebugger.AddBreakPoint(i: integer);
var
  filename: String;
begin
  // "filename":linenum
  filename := StringReplace(AnsiString(PBreakPoint(BreakPointList.Items[i])^.editor.FileName), '\', '/', [rfReplaceAll]);
  SendCommand('break', '"' + UTF8ToWinCP(filename) + '":' + inttostr(PBreakPoint(BreakPointList.Items[i])^.line), true);
end;

procedure TDebugger.RemoveBreakPoint(i: integer);
var
  filename: String;
begin
  // "filename":linenum
  filename := StringReplace(AnsiString(PBreakPoint(BreakPointList.Items[i])^.editor.FileName), '\', '/', [rfReplaceAll]);
  SendCommand('clear', '"' + UTF8ToWinCP(filename) + '":' + inttostr(PBreakPoint(BreakPointList.Items[i])^.line), true);
end;

procedure TDebugger.AddBreakPoint(linein: integer; e: TEditor);
var
  APBreakPoint: PBreakPoint;
begin
  APBreakPoint := new(PBreakPoint);
  with APBreakPoint^ do begin
    line := Linein;
    editor := e;
  end;
  BreakPointList.Add(APBreakPoint);

  // Debugger already running? Add it to GDB
  if Executing then
    AddBreakPoint(BreakPointList.Count - 1);
end;

procedure TDebugger.RemoveBreakPoint(Linein: integer; e: TEditor);
var
  i: integer;
begin
  for i := 0 to BreakPointList.Count - 1 do begin
    if (PBreakPoint(BreakPointList.Items[i])^.line = Linein) and (PBreakPoint(BreakPointList.Items[i])^.editor = e) then
      begin

      // Debugger already running? Remove it from GDB
      if Executing then
        RemoveBreakPoint(i);

      // Remove from list
      Dispose(PBreakPoint(BreakPointList.Items[i]));
      BreakPointList.Delete(i);
      break;
    end;
  end;
end;

procedure TDebugger.DeleteBreakPointsOf(editor: TEditor);
var
  I: integer;
begin
  // Breakpoints in closed files need to be deleted
  for i := BreakPointList.Count - 1 downto 0 do

    if PBreakPoint(BreakPointList.Items[i])^.editor = editor then begin

      // Remove from list
      Dispose(PBreakPoint(BreakPointList.Items[i]));
      BreakPointList.Delete(i);
    end;
end;

procedure TDebugger.AddWatchVar(i: integer);
begin
  SendCommand('display', PWatchVar(WatchVarList.Items[i])^.name, true);
end;

procedure TDebugger.RemoveWatchVar(i: integer);
begin
  SendCommand('undisplay', IntToStr(PWatchVar(WatchVarList.Items[i])^.gdbindex), true);
end;

procedure TDebugger.AddWatchVar(const namein: AnsiString);
var
  parentnode: TTreeNode;
  I: integer;
  wparent: PWatchVar;
begin

  // Don't allow duplicates...
  for I := 0 to WatchVarList.Count - 1 do
    if SameStr(PWatchVar(WatchVarList.Items[i])^.name, namein) then
      Exit;

  // Add parent to list
  wparent := New(PWatchVar);
  wparent^.name := namein;
  //	wparent^.value := 'Execute to evaluate';
  wparent^.gdbindex := -1; // filled by GDB
  WatchVarList.Add(wparent);

  // Add parent to GUI
  parentnode := DebugView.Items.AddObject(nil, wparent^.name + ' = Execute to evaluate', wparent);
  parentnode.ImageIndex := 45;
  parentnode.SelectedIndex := 45;

  // Refer to list from GUI
  wparent^.node := parentnode;

  // Debugger already running? Add it to GDB
  if Executing then
    AddWatchVar(WatchVarList.Count - 1);
end;

procedure TDebugger.RemoveWatchVar(nodein: TTreeNode);
var
  I: integer;
  wparent: PWatchVar;
begin
  for i := 0 to WatchVarList.Count - 1 do begin
    wparent := PWatchVar(WatchVarList.Items[I]);

    if SameStr(wparent^.name, PWatchVar(nodein.Data)^.name) then begin

      // Debugger already running and GDB scanned this one? Remove it from GDB
      if Executing and (wparent^.gdbindex <> -1) then
        RemoveWatchVar(i);

      // Remove from UI
      nodein.DeleteChildren;
      nodein.Delete;

      // Remove from list
      Dispose(PWatchVar(WatchVarList.Items[i]));
      WatchVarList.Delete(i);

      break;
    end;
  end;
end;

procedure TDebugger.WatchLocals;
begin
   SendCommand('info', 'args', true);
   Reader.CmdQueue := 'info locals';
   //SendCommand('info', 'variables', true);
end;

procedure TDebugger.RefreshWatchVars;
var
  I: integer;
begin
  // Variables that aren't found need to be re-displayed!
  for i := 0 to WatchVarList.Count - 1 do
    if PWatchVar(WatchVarList.Items[i])^.gdbindex = -1 then
      AddWatchVar(i); // resends command to display to GDB
end;

procedure TDebugger.DeleteWatchVars(deleteparent: boolean);
var
  I: integer;
  wparent: PWatchVar;
begin
  DebugView.Items.BeginUpdate;
  try
    for I := WatchVarList.Count - 1 downto 0 do begin
      wparent := PWatchVar(WatchVarList.Items[I]);

      if deleteparent then begin

        // Remove from UI
        if wparent^.node.HasChildren then
          wparent^.node.DeleteChildren;
        wparent^.node.Delete;

        // Remove from list
        Dispose(PWatchVar(WatchVarList.Items[i]));
        WatchVarList.Delete(i);
      end else begin

        // Remove from UI
        if wparent^.node.HasChildren then
          wparent^.node.DeleteChildren;

        // Leave parent node intact...
        wparent^.gdbindex := -1;
        wparent^.node.Text := wparent^.name + ' = Execute to evaluate';
      end;
    end;
  finally
    DebugView.Items.EndUpdate;
  end;
end;

end.

