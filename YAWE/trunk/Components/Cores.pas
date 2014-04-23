{*--------------------------------------------------------------------
  YAWE cores
  Containing global core variables.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth
  @Docs TheSelby
--------------------------------------------------------------------}

{$I compiler.inc}
unit Cores;

interface

{$REGION 'Uses Clause'}
  uses
    Components,
    Components.DataCore,
    Components.GameCore,
    Components.NetworkCore,
    Components.ExtensionCore,
    Components.IoCore;
{$ENDREGION}
  
{$REGION 'Variables'}
  var

    DataCore: YDataCore;           /// Data Core Instance
    NetworkCore: YNetworkCore;     /// NetworkCore Instance
    GameCore: YGameCore;           /// Open Core Instance
    ExtensionCore: YExtensionCore; /// Extension Core Instance
    IoCore: YIoCore;               /// IoCore Instance
{$ENDREGION}
 
implementation

end.
