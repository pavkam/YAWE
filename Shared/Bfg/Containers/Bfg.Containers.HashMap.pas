{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Hash Maps
  
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
unit Bfg.Containers.HashMap;

interface

uses
  Bfg.Containers.Interfaces,
  Bfg.Containers.ArrayList,
  Bfg.Containers.Sets{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

type
  TStrEntry = record
    Key: string;
    Value: TObject;
  end;

  TStrStrEntry = record
    Key: string;
    Value: string;
  end;

  TStrIntEntry = record
    Key: string;
    Value: Integer;
  end;

  TStrPtrEntry = record
    Key: string;
    Value: Pointer;
  end;

  TStrIntfEntry = record
    Key: string;
    Value: IInterface;
  end;

  TIntEntry = record
    Key: Integer;
    Value: TObject;
  end;

  TIntIntEntry = record
    Key: Integer;
    Value: Integer;
  end;

  TIntPtrEntry = record
    Key: Integer;
    Value: Pointer;
  end;

  TPtrPtrEntry = record
    Key: Pointer;
    Value: Pointer;
  end;

  TEntry = record
    Key: TObject;
    Value: TObject;
  end;

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

  PStrBucket = ^TStrBucket;
  TStrBucket = record
    Count: Integer;
    Entries: TStrEntryArray;
  end;

  PStrStrBucket = ^TStrStrBucket;
  TStrStrBucket = record
    Count: Integer;
    Entries: TStrStrEntryArray;
  end;

  PStrIntBucket = ^TStrIntBucket;
  TStrIntBucket = record
    Count: Integer;
    Entries: TStrIntEntryArray;
  end;

  PStrPtrBucket = ^TStrPtrBucket;
  TStrPtrBucket = record
    Count: Integer;
    Entries: TStrPtrEntryArray;
  end;

  PStrIntfBucket = ^TStrIntfBucket;
  TStrIntfBucket = record
    Count: Integer;
    Entries: TStrIntfEntryArray;
  end;

  PIntBucket = ^TIntBucket;
  TIntBucket = record
    Count: Integer;
    Entries: TIntEntryArray;
  end;

  PIntIntBucket = ^TIntIntBucket;
  TIntIntBucket = record
    Count: Integer;
    Entries: TIntIntEntryArray;
  end;

  PIntPtrBucket = ^TIntPtrBucket;
  TIntPtrBucket = record
    Count: Integer;
    Entries: TIntPtrEntryArray;
  end;

  PPtrPtrBucket = ^TPtrPtrBucket;
  TPtrPtrBucket = record
    Count: Integer;
    Entries: TPtrPtrEntryArray;
  end;

  PBucket = ^TBucket;
  TBucket = record
    Count: Integer;
    Entries: TEntryArray;
  end;

  PIntfIntfBucket = ^TIntfIntfBucket;
  TIntfIntfBucket = record
    Count: Integer;
    Entries: TIntfIntfEntryArray;
  end;

  TStrBucketArray = array of TStrBucket;
  TStrStrBucketArray = array of TStrStrBucket;
  TStrIntBucketArray = array of TStrIntBucket;
  TStrPtrBucketArray = array of TStrPtrBucket;
  TStrIntfBucketArray = array of TStrIntfBucket;
  TIntBucketArray = array of TIntBucket;
  TIntIntBucketArray = array of TIntIntBucket;
  TIntPtrBucketArray = array of TIntPtrBucket;
  TPtrPtrBucketArray = array of TPtrPtrBucket;
  TBucketArray = array of TBucket;
  TIntfIntfBucketArray = array of TIntfIntfBucket;

  TStrHashMap = class(TAbstractContainer, IStrMap, ICloneable)
    private
      FCapacity: Integer;
      FCount: Integer;
      FBuckets: TStrBucketArray;
      FOwnsObjects: Boolean;
      FStrCompareProc: function(const S1, S2: string): Boolean;
      FStrHashProc: function(const Key: string; Capacity: Longword): Longword;
    protected
      procedure GrowEntries(BucketIndex: Integer);
      function FreeObject(AObject: TObject): Boolean;
      function GetBucket(Index: Integer): PStrBucket;
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
      function GetBucketByKey(const Key: string): PStrBucket;
      property CaseSensitive: Boolean read GetCaseSensitivity;
    public
      { ICloneable }
      function Clone: TObject;
    public
      constructor Create(ACaseSensitive: Boolean; ACapacity: Integer = 16; AOwnsObjects: Boolean = True);
      destructor Destroy; override;
      property MapValues[const Index: string]: TObject read GetValue write PutValue; default;
      property Capacity: Integer read FCapacity;
      property Data[Index: Integer]: PStrBucket read GetBucket;
  end;

  TStrStrHashMap = class(TAbstractContainer, IStrStrMap, ICloneable)
    private
      FCapacity: Integer;
      FCount: Integer;
      FBuckets: TStrStrBucketArray;
      FStrCompareProc: function(const S1, S2: string): Boolean;
      FStrHashProc: function(const Key: string; Capacity: Longword): Longword;
    protected
      procedure GrowEntries(BucketIndex: Integer);
      function GetBucket(Index: Integer): PStrStrBucket;
      function GetCaseSensitivity: Boolean;
    public
      { IStrStrMap }
      procedure Clear;
      function ContainsKey(const Key: string): Boolean;
      function ContainsValue(const Value: string): Boolean;
      function Equals(const AMap: IStrStrMap): Boolean;
      function GetValue(const Key: string): string;
      function IsEmpty: Boolean;
      function KeySet: IStrIterator;
      procedure PutAll(const AMap: IStrStrMap);
      procedure PutValue(const Key, Value: string);
      function Remove(const Key: string): string;
      function Size: Integer;
      function Values: IStrIterator;
      function GetBucketByKey(const Key: string): PStrStrBucket;
      property CaseSensitive: Boolean read GetCaseSensitivity;
    public
      { ICloneable }
      function Clone: TObject;
    public
      constructor Create(ACaseSensitive: Boolean; ACapacity: Integer = 16);
      destructor Destroy; override;
      property MapValues[const Index: string]: string read GetValue write PutValue; default;
      property Capacity: Integer read FCapacity;
      property Data[Index: Integer]: PStrStrBucket read GetBucket;
  end;

  TStrIntHashMap = class(TAbstractContainer, IStrIntMap, ICloneable)
    private
      FCapacity: Integer;
      FCount: Integer;
      FBuckets: TStrIntBucketArray;
      FStrCompareProc: function(const S1, S2: string): Boolean;
      FStrHashProc: function(const Key: string; Capacity: Longword): Longword;
    protected
      procedure GrowEntries(BucketIndex: Integer);
      function GetBucket(Index: Integer): PStrIntBucket;
      function GetCaseSensitivity: Boolean;
    public
      { IStrIntMap }
      procedure Clear;
      function ContainsKey(const Key: string): Boolean;
      function ContainsValue(Value: Integer): Boolean;
      function Equals(const AMap: IStrIntMap): Boolean;
      function GetValue(const Key: string): Integer;
      function IsEmpty: Boolean;
      function KeySet: IStrIterator;
      procedure PutAll(const AMap: IStrIntMap);
      procedure PutValue(const Key: string; Value: Integer);
      function Remove(const Key: string): Integer;
      function Size: Integer;
      function Values: IIntIterator;
      function GetBucketByKey(const Key: string): PStrIntBucket;
      property CaseSensitive: Boolean read GetCaseSensitivity;
    public
      { ICloneable }
      function Clone: TObject;
    public
      constructor Create(ACaseSensitive: Boolean; ACapacity: Integer = 16);
      destructor Destroy; override;
      property MapValues[const Index: string]: Integer read GetValue write PutValue; default;
      property Capacity: Integer read FCapacity;
      property Data[Index: Integer]: PStrIntBucket read GetBucket;
  end;

  TStrPtrHashMap = class(TAbstractContainer, IStrPtrMap, ICloneable)
    private
      FCapacity: Integer;
      FCount: Integer;
      FBuckets: TStrPtrBucketArray;
      FStrCompareProc: function(const S1, S2: string): Boolean;
      FStrHashProc: function(const Key: string; Capacity: Longword): Longword;
    protected
      procedure GrowEntries(BucketIndex: Integer);
      function GetBucket(Index: Integer): PStrPtrBucket;
      function GetCaseSensitivity: Boolean;
    public
      { IStrPtrMap }
      procedure Clear;
      function ContainsKey(const Key: string): Boolean;
      function ContainsValue(Value: Pointer): Boolean;
      function Equals(const AMap: IStrPtrMap): Boolean;
      function GetValue(const Key: string): Pointer;
      function IsEmpty: Boolean;
      function KeySet: IStrIterator;
      procedure PutAll(const AMap: IStrPtrMap);
      procedure PutValue(const Key: string; Value: Pointer);
      function Remove(const Key: string): Pointer;
      function Size: Integer;
      function Values: IPtrIterator;
      function GetBucketByKey(const Key: string): PStrPtrBucket;
      property CaseSensitive: Boolean read GetCaseSensitivity;
    public
      { ICloneable }
      function Clone: TObject;
    public
      constructor Create(ACaseSensitive: Boolean; ACapacity: Integer = 16);
      destructor Destroy; override;
      property MapValues[const Index: string]: Pointer read GetValue write PutValue; default;
      property Capacity: Integer read FCapacity;
      property Data[Index: Integer]: PStrPtrBucket read GetBucket;
  end;

  TStrIntfHashMap = class(TAbstractContainer, IStrIntfMap, ICloneable)
    private
      FCapacity: Integer;
      FCount: Integer;
      FBuckets: TStrIntfBucketArray;
      FStrCompareProc: function(const S1, S2: string): Boolean;
      FStrHashProc: function(const Key: string; Capacity: Longword): Longword;
    protected
      procedure GrowEntries(BucketIndex: Integer);
      function GetBucket(Index: Integer): PStrIntfBucket;
      function GetCaseSensitivity: Boolean;
    public
      { IStrIntfMap }
      procedure Clear;
      function ContainsKey(const Key: string): Boolean;
      function ContainsValue(const Value: IInterface): Boolean;
      function Equals(const AMap: IStrIntfMap): Boolean;
      function GetValue(const Key: string): IInterface;
      function IsEmpty: Boolean;
      function KeySet: IStrIterator;
      procedure PutAll(const AMap: IStrIntfMap);
      procedure PutValue(const Key: string; const Value: IInterface);
      function Remove(const Key: string): IInterface;
      function Size: Integer;
      function Values: IIntfIterator;
      function GetBucketByKey(const Key: string): PStrIntfBucket;
      property CaseSensitive: Boolean read GetCaseSensitivity;
    public
      { ICloneable }
      function Clone: TObject;
    public
      constructor Create(ACaseSensitive: Boolean; ACapacity: Integer = 16);
      destructor Destroy; override;
      property MapValues[const Index: string]: IInterface read GetValue write PutValue; default;
      property Capacity: Integer read FCapacity;
      property Data[Index: Integer]: PStrIntfBucket read GetBucket;
  end;

  TIntHashMap = class(TAbstractContainer, IIntMap, ICloneable)
    private
      FCapacity: Integer;
      FCount: Integer;
      FBuckets: TIntBucketArray;
      FOwnsObjects: Boolean;
    protected
      procedure GrowEntries(BucketIndex: Integer);
      function FreeObject(AObject: TObject): Boolean;
      function GetBucket(Index: Integer): PIntBucket;
    public
      { IIntMap }
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
      function GetBucketByKey(Key: Integer): PIntBucket;
    public
      { ICloneable }
      function Clone: TObject;
    public
      constructor Create(ACapacity: Integer = 16; AOwnsObjects: boolean = true);
      destructor Destroy; override;
      function GetMemoryUsageInBytes: Longword;
      property MapValues[Index: Integer]: TObject read GetValue write PutValue; default;
      property Capacity: Integer read FCapacity;
      property Data[Index: Integer]: PIntBucket read GetBucket;
  end;

  TIntIntHashMap = class(TAbstractContainer, IIntIntMap, ICloneable)
    private
      FCapacity: Integer;
      FCount: Integer;
      FBuckets: TIntIntBucketArray;
    protected
      procedure GrowEntries(BucketIndex: Integer);
      function GetBucket(Index: Integer): PIntIntBucket;
    public
      { IIntIntMap }
      procedure Clear;
      function ContainsKey(Key: Integer): Boolean;
      function ContainsValue(Value: Integer): Boolean;
      function Equals(const AMap: IIntIntMap): Boolean;
      function GetValue(Key: Integer): Integer;
      function IsEmpty: Boolean;
      function KeySet: IIntIterator;
      procedure PutAll(const AMap: IIntIntMap);
      procedure PutValue(Key, Value: Integer);
      function Remove(Key: Integer): Integer;
      function Size: Integer;
      function Values: IIntIterator;
      function GetBucketByKey(Key: Integer): PIntIntBucket;
    public
      { ICloneable }
      function Clone: TObject;
    public
      constructor Create(ACapacity: Integer = 16);
      destructor Destroy; override;
      property MapValues[Index: Integer]: Integer read GetValue write PutValue; default;
      property Capacity: Integer read FCapacity;
      property Data[Index: Integer]: PIntIntBucket read GetBucket;
  end;

  TIntPtrHashMap = class(TAbstractContainer, IIntPtrMap, ICloneable)
    private
      FCapacity: Integer;
      FCount: Integer;
      FBuckets: TIntPtrBucketArray;
    protected
      procedure GrowEntries(BucketIndex: Integer);
      function GetBucket(Index: Integer): PIntPtrBucket;
    public
      { IIntPtrMap }
      procedure Clear;
      function ContainsKey(Key: Integer): Boolean;
      function ContainsValue(Value: Pointer): Boolean;
      function Equals(const AMap: IIntPtrMap): Boolean;
      function GetValue(Key: Integer): Pointer;
      function IsEmpty: Boolean;
      function KeySet: IIntIterator;
      procedure PutAll(const AMap: IIntPtrMap);
      procedure PutValue(Key: Integer; Value: Pointer);
      function Remove(Key: Integer): Pointer;
      function Size: Integer;
      function Values: IPtrIterator;
      function GetBucketByKey(Key: Integer): PIntPtrBucket;
    public
      { ICloneable }
      function Clone: TObject;
    public
      constructor Create(ACapacity: Integer = 16);
      destructor Destroy; override;
      property MapValues[Index: Integer]: Pointer read GetValue write PutValue; default;
      property Capacity: Integer read FCapacity;
      property Data[Index: Integer]: PIntPtrBucket read GetBucket;
  end;

  TPtrPtrHashMap = class(TAbstractContainer, IPtrPtrMap, ICloneable)
    private
      FCapacity: Integer;
      FCount: Integer;
      FBuckets: TPtrPtrBucketArray;
    protected
      procedure GrowEntries(BucketIndex: Integer);
      function GetBucket(Index: Integer): PPtrPtrBucket;
    public
      { IPtrPtrMap }
      procedure Clear;
      function ContainsKey(Key: Pointer): Boolean;
      function ContainsValue(Value: Pointer): Boolean;
      function Equals(const AMap: IPtrPtrMap): Boolean;
      function GetValue(Key: Pointer): Pointer;
      function IsEmpty: Boolean;
      function KeySet: IPtrIterator;
      procedure PutAll(const AMap: IPtrPtrMap);
      procedure PutValue(Key, Value: Pointer);
      function Remove(Key: Pointer): Pointer;
      function Size: Integer;
      function Values: IPtrIterator;
      function GetBucketByKey(Key: Pointer): PPtrPtrBucket;
    public
      { ICloneable }
      function Clone: TObject;
    public
      constructor Create(ACapacity: Integer = 16);
      destructor Destroy; override;
      property MapValues[Index: Pointer]: Pointer read GetValue write PutValue; default;
      property Capacity: Integer read FCapacity;
      property Data[Index: Integer]: PPtrPtrBucket read GetBucket;
  end;

  TIntfIntfHashMap = class(TAbstractContainer, IIntfIntfMap, ICloneable)
    private
      FCapacity: Integer;
      FCount: Integer;
      FBuckets: TIntfIntfBucketArray;
    protected
      procedure GrowEntries(BucketIndex: Integer);
      function GetBucket(Index: Integer): PIntfIntfBucket;
    public
      { IIntfIntfMap }
      procedure Clear;
      function ContainsKey(const Key: IInterface): Boolean;
      function ContainsValue(const Value: IInterface): Boolean;
      function Equals(const AMap: IIntfIntfMap): Boolean;
      function GetValue(const Key: IInterface): IInterface;
      function IsEmpty: Boolean;
      function KeySet: IIntfIterator;
      procedure PutAll(const AMap: IIntfIntfMap);
      procedure PutValue(const Key, Value: IInterface);
      function Remove(const Key: IInterface): IInterface;
      function Size: Integer;
      function Values: IIntfIterator;
      function GetBucketByKey(const Key: IInterface): PIntfIntfBucket;
    public
      { ICloneable }
      function Clone: TObject;
    public
      constructor Create(ACapacity: Integer = 16);
      destructor Destroy; override;
      property MapValues[const Index: IInterface]: IInterface read GetValue write PutValue; default;
      property Capacity: Integer read FCapacity;
      property Data[Index: Integer]: PIntfIntfBucket read GetBucket;
  end;

  THashMap = class(TAbstractContainer, IMap, ICloneable)
    private
      FCapacity: Integer;
      FCount: Integer;
      FBuckets: TBucketArray;
      FOwnsObjects: Boolean;
    protected
      procedure GrowEntries(BucketIndex: Integer);
      function FreeObject(AObject: TObject): Boolean;
      function GetBucket(Index: Integer): PBucket;
    public
      { IMap }
      procedure Clear;
      function ContainsKey(Key: TObject): Boolean;
      function ContainsValue(Value: TObject): Boolean;
      function Equals(const AMap: IMap): Boolean;
      function GetValue(Key: TObject): TObject;
      function IsEmpty: Boolean;
      function KeySet: IIterator;
      procedure PutAll(const AMap: IMap);
      procedure PutValue(Key, Value: TObject);
      function Remove(Key: TObject): TObject;
      function Size: Integer;
      function Values: IIterator;
      function GetBucketByKey(Key: TObject): PBucket;
    public
      { ICloneable }
      function Clone: TObject;
    public
      constructor Create(ACapacity: Integer = 16; AOwnsObjects: Boolean = True);
      destructor Destroy; override;
      property MapValues[Index: TObject]: TObject read GetValue write PutValue; default;
      property Capacity: Integer read FCapacity;
      property Data[Index: Integer]: PBucket read GetBucket;
  end;

implementation

uses
  Bfg.Utils;

{$REGION 'Iterators'}
type
  TItrResultType = (irtValue, irtKey);

  TMultiItr = class(TAbstractContainer, IIterator, IPtrIterator, IIntIterator,
    IStrIterator, IIntfIterator)
    private
      FCursorX: Integer;
      FCursorY: Integer;
      FData: TAbstractContainer;
      FCapacity: Integer;
      FFound: Integer;
      FSize: Integer;
      FResType: TItrResultType;
    protected
      function GetString: string;
      function HasNextStr: Boolean;
      function IStrIterator.HasNext = HasNextStr;
      function HasPreviousStr: Boolean;
      function IStrIterator.HasPrevious = HasPreviousStr;
      function NextStr: string;
      function IStrIterator.Next = NextStr;
      function PreviousStr: string;
      function IStrIterator.Previous = PreviousStr;

      function GetInt: Integer;
      function HasNextInt: Boolean;
      function IIntIterator.HasNext = HasNextInt;
      function HasPreviousInt: Boolean;
      function IIntIterator.HasPrevious = HasPreviousInt;
      function NextInt: Integer;
      function IIntIterator.Next = NextInt;
      function PreviousInt: Integer;
      function IIntIterator.Previous = PreviousInt;

      function GetPtr: Pointer;
      function HasNextPtr: Boolean;
      function IPtrIterator.HasNext = HasNextPtr;
      function HasPreviousPtr: Boolean;
      function IPtrIterator.HasPrevious = HasPreviousPtr;
      function NextPtr: Pointer;
      function IPtrIterator.Next = NextPtr;
      function PreviousPtr: Pointer;
      function IPtrIterator.Previous = PreviousPtr;

      function GetIntf: IInterface;
      function HasNextIntf: Boolean;
      function IIntfIterator.HasNext = HasNextIntf;
      function HasPreviousIntf: Boolean;
      function IIntfIterator.HasPrevious = HasPreviousIntf;
      function NextIntf: IInterface;
      function IIntfIterator.Next = NextIntf;
      function PreviousIntf: IInterface;
      function IIntfIterator.Previous = PreviousIntf;

      function GetObject: TObject;
      function HasNext: Boolean;
      function HasPrevious: Boolean;
      function Next: TObject;
      function Previous: TObject;
    public
      constructor Create(ResType: TItrResultType; Map: TAbstractContainer);
  end;

{ TMultiItr }

constructor TMultiItr.Create(ResType: TItrResultType; Map: TAbstractContainer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1721 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FResType := ResType;
  FData := Map;
  FCapacity := THashMap(Map).Capacity;
  FSize := THashMap(Map).Size;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1721; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.GetInt: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1722 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  case FResType of
    irtValue: Result := TIntIntHashMap(FData).FBuckets[FCursorX].Entries[FCursorY].Value;
    irtKey: Result := TIntIntHashMap(FData).FBuckets[FCursorX].Entries[FCursorY].Key;
  else
    Result := 0;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1722; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.GetIntf: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1723 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  case FResType of
    irtValue: Result := TIntfIntfHashMap(FData).FBuckets[FCursorX].Entries[FCursorY].Value;
    irtKey: Result := TIntfIntfHashMap(FData).FBuckets[FCursorX].Entries[FCursorY].Key;
  else
    Result := nil;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1723; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.GetObject: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1724 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  case FResType of
    irtValue: Result := THashMap(FData).FBuckets[FCursorX].Entries[FCursorY].Value;
    irtKey: Result := THashMap(FData).FBuckets[FCursorX].Entries[FCursorY].Key;
  else
    Result := nil;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1724; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.GetPtr: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1725 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  case FResType of
    irtValue: Result := TPtrPtrHashMap(FData).FBuckets[FCursorX].Entries[FCursorY].Value;
    irtKey: Result := TPtrPtrHashMap(FData).FBuckets[FCursorX].Entries[FCursorY].Key;
  else
    Result := nil;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1725; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.GetString: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1726 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  case FResType of
    irtValue: Result := TStrStrHashMap(FData).FBuckets[FCursorX].Entries[FCursorY].Value;
    irtKey: Result := TStrStrHashMap(FData).FBuckets[FCursorX].Entries[FCursorY].Key;
  else
    Result := '';
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1726; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1727 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FFound <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1727; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.HasNextInt: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1728 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FFound <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1728; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.HasNextIntf: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1729 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FFound <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1729; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.HasNextPtr: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1730 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FFound <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1730; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.HasNextStr: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1731 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FFound <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1731; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1732 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FFound <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1732; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.HasPreviousInt: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1733 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FFound <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1733; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.HasPreviousIntf: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1734 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FFound <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1734; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.HasPreviousPtr: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1735 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FFound <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1735; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.HasPreviousStr: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1736 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FFound <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1736; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.Next: TObject;
var
  HM: THashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1737 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  HM := THashMap(FData);
  repeat
    if HM.FBuckets[FCursorX].Count <> 0 then
    begin
      case FResType of
        irtValue: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Value;
        irtKey: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Key;
      else
        Result := nil;
      end;
      Inc(FFound);
      Inc(FCursorY);
      if FCursorY = HM.FBuckets[FCursorX].Count then
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
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1737; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.NextInt: Integer;
var
  HM: TIntIntHashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1738 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  HM := TIntIntHashMap(FData);
  repeat
    if HM.FBuckets[FCursorX].Count <> 0 then
    begin
      case FResType of
        irtValue: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Value;
        irtKey: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Key;
      else
        Result := 0;
      end;
      Inc(FFound);
      Inc(FCursorY);
      if FCursorY = HM.FBuckets[FCursorX].Count then
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
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1738; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.NextIntf: IInterface;
var
  HM: TIntfIntfHashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1739 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  HM := TIntfIntfHashMap(FData);
  repeat
    if HM.FBuckets[FCursorX].Count <> 0 then
    begin
      case FResType of
        irtValue: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Value;
        irtKey: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Key;
      else
        Result := nil;
      end;
      Inc(FFound);
      Inc(FCursorY);
      if FCursorY = HM.FBuckets[FCursorX].Count then
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
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1739; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.NextPtr: Pointer;
var
  HM: TPtrPtrHashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1740 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  HM := TPtrPtrHashMap(FData);
  repeat
    if HM.FBuckets[FCursorX].Count <> 0 then
    begin
      case FResType of
        irtValue: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Value;
        irtKey: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Key;
      else
        Result := nil;
      end;
      Inc(FFound);
      Inc(FCursorY);
      if FCursorY = HM.FBuckets[FCursorX].Count then
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
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1740; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.NextStr: string;
var
  HM: TStrStrHashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1741 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  HM := TStrStrHashMap(FData);
  repeat
    if HM.FBuckets[FCursorX].Count <> 0 then
    begin
      case FResType of
        irtValue: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Value;
        irtKey: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Key;
      end;
      Inc(FFound);
      Inc(FCursorY);
      if FCursorY = HM.FBuckets[FCursorX].Count then
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
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1741; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.Previous: TObject;
var
  HM: THashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1742 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  HM := THashMap(FData);
  repeat
    if FCursorY > -1 then
    begin
      case FResType of
        irtValue: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Value;
        irtKey: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Key;
      else
        Result := nil;
      end;
      Inc(FFound);
      Dec(FCursorY);
      if FCursorY = -1 then
      begin
        Dec(FCursorX);
        if FCursorX > -1 then
        begin
          FCursorY := HM.FBuckets[FCursorX].Count - 1;
        end;
      end;
      Exit;
    end;
    Dec(FCursorX);
    if FCursorX = -1 then Break;
    FCursorY := HM.FBuckets[FCursorX].Count -1;
  until False;
  Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1742; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.PreviousInt: Integer;
var
  HM: TIntIntHashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1743 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  HM := TIntIntHashMap(FData);
  repeat
    if FCursorY > -1 then
    begin
      case FResType of
        irtValue: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Value;
        irtKey: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Key;
      else
        Result := 0;
      end;
      Inc(FFound);
      Dec(FCursorY);
      if FCursorY = -1 then
      begin
        Dec(FCursorX);
        if FCursorX > -1 then
        begin
          FCursorY := HM.FBuckets[FCursorX].Count - 1;
        end;
      end;
      Exit;
    end;
    Dec(FCursorX);
    if FCursorX = -1 then Break;
    FCursorY := HM.FBuckets[FCursorX].Count -1;
  until False;
  Result := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1743; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.PreviousIntf: IInterface;
var
  HM: TIntfIntfHashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1744 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  HM := TIntfIntfHashMap(FData);
  repeat
    if FCursorY > -1 then
    begin
      case FResType of
        irtValue: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Value;
        irtKey: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Key;
      else
        Result := nil;
      end;
      Inc(FFound);
      Dec(FCursorY);
      if FCursorY = -1 then
      begin
        Dec(FCursorX);
        if FCursorX > -1 then
        begin
          FCursorY := HM.FBuckets[FCursorX].Count - 1;
        end;
      end;
      Exit;
    end;
    Dec(FCursorX);
    if FCursorX = -1 then Break;
    FCursorY := HM.FBuckets[FCursorX].Count -1;
  until False;
  Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1744; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.PreviousPtr: Pointer;
var
  HM: TPtrPtrHashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1745 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  HM := TPtrPtrHashMap(FData);
  repeat
    if FCursorY > -1 then
    begin
      case FResType of
        irtValue: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Value;
        irtKey: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Key;
      else
        Result := nil;
      end;
      Inc(FFound);
      Dec(FCursorY);
      if FCursorY = -1 then
      begin
        Dec(FCursorX);
        if FCursorX > -1 then
        begin
          FCursorY := HM.FBuckets[FCursorX].Count - 1;
        end;
      end;
      Exit;
    end;
    Dec(FCursorX);
    if FCursorX = -1 then Break;
    FCursorY := HM.FBuckets[FCursorX].Count -1;
  until False;
  Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1745; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TMultiItr.PreviousStr: string;
var
  HM: TStrStrHashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1746 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  HM := TStrStrHashMap(FData);
  repeat
    if FCursorY > -1 then
    begin
      case FResType of
        irtValue: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Value;
        irtKey: Result := HM.FBuckets[FCursorX].Entries[FCursorY].Key;
      end;
      Inc(FFound);
      Dec(FCursorY);
      if FCursorY = -1 then
      begin
        Dec(FCursorX);
        if FCursorX > -1 then
        begin
          FCursorY := HM.FBuckets[FCursorX].Count - 1;
        end;
      end;
      Exit;
    end;
    Dec(FCursorX);
    if FCursorX = -1 then Break;
    FCursorY := HM.FBuckets[FCursorX].Count -1;
  until False;
  Result := '';
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1746; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;
{$ENDREGION}

{ TStrHashMap }

procedure TStrHashMap.Clear;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1747 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count-1 do
    begin
      FBuckets[I].Entries[J].Key := '';
      FreeObject(FBuckets[I].Entries[J].Value);
    end;
    FBuckets[I].Count := 0;
  end;
  FCount := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1747; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashMap.Clone: TObject;
var
  I, J: Integer;
  NewEntryArray: TStrEntryArray;
  NewMap: TStrHashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1748 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewMap := TStrHashMap.Create(CaseSensitive, FCapacity, False);
  for I := 0 to FCapacity - 1 do
  begin
    NewEntryArray := NewMap.FBuckets[I].Entries;
    SetLength(NewEntryArray, Length(FBuckets[I].Entries));
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      NewEntryArray[J].Key := FBuckets[I].Entries[J].Key;
      NewEntryArray[J].Value := FBuckets[I].Entries[J].Value;
    end;
    NewMap.FBuckets[I].Count := FBuckets[I].Count;
  end;
  Result := NewMap;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1748; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashMap.ContainsKey(const Key: string): Boolean;
var
  I: Integer;
  Bucket: PStrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1749 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  {$ENDIF}
  Bucket := @FBuckets[FStrHashProc(Key, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1749; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashMap.ContainsValue(Value: TObject): Boolean;
var
  I, J: Integer;
  Bucket: PStrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1750 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Value = nil then Exit;
  {$ENDIF}
  for J := 0 to FCapacity - 1 do
  begin
    Bucket := @FBuckets[J];
    for I := 0 to Bucket.Count - 1 do
    begin
      if Bucket.Entries[I].Value = Value then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1750; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TStrHashMap.Create(ACaseSensitive: Boolean; ACapacity: Integer = 16; AOwnsObjects: Boolean = true);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1751 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
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
  FOwnsObjects := AOwnsObjects;
  SetLength(FBuckets, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1751; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TStrHashMap.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1752 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1752; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashMap.Equals(const AMap: IStrMap): Boolean;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1753 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AMap = nil then Exit;
  if FCount <> AMap.Size then Exit;
  Result := True;
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      if AMap.ContainsKey(FBuckets[I].Entries[J].Key) then
      begin
        if not (AMap.GetValue(FBuckets[I].Entries[J].Key) = FBuckets[I].Entries[J].Value) then
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
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1753; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashMap.GetValue(const Key: string): TObject;
var
  I: Integer;
  Bucket: PStrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1754 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  {$ENDIF}
  I := FStrHashProc(Key, FCapacity);
  Bucket := @FBuckets[I];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      Result := Bucket.Entries[I].Value;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1754; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashMap.FreeObject(AObject: TObject): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1755 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FOwnsObjects;
  if Result then AObject.Free;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1755; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrHashMap.GrowEntries(BucketIndex: Integer);
var
  Capacity: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1756 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Capacity := Length(FBuckets[BucketIndex].Entries);
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
  SetLength(FBuckets[BucketIndex].Entries, Capacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1756; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashMap.GetBucket(Index: Integer): PStrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1757 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1757; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashMap.GetBucketByKey(const Key: string): PStrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1758 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[FStrHashProc(Key, FCapacity)];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1758; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashMap.GetCaseSensitivity: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1759 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FStrCompareProc = @StringsEqual;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1759; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashMap.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1760 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1760; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashMap.KeySet: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1761 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtKey, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1761; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrHashMap.PutAll(const AMap: IStrMap);
var
  It: IStrIterator;
  Key: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1762 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AMap = nil then Exit;
  It := AMap.KeySet;
  while It.HasNext do
  begin
    Key := It.Next;
    PutValue(Key, AMap.GetValue(Key));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1762; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrHashMap.PutValue(const Key: string; Value: TObject);
var
  Index: Integer;
  Bucket: PStrBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1763 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  if Value = nil then Exit;
  {$ENDIF}
  Index := FStrHashProc(Key, FCapacity);
  Bucket := @FBuckets[Index];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      Bucket.Entries[I].Value := Value;
      Exit;
    end;
  end;
  if Bucket.Count = Length(Bucket.Entries) then GrowEntries(Index);
  Bucket.Entries[Bucket.Count].Key := Key;
  Bucket.Entries[Bucket.Count].Value := Value;
  Inc(Bucket.Count);
  Inc(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1763; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashMap.Remove(const Key: string): TObject;
var
  Bucket: PStrBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1764 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  {$ENDIF}
  Bucket := @FBuckets[FStrHashProc(Key, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      if not FreeObject(Bucket.Entries[I].Value) then
      begin
        Result := Bucket.Entries[I].Value;
        Bucket.Entries[I].Value := nil;
      end;
      Bucket.Entries[I].Key := '';
      if I < Bucket.Count -1 then
      begin
        Move(Bucket.Entries[I + 1], Bucket.Entries[I], (Bucket.Count - I) * SizeOf(TStrEntry));
      end;
      Dec(Bucket.Count);
      Dec(FCount);
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1764; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashMap.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1765 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1765; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashMap.Values: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1766 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtValue, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1766; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TStrStrHashMap }

procedure TStrStrHashMap.Clear;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1767 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count-1 do
    begin
      FBuckets[I].Entries[J].Key := '';
      FBuckets[I].Entries[J].Value := '';
    end;
    FBuckets[I].Count := 0;
  end;
  FCount := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1767; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrStrHashMap.Clone: TObject;
var
  I, J: Integer;
  NewEntryArray: TStrStrEntryArray;
  NewMap: TStrStrHashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1768 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewMap := TStrStrHashMap.Create(CaseSensitive, FCapacity);
  for I := 0 to FCapacity - 1 do
  begin
    NewEntryArray := NewMap.FBuckets[I].Entries;
    SetLength(NewEntryArray, Length(FBuckets[I].Entries));
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      NewEntryArray[J].Key := FBuckets[I].Entries[J].Key;
      NewEntryArray[J].Value := FBuckets[I].Entries[J].Value;
    end;
    NewMap.FBuckets[I].Count := FBuckets[I].Count;
  end;
  Result := NewMap;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1768; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrStrHashMap.ContainsKey(const Key: string): Boolean;
var
  I: Integer;
  Bucket: PStrStrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1769 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  {$ENDIF}
  Bucket := @FBuckets[FStrHashProc(Key, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if StringsEqual(Bucket.Entries[I].Key, Key) then
    begin
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1769; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrStrHashMap.ContainsValue(const Value: string): Boolean;
var
  I, J: Integer;
  Bucket: PStrStrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1770 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if Value = '' then Exit;
  for J := 0 to FCapacity - 1 do
  begin
    Bucket := @FBuckets[J];
    for I := 0 to Bucket.Count - 1 do
    begin
      if StringsEqual(Bucket.Entries[I].Value, Value) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1770; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TStrStrHashMap.Create(ACaseSensitive: Boolean; ACapacity: Integer = 16);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1771 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
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
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1771; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TStrStrHashMap.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1772 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1772; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrStrHashMap.Equals(const AMap: IStrStrMap): Boolean;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1773 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AMap = nil then Exit;
  if FCount <> AMap.Size then Exit;
  Result := True;
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      if AMap.ContainsKey(FBuckets[I].Entries[J].Key) then
      begin
        if not FStrCompareProc(AMap.GetValue(FBuckets[I].Entries[J].Key), FBuckets[I].Entries[J].Value) then
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
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1773; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrStrHashMap.GetValue(const Key: string): string;
var
  I: Integer;
  Bucket: PStrStrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1774 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := '';
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  {$ENDIF}
  I := FStrHashProc(Key, FCapacity);
  Bucket := @FBuckets[I];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      Result := Bucket.Entries[I].Value;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1774; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrStrHashMap.GrowEntries(BucketIndex: Integer);
var
  Capacity: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1775 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Capacity := Length(FBuckets[BucketIndex].Entries);
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
  SetLength(FBuckets[BucketIndex].Entries, Capacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1775; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrStrHashMap.GetBucket(Index: Integer): PStrStrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1776 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1776; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrStrHashMap.GetBucketByKey(
  const Key: string): PStrStrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1777 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[FStrHashProc(Key, FCapacity)];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1777; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrStrHashMap.GetCaseSensitivity: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1778 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FStrCompareProc = @StringsEqual;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1778; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrStrHashMap.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1779 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1779; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrStrHashMap.KeySet: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1780 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtKey, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1780; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrStrHashMap.PutAll(const AMap: IStrStrMap);
var
  It: IStrIterator;
  Key: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1781 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AMap = nil then Exit;
  It := AMap.KeySet;
  while It.HasNext do
  begin
    Key := It.Next;
    PutValue(Key, AMap.GetValue(Key));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1781; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrStrHashMap.PutValue(const Key, Value: string);
var
  Index: Integer;
  Bucket: PStrStrBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1782 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  if Value = '' then Exit;
  {$ENDIF}
  Index := FStrHashProc(Key, FCapacity);
  Bucket := @FBuckets[Index];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      Bucket.Entries[I].Value := Value;
      Exit;
    end;
  end;
  if Bucket.Count = Length(Bucket.Entries) then GrowEntries(Index);
  Bucket.Entries[Bucket.Count].Key := Key;
  Bucket.Entries[Bucket.Count].Value := Value;
  Inc(Bucket.Count);
  Inc(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1782; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrStrHashMap.Remove(const Key: string): string;
var
  Bucket: PStrStrBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1783 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := '';
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  {$ENDIF}
  Bucket := @FBuckets[FStrHashProc(Key, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      Result := Bucket.Entries[I].Value;
      Bucket.Entries[I].Key := '';
      Bucket.Entries[I].Value := '';
      if I < Bucket.Count -1 then
      begin
        Move(Bucket.Entries[I + 1], Bucket.Entries[I], (Bucket.Count - I) * SizeOf(TStrEntry));
      end;
      Dec(Bucket.Count);
      Dec(FCount);
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1783; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrStrHashMap.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1784 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1784; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrStrHashMap.Values: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1785 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtValue, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1785; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TStrIntHashMap }

procedure TStrIntHashMap.Clear;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1786 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count-1 do
    begin
      FBuckets[I].Entries[J].Key := '';
      FBuckets[I].Entries[J].Value := 0;
    end;
    FBuckets[I].Count := 0;
  end;
  FCount := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1786; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntHashMap.Clone: TObject;
var
  I, J: Integer;
  NewEntryArray: TStrIntEntryArray;
  NewMap: TStrIntHashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1787 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewMap := TStrIntHashMap.Create(CaseSensitive, FCapacity);
  for I := 0 to FCapacity - 1 do
  begin
    NewEntryArray := NewMap.FBuckets[I].Entries;
    SetLength(NewEntryArray, Length(FBuckets[I].Entries));
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      NewEntryArray[J].Key := FBuckets[I].Entries[J].Key;
      NewEntryArray[J].Value := FBuckets[I].Entries[J].Value;
    end;
    NewMap.FBuckets[I].Count := FBuckets[I].Count;
  end;
  Result := NewMap;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1787; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntHashMap.ContainsKey(const Key: string): Boolean;
var
  I: Integer;
  Bucket: PStrIntBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1788 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  {$ENDIF}
  Bucket := @FBuckets[FStrHashProc(Key, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1788; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntHashMap.ContainsValue(Value: Integer): Boolean;
var
  I, J: Integer;
  Bucket: PStrIntBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1789 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  for J := 0 to FCapacity - 1 do
  begin
    Bucket := @FBuckets[J];
    for I := 0 to Bucket.Count - 1 do
    begin
      if Bucket.Entries[I].Value = Value then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1789; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TStrIntHashMap.Create(ACaseSensitive: Boolean; ACapacity: Integer = 16);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1790 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
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
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1790; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TStrIntHashMap.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1791 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1791; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntHashMap.Equals(const AMap: IStrIntMap): Boolean;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1792 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AMap = nil then Exit;
  if FCount <> AMap.Size then Exit;
  Result := True;
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      if AMap.ContainsKey(FBuckets[I].Entries[J].Key) then
      begin
        if not (AMap.GetValue(FBuckets[I].Entries[J].Key) = FBuckets[I].Entries[J].Value) then
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
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1792; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntHashMap.GetValue(const Key: string): Integer;
var
  I: Integer;
  Bucket: PStrIntBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1793 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := 0;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  {$ENDIF}
  I := FStrHashProc(Key, FCapacity);
  Bucket := @FBuckets[I];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      Result := Bucket.Entries[I].Value;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1793; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrIntHashMap.GrowEntries(BucketIndex: Integer);
var
  Capacity: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1794 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Capacity := Length(FBuckets[BucketIndex].Entries);
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
  SetLength(FBuckets[BucketIndex].Entries, Capacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1794; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntHashMap.GetBucket(Index: Integer): PStrIntBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1795 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1795; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntHashMap.GetBucketByKey(
  const Key: string): PStrIntBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1796 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[FStrHashProc(Key, FCapacity)];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1796; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntHashMap.GetCaseSensitivity: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1797 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FStrCompareProc = @StringsEqual;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1797; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntHashMap.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1798 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1798; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntHashMap.KeySet: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1799 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtKey, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1799; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrIntHashMap.PutAll(const AMap: IStrIntMap);
var
  It: IStrIterator;
  Key: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1800 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AMap = nil then Exit;
  It := AMap.KeySet;
  while It.HasNext do
  begin
    Key := It.Next;
    PutValue(Key, AMap.GetValue(Key));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1800; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrIntHashMap.PutValue(const Key: string; Value: Integer);
var
  Index: Integer;
  Bucket: PStrIntBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1801 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  {$ENDIF}
  Index := FStrHashProc(Key, FCapacity);
  Bucket := @FBuckets[Index];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      Bucket.Entries[I].Value := Value;
      Exit;
    end;
  end;
  if Bucket.Count = Length(Bucket.Entries) then GrowEntries(Index);
  Bucket.Entries[Bucket.Count].Key := Key;
  Bucket.Entries[Bucket.Count].Value := Value;
  Inc(Bucket.Count);
  Inc(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1801; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntHashMap.Remove(const Key: string): Integer;
var
  Bucket: PStrIntBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1802 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := 0;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  {$ENDIF}
  Bucket := @FBuckets[FStrHashProc(Key, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      Result := Bucket.Entries[I].Value;
      Bucket.Entries[I].Key := '';
      Bucket.Entries[I].Value := 0;
      if I < Bucket.Count -1 then
      begin
        Move(Bucket.Entries[I + 1], Bucket.Entries[I], (Bucket.Count - I) * SizeOf(TStrEntry));
      end;
      Dec(Bucket.Count);
      Dec(FCount);
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1802; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntHashMap.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1803 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1803; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntHashMap.Values: IIntIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1804 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtValue, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1804; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TStrPtrHashMap }

procedure TStrPtrHashMap.Clear;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1805 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count-1 do
    begin
      FBuckets[I].Entries[J].Key := '';
      FBuckets[I].Entries[J].Value := nil;
    end;
    FBuckets[I].Count := 0;
  end;
  FCount := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1805; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrPtrHashMap.Clone: TObject;
var
  I, J: Integer;
  NewEntryArray: TStrPtrEntryArray;
  NewMap: TStrPtrHashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1806 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewMap := TStrPtrHashMap.Create(CaseSensitive, FCapacity);
  for I := 0 to FCapacity - 1 do
  begin
    NewEntryArray := NewMap.FBuckets[I].Entries;
    SetLength(NewEntryArray, Length(FBuckets[I].Entries));
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      NewEntryArray[J].Key := FBuckets[I].Entries[J].Key;
      NewEntryArray[J].Value := FBuckets[I].Entries[J].Value;
    end;
    NewMap.FBuckets[I].Count := FBuckets[I].Count;
  end;
  Result := NewMap;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1806; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrPtrHashMap.ContainsKey(const Key: string): Boolean;
var
  I: Integer;
  Bucket: PStrPtrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1807 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  {$ENDIF}
  Bucket := @FBuckets[FStrHashProc(Key, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1807; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrPtrHashMap.ContainsValue(Value: Pointer): Boolean;
var
  I, J: Integer;
  Bucket: PStrPtrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1808 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Value = nil then Exit;
  {$ENDIF}
  for J := 0 to FCapacity - 1 do
  begin
    Bucket := @FBuckets[J];
    for I := 0 to Bucket.Count - 1 do
    begin
      if Bucket.Entries[I].Value = Value then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1808; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TStrPtrHashMap.Create(ACaseSensitive: Boolean; ACapacity: Integer = 16);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1809 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
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
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1809; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TStrPtrHashMap.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1810 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1810; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrPtrHashMap.Equals(const AMap: IStrPtrMap): Boolean;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1811 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AMap = nil then Exit;
  if FCount <> AMap.Size then Exit;
  Result := True;
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      if AMap.ContainsKey(FBuckets[I].Entries[J].Key) then
      begin
        if not (AMap.GetValue(FBuckets[I].Entries[J].Key) = FBuckets[I].Entries[J].Value) then
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
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1811; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrPtrHashMap.GetValue(const Key: string): Pointer;
var
  I: Integer;
  Bucket: PStrPtrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1812 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  {$ENDIF}
  I := FStrHashProc(Key, FCapacity);
  Bucket := @FBuckets[I];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      Result := Bucket.Entries[I].Value;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1812; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrPtrHashMap.GrowEntries(BucketIndex: Integer);
var
  Capacity: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1813 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Capacity := Length(FBuckets[BucketIndex].Entries);
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
  SetLength(FBuckets[BucketIndex].Entries, Capacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1813; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrPtrHashMap.GetBucket(Index: Integer): PStrPtrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1814 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1814; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrPtrHashMap.GetBucketByKey(
  const Key: string): PStrPtrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1815 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[FStrHashProc(Key, FCapacity)];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1815; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrPtrHashMap.GetCaseSensitivity: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1816 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FStrCompareProc = @StringsEqual;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1816; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrPtrHashMap.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1817 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1817; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrPtrHashMap.KeySet: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1818 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtKey, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1818; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrPtrHashMap.PutAll(const AMap: IStrPtrMap);
var
  It: IStrIterator;
  Key: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1819 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AMap = nil then Exit;
  It := AMap.KeySet;
  while It.HasNext do
  begin
    Key := It.Next;
    PutValue(Key, AMap.GetValue(Key));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1819; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrPtrHashMap.PutValue(const Key: string; Value: Pointer);
var
  Index: Integer;
  Bucket: PStrPtrBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1820 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  if Value = nil then Exit;
  {$ENDIF}
  Index := FStrHashProc(Key, FCapacity);
  Bucket := @FBuckets[Index];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      Bucket.Entries[I].Value := Value;
      Exit;
    end;
  end;
  if Bucket.Count = Length(Bucket.Entries) then GrowEntries(Index);
  Bucket.Entries[Bucket.Count].Key := Key;
  Bucket.Entries[Bucket.Count].Value := Value;
  Inc(Bucket.Count);
  Inc(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1820; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrPtrHashMap.Remove(const Key: string): Pointer;
var
  Bucket: PStrPtrBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1821 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  {$ENDIF}
  Bucket := @FBuckets[FStrHashProc(Key, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      Result := Bucket.Entries[I].Value;
      Bucket.Entries[I].Key := '';
      Bucket.Entries[I].Value := nil;
      if I < Bucket.Count -1 then
      begin
        Move(Bucket.Entries[I + 1], Bucket.Entries[I], (Bucket.Count - I) * SizeOf(TStrEntry));
      end;
      Dec(Bucket.Count);
      Dec(FCount);
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1821; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrPtrHashMap.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1822 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1822; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrPtrHashMap.Values: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1823 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtValue, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1823; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TStrIntfHashMap }

procedure TStrIntfHashMap.Clear;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1824 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count-1 do
    begin
      FBuckets[I].Entries[J].Key := '';
      FBuckets[I].Entries[J].Value := nil;
    end;
    FBuckets[I].Count := 0;
  end;
  FCount := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1824; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntfHashMap.Clone: TObject;
var
  I, J: Integer;
  NewEntryArray: TStrIntfEntryArray;
  NewMap: TStrIntfHashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1825 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewMap := TStrIntfHashMap.Create(CaseSensitive, FCapacity);
  for I := 0 to FCapacity - 1 do
  begin
    NewEntryArray := NewMap.FBuckets[I].Entries;
    SetLength(NewEntryArray, Length(FBuckets[I].Entries));
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      NewEntryArray[J].Key := FBuckets[I].Entries[J].Key;
      NewEntryArray[J].Value := FBuckets[I].Entries[J].Value;
    end;
    NewMap.FBuckets[I].Count := FBuckets[I].Count;
  end;
  Result := NewMap;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1825; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntfHashMap.ContainsKey(const Key: string): Boolean;
var
  I: Integer;
  Bucket: PStrIntfBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1826 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  {$ENDIF}
  Bucket := @FBuckets[FStrHashProc(Key, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1826; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntfHashMap.ContainsValue(const Value: IInterface): Boolean;
var
  I, J: Integer;
  Bucket: PStrIntfBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1827 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Value = nil then Exit;
  {$ENDIF}
  for J := 0 to FCapacity - 1 do
  begin
    Bucket := @FBuckets[J];
    for I := 0 to Bucket.Count - 1 do
    begin
      if Bucket.Entries[I].Value = Value then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1827; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TStrIntfHashMap.Create(ACaseSensitive: Boolean; ACapacity: Integer = 16);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1828 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
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
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1828; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TStrIntfHashMap.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1829 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1829; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntfHashMap.Equals(const AMap: IStrIntfMap): Boolean;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1830 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AMap = nil then Exit;
  if FCount <> AMap.Size then Exit;
  Result := True;
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      if AMap.ContainsKey(FBuckets[I].Entries[J].Key) then
      begin
        if not (AMap.GetValue(FBuckets[I].Entries[J].Key) = FBuckets[I].Entries[J].Value) then
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
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1830; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntfHashMap.GetValue(const Key: string): IInterface;
var
  I: Integer;
  Bucket: PStrIntfBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1831 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  {$ENDIF}
  I := FStrHashProc(Key, FCapacity);
  Bucket := @FBuckets[I];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      Result := Bucket.Entries[I].Value;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1831; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrIntfHashMap.GrowEntries(BucketIndex: Integer);
var
  Capacity: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1832 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Capacity := Length(FBuckets[BucketIndex].Entries);
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
  SetLength(FBuckets[BucketIndex].Entries, Capacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1832; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntfHashMap.GetBucket(Index: Integer): PStrIntfBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1833 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1833; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntfHashMap.GetBucketByKey(
  const Key: string): PStrIntfBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1834 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[FStrHashProc(Key, FCapacity)];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1834; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntfHashMap.GetCaseSensitivity: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1835 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FStrCompareProc = @StringsEqual;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1835; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntfHashMap.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1836 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1836; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntfHashMap.KeySet: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1837 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtKey, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1837; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrIntfHashMap.PutAll(const AMap: IStrIntfMap);
var
  It: IStrIterator;
  Key: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1838 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AMap = nil then Exit;
  It := AMap.KeySet;
  while It.HasNext do
  begin
    Key := It.Next;
    PutValue(Key, AMap.GetValue(Key));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1838; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrIntfHashMap.PutValue(const Key: string; const Value: IInterface);
var
  Index: Integer;
  Bucket: PStrIntfBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1839 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  if Value = nil then Exit;
  {$ENDIF}
  Index := FStrHashProc(Key, FCapacity);
  Bucket := @FBuckets[Index];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      Bucket.Entries[I].Value := Value;
      Exit;
    end;
  end;
  if Bucket.Count = Length(Bucket.Entries) then GrowEntries(Index);
  Bucket.Entries[Bucket.Count].Key := Key;
  Bucket.Entries[Bucket.Count].Value := Value;
  Inc(Bucket.Count);
  Inc(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1839; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntfHashMap.Remove(const Key: string): IInterface;
var
  Bucket: PStrIntfBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1840 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Key = '' then Exit;
  {$ENDIF}
  Bucket := @FBuckets[FStrHashProc(Key, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if FStrCompareProc(Bucket.Entries[I].Key, Key) then
    begin
      Result := Bucket.Entries[I].Value;
      Bucket.Entries[I].Key := '';
      Bucket.Entries[I].Value := nil;
      if I < Bucket.Count -1 then
      begin
        Move(Bucket.Entries[I + 1], Bucket.Entries[I], (Bucket.Count - I) * SizeOf(TStrEntry));
      end;
      Dec(Bucket.Count);
      Dec(FCount);
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1840; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntfHashMap.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1841 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1841; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrIntfHashMap.Values: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1842 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtValue, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1842; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TIntHashMap }

procedure TIntHashMap.Clear;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1843 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count-1 do
    begin
      FBuckets[I].Entries[J].Key := 0;
      FreeObject(FBuckets[I].Entries[J].Value);
    end;
    FBuckets[I].Count := 0;
  end;
  FCount := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1843; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashMap.Clone: TObject;
var
  I, J: Integer;
  NewEntryArray: TIntEntryArray;
  NewMap: TIntHashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1844 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewMap := TIntHashMap.Create(FCapacity, False);
  for I := 0 to FCapacity - 1 do
  begin
    NewEntryArray := NewMap.FBuckets[I].Entries;
    SetLength(NewEntryArray, Length(FBuckets[I].Entries));
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      NewEntryArray[J].Key := FBuckets[I].Entries[J].Key;
      NewEntryArray[J].Value := FBuckets[I].Entries[J].Value;
    end;
    NewMap.FBuckets[I].Count := FBuckets[I].Count;
  end;
  Result := NewMap;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1844; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashMap.ContainsKey(Key: Integer): Boolean;
var
  I: Integer;
  Bucket: PIntBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1845 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  Bucket := @FBuckets[HashLongModulo(Key, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1845; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashMap.ContainsValue(Value: TObject): Boolean;
var
  I, J: Integer;
  Bucket: PIntBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1846 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if Value = nil then Exit;
  for J := 0 to FCapacity - 1 do
  begin
    Bucket := @FBuckets[J];
    for I := 0 to Bucket.Count - 1 do
    begin
      if Bucket.Entries[I].Value = Value then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1846; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TIntHashMap.Create(ACapacity: Integer = 16; AOwnsObjects: Boolean = true);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1847 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if ACapacity > 0 then
  begin
    FCapacity := ACapacity;
  end;
  FOwnsObjects := AOwnsObjects;
  SetLength(FBuckets, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1847; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TIntHashMap.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1848 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1848; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashMap.Equals(const AMap: IIntMap): Boolean;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1849 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AMap = nil then Exit;
  if FCount <> AMap.Size then Exit;
  Result := True;
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      if AMap.ContainsKey(FBuckets[I].Entries[J].Key) then
      begin
        if not (AMap.GetValue(FBuckets[I].Entries[J].Key) = FBuckets[I].Entries[J].Value) then
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
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1849; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashMap.GetValue(Key: Integer): TObject;
var
  I: Integer;
  Bucket: PIntBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1850 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  I := HashLongModulo(Key, FCapacity);
  Bucket := @FBuckets[I];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Result := Bucket.Entries[I].Value;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1850; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashMap.FreeObject(AObject: TObject): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1851 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FOwnsObjects;
  if Result then AObject.Free;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1851; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntHashMap.GrowEntries(BucketIndex: Integer);
var
  Capacity: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1852 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Capacity := Length(FBuckets[BucketIndex].Entries);
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
  SetLength(FBuckets[BucketIndex].Entries, Capacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1852; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashMap.GetBucket(Index: Integer): PIntBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1853 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1853; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashMap.GetBucketByKey(Key: Integer): PIntBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1854 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[HashLongModulo(Key, FCapacity)];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1854; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashMap.GetMemoryUsageInBytes: Longword;
begin
  Result := InstanceSize + Length(FBuckets) * (SizeOf(TIntBucket) + 8) +
    FCount * SizeOf(TIntEntry);
end;

function TIntHashMap.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1855 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1855; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashMap.KeySet: IIntIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1856 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtKey, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1856; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntHashMap.PutAll(const AMap: IIntMap);
var
  It: IIntIterator;
  Key: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1857 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AMap = nil then Exit;
  It := AMap.KeySet;
  while It.HasNext do
  begin
    Key := It.Next;
    PutValue(Key, AMap.GetValue(Key));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1857; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntHashMap.PutValue(Key: Integer; Value: TObject);
var
  Index: Integer;
  Bucket: PIntBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1858 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Value = nil then Exit;
  Index := HashLongModulo(Key, FCapacity);
  Bucket := @FBuckets[Index];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Bucket.Entries[I].Value := Value;
      Exit;
    end;
  end;
  if Bucket.Count = Length(Bucket.Entries) then GrowEntries(Index);
  Bucket.Entries[Bucket.Count].Key := Key;
  Bucket.Entries[Bucket.Count].Value := Value;
  Inc(Bucket.Count);
  Inc(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1858; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashMap.Remove(Key: Integer): TObject;
var
  Bucket: PIntBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1859 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  Bucket := @FBuckets[HashLongModulo(Key, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      if not FreeObject(Bucket.Entries[I].Value) then
      begin
        Result := Bucket.Entries[I].Value;
        Bucket.Entries[I].Value := nil;
      end;
      Bucket.Entries[I].Key := 0;
      if I < Bucket.Count -1 then
      begin
        Move(Bucket.Entries[I + 1], Bucket.Entries[I], (Bucket.Count - I) * SizeOf(TStrEntry));
      end;
      Dec(Bucket.Count);
      Dec(FCount);
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1859; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashMap.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1860 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1860; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntHashMap.Values: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1861 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtValue, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1861; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TIntIntHashMap }

procedure TIntIntHashMap.Clear;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1862 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count-1 do
    begin
      FBuckets[I].Entries[J].Key := 0;
    end;
    FBuckets[I].Count := 0;
  end;
  FCount := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1862; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntIntHashMap.Clone: TObject;
var
  I, J: Integer;
  NewEntryArray: TIntIntEntryArray;
  NewMap: TIntIntHashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1863 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewMap := TIntIntHashMap.Create(FCapacity);
  for I := 0 to FCapacity - 1 do
  begin
    NewEntryArray := NewMap.FBuckets[I].Entries;
    SetLength(NewEntryArray, Length(FBuckets[I].Entries));
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      NewEntryArray[J].Key := FBuckets[I].Entries[J].Key;
      NewEntryArray[J].Value := FBuckets[I].Entries[J].Value;
    end;
    NewMap.FBuckets[I].Count := FBuckets[I].Count;
  end;
  Result := NewMap;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1863; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntIntHashMap.ContainsKey(Key: Integer): Boolean;
var
  I: Integer;
  Bucket: PIntIntBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1864 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  Bucket := @FBuckets[HashLongModulo(Key, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1864; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntIntHashMap.ContainsValue(Value: Integer): Boolean;
var
  I, J: Integer;
  Bucket: PIntIntBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1865 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  for J := 0 to FCapacity - 1 do
  begin
    Bucket := @FBuckets[J];
    for I := 0 to Bucket.Count - 1 do
    begin
      if Bucket.Entries[I].Value = Value then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1865; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TIntIntHashMap.Create(ACapacity: Integer = 16);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1866 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if ACapacity > 0 then
  begin
    FCapacity := ACapacity;
  end;
  SetLength(FBuckets, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1866; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TIntIntHashMap.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1867 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1867; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntIntHashMap.Equals(const AMap: IIntIntMap): Boolean;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1868 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AMap = nil then Exit;
  if FCount <> AMap.Size then Exit;
  Result := True;
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      if AMap.ContainsKey(FBuckets[I].Entries[J].Key) then
      begin
        if not (AMap.GetValue(FBuckets[I].Entries[J].Key) = FBuckets[I].Entries[J].Value) then
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
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1868; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntIntHashMap.GetValue(Key: Integer): Integer;
var
  I: Integer;
  Bucket: PIntIntBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1869 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := 0;
  I := HashLongModulo(Key, FCapacity);
  Bucket := @FBuckets[I];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Result := Bucket.Entries[I].Value;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1869; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntIntHashMap.GrowEntries(BucketIndex: Integer);
var
  Capacity: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1870 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Capacity := Length(FBuckets[BucketIndex].Entries);
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
  SetLength(FBuckets[BucketIndex].Entries, Capacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1870; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntIntHashMap.GetBucket(Index: Integer): PIntIntBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1871 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1871; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntIntHashMap.GetBucketByKey(Key: Integer): PIntIntBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1872 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[HashLongModulo(Key, FCapacity)];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1872; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntIntHashMap.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1873 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1873; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntIntHashMap.KeySet: IIntIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1874 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtKey, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1874; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntIntHashMap.PutAll(const AMap: IIntIntMap);
var
  It: IIntIterator;
  Key: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1875 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AMap = nil then Exit;
  It := AMap.KeySet;
  while It.HasNext do
  begin
    Key := It.Next;
    PutValue(Key, AMap.GetValue(Key));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1875; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntIntHashMap.PutValue(Key, Value: Integer);
var
  Index: Integer;
  Bucket: PIntIntBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1876 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Index := HashLongModulo(Key, FCapacity);
  Bucket := @FBuckets[Index];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Bucket.Entries[I].Value := Value;
      Exit;
    end;
  end;
  if Bucket.Count = Length(Bucket.Entries) then GrowEntries(Index);
  Bucket.Entries[Bucket.Count].Key := Key;
  Bucket.Entries[Bucket.Count].Value := Value;
  Inc(Bucket.Count);
  Inc(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1876; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntIntHashMap.Remove(Key: Integer): Integer;
var
  Bucket: PIntIntBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1877 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := 0;
  Bucket := @FBuckets[HashLongModulo(Key, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Result := Bucket.Entries[I].Value;
      Bucket.Entries[I].Key := 0;
      Bucket.Entries[I].Value := 0;
      if I < Bucket.Count -1 then
      begin
        Move(Bucket.Entries[I + 1], Bucket.Entries[I], (Bucket.Count - I) * SizeOf(TStrEntry));
      end;
      Dec(Bucket.Count);
      Dec(FCount);
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1877; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntIntHashMap.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1878 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1878; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntIntHashMap.Values: IIntIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1879 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtValue, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1879; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TIntPtrHashMap }

procedure TIntPtrHashMap.Clear;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1880 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count-1 do
    begin
      FBuckets[I].Entries[J].Key := 0;
    end;
    FBuckets[I].Count := 0;
  end;
  FCount := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1880; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntPtrHashMap.Clone: TObject;
var
  I, J: Integer;
  NewEntryArray: TIntPtrEntryArray;
  NewMap: TIntPtrHashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1881 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewMap := TIntPtrHashMap.Create(FCapacity);
  for I := 0 to FCapacity - 1 do
  begin
    NewEntryArray := NewMap.FBuckets[I].Entries;
    SetLength(NewEntryArray, Length(FBuckets[I].Entries));
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      NewEntryArray[J].Key := FBuckets[I].Entries[J].Key;
      NewEntryArray[J].Value := FBuckets[I].Entries[J].Value;
    end;
    NewMap.FBuckets[I].Count := FBuckets[I].Count;
  end;
  Result := NewMap;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1881; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntPtrHashMap.ContainsKey(Key: Integer): Boolean;
var
  I: Integer;
  Bucket: PIntPtrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1882 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  Bucket := @FBuckets[HashLongModulo(Key, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1882; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntPtrHashMap.ContainsValue(Value: Pointer): Boolean;
var
  I, J: Integer;
  Bucket: PBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1883 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Value = nil then Exit;
  {$ENDIF}
  for J := 0 to FCapacity - 1 do
  begin
    Bucket := @FBuckets[J];
    for I := 0 to Bucket.Count - 1 do
    begin
      if Bucket.Entries[I].Value = Value then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1883; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TIntPtrHashMap.Create(ACapacity: Integer = 16);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1884 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if ACapacity > 0 then
  begin
    FCapacity := ACapacity;
  end;
  SetLength(FBuckets, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1884; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TIntPtrHashMap.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1885 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1885; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntPtrHashMap.Equals(const AMap: IIntPtrMap): Boolean;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1886 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AMap = nil then Exit;
  if FCount <> AMap.Size then Exit;
  Result := True;
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      if AMap.ContainsKey(FBuckets[I].Entries[J].Key) then
      begin
        if not (AMap.GetValue(FBuckets[I].Entries[J].Key) = FBuckets[I].Entries[J].Value) then
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
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1886; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntPtrHashMap.GetValue(Key: Integer): Pointer;
var
  I: Integer;
  Bucket: PIntPtrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1887 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  Bucket := @FBuckets[HashLongModulo(Key, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Result := Bucket.Entries[I].Value;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1887; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntPtrHashMap.GrowEntries(BucketIndex: Integer);
var
  Capacity: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1888 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Capacity := Length(FBuckets[BucketIndex].Entries);
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
  SetLength(FBuckets[BucketIndex].Entries, Capacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1888; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntPtrHashMap.GetBucket(Index: Integer): PIntPtrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1889 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1889; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntPtrHashMap.GetBucketByKey(Key: Integer): PIntPtrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1890 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[HashLongModulo(Key, FCapacity)];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1890; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntPtrHashMap.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1891 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1891; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntPtrHashMap.KeySet: IIntIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1892 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtKey, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1892; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntPtrHashMap.PutAll(const AMap: IIntPtrMap);
var
  It: IIntIterator;
  Key: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1893 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AMap = nil then Exit;
  It := AMap.KeySet;
  while It.HasNext do
  begin
    Key := It.Next;
    PutValue(Key, AMap.GetValue(Key));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1893; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntPtrHashMap.PutValue(Key: Integer; Value: Pointer);
var
  Index: Integer;
  Bucket: PIntPtrBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1894 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Value = nil then Exit;
  {$ENDIF}
  Index := HashLongModulo(Key, FCapacity);
  Bucket := @FBuckets[Index];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Bucket.Entries[I].Value := Value;
      Exit;
    end;
  end;
  if Bucket.Count = Length(Bucket.Entries) then GrowEntries(Index);
  begin
    Bucket.Entries[Bucket.Count].Key := Key;
    Bucket.Entries[Bucket.Count].Value := Value;
  end;
  Inc(Bucket.Count);
  Inc(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1894; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntPtrHashMap.Remove(Key: Integer): Pointer;
var
  Bucket: PIntPtrBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1895 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  Bucket := @FBuckets[HashLongModulo(Key, FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Result := Bucket.Entries[I].Value;
      Bucket.Entries[I].Key := 0;
      Bucket.Entries[I].Value := nil;
      if I < Bucket.Count -1 then
      begin
        Move(Bucket.Entries[I + 1], Bucket.Entries[I], (Bucket.Count - I) * SizeOf(TIntPtrEntry));
      end;
      Dec(Bucket.Count);
      Dec(FCount);
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1895; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntPtrHashMap.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1896 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1896; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntPtrHashMap.Values: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1897 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtValue, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1897; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TPtrPtrHashMap }

procedure TPtrPtrHashMap.Clear;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1898 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count-1 do
    begin
      FBuckets[I].Entries[J].Key := nil;
    end;
    FBuckets[I].Count := 0;
  end;
  FCount := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1898; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrPtrHashMap.Clone: TObject;
var
  I, J: Integer;
  NewEntryArray: TPtrPtrEntryArray;
  NewMap: TPtrPtrHashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1899 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewMap := TPtrPtrHashMap.Create(FCapacity);
  for I := 0 to FCapacity - 1 do
  begin
    NewEntryArray := NewMap.FBuckets[I].Entries;
    SetLength(NewEntryArray, Length(FBuckets[I].Entries));
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      NewEntryArray[J].Key := FBuckets[I].Entries[J].Key;
      NewEntryArray[J].Value := FBuckets[I].Entries[J].Value;
    end;
    NewMap.FBuckets[I].Count := FBuckets[I].Count;
  end;
  Result := NewMap;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1899; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrPtrHashMap.ContainsKey(Key: Pointer): Boolean;
var
  I: Integer;
  Bucket: PPtrPtrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1900 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if Key = nil then Exit;
  Bucket := @FBuckets[HashLongModulo(Integer(Key), FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1900; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrPtrHashMap.ContainsValue(Value: Pointer): Boolean;
var
  I, J: Integer;
  Bucket: PPtrPtrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1901 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Value = nil then Exit;
  {$ENDIF}
  for J := 0 to FCapacity - 1 do
  begin
    Bucket := @FBuckets[J];
    for I := 0 to Bucket.Count - 1 do
    begin
      if Bucket.Entries[I].Value = Value then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1901; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TPtrPtrHashMap.Create(ACapacity: Integer = 16);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1902 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if ACapacity > 0 then
  begin
    FCapacity := ACapacity;
  end;
  SetLength(FBuckets, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1902; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TPtrPtrHashMap.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1903 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1903; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrPtrHashMap.Equals(const AMap: IPtrPtrMap): Boolean;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1904 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AMap = nil then Exit;
  if FCount <> AMap.Size then Exit;
  Result := True;
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      if AMap.ContainsKey(FBuckets[I].Entries[J].Key) then
      begin
        if not (AMap.GetValue(FBuckets[I].Entries[J].Key) = FBuckets[I].Entries[J].Value) then
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
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1904; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrPtrHashMap.GetValue(Key: Pointer): Pointer;
var
  I: Integer;
  Bucket: PPtrPtrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1905 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  if Key = nil then Exit;
  Bucket := @FBuckets[HashLongModulo(Integer(Key), FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Result := Bucket.Entries[I].Value;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1905; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrPtrHashMap.GrowEntries(BucketIndex: Integer);
var
  Capacity: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1906 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Capacity := Length(FBuckets[BucketIndex].Entries);
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
  SetLength(FBuckets[BucketIndex].Entries, Capacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1906; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrPtrHashMap.GetBucket(Index: Integer): PPtrPtrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1907 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1907; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrPtrHashMap.GetBucketByKey(Key: Pointer): PPtrPtrBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1908 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[HashLongModulo(Integer(Key), FCapacity)];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1908; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrPtrHashMap.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1909 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1909; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrPtrHashMap.KeySet: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1910 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtKey, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1910; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrPtrHashMap.PutAll(const AMap: IPtrPtrMap);
var
  It: IPtrIterator;
  Key: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1911 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AMap = nil then Exit;
  It := AMap.KeySet;
  while It.HasNext do
  begin
    Key := It.Next;
    PutValue(Key, AMap.GetValue(Key));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1911; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrPtrHashMap.PutValue(Key, Value: Pointer);
var
  Index: Integer;
  Bucket: PPtrPtrBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1912 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Key = nil then Exit;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Value = nil then Exit;
  {$ENDIF}
  Index := HashLongModulo(Integer(Key), FCapacity);
  Bucket := @FBuckets[Index];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Bucket.Entries[I].Value := Value;
      Exit;
    end;
  end;
  if Bucket.Count = Length(Bucket.Entries) then GrowEntries(Index);
  begin
    Bucket.Entries[Bucket.Count].Key := Key;
    Bucket.Entries[Bucket.Count].Value := Value;
  end;
  Inc(Bucket.Count);
  Inc(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1912; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrPtrHashMap.Remove(Key: Pointer): Pointer;
var
  Bucket: PPtrPtrBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1913 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  if Key = nil then Exit;
  Bucket := @FBuckets[HashLongModulo(Integer(Key), FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Result := Bucket.Entries[I].Value;
      Bucket.Entries[I].Key := nil;
      if I < Bucket.Count -1 then
      begin
        Move(Bucket.Entries[I + 1], Bucket.Entries[I], (Bucket.Count - I) * SizeOf(TPtrPtrEntry));
      end;
      Dec(Bucket.Count);
      Dec(FCount);
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1913; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrPtrHashMap.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1914 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1914; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrPtrHashMap.Values: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1915 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtValue, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1915; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TIntfIntfHashMap }

procedure TIntfIntfHashMap.Clear;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1916 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count-1 do
    begin
      FBuckets[I].Entries[J].Key := nil;
    end;
    FBuckets[I].Count := 0;
  end;
  FCount := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1916; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfIntfHashMap.Clone: TObject;
var
  I, J: Integer;
  NewEntryArray: TIntfIntfEntryArray;
  NewMap: TIntfIntfHashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1917 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewMap := TIntfIntfHashMap.Create(FCapacity);
  for I := 0 to FCapacity - 1 do
  begin
    NewEntryArray := NewMap.FBuckets[I].Entries;
    SetLength(NewEntryArray, Length(FBuckets[I].Entries));
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      NewEntryArray[J].Key := FBuckets[I].Entries[J].Key;
      NewEntryArray[J].Value := FBuckets[I].Entries[J].Value;
    end;
    NewMap.FBuckets[I].Count := FBuckets[I].Count;
  end;
  Result := NewMap;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1917; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfIntfHashMap.ContainsKey(const Key: IInterface): Boolean;
var
  I: Integer;
  Bucket: PIntfIntfBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1918 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if Key = nil then Exit;
  Bucket := @FBuckets[HashLongModulo(Integer(Key), FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1918; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfIntfHashMap.ContainsValue(const Value: IInterface): Boolean;
var
  I, J: Integer;
  Bucket: PIntfIntfBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1919 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Value = nil then Exit;
  {$ENDIF}
  for J := 0 to FCapacity - 1 do
  begin
    Bucket := @FBuckets[J];
    for I := 0 to Bucket.Count - 1 do
    begin
      if Bucket.Entries[I].Value = Value then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1919; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TIntfIntfHashMap.Create(ACapacity: Integer = 16);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1920 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if ACapacity > 0 then
  begin
    FCapacity := ACapacity;
  end;
  SetLength(FBuckets, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1920; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TIntfIntfHashMap.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1921 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1921; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfIntfHashMap.Equals(const AMap: IIntfIntfMap): Boolean;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1922 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AMap = nil then Exit;
  if FCount <> AMap.Size then Exit;
  Result := True;
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      if AMap.ContainsKey(FBuckets[I].Entries[J].Key) then
      begin
        if not (AMap.GetValue(FBuckets[I].Entries[J].Key) = FBuckets[I].Entries[J].Value) then
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
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1922; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfIntfHashMap.GetValue(const Key: IInterface): IInterface;
var
  I: Integer;
  Bucket: PIntfIntfBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1923 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  if Key = nil then Exit;
  Bucket := @FBuckets[HashLongModulo(Integer(Key), FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Result := Bucket.Entries[I].Value;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1923; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfIntfHashMap.GrowEntries(BucketIndex: Integer);
var
  Capacity: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1924 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Capacity := Length(FBuckets[BucketIndex].Entries);
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
  SetLength(FBuckets[BucketIndex].Entries, Capacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1924; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfIntfHashMap.GetBucket(Index: Integer): PIntfIntfBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1925 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1925; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfIntfHashMap.GetBucketByKey(const Key: IInterface): PIntfIntfBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1926 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[HashLongModulo(Integer(Key), FCapacity)];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1926; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfIntfHashMap.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1927 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1927; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfIntfHashMap.KeySet: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1928 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtKey, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1928; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfIntfHashMap.PutAll(const AMap: IIntfIntfMap);
var
  It: IIntfIterator;
  Key: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1929 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AMap = nil then Exit;
  It := AMap.KeySet;
  while It.HasNext do
  begin
    Key := It.Next;
    PutValue(Key, AMap.GetValue(Key));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1929; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfIntfHashMap.PutValue(const Key, Value: IInterface);
var
  Index: Integer;
  Bucket: PIntfIntfBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1930 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Key = nil then Exit;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Value = nil then Exit;
  {$ENDIF}
  Index := HashLongModulo(Integer(Key), FCapacity);
  Bucket := @FBuckets[Index];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Bucket.Entries[I].Value := Value;
      Exit;
    end;
  end;
  if Bucket.Count = Length(Bucket.Entries) then GrowEntries(Index);
  begin
    Bucket.Entries[Bucket.Count].Key := Key;
    Bucket.Entries[Bucket.Count].Value := Value;
  end;
  Inc(Bucket.Count);
  Inc(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1930; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfIntfHashMap.Remove(const Key: IInterface): IInterface;
var
  Bucket: PIntfIntfBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1931 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  if Key = nil then Exit;
  Bucket := @FBuckets[HashLongModulo(Integer(Key), FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Result := Bucket.Entries[I].Value;
      Bucket.Entries[I].Key := nil;
      if I < Bucket.Count -1 then
      begin
        Move(Bucket.Entries[I + 1], Bucket.Entries[I], (Bucket.Count - I) * SizeOf(TIntfIntfEntry));
      end;
      Dec(Bucket.Count);
      Dec(FCount);
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1931; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfIntfHashMap.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1932 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1932; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfIntfHashMap.Values: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1933 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtValue, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1933; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ THashMap }

procedure THashMap.Clear;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1934 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count-1 do
    begin
      FBuckets[I].Entries[J].Key := nil;
      FreeObject(FBuckets[I].Entries[J].Value);
    end;
    FBuckets[I].Count := 0;
  end;
  FCount := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1934; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashMap.Clone: TObject;
var
  I, J: Integer;
  NewEntryArray: TEntryArray;
  NewMap: THashMap;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1935 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewMap := THashMap.Create(FCapacity, FOwnsObjects);
  for I := 0 to FCapacity - 1 do
  begin
    NewEntryArray := NewMap.FBuckets[I].Entries;
    SetLength(NewEntryArray, Length(FBuckets[I].Entries));
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      NewEntryArray[J].Key := FBuckets[I].Entries[J].Key;
      NewEntryArray[J].Value := FBuckets[I].Entries[J].Value;
    end;
    NewMap.FBuckets[I].Count := FBuckets[I].Count;
  end;
  Result := NewMap;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1935; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashMap.ContainsKey(Key: TObject): Boolean;
var
  I: Integer;
  Bucket: PBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1936 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if Key = nil then Exit;
  Bucket := @FBuckets[HashLongModulo(Integer(Key), FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Result := True;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1936; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashMap.ContainsValue(Value: TObject): Boolean;
var
  I, J: Integer;
  Bucket: PBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1937 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Value = nil then Exit;
  {$ENDIF}
  for J := 0 to FCapacity - 1 do
  begin
    Bucket := @FBuckets[J];
    for I := 0 to Bucket.Count - 1 do
    begin
      if Bucket.Entries[I].Value = Value then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1937; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor THashMap.Create(ACapacity: Integer = 16; AOwnsObjects: Boolean = true);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1938 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if ACapacity > 0 then
  begin
    FCapacity := ACapacity;
  end;
  FOwnsObjects := AOwnsObjects;
  SetLength(FBuckets, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1938; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor THashMap.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1939 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1939; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashMap.Equals(const AMap: IMap): Boolean;
var
  I, J: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1940 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AMap = nil then Exit;
  if FCount <> AMap.Size then Exit;
  Result := True;
  for I := 0 to FCapacity - 1 do
  begin
    for J := 0 to FBuckets[I].Count - 1 do
    begin
      if AMap.ContainsKey(FBuckets[I].Entries[J].Key) then
      begin
        if not (AMap.GetValue(FBuckets[I].Entries[J].Key) = FBuckets[I].Entries[J].Value) then
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
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1940; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashMap.FreeObject(AObject: TObject): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1941 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FOwnsObjects;
  if Result then AObject.Free;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1941; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashMap.GetValue(Key: TObject): TObject;
var
  I: Integer;
  Bucket: PBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1942 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  if Key = nil then Exit;
  Bucket := @FBuckets[HashLongModulo(Integer(Key), FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Result := Bucket.Entries[I].Value;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1942; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashMap.GrowEntries(BucketIndex: Integer);
var
  Capacity: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1943 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Capacity := Length(FBuckets[BucketIndex].Entries);
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
  SetLength(FBuckets[BucketIndex].Entries, Capacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1943; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashMap.GetBucket(Index: Integer): PBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1944 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1944; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashMap.GetBucketByKey(Key: TObject): PBucket;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1945 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuckets[HashLongModulo(Integer(Key), FCapacity)];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1945; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashMap.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1946 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1946; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashMap.KeySet: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1947 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtKey, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1947; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashMap.PutAll(const AMap: IMap);
var
  It: IIterator;
  Key: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1948 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AMap = nil then Exit;
  It := AMap.KeySet;
  while It.HasNext do
  begin
    Key := It.Next;
    PutValue(Key, AMap.GetValue(Key));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1948; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashMap.PutValue(Key, Value: TObject);
var
  Index: Integer;
  Bucket: PBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1949 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Key = nil then Exit;
  {$IFNDEF ALLOW_NIL_PARAMS}
  if Value = nil then Exit;
  {$ENDIF}
  Index := HashLongModulo(Integer(Key), FCapacity);
  Bucket := @FBuckets[Index];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      Bucket.Entries[I].Value := Value;
      Exit;
    end;
  end;
  if Bucket.Count = Length(Bucket.Entries) then GrowEntries(Index);
  begin
    Bucket.Entries[Bucket.Count].Key := Key;
    Bucket.Entries[Bucket.Count].Value := Value;
  end;
  Inc(Bucket.Count);
  Inc(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1949; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashMap.Remove(Key: TObject): TObject;
var
  Bucket: PBucket;
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1950 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  if Key = nil then Exit;
  Bucket := @FBuckets[HashLongModulo(Integer(Key), FCapacity)];
  for I := 0 to Bucket.Count - 1 do
  begin
    if Bucket.Entries[I].Key = Key then
    begin
      if not FreeObject(Bucket.Entries[I].Value) then
      begin
        Result := Bucket.Entries[I].Value;
        Bucket.Entries[I].Value := nil;
      end;
      Bucket.Entries[I].Key := nil;
      if I < Bucket.Count -1 then
      begin
        Move(Bucket.Entries[I + 1], Bucket.Entries[I], (Bucket.Count - I) * SizeOf(TStrEntry));
      end;
      Dec(Bucket.Count);
      Dec(FCount);
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1950; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashMap.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1951 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1951; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashMap.Values: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1952 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TMultiItr.Create(irtValue, Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1952; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

end.
