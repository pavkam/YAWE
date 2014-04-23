{*------------------------------------------------------------------------------
  Area manager.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
  @Changes TheSelby
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.AreaManager;

interface

uses
  Framework.Base,
  Components.NetworkCore.Packet,
  Components.Shared,
  Components.GameCore.WowMobile,
  Components.GameCore.Area,
  Misc.Geometry,
  Misc.Containers;

type
  YGaBaseAreaManager = class(TBaseObject)
    protected
      fMaxX: Int32;
      fMaxY: Int32;
      fMinX: Int32;
      fMinY: Int32;
      fAbsX: Integer;
      fAbsY: Integer;
      fMapId: Integer;

      procedure RealCoordinatesToAbsolute(var fX, fY: Float);

      function GetArea(iX, iY: UInt32): YGaArea; virtual; abstract;
    public
      procedure AssignMap(iMapId: UInt32); virtual; abstract;
      function CoordinatesToArea(fX, fY: Float): YGaArea;
      property Areas[iX, iY: UInt32]: YGaArea read GetArea;
  end;

  YGaAreaManager = class(YGaBaseAreaManager)
    private
      fAreas: Pointer;
      fAreaXCount: UInt32;
      fAreaYCount: UInt32;

      procedure AreaConstructorInvoke(Area: TObject);
      { These special allocation/deallocation routines are here because we want to
        create/destroy all areas very quickly - normal constructors/destructors are too slow }
      function InitAreas(iCount: Integer): Pointer;
      procedure FreeAreas(pAreas: Pointer);
    protected
      function GetArea(iX, iY: UInt32): YGaArea; override;
    public
      destructor Destroy; override;
      procedure AssignMap(iMapId: UInt32); override;
      function CheckObjectRellocation(cObject: YGaMobile; const tNewPos: TVector;
        const fAngle: Float; cPkt: YNwServerPacket): YGaArea;
  end;

  (*
  YGaDynamicAreaManager = class(YGaAreaManager)
    private
      const
        DYN_AREA_ALLOC_AMOUNT = 3;
        { For example you teleport to mapid X which is not defined as a constant
          map. You enter cell 0, 0 if you're the first one to port here. The cell
          with id 0, 0 will be created but also all areas DYN_AREA_ALLOC_AMOUNT
          away from this cell. That is cell 3, 3 to -3, -3. In total 48 extra cells
          around are created. The dynamic area managed should feature a primitive
          garbage collecting. Dynamic area manager may be used for instances also,
          maybe for instances a special derivate can be created, we'll see.
           }

      var
        fAreaMap: TIntHashMap;

      procedure AllocAndLinkAreas(cArea: YGaArea; iDistance: Int32);

      procedure EnsureAreaMapExists(iX: Int32);
      procedure AddAreaToCoords(cArea: YGaArea; iX, iY: Int32);

      function InternalCreateArea(iX, iY: Int32): YGaArea;
    protected
      function GetArea(iX, iY: UInt32): YGaArea; override;
    public
      constructor Create; override;
      destructor Destroy; override;
      procedure AssignMap(iMapId: Longword); override;
  end;
  *)

implementation

uses
  Framework,
  Cores,
  Math,
  SysUtils,
  Misc.Miscleanous;

var
  AREA_INST_SIZE: Longword;

{ YGaBaseAreaManager }

procedure YGaBaseAreaManager.RealCoordinatesToAbsolute(var fX, fY: Single);
begin
  fX := fX + Abs(fMinX);
  fY := fY + Abs(fMinY);
  { We convert physical coordinates into absolute ones.
    Eg. if our fMinX is -5000 and our x is 1000 then after
    conversion it would be 6000 (1000 + Abs(-5000)) }
end;

function YGaBaseAreaManager.CoordinatesToArea(fX, fY: Float): YGaArea;
var
  iX, iY: UInt32;
begin
  RealCoordinatesToAbsolute(fX, fY);
  iX := Ceil32(fX);
  iY := Ceil32(fY);

  iX := iX div AREA_SIZE;
  iY := iY div AREA_SIZE;

  Result := Areas[iX, iY];
end;

{ YGaAreaManager }

destructor YGaAreaManager.Destroy;
begin
  FreeAreas(fAreas);
  inherited Destroy;
end;

function YGaAreaManager.GetArea(iX, iY: UInt32): YGaArea;
begin
  Result := Pointer(Longword(fAreas) + (((iX * fAreaYCount) + iY) * Longword(AREA_INST_SIZE)));
end;

procedure YGaAreaManager.AreaConstructorInvoke(Area: TObject);
begin
  YGaArea(Area).Create;
end;

function YGaAreaManager.InitAreas(iCount: Integer): Pointer;
begin
  YGaArea.AllocateInstanceArrayEx(Result, iCount, AreaConstructorInvoke);
end;

procedure YGaAreaManager.FreeAreas(pAreas: Pointer);
begin
  YGaArea.FreeInstanceArray(pAreas, True);
end;

procedure YGaAreaManager.AssignMap(iMapId: UInt32);
type
  YMapBorders = record
    MaxX,
    MaxY,
    MinX,
    MinY: Int32;
  end;
const
  DefaultBorders: YMapBorders = (
    MaxX: 17088;
    MaxY: 17088;
    MinX: -17088;
    MinY: -17088;
    { 89*89 cell grid }
  );
var
  iX, iY: Integer;
  iCurrBoundsX, iCurrBoundsY: Integer;
  cArea: YGaArea;
  cNeighbour: YGaArea;
  tBorders: TRect;
begin
  fMapId := iMapId;

  if not DataCore.WorldData.TrGetMapBorders(iMapId, tBorders) then
  begin
    fMaxX := DefaultBorders.MaxX;
    fMaxY := DefaultBorders.MaxY;
    fMinX := DefaultBorders.MinX;
    fMinY := DefaultBorders.MinY;
  end else
  begin
    fMaxY := Integer(ForceAlignment(Ceil(tBorders.MaxY), AREA_SIZE)) + AREA_SIZE * 3;
    fMinX := Integer(ForceAlignment(Floor(tBorders.MinX), AREA_SIZE)) - AREA_SIZE * 4;
    fMinY := fMaxY - Integer(ForceAlignment(Round(Abs(tBorders.MaxY - tBorders.MinY)), AREA_SIZE)) - AREA_SIZE * 3;
    fMaxX := fMinX + Integer(ForceAlignment(Round(Abs(tBorders.MaxX - tBorders.MinX)), AREA_SIZE)) + AREA_SIZE * 3;
  end;

  fAbsX := Abs(fMinX) + Abs(fMaxX);
  fAbsY := Abs(fMinY) + Abs(fMaxY);
  fAreaXCount := (fAbsX div AREA_SIZE) + 1; { Create one extra }
  fAreaYCount := (fAbsY div AREA_SIZE) + 1; { Create one extra }
  fAreas := InitAreas(fAreaXCount * fAreaYCount);

  iCurrBoundsX := fMinX;
  iCurrBoundsY := fMinY;

  for iX := 0 to fAreaXCount -1 do
  begin
    for iY := 0 to fAreaYCount -1 do
    begin
      cArea := Areas[iX, iY];
      cArea.X := iX;
      cArea.Y := iY;
      cArea.Initialize(iCurrBoundsX + AREA_SIZE, iCurrBoundsY + AREA_SIZE,
        iCurrBoundsY, iCurrBoundsX); { Intialize area borders }

      { Assign pointers of each neighbour to all areas }
      if iY - 1 > -1 then
      begin
        cNeighbour := Areas[iX, iY - 1];
        cNeighbour.Neighbours[npTop] := cArea;
        cArea.Neighbours[npBottom] := cNeighbour;
      end;

      if iX - 1 > -1 then
      begin
        cNeighbour := Areas[iX - 1, iY];
        cNeighbour.Neighbours[npRight] := cArea;
        cArea.Neighbours[npLeft] := cNeighbour;
      end;

      if (iY - 1 > -1) and (iX - 1 > -1) then
      begin
        cNeighbour := Areas[iX - 1, iY - 1];
        cNeighbour.Neighbours[npTopRight] := cArea;
        cArea.Neighbours[npBottomLeft] := cNeighbour;
      end;

      if (iY + 1 < Integer(fAreaYCount)) and (iX - 1 > -1) then
      begin
        cNeighbour := Areas[iX - 1, iY + 1];
        cNeighbour.Neighbours[npBottomRight] := cArea;
        cArea.Neighbours[npTopLeft] := cNeighbour;
      end;

      Inc(iCurrBoundsY, AREA_SIZE);
    end;
    iCurrBoundsY := fMinY;
    Inc(iCurrBoundsX, AREA_SIZE);
  end;
end;

function YGaAreaManager.CheckObjectRellocation(cObject: YGaMobile; const tNewPos: TVector;
  const fAngle: Float; cPkt: YNwServerPacket): YGaArea;
var
  cOldArea, cNewArea: YGaArea;
  tNewAreas: YAreaEnum;
  iInt, iX: Int32;
  tOldPos: TVector;
begin
  tOldPos := cObject.Position.Vector;
  if (tOldPos.X <> tNewPos.X) or (tOldPos.Y <> tNewPos.Y) or (tOldPos.Z <> tNewPos.Z) then
  begin
    { We changed coordinates, not only angle }
    with tOldPos do
    begin
      cOldArea := Areas[cObject.Position.AreaX, cObject.Position.AreaY];
    end;

    with tNewPos do
    begin
      cNewArea := CoordinatesToArea(X, Y);
      cNewArea.EnumNeighbouringAreas(X, Y, tNewAreas);
    end;

    for iInt := 0 to tNewAreas.Count -1 do
    begin
      with tNewAreas.Areas[iInt] do
      begin
        for iX := 0 to ObjectCount -1 do
        begin
          if cObject = Objects[iX] then Continue;

          if not IsVectorDistanceWithin(tOldPos, Objects[iX].Position.Vector, VIEW_DISTANCE) and
             IsVectorDistanceWithin(tNewPos, Objects[iX].Position.Vector, VIEW_DISTANCE) then
          begin
            cObject.AddInRangeObject(Objects[iX]);
            Objects[iX].AddInRangeObject(cObject);
          end;
        end;
      end;
    end;

    if cOldArea <> cNewArea then
    begin
      { The object has moved beyond the borders of its cell }
      cOldArea.RemoveObject(cObject);
      cNewArea.AddObject(cObject);
      IoCore.Console.WritelnFmt('Object moved from area "X: %d, Y: %d" to area "X: %d, Y: %d".',
        [cOldArea.X, cOldArea.Y, cNewArea.X, cNewArea.Y]);
      Result := cNewArea;
    end else Result := nil;

    { Now we replace our old position vector by the new one }
    cObject.Position.Vector := tNewPos;
    cObject.Position.Angle := fAngle;
    cObject.PurgeInRangeObjects(VIEW_DISTANCE);
  end else
  begin
    cObject.Position.Angle := fAngle;
    Result := nil;
  end;
  if cPkt <> nil then
  begin
    cObject.SendPacketInRange(cPkt, VIEW_DISTANCE, False, True);
  end;
end;

(*

{ YDynamicAreaManager }

procedure YGaDynamicAreaManager.AddAreaToCoords(cArea: YGaArea; iX, iY: Int32);
begin
  TIntHashMap(fAreaMap.GetValue(iX)).PutValue(iY, cArea);
end;

procedure YGaDynamicAreaManager.AllocAndLinkAreas(cArea: YGaArea; iDistance: Int32);
begin

end;

procedure YGaDynamicAreaManager.AssignMap(iMapId: Longword);
begin

end;

procedure YGaDynamicAreaManager.EnsureAreaMapExists(iX: Int32);
var
  cMap: TIntHashMap;
begin
  if not fAreaMap.ContainsKey(iX) then
  begin
    cMap := TIntHashMap.Create(2 shl 13);
    fAreaMap.PutValue(iX, cMap);
  end;
end;

function YGaDynamicAreaManager.GetArea(iX, iY: UInt32): YGaArea;
var
  cMap: TIntHashMap;
begin
  cMap := TIntHashMap(fAreaMap.GetValue(iX));
  if cMap <> nil then
  begin
    Result := YGaArea(cMap.GetValue(iY));
    if Result = nil then Result := InternalCreateArea(iX, iY);
  end else Result := InternalCreateArea(iX, iY);
end;

function YGaDynamicAreaManager.InternalCreateArea(iX, iY: Int32): YGaArea;
begin
  Result := YGaArea.Create;
  Result.X := iX;
  Result.Y := iY;
  EnsureAreaMapExists(iX);
  AddAreaToCoords(Result, iX, iY);
  AllocAndLinkAreas(Result, DYN_AREA_ALLOC_AMOUNT);
end;

destructor YGaDynamicAreaManager.Destroy;
begin
  fAreaMap.Destroy;
  inherited Destroy;
end;

constructor YGaDynamicAreaManager.Create;
begin
  inherited Create;
  fAreaMap := TIntHashMap.Create(2 shl 13);
end;

*)

initialization
  AREA_INST_SIZE := YGaArea.InstanceSize;

end.
