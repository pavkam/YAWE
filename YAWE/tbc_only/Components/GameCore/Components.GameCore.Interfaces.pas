{*------------------------------------------------------------------------------
  Interfaces which are implemented by server classes. 
  For use with the extension engine.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.Interfaces;

interface

uses
  Components.Shared,
  Components.DataCore.Types,
  Components.GameCore.UpdateFields;

{ TODO 2 -oSeth -cFeature adding : Implement all interfaces into server objects.
Scheduled for next milestone. }

type
  IObject = interface;
  IItem = interface;
  IBag = interface;
  IMobile = interface;
  IUnit = interface;
  ICreature = interface;
  INpc = interface;
  IPlayer = interface;

  IObjectComponent = interface;
  IPosition = interface;
  IStats = interface;
  IEquipment = interface;

{$REGION 'Interfaces implemented by YOpenObject and its derivates'}
  IObject = interface(IInterface)
  ['{91AEEA51-8F08-44B8-A851-1F77FCC4E591}']
    { Internal }
    function GetObjType: YWowObjectType;

    { Public }
    procedure SaveToDatabase;
    //function GetDatabaseValue(const sFieldName: string): IVariant; { Extra DB fields }
    property ObjectType: YWowObjectType read GetObjType;
  end;

  IItem = interface(IObject)
  ['{4EDECE16-7095-4576-A3D2-48FBD6360519}']
    { Internal }
    function GetEntry: Integer; 
    function GetOccupiedSlot: Integer;
    function GetOwnerBag: IBag;
    function GetOwner: IUnit;
    function GetCreator: IPlayer;
    function IsInBag: Boolean;

    { Public }
    { Copies this item's template into destination. }
    //procedure CopyTemplate(var tOutTemplate: YItemTemplate);
    property Entry: Integer read GetEntry;
    property OccupiedSlot: Integer read GetOccupiedSlot;
    property InBag: Boolean read IsInBag;
    property ContainedIn: IBag read GetOwnerBag;
    property Owner: IUnit read GetOwner;
    property Creator: IPlayer read GetCreator;
  end;

  IBag = interface(IItem)
  ['{05BD1899-B57B-4D11-8AA1-5268F5856241}']
    { Internal }
    function GetItem(iSlot: Integer): IItem;
    function GetNumItems: Integer;
    function GetSlotCount: Integer;

    { Public }
    { Swaps 2 slots in this bag }
    function SwapItems(iSlot1, iSlot2: Integer): Integer; overload;
    { This function swaps 2 items between distinct bags. }
    function SwapItems(iSrcSlot, iDestSlot: Integer; const ifDestBag: IBag): Integer; overload;
    { Consumes items in iSlot lowering its stack count by the specified amount. }
    { If not the stack count is lower than iCount, the item is destroyed. }
    function ConsumeItem(iSlot, iCount: Integer): Integer; overload;
    { Searches for items with entry iEntry, tries to consume iCount stacks. If bConsumeAlways
      is false, items are not consumed when not enough items have been found. }
    function ConsumeItem(iEntry, iCount: Integer; bConsumeAlways: Boolean): Integer; overload;
    { Destroys item in iSlot, ignoring stack count. }
    function DestroyItem(iSlot: Integer): Integer;
    { Counts items with specified entry. }
    function CountItemsOfEntry(iEntryId: Integer; bConsiderStack: Boolean): Integer;

    property Items[iSlot: Integer]: IItem read GetItem;
    property ItemCount: Integer read GetNumItems;
    property SlotCount: Integer read GetSlotCount;
  end;

  IMobile = interface(IObject)
  ['{FD731A5E-1E87-45B2-8B9B-6D2D4B4987A7}']
    { Internal }
    function GetPosition: IPosition;
    
    { Public }
    property Position: IPosition read GetPosition;
  end;

  IUnit = interface(IObject)
  ['{147C323C-E9F9-48CB-836D-CEE820C7A8A2}']
  end;

  ICreature = interface(IUnit)
  ['{6DD0CB19-519C-48C5-BB79-FBD2C916E825}']
    //procedure CopyUnitTemplate(var tOutTemplate: YCreatureTemplate);
    //procedure CopyLootTemplate(var tOutTemplate: YLootTemplate);
  end;

  INpc = interface(ICreature)
  ['{3F516DB5-A8E8-432F-B020-7F759C99934A}']
  end;

  IPlayer = interface(IUnit)
  ['{93EE8183-8EAB-4D10-9A4A-F19824894F4A}']
  end;
{$ENDREGION}

{$REGION 'Interfaces implemented by YOpenComponent and its derivates'}
  IObjectComponent = interface(IInterface)
  ['{22BC922F-640A-4AE6-89E1-454BBF96024A}']
    { Internal }
    function GetOwner: IObject;

    { Public }
    property Owner: IObject read GetOwner;
  end;

  IPosition = interface(IObjectComponent)
  ['{608CFAF3-1F94-426F-AA16-8A6EBA63717C}']
    {$REGION 'Internal'}
    function GetX: Single;
    function GetY: Single;
    function GetZ: Single;
    function GetAngle: Single;
    function GetMapId: Longword;
    function GetZoneId: Longword;
    {$ENDREGION}

    {$REGION 'Public'}
    //procedure GetCurrentPosition(var tPos: YWorldPosition);
    property X: Single read GetX;
    property Y: Single read GetY;
    property Z: Single read GetZ;
    property Angle: Single read GetAngle;
    property Map: Longword read GetMapId;
    property Zone: Longword read GetZoneId;
    {$ENDREGION}
  end;

  IStats = interface(IObjectComponent)
  ['{4687268E-3650-4F04-BC05-2D12CB3368B3}']
    {$REGION 'Internal'}
    function GetBRadius: Single;
    function GetCReach: Single;
    procedure SetBRadius(const fValue: Single);
    procedure SetCReach(const fValue: Single);
    function GetFaction: Longword;
    procedure SetFaction(iValue: Longword);
    function GetActualHealth: Longword;
    function GetActualPower: Longword;
    function GetAgility: Longword;
    function GetArcaneResist: Longword;
    function GetArmor: Longword;
    function GetClass: YGameClass;
    function GetCurrentModel: Longword;
    function GetFireResist: Longword;
    function GetFrostResist: Longword;
    function GetGender: YGameGender;
    function GetHolyResist: Longword;
    function GetIntellect: Longword;
    function GetLevel: Longword;
    function GetMaxHealth: Longword;
    function GetMaxPower: Longword;
    function GetModel: Longword;
    function GetNatureResist: Longword;
    function GetPowerType: YGamePowerType;
    function GetRace: YGameRace;
    function GetShadowResist: Longword;
    function GetSpirit: Longword;
    function GetStamina: Longword;
    function GetStrength: Longword;
    function GetAttackPower: Cardinal;
    function GetAttackDamageHi: Single;
    function GetAttackDamageLo: Single;
    function GetOffHandAttackDamageHi: Single;
    function GetOffHandAttackDamageLo: Single;
    function GetRangedAttackDamageHi: Single;
    function GetRangedAttackDamageLo: Single;
    function GetRangedAttackPower: Cardinal;
    function GetAdditionalAgility: Integer;
    function GetAdditionalIntellect: Integer;
    function GetAdditionalSpirit: Integer;
    function GetAdditionalStamina: Integer;
    function GetAdditionalStrength: Integer;
    procedure SetClass(iValue: YGameClass);
    procedure SetGender(iValue: YGameGender);
    procedure SetRace(iValue: YGameRace);
    procedure SetLevel(iValue: Longword);
    procedure SetModel(iValue: Longword);
    procedure SetCurrentModel(iValue: Longword);
    procedure SetPowerType(iValue: YGamePowerType);
    procedure SetAgility(iValue: Longword);
    procedure SetActualHealth(iValue: Longword);
    procedure SetActualPower(iValue: Longword);
    procedure SetArmor(iValue: Longword);
    procedure SetIntellect(iValue: Longword);
    procedure SetMaxHealth(iValue: Longword);
    procedure SetMaxPower(iValue: Longword);
    procedure SetSpirit(iValue: Longword);
    procedure SetStamina(iValue: Longword);
    procedure SetStrength(iValue: Longword);
    procedure SetArcaneResist(iValue: Longword);
    procedure SetFireResist(iValue: Longword);
    procedure SetFrostResist(iValue: Longword);
    procedure SetHolyResist(iValue: Longword);
    procedure SetNatureResist(iValue: Longword);
    procedure SetShadowResist(iValue: Longword);
    function GetBaseAttackTimeHi: Longword;
    function GetBaseAttackTimeLo: Longword;
    procedure SetBaseAttackTimeHi(iValue: Longword);
    procedure SetBaseAttackTimeLo(iValue: Longword);
    procedure SetAdditionalAgility(const Value: Integer);
    procedure SetAdditionalIntellect(const Value: Integer);
    procedure SetAdditionalSpirit(const Value: Integer);
    procedure SetAdditionalStamina(const Value: Integer);
    procedure SetAdditionalStrength(const Value: Integer);
    procedure SetRangedAttackDamageHi(const Value: Single);
    procedure SetRangedAttackDamageLo(const Value: Single);
    procedure SetRangedAttackPower(const Value: Cardinal);
    procedure SetOffHandAttackDamageHi(const Value: Single);
    procedure SetOffHandAttackDamageLo(const Value: Single);
    procedure SetAttackPower(iValue: Cardinal);
    procedure SetAttackDamageHi(const fValue: Single);
    procedure SetAttackDamageLo(const fValue: Single);


    {$ENDREGION}

    {$REGION 'Public'}
    property Race: YGameRace read GetRace write SetRace;
    property &Class: YGameClass read GetClass write SetClass;
    property Gender: YGameGender read GetGender write SetGender;
    property Level: Longword read GetLevel write SetLevel;
    property Model: Longword read GetModel write SetModel;
    property CurrentModel: Longword read GetCurrentModel write SetCurrentModel;
    property PowerType: YGamePowerType read GetPowerType write SetPowerType;
    property Power: Longword read GetActualPower write SetActualPower;
    property MaxPower: Longword read GetMaxPower write SetMaxPower;
    property Health: Longword read GetActualHealth write SetActualHealth;
    property MaxHealth: Longword read GetMaxHealth write SetMaxHealth;
    property Strength: Longword read GetStrength write SetStrength;
    property Agility: Longword read GetAgility write SetAgility;
    property Stamina: Longword read GetStamina write SetStamina;
    property Intellect: Longword read GetIntellect write SetIntellect;
    property Spirit: Longword read GetSpirit write SetSpirit;
    property ArmorResist: Longword read GetArmor write SetArmor;
    property HolyResist: Longword read GetHolyResist write SetHolyResist;
    property FireResist: Longword read GetFireResist write SetFireResist;
    property NatureResist: Longword read GetNatureResist write SetNatureResist;
    property FrostResist: Longword read GetFrostResist write SetFrostResist;
    property ShadowResist: Longword read GetShadowResist write SetShadowResist;
    property ArcaneResist: Longword read GetArcaneResist write SetArcaneResist;
    property BaseAttackTimeHi: Longword read GetBaseAttackTimeHi write SetBaseAttackTimeHi;
    property BaseAttackTimeLo: Longword read GetBaseAttackTimeLo write SetBaseAttackTimeLo;
    property Faction: Longword read GetFaction write SetFaction;
    property BoundingRadius: Single read GetBRadius write SetBRadius;
    property CombatReach: Single read GetCReach write SetCReach;
    property MeleeAttackDamageHi: Single read GetAttackDamageHi write SetAttackDamageHi;
    property MeleeAttackDamageLo: Single read GetAttackDamageLo write SetAttackDamageLo;
    property MeleeAttackPower:   Cardinal read GetAttackPower write SetAttackPower;
    property OffHandAttackDamageHi: Single read GetOffHandAttackDamageHi write SetOffHandAttackDamageHi;
    property OffHandAttackDamageLo: Single read GetOffHandAttackDamageLo write SetOffHandAttackDamageLo;
    property OffHandAttackPower:   Cardinal read GetAttackPower write SetAttackPower;
    property RangedAttackDamageHi: Single read GetRangedAttackDamageHi write SetRangedAttackDamageHi;
    property RangedAttackDamageLo: Single read GetRangedAttackDamageLo write SetRangedAttackDamageLo;
    property RangedAttackPower: Cardinal read GetRangedAttackPower write SetRangedAttackPower;

    property AdditionalStrength: Integer read GetAdditionalStrength write SetAdditionalStrength;
    property AdditionalAgility: Integer read GetAdditionalAgility write SetAdditionalAgility;
    property AdditionalStamina: Integer read GetAdditionalStamina write SetAdditionalStamina;
    property AdditionalIntellect: Integer read GetAdditionalIntellect write SetAdditionalIntellect;
    property AdditionalSpirit: Integer read GetAdditionalSpirit write SetAdditionalSpirit;
    {$ENDREGION}
  end;

  IEquipment = interface(IObjectComponent)
  ['{17EC51FA-02B4-471D-B320-17E283D26ABD}']
  end;
{$ENDREGION}

implementation

end.
