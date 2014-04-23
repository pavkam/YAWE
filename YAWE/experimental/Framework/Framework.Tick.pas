{*------------------------------------------------------------------------------
  The main scheduler of events. Multithreaded.

  @Link http://yawe.mcheats.net/index.php
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
  Misc.Containers,
  Misc.Miscleanous,
  Misc.Threads;

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
      fExecutionGroup: Int32;
      fSleepTime: UInt32;
      fLock: TCriticalSection;
      fWakeUpEvent: TEvent;
      fEventList: array of TEventHandle;
      fDelayedEventList: array of TEventHandle;
      
      procedure AddEvent(Event: TEventHandle; Delayed: Boolean);
      procedure RemoveEvent(Event: TEventHandle; Delayed: Boolean);

      procedure DelayEvent(Event: TEventHandle; DelayTime: Int32);
      procedure ReactivateEvent(Event: TEventHandle);

      procedure Lock; inline;
      procedure Unlock; inline;
    public
      constructor Create; override;
      destructor Destroy; override;

      property ExecutionGroup: Int32 read fExecutionGroup;
  end;

  {*------------------------------------------------------------------------------
  Derived TBaseHandle class.
  The basic type which holds event data.

  @see TBaseHandle
  -------------------------------------------------------------------------------}
  TEventHandle = class(THandleBase)
    private
      fOwner: TTickGenerator;
      fName: string;
      fRunningIn: TTickThreadHandle;
      fPriority: TEventPriority;
      fWaitTime: Int32;
      fFireTime: Int32;
      fExecutionCount: Int32;
      fStoredExecutionCount: Int32;
      fFlags: TEventFlags;
      fMethod: TTimedMethod;
      fDelay: Int32;
      fDelayPassed: Int32;

      procedure SetExecCount(Count: Int32);
      procedure SetWaitTime(Time: Int32);
    public
      procedure Disable(RefreshFlags: TRefreshFlags = []);
      procedure DisableTimed(ReactivationDelay: Int32; RefreshFlags: TRefreshFlags = []);
      procedure Enable;
      procedure RefreshCounters(RefreshFlags: TRefreshFlags);

      procedure Unregister;

      property ExecCount: Int32 read fExecutionCount write SetExecCount;
      property TimeLeft: Int32 read fWaitTime write SetWaitTime;
      property Name: string read fName;
      property Flags: TEventFlags read fFlags;
      property Priority: TEventPriority read fPriority;
  end;

  { Tick Generator manages all pseudo-threads }
  TTickGenerator = class(TBaseInterfacedObject)
    private
      fThreads: array of TTickThreadHandle;
      fSleepTimeDefault: UInt32;
      fTerminated: Longbool;
      fLock: TReaderWriterLock;
      fEventMap: TStrPtrHashMap;
      fDisabledEventCount: Int32;

      fOnEventRegister: TEventRegisterEvent;
      fOnEventUnregister: TEventUnregisterEvent;
      fOnEventError: TEventExceptionEvent;

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
      property Terminated: Longbool read fTerminated;
      property Threads[ExecutionGroup: Int32]: TTickThreadHandle read GetThreadHandle;

      property OnEventRegister: TEventRegisterEvent read fOnEventRegister write fOnEventRegister;
      property OnEventUnregister: TEventUnregisterEvent read fOnEventUnregister write fOnEventUnregister;
      property OnEventException: TEventExceptionEvent read fOnEventError write fOnEventError;
    end;

implementation

uses
  API.Win.Kernel,
  MMSystem,
  Misc.Algorithm,
  Classes,
  Framework;

function CompareTickThreads(T1, T2: TTickThreadHandle): Int32;
begin
  Result := T1.fExecutionGroup - T2.fExecutionGroup;
end;

function MatchTickThread(ExGroup: Int32; T: TTickThreadHandle): Int32;
begin
  Result := ExGroup - T.fExecutionGroup;
end;

constructor TTickGenerator.Create(SleepTime: UInt32);
begin
  fSleepTimeDefault := SleepTime;
  SpawnThread(TICK_EXGROUP_DEFAULT, fSleepTimeDefault);
  fEventMap := TStrPtrHashMap.Create(False, 8192);
  fLock.Init;
end;

destructor TTickGenerator.Destroy;
begin
  { Remove all subscribers if any }
  ClearEventList;
  fEventMap.Free;
  fLock.Delete;
  inherited Destroy;
end;

function TTickGenerator.SpawnThread(ExGroup: Int32; SleepTime: UInt32): TTickThreadHandle;
var
  iInt: Int32;
begin
  iInt := Length(fThreads);
  Result := TTickThreadHandle(SystemThreadManager.CreateThreadEx(Execute, True,
    TTickThreadHandle, 'Tick_Thread_' + IntToStr(ExGroup), True));
  Result.Priority := tpHigher;

  SetLength(fThreads, iInt + 1);

  fThreads[iInt] := Result;
  Result.fExecutionGroup := ExGroup;
  Result.fSleepTime := SleepTime;
  Result.fWakeUpEvent.Init(False, False);
  Result.fLock.Init;
  
  SortArray(@fThreads[0], Length(fThreads), @CompareTickThreads, shSorted);
end;

procedure TTickGenerator.StartActivity;
begin
  { Starting Tick Activity }
  fThreads[TICK_EXGROUP_DEFAULT].Resume;
end;

procedure TTickGenerator.StopActivity;
begin
  fThreads[TICK_EXGROUP_DEFAULT].Priority := tpLowest;
  Terminate;
  fThreads[TICK_EXGROUP_DEFAULT].WaitForEnd(-1);
end;

procedure TTickGenerator.Terminate;
begin
  AtomicInc(@fTerminated);
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
      for iIdx := 0 to High(cThread.fEventList) do
      begin
        cEvent := cThread.fEventList[iIdx];
        AtomicSub(@cEvent.fFireTime, iDelta);
        if cEvent.fFireTime <= 0 then
        begin
          { We're ready to fire ! }
          try
            cEvent.fMethod(cEvent, iDelta);
          except
            on E: Exception do
            begin
              DoOnEventException(cEvent, E);
            end;
          end;

          if cEvent.fExecutionCount = 0 then
          begin
            { One-shot }
            DoOnEventUnregister(cEvent);
            fLock.BeginWrite;
            try
              fEventMap.Remove(cEvent.fName);
            finally
              fLock.EndWrite;
            end;
            cThread.RemoveEvent(cEvent, False);
            cEvent.Free;
          end else
          begin
            if cEvent.fExecutionCount > 0 then
            begin
              { Counted }
              AtomicDec(@cEvent.fExecutionCount);
            end; { else Infinite }

            AtomicExchange(@cEvent.fFireTime, cEvent.fWaitTime);
          end;
        end;
      end;

      for iIdx := 0 to High(cThread.fDelayedEventList) do
      begin
        cDelayed := cThread.fDelayedEventList[iIdx];
        AtomicAdd(@cDelayed.fDelayPassed, iDelta);
        if cDelayed.fDelayPassed > cDelayed.fDelay then
        begin
          cThread.ReactivateEvent(cDelayed);
        end;
      end;
    finally
      cThread.Unlock;
    end;
    ShrinkStack;
    Sleep(cThread.fSleepTime);
  end;

  iIdx := BinarySearch(Pointer(cThread.ExecutionGroup), @fThreads[0], Length(fThreads),
    @MatchTickThread);
  if (iIdx <> -1) and (iIdx <> High(fThreads)) then
  begin
    Move(fThreads[iIdx+1], fThreads[iIdx], SizeOf(TTickThreadHandle) * (Length(fThreads) - iIdx - 1));
  end;
  SetLength(fThreads, High(fThreads));
end;

function TTickGenerator.GetEventCount: Int32;
begin
  Result := fEventMap.Size;
end;

function TTickGenerator.GenerateEventName(Event: TEventHandle): string;
begin
  Result := 'Event__' + IntToStr(Event.fRunningIn.ThreadId) + '_0x' +
    IntToHex(Int64((Int64(TMethod(Event.fMethod).Code) shl 32) or Int64(TMethod(Event.fMethod).Data)), 16);
end;

function TTickGenerator.GetDisEventCount: Int32;
begin
  Result := fDisabledEventCount;
end;

function TTickGenerator.LookupEventByName(const Name: string): TEventHandle;
begin
  fLock.BeginRead;
  try
    Result := fEventMap.GetValue(Name);
  finally
    fLock.EndRead;
  end;
end;

function TTickGenerator.LookupThreadInfoByExGroup(ExGroup: Int32): TTickThreadHandle;
var
  iIdx: Int32;
begin
  fLock.BeginRead;
  try
    iIdx := BinarySearch(Pointer(ExGroup), @fThreads[0], Length(fThreads), @MatchTickThread);
    if iIdx <> -1 then
    begin
      Result := fThreads[iIdx];
    end else Result := nil;
  finally
    fLock.EndRead;
  end;
end;

function TTickGenerator.GetThreadHandle(Index: Int32): TTickThreadHandle;
begin
  fLock.BeginRead;
  try
    if (Index > -1) and (Index < Length(fThreads)) then
    begin
      Result := fThreads[Index];
    end else Result := nil;
  finally
    fLock.EndRead;
  end;
end;

procedure TTickGenerator.ClearEventList;
var
  cEvent: TEventHandle;
  ifItr: IPtrIterator;
begin
  fLock.BeginWrite;
  try
    { We just remove and dispose all events }
    ifItr := fEventMap.Values;
    while ifItr.HasNext do
    begin
      cEvent := ifItr.Next;
      cEvent.Free;
    end;
  finally
    fLock.EndWrite;
  end;
end;

procedure TTickGenerator.DoOnEventException(Event: TEventHandle;
  ExcObject: Exception);
begin
  if Assigned(fOnEventError) then fOnEventError(Self, Event, ExcObject);
end;

procedure TTickGenerator.DoOnEventRegister(Event: TEventHandle);
begin
  if Assigned(fOnEventRegister) then fOnEventRegister(Self, Event);
end;

procedure TTickGenerator.DoOnEventUnregister(Event: TEventHandle);
begin
  if Assigned(fOnEventUnregister) then fOnEventUnregister(Self, Event);
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

  fLock.BeginWrite;
  try
    { Internal flag, remove it if present so that tick generator won't get confused }
    Exclude(Flags, efReactivationPending);
    if ActivationDelay > 0 then Include(Flags, efDisabled);
    
    Result := HandleClass.Create;

    Result.fOwner := Self;
    Result.fExecutionCount := Repeats;
    Result.fStoredExecutionCount := Repeats;
    Result.fWaitTime := WaitTime;
    Result.fFireTime := WaitTime;
    Result.fFlags := Flags;
    Result.fMethod := Method;
    Result.fPriority := Priority;
    
    cThrd := LookupThreadInfoByExGroup(ExecutionGroup);
    if cThrd = nil then
    begin
      cThrd := SpawnThread(ExecutionGroup, fSleepTimeDefault);
    end;

    Result.fRunningIn := cThrd;

    if Name <> '' then
    begin
      iCnt := 0;
      sTemp := Name;
      Result.fName := Name;
      
      while fEventMap.ContainsKey(sTemp) do
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
      Result.fName := GenerateEventName(Result);
    end;

    fEventMap.PutValue(Result.fName, Result);
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
      Inc(fDisabledEventCount);
      if ActivationDelay > 0 then
      begin
        cThrd.DelayEvent(Result, ActivationDelay);
      end;
    end;
  finally
    fLock.EndWrite;
  end;
end;

procedure TTickGenerator.UnregisterEvent(Event: TEventHandle);
begin
  fLock.BeginWrite;
  try
    DoOnEventUnregister(Event);
    fEventMap.Remove(Event.fName);
    if not fTerminated then
    begin
      if efReactivationPending in Event.fFlags then
      begin
        { Disabled, but waiting to be reactivated }
        Dec(fDisabledEventCount);
        Event.fRunningIn.Lock;
        try
          Event.fRunningIn.RemoveEvent(Event, True);
        finally
          Event.fRunningIn.Unlock;
        end;
      end else if efDisabled in Event.fFlags then
      begin
        { Disabled }
        Dec(fDisabledEventCount);
      end else
      begin
        { In the queue }
        Event.fRunningIn.Lock;
        try
          Event.fRunningIn.RemoveEvent(Event, False);
        finally
          Event.fRunningIn.Unlock;
        end;
      end;
    end;
    Event.Free;
  finally
    fLock.EndWrite;
  end;
end;

{ YTickThreadHandle }

function CompareEvents(E1, E2: TEventHandle): Int32;
begin
  Result := Int32(E2.fPriority) - Int32(E1.fPriority);
  if Result = 0 then
  begin
    Result := Int32(UInt32(E2) - UInt32(E1));
  end;
end;

function CompareDelayedEvents(E1, E2: TEventHandle): Int32;
begin
  Result := Int32(E2.fPriority) - Int32(E1.fPriority);
  if Result = 0 then
  begin
    Result := Int32(UInt32(E2) - UInt32(E1));
  end;
end;

constructor TTickThreadHandle.Create;
begin
  inherited Create;
  fLock.Init;
  fWakeUpEvent.Init(False, False);
end;

destructor TTickThreadHandle.Destroy;
begin
  fWakeUpEvent.Delete;
  fLock.Delete;
  inherited Destroy;
end;

procedure TTickThreadHandle.Lock;
begin
  fLock.Enter;
end;

procedure TTickThreadHandle.Unlock;
begin
  fLock.Leave;
end;

procedure TTickThreadHandle.AddEvent(Event: TEventHandle; Delayed: Boolean);
var
  iLen: Int32;
begin
  if not Delayed then
  begin
    iLen := Length(fEventList);
    SetLength(fEventList, iLen + 1);
    fEventList[iLen] := Event;
    SortArray(@fEventList[0], iLen + 1, @CompareEvents, shUnsorted);
  end else
  begin
    iLen := Length(fDelayedEventList);
    SetLength(fDelayedEventList, iLen + 1);
    fDelayedEventList[iLen] := Event;
    SortArray(@fDelayedEventList[0], iLen + 1, @CompareDelayedEvents, shUnsorted);
  end;
end;

procedure TTickThreadHandle.RemoveEvent(Event: TEventHandle; Delayed: Boolean);
var
  iInt: Int32;
begin
  if not Delayed then
  begin
    iInt := BinarySearch(Event, @fEventList[0], Length(fEventList), @CompareEvents);
    if iInt <> -1 then
    begin
      if iInt <> High(fEventList) then
      begin
        Move(fEventList[iInt+1], fEventList[iInt], (High(fEventList) - iInt) * SizeOf(TEventHandle));
      end;
      SetLength(fEventList, High(fEventList));
    end;
  end else
  begin
    iInt := BinarySearch(Event, @fDelayedEventList[0], Length(fDelayedEventList), @CompareDelayedEvents);
    if iInt <> -1 then
    begin
      if iInt <> High(fDelayedEventList) then
      begin
        Move(fDelayedEventList[iInt+1], fDelayedEventList[iInt], (High(fDelayedEventList) - iInt) * SizeOf(TEventHandle));
      end;
      SetLength(fDelayedEventList, High(fDelayedEventList));
    end;
  end;
end;

procedure TTickThreadHandle.DelayEvent(Event: TEventHandle; DelayTime: Int32);
begin
  fLock.Enter;
  try
    RemoveEvent(Event, False);
    Include(Event.fFlags, efReactivationPending);
    Event.fDelay := DelayTime;
    Event.fDelayPassed := 0;
    AddEvent(Event, True);
  finally
    fLock.Leave;
  end;
end;

procedure TTickThreadHandle.ReactivateEvent(Event: TEventHandle);
begin
  fLock.Enter;
  try
    RemoveEvent(Event, True);
    Exclude(Event.fFlags, efReactivationPending);
    Exclude(Event.fFlags, efDisabled);
    AddEvent(Event, False);
  finally
    fLock.Leave;
  end;
end;

{ TEventHandle }

{*------------------------------------------------------------------------------
Unregister and Free Event

Notifies owner tick generator of event removal and frees itself afterwards.
-------------------------------------------------------------------------------}
procedure TEventHandle.Unregister;
begin
  fOwner.UnregisterEvent(Self);
end;

{*------------------------------------------------------------------------------
Disabled Event

Puts the event into a disabled state, preventing callback execution. While disabled,
event's counters do not get updated. The event can be reenabled by calling .Enable.

@param RefreshFlags Flags which control additional operations to be performed.
-------------------------------------------------------------------------------}
procedure TEventHandle.Disable(RefreshFlags: TRefreshFlags);
begin
  fRunningIn.fLock.Enter;
  try
    if not (efDisabled in fFlags) then
    begin
      fRunningIn.RemoveEvent(Self, False);
      Include(fFlags, efDisabled);

      if rfTime in RefreshFlags then
      begin
        fFireTime := fWaitTime;
      end;

      if rfExecution in RefreshFlags then
      begin
        fExecutionCount := fStoredExecutionCount;
      end;
    end;
  finally
    fRunningIn.fLock.Leave;
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
  fRunningIn.fLock.Enter;
  try
    if not (efReactivationPending in fFlags) then
    begin
      if not (efDisabled in fFlags) then
      begin
        fRunningIn.RemoveEvent(Self, False);
        Include(fFlags, efDisabled);
      end;

      if rfTime in RefreshFlags then
      begin
        fFireTime := fWaitTime;
      end;

      if rfExecution in RefreshFlags then
      begin
        fExecutionCount := fStoredExecutionCount;
      end;

      fRunningIn.DelayEvent(Self, ReactivationDelay);
    end;
  finally
    fRunningIn.fLock.Leave;
  end;
end;

{*------------------------------------------------------------------------------
Enable Event

Reactivates a previously disabled event. If the event is not in the disabled state,
nothing happens.
-------------------------------------------------------------------------------}
procedure TEventHandle.Enable;
begin
  fRunningIn.fLock.Enter;
  try
    if efDisabled in fFlags then
    begin
      Exclude(fFlags, efDisabled);
      if efReactivationPending in fFlags then
      begin
        fRunningIn.RemoveEvent(Self, True);
        Exclude(fFlags, efReactivationPending);
      end;
      fRunningIn.AddEvent(Self, False);
    end;
  finally
    fRunningIn.fLock.Leave;
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
    AtomicExchange(@fFireTime, fWaitTime);
  end;

  if rfExecution in RefreshFlags then
  begin
    AtomicExchange(@fExecutionCount, fStoredExecutionCount);
  end;

  if (rfReactivationDelay in RefreshFlags) and
     (efReactivationPending in fFlags) then
  begin
    AtomicExchange(@fDelayPassed, 0);
  end;
end;

procedure TEventHandle.SetExecCount(Count: Int32);
begin
  AtomicExchange(@fExecutionCount, Count);
end;

procedure TEventHandle.SetWaitTime(Time: Int32);
begin
  AtomicExchange(@fExecutionCount, Time);
end;

end.
