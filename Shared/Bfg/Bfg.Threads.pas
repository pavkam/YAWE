{*------------------------------------------------------------------------------
  Thread Creation and Manipulation
  Threading and Interlocked functions and synchronization primitives.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Bfg.Threads;

interface

uses
  API.Win.Types,
  API.Win.Kernel,
  API.Win.NtCommon,
  API.Win.NtStatus,
  API.Win.NtApi,
  Bfg.Utils,
  Classes,
  SysUtils;

type
  TCriticalSection = record
    private
      FData: TRTLCriticalSection;
    public
      procedure Init(SpinCount: Integer = 2500);
      procedure Delete;

      procedure Enter;
      procedure Leave;
  end;

  TEvent = record
    private
      FHandle: THandle;
    public
      procedure Init(InitialState: Boolean; ManualReset: Boolean);
      procedure Delete;

      procedure Signal;
      procedure Reset;
      function WaitFor(TimeOut: Integer): Longword; 
  end;

  PThreadInfo = ^TThreadInfo;
  TThreadInfo = record
    Next: PThreadInfo;
    ThreadID: Longword;
    Active: Integer;
    RecursionCount: Longword;
  end;

  TReaderWriterLock = record
    private
      FSentinel: Integer;

      FReadSignal: THandle;
      FWriteSignal: THandle;

      FWriteRecursionCount: Longword;
      FTls: array[0..63] of PThreadInfo;
      FWriterID: Longword;

      function TlsLookupThreadInfo(ThreadId: Longword; Index: PInteger = nil): PThreadInfo;
      function TlsRecycle: PThreadInfo;

      procedure TlsOpen(var Thread: PThreadInfo);
      procedure TlsDelete(var Thread: PThreadInfo);
    public
      procedure Init;
      procedure Delete;
      procedure BeginRead;
      procedure EndRead;
      procedure BeginWrite;
      procedure EndWrite;
  end;

  PAtomicListEntry = ^TAtomicListEntry;
  TAtomicListEntry = record
    Next: PAtomicListEntry;
  end;

type  
  PAtomicListHead = ^TAtomicListHead;
  TAtomicListHead = record
    Start: PAtomicListEntry;
    Depth: Integer;
  end;

type
  PThreadCreateInfo = ^TThreadCreateInfo;
  TThreadCreateInfo = record
    Param: Pointer;
    Handle: THandle;
    ThreadId: Longword;
  end;

  TThreadProc = function(pThrdData: PThreadCreateInfo): Longword;

  TThreadCleanupProc = procedure(pParam: Pointer);

const
  Priorities: array[TThreadPriority] of Longword = (
    THREAD_PRIORITY_IDLE, THREAD_PRIORITY_LOWEST, THREAD_PRIORITY_BELOW_NORMAL,
    THREAD_PRIORITY_NORMAL, THREAD_PRIORITY_ABOVE_NORMAL,
    THREAD_PRIORITY_HIGHEST, THREAD_PRIORITY_TIME_CRITICAL
  );

procedure StartThreadAtAddress(Addr: TThreadProc; Param: Pointer; Suspended: Boolean;
  var ThreadInfo: TThreadCreateInfo; const ThreadName: string = '');

procedure ThreadPushCleanupRoutine(Cleanup: TThreadCleanupProc; Param: Pointer);

procedure ThreadPopCleanupRoutine(ExecuteHandler: Boolean);

function ShrinkStack: Boolean;

procedure ThreadExit(Result: Longword);
procedure ThreadModifyPriority(Handle: THandle; var Prio: TThreadPriority; Change: Boolean);
procedure ThreadModifyState(Handle: THandle; Suspend: Boolean);

{ Atomic (Interlocked) functions
  All functions containing word "exchange" in their name return the original value
  held in the source location. If they do not contain such word, they return the
  altered value.
}
procedure InitializeAtomicSList(ListHead: PAtomicListHead);
function AtomicPushEntrySList(ListHead: PAtomicListHead; Entry: Pointer): Pointer;
function AtomicPopEntrySList(ListHead: PAtomicListHead): Pointer;
function QueryDepthAtomicSList(ListHead: PAtomicListHead): Integer;
procedure AtomicFlushSList(ListHead: PAtomicListHead);

function AtomicInc(Addend: PLongword): Longword;
function AtomicDec(Substrahend: PLongword): Longword;
function AtomicAdd(Addend: PLongword; Value: Longword): Longword;
function AtomicSub(Substrahend: PLongword; Value: Longword): Longword;

procedure AtomicAnd8(Target: PByte; Mask: Byte);
procedure AtomicOr8(Target: PByte; Mask: Byte);
procedure AtomicXor8(Target: PByte; Mask: Byte);
procedure AtomicNot8(Target: PByte);

procedure AtomicAnd16(Target: PWord; Mask: Word);
procedure AtomicOr16(Target: PWord; Mask: Word);
procedure AtomicXor16(Target: PWord; Mask: Word);
procedure AtomicNot16(Target: PWord);

procedure AtomicAnd32(Target: PLongword; Mask: Longword);
procedure AtomicOr32(Target: PLongword; Mask: Longword);
procedure AtomicXor32(Target: PLongword; Mask: Longword);
procedure AtomicNot32(Target: PLongword);

function AtomicExchangeInc(Addend: PLongword): Longword;
function AtomicExchangeDec(Substrahend: PLongword): Longword;
function AtomicExchangeAdd(Addend: PLongword; Value: Longword): Longword;
function AtomicExchangeSub(Substrahend: PLongword; Value: Longword): Longword;

function AtomicExchange(Value: PLongword; Exchange: Longword): Longword;

function AtomicCompareExchange(Value: PLongword; Exchange: Longword;
  Comperand: Longword): Longword;

function AtomicIncPtr(Addend: PPointer): Pointer;
function AtomicDecPtr(Substrahend: PPointer): Pointer;
function AtomicAddPtr(Addend: PPointer; Value: Pointer): Pointer;
function AtomicSubPtr(Substrahend: PPointer; Value: Pointer): Pointer;

function AtomicExchangeIncPtr(Addend: PPointer): Pointer;
function AtomicExchangeDecPtr(Substrahend: PPointer): Pointer;
function AtomicExchangeAddPtr(Addend: PPointer; Value: Pointer): Pointer;
function AtomicExchangeSubPtr(Substrahend: PPointer; Value: Pointer): Pointer;

function AtomicExchangePtr(Value: PPointer; Exchange: Pointer): Pointer;

function AtomicCompareExchangePtr(Value: PPointer; Exchange: Pointer;
  Comperand: Pointer): Pointer;

{
  Custom simple atomic functions can be made by using AtomicCompareExchange.
  Things like AtomicMul can be made as well as AtomicSh(r)/(l). AtomicDiv
  could also work but due to the fact that division takes quite a lot of CPU
  cycles I would not advise it.

  Prototypes of such custom functions:

  function AtomicXXX(pValue: PLongword; lwParam: Longword): Longword;
  var
    lwOldVal: Longword;
  begin
    repeat
      lwOldVal := pValue^;
      Result := Operation(lwOldVal, lwParam);
    until AtomicCompareExchange(pValue, Result, lwOldVal) = lwOldVal;
  end;

  function AtomicExchangeXXX(pValue: PLongword; lwParam: Longword): Longword;
  var
    lwNewVal: Longword;
  begin
    repeat
      Result := pValue^;
      lwNewValue := Operation(Result, lwParam);
    until AtomicCompareExchange(pValue, lwNewVal, Result) = Result;
  end;
}

procedure ThreadCleanupProc(Data: PThreadCreateInfo);

type
  TApcProc = procedure(Context1, Context2: Pointer; QueryingThreadId: Longword; const QueriedAt: TDateTime);
  TApcEvent = procedure(Context: Pointer; QueryingThreadId: Longword; const QueriedAt: TDateTime) of object;

function SleepAndProcessApcQueue(Miliseconds: Longword): Longword;
function ProcessApcQueue(MaxMiliseconds: Longword = 0): Longword;
function WaitForApc(Timeout: Integer): Boolean;

procedure QueueApc(TargetThreadId: Longword; ApcProc: TApcProc; Context1, Context2: Pointer); overload;
procedure QueueApc(TargetThreadId: Longword; ApcEvent: TApcEvent; Context: Pointer); overload;

implementation

{$G-}

uses
  MMSystem,
  Bfg.Containers,
  Bfg.SystemInfo,
  Bfg.Algorithm,
  DateUtils,
  Math;

const
  TTL_SIZE = 64;

type
  PApcEntry = ^TApcEntry;
  TApcEntry = record
    Apc: TApcProc;
    Contexts: array[0..1] of Pointer;
    QueryingThreadId: Longword;
    QueriedAt: TDateTime;
  end;

  TApcEntryArray = array of TApcEntry;

  PThreadCleanupChainElem = ^TThreadCleanupChainElem;
  TThreadCleanupChainElem = record
    Proc: TThreadCleanupProc;
    Arg: Pointer;
    LowerCleanupProc: PThreadCleanupChainElem;
  end;

  TThreadInfoFlag = (tifDelphiThread, tifHasHandle, tifHasId, tifHasName);
  TThreadInfoFlags = set of TThreadInfoFlag;

  PThreadSpecificData = ^TThreadSpecificData;

  TApcDispatchProc = function(ExecTimeOverride: Longword): Longword;

  TThreadSpecificData = record
    Name: string;
    Flags: TThreadInfoFlags;
    Pad: array[0..2] of Byte;
    ThreadHandle: THandle;
    ThreadId: Longword;
    ThreadStartAddr: TThreadProc;
    Lock: TCriticalSection;
    CleanupChainStart: PThreadCleanupChainElem;
    Info: PThreadCreateInfo;
    ApcDispatch: TApcDispatchProc;
    Apcs: TApcEntryArray;
    ApcDispatchExecutionLimit: Longword; { in msecs }
    ApcWaitHandle: THandle;
  end;

  PThreadLocalTableEntry = ^TThreadLocalTableEntry;
  TThreadLocalTableEntry = packed record
    Next: PThreadLocalTableEntry;
    ThreadId: Longword;
    UserData: Pointer;
  end;

  PThreadLocalTable = ^TThreadLocalTable;
  TThreadLocalTable = record
    Entries: array[0..TTL_SIZE-1] of PThreadLocalTableEntry;
    Sentinel: Longword;
    SpinCountMax: Integer;
    CritSect: RTL_CRITICAL_SECTION;
  end;

  PPPendingApcs = ^PPendingApcs;
  PPendingApcs = ^TPendingApcs;
  TPendingApcs = record
    Apcs: TApcEntryArray;
    ApcCount: Integer;
    WaitHandle: THandle;
  end;

  PThreadSharedData = ^TThreadSharedData;
  TThreadSharedData = record
    PendingApcs: TThreadLocalTable;
  end;

threadvar
  ThreadSpecifics: TThreadSpecificData;

var
  ThreadShared: TThreadSharedData;

const
  THREAD_APC_NOT_ALLOWED = Longword(-1);
  THREAD_APC_NO_EXECUTION_LIMIT = 0;

procedure FixupThreadId(Data: PThreadSpecificData; var ThreadId: Longword); inline;
begin
  if ThreadId = 0 then
  begin
    if tifHasId in Data^.Flags then
    begin
      ThreadId := Data^.ThreadId;
    end else
    begin
      ThreadId := GetCurrentThreadId;
      Data^.ThreadId := ThreadId;
      Include(Data^.Flags, tifHasId);
    end;
  end;
end;

const
  HASH_BITMASK = TTL_SIZE - 1;

procedure ThreadLocalTableInitialize(var Table: TThreadLocalTable; MaxSpinCount: Longword);
begin
  FillChar(Table, SizeOf(Table), 0);

  Table.SpinCountMax := MaxSpinCount;
  InitializeCriticalSectionAndSpinCount(Table.CritSect, MaxSpinCount);
end;

procedure ThreadLocalTableDelete(var Table: TThreadLocalTable);
var
  I: Integer;
  Temp, Entry: PThreadLocalTableEntry;
begin
  // Wait till all threads leave the table
  while AtomicCompareExchange(@Table.Sentinel, $FFFFFFFF, 0) <> 0 do;

  DeleteCriticalSection(Table.CritSect);

  for I := 0 to Length(Table.Entries) -1 do
  begin
    Entry := Table.Entries[I];
    while Entry <> nil do
    begin
      Temp := Entry;
      Entry := Entry^.Next;
      Dispose(Temp);
    end;
  end;
end;

function TltIncSentinel(const Table: TThreadLocalTable): Boolean;
var
  Value: Longword;
begin
  repeat
    Value := Table.Sentinel;
    if Value = $FFFFFFFF then
    begin
      Result := False;
      Exit;
    end;
  until AtomicCompareExchange(@Table.Sentinel, Value + 1, Value) = Value;
  Result := True;
end;

procedure TltDecSentinel(const Table: TThreadLocalTable);
begin
  AtomicDec(@Table.Sentinel);
end;

procedure ThreadLocalTableAcquire(var Table: TThreadLocalTable;
  out Entry: PThreadLocalTableEntry; ThreadId: Longword = 0);
var
  Data: PThreadSpecificData;
  HeadEntry: PThreadLocalTableEntry;
  SelfThreadId: Longword;
  HashIndex: Byte;
begin
  // If a table is being destroyed while trying to acquire it then we just return nil
  Entry := nil;
  if not TltIncSentinel(Table) then
  begin
    Exit;
  end;

  Data := @ThreadSpecifics;
  SelfThreadId := 0;
  FixupThreadId(Data, SelfThreadId);
  if ThreadId = 0 then ThreadId := SelfThreadId;
  //SentinelValue := SentinelValues[ThreadId = SelfThreadId];

  HashIndex := HashLong(ThreadId) and HASH_BITMASK;
  // We must make other threads spin while we're looking for an entry so we
  // replace the head entry with an entry which points to itself and has a
  // thread id of 0

  EnterCriticalSection(Table.CritSect);

  Entry := Table.Entries[HashIndex];
  HeadEntry := Entry;
  while (Entry <> nil) and (Entry^.ThreadId <> ThreadId) do
  begin
    Entry := Entry^.Next;
  end;

  if Entry = nil then
  begin
    // No entry for the specified thread id exists, we can create a new one
    Entry := AllocMem(SizeOf(TThreadLocalTableEntry));
    Entry^.ThreadId := ThreadId;
    Entry^.Next := HeadEntry;
    Table.Entries[HashIndex] := Entry;
  end;
end;

procedure ThreadLocalTableRelease(var Table: TThreadLocalTable;
  Entry: PThreadLocalTableEntry);
var
  Data: PThreadSpecificData;
  SelfThreadId: Longword;
begin
  Data := @ThreadSpecifics;
  SelfThreadId := 0;
  FixupThreadId(Data, SelfThreadId);

  LeaveCriticalSection(Table.CritSect);
  TltDecSentinel(Table);
end;

{ APCs are served FIFO }

procedure TransferPendingApcs;
var
  Ptr: PTHreadLocalTableEntry;
  PendingApcs: PPendingApcs;
  Data: PThreadSpecificData;
begin
  Data := @ThreadSpecifics;
  ThreadLocalTableAcquire(ThreadShared.PendingApcs, Ptr, 0);
  Assert(Assigned(Ptr));
  try
    PendingApcs := Ptr^.UserData;
    if (PendingApcs <> nil) and (PendingApcs^.ApcCount <> 0) then
    begin
      Data^.Apcs := PendingApcs^.Apcs;
      PendingApcs^.Apcs := nil;
      SetLength(Data^.Apcs, PendingApcs^.ApcCount);
      PendingApcs^.ApcCount := 0;
      ResetEvent(PendingApcs^.WaitHandle);
    end;
  finally
    ThreadLocalTableRelease(ThreadShared.PendingApcs, Ptr);
  end;
end;

function DispatchApcQueue(MaxExecTimeOverride: Longword): Longword;
var
  Time: Int64;
  ApcEntry: PApcEntry;
  I: Integer;
  TimeLimit: Single;
  TimePassed: Single;
  Data: PThreadSpecificData;
begin
  TransferPendingApcs;
  Result := 0;
  Data := @ThreadSpecifics;
  // If no APCs are queued or the thread cannot dispatch APCs, we just exit
  if (Data^.Apcs = nil) or (Data^.ApcDispatchExecutionLimit = THREAD_APC_NOT_ALLOWED) then Exit;

  // More efficient access
  ApcEntry := @Data^.Apcs[0];
  I := Length(Data^.Apcs);

  if Data^.ApcDispatchExecutionLimit = THREAD_APC_NO_EXECUTION_LIMIT then
  begin
    TimeLimit := MaxExecTimeOverride;
  end else
  begin
    // We choose the more limitating (smaller) APC execution limit
    TimeLimit := Min(Data^.ApcDispatchExecutionLimit, MaxExecTimeOverride);
  end;

  if TimeLimit <> 0 then
  begin
    // There is a time limit, we'll be checking if we haven't been executing APCs
    // longer than allowed every iteration
    TimePassed := 0;
    while I > 0 do
    begin
      StartExecutionTimer(Time);

      ApcEntry^.Apc(ApcEntry^.Contexts[0], ApcEntry^.Contexts[1],
        ApcEntry^.QueryingThreadId, ApcEntry^.QueriedAt);
      Inc(ApcEntry);
      Dec(I);

      TimePassed := TimePassed + StopExecutionTimer(Time);

      if TimePassed >= TimeLimit then
      begin
        // We have passed the time limit so we have to copy remaining APCs from
        // the end of queue to the front unless we have processed all of the APCs
        if I = 0 then
        begin
          Data^.Apcs := nil;
        end else
        begin
          Move(Data^.Apcs[Length(Data^.Apcs) - I], Data^.Apcs[0], I * SizeOf(TApcEntry));
          SetLength(Data^.Apcs, I);
          Result := Ceil32(TimePassed);
        end;
        Exit;
      end;
    end;

    Result := Ceil32(TimePassed);
  end else
  begin
    StartExecutionTimer(Time);

    // No explicit time limit, we just process the whole queue no matter how long
    // will it take
    while I > 0 do
    begin
      ApcEntry^.Apc(ApcEntry^.Contexts[0], ApcEntry^.Contexts[1],
        ApcEntry^.QueryingThreadId, ApcEntry^.QueriedAt);
      Inc(ApcEntry);
      Dec(I);
    end;

    Result := Ceil32(StopExecutionTimer(Time));
  end;
  
  Data^.Apcs := nil;
end;

function SleepAndProcessApcQueue(Miliseconds: Longword): Longword;
var
  TimeToSleep: Int64;
  Data: PThreadSpecificData;
begin
  Data := @ThreadSpecifics;
  if not Assigned(Data^.ApcDispatch) then
  begin
    Data^.ApcDispatch := @DispatchApcQueue;
  end;
  Result := Data^.ApcDispatch(Miliseconds);
  TimeToSleep := Max(Int64(Miliseconds) - Int64(Result), 0);
  Sleep(TimeToSleep);
end;

function ProcessApcQueue(MaxMiliseconds: Longword): Longword;
var
  Data: PThreadSpecificData;
begin
  Data := @ThreadSpecifics;
  if not Assigned(Data^.ApcDispatch) then
  begin
    Data^.ApcDispatch := @DispatchApcQueue;
  end;

  Result := Data^.ApcDispatch(MaxMiliseconds);
end;

procedure QueueApc(TargetThreadId: Longword; ApcProc: TApcProc; Context1,
  Context2: Pointer);
const
  APC_ARRAY_CAPACITY = 16;
var
  Len: Integer;
  Ptr: PThreadLocalTableEntry;
  PendingApcs: PPendingApcs;
  ApcEntry: PApcEntry;
  Handle: THandle;
begin
  ThreadLocalTableAcquire(ThreadShared.PendingApcs, Ptr, TargetThreadId);
  // Ptr is nil only if the table is being freed while trying to acquire
  Assert(Assigned(Ptr));
  try
    PendingApcs := Ptr^.UserData;
    if PendingApcs = nil then
    begin
      PendingApcs := AllocMem(SizeOf(TPendingApcs));
      PendingApcs^.WaitHandle := CreateEvent(nil, True, False, nil);
      Ptr^.UserData := PendingApcs;
    end;

    Len := Length(PendingApcs^.Apcs);
    if Len = PendingApcs^.ApcCount then
    begin
      SetLength(PendingApcs^.Apcs, Len + APC_ARRAY_CAPACITY);
    end;

    // We initialize a new pending apc entry and increment counter
    ApcEntry := @PendingApcs^.Apcs[PendingApcs^.ApcCount];
    ApcEntry^.Apc := ApcProc;
    ApcEntry^.Contexts[0] := Context1;
    ApcEntry^.Contexts[1] := Context2;
    ApcEntry^.QueryingThreadId := GetCurrentThreadId;
    ApcEntry^.QueriedAt := Now;
    Inc(PendingApcs^.ApcCount);
    Handle := PendingApcs^.WaitHandle;
  finally
    ThreadLocalTableRelease(ThreadShared.PendingApcs, Ptr);
  end;

  // To forbid concurency - if we'd woken up a waiting thread while holding the
  // shared data lock, it would immediately block
  SetEvent(Handle);
end;

procedure QueueApc(TargetThreadId: Longword; ApcEvent: TApcEvent; Context: Pointer);
begin
  QueueApc(TargetThreadId, TMethod(ApcEvent).Code, TMethod(ApcEvent).Data, Context);
end;

function WaitForApc(Timeout: Integer): Boolean;
var
  Handle: THandle;
  Data: PThreadSpecificData;
  Ptr: PThreadLocalTableEntry;
  PendingApcs: PPendingApcs;
begin
  Result := False;
  Data := @ThreadSpecifics;
  Handle := Data^.ApcWaitHandle;
  if Handle = INVALID_HANDLE_VALUE then
  begin
    ThreadLocalTableAcquire(ThreadShared.PendingApcs, Ptr, 0);
    Assert(Assigned(Ptr));
    try
      PendingApcs := Ptr^.UserData;
      if Assigned(PendingApcs) then
      begin
        Handle := PendingApcs^.WaitHandle;
      end else Exit;
    finally
      ThreadLocalTableRelease(ThreadShared.PendingApcs, Ptr);
    end;

    Data^.ApcWaitHandle := Handle;
  end;

  Result := WaitForSingleObject(Handle, Timeout) = 0;
end;

function ShrinkStack: Boolean;
var
  Stack: PChar;
  Alloc: PChar;
  Guard: PChar;
  Free: PChar;
  First: PChar;
  MBI: TMemoryBasicInformation;
begin
  Result := False;

  asm
    MOV Stack, ESP
  end;

  Alloc := Stack - (Longword(Stack) mod PageSize) - PageSize;
  Guard := Alloc - PageSize;
  Free := Guard - PageSize;

  FillChar(MBI, SizeOf(MBI), 0);
  if VirtualQuery(Stack, @MBI, SizeOf(MBI)) = 0 then Exit;

  if VirtualQuery(MBI.AllocationBase, @MBI, SizeOf(MBI)) = 0 then Exit;
  if MBI.State <> MEM_RESERVE then Exit;

  First := PChar(MBI.AllocationBase) + MBI.RegionSize;
  if First <= Free then
  begin
    { Let's touch the page, so we won't get a guard page exception }
    asm
      MOV  EAX, [Alloc]
    end;

    if not VirtualFree(First, Longword(Guard - First), MEM_DECOMMIT) then Exit;
    if VirtualAlloc(Guard, PageSize, MEM_COMMIT, PAGE_READWRITE or PAGE_GUARD) = nil then Exit;
  end;

  Result := True;
end;

function ThreadExecuteThreadProc(Copy: PThreadSpecificData): Longword;
var
  Data: PThreadSpecificData;
  Cleanup: PThreadCleanupChainElem;
  Temp: PThreadCleanupChainElem;
begin
  ThreadSpecifics := Copy^;
  Dispose(Copy);
  Data := @ThreadSpecifics;
  Data^.Lock.Init;
  try
    Data^.ThreadStartAddr(Data^.Info);
  finally
    Data^.Lock.Enter;
    try
      Cleanup := Data^.CleanupChainStart;
      while Cleanup <> nil do
      begin
        Cleanup^.Proc(Cleanup^.Arg);
        Temp := Cleanup;
        Cleanup := Cleanup^.LowerCleanupProc;
        Dispose(Temp);
      end;
    finally
      Data^.Lock.Leave;
    end;
    Data^.Lock.Delete;

    Data^.Info^.Handle := INVALID_HANDLE_VALUE;
    CloseHandle(Data^.ApcWaitHandle);
    CloseHandle(Data^.ThreadHandle);
  end;
  Result := 0;
end;

procedure StartThreadAtAddress(Addr: TThreadProc; Param: Pointer; Suspended: Boolean;
  var ThreadInfo: TThreadCreateInfo; const ThreadName: string);
var
  Data: PThreadSpecificData;
begin
  Data := AllocMem(SizeOf(TThreadSpecificData));
  Data^.Name := ThreadName;
  Data^.Flags := [tifDelphiThread, tifHasHandle, tifHasId];
  if ThreadName <> '' then Include(Data^.Flags, tifHasName);
  Data^.ThreadStartAddr := Addr;
  Data^.CleanupChainStart := nil;
  Data^.Info := @ThreadInfo;
  Data^.ApcDispatch := @DispatchApcQueue;
  Data^.ApcWaitHandle := INVALID_HANDLE_VALUE;

  IsMultiThread := True;
  ThreadInfo.Param := Param;
  ThreadInfo.Handle := BeginThread(nil, 0, @ThreadExecuteThreadProc, Data,
    CREATE_SUSPENDED, ThreadInfo.ThreadId);
  Data^.ThreadHandle := ThreadInfo.Handle;
  Data^.ThreadId := ThreadInfo.ThreadId;
  if not Suspended then
  begin
    ResumeThread(ThreadInfo.Handle);
  end;
end;

procedure ThreadPushCleanupRoutine(Cleanup: TThreadCleanupProc; Param: Pointer);
var
  CleanupData: PThreadCleanupChainElem;
  NewCleanupData: PThreadCleanupChainElem;
  Data: PThreadSpecificData;
begin
  Data := @ThreadSpecifics;
  Data^.Lock.Enter;
  try
    CleanupData := ThreadSpecifics.CleanupChainStart;
    New(NewCleanupData);
    NewCleanupData^.Proc := Cleanup;
    NewCleanupData^.Arg := Param;
    NewCleanupData^.LowerCleanupProc := CleanupData;
    Data^.CleanupChainStart := NewCleanupData;
  finally
    Data^.Lock.Leave;
  end;
end;

procedure ThreadPopCleanupRoutine(ExecuteHandler: Boolean);
var
  CleanupData: PThreadCleanupChainElem;
  Data: PThreadSpecificData;
begin
  Data := @ThreadSpecifics;
  Data^.Lock.Enter;
  try
    CleanupData := Data^.CleanupChainStart;
    Data^.CleanupChainStart := CleanupData^.LowerCleanupProc;
    try
      if ExecuteHandler then
      begin
        CleanupData^.Proc(CleanupData^.Arg);
      end;
    finally
      Dispose(CleanupData);
    end;
  finally
    Data^.Lock.Leave;
  end;
end;

procedure ThreadExit(Result: Longword);
begin
  EndThread(Result);
end;

procedure ThreadModifyPriority(Handle: THandle; var Prio: TThreadPriority; Change: Boolean);
var
  Priority: Longword;
  Res: TThreadPriority;
begin
  if Change then SetThreadPriority(Handle, Priorities[Prio]) else
  begin
    Priority := GetThreadPriority(Handle);
    for Res := Low(TThreadPriority) to High(TThreadPriority) do
    begin
      if Priorities[Res] = Priority then
      begin
        Prio := Res;
        Exit;
      end;
    end;
    Prio := tpNormal;
  end;
end;

procedure ThreadModifyState(Handle: THandle; Suspend: Boolean);
begin
  if Suspend then SuspendThread(Handle) else ResumeThread(Handle);
end;

procedure ThreadCleanupProc(Data: PThreadCreateInfo);
begin
  Dispose(Data);
end;

procedure InitializeAtomicSList(ListHead: PAtomicListHead);
begin
  ListHead^.Start := nil;
  ListHead^.Depth := 0;
end;

function AtomicPushEntrySList(ListHead: PAtomicListHead; Entry: Pointer): Pointer;
asm
{ IN
     EAX = ListHead
     EDX = Entry
  OUT 
     EAX = PreviousHeadEntry
}
       PUSH       EBX
       PUSH       ESI

       MOV        ESI, EAX
       MOV        EBX, EDX

       MOV        EAX, [ESI].TAtomicListHead.Start
       MOV        EDX, [ESI].TAtomicListHead.Depth
@@Loop:
       MOV        [EBX].TAtomicListEntry.Next, EAX
       LEA        ECX, [EDX+1]
  LOCK CMPXCHG8B  [ESI]
       JNZ        @@Loop

       POP        ESI
       POP        EBX
end;

function AtomicPopEntrySList(ListHead: PAtomicListHead): Pointer;
{ IN
     EAX = ListHead
  OUT 
     EAX = HeadEntry
}
asm
       PUSH       EBX
       PUSH       ESI

       MOV        ESI, EAX

       MOV        EAX, [EAX].TAtomicListHead.Start
       MOV        EDX, [ESI].TAtomicListHead.Depth
@@Loop:
       TEST       EAX, EAX
       JZ         @@Exit
       LEA        ECX, [EDX-1]
       MOV        EBX, [EAX].TAtomicListEntry.Next
  LOCK CMPXCHG8B  [ESI]
       JNZ        @@Loop
       TEST       EAX, EAX
       JZ         @@Exit
       AND        [EAX].TAtomicListEntry.Next, 0
@@Exit:
       POP        ESI
       POP        EBX
end;

function QueryDepthAtomicSList(ListHead: PAtomicListHead): Integer;
begin
  Result := ListHead^.Depth;
end;

procedure AtomicFlushSList(ListHead: PAtomicListHead);
{ IN
     EAX = ListHead
}
asm
       PUSH       EBX
       PUSH       ESI

       MOV        ESI, EAX
       XOR        EBX, EBX
       XOR        ECX, ECX

       MOV        EAX, [ESI].TAtomicListHead.Start
       MOV        EDX, [ESI].TAtomicListHead.Depth
@@Loop:
       TEST       EAX, EAX
       JZ         @@Exit
  LOCK CMPXCHG8B  [ESI]
       JNZ        @@Loop
@@Exit:
       POP        ESI
       POP        EBX
end;

function AtomicInc(Addend: PLongword): Longword;
asm
       MOV    EDX, 1
       XCHG   EAX, EDX
  LOCK XADD   [EDX], EAX
       INC    EAX
end;

function AtomicDec(Substrahend: PLongword): Longword;
asm
       MOV    EDX, -1
       XCHG   EAX, EDX
  LOCK XADD   [EDX], EAX
       DEC    EAX
end;

function AtomicAdd(Addend: PLongword; Value: Longword): Longword;
asm
       MOV    ECX, EAX
       MOV    EAX, EDX
  LOCK XADD   [ECX], EAX
       ADD    EAX, EDX
end;

function AtomicSub(Substrahend: PLongword; Value: Longword): Longword;
asm
       NEG    EDX
       MOV    ECX, EAX
       MOV    EAX, EDX
  LOCK XADD   [ECX], EAX
       ADD    EAX, EDX
end;

procedure AtomicAnd8(Target: PByte; Mask: Byte);
asm
  LOCK AND    [EAX], DL
end;

procedure AtomicOr8(Target: PByte; Mask: Byte);
asm
  LOCK OR     [EAX], DL
end;

procedure AtomicXor8(Target: PByte; Mask: Byte);
asm
  LOCK XOR    [EAX], DL
end;

procedure AtomicNot8(Target: PByte);
asm
  LOCK NOT    BYTE PTR [EAX]
end;

procedure AtomicAnd16(Target: PWord; Mask: Word);
asm
  LOCK AND    [EAX], DX
end;

procedure AtomicOr16(Target: PWord; Mask: Word);
asm
  LOCK OR     [EAX], DX
end;

procedure AtomicXor16(Target: PWord; Mask: Word);
asm
  LOCK XOR    [EAX], DX
end;

procedure AtomicNot16(Target: PWord);
asm
  LOCK NOT    WORD PTR [EAX]
end;

procedure AtomicAnd32(Target: PLongword; Mask: Longword);
asm
  LOCK AND    [EAX], EDX
end;

procedure AtomicOr32(Target: PLongword; Mask: Longword);
asm
  LOCK OR     [EAX], EDX
end;

procedure AtomicXor32(Target: PLongword; Mask: Longword);
asm
  LOCK XOR    [EAX], EDX
end;

procedure AtomicNot32(Target: PLongword);
asm
  LOCK NOT    [EAX]
end;

function AtomicExchangeInc(Addend: PLongword): Longword;
asm
       MOV    ECX, EAX
       MOV    EAX, 1
  LOCK XADD   [ECX], EAX
end;

function AtomicExchangeDec(Substrahend: PLongword): Longword;
asm
       MOV    ECX, EAX
       MOV    EAX, -1
  LOCK XADD   [ECX], EAX
end;

function AtomicExchangeAdd(Addend: PLongword; Value: Longword): Longword;
asm
       XCHG   EAX, EDX
  LOCK XADD   [EDX], EAX
end;

function AtomicExchangeSub(Substrahend: PLongword; Value: Longword): Longword;
asm
       XCHG   EAX, EDX
       NEG    EAX
  LOCK XADD   [EDX], EAX
end;

function AtomicExchange(Value: PLongword; Exchange: Longword): Longword;
asm
       MOV     ECX, EAX
       MOV     EAX, [EAX]
@@Loop:
  LOCK CMPXCHG [ECX], EDX
       JNE @@Loop
end;

function AtomicCompareExchange(Value: PLongword; Exchange: Longword;
  Comperand: Longword): Longword;
asm
       XCHG    EAX, ECX
  LOCK CMPXCHG [ECX], EDX
end;

function AtomicIncPtr(Addend: PPointer): Pointer;
asm
       MOV    EDX, 1
       XCHG   EAX, EDX
  LOCK XADD   [EDX], EAX
       INC    EAX
end;

function AtomicDecPtr(Substrahend: PPointer): Pointer;
asm
       MOV    EDX, -1
       XCHG   EAX, EDX
  LOCK XADD   [EDX], EAX
       DEC    EAX
end;

function AtomicAddPtr(Addend: PPointer; Value: Pointer): Pointer;
asm
       MOV    ECX, EAX
       MOV    EAX, EDX
  LOCK XADD   [ECX], EAX
       ADD    EAX, EDX
end;

function AtomicSubPtr(Substrahend: PPointer; Value: Pointer): Pointer;
asm
       NEG    EDX
       MOV    ECX, EAX
       MOV    EAX, EDX
  LOCK XADD   [ECX], EAX
       ADD    EAX, EDX
end;

function AtomicExchangeIncPtr(Addend: PPointer): Pointer;
asm
       MOV    ECX, EAX
       MOV    EAX, 1
  LOCK XADD   [ECX], EAX
end;

function AtomicExchangeDecPtr(Substrahend: PPointer): Pointer;
asm
       MOV    ECX, EAX
       MOV    EAX, -1
  LOCK XADD   [ECX], EAX
end;

function AtomicExchangeAddPtr(Addend: PPointer; Value: Pointer): Pointer;
asm
       XCHG   EAX, EDX
  LOCK XADD   [EDX], EAX
end;

function AtomicExchangeSubPtr(Substrahend: PPointer; Value: Pointer): Pointer;
asm
       XCHG   EAX, EDX
       NEG    EAX
  LOCK XADD   [EDX], EAX
end;

function AtomicExchangePtr(Value: PPointer; Exchange: Pointer): Pointer;
asm
       MOV     ECX, EAX
       MOV     EAX, [EAX]
@@Loop:
  LOCK CMPXCHG [ECX], EDX
       JNE @@Loop
end;

function AtomicCompareExchangePtr(Value: PPointer; Exchange: Pointer;
  Comperand: Pointer): Pointer;
asm
       XCHG    EAX, ECX
  LOCK CMPXCHG [ECX], EDX
end;

const
  Alive = $7FFFFFFF;

{ TReaderWriterLock }

const
  mrWriteRequest = $FFFF;

procedure TReaderWriterLock.Init;
begin
  FSentinel := mrWriteRequest;
  FReadSignal := CreateEvent(nil, True, True, nil);
  FWriteSignal := CreateEvent(nil, False, False, nil);
end;

procedure TReaderWriterLock.Delete;
var
  Data, Temp: PThreadInfo;
  I: Integer;
begin
  BeginWrite;
  CloseHandle(FReadSignal);
  CloseHandle(FWriteSignal);
  for I := 0 to Length(FTls) -1 do
  begin
    Data := FTls[I];
    while Data <> nil do
    begin
      Temp := Data;
      Data := Data^.Next;
      FreeMem(Temp);
    end;
  end;
end;

procedure TReaderWriterLock.TlsOpen(var Thread: PThreadInfo);
var
  Data: PThreadInfo;
  CurrentThread: Longword;
  I: Integer;
begin
  CurrentThread := GetCurrentThreadId;
  Data := TlsLookupThreadInfo(CurrentThread, @I);
  while (Data <> nil) and (Data^.ThreadID <> CurrentThread) do
  begin
    Data := Data^.Next;
  end;
  if Data = nil then
  begin
    Data := TlsRecycle;

    if Data = nil then
    begin
      Data := PThreadInfo(AllocMem(SizeOf(TThreadInfo)));
      Data^.ThreadID := CurrentThread;
      Data^.Active := Alive;

      // Another thread could start traversing the list between when we set the
      // head to P and when we assign to P.Next.  Initializing P.Next to point
      // to itself will make others spin until we assign the tail to P.Next.
      Data^.Next := Data;
      Data^.Next := PThreadInfo(AtomicExchange(@FTls[I], Integer(Data)));
    end;
  end;
  Thread := Data;
end;

procedure TReaderWriterLock.TlsDelete(var Thread: PThreadInfo);
begin
  Thread^.ThreadID := 0;
  Thread^.Active := 0;
end;

function InternalTlsHash(ThreadId: Longword): Longword;
const
  HASH_MAGIC = $1CEE24AD;
asm
  ROL   EAX, 16
  XOR   EAX, HASH_MAGIC
  MOV   EDX, EAX
  AND   EAX, $0000FFFF
  SHR   EDX, 16
  MUL   EDX
end;

function TReaderWriterLock.TlsLookupThreadInfo(ThreadId: Longword;
  Index: PInteger): PThreadInfo;
var
  I: Integer;
begin
  I := InternalTlsHash(ThreadId) and (Length(FTls) - 1);
  Result := FTls[I];
  if Index <> nil then Index^ := I;
end;

function TReaderWriterLock.TlsRecycle: PThreadInfo;
var
  Res: Integer;
begin
  Result := TlsLookupThreadInfo(GetCurrentThreadId);
  while Result <> nil do
  begin
    Res := AtomicExchange(@Result^.Active, Alive);
    if Res <> Alive then
    begin
      Result^.ThreadID := GetCurrentThreadID;
      Exit;
    end else Result := Result^.Next;
  end;
end;

procedure TReaderWriterLock.BeginWrite;
var
  Thread: PThreadInfo;
  ThreadId: Longword;
  Test: Integer;
  HasReadLock: Boolean;
begin
  ThreadId := GetCurrentThreadId;
  if FWriterID <> ThreadId then
  begin
    ResetEvent(FReadSignal);

    TlsOpen(Thread);
    HasReadLock := Thread^.RecursionCount <> 0;

    if HasReadLock then
    begin
      AtomicInc(@FSentinel);
    end;

    while AtomicExchangeAdd(@FSentinel, Longword(-mrWriteRequest)) <> mrWriteRequest do
    begin
      Test := AtomicExchangeAdd(@FSentinel, mrWriteRequest);

      if Test <> 0 then
      begin
        WaitForSingleObject(FWriteSignal, INFINITE);
      end;
    end;

    ResetEvent(FReadSignal);

    if HasReadLock then
    begin
      AtomicDec(@FSentinel);
    end;

    FWriterID := ThreadId;
  end;

  Inc(FWriteRecursionCount);
end;

procedure TReaderWriterLock.EndWrite;
var
  Thread: PThreadInfo;
begin
  Assert(FWriterID = GetCurrentThreadID);
  TlsOpen(Thread);
  Dec(FWriteRecursionCount);
  if FWriteRecursionCount = 0 then
  begin
    FWriterID := 0;
    AtomicExchangeAdd(@FSentinel, mrWriteRequest);
    SetEvent(FWriteSignal);
    SetEvent(FReadSignal);
  end;
  if Thread^.RecursionCount = 0 then
  begin
    TlsDelete(Thread);
  end;
end;

procedure TReaderWriterLock.BeginRead;
var
  Thread: PThreadInfo;
  SentValue: Integer;
  WasRecursive: Boolean;
begin
  TlsOpen(Thread);
  Inc(Thread^.RecursionCount);
  WasRecursive := Thread^.RecursionCount > 1;

  if FWriterID <> GetCurrentThreadID then
  begin
    if not WasRecursive then
    begin
      WaitForSingleObject(FReadSignal, INFINITE);
      while AtomicDec(@FSentinel) <= 0 do
      begin
        SentValue := AtomicInc(@FSentinel);
        if SentValue = mrWriteRequest then
        begin
          SignalObjectAndWait(FWriteSignal, FReadSignal, INFINITE, False);
        end else WaitForSingleObject(FReadSignal, INFINITE);
      end;
    end;
  end;
end;

procedure TReaderWriterLock.EndRead;
var
  Thread: PThreadInfo;
  Test: Integer;
begin
  TlsOpen(Thread);
  Dec(Thread^.RecursionCount);
  if Thread^.RecursionCount = 0 then
  begin
    TlsDelete(Thread);

    if FWriterID <> GetCurrentThreadID then
    begin
      Test := AtomicInc(@FSentinel);
      if Test = mrWriteRequest then
      begin
        SetEvent(FWriteSignal);
      end else if Test <= 0 then
      begin
        if (Test mod mrWriteRequest) = 0 then
        begin
          SetEvent(FWriteSignal);
        end;
      end;
    end;
  end;
end;

{ TEvent }

procedure TEvent.Init(InitialState, ManualReset: Boolean);
begin
  FHandle := CreateEvent(nil, ManualReset, InitialState, nil);
end;

procedure TEvent.Delete;
begin
  CloseHandle(FHandle);
  FHandle := INVALID_HANDLE_VALUE;
end;

procedure TEvent.Reset;
begin
  ResetEvent(FHandle);
end;

procedure TEvent.Signal;
begin
  SetEvent(FHandle);
end;

function TEvent.WaitFor(TimeOut: Integer): Longword;
begin
  Result := WaitForSingleObject(FHandle, TimeOut);
end;

{ TCriticalSection }

procedure TCriticalSection.Init(SpinCount: Integer);
begin
  InitializeCriticalSectionAndSpinCount(FData, SpinCount);
end;

procedure TCriticalSection.Delete;
begin
  DeleteCriticalSection(FData);
end;

procedure TCriticalSection.Enter;
begin
  EnterCriticalSection(FData);
end;

procedure TCriticalSection.Leave;
begin
  LeaveCriticalSection(FData);
end;

procedure BfgThreadsInit;
begin
  ThreadLocalTableInitialize(ThreadShared.PendingApcs, 500);
end;

procedure BfgThreadsFini;
begin
  ThreadLocalTableDelete(ThreadShared.PendingApcs);
end;

initialization
  BfgThreadsInit;

finalization
  BfgThreadsFini;

end.
