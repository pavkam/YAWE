{*------------------------------------------------------------------------------
  Main DataCore Object. Provides Access to Data.

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
unit Components.DataCore;

interface

uses
  Framework.Base,
  Components.DataCore.Storage,
  Components.DataCore.Fields,
  Framework.SerializationRegistry,
  Framework.Tick,
  Framework.TypeRegistry,
  Framework.ThreadManager,
  Framework.LogManager,
  Components.DataCore.Types,
  Components.DataCore.CharTemplates,
  Components.DataCore.WorldData.Loader,
  Components.DataCore.WorldData.Types,
  Misc.Miscleanous,
  Misc.Containers,
  Misc.Threads,
  SysUtils,
  Classes,
  Components;

const
  DECACHE_TIME = 1000 * 60 * 5; { 5 minutes }

type
  PDecacheParams = ^YDecacheParams;
  YDecacheParams = record
  end;

  YDataCore = class(YBaseCore)    // YDataCore derived from YBaseCore
    private
      fRegisteredContextClasses: TStrIntfHashMap;
      fDecacheHandle: TEventHandle;
      fBeingSaved: Longbool;
      fSynchLock: TEvent;

      fWorldDataLoader: YDbWorldDataLoader;

      fAccountsMedium: YDbStorageMedium;
      fPlayerStorageMedium: YDbStorageMedium;
      fItemStorageMedium: YDbStorageMedium;
      fNodeStorageMedium: YDbStorageMedium;
      fAddonsMedium: YDbStorageMedium;
      fTimerStorageMedium: YDbStorageMedium;

      fCharTemplateMedium: YDbStorageMedium;
      fCharTemplateStore: YDbCharTemplateStore;

      fItemTemplatesMedium: YDbStorageMedium;
      fQuestTemplatesMedium: YDbStorageMedium;
      fNPCTextTemplatesMedium: YDbStorageMedium;
      fCreatureTemplatesMedium: YDbStorageMedium;
      fGameObjectTemplatesMedium: YDbStorageMedium;

      fProfanityList: TStrArrayList;
      fReservedNamesList: TStrArrayList;

      procedure LoadProfanityList;
      procedure LoadReservedNamesList;
      function InitMedium(const MediumType: string): YDbStorageMedium;
      procedure OnDBDecache(Event: TEventHandle; TimeDelta: UInt32);
      procedure PerformSave(const Params: YDecacheParams);

      procedure OnStorageError(Sender: YDbStorageMedium; const Msg: string);

      procedure FindContextClassInfo(const ClassName: string; out Info: IClassTypeInfo);
    protected
      procedure CoreInitialize; override;
      procedure CoreStart; override;
      procedure CoreStop; override;
    public
      function FullSave(bRefreshTimer: Boolean): Boolean;

      procedure RegisterContextClass(const ClassInfo: IClassTypeInfo);
      procedure RegisterContextClassAlias(const ClassInfo: IClassTypeInfo; const Alias: string);
      procedure UnregisterContextClass(const ClassInfo: IClassTypeInfo);

      property Accounts: YDbStorageMedium read fAccountsMedium;
      property Characters: YDbStorageMedium read fPlayerStorageMedium;
      property Items: YDbStorageMedium read fItemStorageMedium;
      property Nodes: YDbStorageMedium read fNodeStorageMedium;
      property Timers: YDbStorageMedium read fTimerStorageMedium;
      property Addons: YDbStorageMedium read fAddonsMedium;

      property CharTemplates: YDbCharTemplateStore read fCharTemplateStore;
      property ItemTemplates: YDbStorageMedium read fItemTemplatesMedium;
      property QuestTemplates: YDbStorageMedium read fQuestTemplatesMedium;
      property NPCTextsTemplates: YDbStorageMedium read fNPCTextTemplatesMedium;
      property CreatureTemplates: YDbStorageMedium read fCreatureTemplatesMedium;
      property GameObjectTemplates: YDbStorageMedium read fGameObjectTemplatesMedium;

      property ProfanityList: TStrArrayList read fProfanityList;
      property ReservedNamesList: TStrArrayList read fReservedNamesList;

      property WorldData: YDbWorldDataLoader read fWorldDataLoader;
    end;

implementation

uses
  Components.DataCore.DynamicObjectFormat,
  Main,
  Resources,
  Misc.Classes,
  MMSystem,
  Components.DataCore.PkTTEngine,
  Components.DataCore.PcpEngine,
  Components.DataCore.DbcEngine,
  Cores,
  TypInfo,
  Framework;

{ YDataCore }

//------------------------------------------------------------------------------
// DataCore Initialization
//------------------------------------------------------------------------------

{..$DEFINE TEST_DOF}

{$IFDEF TEST_DOF}
type
  TSomeEnum = (seOne, seTwo, seThree);
  TSomeSet = set of TSomeEnum;

  TSubType = class(TBaseObject)
    private
      FName: string;
      FCount: Int32;
    published
      property Name: string read FName write FName;
      property Count: Int32 read FCount write FCount;
  end;

  TSuperComplicated = array of TSubType;

  TSomeType = class(TBaseInterfacedObject, IDofStreamable)
    private
      FX, FY, FZ: Single;
      F64: Int64;
      FEnum: TSomeEnum;
      FSet: TSomeSet;
      FSub: TSubType;
      FArr: TStringDynArray;
      FComplicated: TSuperComplicated;

      procedure ReadArr(const Reader: IDofReader);
      procedure ReadComplicated(const Reader: IDofReader);

      procedure WriteArr(const Writer: IDofWriter);
      procedure WriteComplicated(const Writer: IDofWriter);

      procedure ReadCustomProperties(const Reader: IDofReader);
      procedure WriteCustomProperties(const Writer: IDofWriter);

      property Arr: TStringDynArray read FArr write FArr;
      property Complicated: TSuperComplicated read FComplicated write FComplicated;
    published
      constructor Create;
      destructor Destroy; override;

      property X: Single read FX write FX;
      property Y: Single read FY write FY;
      property Z: Single read FZ write FZ;
      property Big: Int64 read F64 write F64;

      property Enum: TSomeEnum read FEnum write FEnum;
      property SomeSet: TSomeSet read FSet write FSet;
      property SubObject: TSubType read FSub write FSub;
  end;

procedure Test;
var
  W: YDbDofBinaryWriter;
  W2: YDbDofTextWriter;
  R: YDbDofBinaryReader;
  R2: YDbDofTextReader;
  E: TSomeType;
  E2: TSomeType;
begin
  E := TSomeType.Create;
  E.X := 5.37;
  E.Y := 10.18;
  E.Z := 55.44;
  E.Big := MAXINT64;
  E.FSet := [seTwo];
  SetLength(E.FComplicated, 3);
  E.FComplicated[0] := E.SubObject;
  E.FComplicated[1] := E.SubObject;
  E.FComplicated[2] := E.SubObject;
  E.SubObject.Name := 'Test';
  E.SubObject.Count := 1024;
  SetLength(E.FArr, 4);
  E.Arr[0] := 'Hello';
  E.Arr[1] := 'how';
  E.Arr[2] := 'are';
  E.Arr[3] := 'you?';

  DataCore.RegisterContextClass(SystemTypeRegistry.RegisterType(TypeInfo(TSomeType)) as IClassTypeInfo);

  W := YDbDofBinaryWriter.Create('tst.dof', fmCreate);
  W.OnLookup := DataCore.FindContextClassInfo;

  W.BeginWrite;

  W.WriteRootClass(E);

  W.EndWrite;

  W.Free;

  E.Free;

  E2 := TSomeType.Create;

  R := YDbDofBinaryReader.Create('tst.dof', fmOpenRead);
  R.OnLookup := DataCore.FindContextClassInfo;

  R.BeginRead;

  R.ReadRootClass(E2);

  R.EndRead;
  R.Free;
  E2.Free;



  E := TSomeType.Create;
  E.X := 5.37;
  E.Y := 10.18;
  E.Z := 55.44;
  E.Big := MAXINT64;
  E.FSet := [seTwo];
  SetLength(E.FComplicated, 3);
  E.FComplicated[0] := E.SubObject;
  E.FComplicated[1] := E.SubObject;
  E.FComplicated[2] := E.SubObject;
  E.SubObject.Name := 'Test';
  E.SubObject.Count := 1024;
  SetLength(E.FArr, 4);
  E.Arr[0] := 'Hello';
  E.Arr[1] := 'how';
  E.Arr[2] := 'are';
  E.Arr[3] := 'you?';

  W2 := YDbDofTextWriter.Create('tst2.dof', fmCreate);
  W2.OnLookup := DataCore.FindContextClassInfo;

  W2.BeginWrite;

  W2.WriteRootClass(E);

  W2.EndWrite;

  W2.Free;

  E.Free;

  E2 := TSomeType.Create;

  R2 := YDbDofTextReader.Create('tst2.dof', fmOpenRead);
  R2.OnLookup := DataCore.FindContextClassInfo;

  R2.BeginRead;

  R2.ReadRootClass(E2);

  R2.EndRead;
  R2.Free;
  E2.Free;
end;

{ TSomeType }

constructor TSomeType.Create;
begin
  FSub := TSubType.Create;
end;

destructor TSomeType.Destroy;
begin
  FSub.Free;
  inherited;
end;

procedure TSomeType.ReadArr(const Reader: IDofReader);
begin
  Reader.ReadListStart;
  while not Reader.IsListEnd do
  begin
    SetLength(fArr, Length(fArr) + 1);
    fArr[High(fArr)] := Reader.ReadString;
  end;
  Reader.ReadListEnd;
end;

procedure TSomeType.ReadComplicated(const Reader: IDofReader);
var
  ifInfo: IClassTypeInfo;
begin
  ifInfo := SystemTypeRegistry.RegisterType(TypeInfo(TSubType)) as IClassTypeInfo;

  Reader.ReadCollectionStart;
  while not Reader.IsCollectionEnd do
  begin
    SetLength(fComplicated, Length(fComplicated) + 1);
    fComplicated[High(fComplicated)] := TSubType.Create;
    Reader.ReadCollectionItemStart;
    Reader.ReadClass(fComplicated[High(fComplicated)], ifInfo);
    Reader.ReadCollectionItemEnd;
  end;
  Reader.ReadCollectionEnd;
end;

procedure TSomeType.ReadCustomProperties(const Reader: IDofReader);
begin
  Reader.ReadCustomProperty('Arr', ReadArr);
  Reader.ReadCustomProperty('Complicated', ReadComplicated);
end;

procedure TSomeType.WriteArr(const Writer: IDofWriter);
var
  iIdx: Int32;
begin
  Writer.WriteListStart;
  for iIdx := 0 to Length(fArr) -1 do
  begin
    Writer.WriteString(fArr[iIdx]);
  end;
  Writer.WriteListEnd;
end;

procedure TSomeType.WriteComplicated(const Writer: IDofWriter);
var
  iIdx: Int32;
  ifInfo: IClassTypeInfo;
begin
  ifInfo := SystemTypeRegistry.RegisterType(TypeInfo(TSubType)) as IClassTypeInfo;

  Writer.WriteCollectionStart;
  for iIdx := 0 to Length(fComplicated) -1 do
  begin
    if Assigned(fComplicated[iIdx]) then
    begin
      Writer.WriteCollectionItemStart;
      Writer.WriteClass(fComplicated[iIdx], ifInfo);
      Writer.WriteCollectionItemEnd;
    end;
  end;
  Writer.WriteCollectionEnd;
end;

procedure TSomeType.WriteCustomProperties(const Writer: IDofWriter);
begin
  Writer.WriteCustomProperty('Arr', WriteArr);
  Writer.WriteCustomProperty('Complicated', WriteComplicated);
end;
{$ELSE}
procedure Test;
begin

end;
{$ENDIF}

procedure YDataCore.CoreInitialize;
begin
  fRegisteredContextClasses := TStrIntfHashMap.Create(False, 1024);
  Test;

  fSynchLock.Init(False, False);

  try
  //------------------------------------------------------------------------------
  // [1] DataCore - Loading Char Templates
  //------------------------------------------------------------------------------
    IoCore.Console.WriteLoadOf('TEMPLATE: Characters');

    try
      fCharTemplateMedium := InitMedium(SystemConfiguration.StringValue['Data', 'CharTempDBType']);
      fCharTemplateMedium.Initialize(SystemConfiguration.StringValue['Data', 'CharTempDBInfo'],
        False, YDbCharTemplate, 'Character templates');
      fCharTemplateMedium.InitialLoad;
      IoCore.Console.WriteSuccessWithData(itoa(fCharTemplateMedium.Items) + ' Character Templates');
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
            IoCore.Console.WriteFailureWithData(RsDataCoreFileMustExit);
          end;
          MOF_OPT_ERR:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreBadOpt);
          end;
          MOF_INV_MED:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreUnkMed);
            raise ECoreOperationFailed.Create(E.Message);
          end;
        else
          raise;
        end;
      end;
    end;
    fCharTemplateStore := YDbCharTemplateStore.Create;
    fCharTemplateStore.SelectMedium(fCharTemplateMedium);

  //------------------------------------------------------------------------------
  // [2] DataCore - Loading Item Templates
  //------------------------------------------------------------------------------
    IoCore.Console.WriteLoadOf('TEMPLATE: Items');

    try
      fItemTemplatesMedium := InitMedium(SystemConfiguration.StringValue['Data',
        'ItemTempDBType']);
      fItemTemplatesMedium.Initialize(SystemConfiguration.StringValue['Data',
        'ItemTempDBInfo'], False, YDbItemTemplate, 'Item templates');
      fItemTemplatesMedium.InitialLoad;
      IoCore.Console.WriteSuccessWithData(itoa(fItemTemplatesMedium.Items) + ' Item Templates');
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
            IoCore.Console.WriteFailureWithData(RsDataCoreFileMustExit);
          end;
          MOF_OPT_ERR:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreBadOpt);
          end;
          MOF_INV_MED:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreUnkMed);
            raise ECoreOperationFailed.Create(E.Message);
          end;
        else
          raise;
        end;
      end;
    end;

  //------------------------------------------------------------------------------
  // [3.] DataCore - Loading Creature Templates
  //------------------------------------------------------------------------------
    IoCore.Console.WriteLoadOf('TEMPLATE: Creatures');

    try
      fCreatureTemplatesMedium := InitMedium(SystemConfiguration.StringValue['Data',
        'CreaturesTemplateDBType']);
      fCreatureTemplatesMedium.Initialize(SystemConfiguration.StringValue['Data',
        'CreaturesTemplateDBInfo'], False, YDbCreatureTemplate, 'Creature templates');
      fCreatureTemplatesMedium.InitialLoad;
      IoCore.Console.WriteSuccessWithData(itoa(fCreatureTemplatesMedium.Items) + ' Creature Templates');
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
            IoCore.Console.WriteFailureWithData(RsDataCoreFileMustExit);
          end;
          MOF_OPT_ERR:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreBadOpt);
          end;
          MOF_INV_MED:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreUnkMed);
            raise ECoreOperationFailed.Create(E.Message);
          end;
        else
          raise;
        end;
      end;
    end;
     
  //------------------------------------------------------------------------------
  // [4.] DataCore - Loading Game Object Templates
  //------------------------------------------------------------------------------
    IoCore.Console.WriteLoadOf('TEMPLATE: Game Objects');

    try
      fGameObjectTemplatesMedium := InitMedium(SystemConfiguration.StringValue['Data',
        'GameObjectsTemplateDBType']);
      fGameObjectTemplatesMedium.Initialize(SystemConfiguration.StringValue['Data',
        'GameObjectsTemplateDBInfo'], False, YDbGameObjectTemplate, 'Game object templates');
      fGameObjectTemplatesMedium.InitialLoad;
      IoCore.Console.WriteSuccessWithData(itoa(fGameObjectTemplatesMedium.Items) + ' Game Object Templates');
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
            IoCore.Console.WriteFailureWithData(RsDataCoreFileMustExit);
          end;
          MOF_OPT_ERR:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreBadOpt);
          end;
          MOF_INV_MED:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreUnkMed);
            raise ECoreOperationFailed.Create(E.Message);
          end;
        else
          raise;
        end;
      end;
    end;

  //------------------------------------------------------------------------------
  // [5.] DataCore - Loading Quest Templates
  //------------------------------------------------------------------------------
    IoCore.Console.WriteLoadOf('TEMPLATE: Quests');

    try
      fQuestTemplatesMedium := InitMedium(SystemConfiguration.StringValue['Data', 'QuestTempDBType']);
      fQuestTemplatesMedium.Initialize(SystemConfiguration.StringValue['Data',
        'QuestTempDBInfo'], False, YDbQuestTemplate, 'Quest templates');
      fQuestTemplatesMedium.InitialLoad;
      IoCore.Console.WriteSuccessWithData(itoa(fQuestTemplatesMedium.Items) + ' Quest Templates');
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
            IoCore.Console.WriteFailureWithData(RsDataCoreFileMustExit);
          end;
          MOF_OPT_ERR:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreBadOpt);
          end;
          MOF_INV_MED:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreUnkMed);
            raise ECoreOperationFailed.Create(E.Message);
          end;
        else
          raise;
        end;
      end;
    end;

  //------------------------------------------------------------------------------
  // [6.] DataCore - Loading NPC Text Templates
  //------------------------------------------------------------------------------
    IoCore.Console.WriteLoadOf('TEMPLATE: NPC Texts');

    try
      fNPCTextTemplatesMedium := InitMedium(SystemConfiguration.StringValue['Data',
        'NPCTxtTempDBType']);
      fNPCTextTemplatesMedium.Initialize(SystemConfiguration.StringValue['Data',
        'NPCTxtTempDBInfo'], False, YDbNPCTextsTemplate, 'NPCtext templates');
      fNPCTextTemplatesMedium.InitialLoad;
      IoCore.Console.WriteSuccessWithData(itoa(fNPCTextTemplatesMedium.Items) + ' NPC Text Templates');
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
            IoCore.Console.WriteFailureWithData(RsDataCoreFileMustExit);
          end;
          MOF_OPT_ERR:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreBadOpt);
          end;
          MOF_INV_MED:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreUnkMed);
            raise ECoreOperationFailed.Create(E.Message);
          end;
        else
          raise;
        end;
      end;
    end;

  //------------------------------------------------------------------------------
  // [X.] DataCore - Loading XXXXXXXXXXXXX
  //------------------------------------------------------------------------------



  //------------------------------------------------------------------------------
  // DataCore - Loading Accounts and Objects
  //------------------------------------------------------------------------------
    IoCore.Console.WriteLoadOf('SAVES: Accounts');

    try
      fAccountsMedium := InitMedium(SystemConfiguration.StringValue['Data',
        'AccDBType']);
      fAccountsMedium.Initialize(SystemConfiguration.StringValue['Data',
        'AccDBInfo'], True, YDbAccountEntry, 'Accounts');
      fAccountsMedium.InitialLoad;
      IoCore.Console.WriteSuccessWithData(itoa(fAccountsMedium.Items) + ' Accounts');
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
            IoCore.Console.WriteFailureWithData(RsDataCoreFileNotExists);
          end;
          MOF_OPT_ERR:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreBadOpt);
          end;
          MOF_INV_MED:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreUnkMed);
            raise ECoreOperationFailed.Create(E.Message);
          end;
        else
          raise;
        end;
      end;
    end;

    IoCore.Console.WriteLoadOf('SAVES: Characters');

    try
     fPlayerStorageMedium := InitMedium(SystemConfiguration.StringValue['Data',
       'CharsDBType']);
      fPlayerStorageMedium.Initialize(SystemConfiguration.StringValue['Data',
        'CharsDBInfo'], True, YDbPlayerEntry, 'Players');
      fPlayerStorageMedium.InitialLoad;
      IoCore.Console.WriteSuccessWithData(itoa(fPlayerStorageMedium.Items) + ' Characters');
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
            IoCore.Console.WriteFailureWithData(RsDataCoreFileNotExists);
          end;
          MOF_OPT_ERR:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreBadOpt);
          end;
          MOF_INV_MED:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreUnkMed);
            raise ECoreOperationFailed.Create(E.Message);
          end;
        else
          raise;
        end;
      end;
    end;

    IoCore.Console.WriteLoadOf('SAVES: Items');

    try
      fItemStorageMedium := InitMedium(SystemConfiguration.StringValue['Data',
        'ItemsDBType']);
      fItemStorageMedium.Initialize(SystemConfiguration.StringValue['Data',
        'ItemsDBInfo'], True, YDbItemEntry, 'Items');
      fItemStorageMedium.InitialLoad;
      IoCore.Console.WriteSuccessWithData(itoa(fItemStorageMedium.Items) + ' Items');
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
            IoCore.Console.WriteFailureWithData(RsDataCoreFileNotExists);
          end;
          MOF_OPT_ERR:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreBadOpt);
          end;
          MOF_INV_MED:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreUnkMed);
            raise ECoreOperationFailed.Create(E.Message);
          end;
        else
          raise;
        end;
      end;
    end;

    IoCore.Console.WriteLoadOf('SAVES: Nodes');

    try
      fNodeStorageMedium := InitMedium(SystemConfiguration.StringValue['Data',
        'NodesDBType']);
      fNodeStorageMedium.Initialize(SystemConfiguration.StringValue['Data',
        'NodesDBInfo'], True, YDbNodeEntry, 'Nodes');
      fNodeStorageMedium.InitialLoad;
      IoCore.Console.WriteSuccessWithData(itoa(fNodeStorageMedium.Items) + ' Nodes');
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
            IoCore.Console.WriteFailureWithData(RsDataCoreFileNotExists);
          end;
          MOF_OPT_ERR:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreBadOpt);
          end;
          MOF_INV_MED:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreUnkMed);
            raise ECoreOperationFailed.Create(E.Message);
          end;
        else
          raise;
        end;
      end;
    end;

    IoCore.Console.WriteLoadOf('SAVES: Timers');

    try
      fTimerStorageMedium := InitMedium(SystemConfiguration.StringValue['Data',
        'TimersDBType']);
      fTimerStorageMedium.Initialize(SystemConfiguration.StringValue['Data',
        'TimersDBInfo'], True, YDbPersistentTimerEntry, 'Timers');
      fTimerStorageMedium.InitialLoad;
      IoCore.Console.WriteSuccessWithData(itoa(fTimerStorageMedium.Items) + ' Timers');
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
            IoCore.Console.WriteFailureWithData(RsDataCoreFileNotExists);
          end;
          MOF_OPT_ERR:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreBadOpt);
          end;
          MOF_INV_MED:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreUnkMed);
            raise ECoreOperationFailed.Create(E.Message);
          end;
        else
          raise;
        end;
      end;
    end;

    IoCore.Console.WriteLoadOf('SAVES: Addons');

    try
      fAddonsMedium := InitMedium(SystemConfiguration.StringValue['Data', 'AddonsDBType']);
      fAddonsMedium.Initialize(SystemConfiguration.StringValue['Data', 'AddonsDBInfo'],
        True, YDbAddonEntry, 'Addons');
      fAddonsMedium.InitialLoad;
      IoCore.Console.WriteSuccessWithData(itoa(fAddonsMedium.Items) + ' Addons');
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
            IoCore.Console.WriteFailureWithData(RsDataCoreFileNotExists);
          end;
          MOF_OPT_ERR:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreBadOpt);
          end;
          MOF_INV_MED:
          begin
            IoCore.Console.WriteFailureWithData(RsDataCoreUnkMed);
            raise ECoreOperationFailed.Create(E.Message);
          end;
        else
          raise;
        end;
      end;
    end;

    //------------------------------------------------------------------------------
    // DataCore - Loading profanity and reserved names lists
    //------------------------------------------------------------------------------
    fProfanityList := TStrArrayList.Create;
    fReservedNamesList := TStrArrayList.Create;

    fProfanityList.CaseSensitive := False;
    fProfanityList.Sorted := True;
    fReservedNamesList.CaseSensitive := False;
    fReservedNamesList.Sorted := True;

    LoadProfanityList;
    LoadReservedNamesList;

    //------------------------------------------------------------------------------
    // DataCore - Loading Maps
    //------------------------------------------------------------------------------
    try
      IoCore.Console.WriteLoadOfSub('Map Definitions');
      fWorldDataLoader := YDbWorldDataLoader.Create(FileNameToOS(SystemConfiguration.StringValue['Data', 'ServerMapDataDir']));
      fWorldDataLoader.Load;

      IoCore.Console.NewLine;
      IoCore.Console.WriteMapInfo(
        LIQUID_RES,
        HEIGHT_RES,
        CELLS_PER_TILE,

        fWorldDataLoader.MapCount,
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
        IoCore.Console.WriteSuccessWithData(itoa(fWorldDataLoader.IndexTableSize div 1024) + ' Kb');
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
            IoCore.Console.WriteSMDFileLoadError(FileNameToOS(SystemConfiguration.StringValue['Data', 'ServerMapDataDir']));
          end;
        else
          raise;
        end;
      end;
    end;

    fDecacheHandle := SystemTimer.RegisterEvent(OnDBDecache, DECACHE_TIME,
      TICK_EXECUTE_INFINITE, 'DataCore_DatabaseDecache_MainTimer');

  // Handling any medium exception !
  except
    on cEx: EMediumOperationFailed do
    begin
      IoCore.Console.WriteError;
      raise ECoreOperationFailed.Create(cEx.Message);
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
  SystemTimer.UnregisterEvent(fDecacheHandle);

  if fBeingSaved then
  begin
    fSynchLock.WaitFor(-1);
  end;

  fAccountsMedium.FinalSave;
  fPlayerStorageMedium.FinalSave;
  fItemStorageMedium.FinalSave;
  fNodeStorageMedium.FinalSave;
  fTimerStorageMedium.FinalSave;
  fAddonsMedium.FinalSave;

  fAccountsMedium.Free;
  fPlayerStorageMedium.Free;
  fItemStorageMedium.Free;
  fNodeStorageMedium.Free;
  fTimerStorageMedium.Free;
  fAddonsMedium.Free;

  fCharTemplateMedium.FinalSave;
  fCharTemplateMedium.Free;
  fCharTemplateStore.Free;

  fItemTemplatesMedium.FinalSave;
  fItemTemplatesMedium.Free;

  fQuestTemplatesMedium.FinalSave;
  fQuestTemplatesMedium.Free;

  fNPCTextTemplatesMedium.FinalSave;
  fNPCTextTemplatesMedium.Free;

  fCreatureTemplatesMedium.FinalSave;
  fCreatureTemplatesMedium.Free;

  fGameObjectTemplatesMedium.FinalSave;
  fGameObjectTemplatesMedium.Free;

  fWorldDataLoader.Free;

  fProfanityList.Free;
  fReservedNamesList.Free;

  fSynchLock.Delete;
  fRegisteredContextClasses.Free;
end;

procedure YDataCore.LoadProfanityList;
var
  cTemp: TStringList;
  iInt: Int32;
  sLine: string;
begin
  cTemp := TStringList.Create;
  try
    cTemp.LoadFromFile(FileNameToOS('{$YROOT}\Configuration\profanity.txt'));
    for iInt := 0 to cTemp.Count -1 do
    begin
      sLine := Trim(cTemp[iInt]);
      if (sLine[1] <> ';') or (sLine[2] <> ';') then
      begin
        if CharPos(' ', sLine) = 0 then
        begin
          fProfanityList.Add(sLine);
        end;
      end;
    end;
  finally
    cTemp.Free;
  end;
end;

procedure YDataCore.LoadReservedNamesList;
var
  cTemp: TStringList;
  iInt: Int32;
  sLine: string;
begin
  cTemp := TStringList.Create;
  try
    cTemp.LoadFromFile(FileNameToOS('{$YROOT}\Configuration\reserved_names.txt'));
    for iInt := 0 to cTemp.Count -1 do
    begin
      sLine := Trim(cTemp[iInt]);
      if (sLine[1] <> ';') or (sLine[2] <> ';') then
      begin
        if CharPos(' ', sLine) = 0 then
        begin
          fReservedNamesList.Add(sLine);
        end;
      end;
    end;
  finally
    cTemp.Free;
  end;
end;

//------------------------------------------------------------------------------
// Initialization of a medium (database engine) by it's type and options
// If you add a new medium engine please initialize it here!
//------------------------------------------------------------------------------
function YDataCore.InitMedium(const MediumType: string): YDbStorageMedium;
begin
  //------------------------------------------------------------------------------
  // Engine Derived mediums
  //------------------------------------------------------------------------------
  if StringsEqualNoCase(MediumType, 'PKTT') then
  begin
    Result := YDbPkTTMedium.Create;
  end else if StringsEqualNoCase(MediumType, 'DBC') then
  begin
    Result := YDbDbcMedium.Create;
  end else if StringsEqualNoCase(MediumType, 'PCP') then
  begin
    Result := YDbPcpMedium.Create;
  end else Result := nil;

  //------------------------------------------------------------------------------
  // If medium is not recognized then an "operation failed" exception will be raised
  // telling you that the medium is not supported (/yet)
  //------------------------------------------------------------------------------
  if not Assigned(Result) then
  begin
    if MediumType <> '' then
    begin
      raise EMediumOperationFailed.Create(Format(RsUnsupportedMedium, [MediumType]),
        MOF_INV_MED);
    end else
    begin
      raise EMediumOperationFailed.Create(RsNoMedium, MOF_INV_MED);
    end;
  end else Result.OnError := OnStorageError;
end;

type
  PInternalDecacheParams = ^YInternalDecacheParams;
  YInternalDecacheParams = record
    Core: YDataCore;
    Params: YDecacheParams;
  end;

function DecacheDatabase(pThrdData: PThreadData): Longword;
var
  pParams: PInternalDecacheParams;
  cDC: YDataCore;
  sTime: string;
begin
  pParams := pThrdData.Param;
  cDC := pParams^.Core;
  AtomicInc(@cDC.fBeingSaved);
  cDC.fSynchLock.Reset;

  StartExecutionTimer;
  cDC.PerformSave(pParams^.Params);
  sTime := itoa(Trunc32(StopExecutionTimer));

  cDC.fSynchLock.Signal;
  AtomicDec(@cDC.fBeingSaved);

  IoCore.Console.Writeln('=================================');
  IoCore.Console.WriteMultiple([
    'DB decache time: ~',
    sTime,
    ' ms.'],
    [15, 12, 15]);
  IoCore.Console.Writeln('=================================');

  Dispose(pParams);
  Dispose(pThrdData);
  Result := 0;
end;

procedure YDataCore.FindContextClassInfo(const ClassName: string;
  out Info: IClassTypeInfo);
begin
  Info := fRegisteredContextClasses.GetValue(ClassName) as IClassTypeInfo;
end;

function YDataCore.FullSave(bRefreshTimer: Boolean): Boolean;
var
  pThrdData: PThreadData;
  iPrio: TThreadPriority;
  pParams: PInternalDecacheParams;
begin
  if not fBeingSaved then
  begin
    IoCore.Console.WritelnMultiple([
      '=================================',
      'Periodic DB decache started.',
      '================================='],
      [15, 15, 15]);

    New(pParams);

    with pParams^ do
    begin
      Core := Self;
    end;

    New(pThrdData);
    StartThreadAtAddress(DecacheDatabase, pParams, True, pThrdData^);
    iPrio := tpLowest;
    ThreadModifyPriority(pThrdData^.Handle, iPrio, True);
    ThreadModifyState(pThrdData^.Handle, False);

    if bRefreshTimer then
    begin
      fDecacheHandle.RefreshCounters([rfTime]);
    end;
    
    Result := True;
  end else Result := False;
end;

procedure YDataCore.OnDBDecache(Event: TEventHandle; TimeDelta: UInt32);
begin
  FullSave(False);
  if bShuttingDown then
  begin
    fDecacheHandle.Unregister;
    fDecacheHandle := nil;
  end;
end;

procedure YDataCore.OnStorageError(Sender: YDbStorageMedium; const Msg: string);
var
  sName: string;
  cLog: TLogHandle;
begin
  sName := 'Errors/DB/' + StringReplace(Sender.Name, ' ', '_', [rfReplaceAll]) + '_errors.txt';
  cLog := Framework.SystemLogger.OpenLog(sName, True);
  cLog.Write(Msg);
end;

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

procedure YDataCore.RegisterContextClass(const ClassInfo: IClassTypeInfo);
var
  iIdx: Int32;
  ifInfo: IPropertyInfo;
begin
  fRegisteredContextClasses.PutValue(ClassInfo.Name, ClassInfo);
  for iIdx := 0 to ClassInfo.PropertyCount - 1 do
  begin
    ifInfo := ClassInfo.Properties[iIdx];
    if ifInfo.PropertyType.RttiType = tkClass then
    begin
      fRegisteredContextClasses.PutValue((ifInfo.PropertyType as IClassTypeInfo).Name,
        ifInfo.PropertyType as IClassTypeInfo);
    end;
  end;
end;

procedure YDataCore.RegisterContextClassAlias(const ClassInfo: IClassTypeInfo;
  const Alias: string);
begin
  fRegisteredContextClasses.PutValue(Alias, ClassInfo);
end;

procedure YDataCore.UnregisterContextClass(const ClassInfo: IClassTypeInfo);
var
  cStrList: TStrArrayList;
  ifItr: IStrIterator;
  sKey: string;
begin
  if fRegisteredContextClasses.Remove(ClassInfo.Name) <> nil then
  begin
    cStrList := TStrArrayList.Create;
    try
      ifItr := fRegisteredContextClasses.KeySet;
      while ifItr.HasNext do
      begin
        sKey := ifItr.Next;
        if fRegisteredContextClasses.GetValue(sKey) = ClassInfo then
        begin
          cStrList.Add(sKey);
        end;
      end;

      ifItr := cStrList.First;
      while ifItr.HasNext do
      begin
        fRegisteredContextClasses.Remove(ifItr.Next);
      end;
    finally
      cStrList.Free;
    end;
  end;
end;

end.
