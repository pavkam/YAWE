unit PkttMedium;

interface

uses
  SysUtils,
  Classes,
  WideStrings,
  DbCommon,
  DataInterfaces;

type
  TDbPkttStorageMedium = class(TDbMemoryStorageMedium, IYesStorageMedium)
    private
      FSectionName: WideString;
      FFileName: WideString;
    protected
      procedure GetPropertyValueAsString(Instance: Pointer;
        const PropInfo: IPropertyInfo; out Value: WideString);

      procedure SetPropertyValueAsString(Instance: Pointer;
        const PropInfo: IPropertyInfo; const Value: WideString);

      procedure InitializeMedium(var Args: PWideChar); override;

      function CreateStorageContext(Instance: Pointer;
        const Intf: IYesSerializable): TDbStorageContext; override;
    public
      procedure Load; stdcall;
      procedure Save; stdcall;
      procedure ThreadSafeSave; stdcall;
  end;

  TDbPkttStorageContext = class(TDbStorageContext)
    private
      FUnknownFields: TWideStringList;
      FUnknownFieldCount: Integer;

      function GetUnkField(Index: Integer): WideString;
    public
      destructor Destroy; override;

      procedure Clear; override;

      procedure AddUnknownField(const Field, Value: WideString);

      property UnknownFields[Index: Integer]: WideString read GetUnkField;
      property UnknownFieldCount: Integer read FUnknownFieldCount;
  end;

procedure CreateDatabaseLayerInstance(out Db: IYesStorageMedium); stdcall;

exports
  CreateDatabaseLayerInstance;

implementation

uses
  RTLConsts,
  WideStrUtils,
  Bfg.Utils,
  Bfg.Threads,
  Bfg.Classes,
  Bfg.Unicode;

type
  TStreamHelper = class helper for TStream
    procedure Writeln(const S: string);
  end;

procedure CreateDatabaseLayerInstance(out Db: IYesStorageMedium); stdcall;
begin
  Db := TDbPkttStorageMedium.Create;
end;

{ TDbPkttStorageMedium }

procedure TDbPkttStorageMedium.InitializeMedium(var Args: PWideChar);
begin
  inherited InitializeMedium(Args);
  GetArg(Args, FFileName);
  GetArg(Args, FSectionName);
end;

function TDbPkttStorageMedium.CreateStorageContext(Instance: Pointer;
  const Intf: IYesSerializable): TDbStorageContext;
begin
  Result := TDbPkttStorageContext.Create(Instance, Intf);
end;

procedure TDbPkttStorageMedium.GetPropertyValueAsString(Instance: Pointer;
  const PropInfo: IPropertyInfo; out Value: WideString);
var
  Tmp: AnsiString;
begin
  case PropInfo.PropType of
    METADATA_PROPTYPE_INT:
    begin
      Value := WideIntToStr(PropInfo.GetOrdProp(Instance));
    end;
    METADATA_PROPTYPE_FLOAT:
    begin
      Value := WideFloatToStr(PropInfo.GetFloatProp(Instance));
    end;
    METADATA_PROPTYPE_STRING:
    begin
      SetLength(Tmp, PropInfo.GetStrProp(Instance, nil, 0));
      PropInfo.GetStrProp(Instance, Pointer(Tmp), Length(Tmp));
      Value := UTF8ToWideString(Tmp);
    end;
    METADATA_PROPTYPE_WSTRING:
    begin
      SetLength(Value, PropInfo.GetWideStrProp(Instance, nil, 0));
      PropInfo.GetWideStrProp(Instance, Pointer(Value), Length(Value));
    end;
    METADATA_PROPTYPE_ENUM:
    begin
      SetLength(Tmp, PropInfo.GetEnumProp(Instance, nil, 0));
      PropInfo.GetEnumProp(Instance, Pointer(Tmp), Length(Tmp));
      Value := UTF8ToWideString(Tmp);
    end;
    METADATA_PROPTYPE_FLAGS:
    begin
      SetLength(Tmp, PropInfo.GetFlagProp(Instance, nil, 0, True));
      PropInfo.GetFlagProp(Instance, Pointer(Tmp), Length(Tmp), True);
      Value := UTF8ToWideString(Tmp);
    end;
  end;
end;

procedure TDbPkttStorageMedium.SetPropertyValueAsString(Instance: Pointer;
  const PropInfo: IPropertyInfo; const Value: WideString);
var
  Temp: AnsiString;
begin
  case PropInfo.PropType of
    METADATA_PROPTYPE_INT:
    begin
      PropInfo.SetOrdProp(Instance, WideStrToIntDef(Value, 0));
    end;
    METADATA_PROPTYPE_FLOAT:
    begin
      PropInfo.SetFloatProp(Instance, WideStrToFloatDef(Value, 0));
    end;
    METADATA_PROPTYPE_STRING:
    begin
      Temp := WideStringToUtf8(Value);
      PropInfo.SetStrProp(Instance, PAnsiChar(Temp));
    end;
    METADATA_PROPTYPE_WSTRING:
    begin
      PropInfo.SetWideStrProp(Instance, PWideChar(Value));
    end;
    METADATA_PROPTYPE_ENUM:
    begin
      PropInfo.SetEnumProp(Instance, Pointer(WideStringToUTF8(Value)));
    end;
    METADATA_PROPTYPE_FLAGS:
    begin
      PropInfo.SetFlagProp(Instance, Pointer(WideStringToUTF8(Value)));
    end;
  end;
end;

const
  COUNT_HINT = 'ENTRYCOUNT';

function WEquals(S1, S2: PWideChar; MaxLen: Integer): Boolean;
var
  I: Integer;
begin
  if MaxLen <> 0 then
  begin
    I := 0;
    while (I < MaxLen) and (S1^ <> #0) and (S2^ <> #0) do
    begin
      if WideUpperCase(S1^) <> WideUpperCase(S2^) then
      begin
        Result := False;
        Exit;
      end;
      Inc(S1);
      Inc(S2);
    end;
  end;
  Result := True;
end;

procedure TDbPkttStorageMedium.Load;
var
  FS: TWideFileStream;
  TextStart: PWideChar;
  TextCurr: PWideChar;
  TextTemp: PWideChar;
  Section: PWideChar;
  Exc: string;
  FileData: string;
  FileDataConv: WideString;
  Field: WideString;
  Value: WideString;
  Len: Integer;
  Tmp: Integer;
  EntryId: Longword;
  Entry: IYesSerializable;
  Entry2: IYesSerializable2;
  Entry3: IDofStreamable;
  EntryRaw: Pointer;
  Err: string;
  I: Integer;
  LineCounter: Longword;
  EntryCountSet: Boolean;

  function ReadSectionHeader: Boolean;
  begin
    if TextCurr^ = '[' then
    begin
      EntryId := 0;
      Inc(TextCurr);
      TextTemp := TextCurr;

      while (TextTemp^ <> ' ') and (TextTemp^ <> ']') do Inc(TextTemp);

      if (TextTemp^ = ' ') and WEquals(TextCurr, Section, Len) then
      begin
        Inc(TextTemp);
        TextCurr := TextTemp;

        while (TextTemp^ <> #13) and (TextTemp^ <> #10) and (TextTemp^ <> ' ') and
          (TextTemp^ <> ']') do Inc(TextTemp);

        if TextTemp^ = ' ' then
        begin
          Tmp := 1;
          Inc(TextTemp);
          while TextTemp^ = ' ' do
          begin
            Inc(Tmp);
            Inc(TextTemp);
          end;
        end else Tmp := 0;

        if TextTemp^ = ']' then
        begin
          PWideChar(TextTemp - Tmp)^ := #0;
          EntryId := WideStrToInt(TextCurr);
          if EntryId <> 0 then
          begin
            EntryCountSet := True;

            InternalGetFreeClassInstance(Entry, @EntryRaw);
            Entry.UniqueId := EntryId;

            AddEntry(EntryId, Entry, EntryRaw);
          end;           
          Inc(TextTemp);
        end;
      end;
      TextCurr := TextTemp;
      Result := True;
    end else Result := False;
  end;

  function ReadComment: Boolean;
  begin
    if (TextCurr^ = ';') and (PWideChar(TextCurr+1)^ = ';') then
    begin
      Inc(TextCurr, 2);
      Result := True;
    end else Result := False;
  end;

  function ReadField: Boolean;
  var
    Prop: IPropertyInfo;
    S: string;
    Inst: Pointer;
    Reader: IDofReader;
    CtxTypeInfo: ITypeInfo;
    Ctx: IDofStreamable;
  begin
    if EntryId <> 0 then
    begin
      TextTemp := TextCurr;

      while (TextTemp^ <> ' ') and (TextTemp^ <> '=') do Inc(TextTemp);

      SetString(Field, TextCurr, TextTemp - TextCurr);

      while (TextTemp^ = ' ') or (TextTemp^ = '=') do Inc(TextTemp);

      TextCurr := TextTemp;

      while (TextTemp^ <> #13) and (TextTemp^ <> #10) and (TextTemp^ <> #0) do Inc(TextTemp);

      if TextCurr^ = '@' then
      begin
        // This is a streaming context
        Inc(TextCurr);
        SetString(Value, TextCurr, TextTemp - TextCurr);
        S := Field;

        (*
        Reader := YaweDBServices.CreateDofReader(Value);
        Reader.SetInput(RawData, RawDataSize);
        if CtxTypeInfo.QueryInterfaceProc(Inst, IDofStreamable, Ctx) = S_OK then
        begin
          Reader.ReadClass(Inst, CtxTypeInfo);
          Entry.Context[Pointer(S)] := Ctx;
        end;
        *)
      end else
      begin
        // A normal property
        SetString(Value, TextCurr, TextTemp - TextCurr);
        S := Field;
        Metadata.FindProperty(Pointer(S), Prop);
        if Assigned(Prop) then
        begin
          SetPropertyValueAsString(EntryRaw, Prop, Value);
        end else
        begin
          TDbPkttStorageContext(Entry.StorageContext).AddUnknownField(Field, Value);
        end;
      end;

      TextCurr := TextTemp;
      Result := True;
    end else Result := False;
  end;

  function ReadEntryCountHint: Boolean;
  begin
    if not EntryCountSet and (StrLICompW(TextCurr, COUNT_HINT, Length(COUNT_HINT)) = 0) then
    begin
      Inc(TextCurr, Length(COUNT_HINT));
      while TextCurr^ = ' ' do Inc(TextCurr);
      if TextCurr^ = '=' then
      begin
        Inc(TextCurr);

        while TextCurr^ = ' ' do Inc(TextCurr);

        TextTemp := TextCurr;

        while (TextTemp^ <> ' ') and (TextTemp^ <> #13) and (TextTemp^ <> #10) and
          (TextTemp^ <> #0) do Inc(TextTemp);

        TextTemp^ := #0;
        InternalAllocateNewClassBuffer(ForceAlignment(WideTextBufToUInt(TextCurr), 1024));
        EntryCountSet := True;
        TextCurr := TextTemp + 1;
      end;
      Result := True;
    end else Result := False;
  end;
begin
  if not WideFileExists(FFileName) then
  begin
    Exit;
    raise Exception.Create(Format({RsFileErrTTNo}'%s', [FFileName]));
  end;

  { Initialization Part }
  Exc := '';//RsUndefinedError;
  EntryId := 0;
  Entry := nil;
  EntryCountSet := False;
  Section := PWideChar(FSectionName);
  Len := Length(FSectionName);

  { Loading of the File }
  FS := TWideFileStream.Create(FFileName, fmOpenRead);
  try
    if FS.Handle <= 0 then
    begin
      Exc := '';//RsFileErrLoad;
      RaiseException(EXC_LOAD, FFileName, Exc);
    end;

    SetLength(FileData, FS.Size);
    FS.Read(Pointer(FileData)^, FS.Size);
    FileDataConv := UTF8ToWideString(FileData);

    TextStart := PWideChar(FileDataConv);
    TextCurr := TextStart;
  finally
    FS.Free;
  end;

  LockWriteBegin;
  try
    LineCounter := 1;

    while TextCurr^ <> #0 do
    begin
      while (TextCurr^ = ' ') or (TextCurr^ = #10) or (TextCurr^ = #13) do
      begin
        if TextCurr^ = #10 then Inc(LineCounter);
        Inc(TextCurr);
      end;
      if TextCurr^ = #0 then Break;

      if not ReadSectionHeader then
      if not ReadComment then
      if not ReadField then ReadEntryCountHint;

      while (TextCurr^ <> #13) and (TextCurr^ <> #0) do Inc(TextCurr);
    end;

    IdList.CustomSort(@TDbPkttStorageMedium.CompareSerializablesById);

    for I := 0 to IdList.Size -1 do
    begin
      if PIdListEntry(IdList[I])^.Intf.QueryInterface(IYesSerializable2, Entry2) = S_OK then
      begin
        Entry2.AfterLoad;
      end;
    end;
  finally
    LockWriteEnd;
  end;
end;

procedure TDbPkttStorageMedium.Save;
var
  Int, Idx: Int32;
  IdListEntry: PIdListEntry;
  Entry: IYesSerializable;
  EntryRaw: Pointer;
  Field: WideString;
  Temp: WideString;
  FS: TStream;
  PropInfo: IPropertyInfo;
  StorageCtx: TDbPkttStorageContext;
  Err: string;
begin
  if ReadOnlyMode then Exit;
  
  LockReadBegin;
  try
    FS := TCachedStream.Create(TWideFileStream.Create(FFileName, fmCreate), 0, -1, True);
    try
      FS.WriteLn(';; TT File generated by YAWE Server.');
      FS.WriteLn(';;');
      FS.WriteLn(COUNT_HINT + ' = ' + IntToStr(GetEntryCount));
      FS.WriteLn(';; Please do not remove the line above, it''s for speed up purposes.');
      FS.WriteLn(';; Removing it won''t break DB loading, but it will slow it down.');
      FS.WriteLn('');
      for Int := 0 to GetEntryCount -1 do
      begin
        IdListEntry := IdList[Int];
        Entry := IdListEntry^.Intf;
        EntryRaw := IdListEntry^.Instance;
        Temp := '[' + FSectionName + ' ' + WideIntToStr(Entry.UniqueId) + ']';
        FS.Writeln(WideStringToUTF8(Temp));
        for Idx := 0 to Metadata.PropertyCount -1 do
        begin
          PropInfo := Metadata.PropertyInfo[Idx];
          GetPropertyValueAsString(EntryRaw, PropInfo, Field);

          if Field <> '' then
          begin
            Temp := PropInfo.Name + ' = ' + Field;
            FS.WriteLn(WideStringToUTF8(Temp));
          end;
        end;

        StorageCtx := Entry.StorageContext;
        for Idx := 0 to StorageCtx.UnknownFieldCount -1 do
        begin
          FS.WriteLn(WideStringToUTF8(StorageCtx.UnknownFields[Idx]));
        end;
        
        FS.WriteLn('');
      end;
    finally
      FS.Free;
    end;
  finally
    LockReadEnd;
  end;
end;

procedure TDbPkttStorageMedium.ThreadSafeSave;
begin
  LockReadBegin;
  try
    Save;
  finally
    LockReadEnd;
  end;
end;

{ TStreamHelper }

procedure TStreamHelper.Writeln(const S: string);
begin
  Write(Pointer(S)^, Length(S));
  Write(sLineBreak, Length(sLineBreak));
end;

{ TDbPkttStorageContext }

procedure TDbPkttStorageContext.AddUnknownField(const Field, Value: WideString);
begin
  if not Assigned(FUnknownFields) then FUnknownFields := TWideStringList.Create;

  FUnknownFields.Add(Field + '=' + Value);
  Inc(FUnknownFieldCount);
end;

procedure TDbPkttStorageContext.Clear;
begin
  if Assigned(FUnknownFields) then
  begin
    FUnknownFields.Clear;
    FUnknownFieldCount := 0;
  end;
end;

destructor TDbPkttStorageContext.Destroy;
begin
  FUnknownFields.Free;
  inherited Destroy;
end;

function TDbPkttStorageContext.GetUnkField(Index: Integer): WideString;
begin
  if not Assigned(FUnknownFields) then
  begin
    raise EListError.CreateResFmt(@SListIndexError, [Index]);
  end;

  Result := FUnknownFields[Index];
end;

end.

