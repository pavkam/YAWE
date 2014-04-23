{*------------------------------------------------------------------------------
  Custom Packet Builders.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.PacketBuilders;

interface

uses
  Framework.Base,
  Components.Shared,
  Components.NetworkCore.Packet,
  Components.NetworkCore.OpCodes,
  Components.GameCore.WowMobile,
  Components.GameCore.WowObject,
  Components.GameCore.UpdateFields,
  Components.GameCore.Constants;

const
  COMPRESS_UPDATES_AT = 1 shl 6;
  { Compresses update packets with COMPRESS_UPDATE_AT or more bytes }

procedure FillUpdatePacket(Data: YNwPacket; Update: YNwServerPacket);

{ Builds a chat chat packet, displayed as sent by the owner }
function BuildChatPacket(cObject: YGaWowObject; iType: UInt8; iLanguage: YGameLanguage;
  const pMessage: PChar; iLen: Int32; const sChannel: string = ''): YNwServerPacket; overload;

{ The same as previous, but the message is colored }
function BuildChatPacket(cObject: YGaWowObject; iType: UInt8; iLanguage: YGameLanguage;
  const pMessage: PChar; iLen: Int32; cColor: ColorCode;
  const sChannel: string = ''): YNwServerPacket; overload;

{ Builds an anonymous chat packet, usually a system message }
function BuildChatPacketServer(const pMessage: PChar; iLen: Int32): YNwServerPacket; overload;

{ The same as previous, but the message is colored }
function BuildChatPacketServer(const pMessage: PChar; iLen: Int32;
  cColor: ColorCode): YNwServerPacket; overload;

implementation

uses
  Components.GameCore.WowPlayer,
  Bfg.Compression,
  Bfg.Utils;

{ Creates the Update Packet, and compresses it if it's big enough }
procedure FillUpdatePacket(Data: YNwPacket; Update: YNwServerPacket);
var
  pData: Pointer;
  iSize: Int32;
  iOutSize: Int32;
begin
  if (Data.WritePos >= COMPRESS_UPDATES_AT) then
  begin
    { Compressing }
    iSize := Data.WritePos;
    pData := Compress(Data.GetPtr(0), iSize, iOutSize);
    try
      Update.Initialize(SMSG_COMPRESSED_UPDATE_OBJECT, iOutSize + 4);
      Update.AddUInt32(iSize);
      Update.AddPtrData(pData, iOutSize);
    finally
      FreeMem(pData);
    end;
  end else
  begin
    Update.Initialize(SMSG_UPDATE_OBJECT, Data.WritePos);
    Update.AddBuffer(Data);
    { Just add the data - it's already there }
  end;
end;

const
  ReplyTable: array[CHAT_MSG_SAY..CHAT_MSG_LOOT] of Boolean = (
    True, True, True, True, True, True, True,
    True, True, False, False, False, False,
    False, True, False, False, False, False,
    False, False, False, False, False, False,
    False
  );
  ReplyTableSec: array[CHAT_MSG_SAY..CHAT_MSG_LOOT] of Boolean = (
    True, True, False, False, False, True, False,
    False, False, False, False, False, False,
    False, False, False, False, False, False,
    False, False, False, False, False, False,
    False
  );

function BuildChatPacket(cObject: YGaWowObject; iType: UInt8; iLanguage: YGameLanguage;
  const pMessage: PChar; iLen: Int32; const sChannel: string = ''): YNwServerPacket;
var
  iMessageLen: UInt32;
  iGUIDLo, iGUIDHi: UInt32;
begin
  Result := YNwServerPacket.Initialize(SMSG_MESSAGECHAT);

  iMessageLen := iLen + 1; { Null-terminator }
  Result.AddUInt8(iType);
  Result.AddUInt32(Ord(iLanguage));

  { Add channel if is the case to }
  if iType = CHAT_MSG_CHANNEL then
  begin
    Result.AddString(sChannel);
    Result.JumpUInt32;
  end;
  if ReplyTable[iType] then
  begin
    iGUIDLo := YGaPlayer(cObject).GUIDLo;
    iGUIDHi := YGaPlayer(cObject).GUIDHi;
  end else
  begin
    iGUIDLo := 0;
    iGUIDHi := 0;
  end;

  Result.AddUInt32(iGUIDLo);
  Result.AddUInt32(iGUIDHi);

  if ReplyTableSec[iType] then
  begin
    Result.AddUInt32(iGUIDLo);
    Result.AddUInt32(iGUIDHi);
  end;

  Result.AddUInt32(iMessageLen);
  Result.AddPtrData(pMessage, iMessageLen);

  Result.AddUInt8(0);
end;

function BuildChatPacket(cObject: YGaWowObject; iType: UInt8; iLanguage: YGameLanguage;
  const pMessage: PChar; iLen: Int32; cColor: ColorCode;
  const sChannel: string = ''): YNwServerPacket;
var
  iMessageLen: UInt32;
  iGUIDLo, iGUIDHi: UInt32;
begin
  Result := YNwServerPacket.Initialize(SMSG_MESSAGECHAT);

  iMessageLen := iLen + 13; { Null-terminator, Color Code, "|c", "|r" }
  Result.AddUInt8(iType);
  Result.AddUInt32(Ord(iLanguage));

  { Add channel if is the case to }
  if iType = CHAT_MSG_CHANNEL then
  begin
    Result.AddString(sChannel);
    Result.JumpUInt32;
  end;
  if ReplyTable[iType] then
  begin
    iGUIDLo := YGaPlayer(cObject).GUIDLo;
    iGUIDHi := YGaPlayer(cObject).GUIDHi;
  end else
  begin
    iGUIDLo := 0;
    iGUIDHi := 0;
  end;

  Result.AddUInt32(iGUIDLo);
  Result.AddUInt32(iGUIDHi);

  if ReplyTableSec[iType] then
  begin
    Result.AddUInt32(iGUIDLo);
    Result.AddUInt32(iGUIDHi);
  end;

  Result.AddUInt32(iMessageLen);
  Result.AddUInt16($637C); { |c }
  Result.AddPtrData(cColor, 8);
  Result.AddPtrData(pMessage, iLen);
  Result.AddUInt16($727C); { |r }
  Result.JumpUInt8;

  Result.AddUInt8(0);
end;

function BuildChatPacketServer(const pMessage: PChar; iLen: Int32): YNwServerPacket;
var
  iMessageLen: UInt32;
begin
  Result := YNwServerPacket.Initialize(SMSG_MESSAGECHAT);

  iMessageLen := iLen + 1; { Null-terminator }
  Result.AddUInt8(CHAT_MSG_SYSTEM);
  Result.AddUInt32(Ord(glUniversal));
  Result.JumpUInt64;
  Result.AddUInt32(iMessageLen);
  Result.AddPtrData(pMessage, iMessageLen);
  Result.JumpUInt8;
end;

function BuildChatPacketServer(const pMessage: PChar; iLen: Int32;
  cColor: ColorCode): YNwServerPacket;
var
  iMessageLen: UInt32;
begin
  Result := YNwServerPacket.Initialize(SMSG_MESSAGECHAT);

  iMessageLen := iLen + 13; { Null-terminator, Color Code, "|c", "|r" }
  Result.AddUInt8(CHAT_MSG_SYSTEM);
  Result.AddUInt32(Ord(glUniversal));
  Result.JumpUInt64;
  Result.AddUInt32(iMessageLen);
  Result.AddUInt16($637C); { |c }
  Result.AddPtrData(cColor, 8);
  Result.AddPtrData(pMessage, iLen);
  Result.AddUInt16($727C); { |r }
  Result.JumpUInt16;
end;

end.
