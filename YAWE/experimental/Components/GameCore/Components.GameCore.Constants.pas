{*------------------------------------------------------------------------------
  All OpenSession constants go here.


  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth, TheSelby
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.Constants;

interface

uses
  Framework.Base,
  Components.Shared;

const
{$REGION 'Inventory Error'}
  INV_ERR_OK                               = 00;
  INV_ERR_YOU_MUST_REACH_LEVEL_N           = 01;
  INV_ERR_SKILL_ISNT_HIGH_ENOUGH           = 02;
  INV_ERR_ITEM_DOESNT_GO_TO_SLOT           = 03;
  INV_ERR_BAG_FULL                         = 04;
  INV_ERR_NONEMPTY_BAG_OVER_OTHER_BAG      = 05;
  INV_ERR_EQUIPED_BAG                      = 06;
  INV_ERR_ONLY_AMMO_CAN_GO_HERE            = 07;
  INV_ERR_NO_REQUIRED_PROFICIENCY          = 08;
  INV_ERR_NO_EQUIPMENT_SLOT_AVAILABLE      = 09;
  INV_ERR_YOU_CAN_NEVER_USE_THAT_ITEM      = 10;
  INV_ERR_YOU_CAN_NEVER_USE_THAT_ITEM2     = 11;
  INV_ERR_NO_EQUIPMENT_SLOTS_IS_AVAILABLE  = 12;
  INV_ERR_CANT_EQUIP_WITH_TWOHANDED        = 13;
  INV_ERR_CANT_DUAL_WIELD_YET              = 14;
  INV_ERR_ITEM_DOESNT_GO_INTO_BAG          = 15;
  INV_ERR_ITEM_DOESNT_GO_INTO_BAG2         = 16;
  INV_ERR_CANT_CARRY_MORE_OF_THIS          = 17;
  INV_ERR_NO_EQUIPMENT_SLOT_AVAILABLE2     = 18;
  INV_ERR_ITEM_CANT_STACK                  = 19; 
  INV_ERR_ITEM_CANT_BE_EQUIPPED            = 20;
  INV_ERR_ITEMS_CANT_BE_SWAPPED            = 21;
  INV_ERR_SLOT_IS_EMPTY                    = 22;
  INV_ERR_ITEM_NOT_FOUND                   = 23;
  INV_ERR_CANT_DROP_SOULBOUND              = 24;
  INV_ERR_OUT_OF_RANGE                     = 25;
  INV_ERR_TRIED_TO_SPLIT_MORE_THAN_COUNT   = 26;
  INV_ERR_COULDNT_SPLIT_ITEMS              = 27;
  INV_ERR_BAG_FULL2                        = 28;
  INV_ERR_NOT_ENOUGH_MONEY                 = 29;
  INV_ERR_NOT_A_BAG                        = 30;
  INV_ERR_CAN_ONLY_DO_WITH_EMPTY_BAGS      = 31;
  INV_ERR_DONT_OWN_THAT_ITEM               = 32;
  INV_ERR_CAN_EQUIP_ONLY1_QUIVER           = 33;
  INV_ERR_MUST_PURCHASE_THAT_BAG_SLOT      = 34;
  INV_ERR_TOO_FAR_AWAY_FROM_BANK           = 35;
  INV_ERR_ITEM_LOCKED                      = 36;
  INV_ERR_YOU_ARE_STUNNED                  = 37;
  INV_ERR_YOU_ARE_DEAD                     = 38;
  INV_ERR_CANT_DO_RIGHT_NOW                = 39;
  INV_ERR_BAG_FULL3                        = 40;
  INV_ERR_CAN_EQUIP_ONLY1_QUIVER2          = 41;
  INV_ERR_CAN_EQUIP_ONLY1_AMMOPOUCH        = 42;
  INV_ERR_STACKABLE_CANT_BE_WRAPPED        = 43;
  INV_ERR_EQUIPPED_CANT_BE_WRAPPED         = 44;
  INV_ERR_WRAPPED_CANT_BE_WRAPPED          = 45;
  INV_ERR_BOUND_CANT_BE_WRAPPED            = 46;
  INV_ERR_UNIQUE_CANT_BE_WRAPPED           = 47;
  INV_ERR_BAGS_CANT_BE_WRAPPED             = 48;
  INV_ERR_ALREADY_LOOTED                   = 49;
  INV_ERR_INVENTORY_FULL                   = 50;
  INV_ERR_BANK_FULL                        = 51;
  INV_ERR_ITEM_IS_CURRENTLY_SOLD_OUT       = 52;
  INV_ERR_BAG_FULL4                        = 53;
  INV_ERR_ITEM_NOT_FOUND2                  = 54;
  INV_ERR_ITEM_CANT_STACK2                 = 55;
  INV_ERR_BAG_FULL5                        = 56;
  INV_ERR_ITEM_SOLD_OUT                    = 57;
  INV_ERR_OBJECT_IS_BUSY                   = 58;
  INV_ERR_NONE                             = 59;
  INV_ERR_CANT_DO_IN_COMBAT                = 60;
  INV_CANT_DO_WHILE_DISARMED               = 61;
  INV_ERR_NONE2				                     = 62;
  INV_ITEM_RANK_NOT_ENOUGH                 = 63;
  INV_ITEM_REPUTATION_NOT_ENOUGH           = 64;
{$ENDREGION}

const
{$REGION 'Character Manipulation'}
  CHAR_CREATED_OK             =     $2D;
  CHAR_OPERATION_SUCCESS      =     $2E;
  CHAR_CREATE_ERROR           =     $2F;
  CHAR_NAME_UNAVAILABLE       =     $31;
  CHAR_RACE_CLASS_DISABLED    =     $32;
  CHAR_PVP_SERVER             =     $33;
  CHAR_FULL_LIST              =     $34;
  CHAR_DELETED_OK             =     $37;
  CHAR_DELETE_FAILED          =     $38;
  CHAR_EXISTS                 =     $31;
  CHAR_HAS_NO_NAME            =     $41;
  CHAR_AT_LEAST_2             =     $42;
  CHAR_AT_MOST_12             =     $43;
  CHAR_ONLY_LETTERS           =     $44;
  CHAR_PROFANITY              =     $46;
{$ENDREGION}

const
{$REGION 'CHAT Types'}
  CHAT_MSG_SAY                  = $00;
  CHAT_MSG_PARTY                = $01;
  CHAT_MSG_GUILD                = $03;
  CHAT_MSG_OFFICER              = $04;
  CHAT_MSG_YELL                 = $05;
  CHAT_MSG_WHISPER              = $06;
  CHAT_MSG_WHISPER_INFORM       = $07;
  CHAT_MSG_EMOTE                = $08;
  CHAT_MSG_TEXT_EMOTE           = $09;
  CHAT_MSG_SYSTEM               = $0A;
  CHAT_MSG_MONSTER_SAY          = $0B;
  CHAT_MSG_MONSTER_YELL         = $0C;
  CHAT_MSG_MONSTER_EMOTE        = $0D;
  CHAT_MSG_CHANNEL              = $0E;
  CHAT_MSG_CHANNEL_JOIN         = $0F;
  CHAT_MSG_CHANNEL_LEAVE        = $10;
  CHAT_MSG_CHANNEL_LIST         = $11;
  CHAT_MSG_CHANNEL_NOTICE       = $12;
  CHAT_MSG_CHANNEL_NOTICE_USER  = $13;
  CHAT_MSG_AFK                  = $14;
  CHAT_MSG_DND                  = $15;
  CHAT_MSG_COMBAT_LOG           = $16;
  CHAT_MSG_IGNORED              = $17;
  CHAT_MSG_SKILL                = $18;
  CHAT_MSG_LOOT                 = $19;
{$ENDREGION}

const
{$REGION 'CHAT Colors'}
  { Color codes borrowed from the wowwow project }
  MSG_COLOR_ALICEBLUE: ColorCode           = 'FFF0F8FF';
  MSG_COLOR_ANTIQUEWHITE: ColorCode        = 'FFFAEBD7';
  MSG_COLOR_AQUA: ColorCode                = 'FF00FFFF';
  MSG_COLOR_AQUAMARINE: ColorCode          = 'FF7FFFD4';
  MSG_COLOR_AZURE: ColorCode               = 'FFF0FFFF';
  MSG_COLOR_BEIGE: ColorCode               = 'FFF5F5DC';
  MSG_COLOR_BISQUE: ColorCode              = 'FFFFE4C4';
  MSG_COLOR_BLACK: ColorCode               = 'FF000000';
  MSG_COLOR_BLANCHEDALMOND: ColorCode      = 'FFFFEBCD';
  MSG_COLOR_BLUE: ColorCode                = 'FF0000FF';
  MSG_COLOR_BLUEVIOLET: ColorCode          = 'FF8A2BE2';
  MSG_COLOR_BROWN: ColorCode               = 'FFA52A2A';
  MSG_COLOR_BURLYWOOD: ColorCode           = 'FFDEB887';
  MSG_COLOR_CADETBLUE: ColorCode           = 'FF5F9EA0';
  MSG_COLOR_CHARTREUSE: ColorCode          = 'FF7FFF00';
  MSG_COLOR_CHOCOLATE: ColorCode           = 'FFD2691E';
  MSG_COLOR_CORAL: ColorCode               = 'FFFF7F50';
  MSG_COLOR_CORNFLOWERBLUE: ColorCode      = 'FF6495ED';
  MSG_COLOR_CORNSILK: ColorCode            = 'FFFFF8DC';
  MSG_COLOR_CRIMSON: ColorCode             = 'FFDC143C';
  MSG_COLOR_CYAN: ColorCode                = 'FF00FFFF';
  MSG_COLOR_DARKBLUE: ColorCode            = 'FF00008B';
  MSG_COLOR_DARKCYAN: ColorCode            = 'FF008B8B';
  MSG_COLOR_DARKGOLDENROD: ColorCode       = 'FFB8860B';
  MSG_COLOR_DARKGRAY: ColorCode            = 'FFA9A9A9';
  MSG_COLOR_DARKGREEN: ColorCode           = 'FF006400';
  MSG_COLOR_DARKKHAKI: ColorCode           = 'FFBDB76B';
  MSG_COLOR_DARKMAGENTA: ColorCode         = 'FF8B008B';
  MSG_COLOR_DARKOLIVEGREEN: ColorCode      = 'FF556B2F';
  MSG_COLOR_DARKORANGE: ColorCode          = 'FFFF8C00';
  MSG_COLOR_DARKORCHID: ColorCode          = 'FF9932CC';
  MSG_COLOR_DARKRED: ColorCode             = 'FF8B0000';
  MSG_COLOR_DARKSALMON: ColorCode          = 'FFE9967A';
  MSG_COLOR_DARKSEAGREEN: ColorCode        = 'FF8FBC8B';
  MSG_COLOR_DARKSLATEBLUE: ColorCode       = 'FF483D8B';
  MSG_COLOR_DARKSLATEGRAY: ColorCode       = 'FF2F4F4F';
  MSG_COLOR_DARKTURQUOISE: ColorCode       = 'FF00CED1';
  MSG_COLOR_DARKVIOLET: ColorCode          = 'FF9400D3';
  MSG_COLOR_DEEPPINK: ColorCode            = 'FFFF1493';
  MSG_COLOR_DEEPSKYBLUE: ColorCode         = 'FF00BFFF';
  MSG_COLOR_DIMGRAY: ColorCode             = 'FF696969';
  MSG_COLOR_DODGERBLUE: ColorCode          = 'FF1E90FF';
  MSG_COLOR_FIREBRICK: ColorCode           = 'FFB22222';
  MSG_COLOR_FLORALWHITE: ColorCode         = 'FFFFFAF0';
  MSG_COLOR_FORESTGREEN: ColorCode         = 'FF228B22';
  MSG_COLOR_FUCHSIA: ColorCode             = 'FFFF00FF';
  MSG_COLOR_GAINSBORO: ColorCode           = 'FFDCDCDC';
  MSG_COLOR_GHOSTWHITE: ColorCode          = 'FFF8F8FF';
  MSG_COLOR_GOLD: ColorCode                = 'FFFFD700';
  MSG_COLOR_GOLDENROD: ColorCode           = 'FFDAA520';
  MSG_COLOR_GRAY: ColorCode                = 'FF808080';
  MSG_COLOR_GREEN: ColorCode               = 'FF008000';
  MSG_COLOR_GREENYELLOW: ColorCode         = 'FFADFF2F';
  MSG_COLOR_HONEYDEW: ColorCode            = 'FFF0FFF0';
  MSG_COLOR_HOTPINK: ColorCode             = 'FFFF69B4';
  MSG_COLOR_INDIANRED: ColorCode           = 'FFCD5C5C';
  MSG_COLOR_INDIGO: ColorCode              = 'FF4B0082';
  MSG_COLOR_IVORY: ColorCode               = 'FFFFFFF0';
  MSG_COLOR_KHAKI: ColorCode               = 'FFF0E68C';
  MSG_COLOR_LAVENDER: ColorCode            = 'FFE6E6FA';
  MSG_COLOR_LAVENDERBLUSH: ColorCode       = 'FFFFF0F5';
  MSG_COLOR_LAWNGREEN: ColorCode           = 'FF7CFC00';
  MSG_COLOR_LEMONCHIFFON: ColorCode        = 'FFFFFACD';
  MSG_COLOR_LIGHTBLUE: ColorCode           = 'FFADD8E6';
  MSG_COLOR_LIGHTCORAL: ColorCode          = 'FFF08080';
  MSG_COLOR_LIGHTCYAN: ColorCode           = 'FFE0FFFF';
  MSG_COLOR_LIGHTGRAY: ColorCode           = 'FFD3D3D3';
  MSG_COLOR_LIGHTGREEN: ColorCode          = 'FF90EE90';
  MSG_COLOR_LIGHTPINK: ColorCode           = 'FFFFB6C1';
  MSG_COLOR_LIGHTRED: ColorCode            = 'FFFF6060';
  MSG_COLOR_LIGHTSALMON: ColorCode         = 'FFFFA07A';
  MSG_COLOR_LIGHTSEAGREEN: ColorCode       = 'FF20B2AA';
  MSG_COLOR_LIGHTSKYBLUE: ColorCode        = 'FF87CEFA';
  MSG_COLOR_LIGHTSLATEGRAY: ColorCode      = 'FF778899';
  MSG_COLOR_LIGHTSTEELBLUE: ColorCode      = 'FFB0C4DE';
  MSG_COLOR_LIGHTYELLOW: ColorCode         = 'FFFFFFE0';
  MSG_COLOR_LIME: ColorCode                = 'FF00FF00';
  MSG_COLOR_LIMEGREEN: ColorCode           = 'FF32CD32';
  MSG_COLOR_LINEN: ColorCode               = 'FFFAF0E6';
  MSG_COLOR_MAGENTA: ColorCode             = 'FFFF00FF';
  MSG_COLOR_MAROON: ColorCode              = 'FF800000';
  MSG_COLOR_MEDIUMAQUAMARINE: ColorCode    = 'FF66CDAA';
  MSG_COLOR_MEDIUMBLUE: ColorCode          = 'FF0000CD';
  MSG_COLOR_MEDIUMORCHID: ColorCode        = 'FFBA55D3';
  MSG_COLOR_MEDIUMPURPLE: ColorCode        = 'FF9370DB';
  MSG_COLOR_MEDIUMSEAGREEN: ColorCode      = 'FF3CB371';
  MSG_COLOR_MEDIUMSLATEBLUE: ColorCode     = 'FF7B68EE';
  MSG_COLOR_MEDIUMSPRINGGREEN: ColorCode   = 'FF00FA9A';
  MSG_COLOR_MEDIUMTURQUOISE: ColorCode     = 'FF48D1CC';
  MSG_COLOR_MEDIUMVIOLETRED: ColorCode     = 'FFC71585';
  MSG_COLOR_MIDNIGHTBLUE: ColorCode        = 'FF191970';
  MSG_COLOR_MINTCREAM: ColorCode           = 'FFF5FFFA';
  MSG_COLOR_MISTYROSE: ColorCode           = 'FFFFE4E1';
  MSG_COLOR_MOCCASIN: ColorCode            = 'FFFFE4B5';
  MSG_COLOR_NAVAJOWHITE: ColorCode         = 'FFFFDEAD';
  MSG_COLOR_NAVY: ColorCode                = 'FF000080';
  MSG_COLOR_OLDLACE: ColorCode             = 'FFFDF5E6';
  MSG_COLOR_OLIVE: ColorCode               = 'FF808000';
  MSG_COLOR_OLIVEDRAB: ColorCode           = 'FF6B8E23';
  MSG_COLOR_ORANGE: ColorCode              = 'FFFFA500';
  MSG_COLOR_ORANGERED: ColorCode           = 'FFFF4500';
  MSG_COLOR_ORCHID: ColorCode              = 'FFDA70D6';
  MSG_COLOR_PALEGOLDENROD: ColorCode       = 'FFEEE8AA';
  MSG_COLOR_PALEGREEN: ColorCode           = 'FF98FB98';
  MSG_COLOR_PALETURQUOISE: ColorCode       = 'FFAFEEEE';
  MSG_COLOR_PALEVIOLETRED: ColorCode       = 'FFDB7093';
  MSG_COLOR_PAPAYAWHIP: ColorCode          = 'FFFFEFD5';
  MSG_COLOR_PEACHPUFF: ColorCode           = 'FFFFDAB9';
  MSG_COLOR_PERU: ColorCode                = 'FFCD853F';
  MSG_COLOR_PINK: ColorCode                = 'FFFFC0CB';
  MSG_COLOR_PLUM: ColorCode                = 'FFDDA0DD';
  MSG_COLOR_POWDERBLUE: ColorCode          = 'FFB0E0E6';
  MSG_COLOR_PURPLE: ColorCode              = 'FF800080';
  MSG_COLOR_RED: ColorCode                 = 'FFFF0000';
  MSG_COLOR_ROSYBROWN: ColorCode           = 'FFBC8F8F';
  MSG_COLOR_ROYALBLUE: ColorCode           = 'FF4169E1';
  MSG_COLOR_SADDLEBROWN: ColorCode         = 'FF8B4513';
  MSG_COLOR_SALMON: ColorCode              = 'FFFA8072';
  MSG_COLOR_SANDYBROWN: ColorCode          = 'FFF4A460';
  MSG_COLOR_SEAGREEN: ColorCode            = 'FF2E8B57';
  MSG_COLOR_SEASHELL: ColorCode            = 'FFFFF5EE';
  MSG_COLOR_SIENNA: ColorCode              = 'FFA0522D';
  MSG_COLOR_SILVER: ColorCode              = 'FFC0C0C0';
  MSG_COLOR_SKYBLUE: ColorCode             = 'FF87CEEB';
  MSG_COLOR_SLATEBLUE: ColorCode           = 'FF6A5ACD';
  MSG_COLOR_SLATEGRAY: ColorCode           = 'FF708090';
  MSG_COLOR_SNOW: ColorCode                = 'FFFFFAFA';
  MSG_COLOR_SPRINGGREEN: ColorCode         = 'FF00FF7F';
  MSG_COLOR_STEELBLUE: ColorCode           = 'FF4682B4';
  MSG_COLOR_TAN: ColorCode                 = 'FFD2B48C';
  MSG_COLOR_TEAL: ColorCode                = 'FF008080';
  MSG_COLOR_THISTLE: ColorCode             = 'FFD8BFD8';
  MSG_COLOR_TOMATO: ColorCode              = 'FFFF6347';
  MSG_COLOR_TRANSPARENT: ColorCode         = '00FFFFFF';
  MSG_COLOR_TURQUOISE: ColorCode           = 'FF40E0D0';
  MSG_COLOR_VIOLET: ColorCode              = 'FFEE82EE';
  MSG_COLOR_WHEAT: ColorCode               = 'FFF5DEB3';
  MSG_COLOR_WHITE: ColorCode               = 'FFFFFFFF';
  MSG_COLOR_WHITESMOKE: ColorCode          = 'FFF5F5F5';
  MSG_COLOR_YELLOW: ColorCode              = 'FFFFFF00';
  MSG_COLOR_YELLOWGREEN: ColorCode         = 'FF9ACD32';

  { Chat predefined type colors }
  MSG_CHAT_SAY                                                = '00FFFFFF';
  MSG_CHAT_PARTY                                              = '00FFAAAA';
  MSG_CHAT_RAID                                               = '00007FFF';
  MSG_CHAT_GUILD                                              = '0040FF40';
  MSG_CHAT_OFFICER                                            = '0040C040';
  MSG_CHAT_YELL                                               = '004040FF';
  MSG_CHAT_WHISPER                                            = '00FF80FF';
  MSG_CHAT_WHISPER_INFORM                                     = '00FF80FF';
  MSG_CHAT_EMOTE                                              = '004080FF';
  MSG_CHAT_TEXT_EMOTE                                         = '004080FF';
  MSG_CHAT_SYSTEM                                             = '0000FFFF';
  MSG_CHAT_MONSTER_SAY                                        = '009FFFFF';
  MSG_CHAT_MONSTER_YELL                                       = '004040FF';
  MSG_CHAT_MONSTER_EMOTE                                      = '004080FF';
  MSG_CHAT_CHANNEL                                            = '00C0C0FF';
  MSG_CHAT_CHANNEL_JOIN                                       = '008080C0';
  MSG_CHAT_CHANNEL_LEAVE                                      = '008080C0';
  MSG_CHAT_CHANNEL_LIST                                       = '008080C0';
  MSG_CHAT_CHANNEL_NOTICE                                     = '00C0C0C0';
  MSG_CHAT_CHANNEL_NOTICE_USER                                = '00C0C0C0';
  MSG_CHAT_AFK                                                = '00FF80FF';
  MSG_CHAT_DND                                                = '00FF80FF';
  MSG_CHAT_IGNORED                                            = '000000FF';
  MSG_CHAT_SKILL                                              = '00FF5555';
  MSG_CHAT_LOOT                                               = '0000AA00';
  MSG_CHAT_COMBAT_MISC_INFO                                   = '00FF8080';
  MSG_CHAT_MONSTER_WHISPER                                    = '00B3B3B3';
  MSG_CHAT_COMBAT_SELF_HITS                                   = '00FFFFFF';
  MSG_CHAT_COMBAT_SELF_MISSES                                 = '00FFFFFF';
  MSG_CHAT_COMBAT_PET_HITS                                    = '00FFFFFF';
  MSG_CHAT_COMBAT_PET_MISSES                                  = '00FFFFFF';
  MSG_CHAT_COMBAT_PARTY_HITS                                  = '00FFFFFF';
  MSG_CHAT_COMBAT_PARTY_MISSES                                = '00FFFFFF';
  MSG_CHAT_COMBAT_FRIENDLYPLAYER_HITS                         = '00FFFFFF';
  MSG_CHAT_COMBAT_FRIENDLYPLAYER_MISSES                       = '00FFFFFF';
  MSG_CHAT_COMBAT_HOSTILEPLAYER_HITS                          = '00FFFFFF';
  MSG_CHAT_COMBAT_HOSTILEPLAYER_MISSES                        = '00FFFFFF';
  MSG_CHAT_COMBAT_CREATURE_VS_SELF_HITS                       = '002F2FFF';
  MSG_CHAT_COMBAT_CREATURE_VS_SELF_MISSES                     = '002F2FFF';
  MSG_CHAT_COMBAT_CREATURE_VS_PARTY_HITS                      = '00FFFFFF';
  MSG_CHAT_COMBAT_CREATURE_VS_PARTY_MISSES                    = '00FFFFFF';
  MSG_CHAT_COMBAT_CREATURE_VS_CREATURE_HITS                   = '00FFFFFF';
  MSG_CHAT_COMBAT_CREATURE_VS_CREATURE_MISSES                 = '00FFFFFF';
  MSG_CHAT_COMBAT_FRIENDLY_DEATH                              = '00FFFFFF';
  MSG_CHAT_COMBAT_HOSTILE_DEATH                               = '00FFFFFF';
  MSG_CHAT_COMBAT_XP_GAIN                                     = '00FF6F6F';
  MSG_CHAT_SPELL_SELF_DAMAGE                                  = '0000FFFF';
  MSG_CHAT_SPELL_SELF_BUFF                                    = '0000FFFF';
  MSG_CHAT_SPELL_PET_DAMAGE                                   = '00FFFFFF';
  MSG_CHAT_SPELL_PET_BUFF                                     = '00FFFFFF';
  MSG_CHAT_SPELL_PARTY_DAMAGE                                 = '00FFFFFF';
  MSG_CHAT_SPELL_PARTY_BUFF                                   = '00FFFFFF';
  MSG_CHAT_SPELL_FRIENDLYPLAYER_DAMAGE                        = '00FFFFFF';
  MSG_CHAT_SPELL_FRIENDLYPLAYER_BUFF                          = '00FFFFFF';
  MSG_CHAT_SPELL_HOSTILEPLAYER_DAMAGE                         = '00FFFFFF';
  MSG_CHAT_SPELL_HOSTILEPLAYER_BUFF                           = '00FFFFFF';
  MSG_CHAT_SPELL_CREATURE_VS_SELF_DAMAGE                      = '00D94CCA';
  MSG_CHAT_SPELL_CREATURE_VS_SELF_BUFF                        = '00FFFFFF';
  MSG_CHAT_SPELL_CREATURE_VS_PARTY_DAMAGE                     = '00FFFFFF';
  MSG_CHAT_SPELL_CREATURE_VS_PARTY_BUFF                       = '00FFFFFF';
  MSG_CHAT_SPELL_CREATURE_VS_CREATURE_DAMAGE                  = '00FFFFFF';
  MSG_CHAT_SPELL_CREATURE_VS_CREATURE_BUFF                    = '00FFFFFF';
  MSG_CHAT_SPELL_TRADESKILLS                                  = '00FFFFFF';
  MSG_CHAT_SPELL_DAMAGESHIELDS_ON_SELF                        = '00FFFFFF';
  MSG_CHAT_SPELL_DAMAGESHIELDS_ON_OTHERS                      = '00FFFFFF';
  MSG_CHAT_SPELL_AURA_GONE_SELF                               = '00FFFFFF';
  MSG_CHAT_SPELL_AURA_GONE_PARTY                              = '00FFFFFF';
  MSG_CHAT_SPELL_AURA_GONE_OTHER                              = '00FFFFFF';
  MSG_CHAT_SPELL_ITEM_ENCHANTMENTS                            = '00FFFFFF';
  MSG_CHAT_SPELL_BREAK_AURA                                   = '00FFFFFF';
  MSG_CHAT_SPELL_PERIODIC_SELF_DAMAGE                         = '00FFFFFF';
  MSG_CHAT_SPELL_PERIODIC_SELF_BUFFS                          = '00FFFFFF';
  MSG_CHAT_SPELL_PERIODIC_PARTY_DAMAGE                        = '00FFFFFF';
  MSG_CHAT_SPELL_PERIODIC_PARTY_BUFFS                         = '00FFFFFF';
  MSG_CHAT_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE               = '00FFFFFF';
  MSG_CHAT_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS                = '00FFFFFF';
  MSG_CHAT_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE                = '00FFFFFF';
  MSG_CHAT_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS                 = '00FFFFFF';
  MSG_CHAT_SPELL_PERIODIC_CREATURE_DAMAGE                     = '00FFFFFF';
  MSG_CHAT_SPELL_PERIODIC_CREATURE_BUFFS                      = '00FFFFFF';
  MSG_CHAT_SPELL_FAILED_LOCALPLAYER                           = '00FFFFFF';
  MSG_CHAT_COMBAT_HONOR_GAIN                                  = '000ACAE0';
  MSG_CHAT_BG_SYSTEM_NEUTRAL                                  = '000A78FF';
  MSG_CHAT_BG_SYSTEM_ALLIANCE                                 = '00EFAE00';
  MSG_CHAT_BG_SYSTEM_HORDE                                    = '000000FF';
  MSG_CHAT_COMBAT_FACTION_CHANGE                              = '00FF8080';
  MSG_CHAT_MONEY                                              = '0000FFFF';
  MSG_CHAT_RAID_LEADER                                        = '00B7DBFF';
  MSG_CHAT_RAID_WARNING                                       = '00B7DBFF';
  MSG_CHAT_FOREIGN_TELL                                       = '00FF80FF';
  MSG_CHAT_RAID_BOSS_EMOTE                                    = '00B7DBFF';
  MSG_CHAT_FILTERED                                           = '000000FF';
  MSG_CHAT_BATTLEGROUND                                       = '00007FFF';
  MSG_CHAT_BATTLEGROUND_LEADER                                = '00B7DBFF';
  MSG_CHAT_CHANNEL1                                           = '00C0C0FF';
  MSG_CHAT_CHANNEL2                                           = '00C0C0FF';
  MSG_CHAT_CHANNEL3                                           = '00C0C0FF';
  MSG_CHAT_CHANNEL4                                           = '00C0C0FF';
  MSG_CHAT_CHANNEL5                                           = '00C0C0FF';
  MSG_CHAT_CHANNEL6                                           = '00C0C0FF';
  MSG_CHAT_CHANNEL7                                           = '00C0C0FF';
  MSG_CHAT_CHANNEL8                                           = '00C0C0FF';
  MSG_CHAT_CHANNEL9                                           = '00C0C0FF';
  MSG_CHAT_CHANNEL10                                          = '00C0C0FF';
{$ENDREGION}

const
{$REGION 'EQUIPMENT Constants'}
  ITEMS_START = 0;
  ITEMS_END = 88;

  EQUIPMENT_SLOT_START = 0;
  EQUIPMENT_SLOT_END = 18;

  INVENTORY_SLOT_BAG_START = 19;
  INVENTORY_SLOT_BAG_END = 22;

  INVENTORY_SLOT_ITEM_START = 23;
  INVENTORY_SLOT_ITEM_END = 38;

  BANK_SLOT_ITEM_START = 39;
  BANK_SLOT_ITEM_END = 62;

  BANK_SLOT_BAG_START = 63;
  BANK_SLOT_BAG_END = 68;

  BUYBACK_SLOT_START = 69;
  BUYBACK_SLOT_END = 80;

  KEYRING_SLOT_START = 81;
  KEYRING_SLOT_END = 88;

  BAG_NULL = UInt8(-1);
  SLOT_NULL = UInt8(-1);
  
  EQUIPMENT_COUNT = EQUIPMENT_SLOT_END - EQUIPMENT_SLOT_START + 1;
  BAG_COUNT = INVENTORY_SLOT_BAG_END - INVENTORY_SLOT_BAG_START + 1;
  BACKPACK_COUNT = INVENTORY_SLOT_ITEM_END - INVENTORY_SLOT_ITEM_START + 1;
  BANK_COUNT = BANK_SLOT_ITEM_END - BANK_SLOT_ITEM_START + 1;
  BANKBAG_COUNT = BUYBACK_SLOT_END - BUYBACK_SLOT_START + 1;
  BUYBACK_COUNT = BUYBACK_SLOT_END - BUYBACK_SLOT_START + 1;
  KEYRING_COUNT = KEYRING_SLOT_END - KEYRING_SLOT_START + 1;
  
  EQUIP_SLOT_HEAD          = 0;
  EQUIP_SLOT_NECK          = 1;
  EQUIP_SLOT_SHOULDERS     = 2;
  EQUIP_SLOT_SHIRT         = 3;
  EQUIP_SLOT_CHEST         = 4;
  EQUIP_SLOT_BELT          = 5;
  EQUIP_SLOT_PANTS         = 6;
  EQUIP_SLOT_BOOTS         = 7;
  EQUIP_SLOT_WRIST         = 8;
  EQUIP_SLOT_GLOVES        = 9;
  EQUIP_SLOT_FINGER_1      = 10;
  EQUIP_SLOT_FINGER_2      = 11;
  EQUIP_SLOT_TRINKET_1     = 12;
  EQUIP_SLOT_TRINKET_2     = 13;
  EQUIP_SLOT_BACK          = 14;
  EQUIP_SLOT_MAIN_HAND     = 15;
  EQUIP_SLOT_OFF_HAND      = 16;
  EQUIP_SLOT_RANGED_WEAPON = 17;
  EQUIP_SLOT_TABARD        = 18;

type
  {$Z4}
  YEquipmentSlot = (esHead, esNeck, esShoulders, esShirt, esChest, esBelt,
    esPants, esBoots, esWrist, esGloves, esFinger1, esFinger2, esTrinket1,
    esTrinket2, esBack, esMainHand, esOffHand, esRanged, esTabard);

  YEquipmentSlots = set of YEquipmentSlot;
  {$Z1}

const
  esAll = [esHead..esTabard];
  esArmorSlots = [esHead, esShoulders, esChest, esBelt, esPants, esBoots, esWrist,
    esGloves, esBack];
  esWeaponSlots = [esMainHand, esOffHand, esRanged];
  esRingSlots = [esFinger1, esFinger2];
  esTrinketSlots = [esTrinket1, esTrinket2];
  esMisc = [esNeck, esShirt, esTabard];
{$ENDREGION}

const
{$REGION 'ITEM STATS Constants'}
  ITEM_STAT_HEALTH = 1;
  ITEM_STAT_POWER = 2;
  ITEM_STAT_AGILITY = 3;
  ITEM_STAT_STRENGTH = 4;
  ITEM_STAT_INTELLECT = 5;
  ITEM_STAT_SPIRIT = 6;
  ITEM_STAT_STAMINA = 7;
{$ENDREGION}

const
{$REGION 'TRADE STATUS Constants and others related with TRADE'}
  TRADE_STATUS_BUSY = 0;
  TRADE_STATUS_OK = 1;
  TRADE_STATUS_BEGIN = 2;
  TRADE_STATUS_CANCEL = 3;
  TRADE_STATUS_ACCEPT = 4;
  TRADE_STATUS_TRADER_NOT_FOUND = 6;
  TRADE_STATUS_UNACCEPT = 7;
  TRADE_STATUS_COMPLETE = 8;
  TRADE_STATUS_TOO_FAR = 10;
  TRADE_STATUS_DIFFERENT_FACTION = 11;
  TRADE_STATUS_IGNORE = 14;
  TRADE_STATUS_YOU_ARE_STUNT = 15;
  TRADE_STATUS_YOUR_TARGET_IS_STUNT = 16;
  TRADE_STATUS_YOU_DEAD = 17;
  TRADE_STATUS_TRADER_DEAD = 18;
  TRADE_STATUS_YOU_LOGGING_OUT = 19;
  TRADE_STATUS_TRADER_LOGGING_OUT = 20;

  MAXIMUM_TRADE_ITEMS = 7;
{$ENDREGION}

const
{$REGION 'NPC Constants'}
  DIALOG_STATUS_NONE           = 0;
  DIALOG_STATUS_UNAVAILABLE    = 1;
  DIALOG_STATUS_CHAT           = 2;
  DIALOG_STATUS_INCOMPLETE     = 3;
  DIALOG_STATUS_REWARD_REP     = 4;
  DIALOG_STATUS_AVAILABLE      = 5;
  DIALOG_STATUS_REWARD_OLD     = 6;
  DIALOG_STATUS_REWARD         = 7;

  SUBMENU_TAXI                 = 1;
  SUBMENU_VENDOR               = 2;
  SUBMENU_TRAINER              = 3;
  SUBMENU_BANKER               = 4;
  SUBMENU_INKEEPER_BIND        = 5;
  SUBMENU_INKEEPER_MSG         = 6;
  SUBMENU_TABARD               = 7;
  SUBMENU_PETITION             = 8;

	MENUICON_GOSSIP              = $00;
	MENUICON_VENDOR              = $01;
	MENUICON_TAXI                = $02;
	MENUICON_TRAINER             = $03;
	MENUICON_HEALER              = $04;
	MENUICON_BINDER              = $05;
	MENUICON_BANKER              = $06;
	MENUICON_PETITION            = $07;
	MENUICON_TABARD              = $08;
	MENUICON_BATTLEMASTER        = $09;
	MENUICON_AUCTIONER           = $0A;
	MENUICON_GOSSIP2             = $0B;
	MENUICON_GOSSIP3             = $0C;

	NPC_KIND_SPIRITHEALER        = 1;
	NPC_KIND_DIALOG              = 2;
	NPC_KIND_VENDOR              = 4;
	NPC_KIND_TAXI                = 8;
  NPC_KIND_TRAINER             = $10;
  NPC_KIND_HEALER              = $20;
  NPC_KIND_BF_SPIRITHEALER     = $40;
	NPC_KIND_INKEEPER            = $80;
	NPC_KIND_BANKER              = $100;
	NPC_KIND_PETITION            = $200;
	NPC_KIND_TABARD              = $400;
	NPC_KIND_BATTLEMASTER        = $800;
	NPC_KIND_AUCTIONER           = $1000;
	NPC_KIND_STABLEMASTER        = $2000;
{$ENDREGION}

const
{$REGION 'QUESTS Constants'}
  INVALIDREASON_DONT_HAVE_REQ        = 0;
  INVALIDREASON_DONT_HAVE_REQLEVEL   = 1;
  INVALIDREASON_DONT_HAVE_RACE       = 6;
  INVALIDREASON_HAVE_TIMED_QUEST     = 12;
  INVALIDREASON_HAVE_QUEST           = 13;
  INVALIDREASON_DONT_HAVE_REQ_ITEMS  = 19+1;
  INVALIDREASON_DONT_HAVE_REQ_MONEY  = 21+1;

  QUEST_PARTY_MSG_SHARRING_QUEST  = 0;
  QUEST_PARTY_MSG_CANT_TAKE_QUEST = 1;
  QUEST_PARTY_MSG_ACCEPT_QUEST    = 2;
  QUEST_PARTY_MSG_REFUSE_QUEST    = 3;
  QUEST_PARTY_MSG_TO_FAR          = 4;
  QUEST_PARTY_MSG_BUSY            = 5;
  QUEST_PARTY_MSG_LOG_FULL        = 6;
  QUEST_PARTY_MSG_HAVE_QUEST      = 7;
  QUEST_PARTY_MSG_FINISH_QUEST    = 8;

  QUEST_TRSKILL_NONE           = 0;
  QUEST_TRSKILL_ALCHEMY        = 1;
  QUEST_TRSKILL_BLACKSMITHING  = 2;
  QUEST_TRSKILL_COOKING        = 3;
  QUEST_TRSKILL_ENCHANTING     = 4;
  QUEST_TRSKILL_ENGINEERING    = 5;
  QUEST_TRSKILL_FIRSTAID       = 6;
  QUEST_TRSKILL_HERBALISM      = 7;
  QUEST_TRSKILL_LEATHERWORKING = 8;
  QUEST_TRSKILL_POISONS        = 9;
  QUEST_TRSKILL_TAILORING      = 10;
  QUEST_TRSKILL_MINING         = 11;
  QUEST_TRSKILL_FISHING        = 12;
  QUEST_TRSKILL_SKINNING       = 13;
  QUEST_TRSKILL_JEWELCRAFTING  = 14;

  QUEST_STATUS_NONE            = 0;
  QUEST_STATUS_COMPLETE        = 1;
  QUEST_STATUS_UNAVAILABLE     = 2;
  QUEST_STATUS_INCOMPLETE      = 3;
  QUEST_STATUS_AVAILABLE       = 4;

  {$IFNDEF WOW_TBC}
    QUEST_LOG_COUNT = 20;
  {$ELSE}
    QUEST_LOG_COUNT = 25;
  {$ENDIF}
  QUEST_OBJECTS_COUNT = 6;
{$ENDREGION}

const
{$REGION 'Player BLOCK / DODGE / PARRY default percentages, and some other PLAYER consts'}
  PLAYER_BLOCK = 1.045455;
  PLAYER_DODGE = 1.212414;
  PLAYER_PARRY = 0.04;
  PLAYER_DEFAULT_BOUNDING_RADIUS = 0.388999998569489;
  PLAYER_DEFAULT_COMBAT_REACH = 1.5;
  PLAYER_MAXIMUM_ACTION_BUTTONS = 120;
  PLAYER_MAXIMUM_TUTORIALS = 7;
  PLAYER_MOVEMENT_LOCKED = 2;
  PLAYER_MOVEMENT_UNLOCKED = 1;  
{$ENDREGION}

const
{$REGION 'UNIT_STAND_STATES'}
  UNIT_STATE_STAND            = 0;
  UNIT_STATE_SIT              = 1;
  UNIT_STATE_SIT_CHAIR        = 2;
  UNIT_STATE_SLEEP            = 3;
  UNIT_STATE_SIT_LOW_CHAIR    = 4;
  UNIT_STATE_SIT_MEDIUM_CHAIR = 5;
  UNIT_STATE_SIT_HIGH_CHAIR   = 6;
  UNIT_STATE_DEAD             = 7;
  UNIT_STATE_KNEEL            = 8;
{$ENDREGION}

const
{$REGION 'UNIT_FIELD_FLAGS'}
   UNIT_FIELD_FLAG_NONE                       = $00000000;
   UNIT_FIELD_FLAG_UNKNOWN_01                 = $00000001;
   UNIT_FIELD_FLAG_UNKNOWN_02                 = $00000002;
   UNIT_FIELD_FLAG_LOCK_PLAYER                = $00000004;
   UNIT_FIELD_FLAG_PLAYER_CONTROLLED          = $00000008;
   UNIT_FIELD_FLAG_UNKNOWN_03                 = $00000010;
   UNIT_FIELD_FLAG_UNKNOWN_04                 = $00000020;
   UNIT_FIELD_FLAG_PLUS_MOB                   = $00000040;
   UNIT_FIELD_FLAG_UNKNOWN_05                 = $00000080;
   UNIT_FIELD_FLAG_WATERWALK                  = $00000100;
   UNIT_FIELD_FLAG_UNKNOWN_07                 = $00000200;
   UNIT_FILED_ANIMATION_LOOTING               = $00000400;         //correct
   UNIT_FIELD_FLAG_SWIM                       = $00000800;
   UNIT_FIELD_FLAG_PVP                        = $00001000;         //correct
   UNIT_FIELD_FLAG_MOUNT_SIT                  = $00002000;
   UNIT_FIELD_FLAG_HEALTHBAR                  = $00004000; //possible death too
   UNIT_FIELD_FLAG_SNEAK                      = $00008000;
   UNIT_FIELD_FLAG_ALIVE                      = $00010000;
   UNIT_FIELD_FLAG_UNKNOWN_10                 = $00020000;
   UNIT_FIELD_FLAG_DUEL_WINNER                = $00040000;
   UNIT_FIELD_FLAG_ATTACK_ANIMATION           = $00080000;         //correct
   UNIT_FIELD_FLAG_STAR_AFTER_NAME            = $00100000;
   UNIT_FIELD_FLAG_UNKNOWN_11                 = $00200000;
   UNIT_FIELD_FLAG_ROOTED                     = $00400000;
   UNIT_FIELD_FLAG_UNKNOWN_13                 = $00800000;
   UNIT_FIELD_FLAG_PLAYER_CONTROLLED_CREATURE = $01000000;
   UNIT_FIELD_FLAG_UNKNOWN_14                 = $02000000;
   UNIT_FIELD_FLAG_SKINNABLE                  = $04000000;
   UNIT_FIELD_FLAG_INVULNERABLE               = $08000000;
   UNIT_FIELD_FLAG_UNKNOWN_15                 = $10000000;
   UNIT_FIELD_FLAG_UNKNOWN_16                 = $20000000;
   UNIT_FIELD_FLAG_SHEATH_ON                  = $40000000;
   UNIT_FIELD_FLAG_UNKNOWN_17                 = $80000000;
{$ENDREGION}

const
{$REGION 'UNIT FIELD BYTES 2 BYTES DESCRIPTIONS'}
  UFB2_SHEATH_MAIN_WEAPONS = 0;
  UFB2_SHEATH_RANGED_WEAPONS = 1;
{$ENDREGION}

const
{$REGION 'Honor Constants'}
  { Please note that these ranks have different names for the HORDE but this does not matter }
  {   as the actual ranks are the same for both of them }
  UNIT_HONOR_RANK_NONE                       = 00;           //rank 0
  UNIT_HONOR_RANK_PARIAH                     = 01;           //rank -4
  UNIT_HONOR_RANK_OUTLAW                     = 02;           //rank -3
  UNIT_HONOR_RANK_EXILED                     = 03;           //rank -2
  UNIT_HONOR_RANK_DISHONORED                 = 04;           //rank -1
  UNIT_HONOR_RANK_PRIVATE                    = 05;           //rank 1
  UNIT_HONOR_RANK_CORPORAL                   = 06;           //rank 2
  UNIT_HONOR_RANK_SERGEANT                   = 07;           //rank 3
  UNIT_HONOR_RANK_MASTER_SERGEANT            = 08;           //rank 4
  UNIT_HONOR_RANK_SERGEANT_MAJOR             = 09;           //rank 5
  UNIT_HONOR_RANK_KNIGHT                     = 10;           //rank 6
  UNIT_HONOR_RANK_KNIGHT_LIEUTENANT          = 11;           //rank 7
  UNIT_HONOR_RANK_KNIGHT_CAPTAIN             = 12;           //rank 8
  UNIT_HONOR_RANK_KNIGHT_CHAMPION            = 13;           //rank 9
  UNIT_HONOR_RANK_LIEUTENANT_COMMANDER       = 14;           //rank 10
  UNIT_HONOR_RANK_COMMANDER                  = 15;           //rank 11
  UNIT_HONOR_RANK_MARSHAL                    = 16;           //rank 12
  UNIT_HONOR_RANK_FIELD_MARSHAL              = 17;           //rank 13
  UNIT_HONOR_RANK_GRAND_MARSHAL              = 18;           //rank 14
  
  { these constants are used to identify the members of fHonorStats array }
  HONOR_START             = 0;
  TODAY_HONORABLE         = 0;
  TODAY_DISHONORABLE      = 1;
  TODAY_HONOR             = 2;
  YESTERDAY_HONORABLE     = 3;
  YESTERDAY_HONOR         = 4;
  THIS_WEEK_HONORABLE     = 5;
  THIS_WEEK_HONOR         = 6;
  THIS_WEEK_STANDING      = 7;
  LAST_WEEK_HONORABLE     = 8;
  LAST_WEEK_HONOR         = 9;
  LAST_WEEK_STANDING      = 10;
  LIFETIME_HONORABLE      = 11;
  LIFETIME_DISHONORABLE   = 12;
  LIFETIME_HIGHEST_RANK   = 13;
  LIFETIME_RANK_POINTS    = 14;
  HONOR_RANK              = 15;
  ID_YESTERDAY            = 16;    /// it'll be stored as (day shl 16) + month
  ID_LAST_WEEK            = 17;    /// it'll be stored as (week shl 16) + year
  HONOR_END               = ID_LAST_WEEK;

  HONOR_POINTS_PER_KILL         = 3;
  HONOR_POINTS_NONE             = 0;
  HONOR_RANK_DIF_MULTIPLIER     = 2;
  HONOR_STANDING_DIF_MULTIPLIER = 2;
  HONOR_PER_REP_PERCENT         = 2;
{$ENDREGION}

implementation

end.
