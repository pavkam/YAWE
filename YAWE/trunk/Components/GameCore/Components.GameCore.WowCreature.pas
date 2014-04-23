{*------------------------------------------------------------------------------
  Contains wow creature(mob) run-time class.

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
unit Components.GameCore.WowCreature;

interface

uses
  Framework.Base,
  Components.DataCore.Storage,
  Components.DataCore.Fields,
  Components.NetworkCore.Packet,
  Components.DataCore.CharTemplates,
  Components.GameCore.Nodes,
  Components.GameCore.UpdateFields,
  Components.GameCore.WowUnit,
  Components.DataCore.Types,
  Components.GameCore.Interfaces,
  Components.Interfaces,
  SysUtils,
  Misc.Geometry,
  Misc.Miscleanous;

const
  MOVEMENT_AREA_CHECK = 500;
  MOVEMENT_COLLISION_CHECK = 250;

type
  { Item Class }
  YGaCreature = class(YGaUnit, IObject, IMobile, IUnit, ICreature)
    private
      fSpawnNode: INode;
      fTemplate: YDbCreatureTemplate;
      fMoveSource: TVector;
      fMoveTarget: TVector;
      { If you have idea how to get the correct quest list that the questgiver should give... }
      fStartQuestList, fFinishQuestList: TLongWordDynArray;

      procedure SendCreatureMovePacket(Running: Boolean);
    protected
      class function GetOpenObjectType: YWowObjectType; override;

      procedure AddMovementData(cPkt: YNwServerPacket; bSelf: Boolean); override;

      procedure ExtractObjectData(cEntry: YDbSerializable); override;
      procedure InjectObjectData(cEntry: YDbSerializable); override;
      procedure CleanupObjectData; override;
    public
      procedure CreateFromTemplate(iEntryId: UInt32);

      procedure StartMovement(const ToPoint: TVector; Running: Boolean);

      procedure LoadTemplate(iTempId: Int32);
      //procedure CopyUnitTemplate(var tOutTemplate: YCreatureTemplate);

      property Template: YDbCreatureTemplate read fTemplate;
      property SpawnNode: INode read fSpawnNode write fSpawnNode;
      property StartQuestList: TLongWordDynArray read fStartQuestList write fStartQuestList;  //write only for debug
      property FinishQuestList: TLongWordDynArray read fFinishQuestList write fFinishQuestList;  //write only for debug
  end;

implementation

uses
  Math,
  Components.NetworkCore.Opcodes,
  Components.Shared,
  MMSystem,
  Framework,
  Cores;

//procedure YOpenCreature.CopyUnitTemplate(var tOutTemplate: YCreatureTemplate);
//begin
//  if fTemplate <> nil then
//  begin
//    CopyRecord(fTemplate, @tOutTemplate, TypeInfo(YCreatureTemplate));
//  end else FillChar(tOutTemplate, SizeOf(YCreatureTemplate), 0);
//end;

procedure YGaCreature.CreateFromTemplate(iEntryId: UInt32);
begin
  LoadTemplate(iEntryId);
  if fTemplate <> nil then
  begin
    Entry := fTemplate.UniqueID;
    if fTemplate.EntrySize = 0 then
    begin
      SetFloat(OBJECT_FIELD_SCALE_X, 1.0);
    end else
    begin
      SetFloat(OBJECT_FIELD_SCALE_X, fTemplate.EntrySize);
    end;
    SetUInt32(UNIT_FIELD_DISPLAYID, fTemplate.TextureID);
    SetUInt32(UNIT_FIELD_NATIVEDISPLAYID, fTemplate.TextureID);
    SetUInt32(UNIT_FIELD_MOUNTDISPLAYID, fTemplate.MountID);
    SetUInt32(UNIT_FIELD_MAXHEALTH, Max(fTemplate.MaxHealth, 1));
    SetUInt32(UNIT_FIELD_HEALTH, Max(fTemplate.MaxHealth, 1));
    SetUInt32(UNIT_FIELD_MAXPOWER1, fTemplate.MaxMana);
    SetUInt32(UNIT_FIELD_POWER1, fTemplate.MaxMana);
    SetUInt32(UNIT_FIELD_LEVEL, Max(fTemplate.Level, 1));
    SetUInt32(UNIT_FIELD_FACTIONTEMPLATE, fTemplate.Faction);
    SetUInt32(UNIT_NPC_FLAGS, fTemplate.NPCFlag);

    Position.WalkSpeed := SPEED_WALK;
    Position.RunSpeed := SPEED_RUN;
    Position.BackSwimSpeed := SPEED_BACKSWIM;
    Position.SwimSpeed := SPEED_SWIM;
    Position.BackWalkSpeed := SPEED_BACKWALK;
    Position.TurnRate := SPEED_TURNRATE;

    { Till I know how to load the correct lists... }
    SetLength(fStartQuestList, 25);
    fStartQuestList[0] := 532;
    fStartQuestList[1] := 604;
    fStartQuestList[2] := 717;
    fStartQuestList[3] := 849;
    fStartQuestList[4] := 850;
    fStartQuestList[5] := 851;
    fStartQuestList[6] := 14;
    fStartQuestList[7] := 18;
    fStartQuestList[8] := 757;
    fStartQuestList[9] := 924;
    fStartQuestList[10] := 62;
    fStartQuestList[11] := 1447;
    fStartQuestList[12] := 1448;
    fStartQuestList[13] := 1449;
    fStartQuestList[14] := 1450;
    fStartQuestList[15] := 1451;
    fStartQuestList[16] := 1452;
    fStartQuestList[17] := 1453;
    fStartQuestList[18] := 1454;
    fStartQuestList[19] := 1455;
    fStartQuestList[20] := 1456;
    fStartQuestList[21] := 1457;
    fStartQuestList[22] := 1458;
    fStartQuestList[23] := 1459;
    fStartQuestList[24] := 1462;
    SetLength(fFinishQuestList, 25);
    fFinishQuestList[0] := 532;
    fFinishQuestList[1] := 604;
    fFinishQuestList[2] := 717;
    fFinishQuestList[3] := 849;
    fFinishQuestList[4] := 850;
    fFinishQuestList[5] := 851;
    fFinishQuestList[6] := 14;
    fFinishQuestList[7] := 18;
    fFinishQuestList[8] := 757;
    fFinishQuestList[9] := 924;
    fFinishQuestList[10] := 62;
    fFinishQuestList[11] := 1447;
    fFinishQuestList[12] := 1448;
    fFinishQuestList[13] := 1449;
    fFinishQuestList[14] := 1450;
    fFinishQuestList[15] := 1451;
    fFinishQuestList[16] := 1452;
    fFinishQuestList[17] := 1453;
    fFinishQuestList[18] := 1454;
    fFinishQuestList[19] := 1455;
    fFinishQuestList[20] := 1456;
    fFinishQuestList[21] := 1457;
    fFinishQuestList[22] := 1458;
    fFinishQuestList[23] := 1459;
    fFinishQuestList[24] := 1462;

    { TODO 3 -oSeth -cMisc : Add all update fields changes on creation. }
  end;
end;

procedure YGaCreature.ExtractObjectData(cEntry: YDbSerializable);
begin
  inherited ExtractObjectData(cEntry);
  LoadTemplate(Entry);
end;

procedure YGaCreature.InjectObjectData(cEntry: YDbSerializable);
begin
  inherited InjectObjectData(cEntry);
end;

procedure YGaCreature.LoadTemplate(iTempId: Int32);
begin
  DataCore.CreatureTemplates.LoadEntry(iTempId, fTemplate);
end;

procedure YGaCreature.SendCreatureMovePacket(Running: Boolean);
const
  MoveFlags: array[Boolean] of UInt32 = (
    $00000000,
    $00000100
  );
var
  cPkt: YNwServerPacket;
  fSpeed: Float;
begin
  cPkt := YNwServerPacket.Initialize(SMSG_MONSTER_MOVE);
  try
    cPkt.AddPackedGUID(GUID);
    cPkt.AddFloat(fMoveSource.X);
    cPkt.AddFloat(fMoveSource.Y);
    cPkt.AddFloat(fMoveSource.Z);
    cPkt.AddUInt32(TimeGetTime);
    cPkt.AddUInt8(0);
    cPkt.AddUInt32(MoveFlags[Running]);
    
    if Running then
    begin
      fSpeed := Position.RunSpeed;
    end else
    begin
      fSpeed := Position.WalkSpeed;
      // Hmmm... It seems taht speed data is not loeaded ok from database!
      // IoCore.Console.Writeln(' >>> Creature speeds are: ' + ftoa(Position.WalkSpeed) + ' | ' + ftoa(Position.RunSpeed));
    end;

    cPkt.AddUInt32(Ceil32(VectorDistance(fMoveSource, fMoveTarget) / fSpeed));
    cPkt.AddUInt32(1);
    cPkt.AddFloat(fMoveTarget.X);
    cPkt.AddFloat(fMoveTarget.Y);
    cPkt.AddFloat(fMoveTarget.Z);

    SendPacketInRange(cPkt, VIEW_DISTANCE, False, True);
  finally
    cPkt.Free;
  end;
end;

procedure YGaCreature.StartMovement(const ToPoint: TVector; Running: Boolean);
begin
  fMoveSource := Position.Vector;
  fMoveTarget := ToPoint;
  SendCreatureMovePacket(Running);
end;

procedure YGaCreature.AddMovementData(cPkt: YNwServerPacket; bSelf: Boolean);
begin
  cPkt.AddUInt8($10 or $20 or $40);
  cPkt.AddUInt32($800000);
  cPkt.AddUInt32(TimeGetTime);
  cPkt.AddFloat(Position.X);
  cPkt.AddFloat(Position.Y);
  cPkt.AddFloat(Position.Z);
  cPkt.AddFloat(Position.Angle);
  cPkt.JumpUInt32;
  cPkt.AddFloat(Position.WalkSpeed);
  cPkt.AddFloat(Position.RunSpeed);
  cPkt.AddFloat(Position.BackSwimSpeed);
  cPkt.AddFloat(Position.SwimSpeed);
  cPkt.AddFloat(Position.BackWalkSpeed);
  cPkt.AddFloat(Position.TurnRate);
  cPkt.JumpUInt32;
end;

procedure YGaCreature.CleanupObjectData;
begin
end;

class function YGaCreature.GetOpenObjectType: YWowObjectType;
begin
  Result := otUnit;
end;

end.
