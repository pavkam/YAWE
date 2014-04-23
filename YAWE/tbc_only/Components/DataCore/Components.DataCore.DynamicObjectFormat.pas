{
  @Link http://www.yawe.co.uk
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
  Bfg.Utils,
  Bfg.Classes,
  Bfg.Metadata,
  Framework.Base;

type
  IDofReader = interface;
  IDofWriter = interface;

  YClassTypeLookupEvent = procedure(const ClassName: string; out Info: ITypeInfo) of object;

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
    detClass,
    detClassEnd,
    detAnsiString,
    detWideString,
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
    function ReadSingle: Single;
    function ReadDouble: Double;
    function ReadExtended: Extended;
    function ReadString: string;
    function ReadWString: WideString;
    procedure ReadClass(Instance: TObject; const Info: ITypeInfo);
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
    procedure WriteSingle(const Value: Single);
    procedure WriteDouble(const Value: Double);
    procedure WriteExtended(const Value: Extended);
    procedure WriteString(const Value: string);
    procedure WriteWString(const Value: WideString);
    procedure WriteClass(Instance: TObject; const Info: ITypeInfo);
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
      FOnLookup: YClassTypeLookupEvent;
    public
      procedure ReadRootClass(Instance: TObject); virtual; abstract;

      property OnLookup: YClassTypeLookupEvent read FOnLookup write FOnLookup;
  end;

  YDbDofBinaryReader = class(YDbDofAbstractReader, IDofReader)
    private
      FDefinitions: array of PDofClassInfoHeader;
      FClassNames: array of string;
      FDefinitionPropNames: array of TStringDynArray;

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
      function ReadSingle: Single;
      function ReadDouble: Double;
      function ReadExtended: Extended;
      function ReadString: string;
      function ReadWString: WideString;
      procedure ReadClass(Instance: TObject; const Info: ITypeInfo);
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
      FOnLookup: YClassTypeLookupEvent;
    public
      procedure BeginWrite; virtual; abstract;

      procedure WriteRootClass(Instance: TObject); virtual; abstract;

      procedure EndWrite; virtual; abstract;

      property OnLookup: YClassTypeLookupEvent read FOnLookup write FOnLookup;
  end;

  YDbDofBinaryWriter = class(YDbDofAbstractWriter, IDofWriter)
    private
      FDefinitions: array of PDofClassInfoHeader;
      FDefinitionBufsSize: Int32;
      FDefinitionClasses: array of TClass;
      FSavedHeaderPos: Int64;
      FFirstEntryPos: Int64;
      FEntryCount: Integer;

      procedure CreateDefinitionInfo(out Buffer: PDofClassInfoHeader;
        const Info: ITypeInfo);

      function FindDefinition(const Info: ITypeInfo): Int32;
      function AddDefinition(const Info: ITypeInfo): Int32;

      procedure WriteInstanceField(Instance: TObject; const PropInfo: IPropertyInfo;
        const Info: ITypeInfo);

      procedure Clear;
    public
      //constructor Create(const Metadata: ITypeInfo);
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
      procedure WriteSingle(const Value: Single);
      procedure WriteDouble(const Value: Double);
      procedure WriteExtended(const Value: Extended);
      procedure WriteString(const Value: string);
      procedure WriteWString(const Value: WideString);
      procedure WriteClass(Instance: TObject; const Info: ITypeInfo);
      procedure WriteListStart;
      procedure WriteListEnd;
      procedure WriteCollectionStart;
      procedure WriteCollectionEnd;
      procedure WriteCollectionItemStart;
      procedure WriteCollectionItemEnd;

      procedure EndWrite; override;
  end;

implementation

uses
  Framework,
  Bfg.Resources;

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
  for iIdx := 0 to Length(FDefinitions) -1 do
  begin
    FreeMem(FDefinitions[iIdx]);
  end;
  FDefinitions := nil;
  FDefinitionClasses := nil;
  FDefinitionBufsSize := 0;
  FSavedHeaderPos := 0;
  FFirstEntryPos := -1;
  FEntryCount := 0;
end;

procedure YDbDofBinaryWriter.CreateDefinitionInfo(out Buffer: PDofClassInfoHeader;
  const Info: ITypeInfo);
begin
(*
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
      tkLString: pElems^[iIdx] := detAnsiString;
      tkWString: pElems^[iIdx] := detWideString;
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
*)
end;

destructor YDbDofBinaryWriter.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function YDbDofBinaryWriter.AddDefinition(const Info: ITypeInfo): Int32;
begin
(*
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
*)
end;

function YDbDofBinaryWriter.FindDefinition(const Info: ITypeInfo): Int32;
begin
(*
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
  *)
end;

procedure YDbDofBinaryWriter.BeginWrite;
begin
  FSavedHeaderPos := Position;
  FFirstEntryPos := -1;
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

procedure YDbDofBinaryWriter.WriteExtended(const Value: Extended);
begin
  WriteElementType(detF80);
  Write(Value, SizeOf(Value));
end;

procedure YDbDofBinaryWriter.WriteInstanceField(Instance: TObject;
  const PropInfo: IPropertyInfo; const Info: ITypeInfo);
begin
(*
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
  *)
end;

procedure YDbDofBinaryWriter.EndWrite;
var
  iTmp: Int64;
  tHdr: YDofFileHeader;
  iIdx: Int32;
begin
  iTmp := Position;
  tHdr.ClassInfoOffset := Seek(0, soEnd) - FSavedHeaderPos;
  Position := FSavedHeaderPos;
  FSavedHeaderPos := 0;
  tHdr.Magic := DOF_MAGIC;
  tHdr.Size := Size + FDefinitionBufsSize;
  tHdr.ClassInfoCnt := Length(FDefinitions);
  tHdr.EntryCnt := FEntryCount;
  tHdr.EntryOffset := FFirstEntryPos;
  FFirstEntryPos := -1;
  Write(tHdr, SizeOf(tHdr));
  Position := iTmp;
  for iIdx := 0 to Length(FDefinitions) -1 do
  begin
    Write(FDefinitions[iIdx]^, FDefinitions[iIdx]^.Size);
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

procedure YDbDofBinaryWriter.WriteSingle(const Value: Single);
begin
  WriteElementType(detF32);
  Write(Value, SizeOf(Value));
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
  WriteElementType(detAnsiString);
  Len := Length(Value);
  Write(Len, SizeOf(Len));
  Write(Value[1], Len);
end;

procedure YDbDofBinaryWriter.WriteRootClass(Instance: TObject);
var
  ifInfo: ITypeInfo;
begin
  if not Assigned(FOnLookup) then Exit;
  FOnLookup(Instance.ClassName, ifInfo);
  if ifInfo = nil then Exit;
  WriteClass(Instance, ifInfo);
  Inc(FEntryCount);
end;

procedure YDbDofBinaryWriter.WriteClass(Instance: TObject; const Info: ITypeInfo);
begin
(*
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
  *)
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
  WriteElementType(detWideString);
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
  SetLength(FDefinitions, tHdr.ClassInfoCnt);
  SetLength(FDefinitionPropNames, tHdr.ClassInfoCnt);
  SetLength(FClassNames, tHdr.ClassInfoCnt);
  iLen := 0;
  while tHdr.ClassInfoCnt <> 0 do
  begin
    Read(iSize, SizeOf(iSize));
    pClassHdr := AllocMem(iSize);
    pClassHdr^.Size := iSize;
    Read(Pointer(PChar(pClassHdr) + SizeOf(iSize))^, iSize - 4);
    SetLength(FDefinitionPropNames[iLen], pClassHdr^.Count);
    pStr := PChar(pClassHdr) + SizeOf(YDofClassInfoHeader);
    FClassNames[iLen] := pStr;
    Inc(pStr, StrLen(pStr) + 1);
    Inc(pStr, pClassHdr^.Count * SizeOf(YDofElementType));
    iCnt := pClassHdr^.Count;
    iX := 0;
    while iCnt <> 0 do
    begin
      Dec(iCnt);
      FDefinitionPropNames[iLen, iX] := pStr;
      Inc(pStr, StrLen(pStr) + 1);
      Inc(iX);
    end;
    FDefinitions[iLen] := pClassHdr;

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
  for iIdx := 0 to Length(FDefinitions) -1 do
  begin
    FreeMem(FDefinitions[iIdx]);
  end;
  FDefinitions := nil;
  FDefinitionPropNames := nil;
  FClassNames := nil;
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

procedure YDbDofBinaryReader.ReadClass(Instance: TObject; const Info: ITypeInfo);
var
  iClsIndex: Int32;
  pTypes: PDofElemTypeArray;
  iIdx: Int32;
  ifStreamable: IDofStreamable;
begin
  iClsIndex := 0;
  CheckElemType(detClass);
  Read(iClsIndex, SizeOf(Byte));

  if iClsIndex >= Length(FDefinitions) then Error(@RsInvalidDofFormat);

  pTypes := Pointer(PChar(FDefinitions[iClsIndex]) + SizeOf(YDofClassInfoHeader) +
    Length(FClassNames[iClsIndex]) + 1);

  for iIdx := 0 to FDefinitions[iClsIndex]^.Count -1 do
  begin
    ReadField(Instance, FDefinitionPropNames[iClsIndex, iIdx], pTypes^[iIdx]);
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

function YDbDofBinaryReader.ReadExtended: Extended;
begin
  CheckElemType(detF80);
  Read(Result, SizeOf(Result));
end;

procedure YDbDofBinaryReader.ReadField(Instance: TObject; const PropName: string;
  ElemType: YDofElementType);
var
  ifInfo: ITypeInfo;
  cInst: TObject;
  sStr: ShortString;
begin
(*
  if IsPublishedProp(Instance, PropName) then
  begin
    case ElemType of
      detI8: SetOrdProp(Instance, PropName, ReadByte);
      detI16: SetOrdProp(Instance, PropName, ReadWord);
      detI32: SetOrdProp(Instance, PropName, ReadLong);
      detI64: SetInt64Prop(Instance, PropName, ReadQuad);
      detEnum: SetOrdProp(Instance, PropName, ReadEnum);
      detSet: SetOrdProp(Instance, PropName, ReadSet);
      detAnsiString: SetStrProp(Instance, PropName, ReadString);
      detSString:
      begin
        ReadSString(sStr);
        SetStrProp(Instance, PropName, sStr);
      end;
      detWideString: SetWideStrProp(Instance, PropName, ReadWString);
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
*)
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
  ifInfo: ITypeInfo;
begin
(*
  if not Assigned(fOnLookup) then Exit;
  fOnLookup(Instance.ClassName, ifInfo);
  if ifInfo = nil then Exit;
  ReadClass(Instance, ifInfo);
*)
end;

function YDbDofBinaryReader.ReadSingle: Single;
begin
  CheckElemType(detF32);
  Read(Result, SizeOf(Result));
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
  CheckElemType(detAnsiString);
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
  CheckElemType(detWideString);
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

end.
