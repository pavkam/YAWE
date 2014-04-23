{*------------------------------------------------------------------------------
  Main NetworkCore Object. Provides Basic Networking.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.NetworkCore;

interface

uses
  Framework.Base,
  Components.NetworkCore.Logon,
  Components.NetworkCore.World,
  Components.NetworkCore.Patches,
  Components.NetworkCore.Realm,
  SysUtils,
  Components;

type
  YNetworkCore = class(YBaseCore)
    private
      fLogonManager: YNwLogonSocketManager;
      fWorldManager: YNwWorldSocketManager;
      fPatchManager: YNwPatchManager;
      fRealmList: YNwRealmList;
      function GetLogonThreads: Integer;
      function GetRealmThreads: Integer;
    protected
      procedure CoreInitialize; override;
      procedure CoreStart; override;       
      procedure CoreStop; override;
    public
      property LogonServer: YNwLogonSocketManager read fLogonManager;
      property WorldServer: YNwWorldSocketManager read fWorldManager;
      property LogonThreads: Integer read GetLogonThreads;
      property RealmThreads: Integer read GetRealmThreads;
      property Patches: YNwPatchManager read fPatchManager;
      property Realms: YNwRealmList read fRealmList;
    end;

implementation

uses
  Framework,
  Resources,
  Misc.Containers,
  Misc.Miscleanous;

{ YNetworkCore }

procedure YNetworkCore.CoreInitialize;
  function ConvertIP(const sIP: string): Longword;
  var
    aStrs: array[0..3] of string;
  begin
    if StringSplit(sIP, aStrs, '.') then
    begin
      try
        Result := StrToInt(aStrs[0]) or (StrToInt(aStrs[1]) shl 8) or
                  (StrToInt(aStrs[2]) shl 16) or (StrToInt(aStrs[3]) shl 24);
      except
        Result := 0;
      end;
    end else Result := 0;
  end;
var
  aStrs: TStringDynArray;
  iIdx: Integer;
begin
  aStrs := StringSplit(SystemConfiguration.StringValue['Network', 'BannedIPs']);

  { Logon Manager }
  try
    fLogonManager := YNwLogonSocketManager.Create;
    for iIdx := 0 to High(aStrs) do
    begin
      fLogonManager.AddToPermanentBanList(ConvertIP(aStrs[iIdx]));
    end;
  except
    raise ECoreOperationFailed.CreateResFmt(@RsNetworkCoreLogonInit, [fLogonManager.LocalPort]);
  end;

  { Patch Manager }
  try
    fPatchManager := YNwPatchManager.Create;
    fPatchManager.Load(SystemConfiguration.StringValue['Data', 'PatchDir']);
  except
    raise ECoreOperationFailed.CreateRes(@RsNetworkCorePatchInit);
  end;

  { Realm Manager }
  try
    fRealmList := YNwRealmList.Create;
    fRealmList.Add( YNwInternalRealm.Create );
  except
    raise ECoreOperationFailed.CreateRes(@RsNetworkCoreRealmInit);
  end;

  { Realm Server/World }
  try
    fWorldManager := YNwWorldSocketManager.Create;
    for iIdx := 0 to High(aStrs) do
    begin
      fWorldManager.AddToPermanentBanList(ConvertIP(aStrs[iIdx]));
    end;
  except
    raise ECoreOperationFailed.CreateResFmt(@RsNetworkCoreWorldInit, [fWorldManager.LocalPort]);
  end;
  // More stuff later
end;

procedure YNetworkCore.CoreStart;
begin
  try
    fLogonManager.Start(SystemConfiguration.IntegerValue['Network', 'LogonPort']);
  except
    raise ECoreOperationFailed.CreateRes(@RsNetworkCoreLogonStart);
  end;

  try
    fWorldManager.Start(SystemConfiguration.IntegerValue['Network', 'RealmPort']);
  except
    raise ECoreOperationFailed.CreateRes(@RsNetworkCoreWorldStart);
  end;
end;

procedure YNetworkCore.CoreStop;
begin
  { Will stop them automatically on destroy }
  fLogonManager.Free;
  fPatchManager.Free;
  fWorldManager.Free;
  fRealmList.Free;
end;

function YNetworkCore.GetLogonThreads: Integer;
begin
  Result := fLogonManager.ClientCount;
end;

function YNetworkCore.GetRealmThreads: Integer;
begin
  Result := fWorldManager.ClientCount;
end;

end.
