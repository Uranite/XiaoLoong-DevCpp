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

unit CodeToolTip;

interface

uses
  SysUtils, Classes, {$IFDEF MSWINDOWS}Windows{$ELSE}LCLIntf, LCLType{$ENDIF}, Messages, Graphics, Controls, Forms, Types,
  ATSynEdit, utils, CppParser;

type
  TCustomCodeToolTipButton = class(TPersistent)
  private
    FLeft: Integer;
    FTop: Integer;
    FWidth: Integer;
    FHeight: Integer;
  protected
    procedure Paint(const TargetCanvas: TCanvas); virtual; abstract;
    property Left: Integer read FLeft write FLeft;
    property Top: Integer read FTop write FTop;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
  public
    constructor Create; virtual;
    function ClientRect: TRect;
  end;

  TCodeToolTipUpButton = class(TCustomCodeToolTipButton)
  private
    FBitmap: TBitmap;
  protected
    procedure Paint(const TargetCanvas: TCanvas); override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

  TCodeToolTipDownButton = class(TCustomCodeToolTipButton)
  private
    FBitmap: TBitmap;
  protected
    procedure Paint(const TargetCanvas: TCanvas); override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

  { Options to customize the CodeToolTip behavior }
  TToolTipOptions = set of
    (
    ttoHideOnEsc, // hides the tooltip when ESC has been pressed
    ttoCurrentArgumentExtra, // force the current argument to attract extra attention
    shoFindBestMatchingToolTip // automatically find the best matching tooltip (for overloaded functions)
    );

  TCodeToolTip = class(THintWindow)
  private
    FActivated: Boolean;
    FParser: TCppParser;
    FTokenPos: Integer;
    FFunctionEnd: Integer;
    FFunctionStart: Integer;
    FUpButton: TCustomCodeToolTipButton;
    FDownButton: TCustomCodeToolTipButton;
    FSelIndex: Integer;
    FBmp: TBitmap;
    FOptions: TToolTipOptions;
    FEditor: TATSynEdit;  //TCustomSynEdit;
    FKeyDownProc: TKeyEvent;
    FToolTips: TStringList;
    FCurParamIndex: Integer;
    FLookupEditor: TATSynEdit;
    FMaxScanLength: Integer;
    FOldFunction: AnsiString;
    FForceHide: boolean; // true if hidden by Esc
    FCustomSelIndex: Boolean; // user clicked up/down
    procedure SetSelIndex(Value: Integer);
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
  protected
    function GetCommaIndex(P: PUnicodeChar; Start, CurPos: Integer): Integer;
    function FindClosestToolTip(const ToolTip: AnsiString; CommaIndex: Integer): AnsiString;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DummyPaint(RealShow: boolean): integer; //Paint and obtain tooltip width
    procedure Paint; override;
    procedure RethinkCoordAndActivate;
    property MaxScanLength: Integer read FMaxScanLength write FMaxScanLength;
    property SelIndex: Integer read FSelIndex write SetSelIndex;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Show;
    procedure ActivateHint(Rect: TRect; const AHint: String); override;
    procedure ReleaseHandle;
    property ForceHide: boolean read FForceHide write FForceHide;
    property Options: TToolTipOptions read FOptions write FOptions;
    property Parser: TCppParser read FParser write FParser;
    property Activated: Boolean read FActivated write FActivated;
    property Editor: TATSynEdit read FEditor write FEditor;
    //property Editor: TCustomSynEdit read FEditor write FEditor;
  end;

implementation

uses
  devcfg;

// contains the up/down buttons
// I tried to draw them using DrawFrameControl first,
// but it looked very bad, so I use a bitmap instead.
{$R CodeToolTip.res}

resourcestring
  SCodeToolTipIndexXOfX = '%d/%d';  //'%2d/%2d';

var
  Identifiers: array[#0..#255] of boolean;

procedure MakeIdentTable;
var
  c: char;
begin
  FillChar(Identifiers, SizeOf(Identifiers), 0);

  for c := 'a' to 'z' do
    Identifiers[c] := True;

  for c := 'A' to 'Z' do
    Identifiers[c] := True;

  for c := '0' to '9' do
    Identifiers[c] := True;

  Identifiers['_'] := True;
  Identifiers['~'] := True;
end;

// Returns name of function, so passing "foo(bar,bar,bar)" will return "foo"

function GetPrototypeName(const S: AnsiString): AnsiString;
var
  WordEnd, WordStart: Integer;
begin
  WordEnd := Pos('(', S);

  // If we found the starting ( of a function
  if WordEnd > 0 then begin

    // Skip blanks
    repeat
      Dec(WordEnd);
    until (WordEnd = 0) or not (S[WordEnd] in [#32, #9, #13, #10]);

    // Then save the next word
    WordStart := WordEnd;
    repeat
      Dec(WordStart);
    until (WordStart = 0) or (S[WordStart] in [#0..#32]); // This fixes an unsigned 0 - 1 range error

    Result := Copy(S, WordStart + 1, WordEnd - WordStart);
  end else
    Result := '';
end;

//----------------- TCustomCodeToolTipButton ---------------------------------------------------------------------------

constructor TCustomCodeToolTipButton.Create;
begin
  FLeft := 0;
  FTop := 0;
  FWidth := 9;
  FHeight := 11;
end;

function TCustomCodeToolTipButton.ClientRect: TRect;
begin
  Result := Rect(FLeft, FTop, FLeft + FWidth, FTop + FHeight);
end;

//----------------- TCodeToolTipUpButton -------------------------------------------------------------------------------

constructor TCodeToolTipUpButton.Create;
begin
  inherited;

  FBitmap := TBitmap.Create;
  FBitmap.LoadFromResourceName(HInstance, 'UPBUTTON');
end;

destructor TCodeToolTipUpButton.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

procedure TCodeToolTipUpButton.Paint(const TargetCanvas: TCanvas);
begin
  StretchBlt(TargetCanvas.Handle, FLeft, FTop, FWidth, FHeight, FBitmap.Canvas.Handle, 0, 0, FBitmap.Width,
    FBitmap.Height, SRCCOPY);
end;

//----------------- TCodeToolTipDownButton -----------------------------------------------------------------------------

constructor TCodeToolTipDownButton.Create;
begin
  inherited;

  FBitmap := TBitmap.Create;
  FBitmap.LoadFromResourceName(HInstance, 'DOWNBUTTON');
end;

destructor TCodeToolTipDownButton.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

procedure TCodeToolTipDownButton.Paint(const TargetCanvas: TCanvas);
begin
  StretchBlt(TargetCanvas.Handle, FLeft, FTop, FWidth, FHeight, FBitmap.Canvas.Handle, 0, 0, FBitmap.Width,
    FBitmap.Height, SRCCOPY);
end;

//----------------- TCodeToolTip ---------------------------------------------------------------------------------------

constructor TCodeToolTip.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FLookupEditor := TATSynEdit.Create(Self);

  FOptions := [ttoHideOnEsc, ttoCurrentArgumentExtra, shoFindBestMatchingToolTip];

  FBmp := TBitmap.Create;
  with FBmp do begin
    PixelFormat := pf24Bit;
    Width := Screen.Width; // worst case hintwidth
    Height := 32;
  end;

  FToolTips := TStringList.Create;
  with FToolTips do begin
    Sorted := False;
    CaseSensitive := True;
    Duplicates := dupAccept;
  end;

  FMaxScanLength := 512; // Number of character to walk through trying to find ( and )

  FUpButton := TCodeToolTipUpButton.Create;
  FUpButton.Left := 4;
  FUpButton.Top := 5;

  FDownButton := TCodeToolTipDownButton.Create;
  FDownButton.Left := 20; // Edited at runtime
  FDownButton.Top := 5;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCodeToolTip.ActivateHint(Rect: TRect; const AHint: String);
begin
  inherited;
  FActivated := True;
end;

procedure TCodeToolTip.ReleaseHandle;
begin
  FActivated := False;
  if HandleAllocated then begin
    Hide;
    // Note: we Hide instead of DestroyHandle so ActivateHint can
    // re-show the window later without LCL handle-recreation issues.
  end;
end;

destructor TCodeToolTip.Destroy;
begin
  if Activated then
    ReleaseHandle;

  FKeyDownProc := nil;
  FEditor := nil;

  FreeAndNil(FUpButton);
  FreeAndNil(FDownButton);

  FBmp.Free;
  FToolTips.Free;
  FLookupEditor.Free;

  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCodeToolTip.FindClosestToolTip(const ToolTip: AnsiString; CommaIndex: Integer): AnsiString;
var
  I, K: Integer;
  NewIndex: Integer;
  Str: AnsiString;
  LastCommaCnt: Integer;
begin
  Result := '';
  NewIndex := -1;

  // Defensive check
  if not Assigned(FToolTips) or (FToolTips.Count = 0) then
    Exit;

  // Current selection is already good enough
  if (FSelIndex >= 0) and (FSelIndex < FToolTips.Count) then begin
    if ToolTip = FToolTips.Strings[FSelIndex] then
      if CountChar(FToolTips.Strings[FSelIndex], ',') <= CommaIndex then begin
        Result := FToolTips.Strings[FSelIndex];
        Exit;
      end;
  end;

  LastCommaCnt := 9999;

  for I := 0 to FToolTips.Count - 1 do begin
    Str := GetPrototypeName(FToolTips.Strings[I]);
    if SameStr(Str, ToolTip) then begin
      K := CountChar(FToolTips.Strings[I], ',');
      if K >= CommaIndex then begin
        if (K < LastCommaCnt) or
           ((K = LastCommaCnt) and (Pos(' public ', ' ' + FToolTips.Strings[I] + ' ') > 0)) then
        begin
          NewIndex := I;
          LastCommaCnt := K;
        end;
      end;
    end;
  end;

  if NewIndex >= 0 then begin
    Result := FToolTips.Strings[NewIndex];
    SelIndex := NewIndex;
  end;
end;


// Return the comma count the cursor is placed *after*, so foo(aaa,bbb,ccc) with the cursor somewhere in b will return 1

function TCodeToolTip.GetCommaIndex(P: PUnicodeChar; Start, CurPos: Integer): Integer;
var
  I: Integer;

  // skip to EOL
  procedure SkipLine;
  begin
    repeat
      Inc(i);
      if i > CurPos then
        Break;
    until (P[i] = #0) or (P[i] = #10) or (P[i] = #13);
  end;

  // skip c/c++ commentblocks
  procedure SkipCommentBlock;
  begin
    repeat
      case P[i] of
        '*':
          if P[i + 1] = '/' then begin
            Break;
          end;
      end;
      Inc(i);
      if i > CurPos then
        Break;
    until P[i] = #0;
  end;

  // skip strings! since it not unusual to
  // have commas in string we MUST ignore them!
  procedure SkipStrings;
  begin
    Inc(i);

    repeat
      case P[i] of
        // make sure not to skip inline string "'s
        // for example, a c string: "Hello \"Bond, James\"..."
        // This is ONE string only and we dont want to count commas in it
        '\':
          if P[i + 1] = '"' then
            Inc(i);

        '"': Break;
      end;
      Inc(i);
      if i > CurPos then
        Break;
    until P[i] = #0;
  end;

begin
  Result := 0;
  I := Start;

  while I <= CurPos do begin
    if P[i] = '"' then begin
      SkipStrings;
    end else if P[i] = '(' then begin
      repeat
        Inc(I);
      until (P[i] = #0) or (P[i] = ')');
      continue;
    end else if P[i] = '/' then begin
      if P[i + 1] = '/' then
        SkipLine
      else if P[i + 1] = '*' then
        SkipCommentBlock;
    end else if P[i] = ',' then
      Inc(Result);

    Inc(i);
  end;
end;

procedure TCodeToolTip.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Pt: TPoint;
  NeedRefresh: Boolean;
begin
  inherited;

  if Button = mbLeft then begin
    NeedRefresh := False;

    Pt := ScreenToClient(Mouse.CursorPos);
    if PtInRect(FUpButton.ClientRect, Pt) then begin
      if FSelIndex < FToolTips.Count - 1 then
        Inc(FSelIndex, 1)
      else
        FSelIndex := 0;

      NeedRefresh := True;
      FCustomSelIndex := True;
    end else if PtInRect(FDownButton.ClientRect, Pt) then begin
      if FSelIndex > 0 then
        Dec(FSelIndex, 1)
      else
        FSelIndex := FToolTips.Count - 1;

      NeedRefresh := True;
      FCustomSelIndex := True;
    end;

    FEditor.SetFocus;
    if NeedRefresh then
      Show;
  end;
end;

// Determine how much space we need...
// TODO: merge with Paint.
function TCodeToolTip.DummyPaint(RealShow: boolean): integer;
var
  TipWidth, ArgumentIndex, HighlightStart, BraceCount: Integer;
  S: String;
  CurPos: integer;
  InsideString: boolean;
//  HLAttr: TSynHighlighterAttributes;
begin
  TipWidth := 4; // Painting TipWidth. initiate with left offset in pixels (2px border + 2px padding)
  // Clear the backbuffer and set options
  with FBmp.Canvas do begin
    Brush.Color := devCodeCompletion.BackColor; //TColor($E1FFFF);
    FillRect(ClientRect);
    // Draw 2px black border (same as Paint method)
    //Pen.Color := clGray;
    //Pen.Width := 1;
    Brush.Style := bsClear;
    Rectangle(1, 1, ClientRect.Right , ClientRect.Bottom);
    Font.Size := Editor.Font.Size - 2;  // devData.InterfaceFontSize; //10;
    if Font.Size < 9 then
      Font.Size := 9;
    Font.Color := devCodeCompletion.TextColor;  //clBlack;
    Font.Style := [];
  end;

  // when more than one tooltip is in the list, we must draw the UP and DOWN buttons as well.
  if FToolTips.Count > 1 then begin

    // paint the UP button
    //if realshow then FUpButton.Paint(FBmp.Canvas);  //abli
    Inc(TipWidth, FUpButton.Left + FUpButton.Width);

    // output text between the buttons
    S := Format(SCodeToolTipIndexXOfX, [FSelIndex + 1, FToolTips.Count]);
    //if realshow then FBmp.Canvas.TextOut(TipWidth, 1, S);  //abli
    Inc(TipWidth, FBmp.Canvas.TextWidth(S) + 3);

    // paint the DOWN button
    FDownButton.Left := TipWidth;
    //if realshow then FDownButton.Paint(FBmp.Canvas);    //abli
    Inc(TipWidth, 3 + FUpButton.Left + FDownButton.Width);
  end;

  ArgumentIndex := -1;
  HighlightStart := 0;
  BraceCount := 0;
   //the exact painting need to check every character and set their style.
  // now loop through the hint and draw each letter
  for CurPos := 1 to Length(Caption) do begin

    // we use a lookup editor to get the syntax coloring for our tooltips and check for strings
    //FLookupEditor.CaretX := CurPos;   //the second time runnning this line will cause error. //abli
    //FLookupEditor.GetHighlighterAttriAtRowCol(FLookupEditor.CaretXY, S, HLAttr);
    //InsideString := (HLAttr = FLookupEditor.Highlighter.StringAttribute);
    if (Caption[CurPos] in [' '..'/']) or  (Caption[CurPos] in [':'..'@'])
      or (Caption[CurPos] in ['['..'`']) or (Caption[CurPos] in ['{'..'~']) then
      InsideString := false
    else
      InsideString := true;

    // Argument delimiters
    if not InsideString then begin
      case Caption[CurPos] of
        '(': begin
            Inc(BraceCount);
            if ArgumentIndex = -1 then begin // only the first one is a delimiter
              Inc(ArgumentIndex);
              HighlightStart := CurPos + 1;
            end;
          end;
        ')': begin
            Dec(BraceCount);
            if BraceCount = 0 then begin // end of argument list
              Inc(ArgumentIndex, 100);
              HighlightStart := CurPos + 1;
            end;
          end;
        ',': begin
            if BraceCount = 1 then begin
              Inc(ArgumentIndex);
              // Don't draw this one in red yet, but start at the next char...
              HighlightStart := CurPos + 1;
            end;
          end;
      end;
    end;

    //with FBmp.Canvas do begin
      FBmp.Canvas.Font.Color := devCodeCompletion.TextColor; //clBlack //don't use clCaptionText: can be white too, making stuff unreadable
      if (ArgumentIndex = FCurParamIndex) and (CurPos >= HighlightStart) then begin
       FBmp.Canvas.Font.Style := [fsBold];
        if (ttoCurrentArgumentExtra in FOptions) then
          FBmp.Canvas.Font.Color := devCodeCompletion.HighColor;  //clRed;
      end else
        FBmp.Canvas.Font.Style := []; //HLAttr.Style;

      if realshow then
        FBmp.Canvas.TextOut(TipWidth, 3, Caption[CurPos]);
      Inc(TipWidth, FBmp.Canvas.TextWidth(Caption[CurPos]));
    //end;
  end;
  Inc (TipWidth, 4);  //Right margin
  Result := TipWidth;
end;

// This function paints the tooltip to FBmp and copies it to the tooltip client surface
procedure TCodeToolTip.Paint;
//function TCodeToolTip.Paint(RealShow: boolean): integer;
var
  RealShow: boolean;
  ArgumentIndex, HighlightStart, TipWidth, BraceCount: Integer;
  S: String;
  CurPos: integer;
  InsideString: boolean;
//  HLAttr: TSynHighlighterAttributes;
begin
  RealShow := true;
  TipWidth := 4; // Painting TipWidth. initiate with left offset in pixels (2px border + 2px padding)
  // Clear the backbuffer and set options
  with FBmp.Canvas do begin
    Brush.Color := devCodeCompletion.BackColor; //TColor($E1FFFF);
    FillRect(ClientRect);
    // Draw 1px Gray border
    Pen.Color := clGray;
    Pen.Width := 1;
    Brush.Style := bsClear;
    Rectangle(1, 1, ClientRect.Right , ClientRect.Bottom );
    Font.Size := Editor.Font.Size - 2;  //devData.InterfaceFontSize; //10;
    if Font.Size < 9 then
      Font.Size := 9;
    Font.Color := devCodeCompletion.TextColor;  //clBlack;
    //Font.Style := [];
  end;

  // when more than one tooltip is in the list, we must draw the UP and DOWN buttons as well.
  if FToolTips.Count > 1 then begin

    // paint the UP button
    if realshow then
      FUpButton.Paint(FBmp.Canvas);
    Inc(TipWidth, FUpButton.Left + FUpButton.Width);

    // output text between the buttons
    S := Format(SCodeToolTipIndexXOfX, [FSelIndex + 1, FToolTips.Count]);
    if realshow then
      FBmp.Canvas.TextOut(TipWidth, 3, S);
    Inc(TipWidth, FBmp.Canvas.TextWidth(S) + 3);

    // paint the DOWN button
    FDownButton.Left := TipWidth;
    if realshow then
      FDownButton.Paint(FBmp.Canvas);
    Inc(TipWidth, 3 + FUpButton.Left + FDownButton.Width);
  end;

  ArgumentIndex := -1;
  HighlightStart := 0;
  BraceCount := 0;

  // now loop through the hint and draw each letter
  for CurPos := 1 to Length(Caption) do begin

    // we use a lookup editor to get the syntax coloring for our tooltips and check for strings
    //FLookupEditor.CaretX := CurPos;   //the second time runnning this line will cause error. //abli
    //FLookupEditor.GetHighlighterAttriAtRowCol(FLookupEditor.CaretXY, S, HLAttr);
    //InsideString := (HLAttr = FLookupEditor.Highlighter.StringAttribute);
    if (Caption[CurPos] in [' '..'/']) or  (Caption[CurPos] in [':'..'@'])
      or (Caption[CurPos] in ['['..'`']) or (Caption[CurPos] in ['{'..'~']) then
      InsideString := false
    else
      InsideString := true;

    // Argument delimiters
    if not InsideString then begin
      case Caption[CurPos] of
        '(': begin
            Inc(BraceCount);
            if ArgumentIndex = -1 then begin // only the first one is a delimiter
              Inc(ArgumentIndex);
              HighlightStart := CurPos + 1;
            end;
          end;
        ')': begin
            Dec(BraceCount);
            if BraceCount = 0 then begin // end of argument list
              Inc(ArgumentIndex, 100);
              HighlightStart := CurPos + 1;
            end;
          end;
        ',': begin
            if BraceCount = 1 then begin
              Inc(ArgumentIndex);
              // Don't draw this one in red yet, but start at the next char...
              HighlightStart := CurPos + 1;
            end;
          end;
      end;
    end;

    //with FBmp.Canvas do begin
      FBmp.Canvas.Font.Color := devCodeCompletion.TextColor;//clBlack; //don't use clCaptionText: can be white too, making stuff unreadable
      if (ArgumentIndex = FCurParamIndex) and (CurPos >= HighlightStart) then begin
       FBmp.Canvas.Font.Style := [fsBold];
        if (ttoCurrentArgumentExtra in FOptions) then
          FBmp.Canvas.Font.Color := devCodeCompletion.HighColor;  //clRed;
      end else
        FBmp.Canvas.Font.Style := []; //HLAttr.Style;

      if realshow then
        FBmp.Canvas.TextOut(TipWidth, 3, Caption[CurPos]);
      Inc(TipWidth, FBmp.Canvas.TextWidth(Caption[CurPos]));
    //end;
  end;
  if realshow then
    Canvas.CopyRect(ClientRect, FBmp.Canvas, ClientRect);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCodeToolTip.RethinkCoordAndActivate;
var
  Pt: TPoint;
begin
  // Clear the backbuffer and set options
  with FBmp.Canvas do begin
    // Paint the bg
    Brush.Color := TColor($E1FFFF);
    FillRect(ClientRect);
    Brush.Style := bsClear;

    // Set font properties before estimating height using it
    Font.Name := devEditor.Font.Name;
    Font.Size := Editor.Font.Size;  //Font.Size := 10;
    Font.Style := [];
  end;

  // ATSynEdit: use CaretPosToClientPos to position the tooltip
  // Position tooltip below the function token (FTokenPos = offset in text)
  with FEditor.CaretPosToClientPos(FEditor.OffsetToCaretPos(FTokenPos)) do
    Pt := FEditor.ClientToScreen(Point(Integer(X), Integer(Y)));

  ActivateHint(Rect(Pt.X,
    Pt.Y + FEditor.TextCharSize.Y + 2,
    Pt.X + DummyPaint(FALSE) + 4,   // +4 for 2px border on each side
    Pt.Y + FBmp.Canvas.TextHeight('Wg') + FEditor.TextCharSize.Y + 8),  // +8: was +4, now +4 more for border
    Caption);

  // Force repaint so FCurParamIndex change (argument highlight) is visible.
  // ActivateHint may skip repainting when the window is already shown at the
  // same position/caption, so we explicitly repaint here.
  if HandleAllocated then begin
    Paint;
    Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCodeToolTip.SetSelIndex(Value: Integer);
// sets the selection index and repaints the hint when it is activated
begin
  if Value <> FSelIndex then begin
    FSelIndex := Value;
    if Activated then begin
      FCustomSelIndex := True;
      Show;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCodeToolTip.Show;
var
  CurPos: Integer;
  P: PUnicodeChar;
  I: Integer;
  nBraces: Integer;
  S: AnsiString;
  CaretPos: Integer;
  nCommas: Integer;
  //token: String;
  TextUni: UnicodeString;
// TODO: ATSynEdit - removed TATSynHighlighterAttributes
  //FuncStartXY: TPoint;
begin
  // ATSynEdit: use CaretPosToOffset instead of CaretPosToStrPos(CaretPos)
  CaretPos := FEditor.CaretPosToOffset(Point(FEditor.Carets[0].PosX, FEditor.Carets[0].PosY));
  CurPos := CaretPos;

  // get a pointer to the collapsed text
  // ATSynEdit: FEditor.Text returns UnicodeString with LF-only line endings.
  // CaretPosToOffset returns a character index into this UnicodeString.
  // Must use PUnicodeChar (not PAnsiChar) so byte offsets match character
  // offsets — otherwise multi-byte chars (e.g. Chinese comments) cause
  // the caret position to be misaligned with the scanned text.
  TextUni := FEditor.Text;
  if Length(TextUni) = 0 then begin
    ReleaseHandle;
    Exit;
  end;
  //Don't change EOL symbol. Otherwise CurPos will not be precise.
  //TextUni := StringReplace(TextUni, #13#10, #10, [rfReplaceAll]);

  P := PUnicodeChar(TextUni);

  // If caret just moved past the closing ')', back it up one char so the
  // rightward scan below can find the ')' reliably.
  if (CurPos > 0) and (P[CurPos] <> ')') and (P[CurPos - 1] = ')') then
    Dec(CurPos);

  nBraces := 0;
  nCommas := 0;

  // Find out where the function ends...
  // Scan rightward from the caret to locate the matching closing ')'.
  // nBraces tracks nested parentheses depth relative to the start.
  // When nBraces reaches -1 we have passed the outermost closing ')'.
  for I := 1 to FMaxScanLength do begin

    // Stopping characters...
    if (P[CurPos] = #0) or (P[CurPos] = ';') then begin
      ReleaseHandle;
      Exit;

      // Opening brace, increase count
    end else if (P[CurPos] = '(') then begin
      Inc(nBraces);

      // Ending brace, decrease count or success (found ending)!
      // nBraces<=0: -1 if the caret was already between ( and ),
      //             0 if the caret was before the opening ( .
    end else if (P[CurPos] = ')') then begin
      Dec(nBraces);
      if nBraces <= 0 then
        break;

      // Single line comments
    end else if (P[CurPos] = '/') and (P[CurPos + 1] = '/') then begin

      // Walk up to an enter sequence
      while (P[CurPos] <> #0) and (P[CurPos] <> #13) and (P[CurPos] <> #10) do
        Inc(curpos);

      // Skip ONE enter sequence (CRLF, CR, LF, etc.)
      if (P[CurPos] = #13) and (P[CurPos + 1] = #10) then // DOS
        Inc(curpos, 2)
      else if (P[CurPos] = #13) then // UNIX
        Inc(curpos)
      else if (P[CurPos] = #10) then // MAC
        Inc(curpos);

      // Multiline comments
    end else if (P[CurPos] = '/') and (P[CurPos + 1] <> #0) and (P[CurPos + 1] = '*') then begin

      // Walk up to an */
      while (P[CurPos] <> #0) and (P[CurPos + 1] <> #0) and not ((P[CurPos] = '*') and (P[CurPos + 1] = '/')) do
        Inc(curpos);

      // Step over
      Inc(curpos);
    end;

    Inc(CurPos);
  end;

  // If we couldn't find the closing brace or reached the FMaxScanLength...
  if (nBraces > 0) then begin // -1 or 0 means found it (0 when caret was before '(')
    ReleaseHandle;
    Exit;
  end;

  FFunctionEnd := CurPos;

  // If the caret is past the closing ')' (strictly after it, not on it),
  // the caret is outside the argument list — hide the tooltip.
  // CaretPos is the original (unmodified) caret offset; FFunctionEnd is the
  // offset of the ')' we just found.
  if CaretPos > FFunctionEnd then begin
    ReleaseHandle;
    Exit;
  end;

  // We've stopped at the ending ), start walking backwards )*here* with nBraces = -1
  // When the caret was before the opening '(', the rightward scan left nBraces at 0;
  // the leftward scan needs -1 so the ( → Dec(nBraces) → -1 check breaks correctly.
  nBraces := -1;
  for I := 1 to FMaxScanLength do begin

    if (P[CurPos] = '/') and (P[CurPos - 1] = '*') then begin
      repeat
        Dec(CurPos);
      until (CurPos < 2) or ((P[CurPos] = '/') and (P[CurPos + 1] = '*'));

    end else if (P[CurPos] = ')') then begin
      Inc(nBraces);

    end else if (P[CurPos] = '(') then begin
      Dec(nBraces);
      if nBraces = -1 then // found it!
        Break;

    end else if (P[CurPos] = ',') then begin
      if nBraces = 0 then
        Inc(nCommas);
    end;

    Dec(CurPos);
    if CurPos < 1 then
      break;
  end;

  // If we couldn't find the opening brace or reached the FMaxScanLength
  if (nBraces <> -1) then begin // -1 means found it
    ReleaseHandle;
    Exit;
  end;

  FFunctionStart := CurPos;

  // If the caret is at or before the opening '(', the cursor is not inside
  // the function argument list (e.g. in the function name, in whitespace
  // before the call, or on a previous line) — hide the tooltip.
  // This is the symmetric counterpart of the CaretPos > FFunctionEnd check above.
  if CaretPos <= FFunctionStart then begin
    ReleaseHandle;
    Exit;
  end;

  // Skip blanks
  while (CurPos > 1) and ((P[CurPos - 1] = #32) or (P[CurPos - 1] = #9) or (P[CurPos - 1] = #13) or (P[CurPos - 1] = #10)) do
    Dec(CurPos);

  // ATSynEdit: walk backward from CurPos to extract the function name
  // (replaces StrPosToCaretPos + GetWordAtCaretPos)
  S := '';
  I := CurPos;
  while I > 1 do begin
    if Ord(P[I - 1]) > 255 then Break;
    if not Identifiers[Chr(Ord(P[I - 1]))] then Break;
    S := Chr(Ord(P[I - 1])) + S;
    Dec(I);
  end;

  // Don't bother scanning the database when there's no identifier to scan for
  // ATSynEdit: skip highlighter attribute check since API differs from SynEdit.
  // Parser will validate the token anyway.
  if S = '' then begin
    ReleaseHandle;
    Exit;
  end;

  // Only do the cumbersome list filling when showing a new tooltip...
  if (S <> FOldFunction) or not Activated then begin
    FSelIndex := 0;
    FCustomSelIndex := False;

    // Fill a cache of known functions...
    FToolTips.BeginUpdate;
    FToolTips.Clear;
    FParser.FillListOfFunctions(S, FToolTips);
    FToolTips.EndUpdate;
  end;

  // If we can't find it in our database, hide
  if FToolTips.Count = 0 then begin
    ReleaseHandle;
    Exit;
  end;

  FOldFunction := S;

  // get the current token position in the text
  // this is where the prototype name usually starts
  FTokenPos := CurPos - Length(S);

  // Search for the best possible overload match according to comma count
  if (shoFindBestMatchingToolTip in FOptions) then

    // Only do so when the user didn't select his own
    if not FCustomSelIndex then
      S := FindClosestToolTip(S, nCommas);

  // Select the current one
  if (FSelIndex < FToolTips.Count) then
    S := FToolTips.Strings[FSelIndex];

  // set the hint caption
  S := Trim(S);

  S := StringReplace(S, '__cdecl ', '', [rfReplaceAll]);
  S := StringReplace(S, '__stdcall ', '', [rfReplaceAll]);
  S := StringReplace(S, '_CRTIMP ', '', [rfReplaceAll]);  //C Run Rime IMPlement
  S := StringReplace(S, '_GLIBCXX_CONSTEXPR ', '', [rfReplaceAll]); //Macros for CONSTEXPR

  S := StringReplace(S, ' __', ' ', [rfReplaceAll]);
  S := StringReplace(S, ' _', ' ', [rfReplaceAll]);
  S := StringReplace(S, 'public ', '', [rfReplaceAll]);


  // we use the LookupEditor to get the highlighter-attributes
  // from. check the DrawAdvanced method!
  Caption := S;
  FLookupEditor.Text := UnicodeString(Caption);
  FLookupEditor.AdapterForHilite := FEditor.AdapterForHilite;

  // get the index of the current argument (where the cursor is)
  FCurParamIndex := GetCommaIndex(P, FFunctionStart + 1, CaretPos - 1);
  RethinkCoordAndActivate;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCodeToolTip.WMNCHitTest(var Message: TWMNCHitTest);
var
  Pt: TPoint;
begin
  Message.Result := HTTRANSPARENT;
  Pt := ScreenToClient(Point(Message.XPos, Message.YPos));

  // hitcheck against the position of our both buttons
  if PtInRect(FUpButton.ClientRect, Pt) or PtInRect(FDownButton.ClientRect, Pt) then
    Message.Result := HTCLIENT;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCodeToolTip.WMEraseBkgnd(var Message: TWMEraseBkgnd);
// override WMEraseBkgnd to avoid flickering
begin
  Message.Result := 1;
end;

//----------------------------------------------------------------------------------------------------------------------

initialization
  MakeIdentTable;

end.

