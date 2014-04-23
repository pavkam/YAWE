{*------------------------------------------------------------------------------
  Main NetworkCore Object. Provides Basic Networking.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
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
      FLogonManager: YNwLogonSocketManager;
      FWorldManager: YNwWorldSocketManager;
      FPatchManager: YNwPatchManager;
      FRealmList: YNwRealmList;
      function GetLogonThreads: Integer;
      function GetRealmThreads: Integer;
    protected
      procedure CoreInitialize; override;
      procedure CoreStart; override;       
      procedure CoreStop; override;
    public
      property LogonServer: YNwLogonSocketManager read FLogonManager;
      property WorldServer: YNwWorldSocketManager read FWorldManager;
      property LogonThreads: Integer read GetLogonThreads;
      property RealmThreads: Integer read GetRealmThreads;
      property Patches: YNwPatchManager read FPatchManager;
      property Realms: YNwRealmList read FRealmList;
    end;

implementation

uses
  Framework,
  Resources,
  Bfg.Containers,
  Bfg.Utils;

{ YNetworkCore }

procedure YNetworkCore.CoreInitialize;
  function ConvertIP(const sIP: string): Longword;
  var
    Strs: array[0..3] of string;
  begin
    if StringSplit(sIP, Strs, '.') then
    begin
      try
        Result := StrToInt(Strs[0]) or (StrToInt(Strs[1]) shl 8) or
                  (StrToInt(Strs[2]) shl 16) or (StrToInt(Strs[3]) shl 24);
      except
        Result := 0;
      end;
    end else Result := 0;
  end;
var
  Strs: TStringDynArray;
  I: Integer;
begin
  Strs := StringSplit(SysConf.ReadStringN('Network', 'BannedIPs'));

  { Logon Manager }
  try
    FLogonManager := YNwLogonSocketManager.Create;
    for I := 0 to High(Strs) do
    begin
      FLogonManager.AddToPermanentBanList(ConvertIP(Strs[I]));
    end;
  except
    raise ECoreOperationFailed.CreateResFmt(@RsNetworkCoreLogonInit, [FLogonManager.LocalPort]);
  end;

  { Patch Manager }
  try
    FPatchManager := YNwPatchManager.Create;
    FPatchManager.Load(SysConf.ReadStringN('Data', 'PatchDir'));
  except
    raise ECoreOperationFailed.CreateRes(@RsNetworkCorePatchInit);
  end;

  { Realm Manager }
  try
    FRealmList := YNwRealmList.Create;
    FRealmList.Add( YNwInternalRealm.Create );
  except
    raise ECoreOperationFailed.CreateRes(@RsNetworkCoreRealmInit);
  end;

  { Realm Server/World }
  try
    FWorldManager := YNwWorldSocketManager.Create;
    for I := 0 to High(Strs) do
    begin
      FWorldManager.AddToPermanentBanList(ConvertIP(Strs[I]));
    end;
  except
    raise ECoreOperationFailed.CreateResFmt(@RsNetworkCoreWorldInit, [FWorldManager.LocalPort]);
  end;
  // More stuff later
end;

procedure YNetworkCore.CoreStart;
begin
  try
    FLogonManager.Start(SysConf.ReadIntegerN('Network', 'LogonPort', 3724));
  except
    raise ECoreOperationFailed.CreateRes(@RsNetworkCoreLogonStart);
  end;

  try
    FWorldManager.Start(SysConf.ReadIntegerN('Network', 'RealmPort', 3725));
  except
    raise ECoreOperationFailed.CreateRes(@RsNetworkCoreWorldStart);
  end;
end;

procedure YNetworkCore.CoreStop;
begin
  { Will stop them automatically on destroy }
  FLogonManager.Free;
  FPatchManager.Free;
  FWorldManager.Free;
  FRealmList.Free;
end;

function YNetworkCore.GetLogonThreads: Integer;
begin
  Result := FLogonManager.ClientCount;
end;

function YNetworkCore.GetRealmThreads: Integer;
begin
  Result := FWorldManager.ClientCount;
end;

end.
