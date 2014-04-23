{*------------------------------------------------------------------------------
  Basic data classes (packets)
  
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
unit Components.NetworkCore.Packet;

interface

uses
  Framework.Base,
  Components.NetworkCore.HdrXor,
  Bfg.Containers.ByteBuffer,
  Bfg.Containers;

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
  Bfg.Threads,
  Bfg.Utils;

procedure YNwPacket.ReadPackedGUID(Guid: Pointer);
var
  Start: PUInt8;
  GuidPtr: PUInt8;
  Mask: UInt8;
begin
  GuidPtr := @FBuffer[FReadPos];
  Start := GuidPtr;
  Mask := GuidPtr^;
  Inc(GuidPtr);

  if GetBit32(Mask, 0) then
  begin
    PByteArray(Guid)^[0] := GuidPtr^;
    Inc(GuidPtr);
  end else PByteArray(Guid)^[0] := 0;

  if GetBit32(Mask, 1) then
  begin
    PByteArray(Guid)^[1] := GuidPtr^;
    Inc(GuidPtr);
  end else PByteArray(Guid)^[1] := 0;

  if GetBit32(Mask, 2) then
  begin
    PByteArray(Guid)^[2] := GuidPtr^;
    Inc(GuidPtr);
  end else PByteArray(Guid)^[2] := 0;

  if GetBit32(Mask, 3) then
  begin
    PByteArray(Guid)^[3] := GuidPtr^;
    Inc(GuidPtr);
  end else PByteArray(Guid)^[3] := 0;

  if GetBit32(Mask, 4) then
  begin
    PByteArray(Guid)^[4] := GuidPtr^;
    Inc(GuidPtr);
  end else PByteArray(Guid)^[4] := 0;

  if GetBit32(Mask, 5) then
  begin
    PByteArray(Guid)^[5] := GuidPtr^;
    Inc(GuidPtr);
  end else PByteArray(Guid)^[5] := 0;

  if GetBit32(Mask, 6) then
  begin
    PByteArray(Guid)^[6] := GuidPtr^;
    Inc(GuidPtr);
  end else PByteArray(Guid)^[6] := 0;

  if GetBit32(Mask, 7) then
  begin
    PByteArray(Guid)^[7] := GuidPtr^;
    Inc(GuidPtr);
  end else PByteArray(Guid)^[7] := 0;

  Inc(FReadPos, Longword(GuidPtr) - Longword(Start));
end;

procedure YNwPacket.AddPackedGUID(Guid: Pointer);
var
  Data: PUInt8;
  Mask: PUInt8;
  Val: UInt8;
  MaskVal: UInt8;
begin
  Mask := @FBuffer[FWritePos];
  Data := Mask;
  MaskVal := 0;
  Inc(Data);

  Val := PByteArray(Guid)^[0];
  if Val <> 0 then
  begin
    Data^ := Val;
    MaskVal := 1;
    Inc(Data);
  end;

  Val := PByteArray(Guid)^[1];
  if Val <> 0 then
  begin
    Data^ := Val;
    MaskVal := MaskVal or 2;
    Inc(Data);
  end;

  Val := PByteArray(Guid)^[2];
  if Val <> 0 then
  begin
    Data^ := Val;
    MaskVal := MaskVal or 4;
    Inc(Data);
  end;

  Val := PByteArray(Guid)^[3];
  if Val <> 0 then
  begin
    Data^ := Val;
    MaskVal := MaskVal or 8;
    Inc(Data);
  end;

  Val := PByteArray(Guid)^[4];
  if Val <> 0 then
  begin
    Data^ := Val;
    MaskVal := MaskVal or 16;
    Inc(Data);
  end;

  Val := PByteArray(Guid)^[5];
  if Val <> 0 then
  begin
    Data^ := Val;
    MaskVal := MaskVal or 32;
    Inc(Data);
  end;

  Val := PByteArray(Guid)^[6];
  if Val <> 0 then
  begin
    Data^ := Val;
    MaskVal := MaskVal or 64;
    Inc(Data);
  end;

  Val := PByteArray(Guid)^[7];
  if Val <> 0 then
  begin
    Data^ := Val;
    MaskVal := MaskVal or 128;
    Inc(Data);
  end;

  Mask^ := MaskVal;
  Inc(FWritePos, Longword(Data) - Longword(Mask));
end;

constructor YNwServerPacket.Initialize(OperationCode: UInt16; Size: Int32);
begin
  inherited Create(Size + 4);
  FWritePos := 4;
  GetHeaderData^.Opcode := OperationCode;
end;

procedure YNwServerPacket.Finalize(var EncryptionContext: YEncryptionContext;
  Buffer: TCircularBuffer);
var
  Local: PByteArray;
begin
  GetMem(Local, FWritePos);
  try
    Move(fBuffer[0], Local^, FWritePos);
    PWord(Local)^ := EndianSwap16(FWritePos - 2);
    HdrXorEncrypt(EncryptionContext, Local);
    Buffer.Write(Local^, FWritePos);
  finally
    FreeMem(Local);
  end;
end;

function YNwServerPacket.GetHeaderData: PWorldServerHeader;
begin
  Result := PWorldServerHeader(@FBuffer[0]);
end;

constructor YNwClientPacket.Create(Size: Longword);
begin
  inherited Create(Size);
  FReadPos := 6;
end;

function YNwClientPacket.GetHeaderData: PWorldClientHeader;
begin
  Result := PWorldClientHeader(@FBuffer[0]);
end;

end.
