{*------------------------------------------------------------------------------
  Basic data classes (packets)
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.NetworkCore.Packet;

interface

uses
  Framework.Base,
  Components.NetworkCore.HdrXor,
  Misc.Containers.ByteBuffer,
  Misc.Containers;

type
  YNwPacket = class(TByteBuffer)
    public
      procedure AddPackedGUID(Guid: Pointer); { Packs a GUID and adds it to the buffer }
      procedure ReadPackedGUID(Guid: Pointer); { Extracts a packed GUID from the buffer }
  end;

  PWorldServerHeader = ^YWorldServerHeader;
  YWorldServerHeader = packed record { ensure size of 4 }
    Size: UInt16;
    Opcode: UInt16;
  end;

  PWorldClientHeader = ^YWorldClientHeader;
  YWorldClientHeader = packed record { ensure size of 6 }
    Size: UInt16;
    Opcode: UInt32;
  end;

  YNwServerPacket = class(YNwPacket)
    protected
      function GetHeaderData: PWorldServerHeader; inline;
    public
      constructor Initialize(OperationCode: UInt16; Size: Int32 = BYTE_BUFFER_SIZE);
      procedure Finalize(var EncryptionContext: YEncryptionContext; Buffer: TCircularBuffer);
      property Header: PWorldServerHeader read GetHeaderData;
  end;

  YNwClientPacket = class(YNwPacket)
    protected
      function GetHeaderData: PWorldClientHeader; inline;
    public
      constructor Create(Size: Longword);
      property Header: PWorldClientHeader read GetHeaderData;
  end;

implementation

uses
  SysUtils,
  Misc.Threads,
  Misc.Miscleanous;

procedure YNwPacket.ReadPackedGUID(Guid: Pointer);
var
  pStart: PUInt8;
  pGuidPtr: PUInt8;
  iMask: UInt8;
begin
  pGuidPtr := @fBuffer[fReadPos];
  pStart := pGuidPtr;
  iMask := pGuidPtr^;
  Inc(pGuidPtr);

  if GetBit32(iMask, 0) then
  begin
    PByteArray(Guid)^[0] := pGuidPtr^;
    Inc(pGuidPtr);
  end else PByteArray(Guid)^[0] := 0;

  if GetBit32(iMask, 1) then
  begin
    PByteArray(Guid)^[1] := pGuidPtr^;
    Inc(pGuidPtr);
  end else PByteArray(Guid)^[1] := 0;

  if GetBit32(iMask, 2) then
  begin
    PByteArray(Guid)^[2] := pGuidPtr^;
    Inc(pGuidPtr);
  end else PByteArray(Guid)^[2] := 0;

  if GetBit32(iMask, 3) then
  begin
    PByteArray(Guid)^[3] := pGuidPtr^;
    Inc(pGuidPtr);
  end else PByteArray(Guid)^[3] := 0;

  if GetBit32(iMask, 4) then
  begin
    PByteArray(Guid)^[4] := pGuidPtr^;
    Inc(pGuidPtr);
  end else PByteArray(Guid)^[4] := 0;

  if GetBit32(iMask, 5) then
  begin
    PByteArray(Guid)^[5] := pGuidPtr^;
    Inc(pGuidPtr);
  end else PByteArray(Guid)^[5] := 0;

  if GetBit32(iMask, 6) then
  begin
    PByteArray(Guid)^[6] := pGuidPtr^;
    Inc(pGuidPtr);
  end else PByteArray(Guid)^[6] := 0;

  if GetBit32(iMask, 7) then
  begin
    PByteArray(Guid)^[7] := pGuidPtr^;
    Inc(pGuidPtr);
  end else PByteArray(Guid)^[7] := 0;

  Inc(fReadPos, Longword(pGuidPtr) - Longword(pStart));
end;

procedure YNwPacket.AddPackedGUID(Guid: Pointer);
var
  pData: PUInt8;
  pMask: PUInt8;
  iVal: UInt8;
  iMask: UInt8;
begin
  pMask := @fBuffer[fWritePos];
  pData := pMask;
  iMask := 0;
  Inc(pData);

  iVal := PByteArray(Guid)^[0];
  if iVal <> 0 then
  begin
    pData^ := iVal;
    iMask := 1;
    Inc(pData);
  end;

  iVal := PByteArray(Guid)^[1];
  if iVal <> 0 then
  begin
    pData^ := iVal;
    iMask := iMask or 2;
    Inc(pData);
  end;

  iVal := PByteArray(Guid)^[2];
  if iVal <> 0 then
  begin
    pData^ := iVal;
    iMask := iMask or 4;
    Inc(pData);
  end;

  iVal := PByteArray(Guid)^[3];
  if iVal <> 0 then
  begin
    pData^ := iVal;
    iMask := iMask or 8;
    Inc(pData);
  end;

  iVal := PByteArray(Guid)^[4];
  if iVal <> 0 then
  begin
    pData^ := iVal;
    iMask := iMask or 16;
    Inc(pData);
  end;

  iVal := PByteArray(Guid)^[5];
  if iVal <> 0 then
  begin
    pData^ := iVal;
    iMask := iMask or 32;
    Inc(pData);
  end;

  iVal := PByteArray(Guid)^[6];
  if iVal <> 0 then
  begin
    pData^ := iVal;
    iMask := iMask or 64;
    Inc(pData);
  end;

  iVal := PByteArray(Guid)^[7];
  if iVal <> 0 then
  begin
    pData^ := iVal;
    iMask := iMask or 128;
    Inc(pData);
  end;

  pMask^ := iMask;
  Inc(fWritePos, Longword(pData) - Longword(pMask));
end;

constructor YNwServerPacket.Initialize(OperationCode: UInt16; Size: Int32);
begin
  inherited Create(Size + 4);
  fWritePos := 4;
  GetHeaderData^.Opcode := OperationCode;
end;

procedure YNwServerPacket.Finalize(var EncryptionContext: YEncryptionContext;
  Buffer: TCircularBuffer);
var
  Local: PByteArray;
begin
  GetMem(Local, fWritePos);
  try
    Move(fBuffer[0], Local^, fWritePos);
    PWord(Local)^ := EndianSwap16(fWritePos - 2);
    HdrXorEncrypt(EncryptionContext, Local);
    Buffer.Write(Local^, fWritePos);
  finally
    FreeMem(Local);
  end;
end;

function YNwServerPacket.GetHeaderData: PWorldServerHeader;
begin
  Result := PWorldServerHeader(@fBuffer[0]);
end;

constructor YNwClientPacket.Create(Size: Longword);
begin
  inherited Create(Size);
  fReadPos := 6;
end;

function YNwClientPacket.GetHeaderData: PWorldClientHeader;
begin
  Result := PWorldClientHeader(@fBuffer[0]);
end;

end.