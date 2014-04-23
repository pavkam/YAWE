{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Hash Sets
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright JEDI Team
  @Author JEDI Team
  @Changes Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Bfg.Containers.HashSets;

interface

uses
  Bfg.Containers.Interfaces{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

type
  PStrSetBucket = ^TStrSetBucket;
  TStrSetBucket = record
    Count: Integer;
    Keys: array of string;
  end;

  PIntSetBucket = ^TIntSetBucket;
  TIntSetBucket = record
    Count: Integer;
    Keys: array of Integer;
  end;

  PPtrSetBucket = ^TPtrSetBucket;
  TPtrSetBucket = record
    Count: Integer;
    Keys: array of Pointer;
  end;

  PSetBucket = ^TSetBucket;
  TSetBucket = record
    Count: Integer;
    Keys: array of TObject;
  end;

  TStrSetBucketArray = array of TStrSetBucket;
  TIntSetBucketArray = array of TIntSetBucket;
  TPtrSetBucketArray = array of TPtrSetBucket;
  TSetBucketArray = array of TSetBucket;

  TStrHashSet = class(TAbstractContainer, IStrCollection, ICloneable)
    private
      FCapacity: Integer;
      FCount: Integer;
      FBuckets: TStrSetBucketArray;
      FStrCompareProc: function(const S1, S2: string): Boolean;
      FStrHashProc: function(const Key: string; Capacity: Longword): Longword;
    protected
      procedure GrowEntries(BucketIndex: Integer);
      function GetBucket(Index: Integer): PStrSetBucket;
    public
      { IStrCollection }
      function Add(const AString: string): Boolean;
      procedure AddAll(const ACollection: IStrCollection);
      procedure Clear;
      function Contains(const AString: string): Boolean;
      function ContainsAll(const ACollection: IStrCollection): Boolean;
      function Equals(const ACollection: IStrCollection): Boolean;
      function First: IStrIterator;
      function IsEmpty: Boolean;
      function Last: IStrIterator;
      function Remove(const AString: string): Boolean;
      procedure RemoveAll(const ACollection: IStrCollection);
      procedure RetainAll(const ACollection: IStrCollection);
      function Size: Integer;
      procedure SetCaseSensitivity(AValue: Boolean);
      function GetCaseSensitivity: Boolean;
      property CaseSensitive: Boolean read GetCaseSensitivity write SetCaseSensitivity;
    public
      { ICloneable }
      function Clone: TObject;
    public
      constructor Create(ACaseSensitive: Boolean; ACapacity: Integer = 16);
      destructor Destroy; override;
      property Capacity: Integer read FCapacity;
      property Buckets[Index: Integer]: PStrSetBucket read GetBucket;
  end;

  TIntHashSet = class(TAbstractContainer, IIntCollection, ICloneable)
    private
      FCapacity: Integer;
      FCount: Integer;
      FBuckets: TIntSetBucketArray;
    protected
      procedure GrowEntries(BucketIndex: Integer);
      function GetBucket(Index: Integer): PIntSetBucket;
    public
      { IIntCollection }
      function Add(AInt: Integer): Boolean;
      procedure AddAll(const ACollection: IIntCollection);
      procedure Clear;
      function Contains(AInt: Integer): Boolean;
      function ContainsAll(const ACollection: IIntCollection): Boolean;
      function Equals(const ACollection: IIntCollection): Boolean;
      function First: IIntIterator;
      function IsEmpty: Boolean;
      function Last: IIntIterator;
      function Remove(AInt: Integer): Boolean;
      procedure RemoveAll(const ACollection: IIntCollection);
      procedure RetainAll(const ACollection: IIntCollection);
      function Size: Integer;
    public
      { ICloneable }
      function Clone: TObject;
    public
      constructor Create(ACapacity: Integer = 16);
      destructor Destroy; override;
      property Capacity: Integer read FCapacity;
      property Buckets[Index: Integer]: PIntSetBucket read GetBucket;
  end;

  TPtrHashSet = class(TAbstractContainer, IPtrCollection, ICloneable)
    private
      FCapacity: Integer;
      FCount: Integer;
      FBuckets: TPtrSetBucketArray;
    protected
      procedure GrowEntries(BucketIndex: Integer);
      function GetBucket(Index: Integer): PPtrSetBucket;
    public
      { IPtrCollection }
      function Add(APtr: Pointer): Boolean;
      procedure AddAll(const ACollection: IPtrCollection);
      procedure Clear;
      function Contains(APtr: Pointer): Boolean;
      function ContainsAll(const ACollection: IPtrCollection): Boolean;
      function Equals(const ACollection: IPtrCollection): Boolean;
      function First: IPtrIterator;
      function IsEmpty: Boolean;
      function Last: IPtrIterator;
      function Remove(APtr: Pointer): Boolean;
      procedure RemoveAll(const ACollection: IPtrCollection);
      procedure RetainAll(const ACollection: IPtrCollection);
      function Size: Integer;
    public
      { ICloneable }
      function Clone: TObject;
    public
      constructor Create(ACapacity: Integer = 16);
      destructor Destroy; override;
      property Capacity: Integer read FCapacity;
      property Buckets[Index: Integer]: PPtrSetBucket read GetBucket;
  end;

  THashSet = class(TAbstractContainer, ICollection, ICloneable)
    private
      FCapacity: Integer;
      FCount: Integer;
      FBuckets: TSetBucketArray;
      FOwnsObjects: Boolean;
    protected
      procedure FreeObject(var AObject: TObject);
      procedure GrowEntries(BucketIndex: Integer);
      function GetBucket(Index: Integer): PSetBucket;
    public
      { ICollection }
      function Add(AObject: TObject): Boolean;
      procedure AddAll(const ACollection: ICollection);
      procedure Clear;
      function Contains(AObject: TObject): Boolean;
      function ContainsAll(const ACollection: ICollection): Boolean;
      function Equals(const ACollection: ICollection): Boolean;
      function First: IIterator;
      function IsEmpty: Boolean;
      function Last: IIterator;
      function Remove(AObject: TObject): Boolean;
      procedure RemoveAll(const ACollection: ICollection);
      procedure RetainAll(const ACollection: ICollection);
      function Size: Integer;
    public
      { ICloneable }
      function Clone: TObject;
    public
      constructor Create(AOwnsObjects: Boolean; ACapacity: Integer = 16);
      destructor Destroy; override;
      property Capacity: Integer read FCapacity;
      property Buckets[Index: Integer]: PSetBucket read GetBucket;
      property OwnsObjects: Boolean read FOwnsObjects;
  end;

implementation

uses
  Bfg.Utils;

{$REGION 'Iterators'}
type
  TStrHashSetItr = class(TAbstractContainer, IStrIterator)
    private
      FCursorX: Integer;
      FCursorY: Integer;
      FFound: Integer;
      FCapacity: Integer;
      FData: TStrHashSet;
      FSize: Integer;
    protected
    { IStrIterator }
      function GetString: string;
      function HasNext: Boolean;
      function HasPrevious: Boolean;
      function Next: string;
      function Previous: string;
    public
      constructor Create(ASet: TStrHashSet);
  end;

  TIntHashSetItr = class(TAbstractContainer, IIntIterator)
    private
      FCursorX: Integer;
      FCursorY: Integer;
      FFound: Integer;
      FCapacity: Integer;
      FData: TIntHashSet;
      FSize: Integer;
    protected
    { IIntIterator }
      function GetInt: Integer;
      function HasNext: Boolean;
      function HasPrevious: Boolean;
      function Next: Integer;
      function Previous: Integer;
    public
      constructor Create(ASet: TIntHashSet);
  end;

  TPtrHashSetItr = class(TAbstractContainer, IPtrIterator)
    private
      FCursorX: Integer;
      FCursorY: Integer;
      FFound: Integer;
      FCapacity: Integer;
      FData: TPtrHashSet;
      FSize: Integer;
    protected
    { IPtrIterator }
      function GetPtr: Pointer;
      function HasNext: Boolean;
      function HasPrevious: Boolean;
      function Next: Pointer;
      function Previous: Pointer;
    public
      constructor Create(ASet: TPtrHashSet);
  end;

  THashSetItr = class(TAbstractContainer, IIterator)
    private
      FCursorX: Integer;
      FCursorY: Integer;
      FFound: Integer;
      FCapacity: Integer;
      FData: THashSet;
      FSize: Integer;
    protected
    { IIterator }
      function GetObject: TObject;
      function HasNext: Boolean;
      function HasPrevious: Boolean;
      function Next: TObject;
      function Previous: TObject;
    public
      constructor Create(ASet: THashSet);
  end;

{ TStrHashSetItr }

constructor TStrHashSetItr.Create(ASet: TStrHashSet);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1953 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FData := ASet;
  FSize := ASet.FCount;
  FCapacity := ASet.FCapacity;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1953; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashSetItr.GetString: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1954 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FData.FBuckets[FCursorX].Keys[FCursorY];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1954; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashSetItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1955 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FFound <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1955; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashSetItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1956 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FFound <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1956; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashSetItr.Next: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1957 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  repeat
    if FData.FBuckets[FCursorX].Count <> 0 then
    begin
      Result := FData.FBuckets[FCursorX].Keys[FCursorY];
      Inc(FFound);
      Inc(FCursorY);
      if FCursorY = FData.FBuckets[FCursorX].Count then
      begin
        Inc(FCursorX);
        if FCursorX < FCapacity then
        begin
          FCursorY := 0;
        end;
      end;
      Exit;
    end;
    Inc(FCursorX);
    if FCursorX = FCapacity then Break;
    FCursorY := 0;
  until False;
  Result := '';
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1957; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashSetItr.Previous: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1958 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  repeat
    if FCursorY > -1 then
    begin
      Result := FData.FBuckets[FCursorX].Keys[FCursorY];
      Inc(FFound);
      Dec(FCursorY);
      if FCursorY = -1 then
      begin
        Dec(FCursorX);
        if FCursorX > -1 then
        begin
          FCursorY := FData.FBuckets[FCursorX].Count - 1;
        end;
      end;
      Exit;
    end;
    Dec(FCursorX);
    if FCursorX = -1 then Break;
    FCursorY := FData.FBuckets[FCursorX].Count -1;
  until False;
  Result := '';
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1958; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TIntHashSetItr }

constructor TIntHashSetItr.Create(ASet: TIntHashSet);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1959 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FData := ASet;
  FSize := ASet.FCount;
  FCapacity := ASet.FCapacity;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1959; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashSetItr.GetInt: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1960 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FData.FBuckets[FCursorX].Keys[FCursorY];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1960; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashSetItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1961 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FFound <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1961; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashSetItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1962 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FFound <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1962; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashSetItr.Next: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1963 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  repeat
    if FData.FBuckets[FCursorX].Count <> 0 then
    begin
      Result := FData.FBuckets[FCursorX].Keys[FCursorY];
      Inc(FFound);
      Inc(FCursorY);
      if FCursorY = FData.FBuckets[FCursorX].Count then
      begin
        Inc(FCursorX);
        if FCursorX < FCapacity then
        begin
          FCursorY := 0;
        end;
      end;
      Exit;
    end;
    Inc(FCursorX);
    if FCursorX = FCapacity then Break;
    FCursorY := 0;
  until False;
  Result := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1963; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashSetItr.Previous: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1964 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  repeat
    if FCursorY > -1 then
    begin
      Result := FData.FBuckets[FCursorX].Keys[FCursorY];
      Inc(FFound);
      Dec(FCursorY);
      if FCursorY = -1 then
      begin
        Dec(FCursorX);
        if FCursorX > -1 then
        begin
          FCursorY := FData.FBuckets[FCursorX].Count - 1;
        end;
      end;
      Exit;
    end;
    Dec(FCursorX);
    if FCursorX = -1 then Break;
    FCursorY := FData.FBuckets[FCursorX].Count -1;
  until False;
  Result := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1964; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TPtrHashSetItr }

constructor TPtrHashSetItr.Create(ASet: TPtrHashSet);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1965 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FData := ASet;
  FSize := ASet.FCount;
  FCapacity := ASet.FCapacity;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1965; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrHashSetItr.GetPtr: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1966 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FData.FBuckets[FCursorX].Keys[FCursorY];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1966; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrHashSetItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1967 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FFound <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1967; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrHashSetItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1968 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FFound <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1968; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrHashSetItr.Next: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1969 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  repeat
    if FData.FBuckets[FCursorX].Count <> 0 then
    begin
      Result := FData.FBuckets[FCursorX].Keys[FCursorY];
      Inc(FFound);
      Inc(FCursorY);
      if FCursorY = FData.FBuckets[FCursorX].Count then
      begin
        Inc(FCursorX);
        if FCursorX < FCapacity then
        begin
          FCursorY := 0;
        end;
      end;
      Exit;
    end;
    Inc(FCursorX);
    if FCursorX = FCapacity then Break;
    FCursorY := 0;
  until False;
  Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1969; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrHashSetItr.Previous: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1970 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  repeat
    if FCursorY > -1 then
    begin
      Result := FData.FBuckets[FCursorX].Keys[FCursorY];
      Inc(FFound);
      Dec(FCursorY);
      if FCursorY = -1 then
      begin
        Dec(FCursorX);
        if FCursorX > -1 then
        begin
          FCursorY := FData.FBuckets[FCursorX].Count - 1;
        end;
      end;
      Exit;
    end;
    Dec(FCursorX);
    if FCursorX = -1 then Break;
    FCursorY := FData.FBuckets[FCursorX].Count -1;
  until False;
  Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1970; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ THashSetItr }

constructor THashSetItr.Create(ASet: THashSet);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1971 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FData := ASet;
  FSize := ASet.FCount;
  FCapacity := ASet.FCapacity;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1971; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashSetItr.GetObject: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1972 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FData.FBuckets[FCursorX].Keys[FCursorY];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1972; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashSetItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1973 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FFound <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1973; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashSetItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1974 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FFound <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1974; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashSetItr.Next: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1975 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  repeat
    if FData.FBuckets[FCursorX].Count <> 0 then
    begin
      Result := FData.FBuckets[FCursorX].Keys[FCursorY];
      Inc(FFound);
      Inc(FCursorY);
      if FCursorY = FData.FBuckets[FCursorX].Count then
      begin
        Inc(FCursorX);
        if FCursorX < FCapacity then
        begin
          FCursorY := 0;
        end;
      end;
      Exit;
    end;
    Inc(FCursorX);
    if FCursorX = FCapacity then Break;
    FCursorY := 0;
  until False;
  Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1975; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashSetItr.Previous: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1976 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  repeat
    if FCursorY > -1 then
    begin
      Result := FData.FBuckets[FCursorX].Keys[FCursorY];
      Inc(FFound);
      Dec(FCursorY);
      if FCursorY = -1 then
      begin
        Dec(FCursorX);
        if FCursorX > -1 then
        begin
          FCursorY := FData.FBuckets[FCursorX].Count - 1;
        end;
      end;
      Exit;
    end;
    Dec(FCursorX);
    if FCursorX = -1 then Break;
    FCursorY := FData.FBuckets[FCursorX].Count -1;
  until False;
  Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1976; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;
{$ENDREGION}

{ TStrHashSet }

function TStrHashSet.Add(const AString: string): Boolean;
var
  Index: Integer;
  Bucket: PStrSetBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1977 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AString = '' then
  begin
    Result := False;
    Exit;
  end;
  Index := FStrHashProc(AString, FCapacity);
  Bucket := @FBuckets[Index];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Keys[I], AString) then
    begin
      Result := False;
      Exit;
    end;
  end;
  if Bucket.Count = Length(Bucket.Keys) then GrowEntries(Index);
  begin
    Bucket.Keys[Bucket.Count] := AString;
  end;
  Inc(Bucket.Count);
  Inc(FCount);
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1977; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrHashSet.AddAll(const ACollection: IStrCollection);
var
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1978 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1978; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrHashSet.Clear;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1979 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCapacity -1 do
  begin
    for J := 0 to FBuckets[I].Count -1 do
    begin
      FBuckets[I].Keys[J] := '';
    end;
    FBuckets[I].Count := 0;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1979; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashSet.Clone: TObject;
var
  I, J: Integer;
  NewSet: TStrHashSet;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1980 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewSet := TStrHashSet.Create(CaseSensitive, FCapacity);
  for I := 0 to FCapacity -1 do
  begin
    SetLength(NewSet.FBuckets[I].Keys, FBuckets[I].Count);
    for J := 0 to FBuckets[I].Count -1 do
    begin
      NewSet.FBuckets[I].Keys[J] := FBuckets[I].Keys[J];
    end;
    NewSet.FBuckets[I].Count := FBuckets[I].Count;
  end;
  Result := NewSet;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1980; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashSet.Contains(const AString: string): Boolean;
var
  I: Integer;
  Bucket: PStrSetBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1981 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AString = '' then Exit;
  Bucket := @FBuckets[FStrHashProc(AString, FCapacity)];
  for I := 0 to Bucket.Count -1 do
  begin
    if FStrCompareProc(Bucket.Keys[I], AString) then
    begin
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1981; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashSet.ContainsAll(const ACollection: IStrCollection): Boolean;
var
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1982 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then Exit;
  Result := True;
  It := ACollection.First;
  while It.HasNext do
  begin
    if not Contains(It.Next) then
    begin
      Result := False;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1982; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TStrHashSet.Create(ACaseSensitive: Boolean; ACapacity: Integer = 16);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1983 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if ACaseSensitive then
  begin
    FStrCompareProc := StringsEqual;
    FStrHashProc := HashString;
  end else
  begin
    FStrCompareProc := StringsEqualNoCase;
    FStrHashProc := HashStringNoCase;
  end;
  if ACapacity > 0 then
  begin
    FCapacity := ACapacity;
  end;
  SetLength(FBuckets, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1983; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TStrHashSet.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1984 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1984; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashSet.Equals(const ACollection: IStrCollection): Boolean;
var
  I, J: Integer;
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1985 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then Exit;
  if FCount <> ACollection.Size then Exit;
  Result := True;
  It := ACollection.First;
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      if not FStrCompareProc(FBuckets[I].Keys[J], It.Next) then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1985; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashSet.First: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1986 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TStrHashSetItr.Create(Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1986; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashSet.GetBucket(Index: Integer): PStrSetBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1987 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1987; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashSet.GetCaseSensitivity: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1988 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FStrHashProc = @HashString;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1988; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrHashSet.GrowEntries(BucketIndex: Integer);
var
  Capacity: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1989 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Capacity := Length(FBuckets[BucketIndex].Keys);
  if Capacity > 64 then
  begin
    Inc(Capacity, Capacity shr 2);
  end else if Capacity > 0 then
  begin
    Capacity := Capacity shl 2;
  end else
  begin
    Capacity := 4;
  end;
  SetLength(FBuckets[BucketIndex].Keys, Capacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1989; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashSet.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1990 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1990; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashSet.Last: IStrIterator;
var
  It: TStrHashSetItr;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1991 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  It := TStrHashSetItr.Create(Self);
  It.FCursorX := FCapacity -1;
  if FCapacity <> 0 then
  begin
    It.FCursorY := FBuckets[FCapacity-1].Count -1;
  end;
  Result := It;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1991; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashSet.Remove(const AString: string): Boolean;
var
  Bucket: PStrSetBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1992 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AString = '' then Exit;
  Bucket := @FBuckets[FStrHashProc(AString, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Keys[I], AString) then
    begin
      Bucket.Keys[I] := '';
      if I < Bucket.Count -1 then
      begin
        Bucket.Keys[I] := Bucket.Keys[Bucket.Count - 1];
      end;
      Dec(Bucket.Count);
      Dec(FCount);
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1992; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrHashSet.RemoveAll(const ACollection: IStrCollection);
var
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1993 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
    Remove(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1993; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrHashSet.RetainAll(const ACollection: IStrCollection);
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1994 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  for I := 0 to FCapacity -1 do
  begin
    for J := 0 to FBuckets[I].Count -1 do
    begin
      if not ACollection.Contains(FBuckets[I].Keys[J]) then
        Remove(FBuckets[I].Keys[J]);
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1994; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrHashSet.SetCaseSensitivity(AValue: Boolean);
const
  CmpTable: array[Boolean] of Pointer = (
    @StringsEqualNoCase,
    @StringsEqual
  );
  HashTable: array[Boolean] of Pointer = (
    @HashStringNoCase,
    @HashString
  );
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1995 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if CaseSensitive xor AValue then
  begin
    FStrCompareProc := CmpTable[AValue];
    FStrHashProc := HashTable[AValue];
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1995; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashSet.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1996 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1996; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TIntHashSet }

function TIntHashSet.Add(AInt: Integer): Boolean;
var
  Index: Integer;
  Bucket: PIntSetBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1997 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Index := HashLongModulo(AInt, FCapacity);
  Bucket := @FBuckets[Index];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Keys[I] = AInt then
    begin
      Result := False;
      Exit;
    end;
  end;
  if Bucket.Count = Length(Bucket.Keys) then GrowEntries(Index);
  begin
    Bucket.Keys[Bucket.Count] := AInt;
  end;
  Inc(Bucket.Count);
  Inc(FCount);
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1997; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntHashSet.AddAll(const ACollection: IIntCollection);
var
  It: IIntIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1998 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1998; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntHashSet.Clear;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1999 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCapacity -1 do
  begin
    for J := 0 to FBuckets[I].Count -1 do
    begin
      FBuckets[I].Keys[J] := 0;
    end;
    FBuckets[I].Count := 0;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1999; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashSet.Clone: TObject;
var
  I, J: Integer;
  NewSet: TIntHashSet;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2000 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewSet := TIntHashSet.Create(FCapacity);
  for I := 0 to FCapacity -1 do
  begin
    SetLength(NewSet.FBuckets[I].Keys, FBuckets[I].Count);
    for J := 0 to FBuckets[I].Count -1 do
    begin
      NewSet.FBuckets[I].Keys[J] := FBuckets[I].Keys[J];
    end;
    NewSet.FBuckets[I].Count := FBuckets[I].Count;
  end;
  Result := NewSet;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2000; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashSet.Contains(AInt: Integer): Boolean;
var
  I: Integer;
  Bucket: PIntSetBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2001 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  Bucket := @FBuckets[HashLongModulo(AInt, FCapacity)];
  for I := 0 to Bucket.Count -1 do
  begin
    if Bucket.Keys[I] = AInt then
    begin
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2001; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashSet.ContainsAll(const ACollection: IIntCollection): Boolean;
var
  It: IIntIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2002 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then Exit;
  Result := True;
  It := ACollection.First;
  while It.HasNext do
  begin
    if not Contains(It.Next) then
    begin
      Result := False;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2002; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TIntHashSet.Create(ACapacity: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2003 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if ACapacity > 0 then
  begin
    FCapacity := ACapacity;
  end;
  SetLength(FBuckets, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2003; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TIntHashSet.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2004 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2004; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashSet.Equals(const ACollection: IIntCollection): Boolean;
var
  I, J: Integer;
  It: IIntIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2005 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then Exit;
  if FCount <> ACollection.Size then Exit;
  Result := True;
  It := ACollection.First;
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      if not FBuckets[I].Keys[J] = It.Next then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2005; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashSet.First: IIntIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2006 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TIntHashSetItr.Create(Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2006; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashSet.GetBucket(Index: Integer): PIntSetBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2007 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[Index]
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2007; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntHashSet.GrowEntries(BucketIndex: Integer);
var
  Capacity: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2008 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Capacity := Length(FBuckets[BucketIndex].Keys);
  if Capacity > 64 then
  begin
    Inc(Capacity, Capacity shr 2);
  end else if Capacity > 0 then
  begin
    Capacity := Capacity shl 2;
  end else
  begin
    Capacity := 4;
  end;
  SetLength(FBuckets[BucketIndex].Keys, Capacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2008; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashSet.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2009 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2009; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashSet.Last: IIntIterator;
var
  It: TIntHashSetItr;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2010 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  It := TIntHashSetItr.Create(Self);
  It.FCursorX := FCapacity -1;
  if FCapacity <> 0 then
  begin
    It.FCursorY := FBuckets[FCapacity-1].Count -1;
  end;
  Result := It;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2010; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashSet.Remove(AInt: Integer): Boolean;
var
  Bucket: PIntSetBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2011 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  Bucket := @FBuckets[HashLongModulo(AInt, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Keys[I] = AInt then
    begin
      Bucket.Keys[I] := 0;
      if I < Bucket.Count -1 then
      begin
        Bucket.Keys[I] := Bucket.Keys[Bucket.Count - 1];
      end;
      Dec(Bucket.Count);
      Dec(FCount);
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2011; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntHashSet.RemoveAll(const ACollection: IIntCollection);
var
  It: IIntIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2012 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
    Remove(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2012; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntHashSet.RetainAll(const ACollection: IIntCollection);
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2013 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  for I := 0 to FCapacity -1 do
  begin
    for J := 0 to FBuckets[I].Count -1 do
    begin
      if not ACollection.Contains(FBuckets[I].Keys[J]) then
        Remove(FBuckets[I].Keys[J]);
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2013; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashSet.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2014 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2014; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TPtrHashSet }

function TPtrHashSet.Add(APtr: Pointer): Boolean;
var
  Index: Integer;
  Bucket: PPtrSetBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2015 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Index := HashLongModulo(Integer(APtr), FCapacity);
  Bucket := @FBuckets[Index];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Keys[I] = APtr then
    begin
      Result := False;
      Exit;
    end;
  end;
  if Bucket.Count = Length(Bucket.Keys) then GrowEntries(Index);
  begin
    Bucket.Keys[Bucket.Count] := APtr;
  end;
  Inc(Bucket.Count);
  Inc(FCount);
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2015; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrHashSet.AddAll(const ACollection: IPtrCollection);
var
  It: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2016 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2016; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrHashSet.Clear;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2017 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCapacity -1 do
  begin
    for J := 0 to FBuckets[I].Count -1 do
    begin
      FBuckets[I].Keys[J] := nil;
    end;
    FBuckets[I].Count := 0;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2017; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrHashSet.Clone: TObject;
var
  I, J: Integer;
  NewSet: TPtrHashSet;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2018 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewSet := TPtrHashSet.Create(FCapacity);
  for I := 0 to FCapacity -1 do
  begin
    SetLength(NewSet.FBuckets[I].Keys, FBuckets[I].Count);
    for J := 0 to FBuckets[I].Count -1 do
    begin
      NewSet.FBuckets[I].Keys[J] := FBuckets[I].Keys[J];
    end;
    NewSet.FBuckets[I].Count := FBuckets[I].Count;
  end;
  Result := NewSet;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2018; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrHashSet.Contains(APtr: Pointer): Boolean;
var
  I: Integer;
  Bucket: PPtrSetBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2019 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  Bucket := @FBuckets[HashLongModulo(Integer(APtr), FCapacity)];
  for I := 0 to Bucket.Count -1 do
  begin
    if Bucket.Keys[I] = APtr then
    begin
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2019; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrHashSet.ContainsAll(const ACollection: IPtrCollection): Boolean;
var
  It: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2020 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then Exit;
  Result := True;
  It := ACollection.First;
  while It.HasNext do
  begin
    if not Contains(It.Next) then
    begin
      Result := False;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2020; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TPtrHashSet.Create(ACapacity: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2021 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if ACapacity > 0 then
  begin
    FCapacity := ACapacity;
  end;
  SetLength(FBuckets, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2021; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TPtrHashSet.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2022 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2022; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrHashSet.Equals(const ACollection: IPtrCollection): Boolean;
var
  I, J: Integer;
  It: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2023 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then Exit;
  if FCount <> ACollection.Size then Exit;
  Result := True;
  It := ACollection.First;
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      if not (FBuckets[I].Keys[J] = It.Next) then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2023; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrHashSet.First: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2024 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TPtrHashSetItr.Create(Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2024; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrHashSet.GetBucket(Index: Integer): PPtrSetBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2025 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[Index]
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2025; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrHashSet.GrowEntries(BucketIndex: Integer);
var
  Capacity: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2026 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Capacity := Length(FBuckets[BucketIndex].Keys);
  if Capacity > 64 then
  begin
    Inc(Capacity, Capacity shr 2);
  end else if Capacity > 0 then
  begin
    Capacity := Capacity shl 2;
  end else
  begin
    Capacity := 4;
  end;
  SetLength(FBuckets[BucketIndex].Keys, Capacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2026; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrHashSet.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2027 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2027; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrHashSet.Last: IPtrIterator;
var
  It: TPtrHashSetItr;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2028 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  It := TPtrHashSetItr.Create(Self);
  It.FCursorX := FCapacity -1;
  if FCapacity <> 0 then
  begin
    It.FCursorY := FBuckets[FCapacity-1].Count -1;
  end;
  Result := It;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2028; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrHashSet.Remove(APtr: Pointer): Boolean;
var
  Bucket: PPtrSetBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2029 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  Bucket := @FBuckets[HashLongModulo(Integer(APtr), FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Keys[I] = APtr then
    begin
      Bucket.Keys[I] := nil;
      if I < Bucket.Count -1 then
      begin
        Bucket.Keys[I] := Bucket.Keys[Bucket.Count - 1];
      end;
      Dec(Bucket.Count);
      Dec(FCount);
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2029; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrHashSet.RemoveAll(const ACollection: IPtrCollection);
var
  It: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2030 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
    Remove(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2030; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrHashSet.RetainAll(const ACollection: IPtrCollection);
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2031 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  for I := 0 to FCapacity -1 do
  begin
    for J := 0 to FBuckets[I].Count -1 do
    begin
      if not ACollection.Contains(FBuckets[I].Keys[J]) then
        Remove(FBuckets[I].Keys[J]);
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2031; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrHashSet.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2032 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2032; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ THashSet }

function THashSet.Add(AObject: TObject): Boolean;
var
  Index: Integer;
  Bucket: PSetBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2033 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AObject = nil then
  begin
    Result := False;
    Exit;
  end;
  Index := HashLongModulo(Integer(AObject), FCapacity);
  Bucket := @FBuckets[Index];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Keys[I] = AObject then
    begin
      Result := False;
      Exit;
    end;
  end;
  if Bucket.Count = Length(Bucket.Keys) then GrowEntries(Index);
  begin
    Bucket.Keys[Bucket.Count] := AObject;
  end;
  Inc(Bucket.Count);
  Inc(FCount);
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2033; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashSet.AddAll(const ACollection: ICollection);
var
  It: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2034 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2034; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashSet.Clear;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2035 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCapacity -1 do
  begin
    for J := 0 to FBuckets[I].Count -1 do
    begin
      FreeObject(FBuckets[I].Keys[J]);
    end;
    FBuckets[I].Count := 0;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2035; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashSet.Clone: TObject;
var
  I, J: Integer;
  NewSet: THashSet;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2036 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewSet := THashSet.Create(False, FCapacity);
  for I := 0 to FCapacity -1 do
  begin
    SetLength(NewSet.FBuckets[I].Keys, FBuckets[I].Count);
    for J := 0 to FBuckets[I].Count -1 do
    begin
      NewSet.FBuckets[I].Keys[J] := FBuckets[I].Keys[J];
    end;
    NewSet.FBuckets[I].Count := FBuckets[I].Count;
  end;
  Result := NewSet;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2036; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashSet.Contains(AObject: TObject): Boolean;
var
  I: Integer;
  Bucket: PSetBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2037 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AObject = nil then Exit;
  Bucket := @FBuckets[HashLongModulo(Integer(AObject), FCapacity)];
  for I := 0 to Bucket.Count -1 do
  begin
    if Bucket.Keys[I] = AObject then
    begin
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2037; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashSet.ContainsAll(const ACollection: ICollection): Boolean;
var
  It: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2038 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := True;
  if ACollection = nil then Exit;
  Result := True;
  It := ACollection.First;
  while It.HasNext do
  begin
    if not Contains(It.Next) then
    begin
      Result := False;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2038; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor THashSet.Create(AOwnsObjects: Boolean; ACapacity: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2039 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if ACapacity > 0 then
  begin
    FCapacity := ACapacity;
  end;
  FOwnsObjects := AOwnsObjects;
  SetLength(FBuckets, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2039; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor THashSet.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2040 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2040; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashSet.Equals(const ACollection: ICollection): Boolean;
var
  I, J: Integer;
  It: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2041 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then Exit;
  if FCount <> ACollection.Size then Exit;
  Result := True;
  It := ACollection.First;
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      if not (FBuckets[I].Keys[J] <> It.Next) then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2041; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashSet.First: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2042 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := THashSetItr.Create(Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2042; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashSet.FreeObject(var AObject: TObject);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2043 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FOwnsObjects then AObject.Free;
  AObject := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2043; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashSet.GetBucket(Index: Integer): PSetBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2044 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2044; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashSet.GrowEntries(BucketIndex: Integer);
var
  Capacity: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2045 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Capacity := Length(FBuckets[BucketIndex].Keys);
  if Capacity > 64 then
  begin
    Inc(Capacity, Capacity shr 2);
  end else if Capacity > 0 then
  begin
    Capacity := Capacity shl 2;
  end else
  begin
    Capacity := 4;
  end;
  SetLength(FBuckets[BucketIndex].Keys, Capacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2045; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashSet.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2046 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2046; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashSet.Last: IIterator;
var
  It: THashSetItr;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2047 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  It := THashSetItr.Create(Self);
  It.FCursorX := FCapacity -1;
  if FCapacity <> 0 then
  begin
    It.FCursorY := FBuckets[FCapacity-1].Count -1;
  end;
  Result := It;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2047; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashSet.Remove(AObject: TObject): Boolean;
var
  Bucket: PSetBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2048 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AObject = nil then Exit;
  Bucket := @FBuckets[HashLongModulo(Integer(AObject), FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Keys[I] = AObject then
    begin
      FreeObject(Bucket.Keys[I]);
      if I < Bucket.Count -1 then
      begin
        Bucket.Keys[I] := Bucket.Keys[Bucket.Count - 1];
      end;
      Dec(Bucket.Count);
      Dec(FCount);
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2048; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashSet.RemoveAll(const ACollection: ICollection);
var
  It: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2049 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
    Remove(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2049; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashSet.RetainAll(const ACollection: ICollection);
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2050 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  for I := 0 to FCapacity -1 do
  begin
    for J := 0 to FBuckets[I].Count -1 do
    begin
      if not ACollection.Contains(FBuckets[I].Keys[J]) then
        Remove(FBuckets[I].Keys[J]);
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2050; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashSet.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2051 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2051; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

end.
