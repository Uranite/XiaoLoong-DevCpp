unit ShortcutsFrm;

interface

uses
{$IFDEF MSWINDOWS}
  {$IFDEF MSWINDOWS}Windows{$ELSE}LCLIntf, LCLType{$ENDIF},
{$ENDIF}
  SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls,
  ComCtrls, StdCtrls, Menus, ActnList, Buttons, IniFiles, Grids;

type
  TShortCutItem = record
    Default: TShortCut;
    Temporary: TShortCut; // we can't use UI strings to store temp shortcuts (not one to one), so use this instead
    IniEntry: String; // name in ini file, use untranslated MenuItem.Caption
    ListEntry: String; // name in editor form
    MenuItem: TMenuItem; // apply Current to this
    Action: TAction; // OR this
  end;
  PShortCutItem = ^TShortCutItem;

//  TdevShortcuts = class(TComponent)
  TdevShortcuts = class
  private
    fOwner: TComponent;
    fFilename: TFileName;
    fShortcuts: TList;
    //function GetItemDescription(Item: TMenuItem): String;
  public
    constructor Create(AOwner: TComponent); //override;
    destructor Destroy; override;
    procedure Load(List: TActionList);
//    procedure Edit(const WindowCaption, Column1, Column2, Tip, OK, Cancel, ResetAll, ResetCurrent, ReplaceHint,
//      ResetAllConfirm, ResetCurrentConfirm, Button: String);
    procedure Save;
    function GetItemDescription(Item: TMenuItem): String;
  //published

    property Filename: TFilename read fFilename write fFilename;
    property Shtcuts: TList read fShortcuts write fShortcuts;
  end;

  { TShortcutsForm }

  TShortcutsForm = class(TForm)
    btnCancel: TBitBtn;
    btnOk: TBitBtn;
    lvShortcuts: TStringGrid;
    btnResetAll: TButton;
    lblTip: TLabel;
    btnResetCurrent: TButton;
    PanelGround: TPanel;

    procedure FormCreate(Sender: TObject);

    procedure lvShortcutsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lvShortcutsPrepareCanvas(Sender: TObject; Col, Row: Integer;
      AState: TGridDrawState);
    procedure lvShortcutsExit(Sender: TObject);
    procedure lvShortcutsTopLeftChanged(Sender: TObject);

    procedure btnResetAllClick(Sender: TObject);
    procedure btnResetCurrentClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
    fReplaceHint: String;
    fResetAllConfirm: String;
    fResetCurrentConfirm: String;
    function GetShortCut(Index: integer): PShortCutItem;
    procedure LoadText;
  public
    { Public declarations }
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure AddShortcut(Item: PShortcutItem);
    procedure Clear;
    function Count: integer;
    property ShortCuts[Index: integer]: PShortCutItem read GetShortCut;
  end;

var
  ShortcutsForm: TShortcutsForm;

implementation

uses
  MultiLangSupport, devcfg, LCLProc;

{$R *.lfm}

function SafeShortCutToText(ShortCut: TShortCut): string;
begin
  if ShortCut = 0 then
    Result := ''
  else
    Result := ShortCutToText(ShortCut);
end;

constructor TdevShortcuts.Create(AOwner: TComponent);
begin
  //inherited;
  fOwner := AOwner;
  fFileName := 'shortcuts.ini'; // DEV_SHORTCUTS_FILE
  fShortcuts := TList.Create;

end;

destructor TdevShortcuts.Destroy;
var
  I: integer;
begin
  for I := 0 to fShortcuts.Count - 1 do
    Dispose(PShortcutItem(fShortcuts[i]));
  fShortcuts.Free;
  inherited;
end;

function TdevShortcuts.GetItemDescription(Item: TMenuItem): String;
var
  ParentItem: TMenuItem;
begin
  Result := StripHotkey(Item.Caption);
  ParentItem := Item.Parent;
  while ParentItem <> nil do begin
    if ParentItem.Caption <> '' then // menu roots node have no caption
      Result := StripHotkey(ParentItem.Caption) + ' > ' + Result
    else begin
      Result := ParentItem.GetParentMenu.Name + ' > ' + Result;
      Exit;
    end;
    ParentItem := ParentItem.Parent;
  end;
end;

procedure TdevShortcuts.Load(List: TActionList);
var
  I, intvalue: integer;
  Fini: TIniFile;
  value: String;
  ShortCut: TShortCut;
  item: PShortcutItem;
  MenuItem: TMenuItem;
  Actions: TStringList;
  Action: TAction;
begin
  if fOwner = nil then
    Exit;

  // Create a list of all menu items that, UNTRANSLATED!
  Actions := TStringList.Create;
  try

    // Add all main menu items...
    for I := 0 to fOwner.ComponentCount - 1 do begin
      // only accept menu items (not only the main menu, but popup menus too)
      if not (fOwner.Components[I] is TMenuItem) then
        Continue;

      // don't process foldouts and separators and grayed/disabled menu items
      MenuItem := TMenuItem(fOwner.Components[I]);
      if MenuItem.IsLine or (MenuItem.Count <> 0) or (not MenuItem.Enabled) then
        Continue;

      // Don't add if the main menu counterpart or their action has been added
      if Assigned(MenuItem.Action) and (Actions.IndexOf(MenuItem.Action.Name) <> -1) then
        Continue;

      item := new(PShortcutItem);
      item^.Default := MenuItem.ShortCut;
      item^.Temporary := MenuItem.ShortCut;
      item^.IniEntry := GetItemDescription(MenuItem);
      item^.ListEntry := ''; // to be filled by form (translated)
      item^.MenuItem := MenuItem;
      item^.Action := TAction(MenuItem.Action);
      fShortcuts.Add(item);

      // Store action of main menu item, and don't create duplicates for popup menu items with the same action
      if Assigned(MenuItem.Action) then
        Actions.Add(MenuItem.Action.Name);
    end;

    // Lastly, add actions without a menu item
    for I := 0 to List.ActionCount - 1 do begin
      Action := TAction(List.Actions[i]);
      if (Actions.IndexOf(Action.Name) <> -1) or (not Action.Enabled) then
        Continue; // skip actions already added via menu item
      item := new(PShortcutItem);
      item^.Default := Action.ShortCut;
      item^.Temporary := Action.ShortCut;
      item^.IniEntry := Action.Caption;
      item^.ListEntry := ''; // to be filled by form (translated)
      item^.MenuItem := nil;
      item^.Action := Action;
      fShortcuts.Add(item);
    end;
  finally
    Actions.Free;
  end;

  if (fFileName = '') or not FileExists(fFileName) then
    Exit;

  // For each menu item in our list, read the shortcut from disk
  Fini := TIniFile.Create(fFileName);
  try
    for I := 0 to fShortcuts.Count - 1 do begin
      item := PShortCutItem(fShortcuts[i]);

      // Read shortcut, assume ini file is untranslated
      value := Fini.ReadString('Shortcuts', item^.IniEntry, '');
      if (value <> '') then begin // only apply when found in file

        // New format: unsigned int value
        intvalue := StrToIntDef(value, High(ShortCut) + 1);
        if intvalue = High(ShortCut) + 1 then // old format...
          shortcut := TextToShortCut(value)
        else // new format
          shortcut := intvalue;

        // Apply to Menu
        if Assigned(item^.MenuItem) then
          item^.MenuItem.ShortCut := shortcut;

        // Apply to action
        if Assigned(item^.Action) then
          item^.Action.ShortCut := shortcut;

        // Store shortcut in int format
        item^.Temporary := shortcut;
      end;
    end;
  finally
    Fini.Free;
  end;
end;

procedure TdevShortcuts.Save;
var
  I: integer;
  Fini: TIniFile;
  entry, value: String;
  item: PShortcutItem;
begin
  if fFileName = '' then
    Exit;

  Fini := TIniFile.Create(fFileName);
  try
      for I := 0 to fShortcuts.Count - 1 do begin
        item := PShortCutItem(fShortcuts[i]);
        entry := item^.IniEntry;
        value := '';

        if Assigned(item^.MenuItem) then  // Apply to Menu
          value := IntToStr(item^.MenuItem.ShortCut);

        if Assigned(item^.Action) then   // Apply to action
          value := IntToStr(item^.Action.ShortCut);

        // Save untranslated
        Fini.WriteString('Shortcuts', entry, value);
      end;
  finally
    Fini.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////





procedure TShortcutsForm.FormCreate(Sender: TObject);
begin
  //ensure lvShortcuts.ColCount = 2
  while lvShortcuts.ColCount < 2 do
    lvShortcuts.Columns.Add;
  while lvShortcuts.ColCount > 2 do
    lvShortcuts.Columns.Delete(lvShortcuts.Columns.Count - 1);

  // Remove designer's placeholder rows, keep only the fixed header row
  while lvShortcuts.RowCount > 1 do
    lvShortcuts.DeleteRow(1);

  lvShortcuts.FixedRows := 1;
  // goSmoothScroll enables smooth scroll repaint (reduces lag on thumb drag)
  // (already set in .lfm: goSmoothScroll in Options)

  lvShortcuts.DoubleBuffered := False; // disable: scrollbar drag not updating with double buffer
  lvShortcuts.DefaultRowHeight := Round(lvShortcuts.DefaultRowHeight * 1.25);
  LoadText;
end;

procedure TShortcutsForm.LoadText;
begin
  // Set interface font
  Font.Name := devData.InterfaceFont;
  Font.Size := devData.InterfaceFontSize;


  Caption := Lang[ID_SC_CAPTION]; // window
  lvShortcuts.Columns[0].Title.Caption := Lang[ID_SC_HDRENTRY]; // column 1
  lvShortcuts.Columns[0].Width := 330;
  lvShortcuts.Columns[1].Title.Caption := Lang[ID_SC_HDRSHORTCUT]; // column 2
  lvShortcuts.Columns[1].Width := 110;

  lblTip.Caption := Lang[ID_SC_NEWTIP]; // hint
  btnOk.Caption := Lang[ID_BTN_OK]; // OK button
  btnCancel.Caption := Lang[ID_BTN_CANCEL]; // Cancel button
  btnResetAll.Caption := Lang[ID_SC_RESETALL]; // Reset All button
  btnResetCurrent.Caption := Lang[ID_SC_RESETCURRENT]; // Reset Current button

  fReplaceHint := Lang[ID_SC_NEWREPLACEHINT]; // messagebox text when replacing
  fResetAllConfirm := Lang[ID_SC_CONFIRMALL]; // messagebox text when setting to defaults
  fResetCurrentConfirm := Lang[ID_SC_CONFIRMONE]; // messagebox text when setting to defaults
    //Lang[ID_SC_BUTTON]); // Button/Misc
end;

procedure TShortcutsForm.BeginUpdate;
begin
  lvShortcuts.BeginUpdate;
end;

procedure TShortcutsForm.EndUpdate;
begin
  lvShortcuts.EndUpdate;
end;

procedure TShortcutsForm.AddShortcut(Item: PShortcutItem);
var
  Row: Integer;
  ShortCutText: String;
begin
  Row := lvShortcuts.RowCount;
  lvShortcuts.RowCount := Row + 1;
  lvShortcuts.Cells[0, Row] := Item^.ListEntry;

  if Assigned(item^.MenuItem) then
    ShortCutText := SafeShortCutToText(Item^.MenuItem.ShortCut)
  else if Assigned(item^.Action) then
    ShortCutText := SafeShortCutToText(Item^.Action.ShortCut)
  else
    ShortCutText := '';
  lvShortcuts.Cells[1, Row] := ShortCutText;

  // Store pointer to PShortCutItem in row's Objects
  lvShortcuts.Objects[0, Row] := TObject(Item);
end;

procedure TShortcutsForm.Clear;
begin
  lvShortcuts.RowCount := 1; // keep fixed row only
  lvShortcuts.Clean(0, 1, 1, 0, [gzNormal]); // clear content below fixed row
end;


function TShortcutsForm.Count: integer;
begin
  Result := lvShortcuts.RowCount - 1; // exclude fixed row
end;

function TShortcutsForm.GetShortCut(Index: integer): PShortCutItem;
begin
  Result := PShortCutItem(lvShortcuts.Objects[0, Index + 1]); // +1 for fixed row
end;

procedure TShortcutsForm.lvShortcutsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  I, oldindex, selRow: integer;
  IntShortCut: TShortCut;
  RowCaption: String;

  // Handy macro. Please use
  procedure SetShortCut(Row: integer; ShortCut: integer);
  begin
    lvShortcuts.Cells[1, Row] := SafeShortCutToText(ShortCut);
    PShortCutItem(lvShortcuts.Objects[0, Row])^.Temporary := IntShortCut;
  end;
begin
  selRow := lvShortcuts.Row;
  // Require a selection (Row < 1 means fixed row or nothing)
  if selRow < 1 then
    Exit;

  // clear shortcut if ONLY Escape or Del is pressed
  if (Key in [VK_ESCAPE, VK_DELETE]) and (Shift = []) then begin
    SetShortCut(selRow, 0);
    Exit;
  end;

  // Don't accept alt shiftstate (messes up menu interaction)
  if (Shift = [ssAlt]) then
    Exit;

  // Require a key combination when using 'normal' keys
  if (Shift = []) and ((Key < VK_F1) or (Key > VK_F24)) then
    Exit; // ... but allow F keys

  // Don't accept shift state keys as main keys
  if (Key in [VK_SHIFT, VK_CONTROL, VK_MENU]) then // VK_MENU is the alt key
    Exit;

  IntShortCut := ShortCut(Key, Shift);

  oldindex := -1;
  for I := 1 to lvShortcuts.RowCount - 1 do begin

    // Don't scan popups, they can contain duplicate shortcuts (they're picked based on focus)
    if (I <> selRow) then begin
      RowCaption := lvShortcuts.Cells[0, I];
      if Pos('Popup', RowCaption) = 0 then
        if PShortCutItem(lvShortcuts.Objects[0, I])^.Temporary = IntShortCut then begin
          oldindex := I;
          break;
        end;
    end;
  end;

  // Can be written in a more compact form, but I prefer readability
  if oldindex <> -1 then begin // already in use
    if MessageDlg(Format(fReplaceHint, [lvShortcuts.Cells[0, oldindex],
      lvShortcuts.Cells[0, selRow]]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
      SetShortCut(oldindex, 0); // remove old
      SetShortCut(selRow, IntShortCut); // set new
    end;
  end else
    SetShortCut(selRow, IntShortCut); // set new

  // don't let the keystroke propagate...
  Key := 0;
end;

procedure TShortcutsForm.lvShortcutsPrepareCanvas(Sender: TObject; Col, Row: Integer;
  AState: TGridDrawState);
begin
  if not (gdSelected in AState) then begin
    if (Row mod 2) = 0 then
      lvShortcuts.Brush.Color := clWindow
    else
      lvShortcuts.Brush.Color := $E0E0E0;
  end;
end;

procedure TShortcutsForm.lvShortcutsTopLeftChanged(Sender: TObject);
begin
  // Force repaint on scrollbar drag (LCL TStringGrid does not repaint during thumb drag)
  lvShortcuts.Invalidate;
end;

procedure TShortcutsForm.lvShortcutsExit(Sender: TObject);
var
  key: word;
  shift: TShiftState;
  State: TKeyboardState;
begin
  shift := [];
  // Don't let Tab and Alt combinations escape
  if (GetKeyState(VK_TAB) < 0) then
    key := VK_TAB
      //  else if (GetKeyState(VK_MENU) < 0) then
//    key := VK_MENU
  else
    Exit;

  // Get shift state
  State := default(TKeyboardState);
  GetKeyboardState(State);
  if ((State[vk_Control] and 128) <> 0) then
    shift := shift + [ssCtrl];
  if ((State[vk_Menu] and 128) <> 0) then
    shift := shift + [ssAlt];
  if ((State[vk_Shift] and 128) <> 0) then
    shift := shift + [ssShift];

  lvShortcutsKeyDown(Self, key, Shift);

  lvShortcuts.SetFocus; // retain focus!
end;

procedure TShortcutsForm.btnOkClick(Sender: TObject);
begin
//
end;

procedure TShortcutsForm.btnResetAllClick(Sender: TObject);
var
  I: integer;
  Item: PShortCutItem;
begin
  if MessageDlg(fResetAllConfirm, mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
    lvShortcuts.BeginUpdate;
    try
      for I := 1 to lvShortcuts.RowCount - 1 do begin
        Item := PShortCutItem(lvShortcuts.Objects[0, I]);
        Item^.Temporary := Item^.Default;
        lvShortcuts.Cells[1, I] := SafeShortCutToText(Item^.Temporary);
      end;
    finally
      lvShortcuts.EndUpdate;
    end;
  end;
end;



procedure TShortcutsForm.btnResetCurrentClick(Sender: TObject);
var
  selRow: Integer;
  Item: PShortCutItem;
begin
  selRow := lvShortcuts.Row;
  if selRow < 1 then
    Exit;

  // Replace selection
  if MessageDlg(Format(fResetCurrentConfirm, [lvShortcuts.Cells[0, selRow]]), mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then begin
    Item := PShortCutItem(lvShortcuts.Objects[0, selRow]);
    Item^.Temporary := Item^.Default;
    lvShortcuts.Cells[1, selRow] := SafeShortCutToText(Item^.Temporary);
  end;
end;



end.


