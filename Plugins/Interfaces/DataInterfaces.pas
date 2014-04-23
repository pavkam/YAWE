{$WEAKPACKAGEUNIT}
unit DataInterfaces;

interface

const
  COMPARE_OP_LE    = 0; // Lesser
  COMPARE_OP_LEQ   = 1; // Lesser of equal
  COMPARE_OP_EQ    = 2; // Equal
  COMPARE_OP_NEQ   = 3; // Not equal
  COMPARE_OP_GEQ   = 4; // Greater or equal
  COMPARE_OP_GE    = 5; // Greater

type
  TAllocCallback = procedure(Context: Pointer; Instance: Pointer); stdcall;
  TFreeCallback = procedure(Context: Pointer; Instance: Pointer); stdcall;

  IPropertyInfo = interface;

  ITypeInfo = interface(IInterface)
  ['{E782125A-472A-48F4-B010-FA44944E4EBB}']
    function GetTypeName: PAnsiChar; stdcall;
    function GetPropertyInfo(Index: Integer): IPropertyInfo; stdcall;
    function GetPropertyCount: Integer; stdcall;

    function ConstructorProc(Count: Integer; Callback: TAllocCallback; Context: Pointer): Pointer; stdcall;
    procedure DestructorProc(InstanceBlock: Pointer; Count: Integer; Callback: TFreeCallback; Context: Pointer); stdcall;
    function QueryInterfaceProc(Instance: Pointer; const IID: TGUID; out Intf): HRESULT; stdcall;

    procedure FindProperty(PropName: PAnsiChar; out PropInfo: IPropertyInfo); stdcall;

    procedure SetOrdProp(PropName: PAnsiChar; Instance: Pointer; Value: Integer); stdcall;
    function GetOrdProp(PropName: PAnsiChar; Instance: Pointer): Integer; stdcall;

    procedure SetStrProp(PropName: PAnsiChar; Instance: Pointer; Value: PAnsiChar); stdcall;
    function GetStrProp(PropName: PAnsiChar; Instance: Pointer; Value: PAnsiChar; Len: Integer): Integer; stdcall;

    procedure SetWideStrProp(PropName: PAnsiChar; Instance: Pointer; Value: PWideChar); stdcall;
    function GetWideStrProp(PropName: PAnsiChar; Instance: Pointer; Value: PWideChar; Len: Integer): Integer; stdcall;

    procedure SetFloatProp(PropName: PAnsiChar; Instance: Pointer; Value: Single); stdcall;
    function GetFloatProp(PropName: PAnsiChar; Instance: Pointer): Single; stdcall;

    procedure SetObjProp(PropName: PAnsiChar; Instance: Pointer; Value: Pointer); stdcall;
    function GetObjProp(PropName: PAnsiChar; Instance: Pointer): Pointer; stdcall;

    procedure SetEnumProp(PropName: PAnsiChar; Instance: Pointer; Value: PAnsiChar); stdcall;
    function GetEnumProp(PropName: PAnsiChar; Instance: Pointer; Value: PAnsiChar; Len: Integer): Integer; stdcall;

    procedure SetFlagProp(PropName: PAnsiChar; Instance: Pointer; Value: PAnsiChar); stdcall;
    function GetFlagProp(PropName: PAnsiChar; Instance: Pointer; Value: PAnsiChar; Len: Integer; Bracketed: Boolean): Integer; stdcall;

    property TypeName: PAnsiChar read GetTypeName;
    property PropertyInfo[Index: Integer]: IPropertyInfo read GetPropertyInfo;
    property PropertyCount: Integer read GetPropertyCount;
  end;

  IPropertyInfo = interface(IInterface)
  ['{0BC2162C-C7EA-48D3-AAB3-B76242B38EF4}']
    function GetName: PAnsiChar; stdcall;
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

    property Name: PAnsiChar read GetName;
    property PropType: Integer read GetPropType;
  end;

const
  METADATA_PROPTYPE_VOID     = 0;
  METADATA_PROPTYPE_INT      = 1;
  METADATA_PROPTYPE_FLOAT    = 2;
  METADATA_PROPTYPE_STRING   = 3;
  METADATA_PROPTYPE_WSTRING  = 4;
  METADATA_PROPTYPE_ENUM     = 5;
  METADATA_PROPTYPE_FLAGS    = 6;

type
  IYesSerializable = interface;
  PYesSerializable = ^IYesSerializable;

  Int32 = Integer;
  Int16 = SmallInt;
  Int8 = Shortint;
  UInt8 = Byte;
  UInt16 = Word;
  UInt32 = Longword;
  UInt64 = Int64;
  PInt32 = PInteger;
  PUInt32 = PLongword;
  PUInt64 = PInt64;
  Float = Single;
  
  IDofReader = interface;
  IDofWriter = interface;

  IDofStreamable = interface(IInterface)
  ['{93749366-EA8A-4291-8A05-1812084F478D}']
    procedure ReadCustomProperties(const Reader: IDofReader); stdcall;
    procedure WriteCustomProperties(const Writer: IDofWriter); stdcall;
  end;

  YDofReaderMethod = procedure(const Reader: IDofReader) of object; stdcall;
  YDofWriterMethod = procedure(const Writer: IDofWriter) of object; stdcall;

  IDofReader = interface(IInterface)
  ['{ECE8A058-1761-416D-84BB-167E4E24DB94}']
    function ReadCustomProperty(PropName: PAnsiChar; Length: Integer; Reader: YDofReaderMethod): Boolean; stdcall;
    function ReadBinarySize: Integer; stdcall;
    procedure ReadBinary(Buf: Pointer); stdcall;
    function ReadQuad: UInt64; stdcall;
    function ReadLong: UInt32; stdcall;
    function ReadWord: UInt16; stdcall;
    function ReadByte: UInt8; stdcall;
    function ReadSingle: Single; stdcall;
    function ReadDouble: Double; stdcall;
    function ReadExtended: Extended; stdcall;
    function ReadStringLen: Integer; stdcall;
    procedure ReadStringA(Dest: PAnsiChar); stdcall;
    procedure ReadStringW(Dest: PWideChar); stdcall;
    procedure ReadClass(Instance: Pointer; const Info: ITypeInfo); stdcall;
    procedure ReadListStart; stdcall;
    procedure ReadListEnd; stdcall;
    procedure ReadCollectionStart; stdcall;
    procedure ReadCollectionEnd; stdcall;
    procedure ReadCollectionItemStart; stdcall;
    procedure ReadCollectionItemEnd; stdcall;

    function IsListEnd: Boolean; stdcall;
    function IsCollectionEnd: Boolean; stdcall;
  end;

  IDofWriter = interface(IInterface)
  ['{C3D897E3-7244-4879-831B-15E20FCA8A75}']
    procedure WriteCustomProperty(PropName: PAnsiChar; Length: Integer; Writer: YDofWriterMethod); stdcall;
    procedure WriteBinary(Buf: Pointer; Size: Integer); stdcall;
    procedure WriteQuad(Value: UInt64); stdcall;
    procedure WriteLong(Value: UInt32); stdcall;
    procedure WriteWord(Value: UInt16); stdcall;
    procedure WriteByte(Value: UInt8); stdcall;
    procedure WriteSingle(const Value: Single); stdcall;
    procedure WriteDouble(const Value: Double); stdcall;
    procedure WriteExtended(const Value: Extended); stdcall;
    procedure WriteStringA(Value: PAnsiChar; Length: Integer); stdcall;
    procedure WriteStringW(Value: PWideChar; Length: Integer); stdcall;
    procedure WriteClass(Instance: Pointer; const Info: ITypeInfo); stdcall;
    procedure WriteListStart; stdcall;
    procedure WriteListEnd; stdcall;
    procedure WriteCollectionStart; stdcall;
    procedure WriteCollectionEnd; stdcall;
    procedure WriteCollectionItemStart; stdcall;
    procedure WriteCollectionItemEnd; stdcall;
  end;

  IYesSerializableDynArray = array of IYesSerializable;

  IYesSerializable = interface(IInterface)
  ['{A32B47E4-47A5-4824-8296-81EC2DC26D86}']
    { private }
    function GetUniqueId: Longword; stdcall;
    procedure SetUniqueId(NewId: Longword); stdcall;
    function GetContext(Name: PAnsiChar): IDofStreamable; stdcall;
    procedure SetContext(Name: PAnsiChar; const Value: IDofStreamable); stdcall;
    function GetStorageContext: Pointer; stdcall;
    procedure SetStorageContext(Value: Pointer); stdcall;

    { public }
    procedure Initialize; stdcall;
    procedure Clear; stdcall;
    procedure Assign(const Entry: IYesSerializable); stdcall;

    property UniqueId: Longword read GetUniqueId write SetUniqueId;
    property Context[Name: PAnsiChar]: IDofStreamable read GetContext write SetContext;
    property StorageContext: Pointer read GetStorageContext write SetStorageContext;
  end;

  IYesSerializable2 = interface(IYesSerializable)
  ['{A32B47E4-47A5-4824-8778-81EC2DC26D86}']
    procedure AfterLoad; stdcall;
    procedure BeforeSave; stdcall;
  end;

  PYesLookupResult = ^IYesLookupResult;
  IYesLookupResult = interface(IInterface)
  ['{37D64B59-60A3-4805-9090-B30447420F63}']
    function GetEntryCount: Integer; stdcall;

    function GetData(Entries: PPointer; Count: Integer): Integer; stdcall;
    function GetDataEx(Entries: PPointer; Count: Integer; AsTypeIID: PGUID): Integer; stdcall;

    property EntryCount: Integer read GetEntryCount;
  end;

  TCompareOp = COMPARE_OP_LE..COMPARE_OP_GE;

  YES_COMPARE_CALLBACK = function(Context: Pointer; Item1, Item2: Pointer): Integer; stdcall;
  YES_PREDICATE_CALLBACK = function(Context: Pointer; Item: Pointer): Boolean; stdcall;

  IYesStorageMedium = interface(IInterface)
  ['{77DF05B5-001A-4651-83E3-EF84D5B444D2}']
    procedure Initialize(const Metadata: ITypeInfo; const GUID: TGUID;
      Args: PAnsiChar); stdcall;
    
    procedure Load; stdcall;
    procedure Save; stdcall;
    procedure ThreadSafeSave; stdcall;

    procedure DeleteEntry(Id: Longword); stdcall;
    procedure DeleteEntries(Ids: PLongword; Count: Integer); stdcall;

    procedure SaveEntry(const Entry: IYesSerializable; Release: Boolean = True); stdcall;
    procedure SaveEntries(Entries: PYesSerializable; Count: Integer; Release: Boolean = True); stdcall;

    procedure CreateEntry(Entry: PPointer); stdcall;
    procedure CreateEntries(Entries: PPointer; Count: Integer); stdcall;

    procedure AcquireEntry(Entry: PPointer); stdcall;
    procedure AcquireEntries(Entries: PPointer; Count: Integer); stdcall;

    procedure ReleaseEntry(const Entry: IYesSerializable); stdcall;
    procedure ReleaseEntries(Entries: PYesSerializable; Count: Integer); stdcall;

    procedure LookupEntry(Id: Longword; Entry: PPointer); stdcall;

    procedure LookupEntryList(Field: PAnsiChar; CmpValue: Longword; CmpOp: TCompareOp; Result: PYesLookupResult; ResultOwnsEntries: Boolean = True); overload; stdcall;
    procedure LookupEntryList(Field: PAnsiChar; CmpValue: PAnsiChar; CaseSensitive: Boolean; EntryList: PYesLookupResult; ResultOwnsEntries: Boolean = True); overload; stdcall;
    procedure LookupEntryList(Field: PAnsiChar; CmpValue: PWideChar; CaseSensitive: Boolean; EntryList: PYesLookupResult; ResultOwnsEntries: Boolean = True); overload; stdcall;
    procedure LookupEntryList(Field: PAnsiChar; CmpValue: Float; CmpOp: TCompareOp; Epsilon: Float; EntryList: PYesLookupResult; ResultOwnsEntries: Boolean = True); overload; stdcall;
    
    function GetEntryCount: Integer; stdcall;
    function GetName: PChar; stdcall;

    property EntryCount: Integer read GetEntryCount;
    property Name: PAnsiChar read GetName;
  end;

implementation

end.
