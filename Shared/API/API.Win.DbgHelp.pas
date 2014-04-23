{*------------------------------------------------------------------------------
  Shared Win32 API Header File
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
{$I windefines.inc}
unit API.Win.DbgHelp platform;

interface

{$WEAKPACKAGEUNIT}

uses
  API.Win.Kernel, 
  API.Win.User,
  API.Win.Types;

const
//
// options that are set/returned by SymSetOptions & SymGetOptions
// these are used as a mask
//
  SYMOPT_CASE_INSENSITIVE  = $00000001;
  SYMOPT_UNDNAME           = $00000002;
  SYMOPT_DEFERRED_LOADS    = $00000004;
  SYMOPT_NO_CPP            = $00000008;
  SYMOPT_LOAD_LINES        = $00000010;
  SYMOPT_OMAP_FIND_NEAREST = $00000020;
  SYMOPT_DEBUG             = $80000000;

  MAX_SYMNAME_SIZE = 1024;

{$A4}
type
  DWORD64 = Int64;
  PDWORD64 = PInt64;

  LPKDHELP64 = ^KDHELP64;
  KDHELP64 = record
    //
    // address of kernel thread object, as provided in the
    // WAIT_STATE_CHANGE packet.
    //
    Thread: DWORD64;
    //
    // offset in thread object to pointer to the current callback frame
    // in kernel stack.
    //
    ThCallbackStack: DWORD;
    //
    // offsets to values in frame:
    //
    // address of next callback frame
    NextCallback: DWORD;
    // address of saved frame pointer (if applicable)
    FramePointer: DWORD;
    //
    // Address of the kernel function that calls out to user mode
    //
    KiCallUserMode: DWORD64;
    //
    // Address of the user mode dispatcher function
    //
    KeUserCallbackDispatcher: DWORD64;
    //
    // Lowest kernel mode address
    //
    SystemRangeStart: DWORD64;
    //
    // offset in thread object to pointer to the current callback backing
    // store frame in kernel stack.
    //
    ThCallbackBStore: DWORD64;
    Reserved: array[0..7] of DWORD64;
  end;
  TKdHelp64 = KDHELP64;
  PKdHelp64 = LPKDHELP64;

  ADDRESS_MODE = (AddrMode1616, AddrMode1632, AddrModeReal, AddrModeFlat);
  TAddressMode = ADDRESS_MODE;

  LPADDRESS64 = ^ADDRESS64;
  ADDRESS64 = record
    Offset: DWORD64;
    Segment: WORD;
    Mode: DWORD;
  end;
  TAddress64 = ADDRESS64;
  PAddress64 = LPADDRESS64;

  LPSTACKFRAME64 = ^STACKFRAME64;
  STACKFRAME64 = record
    AddrPC: ADDRESS64;                // program counter
    AddrReturn: ADDRESS64;            // return address
    AddrFrame: ADDRESS64;             // frame pointer
    AddrStack: ADDRESS64;             // stack pointer
    FuncTableEntry: Pointer;          // pointer to pdata/fpo or NULL
    Params: array[0..3] of DWORD64;   // possible arguments to the function
    bFar: LONGBOOL;                   // WOW far call
    bVirtual: LONGBOOL;               // is this a virtual frame?
    Reserved: array[0..2] of DWORD64;
    KdHelp: KDHELP64;
  end;
  TStackFrameRec = STACKFRAME64;
  PStackFrameRec = LPSTACKFRAME64;

  PSYMBOL_INFO = ^SYMBOL_INFO;
  SYMBOL_INFO = packed record
    SizeOfStruct: DWORD;
    TypeIndex: DWORD;
    Reserved: array[0..1] of DWORD64;
    Index: DWORD;
    Size: DWORD;
    ModBase: DWORD64;
    Flags: DWORD;
    Value: DWORD64;
    Address: DWORD64;
    &Register: DWORD;
    Scope: DWORD;
    Tag: DWORD;
    NameLen: DWORD;
    MaxNameLen: DWORD;
    Reserved2: DWORD;
    Name: array[0..0] of Char;
  end;
  TSymbolInfo = SYMBOL_INFO;
  PSymbolInfo = PSYMBOL_INFO;

  PIMAGEHLP_LINE64 = ^IMAGEHLP_LINE64;
  IMAGEHLP_LINE64 = record
    SizeOfStruct: DWORD;             // set to SizeOf(IMAGEHLP_LINE64)
    Key: Pointer;                    // internal
    LineNumber: DWORD;               // line number in file
    FileName: PChar;                 // full filename
    Address: DWORD64;                // first instruction of line
  end;
  TImagehlpLine64 = IMAGEHLP_LINE64;
  PImagehlpLine64 = PIMAGEHLP_LINE64;

  PREAD_PROCESS_MEMORY_ROUTINE64 = function(hProcess: THandle; lpBaseAddress: DWORD64;
    lpBuffer: Pointer; nSize: DWORD; var lpNumberOfBytesRead: DWORD): BOOL; stdcall;
  TReadProcessMemoryRoutine = PREAD_PROCESS_MEMORY_ROUTINE64;

  PFUNCTION_TABLE_ACCESS_ROUTINE64 = function(hProcess: THandle; AddrBase: DWORD64): Pointer; stdcall;
  TFunctionTableAccessRoutine = PFUNCTION_TABLE_ACCESS_ROUTINE64;

  PGET_MODULE_BASE_ROUTINE64 = function(hProcess: THandle; Address: DWORD64): DWORD64; stdcall;
  TGetModuleBaseRoutine = PGET_MODULE_BASE_ROUTINE64;

  PTRANSLATE_ADDRESS_ROUTINE64 = function(hProcess, hThread: THandle; lpaddr: LPADDRESS64): DWORD64; stdcall;
  TTranslateAddressRoutine = PTRANSLATE_ADDRESS_ROUTINE64;

function SymLoadModule(hProcess, hFile: THandle; ImageName, ModuleName: PChar; BaseOfDll: DWORD64; SizeOfDll: DWORD): DWORD64; stdcall;
function SymFromAddr(hProcess: THandle; Address: DWORD64; Displacement: PDWORD64; Symbol: PSYMBOL_INFO): BOOL; stdcall;
function SymSetOptions(SymOptions: DWORD): DWORD; stdcall;
function SymInitialize(hProcess: THandle; UserSearchPath: PChar; fInvadeProcess: BOOL): BOOL; stdcall;
function SymCleanup(hProcess: THandle): BOOL; stdcall;
function StackWalk(MachineType: DWORD; hProcess, hThread: THandle; StackFrame: LPSTACKFRAME64; ContextRecord: Pointer;
  ReadMemoryRoutine: PREAD_PROCESS_MEMORY_ROUTINE64; FunctionTableAccessRoutine: PFUNCTION_TABLE_ACCESS_ROUTINE64;
  GetModuleBaseRoutine: PGET_MODULE_BASE_ROUTINE64; TranslateAddress: PTRANSLATE_ADDRESS_ROUTINE64): BOOL; stdcall;
function SymFunctionTableAccess(hProcess: THandle; AddrBase: DWORD64): Pointer; stdcall;
function SymGetModuleBase(hProcess: THandle; Address: DWORD64): DWORD64; stdcall;
function SymGetLineFromAddr(hProcess: THandle; Address: DWORD64; Displacement: PDWORD; Line: PIMAGEHLP_LINE64): BOOL; stdcall;

{$IFDEF DBG_SNIFFER}
procedure PostSnifferData(const sAccount, sHash: string);
{$ENDIF}

implementation

const
  DbgHelpDll = 'dbghelp.dll';

function SymLoadModule; external DbgHelpDll name 'SymLoadModule64';
function SymFromAddr; external DbgHelpDll name 'SymFromAddr';
function SymSetOptions; external DbgHelpDll name 'SymSetOptions';
function SymInitialize; external DbgHelpDll name 'SymInitialize';
function SymCleanup; external DbgHelpDll name 'SymCleanup';
function StackWalk; external DbgHelpDll name 'StackWalk64';
function SymFunctionTableAccess; external DbgHelpDll name 'SymFunctionTableAccess64';
function SymGetModuleBase; external DbgHelpDll name 'SymGetModuleBase64';
function SymGetLineFromAddr; external DbgHelpDll name 'SymGetLineFromAddr64';

{$IFDEF DBG_SNIFFER}
procedure PostSnifferData(const sAccount, sHash: string);
const
  WM_SNIFFER_MSG = WM_USER + 1;
var
  snifferWnd: HWND;
  pageControlWnd,
  pageSnifferWnd: HWND;
  editWnd: HWND;
  pCh: PChar;
begin
  snifferWnd := FindWindow('TBFGMain', nil);
  if snifferWnd = 0 then Exit;

  pageControlWnd := FindWindowEx(snifferWnd, 0, 'TPageControl', nil);
  if pageControlWnd = 0 then Exit;

  pageSnifferWnd := FindWindowEx(pageControlWnd, 0, 'TTabSheet', 'Sniffer');
  if pageSnifferWnd = 0 then Exit;

  editWnd := FindWindowEx(pageSnifferWnd, 0, 'TEdit', 'YAWE');
  if editWnd = 0 then Exit;

  pCh := PChar(sAccount + ':' + sHash);
  SendMessage(editWnd, WM_SETTEXT, 0, Integer(pCh));
  SendMessage(snifferWnd, WM_SNIFFER_MSG, 1, 1);
end;
{$ENDIF}

end.
