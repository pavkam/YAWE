{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Hashing Algorithms
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Bfg.Crypto;

interface

uses
  Classes,
  Bfg.Utils,
  SysUtils{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

type
  THashingAlgorithm = class(TObject)
    private
      function GetDigestByte(Index: Integer): Byte;
      function GetDigestAsHex: string;
    protected
      fDigest: TByteDynArray;
      
      function GetDigestSize: Integer;
    public
      procedure Initialize; virtual; abstract;
      procedure Update(const Data; Size: Integer); overload; virtual; abstract;
      procedure Update(const Str: string); overload;
      procedure Update(const Bytes: array of Byte); overload;
      procedure Finalize; virtual; abstract;

      procedure CopyDigest(var Dest); virtual; abstract;

      procedure FileHash(const FileName: string);

      property Digest[Index: Integer]: Byte read GetDigestByte;
      property DigestAsHex: string read GetDigestAsHex;
      property DigestSize: Integer read GetDigestSize;
  end;

  PMD5Context = ^TMD5Context;
  TMD5Context = packed record
    Count: array[0..1] of Longword;  
    State: array[0..3] of Longword;
    Buf: array[0..63] of Byte;
  end;

  TMD5Hash = class(THashingAlgorithm)
    protected
      fContext: TMD5Context;
    public
      constructor Create;

      procedure Initialize; override;
      procedure Update(const Data; Size: Integer); override;
      procedure Finalize; override;

      procedure CopyDigest(var Dest); override;
    end;

  PSHA1Context = ^TSHA1Context;
  TSHA1Context = packed record
    Hash: array[0..4] of Longword;
    Hi: Integer;
    Lo: Integer;
    Buffer: array[0..63] of Byte;
    Index: Integer;
  end;

  TSHA1Hash = class(THashingAlgorithm)
    protected
      fContext: TSHA1Context;
    public
      constructor Create;
      
      procedure Initialize; override;
      procedure Update(const Data; Size: Integer); override;
      procedure Finalize; override;

      procedure CopyDigest(var Dest); override;
  end;

implementation

uses
  Bfg.Resources;

{ THashingAlgorithm }

procedure THashingAlgorithm.Update(const Str: string);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,634 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Update(Pointer(Str)^, Length(Str));
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,634; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashingAlgorithm.FileHash(const FileName: string);
var
  BufSize: Integer;
  Buf: array[0..4095] of Byte;
  FS: TStream;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,635 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FS := TFileStream.Create(FileName, fmOpenRead);
  try
    repeat
      BufSize := FS.Read(Buf, SizeOf(Buf));
      Update(Buf, BufSize);
    until BufSize = 0;
  finally
    FS.Free;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,635; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashingAlgorithm.GetDigestAsHex: string;
var
  I: Integer;
  S: string;
  P: PWord;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,636 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SetLength(Result, DigestSize * 2);
  P := @Result[1];
  for I := 0 to DigestSize do
  begin
    S := IntToHex(fDigest[I], 2);
    P^ := PWord(S)^;
    Inc(P);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,636; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashingAlgorithm.GetDigestByte(Index: Integer): Byte;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,637 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index >= Length(fDigest)) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  Result := fDigest[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,637; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashingAlgorithm.GetDigestSize: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,638 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := Length(fDigest);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,638; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashingAlgorithm.Update(const Bytes: array of Byte);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,639 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Update(Bytes[0], Length(Bytes));
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,639; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TMD5Hash }

function LRot(I: Longword; C: Byte): Longword; register;
asm
  MOV  ECX, EDX
  ROL  EAX, CL
end;

function RRot(I: Longword; C: Byte): Longword; register;
asm
  MOV  ECX, EDX         
  ROR  EAX, CL
end;

procedure Transform(Buffer: Pointer; InputBuffer: Pointer);
const
  S11 = 7;
  S12 = 12;
  S13 = 17;
  S14 = 22;
  S21 = 5;
  S22 = 9;
  S23 = 14;
  S24 = 20;
  S31 = 4;
  S32 = 11;
  S33 = 16;
  S34 = 23;
  S41 = 6;
  S42 = 10;
  S43 = 15;
  S44 = 21;
type
  PBytes16 = ^TBytes16;
  TBytes16 = array[0..3] of Longword;

  PBytes64 = ^TBytes64;
  TBytes64 = array[0..15] of Longword;
var
  Buf: PBytes16;
  BufIn: PBytes64;
  A: Longword;
  B: Longword;
  C: Longword;
  D: Longword;

  procedure FF(var A: Longword; B, C, D, X, S, AC: Longword); inline;
  begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,640 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
    A := LRot(A + ((B and C) or (not B and D)) + X + AC, S) + B;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,640; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
  end;

  procedure GG(var A: Longword; B, C, D, X, S, AC: Longword); inline;
  begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,641 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
    A := LRot(A + ((B and D) or (C and not D)) + X + AC, S) + B;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,641; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
  end;

  procedure HH(var A: Longword; B, C, D, X, S, AC: Longword); inline;
  begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,642 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
    A := LRot(A + (B xor C xor D) + X + AC, S) + B;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,642; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
  end;

  procedure II(var A: Longword; B, C, D, X, S, AC: Longword); inline;
  begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,643 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
    A := LRot(A + (C xor (B or not D)) + X + AC, S) + B;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,643; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
  end;

begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,644 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Buf := PBytes16(Buffer);
  BufIn := PBytes64(InputBuffer);
  A := Buf^[0];
  B := Buf^[1];
  C := Buf^[2];
  D := Buf^[3];

  { round 1 }
  FF(A, B, C, D, BufIn^[ 0], S11, $D76AA478);  { 1 }
  FF(D, A, B, C, BufIn^[ 1], S12, $E8C7B756);  { 2 }
  FF(C, D, A, B, BufIn^[ 2], S13, $242070DB);  { 3 }
  FF(B, C, D, A, BufIn^[ 3], S14, $C1BDCEEE);  { 4 }
  FF(A, B, C, D, BufIn^[ 4], S11, $F57C0FAF);  { 5 }
  FF(D, A, B, C, BufIn^[ 5], S12, $4787C62A);  { 6 }
  FF(C, D, A, B, BufIn^[ 6], S13, $A8304613);  { 7 }
  FF(B, C, D, A, BufIn^[ 7], S14, $FD469501);  { 8 }
  FF(A, B, C, D, BufIn^[ 8], S11, $698098D8);  { 9 }
  FF(D, A, B, C, BufIn^[ 9], S12, $8B44F7AF);  { 10 }
  FF(C, D, A, B, BufIn^[10], S13, $FFFF5BB1);  { 11 }
  FF(B, C, D, A, BufIn^[11], S14, $895CD7BE);  { 12 }
  FF(A, B, C, D, BufIn^[12], S11, $6B901122);  { 13 }
  FF(D, A, B, C, BufIn^[13], S12, $FD987193);  { 14 }
  FF(C, D, A, B, BufIn^[14], S13, $A679438E);  { 15 }
  FF(B, C, D, A, BufIn^[15], S14, $49B40821);  { 16 }

  { round 2 }
  GG(A, B, C, D, BufIn^[ 1], S21, $F61E2562);  { 17 }
  GG(D, A, B, C, BufIn^[ 6], S22, $C040B340);  { 18 }
  GG(C, D, A, B, BufIn^[11], S23, $265E5A51);  { 19 }
  GG(B, C, D, A, BufIn^[ 0], S24, $E9B6C7AA);  { 20 }
  GG(A, B, C, D, BufIn^[ 5], S21, $D62F105D);  { 21 }
  GG(D, A, B, C, BufIn^[10], S22, $02441453);  { 22 }
  GG(C, D, A, B, BufIn^[15], S23, $D8A1E681);  { 23 }
  GG(B, C, D, A, BufIn^[ 4], S24, $E7D3FBC8);  { 24 }
  GG(A, B, C, D, BufIn^[ 9], S21, $21E1CDE6);  { 25 }
  GG(D, A, B, C, BufIn^[14], S22, $C33707D6);  { 26 }
  GG(C, D, A, B, BufIn^[ 3], S23, $F4D50D87);  { 27 }
  GG(B, C, D, A, BufIn^[ 8], S24, $455A14ED);  { 28 }
  GG(A, B, C, D, BufIn^[13], S21, $A9E3E905);  { 29 }
  GG(D, A, B, C, BufIn^[ 2], S22, $FCEFA3F8);  { 30 }
  GG(C, D, A, B, BufIn^[ 7], S23, $676F02D9);  { 31 }
  GG(B, C, D, A, BufIn^[12], S24, $8D2A4C8A);  { 32 }

  { round 3 }
  HH(A, B, C, D, BufIn^[ 5], S31, $FFFA3942);  { 33 }
  HH(D, A, B, C, BufIn^[ 8], S32, $8771F681);  { 34 }
  HH(C, D, A, B, BufIn^[11], S33, $6D9D6122);  { 35 }
  HH(B, C, D, A, BufIn^[14], S34, $FDE5380C);  { 36 }
  HH(A, B, C, D, BufIn^[ 1], S31, $A4BEEA44);  { 37 }
  HH(D, A, B, C, BufIn^[ 4], S32, $4BDECFA9);  { 38 }
  HH(C, D, A, B, BufIn^[ 7], S33, $F6BB4B60);  { 39 }
  HH(B, C, D, A, BufIn^[10], S34, $BEBFBC70);  { 40 }
  HH(A, B, C, D, BufIn^[13], S31, $289B7EC6);  { 41 }
  HH(D, A, B, C, BufIn^[ 0], S32, $EAA127FA);  { 42 }
  HH(C, D, A, B, BufIn^[ 3], S33, $D4EF3085);  { 43 }
  HH(B, C, D, A, BufIn^[ 6], S34, $04881D05);  { 44 }
  HH(A, B, C, D, BufIn^[ 9], S31, $D9D4D039);  { 45 }
  HH(D, A, B, C, BufIn^[12], S32, $E6DB99E5);  { 46 }
  HH(C, D, A, B, BufIn^[15], S33, $1FA27CF8);  { 47 }
  HH(B, C, D, A, BufIn^[ 2], S34, $C4AC5665);  { 48 }

  { round 4 }
  II(A, B, C, D, BufIn^[ 0], S41, $F4292244);  { 49 }
  II(D, A, B, C, BufIn^[ 7], S42, $432AFF97);  { 50 }
  II(C, D, A, B, BufIn^[14], S43, $AB9423A7);  { 51 }
  II(B, C, D, A, BufIn^[ 5], S44, $FC93A039);  { 52 }
  II(A, B, C, D, BufIn^[12], S41, $655B59C3);  { 53 }
  II(D, A, B, C, BufIn^[ 3], S42, $8F0CCC92);  { 54 }
  II(C, D, A, B, BufIn^[10], S43, $FFEFF47D);  { 55 }
  II(B, C, D, A, BufIn^[ 1], S44, $85845DD1);  { 56 }
  II(A, B, C, D, BufIn^[ 8], S41, $6FA87E4F);  { 57 }
  II(D, A, B, C, BufIn^[15], S42, $FE2CE6E0);  { 58 }
  II(C, D, A, B, BufIn^[ 6], S43, $A3014314);  { 59 }
  II(B, C, D, A, BufIn^[13], S44, $4E0811A1);  { 60 }
  II(A, B, C, D, BufIn^[ 4], S41, $F7537E82);  { 61 }
  II(D, A, B, C, BufIn^[11], S42, $BD3AF235);  { 62 }
  II(C, D, A, B, BufIn^[ 2], S43, $2AD7D2BB);  { 63 }
  II(B, C, D, A, BufIn^[ 9], S44, $EB86D391);  { 64 }

  Inc(Buf^[0], A);
  Inc(Buf^[1], B);
  Inc(Buf^[2], C);
  Inc(Buf^[3], D);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,644; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure InitMD5(var Context: TMD5Context);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,645 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Context.Count[0] := 0;
  Context.Count[1] := 0;

  { load magic initialization constants }
  Context.State[0] := $67452301;
  Context.State[1] := $EFCDAB89;
  Context.State[2] := $98BADCFE;
  Context.State[3] := $10325476;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,645; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure UpdateMD5(var Context: TMD5Context; const Buf; Size: Integer);
var
  InBuf: array[0..15] of Longword;
  BufOfs: Integer;
  MDI: Integer;
  I: Integer;
  II: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,646 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Size <= 0 then Exit;
  { compute number of bytes mod 64 }
  MDI := (Context.Count[0] shr 3) and $3F;

  { update number of bits }
  if (Context.Count[0] + (Longword(Size) shl 3)) < Context.Count[0] then Inc(Context.Count[1]);
  
  Inc(Context.Count[0], Size shl 3);
  Inc(Context.Count[1], Size shr 29);

  { add new byte acters to buffer }
  BufOfs := 0;
  while Size > 0 do
  begin
    Dec(Size);
    Context.Buf[MDI] := TByteArray(Buf)[BufOfs];
    Inc(MDI);
    Inc(BufOfs);
    if MDI = $40 then
    begin
      II := 0;
      for I := 0 to 15 do
      begin
        InBuf[I] := Integer(Context.Buf[II + 3]) shl 24 or
          Integer(Context.Buf[II + 2]) shl 16 or
          Integer(Context.Buf[II + 1]) shl 8 or
          Integer(Context.Buf[II]);
        Inc(II, 4);
      end;
      Transform(@Context.State, @InBuf);
      MDI := 0;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,646; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure FinalizeMD5(var Context: TMD5Context; var Digest: TByteDynArray);
const
  Padding: array[0..63] of Byte = (
    $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
    $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00);
var
  InBuf: array [0..15] of Longword;
  MDI: Integer;
  I: Integer;
  II: Integer;
  PadLen: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,647 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  { save number of bits }
  InBuf[14] := Context.Count[0];
  InBuf[15] := Context.Count[1];
  { compute number of bytes mod 64 }
  MDI := (Context.Count[0] shr 3) and $3F;
  { pad out to 56 mod 64 }
  if (MDI < 56) then
    PadLen := 56 - MDI
  else
    PadLen := 120 - MDI;

  UpdateMD5(Context, Padding, PadLen);

  { append length in bits and transform }
  II := 0;
  for I := 0 to 13 do
  begin
    InBuf[I] :=
      (Integer(Context.Buf[II + 3]) shl 24) or
      (Integer(Context.Buf[II + 2]) shl 16) or
      (Integer(Context.Buf[II + 1]) shl 8) or
       Integer(Context.Buf[II]);
    Inc(II, 4);
  end;
  Transform(@Context.State, @InBuf);
  { store buffer in digest }
  II := 0;
  for I := 0 to 3 do
  begin
    Digest[II] := Byte(Context.State[I] and $FF);
    Digest[II + 1] := Byte((Context.State[I] shr 8) and $FF);
    Digest[II + 2] := Byte((Context.State[I] shr 16) and $FF);
    Digest[II + 3] := Byte((Context.State[I] shr 24) and $FF);
    Inc(II, 4);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,647; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TMD5Hash.Create;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,648 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  SetLength(fDigest, 16);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,648; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TMD5Hash.Initialize;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,649 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FillChar(fContext, SizeOf(fContext), 0);
  FillChar(fDigest[0], 16, 0);
  InitMD5(fContext);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,649; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TMD5Hash.Update(const Data; Size: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,650 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  UpdateMD5(fContext, Data, Size);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,650; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TMD5Hash.CopyDigest(var Dest);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,651 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Move(fDigest[0], Dest, 16);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,651; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TMD5Hash.Finalize;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,652 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FinalizeMD5(fContext, fDigest);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,652; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function F1(X, Y, Z: Longword): Longword; inline;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,653 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result:= Z xor (X and (Y xor Z));
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,653; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function F2(X, Y, Z: Longword): Longword; inline;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,654 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result:= X xor Y xor Z;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,654; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function F3(X, Y, Z: Longword): Longword; inline;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,655 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result:= (X and Y) or (Z and (X or Y));
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,655; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function RB(A: Longword): Longword; inline;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,656 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result:= (A shr 24) or ((A shr 8) and $FF00) or ((A shl 8) and $FF0000) or (A shl 24);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,656; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure SHA1Compress(var Data: TSHA1Context);
var
  A, B, C, D, E, T: Longword;
  W: array[0..79] of Longword;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,657 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Move(Data.Buffer, W, SizeOf(Data.Buffer));
  for I := 0 to 15 do
  begin
    W[I] := RB(W[I]);
  end;

  for I:= 16 to 79 do
  begin
    W[I] := LRot(W[I-3] xor W[I-8] xor W[I-14] xor W[I-16], 1);
  end;

  A := Data.Hash[0];
  B := Data.Hash[1];
  C := Data.Hash[2];
  D := Data.Hash[3];
  E := Data.Hash[4];

  for I := 0 to 19 do
  begin
    T := LRot(A, 5) + F1(B, C, D) + E + W[I] + $5A827999;
    E := D;
    D := C;
    C := LRot(B, 30);
    B := A;
    A := T;
  end;

  for I := 20 to 39 do
  begin
    T := LRot(A, 5) + F2(B, C, D) + E + W[I] + $6ED9EBA1;
    E := D;
    D := C;
    C := LRot(B, 30); B := A;
    A := T;
  end;

  for I := 40 to 59 do
  begin
    T := LRot(A,5) + F3(B, C, D) + E + W[I] + $8F1BBCDC;
    E := D;
    D := C;
    C := LRot(B, 30);
    B := A;
    A := T;
  end;

  for I := 60 to 79 do
  begin
    T := LRot(A, 5) + F2(B, C, D) + E + W[I] + $CA62C1D6;
    E := D;
    D := C;
    C := LRot(B,30);
    B := A;
    A := T;
  end;

  Data.Hash[0] := Data.Hash[0] + A;
  Data.Hash[1] := Data.Hash[1] + B;
  Data.Hash[2] := Data.Hash[2] + C;
  Data.Hash[3] := Data.Hash[3] + D;
  Data.Hash[4] := Data.Hash[4] + E;
  FillChar(W, SizeOf(W),0);
  FillChar(Data.Buffer, SizeOf(Data.Buffer),0);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,657; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure SHA1Init(var Context: TSHA1Context);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,658 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Context.Hi := 0;
  Context.Lo := 0;
  Context.Index := 0;
  Context.Hash[0] := $67452301;
  Context.Hash[1] := $EFCDAB89;
  Context.Hash[2] := $98BADCFE;
  Context.Hash[3] := $10325476;
  Context.Hash[4] := $C3D2E1F0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,658; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure SHA1UpdateLen(var Context: TSHA1Context; Len: integer);
var
  I, K: integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,659 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for K := 0 to 7 do
  begin
    I := Context.Lo;
    Inc(Context.Lo, Len);
    if Context.Lo < I then
      Inc(Context.Hi);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,659; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure SHA1Update(var Context: TSHA1Context; const Data; Len: Integer);
var
  P: PByte;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,660 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SHA1UpdateLen(Context, Len);
  P := @Data;
  while Len > 0 do
  begin
    Context.Buffer[Context.Index] := P^;
    Inc(P);
    Inc(Context.Index);
    Dec(Len);
    if Context.Index = 64 then
    begin
      Context.Index := 0;
      SHA1Compress(Context);
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,660; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure SHA1Final(var Context: TSHA1Context; var Digest: TByteDynArray);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,661 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Context.Buffer[Context.Index] := $80;
  if Context.Index >= 56 then
  begin
    SHA1Compress(Context);
  end;

  PLongword(@Context.Buffer[56])^ := RB(Context.Hi);
  PLongword(@Context.Buffer[60])^ := RB(Context.Lo);
  SHA1Compress(Context);
  Context.Hash[0] := RB(Context.Hash[0]);
  Context.Hash[1] := RB(Context.Hash[1]);
  Context.Hash[2] := RB(Context.Hash[2]);
  Context.Hash[3] := RB(Context.Hash[3]);
  Context.Hash[4] := RB(Context.Hash[4]);
  Move(Context.Hash, Digest, SizeOf(Digest));
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,661; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TSHA1Hash }

constructor TSHA1Hash.Create;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,662 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SetLength(fDigest, 20);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,662; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TSHA1Hash.Initialize;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,663 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FillChar(fContext, SizeOf(fContext), 0);
  FillChar(fDigest[0], 20, 0);
  SHA1Init(fContext);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,663; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TSHA1Hash.Update(const Data; Size: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,664 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SHA1Update(fContext, Data, Size);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,664; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TSHA1Hash.Finalize;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,665 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SHA1Final(fContext, fDigest);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,665; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TSHA1Hash.CopyDigest(var Dest);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,666 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Move(fDigest[0], Dest, 20);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,666; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

end.
