{*------------------------------------------------------------------------------
  Patch Manager

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
unit Components.NetworkCore.Patches;

interface

uses
  Framework.Base,
  Misc.Classes,
  Classes,
  Misc.Hash,
  Misc.Containers,
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
    MD5: string;
    FileName: string;
    Size: Int64;
  end;

  YNwPatch = class(TBaseObject)
    private
      fFile: TFileStream;
      fChunk: YPatchChunk;
      fChunkSize: Int32;
      fInfo: PPatchInfo;
      fType: string;
      fEnded: Boolean;

      function GetPatchSize: UInt64;
      function GetMD5: string;
      procedure LoadFile;
    public
      constructor Create; reintroduce;
      destructor Destroy; override;
      procedure ReadChunk;
      function GetCurrentChunkSize: Int32;
      procedure AddChunkToBuffer(var xBuf);
      function IsChunkAvailable: Boolean;
      function ResumeAt(const iIdx: UInt64): Boolean;
      property PatchType: string read fType;
      property PatchSize: UInt64 read GetPatchSize;
      property PatchMD5: string read GetMD5;
  end;

  YNwPatchManager = class(TBaseObject)
    private
      fPatches: TStrPtrHashMap;
      fMD5: THashingAlgorithm;
    public
      constructor Create;
      destructor Destroy; override;
      procedure Load(sPatchPath: string);
      procedure Clear;
      function HasPatch(iBuild: Int32; const sLocale: string): Boolean;
      function RetrievePatch(iBuild: Int32; const sLocale: string; iChunkSize: Int32): YNwPatch;
  end;

implementation

uses
  Cores,
  Framework,
  Math,
  Resources,
  Misc.Miscleanous;

//------------------------------------------------------------------------------
// YPatch Manager
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// YPM - Clear
//------------------------------------------------------------------------------
procedure YNwPatchManager.Clear;
var
  ifItr: IPtrIterator;
begin
  ifItr := fPatches.Values;
  while ifItr.HasNext do
  begin
    Dispose(PPatchInfo(ifItr.Next));
  end;

  fPatches.Clear;
end;

//------------------------------------------------------------------------------
// YPM - Has Patch?
//------------------------------------------------------------------------------
function YNwPatchManager.HasPatch(iBuild: Int32; const sLocale: string): Boolean;
begin
  Result := fPatches.ContainsKey(sLocale + '.' + itoa(iBuild) + '.mpq');
end;

//------------------------------------------------------------------------------
// YPM - Load
//------------------------------------------------------------------------------
procedure YNwPatchManager.Load(sPatchPath: string);
var
  tSrcRec: TSearchRec;
  sSrcPath: string;
  sMD5: string;
  pPatch: PPatchInfo;
begin
  { Setting Up Search }
  sPatchPath := ExcludeTrailingPathDelimiter(sPatchPath);

  sSrcPath := sPatchPath + '/*.mpq';
  sSrcPath := FileNameToOS(sSrcPath);

  sPatchPath := sPatchPath + '/';
  sPatchPath := FileNameToOS(sPatchPath);

  if FindFirst(sSrcPath , $FF { All }, tSrcRec) = 0 then
  begin
    repeat
      if FileExists(sPatchPath + tSrcRec.Name) then
      begin
        fMD5.Initialize;
        fMD5.FileHash(sPatchPath + tSrcRec.Name);
        fMD5.Finalize;

        sMD5 := fMD5.DigestAsHex;

        New(pPatch);
        pPatch^.MD5 := sMD5;
        pPatch^.FileName := sPatchPath + tSrcRec.Name;
        pPatch^.Size := tSrcRec.Size;

        fPatches.PutValue(tSrcRec.Name, pPatch);

        IoCore.Console.WriteLoadPatch(tSrcRec.Name, sMD5);
        { Add file to list }
      end;
    until FindNext(tSrcRec) <> 0;
  end;
  SysUtils.FindClose(tSrcRec);
end;

//------------------------------------------------------------------------------
// YPM - Destroy Object
//------------------------------------------------------------------------------
destructor YNwPatchManager.Destroy;
begin
  Clear;
  fPatches.Free;
  fMD5.Free;
  inherited Destroy;
end;

//------------------------------------------------------------------------------
// YPM - Initialize Object
//------------------------------------------------------------------------------
constructor YNwPatchManager.Create;
begin
  inherited Create;
  fPatches := TStrPtrHashMap.Create(False, 16);
  fMD5 := TMD5Hash.Create;
end;

//------------------------------------------------------------------------------
// YPM - Retreive Patch
//------------------------------------------------------------------------------
function YNwPatchManager.RetrievePatch(iBuild: Int32; const sLocale: string; iChunkSize: Int32): YNwPatch;
var
  pPatch: PPatchInfo;
begin
  Result := nil;

  pPatch := fPatches.GetValue(sLocale + '.' + itoa(iBuild) + '.mpq');
  if pPatch = nil then Exit;

  Result := YNwPatch.Create;
  Result.fInfo := pPatch;
  Result.LoadFile;
  Result.fType := 'Patch';

  if iChunkSize <= MAX_CHUNK_SIZE then
  begin
    Result.fChunkSize := iChunkSize;
  end else
  begin
    Result.fChunkSize := MAX_CHUNK_SIZE;
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
  fChunk.ReadPos := -1;
end;

//------------------------------------------------------------------------------
// YP - DESTROY
//------------------------------------------------------------------------------
destructor YNwPatch.Destroy;
begin
  fFile.Free;
  inherited Destroy;
end;

//------------------------------------------------------------------------------
// YP - Get CHUNK
//------------------------------------------------------------------------------
procedure YNwPatch.ReadChunk;
begin
  if fEnded then
  begin
    fChunk.Size := PATCH_ENDED;
    Exit;
  end;

  if (fChunk.ReadPos + fChunkSize >= fChunk.Size) or (fChunk.ReadPos = -1) then
  begin
    fChunkSize := fFile.Read(fChunk.Chunk[0], SizeOf(fChunk.Chunk));
    fChunk.ReadPos := 0;
  end else Inc(fChunk.ReadPos, fChunkSize);

  if fChunk.Size < fChunkSize then fEnded := True;
end;

procedure YNwPatch.AddChunkToBuffer(var xBuf);
begin
  Move(fChunk.Chunk[fChunk.ReadPos], xBuf, GetCurrentChunkSize);
end;

function YNwPatch.IsChunkAvailable: Boolean;
begin
  Result := fChunk.Size <> PATCH_ENDED;
end;

function YNwPatch.GetCurrentChunkSize: Int32;
begin
  Result := Min(fChunkSize, Max(fChunk.Size - fChunk.ReadPos, 0));
end;

function YNwPatch.GetMD5: string;
begin
  Result := fInfo^.MD5;
end;

//------------------------------------------------------------------------------
// YP - Get Patch Size
//------------------------------------------------------------------------------
function YNwPatch.GetPatchSize: UInt64;
begin
  Result := fInfo^.Size;
end;

//------------------------------------------------------------------------------
// YP - Load File
//------------------------------------------------------------------------------
procedure YNwPatch.LoadFile;
begin
  try
    fFile := TFileStream.Create(fInfo^.FileName, fmOpenRead);
  except
    raise EFileStreamError.CreateResFmt(@RsNetworkCoreErrPatch, [fInfo^.FileName]);
  end;
  fEnded := False;
end;

//------------------------------------------------------------------------------
// YP - Resume at position
//------------------------------------------------------------------------------
function YNwPatch.ResumeAt(const iIdx: UInt64): Boolean;
begin
  Result := fFile.Seek(iIdx, soBeginning) <> 0;
end;

//------------------------------------------------------------------------------
// YP - END Of File
//------------------------------------------------------------------------------
end.
