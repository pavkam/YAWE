{*------------------------------------------------------------------------------
  Node system and manager.
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.Nodes;

interface

uses
  Framework.Base,
  Framework.Tick,
  Components.Shared,
  Components.DataCore,
  Components.DataCore.Types,
  Components.GameCore.WowObject,
  Components.GameCore.WowMobile,
  Components.GameCore.UpdateFields,
  Components.GameCore.Interfaces,
  SysUtils,
  Bfg.Geometry,
  Bfg.Resources,
  Bfg.Threads,
  Bfg.Containers;

type
  YGaNodeManager = class;

  INodeManager = interface;
  INode = interface;
  INodeContext = interface;

  YNodeLinkType = (nltPrev, nltNext);

  PNodeSpawnInfo = ^YNodeSpawnInfo;
  YNodeSpawnInfo = record
    SpawnedObject: IMobile;
    EntryId: UInt32;
    EntryType: YWowObjectType;
    DistanceMin: Float;
    DistanceMax: Float;
    DelayMin: UInt32;
    DelayMax: UInt32;
  end;

  INode = interface(IInterface)
  ['{62284323-4158-406D-89C0-6FFA319669C1}']
    { private }
    function GetId: UInt32;
    function GetMapId: UInt32;
    function GetPosition: TVector;
    function GetContext(Index: Int32): INodeContext;
    function GetContextCount: Int32;
    function GetOwner: INodeManager;
    procedure SetPosition(const Position: TVector);

    { public }
    function FindContextByInterface(const IID: TGUID): INodeContext;
    function FindContext(const Context: INodeContext): Int32;
    function AddContext(const Context: INodeContext): Int32;
    function RemoveContext(Index: Int32): Int32;

    property Id: UInt32 read GetId;
    property MapId: UInt32 read GetMapId;
    property Position: TVector read GetPosition write SetPosition;
    property Contexts[Index: Int32]: INodeContext read GetContext;
    property ContextCount: Int32 read GetContextCount;

    property Owner: INodeManager read GetOwner;
  end;

  INodeContext = interface(IInterface)
  ['{720E73F3-FF49-412C-8C34-FAA2DDAD3B23}']
    { private }
    function GetOwner: INode;

    { public }
    procedure InjectObjectData(const Entry: INodeEntry);
    procedure ExtractObjectData(const Entry: INodeEntry);

    procedure OnUpdate(TimeDelta: UInt32);
    function AttachToNode(const Node: INode): Boolean;

    property Owner: INode read GetOwner;
  end;

  ISpawnNodeContext = interface(INodeContext)
  ['{8AAC27F3-BCC6-402D-964B-0C0A301AF68A}']
    { private }
    function GetSpawnCount: Int32;

    { public }
    procedure GetSpawnEntry(Index: Int32; out Entry: YNodeSpawnInfo);
    procedure SetSpawnEntry(Index: Int32; const Entry: YNodeSpawnInfo;
      RefreshDelay: Boolean);
    procedure AddSpawnEntry(const Entry: YNodeSpawnInfo);
    procedure RemoveSpawnEntry(Index: Int32);

    property SpawnCount: Int32 read GetSpawnCount;
  end;

  IPathNodeContext = interface(INodeContext)
  ['{BA272537-E1DF-47AB-8085-878A73C09820}']
    function LinkWith(const Node: INode; LinkType: YNodeLinkType): Boolean;
    function UnlinkFrom(const Node: INode; LinkType: YNodeLinkType): Boolean;
    function InsertBetween(const Node1, Node2: INode): Boolean;

    function GetNextNode: INode;
    function GetPrevNode: INode;
  end;

  ITriggerNodeContext = interface(INodeContext)
  ['{B3270D5B-DCFD-4A05-A5C9-D20DD8E10828}']
    procedure TriggerStateChanged(Mobile: IMobile; Left: Boolean);
  end;

  INodeManager = interface(IInterface)
  ['{42CF80BE-C254-4C7C-B65A-5109A1B74FA6}']
    { private }
    function GetNode(Id: UInt32): INode;

    { public }
    function CreateNode(const X, Y, Z: Float; MapId: UInt32): INode;
    function CreateSpawnContext(const Owner: INode): ISpawnNodeContext;
    function CreatePathContext(const Owner: INode): IPathNodeContext;
    function DeleteNode(const Node: INode): Boolean;
    
    property Nodes[Id: UInt32]: INode read GetNode;
  end;

  YGaNodeManager = class(TInterfacedObject, INodeManager)
    private
      fNodes: TIntHashMap;
      fNodesUpdateHandle: TEventHandle;
      fNodeIdHigh: UInt32;
      fStorage: YDbStorageMediumWrapper;

      function GetNode(Id: UInt32): INode; 

      function CreateNodeWithId(Id: UInt32; const X, Y, Z: Float; MapId: UInt32): INode;

      procedure OnNodesUpdate(Event: TEventHandle; TimeDelta: UInt32);
    public
      constructor Create;
      destructor Destroy; override;

      function CreateNode(const X, Y, Z: Float; MapId: UInt32): INode;

      function CreateSpawnContext(const Owner: INode): ISpawnNodeContext;

      function CreatePathContext(const Owner: INode): IPathNodeContext;

      function DeleteNode(const Node: INode): Boolean;

      { Database methods }
      procedure SaveToDatabase;
      procedure LoadFromDatabase;

      property Nodes[Id: UInt32]: INode read GetNode;
  end;

implementation

uses
  Math,
  Bfg.Utils,
  Framework,
  Components.DataCore.DynamicObjectFormat,
  Components.GameCore.WowCreature,
  Components.GameCore.WowGameObject,
  Cores;

type
  YSpawnFlag = (sfSpawned, sfSuspended);
  YSpawnFlags = set of YSpawnFlag;

  PNodeSpawnEntry = ^YNodeSpawnEntry;
  YNodeSpawnEntry = record
    &Object: YGaMobile; { Object's ref }
    EntryId: UInt32; { Id in the DB }
    EntryType: YWowObjectType;
    DistanceMin: Float;
    DistanceMax: Float;
    DelayMin: UInt32;
    DelayMax: UInt32;
    DelayCurrent: UInt32;
    DelayGenerated: UInt32;
    Flags: YSpawnFlags;
  end;

  YGaNode = class(TInterfacedObject, INode)
    private
      fId: UInt32;
      fPosition: TVector;
      fMapId: UInt32;
      fContexts: TIntfArrayList;
      fOwner: INodeManager;

      function GetId: UInt32;
      function GetMapId: UInt32;
      function GetPosition: TVector;
      function GetContext(Index: Int32): INodeContext;
      function GetContextCount: Int32;
      function GetOwner: INodeManager;
      procedure SetPosition(const Position: TVector);

      procedure OnUpdate(Sender: TEventHandle; TimeDelta: UInt32);
    protected
      { Override this in children to perform resource loading }
      procedure ExtractObjectData(const Entry: ISerializable);
      { Override this in children to perform resource saving }
      procedure InjectObjectData(const Entry: ISerializable);
    public
      constructor Create(const X, Y, Z: Float; MapId: UInt32; Id: UInt32; Owner: 
        YGaNodeManager);
      destructor Destroy; override;

      function FindContextByInterface(const IID: TGUID): INodeContext;
      function FindContext(const Context: INodeContext): Int32;
      function AddContext(const Context: INodeContext): Int32;
      function RemoveContext(Index: Int32): Int32;

      property Id: UInt32 read GetId;
      property MapId: UInt32 read GetMapId;
      property Position: TVector read GetPosition write SetPosition;

      property Contexts[Index: Int32]: INodeContext read GetContext;
      property ContextCount: Int32 read GetContextCount;
      property Owner: INodeManager read GetOwner;
  end;

  YGaNodeContext = class(TInterfacedObject, INodeContext, IDofStreamable)
    private
      fOwner: INode;

      function GetOwner: INode;
    protected
      procedure OnUpdate(TimeDelta: UInt32); virtual;
      procedure InjectObjectData(const Entry: INodeEntry); virtual;
      procedure ExtractObjectData(const Entry: INodeEntry); virtual;

      procedure WriteCustomProperties(const Writer: IDofWriter); virtual; stdcall;
      procedure ReadCustomProperties(const Reader: IDofReader); virtual; stdcall;
    public
      constructor Create(const Owner: INode); virtual;
      destructor Destroy; override;

      function AttachToNode(const Node: INode): Boolean;

      property Owner: INode read GetOwner;
  end;

  YGaSpawnNodeContext = class(YGaNodeContext, INodeContext, ISpawnNodeContext)
    private
      fSpawns: array of YNodeSpawnEntry;

      function GetSpawnCount: Int32;
      procedure UpdateSpawnEntry(var Entry: YNodeSpawnEntry; TimeDelta: UInt32);
    protected
      procedure OnUpdate(TimeDelta: UInt32); override;
      procedure InjectObjectData(const Entry: INodeEntry); override;
      procedure ExtractObjectData(const Entry: INodeEntry); override;
      procedure WriteCustomProperties(const Writer: IDofWriter); override; stdcall;
      procedure ReadCustomProperties(const Reader: IDofReader); override; stdcall;
    public
      procedure GetSpawnEntry(Index: Int32; out Entry: YNodeSpawnInfo);
      procedure SetSpawnEntry(Index: Int32; const Entry: YNodeSpawnInfo;
        RefreshDelay: Boolean);
      procedure AddSpawnEntry(const Entry: YNodeSpawnInfo);
      procedure RemoveSpawnEntry(Index: Int32);

      property SpawnCount: Int32 read GetSpawnCount;
  end;

  YGaPathNodeContext = class(YGaNodeContext, INodeContext, IPathNodeContext)
    private
      fNextLinks: TIntfArrayList;
      fPrevLinks: TIntfArrayList;

      class function EnsurePathNodeContextIsContainedIn(const Node: INode): 
        IPathNodeContext; static;

      function LinkWithInternal(const Context: IPathNodeContext; LinkType: YNodeLinkType): Boolean;
      function UnlinkFromInternal(const Context: IPathNodeContext; LinkType: YNodeLinkType): Boolean;
    protected
      procedure InjectObjectData(const Entry: INodeEntry); override;
      procedure ExtractObjectData(const Entry: INodeEntry); override;
    public
      constructor Create(const Owner: INode); override;
      destructor Destroy; override;

      function LinkWith(const Node: INode; LinkType: YNodeLinkType): Boolean;
      function UnlinkFrom(const Node: INode; LinkType: YNodeLinkType): Boolean;
      function InsertBetween(const Node1, Node2: INode): Boolean;

      function GetNextNode: INode;
      function GetPrevNode: INode;
  end;

(*
procedure UpdateSpawn(pNode: PNode);
  function GetRandomSpawnPos(const fMin, fMax: Float): Float;
  begin
    Result := fMin + (Random * (fMax - fMin));
  end;
var
  iIdx: UInt32;
begin
  with pNode^ do
  begin
    for iIdx := 0 to High(SpawnData) do
    begin
      if not SpawnData[iIdx].Spawned and not SpawnData[iIdx].Supressed then
      begin
        Inc(SpawnData[iIdx].Delay.Current);
        if SpawnData[iIdx].Delay.Current >= SpawnData[iIdx].Delay.Generated then
        begin
          if SpawnData[iIdx].EntryType = otUnit then
          begin
            if SpawnData[iIdx].&Object = nil then
            begin
              { A "virgin" spawn, we create a new object for it }
              SpawnData[iIdx].&Object := YGaMobile(GameCore.CreateObject(otUnit));
              YGaCreature(SpawnData[iIdx].&Object).CreateFromTemplate(pNode^.SpawnData[iIdx].EntryId);
              YGaCreature(SpawnData[iIdx].&Object).SpawnNode := pNode;
              with SpawnData[iIdx].&Object do
              begin
                Position.X := pNode^.X + GetRandomSpawnPos(pNode^.SpawnData[iIdx].Distance.Min,
                  pNode^.SpawnData[iIdx].Distance.Max);
                Position.Y := pNode^.Y + GetRandomSpawnPos(pNode^.SpawnData[iIdx].Distance.Min,
                  pNode^.SpawnData[iIdx].Distance.Max);
                Position.Z := pNode^.Z;
                Position.MapId := pNode^.Map;
                ChangeWorldState(wscAdd);
              end;
            end else
            begin
              { Object exists, but not in-world, so put it back there }
              with SpawnData[iIdx].&Object do
              begin
                Position.X := pNode^.X + GetRandomSpawnPos(pNode^.SpawnData[iIdx].Distance.Min,
                  pNode^.SpawnData[iIdx].Distance.Max);
                Position.Y := pNode^.Y + GetRandomSpawnPos(pNode^.SpawnData[iIdx].Distance.Min,
                  pNode^.SpawnData[iIdx].Distance.Max);
                Position.Z := pNode^.Z;
                Position.MapId := pNode^.Map;
                ChangeWorldState(wscEnter);
              end;
            end;
          end else if SpawnData[iIdx].EntryType = otGameObject then
          begin
            if SpawnData[iIdx].&Object = nil then
            begin
              SpawnData[iIdx].&Object := YGaMobile(GameCore.CreateObject(otGameObject));
              with SpawnData[iIdx].&Object do
              begin
                Position.X := pNode^.X + GetRandomSpawnPos(pNode^.SpawnData[iIdx].Distance.Min,
                  pNode^.SpawnData[iIdx].Distance.Max);
                Position.Y := pNode^.Y + GetRandomSpawnPos(pNode^.SpawnData[iIdx].Distance.Min,
                  pNode^.SpawnData[iIdx].Distance.Max);
                Position.Z := pNode^.Z;
                Position.MapId := pNode^.Map;
                ChangeWorldState(wscAdd);
              end;
            end else
            begin
              with SpawnData[iIdx].&Object do
              begin
                Position.X := pNode^.X + GetRandomSpawnPos(pNode^.SpawnData[iIdx].Distance.Min,
                  pNode^.SpawnData[iIdx].Distance.Max);
                Position.Y := pNode^.Y + GetRandomSpawnPos(pNode^.SpawnData[iIdx].Distance.Min,
                  pNode^.SpawnData[iIdx].Distance.Max);
                Position.Z := pNode^.Z;
                Position.MapId := pNode^.Map;
                ChangeWorldState(wscEnter);
              end;
            end;
          end;
          { Generate new wait time }
          SpawnData[iIdx].Delay.Generated := SpawnData[iIdx].Delay.Min +
            Longword(Random(SpawnData[iIdx].Delay.Max - SpawnData[iIdx].Delay.Min + 1));
          { and refresh the current one }
          SpawnData[iIdx].Delay.Current := 0;
          SpawnData[iIdx].Spawned := True;
        end;
      end;
    end;
  end;
end;
*)

{ YNodeManager }

constructor YGaNodeManager.Create;
begin
  inherited Create;
  fNodes := TIntHashMap.Create(1 shl 20, True); { "only" 1024k Capacity }
  fStorage := DataCore.Nodes;
  LoadFromDatabase;
  fNodesUpdateHandle := SysEventMgr.RegisterEvent(OnNodesUpdate, 1000,
    TICK_EXECUTE_INFINITE, 'GaNodeManager_NodeUpdatesTimer');
end;

destructor YGaNodeManager.Destroy;
begin
  fNodesUpdateHandle.Unregister;

  fNodes.Free;
  inherited Destroy;
end;
  
function YGaNodeManager.GetNode(Id: UInt32): INode;
var
  cNode: YGaNode;
begin
  cNode := YGaNode(fNodes[Id]);
  if Assigned(cNode) then
  begin
    Result := cNode as INode;
  end else Result := nil;
end;

procedure YGaNodeManager.LoadFromDatabase;
{TODO 1 -oUNUSED: var
  pNewNode: PNode;
  cNodeData: YNodeEntry;
  ifItr: IPtrIterator;
  iLen: Int32;
  iIdx: Int32;
  iX, iY: Int32;
  lwTemp: UInt32;
  fTemp: Float absolute lwTemp;
  cObj: YOpenMobile;}
begin
  { The total cost for this routine is O(N*3) - it could be simplified to be just
    O(N*2) and probably that's what we'll do }
  (*
  ifItr := fStorage.LoadAllEntries;
  while ifItr.HasNext do
  begin
    pNodeData := ifItr.Next;
    pNewNode := CreateNewNodeWithId(pNodeData^.Id, pNodeData^.PosX, pNodeData^.PosY,
      pNodeData^.PosZ, pNodeData^.MapId);
    fNodes.PutValue(pNewNode^.Id, pNewNode);
  end;

  for iX := 0 to fNodes.Capacity -1 do
  begin
    for iY := 0 to fNodes.Data[iX].Count -1 do
    begin
      pNewNode := fNodes.Data[iX].Entries[iY].Value;
      pNodeData := fStorage.LoadEntry(pNewNode^.Id);
      InitializeNodeFromFlags(pNewNode, UInt32ToFlags(pNodeData^.Flags));
      iLen := Length(pNodeData^.PrevList);
      if iLen = 1 then
      begin
        pNewNode^.Prev := fNodes[pNodeData^.PrevList[0]];
      end else if iLen <> 0 then
      begin
        for iIdx := 0 to iLen -1 do
        begin
          pNewNode^.PrevList^.Count := iLen;
          pNewNode^.PrevList^.Nodes[iIdx] := fNodes[pNodeData^.PrevList[iIdx]];
        end;
      end;

      iLen := Length(pNodeData^.NextList);
      if iLen = 1 then
      begin
        pNewNode^.Next := fNodes[pNodeData^.NextList[0]];
      end else if iLen <> 0 then
      begin
        for iIdx := 0 to iLen -1 do
        begin
          pNewNode^.NextList^.Count := iLen;
          pNewNode^.NextList^.Nodes[iIdx] := fNodes[pNodeData^.NextList[iIdx]];
        end;
      end;

      iLen := Length(pNodeData^.SpawnData);
      iLen := iLen div 11; { 11 fields per YSpawnEntryInfo }
      SetLength(pNewNode^.SpawnData, iLen);
      iIdx := 0;
      while iIdx < iLen -1 do
      begin
        if cGameCore.World.FindObjectByGUID(pNodeData^.SpawnData[iIdx*11+1],
          pNodeData^.SpawnData[iIdx*11+8], cObj) then
        begin
          pNewNode^.SpawnData[iIdx].EntryId := pNodeData^.SpawnData[iIdx*11];
          pNewNode^.SpawnData[iIdx].EntryType := pNodeData^.SpawnData[iIdx*11+1];
          lwTemp := pNodeData^.SpawnData[iIdx*11+2];
          pNewNode^.SpawnData[iIdx].Distance.Min := fTemp;
          lwTemp := pNodeData^.SpawnData[iIdx*11+3];
          pNewNode^.SpawnData[iIdx].Distance.Max := fTemp;
          pNewNode^.SpawnData[iIdx].Delay.Min := pNodeData^.SpawnData[iIdx*11+4];
          pNewNode^.SpawnData[iIdx].Delay.Max := pNodeData^.SpawnData[iIdx*11+5];
          pNewNode^.SpawnData[iIdx].Delay.Current := pNodeData^.SpawnData[iIdx*11+6];
          pNewNode^.SpawnData[iIdx].Delay.Generated := pNodeData^.SpawnData[iIdx*11+7];
          pNewNode^.SpawnData[iIdx].&Object := cObj;
          //pNewNode^.SpawnData[iIdx].Spawned := Boolean(pNodeData^.SpawnData[iIdx*11+9]);
          pNewNode^.SpawnData[iIdx].Supressed := Boolean(pNodeData^.SpawnData[iIdx*11+10]);
        end else
        begin
          { The object does not exist - corrupted DB or manually deleted }
          Dec(iIdx);
          Dec(iLen);
          SetLength(pNewNode^.SpawnData, Length(pNewNode^.SpawnData) -1);
        end;
      end;
      if iLen > 0 then fSpawns.Add(pNewNode);
    end;
  end;
  *)
end;

procedure YGaNodeManager.OnNodesUpdate(Event: TEventHandle; TimeDelta: UInt32);
var
  ifItr: IIterator;
begin
  ifItr := fNodes.Values;
  while ifItr.HasNext do
  begin
    YGaNode(ifItr.Next).OnUpdate(Event, TimeDelta);
  end;
end;

procedure YGaNodeManager.SaveToDatabase;
{TODO 1 -oUNUSED: var
  pSaveNode: PNode;
  cNodeData: YNodeEntry;
  iIdx: Int32;
  iX, iY: Int32;
  iCount: Int32;
  fTemp: Float;
  lwTemp: UInt32 absolute fTemp;}
begin
  (*
  for iX := 0 to fNodes.Capacity -1 do
  begin
    for iY := 0 to fNodes.Data[iX].Count -1 do
    begin
      pSaveNode := fNodes.Data[iX].Entries[iY].Value;
      pNodeData := fStorage.LoadEntry(pSaveNode^.Id);
      if pNodeData = nil then
      begin
        fStorage.AllocateEntry(@pNodeData, pSaveNode^.Id);
      end;
      pNodeData^.PosX := pSaveNode^.X;
      pNodeData^.PosY := pSaveNode^.Y;
      pNodeData^.PosZ := pSaveNode^.Z;
      pNodeData^.MapId := pSaveNode^.Map;
      pNodeData^.Flags := FlagsToUInt32(pSaveNode^.Flags);
      if nfMultilink in pSaveNode^.Flags then
      begin
        if pSaveNode^.NextList <> nil then
        begin
          iCount := pSaveNode^.NextList^.Count;
          SetLength(pNodeData^.NextList, iCount);
          for iIdx := 0 to iCount -1 do
          begin
            pNodeData^.NextList[iIdx] := pSaveNode^.NextList^.Nodes[iIdx]^.Id;
          end;
        end;

        if pSaveNode^.PrevList <> nil then
        begin
          iCount := pSaveNode^.PrevList^.Count;
          SetLength(pNodeData^.PrevList, iCount);
          for iIdx := 0 to iCount -1 do
          begin
            pNodeData^.PrevList[iIdx] := pSaveNode^.PrevList^.Nodes[iIdx]^.Id;
          end;
        end;
      end else if nfLink in pSaveNode^.Flags then
      begin
        if pSaveNode^.Next <> nil then
        begin
          SetLength(pNodeData^.NextList, 1);
          pNodeData^.NextList[0] := pSaveNode^.Next^.Id;
        end else pNodeData^.NextList := nil;

        if pSaveNode^.Prev <> nil then
        begin
          SetLength(pNodeData^.PrevList, 1);
          pNodeData^.PrevList[0] := pSaveNode^.Prev^.Id;
        end else pNodeData^.PrevList := nil;
      end;

      if nfSpawn in pSaveNode^.Flags then
      begin
        iCount := Length(pNodeData^.SpawnData);
        SetLength(pNodeData^.SpawnData, iCount * 11);
        for iIdx := 0 to iCount -1 do
        begin
          pNodeData^.SpawnData[iIdx*11] := pSaveNode^.SpawnData[iIdx].EntryId;
          pNodeData^.SpawnData[iIdx*11+1] := pSaveNode^.SpawnData[iIdx].EntryType;
          fTemp := pSaveNode^.SpawnData[iIdx].Distance.Min;
          pNodeData^.SpawnData[iIdx*11+2] := lwTemp;
          fTemp := pSaveNode^.SpawnData[iIdx].Distance.Max;
          pNodeData^.SpawnData[iIdx*11+3] := lwTemp;
          pNodeData^.SpawnData[iIdx*11+4] := pSaveNode^.SpawnData[iIdx].Delay.Min;
          pNodeData^.SpawnData[iIdx*11+5] := pSaveNode^.SpawnData[iIdx].Delay.Max;
          pNodeData^.SpawnData[iIdx*11+6] := pSaveNode^.SpawnData[iIdx].Delay.Current;
          pNodeData^.SpawnData[iIdx*11+7] := pSaveNode^.SpawnData[iIdx].Delay.Generated;
          pNodeData^.SpawnData[iIdx*11+8] := pSaveNode^.SpawnData[iIdx].&Object.GUIDLo;
          //pNodeData^.SpawnData[iIdx*11+9] := UInt32(pSaveNode^.SpawnData[iIdx].Spawned);
          pNodeData^.SpawnData[iIdx*11+10] := UInt32(pSaveNode^.SpawnData[iIdx].Supressed);
        end;
      end;
    end;
  end;
  *)
end;

function YGaNodeManager.CreateNode(const X, Y, Z: Float; MapId: UInt32): INode;
begin
  Result := CreateNodeWithId(AtomicInc(@fNodeIdHigh), X, Y, Z, MapId);
end;

function YGaNodeManager.CreateNodeWithId(Id: UInt32; const X, Y, Z: Float;
  MapId: UInt32): INode;
var
  cNode: YGaNode;
begin
  AtomicExchange(@fNodeIdHigh, Max(fNodeIdHigh, Id));
  cNode := YGaNode.Create(X, Y, Z, MapId, Id, Self);
  fNodes.PutValue(Id, cNode);
  Result := cNode;
end;

function YGaNodeManager.CreatePathContext(const Owner: INode): IPathNodeContext;
begin
  Result := YGaPathNodeContext.Create(Owner);
end;

function YGaNodeManager.CreateSpawnContext(const Owner: INode): ISpawnNodeContext;
begin
  Result := YGaSpawnNodeContext.Create(Owner);
end;

function YGaNodeManager.DeleteNode(const Node: INode): Boolean;
begin
  if Assigned(Node) then
  begin
    fNodes.Remove(Node.Id);
    Result := True;
  end else Result := False;
end;

{ YGaNode }

constructor YGaNode.Create(const X, Y, Z: Float; MapId: UInt32;
  Id: UInt32; Owner: YGaNodeManager);
begin
  inherited Create;

  fContexts := TIntfArrayList.Create(8);
  fId := Id;
  MakeVector(fPosition, X, Y, Z);
  fMapId := MapId;
  fOwner := Owner as INodeManager;
end;

destructor YGaNode.Destroy;
begin
  fContexts.Free;

  inherited Destroy;
end;

function YGaNode.AddContext(const Context: INodeContext): Int32;
begin
  if fContexts.IndexOf(Context) = -1 then
  begin
    fContexts.Add(Context);
  end;
  Result := fContexts.Size;
end;

function YGaNode.RemoveContext(Index: Int32): Int32;
begin
  fContexts.Remove(Index);
  Result := fContexts.Size;
end;

procedure YGaNode.SetPosition(const Position: TVector);
begin
  fPosition := Position;
end;

function YGaNode.FindContext(const Context: INodeContext): Int32;
begin
  Result := fContexts.IndexOf(Context);
end;

function YGaNode.FindContextByInterface(const IID: TGUID): INodeContext;
var
  iIdx: Int32;
begin
  for iIdx := 0 to fContexts.Size -1 do
  begin
    if fContexts[iIdx].QueryInterface(IID, Result) = S_OK then
    begin
      Exit;
    end;
  end;
  Result := nil;
end;

function YGaNode.GetContext(Index: Int32): INodeContext;
begin
  Result := fContexts[Index] as INodeContext;
end;

function YGaNode.GetContextCount: Int32;
begin
  Result := fContexts.Size;
end;

function YGaNode.GetId: UInt32;
begin
  Result := fId;
end;

function YGaNode.GetMapId: UInt32;
begin
  Result := fMapId;
end;

function YGaNode.GetOwner: INodeManager;
begin
  Result := fOwner;
end;

function YGaNode.GetPosition: TVector;
begin
  Result := fPosition;
end;

procedure YGaNode.OnUpdate(Sender: TEventHandle; TimeDelta: UInt32);
var
  iIdx: Int32;
begin
  for iIdx := 0 to fContexts.Size -1 do
  begin
    (fContexts[iIdx] as INodeContext).OnUpdate(TimeDelta);
  end;
end;

procedure YGaNode.InjectObjectData(const Entry: ISerializable);
var
  Node: INodeEntry;
  iInt: Int32;
begin
  Node := Entry as INodeEntry;
  Node.X := fPosition.X;
  Node.Y := fPosition.Y;
  Node.Z := fPosition.Z;
  Node.MapId := fMapId;
  for iInt := 0 to fContexts.Size -1 do
  begin
    (fContexts[iInt] as INodeContext).InjectObjectData(Node);
  end;
end;

procedure YGaNode.ExtractObjectData(const Entry: ISerializable);
var
  Node: INodeEntry;
  I: Int32;
begin
  Node := Entry as INodeEntry;
  for I := 0 to fContexts.Size -1 do
  begin
    (fContexts[I] as INodeContext).ExtractObjectData(Node);
  end;
end;

{ YGaNodeContext }

function YGaNodeContext.AttachToNode(const Node: INode): Boolean;
begin
  if Assigned(fOwner) then
  begin
    fOwner.RemoveContext(fOwner.FindContext(Self));
  end;
  if Node <> nil then Node.AddContext(Self);
  fOwner := Node;
  Result := True;
end;

constructor YGaNodeContext.Create(const Owner: INode);
begin
  inherited Create;
  fOwner := Owner;
  if Assigned(Owner) then Owner.AddContext(Self);
end;

destructor YGaNodeContext.Destroy;
begin
  if Assigned(fOwner) then fOwner.RemoveContext(fOwner.FindContext(Self));

  inherited Destroy;
end;

function YGaNodeContext.GetOwner: INode;
begin
  Result := fOwner;
end;

procedure YGaNodeContext.InjectObjectData(const Entry: INodeEntry);
begin
  {
    Nothing
  }
end;

procedure YGaNodeContext.ExtractObjectData(const Entry: INodeEntry);
begin
  {
    Nothing
  }
end;

procedure YGaNodeContext.OnUpdate(TimeDelta: UInt32);
begin
  {
    Nothing
  }
end;

procedure YGaNodeContext.ReadCustomProperties(const Reader: IDofReader);
begin
  {
    Nothing
  }
end;

procedure YGaNodeContext.WriteCustomProperties(const Writer: IDofWriter);
begin
  {
    Nothing
  }
end;

{ YGaSpawnNodeContext }

procedure YGaSpawnNodeContext.InjectObjectData(const Entry: INodeEntry);
begin
  Entry.Context['SpawnData'] := Self;
end;

procedure YGaSpawnNodeContext.ExtractObjectData(const Entry: INodeEntry);
var
  Ctx: INodeContext;
begin
  Ctx := Entry.Context['SpawnData'] as INodeContext;
  if Assigned(Ctx) then
  begin

  end;
end;

procedure YGaSpawnNodeContext.ReadCustomProperties(const Reader: IDofReader);
var
  I: Integer;
begin
  Reader.ReadCollectionStart;
  I := 0;
  while not Reader.IsCollectionEnd do
  begin
    SetLength(fSpawns, I + 1);
    fSpawns[I].EntryId := Reader.ReadLong;
    fSpawns[I].EntryType := YWowObjectType(Reader.ReadLong);
    fSpawns[I].DistanceMin := Reader.ReadSingle;
    fSpawns[I].DistanceMax := Reader.ReadSingle;
    fSpawns[I].DelayMin := Reader.ReadLong;
    fSpawns[I].DelayMax := Reader.ReadLong;
    fSpawns[I].DelayCurrent := Reader.ReadLong;
    fSpawns[I].DelayGenerated := Reader.ReadLong;
    Inc(I);
  end;
  Reader.ReadCollectionEnd;
end;

procedure YGaSpawnNodeContext.WriteCustomProperties(const Writer: IDofWriter);
var
  I: Integer;
begin
  Writer.WriteCollectionStart;
  for I := 0 to Length(fSpawns) -1 do
  begin
    Writer.WriteLong(fSpawns[I].EntryId);
    Writer.WriteLong(Longword(fSpawns[I].EntryType));
    Writer.WriteSingle(fSpawns[I].DistanceMin);
    Writer.WriteSingle(fSPawns[I].DistanceMax);
    Writer.WriteLong(fSpawns[I].DelayMin);
    Writer.WriteLong(fSpawns[I].DelayMax);
    Writer.WriteLong(fSpawns[I].DelayCurrent);
    Writer.WriteLong(fSpawns[I].DelayGenerated);
  end;
  Writer.WriteCollectionEnd;
end;

procedure YGaSpawnNodeContext.AddSpawnEntry(const Entry: YNodeSpawnInfo);
var
  iLen: Int32;
  iTemp: UInt32;
  fTemp: Float;
begin
  Assert(Entry.EntryType in [otUnit, otGameobject]);

  iLen := Length(fSpawns);
  SetLength(fSpawns, iLen + 1);
  with fSpawns[iLen] do
  begin
    if Entry.SpawnedObject <> nil then
    begin
      GameCore.FindObjectByGUID(Entry.EntryType, 0, &Object);//Entry.SpawnedObject.GUID;
      Include(Flags, sfSpawned);
    end;
    &Object := nil;
    EntryId := Entry.EntryId;
    EntryType := Entry.EntryType;
    DistanceMin := Entry.DistanceMin;
    DistanceMax := Entry.DistanceMax;
    if DistanceMin < 0 then DistanceMin := 0;
    if DistanceMax < 0 then DistanceMax := 0;
    if DistanceMin > DistanceMax then
    begin
      fTemp := DistanceMax;
      DistanceMax := DistanceMin;
      DistanceMin := fTemp;
    end;
    DelayMin := Entry.DelayMin;
    DelayMax := Entry.DelayMax;
    if DelayMin > DelayMax then
    begin
      iTemp := DelayMax;
      DelayMax := DelayMin;
      DelayMin := iTemp;
    end;
    DelayGenerated := DelayMin + Longword(Random(Integer(DelayMax - DelayMin + 1)));
  end;
end;

function YGaSpawnNodeContext.GetSpawnCount: Int32;
begin
  Result := Length(fSpawns);
end;

procedure YGaSpawnNodeContext.GetSpawnEntry(Index: Int32;
  out Entry: YNodeSpawnInfo);
begin
  if (Index < 0) or (Index > Length(fSpawns) -1) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  
  Entry.SpawnedObject := fSpawns[Index].&Object as IMobile;
  Entry.EntryId := fSpawns[Index].EntryId;
  Entry.DistanceMin := fSpawns[Index].DistanceMin;
  Entry.DistanceMax := fSpawns[Index].DistanceMax;
  Entry.DelayMin := fSpawns[Index].DelayMin;
  Entry.DelayMax := fSpawns[Index].DelayMax;
end;

procedure YGaSpawnNodeContext.OnUpdate(TimeDelta: UInt32);
var
  iIdx: Int32;
begin
  for iIdx := 0 to Length(fSpawns) -1 do
  begin
    UpdateSpawnEntry(fSpawns[iIdx], TimeDelta);
  end;
end;

procedure YGaSpawnNodeContext.RemoveSpawnEntry(Index: Int32);
begin
  if (Index < 0) or (Index > Length(fSpawns) -1) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  
  Move(fSpawns[Index+1], fSpawns[Index], (Length(fSpawns) - 1 - Index) *
    SizeOf(YNodeSpawnEntry));
  SetLength(fSpawns, High(fSpawns));
end;

procedure YGaSpawnNodeContext.SetSpawnEntry(Index: Int32;
  const Entry: YNodeSpawnInfo; RefreshDelay: Boolean);
begin
  if (Index < 0) or (Index > Length(fSpawns) -1) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;

end;

procedure YGaSpawnNodeContext.UpdateSpawnEntry(var Entry: YNodeSpawnEntry;
  TimeDelta: UInt32);
var
  tRandVec: TVector;
  fTemp: Float;
begin
  if (sfSpawned in Entry.Flags) or (sfSuspended in Entry.Flags) then Exit;
  
  Inc(Entry.DelayCurrent, TimeDelta);
  if Entry.DelayCurrent >= Entry.DelayGenerated then
  begin
    Entry.DelayGenerated := Entry.DelayMin + Longword(Random(Integer(Entry.DelayMax -
      Entry.DelayMin + 1)));
    Entry.DelayCurrent := 0;

    fTemp := Entry.DistanceMax - Entry.DistanceMin;

    if Entry.EntryType = otUnit then
    begin
      GameCore.CreateObject(otUnit, Entry.&Object, False);
      YGaCreature(Entry.&Object).CreateFromTemplate(Entry.EntryId);
    end else
    begin
      GameCore.CreateObject(otGameobject, Entry.&Object, False);
      YGaGameObject(Entry.&Object).InitializeFromTemplate(Entry.EntryId);
    end;
    
    MakeVector(tRandVec, Entry.DistanceMin + (Random * fTemp),
      Entry.DistanceMin + (Random * fTemp), Entry.DistanceMin + (Random * fTemp));
      
    AddVector(tRandVec, fOwner.Position);

    Entry.&Object.Vector := tRandVec;
    Entry.&Object.Angle := Random * (2 * PI);
    Entry.&Object.MapId := fOwner.MapId;
    Entry.&Object.ChangeWorldState(wscAdd);
    Include(Entry.Flags, sfSpawned);
  end;
end;

{ YGaPathNodeContext }

procedure YGaPathNodeContext.InjectObjectData(const Entry: INodeEntry);
begin
end;

procedure YGaPathNodeContext.ExtractObjectData(const Entry: INodeEntry);
begin
end;

constructor YGaPathNodeContext.Create(const Owner: INode);
begin
  inherited Create(Owner);

  fPrevLinks := TIntfArrayList.Create(4);
  fNextLinks := TIntfArrayList.Create(4);
end;

destructor YGaPathNodeContext.Destroy;
begin
  fPrevLinks.Free;
  fNextLinks.Free;

  inherited Destroy;
end;

class function YGaPathNodeContext.EnsurePathNodeContextIsContainedIn(
  const Node: INode): IPathNodeContext;
begin
  Result := Node.FindContextByInterface(IPathNodeContext) as IPathNodeContext;
  if not Assigned(Result) then
  begin
    Result := Node.Owner.CreatePathContext(Node);
  end;
end;

function YGaPathNodeContext.GetNextNode: INode;
var
  iSize: Int32;
begin
  iSize := fNextLinks.Size;
  if iSize = 1 then
  begin
    Result := fNextLinks[0] as INode;
  end else if iSize <> 0 then
  begin
    Result := fNextLinks[Random(iSize)] as INode;
  end else Result := nil;
end;

function YGaPathNodeContext.GetPrevNode: INode;
var
  iSize: Int32;
begin
  iSize := fPrevLinks.Size;
  if iSize = 1 then
  begin
    Result := fPrevLinks[0] as INode;
  end else if iSize <> 0 then
  begin
    Result := fPrevLinks[Random(iSize)] as INode;
  end else Result := nil;
end;

function YGaPathNodeContext.InsertBetween(const Node1, Node2: INode): Boolean;
var
  ifContext1: IPathNodeContext;
  ifContext2: IPathNodeContext;
begin
  if not Assigned(Node1) or not Assigned(Node2) then
  begin
    raise EInvalidArgument.CreateRes(@RsNilArgument);
  end;

  ifContext1 := EnsurePathNodeContextIsContainedIn(Node1);
  ifContext2 := EnsurePathNodeContextIsContainedIn(Node2);

  ifContext1.UnlinkFrom(Node2, nltNext);
  ifContext2.UnlinkFrom(Node1, nltPrev);
  ifContext1.LinkWith(fOwner, nltNext);
  ifContext2.LinkWith(fOwner, nltPrev);
  LinkWithInternal(ifContext1, nltPrev);
  LinkWithInternal(ifContext2, nltNext);

  Result := True;
end;

function YGaPathNodeContext.LinkWith(const Node: INode; LinkType: YNodeLinkType): Boolean;
var
  ifContext: IPathNodeContext;
begin
  if not Assigned(Node) then
  begin
    raise EInvalidArgument.CreateRes(@RsNilArgument);
  end;

  ifContext := EnsurePathNodeContextIsContainedIn(Node);

  if LinkType = nltPrev then
  begin
    Result := LinkWithInternal(ifContext, nltPrev);
    ifContext.LinkWith(fOwner, nltNext);
  end else
  begin
    Result := LinkWithInternal(ifContext, nltNext);
    ifContext.LinkWith(fOwner, nltPrev);
  end;
end;

function YGaPathNodeContext.LinkWithInternal(const Context: IPathNodeContext;
  LinkType: YNodeLinkType): Boolean;
begin
  if LinkType = nltPrev then
  begin
    if not fPrevLinks.Contains(Context) then
    begin
      fPrevLinks.Add(Context);
      Result := True;
    end else Result := False;
  end else
  begin
    if not fNextLinks.Contains(Context) then
    begin
      fNextLinks.Add(Context);
      Result := True;
    end else Result := False;
  end;
end;

function YGaPathNodeContext.UnlinkFrom(const Node: INode; LinkType: YNodeLinkType): Boolean;
var
  ifContext: IPathNodeContext;
begin
  if not Assigned(Node) then
  begin
    raise EInvalidArgument.CreateRes(@RsNilArgument);
  end;

  ifContext := EnsurePathNodeContextIsContainedIn(Node);

  if LinkType = nltPrev then
  begin
    Result := UnlinkFromInternal(ifContext, nltPrev);
    ifContext.LinkWith(fOwner, nltNext);
  end else
  begin
    Result := UnlinkFromInternal(ifContext, nltNext);
    ifContext.LinkWith(fOwner, nltPrev);
  end;
end;

function YGaPathNodeContext.UnlinkFromInternal(const Context: IPathNodeContext;
  LinkType: YNodeLinkType): Boolean;
begin
  if LinkType = nltPrev then
  begin
    Result := fPrevLinks.Remove(Context);
  end else
  begin
    Result := fNextLinks.Remove(Context);
  end;
end;

end.
