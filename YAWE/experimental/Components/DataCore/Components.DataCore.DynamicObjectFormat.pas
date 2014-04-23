{
  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE 2007 - Under LGPL licence

  Dynamic object format (DOF) implementation.



  Initial Developer: Seth
}

{$I compiler.inc}
unit Components.DataCore.DynamicObjectFormat;

interface

uses
  SysUtils,
  Classes,
  TypInfo,
  Components.Shared,
  Misc.Miscleanous,
  Misc.Classes,
  Framework.Base,
  Framework.TypeRegistry;

type
  IDofReader = interface;
  IDofWriter = interface;

  YClassTypeLookupEvent = procedure(const ClassName: string; out Info: IClassTypeInfo) of object;

  IDofStreamable = interface(IInterface)
  ['{93749366-EA8A-4291-8A05-1812084F478D}']
    procedure ReadCustomProperties(const Reader: IDofReader); stdcall;
    procedure WriteCustomProperties(const Writer: IDofWriter); stdcall;
  end;

  YDofReaderMethod = procedure(const Reader: IDofReader) of object;
  YDofWriterMethod = procedure(const Writer: IDofWriter) of object;

  YDofElementType = (
    detI8,
    detI16,
    detI32,
    detI64,
    detF32,
    detF64,
    detF80,
    detEnum,
    detSet,
    detClass,
    detClassEnd,
    detSString,
    detLString,
    detWString,
    detBinary,
    detListStart,
    detListEnd,
    detCollectionStart,
    detCollectionEnd,
    detCollectionItemStart,
    detCollectionItemEnd,
    detUdp
  );

  PDofClassInfoHeader = ^YDofClassInfoHeader;
  YDofClassInfoHeader = packed record
    Size: UInt32;
    Count: Word;
    { ClassName: string }
    { ElemTypes: array[0..Count-1] of YDofElementType }
    { StrData: array[0..Count-1] of string }
  end;

  EDofError = class(EYaweException);

  IDofReader = interface(IInterface)
  ['{ECE8A058-1761-416D-84BB-167E4E24DB94}']
    function ReadCustomProperty(const Prop: string; Reader: YDofReaderMethod): Boolean;
    procedure ReadBinary(Stream: TStream);
    function ReadQuad: UInt64;
    function ReadLong: UInt32;
    function ReadWord: UInt16;
    function ReadByte: UInt8;
    function ReadEnum: Int32;
    function ReadSingle: Single;
    function ReadDouble: Double;
    function ReadExtended: Extended;
    function ReadString: string;
    function ReadWString: WideString;
    procedure ReadSString(var Str: ShortString);
    function ReadSet: Int32;
    procedure ReadClass(Instance: TObject; const Info: IClassTypeInfo);
    procedure ReadListStart;
    procedure ReadListEnd;
    procedure ReadCollectionStart;
    procedure ReadCollectionEnd;
    procedure ReadCollectionItemStart;
    procedure ReadCollectionItemEnd;

    function IsListEnd: Boolean;
    function IsCollectionEnd: Boolean;
  end;

  IDofWriter = interface(IInterface)
  ['{C3D897E3-7244-4879-831B-15E20FCA8A75}']
    procedure WriteCustomProperty(const Prop: string; Writer: YDofWriterMethod);
    procedure WriteBinary(const Buf: Pointer; Size: Int32);
    procedure WriteQuad(const Value: UInt64);
    procedure WriteLong(Value: UInt32);
    procedure WriteWord(Value: UInt16);
    procedure WriteByte(Value: UInt8);
    procedure WriteEnum(Value: Int32; const Info: IEnumerationTypeInfo);
    procedure WriteSingle(const Value: Single);
    procedure WriteDouble(const Value: Double);
    procedure WriteExtended(const Value: Extended);
    procedure WriteString(const Value: string);
    procedure WriteWString(const Value: WideString);
    procedure WriteSString(const Value: ShortString);
    procedure WriteSet(Value: Int32; const Info: ISetTypeInfo);
    procedure WriteClass(Instance: TObject; const Info: IClassTypeInfo);
    procedure WriteListStart;
    procedure WriteListEnd;
    procedure WriteCollectionStart;
    procedure WriteCollectionEnd;
    procedure WriteCollectionItemStart;
    procedure WriteCollectionItemEnd;
  end;

  YDbDofAbstractReader = class(TStreamReader, IInterface)
    private
      function _AddRef: Int32; stdcall;
      function _Release: Int32; stdcall;
      function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    protected
      fOnLookup: YClassTypeLookupEvent;
    public
      procedure ReadRootClass(Instance: TObject); virtual; abstract;

      property OnLookup: YClassTypeLookupEvent read fOnLookup write fOnLookup;
  end;

  YDbDofBinaryReader = class(YDbDofAbstractReader, IDofReader)
    private
      fDefinitions: array of PDofClassInfoHeader;
      fClassNames: array of string;
      fDefinitionPropNames: array of TStringDynArray;

      procedure Clear;
      procedure ReadField(Instance: TObject; const PropName: string;
        ElemType: YDofElementType);
      function ReadElemType: YDofElementType; inline;
      procedure CheckElemType(ElemType: YDofElementType);
      function PeekElemType: YDofElementType;
      function ReadStr: string;
    public
      destructor Destroy; override;

      procedure BeginRead;

      procedure ReadRootClass(Instance: TObject); override;

      function ReadCustomProperty(const Prop: string; Reader: YDofReaderMethod): Boolean;
      procedure ReadBinary(Stream: TStream);
      function ReadQuad: UInt64;
      function ReadLong: UInt32;
      function ReadWord: UInt16;
      function ReadByte: UInt8;
      function ReadEnum: Int32;
      function ReadSingle: Single;
      function ReadDouble: Double;
      function ReadExtended: Extended;
      function ReadString: string;
      function ReadWString: WideString;
      procedure ReadSString(var Str: ShortString);
      function ReadSet: Int32;
      procedure ReadClass(Instance: TObject; const Info: IClassTypeInfo);
      procedure ReadListStart;
      procedure ReadListEnd;
      procedure ReadCollectionStart;
      procedure ReadCollectionEnd;
      procedure ReadCollectionItemStart;
      procedure ReadCollectionItemEnd;

      function IsListEnd: Boolean;
      function IsCollectionEnd: Boolean;

      procedure EndRead;
  end;

  YDbDofTextReader = class(YDbDofAbstractReader, IDofReader)
    private
      fDefinitionClasses: array of TClass;
      fDefinitionPropNames: array of TStringDynArray;
      fParser: TParser;

      procedure Clear;
      procedure ReadClassNoHeader(Instance: TObject; const Info: IClassTypeInfo);
      function ReadProperty(Instance: TObject; const Info: IClassTypeInfo; const Ser: IDofStreamable): Boolean;
    public
      destructor Destroy; override;

      procedure BeginRead;

      procedure ReadRootClass(Instance: TObject); override;

      function ReadCustomProperty(const Prop: string; Reader: YDofReaderMethod): Boolean;
      procedure ReadBinary(Stream: TStream);
      function ReadQuad: UInt64;
      function ReadLong: UInt32;
      function ReadWord: UInt16;
      function ReadByte: UInt8;
      function ReadEnum: Int32;
      function ReadSingle: Single;
      function ReadDouble: Double;
      function ReadExtended: Extended;
      function ReadString: string;
      function ReadWString: WideString;
      procedure ReadSString(var Str: ShortString);
      function ReadSet: Int32;
      procedure ReadClass(Instance: TObject; const Info: IClassTypeInfo);
      procedure ReadListStart;
      procedure ReadListEnd;
      procedure ReadCollectionStart;
      procedure ReadCollectionEnd;
      procedure ReadCollectionItemStart;
      procedure ReadCollectionItemEnd;

      function IsListEnd: Boolean;
      function IsCollectionEnd: Boolean;

      procedure EndRead;
  end;

  YDbDofAbstractWriter = class(TStreamWriter, IInterface)
    private
      function _AddRef: Int32; stdcall;
      function _Release: Int32; stdcall;
      function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    protected
      fOnLookup: YClassTypeLookupEvent;
    public
      procedure BeginWrite; virtual; abstract;

      procedure WriteRootClass(Instance: TObject); virtual; abstract;

      procedure EndWrite; virtual; abstract;

      property OnLookup: YClassTypeLookupEvent read fOnLookup write fOnLookup;
  end;

  YDbDofBinaryWriter = class(YDbDofAbstractWriter, IDofWriter)
    private
      fDefinitions: array of PDofClassInfoHeader;
      fDefinitionBufsSize: Int32;
      fDefinitionClasses: array of TClass;
      fSavedHeaderPos: Int64;
      fFirstEntryPos: Int64;
      fEntryCount: Int32;

      procedure CreateDefinitionInfo(out Buffer: PDofClassInfoHeader;
        const Info: IClassTypeInfo);

      function FindDefinition(const Info: IClassTypeInfo): Int32;
      function AddDefinition(const Info: IClassTypeInfo): Int32;

      procedure WriteInstanceField(Instance: TObject; const PropInfo: IPropertyInfo;
        const Info: ITypeInfo);

      procedure Clear;
    public
      destructor Destroy; override;

      procedure BeginWrite; override;

      procedure WriteRootClass(Instance: TObject); override;

      procedure WriteCustomProperty(const Prop: string; Writer: YDofWriterMethod);
      procedure WriteBinary(const Buf: Pointer; Size: Int32);
      procedure WriteStr(const Value: string);
      procedure WriteElementType(ElemType: YDofElementType); inline;
      procedure WriteQuad(const Value: UInt64);
      procedure WriteLong(Value: UInt32);
      procedure WriteWord(Value: UInt16);
      procedure WriteByte(Value: UInt8);
      procedure WriteEnum(Value: Int32; const Info: IEnumerationTypeInfo);
      procedure WriteSingle(const Value: Single);
      procedure WriteDouble(const Value: Double);
      procedure WriteExtended(const Value: Extended);
      procedure WriteString(const Value: string);
      procedure WriteWString(const Value: WideString);
      procedure WriteSString(const Value: ShortString);
      procedure WriteSet(Value: Int32; const Info: ISetTypeInfo);
      procedure WriteClass(Instance: TObject; const Info: IClassTypeInfo);
      procedure WriteListStart;
      procedure WriteListEnd;
      procedure WriteCollectionStart;
      procedure WriteCollectionEnd;
      procedure WriteCollectionItemStart;
      procedure WriteCollectionItemEnd;

      procedure EndWrite; override;
  end;

  YDbDofTextWriter = class(YDbDofAbstractWriter, IDofWriter)
    private
      fDefinitionClasses: array of TClass;
      fEntryCount: Int32;
      fSkipChars: string;
      fForceSkip: Boolean;

      function FindDefinition(const Info: IClassTypeInfo): Int32;
      function AddDefinition(const Info: IClassTypeInfo): Int32;

      procedure WriteInstanceField(Instance: TObject; const PropInfo: IPropertyInfo;
        const Info: ITypeInfo);
      procedure Clear;
      procedure Writeln(Str: string); inline;

      procedure SkipStartChars; inline;
      procedure WriteClassInt(Instance: TObject; const Info: IClassTypeInfo);
    public
      destructor Destroy; override;

      procedure BeginWrite; override;

      procedure WriteRootClass(Instance: TObject); override;

      procedure WriteCustomProperty(const Prop: string; Writer: YDofWriterMethod);
      procedure WriteClass(Instance: TObject; const Info: IClassTypeInfo);
      procedure WriteBinary(const Buf: Pointer; Size: Int32);
      procedure WriteStr(const Value: string);
      procedure WriteQuad(const Value: UInt64);
      procedure WriteLong(Value: UInt32);
      procedure WriteWord(Value: UInt16);
      procedure WriteByte(Value: UInt8);
      procedure WriteEnum(Value: Int32; const Info: IEnumerationTypeInfo);
      procedure WriteSingle(const Value: Single);
      procedure WriteDouble(const Value: Double);
      procedure WriteExtended(const Value: Extended);
      procedure WriteString(const Value: string);
      procedure WriteWString(const Value: WideString);
      procedure WriteSString(const Value: ShortString);
      procedure WriteSet(Value: Int32; const Info: ISetTypeInfo);
      procedure WriteListStart;
      procedure WriteListEnd;
      procedure WriteCollectionStart;
      procedure WriteCollectionEnd;
      procedure WriteCollectionItemStart;
      procedure WriteCollectionItemEnd;

      procedure EndWrite; override;
  end;

const
  EqualSign = ' = ';

implementation

uses
  Framework,
  Misc.Resources;

const
  DOF_MAGIC = $30314644; // 'DF10'

resourcestring
  RsInvalidDofFormat = 'DOF format encountered is invalid.';

type
  PDofFileHeader = ^YDofFileHeader;
  YDofFileHeader = packed record
    Magic: UInt32;
    Size: Int64;
    ClassInfoCnt: Int32;
    ClassInfoOffset: UInt32;
    EntryCnt: Int32;
    EntryOffset: UInt32;
  end;

  PDofElemTypeArray = ^YDofElemTypeArray;
  YDofElemTypeArray = array[0..$7FFFFFE] of YDofElementType;

{ YDbDofWriter }

procedure YDbDofBinaryWriter.Clear;
var
  iIdx: Int32;
begin
  for iIdx := 0 to Length(fDefinitions) -1 do
  begin
    FreeMem(fDefinitions[iIdx]);
  end;
  fDefinitions := nil;
  fDefinitionClasses := nil;
  fDefinitionBufsSize := 0;
  fSavedHeaderPos := 0;
  fFirstEntryPos := -1;
  fEntryCount := 0;
end;

procedure YDbDofBinaryWriter.CreateDefinitionInfo(out Buffer: PDofClassInfoHeader;
  const Info: IClassTypeInfo);
var
  iIdx: Int32;
  ifProp: IPropertyInfo;
  pElems: PDofElemTypeArray;
  pTmp: PChar;
  iReqOld: Int32;
  iRequired: Int32;
  sPropName: string;
begin
  iReqOld := SizeOf(YDofClassInfoHeader) + (Info.PropertyCount * SizeOf(YDofElementType)) +
    Length(Info.Name) + 1;
  iRequired := iReqOld;
  Buffer := AllocMem(iRequired);
  StrPCopy(PChar(Buffer) + SizeOf(YDofClassInfoHeader), Info.Name);
  pElems := Pointer(PChar(Buffer) + SizeOf(YDofClassInfoHeader) + Length(Info.Name) + 1);

  for iIdx := 0 to Info.PropertyCount - 1 do
  begin
    ifProp := Info.Properties[iIdx];
    Inc(iRequired, Length(ifProp.Name) + 1);
    case ifProp.PropertyType.RttiType of
      tkChar, tkWChar: pElems^[iIdx] := detI8;
      tkInt64: pElems^[iIdx] := detI64;
      tkInteger:
      begin
        case (ifProp.PropertyType as IIntegerTypeInfo).OrdinalType of
          otUByte, otSByte: pElems^[iIdx] := detI8;
          otUWord, otSWord: pElems^[iIdx] := detI16;
          otULong, otSLong: pElems^[iIdx] := detI32;
        end;
      end;
      tkEnumeration: pElems^[iIdx] := detEnum;
      tkSet: pElems^[iIdx] := detSet;
      tkFloat:
      begin
        case (ifProp.PropertyType as IFloatTypeInfo).FloatType of
          ftSingle: pElems^[iIdx] := detF32;
          ftDouble, ftComp: pElems^[iIdx] := detF64;
          ftExtended, ftCurr: pElems^[iIdx] := detF80;
        end;
      end;
      tkClass: pElems^[iIdx] := detClass;
      tkString: pElems^[iIdx] := detSString;
      tkLString: pElems^[iIdx] := detLString;
      tkWString: pElems^[iIdx] := detWString;
    end;
  end;
  ReallocMem(Buffer, iRequired);
  pTmp := PChar(Buffer) + iReqOld;
  for iIdx := 0 to Info.PropertyCount - 1 do
  begin
    sPropName := Info.Properties[iIdx].Name;
    StrPCopy(pTmp, sPropName);
    Inc(pTmp, Length(sPropName) + 1);
  end;
  Buffer^.Size := iRequired;
  Buffer^.Count := Info.PropertyCount;
end;

destructor YDbDofBinaryWriter.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function YDbDofBinaryWriter.AddDefinition(const Info: IClassTypeInfo): Int32;
var
  iLen: Int32;
begin
  iLen := Length(fDefinitions);
  SetLength(fDefinitions, iLen + 1);
  SetLength(fDefinitionClasses, iLen + 1);
  CreateDefinitionInfo(fDefinitions[iLen], Info);
  fDefinitionClasses[iLen] := Info.ClassReference;
  Inc(fDefinitionBufsSize, fDefinitions[iLen]^.Size);
  Result := iLen;
end;

function YDbDofBinaryWriter.FindDefinition(const Info: IClassTypeInfo): Int32;
var
  iIdx: Int32;
  pRef: TClass;
begin
  pRef := Info.ClassReference;
  for iIdx := 0 to Length(fDefinitionClasses) - 1 do
  begin
    if fDefinitionClasses[iIdx] = pRef then
    begin
      Result := iIdx;
      Exit;
    end;
  end;
  Result := -1;
end;

procedure YDbDofBinaryWriter.BeginWrite;
begin
  fSavedHeaderPos := Position;
  fFirstEntryPos := -1;
  Seek(SizeOf(YDofFileHeader), soCurrent);
end;

procedure YDbDofBinaryWriter.WriteBinary(const Buf: Pointer; Size: Int32);
begin
  WriteElementType(detBinary);
  Write(Size, SizeOf(Size));
  Write(Buf^, Size);
end;

procedure YDbDofBinaryWriter.WriteByte(Value: UInt8);
begin
  WriteElementType(detI8);
  Write(Value, SizeOf(Value));
end;

procedure YDbDofBinaryWriter.WriteDouble(const Value: Double);
begin
  WriteElementType(detF64);
  Write(Value, SizeOf(Value));
end;

procedure YDbDofBinaryWriter.WriteElementType(ElemType: YDofElementType);
begin
  Write(ElemType, SizeOf(ElemType));
end;

procedure YDbDofBinaryWriter.WriteEnum(Value: Int32; const Info: IEnumerationTypeInfo);
begin
  WriteElementType(detEnum);
  Write(Value, SizeOf(Value));
end;

procedure YDbDofBinaryWriter.WriteExtended(const Value: Extended);
begin
  WriteElementType(detF80);
  Write(Value, SizeOf(Value));
end;

procedure YDbDofBinaryWriter.WriteInstanceField(Instance: TObject;
  const PropInfo: IPropertyInfo; const Info: ITypeInfo);
begin
  case Info.RttiType of
    tkChar: WriteByte(GetOrdProp(Instance, PropInfo.PropInfo));
    tkWChar: WriteWord(GetOrdProp(Instance, PropInfo.PropInfo));
    tkInteger:
    begin
      case (Info as IIntegerTypeInfo).OrdinalType of
        otUByte, otSByte: WriteByte(GetOrdProp(Instance, PropInfo.PropInfo));
        otUWord, otSWord: WriteWord(GetOrdProp(Instance, PropInfo.PropInfo));
        otULong, otSLong: WriteLong(GetOrdProp(Instance, PropInfo.PropInfo));
      end;
    end;
    tkInt64: WriteQuad(GetInt64Prop(Instance, PropInfo.PropInfo));
    tkEnumeration: WriteEnum(GetOrdProp(Instance, PropInfo.PropInfo), nil);
    tkFloat:
    begin
      case (Info as IFloatTypeInfo).FloatType of
        ftSingle: WriteSingle(GetFloatProp(Instance, PropInfo.PropInfo));
        ftDouble, ftComp: WriteDouble(GetFloatProp(Instance, PropInfo.PropInfo));
        ftExtended, ftCurr: WriteExtended(GetFloatProp(Instance, PropInfo.PropInfo));
      end;
    end;
    tkSet: WriteSet(GetOrdProp(Instance, PropInfo.PropInfo), nil);
    tkString: WriteSString(GetStrProp(Instance, PropInfo.PropInfo));
    tkLString: WriteString(GetStrProp(Instance, PropInfo.PropInfo));
    tkWString: WriteWString(GetWideStrProp(Instance, PropInfo.PropInfo));
    tkClass: WriteClass(GetObjectProp(Instance, PropInfo.PropInfo), Info as IClassTypeInfo);
  end;
end;

procedure YDbDofBinaryWriter.EndWrite;
var
  iTmp: Int64;
  tHdr: YDofFileHeader;
  iIdx: Int32;
begin
  iTmp := Position;
  tHdr.ClassInfoOffset := Seek(0, soEnd) - fSavedHeaderPos;
  Position := fSavedHeaderPos;
  fSavedHeaderPos := 0;
  tHdr.Magic := DOF_MAGIC;
  tHdr.Size := Size + fDefinitionBufsSize;
  tHdr.ClassInfoCnt := Length(fDefinitions);
  tHdr.EntryCnt := fEntryCount;
  tHdr.EntryOffset := fFirstEntryPos;
  fFirstEntryPos := -1;
  Write(tHdr, SizeOf(tHdr));
  Position := iTmp;
  for iIdx := 0 to Length(fDefinitions) -1 do
  begin
    Write(fDefinitions[iIdx]^, fDefinitions[iIdx]^.Size);
  end;
  Clear;
end;

procedure YDbDofBinaryWriter.WriteListEnd;
begin
  WriteElementType(detListEnd);
end;

procedure YDbDofBinaryWriter.WriteListStart;
begin
  WriteElementType(detListStart);
end;

procedure YDbDofBinaryWriter.WriteLong(Value: UInt32);
begin
  WriteElementType(detI32);
  Write(Value, SizeOf(Value));
end;

procedure YDbDofBinaryWriter.WriteQuad(const Value: UInt64);
begin
  WriteElementType(detI64);
  Write(Value, SizeOf(Value));
end;

procedure YDbDofBinaryWriter.WriteSet(Value: Int32; const Info: ISetTypeInfo);
begin
  WriteElementType(detSet);
  Write(Value, SizeOf(Value));
end;

procedure YDbDofBinaryWriter.WriteSingle(const Value: Single);
begin
  WriteElementType(detF32);
  Write(Value, SizeOf(Value));
end;

procedure YDbDofBinaryWriter.WriteSString(const Value: ShortString);
begin
  WriteElementType(detSString);
  Write(Value, Length(Value) + 1);
end;

procedure YDbDofBinaryWriter.WriteStr(const Value: string);
var
  iLen: Int32;
begin
  iLen := Length(Value);
  if iLen > 255 then iLen := 255;
  Write(iLen, SizeOf(Byte));
  Write(Value[1], iLen);
end;

procedure YDbDofBinaryWriter.WriteString(const Value: string);
var
  Len: Int32;
begin
  WriteElementType(detLString);
  Len := Length(Value);
  Write(Len, SizeOf(Len));
  Write(Value[1], Len);
end;

procedure YDbDofBinaryWriter.WriteRootClass(Instance: TObject);
var
  ifInfo: IClassTypeInfo;
begin
  if not Assigned(fOnLookup) then Exit;
  fOnLookup(Instance.ClassName, ifInfo);
  if ifInfo = nil then Exit;
  WriteClass(Instance, ifInfo);
  Inc(fEntryCount);
end;

procedure YDbDofBinaryWriter.WriteClass(Instance: TObject; const Info: IClassTypeInfo);
var
  iIdx: Int32;
  iClsIndex: Int32;
  ifProp: IPropertyInfo;
  ifStreamable: IDofStreamable;
begin
  iClsIndex := FindDefinition(Info);
  if iClsIndex = -1 then
  begin
    iClsIndex := AddDefinition(Info);
  end;
  
  if fFirstEntryPos = -1 then
  begin
    fFirstEntryPos := Position - fSavedHeaderPos;
  end;

  WriteElementType(detClass);
  Write(iClsIndex, SizeOf(Byte));

  for iIdx := 0 to Info.PropertyCount -1 do
  begin
    ifProp := Info.Properties[iIdx];
    WriteInstanceField(Instance, ifProp, ifProp.PropertyType);
  end;

  if Supports(Instance, IDofStreamable, ifStreamable) then
  begin
    ifStreamable.WriteCustomProperties(Self);
  end;
  WriteElementType(detClassEnd);
end;

procedure YDbDofBinaryWriter.WriteCollectionEnd;
begin
  WriteElementType(detCollectionEnd);
end;

procedure YDbDofBinaryWriter.WriteCollectionItemEnd;
begin
  WriteElementType(detCollectionItemEnd);
end;

procedure YDbDofBinaryWriter.WriteCollectionItemStart;
begin
  WriteElementType(detCollectionItemStart);
end;

procedure YDbDofBinaryWriter.WriteCollectionStart;
begin
  WriteElementType(detCollectionStart);
end;

procedure YDbDofBinaryWriter.WriteCustomProperty(const Prop: string; Writer: YDofWriterMethod);
begin
  WriteElementType(detUdp);
  WriteStr(Prop);
  Writer(Self);
end;

procedure YDbDofBinaryWriter.WriteWord(Value: UInt16);
begin
  WriteElementType(detI16);
  Write(Value, SizeOf(Value));
end;

procedure YDbDofBinaryWriter.WriteWString(const Value: WideString);
var
  Len: Int32;
begin
  WriteElementType(detWString);
  Len := Length(Value);
  Write(Len, SizeOf(Len));
  Write(Value[1], Len * 2);
end;

{ YDbDofBinaryReader }

procedure Error(ResStr: PResStringRec);
begin
  raise EDofError.CreateRes(ResStr) at GetCurrentReturnAddress;
end;

procedure YDbDofBinaryReader.BeginRead;
var
  iCurr: Int64;
  iFirst: Int64;
  iSize: Int32;
  iLen: Int32;
  iCnt: Int32;
  tHdr: YDofFileHeader;
  pClassHdr: PDofClassInfoHeader;
  pStr: PChar;
  iX: Int32;
begin
  iCurr := Position;
  Read(tHdr, SizeOf(tHdr));
  if tHdr.Magic <> DOF_MAGIC then Error(@RsInvalidDofFormat);

  iFirst := iCurr + tHdr.EntryOffset;
  Position := iCurr + tHdr.ClassInfoOffset;
  SetLength(fDefinitions, tHdr.ClassInfoCnt);
  SetLength(fDefinitionPropNames, tHdr.ClassInfoCnt);
  SetLength(fClassNames, tHdr.ClassInfoCnt);
  iLen := 0;
  while tHdr.ClassInfoCnt <> 0 do
  begin
    Read(iSize, SizeOf(iSize));
    pClassHdr := AllocMem(iSize);
    pClassHdr^.Size := iSize;
    Read(Pointer(PChar(pClassHdr) + SizeOf(iSize))^, iSize - 4);
    SetLength(fDefinitionPropNames[iLen], pClassHdr^.Count);
    pStr := PChar(pClassHdr) + SizeOf(YDofClassInfoHeader);
    fClassNames[iLen] := pStr;
    Inc(pStr, StrLen(pStr) + 1);
    Inc(pStr, pClassHdr^.Count * SizeOf(YDofElementType));
    iCnt := pClassHdr^.Count;
    iX := 0;
    while iCnt <> 0 do
    begin
      Dec(iCnt);
      fDefinitionPropNames[iLen, iX] := pStr;
      Inc(pStr, StrLen(pStr) + 1);
      Inc(iX);
    end;
    fDefinitions[iLen] := pClassHdr;

    Dec(tHdr.ClassInfoCnt);
    Inc(iLen);
  end;
  
  Seek(iFirst, soBeginning);
end;

procedure YDbDofBinaryReader.CheckElemType(ElemType: YDofElementType);
begin
  if ReadElemType <> ElemType then Error(@RsInvalidDofFormat);
end;

procedure YDbDofBinaryReader.Clear;
var
  iIdx: Int32;
begin
  for iIdx := 0 to Length(fDefinitions) -1 do
  begin
    FreeMem(fDefinitions[iIdx]);
  end;
  fDefinitions := nil;
  fDefinitionPropNames := nil;
  fClassNames := nil;
end;

destructor YDbDofBinaryReader.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure YDbDofBinaryReader.EndRead;
begin
  Clear;
end;

function YDbDofBinaryReader.IsCollectionEnd: Boolean;
begin
  Result := PeekElemType = detCollectionEnd;
end;

function YDbDofBinaryReader.IsListEnd: Boolean;
begin
  Result := PeekElemType = detListEnd;
end;

function YDbDofBinaryReader.PeekElemType: YDofElementType;
begin
  Read(Result, SizeOf(Result));
  Seek(-SizeOf(Result), soCurrent);
end;

procedure YDbDofBinaryReader.ReadBinary(Stream: TStream);
var
  Size: Integer;
begin
  CheckElemType(detBinary);
  Read(Size, SizeOf(Size));
  Stream.CopyFrom(Stream, Size);
end;

function YDbDofBinaryReader.ReadByte: UInt8;
begin
  CheckElemType(detI8);
  Read(Result, SizeOf(Result));
end;

procedure YDbDofBinaryReader.ReadClass(Instance: TObject; const Info: IClassTypeInfo);
var
  iClsIndex: Int32;
  pTypes: PDofElemTypeArray;
  iIdx: Int32;
  ifStreamable: IDofStreamable;
begin
  iClsIndex := 0;
  CheckElemType(detClass);
  Read(iClsIndex, SizeOf(Byte));

  if iClsIndex >= Length(fDefinitions) then Error(@RsInvalidDofFormat);

  pTypes := Pointer(PChar(fDefinitions[iClsIndex]) + SizeOf(YDofClassInfoHeader) +
    Length(fClassNames[iClsIndex]) + 1);

  for iIdx := 0 to fDefinitions[iClsIndex]^.Count -1 do
  begin
    ReadField(Instance, fDefinitionPropNames[iClsIndex, iIdx], pTypes^[iIdx]);
  end;

  if Supports(Instance, IDofStreamable, ifStreamable) then
  begin
    ifStreamable.ReadCustomProperties(Self);
  end;
  CheckElemType(detClassEnd);
end;

procedure YDbDofBinaryReader.ReadCollectionEnd;
begin
  CheckElemType(detCollectionEnd);
end;

procedure YDbDofBinaryReader.ReadCollectionItemEnd;
begin
  CheckElemType(detCollectionItemEnd);
end;

procedure YDbDofBinaryReader.ReadCollectionItemStart;
begin
  CheckElemType(detCollectionItemStart);
end;

procedure YDbDofBinaryReader.ReadCollectionStart;
begin
  CheckElemType(detCollectionStart);
end;

function YDbDofBinaryReader.ReadCustomProperty(const Prop: string; Reader: YDofReaderMethod): Boolean;
var
  S: string;
begin
  CheckElemType(detUdp);
  S := ReadStr;
  Result := StringsEqualNoCase(Prop, S);
  if not Result then
  begin
    Seek(-(SizeOf(YDofElementType) + Length(S) + 1), soCurrent);
  end else Reader(Self);
end;

function YDbDofBinaryReader.ReadDouble: Double;
begin
  CheckElemType(detF64);
  Read(Result, SizeOf(Result));
end;

function YDbDofBinaryReader.ReadElemType: YDofElementType;
begin
  Read(Result, SizeOf(Result));
end;

function YDbDofBinaryReader.ReadEnum: Int32;
begin
  CheckElemType(detEnum);
  Read(Result, SizeOf(Result));
end;

function YDbDofBinaryReader.ReadExtended: Extended;
begin
  CheckElemType(detF80);
  Read(Result, SizeOf(Result));
end;

procedure YDbDofBinaryReader.ReadField(Instance: TObject; const PropName: string;
  ElemType: YDofElementType);
var
  ifInfo: IClassTypeInfo;
  cInst: TObject;
  sStr: ShortString;
begin
  if IsPublishedProp(Instance, PropName) then
  begin
    case ElemType of
      detI8: SetOrdProp(Instance, PropName, ReadByte);
      detI16: SetOrdProp(Instance, PropName, ReadWord);
      detI32: SetOrdProp(Instance, PropName, ReadLong);
      detI64: SetInt64Prop(Instance, PropName, ReadQuad);
      detEnum: SetOrdProp(Instance, PropName, ReadEnum);
      detSet: SetOrdProp(Instance, PropName, ReadSet);
      detLString: SetStrProp(Instance, PropName, ReadString);
      detSString:
      begin
        ReadSString(sStr);
        SetStrProp(Instance, PropName, sStr);
      end;
      detWString: SetWideStrProp(Instance, PropName, ReadWString);
      detF32: SetFloatProp(Instance, PropName, ReadSingle);
      detF64: SetFloatProp(Instance, PropName, ReadDouble);
      detF80: SetFloatProp(Instance, PropName, ReadExtended);
      detClass:
      begin
        if not Assigned(fOnLookup) then Exit;
        fOnLookup(PropName, ifInfo);
        cInst := GetObjectProp(Instance, PropName, nil);
        if cInst = nil then cInst := ifInfo.ClassReference.Create;
        ReadClass(cInst, ifInfo);
      end
    else
      Error(@RsInvalidDofFormat);
    end;
  end;
end;

procedure YDbDofBinaryReader.ReadListEnd;
begin
  CheckElemType(detListEnd);
end;

procedure YDbDofBinaryReader.ReadListStart;
begin
  CheckElemType(detListStart);
end;

function YDbDofBinaryReader.ReadLong: UInt32;
begin
  CheckElemType(detI32);
  Read(Result, SizeOf(Result));
end;

function YDbDofBinaryReader.ReadQuad: UInt64;
begin
  CheckElemType(detI64);
  Read(Result, SizeOf(Result));
end;

procedure YDbDofBinaryReader.ReadRootClass(Instance: TObject);
var
  ifInfo: IClassTypeInfo;
begin
  if not Assigned(fOnLookup) then Exit;
  fOnLookup(Instance.ClassName, ifInfo);
  if ifInfo = nil then Exit;
  ReadClass(Instance, ifInfo);
end;

function YDbDofBinaryReader.ReadSet: Int32;
begin
  CheckElemType(detSet);
  Read(Result, SizeOf(Result));
end;

function YDbDofBinaryReader.ReadSingle: Single;
begin
  CheckElemType(detF32);
  Read(Result, SizeOf(Result));
end;

procedure YDbDofBinaryReader.ReadSString(var Str: ShortString);
begin
  CheckElemType(detSString);
  Read(Str[0], SizeOf(Byte));
  Read(Str[1], Ord(Str[0]));
end;

function YDbDofBinaryReader.ReadStr: string;
var
  iLen: Byte;
begin
  Read(iLen, SizeOf(iLen));
  SetLength(Result, iLen);
  Read(Result[1], iLen);
end;

function YDbDofBinaryReader.ReadString: string;
var
  iLen: Int32;
begin
  CheckElemType(detLString);
  Read(iLen, SizeOf(iLen));
  SetLength(Result, iLen);
  Read(Result[1], iLen);
end;

function YDbDofBinaryReader.ReadWord: UInt16;
begin
  CheckElemType(detI16);
  Read(Result, SizeOf(Result));
end;

function YDbDofBinaryReader.ReadWString: WideString;
var
  iLen: Int32;
begin
  CheckElemType(detWString);
  Read(iLen, SizeOf(iLen));
  SetLength(Result, iLen);
  Read(Result[1], iLen * 2);
end;

{ YDbDofAbstractReader }

function YDbDofAbstractReader._AddRef: Int32;
begin
  Result := -1;
end;

function YDbDofAbstractReader._Release: Int32;
begin
  Result := -1;
end;

function YDbDofAbstractReader.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

{ YDbDofAbstractWriter }

function YDbDofAbstractWriter.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function YDbDofAbstractWriter._AddRef: Int32;
begin
  Result := -1;
end;

function YDbDofAbstractWriter._Release: Int32;
begin
  Result := -1;
end;

{ YDbDofTextWriter }

function YDbDofTextWriter.AddDefinition(const Info: IClassTypeInfo): Int32;
var
  iLen: Int32;
begin
  iLen := Length(fDefinitionClasses);
  SetLength(fDefinitionClasses, iLen + 1);
  fDefinitionClasses[iLen] := Info.ClassReference;
  Result := iLen;
end;

procedure YDbDofTextWriter.BeginWrite;
begin
end;

procedure YDbDofTextWriter.Clear;
begin
  fDefinitionClasses := nil;
  fEntryCount := 0;
  fSkipChars := '';
end;

destructor YDbDofTextWriter.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure YDbDofTextWriter.EndWrite;
begin
  Clear;
end;

function YDbDofTextWriter.FindDefinition(const Info: IClassTypeInfo): Int32;
var
  iIdx: Int32;
  pRef: TClass;
begin
  pRef := Info.ClassReference;
  for iIdx := 0 to Length(fDefinitionClasses) - 1 do
  begin
    if fDefinitionClasses[iIdx] = pRef then
    begin
      Result := iIdx;
      Exit;
    end;
  end;
  Result := -1;
end;

procedure YDbDofTextWriter.SkipStartChars;
begin
  WriteStr(fSkipChars);
end;

procedure BufToHex(Buffer, Text: PChar; BufSize: Integer);
const
  Convert: array[0..15] of Char = '0123456789ABCDEF';
var
  I: Integer;
begin
  for I := 0 to BufSize - 1 do
  begin
    Text[0] := Convert[Byte(Buffer[I]) shr 4];
    Text[1] := Convert[Byte(Buffer[I]) and $F];
    Inc(Text, 2);
  end;
end;

procedure YDbDofTextWriter.WriteBinary(const Buf: Pointer; Size: Int32);
var
  sHex: string;
begin
  Writeln('{');
  SetLength(sHex, Size * 2);
  BufToHex(Buf, Pointer(sHex), Size);
  WriteStr(sHex);
  WriteStr('}');
end;

procedure YDbDofTextWriter.WriteByte(Value: UInt8);
begin
  WriteStr(IntToStr(Value));
end;

procedure YDbDofTextWriter.WriteClassInt(Instance: TObject; const Info: IClassTypeInfo);
var
  iIdx: Int32;
  iClsIndex: Int32;
  ifProp: IPropertyInfo;
  ifStreamable: IDofStreamable;
  sOldSkipChars: string;
begin
  iClsIndex := FindDefinition(Info);
  if iClsIndex = -1 then
  begin
    iClsIndex := AddDefinition(Info);
  end;

  WriteStr('~object ');
  Writeln(fDefinitionClasses[iClsIndex].ClassName + ' ');

  sOldSkipChars := fSkipChars;
  fSkipChars := StringOfChar(' ', Length(sOldSkipChars) + 2);

  for iIdx := 0 to Info.PropertyCount -1 do
  begin
    ifProp := Info.Properties[iIdx];
    WriteInstanceField(Instance, ifProp, ifProp.PropertyType);
  end;

  if Supports(Instance, IDofStreamable, ifStreamable) then
  begin
    ifStreamable.WriteCustomProperties(Self);
  end;

  fSkipChars := sOldSkipChars;
  Writeln(fSkipChars + '~end ');
end;

procedure YDbDofTextWriter.WriteClass(Instance: TObject; const Info: IClassTypeInfo);
begin
  SkipStartChars;
  WriteClassInt(Instance, Info);
end;

procedure YDbDofTextWriter.WriteCollectionEnd;
begin
  fSkipChars := StringOfChar(' ', Length(fSkipChars) - 2);
  Writeln(fSkipChars + ']');
end;

procedure YDbDofTextWriter.WriteCollectionItemEnd;
begin
  fSkipChars := StringOfChar(' ', Length(fSkipChars) - 2);
  Writeln(fSkipChars + '~end');
end;

procedure YDbDofTextWriter.WriteCollectionItemStart;
begin
  Writeln(fSkipChars + '~item');
  fSkipChars := StringOfChar(' ', Length(fSkipChars) + 2);
end;

procedure YDbDofTextWriter.WriteCollectionStart;
begin
  Writeln('[');
  fSkipChars := StringOfChar(' ', Length(fSkipChars) + 2);
end;

procedure YDbDofTextWriter.WriteCustomProperty(const Prop: string; Writer: YDofWriterMethod);
begin
  WriteStr(fSkipChars + '~custom ' + Prop + EqualSign);
  Writer(Self);
end;

procedure YDbDofTextWriter.WriteDouble(const Value: Double);
begin
  WriteStr(FloatToStr(Value));
end;

procedure YDbDofTextWriter.WriteEnum(Value: Int32;
  const Info: IEnumerationTypeInfo);
begin
  WriteStr(Info.Names[Value]);
end;

procedure YDbDofTextWriter.WriteExtended(const Value: Extended);
begin
  WriteStr(FloatToStr(Value));
end;

procedure YDbDofTextWriter.WriteInstanceField(Instance: TObject;
  const PropInfo: IPropertyInfo; const Info: ITypeInfo);
var
  iValue: Int32;
  iDefault: Int32;
  cInst: TObject;
  sStr: string;
  sWStr: WideString;
  iValue64: Int64;
  fValue: Extended;
  iType: TTypeKind;
begin
  iType := Info.RttiType;
  case iType of
    tkChar, tkWChar, tkInteger, tkSet, tkEnumeration:
    begin
      iDefault := PropInfo.DefaultValue;
      iValue := GetOrdProp(Instance, PropInfo.PropInfo);
      if (iDefault <> Int32($80000000)) and (iValue = iDefault) then Exit;

      SkipStartChars;
      WriteStr(PropInfo.Name);
      WriteStr(EqualSign);
      case Info.RttiType of
        tkChar: WriteByte(iValue);
        tkWChar: WriteWord(iValue);
        tkInteger:
        begin
          case (Info as IIntegerTypeInfo).OrdinalType of
            otUByte, otSByte: WriteByte(iValue);
            otUWord, otSWord: WriteWord(iValue);
            otULong, otSLong: WriteLong(iValue);
          end;
        end;
        tkEnumeration: WriteEnum(iValue, Info as IEnumerationTypeInfo);
        tkSet: WriteSet(iValue, Info as ISetTypeInfo);
      end;
      Writeln('');
      Exit;
    end;
    tkFloat:
    begin
      fValue := GetFloatProp(Instance, PropInfo.PropInfo);
      if fValue = 0 then Exit;

      SkipStartChars;
      WriteStr(PropInfo.Name);
      WriteStr(EqualSign);
      case (Info as IFloatTypeInfo).FloatType of
        ftSingle: WriteSingle(GetFloatProp(Instance, PropInfo.PropInfo));
        ftDouble, ftComp: WriteDouble(GetFloatProp(Instance, PropInfo.PropInfo));
        ftExtended, ftCurr: WriteExtended(GetFloatProp(Instance, PropInfo.PropInfo));
      end;
      Writeln('');
    end;
    tkInt64:
    begin
      iDefault := PropInfo.DefaultValue;
      iValue64 := GetInt64Prop(Instance, PropInfo.PropInfo);
      if (iDefault <> Int32($80000000)) and (iValue64 = Int64(iDefault)) then Exit;

      SkipStartChars;
      WriteStr(PropInfo.Name);
      WriteStr(EqualSign);
      WriteQuad(iValue64);
      Writeln('');
    end;
    tkString, tkLString:
    begin
      sStr := GetStrProp(Instance, PropInfo.PropInfo);
      if sStr = '' then Exit;

      SkipStartChars;
      WriteStr(PropInfo.Name);
      WriteStr(EqualSign);
      WriteString(sStr);
    end;
    tkWString:
    begin
      sWStr := GetWideStrProp(Instance, PropInfo.PropInfo);
      if sWStr = '' then Exit;

      SkipStartChars;
      WriteStr(PropInfo.Name);
      WriteStr(EqualSign);
      WriteWString(sWStr);
      Writeln('');
    end;
    tkClass:
    begin
      cInst := GetObjectProp(Instance, PropInfo.PropInfo);
      if cInst = nil then Exit;

      SkipStartChars;
      WriteStr(PropInfo.Name);
      WriteStr(EqualSign);
      WriteClassInt(cInst, Info as IClassTypeInfo);
    end;
  end;
end;

procedure YDbDofTextWriter.WriteListEnd;
begin
  fForceSkip := False;
  fSkipChars := StringOfChar(' ', Length(fSkipChars) - 2);
  Writeln(fSkipChars + ')');
end;

procedure YDbDofTextWriter.WriteListStart;
begin
  Writeln('(');
  fSkipChars := StringOfChar(' ', Length(fSkipChars) + 2);
  fForceSkip := True;
end;

procedure YDbDofTextWriter.Writeln(Str: string);
begin
  Str := Str + #13#10;
  Write(Pointer(Str)^, Length(Str));
end;

procedure YDbDofTextWriter.WriteLong(Value: UInt32);
begin
  if fForceSkip then Write(Pointer(fSkipChars)^, Length(fSkipChars));
  WriteStr(IntToStr(Value));
end;

procedure YDbDofTextWriter.WriteQuad(const Value: UInt64);
begin
  if fForceSkip then Write(Pointer(fSkipChars)^, Length(fSkipChars));
  WriteStr(IntToStr(Value));
end;

procedure YDbDofTextWriter.WriteRootClass(Instance: TObject);
var
  ifInfo: IClassTypeInfo;
begin
  if not Assigned(fOnLookup) then Exit;
  fOnLookup(Instance.ClassName, ifInfo);
  if ifInfo = nil then Exit;
  WriteClass(Instance, ifInfo);
end;

procedure YDbDofTextWriter.WriteSet(Value: Int32; const Info: ISetTypeInfo);
var
  sSet: string;
begin
  Info.SetToString(Value, sSet);
  if fForceSkip then Write(Pointer(fSkipChars)^, Length(fSkipChars));
  WriteStr(sSet);
end;

procedure YDbDofTextWriter.WriteSingle(const Value: Single);
begin
  if fForceSkip then Write(Pointer(fSkipChars)^, Length(fSkipChars));
  WriteStr(FloatToStr(Value));
end;

procedure YDbDofTextWriter.WriteSString(const Value: ShortString);
begin
  WriteString(Value);
end;

procedure YDbDofTextWriter.WriteStr(const Value: string);
begin
  Write(Pointer(Value)^, Length(Value));
end;

procedure YDbDofTextWriter.WriteString(const Value: string);
begin
  if fForceSkip then Write(Pointer(fSkipChars)^, Length(fSkipChars));
  WriteStr('''');
  WriteStr(Value);
  Writeln('''');
end;

procedure YDbDofTextWriter.WriteWord(Value: UInt16);
begin
  if fForceSkip then Write(Pointer(fSkipChars)^, Length(fSkipChars));
  WriteStr(IntToStr(Value));
end;

procedure YDbDofTextWriter.WriteWString(const Value: WideString);
begin
  if fForceSkip then Write(Pointer(fSkipChars)^, Length(fSkipChars));
  WriteStr('''');
  Write(Pointer(Value)^, Length(Value) * 2);
  Writeln('''');
end;

{ YDbDofTextReader }

procedure YDbDofTextReader.BeginRead;
begin
  fParser := TParser.Create(Stream, nil);
end;

procedure YDbDofTextReader.Clear;
begin
  FreeAndNil(fParser);
end;

destructor YDbDofTextReader.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure YDbDofTextReader.EndRead;
begin
  Clear;
end;

function YDbDofTextReader.IsCollectionEnd: Boolean;
begin
  Result := fParser.Token = ']';
end;

function YDbDofTextReader.IsListEnd: Boolean;
begin
  Result := fParser.Token = ')';
end;

procedure YDbDofTextReader.ReadBinary(Stream: TStream);
begin
  fParser.HexToBinary(Stream);
end;

function YDbDofTextReader.ReadByte: UInt8;
begin
  fParser.NextToken;
  Result := fParser.TokenInt;
end;

const
  { DOF text symbols }
  DOF_SYMPREFIX     = '~';
  DOF_CLASS         = 'object';
  DOF_CUSTOM        = 'custom';
  DOF_ITEM          = 'item';
  DOF_END           = 'end';

procedure YDbDofTextReader.ReadClass(Instance: TObject; const Info: IClassTypeInfo);
begin
  fParser.CheckToken('~');
  fParser.NextToken;
  fParser.CheckTokenSymbol(DOF_CLASS);
  fParser.NextToken;
  ReadClassNoHeader(Instance, Info);
end;

procedure YDbDofTextReader.ReadClassNoHeader(Instance: TObject; const Info: IClassTypeInfo);
var
  ifSer: IDofStreamable;
  ifInfo: IClassTypeInfo;
  sClass: string;
begin
  sClass := fParser.TokenString;
  if not Assigned(Info) then
  begin
    if not Assigned(fOnLookup) then Exit;
    fOnLookup(sClass, ifInfo);
  end else ifInfo := Info;

  if not Supports(Instance, IDofStreamable, ifSer) then ifSer := nil;

  fParser.NextToken;
  while ReadProperty(Instance, ifInfo, ifSer) do;
end;

procedure YDbDofTextReader.ReadCollectionEnd;
begin
  fParser.CheckToken(']');
  fParser.NextToken;
end;

procedure YDbDofTextReader.ReadCollectionItemEnd;
begin
  fParser.CheckToken('~');
  fParser.NextToken;
  fParser.CheckTokenSymbol(DOF_END);
  fParser.NextToken;
end;

procedure YDbDofTextReader.ReadCollectionItemStart;
begin
  fParser.CheckToken('~');
  fParser.NextToken;
  fParser.CheckTokenSymbol(DOF_ITEM);
  fParser.NextToken;
end;

procedure YDbDofTextReader.ReadCollectionStart;
begin
  fParser.CheckToken('[');
  fParser.NextToken;
end;

function YDbDofTextReader.ReadCustomProperty(const Prop: string;
  Reader: YDofReaderMethod): Boolean;
begin
  Result := fParser.TokenSymbolIs(Prop);
  if Result then
  begin
    fParser.NextToken;
    fParser.CheckToken('=');
    fParser.NextToken;
    Reader(Self);
  end;
end;

function YDbDofTextReader.ReadDouble: Double;
begin
  Result := fParser.TokenFloat;
  fParser.NextToken;
end;

function YDbDofTextReader.ReadEnum: Int32;
begin

end;

function YDbDofTextReader.ReadExtended: Extended;
begin
  Result := fParser.TokenFloat;
  fParser.NextToken;
end;

procedure YDbDofTextReader.ReadListEnd;
begin
  fParser.CheckToken(')');
  fParser.NextToken;
end;

procedure YDbDofTextReader.ReadListStart;
begin
  fParser.CheckToken('(');
  fParser.NextToken;
end;

function YDbDofTextReader.ReadLong: UInt32;
begin
  Result := fParser.TokenInt;
  fParser.NextToken;
end;

function YDbDofTextReader.ReadProperty(Instance: TObject; const Info: IClassTypeInfo; const Ser: IDofStreamable): Boolean;
var
  sProp: string;
  sSet: string;
  ifProp: IPropertyInfo;
  pInfo: PPropInfo;
  cInst: TObject;
begin
  if fParser.Token = '~' then
  begin
    fParser.NextToken;
    if fParser.TokenSymbolIs(DOF_CUSTOM) then
    begin
      fParser.NextToken;
      if Assigned(Ser) then
      begin
        Ser.ReadCustomProperties(Self);
        Result := True;
      end else
      begin
        Result := False;
        fParser.NextToken;
      end;
    end else if fParser.TokenSymbolIs(DOF_END) then
    begin
      Result := False;
      fParser.NextToken;
    end else
    begin
      fParser.ErrorFmt('Unknown attribute %s at line %d', [fParser.TokenString, fParser.SourceLine]);
      Result := False;
      fParser.NextToken;
    end;
  end else
  begin
    sProp := fParser.TokenString;
    ifProp := Info.GetPropByName(sProp);
    if Assigned(ifProp) then
    begin
      fParser.NextToken;
      fParser.CheckToken('=');
      fParser.NextToken;
      pInfo := ifProp.PropInfo;
      Result := True;
      case pInfo.PropType^.Kind of
        tkInteger, tkChar, tkWChar:
        begin
          SetOrdProp(Instance, pInfo, fParser.TokenInt);
          fParser.NextToken;
        end;
        tkEnumeration:
        begin
          SetEnumProp(Instance, pInfo, fParser.TokenString);
          fParser.NextToken;
        end;
        tkSet:
        begin
          fParser.CheckToken('[');
          fParser.NextToken;
          sSet := fParser.TokenString;
          fParser.NextToken;
          fParser.CheckToken(']');
          SetSetProp(Instance, pInfo, sSet);
          fParser.NextToken;
        end;
        tkFloat:
        begin
          SetFloatProp(Instance, pInfo, fParser.TokenFloat);
          fParser.NextToken;
        end;
        tkInt64:
        begin
          SetInt64Prop(Instance, pInfo, fParser.TokenInt);
          fParser.NextToken;
        end;
        tkString, tkLString:
        begin
          SetStrProp(Instance, pInfo, fParser.TokenString);
          fParser.NextToken;
        end;
        tkWString:
        begin
          SetWideStrProp(Instance, pInfo, fParser.TokenWideString);
          fParser.NextToken;
        end;
        tkClass:
        begin
          cInst := GetObjectProp(Instance, pInfo, nil);
          if cInst = nil then
          begin
            cInst := (ifProp.PropertyType as IClassTypeInfo).ClassReference.Create;
            SetObjectProp(Instance, pInfo, cInst);
          end;

          ReadClass(cInst, ifProp.PropertyType as IClassTypeInfo);
        end;
      else
        fParser.ErrorFmt('Unknown type %s for property %s expected at line %d.', [sProp, ifProp.PropertyType.Name, fParser.SourceLine]);
        Result := False;
        fParser.NextToken;
      end;
    end else
    begin
      fParser.ErrorFmt('Undeclared property %s at line %d.', [sProp, fParser.SourceLine]);
      Result := False;
      fParser.NextToken;
    end;
  end;
end;

function YDbDofTextReader.ReadQuad: UInt64;
begin
  Result := fParser.TokenInt;
  fParser.NextToken;
end;

procedure YDbDofTextReader.ReadRootClass(Instance: TObject);
var
  ifInfo: IClassTypeInfo;
begin
  if not Assigned(fOnLookup) then Exit;
  fOnLookup(Instance.ClassName, ifInfo);
  if ifInfo = nil then Exit;
  ReadClass(Instance, ifInfo);
end;

function YDbDofTextReader.ReadSet: Int32;
begin

end;

function YDbDofTextReader.ReadSingle: Single;
begin
  Result := fParser.TokenFloat;
  fParser.NextToken;
end;

procedure YDbDofTextReader.ReadSString(var Str: ShortString);
begin
  Str := fParser.TokenString;
  fParser.NextToken;
end;

function YDbDofTextReader.ReadString: string;
begin
  Result := fParser.TokenString;
  fParser.NextToken;
end;

function YDbDofTextReader.ReadWord: UInt16;
begin
  fParser.NextToken;
  Result := fParser.TokenInt;
end;

function YDbDofTextReader.ReadWString: WideString;
begin
  Result := fParser.TokenWideString;
  fParser.NextToken;
end;

end.
