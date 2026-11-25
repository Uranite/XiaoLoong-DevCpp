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

unit CodeCompletionForm;

interface

uses
{$IFDEF MSWINDOWS}
  {$IFDEF MSWINDOWS}Windows{$ELSE}LCLIntf, LCLType{$ENDIF},
{$ENDIF}
  Classes, Graphics, Forms, StdCtrls, Controls,
  CppParser, CBUtils;

type
  ICodeCompletionFormEvents = interface
    procedure OnFormKeyPress(Sender: TObject; var Key: Char);
    procedure OnFormHide;
    function GetParser: TCppParser;
    function GetColor: TColor;
  end;

  TCodeComplForm = class(TForm)
    lbCompletion: TListBox;
    procedure FormShow(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure lbCompletionDblClick(Sender: TObject);
    procedure lbCompletionDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbCompletionKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    fEvents: ICodeCompletionFormEvents;
//    fOwner: TCodeCompletion;
  public
    constructor Create(AOwner: TComponent; AEvents: ICodeCompletionFormEvents); reintroduce;
    procedure UpdateCompletionList(Statements: TList);
    procedure UpdateSize;
  end;

//var
//  CodeComplForm: TCodeComplForm;

implementation

{$R *.lfm}

constructor TCodeComplForm.Create(AOwner: TComponent; AEvents: ICodeCompletionFormEvents);
begin
  inherited Create(AOwner);
  fEvents := AEvents;
end;
{
procedure TCodeComplForm.lbCompletionKeyPress(Sender: TObject; var Key: Char);
begin
  if Assigned(fEvents) then
    fEvents.OnFormKeyPress(Sender, Key);
end;

procedure TCodeComplForm.FormDeactivate(Sender: TObject);
begin
  if Assigned(fEvents) then
    fEvents.OnFormHide;
end;

procedure TCodeComplForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  Params.Style := Params.Style or WS_SIZEBOX;
end;
}

procedure TCodeComplForm.lbCompletionDblClick(Sender: TObject);
var
  Key: Char;
begin
  // Send command to TEditor
  if Assigned(fEvents) then begin
    Key := Char(VK_RETURN);
    fEvents.OnFormKeyPress(Self, Key);
  end;
end;

procedure TCodeComplForm.lbCompletionDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  Offset: integer;
  statement: PStatement;
begin
  Offset := 4;

  with lbCompletion do begin
    statement := PStatement(Items.Objects[Index]);

    if (Integer(State) and (1 shl Ord(odSelected))) <> 0 then begin
      Canvas.Brush.Color := clHighlight;
      Canvas.FillRect(Rect);
      Canvas.Font.Color := clHighlightText;
    end else begin
      Canvas.Brush.Color := fEvents.GetColor;
      Canvas.FillRect(Rect);
      case statement^._Kind of
        skFunction: Canvas.Font.Color := clGreen;
        skClass: Canvas.Font.Color := clMaroon;
        skVariable: Canvas.Font.Color := clBlue;
        skTypedef: Canvas.Font.Color := clOlive;
        skPreprocessor: Canvas.Font.Color := clPurple;
        skEnum: Canvas.Font.Color := clNavy;
      else
        Canvas.Font.Color := clGray;
      end;
    end;

{
    // Draw statement kind string: 'preprocessor', 'variable', 'constructor', 'destructor',
    // 'function', 'class', 'typedef', 'enum', 'unknown';
    Canvas.TextOut(Offset, Rect.Top, fEvents.GetParser.StatementKindStr(statement^._Kind));
    Offset := Offset + Canvas.TextWidth('preprocessor '); // worst case width + spacing
    if not (odSelected in State) then
      Canvas.Font.Color := clWindowText;

    // Draw data type string, like 'int', hide for defines/others that don't have this property
    if Length(statement^._Type) > 0 then begin
      Canvas.TextOut(Offset, Rect.Top, statement^._Type);
      Offset := Offset + Canvas.TextWidth(statement^._Type + ' ');
    end;
}
    // draw statement name, like 'printf'
    Canvas.Font.Style := [fsBold];
    Canvas.TextOut(Offset, Rect.Top, statement^._Command);
    Offset := Offset + Canvas.TextWidth(statement^._Command + ' ');

{    // if applicable, draw arguments
    if statement^._Kind in [skFunction, skConstructor, skDestructor] then begin
      Canvas.Font.Style := [];
      Canvas.TextOut(Offset, Rect.Top, statement^._Args);
    end;
}
  end;
end;

procedure TCodeComplForm.lbCompletionKeyPress(Sender: TObject; var Key: Char);
begin
  if Assigned(fEvents) then
    fEvents.OnFormKeyPress(Sender, Key);
end;

procedure TCodeComplForm.FormDeactivate(Sender: TObject);
begin
  if Assigned(fEvents) then
    fEvents.OnFormHide;
end;

procedure TCodeComplForm.FormPaint(Sender: TObject);
begin
  // Draw 2px black border around the form.
  // TCanvas.FrameRect is shadowed by Windows.FrameRect, so call it explicitly.
  Canvas.Brush.Color := clBlack;
  Canvas.Brush.Style := bsSolid;
  TCanvas(Canvas).FrameRect(Rect(2, 2, ClientWidth - 2, ClientHeight - 2));
  TCanvas(Canvas).FrameRect(Rect(3, 3, ClientWidth - 3, ClientHeight - 3));
end;

procedure TCodeComplForm.UpdateCompletionList(Statements: TList);
var
  I: integer;
begin
  lbCompletion.Items.BeginUpdate;
  try
    lbCompletion.Items.Clear;
    for I := 0 to Statements.Count - 1 do
      lbCompletion.Items.AddObject('', TObject(Statements[I]));
  finally
    lbCompletion.Items.EndUpdate;
  end;
end;

procedure TCodeComplForm.FormShow(Sender: TObject);
begin
  lbCompletion.BorderStyle := bsSingle;
  lbCompletion.DoubleBuffered := true;
  lbCompletion.Font.Size := self.Font.Size -2;
  if lbCompletion.Font.Size < 9 then
    lbCompletion.Font.Size := 9;

  lbCompletion.Canvas.Font.Size := lbCompletion.Font.Size;
  lbCompletion.ItemHeight := lbCompletion.Canvas.TextHeight('Ag') + 4;

  lbCompletion.Align := alClient;
  UpdateSize;
end;

// 按当前 lbCompletion 的条目数调整窗体尺寸：
// 条目不足 5 条时收缩到实际条目数（下方不留空白），达到/超过 5 条时最多显示 5 条（其余滚动查看）。
// 除首次显示（FormShow）外，Search 在窗体已显示的状态下重新筛选列表后也要调用，
// 使提示框高度随候选词数量实时变化。
procedure TCodeComplForm.UpdateSize;
var
  NewHeight, NewWidth: Integer;
  MaxVisibleItems: Integer;
  i: Integer;
  TextWidth: Integer;
  statement: PStatement;
begin
  if lbCompletion.Items.Count = 0 then
    Exit;

  // Show at most 5 items
  MaxVisibleItems := 5;
  if lbCompletion.Items.Count < MaxVisibleItems then begin
    NewHeight := lbCompletion.ItemHeight * lbCompletion.Items.Count;
    if lbCompletion.Items.Count = 1 then
      NewHeight := NewHeight + 10
  end
  else
    NewHeight := lbCompletion.ItemHeight * MaxVisibleItems;

  NewHeight := NewHeight + 4;  // fixed offset for margin

  // Calculate max width from items
  NewWidth := 100;
  try
    for i := 0 to lbCompletion.Items.Count - 1 do begin
      statement := PStatement(lbCompletion.Items.Objects[i]);
      TextWidth := lbCompletion.Canvas.TextWidth(statement^._Command);
      if TextWidth > NewWidth then
        NewWidth := TextWidth;
    end;
    NewWidth := NewWidth + lbCompletion.Canvas.Font.Size * 2;

  finally
    //
  end;
  if NewWidth < 100 then
    NewWidth := 100;

  // Set form dimensions
  Self.ClientWidth := NewWidth;
  Self.ClientHeight := NewHeight;
end;

end.

