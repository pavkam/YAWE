{*------------------------------------------------------------------------------
  Pcp database engine.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.DataCore.PcpEngine;

interface

uses
  Framework.Base,
  Version,
  Components.DataCore.MemoryStorage,
  Components.DataCore.Fields,
  Framework.SerializationRegistry,
  Components.DataCore.Types,
  Framework.TypeRegistry,
  Misc.Classes,
  Misc.Miscleanous,
  Misc.Threads,
  Misc.Containers,
  Classes,
  SysUtils;

type
  YDbPcpMedium = class(YDbMemoryStorageMedium)
    protected
      fFileName: string;

      procedure LoadPcpFile;
      procedure SavePcpFile;
      procedure InitializeMedium(const sOptions: string); override;
      procedure InitialLoadMedium; override;
      procedure SaveMedium; override;
      procedure ThreadSafeSaveMedium; override;
      procedure FinalSaveMedium; override;
  end;

implementation

uses
  Math,
  Resources,
  Framework;

const
  PCP_VER_MAJOR         = 1;
  PCP_VER_MINOR         = 1;
  PCP_VER_REVISION      = 0;
  PCP_VER_BUILD         = 1;

  PCP_VER_FULL          = PCP_VER_MAJOR or (PCP_VER_MINOR shl 8) or (PCP_VER_REVISION shl 16) or (PCP_VER_BUILD shl 24);  

  PVER = (Ord('P') shl 24) or (Ord('V') shl 16) or (Ord('E') shl 8) or Ord('R'); // Version info
  PHDR = (Ord('P') shl 24) or (Ord('H') shl 16) or (Ord('D') shl 8) or Ord('R'); // PCP file header
  PEFI = (Ord('P') shl 24) or (Ord('E') shl 16) or (Ord('F') shl 8) or Ord('I'); // Entry field info
  PEHO = (Ord('P') shl 24) or (Ord('E') shl 16) or (Ord('H') shl 8) or Ord('O'); // Entry header offsets
  PENT = (Ord('P') shl 24) or (Ord('E') shl 16) or (Ord('N') shl 8) or Ord('T'); // Entry header
  PSTR = (Ord('P') shl 24) or (Ord('S') shl 16) or (Ord('T') shl 8) or Ord('R'); // Stringtable
  PSTI = (Ord('P') shl 24) or (Ord('S') shl 16) or (Ord('T') shl 8) or Ord('I'); // Stringtable indices
  PRAW = (Ord('P') shl 24) or (Ord('R') shl 16) or (Ord('A') shl 8) or Ord('W'); // Rawdata
  PRWI = (Ord('P') shl 24) or (Ord('R') shl 16) or (Ord('W') shl 8) or Ord('I'); // Rawdata indices

type
  YPcpDataType = (pdtDword, pdtFloat, pdtString, pdtRaw);

  PPcpHeaderChunk = ^YPcpHeaderChunk;
  YPcpHeaderChunk = packed record
    GlobalFlags: Longword;
    EntryOffset: Longword;
    EntryCount: Longword;
    StringOffset: Longword;
    StringCount: Longword;
    StringIndicesOffset: Longword;
    StringIndicesCount: Longword;
    RawDataOffset: Longword;
    RawDataCount: Longword;
    RawDataIndicesOffset: Longword;
    RawDataIndicesCount: Longword;
    Reserved: array[0..7] of Longword;
  end;

{ YPcpMedium }

procedure YDbPcpMedium.FinalSaveMedium;
begin
  if fSaveBack then SaveMedium;
  fFileName := '';
  inherited FinalSaveMedium;
end;

procedure YDbPcpMedium.InitializeMedium(const sOptions: string);
begin
  fFileName := FileNameToOS(sOptions);
end;
(*
var
  iIpx, iPos: Int32;
  iFlag: Int32;
begin
  iIpx := CharPos('|', sOptions);
  if iIpx <> 0 then
  begin
    fFileName := Copy(sOptions, 1, iIpx - 1);
  end;

  repeat
    iPos := iIpx + 1;
    iIpx := CharPosEx('|', sOptions, iPos);

    if iIpx <> 0 then
    begin
      iFlag := StrToUInt(Copy(sOptions, iPos, iIpx - iPos));
      case iFlag of
        1: fFileFlags := fFileFlags or PCP_MASK_CHECKSUM;
        2: fFileFlags := fFileFlags or PCP_MASK_PACKED;
        3: fFileFlags := fFileFlags or PCP_MASK_CUSTOM_DATA;
        4: fFileFlags := fFileFlags or PCP_MASK_SORTED_DATA;
      end;
    end else
    begin
      iFlag := StrToUint(Copy(sOptions, iPos, Length(sOptions)));
      case iFlag of
        1: fFileFlags := fFileFlags or PCP_MASK_CHECKSUM;
        2: fFileFlags := fFileFlags or PCP_MASK_PACKED;
        3: fFileFlags := fFileFlags or PCP_MASK_CUSTOM_DATA;
        4: fFileFlags := fFileFlags or PCP_MASK_SORTED_DATA;
      end;
    end;
  until iIpx = 0;

  fFileName := FileNameToOS(fFileName);
end;
*)

procedure YDbPcpMedium.InitialLoadMedium;
begin
  LoadPcpFile;
end;

procedure YDbPcpMedium.SaveMedium;
begin
  SavePcpFile;
end;

procedure YDbPcpMedium.ThreadSafeSaveMedium;
begin

end;

procedure YDbPcpMedium.LoadPcpFile;
var
  iIdx: Int32;
  iInt: Int32;
  iCount: Int32;
  tVers: TVersion;
  tHeader: YPcpHeaderChunk;
  cReader: TChunkReader;
  cMem: TMemoryStream;
  cFile: TFileStream;
  {TODO 1 -oUNUSED: pStrings: PChar;
  pRawData: Pointer;}
  aStringData: array of record
    Offset: UInt32;
    Length: Int32;
  end;
  aRawData: array of record
    Offset: UInt32;
    Size: Int32;
  end;
  aDataTypes: array of YPcpDataType;
  aData: array of Longword;
  aOffsets: array of Longword;
begin
  if not FileExists(fFileName) then
  begin
    raise EMediumOperationFailed.Create(Format(RsFileErrTTNo, [fFilename]), MOF_LOAD);
  end;
  
  cFile := TFileStream.Create(fFileName, fmOpenRead);
  try
    cReader := TChunkReader.Create(nil, True);
    try
      cReader.Stream := TMemoryStream.Create;
      cMem := TMemoryStream(cReader.Stream);
      cMem.Size := cFile.Size;
      cFile.Read(cMem.Memory^, cMem.Size);

      if not cReader.FetchNextChunk or (cReader.CurrentChunkIdent <> PVER) then
      begin
        RaiseException(EXC_LOAD, fFileName, RsFileErrPcpCrpt);
      end;

      cReader.ReadChunkDataMax(@tVers, SizeOf(tVers));
      if (tVers.Full and $0000FFFF) <> (PCP_VER_FULL and $0000FFFF) then
      begin
        RaiseException(EXC_LOAD, fFileName, RsFileErrPcpVerMismatch);
      end;

      if not cReader.FetchNextChunk then RaiseException(EXC_LOAD, fFileName, RsFileErrPcpCrpt);

      cReader.ReadChunkDataMax(@tHeader, SizeOf(tHeader));

      while cReader.CurrentChunkIdent <> PEFI do
      begin
        cReader.SkipCurrentChunk;
        cReader.FetchNextChunk;
      end;

      SetLength(aDataTypes, cReader.CurrentChunkSize div SizeOf(YPcpDataType));
      cReader.ReadChunkDataMax(@aDataTypes[0], Length(aDataTypes) * SizeOf(YPcpDataType));

      while cReader.CurrentChunkIdent <> PEHO do
      begin
        cReader.SkipCurrentChunk;
        cReader.FetchNextChunk;
      end;
      SetLength(aOffsets, tHeader.EntryCount);
      cReader.ReadChunkDataMax(@aOffsets[0], Length(aOffsets) * SizeOf(Longword));

      cReader.Stream.Seek(tHeader.StringOffset, soBeginning);
      cReader.FetchNextChunk;
      {TODO 1 -oUNUSED: if cReader.CurrentChunkSize <> 0 then
      begin
        pStrings := cMem.Current;
      end;}

      cReader.Stream.Seek(tHeader.StringIndicesOffset, soBeginning);
      cReader.FetchNextChunk;
      if cReader.CurrentChunkSize <> 0 then
      begin
        SetLength(aStringData, tHeader.StringIndicesCount);
        cReader.ReadChunkData(@aStringData[0], cReader.CurrentChunkSize);
      end;

      cReader.Stream.Seek(tHeader.RawDataOffset, soBeginning);
      cReader.FetchNextChunk;
      {TODO 1 -oUNUSED: if cReader.CurrentChunkSize <> 0 then
      begin
        pRawData := cMem.Current;
      end;}

      cReader.Stream.Seek(tHeader.RawDataIndicesOffset, soBeginning);
      cReader.FetchNextChunk;
      if cReader.CurrentChunkSize <> 0 then
      begin
        SetLength(aRawData, tHeader.RawDataIndicesCount);
        cReader.ReadChunkData(@aRawData[0], cReader.CurrentChunkSize);
      end;

      for iIdx := 0 to Int32(tHeader.EntryCount -1) do
      begin
        cReader.Stream.Seek(aOffsets[iIdx], soBeginning);
        if not cReader.FetchNextChunk or (cReader.CurrentChunkIdent <> PENT) then
        begin
          RaiseException(EXC_LOAD, fFileName, RsFileErrPcpCrpt);
        end;

        cReader.ReadChunkData(@iCount, SizeOf(iCount));
        SetLength(aData, iCount + Length(aDataTypes));
        cReader.ReadChunkDataMax(@aData[0], Length(aData) * SizeOf(Longword));

        for iInt := 0 to Length(aDataTypes) -1 do
        begin
          case aDataTypes[iInt] of
            pdtDword, pdtFloat:
            begin

            end;
            pdtString:
            begin

            end;
            pdtRaw:
            begin
            
            end;
          end;
        end;
      end;
    finally
      cReader.Free;
    end;
  finally
    cFile.Free;
  end;
end;

procedure YDbPcpMedium.SavePcpFile;
begin

end;
(*
var
  iIdx: Int32;
  iInt: Int32;
  iLen: Int32;
  iSize: Int32;
  iTotal: UInt32;
  cEntry: YDbSerializable;
  cWriter: TChunkWriter;
  cStringMap: TStrIntHashMap;
  tHeader: YPcpHeaderChunk;
  tVers: TVersion;
  aTypeData: array of YPcpDataType;
  aLongBuf: array of Longword;
  aStringData: array of record
    Offset: UInt32;
    Length: Int32;
  end;
  aOffsets: array of Longword;
  sTemp: string;
  sStringData: string;
  iLongBufInd: Int32;
  pRawData: Pointer;
  aRawData: array of record
    Offset: UInt32;
    Size: Int32;
  end;
  iTotalRaw: UInt32;
  iTmp: UInt32;
  icVar: IVariant;
  sErr: string;

  function CheckNewString(const sStr: string): Int32;
  begin
    if sStr = '' then
    begin
      { Empty strings use the -1 constant }
      Result := -1;
    end else if not cStringMap.ContainsKey(sStr) then
    begin
      { A new string }
      Result := Length(aStringData);
      SetLength(aStringData, Result + 1);
      aStringData[Result].Offset := iTotal;
      aStringData[Result].Length := Length(sStr);
      iLen := Length(sStr) + 1;
      SetLength(sStringData, Int32(iTotal) + iLen);
      OffsetMove(Pointer(sStr)^, Pointer(sStringData)^, iLen, 0, iTotal);
      Inc(iTotal, iLen);
      cStringMap.PutValue(sStr, Result);
    end else
    begin
      { This string has been added before already }
      Result := cStringMap.GetValue(sStr);
    end;
  end;
begin
  cWriter := TChunkWriter.Create(nil, True);
  try
    cWriter.Stream := TCachedFileStream.Create(fFileName, fmCreate, True, 0, 1 shl 18);
    tVers.Full := PCP_VER_FULL;
    cWriter.WriteChunk(PVER, @tVers, SizeOf(tVers));

    FillChar(tHeader, SizeOf(tHeader), 0);

    iTotal := 0;
    iTotalRaw := 0;

    { Now fill the field type array }
    SetLength(aTypeData, fClassDataLen);
    for iIdx := 0 to fClassDataLen - 1 do
    begin
      Assert(fClassData^.Data[iIdx].Info^.Info <> nil);
      case fClassData^.Data[iIdx].Info^.Info.RttiType of
        tkeInteger, tkeEnum, tkeSet: aTypeData[iIdx] := pdtDword;
        tkeFloat: aTypeData[iIdx] := pdtFloat;
        tkeLString: aTypeData[iIdx] := pdtString;
        tkeArray, tkeDynArray: aTypeData[iIdx] := pdtRaw;
      else
        Assert(False);
      end;
    end;

    { Skip the header and write the field type table }
    cWriter.WriteEmptyChunk(PHDR, SizeOf(tHeader));
    cWriter.WriteChunk(PEFI, @aTypeData[0], Length(aTypeData) * SizeOf(YPcpDataType));
    cWriter.WriteEmptyChunk(PEHO, fCount * SizeOf(Longword));

    SetLength(aOffsets, fCount);
    tHeader.EntryCount := fCount;
    tHeader.EntryOffset := cWriter.Stream.Position;

    pRawData := nil;
    try
      cStringMap := TStrIntHashMap.Create(False, fCount);
      try
        for iIdx := 0 to fCount -1 do
        begin
          iLongBufInd := 1;
          cEntry := fIdList[iIdx];
          aOffsets[iIdx] := cWriter.Stream.Position;
          SetLength(aLongBuf, fClassDataLen + cEntry.CustomDataCount + 1);
          aLongBuf[0] := cEntry.CustomDataCount;
          for iInt := 0 to fClassDataLen -1 do
          begin
            sErr := '';
            case aTypeData[iInt] of
              pdtDword, pdtFloat:
              begin
                { Writing Int or Float - directly write their binary value }
                SystemSerializationRegistry.InvokeSerializationRoutine(cEntry, @aLongBuf[iLongBufInd],
                  doSave, dtBinary, fClassData^.Data[iInt].Name, fClassData, sErr);
              end;
              pdtString:
              begin
                SystemSerializationRegistry.InvokeSerializationRoutine(cEntry, @sTemp,
                  doSave, dtText, fClassData^.Data[iInt].Name, fClassData, sErr);
                { Write the offset table index }
                aLongBuf[iLongBufInd] := CheckNewString(sTemp);
              end;
              pdtRaw:
              begin
                iLen := Length(aRawData);
                SetLength(aRawData, iLen + 1);
                SystemSerializationRegistry.InvokeSerializationRoutine(cEntry, @iSize,
                  doSizeQuery, dtBinary, fClassData^.Data[iInt].Name, fClassData, sErr);
                aRawData[iLen].Offset := iTotalRaw;
                aRawData[iLen].Size := iSize;
                aLongBuf[iLongBufInd] := iLen;
                iTmp := iTotalRaw;
                Inc(iTotalRaw, iSize);
                ReallocMem(pRawData, iTotalRaw);
                SystemSerializationRegistry.InvokeSerializationRoutine(cEntry,
                  Pointer(Longword(pRawData) + iTmp), doSave, dtBinary,
                  fClassData^.Data[iInt].Name, fClassData, sErr);
              end;
            end;
            Inc(iLongBufInd);
          end;
  
          for iInt := 0 to cEntry.CustomDataCount -1 do
          begin
            cEntry.GetCustomDataByIndex(iInt, icVar);
            case icVar.GetDataType of
              vtInt, vtFloat:
              begin
                icVar.GetData(aLongBuf[iLongBufInd]);
              end;
              vtString:
              begin
                icVar.GetData(sTemp);
                aLongBuf[iLongBufInd] := CheckNewString(sTemp);
              end;
              vtBinary:
              begin
                aLongBuf[iLongBufInd] := 0;
              end;
            end;
            Inc(iLongBufInd);
          end;
  
          cWriter.WriteChunk(PENT, @aLongBuf[0], Length(aLongBuf) * SizeOf(Longword));
        end;
      finally
        cStringMap.Free;
      end;
  
      tHeader.StringIndicesCount := Length(aStringData);
      tHeader.StringIndicesOffset := cWriter.Stream.Position;
      cWriter.WriteChunk(PSTI, @aStringData[0], Length(aStringData) * SizeOf(Longword) * 2);
  
      tHeader.StringCount := tHeader.StringIndicesCount;
      tHeader.StringOffset := cWriter.Stream.Position;
      cWriter.WriteChunk(PSTR, Pointer(sStringData), Length(sStringData));

      tHeader.RawDataIndicesOffset := cWriter.Stream.Position;
      tHeader.RawDataIndicesCount := Length(aRawData);
      cWriter.WriteChunk(PRWI, @aRawData[0], Length(aRawData) * SizeOf(Longword) * 2);

      tHeader.RawDataOffset := cWriter.Stream.Position;
      tHeader.RawDataCount := tHeader.RawDataIndicesCount;
      cWriter.WriteChunk(PRAW, pRawData, iTotalRaw);
    finally
      if pRawData <> nil then FreeMem(pRawData);
    end;

    cWriter.Stream.Seek(SizeOf(TChunkInfo) * 2 + SizeOf(TVersion), spStart);
    cWriter.Stream.Write(tHeader, SizeOf(tHeader));

    cWriter.Stream.Seek(SizeOf(TChunkInfo) * 2 + fClassDataLen * SizeOf(YPcpDataType), spCurrent);
    cWriter.WriteChunkData(@aOffsets[0], Length(aOffsets) * SizeOf(Longword));
  finally
    cWriter.Free;
  end;
end;
*)

end.
