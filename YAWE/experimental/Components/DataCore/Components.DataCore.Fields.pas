{*------------------------------------------------------------------------------
  Data Fields.

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
unit Components.DataCore.Fields;

interface

{ The Section Fields }
const
  FIELD_ID        : string =  'IID';

{ Accounts Fields }
const
  FIELD_ACC_NAME      : string =  'SNAME';
  FIELD_ACC_PASS      : string =  'SPASS';
  FIELD_ACC_ACCESS    : string =  'IACCESS';
  FIELD_ACC_STATUS    : string =  'ISTATUS';
  FIELD_ACC_HASH      : string =  'SHASHKEY';
  FIELD_ACC_LOGGEDIN  : string =  'ILOGGEDIN';
  FIELD_ACC_AUTOCREATE: string =  'IAUTOCREATED'; 

{ Security Group Fields }
const
  FIELD_SG_NAME    : string =  'SGROUPNAME';
  FIELD_SG_MOD     : string =  'IMODERATOR';
  FIELD_SG_MEMBERS : string =  'LMEMBERS';
  FIELD_SG_PRIVS   : string =  'LPRIVILEDGES';

{ Char Templates Fields }
const
  FIELD_CT_RACE         : string =  'SRACE';
  FIELD_CT_CLASS        : string =  'SCLASS';
  FIELD_CT_START_MAP    : string =  'ISTART{MAP}';
  FIELD_CT_START_ZONE   : string =  'ISTART{ZONE}';
  FIELD_CT_START_X      : string =  'FSTART{X}';
  FIELD_CT_START_Y      : string =  'FSTART{Y}';
  FIELD_CT_START_Z      : string =  'FSTART{Z}';
  FIELD_CT_START_O      : string =  'FSTART{ORIENTATION}';
  FIELD_CT_STAT_STR     : string =  'ISTATS{STRENGTH}';
  FIELD_CT_STAT_AGI     : string =  'ISTATS{AGILITY}';
  FIELD_CT_STAT_STA     : string =  'ISTATS{STAMINA}';
  FIELD_CT_STAT_INT     : string =  'ISTATS{INTELLECT}';
  FIELD_CT_STAT_SPI     : string =  'ISTATS{SPIRIT}';
  FIELD_CT_BODY_FEM     : string =  'IBODYTEXTURE{FEMALE}';
  FIELD_CT_BODY_MAL     : string =  'IBODYTEXTURE{MALE}';
  FIELD_CT_BODY_SIZE    : string =  'FSIZE';
  FIELD_CT_POWER_TYPE   : string =  'IPOWER{TYPE}';
  FIELD_CT_POWER_BASE   : string =  'IPOWER{BASE}';
  FIELD_CT_POWER        : string =  'IPOWER';
  FIELD_CT_LVL_UP_POWER : string =  'IONLEVELUP{POWER}';
  FIELD_CT_LVL_UP_STR   : string =  'IONLEVELUP{STRENGTH}';
  FIELD_CT_LVL_UP_AGI   : string =  'IONLEVELUP{AGILITY}';
  FIELD_CT_LVL_UP_STA   : string =  'IONLEVELUP{STAMINA}';
  FIELD_CT_LVL_UP_INT   : string =  'IONLEVELUP{INTELLECT}';
  FIELD_CT_LVL_UP_SPI   : string =  'IONLEVELUP{SPIRIT}';
  FIELD_CT_HEALTH_BASE  : string =  'IHEALTH{BASE}';
  FIELD_CT_LVL_UP_HLTH  : string =  'IONLEVELUP{HEALTH}';
  FIELD_CT_SKILL        : string =  'LSKILL';
  FIELD_CT_SPELL        : string =  'LSPELL';
  FIELD_CT_ITEM         : string =  'LITEM';
  FIELD_CT_ATTACK_TIMES : string =  'LATTACKTIME';
  FIELD_CT_ATTACK_POWER : string =  'IATTACK{POWER}';
  FIELD_CT_ATTACK_DMGHI : string =  'IATTACK{DMGLO}';
  FIELD_CT_ATTACK_DMGLO : string =  'IATTACK{DMGHI}';
  FIELD_CT_ACTION_BTNS  : string =  'LACTIONBUTTONS';
  FIELD_CT_EQUIP_ITEMS  : string =  'LEQUIPEDITEMS';
  FIELD_CT_DEFENCE      : string =  'IDEFENCE';


{ OpenObject Fields }
const
  FIELD_UPDATE_DATA   : string =  'LDATA';

{ Opne Mobile Fields }
const
  FIELD_MOI_POS_X         : string =  'FPOSX';
  FIELD_MOI_POS_Y         : string =  'FPOSY';
  FIELD_MOI_POS_Z         : string =  'FPOSZ';
  FIELD_MOI_POS_O         : string =  'FPOSO';
  FIELD_MOI_POS_MI        : string =  'IMAPID';
  FIELD_MOI_POS_ZI        : string =  'IZONEID';

  FIELD_MOI_SPD_WALK      : string =  'FSPD_WALK';
  FIELD_MOI_SPD_RUN       : string =  'FSPD_RUN';
  FIELD_MOI_SPD_BKSWIM    : string =  'FSPD_BKSWIM';
  FIELD_MOI_SPD_SWIM      : string =  'FSPD_SWIM';
  FIELD_MOI_SPD_BKWALK    : string =  'FSPD_BKWALK';
  FIELD_MOI_SPD_TURN      : string =  'FSPD_TURN';

{ Node Fields }
const
  FIELD_NODE_FLAGS    : string =  'IFLAGS';
  FIELD_NODE_NEXT     : string =  'LNEXT';
  FIELD_NODE_PREV     : string =  'LPREV';
  FIELD_NODE_SPAWNS   : string =  'LSPAWNDATA';

{ Addon Fields }
const
  FIELD_ADDON_NAME    : string =  'SADDONNAME';
  FIELD_ADDON_CRC     : string =  'IADDONPROVIDERID';
  FIELD_ADDON_VALID   : string =  'BVALIDATED';

{ OpenUnit Fields }
const
  FIELD_UNI_POWER_OLU     : string =  'IPOWERONLVLUP';
  FIELD_UNI_HEALTH_OLU    : string =  'IHEALTHONLVLUP';
  FIELD_UNI_STR_OLU       : string =  'ISTRENGTHONLVLUP';
  FIELD_UNI_AGL_OLU       : string =  'IAGILITYONLVLUP';
  FIELD_UNI_STA_OLU       : string =  'ISTAMINAONLVLUP';
  FIELD_UNI_ITL_OLU       : string =  'IINTELLECTONLVLUP';
  FIELD_UNI_SPI_OLU       : string =  'ISPIRITONLVLUP';

{ OpenPlayer Fields }
const
  FIELD_PLI_ACCOUNT_NAME   : string = 'SACCOUNTNAME';
  FIELD_PLI_CHAR_NAME      : string = 'SCHARNAME';
  FIELD_PLI_RESTED_STATE   : string = 'IRESTED';
  FIELD_PLI_TUTORIALS      : string = 'LTUTORIALS';
  FIELD_PLI_EQUIPMENT      : string = 'LEQUIPMENT';
  FIELD_PLI_ACTION_BTNS    : string = 'LACTIONBUTTONS'; 
  FIELD_PLI_HONOR_STATS    : string = 'LHONORSTATS';
  FIELD_PLI_ACTIVE_QUESTS  : string = 'LACTIVEQUESTS';
  FIELD_PLI_FINISHED_QUESTS: string = 'LFINISHEDQUESTS';

{ OpenItem Fields }
const
  FIELD_ITI_ENTRY      : string = 'IENTRY';
  FIELD_ITI_STACKCOUNT : string = 'ISTACKCOUNT';
  FIELD_ITI_DURABILITY : string = 'IDURABILITY';
  FIELD_ITI_CONTAINED  : string = 'IOWNERITEM';
  FIELD_ITI_CREATOR    : string = 'ICREATOR';
  FIELD_ITI_ITEMS      : string = 'LITEMS';

{ Item Templates }
const
  FIELD_ITM_CLASS                : string = 'ICLASS{MAIN}';
  FIELD_ITM_SUBCLASS             : string = 'ICLASS{SUB}';
  FIELD_ITM_TBC_UNKNOWN          : string = 'IUNKNOWN{TBC}';
  FIELD_ITM_BASE_NAME            : string = 'SNAME{MAIN}';
  FIELD_ITM_QUEST_NAME           : string = 'SNAME{QUEST}';
  FIELD_ITM_PVP_NAME             : string = 'SNAME{PVP}';
  FIELD_ITM_PERSONALIZED_NAME    : string = 'SNAME{PER}';
  FIELD_ITM_MODEL_ID             : string = 'IMODELID';
  FIELD_ITM_QUALITY              : string = 'IQUALITY';
  FIELD_ITM_FLAGS                : string = 'IFLAGS{ITEM}';
  FIELD_ITM_BUY_PRICE            : string = 'IPRICE{BUY}';
  FIELD_ITM_SELL_PRICE           : string = 'IPRICE{SELL}';
  FIELD_ITM_INVENTORY_TYPE       : string = 'IINVENTORYTYPE';
  FIELD_ITM_ALLOWABLE_RACE       : string = 'IALLOWABLERACE';
  FIELD_ITM_ALLOWABLE_CLASS      : string = 'IALLOWABLECLASS';
  FIELD_ITM_ITEM_LEVEL           : string = 'IITEMLEVEL';
  FIELD_ITM_REQ_LEVEL            : string = 'IREQUIRES{LEVEL}';
  FIELD_ITM_REQ_SKILL            : string = 'IREQUIRES{SKILL}';
  FIELD_ITM_REQ_SKILL_RANK       : string = 'IREQUIRES{SKILLRANK}';
  FIELD_ITM_REQ_SPELL            : string = 'IREQUIRES{SPELL}';
  FIELD_ITM_REQ_FACTION          : string = 'IREQUIRES{FACTION}';
  FIELD_ITM_REQ_FACTION_LEVEL    : string = 'IREQUIRES{FACTIONLVL}';
  FIELD_ITM_REQ_PVP_RANK_1       : string = 'IREQUIRES{PVPRANK1}';
  FIELD_ITM_REQ_PVP_RANK_2       : string = 'IREQUIRES{PVPRANK2}';
  FIELD_ITM_UNIQUE_FLAG          : string = 'IUNIQUEFLAG';
  FIELD_ITM_MAX_NO_OF_ITEMS      : string = 'IMAXCOUNT';
  FIELD_ITM_CONTAINER_SLOTS      : string = 'ICONTAINERSLOTS';
  FIELD_ITM_STAT_TYPE_0          : string = 'IITEMSTATTYPE{0}';
  FIELD_ITM_STAT_VALUE_0         : string = 'IITEMSTATVALUE{0}';
  FIELD_ITM_STAT_TYPE_1          : string = 'IITEMSTATTYPE{1}';
  FIELD_ITM_STAT_VALUE_1         : string = 'IITEMSTATVALUE{1}';
  FIELD_ITM_STAT_TYPE_2          : string = 'IITEMSTATTYPE{2}';
  FIELD_ITM_STAT_VALUE_2         : string = 'IITEMSTATVALUE{2}';
  FIELD_ITM_STAT_TYPE_3          : string = 'IITEMSTATTYPE{3}';
  FIELD_ITM_STAT_VALUE_3         : string = 'IITEMSTATVALUE{3}';
  FIELD_ITM_STAT_TYPE_4          : string = 'IITEMSTATTYPE{4}';
  FIELD_ITM_STAT_VALUE_4         : string = 'IITEMSTATVALUE{4}';
  FIELD_ITM_STAT_TYPE_5          : string = 'IITEMSTATTYPE{5}';
  FIELD_ITM_STAT_VALUE_5         : string = 'IITEMSTATVALUE{5}';
  FIELD_ITM_STAT_TYPE_6          : string = 'IITEMSTATTYPE{6}';
  FIELD_ITM_STAT_VALUE_6         : string = 'IITEMSTATVALUE{6}';
  FIELD_ITM_STAT_TYPE_7          : string = 'IITEMSTATTYPE{7}';
  FIELD_ITM_STAT_VALUE_7         : string = 'IITEMSTATVALUE{7}';
  FIELD_ITM_STAT_TYPE_8          : string = 'IITEMSTATTYPE{8}';
  FIELD_ITM_STAT_VALUE_8         : string = 'IITEMSTATVALUE{8}';
  FIELD_ITM_STAT_TYPE_9          : string = 'IITEMSTATTYPE{9}';
  FIELD_ITM_STAT_VALUE_9         : string = 'IITEMSTATVALUE{9}';
  FIELD_ITM_DAMAGE_MIN_0         : string = 'FDAMAGEMIN{0}';
  FIELD_ITM_DAMAGE_MAX_0         : string = 'FDAMAGEMAX{0}';
  FIELD_ITM_DAMAGE_TYPE_0        : string = 'IDAMAGETYPE{0}';
  FIELD_ITM_DAMAGE_MIN_1         : string = 'FDAMAGEMIN{1}';
  FIELD_ITM_DAMAGE_MAX_1         : string = 'FDAMAGEMAX{1}';
  FIELD_ITM_DAMAGE_TYPE_1        : string = 'IDAMAGETYPE{1}';
  FIELD_ITM_DAMAGE_MIN_2         : string = 'FDAMAGEMIN{2}';
  FIELD_ITM_DAMAGE_MAX_2         : string = 'FDAMAGEMAX{2}';
  FIELD_ITM_DAMAGE_TYPE_2        : string = 'IDAMAGETYPE{2}';
  FIELD_ITM_DAMAGE_MIN_3         : string = 'FDAMAGEMIN{3}';
  FIELD_ITM_DAMAGE_MAX_3         : string = 'FDAMAGEMAX{3}';
  FIELD_ITM_DAMAGE_TYPE_3        : string = 'IDAMAGETYPE{3}';
  FIELD_ITM_DAMAGE_MIN_4         : string = 'FDAMAGEMIN{4}';
  FIELD_ITM_DAMAGE_MAX_4         : string = 'FDAMAGEMAX{4}';
  FIELD_ITM_DAMAGE_TYPE_4        : string = 'IDAMAGETYPE{4}';
  FIELD_ITM_RESISTANCE_PHYSICAL  : string = 'IRESISTANCE{PHYSICAL}';     //iResistance{Phisical}
  FIELD_ITM_RESISTANCE_HOLY      : string = 'IRESISTANCE{HOLY}';
  FIELD_ITM_RESISTANCE_FIRE      : string = 'IRESISTANCE{FIRE}';
  FIELD_ITM_RESISTANCE_NATURE    : string = 'IRESISTANCE{NATURE}';
  FIELD_ITM_RESISTANCE_FROST     : string = 'IRESISTANCE{FROST}';
  FIELD_ITM_RESISTANCE_SHADOW    : string = 'IRESISTANCE{SHADOW}';
  FIELD_ITM_RESISTANCE_ARCANE    : string = 'IRESISTANCE{ARCANE}';
  FIELD_ITM_DELAY                : string = 'IDELAY';
  FIELD_ITM_AMMO_TYPE            : string = 'IAMMOTYPE';
  FIELD_ITM_MOD_RANGE            : string = 'IRANGEMODIFIER';
  FIELD_ITM_SPELL_TRIGGER_0      : string = 'ISPELLTRIGGER{0}';
  FIELD_ITM_SPELL_ID_0           : string = 'ISPELLID{0}';
  FIELD_ITM_SPELL_CHARGES_0      : string = 'ISPELLCHARGES{0}';
  FIELD_ITM_SPELL_COOLDOWN_0     : string = 'ISPELLCOOLDOWN{0}';
  FIELD_ITM_SPELL_CATEGORY_0     : string = 'ISPELLCATEGORY{0}';
  FIELD_ITM_SPELL_CATEGORY_COOL_0: string = 'ISPELLCATEGORYCOOL{0}';
  FIELD_ITM_SPELL_TRIGGER_1      : string = 'ISPELLTRIGGER{1}';
  FIELD_ITM_SPELL_ID_1           : string = 'ISPELLID{1}';
  FIELD_ITM_SPELL_CHARGES_1      : string = 'ISPELLCHARGES{1}';
  FIELD_ITM_SPELL_COOLDOWN_1     : string = 'ISPELLCOOLDOWN{1}';
  FIELD_ITM_SPELL_CATEGORY_1     : string = 'ISPELLCATEGORY{1}';
  FIELD_ITM_SPELL_CATEGORY_COOL_1: string = 'ISPELLCATEGORYCOOL{1}';
  FIELD_ITM_SPELL_TRIGGER_2      : string = 'ISPELLTRIGGER{2}';
  FIELD_ITM_SPELL_ID_2           : string = 'ISPELLID{2}';
  FIELD_ITM_SPELL_CHARGES_2      : string = 'ISPELLCHARGES{2}';
  FIELD_ITM_SPELL_COOLDOWN_2     : string = 'ISPELLCOOLDOWN{2}';
  FIELD_ITM_SPELL_CATEGORY_2     : string = 'ISPELLCATEGORY{2}';
  FIELD_ITM_SPELL_CATEGORY_COOL_2: string = 'ISPELLCATEGORYCOOL{2}';
  FIELD_ITM_SPELL_TRIGGER_3      : string = 'ISPELLTRIGGER{3}';
  FIELD_ITM_SPELL_ID_3           : string = 'ISPELLID{3}';
  FIELD_ITM_SPELL_CHARGES_3      : string = 'ISPELLCHARGES{3}';
  FIELD_ITM_SPELL_COOLDOWN_3     : string = 'ISPELLCOOLDOWN{3}';
  FIELD_ITM_SPELL_CATEGORY_3     : string = 'ISPELLCATEGORY{3}';
  FIELD_ITM_SPELL_CATEGORY_COOL_3: string = 'ISPELLCATEGORYCOOL{3}';
  FIELD_ITM_SPELL_TRIGGER_4      : string = 'ISPELLTRIGGER{4}';
  FIELD_ITM_SPELL_ID_4           : string = 'ISPELLID{4}';
  FIELD_ITM_SPELL_CHARGES_4      : string = 'ISPELLCHARGES{4}';
  FIELD_ITM_SPELL_COOLDOWN_4     : string = 'ISPELLCOOLDOWN{4}';
  FIELD_ITM_SPELL_CATEGORY_4     : string = 'ISPELLCATEGORY{4}';
  FIELD_ITM_SPELL_CATEGORY_COOL_4: string = 'ISPELLCATEGORYCOOL{4}';
  FIELD_ITM_BONDING              : string = 'IBONDING';
  FIELD_ITM_DESCRIPTION          : string = 'SDESCRIPTION';
  FIELD_ITM_PAGE_ID              : string = 'IPAGE{ID}';
  FIELD_ITM_PAGE_LANGUAGE        : string = 'IPAGE{LANGUAGE}';
  FIELD_ITM_PAGE_MATERIAL        : string = 'IPAGE{MATERIAL}';
  FIELD_ITM_STARTS_QUEST         : string = 'ISTARTQUEST';
  FIELD_ITM_LOCK_ID              : string = 'ILOCK{ID}';
  FIELD_ITM_LOCK_MATERIAL        : string = 'ILOCK{MATERIAL)';
  FIELD_ITM_SHEATH               : string = 'ISHEATH';
  FIELD_ITM_EXTRA_INFO           : string = 'IEXTRAINFO';
  FIELD_ITM_RAND_PROPERTY        : string = 'IRANDOMPROPERTY';
  FIELD_ITM_BLOCK                : string = 'IBLOCK';
  FIELD_ITM_ITEMSET              : string = 'IITEMSET';
  FIELD_ITM_MAX_DURABILITY       : string = 'IMAXDURABILITY';
  FIELD_ITM_AREA                 : string = 'IAREA';
  FIELD_ITM_MAP                  : string = 'IMAP';
  FIELD_ITM_BAG_FAMILY           : string = 'IBAGFAMILY';          //added in 1.11.X
  FIELD_ITM_TOTEM_CATEGORY       : string = 'ITOTEMCATEGORY';          //added in 1.11.X  
  FIELD_ITM_SOCKET_COLOR_0       : string = 'ISCOKETCOLOR{0}';
  FIELD_ITM_SOCKET_UNKNOWN_0     : string = 'ISOCKETUNKNOWN{0}';
  FIELD_ITM_SOCKET_COLOR_1       : string = 'ISCOKETCOLOR{1}';
  FIELD_ITM_SOCKET_UNKNOWN_1     : string = 'ISOCKETUNKNOWN{1}';
  FIELD_ITM_SOCKET_COLOR_2       : string = 'ISCOKETCOLOR{2}';
  FIELD_ITM_SOCKET_UNKNOWN_2     : string = 'ISOCKETUNKNOWN{2}';
  FIELD_ITM_SOCKET_BONUS         : string = 'ISOCKETBONUS';
  FIELD_ITM_GEM_PROPERTIES       : string = 'IGEMPROPERTIES';
  FIELD_ITM_EXTENDED_COST        : string = 'IEXTENDEDCOST';
  FIELD_ITM_REQ_DISENCHANT_SKILL : string = 'IREQUIREDDISENCHANTSKILL';

 { Creature Templates }
const
  FIELD_CRT_MAIN_NAME  : string = 'SNAME{MAIN}';
  FIELD_CRT_SUB_NAME   : string = 'SNAME{0}';
  FIELD_CRT_GUILD_NAME : string = 'SNAME{GUILD}';
  FIELD_CRT_TEXTURE    : string = 'IMODELID';
  FIELD_CRT_MAX_HEALTH : string = 'IMAXHEALTH';
  FIELD_CRT_MAX_MANA   : string = 'IMAXMANA';
  FIELD_CRT_LEVEL      : string = 'ILEVEL';
  FIELD_CRT_MAX_LEVEL  : string = 'IMAXLEVEL';
  FIELD_CRT_ARMOR      : string = 'IARMOR';
  FIELD_CRT_FACTION    : string = 'IFACTION';
  FIELD_CRT_NPC_FLAGS  : string = 'IFLAGS{NPC}';
  FIELD_CRT_RANK       : string = 'IRANK';
  FIELD_CRT_FAMILY     : string = 'IFAMILY';
  FIELD_CRT_GENDER     : string = 'IGENDER';
  FIELD_CRT_BA_POWER   : string = 'IBASEATTACKPOWER';
  FIELD_CRT_BA_TIME    : string = 'IBASEATTACKTIME';
  FIELD_CRT_RA_POWER   : string = 'IRANGEDATTACKPOWER';
  FIELD_CRT_RA_TIME    : string = 'IRANGEDATTACKTIME';
  FIELD_CRT_FLAGS      : string = 'IFLAGS{UNIT}';
  FIELD_CRT_DYN_FLAGS  : string = 'IDYNFLAGS{UNIT}';
  FIELD_CRT_CLASS      : string = 'ICLASS';
  FIELD_CRT_TRAINER_TYPE : string = 'ITRAINERTYPE';
  FIELD_CRT_MOUNT      : string = 'IMOUNTID';
  FIELD_CRT_TYPE       : string = 'ITYPE';
  FIELD_CRT_CIVILIAN   : string = 'ICIVILIAN';
  FIELD_CRT_ELITE      : string = 'IELITE';
  FIELD_CRT_UNIT_TYPE  : string = 'ITYPE{UNIT}';
  FIELD_CRT_UNIT_FLAGS : string = 'IFLAGS{UNIT}';
  FIELD_CRT_WALK_SPEED : string = 'FSPEED{WALK}';
  FIELD_CRT_ATTACK_TIME_HI : string = 'IATTACKTIME{HI}';
  FIELD_CRT_ATTACK_TIME_LO : string = 'IATTACKTIME{LO}';
  FIELD_CRT_RATTACK_TIME_HI : string = 'IRANGEDATTACKTIME{HI}';
  FIELD_CRT_RATTACK_TIME_LO : string = 'IRANGEDATTACKTIME{LO}';
  FIELD_CRT_SCALE      : string = 'FSCALE';
  FIELD_CRT_BOUNDING_RADIUS : string = 'FBOUNDINGRADIUS';
  FIELD_CRT_COMBAT_REACH : string = 'FCOMBATREACH';
  FIELD_CRT_EQUIPED_ITEM_0        : string = 'IEQUIPEDITEM{0}';
  FIELD_CRT_EQUIPED_ITEM_0_INFO_0 : string = 'IEQUIPEDITEMINFO0{0}';
  FIELD_CRT_EQUIPED_ITEM_0_INFO_1 : string = 'IEQUIPEDITEMINFO1{0}';
  FIELD_CRT_EQUIPED_ITEM_1        : string = 'IEQUIPEDITEM{1}';
  FIELD_CRT_EQUIPED_ITEM_1_INFO_0 : string = 'IEQUIPEDITEMINFO1{1}';
  FIELD_CRT_EQUIPED_ITEM_1_INFO_1 : string = 'IEQUIPEDITEMINFO1{1}';
  FIELD_CRT_EQUIPED_ITEM_2        : string = 'IEQUIPEDITEM{2}';
  FIELD_CRT_EQUIPED_ITEM_2_INFO_0 : string = 'IEQUIPEDITEMINFO0{2}';
  FIELD_CRT_EQUIPED_ITEM_2_INFO_1 : string = 'IEQUIPEDITEMINFO1{2}';
  FIELD_CRT_RESISTANCE_PHYSICAL   : string = 'IRESISTANCE{PHYSICAL}';
  FIELD_CRT_RESISTANCE_HOLY       : string = 'IRESISTANCE{HOLY}';
  FIELD_CRT_RESISTANCE_FIRE       : string = 'IRESISTANCE{FIRE}';
  FIELD_CRT_RESISTANCE_NATURE     : string = 'IRESISTANCE{NATURE}';
  FIELD_CRT_RESISTANCE_FROST      : string = 'IRESISTANCE{FROST}';
  FIELD_CRT_RESISTANCE_SHADOW     : string = 'IRESISTANCE{SHADOW}';
  FIELD_CRT_RESISTANCE_ARCANE     : string = 'IRESISTANCE{ARCANE}';
  FIELD_CRT_DAMAGE_MINIMUM        : string = 'IDAMAGE{LO}';
  FIELD_CRT_DAMAGE_MAXIMUM        : string = 'IDAMAGE{HI}';
  FIELD_CRT_RANGED_DAMAGE_MIN     : string = 'IRANGEDDAMAGE{LO}';
  FIELD_CRT_RANGED_DAMAGE_MAX     : string = 'IRANGEDDAMAGE{HI}';

 { NPC Texts Template Constants }
const
  FIELD_NPCT_TEXT_0_0      : string = 'STEXT0{0}';
  FIELD_NPCT_TEXT_0_1      : string = 'STEXT0{1}';
  FIELD_NPCT_TEXT_0_2      : string = 'STEXT0{2}';
  FIELD_NPCT_TEXT_0_3      : string = 'STEXT0{3}';
  FIELD_NPCT_TEXT_0_4      : string = 'STEXT0{4}';
  FIELD_NPCT_TEXT_0_5      : string = 'STEXT0{5}';
  FIELD_NPCT_TEXT_0_6      : string = 'STEXT0{6}';
  FIELD_NPCT_TEXT_0_7      : string = 'STEXT0{7}';
  FIELD_NPCT_TEXT_1_0      : string = 'STEXT1{0}';
  FIELD_NPCT_TEXT_1_1      : string = 'STEXT1{1}';
  FIELD_NPCT_TEXT_1_2      : string = 'STEXT1{2}';
  FIELD_NPCT_TEXT_1_3      : string = 'STEXT1{3}';
  FIELD_NPCT_TEXT_1_4      : string = 'STEXT1{4}';
  FIELD_NPCT_TEXT_1_5      : string = 'STEXT1{5}';
  FIELD_NPCT_TEXT_1_6      : string = 'STEXT1{6}';
  FIELD_NPCT_TEXT_1_7      : string = 'STEXT1{7}';
  FIELD_NPCT_PROBABILITY_0 : string = 'FPROBABILITY{0}';
  FIELD_NPCT_PROBABILITY_1 : string = 'FPROBABILITY{1}';
  FIELD_NPCT_PROBABILITY_2 : string = 'FPROBABILITY{2}';
  FIELD_NPCT_PROBABILITY_3 : string = 'FPROBABILITY{3}';
  FIELD_NPCT_PROBABILITY_4 : string = 'FPROBABILITY{4}';
  FIELD_NPCT_PROBABILITY_5 : string = 'FPROBABILITY{5}';
  FIELD_NPCT_PROBABILITY_6 : string = 'FPROBABILITY{6}';
  FIELD_NPCT_PROBABILITY_7 : string = 'FPROBABILITY{7}';
  FIELD_NPCT_LANGUAGE_0    : string = 'ILANGUAGE{0}';
  FIELD_NPCT_LANGUAGE_1    : string = 'ILANGUAGE{1}';
  FIELD_NPCT_LANGUAGE_2    : string = 'ILANGUAGE{2}';
  FIELD_NPCT_LANGUAGE_3    : string = 'ILANGUAGE{3}';
  FIELD_NPCT_LANGUAGE_4    : string = 'ILANGUAGE{4}';
  FIELD_NPCT_LANGUAGE_5    : string = 'ILANGUAGE{5}';
  FIELD_NPCT_LANGUAGE_6    : string = 'ILANGUAGE{6}';
  FIELD_NPCT_LANGUAGE_7    : string = 'ILANGUAGE{7}';
  FIELD_NPCT_EMOTE_ID_0_0  : string = 'IEMOTEID0{0}';
  FIELD_NPCT_EMOTE_ID_1_0  : string = 'IEMOTEID1{0}';
  FIELD_NPCT_EMOTE_ID_2_0  : string = 'IEMOTEID2{0}';
  FIELD_NPCT_EMOTE_ID_0_1  : string = 'IEMOTEID0{1}';
  FIELD_NPCT_EMOTE_ID_1_1  : string = 'IEMOTEID1{1}';
  FIELD_NPCT_EMOTE_ID_2_1  : string = 'IEMOTEID2{1}';
  FIELD_NPCT_EMOTE_ID_0_2  : string = 'IEMOTEID0{2}';
  FIELD_NPCT_EMOTE_ID_1_2  : string = 'IEMOTEID1{2}';
  FIELD_NPCT_EMOTE_ID_2_2  : string = 'IEMOTEID2{2}';
  FIELD_NPCT_EMOTE_ID_0_3  : string = 'IEMOTEID0{3}';
  FIELD_NPCT_EMOTE_ID_1_3  : string = 'IEMOTEID1{3}';
  FIELD_NPCT_EMOTE_ID_2_3  : string = 'IEMOTEID2{3}';
  FIELD_NPCT_EMOTE_ID_0_4  : string = 'IEMOTEID0{4}';
  FIELD_NPCT_EMOTE_ID_1_4  : string = 'IEMOTEID1{4}';
  FIELD_NPCT_EMOTE_ID_2_4  : string = 'IEMOTEID2{4}';
  FIELD_NPCT_EMOTE_ID_0_5  : string = 'IEMOTEID0{5}';
  FIELD_NPCT_EMOTE_ID_1_5  : string = 'IEMOTEID1{5}';
  FIELD_NPCT_EMOTE_ID_2_5  : string = 'IEMOTEID2{5}';
  FIELD_NPCT_EMOTE_ID_0_6  : string = 'IEMOTEID0{6}';
  FIELD_NPCT_EMOTE_ID_1_6  : string = 'IEMOTEID1{6}';
  FIELD_NPCT_EMOTE_ID_2_6  : string = 'IEMOTEID2{6}';
  FIELD_NPCT_EMOTE_ID_0_7  : string = 'IEMOTEID0{7}';
  FIELD_NPCT_EMOTE_ID_1_7  : string = 'IEMOTEID1{7}';
  FIELD_NPCT_EMOTE_ID_2_7  : string = 'IEMOTEID2{7}';
  FIELD_NPCT_EMOTE_DELAY_0_0  : string = 'IEMOTEDELAY0{0}';
  FIELD_NPCT_EMOTE_DELAY_1_0  : string = 'IEMOTEDELAY1{0}';
  FIELD_NPCT_EMOTE_DELAY_2_0  : string = 'IEMOTEDELAY2{0}';
  FIELD_NPCT_EMOTE_DELAY_0_1  : string = 'IEMOTEDELAY0{1}';
  FIELD_NPCT_EMOTE_DELAY_1_1  : string = 'IEMOTEDELAY1{1}';
  FIELD_NPCT_EMOTE_DELAY_2_1  : string = 'IEMOTEDELAY2{1}';
  FIELD_NPCT_EMOTE_DELAY_0_2  : string = 'IEMOTEDELAY0{2}';
  FIELD_NPCT_EMOTE_DELAY_1_2  : string = 'IEMOTEDELAY1{2}';
  FIELD_NPCT_EMOTE_DELAY_2_2  : string = 'IEMOTEDELAY2{2}';
  FIELD_NPCT_EMOTE_DELAY_0_3  : string = 'IEMOTEDELAY0{3}';
  FIELD_NPCT_EMOTE_DELAY_1_3  : string = 'IEMOTEDELAY1{3}';
  FIELD_NPCT_EMOTE_DELAY_2_3  : string = 'IEMOTEDELAY2{3}';
  FIELD_NPCT_EMOTE_DELAY_0_4  : string = 'IEMOTEDELAY0{4}';
  FIELD_NPCT_EMOTE_DELAY_1_4  : string = 'IEMOTEDELAY1{4}';
  FIELD_NPCT_EMOTE_DELAY_2_4  : string = 'IEMOTEDELAY2{4}';
  FIELD_NPCT_EMOTE_DELAY_0_5  : string = 'IEMOTEDELAY0{5}';
  FIELD_NPCT_EMOTE_DELAY_1_5  : string = 'IEMOTEDELAY1{5}';
  FIELD_NPCT_EMOTE_DELAY_2_5  : string = 'IEMOTEDELAY2{5}';
  FIELD_NPCT_EMOTE_DELAY_0_6  : string = 'IEMOTEDELAY0{6}';
  FIELD_NPCT_EMOTE_DELAY_1_6  : string = 'IEMOTEDELAY1{6}';
  FIELD_NPCT_EMOTE_DELAY_2_6  : string = 'IEMOTEDELAY2{6}';
  FIELD_NPCT_EMOTE_DELAY_0_7  : string = 'IEMOTEDELAY0{7}';
  FIELD_NPCT_EMOTE_DELAY_1_7  : string = 'IEMOTEDELAY1{7}';
  FIELD_NPCT_EMOTE_DELAY_2_7  : string = 'IEMOTEDELAY2{7}';

  { Quest Template Constants }
const
  FIELD_QUEST_REQ_LEVEL      : string = 'IREQUIRESLEVEL';
  FIELD_QUEST_CATEGORY       : string = 'ICATEGORY';
  FIELD_QUEST_QUEST_LEVEL    : string = 'IQUESTLEVEL';
  FIELD_QUEST_MONEY_REWARD   : string = 'IMONEYREWARD';
  FIELD_QUEST_TIME_OBJECTIVE : string = 'ITIMEOBJECTIVE';
  FIELD_QUEST_PREV_QUEST     : string = 'IOPENEDBYQUEST';
  FIELD_QUEST_NEXT_QUEST     : string = 'INEXTSTORYQUEST';
  FIELD_QUEST_COMPLEXITY     : string = 'ICOMPLEXITY';
  FIELD_QUEST_LEARN_SPELL    : string = 'ILEARNSPELL';
  FIELD_QUEST_EXPLORE_OBJECTIVE : string = 'IEXPLOREOBJECTIVE';
  FIELD_QUEST_Q_FINISH_NPC   : string = 'IQUESTFINISHER{NPC}';
  FIELD_QUEST_Q_FINISH_OBJ   : string = 'IQUESTFINISHER{OBJ}';
  FIELD_QUEST_Q_FINISH_ITM   : string = 'IQUESTFINISHER{ITM}';
  FIELD_QUEST_Q_GIVER_NPC    : string = 'IQUESTGIVER{NPC}';
  FIELD_QUEST_Q_GIVER_OBJ    : string = 'IQUESTGIVER{OBJ}';
  FIELD_QUEST_Q_GIVER_ITM    : string = 'IQUESTGIVER{ITM}';
  FIELD_QUEST_DESCRIPTIVE_FLAGS : string = 'IDESCRIPTIVEFLAGS';
  FIELD_QUEST_NAME              : string = 'SNAME';
  FIELD_QUEST_OBJECTIVES        : string = 'SOBJECTIVES';
  FIELD_QUEST_DETAILS           : string = 'SDETAILS';
  FIELD_QUEST_END_TEXT          : string = 'SENDTEXT';
  FIELD_QUEST_COMPLETE_TEXT     : string = 'SCOMPLETETEXT';
  FIELD_QUEST_INCOMPLETE_TEXT   : string = 'SINCOMPLETETEXT';
  FIELD_QUEST_OBJECTIVE_TEXT_1  : string = 'SOBJECTIVETEXT1';
  FIELD_QUEST_OBJECTIVE_TEXT_2  : string = 'SOBJECTIVETEXT2';
  FIELD_QUEST_OBJECTIVE_TEXT_3  : string = 'SOBJECTIVETEXT3';
  FIELD_QUEST_OBJECTIVE_TEXT_4  : string = 'SOBJECTIVETEXT4';
  FIELD_QUEST_DELIVER_OBJECTIVE : string = 'LDELIVEROBJECTIVE';
  FIELD_QUEST_REWARD_ITM_CHOICE : string = 'LREWARDITEMCHOICE';
  FIELD_QUEST_RECEIVE_ITEM      : string = 'LRECEIVEITEM';
  FIELD_QUEST_LOCATION          : string = 'SLOCATION';
  FIELD_QUEST_KILL_OBJECTIVE_MOB : string = 'LKILLOBJECTIVE{MOB}';
  FIELD_QUEST_KILL_OBJECTIVE_OBJ : string = 'LKILLOBJECTIVE{OBJ}';
  FIELD_QUEST_REQ_REPUTATION   : string = 'LREPUTATIONOBJECTIVE';
  FIELD_QUEST_REWARD_ITEM       : string = 'LREWARDITEM';
  FIELD_QUEST_REQUIRES_RACE     : string = 'LREQUIRESRACE';
  FIELD_QUEST_REQUIRES_CLASS    : string = 'LREQUIRESCLASS';
  FIELD_QUEST_REQ_TRADE_SKILL   : string = 'LREQUIRESTRADESKILL';
  FIELD_QUEST_QUEST_BEHAVIOR    : string = 'LQUESTBEHAVIOR';

 { Game Objects Templates }
const
  FIELD_GOT_TYPE      : string = 'ITYPE{GO}';
  FIELD_GOT_TEXTUREID : string = 'IMODELID';
  FIELD_GOT_NAME      : string = 'SNAME{MAIN}';
  FIELD_GOT_FACTION   : string = 'IFACTION';
  FIELD_GOT_FLAGS     : string = 'IFLAGS{GO}';
  FIELD_GOT_SIZE      : string = 'FSCALE';
  FIELD_GOT_SOUND_0   : string = 'ISOUND{0}';
  FIELD_GOT_SOUND_1   : string = 'ISOUND{1}';
  FIELD_GOT_SOUND_2   : string = 'ISOUND{2}';
  FIELD_GOT_SOUND_3   : string = 'ISOUND{3}';
  FIELD_GOT_SOUND_4   : string = 'ISOUND{4}';
  FIELD_GOT_SOUND_5   : string = 'ISOUND{5}';
  FIELD_GOT_SOUND_6   : string = 'ISOUND{6}';
  FIELD_GOT_SOUND_7   : string = 'ISOUND{7}';
  FIELD_GOT_SOUND_8   : string = 'ISOUND{8}';
  FIELD_GOT_SOUND_9   : string = 'ISOUND{9}';
  FIELD_GOT_SOUND_10  : string = 'ISOUND{10}';
  FIELD_GOT_SOUND_11  : string = 'ISOUND{11}';

implementation

end.
