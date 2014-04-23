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
  - Quests Manager
  - Game Master component

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author PavkaM
  @Changes TheSelby, Seth, BigBoss
  @Docs TheSelby
  @Todo Complete Honor Manager, Guild System, Action Buttons Manager,
    Skills Manager, Quests Manager, Spells, etc
-------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.WowPlayer;

interface

{$REGION 'Uses Clause'}
uses
  Misc.Miscleanous,
  Misc.Threads,
  Misc.Classes,
  Math,
  SysUtils,
  Classes,
  DateUtils,
  Misc.Geometry,
  Misc.Algorithm,
  Misc.Containers,
  Framework.Base,
  Framework.Tick,
  Components.DataCore.Storage,
  Components.DataCore.Fields,
  Components.NetworkCore.Packet,
  Components.Shared,
  Components.Interfaces,
  Components.NetworkCore.Opcodes,
  Components.GameCore.Constants,
  Components.DataCore.CharTemplates,
  Components.DataCore.Types,
  Components.GameCore.UpdateFields,
  Components.GameCore.WowContainer,
  Components.GameCore.Component,
  Components.GameCore.WowObject,
  Components.GameCore.WowMobile,
  Components.GameCore.WowUnit,
  Components.GameCore.PacketBuilders,
  Components.GameCore.WowItem,
  Components.GameCore.Interfaces,
  Components.GameCore.WowCreature,
  Components.GameCore.CommandHandler;
{$ENDREGION}

type
  YGaPlayer = class;
  YGaPlayerComponent = class;
  YGaEquipMgr = class;
  YGaChatMgr = class;
  YGaExperienceMgr = class;
  YGaActionMgr = class;
  YGaTutorialMgr = class;
  YGaSkillMgr = class;
  YGaGuildMgr = class;
  YGaHonorMgr = class;
  YGaTradeMgr = class;
  YGaQuestMgr = class;
  YGaGMMgr = class;

  {*------------------------------------------------------------------------------
  WOW Player Base Class
  Derives from YGaUnit and uses IObject, IMobile, IUnit and IPlayer interfaces

  @see IObject
  @see IMobile
  @see IUnit
  @see YGaUnit
  @see IPlayer
  -------------------------------------------------------------------------------}
  YGaPlayer = class(YGaUnit, IObject, IMobile, IUnit, IPlayer)
    private
      {$REGION 'Private members'}
      fSessionLink: ISessionInterface;  /// Interfaced Session link used to send packets. Reference to ISessionInterface Interface.
      fGuildManager: YGaGuildMgr;       /// Guild Manager
      fExpManager: YGaExperienceMgr;    /// Experience Manager
      fEquipManager: YGaEquipMgr;       /// Equipment Manager
      fTutManager: YGaTutorialMgr;      /// Tutorials Manager
      fSkillManager: YGaSkillMgr;       /// Skills Manager
      fChatManager: YGaChatMgr;         /// Chat Manager
      fActBtnsManager: YGaActionMgr;    /// Action Buttons Manager
      fHonorManager: YGaHonorMgr;       /// Honor Manager
      fTradeManager: YGaTradeMgr;       /// Trade Manager
      fQuestManager: YGaQuestMgr;       /// Quests Manager
      fGMManager: YGaGMMgr;             /// GameMaster Manager
      fCharacterName: string;           /// Character's Name
      fInRealm: string;                 /// In which realm the player is logedin
      bInBG: Boolean;                   /// Saves whether the player is in  BattleGround or not
      fMyUpdates: YNwPacket;            /// Character's Updates Packet
      fMyUpdateCount: Int32;            /// Character's Updates count
      fMemberInChannels: TStrArrayList; /// Array with the channels in which this character is a member
      fLock: TCriticalSection;          /// Critical Section Locker

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
      {$ENDREGION}
    protected
      {$REGION 'Protected members'}
      class function GetObjectType: Int32; override;
      class function GetOpenObjectType: YWowObjectType; override;

      { Override this in children to perform resource loading }
      procedure ExtractObjectData(cEntry: YDbSerializable); override;
      { Override this in children to perform resource saving }
      procedure InjectObjectData(cEntry: YDbSerializable); override;
      { Override this in children to perform resource deletion }
      procedure CleanupObjectData; override;

      procedure EnterWorld; override;
      procedure LeaveWorld; override;

      procedure SetCreationParams(out UpdateType: UInt8; UpdatingSelf: Boolean); override;
      procedure AddMovementData(cPkt: YNwServerPacket; bSelf: Boolean); override;

      procedure RequestUpdatesFromObject(Obj: YGaMobile; Request: YUpdateRequest); override;
      {$ENDREGION}
    public
      {$REGION 'Public members'}
      constructor Create; override;
      destructor Destroy; override;
      
      { Template Creation }
      procedure CreateFromTemplate(TpStore: YDbCharTemplateStore; GameClass: YGameClass;
        GameRace: YGameRace; Gender: YGameGender);
      { This function gets called every few world ticks }
      procedure PlayerLifeTimer(Event: TEventHandle; TimeDelta: UInt32);
      procedure AddUpdateBlock(Block: YNwPacket);
      procedure SendPacket(Pkt: YNwServerPacket); inline;

      procedure OnValuesUpdate; override;

      property Account: string read GetAccountName;   ///Accesses Acount Name (read)
      property Name: string read fCharacterName write fCharacterName;  ///Accesses character's name (read/write)
      property InRealmName: string read fInRealm write fInRealm;    ///Accesses fInRealm private member (read/write)
      property InBattleGround: boolean read bInBG write bInBG;      ///Sets/gets "In Battleground" status
      property Guild: YGaGuildMgr read fGuildManager;               ///Accesses Guild manager component
      property Experience: YGaExperienceMgr read fExpManager;       ///Accesses Experience manager component
      property Tutorials: YGaTutorialMgr read fTutManager;          ///Accesses Tutorials manager component
      property Skills: YGaSkillMgr read fSkillManager;              ///Accesses Skills manager component
      property Equip: YGaEquipMgr read fEquipManager;               ///Accesses Equipment manager component
      property Chat: YGaChatMgr read fChatManager;                  ///Accesses Chat manager component
      property Honor: YGaHonorMgr read fHonorManager;               ///Accesses Honor manager component
      property ActionBtns: YGaActionMgr read fActBtnsManager;       ///Accesses Action Buttons manager component
      property Trade: YGaTradeMgr read fTradeManager;               ///Accesses Trade manager component
      property Quests: YGaQuestMgr read fQuestManager;              ///Accesses Quests manager component
      property GMManager: YGaGMMgr read fGMManager;                 ///Accesses GameMaster module
      property Session: ISessionInterface read fSessionLink write fSessionLink;  ///Sets/Gets Session Interface
      property Skin: UInt8 read GetSkin write SetSkin;              ///Accesses Skin property (read/write)
      property Face: UInt8 read GetFace write SetFace;              ///Accesses Face property (read/write)
      property HairStyle: UInt8 read GetHairStyle write SetHairStyle;    ///Accesses Hair Style property (read/write)
      property HairColor: UInt8 read GetHairColor write SetHairColor;    ///Accesses Hair Color property (read/write)
      property FacialHair: UInt8 read GetFacialHair write SetFacialHair; ///Accesses Facial Hair property (read/write)
      property Channels: TStrArrayList read fMemberInChannels;           ///Reads Channels Membership list
      {$ENDREGION}
    end;

  {*------------------------------------------------------------------------------
  WOW Player Component Class which is the parent of all other player components
  Derives from YGaObjectComponent class

  @see YGaObjectComponent
  -------------------------------------------------------------------------------}
  YGaPlayerComponent = class(YGaObjectComponent)
    private
      {$REGION 'Private members'}
      fOwner: YGaPlayer;   ///Component's Owner (YGaPlayer)
      {$ENDREGION}
    protected
      {$REGION 'Protected members'}
      procedure SendPacket(cPkt: YNwServerPacket); inline;
      {$ENDREGION}
    public
      {$REGION 'Public members'}
      constructor Create(cOwner: YGaPlayer); reintroduce;
      property Owner: YGaPlayer read fOwner;
      {$ENDREGION}
  end;


  {$REGION 'Equipment Utility Types'}
  PEquipment = ^YEquipment;  ///Pointer to YEquipment
  ///Record containing Equipment elements
  YEquipment = record
    { Ahh, a *nice* hack, we'll use an union }
    case Byte of
      0: (
        Items: array[ITEMS_START..ITEMS_END] of YGaItem; { All items }
      );
      1: (
        Containers: array[ITEMS_START..ITEMS_END] of YGaContainer; { All items as containers }
      );
      2: (
        EquippedItems : array[0..EQUIPMENT_SLOT_END      - EQUIPMENT_SLOT_START     ] of YGaItem;
        Bags          : array[0..INVENTORY_SLOT_BAG_END  - INVENTORY_SLOT_BAG_START ] of YGaContainer;
        Backpack      : array[0..INVENTORY_SLOT_ITEM_END - INVENTORY_SLOT_ITEM_START] of YGaItem;
        Bank          : array[0..BANK_SLOT_ITEM_END      - BANK_SLOT_ITEM_START     ] of YGaItem;
        BankBags      : array[0..BANK_SLOT_BAG_END       - BANK_SLOT_BAG_START      ] of YGaContainer;
        Buyback       : array[0..BUYBACK_SLOT_END        - BUYBACK_SLOT_START       ] of YGaItem;
        Keyring       : array[0..KEYRING_SLOT_END        - KEYRING_SLOT_START       ] of YGaItem;
      );
  end;

  ///Previous Item used record
  YPrevItemUsed = record
    iSlot: UInt8;
    fItem: YGaItem;
  end;
{$ENDREGION}

  {*------------------------------------------------------------------------------
  WOW Player Equipment Class
  Derives from YGaPlayerComponent class
  This will take care of almost all inteactions with items (loading, saving, equiping, etc)

  @see YGaPlayerComponent
  -------------------------------------------------------------------------------}
  YGaEquipMgr = class(YGaPlayerComponent)
    private
      {$REGION 'Private members'}
      fItems: YEquipment;       ///Player's Items (equipped or in backpack)
      fTempItem: YPrevItemUsed; ///Saves previous item used before using a new one

      function GetMoney: UInt32; inline;
      function GetEquipedItem(iSlot: UInt32): YGaItem; inline;
      function GetBag(iSlot: UInt32): YGaContainer; inline;
      function GetBackpackItem(iSlot: UInt32): YGaItem; inline;
      function GetBankItem(iSlot: UInt32): YGaItem; inline;
      function GetBankBag(iSlot: UInt32): YGaContainer; inline;
      function GetBuybackItem(iSlot: UInt32): YGaItem; inline;
      function GetKeyringItem(iSlot: UInt32): YGaItem; inline;

      function CanPlayerWearItem(iSlot: UInt8; iEntry: UInt32): UInt8;

      procedure InternalSwap(iSlot1, iSlot2: UInt8); overload;
      procedure InternalSwap(iSlot1, iSlot2, iBag1, iBag2: UInt8); overload;

      procedure SendItemReceiveMessage(bReward, bCreated, bHideMessage: Boolean;
        iUnk, iItem, iAmount: UInt32; iBag: UInt8);

      procedure SetMoney(iMoney: UInt32); inline;
      {$ENDREGION}
    public
      {$REGION 'Public members'}
      destructor Destroy; override;

      { Adds all items currently "on player" to the world }
      procedure AddToWorld;

      procedure ExtractObjectData(cEntry: YDbSerializable); override;
      procedure InjectObjectData(cEntry: YDbSerializable); override;
      procedure CleanupObjectData; override;

      { Transfer changed item's properites to player's fields (visible) }
      procedure PrepareUpdatesForTheItemOnSlot(iSlot: UInt32; bForceAlteringStats : Boolean = false);

      (*
       *   Item Manipulation Routines.
       *)

      { Finds a free slot in the main backpack }
      function FindFreeBackpackSlot: UInt8;

      { Finds a bag that has a free slot }
      function FindFreeBag: UInt8;

      { Adds an item into a free equipment slot }
      function AddItem(iItem, iAmount: UInt32; bNormal: Boolean): UInt8;

      { Assigns an item into a free equipment slot and returns the replaced one }
      function AssignItem(cItem: YGaItem): UInt32;

      { Adds an item into a specific bag }
      function AddItemToBag(iBag: UInt8; iItem, iAmount: UInt32; bNormal: Boolean): UInt8;

      { Moves an item from a specific slot in one bag into a random slot in another }
      procedure AutoStoreItem(iBagSrc, iSlotSrc: UInt8; iBagDest: UInt8);

      { Deletes an item from the player and optionally also from the database }
      function DeleteItem(iBag, iSlot: UInt8; bDestroy: Boolean): YGaItem;

      function InventoryTypeToSlot(iInventoryType: YItemInventoryType): UInt8;
      function InventoryTypeToPossibleSlots(iInventoryType: YItemInventoryType): YEquipmentSlots;

      { Tries to split an item into 2 seperate stacks }
      procedure SplitItems(iBagSrc, iSlotSrc: UInt8; iBagDest, iSlotDest: UInt8; iCount: UInt32);

      { Tries to merge stacks of items }
      function MergeStacks(iSrc, iDest: UInt8): Int32;

      { Tries to equip an item }
      procedure TryEquipItem(iSlot : UInt8; iBag: UInt8);

      { Swaps 2 items in the equipment, excluding bags }
      function InventoryChange(iSlot1, iSlot2: UInt8): Boolean; overload;

      { Swaps 2 items }
      function InventoryChange(iSlotSrc, iSlotDest : UInt8; iBagSrc, iBagDest: UInt8): Boolean; overload;

      { Says how many times you have an item (for quest) }
      function ThisItemCount(iItem: UInt32): Int32;

      { Says if you have enough free slots (for quest for) }
      function HasEnoughFreeSlots(iCount: Int32): Boolean;

      { Send an error message to the client }
      procedure GenerateInventoryChangeError(cSrc, cDest: YGaItem; iError: UInt8);

      { Overwrites an item at the specified slot }
      procedure InsertItem(iSlot: UInt32; iId: UInt32; iAmount: UInt32 = 1;
        bOverrideChecks: Boolean = False);

      procedure SendInventoryError(iError: UInt8);

      property EquippedItems[iSlot: UInt32]: YGaItem read GetEquipedItem;
      property Bags[iSlot: UInt32]: YGaContainer read GetBag;
      property BackpackItems[iSlot: UInt32]: YGaItem read GetBackpackItem;
      property BankItems[iSlot: UInt32]: YGaItem read GetBankItem;
      property BankBags[iSlot: UInt32]: YGaContainer read GetBankBag;
      property BuybackItems[iSlot: UInt32]: YGaItem read GetBuybackItem;
      property Keyring[iSlot: UInt32]: YGaItem read GetKeyringItem;
      property Money: UInt32 read GetMoney write SetMoney;
      {$ENDREGION}
    end;

  {*------------------------------------------------------------------------------
  WOW Player Chat Manager
  Derives from YGaPlayerComponent class
  This will manage all chat options (channels, whisper, emotes, etc)

  @see YGaPlayerComponent
  -------------------------------------------------------------------------------}
  YGaChatMgr = class(YGaPlayerComponent)
    private
      {$REGION 'Private members'}
      { Processes the command and returns true is processed }
      function ProcessChatCommand(var sCommand: string): Boolean;

      { Command handlers }
      function CommandHelp(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandList(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandSyntax(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandOnline(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandAdd(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandSetSpeed(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandSave(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandGPS(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandTeleport(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandLevelUp(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandMorph(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandDeMorph(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandShowMount(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandHideMount(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandTeleportTo(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandBroadcast(Sender: YGaCommandHandlerTable; const Args: string): YCommandCallResult;
      function CommandCreateNode(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandDeleteNode(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandNodeAddSpawn(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandNodeRemSpawn(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandSetUnitFlagBits(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandUnSetUnitFlagBits(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandTestUnitFlagBits(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandSetPass(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandQueryHeight(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandDisableCommand(Sender: YGaCommandHandlerTable; const Args: string): YCommandCallResult;
      function CommandEnableCommand(Sender: YGaCommandHandlerTable; const Args: string): YCommandCallResult;
      function CommandKill(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandStartMovement(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;

      { Debug command handlers }
      function CommandDbgSetUpdateFieldI(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandDbgSetUpdateFieldF(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandDbgEquipmeWithItems(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandDbgSuicide(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandDbgHealSelf(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      function CommandDbgHonor(Sender: YGaCommandHandlerTable; cParams: TStringDataList): YCommandCallResult;
      {$ENDREGION}
    public
      {$REGION 'Public members'}
      procedure ExtractObjectData(cEntry: YDbSerializable); override;
      procedure InjectObjectData(cEntry: YDbSerializable); override;
      procedure CleanupObjectData; override;

      { Send a system message to the player }
      procedure SystemMessage(const sMessage: string); overload;
      { Send a system message to the player (PCHAR) }
      procedure SystemMessageRaw(const pMessage: PChar; iLen: Int32); overload;
      { Send a system message to the player }
      procedure SystemMessageColored(const sMessage: string; cColor: ColorCode); overload;
      { Send a system message to the player (PCHAR) }
      procedure SystemMessageRawColored(const pMessage: PChar; iLen: Int32;
        cColor: ColorCode); overload;
      { Dispatch a chat message to all nearby players }
      procedure DispatchMessageInRange(iType: UInt8; iLanguage: YGameLanguage;
        const sMessage, sChannel: string; const fRange: Float; bMeAlso: Boolean);
      { Incomming packet processer }
      procedure HandleChatMessage(cPkt: YNwClientPacket);
      {$ENDREGION}
    end;

  {*------------------------------------------------------------------------------
  WOW Player Experience Class
  Derives from YGaPlayerComponent class
  This will manage the experience a player has. Will be used by other components like
    Quests manager, Combat Sistem, etc...

  @see YGaPlayerComponent
  -------------------------------------------------------------------------------}
  YGaExperienceMgr = class(YGaPlayerComponent)
    private
      {$REGION 'Private members'}
      fRestedState: UInt8;  ///Player's rested state. If the value is greater than 30 then the player is considered to be rested.

      function GetRestState: Boolean;
      {$ENDREGION}
    public
      {$REGION 'Public members'}
      procedure ExtractObjectData(cEntry: YDbSerializable); override;
      procedure InjectObjectData(cEntry: YDbSerializable); override;
      procedure CleanupObjectData; override;

      /// Property that reads/sets player's rested percentage. Be sure to use values in range [0..100]
      property SetRestedPercentage: UInt8 read fRestedState write fRestedState;
      property IsRested: Boolean read GetRestState;   ///Property that reads if the player is rested ot not
      {$ENDREGION}
  end;

  {*------------------------------------------------------------------------------
  WOW Player Action Buttons Class
  Derives from YGaPlayerComponent class
  This will manage all player's action buttons

  @see YGaPlayerComponent
  -------------------------------------------------------------------------------}
  YGaActionMgr = class(YGaPlayerComponent)
    private
      {$REGION 'Private members'}
      fActionButtons: array[0..PLAYER_MAXIMUM_ACTION_BUTTONS] of UInt32;  ///Action buttons array having a maximum of PLAYER_MAXIMUM_ACTION_BUTTONS buttons (10 button bars * 12 per bar)

      procedure AddButton(iButtonIdx: UInt8; iValue: UInt32);
      function ReadButton(iButtonIdx: UInt8): UInt32;
      {$ENDREGION}
    public
      {$REGION 'Public members'}
      procedure ExtractObjectData(cEntry: YDbSerializable); override;
      procedure InjectObjectData(cEntry: YDbSerializable); override;
      procedure CleanupObjectData; override;

      ///Property that reads/sets an action button
      property ActionButton[iButtonIdx: UInt8]: UInt32 read ReadButton write AddButton;
      procedure SendActionButtons;
      {$ENDREGION}
  end;

  {*------------------------------------------------------------------------------
  WOW Player Tutorials Class
  Derives from YGaPlayerComponent class
  This will manage all player's tutorial behaviour

  @see YGaPlayerComponent
  -------------------------------------------------------------------------------}
  YGaTutorialMgr = class(YGaPlayerComponent)
    private
      {$REGION 'Private members'}
      fTutorials: array[0..PLAYER_MAXIMUM_TUTORIALS] of UInt32; ///Tutorials array having a maximum number of PLAYER_MAXIMUM_TUTORIALS (7) members

      function GetTutFlag(iIndex: UInt32): Boolean;
      procedure SetTutFlag(iIndex: UInt32; const bValue: Boolean);
      {$ENDREGION}
    public
      {$REGION 'Public members'}
      procedure ExtractObjectData(cEntry: YDbSerializable); override;
      procedure InjectObjectData(cEntry: YDbSerializable); override;
      procedure CleanupObjectData; override;

      { Marks all tutorials as Read }
      procedure MarkReadAllTutorials;
      { Marks all tutorials as Unread }
      procedure MarkUnreadAllTutorials;
      { Send the tuttorials status }
      procedure SendTutorialsStatus;

      /// Property that reads/sets a tutorial's flag
      property Tutorials[iIndex: UInt32]: Boolean read GetTutFlag write SetTutFlag;
      {$ENDREGION}
    end;

  {*------------------------------------------------------------------------------
  WOW Player Skills Class
  Derives from YGaPlayerComponent class
  This will manage all player's skills

  @see YGaPlayerComponent
  -------------------------------------------------------------------------------}
  YGaSkillMgr = class(YGaPlayerComponent)
    private
      {$REGION 'Private members'}
      function GetSkillCrr(iIndex: UInt32): UInt16;
      function GetSkillId(iIndex: UInt32): UInt32;
      function GetSkillMax(iIndex: UInt32): UInt16;
      procedure SetSkillCrr(iIndex: UInt32; const Value: UInt16);
      procedure SetSkillId(iIndex: UInt32; const Value: UInt32);
      procedure SetSkillMax(iIndex: UInt32; const Value: UInt16);
      function GetSkillCount: UInt32;

      { Retreives a specific part of the line }
      function RetreiveSkillData(iSkillLine, iPiece: UInt32): UInt32;
      { Saves a specific part of the line }
      procedure SaveSkillData(iSkillLine, iInt, iPiece: UInt32);
      {$ENDREGION}
    public
      {$REGION 'Private members'}
      procedure ExtractObjectData(cEntry: YDbSerializable); override;
      procedure InjectObjectData(cEntry: YDbSerializable); override;
      procedure CleanupObjectData; override;

      { Adds a new skill to player and returns the index }
      function AddNewSkill(iSkillId: UInt32; iSkillKnown, iSkillMax: UInt32): Int32;
      { Checks to see if the player knows this skill }
      function HasSkill(iSkillId: UInt32): Boolean;

      { Access all skill info with these properties }
      property SkillId[iIndex: UInt32]: UInt32 read GetSkillId  write SetSkillId;       ///Accesses Skill's ID (read/write)
      property SkillCurrent[iIndex: UInt32]: UInt16 read GetSkillCrr write SetSkillCrr; ///Accesses Skill's Current Value (read/write)
      property SkillMax[iIndex: UInt32]: UInt16 read GetSkillMax write SetSkillMax;     ///Accesses Skill's Maximum Value (read/write)
      property KnownSkills: UInt32 read GetSkillCount;     ///This property returns the number of learned skills
      {$ENDREGION}
    end;

  {*------------------------------------------------------------------------------
  WOW Player Guild Class
  Derives from YGaPlayerComponent class
  Manages the relationship of a player with a guild

  @see YGaPlayerComponent
  -------------------------------------------------------------------------------}
  YGaGuildMgr = class(YGaPlayerComponent)
    private
      {$REGION 'Private members'}
      procedure SetGuildId(const Value: UInt32);
      procedure SetGuildRank(const Value: UInt32);
      function GetGuildId: UInt32;
      function GetGuildRank: UInt32;
      {$ENDREGION}
    public
      {$REGION 'Private members'}
      procedure ExtractObjectData(cEntry: YDbSerializable); override;
      procedure InjectObjectData(cEntry: YDbSerializable); override;
      procedure CleanupObjectData; override;

      property ID: UInt32 read GetGuildId write SetGuildId;        ///Accesses Guild's ID (read/write)
      property Rank: UInt32 read GetGuildRank write SetGuildRank;  ///Accesses Guild's Rank (read/write)
      {$ENDREGION}
    end;

  {*------------------------------------------------------------------------------
  WOW Player Honor Class
  Derives from YGaPlayerComponent class
  This will manage all player's honor data (weekly, daily, etc)

  @see YGaPlayerComponent
  -------------------------------------------------------------------------------}
  YGaHonorMgr = class(YGaPlayerComponent)
    private
      {$REGION 'Private members'}
      fHonorStats: array [HONOR_START..HONOR_END] of Integer;  ///An array with player's honor values

      procedure RenewPrevDayStats; inline;
      procedure RenewPrevWeekStats; inline;
      procedure RenewYesterdayHonor; inline;
      procedure IncreaseLifeTimeKills(bHonorable : Boolean = true); inline;
      procedure IncreaseThisWeekKills; inline;
      
      function ComputeRank(bHonorable: Boolean): UInt32; inline;
      function Standing: UInt32; inline;
      function HonorablePlayersOnServer: UInt32; inline;
      //return the number of players that are part of this honor table shit
      function RankPercentage(iRank, iPoints: Integer): UInt8; inline;

      procedure Honor(iKilledTimesBefore: Integer; iLevelDifference: Integer;
        iHonorRank: UInt32; iStanding: UInt32; iReputationPercentage: UInt32;
        iBGPoints: Integer; bFactionDiffers: Boolean = True);

      function GetPVPRank: UInt8;
      procedure SetPVPRank(const Value: UInt8);
      {$ENDREGION}
    public
      {$REGION 'Public members'}
      procedure ExtractObjectData(cEntry: YDbSerializable); override;
      procedure InjectObjectData(cEntry: YDbSerializable); override;
      procedure CleanupObjectData; override;

      property  PVPRank: UInt8 read GetPVPRank write SetPVPRank;    ///Accesses player's PVPRank (read/write)
      procedure IncreaseSessionKills(iKilledTimesBefore: Integer; {signed because if the killer was killed before that by the current oponent more honor will be received}
        iLevelDifference: Integer; {also signed, as for both types of level differences}
        iHonorRank: UInt32;
        iStanding: UInt32;       //this is the standing of the oponent
        iReputationPercentage: UInt32;  //oponentsRepLevel for his faction
        iBGPoints: Integer;
        bFactionDiffers: Boolean = True);

      procedure AddQuestHonorPoints(iValue: Integer); //signed because maybe I may want to delete some honor dooh :D
      procedure AddBattleGroundHonor(iBGPoints: Integer);
      {$ENDREGION}
  end;

  {$REGION 'Trade useful types'}
  PTradeItem = ^YTradeItem;  ///Pointer to YTradeItem
  ///Record with trade items
  YTradeItem = record
    iBag, iSlot, iEntry, iStackCount: UInt32;
  end;

  YTradeItemArray = array[0..MAXIMUM_TRADE_ITEMS] of YTradeItem;  ///Array of trade-able items
{$ENDREGION}

  {*------------------------------------------------------------------------------
  WOW Player Trade System Class
  Derives from YGaPlayerComponent class
  Manages player's in-game trade system

  @see YGaPlayerComponent
  -------------------------------------------------------------------------------}
  YGaTradeMgr = class(YGaPlayerComponent)
    private
      {$REGION 'Private members'}
      fCopper: UInt32;          ///Copper to trade
      fTrader: YGaPlayer;       ///The trader (YGaPlayer)
      fItems: YTradeItemArray;  ///Items array
      fAccept: Boolean;         ///Boolean value if accepts the trade or not
      {$ENDREGION}
    public
      {$REGION 'Public members'}
      procedure Reset;
      procedure SetItem(const iTradeSlot, iBag, iSlot, iEntry, iStackCount: UInt32);

      property Trader: YGaPlayer read fTrader write fTrader;  ///Accesses trader (read/write)
      property Copper: UInt32 read fCopper write fCopper;     ///Accesses copper value to be traded (read/write)
      property Accept: Boolean read fAccept write fAccept;    ///Accesses TradeAccepted boolean value (read/write)
      property Items: YTradeItemArray read fItems write fItems; ///Accesses trade items array (read/write)
      {$ENDREGION}
    end;

  {$REGION 'Quests useful types'}
    PActiveQuestsInfo = ^YActiveQuestsInfo;  ///Pointer to YActiveQuestsInfo
    ///Record with Quests Informations
    YActiveQuestsInfo = record
      Template: YDbQuestTemplate;
      //DeliverObjectives: YQuestObjects;
      DeliverObjectivesStatus: array[0..QUEST_OBJECTS_COUNT - 1] of UInt32;
      //KillObjectives: YQuestObjects;
    end;
  
    YActiveQuestsInfos = array[0..QUEST_LOG_COUNT - 1] of YActiveQuestsInfo; ///Array of quests (maximum value is QUEST_LOG_COUNT - 1)
{$ENDREGION}

  {*------------------------------------------------------------------------------
  WOW Player Quests System Class
  Derives from YGaPlayerComponent class
  Manages player's in-game quest system

  @see YGaPlayerComponent
  -------------------------------------------------------------------------------}
  YGaQuestMgr = class(YGaPlayerComponent)
    private
      {$REGION 'Private members'}
      fActiveQuests: YActiveQuests;            ///List of Active quests
      fActiveQuestsInfos: YActiveQuestsInfos;  ///List of Active quests informations
      fFinishedQuests: TLongWordDynArray;      ///List of Finished quests
      //what's the best to be used? FastStringList or something??
      {$ENDREGION}
    public
      {$REGION 'Public members'}
      procedure ExtractObjectData(cEntry: YDbSerializable); override;
      procedure InjectObjectData(cEntry: YDbSerializable); override;
      procedure CleanupObjectData; override;

      function GetLogId(iQuestId: UInt32): Int32;
      function IsFinishedQuest(iQuestId: UInt32): Boolean;
      function IsWaitingForReward(iLogId: Int32): Boolean;
      function GetFinishDialogStatus(iLogId: Int32): UInt32;
      procedure QuestExploration(iQuestId: UInt32);
      function IsAvailable(iQuestId: Int32): Boolean;
      procedure Add(iQuestId: UInt32);
      procedure Remove(iQuestLogId: UInt32);
      procedure UpdateKillObject(iId: UInt32; iGuid: UInt64);
      procedure UpdateDeliver(iItemId, iCount: UInt32);
      procedure AddToFinishedQuests(iQuestId: UInt32);

      property ActiveQuests: YActiveQuests read fActiveQuests write fActiveQuests; ///Accesses Active quests list (read/write)
      property ActiveQuestsInfos: YActiveQuestsInfos read fActiveQuestsInfos;      ///Accesses Active quests Informations list (read/write)
      property Count: Int32 read fActiveQuests.Count;          ///Reads Active Quests count
      {$ENDREGION}
    end;

  {*------------------------------------------------------------------------------
  WOW Player GameMaster Module
  Derives from YGaPlayerComponent class
  Manages player's Game-Master priviledges system

  @see YGaPlayerComponent
  -------------------------------------------------------------------------------}
  YGaGMMgr = class(YGaPlayerComponent)
    private
      {$REGION 'Private members'}
      fTPPlaces: YTPPlaces;  ///List of TP Places 
      {$ENDREGION}
    public
      {$REGION 'Public members'}
      procedure ExtractObjectData(cEntry: YDbSerializable); override;
      procedure InjectObjectData(cEntry: YDbSerializable); override;
      procedure CleanupObjectData; override;

      procedure SetTP(sName: string);
      procedure RemTP(iX: Int32);

      property TPPlaces: YTPPlaces read fTPPlaces;  ///Reads all Saved TP Places
      {$ENDREGION}
    end;

{$REGION 'Additional Methods/Types'}
    YSlotConversionType = (sctEquipped, sctBags, sctBackpack, sctBank, sctBankBags, sctBuyback, sctKeyring);   ///Used in conversions (absolute to relative and vice-versa)
  
procedure InitializePlayerCommandHandlers;

function CreateNewItem(iEntry: UInt32; cOwner: YGaPlayer; cContained: YGaContainer): YGaItem;
function ConvertAbsoluteSlotToRelative(iAbsSlot: UInt8; iConvType: YSlotConversionType): UInt8;
function ConvertRelativeSlotToAbsolute(iRelSlot: UInt8; iConvType: YSlotConversionType): UInt8;
{$ENDREGION}


implementation

{$REGION 'Uses Clause'}
uses
  MMSystem,
  Framework,
  Cores,
  Components.GameCore,
  Components.GameCore.Nodes,
  Components.GameCore.Channel;
{$ENDREGION}


{*------------------------------------------------------------------------------
  Freeing resources. First cleaning up all YGaPlayer members.
-------------------------------------------------------------------------------}
procedure YGaPlayer.CleanupObjectData;
begin
  fGuildManager.CleanupObjectData;
  fExpManager.CleanupObjectData;
  fEquipManager.CleanupObjectData;
  fTutManager.CleanupObjectData;
  fSkillManager.CleanupObjectData;
  fChatManager.CleanupObjectData;
  fActBtnsManager.CleanupObjectData;
  fHonorManager.CleanupObjectData;
  fQuestManager.CleanupObjectData;
  fGMManager.CleanupObjectData;
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
  iIndex: Int32;
  cTemp: YDbCharTemplate;
begin
  /// Combining date form multiple templates accordingly to given GameClass
  ///   and GameRace using a temporary cTemp variable 
  cTemp := TpStore.CombineTemplate(GameRace, GameClass);

  /// Assigning character's Race, Class and Gender
  Stats.Race := GameRace;
  Stats.&Class := GameClass;
  Stats.Gender := Gender;

  /// Deppending on given Gender, we'll assing a MaleBody or FemaleBody Texture ID
  case Gender of
    ggMale: Stats.Model := cTemp.MaleBodyModel;
    ggFemale: Stats.Model := cTemp.FemaleBodyModel;
  else
    Stats.Model := 0;
  end;

  /// Assigning Body Size
  Size := cTemp.BodySize;

  /// Assigning Stats (Health, Powers, Rezistances, etc)
  Stats.MaxHealth := cTemp.BaseHealth;
  Stats.Health := cTemp.BaseHealth;
  Stats.PowerType := YGamePowerType(cTemp.PowerType);
  Stats.MaxPower := cTemp.BasePower;
  if Stats.PowerType <> gptRage then
  begin
    Stats.Power := cTemp.BasePower;
  end else Stats.Power := 0;

  Stats.Strength := cTemp.InitialStrength div 1000;
  Stats.Agility := cTemp.InitialAgility div 1000;
  Stats.Stamina := cTemp.InitialStamina div 1000;
  Stats.Intellect := cTemp.InitialIntellect div 1000;
  Stats.Spirit := cTemp.InitialSpirit div 1000;

  /// Assigning Attack times
  Stats.BaseAttackTimeHi := cTemp.AttackTimeHi;
  Stats.BaseAttackTimeLo := cTemp.AttackTimeLo;

  /// Assigning character's faction depending on GameRace
  Stats.Faction := FactionTemplateByRace(GameRace);

  /// Assigning vector positions (Map, ZOne, X, Y, Z and Angle orientation)
  Position.MapId := cTemp.Map;
  Position.ZoneId := cTemp.Zone;
  Position.X := cTemp.StartingX;
  Position.Y := cTemp.StartingY;
  Position.Z := cTemp.StartingZ;
  Position.Angle := cTemp.StartingAngle;

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
  Stats.MeleeAttackDamageHi := cTemp.BaseDamageHi;
  Stats.MeleeAttackDamageLo := cTemp.BaseDamageLo;
  Stats.MeleeAttackPower := cTemp.AttackPower;

  /// Assigning Speeds (walk, run, swim, backwalk, backswim, etc)
  Position.WalkSpeed := SPEED_WALK;
  Position.RunSpeed := SPEED_RUN;
  Position.BackSwimSpeed := SPEED_BACKSWIM;
  Position.SwimSpeed := SPEED_SWIM;
  Position.BackWalkSpeed := SPEED_BACKWALK;
  Position.TurnRate := SPEED_TURNRATE;

  /// Marking all tutorials as unread
  Tutorials.MarkUnreadAllTutorials;

  /// Preparing action buttons
  for iIndex := 0 to 120 do
  begin
    ActionBtns.ActionButton[iIndex] := cTemp.ActionButtons[iIndex];
  end;

  /// Preparing skills
  for iIndex := 0 to Length(cTemp.SkillData) -1 do
  begin
    Skills.AddNewSkill(cTemp.SkillData[iIndex].Id, cTemp.SkillData[iIndex].Initial,
      cTemp.SkillData[iIndex].Max);
  end;

  /// Preparing equipment
  for iIndex := 0 to Length(cTemp.ItemData) -1 do
  begin
    with cTemp.ItemData[iIndex] do
    begin
      Equip.InsertItem(Slot, Id, Count);
    end;
  end;

  /// freeing resources: getting rid of temporary cTemp variable used.
  TpStore.Medium.ReleaseEntry(cTemp);
end;

{*------------------------------------------------------------------------------
  Loads data for a given entry

  @param cEntry Database Serializable component
  @see YDbSerializable
-------------------------------------------------------------------------------}
procedure YGaPlayer.ExtractObjectData(cEntry: YDbSerializable);
begin
  inherited ExtractObjectData(cEntry);
  fCharacterName := YDbPlayerEntry(cEntry).CharName;
  fGuildManager.ExtractObjectData(cEntry);
  fExpManager.ExtractObjectData(cEntry);
  fTutManager.ExtractObjectData(cEntry);
  fEquipManager.ExtractObjectData(cEntry);
  fSkillManager.ExtractObjectData(cEntry);
  fChatManager.ExtractObjectData(cEntry);
  fActBtnsManager.ExtractObjectData(cEntry);
  fHonorManager.ExtractObjectData(cEntry);
  fQuestManager.ExtractObjectData(cEntry);
  fGMManager.ExtractObjectData(cEntry);
end;

{*------------------------------------------------------------------------------
  Saves data for given entry

  @param cEntry Database Serializable component
  @see YDbSerializable
-------------------------------------------------------------------------------}
procedure YGaPlayer.InjectObjectData(cEntry: YDbSerializable);
begin
  inherited InjectObjectData(cEntry);
  YDbPlayerEntry(cEntry).AccountName := Account;
  YDbPlayerEntry(cEntry).CharName := fCharacterName;
  fGuildManager.InjectObjectData(cEntry);
  fExpManager.InjectObjectData(cEntry);
  fTutManager.InjectObjectData(cEntry);
  fEquipManager.InjectObjectData(cEntry);
  fSkillManager.InjectObjectData(cEntry);
  fChatManager.InjectObjectData(cEntry);
  fActBtnsManager.InjectObjectData(cEntry);
  fHonorManager.InjectObjectData(cEntry);
  fQuestManager.InjectObjectData(cEntry);
  fGMManager.InjectObjectData(cEntry);
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
  fGuildManager.Free;
  fExpManager.Free;
  fTutManager.Free;
  fEquipManager.Free;
  fSkillManager.Free;
  fChatManager.Free;
  fActBtnsManager.Free;
  fHonorManager.Free;
  fTradeManager.Free;
  fQuestManager.Free;
  fGMManager.Free;
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

  fGuildManager := YGaGuildMgr.Create(Self);
  fExpManager := YGaExperienceMgr.Create(Self);
  fTutManager := YGaTutorialMgr.Create(Self);
  fEquipManager := YGaEquipMgr.Create(Self);
  fHonorManager := YGaHonorMgr.Create(Self);
  fSkillManager := YGaSkillMgr.Create(Self);
  fChatManager := YGaChatMgr.Create(Self);
  fQuestManager := YGaQuestMgr.Create(Self);
  fGMManager := YGaGMMgr.Create(Self);
  fActBtnsManager := YGaActionMgr.Create(Self);

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
  fEquipManager.AddToWorld;
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
procedure YGaPlayer.AddMovementData(cPkt: YNwServerPacket; bSelf: Boolean);
var
  lwExtraFlags: UInt32;
  lwFlags: UInt8;
begin

  /// Assigning correct flags and extra flags depending on update type.
  if bSelf then
  begin
    lwFlags := $1 or $10 or $20 or $40;
    lwExtraFlags := $2000;
  end else
  begin
    lwFlags := $10 or $20 or $40;
    lwExtraFlags := 0;
  end;

  /// Adding flags, extraflags, current time
  cPkt.AddUInt8(lwFlags);
  cPkt.AddUInt32(lwExtraFlags);
  cPkt.AddUInt32(TimeGetTime);

  /// Adding Position vector (X, Y, Z, Orientation)
  cPkt.AddFloat(Position.X);
  cPkt.AddFloat(Position.Y);
  cPkt.AddFloat(Position.Z);
  cPkt.AddFloat(Position.Angle);
  /// Adds an empty uint32 value (unknown usage ATM)
  cPkt.JumpUInt32;

  /// If updating self, adding some constant data (float)
  if bSelf then
  begin
    cPkt.AddFloat(0);
    cPkt.AddFloat(1);
    cPkt.AddFloat(0);
    cPkt.AddFloat(0);
  end;

  /// Adding Speed data (walk, run, backwalk, backswim, swim, etc)
  cPkt.AddFloat(Position.WalkSpeed);
  cPkt.AddFloat(Position.RunSpeed);
  cPkt.AddFloat(Position.BackSwimSpeed);
  cPkt.AddFloat(Position.SwimSpeed);
  cPkt.AddFloat(Position.BackWalkSpeed);
  {$IFDEF WOW_TBC}
  cPkt.AddFloat(Position.FlySpeed);     //2.0.6
  cPkt.AddFloat(Position.BackFlySpeed); //2.0.6
  {$ENDIF}
  cPkt.AddFloat(Position.TurnRate);
  /// Adds an empty uint32 value (unknown usage ATM)
  cPkt.JumpUInt32;
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



                         {==================}
                         { YPlayerComponent }
                         {==================}


{*------------------------------------------------------------------------------
  Constructor which only applies the owner

  @param cOwner Component owner
  @see YGaPlayer
-------------------------------------------------------------------------------}

constructor YGaPlayerComponent.Create(cOwner: YGaPlayer);
begin
  fOwner := cOwner;
end;

{*------------------------------------------------------------------------------
  Wrapper to player's SendPacket method (which is the owner of course)

  @param cPkt the packet which will be sent
  @see YGaPlayer
  @see YNwServerPacket
-------------------------------------------------------------------------------}
procedure YGaPlayerComponent.SendPacket(cPkt: YNwServerPacket);
begin
  Owner.Session.SendPacket(cPkt);
end;


                             {===============}
                             { YEquipmentMgr }
                             {===============}



{*------------------------------------------------------------------------------
  Creates a new item based on an item template.
  Based on given iEntry, the item is loaded from item templates database,
    it will be configured after some rulles and then returned as result.
  ==============================================================================

  @param iEntry The entry of the item that needs to be loaded from item templates
  @param cOwner The owner of the item that will be created
  @param cContained The class that will add it to world, prepare the updates, etc
  @return Returns the items created
  @see YGaItem
  @see YGaPlayer
  @see YGaContainer
  @see YDbItemTemplate
-------------------------------------------------------------------------------}
function CreateNewItem(iEntry: UInt32; cOwner: YGaPlayer; cContained: YGaContainer): YGaItem;
var
  cTemp: YDbItemTemplate;
begin
  /// loading item from database
  DataCore.ItemTemplates.LoadEntry(iEntry, cTemp);

  /// if we were successfull in loading this item from database then
  if cTemp <> nil then
  begin
    /// if the item's InventoryType is "Bag"
    if cTemp.InventoryType = iitBag then
    begin
      ///  then it will be created as "container"
      Result := YGaItem(GameCore.CreateObject(otContainer));
    end else
    begin
      ///  otherwise it will be created as simple item
      Result := YGaItem(GameCore.CreateObject(otItem));
    end;
    // freeing temporary used cTemp item template
    DataCore.ItemTemplates.ReleaseEntry(cTemp);
  end else
  begin
    /// in the case we were not successfull in loading the item template
    /// we'll free the temporary used cTemp item template and
    /// we'll return NIL as result (no item created) and exit this method.
    DataCore.ItemTemplates.ReleaseEntry(cTemp);
    Result := nil;
    Exit;
  end;

  /// if we got here it means everything went ok and now
  /// we'll create the item, assing it's entry ID and owner
  Result.CreateFromTemplate(iEntry);
  Result.Entry := iEntry;
  if cOwner <> nil then
  begin
    Result.Owner := cOwner;
  end;
  if cContained <> nil then
  begin
    /// and in the case that there is a container provided, we'll assing it
    Result.Contained := cContained;
  end;
  /// done!
end;

const
  /// Slots offsets Table (used for coversions from a slot to another)
  SlotOffsetTable: array[YSlotConversionType] of UInt8 = (
    EQUIPMENT_SLOT_START,
    INVENTORY_SLOT_BAG_START,
    INVENTORY_SLOT_ITEM_START,
    BANK_SLOT_ITEM_START,
    BANK_SLOT_BAG_START,
    BUYBACK_SLOT_START,
    KEYRING_SLOT_START
  );

{*------------------------------------------------------------------------------
  Converts an absolute slot to a relative one

  @param iAbsSlot The absolute slot
  @param iConvType The conversion Type
  @return A relative slot
  @see YSlotConversionType
-------------------------------------------------------------------------------}
function ConvertAbsoluteSlotToRelative(iAbsSlot: UInt8; iConvType: YSlotConversionType): UInt8;
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
function ConvertRelativeSlotToAbsolute(iRelSlot: UInt8; iConvType: YSlotConversionType): UInt8;
begin
  Assert(iConvType <= High(YSlotConversionType));
  Result := iRelSlot + SlotOffsetTable[iConvType];
end;

{*------------------------------------------------------------------------------
  Equipment Manager Destructor
  Freeing used resources.
-------------------------------------------------------------------------------}
destructor YGaEquipMgr.Destroy;
var
  iX: Int32;
begin
  for iX := ITEMS_START to ITEMS_END do
  begin
    fItems.Items[iX].Free;
  end;
  inherited Destroy;
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
function YGaEquipMgr.CanPlayerWearItem(iSlot: UInt8; iEntry: UInt32): UInt8;
var
  cTemp: YDbItemTemplate;
  cPlayer: YGaPlayer;
label
  __Exit;
begin
  cPlayer := YGaPlayer(fOwner);

  DataCore.ItemTemplates.LoadEntry(iEntry, cTemp);

  /// checking if the item was found in database
  if cTemp = nil then
  begin
    Result := INV_ERR_ITEM_NOT_FOUND;
    goto __Exit;
  end;

  /// checking if the items can be swapped
  if not (YEquipmentSlot(iSlot) in cPlayer.Equip.InventoryTypeToPossibleSlots(cTemp.InventoryType)) then
  begin
    Result := INV_ERR_ITEMS_CANT_BE_SWAPPED;
    goto __Exit;
  end;

  /// RACE CHECKS
  if (cTemp.AllowedRaces <> []) and not (cPlayer.Stats.Race in cTemp.AllowedRaces) then
  begin
    Result := INV_ERR_YOU_CAN_NEVER_USE_THAT_ITEM;
    goto __Exit;
  end;

  /// CLASS CHECKS
  if (cTemp.AllowedClasses <> []) and not (cPlayer.Stats.&Class in cTemp.AllowedClasses) then
  begin
    Result := INV_ERR_YOU_CAN_NEVER_USE_THAT_ITEM;
    goto __Exit;
  end;

  /// LEVEL CHECKS
  if (cPlayer.Stats.Level < cTemp.ReqLevel) and
     (cPlayer.Stats.Level <> 0) then
  begin
    Result := INV_ERR_YOU_MUST_REACH_LEVEL_N;
    goto __Exit;
  end;

  /// SKILL CHECKS
  if (not (cPlayer.Skills.GetSkillCount <> 0)) and not cPlayer.Skills.HasSkill(cTemp.ReqSkill) then
  begin
    Result := INV_ERR_NO_REQUIRED_PROFICIENCY;
    goto __Exit;
  end;

  /// SKILL RANK CHECKS
  if (not (cPlayer.Skills.GetSkillCount <> 0)) and cPlayer.Skills.HasSkill(cTemp.ReqSkill) and
     (cPlayer.Skills.SkillCurrent[cTemp.ReqSkill] < cTemp.ReqSkillRank) then
  begin
    Result := INV_ERR_SKILL_ISNT_HIGH_ENOUGH;
    goto __Exit;
  end;

  /// PVP RANK 1 CHECKS
  if cPlayer.Honor.PVPRank < cTemp.ReqPVPRank1 then
  begin
    Result := INV_ITEM_RANK_NOT_ENOUGH;
    goto __Exit;
  end;

  /// PVP RANK 2 CHECKS
  if cPlayer.Honor.PVPRank < cTemp.ReqPVPRank2 then
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
  Deletes items used!

  @see DeleteItem
-------------------------------------------------------------------------------}
procedure YGaEquipMgr.CleanupObjectData;
var
  iX: Int32;
begin
  for iX := ITEMS_START to ITEMS_END do
  begin
    DeleteItem(BAG_NULL, iX, True);
  end;
end;


{*------------------------------------------------------------------------------
  Loads all items from database for given player

  @param cEntry Player entry
  @see YGaItem
  @see YDbPlayerEntry
  @see YDbItemEntry
  @see YDbItemTemplate
-------------------------------------------------------------------------------}
procedure YGaEquipMgr.ExtractObjectData(cEntry: YDbSerializable);
var
  cItem: YGaItem;
  iX: Int32;
  cPlr: YDbPlayerEntry;
  cItm: YDbItemEntry;
  cItmTem: YDbItemTemplate;
begin

  /// Loads the player
  cPlr := YDbPlayerEntry(cEntry);

  /// Loading all component items
  for iX := ITEMS_START to ITEMS_END do
  begin
    if cPlr.EquippedItems[iX] <> 0 then
    begin
      DataCore.Items.LoadEntry(cPlr.EquippedItems[iX], cItm);
      if cItm <> nil then
      begin
        DataCore.ItemTemplates.LoadEntry(cItm.Entry, cItmTem);
        if cItmTem.InventoryType = iitBag then
        begin
          cItem := YGaItem(GameCore.CreateObject(otContainer, True));
        end else
        begin
          cItem := YGaItem(GameCore.CreateObject(otItem, True));
        end;
        DataCore.ItemTemplates.ReleaseEntry(cItmTem);

        /// For each item, assigning GUIDs, applying owner, preparing updates, etc
        cItem.GUIDLo := cPlr.EquippedItems[iX];
        cItem.Owner := fOwner;
        cItem.LoadFromDataBase;
        fItems.Items[iX] := cItem;
        PrepareUpdatesForTheItemOnSlot(iX);
        DataCore.Items.ReleaseEntry(cItm);
      end else fItems.Items[iX] := nil;
    end;
  end;
end;

{*------------------------------------------------------------------------------
  Saves all items a player has in database

  @param cEntry Player entry
  @see YDbPlayerEntry
-------------------------------------------------------------------------------}
procedure YGaEquipMgr.InjectObjectData(cEntry: YDbSerializable);
var
  iX: Int32;
  cPlr: YDbPlayerEntry;
begin
  cPlr := YDbPlayerEntry(cEntry);
  cPlr.SetEquippedItemsLength(Length(fItems.Items));
  for iX := ITEMS_START to ITEMS_END do
  begin
    if Assigned(fItems.Items[iX]) then
    begin
      cPlr.EquippedItems[iX] := fItems.Items[iX].GUIDLo;
      fItems.Items[iX].SaveToDataBase;
    end else cPlr.EquippedItems[iX] := 0;
  end;
end;


{*------------------------------------------------------------------------------
  Finds a free slot in a backpack

  @return The ID of the free slot found or SLOT_NULL if no slots are available
-------------------------------------------------------------------------------}
function YGaEquipMgr.FindFreeBackpackSlot: UInt8;
begin
  for Result := 0 to High(fItems.Backpack) do
  begin
    if fItems.Backpack[Result] = nil then Exit;
  end;
  
  Result := SLOT_NULL;
end;


{*------------------------------------------------------------------------------
  Finds a free bag

  @return The ID of the free bag found or BAG_NULL if no bags are available
-------------------------------------------------------------------------------}
function YGaEquipMgr.FindFreeBag: UInt8;
var
  iX: UInt8;
begin
  for iX := 0 to High(fItems.Bags) do
  begin
    if Assigned(fItems.Bags[iX]) and (fItems.Bags[iX].NumOfFreeSlots <> 0) then
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
function YGaEquipMgr.GetBackpackItem(iSlot: UInt32): YGaItem;
begin
  Result := fItems.Backpack[iSlot];
end;


{*------------------------------------------------------------------------------
  Provides the bag that is supposed to be on a given Slot number

  @return The Bag located on given Slot number.
  @see YGaContainer
-------------------------------------------------------------------------------}
function YGaEquipMgr.GetBag(iSlot: UInt32): YGaContainer;
begin
  Result := fItems.Bags[iSlot];
end;


{*------------------------------------------------------------------------------
  Provides the Bank Bag that is supposed to be on a given Slot number

  @return The Bank Bag located on given Slot number.
  @see YGaContainer
-------------------------------------------------------------------------------}
function YGaEquipMgr.GetBankBag(iSlot: UInt32): YGaContainer;
begin
  Result := fItems.BankBags[iSlot];
end;

{*------------------------------------------------------------------------------
  Provides the item that is supposed to be on a given Slot number in Bank

  @return The Item located on given Slot number in Bank.
-------------------------------------------------------------------------------}
function YGaEquipMgr.GetBankItem(iSlot: UInt32): YGaItem;
begin
  Result := fItems.Bank[iSlot];
end;


{*------------------------------------------------------------------------------
  Provides the item that is supposed to be on a given Slot number in BuyBack array

  @return The Item located on given Slot number in BuyBack array.
-------------------------------------------------------------------------------}
function YGaEquipMgr.GetBuybackItem(iSlot: UInt32): YGaItem;
begin
  Result := fItems.Buyback[iSlot];
end;

{*------------------------------------------------------------------------------
  Gets an Equiped Item for given slot ID

  @return The Item located on given Slot ID.
-------------------------------------------------------------------------------}
function YGaEquipMgr.GetEquipedItem(iSlot: UInt32): YGaItem;
begin
  Result := fItems.EquippedItems[iSlot];
end;


{*------------------------------------------------------------------------------
  Gets a Keyring Item for given slot ID

  @return The Item located on given Slot ID.
-------------------------------------------------------------------------------}
function YGaEquipMgr.GetKeyringItem(iSlot: UInt32): YGaItem;
begin
  Result := fItems.Keyring[iSlot];
end;


{*------------------------------------------------------------------------------
  Reads character's money

  @return Character's money
-------------------------------------------------------------------------------}
function YGaEquipMgr.GetMoney: UInt32;
begin
  Result := Owner.GetUInt32(PLAYER_FIELD_COINAGE);
end;


{*------------------------------------------------------------------------------
  Finds out if the character has a given number of free slots

  @return True if it has enough free slots, false otherwise
-------------------------------------------------------------------------------}
function YGaEquipMgr.HasEnoughFreeSlots(iCount: Int32): Boolean;
var
  iX: Int32;
begin
  Result := True;
  if iCount = 0 then
    Exit;
  for iX := 0 to High(fItems.Backpack) do
  begin
    if fItems.Backpack[iX] = nil then
    begin
      Dec(iCount);
      if iCount <= 0 then
        Exit;
    end;
  end;
  for iX := 0 to High(fItems.Bags) do
  begin
    if Assigned(fItems.Bags[iX]) then
    begin
      Dec(iCount, fItems.Bags[iX].NumOfFreeSlots);
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
procedure YGaEquipMgr.InsertItem(iSlot: UInt32; iId: UInt32; iAmount: UInt32 = 1;
  bOverrideChecks: Boolean = False);
var
  cItem: YGaItem;
  iError: UInt8;
begin
  Assert(iSlot <= ITEMS_END, 'An invalid EQUIP slot "' + itoa(iSlot) + '" has been provided. Please contact developers about this bug.');

  /// Checking if the item can be weared by player
  if iSlot <= EQUIPMENT_SLOT_END then
  begin
    if not bOverrideChecks then iError := CanPlayerWearItem(iSlot, iId) else iError := INV_ERR_OK;
  end else iError := INV_ERR_OK;


  /// If the item can be weared
  if iError = INV_ERR_OK then
  begin
    /// then if there are no items assigned on that slot
    if not Assigned(fItems.Items[iSlot]) then
    begin
      /// then creating and assigning new one
      fTempItem.iSlot := iSlot;
      fTempItem.fItem := nil;
      cItem := CreateNewItem(iId, fOwner, nil);
      cItem.StackCount := iAmount;
    end else
    begin
      /// otherwise just assing the new one
      fTempItem.iSlot := iSlot;
      fTempItem.fItem := fItems.Items[iSlot];
      cItem := fItems.Items[iSlot];
    end;
    fItems.Items[iSlot] := cItem;

    /// if the player is not in world, we'll prepare the updates for that item
    if not YGaPlayer(fOwner).InWorld then
      /// and we'll alter player's stats depending on the item's options
      PrepareUpdatesForTheItemOnSlot(iSlot, True)
    else
      /// otherwise we'll just prepare updates for that item
      PrepareUpdatesForTheItemOnSlot(iSlot);

    /// Setting item's world state to wscAdd (needs to be added to world)
    fItems.Items[iSlot].ChangeWorldState(wscAdd);
  end else
  begin
    /// in the case that the item cannot be weared, we'll generate an Inventory
    /// Change Error, with the error returned by CanPlayerWearItem
    GenerateInventoryChangeError(cItem, nil, iError);
  end;
end;


{*------------------------------------------------------------------------------
  Internal swapping of the items on 2 given slots

  @param iSlot1 First given slot
  @param iSlot2 Second given slot
  @see YGaItem
-------------------------------------------------------------------------------}
procedure YGaEquipMgr.InternalSwap(iSlot1, iSlot2: UInt8);
var
  cTemp: YGaItem;
begin
  /// a temporary item receive's the item data from first slot
  cTemp := fItems.Items[iSlot2];
  fItems.Items[iSlot2] := fItems.Items[iSlot1];
  fItems.Items[iSlot1] := cTemp;

  /// First slot receives now the item from second slot
  {fTempItem.iSlot := iSlot1;
  fTempItem.fItem := fItems.Items[iSlot2];  }
  /// >> preparing the updates for it
  PrepareUpdatesForTheItemOnSlot(iSlot1);

  /// Second slot receives the temporary created item
  {fTempItem.iSlot := iSlot2;
  fTempItem.fItem := fItems.Items[iSlot1]; }
  /// >> preparing the updates for it
  PrepareUpdatesForTheItemOnSlot(iSlot2);
end;


{*------------------------------------------------------------------------------
  Internal swapping of the items on 2 given slots and 2 bags

  @param iSlot1 First given slot
  @param iSlot2 Second given slot
  @param iBag1 First given bag
  @param iBag2 Second given bag
  @see YGaItem
-------------------------------------------------------------------------------}
procedure YGaEquipMgr.InternalSwap(iSlot1, iSlot2, iBag1, iBag2: UInt8);
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
      cTemp := fItems.Containers[iBag2].Items[iSlot2];
      fItems.Containers[iBag2].Items[iSlot2] := fItems.Containers[iBag1].Items[iSlot1];
      fItems.Containers[iBag1].Items[iSlot1] := cTemp;
    end;
    SWP_B2I:
    begin
      /// 2. Bag-to-Inventory swap
      cTemp := fItems.Items[iSlot2];
      fItems.Items[iSlot2] := fItems.Containers[iBag1].Items[iSlot1];
      fItems.Containers[iBag1].Items[iSlot1] := cTemp;
      //fItems.Containers[iBag1].
      //PrepareUpdatesForTheItemOnSlot(iSlot1);
      PrepareUpdatesForTheItemOnSlot(iSlot2);
    end;
    SWP_I2B:
    begin
      /// 3. Inventory-to-bag swap
      cTemp := fItems.Containers[iBag2].Items[iSlot2];
      fItems.Containers[iBag2].Items[iSlot2] := fItems.Items[iSlot1];
      fItems.Items[iSlot1] := cTemp;
      PrepareUpdatesForTheItemOnSlot(iSlot1);
      //PrepareUpdatesForTheItemOnSlot(iSlot2);
    end;
    SWP_I2I:
    begin
      /// 4. Inventory-to-Inventory swap
      InternalSwap(iSlot1, iSlot2);
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
function YGaEquipMgr.DeleteItem(iBag, iSlot: UInt8; bDestroy: Boolean): YGaItem;
begin
  if iBag = BAG_NULL then
  begin
    /// if there is an item assigned to that given slot number
    if Assigned(fItems.Items[iSlot]) then
    begin
      /// assigning fTempItem the slot and the item on that slot
      fTempItem.iSlot := iSlot;
      fTempItem.fItem := fItems.Items[iSlot];

      /// if bDestroy
      if bDestroy then
      begin
        /// then we remove the item form world, delete it from database and
        /// also destroy it, adding as Result a NIL value
        fItems.Items[iSlot].ChangeWorldState(wscRemove);
        fItems.Items[iSlot].DeleteFromDataBase;
        fItems.Items[iSlot].Destroy;
        Result := nil;
      end else
      begin
        /// otherwise we provide as result the item that was on that slot
        Result := fItems.Items[iSlot];
      end;

      /// now assigning to that slot a NIL value (no item present there now)
      fItems.Items[iSlot] := nil;
      /// and we prepare updates for that slot
      PrepareUpdatesForTheItemOnSlot(iSlot);
    /// If there is no item assigned to that slot, we ad NIL as Result
    end else Result := nil;

  /// if iBag is not BAG_NULL, we'll call RemoveItem from Containers
  end else
  begin
    Result := fItems.Containers[iBag].RemoveItem(iSlot, bDestroy);
  end;
end;


{*------------------------------------------------------------------------------
  This method prepares the updates for the item on given slot

  @param iSlot
  @param bForceAlteringStats
  @todo Add the rest of the update fields about enchantments and random properties
-------------------------------------------------------------------------------}
procedure YGaEquipMgr.PrepareUpdatesForTheItemOnSlot(iSlot: UInt32;  bForceAlteringStats : Boolean);
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

  cTemp := fItems.Items[iSlot];

  /// If there is an item on that slot, we'll add visibility for it!
  if cTemp <> nil then
  begin
    /// Adding Item's GUID in proper slot ID in update fields
    Owner.SetUInt64(PLAYER_FIELD_INV_SLOT_HEAD + iSlot * 2, cTemp.GUID^.Full);
    if (iSlot <= EQUIPMENT_SLOT_END) then
    begin
     /// If the player is in world (not in charlist) or we want to force
     ///  altering it's stats we'll call the method that handles stats changes
     if (YGaPlayer(fOwner).InWorld) or (bForceAlteringStats) then
       begin
        // if (fTempItem.iSlot = iSlot) and (fTempItem.fItem <> nil) then
        //   Owner.Stats.AddItemStats(fTempItem.fItem, false) else
        // Owner.Stats.AddItemStats(fItems.Items[iSlot]);
       end;

      /// Setting some more update fields for visibility! 
      Owner.SetUInt64(PLAYER_VISIBLE_ITEM_1_CREATOR + iUpdateBase, __ITEM_CREATOR);
      Owner.SetUInt32(PLAYER_VISIBLE_ITEM_1_0 + iUpdateBase, cTemp.Entry);


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
    Owner.SetUInt64(PLAYER_FIELD_INV_SLOT_HEAD + iSlot * 2, __ITEM_GUID);

    
    if iSlot <= EQUIPMENT_SLOT_END then
    begin
     /// If the player is in world (not in charlist) it's obvious that there was
     /// an item on this slot and that on deletion we have to renew player's stats
     /// as the item is deleted, and all stats that were altered by this item
     /// have to be reconfigured!
      if YGaPlayer(fOwner).InWorld then
        begin
          //if (fTempItem.iSlot = iSlot) and (fTempItem.fItem <> nil) then
          //   fOwner.Stats.AddItemStats(fTempItem.fItem, false);
        end;

       /// removing visibility of the previously equiped item!
       Owner.SetUInt64(PLAYER_VISIBLE_ITEM_1_CREATOR + iUpdateBase, __ITEM_CREATOR);
       Owner.SetUInt32(PLAYER_VISIBLE_ITEM_1_0 + iUpdateBase, __ITEM_ENTRY_ID);
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
function YGaEquipMgr.AddItemToBag(iBag: UInt8; iItem, iAmount: UInt32; bNormal: Boolean): UInt8;
var
  cItem: YGaItem;
  cBag: YGaContainer;
  iSlot: UInt8;
begin
  /// If there's no specific bag given
  if iBag = BAG_NULL then
  begin
    /// then we'll search for a free one
    iSlot := FindFreeBackpackSlot;
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
    cBag := fItems.Containers[iBag];
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
  cItem := CreateNewItem(iItem, fOwner, cBag);

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
    fItems.Containers[iBag].Items[iSlot] := cItem;
    /// and we'll adjust iBag ID
    iBag := iBag + INVENTORY_SLOT_BAG_START;
  end else
  begin
    /// otherwise we'll just add the item to inventory and
    fItems.Items[iSlot] := cItem;
    /// we'll prepare the updates for it
    PrepareUpdatesForTheItemOnSlot(iSlot);
  end;

  /// Last thing... we'll send an Item Received Message
  SendItemReceiveMessage(bNormal, False, bNormal, 0{Magic?}, iItem, iAmount, iBag);
end;


{*------------------------------------------------------------------------------
  Procedure that prepares all items a player has to be added into world
  Used when a player enteres the world.

  @see YGaPlayer
  @see EnterWorld
  @see YGaPlayer.EnterWorld
-------------------------------------------------------------------------------}
procedure YGaEquipMgr.AddToWorld;
var
  iIdx: Int32;
begin
  /// Iterating all items
  for iIdx := ITEMS_START to ITEMS_END do
  begin
    /// if there's an items assinged in the speciffic slot
    if Assigned(fItems.Items[iIdx]) then
    begin
      /// then we'll change it's tate to wscAdd (to be added to World)
      fItems.Items[iIdx].ChangeWorldState(wscAdd);
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
function YGaEquipMgr.AssignItem(cItem: YGaItem): UInt32;
var
  cBag: YGaContainer;
  iBag, iSlot: UInt8;
begin
  iBag := BAG_NULL;

  /// Finding a free slot and assigning it to iSlot
  iSlot := FindFreeBackpackSlot;

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
  fItems.Items[iSlot] := cItem;
  /// and preparing the updates for it
  PrepareUpdatesForTheItemOnSlot(iSlot);

  /// Last thing... we'll send an Item Received Message
  SendItemReceiveMessage(True, False, True, 0{Magic?}, cItem.Entry, cItem.StackCount, iBag);
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
procedure YGaEquipMgr.AutoStoreItem(iBagSrc, iSlotSrc, iBagDest: UInt8);
var
  cItem: YGaItem;
  iSlotDest: UInt8;
begin
  /// If iBagDest is BAG_NULL then we'll auto-store the item in inventory
  if iBagDest = BAG_NULL then
  begin
    /// and we'll find a free slot using ConvertRelativeSlotToAbsolute method
    iSlotDest := ConvertRelativeSlotToAbsolute(FindFreeBackpackSlot, sctBackpack);
  end else
  begin
    /// Otherwise we'll find a free slot in the given BAG
    iSlotDest := Bags[ConvertAbsoluteSlotToRelative(iBagDest, sctBags)].FindFreeSlot;
  end;

  if iSlotDest = SLOT_NULL then
  begin
    if iBagSrc = BAG_NULL then
    begin
      /// If we found no free SLOT and source BAG is NULL (the item is actually
      ///  in backpack (inventory))
      cItem := BackpackItems[ConvertAbsoluteSlotToRelative(iSlotSrc, sctBackpack)];
    end else
    begin
      cItem := Bags[ConvertAbsoluteSlotToRelative(iBagSrc, sctBags)].Items[iSlotSrc];
    end;

    /// If destination SLOT and BAG are NULL
    if iBagDest = BAG_NULL then
    begin
      /// then we'll generate INVENTORY_FULL error!
      GenerateInventoryChangeError(cItem, nil, INV_ERR_INVENTORY_FULL);
    end else
    begin
      /// If destination SLOT is NULL but the BAG is not NULL
      /// then we'll send a BAG_NULL error!
      GenerateInventoryChangeError(cItem, nil, INV_ERR_BAG_FULL);
    end;
  end else
  begin
    /// If we found a free SLOT then we'll proceed with changing the
    /// inventory change!
    InventoryChange(iSlotSrc, iSlotDest, iBagSrc, iBagDest);
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
function YGaEquipMgr.AddItem(iItem, iAmount: UInt32; bNormal: Boolean): UInt8;
var
  cItem: YGaItem;
  cBag: YGaContainer;
  iBag, iSlot: UInt8;
begin
  /// First finding a free slot in backpack
  iSlot := FindFreeBackpackSlot;

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
    iBag := FindFreeBag;

    if iBag = BAG_NULL then
    begin
      /// If we found no free bags
      ///  then we'll send INVENTORY_FULL error and exit!
      Result := INV_ERR_INVENTORY_FULL;
      SendInventoryError(Result);
      Exit;
    end;

    /// If we're here than we found a free bag and now we'll look for a free slot
    cBag := fItems.Bags[iBag];
    iSlot := cBag.FindFreeSlot;

    if iSlot = SLOT_NULL then
    begin
      /// If we were not able to find a free bag slot,
      ///  then we'll send BAG_FULL error and exit!
      Result := INV_ERR_BAG_FULL;
      SendInventoryError(Result);
      Exit;
    end;
  end;


  /// Everything went ok though... creating a new item now
  cItem := CreateNewItem(iItem, fOwner, cBag);

  if not Assigned(cItem) or not Assigned(cItem.Template) then
  begin
    /// If we were not able to find the item in database we'll send
    ///  an apropriate error (ITEM_NOT_FOUND) and exit!
    Result := INV_ERR_ITEM_NOT_FOUND;
    SendInventoryError(Result);
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
    fItems.Bags[iBag].AddItem(cItem, iSlot);
  end else
  begin
    /// otherwise we'll add the item to backpack and
    fItems.Items[iSlot] := cItem;
    /// we'll prepare the updates for it!
    PrepareUpdatesForTheItemOnSlot(iSlot);
  end;

  /// Trying now to update delivery status for quests
  Owner.Quests.UpdateDeliver(iItem, iAmount);

  if iBag <> BAG_NULL then iBag := iBag + INVENTORY_SLOT_BAG_START;

  /// Last thing... we'll send an Item Received Message
  SendItemReceiveMessage(bNormal, False, bNormal, 0, iItem, iAmount, iBag);
end;


{*------------------------------------------------------------------------------
  Converts Inventory Type to slot ID

  @param iInventoryType the inventory Type
  @return Slot's ID
  @see YItemInventoryType
-------------------------------------------------------------------------------}
function YGaEquipMgr.InventoryTypeToSlot(iInventoryType: YItemInventoryType): UInt8;
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
      while fItems.Items[Result] <> nil do
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
function YGaEquipMgr.InventoryTypeToPossibleSlots(iInventoryType: YItemInventoryType): YEquipmentSlots;
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
      while fItems.Items[Result] <> nil do
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
procedure YGaEquipMgr.SendInventoryError(iError: UInt8);
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
procedure YGaEquipMgr.SendItemReceiveMessage(bReward, bCreated, bHideMessage: Boolean;
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
      AddPtrData(fOwner.GUID, 8);
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
procedure YGaEquipMgr.SetMoney(iMoney: UInt32);
begin
  Owner.SetUInt32(PLAYER_FIELD_COINAGE, iMoney);
end;


{*------------------------------------------------------------------------------
  Merging Stacks between 2 slots

  @param iSrc Source slot
  @param iDest Destination slot
  @return STACK_MERGE_OK, STACK_MERGE_DIFFERES or STACK_MERGE_MAX_COUNT_IS_1
  @see YGaItem
-------------------------------------------------------------------------------}
function YGaEquipMgr.MergeStacks(iSrc, iDest: UInt8): Int32;
const
 STACK_MERGE_OK = 0;
 STACK_CANT_STACK = 1;
 STACK_SWAP = 2;
var
  cSrc, cDest: YGaItem;
  iMax: UInt32;
  iTmp, iTmp2: UInt32;
begin
  cSrc := fItems.Items[iSrc];
  cDest := fItems.Items[iDest];
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
        DeleteItem(BAG_NULL, iSrc, True);
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
procedure YGaEquipMgr.SplitItems(iBagSrc, iSlotSrc, iBagDest, iSlotDest: UInt8; iCount: UInt32);
var
  cItemSrc, cItemDest: YGaItem;
begin
  /// If iBagSrc is BAG_NULL 
  if iBagSrc = BAG_NULL then     
  begin
    /// then we'll read the item from backpack
    cItemSrc := fItems.Items[iSlotSrc];
  end else
  begin
    /// otherwise we'll read the item from source bag 
    cItemSrc := fItems.Containers[iBagSrc].Items[iSlotSrc];
  end;

  /// setting source item's stack count to the new value calculated
  cItemSrc.StackCount := cItemSrc.StackCount - iCount;

  /// If ibagDest is BAG_NULL
  if iBagDest = BAG_NULL then
  begin
    /// then we'll create new item in backpack
    cItemDest := CreateNewItem(cItemSrc.Entry, fOwner, nil);
  end else
  begin
    /// otherwise we'll create new item in destination bag
    cItemDest := CreateNewItem(cItemSrc.Entry, fOwner, fItems.Containers[iBagDest]);
  end;

  /// setting destination item's StackCount to iCount value
  cItemDest.StackCount := iCount;
  /// changing it's world state to wscAdd (to be added to world)
  cItemDest.ChangeWorldState(wscAdd);

  /// Updating items (source and destination) to the new values
  fItems.Items[iSlotSrc] := cItemSrc;
  fItems.Items[iSlotDest] := cItemDest;

  /// Preparing the updates for them!
  PrepareUpdatesForTheItemOnSlot(iSlotSrc);
  PrepareUpdatesForTheItemOnSlot(iSlotDest);
end;


{*------------------------------------------------------------------------------
  Counting how many iItems we have in our Inventory!
   (searching in backpack, and bags)

  @param iItem The Item's ID
  @return The number of items we posses
-------------------------------------------------------------------------------}
function YGaEquipMgr.ThisItemCount(iItem: UInt32): Int32;
var
  iX, iY: Int32;
begin
  Result := 0;
  for iX := 0 to High(fItems.BackPack) do
    if Assigned(fItems.BackPack[iX]) and (fItems.Backpack[iX].Entry = iItem) then
      Inc(Result, fItems.Backpack[iX].StackCount);
      
  for iX := 0 to High(fItems.Bags) do
  begin
    if Assigned(fItems.Bags[iX]) then
      for iY := 0 to fItems.Bags[iX].Template.ContainerSlots do
        if Assigned(fItems.Bags[iX].Items[iY]) and (fItems.Bags[iX].Items[iY].Entry = iItem) then
          Inc(Result, fItems.Bags[iX].Items[iY].StackCount);
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
procedure YGaEquipMgr.TryEquipItem(iSlot, iBag: UInt8);
var
  cSrc: YGaItem;
  iDest: UInt8;
begin
  case iBag of
    /// If BAG provided is BAG_NULL than we're trying to equip from backpack directly
    BAG_NULL: cSrc := fItems.Items[iSlot];
  else
    /// otherwise from the given BAG
    cSrc := fItems.Containers[iBag].Items[iSlot];
  end;

  /// Finding what equipment slot we'll that item have to use 
  iDest := InventoryTypeToSlot(cSrc.Template.InventoryType);

  /// If destination slot is SLOT_NULL then that item cannot be equipped
  if iDest = SLOT_NULL then
  begin
    GenerateInventoryChangeError(cSrc, nil, INV_ERR_ITEM_CANT_BE_EQUIPPED);
    Exit;
  end;
  
  case iBag of
    /// If BAG_NULL then we'll equip from backpack
    BAG_NULL: InventoryChange(iSlot, iDest);
  else
    /// otherwise we'll equip from bag
    InventoryChange(iSlot, iDest, iBag, SLOT_NULL);
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
function YGaEquipMgr.InventoryChange(iSlot1, iSlot2: UInt8): Boolean;
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
  cDestItem := fItems.Items[iSlot2];

  /// If SLOT 1 is NULL or there are no items on Slot 1
  if (iSlot1 = SLOT_NULL) or (fItems.Items[iSlot1] = nil) then
  begin
    ///then we'll generate change error and exit!
    GenerateInventoryChangeError(nil, cDestItem, INV_ERR_SLOT_IS_EMPTY);
    Result := False;
    Exit;
  end;

  /// Reading item from Slot 1
  cSrcItem := fItems.Items[iSlot1];

  /// If the slots are the same
  if iSlot1 = iSlot2 then
  begin
    /// then there's no point. Generating error and exit!
    GenerateInventoryChangeError(cSrcItem, cDestItem, INV_ERR_ITEM_CANT_STACK);
    Result := False;
    Exit;
  end;


  /// If we're trying actually to equip the item in slot 2
  if (iSlot2 <= EQUIPMENT_SLOT_END) and (cSrcItem <> nil) then
  begin
    /// then we'll check if player can wear the item in that slot
    iError := CanPlayerWearItem(iSlot2, cSrcItem.Entry);
    if iError <> INV_ERR_OK then
    begin
      /// If the player cannot wear that item, generating
      ///  inventory change error and exit!
      __WearError:
      GenerateInventoryChangeError(cSrcItem, cDestItem, iError);
      Result := False;
      Exit;
    end;
  end;

  /// If we're trying actually to equip the item in slot 1
  if (iSlot1 <= EQUIPMENT_SLOT_END) and (cDestItem <> nil) then
  begin
    /// then we'll check if player can wear the item in that slot
    iError := CanPlayerWearItem(iSlot1, cDestItem.Entry);
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
       GenerateInventoryChangeError(cSrcItem, cDestItem,
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
    GenerateInventoryChangeError(cSrcItem, cDestItem, INV_ERR_NOT_A_BAG);
    Result := False;
    Exit;

  /// If both items are ordinary items of the same type  
  end else if (cDestItem <> nil) and (cSrcItem.Entry = cDestItem.Entry) then
  begin
    /// then we'll merge them together
    case MergeStacks(iSlot1, iSlot2) of
      0:
      begin
        { Successful merge }
        Result := True;
        Exit;
      end;
      1:
      begin
        { Can't stack }
        GenerateInventoryChangeError(cSrcItem, cDestItem, INV_ERR_ITEM_CANT_STACK);
        Result := False;
        Exit;
      end;
      2: { Nothing, swap };
    end;
  end;

  /// Checks are done...
  /// Calling Internal Swap for those 2 slots
  InternalSwap(iSlot1, iSlot2);
  /// Setting the result to TRUE (success)
  Result := True;
end;

function YGaEquipMgr.InventoryChange(iSlotSrc, iSlotDest, iBagSrc, iBagDest: UInt8): Boolean;
{var
  iError: UInt8;
  cSrcItem, cDestItem: YOpenItem;}
begin
  {TODO 4 -oBIGBOSS -cItems : Errors & Merge checking}
  InternalSwap(iSlotSrc, iSlotDest, iBagSrc, iBagDest);
  Result := True;
end;

procedure YGaEquipMgr.GenerateInventoryChangeError(cSrc, cDest: YGaItem;
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

{ YChatMgr }

procedure YGaChatMgr.CleanupObjectData;
begin
end;

procedure YGaChatMgr.ExtractObjectData(cEntry: YDbSerializable);
begin
end;

procedure YGaChatMgr.InjectObjectData(cEntry: YDbSerializable);
begin
end;

procedure YGaChatMgr.SystemMessage(const sMessage: string);
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

procedure YGaChatMgr.SystemMessageColored(const sMessage: string;
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

procedure YGaChatMgr.SystemMessageRaw(const pMessage: PChar; iLen: Int32);
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

procedure YGaChatMgr.SystemMessageRawColored(const pMessage: PChar; iLen: Int32;
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

procedure YGaChatMgr.DispatchMessageInRange(iType: UInt8; iLanguage: YGameLanguage;
  const sMessage, sChannel: string; const fRange: Float; bMeAlso: Boolean);
var
  cPkt: YNwServerPacket;
begin
  cPkt := BuildChatPacket(Owner, iType, iLanguage, @sMessage[1], Length(sMessage),
    sChannel);
  try
    Owner.SendPacketInRange(cPkt, fRange, bMeAlso, False);
  finally
    cPkt.Free;
  end;
end;

procedure YGaChatMgr.HandleChatMessage(cPkt: YNwClientPacket);
const
  Range: array[0..8] of Float = (12.5, 0, 0, 0, 0, 25.0, 0, 0, 25.0);
var
  iType, iLanguage: UInt32;
  iLen: Int32;
  sMessage: string;
  sChannel: string;
  cChannel: YGaChannel;
  sPlayerName: string;
  cPlayer: YGaPlayer;
  cOutPkt: YNwServerPacket;
begin
  iType := cPkt.ReadUInt32;
  iLanguage := cPkt.ReadUInt32;
  case iType of
    CHAT_MSG_SAY, CHAT_MSG_YELL:
    begin
      sMessage := cPkt.ReadString;
      iLen := Length(sMessage);

      if iLen > 1 then
      begin
        { The message must contain at least 2 chars to be considered a command }
        if ProcessChatCommand(sMessage) then
        begin
          Exit; { It was a command and it was processed }
        end;
      end;

      DispatchMessageInRange(iType, glUniversal, sMessage, '', Range[iType], True);
      //TODO change LANG_UNIVERSAL in iLanguage when the time comes as know the skills are not forking
      //for decoding the messages.
    end;
    CHAT_MSG_CHANNEL:
    begin
      sChannel := cPkt.ReadString;
      sMessage := cPkt.ReadString;
      cChannel := GameCore.GetChannelByName(Owner, sChannel);
      if cChannel <> nil then
      begin
        cChannel.Say(Owner, sMessage);
      end else SystemMessage('Channel "' + sChannel + '" does not exist.');
    end;
    CHAT_MSG_WHISPER:
    begin
      sPlayerName := cPkt.ReadString;
      if StringsEqualNoCase(sPlayerName, Owner.Name) then
      begin
        SystemMessage('You cannot whisper to yourself.');
      end else
      begin
        sMessage := cPkt.ReadString;
        case GameCore.FindPlayerByName(sPlayerName, cPlayer) of
          { A char with the specified name does not exist }
          lrNonExistant: SystemMessage('Player ' + sPlayerName + ' does not exist.');
          { The char exists, but he is not currently online }
          lrOffline: SystemMessage('Player ' + sPlayerName + ' is currently not online.');
          { The char is currently in the game so he may receive messages }
          lrOnline:
          begin
            iLen := Length(sMessage);
            
            cOutPkt := BuildChatPacket(Owner, CHAT_MSG_WHISPER, glUniversal,
              Pointer(sMessage), iLen);
            try
              cPlayer.SendPacket(cOutPkt);
            finally
              cOutPkt.Free;
            end;

            cOutPkt := BuildChatPacket(cPlayer, CHAT_MSG_WHISPER_INFORM, glUniversal,
              Pointer(sMessage), iLen);
            try
              SendPacket(cOutPkt);
            finally
              cOutPkt.Free;
            end;
          end;
        end;
      end;
    end;
    CHAT_MSG_EMOTE:
    begin
      sMessage := cPkt.ReadString;
      DispatchMessageInRange(iType, glUniversal, sMessage, '', Range[iType], True);
    end;
  end;
end;

function YGaChatMgr.ProcessChatCommand(var sCommand: string): Boolean;
const
  ReplyTable: array[YCommandCallResult] of string = (
    'Specified command does not exist.',
    'Invalid parameter count. Please read the manual.',
    'Invalid parameter type. Please read the manual.',
    'You are not allowed to use this command.',
    'This command has been disabled.',
    'Unspecified error occured. Command hasn''t been executed.',
    'The command you specified is a root command and it cannot work without a subcommand.',
    'Command has been executed.',
    ''
  );
var
  iResult: YCommandCallResult;
begin
  if sCommand[1] = '.' then
  begin
    iResult := GameCore.CommandHandler.CallCommandHandler(sCommand, nil, Self);
    SystemMessage(ReplyTable[iResult]);

    Result := True;
  end else Result := False;
end;

function YGaChatMgr.CommandAdd(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  iItem, iAmount: Int32;
begin
  iItem := cParams.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  if cParams.List.Count = 1 then
  begin
    iAmount := 1;
  end else
  begin
    iAmount := cParams.GetAsInteger(1, bSuccess);
    if not bSuccess then
    begin
      Result := ccrBadParamType;
      Exit;
    end;
  end;

  Owner.Equip.AddItem(iItem, IAmount, True);

  Result := ccrSupressMsg;
end;

function YGaChatMgr.CommandBroadcast(Sender: YGaCommandHandlerTable;
  const Args: string): YCommandCallResult;
begin
  Result := ccrSupressMsg;
end;

function YGaChatMgr.CommandCreateNode(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  pVect: PVector;
begin
  pVect := @Owner.Position.Vector;
  SystemMessage('Node created. ID: ' +
    itoa(GameCore.NodeManager.CreateNode(pVect^.X, pVect^.Y, pVect^.Z,
    Owner.Position.MapId).Id));
  Result := ccrSupressMsg;
end;

function YGaChatMgr.CommandDbgEquipmeWithItems(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
begin
  Owner.Equip.DeleteItem(BAG_NULL, EQUIP_SLOT_MAIN_HAND, True);
  Owner.Equip.InsertItem(EQUIP_SLOT_MAIN_HAND, 1);
  Owner.Equip.DeleteItem(BAG_NULL, EQUIP_SLOT_RANGED_WEAPON, True);
  Owner.Equip.InsertItem(EQUIP_SLOT_RANGED_WEAPON, 6469);
  Owner.Equip.DeleteItem(BAG_NULL, EQUIP_SLOT_OFF_HAND, True);
  Owner.Equip.InsertItem(EQUIP_SLOT_OFF_HAND, 8135);
  Owner.Equip.DeleteItem(BAG_NULL, EQUIP_SLOT_CHEST, True);
  Owner.Equip.InsertItem(EQUIP_SLOT_CHEST, 12422);
  Owner.Equip.DeleteItem(BAG_NULL, EQUIP_SLOT_BOOTS, True);
  Owner.Equip.InsertItem(EQUIP_SLOT_BOOTS, 12426);
  Owner.Equip.DeleteItem(BAG_NULL, EQUIP_SLOT_PANTS, True);
  Owner.Equip.InsertItem(EQUIP_SLOT_PANTS, 12429);
  Owner.Equip.DeleteItem(BAG_NULL, EQUIP_SLOT_BELT, True);
  Owner.Equip.InsertItem(EQUIP_SLOT_BELT, 12424);
  Owner.Equip.DeleteItem(BAG_NULL, EQUIP_SLOT_WRIST, True);
  Owner.Equip.InsertItem(EQUIP_SLOT_WRIST, 12425);
  Owner.Equip.DeleteItem(BAG_NULL, EQUIP_SLOT_HEAD, True);
  Owner.Equip.InsertItem(EQUIP_SLOT_HEAD, 12427);
  Owner.Equip.DeleteItem(BAG_NULL, EQUIP_SLOT_SHOULDERS, True);
  Owner.Equip.InsertItem(EQUIP_SLOT_SHOULDERS, 12428);
  Owner.Equip.DeleteItem(BAG_NULL, EQUIP_SLOT_SHIRT, True);
  Owner.Equip.InsertItem(EQUIP_SLOT_SHIRT, 14617);
  Owner.Equip.DeleteItem(BAG_NULL, EQUIP_SLOT_FINGER_1, True);
  Owner.Equip.InsertItem(EQUIP_SLOT_FINGER_1, 862);
  Owner.Equip.DeleteItem(BAG_NULL, EQUIP_SLOT_FINGER_2, True);
  Owner.Equip.InsertItem(EQUIP_SLOT_FINGER_2, 862);
  Owner.Equip.DeleteItem(BAG_NULL, EQUIP_SLOT_TRINKET_1, True);
  Owner.Equip.InsertItem(EQUIP_SLOT_TRINKET_1, 744);
  Owner.Equip.DeleteItem(BAG_NULL, EQUIP_SLOT_TRINKET_2, True);
  Owner.Equip.InsertItem(EQUIP_SLOT_TRINKET_2, 744);

  Result := ccrSupressMsg;
end;

function YGaChatMgr.CommandDbgHealSelf(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  iAmount: Int32;
  lwCurrHealth: Longword;
begin
  if StringsEqualNoCase(cParams.GetAsString(0), 'FULL') then
  begin
    Owner.Stats.Health := Owner.Stats.MaxHealth;
    Result := ccrOk;
    Exit;
  end;
  iAmount := cParams.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;
  lwCurrHealth := Owner.Stats.Health;
  if lwCurrHealth < Owner.Stats.MaxHealth then
  begin
    Inc(lwCurrHealth, iAmount);
    if lwCurrHealth > Owner.Stats.MaxHealth then
      Owner.Stats.Health := Owner.Stats.MaxHealth
    else
      Owner.Stats.Health := lwCurrHealth;
  end;
  Result := ccrOk;
end;

function YGaChatMgr.CommandDbgHonor(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
begin
  //This will simulate that you killed some random options oponents
  //to test honor actually! 

  Owner.Honor.IncreaseSessionKills(Random(9), Random(10), Random(10), Random(500),
    Random(99), Random(100), True);
  
  Result := ccrOk;
end;

function YGaChatMgr.CommandDbgSetUpdateFieldF(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  iIndex: Int32;
  fValue: Float;
begin
  iIndex := cParams.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  fValue := cParams.GetAsFloat(1, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  Owner.SetFloat(iIndex, fValue);
  Result := ccrOk;
end;

function YGaChatMgr.CommandDbgSetUpdateFieldI(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  iIndex: Int32;
  iValue: Int32;
begin
  iIndex := cParams.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  iValue := cParams.GetAsInteger(1, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  Owner.SetUInt32(iIndex, iValue);
  Result := ccrOk;
end;

function YGaChatMgr.CommandDbgSuicide(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
begin
  if Owner.Stats.Health > 1 then Owner.Stats.Health := 1;
  Result := ccrOk;
end;

function YGaChatMgr.CommandDeleteNode(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  iId: Uint32;
  bSuccess: Boolean;
begin
  iId := cParams.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  bSuccess := GameCore.NodeManager.DeleteNode(GameCore.NodeManager.Nodes[iId]);
  if bSuccess then
  begin
    SystemMessage('Node ' + itoa(iId) + ' deleted.');
  end else
  begin
    SystemMessage('Node ' + itoa(iId) + ' does not exist.');
  end;
  Result := ccrSupressMsg;
end;

function YGaChatMgr.CommandDeMorph(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
begin
  Owner.SetUInt32(UNIT_FIELD_DISPLAYID, Owner.GetUInt32(UNIT_FIELD_NATIVEDISPLAYID));

  Result := ccrOk;
end;

function YGaChatMgr.CommandDisableCommand(Sender: YGaCommandHandlerTable;
  const Args: string): YCommandCallResult;
var
  aPath: TStringDynArray;
begin
  aPath := StringSplit(Args);
  if Sender.DisableCommandHandler(aPath) then
  begin
    Result := ccrOk;
  end else Result := ccrNotFound;
end;

function YGaChatMgr.CommandEnableCommand(Sender: YGaCommandHandlerTable;
  const Args: string): YCommandCallResult;
var
  aPath: TStringDynArray;
begin
  aPath := StringSplit(Args);
  if Sender.EnableCommandHandler(aPath) then
  begin
    Result := ccrOk;
  end else Result := ccrNotFound;
end;

function YGaChatMgr.CommandGPS(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
const
  GpsMsg = 'GPS: Map = %d, X = %f, Y = %f, Z = %f, Angle = %f';
var
  tPos: TVector;
  fAngle: Float;
  iMap: UInt32;
begin
  tPos := Owner.Position.Vector;
  fAngle := Owner.Position.Angle;
  iMap := Owner.Position.MapId;

  SystemMessage(Format(GpsMsg, [iMap, tPos.X, tPos.Y, tPos.Z, fAngle]));
  Result := ccrSupressMsg;
end;

function YGaChatMgr.CommandHelp(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  //iAccess: YAccountAccess;
  pCmd: PCommandData;
  sMsg: string;
  iInt: Int32;
begin
  if cParams.List.Count = 0 then
  begin
    SystemMessage(Sender.GetCommandHelpContext(['HELP']));
  end else if (cParams.List.Count = 1) and StringsEqualNoCase(cParams.GetAsString(0), 'ALL') then
  begin
    //iAccess := cPlayer.Security;
    for iInt := 0 to Sender.CommandList.Count -1 do
    begin
      sMsg := Sender.CommandList[iInt];
      pCmd := PCommandData(Sender.CommandList.Objects[iInt]);
      //if iAccess >= pCmd^.AccessLevel then
      //begin
        sMsg := '.' + sMsg + ' - ' + pCmd^.HelpContext;
        SystemMessage(sMsg);
      //end;
    end;
  end else
  begin
    for iInt := 0 to cParams.List.Count -1 do
    begin
      sMsg := cParams.GetAsString(iInt);
      if Sender.CommandExists(sMsg) then
      begin
        SystemMessage('.' + sMsg + ' - ' + Sender.GetCommandHelpContext(sMsg));
      end;
    end;
  end;
  Result := ccrSupressMsg;
end;

function YGaChatMgr.CommandHideMount(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
begin
  Owner.SetUInt32(UNIT_FIELD_MOUNTDISPLAYID, 0);

  Result := ccrOk;
end;

function YGaChatMgr.CommandKill(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  iGUID: UInt64;
  cObject: YGaMobile;
begin
  iGUID := Owner.GetUInt64(UNIT_FIELD_TARGET);
  GameCore.FindObjectByGUID(otUnit, iGUID, cObject);
  if not Assigned(cObject) then
  begin
    Result := ccrUnspecifiedError;
    Exit;
  end;
  Owner.Quests.UpdateKillObject(cObject.Entry, iGUID);
  Result := ccrOk;
end;

function YGaChatMgr.CommandLevelUp(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  iLvl: UInt32;
  bSuccess: Boolean;
begin
  if cParams.List.Count = 1 then
  begin
    iLvl := cParams.GetAsInteger(0, bSuccess);
    if not bSuccess then
    begin
      Result := ccrBadParamType;
      Exit;
    end;
  end else iLvl := Owner.Stats.Level + 1;
  Owner.Stats.Level := iLvl;
  Result := ccrOk;
end;

function YGaChatMgr.CommandList(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  iInt: Int32;
  pCmd: PCommandData;
  //iAccess: YAccountAccess;
begin
  //iAccess := cPlayer.Security;
  SystemMessage('Available commands:');
  for iInt := 0 to Sender.CommandList.Count -1 do
  begin
    pCmd := PCommandData(Sender.CommandList.Objects[iInt]);
    SystemMessage('.' + pCmd^.Name);
  end;
  Result := ccrSupressMsg;
end;

function YGaChatMgr.CommandMorph(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  iModel: UInt32;
begin
  iModel := cParams.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  Owner.SetUInt32(UNIT_FIELD_DISPLAYID, iModel);

  Result := ccrOk;
end;

function YGaChatMgr.CommandNodeAddSpawn(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  iId: UInt32;
  iOutId: UInt32;
  tSpawnEntry: YNodeSpawnInfo;
  ifNode: INode;
  ifSpawnContext: ISpawnNodeContext;
begin
  iId := cParams.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  tSpawnEntry.EntryId := cParams.GetAsInteger(1, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  tSpawnEntry.DistanceMin := cParams.GetAsFloat(2, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  tSpawnEntry.DistanceMax := cParams.GetAsFloat(3, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  tSpawnEntry.DelayMin := cParams.GetAsInteger(4, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  tSpawnEntry.DelayMax := cParams.GetAsInteger(5, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  tSpawnEntry.EntryType := otUnit;

  ifNode := GameCore.NodeManager.Nodes[iId];
  if Assigned(ifNode) then
  begin
    ifSpawnContext := ifNode.FindContextByInterface(ISpawnNodeContext) as ISpawnNodeContext;
    if not Assigned(ifSpawnContext) then
    begin
      ifSpawnContext := GameCore.NodeManager.CreateSpawnContext(ifNode);
    end;

    iOutId := 0;
    ifSpawnContext.AddSpawnEntry(tSpawnEntry);
    SystemMessage('Spawn entry added. Id of this entry in node entry table: ' +
      itoa(iOutId));
  end else
  begin
    SystemMessage('Node ' + itoa(iId) + ' does not exist.');
  end;
  
  Result := ccrSupressMsg;
end;

function YGaChatMgr.CommandNodeRemSpawn(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  iId: UInt32;
  iTableId: UInt32;
  ifNode: INode;
  ifSpawnContext: ISpawnNodeContext;
begin
  iId := cParams.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  iTableId := cParams.GetAsInteger(1, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  ifNode := GameCore.NodeManager.Nodes[iId];
  if Assigned(ifNode) then
  begin
    ifSpawnContext := ifNode.FindContextByInterface(ISpawnNodeContext) as ISpawnNodeContext;
    if Assigned(ifSpawnContext) then
    begin
      ifSpawnContext.RemoveSpawnEntry(iTableId);
      SystemMessage('Spawn entry ' + itoa(iTableId) + ' removed.');
    end else
    begin
      SystemMessage('Spawn entry ' + itoa(iTableId) + ' not found.');
    end;
  end else
  begin
    SystemMessage('Node ' + itoa(iId) + ' does not exist.');
  end;

  Result := ccrSupressMsg;
end;

function YGaChatMgr.CommandOnline(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  iPlayerCount: Int32;
begin
  iPlayerCount := GameCore.SessionCount;
  if iPlayerCount <> 1 then
  begin
    SystemMessage('There are ' + IntToStr(GameCore.SessionCount) + ' players online.');
  end else
  begin
    SystemMessage('There is 1 player online.');
  end;
  Result := ccrSupressMsg;
end;

function YGaChatMgr.CommandQueryHeight(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  iMap: UInt32;
  fX, fY: Float;
  fZ: Float;
  bSuccess: Boolean;
begin
  if cParams.List.Count = 0 then
  begin
    with Owner.Position do
    begin
      if GameCore.TerrainManager.QueryHeightAt(MapId, X, Y, fZ) then
      begin
        SystemMessage(Format('The height at your position is: %f', [fZ]));
      end else
      begin
        SystemMessage('The height data could not be queried. Either the .ymf file is not present or you''re standing in a non-existing tile (client-wise).');
      end;
    end;
    Result := ccrSupressMsg;
  end else if cParams.List.Count > 1 then
  begin
    if cParams.List.Count = 3 then
    begin
      iMap := cParams.GetAsInteger(0, bSuccess);
      if not bSuccess then
      begin
        Result := ccrBadParamType;
        Exit;
      end;

      fX := cParams.GetAsFloat(1, bSuccess);
      if not bSuccess then
      begin
        Result := ccrBadParamType;
        Exit;
      end;

      fY := cParams.GetAsFloat(2, bSuccess);
      if not bSuccess then
      begin
        Result := ccrBadParamType;
        Exit;
      end;
    end else
    begin
      fX := cParams.GetAsFloat(0, bSuccess);
      if not bSuccess then
      begin
        Result := ccrBadParamType;
        Exit;
      end;

      fY := cParams.GetAsFloat(1, bSuccess);
      if not bSuccess then
      begin
        Result := ccrBadParamType;
        Exit;
      end;
      iMap := Owner.Position.MapId;
    end;

    if GameCore.TerrainManager.QueryHeightAt(iMap, fX, fY, fZ) then
    begin
      SystemMessage(Format('The height at [MAP_%d, %f, %f] is: %f', [iMap, fX, fY, fZ]));
    end else
    begin
      SystemMessage('The height data could not be queried. Either the .ymf file is not present or the point you have chosen is in a non-existing tile (client-wise).');
    end;
    Result := ccrSupressMsg;
  end else
  begin
    Result := ccrBadParamCount;
    Exit;
  end;
end;

function YGaChatMgr.CommandSave(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  iRefreshTimer: Int32;
  bSuccess: Boolean;
begin
  iRefreshTimer := 1;
  if cParams.List.Count > 0 then
  begin
    iRefreshTimer := cParams.GetAsInteger(0, bSuccess);
    if not bSuccess or not (iRefreshTimer in [0..1]) then
    begin
      Result := ccrBadParamType;
      Exit;
    end;
  end;

  DataCore.FullSave(Boolean(iRefreshTimer));
  SystemMessage('DB save in progress...');
  Result := ccrSupressMsg;
end;

function YGaChatMgr.CommandSetPass(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  sPass: string;
  cAcc: YDbAccountEntry;
begin
  if cParams.List.Count <> 1 then
  begin
    Result := ccrBadParamCount;
    Exit;
  end;

  sPass := cParams.GetAsString(0);
  if sPass = '' then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  DataCore.Accounts.LoadEntry(FIELD_ACC_NAME, Owner.Account, cAcc);
  cAcc.Pass := sPass;
  cAcc.AutoCreated := False;
  DataCore.Accounts.SaveEntry(cAcc);
  SystemMessage('Command .setpass executed.' + #13#10 + 'New password is: ' + sPass);
  Result := ccrSupressMsg;
end;

function YGaChatMgr.CommandSetSpeed(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  fBaseSpeed: Float;
  bSuccess: Boolean;
  aOutPkts: array[0..1] of YNwServerPacket;
begin
  fBaseSpeed := cParams.GetAsFloat(0, bSuccess) / 7;
  if not bSuccess then
  begin
    if StringsEqualNoCase(cParams.GetAsString(0), 'DEFAULT') then
    begin
      fBaseSpeed := 7.5 / 7;
    end else
    begin
      Result := ccrBadParamType;
      Exit;
    end;
  end;

  with Owner.Position do
  begin
    RunSpeed := SPEED_RUN * fBaseSpeed;
    BackSwimSpeed := SPEED_BACKSWIM * fBaseSpeed;
    SwimSpeed := SPEED_SWIM * fBaseSpeed;

    aOutPkts[0] := YNwServerPacket.Initialize(SMSG_FORCE_RUN_SPEED_CHANGE);
    aOutPkts[1] := YNwServerPacket.Initialize(SMSG_FORCE_SWIM_SPEED_CHANGE);
    try
      aOutPkts[0].AddPackedGUID(Owner.GUID);
      aOutPkts[0].AddUInt32(0);
      aOutPkts[0].AddFloat(RunSpeed);

      aOutPkts[1].AddPackedGUID(Owner.GUID);
      aOutPkts[1].AddUInt32(0);
      aOutPkts[1].AddFloat(SwimSpeed);

      Owner.SendPacketSetInRange(aOutPkts, VIEW_DISTANCE, True, True);

    finally
      aOutPkts[0].Free;
      aOutPkts[1].Free;
    end;
  end;
  Result := ccrOk;
end;

function YGaChatMgr.CommandSetUnitFlagBits(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  sFlags: string;
  iBit: UInt32;
  iFlags: UInt32;
label
  __BadParam;
begin
  iBit := cParams.GetAsInteger(1, bSuccess);

  if not bSuccess or (iBit > 31) then
  begin
    goto __BadParam;
  end;

  sFlags := cParams.GetAsString(0);

  if StringsEqualNoCase(sFlags, 'UFF') then iFlags := UNIT_FIELD_FLAGS
  else if StringsEqualNoCase(sFlags, 'UNF') then iFlags := UNIT_NPC_FLAGS
  else if StringsEqualNoCase(sFlags, 'PB') then iFlags := PLAYER_BYTES
  else if StringsEqualNoCase(sFlags, 'PB1') then iFlags := PLAYER_BYTES_2
  else if StringsEqualNoCase(sFlags, 'PB2') then iFlags := PLAYER_BYTES_3
  else if StringsEqualNoCase(sFlags, 'PFB') then iFlags := PLAYER_FIELD_BYTES
  else if StringsEqualNoCase(sFlags, 'PFB2') then iFlags := PLAYER_FIELD_BYTES2
  else if StringsEqualNoCase(sFlags, 'UFB1') then iFlags := UNIT_FIELD_BYTES_1
  else if StringsEqualNoCase(sFlags, 'UFB2') then iFlags := UNIT_FIELD_BYTES_2
  else iFlags := StrToIntDef(sFlags, 0);

  if iFlags <= 0 then
  begin
    __BadParam:
    Result := ccrBadParamType;
    Exit;
  end;

  Owner.SetBit(iFlags, iBit);
  Result := ccrOk;
end;

function YGaChatMgr.CommandShowMount(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  iModel: UInt32;
begin
  iModel := cParams.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  Owner.SetUInt32(UNIT_FIELD_MOUNTDISPLAYID, iModel);

  Result := ccrOk;
end;

function YGaChatMgr.CommandStartMovement(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  tGuid: YObjectGuid;
  cMob: YGaMobile;
  cCr: YGaCreature;
  tVec: TVector;
begin
  tGuid := YObjectGuid(Owner.GetUInt64(UNIT_FIELD_TARGET));
  if GameCore.FindObjectByGUID(tGuid.Hi, tGuid.Lo, cMob) then
  begin
    if cMob.InheritsFrom(YGaCreature) then
    begin
      cCr := YGaCreature(cMob);
      VectorAdd(cCr.Position.Vector, 5, tVec);

      if not GameCore.TerrainManager.QueryHeightAt(cCr.Position.MapId, tVec.X, tVec.Y, tVec.Z) then
      begin
        tVec.Z := cCr.Position.Z;
      end;
      
      cCr.StartMovement(tVec, False);
      Result := ccrOk;
    end else
    begin
      SystemMessage('Invalid selection.');
      Result := ccrSupressMsg;
    end;
  end else
  begin
    SystemMessage('You have no selection.');
    Result := ccrSupressMsg;
  end;
end;

function YGaChatMgr.CommandSyntax(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
const
  SYN_LEGEND =
    'Syntax description legend:' + #13#10 +
    'Integer - expects a number' + #13#10 +
    'String - expects a string' + #13#10 +
    'Float - expects a number or a float' + #13#10 +
    '<> - needed parameter' + #13#10 +
    '[] - optional parameter' + #13#10 +
    'N[] - variable number of optional parameters';
var
  iInt: Int32;
  pCmd: PCommandData;
begin
  if cParams.List.Count = 0 then
  begin
    SystemMessage(SYN_LEGEND);
  end else
  begin
    for iInt := 0 to cParams.List.Count -1 do
    begin
      pCmd := Sender.GetCommandData([cParams.GetAsString(iInt)]);
      if pCmd <> nil then
      begin
        SystemMessage(pCmd^.Name + ' - ' + pCmd^.Syntax);
      end;
    end;
  end;
  Result := ccrSupressMsg;
end;

function YGaChatMgr.CommandTeleport(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  iMap: UInt32;
  fX, fY, fZ: Float;
  bSuccess: Boolean;
begin
  iMap := cParams.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  fX := cParams.GetAsFloat(1, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  fY := cParams.GetAsFloat(2, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  fZ := cParams.GetAsFloat(3, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  Owner.Position.DoTeleport(iMap, fX, fY, fZ);

  Result := ccrOk;
end;

function YGaChatMgr.CommandTeleportTo(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  sName: string;
  cTeleportTo: YGaPlayer;
begin
  sName := cParams.GetAsString(0);
  case GameCore.FindPlayerByName(sName, cTeleportTo) of
    lrNonExistant:
    begin
      Owner.Chat.SystemMessage('Player does not exist.');
      Result := ccrSupressMsg;
    end;
    lrOffline:
    begin
      Owner.Chat.SystemMessage('Player is not online.');
      Result := ccrSupressMsg;
    end;
    lrOnline:
    begin
      with cTeleportTo.Position do
      begin
        Owner.Position.DoTeleport(MapId, X, Y, Z);
      end;

      Result := ccrOk;
    end;
  else
    Result := ccrOk;
  end;
end;

function YGaChatMgr.CommandTestUnitFlagBits(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  sFlags: string;
  iBit: UInt32;
  iFlags: UInt32;
label
  __BadParam;
begin
  iBit := cParams.GetAsInteger(1, bSuccess);
  
  if not bSuccess or (iBit > 31) then
  begin
    goto __BadParam;
  end;

  sFlags := cParams.GetAsString(0);

  if StringsEqualNoCase(sFlags, 'UFF') then iFlags := UNIT_FIELD_FLAGS
  else if StringsEqualNoCase(sFlags, 'UNF') then iFlags := UNIT_NPC_FLAGS
  else if StringsEqualNoCase(sFlags, 'PB') then iFlags := PLAYER_BYTES
  else if StringsEqualNoCase(sFlags, 'PB1') then iFlags := PLAYER_BYTES_2
  else if StringsEqualNoCase(sFlags, 'PB2') then iFlags := PLAYER_BYTES_3
  else if StringsEqualNoCase(sFlags, 'PFB') then iFlags := PLAYER_FIELD_BYTES
  else if StringsEqualNoCase(sFlags, 'PFB2') then iFlags := PLAYER_FIELD_BYTES2
  else if StringsEqualNoCase(sFlags, 'UFB1') then iFlags := UNIT_FIELD_BYTES_1
  else if StringsEqualNoCase(sFlags, 'UFB2') then iFlags := UNIT_FIELD_BYTES_2
  else iFlags := StrToIntDef(sFlags, 0);

  if iFlags <= 0 then
  begin
    __BadParam:
    Result := ccrBadParamType;
    Exit;
  end;

  SystemMessage('Tested bit ' + itoa(iBit) + '. The result is ' +
    BoolToStr(Owner.TestBit(iFlags, iBit)));

  Result := ccrOk;
end;

function YGaChatMgr.CommandUnSetUnitFlagBits(Sender: YGaCommandHandlerTable;
  cParams: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  sFlags: string;
  iBit: UInt32;
  iFlags: UInt32;
label
  __BadParam;
begin
  iBit := cParams.GetAsInteger(1, bSuccess);
  
  if not bSuccess or (iBit > 31) then
  begin
    goto __BadParam;
  end;

  sFlags := cParams.GetAsString(0);

  if StringsEqualNoCase(sFlags, 'UFF') then iFlags := UNIT_FIELD_FLAGS
  else if StringsEqualNoCase(sFlags, 'UNF') then iFlags := UNIT_NPC_FLAGS
  else if StringsEqualNoCase(sFlags, 'PB') then iFlags := PLAYER_BYTES
  else if StringsEqualNoCase(sFlags, 'PB1') then iFlags := PLAYER_BYTES_2
  else if StringsEqualNoCase(sFlags, 'PB2') then iFlags := PLAYER_BYTES_3
  else if StringsEqualNoCase(sFlags, 'PFB') then iFlags := PLAYER_FIELD_BYTES
  else if StringsEqualNoCase(sFlags, 'PFB2') then iFlags := PLAYER_FIELD_BYTES2
  else if StringsEqualNoCase(sFlags, 'UFB1') then iFlags := UNIT_FIELD_BYTES_1
  else if StringsEqualNoCase(sFlags, 'UFB2') then iFlags := UNIT_FIELD_BYTES_2
  else iFlags := StrToIntDef(sFlags, 0);

  if iFlags <= 0 then
  begin
    __BadParam:
    Result := ccrBadParamType;
    Exit;
  end;

  Owner.ResetBit(iFlags, iBit);
  Result := ccrOk;
end;

{ YExperienceMgr }

procedure YGaExperienceMgr.CleanupObjectData;
begin
end;

procedure YGaExperienceMgr.ExtractObjectData(cEntry: YDbSerializable);
begin
end;

procedure YGaExperienceMgr.InjectObjectData(cEntry: YDbSerializable);
begin
end;

function YGaExperienceMgr.GetRestState: Boolean;
begin
  Result := fRestedState > 30;
end;

{ YActionMgr }

procedure YGaActionMgr.CleanupObjectData;
begin
end;

procedure YGaActionMgr.ExtractObjectData(cEntry: YDbSerializable);
var
  cPlr: YDbPlayerEntry;
begin
  cPlr := YDbPlayerEntry(cEntry);
  Move(cPlr.ActionButtons[0], fActionButtons[0], Length(cPlr.ActionButtons) shl 2);
end;

procedure YGaActionMgr.InjectObjectData(cEntry: YDbSerializable);
var
  cPlr: YDbPlayerEntry;
begin
  cPlr := YDbPlayerEntry(cEntry);
  cPlr.SetActionButtonsLength(Length(fActionButtons));
  Move(fActionButtons[0], cPlr.ActionButtons[0], Length(fActionButtons) shl 2);
end;

procedure YGaActionMgr.AddButton(iButtonIdx: UInt8; iValue: UInt32);
begin
  fActionButtons[iButtonIdx] := iValue;
end;

function YGaActionMgr.ReadButton(iButtonIdx: UInt8): UInt32;
begin
  Result := fActionButtons[iButtonIdx];
end;

procedure YGaActionMgr.SendActionButtons;
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
      cPkt.AddUInt32(fActionButtons[iX]);
    end;
    SendPacket(cPkt);
  finally
    cPkt.Free;
  end;
end;

{ YTutorialMgr }

procedure YGaTutorialMgr.CleanupObjectData;
begin
end;

procedure YGaTutorialMgr.ExtractObjectData(cEntry: YDbSerializable);
var
  cPlr: YDbPlayerEntry;
begin
  cPlr := YDbPlayerEntry(cEntry);
  Move(cPlr.Tutorials[0], fTutorials[0], Length(cPlr.Tutorials) shl 2);
end;

procedure YGaTutorialMgr.InjectObjectData(cEntry: YDbSerializable);
var
  cPlr: YDbPlayerEntry;
begin
  cPlr := YDbPlayerEntry(cEntry);
  cPlr.SetTutorialsLength(Length(fTutorials));
  Move(fTutorials[0], cPlr.Tutorials[0], Length(fTutorials) shl 2);
end;

function YGaTutorialMgr.GetTutFlag(iIndex: UInt32): Boolean;
var
  iDex: UInt32;
begin
  iDex := DivModPowerOf2(iIndex, 5, Integer(iIndex));
  Result := GetBit32(fTutorials[iDex], iIndex);
end;

procedure YGaTutorialMgr.SetTutFlag(iIndex: UInt32; const bValue: Boolean);
var
  iDex: UInt32;
begin
  iDex := DivModPowerOf2(iIndex, 5, Integer(iIndex));
  if bValue then
  begin
    fTutorials[iDex] := SetBit32(fTutorials[iDex], iIndex);
  end else
  begin
    fTutorials[iDex] := ResetBit32(fTutorials[iDex], iIndex);
  end;
end;

procedure YGaTutorialMgr.MarkReadAllTutorials;
var
  iIndex: UInt32;
begin
  for iIndex := 0 to Length(fTutorials) - 1 do
  begin
    fTutorials[iIndex] := $FFFFFFFF;
  end;
end;

procedure YGaTutorialMgr.MarkUnreadAllTutorials;
var
  iIndex: UInt32;
begin
  for iIndex := 0 to Length(fTutorials) - 1 do
  begin
    fTutorials[iIndex] := $00000000;
  end;
end;

procedure YGaTutorialMgr.SendTutorialsStatus;
var
  cPkt: YNwServerPacket;
begin
  cPkt := YNwServerPacket.Initialize(SMSG_TUTORIAL_FLAGS);
  try
    cPkt.AddStruct(fTutorials[0], (Length(fTutorials) -1) shl 2);
    SendPacket(cPkt);
  finally
    cPkt.Free;
  end;
end;

{ YSkillMgr }

procedure YGaSkillMgr.CleanupObjectData;
begin
end;

procedure YGaSkillMgr.ExtractObjectData(cEntry: YDbSerializable);
begin
end;

procedure YGaSkillMgr.InjectObjectData(cEntry: YDbSerializable);
begin
end;

function YGaSkillMgr.RetreiveSkillData(iSkillLine, iPiece: UInt32): UInt32;
begin
  //if (iSkillLine < __PLAYER_SKILLS_MAX) then
  //begin
  //  Result := fUpdates.GetUInt32(((iSkillLine * 3) + PLAYER_SKILL_INFO) + iPiece);
  //end;
  Result := 0;
end;

procedure YGaSkillMgr.SaveSkillData(iSkillLine, iInt, iPiece: UInt32);
begin
  //if (iSkillLine < __PLAYER_SKILLS_MAX) then
  //begin
  //  fUpdates.SetUInt32(((iSkillLine * 3) + PLAYER_SKILL_INFO) + iPiece, iInt);
  //end;
end;

function YGaSkillMgr.GetSkillCount: UInt32;
var
  iX: Int32;
begin
  Result := 0;
  for iX := 0 to (__PLAYER_SKILL_INFO_1_1 div 3)  - 2 do
  begin
    if SkillId[iX] <> 0 then Inc(Result);
  end;
end;

function YGaSkillMgr.GetSkillCrr(iIndex: UInt32): UInt16;
begin
  Result := LongRec(RetreiveSkillData(iIndex, UPDATE_SKILL_DATA)).Words[WORD_SKILL_CURR];
end;

function YGaSkillMgr.GetSkillId(iIndex: UInt32): UInt32;
begin
  Result := RetreiveSkillData(iIndex, UPDATE_SKILL_ID);
end;

function YGaSkillMgr.GetSkillMax(iIndex: UInt32): UInt16;
begin
  Result := LongRec(RetreiveSkillData(iIndex, UPDATE_SKILL_DATA)).Words[WORD_SKILL_MAX];
end;

procedure YGaSkillMgr.SetSkillCrr(iIndex: UInt32; const Value: UInt16);
var
  lwTemp: Longword;
begin
  lwTemp := RetreiveSkillData(iIndex, UPDATE_SKILL_DATA);
  LongRec(lwTemp).Words[WORD_SKILL_CURR] := Value;
  SaveSkillData(iIndex, lwTemp, UPDATE_SKILL_DATA);
end;

procedure YGaSkillMgr.SetSkillId(iIndex: UInt32; const Value: UInt32);
begin
  SaveSkillData(iIndex, Value, UPDATE_SKILL_ID);
end;

procedure YGaSkillMgr.SetSkillMax(iIndex: UInt32; const Value: UInt16);
var
  lwTemp: Longword;
begin
  lwTemp := RetreiveSkillData(iIndex, UPDATE_SKILL_DATA);
  LongRec(lwTemp).Words[WORD_SKILL_MAX] := Value;
  SaveSkillData(iIndex, lwTemp, UPDATE_SKILL_DATA);
end;

function YGaSkillMgr.AddNewSkill(iSkillId, iSkillKnown, iSkillMax: UInt32): Int32;
var
  iX: Int32;
begin
  for iX := 0 to (__PLAYER_SKILL_INFO_1_1 div 3)  - 2 do
  begin
    if SkillId[iX] = 0 then
    begin
      Result := iX;
      SkillId[iX] := iSkillId;
      SkillCurrent[iX] := iSkillKnown;
      SkillMax[iX] := iSkillMax;
      Exit;
    end;
  end;
  Result := -1;
end;

function YGaSkillMgr.HasSkill(iSkillId: UInt32): Boolean;
var
  iX: Int32;
begin
  Result := False;
  for iX := 0 to (__PLAYER_SKILL_INFO_1_1 div 3)  - 2 do
  begin
    if SkillId[iX] = iSkillId then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

{ YGuildMgr }

procedure YGaGuildMgr.CleanupObjectData;
begin
end;

procedure YGaGuildMgr.ExtractObjectData(cEntry: YDbSerializable);
begin
end;

procedure YGaGuildMgr.InjectObjectData(cEntry: YDbSerializable);
begin
end;

procedure YGaGuildMgr.SetGuildId(const Value: UInt32);
begin
  Owner.SetUInt32(PLAYER_GUILDID, Value);
end;

procedure YGaGuildMgr.SetGuildRank(const Value: UInt32);
begin
  Owner.SetUInt32(PLAYER_GUILDRANK, Value);
end;

function YGaGuildMgr.GetGuildId: UInt32;
begin
  Result := Owner.GetUInt32(PLAYER_GUILDID);
end;

function YGaGuildMgr.GetGuildRank: UInt32;
begin
  Result := Owner.GetUInt32(PLAYER_GUILDRANK);
end;

{ YHonorMgr }

procedure YGaHonorMgr.CleanupObjectData;
begin
end;

procedure YGaHonorMgr.InjectObjectData(cEntry: YDbSerializable);
var
  cPlr: YDbPlayerEntry;
begin
  cPlr := YDbPlayerEntry(cEntry);
  cPlr.SetHonorStatsLength(Length(fHonorStats));
  Move(fHonorStats[0], cPlr.HonorStats[0], Length(fHonorStats) shl 2);
end;

procedure YGaHonorMgr.ExtractObjectData(cEntry: YDbSerializable);
var
  cPlr: YDbPlayerEntry;
begin
  cPlr := YDbPlayerEntry(cEntry);
  Move(cPlr.HonorStats[0], fHonorStats[0], Length(cPlr.HonorStats) shl 2);
end;

procedure YGaHonorMgr.AddBattleGroundHonor(iBGPoints: Integer);
begin
  // TODO AddBattleGorundHonor
end;

procedure YGaHonorMgr.AddQuestHonorPoints(iValue: Integer);
begin
  // TODO AddQuestHonorPoints
end;

function YGaHonorMgr.HonorablePlayersOnServer: UInt32;
begin
  // TODO HonorablePlayersOnServer - later
  Result := 12;
end;

function YGaHonorMgr.Standing: UInt32;
begin
  Result := 702; //TODO Temporary as it has to calculate the search through the ranks
                 //of all players and assign this one the proper rank, also update all the others
end;

function YGaHonorMgr.ComputeRank(bHonorable: Boolean): UInt32;
var
  iRank: Integer;
begin
  result := 0;
  
  iRank := fHonorStats[LIFETIME_HONORABLE];
  if iRank < 15 then
  begin
    Owner.SetUInt32 ( PLAYER_FIELD_BYTES2, 0);
    fHonorStats[HONOR_RANK] := UNIT_HONOR_RANK_NONE;
    SetPVPRank( UInt8(fHonorStats[HONOR_RANK]) );
    Exit;
  end;

  iRank := fHonorStats[LIFETIME_RANK_POINTS] div 5000;
  if iRank > 13 then iRank := 13;
  if iRank < -4 then iRank := -4;

  Owner.SetUInt32( PLAYER_FIELD_BYTES2, UInt32(RankPercentage(iRank, fHonorStats[LIFETIME_RANK_POINTS])));
  fHonorStats[HONOR_RANK] := iRank + 5;
  SetPVPRank( UInt8(fHonorStats[HONOR_RANK]) );

  Result := UInt32(iRank + 5);
end;

function YGaHonorMgr.GetPVPRank: UInt8;
begin
  Result := UInt8(Owner.GetUInt32(PLAYER_BYTES_3) shr 24);
end;

procedure YGaHonorMgr.Honor(iKilledTimesBefore,
  iLevelDifference: Integer; iHonorRank, iStanding, iReputationPercentage: UInt32;
  iBGPoints: Integer; bFactionDiffers: Boolean);
var
  iTempHonor, iI: Integer;
  //sText : String;
begin
  {$WARNINGS OFF}
  {checks for honor depending on how many times the player was killed before}
  if iKilledTimesBefore > 10 then iTempHonor := HONOR_POINTS_NONE else
  if iKilledTimesBefore < -10 then iTempHonor := HONOR_POINTS_PER_KILL * 2 else   //this means that in the past few hours the
                //actual oponent killed the actual "killer"
     iTempHonor := ((110 - (iKilledTimesBefore * 10)) * HONOR_POINTS_PER_KILL) div 100;


  {checks for level difference}
  if iLevelDifference > 10 then iTempHonor := HONOR_POINTS_NONE else
  if iLevelDifference < -10 then iTempHonor := iTempHonor + (HONOR_POINTS_PER_KILL * 2) else  //this means i'm smaller and i need more honor then he does
  if iLevelDifference = 0 then iTempHonor := iTempHonor + 1 else
     iTempHonor := iTempHonor + (((iLevelDifference * 10) * HONOR_POINTS_PER_KILL) div 100);     //


  {checks for differences between my rank and oponent's rank}
  iTempHonor := iTempHonor - ((fHonorStats[HONOR_RANK] - iHonorRank) * HONOR_RANK_DIF_MULTIPLIER);
  //maybe this needs to be tweaked or something as for example if a Rank14 kills a Rank-4 it may need some special treatment
  //as this may be considered really honorable or something

  {checks for standing  HONOR_STANDING_DIF_MULTIPLIER  }
  {Standing has a HonorablePlayersOnServer MAX value}

  iI := (fHonorStats[THIS_WEEK_STANDING] - iStanding) * (HonorablePlayersOnServer mod 100);
  if iI = 0 then iTempHonor := iTempHonor + HONOR_STANDING_DIF_MULTIPLIER else
    iTempHonor := iTempHonor + ((iI div 100) * HONOR_STANDING_DIF_MULTIPLIER);

  {checks for that oponet's reputation percentage}
  if iReputationPercentage = 0 then iTempHonor := iTempHonor + HONOR_PER_REP_PERCENT else
    iTempHonor := iTempHonor + (iReputationPercentage * HONOR_PER_REP_PERCENT) div 10;

  {check for BG points}
  if (iBGPoints <> 0) and (YGaPlayer(fOwner).Stats.Level >= 10) then
    case YGaPlayer(fOwner).Stats.Level of
    10..19: iTempHonor := iTempHonor +  24 + ((12 * iBGPoints) div 100);
    20..29: iTempHonor := iTempHonor +  41 + ((21 * iBGPoints) div 100);
    30..39: iTempHonor := iTempHonor +  68 + ((34 * iBGPoints) div 100);
    40..49: iTempHonor := iTempHonor + 113 + ((57 * iBGPoints) div 100);
    50..59: iTempHonor := iTempHonor + 189 + ((95 * iBGPoints) div 100);
    60:     iTempHonor := iTempHonor + 198 + iBGPoints
    else
      iTempHonor := iTempHonor + 1;
  end;


  if iTempHonor < 0 then iTempHonor := -iTempHonor;


  {check if this kill is honorable}
  if bFactionDiffers then
  begin
    fHonorStats[TODAY_HONOR]     := fHonorStats[TODAY_HONOR] + UInt32(iTempHonor);
    fHonorStats[THIS_WEEK_HONOR] := fHonorStats[THIS_WEEK_HONOR] + UInt32(iTempHonor);
    fHonorStats[LIFETIME_RANK_POINTS] := fHonorStats[LIFETIME_RANK_POINTS] + UInt32(iTempHonor);
  end else
  begin
    fHonorStats[TODAY_HONOR]     := fHonorStats[TODAY_HONOR] - UInt32(iTempHonor);
    fHonorStats[THIS_WEEK_HONOR] := fHonorStats[THIS_WEEK_HONOR] - UInt32(iTempHonor);
    fHonorStats[LIFETIME_RANK_POINTS] := fHonorStats[LIFETIME_RANK_POINTS] - UInt32(iTempHonor);
  end;

  {$IFNDEF WOW_TBC}
  Owner.SetUInt32(PLAYER_FIELD_THIS_WEEK_CONTRIBUTION, fHonorStats[THIS_WEEK_HONOR]);
  {$ENDIF}

  {

    //Used to display a message with your received honor points

    sText := 'Hey you received ' + itoa(UInt32(iTempHonor)) +
      ' honor points. The options involved in this calculation were: level dif = ' + itoa(iLevelDifference) +
      ', which was killed like '  + itoa(iKilledTimesBefore) +
      ' times before, has rank ' + itoa(iHonorRank) +
      ', a standing of ' + itoa(iStanding) +
      'points, ' + itoa(iReputationPercentage) + '% reputation for it''s faction and you had ' +
      itoa(iBGPoints) + ' BG points';
     YOpenPlayer(fOwner).Chat.SystemMessage( sText );
  }

  {$WARNINGS ON}
end;

procedure YGaHonorMgr.IncreaseLifeTimeKills(bHonorable: Boolean);
begin
  if bHonorable then
  begin
    Inc(fHonorStats[LIFETIME_HONORABLE]);
    Owner.SetUInt32(PLAYER_FIELD_LIFETIME_HONORBALE_KILLS, fHonorStats[LIFETIME_HONORABLE]);
  end else
  begin
    Inc(fHonorStats[LIFETIME_DISHONORABLE]);
    {$IFNDEF WOW_TBC}
    Owner.SetUInt32(PLAYER_FIELD_LIFETIME_DISHONORBALE_KILLS, (fHonorStats[LIFETIME_DISHONORABLE]));
    {$ENDIF}
  end;
end;

procedure YGaHonorMgr.IncreaseSessionKills(
    iKilledTimesBefore,
    iLevelDifference: Integer;
    iHonorRank,
    iStanding,
    iReputationPercentage: UInt32;
    iBGPoints: Integer;
    bFactionDiffers: Boolean
  );
var
  MM, DD, Y, M, D: UInt16;
begin
  //fHonorStats[ID_YESTERDAY] := (12{day} shl 16) + 8{month};

  {in database we will keep both month and day for prev_day date}
  {the structure is supposed to be MMDD, where MM=month, DD=day}
  {day shl 16 + month}

  if fHonorStats[ID_YESTERDAY] <> 0 then
  begin
    DecodeDate(Date, Y, M, D);

    MM := UInt16(fHonorStats[ID_YESTERDAY]);
    DD := UInt16(fHonorStats[ID_YESTERDAY] shr 16);

    if IsToday(IncDay(EncodeDate(Y, MM, DD))) then
    begin
      fHonorStats[ID_YESTERDAY] := (D shl 16) + M;
      RenewPrevDayStats;
    end;
  end else
  begin
    DecodeDate(IncDay(Date, -1), Y, M, D);
    fHonorStats[ID_YESTERDAY] := (D shl 16) + M;
  end;

  {Begining the processing of this shit}

  if bFactionDiffers then //this means the kill was honorable
  begin
    { Increasing kills for both today and this week }
    Inc(fHonorStats[TODAY_HONORABLE]);
    IncreaseThisWeekKills;
  end else
  begin
    Inc(fHonorStats[TODAY_DISHONORABLE]);
  end;

  {Preparing HONOR Points}
  Honor(iKilledTimesBefore, iLevelDifference, iHonorRank, iStanding,
    iReputationPercentage, iBGPoints, bFactionDiffers);

  //Standing()

  {$IFNDEF WOW_TBC}
  Owner.SetUInt32(PLAYER_FIELD_SESSION_KILLS, (fHonorStats[TODAY_DISHONORABLE] shl 16) + fHonorStats[TODAY_HONORABLE]);
  {$ENDIF}
  IncreaseLifeTimeKills(bFactionDiffers);
  ComputeRank(bFactionDiffers);
end;

procedure YGaHonorMgr.IncreaseThisWeekKills;
var
  YY, WW, W, Y: UInt16;
begin
  //fHonorStats[ID_LAST_WEEK] := (15{week} shl 16) + 2006;

  {in database we will keep both year and week for this_week date}
  {the structure is supposed to be YYWW, where YY=year, WW=week}
  {week shl 16 + year}

  if fHonorStats[ID_LAST_WEEK] <> 0 then
  begin
    W := WeekOf(Date);
    Y := CurrentYear;

    YY := UInt16(fHonorStats[ID_LAST_WEEK]);
    WW := UInt16(fHonorStats[ID_LAST_WEEK] shr 16);

    if EncodeDateWeek(Y, W) <> IncWeek(EncodeDateWeek(YY, WW)) then
    begin
      fHonorStats[ID_LAST_WEEK] := (W shl 16) + Y;
      RenewPrevWeekStats;
    end;
  end else
  begin
    W := WeekOf(Date) - 1;
    Y := CurrentYear;
    fHonorStats[ID_LAST_WEEK] := (W shl 16) + Y;
  end;

  Inc(fHonorStats[THIS_WEEK_HONORABLE]);
  {$IFNDEF WOW_TBC}
  Owner.SetUInt32(PLAYER_FIELD_THIS_WEEK_KILLS, fHonorStats[THIS_WEEK_HONORABLE]);
  {$ENDIF}
end;

function YGaHonorMgr.RankPercentage(iRank, iPoints : Integer): UInt8;
begin
  //percentage bar has a 255 max value :)
  Result := ((iPoints - (iRank * 5000)) * 255) div 5000;
end;

procedure YGaHonorMgr.RenewPrevDayStats;
begin
  fHonorStats[YESTERDAY_HONORABLE] := fHonorStats[TODAY_HONORABLE];
  RenewYesterdayHonor;

  fHonorStats[TODAY_HONORABLE] := 0;
  fHonorStats[TODAY_DISHONORABLE] := 0;

  {$IFNDEF WOW_TBC}
  Owner.SetUInt32(PLAYER_FIELD_SESSION_KILLS, (fHonorStats[TODAY_DISHONORABLE] shl 16) + fHonorStats[TODAY_HONORABLE]);
  {$ENDIF}
  //Owner.SetUInt32(PLAYER_FIELD_YESTERDAY_KILLS, fHonorStats[YESTERDAY_HONORABLE]);
  {$IFNDEF WOW_TBC}
  Owner.SetUInt32(PLAYER_FIELD_YESTERDAY_CONTRIBUTION, fHonorStats[YESTERDAY_HONOR]);
  {$ENDIF}
end;

procedure YGaHonorMgr.RenewPrevWeekStats;
begin
  fHonorStats[LAST_WEEK_HONORABLE] := fHonorStats[THIS_WEEK_HONORABLE];
  fHonorStats[LAST_WEEK_HONOR] := fHonorStats[THIS_WEEK_HONOR];
  fHonorStats[LAST_WEEK_STANDING] := Standing; //{ TODO 4 -oTheSelby -cHonor : Here we must compute some formulae to determine this standing shit }
  fHonorStats[THIS_WEEK_HONORABLE] := 0;
  fHonorStats[THIS_WEEK_HONOR] := 0;

  {$IFNDEF WOW_TBC}
  Owner.SetUInt32(PLAYER_FIELD_THIS_WEEK_KILLS, fHonorStats[THIS_WEEK_HONORABLE]);
  Owner.SetUInt32(PLAYER_FIELD_THIS_WEEK_CONTRIBUTION, fHonorStats[THIS_WEEK_HONOR]);
  {$ENDIF}

  {$IFNDEF WOW_TBC}
  Owner.SetUInt32(PLAYER_FIELD_LAST_WEEK_KILLS, fHonorStats[LAST_WEEK_HONORABLE]);
  Owner.SetUInt32(PLAYER_FIELD_LAST_WEEK_CONTRIBUTION, fHonorStats[LAST_WEEK_HONOR]);
  Owner.SetUInt32(PLAYER_FIELD_LAST_WEEK_RANK, fHonorStats[LAST_WEEK_STANDING]);
  {$ENDIF}
end;

procedure YGaHonorMgr.SetPVPRank(const Value: UInt8);
  procedure SetHighestRank;
  begin
    if fHonorStats[HONOR_RANK] > fHonorStats[LIFETIME_HIGHEST_RANK] then
    begin
      fHonorStats[LIFETIME_HIGHEST_RANK] := fHonorStats[HONOR_RANK];
    end;
  end;
var
  iCurrBytes : UInt32;
  iRank : UInt8;
  iA, iB, iC : UInt8;
begin
  iRank := Value;
  if iRank > 18 then iRank := 18;         //a small check for eventual errors
                                        //when giving a wrong value to this method
  iCurrBytes := Owner.GetUInt32(PLAYER_BYTES_3);
  iA := UInt8(iCurrBytes and $FF);
  iB := UInt8((iCurrBytes shr 8) and $FF);
  iC := UInt8((iCurrBytes shr 16) and $FF);

  Owner.SetUInt32(PLAYER_BYTES_3, (iA or (iB shl 8) or (iC shl 16) or (iRank shl 24)));
  SetHighestRank;
end;

procedure YGaHonorMgr.RenewYesterdayHonor;
begin
  fHonorStats[YESTERDAY_HONOR] := fHonorStats[TODAY_HONOR];
  fHonorStats[TODAY_HONOR] := 0;

  {$IFNDEF WOW_TBC}
  Owner.SetUInt32(PLAYER_FIELD_YESTERDAY_CONTRIBUTION, fHonorStats[YESTERDAY_HONOR]);
  {$ENDIF}
end;

{ YTradeMgr }

procedure YGaTradeMgr.SetItem(const iTradeSlot, iBag, iSlot, iEntry, iStackCount: UInt32);
begin
  fItems[iTradeSlot].iBag := iBag;
  fItems[iTradeSlot].iSlot := iSlot;
  fItems[iTradeSlot].iEntry :=  iEntry;
  fItems[iTradeSlot].iStackCount := iStackCount;
end;

procedure YGaTradeMgr.Reset;
var
  iX: UInt32;
begin
  fCopper := 0;
  fAccept := False;
  for iX := 0 to 7 do
  begin
    fItems[iX].iEntry := 0;
    fItems[iX].iStackCount := 0;
  end;
end;

{ YQuestMgr }

procedure YGaQuestMgr.CleanupObjectData;
begin
end;

procedure YGaQuestMgr.ExtractObjectData(cEntry: YDbSerializable);
var
  cPlr: YDbPlayerEntry;
begin
  cPlr := YDbPlayerEntry(cEntry);
  fActiveQuests := cPlr.ActiveQuests;
  fFinishedQuests := cPlr.FinishedQuests;
end;

procedure YGaQuestMgr.InjectObjectData(cEntry: YDbSerializable);
var
  cPlr: YDbPlayerEntry;
begin
  cPlr := YDbPlayerEntry(cEntry);
  cPlr.ActiveQuests := fActiveQuests;
  cPlr.FinishedQuests := fFinishedQuests;
end;

procedure YGaQuestMgr.Add(iQuestId: UInt32);
var
  iX, iLogId, iBaseIndex: Int32;
  cOutPkt: YNwServerPacket;
begin
  iX := 0;
  while fActiveQuests.Quests[iX].Id <> 0 do
  begin
    if iQuestId = fActiveQuests.Quests[iX].Id then
    begin
      Exit;
    end;
    Inc(iX);
    if iX >= QUEST_LOG_COUNT then
    begin
      cOutPkt := YNwServerPacket.Initialize(SMSG_QUESTLOG_FULL);
      try
        SendPacket(cOutPkt);
      finally
        cOutPkt.Free;
      end;
      Exit;
    end;
  end;
  iLogId := iX;
  while iX < QUEST_LOG_COUNT do
  begin
    if iQuestId = fActiveQuests.Quests[iX].Id then Exit;
    Inc(iX);
  end;

  DataCore.QuestTemplates.LoadEntry(iQuestId, fActiveQuestsInfos[iLogId].Template);
  if not Assigned(fActiveQuestsInfos[iLogId].Template) then Exit;

  with fActiveQuestsInfos[iLogId].Template do
  begin
    if not Owner.Equip.HasEnoughFreeSlots(ReceiveItem.Count) then
    begin
      Owner.Equip.SendInventoryError(INV_ERR_INVENTORY_FULL);
      Exit;
    end;
    for iX := 0 to ReceiveItem.Count - 1 do
    begin
      Owner.Equip.AddItem(ReceiveItem.Objects[iX].Id, ReceiveItem.Objects[iX].Count, True);
    end;
  end;

  if not Assigned(fActiveQuestsInfos[iLogId].Template) then
    Exit;
  fActiveQuests.Quests[iLogId].Id := iQuestId;
  for iX := 0 to QUEST_OBJECTS_COUNT - 1 do
  begin
    fActiveQuests.Quests[iLogId].KillObjectives[iX] := 0;
  end;

  if fActiveQuestsInfos[iLogId].Template.ExploreObjective <> 0 then
  begin
    fActiveQuests.Quests[iLogId].NeedExplore := True;
  end;

  with fActiveQuestsInfos[iLogId] do
  begin
    for iX := 0 to QUEST_OBJECTS_COUNT - 1 do
    begin
      DeliverObjectivesStatus[iX] := Owner.Equip.ThisItemCount(Template.DeliverObjective.Objects[iX].Id);
    end;
  end;
  {TODO 5 -oBIGBOSS : set correct Objectives}
  Inc(fActiveQuests.Count);

  //case iQuestLogResult of
    {QUEST_ERROR_QUEST_LOG_FULL:
    begin
      cOutPkt := YServerPacket.Initialize(SMSG_QUESTLOG_FULL);
      SendPacket(cOutPkt);
    end;
    QUEST_ERROR_ALREADY_HAVE:
    begin
      fLoggedInPlayer.Chat.SystemMessage('You already have that quest');
    end;
    QUEST_ERROR_NOT_FOUND:
    begin
      fLoggedInPlayer.Chat.SystemMessage('Quest not found');
    end
    else
    begin  }
      iBaseIndex := PLAYER_QUEST_LOG_1_1 + iLogId * 3;
      Owner.SetUInt32(iBaseIndex, iQuestId);
      Owner.SetUInt32(iBaseIndex + 1, 0);
      Owner.SetUInt32(iBaseIndex + 2, 0);
    //end;
  //end;
end;

procedure YGaQuestMgr.QuestExploration(iQuestId: UInt32);
var
  iLogId: Int32;
  cOutPkt: YNwServerPacket;
begin
  iLogId := GetLogId(iQuestId);
  if (iLogId <> - 1) and fActiveQuests.Quests[iLogId].NeedExplore then
  begin
    fActiveQuests.Quests[iLogId].NeedExplore := False;
    cOutPkt := YNwServerPacket.Initialize(SMSG_QUESTUPDATE_COMPLETE);
    try
      cOutPkt.AddUInt32(iQuestId);
      SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end;
end;

function YGaQuestMgr.IsAvailable(iQuestId: Int32): Boolean;
begin
  if (GetLogId(iQuestId) <> - 1) or IsFinishedQuest(iQuestId) then
    Result := False
  else
    Result := True;
end;

function YGaQuestMgr.IsFinishedQuest(iQuestId: UInt32): Boolean;
var
  iX: Int32;
begin
  iX := 0;
  while iX < Length(fFinishedQuests) do
  begin
    if fFinishedQuests[iX] = iQuestId then
    begin
      Result := True;
      Exit;
    end;
    Inc(iX);
  end;
  Result := False;
end;

function YGaQuestMgr.IsWaitingForReward(iLogId: Int32): Boolean;
var
  iX: Int32;
begin
  if (iLogId = - 1) or not Assigned(fActiveQuestsInfos[iLogId].Template) then
  begin
    Result := False;
    Exit;
  end;
  Result := False;
  if fActiveQuests.Quests[iLogId].NeedExplore then Exit;
  for iX := 0 to QUEST_OBJECTS_COUNT - 1 do
  begin
    if fActiveQuests.Quests[iLogId].KillObjectives[iX] <> fActiveQuestsInfos[iLogId].Template.KillObjectiveMob.Objects[iX].Count then
    begin
      Exit;
    end;
  end;
  for iX := 0 to QUEST_OBJECTS_COUNT - 1 do
  begin
    with fActiveQuestsInfos[iLogId] do
    begin
      if DeliverObjectivesStatus[iX] < Template.DeliverObjective.Objects[iX].Count then
      begin
        Exit;
      end;
    end;
  end;
  Result := True;
end;

function YGaQuestMgr.GetFinishDialogStatus(iLogId: Int32): UInt32;
begin
  if IsWaitingForReward(iLogId) then
    Result := DIALOG_STATUS_REWARD//DIALOG_STATUS_REWARD_REP
  else
    Result := DIALOG_STATUS_INCOMPLETE;
end;

function YGaQuestMgr.GetLogId(iQuestId: UInt32): Int32;
var
  iX: UInt32;
begin
  iX := 0;
  while (iX < QUEST_LOG_COUNT) do
  begin
    if iQuestId = fActiveQuests.Quests[iX].Id then
    begin
      Result := iX;
      Exit;
    end;
    Inc(iX);
  end;
  Result := - 1;
end;

{function YQuestMgr.GetFinishQuestStatus(iLogId: Int32): UInt32;
begin
  if IsWaitingForReward(iLogId) then
    Result := QUEST_STATUS_COMPLETE
  else
    Result := QUEST_STATUS_INCOMPLETE;
end;}

procedure YGaQuestMgr.AddToFinishedQuests(iQuestId: UInt32);
var
  iCount: Int32;
begin
  if not IsFinishedQuest(iQuestId) then
  begin
    iCount := Length(fFinishedQuests);
    SetLength(fFinishedQuests, iCount + 1);
    fFinishedQuests[iCount] := iQuestId;
  end;
end;

procedure YGaQuestMgr.Remove(iQuestLogId: UInt32);
var
  iX, iBaseIndex: Int32;
begin
  for iX := 0 to QUEST_OBJECTS_COUNT - 1 do
  begin
    fActiveQuests.Quests[iQuestLogId].KillObjectives[iX] := 0;
  end;

  fActiveQuests.Quests[iQuestLogId].NeedExplore := False;
  with fActiveQuestsInfos[iQuestLogId] do
  begin
    for iX := 0 to QUEST_OBJECTS_COUNT - 1 do
    begin
      DeliverObjectivesStatus[iX] := 0;
    end;
    DataCore.QuestTemplates.ReleaseEntry(Template);
  end;
  fActiveQuests.Quests[iQuestLogId].Id := 0;
  Dec(fActiveQuests.Count);
  iBaseIndex := PLAYER_QUEST_LOG_1_1 + iQuestLogId * 3;
  Owner.SetUInt32(iBaseIndex, 0);
  Owner.SetUInt32(iBaseIndex + 1, 0);
  Owner.SetUInt32(iBaseIndex + 2, 0);
end;

procedure YGaQuestMgr.UpdateDeliver(iItemId, iCount: UInt32);
var
  iX, iY: Int32;
  cOutPkt: YNwServerPacket;
begin
  iX := 0;
  while (iX < QUEST_LOG_COUNT) do with fActiveQuestsInfos[iX] do
  begin
    if not Assigned(Template) then
    begin
      Inc(iX);
      Continue;
    end;
    iY := 0;
    while iY < Template.DeliverObjective.Count do
    begin
      if (Template.DeliverObjective.Objects[iY].Id = iItemId)
        and (DeliverObjectivesStatus[iY] < Template.DeliverObjective.Objects[iY].Count) then
      begin
        Inc(fActiveQuestsInfos[iX].DeliverObjectivesStatus[iY], iCount);
        cOutPkt := YNwServerPacket.Initialize(SMSG_QUESTUPDATE_ADD_ITEM);
        try
          with cOutPkt do
          begin
            AddUInt32(iItemId);
            AddUInt32(iCount);
          end;
          SendPacket(cOutPkt);
        finally
          cOutPkt.Free;
        end;
      end;
      Inc(iY);
    end;
    Inc(iX);
  end;
end;

procedure YGaQuestMgr.UpdateKillObject(iId: UInt32; iGuid: UInt64);
var
  iX, iY: Int32;
  iQuestId, iOldCount, iKillRequired, iBaseIndex: UInt32;
  cOutPkt: YNwServerPacket;
begin
  iX := 0;
  while (iX < QUEST_LOG_COUNT) do with fActiveQuestsInfos[iX] do
  begin
    if not Assigned(Template) then
    begin
      Inc(iX);
      Continue;
    end;
    iQuestId := fActiveQuests.Quests[iX].Id;
    iY := 0;
    while iY < Template.KillObjectiveMob.Count do
    begin
      iKillRequired := Template.KillObjectiveMob.Objects[iY].Count;
      if (Template.KillObjectiveMob.Objects[iY].Id = iId)
        and (fActiveQuests.Quests[iX].KillObjectives[iY] < iKillRequired) then
      begin
        cOutPkt := YNwServerPacket.Initialize(SMSG_QUESTUPDATE_ADD_KILL);
        try
          with cOutPkt do
          begin
            AddUInt32(iQuestId);
            AddUInt32(iID);
            iOldCount := fActiveQuests.Quests[iX].KillObjectives[iY];
            Inc(fActiveQuests.Quests[iX].KillObjectives[iY]);
            AddUInt32(fActiveQuests.Quests[iX].KillObjectives[iY]);
            AddUInt32(iKillRequired);
            AddUInt64(iGuid);
          end;
          SendPacket(cOutPkt);
        finally
          cOutPkt.Free;
        end;
        iBaseIndex := PLAYER_QUEST_LOG_1_1 + iX * 3 + 1;
        Owner.SetUInt32(iBaseIndex, iOldCount + 1 + UInt32(iY)*6); //not correct?
        Exit;
      end;
      Inc(iY);
    end;
    Inc(iX);
  end;
end;

{ YGMMgr }

procedure YGaGMMgr.CleanupObjectData;
begin
end;

procedure YGaGMMgr.ExtractObjectData(cEntry: YDbSerializable);
var
  cPlr: YDbPlayerEntry;
begin
  cPlr := YDbPlayerEntry(cEntry);
  fTPPlaces := cPlr.TPPlaces;
  SetLength(fTPPlaces, 4);
  with fTPPlaces[0] do
  begin
    Name := 'NORTHSHIRE';
    Map := 0;
    X := -8896.16;
    Y := -179.328;
    Z := 80.2909;
  end;
  with fTPPlaces[1] do
  begin
    Name := 'WESTFALL';
    Map := 0;
    X := -10546.9;
    Y := 1197.24;
    Z := 31.7263;
  end;
  with fTPPlaces[2] do
  begin
    Name := 'DEADMINES';
    Map := 36;
    X := -16.40;
    Y := -383.07;
    Z := 61.78;
  end;
  with fTPPlaces[3] do
  begin
    Name := 'FARGODEEP';
    Map := 0;
    X := -9815.75;
    Y := 182.52;
    Z := 22.70;
  end;
end;

procedure YGaGMMgr.InjectObjectData(cEntry: YDbSerializable);
var
  cPlr: YDbPlayerEntry;
begin
  cPlr := YDbPlayerEntry(cEntry);
  cPlr.TPPlaces := fTPPlaces;
end;

procedure YGaGMMgr.SetTP(sName: string);
var
  iX, iCount: Int32;
  pVect: PVector;
begin
  iX := 0;
  iCount := Length(fTPPlaces);
  while (iX < iCount) and (fTPPlaces[iX].Name <> sName) do
    Inc(iX);
  if iX = iCount then
    SetLength(fTPPlaces, iCount + 1);
  pVect := @Owner.Position.Vector;
  with fTPPlaces[iX] do
  begin
    Name := UpperCase(sName);
    Map := Owner.Position.MapId;
    X := pVect^.X;
    Y := pVect^.Y;
    Z := pVect^.Z;
  end;
end;

procedure YGaGMMgr.RemTP(iX: Int32);
var
  iNewCount: Int32;
begin
  iNewCount := Length(fTPPlaces) - 1;
  if iX < iNewCount then
    Move(fTPPlaces[iX + 1], fTPPlaces[iX], (iNewCount - iX)*SizeOf(YTPPlace));
  SetLength(fTPPlaces, iNewCount);
end;

{ **************************************************************************** }
{ Procedure which initializes the command table }
procedure InitializePlayerCommandHandlers;
const
  { Basic syntax definition }
  SEP = ' ';
  S_NO = '(No parameters expected)';
  S_INT = '<Integer>';
  S_STR = '<String>';
  S_FLT = '<Float>';
  S_INT_O = '[Integer]';
  S_STR_O = '[String]';
  S_FLT_O = '[Float]';
  S_MULT = 'N';

  { All help context put here! }
  HELP_CTX_NONE = 'There is no information available on this command, please consult the administrators.';
  HELP_CTX_HELP = 'Shows more detailed description of commands specified.';
  HELP_CTX_LIST = 'Lists all avaiable commands for your account level.';
  HELP_CTX_SYNTAX = 'Displays the syntax for the specified commands.';
  HELP_CTX_ONLINE = 'Shows you the total number of players online.';
  HELP_CTX_ADD = 'Adds an item or more into your bag.';
  HELP_CTX_SETSPEED = 'Sets your speed to a new constant. Use ".setspeed default" to set its default value';
  HELP_CTX_HONOR = 'Simulates that you killed some oponent with random option like level difference, his rank, etc';
  HELP_CTX_EQUIPME = 'Equips you with some hardcoded items, usually for test purposes.';
  HELP_CTX_SUICIDE = 'Drops your health to 1, almost killing you.';
  HELP_CTX_HEAL = 'Heals yourself for X damage.';
  HELP_CTX_MEUPDI = 'Changes an integer update field. WARNING: Developer only!';
  HELP_CTX_MEUPDF = 'Changes a float update field. WARNING: Developer only!';
  HELP_CTX_SETBIT = 'Sets a specified bit in a value set [UFF, UNF, PB, PB2, PB3, PFB, PFB2, UFB1, UFB2]. WARNING: Developer only!';
  HELP_CTX_UNSETBIT = 'Unsets a specified bit in a value set [UFF, UNF, PB, PB2, PB3, PFB, PFB2, UFB1, UFB2]. WARNING: Developer only!';
  HELP_CTX_TESTBIT = 'Tests a specified bit in a value set [UFF, UNF, PB, PB2, PB3, PFB, PFB2, UFB1, UFB2]. WARNING: Developer only!';
  HELP_CTX_DISCMD = 'Disables a command which can be enabled using .ENCMD.';
  HELP_CTX_ENCMD = 'Enables a previously disabled command using .DISCMD.';
  HELP_CTX_SAVE =
    'Saves the whole DB to disk. Optional parameter specifies if the server save ' +
    'timer should be refreshed (by default yes).';
  HELP_CTX_WARP = 'Teleports you to a desired location (Map, X, Y, Z).';
  HELP_CTX_GPS = 'Shows you the current location (Map and X, Y, Z coordinates).';
  HELP_CTX_LEVELUP = 'Adds you one or more levels.';
  HELP_CTX_MORPH = 'Turns you into model specified.';
  HELP_CTX_DEMORPH = 'Turns you into your original model.';
  HELP_CTX_SHOWMOUNT = 'Graphicly mounts you on mount model you specify.';
  HELP_CTX_HIDEMOUNT = 'Graphicly dismounts you from a mount.';
  HELP_CTX_WARPTO = 'Teleports you to a player. (name is case IN-sensitive)';
  HELP_CTX_BROADCAST = 'Displays a message to all players. Message must be enclosed with quotes(").';
  HELP_CTX_CLOAK = 'Hides you before all other players. (untested)';
  HELP_CTX_UNCLOAK = 'Makes you visible again before all other players. (untested)';

  HELP_CTX_NEWNODE =
    'Creates a node at your location and returns you its ID. You may use this ID ' +
    'to change the properties of this new node.';
  HELP_CTX_DELNODE =
    'Deletes a node specified by index. The node is automaticly unregistered/unlinked and spawns ' +
    'are removed.';
  HELP_CTX_ADDSPAWN =
    'Adds a new spawn entry to the specified node. Returns the ID ' +
    'of this entry in spawn''s entry table. You may use this ID to change or remove this entry.';
  HELP_CTX_REMSPAWN =
    'Removes a spawn entry identified by spawn entry table id.';
  HELP_CTX_SETPASS =
    'Sets or Resets yout account password.';
  HELP_CTX_HEIGHTQUERY =
    'Queries the height of a specified point or of your position. WARNING: Developer only!';
  HELP_CTX_KILL = 'Kills the selected creature.';
  HELP_CTX_SET_TP = 'Set a TP place';
  HELP_CTX_LIST_TP = 'Go to a TP place';
  HELP_CTX_GO_TP = 'Lists all TP places';
  HELP_CTX_REM_TP = 'Remove a TP place';
  { Concreate command syntaxes }
  SYN_HELP = S_MULT + S_STR_O;
  SYN_LIST = S_NO;
  SYN_HONOR = S_NO;
  SYN_EQUIPME = S_NO;
  SYN_SYNTAX = S_MULT + S_STR_O;
  SYN_ONLINE = S_NO;
  SYN_ADD = S_INT + SEP + S_INT_O;
  SYN_SETSPEED = S_INT;
  SYN_SUICIDE = S_NO;
  SYN_HEAL = S_INT;
  SYN_MOVE = S_FLT + SEP + S_FLT;
  SYN_MEUPDI = S_INT + SEP + S_INT;
  SYN_MEUPDF = S_INT + SEP + S_FLT;
  SYN_UBIT = S_INT + SEP + S_INT;
  SYN_DISCMD = S_STR;
  SYN_ENCMD = S_STR;
  SYN_SAVE = S_INT_O;
  SYN_WARP = S_INT + SEP + S_FLT + SEP + S_FLT + SEP + S_FLT;
  SYN_GPS = S_NO;
  SYN_LEVELUP = S_INT_O;
  SYN_MORPH = S_NO;
  SYN_DEMORPH = S_NO;
  SYN_SHOWMOUNT = S_INT;
  SYN_HIDEMOUNT = S_NO;
  SYN_WARPTO = S_STR;
  SYN_BROADCAST = S_STR + SEP + S_INT_O;
  SYN_CLOAK = S_NO;
  SYN_UNCLOAK = S_NO;
  SYN_NEWNODE = S_NO;
  SYN_DELNODE = S_INT_O;
  SYN_ADDSPAWN = S_INT_O + SEP + S_INT + SEP + S_FLT + SEP + S_FLT + SEP + S_INT + SEP + S_INT;
  SYN_REMSPAWN = S_INT_O + SEP + S_INT;
  SYN_SETPASS = S_STR;
  SYN_HEIGHTQUERY = S_INT_O + SEP + S_FLT_O + SEP + S_FLT_O;
  SYN_KILL = S_NO;
  SYN_SET_TP = S_STR;
  SYN_GO_TP = S_STR;
  SYN_LIST_TP = S_NO;
  SYN_REM_TP = S_STR;
begin
  { Root command declarations put here! }
  GameCore.CommandHandler.AddRootCommand(['SET'], HELP_CTX_NONE);
  GameCore.CommandHandler.AddRootCommand(['GET'], HELP_CTX_NONE);
  GameCore.CommandHandler.AddRootCommand(['ADD'], HELP_CTX_NONE);
  GameCore.CommandHandler.AddRootCommand(['REM'], HELP_CTX_NONE);

  { Concrete command declarations put here! }
  GameCore.CommandHandler.AddCommandHandler(['HELP'], @YGaChatMgr.CommandHelp, PARAMS_UNLIMITED, HELP_CTX_HELP, SYN_HELP, []);
  GameCore.CommandHandler.AddCommandHandler(['LIST'], @YGaChatMgr.CommandList, PARAMS_NONE, HELP_CTX_LIST, SYN_LIST, []);
  GameCore.CommandHandler.AddCommandHandler(['SYNTAX'], @YGaChatMgr.CommandSyntax, PARAMS_UNLIMITED, HELP_CTX_SYNTAX, SYN_SYNTAX, []);
  GameCore.CommandHandler.AddCommandHandler(['ONLINE'], @YGaChatMgr.CommandOnline, PARAMS_NONE, HELP_CTX_ONLINE, SYN_ONLINE, []);
  GameCore.CommandHandler.AddCommandHandler(['HONOR'], @YGaChatMgr.CommandDbgHonor, PARAMS_NONE, HELP_CTX_HONOR, SYN_HONOR, []);
  GameCore.CommandHandler.AddCommandHandler(['SUICIDE'], @YGaChatMgr.CommandDbgSuicide, PARAMS_NONE, HELP_CTX_SUICIDE, SYN_SUICIDE, []);
  GameCore.CommandHandler.AddCommandHandler(['HEAL'], @YGaChatMgr.CommandDbgHealSelf, [1, 1], HELP_CTX_HEAL, SYN_HEAL, []);
  GameCore.CommandHandler.AddCommandHandler(['SAVE'], @YGaChatMgr.CommandSave, [0, 1], HELP_CTX_SAVE, SYN_SAVE, []);

  GameCore.CommandHandler.AddCommandHandler(['ADD', 'ITEM'], @YGaChatMgr.CommandAdd, [1, 2], HELP_CTX_ADD, SYN_ADD, []);
  GameCore.CommandHandler.AddCommandHandler(['SET', 'SPEED'], @YGaChatMgr.CommandSetSpeed, [0, 1], HELP_CTX_SETSPEED, SYN_SETSPEED, []);
  GameCore.CommandHandler.AddCommandHandler(['SET', 'PASS'], @YGaChatMgr.CommandSetPass,[1, 1], HELP_CTX_SETPASS, SYN_SETPASS, []);
  GameCore.CommandHandler.AddCommandHandler(['ADD', 'NODE'], @YGaChatMgr.CommandCreateNode, PARAMS_NONE, HELP_CTX_NEWNODE, SYN_NEWNODE, []);
  GameCore.CommandHandler.AddCommandHandler(['REM', 'NODE'], @YGaChatMgr.CommandDeleteNode, [1, 1], HELP_CTX_DELNODE, SYN_DELNODE, []);
  GameCore.CommandHandler.AddCommandHandler(['ADD', 'SPAWN'], @YGaChatMgr.CommandNodeAddSpawn, [5, 6], HELP_CTX_ADDSPAWN, SYN_ADDSPAWN, []);
  GameCore.CommandHandler.AddCommandHandler(['REM', 'SPAWN'], @YGaChatMgr.CommandNodeRemSpawn, [2, 2], HELP_CTX_REMSPAWN, SYN_REMSPAWN, []);
  GameCore.CommandHandler.AddCommandHandler(['GET', 'Z'], @YGaChatMgr.CommandQueryHeight, [0, 3], HELP_CTX_HEIGHTQUERY, SYN_HEIGHTQUERY, []);

  GameCore.CommandHandler.AddCommandHandler(['WARP'], @YGaChatMgr.CommandTeleport, [4, 4], HELP_CTX_WARP, SYN_WARP, []);
  GameCore.CommandHandler.AddCommandHandler(['WARPTO'], @YGaChatMgr.CommandTeleportTo,[1, 1], HELP_CTX_WARPTO, SYN_WARPTO, []);
  GameCore.CommandHandler.AddCommandHandler(['GPS'], @YGaChatMgr.CommandGPS, PARAMS_NONE, HELP_CTX_GPS, SYN_GPS, []);
  GameCore.CommandHandler.AddCommandHandler(['LEVELUP'], @YGaChatMgr.CommandLevelUp, [0, 1], HELP_CTX_LEVELUP, SYN_LEVELUP, []);
  GameCore.CommandHandler.AddCommandHandler(['MORPH'], @YGaChatMgr.CommandMorph, [1, 1], HELP_CTX_MORPH, SYN_MORPH, []);
  GameCore.CommandHandler.AddCommandHandler(['DEMORPH'], @YGaChatMgr.CommandDeMorph, PARAMS_NONE, HELP_CTX_DEMORPH, SYN_DEMORPH, []);
  GameCore.CommandHandler.AddCommandHandler(['SHOWMOUNT'], @YGaChatMgr.CommandShowMount, [1, 1], HELP_CTX_SHOWMOUNT, SYN_SHOWMOUNT, []);
  GameCore.CommandHandler.AddCommandHandler(['HIDEMOUNT'], @YGaChatMgr.CommandHideMount, PARAMS_NONE, HELP_CTX_HIDEMOUNT, SYN_HIDEMOUNT, []);
  //GameCore.CommandHandler.AddCommandHandler('BROADCAST', CommandBroadcast, [1, 1], HELP_CTX_BROADCAST, SYN_BROADCAST, []);
  //GameCore.CommandHandler.AddCommandHandler('CLOAK', CommandMakeInvisible, PARAMS_NONE, HELP_CTX_CLOAK, SYN_CLOAK, []);
  //GameCore.CommandHandler.AddCommandHandler('UNCLOAK', CommandMakeVisible, PARAMS_NONE, HELP_CTX_UNCLOAK, SYN_UNCLOAK, []);
  GameCore.CommandHandler.AddCommandHandler(['EQUIPME'], @YGaChatMgr.CommandDbgEquipmeWithItems, PARAMS_NONE, HELP_CTX_EQUIPME, SYN_EQUIPME, []);
  //GameCore.CommandHandler.AddCommandHandler(['MOVEME'], CommandDebugMove, [2, 2], HELP_CTX_NONE, SYN_MOVE, []);
  GameCore.CommandHandler.AddCommandHandler(['MEUPDI'], @YGaChatMgr.CommandDbgSetUpdateFieldI, [2, 2], HELP_CTX_MEUPDI, SYN_MEUPDI, []);
  GameCore.CommandHandler.AddCommandHandler(['MEUPDF'], @YGaChatMgr.CommandDbgSetUpdateFieldF, [2, 2], HELP_CTX_MEUPDF, SYN_MEUPDF, []);
  GameCore.CommandHandler.AddCommandHandler(['SETBIT'], @YGaChatMgr.CommandSetUnitFlagBits, [2, 2], HELP_CTX_SETBIT, SYN_UBIT, []);
  GameCore.CommandHandler.AddCommandHandler(['UNSETBIT'], @YGaChatMgr.CommandUnSetUnitFlagBits, [2, 2], HELP_CTX_UNSETBIT, SYN_UBIT, []);
  GameCore.CommandHandler.AddCommandHandler(['TESTBIT'], @YGaChatMgr.CommandTestUnitFlagBits, [2, 2], HELP_CTX_TESTBIT, SYN_UBIT, []);
  GameCore.CommandHandler.AddCommandHandlerRaw(['DISCMD'], @YGaChatMgr.CommandDisableCommand, [1, 1], HELP_CTX_DISCMD, SYN_DISCMD, []);
  GameCore.CommandHandler.AddCommandHandlerRaw(['ENCMD'], @YGaChatMgr.CommandEnableCommand, [1, 1], HELP_CTX_ENCMD, SYN_ENCMD, []);
  GameCore.CommandHandler.AddCommandHandler(['KILL'], @YGaChatMgr.CommandKill, PARAMS_NONE, HELP_CTX_KILL, SYN_KILL, []);
  //GameCore.CommandHandler.AddCommandHandler(['SET', 'TP'], @YGaChatMgr.CommandSetTp, [1, 1], HELP_CTX_SET_TP, SYN_SET_TP, []);
  //GameCore.CommandHandler.AddCommandHandler(['GOTP'], @YGaChatMgr.CommandGoTP, [1, 1], HELP_CTX_GO_TP, SYN_GO_TP, []);
  //GameCore.CommandHandler.AddCommandHandler(['LISTTP'], @YGaChatMgr.CommandListTP, PARAMS_NONE, HELP_CTX_LIST_TP, SYN_LIST_TP, []);
  //GameCore.CommandHandler.AddCommandHandler(['REM', 'TP'], @YGaChatMgr.CommandRemTP, [1, 1], HELP_CTX_REM_TP, SYN_REM_TP, []);
  GameCore.CommandHandler.AddCommandHandler(['MOVETARGET'], @YGaChatMgr.CommandStartMovement, PARAMS_NONE, HELP_CTX_NONE, S_NO, []);
end;

end.
