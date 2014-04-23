{*------------------------------------------------------------------------------
  Area. Derived from Abstract group.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.Area;

interface

uses
  Framework.Base,
  Components.Shared,
  Components.GameCore.WowMobile,
  Components.GameCore.WowPlayer,
  SysUtils,
  Bfg.Containers,
  Bfg.Geometry;

const
  AREA_SIZE = VIEW_DISTANCE * 3 { yards };
  MIN_CORNER_DIST = 0.7071678118654752440084436210485 * VIEW_DISTANCE { yards };
  { Neighbour identifiers }

type
  YNeighbourPosition = (npTop, npTopRight, npRight, npBottomRight, npBottom,
    npBottomLeft, npLeft, npTopLeft);

type
  YGaArea = class;

  PAreaEnum = ^YAreaEnum;
  YAreaEnum = record
    Areas: array[0..3] of YGaArea;
    Count: Int32;

    class operator Equal(const E1, E2: YAreaEnum): Boolean; inline;
  end;

  YGaArea = class(TObject)
    private
      fObjects: TArrayList;
      fPlayers: TArrayList;
      fMaxX: Int32;
      fMaxY: Int32;
      fMinX: Int32;
      fMinY: Int32;
      fNeighbours: array[YNeighbourPosition] of YGaArea;
      fX: Int32;
      fY: Int32;
      fPlayerCount: Int32;

      function GetNeighbour(iIndex: YNeighbourPosition): YGaArea; inline;
      procedure SetNeighbour(iIndex: YNeighbourPosition; cArea: YGaArea); inline;
      function GetObjectCount: Int32; inline;
      function GetObject(iIndex: Int32): YGaMobile; inline;
      function GetPlayer(iIndex: Int32): YGaPlayer; inline;
    public
      constructor Create; 
      destructor Destroy; override;

      procedure AddObject(cObject: YGaMobile);
      procedure RemoveObject(cObject: YGaMobile);

      procedure Initialize(iMaxX, iMaxY, iMinY, iMinX: Int32);
      procedure EnumNeighbouringAreas(const fX, fY: Float; out tData: YAreaEnum);

      property Neighbours[iIndex: YNeighbourPosition]: YGaArea read GetNeighbour write SetNeighbour;
      property X: Int32 read fX write fX;
      property Y: Int32 read fY write fY;
      property ObjectCount: Int32 read GetObjectCount;
      property PlayerCount: Int32 read fPlayerCount;
      property Objects[iIndex: Int32]: YGaMobile read GetObject;
      property Players[iIndex: Int32]: YGaPlayer read GetPlayer;
    end;

implementation

uses
  Cores,
  Components.GameCore.UpdateFields,
  Bfg.Utils;


constructor YGaArea.Create;
begin
  inherited Create;
  fObjects := TArrayList.Create(64, False);
  fPlayers := TArrayList.Create(32, False);
end;

destructor YGaArea.Destroy;
begin
  fObjects.Free;
  fPlayers.Free;
  inherited Destroy;
end;

procedure YGaArea.Initialize(iMaxX, iMaxY, iMinY, iMinX: Int32);
begin
  fMaxY := iMaxY;
  fMaxX := iMaxX;
  fMinY := iMinY;
  fMinX := iMinX;
end;

procedure YGaArea.AddObject(cObject: YGaMobile);
begin
  fObjects.Add(cObject);
  if cObject.InheritsFrom(YGaPlayer) then fPlayers.Add(cObject);
end;

procedure YGaArea.RemoveObject(cObject: YGaMobile);
begin
  {$IFOPT B-}
    {$DEFINE RESTORE_B}
    {$B+}
  {$ENDIF}
  if fObjects.Remove(cObject) and cObject.InheritsFrom(YGaPlayer) then fPlayers.Remove(cObject);
  {$IFDEF RESTORE_B}
    {$UNDEF RESTORE_B}
    {$B-}
  {$ENDIF}
end;

function GetDistanceFrom2DSq(const fX1, fY1, fX2, fY2: Float): Float;
begin
  Result := Abs(fX1*fX1+fY1*fY1 - fX2*fX2+fY2*fY2);
end;

procedure Zone00(const fX, fY: Float; cArea: YGaArea; pData: PAreaEnum);
begin
  pData^.Areas[1] := cArea.Neighbours[npBottom];
  pData^.Areas[2] := cArea.Neighbours[npLeft];

  if GetDistanceFrom2DSq(fX, fY, cArea.fMinX, cArea.fMinY) <= MIN_CORNER_DIST * MIN_CORNER_DIST then
  begin
    pData^.Areas[3] := cArea.Neighbours[npBottomLeft];
    pData^.Count := 4;
  end else pData^.Count := 3;
end;

procedure Zone10(const fX, fY: Float; cArea: YGaArea; pData: PAreaEnum);
begin
  pData^.Areas[1] := cArea.Neighbours[npBottom];
  pData^.Count := 2;
end;

procedure Zone20(const fX, fY: Float; cArea: YGaArea; pData: PAreaEnum);
begin
  pData^.Areas[1] := cArea.Neighbours[npBottom];
  pData^.Areas[2] := cArea.Neighbours[npRight];

  if GetDistanceFrom2DSq(fX, fY, cArea.fMaxX, cArea.fMinY) <= MIN_CORNER_DIST * MIN_CORNER_DIST then
  begin
    pData^.Areas[3] := cArea.Neighbours[npBottomRight];
    pData^.Count := 4;
  end else pData^.Count := 3;
end;

procedure Zone01(const fX, fY: Float; cArea: YGaArea; pData: PAreaEnum);
begin
  pData^.Areas[1] := cArea.Neighbours[npLeft];
  pData^.Count := 2;
end;

procedure Zone21(const fX, fY: Float; cArea: YGaArea; pData: PAreaEnum);
begin
  pData^.Areas[1] := cArea.Neighbours[npRight];
  pData^.Count := 2;
end;

procedure Zone02(const fX, fY: Float; cArea: YGaArea; pData: PAreaEnum);
begin
  pData^.Areas[1] := cArea.Neighbours[npTop];
  pData^.Areas[2] := cArea.Neighbours[npLeft];

  if GetDistanceFrom2DSq(fX, fY, cArea.fMinX, cArea.fMaxY) <= MIN_CORNER_DIST * MIN_CORNER_DIST then
  begin
    pData^.Areas[3] := cArea.Neighbours[npTopLeft];
    pData^.Count := 4;
  end else pData^.Count := 3;
end;

procedure Zone12(const fX, fY: Float; cArea: YGaArea; pData: PAreaEnum);
begin
  pData^.Areas[1] := cArea.Neighbours[npTop];
  pData^.Count := 2;
end;

procedure Zone22(const fX, fY: Float; cArea: YGaArea; pData: PAreaEnum);
begin
  pData^.Areas[1] := cArea.Neighbours[npTop];
  pData^.Areas[2] := cArea.Neighbours[npRight];
  
  if GetDistanceFrom2DSq(fX, fY, cArea.fMaxX, cArea.fMaxY) <= MIN_CORNER_DIST * MIN_CORNER_DIST then
  begin
    pData^.Areas[3] := cArea.Neighbours[npTopRight];
    pData^.Count := 4;
  end else pData^.Count := 3;
end;

procedure YGaArea.EnumNeighbouringAreas(const fX, fY: Float;
  out tData: YAreaEnum);
type
  YEnumProcedure = procedure(const fX, fY: Float; cArea: YGaArea; pData: PAreaEnum);
const
  { Used to determine which neighbours should get updates about this object }
  { This table depends on the formulae AREA_SIZE = VIEW_DISTANCE * 3 }
  Zones: array[0..2] of array[0..2] of YEnumProcedure = (
    (Zone00, Zone01, Zone02),
    (Zone10, nil, Zone12),
    (Zone20, Zone21, Zone22)
  );
var
  iX: UInt32;
  iY: UInt32;
  pProc: YEnumProcedure;
begin
  iX := Longword(Floor32(fX - fMinX)) div VIEW_DISTANCE;
  iY := Longword(Floor32(fY - fMinY)) div VIEW_DISTANCE;

  if iX > 2 then iX := 2;
  if iY > 2 then iY := 2;

  FillChar(tData, SizeOf(tData), 0); { Contains random data from start }
  tData.Count := 1;
  tData.Areas[0] := Self;
  pProc := @Zones[iX, iY];
  if Assigned(pProc) then pProc(fX, fY, Self, @tData);
end;

function YGaArea.GetNeighbour(iIndex: YNeighbourPosition): YGaArea;
begin
  Result := fNeighbours[iIndex];
end;

function YGaArea.GetObject(iIndex: Int32): YGaMobile;
begin
  Result := YGaMobile(fObjects[iIndex]);
end;

function YGaArea.GetObjectCount: Int32;
begin
  Result := fObjects.Size;
end;

function YGaArea.GetPlayer(iIndex: Int32): YGaPlayer;
begin
  Result := YGaPlayer(fPlayers[iIndex]);
end;

procedure YGaArea.SetNeighbour(iIndex: YNeighbourPosition; cArea: YGaArea);
begin
  fNeighbours[iIndex] := cArea;
end;

{ YAreaEnum }

class operator YAreaEnum.Equal(const E1, E2: YAreaEnum): Boolean;
begin
  if (E1.Count = E2.Count) and
     (E1.Areas[0] = E2.Areas[0]) and
     (E1.Areas[1] = E2.Areas[1]) and
     (E1.Areas[2] = E2.Areas[2]) then
  begin
    Result := True;
  end else Result := False;
end;

end.
