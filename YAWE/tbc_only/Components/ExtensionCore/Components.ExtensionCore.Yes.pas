{*------------------------------------------------------------------------------
  YES Extension Module.
  This is a scripting module that can be programmed by third-party persons to
  handle some parts of the server differently (those that are allowed by the
  server to be "handled" through scripting modules)

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author Seth
  @Docs TheSelby
-------------------------------------------------------------------------------}
{$I compiler.inc}
unit Components.ExtensionCore.Yes;

interface

{$REGION 'Uses Clause'}
  uses
    Framework.Base,
    Components,
    Components.ExtensionCore.Interfaces,
    Components.NetworkCore.World,
    Bfg.Utils,
    Bfg.PluginSystem;
{$ENDREGION}

type
  {*------------------------------------------------------------------------------
  The class that handles scripting
  -------------------------------------------------------------------------------}
  YExYesManager = class(TPluginManager, IPluginManager, IYaweLogonServices)
    private
      {$REGION 'Private members'}
      {$ENDREGION}
    protected
      {$REGION 'Protected members'}
      class procedure FillVersion(var AInfo: TPluginManagerInfo); override;
      {$ENDREGION}
    public
      {$REGION 'Public members'}
      function DisconnectAccount(const sAccount: string): Boolean;
      function BanAccount(const sAccount: string; bDisconnect: Boolean): Boolean;
      function UnbanAccount(const sAccount: string): Boolean;
      {$ENDREGION}
  end;

implementation

{$REGION 'Uses Clause'}
  uses
    Framework,
    Components.DataCore.Types,
    Cores;
{$ENDREGION}

{$REGION 'Versioning Constants'}
  const
    {*------------------------------------------------------------------------------
    YAWE EXTENSION MODULE's major build number
    -------------------------------------------------------------------------------}
    YES_MAJOR = 0;
    {*------------------------------------------------------------------------------
    YAWE EXTENSION MODULE's minor build number
    -------------------------------------------------------------------------------}
    YES_MINOR = 1;
    {*------------------------------------------------------------------------------
    YAWE EXTENSION MODULE's revision number
    -------------------------------------------------------------------------------}
    YES_REV   = 0;
    {*------------------------------------------------------------------------------
    YAWE EXTENSION MODULE's build number
    -------------------------------------------------------------------------------}
    YES_BUILD = 5;
    {*------------------------------------------------------------------------------
    YAWE EXTENSION MODULE's build type
    -------------------------------------------------------------------------------}
    YES_TYPE  = vtAlfa;
    {*------------------------------------------------------------------------------
    YAWE EXTENSION MODULE's versioning string
    -------------------------------------------------------------------------------}
    YES_STR   = '0.1.0.5a';
{$ENDREGION}

{$REGION 'YExYesManager Methods'}
  {*------------------------------------------------------------------------------
    The plugin calls this method to get the server extension's version

    @param AInfo Outputs the version here
    @see TPluginManagerInfo
  -------------------------------------------------------------------------------}
  class procedure YExYesManager.FillVersion(var AInfo: TPluginManagerInfo);
  begin
    AInfo.Version.VerMajor := YES_MAJOR;
    AInfo.Version.VerMinor := YES_MINOR;
    AInfo.Version.VerRevision := YES_REV;
    AInfo.Version.VerBuild := YES_BUILD;
    AInfo.Version.VerType := YES_TYPE;
    AInfo.Version.VerString := YES_STR;
  end;

  {*------------------------------------------------------------------------------
    Bans an account on request

    @param sAccount The account name (string)
  -------------------------------------------------------------------------------}
  function YExYesManager.BanAccount(const sAccount: string; bDisconnect: Boolean): Boolean;
  var
    cAcc: YDbAccountEntry;
    cSocket: YNwWorldSocket;
  begin
    //DataCore.Accounts.LoadEntry(FIELD_ACC_NAME, sAccount, cAcc);
    if cAcc <> nil then
    begin
      if cAcc.Status <> asBanned then
      begin
        cAcc.Status := asBanned;
        DataCore.Accounts.SaveEntry(cAcc);
      end else DataCore.Accounts.ReleaseEntry(cAcc);
  
      if bDisconnect then
      begin
        cSocket := NetworkCore.WorldServer.GetSocketByAccount(sAccount);
        if cSocket <> nil then cSocket.Disconnect;
      end;
      Result := True;
    end else Result := False;
  end;

  {*------------------------------------------------------------------------------
    Disconnectes an account on request

    @param sAccount The account name (string)
  -------------------------------------------------------------------------------}
  function YExYesManager.DisconnectAccount(const sAccount: string): Boolean;
  var
    cSocket: YNwWorldSocket;
  begin
    cSocket := NetworkCore.WorldServer.GetSocketByAccount(sAccount);
    if cSocket <> nil then
    begin
      cSocket.Disconnect;
      Result := True;
    end else Result := False;
  end;

  {*------------------------------------------------------------------------------
    Removes ban for an account

    @param sAccount The account name (string)
  -------------------------------------------------------------------------------}
  function YExYesManager.UnbanAccount(const sAccount: string): Boolean;
  var
    cAcc: YDbAccountEntry;
  begin
    //DataCore.Accounts.LoadEntry(FIELD_ACC_NAME, sAccount, cAcc);
    if cAcc <> nil then
    begin
      if cAcc.Status = asBanned then
      begin
        cAcc.Status := asNormal;
        DataCore.Accounts.SaveEntry(cAcc);
      end else DataCore.Accounts.ReleaseEntry(cAcc);
      Result := True;
    end else Result := False;
  end;
{$ENDREGION}

end.
