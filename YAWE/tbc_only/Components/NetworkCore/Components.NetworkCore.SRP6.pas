{*------------------------------------------------------------------------------
  Secure Remote Protocol related routines.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.NetworkCore.SRP6;

interface

uses
  Components.DataCore.Types,
  LibEay32.LibInterface,
  SysUtils,
  Bfg.Utils;

type
  PSRPInstance = ^YSRPInstance;
  YSRPInstance = record
    S: TBigNumber;
    G: TBigNumber;
    N: TBigNumber;
    RN: TBigNumber;
    B_Priv: TBigNumber;
    Unk: TBigNumber;
    V: TBigNumber;
    B_Pub: TBigNumber;
    K: TBigNumber;
    Key: string;
    Account: string;
  end;

  PSRPProofData = ^YSRPProofData;
  YSRPProofData = record
    B: array[0..31] of Byte;
    G: Byte;
    N: array[0..31] of Byte;
    S: array[0..31] of Byte;
    Unk: array[0..15] of Byte;
    M2: array[0..19] of Byte;
    SS_Hash: YAccountHash;
  end;

procedure InitializeSRP6(pInst: PSRPInstance; const sAccount, sKey: string);
procedure GetProofSRP6Data(pInst: PSRPInstance; pOutd: PSRPProofData);
function ValidateSRP6(pInst: PSRPInstance; pA: Pointer; pCM1: Pointer; pProof: PSRPProofData): Boolean;
function CheckAuthDigest(iClSeed, iSrvSeed: Integer; pHash, pDigest: Pointer; const sAccount: string): Boolean;

implementation

{$REGION 'Funcs to work with Big Numbers and SHA Hash'}
procedure BigNumInit(pBN: PBigNumber); inline;
begin
  BN_init(pBN);
end;

procedure BigNumInitDword(pBN: PBigNumber; dwValue: Longword); inline;
begin
  BN_init(pBN);
  BN_set_word(pBN, dwValue);
end;

procedure BigNumInitCopy(pBN: PBigNumber; pBNCopySrc: PBigNumber); inline;
begin
  BN_init(pBN);
  BN_copy(pBN, pBNCopySrc);
end;

procedure BigNumInitBinary(pBN: PBigNumber; pData: Pointer; iLen: Integer); inline;
begin
  BN_init(pBN);
  BN_bin2bn(PChar(pData), iLen, pBN);
end;

procedure BigNumClear(pBN: PBigNumber); inline;
begin
  BN_clear_free(pBN);
end;

procedure BigNumSetDword(pBN: PBigNumber; dwValue: Longword); inline;
begin
  BN_set_word(pBN, dwValue);
end;

procedure BigNumReverse(pBN: PBigNumber); inline;
var
  pTemp: PChar;
  iLen: Integer;
begin
  iLen := BN_num_bytes(pBN);
  GetMem(pTemp, iLen);
  BN_bn2bin(pBN, pTemp);
  ReverseBytes(pTemp, iLen);
  BN_bin2bn(pTemp, iLen, pBN);
  FreeMem(pTemp);
end;

procedure BigNumReverseEx(pBNDest: PBigNumber; pBNSrc: PBigNumber); inline;
var
  pTemp: PChar;
  iLen: Integer;
begin
  iLen := BN_num_bytes(pBNSrc);
  GetMem(pTemp, iLen);
  BN_bn2bin(pBNSrc, pTemp);
  ReverseBytes(pTemp, iLen);
  BN_bin2bn(pTemp, iLen, pBNDest);
  FreeMem(pTemp);
end;

procedure BigNumSetQword(pBN: PBigNumber; const liValue: Int64); inline;
begin
  BN_set_word(pBN, Int64Rec(liValue).Cardinals[1]);
  BN_lshift1(pBN, BITS_PER_LONG);
  BN_set_word(pBN, Int64Rec(liValue).Cardinals[0]);
end;

procedure BigNumSetBinary(pBN: PBigNumber; pData: Pointer; iLen: Integer); inline;
begin
  BN_bin2bn(PChar(pData), iLen, pBN);
end;

procedure BigNumSetHex(pBN: PBigNumber; pHex: PChar); inline;
begin
  BN_hex2bn(@pBN, pHex);
end;

procedure BigNumFillRand(pBN: PBigNumber; iCount: Integer); inline;
begin
  BN_pseudo_rand(pBN, iCount * BITS_PER_BYTE, 0, 1);
end;

procedure BigNumCopy(pBNDest: PBigNumber; pBNSrc: PBigNumber); inline;
begin
  BN_copy(pBNDest, pBNSrc);
end;

procedure BigNumAdd(pBNSrc: PBigNumber; pBNAddend: PBigNumber); inline;
begin
  BN_add(pBNSrc, pBNSrc, pBNAddend);
end;

procedure BigNumAddDword(pBN: PBigNumber; dwAddend: Longword); inline;
begin
  BN_add_word(pBN, dwAddend);
end;

procedure BigNumSub(pBNSrc: PBigNumber; pBNSubtrahend: PBigNumber); inline;
begin
  BN_sub(pBNSrc, pBNSrc, pBNSubtrahend);
end;

procedure BigNumSubDword(pBN: PBigNumber; dwSubtrahend: Longword); inline;
begin
  BN_sub_word(pBN, dwSubtrahend);
end;

procedure BigNumMul(pBNSrc: PBigNumber; pBNMultiplier: PBigNumber); inline;
var
  pCtx: BN_CTX;
begin
  pCtx := BN_CTX_new;
  BN_mul(pBNSrc, pBNSrc, pBNMultiplier, pCtx);
  BN_CTX_free(pCtx);
end;

procedure BigNumMulDword(pBN: PBigNumber; dwMultiplier: Longword); inline;
begin
  BN_mul_word(pBN, dwMultiplier);
end;

procedure BigNumDiv(pBNSrc: PBigNumber; pBNDivisor: PBigNumber); inline;
var
  pCtx: BN_CTX;
begin
  pCtx := BN_CTX_new;
  BN_div(pBNSrc, nil, pBNSrc, pBNDivisor, pCtx);
  BN_CTX_free(pCtx);
end;

procedure BigNumMod(pBNSrc: PBigNumber; pBNDivisor: PBigNumber); inline;
var
  pCtx: BN_CTX;
begin
  pCtx := BN_CTX_new;
  BN_div(nil, pBNSrc, pBNSrc, pBNDivisor, pCtx);
  BN_CTX_free(pCtx);
end;

procedure BigNumDivMod(pBNSrc: PBigNumber; pBNDivisor: PBigNumber; pBNRemainder: PBigNumber); inline;
var
  pCtx: BN_CTX;
begin
  pCtx := BN_CTX_new;
  BN_div(pBNSrc, pBNRemainder, pBNSrc, pBNDivisor, pCtx);
  BN_CTX_free(pCtx);
end;

procedure BigNumModExp(pBNSrc: PBigNumber; pBNExponent: PBigNumber; pBNDivisor: PBigNumber); inline;
var
  pCtx: BN_CTX;
begin
  pCtx := BN_CTX_new;
  BN_mod_exp(pBNSrc, pBNSrc, pBNExponent, pBNDivisor, pCtx);
  BN_CTX_free(pCtx);
end;

procedure BigNumExp(pBNSrc: PBigNumber; pBNExponent: PBigNumber); inline;
var
  pCtx: BN_CTX;
begin
  pCtx := BN_CTX_new;
  BN_exp(pBNSrc, pBNSrc, pBNExponent, pCtx);
  BN_CTX_free(pCtx);
end;

function BigNumCompare(pBN1, pBN2: PBigNumber): Integer; inline;
begin
  Result := BN_cmp(pBN1, pBN2);
end; 

function BigNumGetSize(pBN: PBigNumber): Integer; inline;
begin
  Result := BN_num_bytes(pBN);
end;

procedure BigNumCopyToArray(pBN: PBigNumber; pArr: Pointer); inline;
begin
  BN_bn2bin(pBN, PChar(pArr));
end;

function BigNumToHex(pBN: PBigNumber): string; inline;
begin
  Result := BN_bn2hex(pBN);
end;

procedure SHAInitialize(pSD: PSHAData); inline;
begin
  SHA1_Init(@pSD^.Ctx);
end;

procedure SHAUpdate(pSD: PSHAData; pSrc: Pointer; iLen: Integer); inline;
begin
  SHA1_Update(@pSD^.Ctx, pSrc, iLen);
end;

procedure SHAUpdateString(pSD: PSHAData; const sStr: string); inline;
begin
  SHA1_Update(@pSD^.Ctx, Pointer(sStr), Length(sStr));
end;

procedure SHAUpdateBigNumber(pSD: PSHAData; pBN: PBigNumber; var pTempBuf: Pointer); inline;
var
  iLen: Integer;
begin
  iLen := BigNumGetSize(pBN);
  ReallocMem(pTempBuf, iLen);
  BigNumCopyToArray(pBN, pTempBuf);
  SHA1_Update(@pSD^.Ctx, pTempBuf, iLen);
end;

procedure SHAFinalize(pSD: PSHAData); inline;
begin
  SHA1_Final(@pSD^.Digest, @pSD^.Ctx);
end;
{$ENDREGION}

procedure InitializeSRP6(pInst: PSRPInstance; const sAccount, sKey: string);
const
  N_VALUE: array[0..31] of Byte = (
    $89, $4B, $64, $5E, $89, $E1, $53, $5B, $BD, $AD, $5B, $8B, $29, $06, $50, $53,
    $08, $01, $B1, $8E, $BF, $BF, $5E, $8F, $AB, $3C, $82, $87, $2A, $3E, $9B, $B7
  );
  RN_VALUE: array[0..31] of Byte = (
    $B7, $9B, $3E, $2A, $87, $82, $3C, $AB, $8F, $5E, $BF, $BF, $8E, $B1, $01, $08,
    $53, $50, $06, $29, $8B, $5B, $AD, $BD, $5B, $53, $E1, $89, $5E, $64, $4B, $89
  );
  G_VALUE = 7;
  K_VALUE = 3;
var
  tSha: TSHAData;
  X: TBigNumber;
  sTemp: string;
  pTemp: Pointer;
begin
  with pInst^ do
  begin
    pTemp := nil;

    BigNumFillRand(@S, 32);
    BigNumSetBinary(@N, @N_VALUE, SizeOf(N_VALUE));
    BigNumSetBinary(@RN, @RN_VALUE, SizeOf(RN_VALUE));
    BigNumSetDword(@G, G_VALUE);

    sTemp := sAccount + ':' + sKey;

    SHAInitialize(@tSha);
    SHAUpdateString(@tSha, sTemp);
    SHAFinalize(@tSha);

    Account := sAccount;
    Key := sKey;

    SHAInitialize(@tSha);
    SHAUpdateBigNumber(@tSha, @S, pTemp);
    SHAUpdate(@tSha, @tSha.Digest, SHA_DIGEST_LENGTH);
    SHAFinalize(@tSha);
    { OK }

    BigNumInitBinary(@X, @tSha.Digest, SHA_DIGEST_LENGTH);
    BigNumReverse(@X);
    BigNumSetDword(@V, G_VALUE);
    BigNumModExp(@V, @X, @RN);
    { OK }

    BigNumFillRand(@B_Priv, 20);
    BigNumReverse(@B_Priv);

    BigNumSetDword(@X, G_VALUE);
    BigNumModExp(@X, @B_Priv, @RN);

    BigNumCopy(@B_Pub, @V);
    BigNumMulDword(@B_Pub, K_VALUE);
    BigNumAdd(@B_Pub, @X);
    BigNumMod(@B_Pub, @RN);
    BigNumReverse(@B_Pub);
    { OK }

    BigNumFillRand(@Unk, 16);

    FreeMem(pTemp);
  end;
end;

procedure GetProofSRP6Data(pInst: PSRPInstance; pOutd: PSRPProofData);
begin
  BigNumCopyToArray(@pInst^.B_Pub, @pOutd^.B);
  BigNumCopyToArray(@pInst^.G, @pOutd^.G);
  BigNumCopyToArray(@pInst^.N, @pOutd^.N);
  BigNumCopyToArray(@pInst^.S, @pOutd^.S);
  BigNumCopyToArray(@pInst^.Unk, @pOutd^.Unk);
end;

function ValidateSRP6(pInst: PSRPInstance; pA: Pointer; pCM1: Pointer; pProof: PSRPProofData): Boolean;
var
  A: TBigNumber;
  RA: TBigNumber;
  U: TBigNumber;
  ST: TBigNumber;
  X: TBigNumber;
  Y: TBigNumber;
  SM1: TBigNumber;
  CM1: TBigNumber;
  iInt: Integer;
  tSha: TSHAData;
  T: array[0..31] of Byte;
  T1: array[0..15] of Byte;
  SS: array[0..39] of Byte;
  Hash: array[0..19] of Byte;
  pTemp: Pointer;
begin
  with pInst^ do
  begin
    pTemp := nil;
    
    BigNumInitBinary(@A, pA, 32);
    BigNumInitBinary(@CM1, pCM1, 20);

    SHAInitialize(@tSha);
    SHAUpdate(@tSha, pA, 32);
    SHAUpdateBigNumber(@tSha, @B_Pub, pTemp);
    SHAFinalize(@tSha);

    BigNumInitBinary(@U, @tSha.Digest, SHA_DIGEST_LENGTH);
    { OK }

    BigNumInit(@RA);
    BigNumReverse(@U);
    BigNumReverseEx(@RA, @A);

    BigNumInitCopy(@ST, @V);
    BigNumModExp(@ST, @U, @RN);
    BigNumMul(@ST, @RA);
    BigNumModExp(@ST, @B_Priv, @RN);
    { OK }

    BigNumReverse(@ST);
    BigNumCopyToArray(@ST, @T);

    for iInt := 0 to 15 do
    begin
      T1[iInt] := T[iInt*2];
    end;

    SHAInitialize(@tSha);
    SHAUpdate(@tSha, @T1, SizeOf(T1));
    SHAFinalize(@tSha);
    { OK }

    for iInt := 0 to 19 do
    begin
      SS[iInt*2] := tSha.Digest[iInt];
    end;

    for iInt := 0 to 15 do
    begin
      T1[iInt] := T[iInt*2+1];
    end;

    SHAInitialize(@tSha);
    SHAUpdate(@tSha, @T1, SizeOf(T1));
    SHAFinalize(@tSha);
    { OK }

    for iInt := 0 to 19 do
    begin
      SS[iInt*2+1] := tSha.Digest[iInt];
    end;

    BigNumSetBinary(@K, @SS, SizeOf(SS));
    { OK }

    SHAInitialize(@tSha);
    SHAUpdateBigNumber(@tSha, @N, pTemp);
    SHAFinalize(@tSha);

    Move(tSha.Digest, Hash, SizeOf(Hash));

    SHAInitialize(@tSha);
    SHAUpdateBigNumber(@tSha, @G, pTemp);
    SHAFinalize(@tSha);

    for iInt := 0 to 19 do
    begin
      Hash[iInt] := Hash[iInt] xor tSha.Digest[iInt];
    end;

    BigNumInitBinary(@X, @Hash, 20);
    { OK }

    SHAInitialize(@tSha);
    SHAUpdateString(@tSha, Account);
    SHAFinalize(@tSha);

    BigNumInitBinary(@Y, @tSha.Digest, SHA_DIGEST_LENGTH);

    SHAInitialize(@tSha);
    SHAUpdateBigNumber(@tSha, @X, pTemp);
    SHAUpdateBigNumber(@tSha, @Y, pTemp);
    SHAUpdateBigNumber(@tSha, @S, pTemp);
    SHAUpdateBigNumber(@tSha, @A, pTemp);
    SHAUpdateBigNumber(@tSha, @B_Pub, pTemp);
    SHAUpdateBigNumber(@tSha, @K, pTemp);
    SHAFinalize(@tSha);

    BigNumInitBinary(@SM1, @tSha.Digest, SHA_DIGEST_LENGTH);
    { OK }

    if BigNumCompare(@SM1, @CM1) = 0 then
    begin
      { Client's M1 and our calculated M1 match }
      SHAInitialize(@tSha);
      SHAUpdateBigNumber(@tSha, @A, pTemp);
      SHAUpdateBigNumber(@tSha, @SM1, pTemp);
      SHAUpdateBigNumber(@tSha, @K, pTemp);
      SHAFinalize(@tSha);
      { OK }

      Move(tSha.Digest, pProof^.M2, SHA_DIGEST_LENGTH);
      Move(SS, pProof^.SS_Hash, SizeOf(SS));

      Result := True;
    end else
    begin
      { Oops, something went wrong }
      Result := False;
    end;
    
    FreeMem(pTemp);
  end;
end;

function CheckAuthDigest(iClSeed, iSrvSeed: Integer; pHash, pDigest: Pointer; const sAccount: string): Boolean;
const
  ZERO: Longword = 0;
var
  tSha: TSHAData;
  X: TBigNumber;
  pTemp: Pointer;
begin
  pTemp := nil;
  BigNumInitBinary(@X, pHash, 40);

  SHAInitialize(@tSha);
  SHAUpdate(@tSha, Pointer(sAccount), Length(sAccount));
  SHAUpdate(@tSha, @ZERO, SizeOf(ZERO));
  SHAUpdate(@tSha, @iClSeed, SizeOf(iClSeed));
  SHAUpdate(@tSha, @iSrvSeed, SizeOf(iSrvSeed));
  SHAUpdateBigNumber(@tSha, @X, pTemp);
  SHAFinalize(@tSha);
  FreeMem(pTemp);

  Result := CompareMem(@tSha.Digest, pDigest, SHA_DIGEST_LENGTH);
end;

end.
