{*------------------------------------------------------------------------------
  Main OpenObject that derives into many others.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.WowObject;

interface

uses
  Framework.Base,
  Components.DataCore.Storage,
  Components.DataCore.Fields,
  Components.NetworkCore.Packet,
  Components.Shared,
  Components.GameCore.UpdateFields,
  Components.GameCore.Interfaces,
  Components.DataCore,
  Components.DataCore.Types,
  Components.Interfaces,
  Misc.Containers,
  Misc.Miscleanous,
  Misc.Algorithm,
  Classes,
  SysUtils;

type
  YOpenObjectClass = class of YGaWowObject;

  YWorldStateChange = (wscAdd, wscRemove, wscEnter, wscLeave);
  {
    wscAdd - when placed in the world for the first time
    wscRemove - when removed from the world for the good
    wscEnter - re-entering world after leaving it
    wscLeave - temporary leave world, can re-enter later
  }

  YGaTimerSet = class;    
  YTimerEntry = class;

  YTimedMethod = procedure(Timer: YTimerEntry) of object;

  YTimerIdent = type UInt32;

  YTimerEntry = class
    private
      fIdent: YTimerIdent;
      fOwner: YGaTimerSet;
      fElapsed: UInt32;
      fRequired: UInt32;
      fMethod: YTimedMethod;
      fRepeats: UInt32;
      fDisabled: Boolean;
    public
      property Disabled: Boolean read fDisabled write fDisabled;
      property Elapsed: UInt32 read fElapsed write fElapsed;
      property Required: UInt32 read fRequired write fRequired;
      property Repeats: UInt32 read fRepeats write fRepeats;
      property Owner: YGaTimerSet read fOwner;
      property Ident: YTimerIdent read fIdent;
  end;

  YGaTimerSet = class(TBaseInterfacedObject)
    private
      fTimers: array of YTimerEntry;
      fCapacity: Int32;
      fCount: Int32;
      procedure Grow;
      function GetTimer(Ident: YTimerIdent): YTimerEntry;
    protected
      procedure UpdateTimers(Delta: UInt32);
    public
      constructor Create;
      destructor Destroy; override;

      procedure CreateTimer(Ident: YTimerIdent; Method: YTimedMethod; Delay: UInt32;
        Repeats: UInt32; Disabled: Boolean = False);
      procedure DeleteTimer(Ident: YTimerIdent);
      property TimerEntries[Ident: YTimerIdent]: YTimerEntry read GetTimer; default;
  end;

  { Basic WoW Derivable Object }
  YGaWowObject = class(TBaseInterfacedObject, IObject)
    private
      fAllFields: TLongWordDynArray;
      fVisibilityArray: PLongWordArray;
      fNeedsUpdate: PLongWordArray;
      fZeroValues: PLongWordArray;

      fNeedsUpdateLowIndex: UInt32;
      fNeedsUpdateHighIndex: UInt32;
      fNeedsUpdateLowIndexVisible: UInt32;
      fNeedsUpdateHighIndexVisible: UInt32;

      fMaskLen: Int32;

      fInWorld: Longbool;
      fUpdateRequested: Longbool;
      fTimerSet: YGaTimerSet;
    protected
      fOpenObjectType: YWowObjectType;
      fStorage: YDbStorageMedium;

      procedure SetMaskUpdateType(iType: YWowObjectType);
      procedure SetMaskLength(Length: Int32);

      procedure SetInWorld(Value: Boolean); inline;

      function GetGUID: PObjectGuid; inline;
      function GetInWorld: Boolean; inline;

      procedure SetObjectType(UpdType: UInt32; ObjType: YWowObjectType);

      class function GetObjectType: Int32; virtual; { Override in each descendant class }
      class function GetOpenObjectType: YWowObjectType; virtual; { Override in each descendant class }

      function GetObjType: YWowObjectType;

      { Override this in children to perform resource loading }
      procedure ExtractObjectData(Entry: YDbSerializable); virtual;
      { Override this in children to perform resource saving }
      procedure InjectObjectData(Entry: YDbSerializable); virtual;
      { Override this in children to perform resource deletion }
      procedure CleanupObjectData; virtual;

      function GetInternalDataIndex: Int32;
      procedure SetInternalDataIndex(Id: UInt32);

      procedure AddToWorld; virtual;
      procedure RemoveFromWorld; virtual;
      procedure EnterWorld; virtual;
      procedure LeaveWorld; virtual;

      procedure AssignUpdateDataArray(const Data: TLongWordDynArray);

      procedure SetCreationParams(out UpdateType: UInt8; UpdatingSelf: Boolean); virtual;

      procedure AddMovementData(Pkt: YNwServerPacket; UpdatingSelf: Boolean); virtual; abstract;
    public
      constructor Create; virtual;
      destructor Destroy; override;

      procedure FreeInstance; override;

      { Runtime Type Check }
      function IsType(ObjType: YWowObjectType): Boolean; inline;

      { Forces the object to send its updates to the players }
      procedure OnValuesUpdate; virtual; abstract;

      { Fills the packet with a creational update block }
      procedure FillObjectCreationPacket(Pkt: YNwServerPacket; UpdatingSelf: Boolean = True);
      { Fills the packet with a regular update block }
      procedure FillObjectUpdatePacket(Pkt: YNwServerPacket; UpdatingSelf: Boolean = True);
      { Fills the packet with a destructional update block }
      procedure FillObjectDestructionPacket(cPkt: YNwServerPacket; UpdatingSelf: Boolean = True);

      procedure ChangeWorldState(State: YWorldStateChange);

      { Load this object from database }
      procedure LoadFromDataBase(Entry: YDbSerializable = nil);
      { Save this object to database }
      procedure SaveToDataBase;
      { Delete this object from database }
      procedure DeleteFromDataBase;

      { Note: Directly sets a field to value specified }
      procedure SetUInt8(Index: Int32; Position: UInt8; Value: UInt8);
      procedure SetUInt16(Index: Int32; Position: UInt8; Value: UInt16);
      procedure SetUInt32(Index: Int32; Value: UInt32);
      procedure SetUInt64(Index: Int32; const Value: UInt64);
      procedure SetFloat(Index: Int32; const Value: Float); inline;

      { Note: Use for making sure this value is present in a field (flags mostly) }
      procedure OrUInt8(Index: Int32; Position: UInt8; Value: UInt8);
      procedure OrUInt16(Index: Int32; Position: UInt8; Value: UInt16);
      procedure OrUInt32(Index: Int32; Value: UInt32);
      procedure OrUInt64(Index: Int32; const Value: UInt64);

      { Note: Use for toggeling values (flags mostly) }
      { Example:
        1.
        before XorUInt32(0, $100):
        fAllFields[0] = $00040100
        after XorUInt32(0, $100);
        fAllFields[0] = $00040000

        2.
        before XorUInt32(0, $100):
        fAllFields[0] = $00040000
        after XorUInt32(0, $100);
        fAllFields[0] = $00040100
      }
      procedure XorUInt8(Index: Int32; Position: UInt8; Value: UInt8);
      procedure XorUInt16(Index: Int32; Position: UInt8; Value: UInt16);
      procedure XorUInt32(Index: Int32; Value: UInt32);
      procedure XorUInt64(Index: Int32; const Value: UInt64);

      { Note: These methods currently have no use, but may have some in the future }
      { Example:
        before AndUInt32(0, $00FFFFFF):
        fAllFields[0] = $1403CCEF
        after AndUInt32(0, $00FFFFFF);
        fAllFields[0] = $0003CCEF
      }
      procedure AndUInt8(Index: Int32; Position: UInt8; Value: UInt8);
      procedure AndUInt16(Index: Int32; Position: UInt8; Value: UInt16);
      procedure AndUInt32(Index: Int32; Value: UInt32);
      procedure AndUInt64(Index: Int32; const Value: UInt64);

      { Note: These methods currently have no use, but may have some in the future }
      { Example:
        before NotUInt32(0):
        fAllFields[0] = $0000001A
        after NotUInt32(0);
        fAllFields[0] = $FFFFFFE5
      }
      procedure NotUInt8(Index: Int32; Position: UInt8);
      procedure NotUInt16(Index: Int32; Position: UInt8);
      procedure NotUInt32(Index: Int32);
      procedure NotUInt64(Index: Int32);

      { Note: Use for making sure this value is NOT present in a field (flags mostly) }
      { Example:
        1.
        before AndNotUInt32(0, $100):
        fAllFields[0] = $00040100
        after AndNotUInt32(0, $100);
        fAllFields[0] = $00040000

        2.
        before AndNotUInt32(0, $100):
        fAllFields[0] = $00040000
        after AndNotUInt32(0, $100);
        fAllFields[0] = $00040000
      }
      procedure AndNotUInt8(Index: Int32; Position: UInt8; Value: UInt8);
      procedure AndNotUInt16(Index: Int32; Position: UInt8; Value: UInt16);
      procedure AndNotUInt32(Index: Int32; Value: UInt32);
      procedure AndNotUInt64(Index: Int32; const Value: UInt64);

      { Note: Use for checking (flags mostly) }
      { Performs bitwise AND and if result is non-zero, sets resul to true, otherwise false }
      function TestUInt8(Index: Int32; Position: UInt8; Value: UInt8): Boolean;
      function TestUInt16(Index: Int32; Position: UInt8; Value: UInt16): Boolean;
      function TestUInt32(Index: Int32; Value: UInt32): Boolean;
      function TestUInt64(Index: Int32; Value: UInt64): Boolean;

      function TestBit(Index: Int32; Position: UInt8): Boolean;
      procedure SetBit(Index: Int32; Position: UInt8);
      procedure ResetBit(Index: Int32; Position: UInt8);
      procedure ToggleBit(Index: Int32; Position: UInt8);

      procedure AddUInt8(Index: Int32; Position: UInt8; Value: UInt8);
      procedure AddUInt16(Index: Int32; Position: UInt8; Value: UInt16);
      procedure AddUInt32(Index: Int32; Value: UInt32);
      procedure AddUInt64(Index: Int32; const Value: UInt64);
      procedure AddFloat(Index: Int32; const Value: Float);

      procedure SubUInt8(Index: Int32; Position: UInt8; Value: UInt8);
      procedure SubUInt16(Index: Int32; Position: UInt8; Value: UInt16);
      procedure SubUInt32(Index: Int32; Value: UInt32);
      procedure SubUInt64(Index: Int32; const Value: UInt64);
      procedure SubFloat(Index: Int32; const Value: Float);

      function CompareUInt8(Index: Int32; Position: UInt8; Value: UInt8): Boolean;
      function CompareUInt16(Index: Int32; Position: UInt8; Value: UInt16): Boolean;
      function CompareUInt32(Index: Int32; Value: UInt32): Boolean;
      function CompareUInt64(Index: Int32; Value: UInt64): Boolean;

      { Note: I think name says it all }
      function GetUInt8(Index: Int32; Position: UInt8): UInt8; inline;
      function GetUInt16(Index: Int32; Position: UInt8): UInt16; inline;
      function GetUInt32(Index: Int32): UInt32; inline;
      function GetUInt64(Index: Int32): UInt64; inline;
      function GetFloat(Index: Int32): Float; inline;
      function GetElementPtr(Index: Int32): PUInt32; inline;

      { A special method, it tries to remove iOldFlag from the update field at the
        given index and or-s it with iNewFlag }
      { Note: This method is equal to calls to AndNotUIntXX + OrUIntXX, but a bit faster }
      { Example:
        before ReplaceUInt32(0, $00800000, $00040000):
        fAllFields[0] = $00800010
        after ReplaceUInt32(0, $00800000, $00040000):
        fAllFields[0] = $00040010
      }
      procedure ReplaceUInt8(Index: Int32; Position: UInt8; OldFlag: UInt8; NewFlag: UInt8); inline;
      procedure ReplaceUInt16(Index: Int32; Position: UInt8; OldFlag: UInt16; NewFlag: UInt16); inline;
      procedure ReplaceUInt32(Index: Int32; OldFlag: UInt32; NewFlag: UInt32); inline;
      procedure ReplaceUInt64(Index: Int32; OldFlag: UInt64; NewFlag: UInt64); inline;

      { This method copies bits from source to an update field }
      { Note: This method always operates on UInt32-s }
      { Example:
        before BitCopyUpdate(0, $00000007, 1, 1, 1):
        fAllFields[0] = $00000001
        after
        fAllFields[0] = $00000003
      }
      procedure BitCopyUpdate(Index: Int32; Value: UInt32; DestIndex: Integer;
        SrcIndex: Integer; Count: Integer);

      { Get the Update Mask Contents }
      procedure AddUpdateMask(Pkt: YNwPacket; Creation: Boolean; OnlyVisible: Boolean);
      { A simplified version of update mask adding - just for 1 field }
      procedure AddSingleFieldUpdate(Pkt: YNwPacket; Index: Int32);
      { Adds a field update to the packet, but does not change updatefields or notify
        the group manager }
      procedure AddSingleFieldOverrideUpdate(Pkt: YNwPacket; Index: Int32; Value: UInt32);

      { Marks all updates as satisfied }
      procedure MarkUpdatesSatisfied;

      { Invalidates this object, forcing it to be updated }
      procedure RequestUpdate;

      { Edit }
      property GUID: PObjectGuid read GetGUID;
      property GUIDHi: UInt32 index OBJECT_FIELD_GUID + UPDATE_GUID_HI read GetUInt32 write SetUInt32;
      property GUIDLo: UInt32 index OBJECT_FIELD_GUID + UPDATE_GUID_LO read GetUInt32 write SetUInt32;
      property GUIDFull: UInt64 index OBJECT_FIELD_GUID read GetUInt64 write SetUInt64;

      property Size: Float index OBJECT_FIELD_SCALE_X read GetFloat write SetFloat;
      property Entry: UInt32 index OBJECT_FIELD_ENTRY read GetUInt32 write SetUInt32;
      property &Type: UInt32 index OBJECT_FIELD_TYPE read GetUInt32 write SetUInt32;

      { General Properties }
      property DataMedium: YDbStorageMedium read fStorage write fStorage;
      property ObjectType: YWowObjectType read GetOpenObjectType;
      property MaskLength: Int32 read fMaskLen;
      property InWorld: Longbool read fInWorld write fInWorld;
      property UpdatesPending: Longbool read fUpdateRequested;
      property TimerSet: YGaTimerSet read fTimerSet;
    end;

implementation

uses
  Framework,
  Cores,
  Components.NetworkCore.Opcodes,
  Components.GameCore.WowItem,
  Components.GameCore.PacketBuilders,
  Components.GameCore.Factory;

const
  UPD_FIELD_INDEX_INVALID_LO = $7FFFFFFF;
  UPD_FIELD_INDEX_INVALID_HI = $FFFFFFFF;

constructor YGaWowObject.Create;
var
  iType: YWowObjectType;
begin
  inherited Create;

  fTimerSet := YGaTimerSet.Create;
  
  fNeedsUpdateLowIndex := UPD_FIELD_INDEX_INVALID_LO;
  fNeedsUpdateHighIndex := UPD_FIELD_INDEX_INVALID_HI;
  fNeedsUpdateLowIndexVisible := UPD_FIELD_INDEX_INVALID_LO;
  fNeedsUpdateHighIndexVisible := UPD_FIELD_INDEX_INVALID_HI;

  iType := GetOpenObjectType;

  SetMaskUpdateType(iType);
  SetObjectType(GetObjectType, iType);
end;

destructor YGaWowObject.Destroy;
begin
  if fNeedsUpdate <> nil then FreeMem(fNeedsUpdate);
  if fZeroValues <> nil then FreeMem(fZeroValues);
  fTimerSet.Free;
  inherited Destroy;
end;

procedure YGaWowObject.FreeInstance;
var
  pHeader: PObjectHeader;
begin
  { First cleanup all dynamic data }
  CleanupInstance;
  pHeader := Pointer(Self);
  Dec(pHeader);
  if pHeader^.Recycled = False then
  begin
    { Indirect recycle (through destructor) }
    pHeader^.Recycled := True;
    pHeader^.Factory.Recycle(Self);
  end;
end;

procedure YGaWowObject.DeleteFromDataBase;
begin
  CleanupObjectData;
  fStorage.DeleteEntry(GetInternalDataIndex);
end;

procedure YGaWowObject.ExtractObjectData(Entry: YDbSerializable);
var
  cUpd: YDbWowObjectEntry;
begin
  cUpd := YDbWowObjectEntry(Entry);
  { Read Standard Update Data }
  Assert(Length(cUpd.UpdateData) = MaskLength);

  AssignUpdateDataArray(cUpd.UpdateData);
end;

function YGaWowObject.GetInternalDataIndex: Int32;
begin
  Result := GUIDLo;
end;

function YGaWowObject.GetInWorld: Boolean;
begin
  Result := InWorld;
end;

procedure YGaWowObject.SetInternalDataIndex(Id: UInt32);
begin
  GUIDLo := Id;
end;

procedure YGaWowObject.InjectObjectData(Entry: YDbSerializable);
var
  cUpd: YDbWowObjectEntry;
begin
  cUpd := YDbWowObjectEntry(Entry);
  cUpd.AssignUpdateData(PLongWordArray(GetElementPtr(0)), MaskLength);
end;

procedure YGaWowObject.CleanupObjectData;
begin
end;

procedure YGaWowObject.LoadFromDataBase(Entry: YDbSerializable = nil);
var
  cUpd: YDbWowObjectEntry;
begin
  cUpd := YDbWowObjectEntry(Entry);
  if Assigned(cUpd) then
  begin
    SetInternalDataIndex(cUpd.UniqueID);
  end else
  begin
    fStorage.LoadEntry(GetInternalDataIndex, cUpd);
  end;

  if Assigned(cUpd) then ExtractObjectData(cUpd); { Do da' dew ! }

  GUIDHi := GameCore.GenerateHighGUID(fOpenObjectType);
end;

procedure YGaWowObject.SaveToDataBase;
var
  cUpd: YDbWowObjectEntry;
begin
  fStorage.LoadEntry(GetInternalDataIndex, cUpd);
  if cUpd = nil then
  begin
    fStorage.CreateEntry(cUpd, GetInternalDataIndex);
    { Will also ensure derivates will add their properties }
    InjectObjectData(cUpd);
  end else
  begin
    { Will also ensure derivates will add their properties }
    InjectObjectData(cUpd);
  end;
  fStorage.SaveEntry(cUpd);
end;

class function YGaWowObject.GetObjectType;
begin
  Result := UPDATEFLAG_OBJECT;
end;

function YGaWowObject.GetObjType: YWowObjectType;
begin
  Result := GetOpenObjectType;
end;

class function YGaWowObject.GetOpenObjectType: YWowObjectType;
begin
  Result := otObject;
end;

procedure YGaWowObject.SetInWorld(Value: Boolean);
begin
  InWorld := Value;
end;

//function YGaWowObject.GetDatabaseValue(const FieldName: string): IVariant;
//var
//  cSer: YDbSerializable;
//begin
//  fStorage.LoadEntry(GUIDLo, cSer);
//  cSer.GetCustomDataByName(FieldName, Result);
//  fStorage.ReleaseEntry(cSer);
//end;

function YGaWowObject.GetGUID: PObjectGuid;
begin
  Result := PObjectGuid(GetElementPtr(OBJECT_FIELD_GUID));
end;

procedure YGaWowObject.SetObjectType(UpdType: UInt32; ObjType: YWowObjectType);
begin
  &Type := UpdType;
  fOpenObjectType := ObjType;
end;
  
function YGaWowObject.IsType(ObjType: YWowObjectType): Boolean;
begin
  Result := fOpenObjectType = ObjType;
end;

(*
function YGaWowObject.BuildCreatePacketForObject(cTo: YGaWowObject): YNwPacket;
var
  iObjType: YWowObjectType;
  lwType: UInt8;
  lwMoveFlags: UInt8;
  lwMoveAddFlags: UInt32;
  bUpdatingSelf: Boolean;
begin
  iObjType := fOpenObjectType;
  lwType := UPDATETYPE_CREATE_OBJECT;
  lwMoveFlags := MOVE_BASE_FLAG_UNKNOWN0;
  lwMoveAddFlags := MOVE_SECOND_FLAG_NONE;
  bUpdatingSelf := True;

  Result := YNwPacket.Create;
  { Check what THIS object is and generate its updates accordingly }
  case iObjType of
    otUnit, otNode:
    begin
      lwMoveFlags := lwMoveFlags or MOVE_BASE_FLAG_UNKNOWN1 or MOVE_BASE_FLAG_UNKNOWN2;
      lwMoveAddFlags := MOVE_SECOND_FLAG_UNKNOWN3;
    end;
    otPlayer:
    begin
      lwMoveFlags := lwMoveFlags or MOVE_BASE_FLAG_UNKNOWN1 or MOVE_BASE_FLAG_UNKNOWN2;

      if cTo = Self then  { This player is updating itself }
      begin
        lwType := UPDATETYPE_CREATE_OBJECT_ME;
        lwMoveFlags := lwMoveFlags or MOVE_BASE_FLAG_UNKNOWN3;
        lwMoveAddFlags := MOVE_SECOND_FLAG_UNKNOWN1;
      end else bUpdatingSelf := False;
    end;
    otGameObject..otCorpse:
    begin
      lwMoveFlags := lwMoveFlags or MOVE_BASE_FLAG_UNKNOWN2;
    end;
    otPlayerCorpse:
    begin
      lwMoveFlags := lwMoveFlags or MOVE_BASE_FLAG_UNKNOWN2 or MOVE_BASE_FLAG_UNKNOWN4;
      lwMoveAddFlags := MOVE_SECOND_FLAG_UNIQUE;
    end;
  end;

  BuildCreateObjectHeader(Self, lwType, Result);
  AddObjectMovement(Result, lwMoveFlags, lwMoveAddFlags);
  AddObjectUpdates(Result, True, bUpdatingSelf);
  { OK, we have generated an Update block here ... the Group manager (the one that
    required this update) will do the rest. }
end;

procedure BuildUpdateObjectMove(cObj: YGaWowObject; cPkt: YNwPacket; iMoveFlags: UInt8;
  iMoveAddFlags: UInt32);
var
  cMob: YGaMobile absolute cObj;
begin
  cPkt.AddUInt8(iMoveFlags);

  case cObj.ObjectType of
    otUnit, otNode:
    begin
      cPkt.AddUInt32(iMoveAddFlags);
      cPkt.AddUInt32(GetCurrentTime);

      cPkt.AddStruct(cMob.Position.Vector, 12);
      cPkt.AddFloat(cMob.Position.Angle);

      cPkt.Jump(4); { Unknown data ... }

      cPkt.AddFloat(cMob.Position.WalkSpeed);
      cPkt.AddFloat(cMob.Position.RunSpeed);
      cPkt.AddFloat(cMob.Position.BackSwimSpeed);
      cPkt.AddFloat(cMob.Position.SwimSpeed);
      cPkt.AddFloat(cMob.Position.BackWalkSpeed);
      cPkt.AddFloat(cMob.Position.TurnRate);

      if (iMoveAddFlags and MOVE_SECOND_FLAG_UNKNOWN2) <> 0 then
      begin
        cPkt.Jump(20);
      end;
    end;
    otPlayer:
    begin
      cPkt.AddUInt32(iMoveAddFlags);
      cPkt.Jump(4); { Unknown data ... }
      cPkt.AddStruct(cMob.Position.Vector, 12);
      cPkt.AddFloat(cMob.Position.Angle);
      cPkt.AddFloat(0); { Unknown data ... }

      if (iMoveAddFlags and MOVE_SECOND_FLAG_UNKNOWN1) <> 0 then
      begin
        cPkt.AddFloat(0); { Unknown ...}
        cPkt.AddFloat(1); { Unknown ...}
        cPkt.AddFloat(0); { Unknown ...}
        cPkt.AddFloat(0); { Unknown ...}
      end;

      cPkt.AddFloat(cMob.Position.WalkSpeed);
      cPkt.AddFloat(cMob.Position.RunSpeed);
      cPkt.AddFloat(cMob.Position.BackSwimSpeed);
      cPkt.AddFloat(cMob.Position.SwimSpeed);
      cPkt.AddFloat(cMob.Position.BackWalkSpeed);
      cPkt.AddFloat(cMob.Position.TurnRate);
    end;
    otGameObject..otPlayerCorpse:
    begin
      cPkt.AddStruct(cMob.Position.Vector, 12);
      cPkt.AddFloat(cMob.Position.Angle);
    end;
  end;
  
  cPkt.Jump(4); { Unknown ...}

  if (iMoveAddFlags and MOVE_SECOND_FLAG_UNIQUE) <> 0 then
  begin
    cPkt.Jump(4); { Unknown ...}
  end;
end;
*)

procedure YGaWowObject.SetCreationParams(out UpdateType: UInt8; UpdatingSelf: Boolean);
begin
  UpdateType := UPDATETYPE_CREATE_OBJECT;
end;

procedure YGaWowObject.FillObjectCreationPacket(Pkt: YNwServerPacket; UpdatingSelf: Boolean);
var
  lwType: UInt8;
begin
  { Virtual calls here, don't worry performace-wise overshadowed by AddUpdateMask }
  SetCreationParams(lwType, UpdatingSelf);
  { Add the header }
  Pkt.AddUInt8(lwType);
  Pkt.AddPackedGUID(GUID);
  Pkt.AddUInt8(UpdateTable[ObjectType]);
  { The movement data }
  AddMovementData(Pkt, UpdatingSelf);
  { Add the update mask itself }
  AddUpdateMask(Pkt, True, not UpdatingSelf);
end;

procedure YGaWowObject.FillObjectDestructionPacket(cPkt: YNwServerPacket;
  UpdatingSelf: Boolean);
begin
  cPkt.Initialize(SMSG_DESTROY_OBJECT, 12);
  cPkt.AddUInt64(GUIDFull);
end;

procedure YGaWowObject.FillObjectUpdatePacket(Pkt: YNwServerPacket; UpdatingSelf: Boolean);
begin
  Pkt.AddUInt8(UPDATETYPE_VALUES);
  Pkt.AddPackedGUID(GUID);
  AddUpdateMask(Pkt, False, not UpdatingSelf);
end;

procedure YGaWowObject.ChangeWorldState(State: YWorldStateChange);
begin
  case State of
    wscAdd: AddToWorld;
    wscRemove: RemoveFromWorld;
    wscEnter: EnterWorld;
    wscLeave: LeaveWorld;
  end;
end;

procedure YGaWowObject.EnterWorld;
begin
  InWorld := True;
end;

procedure YGaWowObject.LeaveWorld;
begin
  InWorld := False;
end;

procedure YGaWowObject.AddToWorld;
begin
  GameCore.RegisterObjectGUID(fOpenObjectType, Self);
  EnterWorld;
end;

procedure YGaWowObject.RemoveFromWorld;
begin
  LeaveWorld;
  GameCore.UnregisterObjectGUID(fOpenObjectType, GUIDLo);
  SaveToDatabase;
end;

{$WARNINGS OFF}
procedure YGaWowObject.AddUpdateMask(Pkt: YNwPacket; Creation: Boolean; OnlyVisible: Boolean);
const
  UPDATE_FULL           = 0;
  UPDATE_FULL_OTHER     = 1;
  UPDATE_PARTIAL        = 2;
  UPDATE_PARTIAL_OTHER  = 3;

  UpdateDecisionTable: array[Boolean, Boolean] of Int32 = (
    (UPDATE_PARTIAL, UPDATE_PARTIAL_OTHER),
    (UPDATE_FULL, UPDATE_FULL_OTHER)
  );
var
  iFirst: Int32;
  iLast: Int32;
  iRem: Int32;
  iMaskLen: Int32;
  iRealMaskLen: Int32;
  iDataCount: Int32;
  pMaskBuf: PLongWordArray;
  pDataBuf: PUInt32;
  pUpdArray: PLongWordArray;

  procedure ReserveMaskBuffer;
  begin
    iMaskLen := DivModPowerOf2(iLast + 1, 5, iRem);
    iRealMaskLen := iMaskLen shl 2;
    { iMaskLen holds the length of update mask in UInt32's }
    if iRem <> 0 then
    begin
      Inc(iRealMaskLen, DivModPowerOf2Inc(iRem, 3));
      Inc(iMaskLen);
    end;

    iDataCount := 0;

    pUpdArray := PLongWordArray(fAllFields);
    pMaskBuf := Pkt.GetWritePtrOfSize(iMaskLen shl 2 + 1); { Reserve iMaskLen * 4 Bytes in the packet }
    PByte(pMaskBuf)^ := iMaskLen; { The length of Mask Buffer }
    Inc(PByte(pMaskBuf));

    pDataBuf := Pkt.GetCurrentWritePtr;
  end;

  procedure DoAddFieldsCreateFull;
  asm
    PUSH  EBX
    PUSH  ESI
    PUSH  EDI
    MOV   EAX, iFirst
    MOV   EDX, iLast
    MOV   EDI, pDataBuf
    MOV   ESI, pUpdArray
    XOR   ECX, ECX
  @@Loop:
    CMP   EAX, EDX
    JA    @@Exit
    CMP   [ESI+EAX*4], 0
    JZ    @@Zero
    MOV   EBX, [ESI+EAX*4]
    MOV   [EDI+ECX*4], EBX
    INC   EAX
    INC   ECX
    JMP   @@Loop
  @@Zero:
    INC   EAX
    JMP   @@Loop
  @@Exit:
    MOV   iDataCount, ECX
    POP   EDI
    POP   ESI
    POP   EBX
  end;

  procedure DoAddFields;
  asm
    PUSH  EBX
    PUSH  ESI
    PUSH  EDI
    MOV   EAX, iFirst
    MOV   EDX, pMaskBuf
    MOV   EDI, pDataBuf
    MOV   ESI, iLast
    XOR   ECX, ECX
  @@Loop:
    CMP   EAX, ESI
    JA    @@Exit
    BT    [EDX], EAX
    JNC   @@BitNotSet
    MOV   EBX, pUpdArray
    MOV   EBX, [EBX+EAX*4]
    MOV   [EDI+ECX*4], EBX
    INC   EAX
    INC   ECX
    JMP   @@Loop
  @@BitNotSet:
    INC   EAX
    JMP   @@Loop
  @@Exit:
    MOV   iDataCount, ECX
    POP   EDI
    POP   ESI
    POP   EBX
  end;
begin
  { This branch is the key optimization (though code duplication is present). }
  case UpdateDecisionTable[Creation, OnlyVisible] of
    UPDATE_FULL:
    begin
      { All updates, regardless of visiblity }

      { Always iterate over all fields }
      iFirst := 0;
      iLast := fMaskLen -1;

      { Reserve te mask buffer and init some values }
      ReserveMaskBuffer;

      { Here we consider only non-zero values - the updatemask is de facto fZeroValues
        toggled, no need to set bits manually }
      NotBuffer(fZeroValues^, pMaskBuf^, iRealMaskLen);

      DoAddFieldsCreateFull;
    end;
    UPDATE_FULL_OTHER:
    begin
      { All updates, considering visibility }

      { Always iterate over all fields }
      iFirst := 0;
      iLast := fMaskLen -1;

      { Reserve te mask buffer and init some values }
      ReserveMaskBuffer;

      { Here we consider both visibility and non-zero values - the updatemask is
        de facto AND NOT of fZeroValues and fVisibilityArray, no need to set bits manually }
      AndNotBuffers(fVisibilityArray^, fZeroValues^, pMaskBuf^, iRealMaskLen);

      { This calls the subroutine which adds the fields themselves. }
      DoAddFields;
    end;
    UPDATE_PARTIAL:
    begin
      { Only updated fields, regardless of visibility }

      { Here we iterate over all fields which are marked as changed }
      iLast := fNeedsUpdateHighIndex;
      if UInt32(iLast) = UPD_FIELD_INDEX_INVALID_HI then
      begin
        { Update construction was requested, but no updateable fields exist }
        Pkt.Jump(1);
        Exit;
      end;

      iFirst := fNeedsUpdateLowIndex;
      if UInt32(iFirst) = UPD_FIELD_INDEX_INVALID_LO then iFirst := 0;

      if iFirst = iLast then
      begin
        { A special case, when only 1 field needs to be updated }
        AddSingleFieldUpdate(Pkt, iFirst);
        Exit;
      end;

      { Reserve te mask buffer and init some values }
      ReserveMaskBuffer;

      { Here we consider only updates - the updatemask is de facto
        the fNeedsUpdate bit array, no need to set bits manually }
      Move(fNeedsUpdate^, pMaskBuf^, iRealMaskLen);

      { This calls the subroutine which adds the fields themselves. }
      DoAddFields;
    end;
    UPDATE_PARTIAL_OTHER:
    begin
      { Only updated fields, considering visibility }

      { Here we iterate over all fields which are marked as changed and are also
        marked as visible }
      iLast := fNeedsUpdateHighIndexVisible;
      if UInt32(iLast) = UPD_FIELD_INDEX_INVALID_HI then
      begin
        { Update construction was requested, but no updateable fields exist }
        Pkt.Jump(1);
        Exit;
      end;

      iFirst := fNeedsUpdateLowIndexVisible;
      if UInt32(iFirst) = UPD_FIELD_INDEX_INVALID_LO then iFirst := 0;

      if iFirst = iLast then
      begin
        { A special case, when only 1 field needs to be updated }
        AddSingleFieldUpdate(Pkt, iFirst);
        Exit;
      end;

      { Reserve te mask buffer and init some values }
      ReserveMaskBuffer;

      { Here we consider both visibility and updates - the updatemask is de facto
        AND of fNeedsUpdate and fVisibilityArray, no need to set bits manually }
      AndBuffers(fNeedsUpdate^, fVisibilityArray^, pMaskBuf^, iRealMaskLen);

      { This calls the subroutine which adds the fields themselves. }
      DoAddFields;
    end;
  end;

  Pkt.Jump(iDataCount shl 2);
end;
{$WARNINGS ON}

procedure YGaWowObject.AddSingleFieldUpdate(Pkt: YNwPacket; Index: Int32);
var
  iMaskLen: Int32;
begin
  iMaskLen := DivModPowerOf2Inc(Index + 1, 5);

  Pkt.AddUInt8(iMaskLen);
  Misc.Miscleanous.SetBit(Pkt.GetWritePtrOfSize(iMaskLen shl 2), Index);
  Pkt.AddUInt32(fAllFields[Index]);
end;

procedure YGaWowObject.AddSingleFieldOverrideUpdate(Pkt: YNwPacket; Index: Int32; Value: UInt32);
var
  iMaskLen: Int32;
  iRem: Int32;
begin
  iMaskLen := DivModPowerOf2(Index + 1, 5, iRem);
  if iRem <> 0 then
  begin
    Inc(iMaskLen);
  end;

  Pkt.AddUInt8(iMaskLen);
  Misc.Miscleanous.SetBit(Pkt.GetWritePtrOfSize(iMaskLen shl 2), Index);
  Pkt.AddUInt32(Value);
end;

procedure YGaWowObject.SetMaskUpdateType(iType: YWowObjectType);
begin
  fVisibilityArray := GetVisibilityArray(iType);
  SetMaskLength(UpdateMaskLenghts[iType]);
end;

procedure YGaWowObject.SetMaskLength(Length: Int32);
var
  iSize: Int32;
begin
  fMaskLen := Length;

  SetLength(fAllFields, fMaskLen);

  GetBitBuffer(fZeroValues, fMaskLen, iSize);
  FillChar(fZeroValues^, iSize, $FF); { Initially all set to 1 }
  fNeedsUpdate := AllocBitBuffer(fMaskLen);
end;

procedure YGaWowObject.MarkUpdatesSatisfied;
begin
  { Marks all updates as satisfied and sent }
  if fNeedsUpdateLowIndex = fNeedsUpdateHighIndex then
  begin
    Misc.Miscleanous.ResetBit(fNeedsUpdate, fNeedsUpdateLowIndex);
  end else
  begin
    Misc.Miscleanous.ResetBits(fNeedsUpdate, fNeedsUpdateLowIndex, fNeedsUpdateHighIndex);
  end;
  fUpdateRequested := False;
  fNeedsUpdateLowIndex := UPD_FIELD_INDEX_INVALID_LO;
  fNeedsUpdateHighIndex := UPD_FIELD_INDEX_INVALID_HI;
  fNeedsUpdateLowIndexVisible := UPD_FIELD_INDEX_INVALID_LO;
  fNeedsUpdateHighIndexVisible := UPD_FIELD_INDEX_INVALID_HI;
end;

procedure YGaWowObject.RequestUpdate;
begin
  GameCore.ObjectRequiresUpdate(Self);
  fUpdateRequested := True;
end;

function YGaWowObject.GetFloat(Index: Int32): Float;
begin
  Result := TSingleDynArray(fAllFields)[Index];
end;

function YGaWowObject.GetUInt8(Index: Int32; Position: UInt8): UInt8;
begin
  Result := LongRec(fAllFields[Index]).Bytes[Position];
end;

function YGaWowObject.GetUInt16(Index: Int32; Position: UInt8): UInt16;
begin
  Result := LongRec(fAllFields[Index]).Words[Position];
end;

function YGaWowObject.GetUInt32(Index: Int32): UInt32;
begin
  Result := fAllFields[Index];
end;

function YGaWowObject.GetUInt64(Index: Int32): UInt64;
var
  aRes: array[0..1] of UInt32 absolute Result;
begin
  aRes[0] := fAllFields[Index];
  aRes[1] := fAllFields[Index+1];
end;

function YGaWowObject.GetElementPtr(Index: Int32): PUInt32;
begin
  Result := @fAllFields[Index];
end;

procedure _TestPosOverflow;
const
  TableAccessMsgs: array[Boolean] of string = (
    'Byte index overflow (%d) in update mask - contact developers to help fix this problem.',
    'Word index overflow (%d) in update mask - contact developers to help fix this problem.'
  );
var
  Position: UInt8;
  bType: Boolean;
begin
  asm
    MOV  Position, CL
    MOV  bType, CH
  end;
  Assert(False, Format(TableAccessMsgs[bType], [Position]));
end;

function YGaWowObject.TestUInt8(Index: Int32; Position, Value: UInt8): Boolean;
asm
  CMP   CL, 3
  JA    _TestPosOverflow
  MOV   EAX, [EAX].YGaWowObject.fAllFields
  LEA   EAX, [EAX+EDX*4]
  MOV   DL, BYTE PTR [EBP+8]
  MOVZX ECX, CL
  TEST  BYTE PTR [EAX+ECX], DL
  SETNZ AL
  RET
@@Overflow:
  MOV   CH, 0
  JMP   _TestPosOverflow
end;

function YGaWowObject.TestUInt16(Index: Int32; Position: UInt8;
  Value: UInt16): Boolean;
asm
  CMP   CL, 1
  JA    @@Overflow
  MOV   EAX, [EAX].YGaWowObject.fAllFields
  LEA   EAX, [EAX+EDX*4]
  MOV   DX, WORD PTR [EBP+8]
  MOVZX ECX, CL
  TEST  WORD PTR [EAX+ECX*2], DX
  SETNZ AL
  RET
@@Overflow:
  MOV   CH, 1
  JMP   _TestPosOverflow
end;

function YGaWowObject.TestUInt32(Index: Int32; Value: UInt32): Boolean;
asm
  MOV   EAX, [EAX].YGaWowObject.fAllFields
  TEST  [EAX+EDX*4], ECX
  SETNZ AL
end;

function YGaWowObject.TestUInt64(Index: Int32; Value: UInt64): Boolean;
asm
  PUSH  EBX
  MOV   EBX, EDX
  MOV   EDX, [EBP+8]
  MOV   ECX, [EAX].YGaWowObject.fAllFields
  TEST  EDX, EDX
  JZ    @@SkipFirstCheck
  TEST  [ECX+EBX*4], EDX
  JZ    @@Exit
@@SkipFirstCheck:
  INC   EBX
  MOV   EDX, [EBP+12]
  TEST  [ECX+EBX*4], EDX
  SETNZ AL
  POP   EBX
  POP   EBP
  RET   8
@@Exit:
  XOR   AL, AL
  POP   EBX
end;

function YGaWowObject.CompareUInt8(Index: Int32; Position, Value: UInt8): Boolean;
asm
  CMP   CL, 3
  JA    _TestPosOverflow
  MOV   EAX, [EAX].YGaWowObject.fAllFields
  LEA   EAX, [EAX+EDX*4]
  MOV   DL, BYTE PTR [EBP+8]
  MOVZX ECX, CL
  CMP   DL, BYTE PTR [EAX+ECX]
  SETZ  AL
  RET
@@Overflow:
  MOV   CH, 0
  JMP   _TestPosOverflow
end;

function YGaWowObject.CompareUInt16(Index: Int32; Position: UInt8;
  Value: UInt16): Boolean;
asm
  CMP   CL, 1
  JA    @@Overflow
  MOV   EAX, [EAX].YGaWowObject.fAllFields
  LEA   EAX, [EAX+EDX*4]
  MOV   DX, WORD PTR [EBP+8]
  MOVZX ECX, CL
  CMP   DX, WORD PTR [EAX+ECX*2]
  SETZ  AL
  RET
@@Overflow:
  MOV   CH, 1
  JMP   _TestPosOverflow
end;

function YGaWowObject.CompareUInt32(Index: Int32; Value: UInt32): Boolean;
asm
  MOV   EAX, [EAX].YGaWowObject.fAllFields
  CMP   ECX, [EAX+EDX*4]
  SETZ  AL
end;

function YGaWowObject.CompareUInt64(Index: Int32; Value: UInt64): Boolean;
asm
  PUSH  EBX
  MOV   EBX, EDX
  MOV   EDX, [EBP+8]
  MOV   ECX, [EAX].YGaWowObject.fAllFields
  TEST  EDX, EDX
  JZ    @@SkipFirstCheck
  CMP   EDX, [ECX+EBX*4]
  JNZ   @@Exit
@@SkipFirstCheck:
  INC   EBX
  MOV   EDX, [EBP+12]
  CMP   EDX, [ECX+EBX*4]
  SETZ  AL
  POP   EBX
  POP   EBP
  RET   8
@@Exit:
  XOR   AL, AL
  POP   EBX
end;

procedure YGaWowObject.AddUInt8(Index: Int32; Position, Value: UInt8);
var
  lwTemp: Longword;
begin
  lwTemp := fAllFields[Index];
  LongRec(lwTemp).Bytes[Position] := LongRec(lwTemp).Bytes[Position] + Value;
  SetUInt32(Index, lwTemp);
end;

procedure YGaWowObject.AddUInt16(Index: Int32; Position: UInt8; Value: UInt16);
var
  lwTemp: Longword;
begin
  lwTemp := fAllFields[Index];
  LongRec(lwTemp).Words[Position] := LongRec(lwTemp).Words[Position] + Value;
  SetUInt32(Index, lwTemp);
end;

procedure YGaWowObject.AddUInt32(Index: Int32; Value: UInt32);
begin
  SetUInt32(Index, fAllFields[Index] + Value);
end;

procedure YGaWowObject.AddUInt64(Index: Int32; const Value: UInt64);
var
  qwTemp: UInt64;
begin
  qwTemp := PUInt64(Int32(fAllFields) + Index * 4)^;
  SetUInt64(Index, qwTemp + Value);
end;

procedure YGaWowObject.AddFloat(Index: Int32; const Value: Float);
begin
  SetFloat(Index, TSingleDynArray(fAllFields)[Index] + Value);
end;

procedure YGaWowObject.SubUInt8(Index: Int32; Position, Value: UInt8);
var
  lwTemp: Longword;
begin
  lwTemp := fAllFields[Index];
  LongRec(lwTemp).Bytes[Position] := LongRec(lwTemp).Bytes[Position] - Value;
  SetUInt32(Index, lwTemp);
end;

procedure YGaWowObject.SubUInt16(Index: Int32; Position: UInt8; Value: UInt16);
var
  lwTemp: Longword;
begin
  lwTemp := fAllFields[Index];
  LongRec(lwTemp).Words[Position] := LongRec(lwTemp).Words[Position] - Value;
  SetUInt32(Index, lwTemp);
end;

procedure YGaWowObject.SubUInt32(Index: Int32; Value: UInt32);
begin
  SetUInt32(Index, fAllFields[Index] - Value);
end;

procedure YGaWowObject.SubUInt64(Index: Int32; const Value: UInt64);
var
  qwTemp: UInt64;
begin
  qwTemp := PUInt64(Int32(fAllFields) + Index * 4)^;
  SetUInt64(Index, qwTemp - Value);
end;

procedure YGaWowObject.SubFloat(Index: Int32; const Value: Float);
begin
  SetFloat(Index, TSingleDynArray(fAllFields)[Index] - Value);
end;

procedure YGaWowObject.SetUInt8(Index: Int32; Position, Value: UInt8);
var
  lwTemp: Longword;
begin
  lwTemp := fAllFields[Index];
  LongRec(lwTemp).Bytes[Position] := Value;
  SetUInt32(Index, lwTemp);
end;

procedure YGaWowObject.SetUInt16(Index: Int32; Position: UInt8; Value: UInt16);
var
  lwTemp: Longword;
begin
  lwTemp := fAllFields[Index];
  LongRec(lwTemp).Words[Position] := Value;
  SetUInt32(Index, lwTemp);
end;

procedure YGaWowObject.SetUInt32(Index: Int32; Value: UInt32);
begin
  { Do not update if the value is already the same }
  if fAllFields[Index] <> Value then
  begin
    { We set the zero bits if neccessary or we reset them }
    if (Value = 0) xor (fAllFields[Index] = 0) then
    begin
      Misc.Miscleanous.ToggleBit(fZeroValues, Index);
    end;

    fAllFields[Index] := Value;

    if Int32(Index) > Int32(fNeedsUpdateHighIndex) then fNeedsUpdateHighIndex := Index
    else if Int32(Index) < Int32(fNeedsUpdateLowIndex) then fNeedsUpdateLowIndex := Index;

    if GetBit(fVisibilityArray, Index) then
    begin
      if Int32(Index) > Int32(fNeedsUpdateHighIndexVisible) then fNeedsUpdateHighIndexVisible := Index
      else if Int32(Index) < Int32(fNeedsUpdateLowIndexVisible) then fNeedsUpdateLowIndexVisible := Index;
    end;

    Misc.Miscleanous.SetBit(fNeedsUpdate, Index); { Mark the field as "Update-Me!" }

    if not fUpdateRequested and fInWorld then RequestUpdate;
  end;
end;

procedure YGaWowObject.SetUInt64(Index: Int32; const Value: UInt64);
const
  UINT64_UPD_NONE  = 0;
  UINT64_UPD_HIGH  = 1;
  UINT64_UPD_LOW   = 2;
  UINT64_UPD_FULL  = 3;

  UInt64UpdateDecisionTable: array[Boolean, Boolean] of Int32 = (
    (UINT64_UPD_NONE, UINT64_UPD_HIGH),
    (UINT64_UPD_LOW, UINT64_UPD_FULL)
  );
var
  iInts: array[0..1] of UInt32 absolute Value;
  IndexHigh: UInt32;
begin
  case UInt64UpdateDecisionTable[fAllFields[Index] <> iInts[0], fAllFields[Index+1] <> iInts[1]] of
    UINT64_UPD_NONE: Exit;
    UINT64_UPD_HIGH:
    begin
      { iInts[0] - False, iInts[1] - True }
      Inc(Index);

      if (iInts[1] = 0) xor (fAllFields[Index] = 0) then
      begin
        Misc.Miscleanous.ToggleBit(fZeroValues, Index);
      end;

      fAllFields[Index] := iInts[1];

      if Int32(Index) > Int32(fNeedsUpdateHighIndex) then fNeedsUpdateHighIndex := Index
      else if Int32(Index) < Int32(fNeedsUpdateLowIndex) then fNeedsUpdateLowIndex := Index;

      if GetBit(fVisibilityArray, Index) then
      begin
        if Int32(Index) > Int32(fNeedsUpdateHighIndexVisible) then fNeedsUpdateHighIndexVisible := Index
        else if Int32(Index) < Int32(fNeedsUpdateLowIndexVisible) then fNeedsUpdateLowIndexVisible := Index;
      end;

      if fInWorld or (iInts[1] <> 0) then
      begin
        Misc.Miscleanous.SetBit(fNeedsUpdate, Index); { Mark the field as "Update-Me!" }
      end;
    end;
    UINT64_UPD_LOW:
    begin
      { iInts[0] - True, iInts[1] - False }
      if (iInts[0] = 0) xor (fAllFields[Index] = 0) then
      begin
        Misc.Miscleanous.ToggleBit(fZeroValues, Index);
      end;

      fAllFields[Index] := iInts[0];

      if Int32(Index) > Int32(fNeedsUpdateHighIndex) then fNeedsUpdateHighIndex := Index
      else if Int32(Index) < Int32(fNeedsUpdateLowIndex) then fNeedsUpdateLowIndex := Index;

      if GetBit(fVisibilityArray, Index) then
      begin
        if Int32(Index) > Int32(fNeedsUpdateHighIndexVisible) then fNeedsUpdateHighIndexVisible := Index
        else if Int32(Index) < Int32(fNeedsUpdateLowIndexVisible) then fNeedsUpdateLowIndexVisible := Index;
      end;

      if fInWorld or (iInts[0] <> 0) then
      begin
        Misc.Miscleanous.SetBit(fNeedsUpdate, Index); { Mark the field as "Update-Me!" }
      end;
    end;
    UINT64_UPD_FULL:
    begin
      IndexHigh := Index + 1;

      { iInts[0] - True, iInts[1] - True }
      if (iInts[0] = 0) xor (fAllFields[Index] = 0) then
      begin
        Misc.Miscleanous.ToggleBit(fZeroValues, Index);
      end;

      if (iInts[1] = 0) xor (fAllFields[IndexHigh] = 0) then
      begin
        Misc.Miscleanous.ToggleBit(fZeroValues, IndexHigh);
      end;

      fAllFields[Index] := iInts[0];
      fAllFields[IndexHigh] := iInts[1];

      if Int32(IndexHigh) > Int32(fNeedsUpdateHighIndex) then fNeedsUpdateHighIndex := IndexHigh
      else if Int32(Index) < Int32(fNeedsUpdateLowIndex) then fNeedsUpdateLowIndex := Index;

      if GetBit(fVisibilityArray, Index) then
      begin
        if Int32(IndexHigh) > Int32(fNeedsUpdateHighIndexVisible) then fNeedsUpdateHighIndexVisible := IndexHigh
        else if Int32(Index) < Int32(fNeedsUpdateLowIndexVisible) then fNeedsUpdateLowIndexVisible := Index;
      end;

      if fInWorld or (Value <> 0) then
      begin
        Misc.Miscleanous.SetBit(fNeedsUpdate, Index);
        Misc.Miscleanous.SetBit(fNeedsUpdate, IndexHigh);
        { Mark the fields as "Update-Me!" }
      end;
    end;
  end;

  if not fUpdateRequested and fInWorld then RequestUpdate;
end;

procedure YGaWowObject.SetFloat(Index: Int32; const Value: Float);
var
  IValue: UInt32 absolute Value;
begin
  { Uses the int version, treat the float value as binary data }
  SetUInt32(Index, IValue);
end;

procedure YGaWowObject.AndNotUInt8(Index: Int32; Position, Value: UInt8);
var
  lwTemp: Longword;
begin
  lwTemp := fAllFields[Index];
  LongRec(lwTemp).Bytes[Position] := LongRec(lwTemp).Bytes[Position] and not Value;
  SetUInt32(Index, lwTemp);
end;

procedure YGaWowObject.AndNotUInt16(Index: Int32; Position: UInt8; Value: UInt16);
var
  lwTemp: Longword;
begin
  lwTemp := fAllFields[Index];
  LongRec(lwTemp).Words[Position] := LongRec(lwTemp).Words[Position] and not Value;
  SetUInt32(Index, lwTemp);
end;

procedure YGaWowObject.AndNotUInt32(Index: Int32; Value: UInt32);
begin
  SetUInt32(Index, fAllFields[Index] and not Value);
end;

procedure YGaWowObject.AndNotUInt64(Index: Int32; const Value: UInt64);
var
  qwTemp: UInt64;
begin
  qwTemp := PUInt64(Int32(fAllFields) + Index * 4)^;
  SetUInt64(Index, qwTemp and not Value);
end;

procedure YGaWowObject.NotUInt8(Index: Int32; Position: UInt8);
var
  lwTemp: Longword;
begin
  lwTemp := fAllFields[Index];
  LongRec(lwTemp).Bytes[Position] := not LongRec(lwTemp).Bytes[Position];
  SetUInt32(Index, lwTemp);
end;


procedure YGaWowObject.NotUInt16(Index: Int32; Position: UInt8);
var
  lwTemp: Longword;
begin
  lwTemp := fAllFields[Index];
  LongRec(lwTemp).Words[Position] := not LongRec(lwTemp).Words[Position];
  SetUInt32(Index, lwTemp);
end;

procedure YGaWowObject.NotUInt32(Index: Int32);
begin
  SetUInt32(Index, not fAllFields[Index]);
end;

procedure YGaWowObject.NotUInt64(Index: Int32);
begin
  SetUInt64(Index, not PUInt64(Int32(fAllFields) + Index * 4)^);
end;

procedure YGaWowObject.BitCopyUpdate(Index: Int32; Value: UInt32; DestIndex,
  SrcIndex, Count: Integer);
begin
  SetUInt32(0, CopyBits(fAllFields[Index], Value, DestIndex, SrcIndex, Count));
end;

procedure YGaWowObject.AndUInt8(Index: Int32; Position, Value: UInt8);
var
  lwTemp: Longword;
begin
  lwTemp := fAllFields[Index];
  LongRec(lwTemp).Bytes[Position] := LongRec(lwTemp).Bytes[Position] and Value;
  SetUInt32(Index, lwTemp);
end;

procedure YGaWowObject.AssignUpdateDataArray(const Data: TLongWordDynArray);
var
  iInt: Int32;
begin
  for iInt := 0 to High(Data) do
  begin
    SetUInt32(iInt, Data[iInt]);
  end;
end;

procedure YGaWowObject.AndUInt16(Index: Int32; Position: UInt8; Value: UInt16);
var
  lwTemp: Longword;
begin
  lwTemp := fAllFields[Index];
  LongRec(lwTemp).Words[Position] := LongRec(lwTemp).Words[Position] and not Value;
  SetUInt32(Index, lwTemp);
end;

procedure YGaWowObject.AndUInt32(Index: Int32; Value: UInt32);
begin
  SetUInt32(Index, fAllFields[Index] and Value);
end;

procedure YGaWowObject.AndUInt64(Index: Int32; const Value: UInt64);
begin
  SetUInt64(Index, PUInt64(Int32(fAllFields) + Index * 4)^ and Value);
end;

procedure YGaWowObject.OrUInt8(Index: Int32; Position, Value: UInt8);
var
  lwTemp: Longword;
begin
  lwTemp := fAllFields[Index];
  LongRec(lwTemp).Bytes[Position] := LongRec(lwTemp).Bytes[Position] or Value;
  SetUInt32(Index, lwTemp);
end;

procedure YGaWowObject.OrUInt16(Index: Int32; Position: UInt8; Value: UInt16);
var
  lwTemp: Longword;
begin
  lwTemp := fAllFields[Index];
  LongRec(lwTemp).Words[Position] := LongRec(lwTemp).Words[Position] or Value;
  SetUInt32(Index, lwTemp);
end;

procedure YGaWowObject.OrUInt32(Index: Int32; Value: UInt32);
begin
  SetUInt32(Index, fAllFields[Index] or Value);
end;

procedure YGaWowObject.OrUInt64(Index: Int32; const Value: UInt64);
begin
  SetUInt64(Index, PUInt64(Int32(fAllFields) + Index * 4)^ or Value);
end;

procedure YGaWowObject.XorUInt8(Index: Int32; Position, Value: UInt8);
var
  lwTemp: Longword;
begin
  lwTemp := fAllFields[Index];
  LongRec(lwTemp).Bytes[Position] := LongRec(lwTemp).Bytes[Position] xor Value;
  SetUInt32(Index, lwTemp);
end;

procedure YGaWowObject.XorUInt16(Index: Int32; Position: UInt8; Value: UInt16);
var
  lwTemp: Longword;
begin
  lwTemp := fAllFields[Index];
  LongRec(lwTemp).Words[Position] := LongRec(lwTemp).Words[Position] xor Value;
  SetUInt32(Index, lwTemp);
end;

procedure YGaWowObject.XorUInt32(Index: Int32; Value: UInt32);
begin
  SetUInt32(Index, fAllFields[Index] xor Value);
end;

procedure YGaWowObject.XorUInt64(Index: Int32; const Value: UInt64);
begin
  SetUInt64(Index, PUInt64(Int32(fAllFields) + Index * 4)^ xor Value);
end;

procedure YGaWowObject.ReplaceUInt8(Index: Int32; Position, OldFlag,
  NewFlag: UInt8);
var
  lwTemp: Longword;
begin
  lwTemp := fAllFields[Index];
  LongRec(lwTemp).Bytes[Position] := (LongRec(lwTemp).Bytes[Position] and (not OldFlag)) or NewFlag;

  SetUInt32(Index, lwTemp);
end;

procedure YGaWowObject.ReplaceUInt16(Index: Int32; Position: UInt8; OldFlag,
  NewFlag: UInt16);
var
  lwTemp: Longword;
begin
  lwTemp := fAllFields[Index];
  LongRec(lwTemp).Words[Position] := (LongRec(lwTemp).Words[Position] and (not OldFlag)) or NewFlag;

  SetUInt32(Index, lwTemp);
end;

procedure YGaWowObject.ReplaceUInt32(Index: Int32; OldFlag: UInt32; NewFlag: UInt32);
begin
  SetUInt32(Index, (fAllFields[Index] and (not OldFlag)) or NewFlag);
end;

procedure YGaWowObject.ReplaceUInt64(Index: Int32; OldFlag, NewFlag: UInt64);
var
  qwTemp: UInt64;
begin
  qwTemp := PUInt64(Int32(fAllFields) + Index * 4)^;
  SetUInt64(Index, (qwTemp and (not OldFlag)) or NewFlag);
end;

procedure _BitOverflow(Arg: UInt16);
const
  BitOverflowMsgs: array[0..3] of string = (
    'Bit index overflow (%d - access) in update mask - contact developers to help fix this problem.',
    'Bit index overflow (%d - set) in update mask - contact developers to help fix this problem.',
    'Bit index overflow (%d - reset) in update mask - contact developers to help fix this problem.',
    'Bit index overflow (%d - toggle) in update mask - contact developers to help fix this problem.'
  );
var
  Position: UInt8;
  OvType: UInt8;
begin
  Position := Arg and $FF;
  OvType := (Arg shr 8) and $3;
  Assert(False, Format(BitOverflowMsgs[OvType], [Position]));
end;

function YGaWowObject.TestBit(Index: Int32; Position: UInt8): Boolean;
asm
  CMP   CL, 31
  JA    @@Overflow
  AND   ECX, $000000FF
  MOV   EAX, [EAX].YGaWowObject.fAllFields
  BT    [EAX+EDX*4], ECX
  SETC  AL
  RET
@@Overflow:
  MOV   AH, 0
  MOV   AL, CL
  JMP  _BitOverflow
end;

procedure YGaWowObject.SetBit(Index: Int32; Position: UInt8);
asm
  CMP   CL, 31
  JA    @@Overflow
  PUSH  EBX
  MOVZX EBX, CL
  MOV   ECX, [EAX].YGaWowObject.fAllFields
  MOV   ECX, [ECX+EDX*4]
  BTS   ECX, EBX
  CALL  YGaWowObject.SetUInt32
  POP   EBX
  RET
@@Overflow:
  MOV   AH, 1
  MOV   AL, CL
  JMP   _BitOverflow
end;

procedure YGaWowObject.ResetBit(Index: Int32; Position: UInt8);
asm
  CMP   CL, 31
  JA    @@Overflow
  PUSH  EBX
  MOVZX EBX, CL
  MOV   ECX, [EAX].YGaWowObject.fAllFields
  MOV   ECX, [ECX+EDX*4]
  BTR   ECX, EBX
  CALL  YGaWowObject.SetUInt32
  POP   EBX
  RET
@@Overflow:
  MOV   AH, 2
  MOV   AL, CL
  JMP  _BitOverflow
end;

procedure YGaWowObject.ToggleBit(Index: Int32; Position: UInt8);
asm
  CMP   CL, 31
  JA    @@Overflow
  PUSH  EBX
  MOVZX EBX, CL
  MOV   ECX, [EAX].YGaWowObject.fAllFields
  MOV   ECX, [ECX+EDX*4]
  BTC   ECX, EBX
  CALL  YGaWowObject.SetUInt32
  POP   EBX
  RET
@@Overflow:
  MOV   AH, 3
  MOV   AL, CL
  JMP  _BitOverflow
end;

{ YGaTimerSet }

constructor YGaTimerSet.Create;
begin
  inherited Create;

  fCapacity := 16;
  SetLength(fTimers, 16);
end;

function CompareTimerEntries(T1, T2: YTimerEntry): Int32;
begin
  Result := T1.fIdent - T2.fIdent;
end;

function MatchTimerEntry(Ident: YTimerIdent; T: YTimerEntry): Int32;
begin
  Result := Ident - T.fIdent;
end;

procedure YGaTimerSet.CreateTimer(Ident: YTimerIdent; Method: YTimedMethod;
  Delay: UInt32; Repeats: UInt32; Disabled: Boolean);
var
  cTimer: YTimerEntry;
begin
  if fCount = fCapacity then Grow;
  cTimer := YTimerEntry.Create;
  cTimer.fIdent := Ident;
  cTimer.fOwner := Self;
  cTimer.fMethod := Method;
  cTimer.fRequired := Delay;
  cTimer.fElapsed := 0;
  cTimer.fRepeats := Repeats;
  cTimer.fDisabled := Disabled;

  fTimers[fCount] := cTimer;
  Inc(fCount);
  
  SortArray(@fTimers[0], fCount, @CompareTimerEntries, shSorted);
end;

procedure YGaTimerSet.Grow;
begin
  Inc(fCapacity, fCapacity shr 1);
  SetLength(fTimers, fCapacity);
end;

destructor YGaTimerSet.Destroy;
var
  iIdx: Int32;
begin
  for iIdx := 0 to fCount -1 do
  begin
    fTimers[iIdx].Free;
  end;

  inherited Destroy;
end;

procedure YGaTimerSet.UpdateTimers(Delta: UInt32);
var
  iIdx: Int32;
  cTimer: YTimerEntry;
begin
  for iIdx := 0 to fCount -1 do
  begin
    cTimer := fTimers[iIdx];
    if cTimer.Disabled then Continue;
    Inc(cTimer.fElapsed, Delta);
    if cTimer.Elapsed >= cTimer.Required then
    begin
      if cTimer.Repeats <> $FFFFFFFF then Dec(cTimer.fRepeats);
      cTimer.fMethod(cTimer);
      if cTimer.Repeats = $FFFFFFFF then
      begin
        fTimers[iIdx] := nil;
        cTimer.Free;
      end else cTimer.Elapsed := 0;
    end;
  end;

  fCount := PackArray(@fTimers[0], fCount);
end;

procedure YGaTimerSet.DeleteTimer(Ident: YTimerIdent);
var
  cTimer: YTimerEntry;
  iIdx: Int32;
begin
  iIdx := BinarySearch(Pointer(Ident), @fTimers[0], fCount, @MatchTimerEntry);
  if iIdx <> -1 then
  begin
    cTimer := fTimers[iIdx];
    cTimer.Free;
    Dec(fCount);
    Move(fTimers[iIdx+1], fTimers[iIdx], (fCount - iIdx) * SizeOf(YTimerEntry));
  end;
end;

function YGaTimerSet.GetTimer(Ident: YTimerIdent): YTimerEntry;
var
  iIdx: Int32;
begin
  iIdx := BinarySearch(Pointer(Ident), @fTimers[0], fCount, @MatchTimerEntry);
  if iIdx <> -1 then
  begin
    Result := fTimers[iIdx];
  end else Result := nil;
end;

end.
