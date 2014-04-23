{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Container Interfaces
  
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
unit Bfg.Containers.Interfaces;

interface

uses
  Bfg.Algorithm{$IFDEF THREAD_SAFETY}, Bfg.Threads{$ENDIF}{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

type
  ILockable = interface(IInterface)
  ['{687DF963-19B5-4237-99D2-75E2DCEC23E7}']
    procedure Lock;
    procedure Unlock;
  end;

  {$IFDEF THREAD_SAFETY}
  IAbstractContainer = ILockable;
  {$ELSE}
  IAbstractContainer = IInterface;
  {$ENDIF}

  ICloneable = interface(IInterface)
  ['{D224AE70-2C93-4998-9479-1D513D75F2B2}']
    function Clone: TObject;
  end;

  IStrIterator = interface(IInterface)
  ['{D5D4B681-F902-49C7-B9E1-73007C9D64F0}']
    function GetString: string;
    function HasNext: Boolean;
    function HasPrevious: Boolean;
    function Next: string;
    function Previous: string;
  end;

  IIntIterator = interface(IInterface)
  ['{2BD01251-33B2-4E88-81B1-3E918D0EDB1D}']
    function GetInt: Integer;
    function HasNext: Boolean;
    function HasPrevious: Boolean;
    function Next: Integer;
    function Previous: Integer;
  end;

  IPtrIterator = interface(IInterface)
  ['{E4292B86-E4A7-4A22-B47C-8106204A6522}']
    function GetPtr: Pointer;
    function HasNext: Boolean;
    function HasPrevious: Boolean;
    function Next: Pointer;
    function Previous: Pointer;
  end;

  IIntfIterator = interface(IInterface)
  ['{1E68FCBE-94FA-4BF9-A58F-F707470C89C1}']
    function GetIntf: IInterface;
    function HasNext: Boolean;
    function HasPrevious: Boolean;
    function Next: IInterface;
    function Previous: IInterface;
  end;

  IIterator = interface(IInterface)
  ['{997DF9B7-9AA2-4239-8B94-14DFFD26D790}']
    function GetObject: TObject;
    function HasNext: Boolean;
    function HasPrevious: Boolean;
    function Next: TObject;
    function Previous: TObject;
  end;

  IStrCollection = interface(IAbstractContainer)
  ['{3E3CFC19-E8AF-4DD7-91FA-2DF2895FC7B9}']
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
  end;

  IIntCollection = interface(IAbstractContainer)
  ['{FEC97D92-0206-45EA-A3D1-C581FC184FA1}']
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
  end;

  IPtrCollection = interface(IAbstractContainer)
  ['{A8625A7B-A3F6-42B4-9895-99EC92CFEA34}']
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
  end;

  ICollection = interface(IAbstractContainer)
  ['{58947EF1-CD21-4DD1-AE3D-225C3AAD7EE5}']
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
  end;

  IIntfCollection = interface(IAbstractContainer)
  ['{E2A852A9-5EC9-47BA-B6F2-E0C0A6A01B30}']
    function Add(const AIntf: IInterface): Boolean;
    procedure AddAll(const ACollection: IIntfCollection);
    procedure Clear;
    function Contains(const AIntf: IInterface): Boolean;
    function ContainsAll(const ACollection: IIntfCollection): Boolean;
    function Equals(const ACollection: IIntfCollection): Boolean;
    function First: IIntfIterator;
    function IsEmpty: Boolean;
    function Last: IIntfIterator;
    function Remove(const AIntf: IInterface): Boolean;
    procedure RemoveAll(const ACollection: IIntfCollection);
    procedure RetainAll(const ACollection: IIntfCollection);
    function Size: Integer;
  end;

  IStrList = interface(IStrCollection)
  ['{07DD7644-EAC6-4059-99FC-BEB7FBB73186}']
    { private }
    function GetSorted: Boolean;
    procedure SetSorted(AValue: Boolean);
    function GetString(Index: Integer): string;
    procedure SetString(Index: Integer; const AString: string);

    { public }
    procedure Insert(Index: Integer; const AString: string); overload;
    procedure InsertAll(Index: Integer; const ACollection: IStrCollection); overload;
    function IndexOf(const AString: string): Integer;
    function CustomIndexOf(const AString: string; Compare: TStringCompareEx): Integer;
    function Remove(Index: Integer): string; overload;
    function SubList(First, Count: Integer): IStrList;
    procedure Sort;
    procedure CustomSort(Compare: TStringCompareEx);
    procedure PartialResort(Start: Integer);
    procedure CustomPartialResort(Compare: TStringCompareEx; Start: Integer);

    property Items[Index: Integer]: string read GetString write SetString; default;
    property Sorted: Boolean read GetSorted write SetSorted;
  end;

  IIntList = interface(IIntCollection)
  ['{8298C67B-E9ED-4393-A2DF-3BB3CAA99221}']
    { private }
    function GetSorted: Boolean;
    procedure SetSorted(AValue: Boolean);
    procedure SetInt(Index: Integer; AInt: Integer);
    function GetInt(Index: Integer): Integer;

    { public }
    procedure Insert(Index: Integer; AInt: Integer); overload;
    procedure InsertAll(Index: Integer; const ACollection: IIntCollection); overload;
    function IndexOf(AInt: Integer): Integer;
    function CustomIndexOf(AInt: Integer; Compare: TIntegerCompareEx): Integer;
    function RemoveFromIndex(Index: Integer): Integer; overload;
    function SubList(First, Count: Integer): IIntList;
    procedure Sort;
    procedure CustomSort(Compare: TIntegerCompareEx);
    procedure PartialResort(Start: Integer);
    procedure CustomPartialResort(Compare: TIntegerCompareEx; Start: Integer);

    property Items[Index: Integer]: Integer read GetInt write SetInt; default;
    property Sorted: Boolean read GetSorted write SetSorted;
  end;

  IPtrList = interface(IPtrCollection)
  ['{4C2E9045-D0DF-409D-BEAC-1AF62E2A4E8B}']
    { private }
    function GetSorted: Boolean;
    procedure SetSorted(AValue: Boolean);
    procedure SetPtr(Index: Integer; APtr: Pointer);
    function GetPtr(Index: Integer): Pointer;

    { public }
    procedure Insert(Index: Integer; APtr: Pointer); overload;
    procedure InsertAll(Index: Integer; const ACollection: IPtrCollection); overload;
    function IndexOf(APtr: Pointer): Integer;
    function CustomIndexOf(APtr: Pointer; Compare: TPointerCompareEx): Integer;
    function Remove(Index: Integer): Pointer; overload;
    function SubList(First, Count: Integer): IPtrList;
    procedure Sort;
    procedure CustomSort(Compare: TPointerCompareEx);
    procedure PartialResort(Start: Integer);
    procedure CustomPartialResort(Compare: TPointerCompareEx; Start: Integer);

    property Items[Index: Integer]: Pointer read GetPtr write SetPtr; default;
    property Sorted: Boolean read GetSorted write SetSorted;
  end;

  IIntfList = interface(IIntfCollection)
  ['{157F970F-94A1-48C3-A0A6-FEC0A3701DFE}']
    { private }
    function GetSorted: Boolean;
    procedure SetSorted(AValue: Boolean);
    function GetIntf(Index: Integer): IInterface;
    procedure SetIntf(Index: Integer; const AIntf: IInterface);

    { public }
    procedure Insert(Index: Integer; const AIntf: IInterface); overload;
    procedure InsertAll(Index: Integer; const ACollection: IIntfCollection); overload;
    function IndexOf(const AIntf: IInterface): Integer;
    function CustomIndexOf(const AIntf: IInterface; Compare: TInterfaceCompareEx): Integer;
    function Remove(Index: Integer): IInterface; overload;
    function SubList(First, Count: Integer): IIntfList;
    procedure Sort;
    procedure CustomSort(Compare: TInterfaceCompareEx);
    procedure PartialResort(Start: Integer);
    procedure CustomPartialResort(Compare: TInterfaceCompareEx; Start: Integer);

    property Items[Index: Integer]: IInterface read GetIntf write SetIntf; default;
    property Sorted: Boolean read GetSorted write SetSorted;
  end;

  IList = interface(ICollection)
  ['{8ABC70AC-5C06-43EA-AFE0-D066379BCC28}']
    { private }
    function GetSorted: Boolean;
    procedure SetSorted(AValue: Boolean);
    function GetObject(Index: Integer): TObject;
    procedure SetObject(Index: Integer; AObject: TObject);

    { public }
    procedure Insert(Index: Integer; AObject: TObject); overload;
    procedure InsertAll(Index: Integer; const ACollection: ICollection); overload;
    function IndexOf(AObject: TObject): Integer;
    function CustomIndexOf(AObject: TObject; Compare: TObjectCompareEx): Integer;
    function Remove(Index: Integer): TObject; overload;
    function SubList(First, Count: Integer): IList;
    procedure Sort;
    procedure CustomSort(Compare: TObjectCompareEx);
    procedure PartialResort(Start: Integer);
    procedure CustomPartialResort(Compare: TObjectCompareEx; Start: Integer);

    property Items[Index: Integer]: TObject read GetObject write SetObject; default;
    property Sorted: Boolean read GetSorted write SetSorted;
  end;

  IStrSet = interface(IStrCollection)
  ['{72204D85-2B68-4914-B9F2-09E5180C12E9}']
    procedure Intersect(const ACollection: IStrCollection);
    procedure Subtract(const ACollection: IStrCollection);
    procedure Union(const ACollection: IStrCollection);
  end;

  IIntSet = interface(IIntCollection)
  ['{48AA58C7-3CDB-4D38-B605-2790A8A35403}']
    procedure Intersect(const ACollection: IIntCollection);
    procedure Subtract(const ACollection: IIntCollection);
    procedure Union(const ACollection: IIntCollection);
  end;

  IPtrSet = interface(IPtrCollection)
  ['{54BF965E-8261-4852-BD8C-74368AF78567}']
    procedure Intersect(const ACollection: IPtrCollection);
    procedure Subtract(const ACollection: IPtrCollection);
    procedure Union(const ACollection: IPtrCollection);
  end;

  IIntfSet = interface(IIntfCollection)
  ['{9D0B8820-9BD9-44B5-89EF-9BE6738FDC48}']
    procedure Intersect(const ACollection: IIntfCollection);
    procedure Subtract(const ACollection: IIntfCollection);
    procedure Union(const ACollection: IIntfCollection);
  end;

  ISet = interface(ICollection)
  ['{0B7CDB90-8588-4260-A54C-D87101C669EA}']
    procedure Intersect(const ACollection: ICollection);
    procedure Subtract(const ACollection: ICollection);
    procedure Union(const ACollection: ICollection);
  end;

  IStrMap = interface(IAbstractContainer)
  ['{A7D0A882-6952-496D-A258-23D47DDCCBC4}']
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
    function GetCaseSensitivity: Boolean;
    property CaseSensitive: Boolean read GetCaseSensitivity;
  end;

  IStrIntfMap = interface(IAbstractContainer)
  ['{B71B9A02-036B-4154-8513-9A0A4D7D94D0}']
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
    function GetCaseSensitivity: Boolean;
    property CaseSensitive: Boolean read GetCaseSensitivity;
  end;

  IStrStrMap = interface(IAbstractContainer)
  ['{047BD297-01C8-4685-B1A0-DC86477FD9B3}']
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
    function GetCaseSensitivity: Boolean;
    property CaseSensitive: Boolean read GetCaseSensitivity;
  end;

  IStrIntMap = interface(IAbstractContainer)
  ['{15C0BA74-C39C-4E2A-9FC0-464F885CE7FF}']
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
    function GetCaseSensitivity: Boolean;
    property CaseSensitive: Boolean read GetCaseSensitivity;
  end;

  IStrPtrMap = interface(IAbstractContainer)
  ['{047BD297-01C8-4685-B1A0-DC86477FD9B3}']
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
    function GetCaseSensitivity: Boolean;
    property CaseSensitive: Boolean read GetCaseSensitivity;
  end;

  IIntMap = interface(IAbstractContainer)
  ['{B4C88E02-7A1E-479D-99E7-2033EDF1C21E}']
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
  end;

  IIntIntfMap = interface(IAbstractContainer)
  ['{D1B00D0E-35F9-4617-87B0-2EE5E8DE7ED5}']
    procedure Clear;
    function ContainsKey(Key: Integer): Boolean;
    function ContainsValue(const Value: IInterface): Boolean;
    function Equals(const AMap: IIntIntfMap): Boolean;
    function GetValue(Key: Integer): IInterface;
    function IsEmpty: Boolean;
    function KeySet: IIntIterator;
    procedure PutAll(const AMap: IIntIntfMap);
    procedure PutValue(Key: Integer; const Value: IInterface);
    function Remove(Key: Integer): IInterface;
    function Size: Integer;
    function Values: IIntfIterator;
  end;

  IIntIntMap = interface(IAbstractContainer)
  ['{9EA12C79-92F9-4F70-8A02-B8185A77E2DD}']
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
  end;

  IIntPtrMap = interface(IAbstractContainer)
  ['{7AA58678-8FEF-481D-9222-7B640DF6D164}']
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
  end;

  IPtrPtrMap = interface(IAbstractContainer)
  ['{5C7B8B48-842C-4920-8DAD-9A434CE95127}']
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
  end;

  IMap = interface(IAbstractContainer)
  ['{62142145-011A-43C0-8F03-D13BFAC4C680}']
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
  end;

  IIntfIntfMap = interface(IAbstractContainer)
  ['{071C524C-6DEF-4402-9A24-B82A3FAB898C}']
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
  end;

  TTraverseOrder = (toPreOrder, toOrder, toPostOrder);

  IIntfTree = interface(IIntfCollection)
    ['{5A21688F-113D-41B4-A17C-54BDB0BD6559}']
    function GetTraverseOrder: TTraverseOrder;
    procedure SetTraverseOrder(Value: TTraverseOrder);
    property TraverseOrder: TTraverseOrder read GetTraverseOrder write SetTraverseOrder;
  end;

  IStrTree = interface(IStrCollection)
    ['{1E1896C0-0497-47DF-83AF-A9422084636C}']
    function GetTraverseOrder: TTraverseOrder;
    procedure SetTraverseOrder(Value: TTraverseOrder);
    property TraverseOrder: TTraverseOrder read GetTraverseOrder write SetTraverseOrder;
  end;

  IPtrTree = interface(IPtrCollection)
  ['{B50D6ECD-F2C7-4061-8399-91737E2526E7}']
    function GetTraverseOrder: TTraverseOrder;
    procedure SetTraverseOrder(Value: TTraverseOrder);
    property TraverseOrder: TTraverseOrder read GetTraverseOrder write SetTraverseOrder;
  end;

  ITree = interface(ICollection)
    ['{B0C658CC-FEF5-4178-A4C5-442C0DEDE207}']
    function GetTraverseOrder: TTraverseOrder;
    procedure SetTraverseOrder(Value: TTraverseOrder);
    property TraverseOrder: TTraverseOrder read GetTraverseOrder write SetTraverseOrder;
  end;

  IIntfQueue = interface(IInterface)
    ['{B88756FE-5553-4106-957E-3E33120BFA99}']
    function Contains(const AInterface: IInterface): Boolean;
    function Dequeue: IInterface;
    function Empty: Boolean;
    procedure Enqueue(const AInterface: IInterface);
    function Size: Integer;
  end;

  IStrQueue = interface(IInterface)
    ['{5BA0ED9A-5AF3-4F79-9D80-34FA7FF15D1F}']
    function Contains(const AString: string): Boolean;
    function Dequeue: string;
    function Empty: Boolean;
    procedure Enqueue(const AString: string);
    function Size: Integer;
  end;

  IPtrQueue = interface(IInterface)
  ['{BC39B96A-0964-4F9E-87F3-5B9D72FE6D26}']
    function Contains(APtr: Pointer): Boolean;
    function Dequeue: Pointer;
    function Empty: Boolean;
    procedure Enqueue(APtr: Pointer);
    function Size: Integer;
  end;

  IQueue = interface(IInterface)
    ['{7D0F9DE4-71EA-46EF-B879-88BCFD5D9610}']
    function Contains(AObject: TObject): Boolean;
    function Dequeue: TObject;
    function Empty: Boolean;
    procedure Enqueue(AObject: TObject);
    function Size: Integer;
  end;

  IIntfStack = interface(IInterface)
    ['{CA1DC7A1-8D8F-4A5D-81D1-0FE32E9A4E84}']
    function Contains(const AInterface: IInterface): Boolean;
    function Empty: Boolean;
    function Pop: IInterface;
    procedure Push(const AInterface: IInterface);
    function Size: Integer;
  end;

  IStrStack = interface(IInterface)
    ['{649BB74C-D7BE-40D9-9F4E-32DDC3F13F3B}']
    function Contains(const AString: string): Boolean;
    function Empty: Boolean;
    function Pop: string;
    procedure Push(const AString: string);
    function Size: Integer;
  end;

  IPtrStack = interface(IInterface)
    ['{AAA4BB77-6701-46EE-AF0F-EBF5DBF159F8}']
    function Contains(APtr: Pointer): Boolean;
    function Empty: Boolean;
    function Pop: Pointer;
    procedure Push(APtr: Pointer);
    function Size: Integer;
  end;

  IStack = interface(IInterface)
    ['{E07E0BD8-A831-41B9-B9A0-7199BD4873B9}']
    function Contains(AObject: TObject): Boolean;
    function Empty: Boolean;
    function Pop: TObject;
    procedure Push(AObject: TObject);
    function Size: Integer;
  end;

  {$IFDEF THREAD_SAFETY}
  TAbstractContainer = class(TInterfacedObject, IAbstractContainer)
    private
      FLock: TCriticalSection;
    public
      constructor Create;
      destructor Destroy; override;
      procedure Lock;
      procedure Unlock;
  end;
  {$ELSE}
  TAbstractContainer = class(TInterfacedObject, IAbstractContainer);
  {$ENDIF}

implementation

{$IFDEF THREAD_SAFETY}

{ TAbstractContainer }

constructor TAbstractContainer.Create;
begin
  inherited Create;
  FLock.Init;
end;

destructor TAbstractContainer.Destroy;
begin
  FLock.Delete;
  inherited Destroy;
end;

procedure TAbstractContainer.Lock;
begin
  FLock.Enter;
end;

procedure TAbstractContainer.Unlock;
begin
  FLock.Release;
end;
{$ENDIF}

end.
