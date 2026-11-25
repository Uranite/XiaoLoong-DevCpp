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

unit devExec;

interface

uses
  Classes, Forms, Process, LCLIntf, Utils;

type
  TExecThread = class(TThread)
  private
    fFile: String;
    fPath: String;
    fParams: String;
    fTimeOut: Cardinal;
    fProcess: Cardinal;
    fVisible: boolean;
    procedure ExecAndWait;
  public
    procedure Execute; override;
  published
    property FileName: String read fFile write fFile;
    property Path: String read fPath write fPath;
    property Params: String read fParams write fParams;
    property TimeOut: Cardinal read fTimeOut write fTimeOut;
    property Visible: boolean read fVisible write fVisible;
    property Process: Cardinal read fProcess;
  end;

  TdevExecutor = class(TPersistent)
  private
    fExec: TExecThread;
    fIsRunning: boolean;
    fOnTermEvent: TNotifyEvent;
    procedure TerminateEvent(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Reset;
    procedure ExecuteAndWatch(sFileName, sParams, sPath: String; bVisible: boolean; iTimeOut: Cardinal; OnTermEvent:
      TNotifyEvent);
  published
    property Running: boolean read fIsRunning;
  end;

function devExecutor: TdevExecutor;

implementation

const
  INFINITE = $FFFFFFFF;

{ TExecThread }

procedure TExecThread.Execute;
begin
  ExecAndWait;
end;

procedure TExecThread.ExecAndWait;
var
  P: TProcess;
  StartTick: Cardinal;
begin
  P := TProcess.Create(nil);
  try
    // TProcess.CommandLine is deprecated; use Executable + Parameters instead.
    // FPC re-quotes the executable via MaybeQuoteIfNotQuoted (quotes it when it
    // contains spaces), so semantics are identical to the old quoted command line.
    P.Executable := fFile;
    SplitCommandLine(fParams, P.Parameters);
    P.CurrentDirectory := fPath;
    if fVisible then
      P.ShowWindow := swoShow
    else
      P.ShowWindow := swoHIDE;
    // Note: do NOT add poNoConsole on Windows (CREATE_NO_WINDOW breaks pipe I/O).
    // ShowWindow := swoHIDE already suppresses the window; CREATE_NEW_CONSOLE
    // (the default) ensures pipe redirection works correctly for console programs.
    P.Active := True;
    fProcess := Cardinal(P.ProcessID);
    StartTick := LCLIntf.GetTickCount;
    while P.Running do begin
      // Abort requested from another thread (Reset): terminate from THIS thread
      // to avoid touching the process handle across thread boundaries.
      if Terminated then begin
        P.Terminate(0);
        Break;
      end;
      // Timeout: leave the process running, just stop waiting (matches original
      // WaitForSingleObject(hProcess, fTimeOut) semantics).
      if fTimeOut <> INFINITE then begin
        if LCLIntf.GetTickCount - StartTick >= fTimeOut then
          Break;
      end;
      Sleep(10);
    end;
  finally
    P.Free;
  end;
end;

var
  fDevExecutorSingleton: TdevExecutor;

function devExecutor: TdevExecutor;
begin
  if not Assigned(fDevExecutorSingleton) and not Application.Terminated then
    fDevExecutorSingleton := TdevExecutor.Create;
  Result := fDevExecutorSingleton;
end;

{ TdevExecutor }

constructor TdevExecutor.Create;
begin
  inherited;
end;

destructor TdevExecutor.Destroy;
begin
  fDevExecutorSingleton := nil;
  inherited;
end;

procedure TdevExecutor.ExecuteAndWatch(sFileName, sParams, sPath: String;
  bVisible: boolean; iTimeOut: Cardinal; OnTermEvent: TNotifyEvent);
begin
  fIsRunning := True;
  fOnTermEvent := OnTermEvent;
  fExec := TExecThread.Create(True);
  with fExec do begin
    FileName := sFileName;
    Params := sParams;
    Path := sPath;
    TimeOut := iTimeOut;
    Visible := bVisible;
    OnTerminate := @TerminateEvent;
    FreeOnTerminate := True;
    Start; //Resume;
  end;
end;

procedure TdevExecutor.Reset;
begin
  // Only signal the exec thread if it is actually running; otherwise fExec may
  // already have been freed by FreeOnTerminate.
  if fIsRunning and Assigned(fExec) then
    fExec.Terminate;
  fIsRunning := False;
end;

procedure TdevExecutor.TerminateEvent(Sender: TObject);
begin
  fIsRunning := False;
  if Assigned(fOnTermEvent) then
    fOnTermEvent(Self);
end;

end.
