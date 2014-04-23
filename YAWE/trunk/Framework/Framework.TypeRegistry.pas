{*------------------------------------------------------------------------------
  A registry which stores RTTI-ex of types. Types can be added also at runtime.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Framework.TypeRegistry;

interface

uses
  Misc.Miscleanous,
  Misc.Containers,
  Misc.TypInfoEx,
  SysUtils,
  TypInfo,
  Framework.Base;

type
  ITypeInfo = interface;

  TTypeRegistry = class(TBaseInterfacedObject)
    private
      fTypeDefs: TStrPtrHashMap;
      fTypeList: TArrayList;

      procedure RegisterDefaultTypes;
      function CreateTypeInfoEx(InfoPtr: PPTypeInfo; out InfoEx: ITypeInfo): Boolean;
    public
      constructor Create;
      destructor Destroy; override;

      { Registers a new type given by its typeinfo. In this case the actual
        user of the data gathered here will have additional info available about
        these types. }
      function RegisterType(Info: PTypeInfo): ITypeInfo;

      { Registers an alias for the specified type. }
      function RegisterTypeAlias(const Name: string; const Alias: string): ITypeInfo;

      function GetTypeInfo(const TypeName: string): ITypeInfo;
  end;

  ITypeInfo = interface(IInterface)
  ['{E7712D2C-F7E8-450B-9CA7-CF7B8962260B}']
    { private }
    function GetName: string;
    function GetKind: TTypeKind;
    function GetSize: UInt32;
    function GetModule: string;
    function GetInfo: PTypeInfo;

    { public }
    property RttiType: TTypeKind read GetKind;
    property Name: string read GetName;
    property Size: UInt32 read GetSize;
    property ModuleName: string read GetModule;
    property Info: PTypeInfo read GetInfo;
  end;

  IOrdinalTypeInfo = interface(ITypeInfo)
  ['{AF47D23F-E1EA-46BA-8C43-9D0D9E9D87C9}']
    { private }
    function GetOrdinalType: TOrdType;

    { public }
    property OrdinalType: TOrdType read GetOrdinalType;
  end;

  IIntegerTypeInfo = interface(IOrdinalTypeInfo)
  ['{108CB21C-5730-497F-B374-33DF260A551C}']
    { private }
    function GetMin: Int32;
    function GetMax: Int32;

    { public }
    property MaxValue: Int32 read GetMax;
    property MinValue: Int32 read GetMin;
  end;

  IInt64TypeInfo = interface(ITypeInfo)
  ['{BD3C1CAA-FA4D-40BD-A947-C1C7B8DAB756}']
    { private }
    function GetMin: Int64;
    function GetMax: Int64;

    { public }
    property MaxValue: Int64 read GetMax;
    property MinValue: Int64 read GetMin;
  end;

  IEnumerationTypeInfo = interface(IOrdinalTypeInfo)
  ['{BEADE592-12A2-45C0-8F4A-1F433760E6CB}']
    { private }
    function GetEnumName(Index: Int32): string;
    function GetEnumValue(const Index: string): Int32;
    function GetNameCount: Int32;

    { public }
    property Names[Index: Int32]: string read GetEnumName;
    property Value[const Index: string]: Int32 read GetEnumValue;
    property NameCount: Int32 read GetNameCount;
  end;

  ISetTypeInfo = interface(IOrdinalTypeInfo)
  ['{C7FDD08C-0901-49AD-B311-EBA8804F02BA}']
    { private }
    function GetElemInfo: IIntegerTypeInfo;

    { public }
    procedure StringToSet(const Str: string; out SetData);
    procedure SetToString(const SetData; out Str: string);

    property ElementInfo: IIntegerTypeInfo read GetElemInfo;
  end;

  IRecordTypeInfo = interface(ITypeInfo)
  ['{1F528752-D7B8-44F3-8CA8-9435D52EFE0B}']
    { private }
    function GetFieldInfo(Index: Int32): ITypeInfo;
    function GetFieldOffset(Index: Int32): UInt32;
    function GetFieldCount: Int32;

    { public }
    property Fields[Index: Int32]: ITypeInfo read GetFieldInfo;
    property FieldOffsets[Index: Int32]: UInt32 read GetFieldOffset;
    property FieldCount: Int32 read GetFieldCount;
  end;

  IArrayTypeInfo = interface(ITypeInfo)
  ['{12542EF1-5E02-41E5-BC4F-314728FE9F92}']
    { private }
    function GetElemInfo: ITypeInfo;

    { public }
    property ElementInfo: ITypeInfo read GetElemInfo;
  end;

  IStaticArrayTypeInfo = interface(IArrayTypeInfo)
  ['{00ED4DD0-AA05-42E5-A28B-AEC6E20FF9DD}']
    { private }
    function GetElemCount: UInt32;

    { public }
    property ElementCount: UInt32 read GetElemCount;
  end;

  IStringTypeInfo = interface(ITypeInfo)
  ['{8818013A-2A38-47DE-9903-25D5A0584F74}']
    { private }
    function GetMaxLen: Int32;

    { public }
    property MaxLength: Int32 read GetMaxLen;
  end;

  IFloatTypeInfo = interface(ITypeInfo)
  ['{11BF2C97-9976-4A96-B871-25D6CFA1C072}']
    { private }
    function GetFloatType: TFloatType;

    { public }
    property FloatType: TFloatType read GetFloatType;
  end;

  TPropertyAccessor = (paGetter, paSetter, paStored);
  TPropertyAccessType = (patUnknown, patField, patMethod, patIndexedMethod);

  IPropertyInfo = interface(IInterface)
  ['{E9DC7D6E-931D-4BD1-95C2-C19984AED841}']
    { private }
    function GetDataType: ITypeInfo;
    function GetName: string;
    function GetDefault: Int32;
    function GetIndex: Int32;
    function GetPropInfo: PPropInfo;

    { public }
    function GetPropertyAccessor(Accessor: TPropertyAccessor; Instance: TObject;
      out AccessorPtr: Pointer): TPropertyAccessType;

    property PropertyType: ITypeInfo read GetDataType;
    property Name: string read GetName;
    property Index: Int32 read GetIndex;
    property DefaultValue: Int32 read GetDefault;
    property PropInfo: PPropInfo read GetPropInfo;
  end;

  IInterfaceTypeInfo = interface(ITypeInfo)
  ['{18ECE195-DE0C-4DD5-B781-9BD3D45BA40B}']
    { private }
    function GetGUID: TGUID;
    function GetFlags: TIntfFlags;
    function GetParent: IInterfaceTypeInfo;

    { public }
    property ParentType: IInterfaceTypeInfo read GetParent;
    property Flags: TIntfFlags read GetFlags;
    property GUID: TGUID read GetGUID;
  end;

  IClassTypeInfo = interface(ITypeInfo)
  ['{B9FDAE96-6E58-4DD3-881D-72878C569A9D}']
    { private }
    function GetPropInfo(Index: Int32): IPropertyInfo;
    function GetPropCount: Int32;
    function GetParent: IClassTypeInfo;
    function GetClassType: TClass;

    { public }
    function GetPropByName(const Name: string): IPropertyInfo;

    property ParentType: IClassTypeInfo read GetParent;
    property ClassReference: TClass read GetClassType;
    property Properties[Index: Int32]: IPropertyInfo read GetPropInfo;
    property PropertyCount: Int32 read GetPropCount;
  end;

implementation

uses
  Misc.Algorithm,
  Misc.Resources;

type
  PByteSet = ^TByteSet;
  TByteSet = set of Byte;

  TTypeInfo = class(TBaseInterfacedObject, ITypeInfo)
    private
      fTypeName: string;
      fModuleName: string;
      fKind: TTypeKind;

      function GetName: string;
      function GetKind: TTypeKind;
      function GetSize: UInt32;
      function GetModule: string;
      function GetInfo: PTypeInfo;
    protected
      fTypeSize: UInt32;
      fRawInfo: PTypeInfo;
      fTypeData: Pointer;
    public
      constructor Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo); virtual;

      property RttiType: TTypeKind read GetKind;
      property Name: string read GetName;
      property Size: UInt32 read GetSize;
      property ModuleName: string read GetModule;
      property Info: PTypeInfo read GetInfo;
  end;

  TTypeInfoClass = class of TTypeInfo;

  TOrdinalTypeInfo = class(TTypeInfo, ITypeInfo, IOrdinalTypeInfo)
    private
      fOrdinalType: TOrdType;

      function GetOrdinalType: TOrdType;
    public
      constructor Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo); override;

      property OrdinalType: TOrdType read GetOrdinalType;
  end;

  TIntegerTypeInfo = class(TOrdinalTypeInfo, ITypeInfo, IOrdinalTypeInfo, IIntegerTypeInfo)
    private
      fMaxValue: Int32;
      fMinValue: Int32;

      function GetMin: Int32;
      function GetMax: Int32;
    public
      constructor Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo); override;

      property MaxValue: Int32 read GetMax;
      property MinValue: Int32 read GetMin;
  end;

  TInt64TypeInfo = class(TOrdinalTypeInfo, ITypeInfo, IInt64TypeInfo)
    private
      fMaxValue: Int64;
      fMinValue: Int64;

      function GetMin: Int64;
      function GetMax: Int64;
    public
      constructor Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo); override;

      property MaxValue: Int64 read GetMax;
      property MinValue: Int64 read GetMin;
  end;

  TEnumerationTypeInfo = class(TIntegerTypeInfo, ITypeInfo, IOrdinalTypeInfo,
    IIntegerTypeInfo, IEnumerationTypeInfo)
    private
      fNames: array of string;
      fNameCount: Int32;

      function GetEnumName(Index: Int32): string;
      function GetEnumValue(const Index: string): Int32;
      function GetNameCount: Int32;
    public
      constructor Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo); override;

      property Names[Index: Int32]: string read GetEnumName;
      property Value[const Index: string]: Int32 read GetEnumValue;
      property NameCount: Int32 read GetNameCount;
  end;

  TSetTypeInfo = class(TOrdinalTypeInfo, ITypeInfo, IOrdinalTypeInfo, ISetTypeInfo)
    private
      fElementType: TIntegerTypeInfo;

      function GetElemInfo: IIntegerTypeInfo;
    public
      constructor Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo); override;

      procedure StringToSet(const Str: string; out SetData);
      procedure SetToString(const SetData; out Str: string);

      property ElementInfo: IIntegerTypeInfo read GetElemInfo;
  end;

  TRecordTypeInfo = class(TTypeInfo, ITypeInfo, IRecordTypeInfo)
    private
      fFields: array of TTypeInfo;
      fFieldOffsets: array of UInt32;
      fFieldCount: Int32;

      function GetFieldInfo(Index: Int32): ITypeInfo;
      function GetFieldOffset(Index: Int32): UInt32;
      function GetFieldCount: Int32;
    public
      constructor Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo); override;

      property Fields[Index: Int32]: ITypeInfo read GetFieldInfo;
      property FieldOffsets[Index: Int32]: UInt32 read GetFieldOffset;
      property FieldCount: Int32 read GetFieldCount;
  end;

  TArrayTypeInfo = class(TTypeInfo, ITypeInfo, IArrayTypeInfo)
    private
      function GetElemInfo: ITypeInfo;
    protected
      fElementType: TTypeInfo;
    public
      property ElementInfo: ITypeInfo read GetElemInfo;
  end;

  TDynamicArrayTypeInfo = class(TArrayTypeInfo, ITypeInfo, IArrayTypeInfo)
    public
      constructor Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo); override;
  end;


  TStaticArrayTypeInfo = class(TArrayTypeInfo, ITypeInfo, IArrayTypeInfo,
    IStaticArrayTypeInfo)
    private
      fElementCount: UInt32;

      function GetElemCount: UInt32;
    public
      constructor Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo); override;

      property ElementCount: UInt32 read GetElemCount;
  end;

  TStringTypeInfo = class(TTypeInfo, ITypeInfo, IStringTypeInfo)
    private
      fMaxLength: Int32;

      function GetMaxLen: Int32;
    public
      constructor Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo); override;

      property MaxLength: Int32 read GetMaxLen;
  end;

  TFloatTypeInfo = class(TTypeInfo, ITypeInfo, IFloatTypeInfo)
    private
      fFloatType: TFloatType;
      function GetFloatType: TFloatType;
    public
      constructor Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo); override;

      property FloatType: TFloatType read GetFloatType;
  end;

  TPropertyInfo = class(TBaseInterfacedObject, IPropertyInfo)
    private
      fPropInfo: PPropInfo;
      fName: string;
      fDataType: TTypeInfo;
      fGetter: Pointer;
      fSetter: Pointer;
      fStored: Pointer;
      fDefault: Int32;
      fIndex: Int32;

      function GetDataType: ITypeInfo;
      function GetName: string;
      function GetDefault: Int32;
      function GetIndex: Int32;
      function GetPropInfo: PPropInfo;
    public
      constructor Create(Registry: TTypeRegistry; PropInfo: PPropInfo); overload;
      constructor Create(Info: TPropertyInfo); overload;

      function GetPropertyAccessor(Accessor: TPropertyAccessor; Instance: TObject;
        out AccessorPtr: Pointer): TPropertyAccessType;

      property PropertyType: ITypeInfo read GetDataType;
      property Name: string read GetName;
      property Index: Int32 read GetIndex;
      property DefaultValue: Int32 read GetDefault;
      property PropInfo: PPropInfo read GetPropInfo;
  end;

  TInterfaceTypeInfo = class(TTypeInfo, ITypeInfo, IInterfaceTypeInfo)
    private
      fParentType: TInterfaceTypeInfo;
      fFlags: TIntfFlags;
      fGUID: TGuid;

      function GetGUID: TGUID;
      function GetFlags: TIntfFlags;
      function GetParent: IInterfaceTypeInfo;
    public
      constructor Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo); override;

      property ParentType: IInterfaceTypeInfo read GetParent;
      property Flags: TIntfFlags read GetFlags;
      property GUID: TGUID read GetGUID;
  end;

  TClassTypeInfo = class(TTypeInfo, ITypeInfo, IClassTypeInfo)
    private
      fParentType: TClassTypeInfo;
      fClassType: TClass;
      fInstanceSize: Int32;
      fProperties: array of TPropertyInfo;
      fPropertiesSorted: array of TPropertyInfo;
      fPropCount: Int32;
      fMyPropCount: Int32;

      function GetPropInfo(Index: Int32): IPropertyInfo;
      function GetPropCount: Int32;
      function GetParent: IClassTypeInfo;
      function GetClassType: TClass;
    public
      constructor Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo); override;
      destructor Destroy; override;

      function GetPropByName(const Name: string): IPropertyInfo;

      property ParentType: IClassTypeInfo read GetParent;
      property ClassReference: TClass read GetClassType;
      property Properties[Index: Int32]: IPropertyInfo read GetPropInfo;
      property PropertyCount: Int32 read GetPropCount;
  end;

{ TTypeRegistry }

function TTypeRegistry.CreateTypeInfoEx(InfoPtr: PPTypeInfo; out InfoEx: ITypeInfo): Boolean;
const
  TypeInfoTable: array[TTypeKind] of TTypeInfoClass = (
    TTypeInfo,
    TIntegerTypeInfo,
    TIntegerTypeInfo,
    TEnumerationTypeInfo,
    TFloatTypeInfo,
    TStringTypeInfo,
    TSetTypeInfo,
    TClassTypeInfo,
    TTypeInfo, { Method info - unused atm }
    TIntegerTypeInfo,
    TStringTypeInfo,
    TStringTypeInfo,
    TTypeInfo, { Variant? }
    TStaticArrayTypeInfo,
    TRecordTypeInfo,
    TInterfaceTypeInfo,
    TIntegerTypeInfo,
    TDynamicArrayTypeInfo
  );
var
  cInfo: TTypeInfo;
begin
  if InfoPtr = nil then
  begin
    InfoEx := nil;
    Result := False;
    Exit;
  end;

  cInfo := fTypeDefs.GetValue(InfoPtr^.Name);
  if cInfo <> nil then
  begin
    InfoEx := cInfo as ITypeInfo;
    Result := False;
    Exit;
  end;

  cInfo := TypeInfoTable[InfoPtr^.Kind].Create(Self, InfoPtr^);
  fTypeList.Add(cInfo);
  fTypeDefs.PutValue(cInfo.Name, cInfo);
  InfoEx := cInfo as ITypeInfo;

  Result := True;
end;

constructor TTypeRegistry.Create;
begin
  inherited Create;
  fTypeDefs := TStrPtrHashMap.Create(True, 512);
  fTypeList := TArrayList.Create(1024, True);
  RegisterDefaultTypes;
end;

procedure TTypeRegistry.RegisterDefaultTypes;
begin
  { String and char types}
  RegisterType(TypeInfo(string));
  RegisterType(TypeInfo(WideString));
  RegisterType(TypeInfo(ShortString));
  RegisterType(TypeInfo(Char));
  RegisterType(TypeInfo(WideChar));

  { Boolean types }
  RegisterType(TypeInfo(Boolean));
  RegisterType(TypeInfo(ByteBool));
  RegisterType(TypeInfo(WordBool));
  RegisterType(TypeInfo(LongBool));

  { Integer types }
  RegisterType(TypeInfo(Byte));
  RegisterType(TypeInfo(Shortint));
  RegisterType(TypeInfo(Word));
  RegisterType(TypeInfo(Smallint));
  RegisterType(TypeInfo(Integer));
  RegisterType(TypeInfo(Longword));
  RegisterType(TypeInfo(Int64));

  { FP types }
  RegisterType(TypeInfo(Single));
  RegisterType(TypeInfo(Double));
  RegisterType(TypeInfo(Extended));
  RegisterType(TypeInfo(Comp));
  RegisterType(TypeInfo(Currency));

  { Dynamic array types }
  RegisterType(TypeInfo(TBooleanDynArray));
  RegisterType(TypeInfo(TByteDynArray));
  RegisterType(TypeInfo(TWordDynArray));
  RegisterType(TypeInfo(TLongWordDynArray));
  RegisterType(TypeInfo(TInt64DynArray));
  RegisterType(TypeInfo(TQuadwordDynArray));
  RegisterType(TypeInfo(TSingleDynArray));
  RegisterType(TypeInfo(TDoubleDynArray));
  RegisterType(TypeInfo(TExtendedDynArray));
  RegisterType(TypeInfo(TStringDynArray));

  { Class and interface types }
  RegisterType(TypeInfo(TObject));
  RegisterType(TypeInfo(TInterfacedObject));
  RegisterType(TypeInfo(IInterface));
  RegisterType(TypeInfo(TBaseObject));
  RegisterType(TypeInfo(TBaseInterfacedObject));
  RegisterType(TypeInfo(TBaseReferencedObject));

  { Aliases }
  RegisterTypeAlias(SString, SAnsiString);
  RegisterTypeAlias(SChar, SAnsiChar);
  RegisterTypeAlias(SPChar, SCString);
  RegisterTypeAlias(SInteger, SInt32);
  RegisterTypeAlias(SCardinal, SLongword);
  RegisterTypeAlias(SCardinal, SUInt32);
  RegisterTypeAlias(SSingle, SFloat);
  RegisterTypeAlias(SInt64, SUInt64);
  RegisterTypeAlias(SInt64, SQuadword);
  RegisterTypeAlias(SSmallInt, SInt16);
  RegisterTypeAlias(SWord, SUInt16);
  RegisterTypeAlias(SShortInt, SInt8);
  RegisterTypeAlias(SByte, SUInt8);
end;

destructor TTypeRegistry.Destroy;
begin
  fTypeList.Free;
  fTypeDefs.Free;
  inherited Destroy;
end;

function TTypeRegistry.GetTypeInfo(const TypeName: string): ITypeInfo;
begin
  Result := TTypeInfo(fTypeDefs.GetValue(TypeName)) as ITypeInfo;
end;

function TTypeRegistry.RegisterType(Info: PTypeInfo): ITypeInfo;
var
  cType: TTypeInfo;
begin
  if Info = nil then Exit;
  
  cType := fTypeDefs.GetValue(Info^.Name);
  if not Assigned(cType) then
  begin
    CreateTypeInfoEx(@Info, Result);
  end else Result := cType as ITypeInfo;
end;

function TTypeRegistry.RegisterTypeAlias(const Name, Alias: string): ITypeInfo;
var
  cType: TTypeInfo;
begin
  if not fTypeDefs.ContainsKey(Alias) then
  begin
    cType := fTypeDefs.GetValue(Name);
    if cType <> nil then
    begin
      fTypeDefs.PutValue(Alias, cType);
    end;
    Result := cType as ITypeInfo;
  end else Result := nil;
end;

{ TTypeInfo }

constructor TTypeInfo.Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo);
begin
  inherited Create;
  
  if TypeInfo = nil then Exit;
  fRawInfo := TypeInfo;
  fTypeData := GetTypeData(TypeInfo);
  fTypeName := TypeInfo^.Name;
  fModuleName := GetModuleName(FindHInstance(TypeInfo));
  fKind := TypeInfo^.Kind;
end;

function TTypeInfo.GetInfo: PTypeInfo;
begin
  Result := fRawInfo;
end;

function TTypeInfo.GetKind: TTypeKind;
begin
  Result := fKind;
end;

function TTypeInfo.GetModule: string;
begin
  Result := fModuleName;
end;

function TTypeInfo.GetName: string;
begin
  Result := fTypeName;
end;

function TTypeInfo.GetSize: UInt32;
begin
  Result := fTypeSize;
end;

{ TOrdinalTypeInfo }

constructor TOrdinalTypeInfo.Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo);
type
  POrdType = ^TOrdType;
begin
  inherited Create(Registry, TypeInfo);

  fOrdinalType := POrdType(fTypeData)^;
  case fOrdinalType of
    otSByte, otUByte: fTypeSize := SizeOf(Byte);
    otSWord, otUWord: fTypeSize := SizeOf(Word);
    otSLong, otULong: fTypeSize := SizeOf(Longword);
  end;
end;

function TOrdinalTypeInfo.GetOrdinalType: TOrdType;
begin
  Result := fOrdinalType;
end;

{ TIntegerTypeInfo }

constructor TIntegerTypeInfo.Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo);
begin
  inherited Create(Registry, TypeInfo);

  fMaxValue := PIntegerTypeInfo(fTypeData)^.MaxValue;
  fMinValue := PIntegerTypeInfo(fTypeData)^.MinValue;
end;

function TIntegerTypeInfo.GetMax: Int32;
begin
  Result := fMaxValue;
end;

function TIntegerTypeInfo.GetMin: Int32;
begin
  Result := fMinValue;
end;

{ TInt64TypeInfo }

constructor TInt64TypeInfo.Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo);
begin
  inherited Create(Registry, TypeInfo);

  fMaxValue := PInt64TypeInfo(fTypeData)^.MaxValue;
  fMinValue := PInt64TypeInfo(fTypeData)^.MinValue;
end;

function TInt64TypeInfo.GetMax: Int64;
begin
  Result := fMaxValue;
end;

function TInt64TypeInfo.GetMin: Int64;
begin
  Result := fMinValue;
end;

{ TEnumerationTypeInfo }

constructor TEnumerationTypeInfo.Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo);
var
  pEnumData: PEnumInfo;
  pStr: PShortString;
  iInt: Int32;
begin
  inherited Create(Registry, TypeInfo);

  pEnumData := fTypeData;

  if StringsEqualNoCase(pEnumData^.BaseType^^.Name, 'Boolean') or
     StringsEqualNoCase(pEnumData^.BaseType^^.Name, 'ByteBool') or
     StringsEqualNoCase(pEnumData^.BaseType^^.Name, 'WordBool') or
     StringsEqualNoCase(pEnumData^.BaseType^^.Name, 'LongBool') then
  begin
    SetLength(fNames, 2);
    fNames[0] := 'False';
    fNames[1] := 'True';
    fNameCount := 2;
  end else
  begin
    pStr := @pEnumData^.NameList[0];
    fNameCount := fMaxValue - fMinValue + 1;
    SetLength(fNames, fNameCount);
    for iInt := 0 to fNameCount -1 do
    begin
      fNames[iInt] := pStr^;
      Inc(PByte(pStr), Ord(pStr^[0]) + 1);
    end;
  end;
end;

function TEnumerationTypeInfo.GetEnumValue(const Index: string): Int32;
var
  iIdx: Int32;
begin
  for iIdx := 0 to fNameCount -1 do
  begin
    if StringsEqual(fNames[iIdx], Index) then
    begin
      Result := iIdx;
      Exit;
    end;
  end;
  Result := 0;
end;

function TEnumerationTypeInfo.GetNameCount: Int32;
begin
  Result := fNameCount;
end;

function TEnumerationTypeInfo.GetEnumName(Index: Int32): string;
begin
  if (Index < 0) or (Index >= fNameCount) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  Result := fNames[Index];
end;

{ TSetTypeInfo }

constructor TSetTypeInfo.Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo);
var
  ifDummy: ITypeInfo;
begin
  inherited Create(Registry, TypeInfo);

  Registry.CreateTypeInfoEx(PSetInfo(fTypeData)^.CompType, ifDummy);
  fElementType := GetImplementorOfInterface(ifDummy);
  fTypeSize := DivModInc(fElementType.MaxValue - fElementType.MinValue, BITS_PER_BYTE);
end;

function TSetTypeInfo.GetElemInfo: IIntegerTypeInfo;
begin
  Result := fElementType as IIntegerTypeInfo;
end;

procedure TSetTypeInfo.SetToString(const SetData; out Str: string);
var
  S: TByteSet;
  I: Integer;
  TP: PTypeInfo;
begin
  Str := '';
  FillChar(S, SizeOf(S), 0);
  Move(SetData, S, fTypeSize);
  TP := fElementType.fRawInfo;
  for I := 0 to (fTypeSize * BITS_PER_BYTE) -1 do
  begin
    if I in S then
    begin
      if Str <> '' then
      begin
        Str := Str + ',' + GetEnumName(TP, I);
      end else
      begin
        Str := GetEnumName(TP, I);
      end;
    end;
  end;
  Str := '[' + Str + ']';
end;

// grab the next enum name
function NextWord(var P: PChar): string; inline;
var
  I: Integer;
begin
  I := 0;

  // scan til whitespace
  while not (P[I] in [',', ' ', #0,']']) do
  begin
    Inc(I);
  end;

  SetString(Result, P, I);

  // skip whitespace
  while P[I] in [',', ' ',']'] do
  begin
    Inc(I);
  end;

  Inc(P, I);
end;

procedure TSetTypeInfo.StringToSet(const Str: string; out SetData);
var
  P: PChar;
  EnumName: string;
  EnumValue: Integer;
  TP: PTypeInfo;
begin
  if Str = '' then
  begin
    FillChar(SetData, fTypeSize, 0);
    Exit;
  end;

  P := PChar(Str);

  // skip leading bracket and whitespace
  while P^ in ['[',' '] do
  begin
    Inc(P);
  end;

  TP := fElementType.fRawInfo;
  EnumName := NextWord(P);
  while EnumName <> '' do
  begin
    EnumValue := GetEnumValue(TP, EnumName);
    Include(PByteSet(@SetData)^, EnumValue);
    EnumName := NextWord(P);
  end;
end;

{ TRecordTypeInfo }

constructor TRecordTypeInfo.Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo);
var
  pFieldInfo: PRecordFieldInfo;
  iIdx: Int32;
  ifDummy: ITypeInfo;
begin
  inherited Create(Registry, TypeInfo);

  Dec(PByte(fTypeData), 2);
  fTypeSize := PRecordInfo(fTypeData)^.Size;
  pFieldInfo := GetRecordFieldInfoList(fTypeData);
  fFieldCount := PRecordInfo(fTypeData)^.FieldCount;
  SetLength(fFields, fFieldCount);
  SetLength(fFieldOffsets, fFieldCount);
  for iIdx := 0 to fFieldCount -1 do
  begin
    fFieldOffsets[iIdx] := pFieldInfo^.Offset;
    Registry.CreateTypeInfoEx(pFieldInfo^.FieldInfo, ifDummy);
    fFields[iIdx] := GetImplementorOfInterface(ifDummy);
    Inc(pFieldInfo);
  end;
end;

function TRecordTypeInfo.GetFieldCount: Int32;
begin
  Result := fFieldCount;
end;

function TRecordTypeInfo.GetFieldInfo(Index: Int32): ITypeInfo;
begin
  if (Index < 0) or (Index >= fFieldCount) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  Result := fFields[Index] as ITypeInfo;
end;

function TRecordTypeInfo.GetFieldOffset(Index: Int32): UInt32;
begin
  if (Index < 0) or (Index >= fFieldCount) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  Result := fFieldOffsets[Index];
end;

{ TStringTypeInfo }

constructor TStringTypeInfo.Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo);
begin
  inherited Create(Registry, TypeInfo);
  case fKind of    
    tkString:
    begin
      fMaxLength := PByte(fTypeData)^;
      fTypeSize := 1 + fMaxLength;
    end;
    tkLString:
    begin
      fMaxLength := MAXINT;
      fTypeSize := SizeOf(string);
    end;
    tkWString:
    begin
      fMaxLength := -1;
      fTypeSize := SizeOf(WideString);
    end;
  end;
end;

function TStringTypeInfo.GetMaxLen: Int32;
begin
  Result := fMaxLength;
end;

{ TStaticArrayTypeInfo }

constructor TStaticArrayTypeInfo.Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo);
var
  ifDummy: ITypeInfo;
begin
  inherited Create(Registry, TypeInfo);
  fTypeSize := PStaticArrayInfo(fTypeData)^.ArraySize;
  fElementCount := PStaticArrayInfo(fTypeData)^.ElemCount;
  Registry.CreateTypeInfoEx(PStaticArrayInfo(fTypeData)^.ElemInfo, ifDummy);
  fElementType := GetImplementorOfInterface(ifDummy);
end;

function TStaticArrayTypeInfo.GetElemCount: UInt32;
begin
  Result := fElementCount;
end;

{ TDynamicArrayTypeInfo }

constructor TDynamicArrayTypeInfo.Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo);
var
  ifDummy: ITypeInfo;
begin
  inherited Create(Registry, TypeInfo);
  fTypeSize := SizeOf(Pointer);
  Registry.CreateTypeInfoEx(PDynArrayInfo(fTypeData)^.ElemType, ifDummy);
  fElementType := GetImplementorOfInterface(ifDummy);
end;

{ TFloatTypeInfo }

constructor TFloatTypeInfo.Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo);
type
  PFloatType = ^TFloatType;
begin
  inherited Create(Registry, TypeInfo);
  fFloatType := PFloatType(fTypeData)^;
  case fFloatType of
    ftSingle: fTypeSize := SizeOf(Single);
    ftDouble: fTypeSize := SizeOf(Double);
    ftExtended: fTypeSize := SizeOf(Extended);
    ftComp: fTypeSize := SizeOf(Comp);
    ftCurr: fTypeSize := SizeOf(Currency);
  end;
end;

function TFloatTypeInfo.GetFloatType: TFloatType;
begin
  Result := fFloatType;
end;

{ TPropertyInfo }

constructor TPropertyInfo.Create(Registry: TTypeRegistry; PropInfo: PPropInfo);
var
  ifDummy: ITypeInfo;
begin
  inherited Create;

  fPropInfo := PropInfo;
  Registry.CreateTypeInfoEx(fPropInfo^.PropType, ifDummy);
  fDataType := GetImplementorOfInterface(ifDummy);
  fGetter := fPropInfo^.GetProc;
  fSetter := fPropInfo^.SetProc;
  fStored := fPropInfo^.StoredProc;
  fIndex := fPropInfo^.Index;
  fDefault := fPropInfo^.Default;
  fName := fPropInfo^.Name;
end;

constructor TPropertyInfo.Create(Info: TPropertyInfo);
begin
  inherited Create;

  fPropInfo := Info.fPropInfo;
  fDataType := Info.fDataType;
  fGetter := Info.fGetter;
  fSetter := Info.fSetter;
  fStored := Info.fStored;
  fIndex := Info.fIndex;
  fDefault := Info.fDefault;
  fName := Info.fName;
end;

function TPropertyInfo.GetDataType: ITypeInfo;
begin
  Result := fDataType as ITypeInfo;
end;

function TPropertyInfo.GetDefault: Int32;
begin
  Result := fDefault;
end;

function TPropertyInfo.GetIndex: Int32;
begin
  Result := fIndex;
end;

function TPropertyInfo.GetName: string;
begin
  Result := fName;
end;

function TPropertyInfo.GetPropertyAccessor(Accessor: TPropertyAccessor;
  Instance: TObject; out AccessorPtr: Pointer): TPropertyAccessType;
var
  AccessorValue: Int32;
  V: Int32;
begin
  case Accessor of
    paGetter: AccessorValue := Int32(fGetter);
    paSetter: AccessorValue := Int32(fSetter);
    paStored: AccessorValue := Int32(fStored);
  else
    begin
      Result := patUnknown;
      Exit;
    end;
  end;

  V := AccessorValue shr 24;
  if V = $FF then
  begin  // field - Getter is the field's offset in the instance data
    AccessorPtr := Pointer(Integer(Instance) + (AccessorValue and $00FFFFFF));
    Result := patField;
  end else
  begin
    if V = $FE then
    begin
      // virtual method  - Getter is a signed 2 byte integer VMT offset
      AccessorPtr := Pointer(PInteger(PInteger(Instance)^ + SmallInt(AccessorValue))^)
    end else
    begin
      // static method - Getter is the actual address
      AccessorPtr := Pointer(AccessorValue);
    end;

    if fIndex = Integer($80000000) then  // no index
    begin
      Result := patMethod;
    end else
    begin
      Result := patIndexedMethod;
    end;
  end;
end;

function TPropertyInfo.GetPropInfo: PPropInfo;
begin
  Result := fPropInfo;
end;

{ TClassTypeInfo }

function CompareProps(P1, P2: TPropertyInfo): Integer;
begin
  Result := StringsCompare(P1.Name, P2.Name);
end;

function MatchProp(const S: string; P: TPropertyInfo): Integer;
begin
  Result := StringsCompare(S, P.Name);
end;

constructor TClassTypeInfo.Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo);
var
  iIdx: Int32;
  pProps: PPropInfo;
  ifDummy: ITypeInfo;
begin
  inherited Create(Registry, TypeInfo);

  fTypeSize := SizeOf(TClass);
  fClassType := PClassInfo(fTypeData)^.ClassType;
  Registry.CreateTypeInfoEx(PClassInfo(fTypeData)^.ParentInfo, ifDummy);
  fParentType := GetImplementorOfInterface(ifDummy);
  fInstanceSize := fClassType.InstanceSize;
  fPropCount := PClassInfo(fTypeData)^.PropCount;
  if Assigned(fParentType) then
  begin
    fMyPropCount := fPropCount - fParentType.fPropCount;
  end else
  begin
    fMyPropCount := fPropCount;
  end;

  SetLength(fProperties, fPropCount);
  SetLength(fPropertiesSorted, fPropCount);
  pProps := GetClassPropData(fTypeData);

  for iIdx := 0 to fPropCount - fMyPropCount - 1 do
  begin
    fProperties[iIdx] := TPropertyInfo.Create(fParentType.fProperties[iIdx]);
    fPropertiesSorted[iIdx] := fProperties[iIdx];
  end;

  for iIdx := fPropCount - fMyPropCount to fPropCount - 1 do
  begin
    fProperties[iIdx] := TPropertyInfo.Create(Registry, pProps);
    fPropertiesSorted[iIdx] := fProperties[iIdx];
    pProps := PPropInfo(UInt32(@pProps^.Name) + Length(pProps^.Name) + 1);
  end;

  SortArray(@fPropertiesSorted[0], fPropCount, @CompareProps, shUnsorted);
end;

destructor TClassTypeInfo.Destroy;
var
  iIdx: Int32;
begin
  for iIdx := 0 to fPropCount - 1 do
  begin
    fProperties[iIdx].Free;
  end;

  inherited Destroy;
end;

function TClassTypeInfo.GetClassType: TClass;
begin
  Result := fClassType;
end;

function TClassTypeInfo.GetParent: IClassTypeInfo;
begin
  Result := fParentType as IClassTypeInfo;
end;

function TClassTypeInfo.GetPropByName(const Name: string): IPropertyInfo;
var
  I: Int32;
begin
  I := BinarySearch(Pointer(Name), @fPropertiesSorted[0], fPropCount, @MatchProp);
  if I <> -1 then
  begin
    Result := fPropertiesSorted[I] as IPropertyInfo;
  end else Result := nil;
end;

function TClassTypeInfo.GetPropCount: Int32;
begin
  Result := fPropCount;
end;

function TClassTypeInfo.GetPropInfo(Index: Int32): IPropertyInfo;
begin
  if (Index < 0) or (Index >= fPropCount) then
  begin
    raise EOutOfBounds.CreateResFmt(@RsOutOfBounds, [Index]);
  end;
  Result := fProperties[Index] as IPropertyInfo;
end;

{ TInterfaceTypeInfo }

constructor TInterfaceTypeInfo.Create(Registry: TTypeRegistry; TypeInfo: PTypeInfo);
var
  ifDummy: ITypeInfo;
begin
  inherited Create(Registry, TypeInfo);

  fTypeSize := SizeOf(IInterface);
  Registry.CreateTypeInfoEx(PInterfaceInfo(fTypeData)^.Parent, ifDummy);
  fParentType := GetImplementorOfInterface(ifDummy);
  fGUID := PInterfaceInfo(fTypeData)^.GUID;
  fFlags := PInterfaceInfo(fTypeData)^.Flags;
end;

function TInterfaceTypeInfo.GetFlags: TIntfFlags;
begin
  Result := fFlags;
end;

function TInterfaceTypeInfo.GetGUID: TGUID;
begin
  Result := fGUID;
end;

function TInterfaceTypeInfo.GetParent: IInterfaceTypeInfo;
begin
  Result := fParentType as IInterfaceTypeInfo;
end;

{ TArrayTypeInfo }

function TArrayTypeInfo.GetElemInfo: ITypeInfo;
begin
  Result := fElementType as ITypeInfo;
end;

end.
