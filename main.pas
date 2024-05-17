unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls;

type
  TFormMain = class(TForm)
    MainMenu: TMainMenu;
    MenuFile: TMenuItem;
    MenuExit: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure MenuExitClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

uses modal;

procedure pause(zeit: longint);

var
  z1: longint;

begin
  z1 := GetTickCount;
  repeat
    Application.ProcessMessages
  until (GetTickCount - z1 > zeit);
end;

{$R *.dfm}

procedure TFormMain.FormShow(Sender: TObject);
begin
  FormModal.Show;
end;

procedure TFormMain.MenuExitClick(Sender: TObject);
begin
  Close;
end;

end.
