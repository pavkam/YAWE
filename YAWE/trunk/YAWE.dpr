{*------------------------------------------------------------------------------
  YAWE Main Module
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.
  


  Yet Another WoW Emulator Project

    Delphi based MMORPG server that aims to provide fast and clean OOP code.
    We achieve speed by combining Win32 API, assembler code (MMX/SSE/SSE2) and
      Multi-Core based systems. All code is Delphi 10 and later compatible.
  

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author PavkaM
  @Changes TheSelby, Seth, BIGBOSS, Frixion, ZaDarkSide, Morpheus
  @Docs TheSelby
-------------------------------------------------------------------------------}
{$APPTYPE CONSOLE}

{$I compiler.inc}
program YAWE;

{$R 'Main\Resources.res' 'Main\Resources.rc'}
{%TogetherDiagram 'ModelSupport_YAWE\default.txaPackage'}

{$DESCRIPTION 'YAWE - World of Warcraft Emulation Server'}

uses
  SysUtils,
  Classes,
  Misc.Miscleanous,
  API.Win.CommCtrl in '..\..\Shared\API\API.Win.CommCtrl.pas',
  API.Win.DbgHelp in '..\..\Shared\API\API.Win.DbgHelp.pas',
  API.Win.GDI in '..\..\Shared\API\API.Win.GDI.pas',
  API.Win.Kernel in '..\..\Shared\API\API.Win.Kernel.pas',
  API.Win.NtApi in '..\..\Shared\API\API.Win.NtApi.pas',
  API.Win.NtCommon in '..\..\Shared\API\API.Win.NtCommon.pas',
  API.Win.NtStatus in '..\..\Shared\API\API.Win.NtStatus.pas',
  API.Win.PsAPI in '..\..\Shared\API\API.Win.PsAPI.pas',
  API.Win.TlHelp32 in '..\..\Shared\API\API.Win.TlHelp32.pas',
  API.Win.Types in '..\..\Shared\API\API.Win.Types.pas',
  API.Win.User in '..\..\Shared\API\API.Win.User.pas',
  API.Win.Winsock2 in '..\..\Shared\API\API.Win.Winsock2.pas',
  Version in 'Main\Version.pas',
  Main in 'Main\Main.pas',
  Resources in 'Main\Resources.pas',
  Cores in 'Components\Cores.pas',
  Components in 'Components\Components.pas',
  Components.Shared in 'Components\Components.Shared.pas',
  Components.Interfaces in 'Components\Components.Interfaces.pas',
  Components.IoCore in 'Components\IoCore\Components.IoCore.pas',
  Components.IoCore.Console in 'Components\IoCore\Components.IoCore.Console.pas',
  Components.IoCore.Sockets in 'Components\IoCore\Components.IoCore.Sockets.pas',
  Components.IoCore.ErrorManager in 'Components\IoCore\Components.IoCore.ErrorManager.pas',
  Components.DataCore in 'Components\DataCore\Components.DataCore.pas',
  Components.DataCore.DynamicObjectFormat in 'Components\DataCore\Components.DataCore.DynamicObjectFormat.pas',
  Components.DataCore.CharTemplates in 'Components\DataCore\Components.DataCore.CharTemplates.pas',
  Components.DataCore.Storage in 'Components\DataCore\Components.DataCore.Storage.pas',
  Components.DataCore.MemoryStorage in 'Components\DataCore\Components.DataCore.MemoryStorage.pas',
  Components.DataCore.PkTTEngine in 'Components\DataCore\Components.DataCore.PkTTEngine.pas',
  Components.DataCore.DbcEngine in 'Components\DataCore\Components.DataCore.DbcEngine.pas',
  Components.DataCore.PcpEngine in 'Components\DataCore\Components.DataCore.PcpEngine.pas',
  Components.DataCore.Fields in 'Components\DataCore\Components.DataCore.Fields.pas',
  Components.DataCore.Types in 'Components\DataCore\Components.DataCore.Types.pas',
  Components.DataCore.WorldData.Loader in 'Components\DataCore\WorldData\Components.DataCore.WorldData.Loader.pas',
  Components.DataCore.WorldData.Types in 'Components\DataCore\WorldData\Components.DataCore.WorldData.Types.pas',
  Components.NetworkCore in 'Components\NetworkCore\Components.NetworkCore.pas',
  Components.NetworkCore.Packet in 'Components\NetworkCore\Components.NetworkCore.Packet.pas',
  Components.NetworkCore.Constants in 'Components\NetworkCore\Servers\Components.NetworkCore.Constants.pas',
  Components.NetworkCore.HdrXor in 'Components\NetworkCore\Servers\Components.NetworkCore.HdrXor.pas',
  Components.NetworkCore.SRP6 in 'Components\NetworkCore\Components.NetworkCore.SRP6.pas',
  Components.NetworkCore.Logon in 'Components\NetworkCore\Servers\Components.NetworkCore.Logon.pas',
  Components.NetworkCore.Opcodes in 'Components\NetworkCore\Servers\Components.NetworkCore.Opcodes.pas',
  Components.NetworkCore.Patches in 'Components\NetworkCore\Servers\Components.NetworkCore.Patches.pas',
  Components.NetworkCore.Realm in 'Components\NetworkCore\Components.NetworkCore.Realm.pas',
  Components.NetworkCore.World in 'Components\NetworkCore\Servers\Components.NetworkCore.World.pas',
  Components.GameCore in 'Components\GameCore\Components.GameCore.pas',
  Components.GameCore.Area in 'Components\GameCore\Components.GameCore.Area.pas',
  Components.GameCore.AreaManager in 'Components\GameCore\Components.GameCore.AreaManager.pas',
  Components.GameCore.CommandHandler in 'Components\GameCore\Components.GameCore.CommandHandler.pas',
  Components.GameCore.Component in 'Components\GameCore\Components.GameCore.Component.pas',
  Components.GameCore.Constants in 'Components\GameCore\Components.GameCore.Constants.pas',
  Components.GameCore.Factory in 'Components\GameCore\Components.GameCore.Factory.pas',
  Components.GameCore.Groups in 'Components\GameCore\Components.GameCore.Groups.pas',
  Components.GameCore.Channel in 'Components\GameCore\Components.GameCore.Channel.pas',
  Components.GameCore.Interfaces in 'Components\GameCore\Components.GameCore.Interfaces.pas',
  Components.GameCore.Nodes in 'Components\GameCore\Components.GameCore.Nodes.pas',
  Components.GameCore.PacketBuilders in 'Components\GameCore\Components.GameCore.PacketBuilders.pas',
  Components.GameCore.Session in 'Components\GameCore\Components.GameCore.Session.pas',
  Components.GameCore.TerrainManager in 'Components\GameCore\Components.GameCore.TerrainManager.pas',
  Components.GameCore.UpdateFields in 'Components\GameCore\Components.GameCore.UpdateFields.pas',
  Components.GameCore.WowContainer in 'Components\GameCore\Components.GameCore.WowContainer.pas',
  Components.GameCore.WowCreature in 'Components\GameCore\Components.GameCore.WowCreature.pas',
  Components.GameCore.WowDynamicObject in 'Components\GameCore\Components.GameCore.WowDynamicObject.pas',
  Components.GameCore.WowGameObject in 'Components\GameCore\Components.GameCore.WowGameObject.pas',
  Components.GameCore.WowItem in 'Components\GameCore\Components.GameCore.WowItem.pas',
  Components.GameCore.WowMobile in 'Components\GameCore\Components.GameCore.WowMobile.pas',
  Components.GameCore.WowObject in 'Components\GameCore\Components.GameCore.WowObject.pas',
  Components.GameCore.WowPlayer in 'Components\GameCore\Components.GameCore.WowPlayer.pas',
  Components.GameCore.WowUnit in 'Components\GameCore\Components.GameCore.WowUnit.pas',
  Components.ExtensionCore in 'Components\ExtensionCore\Components.ExtensionCore.pas',
  Components.ExtensionCore.Interfaces in 'Components\ExtensionCore\Components.ExtensionCore.Interfaces.pas',
  Components.ExtensionCore.Yes in 'Components\ExtensionCore\Components.ExtensionCore.Yes.pas',
  LibEay32.LibInterface in '..\..\Vendor\LibEay32\LibEay32.LibInterface.pas',
  MapHelp.LibInterface in '..\..\Vendor\MapHelp32\MapHelp.LibInterface.pas',
  Ucl.LibInterface in '..\..\Library\UCL32\Ucl.LibInterface.pas',
  ZLib.LibInterface in '..\..\Vendor\ZLib32\ZLib.LibInterface.pas',
  Components.GameCore.Guilds in 'Components\GameCore\Components.GameCore.Guilds.pas';

{$R *.res}

const
  CopyrightStr: string =
    '(c) 2006-2007 YAWE Project. Unauthorized distribution of this file is strictly prohibited. ' +
    'All files are the intellectual property of the YAWE Development team.';

begin
  ReportMemoryLeaksOnShutdown := True;
  { Run the main executable procedure }
  RunYAWEMain;
end.
