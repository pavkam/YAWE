{*------------------------------------------------------------------------------
  Types to be used all over the GameCore (possibly ExtensionCore).

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author Morpheus

------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.Types;

interface

uses
  Framework.Base,
  Components.GameCore.Constants,
  Components.DataCore.Types,
  Components.GameCore.WowContainer,
  Components.GameCore.WowItem;

type
  YSlotConversionType = (sctEquipped, sctBags, sctBackpack, sctBank, sctBankBags, sctBuyback, sctKeyring);   ///Used in conversions (absolute to relative and vice-versa)

type
  {$REGION 'Equipment Utility Types'}
  PEquipment = ^YEquipment;  ///Pointer to YEquipment
  ///Record containing Equipment elements
  YEquipment = record
    { Ahh, a *nice* hack, we'll use an union }
    case Byte of
      0: (
        Items: array[ITEMS_START..ITEMS_END] of YGaItem; { All items }
      );
      1: (
        Containers: array[ITEMS_START..ITEMS_END] of YGaContainer; { All items as containers }
      );
      2: (
        EquippedItems : array[0..EQUIPMENT_SLOT_END      - EQUIPMENT_SLOT_START     ] of YGaItem;
        Bags          : array[0..INVENTORY_SLOT_BAG_END  - INVENTORY_SLOT_BAG_START ] of YGaContainer;
        Backpack      : array[0..INVENTORY_SLOT_ITEM_END - INVENTORY_SLOT_ITEM_START] of YGaItem;
        Bank          : array[0..BANK_SLOT_ITEM_END      - BANK_SLOT_ITEM_START     ] of YGaItem;
        BankBags      : array[0..BANK_SLOT_BAG_END       - BANK_SLOT_BAG_START      ] of YGaContainer;
        Buyback       : array[0..BUYBACK_SLOT_END        - BUYBACK_SLOT_START       ] of YGaItem;
        Keyring       : array[0..KEYRING_SLOT_END        - KEYRING_SLOT_START       ] of YGaItem;
      );
  end;

  ///Previous Item used record
  YPrevItemUsed = record
    iSlot: UInt8;
    fItem: YGaItem;
  end;

const
  /// Slots offsets Table (used for coversions from a slot to another)
  SlotOffsetTable: array[YSlotConversionType] of UInt8 = (
    EQUIPMENT_SLOT_START,
    INVENTORY_SLOT_BAG_START,
    INVENTORY_SLOT_ITEM_START,
    BANK_SLOT_ITEM_START,
    BANK_SLOT_BAG_START,
    BUYBACK_SLOT_START,
    KEYRING_SLOT_START
  );
{$ENDREGION}

type
  {$REGION 'Trade Utility Types'}
  PTradeItem = ^YTradeItem;  ///Pointer to YTradeItem
  ///Record with trade items
  YTradeItem = record
    iBag, iSlot, iEntry, iStackCount: UInt32;
  end;

  YTradeItemArray = array[0..MAXIMUM_TRADE_ITEMS] of YTradeItem;  ///Array of trade-able items
{$ENDREGION}

implementation

end.
