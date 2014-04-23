{*------------------------------------------------------------------------------
  Registry storing data about serializable types.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Framework.SerializationRegistry;

interface

uses
  TypInfo,
  SysUtils,
  Misc.Containers,
  Misc.TypInfoEx,
  Misc.Algorithm,
  Framework.Base,
  Framework.TypeRegistry;

type
  TSerializationRegistry = class;

  TDataType = (dtBinary, dtText); { What else? }
  TDatabaseOperation = (doLoad, doSave, doSizeQuery);

  { This callback prototype is not nice, I know. But it must have pointers as its
    params. iDbOp is doLoad or doSave. pDataPtr points to the memory from which
    should be read (on save) or written to (on load) and pInOutBuf contains pointer
    to the read buffer (on load) or to the write buffer (on save). iInOutType can
    be either dtBinary or dtText. dtText is sent by the PkTT engine, DBC and PCP
    send dtBinary. SQL DB should also send dtText. pInfoEx contains a pointer to
    the YTypeInfoEx structure. }
  TTypeProcessingCallback = procedure(DataPtr: Pointer; DbOp: TDatabaseOperation;
    InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);

  { A few words on these callbacks. In case of text-based DBs (like PkTT, SQL etc.),
    the pInOutBuf is always a PString. So dereferencing it will give you the input string
    on load or the output string on save. But in case of binary DBs (DBC, PCP) the
    situation is very different. DBC is a strict database, it can store only 32-bit ints,
    32-bit floats and null-terminated strings that's why there are no problems with it.
    In case of ints, the pInOutBuf is a PInteger, in case of floats PSingle and in case
    of strings it is PPChar. However since PCP was designed to save almost any type of
    data, the flexibility comes at a price. Not speed luckily, but complexity. Everything
    mentioned above works also for PCP, with the difference that when saving strings,
    the pInOutBuf is a PString, not PPChar. But PCP can save also smaller or bigger
    types than 32-bit. In case of saving bytes, pInOutBuf is PByte, words - PWord,
    Int64 - PInt64. When saving enums or sets, it uses the YTypeInfoEx structure
    to get the size of the type and reserves as many bytes as required (enums 1-4 bytes,
    sets 1-32 bytes). The "fun" part comes when you save binary streams or arrays.
    The pInOutBuf points to the NUMBER of elements in the array or the size of the
    structure. The value of the first element is stored at an address 4 bytes AFTER
    the pInOutBuf pointer. Note that when you'll want to do a new binary medium type,
    use the same convensions. This is needed to ensure that only 1 type processor
    per type is needed.

    Summarized:
      Text-based DB engines:
        pInOutBuf => always a pointer to the input/output string (PString)

      Binary-based DB engines:
        pInOutBuf => most of the time pointer to a buffer which is big enough to
          write data to or read from without causing stack overflows

          Examples:
            Byte -> PByte
            Word -> PWord
            Longword -> PLongword
            Int64 -> PInt64
            string -> PString
            PChar -> PPChar
            Array or Binary -> PInteger(Length) + Data

          Tip: Use a 32-byte union (the maximum size for integer data).
  }

  PSerializableTypeInfo = ^TSerializableTypeInfo;
  TSerializableTypeInfo = record
    TypeProcessingProc: TTypeProcessingCallback;
    Info: ITypeInfo;
  end;

  PSerializableFieldData = ^TSerializableFieldData;
  TSerializableFieldData = record
    Name: string;
    Offset: Int32;
    Info: PSerializableTypeInfo;
  end;

  PSerializationData = ^TSerializationData;
  TSerializationData = record
    Name: string;
    Map: TStrPtrHashMap;
    Data: array of TSerializableFieldData;
  end;

  TSerializationRegistry = class(TBaseInterfacedObject)
    private
      fProcessingMap: TStrPtrHashMap;
      fProcessingList: TPtrArrayList;
      fSerialMap: TStrPtrHashMap;
      fSerialList: TPtrArrayList;
      fCurrObj: Pointer;
      fCurrData: PSerializationData;
      
      procedure RegisterDefaultSerializableTypes;
    public
      constructor Create;
      destructor Destroy; override;

      { Registers a function to be executed }
      procedure RegisterTypeProcessingCallback(const TypeName: string;
        Callback: TTypeProcessingCallback);

      { Registers an alias for an already registered type }
      procedure RegisterTypeProcessingAlias(const TypeName: string; const Alias: string);

      { Starts a generic type registration block. }
      function SerializableRegistrationBegin(Instance: Pointer; const TypeName: string): Boolean;

      { Registers a generic field. It can be anything, its type is resolved by its name. }
      procedure RegisterField(Offset: Pointer; const Name: string;
        const TypeName: string);

      { Ends a generic type registration block. }
      procedure SerializableRegistrationEnd;

      { Invokes a serialization routine for the specified field name in the specified type instance. }
      procedure InvokeSerializationRoutine(Instance: Pointer; InOutBuf: Pointer;
        DbOperation: TDatabaseOperation; DataType: TDataType; const FieldName: string;
        Data: PSerializationData; out Error: string);

      { Returns type-specific serialization data. }
      function GetTypeDataByName(const TypeName: string): PSerializationData;
    end;

{$REGION 'Type processors'}
{ Used to load/store 8-bit quantities. }
procedure Int8Processor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);

{ Used to load/store 16-bit quantities. }
procedure Int16Processor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);

{ Used to load/store 32-bit quantities. }
procedure Int32Processor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);

{ Used to load/store 64-bit quantities. }
procedure Int64Processor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);

{ Used to load/store 32-bit floating-point numbers. }
procedure SingleProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);

{ Used to load/store ANSI strings. }
procedure StringProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);

{ Used to load/store C-style strings (null-terminated). }
procedure CStringProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);

{ Used to load/store enumeratons. }
procedure EnumProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const InfoEx: IEnumerationTypeInfo; var Error: string);

{ Used to load/store sets. All sizes (1-32 bytes) supported. }
procedure SetProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const InfoEx: ISetTypeInfo; var Error: string);

{ Used to load/store dynamic arrays of 8-bit quantities. }
procedure Int8ArrayProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);

{ Used to load/store dynamic arrays of 16-bit quantities. }
procedure Int16ArrayProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);

{ Used to load/store dynamic arrays of 32-bit quantities. }
procedure Int32ArrayProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);

{ Used to load/store dynamic arrays of 64-bit quantities. }
procedure Int64ArrayProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);

{ Used to load/store dynamic arrays of singles (32-bit floating point). }
procedure SingleArrayProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);

{ Used to load/store dynamic arrays of strings. }
procedure StringArrayProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);
{$ENDREGION}

const
  DB_BIN_LOAD = 0;
  DB_TEXT_SAVE = 1;
  DB_BIN_SAVE = 2;
  DB_TEXT_LOAD = 3;
  DB_SIZE_QUERY = 4;

  ProcessingTypeTable: array[TDatabaseOperation, TDataType] of Integer = (
    (DB_BIN_LOAD, DB_TEXT_LOAD),
    (DB_BIN_SAVE, DB_TEXT_SAVE),
    (DB_SIZE_QUERY, DB_SIZE_QUERY)
  );

implementation

uses
  Framework,
  Framework.Resources,
  Misc.Miscleanous,
  Misc.Resources;

{$REGION 'Type processors and related routines'}
procedure Int8Processor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);
var
  iValue: Int32;
begin
  case ProcessingTypeTable[DbOp, InOutType] of
    DB_BIN_LOAD: PByte(DataPtr)^ := PByte(InOutBuf)^;
    DB_BIN_SAVE: PByte(InOutBuf)^ := PByte(DataPtr)^;
    DB_TEXT_LOAD:
    begin
      if not TryStrToInt(PString(InOutBuf)^, iValue) then
      begin
        Error := 'Integer value expected.';
      end else PByte(DataPtr)^ := UInt8(iValue);
    end;
    DB_TEXT_SAVE: PString(InOutBuf)^ := itoa(PByte(DataPtr)^);
    DB_SIZE_QUERY: PLongword(InOutBuf)^ := SizeOf(Byte);
  end;
end;

procedure Int16Processor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);
var
  iValue: Int32;
begin
  case ProcessingTypeTable[DbOp, InOutType] of
    DB_BIN_LOAD: PWord(DataPtr)^ := PWord(InOutBuf)^;
    DB_BIN_SAVE: PWord(InOutBuf)^ := PWord(DataPtr)^;
    DB_TEXT_LOAD:
    begin
      if not TryStrToInt(PString(InOutBuf)^, iValue) then
      begin
        Error := 'Integer value expected.';
      end else PWord(DataPtr)^ := UInt16(iValue);
    end;
    DB_TEXT_SAVE: PString(InOutBuf)^ := itoa(PWord(DataPtr)^);
    DB_SIZE_QUERY: PLongword(InOutBuf)^ := SizeOf(Word);
  end;
end;

procedure Int32Processor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);
begin
  case ProcessingTypeTable[DbOp, InOutType] of
    DB_BIN_LOAD: PLongword(DataPtr)^ := PLongword(InOutBuf)^;
    DB_BIN_SAVE: PLongword(InOutBuf)^ := PLongword(DataPtr)^;
    DB_TEXT_LOAD:
    begin
      if not TryStrToUInt(PString(InOutBuf)^, PLongword(DataPtr)^) then
      begin
        Error := 'Integer value expected.';
      end;
    end;
    DB_TEXT_SAVE: PString(InOutBuf)^ := itoa(PLongword(DataPtr)^);
    DB_SIZE_QUERY: PLongword(InOutBuf)^ := SizeOf(Longword);
  end;
end;

procedure Int64Processor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);
begin
  case ProcessingTypeTable[DbOp, InOutType] of
    DB_BIN_LOAD: PInt64(DataPtr)^ := PInt64(InOutBuf)^;
    DB_BIN_SAVE: PInt64(InOutBuf)^ := PInt64(DataPtr)^;
    DB_TEXT_LOAD:
    begin
      if not TryStrToInt64(PString(InOutBuf)^, PInt64(DataPtr)^) then
      begin
        Error := 'Integer value expected.';
      end;
    end;
    DB_TEXT_SAVE: PString(InOutBuf)^ := itoa(PInt64(DataPtr)^);
    DB_SIZE_QUERY: PLongword(InOutBuf)^ := SizeOf(Int64);
  end;
end;

procedure SingleProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);
begin
  case ProcessingTypeTable[DbOp, InOutType] of
    DB_BIN_LOAD: PFloat(DataPtr)^ := PFloat(InOutBuf)^;
    DB_BIN_SAVE: PFloat(InOutBuf)^ := PFloat(DataPtr)^;
    DB_TEXT_LOAD:
    begin
      if not TextBufToFloat(PChar(PString(InOutBuf)^), PFloat(DataPtr)^) then
      begin
        Error := 'Float value expected.';
      end;
    end;
    DB_TEXT_SAVE: PString(InOutBuf)^ := ftoa(PFloat(DataPtr)^);
    DB_SIZE_QUERY: PLongword(InOutBuf)^ := SizeOf(Single);
  end;
end;

procedure StringProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);
begin
  case ProcessingTypeTable[DbOp, InOutType] of
    DB_BIN_LOAD, DB_TEXT_LOAD: PString(DataPtr)^ := PString(InOutBuf)^;
    DB_BIN_SAVE, DB_TEXT_SAVE: PString(InOutBuf)^ := PString(DataPtr)^;
    DB_SIZE_QUERY: PLongword(InOutBuf)^ := Length(PString(DataPtr)^);
  end;
end;

procedure CStringProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);
begin
  case ProcessingTypeTable[DbOp, InOutType] of
    DB_BIN_LOAD: StrCopy(PPChar(DataPtr)^, PPChar(InOutBuf)^);
    DB_BIN_SAVE: StrCopy(PPChar(InOutBuf)^, PPChar(DataPtr)^);
    DB_TEXT_LOAD: PPChar(DataPtr)^ := PChar(PString(InOutBuf)^);
    DB_TEXT_SAVE: PString(InOutBuf)^ := PPChar(DataPtr)^;
    DB_SIZE_QUERY: PLongword(InOutBuf)^ := StrLen(PPChar(DataPtr)^);
  end;
end;

procedure EnumProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const InfoEx: IEnumerationTypeInfo; var Error: string);
begin
  case ProcessingTypeTable[DbOp, InOutType] of
    DB_BIN_LOAD:
    begin
      case InfoEx.OrdinalType of
        otSByte, otUByte: PByte(DataPtr)^ := PByte(InOutBuf)^;
        otSWord, otUWord: PWord(DataPtr)^ := PWord(InOutBuf)^;
        otSLong, otULong: PLongword(DataPtr)^ := PLongword(InOutBuf)^;
      end;
    end;
    DB_BIN_SAVE:
    begin
      case InfoEx.OrdinalType of
        otSByte, otUByte: PByte(InOutBuf)^ := PByte(DataPtr)^;
        otSWord, otUWord: PWord(InOutBuf)^ := PWord(DataPtr)^;
        otSLong, otULong: PLongword(InOutBuf)^ := PLongword(DataPtr)^;
      end;
    end;
    DB_TEXT_LOAD:
    begin
      case InfoEx.OrdinalType of
        otSByte, otUByte: PByte(DataPtr)^ := InfoEx.Value[PString(InOutBuf)^];
        otSWord, otUWord: PWord(DataPtr)^ := InfoEx.Value[PString(InOutBuf)^];
        otSLong, otULong: PLongword(DataPtr)^ := InfoEx.Value[PString(InOutBuf)^];
      end;
    end;
    DB_TEXT_SAVE:
    begin
      case InfoEx.OrdinalType of
        otSByte, otUByte: PString(InOutBuf)^ := InfoEx.Names[PByte(DataPtr)^];
        otSWord, otUWord: PString(InOutBuf)^ := InfoEx.Names[PWord(DataPtr)^];
        otSLong, otULong: PString(InOutBuf)^ := InfoEx.Names[PLongword(DataPtr)^];
      end;
    end;
    DB_SIZE_QUERY:
    begin
      case InfoEx.OrdinalType of
        otSByte, otUByte: PLongword(InOutBuf)^ := SizeOf(Byte);
        otSWord, otUWord: PLongword(InOutBuf)^ := SizeOf(Word);
        otSLong, otULong: PLongword(InOutBuf)^ := SizeOf(Longword);
      end;
    end;
  end;
end;

procedure SetProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const InfoEx: ISetTypeInfo; var Error: string);
begin
  case ProcessingTypeTable[DbOp, InOutType] of
    DB_BIN_LOAD: Move(InOutBuf^, DataPtr^, InfoEx.Size);
    DB_BIN_SAVE: Move(DataPtr^, InOutBuf^, InfoEx.Size);
    DB_TEXT_LOAD: InfoEx.StringToSet(PString(InOutBuf)^, DataPtr^);
    DB_TEXT_SAVE: InfoEx.SetToString(DataPtr^, PString(InOutBuf)^);
    DB_SIZE_QUERY: PLongword(InOutBuf)^ := InfoEx.Size;
  end;
end;

procedure Int8ArrayProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);
begin
end;

procedure Int16ArrayProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);
begin
end;

procedure Int32ArrayProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);
var
  iSize: Integer;
begin
  case ProcessingTypeTable[DbOp, InOutType] of
    DB_BIN_LOAD:
    begin
      iSize := PInt32(InOutBuf)^ div SizeOf(Longword);
      Inc(PByte(InOutBuf), SizeOf(iSize));
      SetLength(TLongWordDynArray(DataPtr^), iSize);
      Move(InOutBuf^, DataPtr^, iSize * SizeOf(Longword));
    end;
    DB_BIN_SAVE: Move(TLongWordDynArray(DataPtr^)[0], InOutBuf^, Length(TLongWordDynArray(DataPtr^)) * SizeOf(Longword));
    DB_TEXT_LOAD: StringToDynArray(PString(InOutBuf)^, TLongWordDynArray(DataPtr^));
    DB_TEXT_SAVE: PString(InOutBuf)^ := ArrayToString(TLongWordDynArray(DataPtr^));
    DB_SIZE_QUERY: PLongword(InOutBuf)^ := Length(TLongWordDynArray(DataPtr^)) * SizeOf(Longword);
  end;
end;

procedure Int64ArrayProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);
begin
end;

procedure SingleArrayProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);
begin
  case ProcessingTypeTable[DbOp, InOutType] of
    DB_BIN_LOAD: Move(InOutBuf^, DataPtr^, Length(TSingleDynArray(InOutBuf^)) * 4);
    DB_BIN_SAVE: Move(DataPtr^, InOutBuf^, Length(TSingleDynArray(DataPtr^)) * 4);
    DB_TEXT_LOAD: StringToDynArray(PString(InOutBuf)^, TSingleDynArray(DataPtr^));
    DB_TEXT_SAVE: PString(InOutBuf)^ := ArrayToString(TSingleDynArray(DataPtr^));
    DB_SIZE_QUERY: PLongword(InOutBuf)^ := Length(TSingleDynArray(DataPtr^));
  end;
end;

procedure StringArrayProcessor(DataPtr: Pointer; DbOp: TDatabaseOperation;
  InOutBuf: Pointer; InOutType: TDataType; const Info: ITypeInfo; var Error: string);
begin
  case ProcessingTypeTable[DbOp, InOutType] of
    DB_BIN_LOAD, DB_TEXT_LOAD: TStringDynArray(DataPtr^) := StringSplit(PString(InOutBuf)^);
    DB_BIN_SAVE, DB_TEXT_SAVE: PString(InOutBuf)^ := ArrayToString(TStringDynArray(DataPtr^));
    DB_SIZE_QUERY: PLongword(InOutBuf)^ := Length(TStringArray(DataPtr^));
  end;
end;
{$ENDREGION}

function CalcOffset(PtrWhat, PtrFrom: Pointer): Integer; inline;
begin
  Result := Integer(PtrWhat) - Integer(PtrFrom);
end;

{ YSerializationRegistry }

constructor TSerializationRegistry.Create;
begin
  inherited Create;
  fSerialMap := TStrPtrHashMap.Create(False, 128);
  fSerialList := TPtrArrayList.Create;
  fProcessingMap := TStrPtrHashMap.Create(False, 2048);
  fProcessingList := TPtrArrayList.Create;
  RegisterDefaultSerializableTypes;
end;

destructor TSerializationRegistry.Destroy;
var
  iInt: Int32;
  pData: PSerializationData;
begin
  for iInt := 0 to fSerialList.Size -1 do
  begin
    pData := fSerialList[iInt];
    pData^.Map.Free;
    Dispose(pData);
  end;

  for iInt := 0 to fProcessingList.Size -1 do
  begin
    Dispose(PSerializableTypeInfo(fProcessingList[iInt]));
  end;

  fProcessingMap.Free;
  fProcessingList.Free;
  fSerialMap.Free;
  fSerialList.Free;
  inherited Destroy;
end;

function TSerializationRegistry.GetTypeDataByName(const TypeName: string): PSerializationData;
begin
  Result := fSerialMap.GetValue(TypeName);
end;

procedure TSerializationRegistry.InvokeSerializationRoutine(Instance,
  InOutBuf: Pointer; DbOperation: TDatabaseOperation; DataType: TDataType;
  const FieldName: string; Data: PSerializationData; out Error: string);
var
  pFieldData: PSerializableFieldData;
  pDestPtr: Pointer;
begin
  Error := '';
  if Data <> nil then
  begin
    pFieldData := Data^.Map.GetValue(FieldName);
    if pFieldData <> nil then
    begin
      if pFieldData^.Info <> nil then
      begin
        pDestPtr := Pointer(Integer(Instance) + Integer(pFieldData^.Offset));
        pFieldData^.Info^.TypeProcessingProc(pDestPtr, DbOperation, InOutBuf, DataType,
          pFieldData^.Info^.Info, Error)
      end else raise EDatabaseException.CreateResFmt(@RsNoTypeProcessingCallback, [Data^.Name, pFieldData^.Name]);
    end;
  end;
end;

procedure TSerializationRegistry.RegisterDefaultSerializableTypes;
begin
  RegisterTypeProcessingCallback(SShortint, @Int8Processor);
  RegisterTypeProcessingCallback(SSmallint, @Int16Processor);
  RegisterTypeProcessingCallback(SInteger, @Int32Processor);
  RegisterTypeProcessingCallback(SInt64, @Int64Processor);
  RegisterTypeProcessingCallback(SSingle, @SingleProcessor);
  RegisterTypeProcessingCallback(SString, @StringProcessor);
  RegisterTypeProcessingCallback(SPChar, @CStringProcessor);
  RegisterTypeProcessingCallback(SBoolean, @EnumProcessor);
  RegisterTypeProcessingCallback(STByteArr, @Int8ArrayProcessor);
  RegisterTypeProcessingCallback(STWordArr, @Int16ArrayProcessor);
  RegisterTypeProcessingCallback(STLongwordArr, @Int32ArrayProcessor);
  RegisterTypeProcessingCallback(STInt64Arr, @Int64ArrayProcessor);
  RegisterTypeProcessingCallback(STSingleArr, @SingleArrayProcessor);
  RegisterTypeProcessingCallback(STStringArr, @StringArrayProcessor);

  RegisterTypeProcessingAlias(SShortint, SByte);
  RegisterTypeProcessingAlias(SShortint, SInt8);
  RegisterTypeProcessingAlias(SShortint, SUInt8);
  RegisterTypeProcessingAlias(SShortint, SChar);
  RegisterTypeProcessingAlias(SShortint, SAnsiChar);
  RegisterTypeProcessingAlias(SSmallint, SWord);
  RegisterTypeProcessingAlias(SSmallint, SInt16);
  RegisterTypeProcessingAlias(SSmallint, SUInt16);
  RegisterTypeProcessingAlias(SSmallint, SWideChar);
  RegisterTypeProcessingAlias(SInteger, SInt32);
  RegisterTypeProcessingAlias(SInteger, SUInt32);
  RegisterTypeProcessingAlias(SInteger, SLongword);
  RegisterTypeProcessingAlias(SInteger, SCardinal);
  RegisterTypeProcessingAlias(SInt64, SUInt64);
  RegisterTypeProcessingAlias(SInt64, SQuadword);
  RegisterTypeProcessingAlias(SSingle, SFloat);
  RegisterTypeProcessingAlias(SString, SAnsiString);
end;

function TSerializationRegistry.SerializableRegistrationBegin(Instance: Pointer;
  const TypeName: string): Boolean;
begin
  if fSerialMap.GetValue(TypeName) = nil then
  begin
    New(fCurrData);
    fCurrData^.Name := TypeName;
    fCurrData^.Map := TStrPtrHashMap.Create(False, 1024);
    fSerialMap.PutValue(TypeName, fCurrData);
    fSerialList.Add(fCurrData);
    fCurrObj := Instance;
    Result := True;
  end else Result := False;
end;

procedure TSerializationRegistry.SerializableRegistrationEnd;
var
  iInt: Int32;
begin
  if fCurrData = nil then Exit;
  for iInt := 0 to Length(fCurrData^.Data) -1 do
  begin
    fCurrData.Map.PutValue(fCurrData^.Data[iInt].Name, @fCurrData^.Data[iInt]);
  end;
  fCurrObj := nil;
  fCurrData := nil;
end;

procedure TSerializationRegistry.RegisterField(Offset: Pointer; const Name: string;
  const TypeName: string);
var
  pData: PSerializationData;
  iLen: Int32;
begin
  if fCurrData = nil then Exit;
  pData := fCurrData;
  iLen := Length(pData^.Data);
  SetLength(pData^.Data, iLen + 1);
  pData^.Data[iLen].Name := Name;
  pData^.Data[iLen].Offset := CalcOffset(Offset, fCurrObj);
  pData^.Data[iLen].Info := fProcessingMap.GetValue(TypeName);
end;

procedure TSerializationRegistry.RegisterTypeProcessingCallback(const TypeName: string;
  Callback: TTypeProcessingCallback);
var
  pData: PSerializableTypeInfo;
begin
  if not fProcessingMap.ContainsKey(TypeName) then
  begin
    New(pData);
    Assert(Assigned(Callback), 'No type processing callback was defined while registering a type.');
    pData^.TypeProcessingProc := Callback;
    pData^.Info := SystemTypeRegistry.GetTypeInfo(TypeName);
    fProcessingMap.PutValue(TypeName, pData);
    fProcessingList.Add(pData);
  end;
end;

procedure TSerializationRegistry.RegisterTypeProcessingAlias(const TypeName,
  Alias: string);
var
  pData: PSerializableTypeInfo;
begin
  pData := fProcessingMap.GetValue(TypeName);
  if pData <> nil then
  begin
    fProcessingMap.PutValue(Alias, pData);
  end;
end;

end.
