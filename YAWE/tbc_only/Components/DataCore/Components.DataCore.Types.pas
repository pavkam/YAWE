{*------------------------------------------------------------------------------
  List of types and routines for the use with the DB-system.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.DataCore.Types;

interface

uses
  Math,
  Bfg.Utils,
  Bfg.Containers,
  SysUtils,
  Framework.Base,
  Components.GameCore.Constants,
  Components.DataCore.DynamicObjectFormat,
  Components.Shared,
  Components.GameCore.UpdateFields;

type
  ISerializable = interface(IInterface)
  ['{A32B47E4-47A5-4824-8296-81EC2DC26D86}']
    { private }
    function GetUniqueId: Longword; stdcall;
    procedure SetUniqueId(NewId: Longword); stdcall;
    function GetContext(Name: PAnsiChar): IDofStreamable; stdcall;
    procedure SetContext(Name: PAnsiChar; const Value: IDofStreamable); stdcall;
    function GetStorageContext: Pointer; stdcall;
    procedure SetStorageContext(Value: Pointer); stdcall;

    { public }
    procedure Initialize; stdcall;
    procedure Clear; stdcall;
    procedure Assign(const Entry: ISerializable); stdcall;

    property UniqueId: Longword read GetUniqueId write SetUniqueId;
    property Context[Name: PAnsiChar]: IDofStreamable read GetContext write SetContext;
    property StorageContext: Pointer read GetStorageContext write SetStorageContext;
  end;

  ISerializable2 = interface(ISerializable)
  ['{A32B47E4-47A5-4824-8778-81EC2DC26D86}']
    procedure AfterLoad; stdcall;
    procedure BeforeSave; stdcall;
  end;

  PSerializable = ^ISerializable;

  {$M+}
  YDbSerializable = class(TInterfacedObject, ISerializable, IDofStreamable)
    private
      FStorageContext: Pointer;
      
      procedure ReadContexts(const Reader: IDofReader);
      procedure WriteContexts(const Writer: IDofWriter);
    protected
      FContexts: TStrIntfHashMap;
      FId: Longword;

      function GetUniqueId: Longword; stdcall;
      procedure SetUniqueId(Id: Longword); stdcall;
      function GetContext(Name: PChar): IDofStreamable; stdcall;
      procedure SetContext(Name: PChar; const Value: IDofStreamable); stdcall;
      function GetStorageContext: Pointer; stdcall;
      procedure SetStorageContext(Value: Pointer); stdcall;

      procedure ReadCustomProperties(const Reader: IDofReader); virtual; stdcall;
      procedure WriteCustomProperties(const Writer: IDofWriter); virtual; stdcall;

      procedure Assign(const Entry: ISerializable); virtual; stdcall;
      procedure Initialize; virtual; stdcall;
      procedure Clear; virtual; stdcall;
    public
      destructor Destroy; override;
  end;
  {$M-}

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
    Name: AnsiString;
	  Map: UInt32;
	  X, Y, Z: float;
  end;

  YTPPlaces = array of YTPPlace;

  PStartingItemInfo = ^TStartingItemInfo;
  TStartingItemInfo = packed record
    EquipmentSlot: Longword;
    ItemId: Longword;
    ItemCount: Longword;
  end;

  PStartingSkillInfo = ^TStartingSkillInfo;
  TStartingSkillInfo = packed record
    SkillId: Longword;
    SkillInitial: Longword;
    SkillMax: Longword;
  end;

  PStartingSpellInfo = ^TStartingSpellInfo;
  TStartingSpellInfo = packed record
    SpellId: Longword;
  end;

  PStartingActionButtonInfo = ^TStartingActionButtonInfo;
  TStartingActionButtonInfo = packed record
    Action: Word;
    ButtonType: Byte;
    Misc: Byte;
  end;

  PDbPlayerTemplateData = ^TDbPlayerTemplateData;
  TDbPlayerTemplateData = packed record
    RaceStr: PAnsiChar;
    RaceStrLen: Integer;
    ClassStr: PAnsiChar;
    ClassStrLen: Integer;
    StartingMapId: Longword;
    StartingX: Float;
    StartingY: Float;
    StartingZ: Float;
    StartingAngle: Float;
    StartingStrength: Integer;
    StartingAgility: Integer;
    StartingStamina: Integer;
    StartingIntellect: Integer;
    StartingSpirit: Integer;
    ModelMale: Integer;
    ModelFemale: Integer;
    ModelSize: Float;
    HealthBase: Longword;
    PowerType: Longword;
    PowerBase: Longword;
    AttackTimeBase: array[0..1] of Longword;
    AttackDamageBase: array[0..1] of Longword;
    AttackPowerBase: Longword;
    StartingSpells: PStartingSpellInfo;
    StartingSpellCount: Integer;
    StartingItems: PStartingItemInfo;
    StartingItemCount: Integer;
    StartingSkills: PStartingSkillInfo;
    StartingSkillCount: Integer;
    StartingActionButtons: PStartingActionButtonInfo;
    StartingActionButtonCount: Integer;
  end;

  TStartingSpellInfoDynArray = array of TStartingSpellInfo;
  TStartingItemInfoDynArray = array of TStartingItemInfo;
  TStartingSkillInfoDynArray = array of TStartingSkillInfo;
  TStartingActionButtonInfoDynArray = array of TStartingActionButtonInfo;

  PDbPlayerTemplateDataN = ^TDbPlayerTemplateDataN;
  TDbPlayerTemplateDataN = packed record
    RaceStr: AnsiString;
    ClassStr: AnsiString;
    StartingMapId: Longword;
    StartingX: Float;
    StartingY: Float;
    StartingZ: Float;
    StartingAngle: Float;
    StartingStrength: Integer;
    StartingAgility: Integer;
    StartingStamina: Integer;
    StartingIntellect: Integer;
    StartingSpirit: Integer;
    ModelMale: Integer;
    ModelFemale: Integer;
    ModelSize: Float;
    HealthBase: Longword;
    PowerType: Longword;
    PowerBase: Longword;
    AttackTimeBase: array[0..1] of Longword;
    AttackDamageBase: array[0..1] of Longword;
    AttackPowerBase: Longword;
    StartingSpells: TStartingSpellInfoDynArray;
    StartingItems: TStartingItemInfoDynArray;
    StartingSkills: TStartingSkillInfoDynArray;
    StartingActionButtons: TStartingActionButtonInfoDynArray;
  end;

  IPlayerTemplateEntry = interface(ISerializable)
  ['{3786BD34-3D75-4B5F-B8DF-37B9A9F4AA30}']
    function GetRace: PAnsiChar; stdcall;
    function GetClass: PAnsiChar; stdcall;
    function GetRaceN: AnsiString;
    function GetClassN: AnsiString;
    function GetMapId: UInt32; stdcall;
    function GetZoneId: UInt32; stdcall;
    function GetStartingX: Float; stdcall;
    function GetStartingY: Float; stdcall;
    function GetStartingZ: Float; stdcall;
    function GetStartingAngle: Float; stdcall;
    function GetInitialStrength: UInt32; stdcall;
    function GetInitialAgility: UInt32; stdcall;
    function GetInitialStamina: UInt32; stdcall;
    function GetInitialIntellect: UInt32; stdcall;
    function GetInitialSpirit: UInt32; stdcall;
    function GetMaleBodyModel: UInt32; stdcall;
    function GetFemaleBodyModel: UInt32; stdcall;
    function GetBodySize: Float; stdcall;
    function GetPowerType: UInt32; stdcall;
    function GetBasePower: UInt32; stdcall;
    function GetBaseHealth: UInt32; stdcall;
    function GetPower: UInt32; stdcall;
    function GetAttackTimeLo: UInt32; stdcall;
    function GetAttackTimeHi: UInt32; stdcall;
    function GetAttackPower: UInt32; stdcall;
    function GetAttackDamageLo: UInt32; stdcall;
    function GetAttackDamageHi: UInt32; stdcall;

    procedure SetRace(Value: PAnsiChar); stdcall;
    procedure SetClass(Value: PAnsiChar); stdcall;
    procedure SetRaceN(const Value: AnsiString);
    procedure SetClassN(const Value: AnsiString);
    procedure SetMapId(Value: UInt32); stdcall;
    procedure SetZoneId(Value: UInt32); stdcall;
    procedure SetStartingX(Value: Float); stdcall;
    procedure SetStartingY(Value: Float); stdcall;
    procedure SetStartingZ(Value: Float); stdcall;
    procedure SetStartingAngle(Value: Float); stdcall;
    procedure SetInitialStrength(Value: UInt32); stdcall;
    procedure SetInitialAgility(Value: UInt32); stdcall;
    procedure SetInitialStamina(Value: UInt32); stdcall;
    procedure SetInitialIntellect(Value: UInt32); stdcall;
    procedure SetInitialSpirit(Value: UInt32); stdcall;
    procedure SetMaleBodyModel(Value: UInt32); stdcall;
    procedure SetFemaleBodyModel(Value: UInt32); stdcall;
    procedure SetBodySize(Value: Float); stdcall;
    procedure SetPowerType(Value: UInt32); stdcall;
    procedure SetBasePower(Value: UInt32); stdcall;
    procedure SetBaseHealth(Value: UInt32); stdcall;
    procedure SetPower(Value: UInt32); stdcall;
    procedure SetAttackTimeLo(Value: UInt32); stdcall;
    procedure SetAttackTimeHi(Value: UInt32); stdcall;
    procedure SetAttackPower(Value: UInt32); stdcall;
    procedure SetAttackDamageLo(Value: UInt32); stdcall;
    procedure SetAttackDamageHi(Value: UInt32); stdcall;

    procedure StoreEntryContents(var Data; Flags: Longword); stdcall;
    procedure LoadEntryContents(const Data; Flags: Longword); stdcall;

    property Race: AnsiString read GetRaceN write SetRaceN;
    property PlayerClass: AnsiString read GetClassN write SetClassN;
    property StartingX: Float read GetStartingX write SetStartingX;
    property StartingY: Float read GetStartingY write SetStartingY;
    property StartingZ: Float read GetStartingZ write SetStartingZ;
    property StartingAngle: Float read GetStartingAngle write SetStartingAngle;
    property Map: UInt32 read GetMapId write SetMapId;
    property Zone: UInt32 read GetZoneId write SetZoneId;
    property InitialStrength: UInt32 read GetInitialStrength write SetInitialStrength;
    property InitialAgility: UInt32 read GetInitialAgility write SetInitialAgility;
    property InitialStamina: UInt32 read GetInitialStamina write SetInitialStamina;
    property InitialIntellect: UInt32 read GetInitialIntellect write SetInitialIntellect;
    property InitialSpirit: UInt32 read GetInitialSpirit write SetInitialSpirit;
    property MaleBodyModel: UInt32 read GetMaleBodyModel write SetMaleBodyModel;
    property FemaleBodyModel: UInt32 read GetFemaleBodyModel write SetMaleBodyModel;
    property BodySize: Float read GetBodySize write SetBodySize;
    property PowerType: UInt32 read GetPowerType write SetPowerType;
    property BasePower: UInt32 read GetBasePower write SetBasePower;
    property BaseHealth: UInt32 read GetBaseHealth write SetBaseHealth;
    property AttackTimeLo: UInt32 read GetAttackTimeLo write SetAttackTimeLo;
    property AttackTimeHi: UInt32 read GetAttackTimeHi write SetAttackTimeHi;
    property AttackPower: UInt32 read GetAttackPower write SetAttackPower;
    property AttackDamageLo: UInt32 read GetAttackDamageLo write SetAttackDamageLo;
    property AttackDamageHi: UInt32 read GetAttackDamageHi write SetAttackDamageHi;
  end;

const
  DB_PLAYERTEMP_FLAG_NATIVE = $00000001;
  DB_PLAYERTEMP_FLAG_LOOKAT = $00000002;
  DB_PLAYERTEMP_FLAG_ONLYDYNAMIC = $00000004;

type
  {$M+}
  YDbPlayerTemplate = class(YDbSerializable, ISerializable, IPlayerTemplateEntry, ISerializable2)
    private
      FRace: AnsiString;
      FClass: AnsiString;
      FMapId: UInt32;
      FZoneId: UInt32;
      FX: Float;
      FY: Float;
      FZ: Float;
      FO: Float;
      FStrength: UInt32;
      FAgility: UInt32;
      FStamina: UInt32;
      FIntellect: UInt32;
      FSpirit: UInt32;
      FMaleBody: UInt32;
      FFemaleBody: UInt32;
      FBodySize: Float;
      FPowerType: UInt32;
      FBasePower: UInt32;
      FBaseHealth: UInt32;
      FPower: UInt32;

      FSkillStr: AnsiString;
      FSpellStr: AnsiString;
      FItemStr: AnsiString;
      FActionButtonStr: AnsiString;

      FSkills: TStartingSkillInfoDynArray;
      FSpells: TStartingSpellInfoDynArray;
      FItems: TStartingItemInfoDynArray;
      FActionButtons: TStartingActionButtonInfoDynArray;

      FAttackTimeLo: UInt32;
      FAttackTimeHi: UInt32;
      FAttackPower: UInt32;
      FAttackDamageHi: UInt32;
      FAttackDamageLo: UInt32;
    protected
      procedure Assign(const Entry: ISerializable); override;

      procedure AfterLoad; stdcall;
      procedure BeforeSave; stdcall;

      function GetRace: PAnsiChar; stdcall;
      function GetClass: PAnsiChar; stdcall;
      function GetRaceN: AnsiString;
      function GetClassN: AnsiString;
      function GetMapId: UInt32; stdcall;
      function GetZoneId: UInt32; stdcall;
      function GetStartingX: Float; stdcall;
      function GetStartingY: Float; stdcall;
      function GetStartingZ: Float; stdcall;
      function GetStartingAngle: Float; stdcall;
      function GetInitialStrength: UInt32; stdcall;
      function GetInitialAgility: UInt32; stdcall;
      function GetInitialStamina: UInt32; stdcall;
      function GetInitialIntellect: UInt32; stdcall;
      function GetInitialSpirit: UInt32; stdcall;
      function GetMaleBodyModel: UInt32; stdcall;
      function GetFemaleBodyModel: UInt32; stdcall;
      function GetBodySize: Float; stdcall;
      function GetPowerType: UInt32; stdcall;
      function GetBasePower: UInt32; stdcall;
      function GetBaseHealth: UInt32; stdcall;
      function GetPower: UInt32; stdcall;
      function GetAttackTimeLo: UInt32; stdcall;
      function GetAttackTimeHi: UInt32; stdcall;
      function GetAttackPower: UInt32; stdcall;
      function GetAttackDamageLo: UInt32; stdcall;
      function GetAttackDamageHi: UInt32; stdcall;

      procedure SetRace(Value: PAnsiChar); stdcall;
      procedure SetClass(Value: PAnsiChar); stdcall;
      procedure SetRaceN(const Value: AnsiString);
      procedure SetClassN(const Value: AnsiString);
      procedure SetMapId(Value: UInt32); stdcall;
      procedure SetZoneId(Value: UInt32); stdcall;
      procedure SetStartingX(Value: Float); stdcall;
      procedure SetStartingY(Value: Float); stdcall;
      procedure SetStartingZ(Value: Float); stdcall;
      procedure SetStartingAngle(Value: Float); stdcall;
      procedure SetInitialStrength(Value: UInt32); stdcall;
      procedure SetInitialAgility(Value: UInt32); stdcall;
      procedure SetInitialStamina(Value: UInt32); stdcall;
      procedure SetInitialIntellect(Value: UInt32); stdcall;
      procedure SetInitialSpirit(Value: UInt32); stdcall;
      procedure SetMaleBodyModel(Value: UInt32); stdcall;
      procedure SetFemaleBodyModel(Value: UInt32); stdcall;
      procedure SetBodySize(Value: Float); stdcall;
      procedure SetPowerType(Value: UInt32); stdcall;
      procedure SetBasePower(Value: UInt32); stdcall;
      procedure SetBaseHealth(Value: UInt32); stdcall;
      procedure SetPower(Value: UInt32); stdcall;
      procedure SetAttackTimeLo(Value: UInt32); stdcall;
      procedure SetAttackTimeHi(Value: UInt32); stdcall;
      procedure SetAttackPower(Value: UInt32); stdcall;
      procedure SetAttackDamageLo(Value: UInt32); stdcall;
      procedure SetAttackDamageHi(Value: UInt32); stdcall;

      procedure StoreEntryContents(var Data; Flags: Longword); stdcall;
      procedure LoadEntryContents(const Data; Flags: Longword); stdcall;
    published
      property Race: AnsiString read FRace write FRace;
      property PlayerClass: AnsiString read FClass write FClass;
      property StartingX: Float read FX write FX;
      property StartingY: Float read FY write FY;
      property StartingZ: Float read FZ write FZ;
      property StartingAngle: Float read FO write FO;
      property Map: UInt32 read FMapId write FMapId;
      property Zone: UInt32 read FZoneId write FZoneId;
      property InitialStrength: UInt32 read FStrength write FStrength;
      property InitialAgility: UInt32 read FAgility write FAgility;
      property InitialStamina: UInt32 read FStamina write FStamina;
      property InitialIntellect: UInt32 read FIntellect write FIntellect;
      property InitialSpirit: UInt32 read FSpirit write FSpirit;
      property MaleBodyModel: UInt32 read FMaleBody write FMaleBody;
      property FemaleBodyModel: UInt32 read FFemaleBody write FFemaleBody;
      property BodySize: Float read FBodySize write FBodySize;
      property PowerType: UInt32 read FPowerType write FPowerType;
      property BasePower: UInt32 read FBasePower write FBasePower;
      property BaseHealth: UInt32 read FBaseHealth write FBaseHealth;
      property Power: UInt32 read FPower write FPower;
      property SkillData: AnsiString read FSkillStr write FSkillStr;
      property Spells: AnsiString read FSpellStr write FSpellStr;
      property ItemData: AnsiString read FItemStr write FItemStr;
      property AttackTimeLo: UInt32 read FAttackTimeLo write FAttackTimeLo;
      property AttackTimeHi: UInt32 read FAttackTimeHi write FAttackTimeHi;
      property AttackPower: UInt32 read FAttackPower write FAttackPower;
      property AttackDamageLo: UInt32 read FAttackDamageLo write FAttackDamageLo;
      property AttackDamageHi: UInt32 read FAttackDamageHi write FAttackDamageHi;
      property ActionButtons: AnsiString read FActionButtonStr write FActionButtonStr;
  end;
  {$M-}

  {$IF ((SizeOf(YGameRaces) + SizeOf(YGameClasses)) mod SizeOf(UInt32)) <> 0}
    {$DEFINE ITEM_TEMPLATE_HAS_PAD}
  {$IFEND}

  PItemStatBonusInfo = ^TItemStatBonusInfo;
  TItemStatBonusInfo = packed record
    StatType: YStatBonusType;
    Value: Longword;
  end;

  PItemDamageTypeInfo = ^TItemDamageTypeInfo;
  TItemDamageTypeInfo = packed record
    Min: Float;
    Max: Float;
    DamageType: YDamageType;
  end;

  PItemDamageResistanceInfo = ^TItemDamageResistanceInfo;
  TItemDamageResistanceInfo = packed record
    Amount: Longword;
  end;

  PItemSpellInfo = ^TItemSpellInfo;
  TItemSpellInfo = packed record
    SpellId: Longword;
    Trigger: Longword;
    Charges: Longword;
    Cooldown: Longword;
    Category: Longword;
    CategoryCooldown: Longword;
  end;

  PItemGemSocketInfo = ^TItemGemSocketInfo;
  TItemGemSocketInfo = packed record
    SocketColors: Longword;
  end;

  PDbItemTemplateData = ^TDbItemTemplateData;
  TDbItemTemplateData = packed record
    Name: PWideChar;
    NameLen: Integer;
    MainClass: YItemClass;
    SubClass: Longword;
    ModelId: Longword;
    Quality: Longword;
    Flags: Longword;
    BuyPrice: Longword;
    SellPrice: Longword;
    ExtendedPrice: Longword;
    InvantoryType: YItemInventoryType;
    AllowedRaces: YGameRaces;
    AllowedClass: YGameClasses;
    Unique: Boolean;
    ItemLevel: Longword;
    RequiredLevel: Longword;
    RequiredSkillId: Longword;
    RequiredSkillIdRank: Longword;
    RequiredSpell: Longword;
    RequiredFaction: Longword;
    RequiredFactionStanding: Longword;
    RequiredPvPRank1: Longword;
    RequiredPvPRank2: Longword;
    RequiredDisenchantSkill: Longword;
    MaximumCount: Longword;
    ContainerSlotCount: Longword;
    Stats: array[0..9] of TItemStatBonusInfo;
    Damage: array[0..4] of TItemDamageTypeInfo;
    Resistances: array[0..6] of TItemDamageResistanceInfo;
    AttackDelay: Longword;
    AmmunitionType: Longword;
    AttackRange: Float;
    Spells: array[0..5] of TItemSpellInfo;
    BondingType: Longword;
    PageId: Longword;
    PageLanguage: Longword;
    PageMaterial: Longword;
    StartsQuest: Longword;
    LockId: Longword;
    LockMaterial: Longword;
    Sheath: Longword;
    RandomProperties: Longword;
    RandomPropertiesEx: Longword;
    BlockAmount: Longword;
    ItemSetId: Longword;
    MaximumDurability: Longword;
    UseableInZone: Longword;
    UseableInMap: Longword;
    BagType: Longword;
    ToolType: Longword;
    GemSockets: array[0..2] of TItemGemSocketInfo;
    GemSocketBouns: Longword;
    GemProperties: Longword;
    Description: PWideChar;
    DescriptionLen: Integer;
  end;

  PDbItemTemplateDataN = ^TDbItemTemplateDataN;
  TDbItemTemplateDataN = packed record
    Name: WideString;
    MainClass: YItemClass;
    SubClass: Longword;
    ModelId: Longword;
    Quality: Longword;
    Flags: Longword;
    BuyPrice: Longword;
    SellPrice: Longword;
    ExtendedPrice: Longword;
    InvantoryType: YItemInventoryType;
    AllowedRaces: YGameRaces;
    AllowedClass: YGameClasses;
    Unique: Boolean;
    ItemLevel: Longword;
    RequiredLevel: Longword;
    RequiredSkillId: Longword;
    RequiredSkillIdRank: Longword;
    RequiredSpell: Longword;
    RequiredFaction: Longword;
    RequiredFactionStanding: Longword;
    RequiredPvPRank1: Longword;
    RequiredPvPRank2: Longword;
    RequiredDisenchantSkill: Longword;
    MaximumCount: Longword;
    ContainerSlotCount: Longword;
    Stats: array[0..9] of TItemStatBonusInfo;
    Damage: array[0..4] of TItemDamageTypeInfo;
    Resistances: array[0..6] of TItemDamageResistanceInfo;
    AttackDelay: Longword;
    AmmunitionType: Longword;
    AttackRange: Float;
    Spells: array[0..5] of TItemSpellInfo;
    BondingType: Longword;
    PageId: Longword;
    PageLanguage: Longword;
    PageMaterial: Longword;
    StartsQuest: Longword;
    LockId: Longword;
    LockMaterial: Longword;
    Sheath: Longword;
    RandomProperties: Longword;
    RandomPropertiesEx: Longword;
    BlockAmount: Longword;
    ItemSetId: Longword;
    MaximumDurability: Longword;
    UseableInZone: Longword;
    UseableInMap: Longword;
    BagType: Longword;
    ToolType: Longword;
    GemSockets: array[0..2] of TItemGemSocketInfo;
    GemSocketBouns: Longword;
    GemProperties: Longword;
    Description: WideString;
  end;

  IItemTemplateEntry = interface(ISerializable)
  ['{D2BC1C93-EFB5-4967-BBBF-13EB26E95A77}']
    function GetMainClass: YItemClass; stdcall;
    function GetSubClass: UInt32; stdcall;
    function GetModelId: UInt32; stdcall;
    function GetQuality: YItemQuality; stdcall;
    function GetFlags: UInt32; stdcall;
    function GetBuyPrice: UInt32; stdcall;
    function GetSellPrice: UInt32; stdcall;
    function GetInventoryType: YItemInventoryType; stdcall;
    function GetAllowedRaces: YGameRaces; stdcall;
    function GetAllowedClasses: YGameClasses; stdcall;
    function GetItemLevel: UInt32; stdcall;
    function GetReqLevel: UInt32; stdcall;
    function GetReqSkill: UInt32; stdcall;
    function GetReqSkillRank: UInt32; stdcall;
    function GetReqSpell: UInt32; stdcall;
    function GetReqFaction: UInt32; stdcall;
    function GetReqFactionLevel: UInt32; stdcall;
    function GetReqPVPRank1: UInt32; stdcall;
    function GetReqPVPRank2: UInt32; stdcall;
    function GetMaximumCount: UInt32; stdcall;
    function GetUniqueFlag: UInt32; stdcall;
    function GetContainerSlots: UInt32; stdcall;
    function GetResistancePhysical: UInt32; stdcall;
    function GetResistanceHoly: UInt32; stdcall;
    function GetResistanceFire: UInt32; stdcall;
    function GetResistanceNature: UInt32; stdcall;
    function GetResistanceFrost: UInt32; stdcall;
    function GetResistanceShadow: UInt32; stdcall;
    function GetResistanceArcane: UInt32; stdcall;
    function GetDelay: UInt32; stdcall;
    function GetAmunitionType: UInt32; stdcall;
    function GetBonding: UInt32; stdcall;
    function GetRangedModifier: Float; stdcall;
    function GetPageID: UInt32; stdcall;
    function GetPageLanguage: UInt32; stdcall;
    function GetPageMaterial: UInt32; stdcall;
    function GetStartsQuest: UInt32; stdcall;
    function GetLockID: UInt32; stdcall;
    function GetLockMaterial: UInt32; stdcall;
    function GetSheath: UInt32; stdcall;
    function GetExtraInfo: UInt32; stdcall;
    function GetExtraInfoAdvanced: UInt32; stdcall;
    function GetBlock: UInt32; stdcall;
    function GetItemSet: UInt32; stdcall;
    function GetMaximumDurability: UInt32; stdcall;
    function GetArea: UInt32; stdcall;
    function GetName: PWideChar; stdcall;
    function GetNameForQuest: PWideChar; stdcall;
    function GetNameHonorable: PWideChar; stdcall;
    function GetNameEnchanting: PWideChar; stdcall;
    function GetDescription: PWideChar; stdcall;
    function GetNameN: WideString;
    function GetNameForQuestN: WideString;
    function GetNameHonorableN: WideString;
    function GetNameEnchantingN: WideString;
    function GetDescriptionN: WideString;
    function GetMapId: UInt32; stdcall;
    function GetBagFamily: UInt32; stdcall;
    function GetTotemCategory: UInt32; stdcall;
    function GetSocketColor1: UInt32; stdcall;
    function GetSocketUnk1: UInt32; stdcall;
    function GetSocketColor2: UInt32; stdcall;
    function GetSocketUnk2: UInt32; stdcall;
    function GetSocketColor3: UInt32; stdcall;
    function GetSocketUnk3: UInt32; stdcall;
    function GetSocketBonus: UInt32; stdcall;
    function GetGemProperties: UInt32; stdcall;
    function GetItemExtendedCost: UInt32; stdcall;
    function GetDisenchantReqSkill: UInt32; stdcall;

    procedure SetMainClass(Value: YItemClass); stdcall;
    procedure SetSubClass(Value: UInt32); stdcall;
    procedure SetModelId(Value: UInt32); stdcall;
    procedure SetQuality(Value: YItemQuality); stdcall;
    procedure SetFlags(Value: UInt32); stdcall;
    procedure SetBuyPrice(Value: UInt32); stdcall;
    procedure SetSellPrice(Value: UInt32); stdcall;
    procedure SetInventoryType(Value: YItemInventoryType); stdcall;
    procedure SetAllowedRaces(Value: YGameRaces); stdcall;
    procedure SetAllowedClasses(Value: YGameClasses); stdcall;
    procedure SetItemLevel(Value: UInt32); stdcall;
    procedure SetReqLevel(Value: UInt32); stdcall;
    procedure SetReqSkill(Value: UInt32); stdcall;
    procedure SetReqSkillRank(Value: UInt32); stdcall;
    procedure SetReqSpell(Value: UInt32); stdcall;
    procedure SetReqFaction(Value: UInt32); stdcall;
    procedure SetReqFactionLevel(Value: UInt32); stdcall;
    procedure SetReqPVPRank1(Value: UInt32); stdcall;
    procedure SetReqPVPRank2(Value: UInt32); stdcall;
    procedure SetMaximumCount(Value: UInt32); stdcall;
    procedure SetUniqueFlag(Value: UInt32); stdcall;
    procedure SetContainerSlots(Value: UInt32); stdcall;
    procedure SetResistancePhysical(Value: UInt32); stdcall;
    procedure SetResistanceHoly(Value: UInt32); stdcall;
    procedure SetResistanceFire(Value: UInt32); stdcall;
    procedure SetResistanceNature(Value: UInt32); stdcall;
    procedure SetResistanceFrost(Value: UInt32); stdcall;
    procedure SetResistanceShadow(Value: UInt32); stdcall;
    procedure SetResistanceArcane(Value: UInt32); stdcall;
    procedure SetDelay(Value: UInt32); stdcall;
    procedure SetAmunitionType(Value: UInt32); stdcall;
    procedure SetBonding(Value: UInt32); stdcall;
    procedure SetRangedModifier(Value: Float); stdcall;
    procedure SetPageID(Value: UInt32); stdcall;
    procedure SetPageLanguage(Value: UInt32); stdcall;
    procedure SetPageMaterial(Value: UInt32); stdcall;
    procedure SetStartsQuest(Value: UInt32); stdcall;
    procedure SetLockID(Value: UInt32); stdcall;
    procedure SetLockMaterial(Value: UInt32); stdcall;
    procedure SetSheath(Value: UInt32); stdcall;
    procedure SetExtraInfo(Value: UInt32); stdcall;
    procedure SetExtraInfoAdvanced(Value: UInt32); stdcall;
    procedure SetBlock(Value: UInt32); stdcall;
    procedure SetItemSet(Value: UInt32); stdcall;
    procedure SetMaximumDurability(Value: UInt32); stdcall;
    procedure SetArea(Value: UInt32); stdcall;
    procedure SetName(Value: PWideChar); stdcall;
    procedure SetNameForQuest(Value: PWideChar); stdcall;
    procedure SetNameHonorable(Value: PWideChar); stdcall;
    procedure SetNameEnchanting(Value: PWideChar); stdcall;
    procedure SetDescription(Value: PWideChar); stdcall;
    procedure SetNameN(const Value: WideString);
    procedure SetNameForQuestN(const Value: WideString);
    procedure SetNameHonorableN(const Value: WideString);
    procedure SetNameEnchantingN(const Value: WideString);
    procedure SetDescriptionN(const Value: WideString);
    procedure SetMapId(Value: UInt32); stdcall;
    procedure SetBagFamily(Value: UInt32); stdcall;
    procedure SetTotemCategory(Value: UInt32); stdcall;
    procedure SetSocketColor1(Value: UInt32); stdcall;
    procedure SetSocketUnk1(Value: UInt32); stdcall;
    procedure SetSocketColor2(Value: UInt32); stdcall;
    procedure SetSocketUnk2(Value: UInt32); stdcall;
    procedure SetSocketColor3(Value: UInt32); stdcall;
    procedure SetSocketUnk3(Value: UInt32); stdcall;
    procedure SetSocketBonus(Value: UInt32); stdcall;
    procedure SetGemProperties(Value: UInt32); stdcall;
    procedure SetItemExtendedCost(Value: UInt32); stdcall;
    procedure SetDisenchantReqSkill(Value: UInt32); stdcall;

    function GetInfoBufferRequiredSize: Int32; stdcall;
    procedure FillInfoBuffer(Buffer: Pointer); stdcall;

    procedure StoreEntryContents(var Data; Flags: Longword); stdcall;
    procedure LoadEntryContents(const Data; Flags: Longword); stdcall;

    property MainClass: YItemClass read GetMainClass write SetMainClass;
    property SubClass: UInt32 read GetSubClass write SetSubClass;
    property ModelId: UInt32 read GetModelId write SetModelId;
    property Quality: YItemQuality read GetQuality write SetQuality;
    property Flags: UInt32 read GetFlags write SetFlags;
    property BuyPrice: UInt32 read GetBuyPrice write SetBuyPrice;
    property SellPrice: UInt32 read GetSellPrice write SetSellPrice;
    property InventoryType: YItemInventoryType read GetInventoryType write SetInventoryType;
    property AllowedRaces: YGameRaces read GetAllowedRaces write SetAllowedRaces;
    property AllowedClasses: YGameClasses read GetAllowedClasses write SetAllowedClasses;
    property ItemLevel: UInt32 read GetItemLevel write SetItemLevel;
    property ReqLevel: UInt32 read GetReqLevel write SetReqLevel;
    property ReqSkill: UInt32 read GetReqSkill write SetReqSkill;
    property ReqSkillRank: UInt32 read GetReqSkillRank write SetReqSkillRank;
    property ReqSpell: UInt32 read GetReqSpell write SetReqSpell;
    property ReqFaction: UInt32 read GetReqFaction write SetReqFaction;
    property ReqFactionLevel: UInt32 read GetReqFactionLevel write SetReqFactionLevel;
    property ReqPVPRank1: UInt32 read GetReqPVPRank1 write SetReqPVPRank1;
    property ReqPVPRank2: UInt32 read GetReqPvpRank2 write SetReqPvpRank2;
    property MaximumCount: UInt32 read GetMaximumCount write SetMaximumCount;
    property UniqueFlag: UInt32 read GetUniqueFlag write SetUniqueFlag;
    property ContainerSlots: UInt32 read GetContainerSlots write SetContainerSlots;
    property ResistancePhysical: UInt32 read GetResistancePhysical write SetResistancePhysical;
    property ResistanceHoly: UInt32 read GetResistanceHoly write SetResistanceHoly;
    property ResistanceFire: UInt32 read GetResistanceFire write SetResistanceFire;
    property ResistanceNature: UInt32 read GetResistanceNature write SetResistanceNature;
    property ResistanceFrost: UInt32 read GetResistanceFrost write SetResistanceFrost;
    property ResistanceShadow: UInt32 read GetResistanceShadow write SetResistanceShadow;
    property ResistanceArcane: UInt32 read GetResistanceArcane write SetResistanceArcane;
    property Delay: UInt32 read GetDelay write SetDelay;
    property AmunitionType: UInt32 read GetAmunitionType write SetAmunitionType;
    property Bonding: UInt32 read GetBonding write SetBonding;
    property RangedModifier: Float read GetRangedModifier write SetRangedModifier;
    property PageID: UInt32 read GetPageID write SetPageID;
    property PageLanguage: UInt32 read GetPageLanguage write SetPageLanguage;
    property PageMaterial: UInt32 read GetPageMaterial write SetPageMaterial;
    property StartsQuest: UInt32 read GetStartsQuest write SetStartsQuest;
    property LockID: UInt32 read GetLockID write SetLockID;
    property LockMaterial: UInt32 read GetLockMaterial write SetLockMaterial;
    property Sheath: UInt32 read GetSheath write SetSheath;
    property ExtraInfo: UInt32 read GetExtraInfo write SetExtraInfo;
    property ExtraInfoAdvanced: UInt32 read GetExtraInfoAdvanced write SetExtraInfoAdvanced;
    property Block: UInt32 read GetBlock write SetBlock;
    property ItemSet: UInt32 read GetItemSet write SetItemSet;
    property MaximumDurability: UInt32 read GetMaximumDurability write SetMaximumDurability;
    property Area: UInt32 read GetArea write SetArea;
    property Name: WideString read GetNameN write SetNameN;
    property NameForQuest: WideString read GetNameForQuestN write SetNameForQuestN;
    property NameHonorable: WideString read GetNameHonorableN write SetNameHonorableN;
    property NameEnchanting: WideString read GetNameEnchantingN write SetNameEnchantingN;
    property Description: WideString read GetDescriptionN write SetDescriptionN;
    property MapId: UInt32 read GetMapId write SetMapId;
    property BagFamily: UInt32 read GetBagFamily write SetBagFamily;
    property TotemCategory: UInt32 read GetTotemCategory write SetTotemCategory;
    property SocketColor1: UInt32 read GetSocketColor1 write SetSocketColor1;
    property SocketUnk1: UInt32 read GetSocketUnk1 write SetSocketUnk1;
    property SocketColor2: UInt32 read GetSocketColor2 write SetSocketColor2;
    property SocketUnk2: UInt32 read GetSocketUnk2 write SetSocketUnk2;
    property SocketColor3: UInt32 read GetSocketColor3 write SetSocketColor3;
    property SocketUnk3: UInt32 read GetSocketUnk3 write SetSocketUnk3;
    property SocketBonus: UInt32 read GetSocketBonus write SetSocketBonus;
    property GemProperties: UInt32 read GetGemProperties write SetGemProperties;
    property ItemExtendedCost: UInt32 read GetItemExtendedCost write SetItemExtendedCost;
    property DisenchantReqSkill: UInt32 read GetDisenchantReqSkill write SetDisenchantReqSkill;
  end;

  {$M+}
  YDbItemTemplate = class(YDbSerializable, ISerializable, ISerializable2, IItemTemplateEntry)
    private
      FClass: YItemClass;
      FSubClass: UInt32;
      FModelId: UInt32;
      FQuality: YItemQuality;
      FFlags: UInt32;
      FBuyPrice: UInt32;
      FSellPrice: UInt32;
      FInventoryType: YItemInventoryType;
      FAllowedRaces: YGameRaces;
      FAllowedClasses: YGameClasses;
      {$IFDEF ITEM_TEMPLATE_HAS_PAD}
      { Do not remove, here for alignment! }
      { It looks scary I know. But all it does is automaticly calculating the number of fill-bytes. }
      FPad1: array[0..SizeOf(UInt32)-((SizeOf(YGameRaces) + SizeOf(YGameClasses)) mod SizeOf(UInt32))-1] of UInt8;
      {$ENDIF}
      FItemLevel: UInt32;
      FReqLevel: UInt32;
      FReqSkill: UInt32;
      FReqSkillRank: UInt32;
      FReqSpell: UInt32;
      FReqFaction: UInt32;
      FReqFactionStanding: UInt32;
      FReqPVPRank1: UInt32;
      FReqPVPRank2: UInt32;
      FUniqueFlag: UInt32;
      FMaximumCount: UInt32;   //the max number of items of this type that a char can have
      FContainerSlots: UInt32;
      FStats: array[0..9] of TItemStatBonusInfo;
      FDamageTypes: array[0..4] of TItemDamageTypeInfo;
      FResistancePhysical: UInt32;
      FResistanceHoly: UInt32;
      FResistanceFire: UInt32;
      FResistanceNature: UInt32;
      FResistanceFrost: UInt32;
      FResistanceShadow: UInt32;
      FResistanceArcane: UInt32;
      FDelay: UInt32;
      FAmmunitionType: UInt32;  //2 = arrows, 3 = bullets
      FRange: Float;
      FItemSpells: array[0..__ITEM_FIELD_SPELL_CHARGES - 1] of TItemSpellInfo;
      FBonding: UInt32;
      FPageID: UInt32;
      FPageLanguage: UInt32;
      FPageMaterial: UInt32;
      FStartsQuest: UInt32;
      FLockID: UInt32;
      FLockMaterial: UInt32;
      FSheath: UInt32;
      FExtraInfo: UInt32;
      FExtraInfo2: UInt32;
      FBlock: UInt32;
      FItemSet: UInt32;
      FMaximumDurability: UInt32;
      FArea: UInt32;
      FMapId: UInt32;
      FBagType: UInt32;
      FToolCategory: UInt32;
      FSocketColor1: UInt32;
      FUnk2: UInt32;
      FSocketColor2: UInt32;
      FUnk3: UInt32;
      FSocketColor3: UInt32;
      FUnk4: UInt32;
      FSocketBonus: UInt32;
      FGemProperties: UInt32;
      FItemExtendedCost: UInt32;
      FDisenchantReqSkill: UInt32;
      FName: WideString;
      FNameForQuest: WideString;
      FNameHonorable: WideString;
      FNameEnchanting: WideString;
      FDescription: WideString;
      FNameUTF8: AnsiString;
      FNameForQuestUTF8: AnsiString;
      FNameHonorableUTF8: AnsiString;
      FNameEnchantingUTF8: AnsiString;
      FDescriptionUTF8: AnsiString;
      FUnknown206: UInt32; //2.0.6 TODO SELBY - check it later
    protected
      procedure Assign(const Entry: ISerializable); override;
      
      procedure AfterLoad; stdcall;
      procedure BeforeSave; stdcall;

      procedure StoreEntryContents(var Data; Flags: Longword); stdcall;
      procedure LoadEntryContents(const Data; Flags: Longword); stdcall;

      function GetMainClass: YItemClass; stdcall;
      function GetSubClass: UInt32; stdcall;
      function GetModelId: UInt32; stdcall;
      function GetQuality: YItemQuality; stdcall;
      function GetFlags: UInt32; stdcall;
      function GetBuyPrice: UInt32; stdcall;
      function GetSellPrice: UInt32; stdcall;
      function GetInventoryType: YItemInventoryType; stdcall;
      function GetAllowedRaces: YGameRaces; stdcall;
      function GetAllowedClasses: YGameClasses; stdcall;
      function GetItemLevel: UInt32; stdcall;
      function GetReqLevel: UInt32; stdcall;
      function GetReqSkill: UInt32; stdcall;
      function GetReqSkillRank: UInt32; stdcall;
      function GetReqSpell: UInt32; stdcall;
      function GetReqFaction: UInt32; stdcall;
      function GetReqFactionLevel: UInt32; stdcall;
      function GetReqPVPRank1: UInt32; stdcall;
      function GetReqPVPRank2: UInt32; stdcall;
      function GetMaximumCount: UInt32; stdcall;
      function GetUniqueFlag: UInt32; stdcall;
      function GetContainerSlots: UInt32; stdcall;
      function GetResistancePhysical: UInt32; stdcall;
      function GetResistanceHoly: UInt32; stdcall;
      function GetResistanceFire: UInt32; stdcall;
      function GetResistanceNature: UInt32; stdcall;
      function GetResistanceFrost: UInt32; stdcall;
      function GetResistanceShadow: UInt32; stdcall;
      function GetResistanceArcane: UInt32; stdcall;
      function GetDelay: UInt32; stdcall;
      function GetAmunitionType: UInt32; stdcall;
      function GetBonding: UInt32; stdcall;
      function GetRangedModifier: Float; stdcall;
      function GetPageID: UInt32; stdcall;
      function GetPageLanguage: UInt32; stdcall;
      function GetPageMaterial: UInt32; stdcall;
      function GetStartsQuest: UInt32; stdcall;
      function GetLockID: UInt32; stdcall;
      function GetLockMaterial: UInt32; stdcall;
      function GetSheath: UInt32; stdcall;
      function GetExtraInfo: UInt32; stdcall;
      function GetExtraInfoAdvanced: UInt32; stdcall;
      function GetBlock: UInt32; stdcall;
      function GetItemSet: UInt32; stdcall;
      function GetMaximumDurability: UInt32; stdcall;
      function GetArea: UInt32; stdcall;
      function GetName: PWideChar; stdcall;
      function GetNameForQuest: PWideChar; stdcall;
      function GetNameHonorable: PWideChar; stdcall;
      function GetNameEnchanting: PWideChar; stdcall;
      function GetDescription: PWideChar; stdcall;
      function GetNameN: WideString;
      function GetNameForQuestN: WideString;
      function GetNameHonorableN: WideString;
      function GetNameEnchantingN: WideString;
      function GetDescriptionN: WideString;
      function GetMapId: UInt32; stdcall;
      function GetBagFamily: UInt32; stdcall;
      function GetTotemCategory: UInt32; stdcall;
      function GetSocketColor1: UInt32; stdcall;
      function GetSocketUnk1: UInt32; stdcall;
      function GetSocketColor2: UInt32; stdcall;
      function GetSocketUnk2: UInt32; stdcall;
      function GetSocketColor3: UInt32; stdcall;
      function GetSocketUnk3: UInt32; stdcall;
      function GetSocketBonus: UInt32; stdcall;
      function GetGemProperties: UInt32; stdcall;
      function GetItemExtendedCost: UInt32; stdcall;
      function GetDisenchantReqSkill: UInt32; stdcall;

      procedure SetMainClass(Value: YItemClass); stdcall;
      procedure SetSubClass(Value: UInt32); stdcall;
      procedure SetModelId(Value: UInt32); stdcall;
      procedure SetQuality(Value: YItemQuality); stdcall;
      procedure SetFlags(Value: UInt32); stdcall;
      procedure SetBuyPrice(Value: UInt32); stdcall;
      procedure SetSellPrice(Value: UInt32); stdcall;
      procedure SetInventoryType(Value: YItemInventoryType); stdcall;
      procedure SetAllowedRaces(Value: YGameRaces); stdcall;
      procedure SetAllowedClasses(Value: YGameClasses); stdcall;
      procedure SetItemLevel(Value: UInt32); stdcall;
      procedure SetReqLevel(Value: UInt32); stdcall;
      procedure SetReqSkill(Value: UInt32); stdcall;
      procedure SetReqSkillRank(Value: UInt32); stdcall;
      procedure SetReqSpell(Value: UInt32); stdcall;
      procedure SetReqFaction(Value: UInt32); stdcall;
      procedure SetReqFactionLevel(Value: UInt32); stdcall;
      procedure SetReqPVPRank1(Value: UInt32); stdcall;
      procedure SetReqPVPRank2(Value: UInt32); stdcall;
      procedure SetMaximumCount(Value: UInt32); stdcall;
      procedure SetUniqueFlag(Value: UInt32); stdcall;
      procedure SetContainerSlots(Value: UInt32); stdcall;
      procedure SetResistancePhysical(Value: UInt32); stdcall;
      procedure SetResistanceHoly(Value: UInt32); stdcall;
      procedure SetResistanceFire(Value: UInt32); stdcall;
      procedure SetResistanceNature(Value: UInt32); stdcall;
      procedure SetResistanceFrost(Value: UInt32); stdcall;
      procedure SetResistanceShadow(Value: UInt32); stdcall;
      procedure SetResistanceArcane(Value: UInt32); stdcall;
      procedure SetDelay(Value: UInt32); stdcall;
      procedure SetAmunitionType(Value: UInt32); stdcall;
      procedure SetBonding(Value: UInt32); stdcall;
      procedure SetRangedModifier(Value: Float); stdcall;
      procedure SetPageID(Value: UInt32); stdcall;
      procedure SetPageLanguage(Value: UInt32); stdcall;
      procedure SetPageMaterial(Value: UInt32); stdcall;
      procedure SetStartsQuest(Value: UInt32); stdcall;
      procedure SetLockID(Value: UInt32); stdcall;
      procedure SetLockMaterial(Value: UInt32); stdcall;
      procedure SetSheath(Value: UInt32); stdcall;
      procedure SetExtraInfo(Value: UInt32); stdcall;
      procedure SetExtraInfoAdvanced(Value: UInt32); stdcall;
      procedure SetBlock(Value: UInt32); stdcall;
      procedure SetItemSet(Value: UInt32); stdcall;
      procedure SetMaximumDurability(Value: UInt32); stdcall;
      procedure SetArea(Value: UInt32); stdcall;
      procedure SetName(Value: PWideChar); stdcall;
      procedure SetNameForQuest(Value: PWideChar); stdcall;
      procedure SetNameHonorable(Value: PWideChar); stdcall;
      procedure SetNameEnchanting(Value: PWideChar); stdcall;
      procedure SetDescription(Value: PWideChar); stdcall;
      procedure SetNameN(const Value: WideString);
      procedure SetNameForQuestN(const Value: WideString);
      procedure SetNameHonorableN(const Value: WideString);
      procedure SetNameEnchantingN(const Value: WideString);
      procedure SetDescriptionN(const Value: WideString);
      procedure SetMapId(Value: UInt32); stdcall;
      procedure SetBagFamily(Value: UInt32); stdcall;
      procedure SetTotemCategory(Value: UInt32); stdcall;
      procedure SetSocketColor1(Value: UInt32); stdcall;
      procedure SetSocketUnk1(Value: UInt32); stdcall;
      procedure SetSocketColor2(Value: UInt32); stdcall;
      procedure SetSocketUnk2(Value: UInt32); stdcall;
      procedure SetSocketColor3(Value: UInt32); stdcall;
      procedure SetSocketUnk3(Value: UInt32); stdcall;
      procedure SetSocketBonus(Value: UInt32); stdcall;
      procedure SetGemProperties(Value: UInt32); stdcall;
      procedure SetItemExtendedCost(Value: UInt32); stdcall;
      procedure SetDisenchantReqSkill(Value: UInt32); stdcall;

      function GetInfoBufferRequiredSize: Int32; stdcall;
      procedure FillInfoBuffer(Buffer: Pointer); stdcall;
    published
      property MainClass: YItemClass read FClass write FClass;
      property SubClass: UInt32 read FSubClass write FSubClass;
      property ModelId: UInt32 read FModelId write FModelId;
      property Quality: YItemQuality read FQuality write FQuality;
      property Flags: UInt32 read FFlags write FFlags;
      property BuyPrice: UInt32 read FBuyPrice write FBuyPrice;
      property SellPrice: UInt32 read FSellPrice write FSellPrice;
      property InventoryType: YItemInventoryType read FInventoryType write FInventoryType;
      property AllowedRaces: YGameRaces read FAllowedRaces write FAllowedRaces;
      property AllowedClasses: YGameClasses read FAllowedClasses write FAllowedClasses;
      property ItemLevel: UInt32 read FItemLevel write FItemLevel;
      property ReqLevel: UInt32 read FReqLevel write FReqLevel;
      property ReqSkill: UInt32 read FReqSkill write FReqSkill;
      property ReqSkillRank: UInt32 read FReqSkillRank write FReqSkillRank;
      property ReqSpell: UInt32 read FReqSpell write FReqSpell;
      property ReqFaction: UInt32 read FReqFaction write FReqFaction;
      property ReqFactionLevel: UInt32 read FReqFactionStanding write FReqFactionStanding;
      property ReqPVPRank1: UInt32 read FReqPVPRank1 write FReqPVPRank1;
      property ReqPVPRank2: UInt32 read FReqPVPRank2 write FReqPVPRank2;
      property MaximumCount: UInt32 read FMaximumCount write FMaximumCount;
      property UniqueFlag: UInt32 read FUniqueFlag write FUniqueFlag;
      property ContainerSlots: UInt32 read FContainerSlots write FContainerSlots;
      property ResistancePhysical: UInt32 read FResistancePhysical write FResistancePhysical;
      property ResistanceHoly: UInt32 read FResistanceHoly write FResistanceHoly;
      property ResistanceFire: UInt32 read FResistanceFire write FResistanceFire;
      property ResistanceNature: UInt32 read FResistanceNature write FResistanceNature;
      property ResistanceFrost: UInt32 read FResistanceFrost write FResistanceFrost;
      property ResistanceShadow: UInt32 read FResistanceShadow write FResistanceShadow;
      property ResistanceArcane: UInt32 read FResistanceArcane write FResistanceArcane;
      property Delay: UInt32 read FDelay write FDelay;
      property AmunitionType: UInt32 read FAmmunitionType write FAmmunitionType;
      property Bonding: UInt32 read FBonding write FBonding;
      property RangedModifier: Float read FRange write FRange;
      property PageID: UInt32 read FPageID write FPageID;
      property PageLanguage: UInt32 read FPageLanguage write FPageLanguage;
      property PageMaterial: UInt32 read FPageMaterial write FPageMaterial;
      property StartsQuest: UInt32 read FStartsQuest write FStartsQuest;
      property LockID: UInt32 read FLockID write FLockID;
      property LockMaterial: UInt32 read FLockMaterial write FLockMaterial;
      property Sheath: UInt32 read FSheath write FSheath;
      property ExtraInfo: UInt32 read FExtraInfo write FExtraInfo;
      property ExtraInfoAdvanced: UInt32 read FExtraInfo2 write FExtraInfo2;
      property Block: UInt32 read FBlock write FBlock;
      property ItemSet: UInt32 read FItemSet write FItemSet;
      property MaximumDurability: UInt32 read FMaximumDurability write FMaximumDurability;
      property Area: UInt32 read FArea write FArea;
      property Name: WideString read FName write FName;
      property NameForQuest: WideString read FNameForQuest write FNameForQuest;
      property NameHonorable: WideString read FNameHonorable write FNameHonorable;
      property NameEnchanting: WideString read FNameEnchanting write FNameEnchanting;
      property Description: WideString read FDescription write FDescription;
      property MapId: UInt32 read FMapId write FMapId;
      property BagFamily: UInt32 read FBagType write FBagType;
      property TotemCategory: UInt32 read FToolCategory write FToolCategory;
      property SocketColor1: UInt32 read FSocketColor1 write FSocketColor1;
      property SocketUnk1: UInt32 read FUnk2 write FUnk2;
      property SocketColor2: UInt32 read FSocketColor2 write FSocketColor2;
      property SocketUnk2: UInt32 read FUnk3 write FUnk3;
      property SocketColor3: UInt32 read FSocketColor3 write FSocketColor3;
      property SocketUnk3: UInt32 read FUnk4 write FUnk4;
      property SocketBonus: UInt32 read FSocketBonus write FSocketBonus;
      property GemProperties: UInt32 read FGemProperties write FGemProperties;
      property ItemExtendedCost: UInt32 read FItemExtendedCost write FItemExtendedCost;
      property DisenchantReqSkill: UInt32 read FDisenchantReqSkill write FDisenchantReqSkill;
  end;
  {$M-}

  ICreatureTemplateEntry = interface(ISerializable)
  ['{52AC0E92-DB38-4483-AAAE-07562243D51D}']
    function GetEntryName: PWideChar; stdcall;
    function GetEntryGuildName: PWideChar; stdcall;
    function GetEntrySubName: PWideChar; stdcall;
    function GetEntryNameN: WideString;
    function GetEntryGuildNameN: WideString;
    function GetEntrySubNameN: WideString;
    function GetModelId: UInt32; stdcall;
    function GetMaxHealth: UInt32; stdcall;
    function GetMaxMana: UInt32; stdcall;
    function GetLevel: UInt32; stdcall;
    function GetMaximumLevel: UInt32; stdcall;
    function GetArmor: UInt32; stdcall;
    function GetFaction: UInt32; stdcall;
    function GetNpcFlags: UInt32; stdcall;
    function GetRank: UInt32; stdcall;
    function GetFamily: UInt32; stdcall;
    function GetGender: UInt32; stdcall;
    function GetBaseAttackPower: UInt32; stdcall;
    function GetBaseAttackTime: UInt32; stdcall;
    function GetRangedAttackPower: UInt32; stdcall;
    function GetRangedAttackTime: UInt32; stdcall;
    function GetFlags: UInt32; stdcall;
    function GetDynamicFlags: UInt32; stdcall;
    function GetUnitClass: UInt32; stdcall;
    function GetTrainerType: UInt32; stdcall;
    function GetMountID: UInt32; stdcall;
    function GetType: UInt32; stdcall;
    function GetCivilian: UInt32; stdcall;
    function GetElite: UInt32; stdcall;
    function GetUnitType: UInt32; stdcall;
    function GetUnitFlags: UInt32; stdcall;
    function GetMovementSpeed: Float; stdcall;
    function GetDamageMin: Float; stdcall;
    function GetDamageMax: Float; stdcall;
    function GetRangeDamageMin: Float; stdcall;
    function GetRangeDamageMax: Float; stdcall;
    function GetScale: Float; stdcall;
    function GetBoundingRadius: Float; stdcall;
    function GetCombatReach: Float; stdcall;
    function GetResistancePhysical: UInt32; stdcall;
    function GetResistanceHoly: UInt32; stdcall;
    function GetResistanceFire: UInt32; stdcall;
    function GetResistanceNature: UInt32; stdcall;
    function GetResistanceFrost: UInt32; stdcall;
    function GetResistanceShadow: UInt32; stdcall;
    function GetResistanceArcane: UInt32; stdcall;

    procedure SetEntryName(Value: PWideChar); stdcall;
    procedure SetEntryGuildName(Value: PWideChar); stdcall;
    procedure SetEntrySubName(Value: PWideChar); stdcall;
    procedure SetEntryNameN(const Value: WideString);
    procedure SetEntryGuildNameN(const Value: WideString);
    procedure SetEntrySubNameN(const Value: WideString);
    procedure SetModelId(Value: UInt32); stdcall;
    procedure SetMaxHealth(Value: UInt32); stdcall;
    procedure SetMaxMana(Value: UInt32); stdcall;
    procedure SetLevel(Value: UInt32); stdcall;
    procedure SetMaximumLevel(Value: UInt32); stdcall;
    procedure SetArmor(Value: UInt32); stdcall;
    procedure SetFaction(Value: UInt32); stdcall;
    procedure SetNpcFlags(Value: UInt32); stdcall;
    procedure SetRank(Value: UInt32); stdcall;
    procedure SetFamily(Value: UInt32); stdcall;
    procedure SetGender(Value: UInt32); stdcall;
    procedure SetBaseAttackPower(Value: UInt32); stdcall;
    procedure SetBaseAttackTime(Value: UInt32); stdcall;
    procedure SetRangedAttackPower(Value: UInt32); stdcall;
    procedure SetRangedAttackTime(Value: UInt32); stdcall;
    procedure SetFlags(Value: UInt32); stdcall;
    procedure SetDynamicFlags(Value: UInt32); stdcall;
    procedure SetUnitClass(Value: UInt32); stdcall;
    procedure SetTrainerType(Value: UInt32); stdcall;
    procedure SetMountID(Value: UInt32); stdcall;
    procedure SetType(Value: UInt32); stdcall;
    procedure SetCivilian(Value: UInt32); stdcall;
    procedure SetElite(Value: UInt32); stdcall;
    procedure SetUnitType(Value: UInt32); stdcall;
    procedure SetUnitFlags(Value: UInt32); stdcall;
    procedure SetMovementSpeed(Value: Float); stdcall;
    procedure SetDamageMin(Value: Float); stdcall;
    procedure SetDamageMax(Value: Float); stdcall;
    procedure SetRangeDamageMin(Value: Float); stdcall;
    procedure SetRangeDamageMax(Value: Float); stdcall;
    procedure SetScale(Value: Float); stdcall;
    procedure SetBoundingRadius(Value: Float); stdcall;
    procedure SetCombatReach(Value: Float); stdcall;
    procedure SetResistancePhysical(Value: UInt32); stdcall;
    procedure SetResistanceHoly(Value: UInt32); stdcall;
    procedure SetResistanceFire(Value: UInt32); stdcall;
    procedure SetResistanceNature(Value: UInt32); stdcall;
    procedure SetResistanceFrost(Value: UInt32); stdcall;
    procedure SetResistanceShadow(Value: UInt32); stdcall;
    procedure SetResistanceArcane(Value: UInt32); stdcall;

    property EntryName: WideString read GetEntryNameN write SetEntryNameN;
    property EntryGuildName: WideString read GetEntryGuildNameN write SetEntryGuildNameN;
    property EntrySubName: WideString read GetEntrySubNameN write SetEntrySubNameN;
    property ModelId: UInt32 read GetModelId write SetModelId;
    property MaxHealth: UInt32 read GetMaxHealth write SetMaxHealth;
    property MaxMana: UInt32 read GetMaxMana write SetMaxMana;
    property Level: UInt32 read GetLevel write SetLevel;
    property MaximumLevel: UInt32 read GetMaximumLevel write SetMaximumLevel;
    property Armor: UInt32 read GetArmor write SetArmor;
    property Faction: UInt32 read GetFaction write SetFaction;
    property NPCFlag: UInt32 read GetNPCFlags write SetNPCFlags;
    property Rank: UInt32 read GetRank write SetRank;
    property Family: UInt32 read GetFamily write SetFamily;
    property Gender: UInt32 read GetGender write SetGender;
    property BaseAttackPower: UInt32 read GetBaseAttackPower write SetBaseAttackPower;
    property BaseAttackTime: UInt32 read GetBaseAttackTime write SetBaseAttackTime;
    property RangedAttackPower: UInt32 read GetRangedAttackPower write SetRangedAttackPower;
    property RangedAttackTime: UInt32 read GetRangedAttackTime write SetRangedAttackTime;
    property EntryFlags: UInt32 read GetFlags write SetFlags;
    property DynamicFlags: UInt32 read GetDynamicFlags write SetDynamicFlags;
    property UnitClass: UInt32 read GetUnitClass write SetUnitClass;
    property TrainerType: UInt32 read GetTrainerType write SetTrainerType;
    property MountID: UInt32 read GetMountID write SetMountID;
    property EntryType: UInt32 read GetType write SetType;
    property Civilian: UInt32 read GetCivilian write SetCivilian;
    property Elite: UInt32 read GetElite write SetElite;
    property UnitType: UInt32 read GetUnitType write SetUnitType;
    property UnitFlags: UInt32 read GetUnitFlags write SetUnitFlags;
    property MovementSpeed: Float read GetMovementSpeed write SetMovementSpeed;
    property DamageMin: Float read GetDamageMin write SetDamageMin;
    property DamageMax: Float read GetDamageMax write SetDamageMax;
    property RangeDamageMin: Float read GetRangeDamageMin write SetRangeDamageMin;
    property RangeDamageMax: Float read GetRangeDamageMax write SetRangeDamageMax;
    property EntrySize: Float read GetScale write SetScale;
    property BoundingRadius: Float read GetBoundingRadius write SetBoundingRadius;
    property CombatReach: Float read GetCombatReach write SetCombatReach;
    property ResistancePhysical: UInt32 read GetResistancePhysical write SetResistancePhysical;
    property ResistanceHoly: UInt32 read GetResistanceHoly write SetResistanceHoly;
    property ResistanceFire: UInt32 read GetResistanceFire write SetResistanceFire;
    property ResistanceNature: UInt32 read GetResistanceNature write SetResistanceNature;
    property ResistanceFrost: UInt32 read GetResistanceFrost write SetResistanceFrost;
    property ResistanceShadow: UInt32 read GetResistanceShadow write SetResistanceShadow;
    property ResistanceArcane: UInt32 read GetResistanceArcane write SetResistanceArcane;
  end;

  {$M+}
  YDbCreatureTemplate = class(YDbSerializable, ISerializable, ICreatureTemplateEntry)
    private
      FEntryName: WideString;
      FEntryGuildName: WideString;
      FEntrySubName: WideString;
      FEntryNameUTF8: AnsiString;
      FEntryGuildNameUTF8: AnsiString;
      FEntrySubNameUTF8: AnsiString;
      FModelId: UInt32;
      FMaxHealth: UInt32;
      FMaxMana: UInt32;
      FLevel: UInt32;
      FMaximumLevel: UInt32;
      FArmor: UInt32;
      FFaction: UInt32;
      FNPCFlags: UInt32;
      FRank: UInt32;
      FFamily: UInt32;
      FGender: UInt32;
      FBaseAttackPower: UInt32;
      FBaseAttackTime: UInt32;
      FRangedAttackPower: UInt32;
      FRangedAttackTime: UInt32;
      FFlags: UInt32;
      FDynamicFlags: UInt32;
      FUnitClass: UInt32;
      FTrainerType: UInt32;
      FMountID: UInt32;
      FType: UInt32;
      FCivilian: UInt32;
      FElite: UInt32;
      FUnitType: UInt32;
      FUnitFlags: UInt32;

      FMovementSpeed: Float;
      FDamageMin: Float;
      FDamageMax: Float;
      FRangeDamageMin: Float;
      FRangeDamageMax: Float;
      FScale: Float;
      FBoundingRadius: Float;
      FCombatReach: Float;

      FEquipModel0: UInt32;
      FEquipModel1: UInt32;
      FEquipModel2: UInt32;
      FEquipInfo0: UInt32;
      FEquipInfo1: UInt32;
      FEquipInfo2: UInt32;
      FEquipSlot0: UInt32;
      FEquipSlot1: UInt32;
      FEquipSlot2: UInt32;

      FResistancePhysical: UInt32;
      FResistanceHoly: UInt32;
      FResistanceFire: UInt32;
      FResistanceNature: UInt32;
      FResistanceFrost: UInt32;
      FResistanceShadow: UInt32;
      FResistanceArcane: UInt32;
    protected
      procedure Assign(const Entry: ISerializable); override;

      function GetEntryName: PWideChar; stdcall;
      function GetEntryGuildName: PWideChar; stdcall;
      function GetEntrySubName: PWideChar; stdcall;
      function GetEntryNameN: WideString;
      function GetEntryGuildNameN: WideString;
      function GetEntrySubNameN: WideString;
      function GetModelId: UInt32; stdcall;
      function GetMaxHealth: UInt32; stdcall;
      function GetMaxMana: UInt32; stdcall;
      function GetLevel: UInt32; stdcall;
      function GetMaximumLevel: UInt32; stdcall;
      function GetArmor: UInt32; stdcall;
      function GetFaction: UInt32; stdcall;
      function GetNpcFlags: UInt32; stdcall;
      function GetRank: UInt32; stdcall;
      function GetFamily: UInt32; stdcall;
      function GetGender: UInt32; stdcall;
      function GetBaseAttackPower: UInt32; stdcall;
      function GetBaseAttackTime: UInt32; stdcall;
      function GetRangedAttackPower: UInt32; stdcall;
      function GetRangedAttackTime: UInt32; stdcall;
      function GetFlags: UInt32; stdcall;
      function GetDynamicFlags: UInt32; stdcall;
      function GetUnitClass: UInt32; stdcall;
      function GetTrainerType: UInt32; stdcall;
      function GetMountID: UInt32; stdcall;
      function GetType: UInt32; stdcall;
      function GetCivilian: UInt32; stdcall;
      function GetElite: UInt32; stdcall;
      function GetUnitType: UInt32; stdcall;
      function GetUnitFlags: UInt32; stdcall;
      function GetMovementSpeed: Float; stdcall;
      function GetDamageMin: Float; stdcall;
      function GetDamageMax: Float; stdcall;
      function GetRangeDamageMin: Float; stdcall;
      function GetRangeDamageMax: Float; stdcall;
      function GetScale: Float; stdcall;
      function GetBoundingRadius: Float; stdcall;
      function GetCombatReach: Float; stdcall;
      function GetResistancePhysical: UInt32; stdcall;
      function GetResistanceHoly: UInt32; stdcall;
      function GetResistanceFire: UInt32; stdcall;
      function GetResistanceNature: UInt32; stdcall;
      function GetResistanceFrost: UInt32; stdcall;
      function GetResistanceShadow: UInt32; stdcall;
      function GetResistanceArcane: UInt32; stdcall;

      procedure SetEntryName(Value: PWideChar); stdcall;
      procedure SetEntryGuildName(Value: PWideChar); stdcall;
      procedure SetEntrySubName(Value: PWideChar); stdcall;
      procedure SetEntryNameN(const Value: WideString);
      procedure SetEntryGuildNameN(const Value: WideString);
      procedure SetEntrySubNameN(const Value: WideString);
      procedure SetModelId(Value: UInt32); stdcall;
      procedure SetMaxHealth(Value: UInt32); stdcall;
      procedure SetMaxMana(Value: UInt32); stdcall;
      procedure SetLevel(Value: UInt32); stdcall;
      procedure SetMaximumLevel(Value: UInt32); stdcall;
      procedure SetArmor(Value: UInt32); stdcall;
      procedure SetFaction(Value: UInt32); stdcall;
      procedure SetNpcFlags(Value: UInt32); stdcall;
      procedure SetRank(Value: UInt32); stdcall;
      procedure SetFamily(Value: UInt32); stdcall;
      procedure SetGender(Value: UInt32); stdcall;
      procedure SetBaseAttackPower(Value: UInt32); stdcall;
      procedure SetBaseAttackTime(Value: UInt32); stdcall;
      procedure SetRangedAttackPower(Value: UInt32); stdcall;
      procedure SetRangedAttackTime(Value: UInt32); stdcall;
      procedure SetFlags(Value: UInt32); stdcall;
      procedure SetDynamicFlags(Value: UInt32); stdcall;
      procedure SetUnitClass(Value: UInt32); stdcall;
      procedure SetTrainerType(Value: UInt32); stdcall;
      procedure SetMountID(Value: UInt32); stdcall;
      procedure SetType(Value: UInt32); stdcall;
      procedure SetCivilian(Value: UInt32); stdcall;
      procedure SetElite(Value: UInt32); stdcall;
      procedure SetUnitType(Value: UInt32); stdcall;
      procedure SetUnitFlags(Value: UInt32); stdcall;
      procedure SetMovementSpeed(Value: Float); stdcall;
      procedure SetDamageMin(Value: Float); stdcall;
      procedure SetDamageMax(Value: Float); stdcall;
      procedure SetRangeDamageMin(Value: Float); stdcall;
      procedure SetRangeDamageMax(Value: Float); stdcall;
      procedure SetScale(Value: Float); stdcall;
      procedure SetBoundingRadius(Value: Float); stdcall;
      procedure SetCombatReach(Value: Float); stdcall;
      procedure SetResistancePhysical(Value: UInt32); stdcall;
      procedure SetResistanceHoly(Value: UInt32); stdcall;
      procedure SetResistanceFire(Value: UInt32); stdcall;
      procedure SetResistanceNature(Value: UInt32); stdcall;
      procedure SetResistanceFrost(Value: UInt32); stdcall;
      procedure SetResistanceShadow(Value: UInt32); stdcall;
      procedure SetResistanceArcane(Value: UInt32); stdcall;
    published
      property EntryName: WideString read FEntryName write FEntryName;
      property EntryGuildName: WideString read FEntryGuildName write FEntryGuildName;
      property EntrySubName: WideString read FEntrySubName write FEntrySubName;
      property ModelId: UInt32 read FModelId write FModelId;
      property MaxHealth: UInt32 read FMaxHealth write FMaxHealth;
      property MaxMana: UInt32 read FMaxMana write FMaxMana;
      property Level: UInt32 read FLevel write FLevel;
      property MaximumLevel: UInt32 read FMaximumLevel write FMaximumLevel;
      property Armor: UInt32 read FArmor write FArmor;
      property Faction: UInt32 read FFaction write FFaction;
      property NPCFlag: UInt32 read FNPCFlags write FNPCFlags;
      property Rank: UInt32 read FRank write FRank;
      property Family: UInt32 read FFamily write FFamily;
      property Gender: UInt32 read FGender write FGender;
      property BaseAttackPower: UInt32 read FBaseAttackPower write FBaseAttackPower;
      property BaseAttackTime: UInt32 read FBaseAttackTime write FBaseAttackTime;
      property RangedAttackPower: UInt32 read FRangedAttackPower write FRangedAttackPower;
      property RangedAttackTime: UInt32 read FRangedAttackTime write FRangedAttackTime;
      property EntryFlags: UInt32 read FFlags write FFlags;
      property DynamicFlags: UInt32 read FDynamicFlags write FDynamicFlags;
      property UnitClass: UInt32 read FUnitClass write FUnitClass;
      property TrainerType: UInt32 read FTrainerType write FTrainerType;
      property MountID: UInt32 read FMountID write FMountID;
      property EntryType: UInt32 read FType write FType;
      property Civilian: UInt32 read FCivilian write FCivilian;
      property Elite: UInt32 read FElite write FElite;
      property UnitType: UInt32 read FUnitType write FUnitType;
      property UnitFlags: UInt32 read FUnitFlags write FUnitFlags;
      property MovementSpeed: Float read FMovementSpeed write FMovementSpeed;
      property DamageMin: Float read FDamageMin write FDamageMin;
      property DamageMax: Float read FDamageMax write FDamageMax;
      property RangeDamageMin: Float read FRangeDamageMin write FRangeDamageMin;
      property RangeDamageMax: Float read FRangeDamageMax write FRangeDamageMax;
      property EntrySize: Float read FScale write FScale;
      property BoundingRadius: Float read FBoundingRadius write FBoundingRadius;
      property CombatReach: Float read FCombatReach write FCombatReach;
      property ResistancePhysical: UInt32 read FResistancePhysical write FResistancePhysical;
      property ResistanceHoly: UInt32 read FResistanceHoly write FResistanceHoly;
      property ResistanceFire: UInt32 read FResistanceFire write FResistanceFire;
      property ResistanceNature: UInt32 read FResistanceNature write FResistanceNature;
      property ResistanceFrost: UInt32 read FResistanceFrost write FResistanceFrost;
      property ResistanceShadow: UInt32 read FResistanceShadow write FResistanceShadow;
      property ResistanceArcane: UInt32 read FResistanceArcane write FResistanceArcane;
  end;
  {$M-}

  IGameObjectTemplateEntry = interface(ISerializable)
  ['{070E0F98-589F-46A3-9CBB-1195C03BBB93}']
    function GetName: PWideChar; stdcall;
    function GetNameN: WideString;
    function GetType: UInt32; stdcall;
    function GetModelId: UInt32; stdcall;
    function GetFaction: UInt32; stdcall;
    function GetFlags: UInt32; stdcall;
    function GetSize: Float; stdcall;

    procedure SetName(Value: PWideChar); stdcall;
    procedure SetNameN(const Value: WideString);
    procedure SetType(Value: UInt32); stdcall;
    procedure SetModelId(Value: UInt32); stdcall;
    procedure SetFaction(Value: UInt32); stdcall;
    procedure SetFlags(Value: UInt32); stdcall;
    procedure SetSize(Value: Float); stdcall;

    property Name: WideString read GetNameN write SetNameN;
    property GOType: UInt32 read GetType write SetType;
    property ModelId: UInt32 read GetModelId write SetModelId;
    property Faction: UInt32 read GetFlags write SetFlags;
    property Flags: UInt32 read GetFlags write SetFlags;
    property Size: Float read GetSize write SetSize;
  end;

  {$M+}
  YDbGameObjectTemplate = class(YDbSerializable, ISerializable, IGameObjectTemplateEntry)
    private
      FType: UInt32;
      FModelId: UInt32;
      FFaction: UInt32;
      FFlags: UInt32;
      FSize: Float;
      FSounds: array[0..11] of UInt32;
      FName: WideString;
      FNameUTF8: AnsiString;
      function GetSound(iIndex: Int32): UInt32;
    protected
      procedure Assign(const Entry: ISerializable); override;
      
      function GetName: PWideChar; stdcall;
      function GetNameN: WideString;
      function GetType: UInt32; stdcall;
      function GetModelId: UInt32; stdcall;
      function GetFaction: UInt32; stdcall;
      function GetFlags: UInt32; stdcall;
      function GetSize: Float; stdcall;

      procedure SetName(Value: PWideChar); stdcall;
      procedure SetNameN(const Value: WideString);
      procedure SetType(Value: UInt32); stdcall;
      procedure SetModelId(Value: UInt32); stdcall;
      procedure SetFaction(Value: UInt32); stdcall;
      procedure SetFlags(Value: UInt32); stdcall;
      procedure SetSize(Value: Float); stdcall;
    published
      property Name: WideString read FName write FName;
      property GOType: UInt32 read FType write FType;
      property ModelId: UInt32 read FModelId write FModelId;
      property Faction: UInt32 read FFaction write FFaction;
      property Flags: UInt32 read FFlags write FFlags;
      property Size: Float read FSize write FSize;
    public
      property Sounds[iIndex: Int32]: UInt32 read GetSound;
  end;
  {$M-}

  (*

  IQuestTemplateEntry = interface(ISerializable)
  ['{070E0F98-589F-46A3-9CBB-1195C03BBB93}']
  
  end;

  YDbQuestTemplate = class(YDbSerializable, IQuestTemplateEntry)
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
      fName: AnsiString;
      fObjectives: AnsiString;
      fDetails: AnsiString;
      fEndText: AnsiString;
      fCompleteText: AnsiString;
      fIncompleteText: AnsiString;
      fObjectiveText1: AnsiString;
      fObjectiveText2: AnsiString;
      fObjectiveText3: AnsiString;
      fObjectiveText4: AnsiString;
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
      property ReqLevel: UInt32 read FReqLevel write FReqLevel;
      property Category: UInt32 read FCategory write FCategory;
      property QuestLevel: UInt32 read FQuestLevel write FQuestLevel;
      property MoneyReward: UInt32 read FMoneyReward write FMoneyReward;
      property TimeObjective: UInt32 read FTimeObjective write FTimeObjective;
      property PrevQuest: UInt32 read FPrevQuest write FPrevQuest;
      property NextQuest: UInt32 read FNextQuest write FNextQuest;
      property Complexity: UInt32 read FComplexity write FComplexity;
      property LearnSpell: UInt32 read FLearnSpell write FLearnSpell;
      property ExploreObjective: UInt32 read FExploreObjective write FExploreObjective;
      property QFinishNpc: UInt32 read FQFinishNpc write FQFinishNpc;
      property QFinishObj: UInt32 read FQFinishObj write FQFinishObj;
      property QFinishItm: UInt32 read FQFinishItm write FQFinishItm;
      property QGiverNpc: UInt32 read FQGiverNpc write FQGiverNpc;
      property QGiverObj: UInt32 read FQGiverObj write FQGiverObj;
      property QGiverItm: UInt32 read FQGiverItm write FQGiverItm;
      property DescriptiveFlags: UInt32 read FDescriptiveFlags write FDescriptiveFlags;
      property Name: AnsiString read FName write FName;
      property Objectives: AnsiString read FObjectives write FObjectives;
      property Details: AnsiString read FDetails write FDetails;
      property EndText: AnsiString read FEndText write FEndText;
      property CompleteText: AnsiString read FCompleteText write FCompleteText;
      property IncompleteText: AnsiString read FIncompleteText write FIncompleteText;
      property ObjectiveText1: AnsiString read FObjectiveText1 write FObjectiveText1;
      property ObjectiveText2: AnsiString read FObjectiveText2 write FObjectiveText2;
      property ObjectiveText3: AnsiString read FObjectiveText3 write FObjectiveText3;
      property ObjectiveText4: AnsiString read FObjectiveText4 write FObjectiveText4;
      property DeliverObjective: YQuestObjects read FDeliverObjective write FDeliverObjective;
      property RewardItmChoice: YQuestObjects read FRewardItmChoice write FRewardItmChoice;
      property ReceiveItem: YQuestObjects read FReceiveItem write FReceiveItem;
      property Location: YQuestLocation read FLocation write FLocation;
      property KillObjectiveMob: YQuestObjects read FKillObjectiveMob write FKillObjectiveMob;
      property KillObjectiveObj: YQuestObjects read FKillObjectiveObj write FKillObjectiveObj;
    public
      property ReqReputation: YDoubleDword read FReqReputation;
      property RewardItem: YQuestObjects read FRewardItem;
      property RequiresRace: YDoubleDword read FRequiresRace;
      property RequiresClass: YDoubleDword read FRequiresClass;
      property ReqTradeSkill: YDoubleDword read FReqTradeSkill;
      property QuestBehavior: YQuestBehaviors read FQuestBehavior;
  end;

  *)

  (*
  INPCTextsTemplate = interface(ISerializable)
  ['{070E0F98-589F-46A3-9CBB-1195C03BBB93}']
  end;

  YDbNPCTextsTemplate = class(YDbSerializable, INPCTextsTemplate)
    private
      fText00: AnsiString;
      fText01: AnsiString;
      fText02: AnsiString;
      fText03: AnsiString;
      fText04: AnsiString;
      fText05: AnsiString;
      fText06: AnsiString;
      fText07: AnsiString;
      fText10: AnsiString;
      fText11: AnsiString;
      fText12: AnsiString;
      fText13: AnsiString;
      fText14: AnsiString;
      fText15: AnsiString;
      fText16: AnsiString;
      fText17: AnsiString;
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
      property Text00: AnsiString read FText00;
      property Text01: AnsiString read FText01;
      property Text02: AnsiString read FText02;
      property Text03: AnsiString read FText03;
      property Text04: AnsiString read FText04;
      property Text05: AnsiString read FText05;
      property Text06: AnsiString read FText06;
      property Text07: AnsiString read FText07;
      property Text10: AnsiString read FText10;
      property Text11: AnsiString read FText11;
      property Text12: AnsiString read FText12;
      property Text13: AnsiString read FText13;
      property Text14: AnsiString read FText14;
      property Text15: AnsiString read FText15;
      property Text16: AnsiString read FText16;
      property Text17: AnsiString read FText17;
      property Probability0: Float read FProbability0;
      property Probability1: Float read FProbability1;
      property Probability2: Float read FProbability2;
      property Probability3: Float read FProbability3;
      property Probability4: Float read FProbability4;
      property Probability5: Float read FProbability5;
      property Probability6: Float read FProbability6;
      property Probability7: Float read FProbability7;
      property Language0: UInt32 read FLanguage0;
      property Language1: UInt32 read FLanguage1;
      property Language2: UInt32 read FLanguage2;
      property Language3: UInt32 read FLanguage3;
      property Language4: UInt32 read FLanguage4;
      property Language5: UInt32 read FLanguage5;
      property Language6: UInt32 read FLanguage6;
      property Language7: UInt32 read FLanguage7;
      property EmoteId00: UInt32 read FEmoteId00;
      property EmoteId10: UInt32 read FEmoteId10;
      property EmoteId20: UInt32 read FEmoteId20;
      property EmoteId01: UInt32 read FEmoteId01;
      property EmoteId11: UInt32 read FEmoteId11;
      property EmoteId21: UInt32 read FEmoteId21;
      property EmoteId02: UInt32 read FEmoteId02;
      property EmoteId12: UInt32 read FEmoteId12;
      property EmoteId22: UInt32 read FEmoteId22;
      property EmoteId03: UInt32 read FEmoteId03;
      property EmoteId13: UInt32 read FEmoteId13;
      property EmoteId23: UInt32 read FEmoteId23;
      property EmoteId04: UInt32 read FEmoteId04;
      property EmoteId14: UInt32 read FEmoteId14;
      property EmoteId24: UInt32 read FEmoteId24;
      property EmoteId05: UInt32 read FEmoteId05;
      property EmoteId15: UInt32 read FEmoteId15;
      property EmoteId25: UInt32 read FEmoteId25;
      property EmoteId06: UInt32 read FEmoteId06;
      property EmoteId16: UInt32 read FEmoteId16;
      property EmoteId26: UInt32 read FEmoteId26;
      property EmoteId07: UInt32 read FEmoteId07;
      property EmoteId17: UInt32 read FEmoteId17;
      property EmoteId27: UInt32 read FEmoteId27;
      property EmoteDelay00: UInt32 read FEmoteDelay00;
      property EmoteDelay10: UInt32 read FEmoteDelay10;
      property EmoteDelay20: UInt32 read FEmoteDelay20;
      property EmoteDelay01: UInt32 read FEmoteDelay01;
      property EmoteDelay11: UInt32 read FEmoteDelay11;
      property EmoteDelay21: UInt32 read FEmoteDelay21;
      property EmoteDelay02: UInt32 read FEmoteDelay02;
      property EmoteDelay12: UInt32 read FEmoteDelay12;
      property EmoteDelay22: UInt32 read FEmoteDelay22;
      property EmoteDelay03: UInt32 read FEmoteDelay03;
      property EmoteDelay13: UInt32 read FEmoteDelay13;
      property EmoteDelay23: UInt32 read FEmoteDelay23;
      property EmoteDelay04: UInt32 read FEmoteDelay04;
      property EmoteDelay14: UInt32 read FEmoteDelay14;
      property EmoteDelay24: UInt32 read FEmoteDelay24;
      property EmoteDelay05: UInt32 read FEmoteDelay05;
      property EmoteDelay15: UInt32 read FEmoteDelay15;
      property EmoteDelay25: UInt32 read FEmoteDelay25;
      property EmoteDelay06: UInt32 read FEmoteDelay06;
      property EmoteDelay16: UInt32 read FEmoteDelay16;
      property EmoteDelay26: UInt32 read FEmoteDelay26;
      property EmoteDelay07: UInt32 read FEmoteDelay07;
      property EmoteDelay17: UInt32 read FEmoteDelay17;
      property EmoteDelay27: UInt32 read FEmoteDelay27;
  end;
  *)

  YAccountHash = array[0..39] of Byte;

  IAccountEntry = interface(ISerializable)
  ['{D0DE9810-3EA0-4D92-9240-37885E3E1AE7}']
    function GetName: PWideChar; stdcall;
    function GetNameN: WideString;
    function GetPass: PWideChar; stdcall;
    function GetPassN: WideString;
    function GetHash: YAccountHash; stdcall;
    function GetAccess: YAccountAccess; stdcall;
    function GetStatus: YAccountStatus; stdcall;
    function GetLoggedIn: Boolean; stdcall;
    function GetAutoCreated: Boolean; stdcall;

    procedure SetName(Value: PWideChar); stdcall;
    procedure SetNameN(const Value: WideString);
    procedure SetPass(Value: PWideChar); stdcall;
    procedure SetPassN(const Value: WideString);
    procedure SetHash(Value: YAccountHash); stdcall;
    procedure SetAccess(Value: YAccountAccess); stdcall;
    procedure SetStatus(Value: YAccountStatus); stdcall;
    procedure SetLoggedIn(Value: Boolean); stdcall;
    procedure SetAutoCreated(Value: Boolean); stdcall;

    property Name: WideString read GetNameN write SetNameN;
    property Pass: WideString read GetPassN write SetPassN;
    property Hash: YAccountHash read GetHash write SetHash;
    property Access: YAccountAccess read GetAccess write SetAccess;
    property Status: YAccountStatus read GetStatus write SetStatus;
    property LoggedIn: Boolean read GetLoggedIn write SetLoggedIn;
    property AutoCreated: Boolean read GetAutoCreated write SetAutoCreated;
  end;

  {$M+}
  YDbAccountEntry = class(YDbSerializable, ISerializable, IAccountEntry)
    private
      FName: WideString;
      FPass: WideString;
      FHash: YAccountHash;
      FLoggedIn: Boolean;
      FAutoCreated: Boolean;
      FAccess: YAccountAccess;
      FStatus: YAccountStatus;
    protected
      procedure Assign(const Entry: ISerializable); override;
      
      function GetName: PWideChar; stdcall;
      function GetPass: PWideChar; stdcall;
      function GetNameN: WideString;
      function GetPassN: WideString;
      function GetHash: YAccountHash; stdcall;
      function GetAccess: YAccountAccess; stdcall;
      function GetStatus: YAccountStatus; stdcall;
      function GetLoggedIn: Boolean; stdcall;
      function GetAutoCreated: Boolean; stdcall;

      procedure SetName(Value: PWideChar); stdcall;
      procedure SetPass(Value: PWideChar); stdcall;
      procedure SetNameN(const Value: WideString);
      procedure SetPassN(const Value: WideString);
      procedure SetHash(Value: YAccountHash); stdcall;
      procedure SetAccess(Value: YAccountAccess); stdcall;
      procedure SetStatus(Value: YAccountStatus); stdcall;
      procedure SetLoggedIn(Value: Boolean); stdcall;
      procedure SetAutoCreated(Value: Boolean); stdcall;
    published
      property Name: WideString read FName write FName;
      property Pass: WideString read FPass write FPass;
      property Access: YAccountAccess read FAccess write FAccess;
      property Status: YAccountStatus read FStatus write FStatus;
      property LoggedIn: Boolean read FLoggedIn write FLoggedIn;
      property AutoCreated: Boolean read FAutoCreated write FAutoCreated;
  end;
  {$M-}

  IWowObjectEntry = interface(ISerializable)
  ['{49A3CBB7-CE9E-4808-9D62-A312F0C3738A}']
    function GetUpdateDataLength: Int32; stdcall;
    procedure GetUpdateData(Buffer: PUInt32); stdcall;
    procedure SetUpdateData(Buffer: PUInt32; Length: Int32); stdcall;
  end;

  {$M+}
  YDbWowObjectEntry = class(YDbSerializable, ISerializable, IWowObjectEntry)
    private
      FUpdateData: TLongWordDynArray;
      FTimers: TLongWordDynArray;
    protected
      procedure Assign(const Entry: ISerializable); override;

      function GetUpdateDataLength: Int32; stdcall;
      procedure GetUpdateData(Buffer: PUInt32); stdcall;
      procedure SetUpdateData(Buffer: PUInt32; Length: Int32); stdcall;
    published
      property UpdateData: TLongWordDynArray read FUpdateData write FUpdateData;
      property Timers: TLongWordDynArray read FTimers write FTimers;
  end;
  {$M-}

  IItemEntry = interface(IWowObjectEntry)
  ['{2CD79BEE-CB7B-424C-A7C5-E34D87C494B1}']
    function GetEntryId: UInt32; stdcall;
    function GetStackCount: UInt32; stdcall;
    function GetDurability: UInt32; stdcall;
    function GetContainedIn: UInt32; stdcall;
    function GetCreator: UInt32; stdcall;

    procedure SetEntryId(Value: UInt32); stdcall;
    procedure SetStackCount(Value: UInt32); stdcall;
    procedure SetDurability(Value: UInt32); stdcall;
    procedure SetContainedId(Value: UInt32); stdcall;
    procedure SetCreator(Value: UInt32); stdcall;

    property EntryId: UInt32 read GetEntryId write SetEntryId;
    property StackCount: UInt32 read GetStackCount write SetStackCount;
    property Durability: UInt32 read GetDurability write SetDurability;
    property ContainedId: UInt32 read GetContainedIn write SetContainedId;
    property Creator: UInt32 read GetCreator write SetCreator;
  end;

  {$M+}
  YDbItemEntry = class(YDbWowObjectEntry, ISerializable, IItemEntry)
    private
      FEntry: UInt32;
      FStackCount: UInt32;
      FDurability: UInt32;
      FContained: UInt32;
      FCreator: UInt32;
      FItemsContained: TLongWordDynArray;
    protected
      procedure Assign(const Entry: ISerializable); override;

      function GetEntryId: UInt32; stdcall;
      function GetStackCount: UInt32; stdcall;
      function GetDurability: UInt32; stdcall;
      function GetContainedIn: UInt32; stdcall;
      function GetCreator: UInt32; stdcall;

      procedure SetEntryId(Value: UInt32); stdcall;
      procedure SetStackCount(Value: UInt32); stdcall;
      procedure SetDurability(Value: UInt32); stdcall;
      procedure SetContainedId(Value: UInt32); stdcall;
      procedure SetCreator(Value: UInt32); stdcall;

      procedure SetItemsContainedLength(iNewLen: Int32);
    published
      property Entry: UInt32 read FEntry write FEntry;
      property StackCount: UInt32 read FStackCount write FStackCount;
      property Durability: UInt32 read FDurability write FDurability;
      property ContainedIn: UInt32 read FContained write FContained;
      property Creator: UInt32 read FCreator write FCreator;
      property ItemsContained: TLongWordDynArray read FItemsContained;
  end;
  {$M-}

  IPlayerEntry = interface(IWowObjectEntry)
  ['{C0786724-9676-4BF5-AEBF-68F83785064C}']
    function GetX: Float; stdcall;
    function GetY: Float; stdcall;
    function GetZ: Float; stdcall;
    function GetAngle: Float; stdcall;
    function GetMapId: UInt32; stdcall;
    function GetZoneId: UInt32; stdcall;
    function GetInstanceId: UInt32; stdcall;
    function GetAccountName: PWideChar; stdcall;
    function GetAccountNameN: WideString;
    function GetName: PWideChar; stdcall;
    function GetNameN: WideString;
    function GetPrivileges: PAnsiChar; stdcall;
    function GetPrivilegesN: AnsiString;
    function GetRested: UInt32; stdcall;

    procedure SetX(Value: Float); stdcall;
    procedure SetY(Value: Float); stdcall;
    procedure SetZ(Value: Float); stdcall;
    procedure SetAngle(Value: Float); stdcall;
    procedure SetMapId(Value: UInt32); stdcall;
    procedure SetZoneId(Value: UInt32); stdcall;
    procedure SetInstanceId(Value: UInt32); stdcall;
    procedure SetAccountName(Value: PWideChar); stdcall;
    procedure SetAccountNameN(const Value: WideString);
    procedure SetName(Value: PWideChar); stdcall;
    procedure SetNameN(const Value: WideString); stdcall;
    procedure SetPrivileges(Value: PAnsiChar); stdcall;
    procedure SetPrivilegesN(const Value: AnsiString); stdcall;
    procedure SetRested(Value: UInt32); stdcall;

    property X: Float read GetX write SetX;
    property Y: Float read GetY write SetY;
    property Z: Float read GetZ write SetZ;
    property Angle: Float read GetAngle write SetAngle;
    property ZoneId: UInt32 read GetZoneId write SetZoneId;
    property MapId: UInt32 read GetMapId write SetMapId;
    property InstanceId: UInt32 read GetInstanceId write SetInstanceId;
    property AccountName: WideString read GetAccountNameN write SetAccountNameN;
    property Name: WideString read GetNameN write SetNameN;
    property Privileges: AnsiString read GetPrivilegesN write SetPrivilegesN;
    property Rested: UInt32 read GetRested write SetRested;
  end;

  {$M+}
  YDbPlayerEntry = class(YDbWowObjectEntry, ISerializable, IPlayerEntry)
    private
      FPosX: Float;
      FPosY: Float;
      FPosZ: Float;
      FAngle: Float;
      FMapId: UInt32;
      FInstanceId: UInt32;
      FZoneId: UInt32;
      FAccount: WideString;
      FCharName: WideString;
      FPrivileges: AnsiString;
      FRested: UInt32;
      FTutorials: TLongWordDynArray;
      FActionButtons: TLongWordDynArray;
      FEquippedItems: TLongWordDynArray;
      FHonorStats: TLongWordDynArray;
      FPriviledges: AnsiString;
      FActiveQuests: YActiveQuests;
      FFinishedQuests: TLongWordDynArray;
      FTPPlaces: YTPPlaces;
    protected
      procedure Assign(const Entry: ISerializable); override;

      procedure SetTutorialsLength(iNewLen: Int32);
      procedure SetActionButtonsLength(iNewLen: Int32);
      procedure SetEquippedItemsLength(iNewLen: Int32);
      procedure SetHonorStatsLength(iNewLen: Int32);
      procedure SetPriviledgesLength(iNewLen: Int32);

      function GetX: Float; stdcall;
      function GetY: Float; stdcall;
      function GetZ: Float; stdcall;
      function GetAngle: Float; stdcall;
      function GetMapId: UInt32; stdcall;
      function GetZoneId: UInt32; stdcall;
      function GetInstanceId: UInt32; stdcall;
      function GetAccountName: PWideChar; stdcall;
      function GetAccountNameN: WideString;
      function GetName: PWideChar; stdcall;
      function GetNameN: WideString;
      function GetPrivileges: PAnsiChar; stdcall;
      function GetPrivilegesN: AnsiString;
      function GetRested: UInt32; stdcall;

      procedure SetX(Value: Float); stdcall;
      procedure SetY(Value: Float); stdcall;
      procedure SetZ(Value: Float); stdcall;
      procedure SetAngle(Value: Float); stdcall;
      procedure SetMapId(Value: UInt32); stdcall;
      procedure SetZoneId(Value: UInt32); stdcall;
      procedure SetInstanceId(Value: UInt32); stdcall;
      procedure SetAccountName(Value: PWideChar); stdcall;
      procedure SetAccountNameN(const Value: WideString);
      procedure SetName(Value: PWideChar); stdcall;
      procedure SetNameN(const Value: WideString); stdcall;
      procedure SetPrivileges(Value: PAnsiChar); stdcall;
      procedure SetPrivilegesN(const Value: AnsiString); stdcall;
      procedure SetRested(Value: UInt32); stdcall;
    published
      property X: Float read FPosX write FPosX;
      property Y: Float read FPosY write FPosY;
      property Z: Float read FPosZ write FPosZ;
      property Angle: Float read FAngle write FAngle;
      property ZoneId: UInt32 read FZoneId write FZoneId;
      property MapId: UInt32 read FMapId write FMapId;
      property InstanceId: UInt32 read FInstanceId write FInstanceId;
      property AccountName: WideString read FAccount write FAccount;
      property Name: WideString read FCharName write FCharName;
      property Privileges: AnsiString read FPrivileges write FPrivileges;
      property Rested: UInt32 read FRested write FRested;
      property Tutorials: TLongWordDynArray read FTutorials;
      property ActionButtons: TLongWordDynArray read FActionButtons;
      property EquippedItems: TLongWordDynArray read FEquippedItems;
      property HonorStats: TLongWordDynArray read FHonorStats;
      property Priviledges: AnsiString read FPriviledges;
      property ActiveQuests: YActiveQuests read FActiveQuests write FActiveQuests;
      property FinishedQuests: TLongWordDynArray read FFinishedQuests write FFinishedQuests;
      property TPPlaces: YTPPlaces read FTPPlaces write FTPPlaces;
  end;
  {$M-}

  YNodeFlag = (nfNone, nfSpawn, nfReachNotify, nfLink, nfMultilink);
  { Flags:
    nfNone - dummy
    nfSpawn - the node has spawn entries (unimplemented)
    nfReachNotify - the node calls a callback when an object reaches it (unimplemented)
    nfLink - the node is linked to another node
    nfMultilink - the node is (or can be) linked with more nodes
  }

  YNodeFlags = set of YNodeFlag;

  INodeEntry = interface(ISerializable)
  ['{8D8D1B90-F519-4BFE-BC51-1B767EC68357}']
    function GetX: Float; stdcall;
    function GetY: Float; stdcall;
    function GetZ: Float; stdcall;
    function GetMapId: UInt32; stdcall;
    function GetFlags: YNodeFlags; stdcall;

    procedure SetX(Value: Float); stdcall;
    procedure SetY(Value: Float); stdcall;
    procedure SetZ(Value: Float); stdcall;
    procedure SetMapId(Value: UInt32); stdcall;
    procedure SetFlags(Value: YNodeFlags); stdcall;

    property X: Float read GetX write SetX;
    property Y: Float read GetY write SetY;
    property Z: Float read GetZ write SetZ;
    property MapId: UInt32 read GetMapId write SetMapId;
    property Flags: YNodeFlags read GetFlags write SetFlags;
  end;

  {$M+}
  YDbNodeEntry = class(YDbSerializable, ISerializable, INodeEntry)
    private
      FPosX: Float;
      FPosY: Float;
      FPosZ: Float;
      FMapId: UInt32;
      FFlags: YNodeFlags;
    protected
      procedure Assign(const Entry: ISerializable); override;

      function GetX: Float; stdcall;
      function GetY: Float; stdcall;
      function GetZ: Float; stdcall;
      function GetMapId: UInt32; stdcall;
      function GetFlags: YNodeFlags; stdcall;

      procedure SetX(Value: Float); stdcall;
      procedure SetY(Value: Float); stdcall;
      procedure SetZ(Value: Float); stdcall;
      procedure SetMapId(Value: UInt32); stdcall;
      procedure SetFlags(Value: YNodeFlags); stdcall;
    published
      property X: Float read FPosX write FPosX;
      property Y: Float read FPosY write FPosY;
      property Z: Float read FPosZ write FPosZ;
      property MapId: UInt32 read FMapId write FMapId;
      property Flags: YNodeFlags read FFlags write FFlags;
  end;
  {$M-}

  IAddonEntry = interface(ISerializable)
  ['{EE30FE42-AAB6-48A2-8824-5EBEEAD06579}']
    function GetName: PWideChar; stdcall;
    function GetNameN: WideString;
    function GetCRC32: UInt32; stdcall;
    function GetEnabled: Boolean; stdcall;

    procedure SetName(Value: PWideChar); stdcall;
    procedure SetNameN(const Value: WideString);
    procedure SetCRC32(Value: UInt32); stdcall;
    procedure SetEnabled(Value: Boolean); stdcall;

    property Name: WideString read GetNameN write SetNameN;
    property CRC32: UInt32 read GetCRC32 write SetCRC32;
    property Enabled: Boolean read GetEnabled write SetEnabled;
  end;

  {$M+}
  YDbAddonEntry = class(YDbSerializable, ISerializable, IAddonEntry)
    private
      FName: WideString;
      FCRC32: UInt32;
      FEnabled: Boolean;
    protected
      procedure Assign(const Entry: ISerializable); override;

      function GetName: PWideChar; stdcall;
      function GetNameN: WideString;
      function GetCRC32: UInt32; stdcall;
      function GetEnabled: Boolean; stdcall;

      procedure SetName(Value: PWideChar); stdcall;
      procedure SetNameN(const Value: WideString);
      procedure SetCRC32(Value: UInt32); stdcall;
      procedure SetEnabled(Value: Boolean); stdcall;
    published
      property Name: WideString read FName write FName;
      property CRC32: UInt32 read FCRC32 write FCRC32;
      property Enabled: Boolean read FEnabled write FEnabled;
  end;
  {$M-}

  IPersistentTimerEntry = interface(ISerializable)
  ['{7AC497E0-9EA4-4872-8440-9FE7E0E5B83D}']
    function GetTimeLeft: UInt32; stdcall;
    function GetTimeTotal: UInt32; stdcall;
    function GetExecutionCount: Int32; stdcall;
    function GetDisabled: Boolean; stdcall;

    procedure SetTimeLeft(Value: UInt32); stdcall;
    procedure SetTimeTotal(Value: UInt32); stdcall;
    procedure SetExecutionCount(Value: Int32); stdcall;
    procedure SetDisabled(Value: Boolean); stdcall;

    property TimeLeft: UInt32 read GetTimeLeft write SetTimeLeft;
    property TimeTotal: UInt32 read GetTimeTotal write SetTimeTotal;
    property ExecutionCount: Int32 read GetExecutionCount write SetExecutionCount;
    property Disabled: Boolean read GetDisabled write SetDisabled;
  end;

  {$M+}
  YDbPersistentTimerEntry = class(YDbSerializable, ISerializable, IPersistentTimerEntry)
    private
      FExecutionCount: Int32;
      FTimeLeft: Int32;
      FTimeTotal: Int32;
      FDisabled: Boolean;
    protected
      procedure Assign(const Entry: ISerializable); override;

      function GetTimeLeft: UInt32; stdcall;
      function GetTimeTotal: UInt32; stdcall;
      function GetExecutionCount: Int32; stdcall;
      function GetDisabled: Boolean; stdcall;

      procedure SetTimeLeft(Value: UInt32); stdcall;
      procedure SetTimeTotal(Value: UInt32); stdcall;
      procedure SetExecutionCount(Value: Int32); stdcall;
      procedure SetDisabled(Value: Boolean); stdcall;
    published
      property TimeLeft: Int32 read FTimeLeft write FTimeLeft;
      property TimeTotal: Int32 read FTimeTotal write FTimeTotal;
      property ExecutionCount: Int32 read FExecutionCount write FExecutionCount;
      property Disabled: Boolean read FDisabled write FDisabled;
  end;
  {$M-}

implementation

uses
  Cores,
  Framework,
  Bfg.Unicode;

{ YDbSerializable }

function YDbSerializable.GetContext(Name: PChar): IDofStreamable;
begin
  Result := FContexts.GetValue(Name) as IDofStreamable;
end;

function YDbSerializable.GetStorageContext: Pointer;
begin
  Result := FStorageContext;
end;

procedure YDbSerializable.SetContext(Name: PChar; const Value: IDofStreamable);
begin
  FContexts.PutValue(Name, Value);
end;

procedure YDbSerializable.SetStorageContext(Value: Pointer);
begin
  FStorageContext := Value;
end;

procedure YDbSerializable.SetUniqueId(Id: UInt32);
begin
  FId := Id;
end;

procedure YDbSerializable.WriteContexts(const Writer: IDofWriter);
var
  Itr: IIntfIterator;
  Keys: IStrIterator;
  Streamable: IDofStreamable;
begin
  Itr := FContexts.Values;
  Keys := FContexts.KeySet;
  Writer.WriteCollectionStart;
  while Itr.HasNext do
  begin
    Writer.WriteCollectionItemStart;
    Writer.WriteString(Keys.Next);
    Streamable.WriteCustomProperties(Writer);
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
  Obj: TInterfacedObject;
  Str: AnsiString;
begin
  Reader.ReadCollectionStart;
  while not Reader.IsCollectionEnd do
  begin
    Reader.ReadCollectionItemStart;
    Str := Reader.ReadString;
    Reader.ReadClass(Obj, nil);
    if Obj <> nil then
    begin
      FContexts.PutValue(Str, Obj as IDofStreamable);
    end;
    Reader.ReadCollectionItemEnd;
  end;
  Reader.ReadCollectionEnd;
end;

procedure YDbSerializable.ReadCustomProperties(const Reader: IDofReader);
begin
  Reader.ReadCustomProperty('Contexts', ReadContexts);
end;

function YDbSerializable.GetUniqueId: UInt32;
begin
  Result := FId;
end;

procedure YDbSerializable.Initialize;
begin
  if not Assigned(FContexts) then FContexts := TStrIntfHashMap.Create(False, 16);
end;

procedure YDbSerializable.Assign(const Entry: ISerializable);
begin
  FId := Entry.UniqueId;
end;

procedure YDbSerializable.Clear;
begin
  if Assigned(FContexts) then FContexts.Clear;
end;

destructor YDbSerializable.Destroy;
begin
  FContexts.Free;

  inherited Destroy;
end;

{ YDbPlayerTemplate }

function ParseStartingItemDef(const Str: string;
  out Item: TStartingItemInfo): Boolean;
var
  P: PChar;
  P2: PChar;
  Temp: string;
  V: Longword;
begin
  Result := False;
  P := Pointer(Str);
  if P^ <> '(' then Exit;
  Inc(P);

  // Skip white space
  while P^ = ' ' do Inc(P);

  P2 := P;
  // Advance untill end of string, space or delimiter is found
  while not (P^ in [#0, ' ', ',']) do Inc(P);
  // If this is the end of string we bail out
  if P^ = #0 then Exit;

  // Copy the result into temp, try to convert it and if successful we continue
  SetString(Temp, P2, P - P2);
  if not TryStrToUInt(Temp, V) then Exit;
  Item.ItemId := V;

  while P^ = ' ' do Inc(P);
  // There must be a delimiter following
  if P^ <> ',' then Exit;
  Inc(P);

  while P^ = ' ' do Inc(P);
  P2 := P;

  while not (P^ in [#0, ' ', ',']) do Inc(P);
  if P^ = #0 then Exit;

  SetString(Temp, P2, P - P2);
  if not TryStrToUInt(Temp, V) then Exit;
  Item.EquipmentSlot := V;

  while P^ = ' ' do Inc(P);
  if P^ <> ',' then Exit;
  Inc(P);

  while P^ = ' ' do Inc(P);
  P2 := P;

  while not (P^ in [#0, ' ', ')']) do Inc(P);
  if P^ = #0 then Exit;

  SetString(Temp, P2, P - P2);
  if not TryStrToUInt(Temp, V) then Exit;
  Item.ItemCount := V;

  while P^ = ' ' do Inc(P);
  // If this is missing/different then the syntax is wrong
  if P^ <> ')' then Exit;

  Result := True;
end;

function ParseStartingSkillDef(const Str: string;
  out Skill: TStartingSkillInfo): Boolean;
var
  P: PChar;
  P2: PChar;
  Temp: string;
  V: Longword;
begin
  Result := False;
  P := Pointer(Str);
  if P^ <> '(' then Exit;
  Inc(P);

  // Skip white space
  while P^ = ' ' do Inc(P);

  P2 := P;
  // Advance untill end of string, space or delimiter is found
  while not (P^ in [#0, ' ', ',']) do Inc(P);
  // If this is the end of string we bail out
  if P^ = #0 then Exit;

  // Copy the result into temp, try to convert it and if successful we continue
  SetString(Temp, P2, P - P2);
  if not TryStrToUInt(Temp, V) then Exit;
  Skill.SkillId := V;

  while P^ = ' ' do Inc(P);
  // There must be a delimiter following
  if P^ <> ',' then Exit;
  Inc(P);

  while P^ = ' ' do Inc(P);
  P2 := P;

  while not (P^ in [#0, ' ', ',']) do Inc(P);
  if P^ = #0 then Exit;

  SetString(Temp, P2, P - P2);
  if not TryStrToUInt(Temp, V) then Exit;
  Skill.SkillInitial := V;

  while P^ = ' ' do Inc(P);
  if P^ <> ',' then Exit;
  Inc(P);

  while P^ = ' ' do Inc(P);
  P2 := P;

  while not (P^ in [#0, ' ', ')']) do Inc(P);
  if P^ = #0 then Exit;

  SetString(Temp, P2, P - P2);
  if not TryStrToUInt(Temp, V) then Exit;
  Skill.SkillMax := V;

  while P^ = ' ' do Inc(P);
  // If this is missing/different then the syntax is wrong
  if P^ <> ')' then Exit;

  Result := True;
end;

function ParseStartingActionButtonDef(const Str: string;
  out Button: TStartingActionButtonInfo): Boolean;
var
  P: PChar;
  P2: PChar;
  Temp: string;
  V: Longword;
begin
  Result := False;
  P := Pointer(Str);
  if P^ <> '(' then Exit;
  Inc(P);

  // Skip white space
  while P^ = ' ' do Inc(P);

  P2 := P;
  // Advance untill end of string, space or delimiter is found
  while not (P^ in [#0, ' ', ',']) do Inc(P);
  // If this is the end of string we bail out
  if P^ = #0 then Exit;

  // Copy the result into temp, try to convert it and if successful we continue
  SetString(Temp, P2, P - P2);
  if not TryStrToUInt(Temp, V) then Exit;
  Button.Action := V;

  while P^ = ' ' do Inc(P);
  // There must be a delimiter following
  if P^ <> ',' then Exit;
  Inc(P);

  while P^ = ' ' do Inc(P);
  P2 := P;

  while not (P^ in [#0, ' ', ',']) do Inc(P);
  if P^ = #0 then Exit;

  SetString(Temp, P2, P - P2);
  if not TryStrToUInt(Temp, V) then Exit;
  Button.ButtonType := V;

  while P^ = ' ' do Inc(P);
  if P^ <> ',' then Exit;
  Inc(P);

  while P^ = ' ' do Inc(P);
  P2 := P;

  while not (P^ in [#0, ' ', ')']) do Inc(P);
  if P^ = #0 then Exit;

  SetString(Temp, P2, P - P2);
  if not TryStrToUInt(Temp, V) then Exit;
  Button.Misc := V;

  while P^ = ' ' do Inc(P);
  // If this is missing/different then the syntax is wrong
  if P^ <> ')' then Exit;

  Result := True;
end;

procedure YDbPlayerTemplate.AfterLoad;
var
  Parsed: TStringDynArray;
  I, J: Integer;
  Temp: Integer;
begin
  // Parsing list of spell ids
  if FSpellStr <> '' then
  begin
    Parsed := StringSplit(FSpellStr, ';');

    SetLength(FSpells, Length(Parsed));
    J := 0;
    for I := 0 to Length(Parsed) -1 do
    begin
      if TryStrToUInt(Trim(Parsed[I]), FSpells[J].SpellId) then
      begin
        Inc(J);
      end;
    end;

    if J <> Length(FSpells) then SetLength(FSpells, J);
  end;

  // Parsing list of items
  if FItemStr <> '' then
  begin
    Parsed := StringSplit(FItemStr, ';');

    SetLength(FItems, Length(Parsed));
    J := 0;
    for I := 0 to Length(Parsed) -1 do
    begin
      if ParseStartingItemDef(Trim(Parsed[I]), FItems[J]) then
      begin
        Inc(J);
      end;
    end;

    if J <> Length(FItems) then SetLength(FItems, J);
  end;

  // Parsing list of skills
  if FSkillStr <> '' then
  begin
    Parsed := StringSplit(FSkillStr, ';');

    SetLength(FSkills, Length(Parsed));
    J := 0;
    for I := 0 to Length(Parsed) -1 do
    begin
      if ParseStartingSkillDef(Trim(Parsed[I]), FSkills[J]) then
      begin
        Inc(J);
      end;
    end;

    if J <> Length(FSkills) then SetLength(FSkills, J);
  end;

  // Parsing list of action buttons
  if FActionButtonStr <> '' then
  begin
    Parsed := StringSplit(FActionButtonStr, ';');

    SetLength(FActionButtons, Length(Parsed));
    J := 0;
    for I := 0 to Length(Parsed) -1 do
    begin
      if ParseStartingActionButtonDef(Trim(Parsed[I]), FActionButtons[J]) then
      begin
        Inc(J);
      end;
    end;

    if J <> Length(FActionButtons) then SetLength(FActionButtons, J);
  end;
end;

procedure YDbPlayerTemplate.BeforeSave;
begin
  // atm read-only, in the future for the sake of completeness we'll implement this
end;

procedure YDbPlayerTemplate.Assign(const Entry: ISerializable);
var
  Player: IPlayerTemplateEntry;
  CapturedContext: TDbPlayerTemplateDataN;
begin
  inherited Assign(Entry);
  if Entry.QueryInterface(IPlayerTemplateEntry, Player) <> S_OK then Exit;

  Player.StoreEntryContents(CapturedContext, DB_PLAYERTEMP_FLAG_NATIVE);
  LoadEntryContents(CapturedContext, DB_PLAYERTEMP_FLAG_NATIVE);
end;

function YDbPlayerTemplate.GetAttackPower: UInt32;
begin
  Result := FAttackPower;
end;

function YDbPlayerTemplate.GetAttackTimeHi: UInt32;
begin
  Result := FAttackTimeHi;
end;

function YDbPlayerTemplate.GetAttackTimeLo: UInt32;
begin
  Result := FAttackTimeLo;
end;

function YDbPlayerTemplate.GetAttackDamageHi: UInt32;
begin
  Result := FAttackDamageHi;
end;

function YDbPlayerTemplate.GetAttackDamageLo: UInt32;
begin
  Result := FAttackDamageLo;
end;

function YDbPlayerTemplate.GetBaseHealth: UInt32;
begin
  Result := FBaseHealth;
end;

function YDbPlayerTemplate.GetBasePower: UInt32;
begin
  Result := FBasePower;
end;

function YDbPlayerTemplate.GetBodySize: Float;
begin
  Result := FBodySize;
end;

function YDbPlayerTemplate.GetClass: PAnsiChar;
begin
  Result := PAnsiChar(FClass);
end;

function YDbPlayerTemplate.GetClassN: AnsiString;
begin
  Result := FClass;
end;

function YDbPlayerTemplate.GetFemaleBodyModel: UInt32;
begin
  Result := FFemaleBody;
end;

function YDbPlayerTemplate.GetInitialAgility: UInt32;
begin
  Result := FAgility;
end;

function YDbPlayerTemplate.GetInitialIntellect: UInt32;
begin
  Result := FIntellect;
end;

function YDbPlayerTemplate.GetInitialSpirit: UInt32;
begin
  Result := FSpirit;
end;

function YDbPlayerTemplate.GetInitialStamina: UInt32;
begin
  Result := FStamina;
end;

function YDbPlayerTemplate.GetInitialStrength: UInt32;
begin
  Result := FStrength;
end;

function YDbPlayerTemplate.GetMaleBodyModel: UInt32;
begin
  Result := FMaleBody;
end;

function YDbPlayerTemplate.GetMapId: UInt32;
begin
  Result := FMapId;
end;

function YDbPlayerTemplate.GetPower: UInt32;
begin
  Result := FPower;
end;

function YDbPlayerTemplate.GetPowerType: UInt32;
begin
  Result := FPowerType;
end;

function YDbPlayerTemplate.GetRace: PChar;
begin
  Result := PChar(FRace);
end;

function YDbPlayerTemplate.GetRaceN: AnsiString;
begin
  Result := FRace;
end;

function YDbPlayerTemplate.GetStartingAngle: Float;
begin
  Result := FO;
end;

function YDbPlayerTemplate.GetStartingX: Float;
begin
  Result := FX;
end;

function YDbPlayerTemplate.GetStartingY: Float;
begin
  Result := FY;
end;

function YDbPlayerTemplate.GetStartingZ: Float;
begin
  Result := FZ;
end;

function YDbPlayerTemplate.GetZoneId: UInt32;
begin
  Result := FZoneId;
end;

procedure YDbPlayerTemplate.SetAttackPower(Value: UInt32);
begin
  FAttackPower := Value;
end;

procedure YDbPlayerTemplate.SetAttackTimeHi(Value: UInt32);
begin
  FAttackTimeHi := Value;
end;

procedure YDbPlayerTemplate.SetAttackTimeLo(Value: UInt32);
begin
  FAttackTimeLo := Value;
end;

procedure YDbPlayerTemplate.SetAttackDamageHi(Value: UInt32);
begin
  FAttackDamageHi := Value;
end;

procedure YDbPlayerTemplate.SetAttackDamageLo(Value: UInt32);
begin
  FAttackDamageLo := Value;
end;

procedure YDbPlayerTemplate.SetBaseHealth(Value: UInt32);
begin
  FBaseHealth := Value;
end;

procedure YDbPlayerTemplate.SetBasePower(Value: UInt32);
begin
  FBasePower := Value;
end;

procedure YDbPlayerTemplate.SetBodySize(Value: Float);
begin
  FBodySize := Value;
end;

procedure YDbPlayerTemplate.SetClass(Value: PChar);
begin
  FClass := Value;
end;

procedure YDbPlayerTemplate.SetClassN(const Value: AnsiString);
begin
  FClass := Value;
end;

procedure YDbPlayerTemplate.SetFemaleBodyModel(Value: UInt32);
begin
  FFemaleBody := Value;
end;

procedure YDbPlayerTemplate.SetInitialAgility(Value: UInt32);
begin
  FAgility := Value;
end;

procedure YDbPlayerTemplate.SetInitialIntellect(Value: UInt32);
begin
  FIntellect := Value;
end;

procedure YDbPlayerTemplate.SetInitialSpirit(Value: UInt32);
begin
  FSpirit := Value;
end;

procedure YDbPlayerTemplate.SetInitialStamina(Value: UInt32);
begin
  FStamina := Value;
end;

procedure YDbPlayerTemplate.SetInitialStrength(Value: UInt32);
begin
  FStrength := Value;
end;

procedure YDbPlayerTemplate.SetMaleBodyModel(Value: UInt32);
begin
  FMaleBody := Value;
end;

procedure YDbPlayerTemplate.SetMapId(Value: UInt32);
begin
  FMapId := Value;
end;

procedure YDbPlayerTemplate.SetPower(Value: UInt32);
begin
  FPower := Value;
end;

procedure YDbPlayerTemplate.SetPowerType(Value: UInt32);
begin
  FPowerType := Value;
end;

procedure YDbPlayerTemplate.SetRace(Value: PChar);
begin
  FRace := Value;
end;

procedure YDbPlayerTemplate.SetRaceN(const Value: AnsiString);
begin
  FRace := Value;
end;

procedure YDbPlayerTemplate.SetStartingAngle(Value: Float);
begin
  FO := Value;
end;

procedure YDbPlayerTemplate.SetStartingX(Value: Float);
begin
  FX := Value;
end;

procedure YDbPlayerTemplate.SetStartingY(Value: Float);
begin
  FY := Value;
end;

procedure YDbPlayerTemplate.SetStartingZ(Value: Float);
begin
  FZ := Value;
end;

procedure YDbPlayerTemplate.SetZoneId(Value: UInt32);
begin
  FZoneId := Value;
end;

procedure YDbPlayerTemplate.LoadEntryContents(const Data; Flags: Longword);
var
  Dest: PDbPlayerTemplateData;
  DestN: PDbPlayerTemplateDataN;
begin
  // Unimplemented yet
  if (Flags and DB_PLAYERTEMP_FLAG_NATIVE) <> 0 then
  begin

  end else
  begin
    
  end;
end;

procedure YDbPlayerTemplate.StoreEntryContents(var Data; Flags: Longword);
var
  Dest: PDbPlayerTemplateData;
  DestN: PDbPlayerTemplateDataN;
  I: Integer;
begin
  if (Flags and DB_PLAYERTEMP_FLAG_NATIVE) <> 0 then
  begin
    if (Flags and DB_PLAYERTEMP_FLAG_LOOKAT) <> 0 then
    begin
      Dest.RaceStrLen := Length(FRace) + 1;
      Dest.ClassStrLen := Length(FClass) + 1;
      Dest.StartingSpellCount := Length(FSpells);
      Dest.StartingItemCount:= Length(FItems);
      Dest.StartingSkillCount := Length(FSkills);
    end else
    begin
      if (Flags and DB_PLAYERTEMP_FLAG_ONLYDYNAMIC) <> 0 then
      begin
        if Assigned(Dest.RaceStr) then
        begin
          StrPLCopy(Dest.RaceStr, FRace, Dest.RaceStrLen);
        end;

        if Assigned(Dest.ClassStr) then
        begin
          StrPLCopy(Dest.ClassStr, FClass, Dest.ClassStrLen);
        end;

        if Assigned(Dest.StartingSpells) then
        begin
          I := Min(Length(FSpells), Dest.StartingSkillCount);
          Move(FSpells[0], Dest.StartingSpells^, I * SizeOf(TStartingSpellInfo));
          Dest.StartingSpellCount := I;
        end;

        if Assigned(Dest.StartingItems) then
        begin
          I := Min(Length(FItems), Dest.StartingItemCount);
          Move(FItems[0], Dest.StartingItems^, I * SizeOf(TStartingItemInfo));
          Dest.StartingItemCount := I;
        end;

        if Assigned(Dest.StartingSkills) then
        begin
          I := Min(Length(FSkills), Dest.StartingSkillCount);
          Move(FSkills[0], Dest.StartingSkills^, I * SizeOf(TStartingSkillInfo));
          Dest.StartingSkillCount := I;
        end;
      end else
      begin
        Dest := @Data;

        if Assigned(Dest.RaceStr) then
        begin
          StrPLCopy(Dest.RaceStr, FRace, Dest.RaceStrLen);
        end;

        if Assigned(Dest.ClassStr) then
        begin
          StrPLCopy(Dest.ClassStr, FClass, Dest.ClassStrLen);
        end;

        Dest.StartingMapId := FMapId;
        Dest.StartingX := FX;
        Dest.StartingY := FY;
        Dest.StartingZ := FZ;
        Dest.StartingAngle := FO;
        Dest.StartingStrength := FStrength;
        Dest.StartingAgility := FAgility;
        Dest.StartingStamina := FStamina;
        Dest.StartingIntellect := FIntellect;
        Dest.StartingSpirit := FSpirit;
        Dest.ModelMale := FMaleBody;
        Dest.ModelFemale := FFemaleBody;
        Dest.ModelSize := FBodySize;
        Dest.HealthBase := Self.FBaseHealth;
        Dest.PowerType := FPowerType;
        Dest.PowerBase := FBasePower;
        Dest.AttackTimeBase[0] := FAttackTimeLo;
        Dest.AttackTimeBase[1] := FAttackTimeHi;
        Dest.AttackDamageBase[0] := FAttackDamageLo;
        Dest.AttackDamageBase[1] := FAttackDamageHi;
        Dest.AttackPowerBase := FAttackPower;

        if Assigned(Dest.StartingSpells) then
        begin
          I := Min(Length(FSpells), Dest.StartingSkillCount);
          Move(FSpells[0], Dest.StartingSpells^, I * SizeOf(TStartingSpellInfo));
          Dest.StartingSpellCount := I;
        end;

        if Assigned(Dest.StartingItems) then
        begin
          I := Min(Length(FItems), Dest.StartingItemCount);
          Move(FItems[0], Dest.StartingItems^, I * SizeOf(TStartingItemInfo));
          Dest.StartingItemCount := I;
        end;

        if Assigned(Dest.StartingSkills) then
        begin
          I := Min(Length(FSkills), Dest.StartingSkillCount);
          Move(FSkills[0], Dest.StartingSkills^, I * SizeOf(TStartingSkillInfo));
          Dest.StartingSkillCount := I;
        end;
      end;
    end;
  end else if (Flags and DB_PLAYERTEMP_FLAG_LOOKAT) = 0 then
  begin
    if (Flags and DB_PLAYERTEMP_FLAG_ONLYDYNAMIC) <> 0 then
    begin
      DestN := @Data;
      DestN.RaceStr := FRace;
      DestN.ClassStr := FClass;
      DestN.StartingMapId := FMapId;
      DestN.StartingX := FX;
      DestN.StartingY := FY;
      DestN.StartingZ := FZ;
      DestN.StartingAngle := FO;
      DestN.StartingStrength := FStrength;
      DestN.StartingAgility := FAgility;
      DestN.StartingStamina := FStamina;
      DestN.StartingIntellect := FIntellect;
      DestN.StartingSpirit := FSpirit;
      DestN.ModelMale := FMaleBody;
      DestN.ModelFemale := FFemaleBody;
      DestN.ModelSize := FBodySize;
      DestN.HealthBase := Self.FBaseHealth;
      DestN.PowerType := FPowerType;
      DestN.PowerBase := FBasePower;
      DestN.AttackTimeBase[0] := FAttackTimeLo;
      DestN.AttackTimeBase[1] := FAttackTimeHi;
      DestN.AttackDamageBase[0] := FAttackDamageLo;
      DestN.AttackDamageBase[1] := FAttackDamageHi;
      DestN.AttackPowerBase := FAttackPower;
      DestN.StartingSkills := FSkills;
      DestN.StartingSpells := FSpells;
      DestN.StartingItems := FItems;
    end else
    begin
      DestN.RaceStr := FRace;
      DestN.ClassStr := FClass;
      DestN.StartingSkills := FSkills;
      DestN.StartingSpells := FSpells;
      DestN.StartingItems := FItems;
    end;
  end;
end;

{ YDbCreatureTemplate }

procedure YDbCreatureTemplate.Assign(const Entry: ISerializable);
var
  Creature: ICreatureTemplateEntry;
begin
  inherited Assign(Entry);
  if not Entry.QueryInterface(ICreatureTemplateEntry, Creature) <> S_OK then Exit;

  FEntryName := Creature.EntryName;
  FEntryGuildName := Creature.EntryGuildName;
  FEntrySubName := Creature.EntrySubName;
  FModelId := Creature.ModelId;
  FMaxHealth := Creature.MaxHealth;
  FMaxMana := Creature.MaxMana;
  FLevel := Creature.Level;
  FMaximumLevel := Creature.MaximumLevel;
  FArmor := Creature.Armor;
  FFaction := Creature.Faction;
  //FNPCFlags := Creature.NPCFlags;
  FRank := Creature.Rank;
  FFamily := Creature.Family;
  FGender := Creature.Gender;
  FBaseAttackPower := Creature.BaseAttackPower;
  FBaseAttackTime := Creature.BaseAttackTime;
  FRangedAttackPower := Creature.RangedAttackPower;
  FRangedAttackTime := Creature.RangedAttackTime;
  //FFlags := Creature.Flags;
  FDynamicFlags := Creature.DynamicFlags;
  FUnitClass := Creature.UnitClass;
  FTrainerType := Creature.TrainerType;
  FMountID := Creature.MountID;
  //FType := Creature.Type;
  FCivilian := Creature.Civilian;
  FElite := Creature.Elite;
  FUnitType := Creature.UnitType;
  FUnitFlags := Creature.UnitFlags;
  FMovementSpeed := Creature.MovementSpeed;
  FDamageMin := Creature.DamageMin;
  FDamageMax := Creature.DamageMax;
  FRangeDamageMin := Creature.RangeDamageMin;
  FRangeDamageMax := Creature.RangeDamageMax;
  //FScale := Creature.Scale;
  FBoundingRadius := Creature.BoundingRadius;
  FCombatReach := Creature.CombatReach;
  //FEquipModel0 := Creature.EquipModel0;
  //FEquipModel1 := Creature.EquipModel1;
  //FEquipModel2 := Creature.EquipModel2;
  //FEquipInfo0 := Creature.EquipInfo0;
  //FEquipInfo1 := Creature.EquipInfo1;
  //FEquipInfo2 := Creature.EquipInfo2;
  //FEquipSlot0 := Creature.EquipSlot0;
  //FEquipSlot1 := Creature.EquipSlot1;
  //FEquipSlot2 := Creature.EquipSlot2;
  FResistancePhysical := Creature.ResistancePhysical;
  FResistanceHoly := Creature.ResistanceHoly;
  FResistanceFire := Creature.ResistanceFire;
  FResistanceNature := Creature.ResistanceNature;
  FResistanceFrost := Creature.ResistanceFrost;
  FResistanceShadow := Creature.ResistanceShadow;
  FResistanceArcane := Creature.ResistanceArcane;
end;

function YDbCreatureTemplate.GetArmor: UInt32;
begin
  Result := FArmor;
end;

function YDbCreatureTemplate.GetBaseAttackPower: UInt32;
begin
  Result := FBaseAttackPower;
end;

function YDbCreatureTemplate.GetBaseAttackTime: UInt32;
begin
  Result := FBaseAttackTime;
end;

function YDbCreatureTemplate.GetBoundingRadius: Float;
begin
  Result := FBoundingRadius;
end;

function YDbCreatureTemplate.GetCivilian: UInt32;
begin
  Result := FCivilian;
end;

function YDbCreatureTemplate.GetCombatReach: Float;
begin
  Result := FCombatReach;
end;

function YDbCreatureTemplate.GetDamageMax: Float;
begin
  Result := FDamageMax;
end;

function YDbCreatureTemplate.GetDamageMin: Float;
begin
  Result := FDamageMin;
end;

function YDbCreatureTemplate.GetDynamicFlags: UInt32;
begin
  Result := FDynamicFlags;
end;

function YDbCreatureTemplate.GetElite: UInt32;
begin
  Result := FElite;
end;

function YDbCreatureTemplate.GetEntryGuildName: PWideChar;
begin
  Result := PWideChar(FEntryGuildName);
end;

function YDbCreatureTemplate.GetEntryGuildNameN: WideString;
begin
  Result := FEntryGuildName;
end;

function YDbCreatureTemplate.GetEntryName: PWideChar;
begin
  Result := PWideChar(FEntryName);
end;

function YDbCreatureTemplate.GetEntryNameN: WideString;
begin
  Result := FEntryName;
end;

function YDbCreatureTemplate.GetEntrySubName: PWideChar;
begin
  Result := PWideChar(FEntrySubName);
end;

function YDbCreatureTemplate.GetEntrySubNameN: WideString;
begin
  Result := FEntrySubName;
end;

function YDbCreatureTemplate.GetFaction: UInt32;
begin
  Result := FFaction;
end;

function YDbCreatureTemplate.GetFamily: UInt32;
begin
  Result := FFamily;
end;

function YDbCreatureTemplate.GetFlags: UInt32;
begin
  Result := FFlags;
end;

function YDbCreatureTemplate.GetGender: UInt32;
begin
  Result := FGender;
end;

function YDbCreatureTemplate.GetLevel: UInt32;
begin
  Result := FLevel;
end;

function YDbCreatureTemplate.GetMaxHealth: UInt32;
begin
  Result := FMaxHealth;
end;

function YDbCreatureTemplate.GetMaximumLevel: UInt32;
begin
  Result := FMaximumLevel;
end;

function YDbCreatureTemplate.GetMaxMana: UInt32;
begin
  Result := FMaxMana;
end;

function YDbCreatureTemplate.GetModelId: UInt32;
begin
  Result := FModelId;
end;

function YDbCreatureTemplate.GetMountID: UInt32;
begin
  Result := FMountId;
end;

function YDbCreatureTemplate.GetMovementSpeed: Float;
begin
  Result := FMovementSpeed;
end;

function YDbCreatureTemplate.GetNpcFlags: UInt32;
begin
  Result := FNpcFlags;
end;

function YDbCreatureTemplate.GetRangeDamageMax: Float;
begin
  Result := FRangeDamageMax;
end;

function YDbCreatureTemplate.GetRangeDamageMin: Float;
begin
  Result := FRangeDamageMin;
end;

function YDbCreatureTemplate.GetRangedAttackPower: UInt32;
begin
  Result := FRangedAttackPower;
end;

function YDbCreatureTemplate.GetRangedAttackTime: UInt32;
begin
  Result := FRangedAttackTime;
end;

function YDbCreatureTemplate.GetRank: UInt32;
begin
  Result := FRank;
end;

function YDbCreatureTemplate.GetResistanceArcane: UInt32;
begin
  Result := FResistanceArcane;
end;

function YDbCreatureTemplate.GetResistanceFire: UInt32;
begin
  Result := FResistanceFire;
end;

function YDbCreatureTemplate.GetResistanceFrost: UInt32;
begin
  Result := FResistanceFrost;
end;

function YDbCreatureTemplate.GetResistanceHoly: UInt32;
begin
  Result := FResistanceHoly;
end;

function YDbCreatureTemplate.GetResistanceNature: UInt32;
begin
  Result := FResistanceNature;
end;

function YDbCreatureTemplate.GetResistancePhysical: UInt32;
begin
  Result := FResistancePhysical;
end;

function YDbCreatureTemplate.GetResistanceShadow: UInt32;
begin
  Result := FResistanceShadow;
end;

function YDbCreatureTemplate.GetScale: Float;
begin
  Result := FScale;
end;

function YDbCreatureTemplate.GetTrainerType: UInt32;
begin
  Result := FTrainerType;
end;

function YDbCreatureTemplate.GetType: UInt32;
begin
  Result := FType;
end;

function YDbCreatureTemplate.GetUnitClass: UInt32;
begin
  Result := FUnitClass;
end;

function YDbCreatureTemplate.GetUnitFlags: UInt32;
begin
  Result := FUnitFlags;
end;

function YDbCreatureTemplate.GetUnitType: UInt32;
begin
  Result := FUnitType;
end;

procedure YDbCreatureTemplate.SetArmor(Value: UInt32);
begin
  FArmor := Value;
end;

procedure YDbCreatureTemplate.SetBaseAttackPower(Value: UInt32);
begin
  FBaseAttackPower := Value;
end;

procedure YDbCreatureTemplate.SetBaseAttackTime(Value: UInt32);
begin
  FBaseAttackTime := Value;
end;

procedure YDbCreatureTemplate.SetBoundingRadius(Value: Float);
begin
  FBoundingRadius := Value;
end;

procedure YDbCreatureTemplate.SetCivilian(Value: UInt32);
begin
  FCivilian := Value;
end;

procedure YDbCreatureTemplate.SetCombatReach(Value: Float);
begin
  FCombatReach := Value;
end;

procedure YDbCreatureTemplate.SetDamageMax(Value: Float);
begin
  FDamageMax := Value;
end;

procedure YDbCreatureTemplate.SetDamageMin(Value: Float);
begin
  FDamageMin := Value;
end;

procedure YDbCreatureTemplate.SetDynamicFlags(Value: UInt32);
begin
  FDynamicFlags := Value;
end;

procedure YDbCreatureTemplate.SetElite(Value: UInt32);
begin
  FElite := Value;
end;

procedure YDbCreatureTemplate.SetEntryGuildName(Value: PWideChar);
begin
  FEntryGuildName := Value;
end;

procedure YDbCreatureTemplate.SetEntryGuildNameN(const Value: WideString);
begin
  FEntryGuildName := Value;
end;

procedure YDbCreatureTemplate.SetEntryName(Value: PWideChar);
begin
  FEntryName := Value;
end;

procedure YDbCreatureTemplate.SetEntryNameN(const Value: WideString);
begin
  FEntryName := Value;
end;

procedure YDbCreatureTemplate.SetEntrySubName(Value: PWideChar);
begin
  FEntrySubName := Value;
end;

procedure YDbCreatureTemplate.SetEntrySubNameN(const Value: WideString);
begin
  FEntrySubName := Value;
end;

procedure YDbCreatureTemplate.SetFaction(Value: UInt32);
begin
  FFaction := Value;
end;

procedure YDbCreatureTemplate.SetFamily(Value: UInt32);
begin
  FFamily := Value;
end;

procedure YDbCreatureTemplate.SetFlags(Value: UInt32);
begin
  FFlags := Value;
end;

procedure YDbCreatureTemplate.SetGender(Value: UInt32);
begin
  FGender := Value;
end;

procedure YDbCreatureTemplate.SetLevel(Value: UInt32);
begin
  FLevel := Value;
end;

procedure YDbCreatureTemplate.SetMaxHealth(Value: UInt32);
begin
  FMaxHealth := Value;
end;

procedure YDbCreatureTemplate.SetMaximumLevel(Value: UInt32);
begin
  FMaximumLevel := Value;
end;

procedure YDbCreatureTemplate.SetMaxMana(Value: UInt32);
begin
  FMaxMana := Value;
end;

procedure YDbCreatureTemplate.SetModelId(Value: UInt32);
begin
  FModelId := Value;
end;

procedure YDbCreatureTemplate.SetMountID(Value: UInt32);
begin
  FMountId := Value;
end;

procedure YDbCreatureTemplate.SetMovementSpeed(Value: Float);
begin
  FMovementSpeed := Value;
end;

procedure YDbCreatureTemplate.SetNpcFlags(Value: UInt32);
begin
  FNpcFlags := Value;
end;

procedure YDbCreatureTemplate.SetRangeDamageMax(Value: Float);
begin
  FRangeDamageMax := Value;
end;

procedure YDbCreatureTemplate.SetRangeDamageMin(Value: Float);
begin
  FRangeDamageMin := Value;
end;

procedure YDbCreatureTemplate.SetRangedAttackPower(Value: UInt32);
begin
  FRangedAttackPower := Value;
end;

procedure YDbCreatureTemplate.SetRangedAttackTime(Value: UInt32);
begin
  FRangedAttackTime := Value;
end;

procedure YDbCreatureTemplate.SetRank(Value: UInt32);
begin
  FRank := Value;
end;

procedure YDbCreatureTemplate.SetResistanceArcane(Value: UInt32);
begin
  FResistanceArcane := Value;
end;

procedure YDbCreatureTemplate.SetResistanceFire(Value: UInt32);
begin
  FResistanceFire := Value;
end;

procedure YDbCreatureTemplate.SetResistanceFrost(Value: UInt32);
begin
  FResistanceFrost := Value;
end;

procedure YDbCreatureTemplate.SetResistanceHoly(Value: UInt32);
begin
  FResistanceHoly := Value;
end;

procedure YDbCreatureTemplate.SetResistanceNature(Value: UInt32);
begin
  FResistanceNature := Value;
end;

procedure YDbCreatureTemplate.SetResistancePhysical(Value: UInt32);
begin
  FResistancePhysical := Value;
end;

procedure YDbCreatureTemplate.SetResistanceShadow(Value: UInt32);
begin
  FResistanceShadow := Value;
end;

procedure YDbCreatureTemplate.SetScale(Value: Float);
begin
  FScale := Value;
end;

procedure YDbCreatureTemplate.SetTrainerType(Value: UInt32);
begin
  FTrainerType := Value;
end;

procedure YDbCreatureTemplate.SetType(Value: UInt32);
begin
  FType := Value;
end;

procedure YDbCreatureTemplate.SetUnitClass(Value: UInt32);
begin
  FUnitClass := Value;
end;

procedure YDbCreatureTemplate.SetUnitFlags(Value: UInt32);
begin
  FUnitFlags := Value;
end;

procedure YDbCreatureTemplate.SetUnitType(Value: UInt32);
begin
  FUnitType := Value;
end;

{ YDbGameObjectTemplate }

procedure YDbGameObjectTemplate.Assign(const Entry: ISerializable);
var
  Go: IGameObjectTemplateEntry;
begin
  inherited Assign(Entry);
  if Entry.QueryInterface(IGameObjectTemplateEntry, Go) <> S_OK then Exit;

  FType := Go.GoType;
  FModelId := Go.ModelId;
  FFaction := Go.Faction;
  FFlags := Go.Flags;
  FSize := Go.Size;
  //fSounds := Go.fSounds;
  FName := Go.Name;
end;

function YDbGameObjectTemplate.GetFaction: UInt32;
begin
  Result := FFaction;
end;

function YDbGameObjectTemplate.GetFlags: UInt32;
begin
  Result := FFlags;
end;

function YDbGameObjectTemplate.GetModelId: UInt32;
begin
  Result := FModelId;
end;

function YDbGameObjectTemplate.GetName: PWideChar;
begin
  Result := PWideChar(FName);
end;

function YDbGameObjectTemplate.GetNameN: WideString;
begin
  Result := FName;
end;

function YDbGameObjectTemplate.GetSize: Float;
begin
  Result := FSize;
end;

function YDbGameObjectTemplate.GetSound(iIndex: Int32): UInt32;
begin
  if iIndex > 11 then Result := 0 else Result := FSounds[iIndex];
end;

function YDbGameObjectTemplate.GetType: UInt32;
begin
  Result := FType;
end;

procedure YDbGameObjectTemplate.SetFaction(Value: UInt32);
begin
  FFaction := Value;
end;

procedure YDbGameObjectTemplate.SetFlags(Value: UInt32);
begin
  FFlags := Value;
end;

procedure YDbGameObjectTemplate.SetModelId(Value: UInt32);
begin
  FModelId := Value;
end;

procedure YDbGameObjectTemplate.SetName(Value: PWideChar);
begin
  FName := Value;
end;

procedure YDbGameObjectTemplate.SetNameN(const Value: WideString);
begin
  FName := Value;
end;

procedure YDbGameObjectTemplate.SetSize(Value: Float);
begin
  FSize := Value;
end;

procedure YDbGameObjectTemplate.SetType(Value: UInt32);
begin
  FType := Value;
end;

(*

{ YDbQuestTemplate }

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

*)

(*

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

*)

{ YDbAccountEntry }

procedure YDbAccountEntry.Assign(const Entry: ISerializable);
var
  Acc: IAccountEntry;
begin
  inherited Assign(Entry);
  if Entry.QueryInterface(IAccountEntry, Acc) <> S_OK then Exit;

  FName := Acc.Name;
  FPass := Acc.Pass;
  FHash := Acc.Hash;
  FLoggedIn := Acc.LoggedIn;
  FAutoCreated := Acc.AutoCreated;
  FAccess := Acc.Access;
  FStatus := Acc.Status;
end;

{ YUpdateable }

procedure YDbWowObjectEntry.Assign(const Entry: ISerializable);
var
  WowObj: IWowObjectEntry;
begin
  inherited Assign(Entry);
  if Entry.QueryInterface(IWowObjectEntry, WowObj) <> S_OK then Exit;
  
  SetLength(FUpdateData, WowObj.GetUpdateDataLength);
  WowObj.GetUpdateData(@FUpdateData[0]);

  //SetLength(fTimers, Length(cUpd.fTimers));
  //Move(cUpd.fTimers[0], fTimers[0], Length(fTimers) * SizeOf(UInt32));
end;

procedure YDbWowObjectEntry.GetUpdateData(Buffer: PUInt32);
begin
  Move(FUpdateData[0], Buffer^, SizeOf(UInt32) * Length(FUpdateData));
end;

function YDbWowObjectEntry.GetUpdateDataLength: Int32;
begin
  Result := Length(FUpdateData);
end;

procedure YDbWowObjectEntry.SetUpdateData(Buffer: PUInt32; Length: Int32);
begin
  SetLength(FUpdateData, Length);
  Move(Buffer^, FUpdateData[0], Length * SizeOf(UInt32));
end;

{ YDbItemEntry }

procedure YDbItemEntry.Assign(const Entry: ISerializable);
var
  Item: IItemEntry;
begin
  inherited Assign(Entry);
  if Entry.QueryInterface(IItemEntry, Item) <> S_OK then Exit;

  FEntry := Item.EntryId;
  FStackCount := Item.StackCount;
  FDurability := Item.Durability;
  FContained := Item.ContainedId;
  FCreator := Item.Creator;
  //SetLength(fItemsContained, Length(cItem.fItemsContained));
  //Move(cItem.fItemsContained[0], fItemsContained[0], Length(fItemsContained) * SizeOf(UInt32));
end;

function YDbItemEntry.GetContainedIn: UInt32;
begin
  Result := FContained;
end;

function YDbItemEntry.GetCreator: UInt32;
begin
  Result := FCreator;
end;

function YDbItemEntry.GetDurability: UInt32;
begin
  Result := FDurability;
end;

function YDbItemEntry.GetEntryId: UInt32;
begin
  Result := FEntry;
end;

function YDbItemEntry.GetStackCount: UInt32;
begin
  Result := FStackCount;
end;

procedure YDbItemEntry.SetContainedId(Value: UInt32);
begin
  FContained := Value;
end;

procedure YDbItemEntry.SetCreator(Value: UInt32);
begin
  FCreator := Value;
end;

procedure YDbItemEntry.SetDurability(Value: UInt32);
begin
  FDurability := Value;
end;

procedure YDbItemEntry.SetEntryId(Value: UInt32);
begin
  FEntry := Value;
end;

procedure YDbItemEntry.SetItemsContainedLength(iNewLen: Int32);
begin
  SetLength(fItemsContained, iNewLen);
end;

procedure YDbItemEntry.SetStackCount(Value: UInt32);
begin
  FStackCount := Value;
end;

{ YDbPlayerEntry }

procedure YDbPlayerEntry.Assign(const Entry: ISerializable);
var
  Player: IPlayerEntry;
  Idx: Int32;
begin
  inherited Assign(Entry);
  if Entry.QueryInterface(IPlayerEntry, Player) <> S_OK then Exit;

  FPosX := Player.X;
  FPosY := Player.Y;
  FPosZ := Player.Z;
  FAngle := Player.Angle;
  FZoneId := Player.ZoneId;
  FMapId := Player.MapId;
  FInstanceId := Player.InstanceId;
  FAccount := Player.AccountName;
  FCharName := Player.Name;
  FPrivileges := Player.Privileges;
  FRested := Player.Rested;

  (*
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
  *)
end;

function YDbPlayerEntry.GetAccountName: PWideChar;
begin
  Result := PWideChar(FAccount);
end;

function YDbPlayerEntry.GetAccountNameN: WideString;
begin
  Result := FAccount;
end;

function YDbPlayerEntry.GetAngle: Float;
begin
  Result := FAngle;
end;

function YDbPlayerEntry.GetInstanceId: UInt32;
begin
  Result := FInstanceId;
end;

function YDbPlayerEntry.GetMapId: UInt32;
begin
  Result := FMapId;
end;

function YDbPlayerEntry.GetName: PWideChar;
begin
  Result := PWideChar(FCharName);
end;

function YDbPlayerEntry.GetNameN: WideString;
begin
  Result := FCharName;
end;

function YDbPlayerEntry.GetPrivileges: PChar;
begin
  Result := PChar(FPriviledges);
end;

function YDbPlayerEntry.GetPrivilegesN: AnsiString;
begin
  Result := FPriviledges;
end;

function YDbPlayerEntry.GetRested: UInt32;
begin
  Result := FRested;
end;

function YDbPlayerEntry.GetX: Float;
begin
  Result := FPosX;
end;

function YDbPlayerEntry.GetY: Float;
begin
  Result := FPosY;
end;

function YDbPlayerEntry.GetZ: Float;
begin
  Result := FPosZ;
end;

function YDbPlayerEntry.GetZoneId: UInt32;
begin
  Result := FZoneId;
end;

procedure YDbPlayerEntry.SetAccountName(Value: PWideChar);
begin
  FAccount := Value;
end;

procedure YDbPlayerEntry.SetAccountNameN(const Value: WideString);
begin
  FAccount := Value;
end;

procedure YDbPlayerEntry.SetActionButtonsLength(iNewLen: Int32);
begin
  SetLength(fActionButtons, iNewLen);
end;

procedure YDbPlayerEntry.SetAngle(Value: Float);
begin
  FAngle := Value;
end;

procedure YDbPlayerEntry.SetEquippedItemsLength(iNewLen: Int32);
begin
  SetLength(fEquippedItems, iNewLen);
end;

procedure YDbPlayerEntry.SetHonorStatsLength(iNewLen: Int32);
begin
  SetLength(fHonorStats, iNewLen);
end;

procedure YDbPlayerEntry.SetInstanceId(Value: UInt32);
begin
  FInstanceId := Value;
end;

procedure YDbPlayerEntry.SetMapId(Value: UInt32);
begin
  FMapId := Value;
end;

procedure YDbPlayerEntry.SetName(Value: PWideChar);
begin
  FCharName := Value;
end;

procedure YDbPlayerEntry.SetNameN(const Value: WideString);
begin
  FCharName := Value;
end;

procedure YDbPlayerEntry.SetPriviledgesLength(iNewLen: Int32);
begin
  SetLength(fPriviledges, iNewLen);
end;

procedure YDbPlayerEntry.SetPrivileges(Value: PChar);
begin
  FPriviledges := Value;
end;

procedure YDbPlayerEntry.SetPrivilegesN(const Value: AnsiString);
begin
  FPriviledges := Value;
end;

procedure YDbPlayerEntry.SetRested(Value: UInt32);
begin
  FRested := Value;
end;

procedure YDbPlayerEntry.SetTutorialsLength(iNewLen: Int32);
begin
  SetLength(fTutorials, iNewLen);
end;

procedure YDbPlayerEntry.SetX(Value: Float);
begin
  FPosX := Value;
end;

procedure YDbPlayerEntry.SetY(Value: Float);
begin
  FPosY := Value;
end;

procedure YDbPlayerEntry.SetZ(Value: Float);
begin
  FPosZ := Value;
end;

procedure YDbPlayerEntry.SetZoneId(Value: UInt32);
begin
  FZoneId := Value;
end;

{ YDbAccountEntry }

function YDbAccountEntry.GetAccess: YAccountAccess;
begin
  Result := FAccess;
end;

function YDbAccountEntry.GetAutoCreated: Boolean;
begin
  Result := FAutoCreated;
end;

function YDbAccountEntry.GetHash: YAccountHash;
begin
  Result := FHash;
end;

function YDbAccountEntry.GetLoggedIn: Boolean;
begin
  Result := FLoggedIn;
end;

function YDbAccountEntry.GetName: PWideChar;
begin
  Result := PWideChar(FName);
end;

function YDbAccountEntry.GetNameN: WideString;
begin
  Result := FName;
end;

function YDbAccountEntry.GetPass: PWideChar;
begin
  Result := PWideChar(FPass);
end;

function YDbAccountEntry.GetPassN: WideString;
begin
  Result := FPass;
end;

function YDbAccountEntry.GetStatus: YAccountStatus;
begin
  Result := FStatus;
end;

procedure YDbAccountEntry.SetAccess(Value: YAccountAccess);
begin
  FAccess := Value;
end;

procedure YDbAccountEntry.SetAutoCreated(Value: Boolean);
begin
  FAutoCreated := Value;
end;

procedure YDbAccountEntry.SetHash(Value: YAccountHash);
begin
  FHash := Value;
end;

procedure YDbAccountEntry.SetLoggedIn(Value: Boolean);
begin
  FLoggedIn := Value;
end;

procedure YDbAccountEntry.SetName(Value: PWideChar);
begin
  FName := Value;
end;

procedure YDbAccountEntry.SetNameN(const Value: WideString);
begin
  FName := Value;
end;

procedure YDbAccountEntry.SetPass(Value: PWideChar);
begin
  FPass := Value;
end;

procedure YDbAccountEntry.SetPassN(const Value: WideString);
begin
  FPass := Value;
end;

procedure YDbAccountEntry.SetStatus(Value: YAccountStatus);
begin
  FStatus := Value;
end;

{ YDbNodeEntry }

procedure YDbNodeEntry.Assign(const Entry: ISerializable);
var
  Node: INodeEntry;
begin
  inherited Assign(Entry);
  if Entry.QueryInterface(INodeEntry, Node) <> S_OK then Exit;

  FPosX := Node.X;
  FPosY := Node.Y;
  FPosZ := Node.Z;
  FMapId := Node.MapId;
  FFlags := Node.Flags;
end;

function YDbNodeEntry.GetFlags: YNodeFlags;
begin
  Result := FFlags;
end;

function YDbNodeEntry.GetMapId: UInt32;
begin
  Result := FMapId;
end;

function YDbNodeEntry.GetX: Float;
begin
  Result := FPosX;
end;

function YDbNodeEntry.GetY: Float;
begin
  Result := FPosY;
end;

function YDbNodeEntry.GetZ: Float;
begin
  Result := FPosZ;
end;

procedure YDbNodeEntry.SetFlags(Value: YNodeFlags);
begin
  FFlags := Value;
end;

procedure YDbNodeEntry.SetMapId(Value: UInt32);
begin
  FMapId := Value;
end;

procedure YDbNodeEntry.SetX(Value: Float);
begin
  FPosX := Value;
end;

procedure YDbNodeEntry.SetY(Value: Float);
begin
  FPosY := Value;
end;

procedure YDbNodeEntry.SetZ(Value: Float);
begin
  FPosZ := Value;
end;

{ YDbItemTemplate }

procedure YDbItemTemplate.Assign(const Entry: ISerializable);
var
  Item: IItemTemplateEntry;
begin
  inherited Assign(Entry);
  if Entry.QueryInterface(IItemTemplateEntry, Item) <> S_OK then Exit;

  FClass := Item.MainClass;
  FSubClass := Item.SubClass;
  FModelId := Item.ModelId;
  FQuality := Item.Quality;
  FFlags := Item.Flags;
  FBuyPrice := Item.BuyPrice;
  FSellPrice := Item.SellPrice;
  FInventoryType := Item.InventoryType;
  FAllowedRaces := Item.AllowedRaces;
  FAllowedClasses := Item.AllowedClasses;
  FItemLevel := Item.ItemLevel;
  FReqLevel := Item.ReqLevel;
  FReqSkill := Item.ReqSkill;
  FReqSkillRank := Item.ReqSkillRank;
  FReqSpell := Item.ReqSpell;
  FReqFaction := Item.ReqFaction;
  FReqFactionStanding := Item.ReqFactionLevel;
  FReqPVPRank1 := Item.ReqPVPRank1;
  FReqPVPRank2 := Item.ReqPVPRank2;
  FMaximumCount := Item.MaximumCount;
  FUniqueFlag := Item.UniqueFlag;
  FContainerSlots := Item.ContainerSlots;
  //fStats := Item.Stats;
  //fDamageTypes := Item.DamageTypes;
  FResistancePhysical := Item.ResistancePhysical;
  FResistanceHoly := Item.ResistanceHoly;
  FResistanceFire := Item.ResistanceFire;
  FResistanceNature := Item.ResistanceNature;
  FResistanceFrost := Item.ResistanceFrost;
  FResistanceShadow := Item.ResistanceShadow;
  FResistanceArcane := Item.ResistanceArcane;
  FDelay := Item.Delay;
  FAmmunitionType := Item.AmunitionType;
  //fItemSpells := Item.ItemSpells;
  FBonding := Item.Bonding;
  //fRangeModifier := Item.RangeModifier;
  FPageID := Item.PageID;
  FPageLanguage := Item.PageLanguage;
  FPageMaterial := Item.PageMaterial;
  FStartsQuest := Item.StartsQuest;
  FLockID := Item.LockID;
  FLockMaterial := Item.LockMaterial;
  FSheath := Item.Sheath;
  FExtraInfo := Item.ExtraInfo;
  //fExtraInfo2 := Item.ExtraInfo2;
  FBlock := Item.Block;
  FItemSet := Item.ItemSet;
  FMaximumDurability := Item.MaximumDurability;
  FArea := Item.Area;
  FMapId := Item.MapId;
  FBagType := Item.BagFamily;
  FToolCategory := Item.TotemCategory;
  FSocketColor1 := Item.SocketColor1;
  FUnk2 := Item.SocketUnk1;
  FSocketColor2 := Item.SocketColor2;
  FUnk3 := Item.SocketUnk2;
  FSocketColor3 := Item.SocketColor3;
  FUnk4 := Item.SocketUnk3;
  FSocketBonus := Item.SocketBonus;
  FGemProperties := Item.GemProperties;
  FItemExtendedCost := Item.ItemExtendedCost;
  FDisenchantReqSkill := Item.DisenchantReqSkill;

  FName := Item.Name;
  FNameForQuest := Item.NameForQuest;
  FNameHonorable := Item.NameHonorable;
  FNameEnchanting := Item.NameEnchanting;
  FDescription := Item.Description;
end;

procedure YDbItemTemplate.AfterLoad;
begin
  FNameUTF8 := WideStringToUTF8(FName);

  if FNameForQuest = '' then
  begin
    FNameForQuest := FName;
    FNameForQuestUTF8 := FNameUTF8;
  end else FNameForQuestUTF8 := WideStringToUTF8(FNameForQuest);

  if FNameHonorable = '' then
  begin
    FNameHonorable := FName;
    FNameHonorable := FNameUTF8;
  end else FNameHonorableUTF8 := WideStringToUTF8(FNameHonorable);

  if FNameEnchanting = '' then
  begin
    FNameEnchanting := FName;
    FNameEnchanting := FNameUTF8;
  end else FNameEnchantingUTF8 := WideStringToUTF8(FNameEnchanting);
end;

procedure YDbItemTemplate.BeforeSave;
begin
  { Nothing }
end;

(*
      FClass: YItemClass;
      FSubClass: UInt32;
      FModelId: UInt32;
      FQuality: YItemQuality;
      FFlags: UInt32;
      FBuyPrice: UInt32;
      FSellPrice: UInt32;
      FInventoryType: YItemInventoryType;
      FAllowedRaces: YGameRaces;
      FAllowedClasses: YGameClasses;
      {$IFDEF ITEM_TEMPLATE_HAS_PAD}
      { Do not remove, here for alignment! }
      { It looks scary I know. But all it does is automaticly calculating the number of fill-bytes. }
      FPad1: array[0..SizeOf(UInt32)-((SizeOf(YGameRaces) + SizeOf(YGameClasses)) mod SizeOf(UInt32))-1] of UInt8;
      {$ENDIF}
      FItemLevel: UInt32;
      FReqLevel: UInt32;
      FReqSkill: UInt32;
      FReqSkillRank: UInt32;
      FReqSpell: UInt32;
      FReqFaction: UInt32;
      FReqFactionLevel: UInt32;
      FReqPVPRank1: UInt32;
      FReqPVPRank2: UInt32;
      FUniqueFlag: UInt32;
      FMaximumCount: UInt32;   //the max number of items of this type that a char can have
      FContainerSlots: UInt32;
      FStats: array[0..9] of YStatRec;
      FDamageTypes: array[0..4] of YWeaponDamageRec;
      FResistancePhysical: UInt32;
      FResistanceHoly: UInt32;
      FResistanceFire: UInt32;
      FResistanceNature: UInt32;
      FResistanceFrost: UInt32;
      FResistanceShadow: UInt32;
      FResistanceArcane: UInt32;
      FDelay: UInt32;
      FAmmunitionType: UInt32;  //2 = arrows, 3 = bullets
      FRangeModifier: Float;
      FItemSpells: array[0..__ITEM_FIELD_SPELL_CHARGES - 1] of YItemSpellRec;
      FBonding: UInt32;
      FPageID: UInt32;
      FPageLanguage: UInt32;
      FPageMaterial: UInt32;
      FStartsQuest: UInt32;
      FLockID: UInt32;
      FLockMaterial: UInt32;
      FSheath: UInt32;
      FExtraInfo: UInt32;
      FExtraInfo2: UInt32;
      FBlock: UInt32;
      FItemSet: UInt32;
      FMaximumDurability: UInt32;
      FArea: UInt32;
      FMapId: UInt32;
      FBagFamily: UInt32;
      FTotemCategory: UInt32;
      FSocketColor1: UInt32;
      FUnk2: UInt32;
      FSocketColor2: UInt32;
      FUnk3: UInt32;
      FSocketColor3: UInt32;
      FUnk4: UInt32;
      FSocketBonus: UInt32;
      FGemProperties: UInt32;
      FItemExtendedCost: UInt32;
      FDisenchantReqSkill: UInt32;
      FName: WideString;
      FNameForQuest: WideString;
      FNameHonorable: WideString;
      FNameEnchanting: WideString;
      FDescription: WideString;
      FUnknown206: UInt32; //2.0.6 TODO SELBY - check it later
*)

function YDbItemTemplate.GetInfoBufferRequiredSize: Int32;
begin
  Result := (SizeOf(UInt32) * 60 + SizeOf(FStats) + SizeOf(FDamageTypes) +
    SizeOf(FItemSpells) + 5 + Length(FNameUTF8) + Length(FNameForQuestUTF8) +
    Length(FNameHonorableUTF8) + Length(FNameEnchantingUTF8) + Length(FDescriptionUTF8));
end;

procedure YDbItemTemplate.FillInfoBuffer(Buffer: Pointer);
var
  Temp: Longword;
  Races: YGameRaces absolute Temp;
  Classes: YGameClasses absolute Temp;
  S: Integer;
  B: PUInt32 absolute Buffer;
  I: Integer;
begin
  B^ := FId;
  Inc(B);

  B^ := UInt32(FClass);
  Inc(B);

  B^ := FSubClass;
  Inc(B);

  B^ := 0;
  Inc(B);

  S := (Length(FNameUTF8) + 1) * SizeOf(AnsiChar);
  Move(Pointer(FNameUTF8)^, B^, S);
  Inc(PByte(B), S);

  S := (Length(FNameForQuestUTF8) + 1) * SizeOf(AnsiChar);
  Move(Pointer(FNameForQuestUTF8)^, B^, S);
  Inc(PByte(B), S);

  S := (Length(FNameHonorableUTF8) + 1) * SizeOf(AnsiChar);
  Move(Pointer(FNameHonorableUTF8)^, B^, S);
  Inc(PByte(B), S);

  S := (Length(FNameEnchantingUTF8) + 1) * SizeOf(AnsiChar);
  Move(Pointer(FNameEnchantingUTF8)^, B^, S);
  Inc(PByte(B), S);

  B^ := FModelId;
  Inc(B);

  B^ := UInt32(FQuality);
  Inc(B);

  B^ := FFlags;
  Inc(B);

  B^ := FBuyPrice;
  Inc(B);

  B^ := FSellPrice;
  Inc(B);

  B^ := UInt32(FInventoryType);
  Inc(B);

  Classes := FAllowedClasses;
  if Classes = gcAll then
  begin
    B^ := $FFFFFFFF;
  end else
  begin
    B^ := Temp shr 1;
  end;

  Inc(B);

  Races := FAllowedRaces;
  if Races = grAll then
  begin
    B^ := $FFFFFFFF;
  end else
  begin
    B^ := Temp shr 1;
  end;

  Inc(B);

  B^ := FItemLevel;
  Inc(B);

  B^ := FReqLevel;
  Inc(B);

  B^ := FReqSkill;
  Inc(B);

  B^ := FReqSkillRank;
  Inc(B);

  B^ := FReqSpell;
  Inc(B);

  B^ := FReqPVPRank1;
  Inc(B);

  B^ := FReqPVPRank2;
  Inc(B);

  B^ := FReqFaction;
  Inc(B);

  B^ := FReqFactionStanding;
  Inc(B);

  B^ := FUniqueFlag;
  Inc(B);

  B^ := FMaximumCount;
  Inc(B);

  B^ := FContainerSlots;
  Inc(B);

  Move(FStats, B^, SizeOf(FStats));
  Inc(PByte(B), SizeOf(FStats));

  Move(FDamageTypes, B^, SizeOf(FDamageTypes));
  Inc(PByte(B), SizeOf(FDamageTypes));

  B^ := FResistancePhysical;
  Inc(B);

  B^ := FResistanceHoly;
  Inc(B);

  B^ := FResistanceFire;
  Inc(B);

  B^ := FResistanceNature;
  Inc(B);

  B^ := FResistanceFrost;
  Inc(B);

  B^ := FResistanceShadow;
  Inc(B);

  B^ := FResistanceArcane;
  Inc(B);

  B^ := FDelay;
  Inc(B);

  B^ := FAmmunitionType;
  Inc(B);

  PFloat(B)^ := FRange;
  Inc(B);

  Move(FItemSpells, B^, SizeOf(FItemSpells));
  Inc(PByte(B), SizeOf(FItemSpells));

  B^ := FBonding;
  Inc(B);

  S := (Length(FDescriptionUTF8) + 1) * SizeOf(AnsiChar);
  Move(Pointer(FDescriptionUTF8)^, B^, S);
  Inc(PByte(B), S);

  B^ := FPageId;
  Inc(B);

  B^ := FPageLanguage;
  Inc(B);

  B^ := FPageMaterial;
  Inc(B);

  B^ := FStartsQuest;
  Inc(B);

  B^ := FLockId;
  Inc(B);

  B^ := FLockMaterial;
  Inc(B);

  B^ := 0;
  Inc(B);

  B^ := FExtraInfo;
  Inc(B);

  B^ := FExtraInfo2;
  Inc(B);

  B^ := FBlock;
  Inc(B);

  B^ := FItemSet;
  Inc(B);

  B^ := FMaximumDurability;
  Inc(B);

  B^ := FArea;
  Inc(B);

  B^ := 0;
  Inc(B);

  B^ := FBagType;
  Inc(B);

  B^ := FToolCategory;
  Inc(B);

  B^ := FSocketColor1;
  Inc(B);

  B^ := 0;
  Inc(B);

  B^ := FSocketColor2;
  Inc(B);

  B^ := 0;
  Inc(B);

  B^ := FSocketColor3;
  Inc(B);

  B^ := FSocketBonus;
  Inc(B);

  B^ := FItemExtendedCost;
  Inc(B);

  B^ := FDisenchantReqSkill;
  Inc(B);

  B^ := 0;
end;

function YDbItemTemplate.GetAllowedClasses: YGameClasses;
begin
  Result := FAllowedClasses;
end;

function YDbItemTemplate.GetAllowedRaces: YGameRaces;
begin
  Result := FAllowedRaces;
end;

function YDbItemTemplate.GetAmunitionType: UInt32;
begin
  Result := FAmmunitionType;
end;

function YDbItemTemplate.GetArea: UInt32;
begin
  Result := FArea;
end;

function YDbItemTemplate.GetBagFamily: UInt32;
begin
  Result := FBagType;
end;

function YDbItemTemplate.GetBlock: UInt32;
begin
  Result := FBlock;
end;

function YDbItemTemplate.GetBonding: UInt32;
begin
  Result := FBonding;
end;

function YDbItemTemplate.GetBuyPrice: UInt32;
begin
  Result := FBuyPrice;
end;

function YDbItemTemplate.GetContainerSlots: UInt32;
begin
  Result := FContainerSlots;
end;

function YDbItemTemplate.GetDelay: UInt32;
begin
  Result := FDelay;
end;

function YDbItemTemplate.GetDescription: PWideChar;
begin
  Result := PWideChar(FDescription);
end;

function YDbItemTemplate.GetDescriptionN: WideString;
begin
  Result := FDescription;
end;

function YDbItemTemplate.GetDisenchantReqSkill: UInt32;
begin
  Result := FDisenchantReqSkill;
end;

function YDbItemTemplate.GetExtraInfo: UInt32;
begin
  Result := FExtraInfo;
end;

function YDbItemTemplate.GetExtraInfoAdvanced: UInt32;
begin
  Result := FExtraInfo2;
end;

function YDbItemTemplate.GetFlags: UInt32;
begin
  Result := FFlags;
end;

function YDbItemTemplate.GetGemProperties: UInt32;
begin
  Result := FGemProperties;
end;

function YDbItemTemplate.GetInventoryType: YItemInventoryType;
begin
  Result := FInventoryType;
end;

function YDbItemTemplate.GetItemExtendedCost: UInt32;
begin
  Result := FItemExtendedCost;
end;

function YDbItemTemplate.GetItemLevel: UInt32;
begin
  Result := FItemLevel;
end;

function YDbItemTemplate.GetItemSet: UInt32;
begin
  Result := FItemSet;
end;

function YDbItemTemplate.GetLockID: UInt32;
begin
  Result := FLockId;
end;

function YDbItemTemplate.GetLockMaterial: UInt32;
begin
  Result := FLockMaterial;
end;

function YDbItemTemplate.GetMainClass: YItemClass;
begin
  Result := FClass;
end;

function YDbItemTemplate.GetMapId: UInt32;
begin
  Result := FMapId;
end;

function YDbItemTemplate.GetMaximumCount: UInt32;
begin
  Result := FMaximumCount;
end;

function YDbItemTemplate.GetMaximumDurability: UInt32;
begin
  Result := FMaximumDurability;
end;

function YDbItemTemplate.GetModelId: UInt32;
begin
  Result := FModelId;
end;

function YDbItemTemplate.GetName: PWideChar;
begin
  Result := PWideChar(FName);
end;

function YDbItemTemplate.GetNameEnchanting: PWideChar;
begin
  Result := PWideChar(FNameEnchanting);
end;

function YDbItemTemplate.GetNameEnchantingN: WideString;
begin
  Result := FNameEnchanting;
end;

function YDbItemTemplate.GetNameForQuest: PWideChar;
begin
  Result := PWideChar(FNameForQuest);
end;

function YDbItemTemplate.GetNameForQuestN: WideString;
begin
  Result := FNameForQuest;
end;

function YDbItemTemplate.GetNameHonorable: PWideChar;
begin
  Result := PWideChar(FNameHonorable);
end;

function YDbItemTemplate.GetNameHonorableN: WideString;
begin
  Result := FNameHonorable;
end;

function YDbItemTemplate.GetNameN: WideString;
begin
  Result := FName;
end;

function YDbItemTemplate.GetPageID: UInt32;
begin
  Result := FPageId;
end;

function YDbItemTemplate.GetPageLanguage: UInt32;
begin
  Result := FPageLanguage;
end;

function YDbItemTemplate.GetPageMaterial: UInt32;
begin
  Result := FPageMaterial;
end;

function YDbItemTemplate.GetQuality: YItemQuality;
begin
  Result := FQuality;
end;

function YDbItemTemplate.GetRangedModifier: Float;
begin
  Result := FRange;
end;

function YDbItemTemplate.GetReqFaction: UInt32;
begin
  Result := FReqFaction;
end;

function YDbItemTemplate.GetReqFactionLevel: UInt32;
begin
  Result := FReqFactionStanding;
end;

function YDbItemTemplate.GetReqLevel: UInt32;
begin
  Result := FReqLevel;
end;

function YDbItemTemplate.GetReqPVPRank1: UInt32;
begin
  Result := FReqPVPRank1;
end;

function YDbItemTemplate.GetReqPVPRank2: UInt32;
begin
  Result := FReqPVPRank2;
end;

function YDbItemTemplate.GetReqSkill: UInt32;
begin
  Result := FReqSkill;
end;

function YDbItemTemplate.GetReqSkillRank: UInt32;
begin
  Result := FReqSkillRank;
end;

function YDbItemTemplate.GetReqSpell: UInt32;
begin
  Result := FReqSpell;
end;

function YDbItemTemplate.GetResistanceArcane: UInt32;
begin
  Result := FResistanceArcane;
end;

function YDbItemTemplate.GetResistanceFire: UInt32;
begin
  Result := FResistanceFire;
end;

function YDbItemTemplate.GetResistanceFrost: UInt32;
begin
  Result := FResistanceFrost;
end;

function YDbItemTemplate.GetResistanceHoly: UInt32;
begin
  Result := FResistanceHoly;
end;

function YDbItemTemplate.GetResistanceNature: UInt32;
begin
  Result := FResistanceNature;
end;

function YDbItemTemplate.GetResistancePhysical: UInt32;
begin
  Result := FResistancePhysical;
end;

function YDbItemTemplate.GetResistanceShadow: UInt32;
begin
  Result := FResistanceShadow;
end;

function YDbItemTemplate.GetSellPrice: UInt32;
begin
  Result := FSellPrice;
end;

function YDbItemTemplate.GetSheath: UInt32;
begin
  Result := FSheath;
end;

function YDbItemTemplate.GetSocketBonus: UInt32;
begin
  Result := FSocketBonus;
end;

function YDbItemTemplate.GetSocketColor1: UInt32;
begin
  Result := FSocketColor1;
end;

function YDbItemTemplate.GetSocketColor2: UInt32;
begin
  Result := FSocketColor2;
end;

function YDbItemTemplate.GetSocketColor3: UInt32;
begin
  Result := FSocketColor3;
end;

function YDbItemTemplate.GetSocketUnk1: UInt32;
begin
  Result := 0;
end;

function YDbItemTemplate.GetSocketUnk2: UInt32;
begin
  Result := 0;
end;

function YDbItemTemplate.GetSocketUnk3: UInt32;
begin
  Result := 0;
end;

function YDbItemTemplate.GetStartsQuest: UInt32;
begin
  Result := FStartsQuest;
end;

function YDbItemTemplate.GetSubClass: UInt32;
begin
  Result := FSubClass;
end;

function YDbItemTemplate.GetTotemCategory: UInt32;
begin
  Result := FToolCategory;
end;

function YDbItemTemplate.GetUniqueFlag: UInt32;
begin
  Result := FUniqueFlag;
end;

procedure YDbItemTemplate.SetAllowedClasses(Value: YGameClasses);
begin
  FAllowedClasses := Value;
end;

procedure YDbItemTemplate.SetAllowedRaces(Value: YGameRaces);
begin
  FAllowedRaces := Value;
end;

procedure YDbItemTemplate.SetAmunitionType(Value: UInt32);
begin
  FAmmunitionType := Value;
end;

procedure YDbItemTemplate.SetArea(Value: UInt32);
begin
  FArea := Value;
end;

procedure YDbItemTemplate.SetBagFamily(Value: UInt32);
begin
  FBagType := Value;
end;

procedure YDbItemTemplate.SetBlock(Value: UInt32);
begin
  FBlock := Value;
end;

procedure YDbItemTemplate.SetBonding(Value: UInt32);
begin
  FBonding := Value;
end;

procedure YDbItemTemplate.SetBuyPrice(Value: UInt32);
begin
  FBuyPrice := Value;
end;

procedure YDbItemTemplate.SetContainerSlots(Value: UInt32);
begin
  FContainerSlots := Value;
end;

procedure YDbItemTemplate.SetDelay(Value: UInt32);
begin
  FDelay := Value;
end;

procedure YDbItemTemplate.SetDescription(Value: PWideChar);
begin
  FDescription := Value;
  FDescriptionUTF8 := WideStringToUTF8(FDescription);
end;

procedure YDbItemTemplate.SetDescriptionN(const Value: WideString);
begin
  FDescription := Value;
  FDescriptionUTF8 := WideStringToUTF8(Value);
end;

procedure YDbItemTemplate.SetDisenchantReqSkill(Value: UInt32);
begin
  FDisenchantReqSkill := Value;
end;

procedure YDbItemTemplate.SetExtraInfo(Value: UInt32);
begin
  FExtraInfo := Value;
end;

procedure YDbItemTemplate.SetExtraInfoAdvanced(Value: UInt32);
begin
  FExtraInfo2 := Value;
end;

procedure YDbItemTemplate.SetFlags(Value: UInt32);
begin
  FFlags := Value;
end;

procedure YDbItemTemplate.SetGemProperties(Value: UInt32);
begin
  FGemProperties := Value;
end;

procedure YDbItemTemplate.SetInventoryType(Value: YItemInventoryType);
begin
  FInventoryType := Value;
end;

procedure YDbItemTemplate.SetItemExtendedCost(Value: UInt32);
begin
  FItemExtendedCost := Value;
end;

procedure YDbItemTemplate.SetItemLevel(Value: UInt32);
begin
  FItemLevel := Value;
end;

procedure YDbItemTemplate.SetItemSet(Value: UInt32);
begin
  FItemSet := Value;
end;

procedure YDbItemTemplate.SetLockID(Value: UInt32);
begin
  FLockId := Value;
end;

procedure YDbItemTemplate.SetLockMaterial(Value: UInt32);
begin
  FLockMaterial := Value;
end;

procedure YDbItemTemplate.SetMainClass(Value: YItemClass);
begin
  FClass := Value;
end;

procedure YDbItemTemplate.SetMapId(Value: UInt32);
begin
  FMapId := Value;
end;

procedure YDbItemTemplate.SetMaximumCount(Value: UInt32);
begin
  FMaximumCount := Value;
end;

procedure YDbItemTemplate.SetMaximumDurability(Value: UInt32);
begin
  FMaximumDurability := Value;
end;

procedure YDbItemTemplate.SetModelId(Value: UInt32);
begin
  FModelId := Value;
end;

procedure YDbItemTemplate.SetName(Value: PWideChar);
begin
  FName := Value;
  FNameUTF8 := WideStringToUTF8(FName);
end;

procedure YDbItemTemplate.SetNameEnchanting(Value: PWideChar);
begin
  FNameEnchanting := Value;
  FNameEnchantingUTF8 := WideStringToUTF8(FNameEnchanting);
end;

procedure YDbItemTemplate.SetNameEnchantingN(const Value: WideString);
begin
  FNameEnchanting := Value;
  FNameEnchantingUTF8 := WideStringToUTF8(Value);
end;

procedure YDbItemTemplate.SetNameForQuest(Value: PWideChar);
begin
  FNameForQuest := Value;
  FNameForQuestUTF8 := WideStringToUTF8(FNameForQuest);
end;

procedure YDbItemTemplate.SetNameForQuestN(const Value: WideString);
begin
  FNameForQuest := Value;
  FNameForQuestUTF8 := WideStringToUTF8(Value);
end;

procedure YDbItemTemplate.SetNameHonorable(Value: PWideChar);
begin
  FNameHonorable := Value;
  FNameHonorableUTF8 := WideStringToUTF8(FNameHonorable);
end;

procedure YDbItemTemplate.SetNameHonorableN(const Value: WideString);
begin
  FNameHonorable := Value;
  FNameHonorableUTF8 := WideStringToUTF8(Value);
end;

procedure YDbItemTemplate.SetNameN(const Value: WideString);
begin
  FName := Value;
  FNameUTF8 := WideStringToUTF8(Value);
end;

procedure YDbItemTemplate.SetPageID(Value: UInt32);
begin
  FPageId := Value;
end;

procedure YDbItemTemplate.SetPageLanguage(Value: UInt32);
begin
  FPageLanguage := Value;
end;

procedure YDbItemTemplate.SetPageMaterial(Value: UInt32);
begin
  FPageMaterial := Value;
end;

procedure YDbItemTemplate.SetQuality(Value: YItemQuality);
begin
  FQuality := Value;
end;

procedure YDbItemTemplate.SetRangedModifier(Value: Float);
begin
  FRange := Value;
end;

procedure YDbItemTemplate.SetReqFaction(Value: UInt32);
begin
  FReqFaction := Value;
end;

procedure YDbItemTemplate.SetReqFactionLevel(Value: UInt32);
begin
  FReqFactionStanding := Value;
end;

procedure YDbItemTemplate.SetReqLevel(Value: UInt32);
begin
  FReqLevel := Value;
end;

procedure YDbItemTemplate.SetReqPVPRank1(Value: UInt32);
begin
  FReqPVPRank1 := Value;
end;

procedure YDbItemTemplate.SetReqPVPRank2(Value: UInt32);
begin
  FReqPVPRank2 := Value;
end;

procedure YDbItemTemplate.SetReqSkill(Value: UInt32);
begin
  FReqSkill := Value;
end;

procedure YDbItemTemplate.SetReqSkillRank(Value: UInt32);
begin
  FReqSkillRank := Value;
end;

procedure YDbItemTemplate.SetReqSpell(Value: UInt32);
begin
  FReqSpell := Value;
end;

procedure YDbItemTemplate.SetResistanceArcane(Value: UInt32);
begin
  FResistanceArcane := Value;
end;

procedure YDbItemTemplate.SetResistanceFire(Value: UInt32);
begin
  FResistanceFire := Value;
end;

procedure YDbItemTemplate.SetResistanceFrost(Value: UInt32);
begin
  FResistanceFrost := Value;
end;

procedure YDbItemTemplate.SetResistanceHoly(Value: UInt32);
begin
  FResistanceHoly := Value;
end;

procedure YDbItemTemplate.SetResistanceNature(Value: UInt32);
begin
  FResistanceNature := Value;
end;

procedure YDbItemTemplate.SetResistancePhysical(Value: UInt32);
begin
  FResistancePhysical := Value;
end;

procedure YDbItemTemplate.SetResistanceShadow(Value: UInt32);
begin
  FResistanceShadow := Value;
end;

procedure YDbItemTemplate.SetSellPrice(Value: UInt32);
begin
  FSellPrice := Value;
end;

procedure YDbItemTemplate.SetSheath(Value: UInt32);
begin
  FSheath := Value;
end;

procedure YDbItemTemplate.SetSocketBonus(Value: UInt32);
begin
  FSocketBonus := Value;
end;

procedure YDbItemTemplate.SetSocketColor1(Value: UInt32);
begin
  FSocketColor1 := Value;
end;

procedure YDbItemTemplate.SetSocketColor2(Value: UInt32);
begin
  FSocketColor2 := Value;
end;

procedure YDbItemTemplate.SetSocketColor3(Value: UInt32);
begin
  FSocketColor3 := Value;
end;

procedure YDbItemTemplate.SetSocketUnk1(Value: UInt32);
begin

end;

procedure YDbItemTemplate.SetSocketUnk2(Value: UInt32);
begin

end;

procedure YDbItemTemplate.SetSocketUnk3(Value: UInt32);
begin

end;

procedure YDbItemTemplate.SetStartsQuest(Value: UInt32);
begin
  FStartsQuest := Value;
end;

procedure YDbItemTemplate.SetSubClass(Value: UInt32);
begin
  FSubClass := Value;
end;

procedure YDbItemTemplate.SetTotemCategory(Value: UInt32);
begin
  FToolCategory := Value;
end;

procedure YDbItemTemplate.SetUniqueFlag(Value: UInt32);
begin
  FUniqueFlag := Value;
end;

procedure YDbItemTemplate.StoreEntryContents(var Data; Flags: Longword);
begin

end;

procedure YDbItemTemplate.LoadEntryContents(const Data; Flags: Longword);
begin

end;

{ YDbAddonEntry }

procedure YDbAddonEntry.Assign(const Entry: ISerializable);
var
  Addon: IAddonEntry;
begin
  inherited Assign(Entry);
  if Entry.QueryInterface(IAddonEntry, Addon) <> S_OK then Exit;

  FName := Addon.Name;
  FCRC32 := Addon.CRC32;
  FEnabled := Addon.Enabled;
end;

function YDbAddonEntry.GetCRC32: UInt32;
begin
  Result := FCRC32;
end;

function YDbAddonEntry.GetEnabled: Boolean;
begin
  Result := FEnabled;
end;

function YDbAddonEntry.GetName: PWideChar;
begin
  Result := PWideChar(FName);
end;

function YDbAddonEntry.GetNameN: WideString;
begin
  Result := FName;
end;

procedure YDbAddonEntry.SetCRC32(Value: UInt32);
begin
  FCRC32 := Value;
end;

procedure YDbAddonEntry.SetEnabled(Value: Boolean);
begin
  FEnabled := Value;
end;

procedure YDbAddonEntry.SetName(Value: PWideChar);
begin
  FName := Value;
end;

procedure YDbAddonEntry.SetNameN(const Value: WideString);
begin
  FName := Value;
end;

{ YDbPersistentTimerEntry }

procedure YDbPersistentTimerEntry.Assign(const Entry: ISerializable);
var
  Timer: IPersistentTimerEntry;
begin
  inherited Assign(Entry);
  if Entry.QueryInterface(IPersistentTimerEntry, Timer) <> S_OK then Exit;

  FTimeLeft := Timer.TimeLeft;
  FTimeTotal := Timer.TimeTotal;
  FExecutionCount := Timer.ExecutionCount;
  FDisabled := Timer.Disabled;
end;

function YDbPersistentTimerEntry.GetDisabled: Boolean;
begin
  Result := FDisabled;
end;

function YDbPersistentTimerEntry.GetExecutionCount: Int32;
begin
  Result := FExecutionCount;
end;

function YDbPersistentTimerEntry.GetTimeLeft: UInt32;
begin
  Result := FTimeLeft;
end;

function YDbPersistentTimerEntry.GetTimeTotal: UInt32;
begin
  Result := FTimeTotal;
end;

procedure YDbPersistentTimerEntry.SetDisabled(Value: Boolean);
begin
  FDisabled := Value;
end;

procedure YDbPersistentTimerEntry.SetExecutionCount(Value: Int32);
begin
  FExecutionCount := Value;
end;

procedure YDbPersistentTimerEntry.SetTimeLeft(Value: UInt32);
begin
  FTimeLeft := Value;
end;

procedure YDbPersistentTimerEntry.SetTimeTotal(Value: UInt32);
begin
  FTimeTotal := Value;
end;

end.
