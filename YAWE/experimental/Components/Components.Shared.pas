{*------------------------------------------------------------------------------
  Shared defines.

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
unit Components.Shared;

interface

uses
  SysUtils,
  Misc.Miscleanous,
  Framework.Base;

const
  VIEW_DISTANCE = 128 { yards };

type
  EYaweException = class(Exception);

  PObjectGuid = ^YObjectGuid;
  YObjectGuid = record
    case Byte of
      0: (Full: Int64);
      1: (Longs: array[0..1] of UInt32);
      2: (Words: array[0..3] of UInt16);
      3: (Bytes: array[0..7] of UInt8);
      4: (
        Lo, Hi: UInt32;
      );
  end;

  YGameGender = (ggMale, ggFemale, ggUnknown);

  YGameLanguage = (glUniversal = 0, glOrcish = 1, glDarnassian = 2, glTaurahe = 3,
    glDwarvish = 6, glCommon = 7, glDemonic = 8, glTitan = 9, glThelassian = 10,
    glDraconic = 11, glKalimag = 12, glGnomish = 13, glTroll = 14, glGutterspeak = 33);

  {$IFNDEF WOW_TBC}
  YGameRace = (grFill, grHuman, grOrc, grDwarf, grNightElf, grUndead, grTauren, grGnome,
    grTroll, grGoblin);
  {$ELSE}
  YGameRace = (grFill, grHuman, grOrc, grDwarf, grNightElf, grUndead, grTauren, grGnome,
    grTroll, grGoblin, grBloodElf, grDraenei);
  {$ENDIF}
    
  YGameClass = (gcFill, gcWarrior, gcPaladin, gcHunter, gcRogue, gcPriest, gcUnk1,
    gcShaman, gcMage, gcWarlock, gcUnk2, gcDruid);

  YGameRaces = set of YGameRace;
  YGameClasses = set of YGameClass;

  YGamePowerType = (gptMana, gptRage, gptFocus, gptEnergy, gptHappiness);

  {$Z4}
  YItemClass = (icConsumable, icContainer, icWeapon, icUnused1, icArmor, icReagent,
    icProjectile, icTradeGoods, icGeneric, icBook, icQuiver, icQuestItem, icKey,
    icPermanent, icJunk);

  YItemQuality = (iqJunk, iqCommon, iqUncommon, iqRare, iqEpic, iqLegendary, iqArtifact);

  YItemBondingType = (ibtNone, ibtBindOnPickup, ibtBindOnRquip, ibtBindOnUse, ibtSoulBound);

  YItemInventoryType = (iitNone, iitHead, iitNeck, iitShoulders, iitBody, iitChest,
    iitWaist, iitLegs, iitFeet, iitWrists, iitHands, iitFingers, iitTrinkets,
    iitWeaponUniversal, iitShield, iitBowOrCrossbow, iitCloak, iit2HandedWeapon,
    iitBag, iitTabard, iitRobe, iitWeaponMainHand, iitWeaponOffHand, iitHoldable,
    iitAmmo, iitThrowable, iitGunOrWand);

  YStatBonusType = (sbtUnused, sbtHealth, sbtMana, sbtAgility, sbtStrength,
    sbtIntellect, sbtSpirit, sbtStamina);

  YDamageType = (dtPhysical, dtHoly, dtFire, dtNature, dtFrost, dtShadow, dtArcane);

  YResistanceType = (rtUnused, rtPhysical, rtHoly, rtFire, rtNature, rtFrost,
    rtShadow, rtArcane);
  {$Z1}

  ColorCode = type PChar;

const
  {$IFNDEF WOW_TBC}
  grAll = [grHuman..grTroll];
  grAlliance = [grHuman, grDwarf, grNightElf, grGnome];
  grHorde = [grOrc, grUndead, grTauren, grTroll];
  {$ELSE}
  grAll = [grHuman..grTroll, grBloodElf..grDraenei];
  grAlliance = [grHuman, grDwarf, grNightElf, grGnome, grDraenei];
  grHorde = [grOrc, grUndead, grTauren, grTroll, grBloodElf];
  {$ENDIF}
  gcAll = [gcWarrior, gcPaladin, gcHunter, gcRogue, gcPriest, gcShaman, gcMage, gcWarlock, gcDruid];
  gcCasterClasses = [gcPriest, gcMage, gcWarlock];
  gcMeleeClasses = [gcWarrior, gcHunter, gcRogue];
  gcHybridClasses = [gcPaladin, gcShaman, gcDruid];

{ Game Races }
const
  RACE_HUMAN        = 1;
  RACE_ORC          = 2;
  RACE_DWARF        = 3;
  RACE_NIGHT_ELF    = 4;
  RACE_UNDEAD       = 5;
  RACE_TAUREN       = 6;
  RACE_GNOME        = 7;
  RACE_TROLL        = 8;
  RACE_GOBLIN       = 9;
  RACE_BLOODELF     = 10;
  RACE_DRAENEI      = 11;

  {$IFNDEF WOW_TBC}
  GAME_RACES_MASK = (
    (1 shl RACE_HUMAN) or
    (1 shl RACE_ORC) or
    (1 shl RACE_DWARF) or
    (1 shl RACE_NIGHT_ELF) or
    (1 shl RACE_UNDEAD) or
    (1 shl RACE_TAUREN) or
    (1 shl RACE_GNOME) or
    (1 shl RACE_TROLL)
  );
  {$ELSE}
  GAME_RACES_MASK = (
    (1 shl RACE_HUMAN) or
    (1 shl RACE_ORC) or
    (1 shl RACE_DWARF) or
    (1 shl RACE_NIGHT_ELF) or
    (1 shl RACE_UNDEAD) or
    (1 shl RACE_TAUREN) or
    (1 shl RACE_GNOME) or
    (1 shl RACE_TROLL) or
    (1 shl RACE_BLOODELF) or
    (1 shl RACE_DRAENEI)
  );
  {$ENDIF}

{$IFNDEF WOW_TBC}
  ALLIANCE_MASK = (
    (1 shl RACE_HUMAN) or
    (1 shl RACE_DWARF) or
    (1 shl RACE_NIGHT_ELF) or
    (1 shl RACE_GNOME)
  );
{$ELSE}
  ALLIANCE_MASK = (
    (1 shl RACE_HUMAN) or
    (1 shl RACE_DWARF) or
    (1 shl RACE_NIGHT_ELF) or
    (1 shl RACE_GNOME) or
    (1 shl RACE_DRAENEI)
  );
{$ENDIF}

{$IFNDEF WOW_TBC}
  HORDE_MASK = (
    (1 shl RACE_ORC) or
    (1 shl RACE_UNDEAD) or
    (1 shl RACE_TAUREN) or
    (1 shl RACE_TROLL)
  );
{$ELSE}
  HORDE_MASK = (
    (1 shl RACE_ORC) or
    (1 shl RACE_UNDEAD) or
    (1 shl RACE_TAUREN) or
    (1 shl RACE_TROLL) or
    (1 shl RACE_BLOODELF)
  );
{$ENDIF}

{ Game Classes }
const
  CLASS_WARRIOR     = 1;
  CLASS_PALADIN     = 2;
  CLASS_HUNTER      = 3;
  CLASS_ROGUE       = 4;
  CLASS_PRIEST      = 5;
  CLASS_UNK1        = 6;
  CLASS_SHAMAN      = 7;
  CLASS_MAGE        = 8;
  CLASS_WARLOCK     = 9;
  CLASS_UNK2        = 10;
  CLASS_DRUID       = 11;

  GAME_CLASSES_MASK = (
    (1 shl CLASS_WARRIOR) or
    (1 shl CLASS_PALADIN) or
    (1 shl CLASS_HUNTER) or
    (1 shl CLASS_ROGUE) or
    (1 shl CLASS_PRIEST) or
    (1 shl CLASS_SHAMAN) or
    (1 shl CLASS_MAGE) or
    (1 shl CLASS_WARLOCK) or
    (1 shl CLASS_DRUID)
  );

  MELEE_MASK = (
    (1 shl CLASS_WARRIOR) or
    (1 shl CLASS_HUNTER) or
    (1 shl CLASS_ROGUE)
  );

  CASTERS_MASK = (
    (1 shl CLASS_PRIEST) or
    (1 shl CLASS_MAGE) or
    (1 shl CLASS_WARLOCK)
  );

  HYBRID_MASK = (
    (1 shl CLASS_PALADIN) or
    (1 shl CLASS_SHAMAN) or
    (1 shl CLASS_DRUID)
  );

{ Power Types }
const
  POWER_MANA        = 0;
  POWER_RAGE        = 1;
  POWER_FOCUS       = 2;
  POWER_ENERGY      = 3;
  POWER_HAPPINESS   = 4;

{ Languages }
const
  LANG_UNIVERSAL		 = 0;
  LANG_ORCISH			   = 1;
  LANG_DARNASSIAN	   = 2;
  LANG_TAURAHE			 = 3;
  LANG_DWARVISH		   = 6;
  LANG_COMMON			   = 7;
  LANG_DEMONIC			 = 8;
  LANG_TITAN				 = 9;
  LANG_THELASSIAN	   = 10;
  LANG_DRACONIC		   = 11;
  LANG_KALIMAG			 = 12;
  LANG_GNOMISH			 = 13;
  LANG_TROLL				 = 14;
  LANG_GUTTERSPEAK	 = 33;

{ Genders }
const
  GENDER_MALE       = 0;
  GENDER_FEMALE     = 1;
  GENDER_UNKNOWN    = 2;

{ Sheath }
const
  SHEATH_NONE       = 0;
  SHEATH_MAIN       = 1;
  SHEATH_RANGED     = 2;

{ Default static channels }
const
  STATIC_CHANNELS: array[0..4] of string = (
    'GENERAL',
    'TRADE',
    'LOCALDEFENSE',
    'WORLDDEFENSE',
    'LOOKINGFORGROUP'
  );

const
{$IFDEF WOW_TBC}
  ALL_MAP_IDS: array[0..2] of UInt32 = (0, 1, 530);
{$ELSE}
  ALL_MAP_IDS: array[0..1] of UInt32 = (0, 1);
{$ENDIF}

{ Utility functions }
function RaceToString(iRace: YGameRace): string;
function ClassToString(iClass: YGameClass): string;

function IsAlliance(iRace: YGameRace): Boolean;
function IsHorde(iRace: YGameRace): Boolean;

function FactionDiffers(iRace1, iRace2: YGameRace): Boolean;

function FactionTemplateByRace(iRace: YGameRace): UInt32;

function GetCinematicByRace(iRace: YGameRace): UInt32;

implementation

function GetCinematicByRace(iRace: YGameRace): UInt32;
{$IFNDEF WOW_TBC}
const
  CinematicIds: array[YGameRace] of UInt32 = (
    0,
    81,
    21,
    41,
    61,
    2,
    141,
    101,
    121,
    0
  );
{$ELSE}
const
  CinematicIds: array[YGameRace] of UInt32 = (
    0,
    81,
    21,
    41,
    61,
    2,
    141,
    101,
    121,
    0,
    0, { TODO -oAll -cDefines : To find out the cinematics IDs }
    163
  );
{$ENDIF}
begin
  Result := CinematicIds[iRace];
end;

function FactionTemplateByRace(iRace: YGameRace): UInt32;
begin  { TODO -oAll -cDefines : To find out the proper Faction table! }
  if iRace < grGnome then Result := UInt32(iRace) else Result := UInt32(iRace) + 108;
end;

function IsAlliance(iRace: YGameRace): Boolean;
begin
  Result := ((1 shl UInt8(iRace)) and ALLIANCE_MASK) <> 0;
end;

function IsHorde(iRace: YGameRace): Boolean;
begin
  Result := ((1 shl UInt8(iRace)) and HORDE_MASK) <> 0;
end;

function FactionDiffers(iRace1, iRace2: YGameRace): Boolean;
begin
  Result := IsAlliance(iRace1) xor not IsHorde(iRace2);
end;

function RaceToString(iRace: YGameRace): string;
{$IFNDEF WOW_TBC}
const
  RaceNames: array[YGameRace] of string = (
    'INVALID',
    'HUMAN',
    'ORC',
    'DWARF',
    'NIGHT_ELF',
    'UNDEAD',
    'TAUREN',
    'GNOME',
    'TROLL',
    'GOBLIN'
  );
{$ELSE}
const
  RaceNames: array[YGameRace] of string = (
    'INVALID',
    'HUMAN',
    'ORC',
    'DWARF',
    'NIGHT_ELF',
    'UNDEAD',
    'TAUREN',
    'GNOME',
    'TROLL',
    'GOBLIN',
    'BLOOD_ELF',
    'DRAENEI'
  );
{$ENDIF}
begin
  {$IFNDEF WOW_TBC}
  if iRace <= grGoblin then Result := RaceNames[iRace] else Result := RaceNames[grFill];
  {$ELSE}
  if iRace <= grDraenei then Result := RaceNames[iRace] else Result := RaceNames[grFill];
  {$ENDIF}
end;

function ClassToString(iClass: YGameClass): string;
const
  ClassNames: array[YGameClass] of string = (
    'INVALID',
    'WARRIOR',
    'PALADIN',
    'HUNTER',
    'ROGUE',
    'PRIEST',
    'UNK1',
    'SHAMAN',
    'MAGE',
    'WARLOCK',
    'UNK2',
    'DRUID'
  );
begin
  if iClass <= gcDruid then Result := ClassNames[iClass] else Result := ClassNames[gcFill];
end;

end.
