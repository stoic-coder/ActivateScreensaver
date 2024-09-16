unit modal;

interface

uses
  Winapi.Windows, Winapi.TlHelp32, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Registry, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

const
  WM_WTSSESSION_CHANGE = $02B1;
  WTS_SESSION_UNLOCK = 8;

type
  TFormModal = class(TForm)
    LabelCounter: TLabel;
    ButtonCancelQuit: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonCancelQuitClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure WMSessionChange(var Msg: TMessage); message WM_WTSSESSION_CHANGE;
    procedure SetScreensaver(const ScreensaverPath: string; Timeout: Integer;
      Active: Boolean);
    procedure RemoveScreensaver;
    { Private declarations }
  public
    { Public declarations }
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

const

  AeonPath: string = 'c:\Windows\System32\Aeon.scr';
  GForcePath: string = 'c:\Windows\System32\G-Force.scr';
  WhiteCapPath: String = 'c:\Windows\System32\WhiteCap.scr';
  ScreenSaverPathValue: String = 'SCRNSAVE.EXE';

var
  FormModal: TFormModal;
  ThreadCounter: TThreadCounter;
  IsCanceled: Boolean;

implementation

{$R *.dfm}


procedure TFormModal.RemoveScreensaver;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_WRITE);
  try
    // Focus on the key affecting the current user's screensaver settings
    Reg.RootKey := HKEY_CURRENT_USER;

    // Open the registry key for the screensaver settings
    if Reg.OpenKey('\Control Panel\Desktop', False) then
    begin
      Reg.DeleteValue(ScreenSaverPathValue);
      Reg.CloseKey;
    end
    else
      raise Exception.Create
        ('Failed to open registry key for screensaver settings.');

  finally
    // Ensure that the TRegistry instance is cleaned up properly
    Reg.Free;
  end;
end;

procedure TFormModal.SetScreensaver(const ScreensaverPath: string;  Timeout: Integer; Active: Boolean);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_WRITE);
  try
    // Focus on the key affecting the current user's screensaver settings
    Reg.RootKey := HKEY_CURRENT_USER;

    // Open the registry key for the screensaver settings
    if Reg.OpenKey('\Control Panel\Desktop', False) then
    begin
      // Set the path to the screensaver executable (.scr file)
      Reg.WriteString('SCRNSAVE.EXE', ScreensaverPath);

      // Optionally set the idle time (in seconds) before the screensaver activates
      Reg.WriteString('ScreenSaveTimeOut', IntToStr(Timeout));

      // Enable or disable the screensaver (1 = enabled, 0 = disabled)
      if Active then
        Reg.WriteString('ScreenSaveActive', '1')
      else
        Reg.WriteString('ScreenSaveActive', '0');

      // Close the key once the changes are applied
      Reg.CloseKey;

      // Optionally, inform the user of success
      // Writeln('Screensaver settings updated successfully');
    end
    else
      raise Exception.Create
        ('Failed to open registry key for screensaver settings.');

  finally
    // Ensure that the TRegistry instance is cleaned up properly
    Reg.Free;
  end;
end;

constructor TThreadCounter.Create;
begin
  IsCanceled := False;
  inherited Create(False);
  Priority := tpNormal;
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

procedure TFormModal.FormDestroy(Sender: TObject);
begin
  WTSUnRegisterSessionNotification(Handle);
end;

procedure TFormModal.FormCreate(Sender: TObject);
begin
  WTSRegisterSessionNotification(Handle, 0);
end;

procedure TFormModal.ButtonCancelQuitClick(Sender: TObject);
begin
  ThreadCounter.CancelThread;
  ThreadCounter.DoTerminate;
  RemoveScreenSaver;
  Close;
end;

procedure TFormModal.FormShow(Sender: TObject);
begin
  SetScreensaver(GForcePath, 3600, true);
  ThreadCounter := TThreadCounter.Create;
end;

procedure TFormModal.WMSessionChange(var Msg: TMessage);
begin
  // Check for the unlock event
  if Msg.WParam = WTS_SESSION_UNLOCK then
  begin
    RemoveScreensaver;
    Close;
  end;
end;

end.
