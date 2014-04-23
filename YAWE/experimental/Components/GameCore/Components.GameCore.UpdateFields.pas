{*------------------------------------------------------------------------------
  OpenObject and Descendants' Update fields.

  Notes: Added support for 1.10
         Repaired some bugs with dead chars on login and such...

  13-08-2006 Notes:
         Added support for 1.11.X
         This must be correct now and everything should work fine

  23-08-2006 Notes:
         Added support for 1.12.X
         
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author PavkaM
  @Changes TheSelby, Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.UpdateFields;

interface

uses
  Framework.Base,
  SysUtils,
  Misc.Miscleanous;

{$REGION 'Control Constants'}
{ Movement flags }
const
  MOVE_BASE_FLAG_NONE                   =    $000000;
  MOVE_BASE_FLAG_UNKNOWN3               =    $000001;
  MOVE_BASE_FLAG_UNKNOWN4               =    $000002;
  MOVE_BASE_FLAG_UNKNOWN0               =    $000010;
  MOVE_BASE_FLAG_UNKNOWN1               =    $000020;
  MOVE_BASE_FLAG_UNKNOWN2               =    $000040;

  MOVE_SECOND_FLAG_NONE                 =    $000000;
  MOVE_SECOND_FLAG_UNIQUE               =    $000100;
  MOVE_SECOND_FLAG_UNKNOWN1             =    $002000;
  MOVE_SECOND_FLAG_UNKNOWN2             =    $400000;
  MOVE_SECOND_FLAG_UNKNOWN3             =    $800000;

{ Player speeds }
const
  SPEED_WALK                = 2.5;
  SPEED_RUN                 = 7;
  SPEED_BACKSWIM            = 4.5;
  SPEED_SWIM                = 4.7222225;
  SPEED_BACKWALK            = 2.5;
  SPEED_TURNRATE            = PI;

{ ObjectType Constants }

type
  {$Z4}
  YWowObjectType = (otObject, otItem, otContainer, otUnit, otNode, otPlayer,
    otGameObject, otDynamicObject, otCorpse, otPlayerCorpse, otUnknown);
  {$Z1}

const
  UpdateTable: array[YWowObjectType] of Byte = (
    0,
    1,
    2,
    3,
    3,
    4,
    5,
    6,
    7,
    7,
    2
  );

{ Object Update Types }
const
  UPDATETYPE_VALUES                       =   0;  { Updates for a few fields }
  UPDATETYPE_MOVEMENT                     =   1;  { Movement updates for an object }
  UPDATETYPE_CREATE_OBJECT                =   2;  { Creation combines Value & Movement updates }
  UPDATETYPE_CREATE_OBJECT_ME             =   3;  { Same as previous but for same player }
  UPDATETYPE_OUT_OF_RANGE_OBJECTS         =   4;  { Unknown }
  UPDATETYPE_NEAR_OBJECTS                 =   5;  { Unknown }

{ ObjectID Constants }
const
  TYPE_OBJECT                             =   1;
  TYPE_ITEM                               =   2;
  TYPE_CONTAINER                          =   6;
  TYPE_UNIT                               =   8;
  TYPE_PLAYER                             =   16;
  TYPE_GAMEOBJECT                         =   32;
  TYPE_DYNAMICOBJECT                      =   64;
  TYPE_CORPSE                             =   128;
  TYPE_AIGROUP                            =   256;
  TYPE_AREATRIGGER                        =   512;

const
  UPDATEFLAG_OBJECT                       =   TYPE_OBJECT;
  UPDATEFLAG_ITEM                         =   TYPE_OBJECT or TYPE_ITEM;
  UPDATEFLAG_CONTAINER                    =   TYPE_OBJECT or TYPE_ITEM or TYPE_CONTAINER;
  UPDATEFLAG_UNIT                         =   TYPE_OBJECT or TYPE_UNIT;
  UPDATEFLAG_PLAYER                       =   TYPE_OBJECT or TYPE_UNIT or TYPE_PLAYER;
  UPDATEFLAG_GAMEOBJECT                   =   TYPE_OBJECT or TYPE_GAMEOBJECT;
  UPDATEFLAG_DYNAMICOBJECT                =   TYPE_OBJECT or TYPE_DYNAMICOBJECT;
  UPDATEFLAG_CORPSE                       =   TYPE_OBJECT or TYPE_CORPSE;
  UPDATEFLAG_AIGROUP                      =   TYPE_OBJECT or TYPE_AIGROUP;
  UPDATEFLAG_AREATRIGGER                  =   TYPE_OBJECT or TYPE_AREATRIGGER;
{$ENDREGION}

{$REGION 'Accessors'}
const
  BYTE_RACE   = 0;
  BYTE_CLASS  = 1;
  BYTE_GENDER = 2;
  BYTE_POWER  = 3;

  BYTE_SKIN     = 0;
  BYTE_FACE     = 1;
  BYTE_HSTYLE   = 2;
  BYTE_HCOLOR   = 3;

  BYTE_FHAIR    = 0;

{ GUID Accessors }
const
  UPDATE_GUID_LO                          =    0;
  UPDATE_GUID_HI                          =    1;

{ Skill }
const
  UPDATE_SKILL_ID                         =    0;
  UPDATE_SKILL_DATA                       =    1;

  WORD_SKILL_CURR                         =    0;
  WORD_SKILL_MAX                          =    1;
{$ENDREGION}

{$REGION 'OBJECT Update Fields' }
{ OBJECT object type update fields }
Const
  OBJECT_START                                    =  0;
  OBJECT_FIELD_GUID                               =  $0000; { Type: guid }
  OBJECT_FIELD_TYPE                               =  $0002; { Type: uint32 }
  OBJECT_FIELD_ENTRY                              =  $0003; { Type: uint32 }
  OBJECT_FIELD_SCALE_X                            =  $0004; { Type: float }
  OBJECT_FIELD_PADDING                            =  $0005; { Type: uint32 }
  OBJECT_END                                      =  OBJECT_FIELD_PADDING + 1;
{$ENDREGION}


{$REGION 'ITEM Update Fields' }
{ ITEM object type update fields }
Const
  ITEM_START                                      =  OBJECT_END;
  ITEM_FIELD_OWNER                                =  OBJECT_END + $0000; { Type: guid }
  ITEM_FIELD_CONTAINED                            =  OBJECT_END + $0002; { Type: guid }
  ITEM_FIELD_CREATOR                              =  OBJECT_END + $0004; { Type: guid }
  ITEM_FIELD_GIFTCREATOR                          =  OBJECT_END + $0006; { Type: guid }
  ITEM_FIELD_STACK_COUNT                          =  OBJECT_END + $0008; { Type: uint32 }
  ITEM_FIELD_DURATION                             =  OBJECT_END + $0009; { Type: uint32 }

  { Repeat 5 Times }
  __ITEM_FIELD_SPELL_CHARGES                      =  5;
  ITEM_FIELD_SPELL_CHARGES                        =  OBJECT_END + $000A; { Type: uint32 }
  { ... }

  ITEM_FIELD_FLAGS                                =  OBJECT_END + $000F; { Type: uint32 }

  { Repeat 33 Times }
  __ITEM_FIELD_ENCHANTMENT                        =  33;
  ITEM_FIELD_ENCHANTMENT                          =  OBJECT_END + $0010; { Type: uint32 }
  { ... }

  ITEM_FIELD_PROPERTY_SEED                        =  OBJECT_END + $0031; { Type: uint32 }
  ITEM_FIELD_RANDOM_PROPERTIES_ID                 =  OBJECT_END + $0032; { Type: uint32 }
  ITEM_FIELD_ITEM_TEXT_ID                         =  OBJECT_END + $0033; { Type: uint32 }
  ITEM_FIELD_DURABILITY                           =  OBJECT_END + $0034; { Type: uint32 }
  ITEM_FIELD_MAXDURABILITY                        =  OBJECT_END + $0035; { Type: uint32 }
  ITEM_END                                        =  ITEM_FIELD_MAXDURABILITY + 1;
{$ENDREGION}


{$REGION 'CONTAINER Update Fields' }
{ CONTAINER object type update fields }
Const
  CONTAINER_START                                 =  ITEM_END;
  CONTAINER_FIELD_NUM_SLOTS                       =  ITEM_END + $0000; { Type: uint32 }
  CONTAINER_ALIGN_PAD                             =  ITEM_END + $0001; { Type: bytes }

  { Repeat 72 Times }
  __CONTAINER_FIELD_SLOT_1                        =  72;
  CONTAINER_FIELD_SLOT_1                          =  ITEM_END + $0002; { Type: guid }
  { ... }

  CONTAINER_END                                   =  CONTAINER_FIELD_SLOT_1 + 72;
{$ENDREGION}


{$REGION 'UNIT Update Fields' }
{ UNIT object type update fields }
Const
  UNIT_START                                      =  OBJECT_END;
  UNIT_FIELD_CHARM                                =  OBJECT_END + $0000; { Type: guid }
  UNIT_FIELD_SUMMON                               =  OBJECT_END + $0002; { Type: guid }
  UNIT_FIELD_CHARMEDBY                            =  OBJECT_END + $0004; { Type: guid }
  UNIT_FIELD_SUMMONEDBY                           =  OBJECT_END + $0006; { Type: guid }
  UNIT_FIELD_CREATEDBY                            =  OBJECT_END + $0008; { Type: guid }
  UNIT_FIELD_TARGET                               =  OBJECT_END + $000A; { Type: guid }
  UNIT_FIELD_PERSUADED                            =  OBJECT_END + $000C; { Type: guid }
  UNIT_FIELD_CHANNEL_OBJECT                       =  OBJECT_END + $000E; { Type: guid }
  UNIT_FIELD_HEALTH                               =  OBJECT_END + $0010; { Type: uint32 }
  UNIT_FIELD_POWER1                               =  OBJECT_END + $0011; { Type: uint32 }
  UNIT_FIELD_POWER2                               =  OBJECT_END + $0012; { Type: uint32 }
  UNIT_FIELD_POWER3                               =  OBJECT_END + $0013; { Type: uint32 }
  UNIT_FIELD_POWER4                               =  OBJECT_END + $0014; { Type: uint32 }
  UNIT_FIELD_POWER5                               =  OBJECT_END + $0015; { Type: uint32 }
  UNIT_FIELD_MAXHEALTH                            =  OBJECT_END + $0016; { Type: uint32 }
  UNIT_FIELD_MAXPOWER1                            =  OBJECT_END + $0017; { Type: uint32 }
  UNIT_FIELD_MAXPOWER2                            =  OBJECT_END + $0018; { Type: uint32 }
  UNIT_FIELD_MAXPOWER3                            =  OBJECT_END + $0019; { Type: uint32 }
  UNIT_FIELD_MAXPOWER4                            =  OBJECT_END + $001A; { Type: uint32 }
  UNIT_FIELD_MAXPOWER5                            =  OBJECT_END + $001B; { Type: uint32 }
  UNIT_FIELD_LEVEL                                =  OBJECT_END + $001C; { Type: uint32 }
  UNIT_FIELD_FACTIONTEMPLATE                      =  OBJECT_END + $001D; { Type: uint32 }
  UNIT_FIELD_BYTES_0                              =  OBJECT_END + $001E; { Type: bytes }

  { Repeat 3 Times }
  __UNIT_VIRTUAL_ITEM_SLOT_DISPLAY                =  3;
  UNIT_VIRTUAL_ITEM_SLOT_DISPLAY                  =  OBJECT_END + $001F; { Type: uint32 }
  { ... }


  { Repeat 6 Times }
  __UNIT_VIRTUAL_ITEM_INFO                        =  6;
  UNIT_VIRTUAL_ITEM_INFO                          =  OBJECT_END + $0022; { Type: bytes }
  { ... }

  UNIT_FIELD_FLAGS                                =  OBJECT_END + $0028; { Type: uint32 }
  UNIT_FIELD_FLAGS_2                              =  OBJECT_END + $0029; { Type: uint32 }

  { Repeat 56 Times }
  __UNIT_FIELD_AURA                               =  56;
  UNIT_FIELD_AURA                                 =  OBJECT_END + $002A; { Type: uint32 }
  { ... }


  { Repeat 7 Times }
  __UNIT_FIELD_AURAFLAGS                          =  7;
  UNIT_FIELD_AURAFLAGS                            =  OBJECT_END + $0062; { Type: bytes }
  { ... }


  { Repeat 14 Times }
  __UNIT_FIELD_AURALEVELS                         =  14;
  UNIT_FIELD_AURALEVELS                           =  OBJECT_END + $0069; { Type: bytes }
  { ... }


  { Repeat 14 Times }
  __UNIT_FIELD_AURAAPPLICATIONS                   =  14;
  UNIT_FIELD_AURAAPPLICATIONS                     =  OBJECT_END + $0077; { Type: bytes }
  { ... }

  UNIT_FIELD_AURASTATE                            =  OBJECT_END + $0085; { Type: uint32 }

  { Repeat 2 Times }
  __UNIT_FIELD_BASEATTACKTIME                     =  2;
  UNIT_FIELD_BASEATTACKTIME                       =  OBJECT_END + $0086; { Type: uint32 }
  { ... }

  UNIT_FIELD_RANGEDATTACKTIME                     =  OBJECT_END + $0088; { Type: uint32 }
  UNIT_FIELD_BOUNDINGRADIUS                       =  OBJECT_END + $0089; { Type: float }
  UNIT_FIELD_COMBATREACH                          =  OBJECT_END + $008A; { Type: float }
  UNIT_FIELD_DISPLAYID                            =  OBJECT_END + $008B; { Type: uint32 }
  UNIT_FIELD_NATIVEDISPLAYID                      =  OBJECT_END + $008C; { Type: uint32 }
  UNIT_FIELD_MOUNTDISPLAYID                       =  OBJECT_END + $008D; { Type: uint32 }
  UNIT_FIELD_MINDAMAGE                            =  OBJECT_END + $008E; { Type: float }
  UNIT_FIELD_MAXDAMAGE                            =  OBJECT_END + $008F; { Type: float }
  UNIT_FIELD_MINOFFHANDDAMAGE                     =  OBJECT_END + $0090; { Type: float }
  UNIT_FIELD_MAXOFFHANDDAMAGE                     =  OBJECT_END + $0091; { Type: float }
  UNIT_FIELD_BYTES_1                              =  OBJECT_END + $0092; { Type: bytes }
  UNIT_FIELD_PETNUMBER                            =  OBJECT_END + $0093; { Type: uint32 }
  UNIT_FIELD_PET_NAME_TIMESTAMP                   =  OBJECT_END + $0094; { Type: uint32 }
  UNIT_FIELD_PETEXPERIENCE                        =  OBJECT_END + $0095; { Type: uint32 }
  UNIT_FIELD_PETNEXTLEVELEXP                      =  OBJECT_END + $0096; { Type: uint32 }
  UNIT_DYNAMIC_FLAGS                              =  OBJECT_END + $0097; { Type: uint32 }
  UNIT_CHANNEL_SPELL                              =  OBJECT_END + $0098; { Type: uint32 }
  UNIT_MOD_CAST_SPEED                             =  OBJECT_END + $0099; { Type: float }
  UNIT_CREATED_BY_SPELL                           =  OBJECT_END + $009A; { Type: uint32 }
  UNIT_NPC_FLAGS                                  =  OBJECT_END + $009B; { Type: uint32 }
  UNIT_NPC_EMOTESTATE                             =  OBJECT_END + $009C; { Type: uint32 }
  UNIT_TRAINING_POINTS                            =  OBJECT_END + $009D; { Type: bytes }
  UNIT_FIELD_STAT0                                =  OBJECT_END + $009E; { Type: uint32 }
  UNIT_FIELD_STAT1                                =  OBJECT_END + $009F; { Type: uint32 }
  UNIT_FIELD_STAT2                                =  OBJECT_END + $00A0; { Type: uint32 }
  UNIT_FIELD_STAT3                                =  OBJECT_END + $00A1; { Type: uint32 }
  UNIT_FIELD_STAT4                                =  OBJECT_END + $00A2; { Type: uint32 }
  UNIT_FIELD_POSSTAT0                             =  OBJECT_END + $00A3; { Type: uint32 }
  UNIT_FIELD_POSSTAT1                             =  OBJECT_END + $00A4; { Type: uint32 }
  UNIT_FIELD_POSSTAT2                             =  OBJECT_END + $00A5; { Type: uint32 }
  UNIT_FIELD_POSSTAT3                             =  OBJECT_END + $00A6; { Type: uint32 }
  UNIT_FIELD_POSSTAT4                             =  OBJECT_END + $00A7; { Type: uint32 }
  UNIT_FIELD_NEGSTAT0                             =  OBJECT_END + $00A8; { Type: uint32 }
  UNIT_FIELD_NEGSTAT1                             =  OBJECT_END + $00A9; { Type: uint32 }
  UNIT_FIELD_NEGSTAT2                             =  OBJECT_END + $00AA; { Type: uint32 }
  UNIT_FIELD_NEGSTAT3                             =  OBJECT_END + $00AB; { Type: uint32 }
  UNIT_FIELD_NEGSTAT4                             =  OBJECT_END + $00AC; { Type: uint32 }

  { Repeat 7 Times }
  __UNIT_FIELD_RESISTANCES                        =  7;
  UNIT_FIELD_RESISTANCES                          =  OBJECT_END + $00AD; { Type: uint32 }
  { ... }


  { Repeat 7 Times }
  __UNIT_FIELD_RESISTANCEBUFFMODSPOSITIVE         =  7;
  UNIT_FIELD_RESISTANCEBUFFMODSPOSITIVE           =  OBJECT_END + $00B4; { Type: uint32 }
  { ... }


  { Repeat 7 Times }
  __UNIT_FIELD_RESISTANCEBUFFMODSNEGATIVE         =  7;
  UNIT_FIELD_RESISTANCEBUFFMODSNEGATIVE           =  OBJECT_END + $00BB; { Type: uint32 }
  { ... }

  UNIT_FIELD_BASE_MANA                            =  OBJECT_END + $00C2; { Type: uint32 }
  UNIT_FIELD_BASE_HEALTH                          =  OBJECT_END + $00C3; { Type: uint32 }
  UNIT_FIELD_BYTES_2                              =  OBJECT_END + $00C4; { Type: bytes }
  UNIT_FIELD_ATTACK_POWER                         =  OBJECT_END + $00C5; { Type: uint32 }
  UNIT_FIELD_ATTACK_POWER_MODS                    =  OBJECT_END + $00C6; { Type: bytes }
  UNIT_FIELD_ATTACK_POWER_MULTIPLIER              =  OBJECT_END + $00C7; { Type: float }
  UNIT_FIELD_RANGED_ATTACK_POWER                  =  OBJECT_END + $00C8; { Type: uint32 }
  UNIT_FIELD_RANGED_ATTACK_POWER_MODS             =  OBJECT_END + $00C9; { Type: bytes }
  UNIT_FIELD_RANGED_ATTACK_POWER_MULTIPLIER       =  OBJECT_END + $00CA; { Type: float }
  UNIT_FIELD_MINRANGEDDAMAGE                      =  OBJECT_END + $00CB; { Type: float }
  UNIT_FIELD_MAXRANGEDDAMAGE                      =  OBJECT_END + $00CC; { Type: float }

  { Repeat 7 Times }
  __UNIT_FIELD_POWER_COST_MODIFIER                =  7;
  UNIT_FIELD_POWER_COST_MODIFIER                  =  OBJECT_END + $00CD; { Type: uint32 }
  { ... }


  { Repeat 7 Times }
  __UNIT_FIELD_POWER_COST_MULTIPLIER              =  7;
  UNIT_FIELD_POWER_COST_MULTIPLIER                =  OBJECT_END + $00D4; { Type: float }
  { ... }

  UNIT_FIELD_PADDING                              =  OBJECT_END + $00DB; { Type: uint32 }
  UNIT_END                                        =  UNIT_FIELD_PADDING + 1;
{$ENDREGION}


{$REGION 'PLAYER Update Fields' }
{ PLAYER object type update fields }
Const
  PLAYER_START                                    =  UNIT_END;
  PLAYER_DUEL_ARBITER                             =  UNIT_END + $0000; { Type: guid }
  PLAYER_FLAGS                                    =  UNIT_END + $0002; { Type: uint32 }
  PLAYER_GUILDID                                  =  UNIT_END + $0003; { Type: uint32 }
  PLAYER_GUILDRANK                                =  UNIT_END + $0004; { Type: uint32 }
  PLAYER_BYTES                                    =  UNIT_END + $0005; { Type: bytes }
  PLAYER_BYTES_2                                  =  UNIT_END + $0006; { Type: bytes }
  PLAYER_BYTES_3                                  =  UNIT_END + $0007; { Type: bytes }
  PLAYER_DUEL_TEAM                                =  UNIT_END + $0008; { Type: uint32 }
  PLAYER_GUILD_TIMESTAMP                          =  UNIT_END + $0009; { Type: uint32 }
  PLAYER_QUEST_LOG_1_1                            =  UNIT_END + $000A; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_1_2                          =  2;
  PLAYER_QUEST_LOG_1_2                            =  UNIT_END + $000B; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_2_1                            =  UNIT_END + $000D; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_2_2                          =  2;
  PLAYER_QUEST_LOG_2_2                            =  UNIT_END + $000E; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_3_1                            =  UNIT_END + $0010; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_3_2                          =  2;
  PLAYER_QUEST_LOG_3_2                            =  UNIT_END + $0011; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_4_1                            =  UNIT_END + $0013; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_4_2                          =  2;
  PLAYER_QUEST_LOG_4_2                            =  UNIT_END + $0014; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_5_1                            =  UNIT_END + $0016; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_5_2                          =  2;
  PLAYER_QUEST_LOG_5_2                            =  UNIT_END + $0017; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_6_1                            =  UNIT_END + $0019; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_6_2                          =  2;
  PLAYER_QUEST_LOG_6_2                            =  UNIT_END + $001A; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_7_1                            =  UNIT_END + $001C; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_7_2                          =  2;
  PLAYER_QUEST_LOG_7_2                            =  UNIT_END + $001D; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_8_1                            =  UNIT_END + $001F; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_8_2                          =  2;
  PLAYER_QUEST_LOG_8_2                            =  UNIT_END + $0020; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_9_1                            =  UNIT_END + $0022; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_9_2                          =  2;
  PLAYER_QUEST_LOG_9_2                            =  UNIT_END + $0023; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_10_1                           =  UNIT_END + $0025; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_10_2                         =  2;
  PLAYER_QUEST_LOG_10_2                           =  UNIT_END + $0026; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_11_1                           =  UNIT_END + $0028; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_11_2                         =  2;
  PLAYER_QUEST_LOG_11_2                           =  UNIT_END + $0029; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_12_1                           =  UNIT_END + $002B; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_12_2                         =  2;
  PLAYER_QUEST_LOG_12_2                           =  UNIT_END + $002C; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_13_1                           =  UNIT_END + $002E; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_13_2                         =  2;
  PLAYER_QUEST_LOG_13_2                           =  UNIT_END + $002F; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_14_1                           =  UNIT_END + $0031; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_14_2                         =  2;
  PLAYER_QUEST_LOG_14_2                           =  UNIT_END + $0032; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_15_1                           =  UNIT_END + $0034; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_15_2                         =  2;
  PLAYER_QUEST_LOG_15_2                           =  UNIT_END + $0035; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_16_1                           =  UNIT_END + $0037; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_16_2                         =  2;
  PLAYER_QUEST_LOG_16_2                           =  UNIT_END + $0038; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_17_1                           =  UNIT_END + $003A; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_17_2                         =  2;
  PLAYER_QUEST_LOG_17_2                           =  UNIT_END + $003B; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_18_1                           =  UNIT_END + $003D; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_18_2                         =  2;
  PLAYER_QUEST_LOG_18_2                           =  UNIT_END + $003E; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_19_1                           =  UNIT_END + $0040; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_19_2                         =  2;
  PLAYER_QUEST_LOG_19_2                           =  UNIT_END + $0041; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_20_1                           =  UNIT_END + $0043; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_20_2                         =  2;
  PLAYER_QUEST_LOG_20_2                           =  UNIT_END + $0044; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_21_1                           =  UNIT_END + $0046; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_21_2                         =  2;
  PLAYER_QUEST_LOG_21_2                           =  UNIT_END + $0047; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_22_1                           =  UNIT_END + $0049; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_22_2                         =  2;
  PLAYER_QUEST_LOG_22_2                           =  UNIT_END + $004A; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_23_1                           =  UNIT_END + $004C; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_23_2                         =  2;
  PLAYER_QUEST_LOG_23_2                           =  UNIT_END + $004D; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_24_1                           =  UNIT_END + $004F; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_24_2                         =  2;
  PLAYER_QUEST_LOG_24_2                           =  UNIT_END + $0050; { Type: uint32 }
  { ... }

  PLAYER_QUEST_LOG_25_1                           =  UNIT_END + $0052; { Type: uint32 }

  { Repeat 2 Times }
  __PLAYER_QUEST_LOG_25_2                         =  2;
  PLAYER_QUEST_LOG_25_2                           =  UNIT_END + $0053; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_1_CREATOR                   =  UNIT_END + $0055; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_1_0                       =  12;
  PLAYER_VISIBLE_ITEM_1_0                         =  UNIT_END + $0057; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_1_PROPERTIES                =  UNIT_END + $0063; { Type: bytes }
  PLAYER_VISIBLE_ITEM_1_PAD                       =  UNIT_END + $0064; { Type: uint32 }
  PLAYER_VISIBLE_ITEM_2_CREATOR                   =  UNIT_END + $0065; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_2_0                       =  12;
  PLAYER_VISIBLE_ITEM_2_0                         =  UNIT_END + $0067; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_2_PROPERTIES                =  UNIT_END + $0073; { Type: bytes }
  PLAYER_VISIBLE_ITEM_2_PAD                       =  UNIT_END + $0074; { Type: uint32 }
  PLAYER_VISIBLE_ITEM_3_CREATOR                   =  UNIT_END + $0075; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_3_0                       =  12;
  PLAYER_VISIBLE_ITEM_3_0                         =  UNIT_END + $0077; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_3_PROPERTIES                =  UNIT_END + $0083; { Type: bytes }
  PLAYER_VISIBLE_ITEM_3_PAD                       =  UNIT_END + $0084; { Type: uint32 }
  PLAYER_VISIBLE_ITEM_4_CREATOR                   =  UNIT_END + $0085; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_4_0                       =  12;
  PLAYER_VISIBLE_ITEM_4_0                         =  UNIT_END + $0087; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_4_PROPERTIES                =  UNIT_END + $0093; { Type: bytes }
  PLAYER_VISIBLE_ITEM_4_PAD                       =  UNIT_END + $0094; { Type: uint32 }
  PLAYER_VISIBLE_ITEM_5_CREATOR                   =  UNIT_END + $0095; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_5_0                       =  12;
  PLAYER_VISIBLE_ITEM_5_0                         =  UNIT_END + $0097; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_5_PROPERTIES                =  UNIT_END + $00A3; { Type: bytes }
  PLAYER_VISIBLE_ITEM_5_PAD                       =  UNIT_END + $00A4; { Type: uint32 }
  PLAYER_VISIBLE_ITEM_6_CREATOR                   =  UNIT_END + $00A5; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_6_0                       =  12;
  PLAYER_VISIBLE_ITEM_6_0                         =  UNIT_END + $00A7; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_6_PROPERTIES                =  UNIT_END + $00B3; { Type: bytes }
  PLAYER_VISIBLE_ITEM_6_PAD                       =  UNIT_END + $00B4; { Type: uint32 }
  PLAYER_VISIBLE_ITEM_7_CREATOR                   =  UNIT_END + $00B5; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_7_0                       =  12;
  PLAYER_VISIBLE_ITEM_7_0                         =  UNIT_END + $00B7; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_7_PROPERTIES                =  UNIT_END + $00C3; { Type: bytes }
  PLAYER_VISIBLE_ITEM_7_PAD                       =  UNIT_END + $00C4; { Type: uint32 }
  PLAYER_VISIBLE_ITEM_8_CREATOR                   =  UNIT_END + $00C5; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_8_0                       =  12;
  PLAYER_VISIBLE_ITEM_8_0                         =  UNIT_END + $00C7; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_8_PROPERTIES                =  UNIT_END + $00D3; { Type: bytes }
  PLAYER_VISIBLE_ITEM_8_PAD                       =  UNIT_END + $00D4; { Type: uint32 }
  PLAYER_VISIBLE_ITEM_9_CREATOR                   =  UNIT_END + $00D5; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_9_0                       =  12;
  PLAYER_VISIBLE_ITEM_9_0                         =  UNIT_END + $00D7; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_9_PROPERTIES                =  UNIT_END + $00E3; { Type: bytes }
  PLAYER_VISIBLE_ITEM_9_PAD                       =  UNIT_END + $00E4; { Type: uint32 }
  PLAYER_VISIBLE_ITEM_10_CREATOR                  =  UNIT_END + $00E5; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_10_0                      =  12;
  PLAYER_VISIBLE_ITEM_10_0                        =  UNIT_END + $00E7; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_10_PROPERTIES               =  UNIT_END + $00F3; { Type: bytes }
  PLAYER_VISIBLE_ITEM_10_PAD                      =  UNIT_END + $00F4; { Type: uint32 }
  PLAYER_VISIBLE_ITEM_11_CREATOR                  =  UNIT_END + $00F5; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_11_0                      =  12;
  PLAYER_VISIBLE_ITEM_11_0                        =  UNIT_END + $00F7; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_11_PROPERTIES               =  UNIT_END + $0103; { Type: bytes }
  PLAYER_VISIBLE_ITEM_11_PAD                      =  UNIT_END + $0104; { Type: uint32 }
  PLAYER_VISIBLE_ITEM_12_CREATOR                  =  UNIT_END + $0105; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_12_0                      =  12;
  PLAYER_VISIBLE_ITEM_12_0                        =  UNIT_END + $0107; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_12_PROPERTIES               =  UNIT_END + $0113; { Type: bytes }
  PLAYER_VISIBLE_ITEM_12_PAD                      =  UNIT_END + $0114; { Type: uint32 }
  PLAYER_VISIBLE_ITEM_13_CREATOR                  =  UNIT_END + $0115; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_13_0                      =  12;
  PLAYER_VISIBLE_ITEM_13_0                        =  UNIT_END + $0117; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_13_PROPERTIES               =  UNIT_END + $0123; { Type: bytes }
  PLAYER_VISIBLE_ITEM_13_PAD                      =  UNIT_END + $0124; { Type: uint32 }
  PLAYER_VISIBLE_ITEM_14_CREATOR                  =  UNIT_END + $0125; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_14_0                      =  12;
  PLAYER_VISIBLE_ITEM_14_0                        =  UNIT_END + $0127; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_14_PROPERTIES               =  UNIT_END + $0133; { Type: bytes }
  PLAYER_VISIBLE_ITEM_14_PAD                      =  UNIT_END + $0134; { Type: uint32 }
  PLAYER_VISIBLE_ITEM_15_CREATOR                  =  UNIT_END + $0135; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_15_0                      =  12;
  PLAYER_VISIBLE_ITEM_15_0                        =  UNIT_END + $0137; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_15_PROPERTIES               =  UNIT_END + $0143; { Type: bytes }
  PLAYER_VISIBLE_ITEM_15_PAD                      =  UNIT_END + $0144; { Type: uint32 }
  PLAYER_VISIBLE_ITEM_16_CREATOR                  =  UNIT_END + $0145; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_16_0                      =  12;
  PLAYER_VISIBLE_ITEM_16_0                        =  UNIT_END + $0147; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_16_PROPERTIES               =  UNIT_END + $0153; { Type: bytes }
  PLAYER_VISIBLE_ITEM_16_PAD                      =  UNIT_END + $0154; { Type: uint32 }
  PLAYER_VISIBLE_ITEM_17_CREATOR                  =  UNIT_END + $0155; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_17_0                      =  12;
  PLAYER_VISIBLE_ITEM_17_0                        =  UNIT_END + $0157; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_17_PROPERTIES               =  UNIT_END + $0163; { Type: bytes }
  PLAYER_VISIBLE_ITEM_17_PAD                      =  UNIT_END + $0164; { Type: uint32 }
  PLAYER_VISIBLE_ITEM_18_CREATOR                  =  UNIT_END + $0165; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_18_0                      =  12;
  PLAYER_VISIBLE_ITEM_18_0                        =  UNIT_END + $0167; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_18_PROPERTIES               =  UNIT_END + $0173; { Type: bytes }
  PLAYER_VISIBLE_ITEM_18_PAD                      =  UNIT_END + $0174; { Type: uint32 }
  PLAYER_VISIBLE_ITEM_19_CREATOR                  =  UNIT_END + $0175; { Type: guid }

  { Repeat 12 Times }
  __PLAYER_VISIBLE_ITEM_19_0                      =  12;
  PLAYER_VISIBLE_ITEM_19_0                        =  UNIT_END + $0177; { Type: uint32 }
  { ... }

  PLAYER_VISIBLE_ITEM_19_PROPERTIES               =  UNIT_END + $0183; { Type: bytes }
  PLAYER_VISIBLE_ITEM_19_PAD                      =  UNIT_END + $0184; { Type: uint32 }
  PLAYER_CHOSEN_TITLE                             =  UNIT_END + $0185; { Type: uint32 }

  { Repeat 46 Times }
  __PLAYER_FIELD_INV_SLOT_HEAD                    =  46;
  PLAYER_FIELD_INV_SLOT_HEAD                      =  UNIT_END + $0186; { Type: guid }
  { ... }


  { Repeat 32 Times }
  __PLAYER_FIELD_PACK_SLOT_1                      =  32;
  PLAYER_FIELD_PACK_SLOT_1                        =  UNIT_END + $01B4; { Type: guid }
  { ... }


  { Repeat 56 Times }
  __PLAYER_FIELD_BANK_SLOT_1                      =  56;
  PLAYER_FIELD_BANK_SLOT_1                        =  UNIT_END + $01D4; { Type: guid }
  { ... }


  { Repeat 14 Times }
  __PLAYER_FIELD_BANKBAG_SLOT_1                   =  14;
  PLAYER_FIELD_BANKBAG_SLOT_1                     =  UNIT_END + $020C; { Type: guid }
  { ... }


  { Repeat 24 Times }
  __PLAYER_FIELD_VENDORBUYBACK_SLOT_1             =  24;
  PLAYER_FIELD_VENDORBUYBACK_SLOT_1               =  UNIT_END + $021A; { Type: guid }
  { ... }


  { Repeat 64 Times }
  __PLAYER_FIELD_KEYRING_SLOT_1                   =  64;
  PLAYER_FIELD_KEYRING_SLOT_1                     =  UNIT_END + $0232; { Type: guid }
  { ... }

  PLAYER_FARSIGHT                                 =  UNIT_END + $0272; { Type: guid }
  PLAYER__FIELD_COMBO_TARGET                      =  UNIT_END + $0274; { Type: guid }
  PLAYER__FIELD_KNOWN_TITLES                      =  UNIT_END + $0276; { Type: guid }
  PLAYER_XP                                       =  UNIT_END + $0278; { Type: uint32 }
  PLAYER_NEXT_LEVEL_XP                            =  UNIT_END + $0279; { Type: uint32 }

  { Repeat 384 Times }
  __PLAYER_SKILL_INFO_1_1                         =  384;
  PLAYER_SKILL_INFO_1_1                           =  UNIT_END + $027A; { Type: bytes }
  { ... }

  PLAYER_CHARACTER_POINTS1                        =  UNIT_END + $03FA; { Type: uint32 }
  PLAYER_CHARACTER_POINTS2                        =  UNIT_END + $03FB; { Type: uint32 }
  PLAYER_TRACK_CREATURES                          =  UNIT_END + $03FC; { Type: uint32 }
  PLAYER_TRACK_RESOURCES                          =  UNIT_END + $03FD; { Type: uint32 }
  PLAYER_BLOCK_PERCENTAGE                         =  UNIT_END + $03FE; { Type: float }
  PLAYER_DODGE_PERCENTAGE                         =  UNIT_END + $03FF; { Type: float }
  PLAYER_PARRY_PERCENTAGE                         =  UNIT_END + $0400; { Type: float }
  PLAYER_CRIT_PERCENTAGE                          =  UNIT_END + $0401; { Type: float }
  PLAYER_RANGED_CRIT_PERCENTAGE                   =  UNIT_END + $0402; { Type: float }
  PLAYER_OFFHAND_CRIT_PERCENTAGE                  =  UNIT_END + $0403; { Type: float }

  { Repeat 7 Times }
  __PLAYER_SPELL_CRIT_PERCENTAGE1                 =  7;
  PLAYER_SPELL_CRIT_PERCENTAGE1                   =  UNIT_END + $0404; { Type: float }
  { ... }


  { Repeat 64 Times }
  __PLAYER_EXPLORED_ZONES_1                       =  64;
  PLAYER_EXPLORED_ZONES_1                         =  UNIT_END + $040B; { Type: bytes }
  { ... }

  PLAYER_REST_STATE_EXPERIENCE                    =  UNIT_END + $044B; { Type: uint32 }
  PLAYER_FIELD_COINAGE                            =  UNIT_END + $044C; { Type: uint32 }

  { Repeat 7 Times }
  __PLAYER_FIELD_MOD_DAMAGE_DONE_POS              =  7;
  PLAYER_FIELD_MOD_DAMAGE_DONE_POS                =  UNIT_END + $044D; { Type: uint32 }
  { ... }


  { Repeat 7 Times }
  __PLAYER_FIELD_MOD_DAMAGE_DONE_NEG              =  7;
  PLAYER_FIELD_MOD_DAMAGE_DONE_NEG                =  UNIT_END + $0454; { Type: uint32 }
  { ... }


  { Repeat 7 Times }
  __PLAYER_FIELD_MOD_DAMAGE_DONE_PCT              =  7;
  PLAYER_FIELD_MOD_DAMAGE_DONE_PCT                =  UNIT_END + $045B; { Type: uint32 }
  { ... }

  PLAYER_FIELD_MOD_HEALING_DONE_POS               =  UNIT_END + $0462; { Type: uint32 }
  PLAYER_FIELD_MOD_TARGET_RESISTANCE              =  UNIT_END + $0463; { Type: uint32 }
  PLAYER_FIELD_BYTES                              =  UNIT_END + $0464; { Type: bytes }
  PLAYER_AMMO_ID                                  =  UNIT_END + $0465; { Type: uint32 }
  PLAYER_SELF_RES_SPELL                           =  UNIT_END + $0466; { Type: uint32 }
  PLAYER_FIELD_PVP_MEDALS                         =  UNIT_END + $0467; { Type: uint32 }

  { Repeat 12 Times }
  __PLAYER_FIELD_BUYBACK_PRICE_1                  =  12;
  PLAYER_FIELD_BUYBACK_PRICE_1                    =  UNIT_END + $0468; { Type: uint32 }
  { ... }


  { Repeat 12 Times }
  __PLAYER_FIELD_BUYBACK_TIMESTAMP_1              =  12;
  PLAYER_FIELD_BUYBACK_TIMESTAMP_1                =  UNIT_END + $0474; { Type: uint32 }
  { ... }

  PLAYER_FIELD_KILLS                              =  UNIT_END + $0480; { Type: bytes }
  PLAYER_FIELD_TODAY_CONTRIBUTION                 =  UNIT_END + $0481; { Type: uint32 }
  PLAYER_FIELD_YESTERDAY_CONTRIBUTION             =  UNIT_END + $0482; { Type: uint32 }
  PLAYER_FIELD_LIFETIME_HONORBALE_KILLS           =  UNIT_END + $0483; { Type: uint32 }
  PLAYER_FIELD_BYTES2                             =  UNIT_END + $0484; { Type: bytes }
  PLAYER_FIELD_WATCHED_FACTION_INDEX              =  UNIT_END + $0485; { Type: uint32 }

  { Repeat 23 Times }
  __PLAYER_FIELD_COMBAT_RATING_1                  =  23;
  PLAYER_FIELD_COMBAT_RATING_1                    =  UNIT_END + $0486; { Type: uint32 }
  { ... }


  { Repeat 9 Times }
  __PLAYER_FIELD_ARENA_TEAM_INFO_1_1              =  9;
  PLAYER_FIELD_ARENA_TEAM_INFO_1_1                =  UNIT_END + $049D; { Type: uint32 }
  { ... }

  PLAYER_FIELD_HONOR_CURRENCY                     =  UNIT_END + $04A6; { Type: uint32 }
  PLAYER_FIELD_ARENA_CURRENCY                     =  UNIT_END + $04A7; { Type: uint32 }
  PLAYER_FIELD_MOD_MANA_REGEN                     =  UNIT_END + $04A8; { Type: float }
  PLAYER_FIELD_MOD_MANA_REGEN_INTERRUPT           =  UNIT_END + $04A9; { Type: float }
  PLAYER_FIELD_MAX_LEVEL                          =  UNIT_END + $04AA; { Type: uint32 }
  PLAYER_FIELD_PADDING                            =  UNIT_END + $04AB; { Type: uint32 }
  PLAYER_END                                      =  PLAYER_FIELD_PADDING + 1;
{$ENDREGION}


{$REGION 'GAMEOBJECT Update Fields' }
{ GAMEOBJECT object type update fields }
Const
  GAMEOBJECT_START                                =  OBJECT_END;
  OBJECT_FIELD_CREATED_BY                         =  OBJECT_END + $0000; { Type: guid }
  GAMEOBJECT_DISPLAYID                            =  OBJECT_END + $0002; { Type: uint32 }
  GAMEOBJECT_FLAGS                                =  OBJECT_END + $0003; { Type: uint32 }

  { Repeat 4 Times }
  __GAMEOBJECT_ROTATION                           =  4;
  GAMEOBJECT_ROTATION                             =  OBJECT_END + $0004; { Type: float }
  { ... }

  GAMEOBJECT_STATE                                =  OBJECT_END + $0008; { Type: uint32 }
  GAMEOBJECT_POS_X                                =  OBJECT_END + $0009; { Type: float }
  GAMEOBJECT_POS_Y                                =  OBJECT_END + $000A; { Type: float }
  GAMEOBJECT_POS_Z                                =  OBJECT_END + $000B; { Type: float }
  GAMEOBJECT_FACING                               =  OBJECT_END + $000C; { Type: float }
  GAMEOBJECT_DYN_FLAGS                            =  OBJECT_END + $000D; { Type: uint32 }
  GAMEOBJECT_FACTION                              =  OBJECT_END + $000E; { Type: uint32 }
  GAMEOBJECT_TYPE_ID                              =  OBJECT_END + $000F; { Type: uint32 }
  GAMEOBJECT_LEVEL                                =  OBJECT_END + $0010; { Type: uint32 }
  GAMEOBJECT_ARTKIT                               =  OBJECT_END + $0011; { Type: uint32 }
  GAMEOBJECT_ANIMPROGRESS                         =  OBJECT_END + $0012; { Type: uint32 }
  GAMEOBJECT_PADDING                              =  OBJECT_END + $0013; { Type: uint32 }
  GAMEOBJECT_END                                  =  GAMEOBJECT_PADDING + 1;
{$ENDREGION}


{$REGION 'DYNAMICOBJECT Update Fields' }
{ DYNAMICOBJECT object type update fields }
Const
  DYNAMICOBJECT_START                             =  OBJECT_END;
  DYNAMICOBJECT_CASTER                            =  OBJECT_END + $0000; { Type: guid }
  DYNAMICOBJECT_BYTES                             =  OBJECT_END + $0002; { Type: bytes }
  DYNAMICOBJECT_SPELLID                           =  OBJECT_END + $0003; { Type: uint32 }
  DYNAMICOBJECT_RADIUS                            =  OBJECT_END + $0004; { Type: float }
  DYNAMICOBJECT_POS_X                             =  OBJECT_END + $0005; { Type: float }
  DYNAMICOBJECT_POS_Y                             =  OBJECT_END + $0006; { Type: float }
  DYNAMICOBJECT_POS_Z                             =  OBJECT_END + $0007; { Type: float }
  DYNAMICOBJECT_FACING                            =  OBJECT_END + $0008; { Type: float }
  DYNAMICOBJECT_PAD                               =  OBJECT_END + $0009; { Type: bytes }
  DYNAMICOBJECT_END                               =  DYNAMICOBJECT_PAD + 1;
{$ENDREGION}


{$REGION 'CORPSE Update Fields' }
{ CORPSE object type update fields }
Const
  CORPSE_START                                    =  OBJECT_END;
  CORPSE_FIELD_OWNER                              =  OBJECT_END + $0000; { Type: guid }
  CORPSE_FIELD_FACING                             =  OBJECT_END + $0002; { Type: float }
  CORPSE_FIELD_POS_X                              =  OBJECT_END + $0003; { Type: float }
  CORPSE_FIELD_POS_Y                              =  OBJECT_END + $0004; { Type: float }
  CORPSE_FIELD_POS_Z                              =  OBJECT_END + $0005; { Type: float }
  CORPSE_FIELD_DISPLAY_ID                         =  OBJECT_END + $0006; { Type: uint32 }

  { Repeat 19 Times }
  __CORPSE_FIELD_ITEM                             =  19;
  CORPSE_FIELD_ITEM                               =  OBJECT_END + $0007; { Type: uint32 }
  { ... }

  CORPSE_FIELD_BYTES_1                            =  OBJECT_END + $001A; { Type: bytes }
  CORPSE_FIELD_BYTES_2                            =  OBJECT_END + $001B; { Type: bytes }
  CORPSE_FIELD_GUILD                              =  OBJECT_END + $001C; { Type: uint32 }
  CORPSE_FIELD_FLAGS                              =  OBJECT_END + $001D; { Type: uint32 }
  CORPSE_FIELD_DYNAMIC_FLAGS                      =  OBJECT_END + $001E; { Type: uint32 }
  CORPSE_FIELD_PAD                                =  OBJECT_END + $001F; { Type: uint32 }
  CORPSE_END                                      =  CORPSE_FIELD_PAD + 1;
{$ENDREGION}

const
  UpdateMaskLenghts: array[YWowObjectType] of UInt32 = (
    OBJECT_END,
    ITEM_END,
    CONTAINER_END,
    UNIT_END,
    UNIT_END,
    PLAYER_END,
    GAMEOBJECT_END,
    DYNAMICOBJECT_END,
    CORPSE_END,
    CORPSE_END,
    OBJECT_END
  );

function GetVisibilityArray(iType: YWowObjectType): PLongWordArray;

implementation

var
  { Ahh, for the sake of all optimizations, do not remove this :) }
  ObjectVisibilityArray: array[0..(OBJECT_END div 32) + 1] of UInt32;
  ItemVisibilityArray: array[0..(ITEM_END div 32) + 1] of UInt32;
  ContainerVisibilityArray: array[0..(CONTAINER_END div 32) + 1] of UInt32;
  UnitVisibilityArray: array[0..(UNIT_END div 32) + 1] of UInt32;
  PlayerVisibilityArray: array[0..(PLAYER_END div 32) + 1] of UInt32;
  GOVisibilityArray: array[0..(GAMEOBJECT_END div 32) + 1] of UInt32;
  DOVisibilityArray: array[0..(DYNAMICOBJECT_END div 32) + 1] of UInt32;
  CorpseVisibilityArray: array[0..(CORPSE_END div 32) + 1] of UInt32;

function GetVisibilityArray(iType: YWowObjectType): PLongWordArray;
begin
  case iType of
    otObject:
    begin
      Result := @ObjectVisibilityArray;
    end;
    otItem:
    begin
      Result := @ItemVisibilityArray;
    end;
    otContainer:
    begin
      Result := @ContainerVisibilityArray;
    end;
    otUnit, otNode:
    begin
      Result := @UnitVisibilityArray;
    end;
    otPlayer:
    begin
      Result := @PlayerVisibilityArray;
    end;
    otGameObject:
    begin
      Result := @GOVisibilityArray;
    end;
    otDynamicObject:
    begin
      Result := @DOVisibilityArray;
    end;
    otCorpse, otPlayerCorpse:
    begin
      Result := @CorpseVisibilityArray;
    end;
  else
    begin
      Result := nil;
    end;
  end;
end;

procedure InitVisibleProperties;
begin
  { Here we initialize object type-specific visibility arrays.
    They are bit arrays to reduce memory usage and to allow us to predict
    update masks during update packet construction. }

  FillChar(ObjectVisibilityArray, SizeOf(ObjectVisibilityArray), $FF); { Set all bits }
  FillChar(ItemVisibilityArray, SizeOf(ItemVisibilityArray), $FF); { Set all bits }
  FillChar(ContainerVisibilityArray, SizeOf(ContainerVisibilityArray), $FF); { Set all bits }
  FillChar(UnitVisibilityArray, SizeOf(UnitVisibilityArray), $FF); { Set all bits }
  FillChar(GOVisibilityArray, SizeOf(GOVisibilityArray), $FF); { Set all bits }
  FillChar(DOVisibilityArray, SizeOf(DOVisibilityArray), $FF); { Set all bits }
  FillChar(CorpseVisibilityArray, SizeOf(CorpseVisibilityArray), $FF); { Set all bits }

  { Ok, here we init the visible fields array for players }
  SetBits(@PlayerVisibilityArray, OBJECT_START, OBJECT_END - 1);

  SetBits(@PlayerVisibilityArray, UNIT_FIELD_SUMMON, UNIT_FIELD_SUMMON + 1);
  SetBits(@PlayerVisibilityArray, UNIT_FIELD_TARGET, UNIT_FIELD_TARGET + 1);

  SetBits(@PlayerVisibilityArray, UNIT_FIELD_HEALTH, UNIT_FIELD_MAXHEALTH);

  SetBit(@PlayerVisibilityArray, UNIT_FIELD_LEVEL);
  SetBit(@PlayerVisibilityArray, UNIT_FIELD_FACTIONTEMPLATE);
  SetBit(@PlayerVisibilityArray, UNIT_FIELD_BYTES_0);
  SetBit(@PlayerVisibilityArray, UNIT_FIELD_FLAGS);

  SetBits(@PlayerVisibilityArray, UNIT_FIELD_AURA, UNIT_FIELD_AURA + __UNIT_FIELD_AURA - 1);
  SetBits(@PlayerVisibilityArray, UNIT_FIELD_BASEATTACKTIME, __UNIT_FIELD_BASEATTACKTIME + UNIT_FIELD_BASEATTACKTIME - 1);
  SetBits(@PlayerVisibilityArray, UNIT_VIRTUAL_ITEM_SLOT_DISPLAY, UNIT_VIRTUAL_ITEM_INFO + __UNIT_VIRTUAL_ITEM_INFO - 1);

  SetBit(@PlayerVisibilityArray, UNIT_FIELD_BOUNDINGRADIUS);
  SetBit(@PlayerVisibilityArray, UNIT_FIELD_COMBATREACH);

  SetBit(@PlayerVisibilityArray, UNIT_FIELD_DISPLAYID);
  SetBit(@PlayerVisibilityArray, UNIT_FIELD_NATIVEDISPLAYID);
  SetBit(@PlayerVisibilityArray, UNIT_FIELD_MOUNTDISPLAYID);

  SetBit(@PlayerVisibilityArray, UNIT_FIELD_BYTES_1);
  SetBit(@PlayerVisibilityArray, UNIT_FIELD_BYTES_2);
  SetBit(@PlayerVisibilityArray, UNIT_FIELD_PETNUMBER);
  SetBit(@PlayerVisibilityArray, UNIT_FIELD_PET_NAME_TIMESTAMP);
  SetBit(@PlayerVisibilityArray, UNIT_DYNAMIC_FLAGS);

  SetBit(@PlayerVisibilityArray, PLAYER_BYTES);
  SetBit(@PlayerVisibilityArray, PLAYER_BYTES_2);
  SetBit(@PlayerVisibilityArray, PLAYER_BYTES_3);
  SetBit(@PlayerVisibilityArray, PLAYER_GUILDID);
  SetBit(@PlayerVisibilityArray, PLAYER_GUILDRANK);
  SetBit(@PlayerVisibilityArray, PLAYER_GUILD_TIMESTAMP);

  SetBits(@PlayerVisibilityArray, PLAYER_VISIBLE_ITEM_1_CREATOR, PLAYER_VISIBLE_ITEM_19_PAD);
end;

initialization
  InitVisibleProperties;

end.
