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

unit Yes.Export;

interface

uses
  Yes.Types,
  Yes.Main;

function RegisterPluginModules(const AManager: IPluginManager): Boolean;

implementation

function RegisterPluginModules(const AManager: IPluginManager): Boolean;
begin
  Result := CheckManager(AManager); { Change this to call the initialization code }
end;

end.
