{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  MapHelp Interface
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

unit MapHelp.LibInterface;

interface

uses
  API.Win.Types,
  API.Win.NtCommon,
  API.Win.Kernel{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

const
  { Data types }
  MID_MAP                     = $00000000;
  MID_BDMF                    = $00000001;
  MID_ANY                     = $FFFFFFFF;

  { Source types }
  MIS_STRIPPED                = $00000000;
  MIS_MEMORY                  = $00000001;
  MIS_MODULE                  = $00000002;

  { Extra flags }
  MIF_PRELOAD_MAIN_MODULE     = $00000001;
  MIF_PRELOAD_NONE            = $00000002;
  MIF_PRELOAD_ALL             = $00000004;
  MIF_LOAD_DEFERRED           = $00000008;

  MIF_ALL                     = MIF_PRELOAD_MAIN_MODULE or MIF_PRELOAD_NONE or
                                MIF_PRELOAD_ALL or MIF_LOAD_DEFERRED;

  MAP_ERR_ALREADY_INITIALIZED = 1;
  MAP_ERR_OK                  = 0;
  MAP_ERR_GENERIC             = -1;
  MAP_ERR_SMALL_BUFFER        = -2;
  MAP_ERR_CANNOT_OPEN_FILE    = -3;
  MAP_ERR_NOT_INITIALIZED     = -4;
  MAP_ERR_INVALID_ARGS        = -5;
  MAP_ERR_SYMBOL_NOT_FOUND    = -6;
  MAP_ERR_FILE_CORRUPT        = -7;
  MAP_ERR_CANNOT_DECOMPRESS   = -8;
  MAP_ERR_NOT_IMPLEMENTED     = -9;

type
  PLineDebugInfo = ^TLineDebugInfo;
  TLineDebugInfo = packed record
    Address: Pointer;
    Displacement: Longword;
    ModuleBase: Pointer;
    Line: Longword;
  end;

  PSymbolDebugInfo = ^TSymbolDebugInfo;
  TSymbolDebugInfo = packed record
    Address: Pointer;
    Displacement: Longword;
    ModuleBase: Pointer;
    SymType: Longword;
    Name: PChar;
    Length: Integer;
  end;

  PLibraryVersionInfo = ^TLibraryVersionInfo;
  TLibraryVersionInfo = packed record
    Major: Byte;
    Minor: Byte;
    Revision: Byte;
    Build: Byte;
    VerString: PChar;
  end;

  PModuleInformation = ^TModuleInformation;
  TModuleInformation = packed record
    ModuleStart: Pointer;
    ModuleSize: Longword;
    ModuleBaseName: PChar;
    ModuleFullName: array[0..MAX_PATH] of Char;
  end;

  PExportedFunctionEntry = ^TExportedFunctionEntry;
  TExportedFunctionEntry = record
    Name: array[0..255] of Char;
    Index: Longword;
    AddressRva: Pointer;
  end;

  TEnumExportedFunctionsCallback = procedure(Name: PChar; Index: Longword; AddressRva: Pointer; UserContext: Pointer); cdecl;
  TEnumImportedFunctionsCallback = procedure(ModuleName: PChar; Name: PChar; Address: Pointer; UserContext: Pointer); cdecl;

  PDHK_STUBCREATE_INFO_CDECL = ^DHK_STUBCREATE_INFO_CDECL;
  DHK_STUBCREATE_INFO_CDECL = packed record
    ArgCount: Integer;
    VariableArgCount: Boolean;
    ExtraArgsAfterOriginal: Boolean;
  end;

function MapInit(Arg: PChar; Size: Integer; DataType: Longword; SourceType: Longword): Integer; cdecl;
function MapInitEx(Arg: PChar; Size: Integer; DataType: Longword; SourceType: Longword; Options: Longword): Integer; cdecl;
function MapAddSymbol(Address: Pointer; Name: PChar; SymType: Longword): Integer; cdecl;
function MapSourceFileNameFromAddr(Address: Pointer; SourceName: PChar; Size: PInteger; Module: PHMODULE): Integer; cdecl;
function MapSourceFileAddrRangeFromName(SourceName: PChar; Address: PPointer; Size: PInteger; Module: PHMODULE): Integer; cdecl;
function MapSymbolNameFromAddr(Address: Pointer; SymbolInfo: PSymbolDebugInfo): Integer; cdecl;
function MapLineNumberFromAddr(Address: Pointer; LineInfo: PLineDebugInfo): Integer; cdecl;
function MapCleanup: Integer; cdecl;
function MapGetLoadedModules(ModuleInfo: PModuleInformation; Count: Integer; Required: PInteger): Integer; cdecl;
function MapConvert(InFile, OutFile: PChar; InDataType, OutDataType, Flags: Longword): Integer; cdecl;

function MapGetVersionInfo(LibVerInfo: PLibraryVersionInfo): Integer; cdecl;
function MapFormatError(ErrorCode: Integer): PChar; cdecl;

function PeImgNtHeaders(BaseAddress: Pointer): PImageNtHeaders32; cdecl; overload;
function PeImgGetFirstSection(BaseAddress: Pointer): PImageSectionHeader; cdecl; overload;
function PeImgFindSection(BaseAddress: Pointer; SectionName: PChar): PImageSectionHeader; cdecl; overload;
function PeImgGetSectionData(BaseAddress: Pointer; SectionName: PChar; Size: PLongword): Pointer; cdecl; overload;
function PeImgIsSectionPresent(BaseAddress: Pointer; SectionName: PChar): Boolean; cdecl; overload;
function PeImgGetDirectoryEntryDataEx(BaseAddress: Pointer; DirIndex: Word; Size: PLongword; Data: PPointer): PImageSectionHeader; cdecl; overload;
function PeImgGetDirectoryEntryData(BaseAddress: Pointer; DirIndex: Word; Size: PLongword): Pointer; cdecl; overload;
function PeImgGetExportedFunctionsList(BaseAddress: Pointer; ExportedFunctionsList: Pointer; Count: Integer): Integer; cdecl; overload;
function PeImgGetImportedFunctionsList(BaseAddress: Pointer; ImportedFunctionsList: Pointer; Count: Integer; Modules: PPChar; ModuleCount: PInteger): Integer; cdecl; overload;
function PeImgEnumExportedFunctions(BaseAddress: Pointer; Callback: TEnumExportedFunctionsCallback; UserContext: Pointer): Integer; cdecl; overload;
function PeImgEnumImportedFunctions(BaseAddress: Pointer; Callback: TEnumImportedFunctionsCallback; UserContext: Pointer): Integer; cdecl; overload;

function PeImgNtHeaders(Module: HMODULE): PImageNtHeaders32; cdecl; overload;
function PeImgGetFirstSection(Module: HMODULE): PImageSectionHeader; cdecl; overload;
function PeImgFindSection(Module: HMODULE; SectionName: PChar): PImageSectionHeader; cdecl; overload;
function PeImgGetSectionData(Module: HMODULE; SectionName: PChar; Size: PLongword): Pointer; cdecl; overload;
function PeImgIsSectionPresent(Module: HMODULE; SectionName: PChar): Boolean; cdecl; overload;
function PeImgGetDirectoryEntryDataEx(Module: HMODULE; DirIndex: Word; Size: PLongword; Data: PPointer): PImageSectionHeader; cdecl; overload;
function PeImgGetDirectoryEntryData(Module: HMODULE; DirIndex: Word; Size: PLongword): Pointer; cdecl; overload;
function PeImgGetExportedFunctionsList(Module: HMODULE; ExportedFunctionsList: Pointer; Count: Integer): Integer; cdecl; overload;
function PeImgGetImportedFunctionsList(Module: HMODULE; ImportedFunctionsList: Pointer; Count: Integer; Modules: PPChar; ModuleCount: PInteger): Integer; cdecl; overload;
function PeImgEnumExportedFunctions(Module: HMODULE; Callback: TEnumExportedFunctionsCallback; UserContext: Pointer): Integer; cdecl; overload;
function PeImgEnumImportedFunctions(Module: HMODULE; Callback: TEnumImportedFunctionsCallback; UserContext: Pointer): Integer; cdecl; overload;

function DhkHookProcedure(ProcAddr, NewProc: Pointer): Pointer; cdecl;
function DhkUnhookProcedure(ProcAddr: Pointer): Boolean; cdecl;
function DhkHookDllProcedure(ImportModule, ExportModule, ProcName: PChar; NewProc: Pointer): Pointer; cdecl;
function DhkUnhookDllProcedure(ImportModule, ExportModule, ProcName: PChar): Pointer; cdecl;
function DhkPatchProcedure(ProcAddr, NewProc: Pointer): Boolean; cdecl;
function DhkCreateStub(ExtraArgs: PPointer; ExtraArgCount: Integer; CodePtr: Pointer; CallingConvention: Byte; Buffer: Pointer; Size: Integer; Extra: Pointer): Integer; cdecl;

implementation

const
  MapHlpDll = 'maphlp.dll';

function MapInit; external MapHlpDll name 'MapInit';
function MapInitEx; external MapHlpDll name 'MapInitEx';
function MapAddSymbol; external MapHlpDll name 'MapAddSymbol';
function MapSourceFileNameFromAddr; external MapHlpDll name 'MapSourceFileNameFromAddr';
function MapSourceFileAddrRangeFromName; external MapHlpDll name 'MapSourceFileAddrRangeFromName';
function MapSymbolNameFromAddr; external MapHlpDll name 'MapSymbolNameFromAddr';
function MapLineNumberFromAddr; external MapHlpDll name 'MapLineNumberFromAddr';
function MapCleanup; external MapHlpDll name 'MapCleanup';
function MapGetLoadedModules; external MapHlpDll name 'MapGetLoadedModules';
function MapConvert; external MapHlpDll name 'MapConvert';
function MapGetVersionInfo; external MapHlpDll name 'MapGetVersionInfo';
function MapFormatError; external MapHlpDll name 'MapFormatError';

function PeImgNtHeaders(BaseAddress: Pointer): PImageNtHeaders32; external MapHlpDll name 'PeImgNtHeaders';
function PeImgGetFirstSection(BaseAddress: Pointer): PImageSectionHeader; external MapHlpDll name 'PeImgGetFirstSection';
function PeImgFindSection(BaseAddress: Pointer; SectionName: PChar): PImageSectionHeader; external MapHlpDll name 'PeImgFindSection';
function PeImgGetSectionData(BaseAddress: Pointer; SectionName: PChar; Size: PLongword): Pointer; external MapHlpDll name 'PeImgGetSectionData';
function PeImgIsSectionPresent(BaseAddress: Pointer; SectionName: PChar): Boolean; external MapHlpDll name 'PeImgIsSectionPresent';
function PeImgGetDirectoryEntryDataEx(BaseAddress: Pointer; DirIndex: Word; Size: PLongword; Data: PPointer): PImageSectionHeader; external MapHlpDll name 'PeImgGetDirectoryEntryDataEx';
function PeImgGetDirectoryEntryData(BaseAddress: Pointer; DirIndex: Word; Size: PLongword): Pointer; external MapHlpDll name 'PeImgGetDirectoryEntryData';
function PeImgGetExportedFunctionsList(BaseAddress: Pointer; ExportedFunctionsList: Pointer; Count: Integer): Integer; external MapHlpDll name 'PeImgGetExportedFunctionsList';
function PeImgGetImportedFunctionsList(BaseAddress: Pointer; ImportedFunctionsList: Pointer; Count: Integer; Modules: PPChar; ModuleCount: PInteger): Integer; external MapHlpDll name 'PeImgGetImportedFunctionsList';
function PeImgEnumExportedFunctions(BaseAddress: Pointer; Callback: TEnumExportedFunctionsCallback; UserContext: Pointer): Integer; external MapHlpDll name 'PeImgEnumExportedFunctions';
function PeImgEnumImportedFunctions(BaseAddress: Pointer; Callback: TEnumImportedFunctionsCallback; UserContext: Pointer): Integer; external MapHlpDll name 'PeImgEnumImportedFunctions';

function PeImgNtHeaders(Module: HMODULE): PImageNtHeaders32; external MapHlpDll name 'PeImgNtHeaders';
function PeImgGetFirstSection(Module: HMODULE): PImageSectionHeader; external MapHlpDll name 'PeImgGetFirstSection';
function PeImgFindSection(Module: HMODULE; SectionName: PChar): PImageSectionHeader; external MapHlpDll name 'PeImgFindSection';
function PeImgGetSectionData(Module: HMODULE; SectionName: PChar; Size: PLongword): Pointer; external MapHlpDll name 'PeImgGetSectionData';
function PeImgIsSectionPresent(Module: HMODULE; SectionName: PChar): Boolean; external MapHlpDll name 'PeImgIsSectionPresent';
function PeImgGetDirectoryEntryDataEx(Module: HMODULE; DirIndex: Word; Size: PLongword; Data: PPointer): PImageSectionHeader; external MapHlpDll name 'PeImgGetDirectoryEntryDataEx';
function PeImgGetDirectoryEntryData(Module: HMODULE; DirIndex: Word; Size: PLongword): Pointer; external MapHlpDll name 'PeImgGetDirectoryEntryData';
function PeImgGetExportedFunctionsList(Module: HMODULE; ExportedFunctionsList: Pointer; Count: Integer): Integer; external MapHlpDll name 'PeImgGetExportedFunctionsList';
function PeImgGetImportedFunctionsList(Module: HMODULE; ImportedFunctionsList: Pointer; Count: Integer; Modules: PPChar; ModuleCount: PInteger): Integer; external MapHlpDll name 'PeImgGetImportedFunctionsList';
function PeImgEnumExportedFunctions(Module: HMODULE; Callback: TEnumExportedFunctionsCallback; UserContext: Pointer): Integer; external MapHlpDll name 'PeImgEnumExportedFunctions';
function PeImgEnumImportedFunctions(Module: HMODULE; Callback: TEnumImportedFunctionsCallback; UserContext: Pointer): Integer; external MapHlpDll name 'PeImgEnumImportedFunctions';

function DhkHookProcedure; external MapHlpDll name 'DhkHookProcedure';
function DhkUnhookProcedure; external MapHlpDll name 'DhkUnhookProcedure';
function DhkHookDllProcedure; external MapHlpDll name 'DhkHookDllProcedure';
function DhkUnhookDllProcedure; external MapHlpDll name 'DhkUnhookDllProcedure';
function DhkPatchProcedure; external MapHlpDll name 'DhkPatchProcedure';
function DhkCreateStub; external MapHlpDll name 'DhkCreateStub';

end.
