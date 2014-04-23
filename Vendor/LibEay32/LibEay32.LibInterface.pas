{*------------------------------------------------------------------------------
  LibEAY Interface
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit LibEay32.LibInterface;

interface

uses
  SysUtils;

type
  PPBigNumber = ^PBigNumber;
  PBigNumber = ^TBigNumber;
  TBigNumber = record
    Data: PLongword;
    Top: Integer;
    DMax: Integer;
    Neg: Integer;
    Flags: Longword;
  end;

type
  DWORD = Longword;
  BIGNUM = PBigNumber;
  PBIGNUM = PPBigNumber;
  BN_CTX = type Pointer;

const
  {$IFDEF MSWINDOWS}
  libeay32 = 'libeay32.dll';
  {$ELSE}
  libeay32 = 'libeay32.so';
  {$ENDIF}

  SHA_LBLOCK = 16;
  SHA_DIGEST_LENGTH = 20;

type
  PSHAContext = ^TSHAContext;
  TSHAContext = record
    H0: Longword;
    H1: Longword;
    H2: Longword;
    H3: Longword;
    H4: Longword;
    Nl: Longword;
    Nh: Longword;
    Data: array[0..SHA_LBLOCK-1] of Longword;
    Num: Longword;
  end;

  SHA_CTX = TSHAContext;
  PSHA_CTX = PSHAContext;

  PSHAData = ^TSHAData;
  TSHAData = record
    Ctx: TSHAContext;
    Digest: array[0..SHA_DIGEST_LENGTH-1] of Byte;
  end;

function SHA1_Init(scSrc: PSHA_CTX): Integer; cdecl; 
function SHA1_Update(scSrc: PSHA_CTX; const pData: Pointer; iLen: Integer): Integer; cdecl;
function SHA1_Final(pDigest: Pointer; scSrc: PSHA_CTX): Integer; cdecl; 

procedure BN_init(pBN: BIGNUM); cdecl; 
procedure BN_clear_free(pBN: BIGNUM); cdecl; 

function BN_set_word(bnSrc: BIGNUM; dwValue: DWORD): Integer; cdecl; 
function BN_lshift1(bnSrc: BIGNUM; dwShift: DWORD): Integer; cdecl; 
function BN_bin2bn(pSrc: PChar; iLen: Integer; bnOut: BIGNUM): BIGNUM; cdecl;
function BN_hex2bn(bnOut: PBIGNUM; pSrc: PChar): Integer; cdecl; 

function BN_pseudo_rand(bnOut: BIGNUM; iBits, iTop, iBottom: Integer): Integer; cdecl; 
function BN_copy(bnOut: BIGNUM; bnSrc: BIGNUM): BIGNUM; cdecl;

function BN_add(bnOut, bnSrc1, bnSrc2: BIGNUM): Integer; cdecl;
function BN_sub(bnOut, bnSrc1, bnSrc2: BIGNUM): Integer; cdecl;
function BN_mul(bnOut, bnSrc1, bnSrc2: BIGNUM; ctx: BN_CTX): Integer; cdecl; 

function BN_add_word(bnSrc: BIGNUM; dwValue: DWORD): Integer; cdecl;
function BN_sub_word(bnSrc: BIGNUM; dwValue: DWORD): Integer; cdecl; 
function BN_mul_word(bnSrc: BIGNUM; dwValue: DWORD): Integer; cdecl;

function BN_CTX_new: BN_CTX; cdecl; 
procedure BN_CTX_free(ctx: BN_CTX); cdecl; 

function BN_div(bnRes, bnRem, bnDividend, bnDivisor: BIGNUM; ctx: BN_CTX): Integer; cdecl;

function BN_exp(bnOut: BIGNUM; bnSrc, bnExp: BIGNUM; ctx: BN_CTX): Integer; cdecl; 
function BN_mod_exp(bnOut: BIGNUM; bnSrc, bnExp, bnMod: BIGNUM; ctx: BN_CTX): Integer; cdecl; 

function BN_num_bits(bnSrc: BIGNUM): Integer; cdecl; 
function BN_num_bytes(bnSrc: BIGNUM): Integer; inline;

function BN_cmp(bnSrc1, bnSrc2: BIGNUM): Integer; cdecl; 

function BN_bn2bin(bnSrc: BIGNUM; const pDest: PChar): Integer; cdecl; 
function BN_bn2hex(bnSrc: BIGNUM): PChar; cdecl; 

implementation

function SHA1_Init; external libeay32 name 'SHA1_Init';
function SHA1_Update; external libeay32 name 'SHA1_Update';
function SHA1_Final; external libeay32 name 'SHA1_Final';

procedure BN_init; external libeay32 name 'BN_init';
procedure BN_clear_free; external libeay32 name 'BN_clear_free';

function BN_set_word; external libeay32 name 'BN_set_word';
function BN_lshift1; external libeay32 name 'BN_lshift1';
function BN_bin2bn; external libeay32 name 'BN_bin2bn';
function BN_hex2bn; external libeay32 name 'BN_hex2bn';

function BN_pseudo_rand; external libeay32 name 'BN_pseudo_rand';
function BN_copy; external libeay32 name 'BN_copy';

function BN_add; external libeay32 name 'BN_add';
function BN_sub; external libeay32 name 'BN_sub';
function BN_mul; external libeay32 name 'BN_mul';

function BN_add_word; external libeay32 name 'BN_add_word';
function BN_sub_word; external libeay32 name 'BN_sub_word';
function BN_mul_word; external libeay32 name 'BN_mul_word';

function BN_CTX_new; external libeay32 name 'BN_CTX_new';
procedure BN_CTX_free; external libeay32 name 'BN_CTX_free';

function BN_div; external libeay32 name 'BN_div';

function BN_exp; external libeay32 name 'BN_exp';
function BN_mod_exp; external libeay32 name 'BN_mod_exp';

function BN_num_bits; external libeay32 name 'BN_num_bits';

function BN_num_bytes(bnSrc: BIGNUM): Integer; inline;
begin
  Result := (BN_num_bits(bnSrc) + 7) shr 3;
end;

function BN_cmp; external libeay32 name 'BN_cmp';

function BN_bn2bin; external libeay32 name 'BN_bn2bin';
function BN_bn2hex; external libeay32 name 'BN_bn2hex';

end.
