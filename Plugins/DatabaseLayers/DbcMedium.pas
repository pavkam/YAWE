unit DbcMedium;

interface

uses
  Bfg.Containers,
  DataInterfaces,
  DbCommon;

type
  {$Z4}
  { Force DWORD size }
  PDbcDataType = ^TDbcDataType;
  TDbcDataType = (ddtInt, ddtFlt, ddtStr);
  {$Z1}

  TDbDbcStorageMedium = class(TDbMemoryStorageMedium, IYesStorageMedium)
    private
      FDbcDefFileName: WideString;
      FDbcFileName: WideString;
      FDefinitions: TStrIntHashMap;
      FDefinitionIndexes: TIntPtrHashMap;

      procedure SaveDbcFile;
      procedure LoadDbcDefinitionFile;
      procedure LoadDbcFile;
    protected
      procedure InitializeMedium(var Args: PWideChar); override;
    public
      constructor Create; override; 
      destructor Destroy; override;

      procedure Load; stdcall;
      procedure Save; stdcall;
      procedure ThreadSafeSave; stdcall;
  end;

procedure CreateDatabaseLayerInstance(out Db: IYesStorageMedium); stdcall;

procedure CreateDbcDefinitionFile(FileName: PWideChar; Idents: PPChar;
  Types: PDbcDataType; Count: Integer); stdcall;

exports
  CreateDatabaseLayerInstance,
  CreateDbcDefinitionFile;

implementation

uses
  SysUtils,
  Classes,
  Math,
  Bfg.Utils,
  Bfg.Classes;

const
  { Headers }
  DBC_HEADER = 'WDBC';
  DBCDEF_HEADER = 'WDBCDEF';

type
  PIndexRec = ^TIndexRec;
  TIndexRec = packed record
    Name: AnsiString;
    DataType: TDbcDataType;
  end;

  PDbcDefFileInformation = ^TDbcDefFileInformation;
  TDbcDefFileInformation = record
    DefinitionCount: Int32; { Number of definitions in the file }
    StringTableSize: Int32; { String table size - for file size comparison }
  end;

  PDbcFileInformation = ^TDbcFileInformation;
  TDbcFileInformation = record
    RecordCount: Int32;     { Number of records (entries) in the file }
    FieldCount: Int32;      { Number of fields per record }
    RecordSize: Int32;      { Size of a record - should be FieldCount * 4 }
    StringTableSize: Int32; { String table size - for file size comparison }
  end;

  PMultiPtr = ^MultiPtr;
  MultiPtr = record
    case Byte of
      0: (Quad: PInt64);
      1: (Long: PLongword);
      2: (Flt: PSingle);
      3: (Word: PWord);
      4: (Byte: PByte);
      5: (Char: PChar);
      6: (Str: PString);
      7: (Ptr: Pointer);
  end;

procedure CreateDbcDefinitionFile(FileName: PWideChar; Idents: PPChar;
  Types: PDbcDataType; Count: Integer);
var
  FS: TCachedWideFileStream;
  Idx: Integer;
  Len: Integer;
  StrLen: Integer;
  StringTableSize: Integer;
  TextStrTable: PPChar;
  TextStr: PChar;
  Exc: string;
  OutFile: string;
label
  __ExceptionOccured;
begin
  OutFile := FileName;

  FS := TCachedWideFileStream.Create(OutFile, fmCreate, 0, -1);
  try
    if FS.Handle <> 0 then
    begin
      { Successfully created a file }

      { We must have enough types defined }
      FS.Write(DBCDEF_HEADER, SizeOf(DBCDEF_HEADER));
      { Write the header }
      FS.Write(Len, SizeOf(Len));
      { Write number of fields per record }
      FS.Seek(SizeOf(Integer), soCurrent);
      { Seek 4 bytes - we don't know the size of the stringtable yet }
      FS.Write(Types^, 4 * Len);
      { Write all field types }
      FS.Seek(SizeOf(Char), soCurrent);
      { 1 byte = null-terminator }
      TextStrTable := Idents;
      StringTableSize := 1;
      for Idx := 0 to Len -1 do
      begin
        TextStr := TextStrTable^;
        { We get the string pointer }
        StrLen := PLongword(Longword(TextStr) - SizeOf(Longword))^ + 1;
        { We get the length - another trick to save the compiler some job (preserving Idents) }
        Inc(StringTableSize, StrLen);
        FS.Write(TextStr[0], StrLen);
        { And now we write the entire string (including null-terminator) }
        Inc(TextStrTable);
        { Iterate through the table }
      end;
      FS.Seek(11, soBeginning);
      FS.Write(StringTableSize, SizeOf(StringTableSize));
      { Now we know the string table size so we can write it }
      FS.Seek(0, soEnd);
      { To prevent the file being truncated }
    end else
    begin
      Exc := '';//RsFileErrSave;
      __ExceptionOccured:
      TDbDbcStorageMedium.RaiseException(EXC_SAVE, OutFile, Exc);
      { An exception has occured }
    end;
  finally
    FS.Free;
  end;
end;

procedure CreateDatabaseLayerInstance(out Db: IYesStorageMedium);
begin
  Db := TDbDbcStorageMedium.Create;
end;

{ TDbDbcStorageMedium }

constructor TDbDbcStorageMedium.Create;
begin
  inherited Create;
  FDefinitions := TStrIntHashMap.Create(True, 128);
  FDefinitionIndexes := TIntPtrHashMap.Create(128);
end;

destructor TDbDbcStorageMedium.Destroy;
var
  Itr: IPtrIterator;
begin
  Itr := FDefinitionIndexes.Values;
  while Itr.HasNext do
  begin
    Dispose(PIndexRec(Itr.Next));
  end;

  FDefinitions.Destroy;
  FDefinitionIndexes.Destroy;
  inherited Destroy;
end;

procedure TDbDbcStorageMedium.InitializeMedium(var Args: PWideChar);
begin
  inherited InitializeMedium(Args);
  GetArg(Args, FDbcFileName);
  GetArg(Args, FDbcDefFileName);
end;

procedure TDbDbcStorageMedium.Load;
begin
  LoadDbcDefinitionFile;
  LoadDbcFile;
end;

procedure TDbDbcStorageMedium.LoadDbcDefinitionFile;
var
  FS: TCachedFileStream;
  FileBuffer: Pointer;
  CurrPtr: MultiPtr;
  FileInfo: PDbcDefFileInformation;
  Int: Integer;
  TextStr: PChar;
  Str: string;
  IndexData: PIndexRec;
  Exc: string;
label
  __ExceptionOccured, __FreeMemAndRaiseException;
begin
  if not FileExists(FDbcDefFileName) then
  begin
    raise Exception.Create(Format({RsFileErrDBCNo2}'%s', [FDbcDefFileName]));
  end;
  Exc := '';//RsUndefinedError;
  FS := TCachedFileStream.Create(FDbcDefFileName, fmOpenRead, -1, 0);
  try
    if FS.Handle > 0 then
    begin
      { Needed to get the file size }
      if FS.Size < 16 then
      begin
        { 7 bytes Header, 8 bytes info and 1 byte null-terminator }
        Exc := '';//RsFileErrDBCCrpt2;
        goto __ExceptionOccured;
      end;
      GetMem(FileBuffer, FS.Size);
      { Allocate the buffer }
      if FS.Read(FileBuffer^, FS.Size) <> 0 then
      begin
        if CompareMem(FileBuffer, @DBCDEF_HEADER[1], 7) then
        begin
          { Passed header check }
          CurrPtr.Long := FileBuffer;
          Inc(CurrPtr.Byte, 7);
          { Skip the header }
          FileInfo := CurrPtr.Ptr;
          { Get the file info pointer }
          Inc(CurrPtr.Byte, 8);
          if FileInfo^.DefinitionCount * 4 + FileInfo^.StringTableSize + 15 = FS.Size then
          begin
            TextStr := CurrPtr.Ptr;
            Inc(TextStr, FileInfo^.DefinitionCount * 4 + 1);
            { Strings start right after all field type definitions }
            for Int := 0 to FileInfo^.DefinitionCount -1 do
            begin
              Str := UpperCase(TextStr);
              FDefinitions.PutValue(Str, Int + 1);
              { Add the value type by string key }
              New(IndexData);
              IndexData^.Name := Str;
              IndexData^.DataType := TDbcDataType(CurrPtr.Long^);
              FDefinitionIndexes.PutValue(Int, IndexData);
              { Add name and field type by ID }
              Inc(CurrPtr.Long);
              Inc(TextStr, Length(Str) + 1);
              { Advance file pointers }
            end;
          end else
          begin
            Exc := '';//RsFileErrCrpt;
            goto __FreeMemAndRaiseException;
          end;
        end else
        begin
          Exc := '';//RsFileErrDBCCrpt2;
          goto __FreeMemAndRaiseException;
        end;
      end else
      begin
        Exc := '';//RsFileErrRead;
        __FreeMemAndRaiseException:
        FreeMem(FileBuffer);
        goto __ExceptionOccured;
      end;
      FreeMem(FileBuffer);
      { Finally free the local file buffer }
    end else
    begin
      Exc := '';//RsFileErrLoad;
      __ExceptionOccured:
      RaiseException(EXC_LOAD, FDbcDefFileName, Exc);
      { An exception has occured }
    end;
  finally
    FS.Free;
  end;
end;

procedure TDbDbcStorageMedium.LoadDbcFile;
var
  FS: TCachedWideFileStream;
  FileBuffer: Pointer;
  CurrPtr: MultiPtr;
  FileInfo: PDbcFileInformation;
  X, Y: Int32;
  EntryId: UInt32;
  StringTable: PChar;
  Temp: string;
  Entry: IYesSerializable;
  Entry2: IYesSerializable2;
  EntryRaw: Pointer;
  IndexData: PIndexRec;
  Exc: string;
  Err: string;
label
  __ExceptionOccured, __FreeMemAndRaiseException, __FileCorruptError;
begin
  if not FileExists(FDbcFileName) then
  begin
    raise Exception.Create('DBC File "' + FDbcFileName + '" not found!');
  end;

  Entry := nil;

  LockWriteBegin;
  try
    FS := TCachedWideFileStream.Create(FDbcFileName, fmOpenRead, -1, 0);
    try
      if FS.Handle > 0 then
      begin
        { Needed to get the file size }
        if FS.Size < 21 then
        begin
          { 4 bytes header, 16 bytes info + 1 null terminator }
          Exc := '';//RsFileErrDBCCrpt;
          goto __ExceptionOccured;
        end;
        GetMem(FileBuffer, FS.Size);
        { Allocate temporary buffer }
        if FS.Read(FileBuffer^, FS.Size) <> 0 then
        begin
          { Read the whole file into our buffer }
          if CompareMem(FileBuffer, @DBC_HEADER[1], SizeOf(DBC_HEADER)) then
          begin
            { Header is ok }
            CurrPtr.Ptr := FileBuffer;
            Inc(CurrPtr.Byte, 4);
            { We'll continue from the end of the header }
            FileInfo := CurrPtr.Ptr;
            { We'll just point the pFileInfo pointer to the current position }
            Inc(CurrPtr.Byte, 16);
            if FileInfo^.RecordCount * FileInfo^.RecordSize + FileInfo^.StringTableSize + 20 = FS.Size then
            begin
              { Is the file size OK? }
              StringTable := CurrPtr.Ptr;
              Inc(StringTable, FileInfo^.RecordCount * FileInfo^.RecordSize); { Start of string fields }
  
              X := Max(ForceAlignment(FileInfo^.RecordCount, 1024),
                MEM_STORE_DEFAULT_CAPACITY);
              InternalAllocateNewClassBuffer(X);
  
              for X := 0 to FileInfo^.RecordCount -1 do
              begin
                EntryId := CurrPtr.Long^;
                InternalGetFreeClassInstance(Entry, @EntryRaw);

                AddEntry(EntryId, Entry, EntryRaw);

                if Entry.QueryInterface(IYesSerializable2, Entry2) = S_OK then
                begin
                  Entry2.AfterLoad;
                end;
                Inc(CurrPtr.Long);
                { First field is always the identifier }
                for Y := 1 to FileInfo^.FieldCount -1 do
                begin
                  IndexData := FDefinitionIndexes.GetValue(Y);
                  { Get the definition data about this particular data index }
                  if IndexData = nil then goto __FileCorruptError;
                  Err := '';
                  case IndexData^.DataType of
                    ddtInt, ddtFlt:
                    begin
                      { This value is an Integer or a Float }
                      //SystemSerializationRegistry.InvokeSerializationRoutine(Entry,
                      //  CurrPtr.Long, doLoad, dtBinary, IndexData^.Name, fClassData, Err);
                    end;
                    ddtStr:
                    begin
                      { In this case the current DWORD we point to is the offset from the stringtable,
                        where the actual string starts }
                      if Integer(CurrPtr.Long^) <= FileInfo^.StringTableSize then
                      begin
                        Temp := StringTable + CurrPtr.Long^;
                        //SystemSerializationRegistry.InvokeSerializationRoutine(Entry,
                         // @Temp, doLoad, dtText, IndexData^.Name, fClassData, Err);
                      end else goto __FileCorruptError;
                    end;
                  else
                    goto __FileCorruptError;
                  end;
                  Inc(CurrPtr.Long);
                  { Advance the buffer pointer }
                end;
              end;
            end else
            begin
              __FileCorruptError:
              Exc := '';//RsFileErrCrpt;
              goto __FreeMemAndRaiseException;
            end;
          end else
          begin
            Exc := '';//RsFileErrDBCCrpt;
            goto __FreeMemAndRaiseException;
          end;
        end else
        begin
          Exc := '';//RsFileErrRead;
          __FreeMemAndRaiseException:
          FreeMem(FileBuffer, FS.Size);
          goto __ExceptionOccured;
        end;
        FreeMem(FileBuffer, FS.Size);
        { Finally free the local file buffer }
      end else
      begin
        Exc := '';//RsFileErrLoad;
        __ExceptionOccured:
        RaiseException(EXC_LOAD, fDbcFileName, Exc);
        { An exception has occured }
      end;
    finally
      FS.Free;
    end;
  finally
    LockWriteEnd;
  end;
end;

procedure TDbDbcStorageMedium.Save;
begin
  SaveDbcFile;
end;

procedure TDbDbcStorageMedium.SaveDbcFile;
const
  NULL: Longword = 0;
var
  FS: TWideFileStream;
  NumFields: Int32;
  RecordSize: Int32;
  X, Y: Int32;
  IndexData: PIndexRec;
  StringTable: Int32;
  StringTableSize: Int32;
  OldPos: Int64;
  StrLen: Int32;
  MultiStringOccurenceMap: TStrIntHashMap;
  Value: Int32;
  Temp: string;
  Entry: IYesSerializable;
  Entry2: IYesSerializable2;
  Exc: string;
  Err: string;
label
  __ExceptionOccured, __FileCorruptError;
begin
  LockReadBegin;
  try
    FS := TCachedWideFileStream.Create(FDbcFileName, fmCreate, 0, -1);
    try
      if FS.Handle > 0 then
      begin
        { Successfully created a file }
        FS.Write(DBC_HEADER, SizeOf(DBC_HEADER));
        { Write the header, }
        X := GetEntryCount;
        FS.Write(X, SizeOf(X));
        { number of records, }
        NumFields := fDefinitionIndexes.Size;
        FS.Write(NumFields, 4);
        { number of fields per record, }
        RecordSize := NumFields * 4;
        FS.Write(RecordSize, 4);
        { and size of a record }
        FS.Seek(4, soCurrent);
        { We skip 4 bytes - stringtable size which we don't know yet }
        StringTable := 20 + GetEntryCount * RecordSize;
        { The position in the file, where stringtable starts }
        StringTableSize := 1;
        { Initial stringtable size is 1 (null-terminator) }
        MultiStringOccurenceMap := TStrIntHashMap.Create(True, 256);
    
        for X := 0 to GetEntryCount -1 do
        begin
          Entry := IYesSerializable(IdList[X]);
          if Entry.QueryInterface(IYesSerializable2, Entry2) = S_OK then
          begin
            Entry2.BeforeSave;
          end;
          Y := Entry.UniqueID;
          FS.Write(Y, 4);
          for Y := 1 to FDefinitionIndexes.Size -1 do
          begin
            IndexData := FDefinitionIndexes.GetValue(Y);
            if IndexData = nil then
            begin
              __FileCorruptError:
              Exc := '';//RsFileErrCrpt;
              goto __ExceptionOccured;
            end;
            Err := '';
            { Get field data by iY-Index }
            case IndexData^.DataType of
              ddtInt, ddtFlt:
              begin
                Value := 0;
                //SystemSerializationRegistry.InvokeSerializationRoutine(Entry, @Value,
                //  doSave, dtBinary, IndexData^.Name, fClassData, Err);
                FS.Write(Value, 4);
              end;
              ddtStr:
              begin
                { First check if the string is not nil - if it is, we just write 0 }
                //SystemSerializationRegistry.InvokeSerializationRoutine(Entry, @Temp,
                //  doSave, dtText, IndexData^.Name, fClassData, Err);
                if Temp <> '' then
                begin
                  Value := MultiStringOccurenceMap.GetValue(Temp);
                  { If the string has been written once already }
                  if Value <> 0 then
                  begin
                    FS.Write(Value, 4);
                    { then we just write it's file position to save space }
                  end else
                  begin
                    { else we write current stringtable size (aka position), }
                    FS.Write(StringTableSize, 4);
                    OldPos := FS.Position;
                    FS.Seek(StringTable + StringTableSize, soBeginning);
                    { Now we jump to the new string position, }
                    MultiStringOccurenceMap.PutValue(Temp, StringTableSize);
                    StrLen := Length(Temp) + 1;
                    FS.Write(Temp[1], StrLen);
                    { write the string (including null-terminator) }
                    Inc(StringTableSize, StrLen);
                    FS.Seek(OldPos, soBeginning);
                    { and seek back to the last field we've written }
                  end;
                end else FS.Write(NULL, 4);
              end;
            else
              goto __FileCorruptError;
            end;
          end;
        end;
        MultiStringOccurenceMap.Destroy;
    
        if StringTableSize = 1 then
        begin
          FS.Seek(StringTable, soBeginning);
          FS.Write(NULL, 1);
        end;
    
        FS.Seek(16, soBeginning);
        FS.Write(StringTableSize, 4);
        { Now we know the size of the string table, so we write it }
        FS.Seek(0, soEnd);
        { To prevent the file being truncated }
      end else
      begin
        Exc := '';//RsFileErrSave;
        __ExceptionOccured:
        RaiseException(EXC_SAVE, FDbcFileName, Exc);
        { An exception has occured }
      end;
    finally
      FS.Free;
    end;
  finally
    LockReadEnd;
  end;
end;

procedure TDbDbcStorageMedium.ThreadSafeSave;
begin

end;

end.
