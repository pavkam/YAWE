{*------------------------------------------------------------------------------
  PkTT database engine.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.DataCore.PkTTEngine;

interface

uses
  Framework.Base,
  Version,
  Components.DataCore.Types,
  Components.DataCore.MemoryStorage,
  Components.DataCore.Fields,
  Framework.SerializationRegistry,
  Misc.Classes,
  Misc.Threads,
  Misc.Miscleanous,
  Misc.Containers,
  Classes,
  SysUtils;

type
  YDbPkTTMedium = class(YDbMemoryStorageMedium)
    protected
      fFileName: string;
      fSection: string;

      procedure ReportLoadError(const sError: string; lwLine: Longword); inline;
      procedure ReportSaveError(const sError: string); inline;

      procedure LoadIndexedTTFile;
      procedure SaveIndexedTTFile;
      procedure InitializeMedium(const sOptions: string); override;
      procedure InitialLoadMedium; override;
      procedure SaveMedium; override;
      procedure ThreadSafeSaveMedium; override;
      procedure FinalSaveMedium; override;
  end;

const
  PkTTLoadErrorReport = 'PkTT load error at or near line %d: %s';
  PkTTSaveError = 'PkTT save error: %s';

implementation

uses
  Math,
  Resources,
  Framework;

{ YPkTTMedium }

procedure YDbPkTTMedium.InitializeMedium(const sOptions: string);
var
  iIpx: Int32;
begin
  iIpx := CharPos('|', sOptions);

  if iIpx > 0 then
  begin
     fFileName := Copy(sOptions, 1, iIpx - 1);
     fSection := UpperCase(Copy(sOptions, iIpx + 1, Length(sOptions)));
  end else raise EMediumOperationFailed.Create(RsSectionMissing, MOF_OPT_ERR);

  fFileName := FileNameToOS(fFileName);
end;

procedure YDbPkTTMedium.InitialLoadMedium;
begin
  LoadIndexedTTFile;
end;

procedure YDbPkTTMedium.SaveMedium;
begin
  SaveIndexedTTFile;
end;

procedure YDbPkTTMedium.ThreadSafeSaveMedium;
var
  cClone: YDbPkTTMedium;
begin
  cClone := YDbPkTTMedium(Clone(YDbPkTTMedium));
  try
    cClone.fFileName := fFileName;
    cClone.fSection := fSection;
    cClone.FinalSaveMedium;
  finally
    cClone.Free;
  end;
end;

procedure YDbPkTTMedium.FinalSaveMedium;
begin
  if fSaveBack then SaveMedium;
  fFileName := '';
  fSection := '';
  inherited FinalSaveMedium;
end;

procedure YDbPkTTMedium.ReportLoadError(const sError: string; lwLine: Longword);
begin
  if sError = '' then Exit;
  DoOnError(Format(PkTTLoadErrorReport, [lwLine, sError]));
end;

procedure YDbPkTTMedium.ReportSaveError(const sError: string);
begin
  if sError = '' then Exit;
  DoOnError(Format(PkTTSaveError, [sError]));
end;

procedure YDbPkTTMedium.LoadIndexedTTFile;
var
  cFile: TFileStream;
  pStart: PChar;
  pCurr: PChar;
  pTmp: PChar;
  pSect: PChar;
  sExc: string;
  sFileData: string;
  sField: string;
  sValue: string;
  iLen: Int32;
  iTmp: Int32;
  iEntryId: UInt32;
  cEntry: YDbSerializable;
  bEntryCountSet: Boolean;
  sErr: string;
  iLineCounter: UInt32;

  function ReadSectionHeader: Boolean;
  begin
    if pCurr^ = '[' then
    begin
      iEntryId := 0;
      Inc(pCurr);
      pTmp := pCurr;

      while not (pTmp^ in [' ', ']']) do Inc(pTmp);

      if (pTmp^ = ' ') and
         (Integer(pTmp - pCurr) = iLen) and
         (StrLIComp(pCurr, pSect, iLen) = 0) then
      begin
        Inc(pTmp);
        pCurr := pTmp;

        while not (pTmp^ in [#13, #10, ' ', ']']) do Inc(pTmp);

        if pTmp^ = ' ' then
        begin
          iTmp := 1;
          Inc(pTmp);
          while pTmp^ = ' ' do
          begin
            Inc(iTmp);
            Inc(pTmp);
          end;
        end else iTmp := 0;

        if pTmp^ = ']' then
        begin
          PChar(pTmp - iTmp)^ := #0;
          iEntryId := TextBufToUInt(pCurr);
          if iEntryId <> 0 then
          begin
            bEntryCountSet := True;
            if cEntry <> nil then cEntry.AfterLoad;
            cEntry := InternalGetFreeClassInstance;
            cEntry.UniqueID := iEntryId;
            if iEntryId > fHighestId then fHighestId := iEntryId;
            Inc(fCount);
            fIdList.Add(cEntry);
          end;
          Inc(pTmp);
        end;
      end;
      pCurr := pTmp;
      Result := True;
    end else Result := False;
  end;

  function ReadComment: Boolean;
  begin
    if (pCurr^ = ';') and (PChar(pCurr+1)^ = ';') then
    begin
      Inc(pCurr, 2);
      Result := True;
    end else Result := False;
  end;

  function ReadField: Boolean;
  begin
    if iEntryId <> 0 then
    begin
      pTmp := pCurr;

      while not (pTmp^ in [' ', '=']) do Inc(pTmp);

      SetString(sField, pCurr, pTmp - pCurr);

      while pTmp^ in [' ', '='] do Inc(pTmp);

      pCurr := pTmp;

      while not (pTmp^ in [#13, #10, #0]) do Inc(pTmp);

      SetString(sValue, pCurr, pTmp - pCurr);
      SystemSerializationRegistry.InvokeSerializationRoutine(cEntry, @sValue, doLoad,
        dtText, sField, fClassData, sErr);
      ReportLoadError(sErr, iLineCounter);
      pCurr := pTmp;
      Result := True;
    end else Result := False;
  end;

  (*
  function ReadCustomData: Boolean;
  var
    sBlockName: string;
    ifBlock: ICustomDataBlock;
  begin
    Result := False;
    if (iEntryId <> 0) and (pCurr^ = '#') and (StrLIComp(pCurr, '##DATABLOCK', 11) = 0) then
    begin
      Inc(pCurr, 11);

      if pCurr^ = ' ' then
      begin
        Inc(pCurr);
        pTmp := pCurr;

        while not (pTmp^ in [#13, #10, #0, ' ', '=']) do Inc(pTmp);

        if pTmp^ = #0 then
        begin
          pCurr := pTmp;
          Exit;
        end;

        SetString(sBlockName, pCurr, Int32(pTmp - pCurr));

        pCurr := pTmp;

        while pCurr^ in [#13, #10, ' '] do
        begin
          if pCurr^ = #10 then Inc(iLineCounter);
          Inc(pCurr);
        end;

        if pCurr^ <> '=' then Exit;
        Inc(pCurr);

        while pCurr^ in [#13, #10, ' '] do
        begin
          if pCurr^ = #10 then Inc(iLineCounter);
          Inc(pCurr);
        end;

        if pCurr^ <> '(' then Exit;
        Inc(pCurr);
      end else Exit;

      if cEntry.CustomDataBlocks[sBlockName] = nil then
      begin
        ifBlock := cEntry.NewDataBlock(sBlockName);

        while not (pCurr^ in [#0, ')']) do
        begin
          if pCurr^ = #10 then Inc(iLineCounter);

          Inc(pCurr);
        end;
      end else
      begin
        ReportLoadError(Format('Custom data block "%s" for ID %d was redefined.',
          [sBlockName, iEntryId]), iLineCounter);

        while not (pCurr^ in [#0, ')']) do
        begin
          if pCurr^ = #10 then Inc(iLineCounter);
          Inc(pCurr);
        end;
      end;

      if pCurr^ = ')' then
      begin
        Inc(pCurr);

        while pCurr^ in [' ', #13, #10] do
        begin
          if pCurr^ = #10 then Inc(iLineCounter);
          Inc(pCurr);
        end;
        
        if pCurr^ = ';' then
        begin
          Inc(pCurr);
          Result := True;
        end;
      end;
    end;
  end;

  function ReadCustomField: Boolean;
  begin
    Result := False;
  end;
  *)

  function ReadEntryCountHint: Boolean;
  begin
    if not bEntryCountSet and (StrLIComp(pCurr, 'IENTRYCOUNT', 11) = 0) then
    begin
      Inc(pCurr, 11);
      while pCurr^ = ' ' do Inc(pCurr);
      if pCurr^ = '=' then
      begin
        Inc(pCurr);

        while pCurr^ = ' ' do Inc(pCurr);

        pTmp := pCurr;

        while not (pTmp^ in [' ', #13, #10, #0]) do Inc(pTmp);

        pTmp^ := #0;
        InternalAllocateNewClassBuffer(ForceAlignment(TextBufToUInt(pCurr), 1024));
        bEntryCountSet := True;
        pCurr := pTmp + 1;
      end;
      Result := True;
    end else Result := False;
  end;
begin
  if not FileExists(fFileName) then
  begin
    raise EMediumOperationFailed.Create(Format(RsFileErrTTNo, [fFileName]), MOF_LOAD);
  end;

  { Initialization Part }
  sExc := RsUndefinedError;
  iEntryId := 0;
  cEntry := nil;
  bEntryCountSet := False;
  pSect := PChar(fSection);
  iLen := Length(fSection);

  { Loading of the File }
  cFile := TFileStream.Create(fFileName, fmOpenRead);
  try
    if cFile.Handle <= 0 then
    begin
      sExc := RsFileErrLoad;
      RaiseException(EXC_LOAD, fFileName, sExc);
    end;
    SetLength(sFileData, cFile.Size);
    pStart := PChar(sFileData);
    cFile.Read(pStart^, cFile.Size);
    pCurr := pStart;
  finally
    cFile.Free;
  end;

  fLock.BeginWrite;
  try
    iLineCounter := 1;

    while pCurr^ <> #0 do
    begin
      while pCurr^ in [' ', #10, #13] do
      begin
        if pCurr^ = #10 then Inc(iLineCounter);
        Inc(pCurr);
      end;
      if pCurr^ = #0 then Break;

      if not ReadSectionHeader then
      if not ReadComment then
      //if not ReadCustomData then
      if not ReadField then ReadEntryCountHint;

      while not (pCurr^ in [#10, #0]) do Inc(pCurr);
    end;

    fIdList.CustomSort(@CompareSerializablesById);
  finally
    fLock.EndWrite;
  end;
end;

procedure YDbPkTTMedium.SaveIndexedTTFile;
var
  iInt, iIdx: Int32;
  cEntry: YDbSerializable;
  sField: string;
  sTemp: string;
  cFile: TFileStream;
  sErr: string;

  procedure IntWriteln(const sStr: string);
  begin
    cFile.Write(Pointer(sStr)^, Length(sStr));
    cFile.Write(sLineBreak, Length(sLineBreak));
  end;
begin
  fLock.BeginRead;
  try
    cFile := TCachedFileStream.Create(fFileName, fmCreate, 0, 1 shl 16);
    try
      if cFile.Handle > 0 then
      begin
        IntWriteLn(';; TT File generated by YAWE Server.');
        IntWriteLn(';;');
        IntWriteLn('IENTRYCOUNT = ' + itoa(fCount));
        IntWriteLn(';; Please do not remove the line above, it''s for speed up purposes.');
        IntWriteLn(';; Removing it won''t break DB loading, but it will slow it down.');
        IntWriteLn('');
        for iInt := 0 to fCount -1 do
        begin
          cEntry := fIdList[iInt];
          sTemp := '[' + fSection + ' ' + itoa(cEntry.UniqueID) + ']';
          IntWriteln(sTemp);
          for iIdx := 0 to fClassDataLen -1 do
          begin
            if fClassData^.Data[iIdx].Offset = 12 then Continue;
            sTemp := '';
            sField := fClassData^.Data[iIdx].Name;
            SystemSerializationRegistry.InvokeSerializationRoutine(cEntry, @sTemp,
              doSave, dtText, sField, fClassData, sErr);
            ReportSaveError(sErr);
            if sTemp <> '' then
            begin
              sField := sField + ' = ' + sTemp;
              IntWriteln(sField);
            end;
          end;
          IntWriteln('');
        end;
      end else
      begin
        RaiseException(EXC_SAVE, fFileName, RsFileErrSave);
      end;
    finally
      cFile.Free;
    end;
  finally
    fLock.EndRead;
  end;
end;

end.
