{*------------------------------------------------------------------------------
  Basic object capable of movement.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
{$DEFINE DEBUG_SPLINE_MOVEMENT}
unit Components.GameCore.WowMobile;

interface

uses
  Misc.Containers,
  Misc.Geometry,
  Framework.Base,
  Framework.Tick,
  Components.NetworkCore.Packet,
  Components.Shared,
  Components.GameCore.Component,
  Components.GameCore.WowObject,
  Components.GameCore.Interfaces,
  Components.DataCore.Types;

(*
type
   PSplineValues = ^YSplineValues;
   YSplineValues = record
     A, B, C, D,
     E, F, G, H: Float;
     XChanged: Boolean;               { Has the X coordinate changed? }
     YChanged: Boolean;               { Has the Y coordinate changed? }
     Z: Float;                        { Temporary }
     Angle: Float;                    { Temporary }
   end;

   PSplineData = ^YSplineData;
   YSplineData = record
     UpdateHandle: YHandle;           { Tick manager's handle }
     Source: YPositionVector;         { Source vector }
     Destination: YPositionVector;    { Destination vector }
     SplinePoint: YPositionVector;    { Coordinates of the last calculated spline point }
     SplineValues: YSplineValues;     { Values used for coordinate calculation }
     CurrentPart: Int32;              { Parts of the spline traversed so far }
     Velocity: Float;                 { Object's velocity }
     Flags: UInt32;                   { Flags which came with the original packet }
     IsMultiPath: Boolean;            { First move or n-th move? }
     IsMoving: Boolean;               { Have we stopped? }
   end;

const
  SPLINE_TRAVEL_PARTS  = 5;  { travel 1/5 of the spline per MOVEMENT_UPDATE_TIME }
  SPLINE_TIME_PER_PART = 1.0 / SPLINE_TRAVEL_PARTS;
*)

type
  YGaMobile = class;
  YGaMobileComponent = class;
  YGaPositionMgr = class;
  YGaMobileArray = array of YGaMobile;

  YUpdateRequest = (urAdd, urRemove, urValueUpdate, urStateUpdate);

  { This class is an ancestor for every object, which can change coordinates on a map }
  YGaMobile = class(YGaWowObject, IObject, IMobile)
    private
      fPositionManager: YGaPositionMgr;
      //fSplineData: YSplineData;
    protected
      fInRangeObjects: YGaMobileArray;
      fInRangePlayers: YGaMobileArray;

      function MatchByRangeApprox(RangeSq: Int32; Obj: YGaMobile): Int32;
      function CompareByRangeApprox(Obj1, Obj2: YGaMobile): Int32;

      function GetRngIndex(const Range: Float): Int32; inline;
      function GetRngPlayerIndex(const Range: Float): Int32; inline;

      procedure ExtractObjectData(cEntry: YDbSerializable); override;
      procedure CleanupObjectData; override;
      procedure InjectObjectData(cEntry: YDbSerializable); override;
      
      procedure EnterWorld; override;
      procedure LeaveWorld; override;

      function GetRngSqIndex(const RangeSq: Float; const aArr: YGaMobileArray): Int32; 

      procedure RequestUpdatesFromObject(Obj: YGaMobile; Request: YUpdateRequest); virtual;
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure AddInRangeObject(cMob: YGaMobile);
      procedure RemoveInRangeObject(cMob: YGaMobile);

      procedure PurgeInRangeObjects(const Range: Float);
      procedure ClearInRangeObjects;

      procedure SendPacketInRange(Pkt: YNwServerPacket; const Range: Float;
        IncludeSelf: Boolean; OnlyVisible: Boolean);

      procedure SendPacketSetInRange(const PktArr: array of YNwServerPacket;
        const Range: Float; IncludeSelf: Boolean; OnlyVisible: Boolean);

      function CanSee(cMob: YGaMobile): Boolean; virtual;

      procedure OnValuesUpdate; override;

      function GetPosition: IPosition;
      //function OnUpdateMovement: Boolean; virtual;
      //procedure UpdateMovementData(pNewVector: PPositionVector; bBackward: Boolean;
      //  lwFlags: UInt32);
      //procedure StopMovement;
      property Position: YGaPositionMgr read fPositionManager;
  end;

  YGaMobileComponent = class(YGaObjectComponent)
    private
      fOwner: YGaMobile;
    public
      constructor Create(cOwner: YGaMobile); reintroduce;
      property Owner: YGaMobile read fOwner;
  end;

  YGaPositionMgr = class(YGaMobileComponent)
    private
      fVec: TVector;
      fAngle: Float;
      fXApprox: Int32;
      fYApprox: Int32;
      fZApprox: Int32;
      fMap: UInt32;
      fZone: UInt32;
      fWalkSpeed: Float;
      fRunSpeed: Float;
      fBackSwimSpeed: Float;
      fSwimSpeed: Float;
      fBackWalkSpeed: Float;
      fTurnRate: Float;
      fAreaGridX: UInt32;
      fAreaGridY: UInt32;

      procedure SetSpeedBackSwim(const Value: Float); inline;
      procedure SetSpeedBackWalk(const Value: Float); inline;
      procedure SetSpeedRun(const Value: Float); inline;
      procedure SetSpeedSwim(const Value: Float); inline;
      procedure SetSpeedTurnRate(const Value: Float); inline;
      procedure SetSpeedWalk(const Value: Float); inline;

      procedure SetMapId(const Value: UInt32); inline;
      procedure SetAngle(const Value: Float); inline;
      procedure SetX(const Value: Float); inline;
      procedure SetY(const Value: Float); inline;
      procedure SetZ(const Value: Float); inline;
      procedure SetZoneId(const Value: UInt32); inline;
      procedure SetVector(const Vec: TVector); inline;

      function GetX: Single;
      function GetY: Single;
      function GetZ: Single;
      function GetAngle: Single;
      function GetMapId: Longword;
      function GetZoneId: Longword;

      procedure SetAreaGridX(val: UInt32);
    public
      procedure ExtractObjectData(cEntry: YDbSerializable); override;
      procedure InjectObjectData(cEntry: YDbSerializable); override;
      procedure CleanupObjectData; override;
      
      //procedure GetCurrentPosition(var tPos: YWorldPosition);
      procedure DoTeleport(iMap: UInt32; const fX, fY, fZ: Float);

      property X: Float read fVec.X write SetX;
      property Y: Float read fVec.Y write SetY;
      property Z: Float read fVec.Z write SetZ;

      property ApproxX: Int32 read fXApprox;
      property ApproxY: Int32 read fYApprox;
      property ApproxZ: Int32 read fZApprox;

      property Angle: Float read fAngle write SetAngle;
      property MapId: UInt32 read fMap write SetMapId;
      property ZoneId: UInt32 read fZone write SetZoneId;
      property Vector: TVector read fVec write SetVector;

      property WalkSpeed: Float read fWalkSpeed write SetSpeedWalk;
      property RunSpeed: Float read fRunSpeed write SetSpeedRun;
      property BackSwimSpeed: Float read fBackSwimSpeed write SetSpeedBackSwim;
      property SwimSpeed: Float read fSwimSpeed write SetSpeedSwim;
      property BackWalkSpeed: Float read fBackWalkSpeed write SetSpeedBackWalk;
      property TurnRate: Float read fTurnRate write SetSpeedTurnRate;

      property AreaX: UInt32 read fAreaGridX write SetAreaGridX;//fAreaGridX;
      property AreaY: UInt32 read fAreaGridY write fAreaGridY;
    end;

implementation

uses
  SysUtils,
  Framework,
  Cores,
  Math,
  Misc.Miscleanous,
  Misc.Algorithm,
  Components.NetworkCore.Opcodes,
  Components.GameCore.Area,
  Components.GameCore.WowPlayer,
  Components.GameCore.UpdateFields,
  Components.GameCore.PacketBuilders;

(*
{ ResizeVector does what the name states - resizes a vector. It changes pDestVector so that
  the new distance between src-dest is fFactor*old_distance. }
procedure ResizeVector(pStartVector, pDestVector: PPositionVector; const fFactor: Float); experimental;
begin
  pDestVector^.X := pStartVector^.X + ((pDestVector^.X - pStartVector^.X) * fFactor);
  pDestVector^.Y := pStartVector^.Y + ((pDestVector^.Y - pStartVector^.Y) * fFactor);
end;

function GetMovementTime(pStartVector, pDestVector: PPositionVector; const fVelocity: Float): Float; experimental;
begin
  Result := 0;//GetDistanceFrom2D(pStartVector^.X, pStartVector^.Y, pDestVector^.X, pDestVector^.Y) / fVelocity;
end;

function AngleFromPositionDifference(pStartVector, pEndVector: PPositionVector): Float; experimental;
begin
  Result := ArcTan2(pEndVector^.Y - pStartVector^.Y, pEndVector^.X - pStartVector^.X);
end;

{ SinCos routine from the Math.pas unit, changed to work with Single instead of Extended. }
procedure SinCos(const fTheta: Float; var fSin, fCos: Float);
asm
  FLD     fTheta
  FSINCOS
  FSTP    DWORD PTR [EDX]
  FSTP    DWORD PTR [EAX]
  FWAIT
end;

{ CreateCubicSplineData prepares the YSplineData structure for subsequent
  calls to CalculateCubicSpline - this is needed, because the creation of
  the cubic spline is quite expensive. }
procedure CreateCubicSplineData(pStartVector, pEndVector: PPositionVector;
  const fVelocity: Single; pOutData: PSplineValues); experimental;
var
  fStartXVel, fStartYVel, fEndXVel, fEndYVel: Single;
  fTemp, fTemp2, fTemp3: Single;
begin
  pOutData.XChanged := pStartVector^.X <> pEndVector^.X;
  pOutData.YChanged := pStartVector^.Y <> pEndVector^.Y;
  if pStartVector^.Angle <> pEndVector^.Angle then
  begin
    { This won't happen as often }
    SinCos(pStartVector^.Angle, fTemp2, fTemp);
    fStartXVel := pStartVector^.X + (fTemp * fVelocity);
    fStartYVel := pStartVector^.Y + (fTemp2 * fVelocity);

    SinCos(pEndVector^.Angle, fTemp2, fTemp);
    fEndXVel := pEndVector^.X - (fTemp * fVelocity);
    fEndYVel := pEndVector^.Y - (fTemp2 * fVelocity);
  end else
  begin
    { A faster option }
    SinCos(pEndVector^.Angle, fTemp2, fTemp);
    fTemp := fTemp * fVelocity;
    fTemp2 := fTemp2 * fVelocity;

    fStartXVel := pStartVector^.X + fTemp;
    fStartYVel := pStartVector^.Y + fTemp2;
    fEndXVel := pEndVector^.X - fTemp;
    fEndYVel := pEndVector^.Y - fTemp2;
  end;

  pOutData^.Angle := pEndVector^.Angle;
  pOutData^.Z := pEndVector^.Z;

  with pOutData^ do
  begin
    if XChanged then
    begin
      fTemp := 3 * fEndXVel;
      fTemp2 := 3 * pStartVector^.X;
      fTemp3 := 3 * fStartXVel;

      A := pEndVector^.X - fTemp + fTemp3 - pStartVector^.X;
      B := fTemp - (fTemp3 * 2) + fTemp2;
      C := fTemp3 - fTemp2;
    end;
    D := pStartVector^.X;

    if YChanged then
    begin
      fTemp := 3 * fEndYVel;
      fTemp2 := 3 * pStartVector^.Y;
      fTemp3 := 3 * fStartYVel;
    
      E := pEndVector^.Y - fTemp + fTemp3 - pStartVector^.Y;
      F := fTemp - (fTemp3 * 2) + fTemp2;
      G := fTemp3 - fTemp2;
    end;
    H := pStartVector^.Y;
  end;
end;

{ CalculateCubicSpline is used to create smooth travelling paths to prevent movement lag }
procedure CalculateCubicSpline(pSourceData: PSplineValues; const fTime: Float;
  pOutVector: PPositionVector); experimental;
var
  fTemp: Float;
begin
  fTemp := fTime * fTime;

  with pSourceData^ do
  begin
    if XChanged then
    begin
      pOutVector^.X := (fTime * ((A * fTemp) + (B * fTime) + C)) + D;
    end else pOutVector^.X := D;

    if YChanged then
    begin
      pOutVector^.Y := (fTime * ((E * fTemp) + (F * fTime) + G)) + H;
    end else pOutVector^.Y := H;

    pOutVector^.Z := Z;
    pOutVector^.Angle := Angle;
  end;
end;
*)

function IntVectorDistSq(Obj1, Obj2: YGaMobile): Int32; inline;
var
  X, Y, Z: Int32;
begin
  X := Obj1.Position.ApproxX - Obj2.Position.ApproxX;
  Y := Obj1.Position.ApproxY - Obj2.Position.ApproxY;
  Z := Obj1.Position.ApproxZ - Obj2.Position.ApproxZ;
  Result := X * X + Y * Y + Z * Z;
end;

{ YGaMobile }

function YGaMobile.MatchByRangeApprox(RangeSq: Int32; Obj: YGaMobile): Int32;
begin
  Result := RangeSq - IntVectorDistSq(Obj, Self);
end;

function YGaMobile.CompareByRangeApprox(Obj1, Obj2: YGaMobile): Int32;
begin
  Result := IntVectorDistSq(Self, Obj1) - IntVectorDistSq(Self, Obj2);
  if Result = 0 then
  begin
    Result := Int32(UInt32(Obj1) - UInt32(Obj2));
  end;
end;

procedure YGaMobile.CleanupObjectData;
begin
  inherited CleanupObjectData;
  fPositionManager.CleanupObjectData;
end;

procedure YGaMobile.EnterWorld;
var
  cArea: YGaArea;
  iInt: Int32;
begin
  inherited EnterWorld;
  cArea := GameCore.GetArea(Position.MapId, Position.X, Position.Y);
  Position.AreaX := cArea.X;
  Position.AreaY := cArea.Y;
  for iInt := 0 to cArea.ObjectCount -1 do
  begin
    if IsVectorDistanceWithin(Position.Vector, cArea.Objects[iInt].Position.Vector, VIEW_DISTANCE) and CanSee(cArea.Objects[iInt]) then
    begin
      AddInRangeObject(cArea.Objects[iInt]);
      cArea.Objects[iInt].AddInRangeObject(Self);
    end;
  end;
  cArea.AddObject(Self);
end;

procedure YGaMobile.LeaveWorld;
var
  cArea: YGaArea;
  iInt: Int32;
begin
  for iInt := 0 to High(fInRangeObjects) do
  begin
    fInRangeObjects[iInt].RemoveInRangeObject(Self);
  end;
  cArea := GameCore.Areas[Position.MapId, Position.AreaX, Position.AreaY];
  cArea.RemoveObject(Self);
  ClearInRangeObjects;
  inherited LeaveWorld;
end;

procedure YGaMobile.ExtractObjectData(cEntry: YDbSerializable);
begin
  inherited ExtractObjectData(cEntry);
  fPositionManager.ExtractObjectData(cEntry);
end;

function YGaMobile.GetPosition: IPosition;
begin
  Result := fPositionManager as IPosition;
end;

procedure YGaMobile.InjectObjectData(cEntry: YDbSerializable);
begin
  inherited InjectObjectData(cEntry);
  fPositionManager.InjectObjectData(cEntry);
end;

function YGaMobile.GetRngSqIndex(const RangeSq: Float; const aArr: YGaMobileArray): Int32;
var
  ApproxRangeSq: Int32;
begin
  { We get the approximation, rounded down }
  ApproxRangeSq := Floor32(RangeSq);
  { Now we'll look for the first object which has distance approximation greater than ApproxRangeSq }
  Result := BinarySearchLesserOrEqual(Pointer(ApproxRangeSq), @aArr[0],
    Length(aArr), TPointerCompareEx(MakeMethod(@YGaMobile.MatchByRangeApprox, Self)));
  { We must perform a few (99% only 1) more precise FP comparisons since approximations
    may cause some objects not to be included even if they are in range. Unless
    all or none objects are in range we check the next entry if it has distance
    less than RangeSq. If it has, we continue checking until we reach end of the list
    or we wncounter an object which is out of range. Since the list is sorted,
    all objects after the first out of range object are also out of range, so we
    may safely ignore them }
  if (Result > -1) and (Result <> High(aArr)) then
  begin
    while (VectorDistanceSq(aArr[Result].Position.Vector, Position.Vector) <= RangeSq) and
          (Result < High(aArr)) do
    begin
      Inc(Result);
    end;
  end;
end;

function YGaMobile.GetRngIndex(const Range: Single): Int32;
begin
  Result := GetRngSqIndex(Range * Range, fInRangeObjects);
end;

function YGaMobile.GetRngPlayerIndex(const Range: Float): Int32;
begin
  Result := GetRngSqIndex(Range * Range, fInRangePlayers);
end;

procedure YGaMobile.AddInRangeObject(cMob: YGaMobile);
var
  I: Int32;
begin
  I := Length(fInRangeObjects);
  SetLength(fInRangeObjects, I + 1);
  fInRangeObjects[I] := cMob;
  SortArray(@fInRangeObjects[0], I + 1, TPointerCompareEx(MakeMethod(
    @YGaMobile.CompareByRangeApprox, Self)), shSorted);
  if cMob.InheritsFrom(YGaPlayer) then
  begin
    I := Length(fInRangePlayers);
    SetLength(fInRangePlayers, I + 1);
    fInRangePlayers[I] := YGaPlayer(cMob);
    SortArray(@fInRangePlayers[0], I + 1, TPointerCompareEx(MakeMethod(
      @YGaMobile.CompareByRangeApprox, Self)), shSorted);
  end;
  RequestUpdatesFromObject(cMob, urAdd);
end;

procedure YGaMobile.RemoveInRangeObject(cMob: YGaMobile);
var
  I, J: Int32;
begin
  I := BinarySearch(cMob, @fInRangeObjects[0], Length(fInRangeObjects),
    TPointerCompareEx(MakeMethod(@YGaMobile.CompareByRangeApprox, Self)));
  if I > -1 then
  begin
    J := High(fInRangeObjects);
    if I < J then
    begin
      Move(fInRangeObjects[I+1], fInRangeObjects[I], SizeOf(YGaMobile) * (J - I));
      SetLength(fInRangeObjects, J);
    end;
  end;

  if cMob.InheritsFrom(YGaPlayer) then
  begin
    I := BinarySearch(cMob, @fInRangePlayers[0], Length(fInRangePlayers),
      TPointerCompareEx(MakeMethod(@YGaMobile.CompareByRangeApprox, Self)));
    if I > -1 then
    begin
      J := High(fInRangePlayers);
      if I < J then
      begin
        Move(fInRangePlayers[I+1], fInRangePlayers[I], SizeOf(YGaPlayer) * (J - I));
        SetLength(fInRangePlayers, J);
      end;
    end;
  end;

  RequestUpdatesFromObject(cMob, urRemove);
end;

procedure YGaMobile.RequestUpdatesFromObject(Obj: YGaMobile; Request: YUpdateRequest);
begin
  { Nothing }
end;

procedure YGaMobile.PurgeInRangeObjects(const Range: Float);
var
  I, J: Int32;
  RngSq: Float;
begin
  RngSq := Range * Range;
  
  I := GetRngSqIndex(RngSq, fInRangeObjects);
  if I < High(fInRangeObjects) then
  begin
    Inc(I);
    for J := I to High(fInRangeObjects) do
    begin
      RequestUpdatesFromObject(fInRangeObjects[J], urRemove);
      fInRangeObjects[J].RequestUpdatesFromObject(Self, urRemove);
    end;
    SetLength(fInRangeObjects, I);
  end;
  
  I := GetRngSqIndex(RngSq, YGaMobileArray(fInRangePlayers));
  if I < High(fInRangePlayers) then
  begin
    SetLength(fInRangePlayers, I + 1);
  end;
end;

procedure YGaMobile.ClearInRangeObjects;
begin
  fInRangeObjects := nil;
end;

procedure YGaMobile.SendPacketInRange(Pkt: YNwServerPacket;
  const Range: Float; IncludeSelf, OnlyVisible: Boolean);
var
  iLast: Int32;
begin
  Assert(Sign(Range) <> -1);
  iLast := GetRngPlayerIndex(Range);
  if OnlyVisible then
  begin
    while iLast > -1 do
    begin
      if fInRangePlayers[iLast].CanSee(Self) then
      begin
        YGaPlayer(fInRangePlayers[iLast]).Session.SendPacket(Pkt);
      end;
      Dec(iLast);
    end;
  end else
  begin
    while iLast > -1 do
    begin
      YGaPlayer(fInRangePlayers[iLast]).Session.SendPacket(Pkt);
      Dec(iLast);
    end;
  end;

  if IncludeSelf and Self.InheritsFrom(YGaPlayer) then
  begin
    YGaPlayer(Self).Session.SendPacket(Pkt);
  end;
end;

procedure YGaMobile.SendPacketSetInRange(const PktArr: array of YNwServerPacket;
  const Range: Float; IncludeSelf, OnlyVisible: Boolean);
var
  iLast: Int32;
  iI: Int32;
begin
  Assert(Sign(Range) <> -1);
  iLast := GetRngPlayerIndex(Range);
  if OnlyVisible then
  begin
    while iLast > -1 do
    begin
      if fInRangePlayers[iLast].CanSee(Self) then
      begin
        for iI := 0 to High(PktArr) do
        begin
          YGaPlayer(fInRangePlayers[iLast]).Session.SendPacket(PktArr[iI]);
        end;
      end;
      Dec(iLast);
    end;
  end else
  begin
    while iLast > -1 do
    begin
      for iI := 0 to High(PktArr) do
      begin
        YGaPlayer(fInRangePlayers[iLast]).Session.SendPacket(PktArr[iI]);
      end;
      Dec(iLast);
    end;
  end;

  if IncludeSelf and Self.InheritsFrom(YGaPlayer) then
  begin
    for iI := 0 to High(PktArr) do
    begin
      YGaPlayer(Self).Session.SendPacket(PktArr[iI]);
    end;
  end;
end;

function YGaMobile.CanSee(cMob: YGaMobile): Boolean;
begin
  Result := True;
end;

procedure YGaMobile.OnValuesUpdate;
var
  I: Int32;
  UpdPacket: YNwServerPacket;
begin
  UpdPacket := YNwServerPacket.Create;
  try
    FillObjectUpdatePacket(UpdPacket, False);
    I := Length(fInRangePlayers);
    if I <> 0 then
    begin
      Dec(I);
      while I <> -1 do
      begin
        YGaPlayer(fInRangePlayers[I]).AddUpdateBlock(UpdPacket);
        Dec(I);
      end;
    end;
  finally
    UpdPacket.Free;
  end;
end;

(*
function YGaMobile.OnUpdateMovement: Boolean;
const
  MOVE_FLAG_STOP         = $00000000;
  MOVE_FLAG_FORWARD      = $00000001;
  MOVE_FLAG_BACKWARD     = $00000002;
  MOVE_FLAG_TURN_LEFT    = $00000010;
  MOVE_FLAG_TURN_RIGHT   = $00000020;
  MOVE_FLAG_STRAFE_LEFT  = $00000100;
  MOVE_FLAG_STRAFE_RIGHT = $00000200;
  MOVE_FLAG_UNK1         = $00001000;
  MOVE_FLAG_JUMP         = $00002000;
  MOVE_FLAG_FALL         = $00004000;
  MOVE_FLAG_UNK2         = $04000000;
var
  cOutPkt: YNwServerPacket;
  tPreviousSplinePoint: YPositionVector;
begin
  if InWorld and fSplineData.IsMoving then
  begin
    Inc(fSplineData.CurrentPart);
    if fSplineData.CurrentPart > SPLINE_TRAVEL_PARTS then
    begin
      { We've reached the end of our spline (a long lag, huh?). To continue generating
        movement packets, we must scale our previous destination vector by a factor.
        Then we'll create new spline parameters using our current position (spline point)
        and this new scaled vector and proceed as normal. }
      ResizeVector(@fSplineData.Source, @fSplineData.Destination, 2.0);
      Move(fSplineData.SplinePoint, fSplineData.Source, SizeOf(YPositionVector));
      {$IFDEF DEBUG_SPLINE_MOVEMENT}
      OutputToLog('Splines.txt', 'Prolonged spline. '  + #13#10 + 'Start point: '
        + FloatToStr(fSplineData.SplinePoint.X) + ', ' + FloatToStr(fSplineData.SplinePoint.Y) +
        #13#10 + 'End point: ' + FloatToStr(fSplineData.Destination.X) + ', ' +
        FloatToStr(fSplineData.Destination.Y), False);
      {$ENDIF}
      CreateCubicSplineData(@fSplineData.Source, @fSplineData.Destination,
        fSplineData.Velocity, @fSplineData.SplineValues);
      fSplineData.CurrentPart := 1;
    end;
    { We'll just calculate the coordinates on the spline using stored values. }
    //if (fSplineData.CurrentPart mod 2) = 1 then
    //begin
      Move(fSplineData.SplinePoint, tPreviousSplinePoint, SizeOf(YPositionVector));
      CalculateCubicSpline(@fSplineData.SplineValues,
        SPLINE_TIME_PER_PART * fSplineData.CurrentPart, @fSplineData.SplinePoint);

      cOutPkt := YNwServerPacket.Initialize(MSG_MOVE_HEARTBEAT);
      cOutPkt.AddPackedGUID(GUID);
      cOutPkt.AddUInt32(fSplineData.Flags);
      cOutPkt.AddUInt32(GetCurrentTime + Trunc(GetMovementTime(@tPreviousSplinePoint,
        @fSplineData.SplinePoint, fSplineData.Velocity) * 1000));
      cOutPkt.AddStruct(fSplineData.SplinePoint, SizeOf(YPositionVector));
      GameCore.BroadcastPacketInRange(cOutPkt, Self, False, True);
    //end else
    //begin
    //  CalculateCubicSpline(@fSplineData.SplineValues,
    //    SPLINE_TIME_PER_PART * fSplineData.CurrentPart, @fSplineData.SplinePoint);
    //end;
    {$IFDEF DEBUG_SPLINE_MOVEMENT}
    OutputToLog('Splines.txt', 'New spline point: ' + FloatToStr(fSplineData.SplinePoint.X) +
      ', ' + FloatToStr(fSplineData.SplinePoint.Y), False);
    {$ENDIF}
  end;
  Result := True;
end;
*)

constructor YGaMobile.Create;
begin
  inherited Create;
  fPositionManager := YGaPositionMgr.Create(Self);
end;

destructor YGaMobile.Destroy;
begin
  fPositionManager.Free;
  inherited Destroy;
end;

(*
procedure YGaMobile.StopMovement;
begin
  FillChar(fSplineData, SizeOf(YSplineData), 0);
  Move(fPositionManager.Vector, fSplineData.SplinePoint, SizeOf(YPositionVector));
end;
*)

(*
{$IFDEF DEBUG_SPLINE_MOVEMENT}
procedure ReportSpline(pData: PSplineData);
begin
  OutputToLog('Splines.txt',
    'Created a new spline.' + #13#10 + 'Start point: ' + FloatToStr(pData^.Source.X) + ', ' +
    FloatToStr(pData^.Source.Y) + #13#10 + 'End point: ' + FloatToStr(pData^.Destination.X) +
    ', ' + FloatToStr(pData^.Destination.Y), False);
end;
{$ENDIF}

procedure YGaMobile.UpdateMovementData(pNewVector: PPositionVector; bBackward: Boolean;
  lwFlags: UInt32);
const
  VELOCITY_TABLE: array[Boolean] of Float = (7.0, 2.5);  { Temporary }
  procedure SplineDataUpdate;
  //var
    //tUpdateInfo: YSubscriberInfo;
  begin
    fSplineData.Velocity := VELOCITY_TABLE[bBackward];
    { We set the current velocity, }
    Move(fSplineData.SplinePoint, fSplineData.Source, SizeOf(YPositionVector));
    { move the previous spline point into source (if this is the first movement packet
      then spline point is object's current position), }
    Move(pNewVector^, fSplineData.Destination, SizeOf(YPositionVector));
    { move the new vector into destination }
    CreateCubicSplineData(@fSplineData.Source, @fSplineData.Destination, fSplineData.Velocity,
      @fSplineData.SplineValues);
    { and calculate the cubic spline. }
    fSplineData.CurrentPart := 0;
    fSplineData.Flags := lwFlags;
    fSplineData.IsMoving := True;
    {$IFDEF DEBUG_SPLINE_MOVEMENT}
    ReportSpline(@fSplineData); { Debug }
    {$ENDIF}
    //SystemTimer.GetSubscriberInfo(fSplineData.UpdateHandle, tUpdateInfo);
    //tUpdateInfo.FireTime := 50;
    { We must change the subscriber info so that 2 events won't be fired one after another. }
    OnUpdateMovement;
  end;
begin
  if fSplineData.IsMultiPath then
  begin
    SplineDataUpdate;
  end else if not CompareMem(pNewVector, @fSplineData.SplinePoint, SizeOf(YPositionVector)) then
  begin
    fSplineData.IsMultiPath := True;
    SplineDataUpdate;
  end;
end;
*)

{ YMobileComponent }

constructor YGaMobileComponent.Create(cOwner: YGaMobile);
begin
  fOwner := cOwner;
end;

{ YPositionMgr }

procedure YGaPositionMgr.CleanupObjectData;
begin
end;

procedure YGaPositionMgr.ExtractObjectData(cEntry: YDbSerializable);
var
  cMoveable: YDbMoveableEntry;
begin
  cMoveable := YDbMoveableEntry(cEntry);
  X := cMoveable.PosX;
  Y := cMoveable.PosY;
  Z := cMoveable.PosZ;
  Angle := cMoveable.Angle;
  ZoneId := cMoveable.ZoneId;
  MapId := cMoveable.MapId;
  WalkSpeed := cMoveable.SpeedWalk;
  RunSpeed := cMoveable.SpeedRun;
  SwimSpeed := cMoveable.SpeedSwim;
  BackWalkSpeed := cMoveable.SpeedBackwardWalk;
  BackSwimSpeed := cMoveable.SpeedBackwardSwim;
  TurnRate := cMoveable.SpeedTurn;
end;
  
procedure YGaPositionMgr.InjectObjectData(cEntry: YDbSerializable);
var
  cMoveable: YDbMoveableEntry;
begin
  cMoveable := YDbMoveableEntry(cEntry);
  cMoveable.PosX := X;
  cMoveable.PosY := Y;
  cMoveable.PosZ := Z;
  cMoveable.Angle := Angle;
  cMoveable.ZoneId := ZoneId;
  cMoveable.MapId := MapId;
  cMoveable.SpeedWalk := WalkSpeed;
  cMoveable.SpeedRun := RunSpeed;
  cMoveable.SpeedSwim := SwimSpeed;
  cMoveable.SpeedBackwardWalk := BackWalkSpeed;
  cMoveable.SpeedBackwardSwim := BackSwimSpeed;
  cMoveable.SpeedTurn := TurnRate;
end;

procedure YGaPositionMgr.SetMapId(const Value: UInt32);
begin
  fMap := Value;
end;

procedure YGaPositionMgr.SetAngle(const Value: Float);
begin
  fAngle := Value;
end;

procedure YGaPositionMgr.SetAreaGridX(val: UInt32);
begin
  fAreaGridX := Val;
end;

procedure YGaPositionMgr.SetX(const Value: Float);
begin
  fVec.X := Value;
  fXApprox := Floor32(Value);
end;

procedure YGaPositionMgr.SetY(const Value: Float);
begin
  fVec.Y := Value;
  fYApprox := Floor32(Value);
end;

procedure YGaPositionMgr.SetZ(const Value: Float);
begin
  fVec.Z := Value;
  fZApprox := Floor32(Value);
end;

procedure YGaPositionMgr.SetSpeedBackSwim(const Value: Float);
begin
  fBackSwimSpeed := Value;
end;

procedure YGaPositionMgr.SetSpeedBackWalk(const Value: Float);
begin
  fBackWalkSpeed := Value;
end;

procedure YGaPositionMgr.SetSpeedRun(const Value: Float);
begin
  fRunSpeed := Value;
end;

procedure YGaPositionMgr.SetSpeedSwim(const Value: Float);
begin
  fSwimSpeed := Value;
end;

procedure YGaPositionMgr.SetSpeedTurnRate(const Value: Float);
begin
  fTurnRate := Value;
end;

procedure YGaPositionMgr.SetSpeedWalk(const Value: Float);
begin
  fWalkSpeed := Value;
end;

procedure YGaPositionMgr.SetVector(const Vec: TVector);
begin
  fVec := Vec;
  fXApprox := Floor32(Vec.X);
  fYApprox := Floor32(Vec.Y);
  fZApprox := Floor32(Vec.Z);
end;

procedure YGaPositionMgr.SetZoneId(const Value: UInt32);
begin
  fZone := Value;
end;

function YGaPositionMgr.GetAngle: Single;
begin
  Result := fAngle;
end;

function YGaPositionMgr.GetX: Single;
begin
  Result := fVec.X;
end;

function YGaPositionMgr.GetY: Single;
begin
  Result := fVec.Y;
end;

//procedure YGaPositionMgr.GetCurrentPosition(var tPos: YWorldPosition);
//begin
  //Move(fX, tPos, SizeOf(YWorldPosition));
//end;

function YGaPositionMgr.GetMapId: Longword;
begin
  Result := fMap;
end;

function YGaPositionMgr.GetZ: Single;
begin
  Result := fVec.Z;
end;

function YGaPositionMgr.GetZoneId: Longword;
begin
  Result := fZone;
end;

procedure YGaPositionMgr.DoTeleport(iMap: UInt32; const fX, fY, fZ: Float);
var
  cOutPkt: YNwServerPacket;
begin
  if MapId = iMap then
  begin
    cOutPkt := YNwServerPacket.Initialize(MSG_MOVE_TELEPORT_ACK);
    try
      cOutPkt.AddPackedGUID(Owner.GUID);
      cOutPkt.Jump(12);
      cOutPkt.AddFloat(fX);
      cOutPkt.AddFloat(fY);
      cOutPkt.AddFloat(fZ);
      cOutPkt.AddFloat(Angle);
      Owner.SendPacketInRange(cOutPkt, VIEW_DISTANCE, True, True);
    finally
      cOutPkt.Free;
    end;
  end else
  begin
    //cOutPkt := YNwServerPacket.Initialize(SMSG_TRANSFER_PENDING);
    //try
    //cOutPkt.AddUInt32(iMap);
    //Owner.Session.SendPacket(cOutPkt);

    Owner.ChangeWorldState(wscLeave);

    { Change our position }
    X := fX;
    Y := fY;
    Z := fZ;
    Angle := 0;
    MapId := iMap;

    cOutPkt := YNwServerPacket.Initialize(SMSG_NEW_WORLD);
    cOutPkt.AddUInt32(iMap);
    cOutPkt.AddFloat(fX);
    cOutPkt.AddFloat(fY);
    cOutPkt.AddFloat(fZ);
    cOutPkt.AddFloat(0);
    cOutPkt.Free;
    //YOpenPlayer(fOwner).Session.SendPacket(cOutPkt);
  end;
end;

end.
