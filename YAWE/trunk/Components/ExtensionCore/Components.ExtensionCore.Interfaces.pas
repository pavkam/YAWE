{*------------------------------------------------------------------------------
  ExtensionCore Interfaces
  Provides interfaces for access between YAWE server and scripting modules

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
  @Docs TheSelby
-------------------------------------------------------------------------------}
{$I compiler.inc}
unit Components.ExtensionCore.Interfaces;

interface

{$REGION 'Uses Clause'}
  uses
    Misc.PluginSystem,
    Framework.Tick;
{$ENDREGION}

type

  {*------------------------------------------------------------------------------
  LogonService Interfaces implemented by the plugin manager
  -------------------------------------------------------------------------------}
  IYaweLogonServices = interface(IInterface)
  ['{E3A0862D-F0B7-4185-9741-20B4CF321D7C}']
    {$REGION 'Interface Methods'}
      {*------------------------------------------------------------------------------
        Disconnectes an account on request

        @param sAccount The account name (string)
      -------------------------------------------------------------------------------}
      function DisconnectAccount(const sAccount: string): Boolean;

      {*------------------------------------------------------------------------------
        Bans an account on request

        @param sAccount The account name (string)
      -------------------------------------------------------------------------------}
      function BanAccount(const sAccount: string; bDisconnect: Boolean): Boolean;

      {*------------------------------------------------------------------------------
        Removes ban for an account

        @param sAccount The account name (string)
      -------------------------------------------------------------------------------}
      function UnbanAccount(const sAccount: string): Boolean;
    {$ENDREGION}
  end;

implementation

end.
