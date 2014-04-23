{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Base Data Class.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth, TheSelby
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Bfg.Containers.ByteBuffer;

interface

uses
  SysUtils,
  Bfg.Utils,
  Bfg.Containers.Interfaces{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

const
  BYTE_BUFFER_SIZE = $4000; { 16kB default buffer should be big enough }

type
  TBufferSeekType = (bstForward, bstBackward);

  TByteBuffer = class(TObject)
    protected
      FSize: Integer;
      FReadPos: Integer;
      FWritePos: Integer;
      FBuffer: TByteDynArray;
      
      function GetByte(Index: Integer): Byte; inline;
      procedure SetByte(Index: Integer; Value: Byte); inline;
      procedure AddObjPlain(const Src; Index: Integer; Size: Integer);
      procedure GetObjPlain(var Dest; Index: Integer; Size: Integer);
      procedure AddObj(const Src; Index: Integer; Size: Integer);
      procedure GetObj(var Dest; Index: Integer; Size: Integer);
      procedure SetSize(Size: Integer);
    public
      constructor Create(Size: Integer = BYTE_BUFFER_SIZE); overload;
      constructor Create(const DataSource; Size: Integer); overload;
      constructor Clone(Buffer: TByteBuffer);

      {$REGION 'Add/Read methods'}
      procedure AddUInt8(Value: Byte); overload; inline;
      procedure AddUInt16(Value: Word); overload; inline;
      procedure AddUInt32(Value: Longword); overload; inline;
      procedure AddUInt64(const Value: Int64); overload; inline;
      procedure AddString(const Str: AnsiString); overload; inline;
      procedure AddStringMultiple(const Strings: array of AnsiString);
      procedure AddStringData(const Str: AnsiString); inline;
      procedure AddFloat(Value: Single); overload; inline;
      procedure AddBool(Value: Boolean); overload; inline;
      procedure AddStruct(const Data; Size: Integer); overload; inline;
      procedure AddPtrData(Data: Pointer; Size: Integer); overload; inline;
      procedure AddBuffer(Data: TByteBuffer); inline;

      function ReadUInt8: Byte; overload; inline;
      function ReadUInt16: Word; overload; inline;
      function ReadUInt32: Longword; overload; inline;
      function ReadUInt64: Int64; overload; inline;
      function ReadString: AnsiString; overload; inline;
      function ReadFloat: Single; overload; inline;
      procedure ReadStruct(var Data; Size: Integer); overload; inline;
      procedure ReadPtrData(Data: Pointer; Size: Integer); overload; inline;
      {$ENDREGION}

      {$REGION 'Add/Read methods(indexed)'}
      procedure AddUInt8(Value: Byte; Index: Integer); overload; inline;
      procedure AddUInt16(Value: Word; Index: Integer); overload; inline;
      procedure AddUInt32(Value: Longword; Index: Integer); overload; inline;
      procedure AddUInt64(const Value: Int64; Index: Integer); overload; inline;
      procedure AddString(const Str: AnsiString; Index: Integer); overload; inline;
      procedure AddFloat(Value: Single; Index: Integer); overload; inline;
      procedure AddBool(Value: Boolean; Index: Integer); overload; inline;
      procedure AddStruct(const Data; Size: Integer; Index: Integer); overload; inline;
      procedure AddPtrData(Data: Pointer; Size: Integer; Index: Integer); overload; inline;

      function ReadUInt8(Index: Integer): Byte; overload; inline;
      function ReadUInt16(Index: Integer): Word; overload; inline;
      function ReadUInt32(Index: Integer): Longword; overload; inline;
      function ReadUInt64(Index: Integer): Int64; overload; inline;
      function ReadString(Index: Integer): AnsiString; overload; inline;
      function ReadFloat(Index: Integer): Single; overload; inline;
      procedure ReadStruct(var Data; Size: Integer; Index: Integer); overload; inline;
      procedure ReadPtrData(Data: Pointer; Size: Integer; Index: Integer); overload; inline;
      {$ENDREGION}

      {$REGION 'Pointer Methods'}
      (*
        Use these functions only when you know, what you're doing. :)
        Useful when you want to read data of static length (no strings, pchars or dynarrays).
        GetPtr:
          Args: Index - Integer
          Returns: Pointer
          Description: Returns pointer to the Index-byte in the packet's buffer.
          Warning: No range-checking.

        GetCurrentReadPtr
          Args: None
          Returns: Pointer;
          Description: Returns pointer to the current byte (next byte after the last one read).

        GetCurrentWritePtr
          Args: None
          Returns: Pointer;
          Description: Returns pointer to the current byte (next byte after the last one written).

        GetReadPtrOfSize
          Args: iExpectedSize - Integer
          Returns: Pointer;
          Description: The same as GetCurrentReadPtr, but it acts as if you had actually
                       read the data of iExpectedSize bytes size. You can achieve the same
                       effect by using GetCurrentReadPtr and then Skip(iExpectedSize).

        GetWritePtrOfSize
          Args: iExpectedSize - Integer
          Returns: Pointer;
          Description: The same as GetCurrentWritePtr, but it acts as if you had actually
                       written the data of iExpectedSize bytes size. You can achieve the same
                       effect by using GetCurrentWritePtr and then Jump(iExpectedSize).

        Example: See Components.GameCore.Session unit, class YOpenSession, method "HandleCharCreateOpcode".
      *)
      function GetPtr(Index: Integer): Pointer; inline;
      function GetCurrentReadPtr: Pointer; inline;
      function GetCurrentWritePtr: Pointer; inline;
      function GetReadPtrOfSize(ExpectedSize: Integer): Pointer; inline;
      function GetWritePtrOfSize(ExpectedSize: Integer): Pointer; inline;
      {$ENDREGION}

      function SeekWritePointer(SeekType: TBufferSeekType; Count: Integer): Integer;
      function SeekReadPointer(SeekType: TBufferSeekType; Count: Integer): Integer;

      procedure Jump(Count: Integer); inline;
      procedure JumpUInt8; inline;
      procedure JumpUInt16; inline;
      procedure JumpUInt32; inline;
      procedure JumpUInt64; inline;

      procedure Skip(Count: Integer); inline;
      procedure SkipUInt8; inline;
      procedure SkipUInt16; inline;
      procedure SkipUInt32; inline;
      procedure SkipUInt64; inline;

      function BufferToString: string;
      function RemainingBufferToString: string;
      function ReadAllFrom(Index: Integer): string;

      procedure Clear;

      property Size: Integer read FSize write SetSize;
      property WritePos: Integer read FWritePos write FWritePos;
      property ReadPos: Integer read FReadPos write FReadPos;
      property Storage: TByteDynArray read FBuffer;
      property Bytes[Index: Integer]: Byte read GetByte write SetByte; default;
  end;

implementation

constructor TByteBuffer.Create(const DataSource; Size: Integer);
begin
  inherited Create;
  SetLength(FBuffer, Size);
  AddObj(DataSource, 0, Size);
end;

constructor TByteBuffer.Create(Size: Integer);
begin
  inherited Create;
  if Size = 0 then Size := BYTE_BUFFER_SIZE;
  SetLength(FBuffer, Size);
  FSize := Size;
end;

constructor TByteBuffer.Clone(Buffer: TByteBuffer);
begin
  SetLength(FBuffer, Buffer.Size);
  Create(Buffer.Storage[0], Buffer.Size);
end;

procedure TByteBuffer.AddObjPlain(const Src; Index: Integer; Size: Integer);
begin
  { Copy Size-bytes to the tail }
  Move(Src, FBuffer[Index], Size);
end;

procedure TByteBuffer.GetObjPlain(var Dest; Index: Integer; Size: Integer);
begin
  { Copy Size-bytes from the tail }
  Move(FBuffer[Index], Dest, Size);
end;

procedure TByteBuffer.AddObj(const Src; Index: Integer; Size: Integer);
var
  iIncAmount: Integer;
begin
  iIncAmount := (Index + Size) - FWritePos;
  { Copy Size-bytes to the tail }
  Move(Src, FBuffer[Index], Size);
  { And increase increase fSize if required }
  Inc(FWritePos, iIncAmount);
end;

procedure TByteBuffer.GetObj(var Dest; Index: Integer; Size: Integer);
var
  iIncAmount: Integer;
begin
  iIncAmount := (Index + Size) - FReadPos;
  { Copy Size-bytes from the tail }
  Move(FBuffer[Index], Dest, Size);
  { And increase increase fReadPos if required }
  Inc(FReadPos, iIncAmount);
end;

function TByteBuffer.SeekReadPointer(SeekType: TBufferSeekType;
  Count: Integer): Integer;
begin
  case SeekType of
    bstForward:
    begin
      Inc(FReadPos, Count);
    end;
    bstBackward:
    begin
      Dec(FReadPos, Count);
    end;
  end;
  Result := FReadPos;
end;

function TByteBuffer.SeekWritePointer(SeekType: TBufferSeekType;
  Count: Integer): Integer;
begin
  case SeekType of
    bstForward:
    begin
      Inc(FWritePos, Count);
    end;
    bstBackward:
    begin
      Dec(FWritePos, Count);
    end;
  end;
  Result := FWritePos;
end;

procedure TByteBuffer.SetByte(Index: Integer; Value: Byte);
begin
  FBuffer[Index] := Value;
end;

function TByteBuffer.GetByte(Index: Integer): Byte;
begin
  Result := FBuffer[Index];
end;

procedure TByteBuffer.SetSize(Size: Integer);
begin
  if Size < FSize then
  begin
    FillChar(FBuffer[Size], FSize - Size, 0);
  end;
  FSize := Size;
end;

procedure TByteBuffer.Jump(Count: Integer);
begin
  Inc(FWritePos, Count);
end;

procedure TByteBuffer.JumpUInt8;
begin
  Inc(FWritePos);
end;

procedure TByteBuffer.JumpUInt16;
begin
  Inc(FWritePos, 2);
end;

procedure TByteBuffer.JumpUInt32;
begin
  Inc(FWritePos, 4);
end;

procedure TByteBuffer.JumpUInt64;
begin
  Inc(FWritePos, 8);
end;

procedure TByteBuffer.Skip(Count: Integer);
begin
  Inc(FReadPos, Count);
end;

procedure TByteBuffer.SkipUInt8;
begin
  Inc(FReadPos);
end;

procedure TByteBuffer.SkipUInt16;
begin
  Inc(FReadPos, 2);
end;

procedure TByteBuffer.SkipUInt32;
begin
  Inc(FReadPos, 4);
end;

procedure TByteBuffer.SkipUInt64;
begin
  Inc(FReadPos, 8);
end;

function TByteBuffer.GetPtr(Index: Integer): Pointer;
begin
  Result := @FBuffer[Index];
end;

function TByteBuffer.GetCurrentReadPtr: Pointer;
begin
  Result := @FBuffer[FReadPos];
end;

function TByteBuffer.GetCurrentWritePtr: Pointer;
begin
  Result := @FBuffer[FWritePos];
end;

function TByteBuffer.GetReadPtrOfSize(ExpectedSize: Integer): Pointer;
begin
  Result := @FBuffer[FReadPos];
  Inc(FReadPos, ExpectedSize);
end;

function TByteBuffer.GetWritePtrOfSize(ExpectedSize: Integer): Pointer;
begin
  Result := @FBuffer[FWritePos];
  Inc(FWritePos, ExpectedSize);
end;

function TByteBuffer.BufferToString: AnsiString;
begin
  SetLength(Result, FWritePos);
  Move(FBuffer[0], Pointer(Result)^, FWritePos);
end;

function TByteBuffer.RemainingBufferToString: AnsiString;
begin
  SetLength(Result, FWritePos - FReadPos);
  Move(FBuffer[FReadPos], Pointer(Result)^, FWritePos - FReadPos);
end;

function TByteBuffer.ReadAllFrom(Index: Integer): AnsiString;
begin
  SetLength(Result, FWritePos - Index);
  Move(FBuffer[Index], Pointer(Result)^, FWritePos - Index);
end;

procedure TByteBuffer.Clear;
begin
  FillChar(FBuffer[0], FWritePos, 0);
  FWritePos := 0;
  FReadPos := 0;
end;
{$ENDREGION}

{$REGION 'Adding of data'}
procedure TByteBuffer.AddUInt8(Value: Byte);
begin
  PByte(@FBuffer[FWritePos])^ := Value;
  Inc(FWritePos);
end;

procedure TByteBuffer.AddUInt16(Value: Word);
begin
  PWord(@FBuffer[FWritePos])^ := Value;
  Inc(FWritePos, 2);
end;

procedure TByteBuffer.AddUInt32(Value: Longword);
begin
  PLongword(@FBuffer[FWritePos])^ := Value;
  Inc(FWritePos, 4);
end;

procedure TByteBuffer.AddUInt64(const Value: Int64);
begin
  PInt64(@FBuffer[FWritePos])^ := Value;
  Inc(FWritePos, 8);
end;

procedure TByteBuffer.AddString(const Str: AnsiString);
begin
  AddObj(Pointer(Str)^, FWritePos, Length(Str));
  Inc(FWritePos);
  { Null-terminated }
end;

procedure TByteBuffer.AddStringMultiple(const Strings: array of AnsiString);
var
  iInt: Integer;
begin
  for iInt := 0 to Length(Strings) -1 do
  begin
    AddString(Strings[iInt]);
  end;
end;

procedure TByteBuffer.AddStringData(const Str: AnsiString);
begin
  AddObj(Pointer(Str)^, FWritePos, Length(Str));
  { NOT Null-terminated }
end;

procedure TByteBuffer.AddFloat(Value: Single);
begin
  PSingle(@FBuffer[FWritePos])^ := Value;
  Inc(FWritePos, 4);
end;

procedure TByteBuffer.AddBool(Value: Boolean);
begin
  PBoolean(@FBuffer[FWritePos])^ := Value;
  Inc(FWritePos);
end;

procedure TByteBuffer.AddStruct(const Data; Size: Integer);
begin
  AddObj(Data, FWritePos, Size);
end;

procedure TByteBuffer.AddPtrData(Data: Pointer; Size: Integer);
begin
  AddObj(Data^, FWritePos, Size);
end;

procedure TByteBuffer.AddBuffer(Data: TByteBuffer);
begin
  AddObj(Data.Storage[0], FWritePos, Data.WritePos);
end;

function TByteBuffer.ReadUInt8: Byte;
begin
  Result := PByte(@FBuffer[FReadPos])^;
  Inc(FReadPos);
end;

function TByteBuffer.ReadUInt16: Word;
begin
  Result := PWord(@FBuffer[FReadPos])^;
  Inc(FReadPos, 2);
end;

function TByteBuffer.ReadUInt32: Longword;
begin
  Result := PLongword(@FBuffer[FReadPos])^;
  Inc(FReadPos, 4);
end;

function TByteBuffer.ReadUInt64: Int64;
begin
  Result := PInt64(@FBuffer[FReadPos])^;
  Inc(FReadPos, 8);
end;

function TByteBuffer.ReadString: AnsiString;
begin
  Inc(FReadPos, PCharToString(GetCurrentReadPtr, Result) + 1); { Count #0 also }
end;

function TByteBuffer.ReadFloat: Single;
begin
  Result := PSingle(@FBuffer[FReadPos])^;
  Inc(FReadPos, 4);
end;

procedure TByteBuffer.ReadStruct(var Data; Size: Integer);
begin
  GetObj(Data, FReadPos, Size);
end;

procedure TByteBuffer.ReadPtrData(Data: Pointer; Size: Integer);
begin
  GetObj(Data^, FReadPos, Size);
end;

procedure TByteBuffer.AddUInt8(Value: Byte; Index: Integer);
begin
  PByte(@FBuffer[Index])^ := Value;
end;

procedure TByteBuffer.AddUInt16(Value: Word; Index: Integer);
begin
  PWord(@FBuffer[Index])^ := Value;
end;

procedure TByteBuffer.AddUInt32(Value: Longword; Index: Integer);
begin
  PLongword(@FBuffer[Index])^ := Value;
end;

procedure TByteBuffer.AddUInt64(const Value: Int64; Index: Integer);
begin
  PInt64(@FBuffer[Index])^ := Value;
end;

procedure TByteBuffer.AddString(const Str: AnsiString; Index: Integer);
begin
  AddObjPlain(Pointer(Str)^, Index, Length(Str));
  Inc(FWritePos);
  { Null-terminated }
end;

procedure TByteBuffer.AddFloat(Value: Single; Index: Integer);
begin
  PSingle(@FBuffer[Index])^ := Value;
end;

procedure TByteBuffer.AddBool(Value: Boolean; Index: Integer);
begin
  PBoolean(@FBuffer[Index])^ := Value;
end;

procedure TByteBuffer.AddStruct(const Data; Size: Integer; Index: Integer);
begin
  AddObjPlain(Data, Index, Size);
end;

procedure TByteBuffer.AddPtrData(Data: Pointer; Size: Integer; Index: Integer);
begin
  AddObjPlain(Data^, Index, Size);
end;

function TByteBuffer.ReadUInt8(Index: Integer): Byte;
begin
  Result := PByte(@FBuffer[Index])^;
end;

function TByteBuffer.ReadUInt16(Index: Integer): Word;
begin
  Result := PWord(@FBuffer[Index])^;
end;

function TByteBuffer.ReadUInt32(Index: Integer): Longword;
begin
  Result := PLongword(@FBuffer[Index])^;
end;

function TByteBuffer.ReadUInt64(Index: Integer): Int64;
begin
  Result := PInt64(@FBuffer[Index])^;
end;

function TByteBuffer.ReadString(Index: Integer): AnsiString;
begin
  PCharToString(GetPtr(Index), Result);
end;

function TByteBuffer.ReadFloat(Index: Integer): Single;
begin
  Result := PSingle(@FBuffer[Index])^;
end;

procedure TByteBuffer.ReadStruct(var Data; Size: Integer; Index: Integer);
begin
  GetObjPlain(Data, Index, Size);
end;

procedure TByteBuffer.ReadPtrData(Data: Pointer; Size: Integer; Index: Integer);
begin
  GetObjPlain(Data^, Index, Size);
end;

end.
