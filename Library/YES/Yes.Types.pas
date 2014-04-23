{*------------------------------------------------------------------------------
  Public YAWE Extension Library
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

unit Yes.Types;
interface

uses
  Types;

const
  PM_RESERVED_MASK              = $80000000;
  PM_STOP                       = 0 or PM_RESERVED_MASK;
  PM_START                      = 1 or PM_RESERVED_MASK;
  PM_PLUGIN_LOADED              = 2 or PM_RESERVED_MASK;
  PM_PLUGIN_UNLOADED            = 3 or PM_RESERVED_MASK;
  PM_SET_UID                    = 4 or PM_RESERVED_MASK;

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
    VerString: string;
  end;

  PPluginInfo = ^TPluginInfo;
  TPluginInfo = record
    Version: TPluginVersionInfo;
    Name: string;
    Authors: array of string;
    Copyright: string;
    Info: string;
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

  TPluginMessageEvent = function(MsgId: Longword; ParamA, ParamB: Longword): Integer of object;

  IPlugin = interface(IInterface)
  ['{C2538F09-015E-458D-B190-F9246A9CA68A}']
    procedure GetPluginInfo(out Info: TPluginInfo);
    function GetUniqueId: TPluginId;
    
    function FormatMessageId(MsgId: Longword): string;
    function FormatError(ErrorCode: Integer): string;
  end;

  IPluginManager = interface(IInterface)
  ['{F9158F48-D188-4DFD-A69F-C105AB1EA255}']
    function RegisterPlugin(const Plugin: IPlugin; MsgEvent: TPluginMessageEvent): Boolean;
    function UnregisterPlugin(const APlugin: IPlugin): Boolean;

    function IsPluginLoaded(const PluginName: string): Boolean;
    function GetNumberOfPlugins: Integer;
    function GetNumberOfPluginPackages: Integer;
    procedure GetPluginIdList(var PluginIds: TPluginIdDynArray);
    procedure GetPluginNameList(var PluginNames: TStringDynArray);
    function GetPluginByName(const PluginName: string): IPlugin;
    function GetPluginById(PluginId: TPluginId): IPlugin;

    function SendMessage(const Sender, Receiver: IPlugin;
      MsgId: Longword; ParamA: Longword; ParamB: Longword): Boolean;

    function BroadcastMessage(const Sender: IPlugin; MsgId: Longword;
      ParamA: Longword; ParamB: Longword): Boolean;

    procedure GetManagerInfo(var Info: TPluginManagerInfo);
  end;

  IYaweLogonServices = interface(IInterface)
  ['{E3A0862D-F0B7-4185-9741-20B4CF321D7C}']
    function DisconnectAccount(const sAccount: string): Boolean;
    function BanAccount(const sAccount: string; bDisconnect: Boolean): Boolean;
    function UnbanAccount(const sAccount: string): Boolean;
  end;

  TPlugin = class(TInterfacedObject, IPlugin)
    protected
      FManager: IPluginManager;
      FId: TPluginId;

      function ManagerMessageHandler(AMsgId: Longword; AParamA, AParamB: Longword): Integer; virtual;
      function PluginMessageHandler(AMsgId: Longword; AParamA, AParamB: Longword): Integer; virtual;

      function MessageHandler(AMsgId: Longword; AParamA, AParamB: Longword): Integer; virtual;

      procedure PluginLoaded(const APlugin: IPlugin); virtual;
      procedure PluginUnloaded(const APlugin: IPlugin); virtual;
    public
      constructor Create(const AManager: IPluginManager); 
      destructor Destroy; override;

      procedure Initialize; virtual;
      procedure Finalize; virtual;

      procedure SendMessage(const AReceiver: IPlugin; AMsgId: Longword;
        AParamA, AParamB: Longword);

      procedure BroadcastMessage(AMsgId: Longword; AParamA, AParamB: Longword);

      function GetUniqueId: TPluginId;
      procedure GetPluginInfo(out AInfo: TPluginInfo); virtual; abstract;

      function FormatMessageId(AMsgId: Longword): string; virtual;
      function FormatError(AError: Integer): string; virtual;
  end;

implementation

{ TPlugin }

constructor TPlugin.Create(const AManager: IPluginManager);
begin
  inherited Create;
  FManager := AManager;
end;

destructor TPlugin.Destroy;
begin
  FManager := nil;
  inherited Destroy;
end;

procedure TPlugin.Initialize;
begin
end;

procedure TPlugin.Finalize;
begin
end;

function TPlugin.MessageHandler(AMsgId, AParamA, AParamB: Longword): Integer;
begin
  if (AMsgId and PM_RESERVED_MASK) = 0 then
  begin
    Result := PluginMessageHandler(AMsgId, AParamA, AParamB);
  end else
  begin
    Result := ManagerMessageHandler(AMsgId, AParamA, AParamB);
  end;
end;

function TPlugin.PluginMessageHandler(AMsgId, AParamA,
  AParamB: Longword): Integer;
begin
  Result := 0;
end;

function TPlugin.ManagerMessageHandler(AMsgId, AParamA,
  AParamB: Longword): Integer;
begin
  case AMsgId of
    PM_START: Initialize;
    PM_STOP: Finalize;
    PM_PLUGIN_LOADED: PluginLoaded(IPlugin(AParamA));
    PM_PLUGIN_UNLOADED: PluginUnloaded(IPlugin(AParamA));
    PM_SET_UID: FId := TPluginId(AParamA);
  end;
  Result := 0;
end;

procedure TPlugin.PluginLoaded(const APlugin: IPlugin);
begin
end;

procedure TPlugin.PluginUnloaded(const APlugin: IPlugin);
begin
end;

function TPlugin.FormatError(AError: Integer): string;
begin
  Result := '';
end;

function TPlugin.FormatMessageId(AMsgId: Longword): string;
begin
  Result := '';
end;

function TPlugin.GetUniqueId: TPluginId;
begin
  Result := FId;
end;

procedure TPlugin.SendMessage(const AReceiver: IPlugin; AMsgId: Longword;
  AParamA, AParamB: Longword);
begin
  FManager.SendMessage(Self, AReceiver, AMsgId, AParamA, AParamB);
end;

procedure TPlugin.BroadcastMessage(AMsgId, AParamA, AParamB: Longword);
begin
  FManager.BroadcastMessage(Self, AMsgId, AParamA, AParamB);
end;

end.
