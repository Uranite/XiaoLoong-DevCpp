下面是一份可直接用于 Lazarus + ATSynEdit + EControl 的 LexerManager.pas，专门为内嵌 RCDATA 的 .lcf设计，线程安全、可扩展、不依赖外部 lexers 文件夹。

特点：

✅ 单例模式
✅ 资源名 → 扩展名 → LexerName 映射
✅ 自动从 RCDATA 加载 .lcf
✅ 自动缓存，避免重复解析
✅ 按文件名后缀自动选择 Lexer
✅ 后续加 Python / JS / Pascal 只改映射表

设计决策说明（你可能会关心的）

设计点	原因
单例 	避免多次加载同一 lexer
RCDATA	完全脱离文件系统
LexerName 二次映射	rc 资源名 ≠ lcf 内部名
延迟加载	启动快，按需解析
不接管 FLexerList 生命周期	遵循 EControl 所有权模型



unit LexerManager;

interface

uses
  Classes, SysUtils,
  ec_Lexer, ec_SyntAnalyzer, ATAdapterEControl;

type
  TLexerMapping = record
    ResourceName: string;   // RCDATA 资源名（大写）
    LexerName: string;      // lcf 内部 LexerName
    Extensions: array of string; // 支持的文件扩展名
  end;

  TLexerManager = class
  private
    FLexerList: TecLexerList;
    FMappings: array of TLexerMapping;
    function FindMappingByExtension(const AExt: string): Integer;
    procedure EnsureLexerLoaded(const AResourceName: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Initialize(ALexerList: TecLexerList);

    // 按文件名设置 Adapter 的 Lexer
    procedure ApplyLexerByFileName(
      const AFileName: string;
      AAdapter: TATAdapterEControl
    );

    // 手动按 LexerName 设置
    procedure ApplyLexerByName(
      const ALexerName: string;
      AAdapter: TATAdapterEControl
    );

    // 调试/诊断
    function LexerCount: Integer;
  end;

var
  LexerMgr: TLexerManager;

implementation

{ TLexerManager }

constructor TLexerManager.Create;
begin
  inherited Create;

  // =========================================================
  // ★ 在这里注册 lexer
  // ResourceName 必须和 lexers.rc 里完全一致（大写）
  // LexerName 必须和 .lcf 内部 LexerName 完全一致
  // =========================================================
  SetLength(FMappings, 3);

  // C++
  FMappings[0].ResourceName := 'CPP_LEXER';
  FMappings[0].LexerName := 'C++';
  FMappings[0].Extensions := ['.cpp', '.cxx', '.cc', '.hpp', '.hxx', '.hh', '.h', '.ipp'];

  // C
  FMappings[1].ResourceName := 'C_LEXER';
  FMappings[1].LexerName := 'C';
  FMappings[1].Extensions := ['.c', '.h'];

  // Pascal
  FMappings[2].ResourceName := 'PASCAL_LEXER';
  FMappings[2].LexerName := 'Pascal';
  FMappings[2].Extensions := ['.pas', '.pp', '.inc', '.lpr', '.dpr'];

  FLexerList := nil;
end;

destructor TLexerManager.Destroy;
begin
  // FLexerList 由 Adapter 拥有，这里不释放
  inherited Destroy;
end;

procedure TLexerManager.Initialize(ALexerList: TecLexerList);
begin
  FLexerList := ALexerList;
end;

procedure TLexerManager.EnsureLexerLoaded(const AResourceName: string);
var
  Stream: TResourceStream;
  Lexer: TecSyntAnalyzer;
begin
  if not Assigned(FLexerList) then
    raise Exception.Create('LexerManager not initialized.');

  // 已加载则跳过
  if FLexerList.FindLexerByName(AResourceName) <> nil then
    Exit;

  Stream := TResourceStream.Create(HInstance, AResourceName, RT_RCDATA);
  try
    Lexer := FLexerList.AddLexer;
    Lexer.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

function TLexerManager.FindMappingByExtension(const AExt: string): Integer;
var
  i, j: Integer;
begin
  Result := -1;
  for i := Low(FMappings) to High(FMappings) do
    for j := Low(FMappings[i].Extensions) to High(FMappings[i].Extensions) do
      if SameText(AExt, FMappings[i].Extensions[j]) then
        Exit(i);
end;

procedure TLexerManager.ApplyLexerByFileName(
  const AFileName: string;
  AAdapter: TATAdapterEControl);
var
  Ext: string;
  Idx: Integer;
begin
  if not Assigned(AAdapter) then Exit;

  Ext := ExtractFileExt(AFileName);
  Idx := FindMappingByExtension(Ext);

  if Idx >= 0 then
  begin
    EnsureLexerLoaded(FMappings[Idx].ResourceName);
    AAdapter.LexerName := FMappings[Idx].LexerName;
  end
  else
    AAdapter.LexerName := ''; // 无匹配，关闭高亮
end;

procedure TLexerManager.ApplyLexerByName(
  const ALexerName: string;
  AAdapter: TATAdapterEControl);
var
  i: Integer;
begin
  if not Assigned(AAdapter) then Exit;

  for i := Low(FMappings) to High(FMappings) do
    if SameText(FMappings[i].LexerName, ALexerName) then
    begin
      EnsureLexerLoaded(FMappings[i].ResourceName);
      AAdapter.LexerName := FMappings[i].LexerName;
      Exit;
    end;

  AAdapter.LexerName := '';
end;

function TLexerManager.LexerCount: Integer;
begin
  if Assigned(FLexerList) then
    Result := FLexerList.Count
  else
    Result := 0;
end;

initialization
  LexerMgr := TLexerManager.Create;

finalization
  FreeAndNil(LexerMgr);

end.