{*------------------------------------------------------------------------------
  WOW Game Terrain Manager
  There are lots of methods here used to query area informations, liquid informations,
  everything that is needed in game related to terrain

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
  @Docs TheSelby
-------------------------------------------------------------------------------}
{$I compiler.inc}
unit Components.GameCore.TerrainManager;

interface

{$REGION 'Uses clause'}
uses
  Components.DataCore.WorldData.Types,
  Framework.Base,
  Framework.Tick,
  Misc.Geometry,
  Misc.Containers,
  Misc.Miscleanous,
  Classes,
  SysUtils;
{$ENDREGION}
  
type

  {$REGION 'Terrain Information Records'}
    {*------------------------------------------------------------------------------
    PTileInfo - pointer to YTileInfo
    @see YTileInfo
    -------------------------------------------------------------------------------}
    PTileInfo = ^YTileInfo;
    {*------------------------------------------------------------------------------
    YTileInfo - record with Tile Informations such as:
      TimeStamp (Time delta)
      Data (PTileChunk format)
      MapId
    @see PTileChunk
    -------------------------------------------------------------------------------}
    YTileInfo = record
      TimeStamp: UInt32;
      Data: PTileChunk;
      MapId: UInt32;
    end;
  
    {*------------------------------------------------------------------------------
    PPerMapTileData - pointer to YPerMapTileData
    @see YPerMapTileData
    -------------------------------------------------------------------------------}
    PPerMapTileData = ^YPerMapTileData;
    {*------------------------------------------------------------------------------
    YPerMapTileData - array of Tiles
    Max value for rows/columns is the constant TILES_PER_MAP (64)
    @see Components.DataCore.WorldData.Types
    -------------------------------------------------------------------------------}
    YPerMapTileData = record
      Tiles: array[0..TILES_PER_MAP-1, 0..TILES_PER_MAP-1] of YTileInfo;
    end;
  
    {*------------------------------------------------------------------------------
    PLiquidInfo - pointer to YLiquidInfo
    @see YLiquidInfo
    -------------------------------------------------------------------------------}
    PLiquidInfo = ^YLiquidInfo;
    {*------------------------------------------------------------------------------
    YLiquidInfo - record with Liquid Informations such as:
      Height
      Flags
    -------------------------------------------------------------------------------}
    YLiquidInfo = record
      Height: Float;
      Flags: TMapCellFlags;
    end;
  
    {*------------------------------------------------------------------------------
    PAreaInfo - pointer to YAreaInfo
    @see YAreaInfo
    -------------------------------------------------------------------------------}
    PAreaInfo = ^YAreaInfo;
    {*------------------------------------------------------------------------------
    YAreaInfo - record with Area Informations such as:
      AreaID
      Flags
    -------------------------------------------------------------------------------}
    YAreaInfo = record
      AreaId: UInt32;
      Flags: UInt8;
    end;
  
    {*------------------------------------------------------------------------------
    PZoneInfo - pointer to YZoneInfo
    @see YZoneInfo
    -------------------------------------------------------------------------------}
    PZoneInfo = ^YZoneInfo;
    {*------------------------------------------------------------------------------
    YZoneInfo - record with Zone Informations such as:
      ZoneId
      Level
    -------------------------------------------------------------------------------}
    YZoneInfo = record
      ZoneId: UInt32;
      Level: UInt8;
    end;
  
    {*------------------------------------------------------------------------------
    PPointInfo - pointer to YPointInfo
    @see YPointInfo
    @see YLiquidInfo
    @see YAreaInfo
    @see YZoneInfo
    -------------------------------------------------------------------------------}
    PPointInfo = ^YPointInfo;
    {*------------------------------------------------------------------------------
    YPointInfo - record with Point Informations such as:
      Height
      LiquidInfo
      AreaInfo
      ZoneInfo
    @see YLiquidInfo
    @see YAreaInfo
    @see YZoneInfo
    -------------------------------------------------------------------------------}
    YPointInfo = record
      Height: Float;
      LiquidInfo: YLiquidInfo;
      AreaInfo: YAreaInfo;
      ZoneInfo: YZoneInfo;
    end;
  {$ENDREGION}

  {*------------------------------------------------------------------------------
  YGaTerrainManager Class derived from YInterfacedObject
  @see YInterfacedObject
  -------------------------------------------------------------------------------}
  ITerrainManager = interface(IInterface)
  ['{2DD67028-E536-4572-9F06-45E9754D6342}']
    function QueryHeightAt(MapId: UInt32; const X, Y: Float; out Z: Float): Boolean;
    function QueryLiquidInfoAt(MapId: UInt32; const X, Y: Float; out LiquidInfo: YLiquidInfo): Boolean;
    function QueryAreaInfoAt(MapId: UInt32; const X, Y: Float; out AreaInfo: YAreaInfo): Boolean;
    function QueryZoneInfoAt(MapId: UInt32; const X, Y: Float; out ZoneInfo: YZoneInfo): Boolean;
    function QueryPointInfoAt(MapId: UInt32; const X, Y: Float; out PointInfo: YPointInfo): Boolean;
  end;

  YGaTerrainManager = class(TBaseInterfacedObject, ITerrainManager)
    private
      {$REGION 'Private members'}
      fMapData: TIntPtrHashMap;      ///A HashList which will contain MapData
      fUsedTiles: TList;             ///A fast list used to remember all used tiles
      fMonitorHandle: TEventHandle;  ///An event handler timer

      procedure MonitorTimestamps(Event: TEventHandle; TimeDelta: UInt32);
      function GetMapTileTable(MapId: UInt32): PPerMapTileData;
      function GetTileInfoByCoords(MapId: UInt32; const X, Y: Float): PTileInfo;
      procedure TranslateCoordinatesToTileIndices(const X, Y: Float; out XIndex, YIndex: Int32);
      {$ENDREGION}
    protected
      {$REGION 'Protected members'}
      {$ENDREGION}
    public
      {$REGION 'Public members'}
      
      constructor Create;
      destructor Destroy; override;

      function QueryHeightAt(MapId: UInt32; const X, Y: Float; out Z: Float): Boolean;
      function QueryLiquidInfoAt(MapId: UInt32; const X, Y: Float; out LiquidInfo: YLiquidInfo): Boolean;
      function QueryAreaInfoAt(MapId: UInt32; const X, Y: Float; out AreaInfo: YAreaInfo): Boolean;
      function QueryZoneInfoAt(MapId: UInt32; const X, Y: Float; out ZoneInfo: YZoneInfo): Boolean;
      function QueryPointInfoAt(MapId: UInt32; const X, Y: Float; out PointInfo: YPointInfo): Boolean;

      {$ENDREGION}
  end;

{$REGION 'Monitor Timer CONSTANTS'}
  const
    {*------------------------------------------------------------------------------
    MonitorTimestamp's wait time (60 seconds)
    -------------------------------------------------------------------------------}
    MONITOR_WAIT = 1000 * 60 { ms };
    {*------------------------------------------------------------------------------
    MonitorTimestamp's maximum idle time (5 minutes)
    -------------------------------------------------------------------------------}
    MAX_IDLE_TIME = 1000 * 60 * 5 { ms };
{$ENDREGION}

implementation

{$REGION 'Uses clause'}
uses
  MMSystem,
  Framework,
  Cores,
  Math;
{$ENDREGION}


{$REGION 'YTerrainManager Methods'}
  {*------------------------------------------------------------------------------
    Constructor for YGaTerrainManager class
  

    @see PPerMapTileData
    @see PTileInfo
    @see IPtrIterator
  -------------------------------------------------------------------------------}
constructor YGaTerrainManager.Create;
begin
  /// Inherits Create
  inherited Create;
  /// Creates a HashMap in fMapData
  fMapData := TIntPtrHashMap.Create(1024);
  /// Creates fUsedTiles as a fast list
  fUsedTiles := TList.Create;

  /// Registers a MonitorTimestamps timer
  fMonitorHandle := SystemTimer.RegisterEvent(MonitorTimestamps, MONITOR_WAIT,
    TICK_EXECUTE_INFINITE, 'GaTerrainManager_TerrainMonitorTimer');
end;

  {*------------------------------------------------------------------------------
    Destructor for YGaTerrainManager class


    @see PPerMapTileData
    @see PTileInfo
    @see IPtrIterator
    @see MonitorTimestamps
  -------------------------------------------------------------------------------}
destructor YGaTerrainManager.Destroy;
var
  ifItr: IPtrIterator;
  pMapData: PPerMapTileData;
  iX, iY: Int32;
  pTile: PTileInfo;
begin
  /// Unregisters fMonitorHandle (MonitorTimestamps timer)
  fMonitorHandle.Unregister;

  ifItr := fMapData.Values;

  /// Disposing of data used
  while ifItr.HasNext do
  begin
    pMapData := ifItr.Next;
    for iX := 0 to TILES_PER_MAP -1 do
    begin
      for iY := 0 to TILES_PER_MAP -1 do
      begin
        pTile := @pMapData^.Tiles[iX, iY];
        if pTile^.Data <> nil then Dispose(pTile^.Data);
      end;
    end;
    Dispose(pMapData);
  end;

  /// Freeing fMapData, fUsedTiles and inheriting Destroy
  fMapData.Free;
  fUsedTiles.Free;
  inherited Destroy;
end;

  {*------------------------------------------------------------------------------
    Trying to get Map tile table


    @param iMapId The map where the area is tested
    @return MapTileData in PPerMapTileData format
    @see PPerMapTileData
    @see YPerMapTileData
  -------------------------------------------------------------------------------}
function YGaTerrainManager.GetMapTileTable(MapId: UInt32): PPerMapTileData;
begin
  Result := fMapData.GetValue(MapId);
  if Result = nil then
  begin
    Result := AllocMem(SizeOf(YPerMapTileData));
    fMapData.PutValue(MapId, Result);
  end;
end;


  {*------------------------------------------------------------------------------
    Trying to get tile informations using some given coordinates


    @param iMapId The map where the area is tested
    @param fX X coordinate
    @param fY Y coordinate
    @return TileInfo in PTileInfo format
    @see PTileInfo
    @see PPerMapTileData
    @see TranslateCoordinatesToTileIndices
    @see GetMapTileTable
  -------------------------------------------------------------------------------}
function YGaTerrainManager.GetTileInfoByCoords(MapId: UInt32; const X, Y: Float): PTileInfo;
var
  iX, iY: Int32;
  pTable: PPerMapTileData;
begin
  TranslateCoordinatesToTileIndices(X, Y, iX, iY);
  pTable := GetMapTileTable(MapId);
  Result := @pTable^.Tiles[iX, iY];
  if Result^.Data = nil then
  begin
    if DataCore.WorldData.TrIsBlockDefined(MapId, iX, iY) then
    begin
      try
        New(Result^.Data);
        if DataCore.WorldData.TrFillTileData(MapId, iX, iY, Result^.Data) then
        begin
          Result^.TimeStamp := TimeGetTime;
          fUsedTiles.Add(Result);
        end else
        begin
          Dispose(Result^.Data);
          Result^.Data := nil;
          Result^.TimeStamp := 0;
        end;
      except
        on E: EOutOfMemory do
        begin
          Result^.TimeStamp := 0;
        end;
      else
        raise;
      end;
    end else Result^.TimeStamp := 0;
    Result^.MapId := MapId;
  end else Result^.TimeStamp := TimeGetTime;
end;


  {*------------------------------------------------------------------------------
    Monitoring Terrain Event Timestamps
  
    @param Event The event monitored
    @param TimeDelta TimeDelta value
  -------------------------------------------------------------------------------}
procedure YGaTerrainManager.MonitorTimestamps(Event: TEventHandle; TimeDelta: UInt32);
var
  iInt: Int32;
  pTile: PTileInfo;
  iTime: UInt32;
begin
  iTime := TimeGetTime;
  iInt := fUsedTiles.Count -1;
  while iInt > -1 do
  begin
    pTile := fUsedTiles[iInt];
    if pTile <> nil then
    begin
      if GetTimeDifference(iTime, pTile^.TimeStamp) > MAX_IDLE_TIME then
      begin
        fUsedTiles[iInt] := fUsedTiles[fUsedTiles.Count-1];
        fUsedTiles[fUsedTiles.Count-1] := nil;
        Dispose(pTile^.Data);
        pTile^.Data := nil;
        pTile^.TimeStamp := 0;
      end;
    end;
    Dec(iInt);
  end;
  fUsedTiles.Pack;
end;


  {*------------------------------------------------------------------------------
    Trying to query area flags and area ID on a given map ID
  
  
    @param iMapId The map where the area is tested
    @param fX X coordinate
    @param fY Y coordinate
    @param tArInfo the area flags and area ID in that map
    @return True if successful, False `au contraire`
  -------------------------------------------------------------------------------}
function YGaTerrainManager.QueryAreaInfoAt(MapId: UInt32; const X, Y: Float;out AreaInfo: YAreaInfo): Boolean;
var
  pTile: PTileInfo;
  iX, iY: Int32;
begin
  pTile := GetTileInfoByCoords(MapId, X, Y);
  if pTile^.Data <> nil then
  begin
    iX := Floor32((pTile^.Data^.Borders.MaxX - X) * (1 / CELL_SIZE));
    iY := Floor32((pTile^.Data^.Borders.MaxY - Y) * (1 / CELL_SIZE));
    if iX > CELLS_PER_TILE - 1 then iX := CELLS_PER_TILE - 1 else if iX < 0 then iX := 0;
    if iY > CELLS_PER_TILE - 1 then iY := CELLS_PER_TILE - 1 else if iY < 0 then iY := 0;

    AreaInfo.AreaId := pTile^.Data^.AreaIds[iX, iY];
    AreaInfo.Flags := pTile^.Data^.AreaFlags[iX, iY];
    Result := True;
  end else Result := False;
end;

  {*------------------------------------------------------------------------------
    Trying to query height informations at some coordinates on a given map ID
  
  
    @param iMapId The map where the zone is tested
    @param fX 0X coordinate
    @param fY 0Y coordinate
    @param fHeight the height information in that zone
    @return True if successful, False `au contraire`
  -------------------------------------------------------------------------------}
function YGaTerrainManager.QueryHeightAt(MapId: UInt32; const X, Y: Float; out Z: Float): Boolean;
var
  pTile: PTileInfo;
  iX, iY: Int32;
begin
  pTile := GetTileInfoByCoords(MapId, X, Y);
  if pTile^.Data <> nil then
  begin
    iX := Floor32((pTile^.Data^.Borders.MaxX - X) * (1 / HEIGHT_POINT_DISTANCE));
    iY := Floor32((pTile^.Data^.Borders.MaxY - Y) * (1 / HEIGHT_POINT_DISTANCE));
    if iX > HEIGHT_RES - 1 then iX := HEIGHT_RES - 1 else if iX < 0 then iX := 0;
    if iY > HEIGHT_RES - 1 then iY := HEIGHT_RES - 1 else if iY < 0 then iY := 0;

    Z := pTile^.Data^.HeightData[iX, iY];
    Result := True;
  end else Result := False;
end;


  {*------------------------------------------------------------------------------
    Trying to query liquid informations at some coordinates on a given map ID
  
  
    @param iMapId The map where the liquid is tested
    @param fX 0X coordinate
    @param fY 0Y coordinate
    @param tLiqInfo the liquid information in that zone
    @return True if successful, False `au contraire`
  -------------------------------------------------------------------------------}
function YGaTerrainManager.QueryLiquidInfoAt(MapId: UInt32; const X, Y: Float;
  out LiquidInfo: YLiquidInfo): Boolean;
var
  pTile: PTileInfo;
  iX, iY: Int32;
  fTemp: Float;
begin
  pTile := GetTileInfoByCoords(MapId, X, Y);
  if pTile^.Data <> nil then
  begin
    iX := Floor32((pTile^.Data^.Borders.MaxX - X) * (1 / LIQUID_POINT_DISTANCE));
    iY := Floor32((pTile^.Data^.Borders.MaxY - Y) * (1 / LIQUID_POINT_DISTANCE));
    if iX > LIQUID_RES - 1 then iX := LIQUID_RES - 1 else if iX < 0 then iX := 0;
    if iY > LIQUID_RES - 1 then iY := LIQUID_RES - 1 else if iY < 0 then iY := 0;

    fTemp := pTile^.Data^.LiquidData[iX, iY];
    if not IsNan(fTemp) then
    begin
      LiquidInfo.Height := fTemp;
      LiquidInfo.Flags := pTile^.Data^.CellFlags[iX, iY];
      Result := True;
    end else Result := False;
  end else Result := False;
end;

  {*------------------------------------------------------------------------------
    Trying to query ZoneInfo at some coordinates on a given map ID
  
  
    @param iMapId The map where the zone is tested
    @param fX 0X coordinate
    @param fY 0Y coordinate
    @param tZnInfo the zone's information
    @return True if successful, False `au contraire`
  -------------------------------------------------------------------------------}
function YGaTerrainManager.QueryZoneInfoAt(MapId: UInt32; const X, Y: Float;
  out ZoneInfo: YZoneInfo): Boolean;
var
  pTile: PTileInfo;
  iX, iY: Int32;
begin
  pTile := GetTileInfoByCoords(MapId, X, Y);
  if pTile^.Data <> nil then
  begin
    iX := Floor32((pTile^.Data^.Borders.MaxX - X) * (1 / CELL_SIZE));
    iY := Floor32((pTile^.Data^.Borders.MaxY - Y) * (1 / CELL_SIZE));
    if iX > CELLS_PER_TILE - 1 then iX := CELLS_PER_TILE - 1 else if iX < 0 then iX := 0;
    if iY > CELLS_PER_TILE - 1 then iY := CELLS_PER_TILE - 1 else if iY < 0 then iY := 0;

    ZoneInfo.ZoneId := pTile^.Data^.ZoneIds[iX, iY];
    ZoneInfo.Level := pTile^.Data^.ZoneLevels[iX, iY];
    Result := True;
  end else Result := False;
end;


  {*------------------------------------------------------------------------------
    Trying to query PointInfo at some coordinates on a given map ID
  
  
    @param iMapId The map where the point is tested
    @param fX X coordinate
    @param fY Y coordinate
    @param tPtInfo the point's information
    @return True if successful, False `au contraire`
  -------------------------------------------------------------------------------}
function YGaTerrainManager.QueryPointInfoAt(MapId: UInt32; const X, Y: Float;
  out PointInfo: YPointInfo): Boolean;
var
  pTile: PTileInfo;
  iX, iY: Int32;
begin
  pTile := GetTileInfoByCoords(MapId, X, Y);
  if pTile^.Data <> nil then
  begin
    iX := Floor32((pTile^.Data^.Borders.MaxX - X) * (1 / HEIGHT_POINT_DISTANCE));
    iY := Floor32((pTile^.Data^.Borders.MaxY - Y) * (1 / HEIGHT_POINT_DISTANCE));
    if iX > HEIGHT_RES - 1 then iX := HEIGHT_RES - 1 else if iX < 0 then iX := 0;
    if iY > HEIGHT_RES - 1 then iY := HEIGHT_RES - 1 else if iY < 0 then iY := 0;

    PointInfo.Height := pTile^.Data^.HeightData[iX, iY];

    iX := Floor32((pTile^.Data^.Borders.MaxX - X) * (1 / LIQUID_POINT_DISTANCE));
    iY := Floor32((pTile^.Data^.Borders.MaxY - Y) * (1 / LIQUID_POINT_DISTANCE));
    if iX > LIQUID_RES - 1 then iX := LIQUID_RES - 1 else if iX < 0 then iX := 0;
    if iY > LIQUID_RES - 1 then iY := LIQUID_RES - 1 else if iY < 0 then iY := 0;

    PointInfo.LiquidInfo.Height := pTile^.Data^.LiquidData[iX, iY];
    PointInfo.LiquidInfo.Flags := pTile^.Data^.CellFlags[iX, iY];

    iX := Floor32((pTile^.Data^.Borders.MaxX - X) * (1 / CELL_SIZE));
    iY := Floor32((pTile^.Data^.Borders.MaxY - Y) * (1 / CELL_SIZE));
    if iX > CELLS_PER_TILE - 1 then iX := CELLS_PER_TILE - 1 else if iX < 0 then iX := 0;
    if iY > CELLS_PER_TILE - 1 then iY := CELLS_PER_TILE - 1 else if iY < 0 then iY := 0;

    PointInfo.AreaInfo.AreaId := pTile^.Data^.AreaIds[iX, iY];
    PointInfo.AreaInfo.Flags := pTile^.Data^.AreaFlags[iX, iY];

    PointInfo.ZoneInfo.ZoneId := pTile^.Data^.ZoneIds[iX, iY];
    PointInfo.ZoneInfo.Level := pTile^.Data^.ZoneLevels[iX, iY];

    Result := True;
  end else Result := False;
end;


  {*------------------------------------------------------------------------------
    Translates Coordinates to tile indices
    In-game coordinates are based on point (0, 0) which is located in the center of a map.
    The map has the maximum size of 64*64 tiles, each having size of 533.3333 feet.
    So all in all, the maximum/minimum coordinates are 32*533.3333 and -32*533.3333 for
    both axes. So if we are located at let's say coodinates (0, -19.34), you're in a tile
    with indexes [32, 33]. All we have to do is convert the input to the tile index
    which is not a problem at all.
  
    @param fX X coordinate
    @param fY Y coordinate
    @param iX X index
    @param iY Y index
  -------------------------------------------------------------------------------}
procedure YGaTerrainManager.TranslateCoordinatesToTileIndices(const X, Y: Float;
  out XIndex, YIndex: Int32);
begin
  XIndex := Floor32((ZERO_POINT - X) * (1 / TILE_SIZE));
  if XIndex < 0 then XIndex := 0;
  YIndex := Floor32((ZERO_POINT - Y) * (1 / TILE_SIZE));
  if YIndex < 0 then YIndex := 0;
end;

{$ENDREGION}

end.
