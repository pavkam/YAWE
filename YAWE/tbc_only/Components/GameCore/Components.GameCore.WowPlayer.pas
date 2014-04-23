{*------------------------------------------------------------------------------
  WOW Player and all it's components
  WOW Player Components:
  - Equipment
  - Chat Manager
  - Experience
  - Action Buttons
  - Tutorials
  - Skills
  - Guild Manager
  - Honor
  - Trade system
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author PavkaM
  @Changes TheSelby, Seth, BigBoss, Morpheus
  @Docs TheSelby, Morpheus
  @TODO Quests Manager, Game Master component
-------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.WowPlayer;

interface

{$REGION 'Uses Clause'}
uses
  Bfg.Utils,
  Bfg.Threads,
  Bfg.Classes,
  Math,
  SysUtils,
  Classes,
  DateUtils,
  Bfg.Geometry,
  Bfg.Algorithm,
  Bfg.Containers,
  Framework.Base,
  Framework.Tick,
  Components.DataCore,
  Components.NetworkCore.Packet,
  Components.Shared,
  Components.Interfaces,
  Components.NetworkCore.Opcodes,
  Components.GameCore.Constants,
  Components.GameCore.Types,
  Components.DataCore.Types,
  Components.GameCore.UpdateFields,
  Components.GameCore.WowContainer,
  Components.GameCore.Component,
  Components.GameCore.WowObject,
  Components.GameCore.WowMobile,
  Components.GameCore.WowUnit,
  Components.GameCore.PacketBuilders,
  Components.GameCore.Guilds,
  Components.GameCore.WowItem,
  Components.GameCore.Interfaces,
  Components.GameCore.WowCreature;
{$ENDREGION}

type
  YGaPlayer = class;

  {*----------------------------------------------------------------------------
  WOW Player Base Class
  Derives from YGaUnit and uses IObject, IMobile, IUnit and IPlayer interfaces

  Manages sub components with prefix.

    Btn -> Action Buttons Component
    Eqp -> Equip Component
    Exp -> Experience Component
    Gld -> Guild Component
    PvP -> PvP(Honor) Component
    Tut -> Tutorials Component
    Skl -> Skills Component

  @see IObject
  @see IMobile
  @see IUnit
  @see YGaUnit
  @see IPlayer
  -----------------------------------------------------------------------------}
  YGaPlayer = class(YGaUnit)
    private
      {$REGION 'Private members'}
      FSessionLink: ISessionInterface;                                         /// Interfaced Session link used to send packets. Reference to ISessionInterface Interface.
      FCharacterName: string;                                                  /// Character's Name
      FInRealm: string;                                                        /// In which realm the player is logedin
      FInBG: Boolean;                                                          /// Saves whether the player is in  BattleGround or not
      FMyUpdates: YNwPacket;                                                   /// Character's Updates Packet
      FMyUpdateCount: Int32;                                                   /// Character's Updates count
      FMemberInChannels: TStrArrayList;                                        /// Array with the channels in which this character is a member
      FLock: TCriticalSection;                                                 /// Critical Section Locker
      FAccount: WideString;                                                    /// Account name
      FGldInvite: UInt32;                                                      /// Guild Inviation id.
      FGldEntry: YGaGuild;                                                     /// Pointer to player`s guild.
      FExpRestedState: UInt8;                                                  /// Player's rested state. If the value is greater than 30 then the player is considered to be rested.
      FBtnActionButtons: array[0..PLAYER_MAXIMUM_ACTION_BUTTONS] of UInt32;    /// Action buttons array having a maximum of PLAYER_MAXIMUM_ACTION_BUTTONS buttons (10 button bars * 12 per bar)
      FTutTutorials: array[0..PLAYER_MAXIMUM_TUTORIALS] of UInt32;             /// Tutorials array having a maximum number of PLAYER_MAXIMUM_TUTORIALS (7) members
      FTrdCopper: UInt32;                                                      /// Copper to trade
      FTrdTrader: YGaPlayer;                                                   /// The trader (YGaPlayer)
      FTrdItems: YTradeItemArray;                                              /// Items array
      FTrdAccept: Boolean;                                                     /// Boolean value if accepts the trade or not
      FEqpItems: YEquipment;                                                   /// Player's Items (equipped or in backpack)
      FEqpTempItem: YPrevItemUsed;                                             /// Saves previous item used before using a new one

      function GetAccountName: string; inline;
      function GetFace: UInt8; inline;
      function GetFacialHair: UInt8; inline;
      function GetHairColor: UInt8; inline;
      function GetHairStyle: UInt8; inline;
      function GetSkin: UInt8; inline;
      procedure SetFace(const Value: UInt8); inline;
      procedure SetFacialHair(const Value: UInt8); inline;
      procedure SetHairColor(const Value: UInt8); inline;
      procedure SetHairStyle(const Value: UInt8); inline;
      procedure SetSkin(const Value: UInt8); inline;

      { Sub components starts here }

      procedure GldSetId(const Value: UInt32);
      procedure GldSetRank(const Value: UInt32);
      function GldGetId: UInt32;
      function GldGetRank: UInt32;

      function ExpGetRestState: Boolean;

      function PvPMgrGetRank: UInt8;
      procedure PvPMgrSetRank(const Value: UInt8);

      procedure BtnAddButton(iButtonIdx: UInt8; iValue: UInt32);
      function BtnReadButton(iButtonIdx: UInt8): UInt32;

      function SklGetSkillCrr(iIndex: UInt32): UInt16;
      function SklGetSkillId(iIndex: UInt32): UInt32;
      function SklGetSkillMax(iIndex: UInt32): UInt16;
      procedure SklSetSkillCrr(iIndex: UInt32; const Value: UInt16);
      procedure SklSetSkillId(iIndex: UInt32; const Value: UInt32);
      procedure SklSetSkillMax(iIndex: UInt32; const Value: UInt16);
      function SklGetSkillCount: UInt32;
      function SklRetreiveSkillData(iSkillLine, iPiece: UInt32): UInt32; { Retreives a specific part of the line }
      procedure SklSaveSkillData(iSkillLine, iInt, iPiece: UInt32); { Saves a specific part of the line }

      function TutGetTutFlag(iIndex: UInt32): Boolean;
      procedure TutSetTutFlag(iIndex: UInt32; const bValue: Boolean);

      function EqpGetMoney: UInt32; inline;
      function EqpGetEquipedItem(iSlot: UInt32): YGaItem; inline;
      function EqpGetBag(iSlot: UInt32): YGaContainer; inline;
      function EqpGetBackpackItem(iSlot: UInt32): YGaItem; inline;
      function EqpGetBankItem(iSlot: UInt32): YGaItem; inline;
      function EqpGetBankBag(iSlot: UInt32): YGaContainer; inline;
      function EqpGetBuybackItem(iSlot: UInt32): YGaItem; inline;
      function EqpGetKeyringItem(iSlot: UInt32): YGaItem; inline;
      function EqpCanPlayerWearItem(iSlot: UInt8; iEntry: UInt32): UInt8;
      procedure EqpInternalSwap(iSlot1, iSlot2: UInt8); overload;
      procedure EqpInternalSwap(iSlot1, iSlot2, iBag1, iBag2: UInt8); overload;
      procedure EqpSendItemReceiveMessage(bReward, bCreated, bHideMessage: Boolean;iUnk, iItem, iAmount: UInt32; iBag: UInt8);
      procedure EqpSetMoney(iMoney: UInt32); inline;
      {$ENDREGION}
    protected
      {$REGION 'Protected members'}
      class function GetObjectType: Int32; override;
      class function GetOpenObjectType: YWowObjectType; override;

      { Override this in children to perform resource loading }
      procedure ExtractObjectData(const Entry: ISerializable); override;
      { Override this in children to perform resource saving }
      procedure InjectObjectData(const Entry: ISerializable); override;
      { Override this in children to perform resource deletion }
      procedure CleanupObjectData; override;

      procedure EnterWorld; override;
      procedure LeaveWorld; override;

      procedure SetCreationParams(out UpdateType: UInt8; UpdatingSelf: Boolean); override;
      procedure AddMovementData(Pkt: YNwServerPacket; UpdatingSelf: Boolean); override;

      procedure RequestUpdatesFromObject(Obj: YGaMobile; Request: YUpdateRequest); override;
      {$ENDREGION}
    public
      {$REGION 'Public members'}
      constructor Create; override;
      destructor Destroy; override;

      procedure CreateFromTemplate(TpStore: YDbCharTemplateStore; GameClass: YGameClass;       /// Template Creation
        GameRace: YGameRace; Gender: YGameGender);

      procedure PlayerLifeTimer(Event: TEventHandle; TimeDelta: UInt32);                       /// This function gets called every few world ticks
      procedure AddUpdateBlock(Block: YNwPacket);



      procedure SendSystemMessage(const sMessage: string); overload;                           /// Send a system message to the player
      procedure SendSystemMessageRaw(const pMessage: PChar; iLen: Int32); overload;            /// Send a system message to the player (PCHAR)
      procedure SendSystemMessageColored(const sMessage: string; cColor: ColorCode); overload; /// Send a system message to the player
      procedure SendSystemMessageRawColored(const pMessage: PChar; iLen: Int32; cColor: ColorCode); overload; /// Send a system message to the player (PCHAR)
      procedure SendMessageDispatchedInRange(iType: UInt8; iLanguage: YGameLanguage; const sMessage, sChannel: string; const fRange: Float; bMeAlso: Boolean);  { Dispatch a chat message to all nearby players }
      procedure SendPacket(Pkt: YNwServerPacket); inline;

      procedure OnValuesUpdate; override;

      property Account: WideString read FAccount write FAccount;                               /// Accesses Acount Name (R)
      property Name: string read fCharacterName write fCharacterName;                          /// Accesses character's name (R/W)
      property InRealmName: string read fInRealm write fInRealm;                               /// Accesses fInRealm private member (R/W)
      property InBattleGround: boolean read FInBG write FInBG;                                 /// Sets/gets "In Battleground" status (R/W)
      property Session: ISessionInterface read fSessionLink write fSessionLink;                /// Sets/Gets Session Interface (R/W)
      property Skin: UInt8 read GetSkin write SetSkin;                                         /// Accesses Skin property (R/W)
      property Face: UInt8 read GetFace write SetFace;                                         /// Accesses Face property (R/W)
      property HairStyle: UInt8 read GetHairStyle write SetHairStyle;                          /// Accesses Hair Style property (R/W)
      property HairColor: UInt8 read GetHairColor write SetHairColor;                          /// Accesses Hair Color property (R/W)
      property FacialHair: UInt8 read GetFacialHair write SetFacialHair;                       /// Accesses Facial Hair property (R/W)
      property Channels: TStrArrayList read fMemberInChannels;                                 /// Reads Channels Membership list (R)

      { Guild }
      property GldId: UInt32 read GldGetId write GldSetId;                                     /// Accesses Guild's ID (R/W)
      property GldRank: UInt32 read GldGetRank write GldSetRank;                               /// Accesses Guild's Rank (R/W)
      property GldInviation: UInt32 read FGldInvite write FGldInvite;                          /// Player`s guild Inviation (R/W)
      property Guild: YGaGuild read FGldEntry write FGldEntry;                                 /// Pointer to Player`s guild, nil if player isnt part of one (R/W)

      { Experience }
      property ExpSetRestedPercentage: UInt8 read FExpRestedState write FExpRestedState;       /// Rested Percentage (R/W)
      property ExpIsRested: Boolean read ExpGetRestState;                                      /// Property that reads if the player is rested ot not (R)

      { PvP }
      property Rank: UInt8 read PvPMgrGetRank write PvPMgrSetRank;                             /// Accesses player's PVPRank (R/W)

      { Buttons }

      property Buttons[iButtonIdx: UInt8]: UInt32 read BtnReadButton write BtnAddButton;       /// Accesses player`s action buttons (R/W)
      procedure BtnSendActionButtons;

      { Skills }

      function SklAddNewSkill(iSkillId: UInt32; iSkillKnown, iSkillMax: UInt32): Int32;        /// Adds a new skill to player and returns the index 
      function SklHasSkill(iSkillId: UInt32): Boolean;                                         /// Checks to see if the player knows this skill }
      property SklSkillId[iIndex: UInt32]: UInt32 read SklGetSkillId  write SklSetSkillId;     /// Accesses Skill's ID (R/W)
      property SklSkillCurrent[iIndex: UInt32]: UInt16 read SklGetSkillCrr write SklSetSkillCrr; /// Accesses Skill's Current Value (R/W)
      property SklSkillMax[iIndex: UInt32]: UInt16 read SklGetSkillMax write SklSetSkillMax;   /// Accesses Skill's Maximum Value (R/W)
      property SklKnownSkills: UInt32 read SklGetSkillCount;                                   /// This property returns the number of learned skills

      { Trade }

      procedure TrdReset;
      procedure TrdSetItem(const iTradeSlot, iBag, iSlot, iEntry, iStackCount: UInt32);
      property TrdTrader: YGaPlayer read FTrdTrader write FTrdTrader;                           /// Accesses trader (R/W)
      property TrdCopper: UInt32 read FTrdCopper write FTrdCopper;                              /// Accesses copper value to be traded (R/W)
      property TrdAccept: Boolean read FTrdAccept write FTrdAccept;                             /// Accesses TradeAccepted boolean value (R/W)
      property TrdItems: YTradeItemArray read FTrdItems write FTrdItems;                        /// Accesses trade items array (R/W)

      { Tutorials }

      property Tutorials[iIndex: UInt32]: Boolean read TutGetTutFlag write TutSetTutFlag;       /// Property that reads/sets a tutorial's flag (R/W)
      procedure TutMarkReadAllTutorials;                                                        /// Marks all tutorials as Read 
      procedure TutMarkUnreadAllTutorials;                                                      /// Marks all tutorials as Unread
      procedure TutSendTutorialsStatus;                                                         /// Send the tuttorials status

      { Equip }

      procedure EqpAddToWorld;
      procedure EqpPrepareUpdatesForTheItemOnSlot(iSlot: UInt32; bForceAlteringStats : Boolean = false); /// Transfer changed item's properites to player's fields (visible)
      function EqpFindFreeBackpackSlot: UInt8;                                                  /// Finds a free slot in the main backpack
      function EqpFindFreeBag: UInt8;                                                           /// Finds a bag that has a free slot
      function EqpAddItem(iItem, iAmount: UInt32; bNormal: Boolean): UInt8;                     /// Adds an item into a free equipment slot
      function EqpAssignItem(cItem: YGaItem): UInt32;                                           /// Assigns an item into a free equipment slot and returns the replaced one}
      function EqpAddItemToBag(iBag: UInt8; iItem, iAmount: UInt32; bNormal: Boolean): UInt8;   /// Adds an item into a specific bag
      procedure EqpAutoStoreItem(iBagSrc, iSlotSrc: UInt8; iBagDest: UInt8);                    /// Moves an item from a specific slot in one bag into a random slot in another
      function EqpDeleteItem(iBag, iSlot: UInt8; bDestroy: Boolean): YGaItem;                   /// Deletes an item from the player and optionally also from the database
      function EqpInventoryTypeToSlot(iInventoryType: YItemInventoryType): UInt8;
      function EqpInventoryTypeToPossibleSlots(iInventoryType: YItemInventoryType): YEquipmentSlots;

      procedure EqpSplitItems(iBagSrc, iSlotSrc: UInt8; iBagDest, iSlotDest: UInt8; iCount: UInt32);  /// Tries to split an item into 2 seperate stacks
      function EqpMergeStacks(iSrc, iDest: UInt8): Int32;                                       /// Tries to merge stacks of items
      procedure EqpTryEquipItem(iSlot : UInt8; iBag: UInt8);                                    /// Tries to equip an item
      function EqpInventoryChange(iSlot1, iSlot2: UInt8): Boolean; overload;                    /// Swaps 2 items in the equipment, excluding bags
      function EqpInventoryChange(iSlotSrc, iSlotDest : UInt8; iBagSrc, iBagDest: UInt8): Boolean; overload; /// Swaps 2 items
      function EqpThisItemCount(iItem: UInt32): Int32;                                          /// Says how many times you have an item (for quest)
      function EqpHasEnoughFreeSlots(iCount: Int32): Boolean;                                   /// Says if you have enough free slots (for quest for)
      procedure EqpGenerateInventoryChangeError(cSrc, cDest: YGaItem; iError: UInt8);           /// Send an error message to the client
      procedure EqpInsertItem(iSlot: UInt32; iId: UInt32; iAmount: UInt32 = 1; bOverrideChecks: Boolean = False); /// Overwrites an item at the specified slot 
      procedure EqpSendInventoryError(iError: UInt8);
      property EqpEquippedItems[iSlot: UInt32]: YGaItem read EqpGetEquipedItem;
      property Bags[iSlot: UInt32]: YGaContainer read EqpGetBag;
      property EqpBackpackItems[iSlot: UInt32]: YGaItem read EqpGetBackpackItem;
      property EqpBankItems[iSlot: UInt32]: YGaItem read EqpGetBankItem;
      property EqpBankBags[iSlot: UInt32]: YGaContainer read EqpGetBankBag;
      property EqpBuybackItems[iSlot: UInt32]: YGaItem read EqpGetBuybackItem;
      property EqpKeyring[iSlot: UInt32]: YGaItem read EqpGetKeyringItem;
      property Money: UInt32 read EqpGetMoney write EqpSetMoney;
      function EqpConvertAbsoluteSlotToRelative(iAbsSlot: UInt8; iConvType: YSlotConversionType): UInt8;
      function EqpConvertRelativeSlotToAbsolute(iRelSlot: UInt8; iConvType: YSlotConversionType): UInt8;
      {$ENDREGION}
    end;

implementation

{$REGION 'Uses Clause'}
uses
  MMSystem,
  Framework,
  Cores,
  Components.GameCore,
  Components.GameCore.Nodes,
  Components.GameCore.CommandHandler,
  Components.GameCore.Channel;
{$ENDREGION}

{*------------------------------------------------------------------------------
  Freeing resources. First cleaning up all YGaPlayer members.
-------------------------------------------------------------------------------}
procedure YGaPlayer.CleanupObjectData;
begin
end;

{*------------------------------------------------------------------------------
  Creating a character using a template
  Based on given Race, Class and gender, a character is created and it will be
    assigned with proper stats, equipment, spells, skills, etc.
  ==============================================================================

  @param TpStore The character templates store which holds
           informations about all possible combinations of characters
  @param GameClass Character's Class (druid or hunter, etc)
  @param GameRace Character's Race (such as Human or Undead, etc)
  @param Gender Character's gender (Male or Female)
  @see YDbCharTemplateStore
  @see YGameClass
  @see YGameRace
  @see YGameGender
-------------------------------------------------------------------------------}
procedure YGaPlayer.CreateFromTemplate(TpStore: YDbCharTemplateStore; GameClass: YGameClass;
  GameRace: YGameRace; Gender: YGameGender);
var
  I: Integer;
  PlayerTempDbEntry: IPlayerTemplateEntry;
begin
  /// Combining date form multiple templates accordingly to given GameClass
  ///   and GameRace using a temporary variable
  PlayerTempDbEntry := TpStore.CombineTemplate(GameRace, GameClass);
  try
    /// Assigning character's Race, Class and Gender
    Stats.Race := GameRace;
    Stats.&Class := GameClass;
    Stats.Gender := Gender;
  
    /// Deppending on given Gender, we'll assing a MaleBody or FemaleBody Texture ID
    case Gender of
      ggMale: Stats.Model := PlayerTempDbEntry.MaleBodyModel;
      ggFemale: Stats.Model := PlayerTempDbEntry.FemaleBodyModel;
    else
      Stats.Model := 0;
    end;
  
    /// Assigning Body Size
    Size := PlayerTempDbEntry.BodySize;
  
    /// Assigning Stats (Health, Powers, Rezistances, etc)
    Stats.MaxHealth := PlayerTempDbEntry.BaseHealth;
    Stats.Health := PlayerTempDbEntry.BaseHealth;
    Stats.PowerType := YGamePowerType(PlayerTempDbEntry.PowerType);
    Stats.MaxPower := PlayerTempDbEntry.BasePower;
    if Stats.PowerType <> gptRage then
    begin
      Stats.Power := PlayerTempDbEntry.BasePower;
    end else Stats.Power := 0;
  
    Stats.Strength := PlayerTempDbEntry.InitialStrength div 1000;
    Stats.Agility := PlayerTempDbEntry.InitialAgility div 1000;
    Stats.Stamina := PlayerTempDbEntry.InitialStamina div 1000;
    Stats.Intellect := PlayerTempDbEntry.InitialIntellect div 1000;
    Stats.Spirit := PlayerTempDbEntry.InitialSpirit div 1000;
  
    /// Assigning Attack times
    Stats.BaseAttackTimeHi := PlayerTempDbEntry.AttackTimeHi;
    Stats.BaseAttackTimeLo := PlayerTempDbEntry.AttackTimeLo;
  
    /// Assigning character's faction depending on GameRace
    Stats.Faction := FactionTemplateByRace(GameRace);
  
    /// Assigning vector positions (Map, ZOne, X, Y, Z and Angle orientation)
    MapId := PlayerTempDbEntry.Map;
    ZoneId := PlayerTempDbEntry.Zone;
    X := PlayerTempDbEntry.StartingX;
    Y := PlayerTempDbEntry.StartingY;
    Z := PlayerTempDbEntry.StartingZ;
    Angle := PlayerTempDbEntry.StartingAngle;
  
    /// Preparing character's updatefields
    SetUInt32(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_PLAYER_CONTROLLED);
  
    SetUInt8(PLAYER_BYTES_3, 0, UInt8(Gender));
    SetUInt32(PLAYER_BYTES_2, GetUInt32(PLAYER_BYTES_2) or ($EE shl 8) or (1 shl 16) or (1 shl 24));
  
    /// Setting experience and maximum experience for level 1
    SetUInt32(PLAYER_XP, 0);
    SetUInt32(PLAYER_NEXT_LEVEL_XP, 400);
    SetUInt32(PLAYER_FIELD_WATCHED_FACTION_INDEX, $FFFFFFFF);
  
    /// Setting other update fields
    SetFloat(PLAYER_FIELD_MOD_DAMAGE_DONE_PCT, 1);
    SetFloat(PLAYER_BLOCK_PERCENTAGE, PLAYER_BLOCK);
    SetFloat(PLAYER_DODGE_PERCENTAGE, PLAYER_DODGE);
    SetFloat(PLAYER_PARRY_PERCENTAGE, PLAYER_PARRY);
  
    SetUInt32(PLAYER_FIELD_BYTES, $EEEE0000);
  
    /// Setting Attack fields
    Stats.BoundingRadius := PLAYER_DEFAULT_BOUNDING_RADIUS;
    Stats.CombatReach := PLAYER_DEFAULT_COMBAT_REACH;
    Stats.MeleeAttackDamageHi := PlayerTempDbEntry.AttackDamageHi;
    Stats.MeleeAttackDamageLo := PlayerTempDbEntry.AttackDamageLo;
    Stats.MeleeAttackPower := PlayerTempDbEntry.AttackPower;
  
    /// Assigning Speeds (walk, run, swim, backwalk, backswim, etc)
    WalkSpeed := SPEED_WALK;
    RunSpeed := SPEED_RUN;
    BackSwimSpeed := SPEED_BACKSWIM;
    SwimSpeed := SPEED_SWIM;
    BackWalkSpeed := SPEED_BACKWALK;
    FlySpeed := SPEED_FLY;
    BackFlySpeed := SPEED_BACKFLY;
    TurnRate := SPEED_TURNRATE;
  
    /// Marking all tutorials as unread
    //Tutorials.TM_MarkUnreadAllTutorials;

    (*
    /// Preparing action buttons
    for I := 0 to 120 do
    begin
      ActionBtns.ActionButton[I] := PlayerTempDbEntry.ActionButtons[I];
    end;
  
    /// Preparing skills
    for I := 0 to Length(PlayerTempDbEntry.SkillData) -1 do
    begin
      Skills.AddNewSkill(PlayerTempDbEntry.SkillData[I].Id, PlayerTempDbEntry.SkillData[I].Initial,
        PlayerTempDbEntry.SkillData[I].Max);
    end;
  
    /// Preparing equipment
    for I := 0 to Length(PlayerTempDbEntry.ItemData) -1 do
    begin
      with PlayerTempDbEntry.ItemData[I] do
      begin
        Equip.InsertItem(Slot, Id, Count);
      end;
    end;
    *)
  finally
    TpStore.Medium.ReleaseEntry(PlayerTempDbEntry);
  end;
end;

{*------------------------------------------------------------------------------
  Loads data for a given entry

  @param cEntry Database Serializable component
  @see YDbSerializable
-------------------------------------------------------------------------------}
procedure YGaPlayer.ExtractObjectData(const Entry: ISerializable);
begin
  inherited ExtractObjectData(Entry);
  //fCharacterName := YDbPlayerEntry(cEntry).CharName;
end;

{*------------------------------------------------------------------------------
  Saves data for given entry

  @param cEntry Database Serializable component
  @see YDbSerializable
-------------------------------------------------------------------------------}
procedure YGaPlayer.InjectObjectData(const Entry: ISerializable);
begin
  inherited InjectObjectData(Entry);
  IPlayerEntry(Entry).AccountName := FAccount;
  IPlayerEntry(Entry).Name := FCharacterName;
  //YDbPlayerEntry(cEntry).AccountName := Account;
  //YDbPlayerEntry(cEntry).CharName := fCharacterName;
end;

{*------------------------------------------------------------------------------
  Player Updates Fields are updates!
  This method gets executed when there are updates that need to be constructed
    for a Player.

  Note: Do not modify this but only if you really know what you're doing :)
  ==============================================================================  

  @see YNwServerPacket
  @see FillObjectUpdatePacket
  @see AddUpdateBlock
-------------------------------------------------------------------------------}
procedure YGaPlayer.OnValuesUpdate;
var
  I: Int32;
  UpdPacket: YNwServerPacket;
begin
  /// creates a Server Packet
  UpdPacket := YNwServerPacket.Create;

  /// trying to fill this server packet with updates data
  try
    FillObjectUpdatePacket(UpdPacket);
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
    UpdPacket.Clear;
    FillObjectUpdatePacket(UpdPacket, True);
    /// Adding this update block
    AddUpdateBlock(UpdPacket);
  finally
    /// finally freeing resources used
    UpdPacket.Free;
  end;
end;

{*------------------------------------------------------------------------------
  Method that is asking for object's type

  @return This returns obviously that we're dealing with a player (UPDATEFLAG_PLAYER)
  @see UPDATEFLAG_PLAYER
-------------------------------------------------------------------------------}
class function YGaPlayer.GetObjectType;
begin
  Result := UPDATEFLAG_PLAYER;
end;

{*------------------------------------------------------------------------------
  Method that is asking for object's type as an open object

  @return This returns obviously that we're dealing with a player (otPlayer)
  @see otPlayer
-------------------------------------------------------------------------------}
class function YGaPlayer.GetOpenObjectType: YWowObjectType;
begin
  Result := otPlayer;
end;

{*------------------------------------------------------------------------------
  Destructor for YGaPlayer class
  Frees all used resources, first of all of course it is asking for all
    submembers to free their resources.
-------------------------------------------------------------------------------}
destructor YGaPlayer.Destroy;
begin
  fMyUpdates.Free;
  fMemberInChannels.Free;

  fLock.Delete;
  inherited Destroy;
end;

{*------------------------------------------------------------------------------
  Constructor for YGaPlayer class
  Creates every submember, preparing updates and adds this player to channels.
-------------------------------------------------------------------------------}
constructor YGaPlayer.Create;
begin
  inherited Create;

  fLock.Init;

  fMyUpdates := YNwPacket.Create;
  fMyUpdates.Jump(5); /// Reserve first 5 bytes in an updates creation packet
  fMyUpdateCount := 0; /// Initially setting updates count to 0

  fMemberInChannels := TStrArrayList.Create(16);
end;

{*------------------------------------------------------------------------------
  Adds a player to game world
  Basically it prepares updates for a player in order for this to enter the
    world. So creation packet is preapared and sent to all nearby players,
    eventually guild will be notified, etc.
-------------------------------------------------------------------------------}
procedure YGaPlayer.EnterWorld;
var
  cPkt: YNwServerPacket;
begin
  inherited EnterWorld;
  EqpAddToWorld;
  cPkt := YNwServerPacket.Create;
  try
    FillObjectCreationPacket(cPkt, True);
    AddUpdateBlock(cPkt);
  finally
    cPkt.Free;
  end;
end;

{*------------------------------------------------------------------------------
  Removes a player from game world
  Prepares updates for a player in order for this to leave safelly the
    world. So destruction packet is preapared and sent to all nearby players,
    eventually guild will be notified, it will leave the party if it had one, etc.
-------------------------------------------------------------------------------}
procedure YGaPlayer.LeaveWorld;
var
  I: Int32;
begin
  for I := 0 to fMemberInChannels.Size -1 do
  begin
    /// Leaving chat channels
    GameCore.LeaveChannel(Self, fMemberInChannels[I], True);
  end;
  inherited LeaveWorld;
end;

{*------------------------------------------------------------------------------
  Adds an Update Block (packet with updates data) to a bigger one

  @param Block A ByteBuffer which contains all updates that are going to be added
  @see YNwPacket
  @see fMyUpdates
-------------------------------------------------------------------------------}
procedure YGaPlayer.AddUpdateBlock(Block: YNwPacket);
begin
  fLock.Enter;
  try
    /// adds block buffer to fMyUpdates packet
    fMyUpdates.AddBuffer(Block);
    /// increases the number of updates
    Inc(fMyUpdateCount);
  finally
    fLock.Leave;
  end;
end;

{*------------------------------------------------------------------------------
  Uses current session to send a packet

  @param Pkt Server Packet that will be sent
  @see Session
-------------------------------------------------------------------------------}
procedure YGaPlayer.SendPacket(Pkt: YNwServerPacket);
begin
  Session.SendPacket(Pkt);
end;

{*------------------------------------------------------------------------------
  Provides correct updatetype creation parameter
  If it's going to update only itself, then it'll use UPDATETYPE_CREATE_OBJECT_ME
    as creation parameter, else it'll use UPDATETYPE_CREATE_OBJECT.

  @param UpdateType Returns the update type (for self or for others)
  @param UpdatingSelf Am I updating myself?
  @see (used for a "For additional informations see XXXXX" approach) [optional]
-------------------------------------------------------------------------------}
procedure YGaPlayer.SetCreationParams(out UpdateType: UInt8; UpdatingSelf: Boolean);
begin
  if UpdatingSelf then
  begin
    UpdateType := UPDATETYPE_CREATE_OBJECT_ME;
  end else
  begin
    UpdateType := UPDATETYPE_CREATE_OBJECT;
  end;
end;

{*------------------------------------------------------------------------------
  Adds movement data to that update packet

  @param cPkt The Server Packet
  @param bSelf Updating self?
  @see YNwServerPacket
  @see SetCreationParams
-------------------------------------------------------------------------------}
procedure YGaPlayer.AddMovementData(Pkt: YNwServerPacket; UpdatingSelf: Boolean);
var
  ExtraFlags: UInt32;
  Flags: UInt8;
begin
  /// Assigning correct flags and extra flags depending on update type.
  if UpdatingSelf then
  begin
    Flags := $71;
    ExtraFlags := $2000;
  end else
  begin
    Flags := $70;
    ExtraFlags := 0;
  end;

  /// Adding flags, extraflags, current time
  Pkt.AddUInt8(Flags);
  Pkt.AddUInt32(ExtraFlags);
  Pkt.AddUInt32(TimeGetTime);

  /// Adding Position vector (X, Y, Z, Orientation)
  Pkt.AddFloat(X);
  Pkt.AddFloat(Y);
  Pkt.AddFloat(Z);
  Pkt.AddFloat(Angle);
  /// Adds an empty uint32 value (unknown usage ATM)
  Pkt.JumpUInt32;

  /// If updating self, adding some constant data (float)
  if UpdatingSelf then
  begin
    Pkt.AddFloat(0);
    Pkt.AddFloat(1);
    Pkt.AddFloat(0);
    Pkt.AddFloat(0);
  end;

  /// Adding Speed data (walk, run, backwalk, backswim, swim, etc)
  Pkt.AddFloat(WalkSpeed);
  Pkt.AddFloat(RunSpeed);
  Pkt.AddFloat(BackSwimSpeed);
  Pkt.AddFloat(SwimSpeed);
  Pkt.AddFloat(BackWalkSpeed);
  Pkt.AddFloat(FlySpeed);
  Pkt.AddFloat(BackFlySpeed);
  Pkt.AddFloat(TurnRate);
  /// Adds an empty uint32 value (unknown usage ATM)
  Pkt.JumpUInt32;
end;

{*------------------------------------------------------------------------------
  Sets character's face byte (for design)

  @param Value The value that is used
-------------------------------------------------------------------------------}
procedure YGaPlayer.SetFace(const Value: UInt8);
begin
  SetUInt8(PLAYER_BYTES, BYTE_FACE, Value);
end;

{*------------------------------------------------------------------------------
  Sets character's facial hair byte

  @param Value The value that is used
-------------------------------------------------------------------------------}
procedure YGaPlayer.SetFacialHair(const Value: UInt8);
begin
  SetUInt8(PLAYER_BYTES_2, BYTE_FHAIR, Value);
end;

{*------------------------------------------------------------------------------
  Sets character's hair color byte

  @param Value The value that is used
-------------------------------------------------------------------------------}
procedure YGaPlayer.SetHairColor(const Value: UInt8);
begin
  SetUInt8(PLAYER_BYTES, BYTE_HCOLOR, Value);
end;

{*------------------------------------------------------------------------------
  Sets character's hair style byte

  @param Value The value that is used
-------------------------------------------------------------------------------}
procedure YGaPlayer.SetHairStyle(const Value: UInt8);
begin
  SetUInt8(PLAYER_BYTES, BYTE_HSTYLE, Value);
end;

{*------------------------------------------------------------------------------
  Sets character's skin color byte

  @param Value The value that is used
-------------------------------------------------------------------------------}
procedure YGaPlayer.SetSkin(const Value: UInt8);
begin
  SetUInt8(PLAYER_BYTES, BYTE_SKIN, Value);
end;

{*------------------------------------------------------------------------------
  Retreives account's name

  @return A string with account's name
-------------------------------------------------------------------------------}
function YGaPlayer.GetAccountName: string;
begin
  Result := fSessionLink.GetAccount;
end;

{*------------------------------------------------------------------------------
  Retreives character's face byte

  @return byte data
-------------------------------------------------------------------------------}
function YGaPlayer.GetFace: UInt8;
begin
  Result := GetUInt8(PLAYER_BYTES, BYTE_FACE);
end;

{*------------------------------------------------------------------------------
  Retreives character's facial hair byte

  @return byte data
-------------------------------------------------------------------------------}
function YGaPlayer.GetFacialHair: UInt8;
begin
  Result := GetUInt8(PLAYER_BYTES_2, BYTE_FHAIR);
end;

{*------------------------------------------------------------------------------
  Retreives character's hair color

  @return byte data
-------------------------------------------------------------------------------}
function YGaPlayer.GetHairColor: UInt8;
begin
  Result := GetUInt8(PLAYER_BYTES, BYTE_HCOLOR);
end;

{*------------------------------------------------------------------------------
  Retreives character's hair style

  @return byte data
-------------------------------------------------------------------------------}
function YGaPlayer.GetHairStyle: UInt8;
begin
  Result := GetUInt8(PLAYER_BYTES, BYTE_HSTYLE);
end;

{*------------------------------------------------------------------------------
  Retreives character's skin color

  @return byte data
-------------------------------------------------------------------------------}
function YGaPlayer.GetSkin: UInt8;
begin
  Result := GetUInt8(PLAYER_BYTES, BYTE_SKIN);
end;

{*------------------------------------------------------------------------------
  Timer that gets executed every TimeDelta miliseconds
  This timer chacks periodically for available updates needed to be sent.

  @param Event Event handler
  @param TimeDelta Timer execution time
  @see fMyUpdateCount
  @see fMyUpdates
  @see fLock
-------------------------------------------------------------------------------}
procedure YGaPlayer.PlayerLifeTimer(Event: TEventHandle; TimeDelta: UInt32);
var
  cPkt: YNwServerPacket;
  iSz: Int32;
begin
  /// Check for available cached updates
  fLock.Enter;
  try
    if fMyUpdateCount > 0 then
    begin
      /// Set number of records in the updates 
      fMyUpdates.AddUInt32(fMyUpdateCount, 0);
      cPkt := YNwServerPacket.Create;
      try
        Components.GameCore.PacketBuilders.FillUpdatePacket(fMyUpdates, cPkt);
        fSessionLink.SendPacket(cPkt);
      finally
        cPkt.Free;
      end;
      iSz := fMyUpdates.Size;
      fMyUpdates.WritePos := 5;
      /// Clear all but the first 5 bytes
      fMyUpdates.Size := 5;
      fMyUpdates.Size := iSz;
      fMyUpdateCount := 0;
    end;
  finally
    fLock.Leave;
  end;
end;

{*------------------------------------------------------------------------------
  Method to request updates from an Object (creature, GO, player, etc)

  @param Obj The object from which you request it's updates
  @param Request Updates request (creation, destruction, or only updates)
  @see YGaMobile
  @see YUpdateRequest
  @see YNwServerPacket
-------------------------------------------------------------------------------}
procedure YGaPlayer.RequestUpdatesFromObject(Obj: YGaMobile; Request: YUpdateRequest);
var
  cPkt: YNwServerPacket;
begin
  if Request = urStateUpdate then Exit;
  cPkt := YNwServerPacket.Create;
  try
    case Request of
      urAdd:
      begin
        Obj.FillObjectCreationPacket(cPkt, False);
        AddUpdateBlock(cPkt);
      end;
      urRemove:
      begin
        Obj.FillObjectDestructionPacket(cPkt, False);
        Session.SendPacket(cPkt);
      end;
      urValueUpdate:
      begin
        Obj.FillObjectUpdatePacket(cPkt, False);
        AddUpdateBlock(cPkt);
      end;
    end;
  finally
    cPkt.Free;
  end;
end;

{ Guild Component }

{*------------------------------------------------------------------------------
  sets player`s guild id

  @param UInt32 data
-------------------------------------------------------------------------------}
procedure YGaPlayer.GldSetId(const Value: UInt32);
begin
  SetUInt32(PLAYER_GUILDID, Value);
end;


{*------------------------------------------------------------------------------
  sets player`s guild rank

  @param UInt32 data
-------------------------------------------------------------------------------}
procedure YGaPlayer.GldSetRank(const Value: UInt32);
begin
  SetUInt32(PLAYER_GUILDRANK, Value);
end;


{*------------------------------------------------------------------------------
  Retreives player`s guild id

  @return UInt32 data
-------------------------------------------------------------------------------}
function YGaPlayer.GldGetId: UInt32;
begin
  Result := GetUInt32(PLAYER_GUILDID);
end;

{*------------------------------------------------------------------------------
  Retreives player`s guild rank

  @return UInt32 data
-------------------------------------------------------------------------------}
function YGaPlayer.GldGetRank: UInt32;
begin
  Result := GetUInt32(PLAYER_GUILDRANK);
end;


{ Experience Component }

{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
function YGaPlayer.ExpGetRestState: Boolean;
begin
  Result := FExpRestedState > 30;
end;


{ PvP Component }

{*------------------------------------------------------------------------------
  Retreives player`s pvp rank

  @return UInt8 data
-------------------------------------------------------------------------------}
function YGaPlayer.PvPMgrGetRank: UInt8;
begin
  Result := UInt8(GetUInt32(PLAYER_BYTES_3) shr 24);
end;


{*------------------------------------------------------------------------------
  sets player`s PvP rank

  @param UInt8;
-------------------------------------------------------------------------------}
procedure YGaPlayer.PvPMgrSetRank(const Value: UInt8);
begin

end;


{ Action Buttons Component }

{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
procedure YGaPlayer.BtnAddButton(iButtonIdx: UInt8; iValue: UInt32);
begin
  FBtnActionButtons[iButtonIdx] := iValue;
end;


{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
function YGaPlayer.BtnReadButton(iButtonIdx: UInt8): UInt32;
begin
  Result := FBtnActionButtons[iButtonIdx];
end;


{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
procedure YGaPlayer.BtnSendActionButtons;
var
  iX: UInt32;
  cPkt: YNwServerPacket;
begin
  cPkt := YNwServerPacket.Initialize(SMSG_ACTION_BUTTONS);
  try
    for iX := 0 to 120 do
    begin
      { Sending the button. }
      { The check for it as a spell or an item is not done here}
      cPkt.AddUInt32(FBtnActionButtons[iX]);
    end;
    SendPacket(cPkt);
  finally
    cPkt.Free;
  end;
end;


{ Skills Component }

{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
function YGaPlayer.SklRetreiveSkillData(iSkillLine, iPiece: UInt32): UInt32;
begin
  Result := 0;
end;


{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
procedure YGaPlayer.SklSaveSkillData(iSkillLine, iInt, iPiece: UInt32);
begin
end;


{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
function YGaPlayer.SklGetSkillCount: UInt32;
var
  iX: Int32;
begin
  Result := 0;
  for iX := 0 to (__PLAYER_SKILL_INFO_1_1 div 3)  - 2 do
  begin
    if SklSkillId[iX] <> 0 then Inc(Result);
  end;
end;


{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
function YGaPlayer.SklGetSkillCrr(iIndex: UInt32): UInt16;
begin
  Result := LongRec(SklRetreiveSkillData(iIndex, UPDATE_SKILL_DATA)).Words[WORD_SKILL_CURR];
end;


{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
function YGaPlayer.SklGetSkillId(iIndex: UInt32): UInt32;
begin
  Result := SklRetreiveSkillData(iIndex, UPDATE_SKILL_ID);
end;


{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
function YGaPlayer.SklGetSkillMax(iIndex: UInt32): UInt16;
begin
  Result := LongRec(SklRetreiveSkillData(iIndex, UPDATE_SKILL_DATA)).Words[WORD_SKILL_MAX];
end;


{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
procedure YGaPlayer.SklSetSkillCrr(iIndex: UInt32; const Value: UInt16);
var
  lwTemp: Longword;
begin
  lwTemp := SklRetreiveSkillData(iIndex, UPDATE_SKILL_DATA);
  LongRec(lwTemp).Words[WORD_SKILL_CURR] := Value;
  SklSaveSkillData(iIndex, lwTemp, UPDATE_SKILL_DATA);
end;


{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
procedure YGaPlayer.SklSetSkillId(iIndex: UInt32; const Value: UInt32);
begin
  SklSaveSkillData(iIndex, Value, UPDATE_SKILL_ID);
end;

{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
procedure YGaPlayer.SklSetSkillMax(iIndex: UInt32; const Value: UInt16);
var
  lwTemp: Longword;
begin
  lwTemp := SklRetreiveSkillData(iIndex, UPDATE_SKILL_DATA);
  LongRec(lwTemp).Words[WORD_SKILL_MAX] := Value;
  SklSaveSkillData(iIndex, lwTemp, UPDATE_SKILL_DATA);
end;


{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
function YGaPlayer.SklAddNewSkill(iSkillId, iSkillKnown, iSkillMax: UInt32): Int32;
var
  iX: Int32;
begin
  for iX := 0 to (__PLAYER_SKILL_INFO_1_1 div 3)  - 2 do
  begin
    if SklSkillId[iX] = 0 then
    begin
      Result := iX;
      SklSkillId[iX] := iSkillId;
      SklSkillCurrent[iX] := iSkillKnown;
      SklSkillMax[iX] := iSkillMax;
      Exit;
    end;
  end;
  Result := -1;
end;


{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
function YGaPlayer.SklHasSkill(iSkillId: UInt32): Boolean;
var
  iX: Int32;
begin
  Result := False;
  for iX := 0 to (__PLAYER_SKILL_INFO_1_1 div 3)  - 2 do
  begin
    if SklSkillId[iX] = iSkillId then
    begin
      Result := True;
      Exit;
    end;
  end;
end;


{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
{ Tutorials Component }

function YGaPlayer.TutGetTutFlag(iIndex: UInt32): Boolean;
var
  iDex: UInt32;
begin
  iDex := DivModPowerOf2(iIndex, 5, Integer(iIndex));
  Result := GetBit32(FTutTutorials[iDex], iIndex);
end;


{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
procedure YGaPlayer.TutSetTutFlag(iIndex: UInt32; const bValue: Boolean);
var
  iDex: UInt32;
begin
  iDex := DivModPowerOf2(iIndex, 5, Integer(iIndex));
  if bValue then
  begin
    FTutTutorials[iDex] := SetBit32(FTutTutorials[iDex], iIndex);
  end else
  begin
    FTutTutorials[iDex] := ResetBit32(FTutTutorials[iDex], iIndex);
  end;
end;


{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
procedure YGaPlayer.TutMarkReadAllTutorials;
var
  iIndex: UInt32;
begin
  for iIndex := 0 to Length(FTutTutorials) - 1 do
  begin
    FTutTutorials[iIndex] := $FFFFFFFF;
  end;
end;


{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
procedure YGaPlayer.TutMarkUnreadAllTutorials;
var
  iIndex: UInt32;
begin
  for iIndex := 0 to Length(FTutTutorials) - 1 do
  begin
    FTutTutorials[iIndex] := $00000000;
  end;
end;


{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
procedure YGaPlayer.TutSendTutorialsStatus;
var
  cPkt: YNwServerPacket;
begin
  cPkt := YNwServerPacket.Initialize(SMSG_TUTORIAL_FLAGS);
  try
    cPkt.AddStruct(FTutTutorials[0], (Length(FTutTutorials) -1) shl 2);
    SendPacket(cPkt);
  finally
    cPkt.Free;
  end;
end;


{*------------------------------------------------------------------------------
  Checks if the player is able to wear the given item.
  This method will check for player's stats, skills, spells, etc as they all have
    to fit item's requirements.

  @param iSlot The slot where the player wants to wear that item
  @param iEntry
  @return An error, depending on the checks. If successfull, INV_ERR_OK is returned
  @todo More checks for: reputation, spell and some other checks that I missed
  @see YDbItemTemplate
  @see YGaPlayer
  @see Components.GameCore.Constants
-------------------------------------------------------------------------------}
function YGaPlayer.EqpCanPlayerWearItem(iSlot: UInt8; iEntry: UInt32): UInt8;
var
  cTemp: YDbItemTemplate;
label
  __Exit;
begin

  //DataCore.ItemTemplates.LoadEntry(iEntry, cTemp);

  /// checking if the item was found in database
  if cTemp = nil then
  begin
    Result := INV_ERR_ITEM_NOT_FOUND;
    goto __Exit;
  end;

  /// checking if the items can be swapped
  if not (YEquipmentSlot(iSlot) in EqpInventoryTypeToPossibleSlots(cTemp.InventoryType)) then
  begin
    Result := INV_ERR_ITEMS_CANT_BE_SWAPPED;
    goto __Exit;
  end;

  /// RACE CHECKS
  if (cTemp.AllowedRaces <> []) and not (Stats.Race in cTemp.AllowedRaces) then
  begin
    Result := INV_ERR_YOU_CAN_NEVER_USE_THAT_ITEM;
    goto __Exit;
  end;

  /// CLASS CHECKS
  if (cTemp.AllowedClasses <> []) and not (Stats.&Class in cTemp.AllowedClasses) then
  begin
    Result := INV_ERR_YOU_CAN_NEVER_USE_THAT_ITEM;
    goto __Exit;
  end;

  /// LEVEL CHECKS
  if (Stats.Level < cTemp.ReqLevel) and
     (Stats.Level <> 0) then
  begin
    Result := INV_ERR_YOU_MUST_REACH_LEVEL_N;
    goto __Exit;
  end;

  /// SKILL CHECKS
  if (not (SklGetSkillCount <> 0)) and not SklHasSkill(cTemp.ReqSkill) then
  begin
    Result := INV_ERR_NO_REQUIRED_PROFICIENCY;
    goto __Exit;
  end;

  /// SKILL RANK CHECKS
  if (not (SklGetSkillCount <> 0)) and SklHasSkill(cTemp.ReqSkill) and
     (SklSkillCurrent[cTemp.ReqSkill] < cTemp.ReqSkillRank) then
  begin
    Result := INV_ERR_SKILL_ISNT_HIGH_ENOUGH;
    goto __Exit;
  end;

  /// PVP RANK 1 CHECKS
  if Rank < cTemp.ReqPVPRank1 then
  begin
    Result := INV_ITEM_RANK_NOT_ENOUGH;
    goto __Exit;
  end;

  /// PVP RANK 2 CHECKS
  if Rank < cTemp.ReqPVPRank2 then
  begin
    Result := INV_ITEM_RANK_NOT_ENOUGH;
    goto __Exit;
  end;

  { TODO -oAll -cEquipManager : More checks for: reputation, spell and some other that i missed }
  Result := INV_ERR_OK;
  __Exit:
  /// freeing temporary used resources
  DataCore.ItemTemplates.ReleaseEntry(cTemp);
end;

{*------------------------------------------------------------------------------
  Finds a free slot in a backpack

  @return The ID of the free slot found or SLOT_NULL if no slots are available
-------------------------------------------------------------------------------}
function YGaPlayer.EqpFindFreeBackpackSlot: UInt8;
begin
  for Result := 0 to High(FEqpItems.Backpack) do
  begin
    if FEqpItems.Backpack[Result] = nil then Exit;
  end;
  
  Result := SLOT_NULL;
end;


{*------------------------------------------------------------------------------
  Finds a free bag

  @return The ID of the free bag found or BAG_NULL if no bags are available
-------------------------------------------------------------------------------}
function YGaPlayer.EqpFindFreeBag: UInt8;
var
  iX: UInt8;
begin
  for iX := 0 to High(FEqpItems.Bags) do
  begin
    if Assigned(FEqpItems.Bags[iX]) and (FEqpItems.Bags[iX].NumOfFreeSlots <> 0) then
    begin
      Result := iX;
      Exit;
    end;
  end;

  Result := BAG_NULL;
end;

{*------------------------------------------------------------------------------
  Provides the item that is supposed to be on a given Slot number

  @return The Item located on given Slot number.
-------------------------------------------------------------------------------}
function YGaPlayer.EqpGetBackpackItem(iSlot: UInt32): YGaItem;
begin
  Result := FEqpItems.Backpack[iSlot];
end;


{*------------------------------------------------------------------------------
  Provides the bag that is supposed to be on a given Slot number

  @return The Bag located on given Slot number.
  @see YGaContainer
-------------------------------------------------------------------------------}
function YGaPlayer.EqpGetBag(iSlot: UInt32): YGaContainer;
begin
  Result := FEqpItems.Bags[iSlot];
end;


{*------------------------------------------------------------------------------
  Provides the Bank Bag that is supposed to be on a given Slot number

  @return The Bank Bag located on given Slot number.
  @see YGaContainer
-------------------------------------------------------------------------------}
function YGaPlayer.EqpGetBankBag(iSlot: UInt32): YGaContainer;
begin
  Result := FEqpItems.BankBags[iSlot];
end;

{*------------------------------------------------------------------------------
  Provides the item that is supposed to be on a given Slot number in Bank

  @return The Item located on given Slot number in Bank.
-------------------------------------------------------------------------------}
function YGaPlayer.EqpGetBankItem(iSlot: UInt32): YGaItem;
begin
  Result := FEqpItems.Bank[iSlot];
end;


{*------------------------------------------------------------------------------
  Provides the item that is supposed to be on a given Slot number in BuyBack array

  @return The Item located on given Slot number in BuyBack array.
-------------------------------------------------------------------------------}
function YGaPlayer.EqpGetBuybackItem(iSlot: UInt32): YGaItem;
begin
  Result := FEqpItems.Buyback[iSlot];
end;

{*------------------------------------------------------------------------------
  Gets an Equiped Item for given slot ID

  @return The Item located on given Slot ID.
-------------------------------------------------------------------------------}
function YGaPlayer.EqpGetEquipedItem(iSlot: UInt32): YGaItem;
begin
  Result := FEqpItems.EquippedItems[iSlot];
end;


{*------------------------------------------------------------------------------
  Gets a Keyring Item for given slot ID

  @return The Item located on given Slot ID.
-------------------------------------------------------------------------------}
function YGaPlayer.EqpGetKeyringItem(iSlot: UInt32): YGaItem;
begin
  Result := FEqpItems.Keyring[iSlot];
end;


{*------------------------------------------------------------------------------
  Reads character's money

  @return Character's money
-------------------------------------------------------------------------------}
function YGaPlayer.EqpGetMoney: UInt32;
begin
  Result := GetUInt32(PLAYER_FIELD_COINAGE);
end;


{*------------------------------------------------------------------------------
  Finds out if the character has a given number of free slots

  @return True if it has enough free slots, false otherwise
-------------------------------------------------------------------------------}
function YGaPlayer.EqpHasEnoughFreeSlots(iCount: Int32): Boolean;
var
  iX: Int32;
begin
  Result := True;
  if iCount = 0 then
    Exit;
  for iX := 0 to High(FEqpItems.Backpack) do
  begin
    if FEqpItems.Backpack[iX] = nil then
    begin
      Dec(iCount);
      if iCount <= 0 then
        Exit;
    end;
  end;
  for iX := 0 to High(FEqpItems.Bags) do
  begin
    if Assigned(FEqpItems.Bags[iX]) then
    begin
      Dec(iCount, FEqpItems.Bags[iX].NumOfFreeSlots);
      if iCount <= 0 then
        Exit;
    end;
  end;
  Result := False;
end;


{*------------------------------------------------------------------------------
  Inserts an item (or multiple instances of that item) on a given slot

  @param iSlot The slot where the item will be inserted
  @param iId Item's Entry ID
  @param iAmount The amount of items to be inserted on that slot. Default 1.
  @param bOverrideChecks If true, function CanPlayerWearItem will not be executed
  @see CanPlayerWearItem
  @see YGaItem
  @see GenerateInventoryChangeError
-------------------------------------------------------------------------------}
procedure YGaPlayer.EqpInsertItem(iSlot: UInt32; iId: UInt32; iAmount: UInt32 = 1;
  bOverrideChecks: Boolean = False);
var
  cItem: YGaItem;
  iError: UInt8;
begin
  Assert(iSlot <= ITEMS_END, 'An invalid EQUIP slot "' + itoa(iSlot) + '" has been provided. Please contact developers about this bug.');

  /// Checking if the item can be weared by player
  if iSlot <= EQUIPMENT_SLOT_END then
  begin
    if not bOverrideChecks then iError := EqpCanPlayerWearItem(iSlot, iId) else iError := INV_ERR_OK;
  end else iError := INV_ERR_OK;


  /// If the item can be weared
  if iError = INV_ERR_OK then
  begin
    /// then if there are no items assigned on that slot
    if not Assigned(FEqpItems.Items[iSlot]) then
    begin
      /// then creating and assigning new one
      FEqpTempItem.iSlot := iSlot;
      FEqpTempItem.fItem := nil;
      //cItem := CreateNewItem(iId, fOwner, nil);
      cItem.StackCount := iAmount;
    end else
    begin
      /// otherwise just assing the new one
      FEqpTempItem.iSlot := iSlot;
      FEqpTempItem.fItem := FEqpItems.Items[iSlot];
      cItem := FEqpItems.Items[iSlot];
    end;
    FEqpItems.Items[iSlot] := cItem;

    /// if the player is not in world, we'll prepare the updates for that item
    if not InWorld then
      /// and we'll alter player's stats depending on the item's options
      EqpPrepareUpdatesForTheItemOnSlot(iSlot, True)
    else
      /// otherwise we'll just prepare updates for that item
      EqpPrepareUpdatesForTheItemOnSlot(iSlot);

    /// Setting item's world state to wscAdd (needs to be added to world)
    FEqpItems.Items[iSlot].ChangeWorldState(wscAdd);
  end else
  begin
    /// in the case that the item cannot be weared, we'll generate an Inventory
    /// Change Error, with the error returned by CanPlayerWearItem
    EqpGenerateInventoryChangeError(cItem, nil, iError);
  end;
end;


{*------------------------------------------------------------------------------
  Internal swapping of the items on 2 given slots

  @param iSlot1 First given slot
  @param iSlot2 Second given slot
  @see YGaItem
-------------------------------------------------------------------------------}
procedure YGaPlayer.EqpInternalSwap(iSlot1, iSlot2: UInt8);
var
  cTemp: YGaItem;
begin
  /// a temporary item receive's the item data from first slot
  cTemp := FEqpItems.Items[iSlot2];
  FEqpItems.Items[iSlot2] := FEqpItems.Items[iSlot1];
  FEqpItems.Items[iSlot1] := cTemp;

  /// First slot receives now the item from second slot
  {fTempItem.iSlot := iSlot1;
  fTempItem.fItem := FEqpItems.Items[iSlot2];  }
  /// >> preparing the updates for it
  EqpPrepareUpdatesForTheItemOnSlot(iSlot1);

  /// Second slot receives the temporary created item
  {fTempItem.iSlot := iSlot2;
  fTempItem.fItem := FEqpItems.Items[iSlot1]; }
  /// >> preparing the updates for it
  EqpPrepareUpdatesForTheItemOnSlot(iSlot2);
end;


{*------------------------------------------------------------------------------
  Internal swapping of the items on 2 given slots and 2 bags

  @param iSlot1 First given slot
  @param iSlot2 Second given slot
  @param iBag1 First given bag
  @param iBag2 Second given bag
  @see YGaItem
-------------------------------------------------------------------------------}
procedure YGaPlayer.EqpInternalSwap(iSlot1, iSlot2, iBag1, iBag2: UInt8);
const
  SWP_B2B = 0;
  SWP_B2I = 1;
  SWP_I2B = 2;
  SWP_I2I = 3;

  /// Swap decision table
  SwapTable: array[Boolean, Boolean] of Int32 = (
    (SWP_B2B, SWP_B2I),
    (SWP_I2B, SWP_I2I)
  );
var
  cTemp: YGaItem;
begin
  case SwapTable[iBag1 = BAG_NULL, iBag2 = BAG_NULL] of
    SWP_B2B:
    begin
      /// 1. Bag-to-Bag swap
      cTemp := FEqpItems.Containers[iBag2].Items[iSlot2];
      FEqpItems.Containers[iBag2].Items[iSlot2] := FEqpItems.Containers[iBag1].Items[iSlot1];
      FEqpItems.Containers[iBag1].Items[iSlot1] := cTemp;
    end;
    SWP_B2I:
    begin
      /// 2. Bag-to-Inventory swap
      cTemp := FEqpItems.Items[iSlot2];
      FEqpItems.Items[iSlot2] := FEqpItems.Containers[iBag1].Items[iSlot1];
      FEqpItems.Containers[iBag1].Items[iSlot1] := cTemp;
      //FEqpItems.Containers[iBag1].
      //PrepareUpdatesForTheItemOnSlot(iSlot1);
      EqpPrepareUpdatesForTheItemOnSlot(iSlot2);
    end;
    SWP_I2B:
    begin
      /// 3. Inventory-to-bag swap
      cTemp := FEqpItems.Containers[iBag2].Items[iSlot2];
      FEqpItems.Containers[iBag2].Items[iSlot2] := FEqpItems.Items[iSlot1];
      FEqpItems.Items[iSlot1] := cTemp;
      EqpPrepareUpdatesForTheItemOnSlot(iSlot1);
      //PrepareUpdatesForTheItemOnSlot(iSlot2);
    end;
    SWP_I2I:
    begin
      /// 4. Inventory-to-Inventory swap
      EqpInternalSwap(iSlot1, iSlot2);
    end;
  end;
end;


{*------------------------------------------------------------------------------
  Deletes and/or even destroys the item on a given slot/bag

  @param iBag Bag ID
  @param iSlot Slot ID
  @param bDestroy Destroy the item and delete it from database?
  @return The item data if it is not completelly deleted from database
-------------------------------------------------------------------------------}
function YGaPlayer.EqpDeleteItem(iBag, iSlot: UInt8; bDestroy: Boolean): YGaItem;
begin
  if iBag = BAG_NULL then
  begin
    /// if there is an item assigned to that given slot number
    if Assigned(FEqpItems.Items[iSlot]) then
    begin
      /// assigning fTempItem the slot and the item on that slot
      FEqpTempItem.iSlot := iSlot;
      FEqpTempItem.fItem := FEqpItems.Items[iSlot];

      /// if bDestroy
      if bDestroy then
      begin
        /// then we remove the item form world, delete it from database and
        /// also destroy it, adding as Result a NIL value
        FEqpItems.Items[iSlot].ChangeWorldState(wscRemove);
        FEqpItems.Items[iSlot].DeleteFromDataBase;
        FEqpItems.Items[iSlot].Destroy;
        Result := nil;
      end else
      begin
        /// otherwise we provide as result the item that was on that slot
        Result := FEqpItems.Items[iSlot];
      end;

      /// now assigning to that slot a NIL value (no item present there now)
      FEqpItems.Items[iSlot] := nil;
      /// and we prepare updates for that slot
      EqpPrepareUpdatesForTheItemOnSlot(iSlot);
    /// If there is no item assigned to that slot, we ad NIL as Result
    end else Result := nil;

  /// if iBag is not BAG_NULL, we'll call RemoveItem from Containers
  end else
  begin
    Result := FEqpItems.Containers[iBag].RemoveItem(iSlot, bDestroy);
  end;
end;


{*------------------------------------------------------------------------------
  This method prepares the updates for the item on given slot

  @param iSlot
  @param bForceAlteringStats
  @todo Add the rest of the update fields about enchantments and random properties
-------------------------------------------------------------------------------}
procedure YGaPlayer.EqpPrepareUpdatesForTheItemOnSlot(iSlot: UInt32;  bForceAlteringStats : Boolean);
const
  { Constants used for deleted item settings, 0 values }
  __ITEM_CREATOR  = 0;
  __ITEM_ENTRY_ID = 0;
  __ITEM_GUID     = 0;

var
  cTemp: YGaItem;
  iUpdateBase: UInt32;
begin
  Assert(iSlot <= ITEMS_END, 'An invalid EQUIP slot "' + itoa(iSlot) + '" has been provided. Please contact developers about this bug. [PrepareUpdatesForTheItemOnSlot]');

  /// preparing Updatebase for item
  iUpdateBase := iSlot * (PLAYER_VISIBLE_ITEM_1_PAD - PLAYER_VISIBLE_ITEM_1_CREATOR + 1);

  cTemp := FEqpItems.Items[iSlot];

  /// If there is an item on that slot, we'll add visibility for it!
  if cTemp <> nil then
  begin
    /// Adding Item's GUID in proper slot ID in update fields
    SetUInt64(PLAYER_FIELD_INV_SLOT_HEAD + iSlot * 2, cTemp.GUID^.Full);
    if (iSlot <= EQUIPMENT_SLOT_END) then
    begin
     /// If the player is in world (not in charlist) or we want to force
     ///  altering it's stats we'll call the method that handles stats changes
     if (InWorld) or (bForceAlteringStats) then
       begin
        // if (fTempItem.iSlot = iSlot) and (fTempItem.fItem <> nil) then
        //   Owner.Stats.AddItemStats(fTempItem.fItem, false) else
        // Owner.Stats.AddItemStats(FEqpItems.Items[iSlot]);
       end;

      /// Setting some more update fields for visibility! 
      SetUInt64(PLAYER_VISIBLE_ITEM_1_CREATOR + iUpdateBase, __ITEM_CREATOR);
      SetUInt32(PLAYER_VISIBLE_ITEM_1_0 + iUpdateBase, cTemp.Entry);


      {
      Owner.SetUInt32(PLAYER_VISIBLE_ITEM_ENCHANTMENT_0 + iUpdateBase, fItems[iSlot].Entry);
      Owner.SetUInt32(PLAYER_VISIBLE_ITEM_ENCHANTMENT_1 + iUpdateBase, fItems[iSlot].Entry);
      Owner.SetUInt32(PLAYER_VISIBLE_ITEM_ENCHANTMENT_2 + iUpdateBase, fItems[iSlot].Entry);
      Owner.SetUInt32(PLAYER_VISIBLE_ITEM_ENCHANTMENT_3 + iUpdateBase, fItems[iSlot].Entry);
      Owner.SetUInt32(PLAYER_VISIBLE_ITEM_ENCHANTMENT_4 + iUpdateBase, fItems[iSlot].Entry);
      Owner.SetUInt32(PLAYER_VISIBLE_ITEM_ENCHANTMENT_5 + iUpdateBase, fItems[iSlot].Entry);
      Owner.SetUInt32(PLAYER_VISIBLE_ITEM_ENCHANTMENT_6 + iUpdateBase, fItems[iSlot].Entry);
      Owner.SetUInt32(PLAYER_VISIBLE_ITEM_PROPERTIES + iUpdateBase, fItems[iSlot].Entry);      // Item Random properties
      }
    end;

  /// If there's no item on that slot (e.g it was previously deleted) we'll
  ///  empty the updafields reserved for that slot!
  end else
  begin
    SetUInt64(PLAYER_FIELD_INV_SLOT_HEAD + iSlot * 2, __ITEM_GUID);

    
    if iSlot <= EQUIPMENT_SLOT_END then
    begin
     /// If the player is in world (not in charlist) it's obvious that there was
     /// an item on this slot and that on deletion we have to renew player's stats
     /// as the item is deleted, and all stats that were altered by this item
     /// have to be reconfigured!
      if InWorld then
        begin
          //if (fTempItem.iSlot = iSlot) and (fTempItem.fItem <> nil) then
          //   fOwner.Stats.AddItemStats(fTempItem.fItem, false);
        end;

       /// removing visibility of the previously equiped item!
       SetUInt64(PLAYER_VISIBLE_ITEM_1_CREATOR + iUpdateBase, __ITEM_CREATOR);
       SetUInt32(PLAYER_VISIBLE_ITEM_1_0 + iUpdateBase, __ITEM_ENTRY_ID);
    end;
  end;
end;


{*------------------------------------------------------------------------------
  Adding an item (or an amount of items) to bag

  @param iBag The bag where we'll insert the item
  @param iItem Item's ID
  @param iAmount The amount of items to add
  @param bNormal If FALSE, there will be no text in chat announcing you what item you received
  @return Returns inserting error
  @see SendItemReceiveMessage
  @see FindFreeBackpackSlot
  @see PrepareUpdatesForTheItemOnSlot
  @see INV_ERR_INVENTORY_FULL
  @see INV_ERR_BAG_FULL
  @see INV_ERR_OK
-------------------------------------------------------------------------------}
function YGaPlayer.EqpAddItemToBag(iBag: UInt8; iItem, iAmount: UInt32; bNormal: Boolean): UInt8;
var
  cItem: YGaItem;
  cBag: YGaContainer;
  iSlot: UInt8;
begin
  /// If there's no specific bag given
  if iBag = BAG_NULL then
  begin
    /// then we'll search for a free one
    iSlot := EqpFindFreeBackpackSlot;
    /// If we found a free bagslot
    if iSlot <> SLOT_NULL then
    begin
      /// then we'll adjust data
      Inc(iSlot, INVENTORY_SLOT_ITEM_START);
      iBag := BAG_NULL;
      cBag := nil;
    end else
    begin
      /// otherwise we'll send as result INVENTORY_FULL error and exit!
      Result := INV_ERR_INVENTORY_FULL;
      Exit;
    end;
  end else
  /// On the other hand, if there is a bag specified
  begin
    cBag := FEqpItems.Containers[iBag];
    /// we'll adjust data and try to find a free slot in that bag
    iSlot := cBag.FindFreeSlot;

    /// If we were not able to find a free slot
    if iSlot = SLOT_NULL then
    begin
      /// then we'll send BAG_FULL error and exit!
      Result := INV_ERR_BAG_FULL;
      Exit;
    end;
  end;

  /// If we are here it means we have a free bag and a free slot in that bag
  /// so we'll adjust data now!
  /// Creating new item to add based on iItem ID provided
  cItem := GameCore.CreateNewItem(iItem, Self, cBag);

  /// If we were not able to find that item in database
  if not Assigned(cItem) or not Assigned(cItem.Template) then
  begin
    /// then we'll send ITEM_NOT_FOUND error and exit!
    Result := INV_ERR_ITEM_NOT_FOUND;
    Exit;
  /// Otherwise we'll set the result to INV_ERR_OK (everyhtign is ok xD)
  end else Result := INV_ERR_OK;

  /// Preparing the amount of items to be added
  cItem.StackCount := iAmount;
  /// Changing item's worldstate to wscAdd (to be added in world)
  cItem.ChangeWorldState(wscAdd);


  /// If iBag is not BAG_NULL
  if iBag <> BAG_NULL then
  begin
    /// then we'll assign that item to specific container list
    FEqpItems.Containers[iBag].Items[iSlot] := cItem;
    /// and we'll adjust iBag ID
    iBag := iBag + INVENTORY_SLOT_BAG_START;
  end else
  begin
    /// otherwise we'll just add the item to inventory and
    FEqpItems.Items[iSlot] := cItem;
    /// we'll prepare the updates for it
    EqpPrepareUpdatesForTheItemOnSlot(iSlot);
  end;

  /// Last thing... we'll send an Item Received Message
  EqpSendItemReceiveMessage(bNormal, False, bNormal, 0{Magic?}, iItem, iAmount, iBag);
end;


{*------------------------------------------------------------------------------
  Procedure that prepares all items a player has to be added into world
  Used when a player enteres the world.

  @see YGaPlayer
  @see EnterWorld
  @see YGaPlayer.EnterWorld
-------------------------------------------------------------------------------}
procedure YGaPlayer.EqpAddToWorld;
var
  iIdx: Int32;
begin
  /// Iterating all items
  for iIdx := ITEMS_START to ITEMS_END do
  begin
    /// if there's an items assinged in the speciffic slot
    if Assigned(FEqpItems.Items[iIdx]) then
    begin
      /// then we'll change it's tate to wscAdd (to be added to World)
      FEqpItems.Items[iIdx].ChangeWorldState(wscAdd);
    end;
  end;
end;


{*------------------------------------------------------------------------------
  Assigning an Item to an inventory slot

  @param cItem item to be assigned
  @return Returns inserting error
  @see SendItemReceiveMessage
  @see FindFreeBackpackSlot
  @see PrepareUpdatesForTheItemOnSlot
  @see INV_ERR_INVENTORY_FULL
  @see INV_ERR_BAG_FULL
  @see INV_ERR_OK
-------------------------------------------------------------------------------}
function YGaPlayer.EqpAssignItem(cItem: YGaItem): UInt32;
var
  cBag: YGaContainer;
  iBag, iSlot: UInt8;
begin
  iBag := BAG_NULL;

  /// Finding a free slot and assigning it to iSlot
  iSlot := EqpFindFreeBackpackSlot;

  /// If we found a free slot
  if iSlot <> SLOT_NULL then
  begin
    /// we'll prepare some data
    Inc(iSlot, INVENTORY_SLOT_ITEM_START);
    /// and assing INV_ERR_OK as result
    Result := INV_ERR_OK;
  end else
  begin
    /// Otherwise we'll send INVENTORY_FULL error and exit!
    Result := INV_ERR_INVENTORY_FULL;
    Exit;
  end;

  /// Assigning the item to that found Inventory Slot
  FEqpItems.Items[iSlot] := cItem;
  /// and preparing the updates for it
  EqpPrepareUpdatesForTheItemOnSlot(iSlot);

  /// Last thing... we'll send an Item Received Message
  EqpSendItemReceiveMessage(True, False, True, 0{Magic?}, cItem.Entry, cItem.StackCount, iBag);
end;


{*------------------------------------------------------------------------------
  Autostores an item received from a speciffic bag and slot to a speciffic bag,
   finding automatically a free slot in the destination bag.

  @param iBagSrc The BAG ID where the item is located
  @param iSlotSrc The SLOT ID where the item is located
  @param iBagDest Where we'll store the item
  @see YGaItem
  @see ConvertRelativeSlotToAbsolute
  @see ConvertAbsoluteSlotToRelative
  @see FindFreeSlot
  @see InventoryChange
  @see GenerateInventoryChangeError
  @see INV_ERR_INVENTORY_FULL
  @see INV_ERR_BAG_FULL
  @see INV_ERR_OK  
-------------------------------------------------------------------------------}
procedure YGaPlayer.EqpAutoStoreItem(iBagSrc, iSlotSrc, iBagDest: UInt8);
var
  cItem: YGaItem;
  iSlotDest: UInt8;
begin
  /// If iBagDest is BAG_NULL then we'll auto-store the item in inventory
  if iBagDest = BAG_NULL then
  begin
    /// and we'll find a free slot using ConvertRelativeSlotToAbsolute method
    iSlotDest := EqpConvertRelativeSlotToAbsolute(EqpFindFreeBackpackSlot, sctBackpack);
  end else
  begin
    /// Otherwise we'll find a free slot in the given BAG
    iSlotDest := Bags[EqpConvertAbsoluteSlotToRelative(iBagDest, sctBags)].FindFreeSlot;
  end;

  if iSlotDest = SLOT_NULL then
  begin
    if iBagSrc = BAG_NULL then
    begin
      /// If we found no free SLOT and source BAG is NULL (the item is actually
      ///  in backpack (inventory))
      cItem := EqpBackpackItems[EqpConvertAbsoluteSlotToRelative(iSlotSrc, sctBackpack)];
    end else
    begin
      cItem := Bags[EqpConvertAbsoluteSlotToRelative(iBagSrc, sctBags)].Items[iSlotSrc];
    end;

    /// If destination SLOT and BAG are NULL
    if iBagDest = BAG_NULL then
    begin
      /// then we'll generate INVENTORY_FULL error!
      EqpGenerateInventoryChangeError(cItem, nil, INV_ERR_INVENTORY_FULL);
    end else
    begin
      /// If destination SLOT is NULL but the BAG is not NULL
      /// then we'll send a BAG_NULL error!
      EqpGenerateInventoryChangeError(cItem, nil, INV_ERR_BAG_FULL);
    end;
  end else
  begin
    /// If we found a free SLOT then we'll proceed with changing the
    /// inventory change!
    EqpInventoryChange(iSlotSrc, iSlotDest, iBagSrc, iBagDest);
  end;
end;


{*------------------------------------------------------------------------------
  Adds an item to inventory. Slot we'll be found automatically!

  @param iItem Item's ID (the item will be loaded from templates using this ID)
  @param iAmount The amount of items to be added
  @param bNormal If FALSE, there will be no text in chat announcing you what item you received
  @return Returns inserting error
  @see YGaItem
  @see YGaContainer
  @see SendItemReceiveMessage
  @see FindFreeBackpackSlot
  @see PrepareUpdatesForTheItemOnSlot
  @see INV_ERR_INVENTORY_FULL
  @see INV_ERR_BAG_FULL
  @see INV_ERR_OK
-------------------------------------------------------------------------------}
function YGaPlayer.EqpAddItem(iItem, iAmount: UInt32; bNormal: Boolean): UInt8;
var
  cItem: YGaItem;
  cBag: YGaContainer;
  iBag, iSlot: UInt8;
begin
  /// First finding a free slot in backpack
  iSlot := EqpFindFreeBackpackSlot;

  /// If we found a free slot in BackPack
  if iSlot <> SLOT_NULL then
  begin
    /// then we'll adjust data
    Inc(iSlot, INVENTORY_SLOT_ITEM_START);
    iBag := BAG_NULL;
    cBag := nil;
  end else
  begin
    /// Otherwise we'll try to find a free BAG
    iBag := EqpFindFreeBag;

    if iBag = BAG_NULL then
    begin
      /// If we found no free bags
      ///  then we'll send INVENTORY_FULL error and exit!
      Result := INV_ERR_INVENTORY_FULL;
      EqpSendInventoryError(Result);
      Exit;
    end;

    /// If we're here than we found a free bag and now we'll look for a free slot
    cBag := FEqpItems.Bags[iBag];
    iSlot := cBag.FindFreeSlot;

    if iSlot = SLOT_NULL then
    begin
      /// If we were not able to find a free bag slot,
      ///  then we'll send BAG_FULL error and exit!
      Result := INV_ERR_BAG_FULL;
      EqpSendInventoryError(Result);
      Exit;
    end;
  end;


  /// Everything went ok though... creating a new item now
  cItem := GameCore.CreateNewItem(iItem, Self, cBag);

  if not Assigned(cItem) or not Assigned(cItem.Template) then
  begin
    /// If we were not able to find the item in database we'll send
    ///  an apropriate error (ITEM_NOT_FOUND) and exit!
    Result := INV_ERR_ITEM_NOT_FOUND;
    EqpSendInventoryError(Result);
    Exit;
  /// Otherwise we'll set the result to INV_ERR_OK (everything is ok xD)
  end else Result := INV_ERR_OK;

  /// and we'll adjust items amount
  cItem.StackCount := iAmount;
  /// Changing item's state to wscAdd (to be added to world)
  cItem.ChangeWorldState(wscAdd);

  if iBag <> BAG_NULL then
  begin
    /// if we found a free BAG, we'll add the created item to it
    FEqpItems.Bags[iBag].AddItem(cItem, iSlot);
  end else
  begin
    /// otherwise we'll add the item to backpack and
    FEqpItems.Items[iSlot] := cItem;
    /// we'll prepare the updates for it!
    EqpPrepareUpdatesForTheItemOnSlot(iSlot);
  end;

  /// Trying now to update delivery status for quests
  //Owner.Quests.UpdateDeliver(iItem, iAmount);

  if iBag <> BAG_NULL then iBag := iBag + INVENTORY_SLOT_BAG_START;

  /// Last thing... we'll send an Item Received Message
  EqpSendItemReceiveMessage(bNormal, False, bNormal, 0, iItem, iAmount, iBag);
end;


{*------------------------------------------------------------------------------
  Converts Inventory Type to slot ID

  @param iInventoryType the inventory Type
  @return Slot's ID
  @see YItemInventoryType
-------------------------------------------------------------------------------}
function YGaPlayer.EqpInventoryTypeToSlot(iInventoryType: YItemInventoryType): UInt8;
begin
  case iInventoryType of
    iitHead: Result := EQUIP_SLOT_HEAD;
    iitNeck: Result := EQUIP_SLOT_NECK;
    iitShoulders: Result := EQUIP_SLOT_SHOULDERS;
    iitBody: Result := EQUIP_SLOT_SHIRT;
    iitChest: Result := EQUIP_SLOT_CHEST;
    iitWaist: Result := EQUIP_SLOT_BELT;
    iitLegs: Result := EQUIP_SLOT_PANTS;
    iitFeet: Result := EQUIP_SLOT_BOOTS;
    iitWrists: Result := EQUIP_SLOT_WRIST;
    iitHands: Result := EQUIP_SLOT_GLOVES;
    iitWeaponUniversal: Result := EQUIP_SLOT_MAIN_HAND;
    iitShield: Result := EQUIP_SLOT_OFF_HAND;
    iitBowOrCrossbow: Result := EQUIP_SLOT_RANGED_WEAPON;
    iitCloak: Result := EQUIP_SLOT_BACK;
    iit2HandedWeapon: Result := EQUIP_SLOT_MAIN_HAND;
    iitBag:
    begin
      Result := INVENTORY_SLOT_BAG_START;
      while FEqpItems.Items[Result] <> nil do
      begin
        if Result < INVENTORY_SLOT_BAG_START + 3 then
        begin
          Inc(Result);
        end else
        begin
          Result := SLOT_NULL;
          Exit;
        end;
      end;
    end;
    iitTrinkets: Result := EQUIP_SLOT_TRINKET_1;
    iitFingers: Result := EQUIP_SLOT_FINGER_1;
    iitTabard: Result := EQUIP_SLOT_TABARD;
    iitRobe: Result := EQUIP_SLOT_CHEST;
    iitWeaponMainHand: Result := EQUIP_SLOT_MAIN_HAND;
    iitWeaponOffHand: Result := EQUIP_SLOT_OFF_HAND;
    iitHoldable: Result := EQUIP_SLOT_OFF_HAND;
    iitAmmo: Result := EQUIP_SLOT_RANGED_WEAPON;
    iitThrowable: Result := EQUIP_SLOT_RANGED_WEAPON;
    iitGunOrWand: Result := EQUIP_SLOT_RANGED_WEAPON;
  else
    Result := SLOT_NULL;
  end;
end;


{*------------------------------------------------------------------------------
  Converts Inventory Type to a set of possible Slot IDs

  @param iInventoryType the inventory Type
  @return The set with possible slot IDs
  @see YItemInventoryType
  @see YEquipmentSlots
-------------------------------------------------------------------------------}
function YGaPlayer.EqpInventoryTypeToPossibleSlots(iInventoryType: YItemInventoryType): YEquipmentSlots;
begin
  case iInventoryType of
    iitHead: Result := [esHead];
    iitNeck: Result := [esNeck];
    iitShoulders: Result := [esShoulders];
    iitBody: Result := [esShirt];
    iitChest: Result := [esChest];
    iitWaist: Result := [esBelt];
    iitLegs: Result := [esPants];
    iitFeet: Result := [esBoots];
    iitWrists: Result :=[esWrist];
    iitHands: Result := [esGloves];
    iitFingers: Result := esRingSlots;
    iitTrinkets: Result := esTrinketSlots;
    iitWeaponUniversal: Result := [esMainHand];
    iitShield: Result := [esOffHand];
    iitBowOrCrossbow: Result := [esRanged];
    iitCloak: Result := [esBack];
    iit2HandedWeapon: Result := [esMainHand];
    (*iitBag:
    begin
      Result := INVENTORY_SLOT_BAG_START;
      while FEqpItems.Items[Result] <> nil do
      begin
        if Result < INVENTORY_SLOT_BAG_START + 3 then
        begin
          Inc(Result);
        end else
        begin
          Result := SLOT_NULL;
          Exit;
        end;
      end;
    end; *)
    iitTabard: Result := [esTabard];
    iitRobe: Result := [esChest];
    iitWeaponMainHand: Result := [esMainHand];
    iitWeaponOffHand: Result := [esOffHand];
    iitHoldable: Result := [esOffHand];
    iitAmmo: Result := [esRanged];
    iitThrowable: Result := [esRanged];
    iitGunOrWand: Result := [esRanged];
  else
    Result := [];
  end;
end;


{*------------------------------------------------------------------------------
  Sends an Inventory Change Error

  @param iError The Inventory Change error code
  @see YNwServerPacket
  @see SMSG_INVENTORY_CHANGE_FAILURE
-------------------------------------------------------------------------------}
procedure YGaPlayer.EqpSendInventoryError(iError: UInt8);
var
  cOutPkt: YNwServerPacket;
begin
  /// creates the server packet
  cOutPkt := YNwServerPacket.Initialize(SMSG_INVENTORY_CHANGE_FAILURE);

  /// We'll try to
  try
    /// Add the error code to packet
    cOutPkt.AddUInt8(iError);
    /// Send the pack
    SendPacket(cOutPkt);
  finally
    /// finally we'll free the packet's used memory
    cOutPkt.Free;
  end;
end;


{*------------------------------------------------------------------------------
  Sends an Item Received Message

  @param bReward If TRUE, the message will show as the item was received as a Reward
  @param bCreated If TRUE, the message will say the item was created
  @param bHideMessage If TRUE, the message will not appear in chat messages window
  @param iUnk Unknown value, usually 0, we think it's about some "magic" id or something
  @param iItem Item's ID
  @param iAmount The amount of items that we're received
  @param iBag The bag where the item is located now
  @see YNwServerPacket
  @see SMSG_ITEM_PUSH_RESULT
-------------------------------------------------------------------------------}
procedure YGaPlayer.EqpSendItemReceiveMessage(bReward, bCreated, bHideMessage: Boolean;
  iUnk, iItem, iAmount: UInt32; iBag: UInt8);
var
  cOutPkt: YNwServerPacket;
begin
  /// Creating a server packet
  cOutPkt := YNwServerPacket.Initialize(SMSG_ITEM_PUSH_RESULT);
  try
    with cOutPkt do
    begin
      /// Adding Player's GUID (Game Unique ID)
      AddPtrData(GUID, 8);
      /// Adding the boolean values (bReward, bCreated, bHideMessage)
      AddUInt32(UInt32(bReward));
      AddUInt32(UInt32(bCreated));
      AddUInt32(UInt32(bHideMessage));
      /// Adding iBag, iUnk, iItem
      AddUInt8(iBag);
      AddUInt32(iUnk);
      AddUInt32(iItem);
      /// Skipping 2 uint32 values. We don't know their usage
      Jump(8);
      /// Adding the iAmount value to packet
      AddUInt32(iAmount);
    end;
    /// Sending the packet
    SendPacket(cOutPkt);
  finally
    /// Freeing used resources
    cOutPkt.Free;
  end;
end;


{*------------------------------------------------------------------------------
  Assigns a given amount of money to player

  @param iMoney New money number xD
  @see PLAYER_FIELD_COINAGE
-------------------------------------------------------------------------------}
procedure YGaPlayer.EqpSetMoney(iMoney: UInt32);
begin
  SetUInt32(PLAYER_FIELD_COINAGE, iMoney);
end;


{*------------------------------------------------------------------------------
  Merging Stacks between 2 slots

  @param iSrc Source slot
  @param iDest Destination slot
  @return STACK_MERGE_OK, STACK_MERGE_DIFFERES or STACK_MERGE_MAX_COUNT_IS_1
  @see YGaItem
-------------------------------------------------------------------------------}
function YGaPlayer.EqpMergeStacks(iSrc, iDest: UInt8): Int32;
const
 STACK_MERGE_OK = 0;
 STACK_CANT_STACK = 1;
 STACK_SWAP = 2;
var
  cSrc, cDest: YGaItem;
  iMax: UInt32;
  iTmp, iTmp2: UInt32;
begin
  cSrc := FEqpItems.Items[iSrc];
  cDest := FEqpItems.Items[iDest];
  iMax := cSrc.Template.MaximumCount;
  if iMax > 1 then
  begin
    /// If destination item's stack count is different then the maximum count
    ///  then we'll simply adjust stack counts.
    if cDest.StackCount <> iMax then
    begin
      iTmp := Min(iMax, cDest.StackCount + cSrc.StackCount);
      iTmp2 := cDest.StackCount + cSrc.StackCount - iTmp;
      if iTmp2 = 0 then
      begin
        /// Eventually we'll make a FULL MERGE between those 2 slots
        ///  so we'll delete the source item and update destination item with
        EqpDeleteItem(BAG_NULL, iSrc, True);
      end else
      begin
        /// In the case where is not possible to make a FULL MERGE
        ///  we'll update source item's stack count
        cSrc.StackCount := iTmp2;
      end;
      /// the new stack count
      cDest.StackCount := iTmp;
      Result := STACK_MERGE_OK;
    end else Result := STACK_CANT_STACK;
  end else Result := STACK_SWAP;
end;


{*------------------------------------------------------------------------------
  Splits items 

  @param iBagSrc Source BAG ID
  @param iSlotSrc Source SLOT ID
  @param iBagDest Destination BAG ID
  @param iSlotDest Destination SLOT ID 
  @param iCount Amount of items that will be splitted
  @see YGaItem
-------------------------------------------------------------------------------}
procedure YGaPlayer.EqpSplitItems(iBagSrc, iSlotSrc, iBagDest, iSlotDest: UInt8; iCount: UInt32);
var
  cItemSrc, cItemDest: YGaItem;
begin
  /// If iBagSrc is BAG_NULL 
  if iBagSrc = BAG_NULL then     
  begin
    /// then we'll read the item from backpack
    cItemSrc := FEqpItems.Items[iSlotSrc];
  end else
  begin
    /// otherwise we'll read the item from source bag 
    cItemSrc := FEqpItems.Containers[iBagSrc].Items[iSlotSrc];
  end;

  /// setting source item's stack count to the new value calculated
  cItemSrc.StackCount := cItemSrc.StackCount - iCount;

  /// If ibagDest is BAG_NULL
  if iBagDest = BAG_NULL then
  begin
    /// then we'll create new item in backpack
    cItemDest := GameCore.CreateNewItem(cItemSrc.Entry, Self, nil);
  end else
  begin
    /// otherwise we'll create new item in destination bag
    cItemDest := GameCore.CreateNewItem(cItemSrc.Entry, Self, FEqpItems.Containers[iBagDest]);
  end;

  /// setting destination item's StackCount to iCount value
  cItemDest.StackCount := iCount;
  /// changing it's world state to wscAdd (to be added to world)
  cItemDest.ChangeWorldState(wscAdd);

  /// Updating items (source and destination) to the new values
  FEqpItems.Items[iSlotSrc] := cItemSrc;
  FEqpItems.Items[iSlotDest] := cItemDest;

  /// Preparing the updates for them!
  EqpPrepareUpdatesForTheItemOnSlot(iSlotSrc);
  EqpPrepareUpdatesForTheItemOnSlot(iSlotDest);
end;


{*------------------------------------------------------------------------------
  Counting how many iItems we have in our Inventory!
   (searching in backpack, and bags)

  @param iItem The Item's ID
  @return The number of items we posses
-------------------------------------------------------------------------------}
function YGaPlayer.EqpThisItemCount(iItem: UInt32): Int32;
var
  iX, iY: Int32;
begin
  Result := 0;
  for iX := 0 to High(FEqpItems.BackPack) do
    if Assigned(FEqpItems.BackPack[iX]) and (FEqpItems.Backpack[iX].Entry = iItem) then
      Inc(Result, FEqpItems.Backpack[iX].StackCount);
      
  for iX := 0 to High(FEqpItems.Bags) do
  begin
    if Assigned(FEqpItems.Bags[iX]) then
      for iY := 0 to FEqpItems.Bags[iX].Template.ContainerSlots do
        if Assigned(FEqpItems.Bags[iX].Items[iY]) and (FEqpItems.Bags[iX].Items[iY].Entry = iItem) then
          Inc(Result, FEqpItems.Bags[iX].Items[iY].StackCount);
  end;
end;


{*------------------------------------------------------------------------------
  Method that will "try" to equip an item

  @param iSlot Source Slot
  @param iBag Source Bag
  @see YGaItem
  @see InventoryTypeToSlot
  @see GenerateInventoryChangeError
  @see InventoryChange
-------------------------------------------------------------------------------}
procedure YGaPlayer.EqpTryEquipItem(iSlot, iBag: UInt8);
var
  cSrc: YGaItem;
  iDest: UInt8;
begin
  case iBag of
    /// If BAG provided is BAG_NULL than we're trying to equip from backpack directly
    BAG_NULL: cSrc := FEqpItems.Items[iSlot];
  else
    /// otherwise from the given BAG
    cSrc := FEqpItems.Containers[iBag].Items[iSlot];
  end;

  /// Finding what equipment slot we'll that item have to use 
  iDest := EqpInventoryTypeToSlot(cSrc.Template.InventoryType);

  /// If destination slot is SLOT_NULL then that item cannot be equipped
  if iDest = SLOT_NULL then
  begin
    EqpGenerateInventoryChangeError(cSrc, nil, INV_ERR_ITEM_CANT_BE_EQUIPPED);
    Exit;
  end;
  
  case iBag of
    /// If BAG_NULL then we'll equip from backpack
    BAG_NULL: EqpInventoryChange(iSlot, iDest);
  else
    /// otherwise we'll equip from bag
    EqpInventoryChange(iSlot, iDest, iBag, SLOT_NULL);
  end;
end;


{*------------------------------------------------------------------------------
  Processing an Inventory Change!

  @param iSlot1 From this slot
  @param iSlot2 To this slot
  @return TRUE if change was successfull, FALSE otherwise
  @see YGaItem
  @see YGaContainer
  @see GenerateInventoryChangeError
-------------------------------------------------------------------------------}
function YGaPlayer.EqpInventoryChange(iSlot1, iSlot2: UInt8): Boolean;
var
  iError: UInt8;
  cSrcItem, cDestItem: YGaItem;
  cSrcBag: YGaContainer absolute cSrcItem;
  cDestBag: YGaContainer absolute cDestItem;
label
  __BagError,
  __WearError;
begin
  /// Reading item from Slot2
  cDestItem := FEqpItems.Items[iSlot2];

  /// If SLOT 1 is NULL or there are no items on Slot 1
  if (iSlot1 = SLOT_NULL) or (FEqpItems.Items[iSlot1] = nil) then
  begin
    ///then we'll generate change error and exit!
    EqpGenerateInventoryChangeError(nil, cDestItem, INV_ERR_SLOT_IS_EMPTY);
    Result := False;
    Exit;
  end;

  /// Reading item from Slot 1
  cSrcItem := FEqpItems.Items[iSlot1];

  /// If the slots are the same
  if iSlot1 = iSlot2 then
  begin
    /// then there's no point. Generating error and exit!
    EqpGenerateInventoryChangeError(cSrcItem, cDestItem, INV_ERR_ITEM_CANT_STACK);
    Result := False;
    Exit;
  end;


  /// If we're trying actually to equip the item in slot 2
  if (iSlot2 <= EQUIPMENT_SLOT_END) and (cSrcItem <> nil) then
  begin
    /// then we'll check if player can wear the item in that slot
    iError := EqpCanPlayerWearItem(iSlot2, cSrcItem.Entry);
    if iError <> INV_ERR_OK then
    begin
      /// If the player cannot wear that item, generating
      ///  inventory change error and exit!
      __WearError:
      EqpGenerateInventoryChangeError(cSrcItem, cDestItem, iError);
      Result := False;
      Exit;
    end;
  end;

  /// If we're trying actually to equip the item in slot 1
  if (iSlot1 <= EQUIPMENT_SLOT_END) and (cDestItem <> nil) then
  begin
    /// then we'll check if player can wear the item in that slot
    iError := EqpCanPlayerWearItem(iSlot1, cDestItem.Entry);
    if iError <> INV_ERR_OK then goto __WearError;
  end;

  /// If source Item is a bag
  if cSrcItem.IsType(otContainer) then
  begin
    /// Then if the bag is not empty
    if not cSrcBag.IsEmpty then
    begin
       /// Then we're trying to put a non-empty bag to backpack
       ///  and we'll generate an apropriate inventory change error and exit!
       __BagError:
       EqpGenerateInventoryChangeError(cSrcItem, cDestItem,
                                    INV_ERR_NONEMPTY_BAG_OVER_OTHER_BAG);
       Result := False;
       Exit;

    /// Otherwise if destination item is container and is not empty   
    end else if (cDestItem <> nil) and (cDestItem.IsType(otContainer))and
                (not YGaContainer(cDestItem).IsEmpty) then
    begin
      /// if we have more or equal slots available, we'll swap the bags, 
      /// otherwise we'll generate an apropriate inventory change error and exit!
      if cSrcBag.NumOfSlots >= cDestBag.NumOfSlots then
      begin
        cDestBag.ExchangeBagContents(cSrcBag);
      end else goto __BagError;
    end;

  /// If Slot 2 is not a bag, generating the appropriate error and exit  
  end else if (iSlot2 in [INVENTORY_SLOT_BAG_START..INVENTORY_SLOT_BAG_END]) then
  begin
    EqpGenerateInventoryChangeError(cSrcItem, cDestItem, INV_ERR_NOT_A_BAG);
    Result := False;
    Exit;

  /// If both items are ordinary items of the same type  
  end else if (cDestItem <> nil) and (cSrcItem.Entry = cDestItem.Entry) then
  begin
    /// then we'll merge them together
    case EqpMergeStacks(iSlot1, iSlot2) of
      0:
      begin
        { Successful merge }
        Result := True;
        Exit;
      end;
      1:
      begin
        { Can't stack }
        EqpGenerateInventoryChangeError(cSrcItem, cDestItem, INV_ERR_ITEM_CANT_STACK);
        Result := False;
        Exit;
      end;
      2: { Nothing, swap };
    end;
  end;

  /// Checks are done...
  /// Calling Internal Swap for those 2 slots
  EqpInternalSwap(iSlot1, iSlot2);
  /// Setting the result to TRUE (success)
  Result := True;
end;

function YGaPlayer.EqpInventoryChange(iSlotSrc, iSlotDest, iBagSrc, iBagDest: UInt8): Boolean;
{var
  iError: UInt8;
  cSrcItem, cDestItem: YOpenItem;}
begin
  {TODO 4 -oBIGBOSS -cItems : Errors & Merge checking}
  EqpInternalSwap(iSlotSrc, iSlotDest, iBagSrc, iBagDest);
  Result := True;
end;

procedure YGaPlayer.EqpGenerateInventoryChangeError(cSrc, cDest: YGaItem;
  iError: UInt8);
var
  cOutPkt: YNwServerPacket;
begin
  cOutPkt := YNwServerPacket.Initialize(SMSG_INVENTORY_CHANGE_FAILURE);
  try
    cOutPkt.AddUInt8(iError);
    if iError = INV_ERR_YOU_MUST_REACH_LEVEL_N then
    begin
      cOutPkt.AddUInt32(cSrc.Template.ReqLevel);
    end;

    if cSrc <> nil then
    begin
      cOutPkt.AddPtrData(cSrc.GUID, 8);
    end else
    begin
      cOutPkt.JumpUInt64;
    end;

    if cDest <> nil then
    begin
      cOutPkt.AddPtrData(cDest.GUID, 8);
    end else
    begin
      cOutPkt.JumpUInt64;
    end;

    cOutPkt.JumpUInt8;
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
end;

{*------------------------------------------------------------------------------
  Converts an absolute slot to a relative one

  @param iAbsSlot The absolute slot
  @param iConvType The conversion Type
  @return A relative slot
  @see YSlotConversionType
-------------------------------------------------------------------------------}
function YGaPlayer.EqpConvertAbsoluteSlotToRelative(iAbsSlot: UInt8; iConvType: YSlotConversionType): UInt8;
begin
  Assert(iConvType <= High(YSlotConversionType));
  Result := iAbsSlot - SlotOffsetTable[iConvType];
end;

{*------------------------------------------------------------------------------
  Converts a relative slot to an absolute one

  @param iRelSlot The relative slot
  @param iConvType The conversion Type
  @return An absolute slot
  @see YSlotConversionType
-------------------------------------------------------------------------------}
function YGaPlayer.EqpConvertRelativeSlotToAbsolute(iRelSlot: UInt8; iConvType: YSlotConversionType): UInt8;
begin
  Assert(iConvType <= High(YSlotConversionType));
  Result := iRelSlot + SlotOffsetTable[iConvType];
end;


procedure YGaPlayer.TrdSetItem(const iTradeSlot, iBag, iSlot, iEntry, iStackCount: UInt32);
begin
  FTrdItems[iTradeSlot].iBag := iBag;
  FTrdItems[iTradeSlot].iSlot := iSlot;
  FTrdItems[iTradeSlot].iEntry :=  iEntry;
  FTrdItems[iTradeSlot].iStackCount := iStackCount;
end;

procedure YGaPlayer.TrdReset;
var
  iX: UInt32;
begin
  FTrdCopper := 0;
  FTrdAccept := False;
  for iX := 0 to 7 do
  begin
    FTrdItems[iX].iEntry := 0;
    FTrdItems[iX].iStackCount := 0;
  end;
end;

{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
procedure YGaPlayer.SendSystemMessage(const sMessage: string);
var
  pStart: PChar;
  pCursor: PChar;
  iPos: Int32;
  iOldPos: Int32;
  cPkt: YNwServerPacket;
begin
  if Length(sMessage) = 0 then Exit;

  iPos := CharPos(#13, sMessage);
  if iPos = 0 then
  begin
    cPkt := BuildChatPacketServer(Pointer(sMessage), Length(sMessage));
    try
      SendPacket(cPkt);
    finally
      cPkt.Free;
    end;
  end else
  begin
    pStart := Pointer(sMessage);
    pCursor := pStart;
    iOldPos := 0;

    while iPos <> 0 do
    begin
      Dec(iPos); { Ignore #13#10 }
      if iPos <> 0 then { #13#10#13#10 would cause the server to send an empty chat packet }
      begin
        cPkt := BuildChatPacketServer(pCursor, iPos - iOldPos);
        try
          SendPacket(cPkt);
        finally
          cPkt.Free;
        end;
      end;
      Inc(iPos, 2);
      pCursor := pStart + iPos;
      iOldPos := iPos;
      iPos := CharPosEx(#13, sMessage, iPos);
      { Set the string to the start of the new line (after #13#10) }
    end;

    if pCursor - pStart <> Length(sMessage) then
    begin
      cPkt := BuildChatPacketServer(pCursor, Length(sMessage) - iOldPos);
      try
        SendPacket(cPkt);
      finally
        cPkt.Free;
      end;
    end;
  end;
end;


{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
procedure YGaPlayer.SendSystemMessageColored(const sMessage: string;
  cColor: ColorCode);
var
  pStart: PChar;
  pCursor: PChar;
  iPos: Int32;
  iOldPos: Int32;
  cPkt: YNwServerPacket;
begin
  if Length(sMessage) = 0 then Exit;

  iPos := CharPos(#13, sMessage);
  if iPos = 0 then
  begin
    cPkt := BuildChatPacketServer(Pointer(sMessage), Length(sMessage), cColor);
    try
      SendPacket(cPkt);
    finally
      cPkt.Free;
    end;
  end else
  begin
    pStart := Pointer(sMessage);
    pCursor := pStart;
    iOldPos := 0;

    while iPos <> 0 do
    begin
      Dec(iPos); { Ignore #13#10 }
      if iPos <> 0 then { #13#10#13#10 would cause the server to send an empty chat packet }
      begin
        cPkt := BuildChatPacketServer(pCursor, iPos - iOldPos, cColor);
        try
          SendPacket(cPkt);
        finally
          cPkt.Free;
        end;
      end;
      Inc(iPos, 2);
      pCursor := pStart + iPos;
      iOldPos := iPos;
      iPos := CharPosEx(#13, sMessage, iPos);
      { Set the string to the start of the new line (after #13#10) }
    end;

    if pCursor - pStart <> Length(sMessage) then
    begin
      cPkt := BuildChatPacketServer(pCursor, Length(sMessage) - iOldPos, cColor);
      try
        SendPacket(cPkt);
      finally
        cPkt.Free;
      end;
    end;
  end;
end;

{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
procedure YGaPlayer.SendSystemMessageRaw(const pMessage: PChar; iLen: Int32);
var
  cPkt: YNwServerPacket;
begin
  if iLen = 0 then Exit;

  cPkt := BuildChatPacketServer(pMessage, iLen);
  try
    SendPacket(cPkt);
  finally
    cPkt.Free;
  end;
end;

{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
procedure YGaPlayer.SendSystemMessageRawColored(const pMessage: PChar; iLen: Int32;
  cColor: ColorCode);
var
  cPkt: YNwServerPacket;
begin
  if iLen = 0 then Exit;

  cPkt := BuildChatPacketServer(pMessage, iLen, cColor);
  try
    SendPacket(cPkt);
  finally
    cPkt.Free;
  end;
end;

{*------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
procedure YGaPlayer.SendMessageDispatchedInRange(iType: UInt8; iLanguage: YGameLanguage;
  const sMessage, sChannel: string; const fRange: Float; bMeAlso: Boolean);
var
  cPkt: YNwServerPacket;
begin
  cPkt := BuildChatPacket(Self, iType, iLanguage, @sMessage[1], Length(sMessage),
    sChannel);
  try
    SendPacketInRange(cPkt, fRange, bMeAlso, False);
  finally
    cPkt.Free;
  end;
end;


end.
