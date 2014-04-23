{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Provides Plugin Management System
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

unit Bfg.PluginSystem;

interface

uses
  Bfg.Utils,
  Bfg.Containers,
  Bfg.Threads,
  SysUtils,
  Bfg.Algorithm{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

//==============================================================================
// Reserved plugin messages
//==============================================================================

const
  PM_RESERVED_MASK              = $80000000;
  PM_STOP                       = 0 or PM_RESERVED_MASK;
  PM_START                      = 1 or PM_RESERVED_MASK;
  PM_PLUGIN_LOADED              = 2 or PM_RESERVED_MASK;
  PM_PLUGIN_UNLOADED            = 3 or PM_RESERVED_MASK;
  PM_SET_UID                    = 4 or PM_RESERVED_MASK;

//==============================================================================
// Type declarations
//==============================================================================

type
  {$Z4}
  TPluginVersionType = (vtNull, vtAlfa, vtBeta, vtRelease);
  {$Z1}

  PPluginVersionInfo = ^TPluginVersionInfo;
  TPluginVersionInfo = record
    VerMajor,
    VerMinor,
    VerRevision,
    VerBuild: Byte;
    VerType: TPluginVersionType;
    VerString: PWideChar;
  end;

  PPluginInfo = ^TPluginInfo;
  TPluginInfo = record
    Version: TPluginVersionInfo;
    Name: PWideChar;
    Authors: PPWideCharArray;
    AuthorCount: Integer;
    Copyright: PWideChar;
    Info: PWideChar;
  end;

  PPluginManagerInfo = ^TPluginManagerInfo;
  TPluginManagerInfo = record
    Version: TPluginVersionInfo;
  end;

  PPluginId = ^TPluginId;
  TPluginId = type Longword;
  TPluginIdDynArray = array of TPluginId;

  IPlugin = interface;
  IPluginManager = interface;
  TPluginManager = class;

  TPluginMessageEvent = function(Context: Pointer; MsgId: Longword; ParamA, ParamB: Longword): Integer; stdcall;

  PPerPluginPackageData = ^TPerPluginPackageData;
  TPerPluginPackageData = record
    FileName: PChar;
    BaseName: PChar;
    Module: HMODULE;
    Plugins: array of IPlugin;
  end;

  PPerPluginData = ^TPerPluginData;
  TPerPluginData = record
    Plugin: IPlugin;
    Uid: TPluginId;
    Info: TPluginInfo;
    MessageHandler: TPluginMessageEvent;
    Ctx: Pointer;
    OwnerPackage: PPerPluginPackageData;
  end;

  //============================================================================
  // Event prototypes
  //============================================================================

  { Function prototype for the main plugin package function }
  TPluginPackageInitProc = function(const Manager: IPluginManager): Boolean;

  { A generic Package Save/Load event }
  TPluginPackageGenericEvent = procedure(Manager: TPluginManager;
    const PackageName: string) of object;

  { A generic Plugin Save/Load event }
  TPluginGenericEvent = procedure(Manager: TPluginManager; const Plugin: IPlugin) of object;

  { Plugin message processed event }
  TPluginMessageProcessedEvent = procedure(Manager: TPluginManager;
    const Plugin: IPlugin; MsgId: Longword) of object;

  { Plugin message ignore event prototype }
  TPluginMessageIgnoreEvent = procedure(Manager: TPluginManager;
    const Plugin: IPlugin; MsgId: Longword) of object;

  { Plugin message exception event prototype }
  TPluginMessageExceptionEvent = procedure(Manager: TPluginManager;
    const Plugin: IPlugin; MsgId: Longword; ErrorCode: Integer) of object;

  { Plugin invalid message event prototype }
  TPluginInvalidMessageEvent = procedure(Manager: TPluginManager;
    const Plugin: IPlugin; MsgId: Longword) of object;

  { Plugin security check event prototype }
  TPluginSecurityCheckEvent = procedure(Manager: TPluginManager;
    const Info: TPluginInfo; out Success: Boolean) of object;

  //============================================================================
  // IPlugin and IPluginManager interfaces
  //============================================================================

  IPlugin = interface(IInterface)
  ['{C2538F09-015E-458D-B190-F9246A9CA68A}']
    procedure GetPluginInfo(out Info: TPluginInfo); stdcall;
    function GetUniqueId: Longword; stdcall;
    
    function FormatMessageId(MsgId: Longword): PWideChar; stdcall;
    function FormatError(ErrorCode: Integer): PWideChar; stdcall;
  end;

  IPluginManager = interface(IInterface)
  ['{F9158F48-D188-4DFD-A69F-C105AB1EA255}']
    function RegisterPlugin(const Plugin: IPlugin; MsgEvent: TPluginMessageEvent; Ctx: Pointer): Boolean; stdcall;
    function UnregisterPlugin(const Plugin: IPlugin): Boolean; stdcall;

    function IsPluginLoaded(PluginName: PWideChar): Boolean; stdcall;
    function GetNumberOfPlugins: Integer; stdcall;
    function GetNumberOfPluginPackages: Integer; stdcall;
    procedure GetPluginIdList(var PluginIds: TPluginIdDynArray); stdcall;
    function GetPluginNameList: PPWideCharArray; stdcall;
    function GetPluginByName(PluginName: PWideChar): IPlugin; stdcall;
    function GetPluginById(PluginId: TPluginId): IPlugin; stdcall;

    function SendMessage(const Sender, Receiver: IPlugin;
      MsgId: Longword; ParamA: Longword; ParamB: Longword): Boolean; stdcall;

    function BroadcastMessage(const Sender: IPlugin; MsgId: Longword;
      ParamA: Longword; ParamB: Longword): Boolean; stdcall;

    procedure GetManagerInfo(var Info: TPluginManagerInfo); stdcall;
  end;

  //============================================================================
  // TPluginManager class
  //============================================================================
  TPluginManager = class(TObject, IInterface, IPluginManager)
    private
      FOnPackageLoad: TPluginPackageGenericEvent;
      FOnPackageUnload: TPluginPackageGenericEvent;
      FOnPluginLoad: TPluginGenericEvent;
      FOnPluginUnload: TPluginGenericEvent;
      FOnPluginMessageProcessed: TPluginMessageProcessedEvent;
      FOnPluginMessageIgnore: TPluginMessageIgnoreEvent;
      FOnPluginMessageException: TPluginMessageExceptionEvent;
      FOnPluginInvalidMessage: TPluginInvalidMessageEvent;
      FOnPluginSecurityCheck: TPluginSecurityCheckEvent;
    protected
      FPluginPackageData: TStrPtrHashMap;
      FPluginData: TStrPtrHashMap;
      FPluginList: array of TPerPluginData;
      FUsedUids: array of TPluginId;
      FUnusedUids: array of TPluginId;

      procedure DoOnPackageLoad(const APackage: string);
      procedure DoOnPackageUnload(const APackage: string);
      procedure DoOnPluginLoad(const APlugin: IPlugin; ANotifySelf: Boolean = False);
      procedure DoOnPluginUnload(const APlugin: IPlugin; ANotifySelf: Boolean = False);
      procedure DoOnPluginMessageProcessed(const APlugin: IPlugin; AMsgId: Longword);
      procedure DoOnPluginMessageIgnore(const APlugin: IPlugin; AMsgId: Longword);
      procedure DoOnPluginMessageException(const APlugin: IPlugin;
        AMsgId: Longword; AErrorCode: Integer);
      procedure DoOnPluginInvalidMessage(const APlugin: IPlugin; AMsgId: Longword);
      procedure DoOnPluginSecurityCheck(const AInfo: TPluginInfo; out ASuccess: Boolean);

      function InternalLookupPackageData(AAddr: Pointer): Pointer;

      function InternalGetUid: TPluginId; virtual;
      procedure InternalRecycleUid(AUid: TPluginId); virtual;
      function InternalIsUidValid(AUid: TPluginId): Boolean; virtual;

      function InternalMessageCheck(AUid: TPluginId; AMsgId: Longword): Integer; virtual;

      procedure InternalSendMessage(AReceiver: TPluginId; AMsgId: Longword;
        AParamA: Longword; AParamB: Longword); virtual;

      procedure InternalBroadcastMessage(AMsgId: Longword; AParamA: Longword;
        AParamB: Longword; AExcluding: TPluginId = $FFFFFFFF); virtual;

      class procedure FillVersion(var AInfo: TPluginManagerInfo); virtual; abstract;
    public
      constructor Create; virtual;
      destructor Destroy; override;

      function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
      function _AddRef: Integer; stdcall;
      function _Release: Integer; stdcall;

      procedure Start; virtual;
      procedure Stop; virtual;

      function RegisterPlugin(const APlugin: IPlugin; AMsgEvent: TPluginMessageEvent; Ctx: Pointer): Boolean; stdcall;
      function UnregisterPlugin(const APlugin: IPlugin): Boolean; stdcall;

      function LoadPluginPackage(const APackagePath: string): Integer; virtual;

      procedure LoadPluginPackages(const APackageDir: string; const AMasks: array of string); overload;
      procedure LoadPluginPackages(const APackagePaths: array of string); overload;

      function UnloadPluginPackage(APackageData: PPerPluginPackageData): Boolean; overload;
      function UnloadPluginPackage(const APackageName: string): Boolean; overload;

      procedure UnloadAllPluginPackages;

      function IsPluginLoaded(PluginName: PWideChar): Boolean; virtual; stdcall;
      function GetNumberOfPlugins: Integer; virtual; stdcall;
      function GetNumberOfPluginPackages: Integer; virtual; stdcall;
      procedure GetPluginIdList(var APluginIds: TPluginIdDynArray); virtual; stdcall;
      function GetPluginNameList: PPWideCharArray; virtual; stdcall;
      function GetPluginByName(PluginName: PWideChar): IPlugin; virtual; stdcall;
      function GetPluginById(APluginId: TPluginId): IPlugin; virtual; stdcall;

      function SendMessage(const ASender, AReceiver: IPlugin;
        AMsgId: Longword; AParamA: Longword; AParamB: Longword): Boolean; virtual; stdcall;

      function BroadcastMessage(const ASender: IPlugin; AMsgId: Longword;
        AParamA: Longword; AParamB: Longword): Boolean; virtual; stdcall;

      procedure GetManagerInfo(var AInfo: TPluginManagerInfo); stdcall;

      property OnPackageLoad: TPluginPackageGenericEvent read FOnPackageLoad write FOnPackageLoad;
      property OnPackageUnload: TPluginPackageGenericEvent read FOnPackageUnload write FOnPackageUnload;
      property OnPluginLoad: TPluginGenericEvent read FOnPluginLoad write FOnPluginLoad;
      property OnPluginUnload: TPluginGenericEvent read FOnPluginUnload write FOnPluginUnload;
      property OnPluginMessageProcessed: TPluginMessageProcessedEvent read FOnPluginMessageProcessed write FOnPluginMessageProcessed;
      property OnPluginMessageIgnore: TPluginMessageIgnoreEvent read FOnPluginMessageIgnore write FOnPluginMessageIgnore;
      property OnPluginInvalidMessage: TPluginInvalidMessageEvent read FOnPluginInvalidMessage write FOnPluginInvalidMessage;
      property OnPluginMessageException: TPluginMessageExceptionEvent read FOnPluginMessageException write FOnPluginMessageException;
      property OnPluginSecurityCheck: TPluginSecurityCheckEvent read FOnPluginSecurityCheck write FOnPluginSecurityCheck;
  end;

const
  PLG_ERR_OK                                   = 0;
  PLG_ERR_UNK_ERROR                            = 1;
  PLG_ERR_NOT_FOUND                            = 2;
  PLG_ERR_INVALID_PLUGIN                       = 3;
  PLG_ERR_PLUGIN_STARTUP_FAILED                = 4;

implementation

uses
  Math,
  API.Win.Types,
  API.Win.NtCommon,
  API.Win.Kernel;

const
  NullPluginData: TPerPluginData = (
    Plugin: nil;
    Uid: 0;
    Info: (
      Version: (
        VerMajor: 0;
        VerMinor: 0;
        VerRevision: 0;
        VerBuild: 0;
        VerType: vtNull;
        VerString: '';
      );
      Name: '';
      Authors: nil;
      Copyright: '';
      Info: '';
    );
    MessageHandler: nil;
    Ctx: nil;
    OwnerPackage: nil;
  );

{ TPluginManager }

constructor TPluginManager.Create;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,740 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FPluginPackageData := TStrPtrHashMap.Create(False, 128);
  FPluginData := TStrPtrHashMap.Create(False, 1024);
  SetLength(FPluginList, 1024);
  SetLength(FUnusedUids, 1024);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,740; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TPluginManager.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,741 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  UnloadAllPluginPackages;

  FPluginData.Free;
  FPluginPackageData.Free;

  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,741; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.Start;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,742 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  InternalBroadcastMessage(PM_START, 0, 0);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,742; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.Stop;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,743 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  InternalBroadcastMessage(PM_STOP, 0, 0);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,743; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager.InternalLookupPackageData(AAddr: Pointer): Pointer;
var
  Itr: IPtrIterator;
  Lib: HMODULE;
  Data: PPerPluginPackageData;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,744 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Lib := FindHInstance(AAddr);
  Itr := FPluginPackageData.Values;
  while Itr.HasNext do
  begin
    Data := Itr.Next;
    if Data^.Module = Lib then
    begin
      Result := Data;
      Exit;
    end;
  end;
  Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,744; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager.InternalMessageCheck(AUid: TPluginId;
  AMsgId: Longword): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,745 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if InternalIsUidValid(AUid) then
  begin
    if (AMsgId and PM_RESERVED_MASK) <> 0 then
    begin
      Result := 2;
    end else Result := 0;
  end else Result := 1;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,745; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager.InternalGetUid: TPluginId;
const
  ARRAY_ENLARGE_DELTA = 128;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,746 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Length(FUnusedUids) <> 0 then
  begin
    I := Length(FUnusedUids) - 1;
    Result := FUnusedUids[I];
    SetLength(FUnusedUids, I);
  end else
  begin
    Result := Length(FPluginList);
    SetLength(FPluginList, Result + ARRAY_ENLARGE_DELTA);
    SetLength(FUnusedUids, ARRAY_ENLARGE_DELTA - 1);
    for I := 0 to ARRAY_ENLARGE_DELTA -2 do
    begin
      FUnusedUids[I] := Result + TPluginId(I);
    end;
  end;
  I := Length(FUsedUids);
  SetLength(FUsedUids, I + 1);
  FUsedUids[I] := Result;
  SortArray(@FUsedUids[0], I + 1);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,746; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.InternalRecycleUid(AUid: TPluginId);
var
  I: Integer;
  J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,747 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  I := Length(FUnusedUids);
  SetLength(FUnusedUids, I + 1);
  FUnusedUids[I] := AUid;
  I := Length(FUsedUids) -1;
  for J := 0 to Length(FUsedUids) -2 do
  begin
    if FUsedUids[J] = AUid then
    begin
      FUsedUids[J] := FUsedUids[I];
      Break;
    end;
  end;
  SetLength(FUsedUids, I);
  SortArray(@FUsedUids[0], I);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,747; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager.InternalIsUidValid(AUid: TPluginId): Boolean;
var
  Res: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,748 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Res := BinarySearch(Pointer(AUid), @FUsedUids[0], Length(FUsedUids));
  if Res <> -1 then
  begin
    Result := FPluginList[Res].Uid = AUid;
  end else Result := False;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,748; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.InternalSendMessage(AReceiver: TPluginId; AMsgId,
  AParamA, AParamB: Longword);
var
  Res: Integer;
  Data: PPerPluginData;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,749 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Data := @FPluginList[AReceiver];
  Res := Data^.MessageHandler(Data^.Ctx, AMsgId, AParamA, AParamB);
  case Res of
    0: DoOnPluginMessageProcessed(Data^.Plugin, AMsgId);
    -1: DoOnPluginMessageIgnore(Data^.Plugin, AMsgId);
  else
    DoOnPluginMessageException(Data^.Plugin, AMsgId, Res);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,749; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.InternalBroadcastMessage(AMsgId, AParamA,
  AParamB: Longword; AExcluding: TPluginId);
var
  Res: Integer;
  I: Integer;
  Data: PPerPluginData;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,750 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AExcluding = $FFFFFFFF then
  begin
    for I := 0 to Length(FUsedUids) -1 do
    begin
      Data := @FPluginList[FUsedUids[I]];
      if Data^.Plugin = nil then Continue;
      Res := Data^.MessageHandler(Data^.Ctx, AMsgId, AParamA, AParamB);
      case Res of
        0: DoOnPluginMessageProcessed(Data^.Plugin, AMsgId);
        -1: DoOnPluginMessageIgnore(Data^.Plugin, AMsgId);
      else
        DoOnPluginMessageException(Data^.Plugin, AMsgId, Res);
      end;
    end;
  end else
  begin
    for I := 0 to Length(FUsedUids) -1 do
    begin
      if FUsedUids[I] <> AExcluding then
      begin
        Data := @FPluginList[FUsedUids[I]];
        if Data^.Plugin = nil then Continue;
        Res := Data^.MessageHandler(Data^.Ctx, AMsgId, AParamA, AParamB);
        case Res of
          0: DoOnPluginMessageProcessed(Data^.Plugin, AMsgId);
          -1: DoOnPluginMessageIgnore(Data^.Plugin, AMsgId);
        else
          DoOnPluginMessageException(Data^.Plugin, AMsgId, Res);
        end;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,750; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager.RegisterPlugin(const APlugin: IPlugin;
  AMsgEvent: TPluginMessageEvent; Ctx: Pointer): Boolean;
var
  Data: TPerPluginData;
  SecurityOk: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,751 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Assigned(APlugin) and Assigned(AMsgEvent) then
  begin
    APlugin.GetPluginInfo(Data.Info);
    DoOnPluginSecurityCheck(Data.Info, SecurityOk);
    if SecurityOk then
    begin
      Data.Plugin := APlugin;
      Data.Uid := InternalGetUid;
      Data.MessageHandler := AMsgEvent;
      Data.Ctx := Ctx;
      Data.OwnerPackage := InternalLookupPackageData(GetCurrentReturnAddress);

      SetLength(Data.OwnerPackage^.Plugins, Length(Data.OwnerPackage^.Plugins) + 1);
      Data.OwnerPackage^.Plugins[Length(Data.OwnerPackage^.Plugins)-1] := Data.Plugin;

      FPluginList[Data.Uid] := Data;
      FPluginData.PutValue(Data.Info.Name, @FPluginList[Data.Uid]);

      InternalSendMessage(Data.Uid, PM_SET_UID, Data.Uid, 0);
      DoOnPluginLoad(APlugin);

      Result := True;
    end else Result := False;
  end else Result := False;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,751; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager.UnregisterPlugin(const APlugin: IPlugin): Boolean;
var
  Uid: TPluginId;
  I: Integer;
  Data: PPerPluginData;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,752 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if APlugin = nil then
  begin
    Result := False;
    Exit;
  end;
  
  Uid := APlugin.GetUniqueId;
  if InternalIsUidValid(Uid) then
  begin
    Data := @FPluginList[Uid];
    if Data^.Plugin = APlugin then
    begin
      if Data^.OwnerPackage^.Plugins[High(Data^.OwnerPackage^.Plugins)] <> APlugin then
      begin
        for I := Length(Data^.OwnerPackage^.Plugins) -2 downto 0 do
        begin
          if Data^.OwnerPackage^.Plugins[I] = APlugin then
          begin
            Data^.OwnerPackage^.Plugins[I] := Data^.OwnerPackage^.Plugins[High(Data^.OwnerPackage^.Plugins)];
            Break;
          end;
        end;
      end;

      SetLength(Data^.OwnerPackage^.Plugins, Max(High(Data^.OwnerPackage^.Plugins), 0));

      DoOnPluginUnload(APlugin);
      
      FPluginData.Remove(Data^.Info.Name);
      FPluginList[Uid] := NullPluginData;
      InternalRecycleUid(Uid);
      Result := True;
    end else Result := False;
  end else Result := False;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,752; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.GetManagerInfo(var AInfo: TPluginManagerInfo);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,753 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FillVersion(AInfo);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,753; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager.GetNumberOfPluginPackages: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,754 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FPluginPackageData.Size;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,754; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager.GetNumberOfPlugins: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,755 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FPluginData.Size;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,755; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager.GetPluginByName(PluginName: PWideChar): IPlugin;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,756 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := IPlugin(FPluginData.GetValue(PluginName));
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,756; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager.GetPluginById(APluginId: TPluginId): IPlugin;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,757 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if InternalIsUidValid(APluginId) then
  begin
    Result := FPluginList[APluginId].Plugin;
  end else Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,757; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.GetPluginIdList(var APluginIds: TPluginIdDynArray);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,758 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SetLength(APluginIds, Length(FUsedUids));
  Move(FUsedUids[0], APluginIds[0], Length(APluginIds) * SizeOf(TPluginId));
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,758; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager.GetPluginNameList: PPWideCharArray;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,759 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,759; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;
(*
var
  I: Integer;
begin
  SetLength(APluginNames, Length(FUsedUids));
  for I := 0 to Length(APluginNames) -1 do
  begin
    APluginNames[I] := FPluginList[FUsedUids[I]].Info.Name;
  end;
end;
*)

function TPluginManager.IsPluginLoaded(PluginName: PWideChar): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,760 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FPluginData.ContainsKey(PluginName);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,760; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager.SendMessage(const ASender, AReceiver: IPlugin;
  AMsgId: Longword; AParamA: Longword; AParamB: Longword): Boolean;
var
  Uid1, Uid2: TPluginId;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,761 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Uid1 := ASender.GetUniqueId;
  Uid2 := AReceiver.GetUniqueId;
  if InternalMessageCheck(Uid1, AMsgId) = 0 then
  begin
    if InternalIsUidValid(Uid2) then
    begin
      InternalSendMessage(Uid1, AMsgId, AParamA, AParamB);
      Result := True;
    end else Result := False;
  end else
  begin
    DoOnPluginInvalidMessage(ASender, AMsgId);
    Result := False;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,761; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager.BroadcastMessage(const ASender: IPlugin;
  AMsgId, AParamA, AParamB: Longword): Boolean;
var
  Uid: TPluginId;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,762 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Uid := ASender.GetUniqueId;
  if InternalMessageCheck(Uid, AMsgId) = 0 then
  begin
    InternalBroadcastMessage(AMsgId, AParamA, AParamB);
    Result := True;
  end else
  begin
    DoOnPluginInvalidMessage(ASender, AMsgId);
    Result := False;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,762; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager.LoadPluginPackage(const APackagePath: string): Integer;
var
  Lib: HMODULE;
  InitProc: TPluginPackageInitProc;
  PackageData: PPerPluginPackageData;
  ModFileName: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,763 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Lib := SafeLoadLibrary(APackagePath);
  if Lib <> 0 then
  begin
    InitProc := GetProcAddress(Lib, 'RegisterPluginModules');
    if Assigned(InitProc) then
    begin
      ModFileName := GetModuleName(Lib);
      New(PackageData);
      PackageData^.Module := Lib;
      GetMem(PackageData^.FileName, Length(ModFileName) + 1);
      StrPCopy(PackageData^.FileName, ModFileName);
      PackageData^.BaseName := PackageData^.FileName + LastDelimiter(PathDelim + DriveDelim, ModFileName);
      FPluginPackageData.PutValue(PackageData^.BaseName, PackageData);
      
      if InitProc(Self) then
      begin
        DoOnPackageLoad(APackagePath);
        Result := PLG_ERR_OK;
      end else
      begin
        FPluginPackageData.Remove(PackageData^.BaseName);
        Dispose(PackageData);
        FreeLibrary(Lib);
        Result := PLG_ERR_PLUGIN_STARTUP_FAILED;
      end;
    end else
    begin
      FreeLibrary(Lib);
      Result := PLG_ERR_INVALID_PLUGIN;
    end;
  end else Result := PLG_ERR_NOT_FOUND;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,763; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.LoadPluginPackages(const APackageDir: string;
  const AMasks: array of string);
var
  Plugins: TStringDynArray;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,764 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  BuildFileList(APackageDir, faArchive, Plugins, AMasks);
  LoadPluginPackages(Plugins);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,764; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.LoadPluginPackages(const APackagePaths: array of string);
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,765 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := Low(APackagePaths) to High(APackagePaths) do
  begin
    LoadPluginPackage(APackagePaths[I]);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,765; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager.UnloadPluginPackage(APackageData: PPerPluginPackageData): Boolean;
var
  I: Integer;
  Lib: HMODULE;
  Name: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,766 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if APackageData <> nil then
  begin
    for I := 0 to Length(APackageData^.Plugins) -1 do
    begin
      UnregisterPlugin(APackageData^.Plugins[I]);
    end;
    Lib := APackageData^.Module;
    Name := APackageData^.FileName;
    FreeMem(APackageData^.FileName);
    FreeLibrary(Lib);
    DoOnPackageUnload(Name);
    Dispose(APackageData);
    Result := True;
  end else Result := False;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,766; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager.UnloadPluginPackage(const APackageName: string): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,767 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := UnloadPluginPackage(FPluginPackageData.Remove(APackageName));
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,767; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.UnloadAllPluginPackages;
var
  Itr: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,768 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FPluginPackageData.Size = 0 then Exit;
  Itr := FPluginPackageData.Values;
  while Itr.HasNext do
  begin
    UnloadPluginPackage(Itr.Next);
  end;
  FPluginPackageData.Clear;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,768; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.DoOnPackageLoad(const APackage: string);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,769 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Assigned(FOnPackageLoad) then FOnPackageLoad(Self, APackage);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,769; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.DoOnPackageUnload(const APackage: string);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,770 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Assigned(FOnPackageUnload) then FOnPackageUnload(Self, APackage);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,770; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.DoOnPluginInvalidMessage(const APlugin: IPlugin;
  AMsgId: Longword);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,771 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Assigned(FOnPluginInvalidMessage) then FOnPluginInvalidMessage(Self, APlugin,
    AMsgId);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,771; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.DoOnPluginMessageException(const APlugin: IPlugin;
  AMsgId: Longword; AErrorCode: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,772 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Assigned(FOnPluginMessageException) then FOnPluginMessageException(Self, APlugin,
    AMsgId, AErrorCode);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,772; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.DoOnPluginMessageIgnore(const APlugin: IPlugin;
  AMsgId: Longword);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,773 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Assigned(FOnPluginMessageIgnore) then FOnPluginMessageIgnore(Self, APlugin,
    AMsgId);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,773; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.DoOnPluginMessageProcessed(const APlugin: IPlugin;
  AMsgId: Longword);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,774 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Assigned(FOnPluginMessageProcessed) then FOnPluginMessageProcessed(Self, APlugin,
    AMsgId);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,774; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.DoOnPluginLoad(const APlugin: IPlugin; ANotifySelf: Boolean);
var
  ID: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,775 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Assigned(FOnPluginLoad) then FOnPluginLoad(Self, APlugin);
  if ANotifySelf then
  begin
    InternalBroadcastMessage(PM_PLUGIN_LOADED, APlugin.GetUniqueId, 0);
  end else
  begin
    ID := APlugin.GetUniqueId;
    InternalBroadcastMessage(PM_PLUGIN_LOADED, ID, 0, ID);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,775; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.DoOnPluginUnload(const APlugin: IPlugin; ANotifySelf: Boolean);
var
  ID: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,776 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ANotifySelf then
  begin
    InternalBroadcastMessage(PM_PLUGIN_UNLOADED, APlugin.GetUniqueId, 0);
  end else
  begin
    ID := APlugin.GetUniqueId;
    InternalBroadcastMessage(PM_PLUGIN_UNLOADED, ID, 0, ID);
  end;
  if Assigned(FOnPluginUnload) then FOnPluginUnload(Self, APlugin);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,776; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPluginManager.DoOnPluginSecurityCheck(const AInfo: TPluginInfo;
  out ASuccess: Boolean);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,777 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Assigned(FOnPluginSecurityCheck) then FOnPluginSecurityCheck(Self, AInfo, ASuccess) else ASuccess := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,777; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,778 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,778; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager._AddRef: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,779 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,779; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPluginManager._Release: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,780 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,780; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

end.
