{*------------------------------------------------------------------------------
  Error manager, encapsulating exception watcher.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
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
  Framework.TypeRegistry,
  Misc.Containers,
  Misc.Miscleanous,
  Misc.SystemInfo,
  Misc.Threads;

type
  YIoErrorManager = class(TBaseObject)
    private
      fLock: TCriticalSection;
      fLogPath: string;
      fIgnoredExceptionTypes: TPtrArrayList;
      fIgnoredRaiseSources: TPtrArrayList;
      fForceLogExceptionTypes: TPtrArrayList;
      fForceLogRaiseSources: TPtrArrayList;
    public
      constructor Create(const LogPath: string);
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
  Misc.Classes,
  Classes,
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

constructor YIoErrorManager.Create(const LogPath: string);
begin
  inherited Create;
  fLogPath := IncludeTrailingPathDelimiter(ExpandFileName(FileNameToOS(LogPath)));
  fLock.Init;
  SystemDebugger.OnCatchException := CatchCriticalException;

  fIgnoredExceptionTypes := TPtrArrayList.Create;
  fIgnoredRaiseSources := TPtrArrayList.Create;
  fForceLogExceptionTypes := TPtrArrayList.Create;
  fForceLogRaiseSources := TPtrArrayList.Create;

  fIgnoredExceptionTypes.Sorted := True;
  fIgnoredRaiseSources.Sorted := True;

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
  fIgnoredExceptionTypes.Free;
  fIgnoredRaiseSources.Free;
  fForceLogExceptionTypes.Free;
  fForceLogRaiseSources.Free;
  fLock.Delete;
  inherited Destroy;
end;

procedure YIoErrorManager.IgnoreRaiseSource(Addr: Pointer);
var
  Displacement: Longword;
begin
  SystemDebugger.GetFunctionInfo(Displacement, Addr);
  Addr := PChar(Addr) - Displacement;
  Assert(fForceLogRaiseSources.IndexOf(Addr) = -1);

  if fIgnoredRaiseSources.IndexOf(Addr) = -1 then
  begin
    fIgnoredRaiseSources.Add(Addr);
  end;
end;

procedure YIoErrorManager.IgnoreExceptionType(ExcClass: ExceptClass);
begin
  Assert(fForceLogExceptionTypes.IndexOf(ExcClass) = -1);

  if fIgnoredExceptionTypes.IndexOf(ExcClass) = -1 then
  begin
    fIgnoredExceptionTypes.Add(ExcClass);
  end;
end;

procedure YIoErrorManager.ForceLogRaiseSource(Addr: Pointer);
var
  Displacement: Longword;
begin
  SystemDebugger.GetFunctionInfo(Displacement, Addr);
  Addr := PChar(Addr) - Displacement;
  Assert(fIgnoredRaiseSources.IndexOf(Addr) = -1);

  if fForceLogRaiseSources.IndexOf(Addr) = -1 then
  begin
    fForceLogRaiseSources.Add(Addr);
  end;
end;

procedure YIoErrorManager.ForceLogExceptionType(ExcClass: ExceptClass);
begin
  Assert(fIgnoredExceptionTypes.IndexOf(ExcClass) = -1);

  if fForceLogExceptionTypes.IndexOf(ExcClass) = -1 then
  begin
    fForceLogExceptionTypes.Add(ExcClass);
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
  iCount: Integer;
  aModules: array of TModuleInformation;
begin
  MapGetLoadedModules(nil, 0, @iCount);
  SetLength(aModules, iCount);
  if MapGetLoadedModules(@aModules[0], iCount, nil) = MAP_ERR_OK then
  begin
    Result := RsErrLoadedModules;
    for iCount := 0 to Length(aModules) -1 do
    begin
      Result := Result + Format(ModuleEntryFmt, [aModules[iCount].ModuleStart,
        Pointer(Longword(aModules[iCount].ModuleStart) + aModules[iCount].ModuleSize),
        aModules[iCount].ModuleFullName]);
    end;
  end else Result := '';
end;

function GetMemoryInfo: string;
var
  tMemInfo: TProcessMemoryCounters;
begin
  GetProcessMemoryInfo(hMainProcess, @tMemInfo, SizeOf(tMemInfo));
  Result := Format(RsErrLogMemInfo, [tMemInfo.WorkingSetSize div 1024,
    tMemInfo.PagefileUsage div 1024, tMemInfo.PeakWorkingSetSize div 1024,
    tMemInfo.PeakPagefileUsage div 1024]);
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
  iIdx: Int32;
  cLog: TLogHandle;
  sDate: string;
  sFmtHeader: string;
  sSepLine: string;
  sFlags: string;
  iFlags: TExceptionFlags;
  pFirstEntry: TCallStackEntry;
  tItemInfos: array of TCallStackEntryInfo;
  iFirst: Int32;
  bMustLog: Boolean;
label
  __SkipChecks;
begin
  iFlags := RaisedExc.Flags;
  if efUnhandled in iFlags then ReportMemoryLeaksOnShutdown := False;

  bMustLog := (efAnyHandler in iFlags);
  sDate := GetFormatedDateTime;
  Assert(Length(CallStack) <> 0);

  SetLength(tItemInfos, Length(Callstack));
  for iIdx := 0 to Length(Callstack) -1 do
  begin
    Watcher.GetCallStackEntryInfo(Callstack[iIdx], tItemInfos[iIdx], cifAll);
  end;

  if efUnhandled in iFlags then goto __SkipChecks;

  if bMustLog then
  begin
    for iIdx := 0 to Length(tItemInfos) -1 do
    begin
      if fIgnoredRaiseSources.IndexOf(tItemInfos[iIdx].Addr) <> -1 then
      begin
        bMustLog := False;
        Break;
      end;
    end;
  end;

  if bMustLog then
  begin
    if Assigned(Exc) then
    begin
      bMustLog := fIgnoredExceptionTypes.IndexOf(Exc.ClassType) = -1;
    end;
  end;

  if not bMustLog then
  begin
    for iIdx := 0 to Length(tItemInfos) -1 do
    begin
      if fForceLogRaiseSources.IndexOf(tItemInfos[iIdx].Addr) <> -1 then
      begin
        bMustLog := True;
        Break;
      end;
    end;

    if not bMustLog and Assigned(Exc) then
    begin
      bMustLog := fForceLogExceptionTypes.IndexOf(Exc.ClassType) <> -1;
    end;
  end;

  if not bMustLog then Exit;

  __SkipChecks:
  iFirst := -1;
  if StringsEqualNoCase(tItemInfos[0].Module, 'kernel32.dll') then
  begin
    { A check for RaiseException }
    if Length(CallStack) > 1 then
    begin
      pFirstEntry := CallStack[1];
      tItemInfos[0].Module := '';
      tItemInfos[0].Routine := '';
      tItemInfos[0].Source := '';

      iFirst := 1;
    end else pFirstEntry := nil;
  end else
  begin
    iFirst := 0;
    pFirstEntry := CallStack[0];
  end;

  if pFirstEntry = nil then Exit;

  sFmtHeader := StringOfChar('=', 80) + EOL;
  with tItemInfos[0] do
  begin
    (SystemTypeRegistry.GetTypeInfo('TExceptionFlags') as
      ISetTypeInfo).SetToString(iFlags, sFlags);
    if efSystem in iFlags then
    begin
      sFmtHeader := sFmtHeader + RsErrLogHeader + RsErrLogSysStart +
        RsErrLogCall  + RsErrLogExtraFlags;
      sFmtHeader := Format(sFmtHeader, [sDate, ConvertRuntimeErrorToString(RaisedExc),
        LineNumber, Source, sFlags]);
    end else if efDelphi in iFlags then
    begin
      sFmtHeader := sFmtHeader + RsErrLogHeader + RsErrLogStart +
        RsErrLogCall + RsErrLogExtraFlags;
      sFmtHeader := Format(sFmtHeader, [sDate, Exc.ClassName, Exc.Message,
        LineNumber, Source, sFlags]);
    end;
  end;

  if not DirectoryExists(fLogPath) then CreateDir(fLogPath);

  sSepLine := StringOfChar('-', 80);
  
  cLog := SystemLogger.CreateLog(Format(fLogPath + '%s.log', [StringReplace(sDate,
    ':', '.', [rfReplaceAll])]), -1, lmSync);
  try
    cLog.Open;

    cLog.Write(sFmtHeader);
    cLog.Write(sSepLine);
    cLog.WriteResFmt(@RsErrYAWEInfo, [ProgramVersion]);
    cLog.Write(GetOSAndCPUInfo);
    cLog.Write(GetMemoryInfo);
    cLog.Write(sSepLine);

    if Length(CallStack) <> 0 then
    begin
      cLog.WriteRes(@RsErrLogStack);
      for iIdx := iFirst to Length(tItemInfos) -1 do
      begin
        with tItemInfos[iIdx] do
        begin
          FormatRoutineName(Routine, Module);
          cLog.WriteFmt(FormatStr, [CallStack[iIdx], Module, Routine,
            IntToHex(Displacement, 2)]);
        end;
      end;
    end else
    begin
      cLog.WriteRes(@RsErrLogNoStack);
    end;

    cLog.Write('');
    cLog.Write(sSepLine);
    cLog.Write(GetLoadedModulesList);
  finally
    cLog.Free;
  end;
end;

procedure YIoErrorManager.CatchCriticalException(Watcher: TExceptionWatcher;
  const RaisedExc: TRaisedExceptionInfo);
var
  aCallStack: TCallStack;
begin
  if not DisabledLogging then DisabledLogging := True else Exit;
  fLock.Enter;
  try
    Watcher.GetCallStack(RaisedExc, aCallStack);
    { Now we'll format the stack trace into a nice and clean log }
    OutputStackTrace(aCallStack, RaisedExc.ExceptionObject, RaisedExc, Watcher);
  finally
    fLock.Leave;
  end;
  DisabledLogging := False;
end;

end.
