unit HomepageFrm;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Version, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  UpdateCheck;

type

  { THomepageForm }

  THomepageForm = class(TForm)
    bvCompilers: TBevel;
    lblError: TLabel;
    lblVersion: TLabel;
    lblBuild: TLabel;
    lblFound: TLabel;
    lblNewVersion: TLabel;
    btnGitee: TButton;
    btnGitcode: TButton;
    btnGithub: TButton;
    btnSf: TButton;
    btnOk: TBitBtn;
    btnCheckUpdate: TButton;
    chkAutoCheck: TCheckBox;
    timerCheckUpdate: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure btnGiteeClick(Sender: TObject);
    procedure btnGitcodeClick(Sender: TObject);
    procedure btnGithubClick(Sender: TObject);
    procedure btnSfClick(Sender: TObject);
    procedure btnCheckUpdateClick(Sender: TObject);
    procedure timerCheckUpdateTimer(Sender: TObject);
    procedure chkAutoCheckClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    fUpdateChecker: TUpdateChecker;
    fAutoCheckUpdate: boolean;
    procedure LoadText;
  public
    { Public declarations }
    property UpdateChecker: TUpdateChecker read fUpdateChecker write fUpdateChecker;
    property AutoCheckUpdate: boolean read fAutoCheckUpdate write fAutoCheckUpdate;
  end;

var
  HomepageForm: THomepageForm;

implementation

uses
  devcfg, Utils, MultiLangSupport;

{$R *.lfm}

procedure THomepageForm.btnSfClick(Sender: TObject);
begin
    OpenURL(PChar('https://sourceforge.net/projects/devcpp20/')); { *ת����ShellExecute* }
end;

procedure THomepageForm.chkAutoCheckClick(Sender: TObject);
begin
  AutoCheckUpdate := chkAutoCheck.Checked;
end;

procedure THomepageForm.btnGiteeClick(Sender: TObject);
begin
  OpenURL(PChar('https://gitee.com/devcpp/devcpp/')); { *ת����ShellExecute* }
end;

procedure THomepageForm.btnGitcodeClick(Sender: TObject);
begin
  OpenURL(PChar('https://gitcode.com/devcpp/devcpp/')); { *ת����ShellExecute* }
end;

procedure THomepageForm.btnGithubClick(Sender: TObject);
begin
    OpenURL(PChar('https://anbangli.github.io/XiaoLoong-DevCpp/')); { *ת����ShellExecute* }
end;

procedure THomepageForm.LoadText;
begin
  Font.Name := devData.InterfaceFont;
  Font.Size := devData.InterfaceFontSize;
  lblVersion.Font.Size := devData.InterfaceFontSize + 2;

  Caption := Lang[ID_PROGRAM];
  lblVersion.Caption := Lang[ID_PROGRAM];
  lblBuild.Caption := Lang[ID_HP_BUILDTIME];
  lblFound.Caption := Lang[ID_HP_VERSIONINFO];
  chkAutoCheck.Caption := Lang[ID_HP_AUTOCHECK];
  btnCheckUpdate.Caption := Lang[ID_HP_CHECKUPDATE];
  lblError.Caption := Lang[ID_HP_ERROR];

  btnGitee.Caption := Lang[ID_HP_GITEE];
  btnGitcode.Caption := Lang[ID_HP_GITCODE];
  btnGithub.Caption := Lang[ID_HP_GITHUB];
  btnSf.Caption := Lang[ID_HP_SF];
  btnOk.Caption := Lang[ID_BTN_OK];

end;


procedure THomepageForm.FormCreate(Sender: TObject);
var
  datestring: String;
begin
  LoadText;

  // Use modified time, not the PE headers
  datestring := GetBuildTime(ParamStr(0));
  lblVersion.Caption := lblVersion.Caption + ' ' + DEVCPP_VERSION;
  lblBuild.Caption := lblBuild.Caption + ' ' + datestring;

  lblNewVersion.Caption := '';
  AutoCheckUpdate := true;
  timerCheckUpdate.Enabled := false;
  timerCheckUpdate.Interval := 1000;

end;

procedure THomepageForm.FormShow(Sender: TObject);
var
  ExeDir: string;
  HasSSL: Boolean;
begin
  ExeDir := ExtractFilePath(ParamStr(0));
  HasSSL := FileExists(ExeDir + 'libcrypto-1_1-x64.dll') and
            FileExists(ExeDir + 'libssl-1_1-x64.dll');

  if not HasSSL then
  begin
    chkAutoCheck.Checked := False;
    chkAutoCheck.Enabled := False;
    chkAutoCheck.visible := False;
    btnCheckUpdate.Enabled := False;

    lblFound.visible := False;
    lblNewVersion.visible := False;
    lblError.visible := True;

    lblNewVersion.Caption := '';
    chkAutoCheck.visible := False;
    timerCheckUpdate.Enabled := False;
    Exit;
  end;

  chkAutoCheck.Checked := AutoCheckUpdate;
  timerCheckUpdate.Enabled := true;
end;

procedure THomepageForm.timerCheckUpdateTimer(Sender: TObject);
begin
  timerCheckUpdate.Enabled := false;
  btnCheckUpdateClick(Self);
end;

procedure THomepageForm.btnCheckUpdateClick(Sender: TObject);
var
  url: string;
begin
  lblFound.Caption := Lang[ID_HP_CHECKING];

  lblNewVersion.Caption := '';
  lblFound.Refresh;

  fUpdateChecker := TUpdateChecker.Create(DEVCPP_VERSION);
  try
    fUpdateChecker.LatestVersion := UpdateChecker.GetLatestReleaseVersionGitee();
    url := 'https://gitee.com/devcpp/devcpp/releases';

    if fUpdateChecker.LatestVersion = '' then
    begin
      lblFound.Caption := Lang[ID_HP_CHECKERROR];
      lblNewVersion.Caption := '';
      fUpdateChecker.LatestVersion := UpdateChecker.GetLatestReleaseVersionGitCode();
      url := 'https://gitcode.com/devcpp/devcpp/releases';
    end;

    if (fUpdateChecker.LatestVersion <> '') and (CompareText(fUpdateChecker.LatestVersion, 'v'+DEVCPP_VERSION) > 0) then
    begin
      lblFound.Caption := Lang[ID_HP_FOUNDNEW];
      lblNewVersion.Caption := fUpdateChecker.LatestVersion;

      if MessageDlg(Lang[ID_HP_GOTODOWNLOAD], mtInformation, [mbYes, mbNo], 0) = mrYes then
      begin
        // ���������ת������ҳ��
         OpenDocument(PChar(url)); { *ת����ShellExecute* }
      end;
    end
    else
    begin
        lblFound.Caption := Lang[ID_HP_LATESTVER];  //ShowMessage('');
        lblNewVersion.Caption := '';
    end;

  finally
    UpdateChecker.Free;
  end;
end;


end.
