{*------------------------------------------------------------------------------
  Main Functionality and CLI
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth, TheSelby
------------------------------------------------------------------------------}

{$I compiler.inc}
{$G-}
unit Main;

interface

uses
  API.Win.Winsock2,
  API.Win.NtStatus,
  API.Win.Types,
  API.Win.NtCommon,
  API.Win.Kernel,
  API.Win.NtApi,
  API.Win.GDI,
  API.Win.User,
  Version,
  MapHelp.LibInterface,
  Framework,
  Framework.Configuration,
  Framework.Base,
  Framework.Tick,
  Framework.ThreadManager,
  Framework.LogManager,
  Framework.ErrorHandler,
  Framework.OptimizationManager,
  Components.DataCore,
  Components.NetworkCore,
  Components.GameCore,
  Components.ExtensionCore,
  Components.IoCore,
  Bfg.Compression,
  Bfg.Utils,
  Bfg.Containers,
  Bfg.Geometry,
  Bfg.Threads,
  Resources,
  SysUtils,
  Bfg.SystemInfo,
  Bfg.Unicode,
  Math;

{ Main Running function }
procedure RunYAWEMain;

type
  PNotifyIconData = ^TNotifyIconData;
  TNotifyIconData = record
    cbSize: Longword;
    Wnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array [0..127] of AnsiChar;
    dwState: Longword;
    dwStateMask: Longword;
    szInfo: array [0..255] of AnsiChar;
    uTimeout: UINT;
    szInfoTitle: array [0..63] of AnsiChar;
    dwInfoFlags: Longword;
  end;

function Shell_NotifyIcon(dwMessage: Longword; lpData: PNotifyIconData): BOOL; stdcall;
  external 'shell32.dll' name 'Shell_NotifyIconA';

var
  hConsoleIcon: HICON;
  hInvisibleWindow: HWND;
  tInitData: TWSAData;
  tTrayIconData: TNotifyIconData;
  bInTray: Longbool;
  iWSAError: Integer;
  hMainInstance: HINSTANCE;
  hMainProcess: THandle;
  hMainThread: THandle;
  lwMainProcessId: Longword;
  lwMainThreadId: Longword;
  bShuttingDown: Longbool;
  tShutDown: TEvent;
  sModuleName: string;
  sAppName: string;

implementation

uses
  Components.IoCore.Console,
  Components.IoCore.ErrorManager,
  Classes,
  Cores;

const
  ConsoleTitle = 'YAWE Server';
  WM_SYSTEM_TRAY_MESSAGE = WM_USER * 2; { Message which will notify us of any click on the notificaton icon }

  NIM_ADD         = $00000000;
  NIM_MODIFY      = $00000001;
  NIM_DELETE      = $00000002;

  NIF_MESSAGE     = $00000001;
  NIF_ICON        = $00000002;
  NIF_TIP         = $00000004;

{ WndProc of the invisible window }
function InvisibleWndProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  if (uMsg = WM_SYSTEM_TRAY_MESSAGE) and (lParam = WM_LBUTTONUP) then { User clicked on the tray }
  begin
    Shell_NotifyIcon(NIM_DELETE, @tTrayIconData);  { Delete the tray icon }
    Result := Integer(ShowWindow(IoCore.Console.WindowHandle, SW_SHOW)); { And make the console visible once again }
    SetForegroundWindow(IoCore.Console.WindowHandle); { As an addition, set the focus to our console }
    AtomicDec(@bInTray); { Must use this since it's asynchronous }
  end else if uMsg = WM_QUIT then
  begin
    PostQuitMessage(0);
    Result := 1;
  end else
  begin
    Result := DefWindowProc(hWnd, uMsg, wParam, lParam); { This is a must otherwise it would not work properly }
  end;
end;

const
  { Invisible window prototype }
  DefClass: TWndClass = (
    style: 0;
    lpfnWndProc: @InvisibleWndProc;
    cbClsExtra: 0;
    cbWndExtra: 0;
    hInstance: 0;
    hIcon: 0;
    hCursor: 0;
    hbrBackground: 0;
    lpszMenuName: nil;
    lpszClassName: 'YInvisibleMessageWindow';
  );

procedure InitializeFramework;
var
  Conf: IConfiguration;
begin
  Randomize;

  SysDbg := TExceptionWatcher.Create;
  SysThreadMgr := TThreadManager.Create;
  SysLogger := TLogManager.Create;
  SysEventMgr := TTickGenerator.Create(TICK_LENGTH);
  CreateConfigurationIni(FileNameToOS(WideStringToUTF8(ConfigurationFile)), Conf);
  SysConf := Conf as IConfiguration2;
  SysOptimizer := TOptimizationManager.Create;
end;

procedure FinalizeFramework;
begin
  FreeAndNil(SysOptimizer);
  SysConf := nil;
  FreeAndNil(SysEventMgr);
  FreeAndNil(SysLogger);
  FreeAndNil(SysThreadMgr);
  FreeAndNil(SysDbg);
end;

procedure BoostMainThread;
var
  iPrio: TThreadPriority;
begin
  iPrio := tpHighest;
  ThreadModifyPriority(hMainThread, iPrio, True);
end;

procedure SlowDownMainThread;
var
  iPrio: TThreadPriority;
begin
  iPrio := tpLower;
  ThreadModifyPriority(hMainThread, iPrio, True);
end;

procedure HaltSystem;
begin
  DataCore.Free;
  NetworkCore.Free;
  GameCore.Free;
  ExtensionCore.Free;
  IoCore.Free;

  if iWSAError = 0 then WSACleanup; { If there was no error, do a cleanup }
  
  Writeln(RsExitMsg);
  
  { Destroy the framework, no longer needed }
  FinalizeFramework;
  SlowDownMainThread;
  CloseHandle(hMainProcess);
  CloseHandle(hMainThread);
  Readln;
end;

procedure DisplayCommands(Dummy: Pointer; const Args: array of string);
var
  aCmds: TStringDynArray;
begin
  aCmds := IoCore.Console.EnumCommands;
  IoCore.Console.Writeln('Available console commands:');
  IoCore.Console.WriteLnMultiple(aCmds, []);
end;

procedure ServerTerminate(Dummy: Pointer; const Args: array of string);
begin
  IoCore.Console.ClearCommandHandlers;
  AtomicInc(@bShuttingDown);
  tShutDown.Signal;
end;

procedure CreateTrayIcon(Dummy: Pointer; const Args: array of string);
begin
  if not bInTray then
  begin
    AtomicInc(@bInTray);
    { Got the command to resize the console into a tray }
    ShowWindow(IoCore.Console.WindowHandle, SW_HIDE); { Hide the console window }
    Shell_NotifyIcon(NIM_ADD, @tTrayIconData); { And create the notification icon }
  end;
end;

procedure ShowThreadStatusAll(Dummy: Pointer; const Args: array of string);
const
  ThreadDbgFmtMsg =
    'Name: %s' + #13#10 +
    'ThreadId: %4d' + #13#10 +
    'Creation: %.4d-%.2d-%.2d %.2d:%.2d:%.2d:%.3d'+ #13#10 +
    'Execution: %d %.2d:%.2d:%.2d:%.3d' + #13#10 +
    'Affinity Mask: %2d' + #13#10;
var
  iInt: Int32;
  aThreads: TThreadInfoArray;
  iYear, iMonth, iDay, iHour, iMin, iSec, iMSec: UInt16;
begin
  aThreads := SysThreadMgr.EnumThreadsInfo;
  for iInt := 0 to High(aThreads) do
  begin
    DecodeDate(aThreads[iInt].CreationTime, iYear, iMonth, iDay);
    DecodeTime(aThreads[iInt].CreationTime, iHour, iMin, iSec, iMSec);
    
    Writeln(Format(ThreadDbgFmtMsg, [aThreads[iInt].Name, aThreads[iInt].ThreadId,
      iYear, iMonth, iDay, iHour, iMin, iSec, iMSec,
      aThreads[iInt].ExecutionTime.Days, aThreads[iInt].ExecutionTime.Hours,
      aThreads[iInt].ExecutionTime.Mins, aThreads[iInt].ExecutionTime.Secs,
      aThreads[iInt].ExecutionTime.MSecs, aThreads[iInt].AffinityMask]));
  end;
end;

procedure ShowThreadStatus(Dummy: Pointer; const Args: array of string);
const
  ThreadDbgFmtMsg =
    'Name: %s' + #13#10 +
    'ThreadId: %4d' + #13#10 +
    'Creation: %.4d-%.2d-%.2d %.2d:%.2d:%.2d:%.3d'+ #13#10 +
    'Execution: %d %.2d:%.2d:%.2d:%.3d' + #13#10 +
    'Affinity Mask: %2d' + #13#10;
var
  tThread: TThreadHandleInfo;
  iYear, iMonth, iDay, iHour, iMin, iSec, iMSec: UInt16;
begin
  if Length(Args) = 1 then
  begin
    if SysThreadMgr.GetThreadInfo(Args[0], tThread) then
    begin
      DecodeDate(tThread.CreationTime, iYear, iMonth, iDay);
      DecodeTime(tThread.CreationTime, iHour, iMin, iSec, iMSec);

      IoCore.Console.Writeln(Format(ThreadDbgFmtMsg, [tThread.Name, tThread.ThreadId,
        iYear, iMonth, iDay, iHour, iMin, iSec, iMSec,
        tThread.ExecutionTime.Days, tThread.ExecutionTime.Hours,
        tThread.ExecutionTime.Mins, tThread.ExecutionTime.Secs,
        tThread.ExecutionTime.MSecs, tThread.AffinityMask]));
    end;
  end;
end;

procedure RegisterKeyHandlers;
begin
  IoCore.Console.RegisterCommandHandler('Commands', YConsoleCommandHandler(MakeMethod(@DisplayCommands, nil)));
  IoCore.Console.RegisterCommandHandler('Exit', YConsoleCommandHandler(MakeMethod(@ServerTerminate, nil)));
  IoCore.Console.RegisterCommandHandler('Tray', YConsoleCommandHandler(MakeMethod(@CreateTrayIcon, nil)));
  IoCore.Console.RegisterCommandHandler('DebugThreads', YConsoleCommandHandler(MakeMethod(@ShowThreadStatusAll, nil)));
  IoCore.Console.RegisterCommandHandler('DebugThread', YConsoleCommandHandler(MakeMethod(@ShowThreadStatus, nil)));
end;

function ProcessWindowMessages(Data: PThreadCreateInfo): Longword;
var
  WinMsg: TMsg;
begin
  ThreadPushCleanupRoutine(@ThreadCleanupProc, Data);
  hConsoleIcon := LoadImage(MainInstance, 'CONSOLEICON', IMAGE_ICON, 0, 0,
    LR_DEFAULTCOLOR or LR_DEFAULTSIZE or LR_SHARED); { Get the console icon handle }
  API.Win.User.RegisterClass(DefClass); { Register our window prototype }
  hInvisibleWindow := CreateWindowEx(WS_EX_NOACTIVATE, DefClass.lpszClassName,
    DefClass.lpszClassName, 0, 0, 0, 0, 0, HWND_MESSAGE, 0, hMainInstance, nil);
    { Create the invisible window which will process the messages }

  { Initialize the notify icon structure }
  with tTrayIconData do
  begin
    cbSize := SizeOf(TNotifyIconData);
    Wnd := hInvisibleWindow;
    uID := 0;
    uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
    uCallbackMessage := WM_SYSTEM_TRAY_MESSAGE;
    hIcon := hConsoleIcon;
    szTip := ConsoleTitle;
  end;

  bInTray := False;
  FillChar(WinMsg, SizeOf(WinMsg), 0);

  while not bShuttingDown do
  begin
    while PeekMessage(WinMsg, hInvisibleWindow, 0, 0, PM_REMOVE) do { Process pending messages }
    begin
      TranslateMessage(@WinMsg);
      DispatchMessage(@WinMsg); { Dispatch them to the WndProc }
    end;
    ProcessApcQueue;
    WaitMessage;
  end;

  DestroyWindow(hInvisibleWindow); { Destroy our window }
  API.Win.User.UnregisterClass(DefClass.lpszClassName, MainInstance); { And unregister our class prototype }
  Result := 0;
end;

procedure RunYAWEMain;
const
  PRINT_DELAY_PARTS = 20;
var
  ExecCounter: Int64;
  ThrdData: PThreadCreateInfo;
begin
  hMainInstance := MainInstance;
  hMainProcess := OpenProcess(PROCESS_ALL_ACCESS, True, GetCurrentProcessId);
  hMainThread := OpenThread(THREAD_ALL_ACCESS, True, GetCurrentThreadId);
  lwMainProcessId := GetCurrentProcessId; 
  lwMainThreadId := GetCurrentThreadId;
  sModuleName := ExtractFileName(GetModuleName(hMainInstance));
  sAppName := sModuleName;
  Delete(sAppName, Length(sAppName) - 3, 4);

  SetConsoleTitle(ConsoleTitle); { Sets the name of the application }
  iWSAError := WSAStartup($202, tInitData);

  SetPrecisionMode(pmDouble); { double-precision calculation }

  //------------------------------------------------------------------------------
  // Initialize the framework
  //------------------------------------------------------------------------------
  InitializeFramework;

  //------------------------------------------------------------------------------
  // Optimizing routines
  //------------------------------------------------------------------------------
  SysOptimizer.AddFunctionVariant(@XorBuffers, @XorBuffersMMX, cisMMX);
  SysOptimizer.AddFunctionVariant(@AndBuffers, @AndBuffersMMX, cisMMX);
  SysOptimizer.AddFunctionVariant(@OrBuffers, @OrBuffersMMX, cisMMX);
  SysOptimizer.AddFunctionVariant(@AndNotBuffers, @AndNotBuffersMMX, cisMMX);
  SysOptimizer.AddFunctionVariant(@NotBuffer, @NotBufferMMX, cisMMX);

  SysOptimizer.AddFunctionVariant(@System.Move, @MoveMMX, cisMMX);
  SysOptimizer.AddFunctionVariant(@System.Move, @MoveSSE, cisSSE);
  SysOptimizer.AddFunctionVariant(@System.Move, @MoveSSE2, cisSSE2);
  SysOptimizer.AddFunctionVariant(@System.Move, @MoveSSE3, cisSSE3);

  { And patch it }
  SysOptimizer.PatchFunctions;

  //------------------------------------------------------------------------------
  // Defining the default configuration values
  //------------------------------------------------------------------------------
  (*
  SystemConfiguration.SetDefaultValue('Network', 'LogonPort', CONF_NETWORK_LOGONPORT);
  SystemConfiguration.SetDefaultValue('Network', 'RealmPort', CONF_NETWORK_REALMPORT);
  SystemConfiguration.SetDefaultValue('Network', 'RealmAddress', CONF_NETOWRK_REALM_ADDRESS);
  SystemConfiguration.SetDefaultValue('Network', 'Players', CONF_NETWORK_PLAYERS);
  SystemConfiguration.SetDefaultValue('Network', 'TimeoutDelay', CONF_NETWORK_TIMEOUT_DELAY);
  SystemConfiguration.SetDefaultValue('Network', 'AllowedLocals', CONF_NETWORK_ALLOWED_LOCALS);
  SystemConfiguration.SetDefaultValue('Network', 'BannedIPs', CONF_NETWORK_BANNED_IPS);
  SystemConfiguration.SetDefaultValue('Network', 'ExtraLogonWorkers', CONF_NETWORK_EXTRA_LOGON_WORKERS);
  SystemConfiguration.SetDefaultValue('Network', 'ExtraLogonListeners', CONF_NETWORK_EXTRA_LOGON_LISTENERS);
  SystemConfiguration.SetDefaultValue('Network', 'ExtraRealmWorkers', CONF_NETWORK_EXTRA_REALM_WORKERS);
  SystemConfiguration.SetDefaultValue('Network', 'ExtraRealmListeners', CONF_NETWORK_EXTRA_REALM_LISTENERS);

  SystemConfiguration.SetDefaultValue('Realm', 'Name', CONF_REALM_NAME);
  SystemConfiguration.SetDefaultValue('Realm', 'TimeZone', CONF_REALM_TIMEZONE);
  SystemConfiguration.SetDefaultValue('Realm', 'MOTD', CONF_REALM_MOTD);
  SystemConfiguration.SetDefaultValue('Realm', 'Type', CONF_REALM_TYPE);
  SystemConfiguration.SetDefaultValue('Realm', 'AutoAccount', CONF_REALM_AUTOACCOUNT);
  SystemConfiguration.SetDefaultValue('Realm', 'MaxChars', CONF_REALM_MAXCHARS);

  SystemConfiguration.SetDefaultValue('Data', 'PacketCompressionLevel', CONF_DATA_PACKET_COMPRESSION_LEVEL);
  SystemConfiguration.SetDefaultValue('Data', 'YesPluginDir', CONF_DATA_YES_PLUGIN_DIR);
  SystemConfiguration.SetDefaultValue('Data', 'PatchDir', CONF_DATA_PATCH_DIR);
  SystemConfiguration.SetDefaultValue('Data', 'PatchSpeed', CONF_DATA_PATCH_SPEED);
  SystemConfiguration.SetDefaultValue('Data', 'ServerMapDataDir', CONF_DATA_MAP_DATA_DIR);
  *)

  //------------------------------------------------------------------------------
  // Let's boost the main thread's priority while it loads the DB and stuff.
  //------------------------------------------------------------------------------
  BoostMainThread;

  StartExecutionTimer(ExecCounter);

  //------------------------------------------------------------------------------
  // Loading Configuration
  //------------------------------------------------------------------------------
  SysConf.Load;

  SetGlobalCompressionLevel(SysConf.ReadInteger('Data', 'PacketCompressionLevel', CONF_DATA_PACKET_COMPRESSION_LEVEL));

  SysEventMgr.StartActivity;

  SysEventMgr.Threads[TICK_EXGROUP_DEFAULT].WaitForStart(-1);

  tShutDown.Init(False, False);

  New(ThrdData);
  StartThreadAtAddress(@ProcessWindowMessages, nil, True, ThrdData^);
  ThreadModifyState(ThrdData^.Handle, False);

  //------------------------------------------------------------------------------
  // Entering the core.
  //------------------------------------------------------------------------------
  try
    //------------------------------------------------------------------------------
    // Initialization of Io Core
    //------------------------------------------------------------------------------
    IoCore := YIoCore.Create;
    try
      IoCore.Initialize;
    except
      on cEx: ECoreOperationFailed do
      begin
        IoCore.Console.WriteDataCoreStatus(sttError);
        IoCore.Console.WriteSoftExceptionLog(cEx);
        raise;
      end;
    end;
    
    //------------------------------------------------------------------------------
    // Writing Console MOTD (as program name, version, team, etc)
    //------------------------------------------------------------------------------
    IoCore.Console.WriteProgramMOTD;

    //------------------------------------------------------------------------------
    // Initialization of Data Core
    //------------------------------------------------------------------------------
    IoCore.Console.WriteDataCoreStatus(sttInit);
    DataCore := YDataCore.Create;
    try
      DataCore.Initialize;
    except
      on cEx: ECoreOperationFailed do
      begin
        IoCore.Console.WriteIoCoreStatus(sttError);
        IoCore.Console.WriteSoftExceptionLog(cEx);
        raise;
      end;
    end;

    //------------------------------------------------------------------------------
    // Initialization of NetworkCore
    //------------------------------------------------------------------------------
    IoCore.Console.WriteNetworkCoreStatus(sttInit);
    NetworkCore := YNetworkCore.Create;
    try
      NetworkCore.Initialize;
    except
      on cEx: ECoreOperationFailed do
      begin
        IoCore.Console.WriteNetworkCoreStatus(sttError);
        IoCore.Console.WriteSoftExceptionLog(cEx);
        raise;
      end;
    end;

    //------------------------------------------------------------------------------
    // Initialization of GameCore
    //------------------------------------------------------------------------------
    IoCore.Console.WriteGameCoreStatus(sttInit);
    GameCore := YGameCore.Create;
    try
      GameCore.Initialize;
    except
      on cEx: ECoreOperationFailed do
      begin
        IoCore.Console.WriteGameCoreStatus(sttError);
        IoCore.Console.WriteSoftExceptionLog(cEx);
        raise;
      end;
    end;

    IoCore.Console.WriteExtensionCoreStatus(sttInit);
    ExtensionCore := YExtensionCore.Create;
    try
      ExtensionCore.Initialize;
    except
      on cEx: ECoreOperationFailed do
      begin
        IoCore.Console.WriteExtensionCoreStatus(sttError);
        IoCore.Console.WriteSoftExceptionLog(cEx);
        raise;
      end;
    end;

    //------------------------------------------------------------------------------
    // Starting Io Core
    //------------------------------------------------------------------------------
    try
      IoCore.Start;
    except
      on cEx: ECoreOperationFailed do
      begin
        IoCore.Console.WriteIoCoreStatus(sttError);
        IoCore.Console.WriteSoftExceptionLog(cEx);
        raise;
      end;
    end;

    //------------------------------------------------------------------------------
    // Starting Data Core
    //------------------------------------------------------------------------------
    try
      DataCore.Start;
    except
      on cEx: ECoreOperationFailed do
      begin
        IoCore.Console.WriteDataCoreStatus(sttError);
        IoCore.Console.WriteSoftExceptionLog(cEx);
        raise;
      end;
    end;
    IoCore.Console.WriteDataCoreStatus(sttStart);

    //------------------------------------------------------------------------------
    // Starting NetworkCore
    //------------------------------------------------------------------------------
    try
      NetworkCore.Start;
    except
      on cEx: ECoreOperationFailed do
      begin
        IoCore.Console.WriteNetworkCoreStatus(sttError);
        IoCore.Console.WriteSoftExceptionLog(cEx);
        raise;
      end;
    end;
    IoCore.Console.WriteNetworkCoreStatus(sttStart);

    //------------------------------------------------------------------------------
    // Starting GameCore
    //------------------------------------------------------------------------------
    try
      GameCore.Start;
    except
      on cEx: ECoreOperationFailed do
      begin
        IoCore.Console.WriteGameCoreStatus(sttError);
        IoCore.Console.WriteSoftExceptionLog(cEx);
        raise;
      end;
    end;
    IoCore.Console.WriteGameCoreStatus(sttStart);

    try
      ExtensionCore.Start;
    except
      on cEx: ECoreOperationFailed do
      begin
        IoCore.Console.WriteExtensionCoreStatus(sttError);
        IoCore.Console.WriteSoftExceptionLog(cEx);
        raise;
      end;
    end;
    IoCore.Console.WriteExtensionCoreStatus(sttStart);

    IoCore.Console.WriteStartupTime(StopExecutionTimer(ExecCounter));
    
    IoCore.Console.WriteSocketInit(NetworkCore.LogonServer.LocalPort, NetworkCore.WorldServer.LocalPort,
      NetworkCore.LogonServer.ThreadCount, NetworkCore.WorldServer.ThreadCount);

    //------------------------------------------------------------------------------
    // We'll reduce the main thread's priority, because it only checks a few booleans.
    //------------------------------------------------------------------------------
    SlowDownMainThread;

    RegisterKeyHandlers;

    IoCore.Console.WriteProgramStopMOTD;

    tShutdown.WaitFor(-1);

    tShutDown.Delete;

    PostMessage(hInvisibleWindow, WM_USER, 0, 0); { Post a rand message so that the message thread will exit }

    SysEventMgr.StopActivity; { Wait for the tick generator thread to end }
    
    //------------------------------------------------------------------------------
    // Now we'll increase the main thread's priority, because now it's the only thread
    // running and among other things it saves the DB and deallocates memory.
    //------------------------------------------------------------------------------

    BoostMainThread;

    StartExecutionTimer(ExecCounter);
    //------------------------------------------------------------------------------
    // Trying to stop NetworkCore
    //------------------------------------------------------------------------------
    try
      NetworkCore.Stop;
    except
      on ECoreOperationFailed do
      begin
        IoCore.Console.WriteNetworkCoreStatus(sttError);
      end;
    end;
    IoCore.Console.WriteNetworkCoreStatus(sttStop);
    
    //------------------------------------------------------------------------------
    // Trying to stop GameCore
    //------------------------------------------------------------------------------
    try
      GameCore.Stop;
    except
      on ECoreOperationFailed do
      begin
        IoCore.Console.WriteGameCoreStatus(sttError);
      end;
    end;
    IoCore.Console.WriteGameCoreStatus(sttStop);

    try
      ExtensionCore.Stop;
    except
      on ECoreOperationFailed do
      begin
        IoCore.Console.WriteExtensionCoreStatus(sttError);
      end;
    end;
    IoCore.Console.WriteExtensionCoreStatus(sttStop);

    //------------------------------------------------------------------------------
    // Trying to stop DataCore
    //------------------------------------------------------------------------------
    try
      DataCore.Stop;
    except
      on ECoreOperationFailed do
      begin
        IoCore.Console.WriteDataCoreStatus(sttError);
      end;
    end;
    IoCore.Console.WriteDataCoreStatus(sttStop);

    try
      IoCore.Stop;
    except
      on ECoreOperationFailed do
      begin
        IoCore.Console.WriteIoCoreStatus(sttError);
      end;
    end;

    IoCore.Console.WriteShutdownTime(StopExecutionTimer(ExecCounter));

  //------------------------------------------------------------------------------
  // This is thr rxception handler for the entire process
  //------------------------------------------------------------------------------
  except
    on E: Exception do
    begin
      IoCore.Console.WriteFatalExit;
      ReportMemoryLeaksOnShutdown := False;
      Sleep(1000);
      raise;
    end;
  end;

  HaltSystem;
  //------------------------------------------------------------------------------
  // YAWE - End of file
  //------------------------------------------------------------------------------
end;

end.
