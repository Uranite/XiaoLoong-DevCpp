unit Unit1;

{$mode delphi}{$H+}

interface

uses
  FGL,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  Math,
  Diff,
  ExtCtrls,
  Grids,
  Menus,
  ComCtrls, ActnList, ImgList;

type
  TIntegerList = TFPGList<Cardinal>;

  { TForm1 }

  TForm1 = class(TForm)
    actIgnoreCase: TAction;
    actIgnoreSpace: TAction;
    actSave2: TAction;
    actNextDiff: TAction;
    actPrevDiff: TAction;
    actSave1: TAction;
    actCompare: TAction;
    Edit1: TEdit;
    Edit2: TEdit;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open11: TMenuItem;
    Open21: TMenuItem;
    N1: TMenuItem;
    mnuCompare: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    OpenDialog1: TOpenDialog;
    mnuCancel: TMenuItem;
    Panel2: TPanel;
    Panel3: TPanel;
    ResultGrid: TStringGrid;
    StatusBar1: TStatusBar;
    Options1: TMenuItem;
    mnuIgnoreCase: TMenuItem;
    mnuIgnoreWhiteSpace: TMenuItem;
    mnuView: TMenuItem;
    PreviousChanges1: TMenuItem;
    NextChanges1: TMenuItem;
    ToolBar1: TToolBar;
    btnOpen1: TToolButton;
    ImageList1: TImageList;
    ActionList1: TActionList;
    actOpen1: TAction;
    actOpen2: TAction;
    actEditMode: TAction;
    btnOpen2: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    btnSaveAll: TToolButton;
    btnSave2: TToolButton;
    ToolButton5: TToolButton;
    btnCompare: TToolButton;
    btnPrevDiff: TToolButton;
    actCancel: TAction;
    btnNextDiff: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    Image1: TImage;
    ImageList16: TImageList;
    Panel1: TPanel;
    lblFile1: TLabel;
    lblFile2: TLabel;

    procedure actIgnoreCaseExecute(Sender: TObject);
    procedure actIgnoreSpaceExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ResultGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure ResultGridAfterSelection(Sender: TObject; aCol, aRow: Integer);
    procedure FormActivate(Sender: TObject);

    procedure actOpen1Execute(Sender: TObject);
    procedure actOpen2Execute(Sender: TObject);
    procedure actSave1Execute(Sender: TObject);
    procedure actSave2Execute(Sender: TObject);


    procedure actCompareExecute(Sender: TObject);
    procedure actPrevDiffExecute(Sender: TObject);
    procedure actNextDiffExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure btnCompareClick(Sender: TObject);

  private
    Diff: TDiff;
    source1, source2: TStringList;
    result1, result2: TStringList;
    hashlist1, hashlist2: TIntegerList;
    IgnoreCase, IgnoreWhiteSpace: boolean;
    procedure Clear(aleft,aright: boolean);
    procedure BuildHashList(left,right: boolean);
    procedure OpenFile(src: integer; const filename: string);
    procedure ShowRowInEdits(row: integer);
//    procedure OpenFile1(const filename: string);
//    procedure OpenFile2(const filename: string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses HashUnit;

{$R *.lfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  Diff := TDiff.Create(self);
  source1 := TStringList.Create;
  source2 := TStringList.Create;
  result1 := TStringList.Create;
  result2 := TStringList.Create;
  hashlist1 := TIntegerList.Create;
  hashlist2 := TIntegerList.Create;

  IgnoreCase := true;
  IgnoreWhiteSpace := true;
  ResultGrid.ColWidths[0] := 40;
  ResultGrid.ColWidths[2] := 40;
  ResultGrid.Canvas.Font := ResultGrid.Font;
  //ResultGrid.DefaultRowHeight := ResultGrid.Font.Height + 2;
end;

procedure TForm1.actIgnoreSpaceExecute(Sender: TObject);
begin
  actIgnoreSpace.Checked := not actIgnoreSpace.Checked;
  IgnoreWhiteSpace := mnuIgnoreWhiteSpace.Checked;
  Clear(false,false);
  BuildHashList(true,true);
  actCompareExecute(nil);
end;

procedure TForm1.actSave1Execute(Sender: TObject);
begin

end;

procedure TForm1.actSave2Execute(Sender: TObject);
begin

end;

procedure TForm1.actIgnoreCaseExecute(Sender: TObject);
begin
  actIgnoreCase.checked := not actIgnoreCase.checked; //mnuIgnoreWhiteSpace.Checked := not mnuIgnoreWhiteSpace.Checked;
  IgnoreWhiteSpace := mnuIgnoreWhiteSpace.Checked;
  Clear(false,false);
  BuildHashList(true,true);
  actCompareExecute(nil);
end;

//------------------------------------------------------------------------------

procedure TForm1.FormActivate(Sender: TObject);
begin
  mnuIgnoreCase.Checked := IgnoreCase;
  mnuIgnoreWhiteSpace.Checked := IgnoreWhiteSpace;
  if (paramcount > 0) then OpenFile(1, paramstr(1));
  if (paramcount > 1) then OpenFile(2, paramstr(2));
  actCompareExecute(nil);
end;


//------------------------------------------------------------------------------

procedure TForm1.FormDestroy(Sender: TObject);
begin
  source1.Free;
  source2.Free;
  result1.Free;
  result2.Free;
  hashlist1.Free;
  hashlist2.Free;
end;
//------------------------------------------------------------------------------

procedure TForm1.Clear(aleft, aright: boolean);
begin
  if aleft then
  begin
    source1.Clear;
    result1.Clear;
    hashlist1.Clear;
    lblFile1.Caption := ' File1: ';
  end;
  if aright then
  begin
    source2.Clear;
    result2.Clear;
    hashlist2.Clear;
    lblFile2.Caption := ' File2: ';
  end;
  ResultGrid.RowCount := 0;
  Diff.Clear;
  Edit1.Text := '';
  Edit2.Text := '';
  StatusBar1.Panels[0].Text := '';
  StatusBar1.Panels[1].Text := '';
  StatusBar1.Panels[2].Text := '';
  StatusBar1.Panels[3].Text := '';
  mnuCompare.Enabled := false;
  //mnuView.Enabled := false;
end;
//------------------------------------------------------------------------------

procedure TForm1.OpenFile(src: integer; const filename: string);
var
  i: integer;
begin
  if (src <>1) and (src <> 2) then exit;
  if not fileExists(fileName) then exit;

  if (src = 1) then begin
    Clear(true, false);
    source1.LoadFromFile(fileName);
    lblFile1.Caption := ' File1: ' + ExtractFileName(fileName);
    BuildHashList(true, false);
  end;
  if (src = 2) then begin
    Clear(false, true);
    source2.LoadFromFile(fileName);
    lblFile2.Caption := ' File2: ' + ExtractFileName(fileName);
    BuildHashList(false, true);
  end;

  ResultGrid.RowCount := max(source1.Count, source2.Count);
  for i := 0 to 3 do ResultGrid.Cols[i].BeginUpdate;
  try
    for i := 0 to source1.Count -1 do
    begin
      ResultGrid.Cells[0,i] := inttostr(i+1);
      ResultGrid.Cells[1,i] := source1[i];
    end;
    for i := 0 to source2.Count -1 do
    begin
      ResultGrid.Cells[2,i] := inttostr(i+1);
      ResultGrid.Cells[3,i] := source2[i];
    end;
  finally
    for i := 0 to 3 do ResultGrid.Cols[i].EndUpdate;
  end;
end;


//------------------------------------------------------------------------------

procedure TForm1.actOpen1Execute(Sender: TObject);
begin
    if OpenDialog1.Execute then OpenFile(1, OpenDialog1.FileName);
end;

procedure TForm1.actOpen2Execute(Sender: TObject);
begin
    if OpenDialog1.Execute then OpenFile(2, OpenDialog1.FileName);
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  close;
end;

//------------------------------------------------------------------------------

procedure TForm1.FormResize(Sender: TObject);
var
  i: integer;
begin
  with ResultGrid do
  begin
    i := (ClientWidth -80) div 2;
    ResultGrid.ColWidths[1] := i;
    ResultGrid.ColWidths[3] := i;
  end;
  lblFile2.Left := Panel1.ClientWidth div 2;
end;
//------------------------------------------------------------------------------

//Because it's SO MUCH EASIER AND FASTER comparing hashes (integers) than
//comparing whole lines of text, we'll build a list of hashes for each line
//in the source files. Each line is represented by a (virtually) unique
//hash that is based on the contents of that line. Also, since the
//likelihood of 2 different lines generating the same hash is so small,
//we can safely ignore that possibility.

procedure TForm1.BuildHashList(left, right: boolean);
var
  i: integer;
begin
  if left then
  begin
    hashlist1.Clear;
    for i := 0 to source1.Count -1 do
      hashlist1.Add(HashLine(source1[i], IgnoreCase, IgnoreWhiteSpace));
  end;
  if right then
  begin
    hashlist2.Clear;
    for i := 0 to source2.Count -1 do
      hashlist2.Add(HashLine(source2[i], IgnoreCase, IgnoreWhiteSpace));
  end;

  mnuCompare.Enabled := (hashlist1.Count > 0) and (hashlist2.Count > 0);
end;
//------------------------------------------------------------------------------

procedure TForm1.actCompareExecute(Sender: TObject);
var
  i: integer;
begin
  if (hashlist1.Count = 0) or (hashlist2.Count = 0) then exit;
  mnuCancel.Enabled := true;
  screen.Cursor := crHourGlass;
  try
    //this is where it all happens  ...

    //nb: TList.list is a pointer to the bottom of the list's integer array
    Diff.Execute(hashlist1, hashlist2);

    if Diff.Cancelled then exit;

    //now fill ResultGrid with the differences ...
    for i := 0 to 3 do
    begin
      ResultGrid.Cols[i].BeginUpdate;
      ResultGrid.Cols[i].Clear;
    end;

    try
      ResultGrid.RowCount := Diff.Count;
      for i := 0 to Diff.Count -1 do
        with Diff.Compares[i], ResultGrid do
        begin
          if Kind <> ckAdd then
          begin
            Cells[0,i] := inttostr(oldIndex1+1);
            Cells[1,i] := source1[oldIndex1];
          end;
          if Kind <> ckDelete then
          begin
            Cells[2,i] := inttostr(oldIndex2+1);
            Cells[3,i] := source2[oldIndex2];
          end;
        end;
    finally
      for i := 0 to 3 do ResultGrid.Cols[i].EndUpdate;
    end;

    with Diff.DiffStats do
    begin
      StatusBar1.SimplePanel := False;
      StatusBar1.Panels[0].Text := ' Matches: ' + inttostr(matches);
      StatusBar1.Panels[1].Text := ' Modifies: ' + inttostr(modifies);
      StatusBar1.Panels[2].Text := ' Adds: ' + inttostr(adds);
      StatusBar1.Panels[3].Text := ' Deletes: ' + inttostr(deletes);
    end;

  finally
    screen.Cursor := crDefault;
    mnuCancel.Enabled := false;
  end;
  mnuView.Enabled := true;
end;

procedure TForm1.actCancelExecute(Sender: TObject);
begin
  Diff.Cancel;
end;




procedure TForm1.btnCompareClick(Sender: TObject);
begin

end;

procedure TForm1.actNextDiffExecute(Sender: TObject);
var
  row: integer;
  Kind: TChangeKind;
begin
  row := ResultGrid.Selection.Top;
  // Selection.Top is -1 when the grid is empty or when the last click landed
  // outside any cell. Diff.Compares[] must never be indexed with -1.
  if (row < 0) or (Diff.Count = 0) then exit;
  if row = ResultGrid.RowCount -1 then exit;
  Kind := Diff.Compares[row].Kind;
  while (row < ResultGrid.RowCount -1) and
    (Diff.Compares[row].Kind = Kind) do inc(row);
  if Diff.Compares[row].Kind = ckNone then
  begin
    Kind := ckNone;
    while (row < ResultGrid.RowCount -1) and
      (Diff.Compares[row].Kind = Kind) do inc(row);
  end;
  ResultGrid.Selection := TGridRect(Rect(0, row, 3, row));
  if row > ResultGrid.TopRow + ResultGrid.VisibleRowCount -1 then
    ResultGrid.TopRow := max(0,min(row, ResultGrid.RowCount - ResultGrid.VisibleRowCount));

  ResultGrid.Row := row;
  // Setting Row goes through MoveExtend, which fires OnAfterSelection; the
  // edits are refreshed from there. No explicit ShowRowInEdits call needed.
end;

//------------------------------------------------------------------------------
procedure TForm1.actPrevDiffExecute(Sender: TObject);
var
  row: integer;
  Kind: TChangeKind;
begin
  row := ResultGrid.Selection.Top;
  // See the note in actNextDiffExecute: guard against Selection.Top = -1.
  if (row < 0) or (Diff.Count = 0) then exit;
  if row <= 0 then exit;
  Kind := Diff.Compares[row].Kind;
  while (row > 0) and (Diff.Compares[row].Kind = Kind) do dec(row);
  if Diff.Compares[row].Kind = ckNone then
  begin
    Kind := ckNone;
    while (row > 0) and
      (Diff.Compares[row].Kind = Kind) do dec(row);
  end;
  ResultGrid.Selection := TGridRect(Rect(0, row, 3, row));
  If row < ResultGrid.TopRow then
    ResultGrid.TopRow := Max(0, row - ResultGrid.VisibleRowCount +1);

  ResultGrid.Row := row;
  // Setting Row goes through MoveExtend, which fires OnAfterSelection; the
  // edits are refreshed from there. No explicit ShowRowInEdits call needed.
end;


procedure AddCharToStr(var s: string; c: char; kind, lastkind: TChangeKind);
begin
  if (Kind = lastKind) then s := s + c
  else
  case kind of
    ckNone: s := s + '<BC:------>' + c;
    else s := s + '<BC:33FFFF>' + c;
  end;
end;
//------------------------------------------------------------------------------
// Copies the text of column 1 (file 1) and column 3 (file 2) of the given row
// into Edit1 and Edit2. Out-of-range rows and empty cells yield empty edits.
//
// NOTE: "row" is a 0-based grid row index (as delivered by OnAfterSelection),
// NOT a display line number. TStringGrid.Cells[] is 0-based as well, so it must
// be used as-is. It must never be decremented: doing so turns row 0 into -1 and
// makes Cells[] raise EGridException('Index Out of range Cell[Col=1 Row=-1]').
procedure TForm1.ShowRowInEdits(row: integer);
begin
  if (row < 0) or (row > ResultGrid.RowCount - 1) then
  begin
    Edit1.Text := '';
    Edit2.Text := '';
    exit;
  end;

  Edit1.Text := ResultGrid.Cells[1, row];   // left  file, 2nd column
  Edit2.Text := ResultGrid.Cells[3, row];   // right file, 4th column
end;
//------------------------------------------------------------------------------

procedure TForm1.ResultGridAfterSelection(Sender: TObject; aCol, aRow: Integer);
begin
  // CAUTION: despite the "After" in its name, OnAfterSelection does NOT receive
  // the newly selected cell. LCL forwards the PREVIOUS coordinates:
  //
  //   procedure TCustomGrid.AfterMoveSelection(const prevCol, prevRow: Integer);
  //   begin
  //     if Assigned(OnAfterSelection) then
  //       OnAfterSelection(Self, prevCol, prevRow);   // <-- prevCol, prevRow
  //   end;                                            //     (grids.pas:3131)
  //
  // So aCol/aRow are the cell we came FROM, not the one just clicked. Using them
  // here would always display the previous row. The grid's own state is already
  // up to date by now (MoveExtend assigns FCol/FRow before calling
  // AfterMoveSelection), so read the current row straight from the grid.
  //
  // The aCol/aRow parameters are intentionally unused; ShowRowInEdits() validates
  // the row itself and blanks both edits when it is out of range.
  ShowRowInEdits(ResultGrid.Row);
end;
//------------------------------------------------------------------------------

procedure TForm1.ResultGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
const
  PaleRed  : TColor = $AAAAFF;
  PaleBlue : TColor = $FFAAAA;
  // Tab stop width, in characters. This project uses a 4-column tab stop.
  TabWidth = 4;
var
  clr,ctxt: Tcolor;
  ts: TTextStyle;
  cells: string;

  // Expands every #9 into spaces so that the text following it starts at the
  // next multiple of TabWidth, measured from the start of the string.
  //
  // WHY WE EXPAND OURSELVES instead of letting Windows do it:
  // TextRect() maps Style.ExpandTabs -> DT_EXPANDTABS (canvas.inc:1281). Windows'
  // DrawText only honours DT_EXPANDTABS when it performs its own layout; with
  // DT_SINGLELINE (which TTextStyle sets by default, grids.pas:10039) a leading
  // tab is consumed without advancing the pen, so the indentation silently
  // collapses to zero. Doing the expansion ourselves keeps the result
  // identical in every code path and independent of the widgetset.
  function ExpandTabs(const S: string): string;
  var
    i, col: Integer;
  begin
    Result := '';
    col := 0;
    for i := 1 to Length(S) do
    begin
      if S[i] = #9 then
      begin
        repeat
          Result := Result + ' ';
          inc(col);
        until (col mod TabWidth) = 0;
      end
      else
      begin
        Result := Result + S[i];
        inc(col);
      end;
    end;
  end;
begin
  if (gdSelected in State) and (ACol in [0,2]) then
  begin
     clr := clHighlight;
     ctxt := clHighlightText;
  end
  else if (Diff.Count = 0) then
  begin
    clr := clWhite;
    ctxt := clBlack;
  end
  else
  begin
    clr := clBtnFace;
    ctxt := clBlack;
  end;

  if (ACol in [1,3]) and (ARow >= 0) and (ARow < Diff.Count) then
  begin
    case Diff.Compares[ARow].Kind of
      ckNone: clr := clWhite;
      ckModify: clr := clYellow;
      ckDelete: clr := PaleRed;
      ckAdd: clr := PaleBlue;
    end;
  end;

  with ResultGrid.Canvas do
  begin
    // Set up the text style for the rest of this cell.
    //
    // WHY THIS IS NEEDED (the "leading blanks disappear" bug):
    // A cell is painted in four steps, each potentially overwriting Canvas.TextStyle:
    //   1. PrepareCanvas          -> sets TextStyle from DefaultTextStyle
    //   2. DefaultDrawCell        -> DrawCellText       (we skip this: DefaultDrawing=False)
    //   3. OnDrawCell (this proc) -> our own TextRect   (does not touch TextStyle)
    //   4. DrawCellGrid           -> draws the grid lines
    // We therefore inherit whatever PrepareCanvas left behind, i.e. DefaultTextStyle.
    // LCL builds DefaultTextStyle from Canvas.TextStyle in the CONSTRUCTOR
    // (grids.pas:10037) and only overrides Wordbreak/SingleLine, so ShowPrefix
    // keeps the TCanvas default of False (canvas.inc:1532).
    // Without ShowPrefix the widgetset adds DT_NOPREFIX (canvas.inc:1284), which
    // makes Windows swallow any '&' in the text -- so '  &value' comes out as
    // 'value', i.e. the blanks in front of it vanish.
    //
    // Note: Canvas.TextStyle is a read-only property, so it must be copied to a
    // local style record, modified, and written back.
    ts := TextStyle;
    ts.ShowPrefix := True;    // keep '&' literal (the actual fix)
    ts.ExpandTabs := False;   // we expand tabs ourselves, see ExpandTabs() above
    TextStyle := ts;

    Brush.Color := clr;
    Font.Color := ctxt;
    FillRect(Rect);

    // Our own TextRect() call is NOT affected by DefaultTextStyle.ShowPrefix,
    // so '&' is rendered literally there. We deliberately bypass LCL's
    // DrawCellText because it clips the text to the cell rect; long source
    // lines would lose their leading blanks once the cell is scrolled.
    cells := ExpandTabs(ResultGrid.Cells[ACol,ARow]);
    TextRect(Rect, Rect.Left+3,Rect.Top+2, cells);

    if (source1.Count = 0) and (source2.Count = 0) then exit;

    //now just some fancy coloring ...
    if (ACol in [0,2]) then
    begin
      Pen.Color := clWhite;
      MoveTo(Rect.Right-1,0);
      LineTo(Rect.Right-1,Rect.Bottom);
    end else
    begin
      if (ACol = 1) then
      begin
        Pen.Color := $333333;
        MoveTo(Rect.Right-1,0);
        LineTo(Rect.Right-1,Rect.Bottom);
      end;
      Pen.Color := clSilver;
      MoveTo(Rect.Left,0);
      LineTo(Rect.Left,Rect.Bottom);
    end;
    //finally, draw the focusRect ...
    if (gdSelected in State) and (ACol in [1,3]) then
    begin
      rect.Left := 0;
      DrawFocusRect(Rect);
    end;
  end;
end;

//------------------------------------------------------------------------------

function GridRect(Coord1, Coord2: TGridCoord): TGridRect;
begin
  with Result do
  begin
    Left := Coord2.X;
    if Coord1.X < Coord2.X then Left := Coord1.X;
    Right := Coord1.X;
    if Coord1.X < Coord2.X then Right := Coord2.X;
    Top := Coord2.Y;
    if Coord1.Y < Coord2.Y then Top := Coord1.Y;
    Bottom := Coord1.Y;
    if Coord1.Y < Coord2.Y then Bottom := Coord2.Y;
  end;
end;

//------------------------------------------------------------------------------

end.
