{*------------------------------------------------------------------------------
  Header Encryption Class.

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
unit Components.NetworkCore.HdrXor;

interface

uses
  Framework.Base,
  SysUtils,
  Components;

const
  ENCRYPT_LENGTH = 4;
  DECRYPT_LENGTH = 6;
  KEY_SIZE = 40;

type
  PEncryptionContext = ^YEncryptionContext;
  YEncryptionContext = record
    Key: array[0..KEY_SIZE-1] of UInt8;
    EncryptPos: UInt8;
    DecryptPos: UInt8;
    PrevEncryptValue: UInt8;
    PrevDecryptValue: UInt8;
    KeyValid: Boolean;
  end;

procedure HdrXorDecrypt(var Ctx: YEncryptionContext; BufferStart: Pointer);
procedure HdrXorEncrypt(var Ctx: YEncryptionContext; BufferStart: Pointer);

implementation

uses
  Bfg.Utils;

{$IFNDEF ASM_OPTIMIZATIONS}
{ Delphi implementation }
{$IFOPT R+}
  {$DEFINE RANGE_CHECKS_ENABLED}
  {$R-}
{$ENDIF}
procedure HdrXorDecrypt(var Ctx: YEncryptionContext; BufferStart: Pointer);
type
  PHeaderArray = ^YHeaderArray;
  YHeaderArray = array[0..DECRYPT_LENGTH - 1] of UInt8; // The max header size is 6
var
  pHdr: PHeaderArray;
  iTemp: UInt8;
begin
  if not Ctx.KeyValid then Exit;
  pHdr := BufferStart;

  if Ctx.DecryptPos = KEY_SIZE then Ctx.DecryptPos := 0;
  iTemp := (UInt8(pHdr^[0] - Ctx.PrevDecryptValue)) xor Ctx.Key[Ctx.DecryptPos];
  Inc(Ctx.DecryptPos);
  Ctx.PrevDecryptValue := pHdr^[0];
  pHdr^[0] := iTemp;

  if Ctx.DecryptPos = KEY_SIZE then Ctx.DecryptPos := 0;
  iTemp := (UInt8(pHdr^[1] - Ctx.PrevDecryptValue)) xor Ctx.Key[Ctx.DecryptPos];
  Inc(Ctx.DecryptPos);
  Ctx.PrevDecryptValue := pHdr^[1];
  pHdr^[1] := iTemp;

  if Ctx.DecryptPos = KEY_SIZE then Ctx.DecryptPos := 0;
  iTemp := (UInt8(pHdr^[2] - Ctx.PrevDecryptValue)) xor Ctx.Key[Ctx.DecryptPos];
  Inc(Ctx.DecryptPos);
  Ctx.PrevDecryptValue := pHdr^[2];
  pHdr^[2] := iTemp;

  if Ctx.DecryptPos = KEY_SIZE then Ctx.DecryptPos := 0;
  iTemp := (UInt8(pHdr^[3] - Ctx.PrevDecryptValue)) xor Ctx.Key[Ctx.DecryptPos];
  Inc(Ctx.DecryptPos);
  Ctx.PrevDecryptValue := pHdr^[3];
  pHdr^[3] := iTemp;

  if Ctx.DecryptPos = KEY_SIZE then Ctx.DecryptPos := 0;
  iTemp := (UInt8(pHdr^[4] - Ctx.PrevDecryptValue)) xor Ctx.Key[Ctx.DecryptPos];
  Inc(Ctx.DecryptPos);
  Ctx.PrevDecryptValue := pHdr^[4];
  pHdr^[4] := iTemp;

  if Ctx.DecryptPos = KEY_SIZE then Ctx.DecryptPos := 0;
  iTemp := (UInt8(pHdr^[5] - Ctx.PrevDecryptValue)) xor Ctx.Key[Ctx.DecryptPos];
  Inc(Ctx.DecryptPos);
  Ctx.PrevDecryptValue := pHdr^[5];
  pHdr^[5] := iTemp;
end;

procedure HdrXorEncrypt(var Ctx: YEncryptionContext; BufferStart: Pointer);
type
  PHeaderArray = ^YHeaderArray;
  YHeaderArray = array[0..ENCRYPT_LENGTH - 1] of UInt8; // The max header size is 4
var
  pHdr: PHeaderArray;
  iTemp: UInt8;
begin
  if not Ctx.KeyValid then Exit;
  pHdr := BufferStart;

  if Ctx.EncryptPos = KEY_SIZE then Ctx.EncryptPos := 0;
  iTemp := UInt8((pHdr^[0] xor Ctx.Key[Ctx.EncryptPos]) + Ctx.PrevEncryptValue);
  Inc(Ctx.EncryptPos);
  Ctx.PrevEncryptValue := iTemp;
  pHdr^[0] := iTemp;

  if Ctx.EncryptPos = KEY_SIZE then Ctx.EncryptPos := 0;
  iTemp := UInt8((pHdr^[1] xor Ctx.Key[Ctx.EncryptPos]) + Ctx.PrevEncryptValue);
  Inc(Ctx.EncryptPos);
  Ctx.PrevEncryptValue := iTemp;
  pHdr^[1] := iTemp;

  if Ctx.EncryptPos = KEY_SIZE then Ctx.EncryptPos := 0;
  iTemp := UInt8((pHdr^[2] xor Ctx.Key[Ctx.EncryptPos]) + Ctx.PrevEncryptValue);
  Inc(Ctx.EncryptPos);
  Ctx.PrevEncryptValue := iTemp;
  pHdr^[2] := iTemp;

  if Ctx.EncryptPos = KEY_SIZE then Ctx.EncryptPos := 0;
  iTemp := UInt8((pHdr^[3] xor Ctx.Key[Ctx.EncryptPos]) + Ctx.PrevEncryptValue);
  Inc(Ctx.EncryptPos);
  Ctx.PrevEncryptValue := iTemp;
  pHdr^[3] := iTemp;
end;
{$IFDEF RANGE_CHECKS_ENABLED}
  {$R+}
  {$UNDEF RANGE_CHECKS_ENABLED}
{$ENDIF}

{$ELSE}
{ Asm implementation }
procedure HdrXorDecrypt(var Ctx: YEncryptionContext; BufferStart: Pointer);
asm
  CMP       BYTE PTR [EAX].YEncryptionContext.KeyValid, 0
  JZ        @@Exit
  PUSH      EBX
  PUSH      ESI
  PUSH      EDI
  PUSH      EBP

  MOV       EBP, EAX
  MOV       ECX, DWORD PTR [EDX]
  MOVZX     EDI, BYTE PTR [EAX].YEncryptionContext.DecryptPos;
  MOVZX     EAX, BYTE PTR [EBP].YEncryptionContext.PrevDecryptValue;
  MOV       EBX, ECX
  XOR       ESI, ESI

  CMP       EDI, KEY_SIZE - DECRYPT_LENGTH
  JL        @@AllOk
  JG        @@SafeMethod
  JMP       @@SpecialCase

@@AllOk:
  { fKeyPos_D + DECRYPT_LENGTH <= KEY_SIZE }
  SUB       BH, CL
  SUB       BL, AL
  MOV       AL, CH
  SHR       ECX, 16
  XOR       BX, WORD PTR [EBP].YEncryptionContext.Key + EDI + 0

  MOV       AH, CH
  SUB       CH, CL
  AND       EBX, $0000FFFF
  SUB       CL, AL
  XOR       CX, WORD PTR [EBP].YEncryptionContext.Key + EDI + 2
  SHL       ECX, 16
  OR        EBX, ECX
  MOV       CX, WORD PTR [EDX+4]
  MOV       DWORD PTR [EDX], EBX

  MOV       AL, CH
  SUB       CH, CL
  SUB       CL, AH
  XOR       CX, WORD PTR [EBP].YEncryptionContext.Key + EDI + 4

  MOV       WORD PTR [EDX+4], CX

  ADD       EDI, DECRYPT_LENGTH

  MOV       EBX, EDI
  MOV       BYTE PTR [EBP].YEncryptionContext.PrevDecryptValue, AL
  MOV       BYTE PTR [EBP].YEncryptionContext.DecryptPos, BL

  POP       EBP
  POP       EDI
  POP       ESI
  POP       EBX
@@Exit:
  RET
@@SafeMethod:
  { fKeyPos_D + DECRYPT_LENGTH > KEY_SIZE }
  MOV       AH, CH
  SUB       BH, CL
  SUB       BL, AL
  XOR       BL, BYTE PTR [EBP].YEncryptionContext.Key + EDI
  INC       EDI
  SHR       ECX, 16
  CMP       EDI, KEY_SIZE
  CMOVGE    EDI, ESI
  XOR       BH, BYTE PTR [EBP].YEncryptionContext.Key + EDI
  INC       EDI
  MOV       AL, CH
  SUB       CH, CL
  AND       EBX, $0000FFFF
  SUB       CL, AH
  CMP       EDI, KEY_SIZE
  CMOVGE    EDI, ESI
  XOR       CL, BYTE PTR [EBP].YEncryptionContext.Key + EDI
  INC       EDI
  CMP       EDI, KEY_SIZE
  CMOVGE    EDI, ESI
  XOR       CH, BYTE PTR [EBP].YEncryptionContext.Key + EDI
  INC       EDI
  CMP       EDI, KEY_SIZE
  CMOVGE    EDI, ESI
  SHL       ECX, 16
  OR        EBX, ECX
  MOV       CX, WORD PTR [EDX+4]
  MOV       DWORD PTR [EDX], EBX
  MOV       AH, CH
  SUB       CH, CL
  SUB       CL, AL
  XOR       CL, BYTE PTR [EBP].YEncryptionContext.Key + EDI
  INC       EDI
  CMP       EDI, KEY_SIZE
  CMOVGE    EDI, ESI
  XOR       CH, BYTE PTR [EBP].YEncryptionContext.Key + EDI
  INC       EDI
  MOV       WORD PTR [EDX+4], CX

  MOV       EBX, EDI
  MOV       BYTE PTR [EBP].YEncryptionContext.PrevDecryptValue, AH
  MOV       BYTE PTR [EBP].YEncryptionContext.DecryptPos, BL

  POP       EBP
  POP       EDI
  POP       ESI
  POP       EBX

  RET
@@SpecialCase:
  { fKeyPos_D + DECRYPT_LENGTH = KEY_SIZE }
  SUB       BH, CL
  SUB       BL, AL
  MOV       AL, CH
  SHR       ECX, 16
  XOR       BX, WORD PTR [EBP].YEncryptionContext.Key + KEY_SIZE - DECRYPT_LENGTH + 0

  MOV       AH, CH
  SUB       CH, CL
  AND       EBX, $0000FFFF
  SUB       CL, AL
  XOR       CX, WORD PTR [EBP].YEncryptionContext.Key + KEY_SIZE - DECRYPT_LENGTH + 2
  SHL       ECX, 16
  OR        EBX, ECX
  MOV       CX, WORD PTR [EDX+4]
  MOV       DWORD PTR [EDX], EBX

  MOV       AL, CH
  SUB       CH, CL
  SUB       CL, AH
  XOR       CX, WORD PTR [EBP].YEncryptionContext.Key + KEY_SIZE - DECRYPT_LENGTH + 4

  MOV       WORD PTR [EDX+4], CX

  ADD       EDI, DECRYPT_LENGTH

  XOR       EBX, EBX
  MOV       BYTE PTR [EBP].YEncryptionContext.PrevDecryptValue, AL
  MOV       BYTE PTR [EBP].YEncryptionContext.DecryptPos, BL

  POP       EBP
  POP       EDI
  POP       ESI
  POP       EBX
end;

procedure HdrXorEncrypt(var Ctx: YEncryptionContext; BufferStart: Pointer);
asm
  CMP       BYTE PTR [EAX].YEncryptionContext.KeyValid, 0
  JZ        @@Exit
  PUSH      EBX
  PUSH      ESI
  PUSH      EDI
  PUSH      EBP

  MOV       EBP, EAX
  MOV       ECX, DWORD PTR [EDX]
  MOVZX     EDI, BYTE PTR [EAX].YEncryptionContext.EncryptPos;
  MOVZX     EAX, BYTE PTR [EBP].YEncryptionContext.PrevEncryptValue;
  XOR       ESI, ESI

  CMP       EDI, KEY_SIZE - ENCRYPT_LENGTH
  JL        @@AllOk
  JG        @@SafeMethod
  JMP       @@SpecialCase

@@AllOk:
  { KeyPos_E + ENCRYPT_LENGTH <= KEY_SIZE }
  XOR       ECX, DWORD PTR [EBP].YEncryptionContext.Key + EDI
  
  ADD       CL, AL
  MOV       EBX, ECX
  ADD       CH, CL
  SHR       EBX, 16
  ADD       BL, CH
  ADD       BH, BL
  AND       ECX, $0000FFFF
  MOV       AL, BH
  SHL       EBX, 16
  OR        ECX, EBX

  MOV       DWORD PTR [EDX], ECX

  ADD       EDI, ENCRYPT_LENGTH

  MOV       EBX, EDI
  MOV       BYTE PTR [EBP].YEncryptionContext.PrevEncryptValue, AL
  MOV       BYTE PTR [EBP].YEncryptionContext.EncryptPos, BL

  POP       EBP
  POP       EDI
  POP       ESI
  POP       EBX
@@Exit:
  RET
@@SafeMethod:
  { KeyPos_E + ENCRYPT_LENGTH > KEY_SIZE }
  XOR       CL, BYTE PTR [EBP].YEncryptionContext.Key + EDI

  INC       EDI
  ADD       CL, AL
  CMP       EDI, KEY_SIZE
  CMOVGE    EDI, ESI

  XOR       CH, BYTE PTR [EBP].YEncryptionContext.Key + EDI

  INC       EDI
  ADD       CH, CL
  MOV       AL, CH
  SHR       ECX, 16
  CMP       EDI, KEY_SIZE
  CMOVGE    EDI, ESI

  XOR       CL, BYTE PTR [EBP].YEncryptionContext.Key + EDI

  INC       EDI
  ADD       CL, AL
  CMP       EDI, KEY_SIZE
  CMOVGE    EDI, ESI

  XOR       CH, BYTE PTR [EBP].YEncryptionContext.Key + EDI
  INC       EDI
  ADD       CH, CL
  MOV       AL, CH

  MOV       DWORD PTR [EDX], ECX

  MOV       EBX, EDI
  MOV       BYTE PTR [EBP].YEncryptionContext.PrevEncryptValue, AL
  MOV       BYTE PTR [EBP].YEncryptionContext.EncryptPos, BL

  POP       EBP
  POP       EDI
  POP       ESI
  POP       EBX

  RET
@@SpecialCase:
  { KeyPos_E + ENCRYPT_LENGTH = KEY_SIZE }
  XOR       ECX, DWORD PTR [EBP].YEncryptionContext.Key + KEY_SIZE - ENCRYPT_LENGTH
  
  ADD       CL, AL
  MOV       EBX, ECX
  ADD       CH, CL
  SHR       EBX, 16
  ADD       BL, CH
  ADD       BH, BL
  AND       ECX, $0000FFFF
  MOV       AL, BH
  SHL       EBX, 16
  OR        ECX, EBX

  MOV       DWORD PTR [EDX], ECX

  XOR       EBX, EBX
  MOV       BYTE PTR [EBP].YEncryptionContext.PrevEncryptValue, AL
  MOV       BYTE PTR [EBP].YEncryptionContext.EncryptPos, BL

  POP       EBP
  POP       EDI
  POP       ESI
  POP       EBX
end;
{$ENDIF}

end.
