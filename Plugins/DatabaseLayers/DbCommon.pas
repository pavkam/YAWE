{*------------------------------------------------------------------------------
  Abstract Object to access database contents.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

unit DbCommon;

interface

uses
  SysUtils,
  Classes,
  DataInterfaces,
  Bfg.Utils,
  Bfg.Containers,
  Bfg.Algorithm,
  Bfg.Threads;

type
  {
    Storage medium is a semi-abstract class used as a parent to
    all medium types.
  }
  TDbStorageMedium = class;

  TStorageErrorEvent = procedure(Sender: TDbStorageMedium; const Error: string) of object;

  TDbStorageContext = class(TObject)
    strict private
      FInstancePtr: Pointer;
    public
      constructor Create(Instance: Pointer; const Intf: IYesSerializable); virtual;

      procedure Clear; virtual;

      property InstancePointer: Pointer read FInstancePtr;
  end;

  TDbStorageMedium = class(TInterfacedObject)
    strict private
      FOnError: TStorageErrorEvent;
      FInitArgs: WideString;
      FTypeIID: TGUID;
      FMetadata: ITypeInfo;
      FReadOnly: Longbool;
      FName: AnsiString;
    protected
      class procedure GetArg(var Args: PWideChar; out Arg: WideString); static;
      procedure InitializeMedium(var Args: PWideChar); virtual;

      function CreateStorageContext(Instance: Pointer;
        const Intf: IYesSerializable): TDbStorageContext; virtual;

      procedure GetPropInfo(const PropName: AnsiString; out Info: IPropertyInfo;
        ExpectedType: Integer); virtual;

      procedure DoOnError(const Msg: string);
      function GetName: PChar; stdcall;
    public
      constructor Create; virtual;

      procedure Initialize(const Metadata: ITypeInfo; const IID: TGUID;
        Args: PAnsiChar); stdcall;

      property Metadata: ITypeInfo read FMetadata;
      property ReadOnlyMode: Longbool read FReadOnly;
      property Name: AnsiString read FName;
      property TypeIID: TGUID read FTypeIID;

      property OnError: TStorageErrorEvent read FOnError write FOnError;
    end;

  PIdListEntry = ^TIdListEntry;
  TIdListEntry = packed record
    Id: Longword;
    Intf: IYesSerializable;
    Instance: Pointer;
  end;

  PFreeListEntry = ^TFreeListEntry;
  TFreeListEntry = packed record
    Next: PFreeListEntry;
    Intf: IYesSerializable;
    Instance: Pointer;
  end;

  TDbMemoryStorageMedium = class(TDbStorageMedium)
    strict private
      FDataBlocks: array of Pointer;
      FBlockCapacities: array of Integer;
      FDefaultCapacity: Integer;
      FFreeList: TAtomicListHead;
      FIdList: TPtrArrayList;
      FCount: Integer;
      FHighestId: Longword;
      FLock: TReaderWriterLock;
    protected
      procedure LockReadBegin; inline;
      procedure LockReadEnd; inline;
      procedure LockWriteBegin; inline;
      procedure LockWriteEnd; inline;

      procedure AllocationCallback(Inst: Pointer); virtual; stdcall;
      procedure DeallocationCallback(Inst: Pointer); virtual; stdcall;

      function CreateIdListEntry(Id: Longword; const Intf: IYesSerializable;
        Instance: Pointer): PIdListEntry;

      procedure DeleteIdListEntry(Entry: PIdListEntry);

      procedure InternalAllocateNewClassBuffer(InstCount: Integer = 0);
      procedure InternalGetFreeClassInstance(out Intf: IYesSerializable; InstPtr: PPointer = nil);
      procedure InternalAddFreeClassInstance(const Intf: IYesSerializable; Inst: Pointer);

      function CreateLookupResult(const Intfs: IYesSerializableDynArray; OwnsEntries: Boolean): IYesLookupResult; virtual;

      function GeneratePrimaryIndex: Longword; inline;

      class function CompareSerializablesById(const E1, E2: TIdListEntry): Integer; static;
      class function MatchSerializableById(Id: UInt32; const E: TIdListEntry): Integer; static;

      class procedure RaiseException(Op: Integer; const FileName: WideString;
        const Msg: string); static;

      procedure InitializeMedium(var Args: PWideChar); override;

      procedure AddEntry(Id: Longword; const Entry: IYesSerializable; Instance: Pointer);

      property IdList: TPtrArrayList read FIdList;
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure DeleteEntry(Id: Longword); virtual; stdcall;
      procedure DeleteEntries(Ids: PLongword; Count: Integer); virtual; stdcall;

      procedure SaveEntry(const Entry: IYesSerializable; Release: Boolean = True); virtual; stdcall;
      procedure SaveEntries(Entries: PYesSerializable; Count: Integer; Release: Boolean = True); virtual; stdcall;

      procedure CreateEntry(Entry: PPointer); virtual; stdcall;
      procedure CreateEntries(Entries: PPointer; Count: Integer); virtual; stdcall;

      procedure AcquireEntry(Entry: PPointer); virtual; stdcall;
      procedure AcquireEntries(Entries: PPointer; Count: Integer); virtual; stdcall;

      procedure ReleaseEntry(const Entry: IYesSerializable); virtual; stdcall;
      procedure ReleaseEntries(Entries: PYesSerializable; Count: Integer); virtual; stdcall;

      procedure LookupEntry(Id: Longword; Entry: PPointer); virtual; stdcall; 

      procedure LookupEntryList(Field: PAnsiChar; CmpValue: Longword; CmpOp: TCompareOp; Result: PYesLookupResult; ResultOwnsEntries: Boolean = True); overload; virtual; stdcall;
      procedure LookupEntryList(Field: PAnsiChar; CmpValue: PAnsiChar; CaseSensitive: Boolean; Result: PYesLookupResult; ResultOwnsEntries: Boolean = True); overload; virtual; stdcall;
      procedure LookupEntryList(Field: PAnsiChar; CmpValue: PWideChar; CaseSensitive: Boolean; Result: PYesLookupResult; ResultOwnsEntries: Boolean = True); overload; virtual; stdcall;
      procedure LookupEntryList(Field: PAnsiChar; CmpValue: Float; CmpOp: TCompareOp; Epsilon: Float; Result: PYesLookupResult; ResultOwnsEntries: Boolean = True); overload; virtual; stdcall;

      function GetEntryCount: Integer; stdcall;
  end;

  TDbLookupResult = class(TInterfacedObject, IYesLookupResult)
    private
      FData: IYesSerializableDynArray;
      FOwner: TDbMemoryStorageMedium;
      FTypeIIDRef: PGUID;
      FReleaseEntries: Longbool;

      function GetEntryCount: Integer; stdcall;
    public
      constructor Create(const Owner: TDbMemoryStorageMedium; TypeIIDRef: PGUID;
        const Intfs: IYesSerializableDynArray; OwnsEntries: Boolean); virtual;

      destructor Destroy; override;

      function GetData(Entries: PPointer; Count: Integer): Integer; stdcall;
      function GetDataEx(Entries: PPointer; Count: Integer; AsTypeIID: PGUID): Integer; stdcall;

      property EntryCount: Integer read GetEntryCount;
  end;

  EPropertyTypeMismatch = class(Exception);
  EDatabaseReadOnly = class(Exception);

const
  MEM_STORE_DEFAULT_CAPACITY = $800;

  THREAD_SAFE_BLOCK_ENTRY_COUNT = 24;

  { Exception types }
  EXC_OTHER = 0;
  EXC_LOAD = 1;
  EXC_SAVE = 2;

implementation

uses
  ComObj,
  Math,
  TypInfo,
  WideStrUtils,
  Bfg.Unicode;

{ TDbStorageMedium }

procedure TDbStorageMedium.Initialize(const Metadata: ITypeInfo;
  const IID: TGUID; Args: PAnsiChar);
var
  WArgs: PWideChar;
  Arg: WideString;
  Name: WideString;
begin
  if Metadata = nil then Exit;

  FInitArgs := UTF8ToWideString(Args);
  FMetadata := Metadata;
  FTypeIID := IID;
  WArgs := PWideChar(FInitArgs);

  GetArg(WArgs, Name);
  FName := WIdeStringTOUTF8(Name);
  GetArg(WArgs, Arg);
  if WideLowerCase(Arg) = 'true' then FReadOnly := True else FReadOnly := False;

  InitializeMedium(WArgs);
end;

procedure TDbStorageMedium.InitializeMedium(var Args: PWideChar);
begin
  { Nothing here }
end;

constructor TDbStorageMedium.Create;
begin
  { Nothing here }
end;

function TDbStorageMedium.CreateStorageContext(Instance: Pointer;
  const Intf: IYesSerializable): TDbStorageContext;
begin
  Result := TDbStorageContext.Create(Instance, Intf);
end;

procedure TDbStorageMedium.DoOnError(const Msg: string);
begin
  if Assigned(FOnError) then FOnError(Self, Msg);
end;

class procedure TDbStorageMedium.GetArg(var Args: PWideChar; out Arg: WideString);
var
  Tmp: PWideChar;
begin
  if Args = nil then
  begin
    Arg := '';
    Exit;
  end;
  
  Tmp := Args;
  while (Args^ <> #0) and (Args^ <> ' ') and (Args^ <> '|') do Inc(Args);

  SetString(Arg, Tmp, Args - Tmp);

  if Args^ = #0 then
  begin
    Args := nil;
    Exit;
  end;

  while (Args^ = ' ') or (Args^ = '|') do Inc(Args);
end;

function TDbStorageMedium.GetName: PChar;
begin
  Result := Pointer(FName);
end;

procedure TDbStorageMedium.GetPropInfo(const PropName: AnsiString;
  out Info: IPropertyInfo; ExpectedType: Integer);
begin
  FMetadata.FindProperty(Pointer(PropName), Info);
  if Info.PropType <> ExpectedType then raise EPropertyTypeMismatch.Create('');
end;

{ TDbMemoryStorageMedium }

constructor TDbMemoryStorageMedium.Create;
begin
  inherited Create;

  FIdList := TPtrArrayList.Create(1024);
  InitializeAtomicSList(@FFreeList);

  FLock.Init;
end;

destructor TDbMemoryStorageMedium.Destroy;
var
  I: Integer;
  IdListEntry: PIdListEntry;
  Entry: PFreeListEntry;
  Itr: IPtrIterator;
begin
  { Release refs to interfaces }
  Itr := FIdList.First;
  while Itr.HasNext do
  begin
    IdListEntry := Itr.Next;
    TDbStorageContext(IdListEntry^.Intf.StorageContext).Free;
    Dispose(IdListEntry);
  end;

  FIdList.Free;

  { Free all atomic list entries }
  Entry := AtomicPopEntrySList(@FFreeList);
  while Entry <> nil do
  begin
    TDbStorageContext(Entry^.Intf.StorageContext).Free;
    Dispose(Entry);
    Entry := AtomicPopEntrySList(@FFreeList);
  end;

  { Now let's deallocate the memory blocks }
  for I := 0 to Length(FDataBlocks) -1 do
  begin
    Metadata.DestructorProc(FDataBlocks[I], FBlockCapacities[I],
      @TDbMemoryStorageMedium.DeallocationCallback, Self);
  end;

  { Delete RW lock }
  FLock.Delete;

  inherited Destroy;
end;

class function TDbMemoryStorageMedium.CompareSerializablesById(const E1,
  E2: TIdListEntry): Integer;
begin
  Result := E1.Id - E2.Id;
end;

class function TDbMemoryStorageMedium.MatchSerializableById(Id: Longword;
  const E: TIdListEntry): Integer;
begin
  Result := Id - E.Id;
end;

procedure TDbMemoryStorageMedium.AllocationCallback(Inst: Pointer);
var
  Entry: IYesSerializable;
  Ctx: TDbStorageContext;
begin
  OleCheck(Metadata.QueryInterfaceProc(Inst, IYesSerializable, Entry));
  Ctx := CreateStorageContext(Inst, Entry);
  Entry._AddRef;
  Entry.StorageContext := Ctx;
  InternalAddFreeClassInstance(Entry, Ctx.InstancePointer);
  Entry.Initialize;
end;

procedure TDbMemoryStorageMedium.DeallocationCallback(Inst: Pointer);
begin

end;

function TDbMemoryStorageMedium.CreateIdListEntry(Id: Longword;
  const Intf: IYesSerializable; Instance: Pointer): PIdListEntry;
begin
  New(Result);
  try
    Result^.Id := Id;
    Result^.Intf := Intf;
    Result^.Instance := Instance;
  except
    Dispose(Result);
    raise;
  end;
end;

procedure TDbMemoryStorageMedium.DeleteIdListEntry(Entry: PIdListEntry);
begin
  Dispose(Entry);
end;

procedure TDbMemoryStorageMedium.AcquireEntries(Entries: PPointer;
  Count: Integer);
begin
  if (Entries = nil) or (Count <= 0) then Exit;

  if Count = 1 then
  begin
    AcquireEntry(Entries);
    Exit;
  end;

  while Count > 0 do
  begin
    InternalGetFreeClassInstance(IYesSerializable(Entries^));
    Dec(Count);
    Inc(Entries);
  end;
end;

procedure TDbMemoryStorageMedium.AcquireEntry(Entry: PPointer);
begin
  if Entry = nil then Exit;

  InternalGetFreeClassInstance(IYesSerializable(Entry^));
end;

procedure TDbMemoryStorageMedium.AddEntry(Id: Longword;
  const Entry: IYesSerializable; Instance: Pointer);
begin
  IdList.Add(CreateIdListEntry(Id, Entry, Instance));
  if Id > FHighestId then FHighestId := Id;
  Inc(FCount);
end;

procedure TDbMemoryStorageMedium.CreateEntry(Entry: PPointer);
var
  EntryOut: IYesSerializable;
  EntryIn: IYesSerializable;
  EntryInRaw: Pointer;
  Id: Longword;
begin
  if Entry = nil then Exit;
  { If this storage is meant to be read-only then disallow creation of new entries }
  if ReadOnlyMode then raise EDatabaseReadOnly.Create('');

  { Now we get 2 new instances atomicly }
  InternalGetFreeClassInstance(EntryOut); { The one returned to the caller }
  InternalGetFreeClassInstance(EntryIn, @EntryInRaw); { The one representing the real in-DB entry }

  { Generate a new unique primary index - using this index to perform lookups is extremely fast }
  Id := GeneratePrimaryIndex;

  { Let's assign the unique id to both of the entries }
  EntryOut.UniqueId := Id;
  EntryIn.UniqueId := Id;

  LockWriteBegin;
  try
    IdList.Add(CreateIdListEntry(Id, EntryIn, EntryInRaw));
    Inc(FCount);
  finally
    LockWriteEnd;
  end;

  { Finally we convert the EntryOut into the interface we are expecting }
  EntryOut.QueryInterface(TypeIID, Entry^);
end;

function TDbMemoryStorageMedium.CreateLookupResult(const Intfs: IYesSerializableDynArray;
  OwnsEntries: Boolean): IYesLookupResult;
begin
  Result := TDbLookupResult.Create(Self, @TypeIID, Intfs, OwnsEntries);
end;

procedure TDbMemoryStorageMedium.CreateEntries(Entries: PPointer;
  Count: Integer);
var
  EntryOut: IYesSerializable;
  EntryIn: IYesSerializable;
  EntryInRaw: Pointer;
  Id: Longword;
begin
  if (Entries = nil) or (Count <= 0) then Exit;

  if Count = 1 then
  begin
    CreateEntry(Entries);
    Exit;
  end;

  { If this storage is meant to be read-only then disallow creation of new entries }
  if ReadOnlyMode then raise EDatabaseReadOnly.Create('');

  LockWriteBegin;
  try
    while Count > 0 do
    begin
      { Now we get 2 new instances atomicly }
      InternalGetFreeClassInstance(EntryOut); { The one returned to the caller }
      InternalGetFreeClassInstance(EntryIn, @EntryInRaw); { The one representing the real in-DB entry }

      { Generate a new unique primary index - using this index to perform lookups is extremely fast }
      Id := GeneratePrimaryIndex;

      { Let's assign the unique id to both of the entries }
      EntryOut.UniqueId := Id;
      EntryIn.UniqueId := Id;

      Inc(FCount);

      IdList.Add(CreateIdListEntry(Id, EntryIn, EntryInRaw));

      { Finally we convert the EntryOut into the interface we are expecting }
      EntryOut.QueryInterface(TypeIID, Entries^);
      Inc(Entries);
    end;
  finally
    LockWriteEnd;
  end;
end;

procedure TDbMemoryStorageMedium.DeleteEntries(Ids: PLongword; Count: Integer);
var
  Idx: Integer;
  Id: Longword;
  IdListEntry: PIdListEntry;
  Entry: IYesSerializable;
begin
  if (Ids = nil) or (Count <= 0) then Exit;

  if Count = 1 then
  begin
    DeleteEntry(Ids^);
    Exit;
  end;

  if ReadOnlyMode then raise EDatabaseReadOnly.Create('');

  LockWriteBegin;
  try
    while Count > 0 do
    begin
      Id := Ids^;
      Idx := IdList.CustomIndexOf(Pointer(Id), @TDbMemoryStorageMedium.MatchSerializableById);
      if Idx <> -1 then
      begin
        IdListEntry := IdList.Remove(Idx);
        try
          Entry := IdListEntry^.Intf;
          Entry.Clear;
          TDbStorageContext(Entry.StorageContext).Clear;
          Entry.Initialize;
          Dec(FCount);

          InternalAddFreeClassInstance(IdListEntry^.Intf, IdListEntry^.Instance);
        finally
          DeleteIdListEntry(IdListEntry);
        end;
      end;

      Dec(Count);
      Inc(Ids);
    end;
  finally
    LockWriteEnd;
  end;
end;

procedure TDbMemoryStorageMedium.DeleteEntry(Id: Longword);
var
  Idx: Integer;
  IdListEntry: PIdListEntry;
  Entry: IYesSerializable;
begin
  if ReadOnlyMode then raise EDatabaseReadOnly.Create('');

  LockWriteBegin;
  try
    Idx := IdList.CustomIndexOf(Pointer(Id), @TDbMemoryStorageMedium.MatchSerializableById);
    if Idx <> -1 then
    begin
      IdListEntry := IdList.Remove(Idx);
      try
        Entry := IdListEntry^.Intf;
        Entry.Clear;
        Entry.Initialize;
        Dec(FCount);

        InternalAddFreeClassInstance(IdListEntry^.Intf, IdListEntry^.Instance);
      finally
        DeleteIdListEntry(IdListEntry);
      end;
    end;
  finally
    LockWriteEnd;
  end;
end;

procedure TDbMemoryStorageMedium.SaveEntries(Entries: PYesSerializable;
  Count: Integer; Release: Boolean);
var
  Id: UInt32;
  Idx: Int32;
  IdListEntry: PIdListEntry;
  EntryIn: IYesSerializable;
  EntryInRaw: Pointer;
  Entry: IYesSerializable;
begin
  if (Entries = nil) or (Count <= 0) then Exit;

  if Count = 1 then
  begin
    SaveEntry(Entries^, Release);
    Exit;
  end;

  if ReadOnlyMode then raise EDatabaseReadOnly.Create('');

  LockWriteBegin;
  try
    while Count > 0 do
    begin
      Entry := Entries^;
      if Entry <> nil then
      begin
        Id := Entry.UniqueId;
        Idx := IdList.CustomIndexOf(Pointer(Id), @TDbMemoryStorageMedium.MatchSerializableById);
        if Idx <> -1 then
        begin
          IdListEntry := IdList[Idx];
          IdListEntry^.Intf.Assign(Entry);
          if Release then
          begin
            Entry.Clear;
            Entry.Initialize;
            InternalAddFreeClassInstance(Entry, TDbStorageContext(Entry.StorageContext).InstancePointer);
          end;
        end else
        begin
          if not Release then
          begin
            InternalGetFreeClassInstance(EntryIn, @EntryInRaw);
            EntryIn.Assign(Entry);

            IdList.Add(CreateIdListEntry(EntryIn.UniqueId, EntryIn, EntryInRaw));
          end else
          begin
            IdList.Add(CreateIdListEntry(EntryIn.UniqueId, Entry,
              TDbStorageContext(Entry.StorageContext).InstancePointer));
          end;
  
          if Id > FHighestId then FHighestId := Id;
          Inc(FCount);
        end;
      end;
      
      Dec(Count);
      Inc(Entries);
    end;
  finally
    LockWriteEnd;
  end;
end;

procedure TDbMemoryStorageMedium.SaveEntry(const Entry: IYesSerializable;
  Release: Boolean);
var
  Id: UInt32;
  Idx: Int32;
  IdListEntry: PIdListEntry;
  EntryIn: IYesSerializable;
  EntryInRaw: Pointer;
begin
  if ReadOnlyMode then raise EDatabaseReadOnly.Create('');

  if Entry <> nil then
  begin
    LockWriteBegin;
    try
      Id := Entry.UniqueId;
      Idx := IdList.CustomIndexOf(Pointer(Id), @TDbMemoryStorageMedium.MatchSerializableById);
      if Idx <> -1 then
      begin
        IdListEntry := IdList[Idx];
        IdListEntry^.Intf.Assign(Entry);
        if Release then
        begin
          Entry.Clear;
          Entry.Initialize;
          InternalAddFreeClassInstance(Entry, TDbStorageContext(Entry.StorageContext).InstancePointer);
        end;
      end else
      begin
        if not Release then
        begin
          InternalGetFreeClassInstance(EntryIn, @EntryInRaw);
          EntryIn.Assign(Entry);

          IdList.Add(CreateIdListEntry(EntryIn.UniqueId, EntryIn, EntryInRaw));
        end else
        begin
          IdList.Add(CreateIdListEntry(EntryIn.UniqueId, Entry,
            TDbStorageContext(Entry.StorageContext).InstancePointer));
        end;
        
        if Id > FHighestId then FHighestId := Id;
        Inc(FCount);
      end;
    finally
      LockWriteEnd;
    end;
  end;
end;

procedure TDbMemoryStorageMedium.ReleaseEntry(const Entry: IYesSerializable);
begin
  if Entry <> nil then
  begin
    Entry.Clear;
    Entry.Initialize;
    InternalAddFreeClassInstance(Entry, TDbStorageContext(Entry.StorageContext).InstancePointer);
  end;
end;

procedure TDbMemoryStorageMedium.ReleaseEntries(Entries: PYesSerializable; Count: Integer);
var
  Entry: IYesSerializable;
begin
  if Entries <> nil then Exit;

  while Count > 0 do
  begin
    Entry := Entries^;
    if Entry <> nil then
    begin
      Entry.Clear;
      Entry.Initialize;
      InternalAddFreeClassInstance(Entry, TDbStorageContext(Entry.StorageContext).InstancePointer);
    end;

    Inc(Entries);
    Dec(Count);
  end;
end;

function TDbMemoryStorageMedium.GetEntryCount: Integer;
begin
  Result := FCount;
end;

function TDbMemoryStorageMedium.GeneratePrimaryIndex: Longword;
begin
  Result := AtomicInc(@FHighestId);
end;

procedure TDbMemoryStorageMedium.InitializeMedium(var Args: PWideChar);
var
  S: WideString;
begin
  GetArg(Args, S);
  FDefaultCapacity := WideStrToIntDef(S, MEM_STORE_DEFAULT_CAPACITY);
end;

procedure TDbMemoryStorageMedium.InternalAllocateNewClassBuffer(InstCount: Integer);
var
  Idx: Integer;
begin
  Idx := Length(FDataBlocks);

  { Grow both arrays by one }
  SetLength(FDataBlocks, Idx + 1);
  SetLength(FBlockCapacities, Idx + 1);

  InstCount := Max(FDefaultCapacity, InstCount);

  { Store it }
  FBlockCapacities[Idx] := InstCount;
  { Now allocate the buffer }
  FDataBlocks[Idx] := Metadata.ConstructorProc(InstCount,
    @TDbMemoryStorageMedium.AllocationCallback, Self);
end;

procedure TDbMemoryStorageMedium.InternalGetFreeClassInstance(out Intf: IYesSerializable;
  InstPtr: PPointer);
var
  ListEntry: PFreeListEntry;
begin
  ListEntry := AtomicPopEntrySList(@FFreeList);
  try
    if not Assigned(ListEntry) then
    begin
      InternalAllocateNewClassBuffer;
      ListEntry := AtomicPopEntrySList(@FFreeList);
    end;

    Intf := ListEntry.Intf;
    if InstPtr <> nil then InstPtr^ := ListEntry.Instance;
  finally
    Dispose(ListEntry);
  end;
end;

procedure TDbMemoryStorageMedium.InternalAddFreeClassInstance(const Intf: IYesSerializable;
  Inst: Pointer);
var
  ListEntry: PFreeListEntry;
begin
  New(ListEntry);
  try
    ListEntry^.Intf := Intf;
    ListEntry^.Instance := Inst;
    AtomicPushEntrySList(@FFreeList, ListEntry);
  except
    Dispose(ListEntry);
    raise;
  end;
end;

procedure TDbMemoryStorageMedium.LockReadBegin;
begin
  FLock.BeginRead;
end;

procedure TDbMemoryStorageMedium.LockReadEnd;
begin
  FLock.EndRead;
end;

procedure TDbMemoryStorageMedium.LockWriteBegin;
begin
  FLock.BeginWrite;
end;

procedure TDbMemoryStorageMedium.LockWriteEnd;
begin
  FLock.EndWrite;
end;

procedure TDbMemoryStorageMedium.LookupEntry(Id: Longword; Entry: PPointer);
var
  Idx: Integer;
begin
  if Entry = nil then Exit;

  FLock.BeginRead;
  try
    Idx := FIdList.CustomIndexOf(Pointer(Id), @TDbMemoryStorageMedium.MatchSerializableById);
    if Idx <> -1 then
    begin
      PIdListEntry(FIdList[Idx])^.Intf.QueryInterface(TypeIID, Entry^)
    end else PPointer(Entry)^ := nil;
  finally
    FLock.EndRead;
  end;
end;

procedure TDbMemoryStorageMedium.LookupEntryList(Field: PAnsiChar;
  CmpValue: Float; CmpOp: TCompareOp; Epsilon: Float; Result: PYesLookupResult;
  ResultOwnsEntries: Boolean);
var
  I: Integer;
  C: Integer;
  Count: Integer;
  IdListEntry: PIdListEntry;
  PropInfo: IPropertyInfo;
  PropValue: Single;
  Temps: IYesSerializableDynArray;
begin
  if (Field = nil) or (Result = nil) then Exit;

  Metadata.FindProperty(Field, PropInfo);
  if (PropInfo = nil) or (PropInfo.PropType <> METADATA_PROPTYPE_FLOAT) then Exit;
  Count := 0;
  C := 0;

  case CmpOp of
    // Lesser comparison
    COMPARE_OP_LE:
    begin
      for I := 0 to FIdList.Size -1 do
      begin
        IdListEntry := FIdList[I];

        PropValue := PropInfo.GetFloatProp(IdListEntry^.Instance);

        if PropValue < CmpValue then
        begin
          if Count = C then
          begin
            Inc(C, 64);
            SetLength(Temps, C);
          end;

          Temps[Count] := IdListEntry^.Intf;
          Inc(Count);
        end;
      end;
    end;
    // Lesser or equal comparsion
    COMPARE_OP_LEQ:
    begin
      for I := 0 to FIdList.Size -1 do
      begin
        IdListEntry := FIdList[I];

        PropValue := PropInfo.GetFloatProp(IdListEntry^.Instance);

        if PropValue <= CmpValue then
        begin
          if Count = C then
          begin
            Inc(C, 64);
            SetLength(Temps, C);
          end;

          Temps[Count] := IdListEntry^.Intf;
          Inc(Count);
        end;
      end;
    end;
    // Equal comparison
    COMPARE_OP_EQ:
    begin
      for I := 0 to FIdList.Size -1 do
      begin
        IdListEntry := FIdList[I];

        PropValue := PropInfo.GetFloatProp(IdListEntry^.Instance);

        if SameValue(PropValue, CmpValue, Epsilon) then
        begin
          if Count = C then
          begin
            Inc(C, 64);
            SetLength(Temps, C);
          end;

          Temps[Count] := IdListEntry^.Intf;
          Inc(Count);
        end;
      end;
    end;
    // Not equal comparison
    COMPARE_OP_NEQ:
    begin
      for I := 0 to FIdList.Size -1 do
      begin
        IdListEntry := FIdList[I];

        PropValue := PropInfo.GetFloatProp(IdListEntry^.Instance);

        if not SameValue(PropValue, CmpValue, Epsilon) then
        begin
          if Count = C then
          begin
            Inc(C, 64);
            SetLength(Temps, C);
          end;

          Temps[Count] := IdListEntry^.Intf;
          Inc(Count);
        end;
      end;
    end;
    // Greater or equal comparsion
    COMPARE_OP_GEQ:
    begin
      for I := 0 to FIdList.Size -1 do
      begin
        IdListEntry := FIdList[I];

        PropValue := PropInfo.GetFloatProp(IdListEntry^.Instance);

        if PropValue >= CmpValue then
        begin
          if Count = C then
          begin
            Inc(C, 64);
            SetLength(Temps, C);
          end;

          Temps[Count] := IdListEntry^.Intf;
          Inc(Count);
        end;
      end;
    end;
    // Greater comparsion
    COMPARE_OP_GE:
    begin
      for I := 0 to FIdList.Size -1 do
      begin
        IdListEntry := FIdList[I];

        PropValue := PropInfo.GetFloatProp(IdListEntry^.Instance);

        if PropValue >CmpValue then
        begin
          if Count = C then
          begin
            Inc(C, 64);
            SetLength(Temps, C);
          end;

          Temps[Count] := IdListEntry^.Intf;
          Inc(Count);
        end;
      end;
    end;
  end;

  if Count <> 0 then
  begin
    SetLength(Temps, Count);
    Result^ := CreateLookupResult(Temps, ResultOwnsEntries);
  end else Result^ := nil;
end;

procedure TDbMemoryStorageMedium.LookupEntryList(Field: PAnsiChar;
  CmpValue: Longword; CmpOp: TCompareOp; Result: PYesLookupResult;
  ResultOwnsEntries: Boolean);
var
  I: Integer;
  C: Integer;
  Count: Integer;
  IdListEntry: PIdListEntry;
  PropInfo: IPropertyInfo;
  PropValue: Float;
  Temps: IYesSerializableDynArray;
begin
  if (Field = nil) or (Result = nil) then Exit;

  Metadata.FindProperty(Field, PropInfo);
  if (PropInfo = nil) or (PropInfo.PropType <> METADATA_PROPTYPE_FLOAT) then Exit;
  Count := 0;
  C := 0;

  case CmpOp of
    // Lesser comparison
    COMPARE_OP_LE:
    begin
      for I := 0 to FIdList.Size -1 do
      begin
        IdListEntry := FIdList[I];

        PropValue := PropInfo.GetFloatProp(IdListEntry^.Instance);

        if PropValue < CmpValue then
        begin
          if Count = C then
          begin
            Inc(C, 64);
            SetLength(Temps, C);
          end;

          Temps[Count] := IdListEntry^.Intf;
          Inc(Count);
        end;
      end;
    end;
    // Lesser or equal comparsion
    COMPARE_OP_LEQ:
    begin
      for I := 0 to FIdList.Size -1 do
      begin
        IdListEntry := FIdList[I];

        PropValue := PropInfo.GetFloatProp(IdListEntry^.Instance);

        if PropValue <= CmpValue then
        begin
          if Count = C then
          begin
            Inc(C, 64);
            SetLength(Temps, C);
          end;

          Temps[Count] := IdListEntry^.Intf;
          Inc(Count);
        end;
      end;
    end;
    // Equal comparison
    COMPARE_OP_EQ:
    begin
      for I := 0 to FIdList.Size -1 do
      begin
        IdListEntry := FIdList[I];

        PropValue := PropInfo.GetFloatProp(IdListEntry^.Instance);

        if PropValue = CmpValue then
        begin
          if Count = C then
          begin
            Inc(C, 64);
            SetLength(Temps, C);
          end;

          Temps[Count] := IdListEntry^.Intf;
          Inc(Count);
        end;
      end;
    end;
    // Not equal comparison
    COMPARE_OP_NEQ:
    begin
      for I := 0 to FIdList.Size -1 do
      begin
        IdListEntry := FIdList[I];

        PropValue := PropInfo.GetFloatProp(IdListEntry^.Instance);

        if PropValue <> CmpValue then
        begin
          if Count = C then
          begin
            Inc(C, 64);
            SetLength(Temps, C);
          end;

          Temps[Count] := IdListEntry^.Intf;
          Inc(Count);
        end;
      end;
    end;
    // Greater or equal comparsion
    COMPARE_OP_GEQ:
    begin
      for I := 0 to FIdList.Size -1 do
      begin
        IdListEntry := FIdList[I];

        PropValue := PropInfo.GetFloatProp(IdListEntry^.Instance);

        if PropValue >= CmpValue then
        begin
          if Count = C then
          begin
            Inc(C, 64);
            SetLength(Temps, C);
          end;

          Temps[Count] := IdListEntry^.Intf;
          Inc(Count);
        end;
      end;
    end;
    // Greater comparsion
    COMPARE_OP_GE:
    begin
      for I := 0 to FIdList.Size -1 do
      begin
        IdListEntry := FIdList[I];

        PropValue := PropInfo.GetFloatProp(IdListEntry^.Instance);

        if PropValue >CmpValue then
        begin
          if Count = C then
          begin
            Inc(C, 64);
            SetLength(Temps, C);
          end;

          Temps[Count] := IdListEntry^.Intf;
          Inc(Count);
        end;
      end;
    end;
  end;

  if Count <> 0 then
  begin
    SetLength(Temps, Count);
    Result^ := CreateLookupResult(Temps, ResultOwnsEntries);
  end else Result^ := nil;
end;

procedure TDbMemoryStorageMedium.LookupEntryList(Field: PAnsiChar;
  CmpValue: PAnsiChar; CaseSensitive: Boolean; Result: PYesLookupResult;
  ResultOwnsEntries: Boolean);
type
  TCAnsiStrComp = function(const P1, P2: PAnsiChar): Integer;
const
  Comparators: array[Boolean] of TCAnsiStrComp = (
    StrIComp,
    StrComp
  );
var
  I: Integer;
  L: Integer;
  C: Integer;
  Count: Integer;
  IdListEntry: PIdListEntry;
  PropInfo: IPropertyInfo;
  PropValue: AnsiString;
  Temps: IYesSerializableDynArray;
  Comparator: TCAnsiStrComp;
begin
  if (Field = nil) or (Result = nil) or (CmpValue = nil) then Exit;

  Metadata.FindProperty(Field, PropInfo);
  if (PropInfo = nil) or (PropInfo.PropType <> METADATA_PROPTYPE_STRING) then Exit;
  Count := 0;
  C := 0;

  Comparator := Comparators[CaseSensitive];

  for I := 0 to FIdList.Size -1 do
  begin
    IdListEntry := FIdList[I];

    // Getting the wide string prop, allocated on stack
    L := PropInfo.GetStrProp(IdListEntry^.Instance, nil, 0) + 1;
    SetLength(PropValue, L);
    PropInfo.GetStrProp(IdListEntry^.Instance, PChar(PropValue), L);

    if Comparator(PChar(PropValue), CmpValue) = 0 then
    begin
      if Count = C then
      begin
        Inc(C, 64);
        SetLength(Temps, C);
      end;

      Temps[Count] := IdListEntry^.Intf;
      Inc(Count);
    end;
  end;

  if Count <> 0 then
  begin
    SetLength(Temps, Count);
    Result^ := CreateLookupResult(Temps, ResultOwnsEntries);
  end else Result^ := nil;
end;

procedure TDbMemoryStorageMedium.LookupEntryList(Field: PAnsiChar;
  CmpValue: PWideChar; CaseSensitive: Boolean; Result: PYesLookupResult;
  ResultOwnsEntries: Boolean);
type
  TCWideStrComp = function(const P1, P2: PWideChar): Integer;
const
  Comparators: array[Boolean] of TCWideStrComp = (
    StrICompW,
    StrCompW
  );
var
  I: Integer;
  L: Integer;
  C: Integer;
  Count: Integer;
  IdListEntry: PIdListEntry;
  PropInfo: IPropertyInfo;
  PropValue: WideString;
  Temps: IYesSerializableDynArray;
  Comparator: TCWideStrComp;
begin
  if (Field = nil) or (Result = nil) or (CmpValue = nil) then Exit;

  Metadata.FindProperty(Field, PropInfo);
  if (PropInfo = nil) or (PropInfo.PropType <> METADATA_PROPTYPE_WSTRING) then Exit;
  Count := 0;
  C := 0;

  Comparator := Comparators[CaseSensitive];

  for I := 0 to FIdList.Size -1 do
  begin
    IdListEntry := FIdList[I];

    // Getting the wide string prop, allocated on stack
    L := PropInfo.GetWideStrProp(IdListEntry^.Instance, nil, 0) + 1;
    SetLength(PropValue, L);
    PropInfo.GetWideStrProp(IdListEntry^.Instance, PWideChar(PropValue), L);

    if Comparator(PWideChar(PropValue), CmpValue) = 0 then
    begin
      if Count = C then
      begin
        Inc(C, 64);
        SetLength(Temps, C);
      end;

      Temps[Count] := IdListEntry^.Intf;
      Inc(Count);
    end;
  end;

  if Count <> 0 then
  begin
    SetLength(Temps, Count);
    Result^ := CreateLookupResult(Temps, ResultOwnsEntries);
  end else Result^ := nil;
end;

(*
procedure TDbMemoryStorageMedium.LookupEntryList(
  Predicate: YES_PREDICATE_CALLBACK; Context: Pointer; PassRawEntries: Boolean;
  Result: PYesLookupResult);
var
  I: Integer;
  C: Integer;
  Count: Integer;
  IdListEntry: PIdListEntry;
  Temps: IYesSerializableDynArray;
begin
  if (@Predicate = nil) or (Result = nil) then Exit;

  Count := 0;
  C := 0;

  if not PassRawEntries then
  begin
    for I := 0 to FIdList.Size -1 do
    begin
      IdListEntry := FIdList[I];

      if Predicate(Context, Pointer(IdListEntry^.Intf)) then
      begin
        if Count = C then
        begin
          Inc(C, 64);
          SetLength(Temps, C);
        end;

        Temps[Count] := IdListEntry^.Intf;
        Inc(Count);
      end;
    end;
  end else
  begin
    for I := 0 to FIdList.Size -1 do
    begin
      IdListEntry := FIdList[I];

      if Predicate(Context, IdListEntry^.Instance) then
      begin
        if Count = C then
        begin
          Inc(C, 64);
          SetLength(Temps, C);
        end;

        Temps[Count] := IdListEntry^.Intf;
        Inc(Count);
      end;
    end;
  end;

  if Count <> 0 then
  begin
    Result^ := CreateLookupResult(Temps);
  end else Result^ := nil;
end;
*)

class procedure TDbMemoryStorageMedium.RaiseException(Op: Integer; const FileName: WideString;
  const Msg: string);
const
  ExceptionTable: array[0..2] of ExceptClass = (
    Exception, Exception, Exception
  );
var
  ExceptionClass: ExceptClass;
begin
  if (Op < Low(ExceptionTable)) or (Op > High(ExceptionTable)) then
  begin
    ExceptionClass := Exception;
  end else
  begin
    ExceptionClass := ExceptionTable[Op];
    if ExceptionClass = nil then ExceptionClass := Exception;
  end;
  raise ExceptionClass.CreateFmt({RsFileErrOp}'File op error in %s - %s', [FileName, Msg]) at GetCurrentReturnAddress;
end;

{ TDbStorageContext }

procedure TDbStorageContext.Clear;
begin
  // Nothing by default
end;

constructor TDbStorageContext.Create(Instance: Pointer;
  const Intf: IYesSerializable);
begin
  FInstancePtr := Instance;
end;

{ TDbLookupResult }

constructor TDbLookupResult.Create(const Owner: TDbMemoryStorageMedium; TypeIIDRef: PGUID;
  const Intfs: IYesSerializableDynArray; OwnsEntries: Boolean);
begin
  FData := Intfs;
  FOwner := Owner;
  FTypeIIDRef := TypeIIDRef;
  FReleaseEntries := OwnsEntries;
end;

destructor TDbLookupResult.Destroy;
begin
  if FReleaseEntries then FOwner.ReleaseEntries(@FData[0], Length(FData));

  inherited Destroy;
end;

function TDbLookupResult.GetData(Entries: PPointer; Count: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  if (Entries = nil) or (Count <= 0) then Exit;

  for I := 0 to Min(Count, Length(FData)) -1 do
  begin
    FData[I].QueryInterface(FTypeIIDRef^, Entries^);
    Inc(Entries);
    Inc(Result);
  end;
end;

function TDbLookupResult.GetDataEx(Entries: PPointer; Count: Integer;
  AsTypeIID: PGUID): Integer;
var
  I: Integer;
begin
  Result := 0;
  if (Entries = nil) or (Count <= 0) then Exit;

  if AsTypeIID = nil then AsTypeIID := FTypeIIDRef;

  for I := 0 to Min(Count, Length(FData)) -1 do
  begin
    FData[I].QueryInterface(AsTypeIID^, Entries^);
    Inc(Entries);
    Inc(Result);
  end;
end;

function TDbLookupResult.GetEntryCount: Integer;
begin
  Result := Length(FData);
end;

end.

