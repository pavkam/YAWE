{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Typedata structs declaration and some handy macros.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Bfg.TypInfoEx;

interface

uses
  SysUtils,
  TypInfo,
  Bfg.Utils{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

type
  PIntegerTypeInfo = ^TIntegerTypeInfo;
  TIntegerTypeInfo = packed record
    OrdinalType: TOrdType;
    MinValue: Integer;
    MaxValue: Integer;
  end;

  PEnumInfo = ^TEnumInfo;
  TEnumInfo = packed record
    OrdinalType: TOrdType;
    MinValue: Integer;
    MaxValue: Integer;
    BaseType: PPTypeInfo;
    NameList: string[255];
    DeclaredIn: string[255];
  end;

  PSetInfo = ^TSetInfo;
  TSetInfo = packed record
    OrdinalType: TOrdType;
    CompType: PPTypeInfo;
  end;

  PFloatInfo = ^TFloatInfo;
  TFloatInfo = packed record
    FloatType: TFloatType;
  end;

  PClassInfo = ^TClassInfo;
  TClassInfo = packed record
    ClassType: TClass;
    ParentInfo: PPTypeInfo;
    PropCount: Smallint;
    DeclaredIn: string[255];
  end;

  PInterfaceInfo = ^TInterfaceInfo;
  TInterfaceInfo = packed record
    Parent: PPTypeInfo;
    Flags: TIntfFlags;
    GUID: TGuid;
    DeclaredIn: string[255];
    PropCount: Word;
  end;

  PInt64TypeInfo = ^TInt64TypeInfo;
  TInt64TypeInfo = packed record
    MinValue: Int64;
    MaxValue: Int64;
  end;

  PDynArrayInfo = ^TDynArrayInfo;
  TDynArrayInfo = packed record
    ElemSize: Integer;
    ElemTypeCleanup: PPTypeInfo;
    Reserved1: array[0..3] of Byte;
    ElemType: PPTypeInfo;
    DeclaredIn: string[255];
  end;

  PStaticArrayInfo = ^TStaticArrayInfo;
  TStaticArrayInfo = packed record
    ArraySize: Integer;
    ElemCount: Integer;
    ElemInfo: PPTypeInfo;
  end;

  PRecordInfo = ^TRecordInfo;
  TRecordInfo = packed record
    Reserved: Word;
    Size: Integer;
    FieldCount: Integer;
  end;

  PRecordFieldInfo = ^TRecordFieldInfo;
  TRecordFieldInfo = packed record
    FieldInfo: PPTypeInfo;
    Offset: Integer;
  end;

procedure CopyRecord(pSource, pDest: Pointer; pTypInfo: PTypeInfo);

function GetRecordFieldInfoList(pInfo: PRecordInfo): PRecordFieldInfo;
function GetClassPropData(pInfo: PClassInfo): PPropInfo;
function GetInterfacePropData(pInfo: PInterfaceInfo): PPropInfo;

function SetToString(TypeInfo: PTypeInfo; Value: Integer; Brackets, CStyle: Boolean): string;
function StringToSet(TypeInfo: PTypeInfo; const Value: string): Integer;

implementation

uses
  RTLConsts;

function SetToString(TypeInfo: PTypeInfo; Value: Integer; Brackets, CStyle: Boolean): string;
const
  ElemDelim: array[Boolean] of Char = (',', '|');
var
  S: TIntegerSet;
  I: Integer;
  C: Char;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,824 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := '';
  Integer(S) := Value;
  TypeInfo := GetTypeData(TypeInfo)^.CompType^;
  C := ElemDelim[CStyle];
  for I := 0 to SizeOf(Integer) * 8 - 1 do
  begin
    if I in S then
    begin
      if Result <> '' then Result := Result + C;
      Result := Result + GetEnumName(TypeInfo, I);
    end;
  end;
  if Brackets then Result := '[' + Result + ']';
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,824; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function StringToSet(TypeInfo: PTypeInfo; const Value: string): Integer;
var
  P: PChar;
  EnumName: string;
  EnumValue: Longint;
  EnumInfo: PTypeInfo;

  // grab the next enum name
  function NextWord(var P: PChar): string;
  var
    i: Integer;
  begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,825 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
    i := 0;

    // scan til whitespace
    while not (P[i] in [',', '|', ' ', #0, ']']) do
      Inc(i);

    SetString(Result, P, i);

    // skip whitespace
    while P[i] in [',', '|', ' ', ']'] do
      Inc(i);

    Inc(P, i);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,825; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
  end;

begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,826 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := 0;
  if Value = '' then Exit;
  P := PChar(Value);

  // skip leading bracket and whitespace
  while P^ in ['[',' '] do Inc(P);

  EnumInfo := GetTypeData(TypeInfo)^.CompType^;
  EnumName := NextWord(P);
  while EnumName <> '' do
  begin
    EnumValue := GetEnumValue(EnumInfo, EnumName);
    if EnumValue < 0 then
      raise EPropertyConvertError.CreateResFmt(@SInvalidPropertyElement, [EnumName]);
    Include(TIntegerSet(Result), EnumValue);
    EnumName := NextWord(P);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,826; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure CopyRecord(pSource, pDest: Pointer; pTypInfo: PTypeInfo);
asm
  TEST  ECX, ECX
  JZ    @@Exit
  XCHG  EAX, EDX
  CALL  System.@CopyRecord
@@Exit:
end;

function GetRecordFieldInfoList(pInfo: PRecordInfo): PRecordFieldInfo;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,827 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := Pointer(Integer(@pInfo^.FieldCount) + SizeOf(Integer));
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,827; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function GetClassPropData(pInfo: PClassInfo): PPropInfo;
var
  Len: Byte;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,828 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Len := Length(pInfo^.DeclaredIn);
  Result := PPropInfo(Longword(@pInfo^.DeclaredIn) + Len + 3);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,828; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function GetInterfacePropData(pInfo: PInterfaceInfo): PPropInfo;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,829 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := Pointer(Integer(@pInfo^.PropCount) + SizeOf(Word));
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,829; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

end.
