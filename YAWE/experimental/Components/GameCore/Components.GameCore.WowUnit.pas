{*------------------------------------------------------------------------------
  WOW Unit and all it's components

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
  @Changes PavkaM, TheSelby
  @Docs TheSelby
-------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.WowUnit;

interface

{$REGION 'Uses Clause'}
  uses
    Misc.Geometry,
    Misc.Miscleanous,
    Misc.Algorithm,
    Framework.Base,
    Framework.Tick,
    Components.DataCore.Storage,
    Components.DataCore.Fields,
    Components.NetworkCore.Packet,
    Components.Shared,
    Components.GameCore.UpdateFields,
    Components.Interfaces,
    Components.GameCore.Component,
    Components.GameCore.WowMobile,
    Components.GameCore.Interfaces,
    Components.DataCore.Types;
{$ENDREGION}

type
  YGaUnit = class;
  YGaUnitComponent = class;
  YGaStatMgr = class;
  YGaPetMgr = class;

  {*------------------------------------------------------------------------------
  YGaUnit Class. Essentialy the main "active" class in the game.
  Derived from YGaMobile class and Interfaces IObject, IMobile and IUnit
  @see YGaMobile
  @see IObject
  @see IMobile
  @see IUnit
  -------------------------------------------------------------------------------}
  YGaUnit = class(YGaMobile, IObject, IMobile, IUnit)
    private
      {$REGION 'Private members'}
        fPetManager: YGaPetMgr;       ///Pet Manager
        fStatManager: YGaStatMgr;     ///Stats Manager
        fUpdateHandle: TEventHandle;  ///Updates Handler
      {$ENDREGION}

    protected
      {$REGION 'Protected members'}
      class function GetObjectType: Integer; override;
      class function GetOpenObjectType: YWowObjectType; override;

      { Override this in children to perform resource loading }
      procedure ExtractObjectData(Entry: YDbSerializable); override;
      { Override this in children to perform resource saving }
      procedure InjectObjectData(Entry: YDbSerializable); override;
      { Override this in children to perform resource deletion }
      procedure CleanupObjectData; override;

      procedure UnitLifeTimer(Event: TEventHandle; TimeDelta: UInt32);

      procedure Regenerate; virtual;

      procedure AddToWorld; override;
      procedure RemoveFromWorld; override;
      {$ENDREGION}
    public
      {$REGION 'Public members'}
      constructor Create; override;
      destructor Destroy; override;

      {*------------------------------------------------------------------------------
      Pet property. Reads data from fPetManager
      -------------------------------------------------------------------------------}
      property Pet: YGaPetMgr read fPetManager;
      {*------------------------------------------------------------------------------
      Stats Property. Reads data from fStatManager
      -------------------------------------------------------------------------------}
      property Stats: YGaStatMgr read fStatManager;
      {$ENDREGION}
  end;

  {*------------------------------------------------------------------------------
  YGaUnitComponent Class. Intermediary class.
  Derived from YGaObjectComponent class.
  @see YGaObjectComponent
  -------------------------------------------------------------------------------}
  YGaUnitComponent = class(YGaObjectComponent)
    private
      {$REGION 'Private members'}
        fOwner: YGaMobile;  ///Unit Component's owner (YGaMobile)
      {$ENDREGION}
    public
      {$REGION 'Private members'}
      constructor Create(Owner: YGaMobile); reintroduce;
      {*------------------------------------------------------------------------------
      Owner Property. Reads data from fOwner
      -------------------------------------------------------------------------------}
      property Owner: YGaMobile read fOwner;
      {$ENDREGION}
  end;

  {*------------------------------------------------------------------------------
  YGaPetMgr Class. The Pet Manager is used to track the pet
  Derived from YGaUnitComponent class.
  @see YGaUnitComponent
  -------------------------------------------------------------------------------}
  YGaPetMgr = class(YGaUnitComponent)
    private
      {$REGION 'Private members'}
      function GetPetFamily: UInt32;
      function GetPetId: UInt32;
      function GetPetLevel: UInt32;
      {$ENDREGION}
    public
      {$REGION 'Private members'}
      procedure ExtractObjectData(Entry: YDbSerializable); override;
      procedure InjectObjectData(Entry: YDbSerializable); override;
      procedure CleanupObjectData; override;

      {*------------------------------------------------------------------------------
      ID Property. Reads Pet's ID
      -------------------------------------------------------------------------------}
      property ID: UInt32 read GetPetId;
      {*------------------------------------------------------------------------------
      Level Property. Reads Pet's Level
      -------------------------------------------------------------------------------}
      property Level: UInt32 read GetPetLevel;
      {*------------------------------------------------------------------------------
      Family Property. Reads Pet's Family
      -------------------------------------------------------------------------------}
      property Family: UInt32 read GetPetFamily;
      {$ENDREGION}
    end;

  {*------------------------------------------------------------------------------
  YGaStatMgr Class.
  This class is used to track/modify unit's stats such as health, mana, rage, powers,
   damages, so on and so forth.
  Derived from YGaUnitComponent class.
  @see YGaUnitComponent
  -------------------------------------------------------------------------------}
  YGaStatMgr = class(YGaUnitComponent)
    private
      {$REGION 'Private members'}
      function GetAttackPower: UInt32;
      function GetAttackDamageHi: Float;
      function GetAttackDamageLo: Float;
      function GetOffHandAttackDamageHi: Float;
      function GetOffHandAttackDamageLo: Float;
      function GetRangedAttackDamageHi: Float;
      function GetRangedAttackDamageLo: Float;
      function GetRangedAttackPower: UInt32;
      function GetBRadius: Float;
      function GetCReach: Float;
      function GetFaction: UInt32;
      function GetActualHealth: UInt32;
      function GetActualPower: UInt32;
      function GetAgility: UInt32;
      function GetArcaneResist: UInt32;
      function GetArmor: UInt32;
      function GetClass: YGameClass;
      function GetCurrentModel: UInt32;
      function GetFireResist: UInt32;
      function GetFrostResist: UInt32;
      function GetGender: YGameGender;
      function GetHolyResist: UInt32;
      function GetIntellect: UInt32;
      function GetLevel: UInt32;
      function GetMaxHealth: UInt32;
      function GetMaxPower: UInt32;
      function GetModel: UInt32;
      function GetNatureResist: UInt32;
      function GetPowerType: YGamePowerType;
      function GetRace: YGameRace;
      function GetShadowResist: UInt32;
      function GetSpirit: UInt32;
      function GetStamina: UInt32;
      function GetStrength: UInt32;
      function GetMount: UInt32;
      function GetAdditionalAgility: Integer;
      function GetAdditionalIntellect: Integer;
      function GetAdditionalSpirit: Integer;
      function GetAdditionalStamina: Integer;
      function GetAdditionalStrength: Integer;
      function GetBaseAttackTimeHi: UInt32;
      function GetBaseAttackTimeLo: UInt32;      

      procedure SetFaction(Value: UInt32);
      procedure SetAdditionalAgility(const Value: Integer);
      procedure SetAdditionalIntellect(const Value: Integer);
      procedure SetAdditionalSpirit(const Value: Integer);
      procedure SetAdditionalStamina(const Value: Integer);
      procedure SetAdditionalStrength(const Value: Integer);
      procedure SetBRadius(const Value: Float);
      procedure SetCReach(const Value: Float);
      procedure SetMount(const Value: UInt32);
      procedure SetClass(Value: YGameClass);
      procedure SetGender(Value: YGameGender);
      procedure SetRace(Value: YGameRace);
      procedure SetLevel(Value: UInt32);
      procedure SetModel(Value: UInt32);
      procedure SetCurrentModel(Value: UInt32);
      procedure SetPowerType(Value: YGamePowerType);
      procedure SetAgility(Value: UInt32);
      procedure SetActualHealth(Value: UInt32);
      procedure SetActualPower(Value: UInt32);
      procedure SetArmor(Value: UInt32);
      procedure SetIntellect(Value: UInt32);
      procedure SetMaxHealth(Value: UInt32);
      procedure SetMaxPower(Value: UInt32);
      procedure SetSpirit(Value: UInt32);
      procedure SetStamina(Value: UInt32);
      procedure SetStrength(Value: UInt32);
      procedure SetArcaneResist(Value: UInt32);
      procedure SetFireResist(Value: UInt32);
      procedure SetFrostResist(Value: UInt32);
      procedure SetHolyResist(Value: UInt32);
      procedure SetNatureResist(Value: UInt32);
      procedure SetShadowResist(Value: UInt32);
      procedure SetBaseAttackTimeHi(Value: UInt32);
      procedure SetBaseAttackTimeLo(Value: UInt32);
      procedure SetRangedAttackDamageHi(const Value: Float);
      procedure SetRangedAttackDamageLo(const Value: Float);
      procedure SetRangedAttackPower(const Value: UInt32);
      procedure SetOffHandAttackDamageHi(const Value: Float);
      procedure SetOffHandAttackDamageLo(const Value: Float);
      procedure SetAttackPower(Value: UInt32);
      procedure SetAttackDamageHi(const Value: Float);
      procedure SetAttackDamageLo(const Value: Float);
      {$ENDREGION}
    public
      {$REGION 'Public members'}
      procedure ExtractObjectData(Entry: YDbSerializable); override;
      procedure InjectObjectData(Entry: YDbSerializable); override;
      procedure CleanupObjectData; override;

                                  {----------}
                                  { Generals }
                                  {----------}

      {*------------------------------------------------------------------------------
      GameRace Property. Reads Unit's GameRace and offers the possibility to change it
      -------------------------------------------------------------------------------}
      property Race: YGameRace read GetRace write SetRace;
      {*------------------------------------------------------------------------------
      GameClass Property. Reads Unit's GameClass and offers the possibility to change it
      -------------------------------------------------------------------------------}
      property &Class: YGameClass read GetClass write SetClass;
      {*------------------------------------------------------------------------------
      Gender Property. Reads Unit's Gender and offers the possibility to change it
      -------------------------------------------------------------------------------}
      property Gender: YGameGender read GetGender write SetGender;
      {*------------------------------------------------------------------------------
      Level Property. Reads Unit's Level and offers the possibility to change it
      -------------------------------------------------------------------------------}
      property Level: UInt32 read GetLevel write SetLevel;
      {*------------------------------------------------------------------------------
      Mount Property. Reads Unit's MountID and offers the possibility to change it
      -------------------------------------------------------------------------------}
      property Mount: UInt32 read GetMount write SetMount;

                                    {--------}
                                    { Models }
                                    {--------}

      {*------------------------------------------------------------------------------
      Model Property. Reads/Sets Unit's Model
      -------------------------------------------------------------------------------}
      property Model: UInt32 read GetModel write SetModel;
      {*------------------------------------------------------------------------------
      Current Model Property. Reads/Sets Unit's Current Model
      -------------------------------------------------------------------------------}
      property CurrentModel: UInt32 read GetCurrentModel write SetCurrentModel;

                                    {--------}
                                    { Powers }
                                    {--------}

      {*------------------------------------------------------------------------------
      PowerType Property. Reads/Sets Unit's Power Type
      -------------------------------------------------------------------------------}
      property PowerType: YGamePowerType read GetPowerType write SetPowerType;
      {*------------------------------------------------------------------------------
      Power Property. Reads/Sets Unit's Power
      -------------------------------------------------------------------------------}
      property Power: UInt32 read GetActualPower write SetActualPower;
      {*------------------------------------------------------------------------------
      Maximum Power Property. Reads/Sets Unit's Maximum Power
      -------------------------------------------------------------------------------}
      property MaxPower: UInt32 read GetMaxPower write SetMaxPower;

                                {------------------}
                                { Health Propeties }
                                {------------------}

      {*------------------------------------------------------------------------------
      Health Property. Reads/Sets Unit's Health
      -------------------------------------------------------------------------------}
      property Health: UInt32 read GetActualHealth write SetActualHealth;
      {*------------------------------------------------------------------------------
      Maximum Health Property. Reads/Sets Unit's Maximum Health
      -------------------------------------------------------------------------------}
      property MaxHealth: UInt32 read GetMaxHealth write SetMaxHealth;

                {----------------------------------------------------}
                { Actual Stats. Modified by Auras, Affects and Items }
                {----------------------------------------------------}

      {*------------------------------------------------------------------------------
      Strength Property. Reads/Sets Unit's Strength
      -------------------------------------------------------------------------------}
      property Strength: UInt32 read GetStrength write SetStrength;
      {*------------------------------------------------------------------------------
      Agility Property. Reads/Sets Unit's Agility
      -------------------------------------------------------------------------------}
      property Agility: UInt32 read GetAgility write SetAgility;
      {*------------------------------------------------------------------------------
      Stamina Property. Reads/Sets Unit's Stamina
      -------------------------------------------------------------------------------}
      property Stamina: UInt32 read GetStamina write SetStamina;
      {*------------------------------------------------------------------------------
      Intellect Property. Reads/Sets Unit's Intellect
      -------------------------------------------------------------------------------}
      property Intellect: UInt32 read GetIntellect write SetIntellect;
      {*------------------------------------------------------------------------------
      Spirit Property. Reads/Sets Unit's Spirit
      -------------------------------------------------------------------------------}
      property Spirit: UInt32 read GetSpirit write SetSpirit;

                                    {-------------}
                                    { Additionals }
                                    {-------------}

      {*------------------------------------------------------------------------------
      Additional Strength Property. Reads/Sets Unit's Additional Strength
      -------------------------------------------------------------------------------}
      property AdditionalStrength: Integer read GetAdditionalStrength write SetAdditionalStrength;
      {*------------------------------------------------------------------------------
      Additional Agility Property. Reads/Sets Unit's Additional Agility
      -------------------------------------------------------------------------------}
      property AdditionalAgility: Integer read GetAdditionalAgility write SetAdditionalAgility;
      {*------------------------------------------------------------------------------
      Additional Stamina Property. Reads/Sets Unit's Additional Stamina
      -------------------------------------------------------------------------------}
      property AdditionalStamina: Integer read GetAdditionalStamina write SetAdditionalStamina;
      {*------------------------------------------------------------------------------
      Additional Intellect Property. Reads/Sets Unit's Additional Intellect
      -------------------------------------------------------------------------------}
      property AdditionalIntellect: Integer read GetAdditionalIntellect write SetAdditionalIntellect;
      {*------------------------------------------------------------------------------
      Additional Spirit Property. Reads/Sets Unit's Additional Spirit
      -------------------------------------------------------------------------------}
      property AdditionalSpirit: Integer read GetAdditionalSpirit write SetAdditionalSpirit;

                                    {-------------}
                                    { Resistances }
                                    {-------------}
      
      {*------------------------------------------------------------------------------
      Armor Resistance Property. Reads/Sets Unit's Armor Resistance
      -------------------------------------------------------------------------------}
      property ArmorResist: UInt32 read GetArmor write SetArmor;
      {*------------------------------------------------------------------------------
      Holly Resistance Property. Reads/Sets Unit's Holly Resistance
      -------------------------------------------------------------------------------}
      property HolyResist: UInt32 read GetHolyResist write SetHolyResist;
      {*------------------------------------------------------------------------------
      Fire Resistance Property. Reads/Sets Unit's Fire Resistance
      -------------------------------------------------------------------------------}
      property FireResist: UInt32 read GetFireResist write SetFireResist;
      {*------------------------------------------------------------------------------
      Nature Resistance Property. Reads/Sets Unit's Nature Resistance
      -------------------------------------------------------------------------------}
      property NatureResist: UInt32 read GetNatureResist write SetNatureResist;
      {*------------------------------------------------------------------------------
      Frost Resistance Property. Reads/Sets Unit's Frost Resistance
      -------------------------------------------------------------------------------}
      property FrostResist: UInt32 read GetFrostResist write SetFrostResist;
      {*------------------------------------------------------------------------------
      Shadow Resistance Property. Reads/Sets Unit's Shadow Resistance
      -------------------------------------------------------------------------------}
      property ShadowResist: UInt32 read GetShadowResist write SetShadowResist;
      {*------------------------------------------------------------------------------
      Arcane Resistance Property. Reads/Sets Unit's Arcane Resistance
      -------------------------------------------------------------------------------}
      property ArcaneResist: UInt32 read GetArcaneResist write SetArcaneResist;

                                    {------------------}
                                    { Attack & Related }
                                    {------------------}
      
      {*------------------------------------------------------------------------------
      High Part of the Base Attack Time Property. Reads/Sets Unit's High Part of the Base Attack Time
      -------------------------------------------------------------------------------}
      property BaseAttackTimeHi: UInt32 read GetBaseAttackTimeHi write SetBaseAttackTimeHi;
      {*------------------------------------------------------------------------------
      Low Part of the Base Attack Time Property. Reads/Sets Unit's Low Part of the Base Attack Time
      -------------------------------------------------------------------------------}
      property BaseAttackTimeLo: UInt32 read GetBaseAttackTimeLo write SetBaseAttackTimeLo;
      {*------------------------------------------------------------------------------
      Faction Property. Reads/Sets Unit's Faction
      -------------------------------------------------------------------------------}
      property Faction: UInt32 read GetFaction write SetFaction;
      {*------------------------------------------------------------------------------
      Bounding Radius Property. Reads/Sets Unit's Bounding Radius
      -------------------------------------------------------------------------------}
      property BoundingRadius: Float read GetBRadius write SetBRadius;
      {*------------------------------------------------------------------------------
      Combat Reach Property. Reads/Sets Unit's Combat Reach
      -------------------------------------------------------------------------------}
      property CombatReach: Float read GetCReach write SetCReach;
      {*------------------------------------------------------------------------------
      High Part of the Melee Attack Damage Property. Reads/Sets Unit's High Part of the Melee Attack Damage
      -------------------------------------------------------------------------------}
      property MeleeAttackDamageHi: Float read GetAttackDamageHi write SetAttackDamageHi;
      {*------------------------------------------------------------------------------
      Low Part of the Melee Attack Damage Property. Reads/Sets Unit's Low Part of the Melee Attack Damage
      -------------------------------------------------------------------------------}
      property MeleeAttackDamageLo: Float read GetAttackDamageLo write SetAttackDamageLo;
      {*------------------------------------------------------------------------------
      Melee Attack Power Property. Reads/Sets Unit's Melee Attack Power
      -------------------------------------------------------------------------------}
      property MeleeAttackPower:   UInt32 read GetAttackPower write SetAttackPower;
      {*------------------------------------------------------------------------------
      High Part of the OffHand Attack Damage Property. Reads/Sets Unit's High Part of the OffHand Attack Damage
      -------------------------------------------------------------------------------}
      property OffHandAttackDamageHi: Float read GetOffHandAttackDamageHi write SetOffHandAttackDamageHi;
      {*------------------------------------------------------------------------------
      Low Part of the OffHand Attack Damage Property. Reads/Sets Unit's Low Part of the OffHand Attack Damage
      -------------------------------------------------------------------------------}
      property OffHandAttackDamageLo: Float read GetOffHandAttackDamageLo write SetOffHandAttackDamageLo;
      {*------------------------------------------------------------------------------
      Offhand Attack Power Property. Reads/Sets Unit's Offhand Attack Power
      -------------------------------------------------------------------------------}
      property OffHandAttackPower:   UInt32 read GetAttackPower write SetAttackPower;
      {*------------------------------------------------------------------------------
      High Part of the Ranged Attack Damage Property. Reads/Sets Unit's High Part of the Ranged Attack Damage
      -------------------------------------------------------------------------------}
      property RangedAttackDamageHi: Float read GetRangedAttackDamageHi write SetRangedAttackDamageHi;
      {*------------------------------------------------------------------------------
      Low Part of the Ranged Attack Damage Property. Reads/Sets Unit's Low Part of the Ranged Attack Damage
      -------------------------------------------------------------------------------}
      property RangedAttackDamageLo: Float read GetRangedAttackDamageLo write SetRangedAttackDamageLo;
      {*------------------------------------------------------------------------------
      Ranged Attack Power Property. Reads/Sets Unit's Ranged Attack Power
      -------------------------------------------------------------------------------}
      property RangedAttackPower: UInt32 read GetRangedAttackPower write SetRangedAttackPower;
      {$ENDREGION}
    end;

implementation

  {$REGION 'Uses Clause'}
  uses
    Framework;
{$ENDREGION}


  {$REGION 'YGaUnit Methods'}
{*------------------------------------------------------------------------------
  Cleans Object Data

  @param paramname descr
-------------------------------------------------------------------------------}
procedure YGaUnit.CleanupObjectData;
begin
  inherited CleanupObjectData;
  /// >>> Requests also Pet Manager and Stats Manger to clean their Object Data
  fPetManager.CleanupObjectData;
  fStatManager.CleanupObjectData;
end;

{*------------------------------------------------------------------------------
  Extracts Object Data for a given Entry

  @param Entry The Entry that needs to be extracted from database
  @see YDbSerializable
-------------------------------------------------------------------------------}
procedure YGaUnit.ExtractObjectData(Entry: YDbSerializable);
begin
  inherited ExtractObjectData(Entry);
  /// >>> Also it will ask Pet and Stats managers to extract their data related with this given Entry
  fPetManager.ExtractObjectData(Entry);
  fStatManager.ExtractObjectData(Entry);
end;

{*------------------------------------------------------------------------------
  Saves Object Data for a given Entry

  @param Entry The Entry that needs to be extracted from database
  @see YDbSerializable
-------------------------------------------------------------------------------}
procedure YGaUnit.InjectObjectData(Entry: YDbSerializable);
begin
  inherited InjectObjectData(Entry);
  /// >>> Also it will ask Pet and Stats managers to save their data related with this given Entry
  fPetManager.InjectObjectData(Entry);
  fStatManager.InjectObjectData(Entry);
end;

{*------------------------------------------------------------------------------
  Function that will return the object's type
  hack: As this is in YGaUnit, it will have to return UPDATEFLAG_UNIT
  This is an overrided function

  @return UPDATEFLAG_UNIT (9)
  @see Components.GameCore.UpdateFields
-------------------------------------------------------------------------------}
class function YGaUnit.GetObjectType;
begin
  Result := UPDATEFLAG_UNIT;
end;

 {*------------------------------------------------------------------------------
  Function that will return the open object's type
  hack: As this is in YGaUnit, it will have to return otUnknown
  This is an overrided function

  @return otUnknown (10)
  @see Components.GameCore.UpdateFields
-------------------------------------------------------------------------------}
class function YGaUnit.GetOpenObjectType: YWowObjectType;
begin
  Result := otUnknown;
end;

{*------------------------------------------------------------------------------
  Destructor for YGaUnit class

-------------------------------------------------------------------------------}
destructor YGaUnit.Destroy;
begin
  /// Frees Pet Manager
  fPetManager.Free;
  /// Frees Stats Manager
  fStatManager.Free;
  /// Inherits Destroy.
  inherited Destroy;
end;

{*------------------------------------------------------------------------------
  Constructor for YGaUnit class

-------------------------------------------------------------------------------}
constructor YGaUnit.Create;
begin
  /// Inherits Create
  inherited Create;
  /// Creates the other components (Pet and Stat Managers)
  fPetManager := YGaPetMgr.Create(Self);
  fStatManager := YGaStatMgr.Create(Self);
end;

{*------------------------------------------------------------------------------
  This function prepares the updates so it will add current unit to world
  @see fUpdateHandle SystemTimer.RegisterEvent
-------------------------------------------------------------------------------}
procedure YGaUnit.AddToWorld;
begin
  /// Inherits AddToWorld
  inherited AddToWorld;
  /// Registers an Update Event Handler
  fUpdateHandle := SystemTimer.RegisterEvent(UnitLifeTimer, 100, TICK_EXECUTE_INFINITE, 'GaUnit_UnitLifeTimer');
end;

{*------------------------------------------------------------------------------
  This function is missing implementation
-------------------------------------------------------------------------------}
procedure YGaUnit.Regenerate;
begin
  { TODO -oALL -cYGaUnit : Missing implementation? }
end;

{*------------------------------------------------------------------------------
  This function prepares the updates so it will remove current unit from world
  @see fUpdateHandle
-------------------------------------------------------------------------------}
procedure YGaUnit.RemoveFromWorld;
begin
  /// Unregisters it from the Updates Handler
  fUpdateHandle.Unregister;
  /// Inherits removeFromWorld
  inherited RemoveFromWorld;
end;


{*------------------------------------------------------------------------------
  This function is missing implementation

  @param Event YEventHandle
  @param TimeDelta the time value for the event
-------------------------------------------------------------------------------}
procedure YGaUnit.UnitLifeTimer(Event: TEventHandle; TimeDelta: UInt32);
begin
  { TODO -oALL -cYGaUnit : Missing implementation? }
end;
  {$ENDREGION}


  {$REGION 'YUnitComponent Methods'}
{*------------------------------------------------------------------------------
  Constructor for YGaUnitComponent
  Only applies owner

  @param Owner YGaMobile
-------------------------------------------------------------------------------}
constructor YGaUnitComponent.Create(Owner: YGaMobile);
begin
  fOwner := Owner;
end;
  {$ENDREGION}


  {$REGION 'YPetMgr Methods'}
{*------------------------------------------------------------------------------
Cleans Object data

As pets are not implemented yet, this is a stub method. Ignored.
-------------------------------------------------------------------------------}
procedure YGaPetMgr.CleanupObjectData;
begin
end;

{*------------------------------------------------------------------------------
Extracts (Loads) Object data

As pets are not implemented yet, this is a stub method. Ignored.
@param Entry The ID of the unit
@see YDbSerializable
-------------------------------------------------------------------------------}
procedure YGaPetMgr.ExtractObjectData(Entry: YDbSerializable);
begin
end;

{*------------------------------------------------------------------------------
Injects (Saves) Object data

As pets are not implemented yet, this is a stub method. Ignored.
@param Entry The ID of the unit
@see YDbSerializable
-------------------------------------------------------------------------------}
procedure YGaPetMgr.InjectObjectData(Entry: YDbSerializable);
begin
end;

{*------------------------------------------------------------------------------
Function that returns Pet's family type

As pets are not implemented yet, this is a stub method. Ignored.
@return 0(zero) as Pets are not implemented yet
-------------------------------------------------------------------------------}
function YGaPetMgr.GetPetFamily: UInt32;
begin
  Result := 0;
end;

{*------------------------------------------------------------------------------
Function that returns Pet's ID

As pets are not implemented yet, this is a stub method. Ignored.
@return 0(zero) as Pets are not implemented yet
-------------------------------------------------------------------------------}
function YGaPetMgr.GetPetId: UInt32;
begin
  Result := 0;
end;

{*------------------------------------------------------------------------------
Function that returns Pet's Level

As pets are not implemented yet, this is a stub method. Ignored.
@return 0(zero) as Pets are not implemented yet
-------------------------------------------------------------------------------}
function YGaPetMgr.GetPetLevel: UInt32;
begin
  Result := 0;
end;
  {$ENDREGION}


  {$REGION 'YStatMgr Methods'}
{*------------------------------------------------------------------------------
Cleans Object data

This is a stub method. Ignored.
-------------------------------------------------------------------------------}
procedure YGaStatMgr.CleanupObjectData;
begin
end;

{*------------------------------------------------------------------------------
Extracts (Loads) Object data

This is a stub method. Ignored.
@param Entry The ID of the unit
@see YDbSerializable
-------------------------------------------------------------------------------}
procedure YGaStatMgr.ExtractObjectData(Entry: YDbSerializable);
begin
end;

{*------------------------------------------------------------------------------
Injects (Saves) Object data

This is a stub method. Ignored.
@param Entry The ID of the unit
@see YDbSerializable
-------------------------------------------------------------------------------}
procedure YGaStatMgr.InjectObjectData(Entry: YDbSerializable);
begin
end;

                             {-----------------------------}
                             { Write methods for properties}
                             {-----------------------------}

{*------------------------------------------------------------------------------
  Setting a New Agility value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_STAT1
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetAgility(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_STAT1, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Actual Health value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_HEALTH
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetActualHealth(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_HEALTH, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Actual Power value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_POWER1
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetActualPower(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_POWER1 + UInt8(PowerType), Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Additional Agility value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_POSSTAT1
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetAdditionalAgility(const Value: Integer);
begin
  //Owner.SetUInt32(PLAYER_FIELD_POSSTAT1, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Additional Intellect value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_POSSTAT3
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetAdditionalIntellect(const Value: Integer);
begin
  //Owner.SetUInt32(PLAYER_FIELD_POSSTAT3, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Additional Spirit value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_POSSTAT4
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetAdditionalSpirit(const Value: Integer);
begin
  //Owner.SetUInt32(PLAYER_FIELD_POSSTAT4, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Additional Stamina value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_POSSTAT2
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetAdditionalStamina(const Value: Integer);
begin
  //Owner.SetUInt32(PLAYER_FIELD_POSSTAT2, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Additional Strength value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_POSSTAT3
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetAdditionalStrength(const Value: Integer);
begin
  //Owner.SetUInt32(PLAYER_FIELD_POSSTAT3, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Armor value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_RESISTANCES
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetArmor(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_RESISTANCES + 0, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Maximum Attack Damage value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_MAXDAMAGE
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetAttackDamageHi(const Value: Float);
begin
  Owner.SetFloat(UNIT_FIELD_MAXDAMAGE, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Minimum Attack Damage value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_MINDAMAGE
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetAttackDamageLo(const Value: Float);
begin
  Owner.SetFloat(UNIT_FIELD_MINDAMAGE, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Attack Power value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_ATTACK_POWER
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetAttackPower(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_ATTACK_POWER, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Maximum Attack Time value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_BASEATTACKTIME
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetBaseAttackTimeHi(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_BASEATTACKTIME + 1, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Minimum Attack Time value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_BASEATTACKTIME
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetBaseAttackTimeLo(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_BASEATTACKTIME, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Bounding Radius value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_BOUNDINGRADIUS
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetBRadius(const Value: Float);
begin
  Owner.SetFloat(UNIT_FIELD_BOUNDINGRADIUS, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Class value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_BYTES_0
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetClass(Value: YGameClass);
begin
  Owner.SetUInt8(UNIT_FIELD_BYTES_0, BYTE_CLASS, UInt8(Value));
end;

{*------------------------------------------------------------------------------
  Setting a New Combat Reach value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_COMBATREACH
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetCReach(const Value: Float);
begin
  Owner.SetFloat(UNIT_FIELD_COMBATREACH, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Gender value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_BYTES_0
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetGender(Value: YGameGender);
begin
  Owner.SetUInt8(UNIT_FIELD_BYTES_0, BYTE_GENDER, UInt8(Value));
end;

{*------------------------------------------------------------------------------
  Setting a New Intellect value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_STAT3
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetIntellect(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_STAT3, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Level value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_LEVEL
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetLevel(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_LEVEL, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Maximum Health value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_MAXHEALTH
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetMaxHealth(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_MAXHEALTH, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Maximum Power value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_MAXPOWER1
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetMaxPower(Value: UInt32);
begin
  /// This one depends on unit's power type (e.g. rage/mana/etc)
  Owner.SetUInt32(UNIT_FIELD_MAXPOWER1 + UInt8(PowerType), Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Power Type value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_BYTES_0
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetPowerType(Value: YGamePowerType);
begin
  Owner.SetUInt8(UNIT_FIELD_BYTES_0, BYTE_POWER, UInt8(Value));
end;

{*------------------------------------------------------------------------------
  Setting a New Race value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_BYTES_0
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetRace(Value: YGameRace);
begin
  Owner.SetUInt8(UNIT_FIELD_BYTES_0, BYTE_RACE, UInt8(Value));
end;

{*------------------------------------------------------------------------------
  Setting a New Maximum Ranged Attack Damage value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_MAXRANGEDDAMAGE
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetRangedAttackDamageHi(const Value: Float);
begin
  Owner.SetFloat(UNIT_FIELD_MAXRANGEDDAMAGE, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Minimum Ranged Attack Damage value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_MINRANGEDDAMAGE
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetRangedAttackDamageLo(const Value: Float);
begin
  Owner.SetFloat(UNIT_FIELD_MINRANGEDDAMAGE, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Ranged Attack Power value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_RANGED_ATTACK_POWER
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetRangedAttackPower(const Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_RANGED_ATTACK_POWER, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Spirit value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_STAT4
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetSpirit(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_STAT4, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Stamina value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_STAT2
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetStamina(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_STAT2, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Strength value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_STAT0
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetStrength(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_STAT0, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Arcane Resistance value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_RESISTANCES
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetArcaneResist(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_RESISTANCES + 6, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Faction Template value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_FACTIONTEMPLATE
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetFaction(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_FACTIONTEMPLATE, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Fire Resistance value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_RESISTANCES
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetFireResist(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_RESISTANCES + 2, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Frost Resistance value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_RESISTANCES
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetFrostResist(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_RESISTANCES + 4, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Holy Resistance value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_RESISTANCES
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetHolyResist(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_RESISTANCES + 1, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Nature Resistance value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_RESISTANCES
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetNatureResist(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_RESISTANCES + 3, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Maximum OffHand Attack Damage value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_MAXOFFHANDDAMAGE
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetOffHandAttackDamageHi(const Value: Float);
begin
  Owner.SetFloat(UNIT_FIELD_MAXOFFHANDDAMAGE, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Minimum OffHand Attack Damage value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_MINOFFHANDDAMAGE
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetOffHandAttackDamageLo(const Value: Float);
begin
  Owner.SetFloat(UNIT_FIELD_MINOFFHANDDAMAGE, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Shadow Resistance value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_RESISTANCES
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetShadowResist(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_RESISTANCES + 5, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Native Model value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_NATIVEDISPLAYID
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetModel(Value: UInt32);
begin
  CurrentModel := Value;
  Owner.SetUInt32(UNIT_FIELD_NATIVEDISPLAYID, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New MountID value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_MOUNTDISPLAYID
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetMount(const Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_MOUNTDISPLAYID, Value);
end;

{*------------------------------------------------------------------------------
  Setting a New Current Model ID value

  @param Value The new value that will be assigned
  @see UNIT_FIELD_DISPLAYID
-------------------------------------------------------------------------------}
procedure YGaStatMgr.SetCurrentModel(Value: UInt32);
begin
  Owner.SetUInt32(UNIT_FIELD_DISPLAYID, Value);
end;

                             {----------------------------}
                             { Read methods for properties}
                             {----------------------------}

{*------------------------------------------------------------------------------
  Reads Actual Health

  @return UNIT_FIELD_HEALTH
  @see UNIT_FIELD_HEALTH
-------------------------------------------------------------------------------}
function YGaStatMgr.GetActualHealth: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_HEALTH);
end;

{*------------------------------------------------------------------------------
  Reads Actual Power

  @return UNIT_FIELD_POWER1
  @see UNIT_FIELD_POWER1
-------------------------------------------------------------------------------}
function YGaStatMgr.GetActualPower: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_POWER1 + UInt8(PowerType));
end;

{*------------------------------------------------------------------------------
  Reads Additional Agility

  @return PLAYER_FIELD_POSSTAT1
  @see PLAYER_FIELD_POSSTAT1
-------------------------------------------------------------------------------}
function YGaStatMgr.GetAdditionalAgility: Integer;
begin
  //Result := Owner.GetUInt32(PLAYER_FIELD_POSSTAT1);
end;

{*------------------------------------------------------------------------------
  Reads Additional Intellect

  @return PLAYER_FIELD_POSSTAT3
  @see PLAYER_FIELD_POSSTAT3
-------------------------------------------------------------------------------}
function YGaStatMgr.GetAdditionalIntellect: Integer;
begin
  //Result := Owner.GetUInt32(PLAYER_FIELD_POSSTAT3);
end;

{*------------------------------------------------------------------------------
  Reads Additional Spirit

  @return PLAYER_FIELD_POSSTAT4
  @see PLAYER_FIELD_POSSTAT4
-------------------------------------------------------------------------------}
function YGaStatMgr.GetAdditionalSpirit: Integer;
begin
  //Result := Owner.GetUInt32(PLAYER_FIELD_POSSTAT4);
end;

{*------------------------------------------------------------------------------
  Reads Additional Stamina

  @return PLAYER_FIELD_POSSTAT2
  @see PLAYER_FIELD_POSSTAT2
-------------------------------------------------------------------------------}
function YGaStatMgr.GetAdditionalStamina: Integer;
begin
  //Result := Owner.GetUInt32(PLAYER_FIELD_POSSTAT2);
end;

{*------------------------------------------------------------------------------
  Reads Additional Strength

  @return PLAYER_FIELD_POSSTAT0
  @see PLAYER_FIELD_POSSTAT0
-------------------------------------------------------------------------------}
function YGaStatMgr.GetAdditionalStrength: Integer;
begin
  //Result := Owner.GetUInt32(PLAYER_FIELD_POSSTAT0);
end;

{*------------------------------------------------------------------------------
  Reads Agility

  @return UNIT_FIELD_STAT1
  @see UNIT_FIELD_STAT1
-------------------------------------------------------------------------------}
function YGaStatMgr.GetAgility: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_STAT1);
end;

{*------------------------------------------------------------------------------
  Reads Arcane Resistance

  @return UNIT_FIELD_RESISTANCES
  @see UNIT_FIELD_RESISTANCES
-------------------------------------------------------------------------------}
function YGaStatMgr.GetArcaneResist: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_RESISTANCES + 6);
end;

{*------------------------------------------------------------------------------
  Reads Armor

  @return UNIT_FIELD_RESISTANCES
  @see UNIT_FIELD_RESISTANCES
-------------------------------------------------------------------------------}
function YGaStatMgr.GetArmor: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_RESISTANCES + 0);
end;

{*------------------------------------------------------------------------------
  Reads the Maximum Attack Damage

  @return UNIT_FIELD_MAXDAMAGE
  @see UNIT_FIELD_MAXDAMAGE
-------------------------------------------------------------------------------}
function YGaStatMgr.GetAttackDamageHi: Float;
begin
  Result := Owner.GetFloat(UNIT_FIELD_MAXDAMAGE);
end;

{*------------------------------------------------------------------------------
  Reads the Minimum Attack Damage

  @return UNIT_FIELD_MINDAMAGE
  @see UNIT_FIELD_MINDAMAGE
-------------------------------------------------------------------------------}
function YGaStatMgr.GetAttackDamageLo: Float;
begin
  Result := Owner.GetFloat(UNIT_FIELD_MINDAMAGE);
end;

{*------------------------------------------------------------------------------
  Reads the Attack Power

  @return UNIT_FIELD_ATTACK_POWER
  @see UNIT_FIELD_ATTACK_POWER
-------------------------------------------------------------------------------}
function YGaStatMgr.GetAttackPower: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_ATTACK_POWER);
end;

{*------------------------------------------------------------------------------
  Reads the Maximum Base Attack Time

  @return UNIT_FIELD_BASEATTACKTIME
  @see UNIT_FIELD_BASEATTACKTIME
-------------------------------------------------------------------------------}
function YGaStatMgr.GetBaseAttackTimeHi: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_BASEATTACKTIME + 1);
end;

{*------------------------------------------------------------------------------
  Reads the Minimum Base Attack Time

  @return UNIT_FIELD_BASEATTACKTIME
  @see UNIT_FIELD_BASEATTACKTIME
-------------------------------------------------------------------------------}
function YGaStatMgr.GetBaseAttackTimeLo: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_BASEATTACKTIME);
end;

{*------------------------------------------------------------------------------
  Reads the Bounding Radius

  @return UNIT_FIELD_BOUNDINGRADIUS
  @see UNIT_FIELD_BOUNDINGRADIUS
-------------------------------------------------------------------------------}
function YGaStatMgr.GetBRadius: Float;
begin
  Result := Owner.GetFloat(UNIT_FIELD_BOUNDINGRADIUS);
end;

{*------------------------------------------------------------------------------
  Reads the Current Model ID

  @return UNIT_FIELD_DISPLAYID
  @see UNIT_FIELD_DISPLAYID
-------------------------------------------------------------------------------}
function YGaStatMgr.GetCurrentModel: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_DISPLAYID);
end;

{*------------------------------------------------------------------------------
  Reads the Faction Template

  @return UNIT_FIELD_FACTIONTEMPLATE
  @see UNIT_FIELD_FACTIONTEMPLATE
-------------------------------------------------------------------------------}
function YGaStatMgr.GetFaction: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_FACTIONTEMPLATE);
end;

{*------------------------------------------------------------------------------
  Reads the Fire Resistance

  @return UNIT_FIELD_RESISTANCES
  @see UNIT_FIELD_RESISTANCES
-------------------------------------------------------------------------------}
function YGaStatMgr.GetFireResist: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_RESISTANCES + 2);
end;

{*------------------------------------------------------------------------------
  Reads the Frost Resistance

  @return UNIT_FIELD_RESISTANCES
  @see UNIT_FIELD_RESISTANCES
-------------------------------------------------------------------------------}
function YGaStatMgr.GetFrostResist: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_RESISTANCES + 4);
end;

{*------------------------------------------------------------------------------
  Reads the Game Class of the unit involved

  @return UNIT_FIELD_BYTES_0
  @see UNIT_FIELD_BYTES_0
-------------------------------------------------------------------------------}
function YGaStatMgr.GetClass: YGameClass;
begin
  Result := YGameClass(Owner.GetUInt8(UNIT_FIELD_BYTES_0, BYTE_CLASS));
end;

{*------------------------------------------------------------------------------
  Reads the Combat Reach

  @return UNIT_FIELD_COMBATREACH
  @see UNIT_FIELD_COMBATREACH
-------------------------------------------------------------------------------}
function YGaStatMgr.GetCReach: Float;
begin
  Result := Owner.GetFloat(UNIT_FIELD_COMBATREACH);
end;

{*------------------------------------------------------------------------------
  Reads the Game Gender of the unit involved

  @return UNIT_FIELD_BYTES_0
  @see UNIT_FIELD_BYTES_0
-------------------------------------------------------------------------------}
function YGaStatMgr.GetGender: YGameGender;
begin
  Result := YGameGender(Owner.GetUInt8(UNIT_FIELD_BYTES_0, BYTE_GENDER));
end;

{*------------------------------------------------------------------------------
  Reads the Power Type of the unit involved

  @return UNIT_FIELD_BYTES_0
  @see UNIT_FIELD_BYTES_0
-------------------------------------------------------------------------------}
function YGaStatMgr.GetPowerType: YGamePowerType;
begin
  Result := YGamePowerType(Owner.GetUInt8(UNIT_FIELD_BYTES_0, BYTE_POWER));
end;

{*------------------------------------------------------------------------------
  Reads the Game Race of the unit involved

  @return UNIT_FIELD_BYTES_0
  @see UNIT_FIELD_BYTES_0
-------------------------------------------------------------------------------}
function YGaStatMgr.GetRace: YGameRace;
begin
  Result := YGameRace(Owner.GetUInt8(UNIT_FIELD_BYTES_0, BYTE_RACE));
end;

{*------------------------------------------------------------------------------
  Reads the Maximum Ranged Attack Damage

  @return UNIT_FIELD_MAXRANGEDDAMAGE
  @see UNIT_FIELD_MAXRANGEDDAMAGE
-------------------------------------------------------------------------------}
function YGaStatMgr.GetRangedAttackDamageHi: Float;
begin
  Result := Owner.GetFloat(UNIT_FIELD_MAXRANGEDDAMAGE);
end;

{*------------------------------------------------------------------------------
  Reads the Minimum Ranged Attack Damage

  @return UNIT_FIELD_MINRANGEDDAMAGE
  @see UNIT_FIELD_MINRANGEDDAMAGE
-------------------------------------------------------------------------------}
function YGaStatMgr.GetRangedAttackDamageLo: Float;
begin
  Result := Owner.GetFloat(UNIT_FIELD_MINRANGEDDAMAGE);
end;

{*------------------------------------------------------------------------------
  Reads the Ranged Attack Power

  @return UNIT_FIELD_RANGED_ATTACK_POWER
  @see UNIT_FIELD_RANGED_ATTACK_POWER
-------------------------------------------------------------------------------}
function YGaStatMgr.GetRangedAttackPower: UInt32;
begin
 Result := Owner.GetUInt32(UNIT_FIELD_RANGED_ATTACK_POWER);
end;

{*------------------------------------------------------------------------------
  Reads the Holy Resistance

  @return UNIT_FIELD_RESISTANCES
  @see UNIT_FIELD_RESISTANCES
-------------------------------------------------------------------------------}
function YGaStatMgr.GetHolyResist: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_RESISTANCES + 1);
end;

{*------------------------------------------------------------------------------
  Reads the Intellect value

  @return UNIT_FIELD_STAT3
  @see UNIT_FIELD_STAT3
-------------------------------------------------------------------------------}
function YGaStatMgr.GetIntellect: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_STAT3);
end;

{*------------------------------------------------------------------------------
  Reads the Level value

  @return UNIT_FIELD_LEVEL
  @see UNIT_FIELD_LEVEL
-------------------------------------------------------------------------------}
function YGaStatMgr.GetLevel: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_LEVEL);
end;

{*------------------------------------------------------------------------------
  Reads the Maximum Health value

  @return UNIT_FIELD_MAXHEALTH
  @see UNIT_FIELD_MAXHEALTH
-------------------------------------------------------------------------------}
function YGaStatMgr.GetMaxHealth: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_MAXHEALTH);
end;

{*------------------------------------------------------------------------------
  Reads the Maximum Power value

  @return UNIT_FIELD_MAXPOWER1
  @see UNIT_FIELD_MAXPOWER1
-------------------------------------------------------------------------------}
function YGaStatMgr.GetMaxPower: UInt32;
begin
  /// This depends on unit's power type (e.g. mana/rage/etc)
  Result := Owner.GetUInt32(UNIT_FIELD_MAXPOWER1 + UInt8(PowerType));
end;

{*------------------------------------------------------------------------------
  Reads the Model ID value

  @return UNIT_FIELD_NATIVEDISPLAYID
  @see UNIT_FIELD_NATIVEDISPLAYID
-------------------------------------------------------------------------------}
function YGaStatMgr.GetModel: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_NATIVEDISPLAYID);
end;

{*------------------------------------------------------------------------------
  Reads the Mount ID value

  @return UNIT_FIELD_MOUNTDISPLAYID
  @see UNIT_FIELD_MOUNTDISPLAYID
-------------------------------------------------------------------------------}
function YGaStatMgr.GetMount: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_MOUNTDISPLAYID);
end;

{*------------------------------------------------------------------------------
  Reads the Nature Resistance

  @return UNIT_FIELD_RESISTANCES
  @see UNIT_FIELD_RESISTANCES
-------------------------------------------------------------------------------}
function YGaStatMgr.GetNatureResist: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_RESISTANCES + 3);
end;

{*------------------------------------------------------------------------------
  Reads the Maximum OffHand Attack Damage

  @return UNIT_FIELD_MAXOFFHANDDAMAGE
  @see UNIT_FIELD_MAXOFFHANDDAMAGE
-------------------------------------------------------------------------------}
function YGaStatMgr.GetOffHandAttackDamageHi: Float;
begin
  Result := Owner.GetFloat(UNIT_FIELD_MAXOFFHANDDAMAGE);
end;

{*------------------------------------------------------------------------------
  Reads the Minimum OffHand Attack Damage

  @return UNIT_FIELD_MINOFFHANDDAMAGE
  @see UNIT_FIELD_MINOFFHANDDAMAGE
-------------------------------------------------------------------------------}
function YGaStatMgr.GetOffHandAttackDamageLo: Float;
begin
  Result := Owner.GetFloat(UNIT_FIELD_MINOFFHANDDAMAGE);
end;

{*------------------------------------------------------------------------------
  Reads the Shadow Resistance

  @return UNIT_FIELD_RESISTANCES
  @see UNIT_FIELD_RESISTANCES
-------------------------------------------------------------------------------}
function YGaStatMgr.GetShadowResist: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_RESISTANCES + 5);
end;

{*------------------------------------------------------------------------------
  Reads the Spirit Value

  @return UNIT_FIELD_STAT4
  @see UNIT_FIELD_STAT4
-------------------------------------------------------------------------------}
function YGaStatMgr.GetSpirit: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_STAT4);
end;

{*------------------------------------------------------------------------------
  Reads the Stamine Value

  @return UNIT_FIELD_STAT2
  @see UNIT_FIELD_STAT2
-------------------------------------------------------------------------------}
function YGaStatMgr.GetStamina: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_STAT2);
end;

{*------------------------------------------------------------------------------
  Reads the Strength Value

  @return UNIT_FIELD_STAT0
  @see UNIT_FIELD_STAT0
-------------------------------------------------------------------------------}
function YGaStatMgr.GetStrength: UInt32;
begin
  Result := Owner.GetUInt32(UNIT_FIELD_STAT0);
end;
{$ENDREGION}

end.
