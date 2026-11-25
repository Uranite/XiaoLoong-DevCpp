program CodeDiff;

{$mode delphi}{$H+}

{$R *.res}   // CodeDiff.res: XP manifest + MAINICON (16/24/32 px)

uses
  Interfaces,
  Forms,
  Unit1 in 'Unit1.pas' {Form1};

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
