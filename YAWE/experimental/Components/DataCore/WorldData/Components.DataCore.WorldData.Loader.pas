{*------------------------------------------------------------------------------
  Class responsible for loading world data. Heightmaps, object placements and
  all the like.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.DataCore.WorldData.Loader;

interface

uses
  SysUtils,
  Misc.Miscleanous,
  Misc.Containers,
  Misc.Classes,
  Classes,
  Version,
  Framework.Base,
  Components.DataCore.WorldData.Types;

type
  YDbWorldDataLoader = class(TBaseInterfacedObject)
    private
      fInfo: TFileHeaderChunk;
      fFile: TChunkReader;
      fFileName: string;

      fMapData: TIntPtrHashMap;

      function GetITSize: UInt32;

      procedure TriReadMapFile;
    public
      { Constructor loads the file and gets caps and other information }
      constructor Create(const sPath: string); reintroduce;
      destructor Destroy; override;
      procedure Load;

      function TrIsBlockDefined(iMapId: UInt32; iX, iY: UInt32): Boolean;
      function TrDoesMapExist(iMapId: UInt32): Boolean;
      function TrFillTileData(iMapId: UInt32; iX, iY: UInt32; pTile: PTileChunk): Boolean;
      function TrGetMapBorders(iMapId: UInt32; out tBorders: TRect): Boolean;

      property MapCount: UInt32 read fInfo.NumberOfMaps;
      property IndexTableSize: UInt32 read GetITSize;
    end;

implementation

uses
  Resources,
  Ucl.LibInterface,
  Framework;

type
  PMapHeaderChunkEx = ^YMapHeaderChunkEx;
  YMapHeaderChunkEx = packed record
    Standard: TMapHeaderChunk;
    Mask: TBlockMaskChunk;
    Offsets: TBlockOffsetsChunk;
  end;

const
  TerrainFile = 'terrain.smd';

{ YWorldDataLoader }

constructor YDbWorldDataLoader.Create(const sPath: string);
begin
  inherited Create;
  fMapData := TIntPtrHashMap.Create(1024);
  fFileName := IncludeTrailingPathDelimiter(sPath) + TerrainFile;
end;

destructor YDbWorldDataLoader.Destroy;
var
  ifItr: IPtrIterator;
begin
  ifItr := fMapData.Values;
  while ifItr.HasNext do
  begin
    Dispose(PMapHeaderChunkEx(ifItr.Next));
  end;

  fMapData.Free;
  fFile.Free;
  inherited Destroy;
end;

procedure YDbWorldDataLoader.TriReadMapFile;
var
  aMapIndexes: array of TMapEntryInfo;
  iInt: Int32;
  pHeader: PMapHeaderChunkEx;
  tVers: TVersion;
begin
  if not FileExists(fFileName) then
  begin
    raise EMediumOperationFailed.Create(Format(RsFileErrTTNo, [fFileName]), MOF_LOAD);
  end;

  fFile := TChunkReader.Create(fFileName, fmOpenRead);

  { File Loading }
  if fFile.Size < SizeOf(fInfo) then
  begin
    raise EFileLoadError.CreateResFmt(@RsMapMgrCorrupted, [fFileName]);
  end;
  
  with fFile do
  begin
    if not FetchNextChunk then raise EFileLoadError.CreateResFmt(@RsMapMgrCorrupted, [fFileName]);
    if CurrentChunkIdent <> TVER then raise EFileLoadError.CreateResFmt(@RsMapMgrCorrupted, [fFileName]);

    ReadChunkDataMax(@tVers, SizeOf(tVers));
    if (tVers.Full and $0000FFFF) = (FILE_VER_FULL and $0000FFFF) then //Revision and Build can differ
    begin
      if not FetchNextChunk then raise EFileLoadError.CreateResFmt(@RsMapMgrCorrupted, [fFileName]);

      if CurrentChunkIdent = THDR then
      begin
        ReadChunkDataMax(@fInfo, SizeOf(fInfo));
        iInt := fInfo.NumberOfMaps;
        SetLength(aMapIndexes, iInt);

        if not FetchNextChunk or (CurrentChunkIdent <> TMHO) then Exit;

        ReadChunkDataMax(@aMapIndexes[0], SizeOf(TMapEntryInfo) * iInt);

        for iInt := 0 to fInfo.NumberOfMaps -1 do
        begin
          Seek(aMapIndexes[iInt].Offset, soBeginning);

          if not FetchNextChunk or (CurrentChunkIdent <> TMAP) then Continue;

          New(pHeader);
          ReadChunkDataMax(pHeader, SizeOf(TMapHeaderChunk));
          fMapData.PutValue(pHeader^.Standard.MapId, pHeader);

          while True do
          begin
            if not FetchNextChunk then Break;
            case CurrentChunkIdent of
              TMBM: ReadChunkDataMax(@pHeader^.Mask.BlockMask[0], SizeOf(pHeader^.Mask));
              TMBO: ReadChunkDataMax(@pHeader^.Offsets.BlockOffsets[0, 0], SizeOf(TBlockOffsetsChunk));
            else
              Break;
            end;
          end;
        end;
      end else EFileLoadError.CreateResFmt(@RsMapMgrCorrupted, [fFileName]);
    end else raise EFileLoadError.CreateResFmt(@RsMapMgrBadVer, [tVers.Major,
      tVers.Minor, fFileName, FILE_VER_MAJOR, FILE_VER_MINOR]);
  end;
end;

function YDbWorldDataLoader.TrDoesMapExist(iMapId: UInt32): Boolean;
begin
  Result := fMapData.GetValue(iMapId) <> nil;
end;

function YDbWorldDataLoader.TrFillTileData(iMapId, iX, iY: UInt32;
  pTile: PTileChunk): Boolean;
var
  pHeader: PMapHeaderChunkEx;
  iOffset: Int64;
  tCompressed: TCompressedTileChunk;
begin
  pHeader := fMapData.GetValue(iMapId);
  if pHeader <> nil then
  begin
    if (iX < TILES_PER_MAP) and
       (iY < TILES_PER_MAP) then
    begin
      iOffset := pHeader^.Offsets.BlockOffsets[iY, iX];
      if iOffset <> 0 then
      begin
        with fFile do
        begin
          Stream.Seek(iOffset, soBeginning);
          if not FetchNextChunk then
          begin
            Result := False;
            Exit;
          end;
          if CurrentChunkIdent = TTIL then
          begin
            ReadChunkData(@pTile^.Flags, SizeOf(Longword) * 3);
            if (pTile^.Flags and 1) <> 0 then
            begin
              ReadChunkData(@tCompressed.TileData, CurrentChunkSize - SizeOf(Longword) * 3);
              UclDecompressBuf2(@tCompressed.TileData, CurrentChunkSize - SizeOf(Longword) * 3,
               @pTile^.Borders, UCL_METHOD_2E, SizeOf(TTileChunk));
            end else
            begin
              fFile.ReadChunkDataMax(@pTile^.Borders, SizeOf(TTileChunk) - SizeOf(Longword) * 3);
            end;
            Result := True;
          end else Result := False;
        end;
      end else Result := False;
    end else Result := False;
  end else Result := False;
end;

function YDbWorldDataLoader.TrGetMapBorders(iMapId: UInt32; out tBorders: TRect): Boolean;
var
  pHeader: PMapHeaderChunkEx;
begin
  pHeader := fMapData.GetValue(iMapId);
  if pHeader <> nil then
  begin
    tBorders := pHeader^.Standard.Borders;
    Result := True;
  end else Result := False;
end;

function YDbWorldDataLoader.TrIsBlockDefined(iMapId: UInt32; iX, iY: UInt32): Boolean;
var
  pHeader: PMapHeaderChunkEx;
begin
  pHeader := fMapData.GetValue(iMapId);
  if pHeader <> nil then
  begin
    if (iX < TILES_PER_MAP) and
       (iY < TILES_PER_MAP) then
    begin
      Result := GetBit(@pHeader^.Mask, (iY * TILES_PER_MAP) + iX);
    end else Result := False;
  end else Result := False;
end;

function YDbWorldDataLoader.GetITSize: UInt32;
begin
  Result := fInfo.NumberOfMaps * SizeOf(YMapHeaderChunkEx);
end;

procedure YDbWorldDataLoader.Load;
begin
  TriReadMapFile;
end;

end.
