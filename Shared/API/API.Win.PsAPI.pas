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
unit API.Win.PsAPI platform;

interface

{$WEAKPACKAGEUNIT}

uses
  API.Win.Types;

type
  LPMODULEINFO = ^MODULEINFO;
  MODULEINFO = packed record
    lpBaseOfDll: Pointer;
    SizeOfImage: DWORD;
    EntryPoint: Pointer;
  end;

  TModuleInfo = MODULEINFO;
  PModuleInfo = LPMODULEINFO;

  PPSAPI_WS_WATCH_INFORMATION = ^PSAPI_WS_WATCH_INFORMATION;
  PSAPI_WS_WATCH_INFORMATION = packed record
    FaultingPc: Pointer;
    FaultingVa: Pointer;
  end;

  TWsWatchInformation = PSAPI_WS_WATCH_INFORMATION;
  PWsWatchInformation = PPSAPI_WS_WATCH_INFORMATION;

  PPROCESS_MEMORY_COUNTERS = ^PROCESS_MEMORY_COUNTERS;
  PROCESS_MEMORY_COUNTERS = packed record
    cb: DWORD;
    PageFaultCount: DWORD;
    PeakWorkingSetSize: DWORD;
    WorkingSetSize: DWORD;
    QuotaPeakPagedPoolUsage: DWORD;
    QuotaPagedPoolUsage: DWORD;
    QuotaPeakNonPagedPoolUsage: DWORD;
    QuotaNonPagedPoolUsage: DWORD;
    PagefileUsage: DWORD;
    PeakPagefileUsage: DWORD;
  end;

  TProcessMemoryCounters = PROCESS_MEMORY_COUNTERS;
  PProcessMemoryCounters = PPROCESS_MEMORY_COUNTERS;

  PENUM_PAGE_FILE_INFORMATION = ^ENUM_PAGE_FILE_INFORMATION;
  ENUM_PAGE_FILE_INFORMATION = packed record
    cb: DWORD;
    Reserved: DWORD;
    TotalSize: Longword;
    TotalInUse: Longword;
    PeakUsage: Longword;
  end;

  TEnumPageFileInformation = ENUM_PAGE_FILE_INFORMATION;
  PEnumPageFileInformation = PENUM_PAGE_FILE_INFORMATION;

  ENUMPAGEFILESPROCA = procedure(pContext: Pointer; pPageFileInfo: PENUM_PAGE_FILE_INFORMATION;
    lpFilename: PChar); stdcall;

  ENUMPAGEFILESPROCW = procedure(pContext: Pointer; pPageFileInfo: PENUM_PAGE_FILE_INFORMATION;
    lpFilename: PWideChar); stdcall;

  {$IFDEF UNICODE}
  ENUMPAGEFILESPROC = ENUMPAGEFILESPROCW;
  {$ELSE}
  ENUMPAGEFILESPROC = ENUMPAGEFILESPROCA;
  {$ENDIF}

  TEnumPageFilesProc = ENUMPAGEFILESPROC;
  TEnumPageFilesProcA = ENUMPAGEFILESPROCA;
  TEnumPageFilesProcW = ENUMPAGEFILESPROCW;

  PPERFORMANCE_INFORMATION = ^PERFORMANCE_INFORMATION;
  PERFORMANCE_INFORMATION = packed record
    cb: DWORD;
    CommitTotal: Longword;
    CommitLimit: Longword;
    CommitPeak: Longword;
    PhysicalTotal: Longword;
    PhysicalAvailable: Longword;
    SystemCache: Longword;
    KernelTotal: Longword;
    KernelPaged: Longword;
    KernelNonPaged: Longword;
    PageSize: Longword;
    HandleCount: DWORD;
    ProcessCount: DWORD;
    ThreadCount: DWORD;
  end;

  TPerformanceInformation = PERFORMANCE_INFORMATION;
  PPerformanceInformation = PPERFORMANCE_INFORMATION;

function EnumProcesses(lpidProcess: PDWORD; cb: DWORD; cbNeeded: PDWORD): BOOL; stdcall;

function EnumProcessModules(hProcess: THandle; lphModule: PDWORD; cb: DWORD;
  lpcbNeeded: PDWORD): BOOL; stdcall;

function GetModuleBaseName(hProcess: THandle; hModule: HMODULE;
  lpBaseName: LPCTSTR; nSize: DWORD): DWORD; stdcall;

function GetModuleBaseNameA(hProcess: THandle; hModule: HMODULE;
  lpBaseName: LPCSTR; nSize: DWORD): DWORD; stdcall;

function GetModuleBaseNameW(hProcess: THandle; hModule: HMODULE;
  lpBaseName: LPWSTR; nSize: DWORD): DWORD; stdcall;

function GetModuleFileNameEx(hProcess: THandle; hModule: HMODULE;
  lpFilename: LPCTSTR; nSize: DWORD): DWORD; stdcall;

function GetModuleFileNameExA(hProcess: THandle; hModule: HMODULE;
  lpFilename: LPCSTR; nSize: DWORD): DWORD; stdcall;

function GetModuleFileNameExW(hProcess: THandle; hModule: HMODULE;
  lpFilename: LPWSTR; nSize: DWORD): DWORD; stdcall;

function GetModuleInformation(hProcess: THandle; hModule: HMODULE;
  lpmodinfo: LPMODULEINFO; cb: DWORD): BOOL; stdcall;

function EmptyWorkingSet(hProcess: THandle): BOOL; stdcall;

function QueryWorkingSet(hProcess: THandle; pv: Pointer; cb: DWORD): BOOL; stdcall;

function InitializeProcessForWsWatch(hProcess: THandle): BOOL; stdcall;

function GetMappedFileName(hProcess: THandle; lpv: Pointer;
  lpFilename: LPCTSTR; nSize: DWORD): DWORD; stdcall;

function GetMappedFileNameA(hProcess: THandle; lpv: Pointer;
  lpFilename: LPCSTR; nSize: DWORD): DWORD; stdcall;

function GetMappedFileNameW(hProcess: THandle; lpv: Pointer;
  lpFilename: LPWSTR; nSize: DWORD): DWORD; stdcall;

function GetDeviceDriverBaseName(ImageBase: Pointer; lpBaseName: LPCTSTR;
  nSize: DWORD): DWORD; stdcall;

function GetDeviceDriverBaseNameA(ImageBase: Pointer; lpBaseName: LPCSTR;
  nSize: DWORD): DWORD; stdcall;

function GetDeviceDriverBaseNameW(ImageBase: Pointer; lpBaseName: LPWSTR;
  nSize: DWORD): DWORD; stdcall;

function GetDeviceDriverFileName(ImageBase: Pointer; lpFileName: LPCTSTR;
  nSize: DWORD): DWORD; stdcall;

function GetDeviceDriverFileNameA(ImageBase: Pointer; lpFileName: LPCSTR;
  nSize: DWORD): DWORD; stdcall;

function GetDeviceDriverFileNameW(ImageBase: Pointer; lpFileName: LPWSTR;
  nSize: DWORD): DWORD; stdcall;

function EnumDeviceDrivers(lpImageBase: PPointer; cb: DWORD;
  lpcbNeeded: PDWORD): BOOL; stdcall;

function GetProcessMemoryInfo(Process: THandle; ppsmemCounters: PPROCESS_MEMORY_COUNTERS;
  cb: DWORD): BOOL; stdcall;

function EnumPageInfo(pCallbackRoutine: ENUMPAGEFILESPROC; pContext: Pointer): BOOL; stdcall;

function EnumPageInfoA(pCallbackRoutine: ENUMPAGEFILESPROCA; pContext: Pointer): BOOL; stdcall;

function EnumPageInfoW(pCallbackRoutine: ENUMPAGEFILESPROCW; pContext: Pointer): BOOL; stdcall;

function GetPerformanceInformation(pPerformanceInfo: PPERFORMANCE_INFORMATION;
  cb: DWORD): BOOL; stdcall;

implementation

function EnumProcesses; external psapi name 'EnumProcesses';
function EnumProcessModules; external psapi name 'EnumProcessModules';
function GetModuleBaseName; external psapi name 'GetModuleBaseName' + AWSuffix;
function GetModuleBaseNameA; external psapi name 'GetModuleBaseNameA';
function GetModuleBaseNameW; external psapi name 'GetModuleBaseNameW';
function GetModuleFileNameEx; external psapi name 'GetModuleBaseNameEx' + AWSuffix;
function GetModuleFileNameExA; external psapi name 'GetModuleBaseNameExA';
function GetModuleFileNameExW; external psapi name 'GetModuleBaseNameExW';
function GetModuleInformation; external psapi name 'GetModuleInformation';
function EmptyWorkingSet; external psapi name 'EmptyWorkingSet';
function QueryWorkingSet; external psapi name 'QueryWorkingSet';
function InitializeProcessForWsWatch; external psapi name 'InitializeProcessForWsWatch';
function GetMappedFileName; external psapi name 'GetMappedFileName' + AWSuffix;
function GetMappedFileNameA; external psapi name 'GetMappedFileNameA';
function GetMappedFileNameW; external psapi name 'GetMappedFileNameW';
function GetDeviceDriverBaseName; external psapi name 'GetDeviceDriverBaseName' + AWSuffix;
function GetDeviceDriverBaseNameA; external psapi name 'GetDeviceDriverBaseNameA';
function GetDeviceDriverBaseNameW; external psapi name 'GetDeviceDriverBaseNameW';
function GetDeviceDriverFileName; external psapi name 'GetDeviceDriverFileName' + AWSuffix;
function GetDeviceDriverFileNameA; external psapi name 'GetDeviceDriverFileNameA';
function GetDeviceDriverFileNameW; external psapi name 'GetDeviceDriverFileNameW';
function EnumDeviceDrivers; external psapi name 'EnumDeviceDrivers';
function GetProcessMemoryInfo; external psapi name 'GetProcessMemoryInfo';
function EnumPageInfo; external psapi name 'EnumPageInfo' + AWSuffix;
function EnumPageInfoA; external psapi name 'EnumPageInfoA';
function EnumPageInfoW; external psapi name 'EnumPageInfoW';
function GetPerformanceInformation; external psapi name 'GetPerformanceInformation';

end.
