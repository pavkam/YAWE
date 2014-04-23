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

unit Yes.Main;
interface

uses
  Yes.Types;

var
  YaweManager: IPluginManager;

function CheckManager(const AManager: IPluginManager): Boolean;

implementation

function ValidateVersion(const AInfo: TPluginManagerInfo): Boolean;
begin
  Result := True; { Check for a specific version here }
end;

function CheckManager(const AManager: IPluginManager): Boolean;
var
  MgrInfo: TPluginManagerInfo;
begin
  if AManager <> nil then
  begin
    AManager.GetManagerInfo(MgrInfo);
    if ValidateVersion(MgrInfo) then
    begin
      YaweManager := AManager;
      Result := True;
    end else Result := False;
  end else Result := False;
end;

end.
