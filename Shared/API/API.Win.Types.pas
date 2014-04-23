{*------------------------------------------------------------------------------
  Shared Win32 API Header File
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright JEDI Team
  @Author JEDI Team
  @Changes Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
{$I windefines.inc}
unit API.Win.Types platform;

interface

{$WEAKPACKAGEUNIT}

type
  PPChar = ^PChar;
  PPWideChar = ^PWideChar;
  PPointer = ^Pointer;

  GUID = TGUID;
  LPGUID = ^GUID;
  CLSID = TGUID;

// ntdef.h

const
  ntdll = 'ntdll.dll';
  kernel32 = 'kernel32.dll';
  gdi32 = 'gdi32.dll';
  user32 = 'user32.dll';
  advapi32 = 'advapi32.dll';
  opengl32 = 'opengl32.dll';
  msimg32 = 'msimg32.dll';
  winspool32 = 'winspool32.drv';
  psapi = 'psapi.dll';
  {$IFDEF UNICODE}
  AWSuffix = 'W';
  {$ELSE}
  AWSuffix = 'A';
  {$ENDIF UNICODE}

type

//typedef double DOUBLE;

  PQuad = ^TQuad;
  _QUAD = record                // QUAD is for those times we want
    DoNotUseThisField: Double;  // an 8 byte aligned 8 byte long structure
  end;                          // which is NOT really a floating point
  QUAD = _QUAD;
  TQuad = _QUAD;

//
// Unsigned Basics
//

  UCHAR = Char;
  USHORT = Word;
  ULONG = Longword;
  UQUAD = QUAD;

//
// __int64 is only supported by 2.0 and later midl.
// __midl is set by the 2.0 midl and not by 1.0 midl.
//

type
  LONGLONG = Int64;
  ULONGLONG = Int64;

const
  MAXLONGLONG = $7fffffffffffffff;

type
  PLONGLONG = ^LONGLONG;
  PULONGLONG = ^ULONGLONG;

  BOOL = LongBool;

  DWORD = Longword;

const
  ANYSIZE_ARRAY = 1;

  MAX_NATURAL_ALIGNMENT = SizeOf(ULONG);

//
// Void
//

type
  PVOID = Pointer;
  PPVOID = ^PVOID;
  PVOID64 = Pointer;

//
// Basics
//

  SHORT = Smallint;
  LONG = Longint;

//
// UNICODE (Wide Character) types
//

  WCHAR = WideChar;
  PWCHAR = PWideChar;

  LPWCH = PWCHAR;
  PWCH = PWCHAR;
  LPCWCH = PWCHAR;
  PCWCH = PWCHAR;
  NWPSTR = PWCHAR;
  LPWSTR = PWCHAR;
  LPCWSTR = PWCHAR;
  PWSTR = PWCHAR;
  LPUWSTR = PWCHAR;
  PUWSTR = PWCHAR;
  LCPUWSTR = PWCHAR;
  PCUWSTR = PWCHAR;

  LPLPSTR = ^LPSTR;
  LPLPCSTR = ^LPCSTR;
  LPLPCWSTR = ^LPCWSTR;
  LPLPWSTR = ^LPWSTR;

  PPSTR = LPLPSTR;
  PPCSTR = LPLPCSTR;
  PPCWSTR = LPLPCWSTR;
  PPWSTR = LPLPWSTR;

//
// ANSI (Multi-byte Character) types
//

  LPCH = PCHAR;
  PCH = PCHAR;

  LPCCH = PCHAR;
  PCCH = PCHAR;
  NPSTR = PCHAR;
  LPSTR = PCHAR;
  PSTR = PCHAR;
  LPCSTR = PCHAR;
  PCSTR = PCHAR;

//
// Neutral ANSI/UNICODE types and macros
//

{$IFDEF UNICODE}

  TCHAR = WCHAR;
  PTCHAR = ^TCHAR;
  TUCHAR = WCHAR;
  PTUCHAR = ^TUCHAR;

  LPTCH = LPWSTR;
  PTCH = LPWSTR;
  PTSTR = LPWSTR;
  LPTSTR = LPWSTR;
  PCTSTR = LPCWSTR;
  LPCTSTR = LPCWSTR;

  PCUTSTR = LPCWSTR;
  LPCUTSTR = LPCWSTR;
  PUTSTR = LPCWSTR;
  LPUTSTR = LPCWSTR;

  __TEXT = WideString;

{$ELSE}

  TCHAR = CHAR;
  PTCHAR = ^TCHAR;
  TUCHAR = CHAR;
  PTUCHAR = ^TUCHAR;

  LPTCH = LPSTR;
  PTCH = LPSTR;
  PTSTR = LPSTR;
  LPTSTR = LPSTR;
  PCTSTR = LPCSTR;
  LPCTSTR = LPCSTR;

  PCUTSTR = LPCSTR;
  LPCUTSTR = LPCSTR;
  PUTSTR = LPCSTR;
  LPUTSTR = LPCSTR;

  __TEXT = AnsiString;

{$ENDIF}

  TEXT = __TEXT;

//
// Pointer to Basics
//

  PSHORT = ^SHORT;
  PLONG = ^LONG;

//
// Pointer to Unsigned Basics
//

  PUCHAR = ^UCHAR;
  PUSHORT = ^USHORT;
  PULONG = ^ULONG;
  PUQUAD = ^UQUAD;

//
// Signed characters
//

  SCHAR = Shortint;
  PSCHAR = ^SCHAR;

//
// Handle to an Object
//

  HANDLE = Longword;
  PHANDLE = ^HANDLE;
  THandle = HANDLE;

//
// Flag (bit) fields
//

  FCHAR = UCHAR;
  FSHORT = USHORT;
  FLONG = ULONG;

// Component Object Model defines, and macros

  HRESULT = System.HRESULT; // LONG;

//
// Low order two bits of a handle are ignored by the system and available
// for use by application code as tag bits.  The remaining bits are opaque
// and used to store a serial number and table index.
//

const
  OBJ_HANDLE_TAGBITS = $00000003;

//
// Cardinal Data Types [0 - 2**N-2)
//

type
  CCHAR = Char;
  CSHORT = Shortint;
  CLONG = ULONG;

  PCCHAR = ^CCHAR;
  PCSHORT = ^CSHORT;
  PCLONG = ^CLONG;

//
// NLS basics (Locale and Language Ids)
//

  LCID = ULONG;
  PLCID = PULONG;
  LANGID = USHORT;
  PLANGID = ^LANGID; // TODO Not in original header (used in MSI)

//
// Logical Data Type - These are 32-bit logical values.
//

  LOGICAL = ULONG;
  PLOGICAL = ^ULONG;

//
// NTSTATUS
//

  NTSTATUS = LONG;
  PNTSTATUS = ^NTSTATUS;
  TNTStatus = NTSTATUS;

//
//  Status values are 32 bit values layed out as follows:
//
//   3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
//   1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
//  +---+-+-------------------------+-------------------------------+
//  |Sev|C|       Facility          |               Code            |
//  +---+-+-------------------------+-------------------------------+
//
//  where
//
//      Sev - is the severity code
//
//          00 - Success
//          01 - Informational
//          10 - Warning
//          11 - Error
//
//      C - is the Customer code flag
//
//      Facility - is the facility code
//
//      Code - is the facility's status code
//

//
// Generic test for success on any status value (non-negative numbers
// indicate success).
//

function NT_SUCCESS(Status: NTSTATUS): BOOL;

//
// Generic test for information on any status value.
//

function NT_INFORMATION(Status: NTSTATUS): BOOL;

//
// Generic test for warning on any status value.
//

function NT_WARNING(Status: NTSTATUS): BOOL;

//
// Generic test for error on any status value.
//

function NT_ERROR(Status: NTSTATUS): BOOL;

const
  APPLICATION_ERROR_MASK       = $20000000;
  ERROR_SEVERITY_SUCCESS       = $00000000;
  ERROR_SEVERITY_INFORMATIONAL = $40000000;
  ERROR_SEVERITY_WARNING       = DWORD($80000000);
  ERROR_SEVERITY_ERROR         = DWORD($C0000000);

//
// Large (64-bit) integer types and operations
//

type
  LPLARGE_INTEGER = ^LARGE_INTEGER;

  _LARGE_INTEGER = record
    case Integer of
    0: (
      LowPart: DWORD;
      HighPart: LONG);
    1: (
      QuadPart: LONGLONG);
  end;
  LARGE_INTEGER = Int64;
  //LARGE_INTEGER = _LARGE_INTEGER;
  TLargeInteger = LARGE_INTEGER;

  PLARGE_INTEGER = ^LARGE_INTEGER;
  PLargeInteger = LPLARGE_INTEGER;

  LPULARGE_INTEGER = ^ULARGE_INTEGER;

  ULARGE_INTEGER = record
    case Integer of
      0: (
        LowPart: DWORD;
        HighPart: DWORD);
      1: (
        QuadPart: LONGLONG);
  end;
  TULargeInteger = ULARGE_INTEGER;
  PULargeInteger = LPULARGE_INTEGER;

  PULARGE_INTEGER = ^ULARGE_INTEGER;

  TIME = LARGE_INTEGER;
  _TIME = _LARGE_INTEGER;
  PTIME = PLARGE_INTEGER;

//
// _M_IX86 included so that EM CONTEXT structure compiles with
// x86 programs. *** TBD should this be for all architectures?
//

//
// 16 byte aligned type for 128 bit floats
//

//
// For we define a 128 bit structure and use __declspec(align(16)) pragma to
// align to 128 bits.
//

type
  PFloat128 = ^TFloat128;
  _FLOAT128 = record
    LowPart: Int64;
    HighPart: Int64;
  end;
  FLOAT128 = _FLOAT128;
  TFloat128 = FLOAT128;

// Update Sequence Number

  USN = LONGLONG;

//
// Locally Unique Identifier
//

type
  PLuid = ^LUID;
  _LUID = record
    LowPart: DWORD;
    HighPart: LONG;
  end;
  LUID = _LUID;
  TLuid = LUID;

  DWORDLONG = ULONGLONG;
  PDWORDLONG = ^DWORDLONG;

//
// Physical address.
//

  PHYSICAL_ADDRESS = LARGE_INTEGER;
  PPHYSICAL_ADDRESS = ^LARGE_INTEGER;

//
// Define operations to logically shift an int64 by 0..31 bits and to multiply
// 32-bits by 32-bits to form a 64-bit product.
//

//
// The x86 C compiler understands inline assembler. Therefore, inline functions
// that employ inline assembler are used for shifts of 0..31.  The multiplies
// rely on the compiler recognizing the cast of the multiplicand to int64 to
// generate the optimal code inline.
//

function Int32x32To64(a, b: LONG): LONGLONG; inline;
function UInt32x32To64(a, b: DWORD): ULONGLONG; inline;

function Int64ShllMod32(Value: ULONGLONG; ShiftCount: DWORD): ULONGLONG;
function Int64ShraMod32(Value: LONGLONG; ShiftCount: DWORD): LONGLONG;
function Int64ShrlMod32(Value: ULONGLONG; ShiftCount: DWORD): ULONGLONG;

//
// Event type
//

type
  _EVENT_TYPE = (NotificationEvent, SynchronizationEvent);
  EVENT_TYPE = _EVENT_TYPE;
  TEventType = _EVENT_TYPE;

//
// Timer type
//

  _TIMER_TYPE = (NotificationTimer, SynchronizationTimer);
  TIMER_TYPE = _TIMER_TYPE;

//
// Wait type
//

  _WAIT_TYPE = (WaitAll, WaitAny);
  WAIT_TYPE = _WAIT_TYPE;

//
// Pointer to an Asciiz string
//

  PSZ = ^CHAR;
  PCSZ = ^CHAR;

//
// Counted String
//

  PString = ^TString;
  _STRING = record
    Length: USHORT;
    MaximumLength: USHORT;
    Buffer: PCHAR;
  end;
  TString = _STRING;

  ANSI_STRING = _STRING;
  PANSI_STRING = PSTRING;

  OEM_STRING = _STRING;
  POEM_STRING = PSTRING;

//
// CONSTCounted String
//

  PCString = ^CSTRING;
  _CSTRING = record
    Length: USHORT;
    MaximumLength: USHORT;
    Buffer: PCHAR;
  end;
  CSTRING = _CSTRING;
  TCString = CSTRING;

const
  ANSI_NULL = CHAR(0);
  UNICODE_NULL = WCHAR(0);
  UNICODE_STRING_MAX_BYTES = WORD(65534);
  UNICODE_STRING_MAX_CHARS = 32767;

type
  CANSI_STRING = _STRING;
  PCANSI_STRING = PSTRING;

//
// Unicode strings are counted 16-bit character strings. If they are
// NULL terminated, Length does not include trailing NULL.
//

type
  PUNICODE_STRING = ^UNICODE_STRING;
  _UNICODE_STRING = record
    Length: USHORT;
    MaximumLength: USHORT;
    Buffer: PWSTR;
  end;
  UNICODE_STRING = _UNICODE_STRING;
  PCUNICODE_STRING = ^UNICODE_STRING;
  TUnicodeString = UNICODE_STRING;
  PUnicodeString = PUNICODE_STRING;

//
// Boolean
//

type
//typedef UCHAR BOOLEAN;
  PBOOLEAN = ^ByteBool;

//
//  Doubly linked list structure.  Can be used as either a list head, or
//  as link words.
//

type
  PLIST_ENTRY = ^LIST_ENTRY;

  _LIST_ENTRY = record
    Flink: PLIST_ENTRY;
    Blink: PLIST_ENTRY;
  end;
  LIST_ENTRY = _LIST_ENTRY;
  TListEntry = LIST_ENTRY;
  PListEntry = PLIST_ENTRY;

  PRLIST_ENTRY = ^LIST_ENTRY;

//
//  Singly linked list structure. Can be used as either a list head, or
//  as link words.
//

  PSINGLE_LIST_ENTRY = ^SINGLE_LIST_ENTRY;
  _SINGLE_LIST_ENTRY = record
    Next: PSINGLE_LIST_ENTRY;
  end;
  SINGLE_LIST_ENTRY = _SINGLE_LIST_ENTRY;
  TSingleListEntry = SINGLE_LIST_ENTRY;
  PSingleListEntry = PSINGLE_LIST_ENTRY;

//
// These are needed for portable debugger support.
//

  PLIST_ENTRY32 = ^LIST_ENTRY32;
  LIST_ENTRY32 = record
    Flink: DWORD;
    Blink: DWORD;
  end;
  TListEntry32 = LIST_ENTRY32;
  PListEntry32 = PLIST_ENTRY32;

  PLIST_ENTRY64 = ^LIST_ENTRY64;
  LIST_ENTRY64 = record
    Flink: ULONGLONG;
    Blink: ULONGLONG;
  end;
  TListEntry64 = LIST_ENTRY64;
  PListEntry64 = PLIST_ENTRY64;

procedure ListEntry32To64(l32: PLIST_ENTRY32; l64: PLIST_ENTRY64);

procedure ListEntry64To32(l64: PLIST_ENTRY64; l32: PLIST_ENTRY32);

//
// These macros are used to walk lists on a target system
//

{
#define CONTAINING_RECORD32(address, type, field) ( \
                                                  (ULONG_PTR)(address) - \
                                                  (ULONG_PTR)(&((type *)0)->field))

#define CONTAINING_RECORD64(address, type, field) ( \
                                                  (ULONGLONG)(address) - \
                                                  (ULONGLONG)(&((type *)0)->field))
}

type
  PString32 = ^STRING32;
  _STRING32 = record
    Length: USHORT;
    MaximumLength: USHORT;
    Buffer: ULONG;
  end;
  STRING32 = _STRING32;
  TString32 = STRING32;

  UNICODE_STRING32 = STRING32;
  PUNICODE_STRING32 = ^UNICODE_STRING32;

  ANSI_STRING32 = STRING32;
  PANSI_STRING32 = ^ANSI_STRING32;

  PString64 = ^STRING64;
  _STRING64 = record
    Length: USHORT;
    MaximumLength: USHORT;
    Buffer: ULONGLONG;
  end;
  STRING64 = _STRING64;
  TString64 = STRING64;

  UNICODE_STRING64 = STRING64;
  PUNICODE_STRING64 = ^UNICODE_STRING64;

  ANSI_STRING64 = STRING64;
  PANSI_STRING64 = ^ANSI_STRING64;

//
// Valid values for the Attributes field
//

const
  OBJ_INHERIT          = $00000002;
  OBJ_PERMANENT        = $00000010;
  OBJ_EXCLUSIVE        = $00000020;
  OBJ_CASE_INSENSITIVE = $00000040;
  OBJ_OPENIF           = $00000080;
  OBJ_OPENLINK         = $00000100;
  OBJ_KERNEL_HANDLE    = $00000200;
  OBJ_VALID_ATTRIBUTES = $000003F2;

//
// Object Attributes structure
//

type
  POBJECT_ATTRIBUTES = ^OBJECT_ATTRIBUTES;
  _OBJECT_ATTRIBUTES = record
    Length: ULONG;
    RootDirectory: HANDLE;
    ObjectName: PUNICODE_STRING;
    Attributes: ULONG;
    SecurityDescriptor: PVOID;       // Points to type SECURITY_DESCRIPTOR
    SecurityQualityOfService: PVOID; // Points to type SECURITY_QUALITY_OF_SERVICE
  end;
  OBJECT_ATTRIBUTES = _OBJECT_ATTRIBUTES;
  TObjectAttributes = OBJECT_ATTRIBUTES;
  PObjectAttributes = POBJECT_ATTRIBUTES;

procedure InitializeObjectAttributes(p: POBJECT_ATTRIBUTES; n: PUNICODE_STRING;
  a: ULONG; r: HANDLE; s: PVOID{PSECURITY_DESCRIPTOR});

//
// Constants
//

const

//#define FALSE   0
//#define TRUE    1

  NULL   = 0;
  NULL64 = 0;

//#include <guiddef.h>

type
  PObjectId = ^OBJECTID;
  _OBJECTID = record  // size is 20
    Lineage: GUID;
    Uniquifier: ULONG;
  end;
  OBJECTID = _OBJECTID;
  TObjectId = OBJECTID;

const
  MINCHAR   = $80;
  MAXCHAR   = $7f;
  MINSHORT  = $8000;
  MAXSHORT  = $7fff;
  MINLONG   = DWORD($80000000);
  MAXLONG   = $7fffffff;
  MAXUCHAR  = $ff;
  MAXUSHORT = $ffff;
  MAXULONG  = DWORD($ffffffff);

//
// Useful Helper Macros
//

//
// Determine if an argument is present by testing the value of the pointer
// to the argument value.
//

function ARGUMENT_PRESENT(ArgumentPointer: Pointer): BOOL;

//
// Exception handler routine definition.
//

// struct _CONTEXT;
// struct _EXCEPTION_RECORD;

//type
//  PEXCEPTION_ROUTINE = function (ExceptionRecord: LP_EXCEPTION_RECORD;
//    EstablisherFrame: PVOID; ContextRecord: LPCONTEXT;
//    DispatcherContext: PVOID): EXCEPTION_DISPOSITION; stdcall;

//
// Interrupt Request Level (IRQL)
//

type
  KIRQL = UCHAR;
  PKIRQL = ^KIRQL;

//
// Product types
//

  _NT_PRODUCT_TYPE = (Filler0, NtProductWinNt, NtProductLanManNt, NtProductServer);
  NT_PRODUCT_TYPE = _NT_PRODUCT_TYPE;
  PNT_PRODUCT_TYPE = ^NT_PRODUCT_TYPE;
  TNtProductType = _NT_PRODUCT_TYPE;

//
// the bit mask, SharedUserData->SuiteMask, is a ULONG
// so there can be a maximum of 32 entries
// in this enum.
//

type
  _SUITE_TYPE = (
    SmallBusiness,
    Enterprise,
    BackOffice,
    CommunicationServer,
    TerminalServer,
    SmallBusinessRestricted,
    EmbeddedNT,
    DataCenter,
    SingleUserTS,
    MaxSuiteType);
  SUITE_TYPE = _SUITE_TYPE;
  TSuiteType = SUITE_TYPE;

const
  VER_SERVER_NT                      = DWORD($80000000);
  VER_WORKSTATION_NT                 = $40000000;
  VER_SUITE_SMALLBUSINESS            = $00000001;
  VER_SUITE_ENTERPRISE               = $00000002;
  VER_SUITE_BACKOFFICE               = $00000004;
  VER_SUITE_COMMUNICATIONS           = $00000008;
  VER_SUITE_TERMINAL                 = $00000010;
  VER_SUITE_SMALLBUSINESS_RESTRICTED = $00000020;
  VER_SUITE_EMBEDDEDNT               = $00000040;
  VER_SUITE_DATACENTER               = $00000080;
  VER_SUITE_SINGLEUSERTS             = $00000100;
  VER_SUITE_PERSONAL                 = $00000200;
  VER_SUITE_BLADE                    = $00000400;

// ntdef.h

type
  error_status_t = Longword;
  wchar_t = Word;

//
// The following types are guaranteed to be signed and 32 bits wide.
//

type
  INT_PTR = Integer;
  PINT_PTR = ^INT_PTR;
  UINT_PTR = Longword;
  PUINT_PTR = ^UINT_PTR;
  LONG_PTR = Longint;
  PLONG_PTR = ^LONG_PTR;
  ULONG_PTR = Longword;
  PULONG_PTR = ^ULONG_PTR;

  LONG32 = Integer;
  PLONG32 = ^LONG32;
  INT32 = Integer;
  PINT32 = ^INT32;

//
// The following types are guaranteed to be unsigned and 32 bits wide.
//

  ULONG32 = Longword;
  PULONG32 = ^ULONG32;
  DWORD32 = Longword;
  PDWORD32 = ^DWORD32;
  UINT32 = Longword;
  PUINT32 = ^UINT32;

const
  MAX_PATH = 260;

type

//unsigned char       BYTE;
//unsigned short      WORD;

  FLOAT = Single;
  PFLOAT = ^FLOAT;
  PBOOL = ^BOOL;
  LPBOOL = ^BOOL;
  PBYTE = ^BYTE;
  LPBYTE = ^BYTE;
  PINT = ^INT;
  PUINT = ^UINT;
  LPUINT = ^UINT;
  LPINT = ^INT;
  PWORD = ^WORD;
  LPWORD = ^WORD;
  LPLONG = ^LONG;
  PDWORD = ^DWORD;
  LPDWORD = ^DWORD;
  LPVOID = Pointer;
  LPCVOID = Pointer;
  LPLPVOID = ^LPVOID;

  INT = Integer;
  UINT = Longword;

// Types use for passing & returning polymorphic values

  WPARAM = UINT_PTR;
  LPARAM = LONG_PTR;
  LRESULT = LONG_PTR;

function MAKEWORD(a, b: BYTE): WORD; inline;
function MAKELONG(a, b: WORD): DWORD; inline;

function LOWORD(L: DWORD): WORD; inline;
function HIWORD(L: DWORD): WORD; inline;
function LOBYTE(W: WORD): BYTE; inline;
function HIBYTE(W: WORD): BYTE; inline;

type
  HWND = HANDLE;
  LPHWND = ^HWND;
  HHOOK = HANDLE;
  LPHHOOK = ^HHOOK;
  HEVENT = HANDLE;

  ATOM = WORD;

  SPHANDLE = ^HANDLE;
  LPHANDLE = ^HANDLE;
  HGLOBAL = HANDLE;
  HLOCAL = HANDLE;
  GLOBALHANDLE = HANDLE;
  //LOCALHANDLE = HANDLE; // todo clashes with WinBase.LocalHandle function
  FARPROC = Pointer;
  NEARPROC = Pointer;
  PROC = Pointer;
  TFarProc = FARPROC;
  TNearProc = NEARPROC;
  TProc = PROC;

  HGDIOBJ = HANDLE;

  HKEY = HANDLE;
  PHKEY = ^HKEY;

  HACCEL = HANDLE;

  HBITMAP = HANDLE;
  HBRUSH = HANDLE;

  HCOLORSPACE = HANDLE;

  HDC = HANDLE;
  HGLRC = HANDLE;
  HDESK = HANDLE;
  HENHMETAFILE = HANDLE;
  HFONT = HANDLE;
  HICON = HANDLE;
  HMENU = HANDLE;
  HMETAFILE = HANDLE;
  HINSTANCE = HANDLE;
  HMODULE = HINSTANCE;
  HPALETTE = HANDLE;
  HPEN = HANDLE;
  HRGN = HANDLE;
  HRSRC = HANDLE;
  HSTR = HANDLE;
  HTASK = HANDLE;
  HWINSTA = HANDLE;
  HKL = HANDLE;
  PHKL = ^HANDLE;

  HMONITOR = HANDLE;
  HWINEVENTHOOK = HANDLE;
  HUMPD = HANDLE;

  HFILE = Integer;
  HCURSOR = HICON;

  COLORREF = DWORD;
  LPCOLORREF = ^COLORREF;
  TColorRef = COLORREF;

  PHMODULE = ^HMODULE;

const
  HFILE_ERROR = HFILE(-1);

type
  LPRECT = ^RECT;
  tagRECT = record
    left: LONG;
    top: LONG;
    right: LONG;
    bottom: LONG;
  end;
  RECT = tagRECT;
  NPRECT = ^RECT;
  LPCRECT = ^RECT;
  TRect = RECT;
  PRect = LPRECT;

  LPRECTL = ^RECTL;
  _RECTL = record
    left: LONG;
    top: LONG;
    right: LONG;
    bottom: LONG;
  end;
  RECTL = _RECTL;
  LPCRECTL = ^_RECTL;
  TRectl = RECTL;
  PRectl = LPRECTL;

  LPPOINT = ^POINT;
  tagPOINT = record
    x: LONG;
    y: LONG;
  end;
  NPPOINT = ^tagPoint;
  POINT = tagPOINT;
  TPoint = POINT;
  PPoint = LPPOINT;

  PPointl = ^POINTL;
  _POINTL = record
    x: LONG;
    y: LONG;
  end;
  POINTL = _POINTL;
  TPointl = POINTL;

  LPSIZE = ^TSize;

  tagSIZE = record
    cx: LONG;
    cy: LONG;
  end;
  TSize = tagSIZE;
  PSize = LPSIZE;

  SIZE = TSize;
  SIZEL = TSize;
  PSIZEL = PSize;
  LPSIZEL = PSize;

  LPPOINTS = ^POINTS;
  tagPOINTS = record
    x: SHORT;
    y: SHORT;
  end;
  POINTS = tagPOINTS;
  TPoints = POINTS;
  PPoints = LPPOINTS;

//
//  File System time stamps are represented with the following structure:
//

  _FILETIME = record
    dwLowDateTime: DWORD;
    dwHighDateTime: DWORD;
  end;
  FILETIME = _FILETIME;
  PFILETIME = ^FILETIME;
  LPFILETIME = PFILETIME;
  TFileTime = FILETIME;

// mode selections for the device mode function

const
  DM_UPDATE = 1;
  DM_COPY   = 2;
  DM_PROMPT = 4;
  DM_MODIFY = 8;

  DM_IN_BUFFER   = DM_MODIFY;
  DM_IN_PROMPT   = DM_PROMPT;
  DM_OUT_BUFFER  = DM_COPY;
  DM_OUT_DEFAULT = DM_UPDATE;

// device capabilities indices

  DC_FIELDS           = 1;
  DC_PAPERS           = 2;
  DC_PAPERSIZE        = 3;
  DC_MINEXTENT        = 4;
  DC_MAXEXTENT        = 5;
  DC_BINS             = 6;
  DC_DUPLEX           = 7;
  DC_SIZE             = 8;
  DC_EXTRA            = 9;
  DC_VERSION          = 10;
  DC_DRIVER           = 11;
  DC_BINNAMES         = 12;
  DC_ENUMRESOLUTIONS  = 13;
  DC_FILEDEPENDENCIES = 14;
  DC_TRUETYPE         = 15;
  DC_PAPERNAMES       = 16;
  DC_ORIENTATION      = 17;
  DC_COPIES           = 18;

//
// HALF_PTR is half the size of a pointer it intended for use with
// within strcuture which contain a pointer and two small fields.
// UHALF_PTR is the unsigned variation.
//

const
  ADDRESS_TAG_BIT = DWORD($80000000);

type
  UHALF_PTR = Byte;
  PUHALF_PTR = ^UHALF_PTR;
  HALF_PTR = Shortint;
  PHALF_PTR = ^HALF_PTR;

  SHANDLE_PTR = Longint;
  HANDLE_PTR = Longint;

//
// SIZE_T used for counts or ranges which need to span the range of
// of a pointer.  SSIZE_T is the signed variation.
//

  SIZE_T = ULONG_PTR;
  PSIZE_T = ^SIZE_T;
  SSIZE_T = LONG_PTR;
  PSSIZE_T = ^SSIZE_T;

//
// Add Windows flavor DWORD_PTR types
//

  DWORD_PTR = ULONG_PTR;
  PDWORD_PTR = ^DWORD_PTR;

//
// The following types are guaranteed to be signed and 64 bits wide.
//

  LONG64 = Int64;
  PLONG64 = ^LONG64;

  PINT64 = ^Int64;

//
// The following types are guaranteed to be unsigned and 64 bits wide.
//

  ULONG64 = Int64;
  PULONG64 = ^ULONG64;
  DWORD64 = Int64;
  PDWORD64 = ^DWORD64;
  UINT64 = Int64;
  PUINT64 = ^UINT64;

const
  MAXUINT_PTR   = not UINT_PTR(0);
  MAXINT_PTR    = INT_PTR((MAXUINT_PTR shr 1));
  MININT_PTR    = not MAXINT_PTR;

  MAXULONG_PTR  = not ULONG_PTR(0);
  MAXLONG_PTR   = LONG_PTR(MAXULONG_PTR shr 1);
  MINLONG_PTR   = not MAXLONG_PTR;

  MAXUHALF_PTR  = UHALF_PTR( not 0);
  MAXHALF_PTR   = HALF_PTR(MAXUHALF_PTR shr 1);
  MINHALF_PTR   = not MAXHALF_PTR;

// basetsd

type
  INT8 = Shortint;
  PINT8 = ^INT8;
  INT16 = Smallint;
  PINT16 = ^INT16;
  UINT8 = Byte;
  PUINT8 = ^UINT8;
  UINT16 = Word;
  PUINT16 = ^UINT16;

//
// Thread affinity.
//

  KAFFINITY = ULONG_PTR;
  PKAFFINITY = ^KAFFINITY;

implementation

function Int32x32To64(a, b: LONG): LONGLONG;
begin
  Result := a * b;
end;

function UInt32x32To64(a, b: DWORD): ULONGLONG;
begin
  Result := a * b;
end;

function Int64ShllMod32(Value: ULONGLONG; ShiftCount: DWORD): ULONGLONG;
asm
        MOV     ECX, ShiftCount
        MOV     EAX, DWORD PTR [Value]
        MOV     EDX, DWORD PTR [Value + 4]
        SHLD    EDX, EAX, CL
        SHL     EAX, CL
end;

function Int64ShraMod32(Value: LONGLONG; ShiftCount: DWORD): LONGLONG;
asm
        MOV     ECX, ShiftCount
        MOV     EAX, DWORD PTR [Value]
        MOV     EDX, DWORD PTR [Value + 4]
        SHRD    EAX, EDX, CL
        SAR     EDX, CL
end;

function Int64ShrlMod32(Value: ULONGLONG; ShiftCount: DWORD): ULONGLONG;
asm
        MOV     ECX, ShiftCount
        MOV     EAX, DWORD PTR [Value]
        MOV     EDX, DWORD PTR [Value + 4]
        SHRD    EAX, EDX, CL
        SHR     EDX, CL
end;

procedure ListEntry32To64(l32: PLIST_ENTRY32; l64: PLIST_ENTRY64);
begin
  l64^.Flink := l32^.Flink;
  l64^.Blink := l32^.Blink;
end;

procedure ListEntry64To32(l64: PLIST_ENTRY64; l32: PLIST_ENTRY32);
begin
  l32^.Flink := ULONG(l64^.Flink);
  l32^.Blink := ULONG(l64^.Blink);
end;

function NT_SUCCESS(Status: NTSTATUS): BOOL;
begin
  Result := Status >= 0;
end;

function NT_INFORMATION(Status: NTSTATUS): BOOL;
begin
  Result := (ULONG(Status) shr 30) = 1;
end;

function NT_WARNING(Status: NTSTATUS): BOOL;
begin
  Result := (ULONG(Status) shr 30) = 2;
end;

function NT_ERROR(Status: NTSTATUS): BOOL;
begin
  Result := (ULONG(Status) shr 30) = 3;
end;

procedure InitializeObjectAttributes(p: POBJECT_ATTRIBUTES; n: PUNICODE_STRING;
  a: ULONG; r: HANDLE; s: PVOID{PSECURITY_DESCRIPTOR});
begin
  p^.Length := sizeof(OBJECT_ATTRIBUTES);
  p^.RootDirectory := r;
  p^.Attributes := a;
  p^.ObjectName := n;
  p^.SecurityDescriptor := s;
  p^.SecurityQualityOfService := nil;
end;

function ARGUMENT_PRESENT(ArgumentPointer: Pointer): BOOL;
begin
  Result := ArgumentPointer <> nil;
end;

function MAKEWORD(a, b: BYTE): WORD;
begin
  Result := (b shl 8) or a;
end;

function MAKELONG(a, b: WORD): DWORD;
begin
  Result := (b shl 16) or a;
end;

function LOWORD(L: DWORD): WORD;
begin
  Result := L and $0000FFFF;
end;

function HIWORD(L: DWORD): WORD;
begin
  Result := L shr 16;
end;

function LOBYTE(W: WORD): BYTE;
begin
  Result := W and $FF;
end;

function HIBYTE(W: WORD): BYTE;
begin
  Result := W shr 8;
end;

end.
