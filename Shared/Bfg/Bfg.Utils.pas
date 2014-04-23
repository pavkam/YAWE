{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Collection of miscleanous routines and types for usage in the whole project.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------} 

{$I compiler.inc}
{$WARN UNIT_PLATFORM OFF}
{$WARN SYMBOL_PLATFORM OFF}
unit Bfg.Utils;

interface

uses
  API.Win.Kernel,
  API.Win.NTCommon,
  API.Win.Types,
  SysUtils{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

type
  Quadword = Int64;

  { Array types }
  TIntegerDynArray      = array of Integer;
  TCardinalDynArray     = array of Cardinal;
  TLongWordDynArray     = array of LongWord;
  TWordDynArray         = array of Word;
  TSmallIntDynArray     = array of SmallInt;
  TByteDynArray         = array of Byte;
  TShortIntDynArray     = array of ShortInt;
  TInt64DynArray        = array of Int64;
  TQuadwordDynArray     = array of Quadword;
  TSingleDynArray       = array of Single;
  TDoubleDynArray       = array of Double;
  TExtendedDynArray     = array of Extended;
  TBooleanDynArray      = array of Boolean;
  TStringDynArray       = array of string;
  TWideStringDynArray   = array of WideString;
  TPointerDynArray      = array of Pointer; 
  TObjectDynArray       = array of TObject;
  TClassDynArray        = array of TClass;
  TIntfDynArray         = array of IInterface;
  TPCharDynArray        = array of PChar;
  TCharDynArray         = array of Char;
  TWideCharDynArray     = array of WideChar;

  TIntegerArray         = array[0..$1FFFFFFE] of Integer;
  TCardinalArray        = array[0..$1FFFFFFE] of Cardinal;
  TLongWordArray        = array[0..$1FFFFFFE] of LongWord;
  TWordArray            = array[0..$3FFFFFFC] of Word;
  TSmallIntArray        = array[0..$3FFFFFFC] of SmallInt;
  TByteArray            = array[0..$7FFFFFF8] of Byte;
  TShortIntArray        = array[0..$7FFFFFF8] of ShortInt;
  TInt64Array           = array[0..$0FFFFFFE] of Int64;
  TQuadWordArray        = array[0..$0FFFFFFE] of Quadword;
  TSingleArray          = array[0..$1FFFFFFE] of Single;
  TDoubleArray          = array[0..$0FFFFFFE] of Double;
  TExtendedArray        = array[0..$03333333] of Extended;
  TBooleanArray         = array[0..$7FFFFFF8] of Boolean;
  TStringArray          = array[0..$1FFFFFFE] of string;
  TWideStringArray      = array[0..$1FFFFFFE] of WideString;
  TPointerArray         = array[0..$1FFFFFFE] of Pointer;
  TObjectArray          = array[0..$1FFFFFFE] of TObject;
  TClassArray           = array[0..$1FFFFFFE] of TClass;
  TIntfArray            = array[0..$1FFFFFFE] of IInterface;
  TPCharArray           = array[0..$1FFFFFFE] of PChar;
  TPWideCharArray       = array[0..$1FFFFFFE] of PWideChar;
  TCharArray            = array[0..$7FFFFFF8] of Char;
  TWideCharArray        = array[0..$3FFFFFFC] of WideChar;

  PIntegerArray         = ^TIntegerArray;
  PCardinalArray        = ^TCardinalArray;
  PWordArray            = ^TWordArray;
  PSmallIntArray        = ^TSmallIntArray;
  PByteArray            = ^TByteArray;
  PShortIntArray        = ^TShortIntArray;
  PInt64Array           = ^TInt64Array;
  PQuadWordArray        = ^TQuadWordArray;
  PLongWordArray        = ^TLongWordArray;
  PSingleArray          = ^TSingleArray;
  PDoubleArray          = ^TDoubleArray;
  PExtendedArray        = ^TExtendedArray;
  PBooleanArray         = ^TBooleanArray;
  PStringArray          = ^TStringArray;
  PWideStringArray      = ^TWideStringArray;
  PPointerArray         = ^TPointerArray;
  PObjectArray          = ^TObjectArray;
  PClassArray           = ^TClassArray;
  PIntfArray            = ^TIntfArray;
  PPCharArray           = ^TPCharArray;
  PPWideCharArray       = ^TPWideCharArray;
  PCharArray            = ^TCharArray;
  PWideCharArray        = ^TWideCharArray;

  PCharVector = PPChar;

  PMethod = ^TMethod;

  EOutOfBounds = class(Exception);
  EInvalidArgument = class(Exception);
  ECallUnimplemented = class(Exception);

  TEnumerationCallback = procedure(Instance: TObject) of object;

  TReferencedObject = class(TObject, IInterface)
    protected
      function _AddRef: Integer; stdcall;
      function _Release: Integer; stdcall;
    public
      function QueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
  end;

const
  BITS_PER_BYTE = 8;
  BITS_PER_WORD = BITS_PER_BYTE * 2;
  BITS_PER_LONG = BITS_PER_BYTE * 4;
  BITS_PER_QUAD = BITS_PER_BYTE * 8;

  MAXQWORD   = $FFFFFFFFFFFFFFFF;
  MAXINT64   = $7FFFFFFFFFFFFFFF;
  MININT64   = Int64($8000000000000000);

  MAXDWORD   = $FFFFFFFF;
  MAXINT     = Integer($7FFFFFFF);
  MININT     = Integer($80000000);

  MAXWORD    = $FFFF;
  MAXSMALL   = Smallint($7FFF);
  MINSMALL   = Smallint($8000);

  MAXBYTE    = $FF;
  MAXSHORT   = Shortint($7F);
  MINSHORT   = Shortint($80);

type
  UInt64 = Int64;

  TLargeInteger = LARGE_INTEGER;
  PLargeInteger = PLARGE_INTEGER;

  TULargeInteger = _LARGE_INTEGER;
  PULargeInteger = ^TULargeInteger;

  TSignature = array[0..3] of Char;

  PRect = ^TRect;
  TRect = record
    MaxX: Single;
    MaxY: Single;
    MinX: Single;
    MinY: Single;
  end;

  PVersion = ^TVersion;
  TVersion = packed record
    case Boolean of
      False: (
        Major: Byte;
        Minor: Byte;
        Revision: Byte;
        Build: Byte;
      );
      True: (
        Full: Longword;
      );
  end;

function StackAlloc(Size: Integer): Pointer; register;
procedure StackFree(P: Pointer); register;

function MakeMethod(Code: Pointer; Data: Pointer): TMethod;

{ Type Convertion }
function TextBufToUInt(const Buf: PChar): Longword;
function WideTextBufToUInt(const Buf: PWideChar): Longword;
function StrToUInt(const sStr: string): Longword;
function TryStrToUInt(const sStr: string; var iValue: Longword): Boolean;
function TextBufToFloat(Buffer: PChar; var Value: Single): Boolean;
function TextBufToDouble(Buffer: PChar; var Value: Double): Boolean;
function TextBufToExtended(Buffer: PChar; var Value: Extended): Boolean;

function atoi8(const sString: string): Byte;
function atoi16(const sString: string): Word;
function atoi32(const sString: string): Longword;
function atoi64(const sString: string): Int64;
function atof(const sString: string): Single;

function itoa(iNumber: Int64): string; overload;
function itoa(iNumber: Longword): string; overload;
function itoa(iNumber: Word): string; overload;
function itoa(iNumber: Byte): string; overload;
function ftoa(fNumber: Single): string;

function itoh(iNumber: Byte): string; overload;
function itoh(iNumber: Word): string; overload;
function itoh(iNumber: Longword): string; overload;
function itoh(iNumber: Int64): string; overload;

function ftopki(fNumber: Single): Longword;
function pkitof(iNumber: Longword): Single;

function atoh(const sIn: string): string;
function htoa(const sIn: string): string;

function NilOrString(iInt: Longword): string; overload; inline;
function NilOrString(fFlt: Single): string; overload; inline;
function NilOrString(bBool: Boolean): string; overload; inline;

{ Hashing functions }
function HashLong(Value: Longword): Longword;
function HashLongModulo(Value: Longword; Max: Longword): Longword;
function HashLongMasked(Value: Longword; Mask: Longword): Longword;

function HashData(Data: Pointer; Size: Integer): Longword;
function HashDataModulo(Data: Pointer; Size: Integer; Max: Longword): Longword;
function HashDataMasked(Data: Pointer; Size: Integer; Mask: Longword): Longword;

function HashDataNoCase(Data: Pointer; Size: Integer): Longword;
function HashDataNoCaseRange(Data: Pointer; Size: Integer; Limit: Longword): Longword;

function HashString(const Str: string; Limit: Longword): Longword;
function HashStringNoCase(const Str: string; Limit: Longword): Longword;

{ String-related routines }
function ArrayToString(const aArr: array of Longword): string; overload;
function ArrayToString(const aArr: array of Single): string; overload;
function ArrayToString(const aArr: array of string): string; overload;

function BuildFileList(Path: string; Attr: Integer;
  var List: TStringDynArray; const Masks: array of string): Boolean;

procedure StringToDynArray(const sData: string; var aArr: TLongWordDynArray); overload;
procedure StringToDynArray(const sData: string; var aArr: TSingleDynArray); overload;
procedure StringToDynArray(const sData: string; var aArr: TLongWordDynArray; cSeparator: Char); overload;
procedure StringToDynArray(const sData: string; var aArr: TSingleDynArray; cSeparator: Char); overload;
procedure StringToArray(const sData: string; var aArr: array of Longword); overload;
procedure StringToArray(const sData: string; var aArr: array of Single); overload;

function StringsEqual(const sStr1, sStr2: string): Boolean;
function StringsEqualNoCase(const sStr1, sStr2: string): Boolean;
function StringsCompare(const sStr1, sStr2: string): Integer;
function StringsCompareNoCase(const sStr1, sStr2: string): Integer;

function StrMCmp(Str: PChar; Mask: PChar): Boolean;
function StrMICmp(Str: PChar; Mask: PChar): Boolean;

function StringsMaskCompare(const Str: string; const Mask: string): Boolean;
function StringsMaskCompareNoCase(const Str: string; const Mask: string): Boolean;

function StringSplit(const sStr: string; var aArr: array of string; cDelim: Char = ' '): Boolean; overload;
function StringSplit(const sStr: string; cDelim: Char = ' '): TStringDynArray; overload;
function StrLen(const pStr: PChar): Longword;
function PCharToString(const pSource: PChar; var sDest: string): Integer;
procedure TrimStr(var sStr: string);

function CharPos(cChr: Char; const sStr: string): Integer;
function CharPosEx(cChr: Char; const sStr: string; iOffset: Integer): Integer;
function GetStrRef(const sStr: string): Integer; inline;
procedure IncStrRef(const sStr: string; iAddend: Integer);
procedure DecStrRef(const sStr: string; iAddend: Integer);

function FileNameToOS(const sName: string): string;

function EndianSwap32(lwValue: Longword): Longword; overload;
function EndianSwap16(wValue: Word): Word; overload;

procedure EndianSwapBuf(pValue: PLongword; iCount: Integer);
procedure EndianSwap32(pValue: PLongword); overload;
procedure EndianSwap16(pValue: PWord); overload;

procedure ReverseLongs(pData: Pointer; iCount: Integer);
procedure ReverseWords(pData: Pointer; iCount: Integer);
procedure ReverseBytes(pData: Pointer; iCount: Integer);

procedure RotateBufferRight32(pData: Pointer; iCount: Integer);
procedure RotateBufferLeft32(pData: Pointer; iCount: Integer);

{ Bit-Wise }
function GetBit32(Value: Longword; Bit: Integer): Boolean; inline;
function SetBit32(Value: Longword; Bit: Integer): Longword; inline;
function ResetBit32(Value: Longword; Bit: Integer): Longword; inline;
function ToggleBit32(Value: Longword; Bit: Integer): Longword; inline;
function SetBitScanForward32(Value: Longword; FirstBit: Integer): Integer;
function SetBitScanBackward32(Value: Longword; LastBit: Integer): Integer;
function ResetBitScanForward32(Value: Longword; FirstBit: Integer): Integer;
function ResetBitScanBackward32(Value: Longword; LastBit: Integer): Integer;

function GetBit(P: Pointer; Bit: Integer): Boolean;
procedure SetBit(P: Pointer; Bit: Integer);
procedure ResetBit(P: Pointer; Bit: Integer);
procedure ToggleBit(P: Pointer; Bit: Integer);
function SetBitScanForward(P: Pointer; FirstBit, LastBit: Integer): Integer;
function SetBitScanBackward(P: Pointer; FirstBit, LastBit: Integer): Integer;
function ResetBitScanForward(P: Pointer; FirstBit, LastBit: Integer): Integer;
function ResetBitScanBackward(P: Pointer; FirstBit, LastBit: Integer): Integer;

function SetBits32(Value: Longword; FirstBit, LastBit: Integer): Longword;
function ResetBits32(Value: Longword; FirstBit, LastBit: Integer): Longword;
function ToggleBits32(Value: Longword; FirstBit, LastBit: Integer): Longword;

procedure SetBits(P: Pointer; FirstBit, LastBit: Integer);
procedure ResetBits(P: Pointer; FirstBit, LastBit: Integer);
procedure ToggleBits(P: Pointer; FirstBit, LastBit: Integer);

function CopyBits(Value: Longword; BitSrc: Longword; DestIndex: Integer;
  SrcIndex: Integer; Count: Integer): Longword;

type
  PBitBuffer = ^TBitBuffer;
  TBitBuffer = record
    BitSize: Longword;
    Size: Integer;
    Buffer: Pointer;
  end;

{ Allocates a randomly initialized block of memory for the bitbuffer and sets the
  bitsize and realsize fields. }
procedure GetBitBuffer(pBuffer: PBitBuffer; iBitSize: Longword); overload; inline;
{ Allocates a zero-initialized initialized block of memory for the bitbuffer and sets the
  bitsize and realsize fields. }
procedure AllocBitBuffer(pBuffer: PBitBuffer; iBitSize: Longword); overload; inline;
{ Reallocates the bitbuffer and sets the
  bitsize and realsize fields to reflect this change. }
procedure ReallocBitBuffer(pBuffer: PBitBuffer; iBitSize: Longword); overload; inline;

{ These routines do not work with the TBitBuffer record, but with raw memory pointers. }
procedure GetBitBuffer(var pPtr; iBitSize: Longword); overload; inline;
procedure GetBitBuffer(var pPtr; iBitSize: Longword; var iOutSize: Integer); overload; inline;
function AllocBitBuffer(iBitSize: Longword): Pointer; overload; inline;
function AllocBitBuffer(iBitSize: Longword; var iOutSize: Integer): Pointer; overload; inline;
procedure ReallocBitBuffer(var pPtr; iBitSize: Longword); overload; inline;
procedure ReallocBitBuffer(var pPtr; iBitSize: Longword; out iOutSize: Integer); overload; inline;

{ Logical operations performed on buffers }
procedure XorBuffers(const xSrc1, xSrc2; var xDest; iCount: Integer);
procedure OrBuffers(const xSrc1, xSrc2; var xDest; iCount: Integer);
procedure AndBuffers(const xSrc1, xSrc2; var xDest; iCount: Integer);
procedure AndNotBuffers(const xSrc1, xSrc2; var xDest; iCount: Integer);
procedure NotBuffer(const xSrc; var xDest; iCount: Integer);

{ MMX versions }
procedure XorBuffersMMX(const xSrc1, xSrc2; var xDest; iCount: Integer);
procedure OrBuffersMMX(const xSrc1, xSrc2; var xDest; iCount: Integer);
procedure AndBuffersMMX(const xSrc1, xSrc2; var xDest; iCount: Integer);
procedure AndNotBuffersMMX(const xSrc1, xSrc2; var xDest; iCount: Integer);
procedure NotBufferMMX(const xSrc; var xDest; iCount: Integer);

{ Enhanced Move procedures }

procedure MoveMMX(const Source; var Dest; Count: Integer);
procedure MoveSSE(const Source; var Dest; Count: Integer);
procedure MoveSSE2(const Source; var Dest; Count: Integer);
procedure MoveSSE3(const Source; var Dest; Count: Integer);

{ Generic routines }
procedure OutputToLog(const sLogName, sMsg: string; bAddDate: Boolean = True;
  iLimit: Integer = $4000);

{ This function returns the object represented by the passed interface }
function GetImplementorOfInterface(const I: IInterface): Pointer;

function GetTimeDifference(lwAfter, lwBefore: Longword): Longword; inline;

procedure ForceAlignment(pValue: PLongword; lwAlignment: Longword); overload;
function ForceAlignment(lwValue: Longword; lwAlignment: Longword): Longword; overload;
function IsObject(pPtr: Pointer): Boolean;

procedure AssignIfZero(pTarget: PLongword; lwValue: Longword); overload;
procedure AssignIfZero(pTarget: PSingle; fValue: Single); overload;

function CheckZeroByteOccurence(pSrc: Pointer): Integer;
{
  This function returns index of first $00 byte of value pSrc points to.
  If you have a boolean array like aBools: array[0..3] of Boolean and you would
  initialize it to False and then pass it to this routine (@aBools[0]), returned
  index would be 0 (aBools[0]). When the a DWORD does not contain a zero byte,
  result is set to -1.
}

procedure StartExecutionTimer; overload;
procedure StartExecutionTimer(var liDest: Int64); overload;
function StopExecutionTimer: Extended; overload;
function StopExecutionTimer(var liSrc: Int64): Extended; overload;
procedure CalcOverhead;
{
  These 2 functions are used to measure time which takes to execute a routine.
  If you want accurate results, run the routine more times until the total
  execution takes at least 500 ms, otherwise the result may vary a lot. Thread-safe.
}
function ReadCPUTicks: Int64;

procedure OffsetMove(const xSource; var xDest; iCount, iSourceOffset, iDestOffset: Integer); inline;

function Ceil32(const X: Single): Integer;
function Floor32(const X: Single): Integer;
function Trunc32(const X: Single): Integer;
function IntIntPower(X, Power: Integer): Integer;

function DivMod(Dividend, Divisor: Integer; out Remainder: Integer): Integer;
function DivModInc(Dividend, Divisor: Integer): Integer;
function DivModDec(Dividend, Divisor: Integer): Integer;
function DivModPowerOf2(Dividend: Integer; Power: Longword; out Remainder: Integer): Integer;
function DivModPowerOf2Inc(Dividend: Integer; Power: Longword): Integer;
function DivModPowerOf2Dec(Dividend: Integer; Power: Longword): Integer;
function DivModU(Dividend, Divisor: Longword; out Remainder: Longword): Longword;
function DivModUInc(Dividend, Divisor: Longword): Longword;
function DivModUDec(Dividend, Divisor: Longword): Longword;
function DivModUPowerOf2(Dividend, Power: Longword; out Remainder: Longword): Longword;
function DivModUPowerOf2Inc(Dividend, Power: Longword): Longword;
function DivModUPowerOf2Dec(Dividend, Power: Longword): Longword;

{ For use with the exception raising }
function GetCurrentReturnAddress: Pointer;

procedure Cleanup(Instance: TObject);

procedure AllocateInstanceArray(ClassType: TClass; var Buffer: Pointer; Count: Int32);
procedure AllocateInstanceArrayEx(ClassType: TClass; var Buffer: Pointer; Count: Int32; Callback: TEnumerationCallback);

procedure FreeInstanceArray(ClassType: TClass; var Buffer: Pointer; InvokeDestructor: Boolean);
procedure FreeInstanceArrayEx(ClassType: TClass; var Buffer: Pointer; InvokeDestructor: Boolean; Callback: TEnumerationCallback);

procedure ClearInstanceArray(ClassType: TClass; Buffer: Pointer; InvokeDestructor: Boolean);
procedure ClearInstanceArrayEx(ClassType: TClass; Buffer: Pointer; InvokeDestructor: Boolean; Callback: TEnumerationCallback);

function NextPowerOf2(I: Longword): Longword;

implementation

uses
  MMSystem,
  Bfg.Metadata,
  Bfg.SystemInfo,
  Bfg.Containers,
  Math;

{$G-}

var
  CPUFrequency: Int64;
  Overhead: Single;

threadvar
  Start, Stop: Int64;

procedure InitInstanceBlock(ClassType: TClass; Block: Pointer; Count: Int32); forward;
procedure InitInstanceBlockEx(ClassType: TClass; Block: Pointer; Count: Int32; Callback: TEnumerationCallback); forward;

procedure CleanupInstanceBlock(ClassType: TClass; Block: Pointer; Count: Int32; InvokeDestructor: Boolean); forward;
procedure CleanupInstanceBlockEx(ClassType: TClass; Block: Pointer; Count: Int32; InvokeDestructor: Boolean; Callback: TEnumerationCallback); forward;


function StackAlloc(Size: Integer): Pointer; register;
asm
  POP   ECX          { return address }
  MOV   EDX, ESP
  ADD   EAX, 3
  AND   EAX, not 3   // round up to keep ESP dword aligned
  CMP   EAX, 4092
  JLE   @@2
@@1:
  SUB   ESP, 4092
  PUSH  EAX          { make sure we touch guard page, to grow stack }
  SUB   EAX, 4096
  JNS   @@1
  ADD   EAX, 4096
@@2:
  SUB   ESP, EAX
  MOV   EAX, ESP     { function result = low memory address of block }
  PUSH  EDX          { save original SP, for cleanup }
  MOV   EDX, ESP
  SUB   EDX, 4
  PUSH  EDX          { save current SP, for sanity check  (sp = [sp]) }
  PUSH  ECX          { return to caller }
end;

procedure StackFree(P: Pointer); register;
asm
  POP   ECX                     { return address }
  MOV   EDX, DWORD PTR [ESP]
  SUB   EAX, 8
  CMP   EDX, ESP                { sanity check #1 (SP = [SP]) }
  JNE   @@1
  CMP   EDX, EAX                { sanity check #2 (P = this stack block) }
  JNE   @@1
  MOV   ESP, DWORD PTR [ESP+4]  { restore previous SP  }
@@1:
  PUSH  ECX                     { return to caller }
end;

function MakeMethod(Code: Pointer; Data: Pointer): TMethod;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1151 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result.Code := Code;
  Result.Data := Data;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1151; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function HashData(Data: Pointer; Size: Integer): Longword;
const
  MAGIC_CONST = $7ED55D16;
var
  I: Integer;
  Remaining: Integer;
  Temp: Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1152 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Size <= 0) or (Data = nil) then
  begin
    Result := 0;
    Exit;
  end;

  Result := MAGIC_CONST;
  Remaining := Size and 3;
  Size := Integer(Longword(Size) shr 2);

  for I := 0 to Size -1 do
  begin
    Inc(Result, PWord(Data)^);
    Temp := (PWordArray(Data)^[1] shl 11) xor Result;
    Result := (Result shl 16) xor Temp;
    Inc(Result, Result shr 11);
    Inc(PWord(Data), 2);
  end;

  case Remaining of
    3:
    begin
      Inc(Result, PWord(Data)^);
      Result := Result xor (Result shl 16);
      Result := Result xor (PByteArray(Data)^[2] shl 18);
      Inc(Result, Result shr 11);
    end;
    2:
    begin
      Inc(Result, PWord(Data)^);
      Result := Result xor (Result shl 11);
      Inc(Result, Result shr 17);
    end;
    1:
    begin
      Inc(Result, PByte(Data)^);
      Result := Result xor (Result shl 10);
      Inc(Result, Result shr 1);
    end;
  end;

  Result := Result xor (Result shl 3);
  Inc(Result, Result shr 5);
  Result := Result xor (Result shl 4);
  Inc(Result, Result shr 17);
  Result := Result xor (Result shl 25);
  Inc(Result, Result shr 6);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1152; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function HashDataModulo(Data: Pointer; Size: Integer; Max: Longword): Longword;
const
  MAGIC_CONST = $7ED55D16;
var
  I: Integer;
  Remaining: Integer;
  Temp: Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1153 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Size <= 0) or (Data = nil) then
  begin
    Result := 0;
    Exit;
  end;

  Result := MAGIC_CONST;
  Remaining := Size and 3;
  Size := Integer(Longword(Size) shr 2);

  for I := 0 to Size -1 do
  begin
    Inc(Result, PWord(Data)^);
    Temp := (PWordArray(Data)^[1] shl 11) xor Result;
    Result := (Result shl 16) xor Temp;
    Inc(Result, Result shr 11);
    Inc(PWord(Data), 2);
  end;

  case Remaining of
    3:
    begin
      Inc(Result, PWord(Data)^);
      Result := Result xor (Result shl 16);
      Result := Result xor (PByteArray(Data)^[2] shl 18);
      Inc(Result, Result shr 11);
    end;
    2:
    begin
      Inc(Result, PWord(Data)^);
      Result := Result xor (Result shl 11);
      Inc(Result, Result shr 17);
    end;
    1:
    begin
      Inc(Result, PByte(Data)^);
      Result := Result xor (Result shl 10);
      Inc(Result, Result shr 1);
    end;
  end;

  Result := Result xor (Result shl 3);
  Inc(Result, Result shr 5);
  Result := Result xor (Result shl 4);
  Inc(Result, Result shr 17);
  Result := Result xor (Result shl 25);
  Inc(Result, Result shr 6);
  Result := Result mod Max;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1153; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function HashDataMasked(Data: Pointer; Size: Integer; Mask: Longword): Longword;
const
  MAGIC_CONST = $7ED55D16;
var
  I: Integer;
  Remaining: Integer;
  Temp: Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1153 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Size <= 0) or (Data = nil) then
  begin
    Result := 0;
    Exit;
  end;

  Result := MAGIC_CONST;
  Remaining := Size and 3;
  Size := Integer(Longword(Size) shr 2);

  for I := 0 to Size -1 do
  begin
    Inc(Result, PWord(Data)^);
    Temp := (PWordArray(Data)^[1] shl 11) xor Result;
    Result := (Result shl 16) xor Temp;
    Inc(Result, Result shr 11);
    Inc(PWord(Data), 2);
  end;

  case Remaining of
    3:
    begin
      Inc(Result, PWord(Data)^);
      Result := Result xor (Result shl 16);
      Result := Result xor (PByteArray(Data)^[2] shl 18);
      Inc(Result, Result shr 11);
    end;
    2:
    begin
      Inc(Result, PWord(Data)^);
      Result := Result xor (Result shl 11);
      Inc(Result, Result shr 17);
    end;
    1:
    begin
      Inc(Result, PByte(Data)^);
      Result := Result xor (Result shl 10);
      Inc(Result, Result shr 1);
    end;
  end;

  Result := Result xor (Result shl 3);
  Inc(Result, Result shr 5);
  Result := Result xor (Result shl 4);
  Inc(Result, Result shr 17);
  Result := Result xor (Result shl 25);
  Inc(Result, Result shr 6);
  Result := Result and Mask;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1153; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function NoCase8(B: Byte): Byte; inline;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1154 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Char(B) in ['a'..'z'] then
  begin
    Dec(B, 32);
  end;
  Result := B;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1154; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function NoCase16(V: Word): Word; inline;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1155 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := NoCase8(V) or (NoCase8(V shr 8) shl 8);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1155; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function HashDataNoCase(Data: Pointer; Size: Integer): Longword;
const
  MAGIC_CONST = $7ED55D16;
var
  I: Integer;
  Remaining: Integer;
  Temp: Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1156 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Size <= 0) or (Data = nil) then
  begin
    Result := 0;
    Exit;
  end;

  Result := MAGIC_CONST;
  Remaining := Size and 3;
  Size := Integer(Longword(Size) shr 2);

  for I := 0 to Size -1 do
  begin
    Inc(Result, NoCase16(PWord(Data)^));
    Temp := (NoCase16(PWordArray(Data)^[1]) shl 11) xor Result;
    Result := (Result shl 16) xor Temp;
    Inc(Result, Result shr 11);
    Inc(PWord(Data), 2);
  end;

  case Remaining of
    3:
    begin
      Inc(Result, NoCase16(PWord(Data)^));
      Result := Result xor (Result shl 16);
      Result := Result xor (NoCase8(PByteArray(Data)^[2]) shl 18);
      Inc(Result, Result shr 11);
    end;
    2:
    begin
      Inc(Result, NoCase16(PWord(Data)^));
      Result := Result xor (Result shl 11);
      Inc(Result, Result shr 17);
    end;
    1:
    begin
      Inc(Result, NoCase8(PByte(Data)^));
      Result := Result xor (Result shl 10);
      Inc(Result, Result shr 1);
    end;
  end;

  Result := Result xor (Result shl 3);
  Inc(Result, Result shr 5);
  Result := Result xor (Result shl 4);
  Inc(Result, Result shr 17);
  Result := Result xor (Result shl 25);
  Inc(Result, Result shr 6);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1156; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function HashDataNoCaseRange(Data: Pointer; Size: Integer; Limit: Longword): Longword;
const
  MAGIC_CONST = $7ED55D16;
var
  I: Integer;
  Remaining: Integer;
  Temp: Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1157 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Size <= 0) or (Data = nil) then
  begin
    Result := 0;
    Exit;
  end;

  Result := MAGIC_CONST;
  Remaining := Size and 3;
  Size := Integer(Longword(Size) shr 2);

  for I := 0 to Size -1 do
  begin
    Inc(Result, NoCase16(PWord(Data)^));
    Temp := (NoCase16(PWordArray(Data)^[1]) shl 11) xor Result;
    Result := (Result shl 16) xor Temp;
    Inc(Result, Result shr 11);
    Inc(PWord(Data), 2);
  end;

  case Remaining of
    3:
    begin
      Inc(Result, NoCase16(PWord(Data)^));
      Result := Result xor (Result shl 16);
      Result := Result xor (NoCase8(PByteArray(Data)^[2]) shl 18);
      Inc(Result, Result shr 11);
    end;
    2:
    begin
      Inc(Result, NoCase16(PWord(Data)^));
      Result := Result xor (Result shl 11);
      Inc(Result, Result shr 17);
    end;
    1:
    begin
      Inc(Result, NoCase8(PByte(Data)^));
      Result := Result xor (Result shl 10);
      Inc(Result, Result shr 1);
    end;
  end;

  Result := Result xor (Result shl 3);
  Inc(Result, Result shr 5);
  Result := Result xor (Result shl 4);
  Inc(Result, Result shr 17);
  Result := Result xor (Result shl 25);
  Inc(Result, Result shr 6);
  Result := Result mod Limit;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1157; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function HashString(const Str: string; Limit: Longword): Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1158 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := HashDataModulo(Pointer(Str), Length(Str), Limit);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1158; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function HashStringNoCase(const Str: string; Limit: Longword): Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1159 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := HashDataNoCaseRange(Pointer(Str), Length(Str), Limit);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1159; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function HashLong(Value: Longword): Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1160 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Value := Value xor $69D3CD08;
  Dec(Value, Value shl 6);
  Value := Value xor (Value shr 17);
  Dec(Value, Value shl 9);
  Value := Value xor (Value shl 4);
  Dec(Value, Value shl 3);
  Value := Value xor (Value shl 10);
  Result := Value xor (Value shr 15);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1160; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function HashLongMasked(Value: Longword; Mask: Longword): Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1161 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Value := Value xor $69D3CD08;
  Dec(Value, Value shl 6);
  Value := Value xor (Value shr 17);
  Dec(Value, Value shl 9);
  Value := Value xor (Value shl 4);
  Dec(Value, Value shl 3);
  Value := Value xor (Value shl 10);
  Result := (Value xor (Value shr 15)) and Mask;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1161; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function HashLongModulo(Value: Longword; Max: Longword): Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1161 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Value := Value xor $69D3CD08;
  Dec(Value, Value shl 6);
  Value := Value xor (Value shr 17);
  Dec(Value, Value shl 9);
  Value := Value xor (Value shl 4);
  Dec(Value, Value shl 3);
  Value := Value xor (Value shl 10);
  Result := (Value xor (Value shr 15)) mod Max;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1161; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure ForceAlignment(pValue: PLongword; lwAlignment: Longword);
asm
  PUSH  EBX
  MOV   ECX, EAX
  MOV   EAX, [EAX]
  MOV   EBX, EDX
  XOR   EDX, EDX
  DIV   EBX
  TEST  EDX, EDX
  JZ    @@Aligned
  INC   EAX
  MUL   EBX
  MOV   [ECX], EAX
@@Aligned:
  POP   EBX
end;

function ForceAlignment(lwValue: Longword; lwAlignment: Longword): Longword;
asm
  MOV   ECX, EDX
  XOR   EDX, EDX
  DIV   ECX
  TEST  EDX, EDX
  JZ    @@Aligned
  INC   EAX
@@Aligned:
  MUL   ECX
end;

function IsObject(pPtr: Pointer): Boolean;
type
  TBytes = array of Byte;
var
  pName: Pointer;
  pTemp: Pointer;
  pCls: Pointer;
const
  ClsMaxLen = 40;
  ClassRefLen = -vmtSelfPtr;
  TObjectName: PChar = 'TObject';
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1162 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if pPtr <> nil then
  begin
    GetMem(pTemp, 4);
    if not ReadProcessMemory(GetCurrentProcess, pPtr, pTemp, 4, nil) then
    begin
      FreeMem(pTemp, 4);
      Result := False;
      Exit;
    end else
    begin
      ReallocMem(pTemp, ClassRefLen);
      pCls := Pointer(pPtr^);
      if not ReadProcessMemory(GetCurrentProcess, Pointer(Longword(pCls) - ClassRefLen),
        pTemp, ClassRefLen, nil) then
      begin
        FreeMem(pTemp, ClassRefLen);
        Result := False;
        Exit;
      end;
      FreeMem(pTemp, ClassRefLen);
      pName := Pointer(PPointer(Pointer(Integer(pCls) + vmtClassName))^);
      if PByte(pName)^ > ClsMaxLen then
      begin
        Result := False;
        Exit;
      end;
      if TClass(pCls).ClassParent = nil then
      begin
        { Only TObject has no parent }
        Result := CompareMem(@TBytes(pName)[1], TObjectName, 7);
        Exit;
      end;
      Result := True;
    end;
  end else Result := False;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1162; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function CheckZeroByteOccurence(pSrc: Pointer): Integer;
asm
  PUSH  EBX
  MOV   EDX, EAX
  MOV   EBX, [EAX]
  ADD   EAX, 3
  LEA   ECX, [EBX-$01010101]
  OR    ECX, EBX
  NOT   EBX
  AND   ECX, EBX
  AND   ECX, $80808080
  JZ    @@NoZero
  TEST  ECX, $00008080
  JZ    @@Found
  SHL   ECX, 16
  SUB   EAX, 2
@@Found:
  SHL   ECX, 9
  SBB   EAX, EDX
  JMP   @@Exit
@@NoZero:
  OR    EAX, -1
@@Exit:
  POP   EBX
end;

procedure StartExecutionTimer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1163 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  QueryPerformanceCounter(@Start);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1163; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure StartExecutionTimer(var liDest: Int64);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1164 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  QueryPerformanceCounter(@liDest);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1164; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function StopExecutionTimer: Extended;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1165 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  QueryPerformanceCounter(@Stop);
  if CPUFrequency = 0 then
  begin
    QueryPerformanceFrequency(@CPUFrequency);
    CalcOverhead;
  end;
  Result := (Stop - Start - Overhead) / CPUFrequency * 1000; { miliseconds }
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1165; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function StopExecutionTimer(var liSrc: Int64): Extended;
var
  liDest: Int64;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1166 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  QueryPerformanceCounter(@liDest);
  if CPUFrequency = 0 then
  begin
    QueryPerformanceFrequency(@CPUFrequency);
    CalcOverhead;
  end;
  Result := (liDest - liSrc - Overhead) / CPUFrequency * 1000; { miliseconds }
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1166; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function ReadCPUTicks: Int64;
asm
  RDTSC
end;

function EndianSwap32(lwValue: Longword): Longword;
asm
  BSWAP   EAX
end;

function EndianSwap16(wValue: Word): Word;
asm
  XCHG    AL, AH
end;

procedure EndianSwapBuf(pValue: PLongword; iCount: Integer);
asm
  TEST    EAX, EAX
  JZ      @@Exit
  DEC     EDX
  JS      @@Exit
@@Loop:
  MOV     ECX, [EAX+EDX*4]
  BSWAP   ECX
  MOV     [EAX+EDX*4], ECX
  DEC     EDX
  JNS     @@Loop
@@Exit:
end;

procedure EndianSwap32(pValue: PLongword);
asm
  TEST    EAX, EAX
  JZ      @@Exit
  MOV     EDX, [EAX]
  BSWAP   EDX
  MOV     [EAX], EDX
@@Exit:
end;

procedure EndianSwap16(pValue: PWord);
asm
  TEST    EAX, EAX
  JZ      @@Exit
  MOV     DX, [EAX]
  XCHG    DL, DH
  MOV     [EAX], DX
@@Exit:
end;

procedure ReverseLongs(pData: Pointer; iCount: Integer);
asm
        PUSH    EDI
        ADD     EAX, 4
        LEA     EDI, [EAX+EDX*4-12]
@@lp:   CMP     EAX, EDI
        JGE     @@nx
        MOV     ECX, [EAX-4]
        MOV     EDX, [EDI+4]
        MOV     [EDI+4], ECX
        MOV     [EAX-4], EDX
        MOV     ECX, [EAX]
        MOV     EDX, [EDI]
        MOV     [EDI], ECX
        MOV     [EAX], EDX
        ADD     EAX, 8
        SUB     EDI, 8
        JMP     @@lp
@@nx:   SUB     EAX, 4
        CMP     EAX, EDI
        JG      @@qt
        MOV     ECX, [EAX]
        MOV     EDX, [EDI+4]
        MOV     [EDI+4], ECX
        MOV     [EAX], EDX
@@qt:   POP     EDI
end;

procedure ReverseWords(pData: Pointer; iCount: Integer);
asm
        PUSH    EDI
        LEA     EDI, [EAX+EDX*2-2]
@@lp:   CMP     EAX, EDI
        JGE     @@qt
        MOV     CX, WORD PTR [EAX]
        MOV     DX, WORD PTR [EDI]
        MOV     WORD PTR [EDI], CX
        MOV     WORD PTR [EAX], DX
        ADD     EAX, 2
        SUB     EDI, 2
        JMP     @@lp
@@qt:   POP     EDI
end;

procedure ReverseBytes(pData: Pointer; iCount: Integer);
asm
        LEA     ECX, [EAX+EDX-1]
@@lp:   CMP     EAX, ECX
        JGE     @@qt
        MOV     DH, BYTE PTR [EAX]
        MOV     DL, BYTE PTR [ECX]
        MOV     BYTE PTR [ECX], DH
        MOV     BYTE PTR [EAX], DL
        INC     EAX
        DEC     ECX
        JMP     @@lp
@@qt:
end;

procedure RotateBufferRight32(pData: Pointer; iCount: Integer);
asm
  PUSH    EBX
  PUSH    ESI
  PUSH    EDI
  DEC     EDX
  MOV     EBX, EDX
  MOV     ESI, EDX
  SHR     EBX, 4
  MOV     EDI, [EAX+EDX*4]
  JZ      @@EndLoop
@@Loop:
  MOV     EDX, [EAX+60]
  MOV     ECX, [EAX+56]
  MOV     [EAX+64], EDX
  MOV     [EAX+60], ECX
  MOV     EDX, [EAX+52]
  MOV     ECX, [EAX+48]
  MOV     [EAX+56], EDX
  MOV     [EAX+52], ECX
  MOV     EDX, [EAX+44]
  MOV     ECX, [EAX+40]
  MOV     [EAX+48], EDX
  MOV     [EAX+44], ECX
  MOV     EDX, [EAX+36]
  MOV     ECX, [EAX+32]
  MOV     [EAX+40], EDX
  MOV     [EAX+36], ECX
  MOV     EDX, [EAX+28]
  MOV     ECX, [EAX+24]
  MOV     [EAX+32], EDX
  MOV     [EAX+28], ECX
  MOV     EDX, [EAX+20]
  MOV     ECX, [EAX+16]
  MOV     [EAX+24], EDX
  MOV     [EAX+20], ECX
  MOV     EDX, [EAX+12]
  MOV     ECX, [EAX+8]
  MOV     [EAX+16], EDX
  MOV     [EAX+12], ECX
  MOV     EDX, [EAX+4]
  MOV     ECX, [EAX]
  MOV     [EAX+8], EDX
  MOV     [EAX+4], ECX
  ADD     EAX, 64
  DEC     EBX
  JNZ     @@Loop
@@EndLoop:
  MOV     EBX, ESI
  AND     ESI, 15
  JMP     DWORD PTR [@@wV+ESI*4]
@@wV:
  DD      @@w00, @@w01, @@w02, @@w03
  DD      @@w04, @@w05, @@w06, @@w07
  DD      @@w08, @@w09, @@w10, @@w11
  DD      @@w12, @@w13, @@w14, @@w15
@@w15:
  MOV     EDX, [EAX+56]
  MOV     [EAX+60], EDX
@@w14:
  MOV     EDX, [EAX+52]
  MOV     [EAX+56], EDX
@@w13:
  MOV     EDX, [EAX+48]
  MOV     [EAX+52], EDX
@@w12:
  MOV     EDX, [EAX+44]
  MOV     [EAX+48], EDX
@@w11:
  MOV     EDX, [EAX+40]
  MOV     [EAX+44], EDX
@@w10:
  MOV     EDX, [EAX+36]
  MOV     [EAX+40], EDX
@@w09:
  MOV     EDX, [EAX+32]
  MOV     [EAX+36], EDX
@@w08:
  MOV     EDX, [EAX+28]
  MOV     [EAX+32], EDX
@@w07:
  MOV     EDX, [EAX+24]
  MOV     [EAX+28], EDX
@@w06:
  MOV     EDX, [EAX+20]
  MOV     [EAX+24], EDX
@@w05:
  MOV     EDX, [EAX+16]
  MOV     [EAX+20], EDX
@@w04:
  MOV     EDX, [EAX+12]
  MOV     [EAX+16], EDX
@@w03:
  MOV     EDX, [EAX+8]
  MOV     [EAX+12], EDX
@@w02:
  MOV     EDX, [EAX+4]
  MOV     [EAX+8], EDX
@@w01:
  MOV     EDX, [EAX]
  MOV     [EAX+4], EDX
@@w00:
  SHR     EBX, 4
  SHL     EBX, 6
  NEG     EBX
  MOV     [EBX+EAX], EDI
  POP     EDI
  POP     ESI
  POP     EBX
end;

procedure RotateBufferLeft32(pData: Pointer; iCount: Integer);
asm
  PUSH    EBX
  PUSH    ESI
  PUSH    EDI
  DEC     EDX
  MOV     EBX, EDX
  MOV     ESI, EDX
  SHR     EBX, 4
  MOV     EDI, [EAX]
  JZ      @@EndLoop
@@Loop:
  MOV     EDX, [EAX+4]
  MOV     ECX, [EAX+8]
  MOV     [EAX], EDX
  MOV     [EAX+4], ECX
  MOV     EDX, [EAX+12]
  MOV     ECX, [EAX+16]
  MOV     [EAX+8], EDX
  MOV     [EAX+12], ECX
  MOV     EDX, [EAX+20]
  MOV     ECX, [EAX+24]
  MOV     [EAX+16], EDX
  MOV     [EAX+20], ECX
  MOV     EDX, [EAX+28]
  MOV     ECX, [EAX+32]
  MOV     [EAX+24], EDX
  MOV     [EAX+28], ECX
  MOV     EDX, [EAX+36]
  MOV     ECX, [EAX+40]
  MOV     [EAX+32], EDX
  MOV     [EAX+36], ECX
  MOV     EDX, [EAX+44]
  MOV     ECX, [EAX+48]
  MOV     [EAX+40], EDX
  MOV     [EAX+44], ECX
  MOV     EDX, [EAX+52]
  MOV     ECX, [EAX+56]
  MOV     [EAX+48], EDX
  MOV     [EAX+52], ECX
  MOV     EDX, [EAX+60]
  MOV     ECX, [EAX+64]
  MOV     [EAX+56], EDX
  MOV     [EAX+60], ECX
  ADD     EAX, 64
  DEC     EBX
  JNZ     @@Loop
@@EndLoop:
  AND     ESI, 15
  JZ      @@EndSmallLoop
  XOR     EBX, EBX
@@SmallLoop:
  MOV     EDX, [EAX+EBX*4+4]
  MOV     [EAX+EBX*4], EDX
  INC     EBX
  DEC     ESI
  JNZ     @@SmallLoop
@@EndSmallLoop:
  MOV     [EAX+EBX*4], EDI
  POP     EDI
  POP     ESI
  POP     EBX
end;

function GetBit32(Value: Longword; Bit: Integer): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1167 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := (Value and (1 shl Bit)) <> 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1167; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function SetBit32(Value: Longword; Bit: Integer): Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1168 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := Value or (1 shl Bit);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1168; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function ResetBit32(Value: Longword; Bit: Integer): Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1169 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := Value and not (1 shl Bit);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1169; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function ToggleBit32(Value: Longword; Bit: Integer): Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1170 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := Value xor (1 shl Bit);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1170; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function SetBitScanForward32(Value: Longword; FirstBit: Integer): Integer;
asm
  MOV   ECX, EDX
  OR    EDX, -1
  SHL   EDX, CL
  AND   EDX, EAX
  JE    @@NotFound
  BSF   EAX, EDX
  RET
@@NotFound:
  OR    EAX, -1
end;

function SetBitScanBackward32(Value: Longword; LastBit: Integer): Integer;
asm
  LEA   ECX, [EDX-31]
  OR    EDX, -1
  NEG   ECX
  SHR   EDX, CL
  AND   EDX,EAX
  JE    @@NotFound
  BSR   EAX, EDX
  RET
@@NotFound:
  OR   EAX, -1
end;

function ResetBitScanForward32(Value: Longword; FirstBit: Integer): Integer;
asm
  MOV  ECX, EDX
  OR   EDX, -1
  NOT  EAX
  SHL  EDX, CL
  AND  EDX, EAX
  JE   @@NotFound
  BSF  EAX, EDX
  RET
@@NotFound:
  OR   EAX, -1
end;

function ResetBitScanBackward32(Value: Longword; LastBit: Integer): Integer;
asm
  LEA   ECX, [EDX-31]
  OR    EDX, -1
  NEG   ECX
  NOT   EAX
  SHR   EDX, CL
  AND   EDX,EAX
  JE    @@NotFound
  BSR   EAX, EDX
  RET
@@NotFound:
  OR   EAX, -1
end;

function GetBit(P: Pointer; Bit: Integer): Boolean;
asm
  { Test bit }
  BT [EAX], EDX
  SETC AL
end;

procedure SetBit(P: Pointer; Bit: Integer);
asm
  { Set bit }
  BTS [EAX], EDX
end;

procedure ResetBit(P: Pointer; Bit: Integer);
asm
  { Reset bit }
  BTR [EAX], EDX
end;

procedure ToggleBit(P: Pointer; Bit: Integer);
asm
  { Change bit }
  BTC [EAX], EDX
end;

function SetBits32(Value: Longword; FirstBit, LastBit: Integer): Longword;
asm
  PUSH  EBX
  MOV   EBX, ECX
  MOV   ECX, 31
  SUB   ECX, EBX
  OR    EBX, -1
  SHR   EBX, CL
  MOV   ECX, EDX
  MOV   EDX, EBX
  SHL   EBX, CL
  AND   EDX, EBX
  OR    EAX, EDX
  POP   EBX
end;

function ResetBits32(Value: Longword; FirstBit, LastBit: Integer): Longword;
asm
  PUSH  EBX
  MOV   EBX, ECX
  MOV   ECX, 31
  SUB   ECX, EBX
  OR    EBX, -1
  SHR   EBX, CL
  MOV   ECX, EDX
  MOV   EDX, EBX
  SHL   EBX, CL
  AND   EDX, EBX
  NOT   EDX
  AND   EAX, EDX
  POP   EBX
end;

function ToggleBits32(Value: Longword; FirstBit, LastBit: Integer): Longword;
asm
  PUSH  EBX
  MOV   EBX, ECX
  MOV   ECX, 31
  SUB   ECX, EBX
  OR    EBX, -1
  SHR   EBX, CL
  MOV   ECX, EDX
  MOV   EDX, EBX
  SHL   EBX, CL
  AND   EDX, EBX
  XOR   EAX, EDX
  POP   EBX
end;

procedure SetBits(P: Pointer; FirstBit, LastBit: Integer);
asm
  CMP   ECX, EDX
  JL    @@Quit
  PUSH  EBX
  PUSH  ESI
  PUSH  EDI
  OR    EBX, -1
  MOV   ESI, ECX
  MOV   EDI, $0000001F
  AND   ECX, EDI
  AND   ESI, $FFFFFFE0
  SUB   EDI, ECX
  SHR   ESI, 5
  MOV   ECX, EDI
  MOV   EDI, EBX
  SHR   EDI, CL
  MOV   ECX, EDX
  AND   EDX, $FFFFFFE0
  AND   ECX, $0000001F
  SHR   EDX, 5
  SHL   EBX, CL
  SUB   ESI, EDX
  JE    @@Equal1
  OR    [EAX+EDX*4], EBX
  INC   EDX
  DEC   ESI
  JE    @@Equal2
  OR    EBX, -1
@@Loop:
  MOV   [EAX+EDX*4], EBX
  INC   EDX
  DEC   ESI
  JNE   @@Loop
@@Equal1:
  AND   EDI, EBX
@@Equal2:
  OR    [EAX+EDX*4], EDI
  POP   EDI
  POP   ESI
  POP   EBX
@@Quit:
end;

procedure ResetBits(P: Pointer; FirstBit, LastBit: Integer);
asm
  CMP   ECX, EDX
  JL    @@Quit
  PUSH  EBX
  PUSH  ESI
  PUSH  EDI
  OR    EBX, -1
  MOV   ESI, ECX
  MOV   EDI, $0000001F
  AND   ECX, EDI
  AND   ESI, $FFFFFFE0
  SUB   EDI, ECX
  SHR   ESI, 5
  MOV   ECX, EDI
  MOV   EDI, EBX
  SHR   EDI, CL
  MOV   ECX, EDX
  AND   EDX, $FFFFFFE0
  AND   ECX, $0000001F
  SHR   EDX, 5
  SHL   EBX, CL
  MOV   ECX, EDX
  AND   EDX, $FFFFFFE0
  AND   ECX, $0000001F
  SHR   EDX, 5
  SHL   EBX, CL
  NOT   EDI
  NOT   EBX
  SUB   ESI, EDX
  JE    @@Equal1
  AND   [EAX+EDX*4], EBX
  INC   EDX
  DEC   ESI
  JE    @@Equal2
  XOR   EBX, EBX
@@Loop:
  MOV   [EAX+EDX*4], EBX
  INC   EDX
  DEC   ESI
  JNE   @@Loop
@@Equal1:
  OR    EDI, EBX
@@Equal2:
  AND   [EAX+EDX*4], EDI
  POP   EDI
  POP   ESI
  POP   EBX
@@Quit:
end;

procedure ToggleBits(P: Pointer; FirstBit, LastBit: Integer);
asm
  CMP   ECX, EDX
  JL    @@Quit
  PUSH  EBX
  PUSH  ESI
  PUSH  EDI
  OR    EBX, -1
  MOV   ESI, ECX
  MOV   EDI, $0000001F
  AND   ECX, EDI
  AND   ESI, $FFFFFFE0
  SUB   EDI, ECX
  SHR   ESI, 5
  MOV   ECX, EDI
  MOV   EDI, EBX
  SHR   EDI, CL
  MOV   ECX, EDX
  AND   EDX, $FFFFFFE0
  AND   ECX, $0000001F
  SHR   EDX, 5
  SHL   EBX, CL
  MOV   ECX, EDX
  AND   EDX, $FFFFFFE0
  AND   ECX, $0000001F
  SHR   EDX, 5
  SHL   EBX, CL
  SUB   ESI, EDX
  JE    @@Equal1
  XOR   [EAX+EDX*4], EBX
  INC   EDX
  DEC   ESI
  JE    @@Equal2
  OR    EBX, -1
@@Loop:
  NOT   [EAX+EDX*4]
  INC   EDX
  DEC   ESI
  JNE   @@Loop
@@Equal1:
  AND   EDI, EBX
@@Equal2:
  XOR   [EAX+EDX*4], EDI
  POP   EDI
  POP   ESI
  POP   EBX
@@Quit:
end;

function SetBitScanForward(P: Pointer; FirstBit, LastBit: Integer): Integer;
asm
  PUSH   EBX
  PUSH   ESI
  PUSH   EDI
  LEA    ESI, [EDX+8]
  CMP    ECX, ESI
  JL     @@ut
  OR     EBX, -1
  MOV    ESI, ECX
  MOV    EDI, $0000001F
  AND    ECX, EDI
  AND    ESI, $FFFFFFE0
  SUB    EDI, ECX
  SHR    ESI, 5
  MOV    ECX, EDI
  MOV    EDI, EBX
  SHR    EDI, CL
  MOV    ECX, EDX
  AND    EDX, $FFFFFFE0
  AND    ECX, $0000001F
  SHR    EDX, 5
  SHL    EBX, CL
  AND    EBX, [EAX+EDX*4]
  SUB    ESI, EDX
  JE     @@nq
  TEST   EBX, EBX
  JNE    @@ne
  INC    EDX
  DEC    ESI
  JE     @@xx
@@lp:
  OR     EBX, [EAX+EDX*4]
  JNE    @@ne
  INC    EDX
  DEC    ESI
  JNE    @@lp
@@xx:
  MOV    EBX, [EAX+EDX*4]
@@nq:
  AND    EBX, EDI
  JE     @@zq
@@ne:
  BSF    ECX, EBX
@@qt:
  SHL    EDX, 5
  LEA    EAX, [ECX+EDX]
  POP    EDI
  POP    ESI
  POP    EBX
  RET
@@ut:
  SUB    ECX, EDX
  JS     @@zq
@@uk:
  BT     [EAX], EDX
  JC     @@iq
  INC    EDX
  DEC    ECX
  JNS    @@uk
@@zq:
  OR     EAX, -1
  POP    EDI
  POP    ESI
  POP    EBX
  RET
@@iq:
  MOV    EAX, EDX
  POP    EDI
  POP    ESI
  POP    EBX
end;

function ResetBitScanForward(P: Pointer; FirstBit, LastBit: Integer): Integer;
asm
  PUSH   EBX
  PUSH   ESI
  PUSH   EDI
  LEA    ESI, [EDX+8]
  CMP    ECX, ESI
  JL     @@ut
  MOV    EBX, $FFFFFFFF
  MOV    ESI, ECX
  MOV    EDI, $0000001F
  AND    ECX, EDI
  AND    ESI, $FFFFFFE0
  SUB    EDI, ECX
  SHR    ESI, 5
  MOV    ECX, EDI
  MOV    EDI, EBX
  SHR    EDI, CL
  MOV    ECX, EDX
  AND    EDX, $FFFFFFE0
  AND    ECX, $0000001F
  SHR    EDX, 5
  SHL    EBX, CL
  MOV    ECX, [EAX+EDX*4]
  NOT    ECX
  AND    EBX, ECX
  SUB    ESI, EDX
  JE     @@nq
  TEST   EBX, EBX
  JNE    @@ne
  INC    EDX
  DEC    ESI
  JE     @@xx
@@lp:
  MOV    EBX, [EAX+EDX*4]
  NOT    EBX
  TEST   EBX, EBX
  JNE    @@ne
  INC    EDX
  DEC    ESI
  JNE    @@lp
@@xx:
  MOV    EBX, [EAX+EDX*4]
  NOT    EBX
@@nq:
  AND    EBX, EDI
  JE     @@zq
@@ne:
  BSF    ECX, EBX
@@qt:
  SHL    EDX, 5
  LEA    EAX, [ECX+EDX]
  POP    EDI
  POP    ESI
  POP    EBX
  RET
@@ut:
  SUB    ECX, EDX
  JS     @@zq
@@uk:
  BT     [EAX], EDX
  JNC    @@iq
  INC    EDX
  DEC    ECX
  JNS    @@uk
@@zq:
  OR     EAX, -1
  POP    EDI
  POP    ESI
  POP    EBX
  RET
@@iq:
  MOV    EAX, EDX
  POP    EDI
  POP    ESI
  POP    EBX
end;

function SetBitScanBackward(P: Pointer; FirstBit, LastBit: Integer): Integer;
asm
  PUSH   EBX
  PUSH   ESI
  PUSH   EDI
  LEA    ESI, [EDX+8]
  CMP    ECX, ESI
  JL     @@ut
  OR     EBX, -1
  MOV    ESI, ECX
  MOV    EDI, $0000001F
  AND    ECX, EDI
  AND    ESI, $FFFFFFE0
  SUB    EDI, ECX
  SHR    ESI, 5
  MOV    ECX, EDI
  MOV    EDI, EBX
  SHR    EDI, CL
  MOV    ECX, EDX
  AND    EDX, $FFFFFFE0
  AND    ECX, $0000001F
  SHR    EDX, 5
  SHL    EBX, CL
  AND    EDI, [EAX+ESI*4]
  SUB    EDX, ESI
  JE     @@nq
  TEST   EDI, EDI
  JNE    @@ne
  NEG    EDX
  DEC    ESI
  DEC    EDX
  JE     @@xx
@@lp:
  OR     EDI, [EAX+ESI*4]
  JNE    @@ne
  DEC    ESI
  DEC    EDX
  JNE    @@lp
@@xx:
  MOV    EDI, [EAX+ESI*4]
@@nq:
  AND    EDI, EBX
  JE     @@zq
@@ne:
  BSR    ECX, EDI
@@qt:
  SHL    ESI, 5
  LEA    EAX, [ECX+ESI]
  POP    EDI
  POP    ESI
  POP    EBX
  RET
@@ut:
  SUB    EDX, ECX
  JG     @@zq
@@uk:
  BT     [EAX], ECX
  JC     @@iq
  DEC    ECX
  INC    EDX
  JNG    @@uk
@@zq:
  OR     EAX, -1
  POP    EDI
  POP    ESI
  POP    EBX
  RET
@@iq:
  MOV    EAX, ECX
  POP    EDI
  POP    ESI
  POP    EBX
end;

function ResetBitScanBackward(P: Pointer; FirstBit, LastBit: Integer): Integer;
asm
  PUSH   EBX
  PUSH   ESI
  PUSH   EDI
  LEA    ESI, [EDX+8]
  CMP    ECX, ESI
  JL     @@ut
  OR     EBX, -1
  MOV    ESI, ECX
  MOV    EDI, $0000001F
  AND    ECX, EDI
  AND    ESI, $FFFFFFE0
  SUB    EDI, ECX
  SHR    ESI, 5
  MOV    ECX, EDI
  MOV    EDI, EBX
  SHR    EDI, CL
  MOV    ECX, EDX
  AND    EDX, $FFFFFFE0
  AND    ECX, $0000001F
  SHR    EDX, 5
  SHL    EBX, CL
  MOV    ECX, [EAX+ESI*4]
  NOT    ECX
  AND    EDI, ECX
  SUB    EDX, ESI
  JE     @@nq
  TEST   EDI, EDI
  JNE    @@ne
  NEG    EDX
  DEC    ESI
  DEC    EDX
  JE     @@xx
@@Loop:
  MOV    EDI, [EAX+ESI*4]
  NOT    EDI
  TEST   EDI, EDI
  JNE    @@ne
  DEC    ESI
  DEC    EDX
  JNE    @@Loop
@@xx:
  MOV    EDI, [EAX+ESI*4]
  NOT    EDI
@@nq:
  AND    EDI, EBX
  JE     @@NotFound
@@ne:
  BSR    ECX, EDI
@@Quit:
  SHL    ESI, 5
  LEA    EAX, [ECX+ESI]
  POP    EDI
  POP    ESI
  POP    EBX
  RET
@@ut:
  SUB    EDX, ECX
  JG     @@NotFound
@@uk:
  BT     [EAX], ECX
  JNC    @@iq
  DEC    ECX
  INC    EDX
  JNG    @@uk
@@NotFound:
  OR     EAX, -1
  POP    EDI
  POP    ESI
  POP    EBX
  RET
@@iq:
  MOV    EAX, ECX
  POP    EDI
  POP    ESI
  POP    EBX
end;

function CopyBits(Value: Longword; BitSrc: Longword; DestIndex: Integer;
  SrcIndex: Integer; Count: Integer): Longword;
asm
  PUSH  EBX
  PUSH  ESI
  MOV   ESI, ECX
  OR    EBX, -1
  MOV   ECX, SrcIndex
  SHR   EDX, CL
  MOV   ECX, 32
  SUB   ECX, Count
  SHR   EBX, CL
  MOV   ECX, ESI
  AND   EDX, EBX
  SHL   EDX, CL
  SHL   EBX, CL
  NOT   EBX
  AND   EAX, EBX
  OR    EAX, EDX
  POP   ESI
  POP   EBX
end;

procedure GetBitBuffer(pBuffer: PBitBuffer; iBitSize: Longword);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1171 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  pBuffer^.BitSize := iBitSize;
  pBuffer^.Size := DivModUPowerOf2Inc(iBitSize, 3);
  GetMem(pBuffer^.Buffer, pBuffer^.Size);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1171; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure AllocBitBuffer(pBuffer: PBitBuffer; iBitSize: Longword); inline;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1172 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  pBuffer^.BitSize := iBitSize;
  pBuffer^.Size := DivModUPowerOf2Inc(iBitSize, 3);
  pBuffer^.Buffer := AllocMem(pBuffer^.Size);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1172; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure ReallocBitBuffer(pBuffer: PBitBuffer; iBitSize: Longword);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1173 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  pBuffer^.BitSize := iBitSize;
  pBuffer^.Size := DivModUPowerOf2Inc(iBitSize, 3);
  ReallocMem(pBuffer^.Buffer, pBuffer^.Size);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1173; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure GetBitBuffer(var pPtr; iBitSize: Longword);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1174 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  GetMem(Pointer(pPtr), DivModUPowerOf2Inc(iBitSize, 3));
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1174; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure GetBitBuffer(var pPtr; iBitSize: Longword; var iOutSize: Integer);
var
  iRes: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1175 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  iRes := DivModUPowerOf2Inc(iBitSize, 3);
  iOutSize := iRes;
  GetMem(Pointer(pPtr), iRes);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1175; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function AllocBitBuffer(iBitSize: Longword): Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1176 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := AllocMem(DivModUPowerOf2Inc(iBitSize, 3));
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1176; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function AllocBitBuffer(iBitSize: Longword; var iOutSize: Integer): Pointer;
var
  iRes: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1177 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  iRes := DivModUPowerOf2Inc(iBitSize, 3);
  iOutSize := iRes;
  Result := AllocMem(iRes);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1177; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure ReallocBitBuffer(var pPtr; iBitSize: Longword);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1178 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  ReallocMem(Pointer(pPtr), DivModUPowerOf2Inc(iBitSize, 3));
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1178; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure ReallocBitBuffer(var pPtr; iBitSize: Longword; out iOutSize: Integer);
var
  iRes: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1179 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  iRes := DivModUPowerOf2Inc(iBitSize, 3);
  iOutSize := iRes;
  ReallocMem(Pointer(pPtr), iRes);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1179; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure XorBuffersBlended(const xSrc1, xSrc2; var xDest; iCount: Integer);
asm
  {
    EAX = xSrc1
    EDX = xSrc2
    ECX = xDest
    [EBP+8] = iCount
  }
  PUSH  EBX
  PUSH  ESI

  MOV   ESI, iCount
  MOV   EBX, ESI
  AND   EBX, 3
  SHR   ESI, 2
  JMP   DWORD PTR [@@JumpTable+EBX*4]
@@JumpTable:
  DD    @@Aligned, @@1Byte, @@2Bytes, @@3Bytes
@@3Bytes:
  MOV   BL, BYTE PTR [EAX+2]
  XOR   BL, BYTE PTR [EDX+2]
  MOV   BYTE PTR [ECX+2], BL
  MOV   BX, WORD PTR [EAX]
  XOR   BX, WORD PTR [EDX]
  MOV   WORD PTR [ECX], BX
  ADD   EAX, 3
  ADD   EDX, 3
  ADD   ECX, 3
  JMP   @@Aligned
@@2Bytes:
  MOV   BX, WORD PTR [EAX]
  XOR   BX, WORD PTR [EDX]
  MOV   WORD PTR [ECX], BX
  ADD   EAX, 2
  ADD   EDX, 2
  ADD   ECX, 2
  JMP   @@Aligned
@@1Byte:
  MOV   BL, BYTE PTR [EAX]
  XOR   BL, BYTE PTR [EDX]
  MOV   BYTE PTR [ECX], BL
  INC   EAX
  INC   EDX
  INC   ECX
@@Aligned:
  DEC   ESI
  JS    @@Exit
@@Loop:
  MOV   EBX, [EAX+ESI*4]
  XOR   EBX, [EDX+ESI*4]
  MOV   [ECX+ESI*4], EBX
  DEC   ESI
  JNS   @@Loop
@@Exit:
  POP   ESI
  POP   EBX
end;

procedure OrBuffersBlended(const xSrc1, xSrc2; var xDest; iCount: Integer);
asm
  {
    EAX = xSrc1
    EDX = xSrc2
    ECX = xDest
    [EBP+8] = iCount
  }
  PUSH  EBX
  PUSH  ESI

  MOV   ESI, iCount
  MOV   EBX, ESI
  AND   EBX, 3
  SHR   ESI, 2
  JMP   DWORD PTR [@@JumpTable+EBX*4]
@@JumpTable:
  DD    @@Aligned, @@1Byte, @@2Bytes, @@3Bytes
@@3Bytes:
  MOV   BL, BYTE PTR [EAX+2]
  OR    BL, BYTE PTR [EDX+2]
  MOV   BYTE PTR [ECX+2], BL
  MOV   BX, WORD PTR [EAX]
  OR    BX, WORD PTR [EDX]
  MOV   WORD PTR [ECX], BX
  ADD   EAX, 3
  ADD   EDX, 3
  ADD   ECX, 3
  JMP   @@Aligned
@@2Bytes:
  MOV   BX, WORD PTR [EAX]
  OR    BX, WORD PTR [EDX]
  MOV   WORD PTR [ECX], BX
  ADD   EAX, 2
  ADD   EDX, 2
  ADD   ECX, 2
  JMP   @@Aligned
@@1Byte:
  MOV   BL, BYTE PTR [EAX]
  OR    BL, BYTE PTR [EDX]
  MOV   BYTE PTR [ECX], BL
  INC   EAX
  INC   EDX
  INC   ECX
@@Aligned:
  DEC   ESI
  JS    @@Exit
@@Loop:
  MOV   EBX, [EAX+ESI*4]
  OR    EBX, [EDX+ESI*4]
  MOV   [ECX+ESI*4], EBX
  DEC   ESI
  JNS   @@Loop
@@Exit:
  POP   ESI
  POP   EBX
end;

procedure AndBuffersBlended(const xSrc1, xSrc2; var xDest; iCount: Integer);
asm
  {
    EAX = xSrc1
    EDX = xSrc2
    ECX = xDest
    [EBP+8] = iCount
  }
  PUSH  EBX
  PUSH  ESI

  MOV   ESI, iCount
  MOV   EBX, ESI
  AND   EBX, 3
  SHR   ESI, 2
  JMP   DWORD PTR [@@JumpTable+EBX*4]
@@JumpTable:
  DD    @@Aligned, @@1Byte, @@2Bytes, @@3Bytes
@@3Bytes:
  MOV   BL, BYTE PTR [EAX+2]
  AND   BL, BYTE PTR [EDX+2]
  MOV   BYTE PTR [ECX+2], BL
  MOV   BX, WORD PTR [EAX]
  AND   BX, WORD PTR [EDX]
  MOV   WORD PTR [ECX], BX
  ADD   EAX, 3
  ADD   EDX, 3
  ADD   ECX, 3
  JMP   @@Aligned
@@2Bytes:
  MOV   BX, WORD PTR [EAX]
  AND   BX, WORD PTR [EDX]
  MOV   WORD PTR [ECX], BX
  ADD   EAX, 2
  ADD   EDX, 2
  ADD   ECX, 2
  JMP   @@Aligned
@@1Byte:
  MOV   BL, BYTE PTR [EAX]
  AND   BL, BYTE PTR [EDX]
  MOV   BYTE PTR [ECX], BL
  INC   EAX
  INC   EDX
  INC   ECX
@@Aligned:
  DEC   ESI
  JS    @@Exit
@@Loop:
  MOV   EBX, [EAX+ESI*4]
  AND   EBX, [EDX+ESI*4]
  MOV   [ECX+ESI*4], EBX
  DEC   ESI
  JNS   @@Loop
@@Exit:
  POP   ESI
  POP   EBX
end;

procedure AndNotBuffersBlended(const xSrc1, xSrc2; var xDest; iCount: Integer);
asm
  {
    EAX = xSrc1
    EDX = xSrc2
    ECX = xDest
    [EBP+8] = iCount
  }
  PUSH  EBX
  PUSH  ESI

  MOV   ESI, iCount
  MOV   EBX, ESI
  AND   EBX, 3
  SHR   ESI, 2
  JMP   DWORD PTR [@@JumpTable+EBX*4]
@@JumpTable:
  DD    @@Aligned, @@1Byte, @@2Bytes, @@3Bytes
@@3Bytes:
  MOV   BL, BYTE PTR [EDX+2]
  NOT   BL
  AND   BL, BYTE PTR [EAX+2]
  MOV   BYTE PTR [ECX+2], BL
  MOV   BX, WORD PTR [EDX]
  NOT   BX
  AND   BX, WORD PTR [EAX]
  MOV   WORD PTR [ECX], BX
  ADD   EAX, 3
  ADD   EDX, 3
  ADD   ECX, 3
  JMP   @@Aligned
@@2Bytes:
  MOV   BX, WORD PTR [EDX]
  NOT   BX
  AND   BX, WORD PTR [EAX]
  MOV   WORD PTR [ECX], BX
  ADD   EAX, 2
  ADD   EDX, 2
  ADD   ECX, 2
  JMP   @@Aligned
@@1Byte:
  MOV   BL, BYTE PTR [EDX]
  NOT   BL
  AND   BL, BYTE PTR [EAX]
  MOV   BYTE PTR [ECX], BL
  INC   EAX
  INC   EDX
  INC   ECX
@@Aligned:
  DEC   ESI
  JS    @@Exit
@@Loop:
  MOV   EBX, [EDX+ESI*4]
  NOT   EBX
  AND   EBX, [EAX+ESI*4]
  MOV   [ECX+ESI*4], EBX
  DEC   ESI
  JNS   @@Loop
@@Exit:
  POP   ESI
  POP   EBX
end;

procedure NotBufferBlended(const xSrc; var xDest; iCount: Integer);
asm
  {
    EAX = xSrc
    EDX = xDest
    ECX = iCount
  }
  PUSH  EBX
  MOV   EBX, ECX
  SHR   ECX, 2
  AND   EBX, 3
  JMP   DWORD PTR [@@JumpTable+EBX*4]
@@JumpTable:
  DD    @@Aligned, @@1Byte, @@2Bytes, @@3Bytes
@@3Bytes:
  MOV   BL, BYTE PTR [EAX+2]
  NOT   BL
  MOV   BYTE PTR [EDX+2], BL
  MOV   BX, WORD PTR [EAX]
  NOT   BX
  MOV   WORD PTR [EDX], BX
  ADD   EAX, 3
  ADD   EDX, 3
  JMP   @@Aligned
@@2Bytes:
  MOV   BX, WORD PTR [EAX]
  NOT   BX
  MOV   WORD PTR [EDX], BX
  ADD   EAX, 2
  ADD   EDX, 2
  JMP   @@Aligned
@@1Byte:
  MOV   BL, BYTE PTR [EAX]
  NOT   BL
  MOV   BYTE PTR [EDX], BL
  INC   EAX
  INC   EDX
@@Aligned:
  DEC   ECX
  JS    @@Exit
@@Loop:
  MOV   EBX, [EAX+ECX*4]
  NOT   EBX
  MOV   [EDX+ECX*4], EBX
  DEC   ECX
  JNS   @@Loop
@@Exit:
  POP   EBX
end;

procedure XorBuffers(const xSrc1, xSrc2; var xDest; iCount: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1180 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  { Dummy }
  asm
    JMP XorBuffersBlended
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1180; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure OrBuffers(const xSrc1, xSrc2; var xDest; iCount: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1181 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  { Dummy }
  asm
    JMP OrBuffersBlended
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1181; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure AndBuffers(const xSrc1, xSrc2; var xDest; iCount: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1182 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  { Dummy }
  asm
    JMP AndBuffersBlended
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1182; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure AndNotBuffers(const xSrc1, xSrc2; var xDest; iCount: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1183 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  { Dummy }
  asm
    JMP AndNotBuffersBlended
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1183; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure NotBuffer(const xSrc; var xDest; iCount: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1184 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  { Dummy }
  asm
    JMP NotBufferBlended
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1184; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure XorBuffersMMX(const xSrc1, xSrc2; var xDest; iCount: Integer);
asm
  {
    EAX = xSrc1
    EDX = xSrc2
    ECX = xDest
    [EBP+8] = iCount
  }
  CMP   iCount, 512
  JAE   @@UseMMX
  POP   EBP
  JMP   XorBuffersBlended { Blended version }
@@UseMMX:
  { MMX Version }
  PUSH  EBX
  PUSH  ESI

  MOV   ESI, iCount
  MOV   EBX, ESI
  AND   EBX, 7
  SHR   ESI, 3
  JMP   DWORD PTR [@@JumpTable+EBX*4]
@@JumpTable:
  DD    @@Aligned, @@1Byte, @@2Bytes, @@3Bytes, @@4Bytes, @@5Bytes, @@6Bytes, @@7Bytes
@@Aligned:
  DEC   ESI
  JS    @@Exit
  LEA   EBX, [ESI+1]
  AND   EBX, 3
  JMP   DWORD PTR [@@MMXTable+EBX*4]
@@MMXTable:
  DD    @@Start, @@MMX_8, @@MMX_16, @@MMX_24
@@Start:
  LEA   ESI, [ESI*8]
@@Loop:
  MOVQ  MM0, [EDX+ESI]
  MOVQ  MM1, [EDX+ESI-8]
  PXOR  MM0, [EAX+ESI]
  PXOR  MM1, [EAX+ESI-8]
  MOVQ  [ECX+ESI], MM0
  MOVQ  [ECX+ESI-8], MM1
  MOVQ  MM0, [EDX+ESI-16]
  MOVQ  MM1, [EDX+ESI-24]
  PXOR  MM0, [EAX+ESI-16]
  PXOR  MM1, [EAX+ESI-24]
  MOVQ  [ECX+ESI-16], MM0
  MOVQ  [ECX+ESI-24], MM1
  SUB   ESI, 32
  JNS   @@Loop
  JMP   @@Exit
@@MMX_8:
  MOVQ  MM0, [EDX+ESI*8]
  PXOR  MM0, [EAX+ESI*8]
  MOVQ  [ECX+ESI*8], MM0
  DEC   ESI
  JMP   @@Start
@@MMX_16:
  LEA   EBX, [ESI*8]
  MOVQ  MM0, [EDX+EBX]
  MOVQ  MM1, [EDX+EBX-8]
  PXOR  MM0, [EAX+EBX]
  PXOR  MM1, [EAX+EBX-8]
  MOVQ  [ECX+EBX], MM0
  MOVQ  [ECX+EBX-8], MM1
  SUB   ESI, 2
  JMP   @@Start
@@MMX_24:
  LEA   EBX, [ESI*8]
  MOVQ  MM0, [EDX+EBX]
  MOVQ  MM1, [EDX+EBX-8]
  MOVQ  MM2, [EDX+EBX-16]
  PXOR  MM0, [EAX+EBX]
  PXOR  MM1, [EAX+EBX-8]
  PXOR  MM2, [EAX+EBX-16]
  MOVQ  [ECX+EBX], MM0
  MOVQ  [ECX+EBX-8], MM1
  MOVQ  [ECX+EBX-16], MM2
  SUB   ESI, 3
  JMP   @@Start
@@7Bytes:
  MOV   EBX, [EDX]
  XOR   EBX, [EAX]
  MOV   [ECX], EBX
  MOV   BX, WORD PTR [EDX+4]
  XOR   BX, WORD PTR [EAX+4]
  MOV   WORD PTR [ECX+4], BX
  MOV   BL, BYTE PTR [EDX+6]
  XOR   BL, BYTE PTR [EAX+6]
  MOV   BYTE PTR [ECX+6], BL
  ADD   EAX, 7
  ADD   EDX, 7
  ADD   ECX, 7
  JMP   @@Aligned
@@6Bytes:
  MOV   EBX, [EDX]
  XOR   EBX, [EAX]
  MOV   [ECX], EBX
  MOV   BX, WORD PTR [EDX+4]
  XOR   BX, WORD PTR [EAX+4]
  MOV   WORD PTR [ECX+4], BX
  ADD   EAX, 6
  ADD   EDX, 6
  ADD   ECX, 6
  JMP   @@Aligned
@@5Bytes:
  MOV   EBX, [EDX]
  XOR   EBX, [EAX]
  MOV   [ECX], EBX
  MOV   BL, BYTE PTR [EDX+5]
  XOR   BL, BYTE PTR [EAX+5]
  MOV   BYTE PTR [ECX+5], BL
  ADD   EAX, 5
  ADD   EDX, 5
  ADD   ECX, 5
  JMP   @@Aligned
@@4Bytes:
  MOV   EBX, [EDX]
  XOR   EBX, [EAX]
  MOV   [ECX], EBX
  ADD   EAX, 4
  ADD   EDX, 4
  ADD   ECX, 4
  JMP   @@Aligned
@@3Bytes:
  MOV   BL, BYTE PTR [EDX+2]
  XOR   BL, BYTE PTR [EAX+2]
  MOV   BYTE PTR [ECX+2], BL
  MOV   BX, WORD PTR [EDX]
  XOR   BX, WORD PTR [EAX]
  MOV   WORD PTR [ECX], BX
  ADD   EAX, 3
  ADD   EDX, 3
  ADD   ECX, 3
  JMP   @@Aligned
@@2Bytes:
  MOV   BX, WORD PTR [EDX]
  XOR   BX, WORD PTR [EAX]
  MOV   WORD PTR [ECX], BX
  ADD   EAX, 2
  ADD   EDX, 2
  ADD   ECX, 2
  JMP   @@Aligned
@@1Byte:
  MOV   BL, BYTE PTR [EDX]
  XOR   BL, BYTE PTR [EAX]
  MOV   BYTE PTR [ECX], BL
  INC   EAX
  INC   EDX
  INC   ECX
  JMP   @@Aligned
@@Exit:
  EMMS
  POP   ESI
  POP   EBX
end;

procedure OrBuffersMMX(const xSrc1, xSrc2; var xDest; iCount: Integer);
asm
  {
    EAX = xSrc1
    EDX = xSrc2
    ECX = xDest
    [EBP+8] = iCount
  }
  CMP   iCount, 512
  JAE   @@UseMMX
  POP   EBP
  JMP   OrBuffersBlended { Blended version }
@@UseMMX:
  { MMX Version }
  PUSH  EBX
  PUSH  ESI

  MOV   ESI, iCount
  MOV   EBX, ESI
  AND   EBX, 7
  SHR   ESI, 3
  JMP   DWORD PTR [@@JumpTable+EBX*4]
@@JumpTable:
  DD    @@Aligned, @@1Byte, @@2Bytes, @@3Bytes, @@4Bytes, @@5Bytes, @@6Bytes, @@7Bytes
@@Aligned:
  DEC   ESI
  JS    @@Exit
  LEA   EBX, [ESI+1]
  AND   EBX, 3
  JMP   DWORD PTR [@@MMXTable+EBX*4]
@@MMXTable:
  DD    @@Start, @@MMX_8, @@MMX_16, @@MMX_24
@@Start:
  LEA   ESI, [ESI*8]
@@Loop:
  MOVQ  MM0, [EDX+ESI]
  MOVQ  MM1, [EDX+ESI-8]
  POR   MM0, [EAX+ESI]
  POR   MM1, [EAX+ESI-8]
  MOVQ  [ECX+ESI], MM0
  MOVQ  [ECX+ESI-8], MM1
  MOVQ  MM0, [EDX+ESI-16]
  MOVQ  MM1, [EDX+ESI-24]
  POR   MM0, [EAX+ESI-16]
  POR   MM1, [EAX+ESI-24]
  MOVQ  [ECX+ESI-16], MM0
  MOVQ  [ECX+ESI-24], MM1
  SUB   ESI, 32
  JNS   @@Loop
  JMP   @@Exit
@@MMX_8:
  MOVQ  MM0, [EDX+ESI*8]
  POR   MM0, [EAX+ESI*8]
  MOVQ  [ECX+ESI*8], MM0
  DEC   ESI
  JMP   @@Start
@@MMX_16:
  LEA   EBX, [ESI*8]
  MOVQ  MM0, [EDX+EBX]
  MOVQ  MM1, [EDX+EBX-8]
  POR   MM0, [EAX+EBX]
  POR   MM1, [EAX+EBX-8]
  MOVQ  [ECX+EBX], MM0
  MOVQ  [ECX+EBX-8], MM1
  SUB   ESI, 2
  JMP   @@Start
@@MMX_24:
  LEA   EBX, [ESI*8]
  MOVQ  MM0, [EDX+EBX]
  MOVQ  MM1, [EDX+EBX-8]
  MOVQ  MM2, [EDX+EBX-16]
  POR   MM0, [EAX+EBX]
  POR   MM1, [EAX+EBX-8]
  POR   MM2, [EAX+EBX-16]
  MOVQ  [ECX+EBX], MM0
  MOVQ  [ECX+EBX-8], MM1
  MOVQ  [ECX+EBX-16], MM2
  SUB   ESI, 3
  JMP   @@Start
@@7Bytes:
  MOV   EBX, [EDX]
  OR    EBX, [EAX]
  MOV   [ECX], EBX
  MOV   BX, WORD PTR [EDX+4]
  OR    BX, WORD PTR [EAX+4]
  MOV   WORD PTR [ECX+4], BX
  MOV   BL, BYTE PTR [EDX+6]
  OR    BL, BYTE PTR [EAX+6]
  MOV   BYTE PTR [ECX+6], BL
  ADD   EAX, 7
  ADD   EDX, 7
  ADD   ECX, 7
  JMP   @@Aligned
@@6Bytes:
  MOV   EBX, [EDX]
  OR    EBX, [EAX]
  MOV   [ECX], EBX
  MOV   BX, WORD PTR [EDX+4]
  OR    BX, WORD PTR [EAX+4]
  MOV   WORD PTR [ECX+4], BX
  ADD   EAX, 6
  ADD   EDX, 6
  ADD   ECX, 6
  JMP   @@Aligned
@@5Bytes:
  MOV   EBX, [EDX]
  OR    EBX, [EAX]
  MOV   [ECX], EBX
  MOV   BL, BYTE PTR [EDX+5]
  OR    BL, BYTE PTR [EAX+5]
  MOV   BYTE PTR [ECX+5], BL
  ADD   EAX, 5
  ADD   EDX, 5
  ADD   ECX, 5
  JMP   @@Aligned
@@4Bytes:
  MOV   EBX, [EDX]
  OR    EBX, [EAX]
  MOV   [ECX], EBX
  ADD   EAX, 4
  ADD   EDX, 4
  ADD   ECX, 4
  JMP   @@Aligned
@@3Bytes:
  MOV   BL, BYTE PTR [EDX+2]
  OR    BL, BYTE PTR [EAX+2]
  MOV   BYTE PTR [ECX+2], BL
  MOV   BX, WORD PTR [EDX]
  OR    BX, WORD PTR [EAX]
  MOV   WORD PTR [ECX], BX
  ADD   EAX, 3
  ADD   EDX, 3
  ADD   ECX, 3
  JMP   @@Aligned
@@2Bytes:
  MOV   BX, WORD PTR [EDX]
  OR    BX, WORD PTR [EAX]
  MOV   WORD PTR [ECX], BX
  ADD   EAX, 2
  ADD   EDX, 2
  ADD   ECX, 2
  JMP   @@Aligned
@@1Byte:
  MOV   BL, BYTE PTR [EDX]
  OR    BL, BYTE PTR [EAX]
  MOV   BYTE PTR [ECX], BL
  INC   EAX
  INC   EDX
  INC   ECX
  JMP   @@Aligned
@@Exit:
  EMMS
  POP   ESI
  POP   EBX
end;

procedure AndBuffersMMX(const xSrc1, xSrc2; var xDest; iCount: Integer);
asm
  {
    EAX = xSrc1
    EDX = xSrc2
    ECX = xDest
    [EBP+8] = iCount
  }
  CMP   iCount, 512
  JAE   @@UseMMX
  POP   EBP
  JMP   AndBuffersBlended { Blended version }
@@UseMMX:
  { MMX Version }
  PUSH  EBX
  PUSH  ESI

  MOV   ESI, iCount
  MOV   EBX, ESI
  AND   EBX, 7
  SHR   ESI, 3
  JMP   DWORD PTR [@@JumpTable+EBX*4]
@@JumpTable:
  DD    @@Aligned, @@1Byte, @@2Bytes, @@3Bytes, @@4Bytes, @@5Bytes, @@6Bytes, @@7Bytes
@@Aligned:
  DEC   ESI
  JS    @@Exit
  LEA   EBX, [ESI+1]
  AND   EBX, 3
  JMP   DWORD PTR [@@MMXTable+EBX*4]
@@MMXTable:
  DD    @@Start, @@MMX_8, @@MMX_16, @@MMX_24
@@Start:
  LEA   ESI, [ESI*8]
@@Loop:
  MOVQ  MM0, [EDX+ESI]
  MOVQ  MM1, [EDX+ESI-8]
  PAND  MM0, [EAX+ESI]
  PAND  MM1, [EAX+ESI-8]
  MOVQ  [ECX+ESI], MM0
  MOVQ  [ECX+ESI-8], MM1
  MOVQ  MM0, [EDX+ESI-16]
  MOVQ  MM1, [EDX+ESI-24]
  PAND  MM0, [EAX+ESI-16]
  PAND  MM1, [EAX+ESI-24]
  MOVQ  [ECX+ESI-16], MM0
  MOVQ  [ECX+ESI-24], MM1
  SUB   ESI, 32
  JNS   @@Loop
  JMP   @@Exit
@@MMX_8:
  MOVQ  MM0, [EDX+ESI*8]
  PAND  MM0, [EAX+ESI*8]
  MOVQ  [ECX+ESI*8], MM0
  DEC   ESI
  JMP   @@Start
@@MMX_16:
  LEA   EBX, [ESI*8]
  MOVQ  MM0, [EDX+EBX]
  MOVQ  MM1, [EDX+EBX-8]
  PAND  MM0, [EAX+EBX]
  PAND  MM1, [EAX+EBX-8]
  MOVQ  [ECX+EBX], MM0
  MOVQ  [ECX+EBX-8], MM1
  SUB   ESI, 2
  JMP   @@Start
@@MMX_24:
  LEA   EBX, [ESI*8]
  MOVQ  MM0, [EDX+EBX]
  MOVQ  MM1, [EDX+EBX-8]
  MOVQ  MM2, [EDX+EBX-16]
  PAND  MM0, [EAX+EBX]
  PAND  MM1, [EAX+EBX-8]
  PAND  MM2, [EAX+EBX-16]
  MOVQ  [ECX+EBX], MM0
  MOVQ  [ECX+EBX-8], MM1
  MOVQ  [ECX+EBX-16], MM2
  SUB   ESI, 3
  JMP   @@Start
@@7Bytes:
  MOV   EBX, [EDX]
  AND   EBX, [EAX]
  MOV   [ECX], EBX
  MOV   BX, WORD PTR [EDX+4]
  AND   BX, WORD PTR [EAX+4]
  MOV   WORD PTR [ECX+4], BX
  MOV   BL, BYTE PTR [EDX+6]
  AND   BL, BYTE PTR [EAX+6]
  MOV   BYTE PTR [ECX+6], BL
  ADD   EAX, 7
  ADD   EDX, 7
  ADD   ECX, 7
  JMP   @@Aligned
@@6Bytes:
  MOV   EBX, [EDX]
  AND   EBX, [EAX]
  MOV   [ECX], EBX
  MOV   BX, WORD PTR [EDX+4]
  AND   BX, WORD PTR [EAX+4]
  MOV   WORD PTR [ECX+4], BX
  ADD   EAX, 6
  ADD   EDX, 6
  ADD   ECX, 6
  JMP   @@Aligned
@@5Bytes:
  MOV   EBX, [EDX]
  AND   EBX, [EAX]
  MOV   [ECX], EBX
  MOV   BL, BYTE PTR [EDX+5]
  AND   BL, BYTE PTR [EAX+5]
  MOV   BYTE PTR [ECX+5], BL
  ADD   EAX, 5
  ADD   EDX, 5
  ADD   ECX, 5
  JMP   @@Aligned
@@4Bytes:
  MOV   EBX, [EDX]
  AND   EBX, [EAX]
  MOV   [ECX], EBX
  ADD   EAX, 4
  ADD   EDX, 4
  ADD   ECX, 4
  JMP   @@Aligned
@@3Bytes:
  MOV   BL, BYTE PTR [EDX+2]
  AND   BL, BYTE PTR [EAX+2]
  MOV   BYTE PTR [ECX+2], BL
  MOV   BX, WORD PTR [EDX]
  AND   BX, WORD PTR [EAX]
  MOV   WORD PTR [ECX], BX
  ADD   EAX, 3
  ADD   EDX, 3
  ADD   ECX, 3
  JMP   @@Aligned
@@2Bytes:
  MOV   BX, WORD PTR [EDX]
  AND   BX, WORD PTR [EAX]
  MOV   WORD PTR [ECX], BX
  ADD   EAX, 2
  ADD   EDX, 2
  ADD   ECX, 2
  JMP   @@Aligned
@@1Byte:
  MOV   BL, BYTE PTR [EDX]
  AND   BL, BYTE PTR [EAX]
  MOV   BYTE PTR [ECX], BL
  INC   EAX
  INC   EDX
  INC   ECX
  JMP   @@Aligned
@@Exit:
  EMMS
  POP   ESI
  POP   EBX
end;

procedure AndNotBuffersMMX(const xSrc1, xSrc2; var xDest; iCount: Integer);
asm
  {
    EAX = xSrc1
    EDX = xSrc2
    ECX = xDest
    [EBP+8] = iCount
  }
  CMP   iCount, 512
  JAE   @@UseMMX
  POP   EBP
  JMP   AndNotBuffersBlended { Blended version }
@@UseMMX:
  { MMX Version }
  PUSH  EBX
  PUSH  ESI

  MOV   ESI, iCount
  MOV   EBX, ESI
  AND   EBX, 7
  SHR   ESI, 3
  JMP   DWORD PTR [@@JumpTable+EBX*4]
@@JumpTable:
  DD    @@Aligned, @@1Byte, @@2Bytes, @@3Bytes, @@4Bytes, @@5Bytes, @@6Bytes, @@7Bytes
@@Aligned:
  DEC   ESI
  JS    @@Exit
  LEA   EBX, [ESI+1]
  AND   EBX, 3
  JMP   DWORD PTR [@@MMXTable+EBX*4]
@@MMXTable:
  DD    @@Start, @@MMX_8, @@MMX_16, @@MMX_24
@@Start:
  LEA   ESI, [ESI*8]
@@Loop:
  MOVQ  MM0, [EDX+ESI]
  MOVQ  MM1, [EDX+ESI-8]
  PANDN MM0, [EAX+ESI]
  PANDN MM1, [EAX+ESI-8]
  MOVQ  [ECX+ESI], MM0
  MOVQ  [ECX+ESI-8], MM1
  MOVQ  MM0, [EDX+ESI-16]
  MOVQ  MM1, [EDX+ESI-24]
  PANDN MM0, [EAX+ESI-16]
  PANDN MM1, [EAX+ESI-24]
  MOVQ  [ECX+ESI-16], MM0
  MOVQ  [ECX+ESI-24], MM1
  SUB   ESI, 32
  JNS   @@Loop
  JMP   @@Exit
@@MMX_8:
  MOVQ  MM0, [EDX+ESI*8]
  PANDN MM0, [EAX+ESI*8]
  MOVQ  [ECX+ESI*8], MM0
  DEC   ESI
  JMP   @@Start
@@MMX_16:
  LEA   EBX, [ESI*8]
  MOVQ  MM0, [EDX+EBX]
  MOVQ  MM1, [EDX+EBX-8]
  PANDN MM0, [EAX+EBX]
  PANDN MM1, [EAX+EBX-8]
  MOVQ  [ECX+EBX], MM0
  MOVQ  [ECX+EBX-8], MM1
  SUB   ESI, 2
  JMP   @@Start
@@MMX_24:
  LEA   EBX, [ESI*8]
  MOVQ  MM0, [EDX+EBX]
  MOVQ  MM1, [EDX+EBX-8]
  MOVQ  MM2, [EDX+EBX-16]
  PANDN MM0, [EAX+EBX]
  PANDN MM1, [EAX+EBX-8]
  PANDN MM2, [EAX+EBX-16]
  MOVQ  [ECX+EBX], MM0
  MOVQ  [ECX+EBX-8], MM1
  MOVQ  [ECX+EBX-16], MM2
  SUB   ESI, 3
  JMP   @@Start
@@7Bytes:
  MOV   EBX, [EDX]
  NOT   EBX
  AND   EBX, [EAX]
  MOV   [ECX], EBX
  MOV   BX, WORD PTR [EDX+4]
  NOT   BX
  AND   BX, WORD PTR [EAX+4]
  MOV   WORD PTR [ECX+4], BX
  MOV   BL, BYTE PTR [EDX+6]
  NOT   BL
  AND   BL, BYTE PTR [EAX+6]
  MOV   BYTE PTR [ECX+6], BL
  ADD   EAX, 7
  ADD   EDX, 7
  ADD   ECX, 7
  JMP   @@Aligned
@@6Bytes:
  MOV   EBX, [EDX]
  NOT   EBX
  AND   EBX, [EAX]
  MOV   [ECX], EBX
  MOV   BX, WORD PTR [EDX+4]
  NOT   BX
  AND   BX, WORD PTR [EAX+4]
  MOV   WORD PTR [ECX+4], BX
  ADD   EAX, 6
  ADD   EDX, 6
  ADD   ECX, 6
  JMP   @@Aligned
@@5Bytes:
  MOV   EBX, [EDX]
  NOT   EBX
  AND   EBX, [EAX]
  MOV   [ECX], EBX
  MOV   BL, BYTE PTR [EDX+5]
  NOT   BL
  AND   BL, BYTE PTR [EAX+5]
  MOV   BYTE PTR [ECX+5], BL
  ADD   EAX, 5
  ADD   EDX, 5
  ADD   ECX, 5
  JMP   @@Aligned
@@4Bytes:
  MOV   EBX, [EDX]
  NOT   EBX
  AND   EBX, [EAX]
  MOV   [ECX], EBX
  ADD   EAX, 4
  ADD   EDX, 4
  ADD   ECX, 4
  JMP   @@Aligned
@@3Bytes:
  MOV   BL, BYTE PTR [EDX+2]
  NOT   BL
  AND   BL, BYTE PTR [EAX+2]
  MOV   BYTE PTR [ECX+2], BL
  MOV   BX, WORD PTR [EDX]
  NOT   BX
  AND   BX, WORD PTR [EAX]
  MOV   WORD PTR [ECX], BX
  ADD   EAX, 3
  ADD   EDX, 3
  ADD   ECX, 3
  JMP   @@Aligned
@@2Bytes:
  MOV   BX, WORD PTR [EDX]
  NOT   BX
  AND   BX, WORD PTR [EAX]
  MOV   WORD PTR [ECX], BX
  ADD   EAX, 2
  ADD   EDX, 2
  ADD   ECX, 2
  JMP   @@Aligned
@@1Byte:
  MOV   BL, BYTE PTR [EDX]
  NOT   BL
  AND   BL, BYTE PTR [EAX]
  MOV   BYTE PTR [ECX], BL
  INC   EAX
  INC   EDX
  INC   ECX
  JMP   @@Aligned
@@Exit:
  EMMS
  POP   ESI
  POP   EBX
end;

procedure NotBufferMMX(const xSrc; var xDest; iCount: Integer);
const
  NotTable: array[0..1] of Longword = ($FFFFFFFF, $FFFFFFFF);
asm
  {
    EAX = xSrc
    EDX = xDest
    ECX = iCount
  }
  CMP   iCount, 512
  JL    NotBufferBlended { Blended version }

  { MMX version }
  PUSH  EBX
  MOV   EBX, ECX
  SHR   ECX, 3
  AND   EBX, 7
  JMP   DWORD PTR [@@JumpTable+EBX*4]
@@JumpTable:
  DD    @@Aligned, @@1Byte, @@2Bytes, @@3Bytes, @@4Bytes, @@5Bytes, @@6Bytes, @@7Bytes
@@Aligned:
  DEC   ECX
  JS    @@Exit
  MOVQ  MM0, NotTable
  LEA   EBX, [ECX+1]
  AND   EBX, 3
  JMP   DWORD PTR [@@MMXTable+EBX*4]
@@MMXTable:
  DD    @@Start, @@MMX_8, @@MMX_16, @@MMX_24
@@Start:
  LEA   ECX, [ECX*8]
@@Loop:
  MOVQ  MM1, [EAX+ECX]
  MOVQ  MM2, [EAX+ECX-8]
  PXOR  MM1, MM0
  PXOR  MM2, MM0
  MOVQ  [EDX+ECX], MM1
  MOVQ  [EDX+ECX-8], MM2
  MOVQ  MM3, [EAX+ECX-16]
  MOVQ  MM4, [EAX+ECX-24]
  PXOR  MM3, MM0
  PXOR  MM4, MM0
  MOVQ  [EDX+ECX-16], MM3
  MOVQ  [EDX+ECX-24], MM4
  SUB   ECX, 32
  JNS   @@Loop
@@Exit:
  EMMS
  POP   EBX
  RET
@@MMX_8:
  MOVQ  MM1, [EAX+ECX*8]
  PXOR  MM1, MM0
  MOVQ  [EDX+ECX*8], MM1
  DEC   ECX
  JMP   @@Start
@@MMX_16:
  LEA   EBX, [ECX*8]
  MOVQ  MM1, [EAX+EBX]
  MOVQ  MM2, [EAX+EBX-8]
  PXOR  MM1, MM0
  PXOR  MM2, MM0
  MOVQ  [EDX+EBX], MM1
  MOVQ  [EDX+EBX-8], MM2
  SUB   ECX, 2
  JMP   @@Start
@@MMX_24:
  LEA   EBX, [ECX*8]
  MOVQ  MM1, [EAX+EBX]
  MOVQ  MM2, [EAX+EBX-8]
  MOVQ  MM3, [EAX+EBX-16]
  PXOR  MM1, MM0
  PXOR  MM2, MM0
  PXOR  MM3, MM0
  MOVQ  [EDX+EBX], MM1
  MOVQ  [EDX+EBX-8], MM2
  MOVQ  [EDX+EBX-16], MM3
  SUB   ECX, 3
  JMP   @@Start
@@7Bytes:
  MOV   EBX, [EAX]
  NOT   EBX
  MOV   [EDX], EBX
  MOV   BX, WORD PTR [EAX+4]
  NOT   BX
  MOV   WORD PTR [EDX+4], BX
  MOV   BL, BYTE PTR [EAX+6]
  NOT   BL
  MOV   BYTE PTR [EDX+6], BL
  ADD   EAX, 7
  ADD   EDX, 7
  JMP   @@Aligned
@@6Bytes:
  MOV   EBX, [EAX]
  NOT   EBX
  MOV   [EDX], EBX
  MOV   BX, WORD PTR [EAX+4]
  NOT   BX
  MOV   WORD PTR [EDX+4], BX
  ADD   EAX, 6
  ADD   EDX, 6
  JMP   @@Aligned
@@5Bytes:
  MOV   EBX, [EAX]
  NOT   EBX
  MOV   [EDX], EBX
  MOV   BL, BYTE PTR [EAX+5]
  NOT   BL
  MOV   BYTE PTR [EDX+5], BL
  ADD   EAX, 5
  ADD   EDX, 5
  JMP   @@Aligned
@@4Bytes:
  MOV   EBX, [EAX]
  NOT   EBX
  MOV   [EDX], EBX
  ADD   EAX, 4
  ADD   EDX, 4
  JMP   @@Aligned
@@3Bytes:
  MOV   BL, BYTE PTR [EAX+2]
  NOT   BL
  MOV   BYTE PTR [EDX+2], BL
  MOV   BX, WORD PTR [EAX]
  NOT   BX
  MOV   WORD PTR [EDX], BX
  ADD   EAX, 3
  ADD   EDX, 3
  JMP   @@Aligned
@@2Bytes:
  MOV   BX, WORD PTR [EAX]
  NOT   BX
  MOV   WORD PTR [EDX], BX
  ADD   EAX, 2
  ADD   EDX, 2
  JMP   @@Aligned
@@1Byte:
  MOV   BL, BYTE PTR [EAX]
  NOT   BL
  MOV   BYTE PTR [EDX], BL
  INC   EAX
  INC   EDX
  JMP   @@Aligned
end;

function UInt32ToStr(lwValue: Longword): string;
asm
  PUSH EBX
  PUSH EDI
  PUSH ESI

  MOV  EBX, EAX
  MOV  EDI, EDX
  MOV  ESI, EDX
  MOV  EAX, EDX
  MOV  ECX, $0A
  XOR  EDX, EDX
  CALL System.@LStrFromPCharLen
  MOV  ESI, EDI
  MOV  EDI, [EDI]
  MOV  EAX, EBX
  MOV  ECX, EAX
  MOV  EDX, $89705F41
  MUL  EDX
  ADD  EAX, EAX
  ADC  EDX, 0
  SHR  EDX, 29
  MOV  EAX, EDX
  MOV  EBX, EDX
  IMUL EAX, 1000000000
  SUB  ECX, EAX
  OR   DL, '0'
  MOV  [EDI], DL
  CMP  EBX, 1
  SBB  EDI, -1
  MOV  EAX, ECX
  MOV  EDX, $ABCC7712
  MUL  EDX
  SHR  EAX, 30
  LEA  EDX, [EAX+EDX*4+1]
  MOV  EAX, EDX
  SHR  EAX, 28
  AND  EDX, $0FFFFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 27
  AND  EDX, $07FFFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 26
  AND  EDX, $03FFFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 25
  AND  EDX, $01FFFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 24
  AND  EDX, $00FFFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 23
  AND  EDX, $007FFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 22
  AND  EDX, $003FFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 21
  AND  EDX, $001FFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  MOV  ECX, [ESI]
  SHR  EAX, 20
  OR   EAX, '0'
  NEG  ECX
  MOV  [EDI], AL
  MOV  EAX, [ESI]
  LEA  EDX, [EDI+ECX+1]
  MOV  [EAX-4], EDX

  POP  ESI
  POP  EDI
  POP  EBX
end;

function Int32ToStr(iValue: Integer): string;
asm
  PUSH EBX
  PUSH EDI
  PUSH ESI

  MOV  EBX, EAX
  MOV  EDI, EDX
  MOV  ESI, EDX
  MOV  EAX, EDX
  MOV  ECX, $0B
  XOR  EDX, EDX
  CALL System.@LStrFromPCharLen
  MOV  ESI, EDI
  MOV  EAX, EBX
  MOV  EDI, [EDI]
  OR   EAX, EBX
  JNS  @@NoSign
  MOV  [EDI], '-'
  NEG  EAX
  INC  EDI
@@NoSign:
  MOV  ECX, EAX
  MOV  EDX, $89705F41
  MUL  EDX
  ADD  EAX, EAX
  ADC  EDX, 0
  SHR  EDX, 29
  MOV  EAX, EDX
  MOV  EBX, EDX
  IMUL EAX, 1000000000
  SUB  ECX, EAX
  OR   DL, '0'
  MOV  [EDI], DL
  CMP  EBX, 1
  SBB  EDI, -1
  MOV  EAX, ECX
  MOV  EDX, $ABCC7712
  MUL  EDX
  SHR  EAX, 30
  LEA  EDX, [EAX+EDX*4+1]
  MOV  EAX, EDX
  SHR  EAX, 28
  AND  EDX, $0FFFFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 27
  AND  EDX, $07FFFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 26
  AND  EDX, $03FFFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 25
  AND  EDX, $01FFFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 24
  AND  EDX, $00FFFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 23
  AND  EDX, $007FFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 22
  AND  EDX, $003FFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 21
  AND  EDX, $001FFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  MOV  ECX, [ESI]
  SHR  EAX, 20
  OR   EAX, '0'
  NEG  ECX
  MOV  [EDI], AL
  MOV  EAX, [ESI]
  LEA  EDX, [EDI+ECX+1]
  MOV  [EAX-4], EDX

  POP  ESI
  POP  EDI
  POP  EBX
end;

function UInt16ToStr(wValue: Word): string;
asm
  PUSH EBX
  PUSH EDI
  PUSH ESI

  MOVZX EBX, AX
  MOV  EDI, EDX
  MOV  ESI, EDX
  MOV  EAX, EDX
  MOV  ECX, $0A
  XOR  EDX, EDX
  CALL System.@LStrFromPCharLen
  MOV  ESI, EDI
  MOV  EDI, [EDI]
  MOV  EAX, EBX
  MOV  ECX, EAX
  MOV  EDX, $89705F41
  MUL  EDX
  ADD  EAX, EAX
  ADC  EDX, 0
  SHR  EDX, 29
  MOV  EAX, EDX
  MOV  EBX, EDX
  IMUL EAX, 1000000000
  SUB  ECX, EAX
  OR   DL, '0'
  MOV  [EDI], DL
  CMP  EBX, 1
  SBB  EDI, -1
  MOV  EAX, ECX
  MOV  EDX, $ABCC7712
  MUL  EDX
  SHR  EAX, 30
  LEA  EDX, [EAX+EDX*4+1]
  MOV  EAX, EDX
  SHR  EAX, 28
  AND  EDX, $0FFFFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 27
  AND  EDX, $07FFFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 26
  AND  EDX, $03FFFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 25
  AND  EDX, $01FFFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 24
  AND  EDX, $00FFFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 23
  AND  EDX, $007FFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 22
  AND  EDX, $003FFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  LEA  EDX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  SHR  EAX, 21
  AND  EDX, $001FFFFF
  OR   EBX, EAX
  OR   EAX, '0'
  MOV  [EDI], AL
  LEA  EAX, [EDX*4+EDX]
  CMP  EBX, 1
  SBB  EDI, -1
  MOV  ECX, [ESI]
  SHR  EAX, 20
  OR   EAX, '0'
  NEG  ECX
  MOV  [EDI], AL
  MOV  EAX, [ESI]
  LEA  EDX, [EDI+ECX+1]
  MOV  [EAX-4], EDX

  POP  ESI
  POP  EDI
  POP  EBX
end;

var
  CacheLimit: Integer;

const
  TINYSIZE = 36;

procedure SmallForwardMove;
asm
  jmp     dword ptr [@@FwdJumpTable+ecx*4]
  nop {Align Jump Table}
@@FwdJumpTable:
  dd      @@Done {Removes need to test for zero size move}
  dd      @@Fwd01, @@Fwd02, @@Fwd03, @@Fwd04, @@Fwd05, @@Fwd06, @@Fwd07, @@Fwd08
  dd      @@Fwd09, @@Fwd10, @@Fwd11, @@Fwd12, @@Fwd13, @@Fwd14, @@Fwd15, @@Fwd16
  dd      @@Fwd17, @@Fwd18, @@Fwd19, @@Fwd20, @@Fwd21, @@Fwd22, @@Fwd23, @@Fwd24
  dd      @@Fwd25, @@Fwd26, @@Fwd27, @@Fwd28, @@Fwd29, @@Fwd30, @@Fwd31, @@Fwd32
  dd      @@Fwd33, @@Fwd34, @@Fwd35, @@Fwd36
@@Fwd36:
  mov     ecx, [eax-36]
  mov     [edx-36], ecx
@@Fwd32:
  mov     ecx, [eax-32]
  mov     [edx-32], ecx
@@Fwd28:
  mov     ecx, [eax-28]
  mov     [edx-28], ecx
@@Fwd24:
  mov     ecx, [eax-24]
  mov     [edx-24], ecx
@@Fwd20:
  mov     ecx, [eax-20]
  mov     [edx-20], ecx
@@Fwd16:
  mov     ecx, [eax-16]
  mov     [edx-16], ecx
@@Fwd12:
  mov     ecx, [eax-12]
  mov     [edx-12], ecx
@@Fwd08:
  mov     ecx, [eax-8]
  mov     [edx-8], ecx
@@Fwd04:
  mov     ecx, [eax-4]
  mov     [edx-4], ecx
  ret
  nop
@@Fwd35:
  mov     ecx, [eax-35]
  mov     [edx-35], ecx
@@Fwd31:
  mov     ecx, [eax-31]
  mov     [edx-31], ecx
@@Fwd27:
  mov     ecx, [eax-27]
  mov     [edx-27], ecx
@@Fwd23:
  mov     ecx, [eax-23]
  mov     [edx-23], ecx
@@Fwd19:
  mov     ecx, [eax-19]
  mov     [edx-19], ecx
@@Fwd15:
  mov     ecx, [eax-15]
  mov     [edx-15], ecx
@@Fwd11:
  mov     ecx, [eax-11]
  mov     [edx-11], ecx
@@Fwd07:
  mov     ecx, [eax-7]
  mov     [edx-7], ecx
  mov     ecx, [eax-4]
  mov     [edx-4], ecx
  ret
  nop
@@Fwd03:
  movzx   ecx, word ptr [eax-3]
  mov     [edx-3], cx
  movzx   ecx, byte ptr [eax-1]
  mov     [edx-1], cl
  ret
@@Fwd34:
  mov     ecx, [eax-34]
  mov     [edx-34], ecx
@@Fwd30:
  mov     ecx, [eax-30]
  mov     [edx-30], ecx
@@Fwd26:
  mov     ecx, [eax-26]
  mov     [edx-26], ecx
@@Fwd22:
  mov     ecx, [eax-22]
  mov     [edx-22], ecx
@@Fwd18:
  mov     ecx, [eax-18]
  mov     [edx-18], ecx
@@Fwd14:
  mov     ecx, [eax-14]
  mov     [edx-14], ecx
@@Fwd10:
  mov     ecx, [eax-10]
  mov     [edx-10], ecx
@@Fwd06:
  mov     ecx, [eax-6]
  mov     [edx-6], ecx
@@Fwd02:
  movzx   ecx, word ptr [eax-2]
  mov     [edx-2], cx
  ret
  nop
  nop
  nop
@@Fwd33:
  mov     ecx, [eax-33]
  mov     [edx-33], ecx
@@Fwd29:
  mov     ecx, [eax-29]
  mov     [edx-29], ecx
@@Fwd25:
  mov     ecx, [eax-25]
  mov     [edx-25], ecx
@@Fwd21:
  mov     ecx, [eax-21]
  mov     [edx-21], ecx
@@Fwd17:
  mov     ecx, [eax-17]
  mov     [edx-17], ecx
@@Fwd13:
  mov     ecx, [eax-13]
  mov     [edx-13], ecx
@@Fwd09:
  mov     ecx, [eax-9]
  mov     [edx-9], ecx
@@Fwd05:
  mov     ecx, [eax-5]
  mov     [edx-5], ecx
@@Fwd01:
  movzx   ecx, byte ptr [eax-1]
  mov     [edx-1], cl
  ret
@@Done:
end;

{-------------------------------------------------------------------------}
{Perform Backward Move of 0..36 Bytes}
{On Entry, ECX = Count, EAX = Source, EDX = Dest.  Destroys ECX}
procedure SmallBackwardMove;
asm
  jmp     dword ptr [@@BwdJumpTable+ecx*4]
  nop {Align Jump Table}
@@BwdJumpTable:
  dd      @@Done {Removes need to test for zero size move}
  dd      @@Bwd01, @@Bwd02, @@Bwd03, @@Bwd04, @@Bwd05, @@Bwd06, @@Bwd07, @@Bwd08
  dd      @@Bwd09, @@Bwd10, @@Bwd11, @@Bwd12, @@Bwd13, @@Bwd14, @@Bwd15, @@Bwd16
  dd      @@Bwd17, @@Bwd18, @@Bwd19, @@Bwd20, @@Bwd21, @@Bwd22, @@Bwd23, @@Bwd24
  dd      @@Bwd25, @@Bwd26, @@Bwd27, @@Bwd28, @@Bwd29, @@Bwd30, @@Bwd31, @@Bwd32
  dd      @@Bwd33, @@Bwd34, @@Bwd35, @@Bwd36
@@Bwd36:
  mov     ecx, [eax+32]
  mov     [edx+32], ecx
@@Bwd32:
  mov     ecx, [eax+28]
  mov     [edx+28], ecx
@@Bwd28:
  mov     ecx, [eax+24]
  mov     [edx+24], ecx
@@Bwd24:
  mov     ecx, [eax+20]
  mov     [edx+20], ecx
@@Bwd20:
  mov     ecx, [eax+16]
  mov     [edx+16], ecx
@@Bwd16:
  mov     ecx, [eax+12]
  mov     [edx+12], ecx
@@Bwd12:
  mov     ecx, [eax+8]
  mov     [edx+8], ecx
@@Bwd08:
  mov     ecx, [eax+4]
  mov     [edx+4], ecx
@@Bwd04:
  mov     ecx, [eax]
  mov     [edx], ecx
  ret
  nop
  nop
  nop
@@Bwd35:
  mov     ecx, [eax+31]
  mov     [edx+31], ecx
@@Bwd31:
  mov     ecx, [eax+27]
  mov     [edx+27], ecx
@@Bwd27:
  mov     ecx, [eax+23]
  mov     [edx+23], ecx
@@Bwd23:
  mov     ecx, [eax+19]
  mov     [edx+19], ecx
@@Bwd19:
  mov     ecx, [eax+15]
  mov     [edx+15], ecx
@@Bwd15:
  mov     ecx, [eax+11]
  mov     [edx+11], ecx
@@Bwd11:
  mov     ecx, [eax+7]
  mov     [edx+7], ecx
@@Bwd07:
  mov     ecx, [eax+3]
  mov     [edx+3], ecx
  mov     ecx, [eax]
  mov     [edx], ecx
  ret
  nop
  nop
  nop
@@Bwd03:
  movzx   ecx, word ptr [eax+1]
  mov     [edx+1], cx
  movzx   ecx, byte ptr [eax]
  mov     [edx], cl
  ret
  nop
  nop
@@Bwd34:
  mov     ecx, [eax+30]
  mov     [edx+30], ecx
@@Bwd30:
  mov     ecx, [eax+26]
  mov     [edx+26], ecx
@@Bwd26:
  mov     ecx, [eax+22]
  mov     [edx+22], ecx
@@Bwd22:
  mov     ecx, [eax+18]
  mov     [edx+18], ecx
@@Bwd18:
  mov     ecx, [eax+14]
  mov     [edx+14], ecx
@@Bwd14:
  mov     ecx, [eax+10]
  mov     [edx+10], ecx
@@Bwd10:
  mov     ecx, [eax+6]
  mov     [edx+6], ecx
@@Bwd06:
  mov     ecx, [eax+2]
  mov     [edx+2], ecx
@@Bwd02:
  movzx   ecx, word ptr [eax]
  mov     [edx], cx
  ret
  nop
@@Bwd33:
  mov     ecx, [eax+29]
  mov     [edx+29], ecx
@@Bwd29:
  mov     ecx, [eax+25]
  mov     [edx+25], ecx
@@Bwd25:
  mov     ecx, [eax+21]
  mov     [edx+21], ecx
@@Bwd21:
  mov     ecx, [eax+17]
  mov     [edx+17], ecx
@@Bwd17:
  mov     ecx, [eax+13]
  mov     [edx+13], ecx
@@Bwd13:
  mov     ecx, [eax+9]
  mov     [edx+9], ecx
@@Bwd09:
  mov     ecx, [eax+5]
  mov     [edx+5], ecx
@@Bwd05:
  mov     ecx, [eax+1]
  mov     [edx+1], ecx
@@Bwd01:
  movzx   ecx, byte ptr[eax]
  mov     [edx], cl
  ret
@@Done:
end;

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX > EDX and ECX > 36 (TINYSIZE)}
procedure Forwards_IA32;
asm
  fild    qword ptr [eax] {First 8}
  lea     eax, [eax+ecx-8]
  lea     ecx, [edx+ecx-8]
  push    edx
  push    ecx
  fild    qword ptr [eax] {Last 8}
  neg     ecx {QWORD Align Writes}
  and     edx, -8
  lea     ecx, [ecx+edx+8]
  pop     edx
@@Loop:
  fild    qword ptr [eax+ecx]
  fistp   qword ptr [edx+ecx]
  add     ecx, 8
  jl      @@Loop
  pop     eax
  fistp   qword ptr [edx] {Last 8}
  fistp   qword ptr [eax] {First 8}
end; 

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX < EDX and ECX > 36 (TINYSIZE)}
procedure Backwards_IA32;
asm
  sub     ecx, 8
  fild    qword ptr [eax+ecx] {Last 8}
  fild    qword ptr [eax] {First 8}
  add     ecx, edx {QWORD Align Writes}
  push    ecx
  and     ecx, -8
  sub     ecx, edx
@@Loop:
  fild    qword ptr [eax+ecx]
  fistp   qword ptr [edx+ecx]
  sub     ecx, 8
  jg      @@Loop
  pop     eax
  fistp   qword ptr [edx] {First 8}
  fistp   qword ptr [eax] {Last 8}
end;


{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX > EDX and ECX > 36 (TINYSIZE)}
procedure Forwards_MMX;
const
  SMALLSIZE = 64;
  LARGESIZE = 2048;
asm
  cmp     ecx, SMALLSIZE {Size at which using MMX becomes worthwhile}
  jl      Forwards_IA32
  cmp     ecx, LARGESIZE
  jge     @@FwdLargeMove
  push    ebx
  mov     ebx, edx
  movq    mm0, [eax] {First 8 Bytes}
  add     eax, ecx {QWORD Align Writes}
  add     ecx, edx
  and     edx, -8
  add     edx, 40
  sub     ecx, edx
  add     edx, ecx
  neg     ecx
  nop {Align Loop}
@@FwdLoopMMX:
  movq    mm1, [eax+ecx-32]
  movq    mm2, [eax+ecx-24]
  movq    mm3, [eax+ecx-16]
  movq    mm4, [eax+ecx- 8]
  movq    [edx+ecx-32], mm1
  movq    [edx+ecx-24], mm2
  movq    [edx+ecx-16], mm3
  movq    [edx+ecx- 8], mm4
  add     ecx, 32
  jle     @@FwdLoopMMX
  movq    [ebx], mm0 {First 8 Bytes}
  emms
  pop     ebx
  neg     ecx
  add     ecx, 32
  jmp     SmallForwardMove
  nop {Align Loop}
  nop
@@FwdLargeMove:
  push    ebx
  mov     ebx, ecx
  test    edx, 15
  jz      @@FwdAligned
  lea     ecx, [edx+15] {16 byte Align Destination}
  and     ecx, -16
  sub     ecx, edx
  add     eax, ecx
  add     edx, ecx
  sub     ebx, ecx
  call    SmallForwardMove
@@FwdAligned:
  mov     ecx, ebx
  and     ecx, -16
  sub     ebx, ecx {EBX = Remainder}
  push    esi
  push    edi
  mov     esi, eax          {ESI = Source}
  mov     edi, edx          {EDI = Dest}
  mov     eax, ecx          {EAX = Count}
  and     eax, -64          {EAX = No of Bytes to Blocks Moves}
  and     ecx, $3F          {ECX = Remaining Bytes to Move (0..63)}
  add     esi, eax
  add     edi, eax
  neg     eax
@@MMXcopyloop:
  movq    mm0, [esi+eax   ]
  movq    mm1, [esi+eax+ 8]
  movq    mm2, [esi+eax+16]
  movq    mm3, [esi+eax+24]
  movq    mm4, [esi+eax+32]
  movq    mm5, [esi+eax+40]
  movq    mm6, [esi+eax+48]
  movq    mm7, [esi+eax+56]
  movq    [edi+eax   ], mm0
  movq    [edi+eax+ 8], mm1
  movq    [edi+eax+16], mm2
  movq    [edi+eax+24], mm3
  movq    [edi+eax+32], mm4
  movq    [edi+eax+40], mm5
  movq    [edi+eax+48], mm6
  movq    [edi+eax+56], mm7
  add     eax, 64
  jnz     @@MMXcopyloop
  emms                   {Empty MMX State}
  add     ecx, ebx
  shr     ecx, 2
  rep     movsd
  mov     ecx, ebx
  and     ecx, 3
  rep     movsb
  pop     edi
  pop     esi
  pop     ebx
end;

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX < EDX and ECX > 36 (TINYSIZE)}
procedure Backwards_MMX;
const
  SMALLSIZE = 64;
asm
  cmp     ecx, SMALLSIZE {Size at which using MMX becomes worthwhile}
  jl      Backwards_IA32
  push    ebx
  movq    mm0, [eax+ecx-8] {Get Last QWORD}
  lea     ebx, [edx+ecx] {QWORD Align Writes}
  and     ebx, 7
  sub     ecx, ebx
  add     ebx, ecx
  sub     ecx, 32
@@BwdLoopMMX:
  movq    mm1, [eax+ecx   ]
  movq    mm2, [eax+ecx+ 8]
  movq    mm3, [eax+ecx+16]
  movq    mm4, [eax+ecx+24]
  movq    [edx+ecx+24], mm4
  movq    [edx+ecx+16], mm3
  movq    [edx+ecx+ 8], mm2
  movq    [edx+ecx   ], mm1
  sub     ecx, 32
  jge     @@BwdLoopMMX
  movq    [edx+ebx-8], mm0 {Last QWORD}
  emms
  add     ecx, 32
  pop     ebx
  jmp     SmallBackwardMove
end;

{-------------------------------------------------------------------------}
procedure LargeAlignedSSEMove;
asm
@@Loop:
  movaps  xmm0, [eax+ecx]
  movaps  xmm1, [eax+ecx+16]
  movaps  xmm2, [eax+ecx+32]
  movaps  xmm3, [eax+ecx+48]
  movaps  [edx+ecx], xmm0 
  movaps  [edx+ecx+16], xmm1
  movaps  [edx+ecx+32], xmm2
  movaps  [edx+ecx+48], xmm3
  movaps  xmm4, [eax+ecx+64]
  movaps  xmm5, [eax+ecx+80]
  movaps  xmm6, [eax+ecx+96]
  movaps  xmm7, [eax+ecx+112]
  movaps  [edx+ecx+64], xmm4
  movaps  [edx+ecx+80], xmm5
  movaps  [edx+ecx+96], xmm6
  movaps  [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
end;

{-------------------------------------------------------------------------}
procedure LargeUnalignedSSEMove;
asm
@@Loop:
  movups  xmm0, [eax+ecx]
  movups  xmm1, [eax+ecx+16]
  movups  xmm2, [eax+ecx+32]
  movups  xmm3, [eax+ecx+48]
  movaps  [edx+ecx], xmm0
  movaps  [edx+ecx+16], xmm1
  movaps  [edx+ecx+32], xmm2
  movaps  [edx+ecx+48], xmm3
  movups  xmm4, [eax+ecx+64]
  movups  xmm5, [eax+ecx+80]
  movups  xmm6, [eax+ecx+96]
  movups  xmm7, [eax+ecx+112]
  movaps  [edx+ecx+64], xmm4
  movaps  [edx+ecx+80], xmm5
  movaps  [edx+ecx+96], xmm6
  movaps  [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
end;

{-------------------------------------------------------------------------}
procedure HugeAlignedSSEMove;
const
  Prefetch = 512;
asm
@@Loop:
  prefetchnta [eax+ecx+Prefetch]
  prefetchnta [eax+ecx+Prefetch+64]
  movaps  xmm0, [eax+ecx]
  movaps  xmm1, [eax+ecx+16]
  movaps  xmm2, [eax+ecx+32]
  movaps  xmm3, [eax+ecx+48]
  movntps [edx+ecx], xmm0
  movntps [edx+ecx+16], xmm1
  movntps [edx+ecx+32], xmm2
  movntps [edx+ecx+48], xmm3
  movaps  xmm4, [eax+ecx+64]
  movaps  xmm5, [eax+ecx+80]
  movaps  xmm6, [eax+ecx+96]
  movaps  xmm7, [eax+ecx+112]
  movntps [edx+ecx+64], xmm4
  movntps [edx+ecx+80], xmm5
  movntps [edx+ecx+96], xmm6
  movntps [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
  sfence
end;

{-------------------------------------------------------------------------}
procedure HugeUnalignedSSEMove;
const
  Prefetch = 512;
asm
@@Loop:
  prefetchnta [eax+ecx+Prefetch]
  prefetchnta [eax+ecx+Prefetch+64]
  movups  xmm0, [eax+ecx]
  movups  xmm1, [eax+ecx+16]
  movups  xmm2, [eax+ecx+32]
  movups  xmm3, [eax+ecx+48]
  movntps [edx+ecx], xmm0
  movntps [edx+ecx+16], xmm1
  movntps [edx+ecx+32], xmm2
  movntps [edx+ecx+48], xmm3
  movups  xmm4, [eax+ecx+64]
  movups  xmm5, [eax+ecx+80]
  movups  xmm6, [eax+ecx+96]
  movups  xmm7, [eax+ecx+112]
  movntps [edx+ecx+64], xmm4
  movntps [edx+ecx+80], xmm5
  movntps [edx+ecx+96], xmm6
  movntps [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
  sfence
end;

{-------------------------------------------------------------------------}
{Dest MUST be 16-Byes Aligned, Count MUST be multiple of 16 }
procedure LargeSSEMove;
asm
  push    ebx
  mov     ebx, ecx
  and     ecx, -128             {No of Bytes to Block Move (Multiple of 128)}
  add     eax, ecx              {End of Source Blocks}
  add     edx, ecx              {End of Dest Blocks}
  neg     ecx
  cmp     ecx, CacheLimit       {Count > Limit - Use Prefetch}
  jl      @@Huge
  test    eax, 15               {Check if Both Source/Dest are Aligned}
  jnz     @@LargeUnaligned
  call    LargeAlignedSSEMove   {Both Source and Dest 16-Byte Aligned}
  jmp     @@Remainder
@@LargeUnaligned:               {Source Not 16-Byte Aligned}
  call    LargeUnalignedSSEMove
  jmp     @@Remainder
@@Huge:
  test    eax, 15               {Check if Both Source/Dest Aligned}
  jnz     @@HugeUnaligned
  call    HugeAlignedSSEMove    {Both Source and Dest 16-Byte Aligned}
  jmp     @@Remainder
@@HugeUnaligned:                {Source Not 16-Byte Aligned}
  call    HugeUnalignedSSEMove
@@Remainder:
  and     ebx, $7F              {Remainder (0..112 - Multiple of 16)}
  jz      @@Done
  add     eax, ebx
  add     edx, ebx
  neg     ebx
@@RemainderLoop:
  movups  xmm0, [eax+ebx]
  movaps  [edx+ebx], xmm0
  add     ebx, 16
  jnz     @@RemainderLoop
@@Done:
  pop     ebx
end;

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX > EDX and ECX > 36 (TINYSIZE)}
procedure Forwards_SSE;
const
  SMALLSIZE = 64;
  LARGESIZE = 2048;
asm
  cmp     ecx, SMALLSIZE
  jle     Forwards_IA32
  push    ebx
  cmp     ecx, LARGESIZE
  jge     @@FwdLargeMove
  movups  xmm0, [eax] {First 16 Bytes}
  mov     ebx, edx
  add     eax, ecx {Align Writes}
  add     ecx, edx
  and     edx, -16
  add     edx, 48
  sub     ecx, edx
  add     edx, ecx
  neg     ecx
  nop {Align Loop}
@@FwdLoopSSE:
  movups  xmm1, [eax+ecx-32]
  movups  xmm2, [eax+ecx-16]
  movaps  [edx+ecx-32], xmm1
  movaps  [edx+ecx-16], xmm2
  add     ecx, 32
  jle     @@FwdLoopSSE
  movups  [ebx], xmm0 {First 16 Bytes}
  neg     ecx
  add     ecx, 32
  pop     ebx
  jmp     SmallForwardMove
@@FwdLargeMove:
  mov     ebx, ecx
  test    edx, 15
  jz      @@FwdLargeAligned
  lea     ecx, [edx+15] {16 byte Align Destination}
  and     ecx, -16
  sub     ecx, edx
  add     eax, ecx
  add     edx, ecx
  sub     ebx, ecx
  call    SmallForwardMove
  mov     ecx, ebx
@@FwdLargeAligned:
  and     ecx, -16
  sub     ebx, ecx {EBX = Remainder}
  push    edx
  push    eax
  push    ecx
  call    LargeSSEMove
  pop     ecx
  pop     eax
  pop     edx
  add     ecx, ebx
  add     eax, ecx
  add     edx, ecx
  mov     ecx, ebx
  pop     ebx
  jmp     SmallForwardMove
end;

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX < EDX and ECX > 36 (TINYSIZE)}
procedure Backwards_SSE;
const
  SMALLSIZE = 64;
asm
  cmp     ecx, SMALLSIZE
  jle     Backwards_IA32
  push    ebx
  movups  xmm0, [eax+ecx-16] {Last 16 Bytes}
  lea     ebx, [edx+ecx] {Align Writes}
  and     ebx, 15
  sub     ecx, ebx
  add     ebx, ecx
  sub     ecx, 32
@@BwdLoop:
  movups  xmm1, [eax+ecx]
  movups  xmm2, [eax+ecx+16]
  movaps  [edx+ecx], xmm1
  movaps  [edx+ecx+16], xmm2
  sub     ecx, 32
  jge     @@BwdLoop
  movups  [edx+ebx-16], xmm0  {Last 16 Bytes}
  add     ecx, 32
  pop     ebx
  jmp     SmallBackwardMove
end;

{-------------------------------------------------------------------------}
procedure LargeAlignedSSE2Move; {Also used in SSE3 Move}
asm
@@Loop:
  movdqa  xmm0, [eax+ecx]
  movdqa  xmm1, [eax+ecx+16]
  movdqa  xmm2, [eax+ecx+32]
  movdqa  xmm3, [eax+ecx+48]
  movdqa  [edx+ecx], xmm0
  movdqa  [edx+ecx+16], xmm1
  movdqa  [edx+ecx+32], xmm2
  movdqa  [edx+ecx+48], xmm3
  movdqa  xmm4, [eax+ecx+64]
  movdqa  xmm5, [eax+ecx+80]
  movdqa  xmm6, [eax+ecx+96]
  movdqa  xmm7, [eax+ecx+112]
  movdqa  [edx+ecx+64], xmm4
  movdqa  [edx+ecx+80], xmm5
  movdqa  [edx+ecx+96], xmm6
  movdqa  [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
end;

{-------------------------------------------------------------------------}
procedure LargeUnalignedSSE2Move;
asm
@@Loop:
  movdqu  xmm0, [eax+ecx]
  movdqu  xmm1, [eax+ecx+16]
  movdqu  xmm2, [eax+ecx+32]
  movdqu  xmm3, [eax+ecx+48]
  movdqa  [edx+ecx], xmm0
  movdqa  [edx+ecx+16], xmm1
  movdqa  [edx+ecx+32], xmm2
  movdqa  [edx+ecx+48], xmm3
  movdqu  xmm4, [eax+ecx+64]
  movdqu  xmm5, [eax+ecx+80]
  movdqu  xmm6, [eax+ecx+96]
  movdqu  xmm7, [eax+ecx+112]
  movdqa  [edx+ecx+64], xmm4
  movdqa  [edx+ecx+80], xmm5
  movdqa  [edx+ecx+96], xmm6
  movdqa  [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
end;

{-------------------------------------------------------------------------}
procedure HugeAlignedSSE2Move; {Also used in SSE3 Move}
const
  Prefetch = 512;
asm
@@Loop:
  prefetchnta [eax+ecx+Prefetch]
  prefetchnta [eax+ecx+Prefetch+64]
  movdqa  xmm0, [eax+ecx]
  movdqa  xmm1, [eax+ecx+16]
  movdqa  xmm2, [eax+ecx+32]
  movdqa  xmm3, [eax+ecx+48]
  movntdq [edx+ecx], xmm0
  movntdq [edx+ecx+16], xmm1
  movntdq [edx+ecx+32], xmm2
  movntdq [edx+ecx+48], xmm3
  movdqa  xmm4, [eax+ecx+64]
  movdqa  xmm5, [eax+ecx+80]
  movdqa  xmm6, [eax+ecx+96]
  movdqa  xmm7, [eax+ecx+112]
  movntdq [edx+ecx+64], xmm4
  movntdq [edx+ecx+80], xmm5
  movntdq [edx+ecx+96], xmm6
  movntdq [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
  sfence
end;

{-------------------------------------------------------------------------}
procedure HugeUnalignedSSE2Move;
const
  Prefetch = 512;
asm
@@Loop:
  prefetchnta [eax+ecx+Prefetch]
  prefetchnta [eax+ecx+Prefetch+64]
  movdqu  xmm0, [eax+ecx]
  movdqu  xmm1, [eax+ecx+16]
  movdqu  xmm2, [eax+ecx+32]
  movdqu  xmm3, [eax+ecx+48]
  movntdq [edx+ecx], xmm0
  movntdq [edx+ecx+16], xmm1
  movntdq [edx+ecx+32], xmm2
  movntdq [edx+ecx+48], xmm3
  movdqu  xmm4, [eax+ecx+64]
  movdqu  xmm5, [eax+ecx+80]
  movdqu  xmm6, [eax+ecx+96]
  movdqu  xmm7, [eax+ecx+112]
  movntdq [edx+ecx+64], xmm4
  movntdq [edx+ecx+80], xmm5
  movntdq [edx+ecx+96], xmm6
  movntdq [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
  sfence
end; {HugeUnalignedSSE2Move}

{-------------------------------------------------------------------------}
{Dest MUST be 16-Byes Aligned, Count MUST be multiple of 16 }
procedure LargeSSE2Move;
asm
  push    ebx
  mov     ebx, ecx
  and     ecx, -128             {No of Bytes to Block Move (Multiple of 128)}
  add     eax, ecx              {End of Source Blocks}
  add     edx, ecx              {End of Dest Blocks}
  neg     ecx
  cmp     ecx, CacheLimit       {Count > Limit - Use Prefetch}
  jl      @@Huge
  test    eax, 15               {Check if Both Source/Dest are Aligned}
  jnz     @@LargeUnaligned
  call    LargeAlignedSSE2Move  {Both Source and Dest 16-Byte Aligned}
  jmp     @@Remainder
@@LargeUnaligned:               {Source Not 16-Byte Aligned}
  call    LargeUnalignedSSE2Move
  jmp     @@Remainder
@@Huge:
  test    eax, 15               {Check if Both Source/Dest Aligned}
  jnz     @@HugeUnaligned
  call    HugeAlignedSSE2Move   {Both Source and Dest 16-Byte Aligned}
  jmp     @@Remainder
@@HugeUnaligned:                {Source Not 16-Byte Aligned}
  call    HugeUnalignedSSE2Move
@@Remainder:
  and     ebx, $7F              {Remainder (0..112 - Multiple of 16)}
  jz      @@Done
  add     eax, ebx
  add     edx, ebx
  neg     ebx
@@RemainderLoop:
  movdqu  xmm0, [eax+ebx]
  movdqa  [edx+ebx], xmm0
  add     ebx, 16
  jnz     @@RemainderLoop
@@Done:
  pop     ebx
end;

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX > EDX and ECX > 36 (TINYSIZE)}
procedure Forwards_SSE2;
const
  SMALLSIZE = 64;
  LARGESIZE = 2048;
asm
  cmp     ecx, SMALLSIZE
  jle     Forwards_IA32
  push    ebx
  cmp     ecx, LARGESIZE
  jge     @@FwdLargeMove
  movdqu  xmm0, [eax] {First 16 Bytes}
  mov     ebx, edx
  add     eax, ecx {Align Writes}
  add     ecx, edx
  and     edx, -16
  add     edx, 48
  sub     ecx, edx
  add     edx, ecx
  neg     ecx
@@FwdLoopSSE2:
  movdqu  xmm1, [eax+ecx-32]
  movdqu  xmm2, [eax+ecx-16]
  movdqa  [edx+ecx-32], xmm1
  movdqa  [edx+ecx-16], xmm2
  add     ecx, 32
  jle     @@FwdLoopSSE2
  movdqu  [ebx], xmm0 {First 16 Bytes}
  neg     ecx
  add     ecx, 32
  pop     ebx
  jmp     SmallForwardMove
@@FwdLargeMove:
  mov     ebx, ecx
  test    edx, 15
  jz      @@FwdLargeAligned
  lea     ecx, [edx+15] {16 byte Align Destination}
  and     ecx, -16
  sub     ecx, edx
  add     eax, ecx
  add     edx, ecx
  sub     ebx, ecx
  call    SmallForwardMove
  mov     ecx, ebx
@@FwdLargeAligned:
  and     ecx, -16
  sub     ebx, ecx {EBX = Remainder}
  push    edx
  push    eax
  push    ecx
  call    LargeSSE2Move
  pop     ecx
  pop     eax
  pop     edx
  add     ecx, ebx
  add     eax, ecx
  add     edx, ecx
  mov     ecx, ebx
  pop     ebx
  jmp     SmallForwardMove
end;

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX < EDX and ECX > 36 (TINYSIZE)}
procedure Backwards_SSE2;
const
  SMALLSIZE = 64;
asm
  cmp     ecx, SMALLSIZE
  jle     Backwards_IA32
  push    ebx
  movdqu  xmm0, [eax+ecx-16] {Last 16 Bytes}
  lea     ebx, [edx+ecx] {Align Writes}
  and     ebx, 15
  sub     ecx, ebx
  add     ebx, ecx
  sub     ecx, 32
  add     edi, 0 {3-Byte NOP Equivalent to Align Loop}
@@BwdLoop:
  movdqu  xmm1, [eax+ecx]
  movdqu  xmm2, [eax+ecx+16]
  movdqa  [edx+ecx], xmm1
  movdqa  [edx+ecx+16], xmm2
  sub     ecx, 32
  jge     @@BwdLoop
  movdqu  [edx+ebx-16], xmm0  {Last 16 Bytes}
  add     ecx, 32
  pop     ebx
  jmp     SmallBackwardMove
end;

{-------------------------------------------------------------------------}
procedure LargeUnalignedSSE3Move;
asm
@@Loop:
  lddqu   xmm0, [eax+ecx]
  lddqu   xmm1, [eax+ecx+16]
  lddqu   xmm2, [eax+ecx+32]
  lddqu   xmm3, [eax+ecx+48]
  movdqa  [edx+ecx], xmm0
  movdqa  [edx+ecx+16], xmm1
  movdqa  [edx+ecx+32], xmm2
  movdqa  [edx+ecx+48], xmm3
  lddqu   xmm4, [eax+ecx+64]
  lddqu   xmm5, [eax+ecx+80]
  lddqu   xmm6, [eax+ecx+96]
  lddqu   xmm7, [eax+ecx+112]
  movdqa  [edx+ecx+64], xmm4
  movdqa  [edx+ecx+80], xmm5
  movdqa  [edx+ecx+96], xmm6
  movdqa  [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
end;

{-------------------------------------------------------------------------}
procedure HugeUnalignedSSE3Move;
const
  Prefetch = 512;
asm
@@Loop:
  prefetchnta [eax+ecx+Prefetch]
  prefetchnta [eax+ecx+Prefetch+64]
  lddqu   xmm0, [eax+ecx]
  lddqu   xmm1, [eax+ecx+16]
  lddqu   xmm2, [eax+ecx+32]
  lddqu   xmm3, [eax+ecx+48]
  movntdq [edx+ecx], xmm0
  movntdq [edx+ecx+16], xmm1
  movntdq [edx+ecx+32], xmm2
  movntdq [edx+ecx+48], xmm3
  lddqu   xmm4, [eax+ecx+64]
  lddqu   xmm5, [eax+ecx+80]
  lddqu   xmm6, [eax+ecx+96]
  lddqu   xmm7, [eax+ecx+112]
  movntdq [edx+ecx+64], xmm4
  movntdq [edx+ecx+80], xmm5
  movntdq [edx+ecx+96], xmm6
  movntdq [edx+ecx+112], xmm7
  add     ecx, 128
  js      @@Loop
  sfence
end;

{-------------------------------------------------------------------------}
{Dest MUST be 16-Byes Aligned, Count MUST be multiple of 16 }
procedure LargeSSE3Move(const Source; var Dest; Count: Integer);
asm
  push    ebx
  mov     ebx, ecx
  and     ecx, -128             {No of Bytes to Block Move (Multiple of 128)}
  add     eax, ecx              {End of Source Blocks}
  add     edx, ecx              {End of Dest Blocks}
  neg     ecx
  cmp     ecx, CacheLimit       {Count > Limit - Use Prefetch}
  jl      @@Huge
  test    eax, 15               {Check if Both Source/Dest are Aligned}
  jnz     @@LargeUnaligned
  call    LargeAlignedSSE2Move  {Both Source and Dest 16-Byte Aligned}
  jmp     @@Remainder
@@LargeUnaligned:               {Source Not 16-Byte Aligned}
  call    LargeUnalignedSSE3Move
  jmp     @@Remainder
@@Huge:
  test    eax, 15               {Check if Both Source/Dest Aligned}
  jnz     @@HugeUnaligned
  call    HugeAlignedSSE2Move   {Both Source and Dest 16-Byte Aligned}
  jmp     @@Remainder
@@HugeUnaligned:                {Source Not 16-Byte Aligned}
  call    HugeUnalignedSSE3Move
@@Remainder:
  and     ebx, $7F              {Remainder (0..112 - Multiple of 16)}
  jz      @@Done
  add     eax, ebx
  add     edx, ebx
  neg     ebx
@@RemainderLoop:
  lddqu   xmm0, [eax+ebx]
  movdqa  [edx+ebx], xmm0
  add     ebx, 16
  jnz     @@RemainderLoop
@@Done:
  pop     ebx
end;

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX > EDX and ECX > 36 (TINYSIZE)}
procedure Forwards_SSE3;
const
  SMALLSIZE = 64;
  LARGESIZE = 2048;
asm
  cmp     ecx, SMALLSIZE
  jle     Forwards_IA32
  push    ebx
  cmp     ecx, LARGESIZE
  jge     @@FwdLargeMove
  lddqu   xmm0, [eax] {First 16 Bytes}
  mov     ebx, edx
  add     eax, ecx {Align Writes}
  add     ecx, edx
  and     edx, -16
  add     edx, 48
  sub     ecx, edx
  add     edx, ecx
  neg     ecx
@@FwdLoopSSE3:
  lddqu   xmm1, [eax+ecx-32]
  lddqu   xmm2, [eax+ecx-16]
  movdqa  [edx+ecx-32], xmm1
  movdqa  [edx+ecx-16], xmm2
  add     ecx, 32
  jle     @@FwdLoopSSE3
  movdqu  [ebx], xmm0 {First 16 Bytes}
  neg     ecx
  add     ecx, 32
  pop     ebx
  jmp     SmallForwardMove
@@FwdLargeMove:
  mov     ebx, ecx
  test    edx, 15
  jz      @@FwdLargeAligned
  lea     ecx, [edx+15] {16 byte Align Destination}
  and     ecx, -16
  sub     ecx, edx
  add     eax, ecx
  add     edx, ecx
  sub     ebx, ecx
  call    SmallForwardMove
  mov     ecx, ebx
@@FwdLargeAligned:
  and     ecx, -16
  sub     ebx, ecx {EBX = Remainder}
  push    edx
  push    eax
  push    ecx
  call    LargeSSE3Move
  pop     ecx
  pop     eax
  pop     edx
  add     ecx, ebx
  add     eax, ecx
  add     edx, ecx
  mov     ecx, ebx
  pop     ebx
  jmp     SmallForwardMove
end;

{-------------------------------------------------------------------------}
{Move ECX Bytes from EAX to EDX, where EAX < EDX and ECX > 36 (TINYSIZE)}
procedure Backwards_SSE3;
const
  SMALLSIZE = 64;
asm
  cmp     ecx, SMALLSIZE
  jle     Backwards_IA32
  push    ebx
  lddqu   xmm0, [eax+ecx-16] {Last 16 Bytes}
  lea     ebx, [edx+ecx] {Align Writes}
  and     ebx, 15
  sub     ecx, ebx
  add     ebx, ecx
  sub     ecx, 32
  add     edi, 0 {3-Byte NOP Equivalent to Align Loop}
@@BwdLoop:
  lddqu   xmm1, [eax+ecx]
  lddqu   xmm2, [eax+ecx+16]
  movdqa  [edx+ecx], xmm1
  movdqa  [edx+ecx+16], xmm2
  sub     ecx, 32
  jge     @@BwdLoop
  movdqu  [edx+ebx-16], xmm0  {Last 16 Bytes}
  add     ecx, 32
  pop     ebx
  jmp     SmallBackwardMove
end;

procedure MoveMMX(const Source; var Dest; Count: Integer);
asm
  cmp     ecx, TINYSIZE
  ja      @@Large { Count > TINYSIZE or Count < 0 }
  cmp     eax, edx
  jbe     @@SmallCheck
  add     eax, ecx
  add     edx, ecx
  jmp     SmallForwardMove
@@SmallCheck:
  jne     SmallBackwardMove
  ret { For Compatibility with Delphi's move for Source = Dest }
@@Large:
  jng     @@Done { For Compatibility with Delphi's move for Count < 0 }
  cmp     eax, edx
  ja      Forwards_MMX
  je      @@Done { For Compatibility with Delphi's move for Source = Dest }
  sub     edx, ecx
  cmp     eax, edx
  lea     edx, [edx+ecx]
  jna     Forwards_MMX
  jmp     Backwards_MMX { Source/Dest Overlap }
@@Done:
end;

procedure MoveSSE(const Source; var Dest; Count: Integer);
asm
  cmp     ecx, TINYSIZE
  ja      @@Large { Count > TINYSIZE or Count < 0 }
  cmp     eax, edx
  jbe     @@SmallCheck
  add     eax, ecx
  add     edx, ecx
  jmp     SmallForwardMove
@@SmallCheck:
  jne     SmallBackwardMove
  ret { For Compatibility with Delphi's move for Source = Dest }
@@Large:
  jng     @@Done { For Compatibility with Delphi's move for Count < 0 }
  cmp     eax, edx
  ja      Forwards_SSE
  je      @@Done { For Compatibility with Delphi's move for Source = Dest }
  sub     edx, ecx
  cmp     eax, edx
  lea     edx, [edx+ecx]
  jna     Forwards_SSE
  jmp     Backwards_SSE { Source/Dest Overlap }
@@Done:
end;

procedure MoveSSE2(const Source; var Dest; Count: Integer);
asm
  cmp     ecx, TINYSIZE
  ja      @@Large {Count > TINYSIZE or Count < 0}
  cmp     eax, edx
  jbe     @@SmallCheck
  add     eax, ecx
  add     edx, ecx
  jmp     SmallForwardMove
@@SmallCheck:
  jne     SmallBackwardMove
  ret {For Compatibility with Delphi's move for Source = Dest}
@@Large:
  jng     @@Done {For Compatibility with Delphi's move for Count < 0}
  cmp     eax, edx
  ja      Forwards_SSE2
  je      @@Done {For Compatibility with Delphi's move for Source = Dest}
  sub     edx, ecx
  cmp     eax, edx
  lea     edx, [edx+ecx]
  jna     Forwards_SSE2
  jmp     Backwards_SSE2 {Source/Dest Overlap}
@@Done:
end;

procedure MoveSSE3(const Source; var Dest; Count: Integer);
asm
  cmp     ecx, TINYSIZE
  ja      @@Large { Count > TINYSIZE or Count < 0 }
  cmp     eax, edx
  jbe     @@SmallCheck
  add     eax, ecx
  add     edx, ecx
  jmp     SmallForwardMove
@@SmallCheck:
  jne     SmallBackwardMove
  ret { For Compatibility with Delphi's move for Source = Dest }
@@Large:
  jng     @@Done { For Compatibility with Delphi's move for Count < 0}
  cmp     eax, edx
  ja      Forwards_SSE3
  je      @@Done { For Compatibility with Delphi's move for Source = Dest }
  sub     edx, ecx
  cmp     eax, edx
  lea     edx, [edx+ecx]
  jna     Forwards_SSE3
  jmp     Backwards_SSE3 { Source/Dest Overlap }
@@Done:
end;

const
  ValidHexChars: array[Char] of Byte = (
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, 0, 1,
    2, 3, 4, 5, 6, 7, 8, 9, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, 10, 11, 12, 13, 14,
    15, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, 10, 11, 12,
    13, 14, 15, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, 0
  );

function TextBufToUInt64(const pBuf: PChar): Int64;
asm
  TEST   EAX, EAX
  JZ     @@StringInvalid
  MOV    EDX, EAX
  XOR    ECX, ECX
  XOR    EAX, EAX
  JMP    @@Start
@@SkipSpace:
  INC    EDX
@@Start:
  CMP    BYTE PTR [EDX], ' '
  JE     @@SkipSpace
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  TEST   AL, AL
  JZ     @@StringInvalid
  CMP    AL, '-'
  JNE    @@CheckPlusSign
  INC    ECX
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  JMP    @@NoExtra
@@CheckPlusSign:
  CMP    AL, '+'
  JNE    @@CheckHex
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  JMP    @@NoExtra
@@CheckHex:
  CMP    WORD PTR [EDX-1], 30768 {'0x'}
  JE     @@Hexadecimal
  CMP    AL, '$'
  JE     @@HexadecimalPascal
@@NoExtra:
  PUSH   ECX
  XOR    ECX, ECX
@@MainLoop:
  TEST   AL, AL
  JZ     @@ReachedNull
  SUB    AL, '0'
  JC     @@InvalidChar
  CMP    AL, 10
  JAE    @@InvalidChar
  LEA    ECX, [ECX+ECX*4]
  LEA    ECX, [EAX+ECX*2]
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  JMP    @@MainLoop
@@ReachedNull:
  MOV    EAX, ECX
  POP    ECX
  SHR    ECX, 1
  JNC    @@Positive
  NEG    EAX
@@Positive:
  RET
@@InvalidChar:
  ADD    ESP, 4
@@StringInvalid:
  XOR    EAX, EAX
  RET
@@Hexadecimal:
  INC    EDX
@@HexadecimalPascal:
  XOR    ECX, ECX
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
@@HexLoop:
  TEST   AL, AL
  JZ     @@ReachedNullHex
  MOV    AL, BYTE PTR [ValidHexChars+EAX]
  CMP    AL, $FF
  JE     @@InvalidHexChar
  LEA    ECX, [ECX*8]
  LEA    ECX, [EAX+ECX*2]
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  JMP    @@HexLoop
@@ReachedNullHex:
  MOV    EAX, ECX
  RET
@@InvalidHexChar:
  XOR    EAX, EAX
end;

function TextBufToUInt(const Buf: PChar): Longword;
asm
  TEST   EAX, EAX
  JZ     @@StringInvalid
  MOV    EDX, EAX
  XOR    ECX, ECX
  XOR    EAX, EAX
  JMP    @@Start
@@SkipSpace:
  INC    EDX
@@Start:
  CMP    BYTE PTR [EDX], ' '
  JE     @@SkipSpace
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  TEST   AL, AL
  JZ     @@StringInvalid
  CMP    AL, '-'
  JNE    @@CheckPlusSign
  INC    ECX
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  JMP    @@NoExtra
@@CheckPlusSign:
  CMP    AL, '+'
  JNE    @@CheckHex
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  JMP    @@NoExtra
@@CheckHex:
  CMP    WORD PTR [EDX-1], 30768 {'0x'}
  JE     @@Hexadecimal
  CMP    AL, '$'
  JE     @@HexadecimalPascal
@@NoExtra:
  PUSH   ECX
  XOR    ECX, ECX
@@MainLoop:
  TEST   AL, AL
  JZ     @@ReachedNull
  SUB    AL, '0'
  JC     @@InvalidChar
  CMP    AL, 10
  JAE    @@InvalidChar
  LEA    ECX, [ECX+ECX*4]
  LEA    ECX, [EAX+ECX*2]
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  JMP    @@MainLoop
@@ReachedNull:
  MOV    EAX, ECX
  POP    ECX
  SHR    ECX, 1
  JNC    @@Positive
  NEG    EAX
@@Positive:
  RET
@@InvalidChar:
  ADD    ESP, 4
@@StringInvalid:
  XOR    EAX, EAX
  RET
@@Hexadecimal:
  INC    EDX
@@HexadecimalPascal:
  XOR    ECX, ECX
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
@@HexLoop:
  TEST   AL, AL
  JZ     @@ReachedNullHex
  MOV    AL, BYTE PTR [ValidHexChars+EAX]
  CMP    AL, $FF
  JE     @@InvalidHexChar
  LEA    ECX, [ECX*8]
  LEA    ECX, [EAX+ECX*2]
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  JMP    @@HexLoop
@@ReachedNullHex:
  MOV    EAX, ECX
  RET
@@InvalidHexChar:
  XOR    EAX, EAX
end;

function WideTextBufToUInt(const Buf: PWideChar): Longword;
asm
  TEST   EAX, EAX
  JZ     @@StringInvalid
  MOV    EDX, EAX
  XOR    ECX, ECX
  XOR    EAX, EAX
  JMP    @@Start
@@SkipSpace:
  ADD    EDX, 2
@@Start:
  CMP    WORD PTR [EDX], Ord(' ')
  JE     @@SkipSpace
  MOV    AX, WORD PTR [EDX]
  ADD    EDX, 2
  TEST   AX, AX
  JZ     @@StringInvalid
  CMP    AX, Ord('-')
  JNE    @@CheckPlusSign
  INC    ECX
  MOV    AX, WORD PTR [EDX]
  ADD    EDX, 2
  JMP    @@NoExtra
@@CheckPlusSign:
  CMP    AX, Ord('+')
  JNE    @@CheckHex
  MOV    AX, WORD PTR [EDX]
  ADD    EDX, 2
  JMP    @@NoExtra
@@CheckHex:
  CMP    DWORD PTR [EDX-1], $00007830 {'0x'}
  JE     @@Hexadecimal
  CMP    AX, Ord('$')
  JE     @@HexadecimalPascal
@@NoExtra:
  PUSH   ECX
  XOR    ECX, ECX
@@MainLoop:
  TEST   AX, AX
  JZ     @@ReachedNull
  SUB    AX, Ord('0')
  JC     @@InvalidChar
  CMP    AX, 10
  JAE    @@InvalidChar
  LEA    ECX, [ECX+ECX*4]
  LEA    ECX, [EAX+ECX*2]
  MOV    AX, WORD PTR [EDX]
  ADD    EDX, 2
  JMP    @@MainLoop
@@ReachedNull:
  MOV    EAX, ECX
  POP    ECX
  SHR    ECX, 1
  JNC    @@Positive
  NEG    EAX
@@Positive:
  RET
@@InvalidChar:
  ADD    ESP, 4
@@StringInvalid:
  XOR    EAX, EAX
  RET
@@Hexadecimal:
  ADD    EDX, 2
@@HexadecimalPascal:
  XOR    ECX, ECX
  MOV    AX, WORD PTR [EDX]
  ADD    EDX, 2
@@HexLoop:
  TEST   AX, AX
  JZ     @@ReachedNullHex
  CMP    AX, $FF
  JA     @@InvalidHexChar
  MOVZX  AX, BYTE PTR [ValidHexChars+EAX]
  CMP    AL, $FF
  JE     @@InvalidHexChar
  LEA    ECX, [ECX*8]
  LEA    ECX, [EAX+ECX*2]
  MOV    AX, WORD PTR [EDX]
  ADD    EDX, 2
  JMP    @@HexLoop
@@ReachedNullHex:
  MOV    EAX, ECX
  RET
@@InvalidHexChar:
  XOR    EAX, EAX
end;

function StrToUInt(const sStr: string): Longword;
asm
  TEST   EAX, EAX
  JZ     @@UnallocateSrc
  PUSH   EDI
  MOV    EDX, EAX
  MOV    EDI, [EAX-4]
  XOR    ECX, ECX
  XOR    EAX, EAX
  JMP    @@Start
@@SkipSpace:
  INC    EDX
  DEC    EDI
  JS     @@StringInvalid
@@Start:
  CMP    BYTE PTR [EDX], ' '
  JE     @@SkipSpace
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  DEC    EDI
  JS     @@StringInvalid
  CMP    AL, '-'
  JNE    @@CheckPlusSign
  INC    ECX
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  DEC    EDI
  JS     @@StringInvalid
  JMP    @@NoExtra
@@CheckPlusSign:
  CMP    AL, '+'
  JNE    @@CheckHex
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  DEC    EDI
  JS     @@StringInvalid
  JMP    @@NoExtra
@@CheckHex:
  CMP    EDI, 2
  JBE    @@NoExtra
  CMP    WORD PTR [EDX-1], 30768 {'0x'}
  JE     @@Hexadecimal
  CMP    AL, '$'
  JE     @@HexadecimalPascal
@@NoExtra:
  PUSH   ECX
  XOR    ECX, ECX
@@MainLoop:
  SUB    AL, '0'
  JC     @@InvalidChar
  CMP    AL, 10
  JAE    @@InvalidChar
  LEA    ECX, [ECX+ECX*4]
  LEA    ECX, [EAX+ECX*2]
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  DEC    EDI
  JNS    @@MainLoop
  MOV    EAX, ECX
  POP    ECX
  SHR    ECX, 1
  JNC    @@Positive
  NEG    EAX
@@Positive:
  POP    EDI
  RET
@@InvalidChar:
  ADD    ESP, 4
@@StringInvalid:
  XOR    EAX, EAX
@@UnallocateSrc:
  POP    EDI
  RET
@@Hexadecimal:
  INC    EDX
  DEC    EDI
  JZ     @@StringInvalid
@@HexadecimalPascal:
  XOR    ECX, ECX
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  DEC    EDI
  JZ     @@FinishedHex
@@HexLoop:
  MOV    AL, BYTE PTR [ValidHexChars+EAX]
  CMP    AL, $FF
  JE     @@InvalidHexChar
  LEA    ECX, [ECX*8]
  LEA    ECX, [EAX+ECX*2]
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  DEC    EDI
  JNS    @@HexLoop
@@FinishedHex:
  MOV    EAX, ECX
  POP    EDI
  RET
@@InvalidHexChar:
  XOR    EAX, EAX
  POP    EDI
end;

function TryStrToUInt(const sStr: string; var iValue: Longword): Boolean;
asm
  TEST   EAX, EAX
  JZ     @@UnallocatedSrc
  TEST   EDX, EDX
  JZ     @@UnallocatedSrc
  PUSH   EDI
  PUSH   ESI
  MOV    ESI, EDX
  MOV    EDX, EAX
  MOV    EDI, [EAX-4]
  XOR    ECX, ECX
  XOR    EAX, EAX
  JMP    @@Start
@@SkipSpace:
  INC    EDX
  DEC    EDI
  JS     @@StringInvalid
@@Start:
  CMP    BYTE PTR [EDX], ' '
  JE     @@SkipSpace
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  DEC    EDI
  JS     @@StringInvalid
  CMP    AL, '-'
  JNE    @@CheckPlusSign
  INC    ECX
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  DEC    EDI
  JS     @@StringInvalid
  JMP    @@NoExtra
@@CheckPlusSign:
  CMP    AL, '+'
  JNE    @@CheckHex
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  DEC    EDI
  JS     @@StringInvalid
  JMP    @@NoExtra
@@CheckHex:
  CMP    EDI, 2
  JBE    @@NoExtra
  CMP    WORD PTR [EDX-1], 30768 {'0x'}
  JE     @@Hexadecimal
  CMP    AL, '$'
  JE     @@HexadecimalPascal
@@NoExtra:
  PUSH   ECX
  XOR    ECX, ECX
@@MainLoop:
  SUB    AL, '0'
  JC     @@InvalidChar
  CMP    AL, 10
  JAE    @@InvalidChar
  LEA    ECX, [ECX+ECX*4]
  LEA    ECX, [EAX+ECX*2]
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  DEC    EDI
  JNS    @@MainLoop
  MOV    EAX, ECX
  POP    ECX
  SHR    ECX, 1
  JNC    @@Positive
  NEG    EAX
@@Positive:
  MOV    [ESI], EAX
  MOV    AL, 1
  POP    ESI
  POP    EDI
  RET
@@InvalidChar:
  ADD    ESP, 4
@@StringInvalid:
  XOR    EAX, EAX
@@UnallocatedSrc:
  XOR    AL, AL
  POP    ESI
  POP    EDI
  RET
@@Hexadecimal:
  INC    EDX
  DEC    EDI
  JZ     @@StringInvalid
@@HexadecimalPascal:
  XOR    ECX, ECX
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  DEC    EDI
  JZ     @@FinishedHex
@@HexLoop:
  MOV    AL, BYTE PTR [ValidHexChars+EAX]
  CMP    AL, $FF
  JE     @@InvalidHexChar
  LEA    ECX, [ECX*8]
  LEA    ECX, [EAX+ECX*2]
  MOV    AL, BYTE PTR [EDX]
  INC    EDX
  DEC    EDI
  JNS    @@HexLoop
@@FinishedHex:
  MOV    [ESI], ECX
  MOV    AL, 1
  POP    ESI
  POP    EDI
  RET
@@InvalidHexChar:
  XOR    AL, AL
  POP    ESI
  POP    EDI
end;

function TextBufToFloat(Buffer: PChar; var Value: Single): Boolean;
const
  CWNear: Word = $133F;
  DCon10: Integer = 10;
var
  Temp: Integer;
  CtrlWord: Word;
  SaveGOT: Integer;
asm
  PUSH    EDI
  PUSH    ESI
  PUSH    EBX
  MOV     ESI,EAX
  MOV     EDI,EDX
  MOV     SaveGOT,0
  FSTCW   CtrlWord
  FCLEX
  FLDCW   CWNear
  FLDZ
  CALL    @@SkipBlanks
  MOV     BH, byte ptr [ESI]
  CMP     BH,'+'
  JE      @@1
  CMP     BH,'-'
  JNE     @@2
@@1:
  INC     ESI
@@2:
  MOV     ECX,ESI
  CALL    @@GetDigitStr
  XOR     EDX,EDX
  MOV     AL,[ESI]
  CMP     AL,'.'
  JE      @@2b
  CMP     AL,','
  JNE     @@3
@@2b:
  INC     ESI
  CALL    @@GetDigitStr
  NEG     EDX
@@3:
  CMP     ECX,ESI
  JE      @@9
  MOV     AL, byte ptr [ESI]
  AND     AL,0DFH
  CMP     AL,'E'
  JNE     @@4
  INC     ESI
  PUSH    EDX
  CALL    @@GetExponent
  POP     EAX
  ADD     EDX,EAX
@@4:
  CALL    @@SkipBlanks
  CMP     BYTE PTR [ESI],0
  JNE     @@9
  MOV     EAX,EDX
  PUSH    EBX
  MOV     EBX,SaveGOT
  CALL    FPower10
  POP     EBX
  CMP     BH,'-'
  JNE     @@6
  FCHS
@@6:
  FSTP    DWORD PTR [EDI]
@@8:
  FSTSW   AX
  TEST    AX,$0001 or $0008
  JNE     @@10
  MOV     AL,1
  JMP     @@11
@@9:
  FSTP    ST(0)
@@10:
  XOR     EAX,EAX
@@11:
  FCLEX
  FLDCW   CtrlWord
  FWAIT
  JMP     @@Exit

@@SkipBlanks:

@@21:
  LODSB
  OR      AL,AL
  JE      @@22
  CMP     AL,' '
  JE      @@21
@@22:
  DEC     ESI
  RET

// Process string of digits
// Out EDX = Digit count

@@GetDigitStr:

  XOR     EAX,EAX
  XOR     EDX,EDX
@@31:
  LODSB
  SUB     AL,'0'+10
  ADD     AL,10
  JNC     @@32
  FIMUL   DCon10
  MOV     Temp,EAX
  FIADD   Temp
  INC     EDX
  JMP     @@31
@@32:
  DEC     ESI
  RET

// Get exponent
// Out EDX = Exponent (-4999..4999)

@@GetExponent:

  XOR     EAX,EAX
  XOR     EDX,EDX
  MOV     CL, byte ptr [ESI]
  CMP     CL,'+'
  JE      @@41
  CMP     CL,'-'
  JNE     @@42
@@41:
  INC     ESI
@@42:
  MOV     AL, BYTE PTR [ESI]
  SUB     AL,'0'+10
  ADD     AL,10
  JNC     @@43
  INC     ESI
  IMUL    EDX,10
  ADD     EDX,EAX
  CMP     EDX,500
  JB      @@42
@@43:
  CMP     CL,'-'
  JNE     @@44
  NEG     EDX
@@44:
  RET

@@Exit:
  POP     EBX
  POP     ESI
  POP     EDI
end;

function TextBufToDouble(Buffer: PChar; var Value: Double): Boolean;
const
  CWNear: Word = $133F;
  DCon10: Integer = 10;
var
  Temp: Integer;
  CtrlWord: Word;
  SaveGOT: Integer;
asm
  PUSH    EDI
  PUSH    ESI
  PUSH    EBX
  MOV     ESI,EAX
  MOV     EDI,EDX
  MOV     SaveGOT,0
  FSTCW   CtrlWord
  FCLEX
  FLDCW   CWNear
  FLDZ
  CALL    @@SkipBlanks
  MOV     BH, byte ptr [ESI]
  CMP     BH,'+'
  JE      @@1
  CMP     BH,'-'
  JNE     @@2
@@1:
  INC     ESI
@@2:
  MOV     ECX,ESI
  CALL    @@GetDigitStr
  XOR     EDX,EDX
  MOV     AL,[ESI]
  CMP     AL,'.'
  JE      @@2b
  CMP     AL,','
  JNE     @@3
@@2b:
  INC     ESI
  CALL    @@GetDigitStr
  NEG     EDX
@@3:
  CMP     ECX,ESI
  JE      @@9
  MOV     AL, byte ptr [ESI]
  AND     AL,0DFH
  CMP     AL,'E'
  JNE     @@4
  INC     ESI
  PUSH    EDX
  CALL    @@GetExponent
  POP     EAX
  ADD     EDX,EAX
@@4:
  CALL    @@SkipBlanks
  CMP     BYTE PTR [ESI],0
  JNE     @@9
  MOV     EAX,EDX
  PUSH    EBX
  MOV     EBX,SaveGOT
  CALL    FPower10
  POP     EBX
  CMP     BH,'-'
  JNE     @@6
  FCHS
@@6:
  FSTP    QWORD PTR [EDI]
@@8:
  FSTSW   AX
  TEST    AX,$0001 or $0008
  JNE     @@10
  MOV     AL,1
  JMP     @@11
@@9:
  FSTP    ST(0)
@@10:
  XOR     EAX,EAX
@@11:
  FCLEX
  FLDCW   CtrlWord
  FWAIT
  JMP     @@Exit

@@SkipBlanks:

@@21:
  LODSB
  OR      AL,AL
  JE      @@22
  CMP     AL,' '
  JE      @@21
@@22:
  DEC     ESI
  RET

// Process string of digits
// Out EDX = Digit count

@@GetDigitStr:

  XOR     EAX,EAX
  XOR     EDX,EDX
@@31:
  LODSB
  SUB     AL,'0'+10
  ADD     AL,10
  JNC     @@32
  FIMUL   DCon10
  MOV     Temp,EAX
  FIADD   Temp
  INC     EDX
  JMP     @@31
@@32:
  DEC     ESI
  RET

// Get exponent
// Out EDX = Exponent (-4999..4999)

@@GetExponent:

  XOR     EAX,EAX
  XOR     EDX,EDX
  MOV     CL, byte ptr [ESI]
  CMP     CL,'+'
  JE      @@41
  CMP     CL,'-'
  JNE     @@42
@@41:
  INC     ESI
@@42:
  MOV     AL, BYTE PTR [ESI]
  SUB     AL,'0'+10
  ADD     AL,10
  JNC     @@43
  INC     ESI
  IMUL    EDX,10
  ADD     EDX,EAX
  CMP     EDX,500
  JB      @@42
@@43:
  CMP     CL,'-'
  JNE     @@44
  NEG     EDX
@@44:
  RET

@@Exit:
  POP     EBX
  POP     ESI
  POP     EDI
end;

function TextBufToExtended(Buffer: PChar; var Value: Extended): Boolean;
const
  CWNear: Word = $133F;
  DCon10: Integer = 10;
var
  Temp: Integer;
  CtrlWord: Word;
  SaveGOT: Integer;
asm
  PUSH    EDI
  PUSH    ESI
  PUSH    EBX
  MOV     ESI,EAX
  MOV     EDI,EDX
  MOV     SaveGOT,0
  FSTCW   CtrlWord
  FCLEX
  FLDCW   CWNear
  FLDZ
  CALL    @@SkipBlanks
  MOV     BH, byte ptr [ESI]
  CMP     BH,'+'
  JE      @@1
  CMP     BH,'-'
  JNE     @@2
@@1:
  INC     ESI
@@2:
  MOV     ECX,ESI
  CALL    @@GetDigitStr
  XOR     EDX,EDX
  MOV     AL,[ESI]
  CMP     AL,'.'
  JE      @@2b
  CMP     AL,','
  JNE     @@3
@@2b:
  INC     ESI
  CALL    @@GetDigitStr
  NEG     EDX
@@3:
  CMP     ECX,ESI
  JE      @@9
  MOV     AL, byte ptr [ESI]
  AND     AL,0DFH
  CMP     AL,'E'
  JNE     @@4
  INC     ESI
  PUSH    EDX
  CALL    @@GetExponent
  POP     EAX
  ADD     EDX,EAX
@@4:
  CALL    @@SkipBlanks
  CMP     BYTE PTR [ESI],0
  JNE     @@9
  MOV     EAX,EDX
  PUSH    EBX
  MOV     EBX,SaveGOT
  CALL    FPower10
  POP     EBX
  CMP     BH,'-'
  JNE     @@6
  FCHS
@@6:
  FSTP    TBYTE PTR [EDI]
@@8:
  FSTSW   AX
  TEST    AX,$0001 or $0008
  JNE     @@10
  MOV     AL,1
  JMP     @@11
@@9:
  FSTP    ST(0)
@@10:
  XOR     EAX,EAX
@@11:
  FCLEX
  FLDCW   CtrlWord
  FWAIT
  JMP     @@Exit

@@SkipBlanks:

@@21:
  LODSB
  OR      AL,AL
  JE      @@22
  CMP     AL,' '
  JE      @@21
@@22:
  DEC     ESI
  RET

// Process string of digits
// Out EDX = Digit count

@@GetDigitStr:

  XOR     EAX,EAX
  XOR     EDX,EDX
@@31:
  LODSB
  SUB     AL,'0'+10
  ADD     AL,10
  JNC     @@32
  FIMUL   DCon10
  MOV     Temp,EAX
  FIADD   Temp
  INC     EDX
  JMP     @@31
@@32:
  DEC     ESI
  RET

// Get exponent
// Out EDX = Exponent (-4999..4999)

@@GetExponent:

  XOR     EAX,EAX
  XOR     EDX,EDX
  MOV     CL, byte ptr [ESI]
  CMP     CL,'+'
  JE      @@41
  CMP     CL,'-'
  JNE     @@42
@@41:
  INC     ESI
@@42:
  MOV     AL, BYTE PTR [ESI]
  SUB     AL,'0'+10
  ADD     AL,10
  JNC     @@43
  INC     ESI
  IMUL    EDX,10
  ADD     EDX,EAX
  CMP     EDX,500
  JB      @@42
@@43:
  CMP     CL,'-'
  JNE     @@44
  NEG     EDX
@@44:
  RET

@@Exit:
  POP     EBX
  POP     ESI
  POP     EDI
end;

function atof(const sString: string): Single;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1185 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if not TextBufToFloat(PChar(sString), Result) then Result := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1185; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function atoi16(const sString: string): Word;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1186 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := StrToIntDef(sString, 0);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1186; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function atoi32(const sString: string): Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1187 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := StrToUInt(sString);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1187; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function atoi64(const sString: string): Int64;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1188 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := StrToInt64Def(sString, 0);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1188; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function atoi8(const sString: string): Byte;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1189 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := StrToIntDef(sString, 0);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1189; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function ftoa(fNumber: Single): string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1190 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FloatToStr(fNumber);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1190; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function itoa(iNumber: Word): string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1191 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := UInt32ToStr(iNumber);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1191; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function ftopki(fNumber: Single): Longword;
var
  iPk: Longword absolute fNumber;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1192 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := iPk;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1192; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function pkitof(iNumber: Longword): Single;
var
  fPk: Single absolute iNumber;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1193 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := fPk;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1193; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function htoa(const sIn: string): string;
(*
asm

*)

var
  iIn: Integer;
  iIdx: Integer;
  iLen: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1194 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := '';

  if sIn = '' then Exit;

  iLen := Length(sIn) shr 1;
  SetLength(Result, iLen);
  iIn := 1;

  for iIdx := 1 to iLen do
  begin
    Result[iIdx] := Chr(StrToInt('$' + sIn[iIn] + sIn[iIn+1]));
    Inc(iIn, 2);
  end;

{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1194; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function atoh(const sIn: string): string;
var
  iIn: Integer;
  iLen: Integer;
  sRes: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1195 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := '';

  iLen := Length(sIn);
  if iLen = 0 then Exit;

  SetLength(Result, iLen shl 1);

  for iIn := 1 to iLen do
  begin
    sRes := itoh(Byte(sIn[iIn]));
    Result[iIn*2-1] := sRes[1];
    Result[iIn*2] := sRes[2];
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1195; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function itoa(iNumber: Byte): string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1196 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := UInt32ToStr(iNumber);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1196; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function itoa(iNumber: Int64): string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1197 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := IntToStr(iNumber);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1197; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function itoa(iNumber: Longword): string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1198 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := UInt32ToStr(iNumber);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1198; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function itoh(iNumber: Byte): string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1199 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := IntToHex(iNumber, 2);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1199; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function itoh(iNumber: Word): string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1200 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := IntToHex(iNumber, 4);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1200; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function itoh(iNumber: Longword): string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1201 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := IntToHex(iNumber, 8);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1201; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function itoh(iNumber: Int64): string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1202 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := IntToHex(iNumber, 16);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1202; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function NilOrString(iInt: Longword): string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1203 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if iInt <> 0 then Result := itoa(iInt) else Result := '';
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1203; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function NilOrString(fFlt: Single): string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1204 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if fFlt <> 0 then Result := ftoa(fFlt) else Result := '';
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1204; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function NilOrString(bBool: Boolean): string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1205 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if bBool then Result := '1' else Result := '';
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1205; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function ArrayToString(const aArr: array of Longword): string;
var
  iInt: Integer;
  iLen: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1206 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := '';
  iLen := Length(aArr);
  if iLen = 0 then Exit;
  for iInt := 0 to iLen -1 do
  begin
    Result := Result + itoa(aArr[iInt]) + ' ';
  end;
  System.Delete(Result, Length(Result), 1);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1206; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function ArrayToString(const aArr: array of Single): string;
var
  iInt: Integer;
  iLen: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1207 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := '';
  iLen := Length(aArr);
  if iLen = 0 then Exit;
  for iInt := 0 to iLen -1 do
  begin
    Result := Result + ftoa(aArr[iInt]) + ' ';
  end;
  System.Delete(Result, Length(Result), 1);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1207; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function ArrayToString(const aArr: array of string): string;
var
  iInt: Integer;
  iLen: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1208 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := '';
  iLen := Length(aArr);
  if iLen = 0 then Exit;
  for iInt := 0 to iLen -1 do
  begin
    Result := Result + aArr[iInt] + ' ';
  end;
  System.Delete(Result, Length(Result), 1);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1208; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function InternalBuildFileList(const Path: string; Attr: Integer;
  var List: TStringDynArray; const Mask: string): Boolean;
var
  SearchRec: TSearchRec;
  R: Integer;
  Idx: Integer;
  MaskedPath: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1209 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  MaskedPath := Path + Mask;
  R := FindFirst(MaskedPath, Attr, SearchRec);
  Result := R = 0;
  try
    if Result then
    begin
      Idx := Length(List);
      while R = 0 do
      begin
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          SetLength(List, Idx + 1);
          List[Idx] := Path + SearchRec.Name;
          Inc(Idx);
        end;
        R := FindNext(SearchRec);
      end;
      Result := Longword(R) = ERROR_NO_MORE_FILES;
    end;
  finally
    FindClose(SearchRec);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1209; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BuildFileList(Path: string; Attr: Integer;
  var List: TStringDynArray; const Masks: array of string): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1210 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Path := IncludeTrailingPathDelimiter(Path);
  Result := True;
  for I := Low(Masks) to High(Masks) do
  begin
    Result := InternalBuildFileList(Path, Attr, List, Masks[I]) or Result;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1210; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure StringToDynArray(const sData: string; var aArr: TLongWordDynArray);
var
  pCopy, pCursor: PChar;
  iLen: Integer;
  iCounter, iIdx, iInt: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1211 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if sData = '' then Exit;
  iLen := Length(sData);
  Inc(iLen);
  GetMem(pCopy, iLen);
  Move(Pointer(sData)^, pCopy^, iLen);
  pCursor := pCopy;
  aArr := nil;
  iIdx := 0;
  iInt := 1;
  for iCounter := 1 to iLen do
  begin
    if (sData[iCounter] = ' ') or (iCounter = iLen) then
    begin
      pCopy[iCounter-1] := #0;
      if pCursor^ <> #0 then
      begin
        SetLength(aArr, iIdx + 1);
        aArr[iIdx] := TextBufToUInt(pCursor);
        Inc(iIdx);
      end;
      Inc(pCursor, iInt);
      iInt := 0;
    end;
    Inc(iInt);
  end;
  FreeMem(pCopy);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1211; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure StringToDynArray(const sData: string; var aArr: TSingleDynArray);
var
  pCopy, pCursor: PChar;
  iLen: Integer;
  iCounter, iIdx, iInt: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1212 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if sData = '' then Exit;
  iLen := Length(sData);
  Inc(iLen);
  GetMem(pCopy, iLen);
  Move(Pointer(sData)^, pCopy^, iLen);
  pCursor := pCopy;
  aArr := nil;
  iIdx := 0;
  iInt := 1;
  for iCounter := 1 to iLen do
  begin
    if (sData[iCounter] = ' ') or (iCounter = iLen) then
    begin
      pCopy[iCounter-1] := #0;
      if pCursor^ <> #0 then
      begin
        SetLength(aArr, iIdx + 1);
        aArr[iIdx] := atof(pCursor);
        Inc(iIdx);
      end;
      Inc(pCursor, iInt);
      iInt := 0;
    end;
    Inc(iInt);
  end;
  FreeMem(pCopy);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1212; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure StringToDynArray(const sData: string; var aArr: TLongWordDynArray; cSeparator: Char);
var
  pCopy, pCursor: PChar;
  iLen: Integer;
  iCounter, iIdx, iInt: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1213 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if sData = '' then Exit;
  iLen := Length(sData);
  Inc(iLen);
  GetMem(pCopy, iLen);
  Move(Pointer(sData)^, pCopy^, iLen);
  pCursor := pCopy;
  aArr := nil;
  iIdx := 0;
  iInt := 1;
  for iCounter := 1 to iLen do
  begin
    if (sData[iCounter] = cSeparator) or (iCounter = iLen) then
    begin
      pCopy[iCounter-1] := #0;
      if pCursor^ <> #0 then
      begin
        SetLength(aArr, iIdx + 1);
        aArr[iIdx] := TextBufToUInt(pCursor);
        Inc(iIdx);
      end;
      Inc(pCursor, iInt);
      iInt := 0;
    end;
    Inc(iInt);
  end;
  FreeMem(pCopy);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1213; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure StringToDynArray(const sData: string; var aArr: TSingleDynArray; cSeparator: Char);
var
  pCopy, pCursor: PChar;
  iLen: Integer;
  iCounter, iIdx, iInt: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1214 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if sData = '' then Exit;
  iLen := Length(sData);
  Inc(iLen);
  GetMem(pCopy, iLen);
  Move(Pointer(sData)^, pCopy^, iLen);
  pCursor := pCopy;
  aArr := nil;
  iIdx := 0;
  iInt := 1;
  for iCounter := 1 to iLen do
  begin
    if (sData[iCounter] = cSeparator) or (iCounter = iLen) then
    begin
      pCopy[iCounter-1] := #0;
      if pCursor^ <> #0 then
      begin
        SetLength(aArr, iIdx + 1);
        aArr[iIdx] := atof(pCursor);
        Inc(iIdx);
      end;
      Inc(pCursor, iInt);
      iInt := 0;
    end;
    Inc(iInt);
  end;
  FreeMem(pCopy);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1214; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure StringToArray(const sData: string; var aArr: array of Longword);
var
  pCopy, pCursor: PChar;
  iLen: Integer;
  iArrLen: Integer;
  iCounter, iIdx, iInt: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1215 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if sData = '' then Exit;
  iArrLen := Length(aArr);
  if iArrLen = 0 then Exit;
  iLen := Length(sData);
  Inc(iLen);
  pCopy := AllocMem(iLen);
  Move(Pointer(sData)^, pCopy^, iLen);
  pCursor := pCopy;
  iIdx := 0;
  iInt := 1;
  for iCounter := 1 to iLen do
  begin
    if (sData[iCounter] = ' ') or (iCounter = iLen) then
    begin
      pCopy[iCounter-1] := #0;
      if pCursor^ <> #0 then
      begin
        aArr[iIdx] := TextBufToUInt(pCursor);
        Inc(iIdx);
        if iIdx = iArrLen then
        begin
          FreeMem(pCopy);
          Exit;
        end;
      end;
      Inc(pCursor, iInt);
      iInt := 0;
    end;
    Inc(iInt);
  end;
  FreeMem(pCopy);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1215; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure StringToArray(const sData: string; var aArr: array of Single);
var
  pCopy, pCursor: PChar;
  iLen: Integer;
  iArrLen: Integer;
  iCounter, iIdx, iInt: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1216 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if sData = '' then Exit;
  iArrLen := Length(aArr);
  if iArrLen = 0 then Exit;
  iLen := Length(sData);
  Inc(iLen);
  pCopy := AllocMem(iLen);
  Move(Pointer(sData)^, pCopy^, iLen);
  pCursor := pCopy;
  iIdx := 0;
  iInt := 1;
  for iCounter := 1 to iLen do
  begin
    if (sData[iCounter] = ' ') or (iCounter = iLen) then
    begin
      pCopy[iCounter-1] := #0;
      if pCursor^ <> #0 then
      begin
        TextBufToFloat(pCursor, aArr[iIdx]);
        Inc(iIdx);
        if iIdx = iArrLen then
        begin
          FreeMem(pCopy);
          Exit;
        end;
      end;
      Inc(pCursor, iInt);
      iInt := 0;
    end;
    Inc(iInt);
  end;
  FreeMem(pCopy);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1216; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function StringsEqual(const sStr1, sStr2: string): Boolean;
asm
  CMP   EAX, EDX
  JE    @@CompareDoneNoPop
  TEST  EAX, EDX
  JZ    @@PossibleNilString
@@BothStringsNonNil:
  MOV   ECX, [EAX-4]
  CMP   ECX, [EDX-4]
  JNE   @@CompareDoneNoPop
  PUSH  EBX
  LEA   EDX, [EDX+ECX-4]
  LEA   EBX, [EAX+ECX-4]
  NEG   ECX
  MOV   EAX, [EBX]
  CMP   EAX, [EDX]
  JNE   @@CompareDonePop
@@CompareLoop:
  ADD   ECX, 4
  JNS   @@Match
  MOV   EAX, [EBX+ECX]
  CMP   EAX, [EDX+ECX]
  JE    @@CompareLoop
@@CompareDonePop:
  POP   EBX
@@CompareDoneNoPop:
  SETZ  AL
  RET
@@Match:
  MOV   AL, 1
  POP   EBX
  RET
@@PossibleNilString:
  TEST  EAX, EAX
  JZ    @@FirstStringNil
  TEST  EDX, EDX
  JNZ   @@BothStringsNonNil
  CMP   [EAX-4], EDX
  SETZ  AL
  RET
@@FirstStringNil:
  CMP   EAX, [EDX-4]
  SETZ  AL
end;

function StringsEqualNoCase(const sStr1, sStr2: string): Boolean;
asm
  CMP   EAX, EDX
  JE    @@CompareDoneNoPop
  TEST  EAX, EDX
  JZ    @@PossibleNilString
@@BothStringsNonNil:
  MOV   ECX, [EAX-4]
  CMP   ECX, [EDX-4]
  JNE   @@CompareDoneNoPop
  PUSH  EBX
  PUSH  ESI
  PUSH  EDI
  PUSH  EBP
  LEA   EDX, [EDX+ECX-4]
  LEA   EBX, [EAX+ECX-4]
  NEG   ECX
  MOV   ESI, [EBX]
  MOV   EBP, $7F7F7F7F
  MOV   EDI, ESI
  NOT   EDI
  AND   EBP, ESI
  AND   EDI, $80808080
  ADD   EBP, $05050505
  AND   EBP, $7F7F7F7F
  ADD   EBP, $1A1A1A1A
  AND   EBP, EDI
  SHR   EBP, 2
  SUB   ESI, EBP
  MOV   EAX, [EDX]
  MOV   EBP, $7F7F7F7F
  MOV   EDI, EAX
  NOT   EDI
  AND   EBP, EAX
  AND   EDI, $80808080
  ADD   EBP, $05050505
  AND   EBP, $7F7F7F7F
  ADD   EBP, $1A1A1A1A
  AND   EBP, EDI
  SHR   EBP, 2
  SUB   EAX, EBP
  CMP   EAX, ESI
  JNE   @@CompareDonePop
@@CompareLoop:
  ADD   ECX, 4
  JNS   @@Match
  MOV   ESI, [EBX+ECX]
  MOV   EBP, $7F7F7F7F
  MOV   EDI, ESI
  NOT   EDI
  AND   EBP, ESI
  AND   EDI, $80808080
  ADD   EBP, $05050505
  AND   EBP, $7F7F7F7F
  ADD   EBP, $1A1A1A1A
  AND   EBP, EDI
  SHR   EBP, 2
  SUB   ESI, EBP
  MOV   EAX, [EDX+ECX]
  MOV   EBP, $7F7F7F7F
  MOV   EDI, EAX
  NOT   EDI
  AND   EBP, EAX
  AND   EDI, $80808080
  ADD   EBP, $05050505
  AND   EBP, $7F7F7F7F
  ADD   EBP, $1A1A1A1A
  AND   EBP, EDI
  SHR   EBP, 2
  SUB   EAX, EBP
  CMP   EAX, ESI
  JE    @@CompareLoop
@@CompareDonePop:
  POP   EBP
  POP   EDI
  POP   ESI
  POP   EBX
@@CompareDoneNoPop:
  SETZ  AL
  RET
@@Match:
  MOV   AL, 1
  POP   EBP
  POP   EDI
  POP   ESI
  POP   EBX
  RET
@@PossibleNilString:
  TEST  EAX, EAX
  JZ    @@FirstStringNil
  TEST  EDX, EDX
  JNZ   @@BothStringsNonNil
  CMP   [EAX-4], EDX
  SETZ  AL
  RET
@@FirstStringNil:
  CMP   EAX, [EDX-4]
  SETZ  AL
end;

function StringsCompare(const sStr1, sStr2: string): Integer;
asm
  CMP    EAX, EDX
  JE     @@DoneEqual
  TEST   EAX, EDX
  JZ     @@PossibleNilString
@@BothStringsNonNil:
  MOV    CL, [EDX]
  CMP    [EAX], CL
  JNE    @@DoneNoPop
  PUSH   EBX
  MOV    EBX, [EAX-4]
  SUB    EBX, [EDX-4]
  PUSH   EBX
  SBB    ECX, ECX
  AND    ECX, EBX
  SUB    ECX, [EAX-4]
  SUB    EAX, ECX
  SUB    EDX, ECX
@@CompareLoop:
  MOV    EBX, [EAX+ECX]
  XOR    EBX, [EDX+ECX]
  JNZ    @@Mismatch
  ADD    ECX, 4
  JS     @@CompareLoop
@@DoneEqualPop:
  POP    EBX
  POP    EBX
@@DoneEqual:
  XOR    EAX, EAX
  RET
@@DonePop:
  POP    EBX
@@DoneNoPop:
  JC     @@Lesser
@@Greater:
  MOV    EAX, 1
  RET
@@Lesser:
  OR     EAX, -1
  RET
@@Mismatch:
  BSF    EBX, EBX
  SHR    EBX, 3
  ADD    ECX, EBX
  JNS    @@DoneEqualPop
  MOV    AL, [EAX+ECX]
  CMP    AL, [EDX+ECX]
  POP    EBX
  JMP    @@DonePop
@@PossibleNilString:
  TEST   EAX, EAX
  JZ     @@FirstStringNil
  TEST   EDX, EDX
  JNZ    @@BothStringsNonNil
  MOV    EAX, 1
  RET
@@FirstStringNil:
  OR     EAX, -1
end;

function StringsCompareNoCase(const sStr1, sStr2: string): Integer;
asm
  CMP    EAX, EDX
  JE     @@DoneEqual
  TEST   EAX, EDX
  JZ     @@PossibleNilString
@@BothStringsNonNil:
  MOV    CL, [EDX]
  MOV    CH, [EAX]
  CMP    CL, 'z'
  JA     @@SkipCharUpper1
  CMP    CL, 'a'
  JB     @@SkipCharUpper1
  SUB    CL, 32
@@SkipCharUpper1:
  CMP    CH, 'z'
  JA     @@SkipCharUpper2
  CMP    CH, 'a'
  JB     @@SkipCharUpper2
  SUB    CH, 32
@@SkipCharUpper2:
  CMP    CL, CH
  JNE    @@DoneNoPop
  PUSH   EBX
  MOV    EBX, [EAX-4]
  SUB    EBX, [EDX-4]
  PUSH   EBX
  SBB    ECX, ECX
  AND    ECX, EBX
  SUB    ECX, [EAX-4]
  SUB    EAX, ECX
  SUB    EDX, ECX
  PUSH   ESI
  PUSH   EDI
  PUSH   EBP
@@CompareLoop:
  MOV    EBX, [EAX+ECX]
  CMP    EBX, [EDX+ECX]
  JE     @@SkipUppercasing
  MOV    EDI, $7F7F7F7F
  MOV    ESI, EBX
  NOT    ESI
  AND    EDI, EBX
  AND    ESI, $80808080
  ADD    EDI, $05050505
  AND    EDI, $7F7F7F7F
  ADD    EDI, $1A1A1A1A
  AND    EDI, ESI
  SHR    EDI, 2
  SUB    EBX, EDI
  MOV    ESI, [EDX+ECX]
  MOV    EDI, $7F7F7F7F
  MOV    EBP, ESI
  NOT    EBP
  AND    EDI, ESI
  AND    EBP, $80808080
  ADD    EDI, $05050505
  AND    EDI, $7F7F7F7F
  ADD    EDI, $1A1A1A1A
  AND    EDI, EBP
  SHR    EDI, 2
  SUB    ESI, EDI
  XOR    EBX, ESI
  JNZ    @@Mismatch
@@SkipUppercasing:
  ADD    ECX, 4
  JS     @@CompareLoop
@@DoneEqualPop:
  POP    EBP
  POP    EDI
  POP    ESI
  POP    EBX
  POP    EBX
@@DoneEqual:
  XOR    EAX, EAX
  RET
@@DonePop:
  POP    EBX
@@DoneNoPop:
  JC     @@Lesser
@@Greater:
  MOV    EAX, 1
  RET
@@Lesser:
  OR     EAX, -1
  RET
@@Mismatch:
  BSF    EBX, EBX
  SHR    EBX, 3
  ADD    ECX, EBX
  JNS    @@DoneEqualPop
  MOV    AL, [EAX+ECX]
  MOV    AH, [EDX+ECX]
  CMP    AL, 'z'
  JA     @@SkipCharUpper1B
  CMP    AL, 'a'
  JB     @@SkipCharUpper1B
  SUB    AL, 32
@@SkipCharUpper1B:
  CMP    AH, 'z'
  JA     @@SkipCharUpper2B
  CMP    AH, 'a'
  JB     @@SkipCharUpper2B
  SUB    AH, 32
@@SkipCharUpper2B:
  CMP    AL, AH
  POP    EBP
  POP    EDI
  POP    ESI
  POP    EBX
  JMP    @@DonePop
@@PossibleNilString:
  TEST   EAX, EAX
  JZ     @@FirstStringNil
  TEST   EDX, EDX
  JNZ    @@BothStringsNonNil
  MOV    EAX, 1
  RET
@@FirstStringNil:
  OR     EAX, -1
end;

function StrMCmp(Str: PChar; Mask: PChar): Boolean;
var
  Temp: PChar;
  MustNotMatch: Integer;
  MustMatch: Integer;
  CmpRes: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1217 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if not Assigned(Str) or not Assigned(Mask) then Exit;
  if (Str^ = #0) or (Mask^ = #0) then Exit;

  MustNotMatch := 0;

  while True do
  begin
    case Mask^ of
      '?':
      begin
        while Mask^ = '?' do
        begin
          Inc(Mask);
          Inc(MustNotMatch);
        end;
      end;
      '*':
      begin
        while Mask^ = '*' do Inc(Mask);

        if Mask^ = #0 then
        begin
          Result := True;
          Exit;
        end;

        MustNotMatch := MAXINT;
      end;
    else
      begin
        if Str^ = Mask^ then
        begin
          if Str^ = #0 then
          begin
            Result := True;
            Exit;
          end;

          MustNotMatch := 0;
          Inc(Str);
          Inc(Mask);
        end else
        begin
          if MustNotMatch = 0 then Exit;

          Temp := Mask;
          MustMatch := 0;

          while not (Temp^ in [#0, '?', '*']) do
          begin
            Inc(MustMatch);
            Inc(Temp);
          end;

          CmpRes := -1;
          while (MustNotMatch > 0) and (Str^ <> #0) do
          begin
            CmpRes := StrLComp(Str, Mask, MustMatch);
            if CmpRes = 0 then Break;
            Inc(Str);
            Dec(MustNotMatch);
          end;

          if MustNotMatch = 0 then
          begin
            CmpRes := StrLComp(Str, Mask, MustMatch);
          end;

          if CmpRes = 0 then
          begin
            MustNotMatch := 0;
            Inc(Str);
            Inc(Mask);
          end else Exit;
        end;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1217; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function StrMICmp(Str: PChar; Mask: PChar): Boolean;
var
  Temp: PChar;
  MustNotMatch: Integer;
  MustMatch: Integer;
  CmpRes: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1218 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if not Assigned(Str) or not Assigned(Mask) then Exit;
  if (Str^ = #0) or (Mask^ = #0) then Exit;

  MustNotMatch := 0;

  while True do
  begin
    case Mask^ of
      '?':
      begin
        while Mask^ = '?' do
        begin
          Inc(Mask);
          Inc(MustNotMatch);
        end;
      end;
      '*':
      begin
        while Mask^ = '*' do Inc(Mask);

        if Mask^ = #0 then
        begin
          Result := True;
          Exit;
        end;

        MustNotMatch := MAXINT;
      end;
    else
      begin
        if UpCase(Str^) = UpCase(Mask^) then
        begin
          if Str^ = #0 then
          begin
            Result := True;
            Exit;
          end;

          MustNotMatch := 0;
          Inc(Str);
          Inc(Mask);
        end else
        begin
          if MustNotMatch = 0 then Exit;

          Temp := Mask;
          MustMatch := 0;

          while not (Temp^ in [#0, '?', '*']) do
          begin
            Inc(MustMatch);
            Inc(Temp);
          end;

          CmpRes := -1;
          while (MustNotMatch > 0) and (Str^ <> #0) do
          begin
            CmpRes := StrLIComp(Str, Mask, MustMatch);
            if CmpRes = 0 then Break;
            Inc(Str);
            Dec(MustNotMatch);
          end;

          if MustNotMatch = 0 then
          begin
            CmpRes := StrLIComp(Str, Mask, MustMatch);
          end;

          if CmpRes = 0 then
          begin
            MustNotMatch := 0;
            Inc(Str);
            Inc(Mask);
          end else Exit;
        end;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1218; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function StringsMaskCompare(const Str: string; const Mask: string): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1219 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := StrMCmp(PChar(Str), PChar(Mask));
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1219; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function StringsMaskCompareNoCase(const Str: string; const Mask: string): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1220 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := StrMICmp(PChar(Str), PChar(Mask));
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1220; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function StringSplit(const sStr: string; var aArr: array of string; cDelim: Char = ' '): Boolean;
var
  iLen: Integer;
  iCounter, iIdx, iLast: Integer;
  sTemp: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1221 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if sStr = '' then
  begin
    Result := True;
    Exit;
  end;
  iCounter := 0;
  iLen := High(aArr);
  iLast := 1;
  iIdx := CharPos(cDelim, sStr);
  while iIdx <> 0 do
  begin
    sTemp := Copy(sStr, iLast, iIdx - iLast);
    if sTemp <> '' then
    begin
      if iCounter > iLen then
      begin
        Result := False;
        Exit;
      end;
      aArr[iCounter] := sTemp;
      Inc(iCounter);
    end;
    Inc(iIdx);
    iLast := iIdx;
    iIdx := CharPosEx(cDelim, sStr, iIdx);
  end;
  iLen := Length(sStr);
  if iLen <> 0 then
  begin
    sTemp := Copy(sStr, iLast, iLen);
    if sTemp <> '' then
    begin
      aArr[iCounter] := sTemp;
    end;
  end;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1221; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function StringSplit(const sStr: string; cDelim: Char = ' '): TStringDynArray;
var
  iLen: Integer;
  iCounter, iIdx, iLast: Integer;
  sTemp: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1222 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if sStr = '' then
  begin
    Result := nil;
    Exit;
  end;
  iCounter := 0;
  iLast := 1;
  iIdx := CharPos(cDelim, sStr);
  while iIdx <> 0 do
  begin
    sTemp := Copy(sStr, iLast, iIdx - iLast);
    if sTemp <> '' then
    begin
      SetLength(Result, iCounter + 1);
      Result[iCounter] := sTemp;
      Inc(iCounter);
    end;
    Inc(iIdx);
    iLast := iIdx;
    iIdx := CharPosEx(cDelim, sStr, iIdx);
  end;
  iLen := Length(sStr);
  if iLen <> 0 then
  begin
    sTemp := Copy(sStr, iLast, iLen);
    if sTemp <> '' then
    begin
      SetLength(Result, iCounter + 1);
      Result[iCounter] := sTemp;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1222; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function StrLen(const pStr: PChar): Longword;
asm
  CMP   BYTE PTR [EAX], 0
  JE    @@0
  CMP   BYTE PTR [EAX+1], 0
  JE    @@1
  CMP   BYTE PTR [EAX+2], 0
  JE    @@2
  CMP   BYTE PTR [EAX+3], 0
  JE    @@3
  PUSH  EAX
  SUB   EAX, 4
@@Loop:
  ADD   EAX, 4
  MOV   EDX, [EAX]
  LEA   ECX, [EDX-$01010101]
  NOT   EDX
  AND   EDX, ECX
  AND   EDX, $80808080
  JZ    @@Loop
@@SetResult:
  POP   ECX
  BSF   EDX, EDX
  SHR   EDX, 3
  ADD   EAX, EDX
  SUB   EAX, ECX
  RET
@@0:
  XOR   EAX, EAX
  RET
@@1:
  MOV   EAX, 1
  RET
@@2:
  MOV   EAX, 2
  RET
@@3:
  MOV   EAX, 3
end;

function PCharToString(const pSource: PChar; var sDest: string): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1223 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := StrLen(pSource);
  SetLength(sDest, Result);
  Move(pSource^, Pointer(sDest)^, Result);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1223; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TrimStr(var sStr: string);
const
  ResTable: array[Boolean, Boolean] of Integer = (
    (0, 1),
    (2, 3)
  );
var
  iStart1, iStart2: Integer;
  iEnd1, iEnd2: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1224 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if sStr = '' then Exit;
  iEnd2 := Length(sStr);
  iStart1 := 1;

  for iEnd1 := 1 to iEnd2 do
  begin
    if sStr[iEnd1] <> ' ' then
    begin
      Break;
    end;
  end;
  Dec(iEnd1);

  if iEnd1 = iEnd2 then
  begin
    sStr := '';
    Exit;
  end;

  for iStart2 := iEnd2 downto 1 do
  begin
    if sStr[iStart2] <> ' ' then
    begin
      Break;
    end;
  end;
  Inc(iStart2);

  case ResTable[iEnd1 = 0, iStart2 = iEnd2 + 1] of
    0:
    begin
      { Whitespace both before and after the text }
      UniqueString(sStr);
      OffsetMove(Pointer(sStr)^, Pointer(sStr)^, iStart2 - iEnd1, iEnd1, 0);
      SetLength(sStr, iEnd2 - (iEnd2 - iStart2) - (iEnd1 - iStart1) - 2);
    end;
    1:
    begin
      { Whitespace only before the text }
      UniqueString(sStr);
      OffsetMove(Pointer(sStr)^, Pointer(sStr)^, iStart2 - iEnd1, iEnd1, 0);
      SetLength(sStr, iEnd2 - (iEnd2 - iStart2) - 2);
    end;
    2:
    begin
      { Whitespace only after the text }
      SetLength(sStr, iEnd2 - (iEnd1 - iStart1) - 2);
    end;
    3: { No whitespace at all };
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1224; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function CharPos(cChr: Char; const sStr: string): Integer;
asm
  TEST  EDX, EDX
  JZ    @@Ret0
  PUSH  EBP
  PUSH  EBX
  PUSH  EDX
  PUSH  ESI
  PUSH  EDI
  MOV   ECX, [EDX-4]
  NOT   ECX
  JZ    @@Pop0
  MOV   AH, AL
  ADD   ECX, 1
  MOVZX EDI, AX
  AND   ECX, -4
  SHL   EAX, 16
  SUB   EDX, ECX
  OR    EDI, EAX
  MOV   EBP, $80808080
  MOV   EAX, EDI
  XOR   EDI, [ECX+EDX]
  MOV   ESI, EAX
  LEA   EBX, [EDI-$01010101]
  NOT   EDI
  AND   EBX, EDI
  ADD   ECX, 4
  JGE   @@Last1
  AND   EBX,EBP
  JNZ   @@Found4
  XOR   ESI, [ECX+EDX]
  MOV   EBP, EBP
@@Find:
  LEA   EBX, [ESI-$01010101]
  NOT   ESI
  AND   EBX, ESI
  MOV   EDI, [ECX+EDX+4]
  ADD   ECX, 8
  JGE   @@Last2
  XOR   EDI, EAX
  AND   EBX, EBP
  MOV   ESI, [ECX+EDX]
  JNZ   @@Found0
  LEA   EBX, [EDI-$01010101]
  NOT   EDI
  AND   EBX, EDI
  XOR   ESI, EAX
  AND   EBX, EBP
  JZ    @@Find
@@Found4:
  ADD   ECX, 4
@@Found0:
  SHR   EBX, 8
  JC    @@Inc0
  SHR   EBX, 8
  JC    @@Inc1
  SHR   EBX, 8
  JC    @@Inc2
@@Inc3:
  INC   ECX
@@Inc2:
  INC   ECX
@@Inc1:
  INC   ECX
@@Inc0:
  POP   EDI
  POP   ESI
  LEA   EAX, [ECX+EDX-7]
  POP   EDX
  POP   EBX
  SUB   EAX, EDX
  POP   EBP
  CMP   EAX, [EDX-4]
  JG    @@Ret0
  RET
@@Last2:
  AND   EBX, EBP
  JNZ   @@Found0
  XOR   EDI, EAX
  LEA   EBX, [EDI-$01010101]
  NOT   EDI
  AND   EBX, EDI
@@Last1:
  AND   EBX, EBP
  JNZ   @@Found4
@@Pop0:
  POP   EDI
  POP   ESI
  POP   EDX
  POP   EBX
  POP   EBP
@@Ret0:
  XOR   EAX, EAX
end;

function CharPosEx(cChr: Char; const sStr: string; iOffset: Integer): Integer;
asm
  TEST  EDX, EDX
  JZ    @@Ret0
  PUSH  EBP
  PUSH  EBX
  PUSH  EDX
  PUSH  ESI
  PUSH  EDI
  MOV   EBX, ECX
  MOV   ECX, [EDX-4]
  SUB   ECX, EBX
  ADD   EDX, EBX
  NOT   ECX
  JZ    @@Pop0
  MOV   AH, AL
  ADD   ECX, 1
  MOVZX EDI, AX
  AND   ECX, -4
  SHL   EAX, 16
  SUB   EDX, ECX
  OR    EDI, EAX
  MOV   EBP, $80808080
  MOV   EAX, EDI
  XOR   EDI, [ECX+EDX]
  MOV   ESI, EAX
  LEA   EBX, [EDI-$01010101]
  NOT   EDI
  AND   EBX, EDI
  ADD   ECX, 4
  JGE   @@Last1
  AND   EBX, EBP
  JNZ   @@Found4
  XOR   ESI, [ECX+EDX]
  MOV   EBP, EBP
@@Find:
  LEA   EBX, [ESI-$01010101]
  NOT   ESI
  AND   EBX, ESI
  MOV   EDI, [ECX+EDX+4]
  ADD   ECX, 8
  JGE   @@Last2
  XOR   EDI, EAX
  AND   EBX, EBP
  MOV   ESI, [ECX+EDX]
  JNZ   @@Found0
  LEA   EBX, [EDI-$01010101]
  NOT   EDI
  AND   EBX, EDI
  XOR   ESI, EAX
  AND   EBX, EBP
  JZ    @@Find
@@Found4:
  ADD   ECX, 4
@@Found0:
  SHR   EBX, 8
  JC    @@Inc0
  SHR   EBX, 8
  JC    @@Inc1
  SHR   EBX, 8
  JC    @@Inc2
@@Inc3:
  INC   ECX
@@Inc2:
  INC   ECX
@@Inc1:
  INC   ECX
@@Inc0:
  POP   EDI
  POP   ESI
  LEA   EAX, [ECX+EDX-7]
  POP   EDX
  POP   EBX
  SUB   EAX, EDX
  POP   EBP
  CMP   EAX, [EDX-4]
  JG    @@Ret0
  RET
@@Last2:
  AND   EBX, EBP
  JNZ   @@Found0
  XOR   EDI, EAX
  LEA   EBX, [EDI-$01010101]
  NOT   EDI
  AND   EBX, EDI
@@Last1:
  AND   EBX,EBP
  JNZ   @@Found4
@@Pop0:
  POP   EDI
  POP   ESI
  POP   EDX
  POP   EBX
  POP   EBP
@@Ret0:
  XOR   EAX, EAX
end;

function GetStrRef(const sStr: string): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1225 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := Integer(sStr);
  if Result <> 0 then Result := PInteger(Result - 8)^;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1225; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure IncStrRef(const sStr: string; iAddend: Integer);
var
  iAdr: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1226 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if iAddend = 0 then Exit;
  iAdr := Integer(sStr);
  if iAdr <> 0 then
  begin
    Dec(iAdr, 8);
    { TODO -oSeth -cThread-unsafe : replace with an interlocked function }
    PInteger(iAdr)^ := PInteger(iAdr)^ + iAddend;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1226; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure DecStrRef(const sStr: string; iAddend: Integer);
var
  iAdr: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1227 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if iAddend = 0 then Exit;
  iAdr := Integer(sStr);
  if iAdr <> 0 then
  begin
    Dec(iAdr, 8);
    { TODO -oSeth -cThread-unsafe : replace with an interlocked function }
    PInteger(iAdr)^ := PInteger(iAdr)^ - iAddend;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1227; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function FileNameToOS(const sName: string): string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1228 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  { No Change on Win32 }
  Result := StringReplace(sName, '{$YROOT}',
    ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))), [rfReplaceAll]);
  Result := StringReplace(Result, '/', '\', [rfReplaceAll]);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1228; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure AssignIfZero(pTarget: PLongword; lwValue: Longword);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1229 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if pTarget^ = 0 then pTarget^ := lwValue;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1229; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure AssignIfZero(pTarget: PSingle; fValue: Single);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1230 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if pTarget^ = 0 then pTarget^ := fValue;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1230; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure OutputToLog(const sLogName, sMsg: string; bAddDate: Boolean; iLimit: Integer);
{const
  CRLF = #13#10;
var
  hHandle: Integer;
  tInfo: TByHandleFileInformation;
  pBuf: Pointer;
  pC: PChar;
  sDate: string;
  iMsgLen: Integer;
  iDateLen: Integer;
  iWriteCount: Integer; }
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1231 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  (*
  if bAddDate then
  begin
    sDate := StringReplace(DateTimeToStr(Now), '. ', '-', [rfReplaceAll]);
    sDate := sDate + ': ';
    iDateLen := Length(sDate);
  end else
  begin
    sDate := '';
    iDateLen := 0;
  end;
  if not FileExists(sLogName) then
  begin
    hHandle := FileCreate(sLogName);
    if hHandle = -1 then Exit;
  end else
  begin
    hHandle := FileOpen(sLogName, fmOpenReadWrite);
    if hHandle = -1 then Exit;
  end;
  iMsgLen := Length(sMsg);
  GetFileInformationByHandle(hHandle, tInfo);
  if (tInfo.nFileSizeLow <> 0) and (iLimit <> 0) then
  begin
    if Integer(tInfo.nFileSizeLow) + iMsgLen + iDateLen + 2 > iLimit then
    begin
      GetMem(pBuf, tInfo.nFileSizeLow);
      FileRead(hHandle, pBuf^, tInfo.nFileSizeLow);
      pC := pBuf;
      iWriteCount := tInfo.nFileSizeLow;
      Inc(tInfo.nFileSizeLow, iMsgLen + iDateLen + 2);
      while ((pC^ <> #13) or (Integer(tInfo.nFileSizeLow) > iLimit)) and
            (Integer(pC) - Integer(pBuf) <> iWriteCount) do
      begin
        Inc(pC);
        Dec(tInfo.nFileSizeLow);
      end;
      if PC^ = #13 then Inc(PC, 2);
      Dec(iWriteCount, Integer(pC) - Integer(pBuf));
      FileSeek(hHandle, 0, soFromBeginning);
      FileWrite(hHandle, pC^, iWriteCount);
      FreeMem(pBuf);
    end else
    begin
      FileSeek(hHandle, 0, soFromEnd);
    end;
  end;
  FileWrite(hHandle, Pointer(sDate)^, iDateLen);
  FileWrite(hHandle, Pointer(sMsg)^, iMsgLen);
  FileWrite(hHandle, CRLF[1], 2);
  SetEndOfFile(hHandle);
  FileClose(hHandle);
  *)
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1231; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function GetImplementorOfInterface(const I: IInterface): Pointer;
const
  AddByte = $04244483; // opcode for ADD DWORD PTR [ESP+4], Shortint
  AddLong = $04244481; // opcode for ADD DWORD PTR [ESP+4], Longint
type
  PInterfaceThunk = ^YInterfaceThunk;
  YInterfaceThunk = packed record
    case AddInstruction: Integer of
      AddByte: (AdjustmentByte: ShortInt);
      AddLong: (AdjustmentLong: Integer);
  end;

  YQueryInterfaceThunk = ^PInterfaceThunk;
  PQueryInterfaceThunk = ^YQueryInterfaceThunk;
var
  Thunk: PInterfaceThunk;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1232 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  try
    Result := Pointer(I);
    if Assigned(Result) then
    begin
      Thunk := PQueryInterfaceThunk(I)^^;
      case Thunk^.AddInstruction of
        AddByte:
          Inc(PChar(Result), Thunk^.AdjustmentByte);
        AddLong:
          Inc(PChar(Result), Thunk^.AdjustmentLong);
      else
        Result := nil;
      end;
    end;
  except
    on E: EAccessViolation do
    begin
      Result := nil;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1232; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function GetTimeDifference(lwAfter, lwBefore: Longword): Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1233 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if lwAfter < lwBefore then
  begin
    Result :=  lwAfter + ($FFFFFFFF - lwBefore);
  end else
  begin
    Result := lwAfter - lwBefore;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1233; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure OffsetMove(const xSource; var xDest; iCount, iSourceOffset, iDestOffset: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1234 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Move(Pointer(Integer(@xSource) + iSourceOffset)^, Pointer(Integer(@xDest) + iDestOffset)^, iCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1234; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function IntIntPower(X: Integer; Power: Integer): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1235 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Power < 0 then
  begin
    Result := 0;
  end else if Power = 0 then
  begin
    Result := 1;
  end else
  begin
    if (Power and 1) <> 0 then
    begin
      Result := X;
    end else
    begin
      Result := 1;
    end;

    Power := Power shr 1;

    while Power <> 0 do
    begin
      X := X * X;
      if (Power and 1) <> 0 then Result := Result * X;
      Power := Power shr 1;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1235; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function Ceil32(const X: Single): Integer;
asm
  MOV   EAX, [ESP+8]
  CDQ
  SHL   EAX, 1
  JZ    @@Done
  MOV   ECX, EAX
  SHR   ECX, 24
  NEG   ECX
  ADD   ECX, 127 + 31
  CMP   ECX, 31
  JA    @@FractionOrTooLarge
  SHL   EAX, 7
  OR    EAX, $80000000
  MOV   EBP, EAX
  SHR   EAX, CL
  TEST  EDX, EDX
  JNS   @@PositiveNumber
  NEG   EAX
  JS    @@Done
@@RaiseInvalidOperationException:
  MOV   AL, reInvalidOp
  JMP   System.Error
@@PositiveNumber:
  TEST  EAX, EAX
  JS    @@RaiseInvalidOperationException
  OR    EDX, -1
  SHL   EDX, CL
  NOT   EDX
  AND   EDX, EBP
  JZ    @@Done
  ADD   EAX, 1
  JNS   @@Done
  JMP   @@RaiseInvalidOperationException
@@FractionOrTooLarge:
  TEST  ECX, ECX
  JS    @@RaiseInvalidOperationException
  LEA   EAX, [EDX+1]
@@Done:
end;

function Floor32(const X: Single): Integer;
asm
  MOV   EAX, [ESP+8]
  CDQ
  SHL   EAX, 1
  JZ    @@Done
  MOV   ECX, EAX
  SHR   ECX, 24
  NEG   ECX
  ADD   ECX, 127 + 31
  CMP   ECX, 31
  JA    @@FractionOrTooLarge
  SHL   EAX, 7
  OR    EAX, $80000000
  MOV   EBP, EAX
  SHR   EAX, CL
  TEST  EDX, EDX
  JS    @@NegativeNumber
  TEST  EAX, EAX
  JNS   @@Done
@@RaiseInvalidOperationException:
  MOV   AL, reInvalidOp
  JMP   System.Error
@@NegativeNumber:
  NEG   EAX
  JNS   @@RaiseInvalidOperationException
  SHL   EDX, CL
  NOT   EDX
  AND   EDX, EBP
  JZ    @@Done
  SUB   EAX, 1
  JS    @@Done
  JMP   @@RaiseInvalidOperationException
@@FractionOrTooLarge:
  TEST  ECX, ECX
  JS    @@RaiseInvalidOperationException
  MOV   EAX, EDX
@@Done:
end;

function Trunc32(const X: Single): Integer;
var
  OldCW, NewCW: Word;
asm
  FNSTCW OldCW
  MOVZX  EAX, OldCW
  OR     AX, $0F00
  MOV    NewCW, AX
  FLDCW  NewCW
  FLD    X
  FISTP  Result
  FLDCW  OldCW
end;

function DivMod(Dividend, Divisor: Integer; out Remainder: Integer): Integer;
asm
  PUSH  EBX
  MOV   EBX, EDX
  CDQ
  IDIV  EBX
  MOV   [ECX], EDX
  POP   EBX
end;

function DivModInc(Dividend, Divisor: Integer): Integer;
asm
  MOV   ECX, EDX
  CDQ
  IDIV  ECX
  TEST  EDX, EDX
  JZ    @@Skip
  INC   EAX
@@Skip:
end;

function DivModDec(Dividend, Divisor: Integer): Integer;
asm
  MOV   ECX, EDX
  CDQ
  IDIV  ECX
  TEST  EDX, EDX
  JZ    @@Skip
  DEC   EAX
@@Skip:
end;

function DivModPowerOf2(Dividend: Integer; Power: Longword; out Remainder: Integer): Integer;
asm
  PUSH  EBX
  PUSH  ESI
  MOV   EBX, EAX
  MOV   ESI, ECX
  MOV   ECX, EDX
  SAR   EAX, CL
  MOV   EDX, EAX
  SAL   EDX, CL
  SUB   EBX, EDX
  MOV   [ESI], EBX
  POP   ESI
  POP   EBX
end;

function DivModPowerOf2Inc(Dividend: Integer; Power: Longword): Integer;
asm
  PUSH  EBX
  MOV   EBX, EAX
  MOV   ECX, EDX
  SAR   EAX, CL
  MOV   EDX, EAX
  SAL   EDX, CL
  CMP   EBX, EDX
  JNA   @@Skip
  INC   EAX
@@Skip:
  POP   EBX
end;

function DivModPowerOf2Dec(Dividend: Integer; Power: Longword): Integer;
asm
  PUSH  EBX
  MOV   EBX, EAX
  MOV   ECX, EDX
  SAR   EAX, CL
  MOV   EDX, EAX
  SAL   EDX, CL
  CMP   EBX, EDX
  JNA   @@Skip
  DEC   EAX
@@Skip:
  POP   EBX
end;

function DivModU(Dividend, Divisor: Longword; out Remainder: Longword): Longword;
asm
  PUSH  EBX
  MOV   EBX, EDX
  XOR   EDX, EDX
  DIV   EBX
  MOV   [ECX], EDX
  POP   EBX
end;

function DivModUInc(Dividend, Divisor: Longword): Longword;
asm
  MOV   ECX, EDX
  XOR   EDX, EDX
  DIV   ECX
  TEST  EDX, EDX
  JZ    @@Skip
  INC   EAX
@@Skip:
end;

function DivModUDec(Dividend, Divisor: Longword): Longword;
asm
  MOV   ECX, EDX
  XOR   EDX, EDX
  DIV   ECX
  TEST  EDX, EDX
  JZ    @@Skip
  DEC   EAX
@@Skip:
end;

function DivModUPowerOf2(Dividend, Power: Longword; out Remainder: Longword): Longword;
asm
  PUSH  EBX
  PUSH  ESI
  MOV   ESI, ECX
  MOV   EBX, EAX
  MOV   ECX, EDX
  SHR   EAX, CL
  MOV   EDX, EAX
  SHL   EDX, CL
  SUB   EBX, EDX
  MOV   [ESI], EBX
  POP   ESI
  POP   EBX
end;

function DivModUPowerOf2Inc(Dividend, Power: Longword): Longword;
asm
  PUSH  EBX
  MOV   EBX, EAX
  MOV   ECX, EDX
  SHR   EAX, CL
  MOV   EDX, EAX
  SHL   EDX, CL
  CMP   EBX, EDX
  JNA   @@Skip
  INC   EAX
@@Skip:
  POP   EBX
end;

function DivModUPowerOf2Dec(Dividend, Power: Longword): Longword;
asm
  PUSH  EBX
  MOV   EBX, EAX
  MOV   ECX, EDX
  SHR   EAX, CL
  MOV   EDX, EAX
  SHL   EDX, CL
  CMP   EBX, EDX
  JNA   @@Skip
  DEC   EAX
@@Skip:
  POP   EBX
end;

function NextPowerOf2(I: Longword): Longword;
begin
  if I = 0 then
  begin
    Result := 0;
    Exit;
  end;
  
  Dec(I);
  Result := I or (I shr 1) or (I shr 2) or (I shr 4) or (I shr 8) or (I shr 16);
  Inc(Result);
end;

function GetCurrentReturnAddress: Pointer;
asm
  MOV   EAX, [EBP+4]
end;

procedure CalcOverhead;
var
  iInt: Integer;
  liStart, liEnd: Int64;
  liTemp: Int64;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1236 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  QueryPerformanceCounter(@liStart);
  for iInt := 0 to 99999 do
  begin
    QueryPerformanceCounter(@liTemp);
    QueryPerformanceCounter(@liTemp);
  end;
  QueryPerformanceCounter(@liEnd);
  Overhead := (liEnd - liStart) / 100000;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1236; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

type
  PObjectBlockHeader = ^TObjectBlockHeader;
  TObjectBlockHeader = packed record
    NumOfObjects: Integer;
  end;

procedure AllocateInstanceArray(ClassType: TClass; var Buffer: Pointer;
  Count: Int32);
var
  Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1237 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  /// Retreive the instance size of this class. InstanceSize - defined in TObject
  Size := ClassType.InstanceSize;

  /// Allocate the required amount of memory for the allocation process.
  /// This includes a Block header and then the memory for instances
  GetMem(Buffer, (Size * Count) + SizeOf(TObjectBlockHeader));

  /// Insert the number of Intences into the block header
  PObjectBlockHeader(Buffer)^.NumOfObjects := Count;

  /// Move the Pointer + Block Header and pass the
  /// pointer to the allocation method
  Inc(PByte(Buffer), SizeOf(TObjectBlockHeader));
  InitInstanceBlock(ClassType, Buffer, Count);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1237; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure AllocateInstanceArrayEx(ClassType: TClass; var Buffer: Pointer;
  Count: Int32; Callback: TEnumerationCallback);
var
  Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1238 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if @Callback = nil then
  begin
    /// If no callback was specied, call the simple Alloation Method
    AllocateInstanceArray(ClassType, Buffer, Count);
  end else
  begin
    /// Retreive the instance size of this class. InstanceSize - defined in TObject
    Size := ClassType.InstanceSize;

    /// Allocate the required amount of memory for the allocation process.
    /// This includes a Block header and then the memory for instances
    GetMem(Buffer, (Size * Count) + SizeOf(TObjectBlockHeader));

    /// Insert the number of Intences into the block header
    PObjectBlockHeader(Buffer)^.NumOfObjects := Count;

    /// Move the Pointer + Block Header and pass the
    /// pointer to the allocation method
    Inc(PByte(Buffer), SizeOf(TObjectBlockHeader));
    InitInstanceBlockEx(ClassType, Buffer, Count, Callback);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1238; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure Cleanup(Instance: TObject);
asm
  MOV   ECX, [EAX]
  XOR   DL, DL
  JMP   [ECX] + VMTOFFSET TObject.Destroy
end;

procedure CleanupInstanceBlock(ClassType: TClass; Block: Pointer; Count: Int32;
  InvokeDestructor: Boolean);
var
  Size: Integer;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1239 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  /// Retreive the instance size of this class. InstanceSize - defined in TObject
  Size := ClassType.InstanceSize;

  /// Loop "Count" number of times
  for I := 0 to Count -1 do
  begin
    /// Cleanup the instance memory - defined in TObject
    TObject(Block).CleanupInstance;

    /// In case of InvokeDestructor = true, call the destructor for this object
    if InvokeDestructor then
       Cleanup(Block);

    /// Increase the pointer with the size of instance
    Inc(PByte(Block), Size);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1239; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure CleanupInstanceBlockEx(ClassType: TClass; Block: Pointer;
  Count: Int32; InvokeDestructor: Boolean; Callback: TEnumerationCallback);
var
  Size: Integer;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1240 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  /// Retreive the instance size of this class. InstanceSize - defined in TObject
  Size := ClassType.InstanceSize;

  /// Loop "Count" number of times
  for I := 0 to Count -1 do
  begin
    /// Call the method with reported object.
    Callback(Block);

    /// Cleanup the instance memory - defined in TObject
    TObject(Block).CleanupInstance;

    /// In case of InvokeDestructor = true, call the destructor for this object
    if InvokeDestructor then
       Cleanup(Block);

    /// Increase the pointer with the size of instance
    Inc(PByte(Block), Size);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1240; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure ClearInstanceArray(ClassType: TClass; Buffer: Pointer;
  InvokeDestructor: Boolean);
var
  Local: PObjectBlockHeader;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1241 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  /// Find out the Block header
  Local := Pointer(Integer(Buffer) - SizeOf(TObjectBlockHeader));

  /// Cleanup the instances located in this buffer using CleanupInstanceBlock
  CleanupInstanceBlock(ClassType, Buffer, Local^.NumOfObjects, InvokeDestructor);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1241; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure ClearInstanceArrayEx(ClassType: TClass; Buffer: Pointer;
  InvokeDestructor: Boolean; Callback: TEnumerationCallback);
var
  Local: PObjectBlockHeader;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1242 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  /// If the callback was nil, call the simple method ClearInstanceArray
  if @Callback = nil then
  begin
    ClearInstanceArray(ClassType, Buffer, InvokeDestructor);
  end else
  begin
    /// Find out the Block header
    Local := Pointer(Integer(Buffer) - SizeOf(TObjectBlockHeader));

    /// Cleanup the instances located in this buffer using CleanupInstanceBlockEx
    CleanupInstanceBlockEx(ClassType, Buffer, Local^.NumOfObjects, InvokeDestructor, Callback);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1242; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure FreeInstanceArray(ClassType: TClass; var Buffer: Pointer;
  InvokeDestructor: Boolean);
var
  Local: PObjectBlockHeader;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1243 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  /// Extract the Header from the Buffer. Header contains the number of instances
  /// contained in this buffer.
  Local := Pointer(Longword(Buffer) - SizeOf(TObjectBlockHeader));

  /// Invoke private CleanupInstanceBlock to actually destroy the instances
  CleanupInstanceBlock(ClassType, Buffer, Local^.NumOfObjects, InvokeDestructor);

  /// Free the given memory and set it's pointer to nil.
  FreeMem(Local);
  Buffer := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1243; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure FreeInstanceArrayEx(ClassType: TClass; var Buffer: Pointer;
  InvokeDestructor: Boolean; Callback: TEnumerationCallback);
var
  Local: PObjectBlockHeader;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1244 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  /// If callback was nil call the simple FreeInstanceArray method
  if @Callback = nil then
  begin
    FreeInstanceArray(ClassType, Buffer, InvokeDestructor);
  end else
  begin
    /// Extract the Header from the Buffer. Header contains the number of instances
    /// contained in this buffer.
    Local := Pointer(Longword(Buffer) - SizeOf(TObjectBlockHeader));

    /// Invoke private CleanupInstanceBlockEx to actually destroy the instances
    CleanupInstanceBlockEx(ClassType, Buffer, Local^.NumOfObjects, InvokeDestructor, Callback);

    /// Free the given memory and set it's pointer to nil.
    FreeMem(Local);
    Buffer := nil;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1244; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure InitInstanceBlock(ClassType: TClass; Block: Pointer; Count: Int32);
var
  Size: Integer;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1245 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  /// Retreive the instance size of this class. InstanceSize - defined in TObject
  Size := ClassType.InstanceSize;

  /// Loop "Count" number of times
  for I := 0 to Count - 1 do
  begin
    /// Instantiate an instance into a given memory block. InitInstance - defined in TObject
    ClassType.InitInstance(Block);

    /// Increase the pointer with the size of instance
    Inc(PByte(Block), Size);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1245; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure InitInstanceBlockEx(ClassType: TClass; Block: Pointer; Count: Int32;
  Callback: TEnumerationCallback);
var
  Size: Integer;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1246 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  /// Retreive the instance size of this class. InstanceSize - defined in TObject
  Size := ClassType.InstanceSize;

  /// Loop "Count" number of times
  for I := 0 to Count -1 do
  begin
    /// Instantiate an instance into a given memory block. InitInstance - defined in TObject
    ClassType.InitInstance(Block);

    /// Call athe callback method with the given parameter
    Callback(Block);

    /// Increase the pointer with the size of instance
    Inc(PByte(Block), Size);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1246; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TReferencedObject }

function TReferencedObject.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1247 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_UNEXPECTED;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1247; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TReferencedObject._AddRef: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1248 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1248; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TReferencedObject._Release: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1249 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1249; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

initialization
  CacheLimit := CPUInfo.L2CacheSize * -512;
  QueryPerformanceFrequency(@CPUFrequency);
  CalcOverhead;

end.
