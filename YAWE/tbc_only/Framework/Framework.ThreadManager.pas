{*------------------------------------------------------------------------------
  Thread manager. Contructs thread handles and balances load.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Framework.ThreadManager;

interface

uses
  API.Win.Types,
  API.Win.NtCommon,
  API.Win.Kernel,
  Framework.Base,
  SysUtils,
  DateUtils,
  Classes,
  Bfg.Utils,
  Bfg.Containers,
  Bfg.Algorithm,
  Bfg.Threads;

type
  TThreadManager = class;
  TThreadHandle = class;
  TThreadHandleClass = class of TThreadHandle;

  TThreadMethod = procedure(Thread: TThreadHandle) of object;

  PPerProcessorData = ^TPerProcessorData;
  TPerProcessorData = record
    AffinityMaskIndex: Int32;
    TotalExecutionTime: TDateTime;
    RunningThreads: array of TThreadHandle;
  end;

  TPackedTime = packed record
    Days: Word;
    Hours: Byte;
    Mins: Byte;
    Secs: Byte;
    MSecs: Word;
  end;

  TThreadHandle = class(TReferencedObject)
    private
      fOwner: TThreadManager;
      fData: TThreadCreateInfo;
      fName: string;
      fCreationTime: TDateTime;
      fExecutionTime: TDateTime;
      fExecTime2: TPackedTime;
      fAffineProcessors: array of PPerProcessorData;
      fRestartable: Longbool;
      fTerminated: Longbool;
      fMethod: TThreadMethod;
      fStartEvent: TEvent;
      fEndEvent: TEvent;
      fThreadGroups: TStrPtrHashMap;

      procedure SetPrio(Priority: TThreadPriority);
      function GetPrio: TThreadPriority;
    public
      constructor Create; virtual;
      destructor Destroy; override;

      function Suspend: Boolean;
      function Resume: Boolean;

      function AddAffineProcessor(ProcessorIndex: Int32): Boolean;

      procedure Terminate;

      function WaitForStart(TimeOut: Int32): Boolean;
      function WaitForEnd(TimeOut: Int32): Boolean;

      property ThreadId: UInt32 read fData.ThreadId;
      property Name: string read fName;
      property Priority: TThreadPriority read GetPrio write SetPrio;
      property Terminated: Longbool read fTerminated;
  end;

  PThreadHandleInfo = ^TThreadHandleInfo;
  TThreadHandleInfo = record
    Name: string;
    ThreadId: Longword;
    CreationTime: TDateTime;
    ExecutionTime: TPackedTime;
    AffinityMask: Longword;
  end;

  TThreadInfoArray = array of TThreadHandleInfo;

  TThreadStartEvent = procedure(Sender: TThreadManager; Thread: TThreadHandle) of object;
  TThreadSuspendEvent = procedure(Sender: TThreadManager; Thread: TThreadHandle) of object;
  TThreadResumeEvent = procedure(Sender: TThreadManager; Thread: TThreadHandle) of object;
  TThreadExceptionEvent = procedure(Sender: TThreadManager; Thread: TThreadHandle; ExcObject: Exception) of object;
  TThreadFinishEvent = procedure(Sender: TThreadManager; Thread: TThreadHandle) of object;

  TThreadManager = class(TReferencedObject)
    private
      fLock: TReaderWriterLock;
      fThreads: array of TThreadHandle;
      fProcessors: array of PPerProcessorData;

      fOnStart: TThreadStartEvent;
      fOnSuspend: TThreadSuspendEvent;
      fOnResume: TThreadResumeEvent;
      fOnException: TThreadExceptionEvent;
      fOnEnd: TThreadFinishEvent;

      function GetThreadCount: Int32; inline;
      function GetThreadsPerProcessor(ProcessorIndex: Int32): Int32;
      function GetProcessorCount: Int32; inline;

      procedure GetAvailableProcessors;
      function FindLessUsedProcessor: PPerProcessorData;
      function GenerateThreadName(Thread: TThreadHandle): string;
      function GetThreadByName(const ThreadName: string): TThreadHandle;
      procedure SetThreadProcessor(Thread: TThreadHandle; Processor: PPerProcessorData);
      procedure RemoveThread(Thread: TThreadHandle);
      procedure AddThread(Thread: TThreadHandle);

      procedure DoOnStart(Thread: TThreadHandle);
      procedure DoOnSuspend(Thread: TThreadHandle);
      procedure DoOnResume(Thread: TThreadHandle);
      procedure DoOnException(Thread: TThreadHandle; Exc: Exception);
      procedure DoOnFinish(Thread: TThreadHandle);
    public
      constructor Create;
      destructor Destroy; override;

      function CreateThread(Method: TThreadMethod; Suspended: Boolean;
        const Name: string = ''; RestartOnException: Boolean = False): TThreadHandle;

      function CreateThreadEx(Method: TThreadMethod; Suspended: Boolean;
        HandleClass: TThreadHandleClass; const Name: string = '';
        RestartOnException: Boolean = False): TThreadHandle;

      function EnumThreadsInfo: TThreadInfoArray;
      function GetThreadInfo(const Name: string; out Info: TThreadHandleInfo): Boolean;

      property Threads[const Name: string]: TThreadHandle read GetThreadByName;
      property ThreadCount: Int32 read GetThreadCount;
      property ThreadsPerProcessor[ProcessorIndex: Int32]: Int32 read GetThreadsPerProcessor;
      property ProcessorCount: Int32 read GetProcessorCount;

      property OnThreadStart: TThreadStartEvent read fOnStart write fOnStart;
      property OnThreadSuspend: TThreadSuspendEvent read fOnSuspend write fOnSuspend;
      property OnThreadResume: TThreadResumeEvent read fOnResume write fOnResume;
      property OnThreadException: TThreadExceptionEvent read fOnException write fOnException;
      property OnThreadFinish: TThreadFinishEvent read fOnEnd write fOnEnd;
  end;

implementation

uses
  API.Win.NtStatus,
  API.Win.NtApi,
  API.Win.TlHelp32,
  Bfg.SystemInfo,
  Framework;

function CompareThreadHandles(T1, T2: TThreadHandle): Int32;
begin
  Result := StringsCompare(T1.fName, T2.fName);
end;

function MatchThreadHandle(const Name: string; T: TThreadHandle): Int32;
begin
  Result := StringsCompare(Name, T.fName);
end;

procedure FileTimeToDateTime(const FileTime: TFileTime; out DateTime: TDateTime);
var
  LocalTime: TFileTime;
  SysTime: TSystemTime;
begin
  FileTimeToLocalFileTime(FileTime, LocalTime);
  FileTimeToSystemTime(LocalTime, SysTime);
  with SysTime do
  begin
    DateTime := EncodeDate(wYear, wMonth, wDay) +
      EncodeTime(wHour, wMinute, wSecond, wMilliSeconds);
  end;
end;

procedure ElapsedToPackedTime(const FileTime: TFileTime; out PackedTime: TPackedTime);
var
  Days: Int64;
  Hours: Int64;
  Mins: Int64;
  Secs: Int64;
  Milisecs: Int64;
begin
  Milisecs := Int64(FileTime) div 1000;
  Secs := Milisecs div 1000;
  Milisecs := Milisecs mod 1000;
  Mins := Secs div 60;
  Secs := Secs mod 60;
  Hours := Mins div 60;
  Mins := Mins mod 60;
  Days := Hours div 60;
  Hours := Hours mod 60;

  PackedTime.Days := Days;
  PackedTime.Hours := Hours;
  PackedTime.Mins := Mins;
  PackedTime.Secs := Secs;
  PackedTime.MSecs := Milisecs;
end;

function CreateAffinityMask(const pProcs: array of PPerProcessorData): UInt32;
var
  iI: Int32;
begin
  Result := 0;
  for iI := 0 to High(pProcs) do
  begin
    Result := Result or (1 shl pProcs[iI]^.AffinityMaskIndex);
  end;
end;

procedure UpdateThreadTimes(Thread: TThreadHandle);
var
  tCreation: TFileTime;
  tExit: TFileTime;
  tUser: TFileTime;
  tKernel: TFileTime;
  dUser: TDateTime;
  dKernel: TDateTime;
begin
  GetThreadTimes(Thread.fData.Handle, @tCreation, @tExit, @tKernel, @tUser);
  FileTimeToDateTime(tCreation, Thread.fCreationTime);
  FileTimeToDateTime(tKernel, dKernel);
  FileTimeToDateTime(tUser, dUser);
  Thread.fExecutionTime := dKernel + dUser;
  ElapsedToPackedTime(TFileTime(Int64(tKernel) + Int64(tUser)), Thread.fExecTime2);
end;

function ThreadMgrExecuteMethod(Data: PThreadCreateInfo): UInt32;
var
  cThread: TThreadHandle;
  bException: Boolean;
label
  __Restart;
begin
  cThread := Data^.Param;

  cThread.fOwner.fLock.BeginWrite;
  try
    UpdateThreadTimes(cThread);
    SetThreadAffinityMask(cThread.fData.Handle, CreateAffinityMask(cThread.fAffineProcessors));
  finally
    cThread.fOwner.fLock.EndWrite;
  end;

  try
    cThread.fStartEvent.Signal;
    cThread.fOwner.DoOnStart(cThread);
    __Restart:
    bException := False;
    try
      cThread.fMethod(cThread);
    except
      on E: Exception do
      begin
        cThread.fOwner.DoOnException(cThread, E);
        if not cThread.fRestartable then raise else bException := True;
      end;
    end;
    if bException then goto __Restart;
  finally
    cThread.fOwner.fLock.BeginWrite;
    try
      cThread.fEndEvent.Signal;
      cThread.fOwner.DoOnFinish(cThread);
      cThread.fOwner.RemoveThread(cThread);
    finally
      cThread.fOwner.fLock.EndWrite;
    end;
  end;
  Result := 0;
end;

{ YThreadManager }

constructor TThreadManager.Create;
begin
  GetAvailableProcessors;
  fLock.Init;
end;

destructor TThreadManager.Destroy;
var
  iInt: Int32;
begin
  for iInt := 0 to High(fThreads) do
  begin
    fThreads[iInt].Free;
  end;

  for iInt := 0 to High(fProcessors) do
  begin
    Dispose(PPerProcessorData(fProcessors[iInt]));
  end;

  fLock.Delete;
  inherited Destroy;
end;

procedure TThreadManager.DoOnStart(Thread: TThreadHandle);
begin
  if Assigned(fOnStart) then fOnStart(Self, Thread);
end;

procedure TThreadManager.DoOnFinish(Thread: TThreadHandle);
begin
  if Assigned(fOnEnd) then fOnEnd(Self, Thread);
end;

procedure TThreadManager.DoOnException(Thread: TThreadHandle; Exc: Exception);
begin
  if Assigned(fOnException) then fOnException(Self, Thread, Exc);
end;

procedure TThreadManager.DoOnResume(Thread: TThreadHandle);
begin
  if Assigned(fOnResume) then fOnResume(Self, Thread);
end;

procedure TThreadManager.DoOnSuspend(Thread: TThreadHandle);
begin
  if Assigned(fOnSuspend) then fOnSuspend(Self, Thread);
end;

function TThreadManager.CreateThread(Method: TThreadMethod; Suspended: Boolean;
  const Name: string; RestartOnException: Boolean): TThreadHandle;
begin
  Result := CreateThreadEx(Method, Suspended, TThreadHandle, Name,
    RestartOnException); 
end;

function TThreadManager.CreateThreadEx(Method: TThreadMethod;
  Suspended: Boolean; HandleClass: TThreadHandleClass; const Name: string;
  RestartOnException: Boolean): TThreadHandle;
var
  iCnt: Int32;
  sTemp: string;
begin
  fLock.BeginWrite;
  try
    Result := HandleClass.Create;
    if Name <> '' then
    begin
      iCnt := 0;
      sTemp := Name;
      Result.fName := Name;
      
      while GetThreadByName(sTemp) <> nil do
      begin
        Inc(iCnt);
        sTemp := Result.fName + '_' + IntToStr(iCnt);
      end;

      if iCnt <> 0 then
      begin
        Result.fName := sTemp;
      end;
    end else
    begin
      Result.fName := GenerateThreadName(Result);
    end;

    Result.fRestartable := RestartOnException;
    Result.fMethod := Method;
    Result.fOwner := Self;
    AddThread(Result);

    StartThreadAtAddress(@ThreadMgrExecuteMethod, Result, True, Result.fData);
    SetThreadProcessor(Result, FindLessUsedProcessor);

    if not Suspended then
    begin
      ThreadModifyState(Result.fData.Handle, False);
    end;
  finally
    fLock.EndWrite;
  end;
end;

procedure TThreadManager.RemoveThread(Thread: TThreadHandle);
var
  iIdx, iInt: Int32;
begin
  iIdx := BinarySearch(Pointer(Thread.fName), @fThreads[0], Length(fThreads), @MatchThreadHandle);
  if iIdx <> -1 then
  begin
    if iIdx <> Length(fThreads) -1 then
    begin
      Move(fThreads[iIdx+1], fThreads[iIdx], (Length(fThreads) - iIdx - 1) * SizeOf(Pointer));
    end;
    SetLength(fThreads, High(fThreads));

    for iInt := 0 to High(Thread.fAffineProcessors) do
    begin
      with Thread.fAffineProcessors[iInt]^ do
      begin
        for iIdx := 0 to Length(RunningThreads) -1 do
        begin
          if RunningThreads[iIdx] = Thread then
          begin
            RunningThreads[iIdx] := RunningThreads[High(RunningThreads)];
            Break;
          end;
        end;
        SetLength(RunningThreads, High(RunningThreads));
      end;
    end;
  end;

  Thread.Free;
end;

procedure TThreadManager.AddThread(Thread: TThreadHandle);
var
  iLen: Int32;
begin
  iLen := Length(fThreads);
  SetLength(fThreads, iLen + 1);
  fThreads[iLen] := Thread;

  SortArray(@fThreads[0], iLen + 1, @CompareThreadHandles, shSorted);
end;

function TThreadManager.FindLessUsedProcessor: PPerProcessorData;
var
  iI, iJ: Int32;
  dHighest: TDateTime;
begin
  Result := fProcessors[0];
  if ProcessorCount = 1 then Exit;

  dHighest := 0;

  for iI := 0 to High(fProcessors) do
  begin
    with fProcessors[iI]^ do
    begin
      TotalExecutionTime := 0;

      for iJ := 0 to High(RunningThreads) do
      begin
        UpdateThreadTimes(RunningThreads[iJ]);
        TotalExecutionTime := TotalExecutionTime + RunningThreads[iJ].fExecutionTime;
      end;

      if TotalExecutionTime > dHighest then Result := fProcessors[iI];
    end;
  end;
end;

function TThreadManager.GenerateThreadName(Thread: TThreadHandle): string;
begin
  Result := 'Thread__' + IntToStr(Thread.ThreadId);
end;

procedure TThreadManager.GetAvailableProcessors;
var
  lwSystemMask: UInt32;
  lwProcessMask: UInt32;
  iLen: Int32;
  iInt: Int32;
  pCpuData: PPerProcessorData;
begin
  GetProcessAffinityMask(GetCurrentProcess, @lwProcessMask, @lwSystemMask);
  if lwProcessMask <> lwSystemMask then
  begin
    SetProcessAffinityMask(GetCurrentProcess, lwSystemMask);
  end;
  
  for iInt := 0 to 31 do
  begin
    if GetBit32(lwSystemMask, iInt) then
    begin
      New(pCpuData);
      pCpuData^.AffinityMaskIndex := iInt;

      iLen := Length(fProcessors);
      SetLength(fProcessors, iLen + 1);
      fProcessors[iLen] := pCpuData;
    end;
  end;
end;

function TThreadManager.GetProcessorCount: Int32;
begin
  Result := Length(fProcessors);
end;

procedure TThreadManager.SetThreadProcessor(Thread: TThreadHandle;
  Processor: PPerProcessorData);
var
  iLen: Int32;
begin
  iLen := Length(Thread.fAffineProcessors);
  SetLength(Thread.fAffineProcessors, iLen + 1);
  Thread.fAffineProcessors[iLen] := Processor;

  iLen := Length(Processor^.RunningThreads);
  SetLength(Processor^.RunningThreads, iLen + 1);
  Processor^.RunningThreads[iLen] := Thread;

  SetThreadAffinityMask(Thread.fData.Handle, 1 shl Processor^.AffinityMaskIndex);
end;

function TThreadManager.GetThreadByName(const ThreadName: string): TThreadHandle;
var
  iIdx: Int32;
begin
  fLock.BeginRead;
  try
    iIdx := BinarySearch(Pointer(ThreadName), @fThreads[0], Length(fThreads),
      @MatchThreadHandle);
    if iIdx <> -1 then
    begin
      Result := fThreads[iIdx];
    end else Result := nil;
  finally
    fLock.EndRead;
  end;
end;

function TThreadManager.GetThreadCount: Int32;
begin
  Result := Length(fThreads);
end;

function TThreadManager.EnumThreadsInfo: TThreadInfoArray;
var
  iInt: Int32;
begin
  fLock.BeginWrite;
  try
   SetLength(Result, Length(fThreads));
   for iInt := 0 to High(fThreads) do
   begin
     UpdateThreadTimes(fThreads[iInt]);
     Result[iInt].Name := fThreads[iInt].Name;
     Result[iInt].ThreadId := fTHreads[iInt].ThreadId;
     Result[iInt].CreationTime := fThreads[iInt].fCreationTime;
     Result[iInt].ExecutionTime := fThreads[iInt].fExecTime2;
     Result[iInt].AffinityMask := CreateAffinityMask(fThreads[iInt].fAffineProcessors);
   end;
  finally
    fLock.EndWrite;
  end;
end;

function TThreadManager.GetThreadInfo(const Name: string;
  out Info: TThreadHandleInfo): Boolean;
var
  cThread: TThreadHandle;
begin
  fLock.BeginWrite;
  try
    cThread := Self.Threads[Name];
    if cThread <> nil then
    begin
      UpdateThreadTimes(cThread);
      Info.Name := cThread.Name;
      Info.ThreadId := cThread.ThreadId;
      Info.CreationTime := cThread.fCreationTime;
      Info.ExecutionTime := cThread.fExecTime2;
      Info.AffinityMask := CreateAffinityMask(cThread.fAffineProcessors);
      Result := True;
    end else Result := False;
  finally
    fLock.EndWrite;
  end;
end;

function TThreadManager.GetThreadsPerProcessor(ProcessorIndex: Int32): Int32;
begin
  fLock.BeginRead;
  try
    if ProcessorIndex >= Length(fProcessors) then
    begin
      Result := -1;
    end else
    begin
      Result := Length(fProcessors[ProcessorIndex]^.RunningThreads);
    end;
  finally
    fLock.EndRead;
  end;
end;

{ YThreadHandle }

constructor TThreadHandle.Create;
begin
  inherited Create;
  fStartEvent.Init(False, True);
  fEndEvent.Init(False, True);
  fThreadGroups := TStrPtrHashMap.Create(False);
end;

destructor TThreadHandle.Destroy;
begin
  fStartEvent.Delete;
  fEndEvent.Delete;
  fThreadGroups.Free;
  inherited Destroy;
end;

function TThreadHandle.AddAffineProcessor(ProcessorIndex: Int32): Boolean;
begin
  fOwner.fLock.BeginWrite;
  try
    if ProcessorIndex >= Length(fOwner.fProcessors) then
    begin
      Result := False;
    end else
    begin
      fOwner.SetThreadProcessor(Self, fOwner.fProcessors[ProcessorIndex]);
      Result := True;
    end;
  finally
    fOwner.fLock.EndWrite;
  end;
end;

function TThreadHandle.GetPrio: TThreadPriority;
begin
  ThreadModifyPriority(fData.Handle, Result, False);
end;

procedure TThreadHandle.SetPrio(Priority: TThreadPriority);
begin
  ThreadModifyPriority(fData.Handle, Priority, True);
end;

function TThreadHandle.Resume: Boolean;
begin
  if API.Win.Kernel.ResumeThread(fData.Handle) <> $FFFFFFFF then
  begin
    fOwner.DoOnResume(Self);
    Result := True;
  end else Result := False;
end;

function TThreadHandle.Suspend: Boolean;
begin
  if API.Win.Kernel.SuspendThread(fData.Handle) <> $FFFFFFFF then
  begin
    fOwner.DoOnSuspend(Self);
    Result := True;
  end else Result := False;
end;

procedure TThreadHandle.Terminate;
begin
  AtomicInc(@fTerminated);
end;

function TThreadHandle.WaitForEnd(TimeOut: Int32): Boolean;
begin
  if fData.Handle = INVALID_HANDLE_VALUE then
  begin
    Result := True;
    Exit;
  end;
  Result := fEndEvent.WaitFor(TimeOut) = WAIT_OBJECT_0;
end;

function TThreadHandle.WaitForStart(TimeOut: Int32): Boolean;
begin
  if fData.Handle = INVALID_HANDLE_VALUE then
  begin
    Result := True;
    Exit;
  end;
  Result := fStartEvent.WaitFor(TimeOut) = WAIT_OBJECT_0;
end;

end.
