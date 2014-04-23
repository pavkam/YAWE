{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Collection of various algorithms, mostly sorting.
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
  @Changes Frixion
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Bfg.Algorithm;

interface

uses
  SysUtils,
  Bfg.Utils{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

type
  TInterfaceCompare = function(const I1, I2: IInterface): Integer;
  TObjectCompare = function(O1, O2: TObject): Integer;
  TStringCompare = function(const S1, S2: string): Integer;
  TPointerCompare = function(P1, P2: Pointer): Integer;
  TIntegerCompare = function(I1, I2: Integer): Integer;
  TSingleCompare = function(const F1, F2: Single): Integer;

  TInterfaceCompareEx = function(const I1, I2: IInterface): Integer of object;
  TObjectCompareEx = function(O1, O2: TObject): Integer of object;
  TStringCompareEx = function(const S1, S2: string): Integer of object;
  TPointerCompareEx = function(P1, P2: Pointer): Integer of object;
  TIntegerCompareEx = function(I1, I2: Integer): Integer of object;
  TSingleCompareEx = function(const F1, F2: Single): Integer of object;

  TSortingHint = (shUnsorted, shSorted);

{
  The SortArray function encapsulates 3 distinct sorting algorithms. If the number
  of elements is less than or equal to 16, it's reduced into an Insertion Sort.
  If the number of elements is greater, than the algorithm performs an Intro Sort.
  Intro Sort also consists of 2 phases - Quick Sort and Heap Sort. It first tries
  to sort the array using the Quick Sort algorithm up to certain depth. This is
  because the Quick Sort algorithm has problems with running out of stack space if
  left running on a large dataset. After the maximum number of recursive calls have
  been made, the Heap Sort algorithm finishes the job. Also by limiting the maximum
  number of recursions of the Quick Sort algorithm the "critical pivot" problem
  is removed also. This problem causes in some rare cases Quick Sort algorithm
  to behave like a quadratic function. Unlike Quick Sort, Heap Sort has the unique
  ability that it's running cost varies only very little based on the order of the
  elements it sorts.

  Intro Sort:
    Avg. cost - O(N log N)
    Min. cost - O(N log N)
    Max. cost - O(N log N)
}

procedure SortArray(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompareEx; Hint: TSortingHint = shUnsorted); overload;

{ Comparison is performed by the user-defined callback function. }
procedure SortArray(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompare; Hint: TSortingHint = shUnsorted); overload;

{ Comparison is automatic. }
procedure SortArray(ItemList: PPointerArray; Count: Integer; Signed: Boolean = False;
  Hint: TSortingHint = shUnsorted); overload;

{ ShellSort function sorts an array. While usually slower on unsorted lists,
  it's much faster with almost sorted lists or reversed lists. Later we may
  improve the algorithm to use Smooth Sort - a variation of Heap Sort - which is
  very fast at huge datasets of almost sorted arrays and has avg. running time of
  O(N log N) on unsorted ones like Heap Sort.

  Shell Sort:
    Avg. cost - N/A
    Min. cost - O(log N)
    Max. cost - O(N^1.25-N^1.5)
}
procedure ShellSort(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompareEx); overload;

{ Comparison is performed by the user-defined callback function. }
procedure ShellSort(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompare); overload;

{ Comparison is automatic. }
procedure ShellSort(ItemList: PPointerArray; Count: Integer;
  Signed: Boolean = False); overload;

{ Sorts items from index start to count-1 and then merges the 2 individually sorted
  partitions together. Use only when it's guaranteed that items from 0 to Start-1
  are already sorted. }
  
procedure PartialResortArray(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompareEx; Start: Integer); overload;

procedure PartialResortArray(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompare; Start: Integer); overload;

procedure PartialResortArray(ItemList: PPointerArray; Count: Integer;
  Start: Integer; Signed: Boolean = False); overload;

{ Searches an sorted array of specified length. Positive match is determined by the
  function supplied. }
function BinarySearch(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; MatchFunction: TPointerCompareEx): Integer; overload;

function BinarySearch(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; MatchFunction: TPointerCompare): Integer; overload;

function BinarySearch(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; Signed: Boolean = False): Integer; overload;

function BinarySearchGreater(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; MatchFunction: TPointerCompareEx): Integer; overload;

function BinarySearchGreater(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; MatchFunction: TPointerCompare): Integer; overload;

function BinarySearchGreater(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; Signed: Boolean = False): Integer; overload;

function BinarySearchGreaterOrEqual(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; MatchFunction: TPointerCompareEx): Integer; overload;

function BinarySearchGreaterOrEqual(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; MatchFunction: TPointerCompare): Integer; overload;

function BinarySearchGreaterOrEqual(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; Signed: Boolean = False): Integer; overload;

function BinarySearchLesser(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; MatchFunction: TPointerCompareEx): Integer; overload;

function BinarySearchLesser(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; MatchFunction: TPointerCompare): Integer; overload;

function BinarySearchLesser(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; Signed: Boolean = False): Integer; overload;

function BinarySearchLesserOrEqual(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; MatchFunction: TPointerCompareEx): Integer; overload;

function BinarySearchLesserOrEqual(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; MatchFunction: TPointerCompare): Integer; overload;

function BinarySearchLesserOrEqual(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; Signed: Boolean = False): Integer; overload;

function PackArray(ItemList: PPointerArray; Count: Integer): Integer;

implementation

{$REGION 'Forwards'}
procedure MakeHeap(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompareEx); forward; overload;

procedure SortHeap(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompareEx); forward; overload;

procedure MakeHeapS(ItemList: PPointerArray; Count: Integer); forward;

procedure SortHeapS(ItemList: PPointerArray; Count: Integer); forward;

procedure MakeHeap(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompare); forward; overload;

procedure SortHeap(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompare); forward; overload;

procedure MakeHeap(ItemList: PPointerArray; Count: Integer); forward; overload;

procedure SortHeap(ItemList: PPointerArray; Count: Integer); forward; overload;

procedure InternalInsertionSort(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompareEx); forward; overload;

procedure InternalInsertionSort(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompare); forward; overload;

procedure InternalInsertionSort(ItemList: PPointerArray; Count: Integer); forward; overload;

procedure InternalInsertionSortS(ItemList: PPointerArray; Count: Integer); forward;

procedure IntroSort(L, R: Integer; ItemList: PPointerArray;
  Compare: TPointerCompareEx; DepthLimit: Integer); forward; overload;

procedure IntroSort(L, R: Integer; ItemList: PPointerArray;
  Compare: TPointerCompare; DepthLimit: Integer); forward; overload;

procedure IntroSort(L, R: Integer; ItemList: PPointerArray; Signed: Boolean;
  DepthLimit: Integer); forward; overload;

procedure InternalDownHeap(ItemList: PPointerArray; Index, Count: Integer;
  P: Pointer; Compare: TPointerCompareEx); forward; overload;

procedure InternalDownHeap(ItemList: PPointerArray; Index, Count: Integer;
  P: Pointer; Compare: TPointerCompare); forward; overload;

procedure InternalDownHeap(ItemList: PPointerArray; Index, Count: Integer;
  P: Pointer); forward; overload;

procedure InternalDownHeapS(ItemList: PPointerArray; Index, Count: Integer;
  P: Pointer); forward;
{$ENDREGION}

procedure InternalRotate(Ptr: Pointer; Count: Integer);
asm
        MOV     ECX, [EAX+EDX*4]
        JMP     DWORD PTR [@@wV+EDX*4]
@@wV:   DD      @@w00, @@w01, @@w02, @@w03
        DD      @@w04, @@w05, @@w06, @@w07
        DD      @@w08, @@w09, @@w10, @@w11
        DD      @@w12, @@w13, @@w14, @@w15
@@w15:  MOV     EDX ,[EAX+56]
        MOV     [EAX+60], EDX
@@w14:  MOV     EDX ,[EAX+52]
        MOV     [EAX+56], EDX
@@w13:  MOV     EDX ,[EAX+48]
        MOV     [EAX+52], EDX
@@w12:  MOV     EDX ,[EAX+44]
        MOV     [EAX+48], EDX
@@w11:  MOV     EDX ,[EAX+40]
        MOV     [EAX+44], EDX
@@w10:  MOV     EDX ,[EAX+36]
        MOV     [EAX+40], EDX
@@w09:  MOV     EDX ,[EAX+32]
        MOV     [EAX+36], EDX
@@w08:  MOV     EDX ,[EAX+28]
        MOV     [EAX+32], EDX
@@w07:  MOV     EDX ,[EAX+24]
        MOV     [EAX+28], EDX
@@w06:  MOV     EDX ,[EAX+20]
        MOV     [EAX+24], EDX
@@w05:  MOV     EDX ,[EAX+16]
        MOV     [EAX+20], EDX
@@w04:  MOV     EDX ,[EAX+12]
        MOV     [EAX+16], EDX
@@w03:  MOV     EDX ,[EAX+8]
        MOV     [EAX+12], EDX
@@w02:  MOV     EDX ,[EAX+4]
        MOV     [EAX+8], EDX
@@w01:  MOV     EDX, [EAX]
        MOV     [EAX+4], EDX
@@w00:  MOV     [EAX], ECX
end;

procedure InternalInsertionSort(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompareEx);
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,488 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  I := 1;
  while I < Count do
  begin
    J := I - 1;
    while J >= 0 do
    begin
      if Compare(ItemList^[I], ItemList^[J]) >= 0 then
      begin
        Break;
      end;
      Dec(J);
    end;
    Inc(J);
    if I <> J then
    begin
      InternalRotate(@ItemList^[J], I - J);
    end;
    Inc(I);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,488; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure InternalInsertionSort(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompare);
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,489 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  I := 1;
  while I < Count do
  begin
    J := I - 1;
    while J >= 0 do
    begin
      if Compare(ItemList^[I], ItemList^[J]) >= 0 then
      begin
        Break;
      end;
      Dec(J);
    end;
    Inc(J);
    if I <> J then
    begin
      InternalRotate(@ItemList^[J], I - J);
    end;
    Inc(I);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,489; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure InternalInsertionSort(ItemList: PPointerArray; Count: Integer);
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,490 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  I := 1;
  while I < Count do
  begin
    J := I - 1;
    while J >= 0 do
    begin
      if Longword(ItemList^[I]) >= Longword(ItemList^[J]) then
      begin
        Break;
      end;
      Dec(J);
    end;
    Inc(J);
    if I <> J then
    begin
      InternalRotate(@ItemList^[J], I - J);
    end;
    Inc(I);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,490; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure InternalInsertionSortS(ItemList: PPointerArray; Count: Integer);
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,491 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  I := 1;
  while I < Count do
  begin
    J := I - 1;
    while J >= 0 do
    begin
      if Integer(ItemList^[I]) >= Integer(ItemList^[J]) then
      begin
        Break;
      end;
      Dec(J);
    end;
    Inc(J);
    if I <> J then
    begin
      InternalRotate(@ItemList^[J], I - J);
    end;
    Inc(I);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,491; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure IntroSort(L, R: Integer; ItemList: PPointerArray;
  Compare: TPointerCompareEx; DepthLimit: Integer);
var
  I, J: Integer;
  P, T: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,492 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  I := L;
  J := R;
  if DepthLimit = 0 then
  begin
    Dec(J, I);
    MakeHeap(@ItemList^[I], J + 1, Compare);
    SortHeap(@ItemList^[I], J + 1, Compare);
    Exit;
  end;
  Dec(DepthLimit);
  P := ItemList^[(I + J) shr 1];
  if Compare(ItemList^[I], P) <= 0 then
  begin
    if Compare(P, ItemList^[J]) > 0 then
    begin
      if Compare(ItemList^[I], ItemList^[J]) <= 0 then
      begin
        P := ItemList^[J];
      end else
      begin
        P := ItemList^[I];
      end;
    end;
  end else if Compare(ItemList^[I], ItemList^[J]) <= 0 then
  begin
    P := ItemList^[I];
  end else if Compare(P, ItemList^[J]) <= 0 then
  begin
    P := ItemList^[J];
  end;

  repeat
    while Compare(ItemList^[I], P) < 0 do Inc(I);
    while Compare(ItemList^[J], P) > 0 do Dec(J);
    if I <= J then
    begin
      T := ItemList^[I];
      ItemList^[I] := ItemList^[J];
      ItemList^[J] := T;
      Inc(I);
      Dec(J);
    end;
  until I > J;
  if J - L > 15 then
  begin
    IntroSort(L, J, ItemList, Compare, DepthLimit);
  end else
  begin
    InternalInsertionSort(@ItemList^[L], J - L + 1, Compare);
  end;
  if R - I > 15 then
  begin
    IntroSort(I, R, ItemList, Compare, DepthLimit);
  end else
  begin
    InternalInsertionSort(@ItemList^[I], R - I + 1, Compare);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,492; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure IntroSort(L, R: Integer; ItemList: PPointerArray;
  Compare: TPointerCompare; DepthLimit: Integer);
var
  I, J: Integer;
  P, T: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,493 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  I := L;
  J := R;
  if DepthLimit = 0 then
  begin
    Dec(J, I);
    MakeHeap(@ItemList^[I], J + 1, Compare);
    SortHeap(@ItemList^[I], J + 1, Compare);
    Exit;
  end;
  Dec(DepthLimit);
  P := ItemList^[(I + J) shr 1];
  if Compare(ItemList^[I], P) <= 0 then
  begin
    if Compare(P, ItemList^[J]) > 0 then
    begin
      if Compare(ItemList^[I], ItemList^[J]) <= 0 then
      begin
        P := ItemList^[J];
      end else
      begin
        P := ItemList^[I];
      end;
    end;
  end else if Compare(ItemList^[I], ItemList^[J]) <= 0 then
  begin
    P := ItemList^[I];
  end else if Compare(P, ItemList^[J]) <= 0 then
  begin
    P := ItemList^[J];
  end;

  repeat
    while Compare(ItemList^[I], P) < 0 do Inc(I);
    while Compare(ItemList^[J], P) > 0 do Dec(J);
    if I <= J then
    begin
      T := ItemList^[I];
      ItemList^[I] := ItemList^[J];
      ItemList^[J] := T;
      Inc(I);
      Dec(J);
    end;
  until I > J;
  if J - L > 15 then
  begin
    IntroSort(L, J, ItemList, Compare, DepthLimit);
  end else
  begin
    InternalInsertionSort(@ItemList^[L], J - L + 1, Compare);
  end;
  if R - I > 15 then
  begin
    IntroSort(I, R, ItemList, Compare, DepthLimit);
  end else
  begin
    InternalInsertionSort(@ItemList^[I], R - I + 1, Compare);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,493; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure IntroSort(L, R: Integer; ItemList: PPointerArray; Signed: Boolean;
  DepthLimit: Integer);
var
  I, J: Integer;
  P, T: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,494 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  I := L;
  J := R;

  if not Signed then
  begin
    if DepthLimit = 0 then
    begin
      Dec(J, I);
      MakeHeap(@ItemList^[I], J + 1);
      SortHeap(@ItemList^[I], J + 1);
      Exit;
    end;
    Dec(DepthLimit);
    P := ItemList^[(I + J) shr 1];
    if Longword(ItemList^[I]) <= Longword(P) then
    begin
      if Longword(P) > Longword(ItemList^[J]) then
      begin
        if Longword(ItemList^[I]) <= Longword(ItemList^[J]) then
        begin
          P := ItemList^[J];
        end else
        begin
          P := ItemList^[I];
        end;
      end;
    end else if Longword(ItemList^[I]) <= Longword(ItemList^[J]) then
    begin
      P := ItemList^[I];
    end else if Longword(P) <= Longword(ItemList^[J]) then
    begin
      P := ItemList^[J];
    end;

    repeat
      while Longword(ItemList^[I]) < Longword(P) do Inc(I);
      while Longword(ItemList^[J]) > Longword(P) do Dec(J);
      if I <= J then
      begin
        T := ItemList^[I];
        ItemList^[I] := ItemList^[J];
        ItemList^[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if J - L > 15 then
    begin
      IntroSort(L, J, ItemList, False, DepthLimit);
    end else
    begin
      InternalInsertionSort(@ItemList^[L], J - L + 1);
    end;
    if R - I > 15 then
    begin
      IntroSort(I, R, ItemList, False, DepthLimit)
    end else
    begin
      InternalInsertionSort(@ItemList^[I], R - I + 1);
    end;
  end else
  begin
    if DepthLimit = 0 then
    begin
      Dec(J, I);
      MakeHeapS(@ItemList^[I], J + 1);
      SortHeapS(@ItemList^[I], J + 1);
      Exit;
    end;
    Dec(DepthLimit);
    P := ItemList^[(I + J) shr 1];
    if Integer(ItemList^[I]) <= Integer(P) then
    begin
      if Integer(P) > Integer(ItemList^[J]) then
      begin
        if Integer(ItemList^[I]) <= Integer(ItemList^[J]) then
        begin
          P := ItemList^[J];
        end else
        begin
          P := ItemList^[I];
        end;
      end;
    end else if Integer(ItemList^[I]) <= Integer(ItemList^[J]) then
    begin
      P := ItemList^[I];
    end else if Integer(P) <= Integer(ItemList^[J]) then
    begin
      P := ItemList^[J];
    end;

    repeat
      while Integer(ItemList^[I]) < Integer(P) do Inc(I);
      while Integer(ItemList^[J]) > Integer(P) do Dec(J);
      if I <= J then
      begin
        T := ItemList^[I];
        ItemList^[I] := ItemList^[J];
        ItemList^[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if J - L > 15 then
    begin
      IntroSort(L, J, ItemList, True, DepthLimit);
    end else
    begin
      InternalInsertionSort(@ItemList^[L], J - L + 1);
    end;
    if R - I > 15 then
    begin
      IntroSort(I, R, ItemList, True, DepthLimit);
    end else
    begin
      InternalInsertionSortS(@ItemList^[I], R - I + 1);
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,494; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function Log2(L: LongWord): LongWord;
asm
  TEST    EAX, EAX
  JE      @@zq
  BSR     EAX, EAX
@@zq:
end;

procedure SortArray(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompareEx; Hint: TSortingHint = shUnsorted);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,495 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Count < 2 then Exit;

  if Count < 17 then
  begin
    InternalInsertionSort(ItemList, Count, Compare);
  end else
  begin
    case Hint of
      shUnsorted:
      begin
        IntroSort(0, Count - 1, ItemList, Compare, Log2(Count) * 2);
      end;
      shSorted:
      begin
        if Count <= 128 then
        begin
          ShellSort(ItemList, Count, Compare);
        end else
        begin
          MakeHeap(ItemList, Count, Compare);
          SortHeap(ItemList, Count, Compare);
        end;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,495; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure SortArray(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompare; Hint: TSortingHint);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,496 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Count < 2 then Exit;

  if Count < 17 then
  begin
    InternalInsertionSort(ItemList, Count, Compare);
  end else
  begin
    case Hint of
      shUnsorted:
      begin
        IntroSort(0, Count - 1, ItemList, Compare, Log2(Count) * 2);
      end;
      shSorted:
      begin
        if Count <= 128 then
        begin
          ShellSort(ItemList, Count, Compare);
        end else
        begin
          MakeHeap(ItemList, Count, Compare);
          SortHeap(ItemList, Count, Compare);
        end;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,496; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure SortArray(ItemList: PPointerArray; Count: Integer; Signed: Boolean;
  Hint: TSortingHint);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,497 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Count < 2 then Exit;

  if Count < 17 then
  begin
    if Signed then
    begin
      InternalInsertionSortS(ItemList, Count);
    end else
    begin
      InternalInsertionSort(ItemList, Count);
    end;
  end else
  begin
    case Hint of
      shUnsorted:
      begin
        IntroSort(0, Count - 1, ItemList, Signed, Log2(Count) * 2);
      end;
      shSorted:
      begin
        if Count <= 128 then
        begin
          ShellSort(ItemList, Count, Signed);
        end else
        begin
          if not Signed then
          begin
            MakeHeap(ItemList, Count);
            SortHeap(ItemList, Count);
          end else
          begin
            MakeHeapS(ItemList, Count);
            SortHeapS(ItemList, Count);
          end;
        end;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,497; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure ShellSort(ItemList: PPointerArray; Count: Integer; Signed: Boolean); // Sedgewick
const
  IncrementTable: array[0..15] of Integer = (
    1391376, 463792, 198768, 86961, 33936, 13776, 4592, 1968, 861, 336, 112, 48, 21, 7, 3, 1
  );
var
  I, J, K, L: Longword;
  P: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,498 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if not Signed then
  begin
    for K := 0 to High(IncrementTable) do
    begin
      L := IncrementTable[K];
      for I := L to Count -1 do
      begin
        P := ItemList^[I];
        J := I;
        while (J >= L) and (Longword(P) < Longword(ItemList^[J - L])) do
        begin
          ItemList^[J] := ItemList^[J - L];
          Dec(J, L);
        end;

        if I <> J then
        begin
          ItemList^[J] := P;
        end;
      end;
    end;
  end else
  begin
    for K := 0 to High(IncrementTable) do
    begin
      L := IncrementTable[K];
      for I := L to Count -1 do
      begin
        P := ItemList^[I];
        J := I;
        while (J >= L) and (Integer(P) < Integer(ItemList^[J - L])) do
        begin
          ItemList^[J] := ItemList^[J - L];
          Dec(J, L);
        end;

        if I <> J then
        begin
          ItemList^[J] := P;
        end;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,498; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure ShellSort(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompare); // Sedgewick
const
  IncrementTable: array[0..15] of Integer = (
    1391376, 463792, 198768, 86961, 33936, 13776, 4592, 1968, 861, 336, 112, 48, 21, 7, 3, 1
  );
var
  I, J, K, L: Longword;
  P: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,499 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for K := 0 to High(IncrementTable) do
  begin
    L := IncrementTable[K];
    for I := L to Count -1 do
    begin
      P := ItemList^[I];
      J := I;
      while (J >= L) and (Compare(P, ItemList^[J - L]) < 0) do
      begin
        ItemList^[J] := ItemList^[J - L];
        Dec(J, L);
      end;
      
      if I <> J then
      begin
        ItemList^[J] := P;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,499; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure ShellSort(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompareEx); // Sedgewick
const
  IncrementTable: array[0..15] of Integer = (
    1391376, 463792, 198768, 86961, 33936, 13776, 4592, 1968, 861, 336, 112, 48, 21, 7, 3, 1
  );
var
  I, J, K, L: Longword;
  P: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,500 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for K := 0 to High(IncrementTable) do
  begin
    L := IncrementTable[K];
    for I := L to Count -1 do
    begin
      P := ItemList^[I];
      J := I;
      while (J >= L) and (Compare(P, ItemList^[J - L]) < 0) do
      begin
        ItemList^[J] := ItemList^[J - L];
        Dec(J, L);
      end;
      
      if I <> J then
      begin
        ItemList^[J] := P;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,500; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BinarySearch(Value: Pointer; ItemList: PPointerArray; Count: Integer;
  MatchFunction: TPointerCompareEx): Integer;
var
  L, M, C: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,501 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Count > 0 then
  begin
    L := 0;
    Dec(Count);
    while L <= Count do
    begin
      M := (L + Count) shr 1;
      C := MatchFunction(Value, ItemList^[M]);
      if C > 0 then
        L := M + 1
      else if C <> 0 then
        Count := M - 1
      else
      begin
        Result := M;
        Exit;
      end;
    end;
  end;
  Result := -1;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,501; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BinarySearch(Value: Pointer; ItemList: PPointerArray; Count: Integer;
  MatchFunction: TPointerCompare): Integer;
var
  L, M, C: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,502 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Count > 0 then
  begin
    L := 0;
    Dec(Count);
    while L <= Count do
    begin
      M := (L + Count) shr 1;
      C := MatchFunction(Value, ItemList^[M]);
      if C > 0 then
        L := M + 1
      else if C <> 0 then
        Count := M - 1
      else
      begin
        Result := M;
        Exit;
      end;
    end;
  end;
  Result := -1;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,502; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BinarySearch(Value: Pointer; ItemList: PPointerArray; Count: Integer;
  Signed: Boolean): Integer;
var
  L, M: Integer;
  P: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,503 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Count > 0 then
  begin
    L := 0;
    Dec(Count);

    if not Signed then
    begin
      while L <= Count do
      begin
        M := (L + Count) shr 1;
        P := ItemList^[M];
        if Longword(Value) > Longword(P) then
          L := M + 1
        else if Longword(Value) <> Longword(P) then
          Count := M - 1
        else
        begin
          Result := M;
          Exit;
        end;
      end;
    end else
    begin
      while L <= Count do
      begin
        M := (L + Count) shr 1;
        P := ItemList^[M];
        if Integer(Value) > Integer(P) then
          L := M + 1
        else if Integer(Value) <> Integer(P) then
          Count := M - 1
        else
        begin
          Result := M;
          Exit;
        end;
      end;
    end;
  end;
  Result := -1;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,503; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BinarySearchGreater(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; MatchFunction: TPointerCompareEx): Integer;
var
  L, M: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,504 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if Count > 0 then
  begin
    L := 0;
    Dec(Count);
    while L <= Count do
    begin
      M := (L + Count) shr 1;
      if MatchFunction(Value, ItemList^[M]) >= 0 then
        L := M + 1
      else
      begin
        Count := M - 1;
        Result := M;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,504; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BinarySearchGreater(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; MatchFunction: TPointerCompare): Integer;
var
  L, M: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,505 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if Count > 0 then
  begin
    L := 0;
    Dec(Count);
    while L <= Count do
    begin
      M := (L + Count) shr 1;
      if MatchFunction(Value, ItemList^[M]) >= 0 then
        L := M + 1
      else
      begin
        Count := M - 1;
        Result := M;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,505; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BinarySearchGreater(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; Signed: Boolean): Integer;
var
  L, M: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,506 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if Count > 0 then
  begin
    L := 0;
    Dec(Count);

    if not Signed then
    begin
      while L <= Count do
      begin
        M := (L + Count) shr 1;
        if Longword(Value) >=  Longword(ItemList^[M]) then
          L := M + 1
        else
        begin
          Count := M - 1;
          Result := M;
        end;
      end;
    end else
    begin
      while L <= Count do
      begin
        M := (L + Count) shr 1;
        if Integer(Value) >= Integer(ItemList^[M]) then
          L := M + 1
        else
        begin
          Count := M - 1;
          Result := M;
        end;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,506; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BinarySearchGreaterOrEqual(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; MatchFunction: TPointerCompareEx): Integer;
var
  L, M: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,507 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if Count > 0 then
  begin
    L := 0;
    Dec(Count);
    while L <= Count do
    begin
      M := (L + Count) shr 1;
      if MatchFunction(Value, ItemList^[M]) > 0 then
        L := M + 1
      else
      begin
        Count := M - 1;
        Result := M;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,507; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BinarySearchGreaterOrEqual(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; MatchFunction: TPointerCompare): Integer;
var
  L, M: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,508 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if Count > 0 then
  begin
    L := 0;
    Dec(Count);
    while L <= Count do
    begin
      M := (L + Count) shr 1;
      if MatchFunction(Value, ItemList^[M]) > 0 then
        L := M + 1
      else
      begin
        Count := M - 1;
        Result := M;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,508; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BinarySearchGreaterOrEqual(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; Signed: Boolean): Integer;
var
  L, M: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,509 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if Count > 0 then
  begin
    L := 0;
    Dec(Count);

    if not Signed then
    begin
      while L <= Count do
      begin
        M := (L + Count) shr 1;
        if Longword(Value) > Longword(ItemList^[M]) then
          L := M + 1
        else
        begin
          Count := M - 1;
          Result := M;
        end;
      end;
    end else
    begin
      while L <= Count do
      begin
        M := (L + Count) shr 1;
        if Integer(Value) > Integer(ItemList^[M]) then
          L := M + 1
        else
        begin
          Count := M - 1;
          Result := M;
        end;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,509; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BinarySearchLesser(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; MatchFunction: TPointerCompareEx): Integer;
var
  L, M: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,510 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if Count > 0 then
  begin
    L := 0;
    Dec(Count);
    while L <= Count do
    begin
      M := (L + Count) shr 1;
      if MatchFunction(Value, ItemList^[M]) <= 0 then
        Count := M - 1
      else
      begin
        L := M + 1;
        Result := M;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,510; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BinarySearchLesser(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; MatchFunction: TPointerCompare): Integer;
var
  L, M: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,511 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if Count > 0 then
  begin
    L := 0;
    Dec(Count);
    while L <= Count do
    begin
      M := (L + Count) shr 1;
      if MatchFunction(Value, ItemList^[M]) <= 0 then
        Count := M - 1
      else
      begin
        L := M + 1;
        Result := M;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,511; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BinarySearchLesser(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; Signed: Boolean): Integer;
var
  L, M: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,512 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if Count > 0 then
  begin
    L := 0;
    Dec(Count);

    if not Signed then
    begin
      while L <= Count do
      begin
        M := (L + Count) shr 1;
        if Longword(Value) <= Longword(ItemList^[M]) then
          Count := M - 1
        else
        begin
          L := M + 1;
          Result := M;
        end;
      end;
    end else
    begin
      while L <= Count do
      begin
        M := (L + Count) shr 1;
        if Integer(Value) <= Integer(ItemList^[M]) then
          Count := M - 1
        else
        begin
          L := M + 1;
          Result := M;
        end;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,512; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BinarySearchLesserOrEqual(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; MatchFunction: TPointerCompareEx): Integer;
var
  L, M: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,513 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if Count > 0 then
  begin
    L := 0;
    Dec(Count);
    while L <= Count do
    begin
      M := (L + Count) shr 1;
      if MatchFunction(Value, ItemList^[M]) < 0 then
        Count := M - 1
      else
      begin
        L := M + 1;
        Result := M;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,513; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BinarySearchLesserOrEqual(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; MatchFunction: TPointerCompare): Integer;
var
  L, M: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,514 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if Count > 0 then
  begin
    L := 0;
    Dec(Count);
    while L <= Count do
    begin
      M := (L + Count) shr 1;
      if MatchFunction(Value, ItemList^[M]) < 0 then
        Count := M - 1
      else
      begin
        L := M + 1;
        Result := M;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,514; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BinarySearchLesserOrEqual(Value: Pointer; ItemList: PPointerArray;
  Count: Integer; Signed: Boolean): Integer;
var
  L, M: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,515 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if Count > 0 then
  begin
    L := 0;
    Dec(Count);

    if not Signed then
    begin
      while L <= Count do
      begin
        M := (L + Count) shr 1;
        if Longword(Value) < Longword(ItemList^[M]) then
          Count := M - 1
        else
        begin
          L := M + 1;
          Result := M;
        end;
      end;
    end else
    begin
      while L <= Count do
      begin
        M := (L + Count) shr 1;
        if Integer(Value) < Integer(ItemList^[M]) then
          Count := M - 1
        else
        begin
          L := M + 1;
          Result := M;
        end;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,515; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure InternalDownHeap(ItemList: PPointerArray; Index, Count: Integer;
  P: Pointer; Compare: TPointerCompareEx);
var
  Top, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,516 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Top := Index;
  J := (Index * 2) + 2;
  while J < Count do
  begin
    if Compare(ItemList^[J], ItemList^[J - 1]) < 0 then
    begin
      Dec(J);
    end;
    ItemList^[Index] := ItemList^[J];
    Index := J;
    Inc(J, J + 2);
  end;
  if J = Count then
  begin
    ItemList^[Index] := ItemList^[J - 1];
    Index := J - 1;
  end;
  J := (Index - 1) shr 1;
  while (Index > Top) and (Compare(ItemList^[J], P) < 0) do
  begin
    ItemList^[Index] := ItemList^[J];
    Index := J;
    J := (Index - 1) shr 1;
  end;
  ItemList^[Index] := P;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,516; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure InternalDownHeap(ItemList: PPointerArray; Index, Count: Integer;
  P: Pointer; Compare: TPointerCompare);
var
  Top, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,517 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Top := Index;
  J := (Index * 2) + 2;
  while J < Count do
  begin
    if Compare(ItemList^[J], ItemList^[J - 1]) < 0 then
    begin
      Dec(J);
    end;
    ItemList^[Index] := ItemList^[J];
    Index := J;
    Inc(J, J + 2);
  end;
  if J = Count then
  begin
    ItemList^[Index] := ItemList^[J - 1];
    Index := J - 1;
  end;
  J := (Index - 1) shr 1;
  while (Index > Top) and (Compare(ItemList^[J], P) < 0) do
  begin
    ItemList^[Index] := ItemList^[J];
    Index := J;
    J := (Index - 1) shr 1;
  end;
  ItemList^[Index] := P;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,517; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure InternalDownHeap(ItemList: PPointerArray; Index, Count: Integer;
  P: Pointer);
var
  Top, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,518 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Top := Index;
  J := (Index * 2) + 2;
  while J < Count do
  begin
    if Longword(ItemList^[J]) < Longword(ItemList^[J - 1]) then
    begin
      Dec(J);
    end;
    ItemList^[Index] := ItemList^[J];
    Index := J;
    Inc(J, J + 2);
  end;
  if J = Count then
  begin
    ItemList^[Index] := ItemList^[J - 1];
    Index := J - 1;
  end;
  J := (Index - 1) shr 1;
  while (Index > Top) and (Longword(ItemList^[J]) < Longword(P)) do
  begin
    ItemList^[Index] := ItemList^[J];
    Index := J;
    J := (Index - 1) shr 1;
  end;
  ItemList^[Index] := P;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,518; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure InternalDownHeapS(ItemList: PPointerArray; Index, Count: Integer;
  P: Pointer);
var
  Top, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,519 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Top := Index;
  J := (Index * 2) + 2;
  while J < Count do
  begin
    if Integer(ItemList^[J]) < Integer(ItemList^[J - 1]) then
    begin
      Dec(J);
    end;
    ItemList^[Index] := ItemList^[J];
    Index := J;
    Inc(J, J + 2);
  end;
  if J = Count then
  begin
    ItemList^[Index] := ItemList^[J - 1];
    Index := J - 1;
  end;
  J := (Index - 1) shr 1;
  while (Index > Top) and (Integer(ItemList^[J]) < Integer(P)) do
  begin
    ItemList^[Index] := ItemList^[J];
    Index := J;
    J := (Index - 1) shr 1;
  end;
  ItemList^[Index] := P;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,519; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure MakeHeap(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompareEx);
var
  Parent: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,520 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Count > 1 then
  begin
    Parent := (Count - 2) shr 1;
    repeat
      InternalDownHeap(ItemList, Parent, Count, ItemList^[Parent], Compare);
      if Parent = 0 then
      begin
        Break;
      end;
      Dec(Parent);
    until False;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,520; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure MakeHeap(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompare);
var
  Parent: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,521 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Count > 1 then
  begin
    Parent := (Count - 2) shr 1;
    repeat
      InternalDownHeap(ItemList, Parent, Count, ItemList^[Parent], Compare);
      if Parent = 0 then
      begin
        Break;
      end;
      Dec(Parent);
    until False;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,521; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure MakeHeap(ItemList: PPointerArray; Count: Integer);
var
  Parent: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,522 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Count > 1 then
  begin
    Parent := (Count - 2) shr 1;
    repeat
      InternalDownHeap(ItemList, Parent, Count, ItemList^[Parent]);
      if Parent = 0 then
      begin
        Break;
      end;
      Dec(Parent);
    until False;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,522; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure MakeHeapS(ItemList: PPointerArray; Count: Integer);
var
  Parent: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,523 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Count > 1 then
  begin
    Parent := (Count - 2) shr 1;
    repeat
      InternalDownHeapS(ItemList, Parent, Count, ItemList^[Parent]);
      if Parent = 0 then
      begin
        Break;
      end;
      Dec(Parent);
    until False;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,523; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure SortHeap(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompareEx);
var
  P: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,524 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  while Count > 1 do
  begin
    Dec(Count);
    P := ItemList^[Count];
    ItemList^[Count] := ItemList^[0];
    InternalDownHeap(ItemList, 0, Count, P, Compare);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,524; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure SortHeap(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompare);
var
  P: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,525 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  while Count > 1 do
  begin
    Dec(Count);
    P := ItemList^[Count];
    ItemList^[Count] := ItemList^[0];
    InternalDownHeap(ItemList, 0, Count, P, Compare);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,525; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure SortHeap(ItemList: PPointerArray; Count: Integer);
var
  P: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,526 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  while Count > 1 do
  begin
    Dec(Count);
    P := ItemList^[Count];
    ItemList^[Count] := ItemList^[0];
    InternalDownHeap(ItemList, 0, Count, P);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,526; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure SortHeapS(ItemList: PPointerArray; Count: Integer);
var
  P: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,527 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  while Count > 1 do
  begin
    Dec(Count);
    P := ItemList^[Count];
    ItemList^[Count] := ItemList^[0];
    InternalDownHeapS(ItemList, 0, Count, P);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,527; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure InternalMerge(ItemList: PPointerArray; Lo, Hi, Pivot: Integer;
  Compare: TPointerCompareEx); overload;
var
  I, J, K, L: Integer;
  Temp: PPointerArray;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,528 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  L := (Pivot - Lo + 1) * SizeOf(Pointer);
  Temp := StackAlloc(L);
  Move(ItemList^[Lo], Temp[0], L);
  I := 0;
  K := Lo;
  J := Pivot + 1;
  while (K < J) and (J <= Hi) do
  begin
    if Compare(Temp[I], ItemList^[J]) <= 0 then
    begin
      ItemList^[K] := Temp[I];
      Inc(K);
      Inc(I);
    end else
    begin
      ItemList^[K] := ItemList^[J];
      Inc(K);
      Inc(J);
    end;
  end;

  Move(Temp[I], ItemList^[K], (J - K) * SizeOf(Pointer));
  StackFree(Temp);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,528; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure InternalMerge(ItemList: PPointerArray; Lo, Hi, Pivot: Integer;
  Compare: TPointerCompare); overload;
var
  I, J, K, L: Integer;
  Temp: PPointerArray;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,529 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  L := (Pivot - Lo + 1) * SizeOf(Pointer);
  Temp := StackAlloc(L);

  Move(ItemList^[Lo], Temp[0], L);
  I := 0;
  K := Lo;
  J := Pivot + 1;
  while (K < J) and (J <= Hi) do
  begin
    if Compare(Temp[I], ItemList^[J]) <= 0 then
    begin
      ItemList^[K] := Temp[I];
      Inc(K);
      Inc(I);
    end else
    begin
      ItemList^[K] := ItemList^[J];
      Inc(K);
      Inc(J);
    end;
  end;

  Move(Temp[I], ItemList^[K], (J - K) * SizeOf(Pointer));
  StackFree(Temp);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,529; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure InternalMerge(ItemList: PPointerArray; Lo, Hi, Pivot: Integer); overload;
var
  I, J, K, L: Integer;
  Temp: PPointerArray;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,530 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  L := (Pivot - Lo + 1) * SizeOf(Pointer);
  Temp := StackAlloc(L);
  Move(ItemList^[Lo], Temp[0], L);
  I := 0;
  K := Lo;
  J := Pivot + 1;
  while (K < J) and (J <= Hi) do
  begin
    if Longword(Temp[I]) <= Longword(ItemList^[J]) then
    begin
      ItemList^[K] := Temp[I];
      Inc(K);
      Inc(I);
    end else
    begin
      ItemList^[K] := ItemList^[J];
      Inc(K);
      Inc(J);
    end;
  end;

  Move(Temp[I], ItemList^[K], (J - K) * SizeOf(Pointer));
  StackFree(Temp);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,530; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure InternalMergeS(ItemList: PPointerArray; Lo, Hi, Pivot: Integer); overload;
var
  I, J, K, L: Integer;
  Temp: PPointerArray;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,531 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  L := (Pivot - Lo + 1) * SizeOf(Pointer);
  Temp := StackAlloc(L);

  Move(ItemList^[Lo], Temp[0], L);
  I := 0;
  K := Lo;
  J := Pivot + 1;
  while (K < J) and (J <= Hi) do
  begin
    if Integer(Temp[I]) <= Integer(ItemList^[J]) then
    begin
      ItemList^[K] := Temp[I];
      Inc(K);
      Inc(I);
    end else
    begin
      ItemList^[K] := ItemList^[J];
      Inc(K);
      Inc(J);
    end;
  end;

  Move(Temp[I], ItemList^[K], (J - K) * SizeOf(Pointer));
  StackFree(Temp);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,531; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure MergeSort(ItemList: PPointerArray; Lo, Hi: Integer;
  Compare: TPointerCompareEx); overload;
var
  Pivot: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,532 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Lo = Hi then Exit;
  Pivot := (Lo + Hi) shr 1;
  MergeSort(ItemList, Lo, Pivot, Compare);
  MergeSort(ItemList, Pivot + 1, Hi, Compare);
  InternalMerge(ItemList, Lo, Hi, Pivot, Compare);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,532; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure MergeSort(ItemList: PPointerArray; Lo, Hi: Integer;
  Compare: TPointerCompare); overload;
var
  Pivot: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,533 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Lo = Hi then Exit;
  Pivot := (Lo + Hi) shr 1;
  MergeSort(ItemList, Lo, Pivot, Compare);
  MergeSort(ItemList, Pivot + 1, Hi, Compare);
  InternalMerge(ItemList, Lo, Hi, Pivot, Compare);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,533; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure MergeSort(ItemList: PPointerArray; Lo, Hi: Integer; Signed: Boolean); overload;
var
  Pivot: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,534 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Lo = Hi then Exit;
  Pivot := (Lo + Hi) shr 1;
  MergeSort(ItemList, Lo, Pivot, Signed);
  MergeSort(ItemList, Pivot + 1, Hi, Signed);
  if not Signed then
  begin
    InternalMerge(ItemList, Lo, Hi, Pivot);
  end else
  begin
    InternalMergeS(ItemList, Lo, Hi, Pivot);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,534; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure PartialResortArray(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompareEx; Start: Integer);
var
  I, J, K, L: Integer;
  Temp: PPointerArray;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,535 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Count <= 1 then Exit;
  if Start >= Count then Exit;
  MergeSort(ItemList, Start, Count - 1, Compare);
  L := (Count - Start) * SizeOf(Pointer);
  Temp := StackAlloc(L);
  Move(ItemList^[Start], Temp[0], L);
  I := L - 1;
  K := Count -1;
  J := Start - 1;
  while (K > J) and (J >= 0) do
  begin
    if Compare(Temp[I], ItemList^[J]) > 0 then
    begin
      ItemList^[K] := Temp[I];
      Dec(K);
      Dec(I);
    end else
    begin
      ItemList^[K] := ItemList^[J];
      Dec(K);
      Dec(J);
    end;
  end;

  Move(Temp[I], ItemList^[K], (J - K) * SizeOf(Pointer));
  StackFree(Temp);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,535; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure PartialResortArray(ItemList: PPointerArray; Count: Integer;
  Compare: TPointerCompare; Start: Integer);
var
  I, J, K, L: Integer;
  Temp: PPointerArray;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,536 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Count <= 1 then Exit;
  if Start >= Count then Exit;
  MergeSort(ItemList, Start, Count - 1, Compare);
  L := (Count - Start) * SizeOf(Pointer);
  Temp := StackAlloc(L);
  Move(ItemList^[Start], Temp[0], L);
  I := L - 1;
  K := Count -1;
  J := Start - 1;
  while (K > J) and (J >= 0) do
  begin
    if Compare(Temp[I], ItemList^[J]) > 0 then
    begin
      ItemList^[K] := Temp[I];
      Dec(K);
      Dec(I);
    end else
    begin
      ItemList^[K] := ItemList^[J];
      Dec(K);
      Dec(J);
    end;
  end;

  Move(Temp[I], ItemList^[K], (J - K) * SizeOf(Pointer));
  StackFree(Temp);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,536; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure PartialResortArray(ItemList: PPointerArray; Count: Integer;
  Start: Integer; Signed: Boolean);
var
  I, J, K, L: Integer;
  Temp: PPointerArray;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,537 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Count <= 1 then Exit;
  if Start >= Count then Exit;
  MergeSort(ItemList, Start, Count - 1, Signed);
  L := (Count - Start) * SizeOf(Pointer);
  Temp := StackAlloc(L);
  Move(ItemList^[Start], Temp[0], L);
  I := L - 1;
  K := Count - 1;
  J := Start - 1;

  if not Signed then
  begin
    while (K > J) and (J > 0) do
    begin
      if Longword(Temp[I]) > Longword(ItemList^[J]) then
      begin
        ItemList^[K] := Temp[I];
        Dec(K);
        Dec(I);
      end else
      begin
        ItemList^[K] := ItemList^[J];
        Dec(K);
        Dec(J);
      end;
    end;
  end else
  begin
    while (K > J) and (J > 0) do
    begin
      if Integer(Temp[I]) > Integer(ItemList^[J]) then
      begin
        ItemList^[K] := Temp[I];
        Dec(K);
        Dec(I);
      end else
      begin
        ItemList^[K] := ItemList^[J];
        Dec(K);
        Dec(J);
      end;
    end;
  end;

  Move(Temp[0], ItemList^[K-I], (K - J) * SizeOf(Pointer));
  StackFree(Temp);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,537; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function PackArray(ItemList: PPointerArray; Count: Integer): Integer;
var
  StartIndex: Integer;
  EndIndex: Integer;
  PackedCount: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,538 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := Count;
  if Count = 0 then Exit;

  PackedCount := 0;
  StartIndex := 0;
  repeat
    // Locate the first/next non-nil element in the list
    while (ItemList^[StartIndex] = nil) and (StartIndex < Count) do
      Inc(StartIndex);

    if StartIndex < Count then // There is nothing more to do
    begin
      // Locate the next nil pointer
      EndIndex := StartIndex;
      while (ItemList^[EndIndex] <> nil) and (EndIndex < Count) do
        Inc(EndIndex);

      Dec(EndIndex);

      // Move this block of non-null items to the index recorded in PackedToCount:
      // If this is a contiguous non-nil block at the start of the list then
      // StartIndex and PackedToCount will be equal (and 0) so don't bother with the move.
      if StartIndex > PackedCount then
      begin
        Move(ItemList^[StartIndex], ItemList^[PackedCount], (EndIndex -
          StartIndex + 1) * SizeOf(Pointer));
      end;

      // Set the PackedToCount to reflect the number of items in the list
      // that have now been packed.
      Inc(PackedCount, EndIndex - StartIndex + 1);

      // Reset StartIndex to the element following EndIndex
      StartIndex := EndIndex + 1;
    end;
  until StartIndex >= Count;
  Result := PackedCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,538; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

end.
