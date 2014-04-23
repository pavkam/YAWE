{*------------------------------------------------------------------------------
  GameObject Implementation

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author TheSelby
  @Changes Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.WowGameObject;

interface

uses
  Framework.Base,
  Components.DataCore,
  Components.NetworkCore.Packet,
  Components.GameCore.UpdateFields,
  Components.GameCore.WowMobile,
  Components.DataCore.Types,
  Components.Interfaces,
  SysUtils;

type
  { Item Class }
  YGaGameObject = class(YGaMobile)
    private
      FTemplate: IGameObjectTemplateEntry;
      FOwner: TObject;
      { Load Template }
      procedure LoadTemplate(TemplateId: Int32);
    protected
      class function GetObjectType: Int32; override;
      class function GetOpenObjectType: YWowObjectType; override;

      procedure AddMovementData(Pkt: YNwServerPacket; UpdatingSelf: Boolean); override;
    public
      procedure ExtractObjectData(const Entry: ISerializable); override;
      procedure InjectObjectData(const Entry: ISerializable); override;
      procedure CleanupObjectData; override;

      procedure InitializeFromTemplate(EntryId: UInt32);

      destructor Destroy; override;

      property Template: IGameObjectTemplateEntry read FTemplate;
      property Owner: TObject read FOwner write FOwner;
    end;

implementation

uses
  Bfg.Utils,
  Framework,
  Cores;

procedure YGaGameObject.InitializeFromTemplate(EntryId: UInt32);
begin
  LoadTemplate(EntryId);
end;

destructor YGaGameObject.Destroy;
begin
  if FTemplate <> nil then DataCore.GameObjectTemplates.ReleaseEntry(FTemplate);
  inherited Destroy;
end;

procedure YGaGameObject.ExtractObjectData(const Entry: ISerializable);
begin
  raise EUnSupported.Create('Operation YGaGameObject.ExtractObjectData is not supported');
end;

procedure YGaGameObject.InjectObjectData(const Entry: ISerializable);
begin
  raise EUnSupported.Create('Operation YGaGameObject.InjectObjectData is not supported');
end;

procedure YGaGameObject.LoadTemplate(TemplateId: Int32);
begin
  if FTemplate <> nil then DataCore.GameObjectTemplates.ReleaseEntry(FTemplate);
  DataCore.GameObjectTemplates.LookupEntry(TemplateId, FTemplate);
end;
  
procedure YGaGameObject.AddMovementData(Pkt: YNwServerPacket; UpdatingSelf: Boolean);
begin
  Pkt.AddUInt8($10 or $20);
  Pkt.AddUInt32(0);
  Pkt.AddFloat(X);
  Pkt.AddFloat(Y);
  Pkt.AddFloat(Z);
  Pkt.AddFloat(Angle);
  Pkt.JumpUInt32;
end;

procedure YGaGameObject.CleanupObjectData;
begin
  raise EUnSupported.Create('Operation YGaGameObject.CleanupObjectData is not supported');
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

