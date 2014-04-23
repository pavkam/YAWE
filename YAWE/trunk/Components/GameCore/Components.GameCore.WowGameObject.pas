{*------------------------------------------------------------------------------
  GameObject Implementation

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author TheSelby
  @Changes Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.WowGameObject;

interface

uses
  Framework.Base,
  Components.DataCore.Storage,
  Components.DataCore.Fields,
  Components.NetworkCore.Packet,
  Components.DataCore.CharTemplates,
  Components.GameCore.UpdateFields,
  Components.GameCore.WowMobile,
  Components.DataCore.Types,
  Components.Interfaces,
  SysUtils;

type
  { Item Class }
  YGaGameObject = class(YGaMobile)
    private
      fTemplate: YDbGameObjectTemplate;
      fOwner: TBaseObject;
      { Load Template }
      procedure LoadTemplate(iTempId: Int32);
    protected
      class function GetObjectType: Int32; override;
      class function GetOpenObjectType: YWowObjectType; override;

      procedure AddMovementData(cPkt: YNwServerPacket; bSelf: Boolean); override;
    public
      procedure ExtractObjectData(cEntry: YDbSerializable); override;
      procedure InjectObjectData(cEntry: YDbSerializable); override;
      procedure CleanupObjectData; override;

      procedure CreateFromTemplate(iEntryId: UInt32);

      destructor Destroy; override;

      property Template: YDbGameObjectTemplate read fTemplate;
      property Owner: TBaseObject read fOwner write fOwner;
    end;

implementation

uses
  Misc.Miscleanous,
  Framework,
  Cores;

procedure YGaGameObject.CreateFromTemplate(iEntryId: UInt32);
begin
  LoadTemplate(iEntryId);
end;

destructor YGaGameObject.Destroy;
begin
  if fTemplate <> nil then DataCore.GameObjectTemplates.ReleaseEntry(fTemplate);
  inherited Destroy;
end;

procedure YGaGameObject.ExtractObjectData(cEntry: YDbSerializable);
begin
  inherited ExtractObjectData(cEntry);
  LoadTemplate(Entry);
end;

procedure YGaGameObject.InjectObjectData(cEntry: YDbSerializable);
begin
  inherited InjectObjectData(cEntry);
end;

procedure YGaGameObject.LoadTemplate(iTempId: Int32);
begin
  if fTemplate <> nil then DataCore.GameObjectTemplates.ReleaseEntry(fTemplate);
  DataCore.GameObjectTemplates.LoadEntry(iTempId, fTemplate);
end;
  
procedure YGaGameObject.AddMovementData(cPkt: YNwServerPacket; bSelf: Boolean);
begin
  cPkt.AddUInt8($10 or $20);
  cPkt.AddUInt32(0);
  cPkt.AddFloat(Position.X);
  cPkt.AddFloat(Position.Y);
  cPkt.AddFloat(Position.Z);
  cPkt.AddFloat(Position.Angle);
  cPkt.JumpUInt32;
end;

procedure YGaGameObject.CleanupObjectData;
begin
end;

class function YGaGameObject.GetObjectType;
begin
  Result := UPDATEFLAG_GAMEOBJECT;
end;

class function YGaGameObject.GetOpenObjectType: YWowObjectType;
begin
  Result := otGameObject;
end;

end.

