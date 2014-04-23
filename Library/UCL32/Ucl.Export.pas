{ ------------------------------------------------------------------------------

  DIUcl.pas -- UCL Compression Library for Borland Delphi

  This file is part of the DIUcl package.

  Copyright (c) 2003 Ralf Junker - The Delphi Inspiration
  All Rights Reserved.

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

  Ralf Junker - The Delphi Inspiration
  <delphi@zeitungsjunge.de>
  http://www.zeitungsjunge.de/delphi/

  UCL is Copyright (c) 1996-2002 Markus Franz Xaver Johannes Oberhumer
  All Rights Reserved.

  Markus F.X.J. Oberhumer
  <markus@oberhumer.com>
  http://www.oberhumer.com/opensource/ucl/

------------------------------------------------------------------------------ }

{ @abstract(UCL Compression Library routines.) }
unit Ucl.Export;

interface

uses
  Ucl.Core;

type
  TUclProgressCallback = procedure(TextSize: Longword; CodeSize: Longword; State: Integer;
    UserData: Pointer); cdecl;

function UclInit(Ver: Integer): Integer;
function UclInitEx(Ver, SizeOfShort, SizeOfInt, SizeOfUInt, SizeOfPChar, SizeOfPointer: Integer): Integer;

function UclCompressBuf(const Buf: Pointer; Size: Longword; out Compressed: Pointer;
  Method: Integer; CompressionLevel: Integer): Longword;

function UclCompressBuf2(const Buf: Pointer; Size: Longword; Compressed: Pointer;
  Method: Integer; CompressionLevel: Integer): Longword;

function UclDecompressBuf(const Buf: Pointer; Size: Longword; out Decompressed: Pointer;
  Method: Integer; DecompressedSize: Longword): Longword;

function UclDecompressBuf2(const Buf: Pointer; Size: Longword; Decompressed: Pointer;
  Method: Integer; DecompressedSize: Longword): Longword;

function UclCompressStr(const Str: string; Method: Integer; CompressionLevel: Integer;
  Flags: Longword): string;

function UclDecompressStr(const Str: string): string;

function UclCompressBufEx(const Buf: Pointer; Size: Longword; out Compressed: Pointer;
  Method: Integer; CompressionLevel: Integer; Callback: TUclProgressCallback;
  UserData: Pointer): Longword;

function UclCompressBufEx2(const Buf: Pointer; Size: Longword; Compressed: Pointer;
  Method: Integer; CompressionLevel: Integer; Callback: TUclProgressCallback;
  UserData: Pointer): Longword;

function UclCompressStrEx(const Str: string; Method: Integer; CompressionLevel: Integer;
  Flags: Longword; Callback: TUclProgressCallback; UserData: Pointer): string;

function UclGetCompressionBufferOverhead(Size: Longword): Longword;

function UclGetLastError: Integer;
procedure UclSetLastError(ErrorCode: Integer);

function UclFormatUclError(ErrorCode: Integer): PChar;

function UclGetVersion: Integer;
function UclGetVersionString: PChar;
function UclGetBuildDate: PChar;

implementation

threadvar
  LastUclError: Integer;

const
  UCL_E_OK_MSG: PChar = 'The opeartion has completed successfully.';
  UCL_E_ERROR_MSG: PChar = 'Undefined internal error occured (data corruption present).';
  UCL_E_OUT_OF_MEMORY_MSG: PChar = 'Could not allocate work memory;';
  UCL_E_INVALID_ARGUMENT_MSG: PChar = 'One or more arguments supplied are invalid.';
  UCL_E_NOT_COMPRESSIBLE_MSG: PChar = 'The target buffer is not compressible.';
  UCL_E_DECOMPRESSION_ERROR_MSG: PChar = 'Buffer overrun occured during decompression.';

function UclGetCompressionBufferOverhead(Size: Longword): Longword;
begin
  Result := (Size div 8) + 256;
end;

function UclGetLastError: Integer;
begin
  Result := LastUclError;
end;

procedure UclSetLastError(ErrorCode: Integer);
begin
  LastUclError := ErrorCode;
end;

function UclFormatUclError(ErrorCode: Integer): PChar;
begin
  case ErrorCode of
    UCL_E_OK: Result := UCL_E_OK_MSG;
    UCL_E_INVALID_ARGUMENT: Result := UCL_E_INVALID_ARGUMENT_MSG;
    UCL_E_NOT_COMPRESSIBLE: Result := UCL_E_NOT_COMPRESSIBLE_MSG;
    UCL_E_OUT_OF_MEMORY: Result := UCL_E_OUT_OF_MEMORY_MSG;
    UCL_E_INPUT_OVERRUN, UCL_E_OUTPUT_OVERRUN,
    UCL_E_LOOKBEHIND_OVERRUN, UCL_E_EOF_NOT_FOUND,
    UCL_E_INPUT_NOT_CONSUMED, UCL_E_OVERLAP_OVERRUN: Result := UCL_E_DECOMPRESSION_ERROR_MSG;
  else
    Result := UCL_E_ERROR_MSG;
  end;
end;

function UclGetVersion: Integer;
begin
  Result := ucl_version;
end;

function UclGetVersionString: PChar;
begin
  Result := ucl_version_string;
end;

function UclGetBuildDate: PChar;
begin
  Result := ucl_version_date;
end;

function UclCompressBuf(const Buf: Pointer; Size: Longword; out Compressed: Pointer;
  Method: Integer; CompressionLevel: Integer): Longword;
label
  __Fail;
var
  MaxBlock: Longword;
  Error: Integer;
begin
  if (Buf = nil) or (Size = 0) then
  begin
    LastUclError := UCL_E_INVALID_ARGUMENT;
    goto __Fail;
  end;

  MaxBlock := ucl_output_block_size(Size);
  GetMem(Compressed, MaxBlock);

  case Method of
    UCL_METHOD_2B:
    begin
      Error := ucl_nrv2b_99_compress(Buf, Size, Compressed, Longword(MaxBlock),
        nil, CompressionLevel, nil, nil);
    end;
    UCL_METHOD_2D:
    begin
      Error := ucl_nrv2d_99_compress(Buf, Size, Compressed, Longword(MaxBlock),
        nil, CompressionLevel, nil, nil);
    end;
    UCL_METHOD_2E:
    begin
      Error := ucl_nrv2e_99_compress(Buf, Size, Compressed, Longword(MaxBlock),
        nil, CompressionLevel, nil, nil);
    end;
  else
    Error := UCL_E_INVALID_ARGUMENT;
  end;

  LastUclError := Error;
  if Error < UCL_E_OK then
  begin
    FreeMem(Compressed);
    Compressed := nil;
    goto __Fail;
  end;

  if MaxBlock < Size then
  begin
    ReallocMem(Compressed, MaxBlock);
    Result := MaxBlock;
  end else
  begin
    ReallocMem(Compressed, Size);
    Move(Buf^, Compressed^, Size);
    Result := Size;
  end;

  Exit;

  __Fail:
  Result := 0;
end;

function UclCompressBuf2(const Buf: Pointer; Size: Longword; Compressed: Pointer;
  Method: Integer; CompressionLevel: Integer): Longword;
label
  __Fail;
var
  MaxBlock: Longword;
  Error: Integer;
begin
  if (Buf = nil) or (Size = 0) or (Compressed = nil) then
  begin
    LastUclError := UCL_E_INVALID_ARGUMENT;
    goto __Fail;
  end;

  MaxBlock := ucl_output_block_size(Size);

  case Method of
    UCL_METHOD_2B:
    begin
      Error := ucl_nrv2b_99_compress(Buf, Size, Compressed, Longword(MaxBlock),
        nil, CompressionLevel, nil, nil);
    end;
    UCL_METHOD_2D:
    begin
      Error := ucl_nrv2d_99_compress(Buf, Size, Compressed, Longword(MaxBlock),
        nil, CompressionLevel, nil, nil);
    end;
    UCL_METHOD_2E:
    begin
      Error := ucl_nrv2e_99_compress(Buf, Size, Compressed, Longword(MaxBlock),
        nil, CompressionLevel, nil, nil);
    end;
  else
    Error := UCL_E_INVALID_ARGUMENT;
  end;

  LastUclError := Error;
  if Error < UCL_E_OK then goto __Fail;

  if MaxBlock < Size then
  begin
    Result := MaxBlock;
  end else
  begin
    Move(Buf^, Compressed^, Size);
    Result := Size;
  end;

  Exit;

  __Fail:
  Result := 0;
end;

function UclDecompressBuf(const Buf: Pointer; Size: Longword; out Decompressed: Pointer;
  Method: Integer; DecompressedSize: Longword): Longword;
label
  __Fail;
var
  Error: Integer;
begin
  if (Buf = nil) or (Size = 0) then
  begin
    LastUclError := UCL_E_INVALID_ARGUMENT;
    goto __Fail;
  end;

  GetMem(Decompressed, DecompressedSize);

  if (DecompressedSize mod 4) = 0 then
  begin
    case Method of
      UCL_METHOD_2B:
      begin
        Error := ucl_nrv2b_decompress_asm_fast_8(Buf, Size, Decompressed,
          DecompressedSize, nil);
      end;
      UCL_METHOD_2D:
      begin
        Error := ucl_nrv2d_decompress_asm_fast_8(Buf, Size, Decompressed,
          DecompressedSize, nil);
      end;
      UCL_METHOD_2E:
      begin
        Error := ucl_nrv2e_decompress_asm_fast_8(Buf, Size, Decompressed,
          DecompressedSize, nil);
      end;
    else
      Error := UCL_E_INVALID_ARGUMENT;
    end;
  end else
  begin
    case Method of
      UCL_METHOD_2B:
      begin
        Error := ucl_nrv2b_decompress_asm_safe_8(Buf, Size, Decompressed,
          DecompressedSize, nil);
      end;
      UCL_METHOD_2D:
      begin
        Error := ucl_nrv2d_decompress_asm_safe_8(Buf, Size, Decompressed,
          DecompressedSize, nil);
      end;
      UCL_METHOD_2E:
      begin
        Error := ucl_nrv2e_decompress_asm_safe_8(Buf, Size, Decompressed,
          DecompressedSize, nil);
      end;
    else
      Error := UCL_E_INVALID_ARGUMENT;
    end;
  end;

  LastUclError := Error;
  if Error < UCL_E_OK then
  begin
    FreeMem(Decompressed);
    Decompressed := nil;
    goto __Fail;
  end else
  begin
    Result := DecompressedSize;
  end;

  Exit;

  __Fail:
  Result := 0;
end;

function UclDecompressBuf2(const Buf: Pointer; Size: Longword; Decompressed: Pointer;
  Method: Integer; DecompressedSize: Longword): Longword;
label
  __Fail;
var
  Error: Integer;
begin
  if (Buf = nil) or (Size = 0) or (Decompressed = nil) then
  begin
    LastUclError := UCL_E_INVALID_ARGUMENT;
    goto __Fail;
  end;

  if (DecompressedSize mod 4) = 0 then
  begin
    case Method of
      UCL_METHOD_2B:
      begin
        Error := ucl_nrv2b_decompress_asm_fast_8(Buf, Size, Decompressed,
          DecompressedSize, nil);
      end;
      UCL_METHOD_2D:
      begin
        Error := ucl_nrv2d_decompress_asm_fast_8(Buf, Size, Decompressed,
          DecompressedSize, nil);
      end;
      UCL_METHOD_2E:
      begin
        Error := ucl_nrv2e_decompress_asm_fast_8(Buf, Size, Decompressed,
          DecompressedSize, nil);
      end;
    else
      Error := UCL_E_INVALID_ARGUMENT;
    end;
  end else
  begin
    case Method of
      UCL_METHOD_2B:
      begin
        Error := ucl_nrv2b_decompress_asm_safe_8(Buf, Size, Decompressed,
          DecompressedSize, nil);
      end;
      UCL_METHOD_2D:
      begin
        Error := ucl_nrv2d_decompress_asm_safe_8(Buf, Size, Decompressed,
          DecompressedSize, nil);
      end;
      UCL_METHOD_2E:
      begin
        Error := ucl_nrv2e_decompress_asm_safe_8(Buf, Size, Decompressed,
          DecompressedSize, nil);
      end;
    else
      Error := UCL_E_INVALID_ARGUMENT;
    end;
  end;

  LastUclError := Error;
  if Error < UCL_E_OK then
  begin
    goto __Fail;
  end else
  begin
    Result := DecompressedSize;
  end;

  Exit;

  __Fail:
  Result := 0;
end;

function UclCompressStr(const Str: string; Method: Integer; CompressionLevel: Integer;
  Flags: Longword): string;
label
  __Fail;
var
  Len: Integer;
  MaxBlock: Integer;
  Error: Integer;
  Checksum: Longword;
begin
  if Pointer(Str) = nil then
  begin
    LastUclError := UCL_E_INVALID_ARGUMENT;
    goto __Fail;
  end;

  Len := Length(Str);
  if Len <> 0 then
  begin
    MaxBlock := ucl_output_block_size(Len);

    if (Flags and UCL_FLAG_ADLER_CHECKSUM) <> 0 then
    begin
      Checksum := ucl_adler32(0, Pointer(Str), Len);
    end else Checksum := 0;

    SetString(Result, nil, MaxBlock + 16);

    case Method of
      UCL_METHOD_2B:
      begin
        Error := ucl_nrv2b_99_compress(Pointer(Str), Len, Pointer(Longword(Result) + 16),
          Longword(MaxBlock), nil, CompressionLevel, nil, nil);
      end;
      UCL_METHOD_2D:
      begin
        Error := ucl_nrv2d_99_compress(Pointer(Str), Len, Pointer(Longword(Result) + 16),
          Longword(MaxBlock), nil, CompressionLevel, nil, nil);
      end;
      UCL_METHOD_2E:
      begin
        Error := ucl_nrv2e_99_compress(Pointer(Str), Len, Pointer(Longword(Result) + 16),
          Longword(MaxBlock), nil, CompressionLevel, nil, nil);
      end;
    else
      Error := UCL_E_INVALID_ARGUMENT;
    end;
  
    LastUclError := Error;
    if Error < UCL_E_OK then
    begin
      goto __Fail;
    end;
  
    if MaxBlock < Len then
    begin
      PLongword(Result)^ := Len;
      PLongword(Longword(Result) + 4)^ := Flags;
      PLongword(Longword(Result) + 8)^ := Checksum;
      PLongword(Integer(Result) + 4)^ := Method;
      SetLength(Result, MaxBlock + 16);
    end else
    begin
      PInt64(Result)^ := 0;
      PInt64(Longword(Result) + 8)^ := 0;
      Move(Pointer(Str)^, Pointer(Longword(Result) + 16)^, Len);
      SetLength(Result, Len + 16);
    end;
  end else
  begin
    LastUclError := UCL_E_INVALID_ARGUMENT;
    goto __Fail;
  end;

  Exit;

  __Fail:
  Result := '';
end;

{ ---------------------------------------------------------------------------- }

function UclDecompressStr(const Str: string): string;
label
  __Fail;
var
  Len: Integer;
  PrevLen: Integer;
  Method: Integer;
  Flags: Longword;
  Checksum: Longword;
  Error: Integer;
begin
  if Pointer(Str) = nil then
  begin
    LastUclError := UCL_E_INVALID_ARGUMENT;
    goto __Fail;
  end;

  Len := Length(Str);

  if Len < 16 then
  begin
    LastUclError := UCL_E_INVALID_ARGUMENT;
    goto __Fail;
  end;

  PrevLen := PInteger(Str)^;
  Method := PInteger(Longword(Str) + 4)^;
  Flags := PLongword(Longword(Str) + 8)^;
  Checksum := PLongword(Longword(Str) + 12)^;

  if PrevLen <> 0 then
  begin
    SetString(Result, nil, PrevLen);

    case Method of
      UCL_METHOD_2B:
      begin
        Error := ucl_nrv2b_decompress_asm_8(Pointer(Cardinal(Str) + 16), Len - 16,
          Pointer(Result), Longword(PrevLen), nil);
      end;
      UCL_METHOD_2D:
      begin
        Error := ucl_nrv2d_decompress_asm_8(Pointer(Cardinal(Str) + 16), Len - 16,
          Pointer(Result), Longword(PrevLen), nil);
      end;
      UCL_METHOD_2E:
      begin
        Error := ucl_nrv2e_decompress_asm_8(Pointer(Cardinal(Str) + 16), Len - 16,
          Pointer(Result), Longword(PrevLen), nil);
      end;
    else
      Error := UCL_E_INVALID_ARGUMENT;
    end;

    if (Flags and UCL_FLAG_ADLER_CHECKSUM) <> 0 then
    begin
      if Checksum <> ucl_adler32(0, Pointer(Result), PrevLen) then
      begin
        Error := UCL_E_ERROR;
      end;
    end;

    LastUclError := Error;
    if Error < UCL_E_OK then
    begin
      goto __Fail;
    end;
  end else
  begin
    Dec(Len, 16);
    SetString(Result, nil, Len);
    Move(Pointer(Longword(Str) + 16)^, Pointer(Result)^, Len);
  end;

  Exit;

  __Fail:
  Result := '';
end;

function UclCompressBufEx(const Buf: Pointer; Size: Longword; out Compressed: Pointer;
  Method: Integer; CompressionLevel: Integer; Callback: TUclProgressCallback;
  UserData: Pointer): Longword;
label
  __Fail;
var
  MaxBlock: Longword;
  Error: Integer;
  CallbackRec: ucl_progress_callback_t;
begin
  if (Buf = nil) or (Size = 0) then
  begin
    LastUclError := UCL_E_INVALID_ARGUMENT;
    goto __Fail;
  end;

  MaxBlock := ucl_output_block_size(Size);
  GetMem(Compressed, MaxBlock);

  CallbackRec.Callback := Callback;
  CallbackRec.User := UserData;

  case Method of
    UCL_METHOD_2B:
    begin
      Error := ucl_nrv2b_99_compress(Buf, Size, Compressed, MaxBlock,
        @CallbackRec, CompressionLevel, nil, nil);
    end;
    UCL_METHOD_2D:
    begin
      Error := ucl_nrv2d_99_compress(Buf, Size, Compressed, MaxBlock,
        @CallbackRec, CompressionLevel, nil, nil);
    end;
    UCL_METHOD_2E:
    begin
      Error := ucl_nrv2e_99_compress(Buf, Size, Compressed, MaxBlock,
        @CallbackRec, CompressionLevel, nil, nil);
    end;
  else
    Error := UCL_E_INVALID_ARGUMENT;
  end;

  LastUclError := Error;
  if Error < UCL_E_OK then
  begin
    FreeMem(Compressed);
    Compressed := nil;
    goto __Fail;
  end;

  if MaxBlock < Size then
  begin
    ReallocMem(Compressed, MaxBlock);
    Result := MaxBlock;
  end else
  begin
    ReallocMem(Compressed, Size);
    Move(Buf^, Compressed^, Size);
    Result := Size;
  end;

  Exit;

  __Fail:
  Result := 0;
end;

function UclCompressBufEx2(const Buf: Pointer; Size: Longword; Compressed: Pointer;
  Method: Integer; CompressionLevel: Integer; Callback: TUclProgressCallback;
  UserData: Pointer): Longword;
label
  __Fail;
var
  MaxBlock: Longword;
  Error: Integer;
  CallbackRec: ucl_progress_callback_t;
begin
  if (Buf = nil) or (Size = 0) then
  begin
    LastUclError := UCL_E_INVALID_ARGUMENT;
    goto __Fail;
  end;

  MaxBlock := ucl_output_block_size(Size);

  CallbackRec.Callback := Callback;
  CallbackRec.User := UserData;

  case Method of
    UCL_METHOD_2B:
    begin
      Error := ucl_nrv2b_99_compress(Buf, Size, Compressed, MaxBlock,
        @CallbackRec, CompressionLevel, nil, nil);
    end;
    UCL_METHOD_2D:
    begin
      Error := ucl_nrv2d_99_compress(Buf, Size, Compressed, MaxBlock,
        @CallbackRec, CompressionLevel, nil, nil);
    end;
    UCL_METHOD_2E:
    begin
      Error := ucl_nrv2e_99_compress(Buf, Size, Compressed, MaxBlock,
        @CallbackRec, CompressionLevel, nil, nil);
    end;
  else
    Error := UCL_E_INVALID_ARGUMENT;
  end;

  LastUclError := Error;
  if Error < UCL_E_OK then goto __Fail;

  if MaxBlock < Size then
  begin
    Result := MaxBlock;
  end else
  begin
    Move(Buf^, Compressed^, Size);
    Result := Size;
  end;

  Exit;

  __Fail:
  Result := 0;
end;

function UclCompressStrEx(const Str: string; Method: Integer; CompressionLevel: Integer;
  Flags: Longword; Callback: TUclProgressCallback; UserData: Pointer): string;
label
  __Fail;
var
  Len: Integer;
  MaxBlock: Integer;
  Error: Integer;
  Checksum: Longword;
  CallbackRec: ucl_progress_callback_t;
begin
  if Pointer(Str) = nil then
  begin
    LastUclError := UCL_E_INVALID_ARGUMENT;
    goto __Fail;
  end;

  Len := Length(Str);
  if Len <> 0 then
  begin
    MaxBlock := ucl_output_block_size(Len);

    if (Flags and UCL_FLAG_ADLER_CHECKSUM) <> 0 then
    begin
      Checksum := ucl_adler32(0, Pointer(Str), Len);
    end else Checksum := 0;

    SetString(Result, nil, MaxBlock + 16);
  
    CallbackRec.Callback := Callback;
    CallbackRec.User := UserData;
  
    Error := ucl_nrv2e_99_compress(Pointer(Str), Len, Pointer(Longword(Result) + 16),
      Longword(MaxBlock), @CallbackRec, CompressionLevel, nil, nil);
    LastUclError := Error;
    if Error < UCL_E_OK then
    begin
      goto __Fail;
    end;
  
    if MaxBlock < Len then
    begin
      PLongword(Result)^ := Len;
      PLongword(Longword(Result) + 4)^ := Flags;
      PLongword(Longword(Result) + 8)^ := Checksum;
      PLongword(Integer(Result) + 4)^ := Method;
      SetLength(Result, MaxBlock + 16);
    end else
    begin
      PInt64(Result)^ := 0;
      PInt64(Longword(Result) + 8)^ := 0;
      Move(Pointer(Str)^, Pointer(Longword(Result) + 16)^, Len);
      SetLength(Result, Len + 16);
    end;
  end else
  begin
    LastUclError := UCL_E_INVALID_ARGUMENT;
    goto __Fail;
  end;

  Exit;

  __Fail:
  Result := '';
end;

function UclInit(Ver: Integer): Integer;
begin
  Result := UclInitEx(Ver, SizeOf(SmallInt), SizeOf(Integer), SizeOf(Longword),
    SizeOf(PChar), SizeOf(Pointer));
end;

function UclInitEx(Ver, SizeOfShort, SizeOfInt, SizeOfUInt, SizeOfPChar, SizeOfPointer: Integer): Integer;
begin
  Result := __ucl_init2(Ver, SizeOfShort, SizeOfInt, SizeOfInt, SizeOfUInt,
    SizeOfUInt, -1, SizeOfPChar, SizeOfPointer, 4);
end;

end.

