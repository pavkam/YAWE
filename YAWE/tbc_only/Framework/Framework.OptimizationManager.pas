{*------------------------------------------------------------------------------
  Run-time Optimization Support Module
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

unit Framework.OptimizationManager;

interface

uses
  Bfg.Utils,
  Bfg.SystemInfo,
  Bfg.Containers,
  Bfg.Classes,
  Framework.Base;

type
  EOptimizerError = class(EFrameworkException);

  TOptimizationManager = class(TReferencedObject)
    private
      FFunctionVariants: TPtrPtrHashMap;
      FStubs: TMemoryPool;

      procedure Patch(Base, New: Pointer);
    public
      constructor Create;
      destructor Destroy; override;

      procedure PatchFunctions;

      procedure AddFunctionVariant(BaseProc: Pointer; OptimalizedProc: Pointer;
        Requires: TCPUInstructionSupport; SelectEvenWhenLowerISS: Boolean = False);

      function CreateCallbackStub(SelfPtr: Pointer; MethodPtr: Pointer): Pointer;
  end;

implementation

uses
  Api.Win.NtCommon,
  Bfg.Algorithm,
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

type
  PCallbackStub = ^TCallbackStub;
  TCallbackStub = packed record
    PopEDX: Byte;
    MovEAX: Byte;
    SelfPointer: Pointer;
    PushEAX: Byte;
    PushEDX: Byte;
    JmpShort: Byte;
    Displacement: Longword;
  end;

{ TOptimizationManager }

constructor TOptimizationManager.Create;
begin
  inherited Create;
  FFunctionVariants := TPtrPtrHashMap.Create(64);
  FStubs := TMemoryPool.Create(SizeOf(TCallbackStub), 2048, 2, 0.33, True, True,
    PAGE_EXECUTE_READWRITE);
end;

function TOptimizationManager.CreateCallbackStub(SelfPtr,
  MethodPtr: Pointer): Pointer; // Assumes both callback and target method are stdcall
const
  AsmPopEDX = $5A;
  AsmMovEAX = $B8;
  AsmPushEAX = $50;
  AsmPushEDX = $52;
  AsmJmpShort = $E9;
var
  Stub: PCallbackStub;
begin
  Stub := FStubs.Allocate;

  // Pop the return address off the stack
  Stub^.PopEDX := AsmPopEDX;

  // Push the object pointer on the stack
  Stub^.MovEAX := AsmMovEAX;
  Stub^.SelfPointer := SelfPtr;
  Stub^.PushEAX := AsmPushEAX;

  // Push the return address back on the stack
  Stub^.PushEDX := AsmPushEDX;

  // Jump to the target method
  Stub^.JmpShort := AsmJmpShort;
  Stub^.Displacement := (Longword(MethodPtr) - Longword(@(Stub^.JmpShort))) -
    (SizeOf(Stub^.JmpShort) + SizeOf(Stub^.Displacement));

  // Return a pointer to the stub
  Result := Stub;
end;

destructor TOptimizationManager.Destroy;
var
  Itr: IPtrIterator;
  I: Int32;
  Data: PFunctionOptimizationVariants;
begin
  Itr := fFunctionVariants.Values;
  while Itr.HasNext do
  begin
    Data := Itr.Next;
    for I := 0 to High(Data^.OptimizedVersions) do
    begin
      Dispose(Data^.OptimizedVersions[I]);
    end;
    Dispose(Data);
  end;

  FFunctionVariants.Free;
  FStubs.Free;
  inherited Destroy;
end;

procedure TOptimizationManager.AddFunctionVariant(BaseProc,
  OptimalizedProc: Pointer; Requires: TCPUInstructionSupport;
  SelectEvenWhenLowerISS: Boolean = False);
var
  Data: PFunctionOptimizationVariants;
  I: Int32;
begin
  if (BaseProc = nil) or
     (OptimalizedProc = nil) or
     (BaseProc = OptimalizedProc) then
  begin
    raise EOptimizerError.CreateRes(@RsOptimizerInvalidArgs);
  end;
  
  Data := fFunctionVariants.GetValue(BaseProc);
  if Data = nil then
  begin
    New(Data);
    Data^.OriginalFunc := BaseProc;
    fFunctionVariants.PutValue(BaseProc, Data);
  end;

  if not DoRequirementsCollide(Data, Requires, SelectEvenWhenLowerISS) then
  begin
    I := Length(Data^.OptimizedVersions);
    SetLength(Data^.OptimizedVersions, I + 1);
    New(Data^.OptimizedVersions[I]);
    Data^.OptimizedVersions[I]^.FuncAddr := OptimalizedProc;
    Data^.OptimizedVersions[I]^.Requires := Requires;
    Data^.OptimizedVersions[I]^.Always := SelectEvenWhenLowerISS;
  end else raise EOptimizerError.CreateRes(@RsOptimizerCapabilitiesCollision);
end;

procedure TOptimizationManager.PatchFunctions;
var
  Itr: IPtrIterator;
  Data: PFunctionOptimizationVariants;
begin
  Itr := fFunctionVariants.Values;
  while Itr.HasNext do
  begin
    Data := Itr.Next;
    if Length(Data^.OptimizedVersions) <> 0 then
    begin
      SortArray(@Data^.OptimizedVersions[0], Length(Data^.OptimizedVersions),
        @CompareOptimizedFuncs);
      Patch(Data^.OriginalFunc, SelectFunctionByInstructionSet(Data^.OptimizedVersions));
    end;
  end;
end;

procedure TOptimizationManager.Patch(Base, New: Pointer);
begin
  DhkPatchProcedure(Base, New);
end;

end.
