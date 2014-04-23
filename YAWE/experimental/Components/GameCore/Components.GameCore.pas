{*------------------------------------------------------------------------------
  Game Core Definition

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
unit Components.GameCore;

interface

uses
  Framework.Base,
  Version,
  Classes,
  Framework.Tick,
  Components.DataCore.Fields,
  Components.NetworkCore.Packet,
  Framework.SerializationRegistry,
  Components,
  Components.GameCore.Session,
  Components.GameCore.Factory,
  Components.GameCore.WowObject,
  Components.GameCore.Nodes,
  Components.GameCore.WowUnit,
  Components.GameCore.WowPlayer,
  Components.GameCore.WowItem,
  Components.GameCore.WowContainer,
  Components.GameCore.WowCreature,
  Components.GameCore.WowGameObject,
  Components.GameCore.WowMobile,
  Components.GameCore.WowDynamicObject,
  Components.GameCore.TerrainManager,
  Components.GameCore.UpdateFields,
  Components.Interfaces,
  Misc.Containers,
  SysUtils,
  Misc.Geometry,
  Components.DataCore.Storage,
  Components.Shared,
  Components.GameCore.Area,
  Components.GameCore.AreaManager,
  Components.GameCore.PacketBuilders,
  Components.GameCore.Channel,
  Components.GameCore.CommandHandler,
  Misc.Resources;

type
  YLookupResult = (lrOnline, lrOffline, lrNonExistant);

  { The mighty GameCore provides access to World and Groups }
  YGameCore = class(YBaseCore)
    private
      fSessions: THashSet;
      fNodeMgr: YGaNodeManager;
      fTerMgr: YGaTerrainManager;
      fLowGUIDs: array[YWowObjectType] of UInt32;
      fFactories: array[YWowObjectType] of YGaFactory;
      fGUIDMaps: array[YWowObjectType] of TIntHashMap;
      fReqObj: TList;
      fSubHdl: TEventHandle;
      fAreaMgrs: TIntHashMap;
      fChannels: array[Boolean] of TStrHashMap;
      fCmdHandler: YGaCommandHandlerTable;

      procedure TimedUpdate(Event: TEventHandle; TimeDelta: UInt32);

      function InternalCreateArea(iMapid: UInt32): YGaAreaManager;

      class function CheckStaticChannelName(const sName: string): Boolean; static;
      function CreateNewChannel(const sName, sPass: string; aFlags: YChannelFlags;
        cOwner: YGaPlayer; iRace: YGameRace): YGaChannel;
      function GetSessionCount: Int32;
    protected
      procedure CoreInitialize; override;  //
      procedure CoreStart; override;       // Initialization functions
      procedure CoreStop; override;        //
    public
      (*
       * Session Management Routines
       *)
      { Adds a new session to the world }
      procedure AddSession(cSession: YGaSession);
      { Removes a specified session form the world }
      procedure RemoveSession(cSession: YGaSession);
      { Count of all the sessions }
      property SessionCount: Int32 read GetSessionCount;

      (*
       * Object Control Utilities
       *)

      { Creates a new object and assigns it a GUID }
      function CreateObject(iType: YWowObjectType; bNoGUID: Boolean = False): YGaWowObject;
      { Generates a High GUID by Obj Type }
      function GenerateHighGUID(iType: YWowObjectType): UInt32;
      { Generates a Low GUID by Obj Type }
      function GenerateLowGUID(iType: YWowObjectType): UInt32;
      { A general lookup function }
      function FindObjectByGUID(iType: YWowObjectType; iGUID: UInt32; var xObj): Boolean; overload;
      function FindObjectByGUID(iGUIDHi, iGUIDLo: UInt32; var xObj): Boolean; overload;
      { A slower look up function }
      function FindPlayerByName(const sName: string; var xObj): YLookupResult;
      { A short-cut function }
      function IsPlayerOnline(const sName: string): YLookupResult;
      { Adds an object to the internal hash map }
      procedure RegisterObjectGUID(iType: YWowObjectType; cObject: YGaWowObject);
      { Removes this key from the internal hash map }
      procedure UnregisterObjectGUID(iType: YWowObjectType; iGUID: UInt32);

      procedure ObjectRequiresUpdate(cObject: YGaWowObject);

      function GetArea(iMap: UInt32; const fX, fY: Float): YGaArea;
      function GetAreaDirect(iMap, iX, iY: UInt32): YGaArea;

      procedure TryJoinChannel(cPlayer: YGaPlayer; const sChannel, sPassword: string);
      function GetChannelByName(cPlayer: YGaPlayer; const sChannel: string): YGaChannel;
      procedure LeaveChannel(cPlayer: YGaPlayer; const sChannel: string;
        bOnExit: Boolean = False);

      procedure SendPacketOnChannel(cPlayer: YGaPlayer; const sChannel: string;
        cPacket: YNwServerPacket);

      procedure BroadcastPacketAtPoint(cPkt: YNwServerPacket; iMapId: UInt32;
        const fX, fY: Float; const fRange: Float);

      procedure BroadcastPacketSetAtPoint(const PktArr: array of YNwServerPacket;
        iMapId: UInt32; const fX, fY: Float; const fRange: Float);

      procedure CheckObjectRellocation(cObject: YGaMobile; const tNewPos: TVector;
        const fAngle: Float; cPkt: YNwServerPacket);

      property NodeManager: YGaNodeManager read fNodeMgr;
      property TerrainManager: YGaTerrainManager read fTerMgr;

      property Areas[iMap, iX, iY: UInt32]: YGaArea read GetAreaDirect;
      property CommandHandler: YGaCommandHandlerTable read fCmdHandler;
    end;

implementation

uses
  Framework,
  Components.DataCore.Types,
  Cores;

type
  YObjectInitProc = procedure(cObject: YGaWowObject);

procedure InitItem(cObject: YGaWowObject);
begin
  cObject.DataMedium := DataCore.Items;
end;

procedure InitPlayer(cObject: YGaWowObject);
begin
  cObject.DataMedium := DataCore.Characters;
end;

const
  ObjectClassTable: array[YWowObjectType] of YOpenObjectClass = (
    nil,
    YGaItem,
    YGaContainer,
    YGaCreature,
    nil,
    YGaPlayer,
    YGaGameObject,
    YGaDynamicObject,
    nil,
    nil,
    nil
  );

  InitTable: array[YWowObjectType] of YObjectInitProc = (
    nil,
    InitItem,
    InitItem,
    nil,
    nil,
    InitPlayer,
    nil,
    nil,
    nil,
    nil,
    nil
  );

  FactoryNames: array[YWowObjectType] of string = (
    'Object Factory',
    'Item factory',
    'Container factory',
    'Creature factory',
    'Pathnode factory',
    'Player factory',
    'GO factory',
    'DO factory',
    'Corpse factory',
    'Player corpse factory',
    'Error'
  );

  FactoryCaps: array[YWowObjectType] of Integer = (
    0,
    50000,
    7500,
    50000,
    50000,
    1000,
    2000,
    2000,
    7500,
    4000,
    0
  );

{ YGameCore }

procedure YGameCore.CoreInitialize;
var
  iInt: YWowObjectType;
  cAreaMgr: YGaAreaManager;
  iMap: Int32;
begin
  inherited Create;
  fSessions := THashSet.Create(False, 512);
  fNodeMgr := YGaNodeManager.Create;
  fTerMgr := YGaTerrainManager.Create;

  { Setting Up GUID Tables }

  fLowGUIDs[otUnit] := 0;
  fLowGUIDs[otNode] := 0;
  fLowGUIDs[otPlayer] := DataCore.Characters.LoadMaxId;

  fLowGUIDs[otItem] := DataCore.Items.LoadMaxId;
  fLowGUIDs[otContainer] := fLowGUIDs[otItem];

  fLowGUIDs[otGameObject] := 0;
  fLowGUIDs[otCorpse] := 0;
  fLowGUIDs[otDynamicObject] := 0;
  fLowGUIDs[otPlayerCorpse] := 0;

  fGUIDMaps[otItem] := TIntHashMap.Create(1 shl 18, False);
  fGUIDMaps[otContainer] := TIntHashMap.Create(1 shl 12, False);
  fGUIDMaps[otUnit] := TIntHashMap.Create(1 shl 15, False);
  fGUIDMaps[otNode] := TIntHashMap.Create(1 shl 10, False);
  fGUIDMaps[otPlayer] := TIntHashMap.Create(1 shl 11, False);
  fGUIDMaps[otGameObject] := TIntHashMap.Create(1 shl 13, False);
  fGUIDMaps[otDynamicObject] := TIntHashMap.Create(1 shl 12, False);
  fGUIDMaps[otCorpse] := TIntHashMap.Create(1 shl 12, False);
  fGUIDMaps[otPlayerCorpse] := TIntHashMap.Create(1 shl 11, False);

  for iInt := Low(YWowObjectType) to High(YWowObjectType) do
  begin
    if ObjectClassTable[iInt] <> nil then
    begin
      fFactories[iInt] := YGaFactory.Create(
        ObjectClassTable[iInt],
        FactoryCaps[iInt],
        FactoryNames[iInt],
        Self
      );
    end;
  end;

  fReqObj := TList.Create;
  fAreaMgrs := TIntHashMap.Create(32);

  for iMap := 0 to High(ALL_MAP_IDS) do
  begin
    cAreaMgr := YGaAreaManager.Create;
    cAreaMgr.AssignMap(ALL_MAP_IDS[iMap]);
    fAreaMgrs.PutValue(ALL_MAP_IDS[iMap], cAreaMgr);
  end;

  fChannels[False] := TStrHashMap.Create(True, 2048);
  fChannels[True] := TStrHashMap.Create(True, 2048);

  fCmdHandler := YGaCommandHandlerTable.Create;
  InitializePlayerCommandHandlers;

  fSubHdl := SystemTimer.RegisterEvent(TimedUpdate, GROUPS_UPD_INTERVAL,
    TICK_EXECUTE_INFINITE, 'GameCore_MainUpdater_Event');
end;

procedure YGameCore.CoreStart;
begin
end;

procedure YGameCore.CoreStop;
var
  iX: YWowObjectType;
begin
  fSubHdl.Unregister;
  fNodeMgr.SaveToDatabase;

  fSessions.Free;
  fReqObj.Free;
  fChannels[False].Free;
  fChannels[True].Free;
  fAreaMgrs.Free;
  fNodeMgr.Free;
  fTerMgr.Free;
  fCmdHandler.Free;

  for iX := Low(YWowObjectType) to High(YWowObjectType) do
  begin
    fGUIDMaps[iX].Free;
    fFactories[iX].Free;
  end;

  inherited Destroy;
end;

procedure YGameCore.AddSession(cSession: YGaSession);
begin
  { Registers a session into the World }
  fSessions.Add(cSession);
end;

function YGameCore.CreateObject(iType: YWowObjectType; bNoGUID: Boolean): YGaWowObject;
var
  pClassPtr: YOpenObjectClass;
  pInitProc: YObjectInitProc;
begin
  pClassPtr := ObjectClassTable[iType];
  if pClassPtr <> nil then
  begin
    if fFactories[iType] <> nil then
    begin
      Result := fFactories[iType].Assemble;
      pInitProc := InitTable[iType];
      if Assigned(pInitProc) then pInitProc(Result);
    end else Result := nil;
  end else Result := nil;

  if not Assigned(Result) then { Check if the object was created successfully }
  begin
    raise Exception.Create('Invalid object type supplied!');
  end;

  Result.GUIDHi := GenerateHighGUID(iType);
  if not bNoGUID then
  begin
    Result.GUIDLo := GenerateLowGUID(iType);
    fGUIDMaps[iType].PutValue(Result.GUIDLo, Result);
  end;
end;

function YGameCore.FindObjectByGUID(iType: YWowObjectType; iGUID: UInt32; var xObj): Boolean;
begin
  TObject(xObj) := fGUIDMaps[iType].GetValue(iGUID);
  Result := Pointer(xObj) <> nil; 
end;

function YGameCore.FindObjectByGUID(iGUIDHi, iGUIDLo: UInt32;
  var xObj): Boolean;
var
  iType: YWowObjectType;
begin
  case iGUIDHi of
    $00000000: iType := otPlayer;
    $00000002: iType := otUnit;
    $00000004: iType := otItem;
    $00000008: iType := otContainer;
    $00000010: iType := otNode;
    $00000020: iType := otGameobject;
    $00000040: iType := otDynamicObject;
    $00000080: iType := otCorpse;
    $00000100: iType := otPlayercorpse;
  else
    iType := otObject;
  end;
  Result := FindObjectByGUID(iType, iGUIDLo, xObj);
end;

function YGameCore.FindPlayerByName(const sName: string; var xObj): YLookupResult;
var
  cPlr: YDbPlayerEntry;
begin
  DataCore.Characters.LoadEntry(FIELD_PLI_CHAR_NAME, sName, cPlr);
  if cPlr = nil then
  begin
    Result := lrNonExistant;
  end else if FindObjectByGUID(otPlayer, cPlr.UniqueID, xObj) then
  begin
    Result := lrOnline;
  end else
  begin
    Result := lrOffline;
  end;
  DataCore.Characters.ReleaseEntry(cPlr);
end;

function YGameCore.IsPlayerOnline(const sName: string): YLookupResult;
var
  cPlr: YDbPlayerEntry;
  cPlayer: YGaPlayer;
begin
  DataCore.Characters.LoadEntry(FIELD_PLI_CHAR_NAME, sName, cPlr);
  if cPlr = nil then
  begin
    Result := lrNonExistant;
  end else if FindObjectByGUID(otPlayer, cPlr.UniqueID, cPlayer) then
  begin
    Result := lrOnline;
  end else
  begin
    Result := lrOffline;
  end;
  DataCore.Characters.ReleaseEntry(cPlr);
end;

function YGameCore.GenerateHighGUID(iType: YWowObjectType): UInt32;
const
  HighGuidTable: array[YWowObjectType] of Longword = (
    $00000001, { OPENOBJECT_OBJECT }
    $00000004, { OPENOBJECT_ITEM }
    $00000008, { OPENOBJECT_CONTAINER }
    $00000002, { OPENOBJECT_UNIT }
    $00000010, { OPENOBJECT_PATHNODE }
    $00000000, { OPENOBJECT_PLAYER }
    $00000020, { OPENOBJECT_GAMEOBJECT }
    $00000040, { OPENOBJECT_DYNOBJECT }
    $00000080, { OPENOBJECT_CORPSE }
    $00000100, { OPENOBJECT_PLAYERCORPSE }
    $80000000  { OPENOBJECT_ERROR }
  );
begin
  Result := HighGuidTable[iType];
end;

function YGameCore.GenerateLowGUID(iType: YWowObjectType): UInt32;
begin
  Inc(fLowGUIDs[iType]);
  Result := fLowGUIDs[iType];
end;

function YGameCore.GetSessionCount: Int32;
begin
  Result := fSessions.Size;
end;

procedure YGameCore.RegisterObjectGUID(iType: YWowObjectType; cObject: YGaWowObject);
begin
  fGUIDMaps[iType].PutValue(cObject.GUIDLo, cObject);
  cObject.MarkUpdatesSatisfied;
end;

procedure YGameCore.RemoveSession(cSession: YGaSession);
begin
  fSessions.Remove(cSession);
end;

procedure YGameCore.UnregisterObjectGUID(iType: YWowObjectType; iGUID: UInt32);
var
  cObj: YGaWowObject;
begin
  cObj := YGaWowObject(fGUIDMaps[iType].Remove(iGUID));
  if (cObj <> nil) and cObj.UpdatesPending then
  begin
    fReqObj.Remove(cObj);
  end;
end;

procedure YGameCore.CheckObjectRellocation(cObject: YGaMobile;
  const tNewPos: TVector; const fAngle: Float; cPkt: YNwServerPacket);
var
  cAreaMgr: YGaAreaManager;
  cArea: YGaArea;
label
  __Proceed;
begin
  cAreaMgr := YGaAreaManager(fAreaMgrs.GetValue(cObject.Position.MapId));
  if cAreaMgr <> nil then
  begin
    __Proceed:
    cArea := cAreaMgr.CheckObjectRellocation(cObject, tNewPos, fAngle, cPkt);
    if cArea <> nil then
    begin
      cObject.Position.AreaX := cArea.X;
      cObject.Position.AreaY := cArea.Y;
    end;
  end else
  begin
    cAreaMgr := InternalCreateArea(cObject.Position.MapId);
    goto __Proceed;
  end;
end;

class function YGameCore.CheckStaticChannelName(const sName: string): Boolean;
var
  iInt: Int32;
  sTmp: string;
begin
  sTmp := UpperCase(sName);
  for iInt := 0 to 4 do
  begin
    if Pos(STATIC_CHANNELS[iInt], sTmp) <> 0 then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

function YGameCore.CreateNewChannel(const sName, sPass: string;
  aFlags: YChannelFlags; cOwner: YGaPlayer; iRace: YGameRace): YGaChannel;
begin
  if not CheckStaticChannelName(sName) then
  begin
    Result := YGaChannel.Create;
    Result.SetChannelData(sName, sPass, aFlags, cOwner);
  end else
  begin
    Result := YGaChannel.Create;
    Result.SetChannelData(sName, '', [cfStatic], nil);
  end;
  fChannels[IsHorde(iRace)].PutValue(sName, Result);
end;

function YGameCore.GetArea(iMap: UInt32; const fX, fY: Float): YGaArea;
var
  cAreaMgr: YGaAreaManager;
label
  __Proceed;
begin
  cAreaMgr := YGaAreaManager(fAreaMgrs.GetValue(iMap));
  if cAreaMgr <> nil then
  begin
    __Proceed:
    Result := cAreaMgr.CoordinatesToArea(fX, fY);
  end else
  begin
    cAreaMgr := InternalCreateArea(iMap);
    goto __Proceed;
  end;
end;

function YGameCore.GetAreaDirect(iMap, iX, iY: UInt32): YGaArea;
var
  cAreaMgr: YGaAreaManager;
label
  __Proceed;
begin
  cAreaMgr := YGaAreaManager(fAreaMgrs.GetValue(iMap));
  if cAreaMgr <> nil then
  begin
    __Proceed:
    Result := cAreaMgr.Areas[iX, iY];
  end else
  begin
    cAreaMgr := InternalCreateArea(iMap);
    goto __Proceed;
  end;
end;

function YGameCore.GetChannelByName(cPlayer: YGaPlayer; const sChannel: string): YGaChannel;
begin
  Result := YGaChannel(fChannels[IsHorde(cPlayer.Stats.Race)].GetValue(sChannel));
end;

function YGameCore.InternalCreateArea(iMapid: UInt32): YGaAreaManager;
begin
  Result := YGaAreaManager.Create;
  Result.AssignMap(iMapId);
  fAreaMgrs.PutValue(iMapid, Result);
end;

procedure YGameCore.LeaveChannel(cPlayer: YGaPlayer; const sChannel: string;
  bOnExit: Boolean);
var
  cChannel: YGaChannel;
  bBool: Boolean;
begin
  bBool := IsHorde(cPlayer.Stats.Race);
  cChannel := YGaChannel(fChannels[bBool].GetValue(sChannel));
  if cChannel <> nil then
  begin
    if cChannel.Leave(cPlayer, bOnExit) then
    begin
      if not bOnExit then cPlayer.Channels.Remove(cChannel.Name);
      if not cChannel.IsStatic and (cChannel.ListenerCount = 0) then
      begin
        fChannels[bBool].Remove(sChannel);
      end;
    end;
  end else if not bOnExit then cPlayer.Chat.SystemMessage('Specified channel does not exist.');
end;

procedure YGameCore.BroadcastPacketAtPoint(cPkt: YNwServerPacket; iMapId: UInt32;
  const fX, fY: Float; const fRange: Float);
var
  fZ: Float;
  cArea: YGaArea;
  tVec: TVector;
  tAreas: YAreaEnum;
  cPlayer: YGaPlayer;
  iI, iJ: Int32;
  fRangeSq: Float;
begin
  fRangeSq := fRange * fRange;

  if not fTerMgr.QueryHeightAt(iMapId, fX, fY, fZ) then
  begin
    fZ := 65.0; { This is NOT correct, but oh well. :) It's the average height of the world. }
  end;

  MakeVector(tVec, fX, fY, fZ);
  cArea := YGaAreaManager(fAreaMgrs[iMapId]).CoordinatesToArea(fX, fY);
  Assert(cArea <> nil);

  cArea.EnumNeighbouringAreas(fX, fY, tAreas);
  for iI := 0 to tAreas.Count- 1 do
  begin
    for iJ := 0 to tAreas.Areas[iI].PlayerCount -1 do
    begin
      cPlayer := tAreas.Areas[iI].Players[iJ];
      if VectorDistanceSq(tVec, cPlayer.Position.Vector) <= fRangeSq then
      begin
        tAreas.Areas[iI].Players[iJ].Session.SendPacket(cPkt);
      end;
    end;
  end;
end;

procedure YGameCore.BroadcastPacketSetAtPoint(const PktArr: array of YNwServerPacket;
  iMapId: UInt32; const fX, fY, fRange: Float);
var
  fZ: Float;
  cArea: YGaArea;
  tVec: TVector;
  tAreas: YAreaEnum;
  cPlayer: YGaPlayer;
  iI, iJ, iK: Int32;
  fRangeSq: Float;
begin
  fRangeSq := fRange * fRange;

  if not fTerMgr.QueryHeightAt(iMapId, fX, fY, fZ) then
  begin
    fZ := 65.0; { This is NOT correct, but oh well. :) It's the average height of the world. }
  end;

  MakeVector(tVec, fX, fY, fZ);
  cArea := YGaAreaManager(fAreaMgrs[iMapId]).CoordinatesToArea(fX, fY);
  Assert(cArea <> nil);

  cArea.EnumNeighbouringAreas(fX, fY, tAreas);

  for iI := 0 to tAreas.Count- 1 do
  begin
    for iJ := 0 to tAreas.Areas[iI].PlayerCount -1 do
    begin
      cPlayer := tAreas.Areas[iI].Players[iJ];
      if VectorDistanceSq(tVec, cPlayer.Position.Vector) <= fRangeSq then
      begin
        for iK := 0 to High(PktArr) do
        begin
          tAreas.Areas[iI].Players[iJ].Session.SendPacket(PktArr[iK]);
        end;
      end;
    end;
  end;
end;

procedure YGameCore.ObjectRequiresUpdate(cObject: YGaWowObject);
begin
  IoCore.Console.WriteUpdateReq(cObject);
  fReqObj.Add(cObject);
end;

procedure YGameCore.SendPacketOnChannel(cPlayer: YGaPlayer;
  const sChannel: string; cPacket: YNwServerPacket);
var
  cChannel: YGaChannel;
begin
  try
    cChannel := YGaChannel(fChannels[IsHorde(cPlayer.Stats.Race)].GetValue(sChannel));
    if cChannel <> nil then
    begin
      cChannel.DispatchPacketToAll(cPacket);
    end;
  finally
    cPacket.Free;
  end;
end;

procedure YGameCore.TimedUpdate(Event: TEventHandle; TimeDelta: UInt32);
var
  iX: Int32;
  cObj: YGaWowObject;
begin
  { Executes to get the proper updates and distribute to the players }
  { Circulate all objects that requested updating }
  for iX := 0 to fReqObj.Count - 1 do
  begin
    cObj := fReqObj.Items[iX];
    cObj.OnValuesUpdate;
    cObj.MarkUpdatesSatisfied;
  end;

  fReqObj.Clear;
end;

procedure YGameCore.TryJoinChannel(cPlayer: YGaPlayer; const sChannel,
  sPassword: string);
var
  cChannel: YGaChannel;
begin
  cChannel := GetChannelByName(cPlayer, sChannel);
  if cChannel = nil then
  begin
    cChannel := CreateNewChannel(sChannel, sPassword, [cfAnnounce], cPlayer,
      cPlayer.Stats.Race);
  end;
  if cChannel.Join(cPlayer, sPassword) then
  begin
    cPlayer.Channels.Add(cChannel.Name);
  end;
end;

end.
