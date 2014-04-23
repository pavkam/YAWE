{*------------------------------------------------------------------------------
  Error manager, encapsulating exception watcher.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.IoCore.ErrorManager;

interface

uses
  SysUtils,
  Framework.ErrorHandler,
  Framework.Base,
  Framework.LogManager,
  Bfg.Containers,
  Bfg.Utils,
  Bfg.SystemInfo,
  Bfg.Threads;

type
  YIoErrorManager = class(TInterfacedObject)
    private
      FLock: TCriticalSection;
      FLogPath: WideString;
      FIgnoredExceptionTypes: TPtrArrayList;
      FIgnoredRaiseSources: TPtrArrayList;
      FForceLogExceptionTypes: TPtrArrayList;
      FForceLogRaiseSources: TPtrArrayList;
    public
      constructor Create(const LogPath: WideString);
      destructor Destroy; override;

      procedure IgnoreRaiseSource(Addr: Pointer);
      procedure IgnoreExceptionType(ExcClass: ExceptClass);
      procedure ForceLogRaiseSource(Addr: Pointer);
      procedure ForceLogExceptionType(ExcClass: ExceptClass);

      procedure CatchCriticalException(Watcher: TExceptionWatcher;
        const RaisedExc: TRaisedExceptionInfo);

      procedure OutputStackTrace(const CallStack: TCallStack; Exc: Exception;
        const RaisedExc: TRaisedExceptionInfo; Watcher: TExceptionWatcher);
  end;

implementation

uses
  API.Win.PsAPI,
  API.Win.Kernel,
  Framework,
  Version,
  SysConst,
  MapHelp.LibInterface,
  Resources,
  Bfg.Classes,
  Bfg.Unicode,
  Classes,
  TypInfo,
  Bfg.TypInfoEx,
  Main;

threadvar
  DisabledLogging: Boolean;

function ConvertRuntimeErrorToString(const RaisedExc: TRaisedExceptionInfo): string;
var
  sAccess: string;
begin
  case RaisedExc.ErrorType of
    reOutOfMemory: Result := SOutOfMemory;
    reDivByZero: Result := SDivByZero;
    reRangeError: Result := SRangeError;
    reInvalidOp: Result := SInvalidOp;
    reZeroDivide: Result := SZeroDivide;
    reAccessViolation:
    begin
      if RaisedExc.Extra[0] = 0 then
      begin
        sAccess := SReadAccess;
      end else if RaisedExc.Extra[0] = 8 then
      begin
        sAccess := SExecuteAccess;
      end else
      begin
        sAccess := SWriteAccess;
      end;
      Result := Format(SysConst.SAccessViolationArg3, [RaisedExc.ExceptionAddress,
        sAccess, Pointer(RaisedExc.Extra[1])]);
    end;
    rePrivInstruction: Result := SPrivilege;
    reStackOverflow: Result := SStackOverflow;
  else
    begin
      Result := Format(SysConst.SExternalException, [Longword(RaisedExc.ExceptionCode)]);
    end;
  end;
end;

procedure FormatRoutineName(var Name: string; const Module: string);
const
  ENTRY_POINT = '@Entry';
begin
  if StringsEqualNoCase(Module, sModuleName) then
  begin
    if StringsEqualNoCase(Name, sAppName) then
    begin
      Name := Name + ENTRY_POINT;
    end;
  end;
end;

{ YIoErrorManager }

constructor YIoErrorManager.Create(const LogPath: WideString);
begin
  inherited Create;

  FLock.Init;
  
  FLogPath := WideIncludeTrailingPathDelimiter(WideExpandFileName(FileNameToOS(LogPath)));
  SysDbg.OnCatchException := CatchCriticalException;

  FIgnoredExceptionTypes := TPtrArrayList.Create;
  FIgnoredRaiseSources := TPtrArrayList.Create;
  FForceLogExceptionTypes := TPtrArrayList.Create;
  FForceLogRaiseSources := TPtrArrayList.Create;

  FIgnoredExceptionTypes.Sorted := True;
  FIgnoredRaiseSources.Sorted := True;

  { Exceptions raised in these functions will never be included in the log }
  IgnoreRaiseSource(@YIoErrorManager.OutputStackTrace);
  
  { These exception types will be always excluded from the log }
  IgnoreExceptionType(EAbort);

  { These exception types will be logged, no matter what you do }
  ForceLogExceptionType(EExternal);
  ForceLogExceptionType(EExternalException);
  ForceLogExceptionType(EAccessViolation);
  ForceLogExceptionType(EPrivilege);
  ForceLogExceptionType(EStackOverflow);
  ForceLogExceptionType(EAssertionFailed);
  ForceLogExceptionType(EMathError);
  ForceLogExceptionType(EInvalidOp);
  ForceLogExceptionType(EOverflow);
  ForceLogExceptionType(EUnderflow);
  ForceLogExceptionType(EZeroDivide);
  ForceLogExceptionType(EHeapException);
  ForceLogExceptionType(EInvalidPointer);
end;

destructor YIoErrorManager.Destroy;
begin
  FIgnoredExceptionTypes.Free;
  FIgnoredRaiseSources.Free;
  FForceLogExceptionTypes.Free;
  FForceLogRaiseSources.Free;
  FLock.Delete;
  inherited Destroy;
end;

procedure YIoErrorManager.IgnoreRaiseSource(Addr: Pointer);
var
  Displacement: Longword;
begin
  SysDbg.GetFunctionInfo(Displacement, Addr);
  Addr := PChar(Addr) - Displacement;
  Assert(FForceLogRaiseSources.IndexOf(Addr) = -1);

  if FIgnoredRaiseSources.IndexOf(Addr) = -1 then
  begin
    FIgnoredRaiseSources.Add(Addr);
  end;
end;

procedure YIoErrorManager.IgnoreExceptionType(ExcClass: ExceptClass);
begin
  Assert(FForceLogExceptionTypes.IndexOf(ExcClass) = -1);

  if FIgnoredExceptionTypes.IndexOf(ExcClass) = -1 then
  begin
    FIgnoredExceptionTypes.Add(ExcClass);
  end;
end;

procedure YIoErrorManager.ForceLogRaiseSource(Addr: Pointer);
var
  Displacement: Longword;
begin
  SysDbg.GetFunctionInfo(Displacement, Addr);
  Addr := PChar(Addr) - Displacement;
  Assert(FIgnoredRaiseSources.IndexOf(Addr) = -1);

  if FForceLogRaiseSources.IndexOf(Addr) = -1 then
  begin
    FForceLogRaiseSources.Add(Addr);
  end;
end;

procedure YIoErrorManager.ForceLogExceptionType(ExcClass: ExceptClass);
begin
  Assert(FIgnoredExceptionTypes.IndexOf(ExcClass) = -1);

  if FForceLogExceptionTypes.IndexOf(ExcClass) = -1 then
  begin
    FForceLogExceptionTypes.Add(ExcClass);
  end;
end;

function GetOSAndCPUInfo: string;
begin
  Result := Format(RsErrLogCpuAndOsInfo, [OSName, CPUInfo.VendorString, CPUInfo.CpuName,
    CPUInfo.InstructionSupportString, ProcessorCount]);
end;

function GetLoadedModulesList: string;
const
  ModuleEntryFmt = '  0x%p - 0x%p  %s'#13#10;
var
  I: Integer;
  Modules: array of TModuleInformation;
begin
  MapGetLoadedModules(nil, 0, @I);
  SetLength(Modules, I);
  if MapGetLoadedModules(@Modules[0], I, nil) = MAP_ERR_OK then
  begin
    Result := RsErrLoadedModules;
    for I := 0 to Length(Modules) -1 do
    begin
      Result := Result + Format(ModuleEntryFmt, [Modules[I].ModuleStart,
        Pointer(Longword(Modules[I].ModuleStart) + Modules[I].ModuleSize),
        Modules[I].ModuleFullName]);
    end;
  end else Result := '';
end;

function GetMemoryInfo: string;
var
  MemInfo: TProcessMemoryCounters;
begin
  GetProcessMemoryInfo(hMainProcess, @MemInfo, SizeOf(MemInfo));
  Result := Format(RsErrLogMemInfo, [MemInfo.WorkingSetSize div 1024,
    MemInfo.PagefileUsage div 1024, MemInfo.PeakWorkingSetSize div 1024,
    MemInfo.PeakPagefileUsage div 1024]);
end;

procedure YIoErrorManager.OutputStackTrace(const CallStack: TCallStack; Exc: Exception;
  const RaisedExc: TRaisedExceptionInfo; Watcher: TExceptionWatcher);
  function GetFormatedDateTime: string;
  const
    DateTimeStrFmt = '%u-%u-%u %.2u:%.2u:%.2u.%.3u';
  var
    SystemTime: TSystemTime;
  begin
    GetLocalTime(@SystemTime);
    with SystemTime do
    begin
      Result := Format(DateTimeStrFmt, [wDay, wMonth, wYear, wHour, wMinute, wSecond,
        wMilliSeconds]);
    end;
  end;
const
  FormatStr = '  0x%p - %s!%s+0x%s';
var
  I: Integer;
  Log: TLogHandle;
  DateStr: string;
  FmtHeader: string;
  SepLine: string;
  FlagsStr: string;
  Overlay: Integer;
  Flags: TExceptionFlags absolute Overlay;
  FirstEntry: TCallStackEntry;
  ItemInfoArray: array of TCallStackEntryInfo;
  First: Integer;
  MustLog: Boolean;
label
  __SkipChecks;
begin
  Overlay := 0;
  Flags := RaisedExc.Flags;
  if efUnhandled in Flags then ReportMemoryLeaksOnShutdown := False;

  MustLog := (efAnyHandler in Flags);
  DateStr := GetFormatedDateTime;
  Assert(Length(CallStack) <> 0);

  SetLength(ItemInfoArray, Length(Callstack));
  for I := 0 to Length(Callstack) -1 do
  begin
    Watcher.GetCallStackEntryInfo(Callstack[I], ItemInfoArray[I], cifAll);
  end;

  if efUnhandled in Flags then goto __SkipChecks;

  if MustLog then
  begin
    for I := 0 to Length(ItemInfoArray) -1 do
    begin
      if FIgnoredRaiseSources.IndexOf(ItemInfoArray[I].Addr) <> -1 then
      begin
        MustLog := False;
        Break;
      end;
    end;
  end;

  if MustLog then
  begin
    if Assigned(Exc) then
    begin
      MustLog := FIgnoredExceptionTypes.IndexOf(Exc.ClassType) = -1;
    end;
  end;

  if not MustLog then
  begin
    for I := 0 to Length(ItemInfoArray) -1 do
    begin
      if FForceLogRaiseSources.IndexOf(ItemInfoArray[I].Addr) <> -1 then
      begin
        MustLog := True;
        Break;
      end;
    end;

    if not MustLog and Assigned(Exc) then
    begin
      MustLog := FForceLogExceptionTypes.IndexOf(Exc.ClassType) <> -1;
    end;
  end;

  if not MustLog then Exit;

  __SkipChecks:
  First := -1;
  if StringsEqualNoCase(ItemInfoArray[0].Module, 'kernel32.dll') then
  begin
    { A check for RaiseException }
    if Length(CallStack) > 1 then
    begin
      FirstEntry := CallStack[1];
      ItemInfoArray[0].Module := '';
      ItemInfoArray[0].Routine := '';
      ItemInfoArray[0].Source := '';

      First := 1;
    end else FirstEntry := nil;
  end else
  begin
    First := 0;
    FirstEntry := CallStack[0];
  end;

  if FirstEntry = nil then Exit;

  FmtHeader := StringOfChar('=', 80) + EOL;
  with ItemInfoArray[0] do
  begin
    FlagsStr := Bfg.TypInfoEx.SetToString(TypeInfo(TExceptionFlags), Overlay, True, False);
    if efSystem in Flags then
    begin
      FmtHeader := FmtHeader + RsErrLogHeader + RsErrLogSysStart +
        RsErrLogCall  + RsErrLogExtraFlags;
      FmtHeader := Format(FmtHeader, [DateStr, ConvertRuntimeErrorToString(RaisedExc),
        LineNumber, Source, FlagsStr]);
    end else if efDelphi in Flags then
    begin
      FmtHeader := FmtHeader + RsErrLogHeader + RsErrLogStart +
        RsErrLogCall + RsErrLogExtraFlags;
      FmtHeader := Format(FmtHeader, [DateStr, Exc.ClassName, Exc.Message,
        LineNumber, Source, FlagsStr]);
    end;
  end;

  if not WideDirectoryExists(FLogPath) then WideCreateDir(FLogPath);

  SepLine := StringOfChar('-', 80);
  
  Log := SysLogger.CreateLog(Format(FLogPath + '%s.log', [StringReplace(DateStr,
    ':', '.', [rfReplaceAll])]), -1, lmSync);
  try
    Log.Open;

    Log.Write(FmtHeader);
    Log.Write(SepLine);
    Log.WriteResFmt(@RsErrYAWEInfo, [ProgramVersion]);
    Log.Write(GetOSAndCPUInfo);
    Log.Write(GetMemoryInfo);
    Log.Write(SepLine);

    if Length(CallStack) <> 0 then
    begin
      Log.WriteRes(@RsErrLogStack);
      for I := First to Length(ItemInfoArray) -1 do
      begin
        with ItemInfoArray[I] do
        begin
          FormatRoutineName(Routine, Module);
          Log.WriteFmt(FormatStr, [CallStack[I], Module, Routine,
            IntToHex(Displacement, 2)]);
        end;
      end;
    end else
    begin
      Log.WriteRes(@RsErrLogNoStack);
    end;

    Log.Write('');
    Log.Write(SepLine);
    Log.Write(GetLoadedModulesList);
  finally
    Log.Free;
  end;
end;

procedure YIoErrorManager.CatchCriticalException(Watcher: TExceptionWatcher;
  const RaisedExc: TRaisedExceptionInfo);
var
  CallStack: TCallStack;
begin
  if not DisabledLogging then DisabledLogging := True else Exit;
  FLock.Enter;
  try
    Watcher.GetCallStack(RaisedExc, CallStack);
    { Now we'll format the stack trace into a nice and clean log }
    OutputStackTrace(CallStack, RaisedExc.ExceptionObject, RaisedExc, Watcher);
  finally
    FLock.Leave;
  end;
  DisabledLogging := False;
end;

end.
