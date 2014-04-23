{*------------------------------------------------------------------------------
  Factory system.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.Factory;

interface

uses
  Components.GameCore.WowObject,
  Framework.Base,
  Classes,
  Bfg.Containers;

type
  { YFactory class }
  YGaFactory = class(TObject)
    private
      fName: string;
      fBlockList: TList;
      fBlockCount: Int32;
      fSize: Int32;
      fFreeList: TList;
      fCapacity: Int32;
      fClass: YWowObjectClass;
      fGrowAmount: Int32;
      fCore: TObject;
      function GetCount: Int32;
      function GetFreeCount: Int32;
      procedure AddObjects(pBlockptr: Pointer; iNumObjects: Int32);
    public
      constructor Create(pFactoryClass: YWowObjectClass; iCapacity: Int32; const sName: string;
        cCoreObject: TObject; iGrowAmount: Int32 = -1); reintroduce;
      destructor Destroy; override;
      function Assemble: YGaWowObject;
      procedure GrowFactory(iExtraObjects: Int32);
      procedure Recycle(cFactoryObject: YGaWowObject);
      property Capacity: Int32 read fCapacity;
      property UsedInstanceCount: Int32 read GetCount;
      property FreeInstanceCount: Int32 read GetFreeCount;
      property Name: string read fName;
      property BlockCount: Int32 read fBlockcount;
      property GrowAmount: Int32 read fGrowAmount write fGrowAmount;
  end;

  { Internal markers }
  PObjectHeader = ^YObjectHeader;
  YObjectHeader = record
    Valid: Int32;
    Recycled: LongBool;
    Factory: YGaFactory;
  end;

implementation

uses
  SysUtils,
  Bfg.Resources;

type
  EFactoryException = class(EFrameworkException);

const
  EObjectsInUse = 'Factory: %s has objects still in use!';
  EInvalidOp = 'Invalid pointer operation - tried to deallocate an already freed object (%s)!';
  
  ERR_OBJECT_OK = 0;
  ERR_OBJECT_INVALID_REF = -1;

{ procedure AddObjects }
procedure YGaFactory.AddObjects(pBlockPtr: Pointer; iNumObjects: Int32);
var
  iIndex: Int32;
  pHeader: PObjectHeader absolute pBlockPtr;
  cObj: YGaWowObject absolute pBlockPtr;
begin
  fFreeList.Capacity := fFreeList.Count + iNumObjects;
  for iIndex := 0 to iNumObjects -1 do
  begin
    { Basicly we initialize iNumObject instances of the specified class }
    { but we reserve SizeOf(YObjectHeader) bytes for internal use }
    pHeader^.Valid := ERR_OBJECT_INVALID_REF; { Unallocated object - invalid to reference it }
    pHeader^.Recycled := False; { No, it's not recycled :) }
    pHeader^.Factory := Self;
    Inc(pHeader);
    { We initialize the instance and add it to the fFreeList }
    fFreeList.Add(pBlockPtr);
    fClass.InitInstance(pBlockPtr);
    pBlockPtr := Pointer(Integer(pBlockPtr) + fSize);
  end;
end;

{ constructor Create }
constructor YGaFactory.Create(pFactoryClass: YWowObjectClass; iCapacity: Int32; const sName: string;
  cCoreObject: TObject; iGrowAmount: Int32 = -1);
var
  pDataBlock: Pointer;
begin
  inherited Create;
  fName := sName;
  fClass := pFactoryClass;
  fSize := fClass.InstanceSize;
  fCapacity := iCapacity;
  fCore := cCoreObject;

  if iGrowAmount > 0 then
  begin
    fGrowAmount := iGrowAmount;
  end else if iGrowAmount = -1 then
  begin
    fGrowAmount := iCapacity shr 2;
  end;

  fBlockList := TList.Create;
  fBlockList.Capacity := 10;
  { Allocate a huge memory block for the factory }
  GetMem(pDatablock, Capacity * (fSize + SizeOf(YObjectHeader)));
  fFreeList := TList.Create;
  fFreeList.Capacity := Capacity;
  AddObjects(pDataBlock, Capacity);
  fBlockList.Add(pDatablock);
end;

{ destructor Destroy }
destructor YGaFactory.Destroy;
var
  iIndex: Int32;
  pPtr: Pointer;
begin
  if fFreeList.Count <> Capacity then
  begin
    raise EFactoryException.CreateFmt(EObjectsInUse, [fName]);
  end else
  begin
    for iIndex := fBlockList.Count -1 downto 0 do
    begin
      { We just free all allocated blocks at once }
      pPtr := fBlockList[iIndex];
      FreeMem(pPtr);
    end;
    fBlockList.Free;
    fFreeList.Free;
    inherited Destroy;
  end;
end;

{ procedure GrowFactory }
procedure YGaFactory.GrowFactory(iExtraObjects: Int32);
var
  pDataPtr: Pointer;
begin
  { Allocate a new block, normally 25% extra }
  GetMem(pDataPtr, fSize * iExtraObjects);
  fBlockList.Add(pDataPtr);
  AddObjects(pDataPtr, iExtraObjects);
end;

{ function GetCount }
function YGaFactory.GetCount: Int32;
begin
  Result := fCapacity - fFreelist.Count;
end;

{ function GetFreeCount }
function YGaFactory.GetFreeCount: Int32;
begin
  Result := fFreeList.Count;
end;

{ function Assemble }
function YGaFactory.Assemble: YGaWowObject;
var
  pHeader: PObjectHeader;
begin
  if fFreeList.Count = 0 then GrowFactory(fGrowAmount);
  { We take a memory block from the fFreeList }
  Result := YGaWowObject(fFreeList[fFreeList.Count - 1]);
  fFreeList.Delete(fFreeList.Count - 1);
  pHeader := Pointer(Result);
  Dec(pHeader);
  { and initialize it so that it's ready to be used }
  pHeader^.Valid := ERR_OBJECT_OK;
  Result.Create;
end;

{ procedure Recycle }
procedure YGaFactory.Recycle(cFactoryObject: YGaWowObject);
var
  pHeader: PObjectHeader;
begin
  pHeader := Pointer(cFactoryObject);
  Dec(pHeader);
  if pHeader^.Valid = ERR_OBJECT_INVALID_REF then
  begin
    { Trying to free an already freed object }
    raise EInvalidPointer.CreateFmt(EInvalidOp, [fName]);
  end else
  begin
    pHeader^.Valid := ERR_OBJECT_INVALID_REF;
    if pHeader^.Recycled = False then
    begin
      { Direct recycling - we call the destructor }
      pHeader^.Recycled := True;
      cFactoryObject.Free;
    end;
    pHeader^.Recycled := False;
    { Put the object back into fFreeList }
    fFreeList.Add(cFactoryObject);
  end;
end;

end.
