{*------------------------------------------------------------------------------
  Patch Manager

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.NetworkCore.Patches;

interface

uses
  Framework.Base,
  Bfg.Classes,
  Classes,
  Bfg.Crypto,
  Bfg.Containers,
  SysUtils;

const
  MAX_CHUNK_SIZE = 122880; { Max Chunk Size - 120kB }
  PATCH_ENDED = -1;

type
  PPatchChunk = ^YPatchChunk;
  YPatchChunk = packed record
    Size: Int32;
    ReadPos: Int32;
    Chunk: array[0..MAX_CHUNK_SIZE-1] of Byte;
  end;

  PPatchInfo = ^YPatchInfo;
  YPatchInfo = record
    MD5: WideString;
    FileName: WideString;
    Size: Int64;
  end;

  YNwPatch = class(TObject)
    private
      FFile: TWideFileStream;
      FChunk: YPatchChunk;
      FChunkSize: Int32;
      FInfo: PPatchInfo;
      FType: WideString;
      FEnded: Boolean;

      function GetPatchSize: UInt64;
      function GetMD5: WideString;
      procedure LoadFile;
    public
      constructor Create; reintroduce;
      destructor Destroy; override;
      procedure ReadChunk;
      function GetCurrentChunkSize: Int32;
      procedure AddChunkToBuffer(var Buf);
      function IsChunkAvailable: Boolean;
      function ResumeAt(const Offset: UInt64): Boolean;
      property PatchType: WideString read FType;
      property PatchSize: UInt64 read GetPatchSize;
      property PatchMD5: WideString read GetMD5;
  end;

  YNwPatchManager = class(TInterfacedObject)
    private
      FPatches: TStrPtrHashMap;
      FMD5: THashingAlgorithm;
    public
      constructor Create;
      destructor Destroy; override;
      procedure Load(PatchPath: WideString);
      procedure Clear;
      function HasPatch(Build: Int32; const Locale: WideString): Boolean;
      function RetrievePatch(Build: Int32; const Locale: WideString; ChunkSize: Int32): YNwPatch;
  end;

implementation

uses
  Cores,
  Framework,
  Math,
  Resources,
  Bfg.Utils,
  Bfg.Unicode;

//------------------------------------------------------------------------------
// YPatch Manager
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// YPM - Clear
//------------------------------------------------------------------------------
procedure YNwPatchManager.Clear;
var
  Itr: IPtrIterator;
begin
  Itr := FPatches.Values;
  while Itr.HasNext do
  begin
    Dispose(PPatchInfo(Itr.Next));
  end;

  FPatches.Clear;
end;

//------------------------------------------------------------------------------
// YPM - Has Patch?
//------------------------------------------------------------------------------
function YNwPatchManager.HasPatch(Build: Int32; const Locale: WideString): Boolean;
begin
  Result := FPatches.ContainsKey(Locale + '.' + itoa(Build) + '.mpq');
end;

//------------------------------------------------------------------------------
// YPM - Load
//------------------------------------------------------------------------------
procedure YNwPatchManager.Load(PatchPath: WideString);
var
  SrcRec: TWideSearchRec;
  SrcPath: Widestring;
  MD5: WideString;
  PatchInfo: PPatchInfo;
begin
  { Setting Up Search }
  PatchPath := WideExcludeTrailingPathDelimiter(PatchPath);

  SrcPath := PatchPath + '/*.mpq';
  SrcPath := FileNameToOS(SrcPath);

  PatchPath := PatchPath + '/';
  PatchPath := FileNameToOS(PatchPath);

  if WideFindFirst(SrcPath , $FF { All }, SrcRec) = 0 then
  begin
    try
      repeat
        if WideFileExists(PatchPath + SrcRec.Name) then
        begin
          FMD5.Initialize;
          FMD5.FileHash(PatchPath + SrcRec.Name);
          FMD5.Finalize;

          MD5 := FMD5.DigestAsHex;

          New(PatchInfo);
          try
            PatchInfo^.MD5 := MD5;
            PatchInfo^.FileName := PatchPath + SrcRec.Name;
            PatchInfo^.Size := SrcRec.Size;

            FPatches.PutValue(SrcRec.Name, PatchInfo);
          except
            Dispose(PatchInfo);
            raise;
          end;

          IoCore.Console.WriteLoadPatch(SrcRec.Name, MD5);
          { Add file to list }
        end;
      until WideFindNext(SrcRec) <> 0;
    finally
      WideFindClose(SrcRec);
    end;
  end;
end;

//------------------------------------------------------------------------------
// YPM - Destroy Object
//------------------------------------------------------------------------------
destructor YNwPatchManager.Destroy;
begin
  Clear;
  FPatches.Free;
  FMD5.Free;
  inherited Destroy;
end;

//------------------------------------------------------------------------------
// YPM - Initialize Object
//------------------------------------------------------------------------------
constructor YNwPatchManager.Create;
begin
  inherited Create;
  FPatches := TStrPtrHashMap.Create(False, 16);
  FMD5 := TMD5Hash.Create;
end;

//------------------------------------------------------------------------------
// YPM - Retreive Patch
//------------------------------------------------------------------------------
function YNwPatchManager.RetrievePatch(Build: Int32; const Locale: WideString; ChunkSize: Int32): YNwPatch;
var
  PatchInfo: PPatchInfo;
begin
  Result := nil;

  PatchInfo := FPatches.GetValue(Locale + '.' + itoa(Build) + '.mpq');
  if PatchInfo = nil then Exit;

  Result := YNwPatch.Create;
  Result.FInfo := PatchInfo;
  Result.LoadFile;
  Result.FType := 'Patch';

  if ChunkSize <= MAX_CHUNK_SIZE then
  begin
    Result.FChunkSize := ChunkSize;
  end else
  begin
    Result.FChunkSize := MAX_CHUNK_SIZE;
  end;
end;
//------------------------------------------------------------------------------
// YPatch
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// YP - CREATE
//------------------------------------------------------------------------------
constructor YNwPatch.Create;
begin
  inherited Create;
  FChunk.ReadPos := -1;
end;

//------------------------------------------------------------------------------
// YP - DESTROY
//------------------------------------------------------------------------------
destructor YNwPatch.Destroy;
begin
  FFile.Free;
  inherited Destroy;
end;

//------------------------------------------------------------------------------
// YP - Get CHUNK
//------------------------------------------------------------------------------
procedure YNwPatch.ReadChunk;
begin
  if FEnded then
  begin
    FChunk.Size := PATCH_ENDED;
    Exit;
  end;

  if (FChunk.ReadPos + FChunkSize >= FChunk.Size) or (FChunk.ReadPos = -1) then
  begin
    FChunkSize := FFile.Read(FChunk.Chunk[0], SizeOf(FChunk.Chunk));
    FChunk.ReadPos := 0;
  end else Inc(FChunk.ReadPos, FChunkSize);

  if FChunk.Size < FChunkSize then FEnded := True;
end;

procedure YNwPatch.AddChunkToBuffer(var Buf);
begin
  Move(FChunk.Chunk[FChunk.ReadPos], Buf, GetCurrentChunkSize);
end;

function YNwPatch.IsChunkAvailable: Boolean;
begin
  Result := FChunk.Size <> PATCH_ENDED;
end;

function YNwPatch.GetCurrentChunkSize: Int32;
begin
  Result := Min(FChunkSize, Max(FChunk.Size - FChunk.ReadPos, 0));
end;

function YNwPatch.GetMD5: WideString;
begin
  Result := FInfo^.MD5;
end;

//------------------------------------------------------------------------------
// YP - Get Patch Size
//------------------------------------------------------------------------------
function YNwPatch.GetPatchSize: UInt64;
begin
  Result := FInfo^.Size;
end;

//------------------------------------------------------------------------------
// YP - Load File
//------------------------------------------------------------------------------
procedure YNwPatch.LoadFile;
begin
  try
    FFile := TWideFileStream.Create(FInfo^.FileName, fmOpenRead);
  except
    raise EFileStreamError.CreateResFmt(@RsNetworkCoreErrPatch, [FInfo^.FileName]);
  end;
  FEnded := False;
end;

//------------------------------------------------------------------------------
// YP - Resume at position
//------------------------------------------------------------------------------
function YNwPatch.ResumeAt(const Offset: UInt64): Boolean;
begin
  Result := FFile.Seek(Offset, soBeginning) <> 0;
end;

//------------------------------------------------------------------------------
// YP - END Of File
//------------------------------------------------------------------------------
end.
