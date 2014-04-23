

unit Components.DataCore;
{$I compiler.inc}
interface

uses
  Framework.Base,
  Framework.Tick,
  Framework.ThreadManager,
  Framework.LogManager,
  Framework.Configuration,
  Components.Shared,
  Components.DataCore.DynamicObjectFormat,
  Components.DataCore.Types,
  Components.DataCore.WorldData.Loader,
  Components.DataCore.WorldData.Types,
  Components.GameCore.Constants,
  Bfg.Utils,
  Bfg.Containers,
  Bfg.Threads,
  Bfg.Metadata,
  Bfg.Unicode,
  SysUtils,
  Classes,
  Components,
  WideStrings;

const
  DECACHE_TIME = 1000 * 60 * 5; { 5 minutes }

  COMPARE_OP_LE    = 0; // Lesser
  COMPARE_OP_LEQ   = 1; // Lesser of equal
  COMPARE_OP_EQ    = 2; // Equal
  COMPARE_OP_NEQ   = 3; // Not equal
  COMPARE_OP_GEQ   = 4; // Greater or equal
  COMPARE_OP_GE    = 5; // Greater

type
  PDecacheParams = ^YDecacheParams;
  YDecacheParams = record
  end;

  PSerializable = ^ISerializable;

  ILookupResult = interface(IInterface)
  ['{37D64B59-60A3-4805-9090-B30447420F63}']
    function GetEntryCount: Integer; stdcall;

    function GetData(out Entries; Count: Integer): Integer; stdcall;
    function GetDataEx(out Entries; Count: Integer; const AsTypeIID: TGUID): Integer; stdcall;

    property EntryCount: Integer read GetEntryCount;
  end;

  TCompareOp = COMPARE_OP_LE..COMPARE_OP_GE;

  YES_PREDICATE_CALLBACK = function(Context: Pointer; Item: Pointer): Boolean; stdcall;

  IStorageMedium = interface(IInterface)
  ['{77DF05B5-001A-4651-83E3-EF84D5B444D2}']
    procedure Initialize(const Metadata: ITypeInfo; const GUID: TGUID;
      Args: PAnsiChar); stdcall;

    procedure Load; stdcall;
    procedure Save; stdcall;
    procedure ThreadSafeSave; stdcall;

    procedure DeleteEntry(Id: Longword); stdcall;
    procedure DeleteEntries(Ids: PLongword; Count: Integer); stdcall;

    procedure SaveEntry(const Entry: ISerializable; Release: Boolean = True); stdcall;
    procedure SaveEntries(const Entries; Count: Integer; Release: Boolean = True); stdcall;

    procedure CreateEntry(out Entry); stdcall;
    procedure CreateEntries(out Entries; Count: Integer); stdcall;

    procedure AcquireEntry(out Entry); stdcall;
    procedure AcquireEntries(out Entries; Count: Integer); stdcall;

    procedure ReleaseEntry(const Entry: ISerializable); stdcall;
    procedure ReleaseEntries(const Entries; Count: Integer); stdcall;

    procedure LookupEntry(Id: Longword; out Entry); stdcall;

    procedure LookupEntryList(Field: PAnsiChar; CmpValue: Longword; CmpOp: TCompareOp; out Result: ILookupResult; ResultOwnsEntries: Boolean = True); overload; stdcall;
    procedure LookupEntryList(Field: PAnsiChar; CmpValue: PAnsiChar; CaseSensitive: Boolean; out Result: ILookupResult; ResultOwnsEntries: Boolean = True); overload; stdcall;
    procedure LookupEntryList(Field: PAnsiChar; CmpValue: PWideChar; CaseSensitive: Boolean; out Result: ILookupResult; ResultOwnsEntries: Boolean = True); overload; stdcall;
    procedure LookupEntryList(Field: PAnsiChar; CmpValue: Float; CmpOp: TCompareOp; Epsilon: Float; out Result: ILookupResult; ResultOwnsEntries: Boolean = True); overload; stdcall;

    function GetEntryCount: Integer; stdcall;
    function GetName: PChar; stdcall;

    property EntryCount: Integer read GetEntryCount;
    property Name: PChar read GetName;
  end;

  IDataCore = interface(IInterface)
  ['{BF7B6578-C809-4CFB-81BF-4FA48E0F839C}']
    procedure RegisterContextClass(const ClassInfo: ITypeInfo); stdcall;
    procedure RegisterContextClassAlias(const ClassInfo: ITypeInfo; Alias: PAnsiChar); stdcall;
    procedure UnregisterContextClass(const ClassInfo: ITypeInfo); stdcall;

    procedure CreateDofReader(out Reader: IDofReader); stdcall;
    procedure CreateDofWriter(out Writer: IDofWriter); stdcall;

    procedure CreateStorage(StorageType: PChar; out Storage: IStorageMedium); stdcall;

    function GetAccountStorage: IStorageMedium; stdcall;
    function GetPlayerStorage: IStorageMedium; stdcall;
    function GetItemStorage: IStorageMedium; stdcall;
    function GetNodeStorage: IStorageMedium; stdcall;
    function GetTimerStorage: IStorageMedium; stdcall;
    function GetAddonStorage: IStorageMedium; stdcall;
    function GetPlayerTemplateStorage: IStorageMedium; stdcall;
    function GetItemTemplateStorage: IStorageMedium; stdcall;
    function GetQuestTemplateStorage: IStorageMedium; stdcall;
    function GetCreatureTemplateStorage: IStorageMedium; stdcall;
    function GetGameObjectTemplateStorage: IStorageMedium; stdcall;

    property Accounts: IStorageMedium read GetAccountStorage;
    property Players: IStorageMedium read GetPlayerStorage;
    property Items: IStorageMedium read GetItemStorage;
    property Nodes: IStorageMedium read GetNodeStorage;
    property Timers: IStorageMedium read GetTimerStorage;
    property Addons: IStorageMedium read GetAddonStorage;
    property PlayerTemplates: IStorageMedium read GetPlayerTemplateStorage;
    property ItemTemplates: IStorageMedium read GetItemTemplateStorage;
    property QuestTemplates: IStorageMedium read GetQuestTemplateStorage;
    property CreatureTemplates: IStorageMedium read GetCreatureTemplateStorage;
    property GameObjectTemplates: IStorageMedium read GetGameObjectTemplateStorage;
  end;

  PDbLayerPluginInfo = ^TDbLayerPluginInfo;
  TDbLayerPluginInfo = record
    Module: HMODULE;
    FileName: WideString;
    Ident: WideString;
    References: Integer;
    CreateDatabaseLayerInstanceProc: procedure(out Db: IStorageMedium); stdcall;
  end;

  YDbStorageMediumWrapper = class;

  YDbCharTemplateStore = class(TInterfacedObject)
    private
      FStorage: YDbStorageMediumWrapper;
    public
      constructor Create(const Storage: YDbStorageMediumWrapper);

      procedure UpdateTemplate(const Template, By: IPlayerTemplateEntry);
      function CombineTemplate(PlrRace: YGameRace; PlrClass: YGameClass): IPlayerTemplateEntry;
      property Medium: YDbStorageMediumWrapper read FStorage;
    end;

  YDbStorageMediumWrapper = class(TObject)
    private
      FMedium: IStorageMedium;
      FName: AnsiString;

      function GetEntryCount: Integer;
    public
      constructor Create(const Provider: IStorageMedium);

      procedure Initialize(const Metadata: ITypeInfo; const GUID: TGUID;
        const Args: AnsiString);

      procedure Load;
      procedure Save;
      procedure ThreadSafeSave;

      procedure DeleteEntry(Id: Longword);
      procedure DeleteEntries(const Ids: array of Longword);

      procedure SaveEntry(const Entry: ISerializable; Release: Boolean = True);
      procedure SaveEntries(const Entries; Count: Integer; Release: Boolean = True);

      procedure CreateEntry(out Entry);
      procedure CreateEntries(out Entries; Count: Integer);

      procedure AcquireEntry(out Entry);
      procedure AcquireEntries(out Entries; Count: Integer);

      procedure ReleaseEntry(const Entry: ISerializable);
      procedure ReleaseEntries(const Entries; Count: Integer);

      procedure LookupEntry(Id: Longword; out Entry);

      procedure LookupEntryListL(const Field: AnsiString; CmpValue: Longword; CmpOp: TCompareOp; out Result: ILookupResult; ResultOwnsEntries: Boolean = True); overload; stdcall;
      procedure LookupEntryListA(const Field: AnsiString; const CmpValue: AnsiString; CaseSensitive: Boolean; out Result: ILookupResult; ResultOwnsEntries: Boolean = True); overload; stdcall;
      procedure LookupEntryListW(const Field: AnsiString; const CmpValue: WideString; CaseSensitive: Boolean; out Result: ILookupResult; ResultOwnsEntries: Boolean = True); overload; stdcall;
      procedure LookupEntryListF(const Field: AnsiString; CmpValue: Float; CmpOp: TCompareOp; Epsilon: Float; out Result: ILookupResult; ResultOwnsEntries: Boolean = True); overload; stdcall;

      property EntryCount: Integer read GetEntryCount;
      property Name: AnsiString read FName;
      property WrappedObject: IStorageMedium read FMedium;
  end;

  YDataCore = class(YBaseCore)
    private
      FRegisteredContextClasses: TStrIntfHashMap;
      FDecacheHandle: TEventHandle;
      FBeingSaved: Longbool;
      FSynchLock: TEvent;

      FWorldDataLoader: YDbWorldDataLoader;

      FAccountMedium: YDbStorageMediumWrapper;
      FPlayerMedium: YDbStorageMediumWrapper;
      FItemMedium: YDbStorageMediumWrapper;
      FNodeMedium: YDbStorageMediumWrapper;
      FAddonMedium: YDbStorageMediumWrapper;
      FTimerMedium: YDbStorageMediumWrapper;

      FPlayerTemplateMedium: YDbStorageMediumWrapper;
      FPlayerTemplateStore: YDbCharTemplateStore;

      FItemTemplateMedium: YDbStorageMediumWrapper;
      FQuestTemplateMedium: YDbStorageMediumWrapper;
      FNPCTextTemplateMedium: YDbStorageMediumWrapper;
      FCreatureTemplateMedium: YDbStorageMediumWrapper;
      FGameObjectTemplateMedium: YDbStorageMediumWrapper;

      FProfanityList: TWideStringList;
      FReservedNameList: TWideStringList;

      FDatabaseLayerPlugins: array of TDbLayerPluginInfo;

      procedure LoadProfanityList;
      procedure LoadReservedNameList;
      procedure LoadDbLayerIdentList;
      procedure UnloadDbLayerPlugins;

      procedure CreateDatabaseInstance(Ident: WideString; out Storage: YDbStorageMediumWrapper);

      procedure OnDBDecache(Event: TEventHandle; TimeDelta: UInt32);
      procedure PerformSave(const Params: YDecacheParams);

      procedure FindContextClassInfo(const ClassName: string; out Info: ITypeInfo);
    protected
      procedure CoreInitialize; override;
      procedure CoreStart; override;
      procedure CoreStop; override;
    public
      function FullSave(RefreshTimer: Boolean): Boolean;

      procedure RegisterContextClass(const ClassInfo: ITypeInfo); stdcall;
      procedure RegisterContextClassAlias(const ClassInfo: ITypeInfo; Alias: PChar); stdcall;
      procedure UnregisterContextClass(const ClassInfo: ITypeInfo); stdcall;

      procedure CreateDofReader(out Reader: IDofReader); stdcall;
      procedure CreateDofWriter(out Writer: IDofWriter); stdcall;

      procedure CreateStorage(StorageType: PChar; out Storage: IStorageMedium); stdcall;

      function GetAccountStorage: IStorageMedium; stdcall;
      function GetPlayerStorage: IStorageMedium; stdcall;
      function GetItemStorage: IStorageMedium; stdcall;
      function GetNodeStorage: IStorageMedium; stdcall;
      function GetTimerStorage: IStorageMedium; stdcall;
      function GetAddonStorage: IStorageMedium; stdcall;
      function GetPlayerTemplateStorage: IStorageMedium; stdcall;
      function GetItemTemplateStorage: IStorageMedium; stdcall;
      function GetQuestTemplateStorage: IStorageMedium; stdcall;
      function GetCreatureTemplateStorage: IStorageMedium; stdcall;
      function GetGameObjectTemplateStorage: IStorageMedium; stdcall;

      property Accounts: YDbStorageMediumWrapper read FAccountMedium;
      property Players: YDbStorageMediumWrapper read FPlayerMedium;
      property Items: YDbStorageMediumWrapper read FItemMedium;
      property Nodes: YDbStorageMediumWrapper read FNodeMedium;
      property Timers: YDbStorageMediumWrapper read FTimerMedium;
      property Addons: YDbStorageMediumWrapper read FAddonMedium;
      property PlayerTemplates: YDbCharTemplateStore read FPlayerTemplateStore;
      property ItemTemplates: YDbStorageMediumWrapper read FItemTemplateMedium;
      property QuestTemplates: YDbStorageMediumWrapper read FQuestTemplateMedium;
      property CreatureTemplates: YDbStorageMediumWrapper read FCreatureTemplateMedium;
      property GameObjectTemplates: YDbStorageMediumWrapper read FGameObjectTemplateMedium;

      property WorldData: YDbWorldDataLoader read FWorldDataLoader;

      property ProfanityList: TWideStringList read FProfanityList;
      property ReservedNameList: TWideStringList read FReservedNameList;
    end;

implementation

uses
  Main,
  Resources,
  Bfg.Classes,
  MMSystem,
  Windows,
  Cores,
  TypInfo,
  Framework;

{ YDataCore }

//------------------------------------------------------------------------------
// DataCore Initialization
//------------------------------------------------------------------------------

procedure YDataCore.CoreInitialize;
var
  TInfo: ITypeInfo;
  Options: AnsiString;
begin
  FRegisteredContextClasses := TStrIntfHashMap.Create(False, 1024);
  FSynchLock.Init(False, False);

  LoadDbLayerIdentList;

  try
  //------------------------------------------------------------------------------
  // [1] DataCore - Loading Char Templates
  //------------------------------------------------------------------------------
    IoCore.Console.WriteLoadOf('TEMPLATE: Players');

    try
      CreateTypeInfoFromDelphiRTTI(TypeInfo(YDbPlayerTemplate), TInfo);
      Options := WideStringToUTF8(SysConf.ReadStringN('Data', 'PlayerTemplateDBInfo'));
      CreateDatabaseInstance(SysConf.ReadStringN('Data',
        'PlayerTemplateDBType'), FPlayerTemplateMedium);
      FPlayerTemplateMedium.Initialize(TInfo, IPlayerTemplateEntry, PAnsiChar(Options));
      FPlayerTemplateMedium.Load;
      
      IoCore.Console.WriteSuccessWithData(itoa(FPlayerTemplateMedium.GetEntryCount) + ' Player Templates');
    except
      on Exception{EFileLoadError} do
      begin
        IoCore.Console.WriteFailureWithData(RsDataCoreLoadErr);
      end;
    else
      raise;
    end;
    FPlayerTemplateStore := YDbCharTemplateStore.Create(FPlayerTemplateMedium);

  //------------------------------------------------------------------------------
  // [2] DataCore - Loading Item Templates
  //------------------------------------------------------------------------------
    IoCore.Console.WriteLoadOf('TEMPLATE: Items');

    try
      CreateTypeInfoFromDelphiRTTI(TypeInfo(YDbItemTemplate), TInfo);
      Options := WideStringToUTF8(SysConf.ReadStringN('Data', 'ItemTemplateDBInfo'));
      CreateDatabaseInstance(SysConf.ReadStringN('Data',
        'ItemTemplateDBType'), FItemTemplateMedium);
      FItemTemplateMedium.Initialize(TInfo, IItemTemplateEntry, PAnsiChar(Options));
      FItemTemplateMedium.Load;

      IoCore.Console.WriteSuccessWithData(itoa(FItemTemplateMedium.GetEntryCount) + ' Item Templates');
    except
      on Exception{EFileLoadError} do
      begin
        IoCore.Console.WriteFailureWithData(RsDataCoreLoadErr);
      end;
    else
      raise;
    end;

  //------------------------------------------------------------------------------
  // [3.] DataCore - Loading Creature Templates
  //------------------------------------------------------------------------------
    IoCore.Console.WriteLoadOf('TEMPLATE: Creatures');

    try
      CreateTypeInfoFromDelphiRTTI(TypeInfo(YDbCreatureTemplate), TInfo);
      Options := WideStringToUTF8(SysConf.ReadStringN('Data', 'CreatureTemplateDBInfo'));
      CreateDatabaseInstance(SysConf.ReadStringN('Data',
        'CreatureTemplateDBType'), FCreatureTemplateMedium);
      FCreatureTemplateMedium.Initialize(TInfo, ICreatureTemplateEntry, PAnsiChar(Options));
      FCreatureTemplateMedium.Load;

      IoCore.Console.WriteSuccessWithData(itoa(FCreatureTemplateMedium.GetEntryCount) + ' Creature Templates');
    except
      on Exception{EFileLoadError} do
      begin
        IoCore.Console.WriteFailureWithData(RsDataCoreLoadErr);
      end;
    else
      raise;
    end;
     
  //------------------------------------------------------------------------------
  // [4.] DataCore - Loading Game Object Templates
  //------------------------------------------------------------------------------
    IoCore.Console.WriteLoadOf('TEMPLATE: Game Objects');

    try
      CreateTypeInfoFromDelphiRTTI(TypeInfo(YDbGameObjectTemplate), TInfo);
      Options := WideStringToUTF8(SysConf.ReadStringN('Data', 'GameObjectTemplateDBInfo'));
      CreateDatabaseInstance(SysConf.ReadStringN('Data',
        'GameObjectTemplateDBType'), FGameObjectTemplateMedium);
      FGameObjectTemplateMedium.Initialize(TInfo, IGameObjectTemplateEntry, PAnsiChar(Options));
      FGameObjectTemplateMedium.Load;

      IoCore.Console.WriteSuccessWithData(itoa(FGameObjectTemplateMedium.GetEntryCount) + ' Game Object Templates');
    except
      on Exception{EFileLoadError} do
      begin
        IoCore.Console.WriteFailureWithData(RsDataCoreLoadErr);
      end;
    else
      raise;
    end;

    (*
  //------------------------------------------------------------------------------
  // [5.] DataCore - Loading Quest Templates
  //------------------------------------------------------------------------------
    IoCore.Console.WriteLoadOf('TEMPLATE: Quests');

    try
      CreateDatabaseInstance(SystemConfiguration.ReadString('Data',
        'QuestTempateDBType', nil), FQuestTemplateMedium);
      FQuestTemplateMedium.Initialize(nil, 0, SystemConfiguration.ReadString('Data',
        'QuestTempateDBInfo', nil));
      FQuestTemplateMedium.Load;

      IoCore.Console.WriteSuccessWithData(itoa(FQuestTemplateMedium.GetEntryCount) + ' Quest Templates');
    except
      on EFileLoadError do
      begin
        IoCore.Console.WriteFailureWithData(RsDataCoreLoadErr);
      end;
    else
      raise;
    end;

  //------------------------------------------------------------------------------
  // [6.] DataCore - Loading NPC Text Templates
  //------------------------------------------------------------------------------
    IoCore.Console.WriteLoadOf('TEMPLATE: NPC Texts');

    try
      CreateDatabaseInstance(SystemConfiguration.ReadString('Data',
        'NPCTextTempateDBType', nil), FNPCTextTemplateMedium);
      FNPCTextTemplateMedium.Initialize(nil, 0, SystemConfiguration.ReadString('Data',
        'NPCTextTempateDBInfo', nil));
      FNPCTextTemplateMedium.Load;

      IoCore.Console.WriteSuccessWithData(itoa(FNPCTextTemplateMedium.GetEntryCount) + ' NPC Text Templates');
    except
      on EFileLoadError do
      begin
        IoCore.Console.WriteFailureWithData(RsDataCoreLoadErr);
      end;
    else
      raise;
    end;

  //------------------------------------------------------------------------------
  // [X.] DataCore - Loading XXXXXXXXXXXXX
  //------------------------------------------------------------------------------

    *)


  //------------------------------------------------------------------------------
  // DataCore - Loading Accounts and Objects
  //------------------------------------------------------------------------------
    IoCore.Console.WriteLoadOf('SAVES: Accounts');

    try
      CreateTypeInfoFromDelphiRTTI(TypeInfo(YDbAccountEntry), TInfo);
      Options := WideStringToUTF8(SysConf.ReadStringN('Data', 'AccountDBInfo'));
      CreateDatabaseInstance(SysConf.ReadStringN('Data',
        'AccountDBType'), FAccountMedium);
      FAccountMedium.Initialize(TInfo, IAccountEntry, PAnsiChar(Options));
      FAccountMedium.Load;

      IoCore.Console.WriteSuccessWithData(itoa(FAccountMedium.GetEntryCount) + ' Accounts');
    except
      on Exception{EFileLoadError} do
      begin
        IoCore.Console.WriteFailureWithData(RsDataCoreLoadErr);
      end;
    else
      raise;
    end;

    IoCore.Console.WriteLoadOf('SAVES: Players');

    try
      CreateTypeInfoFromDelphiRTTI(TypeInfo(YDbPlayerEntry), TInfo);
      Options := WideStringToUTF8(SysConf.ReadStringN('Data', 'PlayerDBInfo'));
      CreateDatabaseInstance(SysConf.ReadStringN('Data',
        'PlayerDBType'), FPlayerMedium);
      FPlayerMedium.Initialize(TInfo, IPlayerEntry, PAnsiChar(Options));
      FPlayerMedium.Load;

      IoCore.Console.WriteSuccessWithData(itoa(FPlayerMedium.GetEntryCount) + ' Players');
    except
      on Exception{EFileLoadError} do
      begin
        IoCore.Console.WriteFailureWithData(RsDataCoreLoadErr);
      end;
    else
      raise;
    end;

    IoCore.Console.WriteLoadOf('SAVES: Items');

    try
      CreateTypeInfoFromDelphiRTTI(TypeInfo(YDbItemEntry), TInfo);
      Options := WideStringToUTF8(SysConf.ReadStringN('Data', 'ItemDBInfo'));
      CreateDatabaseInstance(SysConf.ReadStringN('Data',
        'ItemDBType'), FItemMedium);
      FItemMedium.Initialize(TInfo, IItemEntry, PAnsiChar(Options));
      FItemMedium.Load;

      IoCore.Console.WriteSuccessWithData(itoa(FItemMedium.GetEntryCount) + ' Items');
    except
      on Exception{EFileLoadError} do
      begin
        IoCore.Console.WriteFailureWithData(RsDataCoreLoadErr);
      end;
    else
      raise;
    end;

    IoCore.Console.WriteLoadOf('SAVES: Nodes');

    try
      CreateTypeInfoFromDelphiRTTI(TypeInfo(YDbNodeEntry), TInfo);
      Options := WideStringToUTF8(SysConf.ReadStringN('Data', 'NodeDBInfo'));
      CreateDatabaseInstance(SysConf.ReadStringN('Data',
        'NodeDBType'), FNodeMedium);
      FNodeMedium.Initialize(TInfo, INodeEntry, PAnsiChar(Options));
      FNodeMedium.Load;

      IoCore.Console.WriteSuccessWithData(itoa(FNodeMedium.GetEntryCount) + ' Nodes');
    except
      on Exception{EFileLoadError} do
      begin
        IoCore.Console.WriteFailureWithData(RsDataCoreLoadErr);
      end;
    else
      raise;
    end;

    IoCore.Console.WriteLoadOf('SAVES: Timers');

    try
      CreateTypeInfoFromDelphiRTTI(TypeInfo(YDbPersistentTimerEntry), TInfo);
      Options := WideStringToUTF8(SysConf.ReadStringN('Data', 'TimerDBInfo'));
      CreateDatabaseInstance(SysConf.ReadStringN('Data',
        'TimerDBType'), FTimerMedium);
      FTimerMedium.Initialize(TInfo, IPersistentTimerEntry, PAnsiChar(Options));
      FTimerMedium.Load;

      IoCore.Console.WriteSuccessWithData(itoa(FTimerMedium.GetEntryCount) + ' Timers');
    except
      on Exception{EFileLoadError} do
      begin
        IoCore.Console.WriteFailureWithData(RsDataCoreLoadErr);
      end;
    else
      raise;
    end;

    IoCore.Console.WriteLoadOf('SAVES: Addons');

    try
      CreateTypeInfoFromDelphiRTTI(TypeInfo(YDbAddonEntry), TInfo);
      Options := WideStringToUTF8(SysConf.ReadStringN('Data', 'AddonDBInfo'));
      CreateDatabaseInstance(SysConf.ReadStringN('Data',
        'AddonDBType'), FAddonMedium);
      FAddonMedium.Initialize(TInfo, IAddonEntry, PAnsiChar(Options));
      FAddonMedium.Load;

      IoCore.Console.WriteSuccessWithData(itoa(FAddonMedium.GetEntryCount) + ' Addons');
    except
      on Exception{EFileLoadError} do
      begin
        IoCore.Console.WriteFailureWithData(RsDataCoreLoadErr);
      end;
    else
      raise;
    end;

    //------------------------------------------------------------------------------
    // DataCore - Loading profanity and reserved names lists
    //------------------------------------------------------------------------------
    FProfanityList := TWideStringList.Create;
    FReservedNameList := TWideStringList.Create;

    FProfanityList.CaseSensitive := False;
    FProfanityList.Sorted := True;
    FReservedNameList.CaseSensitive := False;
    FReservedNameList.Sorted := True;

    LoadProfanityList;
    LoadReservedNameList;

    //------------------------------------------------------------------------------
    // DataCore - Loading Maps
    //------------------------------------------------------------------------------
    try
      IoCore.Console.WriteLoadOfSub('Map Definitions');
      FWorldDataLoader := YDbWorldDataLoader.Create(
        FileNameToOS(SysConf.ReadStringN('Data', 'ServerMapDataDir')));
      FWorldDataLoader.Load;

      IoCore.Console.NewLine;
      IoCore.Console.WriteMapInfo(
        LIQUID_RES,
        HEIGHT_RES,
        CELLS_PER_TILE,

        FWorldDataLoader.MapCount,
        FILE_VER_FULL
      );

      try
        IoCore.Console.WriteLoadOfSubComp('Main Index Table');
        IoCore.Console.WriteSuccess;
      except
        on E: Exception do
        begin
          IoCore.Console.WriteFailureWithData(RsDataCoreLoadErr);
          raise ECoreOperationFailed.Create(E.Message);
        end;
      end;

      try
        IoCore.Console.WriteLoadOfSubComp('Block Index Tables');
        IoCore.Console.WriteSuccessWithData(itoa(FWorldDataLoader.IndexTableSize div 1024) + ' Kb');
      except
        on E: Exception do
        begin
          IoCore.Console.WriteFailureWithData(RsDataCoreLoadErr);
          raise ECoreOperationFailed.Create(E.Message);
        end;
      end;
    except
      on EFileLoadError do
      begin
        IoCore.Console.WriteFailureWithData(RsDataCoreLoadErr);
      end;

      on E: EMediumOperationFailed do
      begin
        case E.Error of
          MOF_LOAD:
          begin
            IoCore.Console.WriteSMDFileLoadError(
              FileNameToOS(SysConf.ReadStringN('Data', 'ServerMapDataDir')));
          end;
        else
          raise;
        end;
      end;
    end;

    FDecacheHandle := SysEventMgr.RegisterEvent(OnDBDecache, DECACHE_TIME,
      TICK_EXECUTE_INFINITE, 'DataCore_DatabaseDecache_MainTimer');

  // Handling any medium exception !
  except
    on E: EMediumOperationFailed do
    begin
      IoCore.Console.WriteError;
      raise ECoreOperationFailed.Create(E.Message);
    end;
  end;
end;

//------------------------------------------------------------------------------
// Datacore - Start [overriding the one in YBaseCore]
//------------------------------------------------------------------------------
procedure YDataCore.CoreStart;
begin
  { This Core doesn't require a start point now. :) }
end;

//------------------------------------------------------------------------------
// Datacore - Stop [overriding the one in YBaseCore]
//------------------------------------------------------------------------------
procedure YDataCore.CoreStop;
begin
  SysEventMgr.UnregisterEvent(FDecacheHandle);

  if FBeingSaved then
  begin
    FSynchLock.WaitFor(-1);
  end;

  FAccountMedium.Save;
  FPlayerMedium.Save;
  FItemMedium.Save;
  FNodeMedium.Save;
  FTimerMedium.Save;
  FAddonMedium.Save;

  FPlayerTemplateMedium.Save;

  FItemTemplateMedium.Save;

  //FQuestTemplateMedium.Save;

  //FNPCTextTemplateMedium.Save;

  FCreatureTemplateMedium.Save;

  FGameObjectTemplateMedium.Save;

  UnloadDbLayerPlugins;

  FWorldDataLoader.Free;

  FProfanityList.Free;
  FReservedNameList.Free;

  FSynchLock.Delete;
  FRegisteredContextClasses.Free;
end;

procedure YDataCore.CreateDatabaseInstance(Ident: WideString;
  out Storage: YDbStorageMediumWrapper);
var
  StorageIntf: IStorageMedium;
begin
  CreateStorage(PAnsiChar(WideStringToUTF8(Ident)), StorageIntf);
  Storage := YDbStorageMediumWrapper.Create(StorageIntf);
end;

procedure YDataCore.CreateDofReader(out Reader: IDofReader);
begin
  Reader := YDbDofBinaryReader.Create(nil, False);
end;

procedure YDataCore.CreateDofWriter(out Writer: IDofWriter);
begin
  Writer := YDbDofBinaryWriter.Create(nil, False);
end;

procedure YDataCore.CreateStorage(StorageType: PChar;
  out Storage: IStorageMedium);
var
  I: Integer;
  Ident: WideString;
begin
  Ident := WideUpperCase(StorageType);
  for I := 0 to Length(FDatabaseLayerPlugins) -1 do
  begin
    if FDatabaseLayerPlugins[I].Ident = Ident then
    begin
      with FDatabaseLayerPlugins[I] do
      begin
        if References = 0 then
        begin
          Module := LoadLibraryW(PWideChar(FileName));
          @CreateDatabaseLayerInstanceProc := GetProcAddress(Module, 'CreateDatabaseLayerInstance');
          if (Module = 0) or (Module = $FFFFFFFF) or
             not Assigned(CreateDatabaseLayerInstanceProc) then
          begin
            raise Exception.Create('');
          end;
        end;
        CreateDatabaseLayerInstanceProc(Storage);
        Inc(References);
      end;
      Exit;
    end;
  end;
  raise Exception.Create('');
end;

procedure YDataCore.LoadDbLayerIdentList;
var
  Temp: TStringList;
  Int: Int32;
  Line: WideString;
  I: Integer;
  PluginName: WideString;
begin
  Temp := TStringList.Create;
  try
    Temp.LoadFromFile(FileNameToOS('{$YROOT}\Configuration\dbidents.txt'));
    for Int := 0 to Temp.Count -1 do
    begin
      Line := WideTrim(UTF8ToWideString(Temp[Int]));
      if (Line[1] <> ';') or (Line[2] <> ';') then
      begin
        I := WideCharPos(Line, '=', 1);
        if I <= 0 then Continue;

        PluginName := FileNameToOS(WideTrimLeft(Copy(Line, I + 1, Length(Line))));
        Delete(Line, I, Length(Line));
        Line := WideTrimRight(Line);

        if Length(Line) > 8 then Continue;
        if not WideFileExists(PluginName) then Continue;

        I := Length(FDatabaseLayerPlugins);
        SetLength(FDatabaseLayerPlugins, I + 1);
        with FDatabaseLayerPlugins[I] do
        begin
          FileName := PluginName;
          Ident := Line;
        end;
      end;
    end;
  finally
    Temp.Free;
  end;
end;

procedure YDataCore.LoadProfanityList;
var
  Temp: TStringList;
  Int: Int32;
  Line: WideString;
begin
  Temp := TStringList.Create;
  try
    Temp.LoadFromFile(FileNameToOS('{$YROOT}\Configuration\profanity.txt'));
    for Int := 0 to Temp.Count -1 do
    begin
      Line := WideTrim(UTF8ToWideString(Temp[Int]));
      if (Line[1] <> ';') or (Line[2] <> ';') then
      begin
        if WideCharPos(Line, ' ', 1) = 0 then
        begin
          FProfanityList.Add(Line);
        end;
      end;
    end;
  finally
    Temp.Free;
  end;
end;

procedure YDataCore.LoadReservedNameList;
var
  Temp: TStringList;
  Int: Int32;
  Line: WideString;
begin
  Temp := TStringList.Create;
  try
    Temp.LoadFromFile(FileNameToOS('{$YROOT}\Configuration\reserved_names.txt'));
    for Int := 0 to Temp.Count -1 do
    begin
      Line := WideTrim(UTF8ToWideString(Temp[Int]));
      if (Line[1] <> ';') or (Line[2] <> ';') then
      begin
        if WideCharPos(Line, ' ', 1) = 0 then
        begin
          FReservedNameList.Add(Line);
        end;
      end;
    end;
  finally
    Temp.Free;
  end;
end;

type
  PInternalDecacheParams = ^TInternalDecacheParams;
  TInternalDecacheParams = record
    Core: YDataCore;
    Params: YDecacheParams;
  end;

function DecacheDatabase(ThrdData: PThreadCreateInfo): Longword;
var
  Params: PInternalDecacheParams;
  DC: YDataCore;
  Time: string;
begin
  Params := ThrdData.Param;
  DC := Params^.Core;
  AtomicInc(@DC.fBeingSaved);
  DC.fSynchLock.Reset;

  StartExecutionTimer;
  DC.PerformSave(Params^.Params);
  Time := itoa(Trunc32(StopExecutionTimer));

  DC.FSynchLock.Signal;
  AtomicDec(@DC.FBeingSaved);

  IoCore.Console.Writeln('=================================');
  IoCore.Console.WriteMultiple([
    'DB decache time: ~',
    Time,
    ' ms.'],
    [15, 12, 15]);
  IoCore.Console.Writeln('=================================');

  Dispose(Params);
  Dispose(ThrdData);
  Result := 0;
end;

procedure YDataCore.FindContextClassInfo(const ClassName: string;
  out Info: ITypeInfo);
begin
  Info := FRegisteredContextClasses.GetValue(ClassName) as ITypeInfo;
end;

function YDataCore.FullSave(RefreshTimer: Boolean): Boolean;
var
  ThrdData: PThreadCreateInfo;
  Prio: TThreadPriority;
  Params: PInternalDecacheParams;
begin
  if not FBeingSaved then
  begin
    IoCore.Console.WritelnMultiple([
      '=================================',
      'Periodic DB decache started.',
      '================================='],
      [15, 15, 15]);

    New(Params);

    with Params^ do
    begin
      Core := Self;
    end;

    New(ThrdData);
    StartThreadAtAddress(DecacheDatabase, Params, True, ThrdData^);
    Prio := tpLowest;
    ThreadModifyPriority(ThrdData^.Handle, Prio, True);
    ThreadModifyState(ThrdData^.Handle, False);

    if RefreshTimer then
    begin
      FDecacheHandle.RefreshCounters([rfTime]);
    end;
    
    Result := True;
  end else Result := False;
end;

function YDataCore.GetAccountStorage: IStorageMedium;
begin
  Result := FAccountMedium.WrappedObject;
end;

function YDataCore.GetAddonStorage: IStorageMedium;
begin
  Result := FAddonMedium.WrappedObject;
end;

function YDataCore.GetPlayerStorage: IStorageMedium;
begin
  Result := FPlayerMedium.WrappedObject;
end;

function YDataCore.GetPlayerTemplateStorage: IStorageMedium;
begin
  Result := FPlayerTemplateMedium.WrappedObject;
end;

function YDataCore.GetCreatureTemplateStorage: IStorageMedium;
begin
  Result := FCreatureTemplateMedium.WrappedObject;
end;

function YDataCore.GetGameObjectTemplateStorage: IStorageMedium;
begin
  Result := FGameObjectTemplateMedium.WrappedObject;
end;

function YDataCore.GetItemStorage: IStorageMedium;
begin
  Result := FItemMedium.WrappedObject;
end;

function YDataCore.GetItemTemplateStorage: IStorageMedium;
begin
  Result := FItemTemplateMedium.WrappedObject;
end;

function YDataCore.GetNodeStorage: IStorageMedium;
begin
  Result := FNodeMedium.WrappedObject;
end;

function YDataCore.GetQuestTemplateStorage: IStorageMedium;
begin
  Result := FQuestTemplateMedium.WrappedObject;
end;

function YDataCore.GetTimerStorage: IStorageMedium;
begin
  Result := FTimerMedium.WrappedObject;
end;

procedure YDataCore.OnDBDecache(Event: TEventHandle; TimeDelta: UInt32);
begin
  FullSave(False);
  if bShuttingDown then
  begin
    FDecacheHandle.Unregister;
    FDecacheHandle := nil;
  end;
end;

(*
procedure YDataCore.OnStorageError(Sender: YDbStorageMedium; const Msg: string);
var
  sName: string;
  cLog: TLogHandle;
begin
  sName := 'Errors/DB/' + StringReplace(Sender.Name, ' ', '_', [rfReplaceAll]) + '_errors.txt';
  cLog := Framework.SystemLogger.OpenLog(sName, True);
  cLog.Write(Msg);
end;
*)

procedure YDataCore.PerformSave(const Params: YDecacheParams);
begin
  with Params do
  begin
    //Accounts.ThreadSafeSave;
    //Characters.ThreadSafeSave;
    //Items.ThreadSafeSave;
    //Creatures.ThreadSafeSave;
    //GameObjects.ThreadSafeSave;
    //Nodes.ThreadSafeSave;
    //SecurityGroups.ThreadSafeSave;
    //Addons.ThreadSafeSave;
  end;
end;

procedure YDataCore.RegisterContextClass(const ClassInfo: ITypeInfo);
begin
  FRegisteredContextClasses.PutValue(ClassInfo.TypeName, ClassInfo);
end;

procedure YDataCore.RegisterContextClassAlias(const ClassInfo: ITypeInfo;
  Alias: PChar);
begin
  FRegisteredContextClasses.PutValue(Alias, ClassInfo);
end;

procedure YDataCore.UnloadDbLayerPlugins;
var
  I: Integer;
begin
  FAccountMedium.Free;
  FPlayerMedium.Free;
  FItemMedium.Free;
  FNodeMedium.Free;
  FAddonMedium.Free;
  FTimerMedium.Free;

  FPlayerTemplateMedium.Free;
  FPlayerTemplateStore.Free;

  FItemTemplateMedium.Free;
  FQuestTemplateMedium.Free;
  FNPCTextTemplateMedium.Free;
  FCreatureTemplateMedium.Free;
  FGameObjectTemplateMedium.Free;

  for I := 0 to Length(FDatabaseLayerPlugins) -1 do
  begin
    with FDatabaseLayerPlugins[I] do
    begin
      if (Module <> 0) and (Module <> $FFFFFFFF) then FreeLibrary(Module);
    end;
  end;
end;

procedure YDataCore.UnregisterContextClass(const ClassInfo: ITypeInfo);
var
  StrList: TStrArrayList;
  Itr: IStrIterator;
  Key: string;
begin
  if FRegisteredContextClasses.Remove(ClassInfo.TypeName) <> nil then
  begin
    StrList := TStrArrayList.Create;
    try
      Itr := FRegisteredContextClasses.KeySet;
      while Itr.HasNext do
      begin
        Key := Itr.Next;
        if FRegisteredContextClasses.GetValue(Key) = ClassInfo then
        begin
          StrList.Add(Key);
        end;
      end;

      Itr := StrList.First;
      while Itr.HasNext do
      begin
        FRegisteredContextClasses.Remove(Itr.Next);
      end;
    finally
      StrList.Free;
    end;
  end;
end;

{ YDbCharTemplateStore }

constructor YDbCharTemplateStore.Create(const Storage: YDbStorageMediumWrapper);
begin
  FStorage := Storage;
end;

function YDbCharTemplateStore.CombineTemplate(PlrRace: YGameRace;
  PlrClass: YGameClass): IPlayerTemplateEntry;
var
  ClassTemplates: array of IPlayerTemplateEntry;
  Race: string;
  I: Integer;
  LookupRes: ILookupResult;
begin
  FStorage.LookupEntryListA('Race', RaceToString(PlrRace), False, LookupRes, False);
  if not Assigned(LookupRes) then raise Exception.Create('');
  LookupRes.GetData(Result, 1);

  FStorage.LookupEntryListA('PlayerClass', ClassToString(PlrClass), False, LookupRes);
  if Assigned(LookupRes) then
  begin
    I := LookupRes.EntryCount;
    SetLength(ClassTemplates, I);

    LookupRes.GetData(ClassTemplates[0], I);
    Result.Race := RaceToString(PlrRace);
    Result.PlayerClass := ClassToString(PlrClass);

    for I := 0 to Length(ClassTemplates) -1 do
    begin
      Race := ClassTemplates[I].Race;
      if (Race = '') or StringsEqualNoCase(Race, Result.Race) then
      begin
        UpdateTemplate(Result, ClassTemplates[I]);
      end;
    end;

    if Result.BodySize = 0 then Result.BodySize := 1;
  end;
end;

procedure YDbCharTemplateStore.UpdateTemplate(const Template, By: IPlayerTemplateEntry);
var
  I, Len: Integer;
begin
  if Template.Map = 0 then Template.Map := By.Map;
  if Template.Zone = 0 then Template.Zone := By.Zone;
  if Template.StartingX = 0 then Template.StartingX := By.StartingX;
  if Template.StartingY = 0 then Template.StartingY := By.StartingY;
  if Template.StartingZ = 0 then Template.StartingZ := By.StartingZ;
  if Template.StartingAngle = 0 then Template.StartingAngle := By.StartingAngle;

  Template.InitialStrength := Template.InitialStrength + By.InitialStrength;
  Template.InitialAgility := Template.InitialAgility + By.InitialAgility;
  Template.InitialStamina := Template.InitialStamina + By.InitialStamina;
  Template.InitialIntellect := Template.InitialIntellect + By.InitialIntellect;
  Template.InitialSpirit := Template.InitialSpirit + By.InitialSpirit;

  if Template.MaleBodyModel = 0 then Template.MaleBodyModel := By.MaleBodyModel;
  if Template.FemaleBodyModel = 0 then Template.FemaleBodyModel := By.FemaleBodyModel;
  if Template.BodySize = 0 then Template.BodySize := By.BodySize;
  if Template.PowerType = 0 then Template.PowerType := By.PowerType;

  Template.BasePower := Template.BasePower + By.BasePower;
  Template.BaseHealth := Template.BaseHealth + By.BaseHealth;

  //Len := Length(Template.SkillData);
  //Template.SetSkillDataLength(Len + Length(By.SkillData));
  //for I := 0 to Length(By.SkillData) -1 do
  //begin
  //  Template.SkillData[Len+I] := By.SkillData[I];
  //end;

  //Len := Length(Template.ItemData);
  //Template.SetItemDataLength(Len + Length(By.ItemData));
  //for I := 0 to Length(By.ItemData) -1 do
  //begin
  //  Template.ItemData[Len+I] := By.ItemData[I];
  //end;

  //Len := Length(Template.Spells);
  //Template.SetSpellsLength(Len + Length(By.Spells));
  //for I := 0 to Length(By.Spells) -1 do
  //begin
  //  Template.Spells[Len+I] := By.Spells[I];
  //end;

  //Len := Length(Template.ActionButtons);
  //Template.SetActionButtonsLength(Len + Length(By.ActionButtons));
  //for I := 0 to Length(By.ActionButtons) -1 do
  //begin
  //  Template.ActionButtons[Len+I] := By.ActionButtons[I];
  //end;

  if Template.AttackTimeLo = 0 then Template.AttackTimeLo := By.AttackTimeLo;
  if Template.AttackTimeHi = 0 then Template.AttackTimeHi := By.AttackTimeHi;
  if Template.AttackPower = 0 then Template.AttackPower := By.AttackPower;

  Template.AttackDamageLo := Template.AttackDamageLo + By.AttackDamageLo;
  Template.AttackDamageHi := Template.AttackDamageHi + By.AttackDamageHi;
end;

{ YDbStorageMediumWrapper }

procedure YDbStorageMediumWrapper.AcquireEntries(out Entries; Count: Integer);
begin
  FMedium.AcquireEntries(Entries, Count);
end;

procedure YDbStorageMediumWrapper.AcquireEntry(out Entry);
begin
  FMedium.AcquireEntry(Entry);
end;

constructor YDbStorageMediumWrapper.Create(const Provider: IStorageMedium);
begin
  FMedium := Provider;
  FName := FMedium.Name;
end;

procedure YDbStorageMediumWrapper.CreateEntries(out Entries; Count: Integer);
begin
  FMedium.CreateEntries(Entries, Count);
end;

procedure YDbStorageMediumWrapper.CreateEntry(out Entry);
begin
  FMedium.CreateEntry(Entry);
end;

procedure YDbStorageMediumWrapper.DeleteEntries(const Ids: array of Longword);
begin
  FMedium.DeleteEntries(@Ids[0], Length(Ids));
end;

procedure YDbStorageMediumWrapper.DeleteEntry(Id: Longword);
begin
  FMedium.DeleteEntry(Id);
end;

function YDbStorageMediumWrapper.GetEntryCount: Integer;
begin
  Result := FMedium.EntryCount;
end;

procedure YDbStorageMediumWrapper.Initialize(const Metadata: ITypeInfo;
  const GUID: TGUID; const Args: AnsiString);
begin
  FMedium.Initialize(Metadata, GUID, Pointer(Args));
end;

procedure YDbStorageMediumWrapper.Load;
begin
  FMedium.Load;
end;

procedure YDbStorageMediumWrapper.LookupEntry(Id: Longword; out Entry);
begin
  FMedium.LookupEntry(Id, Entry);
end;

procedure YDbStorageMediumWrapper.LookupEntryListA(const Field,
  CmpValue: AnsiString; CaseSensitive: Boolean; out Result: ILookupResult;
  ResultOwnsEntries: Boolean);
begin
  FMedium.LookupEntryList(PAnsiChar(Field), PAnsiChar(CmpValue), CaseSensitive,
    Result, ResultOwnsEntries);
end;

procedure YDbStorageMediumWrapper.LookupEntryListL(const Field: AnsiString;
  CmpValue: Longword; CmpOp: TCompareOp; out Result: ILookupResult;
  ResultOwnsEntries: Boolean);
begin
  FMedium.LookupEntryList(PAnsiChar(Field), CmpValue, CmpOp, Result, ResultOwnsEntries);
end;

procedure YDbStorageMediumWrapper.LookupEntryListF(const Field: AnsiString;
  CmpValue: Float; CmpOp: TCompareOp; Epsilon: Float; out Result: ILookupResult;
  ResultOwnsEntries: Boolean);
begin
  FMedium.LookupEntryList(PAnsiChar(Field), CmpValue, CmpOp, Epsilon, Result, ResultOwnsEntries);
end;

procedure YDbStorageMediumWrapper.LookupEntryListW(const Field: AnsiString;
  const CmpValue: WideString; CaseSensitive: Boolean; out Result: ILookupResult;
  ResultOwnsEntries: Boolean);
begin
  FMedium.LookupEntryList(PAnsiChar(Field), PWideChar(CmpValue), CaseSensitive,
    Result, ResultOwnsEntries);
end;

procedure YDbStorageMediumWrapper.ReleaseEntries(const Entries; Count: Integer);
begin
  FMedium.ReleaseEntries(Entries, Count);
end;

procedure YDbStorageMediumWrapper.ReleaseEntry(const Entry: ISerializable);
begin
  FMedium.ReleaseEntry(Entry);
end;

procedure YDbStorageMediumWrapper.Save;
begin
  FMedium.Save;
end;

procedure YDbStorageMediumWrapper.SaveEntries(const Entries; Count: Integer;
  Release: Boolean);
begin
  FMedium.SaveEntries(Entries, Count, Release);
end;

procedure YDbStorageMediumWrapper.SaveEntry(const Entry: ISerializable;
  Release: Boolean);
begin
  FMedium.SaveEntry(Entry, Release);
end;

procedure YDbStorageMediumWrapper.ThreadSafeSave;
begin
  FMedium.ThreadSafeSave;
end;

end.
