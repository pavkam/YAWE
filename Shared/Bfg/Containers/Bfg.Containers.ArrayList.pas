{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Array Lists.

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
unit Bfg.Containers.ArrayList;

interface

uses
  Bfg.Utils,
  Bfg.Algorithm,
  Bfg.Containers.Interfaces{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

type
  TStrArrayList = class(TAbstractContainer, IStrCollection, IStrList,
    ICloneable)
    private
      FCapacity: Integer;
      FElementData: TStringDynArray;
      FSize: Integer;
      FStrEqualProc: function(const S1, S2: string): Boolean;
      FCaseSensitive: Boolean;
      FSorted: Boolean;
    protected
      procedure Grow;
      procedure SetString(Index: Integer; const AString: string);
      procedure SetCaseSensitivity(AValue: Boolean);
      procedure SetSorted(AValue: Boolean);
      function GetString(Index: Integer): string;
      function GetCaseSensitivity: Boolean;
      function GetSorted: Boolean;
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
      function Remove(const AString: string): Boolean; overload;
      procedure RemoveAll(const ACollection: IStrCollection);
      procedure RetainAll(const ACollection: IStrCollection);
      function Size: Integer;
    public
    { IStrList }
      procedure Insert(Index: Integer; const AString: string);
      procedure InsertAll(Index: Integer; const ACollection: IStrCollection);

      function IndexOf(const AString: string): Integer;
      function CustomIndexOf(const AString: string; Compare: TStringCompare): Integer; overload;
      function CustomIndexOf(const AString: string; Compare: TStringCompareEx): Integer; overload;
      function Remove(Index: Integer): string; overload;
      function SubList(First, Count: Integer): IStrList;
      procedure Sort;
      procedure CustomSort(Compare: TStringCompare); overload;
      procedure CustomSort(Compare: TStringCompareEx); overload;
      procedure PartialResort(Start: Integer);
      procedure CustomPartialResort(Compare: TStringCompare; Start: Integer); overload;
      procedure CustomPartialResort(Compare: TStringCompareEx; Start: Integer); overload;

      property Items[Index: Integer]: string read GetString write SetString; default;
      property CaseSensitive: Boolean read GetCaseSensitivity write SetCaseSensitivity;
      property Sorted: Boolean read GetSorted write SetSorted;
    public
    { ICloneable }
      function Clone: TObject;
    public
      constructor Create; overload;
      constructor Create(Capacity: Integer); overload;
      constructor Create(const ACollection: IStrCollection); overload;
      destructor Destroy; override;
  end;

  TIntArrayList = class(TAbstractContainer, IIntCollection, IIntList,
    ICloneable)
    private
      FCapacity: Integer;
      FElementData: TIntegerDynArray;
      FSize: Integer;
      FSorted: Boolean;
    protected
      procedure Grow;
      function GetInt(Index: Integer): Integer;
      function GetSorted: Boolean;
      procedure SetInt(Index: Integer; AInt: Integer);
      procedure SetSorted(AValue: Boolean);
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
      function Remove(AInt: Integer): Boolean; overload;
      procedure RemoveAll(const ACollection: IIntCollection);
      procedure RetainAll(const ACollection: IIntCollection);
      function Size: Integer;
    public
    { IIntList }
      procedure Insert(Index: Integer; AInt: Integer);
      procedure InsertAll(Index: Integer; const ACollection: IIntCollection);
      function IndexOf(AInt: Integer): Integer;
      function CustomIndexOf(AInt: Integer; Compare: TIntegerCompare): Integer; overload;
      function CustomIndexOf(AInt: Integer; Compare: TIntegerCompareEx): Integer; overload;
      function RemoveFromIndex(Index: Integer): Integer; overload;
      function SubList(First, Count: Integer): IIntList;
      procedure Sort;
      procedure CustomSort(Compare: TIntegerCompare); overload;
      procedure CustomSort(Compare: TIntegerCompareEx); overload;
      procedure PartialResort(Start: Integer);
      procedure CustomPartialResort(Compare: TIntegerCompare; Start: Integer); overload;
      procedure CustomPartialResort(Compare: TIntegerCompareEx; Start: Integer); overload;

      property Items[Index: Integer]: Integer read GetInt write SetInt; default;
      property Sorted: Boolean read GetSorted write SetSorted;
    public
    { ICloneable }
      function Clone: TObject;
    public
      constructor Create; overload;
      constructor Create(Capacity: Integer); overload;
      constructor Create(const ACollection: IIntCollection); overload;
      destructor Destroy; override;
  end;

  TPtrArrayList = class(TAbstractContainer, IPtrCollection, IPtrList,
    ICloneable)
    private
      FCapacity: Integer;
      FElementData: TPointerDynArray;
      FSize: Integer;
      FSorted: Boolean;
    protected
      procedure Grow;
      procedure SetPtr(Index: Integer; APtr: Pointer);
      procedure SetSorted(AValue: Boolean);
      function GetPtr(Index: Integer): Pointer;
      function GetSorted: Boolean;
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
      function Remove(APtr: Pointer): Boolean; overload;
      procedure RemoveAll(const ACollection: IPtrCollection);
      procedure RetainAll(const ACollection: IPtrCollection);
      function Size: Integer;
    public
    { IPtrList }
      procedure Insert(Index: Integer; APtr: Pointer);
      procedure InsertAll(Index: Integer; const ACollection: IPtrCollection);
      function IndexOf(APtr: Pointer): Integer;
      function CustomIndexOf(APtr: Pointer; Compare: TPointerCompare): Integer; overload;
      function CustomIndexOf(APtr: Pointer; Compare: TPointerCompareEx): Integer; overload;
      function Remove(Index: Integer): Pointer; overload;
      function SubList(First, Count: Integer): IPtrList;
      procedure Sort;
      procedure CustomSort(Compare: TPointerCompare); overload;
      procedure CustomSort(Compare: TPointerCompareEx); overload;
      procedure PartialResort(Start: Integer);
      procedure CustomPartialResort(Compare: TPointerCompare; Start: Integer); overload;
      procedure CustomPartialResort(Compare: TPointerCompareEx; Start: Integer); overload;

      property Items[Index: Integer]: Pointer read GetPtr write SetPtr; default;
      property Sorted: Boolean read GetSorted write SetSorted;
    public
    { ICloneable }
      function Clone: TObject;
    public
      constructor Create; overload;
      constructor Create(Capacity: Integer); overload;
      constructor Create(const ACollection: IPtrCollection); overload;
      destructor Destroy; override;
  end;

  TArrayList = class(TAbstractContainer, ICollection, IList, ICloneable)
    private
      FCapacity: Integer;
      FElementData: TObjectDynArray;
      FSize: Integer;
      FOwnsObjects: Boolean;
      FSorted: Boolean;
    protected
      procedure Grow;
      procedure FreeObject(AObject: TObject);
      function GetObject(Index: Integer): TObject;
      function GetSorted: Boolean;
      procedure SetObject(Index: Integer; AObject: TObject);
      procedure SetSorted(AValue: Boolean);
    public
    { ICollection }
      function Add(AObject: TObject): Boolean; overload;
      procedure AddAll(const ACollection: ICollection); overload;
      procedure Clear;
      function Contains(AObject: TObject): Boolean;
      function ContainsAll(const ACollection: ICollection): Boolean;
      function Equals(const ACollection: ICollection): Boolean;
      function First: IIterator;
      function IsEmpty: Boolean;
      function Last: IIterator;
      function Remove(AObject: TObject): Boolean; overload;
      procedure RemoveAll(const ACollection: ICollection);
      procedure RetainAll(const ACollection: ICollection);
      function Size: Integer;
    public
    { IList }
      procedure Insert(Index: Integer; AObject: TObject);
      procedure InsertAll(Index: Integer; const ACollection: ICollection); 
      function IndexOf(AObject: TObject): Integer;
      function CustomIndexOf(AObject: TObject; Compare: TObjectCompare): Integer; overload;
      function CustomIndexOf(AObject: TObject; Compare: TObjectCompareEx): Integer; overload;
      function Remove(Index: Integer): TObject; overload;
      function SubList(First, Count: Integer): IList;
      procedure Sort;
      procedure CustomSort(Compare: TObjectCompare); overload;
      procedure CustomSort(Compare: TObjectCompareEx); overload;
      procedure PartialResort(Start: Integer);
      procedure CustomPartialResort(Compare: TObjectCompare; Start: Integer); overload;
      procedure CustomPartialResort(Compare: TObjectCompareEx; Start: Integer); overload; 

      property Items[Index: Integer]: TObject read GetObject write SetObject; default;
      property Sorted: Boolean read GetSorted write SetSorted;
    public
    { ICloneable }
      function Clone: TObject;
    public
      constructor Create; overload;
      constructor Create(Capacity: Integer; AOwnsObjects: Boolean); overload;
      constructor Create(const ACollection: ICollection; AOwnsObjects: Boolean); overload;
      destructor Destroy; override;
  end;

  TIntfArrayList = class(TAbstractContainer, IIntfCollection, IIntfList,
    ICloneable)
    private
      FCapacity: Integer;
      FElementData: TIntfDynArray;
      FSize: Integer;
      FSorted: Boolean;
    protected
      procedure Grow;
      function GetIntf(Index: Integer): IInterface;
      function GetSorted: Boolean;
      procedure SetIntf(Index: Integer; const AIntf: IInterface);
      procedure SetSorted(AValue: Boolean);
    public
    { IIntfCollection }
      function Add(const AIntf: IInterface): Boolean; overload;
      procedure AddAll(const ACollection: IIntfCollection); overload;
      procedure Clear;
      function Contains(const AIntf: IInterface): Boolean;
      function ContainsAll(const ACollection: IIntfCollection): Boolean;
      function Equals(const ACollection: IIntfCollection): Boolean;
      function First: IIntfIterator;
      function IsEmpty: Boolean;
      function Last: IIntfIterator;
      function Remove(const AIntf: IInterface): Boolean; overload;
      procedure RemoveAll(const ACollection: IIntfCollection);
      procedure RetainAll(const ACollection: IIntfCollection);
      function Size: Integer;
    public
    { IIntfList }
      procedure Insert(Index: Integer; const AIntf: IInterface);
      procedure InsertAll(Index: Integer; const ACollection: IIntfCollection);
      function IndexOf(const AIntf: IInterface): Integer;
      function CustomIndexOf(const AIntf: IInterface; Compare: TInterfaceCompare): Integer; overload;
      function CustomIndexOf(const AIntf: IInterface; Compare: TInterfaceCompareEx): Integer; overload;
      function Remove(Index: Integer): IInterface; overload;
      function SubList(First, Count: Integer): IIntfList;
      procedure Sort;
      procedure CustomSort(Compare: TInterfaceCompare); overload;
      procedure CustomSort(Compare: TInterfaceCompareEx); overload;
      procedure PartialResort(Start: Integer);
      procedure CustomPartialResort(Compare: TInterfaceCompare; Start: Integer); overload;
      procedure CustomPartialResort(Compare: TInterfaceCompareEx; Start: Integer); overload;

      property Items[Index: Integer]: IInterface read GetIntf write SetIntf; default;
      property Sorted: Boolean read GetSorted write SetSorted;
    public
    { ICloneable }
      function Clone: TObject;
    public
      constructor Create; overload;
      constructor Create(Capacity: Integer); overload;
      constructor Create(const ACollection: IIntfCollection); overload;
      destructor Destroy; override;
  end;

implementation

uses
  SysUtils,
  Bfg.Resources;

type
  TStrItr = class(TAbstractContainer, IStrIterator)
    private
      FCursor: Integer;
      FOwnList: TStrArrayList;
      FSize: Integer;
    protected
    { IStrIterator }
      function GetString: string;
      function HasNext: Boolean;
      function HasPrevious: Boolean;
      function Next: string;
      function Previous: string;
    public
      constructor Create(OwnList: TStrArrayList);
    end;

  TIntItr = class(TAbstractContainer, IIntIterator)
    private
      FCursor: Integer;
      FOwnList: TIntArrayList;
      FSize: Integer;
    protected
    { IIntIterator }
      function GetInt: Integer;
      function HasNext: Boolean;
      function HasPrevious: Boolean;
      function Next: Integer;
      function Previous: Integer;
    public
      constructor Create(OwnList: TIntArrayList);
    end;

  TPtrItr = class(TAbstractContainer, IPtrIterator)
    private
      FCursor: Integer;
      FOwnList: TPtrArrayList;
      FSize: Integer;
    protected
    { IPtrIterator }
      function GetPtr: Pointer;
      function HasNext: Boolean;
      function HasPrevious: Boolean;
      function Next: Pointer;
      function Previous: Pointer;
    public
      constructor Create(OwnList: TPtrArrayList);
  end;

  TIntfItr = class(TAbstractContainer, IIntfIterator)
    private
      FCursor: Integer;
      FOwnList: TIntfArrayList;
      FSize: Integer;
    protected
    { IIntfIterator }
      function GetIntf: IInterface;
      function HasNext: Boolean;
      function HasPrevious: Boolean;
      function Next: IInterface;
      function Previous: IInterface;
    public
      constructor Create(OwnList: TIntfArrayList);
  end;

  TItr = class(TAbstractContainer, IIterator)
    private
      FCursor: Integer;
      FOwnList: TArrayList;
      FSize: Integer;
    protected
    { IIterator }
      function GetObject: TObject;
      function HasNext: Boolean;
      function HasPrevious: Boolean;
      function Next: TObject;
      function Previous: TObject;
    public
      constructor Create(OwnList: TArrayList);
  end;

constructor TStrItr.Create(OwnList: TStrArrayList);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1250 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FCursor := 0;
  FOwnList := OwnList;
  FSize := FOwnList.Size;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1250; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrItr.GetString: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1251 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FOwnList.FElementData[FCursor];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1251; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1252 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor < FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1252; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1253 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor > 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1253; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrItr.Next: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1254 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FOwnList.FElementData[FCursor];
  Inc(FCursor);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1254; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrItr.Previous: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1255 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Dec(FCursor);
  Result := FOwnList.FElementData[FCursor];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1255; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TIntItr }

constructor TIntItr.Create(OwnList: TIntArrayList);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1256 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FCursor := 0;
  FOwnList := OwnList;
  FSize := FOwnList.Size;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1256; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntItr.GetInt: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1257 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FOwnList.FElementData[FCursor];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1257; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1258 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor < FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1258; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1259 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor > 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1259; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntItr.Next: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1260 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FOwnList.FElementData[FCursor];
  Inc(FCursor);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1260; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntItr.Previous: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1261 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Dec(FCursor);
  Result := FOwnList.FElementData[FCursor];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1261; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TPtrItr }

constructor TPtrItr.Create(OwnList: TPtrArrayList);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1262 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FCursor := 0;
  FOwnList := OwnList;
  FSize := FOwnList.Size;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1262; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrItr.GetPtr: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1263 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FOwnList.FElementData[FCursor];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1263; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1264 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1264; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1265 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor > 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1265; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrItr.Next: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1266 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FOwnList.FElementData[FCursor];
  Inc(FCursor);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1266; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrItr.Previous: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1267 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Dec(FCursor);
  Result := FOwnList.FElementData[FCursor];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1267; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TIntfItr }

constructor TIntfItr.Create(OwnList: TIntfArrayList);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1268 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FCursor := 0;
  FOwnList := OwnList;
  FSize := FOwnList.Size;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1268; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfItr.GetIntf: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1269 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FOwnList.FElementData[FCursor];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1269; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1270 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1270; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1271 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor > 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1271; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfItr.Next: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1272 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FOwnList.FElementData[FCursor];
  Inc(FCursor);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1272; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfItr.Previous: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1273 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Dec(FCursor);
  Result := FOwnList.FElementData[FCursor];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1273; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TItr }

constructor TItr.Create(OwnList: TArrayList);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1274 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FCursor := 0;
  FOwnList := OwnList;
  FSize := FOwnList.Size;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1274; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TItr.GetObject: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1275 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FOwnList.FElementData[FCursor];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1275; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1276 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor <> FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1276; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1277 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor > 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1277; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TItr.Next: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1278 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FOwnList.FElementData[FCursor];
  Inc(FCursor);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1278; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TItr.Previous: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1279 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Dec(FCursor);
  Result := FOwnList.FElementData[FCursor];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1279; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TStrArrayList }

procedure TStrArrayList.Insert(Index: Integer; const AString: string);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1280 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FSize = FCapacity then Grow;
  Move(FElementData[Index], FElementData[Index + 1], (FSize - Index) * SizeOf(string));
  FElementData[Index] := AString;
  Inc(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1280; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrArrayList.Add(const AString: string): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1281 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if not FSorted then
  begin
    if FSize = FCapacity then Grow;
    FElementData[FSize] := AString;
    Inc(FSize);
  end else
  begin
    I := BinarySearchLesser(Pointer(AString), @FElementData[0], FSize);
    Inc(I);
    Insert(I, AString);
  end;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1281; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArrayList.InsertAll(Index: Integer; const ACollection: IStrCollection);
var
  It: IStrIterator;
  Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1282 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  Size := ACollection.Size;
  Move(FElementData[Index], FElementData[Index + Size], Size * SizeOf(string));
  It := ACollection.First;
  while It.HasNext do
  begin
    FElementData[Index] := It.Next;
    Inc(Index);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1282; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArrayList.AddAll(const ACollection: IStrCollection);
var
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1283 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1283; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArrayList.Clear;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1284 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FSize - 1 do
    FElementData[I] := '';
  FSize := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1284; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrArrayList.Clone: TObject;
var
  NewList: TStrArrayList;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1285 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewList := TStrArrayList.Create(FCapacity);
  NewList.AddAll(Self);
  Result := NewList;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1285; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrArrayList.Contains(const AString: string): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1286 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AString = '' then Exit;
  for I := 0 to FSize - 1 do
    if FStrEqualProc(FElementData[I], AString) then
    begin
      Result := True;
      Exit;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1286; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrArrayList.ContainsAll(const ACollection: IStrCollection): Boolean;
var
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1287 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := True;
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
  begin
    if not Contains(It.Next) then
    begin
      Result := False;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1287; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TStrArrayList.Create;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1288 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Create(16);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1288; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TStrArrayList.Create(const ACollection: IStrCollection);
var
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1289 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FStrEqualProc := StringsEqual;
  Create(ACollection.Size);
  It := ACollection.First;
  while it.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1289; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TStrArrayList.Create(Capacity: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1290 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FSize := 0;
  FCapacity := Capacity;
  FStrEqualProc := StringsEqual;
  SetLength(FElementData, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1290; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TStrArrayList.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1291 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1291; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrArrayList.Equals(const ACollection: IStrCollection): Boolean;
var
  I: Integer;
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1292 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then
    Exit;
  if FSize <> ACollection.Size then
    Exit;
  It := ACollection.First;
  for I := 0 to FSize - 1 do
    if not FStrEqualProc(FElementData[I], It.Next) then Exit;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1292; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrArrayList.First: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1293 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TStrItr.Create(Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1293; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrArrayList.GetSorted: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1294 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSorted;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1294; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrArrayList.GetString(Index: Integer): string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1295 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index >= FSize) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  Result := FElementData[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1295; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArrayList.Grow;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1296 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FCapacity > 64 then
  begin
    Inc(FCapacity, FCapacity shr 2);
  end else if FCapacity = 0 then
  begin
    FCapacity := 64;
  end else
  begin
    FCapacity := FCapacity shl 2;
  end;
  SetLength(FElementData, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1296; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrArrayList.IndexOf(const AString: string): Integer;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1297 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if AString = '' then Exit;

  if not FSorted then
  begin
    for I := 0 to FSize - 1 do
    begin
      if FStrEqualProc(FElementData[I], AString) then
      begin
        Result := I;
        Exit;
      end;
    end;
  end else
  begin
    if FCaseSensitive then
    begin
      Result := BinarySearch(Pointer(AString), @FElementData[0], FSize,
        @StringsCompare);
    end else
    begin
      Result := BinarySearch(Pointer(AString), @FElementData[0], FSize,
        @StringsCompareNoCase);
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1297; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrArrayList.CustomIndexOf(const AString: string;
  Compare: TStringCompare): Integer;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1298 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if AString = '' then Exit;

  if not Sorted then
  begin
    for I := 0 to FSize - 1 do
    begin
      if Compare(AString, FElementData[I]) = 0 then
      begin
        Result := I;
        Exit;
      end;
    end;
  end else
  begin
    Result := BinarySearch(Pointer(AString), @FElementData[0], FSize,
      TPointerCompare(Compare));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1298; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrArrayList.CustomIndexOf(const AString: string;
  Compare: TStringCompareEx): Integer;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1299 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if AString = '' then Exit;

  if not Sorted then
  begin
    for I := 0 to FSize - 1 do
    begin
      if Compare(AString, FElementData[I]) = 0 then
      begin
        Result := I;
        Exit;
      end;
    end;
  end else
  begin
    Result := BinarySearch(Pointer(AString), @FElementData[0], FSize,
      TPointerCompareEx(Compare));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1299; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrArrayList.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1300 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSize = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1300; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrArrayList.Last: IStrIterator;
var
  NewIterator: TStrItr;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1301 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewIterator := TStrItr.Create(Self);
  NewIterator.FCursor := NewIterator.FOwnList.FSize;
  NewIterator.FSize := NewIterator.FOwnList.FSize;
  Result := NewIterator;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1301; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrArrayList.Remove(const AString: string): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1302 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AString = '' then Exit;
  for I := FSize - 1 downto 0 do
    if FStrEqualProc(FElementData[I], AString) then
    begin
      FElementData[I] := '';
      Move(FElementData[I + 1], FElementData[I], (FSize - I) * SizeOf(string));
      Dec(FSize);
      Result := True;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1302; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrArrayList.Remove(Index: Integer): string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1303 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index >= FSize) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  Result := FElementData[Index];
  FElementData[Index] := '';
  Move(FElementData[Index + 1], FElementData[Index], (FSize - Index) * SizeOf(string));
  Dec(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1303; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArrayList.RemoveAll(const ACollection: IStrCollection);
var
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1304 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Remove(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1304; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArrayList.RetainAll(const ACollection: IStrCollection);
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1305 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  for I := FSize - 1 downto 0 do
    if not ACollection.Contains(FElementData[I]) then
      Remove(I);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1305; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArrayList.SetCaseSensitivity(AValue: Boolean);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1306 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AValue <> FCaseSensitive then
  begin
    FCaseSensitive := AValue;
    if AValue then
    begin
      FStrEqualProc := StringsEqual;
    end else
    begin
      FStrEqualProc := StringsEqualNoCase;
    end;
    if FSorted then Sort;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1306; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArrayList.SetSorted(AValue: Boolean);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1307 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FSorted <> AValue then
  begin
    if AValue then Sort;
    FSorted := AValue;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1307; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArrayList.SetString(Index: Integer; const AString: string);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1308 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index >= FSize) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  FElementData[Index] := AString
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1308; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrArrayList.GetCaseSensitivity: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1309 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCaseSensitive;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1309; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrArrayList.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1310 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1310; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArrayList.Sort;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1311 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if CaseSensitive then
  begin
    SortArray(@FElementData[0], Length(FElementData), @StringsCompare, shUnsorted);
  end else
  begin
    SortArray(@FElementData[0], Length(FElementData), @StringsCompareNoCase, shUnsorted);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1311; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArrayList.PartialResort(Start: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1312 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if CaseSensitive then
  begin
    PartialResortArray(@FElementData[0], Length(FElementData), @StringsCompare, Start);
  end else
  begin
    PartialResortArray(@FElementData[0], Length(FElementData), @StringsCompareNoCase, Start);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1312; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArrayList.CustomPartialResort(Compare: TStringCompare;
  Start: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1313 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  PartialResortArray(@FElementData[0], Length(FElementData), TPointerCompare(Compare),
    Start);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1313; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArrayList.CustomPartialResort(Compare: TStringCompareEx;
  Start: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1314 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  PartialResortArray(@FElementData[0], Length(FElementData), TPointerCompareEx(Compare),
    Start);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1314; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArrayList.CustomSort(Compare: TStringCompare);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1315 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SortArray(@FElementData[0], Length(FElementData), TPointerCompare(Compare),
    shUnsorted);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1315; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArrayList.CustomSort(Compare: TStringCompareEx);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1316 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SortArray(@FElementData[0], Length(FElementData), TPointerCompareEx(Compare),
    shUnsorted);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1316; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrArrayList.SubList(First, Count: Integer): IStrList;
var
  I: Integer;
  Last: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1317 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Last := First + Count - 1;
  if Last >= FSize then
    Last := FSize - 1;
  Result := TStrArrayList.Create(Count);
  for I := First to Last do
  begin
    Result.Add(FElementData[I]);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1317; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TIntArrayList }

procedure TIntArrayList.Insert(Index: Integer; AInt: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1318 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FSize = FCapacity then Grow;
  Move(FElementData[Index], FElementData[Index + 1], (FSize - Index) * SizeOf(Integer));
  FElementData[Index] := AInt;
  Inc(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1318; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntArrayList.Add(AInt: Integer): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1319 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if not FSorted then
  begin
    if FSize = FCapacity then Grow;
    FElementData[FSize] := AInt;
    Inc(FSize);
  end else
  begin
    I := BinarySearchLesser(Pointer(AInt), @FElementData[0], FSize);
    Inc(I);
    Insert(AInt, I);
  end;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1319; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntArrayList.InsertAll(Index: Integer; const ACollection: IIntCollection);
var
  It: IIntIterator;
  Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1320 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  Size := ACollection.Size;
  Move(FElementData[Index], FElementData[Index + Size], Size * SizeOf(Integer));
  It := ACollection.First;
  while It.HasNext do
  begin
    FElementData[Index] := It.Next;
    Inc(Index);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1320; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntArrayList.AddAll(const ACollection: IIntCollection);
var
  It: IIntIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1321 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1321; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntArrayList.Clear;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1322 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FSize - 1 do
    FElementData[I] := 0;
  FSize := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1322; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntArrayList.Clone: TObject;
var
  NewList: TIntArrayList;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1323 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewList := TIntArrayList.Create(FCapacity);
  NewList.AddAll(Self);
  Result := NewList;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1323; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntArrayList.Contains(AInt: Integer): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1324 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  for I := 0 to FSize - 1 do
    if FElementData[I] = AInt then
    begin
      Result := True;
      Exit;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1324; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntArrayList.ContainsAll(const ACollection: IIntCollection): Boolean;
var
  It: IIntIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1325 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := True;
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
  begin
    if not Contains(It.Next) then
    begin
      Result := False;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1325; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TIntArrayList.Create;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1326 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Create(16);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1326; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TIntArrayList.Create(const ACollection: IIntCollection);
var
  It: IIntIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1327 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  Create(ACollection.Size);
  It := ACollection.First;
  while it.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1327; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TIntArrayList.Create(Capacity: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1328 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FSize := 0;
  FCapacity := Capacity;
  SetLength(FElementData, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1328; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TIntArrayList.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1329 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1329; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntArrayList.Equals(const ACollection: IIntCollection): Boolean;
var
  I: Integer;
  It: IIntIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1330 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then
    Exit;
  if FSize <> ACollection.Size then
    Exit;
  It := ACollection.First;
  for I := 0 to FSize - 1 do
    if FElementData[I] <> It.Next then Exit;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1330; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntArrayList.First: IIntIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1331 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TIntItr.Create(Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1331; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntArrayList.GetInt(Index: Integer): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1332 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index >= FSize) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  Result := FElementData[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1332; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntArrayList.GetSorted: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1333 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSorted;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1333; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntArrayList.Grow;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1334 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FCapacity > 64 then
  begin
    Inc(FCapacity, FCapacity shr 2);
  end else if FCapacity = 0 then
  begin
    FCapacity := 64;
  end else
  begin
    FCapacity := FCapacity shl 2;
  end;
  SetLength(FElementData, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1334; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntArrayList.IndexOf(AInt: Integer): Integer;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1335 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;

  if not FSorted then
  begin
    for I := 0 to FSize - 1 do
    begin
      if FElementData[I] = AInt then
      begin
        Result := I;
        Exit;
      end;
    end;
  end else
  begin
    Result := BinarySearch(Pointer(AInt), @FElementData[0], FSize, True);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1335; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntArrayList.CustomIndexOf(AInt: Integer;
  Compare: TIntegerCompare): Integer;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1336 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;

  if not FSorted then
  begin
    for I := 0 to FSize - 1 do
    begin
      if Compare(AInt, FElementData[I]) = 0 then
      begin
        Result := I;
        Exit;
      end;
    end;
  end else
  begin
    Result := BinarySearch(Pointer(AInt), @FElementData[0], FSize,
      TPointerCompare(Compare));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1336; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntArrayList.CustomIndexOf(AInt: Integer;
  Compare: TIntegerCompareEx): Integer;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1337 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;

  if not FSorted then
  begin
    for I := 0 to FSize - 1 do
    begin
      if Compare(AInt, FElementData[I]) = 0 then
      begin
        Result := I;
        Exit;
      end;
    end;
  end else
  begin
    Result := BinarySearch(Pointer(AInt), @FElementData[0], FSize,
      TPointerCompareEx(Compare));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1337; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntArrayList.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1338 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSize = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1338; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntArrayList.Last: IIntIterator;
var
  NewIterator: TIntItr;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1339 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewIterator := TIntItr.Create(Self);
  NewIterator.FCursor := NewIterator.FOwnList.FSize;
  NewIterator.FSize := NewIterator.FOwnList.FSize;
  Result := NewIterator;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1339; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntArrayList.Remove(AInt: Integer): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1340 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  for I := FSize - 1 downto 0 do
    if FElementData[I] = AInt then
    begin
      FElementData[I] := 0;
      Move(FElementData[I + 1], FElementData[I], (FSize - I) * SizeOf(Integer));
      Dec(FSize);
      Result := True;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1340; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntArrayList.RemoveFromIndex(Index: Integer): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1341 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index >= FSize) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  Result := FElementData[Index];
  FElementData[Index] := 0;
  Move(FElementData[Index + 1], FElementData[Index], (FSize - Index) * SizeOf(Integer));
  Dec(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1341; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntArrayList.RemoveAll(const ACollection: IIntCollection);
var
  It: IIntIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1342 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Remove(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1342; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntArrayList.RetainAll(const ACollection: IIntCollection);
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1343 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  for I := FSize - 1 downto 0 do
    if not ACollection.Contains(FElementData[I]) then
      Remove(I);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1343; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntArrayList.SetInt(Index: Integer; AInt: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1344 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index >= FSize) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  FElementData[Index] := AInt
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1344; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntArrayList.SetSorted(AValue: Boolean);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1345 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FSorted <> AValue then
  begin
    if AValue then Sort;
    FSorted := AValue;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1345; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntArrayList.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1346 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1346; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntArrayList.Sort;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1347 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SortArray(@FElementData[0], FSize, True, shUnsorted);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1347; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntArrayList.PartialResort(Start: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1348 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  PartialResortArray(@FElementData[0], FSize, Start);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1348; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntArrayList.CustomSort(Compare: TIntegerCompare);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1349 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SortArray(@FElementData[0], FSize, TPointerCompare(Compare), shUnsorted);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1349; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntArrayList.CustomSort(Compare: TIntegerCompareEx);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1350 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SortArray(@FElementData[0], FSize, TPointerCompareEx(Compare), shUnsorted);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1350; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntArrayList.CustomPartialResort(Compare: TIntegerCompare;
  Start: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1351 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  PartialResortArray(@FElementData[0], FSize, TPointerCompare(Compare), Start);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1351; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntArrayList.CustomPartialResort(Compare: TIntegerCompareEx;
  Start: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1352 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  PartialResortArray(@FElementData[0], FSize, TPointerCompareEx(Compare), Start);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1352; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntArrayList.SubList(First, Count: Integer): IIntList;
var
  I: Integer;
  Last: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1353 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Last := First + Count - 1;
  if Last >= FSize then
    Last := FSize - 1;
  Result := TIntArrayList.Create(Count);
  for I := First to Last do
  begin
    Result.Add(FElementData[I]);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1353; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TPtrArrayList }

procedure TPtrArrayList.Insert(Index: Integer; APtr: Pointer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1354 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FSize = FCapacity then
  Grow;
  Move(FElementData[Index], FElementData[Index + 1], (FSize - Index) * SizeOf(Pointer));
  FElementData[Index] := APtr;
  Inc(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1354; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrArrayList.Add(APtr: Pointer): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1355 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if not FSorted then
  begin
    if FSize = FCapacity then Grow;
    FElementData[FSize] := APtr;
    Inc(FSize);
  end else
  begin
    I := BinarySearchLesser(Pointer(APtr), @FElementData[0], FSize);
    Inc(I);
    Insert(I, APtr);
  end;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1355; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrArrayList.AddAll(const ACollection: IPtrCollection);
var
  It: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1356 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1356; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrArrayList.InsertAll(Index: Integer; const ACollection: IPtrCollection);
var
  It: IPtrIterator;
  Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1357 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  Size := ACollection.Size;
  Move(FElementData[Index], FElementData[Index + Size], Size * SizeOf(Pointer));
  It := ACollection.First;
  while It.HasNext do
  begin
    FElementData[Index] := It.Next;
    Inc(Index);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1357; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrArrayList.Clear;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1358 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FSize - 1 do
  begin
    FElementData[I] := nil;
  end;
  FSize := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1358; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrArrayList.Clone: TObject;
var
  NewList: TPtrArrayList;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1359 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewList := TPtrArrayList.Create(FCapacity);
  NewList.AddAll(Self);
  Result := NewList;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1359; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrArrayList.Contains(APtr: Pointer): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1360 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if APtr = nil then Exit;
  for I := 0 to FSize - 1 do
    if FElementData[I] = APtr then
    begin
      Result := True;
      Exit;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1360; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrArrayList.ContainsAll(const ACollection: IPtrCollection): Boolean;
var
  It: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1361 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := True;
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
  begin
    if not Contains(It.Next) then
    begin
      Result := False;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1361; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TPtrArrayList.Create(Capacity: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1362 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FSize := 0;
  FCapacity := Capacity;
  SetLength(FElementData, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1362; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TPtrArrayList.Create(const ACollection: IPtrCollection);
var
  It: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1363 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  Create(ACollection.Size);
  It := ACollection.First;
  while it.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1363; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TPtrArrayList.Create;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1364 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Create(16);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1364; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TPtrArrayList.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1365 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1365; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrArrayList.Equals(const ACollection: IPtrCollection): Boolean;
var
  I: Integer;
  It: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1366 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then
    Exit;
  if FSize <> ACollection.Size then
    Exit;
  It := ACollection.First;
  for I := 0 to FSize - 1 do
  if FElementData[I] <> It.Next then Exit;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1366; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrArrayList.GetPtr(Index: Integer): Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1367 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index >= FSize) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  Result := FElementData[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1367; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrArrayList.GetSorted: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1368 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSorted;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1368; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrArrayList.Grow;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1369 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FCapacity > 64 then
  begin
    Inc(FCapacity, FCapacity shr 2);
  end else if FCapacity = 0 then
  begin
    FCapacity := 64;
  end else
  begin
    FCapacity := FCapacity shl 2;
  end;
  SetLength(FElementData, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1369; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrArrayList.IndexOf(APtr: Pointer): Integer;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1370 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if APtr = nil then Exit;

  if not FSorted then
  begin
    for I := 0 to FSize - 1 do
    begin
      if FElementData[I] = APtr then
      begin
        Result := I;
        Exit;
      end;
    end;
  end else
  begin
    Result := BinarySearch(APtr, @FElementData[0], FSize);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1370; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrArrayList.CustomIndexOf(APtr: Pointer;
  Compare: TPointerCompare): Integer;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1371 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if APtr = nil then Exit;

  if not FSorted then
  begin
    for I := 0 to FSize - 1 do
    begin
      if Compare(APtr, FElementData[I]) = 0 then
      begin
        Result := I;
        Exit;
      end;
    end;
  end else
  begin
    Result := BinarySearch(APtr, @FElementData[0], FSize, Compare);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1371; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrArrayList.CustomIndexOf(APtr: Pointer;
  Compare: TPointerCompareEx): Integer;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1372 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if APtr = nil then Exit;

  if not FSorted then
  begin
    for I := 0 to FSize - 1 do
    begin
      if Compare(APtr, FElementData[I]) = 0 then
      begin
        Result := I;
        Exit;
      end;
    end;
  end else
  begin
    Result := BinarySearch(APtr, @FElementData[0], FSize, Compare);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1372; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrArrayList.First: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1373 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TPtrItr.Create(Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1373; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrArrayList.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1374 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSize = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1374; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrArrayList.Last: IPtrIterator;
var
  NewIterator: TPtrItr;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1375 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewIterator := TPtrItr.Create(Self);
  NewIterator.FCursor := NewIterator.FOwnList.FSize;
  NewIterator.FSize := NewIterator.FOwnList.FSize;
  Result := NewIterator;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1375; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrArrayList.Remove(APtr: Pointer): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1376 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if APtr = nil then Exit;
  for I := FSize - 1 downto 0 do
    if FElementData[I] = APtr then
    begin
      Move(FElementData[I + 1], FElementData[I], (FSize - I) * SizeOf(Pointer));
      Dec(FSize);
      Result := True;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1376; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrArrayList.Remove(Index: Integer): Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1377 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index >= FSize) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  Result := nil;
  Move(FElementData[Index + 1], FElementData[Index], (FSize - Index) * SizeOf(Pointer));
  Dec(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1377; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrArrayList.RemoveAll(const ACollection: IPtrCollection);
var
  It: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1378 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Remove(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1378; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrArrayList.RetainAll(const ACollection: IPtrCollection);
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1379 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  for I := FSize - 1 to 0 do
    if not ACollection.Contains(FElementData[I]) then
      Remove(I);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1379; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrArrayList.SetPtr(Index: Integer; APtr: Pointer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1380 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index >= FSize) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  FElementData[Index] := APtr;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1380; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrArrayList.SetSorted(AValue: Boolean);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1381 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FSorted <> AValue then
  begin
    if AValue then Sort;
    FSorted := AValue;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1381; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrArrayList.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1382 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1382; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrArrayList.Sort;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1383 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SortArray(@FElementData[0], FSize, False, shUnsorted);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1383; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrArrayList.PartialResort(Start: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1384 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  PartialResortArray(@FElementData[0], FSize, Start);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1384; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrArrayList.CustomPartialResort(Compare: TPointerCompare;
  Start: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1385 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  PartialResortArray(@FElementData[0], FSize, Compare, Start);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1385; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrArrayList.CustomPartialResort(Compare: TPointerCompareEx;
  Start: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1386 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  PartialResortArray(@FElementData[0], FSize, Compare, Start);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1386; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrArrayList.CustomSort(Compare: TPointerCompare);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1387 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SortArray(@FElementData[0], FSize, Compare, shUnsorted);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1387; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrArrayList.CustomSort(Compare: TPointerCompareEx);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1388 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SortArray(@FElementData[0], FSize, Compare, shUnsorted);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1388; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrArrayList.SubList(First, Count: Integer): IPtrList;
var
  I: Integer;
  Last: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1389 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Last := First + Count - 1;
  if Last >= FSize then Last := FSize - 1;
  Result := TPtrArrayList.Create(Count);
  for I := First to Last do
  begin
    Result.Add(FElementData[I]);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1389; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TIntfArrayList }

procedure TIntfArrayList.Insert(Index: Integer; const AIntf: IInterface);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1390 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FSize = FCapacity then
  Grow;
  Move(FElementData[Index], FElementData[Index + 1], (FSize - Index) * SizeOf(IInterface));
  FElementData[Index] := AIntf;
  Inc(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1390; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfArrayList.Add(const AIntf: IInterface): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1391 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if not FSorted then
  begin
    if FSize = FCapacity then Grow;
    FElementData[FSize] := AIntf;
    Inc(FSize);
  end else
  begin
    I := BinarySearchLesser(Pointer(AIntf), @FElementData[0], FSize);
    Inc(I);
    Insert(I, AIntf);
  end;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1391; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfArrayList.AddAll(const ACollection: IIntfCollection);
var
  It: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1392 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1392; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfArrayList.InsertAll(Index: Integer; const ACollection: IIntfCollection);
var
  It: IIntfIterator;
  Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1393 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  Size := ACollection.Size;
  Move(FElementData[Index], FElementData[Index + Size], Size * SizeOf(IInterface));
  It := ACollection.First;
  while It.HasNext do
  begin
    FElementData[Index] := It.Next;
    Inc(Index);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1393; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfArrayList.Clear;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1394 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FSize - 1 do
  begin
    FElementData[I] := nil;
  end;
  FSize := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1394; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfArrayList.Clone: TObject;
var
  NewList: TIntfArrayList;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1395 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewList := TIntfArrayList.Create(FCapacity);
  NewList.AddAll(Self);
  Result := NewList;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1395; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfArrayList.Contains(const AIntf: IInterface): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1396 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AIntf = nil then Exit;
  for I := 0 to FSize - 1 do
    if FElementData[I] = AIntf then
    begin
      Result := True;
      Exit;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1396; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfArrayList.ContainsAll(const ACollection: IIntfCollection): Boolean;
var
  It: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1397 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := True;
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
  begin
    if not Contains(It.Next) then
    begin
      Result := False;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1397; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TIntfArrayList.Create(Capacity: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1398 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FSize := 0;
  FCapacity := Capacity;
  SetLength(FElementData, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1398; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TIntfArrayList.Create(const ACollection: IIntfCollection);
var
  It: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1399 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  Create(ACollection.Size);
  It := ACollection.First;
  while it.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1399; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TIntfArrayList.Create;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1400 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Create(16);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1400; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TIntfArrayList.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1401 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1401; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfArrayList.Equals(const ACollection: IIntfCollection): Boolean;
var
  I: Integer;
  It: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1402 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then
    Exit;
  if FSize <> ACollection.Size then
    Exit;
  It := ACollection.First;
  for I := 0 to FSize - 1 do
  if FElementData[I] <> It.Next then Exit;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1402; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfArrayList.GetIntf(Index: Integer): IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1403 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index >= FSize) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  Result := FElementData[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1403; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfArrayList.GetSorted: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1404 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSorted;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1404; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfArrayList.Grow;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1405 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FCapacity > 64 then
  begin
    Inc(FCapacity, FCapacity shr 2);
  end else if FCapacity = 0 then
  begin
    FCapacity := 64;
  end else
  begin
    FCapacity := FCapacity shl 2;
  end;
  SetLength(FElementData, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1405; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfArrayList.IndexOf(const AIntf: IInterface): Integer;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1406 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if AIntf = nil then Exit;

  if not FSorted then
  begin
    for I := 0 to FSize - 1 do
    begin
      if FElementData[I] = AIntf then
      begin
        Result := I;
        Exit;
      end;
    end;
  end else
  begin
    Result := BinarySearch(Pointer(AIntf), @FElementData[0], FSize);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1406; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfArrayList.CustomIndexOf(const AIntf: IInterface;
  Compare: TInterfaceCompare): Integer;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1407 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if AIntf = nil then Exit;

  if not FSorted then
  begin
    for I := 0 to FSize - 1 do
    begin
      if Compare(AIntf, FElementData[I]) = 0 then
      begin
        Result := I;
        Exit;
      end;
    end;
  end else
  begin
    Result := BinarySearch(Pointer(AIntf), @FElementData[0], FSize,
      TPointerCompare(Compare));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1407; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfArrayList.CustomIndexOf(const AIntf: IInterface;
  Compare: TInterfaceCompareEx): Integer;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1408 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if AIntf = nil then Exit;

  if not FSorted then
  begin
    for I := 0 to FSize - 1 do
    begin
      if Compare(AIntf, FElementData[I]) = 0 then
      begin
        Result := I;
        Exit;
      end;
    end;
  end else
  begin
    Result := BinarySearch(Pointer(AIntf), @FElementData[0], FSize,
      TPointerCompareEx(Compare));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1408; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfArrayList.First: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1409 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TIntfItr.Create(Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1409; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfArrayList.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1410 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSize = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1410; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfArrayList.Last: IIntfIterator;
var
  NewIterator: TIntfItr;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1411 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewIterator := TIntfItr.Create(Self);
  NewIterator.FCursor := NewIterator.FOwnList.FSize;
  NewIterator.FSize := NewIterator.FOwnList.FSize;
  Result := NewIterator;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1411; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfArrayList.Remove(const AIntf: IInterface): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1412 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AIntf = nil then Exit;
  for I := FSize - 1 downto 0 do
    if FElementData[I] = AIntf then
    begin
      Move(FElementData[I + 1], FElementData[I], (FSize - I) * SizeOf(IInterface));
      Dec(FSize);
      Result := True;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1412; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfArrayList.Remove(Index: Integer): IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1413 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index >= FSize) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  Result := nil;
  Move(FElementData[Index + 1], FElementData[Index], (FSize - Index) * SizeOf(IInterface));
  Dec(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1413; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfArrayList.RemoveAll(const ACollection: IIntfCollection);
var
  It: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1414 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Remove(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1414; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfArrayList.RetainAll(const ACollection: IIntfCollection);
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1415 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  for I := FSize - 1 to 0 do
    if not ACollection.Contains(FElementData[I]) then
      Remove(I);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1415; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfArrayList.SetIntf(Index: Integer; const AIntf: IInterface);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1416 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index >= FSize) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  FElementData[Index] := AIntf;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1416; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfArrayList.SetSorted(AValue: Boolean);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1417 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FSorted <> AValue then
  begin
    if AValue then Sort;
    FSorted := AValue;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1417; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfArrayList.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1418 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1418; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfArrayList.Sort;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1419 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SortArray(@FElementData[0], FSize, False, shUnsorted);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1419; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfArrayList.PartialResort(Start: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1420 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  PartialResortArray(@FElementData[0], FSize, Start);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1420; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfArrayList.CustomPartialResort(Compare: TInterfaceCompare;
  Start: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1421 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  PartialResortArray(@FElementData[0], FSize, TPointerCompare(Compare), Start);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1421; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfArrayList.CustomPartialResort(Compare: TInterfaceCompareEx;
  Start: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1422 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  PartialResortArray(@FElementData[0], FSize, TPointerCompareEx(Compare), Start);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1422; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfArrayList.CustomSort(Compare: TInterfaceCompare);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1423 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SortArray(@FElementData[0], FSize, TPointerCompare(Compare), shUnsorted);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1423; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfArrayList.CustomSort(Compare: TInterfaceCompareEx);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1424 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SortArray(@FElementData[0], FSize, TPointerCompareEx(Compare), shUnsorted);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1424; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfArrayList.SubList(First, Count: Integer): IIntfList;
var
  I: Integer;
  Last: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1425 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Last := First + Count - 1;
  if Last >= FSize then Last := FSize - 1;
  Result := TIntfArrayList.Create(Count);
  for I := First to Last do
  begin
    Result.Add(FElementData[I]);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1425; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TArrayList }

procedure TArrayList.Insert(Index: Integer; AObject: TObject);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1426 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FSize = FCapacity then
  Grow;
  Move(FElementData[Index], FElementData[Index + 1], (FSize - Index) * SizeOf(TObject));
  FElementData[Index] := AObject;
  Inc(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1426; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TArrayList.Add(AObject: TObject): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1427 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if not FSorted then
  begin
    if FSize = FCapacity then Grow;
    FElementData[FSize] := AObject;
    Inc(FSize);
  end else
  begin
    I := BinarySearchLesser(Pointer(AObject), @FElementData[0], FSize);
    Inc(I);
    Insert(I, AObject);
  end;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1427; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArrayList.AddAll(const ACollection: ICollection);
var
  It: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1428 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1428; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArrayList.InsertAll(Index: Integer; const ACollection: ICollection);
var
  It: IIterator;
  Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1429 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  Size := ACollection.Size;
  Move(FElementData[Index], FElementData[Index + Size], Size * SizeOf(Pointer));
  It := ACollection.First;
  while It.HasNext do
  begin
    FElementData[Index] := It.Next;
    Inc(Index);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1429; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArrayList.Clear;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1430 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  for I := 0 to FSize - 1 do
  begin
    FreeObject(FElementData[I]);
    FElementData[I] := nil;
  end;
  FSize := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1430; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TArrayList.Clone: TObject;
var
  NewList: TArrayList;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1431 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewList := TArrayList.Create(FCapacity, False);
  NewList.AddAll(Self);
  Result := NewList;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1431; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TArrayList.Contains(AObject: TObject): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1432 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AObject = nil then Exit;
  for I := 0 to FSize - 1 do
    if FElementData[I] = AObject then
    begin
      Result := True;
      Exit;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1432; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TArrayList.ContainsAll(const ACollection: ICollection): Boolean;
var
  It: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1433 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := True;
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
  begin
    if not Contains(It.Next) then
    begin
      Result := False;
      Exit;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1433; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TArrayList.Create(Capacity: Integer; AOwnsObjects: Boolean);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1434 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FSize := 0;
  FCapacity := Capacity;
  FOwnsObjects := AOwnsObjects;
  SetLength(FElementData, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1434; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TArrayList.Create(const ACollection: ICollection; AOwnsObjects: Boolean);
var
  It: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1435 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  Create(ACollection.Size, AOwnsObjects);
  It := ACollection.First;
  while it.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1435; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TArrayList.Create;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1436 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Create(16, True);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1436; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TArrayList.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1437 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1437; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TArrayList.Equals(const ACollection: ICollection): Boolean;
var
  I: Integer;
  It: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1438 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then
    Exit;
  if FSize <> ACollection.Size then
    Exit;
  It := ACollection.First;
  for I := 0 to FSize - 1 do
  if FElementData[I] <> It.Next then Exit;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1438; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArrayList.FreeObject(AObject: TObject);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1439 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FOwnsObjects then AObject.Free;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1439; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TArrayList.GetObject(Index: Integer): TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1440 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index >= FSize) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  Result := FElementData[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1440; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TArrayList.GetSorted: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1441 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSorted;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1441; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArrayList.Grow;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1442 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FCapacity > 64 then
  begin
    Inc(FCapacity, FCapacity shr 2);
  end else if FCapacity = 0 then
  begin
    FCapacity := 64;
  end else
  begin
    FCapacity := FCapacity shl 2;
  end;
  SetLength(FElementData, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1442; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TArrayList.IndexOf(AObject: TObject): Integer;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1443 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if AObject = nil then Exit;

  if not FSorted then
  begin
    for I := 0 to FSize - 1 do
    begin
      if FElementData[I] = AObject then
      begin
        Result := I;
        Exit;
      end;
    end;
  end else
  begin
    Result := BinarySearch(Pointer(AObject), @FElementData[0], FSize);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1443; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TArrayList.CustomIndexOf(AObject: TObject;
  Compare: TObjectCompare): Integer;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1444 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if AObject = nil then Exit;

  if not FSorted then
  begin
    for I := 0 to FSize - 1 do
    begin
      if Compare(AObject, FElementData[I]) = 0 then
      begin
        Result := I;
        Exit;
      end;
    end;
  end else
  begin
    Result := BinarySearch(Pointer(AObject), @FElementData[0], FSize,
      TPointerCompare(Compare));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1444; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TArrayList.CustomIndexOf(AObject: TObject;
  Compare: TObjectCompareEx): Integer;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1445 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if AObject = nil then Exit;

  if not FSorted then
  begin
    for I := 0 to FSize - 1 do
    begin
      if Compare(AObject, FElementData[I]) = 0 then
      begin
        Result := I;
        Exit;
      end;
    end;
  end else
  begin
    Result := BinarySearch(Pointer(AObject), @FElementData[0], FSize,
      TPointerCompareEx(Compare));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1445; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TArrayList.First: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1446 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TItr.Create(Self);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1446; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TArrayList.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1447 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSize = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1447; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TArrayList.Last: IIterator;
var
  NewIterator: TItr;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1448 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewIterator := TItr.Create(Self);
  NewIterator.FCursor := NewIterator.FOwnList.FSize;
  NewIterator.FSize := NewIterator.FOwnList.FSize;
  Result := NewIterator;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1448; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TArrayList.Remove(AObject: TObject): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1449 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AObject = nil then Exit;
  for I := FSize - 1 downto 0 do
    if FElementData[I] = AObject then
    begin
      FreeObject(FElementData[I]);
      Move(FElementData[I + 1], FElementData[I], (FSize - I) * SizeOf(TObject));
      Dec(FSize);
      Result := True;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1449; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TArrayList.Remove(Index: Integer): TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1450 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index >= FSize) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  Result := nil;
  FreeObject(FElementData[Index]);
  Move(FElementData[Index + 1], FElementData[Index], (FSize - Index) * SizeOf(TObject));
  Dec(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1450; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArrayList.RemoveAll(const ACollection: ICollection);
var
  It: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1451 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Remove(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1451; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArrayList.RetainAll(const ACollection: ICollection);
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1452 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  for I := FSize - 1 to 0 do
    if not ACollection.Contains(FElementData[I]) then
      Remove(I);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1452; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArrayList.SetObject(Index: Integer; AObject: TObject);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1453 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index >= FSize) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  FElementData[Index] := AObject;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1453; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArrayList.SetSorted(AValue: Boolean);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1454 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FSorted <> AValue then
  begin
    if AValue then Sort;
    FSorted := AValue;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1454; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TArrayList.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1455 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1455; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArrayList.Sort;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1456 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SortArray(@FElementData[0], FSize, False, shUnsorted);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1456; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArrayList.PartialResort(Start: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1457 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  PartialResortArray(@FElementData[0], FSize, Start);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1457; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArrayList.CustomPartialResort(Compare: TObjectCompare;
  Start: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1458 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  PartialResortArray(@FElementData[0], FSize, TPointerCompare(Compare), Start);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1458; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArrayList.CustomPartialResort(Compare: TObjectCompareEx;
  Start: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1459 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  PartialResortArray(@FElementData[0], FSize, TPointerCompareEx(Compare), Start);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1459; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArrayList.CustomSort(Compare: TObjectCompare);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1460 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SortArray(@FElementData[0], FSize, TPointerCompare(Compare), shUnsorted);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1460; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArrayList.CustomSort(Compare: TObjectCompareEx);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1461 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SortArray(@FElementData[0], FSize, TPointerCompareEx(Compare), shUnsorted);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1461; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TArrayList.SubList(First, Count: Integer): IList;
var
  I: Integer;
  Last: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1462 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Last := First + Count - 1;
  if Last >= FSize then Last := FSize - 1;
  Result := TArrayList.Create(Count, FOwnsObjects);
  for I := First to Last do
  begin
    Result.Add(FElementData[I]);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1462; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

end.
