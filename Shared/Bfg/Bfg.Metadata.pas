{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{$I compiler.inc}
unit Bfg.Metadata;

interface

uses
  Bfg.Utils,
  TypInfo;
  
type
  TAllocCallback = procedure(Context: Pointer; Instance: Pointer); stdcall;
  TFreeCallback = procedure(Context: Pointer; Instance: Pointer); stdcall;

  IPropertyInfo = interface;

  PPropertyInfo = ^IPropertyInfo;

  ITypeInfo = interface(IInterface)
  ['{E782125A-472A-48F4-B010-FA44944E4EBB}']
    function GetTypeName: PChar; stdcall;
    function GetPropertyInfo(Index: Integer): IPropertyInfo; stdcall;
    function GetPropertyCount: Integer; stdcall;

    function ConstructorProc(Count: Integer; Callback: TAllocCallback; Context: Pointer): Pointer; stdcall;
    procedure DestructorProc(InstanceBlock: Pointer; Count: Integer; Callback: TFreeCallback; Context: Pointer); stdcall;
    function QueryInterfaceProc(Instance: Pointer; const IID: TGUID; out Intf): HRESULT; stdcall;

    procedure FindProperty(PropName: PChar; PropInfo: PPropertyInfo); stdcall;

    procedure SetOrdProp(PropName: PChar; Instance: Pointer; Value: Integer); stdcall;
    function GetOrdProp(PropName: PChar; Instance: Pointer): Integer; stdcall;

    procedure SetStrProp(PropName: PChar; Instance: Pointer; Value: PChar); stdcall;
    function GetStrProp(PropName: PChar; Instance: Pointer; Value: PChar; Len: Integer): Integer; stdcall;

    procedure SetWideStrProp(PropName: PChar; Instance: Pointer; Value: PWideChar); stdcall;
    function GetWideStrProp(PropName: PChar; Instance: Pointer; Value: PWideChar; Len: Integer): Integer; stdcall;

    procedure SetFloatProp(PropName: PChar; Instance: Pointer; Value: Single); stdcall;
    function GetFloatProp(PropName: PChar; Instance: Pointer): Single; stdcall;

    procedure SetObjProp(PropName: PChar; Instance: Pointer; Value: Pointer); stdcall;
    function GetObjProp(PropName: PChar; Instance: Pointer): Pointer; stdcall;

    procedure SetEnumProp(PropName: PChar; Instance: Pointer; Value: PChar); stdcall;
    function GetEnumProp(PropName: PChar; Instance: Pointer; Value: PChar; Len: Integer): Integer; stdcall;

    procedure SetFlagProp(PropName: PChar; Instance: Pointer; Value: PChar); stdcall;
    function GetFlagProp(PropName: PChar; Instance: Pointer; Value: PChar; Len: Integer; Bracketed: Boolean): Integer; stdcall;

    property TypeName: PChar read GetTypeName;
    property PropertyInfo[Index: Integer]: IPropertyInfo read GetPropertyInfo;
    property PropertCount: Integer read GetPropertyCount;
  end;

  IPropertyInfo = interface(IInterface)
  ['{0BC2162C-C7EA-48D3-AAB3-B76242B38EF4}']
    function GetName: PChar; stdcall;
    function GetPropType: Integer; stdcall;

    procedure SetOrdProp(Instance: Pointer; Value: Integer); stdcall;
    function GetOrdProp(Instance: Pointer): Integer; stdcall;

    procedure SetStrProp(Instance: Pointer; Value: PAnsiChar); stdcall;
    function GetStrProp(Instance: Pointer; Value: PAnsiChar; Len: Integer): Integer; stdcall;

    procedure SetWideStrProp(Instance: Pointer; Value: PWideChar); stdcall;
    function GetWideStrProp(Instance: Pointer; Value: PWideChar; Len: Integer): Integer; stdcall;

    procedure SetFloatProp(Instance: Pointer; Value: Single); stdcall;
    function GetFloatProp(Instance: Pointer): Single; stdcall;

    procedure SetObjProp(Instance: Pointer; Value: Pointer); stdcall;
    function GetObjProp(Instance: Pointer): Pointer; stdcall;

    procedure SetEnumProp(Instance: Pointer; Value: PAnsiChar); stdcall;
    function GetEnumProp(Instance: Pointer; Value: PAnsiChar; Len: Integer): Integer; stdcall;

    procedure SetFlagProp(Instance: Pointer; Value: PAnsiChar); stdcall;
    function GetFlagProp(Instance: Pointer; Value: PAnsiChar; Len: Integer; Bracketed: Boolean): Integer; stdcall;

    property Name: PChar read GetName;
    property PropType: Integer read GetPropType;
  end;

  IValueTypeInfo = interface(ITypeInfo)
  ['{CCA3CA6C-FA80-4E5D-A7F1-7556E4839852}']
    function GetSize: Longword; stdcall;
    function GetIdentifier: Longword; stdcall;

    property Size: Longword read GetSize;
    property Identifier: Longword read GetIdentifier;
  end;

  IEnumInfo = interface(IValueTypeInfo)
  ['{5EEE40D6-1284-439C-8011-132F0DB85F4E}']
    function GetEnumName(Index: Integer): PChar; stdcall;

    property EnumNames[Index: Integer]: PChar read GetEnumName;
  end;

  ISetTypeInfo = interface(IValueTypeInfo)
  ['{B8A30550-49C7-4115-9A66-12DBADC79B12}']
    function GetElementType: IEnumInfo; stdcall;

    property ElementType: IEnumInfo read GetElementType;
  end;

const
  METADATA_PROPTYPE_VOID     = 0;
  METADATA_PROPTYPE_INT      = 1;
  METADATA_PROPTYPE_FLOAT    = 2;
  METADATA_PROPTYPE_STRING   = 3;
  METADATA_PROPTYPE_WSTRING  = 4;
  METADATA_PROPTYPE_ENUM     = 5;
  METADATA_PROPTYPE_SET      = 6;

procedure CreateTypeInfoFromDelphiRTTI(Info: Pointer; out NewInfo: ITypeInfo;
  IncludeInheritedPublished: Boolean = True); stdcall;

implementation

uses
  SysUtils,
  RTLConsts,
  Classes,
  WideStrUtils;

type
  TPropertyInfo = class(TInterfacedObject, IPropertyInfo)
    private
      FInfo: PPropInfo;
      FName: string;
      FType: Integer;
    public
      constructor Create(PropInfo: PPropInfo);

      function GetName: PChar; stdcall;
      function GetPropType: Integer; stdcall;

      procedure SetOrdProp(Instance: Pointer; Value: Integer); stdcall;
      function GetOrdProp(Instance: Pointer): Integer; stdcall;

      procedure SetStrProp(Instance: Pointer; Value: PAnsiChar); stdcall;
      function GetStrProp(Instance: Pointer; Value: PAnsiChar; Len: Integer): Integer; stdcall;

      procedure SetWideStrProp(Instance: Pointer; Value: PWideChar); stdcall;
      function GetWideStrProp(Instance: Pointer; Value: PWideChar; Len: Integer): Integer; stdcall;

      procedure SetFloatProp(Instance: Pointer; Value: Single); stdcall;
      function GetFloatProp(Instance: Pointer): Single; stdcall;

      procedure SetObjProp(Instance: Pointer; Value: Pointer); stdcall;
      function GetObjProp(Instance: Pointer): Pointer; stdcall;

      procedure SetEnumProp(Instance: Pointer; Value: PAnsiChar); stdcall;
      function GetEnumProp(Instance: Pointer; Value: PAnsiChar; Len: Integer): Integer; stdcall;

      procedure SetFlagProp(Instance: Pointer; Value: PAnsiChar); stdcall;
      function GetFlagProp(Instance: Pointer; Value: PAnsiChar; Len: Integer; Bracketed: Boolean): Integer; stdcall;
  end;

  TClassTypeInfo = class(TInterfacedObject, ITypeInfo)
    private
      FName: string;
      FClassRef: TClass;
      FProperties: TStringList;
      procedure FindProperty(PropName: PChar; PropInfo: PPropertyInfo); stdcall;
      function FindProp(const Name: string): PPropInfo; inline;
    public
      constructor Create(Info: PTypeInfo; IncludeInherited: Boolean);
      destructor Destroy; override;

      function GetTypeName: PChar; stdcall;
      function GetPropertyInfo(Index: Integer): IPropertyInfo; stdcall;
      function GetPropertyCount: Integer; stdcall;

      function ConstructorProc(Count: Integer; Callback: TAllocCallback; Context: Pointer): Pointer; stdcall;
      procedure DestructorProc(InstanceBlock: Pointer; Count: Integer; Callback: TFreeCallback; Context: Pointer); stdcall;
      function QueryInterfaceProc(Instance: Pointer; const IID: TGUID; out Intf): HRESULT; stdcall;

      procedure SetOrdProp(PropName: PChar; Instance: Pointer; Value: Integer); stdcall;
      function GetOrdProp(PropName: PChar; Instance: Pointer): Integer; stdcall;

      procedure SetStrProp(PropName: PChar; Instance: Pointer; Value: PChar); stdcall;
      function GetStrProp(PropName: PChar; Instance: Pointer; Value: PChar; Len: Integer): Integer; stdcall;

      procedure SetWideStrProp(PropName: PChar; Instance: Pointer; Value: PWideChar); stdcall;
      function GetWideStrProp(PropName: PChar; Instance: Pointer; Value: PWideChar; Len: Integer): Integer; stdcall;

      procedure SetFloatProp(PropName: PChar; Instance: Pointer; Value: Single); stdcall;
      function GetFloatProp(PropName: PChar; Instance: Pointer): Single; stdcall;

      procedure SetObjProp(PropName: PChar; Instance: Pointer; Value: Pointer); stdcall;
      function GetObjProp(PropName: PChar; Instance: Pointer): Pointer; stdcall;

      procedure SetEnumProp(PropName: PChar; Instance: Pointer; Value: PChar); stdcall;
      function GetEnumProp(PropName: PChar; Instance: Pointer; Value: PChar; Len: Integer): Integer; stdcall;

      procedure SetFlagProp(PropName: PChar; Instance: Pointer; Value: PChar); stdcall;
      function GetFlagProp(PropName: PChar; Instance: Pointer; Value: PChar; Len: Integer; Bracketed: Boolean): Integer; stdcall;
  end;

procedure CreateTypeInfoFromDelphiRTTI(Info: Pointer; out NewInfo: ITypeInfo;
  IncludeInheritedPublished: Boolean);
begin
  if Info = nil then Exit;

  if PTypeInfo(Info)^.Kind = tkClass then
    NewInfo := TClassTypeInfo.Create(Info, IncludeInheritedPublished)
  else
    NewInfo := nil;
end;

{ TStructuredTypeInfo }

type
  PPropData = ^TPropData;

function GetClassPropData(Data: PTypeData): PPropData; inline;
var
  Len: Byte;
begin
  Len := Length(Data^.UnitName);
  Result := PPropData(Longword(@Data^.UnitName[1]) + Len);
end;

constructor TClassTypeInfo.Create(Info: PTypeInfo; IncludeInherited: Boolean);
var
  Data: PTypeData;
  PropList: PPropList;
  PropCount: Integer;
  PropData: PPropData;
  Prop: TPropertyInfo;
  I: Integer;
begin
  inherited Create;

  FProperties := TStringList.Create;
  FProperties.CaseSensitive := False;
  FName := Info^.Name;

  Data := GetTypeData(Info);
  FClassRef := Data.ClassType;
  PropData := GetClassPropData(Data);

  PropList := AllocMem(SizeOf(PPropInfo) * PropData^.PropCount);
  try
    PropCount := GetPropList(Info, [tkInteger, tkString, tkLString, tkChar, tkWChar,
      tkWString, tkEnumeration, tkSet, tkFloat, tkClass], PropList, False);

    for I := 0 to PropCount -1 do
    begin
      Prop := TPropertyInfo.Create(PropList^[I]);
      (Prop as IInterface)._AddRef;
      FProperties.AddObject(Prop.FName, Prop);
    end;

    FProperties.Sorted := True;
  finally
    FreeMem(PropList);
  end;
end;

destructor TClassTypeInfo.Destroy;
var
  I: Integer;
begin
  for I := 0 to FProperties.Count -1 do
  begin
    (TPropertyInfo(FProperties.Objects[I]) as IInterface)._Release;
  end;

  FProperties.Free;
  inherited Destroy;
end;

function TClassTypeInfo.ConstructorProc(Count: Integer;
  Callback: TAllocCallback; Context: Pointer): Pointer;
var
  S: Integer;
  I: Integer;
  P: Pointer;
begin
  Result := nil;
  if Count = 0 then Exit;

  S := FClassRef.InstanceSize;
  Result := AllocMem(S * Count);
  try
    P := Result;
    for I := 0 to Count -1 do
    begin
      FClassRef.InitInstance(P);
      if Assigned(Callback) then Callback(Context, P);
      Inc(PByte(P), S);
    end;
  except
    FreeMem(Result);
    raise;
  end;
end;

procedure Cleanup(Instance: TObject);
asm
  MOV   ECX, [EAX]
  XOR   DL, DL
  JMP   [ECX] + VMTOFFSET TObject.Destroy
end;

procedure TClassTypeInfo.DestructorProc(InstanceBlock: Pointer;
  Count: Integer; Callback: TFreeCallback; Context: Pointer);
var
  P: Pointer;
  I: Integer;
  S: Integer;
begin
  if (InstanceBlock = nil) or (Count = 0) then Exit;

  try
    S := FClassRef.InstanceSize;
    P := InstanceBlock;
    for I := 0 to Count -1 do
    begin
      if Assigned(Callback) then Callback(Context, P);
      Cleanup(P);
      Inc(PByte(P), S);
    end;
  finally
    FreeMem(InstanceBlock);
  end;
end;

function TClassTypeInfo.FindProp(const Name: string): PPropInfo;
var
  I: Integer;
begin
  if not FProperties.Find(Name, I) then raise Exception.Create('');
  Result := TPropertyInfo(FProperties.Objects[I]).FInfo;
end;

procedure TClassTypeInfo.FindProperty(PropName: PChar; PropInfo: PPropertyInfo);
var
  I: Integer;
begin
  if PropInfo = nil then Exit;

  if FProperties.Find(PropName, I) then
  begin
    PropInfo^ := TPropertyInfo(FProperties.Objects[I]) as IPropertyInfo;
  end else
  begin
    PropInfo^ := nil;
  end;
end;

function TClassTypeInfo.QueryInterfaceProc(Instance: Pointer;
  const IID: TGUID; out Intf): HRESULT;
begin
  if TObject(Instance).GetInterface(IID, Intf) then Result := S_OK else Result := E_NOINTERFACE;
end;

function TClassTypeInfo.GetEnumProp(PropName: PChar; Instance: Pointer;
  Value: PChar; Len: Integer): Integer;
var
  S: string;
begin
  S := TypInfo.GetEnumProp(TObject(Instance), FindProp(PropName));
  Result := Length(S);
  if (Value <> nil) and (Len >= Result) then StrPCopy(Value, S);
end;

function TClassTypeInfo.GetFloatProp(PropName: PChar;
  Instance: Pointer): Single;
begin
  Result := TypInfo.GetFloatProp(TObject(Instance), FindProp(PropName));
end;

function TClassTypeInfo.GetObjProp(PropName: PChar; Instance: Pointer): Pointer;
begin
  Result := Pointer(TypInfo.GetOrdProp(TObject(Instance), FindProp(PropName)));
end;

function TClassTypeInfo.GetOrdProp(PropName: PChar; Instance: Pointer): Integer;
begin
  Result := TypInfo.GetOrdProp(TObject(Instance), FindProp(PropName));
end;

function SetToStringCStyle(PropInfo: PPropInfo; Value: Integer): string;
var
  S: TIntegerSet;
  TypeInfo: PTypeInfo;
  I: Integer;
begin
  Result := '';
  Integer(S) := Value;
  TypeInfo := TypInfo.GetTypeData(PropInfo^.PropType^)^.CompType^;
  for I := 0 to SizeOf(Integer) * 8 - 1 do
  begin
    if I in S then
    begin
      if Result <> '' then
        Result := Result + ' | ';
      Result := Result + TypInfo.GetEnumName(TypeInfo, I);
    end;
  end;
end;

function TClassTypeInfo.GetFlagProp(PropName: PChar; Instance: Pointer;
  Value: PChar; Len: Integer; Bracketed: Boolean): Integer;
var
  S: string;
  Info: PPropInfo;
begin
  if Bracketed then
  begin
    S := TypInfo.GetSetProp(TObject(Instance), FindProp(PropName), True);
  end else
  begin
    Info := FindProp(PropName);
    S := SetToStringCStyle(Info, TypInfo.GetOrdProp(TObject(Instance), Info));
  end;
  Result := Length(S);
  if (Value <> nil) and (Len >= Result) then StrPCopy(Value, S);
end;

function TClassTypeInfo.GetStrProp(PropName: PChar; Instance: Pointer;
  Value: PChar; Len: Integer): Integer;
var
  S: string;
begin
  S := TypInfo.GetStrProp(TObject(Instance), FindProp(PropName));
  Result := Length(S);
  if (Value <> nil) and (Len >= Result) then StrPCopy(Value, S);
end;

function TClassTypeInfo.GetWideStrProp(PropName: PChar; Instance: Pointer;
  Value: PWideChar; Len: Integer): Integer;
var
  S: WideString;
begin
  S := TypInfo.GetWideStrProp(TObject(Instance), FindProp(PropName));
  Result := Length(S);
  if (Value <> nil) and (Len >= Result) then WStrPCopy(Value, S);
end;

procedure TClassTypeInfo.SetEnumProp(PropName: PChar; Instance: Pointer;
  Value: PChar);
begin
  TypInfo.SetEnumProp(TObject(Instance), FindProp(PropName), Value);
end;

procedure TClassTypeInfo.SetFloatProp(PropName: PChar; Instance: Pointer;
  Value: Single);
begin
  TypInfo.SetFloatProp(TObject(Instance), FindProp(PropName), Value);
end;

procedure TClassTypeInfo.SetObjProp(PropName: PChar; Instance, Value: Pointer);
begin
  TypInfo.SetOrdProp(TObject(Instance), FindProp(PropName), Integer(Value));
end;

procedure TClassTypeInfo.SetOrdProp(PropName: PChar; Instance: Pointer;
  Value: Integer);
begin
  TypInfo.SetOrdProp(TObject(Instance), FindProp(PropName), Value);
end;

function StringToSetEx(PropInfo: PPropInfo; Value: PChar): Integer;
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
    i := 0;

    // scan til whitespace
    while not (P[i] in [',', ' ', #0,']','|']) do
      Inc(i);

    SetString(Result, P, i);

    // skip whitespace
    while P[i] in [',', ' ',']','|'] do
      Inc(i);

    Inc(P, i);
  end;

begin
  Result := 0;
  if Value = nil then Exit;
  P := Value;

  // skip leading bracket and whitespace
  while P^ in ['[',' '] do
    Inc(P);

  EnumInfo := GetTypeData(PropInfo^.PropType^)^.CompType^;
  EnumName := NextWord(P);
  while EnumName <> '' do
  begin
    EnumValue := GetEnumValue(EnumInfo, EnumName);
    if EnumValue < 0 then
      raise EPropertyConvertError.CreateResFmt(@SInvalidPropertyElement, [EnumName]);
    Include(TIntegerSet(Result), EnumValue);
    EnumName := NextWord(P);
  end;
end;

procedure TClassTypeInfo.SetFlagProp(PropName: PChar; Instance: Pointer;
  Value: PChar);
var
  PropInfo: PPropInfo;
begin
  PropInfo := FindProp(PropName);
  TypInfo.SetOrdProp(TObject(Instance), PropInfo, StringToSetEx(PropInfo, Value));
end;

procedure TClassTypeInfo.SetStrProp(PropName: PChar; Instance: Pointer;
  Value: PChar);
begin
  TypInfo.SetStrProp(TObject(Instance), FindProp(PropName), Value);
end;

procedure TClassTypeInfo.SetWideStrProp(PropName: PChar; Instance: Pointer;
  Value: PWideChar);
begin
  TypInfo.SetWideStrProp(TObject(Instance), FindProp(PropName), Value);
end;

function TClassTypeInfo.GetPropertyCount: Integer;
begin
  Result := FProperties.Count;
end;

function TClassTypeInfo.GetPropertyInfo(Index: Integer): IPropertyInfo;
begin
  if (Index < 0) and (Index >= FProperties.Count) then
  begin
    Result := nil;
  end else Result := TPropertyInfo(FProperties.Objects[Index]) as IPropertyInfo;
end;

function TClassTypeInfo.GetTypeName: PChar;
begin
  Result := Pointer(FName);
end;

{ TPropertyInfo }

constructor TPropertyInfo.Create(PropInfo: PPropInfo);
begin
  inherited Create;

  FName := PropInfo.Name;
  FInfo := PropInfo;
  case FInfo^.PropType^^.Kind of
    tkInteger, tkChar, tkWChar: FType := METADATA_PROPTYPE_INT;
    tkFloat: FType := METADATA_PROPTYPE_FLOAT;
    tkString, tkLString: FType := METADATA_PROPTYPE_STRING;
    tkWString: FType := METADATA_PROPTYPE_WSTRING;
    tkClass: FType := METADATA_PROPTYPE_VOID;
    tkEnumeration: FType := METADATA_PROPTYPE_ENUM;
    tkSet: FType := METADATA_PROPTYPE_SET;
  end;
end;

function TPropertyInfo.GetName: PChar;
begin
  Result := Pointer(FName);
end;

function TPropertyInfo.GetPropType: Integer;
begin
  Result := FType;
end;

function TPropertyInfo.GetEnumProp(Instance: Pointer; Value: PAnsiChar;
  Len: Integer): Integer;
var
  S: string;
begin
  S := TypInfo.GetEnumProp(TObject(Instance), FInfo);
  Result := Length(S);
  if (Value <> nil) and (Len >= Result) then StrPCopy(Value, S);
end;

function TPropertyInfo.GetFlagProp(Instance: Pointer; Value: PAnsiChar;
  Len: Integer; Bracketed: Boolean): Integer;
var
  S: string;
begin
  if Bracketed then
  begin
    S := TypInfo.GetSetProp(TObject(Instance), FInfo, True);
  end else
  begin
    S := SetToStringCStyle(FInfo, TypInfo.GetOrdProp(TObject(Instance), FInfo));
  end;
  
  Result := Length(S);
  if (Value <> nil) and (Len >= Result) then StrPCopy(Value, S);
end;

function TPropertyInfo.GetFloatProp(Instance: Pointer): Single;
begin
  Result := TypInfo.GetFloatProp(TObject(Instance), FInfo);
end;

function TPropertyInfo.GetObjProp(Instance: Pointer): Pointer;
begin
  Result := TypInfo.GetObjectProp(TObject(Instance), FInfo);
end;

function TPropertyInfo.GetOrdProp(Instance: Pointer): Integer;
begin
  Result := TypInfo.GetOrdProp(TObject(Instance), FInfo);
end;

function TPropertyInfo.GetStrProp(Instance: Pointer; Value: PAnsiChar;
  Len: Integer): Integer;
var
  S: string;
begin
  S := TypInfo.GetStrProp(TObject(Instance), FInfo);
  Result := Length(S);
  if (Value <> nil) and (Len >= Result) then StrPCopy(Value, S);
end;

function TPropertyInfo.GetWideStrProp(Instance: Pointer; Value: PWideChar;
  Len: Integer): Integer;
var
  S: WideString;
begin
  S := TypInfo.GetWideStrProp(TObject(Instance), FInfo);
  Result := Length(S);
  if (Value <> nil) and (Len >= Result) then WStrPCopy(Value, S);
end;

procedure TPropertyInfo.SetEnumProp(Instance: Pointer; Value: PAnsiChar);
begin
  TypInfo.SetEnumProp(TObject(Instance), FInfo, Value);
end;

procedure TPropertyInfo.SetFlagProp(Instance: Pointer; Value: PAnsiChar);
begin
  TypInfo.SetOrdProp(TObject(Instance), FInfo, StringToSetEx(FInfo, Value));
end;

procedure TPropertyInfo.SetFloatProp(Instance: Pointer; Value: Single);
begin
  TypInfo.SetFloatProp(TObject(Instance), FInfo, Value);
end;

procedure TPropertyInfo.SetObjProp(Instance, Value: Pointer);
begin
  TypInfo.SetObjectProp(TObject(Instance), FInfo, TObject(Value));
end;

procedure TPropertyInfo.SetOrdProp(Instance: Pointer; Value: Integer);
begin
  TypInfo.SetOrdProp(TObject(Instance), FInfo, Value);
end;

procedure TPropertyInfo.SetStrProp(Instance: Pointer; Value: PAnsiChar);
begin
  TypInfo.SetStrProp(TObject(Instance), FInfo, Value);
end;

procedure TPropertyInfo.SetWideStrProp(Instance: Pointer; Value: PWideChar);
begin
  TypInfo.SetWideStrProp(TObject(Instance), FInfo, Value);
end;

end.
