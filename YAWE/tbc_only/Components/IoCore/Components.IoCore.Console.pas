{*------------------------------------------------------------------------------
  Global Console

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
unit Components.IoCore.Console;

interface

uses
  Version,
  Framework.Base,
  Framework.Tick,
  Framework.ThreadManager,
  Framework.LogManager,
  API.Win.Kernel,
  API.Win.Types,
  API.Win.NTCommon,
  Bfg.Containers,
  Bfg.Utils,
  Bfg.SystemInfo,
  Bfg.Threads,
  SysUtils,
  Classes,
  Components.NetworkCore.Packet;

const
  CHR_NL = #13#10;

  Black = 0;
  Blue = 1;
  Green = 2;
  Cyan = 3;
  Red = 4;
  Magneta = 5;
  Brown = 6;
  LightGray = 7;
  DarkGray = 8;
  LightBlue = 9;
  LightGreen = 10;
  LightCyan = 11;
  LightRed = 12;
  LightMagneta = 13;
  Yellow = 14;
  White = 15;

  CLR_INFO = White;
  CLR_ATTENTION = DarkGray;
  CLR_IMPORTANT = LightCyan;
  CLR_OK = Green;
  CLR_ERR = Red;
  CLR_FATAL_ERR = LightRed;
  CLR_ADD = LightGreen;
  CLR_DEBUG = Magneta;

type
  { Used for Core status display. }
  YCoreStatus = (sttInit, sttError, sttStop, sttStart);

  YConsoleCommandHandler = procedure(const Args: array of string) of object;
  PConsoleCommandHandler = ^YConsoleCommandHandler;

  { Interface which provides access to the console object }
  IConsole = interface(IInterface)
  ['{28B3D9BD-7A37-45D3-9A52-DD0B8B9A0588}']
    procedure Write(const sStr: string; iColor: Byte = White);
    procedure Writeln(const sStr: string; iColor: Byte = White);
    procedure WriteMultiple(const aStrings: array of string; const aColors: array of Byte;
      bNewLine: Boolean = True);
    procedure WritelnMultiple(const aStrings: array of string; const aColors: array of Byte);
    procedure NewLine;
  end;

  {
   Console. Please add all major text here instead of modules.
   Also avoid using directly writes/reads.
  }
  YIoConsole = class(TInterfacedObject, IConsole)
    private
      fCi: TCharInfo;
      fConsoleOutput: THandle;
      fConsoleInput: THandle;
      fConsoleWindow: HWND;
      fShutDown: Longbool;
      fScreenInfo: TConsoleScreenBufferInfo;
      fCommandHandlers: TStrPtrHashMap;
      fLock: TCriticalSection;
      fThread: TThreadHandle;
      fDefaultAttributes: Word;

      procedure SetTextColorTo(iColor: Byte); inline;

      procedure InvokeCommandHandler(CmdLine: string);
      procedure CheckConsoleInput(Thread: TThreadHandle);

      procedure Lock; inline;
      procedure Unlock; inline;
    public
      constructor Create;
      destructor Destroy; override;

      procedure Write(const sStr: string; iColor: Byte = White);
      procedure Writeln(const sStr: string; iColor: Byte = White);

      procedure WriteFmt(const sStr: string; const aArgs: array of const; iColor: Byte = White);
      procedure WritelnFmt(const sStr: string; const aArgs: array of const; iColor: Byte = White);

      procedure WriteResFmt(pStr: PResStringRec; const aArgs: array of const; iColor: Byte = White);
      procedure WritelnResFmt(pStr: PResStringRec; const aArgs: array of const; iColor: Byte = White);

      procedure WriteMultiple(const aStrings: array of string; const aColors: array of Byte;
        bNewLine: Boolean = True);
      procedure WritelnMultiple(const aStrings: array of string; const aColors: array of Byte);

      procedure RegisterCommandHandler(const Cmd: string; Handler: YConsoleCommandHandler);
      procedure UnregisterCommandHandler(const Cmd: string);
      procedure ClearCommandHandlers;

      function EnumCommands: TStringDynArray;

      procedure GotoXY(X, Y: Byte);
      procedure GotoOffsetXY(X, Y: Byte);
      procedure GetConsoleScreenBufferSize(out X, Y: Longword);
      procedure NewLine;
      procedure FlushInputBuffer;

      procedure WriteProgramMOTD;
      procedure WriteProgramStopMOTD;
      procedure WriteConfigurationLoad(const sFileName: string);
      procedure WriteSuccess;
      procedure WriteSuccessWithData(const sData: string);
      procedure WriteFailureWithData(const sData: string);
      procedure WriteSMDFileLoadError(const sFile: string);
      procedure WriteError;
      procedure WriteFatalExit;
      procedure WriteTickStart(iMSec: UInt32);
      procedure WriteTickStop;
      procedure WriteCoreStatus(tStatus: YCoreStatus; const sCoreName: string);
      procedure WriteDataCoreStatus(tStatus: YCoreStatus);
      procedure WriteNetworkCoreStatus(tStatus: YCoreStatus);
      procedure WriteGameCoreStatus(tStatus: YCoreStatus);
      procedure WriteExtensionCoreStatus(tStatus: YCoreStatus);
      procedure WriteIoCoreStatus(tStatus: YCoreStatus);
      procedure WriteStartupTime(const fTime: Float);
      procedure WriteShutdownTime(const fTime: Float);
      procedure WriteSoftExceptionLog(cEx: Exception);
      procedure WriteLoadOf(const sWhat: string);
      procedure WriteLoadOfSub(const sWhat: string);
      procedure WriteLoadOfSubComp(const sWhat: string);
      procedure WriteInfoOfSub(const sVar, sValue: string);
      procedure WriteMapInfo(iResLiquid, iResZ, iResArea, iMaps, iVer: UInt32);
      procedure WriteSocketInit(wLogon, wRealm: UInt16; iThreadCountL, iThreadCountR: UInt32);
      procedure WriteConnectInfo(const sHost: string; iPort: Int32);
      procedure WriteDisconnectInfo(const sHost: string; iPort: Int32);
      procedure WriteConnectInfoWS(const sHost: string; iPort: Int32);
      procedure WriteDisconnectInfoWS(const sHost: string; iPort: Int32);
      //procedure WriteSentPacketSize(cPacket: YPacket);
      //procedure WriteReceivedPacketSize(cPacket: YPacket);
      procedure WriteWSSentPacketSize(cPacket: YNwServerPacket);
      procedure WriteLSMessage(const sMsg: string; cSelf: TObject);
      procedure WriteLSErrorMessage(const sMsg: string; iError: Int32; cSelf: TObject);
      procedure WriteLoadPatch(const sPatchName, sMD5: string);
      procedure WriteTickRegister(iHndl: TEventHandle);
      procedure WriteTickUnregister(iHndl: TEventHandle);
      procedure WriteWSMessage(const sMessage: string; pThId: Pointer);
      procedure WriteVar(const sName: string; const xVar; iLen: Int32);
      procedure WriteOpCodeCall(pThId: Pointer; const sOpName: string; iOpCode: UInt32; bHandled: Boolean);
      procedure WriteUpdateReq(cObj: TObject);
      procedure WritePluginPackageLoad(const sPackage: string);
      procedure WritePluginPackageUnload(const sPackage: string);

      property WindowHandle: HWND read fConsoleWindow;
      property InputHandle: THandle read fConsoleInput;
      property OutputHandle: THandle read fConsoleOutput;
    end;

implementation

uses
  Components.NetworkCore.Opcodes,
  Framework,
  Resources;

const
  DEFAULT_COLOR = White;

{ YIoConsole }

constructor YIoConsole.Create;
begin
  inherited Create;
  fLock.Init;
  fCommandHandlers := TStrPtrHashMap.Create(False, 1024);
  fConsoleInput := GetStdHandle(STD_INPUT_HANDLE);
  fConsoleOutput := GetStdHandle(STD_OUTPUT_HANDLE);
  fConsoleWindow := GetConsoleWindow;
  { Get the standard Output/Input handles }
  GetConsoleScreenBufferInfo(fConsoleOutput, fScreenInfo);
  fDefaultAttributes := fScreenInfo.wAttributes;
  fCi.uChar.AsciiChar := ' ';
  fCi.Attributes := fDefaultAttributes;
  { Set all the attributes }
  fThread := SysThreadMgr.CreateThread(CheckConsoleInput, False,
    'Console_Input_Thread', True);
end;

destructor YIoConsole.Destroy;
const
  Dummy: array[0..1] of Char = (#13, #10);
var
  ifItr: IPtrIterator;
  lwOut: UInt32;
  tRec: array[0..1] of TInputRecord;
begin
  tRec[0].EventType := KEY_EVENT;
  tRec[0].KeyEvent.bKeyDown := True;
  tRec[0].KeyEvent.uChar.AsciiChar := #13;
  tRec[1].EventType := KEY_EVENT;
  tRec[1].KeyEvent.bKeyDown := True;
  tRec[1].KeyEvent.uChar.AsciiChar := #10;
  AtomicInc(@fShutDown);
  if not WriteConsoleInput(fConsoleInput, @tRec, 2, @lwOut) then
  begin
    WriteFile(fConsoleInput, @Dummy[0], SizeOf(Dummy), @lwOut, nil);
  end;
  fThread.WaitForEnd(-1);
  FlushConsoleInputBuffer(fConsoleInput); { Destroy all input }

  ifItr := fCommandHandlers.Values;
  while ifItr.HasNext do
  begin
    Dispose(PConsoleCommandHandler(ifItr.Next));
  end;

  fCommandHandlers.Free;
  fLock.Delete;
  inherited Destroy;
end;

procedure YIoConsole.CheckConsoleInput(Thread: TThreadHandle);
var
  lwOldMode: UInt32;
  iError: UInt32;
  iRead: UInt32;
  pBuf: array[0..1023] of Char;
label
  __IgnoreStdInput;
begin
  if not GetConsoleMode(fConsoleInput, @lwOldMode) then
  begin
    iError := GetLastError;
    if iError <> ERROR_INVALID_HANDLE then
    begin
      raise EApiCallFailed.CreateResFmt(@RsGetConsoleMode, [SysErrorMessage(iError)]);
    end;
  end;

  if not SetConsoleMode(fConsoleInput, lwOldMode and not (ENABLE_WINDOW_INPUT or ENABLE_MOUSE_INPUT)) then
  begin
    iError := GetLastError;
    if iError <> ERROR_INVALID_HANDLE then
    begin
      raise EApiCallFailed.CreateResFmt(@RsSetConsoleMode, [SysErrorMessage(iError)]);
    end;
  end;

  while not fShutDown do
  begin
    FillChar(pBuf, SizeOf(pBuf), 0);
    ReadFile(fConsoleInput, @pBuf[0], SizeOf(pBuf), @iRead, nil);
    InvokeCommandHandler(PChar(@pBuf[0]));
  end;

  if not SetConsoleMode(fConsoleInput, lwOldMode) then
  begin
    iError := GetLastError;
    if iError <> ERROR_INVALID_HANDLE then
    begin
      raise EApiCallFailed.CreateResFmt(@RsGetConsoleMode, [SysErrorMessage(iError)]);
    end;
  end;

  FlushInputBuffer;
end;

procedure YIoConsole.SetTextColorTo(iColor: Byte);
begin
  SetConsoleTextAttribute(fConsoleOutput, iColor and $0F); { Just set the attributes }
end;

procedure YIoConsole.InvokeCommandHandler(CmdLine: string);
var
  pCmdHandler: PConsoleCommandHandler;
  sCmd: string;
  aArgs: TStringDynArray;
  pStart: PChar;
  pCurr: PChar;
begin
  Lock;
  try
    pStart := PChar(CmdLine);
    pCurr := pStart;
    while not (pCurr^ in [' ', #0, #13, #10]) do Inc(pCurr);

    SetString(sCmd, pStart, pCurr - pStart);

    pCmdHandler := fCommandHandlers.GetValue(sCmd);
    if pCmdHandler <> nil then
    begin
      if pCurr^ = ' ' then
      begin
        Delete(CmdLine, 1, Length(sCmd) + 1);
        CmdLine := StringReplace(CmdLine, #13#10, '', [rfReplaceAll]);
        aArgs := StringSplit(CmdLine, ' ');
      end else aArgs := nil;

      pCmdHandler^(aArgs);
    end;
  finally
    Unlock;
  end;
end;

procedure YIoConsole.Write(const sStr: string; iColor: Byte = White);
var
  lwOut: UInt32;
begin
  Lock;
  try
    SetTextColorTo(iColor);
    { Set new color }
    WriteFile(fConsoleOutput, PChar(sStr), Length(sStr), @lwOut, nil);
    { Write our text into the console }
    SetTextColorTo(DEFAULT_COLOR);
    { Restore default }
  finally
    Unlock;
  end;
end;

procedure YIoConsole.WriteFmt(const sStr: string; const aArgs: array of const;
  iColor: Byte);
begin
  Write(Format(sStr, aArgs), iColor);
end;

procedure YIoConsole.WriteResFmt(pStr: PResStringRec;
  const aArgs: array of const; iColor: Byte);
begin
  Write(Format(LoadResString(pStr), aArgs), iColor);
end;

procedure YIoConsole.Writeln(const sStr: string; iColor: Byte = White);
begin
  Write(sStr + CHR_NL, iColor);
end;

procedure YIoConsole.WritelnFmt(const sStr: string; const aArgs: array of const;
  iColor: Byte);
begin
  Write(Format(sStr, aArgs) + CHR_NL, iColor);
end;

procedure YIoConsole.WritelnResFmt(pStr: PResStringRec;
  const aArgs: array of const; iColor: Byte);
begin
  Write(Format(LoadResString(pStr), aArgs) + CHR_NL, iColor);
end;

procedure YIoConsole.WriteMultiple(const aStrings: array of string; const aColors: array of Byte;
  bNewLine: Boolean = True);
var
  iIdx: Integer;
begin
  for iIdx := Low(aStrings) to High(aStrings) do
  begin
    Write(aStrings[iIdx], aColors[iIdx]);
  end;

  if bNewLine then Write(CHR_NL, White);
end;

procedure YIoConsole.WritelnMultiple(const aStrings: array of string; const aColors: array of Byte);
var
  iIdx: Integer;
begin
  if Length(aColors) = 0 then
  begin
    for iIdx := Low(aStrings) to High(aStrings) do
    begin
      Write(aStrings[iIdx] + CHR_NL);
    end;
  end else
  begin
    for iIdx := Low(aStrings) to High(aStrings) do
    begin
      Write(aStrings[iIdx] + CHR_NL, aColors[iIdx]);
    end;
  end;
end;

procedure YIoConsole.NewLine;
begin
  Write(CHR_NL, White);
end;

procedure YIoConsole.RegisterCommandHandler(const Cmd: string; Handler: YConsoleCommandHandler);
var
  pCmdHandler: PConsoleCommandHandler;
begin
  if Assigned(Handler) and (Cmd <> '') then
  begin
    Lock;
    try
      if not fCommandHandlers.ContainsKey(Cmd) then
      begin
        New(pCmdHandler);
        pCmdHandler^ := Handler;
        fCommandHandlers.PutValue(Cmd, pCmdHandler);
      end;
    finally
      Unlock;
    end;
  end;
end;

procedure YIoConsole.UnregisterCommandHandler(const Cmd: string);
var
  pCmdHandler: PConsoleCommandHandler;
begin
  if Cmd <> '' then
  begin
    Lock;
    try
      pCmdHandler := fCommandHandlers.Remove(Cmd);
      if pCmdHandler <> nil then
      begin
        Dispose(pCmdHandler);
      end;
    finally
      Unlock;
    end;
  end;
end;

procedure YIoConsole.ClearCommandHandlers;
var
  ifItr: IPtrIterator;
begin
  Lock;
  try
    ifItr := fCommandHandlers.Values;
    while ifItr.HasNext do
    begin
      Dispose(PConsoleCommandHandler(ifItr.Next));
    end;
    fCommandHandlers.Clear;
  finally
    Unlock;
  end;
end;

function YIoConsole.EnumCommands: TStringDynArray;
var
  ifItr: IStrIterator;
  iInt: Int32;
begin
  Lock;
  try
    SetLength(Result, fCommandHandlers.Size);
    iInt := 0;
    ifItr := fCommandHandlers.KeySet;
    while ifItr.HasNext do
    begin
      Result[iInt] := ifItr.Next;
      Inc(iInt);
    end;
  finally
    Unlock;
  end;
end;

procedure YIoConsole.Lock;
begin
  fLock.Enter;
end;

procedure YIoConsole.Unlock;
begin
  fLock.Leave;
end;

procedure YIoConsole.GotoXY(X, Y: Byte);
var
  tCrd: TCoord;
begin
  tCrd.X := X;
  tCrd.Y := Y;
  SetConsoleCursorPosition(fConsoleOutput, tCrd);
end;

procedure YIoConsole.GetConsoleScreenBufferSize(out X, Y: Longword);
begin
  X := fScreenInfo.dwSize.X;
  Y := fScreenInfo.dwSize.Y;
end;

procedure YIoConsole.GotoOffsetXY(X, Y: Byte);
var
  tCurr: TCoord;
begin
  tCurr := fScreenInfo.dwCursorPosition;
  Inc(tCurr.X, X);
  Inc(tCurr.Y, Y);
  SetConsoleCursorPosition(fConsoleOutput, tCurr);
end;

procedure YIoConsole.FlushInputBuffer;
begin
  FlushConsoleInputBuffer(fConsoleInput);
end;

procedure YIoConsole.WriteError;
begin
  Writeln(RsError, CLR_ERR);
end;

procedure YIoConsole.WriteConfigurationLoad(const sFileName: string);
begin
  Write(RsLoadingConf, CLR_INFO);
end;

procedure YIoConsole.WriteSuccess;
begin
  Writeln(RsSuccess, CLR_OK);
end;

procedure YIoConsole.WritePluginPackageLoad(const sPackage: string);
begin
  WriteMultiple(['  > ', 'Loaded package ', sPackage], [CLR_INFO, CLR_INFO, Green]);
end;

procedure YIoConsole.WritePluginPackageUnload(const sPackage: string);
begin
  WriteMultiple(['  > ', 'Unloaded package ', sPackage], [CLR_INFO, CLR_INFO, Red]);
end;

procedure YIoConsole.WriteProgramMOTD;
var
  cFlags: TStringList;
  iInt: Int32;
begin
  WriteMultiple([RsCnslWelcome, ProgramName, ' (', ProgramVersion, ', codename ',
    ProgramCodename, '). '], [CLR_INFO, 12, CLR_ATTENTION,
    CLR_ATTENTION, CLR_ATTENTION, 9, CLR_ATTENTION]);
  Writeln(ProgramCopyright, CLR_INFO);
  WriteMultiple([RsCnslRunningOn, OSName], [CLR_INFO, LightMagneta]);
  Write(RsCnslAcceptedBuilds, CLR_INFO);

  for iInt := Low(AcceptedBuilds) to High(AcceptedBuilds) do
  begin
    Write(IntToStr(AcceptedBuilds[iInt]) + ' ', CLR_IMPORTANT);
  end;

  NewLine;

  cFlags := TStringList.Create;
  cFlags.Delimiter := ' ';

  {$IFDEF WOW_TBC}
  cFlags.Append('WOW_TBC');
  {$ENDIF}

  {$IFDEF DEBUG_BUILD}
  cFlags.Append('DEBUG_BUILD');
  {$ENDIF}

  {$IFDEF EXPERIMENTAL}
  cFlags.Append('EXPERIMENTAL');
  {$ENDIF}

  {$IFDEF ASM_OPTIMIZATIONS}
  cFlags.Append('ASM_OPTIMIZATIONS');
  {$ENDIF}

  {$IFDEF DBG_SNIFFER}
  cFlags.Append('DBG_SNIFFER');
  {$ENDIF}

  if cFlags.Count > 0 then
  begin
    WriteMultiple([RsCnslCompiledWith, cFlags.DelimitedText], [CLR_INFO, CLR_ADD]);
  end;

  cFlags.Destroy;
end;

procedure YIoConsole.WriteFatalExit;
begin
  Writeln('');
  Writeln('______________________________________________');
  Writeln(RsFatal, CLR_ERR);
end;

procedure YIoConsole.WriteInfoOfSub(const sVar, sValue: string);
begin
  WriteMultiple([RsSubInfo, sVar, ' = ', sValue ], [CLR_INFO, Blue , CLR_INFO, Green]);
end;

procedure YIoConsole.WriteDataCoreStatus(tStatus: YCoreStatus);
begin
  WriteCoreStatus(tStatus, 'DataCore');
end;

procedure YIoConsole.WriteCoreStatus(tStatus: YCoreStatus; const sCoreName: string);
begin
  case tStatus of
    sttInit  : WriteMultiple([RsInit, sCoreName, ' ...'], [CLR_INFO, CLR_ATTENTION ,CLR_INFO]);
    sttError : WriteMultiple([sCoreName, RsInternalError], [CLR_ATTENTION, CLR_INFO]);
    sttStop  : WriteMultiple([sCoreName, RsStopCore], [CLR_ATTENTION, CLR_INFO]);
    sttStart : WriteMultiple([sCoreName, RsStartCore], [CLR_ATTENTION, CLR_INFO]);
  end;
end;

procedure YIoConsole.WriteUpdateReq(cObj: TObject);
begin
  WriteMultiple([RsGrpMgrReqUpd, cObj.ClassName],
    [CLR_ADD, CLR_ATTENTION]);
end;

procedure YIoConsole.WriteProgramStopMOTD;
begin
  WriteMultiple([RsMsgPressX1, 'exit', RsMsgPressX2, ProgramName, '.'],
    [CLR_INFO, CLR_IMPORTANT, CLR_INFO, CLR_ATTENTION, CLR_INFO]);
  WriteMultiple([RsMsgPressT1, 'tray', RsMsgPressT2], [CLR_INFO, CLR_IMPORTANT, CLR_INFO]);
end;

procedure YIoConsole.WriteLoadOf(const sWhat: string);
begin
  WriteMultiple([RsLoad + '"', sWhat, '" ... '], [CLR_INFO, CLR_IMPORTANT, CLR_INFO], False);
end;

procedure YIoConsole.WriteLoadOfSub(const sWhat: string);
begin
  WriteMultiple([RsLoadSub, sWhat, ' ...'], [CLR_INFO, CLR_IMPORTANT ,CLR_INFO], False);
end;

procedure YIoConsole.WriteLoadOfSubComp(const sWhat: string);
begin
  WriteMultiple([RsLoadSubComp , sWhat, ' ... '], [CLR_INFO, CLR_IMPORTANT, CLR_INFO], False);
end;

procedure YIoConsole.WriteSoftExceptionLog(cEx: Exception);
begin
  WriteLn('---------------------------------------------------', CLR_INFO);

  WriteMultiple(['Error: ', cEx.ClassName], [CLR_DEBUG, CLR_ERR]);
  WriteMultiple(['Msg: ', cEx.Message], [CLR_INFO, CLR_ATTENTION]);
  Writeln(RsSeeErrorLog, CLR_INFO);
end;

procedure YIoConsole.WriteStartupTime(const fTime: Float);
begin
  WriteMultiple([RsStartupTime, itoa(Round(fTime)), ' ms.'], [White, LightBlue, White]);
end;

procedure YIoConsole.WriteShutdownTime(const fTime: Float);
begin
  WriteMultiple([RsShutdownTime, itoa(Round(fTime)), ' ms.'], [White, LightBlue, White]);
end;

procedure YIoConsole.WriteSMDFileLoadError(const sFile: string);
begin
  WriteMultiple(['[' + RsDataCoreLoadErr + ']', ' ' + Format(RsFileErrSmdNo, [sFile + '\terrain.smd'])],
    [CLR_ERR, CLR_ATTENTION]);
end;

procedure YIoConsole.WriteSuccessWithData(const sData: string);
begin
  WriteLn('[' + sData + ']', CLR_OK);
end;

procedure YIoConsole.WriteFailureWithData(const sData: string);
begin
  WriteLn('[' + sData + ']', CLR_ERR);
end;

procedure YIoConsole.WriteSocketInit(wLogon, wRealm: UInt16; iThreadCountL, iThreadCountR: UInt32);
begin
  WriteMultiple(['Initialized ', 'Logon TCP socket', ' at port: ', IntToStr(wLogon)],
    [CLR_INFO, CLR_ATTENTION, CLR_INFO, Magneta]);
  WriteMultiple([' > Thread count: ', IntToStr(iThreadCountL)], [CLR_INFO, CLR_ADD]);
  WriteMultiple(['Initialized ', 'World TCP socket', ' at port: ', IntToStr(wRealm)],
    [CLR_INFO, CLR_ATTENTION, CLR_INFO, Magneta]);
  WriteMultiple([' > Thread count: ', IntToStr(iThreadCountR)], [CLR_INFO, CLR_ADD]);
end;

procedure YIoConsole.WriteNetworkCoreStatus(tStatus: YCoreStatus);
begin
  WriteCoreStatus(tStatus, 'NetworkCore');
end;

procedure YIoConsole.WriteConnectInfo(const sHost: string; iPort: Int32);
begin
  WriteMultiple(['Received a LS connection from ', sHost, ' : ', itoa(iPort)],
    [CLR_INFO, CLR_IMPORTANT, CLR_INFO, CLR_IMPORTANT]);
end;

procedure YIoConsole.WriteDisconnectInfo(const sHost: string; iPort: Int32);
begin
  WriteMultiple(['Disconnected a LS connection from ', sHost, ' : ', itoa(iPort)],
    [CLR_INFO, CLR_IMPORTANT, CLR_INFO, CLR_IMPORTANT]);
end;

(*
procedure YConsole.WriteSentPacketSize(cPacket: YPacket);
begin
  WriteMultiple(['Sent ', IntToStr(cPacket.Size), ' bytes.'], [White, White, White]);
end;

procedure YConsole.WriteReceivedPacketSize(cPacket: YPacket);
begin
  WriteMultiple(['Received ', IntToStr(cPacket.Size), ' bytes.'], [White, White, White]);
end;
*)
procedure YIoConsole.WriteWSSentPacketSize(cPacket: YNwServerPacket);
const
  Msg = '<WS> %s Sent %d bytes.';
begin
  Writeln(Format(Msg, [GetOpcodeName(cPacket.Header^.Opcode), cPacket.WritePos]));
end;

procedure YIoConsole.WriteLoadPatch(const sPatchName, sMD5: string);
begin
  WriteMultiple([' > Auto-Patch "',sPatchName,'" with MD5 = ', sMD5],
    [CLR_INFO, CLR_ATTENTION, CLR_INFO, CLR_IMPORTANT]);
end;

procedure YIoConsole.WriteLSMessage(const sMsg: string; cSelf: TObject);
begin
  WriteMultiple(['LS (ThId: ', '0x', itoh(Int32(cSelf)), ') : ', sMsg],
    [CLR_INFO, CLR_ATTENTION, CLR_ATTENTION, CLR_INFO, CLR_ATTENTION]);
end;

procedure YIoConsole.WriteMapInfo(iResLiquid, iResZ, iResArea, iMaps, iVer: UInt32);
begin
  WriteInfoOfSub('Number of Maps', itoa(iMaps));
  WriteInfoOfSub('Map File Version', itoa(iVer and $000000FF) + '.' + itoa((iVer and $0000FF00) shr 8) +
    '.' + itoa((iVer and $00FF0000) shr 16) + '.' + itoa((iVer and $FF000000) shr 24));

  WriteInfoOfSub('Liquid Resoulution', itoa(iResLiquid) + 'x' + itoa(iResLiquid));
  WriteInfoOfSub('Z Resoulution', itoa(iResZ) + 'x' + itoa(iResZ));
  WriteInfoOfSub('Area Resolution', itoa(iResArea) + 'x' + itoa(iResArea));
end;

procedure YIoConsole.WriteLSErrorMessage(const sMsg: string; iError: Int32; cSelf: TObject);
begin
  WriteMultiple(['LS (ThId: ', '0x', itoh(Int32(cSelf)), ') : ', Format(sMsg, [iError])],
    [CLR_INFO, CLR_ATTENTION, CLR_ATTENTION, CLR_INFO, CLR_ATTENTION]);
end;


procedure YIoConsole.WriteTickRegister(iHndl: TEventHandle);
begin
  WriteMultiple(['(TickMgr) - Timer Subscription (', iHndl.Name, ')'],
    [CLR_ADD, CLR_ATTENTION, CLR_ADD]);
end;

procedure YIoConsole.WriteTickStart(iMSec: UInt32);
begin
  WriteMultiple(['Started ','Lifetime Tick Generator', ' ... ', '[' + itoa(iMSec) + ' ms]'],
    [CLR_INFO, CLR_ATTENTION ,CLR_INFO, CLR_OK]);
end;

procedure YIoConsole.WriteTickStop;
begin
  WriteMultiple(['Stopped ', 'Lifetime Tick Generator', ' ...' ], [CLR_INFO, CLR_ATTENTION ,CLR_INFO]);
end;

procedure YIoConsole.WriteTickUnregister(iHndl: TEventHandle);
begin
  WriteMultiple(['(TickMgr) - Timer Release (', iHndl.Name, ')'],
    [CLR_ADD, CLR_ATTENTION, CLR_ADD]);
end;

procedure YIoConsole.WriteVar(const sName: string; const xVar; iLen: Int32);
var
  sS: string;
begin
  SetLength(sS, iLen);
  Move(xVar,  Pointer(sS)^, iLen);
  WriteMultiple([sName, ' = "', atoh(sS), '"'], [CLR_DEBUG, CLR_INFO, CLR_ADD, CLR_INFO]);
end;

procedure YIoConsole.WriteConnectInfoWS(const sHost: string; iPort: Int32);
begin
  WriteMultiple(['Received a WS connection from ', sHost, ' : ', itoa(iPort)],
    [CLR_INFO, CLR_IMPORTANT, CLR_INFO, CLR_IMPORTANT]);
end;

procedure YIoConsole.WriteDisconnectInfoWS(const sHost: string; iPort: Int32);
begin
  WriteMultiple(['Disconnected a WS connection from ', sHost, ' : ', itoa(iPort)],
    [CLR_INFO, CLR_IMPORTANT, CLR_INFO, CLR_IMPORTANT]);
end;

procedure YIoConsole.WriteOpcodeCall(pThId: Pointer; const sOpName: string; iOpCode: UInt32;
  bHandled: Boolean);
const
  ColorNames: array[Boolean] of UInt8 = (
    LightRed, LightGreen
  );
  ColorCodes: array[Boolean] of UInt8 = (
    Red, Green
  );
begin
  WriteMultiple(['  World >> ',' Received {', sOpName, ' (', itoa(iOpCode), ')}'],
    [CLR_ATTENTION, CLR_INFO, ColorNames[bHandled], CLR_INFO, ColorCodes[bHandled], CLR_INFO]);
end;

procedure YIoConsole.WriteWSMessage(const sMessage: string; pThId: Pointer);
begin
  WriteMultiple(['WS (ThId: ','0x', itoh(Int32(pThId)), ') : ', sMessage],
    [CLR_INFO, CLR_ATTENTION, CLR_ATTENTION, CLR_INFO, CLR_ATTENTION]);
end;

procedure YIoConsole.WriteGameCoreStatus(tStatus: YCoreStatus);
begin
  WriteCoreStatus(tStatus, 'GameCore');
end;

procedure YIoConsole.WriteExtensionCoreStatus(tStatus: YCoreStatus);
begin
  WriteCoreStatus(tStatus, 'ExtensionCore');
end;

procedure YIoConsole.WriteIoCoreStatus(tStatus: YCoreStatus);
begin
  WriteCoreStatus(tStatus, 'IoCore');
end;

end.
