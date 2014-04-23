{------------------------------------------------------------------------------
  Interface to UCL Library.
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
*------------------------------------------------------------------------------}

unit Ucl.LibInterface;

interface

type
  TUclProgressCallback = procedure(TextSize: Cardinal; CodeSize: Cardinal; State: Integer;
    UserData: Pointer); cdecl;

const
  UCL_VERSION_CONST = $010100;

  UCL_E_OK = 0;
  UCL_E_ERROR = -1;
  UCL_E_INVALID_ARGUMENT = -2;
  UCL_E_OUT_OF_MEMORY = -3;
  UCL_E_NOT_COMPRESSIBLE = -101;
  UCL_E_INPUT_OVERRUN = -201;
  UCL_E_OUTPUT_OVERRUN = -202;
  UCL_E_LOOKBEHIND_OVERRUN = -203;
  UCL_E_EOF_NOT_FOUND = -204;
  UCL_E_INPUT_NOT_CONSUMED = -205;
  UCL_E_OVERLAP_OVERRUN = -206;

  UCL_COMPRESSION_LEVEL_MIN = 1;
  UCL_COMPRESSION_LEVEL_MAX = 10;

  UCL_METHOD_2B = $2B;
  UCL_METHOD_2D = $2D;
  UCL_METHOD_2E = $2E;

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

function UclCompressStr(const Str: string; Method: Integer; CompressionLevel: Integer): string;

function UclDecompressStr(const Str: string): string;

function UclCompressBufEx(const Buf: Pointer; Size: Longword; out Compressed: Pointer;
  Method: Integer; CompressionLevel: Integer; Callback: TUclProgressCallback;
  UserData: Pointer): Longword;

function UclCompressBufEx2(const Buf: Pointer; Size: Longword; Compressed: Pointer;
  Method: Integer; CompressionLevel: Integer; Callback: TUclProgressCallback;
  UserData: Pointer): Longword;

function UclCompressStrEx(const Str: string; Method: Integer; CompressionLevel: Integer;
  Callback: TUclProgressCallback; UserData: Pointer): string;

function UclGetCompressionBufferOverhead(Size: Integer): Integer;

function UclGetLastError: Integer;
procedure UclSetLastError(ErrorCode: Integer);

function UclFormatUclError(ErrorCode: Integer): PChar;

function UclGetVersion: Integer;
function UclGetVersionString: PChar;
function UclGetBuildDate: PChar;

implementation

const
  UclLib = 'ucl32.dll';

function UclInit; external UclLib name 'UclInit';
function UclInitEx; external UclLib name 'UclInit';
function UclCompressBuf; external UclLib name 'UclCompressBuf';
function UclCompressBuf2; external UclLib name 'UclCompressBuf2';
function UclCompressBufEx; external UclLib name 'UclCompressBufEx';
function UclCompressBufEx2; external UclLib name 'UclCompressBufEx2';
function UclDecompressBuf; external UclLib name 'UclDecompressBuf';
function UclDecompressBuf2; external UclLib name 'UclDecompressBuf2';
function UclCompressStr; external UclLib name 'UclCompressStr';
function UclCompressStrEx; external UclLib name 'UclCompressStr';
function UclDecompressStr; external UclLib name 'UclDecompressStr';
function UclGetCompressionBufferOverhead; external UclLib name 'UclGetCompressionBufferOverhead';
function UclGetLastError; external UclLib name 'UclGetLastError';
procedure UclSetLastError; external UclLib name 'UclSetLastError';
function UclFormatUclError; external UclLib name 'UclFormatUclError';
function UclGetVersion; external UclLib name 'UclGetVersion';
function UclGetVersionString; external UclLib name 'UclGetVersionString';
function UclGetBuildDate; external UclLib name 'UclGetBuildDate';

end.
