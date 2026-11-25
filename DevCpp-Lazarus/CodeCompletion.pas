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

unit CodeCompletion;

interface

uses
{$IFDEF MSWINDOWS}
  {$IFDEF MSWINDOWS}Windows{$ELSE}LCLIntf, LCLType{$ENDIF},
{$ENDIF}
  Classes, Forms, SysUtils, Controls, Graphics, CppParser,
  CButils, StatementList, CodeCompletionForm;


type

  TCodeCompletion = class(TComponent, ICodeCompletionFormEvents)
  private
    CodeComplForm: TCodeComplForm;
    fParser: TCppParser;
    fFullCompletionStatementList: TList;
    fCompletionStatementList: TList;
    CppKeywordsList: TStringList;  //
    CppPreProceList: TStringList;  //
    fMinWidth: integer;
    fMinHeight: integer;
    fMaxWidth: integer;
    fMaxHeight: integer;
    fPos: TPoint;
    fColor: TColor;
    fWidth: integer;
    fHeight: integer;
    fFontSize: integer;
    fEnabled: boolean;
    fShowCount: integer;
    fOnKeyPress: TKeyPressEvent;
    fOnResize: TNotifyEvent;
    fOnlyGlobals: boolean;
    fCurrentStatement: PStatement;
    fHideDelay: integer; // allow empty list once, then hide when empty again
    fIncludedFiles: TStringList;
    fIsIncludedCacheFileName: AnsiString;
    fIsIncludedCacheResult: boolean;
    function ApplyClassFilter(Statement, CurrentClass: PStatement; InheritanceStatements: TList): boolean;
    function ApplyMemberFilter(Statement, CurrentClass, ParentClass: PStatement; InheritanceStatements: TList): boolean;
    procedure GetCompletionFor(target: ansistring; Phrase: AnsiString; Filename: string);
    procedure FilterList(const Member: AnsiString);
    procedure SetPosition(Value: TPoint);
    procedure OnFormResize(Sender: TObject);
    function IsIncluded(const FileName: AnsiString): boolean;
    function IsVisible: boolean;
    // ICodeCompletionFormEvents ʵ��
    procedure OnFormKeyPress(Sender: TObject; var Key: Char);
    procedure OnFormHide;
    function GetParser: TCppParser;
    function GetColor: TColor;
//  protected
//    procedure CreateForm;
//    procedure DestroyForm;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Search(const target, Phrase, Filename: AnsiString);
    procedure Hide;
    function SelectedStatement: PStatement;
    property CurrentStatement: PStatement read fCurrentStatement write fCurrentStatement;
    property Position: TPoint read fPos write SetPosition;
  published
    property ShowCount: integer read fShowCount write fShowCount;
    property Parser: TCppParser read fParser write fParser;
    property Color: TColor read fColor write fColor;
    property Width: integer read fWidth write fWidth;
    property Height: integer read fHeight write fHeight;
    property FontSize: integer read fFontSize write fFontSize;
    property Enabled: boolean read fEnabled write fEnabled;
    property MinWidth: integer read fMinWidth write fMinWidth;
    property MinHeight: integer read fMinHeight write fMinHeight;
    property MaxWidth: integer read fMaxWidth write fMaxWidth;
    property MaxHeight: integer read fMaxHeight write fMaxHeight;
    property OnKeyPress: TKeyPressEvent read fOnKeyPress write fOnKeyPress;
    property OnResize: TNotifyEvent read fOnResize write fOnResize;
    property OnlyGlobals: boolean read fOnlyGlobals write fOnlyGlobals;
    property Visible: boolean read IsVisible;
  end;

//procedure Register;

implementation

uses
   Math;

{ TCodeCompletion }

//procedure Register;
//begin
//  RegisterComponents('Dev-C++', [TCodeCompletion]);
//end;

constructor TCodeCompletion.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  fIncludedFiles := TStringList.Create;
  fIncludedFiles.Sorted := True;
  fIncludedFiles.Duplicates := dupIgnore;

  fCompletionStatementList := TList.Create;
  fFullCompletionStatementList := TList.Create;

//  CodeComplForm := TCodeComplForm.Create(Self);
//  CreateForm;
  if not Assigned(CodeComplForm) then
    CodeComplForm := TCodeComplForm.Create(nil, Self);
    //CodeComplForm := TCodeComplForm.Create(Self, nil);

  CodeComplForm.OnResize := @OnFormResize;
  CodecomplForm.Font.Size := fFontSize;

  fWidth := 200;  //320;
  fHeight := 120; //240;
  fColor := clWindow;
  fEnabled := True;
  fOnlyGlobals := False;
  fShowCount := 100; // keep things fast
  fHideDelay := 0;

  fIsIncludedCacheFileName := '';
  fIsIncludedCacheResult := false;

  //CppKeywordsList. Copied from RedPanda Dev-C++
  CppKeywordsList := TStringList.Create;

  CppKeywordsList.Add('and');
  CppKeywordsList.Add('and_eq');
  CppKeywordsList.Add('bitand');
  CppKeywordsList.Add('bitor');
  CppKeywordsList.Add('break');
  CppKeywordsList.Add('compl');
  CppKeywordsList.Add('constexpr');
  CppKeywordsList.Add('const_cast');
  CppKeywordsList.Add('continue');
  CppKeywordsList.Add('dynamic_cast');
  CppKeywordsList.Add('else');
  CppKeywordsList.Add('explicit');
  CppKeywordsList.Add('export');
  CppKeywordsList.Add('extern');
  CppKeywordsList.Add('false');
  CppKeywordsList.Add('mutable');
  CppKeywordsList.Add('noexcept');
  CppKeywordsList.Add('not');
  CppKeywordsList.Add('not_eq');
  CppKeywordsList.Add('nullptr');
  CppKeywordsList.Add('or');
  CppKeywordsList.Add('or_eq');
  CppKeywordsList.Add('register');
  CppKeywordsList.Add('reinterpret_cast');
  CppKeywordsList.Add('static_assert');
  CppKeywordsList.Add('static_cast');
  CppKeywordsList.Add('template');
//  CppKeywordsList.Add('this');
  CppKeywordsList.Add('thread_local');
  CppKeywordsList.Add('true');
  CppKeywordsList.Add('typename');
  CppKeywordsList.Add('virtual');
  CppKeywordsList.Add('volatile');
  CppKeywordsList.Add('xor');
  CppKeywordsList.Add('xor_eq');


  CppKeywordsList.Add('do');
  CppKeywordsList.Add('try');

  // Skip to ;
  CppKeywordsList.Add('delete');
  CppKeywordsList.Add('delete[]');
  CppKeywordsList.Add('goto');
  CppKeywordsList.Add('new');
  CppKeywordsList.Add('return');
  CppKeywordsList.Add('throw');

  // Skip to :
  CppKeywordsList.Add('case');
  CppKeywordsList.Add('default');

  // Skip to )
  CppKeywordsList.Add('__attribute__');
  CppKeywordsList.Add('alignas');  // not right
  CppKeywordsList.Add('alignof');  // not right
  CppKeywordsList.Add('decltype'); // not right
  CppKeywordsList.Add('if');
  CppKeywordsList.Add('sizeof');
  CppKeywordsList.Add('switch');
  CppKeywordsList.Add('typeid');
  CppKeywordsList.Add('while');

  // Skip to }
  CppKeywordsList.Add('asm');

  // wont handle

  //Not supported yet
  CppKeywordsList.Add('atomic_cancel');
  CppKeywordsList.Add('atomic_commit');
  CppKeywordsList.Add('atomic_noexcept');
  CppKeywordsList.Add('concept');
  CppKeywordsList.Add('consteval');
  CppKeywordsList.Add('constinit');
  CppKeywordsList.Add('co_wait');
  CppKeywordsList.Add('co_return');
  CppKeywordsList.Add('co_yield');
  CppKeywordsList.Add('reflexpr');
  CppKeywordsList.Add('requires');

  // its a type
  CppKeywordsList.Add('auto');
  CppKeywordsList.Add('bool');
  CppKeywordsList.Add('char');
  CppKeywordsList.Add('char8_t');
  CppKeywordsList.Add('char16_t');
  CppKeywordsList.Add('char32_t');
  CppKeywordsList.Add('double');
  CppKeywordsList.Add('float');
  CppKeywordsList.Add('int');
  CppKeywordsList.Add('long');
  CppKeywordsList.Add('short');
  CppKeywordsList.Add('signed');
  CppKeywordsList.Add('unsigned');
  CppKeywordsList.Add('void');
  CppKeywordsList.Add('wchar_t');

  // it's part of type info
  CppKeywordsList.Add('const');
  CppKeywordsList.Add('inline');

  // handled elsewhere
  CppKeywordsList.Add('class');
  CppKeywordsList.Add('enum');
  CppKeywordsList.Add('friend');
  CppKeywordsList.Add('operator');
  CppKeywordsList.Add('private');
  CppKeywordsList.Add('protected');
  CppKeywordsList.Add('public');
  CppKeywordsList.Add('static');
  CppKeywordsList.Add('struct');
  CppKeywordsList.Add('typedef');
  CppKeywordsList.Add('union');
  // namespace
  CppKeywordsList.Add('namespace');
  CppKeywordsList.Add('using');

  CppKeywordsList.Add('for');
  CppKeywordsList.Add('catch');

  // nullptr is value
  CppKeywordsList.Add('nullptr');

  // C++ namespace
  CppKeywordsList.Add('std');
  CppKeywordsList.Add('literals');

  // preprecesor.      //by Anbangli
  CppPreProceList := TStringList.Create;
  CppPreProceList.Add('#include');
  CppPreProceList.Add('#if');
  CppPreProceList.Add('#ifdef');
  CppPreProceList.Add('#ifndef');
  CppPreProceList.Add('#else');
  CppPreProceList.Add('#elif');
  CppPreProceList.Add('#endif');
  CppPreProceList.Add('#define');
  CppPreProceList.Add('#error');
  CppPreProceList.Add('#pragma');
  CppPreProceList.Add('#line');

  CppPreProceList.Add('assert.h');
  CppPreProceList.Add('complex.h');//C99
  CppPreProceList.Add('ctype.h');
  CppPreProceList.Add('errno.h');
  CppPreProceList.Add('fenv.h');//C99
  CppPreProceList.Add('float.h');
  CppPreProceList.Add('inttypes.h');//C99
  CppPreProceList.Add('iso646.h');//C99
  CppPreProceList.Add('limits.h');
  CppPreProceList.Add('locale.h');
  CppPreProceList.Add('math.h');
  CppPreProceList.Add('setjmp.h');
  CppPreProceList.Add('signal.h');
  CppPreProceList.Add('stdarg.h');
  CppPreProceList.Add('stdbool.h');//C99
  CppPreProceList.Add('stddef.h');
  CppPreProceList.Add('stdint.h');//C99
  CppPreProceList.Add('stdio.h');
  CppPreProceList.Add('stdlib.h');
  CppPreProceList.Add('string.h');
  CppPreProceList.Add('tgmath.h');//C99
  CppPreProceList.Add('time.h');
  CppPreProceList.Add('wchar.h');//C99
  CppPreProceList.Add('wctype.h');  //C99

  //C++
  CppPreProceList.Add('cstddef');
  CppPreProceList.Add('limits');
  CppPreProceList.Add('climits');
  CppPreProceList.Add('cfloat');
  CppPreProceList.Add('cstdint');
  CppPreProceList.Add('new');
  CppPreProceList.Add('typeinfo');
  CppPreProceList.Add('exception');
  CppPreProceList.Add('initializer_list'); //(C++11)
  CppPreProceList.Add('csignal');
  CppPreProceList.Add('csetjmp');
  CppPreProceList.Add('cstdarg');

  CppPreProceList.Add('utility');
  CppPreProceList.Add('tuple'); //(C++11)
  CppPreProceList.Add('optional'); //(C++17)
  CppPreProceList.Add('any'); //(C++17)
  CppPreProceList.Add('variant'); //(C++17)
  CppPreProceList.Add('memory');
  CppPreProceList.Add('scoped_allocator'); //(C++11)
  CppPreProceList.Add('type_traits'); //(C++11)
  CppPreProceList.Add('functional');
  CppPreProceList.Add('algorithm');
  CppPreProceList.Add('iterator');
  CppPreProceList.Add('ctime');

  CppPreProceList.Add('cstring');
  CppPreProceList.Add('cctype');
  CppPreProceList.Add('cwctype');
  CppPreProceList.Add('string');
  CppPreProceList.Add('cwchar');
  CppPreProceList.Add('cuchar'); //(C++11)

  CppPreProceList.Add('vector');
  CppPreProceList.Add('deque');
  CppPreProceList.Add('list');
  CppPreProceList.Add('forward_list'); //(C++11)
  CppPreProceList.Add('array'); //(C++11)
  CppPreProceList.Add('set');
  CppPreProceList.Add('map');
  CppPreProceList.Add('unordered_set'); //(C++11)
  CppPreProceList.Add('unordered_map'); //(C++11)
  CppPreProceList.Add('stack');
  CppPreProceList.Add('queue');
  CppPreProceList.Add('span'); //(C++20)

  CppPreProceList.Add('complex');
  CppPreProceList.Add('random'); //(C++11)
  CppPreProceList.Add('valarray');
  CppPreProceList.Add('numeric');
  CppPreProceList.Add('cmath');
  CppPreProceList.Add('cfenv'); //(C++11)
  CppPreProceList.Add('bit'); //(C++20)

  CppPreProceList.Add('iostream');
  CppPreProceList.Add('ios');
  CppPreProceList.Add('iosfwd');
  CppPreProceList.Add('streambuf');
  CppPreProceList.Add('istream');
  CppPreProceList.Add('ostream');
  CppPreProceList.Add('iomanip');
  CppPreProceList.Add('sstream');
  CppPreProceList.Add('fstream');
  CppPreProceList.Add('filesystem'); //(C++17)
  CppPreProceList.Add('cstdio');
  CppPreProceList.Add('cinttypes');

  CppPreProceList.Add('regex'); //(C++11)

  CppPreProceList.Add('atomic'); //(C++11)

  CppPreProceList.Add('thread'); //(C++11)
  CppPreProceList.Add('mutex'); //(C++11)
  CppPreProceList.Add('shared_mutex'); //(C++17)
  CppPreProceList.Add('condition_variable'); //(C++11)
  CppPreProceList.Add('future'); //(C++11)
  CppPreProceList.Add('stop_token'); //(C++20)
  CppPreProceList.Add('semaphore'); //(C++20)

  CppPreProceList.Add('locale');
  CppPreProceList.Add('clocale');

  CppPreProceList.Add('cerrno');
  CppPreProceList.Add('ciso646');
  CppPreProceList.Add('assert');
  //CppPreProceList.Add('cspec');//

end;

destructor TCodeCompletion.Destroy;
begin
  //DestroyForm;
  FreeAndNil(CodeComplForm);
  FreeAndNil(fCompletionStatementList);
  FreeAndNil(fFullCompletionStatementList);
  FreeAndNil(fIncludedFiles);
  FreeAndNil(CppKeywordsList);
  FreeAndNil(CppPreProceList);
  inherited Destroy;
end;

//procedure TCodeCompletion.CreateForm;
//begin
//  if not Assigned(CodeComplForm) then
//    CodeComplForm := TCodeComplForm.Create(nil, Self);
//end;

//procedure TCodeCompletion.DestroyForm;
//begin
//  FreeAndNil(CodeComplForm);
//end;

procedure TCodeCompletion.OnFormKeyPress(Sender: TObject; var Key: Char);
begin
  if Assigned(fOnKeyPress) then
    fOnKeyPress(Sender, Key);
end;

procedure TCodeCompletion.OnFormHide;
begin
  Hide;
end;

function TCodeCompletion.ApplyClassFilter(Statement, CurrentClass: PStatement; InheritanceStatements: TList): boolean;
begin
  Result :=
    (
    (Statement^._Scope in [ssLocal, ssGlobal]) or // local or global var or
    (
    (Statement^._Scope = ssClassLocal) and // class var
    (
    (Statement^._Parent = CurrentClass) or // from current class
    (
    (InheritanceStatements.IndexOf(Statement^._Parent) <> -1) and
    (Statement^._ClassScope <> scsPrivate)
    ) // or an inheriting class
    )
    )
    )  and
    (IsIncluded(Statement^._FileName) or IsIncluded(Statement^._DefinitionFileName));
end;

function TCodeCompletion.ApplyMemberFilter(Statement, CurrentClass, ParentClass: PStatement; InheritanceStatements:
  TList): boolean;
var
  cs: set of TStatementClassScope;
begin
  Result := Statement^._Parent <> nil; // only members
  if not Result then
    Exit;

  // all members of current class
  Result := Result and ((ParentClass = CurrentClass) and (Statement^._Parent = ParentClass));

  // all public and published members of var's class
  Result := Result or
    (
    (ParentClass = Statement^._Parent) and
    (not (Statement^._ClassScope in [scsProtected, scsPrivate]))
    // or member of an inherited class
    );

  if (CurrentClass = nil) or (Statement^._Parent = CurrentClass) then
    cs := [scsPrivate, scsProtected]
  else
    cs := [scsPrivate];

  // all inherited class's non-private members
  Result := Result or
    (
    (InheritanceStatements.IndexOf(Statement^._Parent) <> -1) and
    (not (Statement^._ClassScope in cs)) // or member of an inherited class
    );
end;

procedure TCodeCompletion.GetCompletionFor(target: AnsiString; Phrase: AnsiString; Filename: string);
var
  Node: PStatementNode;
  Statement: PStatement;
  I: integer;
  InheritanceStatements: TList;
  ParentStatement, ParentTypeStatement, CurrentStatementParent: PStatement;
  codeInStatement: PStatement;
begin
  // Reset filter cache
  fIsIncludedCacheFileName := '';
  fIsIncludedCacheResult := false;

  // Pulling off the same trick as in TCppParser.FindStatementOf, but ignore everything after last operator
  InheritanceStatements := TList.Create;
  try
    I := fParser.FindLastOperator(Phrase);
    if I = 0 then begin
      if target = 'prepro' then begin  //preprocessor
        for i := 0 to CppPreProceList.Count-1 do begin
          new(codeInStatement);
          codeInStatement^._Command := CppPreProceList[i];
          codeInStatement^._Kind := skKeyword;
          codeInStatement^._InSystemHeader := False;
          codeInStatement^._Scope := ssGlobal;
          //codeInStatement^._FullName := CppPreProceList[i];
          //fCodeInsStatements.Add(pointer(codeInStatement));
          fFullCompletionStatementList.Add(pointer(codeInStatement));
        end
      end
      else begin
      //add keywords
        for i := 0 to CppKeywordsList.Count-1 do begin
          new(codeInStatement);
          codeInStatement^._Command := CppKeywordsList[i];
          codeInStatement^._Kind := skKeyword;
          codeInStatement^._InSystemHeader := False;
          codeInStatement^._Scope := ssGlobal;
          //codeInStatement^._FullName := CppKeywordsList[i];
          //fCodeInsStatements.Add(pointer(codeInStatement));
          fFullCompletionStatementList.Add(pointer(codeInStatement));
        end;
        // only add globals and members of the current class
        // Also consider classes the current class inherits from
        fParser.GetMultipleInheritanceStatements(fCurrentStatement, InheritanceStatements);
        Node := fParser.Statements.FirstNode;
        while Assigned(Node) do begin
          Statement := Node^.Data;
          if ApplyClassFilter(Statement, fCurrentStatement, InheritanceStatements) or  //ClassFilter
            samestr(Statement^._FileName, Filename)  then  //Current File!  by Anbangli, 2026-01
            fFullCompletionStatementList.Add(Statement);
          Node := Node^.NextNode;
        end;
      end;
    end else begin
      // Get parent of current statement
      if Assigned(fCurrentStatement) then
        CurrentStatementParent := fCurrentStatement^._Parent
      else
        CurrentStatementParent := nil;

      // Find last operator
      Delete(Phrase, I, MaxInt);

      // Add statements of all the text before the last operator
      ParentStatement := fParser.FindStatementOf(Phrase, fCurrentStatement);
      if not Assigned(ParentStatement) then
        Exit;

      // Then determine which type it has (so we can use it as a parent)
      if ParentStatement^._Kind = skClass then // already found type
        ParentTypeStatement := ParentStatement
      else
        ParentTypeStatement := fParser.FindTypeDefinitionOf(ParentStatement^._Type, CurrentStatementParent);
      // TODO: should not be nil
      if not Assigned(ParentTypeStatement) then
        Exit;

      // Then add members of the ClassIDs and InheritanceIDs
      fParser.GetMultipleInheritanceStatements(ParentTypeStatement, InheritanceStatements);

      Node := fParser.Statements.FirstNode;
      while Assigned(Node) do begin
        Statement := Node^.Data;
        if ApplyMemberFilter(Statement, fCurrentStatement, ParentTypeStatement, InheritanceStatements) then
          fFullCompletionStatementList.Add(Statement);
        Node := Node^.NextNode;
      end;
    end;

  finally
    InheritanceStatements.Free;
  end;
end;

// Return 1 to show Item2 above Item1, otherwise -1

function ListSort(Item1, Item2: Pointer): Integer;
var
  Statement1, Statement2: PStatement;
begin
  Statement1 := PStatement(Item1);
  Statement2 := PStatement(Item2);

  // �ؼ������ȣ�skKeyword, skPreprocessor �����Ϸ���
  if (Statement1^._Kind = skKeyword) and (Statement2^._Kind <> skKeyword) then begin
    Result := -1;  // Statement1 �ؼ��ʣ�Statement2 �ǹؼ��� �� ������
  end else if (Statement1^._Kind <> skKeyword) and (Statement2^._Kind = skKeyword) then begin
    Result := 1;   // Statement1 �ǹؼ��ʣ�Statement2 �ؼ��� �� ����

  // ϵͳͷ�ļ����ȣ�ϵͳͷ�ļ��е�������ǰ�棩
  end else if (not Statement1^._InSystemHeader) and (Statement2^._InSystemHeader) then begin
    Result := 1;   // Statement1 ���أ�Statement2 ϵͳ �� ������ϵͳ��ǰ�棩
  end else if (Statement1^._InSystemHeader) and (not Statement2^._InSystemHeader) then begin
    Result := -1;  // Statement1 ϵͳ��Statement2 ���� �� ������

  // ȫ������������
  end else if (Statement1^._Scope in [ssGlobal]) and not (Statement2^._Scope in [ssGlobal]) then begin
    Result := -1;  // Statement1 ȫ�֣�Statement2 ��ȫ�� �� ��������ȫ����ǰ�棩
  end else if not (Statement1^._Scope in [ssGlobal]) and (Statement2^._Scope in [ssGlobal]) then begin
    Result := 1;   // Statement1 ��ȫ�֣�Statement2 ȫ�� �� ����

  // ����������ĸ������
  end else
    Result := CompareText(Statement1^._Command, Statement2^._Command);
end;

procedure TCodeCompletion.FilterList(const Member: AnsiString);
var
  I, J: integer;
  Statement1, Statement2: PStatement;
begin
  fCompletionStatementList.Clear;
  if Member <> '' then begin // filter, case insensitive
    fCompletionStatementList.Capacity := fFullCompletionStatementList.Count;
    for I := 0 to fFullCompletionStatementList.Count - 1 do
      if StartsText(Member, PStatement(fFullCompletionStatementList[I])^._Command) then begin
        fCompletionStatementList.Add(fFullCompletionStatementList[I]);
      end;
  end else
    fCompletionStatementList.Assign(fFullCompletionStatementList);

  // Bubble sort by priority: keywords first, then local headers, then global scope, then alphabetical
  for I := 0 to fCompletionStatementList.Count - 2 do
    for J := I + 1 to fCompletionStatementList.Count - 1 do begin
      Statement1 := PStatement(fCompletionStatementList[I]);
      Statement2 := PStatement(fCompletionStatementList[J]);
      if ListSort(Statement1, Statement2) > 0 then
        fCompletionStatementList.Exchange(I, J);
    end;
end;

procedure TCodeCompletion.Hide;
begin
  OnKeyPress := nil;
  CodeComplForm.Hide;

  // Clear data, do not free pointed memory: data is owned by CppParser
  fCompletionStatementList.Clear;
  fFullCompletionStatementList.Clear;
  CodeComplForm.lbCompletion.Items.BeginUpdate;
  CodeComplForm.lbCompletion.Items.Clear;
  CodeComplForm.lbCompletion.Items.EndUpdate;
  fIncludedFiles.Clear; // is recreated anyway on reshow, so save some memory when hiding
end;

procedure TCodeCompletion.Search(const target, Phrase, Filename: AnsiString);
var
  I: integer;
  Member: AnsiString;
begin
  if fEnabled then begin

    Screen.Cursor := crHourglass;

    // only perform full new search if just invoked
    if not CodeComplForm.Showing then begin
      fParser.GetFileIncludes(Filename, fIncludedFiles);
      GetCompletionFor(target, Phrase, Filename);
    end;

    // Sort here by member
    I := fParser.FindLastOperator(Phrase);
    while (I > 0) and (I <= Length(Phrase)) and (Phrase[i] in ['.', ':', '-', '>']) do
      Inc(I);

    // Member = the part of Phrase currently being typed (text after the last operator)
    Member := Copy(Phrase, I, MaxInt);

    // filter fFullCompletionStatementList to fCompletionStatementList
    FilterList(Member);

    // If only one candidate remains and it is exactly what the user has already
    // typed (case-sensitive: SameStr), there is nothing left to complete - hide
    // the box right away instead of making the user press a terminating key (space, etc.).
    if (Member <> '') and (fCompletionStatementList.Count = 1) and
      SameStr(PStatement(fCompletionStatementList[0])^._Command, Member) then begin
      Hide;
      Screen.Cursor := crDefault;
      Exit;
    end;

    if fCompletionStatementList.Count > 0 then begin
      CodeComplForm.lbCompletion.Items.BeginUpdate;
      try
        CodeComplForm.lbCompletion.Items.Clear;

        // Only slow one hundred statements...
        for I := 0 to min(fShowCount, fCompletionStatementList.Count - 1) do begin
          CodeComplForm.lbCompletion.Items.AddObject('', TObject(fCompletionStatementList[I]));
        end;
      finally
        CodeComplForm.lbCompletion.Items.EndUpdate;
      end;

      CodeComplForm.Font.Size := fFontSize;

      CodeComplForm.Show; //!!
      CodeComplForm.lbCompletion.SetFocus;
      if CodeComplForm.lbCompletion.Items.Count > 0 then
        CodeComplForm.lbCompletion.ItemIndex := 0;

      // 框已显示时 FormShow 不会再触发，这里显式按当前条目数重新调整尺寸，
      // 使提示框高度随候选词数量变化（输入更多字符、候选变少时收缩，不留空白）。
      CodeComplForm.UpdateSize;

      fHideDelay := 0;
    end else if fHideDelay = 0 then begin
      CodeComplForm.lbCompletion.Items.Clear;
      fHideDelay := 1;
    end else begin
      Hide;
    end;

    Screen.Cursor := crDefault;
  end;
end;

function TCodeCompletion.SelectedStatement: PStatement;
begin
  if fEnabled then begin
    if (fCompletionStatementList.Count > CodeComplForm.lbCompletion.ItemIndex) and (CodeComplForm.lbCompletion.ItemIndex
      <> -1) then
      Result := PStatement(fCompletionStatementList[CodeComplForm.lbCompletion.ItemIndex])
    else begin
      if fCompletionStatementList.Count > 0 then
        Result := PStatement(fCompletionStatementList[0])
      else
        Result := nil;
    end;
  end else
    Result := nil;
end;

procedure TCodeCompletion.SetPosition(Value: TPoint);
begin
  fPos := Value;
  if fPos.X + fWidth > Screen.Width then
    CodeComplForm.Left := fPos.X - fWidth
  else
    CodeComplForm.Left := fPos.X;
  if fPos.Y + fHeight > Screen.Height then
    CodeComplForm.Top := fPos.Y - fHeight - 16
  else
    CodeComplForm.Top := fPos.Y;

end;

procedure TCodeCompletion.OnFormResize(Sender: TObject);
begin
  if Enabled then begin
    fWidth := CodeComplForm.Width;
    fHeight := CodeComplForm.Height;
    if Assigned(fOnResize) then
      fOnResize(Self);
  end;
end;

function TCodeCompletion.IsIncluded(const FileName: AnsiString): boolean;
begin
  // Only do the slow check if the cache is invalid
  if not SameStr(FileName, fIsIncludedCacheFileName) then begin
    fIsIncludedCacheFileName := FileName;
    fIsIncludedCacheResult := FastIndexOf(fIncludedFiles, FileName) <> -1;
  end;

  // Cache has been updated. Use it.
  Result := fIsIncludedCacheResult;
end;

function TCodeCompletion.IsVisible: boolean;
begin
  Result := fEnabled and CodeComplForm.Visible;
end;

function TCodeCompletion.GetParser: TCppParser;
begin
  Result := fParser;
end;

function TCodeCompletion.GetColor: TColor;
begin
  Result := fColor;
end;

end.

