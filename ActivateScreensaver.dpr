program ActivateScreensaver;

uses
  Vcl.Forms,
  main in 'main.pas' {FormMain},
  DontTwice in 'DontTwice.pas',
  modal in 'modal.pas' {FormModal},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Ruby Graphite');
  Application.Title := 'ActivateScreensave';
  Application.CreateForm(TFormModal, FormModal);
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
