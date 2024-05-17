unit DontTwice;

interface

implementation

uses windows, Dialogs, sysutils;

var
  mHandle: THandle; // Mutexhandle
  exename: string;

initialization
  exename := ExtractFileName(ParamStr(0));
  mHandle := CreateMutex(nil, True, PWideChar(exename));
  // 'xxxxx' Der Anwendungsname ist hier einzutragen
  if GetLastError = ERROR_ALREADY_EXISTS then begin
    // Anwendung l‰uft bereits
    Beep;
    showMessage(exename  + ' l‰uft bereits!');
    // Wenn du deine Meldung willst, mach die Klammern weg
    Halt;
  end;

finalization // ... und Schluﬂ
  if mHandle <> 0 then
    CloseHandle(mHandle)
end.
