{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  ZLib Interface

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth
------------------------------------------------------------------------------}

unit Bfg.Compression;

interface

uses
  ZLib.LibInterface{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

const
  LEVEL_UNK     = -1;
  LEVEL_FAST    = 0;
  LEVEL_NORMAL  = 1;
  LEVEL_MAX     = 2;

function Decompress(pBlock: Pointer; iCompressedSize: Integer; var iInOutSize: Integer): Pointer;
function Compress(pBlock: Pointer; iDataSize: Integer; out iCompressedSize: Integer): Pointer;

procedure SetGlobalCompressionLevel(iLevel: Integer);
function GetGlobalCompressionLevel: Integer;

implementation

{$G-}

var
  GlobalCompressionLevel: TZCompressionLevel = zcMax;

procedure SetGlobalCompressionLevel(iLevel: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,630 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  case iLevel of
    LEVEL_FAST: GlobalCompressionLevel := zcFastest;
    LEVEL_NORMAL: GlobalCompressionLevel := zcDefault;
    LEVEL_MAX: GlobalCompressionLevel := zcMax;
  else
    GlobalCompressionLevel := zcFastest;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,630; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function GetGlobalCompressionLevel: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,631 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  case GlobalCompressionLevel of
    zcFastest: Result := LEVEL_FAST;
    zcDefault: Result := LEVEL_NORMAL;
    zcMax: Result := LEVEL_MAX;
  else
    Result := LEVEL_UNK;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,631; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function Compress(pBlock: Pointer; iDataSize: Integer; out iCompressedSize: Integer): Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,632 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  ZCompress(pBlock, iDataSize, Result, iCompressedSize, GlobalCompressionLevel);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,632; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function Decompress(pBlock: Pointer; iCompressedSize: Integer; var iInOutSize: Integer): Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,633 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  ZDecompress(pBlock, iCompressedSize, Result, iInOutSize, iInOutSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,633; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

end.
