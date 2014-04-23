{*------------------------------------------------------------------------------
  Run-time Optimization Support Module
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

unit Framework.OptimizationManager;

interface

uses
  Misc.Miscleanous,
  Misc.SystemInfo,
  Misc.Containers,
  Framework.Base;

type
  EOptimizerError = class(EFrameworkException);

  TOptimizationManager = class(TBaseObject)
    private
      fFunctionVariants: TPtrPtrHashMap;

      procedure Patch(Base, New: Pointer);
    public
      constructor Create; 
      destructor Destroy; override;

      procedure PatchFunctions;

      procedure AddFunctionVariant(BaseProc: Pointer; OptimalizedProc: Pointer;
        Requires: TCPUInstructionSupport; SelectEvenWhenLowerISS: Boolean = False);
  end;

implementation

uses
  Misc.Algorithm,
  Framework.Resources,
  MapHelp.LibInterface;

type
  PFunctionOptimizationEntry = ^TFunctionOptimizationEntry;
  TFunctionOptimizationEntry = record
    FuncAddr: Pointer;
    Requires: TCPUInstructionSupport;
    Always: Boolean;
  end;

  PFunctionOptimizationVariants = ^TFunctionOptimizationVariants;
  TFunctionOptimizationVariants = record
    OriginalFunc: Pointer;
    OptimizedVersions: array of PFunctionOptimizationEntry;
  end;

function DoRequirementsCollide(pSrc: PFunctionOptimizationVariants;
  iReq: TCPUInstructionSupport; bAlways: Boolean): Boolean;
var
  iI: Int32;
  pCurr: PFunctionOptimizationEntry;
begin
  for iI := 0 to High(pSrc^.OptimizedVersions) do
  begin
    pCurr := pSrc^.OptimizedVersions[iI];
    if (pCurr^.Requires = iReq) or (pCurr^.Always and bAlways) then
    begin
      Result := True;
      Exit;
    end; 
  end;
  Result := False;
end;

function CompareOptimizedFuncs(pFunc1, pFunc2: PFunctionOptimizationEntry): Integer;
begin
  if pFunc1^.Requires = pFunc2^.Requires then
  begin
    Result := 0;
  end else if pFunc1^.Requires > pFunc2^.Requires then
  begin
    if pFunc2^.Always = False then Result := 1 else Result := -1;
  end else
  begin
    if pFunc1^.Always = False then Result := -1 else Result := 1;
  end;
end;

function SelectFunctionByInstructionSet(const aFuncs: array of PFunctionOptimizationEntry): Pointer;
var
  iI: Int32;
begin
  for iI := High(aFuncs) downto 0 do
  begin
    if aFuncs[iI]^.Requires in CPUInfo.InstructionSupport then
    begin
      Result := aFuncs[iI]^.FuncAddr;
      Exit;
    end;
  end;
  Result := nil;
end;

{ YOptimizationManager }

constructor TOptimizationManager.Create;
begin
  inherited Create;
  fFunctionVariants := TPtrPtrHashMap.Create(64);
end;

destructor TOptimizationManager.Destroy;
var
  ifItr: IPtrIterator;
  iI: Int32;
  pData: PFunctionOptimizationVariants;
begin
  ifItr := fFunctionVariants.Values;
  while ifItr.HasNext do
  begin
    pData := ifItr.Next;
    for iI := 0 to High(pData^.OptimizedVersions) do
    begin
      Dispose(pData^.OptimizedVersions[iI]);
    end;
    Dispose(pData);
  end;

  fFunctionVariants.Free;
  inherited Destroy;
end;

procedure TOptimizationManager.AddFunctionVariant(BaseProc,
  OptimalizedProc: Pointer; Requires: TCPUInstructionSupport;
  SelectEvenWhenLowerISS: Boolean = False);
var
  pData: PFunctionOptimizationVariants;
  iI: Int32;
begin
  if (BaseProc = nil) or
     (OptimalizedProc = nil) or
     (BaseProc = OptimalizedProc) then
  begin
    raise EOptimizerError.CreateRes(@RsOptimizerInvalidArgs);
  end;
  
  pData := fFunctionVariants.GetValue(BaseProc);
  if pData = nil then
  begin
    New(pData);
    pData^.OriginalFunc := BaseProc;
    fFunctionVariants.PutValue(BaseProc, pData);
  end;

  if not DoRequirementsCollide(pData, Requires, SelectEvenWhenLowerISS) then
  begin
    iI := Length(pData^.OptimizedVersions);
    SetLength(pData^.OptimizedVersions, iI + 1);
    New(pData^.OptimizedVersions[iI]);
    pData^.OptimizedVersions[iI]^.FuncAddr := OptimalizedProc;
    pData^.OptimizedVersions[iI]^.Requires := Requires;
    pData^.OptimizedVersions[iI]^.Always := SelectEvenWhenLowerISS;
  end else raise EOptimizerError.CreateRes(@RsOptimizerCapabilitiesCollision);
end;

procedure TOptimizationManager.PatchFunctions;
var
  ifItr: IPtrIterator;
  pData: PFunctionOptimizationVariants;
begin
  ifItr := fFunctionVariants.Values;
  while ifItr.HasNext do
  begin
    pData := ifItr.Next;
    if Length(pData^.OptimizedVersions) <> 0 then
    begin
      SortArray(@pData^.OptimizedVersions[0], Length(pData^.OptimizedVersions),
        @CompareOptimizedFuncs);
      Patch(pData^.OriginalFunc, SelectFunctionByInstructionSet(pData^.OptimizedVersions));
    end;
  end;
end;

procedure TOptimizationManager.Patch(Base, New: Pointer);
begin
  DhkPatchProcedure(Base, New);
end;

end.
