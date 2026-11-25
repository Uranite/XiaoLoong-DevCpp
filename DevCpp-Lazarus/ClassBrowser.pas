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

unit ClassBrowser;

interface

uses
  Classes, SysUtils, Controls, ComCtrls, Graphics, Forms,
  StatementList, CppParser, cbutils;

type

  TMemberKind = (
    mkClass,       // ��
    mkStruct,      // �ṹ��
    mkFunction,    // ����/����
    mkVariable,    // ����/�ֶ�
    mkEnum,        // ö��
    mkTypedef,     // ���Ͷ���
    mkMacro,       // ��
    mkNamespace,   // �����ռ�
    mkInherited    // �̳г�Ա
  );

  TImagesRecord = (
    GlobalsImg,
    ClassesImg,
    VariablePrivateImg,
    VariableProtectedImg,
    VariablePublicImg,
    MethodPrivateImg,
    MethodProtectedImg,
    MethodPublicImg,
    InheritedMethodProtectedImg,
    InheritedMethodPublicImg,
    InheritedVariableProtectedImg,
    InheritedVariablePublicImg
  );

{  TImagesRecord = class(TPersistent)
  private
    fGlobalsImg: integer;
    fClassesImg: integer;
    fVariablePrivateImg: integer;
    fVariableProtectedImg: integer;
    fVariablePublicImg: integer;
    fMethodPrivateImg: integer;
    fMethodProtectedImg: integer;
    fMethodPublicImg: integer;
    fInhMethodProtectedImg: integer;
    fInhMethodPublicImg: integer;
    fInhVariableProtectedImg: integer;
    fInhVariablePublicImg: integer;
  published
    property Globals: integer read fGlobalsImg write fGlobalsImg;
    property Classes: integer read fClassesImg write fClassesImg;
    property VariablePrivate: integer read fVariablePrivateImg write fVariablePrivateImg;
    property VariableProtected: integer read fVariableProtectedImg write fVariableProtectedImg;
    property VariablePublic: integer read fVariablePublicImg write fVariablePublicImg;
    property MethodPrivate: integer read fMethodPrivateImg write fMethodPrivateImg;
    property MethodProtected: integer read fMethodProtectedImg write fMethodProtectedImg;
    property MethodPublic: integer read fMethodPublicImg write fMethodPublicImg;
    property InheritedMethodProtected: integer read fInhMethodProtectedImg write fInhMethodProtectedImg;
    property InheritedMethodPublic: integer read fInhMethodPublicImg write fInhMethodPublicImg;
    property InheritedVariableProtected: integer read fInhVariableProtectedImg write fInhVariableProtectedImg;
    property InheritedVariablePublic: integer read fInhVariablePublicImg write fInhVariablePublicImg;
  end;
}

  TClassMember = class(TObject)  //Data imported from TStatement
  private
    //_Parent: PStatement;
    //_HintText: AnsiString;
    fTypeType: string; //����  _Type
    fName: string;     // ��Ա����  _Command
    fArgs: string;     //����  _Args
    fKind: TMemberKind;     // ��Ա����  //_Kind
    //_InheritanceList: TList;
    //fScope: TStatementScope;  //_Scope; // global/local/classlocal
    fClassScope: TStatementClassScope; // �������η� _ClassScope; // protected/private/public
    //_HasDefinition: boolean; // definiton line/filename is valid
    fLine: Integer;         //_Line ���������к�
    fDefinitionLine: Integer; //_DefinitionLine ���������к�
    fFileName: string;      // _FileName ��������Դ�ļ���
    fDefinitionFileName: string;      //_DefinitionFileName ��������Դ�ļ���
    //_Visible: boolean;
    //_Temporary: boolean; // statements to be deleted after parsing
    //_InProject: boolean; // statement in project
    //_InSystemHeader: boolean; // statement in system header (#include <>)
    fChildren: TList;       // �ӳ�Ա�б�
    fIsInherited: Boolean;  // �Ƿ�Ϊ�̳г�Ա

//    fImageIndex: TImagesRecord; //��ͼʱ��ͼ��������  //
  public
//    constructor Create(const AType: string; const AName: string; const AArgs: string; AKind: TMemberKind;
//      const AFileName: string; ALine: Integer; const DefFileName: string; DefLine: Integer);
    constructor Create(const PState: PStatement);
    destructor Destroy; override;

    procedure AddChild(Child: TClassMember);
    function GetChildCount: Integer;
    function GetChild(Index: Integer): TClassMember;
    function MemberKindStr(Value: TMemberKind): string;

    property TypeType: string read fTypeType; //type
    property Name: string read fName;
    property Args: string read fArgs;
    property Kind: TMemberKind read fKind;
    property FileName: string read fFileName;
    property Line: Integer read fLine;
    property DefinitionFileName: string read fDefinitionFileName;
    property DefinitionLine: Integer read fDefinitionLine;

    property Children: TList read fChildren;
    property IsInherited: Boolean read fIsInherited write fIsInherited;
    property ClassScope: TStatementClassScope read fClassScope write fClassScope;
  end;

//  TMemberSelectEvent = procedure(Sender: TObject; Filename: TFilename; Line: integer) of object;
  TDataChangedEvent = procedure of object;

  TShowFilter = (sfAll, sfProject, sfCurrent, sfSystemFiles);

  TClassBrowser = class(TPersistent) //(TCustomTreeView)
  private
    fParser: TCppParser;
    //fOnSelect: TMemberSelectEvent;
    fImagesRecord: TImagesRecord;
    fRootItems: TList; //
    fOnDataChanged: TDataChangedEvent; //

    fShowFilter: TShowFilter;
    fCurrentFile: AnsiString;
    fProjectDir: AnsiString;
    //fControlCanvas: TControlCanvas;
    fShowInheritedMembers: boolean;
    fIncludedFiles: TStringList;
    fIsIncludedCacheFileName: AnsiString;
    fIsIncludedCacheResult: boolean;
    fUpdateCount: integer;
    fTabVisible: boolean;
    //fLastSelection: AnsiString;

    //procedure AddMembers(Node: TTreeNode; ParentStatementNode: PStatementNode);
//    procedure AdvancedCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
//      State: TCustomDrawState; Stage: TCustomDrawStage; var PaintImages,
//      DefaultDraw: Boolean);
//    procedure OnNodeChange(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
//    procedure OnNodeChanging(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ClearRootItems;  //
    procedure OnParserUpdate(Sender: TObject);
    procedure OnParserBusy(Sender: TObject);
    //procedure UpdateFromParser(Parser: TCppParser); //

    //property ImagesRecord: TImagesRecord read fImagesRecord write fImagesRecord;

//    procedure SetNodeImages(Node: TTreeNode; Statement: PStatement);
//    procedure Sort;
    procedure SetCurrentFile(const Value: AnsiString);
    procedure SetShowFilter(Value: TShowFilter);
    procedure SetShowInheritedMembers(Value: boolean);
    procedure SetTabVisible(Value: boolean);
    function IsIncluded(const FileName: AnsiString): boolean;
//    procedure ReSelect;
    function ConvertParserKind(ParserKind: TStatementKind): TMemberKind; //
    procedure NotifyDataChanged;  //
  public
    property ImagesRecord: TImagesRecord read fImagesRecord write fImagesRecord;
    //constructor Create(AOwner: TComponent); override;
    constructor Create;
    destructor Destroy; override;
    procedure SetParser(Value: TCppParser);
    function GetRootCount: Integer;
    function GetRootItem(Index: Integer): TClassMember;
//    procedure HandleNodeSelection(Statement: PStatement);
    procedure UpdateFromParser(Parser: TCppParser); //
    property OnDataChanged: TDataChangedEvent read fOnDataChanged write fOnDataChanged;
//    procedure UpdateView;
//    procedure Clear;
    procedure BeginUpdate;
    procedure EndUpdate;

  published
//    property Align;
//    property Font;
//    property Color;
//    property Images;
//    property ReadOnly;
//    property Indent;
//    property TabOrder;
//    property PopupMenu;
//    property BorderStyle;
//    property MultiSelect;
//    property MultiSelectStyle;
    property ShowFilter: TShowFilter read fShowFilter write SetShowFilter;
//    property OnSelect: TMemberSelectEvent read fOnSelect write fOnSelect;
    property Parser: TCppParser read fParser write SetParser;
    //property ItemImages: TImagesRecord read fImagesRecord write fImagesRecord;
    property CurrentFile: AnsiString read fCurrentFile write SetCurrentFile;
    property ProjectDir: AnsiString read fProjectDir write fProjectDir;
    property ShowInheritedMembers: boolean read fShowInheritedMembers write SetShowInheritedMembers;
    property TabVisible: boolean read fTabVisible write SetTabVisible;
  end;

//const
//  CLASS_FOLDERS_MAGIC = 'DEVCF_1_0';

//procedure Register;

implementation

//procedure Register;
//begin
//  RegisterComponents('Dev-C++', [TClassBrowser]);
//end;

{TClassMember }
{
constructor TClassMember.Create(const AType: string;
                                const AName: string;
                                const AArgs: string;
                                AKind: TMemberKind;
                                const AFileName: string;
                                ALine: Integer;
                                const DefFileName: string;
                                DefLine: Integer);
begin
  inherited Create;
  fTypeType := AType;
  fName := AName;
  fArgs := AArgs;
  fKind := AKind;
  fFileName := AFileName;
  fLine := ALine;
  fDefinitionFileName := DefFileName;
  fDefinitionLine := DefLine;
  fChildren := TList.Create;
  fIsInherited := False;
  fClassScope := 0; // Ĭ��public
end;
}

constructor TClassMember.Create(const PState: PStatement);
begin
  inherited Create;
  fTypeType := PState^._Type;
  fName := PState^._Command;
  fArgs := PState^._Args;
  //fKind := ConvertParserKind(PState^._Kind);
  case PState^._Kind of
    skClass: fKind := mkClass;
    skStruct: fKind := mkStruct;
    skFunction, skConstructor, skDestructor: fKind := mkFunction;
    skVariable: fKind := mkVariable;
    skEnum: fKind := mkEnum;
    skTypedef: fKind := mkTypedef;
    skPreprocessor: fKind := mkMacro;
    skNamespace: fKind := mkNamespace;
  else
    fKind := mkVariable; // Ĭ�ϴ���
  end;

  fClassScope := PState^._ClassScope;
  fLine := PState^._Line;
  fDefinitionLine := PState^._DefinitionLine;
  fFileName := PState^._FileName;
  fDefinitionFileName := PState^._DefinitionFileName;

  fChildren := TList.Create;
  fIsInherited := False;
end;

destructor TClassMember.Destroy;
var
  I: Integer;
begin
  for I := 0 to fChildren.Count - 1 do
    TObject(fChildren[I]).Free;
  fChildren.Free;
  inherited Destroy;
end;

procedure TClassMember.AddChild(Child: TClassMember);
begin
  fChildren.Add(Child);
end;

function TClassMember.GetChildCount: Integer;
begin
  Result := fChildren.Count;
end;

function TClassMember.GetChild(Index: Integer): TClassMember;
begin
  Result := TClassMember(fChildren[Index]);
end;

function TClassMember.MemberKindStr(Value: TMemberKind): string;
begin
  Result := '';
  case Value of
    mkClass: Result := 'class';       // ��
    mkStruct: Result := 'struct';      // �ṹ��
    mkFunction: Result := 'function';    // ����/����
    mkVariable: Result := 'variable';    // ����/�ֶ�
    mkEnum: Result := 'enum';        // ö��
    mkTypedef: Result := 'typedef';     // ���Ͷ���
    mkMacro: Result := 'macro';       // ��
    mkNamespace: Result := 'namespace';   // �����ռ�
    mkInherited: Result := 'inherited';    // �̳г�Ա
{   //StatementKindStr
    skPreprocessor: Result := 'preprocessor';
    skVariable: Result := 'variable';
    skConstructor: Result := 'constructor';
    skDestructor: Result := 'destructor';
    skFunction: Result := 'function';
    skClass: Result := 'class';
    skTypedef: Result := 'typedef';
    skEnum: Result := 'enum';
    skUnknown: Result := 'unknown';
 }
  end;
end;


{ TClassBrowser }

//constructor TClassBrowser.Create(AOwner: TComponent);
constructor TClassBrowser.Create;
begin
  inherited Create;
  fRootItems := TList.Create; //
//  OnMouseUp := OnNodeChange;
//  OnMouseDown := OnNodeChanging;
//  DragMode := dmAutomatic;
  fImagesRecord := GlobalsImg;  //TImagesRecord.Create;
  fCurrentFile := '';
  fShowFilter := sfCurrent;
  fProjectDir := '';
//  ShowHint := True;
//  HideSelection := False;
//  RightClickSelect := True;
  fShowInheritedMembers := False;
//  fControlCanvas := TControlCanvas.Create;
//  fControlCanvas.Control := Self;
//  fControlCanvas.Font.Assign(Self.Font);
//  OnAdvancedCustomDrawItem := AdvancedCustomDrawItem;
  fIncludedFiles := TStringList.Create;
  fIsIncludedCacheFileName := '';
  fIsIncludedCacheResult := false;
  fUpdateCount := 0;
  fTabVisible := true;
end;

destructor TClassBrowser.Destroy;
begin
  ClearRootItems;
  fRootItems.Free;
  FreeAndNil(fImagesRecord);
//  FreeAndNil(fControlCanvas);
  fIncludedFiles.Free;
  inherited Destroy;
end;

procedure TClassBrowser.ClearRootItems;
var
  I: Integer;
begin
  // �ͷ�����TClassMember����
  for I := 0 to fRootItems.Count - 1 do
    TClassMember(fRootItems[I]).Free;

  // ����б�
  fRootItems.Clear;
end;

procedure TClassBrowser.NotifyDataChanged;
begin
  if Assigned(fOnDataChanged) then
    fOnDataChanged;
end;


procedure TClassBrowser.BeginUpdate;
begin
  Inc(fUpdateCount);
end;

procedure TClassBrowser.EndUpdate;
begin
  Dec(fUpdateCount);
  if fUpdateCount = 0 then
    UpdateFromParser(fParser);   //UpdateView;
end;

function TClassBrowser.GetRootCount: Integer;  //
begin
  //  Result := fRootItems.Count;
  if Assigned(fParser) and Assigned(fParser.Statements) then
    Result := fRootItems.Count //Result := fParser.Statements.Count
  else
    Result := 0;
end;

function TClassBrowser.GetRootItem(Index: Integer): TClassMember; //
begin
  Result := TClassMember(fRootItems[Index]);
end;

//procedure TClassBrowser.HandleNodeSelection(Statement: PStatement);   //
//begin
  // �����ڵ�ѡ���¼�������ת������
//  if Assigned(Statement) then
//    JumpToCode(Statement^.FileName, Statement^.Line);
//end;

{
procedure TClassBrowser.AddMembers(Node: TTreeNode; ParentStatementNode: PStatementNode);
var
  CurStatementNode, StatementNode, StartNode: PStatementNode;
  Statement, ParentStatement: PStatement;
  NewNode: TTreeNode;
  bInherited: boolean;
  InheritanceStatements: TList;

  procedure AddStatementNode(StatementNode: PStatementNode);
  begin
    with StatementNode.Data^ do begin
      NewNode := Items.AddChildObject(Node, _Command, Statement);
      SetNodeImages(NewNode, Statement);
      if _Kind = skClass then
        AddMembers(NewNode, StatementNode);
    end;
  end;
begin
  if (not fShowInheritedMembers) and Assigned(ParentStatementNode) then
    StartNode := ParentStatementNode.NextNode // only check for members AFTER the parent statement
  else
    StartNode := fParser.Statements.FirstNode; // if showing inheritance, a big speed penalty

  // create folders that have this branch as parent
  if ParentStatementNode <> nil then
    ParentStatement := ParentStatementNode.Data
  else
    ParentStatement := nil;

  InheritanceStatements := TList.Create;
  try
    // allow inheritance propagation, including MI
    if fShowInheritedMembers and (ParentStatement <> nil) and (ParentStatement^._Kind = skClass) then
      fParser.GetMultipleInheritanceStatements(ParentStatement, InheritanceStatements);

    // Walk all the statements
    bInherited := False;
    StatementNode := StartNode;
    while Assigned(StatementNode) do begin
      Statement := StatementNode^.Data;
      CurStatementNode := StatementNode; // remember current node
      StatementNode := StatementNode^.NextNode; // step to next node up here BEFORE calls to continue
      with Statement^ do begin
        // Do not print statements marked invisible for the class browser
        if not _Visible or _Temporary then
          Continue;

        // Prevent infinite parent/child loops
        if Statement = ParentStatement then
          Continue;

        // Stop the current recurse when we run out of children
        if _Parent <> ParentStatement then begin
          bInherited := fShowInheritedMembers and (InheritanceStatements.IndexOf(_Parent) <> -1);
          if not bInherited then
            Continue;
        end;

        // Only do inheritance checking when absolutely needed
        case fShowFilter of
          sfAll: begin // sfAll means all open files. not the system headers
              if not _InSystemHeader then // do not show system headers
                AddStatementNode(CurStatementNode);
            end;
          sfSystemFiles: begin
              if _InSystemHeader and IsIncluded(_FileName) then
                AddStatementNode(CurStatementNode); // only show system header stuff
            end;
          sfCurrent: begin
              if not _InSystemHeader and IsIncluded(_FileName) then
                AddStatementNode(CurStatementNode);
            end;
          sfProject: begin
              if _InProject or bInherited then
                AddStatementNode(CurStatementNode);
            end;
        end;
      end;
    end;
  finally
    InheritanceStatements.Free;
  end;
end;
}

function TClassBrowser.ConvertParserKind(ParserKind: TStatementKind): TMemberKind;
begin
  case ParserKind of
    skClass: Result := mkClass;
    skStruct: Result := mkStruct;
    skFunction, skConstructor, skDestructor: Result := mkFunction;
    skVariable: Result := mkVariable;
    skEnum: Result := mkEnum;
    skTypedef: Result := mkTypedef;
    skPreprocessor: Result := mkMacro;
    skNamespace: Result := mkNamespace;
  else
    Result := mkVariable; // Ĭ�ϴ���
  end;
end;


//TClassBrowser.UpdateFromParser �� Dev-C++ IDE ��������� (TClassBrowser) �ĺ��ķ�����
//���𽫵ײ������ (TCppParser) ���ɵ�ԭʼ��������ת��Ϊ���νṹ���Ա����û�������չʾ����Ĳ�λ��ṹ���������ռ䡢�ࡢ��Ա�ȣ���
procedure TClassBrowser.UpdateFromParser(Parser: TCppParser);    //
var
  ParserNode: PStatementNode;
  CurrentMember: TClassMember;
  //Member: TClassMember;
  MemberList: TList;  // ���ڴ���Ƕ��������
  idx: integer;

  //bInherited: boolean;
  ShouldAdd: Boolean;

  // �ݹ鴦���̳й�ϵ
  procedure ProcessInheritance(ParentMember: TClassMember; InheritanceList: TList);
  var
    I: Integer;
    InheritedStmt: PStatement;
    InheritedMember: TClassMember;
  begin
    if not Assigned(InheritanceList) then Exit;

    for I := 0 to InheritanceList.Count - 1 do
    begin
      InheritedStmt := PStatement(InheritanceList[I]);
      if not Assigned(InheritedStmt) then Continue;

      InheritedMember := TClassMember.Create(InheritedStmt);
{      InheritedMember := TClassMember.Create(
        InheritedStmt^._Type,
        InheritedStmt^._Command,
        InheritedStmt^._Args,
        ConvertParserKind(InheritedStmt^._Kind),
        InheritedStmt^._FileName,
        InheritedStmt^._Line,
        InheritedStmt^._DefinitionFileName,
        InheritedStmt^._DefinitionLine
      );
 }
      InheritedMember.IsInherited := True;

      ParentMember.AddChild(InheritedMember);

      // �ݹ鴦���̳���
      ProcessInheritance(InheritedMember, InheritedStmt^._InheritanceList);
    end;
  end;

begin
  if not Assigned(fParser) then Exit;

  if fCurrentFile <> '' then begin
      // Update file includes, reset cache
      //�ҳ� fCurrentFile ��������ȫ���ļ�������� fIncludedFiles �б��С�
      fParser.GetFileIncludes(fCurrentFile, fIncludedFiles);
      fIsIncludedCacheFileName := '';
      fIsIncludedCacheResult := false;
  end;

  // �����������
  ClearRootItems;
  MemberList := TList.Create;
  //bInherited := False;
  try
    // ������������ Statements �б��е�����[���]
    ParserNode := fParser.Statements.FirstNode;

    while Assigned(ParserNode) do
    begin
      ShouldAdd := False;
      case fShowFilter of
        sfAll:     ShouldAdd := (not ParserNode^.Data^._InSystemHeader);  // ��ʾ���нڵ�
        sfSystemFiles: ShouldAdd := (ParserNode^.Data^._InSystemHeader and IsIncluded(ParserNode^.Data^._FileName));
        sfCurrent:  ShouldAdd := (not ParserNode^.Data^._InSystemHeader) and
          (ParserNode^.Data^._FileName = fCurrentFile);
        sfProject: ShouldAdd := (ParserNode^.Data^._InProject);// or ParserNode^.Data.bInherited);

      end;
      if not ShouldAdd then
      begin
        ParserNode := ParserNode^.NextNode;
        Continue;
      end;

      // ������Ӧ����������ڵ㲢���ó�Ա
      CurrentMember := TClassMember.Create(ParserNode^.Data);
{      CurrentMember := TClassMember.Create(
        ParserNode^.Data^._Type,
        ParserNode^.Data^._Command,
        ParserNode^.Data^._Args,
        ConvertParserKind(ParserNode^.Data^._Kind),
        ParserNode^.Data^._FileName,
        ParserNode^.Data^._Line,
        ParserNode^.Data^._DefinitionFileName,
        ParserNode^.Data^._DefinitionLine
      );
      //CurrentMember.IsInherited := False;  //Default value is False
 }
      // ���ó�Ա����
      //CurrentMember.ClassScope := Ord(ParserNode^.Data^._ClassScope);

      // ����������Ƕ��
      if not Assigned(ParserNode^.Data^._Parent) then begin
        fRootItems.Add(CurrentMember);  //�����������ӵ����б�
        MemberList.Add(CurrentMember);  //���ӵ����Ա���
      end
      else if (MemberList.Count> 0) then begin
        for idx := MemberList.Count - 1 downto 0 do begin //���Բ��Ҹ��ڵ�
          if (TClassMember(MemberList.items[idx]).Name = ParserNode^.Data^._Parent^._Command) then
            break
        end;
        if idx > -1 then begin //�ҵ����ڵ�ʱ����Ϊ�ӽڵ�
          TClassMember(MemberList.items[idx]).AddChild(CurrentMember);
        end
        else begin  //δ�ҵ����ڵ�ʱ����Ϊ���ڵ�
          fRootItems.Add(CurrentMember);
          MemberList.Add(CurrentMember);
        end;
      end;
       // �����̳й�ϵ
      ProcessInheritance(CurrentMember, ParserNode^.Data^._InheritanceList);

      ParserNode := ParserNode^.NextNode;
    end;
  finally
     MemberList.Free;
  end;

  // ֪ͨ���ݸ���
  NotifyDataChanged;
end;


{
procedure TClassBrowser.UpdateView;
begin
  if not Assigned(fParser) then
    Exit;
  if fUpdateCount <> 0 then
    Exit;
  if not Visible or not TabVisible then
    Exit;

  // We are busy...
  Items.BeginUpdate;
  try
    Clear;
    if fCurrentFile <> '' then begin
      // Update file includes, reset cache
      fParser.GetFileIncludes(fCurrentFile, fIncludedFiles);
      fIsIncludedCacheFileName := '';
      fIsIncludedCacheResult := false;

      // Add everything recursively
      AddMembers(nil, nil);
      Sort;

      // Remember selection
      if fLastSelection <> '' then
        ReSelect;
    end;
  finally
    Items.EndUpdate; // calls repaint when needed
  end;
end;


procedure TClassBrowser.OnNodeChanging(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
begin
  if htOnItem in GetHitTestInfoAt(X, Y) then
    Node := GetNodeAt(X, Y)
  else
    Node := nil;
  Selected := Node;
end;

procedure TClassBrowser.OnNodeChange(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
begin
  inherited;

  // Check if we hit the node
  if htOnItem in GetHitTestInfoAt(X, Y) then
    Node := GetNodeAt(X, Y)
  else
    Node := nil;

  // Dit we click on anything?
  if not Assigned(Node) then begin
    fLastSelection := '';
    Exit;
  end else if not Assigned(Node.Data) then begin
    fLastSelection := '';
    Exit;
  end;

  // Send to listener
  with PStatement(Node.Data)^ do begin
    fLastSelection := _Type + ':' + _Command + ':' + _Args;
    if Assigned(fOnSelect) then
      if Button = mbLeft then // need definition
        fOnSelect(Self, _DefinitionFileName, _DefinitionLine)
      else if Button = mbMiddle then // need declaration
        fOnSelect(Self, _FileName, _Line);
  end;
end;
}

procedure TClassBrowser.OnParserBusy(Sender: TObject);
begin
  BeginUpdate;
end;

procedure TClassBrowser.OnParserUpdate(Sender: TObject);
begin
  EndUpdate;
end;

{
function CustomSortProc(Node1, Node2: TTreeNode; Data: Integer): Integer; stdcall;
begin
  if (Node1.ImageIndex = 0) or (Node2.ImageIndex = 0) then
    Result := Node1.ImageIndex - Node2.ImageIndex
  else
    Result := Ord(PStatement(Node1.Data)^._Kind) - Ord(PStatement(Node2.Data)^._Kind);
  if Result = 0 then
    //Result := StrIComp(PAnsiChar(Node1.Text), PAnsiChar(Node2.Text));
    //StrIComp: �Ƚ������ַ����������ִ�Сд������������ PAnsiChar ���͡�
    //���� Unicode �ַ�����string ���ͣ���Ӧʹ�� AnsiCompareStr �� CompareString API��
    Result := AnsiCompareText(PAnsiChar(Node1.Text), PAnsiChar(Node2.Text));
end;

procedure TClassBrowser.Sort;
begin
   CustomSort(@CustomSortProc, 0);
end;

procedure TClassBrowser.Clear;
begin
  Items.Clear;
end;
}

procedure TClassBrowser.SetParser(Value: TCppParser);
begin
  if Value = fParser then
    Exit;

  fParser := Value;
  if Assigned(fParser) then begin
    fParser.OnUpdate := @OnParserUpdate;
    fParser.OnBusy := @OnParserBusy;
  end;
  UpdateFromParser(fParser); //UpdateView;
end;

procedure TClassBrowser.SetCurrentFile(const Value: AnsiString);
begin
  if Value = fCurrentFile then
    Exit;
  fCurrentFile := Value;
  if fShowFilter = sfAll then // content does not depend on current file. do NOT redraw
    Exit;
  UpdateFromParser(fParser); //UpdateView;
end;


procedure TClassBrowser.SetShowFilter(Value: TShowFilter);
begin
  if fShowFilter = Value then
    Exit;
  fShowFilter := Value;
  UpdateFromParser(fParser);
end;

procedure TClassBrowser.SetShowInheritedMembers(Value: boolean);
begin
  if Value = fShowInheritedMembers then
    Exit;
  fShowInheritedMembers := Value;
  UpdateFromParser(fParser);
end;

procedure TClassBrowser.SetTabVisible(Value: boolean);
begin
  if Value = fTabVisible then
    Exit;
  fTabVisible := Value;
  UpdateFromParser(fParser);
end;

{
procedure TClassBrowser.AdvancedCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
  State: TCustomDrawState; Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
var
  DrawRect: TRect;
  DrawPoint: TPoint;
  st: PStatement;
  bInherited: boolean;
  TypeText: AnsiString;
begin
  // Assume the node image is correct
  bInherited := fShowInheritedMembers and (Node.ImageIndex in [
    fImagesRecord.fInhMethodProtectedImg,
    fImagesRecord.fInhMethodPublicImg,
    fImagesRecord.fInhVariableProtectedImg,
    fImagesRecord.fInhVariablePublicImg]);

  if Stage = cdPrePaint then begin  //before draw the node's main text
    Sender.Canvas.Font.Color := Font.Color; // clWindowText;   //ABLI added
    Sender.Canvas.Font.Style := [fsBold];
    if bInherited then
      Sender.Canvas.Font.Color := clGrayText;  //clGray; //ABLI modi
    //the node's main text is drawn by TCustomTreeView
  end else if Stage = cdPostPaint then begin //draw the node's other text
    try
      st := Node.Data;
      if not Assigned(st) then
        Exit;

      // Start drawing at top right corner of DisplayRect
      DrawRect := Node.DisplayRect(true);
      DrawPoint := Point(DrawRect.Right, DrawRect.Top);

      // Draw function arguments to the right of the already drawn text
      if st^._Args <> '' then begin
        fControlCanvas.Brush.Color := Color;
        fControlCanvas.Font.size := Font.size - 2;
        if (Font.Size >= 9) and (fControlCanvas.Font.Size < 9) then
           fControlCanvas.Font.Size := 9;

        if bInherited then
          fControlCanvas.Font.Color := Font.Color //clGrayText //ABLI
        else
          fControlCanvas.Font.Color := Font.Color; //clGrayText;
        Inc(DrawPoint.X, 4);
        fControlCanvas.TextOut(DrawPoint.X, DrawPoint.Y + 2, st^._Args); // center vertically     //TODO. something may be wrong here
        Inc(DrawPoint.X, fControlCanvas.TextWidth(st^._Args) + 2); // add some right padding
      end;

      if st^._Type <> '' then
        TypeText := st^._Type
      else
        TypeText := fParser.StatementKindStr(st^._Kind);

      // Then draw node type to the right of the arguments
      if TypeText <> '' then begin
        fControlCanvas.Font.Color := Font.Color;  //clGrayText; //ABLI
        fControlCanvas.TextOut(DrawPoint.X, DrawPoint.Y + 2, ': ' + TypeText); // center vertically
      end;
      DrawRect := Node.DisplayRect(true); ////
    except // stick head into sand method. sometimes during painting, the PStatement is invalid
           // this is caused by repainting while the CppParser is busy.
    end;
  end;
end;
}

function TClassBrowser.IsIncluded(const FileName: AnsiString): boolean;
begin
  // Only do the slow check if the cache is invalid
  if not SameStr(FileName, fIsIncludedCacheFileName) then begin
    fIsIncludedCacheFileName := FileName;
    fIsIncludedCacheResult := FastIndexOf(fIncludedFiles, FileName) <> -1;
  end;

  // Cache has been updated. Use it.
  Result := fIsIncludedCacheResult;
end;

{
procedure TClassBrowser.ReSelect;
var
  I: Integer;
  Statement: PStatement;
begin
  for I := 0 to Items.Count - 1 do begin
    Statement := PStatement(Items[I].Data);
    with Statement^ do
      if (_Type + ':' + _Command + ':' + _Args) = fLastSelection then begin
        Selected := Items[I];
        Break;
      end;
  end;
end;
}
end.


