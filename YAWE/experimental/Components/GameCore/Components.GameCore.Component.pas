{*------------------------------------------------------------------------------
  Main Object Component.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author PavkaM
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.Component;

interface

uses
  Framework.Base,
  Components.DataCore.Storage,
  Components.GameCore.WowObject,
  Components.GameCore.Interfaces,
  Components.DataCore.Types,
  Components.Interfaces,
  SysUtils;

type
  { Component on which the whole Object framework is based }
  YGaObjectComponent = class(TBaseInterfacedObject)
    public
      { Override this in children to perform resource loading }
      procedure ExtractObjectData(cEntry: YDbSerializable); virtual;
      { Override this in children to perform resource saving }
      procedure InjectObjectData(cEntry: YDbSerializable); virtual;
      { Delete this component from database }
      procedure CleanupObjectData; virtual;
    end;

implementation

{ YGaObjectComponent }

procedure YGaObjectComponent.CleanupObjectData;
begin
end;

procedure YGaObjectComponent.ExtractObjectData(cEntry: YDbSerializable);
begin
end;

procedure YGaObjectComponent.InjectObjectData(cEntry: YDbSerializable);
begin
end;

end.
