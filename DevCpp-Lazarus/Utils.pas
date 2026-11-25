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

unit Utils;

interface

uses
  {$IFDEF MSWINDOWS}Windows{$ELSE}LCLIntf, LCLType{$ENDIF}, Classes, Sysutils, Dateutils, Forms, {$IFDEF MSWINDOWS}ShellAPI{$ENDIF}, Dialogs,
  Menus, Controls, ComCtrls,
  Process,
{$IFDEF MSWINDOWS}
  {$IFDEF MSWINDOWS}Registry{$ENDIF},
{$ENDIF}
  LazUTF8;

type
  { File ID types }
  TExUnitType = (
    utcSrc, // c source file (.c)
    utcppSrc, // c++ source file (.cpp)
    utcHead, // c header (.h)
    utcppHead, // c++ header (.hpp)
    utresHead, // resouce header (.rh)
    utresComp, // resource compiled (.res)
    utresSrc, // resource source (.rc)
    utPrj, // project file (.dev)
    utMakefile, // makefile (.mk)
    utFortSrc, //FORTRAN source file (.f90 .f95 .f77 .for .f
    utOther // any others
    );

  TFilterSet = (ftOpen, ftPrj, ftSrc, ftAll);

  TLineOutputFunc = procedure(const Line: String; Data: Pointer);
  TCheckAbortFunc = procedure(var AbortThread: boolean; Data: Pointer);

procedure FilesFromWildcard(Directory: String; const Mask: String; Files: TStringList; Subdirs, ShowDirs,
  Multitasking: Boolean);

function ExecuteFile(const FileName, Params, DefaultDir: String; ShowCmd: Integer): THandle;
function RunAndGetOutput(const Cmd, WorkDir: String; LineOutputFunc: TLineOutputFunc; CheckAbortFunc:
  TCheckAbortFunc; ShowReturnValue: Boolean = True; LineOutputData: Pointer = nil; CheckAbortData: Pointer = nil): String;

// Split a raw command line into separate tokens, using the standard MSVCRT
// rules (same algorithm as CommandLineToArgvW / CreateProcess argument
// parsing). Used to feed TProcess.Executable + TProcess.Parameters, because
// TProcess.CommandLine is deprecated.
procedure SplitCommandLine(const ACmdLine: String; ADest: TStrings);

function GetShortName(const FileName: String): String;

function FormatList(const sl: TStrings; formatstr: String): String;
function IncludeQuoteIfSpaces(const s: String): String;
function IncludeQuoteIfNeeded(const s: String): String;

function ValidateFile(const FileName: String; const WorkPath: String; const CheckDirs: boolean = FALSE):
  String;

function BuildFilter(const Filters: array of String): String;

function CodeInstoStr(const s: String): String;
function StrtoCodeIns(const s: String): String;

//procedure StrtoAttr(var Attr: TSynHighlighterAttributes; const Value: String);
//function AttrtoStr(Attr: TSynHighlighterAttributes): String;

procedure StrtoPoint(var pt: TPoint; const value: String);
function PointtoStr(pt: TPoint): String;

function GetFileTyp(const FileName: String): TExUnitType;

procedure SetPath(const Add: String; UseOriginal: boolean = TRUE);
function ExpandFileto(const FileName, BasePath: String): String;
function FileSamePath(const FileName, TestPath: String): boolean;
procedure CloneMenu(FromMenu, ToMenu: TMenuItem);

function FindComplement(const s: String; fromtoken, totoken: char; var curpos: integer; increment: integer):
  boolean;

function FPos(const SubStr, S: String; start: integer): integer;

function RPos(const SubStr, S: AnsiString): integer; overload;
function RPos(const SubStr, S: AnsiString; start: integer): integer; overload;

function GenMakePath1(const FileName: String): String;
function GenMakePath2(const FileName: String): String;
function GenMakePath(const FileName: String; EscapeSpaces, EncloseInQuotes: Boolean): String; overload;

function GetRealPath(const BrokenFileName: String; const Directory: String = ''): String;

function GetVersionString(const FileName: String): String;

function GetAssociatedProgram(const Extension: String; var Filename, Description: String): boolean;

function IsNumeric(const s: String): boolean;

function CountChar(const s: String; c: Char): integer;

function CharToValue(c: char): integer;

procedure OpenHelpFile(const HelpFileName: String);

//function ProgramHasConsole(const Path: String): boolean;
function ProgramHasConsole(const path: String; UsePrecise: Boolean = False): boolean;

function GetBuildTime(const Path: String): String;

function IsKeyDown(key: integer): boolean;

function GetPrettyLine(hwnd: TListView; i: integer = -1): String; // removes #10 subitem delimiters

function IsWindows64: boolean;

function GetFileSize(const FileName: String): integer;

function FormatFileSize(Size: integer): String;

function ShortenLogOutput(const Input: String): String;

// These functions are about six times faster than the locale sensitive AnsiX() versions
function StartsStr(const subtext, text: String): boolean;
function StartsText(const subtext, text: String): boolean;

function SameStr(const s1, s2: String): boolean;
function SameText(const s1, s2: String): boolean;

function EndsStr(const subtext, text: String): boolean;
function EndsText(const subtext, text: String): boolean;

function ContainsStr(const text, subtext: String): boolean;
function ContainsText(const text, subtext: String): boolean;

// Same as StringReplace, but only replace first OldPattern (a lot faster)
function ReplaceFirstStr(const S, OldPattern, NewPattern: String): String;
function ReplaceFirstText(const S, OldPattern, NewPattern: String): String;

function ReplaceLastStr(const S, OldPattern, NewPattern: String): String;
function ReplaceLastText(const S, OldPattern, NewPattern: String): String;

// Reverse Pos() function
function LastPos(const SubStr, S: String): integer;

// Native SelectDirectory function that lets you set flags
function NewSelectDirectory(const Caption: string; const Root: WideString; var Directory: string): Boolean;

// Fast implementation of StringReplace which does not use AnsiX (MBCS ready) comparison
function FastStringReplace(const S, OldPattern, NewPattern: String; Flags: TReplaceFlags): String;

// Fast implementation of IndexOf which does not use AnsiX (MBCS ready) comparison
function FastIndexOf(List: TStrings; const S: String): integer; overload;
function FastIndexOf(List: TStringlist; const S: String): integer; overload;

// Percent-encode non-ASCII bytes in UTF-8 string for URL query parameters
function URLEncode(const s: String): String;

// Convert raw ANSI/UTF-8 bytes to UnicodeString (auto-detects encoding)
function AnsiBytesToUnicode(Buf: PAnsiChar; BufLen: Integer): UnicodeString;

implementation

uses
  devcfg, version, Graphics, StrUtils, MultiLangSupport, main, editor, LCLIntf,
{$IFDEF MSWINDOWS}
  ShlObj, ActiveX,
{$ELSE}
  Process,
{$ENDIF}
  FileUtil;

function URLEncode(const s: String): String;
var
  i: Integer;
  b: Byte;
  UTF8: RawByteString;
begin
  Result := '';
  UTF8 := Utf8Encode(s); // convert UnicodeString to UTF-8 RawByteString
  SetCodePage(UTF8, CP_UTF8, False); // mark as UTF-8 without conversion
  for i := 1 to Length(UTF8) do begin
    b := Byte(UTF8[i]);
    // Keep unreserved characters as-is: A-Z, a-z, 0-9, -, _, ., ~
    if (b in [Ord('A')..Ord('Z'), Ord('a')..Ord('z'), Ord('0')..Ord('9'),
              Ord('-'), Ord('_'), Ord('.'), Ord('~')]) then
      Result := Result + Char(b)
    else
      Result := Result + '%' + IntToHex(b, 2);
  end;
end;

function FastStringReplace(const S, OldPattern, NewPattern: String; Flags: TReplaceFlags): String;
var
  SearchStr, Patt, NewStr: String;
  Offset: Integer;
begin
  if rfIgnoreCase in Flags then begin
    SearchStr := UpperCase(S);
    Patt := UpperCase(OldPattern);
  end else begin
    SearchStr := S;
    Patt := OldPattern;
  end;
  NewStr := S;
  Result := '';
  while SearchStr <> '' do begin
    Offset := Pos(Patt, SearchStr);
    if Offset = 0 then begin
      Result := Result + NewStr;
      Break;
    end;
    Result := Result + Copy(NewStr, 1, Offset - 1) + NewPattern;
    NewStr := Copy(NewStr, Offset + Length(OldPattern), MaxInt);
    if not (rfReplaceAll in Flags) then begin
      Result := Result + NewStr;
      Break;
    end;
    SearchStr := Copy(SearchStr, Offset + Length(Patt), MaxInt);
  end;
end;

function FastIndexOf(List: TStrings; const S: String): integer;
begin
  with List do begin
    for Result := 0 to Count - 1 do
      if CompareText(List[Result], S) = 0 then
        Exit;
    Result := -1;
  end;
end;

function FastIndexOf(List: TStringlist; const S: String): integer;
begin
  with List do begin
    if not List.Sorted then
      Result := FastIndexOf(TStrings(List), S)
    else if not Find(S, Result) then
      Result := -1;
  end;
end;

function IsKeyDown(key: integer): boolean;
begin
  result := (GetKeyState(key) < 0);
end;

function IsWindows64: Boolean;
{$IFDEF WIN64}
begin
  Result := True;  // Compiled as 64-bits, return True
end;
{$ELSE}
var
  Kernel32: HMODULE;
  IsWow64Process: function(hProcess: THandle; var Wow64Process: BOOL): BOOL; stdcall;
  Wow64Process: BOOL;
begin
  Result := False;

  Kernel32 := GetModuleHandle('kernel32.dll');
  if Kernel32 = 0 then Exit;

  IsWow64Process := GetProcAddress(Kernel32, 'IsWow64Process');
  if not Assigned(IsWow64Process) then Exit;

  if IsWow64Process(GetCurrentProcess, Wow64Process) then
    Result := Wow64Process;
end;
{$ENDIF}



function CharToValue(c: char): integer;
begin
  if CharInSet(c, ['a'..'z']) then
    result := integer(c) - integer('a') + 2
  else if (StrToIntDef(c, 0) = 1) then
    result := 1
  else
    result := 0;
end;

function GetPrettyLine(hwnd: TListView; i: integer): String;
begin
  if (i = -1) then begin // selection
    if hwnd.ItemIndex <> -1 then
      result := GetPrettyLine(hwnd, hwnd.ItemIndex)
    else
      result := '';
  end else begin
    result := hwnd.Items[i].Caption + #13#10 + hwnd.Items[i].SubItems.Text; // CRLF separated columns
    result := Trim(StringReplace(result, #13#10, #9, [rfReplaceAll]));
  end;
end;

function StartsStr(const subtext, text: String): boolean;
begin
  Result := SameStr(subtext, Copy(text, 1, Length(subtext)));
end;

function StartsText(const subtext, text: String): boolean;
begin
  Result := SameText(subtext, Copy(text, 1, Length(subtext)));
end;

function SameStr(const s1, s2: String): boolean;
begin
  Result := (CompareStr(s1, s2) = 0);
end;

function SameText(const s1, s2: String): boolean;
begin
  Result := (CompareText(s1, s2) = 0);
end;

function EndsStr(const subtext, text: String): boolean;
var
  SubTextLocation: Integer;
begin
  SubTextLocation := Length(text) - Length(subtext) + 1;
  if (SubTextLocation > 0) and (subtext <> '') then
    Result := StrComp(Pchar(Pointer(subtext)), Pchar(Pointer(@text[SubTextLocation]))) = 0
    //To Support Unicode, should replace  StrCmp  with  CompareStr
  else
    Result := False;
end;

function EndsText(const subtext, text: String): boolean;
var
  SubTextLocation: Integer;
begin
  SubTextLocation := Length(text) - Length(subtext) + 1;
  if (SubTextLocation > 0) and (subtext <> '') then
    Result := StrIComp(Pchar(Pointer(subtext)), Pchar(Pointer(@text[SubTextLocation]))) = 0
  else
    Result := False;
end;

function ContainsStr(const text, subtext: String): boolean;
begin
  Result := Pos(subtext, text) > 0;
end;

function ContainsText(const text, subtext: String): boolean;
begin
  Result := Pos(UpperCase(subtext), UpperCase(text)) > 0;
end;

function ReplaceFirstStr(const S, OldPattern, NewPattern: String): String;
var
  Offset: Integer;
begin

  Offset := Pos(OldPattern, S);
  if Offset = 0 then begin
    Result := S;
  end else begin

    // Copy the preceding stuff, append the new part, append old stuff after old pattern
    Result := Copy(S, 1, Offset - 1) + NewPattern + Copy(S, Offset + Length(OldPattern), MaxInt);
  end;
end;

function ReplaceFirstText(const S, OldPattern, NewPattern: String): String;
var
  Offset: Integer;
  UpperS, UpperOldPattern: string;
begin
  UpperS := UpperCase(S);
  UpperOldPattern := UpperCase(OldPattern);

  Offset := Pos(UpperOldPattern, UpperS);
  if Offset = 0 then begin
    Result := S;
  end else begin

    // Copy the preceding stuff, append the new part, append old stuff after old pattern
    Result := Copy(S, 1, Offset - 1) + NewPattern + Copy(S, Offset + Length(UpperOldPattern), MaxInt);
  end;
end;

function ReplaceLastStr(const S, OldPattern, NewPattern: String): String;
var
  Offset: Integer;
begin

  Offset := RPos(OldPattern, S);
  if Offset = 0 then begin
    Result := S;
  end else begin

    // Copy the preceding stuff, append the new part, append old stuff after old pattern
    Result := Copy(S, 1, Offset - 1) + NewPattern + Copy(S, Offset + Length(OldPattern), MaxInt);
  end;
end;

function ReplaceLastText(const S, OldPattern, NewPattern: String): String;
var
  Offset: Integer;
  UpperS, UpperOldPattern: string;
begin
  UpperS := UpperCase(S);
  UpperOldPattern := UpperCase(OldPattern);

  Offset := RPos(UpperOldPattern, UpperS);
  if Offset = 0 then begin
    Result := S;
  end else begin

    // Copy the preceding stuff, append the new part, append old stuff after old pattern
    Result := Copy(S, 1, Offset - 1) + NewPattern + Copy(S, Offset + Length(UpperOldPattern), MaxInt);
  end;
end;

function LastPos(const SubStr, s: String): integer;
begin
  result := Pos(ReverseString(SubStr), ReverseString(S));
  if result <> 0 then
    result := ((Length(S) - Length(SubStr)) + 1) - result + 1;
end;

function ProgramHasConsole(const path: String; UsePrecise: Boolean = False): boolean;
{$IFDEF MSWINDOWS}
// ============================================================================
// Windows: PE Subsystem check
// ============================================================================
var
  hFile: THandle;
  bytesread: DWORD;
  dos_header: IMAGE_DOS_HEADER;
  pe_sig: DWORD;
  Subsystem: Word;
  pe_offset: LongInt;
begin
  Result := False;

  hFile := CreateFileW(PWideChar(UnicodeString(path)), GENERIC_READ, FILE_SHARE_READ,
    nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if hFile = INVALID_HANDLE_VALUE then
    Exit;

  try
    // Read DOS header
    if not ReadFile(hFile, dos_header, SizeOf(dos_header), bytesread, nil) then
      Exit;
    if bytesread < SizeOf(dos_header) then
      Exit;
    if dos_header.e_magic <> IMAGE_DOS_SIGNATURE then
      Exit;
    if dos_header.e_lfanew = 0 then
      Exit;

    // Verify PE signature
    if SetFilePointer(hFile, dos_header.e_lfanew, nil, FILE_BEGIN) = INVALID_SET_FILE_POINTER then
      Exit;
    if not ReadFile(hFile, pe_sig, SizeOf(pe_sig), bytesread, nil) then
      Exit;
    if bytesread < SizeOf(pe_sig) then
      Exit;
    if pe_sig <> IMAGE_NT_SIGNATURE then
      Exit;

    // Subsystem field: PE sig(4) + IMAGE_FILE_HEADER(20) + 68
    pe_offset := dos_header.e_lfanew + 4 + SizeOf(IMAGE_FILE_HEADER) + 68;
    if SetFilePointer(hFile, pe_offset, nil, FILE_BEGIN) = INVALID_SET_FILE_POINTER then
      Exit;
    if not ReadFile(hFile, Subsystem, SizeOf(Subsystem), bytesread, nil) then
      Exit;
    if bytesread < SizeOf(Subsystem) then
      Exit;

    Result := (Subsystem = IMAGE_SUBSYSTEM_WINDOWS_CUI);
  finally
    CloseHandle(hFile);
  end;
end;
{$ELSE}
  {$IFDEF DARWIN}
  // ==========================================================================
  // macOS: .app bundle check (fast) + optional otool precise mode
  // ==========================================================================
  var
    P: TProcess;
    SL: TStringList;
  begin
    // .app bundle = GUI application
    if AnsiEndsText('.app', path) then begin
      Result := False;
      Exit;
    end;

    // Not .app → default assume CLI (console program)
    Result := True;

    // Optional precise mode: use otool to check for AppKit/Cocoa linkage
    if UsePrecise then begin
      if not FileExists(path) then
        Exit;
      P := TProcess.Create(nil);
      SL := TStringList.Create;
      try
        P.Executable := 'otool';
        P.Parameters.Add('-L');
        P.Parameters.Add(path);
        P.Options := [poWaitOnExit, poUsePipes];
        P.Execute;
        SL.LoadFromStream(P.Output);
        // GUI programs link AppKit or Cocoa framework
        if (Pos('AppKit', SL.Text) > 0) or (Pos('Cocoa', SL.Text) > 0) then
          Result := False;
      finally
        SL.Free;
        P.Free;
      end;
    end;
  end;
  {$ELSE}
    // ========================================================================
    // Linux: ELF PT_INTERP check
    // ========================================================================
    type
      ELF64_Ehdr = record
        e_ident: array[0..15] of Byte;
        e_type: Word;
        e_machine: Word;
        e_version: LongWord;
        e_entry: UInt64;
        e_phoff: UInt64;
        e_shoff: UInt64;
        e_flags: LongWord;
        e_ehsize: Word;
        e_phentsize: Word;
        e_phnum: Word;
        e_shentsize: Word;
        e_shnum: Word;
        e_shstrndx: Word;
      end;

      ELF64_Phdr = record
        p_type: LongWord;
        p_flags: LongWord;
        p_offset: UInt64;
        p_vaddr: UInt64;
        p_paddr: UInt64;
        p_filesz: UInt64;
        p_memsz: UInt64;
        p_align: UInt64;
      end;

    const
      PT_INTERP = $3;
    var
      hFile: THandle;
      bytesread: DWORD;
      Ehdr: ELF64_Ehdr;
      Phdr: ELF64_Phdr;
      Interp: array[0..4096] of Char;
      i: Integer;
      InterpPath: String;
    begin
      Result := False;

      hFile := FileOpen(UTF8ToSys(path), fmOpenRead or fmShareDenyWrite);
      if hFile < 0 then
        Exit;

      try
        bytesread := 0;
        if not FileRead(hFile, Ehdr, SizeOf(Ehdr), bytesread) or (bytesread <> SizeOf(Ehdr)) then
          Exit;

        // ELF magic: 0x7F 'E' 'L' 'F'
        if (Ehdr.e_ident[0] <> $7F) or (Ehdr.e_ident[1] <> Byte('E')) or
           (Ehdr.e_ident[2] <> Byte('L')) or (Ehdr.e_ident[3] <> Byte('F')) then
          Exit;

        // ET_EXEC ($2) or ET_DYN ($3)
        if (Ehdr.e_type <> $2) and (Ehdr.e_type <> $3) then
          Exit;

        FillChar(Interp, SizeOf(Interp), 0);
        if (Ehdr.e_phoff <> 0) and (Ehdr.e_phnum > 0) and
           (Ehdr.e_phentsize >= SizeOf(ELF64_Phdr)) then
        begin
          if FileSeek(hFile, Ehdr.e_phoff, 0) >= 0 then
          begin
            for i := 0 to Ehdr.e_phnum - 1 do
            begin
              if FileRead(hFile, Phdr, SizeOf(Phdr), bytesread) <> SizeOf(Phdr) then
                Break;
              if Phdr.p_type = PT_INTERP then
              begin
                FillChar(Interp, SizeOf(Interp), 0);
                if FileSeek(hFile, Phdr.p_offset, 0) >= 0 then
                begin
                  if FileRead(hFile, Interp,
                      Min(Phdr.p_filesz, SizeOf(Interp) - 1), bytesread) = bytesread then
                    InterpPath := StrPas(Interp);
                end;
                Break;
              end;
            end;
          end;
        end;

        if InterpPath <> '' then
          Result := (Pos('ld-linux', InterpPath) > 0) or
                    (Pos('ld-musl', InterpPath) > 0) or
                    (Pos('ld.so', InterpPath) > 0)
        else
          Result := True;  // statically linked = CLI
      finally
        FileClose(hFile);
      end;
    end;
  {$ENDIF}
{$ENDIF}


function GetBuildTime(const Path: String): String;
var
  //dateinteger: integer;
  datedouble: TDateTime;
  //	handle : Cardinal;
  //	bytesread : DWORD;
  //	signature : DWORD;
  //	dos_header : _IMAGE_DOS_HEADER;
  //	pe_header  : _IMAGE_FILE_HEADER;
begin
  //dateinteger := FileAge(path); //the first version of FileAge is deprecated
  //datedouble := FileDateToDateTime(dateinteger);
  FileAge(path, datedouble);

  //	handle := CreateFile(PChar(path),GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
  //	if handle <> INVALID_HANDLE_VALUE then begin
  //		ReadFile(Handle, dos_header, sizeof(dos_header), bytesread, nil);
  //		SetFilePointer(Handle, dos_header._lfanew, nil, 0);
  //		ReadFile(Handle, signature,  sizeof(signature),  bytesread, nil);
  //		ReadFile(Handle, pe_header,  sizeof(pe_header),  bytesread, nil);

  //		Result := UnixToDateTime(pe_header.TimeDateStamp);
  //	end else
  //		Result := 0;

  //	CloseHandle(handle);

  //DateTimeToString(Result, 'mmmm d yyyy - hh:nn', datedouble);
  DateTimeToString(Result, 'yyyy-mm-dd  hh:nn', datedouble);
end;

procedure OpenHelpFile(const HelpFileName: String);
var
  abshelp: String;
begin
  abshelp := ReplaceFirstStr(devDirs.Help, '%path%\', devDirs.Exec) + HelpFileName;
  OpenURL(abshelp);
end;

procedure FilesFromWildcard(Directory: String; const Mask: String; Files: TStringList; Subdirs, ShowDirs,
  Multitasking: Boolean);
var
  SearchRec: TSearchRec;
  Attr, Error: Integer;
begin
  Directory := IncludeTrailingPathDelimiter(Directory);

  // First, find the required file...
  Attr := faAnyFile;
  if ShowDirs = False then
    Attr := Attr - faDirectory;
  Error := FindFirst(Directory + Mask, Attr, SearchRec);
  if (Error = 0) then begin
    while (Error = 0) do begin
      // Found one!
      Files.Add(Directory + SearchRec.Name);
      Error := FindNext(SearchRec);
      if Multitasking then
        Application.ProcessMessages;
    end;
    FindClose(SearchRec);
  end;

  // Then walk through all subdirectories.
  if Subdirs then begin
    Error := FindFirst(Directory + '*.*', faAnyFile, SearchRec);
    if (Error = 0) then begin
      while (Error = 0) do begin
        // Found one!
        if (SearchRec.Name[1] <> '.') and (SearchRec.Attr and
          faDirectory <> 0) then
          // We do this recursively!
          FilesFromWildcard(Directory + SearchRec.Name, Mask, Files,
            Subdirs, ShowDirs, Multitasking);
        Error := FindNext(SearchRec);
      end;
      FindClose(SearchRec);
    end;
  end;
end;

function ExecuteFile(const FileName, Params, DefaultDir: String; ShowCmd: Integer): THandle;
{$IFDEF MSWINDOWS}
var
  WFileName, WParams, WDefaultDir: UnicodeString;
begin
  // Use ShellExecuteW (Unicode) to support Chinese characters in path
  WFileName := UTF8Decode(FileName);
  WParams := UTF8Decode(Params);
  WDefaultDir := UTF8Decode(DefaultDir);
  Result := ShellExecuteW(Application.MainForm.Handle, nil,
    PWideChar(WFileName), PWideChar(WParams),
    PWideChar(WDefaultDir), ShowCmd);
end;
{$ELSE}
var
  P: TProcess;
  Args: TStringList;
begin
  P := TProcess.Create(nil);
  Args := TStringList.Create;
  try
    P.Executable := FileName;
    P.CurrentDirectory := DefaultDir;
    // Split Params string into separate arguments (respecting quoted strings)
    Args.DelimitedText := Params;
    P.Parameters.Assign(Args);
    P.Options := [poWaitOnExit];
    P.Execute;
    Result := P.ProcessID;
  finally
    Args.Free;
    P.Free;
  end;
end;
{$ENDIF}

{$IFDEF MSWINDOWS}
// 返回 P 处 UTF-8 序列的长度(2..4)与其码点；不是合法 UTF-8 序列时返回 False。
function TryUtf8Seq(P: PAnsiChar; Remaining: Integer; out SeqLen: Integer;
  out CodePoint: Cardinal): Boolean;
var
  b0, b1, b2, b3: Byte;
  cp: Cardinal;
begin
  Result := False;
  SeqLen := 0;
  CodePoint := 0;
  if Remaining <= 0 then
    Exit;
  b0 := Byte(P[0]);
  if b0 < $C2 then // ASCII 或非法首字节
    Exit;
  if b0 <= $DF then begin
    if Remaining < 2 then Exit;
    b1 := Byte(P[1]);
    if (b1 and $C0) <> $80 then Exit;
    SeqLen := 2;
    cp := ((b0 and $1F) shl 6) or (b1 and $3F);
  end else if b0 <= $EF then begin
    if Remaining < 3 then Exit;
    b1 := Byte(P[1]);
    b2 := Byte(P[2]);
    if ((b1 and $C0) <> $80) or ((b2 and $C0) <> $80) then Exit;
    cp := ((b0 and $0F) shl 12) or ((b1 and $3F) shl 6) or (b2 and $3F);
    if (cp < $800) or ((cp >= $D800) and (cp <= $DFFF)) then Exit; // 过长编码/代理区
    SeqLen := 3;
  end else if b0 <= $F4 then begin
    if Remaining < 4 then Exit;
    b1 := Byte(P[1]);
    b2 := Byte(P[2]);
    b3 := Byte(P[3]);
    if ((b1 and $C0) <> $80) or ((b2 and $C0) <> $80) or ((b3 and $C0) <> $80) then Exit;
    cp := ((b0 and $07) shl 18) or ((b1 and $3F) shl 12) or ((b2 and $3F) shl 6) or (b3 and $3F);
    if (cp < $10000) or (cp > $10FFFF) then Exit;
    SeqLen := 4;
  end else
    Exit;
  CodePoint := cp;
  Result := True;
end;

// 把一段字节按 ANSI(CP_ACP) 解码后追加到 S
procedure AppendAnsiBytes(var S: UnicodeString; const Bytes: RawByteString);
var
  n: Integer;
  part: UnicodeString;
begin
  if Bytes = '' then
    Exit;
  n := MultiByteToWideChar(CP_ACP, 0, PAnsiChar(Bytes), Length(Bytes), nil, 0);
  if n > 0 then begin
    SetLength(part, n);
    MultiByteToWideChar(CP_ACP, 0, PAnsiChar(Bytes), Length(Bytes), PWideChar(part), n);
    S := S + part;
  end;
end;
{$ENDIF}

// Convert raw bytes to UnicodeString, bypassing Lazarus default codepage handling.
// 工具链输出可能是混编码的：GCC 把源文件路径以 UTF-8 写进调试信息（诊断消息里的路径
// 因此是 UTF-8），而工具自身路径（来自 argv）与本地化消息是 ANSI(CP_ACP，如 GBK）。
// 因此：整段合法 UTF-8 时按 UTF-8 解码；否则逐段解码（见下）。
// On other platforms: compiler/tool output is UTF-8.
function AnsiBytesToUnicode(Buf: PAnsiChar; BufLen: Integer): UnicodeString;
{$IFDEF MSWINDOWS}
var
  Needed, i, SeqLen, PairLen: Integer;
  cp: Cardinal;
  ch: Word;
  Run: RawByteString;
begin
  Result := '';
  if (Buf = nil) or (BufLen <= 0) then
    Exit;

  // 快路径：整段就是合法 UTF-8（纯 ASCII 输出，或只含路径的诊断行）
  Needed := MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, Buf, BufLen, nil, 0);
  if Needed > 0 then begin
    SetLength(Result, Needed);
    if MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, Buf, BufLen, PWideChar(Result), Needed) > 0 then
      Exit;
    Result := '';
  end;

  // 混编码：逐段解码
  //  - 长度 >=3 的合法 UTF-8 序列取作 UTF-8（单个 ANSI/GBK 字符无法产生 3 字节序列，
  //    不会把 GBK 文字误当 UTF-8；2 字节 UTF-8 恰好可能是 GBK 汉字，故此处不接受）；
  //  - 其余按 ANSI(CP_ACP) 消费，成对消费 GBK 双字节字符，保证中文消息正确。
  Run := '';
  i := 0;
  while i < BufLen do begin
    if TryUtf8Seq(Buf + i, BufLen - i, SeqLen, cp) and (SeqLen >= 3) then begin
      AppendAnsiBytes(Result, Run);
      Run := '';
      if cp >= $10000 then begin
        Dec(cp, $10000);
        ch := $D800 or Word(cp shr 10);
        Result := Result + WideChar(ch);
        ch := $DC00 or Word(cp and $3FF);
        Result := Result + WideChar(ch);
      end else
        Result := Result + WideChar(Word(cp));
      Inc(i, SeqLen);
    end else begin
      PairLen := 1;
      if (Byte(Buf[i]) >= $81) and (i + 1 < BufLen) then begin
        ch := Byte(Buf[i + 1]);
        if ((ch >= $40) and (ch <= $7E)) or ((ch >= $80) and (ch <= $FE)) then
          PairLen := 2;
      end;
      if PairLen = 2 then
        Run := Run + Buf[i] + Buf[i + 1]
      else
        Run := Run + Buf[i];
      Inc(i, PairLen);
    end;
  end;
  AppendAnsiBytes(Result, Run);
end;
{$ELSE}
var
  tmp: AnsiString;
begin
  if (Buf = nil) or (BufLen <= 0) then
    Result := ''
  else begin
    SetString(tmp, Buf, BufLen);
    Result := UTF8ToUnicodeString(UTF8String(tmp));
  end;
end;
{$ENDIF}

procedure SplitCommandLine(const ACmdLine: String; ADest: TStrings);
// MSVCRT tokenization rules (identical to CommandLineToArgvW):
//  - whitespace outside quotes separates tokens, "..." groups text (spaces
//    and special chars inside are kept);
//  - backslashes are literal, EXCEPT directly before a quote:
//      2n   backslashes + "  ->  n backslashes, the quote toggles grouping
//      2n+1 backslashes + "  ->  n backslashes + a literal quote
// Operates on the UTF-8 string directly: quotes/backslashes/spaces are ASCII,
// multibyte UTF-8 sequences pass through untouched.
var
  I, N, NB, K: Integer;
  InQuote: Boolean;
  Tok: String;
begin
  ADest.Clear;
  I := 1;
  N := Length(ACmdLine);
  while I <= N do begin
    // skip whitespace between tokens
    while (I <= N) and ((ACmdLine[I] = ' ') or (ACmdLine[I] = #9)) do
      Inc(I);
    if I > N then
      Break;
    Tok := '';
    InQuote := False;
    while I <= N do begin
      if ACmdLine[I] = '\' then begin
        NB := 0;
        while (I <= N) and (ACmdLine[I] = '\') do begin
          Inc(NB);
          Inc(I);
        end;
        if (I <= N) and (ACmdLine[I] = '"') then begin
          for K := 1 to NB div 2 do
            Tok := Tok + '\';
          if Odd(NB) then
            Tok := Tok + '"'
          else
            InQuote := not InQuote;
          Inc(I); // consume the quote
        end else begin
          for K := 1 to NB do
            Tok := Tok + '\';
        end;
      end
      else if ACmdLine[I] = '"' then begin
        InQuote := not InQuote;
        Inc(I);
      end
      else if (not InQuote) and ((ACmdLine[I] = ' ') or (ACmdLine[I] = #9)) then
        Break // end of token
      else begin
        Tok := Tok + ACmdLine[I];
        Inc(I);
      end;
    end;
    ADest.Add(Tok);
  end;
end;

function RunAndGetOutput(const Cmd, WorkDir: String; LineOutputFunc: TLineOutputFunc;
  CheckAbortFunc: TCheckAbortFunc; ShowReturnValue: Boolean; LineOutputData: Pointer; CheckAbortData: Pointer): String;
var
  P: TProcess;
  Buf: array[0..8191] of Byte;
  nRead: Integer;
  RawBuf: RawByteString;
  LineBytes: RawByteString;
  s: String;
  LinePos: Integer;
  bAbort: Boolean;
begin
  Result := '';
  RawBuf := '';
  P := TProcess.Create(nil);
  try
    P.Options := [poUsePipes, poStderrToOutPut, poNoConsole];
    // TProcess.CommandLine is deprecated; split into Executable + Parameters
    // instead. FPC re-quotes each token via MaybeQuoteIfNotQuoted, so the
    // effective CreateProcess command line is unchanged.
    SplitCommandLine(Cmd, P.Parameters);
    if P.Parameters.Count > 0 then begin
      P.Executable := P.Parameters[0];
      P.Parameters.Delete(0);
    end;
    P.CurrentDirectory := WorkDir;
    try
      P.Active := True;
    except
      on E: Exception do begin Result := 'Process start error: ' + E.Message; Exit; end;
    end;
    bAbort := False;
    repeat
      if Assigned(CheckAbortFunc) then
        CheckAbortFunc(bAbort, CheckAbortData);
      if bAbort then begin
        P.Terminate(1);
        Break;
      end;
      nRead := P.Output.Read(Buf, SizeOf(Buf));
      if nRead > 0 then begin
        SetLength(RawBuf, Length(RawBuf) + nRead);
        Move(Buf[0], RawBuf[Length(RawBuf) - nRead + 1], nRead);
        while True do begin
          LinePos := Pos(#10, RawBuf);
          if LinePos = 0 then Break;
          LineBytes := Copy(RawBuf, 1, LinePos - 1);
          Delete(RawBuf, 1, LinePos);
          s := String(UTF8String(UTF8Encode(AnsiBytesToUnicode(PAnsiChar(LineBytes), Length(LineBytes)))));
          Result := Result + s + #10;
          if Assigned(LineOutputFunc) then
            LineOutputFunc(s, LineOutputData);
        end;
      end else if not P.Running then
        Break
      else
        Sleep(1);
    until False;
    if Length(RawBuf) > 0 then begin
      s := String(UTF8String(UTF8Encode(AnsiBytesToUnicode(PAnsiChar(RawBuf), Length(RawBuf)))));
      Result := Result + s;
      if Assigned(LineOutputFunc) then
        LineOutputFunc(s, LineOutputData);
    end;
    if ShowReturnValue then
      Result := Result + ' ' + IntToStr(P.ExitStatus);
  finally
    P.Free;
  end;
end;
{
procedure SetPath(const Add: String; UseOriginal: boolean = TRUE);
var
  OldPathW: array[0..4096] of WideChar;
  NewPath: String;
begin
  NewPath := Add;

  if NewPath <> '' then
    if NewPath[length(NewPath)] <> ';' then
      NewPath := NewPath + ';';

  // PATH environment variable does *not* like quotes in paths...
  // Even if there are spaces in pathnames, it doesn't matter.
  // It splits them up by the ';'
  NewPath := StringReplace(NewPath, '"', '', [rfReplaceAll]);

  if UseOriginal then
    NewPath := NewPath + devDirs.OriginalPath
  else begin
    // Use W (Unicode) API to preserve paths with non-ASCII characters (e.g. Chinese)
    Windows.GetEnvironmentVariableW('PATH', OldPathW, Length(OldPathW));
    NewPath := NewPath + String(OldPathW);
  end;

  // Use W (Unicode) API so paths with Chinese/non-ASCII characters reach the
  // child process correctly when CreateProcessW is called later.
  Windows.SetEnvironmentVariableW('PATH', PWideChar(UnicodeString(NewPath)));
end;
}
procedure SetPath(const Add: String; UseOriginal: boolean = TRUE);
{$IFDEF MSWINDOWS}
var
  OldPath: UnicodeString;
  Len: DWORD;
  NewPath: String;
begin
  NewPath := Add;

  if (NewPath <> '') and (NewPath[Length(NewPath)] <> ';') then
    NewPath := NewPath + ';';

  // PATH 环境变量不需要引号，它用 ';' 分隔
  NewPath := StringReplace(NewPath, '"', '', [rfReplaceAll]);

  if UseOriginal then
    NewPath := NewPath + devDirs.OriginalPath
  else begin
    // 先问长度，再分配（避免 4096 溢出，且 OldPath 自动为空 -> 零警告）
    Len := Windows.GetEnvironmentVariableW('PATH', nil, 0);
    if Len > 0 then begin
      SetLength(OldPath, Len - 1);  // Len 包含结尾 #0
      Windows.GetEnvironmentVariableW('PATH', @OldPath[1], Len);
      NewPath := NewPath + String(OldPath);
    end;
  end;

  // 用 W API 保证中文/非 ASCII 路径正确传给子进程
  Windows.SetEnvironmentVariableW('PATH', PWideChar(UnicodeString(NewPath)));
end;
{$ELSE}
// Linux / macOS: 用 SysUtils 的 ANSI 版本（POSIX 环境本身就是 UTF-8）
var
  OldPath: String;
  NewPath: String;
begin
  NewPath := Add;

  if (NewPath <> '') and (NewPath[Length(NewPath)] <> ';') then
    NewPath := NewPath + ';';

  NewPath := StringReplace(NewPath, '"', '', [rfReplaceAll]);

  if UseOriginal then
    NewPath := NewPath + devDirs.OriginalPath
  else begin
    // GetEnvironmentVariable 在失败时返回空串 -> 零警告、无垃圾
    OldPath := GetEnvironmentVariable('PATH');
    if OldPath <> '' then
      NewPath := NewPath + OldPath;
  end;

  // SetEnvironmentVariable 在 Linux 上设置当前进程环境
  SetEnvironmentVariable('PATH', NewPath);
end;
{$ENDIF}

function ValidateFile(const FileName: String; const WorkPath: String; const CheckDirs: boolean = FALSE):
  String;
var
  fName: String;
begin
  result := '';
  fName := ExtractFileName(FileName);
  if FileExists(FileName) then
    result := FileName
  else if FileExists(WorkPath + fName) then
    result := WorkPath + fName
  else if FileExists(WorkPath + FileName) then
    result := FileName
  else if CheckDirs then begin
    if (devDirs.Default <> '') and FileExists(devDirs.Default + fName) then
      result := devDirs.Default + fName
    else if (devDirs.Exec <> '') and FileExists(devDirs.Exec + fName) then
      result := devDirs.Exec + fName
    else if (devDirs.Help <> '') and FileExists(devDirs.Help + fName) then
      result := devDirs.Help + fName
    else if (devDirs.Lang <> '') and FileExists(devDirs.Lang + fName) then
      result := devDirs.Lang + fName
    else if (devDirs.Icons <> '') and FileExists(devDirs.Icons + fName) then
      result := devDirs.Icons + fName
    else if (devDirs.Templates <> '') and FileExists(devDirs.Templates + fName) then
      result := devDirs.Templates + fName;
  end;

end;

{
function GetShortName(const FileName: String): String;
var
  pFileName: array[0..2048] of char;
begin
  GetShortPathName(PChar(FileName), pFileName, 2048);
  result := StrPas(pFileName);
end;
}
function GetShortName(const FileName: String): String;
{$IFDEF MSWINDOWS}
var
  Len: DWORD;
begin
  // 先查询所需缓冲区长度
  Len := GetShortPathName(PChar(FileName), nil, 0);
  if Len = 0 then begin
    // API 调用失败（文件不存在 / 权限不足等），返回原路径
    Result := FileName;
    Exit;
  end;

  // 分配刚好大小的缓冲区（注意：Len 包含末尾 #0，所以 SetLength 用 Len - 1）
  SetLength(Result, Len - 1);
  GetShortPathName(PChar(FileName), @Result[1], Len);
end;
{$ELSE}
begin
  // 非 Windows 平台：没有 8.3 短路径概念，直接返回原路径
  Result := FileName;
end;
{$ENDIF}

function BuildFilter(const Filters: array of String): String;
var
  I: integer;
begin
  result := FLT_ALLFILES;
  for I := 0 to high(Filters) do begin

    // Check a few things:
    // 1) result must end with | before appending
    if result[Length(result)] <> '|' then
      result := result + '|';

    result := result + Filters[I];
  end;
end;

function CodeInstoStr(const s: String): String;
begin
  result := StringReplace(s, #13#10, '$_', [rfReplaceAll]);
end;

function StrtoCodeIns(const s: String): String;
begin
  result := StringReplace(s, '$_', #13#10, [rfReplaceAll]);
end;

procedure StrtoPoint(var pt: TPoint; const value: String);
var
  tmp: TStringList;
begin
  tmp := TStringList.Create;
  try
    tmp.CommaText := value;
    if tmp.Count >= 2 then
      with pt do begin
        // x=foreground y=background
        x := StringToColor(tmp[1]);
        y := StringtoColor(tmp[0]);
      end;
  finally
    tmp.Free;
  end;
end;

function PointtoStr(pt: TPoint): String;
begin
  result := format('%d, %d', [pt.y, pt.x]);
end;

{
function AttrtoStr(Attr: TSynHighlighterAttributes): String;
begin
  result := format('%s, %s, %d, %d, %d',
    [ColortoString(Attr.Foreground),
    ColortoString(Attr.Background),
      ord(fsBold in Attr.Style),
      ord(fsItalic in Attr.Style),
      ord(fsUnderline in Attr.Style)]);
end;
}
{
procedure StrtoAttr(var Attr: TSynHighlighterAttributes; const Value: String);
var
  tmp: TStringList;
begin
  tmp := TStringList.Create;
  try
    tmp.commaText := Value;
    if tmp.count = 5 then
      with attr do begin
        Foreground := StringtoColor(tmp[0]);
        Background := StringtoColor(tmp[1]);
        style := [];
        if tmp[2] = '1' then
          style := style + [fsbold]
        else
          style := style - [fsbold];
        if tmp[3] = '1' then
          style := style + [fsItalic]
        else
          style := style - [fsItalic];
        if tmp[4] = '1' then
          style := style + [fsUnderline]
        else
          style := style - [fsUnderline];
      end;
  finally
    tmp.Free;
  end;
end;
}
function FormatList(const sl: TStrings; formatstr: String): String;
var
  i: integer;
begin
  result := '';
  // Append by using formatstr
  for I := 0 to sl.Count - 1 do
    result := format(formatstr, [result, sl[i]]);
end;

function GetFileTyp(const FileName: String): TExUnitType;
var
  ext: String;
  // Helper: case-insensitive extension match against a list
  function ExtMatch(const e: String; const candidates: array of String): Boolean;
  var
    c: String;
  begin
    Result := False;
    for c in candidates do
      if SameText(e, c) then
      begin
        Result := True;
        Exit;
      end;
  end;
begin
  Ext := ExtractFileExt(FileName);
  if      ExtMatch(Ext, ['.dev'])       then Result := utPrj
  else if ExtMatch(Ext, ['.c'])         then Result := utcSrc
  else if ExtMatch(Ext, ['.cpp','.cc','.cxx','.c++','.cp']) then Result := utcppSrc
  else if ExtMatch(Ext, ['.h'])         then Result := utcHead
  else if ExtMatch(Ext, ['.hpp','.rh','.hh','.hxx','.inl']) then Result := utcppHead
  else if ExtMatch(Ext, ['.res','.rc']) then Result := utresSrc
  else if ExtMatch(Ext, ['.rh'])        then Result := utresHead
  else if ExtMatch(Ext, ['.f90','.f95','.f77','.for','.f']) then Result := utFortSrc
  else                                      Result := utOther;
end;

// seems stupid now but I want to expand to account for .. chars
//in basepath and or filename

function ExpandFileto(const FileName, BasePath: String): String;
var
  oldPath: String;
begin
  oldPath := GetCurrentDir;
  try
    if DirectoryExists(BasePath) then begin
      chdir(BasePath);
      result := ExpandFileName(FileName);
    end else
      Result := Filename; // no luck...
  finally
    chdir(oldPath);
  end;
end;

function FileSamePath(const FileName, TestPath: String): boolean;
var
  s1, s2: String;
begin
  result := FALSE;
  s1 := ExtractFilePath(FileName);
  s2 := ExtractFilePath(TestPath);
  if (s1 = s2) then
    result := TRUE
  else if (s1 = '') then
    result := FileExists(s2 + FileName);
end;

procedure CloneMenu(FromMenu, ToMenu: TMenuItem);
var
  idx: integer;
  Item: TMenuItem;
begin
  ToMenu.Clear;
  if FromMenu.Count <= 0 then
    exit;
  for idx := 0 to pred(FromMenu.Count) do begin
    Item := TMenuItem.Create(ToMenu);
    with FromMenu.Items[idx] do begin
      Item.Caption := Caption;
      Item.OnClick := OnClick;
      Item.Tag := Tag;
      Item.AutoCheck := AutoCheck;
      Item.ShortCut := ShortCut;
      Item.ImageIndex := ImageIndex;
      Item.Enabled := Enabled;
      Item.Checked := Checked;
      Item.Visible := Visible;
      Item.Default := Default;
    end;
    ToMenu.Add(Item);
  end;
  ToMenu.Visible := FromMenu.Visible;
end;

function FPos(const SubStr, S: String; start: integer): integer;
var
  i: Integer;
  pStr: PChar;
  pSub: PChar;
begin
  pSub := Pointer(SubStr);

  for i := start to Length(s) do begin
    pStr := @(s[i]);
    if (pStr^ = pSub^) then begin // compare char
      if CompareMem(pSub, pStr, Length(SubStr)) then begin // then compare whole string
        result := i;
        exit;
      end;
    end;
  end;

  result := 0;
end;

function RPos(const SubStr, s: AnsiString): integer;
begin
  result := RPos(SubStr, s, Length(s) - Length(SubStr) + 1);
end;

function RPos(const SubStr, S: AnsiString; start: integer): integer;
var
  i: Integer;
  pStr: PAnsiChar;
  pSub: PAnsiChar;
begin
  pSub := Pointer(SubStr);

  for i := start downto 1 do begin
    pStr := @(s[i]);
    if (pStr^ = pSub^) then begin // compare char
      if CompareMem(pSub, pStr, Length(SubStr)) then begin // then compare whole string
        result := i;
        exit;
      end;
    end;
  end;

  result := 0;
end;

function FindComplement(const s: String; fromtoken, totoken: char; var curpos: integer; increment: integer):
  boolean;
var
  level, curposbackup: integer;
begin
  curposbackup := curpos;
  level := 0;
  while (curpos <= Length(s)) and (curpos > 0) do begin
    if (s[curpos] = fromtoken) then begin
      Inc(level);
    end else if (s[curpos] = totoken) then begin
      Dec(level);
      if level = 0 then begin
        Result := true;
        Exit;
      end;
    end;
    Inc(curpos, increment);
  end;
  curpos := curposbackup;
  Result := false;
end;

{ GenMakePath: convert a filename to a format that can be used by make }

function GenMakePath1(const FileName: String): String;
begin
  Result := GenMakePath(FileName, False, True);
end;

function GenMakePath2(const FileName: String): String;
begin
  Result := GenMakePath(FileName, True, False);
end;

function GenMakePath(const FileName: String; EscapeSpaces, EncloseInQuotes: Boolean): String;
begin
  Result := FileName;

  { Convert backslashes to slashes }
  Result := StringReplace(Result, '\', '/', [rfReplaceAll]);

  if EscapeSpaces then
    Result := StringReplace(Result, ' ', '\ ', [rfReplaceAll]);

  if EncloseInQuotes then
    if (Pos(' ', Result) > 0) then
      Result := '"' + Result + '"';
end;

function GetRealPath(const BrokenFileName, Directory: String): String;
var
  e: TEditor;
begin
  Result := BrokenFileName;
  if (ExtractFileExt(Result) = '.exe') then begin
{$IFDEF WIN32}
    Result := StringReplace(Result, '/', '\', [rfReplaceAll]);
{$ENDIF}
    Exit;
  end;

  // There are 3 kinds of bad filenames:
  // 1: C:/Foo/Bar.txt              (must be backslashes)
  // 2: /C/WINDOWS/Desktop/foo.c    (WinUnix paths?)
  // 3: foo.c                       (not an absolute filename)

  // First, check if this is a WinUnix path
  if CompareText(Copy(Result, 1, 1), '/') = 0 then begin
    Delete(Result, 1, 2);
    Result[2] := ':';
    Insert('\', Result, 3);
  end;

  // Second, check if this is an absolute filename
  if (Length(Result) < 4) or not (CharInSet(LowerCase(Result)[1],['A'..'Z']) and (Result[2] = ':')) then begin
    // It's not
    if Length(Directory) = 0 then begin
      if Assigned(MainForm.Project) then
        Result := ExpandFileTo(Result, MainForm.Project.Directory)
      else begin
        e := MainForm.EditorList.GetEditor;
        if (Assigned(e)) and (Length(ExtractFileDir(AnsiString(e.FileName))) > 0) then
          Result := ExpandFileTo(Result, ExtractFileDir(AnsiString(e.FileName)))
        else
          Result := ExpandFileName(Result);
      end;
    end else begin
      Result := ExpandFileTo(Result, Directory);
    end;
  end;

  // Last, replace all slashes with backslahes
{$IFDEF WIN32}
  Result := StringReplace(Result, '/', '\', [rfReplaceAll]);
{$ENDIF}
end;

function IncludeQuoteIfSpaces(const s: String): String;
begin
  if pos(' ', s) > 0 then
    result := '"' + s + '"'
  else
    result := s;
end;

function IncludeQuoteIfNeeded(const s: String): String;
begin
  if pos('"', s) = 0 then
    result := '"' + s + '"'
  else
    result := s;
end;

// added by mandrav 13 Sep 2002
// returns the file version of the .exe specified by filename
// in the form x.x.x.x

function GetVersionString(const FileName: String): String;
var
  Buf: Pointer;
  i: cardinal;
  P: pointer;
  pSize: cardinal;
  ffi: TVSFixedFileInfo;
begin
  Result := '';
  i := 0;
  i := GetFileVersionInfoSize(PChar(FileName), i);
  if i = 0 then
    Exit;

  Buf := AllocMem(i);
  try
    if not GetFileVersionInfo(PChar(FileName), 0, i, Buf) then
      Exit;

    p := nil;
    pSize := SizeOf(P);
    VerQueryValue(Buf, '\', p, pSize);

    ffi := TVSFixedFileInfo(p^);
    Result := Format('%d.%d.%d.%d', [
      HiWord(ffi.dwFileVersionMS),
        LoWord(ffi.dwFileVersionMS),
        HiWord(ffi.dwFileVersionLS),
        LoWord(ffi.dwFileVersionLS)]);
  finally
    FreeMem(Buf);
  end;
end;

function GetAssociatedProgram(const Extension: String; var Filename, Description: String): boolean;
{$IFDEF MSWINDOWS}
{$PUSH}
{$WARN SYMBOL_PLATFORM OFF}
const
  NOVALUE = '$__NONE__$';
var
  R: TRegIniFile;
  Base, S: String;
begin
  Result := False;
  R := TRegIniFile.Create;
  S := '';
  try
    R.RootKey := HKEY_CLASSES_ROOT;
    Base := R.ReadString(Extension, '', NOVALUE);
    if Base = NOVALUE then
      Exit;
    S := R.ReadString(Base + '\shell\open\command', '', NOVALUE);
    if S = NOVALUE then
      Exit;
    Filename := S; // filename probably contains args, e.g. Filename='"some where\my.exe" "%1"'

    Description := ExtractFilename(S);
    Result := True;
    S := R.ReadString(Base + '\shell\open\ddeexec\application', '', NOVALUE);
    if S = NOVALUE then
      Description := 'Default application'
    else
      Description := S;
    if S = 'DEVCPP' then // avoid extensions registered to DevCpp ;)
      Result := False;
  finally
    R.Free;
  end;
{$POP}
{$ELSE}
// Linux: query the default application for a MIME type via xdg-mime
// If the extension is already a MIME type (e.g. 'text/x-csrc'), use it directly.
// Otherwise, map common source extensions to MIME types.
var
  MIMEType, Cmd: String;
  P: TProcess;
  SL: TStringList;
  F: TextFile;
begin
  Result := False;
  // Map common C/C++ extensions to MIME types
  if Extension = '.c' then
    MIMEType := 'text/x-csrc'
  else if Extension = '.cpp' then
    MIMEType := 'text/x-c++src'
  else if Extension = '.h' then
    MIMEType := 'text/x-chdr'
  else if Extension = '.hpp' then
    MIMEType := 'text/x-c++hdr'
  else
    MIMEType := '';

  if MIMEType <> '' then begin
    // Query the default application for this MIME type
    P := TProcess.Create(nil);
    SL := TStringList.Create;
    try
      P.Executable := 'xdg-mime';
      P.Parameters.Add('query');
      P.Parameters.Add('default');
      P.Parameters.Add(MIMEType);
      P.Options := [poWaitOnExit, poUsePipes];
      P.Execute;
      SL.LoadFromStream(P.Output);
      if SL.Count > 0 then
        Cmd := Trim(SL.Text)
      else begin
        // Try fallback: read from mimeapps.list
        Cmd := '';
        if FileExists(GetEnvironmentVariable('HOME') + '/.config/mimeapps.list') then begin
          AssignFile(F, GetEnvironmentVariable('HOME') + '/.config/mimeapps.list');
          Reset(F);
          while not Eof(F) do begin
            ReadLn(F, S);
            if Pos('[Default Applications]', S) = 1 then
              Continue;
            if (Pos(MIMEType, S) > 0) and (Pos('=', S) > 0) then begin
              Cmd := Copy(S, Pos('=', S) + 1, Length(S));
              Break;
            end;
          end;
          CloseFile(F);
        end;
      end;
      if Cmd <> '' then begin
        // Extract .desktop file name, e.g. "code.desktop" -> "Code"
        Filename := Cmd;
        Description := ChangeFileExt(ExtractFileName(Cmd), '');
        Result := True;
      end;
    finally
      SL.Free;
      P.Free;
    end;
  end else begin
    Filename := '';
    Description := 'Default application';
  end;
{$ENDIF}
end;

function IsNumeric(const s: String): boolean;
var
  i: integer;
begin
  result := true;
  for i := 1 to length(s) do
    if not CharInSet(s[i], ['0'..'9']) then begin
      result := false;
      exit;
    end;
end;

function CountChar(const s: String; c: char): integer;
var
  i: integer;
begin
  result := 0;
  for i := 1 to length(s) do
    if s[i] = c then
      Inc(result);
end;

{$IFDEF MSWINDOWS}
function NewSelectDirectoryCallback(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
begin
  if (uMsg = BFFM_INITIALIZED) and (lpData <> 0) then
    SendMessage(Wnd, BFFM_SETSELECTION, Integer(True), lpdata);
  result := 0;
end;

function NewSelectDirectory(const Caption: string; const Root: WideString; var Directory: string): Boolean;
var
  BrowseInfo: TBrowseInfo;
  Buffer: PChar;
  OldErrorMode: Cardinal;
  RootItemIDList, ItemIDList: PItemIDList;
  ShellMalloc: IMalloc;
  IDesktopFolder: IShellFolder;
  Eaten, Flags: LongWord;
begin
  Result := False;
  Eaten := 0;
  Flags := 0;
  if not DirectoryExists(Directory) then
    Directory := '';

  BrowseInfo := Default(TBrowseInfo);
  FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
  if (ShGetMalloc(ShellMalloc) = S_OK) and (ShellMalloc <> nil) then begin
    Buffer := ShellMalloc.Alloc(MAX_PATH);
    try
      RootItemIDList := nil;
      if Root <> '' then begin
        SHGetDesktopFolder(IDesktopFolder);
        IDesktopFolder.ParseDisplayName(Application.MainFormHandle, nil,
          POleStr(Root), Eaten, RootItemIDList, Flags);
      end;
      BrowseInfo.hwndOwner := Application.MainFormHandle;
      BrowseInfo.pidlRoot := RootItemIDList;
      BrowseInfo.pszDisplayName := Buffer;
      BrowseInfo.lpszTitle := PChar(Caption);
      BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS or BIF_USENEWUI;
      if Directory <> '' then begin
        BrowseInfo.lpfn := @NewSelectDirectoryCallback;
        BrowseInfo.lParam := PtrInt(PChar(Directory));
      end;
      OldErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
      try
        ItemIDList := ShBrowseForFolder(BrowseInfo);
      finally
        SetErrorMode(OldErrorMode);
      end;
      Result := ItemIDList <> nil;
      if Result then begin
        ShGetPathFromIDList(ItemIDList, Buffer);
        ShellMalloc.Free(ItemIDList);
        Directory := Buffer;
      end;
    finally
      ShellMalloc.Free(Buffer);
    end;
  end;
end;
{$ELSE}
// Linux fallback: use Lazarus SelectDirectoryDialog
function NewSelectDirectory(const Caption: string; const Root: WideString; var Directory: string): Boolean;
var
  DirOut: string;
begin
  DirOut := Directory;
  Result := SelectDirectory(Caption, Root, DirOut,
    [sdShowCreateDir, sdShowFiles, sdValidateDir]);
  if Result then
    Directory := DirOut;
end;
{$ENDIF}

function GetFileSize(const FileName: String): integer;
var
  F: TSearchRec;
begin
  if FindFirst(FileName, faAnyFile, F) = 0 then
    Result := F.Size
  else
    Result := 0;
end;

function FormatFileSize(Size: integer): String;
begin
  if Size = 0 then
    Result := '0'
  else if Size < 1024 then
    Result := IntToStr(Size) + ' ' + Lang[ID_BYTES]
  else if Size < 1024 * 1024 then
    Result := FloatToStrF(Size / 1024, ffGeneral, 4, 1) + ' KiB'
  else if Size < 1024 * 1024 * 1024 then
    Result := FloatToStrF((Size / 1024) / 1024, ffGeneral, 4, 1) + ' MiB'
  else
    Result := FloatToStrF(((Size / 1024) / 1024) / 1024, ffGeneral, 4, 1) + ' GiB';
end;

function ShortenLogOutput(const Input: String): String;
var
  I: integer;
begin
  // Shorten compiler paths
  Result := Input;
  if devData.ShortenCompPaths and Assigned(devCompilerSets.CompilationSet) then begin
    with devCompilerSets.CompilationSet do begin
      for I := 0 to BinDir.Count - 1 do
        Result := StringReplace(Result, BinDir[i], '%BinDir' + IntToStr(i) + '%', [rfReplaceAll]);
      for I := 0 to CppDir.Count - 1 do
        Result := StringReplace(Result, CppDir[i], '%CppIncludeDir' + IntToStr(i) + '%', [rfReplaceAll]);
      for I := 0 to CDir.Count - 1 do
        Result := StringReplace(Result, CDir[i], '%CIncludeDir' + IntToStr(i) + '%', [rfReplaceAll]);
      for I := 0 to LibDir.Count - 1 do
        Result := StringReplace(Result, LibDir[i], '%LibDir' + IntToStr(i) + '%', [rfReplaceAll]);
    end;
    Result := StringReplace(Result, devDirs.Exec, '%Dev-Cpp%\', [rfReplaceAll]);
  end;
end;

end.

