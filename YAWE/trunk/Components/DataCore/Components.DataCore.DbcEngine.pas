{*------------------------------------------------------------------------------
  Dbc database engine.
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.DataCore.DbcEngine;

interface

uses
  Framework.Base,
  Components.DataCore.Fields,
  Components.DataCore.MemoryStorage,
  Framework.SerializationRegistry,
  Components.DataCore.Types,
  Misc.Miscleanous,
  Misc.Classes,
  Misc.Threads,
  Misc.Containers,
  Classes;

type
  {$Z4}
  { Force DWORD size }
  YDbcDataType = (ddtInt, ddtFlt, ddtStr);
  {$Z1}

  YDbDbcMedium = class(YDbMemoryStorageMedium)
    protected
      fDbcDefFileName: string;
      fDbcFileName: string;
      fDefinitions: TStrIntHashMap;
      fDefinitionIndexes: TIntPtrHashMap;

      procedure CreateDbcDefinitionFile(const aIdents: array of string;
        const aTypes: array of YDbcDataType);
      procedure SaveDbcFile;
      procedure LoadDbcDefinitionFile;
      procedure LoadDbcFile;
      procedure InitializeMedium(const sOptions: string); override;
      procedure InitialLoadMedium; override;
      procedure SaveMedium; override;
      procedure ThreadSafeSaveMedium; override;
      procedure FinalSaveMedium; override;
    public
      constructor Create; 
      destructor Destroy; override;
  end;

procedure CreateDbcDefinitionFile(const sFileName: string; const aIdents: array of string;
  const aTypes: array of YDbcDataType);

implementation

uses
  Math,
  SysUtils,
  Resources,
  Framework;

const
  { Headers }
  DBC_HEADER = 'WDBC';
  DBCDEF_HEADER = 'WDBCDEF';

type
  PIndexRec = ^YIndexRec;
  YIndexRec = record
    Name: string;
    DataType: YDbcDataType;
  end;

  PDbcDefFileInformation = ^YDbcDefFileInformation;
  YDbcDefFileInformation = record
    DefinitionCount: Int32; { Number of definitions in the file }
    StringTableSize: Int32; { String table size - for file size comparison }
  end;

  PDbcFileInformation = ^YDbcFileInformation;
  YDbcFileInformation = record
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

procedure CreateDbcDefinitionFile(const sFileName: string; const aIdents: array of string;
  const aTypes: array of YDbcDataType);
var
  cMedium: YDbDbcMedium;
begin
  cMedium := YDbDbcMedium.Create;
  cMedium.fDbcDefFileName := sFileName;
  cMedium.CreateDbcDefinitionFile(aIdents, aTypes);
  cMedium.Destroy;
end;

{ YDbcMedium }

constructor YDbDbcMedium.Create;
begin
  inherited Create;
  fDefinitions := TStrIntHashMap.Create(True, 128);
  fDefinitionIndexes := TIntPtrHashMap.Create(128);
end;

destructor YDbDbcMedium.Destroy;
var
  ifItr: IPtrIterator;
begin
  ifItr := fDefinitionIndexes.Values;
  while ifItr.HasNext do
  begin
    Dispose(PIndexRec(ifItr.Next));
  end;

  fDefinitions.Destroy;
  fDefinitionIndexes.Destroy;
  inherited Destroy;
end;

procedure YDbDbcMedium.LoadDbcDefinitionFile;
var
  cDbcDefinitionFile: TFileStream;
  pFileBuffer: Pointer;
  pCurrPtr: MultiPtr;
  pFileInfo: PDbcDefFileInformation;
  iInt: Integer;
  pStr: PChar;
  sString: string;
  pIndexData: PIndexRec;
  sExc: string;
label
  __ExceptionOccured, __FreeMemAndRaiseException;
begin
  if not FileExists(fDbcDefFileName) then
  begin
    raise EMediumOperationFailed.Create(Format(RsFileErrDBCNo2, [fDbcDefFileName]), MOF_LOAD);
  end;
  sExc := RsUndefinedError;
  cDbcDefinitionFile := TFileStream.Create(fDbcDefFileName, fmOpenRead);
  try
    if cDbcDefinitionFile.Handle > 0 then
    begin
      { Needed to get the file size }
      if cDbcDefinitionFile.Size < 16 then
      begin
        { 7 bytes Header, 8 bytes info and 1 byte null-terminator }
        sExc := RsFileErrDBCCrpt2;
        goto __ExceptionOccured;
      end;
      GetMem(pFileBuffer, cDbcDefinitionFile.Size);
      { Allocate the buffer }
      if cDbcDefinitionFile.Read(pFileBuffer^, cDbcDefinitionFile.Size) <> 0 then
      begin
        if CompareMem(pFileBuffer, @DBCDEF_HEADER[1], 7) then
        begin
          { Passed header check }
          pCurrPtr.Long := pFileBuffer;
          Inc(pCurrPtr.Byte, 7);
          { Skip the header }
          pFileInfo := pCurrPtr.Ptr;
          { Get the file info pointer }
          Inc(pCurrPtr.Byte, 8);
          if pFileInfo^.DefinitionCount * 4 + pFileInfo^.StringTableSize + 15 = cDbcDefinitionFile.Size then
          begin
            pStr := pCurrPtr.Ptr;
            Inc(pStr, pFileInfo^.DefinitionCount * 4 + 1);
            { Strings start right after all field type definitions }
            for iInt := 0 to pFileInfo^.DefinitionCount -1 do
            begin
              sString := UpperCase(pStr);
              fDefinitions.PutValue(sString, iInt + 1);
              { Add the value type by string key }
              New(pIndexData);
              pIndexData^.Name := sString;
              pIndexData^.DataType := YDbcDataType(pCurrPtr.Long^);
              fDefinitionIndexes.PutValue(iInt, pIndexData);
              { Add name and field type by ID }
              Inc(pCurrPtr.Long);
              Inc(pStr, Length(sString) + 1);
              { Advance file pointers }
            end;
          end else
          begin
            sExc := RsFileErrCrpt;
            goto __FreeMemAndRaiseException;
          end;
        end else
        begin
          sExc := RsFileErrDBCCrpt2;
          goto __FreeMemAndRaiseException;
        end;
      end else
      begin
        sExc := RsFileErrRead;
        __FreeMemAndRaiseException:
        FreeMem(pFileBuffer);
        goto __ExceptionOccured;
      end;
      FreeMem(pFileBuffer);
      { Finally free the local file buffer }
    end else
    begin
      sExc := RsFileErrLoad;
      __ExceptionOccured:
      RaiseException(EXC_LOAD, fDbcDefFileName, sExc);
      { An exception has occured }
    end;
  finally
    cDbcDefinitionFile.Free;
  end;
end;

procedure YDbDbcMedium.LoadDbcFile;
var
  cDbcFile: TFileStream;
  pFileBuffer: Pointer;
  pCurrPtr: MultiPtr;
  pFileInfo: PDbcFileInformation;
  iX, iY: Int32;
  iEntryId: UInt32;
  pStringTable: PChar;
  sTemp: string;
  cEntry: YDbSerializable;
  pIndexData: PIndexRec;
  sExc: string;
  sErr: string;
label
  __ExceptionOccured, __FreeMemAndRaiseException, __FileCorruptError;
begin
  if not FileExists(fDbcFileName) then
  begin
    raise EMediumOperationFailed.Create('DBC File "' + fDbcFileName + '" not found!', MOF_LOAD);
  end;

  cEntry := nil;

  fLock.BeginWrite;
  cDbcFile := TFileStream.Create(fDbcFileName, fmOpenRead);
  try
    if cDbcFile.Handle > 0 then
    begin
      { Needed to get the file size }
      if cDbcFile.Size < 21 then
      begin
        { 4 bytes header, 16 bytes info + 1 null terminator }
        sExc := RsFileErrDBCCrpt;
        goto __ExceptionOccured;
      end;
      GetMem(pFileBuffer, cDbcFile.Size);
      { Allocate temporary buffer }
      if cDbcFile.Read(pFileBuffer^, cDbcFile.Size) <> 0 then
      begin
        { Read the whole file into our buffer }
        if CompareMem(pFileBuffer, @DBC_HEADER[1], 4) then
        begin
          { Header is ok }
          pCurrPtr.Ptr := pFileBuffer;
          Inc(pCurrPtr.Byte, 4);
          { We'll continue from the end of the header }
          pFileInfo := pCurrPtr.Ptr;
          { We'll just point the pFileInfo pointer to the current position }
          Inc(pCurrPtr.Byte, 16);
          if pFileInfo^.RecordCount * pFileInfo^.RecordSize + pFileInfo^.StringTableSize + 20 = cDbcFile.Size then
          begin
            { Is the file size OK? }
            pStringTable := pCurrPtr.Ptr;
            Inc(pStringTable, pFileInfo^.RecordCount * pFileInfo^.RecordSize); { Start of string fields }

            iX := Max(ForceAlignment(pFileInfo^.RecordCount, 1024),
              MEM_STORE_DEFAULT_CAPACITY);
            InternalAllocateNewClassBuffer(iX);

            for iX := 0 to pFileInfo^.RecordCount -1 do
            begin
              iEntryId := pCurrPtr.Long^;
              if cEntry <> nil then cEntry.AfterLoad;
              cEntry := InternalGetFreeClassInstance;
              cEntry.UniqueID := iEntryId;
              if iEntryId > fHighestId then fHighestId := iEntryId;
              Inc(fCount);
              fIdList.Add(cEntry);
              Inc(pCurrPtr.Long);
              { First field is always the identifier }
              for iY := 1 to pFileInfo^.FieldCount -1 do
              begin
                pIndexData := fDefinitionIndexes.GetValue(iY);
                { Get the definition data about this particular data index }
                if pIndexData = nil then goto __FileCorruptError;
                sErr := '';
                case pIndexData^.DataType of
                  ddtInt, ddtFlt:
                  begin
                    { This value is an Integer or a Float }
                    SystemSerializationRegistry.InvokeSerializationRoutine(cEntry,
                      pCurrPtr.Long, doLoad, dtBinary, pIndexData^.Name, fClassData, sErr);
                  end;
                  ddtStr:
                  begin
                    { In this case the current DWORD we point to is the offset from the stringtable,
                      where the actual string starts }
                    if Integer(pCurrPtr.Long^) <= pFileInfo^.StringTableSize then
                    begin
                      sTemp := pStringTable + pCurrPtr.Long^;
                      SystemSerializationRegistry.InvokeSerializationRoutine(cEntry,
                        @sTemp, doLoad, dtText, pIndexData^.Name, fClassData, sErr);
                    end else goto __FileCorruptError;
                  end;
                else
                  goto __FileCorruptError;
                end;
                Inc(pCurrPtr.Long);
                { Advance the buffer pointer }
              end;
            end;
          end else
          begin
            __FileCorruptError:
            sExc := RsFileErrCrpt;
            goto __FreeMemAndRaiseException;
          end;
        end else
        begin
          sExc := RsFileErrDBCCrpt;
          goto __FreeMemAndRaiseException;
        end;
      end else
      begin
        sExc := RsFileErrRead;
        __FreeMemAndRaiseException:
        FreeMem(pFileBuffer, cDbcFile.Size);
        goto __ExceptionOccured;
      end;
      FreeMem(pFileBuffer, cDbcFile.Size);
      { Finally free the local file buffer }
    end else
    begin
      sExc := RsFileErrLoad;
      __ExceptionOccured:
      RaiseException(EXC_LOAD, fDbcFileName, sExc);
      { An exception has occured }
    end;
  finally
    cDbcFile.Free;
    fLock.EndWrite;
  end;
end;

procedure YDbDbcMedium.SaveDbcFile;
const
  NULL: Longword = 0;
var
  cDbcFile: TFileStream;
  iNumFields: Int32;
  iRecordSize: Int32;
  iX, iY: Int32;
  pIndexData: PIndexRec;
  iStringTable: Int32;
  iStringTableSize: Int32;
  liOldPos: Int64;
  iStrLen: Int32;
  cMultiStringOccurenceMap: TStrIntHashMap;
  iVal: Int32;
  sTemp: string;
  cEntry: YDbSerializable;
  sExc: string;
  sErr: string;
label
  __ExceptionOccured, __FileCorruptError;
begin
  cDbcFile := TCachedFileStream.Create(fDbcFileName, fmCreate, 0, 1 shl 17);
  try
    if cDbcFile.Handle > 0 then
    begin
      { Successfully created a file }
      cDbcFile.Write(DBC_HEADER, 4);
      { Write the header, }
      cDbcFile.Write(fCount, 4);
      { number of records, }
      iNumFields := fDefinitionIndexes.Size;
      cDbcFile.Write(iNumFields, 4);
      { number of fields per record, }
      iRecordSize := iNumFields * 4;
      cDbcFile.Write(iRecordSize, 4);
      { and size of a record }
      cDbcFile.Seek(4, soCurrent);
      { We skip 4 bytes - stringtable size which we don't know yet }
      iStringTable := 20 + fCount * iRecordSize;
      { The position in the file, where stringtable starts }
      iStringTableSize := 1;
      { Initial stringtable size is 1 (null-terminator) }
      cMultiStringOccurenceMap := TStrIntHashMap.Create(True, 256);
  
      for iX := 0 to fCount -1 do
      begin
        cEntry := fIdList[iX];
        iY := cEntry.UniqueID;
        cDbcFile.Write(iY, 4);
        for iY := 1 to fDefinitionIndexes.Size -1 do
        begin
          pIndexData := fDefinitionIndexes.GetValue(iY);
          if pIndexData = nil then
          begin
            __FileCorruptError:
            sExc := RsFileErrCrpt;
            goto __ExceptionOccured;
          end;
          sErr := '';
          { Get field data by iY-Index }
          case pIndexData^.DataType of
            ddtInt, ddtFlt:
            begin
              iVal := 0;
              SystemSerializationRegistry.InvokeSerializationRoutine(cEntry, @iVal,
                doSave, dtBinary, pIndexData^.Name, fClassData, sErr);
              cDbcFile.Write(iVal, 4);
            end;
            ddtStr:
            begin
              { First check if the string is not nil - if it is, we just write 0 }
              SystemSerializationRegistry.InvokeSerializationRoutine(cEntry, @sTemp,
                doSave, dtText, pIndexData^.Name, fClassData, sErr);
              if sTemp <> '' then
              begin
                iVal := cMultiStringOccurenceMap.GetValue(sTemp);
                { If the string has been written once already }
                if iVal <> 0 then
                begin
                  cDbcFile.Write(iVal, 4);
                  { then we just write it's file position to save space }
                end else
                begin
                  { else we write current stringtable size (aka position), }
                  cDbcFile.Write(iStringTableSize, 4);
                  liOldPos := cDbcFile.Position;
                  cDbcFile.Seek(iStringTable + iStringTableSize, soBeginning);
                  { Now we jump to the new string position, }
                  cMultiStringOccurenceMap.PutValue(sTemp, iStringTableSize);
                  iStrLen := Length(sTemp) + 1;
                  cDbcFile.Write(sTemp[1], iStrLen);
                  { write the string (including null-terminator) }
                  Inc(iStringTableSize, iStrLen);
                  cDbcFile.Seek(liOldPos, soBeginning);
                  { and seek back to the last field we've written }
                end;
              end else cDbcFile.Write(NULL, 4);
            end;
          else
            goto __FileCorruptError;
          end;
        end;
      end;
      cMultiStringOccurenceMap.Destroy;
  
      if iStringTableSize = 1 then
      begin
        cDbcFile.Seek(iStringTable, soBeginning);
        cDbcFile.Write(NULL, 1);
      end;
  
      cDbcFile.Seek(16, soBeginning);
      cDbcFile.Write(iStringTableSize, 4);
      { Now we know the size of the string table, so we write it }
      cDbcFile.Seek(0, soEnd);
      { To prevent the file being truncated }
    end else
    begin
      sExc := RsFileErrSave;
      __ExceptionOccured:
      RaiseException(EXC_SAVE, fDbcFileName, sExc);
      { An exception has occured }
    end;
  finally
    cDbcFile.Free;
  end;
end;

procedure YDbDbcMedium.SaveMedium;
begin
  SaveDbcFile;
end;

procedure YDbDbcMedium.ThreadSafeSaveMedium;
var
  cClone: YDbDbcMedium;
begin
  cClone := YDbDbcMedium(Clone(YDbDbcMedium));
  cClone.fDbcDefFileName := fDbcDefFileName;
  cClone.fDbcFileName := fDbcFileName;
  cClone.fDefinitions := TStrIntHashMap.Create(False);
  cClone.fDefinitionIndexes := TIntPtrHashMap.Create;

  fLock.BeginRead;
  cClone.fDefinitions.PutAll(fDefinitions);
  cClone.fDefinitionIndexes.PutAll(fDefinitionIndexes);
  fLock.EndRead;

  cClone.FinalSaveMedium;
  cClone.fDefinitions.Clear;
  cClone.fDefinitionIndexes.Clear;
  cClone.Destroy;
end;

procedure YDbDbcMedium.InitializeMedium(const sOptions: string);
const
  eDefinitionFileNotSpecified = 'Definition file not specified!';
var
  iIpx1, iIpx2: Integer;
begin
  iIpx1 := CharPos('|', sOptions);

  if iIpx1 > 0 then
  begin
     fDbcFileName := Copy(sOptions, 1, iIpx1 - 1);
  end else raise EMediumOperationFailed.Create(eDefinitionFileNotSpecified, MOF_OPT_ERR);

  fDbcFileName := FileNameToOS(fDbcFileName);
  Inc(iIpx1);
  iIpx2 := CharPosEx('|', sOptions, iIpx1) - iIpx1 + 1;

  if iIpx2 > 0 then
  begin
     fDbcDefFileName := Copy(sOptions, iIpx1, iIpx2 - 1);
  end else fDbcDefFileName := Copy(sOptions, iIpx1, Length(sOptions));

  fDbcDefFileName := FileNameToOS(fDbcDefFileName);
end;

procedure YDbDbcMedium.InitialLoadMedium;
begin
  LoadDbcDefinitionFile;
  LoadDbcFile;
end;

procedure YDbDbcMedium.CreateDbcDefinitionFile(const aIdents: array of string; const aTypes: array of YDbcDataType);
var
  cDbcDefinitionFile: TFileStream;
  iIdx: Integer;
  iLen: Integer;
  iStrLen: Integer;
  iStringTableSize: Integer;
  pStrTable: PPChar;
  pStr: PChar;
  sExc: string;
label
  __ExceptionOccured;
begin
  cDbcDefinitionFile := TFileStream.Create(fDbcDefFileName, fmCreate);
  try
    if cDbcDefinitionFile.Handle <> 0 then
    begin
      { Successfully created a file }
      iLen := Length(aTypes);
      if iLen >= Length(aIdents) then
      begin
        { We must have enough types defined }
        cDbcDefinitionFile.Write(DBCDEF_HEADER, 7);
        { Write the header }
        cDbcDefinitionFile.Write(iLen, 4);
        { Write number of fields per record }
        cDbcDefinitionFile.Seek(4, soCurrent);
        { Seek 4 bytes - we don't know the size of the stringtable yet }
        cDbcDefinitionFile.Write(aTypes[0], 4 * iLen);
        { Write all field types }
        cDbcDefinitionFile.Seek(1, soCurrent);
        { 1 byte = null-terminator }
        pStrTable := @aIdents[0];
        { This is a nice trick - it's faster then accessing array's contents again and again }
        iStringTableSize := 1;
        for iIdx := 0 to iLen -1 do
        begin
          pStr := pStrTable^;
          { We get the string pointer }
          iStrLen := PLongword(Longword(pStr) - 4)^ + 1;
          { We get the length - another trick to save the compiler some job (preserving Idents) }
          Inc(iStringTableSize, iStrLen);
          cDbcDefinitionFile.Write(pStr[0], iStrLen);
          { And now we write the entire string (including null-terminator) }
          Inc(pStrTable);
          { Iterate through the table }
        end;
        cDbcDefinitionFile.Seek(11, soBeginning);
        cDbcDefinitionFile.Write(iStringTableSize, 4);
        { Now we know the string table size so we can write it }
        cDbcDefinitionFile.Seek(0, soEnd);
        { To prevent the file being truncated }
      end else
      begin
        sExc := RsFileErrDBCBadFmt;
        goto __ExceptionOccured;
      end;
    end else
    begin
      sExc := RsFileErrSave;
      __ExceptionOccured:
      RaiseException(EXC_SAVE, fDbcDefFileName, sExc);
      { An exception has occured }
    end;
  finally
    cDbcDefinitionFile.Free;
  end;
end;

procedure YDbDbcMedium.FinalSaveMedium;
begin
  if fSaveBack then SaveMedium;
  fDbcFileName := '';
  fDbcDefFileName := '';
  inherited FinalSaveMedium;
end;

end.
