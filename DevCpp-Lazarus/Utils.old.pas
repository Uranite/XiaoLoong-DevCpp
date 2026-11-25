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

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Classes, Sysutils, Dateutils, Forms, Dialogs, ATSynEdit, Windows,
  Menus, Registry, Controls, ComCtrls, Messages;

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
    utMakefile, // makefile (.win)
    utFortSrc, //FORTRAN source file (.f90 .f95 .f77 .for .f
    utOther // any others
    );

  TFilterSet = (ftOpen, ftPrj, ftSrc, ftAll);

  TLineOutputFunc = procedure(const Line: String) of object;
  TCheckAbortFunc = procedure(var AbortThread: boolean) of object;

procedure FilesFromWildcard(Directory: String; const Mask: String; Files: TStringList; Subdirs, ShowDirs,
  Multitasking: Boolean);

function ExecuteFile(const FileName, Params, DefaultDir: String; ShowCmd: Integer): THandle;
function RunAndGetOutput(const Cmd, WorkDir: String; LineOutputFunc: TLineOutputFunc; CheckAbortFunc:
  TCheckAbortFunc; ShowReturnValue: Boolean = True): String;

function GetShortName(const FileName: String): String;

function FormatList(const sl: TStrings; formatstr: String): String;
function IncludeQuoteIfSpaces(const s: String): String;
function IncludeQuoteIfNeeded(const s: String): String;

function ValidateFile(const FileName: String; const WorkPath: String; const CheckDirs: boolean = FALSE):
  String;

function BuildFilter(const Filters: array of String): String;

function CodeInstoStr(const s: String): String;
function StrtoCodeIns(const s: String): String;

// TODO: EControl adapter - reimplement with ATSynHighlighterAttributes
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

function ProgramHasConsole(const path: String): boolean;

IMPLEMENTATION

function ProgramHasConsole(const path: String): boolean;
begin
  // TODO: ATSynEdit - PE header types not available, default to false
  Result := false;
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

function IsWindows64: boolean;
var
  buffer: array[0..1023] of char;
begin
  // IsWow64Process not available in Delphi 7, so using this instead
  buffer := SysUtils.GetEnvironmentVariable('PROGRAMFILES');
  result := EndsStr(' (x86)', String(buffer));
end;

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
  if (i = -1); // selection
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

function ProgramHasConsole(const path: String): boolean;
begin
  // TODO: ATSynEdit - PE header types not available, default to false
  Result := false;
end;
