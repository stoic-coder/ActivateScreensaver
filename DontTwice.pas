unit DontTwice;

interface

implementation

uses
  Winapi.Windows, Dialogs,Registry,Winapi.TlHelp32, Winapi.Messages, System.SysUtils, System.Variants;
var
  mHandle: THandle; // Mutexhandle
  exename: string;

const
  MoveMouseName: string = 'Move Mouse.exe';

function IsProgramRunning(const AProcessName: string): Boolean;
var
  SnapshotHandle: THandle;
  ProcessEntry: TProcessEntry32;
  ProcessFound: Boolean;
begin
  Result := False;  // Assume the process is not running at first
  SnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);  // Take a snapshot of all the processes
  if SnapshotHandle = INVALID_HANDLE_VALUE then
    raise Exception.Create('Failed to create process snapshot');

  try
    ProcessEntry.dwSize := SizeOf(TProcessEntry32);  // Initialize the ProcessEntry structure

    ProcessFound := Process32First(SnapshotHandle, ProcessEntry);  // Get the first process
    while ProcessFound do
    begin
      // Compare the process name with the one we are looking for (case-insensitive)
      if SameText(ExtractFileName(ProcessEntry.szExeFile), AProcessName) then
      begin
        Result := True;  // If found, set Result to True
        Break;           // Exit the loop, no need to continue
      end;
      ProcessFound := Process32Next(SnapshotHandle, ProcessEntry);  // Move to the next process
    end;

  finally
    CloseHandle(SnapshotHandle);  // Always release the snapshot handle when done
  end;
end;

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
  if IsProgramRunning(MoveMouseName) then Halt;
  

finalization // ... und Schluﬂ
  if mHandle <> 0 then
    CloseHandle(mHandle)
end.
