{*****************************************************************************
*  ZLibEx.pas (zlib 1.2.3)                                                   *
*                                                                            *
*  copyright (c) 2002-2005 Roberto Della Pasqua (www.dellapasqua.com)        *
*  copyright (c) 2000-2002 base2 technologies (www.base2ti.com)              *
*  copyright (c) 1997 Borland International (www.borland.com)                *
*                                                                            *
*  revision history                                                          *
*    2006.04.21  updated with latest Borland C++ 2006 SP2                    *
*    2005.02.03  updated with latest zlib 1.2.2, thanks to Fabio Dell'Aria   *
*                (www.eurekalog.com) for provide me the compiled objects     *
*                zlib is compiled without crc32-compressBound                *
*    2003.12.18  updated with latest zlib 1.2.1 (see www.zlib.org)           *
*                obj's compiled with fastest speed optimizations (bcc 5.6.4) *
*                (hint:see basm newsgroup about a Move RTL fast replacement) *
*                Thanks to Cosmin Truta for the pascal zlib reference        *
*                                                                            *
*    2002.11.02  ZSendToBrowser: deflate algorithm for HTTP1.1 compression   *
*    2002.10.24  ZFastCompressString and ZFastDecompressString:300% faster   *
*    2002.10.15  recompiled zlib 1.1.4 c sources with speed optimizations    *
*                (and targeting 686+ cpu) and changes to accomodate Borland  *
*                standards  (C++ v5.6 compiler)                              *
*    2002.10.15  optimized move mem for not aligned structures  (strings,etc)*
*    2002.10.15  little changes to avoid system unique string calls          *
*                                                                            *
*    2002.03.15  updated to zlib version 1.1.4                               *
*    2001.11.27  enhanced TZDecompressionStream.Read to adjust source        *
*                  stream position upon end of compression data              *
*                fixed endless loop in TZDecompressionStream.Read when       *
*                  destination count was greater than uncompressed data      *
*    2001.10.26  renamed unit to integrate "nicely" with delphi 6            *
*    2000.11.24  added soFromEnd condition to TZDecompressionStream.Seek     *
*                added ZCompressStream and ZDecompressStream                 *
*    2000.06.13  optimized, fixed, rewrote, and enhanced the zlib.pas unit   *
*                  included on the delphi cd (zlib version 1.1.3)            *
*                                                                            *
*  acknowledgements                                                          *
*    erik turner    Z*Stream routines                                        *
*    david bennion  finding the nastly little endless loop quirk with the    *
*                     TZDecompressionStream.Read method                      *
*    burak kalayci  informing me about the zlib 1.1.4 update                 *
*****************************************************************************}

unit ZLib.LibInterface;

interface

uses
  SysUtils;

const
  ZLIB_VERSION = '1.2.3';

type
  TZAlloc = function(opaque: Pointer; items, size: Integer): Pointer;
  TZFree = procedure(opaque, block: Pointer);
  TZCompressionLevel = (zcNone, zcFastest, zcDefault, zcMax);

  {** TZStreamRec ***********************************************************}

  TZStreamRec = packed record
    next_in: PChar;        // next input byte
    avail_in: Longint;     // number of bytes available at next_in
    total_in: Longint;     // total nb of input bytes read so far
    next_out: PChar;       // next output byte should be put here
    avail_out: Longint;    // remaining free space at next_out
    total_out: Longint;    // total nb of bytes output so far
    msg: PChar;            // last error message, NULL if no error
    state: Pointer;        // not visible by applications
    zalloc: TZAlloc;       // used to allocate the internal state
    zfree: TZFree;         // used to free the internal state
    opaque: Pointer;       // private data object passed to zalloc and zfree
    data_type: Integer;    // best guess about the data type: ascii or binary
    adler: Longint;        // adler32 value of the uncompressed data
    reserved: Longint;     // reserved for future use
  end;

{** zlib public routines ****************************************************}

{*****************************************************************************
*  ZCompress                                                                 *
*                                                                            *
*  pre-conditions                                                            *
*    inBuffer  = pointer to uncompressed data                                *
*    inSize    = size of inBuffer (bytes)                                    *
*    outBuffer = pointer (unallocated)                                       *
*    level     = compression level                                           *
*                                                                            *
*  post-conditions                                                           *
*    outBuffer = pointer to compressed data (allocated)                      *
*    outSize   = size of outBuffer (bytes)                                   *
*****************************************************************************}

procedure ZCompress(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer;
  level: TZCompressionLevel = zcDefault);

{*****************************************************************************
*  ZDecompress                                                               *
*                                                                            *
*  pre-conditions                                                            *
*    inBuffer    = pointer to compressed data                                *
*    inSize      = size of inBuffer (bytes)                                  *
*    outBuffer   = pointer (unallocated)                                     *
*    outEstimate = estimated size of uncompressed data (bytes)               *
*                                                                            *
*  post-conditions                                                           *
*    outBuffer = pointer to decompressed data (allocated)                    *
*    outSize   = size of outBuffer (bytes)                                   *
*****************************************************************************}

procedure ZDecompress(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer; outEstimate: Integer = 0);

{** string routines *********************************************************}

function ZCompressStr(const s: string; level: TZCompressionLevel = zcDefault): string;
function ZDecompressStr(const s: string): string;

procedure ZCompressStrInPlace(var s: string; level: TZCompressionLevel = zcDefault);
procedure ZDecompressStrInPlace(var s: string);

{** export routines ********************************************************}

function adler32(adler: LongInt; const buf: PChar; len: Integer): LongInt;
function deflateInit_(var strm: TZStreamRec; level: Integer; version: PChar; recsize: Integer): Integer;
function deflateInit2_(var strm: TZStreamRec; level: integer; method: integer; windowBits: integer; memLevel: integer; strategy: integer; version: PChar; recsize: integer): integer;
function deflate(var strm: TZStreamRec; flush: Integer): Integer;
function deflateEnd(var strm: TZStreamRec): Integer;
function inflateInit_(var strm: TZStreamRec; version: PChar; recsize: Integer): Integer;
function inflateInit2_(var strm: TZStreamRec; windowBits: integer;  version: PChar; recsize: integer): integer;
function inflate(var strm: TZStreamRec; flush: Integer): Integer;
function inflateEnd(var strm: TZStreamRec): Integer;
function inflateReset(var strm: TZStreamRec): Integer;

function GetLastZLibErr: Integer;
function GetLastZLibErrMsg: string;

implementation

threadvar
  zlasterr: Integer;
  zlasterrmsg: string;

function GetLastZLibErr: Integer;
begin
  Result := zlasterr;
end;

function GetLastZLibErrMsg: string;
begin
  Result := zlasterrmsg;
end;

{** link zlib 1.2.3 **************************************************************}
{** bcc32 -c -6 -O2 -Ve -X -pr -a8 -b -d -k- -vi -tWM -r -RT- -ff *.c **}

{$L adler32.obj}
{$L deflate.obj}
{$L infback.obj}
{$L inffast.obj}
{$L inflate.obj}
{$L inftrees.obj}
{$L trees.obj}
{$L compress.obj}
{$L crc32.obj}

{*****************************************************************************
*  note: do not reorder the above -- doing so will result in external        *
*  functions being undefined                                                 *
*****************************************************************************}

const
  {** flush constants *******************************************************}

  Z_NO_FLUSH = 0;
  Z_PARTIAL_FLUSH = 1;
  Z_SYNC_FLUSH = 2;
  Z_FULL_FLUSH = 3;
  Z_FINISH = 4;

  {** return codes **********************************************************}

  Z_OK = 0;
  Z_STREAM_END = 1;
  Z_NEED_DICT = 2;
  Z_ERRNO = (-1);
  Z_STREAM_ERROR = (-2);
  Z_DATA_ERROR = (-3);
  Z_MEM_ERROR = (-4);
  Z_BUF_ERROR = (-5);
  Z_VERSION_ERROR = (-6);

  {** compression levels ****************************************************}

  Z_NO_COMPRESSION = 0;
  Z_BEST_SPEED = 1;
  Z_BEST_COMPRESSION = 9;
  Z_DEFAULT_COMPRESSION = (-1);

  {** compression strategies ************************************************}

  Z_FILTERED = 1;
  Z_HUFFMAN_ONLY = 2;
  Z_DEFAULT_STRATEGY = 0;

  {** data types ************************************************************}

  Z_BINARY = 0;
  Z_ASCII = 1;
  Z_UNKNOWN = 2;

  {** compression methods ***************************************************}

  Z_DEFLATED = 8;

  {** return code messages **************************************************}

  _z_errmsg: array[0..9] of PChar = (
    'A dictionary is missing.',                                               // Z_NEED_DICT      (2)
    'Tried to perform an operation after reaching stream''s end.',            // Z_STREAM_END     (1)
    'Operation has been completed successfully.',                             // Z_OK             (0)
    'Undefined file error occured.',                                          // Z_ERRNO          (-1)
    'Undefined stream error occured.',                                        // Z_STREAM_ERROR   (-2)
    'Processed buffer has been detected to be corrupted.',                    // Z_DATA_ERROR     (-3)
    'There was insufficient amount of memory to process the request.',        // Z_MEM_ERROR      (-4)
    'Internal buffer error occured.',                                         // Z_BUF_ERROR      (-5)
    'The file has been compressed with an incompatible version of ZLib.',     // Z_VERSION_ERROR  (-6)
    'Undefined error occured.'
  );

  ZLevels: array[TZCompressionLevel] of Shortint = (
    Z_NO_COMPRESSION,
    Z_BEST_SPEED,
    Z_DEFAULT_COMPRESSION,
    Z_BEST_COMPRESSION
  );

{****************************************************************************}

{** deflate routines ********************************************************}

function deflateInit_(var strm: TZStreamRec; level: Integer; version: PChar;
  recsize: Integer): Integer; external;

function DeflateInit2_(var strm: TZStreamRec; level: integer; method: integer; windowBits: integer;
  memLevel: integer; strategy: integer; version: PChar; recsize: integer): integer; external;

function deflate(var strm: TZStreamRec; flush: Integer): Integer;
  external;

function deflateEnd(var strm: TZStreamRec): Integer; external;

{** inflate routines ********************************************************}

function inflateInit_(var strm: TZStreamRec; version: PChar;
  recsize: Integer): Integer; external;

function inflateInit2_(var strm: TZStreamRec; windowBits: integer;
  version: PChar; recsize: integer): integer; external;

function inflate(var strm: TZStreamRec; flush: Integer): Integer;
  external;

function inflateEnd(var strm: TZStreamRec): Integer; external;

function inflateReset(var strm: TZStreamRec): Integer; external;

{** utility routines  *******************************************************}

function adler32; external;
//function crc32; external;
//function compressBound; external;

{** zlib function implementations *******************************************}

function zcalloc(opaque: Pointer; items, size: Integer): Pointer;
begin
  GetMem(Result, items * size);
end;

procedure zcfree(opaque, block: Pointer);
begin
  FreeMem(block);
end;

{** c function implementations **********************************************}

procedure _memset(p: Pointer; b: Byte; count: Integer); cdecl;
begin
  FillChar(p^, count, b);
end;

procedure _memcpy(dest, source: Pointer; count: Integer); cdecl;
begin
  Move(source^, dest^, count);
end;

function _malloc(Size: Integer): Pointer; cdecl;
begin
  GetMem(Result, Size);
end;

procedure _free(Block: Pointer); cdecl;
begin
  FreeMem(Block);
end;

{** custom zlib routines ****************************************************}

function DeflateInit(var stream: TZStreamRec; level: Integer): Integer;
begin
  Result := DeflateInit_(stream, level, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function DeflateInit2(var stream: TZStreamRec; level, method, windowBits,
  memLevel, strategy: Integer): Integer;
begin
  Result := DeflateInit2_(stream, level, method, windowBits, memLevel, strategy, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function InflateInit(var stream: TZStreamRec): Integer;
begin
  Result := InflateInit_(stream, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function InflateInit2(var stream: TZStreamRec; windowBits: Integer): Integer;
begin
  Result := InflateInit2_(stream, windowBits, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

{****************************************************************************}

function ZCompressCheck(code: Integer): Integer;
begin
  Result := code;

  if code < 0 then
  begin
    zlasterr := Result;
    zlasterrmsg := _z_errmsg[2 - code];
  end;
end;

function ZDecompressCheck(code: Integer): Integer;
begin
  Result := code;

  if code < 0 then
  begin
    zlasterr := Result;
    zlasterrmsg := _z_errmsg[2 - code];
  end;
end;

procedure ZCompress(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer;
  level: TZCompressionLevel);
const
  delta = 256;
var
  zstream: TZStreamRec;
begin
  FillChar(zstream, SizeOf(TZStreamRec), 0);

  outSize := ((inSize + (inSize div 10) + 12) + 255) and not 255;
  GetMem(outBuffer, outSize);

  try
    zstream.next_in := inBuffer;
    zstream.avail_in := inSize;
    zstream.next_out := outBuffer;
    zstream.avail_out := outSize;

    ZCompressCheck(DeflateInit(zstream, ZLevels[level]));

    try
      while ZCompressCheck(deflate(zstream, Z_FINISH)) <> Z_STREAM_END do
      begin
        Inc(outSize, delta);
        ReallocMem(outBuffer, outSize);

        zstream.next_out := PChar(Integer(outBuffer) + zstream.total_out);
        zstream.avail_out := delta;
      end;
    finally
      ZCompressCheck(deflateEnd(zstream));
    end;

    ReallocMem(outBuffer, zstream.total_out);
    outSize := zstream.total_out;
  except
    FreeMem(outBuffer);
    raise;
  end;
end;

procedure ZDecompress(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer; outEstimate: Integer);
var
  zstream: TZStreamRec;
  delta: Integer;
begin
  FillChar(zstream, SizeOf(TZStreamRec), 0);

  delta := (inSize + 255) and not 255;

  if outEstimate = 0 then outSize := delta
  else outSize := outEstimate;

  GetMem(outBuffer, outSize);

  try
    zstream.next_in := inBuffer;
    zstream.avail_in := inSize;
    zstream.next_out := outBuffer;
    zstream.avail_out := outSize;

    ZDecompressCheck(InflateInit(zstream));

    try
      while ZDecompressCheck(inflate(zstream, Z_NO_FLUSH)) <> Z_STREAM_END do
      begin
        Inc(outSize, delta);
        ReallocMem(outBuffer, outSize);

        zstream.next_out := PChar(Integer(outBuffer) + zstream.total_out);
        zstream.avail_out := delta;
      end;
    finally
      ZDecompressCheck(inflateEnd(zstream));
    end;

    ReallocMem(outBuffer, zstream.total_out);
    outSize := zstream.total_out;
  except
    FreeMem(outBuffer);
    raise;
  end;
end;

{** string routines *********************************************************}

function ZCompressStr(const s: string; level: TZCompressionLevel): string;
var
  buffer: Pointer;
  size: Integer;
begin
  ZCompress(PChar(s), Length(s), buffer, size, level);
  SetLength(Result, size);
  Move(buffer^, pointer(Result)^, size);
  FreeMem(buffer);
end;

procedure ZCompressStrInPlace(var s: string; level: TZCompressionLevel);
var
  buffer: Pointer;
  size: Integer;
begin
  ZCompress(PChar(s), Length(s), buffer, size, level);
  SetLength(s, size);
  Move(buffer^, pointer(s)^, size);
  FreeMem(buffer);
end;

function ZDecompressStr(const s: string): string;
var
  buffer: Pointer;
  size: Integer;
begin
  ZDecompress(PChar(s), Length(s), buffer, size);
  SetLength(Result, size);
  Move(buffer^, pointer(Result)^, size);
  FreeMem(buffer);
end;

procedure ZDecompressStrInPlace(var s: string);
var
  buffer: Pointer;
  size: Integer;
begin
  ZDecompress(PChar(s), Length(s), buffer, size);
  SetLength(s, size);
  Move(buffer^, pointer(s)^, size);
  FreeMem(buffer);
end;

end.

