{*------------------------------------------------------------------------------
  Versioning Support
  
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
unit Version;

interface

uses
  Misc.ZLib;

const
  {$I Framework.Revision.rev}

  ProgramName: string        = 'YAWE Server';

  ProgramCodename: string    = 'Yamper';
  ProgramMaxVerMajor         = 0;
  ProgramMaxVerMinor         = 4;

  ProgramPlatform            = 'd2006_win32';
  ProgramRevision            = RevisionNumber;
  ProgramBuild               = BuildCount;

  ProgramCopyright: string   = '(c) 2006-2007 by YAWE Development Team.';

  PatchNotesBroadcast = 'Patch 2.0.12 is now supported. To avoid any technical difficulty or interface related ' +
                        'issues, it is advised that all players disable any third party interface mods. Please visit our forum for ' +
                        'more informations about YAWE server. Our discussions forum is located at http://yawe.mcheats.net/forum/index.php';


  {$IFDEF WOW_TBC}
  AcceptedBuilds: array[0..0] of Word =
  (
    6546  // 2.0.12
  );
  {$ELSE}
  AcceptedBuilds: array[0..2] of Word =
  (
    5595, //1.12.0
    5875, //1.12.1
    6005  //1.12.2
  );
  {$ENDIF}

  (*
  WOW Build Numbers.
  ==================
  5428 - 1.11.0
  5462 - 1.11.1
  5464 - 1.11.2
  5595 - 1.12.0
  5875 - 1.12.1

  5665, // 2.0.0  200MB patch
  5666  // 2.0.0  300MB patch
  5849  // 2.0.0  227MB patch
  5894  // 2.0.0   89MB patch
  5921  // 2.0.0   71MB patch
  5965  // 2.0.0  216MB patch
  5991  // 2.0.0  BETA first release
  6022  // 2.0.0 Closed Beta, first patch

  *)

//------------------------------------------------------------------------------
// Files
//------------------------------------------------------------------------------
  ConfigurationFile: string  =  '{$YROOT}\Configuration\system.conf';
  ErrorLogPath: string       =  '{$YROOT}\Errors';


//------------------------------------------------------------------------------
// Internal Constants
//------------------------------------------------------------------------------
  PATCH_SEND_DELAY      =    200; { Msec }

  MAX_USERNAME_LEN      =     50; { Maximum length of an username }

  TICK_LENGTH           =     25; { Msec }

  WORLD_UPDATE_TIME     =     50; { Msec }

  NETWORK_UPD_INTERVAL  =     50; { Msec }

  GROUPS_UPD_INTERVAL   =     50; { Msec }

  SESSION_UPD_INTERVAL  =     50; { Msec }

//------------------------------------------------------------------------------
// Configuration Defaults
//------------------------------------------------------------------------------
  CONF_NETWORK_LOGONPORT               = 3724;
  CONF_NETWORK_REALMPORT               = 3725;
  CONF_NETOWRK_REALM_ADDRESS: string   = '127.0.0.1';
  CONF_NETWORK_PLAYERS                 = 200;
  CONF_NETWORK_TIMEOUT_DELAY           = 90;
  CONF_NETWORK_ALLOWED_LOCALS: string  = 'enGB enUS frFR deDE';
  CONF_NETWORK_BANNED_IPS: string      = '';
  CONF_NETWORK_EXTRA_LOGON_WORKERS     = 0;
  CONF_NETWORK_EXTRA_LOGON_LISTENERS   = 0;
  CONF_NETWORK_EXTRA_REALM_WORKERS     = 0;
  CONF_NETWORK_EXTRA_REALM_LISTENERS   = 0;

  CONF_REALM_NAME: string              = 'My realm';
  CONF_REALM_TIMEZONE                  = 0;
  CONF_REALM_MOTD: string              = 'Welcome to |cffff0000YAWE Server ver. {$VER} realm {$RLM}|r';
  CONF_REALM_TYPE: string              = 'PvP';
  CONF_REALM_AUTOACCOUNT               = 0;
  CONF_REALM_MAXCHARS                  = 10;

  CONF_DATA_PACKET_COMPRESSION_LEVEL   = LEVEL_FAST;
  CONF_DATA_YES_PLUGIN_DIR: string     = '{$YROOT}/Plugins';
  CONF_DATA_PATCH_DIR: string          = '{$YROOT}/Patches';
  CONF_DATA_PATCH_SPEED                = 16384;
  CONF_DATA_MAP_DATA_DIR: string       = '{$YROOT}/Data/SMD';

var
  ProgramVersion: string; { Contains the formatted program version }

function IsAcceptedBuild(wBuild: Word): Boolean;

implementation

uses Misc.Miscleanous;

const
  BuildsForMajor = 40000;
  BuildsForMinor = (BuildsForMajor div 10) - 1;
  BuildsForSubVer = (BuildsForMinor div 10) - 1;

function IsAcceptedBuild(wBuild: Word): Boolean;
var
  iIdx: Integer;
begin
  for iIdx := Low(AcceptedBuilds) to High(AcceptedBuilds) do
  begin
    if AcceptedBuilds[iIdx] = wBuild then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

function CalcProgramVersion: string;
var
  iMajor, iMinor, iSubVer, iLeft: Integer;
begin
  iLeft := ProgramBuild;

  iMajor := DivMod(iLeft, BuildsForMajor, iLeft);
  if iMajor > ProgramMaxVerMajor then
  begin
    iMajor := ProgramMaxVerMajor;
  end;

  iMinor := DivMod(iLeft, BuildsForMinor, iLeft);
  if iMinor > ProgramMaxVerMinor then
  begin
    iMinor := ProgramMaxVerMinor;
  end;

  iSubVer := iLeft div BuildsForSubVer;
  if iMinor = ProgramMaxVerMinor then
  begin
    iSubVer := 0;
  end;
 
  Result := itoa(iMajor) + '.' + itoa(iMinor) + '.' + itoa(iSubVer) +
    '#' + itoa(ProgramRevision) + itoa(ProgramBuild) + '-' + ProgramPlatform;
end;


initialization
  ProgramVersion := CalcProgramVersion;

end.
