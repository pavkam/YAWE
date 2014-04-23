{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Sorted Maps
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
  @Changes Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Bfg.Containers.SortedMap;

interface

uses
  Bfg.Utils,
  Bfg.Containers.Interfaces,
  Bfg.Containers.ArrayList,
  Bfg.Containers.Sets{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

type
  PStrEntry = ^TStrEntry;
  TStrEntry = record
    Key: string;
    Value: TObject;
  end;

  PStrStrEntry = ^TStrStrEntry;
  TStrStrEntry = record
    Key: string;
    Value: string;
  end;

  PStrIntEntry = ^TStrIntEntry;
  TStrIntEntry = record
    Key: string;
    Value: Integer;
  end;

  PStrPtrEntry = ^TStrPtrEntry;
  TStrPtrEntry = record
    Key: string;
    Value: Pointer;
  end;

  PStrIntfEntry = ^TStrIntfEntry;
  TStrIntfEntry = record
    Key: string;
    Value: IInterface;
  end;

  PIntEntry = ^TIntEntry;
  TIntEntry = record
    Key: Integer;
    Value: TObject;
  end;

  PIntIntEntry = ^TIntIntEntry;
  TIntIntEntry = record
    Key: Integer;
    Value: Integer;
  end;

  PIntPtrEntry = ^TIntPtrEntry;
  TIntPtrEntry = record
    Key: Integer;
    Value: Pointer;
  end;

  PPtrPtrEntry = ^TPtrPtrEntry;
  TPtrPtrEntry = record
    Key: Pointer;
    Value: Pointer;
  end;

  PEntry = ^TEntry;
  TEntry = record
    Key: TObject;
    Value: TObject;
  end;

  PIntfIntfEntry = ^TIntfIntfEntry;
  TIntfIntfEntry = record
    Key: IInterface;
    Value: IInterface;
  end;

  TStrEntryArray = array of TStrEntry;
  TStrStrEntryArray = array of TStrStrEntry;
  TStrIntEntryArray = array of TStrIntEntry;
  TStrPtrEntryArray = array of TStrPtrEntry;
  TStrIntfEntryArray = array of TStrIntfEntry;
  TIntEntryArray = array of TIntEntry;
  TIntIntEntryArray = array of TIntIntEntry;
  TIntPtrEntryArray = array of TIntPtrEntry;
  TPtrPtrEntryArray = array of TPtrPtrEntry;
  TEntryArray = array of TEntry;
  TIntfIntfEntryArray = array of TIntfIntfEntry;

  TStrSortedMap = class(TAbstractContainer, IStrMap, ICloneable)
    private
      FCapacity: Integer;
      FCount: Integer;
      FEntries: TStrEntryArray;
      FIndices: TIntegerDynArray;
      FStrCompareProc: function(const S1, S2: string): Integer;
      FOwnsObjects: Boolean;

      function GetValueIndexed(Index: Integer): TObject;
      function GetKeyIndexed(Index: Integer): string;
      procedure SetValueIndexed(Index: Integer; Value: TObject);
      function LookupIndex(const Key: string): Integer; inline;
      function LookupIndexNew(const Key: string): Integer; inline;
      function MatchKey(P1, P2: Pointer): Integer;
    protected
      procedure Grow;
      function FreeObject(AObject: TObject): Boolean;
      function GetCaseSensitivity: Boolean;
    public
      { IStrMap }
      procedure Clear;
      function ContainsKey(const Key: string): Boolean;
      function ContainsValue(Value: TObject): Boolean;
      function Equals(const AMap: IStrMap): Boolean;
      function GetValue(const Key: string): TObject;
      function IsEmpty: Boolean;
      function KeySet: IStrIterator;
      procedure PutAll(const AMap: IStrMap);
      procedure PutValue(const Key: string; Value: TObject);
      function Remove(const Key: string): TObject;
      function Size: Integer;
      function Values: IIterator;
      property CaseSensitive: Boolean read GetCaseSensitivity;
    public
      { ICloneable }
      function Clone: TObject;
    public
      constructor Create(ACaseSensitive: Boolean; AOwnsObjects: Boolean = True);
      destructor Destroy; override;
      property MapValues[const Index: string]: TObject read GetValue write PutValue; default;
      property Capacity: Integer read FCapacity;
      property ValuesByIndex[Index: Integer]: TObject read GetValueIndexed write SetValueIndexed;
      property KeysByIndex[Index: Integer]: string read GetKeyIndexed;
  end;

  TIntSortedMap = class(TAbstractContainer, IIntMap, ICloneable)
    private
      FCapacity: Integer;
      FCount: Integer;
      FEntries: TIntEntryArray;
      FIndices: TIntegerDynArray;
      FOwnsObjects: Boolean;

      function GetValueIndexed(Index: Integer): TObject;
      function GetKeyIndexed(Index: Integer): Integer;
      procedure SetValueIndexed(Index: Integer; Value: TObject);
      function LookupIndex(Key: Integer): Integer; inline;
      function LookupIndexNew(Key: Integer): Integer; inline;
      function MatchKey(P1, P2: Pointer): Integer;
    protected
      procedure Grow;
      function FreeObject(AObject: TObject): Boolean;
    public
      { IStrMap }
      procedure Clear;
      function ContainsKey(Key: Integer): Boolean;
      function ContainsValue(Value: TObject): Boolean;
      function Equals(const AMap: IIntMap): Boolean;
      function GetValue(Key: Integer): TObject;
      function IsEmpty: Boolean;
      function KeySet: IIntIterator;
      procedure PutAll(const AMap: IIntMap);
      procedure PutValue(Key: Integer; Value: TObject);
      function Remove(Key: Integer): TObject;
      function Size: Integer;
      function Values: IIterator;
    public
      { ICloneable }
      function Clone: TObject;
    public
      constructor Create(AOwnsObjects: Boolean = True);
      destructor Destroy; override;
      property MapValues[Index: Integer]: TObject read GetValue write PutValue; default;
      property Capacity: Integer read FCapacity;
      property ValuesByIndex[Index: Integer]: TObject read GetValueIndexed write SetValueIndexed;
      property KeysByIndex[Index: Integer]: Integer read GetKeyIndexed;
  end;

implementation

uses
  Bfg.Algorithm;

type
  TSortedIterator = class(TInterfacedObject)
    private
      FCount: Integer;
      FList: TIntegerDynArray;
      FPos: Integer;
    public
      function HasNext: Boolean;
      function HasPrevious: Boolean;
  end;

{ TSortedIterator }

function TSortedIterator.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2224 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FPos < FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2224; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TSortedIterator.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2225 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FPos > 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2225; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

type
  TStrSortedIterator = class(TSortedIterator)
    private
      FEntries: PStringArray;
    public
      constructor Create(Entries: PStringArray; Indices: TIntegerDynArray; Count: Integer);
  end;

{ TStrSortedIterator }

constructor TStrSortedIterator.Create(Entries: PStringArray; Indices: TIntegerDynArray; Count: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2226 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FCount := Count;
  FList := Indices;
  FEntries := Entries;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2226; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

type
  TStrKeySortedIterator = class(TStrSortedIterator, IStrIterator)
    public
      function GetString: string;
      function Next: string;
      function Previous: string;
  end;

{ TStrKeySortedIterator }

function TStrKeySortedIterator.GetString: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2227 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FEntries[FList[FPos]*2];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2227; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrKeySortedIterator.Next: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2228 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FEntries[FList[FPos]*2];
  Inc(FPos);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2228; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrKeySortedIterator.Previous: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2229 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Dec(FPos);
  Result := FEntries[FList[FPos]*2];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2229; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

type
  TStrValueSortedIterator = class(TStrSortedIterator, IStrIterator)
    public
      function GetString: string;
      function Next: string;
      function Previous: string;
  end;

{ TStrValueSortedIterator }

function TStrValueSortedIterator.GetString: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2230 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FEntries[1+FList[FPos]*2];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2230; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrValueSortedIterator.Next: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2231 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FEntries[1+FList[FPos]*2];
  Inc(FPos);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2231; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrValueSortedIterator.Previous: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2232 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Dec(FPos);
  Result := FEntries[1+FList[FPos]*2];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2232; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

type
  TObjSortedIterator = class(TSortedIterator)
    private
      FEntries: PObjectArray;
    public
      constructor Create(Entries: PObjectArray; Indices: TIntegerDynArray; Count: Integer);
  end;

{ TObjSortedIterator }

constructor TObjSortedIterator.Create(Entries: PObjectArray; Indices: TIntegerDynArray; Count: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2233 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FCount := Count;
  FList := Indices;
  FEntries := Entries;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2233; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

type
  TObjKeySortedIterator = class(TObjSortedIterator, IIterator)
    public
      function GetObject: TObject;
      function Next: TObject;
      function Previous: TObject;
  end;

{ TObjKeySortedIterator }

function TObjKeySortedIterator.GetObject: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2234 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FEntries[FList[FPos]*2];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2234; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TObjKeySortedIterator.Next: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2235 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FEntries[FList[FPos]*2];
  Inc(FPos);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2235; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TObjKeySortedIterator.Previous: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2236 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Dec(FPos);
  Result := FEntries[FList[FPos]*2];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2236; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

type
  TObjValueSortedIterator = class(TObjSortedIterator, IIterator)
    public
      function GetObject: TObject;
      function Next: TObject;
      function Previous: TObject;
  end;

{ TObjValueSortedIterator }

function TObjValueSortedIterator.GetObject: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2237 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FEntries[1+FList[FPos]*2];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2237; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TObjValueSortedIterator.Next: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2238 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FEntries[1+FList[FPos]*2];
  Inc(FPos);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2238; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TObjValueSortedIterator.Previous: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2239 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Dec(FPos);
  Result := FEntries[1+FList[FPos]*2];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2239; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TStrSortedMap }

constructor TStrSortedMap.Create(ACaseSensitive: Boolean; AOwnsObjects: Boolean);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2240 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;

  if ACaseSensitive then
  begin
    FStrCompareProc := StringsCompare;
  end else
  begin
    FStrCompareProc := StringsCompareNoCase;
  end;

  FCapacity := 16;
  Grow;
  FOwnsObjects := AOwnsObjects;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2240; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TStrSortedMap.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2241 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;

  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2241; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrSortedMap.Clear;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2242 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCount -1 do
  begin
    FEntries[I].Key := '';
    FreeObject(FEntries[I].Value);
    FEntries[I].Value := nil
  end;
  FillChar(FIndices[0], SizeOf(Integer) * FCount, -1);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2242; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrSortedMap.Clone: TObject;
var
  Map: TStrSortedMap;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2243 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Map := TStrSortedMap.Create(CaseSensitive, FOwnsObjects);
  Map.FCapacity := FCapacity;
  Map.FCount := FCount;
  SetLength(Map.FEntries, FCapacity);

  for I := 0 to FCount -1 do
  begin
    Map.FEntries[I].Key := FEntries[I].Key;
    Map.FEntries[I].Value := FEntries[I].Value;
  end;

  Result := Map;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2243; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrSortedMap.LookupIndex(const Key: string): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2244 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := BinarySearch(Pointer(Key), @FIndices[0], FCount, MatchKey);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2244; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrSortedMap.LookupIndexNew(const Key: string): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2245 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := BinarySearchLesser(Pointer(Key), @FIndices[0], FCount, MatchKey);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2245; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrSortedMap.MatchKey(P1, P2: Pointer): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2246 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FStrCompareProc(string(P1), FEntries[Integer(P2)].Key);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2246; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrSortedMap.ContainsKey(const Key: string): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2247 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := LookupIndex(Key) <> -1;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2247; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrSortedMap.ContainsValue(Value: TObject): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2248 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCount -1 do
  begin
    if FEntries[I].Value = Value then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2248; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrSortedMap.Equals(const AMap: IStrMap): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2249 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AMap = nil then Exit;
  if FCount <> AMap.Size then Exit;
  Result := True;
  for I := 0 to FCount - 1 do
  begin
    if AMap.ContainsKey(FEntries[I].Key) then
    begin
      if not (AMap.GetValue(FEntries[I].Key) = FEntries[I].Value) then
      begin
        Result := False;
        Exit;
      end;
    end else
    begin
      Result := False;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2249; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrSortedMap.FreeObject(AObject: TObject): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2250 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FOwnsObjects;
  if Result then AObject.Free;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2250; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrSortedMap.GetCaseSensitivity: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2251 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FStrCompareProc = @StringsCompare;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2251; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrSortedMap.GetKeyIndexed(Index: Integer): string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2252 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FEntries[FIndices[Index]].Key;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2252; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrSortedMap.GetValue(const Key: string): TObject;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2253 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  I := LookupIndex(Key);
  if I <> -1 then
  begin
    Result := FEntries[FIndices[I]].Value;
  end else Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2253; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrSortedMap.GetValueIndexed(Index: Integer): TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2254 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FEntries[FIndices[Index]].Value;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2254; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrSortedMap.Grow;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2255 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Inc(FCapacity, FCapacity shr 2);
  SetLength(FIndices, FCapacity);
  SetLength(FEntries, FCapacity);

  FillChar(FIndices[FCount], (FCapacity - FCount) * SizeOf(Integer), -1);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2255; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrSortedMap.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2256 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2256; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrSortedMap.KeySet: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2257 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TStrKeySortedIterator.Create(Pointer(FEntries), FIndices, FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2257; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrSortedMap.PutAll(const AMap: IStrMap);
var
  Itr: IStrIterator;
  Key: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2258 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Itr := AMap.KeySet;
  while Itr.HasNext do
  begin
    Key := Itr.Next;
    PutValue(Key, AMap.GetValue(Key));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2258; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrSortedMap.PutValue(const Key: string; Value: TObject);
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2259 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  I := LookupIndex(Key);
  if I <> -1 then
  begin
    FEntries[FIndices[I]].Value := Value;
  end else
  begin
    if FCount = FCapacity then Grow;
    I := LookupIndexNew(Key);
    Inc(I);
    if I <> FCount then
    begin
      Move(FIndices[I], FIndices[I+1], SizeOf(Integer) * (FCount - I));
    end;
    FEntries[FCount].Key := Key;
    FEntries[FCount].Value := Value;
    FIndices[I] := FCount;
    Inc(FCount);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2259; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrSortedMap.Remove(const Key: string): TObject;
var
  I: Integer;
  J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2260 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  I := LookupIndex(Key);
  if I <> -1 then
  begin
    J := FIndices[I];
    Result := FEntries[J].Value;
    if FreeObject(Result) then Result := nil;
    Dec(FCount);
    if I <> FCount then
    begin
      Move(FIndices[I+1], FIndices[I], SizeOf(Integer) * (FCount - I));
    end;
    FIndices[I] := -1;
    FEntries[J] := FEntries[FCount];
    FEntries[FCount].Key := '';
    FEntries[FCount].Value := nil;
  end else Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2260; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrSortedMap.SetValueIndexed(Index: Integer; Value: TObject);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2261 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FEntries[Index].Value := Value;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2261; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrSortedMap.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2262 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2262; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrSortedMap.Values: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2263 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TObjValueSortedIterator.Create(Pointer(FEntries), FIndices, FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2263; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TIntSortedMap }

constructor TIntSortedMap.Create(AOwnsObjects: Boolean);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2264 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;

  FCapacity := 16;
  Grow;
  FOwnsObjects := AOwnsObjects;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2264; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TIntSortedMap.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2265 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;

  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2265; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntSortedMap.Clear;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2266 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCount -1 do
  begin
    FEntries[I].Key := 0;
    FreeObject(FEntries[I].Value);
    FEntries[I].Value := nil
  end;
  FillChar(FIndices[0], SizeOf(Integer) * FCount, -1);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2266; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntSortedMap.Clone: TObject;
var
  Map: TIntSortedMap;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2267 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Map := TIntSortedMap.Create(FOwnsObjects);
  Map.FCapacity := FCapacity;
  Map.FCount := FCount;
  SetLength(Map.FEntries, FCapacity);

  for I := 0 to FCount -1 do
  begin
    Map.FEntries[I].Key := FEntries[I].Key;
    Map.FEntries[I].Value := FEntries[I].Value;
  end;

  Result := Map;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2267; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntSortedMap.ContainsKey(Key: Integer): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2268 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := LookupIndex(Key) <> -1;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2268; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntSortedMap.ContainsValue(Value: TObject): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2269 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCount -1 do
  begin
    if FEntries[I].Value = Value then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2269; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntSortedMap.Equals(const AMap: IIntMap): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2270 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AMap = nil then Exit;
  if FCount <> AMap.Size then Exit;
  Result := True;
  for I := 0 to FCount - 1 do
  begin
    if AMap.ContainsKey(FEntries[I].Key) then
    begin
      if not (AMap.GetValue(FEntries[I].Key) = FEntries[I].Value) then
      begin
        Result := False;
        Exit;
      end;
    end else
    begin
      Result := False;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2270; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntSortedMap.FreeObject(AObject: TObject): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2271 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FOwnsObjects;
  if Result then AObject.Free;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2271; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntSortedMap.GetKeyIndexed(Index: Integer): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2272 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FEntries[FIndices[Index]].Key;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2272; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntSortedMap.GetValue(Key: Integer): TObject;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2273 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  I := LookupIndex(Key);
  if I <> -1 then
  begin
    Result := FEntries[FIndices[I]].Value;
  end else Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2273; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntSortedMap.GetValueIndexed(Index: Integer): TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2274 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FEntries[FIndices[Index]].Value;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2274; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntSortedMap.Grow;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2275 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Inc(FCapacity, FCapacity shr 2);
  SetLength(FIndices, FCapacity);
  SetLength(FEntries, FCapacity);

  FillChar(FIndices[FCount], (FCapacity - FCount) * SizeOf(Integer), -1);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2275; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntSortedMap.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2276 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2276; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntSortedMap.KeySet: IIntIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2277 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}

{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2277; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntSortedMap.LookupIndex(Key: Integer): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2278 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := BinarySearch(Pointer(Key), @FIndices[0], FCount, MatchKey);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2278; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntSortedMap.LookupIndexNew(Key: Integer): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2279 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := BinarySearchLesser(Pointer(Key), @FIndices[0], FCount, MatchKey);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2279; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntSortedMap.MatchKey(P1, P2: Pointer): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2280 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := Integer(P1) - Integer(FEntries[Integer(P2)].Value);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2280; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntSortedMap.PutAll(const AMap: IIntMap);
var
  Itr: IIntIterator;
  Key: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2281 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Itr := AMap.KeySet;
  while Itr.HasNext do
  begin
    Key := Itr.Next;
    PutValue(Key, AMap.GetValue(Key));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2281; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntSortedMap.PutValue(Key: Integer; Value: TObject);
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2282 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  I := LookupIndex(Key);
  if I <> -1 then
  begin
    FEntries[FIndices[I]].Value := Value;
  end else
  begin
    if FCount = FCapacity then Grow;
    I := LookupIndexNew(Key);
    Inc(I);
    if I <> FCount then
    begin
      Move(FIndices[I], FIndices[I+1], SizeOf(Integer) * (FCount - I));
    end;
    FEntries[FCount].Key := Key;
    FEntries[FCount].Value := Value;
    FIndices[I] := FCount;
    Inc(FCount);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2282; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntSortedMap.Remove(Key: Integer): TObject;
var
  I: Integer;
  J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2283 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  I := LookupIndex(Key);
  if I <> -1 then
  begin
    J := FIndices[I];
    Result := FEntries[J].Value;
    if FreeObject(Result) then Result := nil;
    Dec(FCount);
    if I <> FCount then
    begin
      Move(FIndices[I+1], FIndices[I], SizeOf(Integer) * (FCount - I));
    end;
    FIndices[I] := -1;
    FEntries[J] := FEntries[FCount];
    FEntries[FCount].Key := 0;
    FEntries[FCount].Value := nil;
  end else Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2283; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntSortedMap.SetValueIndexed(Index: Integer; Value: TObject);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2284 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FEntries[Index].Value := Value;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2284; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntSortedMap.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2285 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2285; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntSortedMap.Values: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2286 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}

{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2286; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

end.
