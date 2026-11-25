unit FileEncodingFrm;

{$MODE Delphi}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TFileEncodingForm }

  TFileEncodingForm = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    cmbFiles: TComboBox;
    lblFileName: TLabel;
    lblEncoding: TLabel;
    lblEol: TLabel;
    listEncoding: TListBox;
    listEolSymbol: TListBox;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure LoadText;
  public

  end;

var
  FileEncodingForm: TFileEncodingForm;

implementation

uses
  MultiLangSupport, devcfg;
{$R *.lfm}

{ TFileEncodingForm }

procedure TFileEncodingForm.btnOKClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TFileEncodingForm.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFileEncodingForm.FormCreate(Sender: TObject);
begin
  LoadText;
end;

procedure TFileEncodingForm.LoadText;
begin
  // Set interface font
  Font.Name := devData.InterfaceFont;
  Font.Size := devData.InterfaceFontSize;

  Caption := Lang[ID_ENCODE_ENCODE];
  lblFileName.Caption := Lang[ID_PROPS_FILENAME] + ':';
  lblEncoding.Caption := Lang[ID_ENCODE_ENCODE] + ':';
  lblEol.Caption := Lang[ID_ENCODE_EOL] + ':';

  btnOK.Caption := Lang[ID_BTN_OK];
  btnCancel.Caption := Lang[ID_BTN_CANCEL];


end;

end.
