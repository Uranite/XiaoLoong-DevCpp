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

unit AddToDoFrm;

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, Spin, MultiLangSupport, devcfg;

type
  TAddToDoForm = class(TForm)
    Label1: TLabel;
    memDescr: TMemo;
    Label2: TLabel;
    Label3: TLabel;
    spnPri: TSpinEdit;
    btnOK: TButton;
    btnCancel: TButton;
    txtUser: TEdit;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure txtUserKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    procedure LoadText;
  public
    { Public declarations }
    fInsertionText: string; // Generated text to insert, set by btnOKClick
  end;

  //var
  //  AddToDoForm: TAddToDoForm;

implementation


{$R *.lfm}

procedure TAddToDoForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
end;

procedure TAddToDoForm.btnOKClick(Sender: TObject);
var
  I: integer;
  Hdr: String;
begin
  Hdr := '/* TODO (';
  if txtUser.Text <> '' then
    Hdr := Hdr + txtUser.Text;
  Hdr := Hdr + '#' + IntToStr(spnPri.Value) + '#): ';

  // Generate the full text to insert
  if memDescr.Lines.Count = 1 then
    fInsertionText := #13#10 + Hdr + memDescr.Text + ' */'
  else begin
    fInsertionText := #13#10 + Hdr + memDescr.Lines[0];
    for I := 1 to memDescr.Lines.Count - 2 do
      fInsertionText := fInsertionText + #13#10 + memDescr.Lines[I];
    if memDescr.Lines.Count > 1 then
      fInsertionText := fInsertionText + #13#10 + memDescr.Lines[memDescr.Lines.Count - 1] + ' */';
  end;

  ModalResult := mrOk;
end;

procedure TAddToDoForm.FormShow(Sender: TObject);
begin
  LoadText;
  memDescr.Clear;
  spnPri.Value := 0;
  txtUser.Clear;
end;

procedure TAddToDoForm.txtUserKeyPress(Sender: TObject; var Key: Char);
begin
  //if not (Key in ['a'..'z', 'A'..'Z', '0'..'9', '_', #8, #13, #27]) then begin
  if not CharInSet(Key, ['a'..'z', 'A'..'Z', '0'..'9', '_', #8, #13, #27]) then begin
    Key := #0;
    Exit;
  end;
end;

procedure TAddToDoForm.LoadText;
begin
  // Set interface font
  Font.Name := devData.InterfaceFont;
  Font.Size := devData.InterfaceFontSize;

  Caption := Lang[ID_ADDTODO_MENUITEM];
  Label1.Caption := Lang[ID_ADDTODO_DESCRIPTION] + ':';
  Label2.Caption := Lang[ID_ADDTODO_PRIORITY] + ':';
  Label3.Caption := Lang[ID_ADDTODO_USER] + ':';
  btnOk.Caption := Lang[ID_BTN_OK];
  btnCancel.Caption := Lang[ID_BTN_CANCEL];
end;

end.

