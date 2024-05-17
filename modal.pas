unit modal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TFormModal = class(TForm)
    LabelCounter: TLabel;
    ButtonCancelQuit: TButton;
    procedure ButtonCancelQuitClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ThreadCounterOnTerminate(Sender: TObject);
  end;

  TThreadCounter = class(TTHread)
  private
    FCounter: Integer;
    FIsCanceled: Boolean;
    FOnTerminate: TNotifyEvent;
    procedure SetCounter(const Value: Integer);
  protected
    procedure Execute; override;
    property Counter: Integer read FCounter write SetCounter;
  public
    constructor Create;
    procedure CancelThread;
    property IsCanceled: Boolean read FIsCanceled write FIsCanceled;
  end;

var
  FormModal: TFormModal;
  ThreadCounter: TThreadCounter;
  IsCanceled: Boolean;

implementation

{$R *.dfm}

constructor TThreadCounter.Create;
begin
  IsCanceled := false;
  inherited Create(false);
  Priority := tpNormal;
  OnTerminate := FormModal.ThreadCounterOnTerminate;
  FreeOnTerminate := true;
end;

procedure TThreadCounter.CancelThread;
begin
  IsCanceled := true;
end;

procedure TThreadCounter.Execute;
var
  I, K: Integer;
begin
  inherited;
  for I := 1 to 10 do
  begin
    if IsCanceled then
      break;
    SetCounter(I);
    Synchronize(
      procedure
      begin
        FormModal.LabelCounter.Caption := 'In ' + (10 - I).ToString +
          ' Sekunden wird der Bildschirmschoner aktiviert!';
        FormModal.Refresh;
      end);
    for K := 0 to 9 do
    begin
      if IsCanceled then
        break;
      Sleep(100);
    end;
  end;
  if not IsCanceled then
  begin
    DefWindowProc(FormModal.Handle, WM_SYSCOMMAND, SC_SCREENSAVE, 0);
  end;
  Terminate;
end;

procedure TThreadCounter.SetCounter(const Value: Integer);
begin
  FCounter := Value;
end;

procedure TFormModal.ButtonCancelQuitClick(Sender: TObject);
begin
  ThreadCounter.CancelThread;
end;

procedure TFormModal.FormShow(Sender: TObject);
begin
  ThreadCounter := TThreadCounter.Create;
end;

procedure TFormModal.ThreadCounterOnTerminate(Sender: TObject);
begin
  Close;
end;

end.
