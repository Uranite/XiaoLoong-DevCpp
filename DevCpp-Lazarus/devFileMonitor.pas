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

unit devFileMonitor;

interface

uses
{$IFDEF MSWINDOWS}
  {$IFDEF MSWINDOWS}Windows{$ELSE}LCLIntf, LCLType{$ENDIF}, Messages,
{$ENDIF}
  SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, Math, SyncObjs;

const
  WM_NOTIFYFILECHANGED = WM_USER + 1;

type

  //types
  TdevMonitorChangeType = (mctChanged, mctDeleted);
  TdevMonitorChange = procedure(Sender: TObject; ChangeType: TdevMonitorChangeType; Filename: String) of object;

  PdevMonitorFile = ^TdevMonitorFile;
  TdevMonitorFile = record
    FileName: String;
    TimeStamp: integer;
  end;

  //thread
  TdevMonitorThread = class(TThread)
  private
    fOwner: TComponent;
    fFileProperties: TList;
    fFileNames: TStringList;
    fMonitors: array[0..MAXIMUM_WAIT_OBJECTS - 1] of THandle;
    fMonitorCount: integer;
    fChangeType: TdevMonitorChangeType;
    fFilename: String;
    fShouldQuit: TEvent;
    procedure Notify;
    procedure CreateMonitors;
    procedure DestroyMonitors;
    procedure InitFileStamps;
  public
    constructor Create(AOwner: TComponent; FileNames: TStringList);
    destructor Destroy; override;
    procedure Execute; override;
  end;

  TdevFileMonitor = class(TWinControl)
  //TdevFileMonitor = class(TControl)
  private
    fMonitor: TdevMonitorThread;
    fFiles: TStringList;
    fNotifyChange: TdevMonitorChange;
    fUpdateCount: integer;
    procedure SubClassWndProc(var Message: TMessage);
    procedure Refresh;
    procedure Activate;
    procedure Deactivate;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Monitor(const FileName: String);
    procedure UnMonitor(const FileName: String);
    procedure BeginUpdate;
    procedure EndUpdate;
  published
    property OnNotifyChange: TdevMonitorChange read fNotifyChange write fNotifyChange;
  end;

implementation

{ TdevMonitorThread }

constructor TdevMonitorThread.Create(AOwner: TComponent; FileNames: TStringList);
begin
  inherited Create(False); // start immediately
  fOwner := AOwner;
  fFileNames := TStringList.Create;
  fFileNames.Assign(FileNames);
  fFileProperties := TList.Create;
  fMonitorCount := 0;
  fShouldQuit := TEvent.Create(nil, false, false, '');
{$IFDEF MSWINDOWS}
  CreateMonitors;
{$ELSE}
  // Non-Windows: no native inotify; use file-stamp polling (simple, reliable)
  // Initialise timestamps for each file
  InitFileStamps;
{$ENDIF}
end;

destructor TdevMonitorThread.Destroy;
begin
  fShouldQuit.SetEvent;
  Terminate;
  WaitFor;
  DestroyMonitors;
  fFileProperties.Free;
  fFileNames.Free;
  fShouldQuit.Free;
  inherited;
end;

procedure TdevMonitorThread.CreateMonitors;
var
  I: integer;
  Item: PdevMonitorFile;
  SearchRec: TSearchRec;
  ChangeID: Cardinal;
  DirPath: UnicodeString;
begin
  for I := 0 to Min(MAXIMUM_WAIT_OBJECTS - 2, fFileNames.Count - 1) do begin
    if FindFirst(fFileNames[I], faAnyFile, SearchRec) = 0 then begin
      DirPath := UnicodeString(ExtractFilePath(fFileNames[I]));
      ChangeID := FindFirstChangeNotificationW(
        PWideChar(DirPath),
        False,
        FILE_NOTIFY_CHANGE_LAST_WRITE or FILE_NOTIFY_CHANGE_FILE_NAME
        );
      if ChangeID <> INVALID_HANDLE_VALUE then begin
        fMonitors[fMonitorCount] := ChangeID;
        Inc(fMonitorCount);
        Item := new(PdevMonitorFile);
        Item^.FileName := fFileNames[i];
        Item^.TimeStamp := SearchRec.Time;
        fFileProperties.Add(Item);
      end;
      FindClose(SearchRec);
    end;
  end;
  fMonitors[fMonitorCount] := QWord(fShouldQuit.Handle);
  Inc(fMonitorCount);
end;

procedure TdevMonitorThread.DestroyMonitors;
var
  I: integer;
begin
  for I := 0 to fFileProperties.Count - 1 do
    Dispose(PdevMonitorFile(fFileProperties[i]));
  fFileProperties.Clear;
{$IFDEF MSWINDOWS}
  for I := 0 to fMonitorCount - 2 do
    if fMonitors[I] <> INVALID_HANDLE_VALUE then
      FindCloseChangeNotification(THandle(fMonitors[I]));
{$ENDIF}
  fMonitorCount := 0;
end;

procedure TdevMonitorThread.InitFileStamps;
// Non-Windows: populate fFileProperties with current file timestamps
var
  I: integer;
  Item: PdevMonitorFile;
  SearchRec: TSearchRec;
begin
  for I := 0 to fFileNames.Count - 1 do begin
    if FindFirst(fFileNames[I], faAnyFile, SearchRec) = 0 then begin
      Item := new(PdevMonitorFile);
      Item^.FileName := fFileNames[I];
      Item^.TimeStamp := SearchRec.Time;
      fFileProperties.Add(Item);
      FindClose(SearchRec);
    end else begin
      Item := new(PdevMonitorFile);
      Item^.FileName := fFileNames[I];
      Item^.TimeStamp := 0;
      fFileProperties.Add(Item);
    end;
  end;
end;

procedure TdevMonitorThread.Execute;
var
  FileNameIndex: integer;
  WaitResult: Cardinal;
  WaitObjectIndex: integer;
  SearchRec: TSearchRec;
  FileStruct: PdevMonitorFile;
begin
{$IFDEF MSWINDOWS}
  // Windows: native file-change notifications
  while not Terminated and not Suspended do begin
    WaitResult := WaitForMultipleObjects(fMonitorCount, @fMonitors, False, INFINITE);
    if WaitResult = WAIT_FAILED then Break;
    if WaitResult = WAIT_TIMEOUT then Break;
    if (WaitResult >= WAIT_ABANDONED_0) and (WaitResult <= WAIT_ABANDONED_0 + Cardinal(fMonitorCount) - 1) then Break;
    if WaitResult = Cardinal(fMonitorCount-1) then Break;

    WaitObjectIndex := WaitResult - WAIT_OBJECT_0;
    FileStruct := PdevMonitorFile(fFileProperties[WaitObjectIndex]);
    if FindFirst(FileStruct^.FileName, faAnyFile, SearchRec) = 0 then begin
      if FileStruct^.TimeStamp <> SearchRec.Time then begin
        FileStruct^.TimeStamp := SearchRec.Time;
        fChangeType := mctChanged;
        fFilename := FileStruct^.FileName;
        Notify;
      end;
      FindClose(SearchRec);
      FindNextChangeNotification(THandle(fMonitors[WaitObjectIndex]));
    end else begin
      fChangeType := mctDeleted;
      fFilename := FileStruct^.FileName;
      Notify;
      FileNameIndex := fFileNames.IndexOf(FileStruct^.FileName);
      if FileNameIndex <> -1 then fFileNames.Delete(FileNameIndex);
      DestroyMonitors;
      CreateMonitors;
    end;
  end;
{$ELSE}
  // Non-Windows: polling-based file change detection
  // Check file timestamps every 500 ms
  while not Terminated and not Suspended do begin
    // Check quit signal every iteration
    if fShouldQuit.WaitFor(500) <> wrTimeout then Break;

    for FileNameIndex := 0 to fFileProperties.Count - 1 do begin
      FileStruct := PdevMonitorFile(fFileProperties[FileNameIndex]);
      if FindFirst(FileStruct^.FileName, faAnyFile, SearchRec) = 0 then begin
        if (FileStruct^.TimeStamp <> 0) and (FileStruct^.TimeStamp <> SearchRec.Time) then begin
          FileStruct^.TimeStamp := SearchRec.Time;
          fChangeType := mctChanged;
          fFilename := FileStruct^.FileName;
          Notify;
        end else if FileStruct^.TimeStamp = 0 then begin
          // File was deleted and is now re-created
          FileStruct^.TimeStamp := SearchRec.Time;
          fChangeType := mctChanged;
          fFilename := FileStruct^.FileName;
          Notify;
        end else begin
          FileStruct^.TimeStamp := SearchRec.Time;
        end;
        FindClose(SearchRec);
      end else begin
        if FileStruct^.TimeStamp <> 0 then begin
          // File was deleted
          FileStruct^.TimeStamp := 0;
          fChangeType := mctDeleted;
          fFilename := FileStruct^.FileName;
          Notify;
        end;
      end;
    end;
  end;
{$ENDIF}
end;

procedure TdevMonitorThread.Notify;
var
  P: PChar;
begin
  P := StrNew(PChar(fFilename));
  PostMessage(TdevFileMonitor(fOwner).Handle, WM_NOTIFYFILECHANGED, integer(fChangeType), LPARAM(P));
end;

{ TdevFileMonitor }

//procedure Register;
//begin
//  RegisterComponents('Dev-C++', [TdevFileMonitor]);
//end;

constructor TdevFileMonitor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner); // �޸�1: ������ø��๹�캯��
  fFiles := TStringList.Create;
  fMonitor := nil;
  fUpdateCount := 0;
  // �޸�2: ȷ���и�����
  if (AOwner is TWinControl) then
    Parent := TWinControl(AOwner);
  WindowProc := @SubClassWndProc;
end;

destructor TdevFileMonitor.Destroy;
begin
  Deactivate;
  fFiles.Free;
  inherited;
end;

procedure TdevFileMonitor.SubClassWndProc(var Message: TMessage);
begin
  if Message.Msg = WM_NOTIFYFILECHANGED then begin
    if Assigned(fNotifyChange) then begin
      fNotifyChange(Self, TDevMonitorChangeType(Message.WParam), PChar(Message.LParam));
      StrDispose(PChar(Message.LParam));
    end;
  end else
    WndProc(Message);
end;

procedure TdevFileMonitor.Activate;
begin
  if not Assigned(fMonitor) then begin
    fMonitor := TdevMonitorThread.Create(Self, fFiles); // starts immediately
  end;
end;

procedure TdevFileMonitor.Deactivate;
begin
  if Assigned(fMonitor) then begin // we can spawn a new fMonitor instance directly after calling this
    fMonitor.Free;
    fMonitor := nil;
  end;
end;

procedure TdevFileMonitor.BeginUpdate;
begin
  Inc(fUpdateCount);
  if fUpdateCount <> 0 then
    Deactivate;
end;

procedure TdevFileMonitor.EndUpdate;
begin
  Dec(fUpdateCount);
  if fUpdateCount = 0 then
    Activate;
end;

procedure TdevFileMonitor.Monitor(const FileName: String);
begin
  fFiles.Add(FileName);
  Refresh;
end;

procedure TdevFileMonitor.UnMonitor(const FileName: String);
var
  I: integer;
begin
  I := fFiles.IndexOf(FileName);
  if I <> -1 then begin
    fFiles.Delete(I);
    Refresh;
  end;
end;

procedure TdevFileMonitor.Refresh;
begin
  if not Assigned(fMonitor) then
    Activate
  else begin
    Deactivate;
    Activate;
  end;
end;

end.

