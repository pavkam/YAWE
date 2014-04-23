{*------------------------------------------------------------------------------
  OpenItem Implementation

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth, TheSelby
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.WowItem;

interface

uses
  Framework.Base,
  Components.NetworkCore.Packet,
  Components.GameCore.Interfaces,
  Components.GameCore.UpdateFields,
  Components.GameCore.WowObject,
  Components.DataCore.Types,
  Components.Interfaces,
  SysUtils;

type
  { Item Class }
  YGaItem = class(YGaWowObject, IObject, IItem)
    protected
      fTemplate: IItemTemplateEntry;
      fOwner: YGaWowObject;
      fContained: YGaItem;
      class function GetObjectType: Int32; override;
      class function GetOpenObjectType: YWowObjectType; override;

      function GetEntry: Integer;
      function GetOccupiedSlot: Integer;
      function GetOwnerBag: IBag;
      function GetCreator: IPlayer;
      function GetOwner: IUnit;
      function IsInBag: Boolean;
      function GetStackCount: UInt32;
      procedure SetOwner(cOwner: YGaWowObject);
      procedure SetStackCount(iNewCount: UInt32); 
      procedure SetContained(cContainer: YGaItem);

      procedure AddMovementData(cPkt: YNwServerPacket; bSelf: Boolean); override;
    protected
      procedure EnterWorld; override;
      procedure LeaveWorld; override;
    public
      destructor Destroy; override;
      procedure ExtractObjectData(const Entry: ISerializable); override;
      procedure InjectObjectData(const Entry: ISerializable); override;
      procedure CreateFromTemplate(iEntryId: UInt32);

      procedure LoadTemplate(iTempId: Int32);
      //procedure CopyTemplate(var tOutTemplate: YItemTemplate);

      procedure OnValuesUpdate; override;

      property Template: IItemTemplateEntry read fTemplate;
      property Owner: YGaWowObject read fOwner write SetOwner;
      property OccupiedSlot: Integer read GetOccupiedSlot;
      property InBag: Boolean read IsInBag;
      property Contained: YGaItem read fContained write SetContained;
      property ContainedIn: IBag read GetOwnerBag;
      property Creator: IPlayer read GetCreator;
      property StackCount: UInt32 read GetStackCount write SetStackCount;
    end;

implementation

uses
  Components.GameCore.PacketBuilders,
  Components.GameCore.WowPlayer,
  Bfg.Utils,
  Framework,
  Cores;

//procedure YOpenItem.CopyTemplate(var tOutTemplate: YItemTemplate);
//begin
//  if fTemplate <> nil then
//  begin
//    CopyRecord(fTemplate, @tOutTemplate, TypeInfo(YItemTemplate));
//  end else FillChar(tOutTemplate, SizeOf(YItemTemplate), 0);
//end;

procedure YGaItem.AddMovementData(cPkt: YNwServerPacket; bSelf: Boolean);
begin
  cPkt.AddUInt8($18);
  cPkt.JumpUInt32;
end;

procedure YGaItem.CreateFromTemplate(iEntryId: UInt32);
begin
  LoadTemplate(iEntryId);
  if not Assigned(fTemplate) then Exit;
  SetUInt32(ITEM_FIELD_ITEM_TEXT_ID, fTemplate.PageID);
  SetUInt32(ITEM_FIELD_MAXDURABILITY, fTemplate.MaximumDurability);
  SetUInt32(ITEM_FIELD_DURABILITY, fTemplate.MaximumDurability);
  if IsType(otContainer) then
  begin
    SetUInt32(CONTAINER_FIELD_NUM_SLOTS, fTemplate.ContainerSlots);
    SetUInt32(ITEM_FIELD_STACK_COUNT, 1);
  end else
  begin
    if fTemplate.MaximumCount <> 0 then
    begin
      SetUInt32(ITEM_FIELD_STACK_COUNT, fTemplate.MaximumCount);
    end else
    begin
      SetUInt32(ITEM_FIELD_STACK_COUNT, 1);
    end;
  end;
end;

destructor YGaItem.Destroy;
begin
  if fTemplate <> nil then DataCore.ItemTemplates.ReleaseEntry(fTemplate);
  inherited Destroy;
end;

procedure YGaItem.EnterWorld;
var
  cPkt: YNwServerPacket;
begin
  inherited EnterWorld;
  if Owner <> nil then
  begin
    cPkt := YNwServerPacket.Create;
    try
      FillObjectCreationPacket(cPkt);
      YGaPlayer(Owner).AddUpdateBlock(cPkt);
    finally
      cPkt.Free;
    end;
  end;
end;

procedure YGaItem.LeaveWorld;
var
  cPkt: YNwServerPacket;
begin
  if Owner <> nil then
  begin
    cPkt := YNwServerPacket.Create;
    try
      FillObjectDestructionPacket(cPkt, True);
      YGaPlayer(Owner).Session.SendPacket(cPkt);
    finally
      cPkt.Free;
    end;
  end;
  inherited LeaveWorld;
end;

procedure YGaItem.ExtractObjectData(const Entry: ISerializable);
var
  iInt: Int32;
  cItm: IItemEntry;
begin
  inherited ExtractObjectData(Entry);
  cItm := Entry as IItemEntry;
  Self.Entry := cItm.EntryId;
  LoadTemplate(cItm.EntryId);
  GUIDLo := cItm.UniqueID;
  SetFloat(OBJECT_FIELD_SCALE_X, 1.0);
  SetUInt64(ITEM_FIELD_OWNER, fOwner.GUID^.Full);
  if fContained <> nil then
  begin
    SetUInt64(ITEM_FIELD_CONTAINED, fContained.GUID^.Full);
  end else
  begin
    SetUInt64(ITEM_FIELD_CONTAINED, fOwner.GUID^.Full);
  end;

  if fTemplate <> nil then
  begin
    SetUInt32(ITEM_FIELD_STACK_COUNT, cItm.StackCount);
    for iInt := 0 to __ITEM_FIELD_SPELL_CHARGES -1 do
    begin
      SetUInt32(ITEM_FIELD_SPELL_CHARGES + iInt, {fTemplate.Spells[iInt].Charges}0);
    end;
    SetUInt32(ITEM_FIELD_FLAGS, fTemplate.Flags);
    SetUInt32(ITEM_FIELD_DURATION, fTemplate.Delay);
    SetUInt32(ITEM_FIELD_DURABILITY, cItm.Durability);
    SetUInt32(ITEM_FIELD_MAXDURABILITY, fTemplate.MaximumDurability);
  end;
end;

procedure YGaItem.InjectObjectData(const Entry: ISerializable);
var
  iStackCount: Int32;
  cItm: IItemEntry;
begin
  inherited InjectObjectData(Entry);
  cItm := Entry as IItemEntry;
  cItm.EntryId := GetUInt32(OBJECT_FIELD_ENTRY);
  cItm.ContainedId := GetUInt32(ITEM_FIELD_CONTAINED);
  cItm.Creator := GetUInt32(ITEM_FIELD_CREATOR);
  iStackCount :=  GetUInt32(ITEM_FIELD_STACK_COUNT);
  if iStackCount = 0 then Inc(iStackCount);
  cItm.StackCount := iStackCount;
  cItm.Durability := GetUInt32(ITEM_FIELD_DURABILITY);
end;

function YGaItem.IsInBag: Boolean;
begin
  Result := fContained <> fOwner;
end;

procedure YGaItem.LoadTemplate(iTempId: Int32);
begin
  if fTemplate <> nil then DataCore.ItemTemplates.ReleaseEntry(fTemplate);
  DataCore.ItemTemplates.LookupEntry(iTempId, fTemplate);
end;

procedure YGaItem.OnValuesUpdate;
var
  cPkt: YNwServerPacket;
begin
  cPkt := YNwServerPacket.Create;
  try
    FillObjectUpdatePacket(cPkt);
    YGaPlayer(Owner).AddUpdateBlock(cPkt);
  finally
    cPkt.Free;
  end;
end;

procedure YGaItem.SetContained(cContainer: YGaItem);
begin
  fContained := cContainer;
  SetUInt64(ITEM_FIELD_CONTAINED, cContainer.GUID^.Full);
end;

procedure YGaItem.SetOwner(cOwner: YGaWowObject);
begin
  fOwner := cOwner;
  SetUInt64(ITEM_FIELD_OWNER, cOwner.GUID^.Full);
end;

procedure YGaItem.SetStackCount(iNewCount: UInt32);
begin
  SetUInt32(ITEM_FIELD_STACK_COUNT, iNewCount);
end;

function YGaItem.GetCreator: IPlayer;
var
  iRes: Integer;
  cPlr: YGaPlayer;
begin
  iRes := GetUInt32(ITEM_FIELD_CREATOR);
  if iRes <> 0 then
  begin
    if GameCore.FindObjectByGUID(otPlayer, iRes, cPlr) then
    begin
      Result := cPlr as IPlayer;
    end else Result := nil;
  end else Result := nil;
end;

function YGaItem.GetEntry: Integer;
begin
  Result := fTemplate.UniqueID;
end;

class function YGaItem.GetObjectType: Int32;
begin
  Result := UPDATEFLAG_ITEM;
end;

function YGaItem.GetOccupiedSlot: Integer;
begin
{ TODO 2 -oSeth -cExtension engine : 
Unimplemented yet. Implementation planned 
once extension core is being worked on. }
  Result := 0;
end;

class function YGaItem.GetOpenObjectType: YWowObjectType;
begin
  Result := otItem;
end;

function YGaItem.GetOwner: IUnit;
begin
  { TODO 2 -oSeth -cExtension engine : 
Unimplemented yet. Implementation planned 
once extension core is being worked on. }
  Result := nil;
end;

function YGaItem.GetOwnerBag: IBag;
begin
  { TODO 2 -oSeth -cExtension engine : 
Unimplemented yet. Implementation planned 
once extension core is being worked on. }
  Result := nil;
end;

function YGaItem.GetStackCount: UInt32;
begin
  Result := GetUInt32(ITEM_FIELD_STACK_COUNT);
end;

end.
