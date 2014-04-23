{*------------------------------------------------------------------------------
  Semi-abstract class used to represent in-memory database types.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.DataCore.MemoryStorage;

interface

uses
  Framework.Base,
  Version,
  Components.DataCore.Storage,
  Components.DataCore.Fields,
  Framework.SerializationRegistry,
  Components.DataCore.Types,
  Misc.Threads,
  Misc.Miscleanous,
  Misc.Containers,
  Classes,
  SysUtils;

type
  YMemoryStorageMediumClass = class of YDbMemoryStorageMedium;

  YDbMemoryStorageMedium = class(YDbStorageMedium, IStorage)
    protected
      fDataBlocks: array of Pointer;
      fBlockCapacities: array of Int32;
      fFreeList: TList;
      fCount: Int32;
      fIdList: TPtrArrayList;
      fHighestId: UInt32;
      fLock: TReaderWriterLock;

      procedure AllocationCallback(Inst: TObject);
      procedure InternalAllocateNewClassBuffer(iInstCount: Int32 = 0);
      function InternalGetFreeClassInstance: Pointer;

      class procedure RaiseException(iType: Int32; const sFile: string;
        const sMsg: string); static;

      procedure FinalSaveMedium; override;

      {
       Data manipulation routines.
      }
      function LoadEntryById(iId: UInt32): YDbSerializable; override;
      function LoadEntryMediumInteger(iOffset: Int32; iEqualsTo: Int32): YDbSerializable; override;
      function LoadEntryMediumString(iOffset: Int32; const sEqualsTo: string): YDbSerializable; override;
      function LoadEntryMediumFloat(iOffset: Int32; const fEqualsTo: Float): YDbSerializable; override;

      procedure SaveMassFieldMediumInteger(iOffset: Int32; iValue: Int32); override;
      procedure SaveMassFieldMediumString(iOffset: Int32; const sValue: string); override;
      procedure SaveMassFieldMediumFloat(iOffset: Int32; const fValue: Float); override;

      procedure DeleteEntryMedium(iId: UInt32); override;
      procedure SaveEntryMedium(cEntry: YDbSerializable); override;
      procedure CreateEntryMedium(out cEntry: YDbSerializable; iId: UInt32); override;
      procedure ReleaseEntryMedium(cEntry: YDbSerializable); override;

      function CountEntriesMediumInteger(iOffset: Int32; iValue: Int32): Int32; override;
      function CountEntriesMediumString(iOffset: Int32; const sValue: string): Int32; override;
      function CountEntriesMediumFloat(iOffset: Int32; const fValue: Float): Int32; override;

      procedure LoadEntryListMediumInteger(iOffset: Int32; iEqualsTo: Int32;
        out aArr: YDbSerializables); override;

      procedure LoadEntryListMediumString(iOffset: Int32; const sEqualsTo: string;
        out aArr: YDbSerializables); override;

      procedure LoadEntryListMediumFloat(iOffset: Int32; const fEqualsTo: Float;
        out aArr: YDbSerializables); override;

      function LoadMaxIdMedium: UInt32; override;

      function Clone(cClass: YMemoryStorageMediumClass): YDbMemoryStorageMedium;
    public
      function GetNumberOfElements: Int32; override;
      constructor Create; 
      destructor Destroy; override;
  end;

const
  MEM_STORE_DEFAULT_CAPACITY = $800;

  THREAD_SAFE_BLOCK_ENTRY_COUNT = 24;

  { Exception types }
  EXC_OTHER = 0;
  EXC_LOAD = 1;
  EXC_SAVE = 2;

implementation

uses
  Math,
  Resources,
  Framework;

{ YMemoryStorageMedium }

constructor YDbMemoryStorageMedium.Create;
begin
  inherited Create;
  fIdList := TPtrArrayList.Create;
  fFreeList := TList.Create;

  fLock.Init;
end;

destructor YDbMemoryStorageMedium.Destroy;
begin
  fIdList.Free;
  fFreeList.Free;
  fLock.Delete;
  inherited Destroy;
end;

{$REGION 'Create/Delete/Save/Release EntryMedium'}
procedure YDbMemoryStorageMedium.CreateEntryMedium(out cEntry: YDbSerializable;
  iId: UInt32);
var
  cDbEntry: YDbSerializable;
begin
  Assert(not fClassType.IsReadOnly, 'Tried to alter a read-only class instance!');
  fLock.BeginWrite;
  try
    cDbEntry := InternalGetFreeClassInstance;
    cEntry := InternalGetFreeClassInstance;
    if iId = 0 then
    begin
      Inc(fHighestId);
      cEntry.UniqueID := fHighestId;
      cDbEntry.UniqueId := fHighestId;
    end else
    begin
      cEntry.UniqueID := iId;
      cDbEntry.UniqueId := iId;
      if iId > fHighestId then fHighestId := iId;
    end;
    Inc(fCount);
    fIdList.Add(cDbEntry);
  finally
    fLock.EndWrite;
  end;
end;

procedure YDbMemoryStorageMedium.DeleteEntryMedium(iId: UInt32);
var
  iIdx: Int32;
  cEntry: YDbSerializable;
begin
  fLock.BeginRead;
  try
    iIdx := fIdList.CustomIndexOf(Pointer(iId), @MatchSerializablesById);
    if iIdx <> -1 then
    begin
      fLock.BeginWrite;
      try
        cEntry := fIdList[iIdx];
        cEntry.Cleanup;
        cEntry.CleanupInstance;
        cEntry.InitInstance(cEntry);
        cEntry.Create;
        fIdList.Remove(iIdx);
        fFreeList.Add(cEntry);
        Dec(fCount);
      finally
        fLock.EndWrite;
      end;
    end;
  finally
    fLock.EndRead;
  end;
end;

procedure YDbMemoryStorageMedium.ReleaseEntryMedium(cEntry: YDbSerializable);
begin
  if cEntry <> nil then
  begin
    fLock.BeginWrite;
    try
      cEntry.Cleanup;
      cEntry.CleanupInstance;
      cEntry.InitInstance(cEntry);
      cEntry.Create;
      fFreeList.Add(cEntry);
    finally
      fLock.EndWrite;
    end;
  end;
end;

procedure YDbMemoryStorageMedium.SaveEntryMedium(cEntry: YDbSerializable);
var
  iID: UInt32;
  iIdx: Int32;
begin
  Assert(not fClassType.IsReadOnly, 'Tried to alter a read-only class instance!');
  if cEntry <> nil then
  begin
    fLock.BeginWrite;
    try
      iID := cEntry.UniqueID;
      iIdx := fIdList.CustomIndexOf(Pointer(iID), @MatchSerializablesById);
      if iIdx <> -1 then
      begin
        YDbSerializable(fIdList[iIdx]).Assign(cEntry);
        cEntry.Cleanup;
        cEntry.CleanupInstance;
        cEntry.InitInstance(cEntry);
        cEntry.Create;
        fFreeList.Add(cEntry);
      end else
      begin
        fIdList.Add(cEntry);
        if iID > fHighestId then fHighestId := iID;
        Inc(fCount);
      end;
    finally
      fLock.EndWrite;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'CountEntriesMediumXXX'}
function YDbMemoryStorageMedium.Clone(cClass: YMemoryStorageMediumClass): YDbMemoryStorageMedium;
var
  iInt: Int32;
begin
  Result := cClass.Create;
  Result.fClassType := fClassType;
  Result.fClassName := fClassName;
  Result.fClassData := fClassData;
  Result.fClassDataLen := fClassDataLen;
  Result.fClassInstSize := fClassInstSize;
  Result.fSaveBack := fSaveBack;
  fLock.BeginRead;
  try
    Result.fHighestId := fHighestId;
    for iInt := 0 to Length(fDataBlocks) -1 do
    begin
      Result.InternalAllocateNewClassBuffer(fBlockCapacities[iInt]);
      Move(fDataBlocks[iInt]^, Result.fDataBlocks[iInt]^, fBlockCapacities[iInt] * fClassInstSize);
    end;
    Result.fCount := fCount;
  finally
    fLock.EndRead;
  end;
  Result.fIdList.CustomSort(@CompareSerializablesById);
end;

function YDbMemoryStorageMedium.CountEntriesMediumFloat(iOffset: Int32;
  const fValue: Float): Int32;
var
  iInt: Int32;
  pRec: PByte;
begin
  fLock.BeginRead;
  try
    Result := 0;
    for iInt := 0 to fCount -1 do
    begin
      pRec := fIdList[iInt];
      Inc(pRec, iOffset);
      if PFloat(pRec)^ = fValue then Inc(Result);
    end;
  finally
    fLock.EndRead;
  end;
end;

function YDbMemoryStorageMedium.CountEntriesMediumInteger(iOffset,
  iValue: Int32): Int32;
var
  iInt: Int32;
  pRec: PByte;
begin
  fLock.BeginRead;
  try
    Result := 0;
    for iInt := 0 to fCount -1 do
    begin
      pRec := fIdList[iInt];
      Inc(pRec, iOffset);
      if PInt32(pRec)^ = iValue then Inc(Result);
    end;
  finally
    fLock.EndRead;
  end;
end;

function YDbMemoryStorageMedium.CountEntriesMediumString(iOffset: Int32;
  const sValue: string): Int32;
var
  iInt: Int32;
  pRec: PByte;
begin
  fLock.BeginRead;
  try
    Result := 0;
    for iInt := 0 to fCount -1 do
    begin
      pRec := fIdList[iInt];
      Inc(pRec, iOffset);
      if StringsEqualNoCase(PString(pRec)^, sValue) then Inc(Result);
    end;
  finally
    fLock.EndRead;
  end;
end;
{$ENDREGION}

{$REGION 'LoadEntryXX'}
function YDbMemoryStorageMedium.LoadEntryById(iId: UInt32): YDbSerializable;
var
  iIdx: Int32;
  cEntry: YDbSerializable;
begin
  fLock.BeginRead;
  try
    iIdx := fIdList.CustomIndexOf(Pointer(iId), @MatchSerializablesById);
    if iIdx <> -1 then
    begin
      cEntry := fIdList[iIdx];
      Result := InternalGetFreeClassInstance;
      Result.Assign(cEntry);
    end else Result := nil;
  finally
    fLock.EndRead;
  end;
end;

function YDbMemoryStorageMedium.LoadEntryMediumFloat(iOffset: Int32;
  const fEqualsTo: Float): YDbSerializable;
var
  iInt: Int32;
  pRec: PByte;
begin
  fLock.BeginRead;
  try
    for iInt := 0 to fCount -1 do
    begin
      pRec := fIdList[iInt];
      Inc(pRec, iOffset);
      if PFloat(pRec)^ = fEqualsTo then
      begin
        Dec(pRec, iOffset);
        Result := InternalGetFreeClassInstance;
        Result.Assign(YDbSerializable(pRec));
        Exit;
      end;
    end;
    Result := nil;
  finally
    fLock.EndRead;
  end;
end;

function YDbMemoryStorageMedium.LoadEntryMediumInteger(iOffset,
  iEqualsTo: Int32): YDbSerializable;
var
  iInt: Int32;
  pRec: PByte;
begin
  fLock.BeginRead;
  try
    for iInt := 0 to fCount -1 do
    begin
      pRec := fIdList[iInt];
      Inc(pRec, iOffset);
      if PInt32(pRec)^ = iEqualsTo then
      begin
        Dec(pRec, iOffset);
        Result := InternalGetFreeClassInstance;
        Result.Assign(YDbSerializable(pRec));
        Exit;
      end;
    end;
    Result := nil;
  finally
    fLock.EndRead;
  end;
end;

function YDbMemoryStorageMedium.LoadEntryMediumString(iOffset: Int32;
  const sEqualsTo: string): YDbSerializable;
var
  iInt: Int32;
  pRec: PByte;
begin
  fLock.BeginRead;
  try
    for iInt := 0 to fCount -1 do
    begin
      pRec := fIdList[iInt];
      Inc(pRec, iOffset);
      if StringsEqualNoCase(PString(pRec)^, sEqualsTo) then
      begin
        Dec(pRec, iOffset);
        Result := InternalGetFreeClassInstance;
        Result.Assign(YDbSerializable(pRec));
        Exit;
      end;
    end;
    Result := nil;
  finally
    fLock.EndRead;
  end;
end;
{$ENDREGION}

{$REGION 'LoadEntryListXXX'}
procedure YDbMemoryStorageMedium.LoadEntryListMediumFloat(iOffset: Int32;
  const fEqualsTo: Float; out aArr: YDbSerializables);
var
  iInt: Int32;
  pRec: PByte;
  iCnt: Int32;
begin
  fLock.BeginRead;
  try
    aArr := nil;
    iCnt := 0;
    for iInt := 0 to fCount -1 do
    begin
      pRec := fIdList[iInt];
      Inc(pRec, iOffset);
      if PFloat(pRec)^ = fEqualsTo then
      begin
        Dec(pRec, iOffset);
        SetLength(aArr, iCnt + 1);
        aArr[iCnt] := InternalGetFreeClassInstance;
        aArr[iCnt].Assign(YDbSerializable(pRec));
        Inc(iCnt);
      end;
    end;
  finally
    fLock.EndRead;
  end;
end;

procedure YDbMemoryStorageMedium.LoadEntryListMediumInteger(iOffset,
  iEqualsTo: Int32; out aArr: YDbSerializables);
var
  iInt: Int32;
  pRec: PByte;
  iCnt: Int32;
begin
  fLock.BeginRead;
  try
    aArr := nil;
    iCnt := 0;
    for iInt := 0 to fCount -1 do
    begin
      pRec := fIdList[iInt];
      Inc(pRec, iOffset);
      if PInt32(pRec)^ = iEqualsTo then
      begin
        Dec(pRec, iOffset);
        SetLength(aArr, iCnt + 1);
        aArr[iCnt] := InternalGetFreeClassInstance;
        aArr[iCnt].Assign(YDbSerializable(pRec));
        Inc(iCnt);
      end;
    end;
  finally
    fLock.EndRead;
  end;
end;

procedure YDbMemoryStorageMedium.LoadEntryListMediumString(iOffset: Int32;
  const sEqualsTo: string; out aArr: YDbSerializables);
var
  iInt: Int32;
  pRec: PByte;
  iCnt: Int32;
begin
  fLock.BeginRead;
  try
    aArr := nil;
    iCnt := 0;
    for iInt := 0 to fCount -1 do
    begin
      pRec := fIdList[iInt];
      Inc(pRec, iOffset);
      if PString(pRec)^ = sEqualsTo then
      begin
        Dec(pRec, iOffset);
        SetLength(aArr, iCnt + 1);
        aArr[iCnt] := InternalGetFreeClassInstance;
        aArr[iCnt].Assign(YDbSerializable(pRec));
        Inc(iCnt);
      end;
    end;
  finally
    fLock.EndRead;
  end;
end;
{$ENDREGION}

{$REGION 'Internal and generic methods'}
procedure YDbMemoryStorageMedium.AllocationCallback(Inst: TObject);
begin
  YDbSerializable(Inst).Create;
  fFreeList.Add(Inst);
end;

procedure YDbMemoryStorageMedium.InternalAllocateNewClassBuffer(iInstCount: Int32);
var
  iIdx: Int32;
begin
  iIdx := Length(fDataBlocks);

  { Grow both arrays by one }
  SetLength(fDataBlocks, iIdx + 1);
  SetLength(fBlockCapacities, iIdx + 1);

  iInstCount := Max(MEM_STORE_DEFAULT_CAPACITY, iInstCount);

  { Store it }
  fBlockCapacities[iIdx] := iInstCount;
  { Now allocate the buffer }
  fClassType.AllocateInstanceArrayEx(fDataBlocks[iIdx], iInstCount,
    AllocationCallback);
end;

function YDbMemoryStorageMedium.InternalGetFreeClassInstance: Pointer;
var
  iCnt: Int32;
begin
  iCnt := fFreeList.Count;
  if iCnt <> 0 then
  begin
    Dec(iCnt);
    Result := fFreeList[iCnt];
    fFreeList.Delete(iCnt);
  end else
  begin
    InternalAllocateNewClassBuffer;
    iCnt := fFreeList.Count -1;
    Result := fFreeList[iCnt];
    fFreeList.Delete(iCnt);
  end;
end;

function YDbMemoryStorageMedium.GetNumberOfElements: Int32;
begin
  Result := fCount;
end;

function YDbMemoryStorageMedium.LoadMaxIdMedium: UInt32;
begin
  Result := fHighestId;
end;

class procedure YDbMemoryStorageMedium.RaiseException(iType: Int32; const sFile,
  sMsg: string);
const
  ExceptionTable: array[0..2] of EYaweExceptionClass = (
    EFrameworkException, EFileLoadError, EFileSaveError
  );
var
  pExceptionClass: EYaweExceptionClass;
begin
  if (iType < Low(ExceptionTable)) or (iType > High(ExceptionTable)) then
  begin
    pExceptionClass := EFrameworkException;
  end else
  begin
    pExceptionClass := ExceptionTable[iType];
    if pExceptionClass = nil then pExceptionClass := EFrameworkException;
  end;
  raise pExceptionClass.CreateFmt(RsFileErrOp + ' - ' + sMsg, [sFile]) at GetCurrentReturnAddress;
end;

procedure YDbMemoryStorageMedium.FinalSaveMedium;
var
  iIdx: Int32;
begin
  fLock.BeginWrite;
  for iIdx := 0 to Length(fDataBlocks) -1 do
  begin
    fClassType.FreeInstanceArray(fDataBlocks[iIdx], True);
  end;
  fDataBlocks := nil;
  fBlockCapacities := nil;
  fCount := 0;
  fHighestId := 0;
  fFreeList.Clear;
  fLock.EndWrite;
end;
{$ENDREGION}

{$REGION 'SaveMassFieldXXX'}
procedure YDbMemoryStorageMedium.SaveMassFieldMediumFloat(iOffset: Int32;
  const fValue: Float);
var
  iInt: Int32;
  pRec: PByte;
begin
  fLock.BeginWrite;
  try
    for iInt := 0 to fCount -1 do
    begin
      pRec := fIdList[iInt];
      Inc(pRec, iOffset);
      PFloat(pRec)^ := fValue;
    end;
  finally
    fLock.EndWrite;
  end;
end;

procedure YDbMemoryStorageMedium.SaveMassFieldMediumInteger(iOffset,
  iValue: Int32);
var
  iInt: Int32;
  pRec: PByte;
begin
  fLock.BeginWrite;
  try
    for iInt := 0 to fCount -1 do
    begin
      pRec := fIdList[iInt];
      Inc(pRec, iOffset);
      PInt32(pRec)^ := iValue;
    end;
  finally
    fLock.EndWrite;
  end;
end;

procedure YDbMemoryStorageMedium.SaveMassFieldMediumString(iOffset: Int32;
  const sValue: string);
var
  iInt: Int32;
  pRec: PByte;
begin
  fLock.BeginWrite;
  try
    for iInt := 0 to fCount -1 do
    begin
      pRec := fIdList[iInt];
      Inc(pRec, iOffset);
      PString(pRec)^ := sValue;
    end;
  finally
    fLock.EndWrite;
  end;
end;
{$ENDREGION}

end.
