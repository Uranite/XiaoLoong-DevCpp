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

unit devRun;

interface

uses
  Classes, Dialogs, utils;

type
  TLineOutputEvent = procedure(Sender: TObject; const Line: String) of object;
  TCheckAbortEvent = procedure(var AbortThread: boolean) of object;

  TDevRun = class(TThread)
  private
    fCurrentLine: String;
    fLineOutput: TLineOutputEvent;
    fCheckAbort: TCheckAbortEvent;
  protected
    procedure CallLineOutputEvent;
    procedure CallCheckAbort(var AbortThread: boolean);
    procedure Execute; override;
    procedure LineOutput(const Line: String);
  public
    Command: String;   // UTF-8 encoded (was ansistring/CP_ACP which garbled Chinese paths)
    Directory: String;
    Output: String;
    property OnLineOutput: TLineOutputEvent read FLineOutput write FLineOutput;
    property OnCheckAbort: TCheckAbortEvent read FCheckAbort write FCheckAbort;
  end;

implementation

procedure TDevRun.CallLineOutputEvent;
begin
  fLineOutput(Self, fCurrentLine);
end;

procedure TDevRun.LineOutput(const Line: String);
begin
  fCurrentLine := Line;
  if Assigned(fLineOutput) then
    Synchronize(@CallLineOutputEvent);
end;

procedure TDevRun.CallCheckAbort(var AbortThread: boolean);
begin
  if Assigned(fCheckAbort) then
    fCheckAbort(AbortThread);
end;

procedure TDevRun_ExecLineOut(const Line: String; Data: Pointer);
begin
  if Data <> nil then
    TDevRun(Data).LineOutput(Line);
end;

procedure TDevRun_ExecAbort(var AbortThread: boolean; Data: Pointer);
begin
  if Data <> nil then
    TDevRun(Data).CallCheckAbort(AbortThread);
end;

procedure TDevRun.Execute;
begin
  Output := RunAndGetOutput(Command, Directory, @TDevRun_ExecLineOut, @TDevRun_ExecAbort, True, Self, Self);
end;

end.
