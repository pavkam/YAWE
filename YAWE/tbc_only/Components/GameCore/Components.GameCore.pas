{*------------------------------------------------------------------------------
  Game Core Definition

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
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
  SysUtils,
  Classes,
  Framework.Tick,
  Components.NetworkCore.Packet,
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
  Components.GameCore.Constants,
  Components.GameCore.Types,
  Components.GameCore.WowDynamicObject,
  Components.GameCore.TerrainManager,
  Components.GameCore.UpdateFields,
  Components.Interfaces,
  Bfg.Containers,
  Bfg.Unicode,
  Bfg.Geometry,
  Components.Shared,
  Components.GameCore.Area,
  Components.GameCore.AreaManager,
  Components.GameCore.PacketBuilders,
  Components.GameCore.Channel,
  Components.GameCore.CommandHandler,
  Bfg.Resources;

type
  YLookupResult = (lrOnline, lrOffline, lrNonExistant);

  { The mighty GameCore provides access to World and Groups }
  YGameCore = class(YBaseCore)
    private
      FSessions: THashSet;
      FNodeMgr: YGaNodeManager;
      FTerMgr: YGaTerrainManager;
      FLowGUIDs: array[YWowObjectType] of UInt32;
      FFactories: array[YWowObjectType] of YGaFactory;
      FGUIDMaps: array[YWowObjectType] of TIntHashMap;
      FReqObj: TList;
      FSubHdl: TEventHandle;
      FAreaMgrs: TIntHashMap;
      FChannels: array[Boolean] of TStrHashMap;
      FCmdHandler: YGaCommandHandlerTable;
      FPlayerNameCache: TStrHashMap;

      procedure TimedUpdate(Event: TEventHandle; TimeDelta: UInt32);

      function InternalCreateArea(MapId: UInt32): YGaAreaManager;

      class function CheckStaticChannelName(const ChanName: WideString): Boolean; static;
      function CreateNewChannel(const ChanName, ChanPass: WideString; Flags: YChannelFlags;
        Owner: YGaPlayer; Race: YGameRace): YGaChannel;
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
      procedure AddSession(Session: YGaSession);
      { Removes a specified session form the world }
      procedure RemoveSession(Session: YGaSession);
      { Count of all the sessions }
      property SessionCount: Int32 read GetSessionCount;

      (*
       * Object Control Utilities
       *)

      procedure CreateObject(ObjectType: YWowObjectType; out Obj; NoGUID: Boolean = False);
      function GenerateHighGUID(ObjectType: YWowObjectType): UInt32;
      function GenerateLowGUID(ObjectType: YWowObjectType): UInt32;
      function FindObjectByGUID(ObjectType: YWowObjectType; GUIDLo: UInt32; var Obj): Boolean; overload;
      function FindObjectByGUID(GUIDHi, GUIDLo: UInt32; var Obj): Boolean; overload;
      function FindPlayerByName(const PlayerName: WideString; var Obj): YLookupResult;
      function IsPlayerOnline(const PlayerName: WideString): YLookupResult;
      procedure RegisterObjectGUID(ObjectType: YWowObjectType; Obj: YGaWowObject);
      procedure UnregisterObjectGUID(ObjectType: YWowObjectType; GUIDLo: UInt32);

      procedure ObjectRequiresUpdate(Obj: YGaWowObject);

      function GetArea(MapId: UInt32; const X, Y: Float): YGaArea;
      function GetAreaDirect(MapId, X, Y: UInt32): YGaArea;

      procedure TryJoinChannel(Player: YGaPlayer; const ChannelName, ChannelPassword: WideString);
      function GetChannelByName(Player: YGaPlayer; const ChannelName: WideString): YGaChannel;
      procedure LeaveChannel(Player: YGaPlayer; const ChannelName: WideString;
        OnExit: Boolean = False);

      procedure SendPacketOnChannel(Player: YGaPlayer; const ChannelName: WideString;
        Packet: YNwServerPacket);

      procedure BroadcastPacketAtPoint(Pkt: YNwServerPacket; MapId: UInt32;
        const X, Y: Float; const Range: Float);

      procedure BroadcastPacketSetAtPoint(const PktArr: array of YNwServerPacket;
        MapId: UInt32; const X, Y: Float; const Range: Float);

      procedure CheckObjectRellocation(Obj: YGaMobile; const NewPos: TVector;
        const Angle: Float; Pkt: YNwServerPacket);

      property NodeManager: YGaNodeManager read FNodeMgr;
      property TerrainManager: YGaTerrainManager read FTerMgr;

      property Areas[MapId, X, Y: UInt32]: YGaArea read GetAreaDirect;
      property CommandHandler: YGaCommandHandlerTable read FCmdHandler;

      function CreateNewItem(iEntry: UInt32; cOwner: YGaPlayer; cContained: YGaContainer): YGaItem;

    end;

implementation

uses
  Framework,
  Components.DataCore,
  Components.DataCore.Types,
  Cores;

type
  YObjectInitProc = procedure(Obj: YGaWowObject);

procedure InitItem(Obj: YGaWowObject);
begin
  Obj.DataMedium := DataCore.Items;
end;

procedure InitPlayer(Obj: YGaWowObject);
begin
  Obj.DataMedium := DataCore.Players;
end;

const
  ObjectClassTable: array[YWowObjectType] of YWowObjectClass = (
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
  ObjType: YWowObjectType;
  AreaMgr: YGaAreaManager;
  MapId: UInt32;
begin
  inherited Create;
  FSessions := THashSet.Create(False, 512);
  FNodeMgr := YGaNodeManager.Create;
  FTerMgr := YGaTerrainManager.Create;
  FPlayerNameCache := TStrHashMap.Create(False, 1024, False);

  { Setting Up GUID Tables }

  FLowGUIDs[otUnit] := 0;
  FLowGUIDs[otNode] := 0;
  FLowGUIDs[otPlayer] := DataCore.Players.EntryCount;

  FLowGUIDs[otItem] := DataCore.Items.EntryCount;
  FLowGUIDs[otContainer] := FLowGUIDs[otItem];

  FLowGUIDs[otGameObject] := 0;
  FLowGUIDs[otCorpse] := 0;
  FLowGUIDs[otDynamicObject] := 0;
  FLowGUIDs[otPlayerCorpse] := 0;

  FGUIDMaps[otItem] := TIntHashMap.Create(1 shl 18, False);
  FGUIDMaps[otContainer] := TIntHashMap.Create(1 shl 12, False);
  FGUIDMaps[otUnit] := TIntHashMap.Create(1 shl 15, False);
  FGUIDMaps[otNode] := TIntHashMap.Create(1 shl 10, False);
  FGUIDMaps[otPlayer] := TIntHashMap.Create(1 shl 11, False);
  FGUIDMaps[otGameObject] := TIntHashMap.Create(1 shl 13, False);
  FGUIDMaps[otDynamicObject] := TIntHashMap.Create(1 shl 12, False);
  FGUIDMaps[otCorpse] := TIntHashMap.Create(1 shl 12, False);
  FGUIDMaps[otPlayerCorpse] := TIntHashMap.Create(1 shl 11, False);

  for ObjType := Low(YWowObjectType) to High(YWowObjectType) do
  begin
    if ObjectClassTable[ObjType] <> nil then
    begin
      FFactories[ObjType] := YGaFactory.Create(
        ObjectClassTable[ObjType],
        FactoryCaps[ObjType],
        FactoryNames[ObjType],
        Self
      );
    end;
  end;

  FReqObj := TList.Create;
  FAreaMgrs := TIntHashMap.Create(32);

  for MapId := 0 to High(ALL_MAP_IDS) do
  begin
    AreaMgr := YGaAreaManager.Create;
    AreaMgr.AssignMap(ALL_MAP_IDS[MapId]);
    FAreaMgrs.PutValue(ALL_MAP_IDS[MapId], AreaMgr);
  end;

  FChannels[False] := TStrHashMap.Create(True, 2048);
  FChannels[True] := TStrHashMap.Create(True, 2048);

  FCmdHandler := YGaCommandHandlerTable.Create;

  YGaChatCommands.Initialize;

  FSubHdl := SysEventMgr.RegisterEvent(TimedUpdate, GROUPS_UPD_INTERVAL,
    TICK_EXECUTE_INFINITE, 'GameCore_MainUpdater_Event');
end;

procedure YGameCore.CoreStart;
begin
end;

procedure YGameCore.CoreStop;
var
  ObjType: YWowObjectType;
begin
  FSubHdl.Unregister;
  FNodeMgr.SaveToDatabase;

  FSessions.Free;
  FReqObj.Free;
  FChannels[False].Free;
  FChannels[True].Free;
  FAreaMgrs.Free;
  FNodeMgr.Free;
  FTerMgr.Free;
  FCmdHandler.Free;

  for ObjType := Low(YWowObjectType) to High(YWowObjectType) do
  begin
    FGUIDMaps[ObjType].Free;
    FFactories[ObjType].Free;
  end;

  FPlayerNameCache.Free;

  inherited Destroy;
end;

procedure YGameCore.AddSession(Session: YGaSession);
begin
  { Registers a session into the World }
  FSessions.Add(Session);
end;

procedure YGameCore.CreateObject(ObjectType: YWowObjectType; out Obj; NoGUID: Boolean);
var
  WowObj: YGaWowObject absolute Obj;
  ClassPtr: YWowObjectClass;
  InitProc: YObjectInitProc;
begin
  ClassPtr := ObjectClassTable[ObjectType];
  if ClassPtr <> nil then
  begin
    if FFactories[ObjectType] <> nil then
    begin
      WowObj := FFactories[ObjectType].Assemble;
      InitProc := InitTable[ObjectType];
      if Assigned(InitProc) then InitProc(WowObj);
    end else WowObj := nil;
  end else WowObj := nil;

  if not Assigned(WowObj) then { Check if the object was created successfully }
  begin
    raise Exception.Create('Invalid object type supplied!');
  end;

  WowObj.GUIDHi := GenerateHighGUID(ObjectType);
  if not NoGUID then
  begin
    WowObj.GUIDLo := GenerateLowGUID(ObjectType);
    FGUIDMaps[ObjectType].PutValue(WowObj.GUIDLo, WowObj);
  end;
end;

function YGameCore.FindObjectByGUID(ObjectType: YWowObjectType; GUIDLo: UInt32; var Obj): Boolean;
begin
  TObject(Obj) := FGUIDMaps[ObjectType].GetValue(GUIDLo);
  Result := Pointer(Obj) <> nil; 
end;

function YGameCore.FindObjectByGUID(GUIDHi, GUIDLo: UInt32;
  var Obj): Boolean;
var
  ObjType: YWowObjectType;
begin
  case GUIDHi of
    $00000000: ObjType := otPlayer;
    $00000002: ObjType := otUnit;
    $00000004: ObjType := otItem;
    $00000008: ObjType := otContainer;
    $00000010: ObjType := otNode;
    $00000020: ObjType := otGameobject;
    $00000040: ObjType := otDynamicObject;
    $00000080: ObjType := otCorpse;
    $00000100: ObjType := otPlayercorpse;
  else
    ObjType := otObject;
  end;
  Result := FindObjectByGUID(ObjType, GUIDLo, Obj);
end;

function YGameCore.FindPlayerByName(const PlayerName: WideString; var Obj): YLookupResult;
var
  Plr: IPlayerEntry;
  LookupRes: ILookupResult;
begin
  Pointer(Obj) := FPlayerNameCache.GetValue(PlayerName);
  if Pointer(Obj) <> nil then
  begin
    Result := lrOnline;
    Exit;
  end;

  DataCore.Players.LookupEntryListW('Name', PlayerName, False, LookupRes);
  Result := lrNonExistant;
  if Assigned(LookupRes) and (LookupRes.GetData(Plr, 1) <> 0) then
  begin
    try
      if FindObjectByGUID(otPlayer, Plr.UniqueId, Obj) then
      begin
        Result := lrOnline;
      end else
      begin
        Result := lrOffline;
      end;
    finally
      DataCore.Players.ReleaseEntry(Plr);
    end;
  end;
end;

function YGameCore.IsPlayerOnline(const PlayerName: WideString): YLookupResult;
var
  Plr: IPlayerEntry;
  Player: YGaPlayer;
  LookupRes: ILookupResult;
begin
  Player := YGaPlayer(FPlayerNameCache.GetValue(PlayerName));
  if Player <> nil then
  begin
    Result := lrOnline;
    Exit;
  end;

  DataCore.Players.LookupEntryListW('Name', PlayerName, False, LookupRes);
  Result := lrNonExistant;
  if Assigned(LookupRes) and (LookupRes.GetData(Plr, 1) <> 0) then
  begin
    try
      if FindObjectByGUID(otPlayer, Plr.UniqueId, Player) then
      begin
        Result := lrOnline;
      end else
      begin
        Result := lrOffline;
      end;
    finally
      DataCore.Players.ReleaseEntry(Plr);
    end;
  end;
end;

function YGameCore.GenerateHighGUID(ObjectType: YWowObjectType): UInt32;
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
  Result := HighGuidTable[ObjectType];
end;

function YGameCore.GenerateLowGUID(ObjectType: YWowObjectType): UInt32;
begin
  Inc(FLowGUIDs[ObjectType]);
  Result := FLowGUIDs[ObjectType];
end;

function YGameCore.GetSessionCount: Int32;
begin
  Result := FSessions.Size;
end;

procedure YGameCore.RegisterObjectGUID(ObjectType: YWowObjectType; Obj: YGaWowObject);
begin
  FGUIDMaps[ObjectType].PutValue(Obj.GUIDLo, Obj);
  Obj.MarkUpdatesSatisfied;
end;

procedure YGameCore.RemoveSession(Session: YGaSession);
begin
  FSessions.Remove(Session);
end;

procedure YGameCore.UnregisterObjectGUID(ObjectType: YWowObjectType; GUIDLo: UInt32);
var
  Obj: YGaWowObject;
begin
  Obj := YGaWowObject(FGUIDMaps[ObjectType].Remove(GUIDLo));
  if (Obj <> nil) and Obj.UpdatesPending then
  begin
    FReqObj.Remove(Obj);
  end;
end;

procedure YGameCore.CheckObjectRellocation(Obj: YGaMobile;
  const NewPos: TVector; const Angle: Float; Pkt: YNwServerPacket);
var
  AreaMgr: YGaAreaManager;
  Area: YGaArea;
label
  __Proceed;
begin
  AreaMgr := YGaAreaManager(FAreaMgrs.GetValue(Obj.MapId));
  if AreaMgr <> nil then
  begin
    __Proceed:
    Area := AreaMgr.CheckObjectRellocation(Obj, NewPos, Angle, Pkt);
    if Area <> nil then
    begin
      Obj.AreaX := Area.X;
      Obj.AreaY := Area.Y;
    end;
  end else
  begin
    AreaMgr := InternalCreateArea(Obj.MapId);
    goto __Proceed;
  end;
end;

class function YGameCore.CheckStaticChannelName(const ChanName: WideString): Boolean;
var
  I: Integer;
  Tmp: WideString;
begin
  Tmp := UpperCase(ChanName);
  for I := 0 to 4 do
  begin
    if WidePos(STATIC_CHANNELS[I], Tmp) <> 0 then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

function YGameCore.CreateNewChannel(const ChanName, ChanPass: WideString;
  Flags: YChannelFlags; Owner: YGaPlayer; Race: YGameRace): YGaChannel;
begin
  if not CheckStaticChannelName(ChanName) then
  begin
    Result := YGaChannel.Create;
    Result.SetChannelData(ChanName, ChanPass, Flags, Owner);
  end else
  begin
    Result := YGaChannel.Create;
    Result.SetChannelData(ChanName, '', [cfStatic], nil);
  end;
  FChannels[IsHorde(Race)].PutValue(ChanName, Result);
end;

function YGameCore.GetArea(MapId: UInt32; const X, Y: Float): YGaArea;
var
  AreaMgr: YGaAreaManager;
label
  __Proceed;
begin
  AreaMgr := YGaAreaManager(FAreaMgrs.GetValue(MapId));
  if AreaMgr <> nil then
  begin
    __Proceed:
    Result := AreaMgr.CoordinatesToArea(X, Y);
  end else
  begin
    AreaMgr := InternalCreateArea(MapId);
    goto __Proceed;
  end;
end;

function YGameCore.GetAreaDirect(MapId, X, Y: UInt32): YGaArea;
var
  AreaMgr: YGaAreaManager;
label
  __Proceed;
begin
  AreaMgr := YGaAreaManager(FAreaMgrs.GetValue(MapId));
  if AreaMgr <> nil then
  begin
    __Proceed:
    Result := AreaMgr.Areas[X, Y];
  end else
  begin
    AreaMgr := InternalCreateArea(MapId);
    goto __Proceed;
  end;
end;

function YGameCore.GetChannelByName(Player: YGaPlayer; const ChannelName: WideString): YGaChannel;
begin
  Result := YGaChannel(FChannels[IsHorde(Player.Stats.Race)].GetValue(ChannelName));
end;

function YGameCore.InternalCreateArea(MapId: UInt32): YGaAreaManager;
begin
  Result := YGaAreaManager.Create;
  Result.AssignMap(MapId);
  FAreaMgrs.PutValue(MapId, Result);
end;

procedure YGameCore.LeaveChannel(Player: YGaPlayer; const ChannelName: WideString;
  OnExit: Boolean);
var
  Channel: YGaChannel;
  Faction: Boolean;
begin
{
  Faction := IsHorde(Player.Stats.Race);
  Channel := YGaChannel(FChannels[Faction].GetValue(ChannelName));
  if Channel <> nil then
  begin
    if Channel.Leave(Player, OnExit) then
    begin
      if not OnExit then Player.Channels.Remove(Channel.Name);
      if not Channel.IsStatic and (Channel.ListenerCount = 0) then
      begin
        FChannels[Faction].Remove(ChannelName);
      end;
    end;
  end else if not OnExit then Player.Chat.SystemMessage('Specified channel does not exist.');
  }
  end;

procedure YGameCore.BroadcastPacketAtPoint(Pkt: YNwServerPacket; MapId: UInt32;
  const X, Y: Float; const Range: Float);
var
  Z: Float;
  Area: YGaArea;
  Vec: TVector;
  Areas: YAreaEnum;
  Player: YGaPlayer;
  I, J: Integer;
  RangeSq: Float;
begin
  RangeSq := Range * Range;

  if not FTerMgr.QueryHeightAt(MapId, X, Y, Z) then
  begin
    Z := 65.0; { This is NOT correct, but oh well. :) It's the average height of the world. }
  end;

  MakeVector(Vec, X, Y, Z);
  Area := YGaAreaManager(FAreaMgrs[MapId]).CoordinatesToArea(X, Y);
  Assert(Area <> nil);

  Area.EnumNeighbouringAreas(X, Y, Areas);
  for I := 0 to Areas.Count- 1 do
  begin
    for J := 0 to Areas.Areas[I].PlayerCount -1 do
    begin
      Player := Areas.Areas[I].Players[J];
      if VectorDistanceSq(Vec, Player.Vector) <= RangeSq then
      begin
        Areas.Areas[I].Players[J].Session.SendPacket(Pkt);
      end;
    end;
  end;
end;

procedure YGameCore.BroadcastPacketSetAtPoint(const PktArr: array of YNwServerPacket;
  MapId: UInt32; const X, Y, Range: Float);
var
  Z: Float;
  Area: YGaArea;
  Vec: TVector;
  Areas: YAreaEnum;
  Player: YGaPlayer;
  I, J, K: Integer;
  RangeSq: Float;
begin
  RangeSq := Range * Range;

  if not FTerMgr.QueryHeightAt(MapId, X, Y, Z) then
  begin
    Z := 65.0; { This is NOT correct, but oh well. :) It's the average height of the world. }
  end;

  MakeVector(Vec, X, Y, Z);
  Area := YGaAreaManager(FAreaMgrs[MapId]).CoordinatesToArea(X, Y);
  Assert(Area <> nil);

  Area.EnumNeighbouringAreas(X, Y, Areas);

  for I := 0 to Areas.Count- 1 do
  begin
    for J := 0 to Areas.Areas[I].PlayerCount -1 do
    begin
      Player := Areas.Areas[I].Players[J];
      if VectorDistanceSq(Vec, Player.Vector) <= RangeSq then
      begin
        for K := 0 to High(PktArr) do
        begin
          Areas.Areas[I].Players[J].Session.SendPacket(PktArr[K]);
        end;
      end;
    end;
  end;
end;

procedure YGameCore.ObjectRequiresUpdate(Obj: YGaWowObject);
begin
  IoCore.Console.WriteUpdateReq(Obj);
  FReqObj.Add(Obj);
end;

procedure YGameCore.SendPacketOnChannel(Player: YGaPlayer;
  const ChannelName: WideString; Packet: YNwServerPacket);
var
  Channel: YGaChannel;
begin
  try
    Channel := YGaChannel(FChannels[IsHorde(Player.Stats.Race)].GetValue(ChannelName));
    if Channel <> nil then
    begin
      Channel.DispatchPacketToAll(Packet);
    end;
  finally
    Packet.Free;
  end;
end;

procedure YGameCore.TimedUpdate(Event: TEventHandle; TimeDelta: UInt32);
var
  I: Int32;
  Obj: YGaWowObject;
begin
  { Executes to get the proper updates and distribute to the players }
  { Circulate all objects that requested updating }
  for I := 0 to FReqObj.Count - 1 do
  begin
    Obj := FReqObj.Items[I];
    Obj.OnValuesUpdate;
    Obj.MarkUpdatesSatisfied;
  end;

  FReqObj.Clear;
end;

procedure YGameCore.TryJoinChannel(Player: YGaPlayer; const ChannelName,
  ChannelPassword: WideString);
var
  Channel: YGaChannel;
begin
  Channel := GetChannelByName(Player, ChannelName);
  if Channel = nil then
  begin
    Channel := CreateNewChannel(ChannelName, ChannelPassword, [cfAnnounce], Player,
      Player.Stats.Race);
  end;
  if Channel.Join(Player, ChannelPassword) then
  begin
    Player.Channels.Add(Channel.Name);
  end;
end;

function YGameCore.CreateNewItem(iEntry: UInt32; cOwner: YGaPlayer; cContained: YGaContainer): YGaItem;
var
  cTemp: YDbItemTemplate;
begin
  /// loading item from database
  //DataCore.ItemTemplates.LoadEntry(iEntry, cTemp);

  /// if we were successfull in loading this item from database then
  if cTemp <> nil then
  begin
    /// if the item's InventoryType is "Bag"
    if cTemp.InventoryType = iitBag then
    begin
      ///  then it will be created as "container"
      //Result := YGaItem(CreateObject(otContainer));
    end else
    begin
      ///  otherwise it will be created as simple item
      //Result := YGaItem(CreateObject(otItem));
    end;
    // freeing temporary used cTemp item template
    DataCore.ItemTemplates.ReleaseEntry(cTemp);
  end else
  begin
    /// in the case we were not successfull in loading the item template
    /// we'll free the temporary used cTemp item template and
    /// we'll return NIL as result (no item created) and exit this method.
    DataCore.ItemTemplates.ReleaseEntry(cTemp);
    Result := nil;
    Exit;
  end;

  /// if we got here it means everything went ok and now
  /// we'll create the item, assing it's entry ID and owner
  Result.CreateFromTemplate(iEntry);
  Result.Entry := iEntry;
  if cOwner <> nil then
  begin
    Result.Owner := cOwner;
  end;
  if cContained <> nil then
  begin
    /// and in the case that there is a container provided, we'll assing it
    Result.Contained := cContained;
  end;
  /// done!
end;

end.
