{*------------------------------------------------------------------------------
  Error Handler with Stack Tracing.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Framework.ErrorHandler;

interface

uses
  Misc.Containers,
  Framework.Base,
  API.Win.Kernel,
  API.Win.Types,
  API.Win.NTCommon,
  Classes,
  SysUtils,
  MapHelp.LibInterface;

type
  TExceptionWatcher = class;

  TExceptionFlag = (efDelphi, efSystem, efHandled, efUnhandled, efAnyHandler,
    efReraised);
  TExceptionFlags = set of TExceptionFlag;

  PRaisedExceptionInfo = ^TRaisedExceptionInfo;
  TRaisedExceptionInfo = record
    ErrorType: TRuntimeError;
    ExceptionCode: Longword;
    ExceptionAddress: Pointer;
    ExceptionObject: Exception;
    Flags: TExceptionFlags;
    Extra: array[0..1] of Longword;
    Internal: array[0..1] of Pointer;
  end;

  TExceptionEvent = procedure(Sender: TExceptionWatcher; const RaisedExc: TRaisedExceptionInfo) of object;

  PCallStackEntryInfo = ^TCallStackEntryInfo;
  TCallStackEntryInfo = record
    Module: string;
    Routine: string;
    Source: string;
    Addr: Pointer;
    LineNumber: Longword;
    Displacement: Longword;
  end;

  TCallStackEntry = Pointer;

  TCallStack = array of TCallStackEntry;

  TCallInfoFlags = set of (cifModule, cifSource, cifFunction);

  TExceptionWatcher = class(TBaseObject)
    private
      fActive: Boolean;
      fOnException: TExceptionEvent;

     { Dumps the call stack trace to the given address. Fills the list with the
       addresses where the called addresses can be found. }
      procedure GetStackTrace(ExceptionAddress: Longword; StackBottom: Longword;
        var Callstack: TCallStack);

      { Sets the watcher active/inactive. Inactive watcher won't report exceptions. }
      procedure SetActive(Value: Boolean);

      { Notifies about an ordinary Delphi or System exception. }
      procedure NotifyException(ExcRec: PExceptionRecord; ExcCtx: PContext;
        Flags: TExceptionFlags);

      { Fills an OS-independant structure with the information about the raised
        exception }
      procedure FillRaisedExceptionInfo(Info: PRaisedExceptionInfo; ExcRec: PExceptionRecord;
        ExcCtx: PContext; Flags: TExceptionFlags);

      procedure HookExceptionHandlers;
    public
      constructor Create;
      destructor Destroy; override;

      function GetFunctionInfo(var Displacement: Longword; Func: Pointer): string;
      function GetSourceInfo(var Line: Longword; Proc: Pointer): string;

      procedure GetCallStack(const RaisedExc: TRaisedExceptionInfo; var Callstack: TCallStack);
      procedure GetCurrentCallStack(var Callstack: TCallStack);
      procedure GetCallStackEntryInfo(Entry: TCallStackEntry; out Info: TCallStackEntryInfo;
        Flags: TCallInfoFlags);

      property Active: Boolean read fActive write SetActive;
      property OnCatchException: TExceptionEvent read fOnException write fOnException;
  end;

const
  cifAll = [cifModule, cifFunction, cifSource];

implementation

uses
  API.Win.DbgHelp,
  Misc.Miscleanous,
  Misc.Resources,
  Misc.Threads;

type
  PExcFrame = ^TExcFrame; 
  TExcFrame = record
    Next: PExcFrame;
    Description: Pointer;
    CurrentEBP: Pointer;
    case Integer of
      0: (ConstructedObject: Pointer);
      1: (SelfOfMethod: Pointer);
  end;

  PExtendedExcFrame = ^TExtendedExcFrame;
  TExtendedExcFrame = record
    Next: PExtendedExcFrame;
    Description: Pointer;
    SafePlace: Pointer;
    SafeEBP: Longword;
  end;

const
  cUnwinding          = 2;
  cUnwindingForExit   = 4;
  cUnwindInProgress   = cUnwinding or cUnwindingForExit;
  cDelphiException    = $0EEDFADE;
  cDelphiReRaise      = $0EEDFADF;
  
  UnkSym: string      = '<Unknown Symbol>';
  UnkModule: string   = '<Unknown Module>';
  UnkFile: string     = '<Unknown File>';

var
  RootWatcher: TExceptionWatcher;

procedure PatchMainExceptionHandler; forward;
procedure PatchHandleAnyExceptionHandler; forward;
procedure PatchOnExceptionHandler; forward;

type
  { The state of a memory page. Used by the raw stack tracing mechanism to
    determine whether an address is a valid call site or not. }
  {$Z4}
  TPageAccess = (paUnknown, paNotExecutable, paExecutable);
  {$Z1}

var
  { There are a total of 1M x 4K pages in the 4GB address space }
  { A problem may arise if we decide to compile under 64bit - 4GB is not the memory limit.
    In that case we'll solve it using a more dynamical approach. }
  MemoryPageAccessMap: array[0..1024 * 1024 - 1] of TPageAccess;

{ Updates the memory page }
procedure UpdateMemoryPageAccessMap(Address: Longword);
var
  tMemInfo: TMemoryBasicInformation;
  iAccess: TPageAccess;
  iStartPage: Integer;
  iPageCount: Integer;
  iIdx: Integer;
begin
  { Query the page }
  if VirtualQuery(Pointer(Address), @tMemInfo, SizeOf(tMemInfo)) <> 0 then
  begin
    { Get access type }
    if (tMemInfo.State = MEM_COMMIT)
      and (tMemInfo.Protect and (PAGE_EXECUTE_READ or PAGE_EXECUTE_READWRITE
        or PAGE_EXECUTE_WRITECOPY or PAGE_EXECUTE) <> 0)
      and ((tMemInfo.Protect and PAGE_GUARD) = 0) then
    begin
      iAccess := paExecutable;
    end else
    begin
      iAccess := paNotExecutable;
    end;
    { Update the map }
    iStartPage := Integer(Longword(tMemInfo.BaseAddress) div 4096);
    iPageCount := tMemInfo.RegionSize div 4096;
    if iStartPage + iPageCount < Length(MemoryPageAccessMap) then
    begin
      { Fill the whole range of pages }
      for iIdx := 0 to iPageCount -1 do
      begin
        AtomicExchange(@MemoryPageAccessMap[iStartPage+iIdx], Ord(iAccess));
      end;
    end;
  end else
  begin
    { Invalid address }
    AtomicExchange(@MemoryPageAccessMap[Address div 4096], Ord(paNotExecutable));
  end;
end;

{ Returns true if the return address is a valid call site. }
function IsValidCallSite(Address: Longword; var CallInstructionSize: Longword): Boolean;
var
  lwAddressLo: Longword;
  lwCode8Back: Longword;
  lwCode4Back: Longword;
  lwTemp: Longword;
begin
  if (Address and $FFFFD7FF) <> 0 then
  begin
    { The call address is up to 8 bytes before the return address }
    lwAddressLo := Address - 8;
    { Update the page map }
    lwTemp := lwAddressLo div 4096;
    if MemoryPageAccessMap[lwTemp] = paUnknown then
    begin
      UpdateMemoryPageAccessMap(lwAddressLo);
    end;
    { Check the page access }
    if (MemoryPageAccessMap[lwTemp] = paExecutable) and
       (MemoryPageAccessMap[Address div 4096] = paExecutable) then
    begin
      { Read the previous 8 bytes }
      try
        lwCode8Back := PLongword(lwAddressLo)^;
        lwCode4Back := PLongword(lwAddressLo + 4)^;
        { Is it a valid "call" instruction? }
        if (lwCode8Back and $FF000000) = $E8000000 then // 5-byte, CALL [-$1234567]
        begin
          CallInstructionSize := 5;
          Result := True;
        end else if (lwCode4Back and $38FF0000) = $10FF0000 then // 2 byte, CALL EAX
        begin
          CallInstructionSize := 2;
          Result := True;
        end else if (lwCode4Back and $0038FF00) = $0010FF00 then // 3 byte, CALL [EBP+0x8]
        begin
          CallInstructionSize := 3;
          Result := True;
        end else if (lwCode4Back and $000038FF) = $000010FF then // 4 byte, CALL ??
        begin
          CallInstructionSize := 4;
          Result := True;
        end else if (lwCode8Back and $38FF0000) = $10FF0000 then // 6-byte, CALL ??
        begin
          CallInstructionSize := 6;
          Result := True;
        end else if (lwCode8Back and $0038FF00) = $0010FF00 then // 7-byte, CALL [ESP-0x1234567]
        begin
          CallInstructionSize := 7;
          Result := True;
        end else Result := False;
      except
        on Exception do
        begin
          { The access has changed }
          UpdateMemoryPageAccessMap(lwAddressLo);
          { Not executable }
          Result := False;
        end;
      end;
    end else Result := False;
  end else Result := False;
end;

{ TExceptionWatcher }

constructor TExceptionWatcher.Create;
begin
  inherited Create;
  HookExceptionHandlers;
  Active := True;
end;

destructor TExceptionWatcher.Destroy;
begin
  Active := False;
  inherited Destroy;
end;

procedure TExceptionWatcher.GetStackTrace(ExceptionAddress: Longword;
  StackBottom: Longword; var Callstack: TCallStack);
var
  lwStackTop: Longword;
  lwStackData: Longword;
  lwPrevAddress: Longword;
  lwCallSize: Longword;
  iLen: Integer;
begin
  { Get the call stack top and current bottom }
  asm
    TEST   EDX, EDX
    JNZ    @@StackBottomDefined
    MOV    StackBottom, EBP
  @@StackBottomDefined:
    MOV    EDX, FS:[4]
    MOV    lwStackTop, EDX
  end;

  { The first entry is the exception address }
  SetLength(Callstack, 1);
  Callstack[0] := Pointer(ExceptionAddress);
  iLen := 1;

  lwPrevAddress := 0;
  
  { Fill the call stack }
  while StackBottom < lwStackTop do
  begin
    { Get the next frame }
    lwStackData := PLongword(StackBottom)^;
    { Does this appear to be a valid call address? }
    if (lwStackData and $FFFF0000) <> 0 then
    begin
      { Is this return address actually valid? }
      if (lwStackData <> lwPrevAddress) and IsValidCallSite(lwStackData, lwCallSize) then
      begin
        SetLength(Callstack, iLen + 1);
        Callstack[iLen] := Pointer(lwStackData - lwCallSize);
        lwPrevAddress := lwStackData;
        Inc(iLen);
      end;
    end;
    Inc(StackBottom, 4);
  end;
end;

procedure TExceptionWatcher.NotifyException(ExcRec: PExceptionRecord; ExcCtx: PContext;
  Flags: TExceptionFlags);
var
  tExcInfo: TRaisedExceptionInfo;
begin
  { No need to clear the local record, it will be filled by values nevertheless }
  FillRaisedExceptionInfo(@tExcInfo, ExcRec, ExcCtx, Flags);

  if Assigned(fOnException) then fOnException(Self, tExcInfo);
end;

procedure TExceptionWatcher.SetActive(Value: Boolean);
begin
  if fActive <> Value then
  begin
    case Value of
      False: RootWatcher := nil;
      True: RootWatcher := Self;
    end;
    fActive := Value;
  end;
end;

procedure TExceptionWatcher.FillRaisedExceptionInfo(Info: PRaisedExceptionInfo;
  ExcRec: PExceptionRecord; ExcCtx: PContext; Flags: TExceptionFlags);
  function MapExceptionCodeToRuntimeError: TRuntimeError;
  begin
    case ExcRec^.ExceptionCode of
      STATUS_INTEGER_DIVIDE_BY_ZERO:
        Result := System.reDivByZero;
      STATUS_ARRAY_BOUNDS_EXCEEDED:
        Result := System.reRangeError;
      STATUS_INTEGER_OVERFLOW:
        Result := System.reIntOverflow;
      STATUS_FLOAT_INEXACT_RESULT,
      STATUS_FLOAT_INVALID_OPERATION,
      STATUS_FLOAT_STACK_CHECK:
        Result := System.reInvalidOp;
      STATUS_FLOAT_DIVIDE_BY_ZERO:
        Result := System.reZeroDivide;
      STATUS_FLOAT_OVERFLOW:
        Result := System.reOverflow;
      STATUS_FLOAT_UNDERFLOW,
      STATUS_FLOAT_DENORMAL_OPERAND:
        Result := System.reUnderflow;
      STATUS_ACCESS_VIOLATION:
        Result := System.reAccessViolation;
      STATUS_PRIVILEGED_INSTRUCTION:
        Result := System.rePrivInstruction;
      STATUS_CONTROL_C_EXIT:
        Result := System.reControlBreak;
      STATUS_STACK_OVERFLOW:
        Result := System.reStackOverflow;
    else
      Result := System.reExternalException;
    end;
  end;
begin
  Info^.ExceptionAddress := ExcRec^.ExceptionAddress;
  Info^.ExceptionCode := ExcRec^.ExceptionCode;

  if ((ExcRec^.ExceptionCode = cDelphiException) or
     (ExcRec^.ExceptionCode = cDelphiReRaise)) and
     (ExcRec^.NumberParameters > 1) then
  begin
    Info^.ErrorType := reNone;
    Info^.ExceptionObject := Exception(ExcRec^.ExceptionInformation[1]);
    Info^.Extra[0] := 0;
    Info^.Extra[1] := 0;
  end else
  begin
    Info^.ErrorType := MapExceptionCodeToRuntimeError;
    Info^.ExceptionObject := nil;
    if Info^.ErrorType = reAccessViolation then
    begin
      Info^.Extra[0] := ExcRec^.ExceptionInformation[0];
      Info^.Extra[1] := ExcRec^.ExceptionInformation[1];
    end else
    begin
      Info^.Extra[0] := 0;
      Info^.Extra[1] := 0;
    end;
  end;

  Info^.Flags := Flags;
  Info^.Internal[0] := ExcRec;
  Info^.Internal[1] := ExcCtx;
end;

procedure TExceptionWatcher.HookExceptionHandlers;
begin
  PatchMainExceptionHandler;
  PatchHandleAnyExceptionHandler;
  PatchOnExceptionHandler;
end;

procedure TExceptionWatcher.GetCallStack(const RaisedExc: TRaisedExceptionInfo;
  var Callstack: TCallStack);
begin
  if RaisedExc.ErrorType <> reNone then
  begin
    GetStackTrace(Longword(RaisedExc.ExceptionAddress),
      PContext(RaisedExc.Internal[1])^.ESP, Callstack);
  end else
  begin
    GetStackTrace(Longword(RaisedExc.ExceptionAddress),
      PContext(RaisedExc.Internal[1])^.EBP, Callstack);
  end;
end;

procedure TExceptionWatcher.GetCallStackEntryInfo(Entry: TCallStackEntry;
  out Info: TCallStackEntryInfo; Flags: TCallInfoFlags);
begin
  Info.Addr := Entry;

  if cifModule in Flags then
  begin
    Info.Module := ExtractFileName(GetModuleName(FindHInstance(Entry)));
  end;
  if Info.Module = '' then Info.Module := UnkModule;

  if cifFunction in Flags then
  begin
    Info.Routine := GetFunctionInfo(Info.Displacement, Entry);
    Info.Addr := PChar(Info.Addr) - Info.Displacement;
    if Info.Routine = '' then Info.Routine := UnkSym;
  end;

  if cifSource in Flags then
  begin
    Info.Source := ExtractFileName(GetSourceInfo(Info.LineNumber, Entry));
    if Info.Source = '' then Info.Source := UnkFile;
  end;
end;

procedure TExceptionWatcher.GetCurrentCallStack(var Callstack: TCallStack);
var
  tCtx: TContext;
begin
  GetThreadContext(GetCurrentThread, @tCtx);
  GetStackTrace(Longword(@TExceptionWatcher.GetCurrentCallStack),
    tCtx.EBP, Callstack);
end;

function TExceptionWatcher.GetFunctionInfo(var Displacement: Longword; Func: Pointer): string;
var
  dwDisplacement: DWORD64;
  tMSymbol: TSymbolDebugInfo;
  pName: array[0..SizeOf(TSymbolInfo) + MAX_SYMNAME_SIZE] of Char;
  tSymbol: TSymbolInfo absolute pName;
begin
  FillChar(pName[0], SizeOf(pName), $FF);
  pName[SizeOf(pName)-1] := #0;
  tMSymbol.Name := @pName;
  tMSymbol.Length := MAX_SYMNAME_SIZE;
  
  if MapSymbolNameFromAddr(Func, @tMSymbol) = MAP_ERR_OK then
  begin
    Result := tMSymbol.Name;
    Displacement := tMSymbol.Displacement;
  end else
  begin
	  tSymbol.SizeOfStruct := SizeOf(TSymbolInfo) - 2;
	  tSymbol.MaxNameLen := MAX_SYMNAME_SIZE;
	  if not SymFromAddr(GetCurrentProcess, DWORD64(Func), @dwDisplacement, @tSymbol) then
    begin
      Result := '';
    end else
    begin
      Result := PChar(@tSymbol.Name);
      Displacement := dwDisplacement;
    end;
  end;
  if Result = '' then Result := UnkSym;
end;

function TExceptionWatcher.GetSourceInfo(var Line: Longword; Proc: Pointer): string;
var
  tMSymbol: TLineDebugInfo;
  pName: array[0..MAX_SYMNAME_SIZE-1] of Char;
  iSize: Integer;
begin
	if MapLineNumberFromAddr(Proc, @tMSymbol) = MAP_ERR_OK then
  begin
		Line := tMSymbol.Line;
	end else Line := 0;
  
  iSize := MAX_SYMNAME_SIZE;
  if MapSourceFileNameFromAddr(Proc, @pName, @iSize, nil) = MAP_ERR_OK then
  begin
    Result := pName;
  end else Result := UnkFile;
end;

procedure ExceptionWatcherCatchProc(Context: PContext; ExcRecord: PExceptionRecord;
  Flags: TExceptionFlags);
begin
  if (ExcRecord^.ExceptionFlags and cUnwindInProgress) = 0 then
  begin
    if RootWatcher <> nil then
    begin
      RootWatcher.NotifyException(ExcRecord, Context, Flags);
    end;
  end;
end;

{ Ok people, don't try to understand the code below. But for those, who have enough
  courage, I'll explain it a bit. Basicly on startup the internal Delphi routines
  are patched. The first 5 bytes are replaced by a JMP $XXXXXXXX instruction.
  So when an exception is thrown and the Delphi RTL calls its internal routines,
  they are redirected to our custom ones here. Before patching, the original code
  is saved so that after our own code gets called, the execution may safely
  continue and the exception gets processed normally. The code is a pure hack,
  so don't change it unless you absolutely know what you are doing. }

var
  CodeRedirectMainHandler: Pointer;
  CodeRedirectOnException: Pointer;
  CodeRedirectAnyException: Pointer;

procedure LongJump(jmpPtr: Pointer; popEBP: Boolean = True);
asm
  ADD  ESP, 4          // Ditch the return address
  TEST EDX, EDX
  JZ  @@DoNotPop
  POP EBP              // Restore EBP if needed
@@DoNotPop:
  JMP EAX              // Jump
end;

procedure DefaultHandler(excPtr: PExceptionRecord; errPtr: Pointer;
  ctxPtr: PContext; dspPtr: Pointer); stdcall;
{
  IN
    [EBP+8]   excPtr
    [EBP+12]  errPtr
    [EBP+16]  ctxPtr
    [EBP+20]  dispPtr
  OUT
    EAX       0/1
}
asm
  PUSH  ESI
  PUSH  EBX
  MOV   EBX, excPtr
  TEST  [EBX].TExceptionRecord.ExceptionFlags, 1
  JNZ   @@l5
  TEST  [EBX].TExceptionRecord.ExceptionFlags, cUnwindInProgress
  JZ    @@un23
  JMP   @@l5
@@un23:
  MOV   ESI, ctxPtr
  MOV   EBX, errPtr
  MOV   [ESI+$C4], EBX
  MOV   EAX, [EBX].TExtendedExcFrame.SafePlace
  MOV   [ESI].TContext.Eip, EAX
  MOV   EAX, [EBX].TExtendedExcFrame.SafeEBP
  MOV   [ESI+$B4], EAX
  XOR   EAX, EAX
  JMP   @@l6
@@l5:
  MOV   EAX, 1
@@l6:
  POP   EBX
  POP   ESI
end;

procedure ExceptionHandler(excPtr: PExceptionRecord; errPtr: Pointer;
  ctxPtr: PContext; dspPtr: Pointer; dwFlags: Longword); stdcall;
{
  IN
    [EBP+8]   excPtr
    [EBP+12]  errPtr
    [EBP+16]  ctxPtr
    [EBP+20]  dispPtr
    [EBP+24]  dwFlags
}
asm
  PUSH  OFFSET @@SafePtr
  PUSH  OFFSET DefaultHandler
  XOR   ECX, ECX
  MOV   EDX, dwFlags
  PUSH  FS:[ECX]
  MOV   FS:[ECX], ESP
  MOV   ECX, EDX
  TEST  EDX, 1 shl efUnhandled
  JNZ   @@Continue
  MOV   EDX, errPtr
  MOV   EDX, [EDX].TExcFrame.Next
  CMP   [EDX].TExcFrame.Next, -1
  JNE   @@Continue
  MOV   ECX, 1 shl efUnhandled
@@Continue:
  MOV   EDX, excPtr
  MOV   EAX, ctxPtr
  CMP   [EDX].TExceptionRecord.ExceptionCode, cDelphiException
  JNE   @@IsSystem
  OR    ECX, 1 shl efDelphi
  JMP   @@DoCall
@@IsSystem:
  OR    ECX, 1 shl efSystem
@@DoCall:
  CALL  ExceptionWatcherCatchProc
@@SafePtr:
  POP   EDX
  XOR   EAX, EAX
  ADD   ESP, 8
  MOV   FS:[EAX], EDX
end;

procedure UnhandledExceptionHandler(excPtr: PExceptionRecord; errPtr: Pointer;
  ctxPtr: PContext; dspPtr: Pointer); stdcall;
begin
  ExceptionHandler(excPtr, errPtr, ctxPtr, dspPtr, 1 shl Longword(efUnhandled));
  LongJump(CodeRedirectMainHandler);
end;

procedure HandleAnyException(excPtr: PExceptionRecord; errPtr: Pointer;
  ctxPtr: PContext; dspPtr: Pointer); stdcall;
begin
  ExceptionHandler(excPtr, errPtr, ctxPtr, dspPtr, 1 shl Longword(efAnyHandler));
  LongJump(CodeRedirectAnyException);
end;

procedure HandleOnException(excPtr: PExceptionRecord; errPtr: Pointer;
  ctxPtr: PContext; dspPtr: Pointer); stdcall;
begin
  ExceptionHandler(excPtr, errPtr, ctxPtr, dspPtr, 1 shl Longword(efHandled));
  LongJump(CodeRedirectOnException);
end;

procedure PatchMainExceptionHandler;
asm
  XOR    EAX, EAX
  MOV    EAX, FS:[EAX]
  MOV    EBX, EAX
@@Loop:
  CMP    [EAX].TExcFrame.Next, -1
  JE     @@LastHandler
  MOV    EBX, EAX
  MOV    EAX, [EAX].TExcFrame.Next
  JMP    @@Loop
@@LastHandler:
  MOV    EAX, [EBX].TExcFrame.Description
  CMP    BYTE PTR [EAX], $E9
  JNE    @@Exit
  MOV    EBX, [EAX+1]
  ADD    EAX, EBX
  ADD    EAX, 5
@@Exit:
  PUSH   OFFSET UnhandledExceptionHandler
  PUSH   EAX
  CALL   DhkHookProcedure
  ADD    ESP, 8
  MOV    [CodeRedirectMainHandler], EAX
end;

procedure PatchHandleAnyExceptionHandler;
asm
  PUSH   OFFSET HandleAnyException
  PUSH   OFFSET System.@HandleAnyException
  CALL   DhkHookProcedure
  ADD    ESP, 8
  MOV    [CodeRedirectAnyException], EAX
end;

procedure PatchOnExceptionHandler;
asm
  PUSH   OFFSET HandleOnException
  PUSH   OFFSET System.@HandleOnException
  CALL   DhkHookProcedure
  ADD    ESP, 8
  MOV    [CodeRedirectOnException], EAX
end;

function GetSymbolSearchPath: string;
const
  SYMBOL_PATH = '_NT_SYMBOL_PATH';
  ALTERNATE_SYMBOL_PATH = '_NT_ALT_SYMBOL_PATH';
var
  tMbi: TMemoryBasicInformation;
  sPath: string;
  pPath: PChar;
begin
  Result := '';
  if (GetEnvironmentVariable(SYMBOL_PATH) <> '') then
  begin
    Result := GetEnvironmentVariable(SYMBOL_PATH) + ';';
  end;

  if (GetEnvironmentVariable(ALTERNATE_SYMBOL_PATH) <> '') then
  begin
    Result := Result + GetEnvironmentVariable(ALTERNATE_SYMBOL_PATH) + ';';
  end;

  if (GetEnvironmentVariable('SystemRoot') <> '') then
  begin
    Result := Result + GetEnvironmentVariable('SystemRoot') + ';';
  end;

	VirtualQuery(@GetSymbolSearchPath, @tMbi, SizeOf(TMemoryBasicInformation));
  sPath := GetModuleName(HMODULE(tMbi.AllocationBase));
  pPath := @sPath[1];
	StrRScan(pPath, '\')^ := #0;
	Result := Result + pPath + ';';

  sPath := GetModuleName(0);
  pPath := @sPath[1];
	StrRScan(pPath, '\')^ := #0;
  Result := Result + pPath;
end;

initialization
  MapInit(nil, 0, MID_BDMF, MIS_MODULE);
	SymSetOptions(SYMOPT_UNDNAME or SYMOPT_LOAD_LINES or SYMOPT_DEFERRED_LOADS);
	SymInitialize(GetCurrentProcess, PChar(GetSymbolSearchPath), True);

finalization
  SymCleanup(GetCurrentProcess);
  MapCleanup;

end.
