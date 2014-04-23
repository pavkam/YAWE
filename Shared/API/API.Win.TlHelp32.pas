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

unit API.Win.TlHelp32;

interface

{$WEAKPACKAGEUNIT}

uses
  API.Win.Types,
  API.Win.NtCommon;

const
  MAX_MODULE_NAME32 = 255;

function CreateToolhelp32Snapshot(dwFlags, th32ProcessID: DWORD): THandle; stdcall;

//
// The th32ProcessID argument is only used if TH32CS_SNAPHEAPLIST or
// TH32CS_SNAPMODULE is specified. th32ProcessID == 0 means the current
// process.
//
// NOTE that all of the snapshots are global except for the heap and module
//  lists which are process specific. To enumerate the heap or module
//  state for all WIN32 processes call with TH32CS_SNAPALL and the
//  current process. Then for each process in the TH32CS_SNAPPROCESS
//  list that isn't the current process, do a call with just
//  TH32CS_SNAPHEAPLIST and/or TH32CS_SNAPMODULE.
//
// dwFlags
//
const
  TH32CS_SNAPHEAPLIST = $00000001;
  TH32CS_SNAPPROCESS  = $00000002;
  TH32CS_SNAPTHREAD   = $00000004;
  TH32CS_SNAPMODULE   = $00000008;
  TH32CS_SNAPALL      = TH32CS_SNAPHEAPLIST or TH32CS_SNAPPROCESS or
                        TH32CS_SNAPTHREAD or TH32CS_SNAPMODULE;
  TH32CS_INHERIT      = $80000000;
//
// Use CloseHandle to destroy the snapshot
//

(****** heap walking ***************************************************)

type
  _HEAPLIST32 = record
    dwSize: DWORD;
    th32ProcessID: DWORD;  // owning process
    th32HeapID: DWORD;     // heap (in owning process's context!)
    dwFlags: DWORD;
  end;
  HEAPLIST32 = _HEAPLIST32;
  PHEAPLIST32 = ^_HEAPLIST32;
  LPHEAPLIST32 = ^_HEAPLIST32;
  THeapList32 = _HEAPLIST32;
//
// dwFlags
//
const
  HF32_DEFAULT = 1;  // process's default heap
  HF32_SHARED  = 2;  // is shared heap

function Heap32ListFirst(hSnapshot: THandle; var lphl: THeapList32): BOOL; stdcall;
function Heap32ListNext(hSnapshot: THandle; var lphl: THeapList32): BOOL; stdcall;

type
  _HEAPENTRY32 = record
    dwSize: DWORD;
    hHandle: THandle;     // Handle of this heap block
    dwAddress: DWORD;     // Linear address of start of block
    dwBlockSize: DWORD;   // Size of block in bytes
    dwFlags: DWORD;
    dwLockCount: DWORD;
    dwResvd: DWORD;
    th32ProcessID: DWORD; // owning process
    th32HeapID: DWORD;    // heap block is in
  end;
  HEAPENTRY32 = _HEAPENTRY32;
  PHEAPENTRY32 = ^_HEAPENTRY32;
  LPHEAPENTRY32 = ^_HEAPENTRY32;
  THeapEntry32 = _HEAPENTRY32;
//
// dwFlags
//
const
  LF32_FIXED    = $00000001;
  LF32_FREE     = $00000002;
  LF32_MOVEABLE = $00000004;

function Heap32First(var lphe: THeapEntry32; th32ProcessID, th32HeapID: DWORD): BOOL;
function Heap32Next(var lphe: THeapEntry32): BOOL;
function Toolhelp32ReadProcessMemory(th32ProcessID: DWORD; lpBaseAddress: Pointer;
  lpBuffer: Pointer; cbRead: DWORD;  lpNumberOfBytesRead: PDWORD): BOOL;

(***** Process walking *************************************************)

type
  _PROCESSENTRY32W = packed record
    dwSize: DWORD;
    cntUsage: DWORD;
    th32ProcessID: DWORD;       // this process
    th32DefaultHeapID: DWORD;
    th32ModuleID: DWORD;        // associated exe
    cntThreads: DWORD;
    th32ParentProcessID: DWORD; // this process's parent process
    pcPriClassBase: Longint;    // Base priority of process's threads
    dwFlags: DWORD;
    szExeFile: array[0..MAX_PATH - 1] of WChar;// Path
  end;
  PROCESSENTRY32W = _PROCESSENTRY32W;
  PPROCESSENTRY32W = ^_PROCESSENTRY32W;
  LPPROCESSENTRY32W = ^_PROCESSENTRY32W;
  TProcessEntry32W = _PROCESSENTRY32W;

function Process32FirstW(hSnapshot: THandle; var lppe: TProcessEntry32W): BOOL; stdcall;
function Process32NextW(hSnapshot: THandle; var lppe: TProcessEntry32W): BOOL; stdcall;

type
  _PROCESSENTRY32 = packed record
    dwSize: DWORD;
    cntUsage: DWORD;
    th32ProcessID: DWORD;       // this process
    th32DefaultHeapID: DWORD;
    th32ModuleID: DWORD;        // associated exe
    cntThreads: DWORD;
    th32ParentProcessID: DWORD; // this process's parent process
    pcPriClassBase: Longint;    // Base priority of process's threads
    dwFlags: DWORD;
    szExeFile: array[0..MAX_PATH-1] of Char;// Path
  end;

  PROCESSENTRY32 = _PROCESSENTRY32;
  PPROCESSENTRY32 = ^_PROCESSENTRY32;
  LPPROCESSENTRY32 = ^_PROCESSENTRY32;
  TProcessEntry32 = _PROCESSENTRY32;

function Process32First(hSnapshot: THandle; var lppe: TProcessEntry32): BOOL; stdcall;
function Process32Next(hSnapshot: THandle; var lppe: TProcessEntry32): BOOL; stdcall;

(***** Thread walking **************************************************)

type
  _THREADENTRY32 = record
    dwSize: DWORD;
    cntUsage: DWORD;
    th32ThreadID: DWORD;       // this thread
    th32OwnerProcessID: DWORD; // Process this thread is associated with
    tpBasePri: Longint;
    tpDeltaPri: Longint;
    dwFlags: DWORD;
  end;
  THREADENTRY32 = _THREADENTRY32;
  PTHREADENTRY32 = ^_THREADENTRY32;
  LPTHREADENTRY32 = ^_THREADENTRY32;
  TThreadEntry32 = _THREADENTRY32;

function Thread32First(hSnapshot: THandle; var lpte: TThreadEntry32): BOOL; stdcall;
function Thread32Next(hSnapshot: THandle; var lpte: TThreadENtry32): BOOL; stdcall;

(***** Module walking *************************************************)

type
  _MODULEENTRY32 = record
    dwSize: DWORD;
    th32ModuleID: DWORD;  // This module
    th32ProcessID: DWORD; // owning process
    GlblcntUsage: DWORD;  // Global usage count on the module
    ProccntUsage: DWORD;  // Module usage count in th32ProcessID's context
    modBaseAddr: PBYTE;   // Base address of module in th32ProcessID's context
    modBaseSize: DWORD;   // Size in bytes of module starting at modBaseAddr
    hModule: HMODULE;     // The hModule of this module in th32ProcessID's context
    szModule: array[0..MAX_MODULE_NAME32] of Char;
    szExePath: array[0..MAX_PATH - 1] of Char;
  end;
  MODULEENTRY32 = _MODULEENTRY32;
  PMODULEENTRY32 = ^_MODULEENTRY32;
  LPMODULEENTRY32 = ^_MODULEENTRY32;
  TModuleEntry32 = _MODULEENTRY32;

//
// NOTE CAREFULLY that the modBaseAddr and hModule fields are valid ONLY
// in th32ProcessID's process context.
//

function Module32First(hSnapshot: THandle; var lpme: TModuleEntry32): BOOL; stdcall;
function Module32Next(hSnapshot: THandle; var lpme: TModuleEntry32): BOOL; stdcall;

type
  _MODULEENTRY32W = record
    dwSize: DWORD;
    th32ModuleID: DWORD;  // This module
    th32ProcessID: DWORD; // owning process
    GlblcntUsage: DWORD;  // Global usage count on the module
    ProccntUsage: DWORD;  // Module usage count in th32ProcessID's context
    modBaseAddr: PBYTE;   // Base address of module in th32ProcessID's context
    modBaseSize: DWORD;   // Size in bytes of module starting at modBaseAddr
    hModule: HMODULE;     // The hModule of this module in th32ProcessID's context
    szModule: array[0..MAX_MODULE_NAME32] of WChar;
    szExePath: array[0..MAX_PATH-1] of WChar;
  end;
  MODULEENTRY32W = _MODULEENTRY32W;
  PMODULEENTRY32W = ^_MODULEENTRY32W;
  LPMODULEENTRY32W = ^_MODULEENTRY32W;
  TModuleEntry32W = _MODULEENTRY32W;

//
// NOTE CAREFULLY that the modBaseAddr and hModule fields are valid ONLY
// in th32ProcessID's process context.
//

function Module32FirstW(hSnapshot: THandle; var lpme: TModuleEntry32W): BOOL; stdcall;
function Module32NextW(hSnapshot: THandle; var lpme: TModuleEntry32W): BOOL; stdcall;

implementation

function CreateToolhelp32Snapshot; external kernel32 name 'CreateToolhelp32Snapshot';
function Heap32ListFirst; external kernel32 name 'Heap32ListFirst';
function Heap32ListNext; external kernel32 name 'Heap32ListNext';
function Heap32First; external kernel32 name 'Heap32First';
function Heap32Next; external kernel32 name 'Heap32Next';
function Toolhelp32ReadProcessMemory; external kernel32 name 'Toolhelp32ReadProcessMemory';
function Process32First; external kernel32 name 'Process32First';
function Process32Next; external kernel32 name 'Process32Next';
function Process32FirstW; external kernel32 name 'Process32FirstW';
function Process32NextW; external kernel32 name 'Process32NextW';
function Thread32First; external kernel32 name 'Thread32First';
function Thread32Next; external kernel32 name 'Thread32Next';
function Module32First; external kernel32 name 'Module32First';
function Module32Next; external kernel32 name 'Module32Next';
function Module32FirstW; external kernel32 name 'Module32FirstW';
function Module32NextW; external kernel32 name 'Module32NextW';

end.


