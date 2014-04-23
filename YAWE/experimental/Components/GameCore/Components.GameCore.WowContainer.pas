{*------------------------------------------------------------------------------
  OpenContainer. Derives from OpenItem.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author BigBoss
  @Changes Seth
------------------------------------------------------------------------------}
{$I compiler.inc}
unit Components.GameCore.WowContainer;

interface

uses
  Framework.Base,
  Components.GameCore.WowObject,
  Components.GameCore.UpdateFields,
  Components.GameCore.Constants,
  Components.GameCore.Interfaces,
  Components.GameCore.WowItem,
  Components.DataCore.Types;

const
  MAX_BAG_SLOTS = 30;

type
  YBagType = (btNormal, btAmmo, btGem, btEnchanting, btHerbs, btSoul, btEngineering);

  YGaContainer = class(YGaItem, IObject, IItem)
    private
      fSlots: array[0..MAX_BAG_SLOTS-1] of YGaItem;
      fOccupiedSlots: UInt32;
      fType: YBagType;

      function GetBagType: YBagType; inline;
      function GetNumOfSlots: UInt32; inline;
      function GetNumOfFreeSlots: UInt32; inline;
      function GetContainerItem(iSlot: UInt8): YGaItem; inline;
      procedure SetContainerItem(iSlot: UInt8; cItem: YGaItem);
    protected
      class function GetObjectType: Int32; override;
      class function GetOpenObjectType: YWowObjectType; override;

      procedure EnterWorld; override;
      procedure LeaveWorld; override;
    public
      procedure ExtractObjectData(cEntry: YDbSerializable); override;
      procedure InjectObjectData(cEntry: YDbSerializable); override;

      procedure ExchangeBagContents(cWithBag: YGaContainer);
      function AddItem(cItem: YGaItem; iSlot: UInt8): UInt8;
      function RemoveItem(iSlot: UInt8; bDestroy: Boolean): YGaItem;
      procedure SwapItems(iSrcSlot, iDestSlot: UInt8);

      function IsEmpty: Boolean;
      function FindFreeSlot: UInt8;
      property NumOfSlots: UInt32 read GetNumOfSlots;
      property NumOfFreeSlots: UInt32 read GetNumOfFreeSlots;
      property Items[iSlot: UInt8]: YGaItem read GetContainerItem write SetContainerItem;
      property BagType: YBagType read GetBagType;
  end;

implementation

uses
  Cores,
  Components.NetworkCore.Constants;

{ YOpenContainer }

function YGaContainer.GetBagType: YBagType;
begin
  Result := fType;
end;

function YGaContainer.AddItem(cItem: YGaItem; iSlot: UInt8): UInt8;
begin
  if iSlot = SLOT_NULL then
  begin
    iSlot := FindFreeSlot;
    if iSlot = SLOT_NULL then
    begin
      Result := INV_ERR_BAG_FULL;
      Exit;
    end;
  end;
  Assert(fSlots[iSlot] = nil);
  fSlots[iSlot] := cItem;
  cItem.Contained := Self;
  Owner.SetUInt64(CONTAINER_FIELD_SLOT_1 + iSlot * 2, cItem.GUID^.Full);
  Inc(fOccupiedSlots);
  Result := INV_ERR_OK;
end;

procedure YGaContainer.EnterWorld;
var
  iIdx: Int32;
begin
  inherited EnterWorld;
  if Owner <> nil then
  begin
    for iIdx := 0 to MAX_BAG_SLOTS -1 do
    begin
      if Items[iIdx] <> nil then
      begin
        Items[iIdx].ChangeWorldState(wscEnter);
      end;
    end;
  end;
end;

procedure YGaContainer.LeaveWorld;
var
  iIdx: Int32;
begin
  if Owner <> nil then
  begin
    for iIdx := 0 to MAX_BAG_SLOTS -1 do
    begin
      if Items[iIdx] <> nil then
      begin
        Items[iIdx].ChangeWorldState(wscLeave);
      end;
    end;
  end;
  inherited LeaveWorld;
end;

procedure YGaContainer.ExchangeBagContents(cWithBag: YGaContainer);
var
  iTmp: Int32;
  cTemp: YGaItem;
  iIdx: Int32;
begin
  iTmp := fOccupiedSlots;
  fOccupiedSlots := cWithBag.fOccupiedSlots;
  cWithBag.fOccupiedSlots := iTmp;
  for iIdx := 0 to NumOfSlots -1 do
  begin
    cTemp := cWithBag.fSlots[iIdx];
    cWithBag.fSlots[iIdx] := fSlots[iIdx];
    fSlots[iIdx] := cTemp;
    if cWithBag.fSlots[iIdx] <> nil then
    begin
      cWithBag.fSlots[iIdx].Contained := cWithBag;
      cWithBag.SetUInt64(CONTAINER_FIELD_SLOT_1 + iIdx * 2, cWithBag.fSlots[iIdx].GUID^.Full);
    end else
    begin
      cWithBag.SetUInt64(CONTAINER_FIELD_SLOT_1 + iIdx * 2, 0);
    end;
    if fSlots[iIdx] <> nil then
    begin
      SetUInt64(CONTAINER_FIELD_SLOT_1 + iIdx * 2, fSlots[iIdx].GUID^.Full);
    end else
    begin
      SetUInt64(CONTAINER_FIELD_SLOT_1 + iIdx * 2, 0);
    end;
  end;
end;

procedure YGaContainer.ExtractObjectData(cEntry: YDbSerializable);
var
  cItm: YDbItemEntry;
  iIdx: Int32;
  cItem: YGaItem;
begin
  cItm := YDbItemEntry(cEntry);
  inherited ExtractObjectData(cEntry);
  SetUInt32(CONTAINER_FIELD_NUM_SLOTS, fTemplate.ContainerSlots);
  for iIdx := 0 to High(cItm.ItemsContained) do
  begin
    if cItm.ItemsContained[iIdx] <> 0 then
    begin
      cItem := YGaItem(GameCore.CreateObject(otItem, True));
      cItem.GUIDLo := cItm.ItemsContained[iIdx];
      cItem.Owner := fOwner;
      cItem.LoadFromDataBase;
      SetUInt64(CONTAINER_FIELD_SLOT_1 + iIdx * 2, cItem.GUID^.Full);
      fSlots[iIdx] := cItem;
    end;
  end;
end;

procedure YGaContainer.InjectObjectData(cEntry: YDbSerializable);
var
  cItm: YDbItemEntry;
  iIdx: Int32;
begin
  cItm := YDbItemEntry(cEntry);
  inherited InjectObjectData(cEntry);
  cItm.SetItemsContainedLength(MAX_BAG_SLOTS);
  for iIdx := 0 to MAX_BAG_SLOTS-1 do
  begin
    cItm.ItemsContained[iIdx] := GetUInt32(CONTAINER_FIELD_SLOT_1 + iIdx * 2);
  end;
end;

function YGaContainer.FindFreeSlot: UInt8;
begin
  for Result := 0 to GetNumOfSlots -1 do
  begin
    if fSlots[Result] = nil then Exit;
  end;
  Result := SLOT_NULL;
end;

function YGaContainer.GetContainerItem(iSlot: UInt8): YGaItem;
begin
  Result := fSlots[iSlot];
end;

function YGaContainer.GetNumOfFreeSlots: UInt32;
begin
  Result := GetNumOfSlots - fOccupiedSlots;
end;

function YGaContainer.GetNumOfSlots: UInt32;
begin
  Result := GetUInt32(CONTAINER_FIELD_NUM_SLOTS);
end;

class function YGaContainer.GetObjectType: Int32;
begin
  Result := UPDATEFLAG_CONTAINER;
end;

class function YGaContainer.GetOpenObjectType: YWowObjectType;
begin
  Result := otContainer;
end;

function YGaContainer.IsEmpty: Boolean;
begin
  Result := fOccupiedSlots = 0;
end;

function YGaContainer.RemoveItem(iSlot: UInt8; bDestroy: Boolean): YGaItem;
begin
  Result := fSlots[iSlot];

  if Result <> nil then
  begin
    fSlots[iSlot] := nil;
    if bDestroy then
    begin
      Result.ChangeWorldState(wscRemove);
      Result.DeleteFromDataBase;
      Result.Destroy;
      Result := nil;
    end else
    begin
      Result.Contained := nil;
    end;
    SetUInt64(CONTAINER_FIELD_SLOT_1 + iSlot * 2, 0);
    Dec(fOccupiedSlots);
  end;
end;

procedure YGaContainer.SwapItems(iSrcSlot, iDestSlot: UInt8);
var
  cTmp: YGaItem;
begin
  cTmp := fSlots[iSrcSlot];
  fSlots[iSrcSlot] := fSlots[iDestSlot];
  fSlots[iDestSlot] := cTmp;
  if fSlots[iSrcSlot] <> nil then
  begin
    SetUInt64(CONTAINER_FIELD_SLOT_1 + iSrcSlot * 2, fSlots[iSrcSlot].GUID^.Full);
  end else
  begin
    SetUInt64(CONTAINER_FIELD_SLOT_1 + iSrcSlot * 2, 0);
  end;

  if fSlots[iDestSlot] <> nil then
  begin
    SetUInt64(CONTAINER_FIELD_SLOT_1 + iDestSlot * 2, fSlots[iDestSlot].GUID^.Full);
  end else
  begin
    SetUInt64(CONTAINER_FIELD_SLOT_1 + iDestSlot * 2, 0);
  end;
end;

procedure YGaContainer.SetContainerItem(iSlot: UInt8; cItem: YGaItem);
begin
  fSlots[iSlot] := cItem;
  if cItem <> nil then
  begin
    SetUInt64(CONTAINER_FIELD_SLOT_1 + iSlot * 2, fSlots[iSlot].GUID^.Full);
  end else
  begin
    SetUInt64(CONTAINER_FIELD_SLOT_1 + iSlot * 2, 0);
  end;
end;

end.
