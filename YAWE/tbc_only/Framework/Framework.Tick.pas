{*------------------------------------------------------------------------------
  The main scheduler of events. Multithreaded.

  @Link http://www.yawe.co.uk
  @Copyright YAWE 2007 - Under LGPL licence


  @Author PavkaM, Seth
  @Docs Seth
-------------------------------------------------------------------------------}

{$I compiler.inc}
unit Framework.Tick;

interface

uses
  Framework.Base,
  Framework.ThreadManager,
  SysUtils,
  Bfg.Containers,
  Bfg.Utils,
  Bfg.Threads;

const
  { Some handy constants }
  TICK_EXECUTE_INFINITE       = 0; { Infinite number of executions }
  TICK_EXECUTE_ONCE           = 1; { One-time event }

  TICK_EXGROUP_DEFAULT        = 0; { Default execution group }

type
  { Forwards }
  TTickGenerator = class;
  TEventHandle = class;
  TEventHandleClass = class of TEventHandle;

  { A method which can be timed }
  TTimedMethod = procedure(Event: TEventHandle; TimeDelta: UInt32) of object;

  {$Z4}
  TEventFlag = (efDisabled, efReactivationPending);
  TEventFlags = set of TEventFlag;

  TRefreshFlag = (rfTime, rfExecution, rfReactivationDelay);
  TRefreshFlags = set of TRefreshFlag;

  TEventPriority = (epLow, epLower, epNormal, epHigher, epHigh);
  {$Z1}

  TEventRegisterEvent = procedure(Sender: TTickGenerator; Event: TEventHandle) of object;
  TEventUnregisterEvent = procedure(Sender: TTickGenerator; Event: TEventHandle) of object;
  TEventExceptionEvent = procedure(Sender: TTickGenerator; Event: TEventHandle; ExcObject: Exception) of object;

  {*------------------------------------------------------------------------------
  Derived TThreadHandle class.
  Derives from TThreadHandle. Contains tickgenerator-specific data.

  @see TThreadManager
  @see TThreadHandle
  -------------------------------------------------------------------------------}
  TTickThreadHandle = class(TThreadHandle)
    private
      FExecutionGroup: Int32;
      FSleepTime: UInt32;
      FLock: TCriticalSection;
      FWakeUpEvent: TEvent;
      FEventList: array of TEventHandle;
      FDelayedEventList: array of TEventHandle;
      
      procedure AddEvent(Event: TEventHandle; Delayed: Boolean);
      procedure RemoveEvent(Event: TEventHandle; Delayed: Boolean);

      procedure DelayEvent(Event: TEventHandle; DelayTime: Int32);
      procedure ReactivateEvent(Event: TEventHandle);

      procedure Lock; inline;
      procedure Unlock; inline;
    public
      constructor Create; override;
      destructor Destroy; override;

      property ExecutionGroup: Int32 read FExecutionGroup;
  end;

  {*------------------------------------------------------------------------------
  Derived TBaseHandle class.
  The basic type which holds event data.

  @see TBaseHandle
  -------------------------------------------------------------------------------}
  TEventHandle = class(TReferencedObject)
    private
      FOwner: TTickGenerator;
      FName: string;
      FRunningIn: TTickThreadHandle;
      FPriority: TEventPriority;
      FWaitTime: Int32;
      FFireTime: Int32;
      FExecutionCount: Int32;
      FStoredExecutionCount: Int32;
      FFlags: TEventFlags;
      FMethod: TTimedMethod;
      FDelay: Int32;
      FDelayPassed: Int32;

      procedure SetExecCount(Count: Int32);
      procedure SetWaitTime(Time: Int32);
    public
      constructor Create; virtual;

      procedure Disable(RefreshFlags: TRefreshFlags = []);
      procedure DisableTimed(ReactivationDelay: Int32; RefreshFlags: TRefreshFlags = []);
      procedure Enable;
      procedure RefreshCounters(RefreshFlags: TRefreshFlags);

      procedure Unregister;

      property ExecCount: Int32 read FExecutionCount write SetExecCount;
      property TimeLeft: Int32 read FWaitTime write SetWaitTime;
      property Name: string read FName;
      property Flags: TEventFlags read FFlags;
      property Priority: TEventPriority read FPriority;
  end;

  { Tick Generator manages all pseudo-threads }
  TTickGenerator = class(TReferencedObject)
    private
      FThreads: array of TTickThreadHandle;
      FSleepTimeDefault: UInt32;
      FTerminated: Longbool;
      FLock: TReaderWriterLock;
      FEventMap: TStrPtrHashMap;
      FDisabledEventCount: Int32;

      FOnEventRegister: TEventRegisterEvent;
      FOnEventUnregister: TEventUnregisterEvent;
      FOnEventError: TEventExceptionEvent;

      function SpawnThread(ExGroup: Int32; SleepTime: UInt32): TTickThreadHandle;

      function GetEventCount: Int32;
      function GetDisEventCount: Int32;

      procedure ClearEventList;

      function GenerateEventName(Event: TEventHandle): string;

      function LookupEventByName(const Name: string): TEventHandle;

      function LookupThreadInfoByExGroup(ExGroup: Int32): TTickThreadHandle;
      function GetThreadHandle(Index: Int32): TTickThreadHandle;

      procedure Execute(Thread: TThreadHandle);

      procedure DoOnEventRegister(Event: TEventHandle);
      procedure DoOnEventUnregister(Event: TEventHandle);
      procedure DoOnEventException(Event: TEventHandle; ExcObject: Exception);
    public
      constructor Create(SleepTime: UInt32);
      destructor Destroy; override;

      procedure StartActivity;
      procedure StopActivity;

      { Creates and registers a new event using the params specified. }
      function RegisterEvent(Method: TTimedMethod; WaitTime: Int32; Repeats: Int32;  Name: string = '';
        ActivationDelay: Int32 = 0; Flags: TEventFlags = [];
        ExecutionGroup: Int32 = TICK_EXGROUP_DEFAULT; Priority: TEventPriority = epNormal): TEventHandle;

      function RegisterEventEx(Method: TTimedMethod; WaitTime: Int32; Repeats: Int32;
        HandleClass: TEventHandleClass; Name: string = ''; ActivationDelay: Int32 = 0; Flags: TEventFlags = [];
        ExecutionGroup: Int32 = TICK_EXGROUP_DEFAULT; Priority: TEventPriority = epNormal): TEventHandle;

      { Unregisters and destroys an event identified by a valid handle. }
      procedure UnregisterEvent(Event: TEventHandle);

      procedure Terminate;

      property Events[const Name: string]: TEventHandle read LookupEventByName;
      property EventCount: Int32 read GetEventCount;
      property DisabledEvents: Int32 read GetDisEventCount;
      property Terminated: Longbool read FTerminated;
      property Threads[ExecutionGroup: Int32]: TTickThreadHandle read GetThreadHandle;

      property OnEventRegister: TEventRegisterEvent read FOnEventRegister write FOnEventRegister;
      property OnEventUnregister: TEventUnregisterEvent read FOnEventUnregister write FOnEventUnregister;
      property OnEventException: TEventExceptionEvent read FOnEventError write FOnEventError;
    end;

implementation

uses
  API.Win.Kernel,
  MMSystem,
  Bfg.Algorithm,
  Classes,
  Framework;

function CompareTickThreads(T1, T2: TTickThreadHandle): Int32;
begin
  Result := T1.FExecutionGroup - T2.FExecutionGroup;
end;

function MatchTickThread(ExGroup: Int32; T: TTickThreadHandle): Int32;
begin
  Result := ExGroup - T.FExecutionGroup;
end;

constructor TTickGenerator.Create(SleepTime: UInt32);
begin
  FSleepTimeDefault := SleepTime;
  SpawnThread(TICK_EXGROUP_DEFAULT, FSleepTimeDefault);
  FEventMap := TStrPtrHashMap.Create(False, 8192);
  FLock.Init;
end;

destructor TTickGenerator.Destroy;
begin
  { Remove all subscribers if any }
  ClearEventList;
  FEventMap.Free;
  FLock.Delete;
  inherited Destroy;
end;

function TTickGenerator.SpawnThread(ExGroup: Int32; SleepTime: UInt32): TTickThreadHandle;
var
  iInt: Int32;
begin
  iInt := Length(FThreads);
  Result := TTickThreadHandle(SysThreadMgr.CreateThreadEx(Execute, True,
    TTickThreadHandle, 'Tick_Thread_' + IntToStr(ExGroup), True));
  Result.Priority := tpHigher;

  SetLength(FThreads, iInt + 1);

  FThreads[iInt] := Result;
  Result.FExecutionGroup := ExGroup;
  Result.FSleepTime := SleepTime;
  Result.FWakeUpEvent.Init(False, False);
  Result.FLock.Init;
  
  SortArray(@FThreads[0], Length(FThreads), @CompareTickThreads, shSorted);
end;

procedure TTickGenerator.StartActivity;
begin
  { Starting Tick Activity }
  FThreads[TICK_EXGROUP_DEFAULT].Resume;
end;

procedure TTickGenerator.StopActivity;
begin
  FThreads[TICK_EXGROUP_DEFAULT].Priority := tpLowest;
  Terminate;
  FThreads[TICK_EXGROUP_DEFAULT].WaitForEnd(-1);
end;

procedure TTickGenerator.Terminate;
begin
  AtomicInc(@FTerminated);
end;

procedure TTickGenerator.Execute(Thread: TThreadHandle);
var
  cThread: TTickThreadHandle;
  cEvent: TEventHandle;
  cDelayed: TEventHandle;
  iLastTime: UInt32;
  iCurrTime: UInt32;
  iDelta: Int32;
  iIdx: Int32;
begin
  cThread := TTickThreadHandle(Thread);
  iCurrTime := TimeGetTime;

  while not Terminated do
  begin
    iLastTime := iCurrTime;
    iCurrTime := TimeGetTime;
    iDelta := GetTimeDifference(iCurrTime, iLastTime);

    cThread.Lock;
    try
      for iIdx := 0 to High(cThread.FEventList) do
      begin
        cEvent := cThread.FEventList[iIdx];
        AtomicSub(@cEvent.FFireTime, iDelta);
        if cEvent.FFireTime <= 0 then
        begin
          { We're ready to fire ! }
          try
            cEvent.FMethod(cEvent, iDelta);
          except
            on E: Exception do
            begin
              DoOnEventException(cEvent, E);
            end;
          end;

          if cEvent.FExecutionCount = 0 then
          begin
            { One-shot }
            DoOnEventUnregister(cEvent);
            FLock.BeginWrite;
            try
              FEventMap.Remove(cEvent.FName);
            finally
              FLock.EndWrite;
            end;
            cThread.RemoveEvent(cEvent, False);
            cEvent.Free;
          end else
          begin
            if cEvent.FExecutionCount > 0 then
            begin
              { Counted }
              AtomicDec(@cEvent.FExecutionCount);
            end; { else Infinite }

            AtomicExchange(@cEvent.FFireTime, cEvent.FWaitTime);
          end;
        end;
      end;

      for iIdx := 0 to High(cThread.FDelayedEventList) do
      begin
        cDelayed := cThread.FDelayedEventList[iIdx];
        AtomicAdd(@cDelayed.FDelayPassed, iDelta);
        if cDelayed.FDelayPassed > cDelayed.FDelay then
        begin
          cThread.ReactivateEvent(cDelayed);
        end;
      end;
    finally
      cThread.Unlock;
    end;
    ShrinkStack;
    SleepAndProcessApcQueue(cThread.FSleepTime);
  end;

  iIdx := BinarySearch(Pointer(cThread.ExecutionGroup), @FThreads[0], Length(FThreads),
    @MatchTickThread);
  if (iIdx <> -1) and (iIdx <> High(FThreads)) then
  begin
    Move(FThreads[iIdx+1], FThreads[iIdx], SizeOf(TTickThreadHandle) * (Length(FThreads) - iIdx - 1));
  end;
  SetLength(FThreads, High(FThreads));
end;

function TTickGenerator.GetEventCount: Int32;
begin
  Result := FEventMap.Size;
end;

function TTickGenerator.GenerateEventName(Event: TEventHandle): string;
begin
  Result := 'Event__' + IntToStr(Event.FRunningIn.ThreadId) + '_0x' +
    IntToHex(Int64((Int64(TMethod(Event.FMethod).Code) shl 32) or Int64(TMethod(Event.FMethod).Data)), 16);
end;

function TTickGenerator.GetDisEventCount: Int32;
begin
  Result := FDisabledEventCount;
end;

function TTickGenerator.LookupEventByName(const Name: string): TEventHandle;
begin
  FLock.BeginRead;
  try
    Result := FEventMap.GetValue(Name);
  finally
    FLock.EndRead;
  end;
end;

function TTickGenerator.LookupThreadInfoByExGroup(ExGroup: Int32): TTickThreadHandle;
var
  iIdx: Int32;
begin
  FLock.BeginRead;
  try
    iIdx := BinarySearch(Pointer(ExGroup), @FThreads[0], Length(FThreads), @MatchTickThread);
    if iIdx <> -1 then
    begin
      Result := FThreads[iIdx];
    end else Result := nil;
  finally
    FLock.EndRead;
  end;
end;

function TTickGenerator.GetThreadHandle(Index: Int32): TTickThreadHandle;
begin
  FLock.BeginRead;
  try
    if (Index > -1) and (Index < Length(FThreads)) then
    begin
      Result := FThreads[Index];
    end else Result := nil;
  finally
    FLock.EndRead;
  end;
end;

procedure TTickGenerator.ClearEventList;
var
  cEvent: TEventHandle;
  ifItr: IPtrIterator;
begin
  FLock.BeginWrite;
  try
    { We just remove and dispose all events }
    ifItr := FEventMap.Values;
    while ifItr.HasNext do
    begin
      cEvent := ifItr.Next;
      cEvent.Free;
    end;
  finally
    FLock.EndWrite;
  end;
end;

procedure TTickGenerator.DoOnEventException(Event: TEventHandle;
  ExcObject: Exception);
begin
  if Assigned(FOnEventError) then FOnEventError(Self, Event, ExcObject);
end;

procedure TTickGenerator.DoOnEventRegister(Event: TEventHandle);
begin
  if Assigned(FOnEventRegister) then FOnEventRegister(Self, Event);
end;

procedure TTickGenerator.DoOnEventUnregister(Event: TEventHandle);
begin
  if Assigned(FOnEventUnregister) then FOnEventUnregister(Self, Event);
end;

function TTickGenerator.RegisterEvent(Method: TTimedMethod; WaitTime: Int32;
  Repeats: Int32; Name: string = ''; ActivationDelay: Int32 = 0; Flags: TEventFlags = [];
  ExecutionGroup: Int32 = TICK_EXGROUP_DEFAULT; Priority: TEventPriority = epNormal): TEventHandle;
begin
  Result := RegisterEventEx(Method, WaitTime, Repeats, TEventHandle, Name, ActivationDelay,
    Flags, ExecutionGroup, Priority);
end;

function TTickGenerator.RegisterEventEx(Method: TTimedMethod; WaitTime: Int32; Repeats: Int32;
  HandleClass: TEventHandleClass; Name: string = ''; ActivationDelay: Int32 = 0; Flags: TEventFlags = [];
  ExecutionGroup: Int32 = TICK_EXGROUP_DEFAULT; Priority: TEventPriority = epNormal): TEventHandle;
var
  cThrd: TTickThreadHandle;
  iCnt: Int32;
  sTemp: string;
begin
  Dec(Repeats);

  FLock.BeginWrite;
  try
    { Internal flag, remove it if present so that tick generator won't get confused }
    Exclude(Flags, efReactivationPending);
    if ActivationDelay > 0 then Include(Flags, efDisabled);
    
    Result := HandleClass.Create;

    Result.FOwner := Self;
    Result.FExecutionCount := Repeats;
    Result.FStoredExecutionCount := Repeats;
    Result.FWaitTime := WaitTime;
    Result.FFireTime := WaitTime;
    Result.FFlags := Flags;
    Result.FMethod := Method;
    Result.FPriority := Priority;
    
    cThrd := LookupThreadInfoByExGroup(ExecutionGroup);
    if cThrd = nil then
    begin
      cThrd := SpawnThread(ExecutionGroup, FSleepTimeDefault);
    end;

    Result.FRunningIn := cThrd;

    if Name <> '' then
    begin
      iCnt := 0;
      sTemp := Name;
      Result.FName := Name;
      
      while FEventMap.ContainsKey(sTemp) do
      begin
        Inc(iCnt);
        sTemp := Result.FName + '_' + IntToStr(iCnt);
      end;

      if iCnt <> 0 then
      begin
        Result.FName := sTemp;
      end;
    end else
    begin
      Result.FName := GenerateEventName(Result);
    end;

    FEventMap.PutValue(Result.FName, Result);
    DoOnEventRegister(Result);

    if not (efDisabled in Flags) then
    begin
      cThrd.Lock;
      try
        { We may start incrementing fire time :) }
        cThrd.AddEvent(Result, False);
      finally
        cThrd.Unlock;
      end;
    end else
    begin
      Inc(FDisabledEventCount);
      if ActivationDelay > 0 then
      begin
        cThrd.DelayEvent(Result, ActivationDelay);
      end;
    end;
  finally
    FLock.EndWrite;
  end;
end;

procedure TTickGenerator.UnregisterEvent(Event: TEventHandle);
begin
  FLock.BeginWrite;
  try
    DoOnEventUnregister(Event);
    FEventMap.Remove(Event.FName);
    if not FTerminated then
    begin
      if efReactivationPending in Event.FFlags then
      begin
        { Disabled, but waiting to be reactivated }
        Dec(FDisabledEventCount);
        Event.FRunningIn.Lock;
        try
          Event.FRunningIn.RemoveEvent(Event, True);
        finally
          Event.FRunningIn.Unlock;
        end;
      end else if efDisabled in Event.FFlags then
      begin
        { Disabled }
        Dec(FDisabledEventCount);
      end else
      begin
        { In the queue }
        Event.FRunningIn.Lock;
        try
          Event.FRunningIn.RemoveEvent(Event, False);
        finally
          Event.FRunningIn.Unlock;
        end;
      end;
    end;
    Event.Free;
  finally
    FLock.EndWrite;
  end;
end;

{ YTickThreadHandle }

function CompareEvents(E1, E2: TEventHandle): Int32;
begin
  Result := Int32(E2.FPriority) - Int32(E1.FPriority);
  if Result = 0 then
  begin
    Result := Int32(UInt32(E2) - UInt32(E1));
  end;
end;

function CompareDelayedEvents(E1, E2: TEventHandle): Int32;
begin
  Result := Int32(E2.FPriority) - Int32(E1.FPriority);
  if Result = 0 then
  begin
    Result := Int32(UInt32(E2) - UInt32(E1));
  end;
end;

constructor TTickThreadHandle.Create;
begin
  inherited Create;
  FLock.Init;
  FWakeUpEvent.Init(False, False);
end;

destructor TTickThreadHandle.Destroy;
begin
  FWakeUpEvent.Delete;
  FLock.Delete;
  inherited Destroy;
end;

procedure TTickThreadHandle.Lock;
begin
  FLock.Enter;
end;

procedure TTickThreadHandle.Unlock;
begin
  FLock.Leave;
end;

procedure TTickThreadHandle.AddEvent(Event: TEventHandle; Delayed: Boolean);
var
  iLen: Int32;
begin
  if not Delayed then
  begin
    iLen := Length(FEventList);
    SetLength(FEventList, iLen + 1);
    FEventList[iLen] := Event;
    SortArray(@FEventList[0], iLen + 1, @CompareEvents, shUnsorted);
  end else
  begin
    iLen := Length(FDelayedEventList);
    SetLength(FDelayedEventList, iLen + 1);
    FDelayedEventList[iLen] := Event;
    SortArray(@FDelayedEventList[0], iLen + 1, @CompareDelayedEvents, shUnsorted);
  end;
end;

procedure TTickThreadHandle.RemoveEvent(Event: TEventHandle; Delayed: Boolean);
var
  iInt: Int32;
begin
  if not Delayed then
  begin
    iInt := BinarySearch(Event, @FEventList[0], Length(FEventList), @CompareEvents);
    if iInt <> -1 then
    begin
      if iInt <> High(FEventList) then
      begin
        Move(FEventList[iInt+1], FEventList[iInt], (High(FEventList) - iInt) * SizeOf(TEventHandle));
      end;
      SetLength(FEventList, High(FEventList));
    end;
  end else
  begin
    iInt := BinarySearch(Event, @FDelayedEventList[0], Length(FDelayedEventList), @CompareDelayedEvents);
    if iInt <> -1 then
    begin
      if iInt <> High(FDelayedEventList) then
      begin
        Move(FDelayedEventList[iInt+1], FDelayedEventList[iInt], (High(FDelayedEventList) - iInt) * SizeOf(TEventHandle));
      end;
      SetLength(FDelayedEventList, High(FDelayedEventList));
    end;
  end;
end;

procedure TTickThreadHandle.DelayEvent(Event: TEventHandle; DelayTime: Int32);
begin
  FLock.Enter;
  try
    RemoveEvent(Event, False);
    Include(Event.FFlags, efReactivationPending);
    Event.FDelay := DelayTime;
    Event.FDelayPassed := 0;
    AddEvent(Event, True);
  finally
    FLock.Leave;
  end;
end;

procedure TTickThreadHandle.ReactivateEvent(Event: TEventHandle);
begin
  FLock.Enter;
  try
    RemoveEvent(Event, True);
    Exclude(Event.FFlags, efReactivationPending);
    Exclude(Event.FFlags, efDisabled);
    AddEvent(Event, False);
  finally
    FLock.Leave;
  end;
end;

{ TEventHandle }

{*------------------------------------------------------------------------------
Unregister and Free Event

Notifies owner tick generator of event removal and frees itself afterwards.
-------------------------------------------------------------------------------}
procedure TEventHandle.Unregister;
begin
  FOwner.UnregisterEvent(Self);
end;

{*------------------------------------------------------------------------------
Disabled Event

Puts the event into a disabled state, preventing callback execution. While disabled,
event's counters do not get updated. The event can be reenabled by calling .Enable.

@param RefreshFlags Flags which control additional operations to be performed.
-------------------------------------------------------------------------------}
constructor TEventHandle.Create;
begin

end;

procedure TEventHandle.Disable(RefreshFlags: TRefreshFlags);
begin
  FRunningIn.FLock.Enter;
  try
    if not (efDisabled in FFlags) then
    begin
      FRunningIn.RemoveEvent(Self, False);
      Include(FFlags, efDisabled);

      if rfTime in RefreshFlags then
      begin
        FFireTime := FWaitTime;
      end;

      if rfExecution in RefreshFlags then
      begin
        FExecutionCount := FStoredExecutionCount;
      end;
    end;
  finally
    FRunningIn.FLock.Leave;
  end;
end;

{*------------------------------------------------------------------------------
Disabled Event, Timed

Puts the event into a disabled state, preventing callback execution. While disabled,
event's counters do not get updated. The event can be reenabled by calling .Enable.
After the specified time elapses, the event is automaticly reeanabled.

@param ReactivationDelay Number of miliseconds to wait till automatic event reactivation.
@param RefreshFlags Flags which control additional operations to be performed.
-------------------------------------------------------------------------------}
procedure TEventHandle.DisableTimed(ReactivationDelay: Int32;
  RefreshFlags: TRefreshFlags);
begin
  FRunningIn.FLock.Enter;
  try
    if not (efReactivationPending in FFlags) then
    begin
      if not (efDisabled in FFlags) then
      begin
        FRunningIn.RemoveEvent(Self, False);
        Include(FFlags, efDisabled);
      end;

      if rfTime in RefreshFlags then
      begin
        FFireTime := FWaitTime;
      end;

      if rfExecution in RefreshFlags then
      begin
        FExecutionCount := FStoredExecutionCount;
      end;

      FRunningIn.DelayEvent(Self, ReactivationDelay);
    end;
  finally
    FRunningIn.FLock.Leave;
  end;
end;

{*------------------------------------------------------------------------------
Enable Event

Reactivates a previously disabled event. If the event is not in the disabled state,
nothing happens.
-------------------------------------------------------------------------------}
procedure TEventHandle.Enable;
begin
  FRunningIn.FLock.Enter;
  try
    if efDisabled in FFlags then
    begin
      Exclude(FFlags, efDisabled);
      if efReactivationPending in FFlags then
      begin
        FRunningIn.RemoveEvent(Self, True);
        Exclude(FFlags, efReactivationPending);
      end;
      FRunningIn.AddEvent(Self, False);
    end;
  finally
    FRunningIn.FLock.Leave;
  end;
end;

{*------------------------------------------------------------------------------
Refresh Event Counters

Refreshes counters associated with the event. 

@param RefreshFlags Controls which counters should be refreshed.
-------------------------------------------------------------------------------}
procedure TEventHandle.RefreshCounters(RefreshFlags: TRefreshFlags);
begin
  if rfTime in RefreshFlags then
  begin
    AtomicExchange(@FFireTime, FWaitTime);
  end;

  if rfExecution in RefreshFlags then
  begin
    AtomicExchange(@FExecutionCount, FStoredExecutionCount);
  end;

  if (rfReactivationDelay in RefreshFlags) and
     (efReactivationPending in FFlags) then
  begin
    AtomicExchange(@FDelayPassed, 0);
  end;
end;

procedure TEventHandle.SetExecCount(Count: Int32);
begin
  AtomicExchange(@FExecutionCount, Count);
end;

procedure TEventHandle.SetWaitTime(Time: Int32);
begin
  AtomicExchange(@FExecutionCount, Time);
end;

end.
