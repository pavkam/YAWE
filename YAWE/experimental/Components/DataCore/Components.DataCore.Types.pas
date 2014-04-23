{*------------------------------------------------------------------------------
  List of types and routines for the use with the DB-system.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.DataCore.Types;

interface

uses
  Misc.Miscleanous,
  Misc.Containers,
  SysUtils,
  Framework.TypeRegistry,
  Components.GameCore.Constants,
  Components.DataCore.DynamicObjectFormat,
  Framework.SerializationRegistry,
  Framework.Base,
  Components.Shared,
  Components.GameCore.UpdateFields,
  Components.DataCore.Fields;

type
  YDbSerializable = class;
  YDbSerializables = array of YDbSerializable;
  YDbSerializableClass = class of YDbSerializable;

  ISerializable = interface(IInterface)
  ['{A32B47E4-47A5-4824-8296-81EC2DC26D86}']
    { private }
    function GetUniqueId: UInt32;
    function GetContexts: IIntfIterator;
    function GetContext(const Name: string): IDofStreamable;
    procedure SetContext(const Name: string; const Value: IDofStreamable);

    { public }
    property UniqueId: UInt32 read GetUniqueId;
    property Contexts: IIntfIterator read GetContexts;
    property Context[const Name: string]: IDofStreamable read GetContext write SetContext;
  end;

  YDbSerializable = class(TBaseInterfacedObject, ISerializable, IDofStreamable)
    private
      fContexts: TStrIntfHashMap;
      
      function GetUniqueId: UInt32;
      function GetContexts: IIntfIterator;
      function GetContext(const Name: string): IDofStreamable;
      procedure SetContext(const Name: string; const Value: IDofStreamable);
    protected
      fId: UInt32;

      procedure WriteContexts(const Writer: IDofWriter);
      procedure ReadContexts(const Reader: IDofReader);

      procedure ReadCustomProperties(const Reader: IDofReader); virtual; stdcall;
      procedure WriteCustomProperties(const Writer: IDofWriter); virtual; stdcall;
      procedure RegisterClassFields(Registry: TSerializationRegistry); virtual; 
    public
      constructor Create; virtual;
      destructor Destroy; override;

      class procedure RegisterSelf(Registry: TSerializationRegistry);
      class function IsReadOnly: Boolean; virtual; abstract;

      procedure Assign(cSerializable: YDbSerializable); virtual;
      procedure AfterLoad; virtual;

      property Contexts: IIntfIterator read GetContexts;
      property Context[const Name: string]: IDofStreamable read GetContext write SetContext;
    published
      property UniqueId: UInt32 read fId write fId;
  end;

  YDbRoSerializable = class(YDbSerializable)
    public
      class function IsReadOnly: Boolean; override;
  end;

  YDbRwSerializable = class(YDbSerializable)
    public
      class function IsReadOnly: Boolean; override;
  end;

  YAccountStatus = (asNormal, asLocked, asBanned, asPayNotify);
  YAccountAccess = (aaNormal, aaReservedSlots, aaGM, aaAdmin);

  PItemData = ^YItemData;
  YItemData = record
    Slot: UInt32;
    Id: UInt32;
    Count: UInt32;
  end;

  YItemDataArray = array of YItemData;

  PQuestObject = ^YQuestObject;
  YQuestObject = record
    Id: UInt32;
    Count: UInt32;
  end;

  PQuestObjects = ^YQuestObjects;
  YQuestObjects = record
    Count: Int32;
    Objects: array[0..QUEST_OBJECTS_COUNT - 1] of YQuestObject;
  end;

  PSkillData = ^YSkillData;
  YSkillData = record
    Id: UInt32;
    Initial: UInt32;
    Max: UInt32;
  end;

  YSkillDataArray = array of YSkillData;

  YDoubleDword = array[0..1] of UInt32;

  YQuestBehavior = (qbKill, qbDelivery, qbSpeakTo, qbTimed);
  YQuestBehaviors = set of YQuestBehavior;

  //same for Class, Race, etc.

  PQuestLocation = ^YQuestLocation;
  YQuestLocation = record
    Area: UInt32;
    X, Y, Z: Float; 
  end;

  PQuest = ^YQuest;
  YQuest = record
    Id: UInt32;
    KillObjectives: array[0..QUEST_OBJECTS_COUNT - 1] of UInt32;
    NeedExplore: Boolean; {TODO 3 -oBIGBOSS -cQuest : Save special objectives}
  end;

  PActiveQuests = ^YActiveQuests;
  YActiveQuests = record
    Count: Int32;
    Quests: array[0..QUEST_LOG_COUNT - 1] of YQuest;
  end;

  YTPPlace = record
    Name: string;
	  Map: UInt32;
	  X, Y, Z: float;
  end;

  YTPPlaces = array of YTPPlace;

  PStatRec = ^YStatRec;
  YStatRec = record
    StatType: YStatBonusType;
    Value: UInt32;
  end;

  PWeaponDamageRec = ^YWeaponDamageRec;
  YWeaponDamageRec = record
    Min: Float;
    Max: Float;
    DamageType: YDamageType;
  end;

  PItemSpellRec = ^YItemSpellRec;
  YItemSpellRec = record
    Id: UInt32;
    Trigger: UInt32;
    Charges: UInt32;
    Cooldown: UInt32;
    Category: UInt32;
    CategoryCooldown: UInt32;
  end;

  ICharTemplate = interface(ISerializable)
  ['{3786BD34-3D75-4B5F-B8DF-37B9A9F4AA30}']
  end;

  YDbCharTemplate = class(YDbRoSerializable, ICharTemplate)
    private
      fRace: string;
      fClass: string;
      fMapId: UInt32;
      fZoneId: UInt32;
      fX: Float;
      fY: Float;
      fZ: Float;
      fO: Float;
      fStrength: UInt32;
      fAgility: UInt32;
      fStamina: UInt32;
      fIntellect: UInt32;
      fSpirit: UInt32;
      fMaleBody: UInt32;
      fFemaleBody: UInt32;
      fBodySize: Float;
      fPowerType: UInt32;
      fBasePower: UInt32;
      fBaseHealth: UInt32;
      fPower: UInt32;

      fSkillData: YSkillDataArray;
      fSpells: TLongWordDynArray;
      fItemData: YItemDataArray;

      fAttackTimeLo: UInt32;
      fAttackTimeHi: UInt32;
      fAttackPower: UInt32;
      fAttackDamageHi: UInt32;
      fAttackDamageLo: UInt32;

      fActionButtons: TLongWordDynArray;
    protected
      procedure RegisterClassFields(Registry: TSerializationRegistry); override;
    public
      procedure Assign(cSerializable: YDbSerializable); override;

      procedure SetSpellsLength(iNewLen: Int32);
      procedure SetActionButtonsLength(iNewLen: Int32);
      procedure SetItemDataLength(iNewLen: Int32);
      procedure SetSkillDataLength(iNewLen: Int32);
    published
      property Race: string read fRace write fRace;
      property PlayerClass: string read fClass write fClass;
      property StartingX: Float read fX write fX;
      property StartingY: Float read fY write fY;
      property StartingZ: Float read fZ write fZ;
      property StartingAngle: Float read fO write fO;
      property Map: UInt32 read fMapId write fMapId;
      property Zone: UInt32 read fZoneId write fZoneId;
      property InitialStrength: UInt32 read fStrength write fStrength;
      property InitialAgility: UInt32 read fAgility write fAgility;
      property InitialStamina: UInt32 read fStamina write fStamina;
      property InitialIntellect: UInt32 read fIntellect write fIntellect;
      property InitialSpirit: UInt32 read fSpirit write fSpirit;
      property MaleBodyModel: UInt32 read fMaleBody;
      property FemaleBodyModel: UInt32 read fFemaleBody;
      property BodySize: Float read fBodySize write fBodySize;
      property PowerType: UInt32 read fPowerType write fPowerType;
      property BasePower: UInt32 read fBasePower write fBasePower;
      property BaseHealth: UInt32 read fBaseHealth write fBaseHealth;
      property Power: UInt32 read fPower write fPower;
      property SkillData: YSkillDataArray read fSkillData write fSkillData;
      property Spells: TLongWordDynArray read fSpells write fSpells;
      property ItemData: YItemDataArray read fItemData write fItemData;
      property AttackTimeLo: UInt32 read fAttackTimeLo write fAttackTimeLo;
      property AttackTimeHi: UInt32 read fAttackTimeHi write fAttackTimeHi;
      property AttackPower: UInt32 read fAttackPower write fAttackPower;
      property BaseDamageLo: UInt32 read fAttackDamageLo write fAttackDamageLo;
      property BaseDamageHi: UInt32 read fAttackDamageHi write fAttackDamageHi;
      property ActionButtons: TLongWordDynArray read fActionButtons write fActionButtons;
  end;

  {$IF ((SizeOf(YGameRaces) + SizeOf(YGameClasses)) mod SizeOf(UInt32)) <> 0}
    {$DEFINE ITEM_TEMPLATE_HAS_PAD}
  {$IFEND}

  IItemTemplate = interface(ISerializable)
  ['{D2BC1C93-EFB5-4967-BBBF-13EB26E95A77}']
  end;

  YDbItemTemplate = class(YDbRoSerializable, IItemTemplate)
    private
      fClass: YItemClass;
      fSubClass: UInt32;
      fUnknown206 : UInt32; //2.0.6 TODO SELBY - check it later
      fModelId: UInt32;
      fQuality: YItemQuality;
      fFlags: UInt32;
      fBuyPrice: UInt32;
      fSellPrice: UInt32;
      fInventoryType: YItemInventoryType;
      fAllowedRaces: YGameRaces;
      fAllowedClasses: YGameClasses;
      {$IFDEF ITEM_TEMPLATE_HAS_PAD}
      { Do not remove, here for alignment! }
      { It looks scary I know. But all it does is automaticly calculating the number of fill-bytes. }
      fPad1: array[0..SizeOf(UInt32)-((SizeOf(YGameRaces) + SizeOf(YGameClasses)) mod SizeOf(UInt32))-1] of UInt8;
      {$ENDIF}
      fItemLevel: UInt32;
      fReqLevel: UInt32;
      fReqSkill: UInt32;
      fReqSkillRank: UInt32;
      fReqSpell: UInt32;
      fReqFaction: UInt32;
      fReqFactionLevel: UInt32;
      fReqPVPRank1: UInt32;
      fReqPVPRank2: UInt32;
      fUniqueFlag: UInt32;
      fMaximumCount: UInt32;   //the max number of items of this type that a char can have
      fContainerSlots: UInt32;
      fStats: array[0..9] of YStatRec;
      fDamageTypes: array[0..4] of YWeaponDamageRec;
      fResistancePhysical: UInt32;
      fResistanceHoly: UInt32;
      fResistanceFire: UInt32;
      fResistanceNature: UInt32;
      fResistanceFrost: UInt32;
      fResistanceShadow: UInt32;
      fResistanceArcane: UInt32;
      fDelay: UInt32;
      fAmmunitionType: UInt32;  //2 = arrows, 3 = bullets
      fRangeModifier: Float;
      fItemSpells: array[0 .. __ITEM_FIELD_SPELL_CHARGES - 1] of YItemSpellRec;
      fBonding: UInt32;
      fPageID: UInt32;
      fPageLanguage: UInt32;
      fPageMaterial: UInt32;
      fStartsQuest: UInt32;
      fLockID: UInt32;
      fLockMaterial: UInt32;
      fSheath: UInt32;
      fExtraInfo: UInt32;
      fExtraInfo2: UInt32;
      fBlock: UInt32;
      fItemSet: UInt32;
      fMaximumDurability: UInt32;
      fArea: UInt32;
      fMapId: UInt32;
      fBagFamily: UInt32;
      fTotemCategory: UInt32;
      fSocketColor1: UInt32;
      fUnk2: UInt32;
      fSocketColor2: UInt32;
      fUnk3: UInt32;
      fSocketColor3: UInt32;
      fUnk4: UInt32;
      fSocketBonus: UInt32;
      fGemProperties: UInt32;
      fItemExtendedCost: UInt32;
      fDisenchantReqSkill: UInt32;
      fName: string;
      fNameForQuest: string;
      fNameHonorable: string;
      fNameEnchanting: string;
      fDescription: string;

      function GetStatData(iIndex: Int32): PStatRec;
      function GetWeaponDamageData(iIndex: Int32): PWeaponDamageRec;
      function GetItemSpellData(iIndex: Int32): PItemSpellRec;
    protected
      procedure RegisterClassFields(Registry: TSerializationRegistry); override;
    public
      procedure Assign(cSerializable: YDbSerializable); override;
      procedure AfterLoad; override;
      procedure FillItemTemplateInfoBuffer(cBuffer: TByteBuffer);

    published
      property MainClass: YItemClass read fClass;
      property SubClass: UInt32 read fSubClass;
      property A206ClassInfo: UInt32 read fUnknown206;
      property ModelId: UInt32 read fModelId;
      property Quality: YItemQuality read fQuality;
      property Flags: UInt32 read fFlags;
      property BuyPrice: UInt32 read fBuyPrice;
      property SellPrice: UInt32 read fSellPrice;
      property InventoryType: YItemInventoryType read fInventoryType;
      property AllowedRaces: YGameRaces read fAllowedRaces;
      property AllowedClasses: YGameClasses read fAllowedClasses;
      property ItemLevel: UInt32 read fItemLevel;
      property ReqLevel: UInt32 read fReqLevel;
      property ReqSkill: UInt32 read fReqSkill;
      property ReqSkillRank: UInt32 read fReqSkillRank;
      property ReqSpell: UInt32 read fReqSpell;
      property ReqFaction: UInt32 read fReqFaction;
      property ReqFactionLevel: UInt32 read fReqFactionLevel;
      property ReqPVPRank1: UInt32 read fReqPVPRank1;
      property ReqPVPRank2: UInt32 read fReqPVPRank2;
      property MaximumCount: UInt32 read fMaximumCount;
      property UniqueFlag: UInt32 read fUniqueFlag;
      property ContainerSlots: UInt32 read fContainerSlots;
      property ResistancePhysical: UInt32 read fResistancePhysical;
      property ResistanceHoly: UInt32 read fResistanceHoly;
      property ResistanceFire: UInt32 read fResistanceFire;
      property ResistanceNature: UInt32 read fResistanceNature;
      property ResistanceFrost: UInt32 read fResistanceFrost;
      property ResistanceShadow: UInt32 read fResistanceShadow;
      property ResistanceArcane: UInt32 read fResistanceArcane;
      property Delay: UInt32 read fDelay;
      property AmunitionType: UInt32 read fAmmunitionType;
      property Bonding: UInt32 read fBonding;
      property RangedModifier: Float read fRangeModifier;
      property PageID: UInt32 read fPageID;
      property PageLanguage: UInt32 read fPageLanguage;
      property PageMaterial: UInt32 read fPageMaterial;
      property StartsQuest: UInt32 read fStartsQuest;
      property LockID: UInt32 read fLockID;
      property LockMaterial: UInt32 read fLockMaterial;
      property Sheath: UInt32 read fSheath;
      property ExtraInfo: UInt32 read fExtraInfo;
      property ExtraInfoAdvanced: UInt32 read fExtraInfo2;
      property Block: UInt32 read fBlock;
      property ItemSet: UInt32 read fItemSet;
      property MaximumDurability: UInt32 read fMaximumDurability;
      property Area: UInt32 read fArea;
      property Name: string read fName;
      property NameForQuest: string read fNameForQuest;
      property NameHonorable: string read fNameHonorable;
      property NameEnchanting: string read fNameEnchanting;
      property Description: string read fDescription;
      property MapId: UInt32 read fMapId;
      property BagFamily: UInt32 read fBagFamily;
      property TotemCategory: UInt32 read fTotemCategory;
      property SocketColor1: UInt32 read fSocketColor1;
      property SocketUnk1: UInt32 read fUnk2;
      property SocketColor2: UInt32 read fSocketColor2;
      property SocketUnk2: UInt32 read fUnk3;
      property SocketColor3: UInt32 read fSocketColor3;
      property SocketUnk3: UInt32 read fUnk4;
      property SocketBonus: UInt32 read fSocketBonus;
      property GemProperties: UInt32 read fGemProperties;
      property ItemExtendedCost: UInt32 read fItemExtendedCost;
      property DisenchantReqSkill: UInt32 read fDisenchantReqSkill;

    public
      property Stats[iIndex: Int32]: PStatRec read GetStatData;
      property Damage[iIndex: Int32]: PWeaponDamageRec read GetWeaponDamageData;
      property Spells[iIndex: Int32]: PItemSpellRec read GetItemSpellData;

  end;

  ICreatureTemplate = interface(ISerializable)
  ['{52AC0E92-DB38-4483-AAAE-07562243D51D}']
  end;

  YDbCreatureTemplate = class(YDbRoSerializable, ICreatureTemplate)
    private
      fEntryName: string;
      fEntryGuildName: string;
      fEntrySubName: string;
      fTextureID: UInt32;
      fMaxHealth: UInt32;
      fMaxMana: UInt32;
      fLevel: UInt32;
      fMaximumLevel: UInt32;
      fArmor: UInt32;
      fFaction: UInt32;
      fNPCFlags: UInt32;
      fRank: UInt32;
      fFamily: UInt32;
      fGender: UInt32;
      fBaseAttackPower: UInt32;
      fBaseAttackTime: UInt32;
      fRangedAttackPower: UInt32;
      fRangedAttackTime: UInt32;
      fFlags: UInt32;
      fDynamicFlags: UInt32;
      fUnitClass: UInt32;
      fTrainerType: UInt32;
      fMountID: UInt32;
      fType: UInt32;
      fCivilian: UInt32;
      fElite: UInt32;
      fUnitType: UInt32;
      fUnitFlags: UInt32;

      fMovementSpeed: Float;
      fDamageMin: Float;
      fDamageMax: Float;
      fRangeDamageMin: Float;
      fRangeDamageMax: Float;
      fScale: Float;
      fBoundingRadius: Float;
      fCombatReach: Float;

      fEquipModel0: UInt32;
      fEquipModel1: UInt32;
      fEquipModel2: UInt32;
      fEquipInfo0: UInt32;
      fEquipInfo1: UInt32;
      fEquipInfo2: UInt32;
      fEquipSlot0: UInt32;
      fEquipSlot1: UInt32;
      fEquipSlot2: UInt32;

      fResistancePhysical: UInt32;
      fResistanceHoly: UInt32;
      fResistanceFire: UInt32;
      fResistanceNature: UInt32;
      fResistanceFrost: UInt32;
      fResistanceShadow: UInt32;
      fResistanceArcane: UInt32;
    protected
      procedure RegisterClassFields(Registry: TSerializationRegistry); override;
    public
      procedure Assign(cSerializable: YDbSerializable); override;
    published
      property EntryName: string read fEntryName;
      property EntryGuildName: string read fEntryGuildName;
      property EntrySubName: string read fEntrySubName;
      property TextureID: UInt32 read fTextureId;
      property MaxHealth: UInt32 read fMaxHealth;
      property MaxMana: UInt32 read fMaxMana;
      property Level: UInt32 read fLevel;
      property MaximumLevel: UInt32 read fMaximumLevel;
      property Armor: UInt32 read fArmor;
      property Faction: UInt32 read fFaction;
      property NPCFlag: UInt32 read fNPCFlags;
      property Rank: UInt32 read fRank;
      property Family: UInt32 read fFamily;
      property Gender: UInt32 read fGender;
      property BaseAttackPower: UInt32 read fBaseAttackPower;
      property BaseAttackTime: UInt32 read fBaseAttackTime;
      property RangedAttackPower: UInt32 read fRangedAttackPower;
      property RangedAttackTime: UInt32 read fRangedAttackTime;
      property EntryFlags: UInt32 read fFlags;
      property DynamicFlags: UInt32 read fDynamicFlags;
      property UnitClass: UInt32 read fUnitClass;
      property TrainerType: UInt32 read fTrainerType;
      property MountID: UInt32 read fMountID;
      property EntryType: UInt32 read fType;
      property Civilian: UInt32 read fCivilian;
      property Elite: UInt32 read fElite;
      property UnitType: UInt32 read fUnitType;
      property UnitFlags: UInt32 read fUnitFlags;
      property MovementSpeed: Float read fMovementSpeed;
      property DamageMin: Float read fDamageMin;
      property DamageMax: Float read fDamageMax;
      property RangeDamageMin: Float read fRangeDamageMin;
      property RangeDamageMax: Float read fRangeDamageMax;
      property EntrySize: Float read fScale;
      property BoundingRadius: Float read fBoundingRadius;
      property CombatReach: Float read fCombatReach;
      property ResistancePhysical: UInt32 read fResistancePhysical;
      property ResistanceHoly: UInt32 read fResistanceHoly;
      property ResistanceFire: UInt32 read fResistanceFire;
      property ResistanceNature: UInt32 read fResistanceNature;
      property ResistanceFrost: UInt32 read fResistanceFrost;
      property ResistanceShadow: UInt32 read fResistanceShadow;
      property ResistanceArcane: UInt32 read fResistanceArcane;
  end;

  IGameObjectTemplate = interface(ISerializable)
  ['{070E0F98-589F-46A3-9CBB-1195C03BBB93}']
  end;

  YDbGameObjectTemplate = class(YDbRoSerializable, IGameObjectTemplate)
    private
      fType: UInt32;
      fTextureID: UInt32;
      fFaction: UInt32;
      fFlags: UInt32;
      fSize: Float;
      fSounds: array[0..11] of UInt32;
      fName: string;
      function GetSound(iIndex: Int32): UInt32;
    protected
      procedure RegisterClassFields(Registry: TSerializationRegistry); override;
    public
      procedure Assign(cSerializable: YDbSerializable); override;
    published
      property GOType: UInt32 read fType;
      property TextureID: UInt32 read fTextureID;
      property Faction: UInt32 read fFaction;
      property Flags: UInt32 read fFlags;
      property Size: Float read fSize;
    public
      property Sounds[iIndex: Int32]: UInt32 read GetSound;
  end;

  IQuestTemplate = interface(ISerializable)
  ['{070E0F98-589F-46A3-9CBB-1195C03BBB93}']
  {TODO 5 -oAll -cDataBase : What should be there interface?}
  end;

  YDbQuestTemplate = class(YDbRoSerializable, IQuestTemplate)
    private
      fReqLevel: UInt32;
      fCategory: UInt32;
      fQuestLevel: UInt32;
      fMoneyReward: UInt32;
      fTimeObjective: UInt32;
      fPrevQuest: UInt32;
      fNextQuest: UInt32;
      fComplexity: UInt32;
      fLearnSpell: UInt32;
      fExploreObjective: UInt32;
      fQFinishNpc: UInt32;
      fQFinishObj: UInt32;
      fQFinishItm: UInt32;
      fQGiverNpc: UInt32;
      fQGiverObj: UInt32;
      fQGiverItm: UInt32;
      fDescriptiveFlags: UInt32;
      fName: string;
      fObjectives: string;
      fDetails: string;
      fEndText: string;
      fCompleteText: string;
      fIncompleteText: string;
      fObjectiveText1: string;
      fObjectiveText2: string;
      fObjectiveText3: string;
      fObjectiveText4: string;
      fDeliverObjective: YQuestObjects;
      fRewardItmChoice: YQuestObjects;
      fReceiveItem: YQuestObjects;
      fLocation: YQuestLocation;
      fKillObjectiveMob: YQuestObjects;
      fKillObjectiveObj: YQuestObjects;
      fReqReputation: YDoubleDword;
      fRewardItem: YQuestObjects;
      fRequiresRace: YDoubleDword;
      fRequiresClass: YDoubleDword;
      fReqTradeSkill: YDoubleDword;
      fQuestBehavior: YQuestBehaviors;
    protected
      procedure RegisterClassFields(Registry: TSerializationRegistry); override;
    public
      procedure Assign(cSerializable: YDbSerializable); override;
    published
      property ReqLevel: UInt32 read fReqLevel;
      property Category: UInt32 read fCategory;
      property QuestLevel: UInt32 read fQuestLevel;
      property MoneyReward: UInt32 read fMoneyReward;
      property TimeObjective: UInt32 read fTimeObjective;
      property PrevQuest: UInt32 read fPrevQuest;
      property NextQuest: UInt32 read fNextQuest;
      property Complexity: UInt32 read fComplexity;
      property LearnSpell: UInt32 read fLearnSpell;
      property ExploreObjective: UInt32 read fExploreObjective;
      property QFinishNpc: UInt32 read fQFinishNpc;
      property QFinishObj: UInt32 read fQFinishObj;
      property QFinishItm: UInt32 read fQFinishItm;
      property QGiverNpc: UInt32 read fQGiverNpc;
      property QGiverObj: UInt32 read fQGiverObj;
      property QGiverItm: UInt32 read fQGiverItm;
      property DescriptiveFlags: UInt32 read fDescriptiveFlags;
      property Name: string read fName;
      property Objectives: string read fObjectives;
      property Details: string read fDetails;
      property EndText: string read fEndText;
      property CompleteText: string read fCompleteText;
      property IncompleteText: string read fIncompleteText;
      property ObjectiveText1: string read fObjectiveText1;
      property ObjectiveText2: string read fObjectiveText2;
      property ObjectiveText3: string read fObjectiveText3;
      property ObjectiveText4: string read fObjectiveText4;
      property DeliverObjective: YQuestObjects read fDeliverObjective;
      property RewardItmChoice: YQuestObjects read fRewardItmChoice;
      property ReceiveItem: YQuestObjects read fReceiveItem;
      property Location: YQuestLocation read fLocation;
      property KillObjectiveMob: YQuestObjects read fKillObjectiveMob;
      property KillObjectiveObj: YQuestObjects read fKillObjectiveObj;
    public
      property ReqReputation: YDoubleDword read fReqReputation;
      property RewardItem: YQuestObjects read fRewardItem;
      property RequiresRace: YDoubleDword read fRequiresRace;
      property RequiresClass: YDoubleDword read fRequiresClass;
      property ReqTradeSkill: YDoubleDword read fReqTradeSkill;
      property QuestBehavior: YQuestBehaviors read fQuestBehavior;
  end;

  INPCTextsTemplate = interface(ISerializable)
  ['{070E0F98-589F-46A3-9CBB-1195C03BBB93}']
  end;

  YDbNPCTextsTemplate = class(YDbRoSerializable, INPCTextsTemplate)
    private
      fText00: string;
      fText01: string;
      fText02: string;
      fText03: string;
      fText04: string;
      fText05: string;
      fText06: string;
      fText07: string;
      fText10: string;
      fText11: string;
      fText12: string;
      fText13: string;
      fText14: string;
      fText15: string;
      fText16: string;
      fText17: string;
      fProbability0: Float;
      fProbability1: Float;
      fProbability2: Float;
      fProbability3: Float;
      fProbability4: Float;
      fProbability5: Float;
      fProbability6: Float;
      fProbability7: Float;
      fLanguage0: UInt32;
      fLanguage1: UInt32;
      fLanguage2: UInt32;
      fLanguage3: UInt32;
      fLanguage4: UInt32;
      fLanguage5: UInt32;
      fLanguage6: UInt32;
      fLanguage7: UInt32;
      fEmoteId00: UInt32;
      fEmoteId10: UInt32;
      fEmoteId20: UInt32;
      fEmoteId01: UInt32;
      fEmoteId11: UInt32;
      fEmoteId21: UInt32;
      fEmoteId02: UInt32;
      fEmoteId12: UInt32;
      fEmoteId22: UInt32;
      fEmoteId03: UInt32;
      fEmoteId13: UInt32;
      fEmoteId23: UInt32;
      fEmoteId04: UInt32;
      fEmoteId14: UInt32;
      fEmoteId24: UInt32;
      fEmoteId05: UInt32;
      fEmoteId15: UInt32;
      fEmoteId25: UInt32;
      fEmoteId06: UInt32;
      fEmoteId16: UInt32;
      fEmoteId26: UInt32;
      fEmoteId07: UInt32;
      fEmoteId17: UInt32;
      fEmoteId27: UInt32;
      fEmoteDelay00: UInt32;
      fEmoteDelay10: UInt32;
      fEmoteDelay20: UInt32;
      fEmoteDelay01: UInt32;
      fEmoteDelay11: UInt32;
      fEmoteDelay21: UInt32;
      fEmoteDelay02: UInt32;
      fEmoteDelay12: UInt32;
      fEmoteDelay22: UInt32;
      fEmoteDelay03: UInt32;
      fEmoteDelay13: UInt32;
      fEmoteDelay23: UInt32;
      fEmoteDelay04: UInt32;
      fEmoteDelay14: UInt32;
      fEmoteDelay24: UInt32;
      fEmoteDelay05: UInt32;
      fEmoteDelay15: UInt32;
      fEmoteDelay25: UInt32;
      fEmoteDelay06: UInt32;
      fEmoteDelay16: UInt32;
      fEmoteDelay26: UInt32;
      fEmoteDelay07: UInt32;
      fEmoteDelay17: UInt32;
      fEmoteDelay27: UInt32;
    protected
      procedure RegisterClassFields(Registry: TSerializationRegistry); override;
    public
      procedure Assign(cSerializable: YDbSerializable); override;
    published
      property Text00: string read fText00;
      property Text01: string read fText01;
      property Text02: string read fText02;
      property Text03: string read fText03;
      property Text04: string read fText04;
      property Text05: string read fText05;
      property Text06: string read fText06;
      property Text07: string read fText07;
      property Text10: string read fText10;
      property Text11: string read fText11;
      property Text12: string read fText12;
      property Text13: string read fText13;
      property Text14: string read fText14;
      property Text15: string read fText15;
      property Text16: string read fText16;
      property Text17: string read fText17;
      property Probability0: Float read fProbability0;
      property Probability1: Float read fProbability1;
      property Probability2: Float read fProbability2;
      property Probability3: Float read fProbability3;
      property Probability4: Float read fProbability4;
      property Probability5: Float read fProbability5;
      property Probability6: Float read fProbability6;
      property Probability7: Float read fProbability7;
      property Language0: UInt32 read fLanguage0;
      property Language1: UInt32 read fLanguage1;
      property Language2: UInt32 read fLanguage2;
      property Language3: UInt32 read fLanguage3;
      property Language4: UInt32 read fLanguage4;
      property Language5: UInt32 read fLanguage5;
      property Language6: UInt32 read fLanguage6;
      property Language7: UInt32 read fLanguage7;
      property EmoteId00: UInt32 read fEmoteId00;
      property EmoteId10: UInt32 read fEmoteId10;
      property EmoteId20: UInt32 read fEmoteId20;
      property EmoteId01: UInt32 read fEmoteId01;
      property EmoteId11: UInt32 read fEmoteId11;
      property EmoteId21: UInt32 read fEmoteId21;
      property EmoteId02: UInt32 read fEmoteId02;
      property EmoteId12: UInt32 read fEmoteId12;
      property EmoteId22: UInt32 read fEmoteId22;
      property EmoteId03: UInt32 read fEmoteId03;
      property EmoteId13: UInt32 read fEmoteId13;
      property EmoteId23: UInt32 read fEmoteId23;
      property EmoteId04: UInt32 read fEmoteId04;
      property EmoteId14: UInt32 read fEmoteId14;
      property EmoteId24: UInt32 read fEmoteId24;
      property EmoteId05: UInt32 read fEmoteId05;
      property EmoteId15: UInt32 read fEmoteId15;
      property EmoteId25: UInt32 read fEmoteId25;
      property EmoteId06: UInt32 read fEmoteId06;
      property EmoteId16: UInt32 read fEmoteId16;
      property EmoteId26: UInt32 read fEmoteId26;
      property EmoteId07: UInt32 read fEmoteId07;
      property EmoteId17: UInt32 read fEmoteId17;
      property EmoteId27: UInt32 read fEmoteId27;
      property EmoteDelay00: UInt32 read fEmoteDelay00;
      property EmoteDelay10: UInt32 read fEmoteDelay10;
      property EmoteDelay20: UInt32 read fEmoteDelay20;
      property EmoteDelay01: UInt32 read fEmoteDelay01;
      property EmoteDelay11: UInt32 read fEmoteDelay11;
      property EmoteDelay21: UInt32 read fEmoteDelay21;
      property EmoteDelay02: UInt32 read fEmoteDelay02;
      property EmoteDelay12: UInt32 read fEmoteDelay12;
      property EmoteDelay22: UInt32 read fEmoteDelay22;
      property EmoteDelay03: UInt32 read fEmoteDelay03;
      property EmoteDelay13: UInt32 read fEmoteDelay13;
      property EmoteDelay23: UInt32 read fEmoteDelay23;
      property EmoteDelay04: UInt32 read fEmoteDelay04;
      property EmoteDelay14: UInt32 read fEmoteDelay14;
      property EmoteDelay24: UInt32 read fEmoteDelay24;
      property EmoteDelay05: UInt32 read fEmoteDelay05;
      property EmoteDelay15: UInt32 read fEmoteDelay15;
      property EmoteDelay25: UInt32 read fEmoteDelay25;
      property EmoteDelay06: UInt32 read fEmoteDelay06;
      property EmoteDelay16: UInt32 read fEmoteDelay16;
      property EmoteDelay26: UInt32 read fEmoteDelay26;
      property EmoteDelay07: UInt32 read fEmoteDelay07;
      property EmoteDelay17: UInt32 read fEmoteDelay17;
      property EmoteDelay27: UInt32 read fEmoteDelay27;
  end;

  IAccountEntry = interface(ISerializable)
  ['{D0DE9810-3EA0-4D92-9240-37885E3E1AE7}']
  end;

  YAccountHash = array[0..39] of Byte;
  
  YDbAccountEntry = class(YDbRwSerializable, IAccountEntry)
    private
      fName: string;
      fPass: string;
      fHash: YAccountHash;
      fLoggedIn: Boolean;
      fAutoCreated: Boolean;
      fAccess: YAccountAccess;
      fStatus: YAccountStatus;
    protected
      procedure RegisterClassFields(Registry: TSerializationRegistry); override;
    public
      procedure Assign(cSerializable: YDbSerializable); override;
    published
      property Name: string read fName write fName;
      property Pass: string read fPass write fPass;
    public
      property Hash: YAccountHash read fHash write fHash;
    published
      property Access: YAccountAccess read fAccess write fAccess;
      property Status: YAccountStatus read fStatus write fStatus;
      property LoggedIn: Boolean read fLoggedIn write fLoggedIn;
      property AutoCreated: Boolean read fAutoCreated write fAutoCreated;
  end;

  IUpdateable = interface(ISerializable)
  ['{49A3CBB7-CE9E-4808-9D62-A312F0C3738A}']
  end;

  YDbWowObjectEntry = class(YDbRwSerializable, IUpdateable)
    private
      fUpdateData: TLongWordDynArray;
      fTimers: TLongWordDynArray;
    protected
      procedure RegisterClassFields(Registry: TSerializationRegistry); override;
    public
      procedure Assign(cSerializable: YDbSerializable); override;

      procedure AssignUpdateData(pData: PLongWordArray; iCount: Int32);
    published
      property UpdateData: TLongWordDynArray read fUpdateData write fUpdateData;
      property Timers: TLongWordDynArray read fTimers write fTimers;
  end;

  IItemEntry = interface(ISerializable)
  ['{2CD79BEE-CB7B-424C-A7C5-E34D87C494B1}']
  end;

  YDbItemEntry = class(YDbWowObjectEntry, IItemEntry)
    private
      fEntry: UInt32;
      fStackCount: UInt32;
      fDurability: UInt32;
      fContained: UInt32;
      fCreator: UInt32;
      fItemsContained: TLongWordDynArray;
    protected
      procedure RegisterClassFields(Registry: TSerializationRegistry); override;
    public
      procedure Assign(cSerializable: YDbSerializable); override;

      procedure SetItemsContainedLength(iNewLen: Int32);
    published
      property Entry: UInt32 read fEntry write fEntry;
      property StackCount: UInt32 read fStackCount write fStackCount;
      property Durability: UInt32 read fDurability write fDurability;
      property ContainedIn: UInt32 read fContained write fContained;
      property Creator: UInt32 read fCreator write fCreator;
      property ItemsContained: TLongWordDynArray read fItemsContained;
  end;

  IPlaceable = interface(IUpdateable)
  ['{F015215C-A7E5-4CC3-9BA3-7A6BADE676D7}']
  end;

  YDbPlaceableEntry = class(YDbWowObjectEntry, IPlaceable)
    private
      fPosX: Float;
      fPosY: Float;
      fPosZ: Float;
      fAngle: Float;
      fMapId: UInt32;
      fZoneId: UInt32;
    protected
      procedure RegisterClassFields(Registry: TSerializationRegistry); override;
    public
      procedure Assign(cSerializable: YDbSerializable); override;
    published
      property PosX: Float read fPosX write fPosX;
      property PosY: Float read fPosY write fPosY;
      property PosZ: Float read fPosZ write fPosZ;
      property Angle: Float read fAngle write fAngle;
      property ZoneId: UInt32 read fZoneId write fZoneId;
      property MapId: UInt32 read fMapId write fMapId;
  end;

  IMoveable = interface(IPlaceable)
  ['{9875E845-1BC5-4D5C-97DB-133DD39DE5B6}']
  end;

  YDbMoveableEntry = class(YDbPlaceableEntry, IMoveable)
    private
      fSpeedWalk: Float;
      fSpeedRun: Float;
      fSpeedBackSwim: Float;
      fSpeedSwim: Float;
      fSpeedBackWalk: Float;
      fSpeedTurn: Float;
    protected
      procedure RegisterClassFields(Registry: TSerializationRegistry); override;
    public
      procedure Assign(cSerializable: YDbSerializable); override;
    published
      property SpeedWalk: Float read fSpeedWalk write fSpeedWalk;
      property SpeedRun: Float read fSpeedRun write fSpeedRun;
      property SpeedBackwardSwim: Float read fSpeedBackSwim write fSpeedBackSwim;
      property SpeedSwim: Float read fSpeedSwim write fSpeedSwim;
      property SpeedBackwardWalk: Float read fSpeedBackWalk write fSpeedBackWalk;
      property SpeedTurn: Float read fSpeedTurn write fSpeedTurn;
  end;

  ICreatureEntry = interface(IMoveable)
  ['{06558D83-FEA3-4195-A06C-9130C6449030}']
  end;

  YDbCreatureEntry = class(YDbMoveableEntry, ICreatureEntry);

  IGameObjectEntry = interface(IPlaceable)
  ['{F9796C4B-1BF9-4617-8A76-92041A984133}']
  end;

  YDbGameObjectEntry = class(YDbPlaceableEntry, IGameObjectEntry);

  IPlayerEntry = interface(IMoveable)
  ['{C0786724-9676-4BF5-AEBF-68F83785064C}']
  end;

  YDbPlayerEntry = class(YDbMoveableEntry, IPlayerEntry)
    private
      fAccount: string;
      fCharName: string;
      fPrivileges: string;
      fRested: UInt32;
      fTutorials: TLongWordDynArray;
      fActionButtons: TLongWordDynArray;
      fEquippedItems: TLongWordDynArray;
      fHonorStats: TLongWordDynArray;
      fPriviledges: TStringDynArray;
      fActiveQuests: YActiveQuests;
      fFinishedQuests: TLongWordDynArray;
      fTPPlaces: YTPPlaces;
    protected
      procedure RegisterClassFields(Registry: TSerializationRegistry); override;
    public
      procedure Assign(cSerializable: YDbSerializable); override;

      procedure SetTutorialsLength(iNewLen: Int32);
      procedure SetActionButtonsLength(iNewLen: Int32);
      procedure SetEquippedItemsLength(iNewLen: Int32);
      procedure SetHonorStatsLength(iNewLen: Int32);
      procedure SetPriviledgesLength(iNewLen: Int32);
    published
      property AccountName: string read fAccount write fAccount;
      property CharName: string read fCharName write fCharName;
      property Privileges: string read fPrivileges write fPrivileges;
      property Rested: UInt32 read fRested write fRested;
      property Tutorials: TLongWordDynArray read fTutorials;
      property ActionButtons: TLongWordDynArray read fActionButtons;
      property EquippedItems: TLongWordDynArray read fEquippedItems;
      property HonorStats: TLongWordDynArray read fHonorStats;
      property Priviledges: TStringDynArray read fPriviledges;
      property ActiveQuests: YActiveQuests read fActiveQuests write fActiveQuests;
      property FinishedQuests: TLongWordDynArray read fFinishedQuests write fFinishedQuests;
      property TPPlaces: YTPPlaces read fTPPlaces write fTPPlaces;
  end;

  INodeEntry = interface(ISerializable)
  ['{8D8D1B90-F519-4BFE-BC51-1B767EC68357}']
  end;

  YNodeFlag = (nfNone, nfSpawn, nfReachNotify, nfLink, nfMultilink);
  { Flags:
    nfNone - dummy
    nfSpawn - the node has spawn entries (unimplemented)
    nfReachNotify - the node calls a callback when an object reaches it (unimplemented)
    nfLink - the node is linked to another node
    nfMultilink - the node is (or can be) linked with more nodes
  }

  YNodeFlags = set of YNodeFlag;

  YDbNodeEntry = class(YDbRwSerializable, INodeEntry)
    private
      fPosX: Float;
      fPosY: Float;
      fPosZ: Float;
      fMapId: UInt32;
      fFlags: YNodeFlags;
    protected
      procedure RegisterClassFields(Registry: TSerializationRegistry); override;
    public
      procedure Assign(cSerializable: YDbSerializable); override;
    published
      property X: Float read fPosX write fPosX;
      property Y: Float read fPosY write fPosY;
      property Z: Float read fPosZ write fPosZ;
      property MapId: UInt32 read fMapId write fMapId;
      property Flags: YNodeFlags read fFlags write fFlags;
  end;

  IAddonEntry = interface(ISerializable)
  ['{EE30FE42-AAB6-48A2-8824-5EBEEAD06579}']
  end;

  YDbAddonEntry = class(YDbRwSerializable, IAddonEntry)
    private
      fName: string;
      fCRC32: UInt32;
      fEnabled: Boolean;
    protected
      procedure RegisterClassFields(Registry: TSerializationRegistry); override;
    public
      procedure Assign(cSerializable: YDbSerializable); override;
    published  
      property Name: string read fName write fName;
      property CRC32: UInt32 read fCRC32 write fCRC32;
      property Enabled: Boolean read fEnabled write fEnabled;
  end;

  YDbPersistentTimerEntry = class(YDbRwSerializable)
    private
      fExecutionCount: Int32;
      fTimeLeft: Int32;
      fTimeTotal: Int32;
      fDisabled: Boolean;
    public
      procedure Assign(Entry: YDbSerializable); override;
    published
      property TimeLeft: Int32 read fTimeLeft write fTimeLeft;
      property TimeTotal: Int32 read fTimeTotal write fTimeTotal;
      property ExecutionCount: Int32 read fExecutionCount write fExecutionCount;
      property Disabled: Boolean read fDisabled write fDisabled;
  end;

function CompareSerializablesById(cSer1, cSer2: YDbSerializable): Integer;
function MatchSerializablesById(pId: Pointer; cSer: YDbSerializable): Integer;

const
  SYSkillDataArr: string     = 'YSkillDataArray';
  SYItemDataArr: string      = 'YItemDataArray';
  SYAccountAccess: string    = 'YAccountAccess';
  SYAccountStatus: string    = 'YAccountStatus';
  SYDoubleDword: string      = 'YDoubleDword';
  SYQuestLocation: string    = 'YQuestLocation';
  SYQuestBehaviors: string   = 'YQuestBehaviors';
  SYQuestObjects: string     = 'YQuestObjects';
  SYActiveQuests: string     = 'YActiveQuests';
  SGameClass: string         = 'YGameClass';
  SGameClasses: string       = 'YGameClasses';
  SGameRace: string          = 'YGameRace';
  SGameRaces: string         = 'YGameRaces';
  SNodeFlags: string         = 'YNodeFlags'; 

implementation

uses
  Cores,
  Framework;

function CompareSerializablesById(cSer1, cSer2: YDbSerializable): Integer;
begin
  Result := cSer1.fID - cSer2.fID;
end;

function MatchSerializablesById(pId: Pointer; cSer: YDbSerializable): Integer;
begin
  Result := Longword(pId) - cSer.fID;
end;

{ YCharTemplateInfo }

procedure SkillDataProcessor(pDataPtr: Pointer; iDbOp: TDatabaseOperation;
  pInOutBuf: Pointer; iInOutType: TDataType; const Info: ITypeInfo; var sError: string);
type
  PSkillDataArray = ^YSkillDataArray;
var
  aArr: array[0..2] of UInt32;
  iIdx: Int32;
  aSkillData: PSkillDataArray;
begin
  case ProcessingTypeTable[iDbOp, iInOutType] of
    DB_BIN_LOAD:
    begin
      aSkillData := PSkillDataArray(pDataPtr);
      SetLength(aSkillData^, PInteger(pInOutBuf)^);
      Inc(PByte(pInOutBuf), 4);
      Move(pInOutBuf^, aSkillData^[0], Length(aSkillData^) * SizeOf(YSkillData));
    end;
    DB_TEXT_LOAD:
    begin
      aSkillData := PSkillDataArray(pDataPtr);
      StringToArray(PString(pInOutBuf)^, aArr);
      iIdx := Length(aSkillData^);
      SetLength(aSkillData^, iIdx + 1);
      aSkillData^[iIdx].Id := aArr[0];
      aSkillData^[iIdx].Initial := aArr[1];
      aSkillData^[iIdx].Max := aArr[2];
    end;
  end;
end;

procedure ItemDataProcessor(pDataPtr: Pointer; iDbOp: TDatabaseOperation;
  pInOutBuf: Pointer; iInOutType: TDataType; const Info: ITypeInfo; var sError: string);
type
  PItemDataArray = ^YItemDataArray;
var
  aArr: array[0..2] of UInt32;
  iIdx: Int32;
  aItemData: PItemDataArray;
begin
  case ProcessingTypeTable[iDbOp, iInOutType] of
    DB_BIN_LOAD:
    begin
      aItemData := PItemDataArray(pDataPtr);
      SetLength(aItemData^, PInteger(pInOutBuf)^);
      Inc(PByte(pInOutBuf), 4);
      Move(pInOutBuf^, aItemData^[0], Length(aItemData^) * SizeOf(YItemData));
    end;
    DB_TEXT_LOAD:
    begin
      aItemData := PItemDataArray(pDataPtr);
      StringToArray(PString(pInOutBuf)^, aArr);
      iIdx := Length(aItemData^);
      SetLength(aItemData^, iIdx + 1);
      aItemData^[iIdx].Slot := aArr[0];
      aItemData^[iIdx].Id := aArr[1];
      aItemData^[iIdx].Count := aArr[2];
    end;
  end;
end;

procedure DoubleDwordProcessor(pDataPtr: PUInt32; iDbOp: TDatabaseOperation;
  pInOutBuf: Pointer; iInOutType: TDataType; const Info: ITypeInfo; var sError: string);
var
  aArr: array[0..1] of UInt32;
begin
  case ProcessingTypeTable[iDbOp, iInOutType] of
    DB_BIN_LOAD:
    begin
      Move(pInOutBuf^, pDataPtr^, SizeOf(UInt32) * 2);
    end;
    DB_TEXT_LOAD:
    begin
      StringToArray(PString(pInOutBuf)^, aArr);
      pDataPtr^ := aArr[0];
      Inc(pDataPtr);
      pDataPtr^ := aArr[1];
    end;
  end;
end;

type
  PGameRaces = ^YGameRaces;
  PGameClasses = ^YGameClasses;

procedure GameRacesProcessor(pDataPtr: PUInt32; iDbOp: TDatabaseOperation;
  pInOutBuf: Pointer; iInOutType: TDataType; const Info: ITypeInfo; var sError: string);
var
  iMask: UInt32;
  iRaceSet: YGameRaces absolute iMask;
begin
  case ProcessingTypeTable[iDbOp, iInOutType] of
    DB_TEXT_LOAD:
    begin
      iMask := (atoi32(PString(pInOutBuf)^) shl 1) and GAME_RACES_MASK;
      if iMask = 0 then iRaceSet := grAll;
      PGameRaces(pDataPtr)^ := iRaceSet;
    end;
  end;
end;

procedure GameClassesProcessor(pDataPtr: PUInt32; iDbOp: TDatabaseOperation;
  pInOutBuf: Pointer; iInOutType: TDataType; const Info: ITypeInfo; var sError: string);
var
  iMask: UInt32;
  iClassSet: YGameClasses absolute iMask;
begin
  case ProcessingTypeTable[iDbOp, iInOutType] of
    DB_TEXT_LOAD:
    begin
      iMask := (atoi32(PString(pInOutBuf)^) shl 1) and GAME_CLASSES_MASK;
      if iMask = 0 then iClassSet := gcAll;
      PGameClasses(pDataPtr)^ := iClassSet;
    end;
  end;
end;

{ YSerializable }

constructor YDbSerializable.Create;
begin
  inherited Create;
  fContexts := TStrIntfHashMap.Create(False, 4);
end;

destructor YDbSerializable.Destroy;
begin
  fContexts.Free;
  inherited Destroy;
end;

procedure YDbSerializable.AfterLoad;
begin
  { Nothing }
end;

procedure YDbSerializable.Assign(cSerializable: YDbSerializable);
begin
  fId := cSerializable.fId;
  fContexts.Clear;
  fContexts.PutAll(cSerializable.fContexts);
end;

function YDbSerializable.GetContext(const Name: string): IDofStreamable;
begin
  Result := fContexts.GetValue(Name) as IDofStreamable;
end;

procedure YDbSerializable.SetContext(const Name: string; const Value: IDofStreamable);
begin
  fContexts.PutValue(Name, Value);
end;

procedure YDbSerializable.WriteContexts(const Writer: IDofWriter);
var
  ifItr: IIntfIterator;
  ifKeys: IStrIterator;
  ifStreamable: IDofStreamable;
begin
  ifItr := fContexts.Values;
  ifKeys := fContexts.KeySet;
  Writer.WriteCollectionStart;
  while ifItr.HasNext do
  begin
    Writer.WriteCollectionItemStart;
    Writer.WriteString(ifKeys.Next);
    ifStreamable.WriteCustomProperties(Writer);
    Writer.WriteCollectionItemEnd;
  end;
  Writer.WriteCollectionEnd;
end;

procedure YDbSerializable.WriteCustomProperties(const Writer: IDofWriter);
begin
  Writer.WriteCustomProperty('Contexts', WriteContexts);
end;

procedure YDbSerializable.ReadContexts(const Reader: IDofReader);
var
  cObj: TInterfacedObject;
  sStr: string;
begin
  Reader.ReadCollectionStart;
  while not Reader.IsCollectionEnd do
  begin
    Reader.ReadCollectionItemStart;
    sStr := Reader.ReadString;
    Reader.ReadClass(cObj, nil);
    if cObj <> nil then
    begin
      fContexts.PutValue(sStr, cObj as IInterface);
    end;
    Reader.ReadCollectionItemEnd;
  end;
  Reader.ReadCollectionEnd;
end;

procedure YDbSerializable.ReadCustomProperties(const Reader: IDofReader);
begin
  Reader.ReadCustomProperty('Contexts', ReadContexts)
end;

function YDbSerializable.GetContexts: IIntfIterator;
begin
  Result := fContexts.Values;
end;

function YDbSerializable.GetUniqueId: UInt32;
begin
  Result := fId;
end;

procedure YDbSerializable.RegisterClassFields(Registry: TSerializationRegistry);
begin
  { Nothing }
end;

class procedure YDbSerializable.RegisterSelf(Registry: TSerializationRegistry);
var
  cInst: YDbSerializable;
begin
  cInst := Self.Create;
  Registry.SerializableRegistrationBegin(cInst, cInst.ClassName);
  cInst.RegisterClassFields(Registry);
  Registry.SerializableRegistrationEnd;
  cInst.Destroy;
end;

{ YReadOnlySerializable }

class function YDbRoSerializable.IsReadOnly: Boolean;
begin
  Result := True;
end;

{ YAlterableSerializable }

class function YDbRwSerializable.IsReadOnly: Boolean;
begin
  Result := False;
end;

{ YDbCharTemplate }

procedure YDbCharTemplate.Assign(cSerializable: YDbSerializable);
var
  cChar: YDbCharTemplate;
begin
  inherited Assign(cSerializable);
  if not cSerializable.InheritsFrom(YDbCharTemplate) then Exit;
  cChar := YDbCharTemplate(cSerializable);
  fRace := cChar.fRace;
  fClass := cChar.fClass;
  fMapId := cChar.fMapId;
  fZoneId := cChar.fZoneId;
  fX := cChar.fX;
  fY := cChar.fY;
  fZ := cChar.fZ;
  fO := cChar.fO;
  fStrength := cChar.fStrength;
  fAgility := cChar.fAgility;
  fStamina := cChar.fStamina;
  fIntellect := cChar.fIntellect;
  fSpirit := cChar.fSpirit;
  fMaleBody := cChar.fMaleBody;
  fFemaleBody := cChar.fFemaleBody;
  fBodySize := cChar.fBodySize;
  fPowerType := cChar.fPowerType;
  fBasePower := cChar.fBasePower;
  fBaseHealth := cChar.fBaseHealth;
  fPower := cChar.fPower;
  fSkillData := cChar.fSkillData;
  fSpells := cChar.fSpells;
  fItemData := cChar.fItemData;
  fAttackTimeLo := cChar.fAttackTimeLo;
  fAttackTimeHi := cChar.fAttackTimeHi;
  fAttackPower := cChar.fAttackPower;
  fAttackDamageHi := cChar.fAttackDamageHi;
  fAttackDamageLo := cChar.fAttackDamageLo;
  SetLength(fActionButtons, Length(cChar.fActionButtons));
  Move(cChar.fActionButtons[0], fActionButtons[0], Length(fActionButtons) * SizeOf(UInt32));
end;

procedure YDbCharTemplate.RegisterClassFields(Registry: TSerializationRegistry);
begin
  inherited RegisterClassFields(Registry);

  SystemTypeRegistry.RegisterType(TypeInfo(YSkillDataArray));
  SystemTypeRegistry.RegisterType(TypeInfo(YItemDataArray));

  Registry.RegisterTypeProcessingCallback(SYSkillDataArr, @SkillDataProcessor);
  Registry.RegisterTypeProcessingCallback(SYItemDataArr, @ItemDataProcessor);
  Registry.RegisterTypeProcessingCallback(SYDoubleDword, @DoubleDwordProcessor);

  Registry.RegisterField(@fRace, FIELD_CT_RACE, SString);
  Registry.RegisterField(@fClass, FIELD_CT_CLASS, SString);
  Registry.RegisterField(@fMapId, FIELD_CT_START_MAP, SUInt32);
  Registry.RegisterField(@fZoneId, FIELD_CT_START_ZONE, SUInt32);
  Registry.RegisterField(@fX, FIELD_CT_START_X, SFloat);
  Registry.RegisterField(@fY, FIELD_CT_START_Y, SFloat);
  Registry.RegisterField(@fZ, FIELD_CT_START_Z, SFloat);
  Registry.RegisterField(@fO, FIELD_CT_START_O, SFloat);
  Registry.RegisterField(@fStrength, FIELD_CT_STAT_STR, SUInt32);
  Registry.RegisterField(@fAgility, FIELD_CT_STAT_AGI, SUInt32);
  Registry.RegisterField(@fStamina, FIELD_CT_STAT_STA, SUInt32);
  Registry.RegisterField(@fIntellect, FIELD_CT_STAT_INT, SUInt32);
  Registry.RegisterField(@fSpirit, FIELD_CT_STAT_SPI, SUInt32);
  Registry.RegisterField(@fFemaleBody, FIELD_CT_BODY_FEM, SUInt32);
  Registry.RegisterField(@fMaleBody, FIELD_CT_BODY_MAL, SUInt32);
  Registry.RegisterField(@fBodySize, FIELD_CT_BODY_SIZE, SFloat);
  Registry.RegisterField(@fPowerType, FIELD_CT_POWER_TYPE, SUInt32);
  Registry.RegisterField(@fBasePower, FIELD_CT_POWER_BASE, SUInt32);
  Registry.RegisterField(@fBaseHealth, FIELD_CT_HEALTH_BASE, SUInt32);
  Registry.RegisterField(@fPower, FIELD_CT_POWER, SUInt32);
  Registry.RegisterField(@fSkillData, FIELD_CT_SKILL, SYSkillDataArr);
  Registry.RegisterField(@fSpells, FIELD_CT_SPELL, STLongwordArr);
  Registry.RegisterField(@fItemData, FIELD_CT_ITEM, SYItemDataArr);
  Registry.RegisterField(@fAttackTimeLo, FIELD_CT_ATTACK_TIMES, SYDoubleDword);
  Registry.RegisterField(@fAttackPower, FIELD_CT_ATTACK_POWER, SUInt32);
  Registry.RegisterField(@fAttackDamageLo, FIELD_CT_ATTACK_DMGLO, SUInt32);
  Registry.RegisterField(@fAttackDamageHi, FIELD_CT_ATTACK_DMGHI, SUInt32);
  Registry.RegisterField(@fActionButtons, FIELD_CT_ACTION_BTNS, STLongwordArr);
end;

procedure YDbCharTemplate.SetActionButtonsLength(iNewLen: Int32);
begin
  SetLength(fActionButtons, iNewLen);
end;

procedure YDbCharTemplate.SetItemDataLength(iNewLen: Int32);
begin
  SetLength(fItemData, iNewLen);
end;

procedure YDbCharTemplate.SetSkillDataLength(iNewLen: Int32);
begin
  SetLength(fSkillData, iNewLen);
end;

procedure YDbCharTemplate.SetSpellsLength(iNewLen: Int32);
begin
  SetLength(fSpells, iNewLen);
end;

{ YCreatureTemplate }

procedure YDbCreatureTemplate.Assign(cSerializable: YDbSerializable);
var
  cCreature: YDbCreatureTemplate;
begin
  inherited Assign(cSerializable);
  if not cSerializable.InheritsFrom(YDbCreatureTemplate) then Exit;
  cCreature := YDbCreatureTemplate(cSerializable);
  fEntryName := cCreature.fEntryName;
  fEntryGuildName := cCreature.fEntryGuildName;
  fEntrySubName := cCreature.fEntrySubName;
  fTextureID := cCreature.fTextureID;
  fMaxHealth := cCreature.fMaxHealth;
  fMaxMana := cCreature.fMaxMana;
  fLevel := cCreature.fLevel;
  fMaximumLevel := cCreature.fMaximumLevel;
  fArmor := cCreature.fArmor;
  fFaction := cCreature.fFaction;
  fNPCFlags := cCreature.fNPCFlags;
  fRank := cCreature.fRank;
  fFamily := cCreature.fFamily;
  fGender := cCreature.fGender;
  fBaseAttackPower := cCreature.fBaseAttackPower;
  fBaseAttackTime := cCreature.fBaseAttackTime;
  fRangedAttackPower := cCreature.fRangedAttackPower;
  fRangedAttackTime := cCreature.fRangedAttackTime;
  fFlags := cCreature.fFlags;
  fDynamicFlags := cCreature.fDynamicFlags;
  fUnitClass := cCreature.fUnitClass;
  fTrainerType := cCreature.fTrainerType;
  fMountID := cCreature.fMountID;
  fType := cCreature.fType;
  fCivilian := cCreature.fCivilian;
  fElite := cCreature.fElite;
  fUnitType := cCreature.fUnitType;
  fUnitFlags := cCreature.fUnitFlags;
  fMovementSpeed := cCreature.fMovementSpeed;
  fDamageMin := cCreature.fDamageMin;
  fDamageMax := cCreature.fDamageMax;
  fRangeDamageMin := cCreature.fRangeDamageMin;
  fRangeDamageMax := cCreature.fRangeDamageMax;
  fScale := cCreature.fScale;
  fBoundingRadius := cCreature.fBoundingRadius;
  fCombatReach := cCreature.fCombatReach;
  fEquipModel0 := cCreature.fEquipModel0;
  fEquipModel1 := cCreature.fEquipModel1;
  fEquipModel2 := cCreature.fEquipModel2;
  fEquipInfo0 := cCreature.fEquipInfo0;
  fEquipInfo1 := cCreature.fEquipInfo1;
  fEquipInfo2 := cCreature.fEquipInfo2;
  fEquipSlot0 := cCreature.fEquipSlot0;
  fEquipSlot1 := cCreature.fEquipSlot1;
  fEquipSlot2 := cCreature.fEquipSlot2;
  fResistancePhysical := cCreature.fResistancePhysical;
  fResistanceHoly := cCreature.fResistanceHoly;
  fResistanceFire := cCreature.fResistanceFire;
  fResistanceNature := cCreature.fResistanceNature;
  fResistanceFrost := cCreature.fResistanceFrost;
  fResistanceShadow := cCreature.fResistanceShadow;
  fResistanceArcane := cCreature.fResistanceArcane;
end;

procedure YDbCreatureTemplate.RegisterClassFields(Registry: TSerializationRegistry);
begin
  inherited RegisterClassFields(Registry);
  Registry.RegisterField(@fEntryName, FIELD_CRT_MAIN_NAME, SString);
  Registry.RegisterField(@fEntrySubName, FIELD_CRT_SUB_NAME, SString);
  Registry.RegisterField(@fEntryGuildName, FIELD_CRT_GUILD_NAME, SString);
  Registry.RegisterField(@fTextureId, FIELD_CRT_TEXTURE, SUInt32);
  Registry.RegisterField(@fMaxHealth, FIELD_CRT_MAX_HEALTH, SUInt32);
  Registry.RegisterField(@fMaxMana, FIELD_CRT_MAX_MANA, SUInt32);
  Registry.RegisterField(@fLevel, FIELD_CRT_LEVEL, SUInt32);
  Registry.RegisterField(@fMaximumLevel, FIELD_CRT_MAX_LEVEL, SUInt32);
  Registry.RegisterField(@fArmor, FIELD_CRT_ARMOR, SUInt32);
  Registry.RegisterField(@fFaction, FIELD_CRT_FACTION, SUInt32);
  Registry.RegisterField(@fNPCFlags, FIELD_CRT_NPC_FLAGS, SUInt32);
  Registry.RegisterField(@fRank, FIELD_CRT_RANK, SUInt32);
  Registry.RegisterField(@fFamily, FIELD_CRT_FAMILY, SUInt32);
  Registry.RegisterField(@fGender, FIELD_CRT_GENDER, SUInt32);
  Registry.RegisterField(@fBaseAttackPower, FIELD_CRT_BA_POWER, SUInt32);
  Registry.RegisterField(@fBaseAttackTime, FIELD_CRT_BA_TIME, SUInt32);
  Registry.RegisterField(@fRangedAttackPower, FIELD_CRT_RA_POWER, SUInt32);
  Registry.RegisterField(@fRangedAttackTime, FIELD_CRT_RA_TIME, SUInt32);
  Registry.RegisterField(@fFlags, FIELD_CRT_FLAGS, SUInt32);
  Registry.RegisterField(@fDynamicFlags, FIELD_CRT_DYN_FLAGS, SUInt32);
  Registry.RegisterField(@fUnitClass, FIELD_CRT_CLASS, SUInt32);
  Registry.RegisterField(@fTrainerType, FIELD_CRT_TRAINER_TYPE, SUInt32);
  Registry.RegisterField(@fMountID, FIELD_CRT_MOUNT, SUInt32);
  Registry.RegisterField(@fType, FIELD_CRT_TYPE, SUInt32);
  Registry.RegisterField(@fCivilian, FIELD_CRT_CIVILIAN, SUint32);
  Registry.RegisterField(@fElite, FIELD_CRT_ELITE, SUInt32);
  Registry.RegisterField(@fUnitType, FIELD_CRT_UNIT_TYPE, SUInt32);
  Registry.RegisterField(@fUnitFlags, FIELD_CRT_UNIT_FLAGS, SUInt32);
  Registry.RegisterField(@fMovementSpeed, FIELD_CRT_WALK_SPEED, SFloat);
  Registry.RegisterField(@fScale, FIELD_CRT_SCALE, SFloat);
  Registry.RegisterField(@BoundingRadius, FIELD_CRT_BOUNDING_RADIUS, SFloat);
  Registry.RegisterField(@fCombatReach, FIELD_CRT_COMBAT_REACH, SFloat);
  Registry.RegisterField(@fResistancePhysical, FIELD_CRT_RESISTANCE_PHYSICAL, SUInt32);
  Registry.RegisterField(@fResistanceHoly, FIELD_CRT_RESISTANCE_HOLY, SUInt32);
  Registry.RegisterField(@fResistanceFire, FIELD_CRT_RESISTANCE_FIRE, SUInt32);
  Registry.RegisterField(@fResistanceFrost, FIELD_CRT_RESISTANCE_FROST, SUInt32);
  Registry.RegisterField(@fResistanceShadow, FIELD_CRT_RESISTANCE_SHADOW, SUInt32);
  Registry.RegisterField(@fResistanceArcane, FIELD_CRT_RESISTANCE_ARCANE, SUInt32);

  Registry.RegisterField(@fDamageMin, FIELD_CRT_DAMAGE_MINIMUM, SUInt32);
  Registry.RegisterField(@fDamageMax, FIELD_CRT_DAMAGE_MAXIMUM, SUInt32);
  Registry.RegisterField(@fRangeDamageMin, FIELD_CRT_RANGED_DAMAGE_MIN, SUInt32);
  Registry.RegisterField(@fRangeDamageMax, FIELD_CRT_RANGED_DAMAGE_MAX, SUInt32);

end;

{ YGameObjectTemplate }

procedure YDbGameObjectTemplate.Assign(cSerializable: YDbSerializable);
var
  cGo: YDbGameObjectTemplate;
begin
  inherited Assign(cSerializable);
  if not cSerializable.InheritsFrom(YDbGameObjectTemplate) then Exit;
  cGo := YDbGameObjectTemplate(cSerializable);
  fType := cGo.fType;
  fTextureID := cGo.fTextureID;
  fFaction := cGo.fFaction;
  fFlags := cGo.fFlags;
  fSize := cGo.fSize;
  fSounds := cGo.fSounds;
  fName := cGo.fName;
end;

function YDbGameObjectTemplate.GetSound(iIndex: Int32): UInt32;
begin
  if iIndex > 11 then Result := 0 else Result := fSounds[iIndex];
end;

procedure YDbGameObjectTemplate.RegisterClassFields(Registry: TSerializationRegistry);
begin
  inherited RegisterClassFields(Registry);
  Registry.RegisterField(@fType, FIELD_GOT_TYPE, SUInt32);
  Registry.RegisterField(@fTextureID, FIELD_GOT_TEXTUREID, SUInt32);
  Registry.RegisterField(@fName, FIELD_GOT_NAME, SString);
  Registry.RegisterField(@fFaction, FIELD_GOT_FACTION, SUInt32);
  Registry.RegisterField(@fFlags, FIELD_GOT_FLAGS, SUInt32);
  Registry.RegisterField(@fSize, FIELD_GOT_SIZE, SFloat);
  Registry.RegisterField(@fSounds[0], FIELD_GOT_SOUND_0, SUInt32);
  Registry.RegisterField(@fSounds[1], FIELD_GOT_SOUND_1, SUInt32);
  Registry.RegisterField(@fSounds[2], FIELD_GOT_SOUND_2, SUInt32);
  Registry.RegisterField(@fSounds[3], FIELD_GOT_SOUND_3, SUInt32);
  Registry.RegisterField(@fSounds[4], FIELD_GOT_SOUND_4, SUInt32);
  Registry.RegisterField(@fSounds[5], FIELD_GOT_SOUND_5, SUInt32);
  Registry.RegisterField(@fSounds[6], FIELD_GOT_SOUND_6, SUInt32);
  Registry.RegisterField(@fSounds[7], FIELD_GOT_SOUND_7, SUInt32);
  Registry.RegisterField(@fSounds[8], FIELD_GOT_SOUND_8, SUInt32);
  Registry.RegisterField(@fSounds[9], FIELD_GOT_SOUND_9, SUInt32);
  Registry.RegisterField(@fSounds[10], FIELD_GOT_SOUND_10, SUInt32);
  Registry.RegisterField(@fSounds[11], FIELD_GOT_SOUND_11, SUInt32);
end;

{ YQuestTemplate }

procedure QuestLocationProcessor(pDataPtr: Pointer; iDbOp: TDatabaseOperation;
  pInOutBuf: Pointer; iInOutType: TDataType; const Info: ITypeInfo; var sError: string);
type
  PQuestLocation = ^YQuestLocation;
var
  aArr: array[0..3] of UInt32;
  aQuestLocationData: PQuestLocation;
begin
  case ProcessingTypeTable[iDbOp, iInOutType] of
    DB_BIN_LOAD:
    begin
      aQuestLocationData := PQuestLocation(pDataPtr);
      Inc(PByte(pInOutBuf), 4);
      Move(pInOutBuf^, aQuestLocationData^, SizeOf(YQuestLocation));
    end;
    DB_TEXT_LOAD:
    begin
      aQuestLocationData := PQuestLocation(pDataPtr);
      StringToArray(PString(pInOutBuf)^, aArr); //Is there a StringCommuToArray?
      aQuestLocationData^.Area := aArr[0];
      aQuestLocationData^.X := aArr[1];
      aQuestLocationData^.Y := aArr[2];
      aQuestLocationData^.Z := aArr[3];
    end;
  else
    Assert(False, 'Tried to perform an invalid serialization operation on type YQuestLocation.');
  end;
end;

procedure QuestObjectsProcessor(pDataPtr: Pointer; iDbOp: TDatabaseOperation;
  pInOutBuf: Pointer; iInOutType: TDataType; const Info: ITypeInfo; var sError: string);
type
  PQuestObjects = ^YQuestObjects;
var
  aArr: array[0..1] of UInt32;
  iIdx: Int32;
  aQuestObjectArrayData: PQuestObjects;
begin
  case ProcessingTypeTable[iDbOp, iInOutType] of
    DB_BIN_LOAD:
    begin
      aQuestObjectArrayData := PQuestObjects(pDataPtr);
      Inc(PByte(pInOutBuf), 4);
      Move(pInOutBuf^, aQuestObjectArrayData^, SizeOf(YQuestObjects));
    end;
    DB_TEXT_LOAD:
    begin
      aQuestObjectArrayData := PQuestObjects(pDataPtr);
      iIdx := aQuestObjectArrayData^.Count;
      if iIdx >= QUEST_OBJECTS_COUNT then
      begin
        Exit;
      end;
      aArr[1] := 1;
      StringToArray(PString(pInOutBuf)^, aArr);
      aQuestObjectArrayData^.Objects[iIdx].Id := aArr[0];
      aQuestObjectArrayData^.Objects[iIdx].Count := aArr[1];
      Inc(aQuestObjectArrayData^.Count);
    end;
  else
    Assert(False, 'Tried to perform an invalid serialization operation on type YQuestObjectArray.');
  end;
end;

procedure QuestBehaviorsProcessor(pDataPtr: Pointer; iDbOp: TDatabaseOperation;
  pInOutBuf: Pointer; iInOutType: TDataType; const Info: ITypeInfo; var sError: string);
//
begin
  case ProcessingTypeTable[iDbOp, iInOutType] of
    DB_BIN_LOAD:
    begin
      //
    end;
    DB_TEXT_LOAD:
    begin
      {TODO 4 -oBIGBOSS -cQuest Flags, Location and ExploreObjectives Processor}
    end;
  else
    Assert(False, 'Tried to perform an invalid serialization operation on type YQuestBehaviors.');
  end;
end;

procedure QuestExploreObjectivesProcessor(pDataPtr: Pointer; iDbOp: TDatabaseOperation;
  pInOutBuf: Pointer; iInOutType: TDataType; const Info: ITypeInfo; var sError: string);
//
begin
  case ProcessingTypeTable[iDbOp, iInOutType] of
    DB_BIN_LOAD:
    begin
      //
    end;
    DB_TEXT_LOAD:
    begin
      //there can be more than one!!
    end;
  else
    Assert(False, 'Tried to perform an invalid serialization operation on type YQuestBehaviors.');
  end;
end;

procedure YDbQuestTemplate.Assign(cSerializable: YDbSerializable);
var
  cQuest: YDbQuestTemplate;
begin
  inherited Assign(cSerializable);
  if not cSerializable.InheritsFrom(YDbQuestTemplate) then Exit;
  cQuest := YDbQuestTemplate(cSerializable);
  fReqLevel := cQuest.fReqLevel;
  fCategory := cQuest.fCategory;
  fQuestLevel := cQuest.fQuestLevel;
  fMoneyReward := cQuest.fMoneyReward;
  fTimeObjective := cQuest.fTimeObjective;
  fPrevQuest := cQuest.fPrevQuest;
  fNextQuest := cQuest.fNextQuest;
  fComplexity := cQuest.fComplexity;
  fLearnSpell := cQuest.fLearnSpell;
  fExploreObjective := cQuest.fExploreObjective;
  fQFinishNpc := cQuest.fQFinishNpc;
  fQFinishObj := cQuest.fQFinishObj;
  fQFinishItm := cQuest.fQFinishItm;
  fQGiverNpc := cQuest.fQGiverNpc;
  fQGiverObj := cQuest.fQGiverObj;
  fQGiverItm := cQuest.fQGiverItm;
  fDescriptiveFlags := cQuest.fDescriptiveFlags;
  fName := cQuest.fName;
  fObjectives := cQuest.fObjectives;
  fDetails := cQuest.fDetails;
  fEndText := cQuest.fEndText;
  fCompleteText := cQuest.fCompleteText;
  fIncompleteText := cQuest.fIncompleteText;
  fObjectiveText1 := cQuest.fObjectiveText1;
  fObjectiveText2 := cQuest.fObjectiveText2;
  fObjectiveText3 := cQuest.fObjectiveText3;
  fObjectiveText4 := cQuest.fObjectiveText4;
  fDeliverObjective := cQuest.fDeliverObjective;
  fRewardItmChoice := cQuest.fRewardItmChoice;
  fReceiveItem := cQuest.fReceiveItem;
  fLocation := cQuest.fLocation;
  fKillObjectiveMob := cQuest.fKillObjectiveMob;
  fKillObjectiveObj := cQuest.fKillObjectiveObj;
  fReqReputation := cQuest.fReqReputation;
  fRewardItem := cQuest.fRewardItem;
  fRequiresRace := cQuest.fRequiresRace;
  fRequiresClass := cQuest.fRequiresClass;
  fReqTradeSkill := cQuest.fReqTradeSkill;
  fQuestBehavior := cQuest.fQuestBehavior;
end;

procedure YDbQuestTemplate.RegisterClassFields(Registry: TSerializationRegistry);
begin
  inherited RegisterClassFields(Registry);

  Registry.RegisterTypeProcessingCallback(SYDoubleDword, @DoubleDwordProcessor);
  Registry.RegisterTypeProcessingCallback(SYQuestLocation, @QuestLocationProcessor);
  Registry.RegisterTypeProcessingCallback(SYQuestBehaviors, @QuestBehaviorsProcessor);
  Registry.RegisterTypeProcessingCallback(SYQuestObjects, @QuestObjectsProcessor);

  Registry.RegisterField(@fReqLevel, FIELD_QUEST_REQ_LEVEL, SUInt32);
  Registry.RegisterField(@fCategory, FIELD_QUEST_CATEGORY, SUInt32);
  Registry.RegisterField(@fQuestLevel, FIELD_QUEST_QUEST_LEVEL, SUInt32);
  Registry.RegisterField(@fMoneyReward, FIELD_QUEST_MONEY_REWARD, SUInt32);
  Registry.RegisterField(@fTimeObjective, FIELD_QUEST_TIME_OBJECTIVE, SUInt32);
  Registry.RegisterField(@fPrevQuest, FIELD_QUEST_PREV_QUEST, SUInt32);
  Registry.RegisterField(@fNextQuest, FIELD_QUEST_NEXT_QUEST, SUInt32);
  Registry.RegisterField(@fComplexity, FIELD_QUEST_COMPLEXITY, SUInt32);
  Registry.RegisterField(@fLearnSpell, FIELD_QUEST_LEARN_SPELL, SUInt32);
  Registry.RegisterField(@fExploreObjective, FIELD_QUEST_EXPLORE_OBJECTIVE, SUInt32);
  Registry.RegisterField(@fQFinishNpc, FIELD_QUEST_Q_FINISH_NPC, SUInt32);
  Registry.RegisterField(@fQFinishObj, FIELD_QUEST_Q_FINISH_OBJ, SUInt32);
  Registry.RegisterField(@fQFinishItm, FIELD_QUEST_Q_FINISH_ITM, SUInt32);
  Registry.RegisterField(@fQGiverNpc, FIELD_QUEST_Q_GIVER_NPC, SUInt32);
  Registry.RegisterField(@fQGiverObj, FIELD_QUEST_Q_GIVER_OBJ, SUInt32);
  Registry.RegisterField(@fQGiverItm, FIELD_QUEST_Q_GIVER_ITM, SUInt32);
  Registry.RegisterField(@fDescriptiveFlags, FIELD_QUEST_DESCRIPTIVE_FLAGS, SUInt32);
  Registry.RegisterField(@fName, FIELD_QUEST_NAME, SString);
  Registry.RegisterField(@fObjectives, FIELD_QUEST_OBJECTIVES, SString);
  Registry.RegisterField(@fDetails, FIELD_QUEST_DETAILS, SString);
  Registry.RegisterField(@fEndText, FIELD_QUEST_END_TEXT, SString);
  Registry.RegisterField(@fCompleteText, FIELD_QUEST_COMPLETE_TEXT, SString);
  Registry.RegisterField(@fIncompleteText, FIELD_QUEST_INCOMPLETE_TEXT, SString);
  Registry.RegisterField(@fObjectiveText1, FIELD_QUEST_OBJECTIVE_TEXT_1, SString);
  Registry.RegisterField(@fObjectiveText2, FIELD_QUEST_OBJECTIVE_TEXT_2, SString);
  Registry.RegisterField(@fObjectiveText3, FIELD_QUEST_OBJECTIVE_TEXT_3, SString);
  Registry.RegisterField(@fObjectiveText4, FIELD_QUEST_OBJECTIVE_TEXT_4, SString);
  Registry.RegisterField(@fDeliverObjective, FIELD_QUEST_DELIVER_OBJECTIVE, SYQuestObjects);
  Registry.RegisterField(@fRewardItmChoice, FIELD_QUEST_REWARD_ITM_CHOICE, SYQuestObjects);
  Registry.RegisterField(@fReceiveItem, FIELD_QUEST_RECEIVE_ITEM, SYQuestObjects);
  Registry.RegisterField(@fLocation, FIELD_QUEST_LOCATION, SYQuestLocation);
  Registry.RegisterField(@fKillObjectiveMob, FIELD_QUEST_KILL_OBJECTIVE_MOB, SYQuestObjects);
  Registry.RegisterField(@fKillObjectiveObj, FIELD_QUEST_KILL_OBJECTIVE_OBJ, SYQuestObjects);
  Registry.RegisterField(@fReqReputation, FIELD_QUEST_REQ_REPUTATION, SYDoubleDword);
  Registry.RegisterField(@fRewardItem, FIELD_QUEST_REWARD_ITEM, SYQuestObjects);
  Registry.RegisterField(@fRequiresRace, FIELD_QUEST_REQUIRES_RACE, SYDoubleDword);
  Registry.RegisterField(@fRequiresClass, FIELD_QUEST_REQUIRES_CLASS, SYDoubleDword);
  Registry.RegisterField(@fReqTradeSkill, FIELD_QUEST_REQ_TRADE_SKILL, SYDoubleDword);
  Registry.RegisterField(@fQuestBehavior, FIELD_QUEST_QUEST_BEHAVIOR, SYQuestBehaviors);
end;

{ YNPCTextsTemplate }

procedure YDbNPCTextsTemplate.Assign(cSerializable: YDbSerializable);
var
  cNPCTexts: YDbNPCTextsTemplate;
begin
  inherited Assign(cSerializable);
  if not cSerializable.InheritsFrom(YDbNPCTextsTemplate) then Exit;
  cNPCTexts := YDbNPCTextsTemplate(cSerializable);
  fText00 := cNPCTexts.fText00;
  fText01 := cNPCTexts.fText01;
  fText02 := cNPCTexts.fText02;
  fText03 := cNPCTexts.fText03;
  fText04 := cNPCTexts.fText04;
  fText05 := cNPCTexts.fText05;
  fText06 := cNPCTexts.fText06;
  fText07 := cNPCTexts.fText07;
  fText10 := cNPCTexts.fText10;
  fText11 := cNPCTexts.fText11;
  fText12 := cNPCTexts.fText12;
  fText13 := cNPCTexts.fText13;
  fText14 := cNPCTexts.fText14;
  fText15 := cNPCTexts.fText15;
  fText16 := cNPCTexts.fText16;
  fText17 := cNPCTexts.fText17;
  fProbability0 := cNPCTexts.fProbability0;
  fProbability1 := cNPCTexts.fProbability1;
  fProbability2 := cNPCTexts.fProbability2;
  fProbability3 := cNPCTexts.fProbability3;
  fProbability4 := cNPCTexts.fProbability4;
  fProbability5 := cNPCTexts.fProbability5;
  fProbability6 := cNPCTexts.fProbability6;
  fProbability7 := cNPCTexts.fProbability7;
  fLanguage0 := cNPCTexts.fLanguage0;
  fLanguage1 := cNPCTexts.fLanguage1;
  fLanguage2 := cNPCTexts.fLanguage2;
  fLanguage3 := cNPCTexts.fLanguage3;
  fLanguage4 := cNPCTexts.fLanguage4;
  fLanguage5 := cNPCTexts.fLanguage5;
  fLanguage6 := cNPCTexts.fLanguage6;
  fLanguage7 := cNPCTexts.fLanguage7;
  fEmoteId00 := cNPCTexts.fEmoteId00;
  fEmoteId10 := cNPCTexts.fEmoteId10;
  fEmoteId20 := cNPCTexts.fEmoteId20;
  fEmoteId01 := cNPCTexts.fEmoteId01;
  fEmoteId11 := cNPCTexts.fEmoteId11;
  fEmoteId21 := cNPCTexts.fEmoteId21;
  fEmoteId02 := cNPCTexts.fEmoteId02;
  fEmoteId12 := cNPCTexts.fEmoteId12;
  fEmoteId22 := cNPCTexts.fEmoteId22;
  fEmoteId03 := cNPCTexts.fEmoteId03;
  fEmoteId13 := cNPCTexts.fEmoteId13;
  fEmoteId23 := cNPCTexts.fEmoteId23;
  fEmoteId04 := cNPCTexts.fEmoteId04;
  fEmoteId14 := cNPCTexts.fEmoteId14;
  fEmoteId24 := cNPCTexts.fEmoteId24;
  fEmoteId05 := cNPCTexts.fEmoteId05;
  fEmoteId15 := cNPCTexts.fEmoteId15;
  fEmoteId25 := cNPCTexts.fEmoteId25;
  fEmoteId06 := cNPCTexts.fEmoteId06;
  fEmoteId16 := cNPCTexts.fEmoteId16;
  fEmoteId26 := cNPCTexts.fEmoteId26;
  fEmoteId07 := cNPCTexts.fEmoteId07;
  fEmoteId17 := cNPCTexts.fEmoteId17;
  fEmoteId27 := cNPCTexts.fEmoteId27;
  fEmoteDelay00 := cNPCTexts.fEmoteDelay00;
  fEmoteDelay10 := cNPCTexts.fEmoteDelay10;
  fEmoteDelay20 := cNPCTexts.fEmoteDelay20;
  fEmoteDelay01 := cNPCTexts.fEmoteDelay01;
  fEmoteDelay11 := cNPCTexts.fEmoteDelay11;
  fEmoteDelay21 := cNPCTexts.fEmoteDelay21;
  fEmoteDelay02 := cNPCTexts.fEmoteDelay02;
  fEmoteDelay12 := cNPCTexts.fEmoteDelay12;
  fEmoteDelay22 := cNPCTexts.fEmoteDelay22;
  fEmoteDelay03 := cNPCTexts.fEmoteDelay03;
  fEmoteDelay13 := cNPCTexts.fEmoteDelay13;
  fEmoteDelay23 := cNPCTexts.fEmoteDelay23;
  fEmoteDelay04 := cNPCTexts.fEmoteDelay04;
  fEmoteDelay14 := cNPCTexts.fEmoteDelay14;
  fEmoteDelay24 := cNPCTexts.fEmoteDelay24;
  fEmoteDelay05 := cNPCTexts.fEmoteDelay05;
  fEmoteDelay15 := cNPCTexts.fEmoteDelay15;
  fEmoteDelay25 := cNPCTexts.fEmoteDelay25;
  fEmoteDelay06 := cNPCTexts.fEmoteDelay06;
  fEmoteDelay16 := cNPCTexts.fEmoteDelay16;
  fEmoteDelay26 := cNPCTexts.fEmoteDelay26;
  fEmoteDelay07 := cNPCTexts.fEmoteDelay07;
  fEmoteDelay17 := cNPCTexts.fEmoteDelay17;
  fEmoteDelay27 := cNPCTexts.fEmoteDelay27;
end;

procedure YDbNPCTextsTemplate.RegisterClassFields(Registry: TSerializationRegistry);
begin
  inherited RegisterClassFields(Registry);

  Registry.RegisterField(@fText00, FIELD_NPCT_TEXT_0_0, SString);
  Registry.RegisterField(@fText01, FIELD_NPCT_TEXT_0_1, SString);
  Registry.RegisterField(@fText02, FIELD_NPCT_TEXT_0_2, SString);
  Registry.RegisterField(@fText03, FIELD_NPCT_TEXT_0_3, SString);
  Registry.RegisterField(@fText04, FIELD_NPCT_TEXT_0_4, SString);
  Registry.RegisterField(@fText05, FIELD_NPCT_TEXT_0_5, SString);
  Registry.RegisterField(@fText06, FIELD_NPCT_TEXT_0_6, SString);
  Registry.RegisterField(@fText07, FIELD_NPCT_TEXT_0_7, SString);
  Registry.RegisterField(@fText10, FIELD_NPCT_TEXT_1_0, SString);
  Registry.RegisterField(@fText11, FIELD_NPCT_TEXT_1_1, SString);
  Registry.RegisterField(@fText12, FIELD_NPCT_TEXT_1_2, SString);
  Registry.RegisterField(@fText13, FIELD_NPCT_TEXT_1_3, SString);
  Registry.RegisterField(@fText14, FIELD_NPCT_TEXT_1_4, SString);
  Registry.RegisterField(@fText15, FIELD_NPCT_TEXT_1_5, SString);
  Registry.RegisterField(@fText16, FIELD_NPCT_TEXT_1_6, SString);
  Registry.RegisterField(@fText17, FIELD_NPCT_TEXT_1_7, SString);
  Registry.RegisterField(@fProbability0, FIELD_NPCT_PROBABILITY_0, SFloat);
  Registry.RegisterField(@fProbability1, FIELD_NPCT_PROBABILITY_1, SFloat);
  Registry.RegisterField(@fProbability2, FIELD_NPCT_PROBABILITY_2, SFloat);
  Registry.RegisterField(@fProbability3, FIELD_NPCT_PROBABILITY_3, SFloat);
  Registry.RegisterField(@fProbability4, FIELD_NPCT_PROBABILITY_4, SFloat);
  Registry.RegisterField(@fProbability5, FIELD_NPCT_PROBABILITY_5, SFloat);
  Registry.RegisterField(@fProbability6, FIELD_NPCT_PROBABILITY_6, SFloat);
  Registry.RegisterField(@fProbability7, FIELD_NPCT_PROBABILITY_7, SFloat);
  Registry.RegisterField(@fLanguage0, FIELD_NPCT_LANGUAGE_0, SUInt32);
  Registry.RegisterField(@fLanguage1, FIELD_NPCT_LANGUAGE_1, SUInt32);
  Registry.RegisterField(@fLanguage2, FIELD_NPCT_LANGUAGE_2, SUInt32);
  Registry.RegisterField(@fLanguage3, FIELD_NPCT_LANGUAGE_3, SUInt32);
  Registry.RegisterField(@fLanguage4, FIELD_NPCT_LANGUAGE_4, SUInt32);
  Registry.RegisterField(@fLanguage5, FIELD_NPCT_LANGUAGE_5, SUInt32);
  Registry.RegisterField(@fLanguage6, FIELD_NPCT_LANGUAGE_6, SUInt32);
  Registry.RegisterField(@fLanguage7, FIELD_NPCT_LANGUAGE_7, SUInt32);
  Registry.RegisterField(@fEmoteId00, FIELD_NPCT_EMOTE_ID_0_0, SUInt32);
  Registry.RegisterField(@fEmoteId10, FIELD_NPCT_EMOTE_ID_1_0, SUInt32);
  Registry.RegisterField(@fEmoteId20, FIELD_NPCT_EMOTE_ID_2_0, SUInt32);
  Registry.RegisterField(@fEmoteId01, FIELD_NPCT_EMOTE_ID_0_1, SUInt32);
  Registry.RegisterField(@fEmoteId11, FIELD_NPCT_EMOTE_ID_1_1, SUInt32);
  Registry.RegisterField(@fEmoteId21, FIELD_NPCT_EMOTE_ID_2_1, SUInt32);
  Registry.RegisterField(@fEmoteId02, FIELD_NPCT_EMOTE_ID_0_2, SUInt32);
  Registry.RegisterField(@fEmoteId12, FIELD_NPCT_EMOTE_ID_1_2, SUInt32);
  Registry.RegisterField(@fEmoteId22, FIELD_NPCT_EMOTE_ID_2_2, SUInt32);
  Registry.RegisterField(@fEmoteId03, FIELD_NPCT_EMOTE_ID_0_3, SUInt32);
  Registry.RegisterField(@fEmoteId13, FIELD_NPCT_EMOTE_ID_1_3, SUInt32);
  Registry.RegisterField(@fEmoteId23, FIELD_NPCT_EMOTE_ID_2_3, SUInt32);
  Registry.RegisterField(@fEmoteId04, FIELD_NPCT_EMOTE_ID_0_4, SUInt32);
  Registry.RegisterField(@fEmoteId14, FIELD_NPCT_EMOTE_ID_1_4, SUInt32);
  Registry.RegisterField(@fEmoteId24, FIELD_NPCT_EMOTE_ID_2_4, SUInt32);
  Registry.RegisterField(@fEmoteId05, FIELD_NPCT_EMOTE_ID_0_5, SUInt32);
  Registry.RegisterField(@fEmoteId15, FIELD_NPCT_EMOTE_ID_1_5, SUInt32);
  Registry.RegisterField(@fEmoteId25, FIELD_NPCT_EMOTE_ID_2_5, SUInt32);
  Registry.RegisterField(@fEmoteId06, FIELD_NPCT_EMOTE_ID_0_6, SUInt32);
  Registry.RegisterField(@fEmoteId16, FIELD_NPCT_EMOTE_ID_1_6, SUInt32);
  Registry.RegisterField(@fEmoteId26, FIELD_NPCT_EMOTE_ID_2_6, SUInt32);
  Registry.RegisterField(@fEmoteId07, FIELD_NPCT_EMOTE_ID_0_7, SUInt32);
  Registry.RegisterField(@fEmoteId17, FIELD_NPCT_EMOTE_ID_1_7, SUInt32);
  Registry.RegisterField(@fEmoteId27, FIELD_NPCT_EMOTE_ID_2_7, SUInt32);
  Registry.RegisterField(@fEmoteDelay00, FIELD_NPCT_EMOTE_DELAY_0_0, SUInt32);
  Registry.RegisterField(@fEmoteDelay10, FIELD_NPCT_EMOTE_DELAY_1_0, SUInt32);
  Registry.RegisterField(@fEmoteDelay20, FIELD_NPCT_EMOTE_DELAY_2_0, SUInt32);
  Registry.RegisterField(@fEmoteDelay01, FIELD_NPCT_EMOTE_DELAY_0_1, SUInt32);
  Registry.RegisterField(@fEmoteDelay11, FIELD_NPCT_EMOTE_DELAY_1_1, SUInt32);
  Registry.RegisterField(@fEmoteDelay21, FIELD_NPCT_EMOTE_DELAY_2_1, SUInt32);
  Registry.RegisterField(@fEmoteDelay02, FIELD_NPCT_EMOTE_DELAY_0_2, SUInt32);
  Registry.RegisterField(@fEmoteDelay12, FIELD_NPCT_EMOTE_DELAY_1_2, SUInt32);
  Registry.RegisterField(@fEmoteDelay22, FIELD_NPCT_EMOTE_DELAY_2_2, SUInt32);
  Registry.RegisterField(@fEmoteDelay03, FIELD_NPCT_EMOTE_DELAY_0_3, SUInt32);
  Registry.RegisterField(@fEmoteDelay13, FIELD_NPCT_EMOTE_DELAY_1_3, SUInt32);
  Registry.RegisterField(@fEmoteDelay23, FIELD_NPCT_EMOTE_DELAY_2_3, SUInt32);
  Registry.RegisterField(@fEmoteDelay04, FIELD_NPCT_EMOTE_DELAY_0_4, SUInt32);
  Registry.RegisterField(@fEmoteDelay14, FIELD_NPCT_EMOTE_DELAY_1_4, SUInt32);
  Registry.RegisterField(@fEmoteDelay24, FIELD_NPCT_EMOTE_DELAY_2_4, SUInt32);
  Registry.RegisterField(@fEmoteDelay05, FIELD_NPCT_EMOTE_DELAY_0_5, SUInt32);
  Registry.RegisterField(@fEmoteDelay15, FIELD_NPCT_EMOTE_DELAY_1_5, SUInt32);
  Registry.RegisterField(@fEmoteDelay25, FIELD_NPCT_EMOTE_DELAY_2_5, SUInt32);
  Registry.RegisterField(@fEmoteDelay06, FIELD_NPCT_EMOTE_DELAY_0_6, SUInt32);
  Registry.RegisterField(@fEmoteDelay16, FIELD_NPCT_EMOTE_DELAY_1_6, SUInt32);
  Registry.RegisterField(@fEmoteDelay26, FIELD_NPCT_EMOTE_DELAY_2_6, SUInt32);
  Registry.RegisterField(@fEmoteDelay07, FIELD_NPCT_EMOTE_DELAY_0_7, SUInt32);
  Registry.RegisterField(@fEmoteDelay17, FIELD_NPCT_EMOTE_DELAY_1_7, SUInt32);
  Registry.RegisterField(@fEmoteDelay27, FIELD_NPCT_EMOTE_DELAY_2_7, SUInt32);
end;

{ YAccountEntry }

procedure YDbAccountEntry.Assign(cSerializable: YDbSerializable);
var
  cAcc: YDbAccountEntry;
begin
  inherited Assign(cSerializable);
  if not cSerializable.InheritsFrom(YDbAccountEntry) then Exit;
  cAcc := YDbAccountEntry(cSerializable);
  fName := cAcc.fName;
  fPass := cAcc.fPass;
  fHash := cAcc.fHash;
  fLoggedIn := cAcc.fLoggedIn;
  fAutoCreated := cAcc.fAutoCreated;
  fAccess := cAcc.Access;
  fStatus := cAcc.Status;
end;

procedure YDbAccountEntry.RegisterClassFields(Registry: TSerializationRegistry);
begin
  inherited RegisterClassFields(Registry);

  SystemTypeRegistry.RegisterType(TypeInfo(YAccountAccess));
  SystemTypeRegistry.RegisterType(TypeInfo(YAccountStatus));

  Registry.RegisterTypeProcessingCallback(SYAccountAccess, @EnumProcessor);
  Registry.RegisterTypeProcessingCallback(SYAccountStatus, @EnumProcessor);

  Registry.RegisterField(@fName, FIELD_ACC_NAME, SString);
  Registry.RegisterField(@fPass, FIELD_ACC_PASS, SString);
  { We don't have to save these 2 fields }
  //Registry.RegisterField(@fHash, FIELD_ACC_HASH, SString);
  //Registry.RegisterField(@fLoggedIn, FIELD_ACC_LOGGEDIN, SBoolean);
  Registry.RegisterField(@fAutoCreated, FIELD_ACC_AUTOCREATE, SBoolean);
  Registry.RegisterField(@fAccess, FIELD_ACC_ACCESS, SYAccountAccess);
  Registry.RegisterField(@fStatus, FIELD_ACC_STATUS, SYAccountStatus);
end;

{ YUpdateable }

procedure YDbWowObjectEntry.Assign(cSerializable: YDbSerializable);
var
  cUpd: YDbWowObjectEntry;
begin
  inherited Assign(cSerializable);
  if not cSerializable.InheritsFrom(YDbWowObjectEntry) then Exit;
  cUpd := YDbWowObjectEntry(cSerializable);
  
  SetLength(fUpdateData, Length(cUpd.fUpdateData));
  Move(cUpd.fUpdateData[0], fUpdateData[0], Length(fUpdateData) * SizeOf(UInt32));

  SetLength(fTimers, Length(cUpd.fTimers));
  Move(cUpd.fTimers[0], fTimers[0], Length(fTimers) * SizeOf(UInt32));
end;

procedure YDbWowObjectEntry.AssignUpdateData(pData: PLongWordArray; iCount: Int32);
begin
  SetLength(fUpdateData, iCount);
  Move(pData^[0], fUpdateData[0], iCount * SizeOf(Longword));
end;

procedure YDbWowObjectEntry.RegisterClassFields(Registry: TSerializationRegistry);
begin
  inherited RegisterClassFields(Registry);
  Registry.RegisterField(@fUpdateData, FIELD_UPDATE_DATA, STLongwordArr);
end;

{ YItemEntry }

procedure YDbItemEntry.Assign(cSerializable: YDbSerializable);
var
  cItem: YDbItemEntry;
begin
  inherited Assign(cSerializable);
  if not cSerializable.InheritsFrom(YDbItemEntry) then Exit;
  cItem := YDbItemEntry(cSerializable);
  fEntry := cItem.fEntry;
  fStackCount := cItem.fStackCount;
  fDurability := cItem.fDurability;
  fContained := cItem.fContained;
  fCreator := cItem.fCreator;
  SetLength(fItemsContained, Length(cItem.fItemsContained));
  Move(cItem.fItemsContained[0], fItemsContained[0], Length(fItemsContained) * SizeOf(UInt32));
end;

procedure YDbItemEntry.RegisterClassFields(Registry: TSerializationRegistry);
begin
  inherited RegisterClassFields(Registry);
  Registry.RegisterField(@fEntry, FIELD_ITI_ENTRY, SUInt32);
  Registry.RegisterField(@fStackCount, FIELD_ITI_STACKCOUNT, SUInt32);
  Registry.RegisterField(@fDurability, FIELD_ITI_DURABILITY, SUInt32);
  Registry.RegisterField(@fContained, FIELD_ITI_CONTAINED, SUInt32);
  Registry.RegisterField(@fCreator, FIELD_ITI_CREATOR, SUInt32);
  Registry.RegisterField(@fItemsContained, FIELD_ITI_ITEMS, STLongwordArr);
end;

procedure YDbItemEntry.SetItemsContainedLength(iNewLen: Int32);
begin
  SetLength(fItemsContained, iNewLen);
end;

{ YStationary }

procedure YDbPlaceableEntry.Assign(cSerializable: YDbSerializable);
var
  cSta: YDbPlaceableEntry;
begin
  inherited Assign(cSerializable);
  if not cSerializable.InheritsFrom(YDbPlaceableEntry) then Exit;
  cSta := YDbPlaceableEntry(cSerializable);
  fPosX := cSta.fPosX;
  fPosY := cSta.fPosY;
  fPosZ := cSta.fPosZ;
  fAngle := cSta.fAngle;
  fZoneId := cSta.fZoneId;
  fMapId := cSta.fMapId;
end;

procedure YDbPlaceableEntry.RegisterClassFields(Registry: TSerializationRegistry);
begin
  inherited RegisterClassFields(Registry);
  Registry.RegisterField(@fPosX, FIELD_MOI_POS_X, SFloat);
  Registry.RegisterField(@fPosY, FIELD_MOI_POS_Y, SFloat);
  Registry.RegisterField(@fPosZ, FIELD_MOI_POS_Z, SFloat);
  Registry.RegisterField(@fAngle, FIELD_MOI_POS_O, SFloat);
  Registry.RegisterField(@fMapId, FIELD_MOI_POS_MI, SUInt32);
  Registry.RegisterField(@fZoneId, FIELD_MOI_POS_ZI, SUInt32);
end;

{ YMoveable }

procedure YDbMoveableEntry.Assign(cSerializable: YDbSerializable);
var
  cMov: YDbMoveableEntry;
begin
  inherited Assign(cSerializable);
  if not cSerializable.InheritsFrom(YDbMoveableEntry) then Exit;
  cMov := YDbMoveableEntry(cSerializable);
  fSpeedWalk := cMov.fSpeedWalk;
  fSpeedRun := cMov.fSpeedRun;
  fSpeedBackSwim := cMov.fSpeedBackSwim;
  fSpeedSwim := cMov.fSpeedSwim;
  fSpeedBackWalk := cMov.fSpeedBackWalk;
  fSpeedTurn := cMov.fSpeedTurn;
end;

procedure YDbMoveableEntry.RegisterClassFields(Registry: TSerializationRegistry);
begin
  inherited RegisterClassFields(Registry);
  Registry.RegisterField(@fSpeedWalk, FIELD_MOI_SPD_WALK, SFloat);
  Registry.RegisterField(@fSpeedRun, FIELD_MOI_SPD_RUN, SFloat);
  Registry.RegisterField(@fSpeedBackWalk, FIELD_MOI_SPD_BKWALK, SFloat);
  Registry.RegisterField(@fSpeedSwim, FIELD_MOI_SPD_SWIM, SFloat);
  Registry.RegisterField(@fSpeedBackSwim, FIELD_MOI_SPD_BKSWIM, SFloat);
  Registry.RegisterField(@fSpeedTurn, FIELD_MOI_SPD_TURN, SFloat);
end;

{ YPlayerEntry }

procedure ActiveQuestsProcessor(pDataPtr: Pointer; iDbOp: TDatabaseOperation;
  pInOutBuf: Pointer; iInOutType: TDataType; const Info: ITypeInfo; var sError: string);
type
  PActiveQuests = ^YActiveQuests;
var
  aArr: array[0..QUEST_OBJECTS_COUNT] of UInt32;
  iIdx: Int32;
  sActiveQuest: string;
  aActiveQuestsData: PActiveQuests;
begin
  case ProcessingTypeTable[iDbOp, iInOutType] of
    DB_BIN_LOAD:
    begin
      aActiveQuestsData := PActiveQuests(pDataPtr);
      Inc(PByte(pInOutBuf), 4);
      Move(pInOutBuf^, aActiveQuestsData^, SizeOf(YQuestLocation));
    end;
    DB_TEXT_LOAD:
    begin
      aActiveQuestsData := PActiveQuests(pDataPtr);
      iIdx := aActiveQuestsData^.Count;
      if iIdx >= QUEST_LOG_COUNT then
      begin
        Exit;
      end;
      StringToArray(PString(pInOutBuf)^, aArr);
      aActiveQuestsData^.Quests[iIdx].Id := aArr[0];
      Move(aArr[1], aActiveQuestsData^.Quests[iIdx].KillObjectives[0], QUEST_OBJECTS_COUNT * SizeOf(UInt32));
      Inc(aActiveQuestsData^.Count);
    end;
    DB_TEXT_SAVE:
    begin
      for iIdx := 0 to YActiveQuests(pDataPtr^).Count - 1 do
      begin
        aActiveQuestsData := PActiveQuests(pDataPtr);
        aArr[0] := aActiveQuestsData^.Quests[iIdx].Id;
        Move(aActiveQuestsData^.Quests[iIdx].KillObjectives[0], aArr[1], QUEST_OBJECTS_COUNT * SizeOf(UInt32));
        if iIdx + 1 <> YActiveQuests(pDataPtr^).Count then
          sActiveQuest := sActiveQuest + ArrayToString(aArr) + #13 + FIELD_PLI_ACTIVE_QUESTS + ' = '
        else
          sActiveQuest := sActiveQuest + ArrayToString(aArr);
        {BIGBOSS : sry for that temporary brute fix :P. Plz correct it if you can}
      end;
      PString(pInOutBuf)^ := sActiveQuest;
    end
  else
    Assert(False, 'Tried to perform an invalid serialization operation on type YActiveQuests.');
  end;
end;

procedure YDbPlayerEntry.Assign(cSerializable: YDbSerializable);
var
  cPlayer: YDbPlayerEntry;
  iIdx: Int32;
begin
  inherited Assign(cSerializable);
  if not cSerializable.InheritsFrom(YDbPlayerEntry) then Exit;
  cPlayer := YDbPlayerEntry(cSerializable);
  fAccount := cPlayer.fAccount;
  fCharName := cPlayer.fCharName;
  fPrivileges := cPlayer.fPrivileges;
  fRested := cPlayer.fRested;

  SetLength(fTutorials, Length(cPlayer.fTutorials));
  Move(cPlayer.fTutorials[0], fTutorials[0], Length(fTutorials) * SizeOf(UInt32));

  SetLength(fActionButtons, Length(cPlayer.fActionButtons));
  Move(cPlayer.fActionButtons[0], fActionButtons[0], Length(fActionButtons) * SizeOf(UInt32));

  SetLength(fEquippedItems, Length(cPlayer.fEquippedItems));
  Move(cPlayer.fEquippedItems[0], fEquippedItems[0], Length(fEquippedItems) * SizeOf(UInt32));

  SetLength(fHonorStats, Length(cPlayer.fHonorStats));
  Move(cPlayer.fHonorStats[0], fHonorStats[0], Length(fHonorStats) * SizeOf(UInt32));

  Move(cPlayer.fActiveQuests.Quests[0], fActiveQuests.Quests[0], SizeOf(YActiveQuests));

  SetLength(fFinishedQuests, Length(cPlayer.fFinishedQuests));
  Move(cPlayer.fFinishedQuests[0], fFinishedQuests[0], Length(fFinishedQuests) * SizeOf(UInt32));

  SetLength(fPriviledges, Length(cPlayer.fPriviledges));
  for iIdx := 0 to Length(cPlayer.fPriviledges) -1 do
  begin
    fPriviledges[iIdx] := cPlayer.fPriviledges[iIdx];
  end;
end;

procedure YDbPlayerEntry.RegisterClassFields(Registry: TSerializationRegistry);
begin
  inherited RegisterClassFields(Registry);
  //SystemTypeRegistry.RegisterType(SYActiveQuests, SizeOf(YActiveQuests));

  Registry.RegisterTypeProcessingCallback(SYActiveQuests, @ActiveQuestsProcessor);

  Registry.RegisterField(@fAccount, FIELD_PLI_ACCOUNT_NAME, SString);
  Registry.RegisterField(@fCharName, FIELD_PLI_CHAR_NAME, SString);
  Registry.RegisterField(@fRested, FIELD_PLI_RESTED_STATE, SUInt32);
  Registry.RegisterField(@fTutorials, FIELD_PLI_TUTORIALS, STLongwordArr);
  Registry.RegisterField(@fActiveQuests, FIELD_PLI_ACTIVE_QUESTS, SYActiveQuests);
  Registry.RegisterField(@fActionButtons, FIELD_PLI_ACTION_BTNS, STLongwordArr);
  Registry.RegisterField(@fEquippedItems, FIELD_PLI_EQUIPMENT, STLongwordArr);
  Registry.RegisterField(@fHonorStats, FIELD_PLI_HONOR_STATS, STLongwordArr);
  Registry.RegisterField(@fFinishedQuests, FIELD_PLI_FINISHED_QUESTS, STLongwordArr);
end;

procedure YDbPlayerEntry.SetActionButtonsLength(iNewLen: Int32);
begin
  SetLength(fActionButtons, iNewLen);
end;

procedure YDbPlayerEntry.SetEquippedItemsLength(iNewLen: Int32);
begin
  SetLength(fEquippedItems, iNewLen);
end;

procedure YDbPlayerEntry.SetHonorStatsLength(iNewLen: Int32);
begin
  SetLength(fHonorStats, iNewLen);
end;

procedure YDbPlayerEntry.SetPriviledgesLength(iNewLen: Int32);
begin
  SetLength(fPriviledges, iNewLen);
end;

procedure YDbPlayerEntry.SetTutorialsLength(iNewLen: Int32);
begin
  SetLength(fTutorials, iNewLen);
end;

{ YNodeEntry }

procedure YDbNodeEntry.Assign(cSerializable: YDbSerializable);
var
  cNode: YDbNodeEntry;
begin
  inherited Assign(cSerializable);
  if not cSerializable.InheritsFrom(YDbNodeEntry) then Exit;
  cNode := YDbNodeEntry(cSerializable);
  fPosX := cNode.fPosX;
  fPosY := cNode.fPosY;
  fPosZ := cNode.fPosZ;
  fMapId := cNode.fMapId;
  fFlags := cNode.fFlags;
end;

procedure YDbNodeEntry.RegisterClassFields(Registry: TSerializationRegistry);
begin
  inherited RegisterClassFields(Registry);

  SystemTypeRegistry.RegisterType(TypeInfo(YNodeFlags));

  Registry.RegisterField(@fPosX, FIELD_MOI_POS_X, SFloat);
  Registry.RegisterField(@fPosY, FIELD_MOI_POS_Y, SFloat);
  Registry.RegisterField(@fPosZ, FIELD_MOI_POS_Z, SFloat);
  Registry.RegisterField(@fMapId, FIELD_MOI_POS_MI, SUInt32);
  Registry.RegisterField(@fFlags, FIELD_NODE_FLAGS, SNodeFlags);
end;

{ YAddonEntry }

procedure YDbAddonEntry.Assign(cSerializable: YDbSerializable);
var
  cAddon: YDbAddonEntry;
begin
  inherited Assign(cSerializable);
  if not cSerializable.InheritsFrom(YDbAddonEntry) then Exit;
  cAddon := YDbAddonEntry(cSerializable);
  fName := cAddon.fName;
  fCRC32 := cAddon.fCRC32;
  fEnabled := cAddon.fEnabled;
end;

procedure YDbAddonEntry.RegisterClassFields(Registry: TSerializationRegistry);
begin
  inherited RegisterClassFields(Registry);
  Registry.RegisterField(@fName, FIELD_ADDON_NAME, SString);
  Registry.RegisterField(@fCRC32, FIELD_ADDON_CRC, SUInt32);
  Registry.RegisterField(@fEnabled, FIELD_ADDON_VALID, SBoolean);
end;

{ YItemTemplate }

procedure YDbItemTemplate.AfterLoad;
begin
  if fNameForQuest = '' then fNameForQuest := fName;
  if fNameHonorable = '' then fNameHonorable := fName;
  if fNameEnchanting = '' then fNameEnchanting := fName;
end;

procedure YDbItemTemplate.Assign(cSerializable: YDbSerializable);
var
  cItem: YDbItemTemplate;
begin
  inherited Assign(cSerializable);
  if not cSerializable.InheritsFrom(YDbItemTemplate) then Exit;
  cItem := YDbItemTemplate(cSerializable);
  
  fClass := cItem.fClass;
  fSubClass := cItem.fSubClass;
  fModelId := cItem.fModelId;
  fQuality := cItem.fQuality;
  fFlags := cItem.fFlags;
  fBuyPrice := cItem.fBuyPrice;
  fSellPrice := cItem.fSellPrice;
  fInventoryType := cItem.fInventoryType;
  fAllowedRaces := cItem.fAllowedRaces;
  fAllowedClasses := cItem.fAllowedClasses;
  fItemLevel := cItem.fItemLevel;
  fReqLevel := cItem.fReqLevel;
  fReqSkill := cItem.fReqSkill;
  fReqSkillRank := cItem.fReqSkillRank;
  fReqSpell := cItem.fReqSpell;
  fReqFaction := cItem.fReqFaction;
  fReqFactionLevel := cItem.fReqFactionLevel;
  fReqPVPRank1 := cItem.fReqPVPRank1;
  fReqPVPRank2 := cItem.fReqPVPRank2;
  fMaximumCount := cItem.fMaximumCount;
  fUniqueFlag := cItem.fUniqueFlag;
  fContainerSlots := cItem.fContainerSlots;
  fStats := cItem.fStats;
  fDamageTypes := cItem.fDamageTypes;
  fResistancePhysical := cItem.fResistancePhysical;
  fResistanceHoly := cItem.fResistanceHoly;
  fResistanceFire := cItem.fResistanceFire;
  fResistanceNature := cItem.fResistanceNature;
  fResistanceFrost := cItem.fResistanceFrost;
  fResistanceShadow := cItem.fResistanceShadow;
  fResistanceArcane := cItem.fResistanceArcane;
  fDelay := cItem.fDelay;
  fAmmunitionType := cItem.fAmmunitionType;
  fItemSpells := cItem.fItemSpells;
  fBonding := cItem.fBonding;
  fRangeModifier := cItem.fRangeModifier;
  fPageID := cItem.fPageID;
  fPageLanguage := cItem.fPageLanguage;
  fPageMaterial := cItem.fPageMaterial;
  fStartsQuest := cItem.fStartsQuest;
  fLockID := cItem.fLockID;
  fLockMaterial := cItem.fLockMaterial;
  fSheath := cItem.fSheath;
  fExtraInfo := cItem.fExtraInfo;
  fExtraInfo2 := cItem.fExtraInfo2;
  fBlock := cItem.fBlock;
  fItemSet := cItem.fItemSet;
  fMaximumDurability := cItem.fMaximumDurability;
  fArea := cItem.fArea;
  fMapId := cItem.fMapId;
  fBagFamily := cItem.fBagFamily;
  fTotemCategory := cItem.fTotemCategory;
  fSocketColor1 := cItem.fSocketColor1;
  fUnk2 := cItem.fUnk2;
  fSocketColor2 := cItem.fSocketColor2;
  fUnk3 := cItem.fUnk3;
  fSocketColor3 := cItem.fSocketColor3;
  fUnk4 := cItem.fUnk4;
  fSocketBonus := cItem.fSocketBonus;
  fGemProperties := cItem.fGemProperties;
  fItemExtendedCost := cItem.fItemExtendedCost;
  fDisenchantReqSkill := cItem.fDisenchantReqSkill;

  fName := cItem.fName;
  fNameForQuest := cItem.fNameForQuest;
  fNameHonorable := cItem.fNameHonorable;
  fNameEnchanting := cItem.fNameEnchanting;
  fDescription := cItem.fDescription;
end;

procedure YDbItemTemplate.FillItemTemplateInfoBuffer(cBuffer: TByteBuffer);
var
  pTemp: PLongword;
  lwTemp: Longword;
  iRaces: YGameRaces absolute lwTemp;
  iClasses: YGameClasses absolute lwTemp;
begin
  pTemp := @fClass;
  cBuffer.AddUInt32(UniqueID);
  cBuffer.AddPtrData(pTemp, 12);
  Inc(pTemp, 3);
  cBuffer.AddStringMultiple([fName, fNameForQuest, fNameHonorable, fNameEnchanting]);
  cBuffer.AddPtrData(pTemp, 24);
  Inc(pTemp, 5 + (SizeOf(YGameClasses) + SizeOf(YGameRaces) div 4));
  iClasses := fAllowedClasses;
  if iClasses = gcAll then
  begin
    cBuffer.AddUInt32($FFFFFFFF);
  end else
  begin
    cBuffer.AddUInt32(lwTemp shr 1);
  end;
  iRaces := fAllowedRaces;
  if iRaces = grAll then
  begin
    cBuffer.AddUInt32($FFFFFFFF);
  end else
  begin
    cBuffer.AddUInt32(lwTemp shr 1);
  end;
  cBuffer.AddPtrData(pTemp, 352);
  Inc(pTemp, 88);
  cBuffer.AddString(Description);
  cBuffer.AddPtrData(pTemp, 104);
end;

function YDbItemTemplate.GetItemSpellData(iIndex: Int32): PItemSpellRec;
begin
  Assert(iIndex < Length(fItemSpells));
  Result := @fItemSpells[iIndex];
end;

function YDbItemTemplate.GetStatData(iIndex: Int32): PStatRec;
begin
  Assert(iIndex < Length(fStats));
  Result := @fStats[iIndex];
end;

function YDbItemTemplate.GetWeaponDamageData(iIndex: Int32): PWeaponDamageRec;
begin
  Assert(iIndex < Length(fDamageTypes));
  Result := @fDamageTypes[iIndex];
end;

procedure YDbItemTemplate.RegisterClassFields(Registry: TSerializationRegistry);
begin
  inherited RegisterClassFields(Registry);

  SystemTypeRegistry.RegisterType(TypeInfo(YGameClass));
  SystemTypeRegistry.RegisterType(TypeInfo(YGameClasses));
  SystemTypeRegistry.RegisterType(TypeInfo(YGameRace));
  SystemTypeRegistry.RegisterType(TypeInfo(YGameRaces));

  Registry.RegisterTypeProcessingCallback(SGameRaces, @GameRacesProcessor);
  Registry.RegisterTypeProcessingCallback(SGameClasses, @GameClassesProcessor);

  Registry.RegisterField(@fClass, FIELD_ITM_CLASS, SUInt32);
  Registry.RegisterField(@fSubClass, FIELD_ITM_SUBCLASS, SUInt32);
  Registry.RegisterField(@fUnknown206, FIELD_ITM_TBC_UNKNOWN, SUInt32);
  Registry.RegisterField(@fModelId, FIELD_ITM_MODEL_ID, SUInt32);
  Registry.RegisterField(@fQuality, FIELD_ITM_QUALITY, SUInt32);
  Registry.RegisterField(@fFlags, FIELD_ITM_FLAGS, SUInt32);
  Registry.RegisterField(@fBuyPrice, FIELD_ITM_BUY_PRICE, SUInt32);
  Registry.RegisterField(@fSellPrice, FIELD_ITM_SELL_PRICE, SUInt32);
  Registry.RegisterField(@fInventoryType, FIELD_ITM_INVENTORY_TYPE, SUInt32);
  Registry.RegisterField(@fAllowedRaces, FIELD_ITM_ALLOWABLE_RACE, SGameRaces);
  Registry.RegisterField(@fAllowedClasses, FIELD_ITM_ALLOWABLE_CLASS, SGameClasses);
  Registry.RegisterField(@fItemLevel, FIELD_ITM_ITEM_LEVEL, SUInt32);
  Registry.RegisterField(@fReqLevel, FIELD_ITM_REQ_LEVEL, SUInt32);
  Registry.RegisterField(@fReqSkill, FIELD_ITM_REQ_SKILL, SUInt32);
  Registry.RegisterField(@fReqSkillRank, FIELD_ITM_REQ_SKILL_RANK, SUInt32);
  Registry.RegisterField(@fReqSpell, FIELD_ITM_REQ_SPELL, SUInt32);
  Registry.RegisterField(@fReqFaction, FIELD_ITM_REQ_FACTION, SUInt32);
  Registry.RegisterField(@fReqFactionLevel, FIELD_ITM_REQ_FACTION_LEVEL, SUInt32);
  Registry.RegisterField(@fReqPVPRank1, FIELD_ITM_REQ_PVP_RANK_1, SUInt32);
  Registry.RegisterField(@fReqPVPRank2, FIELD_ITM_REQ_PVP_RANK_2, SUInt32);
  Registry.RegisterField(@fMaximumCount, FIELD_ITM_MAX_NO_OF_ITEMS, SUInt32);
  Registry.RegisterField(@fUniqueFlag, FIELD_ITM_UNIQUE_FLAG, SUInt32);
  Registry.RegisterField(@fContainerSlots, FIELD_ITM_CONTAINER_SLOTS, SUInt32);
  Registry.RegisterField(@fStats[0].StatType, FIELD_ITM_STAT_TYPE_0, SUInt32);
  Registry.RegisterField(@fStats[0].Value, FIELD_ITM_STAT_VALUE_0, SUInt32);
  Registry.RegisterField(@fStats[1].StatType, FIELD_ITM_STAT_TYPE_1, SUInt32);
  Registry.RegisterField(@fStats[1].Value, FIELD_ITM_STAT_VALUE_1, SUInt32);
  Registry.RegisterField(@fStats[2].StatType, FIELD_ITM_STAT_TYPE_2, SUInt32);
  Registry.RegisterField(@fStats[2].Value, FIELD_ITM_STAT_VALUE_2, SUInt32);
  Registry.RegisterField(@fStats[3].StatType, FIELD_ITM_STAT_TYPE_3, SUInt32);
  Registry.RegisterField(@fStats[3].Value, FIELD_ITM_STAT_VALUE_3, SUInt32);
  Registry.RegisterField(@fStats[4].StatType, FIELD_ITM_STAT_TYPE_4, SUInt32);
  Registry.RegisterField(@fStats[4].Value, FIELD_ITM_STAT_VALUE_4, SUInt32);
  Registry.RegisterField(@fStats[5].StatType, FIELD_ITM_STAT_TYPE_5, SUInt32);
  Registry.RegisterField(@fStats[5].Value, FIELD_ITM_STAT_VALUE_5, SUInt32);
  Registry.RegisterField(@fStats[6].StatType, FIELD_ITM_STAT_TYPE_6, SUInt32);
  Registry.RegisterField(@fStats[6].Value, FIELD_ITM_STAT_VALUE_6, SUInt32);
  Registry.RegisterField(@fStats[7].StatType, FIELD_ITM_STAT_TYPE_7, SUInt32);
  Registry.RegisterField(@fStats[7].Value, FIELD_ITM_STAT_VALUE_7, SUInt32);
  Registry.RegisterField(@fStats[8].StatType, FIELD_ITM_STAT_TYPE_8, SUInt32);
  Registry.RegisterField(@fStats[8].Value, FIELD_ITM_STAT_VALUE_8, SUInt32);
  Registry.RegisterField(@fStats[9].StatType, FIELD_ITM_STAT_TYPE_9, SUInt32);
  Registry.RegisterField(@fStats[9].Value, FIELD_ITM_STAT_VALUE_9, SUInt32);
  Registry.RegisterField(@fDamageTypes[0].DamageType, FIELD_ITM_DAMAGE_TYPE_0, SUInt32);
  Registry.RegisterField(@fDamageTypes[0].Min, FIELD_ITM_DAMAGE_MIN_0, SFloat);
  Registry.RegisterField(@fDamageTypes[0].Max, FIELD_ITM_DAMAGE_MAX_0, SFloat);
  Registry.RegisterField(@fDamageTypes[1].DamageType, FIELD_ITM_DAMAGE_TYPE_1, SUInt32);
  Registry.RegisterField(@fDamageTypes[1].Min, FIELD_ITM_DAMAGE_MIN_1, SFloat);
  Registry.RegisterField(@fDamageTypes[1].Max, FIELD_ITM_DAMAGE_MAX_1, SFloat);
  Registry.RegisterField(@fDamageTypes[2].DamageType, FIELD_ITM_DAMAGE_TYPE_2, SUInt32);
  Registry.RegisterField(@fDamageTypes[2].Min, FIELD_ITM_DAMAGE_MIN_2, SFloat);
  Registry.RegisterField(@fDamageTypes[2].Max, FIELD_ITM_DAMAGE_MAX_2, SFloat);
  Registry.RegisterField(@fDamageTypes[3].DamageType, FIELD_ITM_DAMAGE_TYPE_3, SUInt32);
  Registry.RegisterField(@fDamageTypes[3].Min, FIELD_ITM_DAMAGE_MIN_3, SFloat);
  Registry.RegisterField(@fDamageTypes[3].Max, FIELD_ITM_DAMAGE_MAX_3, SFloat);
  Registry.RegisterField(@fDamageTypes[4].DamageType, FIELD_ITM_DAMAGE_TYPE_4, SUInt32);
  Registry.RegisterField(@fDamageTypes[4].Min, FIELD_ITM_DAMAGE_MIN_4, SFloat);
  Registry.RegisterField(@fDamageTypes[4].Max, FIELD_ITM_DAMAGE_MAX_4, SFloat);
  Registry.RegisterField(@fResistancePhysical, FIELD_ITM_RESISTANCE_PHYSICAL, SUInt32);
  Registry.RegisterField(@fResistanceHoly, FIELD_ITM_RESISTANCE_HOLY, SUInt32);
  Registry.RegisterField(@fResistanceFire, FIELD_ITM_RESISTANCE_FIRE, SUInt32);
  Registry.RegisterField(@fResistanceNature, FIELD_ITM_RESISTANCE_NATURE, SUInt32);
  Registry.RegisterField(@fResistanceFrost, FIELD_ITM_RESISTANCE_FROST, SUInt32);
  Registry.RegisterField(@fResistanceShadow, FIELD_ITM_RESISTANCE_SHADOW, SUInt32);
  Registry.RegisterField(@fResistanceArcane, FIELD_ITM_RESISTANCE_ARCANE, SUInt32);
  Registry.RegisterField(@fDelay, FIELD_ITM_DELAY, SUInt32);
  Registry.RegisterField(@fAmmunitionType, FIELD_ITM_AMMO_TYPE, SUInt32);
  Registry.RegisterField(@fItemSpells[0].Id, FIELD_ITM_SPELL_ID_0, SUInt32);
  Registry.RegisterField(@fItemSpells[0].Trigger, FIELD_ITM_SPELL_TRIGGER_0, SUInt32);
  Registry.RegisterField(@fItemSpells[0].Charges, FIELD_ITM_SPELL_CHARGES_0, SUInt32);
  Registry.RegisterField(@fItemSpells[0].Cooldown, FIELD_ITM_SPELL_COOLDOWN_0, SUInt32);
  Registry.RegisterField(@fItemSpells[0].Category, FIELD_ITM_SPELL_CATEGORY_0, SUInt32);
  Registry.RegisterField(@fItemSpells[0].CategoryCooldown, FIELD_ITM_SPELL_CATEGORY_COOL_0, SUInt32);
  Registry.RegisterField(@fItemSpells[1].Id, FIELD_ITM_SPELL_ID_1, SUInt32);
  Registry.RegisterField(@fItemSpells[1].Trigger, FIELD_ITM_SPELL_TRIGGER_1, SUInt32);
  Registry.RegisterField(@fItemSpells[1].Charges, FIELD_ITM_SPELL_CHARGES_1, SUInt32);
  Registry.RegisterField(@fItemSpells[1].Cooldown, FIELD_ITM_SPELL_COOLDOWN_1, SUInt32);
  Registry.RegisterField(@fItemSpells[1].Category, FIELD_ITM_SPELL_CATEGORY_1, SUInt32);
  Registry.RegisterField(@fItemSpells[1].CategoryCooldown, FIELD_ITM_SPELL_CATEGORY_COOL_1, SUInt32);
  Registry.RegisterField(@fItemSpells[2].Id, FIELD_ITM_SPELL_ID_2, SUInt32);
  Registry.RegisterField(@fItemSpells[2].Trigger, FIELD_ITM_SPELL_TRIGGER_2, SUInt32);
  Registry.RegisterField(@fItemSpells[2].Charges, FIELD_ITM_SPELL_CHARGES_2, SUInt32);
  Registry.RegisterField(@fItemSpells[2].Cooldown, FIELD_ITM_SPELL_COOLDOWN_2, SUInt32);
  Registry.RegisterField(@fItemSpells[2].Category, FIELD_ITM_SPELL_CATEGORY_2, SUInt32);
  Registry.RegisterField(@fItemSpells[2].CategoryCooldown, FIELD_ITM_SPELL_CATEGORY_COOL_2, SUInt32);
  Registry.RegisterField(@fItemSpells[3].Id, FIELD_ITM_SPELL_ID_3, SUInt32);
  Registry.RegisterField(@fItemSpells[3].Trigger, FIELD_ITM_SPELL_TRIGGER_3, SUInt32);
  Registry.RegisterField(@fItemSpells[3].Charges, FIELD_ITM_SPELL_CHARGES_3, SUInt32);
  Registry.RegisterField(@fItemSpells[3].Cooldown, FIELD_ITM_SPELL_COOLDOWN_3, SUInt32);
  Registry.RegisterField(@fItemSpells[3].Category, FIELD_ITM_SPELL_CATEGORY_3, SUInt32);
  Registry.RegisterField(@fItemSpells[3].CategoryCooldown, FIELD_ITM_SPELL_CATEGORY_COOL_3, SUInt32);
  Registry.RegisterField(@fItemSpells[4].Id, FIELD_ITM_SPELL_ID_4, SUInt32);
  Registry.RegisterField(@fItemSpells[4].Trigger, FIELD_ITM_SPELL_TRIGGER_4, SUInt32);
  Registry.RegisterField(@fItemSpells[4].Charges, FIELD_ITM_SPELL_CHARGES_4, SUInt32);
  Registry.RegisterField(@fItemSpells[4].Cooldown, FIELD_ITM_SPELL_COOLDOWN_4, SUInt32);
  Registry.RegisterField(@fItemSpells[4].Category, FIELD_ITM_SPELL_CATEGORY_4, SUInt32);
  Registry.RegisterField(@fItemSpells[4].CategoryCooldown, FIELD_ITM_SPELL_CATEGORY_COOL_4, SUInt32);
  Registry.RegisterField(@fBonding, FIELD_ITM_BONDING, SUInt32);
  Registry.RegisterField(@fRangeModifier, FIELD_ITM_MOD_RANGE, SFloat);
  Registry.RegisterField(@fPageID, FIELD_ITM_PAGE_ID, SUInt32);
  Registry.RegisterField(@fPageLanguage, FIELD_ITM_PAGE_LANGUAGE, SUInt32);
  Registry.RegisterField(@fPageMaterial, FIELD_ITM_PAGE_MATERIAL, SUInt32);
  Registry.RegisterField(@fStartsQuest, FIELD_ITM_STARTS_QUEST, SUInt32);
  Registry.RegisterField(@fLockID, FIELD_ITM_LOCK_ID, SUInt32);
  Registry.RegisterField(@fLockMaterial, FIELD_ITM_LOCK_MATERIAL, SUInt32);
  Registry.RegisterField(@fSheath, FIELD_ITM_SHEATH, SUInt32);
  Registry.RegisterField(@fExtraInfo, FIELD_ITM_EXTRA_INFO, SUInt32);
  Registry.RegisterField(@fExtraInfo2, FIELD_ITM_RAND_PROPERTY, SUInt32);
  Registry.RegisterField(@fBlock, FIELD_ITM_BLOCK, SUInt32);
  Registry.RegisterField(@fItemSet, FIELD_ITM_ITEMSET, SUInt32);
  Registry.RegisterField(@fMaximumDurability, FIELD_ITM_MAX_DURABILITY, SUInt32);
  Registry.RegisterField(@fArea, FIELD_ITM_AREA, SUInt32);
  Registry.RegisterField(@fMapId, FIELD_ITM_MAP, SUInt32);
  Registry.RegisterField(@fBagFamily, FIELD_ITM_BAG_FAMILY, SUInt32);
  Registry.RegisterField(@fTotemCategory, FIELD_ITM_TOTEM_CATEGORY, SUInt32);
  Registry.RegisterField(@fSocketColor1, FIELD_ITM_SOCKET_COLOR_0, SUInt32);
  Registry.RegisterField(@fUnk2, FIELD_ITM_SOCKET_UNKNOWN_0, SUInt32);
  Registry.RegisterField(@fSocketColor2, FIELD_ITM_SOCKET_COLOR_1, SUInt32);
  Registry.RegisterField(@fUnk3, FIELD_ITM_SOCKET_UNKNOWN_1, SUInt32);
  Registry.RegisterField(@fSocketColor3, FIELD_ITM_SOCKET_COLOR_2, SUInt32);
  Registry.RegisterField(@fUnk4, FIELD_ITM_SOCKET_UNKNOWN_2, SUInt32);
  Registry.RegisterField(@fSocketBonus, FIELD_ITM_SOCKET_BONUS, SUInt32);
  Registry.RegisterField(@fGemProperties, FIELD_ITM_GEM_PROPERTIES, SUInt32);
  Registry.RegisterField(@fItemExtendedCost, FIELD_ITM_EXTENDED_COST, SUInt32);
  Registry.RegisterField(@fDisenchantReqSkill, FIELD_ITM_REQ_DISENCHANT_SKILL, SUInt32);
  
  Registry.RegisterField(@fName, FIELD_ITM_BASE_NAME, SString);
  Registry.RegisterField(@fNameForQuest, FIELD_ITM_QUEST_NAME, SString);
  Registry.RegisterField(@fNameHonorable, FIELD_ITM_PVP_NAME, SString);
  Registry.RegisterField(@fNameEnchanting, FIELD_ITM_PERSONALIZED_NAME, SString);
  Registry.RegisterField(@fDescription, FIELD_ITM_DESCRIPTION, SString);
end;

{ YDbPersistentTimerEntry }

procedure YDbPersistentTimerEntry.Assign(Entry: YDbSerializable);
var
  cTimer: YDbPersistentTimerEntry;
begin
  inherited Assign(Entry);
  if Entry is YDbPersistentTimerEntry then
  begin
    cTimer := Entry as YDbPersistentTimerEntry;
    TimeLeft := cTimer.TimeLeft;
    TimeTotal := cTimer.TimeTotal;
    ExecutionCount := cTimer.ExecutionCount;
    Disabled := cTimer.Disabled;
  end;
end;

end.
