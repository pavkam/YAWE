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
{$DEFINE GENERIC_PTRS}
unit API.Win.User;

interface

{$WEAKPACKAGEUNIT}

uses
  API.Win.Kernel,
  API.Win.GDI,
  API.Win.NtCommon,
  API.Win.Types;

const
  UINT_MAX = UINT($FFFFFFFF); // from limits.h TODO

type
  HDWP = HANDLE;

  MENUTEMPLATEA = Pointer;
  MENUTEMPLATEW = Pointer;

{$IFDEF UNICODE}
  MENUTEMPLATE = MENUTEMPLATEW;
{$ELSE}
  MENUTEMPLATE = MENUTEMPLATEA;
{$ENDIF}

  LPMENUTEMPLATEA = PVOID;
  LPMENUTEMPLATEW = PVOID;
{$IFDEF UNICODE}
  LPMENUTEMPLATE = LPMENUTEMPLATEW;
{$ELSE}
  LPMENUTEMPLATE = LPMENUTEMPLATEA;
{$ENDIF}

{$IFDEF GENERIC_PTRS}
  WNDPROC = Pointer;

  DLGPROC = Pointer;
  TIMERPROC = Pointer;
  GRAYSTRINGPROC = Pointer;
  WNDENUMPROC = Pointer;
  HOOKPROC = Pointer;
  SENDASYNCPROC = Pointer;

  PROPENUMPROCA = Pointer;
  PROPENUMPROCW = Pointer;

  PROPENUMPROCEXA = Pointer;
  PROPENUMPROCEXW = Pointer;

  EDITWORDBREAKPROCA = Pointer;
  EDITWORDBREAKPROCW = Pointer;

  DRAWSTATEPROC = Pointer;
{$ELSE}
  WNDPROC = function(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

  DLGPROC = function(hwndDlg: HWND; wMsg: UINT; wParam: WPARAM; lParam: LPARAM): INT_PTR; stdcall;
  TIMERPROC = procedure (hwnd: HWND; uMsg: UINT; idEvent: UINT_PTR; dwTime: DWORD); stdcall;
  GRAYSTRINGPROC = function (hdc: HDC; lpData: LPARAM; cchData: Integer): BOOL; stdcall;
  WNDENUMPROC = function (hwnd: HWND; lParam: LPARAM): BOOL; stdcall;
  HOOKPROC = function (nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
  SENDASYNCPROC = procedure (hwnd: HWND; uMsg: UINT; dwData: ULONG_PTR; lResult: LRESULT); stdcall;

  PROPENUMPROCA = function (hwnd: HWND; lpszString: LPCSTR; hData: HANDLE): BOOL; stdcall;
  PROPENUMPROCW = function (hwnd: HWND; lpszString: LPCWSTR; hData: HANDLE): BOOL; stdcall;

  PROPENUMPROCEXA = function (hwnd: HWND; lpszString: LPSTR; hData: HANDLE; dwData: ULONG_PTR): BOOL; stdcall;
  PROPENUMPROCEXW = function (hwnd: HWND; lpszString: LPWSTR; hData: HANDLE; dwData: ULONG_PTR): BOOL; stdcall;

  EDITWORDBREAKPROCA = function (lpch: LPSTR; ichCurrent: Integer; cch, code: Integer): Integer; stdcall;
  EDITWORDBREAKPROCW = function (lpch: LPWSTR; ichCurrent: Integer; cch, code: Integer): Integer; stdcall;

  DRAWSTATEPROC = function (hdc: HDC; lData: LPARAM; wData: WPARAM; cx, cy: Integer): BOOL; stdcall;
{$ENDIF}

{$IFDEF UNICODE}

  PROPENUMPROC = PROPENUMPROCW;
  PROPENUMPROCEX = PROPENUMPROCEXW;
  EDITWORDBREAKPROC = EDITWORDBREAKPROCW;

{$ELSE}

  PROPENUMPROC = PROPENUMPROCA;
  PROPENUMPROCEX = PROPENUMPROCEXA;
  EDITWORDBREAKPROC = EDITWORDBREAKPROCA;

{$ENDIF}

  NAMEENUMPROCA = function (lpstr: LPSTR; lParam: LPARAM): BOOL; stdcall;
  NAMEENUMPROCW = function (lpstr: LPWSTR; lParam: LPARAM): BOOL; stdcall;

  WINSTAENUMPROCA = NAMEENUMPROCA;
  DESKTOPENUMPROCA = NAMEENUMPROCA;
  WINSTAENUMPROCW = NAMEENUMPROCW;
  DESKTOPENUMPROCW = NAMEENUMPROCW;

{$IFDEF UNICODE}

  WINSTAENUMPROC = WINSTAENUMPROCW;
  DESKTOPENUMPROC = DESKTOPENUMPROCW;

{$ELSE}

  WINSTAENUMPROC = WINSTAENUMPROCA;
  DESKTOPENUMPROC = DESKTOPENUMPROCA;

{$ENDIF}

function IS_INTRESOURCE(wInteger: WORD): BOOL;

type
  MAKEINTRESOURCEA = LPSTR;
  MAKEINTRESOURCEW = LPWSTR;
{$IFDEF UNICODE}
  MAKEINTRESOURCE = MAKEINTRESOURCEW;
{$ELSE}
  MAKEINTRESOURCE = MAKEINTRESOURCEA;
{$ENDIF}

//
// Predefined Resource Types
//

const
  RT_CURSOR       = MAKEINTRESOURCE(1);
  RT_BITMAP       = MAKEINTRESOURCE(2);
  RT_ICON         = MAKEINTRESOURCE(3);
  RT_MENU         = MAKEINTRESOURCE(4);
  RT_DIALOG       = MAKEINTRESOURCE(5);
  RT_STRING       = MAKEINTRESOURCE(6);
  RT_FONTDIR      = MAKEINTRESOURCE(7);
  RT_FONT         = MAKEINTRESOURCE(8);
  RT_ACCELERATOR  = MAKEINTRESOURCE(9);
  RT_RCDATA       = MAKEINTRESOURCE(10);
  RT_MESSAGETABLE = MAKEINTRESOURCE(11);

  DIFFERENCE = 11;

  RT_GROUP_CURSOR = MAKEINTRESOURCE(ULONG_PTR(RT_CURSOR) + DIFFERENCE);
  RT_GROUP_ICON = MAKEINTRESOURCE(ULONG_PTR(RT_ICON) + DIFFERENCE);
  RT_VERSION    = MAKEINTRESOURCE(16);
  RT_DLGINCLUDE = MAKEINTRESOURCE(17);
  RT_PLUGPLAY   = MAKEINTRESOURCE(19);
  RT_VXD        = MAKEINTRESOURCE(20);
  RT_ANICURSOR  = MAKEINTRESOURCE(21);
  RT_ANIICON    = MAKEINTRESOURCE(22);
  RT_HTML       = MAKEINTRESOURCE(23);
  RT_MANIFEST   = MAKEINTRESOURCE(24);
  CREATEPROCESS_MANIFEST_RESOURCE_ID = MAKEINTRESOURCE(1);
  ISOLATIONAWARE_MANIFEST_RESOURCE_ID = MAKEINTRESOURCE(2);
  ISOLATIONAWARE_NOSTATICIMPORT_MANIFEST_RESOURCE_ID = MAKEINTRESOURCE(3);
  MINIMUM_RESERVED_MANIFEST_RESOURCE_ID = MAKEINTRESOURCE(1{inclusive});
  MAXIMUM_RESERVED_MANIFEST_RESOURCE_ID = MAKEINTRESOURCE(16{inclusive});

type
  va_list = PChar;

function wvsprintfA(Output: LPSTR; Format: LPCSTR; arglist: va_list): Integer; stdcall;
function wvsprintfW(Output: LPWSTR; Format: LPCWSTR; arglist: va_list): Integer; stdcall;

{$IFDEF UNICODE}
function wvsprintf(Output: LPWSTR; Format: LPCWSTR; arglist: va_list): Integer; stdcall;
{$ELSE}
function wvsprintf(Output: LPSTR; Format: LPCSTR; arglist: va_list): Integer; stdcall;
{$ENDIF}

function wsprintfA(Output: LPSTR; Format: LPCSTR): Integer; stdcall;
function wsprintfW(Output: LPWSTR; Format: LPCWSTR): Integer; stdcall;

{$IFDEF UNICODE}
function wsprintf(Output: LPWSTR; Format: LPCWSTR): Integer; stdcall;
{$ELSE}
function wsprintf(Output: LPSTR; Format: LPCSTR): Integer; stdcall;
{$ENDIF}

//
// SPI_SETDESKWALLPAPER defined constants
//

const
  SETWALLPAPER_DEFAULT = LPWSTR(-1);

//
// Scroll Bar Constants
//

  SB_HORZ = 0;
  SB_VERT = 1;
  SB_CTL  = 2;
  SB_BOTH = 3;

//
// Scroll Bar Commands
//

  SB_LINEUP        = 0;
  SB_LINELEFT      = 0;
  SB_LINEDOWN      = 1;
  SB_LINERIGHT     = 1;
  SB_PAGEUP        = 2;
  SB_PAGELEFT      = 2;
  SB_PAGEDOWN      = 3;
  SB_PAGERIGHT     = 3;
  SB_THUMBPOSITION = 4;
  SB_THUMBTRACK    = 5;
  SB_TOP           = 6;
  SB_LEFT          = 6;
  SB_BOTTOM        = 7;
  SB_RIGHT         = 7;
  SB_ENDSCROLL     = 8;

//
// ShowWindow() Commands
//

  SW_HIDE            = 0;
  SW_SHOWNORMAL      = 1;
  SW_NORMAL          = 1;
  SW_SHOWMINIMIZED   = 2;
  SW_SHOWMAXIMIZED   = 3;
  SW_MAXIMIZE        = 3;
  SW_SHOWNOACTIVATE  = 4;
  SW_SHOW            = 5;
  SW_MINIMIZE        = 6;
  SW_SHOWMINNOACTIVE = 7;
  SW_SHOWNA          = 8;
  SW_RESTORE         = 9;
  SW_SHOWDEFAULT     = 10;
  SW_FORCEMINIMIZE   = 11;
  SW_MAX             = 11;

//
// Old ShowWindow() Commands
//

  HIDE_WINDOW         = 0;
  SHOW_OPENWINDOW     = 1;
  SHOW_ICONWINDOW     = 2;
  SHOW_FULLSCREEN     = 3;
  SHOW_OPENNOACTIVATE = 4;

//
// Identifiers for the WM_SHOWWINDOW message
//

  SW_PARENTCLOSING = 1;
  SW_OTHERZOOM     = 2;
  SW_PARENTOPENING = 3;
  SW_OTHERUNZOOM   = 4;

//
// AnimateWindow() Commands
//

  AW_HOR_POSITIVE = $00000001;
  AW_HOR_NEGATIVE = $00000002;
  AW_VER_POSITIVE = $00000004;
  AW_VER_NEGATIVE = $00000008;
  AW_CENTER       = $00000010;
  AW_HIDE         = $00010000;
  AW_ACTIVATE     = $00020000;
  AW_SLIDE        = $00040000;
  AW_BLEND        = $00080000;

//
// WM_KEYUP/DOWN/CHAR HIWORD(lParam) flags
//

  KF_EXTENDED = $0100;
  KF_DLGMODE  = $0800;
  KF_MENUMODE = $1000;
  KF_ALTDOWN  = $2000;
  KF_REPEAT   = $4000;
  KF_UP       = $8000;

//
// Virtual Keys, Standard Set
//

  VK_LBUTTON = $01;
  VK_RBUTTON = $02;
  VK_CANCEL  = $03;
  VK_MBUTTON = $04; // NOT contiguous with L & RBUTTON

  VK_XBUTTON1 = $05; // NOT contiguous with L & RBUTTON
  VK_XBUTTON2 = $06; // NOT contiguous with L & RBUTTON

//
// 0x07 : unassigned
//

  VK_BACK = $08;
  VK_TAB  = $09;

//
// 0x0A - 0x0B : reserved
//

  VK_CLEAR  = $0C;
  VK_RETURN = $0D;

  VK_SHIFT   = $10;
  VK_CONTROL = $11;
  VK_MENU    = $12;
  VK_PAUSE   = $13;
  VK_CAPITAL = $14;

  VK_KANA    = $15;
  VK_HANGEUL = $15; // old name - should be here for compatibility
  VK_HANGUL  = $15;
  VK_JUNJA   = $17;
  VK_FINAL   = $18;
  VK_HANJA   = $19;
  VK_KANJI   = $19;

  VK_ESCAPE = $1B;

  VK_CONVERT    = $1C;
  VK_NONCONVERT = $1D;
  VK_ACCEPT     = $1E;
  VK_MODECHANGE = $1F;

  VK_SPACE    = $20;
  VK_PRIOR    = $21;
  VK_NEXT     = $22;
  VK_END      = $23;
  VK_HOME     = $24;
  VK_LEFT     = $25;
  VK_UP       = $26;
  VK_RIGHT    = $27;
  VK_DOWN     = $28;
  VK_SELECT   = $29;
  VK_PRINT    = $2A;
  VK_EXECUTE  = $2B;
  VK_SNAPSHOT = $2C;
  VK_INSERT   = $2D;
  VK_DELETE   = $2E;
  VK_HELP     = $2F;

//
// VK_0 - VK_9 are the same as ASCII '0' - '9' (0x30 - 0x39)
// 0x40 : unassigned
// VK_A - VK_Z are the same as ASCII 'A' - 'Z' (0x41 - 0x5A)
//

  VK_LWIN = $5B;
  VK_RWIN = $5C;
  VK_APPS = $5D;

//
// 0x5E : reserved
//

  VK_SLEEP = $5F;

  VK_NUMPAD0   = $60;
  VK_NUMPAD1   = $61;
  VK_NUMPAD2   = $62;
  VK_NUMPAD3   = $63;
  VK_NUMPAD4   = $64;
  VK_NUMPAD5   = $65;
  VK_NUMPAD6   = $66;
  VK_NUMPAD7   = $67;
  VK_NUMPAD8   = $68;
  VK_NUMPAD9   = $69;
  VK_MULTIPLY  = $6A;
  VK_ADD       = $6B;
  VK_SEPARATOR = $6C;
  VK_SUBTRACT  = $6D;
  VK_DECIMAL   = $6E;
  VK_DIVIDE    = $6F;
  VK_F1        = $70;
  VK_F2        = $71;
  VK_F3        = $72;
  VK_F4        = $73;
  VK_F5        = $74;
  VK_F6        = $75;
  VK_F7        = $76;
  VK_F8        = $77;
  VK_F9        = $78;
  VK_F10       = $79;
  VK_F11       = $7A;
  VK_F12       = $7B;
  VK_F13       = $7C;
  VK_F14       = $7D;
  VK_F15       = $7E;
  VK_F16       = $7F;
  VK_F17       = $80;
  VK_F18       = $81;
  VK_F19       = $82;
  VK_F20       = $83;
  VK_F21       = $84;
  VK_F22       = $85;
  VK_F23       = $86;
  VK_F24       = $87;

//
// 0x88 - 0x8F : unassigned
//

  VK_NUMLOCK = $90;
  VK_SCROLL  = $91;

//
// NEC PC-9800 kbd definitions
//

  VK_OEM_NEC_EQUAL = $92; // '=' key on numpad

//
// Fujitsu/OASYS kbd definitions
//

  VK_OEM_FJ_JISHO   = $92; // 'Dictionary' key
  VK_OEM_FJ_MASSHOU = $93; // 'Unregister word' key
  VK_OEM_FJ_TOUROKU = $94; // 'Register word' key
  VK_OEM_FJ_LOYA    = $95; // 'Left OYAYUBI' key
  VK_OEM_FJ_ROYA    = $96; // 'Right OYAYUBI' key

//
// 0x97 - 0x9F : unassigned
//

//
// VK_L* & VK_R* - left and right Alt, Ctrl and Shift virtual keys.
// Used only as parameters to GetAsyncKeyState() and GetKeyState().
// No other API or message will distinguish left and right keys in this way.
//

  VK_LSHIFT   = $A0;
  VK_RSHIFT   = $A1;
  VK_LCONTROL = $A2;
  VK_RCONTROL = $A3;
  VK_LMENU    = $A4;
  VK_RMENU    = $A5;

  VK_BROWSER_BACK      = $A6;
  VK_BROWSER_FORWARD   = $A7;
  VK_BROWSER_REFRESH   = $A8;
  VK_BROWSER_STOP      = $A9;
  VK_BROWSER_SEARCH    = $AA;
  VK_BROWSER_FAVORITES = $AB;
  VK_BROWSER_HOME      = $AC;

  VK_VOLUME_MUTE         = $AD;
  VK_VOLUME_DOWN         = $AE;
  VK_VOLUME_UP           = $AF;
  VK_MEDIA_NEXT_TRACK    = $B0;
  VK_MEDIA_PREV_TRACK    = $B1;
  VK_MEDIA_STOP          = $B2;
  VK_MEDIA_PLAY_PAUSE    = $B3;
  VK_LAUNCH_MAIL         = $B4;
  VK_LAUNCH_MEDIA_SELECT = $B5;
  VK_LAUNCH_APP1         = $B6;
  VK_LAUNCH_APP2         = $B7;

//
// 0xB8 - 0xB9 : reserved
//

  VK_OEM_1      = $BA; // ';:' for US
  VK_OEM_PLUS   = $BB; // '+' any country
  VK_OEM_COMMA  = $BC; // ',' any country
  VK_OEM_MINUS  = $BD; // '-' any country
  VK_OEM_PERIOD = $BE; // '.' any country
  VK_OEM_2      = $BF; // '/?' for US
  VK_OEM_3      = $C0; // '`~' for US

//
// 0xC1 - 0xD7 : reserved
//

//
// 0xD8 - 0xDA : unassigned
//

  VK_OEM_4 = $DB; // '[{' for US
  VK_OEM_5 = $DC; // '\|' for US
  VK_OEM_6 = $DD; // ']}' for US
  VK_OEM_7 = $DE; // ''"' for US
  VK_OEM_8 = $DF;

//
// 0xE0 : reserved
//

//
// Various extended or enhanced keyboards
//

  VK_OEM_AX   = $E1; // 'AX' key on Japanese AX kbd
  VK_OEM_102  = $E2; // "<>" or "\|" on RT 102-key kbd.
  VK_ICO_HELP = $E3; // Help key on ICO
  VK_ICO_00   = $E4; // 00 key on ICO

  VK_PROCESSKEY = $E5;

  VK_ICO_CLEAR = $E6;

  VK_PACKET = $E7;

//
// 0xE8 : unassigned
//

//
// Nokia/Ericsson definitions
//

  VK_OEM_RESET   = $E9;
  VK_OEM_JUMP    = $EA;
  VK_OEM_PA1     = $EB;
  VK_OEM_PA2     = $EC;
  VK_OEM_PA3     = $ED;
  VK_OEM_WSCTRL  = $EE;
  VK_OEM_CUSEL   = $EF;
  VK_OEM_ATTN    = $F0;
  VK_OEM_FINISH  = $F1;
  VK_OEM_COPY    = $F2;
  VK_OEM_AUTO    = $F3;
  VK_OEM_ENLW    = $F4;
  VK_OEM_BACKTAB = $F5;

  VK_ATTN      = $F6;
  VK_CRSEL     = $F7;
  VK_EXSEL     = $F8;
  VK_EREOF     = $F9;
  VK_PLAY      = $FA;
  VK_ZOOM      = $FB;
  VK_NONAME    = $FC;
  VK_PA1       = $FD;
  VK_OEM_CLEAR = $FE;

//
// 0xFF : reserved
//


//
// SetWindowsHook() codes
//

  WH_MIN             = DWORD(-1);
  WH_MSGFILTER       = DWORD(-1);
  WH_JOURNALRECORD   = 0;
  WH_JOURNALPLAYBACK = 1;
  WH_KEYBOARD        = 2;
  WH_GETMESSAGE      = 3;
  WH_CALLWNDPROC     = 4;
  WH_CBT             = 5;
  WH_SYSMSGFILTER    = 6;
  WH_MOUSE           = 7;
  WH_HARDWARE        = 8;
  WH_DEBUG           = 9;
  WH_SHELL           = 10;
  WH_FOREGROUNDIDLE  = 11;
  WH_CALLWNDPROCRET  = 12;

  WH_KEYBOARD_LL = 13;
  WH_MOUSE_LL    = 14;

  WH_MAX = 14;

  WH_MINHOOK = WH_MIN;
  WH_MAXHOOK = WH_MAX;

//
// Hook Codes
//

  HC_ACTION      = 0;
  HC_GETNEXT     = 1;
  HC_SKIP        = 2;
  HC_NOREMOVE    = 3;
  HC_NOREM       = HC_NOREMOVE;
  HC_SYSMODALON  = 4;
  HC_SYSMODALOFF = 5;

//
// CBT Hook Codes
//

  HCBT_MOVESIZE     = 0;
  HCBT_MINMAX       = 1;
  HCBT_QS           = 2;
  HCBT_CREATEWND    = 3;
  HCBT_DESTROYWND   = 4;
  HCBT_ACTIVATE     = 5;
  HCBT_CLICKSKIPPED = 6;
  HCBT_KEYSKIPPED   = 7;
  HCBT_SYSCOMMAND   = 8;
  HCBT_SETFOCUS     = 9;

//
// HCBT_ACTIVATE structure pointed to by lParam
//

type
  LPCBTACTIVATESTRUCT = ^CBTACTIVATESTRUCT;
  tagCBTACTIVATESTRUCT = record
    fMouse: BOOL;
    hWndActive: HWND;
  end;
  CBTACTIVATESTRUCT = tagCBTACTIVATESTRUCT;
  TCbtActivateStruct = CBTACTIVATESTRUCT;
  PCbtActivateStruct = LPCBTACTIVATESTRUCT;

//
// WTSSESSION_NOTIFICATION struct pointed by lParam, for WM_WTSSESSION_CHANGE
//

  tagWTSSESSION_NOTIFICATION = record
    cbSize: DWORD;
    dwSessionId: DWORD;
  end;
  WTSSESSION_NOTIFICATION = tagWTSSESSION_NOTIFICATION;
  PWTSSESSION_NOTIFICATION = ^WTSSESSION_NOTIFICATION;
  TWtsSessionNotification = WTSSESSION_NOTIFICATION;
  PWtsSessionNotification = PWTSSESSION_NOTIFICATION;

//
// codes passed in WPARAM for WM_WTSSESSION_CHANGE
//

const
  WTS_CONSOLE_CONNECT     = $1;
  WTS_CONSOLE_DISCONNECT  = $2;
  WTS_REMOTE_CONNECT      = $3;
  WTS_REMOTE_DISCONNECT   = $4;
  WTS_SESSION_LOGON       = $5;
  WTS_SESSION_LOGOFF      = $6;
  WTS_SESSION_LOCK        = $7;
  WTS_SESSION_UNLOCK      = $8;
  WTS_SESSION_REMOTE_CONTROL = $9;

//
// WH_MSGFILTER Filter Proc Codes
//

const
  MSGF_DIALOGBOX  = 0;
  MSGF_MESSAGEBOX = 1;
  MSGF_MENU       = 2;
  MSGF_SCROLLBAR  = 5;
  MSGF_NEXTWINDOW = 6;
  MSGF_MAX        = 8; // unused
  MSGF_USER       = 4096;

//
// Shell support
//

  HSHELL_WINDOWCREATED       = 1;
  HSHELL_WINDOWDESTROYED     = 2;
  HSHELL_ACTIVATESHELLWINDOW = 3;

  HSHELL_WINDOWACTIVATED = 4;
  HSHELL_GETMINRECT      = 5;
  HSHELL_REDRAW          = 6;
  HSHELL_TASKMAN         = 7;
  HSHELL_LANGUAGE        = 8;
  HSHELL_ACCESSIBILITYSTATE = 11;
  HSHELL_APPCOMMAND      = 12;

  HSHELL_WINDOWREPLACED  = 13;

// wparam for HSHELL_ACCESSIBILITYSTATE//

  ACCESS_STICKYKEYS = $0001;
  ACCESS_FILTERKEYS = $0002;
  ACCESS_MOUSEKEYS  = $0003;

// cmd for HSHELL_APPCOMMAND and WM_APPCOMMAND//

  APPCOMMAND_BROWSER_BACKWARD    = 1;
  APPCOMMAND_BROWSER_FORWARD     = 2;
  APPCOMMAND_BROWSER_REFRESH     = 3;
  APPCOMMAND_BROWSER_STOP        = 4;
  APPCOMMAND_BROWSER_SEARCH      = 5;
  APPCOMMAND_BROWSER_FAVORITES   = 6;
  APPCOMMAND_BROWSER_HOME        = 7;
  APPCOMMAND_VOLUME_MUTE         = 8;
  APPCOMMAND_VOLUME_DOWN         = 9;
  APPCOMMAND_VOLUME_UP           = 10;
  APPCOMMAND_MEDIA_NEXTTRACK     = 11;
  APPCOMMAND_MEDIA_PREVIOUSTRACK = 12;
  APPCOMMAND_MEDIA_STOP          = 13;
  APPCOMMAND_MEDIA_PLAY_PAUSE    = 14;
  APPCOMMAND_LAUNCH_MAIL         = 15;
  APPCOMMAND_LAUNCH_MEDIA_SELECT = 16;
  APPCOMMAND_LAUNCH_APP1         = 17;
  APPCOMMAND_LAUNCH_APP2         = 18;
  APPCOMMAND_BASS_DOWN           = 19;
  APPCOMMAND_BASS_BOOST          = 20;
  APPCOMMAND_BASS_UP             = 21;
  APPCOMMAND_TREBLE_DOWN         = 22;
  APPCOMMAND_TREBLE_UP           = 23;
  APPCOMMAND_MICROPHONE_VOLUME_MUTE = 24;
  APPCOMMAND_MICROPHONE_VOLUME_DOWN = 25;
  APPCOMMAND_MICROPHONE_VOLUME_UP   = 26;
  APPCOMMAND_HELP                   = 27;
  APPCOMMAND_FIND                   = 28;
  APPCOMMAND_NEW                    = 29;
  APPCOMMAND_OPEN                   = 30;
  APPCOMMAND_CLOSE                  = 31;
  APPCOMMAND_SAVE                   = 32;
  APPCOMMAND_PRINT                  = 33;
  APPCOMMAND_UNDO                   = 34;
  APPCOMMAND_REDO                   = 35;
  APPCOMMAND_COPY                   = 36;
  APPCOMMAND_CUT                    = 37;
  APPCOMMAND_PASTE                  = 38;
  APPCOMMAND_REPLY_TO_MAIL          = 39;
  APPCOMMAND_FORWARD_MAIL           = 40;
  APPCOMMAND_SEND_MAIL              = 41;
  APPCOMMAND_SPELL_CHECK            = 42;
  APPCOMMAND_DICTATE_OR_COMMAND_CONTROL_TOGGLE = 43;
  APPCOMMAND_MIC_ON_OFF_TOGGLE      = 44;
  APPCOMMAND_CORRECTION_LIST        = 45;
  APPCOMMAND_MEDIA_PLAY             = 46;
  APPCOMMAND_MEDIA_PAUSE            = 47;
  APPCOMMAND_MEDIA_RECORD           = 48;
  APPCOMMAND_MEDIA_FAST_FORWARD     = 49;
  APPCOMMAND_MEDIA_REWIND           = 50;
  APPCOMMAND_MEDIA_CHANNEL_UP       = 51;
  APPCOMMAND_MEDIA_CHANNEL_DOWN     = 52;

  FAPPCOMMAND_MOUSE = $8000;
  FAPPCOMMAND_KEY   = 0;
  FAPPCOMMAND_OEM   = $1000;
  FAPPCOMMAND_MASK  = $F000;

function GET_APPCOMMAND_LPARAM(lParam: LPARAM): Shortint;

function GET_DEVICE_LPARAM(lParam: LPARAM): WORD;

function GET_MOUSEORKEY_LPARAM(lParam: LPARAM): WORD;

function GET_FLAGS_LPARAM(lParam: LPARAM): Integer;

function GET_KEYSTATE_LPARAM(lParam: LPARAM): Integer;

//
// Message Structure used in Journaling
//

type
  LPEVENTMSG = ^EVENTMSG;
  tagEVENTMSG = record
    message_: UINT;
    paramL: UINT;
    paramH: UINT;
    time: DWORD;
    hwnd: HWND;
  end;
  EVENTMSG = tagEVENTMSG;
  LPEVENTMSGMSG = ^EVENTMSG;
  PEVENTMSGMSG = ^EVENTMSG;
  NPEVENTMSG = ^EVENTMSG;
  NPEVENTMSGMSG = ^EVENTMSG;
  TEventMsg = EVENTMSG;
  PEventMsg = LPEVENTMSG;

//
// Message structure used by WH_CALLWNDPROC
//

  LPCWPSTRUCT = ^CWPSTRUCT;
  tagCWPSTRUCT = record
    lParam: LPARAM;
    wParam: WPARAM;
    message: UINT;
    hwnd: HWND;
  end;
  CWPSTRUCT = tagCWPSTRUCT;
  NPCWPSTRUCT = ^CWPSTRUCT;
  TCwpStruct = CWPSTRUCT;
  PCwpStruct = LPCWPSTRUCT;

//
// Message structure used by WH_CALLWNDPROCRET
//

  LPCWPRETSTRUCT = ^CWPRETSTRUCT;
  tagCWPRETSTRUCT = record
    lResult: LRESULT;
    lParam: LPARAM;
    wParam: WPARAM;
    message: UINT;
    hwnd: HWND;
  end;
  CWPRETSTRUCT = tagCWPRETSTRUCT;
  NPCWPRETSTRUCT = ^CWPRETSTRUCT;
  TCwpRetStruct = CWPRETSTRUCT;
  PCwpRetStruct = LPCWPRETSTRUCT;

//
// Low level hook flags
//

const
  LLKHF_EXTENDED = (KF_EXTENDED shr 8);
  LLKHF_INJECTED = $00000010;
  LLKHF_ALTDOWN  = (KF_ALTDOWN shr 8);
  LLKHF_UP       = (KF_UP shr 8);

  LLMHF_INJECTED = $00000001;

//
// Structure used by WH_KEYBOARD_LL
//

type
  LPKBDLLHOOKSTRUCT = ^KBDLLHOOKSTRUCT;
  tagKBDLLHOOKSTRUCT = record
    vkCode: DWORD;
    scanCode: DWORD;
    flags: DWORD;
    time: DWORD;
    dwExtraInfo: ULONG_PTR;
  end;
  KBDLLHOOKSTRUCT = tagKBDLLHOOKSTRUCT;
  TKbDllHookStruct = KBDLLHOOKSTRUCT;
  PKbDllHookStruct = LPKBDLLHOOKSTRUCT;

//
// Structure used by WH_MOUSE_LL
//

  LPMSLLHOOKSTRUCT = ^MSLLHOOKSTRUCT;
  tagMSLLHOOKSTRUCT = record
    pt: POINT;
    mouseData: DWORD;
    flags: DWORD;
    time: DWORD;
    dwExtraInfo: ULONG_PTR;
  end;
  MSLLHOOKSTRUCT = tagMSLLHOOKSTRUCT;
  TMsllHookStruct = MSLLHOOKSTRUCT;
  PMsllHookStruct = LPMSLLHOOKSTRUCT;

//
// Structure used by WH_DEBUG
//

  LPDEBUGHOOKINFO = ^DEBUGHOOKINFO;
  tagDEBUGHOOKINFO = record
    idThread: DWORD;
    idThreadInstaller: DWORD;
    lParam: LPARAM;
    wParam: WPARAM;
    code: Integer;
  end;
  DEBUGHOOKINFO = tagDEBUGHOOKINFO;
  NPDEBUGHOOKINFO = ^DEBUGHOOKINFO;
  TDebugHookInfo = DEBUGHOOKINFO;
  PDebugHookInfo = LPDEBUGHOOKINFO;

//
// Structure used by WH_MOUSE
//

  LPMOUSEHOOKSTRUCT = ^MOUSEHOOKSTRUCT;
  tagMOUSEHOOKSTRUCT = record
    pt: POINT;
    hwnd: HWND;
    wHitTestCode: UINT;
    dwExtraInfo: ULONG_PTR;
  end;
  MOUSEHOOKSTRUCT = tagMOUSEHOOKSTRUCT;
  TMouseHookStruct = MOUSEHOOKSTRUCT;
  PMouseHookStruct = LPMOUSEHOOKSTRUCT;

  LPMOUSEHOOKSTRUCTEX = ^MOUSEHOOKSTRUCTEX;
  tagMOUSEHOOKSTRUCTEX = record
    mhs: MOUSEHOOKSTRUCT;
    mouseData: DWORD;
  end;
  MOUSEHOOKSTRUCTEX = tagMOUSEHOOKSTRUCTEX;
  TMouseHookStructEx = MOUSEHOOKSTRUCTEX;
  PMouseHookStructEx = LPMOUSEHOOKSTRUCTEX;

//
// Structure used by WH_HARDWARE
//

  LPHARDWAREHOOKSTRUCT = ^HARDWAREHOOKSTRUCT;
  tagHARDWAREHOOKSTRUCT = record
    hwnd: HWND;
    message: UINT;
    wParam: WPARAM;
    lParam: LPARAM;
  end;
  HARDWAREHOOKSTRUCT = tagHARDWAREHOOKSTRUCT;
  THardwareHookStruct = HARDWAREHOOKSTRUCT;
  PHardwareHookStruct = LPHARDWAREHOOKSTRUCT;

//
// Keyboard Layout API
//

const
  HKL_PREV = 0;
  HKL_NEXT = 1;

  KLF_ACTIVATE      = $00000001;
  KLF_SUBSTITUTE_OK = $00000002;
  KLF_REORDER       = $00000008;
  KLF_REPLACELANG   = $00000010;
  KLF_NOTELLSHELL   = $00000080;
  KLF_SETFORPROCESS = $00000100;
  KLF_SHIFTLOCK     = $00010000;
  KLF_RESET         = $40000000;

//
// Bits in wParam of WM_INPUTLANGCHANGEREQUEST message
//

  INPUTLANGCHANGE_SYSCHARSET = $0001;
  INPUTLANGCHANGE_FORWARD    = $0002;
  INPUTLANGCHANGE_BACKWARD   = $0004;

//
// Size of KeyboardLayoutName (number of characters), including nul terminator
//

  KL_NAMELENGTH = 9;

function LoadKeyboardLayoutA(pwszKLID: LPCSTR; Flags: UINT): HKL; stdcall;
function LoadKeyboardLayoutW(pwszKLID: LPCWSTR; Flags: UINT): HKL; stdcall;

{$IFDEF UNICODE}
function LoadKeyboardLayout(pwszKLID: LPCWSTR; Flags: UINT): HKL; stdcall;
{$ELSE}
function LoadKeyboardLayout(pwszKLID: LPCSTR; Flags: UINT): HKL; stdcall;
{$ENDIF}

function ActivateKeyboardLayout(hkl: HKL; Flags: UINT): HKL; stdcall;

function ToUnicodeEx(wVirtKey, wScanCode: UINT; lpKeyState: PBYTE;
  pwszBuff: LPWSTR; cchBuff: Integer; wFlags: UINT; dwhkl: HKL): Integer; stdcall;

function UnloadKeyboardLayout(hkl: HKL): BOOL; stdcall;

function GetKeyboardLayoutNameA(pwszKLID: LPSTR): BOOL; stdcall;
function GetKeyboardLayoutNameW(pwszKLID: LPWSTR): BOOL; stdcall;

{$IFDEF UNICODE}
function GetKeyboardLayoutName(pwszKLID: LPWSTR): BOOL; stdcall;
{$ELSE}
function GetKeyboardLayoutName(pwszKLID: LPSTR): BOOL; stdcall;
{$ENDIF}

function GetKeyboardLayoutList(nBuff: Integer; lpList: PHKL): Integer; stdcall;

function GetKeyboardLayout(idThread: DWORD): HKL; stdcall;

type
  LPMOUSEMOVEPOINT = ^MOUSEMOVEPOINT;
  tagMOUSEMOVEPOINT = record
    x: Integer;
    y: Integer;
    time: DWORD;
    dwExtraInfo: ULONG_PTR;
  end;
  MOUSEMOVEPOINT = tagMOUSEMOVEPOINT;
  TMouseMovePoint = MOUSEMOVEPOINT;
  PMouseMovePoint = LPMOUSEMOVEPOINT;

//
// Values for resolution parameter of GetMouseMovePointsEx
//

const
  GMMP_USE_DISPLAY_POINTS         = 1;
  GMMP_USE_HIGH_RESOLUTION_POINTS = 2;

function GetMouseMovePointsEx(cbSize: UINT; lppt, lpptBuf: LPMOUSEMOVEPOINT;
  nBufPoints: Integer; resolution: DWORD): Integer; stdcall;

//
// Desktop-specific access flags
//

const
  DESKTOP_READOBJECTS     = $0001;
  DESKTOP_CREATEWINDOW    = $0002;
  DESKTOP_CREATEMENU      = $0004;
  DESKTOP_HOOKCONTROL     = $0008;
  DESKTOP_JOURNALRECORD   = $0010;
  DESKTOP_JOURNALPLAYBACK = $0020;
  DESKTOP_ENUMERATE       = $0040;
  DESKTOP_WRITEOBJECTS    = $0080;
  DESKTOP_SWITCHDESKTOP   = $0100;

//
// Desktop-specific control flags
//

  DF_ALLOWOTHERACCOUNTHOOK = $0001;

function CreateDesktopA(lpszDesktop, lpszDevice: LPCSTR; pDevmode: LPDEVMODEA;
  dwFlags: DWORD; dwDesiredAccess: ACCESS_MASK; lpsa: LPSECURITY_ATTRIBUTES): HDESK; stdcall;
function CreateDesktopW(lpszDesktop, lpszDevice: LPCWSTR; pDevmode: LPDEVMODEW;
  dwFlags: DWORD; dwDesiredAccess: ACCESS_MASK; lpsa: LPSECURITY_ATTRIBUTES): HDESK; stdcall;

{$IFDEF UNICODE}
function CreateDesktop(lpszDesktop, lpszDevice: LPCWSTR; pDevmode: LPDEVMODEW;
  dwFlags: DWORD; dwDesiredAccess: ACCESS_MASK; lpsa: LPSECURITY_ATTRIBUTES): HDESK; stdcall;
{$ELSE}
function CreateDesktop(lpszDesktop, lpszDevice: LPCSTR; pDevmode: LPDEVMODEA;
  dwFlags: DWORD; dwDesiredAccess: ACCESS_MASK; lpsa: LPSECURITY_ATTRIBUTES): HDESK; stdcall;
{$ENDIF}

function OpenDesktopA(lpszDesktop: LPCSTR; dwFlags: DWORD; fInherit: BOOL;
  dwDesiredAccess: ACCESS_MASK): HDESK; stdcall;
function OpenDesktopW(lpszDesktop: LPCWSTR; dwFlags: DWORD; fInherit: BOOL;
  dwDesiredAccess: ACCESS_MASK): HDESK; stdcall;

{$IFDEF UNICODE}
function OpenDesktop(lpszDesktop: LPCWSTR; dwFlags: DWORD; fInherit: BOOL;
  dwDesiredAccess: ACCESS_MASK): HDESK; stdcall;
{$ELSE}
function OpenDesktop(lpszDesktop: LPCSTR; dwFlags: DWORD; fInherit: BOOL;
  dwDesiredAccess: ACCESS_MASK): HDESK; stdcall;
{$ENDIF}

function OpenInputDesktop(dwFlags: DWORD; fInherit: BOOL;
  dwDesiredAccess: ACCESS_MASK): HDESK; stdcall;

function EnumDesktopsA(hwinsta: HWINSTA; lpEnumFunc: DESKTOPENUMPROCA;
  lParam: LPARAM): BOOL; stdcall;
function EnumDesktopsW(hwinsta: HWINSTA; lpEnumFunc: DESKTOPENUMPROCW;
  lParam: LPARAM): BOOL; stdcall;

{$IFDEF UNICODE}
function EnumDesktops(hwinsta: HWINSTA; lpEnumFunc: DESKTOPENUMPROCW;
  lParam: LPARAM): BOOL; stdcall;
{$ELSE}
function EnumDesktops(hwinsta: HWINSTA; lpEnumFunc: DESKTOPENUMPROCA;
  lParam: LPARAM): BOOL; stdcall;
{$ENDIF}

function EnumDesktopWindows(hDesktop: HDESK; lpfn: WNDENUMPROC; lParam: LPARAM): BOOL; stdcall;

function SwitchDesktop(hDesktop: HDESK): BOOL; stdcall;

function SetThreadDesktop(hDesktop: HDESK): BOOL; stdcall;

function CloseDesktop(hDesktop: HDESK): BOOL; stdcall;

function GetThreadDesktop(dwThreadId: DWORD): HDESK; stdcall;

//
// Windowstation-specific access flags
//

const
  WINSTA_ENUMDESKTOPS      = $0001;
  WINSTA_READATTRIBUTES    = $0002;
  WINSTA_ACCESSCLIPBOARD   = $0004;
  WINSTA_CREATEDESKTOP     = $0008;
  WINSTA_WRITEATTRIBUTES   = $0010;
  WINSTA_ACCESSGLOBALATOMS = $0020;
  WINSTA_EXITWINDOWS       = $0040;
  WINSTA_ENUMERATE         = $0100;
  WINSTA_READSCREEN        = $0200;

  WINSTA_ALL_ACCESS        = (WINSTA_ENUMDESKTOPS or WINSTA_READATTRIBUTES or WINSTA_ACCESSCLIPBOARD or
                              WINSTA_CREATEDESKTOP or WINSTA_WRITEATTRIBUTES or WINSTA_ACCESSGLOBALATOMS or
                              WINSTA_EXITWINDOWS or WINSTA_ENUMERATE or WINSTA_READSCREEN);

//
// Windowstation-specific attribute flags
//

  WSF_VISIBLE = $0001;

function CreateWindowStationA(lpwinsta: LPCSTR; dwReserved: DWORD;
  dwDesiredAccess: ACCESS_MASK; lpsa: LPSECURITY_ATTRIBUTES): HWINSTA; stdcall;
function CreateWindowStationW(lpwinsta: LPCWSTR; dwReserved: DWORD;
  dwDesiredAccess: ACCESS_MASK; lpsa: LPSECURITY_ATTRIBUTES): HWINSTA; stdcall;

{$IFDEF UNICODE}
function CreateWindowStation(lpwinsta: LPCWSTR; dwReserved: DWORD;
  dwDesiredAccess: ACCESS_MASK; lpsa: LPSECURITY_ATTRIBUTES): HWINSTA; stdcall;
{$ELSE}
function CreateWindowStation(lpwinsta: LPCSTR; dwReserved: DWORD;
  dwDesiredAccess: ACCESS_MASK; lpsa: LPSECURITY_ATTRIBUTES): HWINSTA; stdcall;
{$ENDIF}

function OpenWindowStationA(lpszWinSta: LPCSTR; fInherit: BOOL;
  dwDesiredAccess: ACCESS_MASK): HWINSTA; stdcall;
function OpenWindowStationW(lpszWinSta: LPCWSTR; fInherit: BOOL;
  dwDesiredAccess: ACCESS_MASK): HWINSTA; stdcall;

{$IFDEF UNICODE}
function OpenWindowStation(lpszWinSta: LPCWSTR; fInherit: BOOL;
  dwDesiredAccess: ACCESS_MASK): HWINSTA; stdcall;
{$ELSE}
function OpenWindowStation(lpszWinSta: LPCSTR; fInherit: BOOL;
  dwDesiredAccess: ACCESS_MASK): HWINSTA; stdcall;
{$ENDIF}

function EnumWindowStationsA(lpEnumFunc: WINSTAENUMPROCA; lParam: LPARAM): BOOL; stdcall;
function EnumWindowStationsW(lpEnumFunc: WINSTAENUMPROCW; lParam: LPARAM): BOOL; stdcall;

{$IFDEF UNICODE}
function EnumWindowStations(lpEnumFunc: WINSTAENUMPROCW; lParam: LPARAM): BOOL; stdcall;
{$ELSE}
function EnumWindowStations(lpEnumFunc: WINSTAENUMPROCA; lParam: LPARAM): BOOL; stdcall;
{$ENDIF}

function CloseWindowStation(hWinSta: HWINSTA): BOOL; stdcall;

function SetProcessWindowStation(hWinSta: HWINSTA): BOOL; stdcall;

function GetProcessWindowStation: HWINSTA; stdcall;

function SetUserObjectSecurity(hObj: HANDLE; var pSIRequested: SECURITY_INFORMATION;
  pSID: PSECURITY_DESCRIPTOR): BOOL; stdcall;

function GetUserObjectSecurity(hObj: HANDLE; var pSIRequested: SECURITY_INFORMATION;
  pSID: PSECURITY_DESCRIPTOR; nLength: DWORD; var lpnLengthNeeded: DWORD): BOOL; stdcall;

const
  UOI_FLAGS    = 1;
  UOI_NAME     = 2;
  UOI_TYPE     = 3;
  UOI_USER_SID = 4;

type
  PUSEROBJECTFLAGS = ^USEROBJECTFLAGS;
  tagUSEROBJECTFLAGS = record
    fInherit: BOOL;
    fReserved: BOOL;
    dwFlags: DWORD;
  end;
  USEROBJECTFLAGS = tagUSEROBJECTFLAGS;
  TUserObjectFlags = USEROBJECTFLAGS;

function GetUserObjectInformationA(hObj: HANDLE; nIndex: Integer; pvInfo: PVOID;
  nLength: DWORD; var lpnLengthNeeded: DWORD): BOOL; stdcall;
function GetUserObjectInformationW(hObj: HANDLE; nIndex: Integer; pvInfo: PVOID;
  nLength: DWORD; var lpnLengthNeeded: DWORD): BOOL; stdcall;

{$IFDEF UNICODE}
function GetUserObjectInformation(hObj: HANDLE; nIndex: Integer; pvInfo: PVOID;
  nLength: DWORD; var lpnLengthNeeded: DWORD): BOOL; stdcall;
{$ELSE}
function GetUserObjectInformation(hObj: HANDLE; nIndex: Integer; pvInfo: PVOID;
  nLength: DWORD; var lpnLengthNeeded: DWORD): BOOL; stdcall;
{$ENDIF}

function SetUserObjectInformationA(hObj: HANDLE; nIndex: Integer; pvInfo: PVOID;
  nLength: DWORD): BOOL; stdcall;
function SetUserObjectInformationW(hObj: HANDLE; nIndex: Integer; pvInfo: PVOID;
  nLength: DWORD): BOOL; stdcall;

{$IFDEF UNICODE}
function SetUserObjectInformation(hObj: HANDLE; nIndex: Integer; pvInfo: PVOID;
  nLength: DWORD): BOOL; stdcall;
{$ELSE}
function SetUserObjectInformation(hObj: HANDLE; nIndex: Integer; pvInfo: PVOID;
  nLength: DWORD): BOOL; stdcall;
{$ENDIF}

type
  LPWNDCLASSEXA = ^WNDCLASSEXA;
  tagWNDCLASSEXA = record
    cbSize: UINT;
    // Win 3.x
    style: UINT;
    lpfnWndProc: WNDPROC;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINSTANCE;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: LPCSTR;
    lpszClassName: LPCSTR;
    // Win 4.0
    hIconSm: HICON;
  end;
  WNDCLASSEXA = tagWNDCLASSEXA;
  NPWNDCLASSEXA = ^WNDCLASSEXA;
  TWndClassExA = WNDCLASSEXA;
  PWndClassExA = LPWNDCLASSEXA;

  LPWNDCLASSEXW = ^WNDCLASSEXW;
  tagWNDCLASSEXW = record
    cbSize: UINT;
    // Win 3.x
    style: UINT;
    lpfnWndProc: WNDPROC;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINSTANCE;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: LPCWSTR;
    lpszClassName: LPCWSTR;
    // Win 4.0
    hIconSm: HICON;
  end;
  WNDCLASSEXW = tagWNDCLASSEXW;
  NPWNDCLASSEXW = ^WNDCLASSEXW;
  TWndClassExW = WNDCLASSEXW;
  PWndClassExW = LPWNDCLASSEXW;

{$IFDEF UNICODE}
  WNDCLASSEX = WNDCLASSEXW;
  NPWNDCLASSEX = NPWNDCLASSEXW;
  LPWNDCLASSEX = LPWNDCLASSEXW;
  TWndClassEx = TWndClassExW;
  PWndClassEx = PWndClassExW;
{$ELSE}
  WNDCLASSEX = WNDCLASSEXA;
  NPWNDCLASSEX = NPWNDCLASSEXA;
  LPWNDCLASSEX = LPWNDCLASSEXA;
  TWndClassEx = TWndClassExA;
  PWndClassEx = PWndClassExA;
{$ENDIF}

  LPWNDCLASSA = ^WNDCLASSA;
  tagWNDCLASSA = record
    style: UINT;
    lpfnWndProc: WNDPROC;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINSTANCE;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: LPCSTR;
    lpszClassName: LPCSTR;
  end;
  WNDCLASSA = tagWNDCLASSA;
  NPWNDCLASSA = ^WNDCLASSA;
  TWndClassA = WNDCLASSA;
  PWndClassA = LPWNDCLASSA;

  LPWNDCLASSW = ^WNDCLASSW;
  tagWNDCLASSW = record
    style: UINT;
    lpfnWndProc: WNDPROC;
    cbClsExtra: Integer;
    cbWndExtra: Integer;
    hInstance: HINSTANCE;
    hIcon: HICON;
    hCursor: HCURSOR;
    hbrBackground: HBRUSH;
    lpszMenuName: LPCWSTR;
    lpszClassName: LPCWSTR;
  end;
  WNDCLASSW = tagWNDCLASSW;
  NPWNDCLASSW = ^WNDCLASSW;
  TWndClassW = WNDCLASSW;
  PWndClassW = LPWNDCLASSW;

{$IFDEF UNICODE}
  WNDCLASS = WNDCLASSW;
  NPWNDCLASS = NPWNDCLASSW;
  LPWNDCLASS = LPWNDCLASSW;
  TWndClass = TWndClassW;
  PWndClass = PWndClassW;
{$ELSE}
  WNDCLASS = WNDCLASSA;
  NPWNDCLASS = NPWNDCLASSA;
  LPWNDCLASS = LPWNDCLASSA;
  TWndClass = TWndClassA;
  PWndClass = PWndClassA;
{$ENDIF}

function IsHungAppWindow(hwnd: HWND): BOOL; stdcall;

//
// Message structure
//

type
  LPMSG = ^MSG;
  tagMSG = record
    hwnd: HWND;
    message: UINT;
    wParam: WPARAM;
    lParam: LPARAM;
    time: DWORD;
    pt: POINT;
  end;
  MSG = tagMSG;
  NPMSG = ^MSG;
  TMsg = MSG;
  PMsg = LPMSG;

function MAKEWPARAM(wLow, wHigh: WORD): WPARAM;

function MAKELPARAM(wLow, wHigh: WORD): LPARAM;

function MAKELRESULT(wLow, wHigh: WORD): LRESULT;

//
// Window field offsets for GetWindowLong()
//

const
  GWL_WNDPROC    = -4;
  GWL_HINSTANCE  = -6;
  GWL_HWNDPARENT = -8;
  GWL_STYLE      = -16;
  GWL_EXSTYLE    = -20;
  GWL_USERDATA   = -21;
  GWL_ID         = -12;

  GWLP_WNDPROC    = -4;
  GWLP_HINSTANCE  = -6;
  GWLP_HWNDPARENT = -8;
  GWLP_USERDATA   = -21;
  GWLP_ID         = -12;

//
// Class field offsets for GetClassLong()
//

  GCL_MENUNAME      = DWORD(-8);
  GCL_HBRBACKGROUND = DWORD(-10);
  GCL_HCURSOR       = DWORD(-12);
  GCL_HICON         = DWORD(-14);
  GCL_HMODULE       = DWORD(-16);
  GCL_CBWNDEXTRA    = DWORD(-18);
  GCL_CBCLSEXTRA    = DWORD(-20);
  GCL_WNDPROC       = DWORD(-24);
  GCL_STYLE         = DWORD(-26);
  GCW_ATOM          = DWORD(-32);

  GCL_HICONSM = DWORD(-34);

  GCLP_MENUNAME      = DWORD(-8);
  GCLP_HBRBACKGROUND = DWORD(-10);
  GCLP_HCURSOR       = DWORD(-12);
  GCLP_HICON         = DWORD(-14);
  GCLP_HMODULE       = DWORD(-16);
  GCLP_WNDPROC       = DWORD(-24);
  GCLP_HICONSM       = DWORD(-34);

//
// Window Messages
//

  WM_NULL    = $0000;
  WM_CREATE  = $0001;
  WM_DESTROY = $0002;
  WM_MOVE    = $0003;
  WM_SIZE    = $0005;

  WM_ACTIVATE = $0006;

//
// WM_ACTIVATE state values
//

  WA_INACTIVE    = 0;
  WA_ACTIVE      = 1;
  WA_CLICKACTIVE = 2;

  WM_SETFOCUS        = $0007;
  WM_KILLFOCUS       = $0008;
  WM_ENABLE          = $000A;
  WM_SETREDRAW       = $000B;
  WM_SETTEXT         = $000C;
  WM_GETTEXT         = $000D;
  WM_GETTEXTLENGTH   = $000E;
  WM_PAINT           = $000F;
  WM_CLOSE           = $0010;
  WM_QUERYENDSESSION = $0011;
  WM_QUERYOPEN       = $0013;
  WM_ENDSESSION      = $0016;
  WM_QUIT            = $0012;
  WM_ERASEBKGND      = $0014;
  WM_SYSCOLORCHANGE  = $0015;
  WM_SHOWWINDOW      = $0018;
  WM_WININICHANGE    = $001A;
  WM_SETTINGCHANGE   = WM_WININICHANGE;

  WM_DEVMODECHANGE = $001B;
  WM_ACTIVATEAPP   = $001C;
  WM_FONTCHANGE    = $001D;
  WM_TIMECHANGE    = $001E;
  WM_CANCELMODE    = $001F;
  WM_SETCURSOR     = $0020;
  WM_MOUSEACTIVATE = $0021;
  WM_CHILDACTIVATE = $0022;
  WM_QUEUESYNC     = $0023;

  WM_GETMINMAXINFO = $0024;

//
// Struct pointed to by WM_GETMINMAXINFO lParam
//

type
  LPMINMAXINFO = ^MINMAXINFO;
  tagMINMAXINFO = record
    ptReserved: POINT;
    ptMaxSize: POINT;
    ptMaxPosition: POINT;
    ptMinTrackSize: POINT;
    ptMaxTrackSize: POINT;
  end;
  MINMAXINFO = tagMINMAXINFO;
  TMinMaxInfo = MINMAXINFO;
  PMinMaxInfo = LPMINMAXINFO;

const
  WM_PAINTICON         = $0026;
  WM_ICONERASEBKGND    = $0027;
  WM_NEXTDLGCTL        = $0028;
  WM_SPOOLERSTATUS     = $002A;
  WM_DRAWITEM          = $002B;
  WM_MEASUREITEM       = $002C;
  WM_DELETEITEM        = $002D;
  WM_VKEYTOITEM        = $002E;
  WM_CHARTOITEM        = $002F;
  WM_SETFONT           = $0030;
  WM_GETFONT           = $0031;
  WM_SETHOTKEY         = $0032;
  WM_GETHOTKEY         = $0033;
  WM_QUERYDRAGICON     = $0037;
  WM_COMPAREITEM       = $0039;
  WM_GETOBJECT         = $003D;
  WM_COMPACTING        = $0041;
  WM_COMMNOTIFY        = $0044; // no longer suported
  WM_WINDOWPOSCHANGING = $0046;
  WM_WINDOWPOSCHANGED  = $0047;

  WM_POWER = $0048;

//
// wParam for WM_POWER window message and DRV_POWER driver notification
//

  PWR_OK             = 1;
  PWR_FAIL           = DWORD(-1);
  PWR_SUSPENDREQUEST = 1;
  PWR_SUSPENDRESUME  = 2;
  PWR_CRITICALRESUME = 3;

  WM_COPYDATA      = $004A;
  WM_CANCELJOURNAL = $004B;

//
// lParam of WM_COPYDATA message points to...
//

type
  PCOPYDATASTRUCT = ^COPYDATASTRUCT;
  tagCOPYDATASTRUCT = record
    dwData: ULONG_PTR;
    cbData: DWORD;
    lpData: PVOID;
  end;
  COPYDATASTRUCT = tagCOPYDATASTRUCT;
  TCopyDataStruct = COPYDATASTRUCT;

  LPMDINEXTMENU = ^MDINEXTMENU;
  tagMDINEXTMENU = record
    hmenuIn: HMENU;
    hmenuNext: HMENU;
    hwndNext: HWND;
  end;
  MDINEXTMENU = tagMDINEXTMENU;
  TMdiNextMenu = MDINEXTMENU;
  PMdiNextMenu = LPMDINEXTMENU;

const
  WM_NOTIFY                 = $004E;
  WM_INPUTLANGCHANGEREQUEST = $0050;
  WM_INPUTLANGCHANGE        = $0051;
  WM_TCARD                  = $0052;
  WM_HELP                   = $0053;
  WM_USERCHANGED            = $0054;
  WM_NOTIFYFORMAT           = $0055;

  NFR_ANSI    = 1;
  NFR_UNICODE = 2;
  NF_QUERY    = 3;
  NF_REQUERY  = 4;

  WM_CONTEXTMENU   = $007B;
  WM_STYLECHANGING = $007C;
  WM_STYLECHANGED  = $007D;
  WM_DISPLAYCHANGE = $007E;
  WM_GETICON       = $007F;
  WM_SETICON       = $0080;

  WM_NCCREATE        = $0081;
  WM_NCDESTROY       = $0082;
  WM_NCCALCSIZE      = $0083;
  WM_NCHITTEST       = $0084;
  WM_NCPAINT         = $0085;
  WM_NCACTIVATE      = $0086;
  WM_GETDLGCODE      = $0087;
  WM_SYNCPAINT       = $0088;
  WM_NCMOUSEMOVE     = $00A0;
  WM_NCLBUTTONDOWN   = $00A1;
  WM_NCLBUTTONUP     = $00A2;
  WM_NCLBUTTONDBLCLK = $00A3;
  WM_NCRBUTTONDOWN   = $00A4;
  WM_NCRBUTTONUP     = $00A5;
  WM_NCRBUTTONDBLCLK = $00A6;
  WM_NCMBUTTONDOWN   = $00A7;
  WM_NCMBUTTONUP     = $00A8;
  WM_NCMBUTTONDBLCLK = $00A9;

  WM_NCXBUTTONDOWN   = $00AB;
  WM_NCXBUTTONUP     = $00AC;
  WM_NCXBUTTONDBLCLK = $00AD;

  WM_INPUT           = $00FF;

  WM_KEYFIRST    = $0100;
  WM_KEYDOWN     = $0100;
  WM_KEYUP       = $0101;
  WM_CHAR        = $0102;
  WM_DEADCHAR    = $0103;
  WM_SYSKEYDOWN  = $0104;
  WM_SYSKEYUP    = $0105;
  WM_SYSCHAR     = $0106;
  WM_SYSDEADCHAR = $0107;
  WM_KEYLAST     = $0108;

  WM_IME_STARTCOMPOSITION = $010D;
  WM_IME_ENDCOMPOSITION   = $010E;
  WM_IME_COMPOSITION      = $010F;
  WM_IME_KEYLAST          = $010F;

  WM_INITDIALOG      = $0110;
  WM_COMMAND         = $0111;
  WM_SYSCOMMAND      = $0112;
  WM_TIMER           = $0113;
  WM_HSCROLL         = $0114;
  WM_VSCROLL         = $0115;
  WM_INITMENU        = $0116;
  WM_INITMENUPOPUP   = $0117;
  WM_MENUSELECT      = $011F;
  WM_MENUCHAR        = $0120;
  WM_ENTERIDLE       = $0121;
  WM_MENURBUTTONUP   = $0122;
  WM_MENUDRAG        = $0123;
  WM_MENUGETOBJECT   = $0124;
  WM_UNINITMENUPOPUP = $0125;
  WM_MENUCOMMAND     = $0126;

  WM_CHANGEUISTATE = $0127;
  WM_UPDATEUISTATE = $0128;
  WM_QUERYUISTATE  = $0129;

//
// LOWORD(wParam) values in WM_*UISTATE*
//

  UIS_SET        = 1;
  UIS_CLEAR      = 2;
  UIS_INITIALIZE = 3;

//
// HIWORD(wParam) values in WM_*UISTATE*
//

  UISF_HIDEFOCUS = $1;
  UISF_HIDEACCEL = $2;
  UISF_ACTIVE    = $4;

  WM_CTLCOLORMSGBOX    = $0132;
  WM_CTLCOLOREDIT      = $0133;
  WM_CTLCOLORLISTBOX   = $0134;
  WM_CTLCOLORBTN       = $0135;
  WM_CTLCOLORDLG       = $0136;
  WM_CTLCOLORSCROLLBAR = $0137;
  WM_CTLCOLORSTATIC    = $0138;

  WM_MOUSEFIRST    = $0200;
  WM_MOUSEMOVE     = $0200;
  WM_LBUTTONDOWN   = $0201;
  WM_LBUTTONUP     = $0202;
  WM_LBUTTONDBLCLK = $0203;
  WM_RBUTTONDOWN   = $0204;
  WM_RBUTTONUP     = $0205;
  WM_RBUTTONDBLCLK = $0206;
  WM_MBUTTONDOWN   = $0207;
  WM_MBUTTONUP     = $0208;
  WM_MBUTTONDBLCLK = $0209;
  WM_MOUSEWHEEL    = $020A;
  WM_XBUTTONDOWN   = $020B;
  WM_XBUTTONUP     = $020C;
  WM_XBUTTONDBLCLK = $020D;
  WM_MOUSELAST = $020D;

// Value for rolling one detent//

  WHEEL_DELTA                    = 120;

function GET_WHEEL_DELTA_WPARAM(wParam: WPARAM): SHORT;

// Setting to scroll one page for SPI_GET/SETWHEELSCROLLLINES//

const
  WHEEL_PAGESCROLL = UINT_MAX;

function GET_KEYSTATE_WPARAM(wParam: WPARAM): Integer;
function GET_NCHITTEST_WPARAM(wParam: WPARAM): Shortint;
function GET_XBUTTON_WPARAM(wParam: WPARAM): Integer;

// XButton values are WORD flags//

const
  XBUTTON1 = $0001;
  XBUTTON2 = $0002;

// Were there to be an XBUTTON3, it's value would be 0x0004//

  WM_PARENTNOTIFY  = $0210;
  WM_ENTERMENULOOP = $0211;
  WM_EXITMENULOOP  = $0212;

  WM_NEXTMENU       = $0213;
  WM_SIZING         = $0214;
  WM_CAPTURECHANGED = $0215;
  WM_MOVING         = $0216;

  WM_POWERBROADCAST = $0218;

  PBT_APMQUERYSUSPEND = $0000;
  PBT_APMQUERYSTANDBY = $0001;

  PBT_APMQUERYSUSPENDFAILED = $0002;
  PBT_APMQUERYSTANDBYFAILED = $0003;

  PBT_APMSUSPEND = $0004;
  PBT_APMSTANDBY = $0005;

  PBT_APMRESUMECRITICAL = $0006;
  PBT_APMRESUMESUSPEND  = $0007;
  PBT_APMRESUMESTANDBY  = $0008;

  PBTF_APMRESUMEFROMFAILURE = $00000001;

  PBT_APMBATTERYLOW        = $0009;
  PBT_APMPOWERSTATUSCHANGE = $000A;

  PBT_APMOEMEVENT = $000B;
  PBT_APMRESUMEAUTOMATIC = $0012;

  WM_DEVICECHANGE = $0219;

  WM_MDICREATE      = $0220;
  WM_MDIDESTROY     = $0221;
  WM_MDIACTIVATE    = $0222;
  WM_MDIRESTORE     = $0223;
  WM_MDINEXT        = $0224;
  WM_MDIMAXIMIZE    = $0225;
  WM_MDITILE        = $0226;
  WM_MDICASCADE     = $0227;
  WM_MDIICONARRANGE = $0228;
  WM_MDIGETACTIVE   = $0229;

  WM_MDISETMENU     = $0230;
  WM_ENTERSIZEMOVE  = $0231;
  WM_EXITSIZEMOVE   = $0232;
  WM_DROPFILES      = $0233;
  WM_MDIREFRESHMENU = $0234;

  WM_IME_SETCONTEXT      = $0281;
  WM_IME_NOTIFY          = $0282;
  WM_IME_CONTROL         = $0283;
  WM_IME_COMPOSITIONFULL = $0284;
  WM_IME_SELECT          = $0285;
  WM_IME_CHAR            = $0286;
  WM_IME_REQUEST         = $0288;
  WM_IME_KEYDOWN         = $0290;
  WM_IME_KEYUP           = $0291;

  WM_MOUSEHOVER   = $02A1;
  WM_MOUSELEAVE   = $02A3;
  WM_NCMOUSEHOVER = $02A0;
  WM_NCMOUSELEAVE = $02A2;

  WM_WTSSESSION_CHANGE = $02B1;

  WM_TABLET_FIRST      = $02c0;
  WM_TABLET_LAST       = $02df;

  WM_CUT               = $0300;
  WM_COPY              = $0301;
  WM_PASTE             = $0302;
  WM_CLEAR             = $0303;
  WM_UNDO              = $0304;
  WM_RENDERFORMAT      = $0305;
  WM_RENDERALLFORMATS  = $0306;
  WM_DESTROYCLIPBOARD  = $0307;
  WM_DRAWCLIPBOARD     = $0308;
  WM_PAINTCLIPBOARD    = $0309;
  WM_VSCROLLCLIPBOARD  = $030A;
  WM_SIZECLIPBOARD     = $030B;
  WM_ASKCBFORMATNAME   = $030C;
  WM_CHANGECBCHAIN     = $030D;
  WM_HSCROLLCLIPBOARD  = $030E;
  WM_QUERYNEWPALETTE   = $030F;
  WM_PALETTEISCHANGING = $0310;
  WM_PALETTECHANGED    = $0311;
  WM_HOTKEY            = $0312;

  WM_PRINT       = $0317;
  WM_PRINTCLIENT = $0318;

  WM_APPCOMMAND = $0319;

  WM_THEMECHANGED  = $031A;

  WM_HANDHELDFIRST = $0358;
  WM_HANDHELDLAST  = $035F;

  WM_AFXFIRST = $0360;
  WM_AFXLAST  = $037F;

  WM_PENWINFIRST = $0380;
  WM_PENWINLAST  = $038F;

  WM_APP = $8000;

//
// NOTE: All Message Numbers below 0x0400 are RESERVED.
//
// Private Window Messages Start Here:
//

  WM_USER = $0400;

//  wParam for WM_SIZING message

  WMSZ_LEFT        = 1;
  WMSZ_RIGHT       = 2;
  WMSZ_TOP         = 3;
  WMSZ_TOPLEFT     = 4;
  WMSZ_TOPRIGHT    = 5;
  WMSZ_BOTTOM      = 6;
  WMSZ_BOTTOMLEFT  = 7;
  WMSZ_BOTTOMRIGHT = 8;

//
// WM_NCHITTEST and MOUSEHOOKSTRUCT Mouse Position Codes
//

  HTERROR       = DWORD(-2);
  HTTRANSPARENT = DWORD(-1);
  HTNOWHERE     = 0;
  HTCLIENT      = 1;
  HTCAPTION     = 2;
  HTSYSMENU     = 3;
  HTGROWBOX     = 4;
  HTSIZE        = HTGROWBOX;
  HTMENU        = 5;
  HTHSCROLL     = 6;
  HTVSCROLL     = 7;
  HTMINBUTTON   = 8;
  HTMAXBUTTON   = 9;
  HTLEFT        = 10;
  HTRIGHT       = 11;
  HTTOP         = 12;
  HTTOPLEFT     = 13;
  HTTOPRIGHT    = 14;
  HTBOTTOM      = 15;
  HTBOTTOMLEFT  = 16;
  HTBOTTOMRIGHT = 17;
  HTBORDER      = 18;
  HTREDUCE      = HTMINBUTTON;
  HTZOOM        = HTMAXBUTTON;
  HTSIZEFIRST   = HTLEFT;
  HTSIZELAST    = HTBOTTOMRIGHT;
  HTOBJECT      = 19;
  HTCLOSE       = 20;
  HTHELP        = 21;

//
// SendMessageTimeout values
//

  SMTO_NORMAL             = $0000;
  SMTO_BLOCK              = $0001;
  SMTO_ABORTIFHUNG        = $0002;
  SMTO_NOTIMEOUTIFNOTHUNG = $0008;

//
// WM_MOUSEACTIVATE Return Codes
//

  MA_ACTIVATE         = 1;
  MA_ACTIVATEANDEAT   = 2;
  MA_NOACTIVATE       = 3;
  MA_NOACTIVATEANDEAT = 4;

//
// WM_SETICON / WM_GETICON Type Codes
//

  ICON_SMALL  = 0;
  ICON_BIG    = 1;
  ICON_SMALL2 = 2;

function RegisterWindowMessageA(lpString: LPCSTR): UINT; stdcall;
function RegisterWindowMessageW(lpString: LPCWSTR): UINT; stdcall;

{$IFDEF UNICODE}
function RegisterWindowMessage(lpString: LPCWSTR): UINT; stdcall;
{$ELSE}
function RegisterWindowMessage(lpString: LPCSTR): UINT; stdcall;
{$ENDIF}

//
// WM_SIZE message wParam values
//

const
  SIZE_RESTORED  = 0;
  SIZE_MINIMIZED = 1;
  SIZE_MAXIMIZED = 2;
  SIZE_MAXSHOW   = 3;
  SIZE_MAXHIDE   = 4;

//
// Obsolete constant names
//

  SIZENORMAL     = SIZE_RESTORED;
  SIZEICONIC     = SIZE_MINIMIZED;
  SIZEFULLSCREEN = SIZE_MAXIMIZED;
  SIZEZOOMSHOW   = SIZE_MAXSHOW;
  SIZEZOOMHIDE   = SIZE_MAXHIDE;

//
// WM_WINDOWPOSCHANGING/CHANGED struct pointed to by lParam
//

type
  LPWINDOWPOS = ^WINDOWPOS;
  tagWINDOWPOS = record
    hwnd: HWND;
    hwndInsertAfter: HWND;
    x: Integer;
    y: Integer;
    cx: Integer;
    cy: Integer;
    flags: UINT;
  end;
  WINDOWPOS = tagWINDOWPOS;
  TWindowPos = WINDOWPOS;
  PWindowPos = LPWINDOWPOS;

//
// WM_NCCALCSIZE parameter structure
//

  LPNCCALCSIZE_PARAMS = ^NCCALCSIZE_PARAMS;
  NCCALCSIZE_PARAMS = record
    rgrc: array [0..2] of RECT;
    lppos: PWINDOWPOS;
  end;
  TNcCalcSizeParams = NCCALCSIZE_PARAMS;
  PNcCalcSizeParams = LPNCCALCSIZE_PARAMS;

//
// WM_NCCALCSIZE "window valid rect" return values
//

const
  WVR_ALIGNTOP    = $0010;
  WVR_ALIGNLEFT   = $0020;
  WVR_ALIGNBOTTOM = $0040;
  WVR_ALIGNRIGHT  = $0080;
  WVR_HREDRAW     = $0100;
  WVR_VREDRAW     = $0200;
  WVR_REDRAW      = (WVR_HREDRAW or WVR_VREDRAW);
  WVR_VALIDRECTS  = $0400;

//
// Key State Masks for Mouse Messages
//

  MK_LBUTTON  = $0001;
  MK_RBUTTON  = $0002;
  MK_SHIFT    = $0004;
  MK_CONTROL  = $0008;
  MK_MBUTTON  = $0010;
  MK_XBUTTON1 = $0020;
  MK_XBUTTON2 = $0040;

  TME_HOVER     = $00000001;
  TME_LEAVE     = $00000002;
  TME_NONCLIENT = $00000010;
  TME_QUERY     = $40000000;
  TME_CANCEL    = $80000000;

  HOVER_DEFAULT = $FFFFFFFF;

type
  LPTRACKMOUSEEVENT = ^_TRACKMOUSEEVENT;
  _TRACKMOUSEEVENT = record
    cbSize: DWORD;
    dwFlags: DWORD;
    hwndTrack: HWND;
    dwHoverTime: DWORD;
  end;
  //TRACKMOUSEEVENT = _TRACKMOUSEEVENT;
  TTrackMouseEvent = _TRACKMOUSEEVENT;
  PTrackMouseEvent = LPTRACKMOUSEEVENT;

function TrackMouseEvent(var lpEventTrack: TTrackMouseEvent): BOOL; stdcall;

//
// Window Styles
//

const
  WS_OVERLAPPED   = $00000000;
  WS_POPUP        = $80000000;
  WS_CHILD        = $40000000;
  WS_MINIMIZE     = $20000000;
  WS_VISIBLE      = $10000000;
  WS_DISABLED     = $08000000;
  WS_CLIPSIBLINGS = $04000000;
  WS_CLIPCHILDREN = $02000000;
  WS_MAXIMIZE     = $01000000;
  WS_CAPTION      = $00C00000; // WS_BORDER | WS_DLGFRAME
  WS_BORDER       = $00800000;
  WS_DLGFRAME     = $00400000;
  WS_VSCROLL      = $00200000;
  WS_HSCROLL      = $00100000;
  WS_SYSMENU      = $00080000;
  WS_THICKFRAME   = $00040000;
  WS_GROUP        = $00020000;
  WS_TABSTOP      = $00010000;

  WS_MINIMIZEBOX = $00020000;
  WS_MAXIMIZEBOX = $00010000;

  WS_TILED       = WS_OVERLAPPED;
  WS_ICONIC      = WS_MINIMIZE;
  WS_SIZEBOX     = WS_THICKFRAME;

//
// Common Window Styles
//

  WS_OVERLAPPEDWINDOW = (WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or
                         WS_THICKFRAME or WS_MINIMIZEBOX or WS_MAXIMIZEBOX);

  WS_POPUPWINDOW = (WS_POPUP or WS_BORDER or WS_SYSMENU);

  WS_CHILDWINDOW = (WS_CHILD);

  WS_TILEDWINDOW = WS_OVERLAPPEDWINDOW;

//
// Extended Window Styles
//

  WS_EX_DLGMODALFRAME  = $00000001;
  WS_EX_NOPARENTNOTIFY = $00000004;
  WS_EX_TOPMOST        = $00000008;
  WS_EX_ACCEPTFILES    = $00000010;
  WS_EX_TRANSPARENT    = $00000020;
  WS_EX_MDICHILD       = $00000040;
  WS_EX_TOOLWINDOW     = $00000080;
  WS_EX_WINDOWEDGE     = $00000100;
  WS_EX_CLIENTEDGE     = $00000200;
  WS_EX_CONTEXTHELP    = $00000400;

  WS_EX_RIGHT          = $00001000;
  WS_EX_LEFT           = $00000000;
  WS_EX_RTLREADING     = $00002000;
  WS_EX_LTRREADING     = $00000000;
  WS_EX_LEFTSCROLLBAR  = $00004000;
  WS_EX_RIGHTSCROLLBAR = $00000000;
  WS_EX_CONTROLPARENT  = $00010000;
  WS_EX_STATICEDGE     = $00020000;
  WS_EX_APPWINDOW      = $00040000;

  WS_EX_OVERLAPPEDWINDOW = (WS_EX_WINDOWEDGE or WS_EX_CLIENTEDGE);
  WS_EX_PALETTEWINDOW    = (WS_EX_WINDOWEDGE or WS_EX_TOOLWINDOW or WS_EX_TOPMOST);

  WS_EX_LAYERED = $00080000;

  WS_EX_NOINHERITLAYOUT = $00100000; // Disable inheritence of mirroring by children
  WS_EX_LAYOUTRTL       = $00400000; // Right to left mirroring

  WS_EX_COMPOSITED = $02000000;
  WS_EX_NOACTIVATE = $08000000;

//
// Class styles
//

  CS_VREDRAW         = $0001;
  CS_HREDRAW         = $0002;
  CS_DBLCLKS         = $0008;
  CS_OWNDC           = $0020;
  CS_CLASSDC         = $0040;
  CS_PARENTDC        = $0080;
  CS_NOCLOSE         = $0200;
  CS_SAVEBITS        = $0800;
  CS_BYTEALIGNCLIENT = $1000;
  CS_BYTEALIGNWINDOW = $2000;
  CS_GLOBALCLASS     = $4000;

  CS_IME = $00010000;
  CS_DROPSHADOW = $00020000;

// WM_PRINT flags//

  PRF_CHECKVISIBLE = $00000001;
  PRF_NONCLIENT    = $00000002;
  PRF_CLIENT       = $00000004;
  PRF_ERASEBKGND   = $00000008;
  PRF_CHILDREN     = $00000010;
  PRF_OWNED        = $00000020;

// 3D border styles//

  BDR_RAISEDOUTER = $0001;
  BDR_SUNKENOUTER = $0002;
  BDR_RAISEDINNER = $0004;
  BDR_SUNKENINNER = $0008;

  BDR_OUTER  = (BDR_RAISEDOUTER or BDR_SUNKENOUTER);
  BDR_INNER  = (BDR_RAISEDINNER or BDR_SUNKENINNER);
  BDR_RAISED = (BDR_RAISEDOUTER or BDR_RAISEDINNER);
  BDR_SUNKEN = (BDR_SUNKENOUTER or BDR_SUNKENINNER);

  EDGE_RAISED = (BDR_RAISEDOUTER or BDR_RAISEDINNER);
  EDGE_SUNKEN = (BDR_SUNKENOUTER or BDR_SUNKENINNER);
  EDGE_ETCHED = (BDR_SUNKENOUTER or BDR_RAISEDINNER);
  EDGE_BUMP   = (BDR_RAISEDOUTER or BDR_SUNKENINNER);

// Border flags//

  BF_LEFT   = $0001;
  BF_TOP    = $0002;
  BF_RIGHT  = $0004;
  BF_BOTTOM = $0008;

  BF_TOPLEFT     = (BF_TOP or BF_LEFT);
  BF_TOPRIGHT    = (BF_TOP or BF_RIGHT);
  BF_BOTTOMLEFT  = (BF_BOTTOM or BF_LEFT);
  BF_BOTTOMRIGHT = (BF_BOTTOM or BF_RIGHT);
  BF_RECT        = (BF_LEFT or BF_TOP or BF_RIGHT or BF_BOTTOM);

  BF_DIAGONAL = $0010;

// For diagonal lines, the BF_RECT flags specify the end point of the
// vector bounded by the rectangle parameter.

  BF_DIAGONAL_ENDTOPRIGHT    = (BF_DIAGONAL or BF_TOP or BF_RIGHT);
  BF_DIAGONAL_ENDTOPLEFT     = (BF_DIAGONAL or BF_TOP or BF_LEFT);
  BF_DIAGONAL_ENDBOTTOMLEFT  = (BF_DIAGONAL or BF_BOTTOM or BF_LEFT);
  BF_DIAGONAL_ENDBOTTOMRIGHT = (BF_DIAGONAL or BF_BOTTOM or BF_RIGHT);

  BF_MIDDLE = $0800; // Fill in the middle
  BF_SOFT   = $1000; // For softer buttons
  BF_ADJUST = $2000; // Calculate the space left over
  BF_FLAT   = $4000; // For flat rather than 3D borders
  BF_MONO   = $8000; // For monochrome borders

function DrawEdge(hdc: HDC; var qrc: RECT; edge, grfFlags: UINT): BOOL; stdcall;

// flags for DrawFrameControl//

const
  DFC_CAPTION   = 1;
  DFC_MENU      = 2;
  DFC_SCROLL    = 3;
  DFC_BUTTON    = 4;
  DFC_POPUPMENU = 5;

  DFCS_CAPTIONCLOSE   = $0000;
  DFCS_CAPTIONMIN     = $0001;
  DFCS_CAPTIONMAX     = $0002;
  DFCS_CAPTIONRESTORE = $0003;
  DFCS_CAPTIONHELP    = $0004;

  DFCS_MENUARROW           = $0000;
  DFCS_MENUCHECK           = $0001;
  DFCS_MENUBULLET          = $0002;
  DFCS_MENUARROWRIGHT      = $0004;
  DFCS_SCROLLUP            = $0000;
  DFCS_SCROLLDOWN          = $0001;
  DFCS_SCROLLLEFT          = $0002;
  DFCS_SCROLLRIGHT         = $0003;
  DFCS_SCROLLCOMBOBOX      = $0005;
  DFCS_SCROLLSIZEGRIP      = $0008;
  DFCS_SCROLLSIZEGRIPRIGHT = $0010;

  DFCS_BUTTONCHECK      = $0000;
  DFCS_BUTTONRADIOIMAGE = $0001;
  DFCS_BUTTONRADIOMASK  = $0002;
  DFCS_BUTTONRADIO      = $0004;
  DFCS_BUTTON3STATE     = $0008;
  DFCS_BUTTONPUSH       = $0010;

  DFCS_INACTIVE = $0100;
  DFCS_PUSHED   = $0200;
  DFCS_CHECKED  = $0400;

  DFCS_TRANSPARENT = $0800;
  DFCS_HOT         = $1000;

  DFCS_ADJUSTRECT = $2000;
  DFCS_FLAT       = $4000;
  DFCS_MONO       = $8000;

function DrawFrameControl(hdc: HDC; const lprc: RECT; uType, uState: UINT): BOOL; stdcall;

// flags for DrawCaption//

const
  DC_ACTIVE   = $0001;
  DC_SMALLCAP = $0002;
  DC_ICON     = $0004;
  DC_TEXT     = $0008;
  DC_INBUTTON = $0010;
  DC_GRADIENT = $0020;
  DC_BUTTONS  = $1000;

function DrawCaption(hwnd: HWND; hdc: HDC; const lprc: RECT; uFlags: UINT): BOOL; stdcall;

const
  IDANI_OPEN = 1;
  IDANI_CAPTION = 3;

function DrawAnimatedRects(hwnd: HWND; idAni: Integer; const lprcFrom, lprcTo: RECT): BOOL; stdcall;

//
// Predefined Clipboard Formats
//

const
  CF_TEXT         = 1;
  CF_BITMAP       = 2;
  CF_METAFILEPICT = 3;
  CF_SYLK         = 4;
  CF_DIF          = 5;
  CF_TIFF         = 6;
  CF_OEMTEXT      = 7;
  CF_DIB          = 8;
  CF_PALETTE      = 9;
  CF_PENDATA      = 10;
  CF_RIFF         = 11;
  CF_WAVE         = 12;
  CF_UNICODETEXT  = 13;
  CF_ENHMETAFILE  = 14;
  CF_HDROP        = 15;
  CF_LOCALE       = 16;
  CF_DIBV5        = 17;

  CF_MAX = 18;

  CF_OWNERDISPLAY    = $0080;
  CF_DSPTEXT         = $0081;
  CF_DSPBITMAP       = $0082;
  CF_DSPMETAFILEPICT = $0083;
  CF_DSPENHMETAFILE  = $008E;

//
// "Private" formats don't get GlobalFree()'d
//

  CF_PRIVATEFIRST = $0200;
  CF_PRIVATELAST  = $02FF;

//
// "GDIOBJ" formats do get DeleteObject()'d
//

  CF_GDIOBJFIRST = $0300;
  CF_GDIOBJLAST  = $03FF;

//
// Defines for the fVirt field of the Accelerator table structure.
//

  FVIRTKEY  = TRUE; // Assumed to be == TRUE
  FNOINVERT = $02;
  FSHIFT    = $04;
  FCONTROL  = $08;
  FALT      = $10;

type
  LPACCEL = ^ACCEL;
  tagACCEL = record
    fVirt: BYTE; // Also called the flags field//
    key: WORD;
    cmd: WORD;
  end;
  ACCEL = tagACCEL;
  TAccel = ACCEL;
  PAccel = LPACCEL;

  LPPAINTSTRUCT = ^PAINTSTRUCT;
  tagPAINTSTRUCT = record
    hdc: HDC;
    fErase: BOOL;
    rcPaint: RECT;
    fRestore: BOOL;
    fIncUpdate: BOOL;
    rgbReserved: array [0..31] of BYTE;
  end;
  PAINTSTRUCT = tagPAINTSTRUCT;
  NPPAINTSTRUCT = ^PAINTSTRUCT;
  TPaintStruct = PAINTSTRUCT;
  PPaintStruct = LPPAINTSTRUCT;

  LPCREATESTRUCTA = ^CREATESTRUCTA;
  tagCREATESTRUCTA = record
    lpCreateParams: LPVOID;
    hInstance: HINSTANCE;
    hMenu: HMENU;
    hwndParent: HWND;
    cy: Integer;
    cx: Integer;
    y: Integer;
    x: Integer;
    style: LONG;
    lpszName: LPCSTR;
    lpszClass: LPCSTR;
    dwExStyle: DWORD;
  end;
  CREATESTRUCTA = tagCREATESTRUCTA;
  TCreateStructA = CREATESTRUCTA;
  PCreateStructA = LPCREATESTRUCTA;

  LPCREATESTRUCTW = ^CREATESTRUCTW;
  tagCREATESTRUCTW = record
    lpCreateParams: LPVOID;
    hInstance: HINSTANCE;
    hMenu: HMENU;
    hwndParent: HWND;
    cy: Integer;
    cx: Integer;
    y: Integer;
    x: Integer;
    style: LONG;
    lpszName: LPCWSTR;
    lpszClass: LPCWSTR;
    dwExStyle: DWORD;
  end;
  CREATESTRUCTW = tagCREATESTRUCTW;
  TCreateStructW = CREATESTRUCTW;
  PCreateStructW = LPCREATESTRUCTW;

{$IFDEF UNICODE}
  CREATESTRUCT = CREATESTRUCTW;
  LPCREATESTRUCT = LPCREATESTRUCTW;
  TCreateStruct = TCreateStructW;
  PCreateStruct = PCreateStructW;
{$ELSE}
  CREATESTRUCT = CREATESTRUCTA;
  LPCREATESTRUCT = LPCREATESTRUCTA;
  TCreateStruct = TCreateStructA;
  PCreateStruct = PCreateStructA;
{$ENDIF}

//
// HCBT_CREATEWND parameters pointed to by lParam
//

type
  LPCBT_CREATEWNDA = ^CBT_CREATEWNDA;
  tagCBT_CREATEWNDA = record
    lpcs: LPCREATESTRUCTA;
    hwndInsertAfter: HWND;
  end;
  CBT_CREATEWNDA = tagCBT_CREATEWNDA;
  TCbtCreateWndA = CBT_CREATEWNDA;
  PCbtCreateWndA = LPCBT_CREATEWNDA;

//
// HCBT_CREATEWND parameters pointed to by lParam
//

  LPCBT_CREATEWNDW = ^CBT_CREATEWNDW;
  tagCBT_CREATEWNDW = record
    lpcs: LPCREATESTRUCTW;
    hwndInsertAfter: HWND;
  end;
  CBT_CREATEWNDW = tagCBT_CREATEWNDW;
  TCbtCreateWndW = CBT_CREATEWNDW;
  PCbtCreateWndW = LPCBT_CREATEWNDW;

{$IFDEF UNICODE}
  CBT_CREATEWND = CBT_CREATEWNDW;
  LPCBT_CREATEWND = LPCBT_CREATEWNDW;
{$ELSE}
  CBT_CREATEWND = CBT_CREATEWNDA;
  LPCBT_CREATEWND = LPCBT_CREATEWNDA;
{$ENDIF}

  LPWINDOWPLACEMENT = ^WINDOWPLACEMENT;
  tagWINDOWPLACEMENT = record
    length: UINT;
    flags: UINT;
    showCmd: UINT;
    ptMinPosition: POINT;
    ptMaxPosition: POINT;
    rcNormalPosition: RECT;
  end;
  WINDOWPLACEMENT = tagWINDOWPLACEMENT;
  TWindowPlacement = WINDOWPLACEMENT;
  PWindowPlacement = LPWINDOWPLACEMENT;

const
  WPF_SETMINPOSITION       = $0001;
  WPF_RESTORETOMAXIMIZED   = $0002;
  WPF_ASYNCWINDOWPLACEMENT = $0004;

type
  LPNMHDR = ^NMHDR;
  tagNMHDR = record
    hwndFrom: HWND;
    idFrom: UINT_PTR;
    code: UINT; // NM_ code
  end;
  NMHDR = tagNMHDR;
  TNmHdr = NMHDR;
  PNmHdr = LPNMHDR;

  LPSTYLESTRUCT = ^STYLESTRUCT;
  tagSTYLESTRUCT = record
    styleOld: DWORD;
    styleNew: DWORD;
  end;
  STYLESTRUCT = tagSTYLESTRUCT;
  TStyleStruct = STYLESTRUCT;
  PStyleStruct = LPSTYLESTRUCT;

//
// Owner draw control types
//

const
  ODT_MENU     = 1;
  ODT_LISTBOX  = 2;
  ODT_COMBOBOX = 3;
  ODT_BUTTON   = 4;
  ODT_STATIC   = 5;

//
// Owner draw actions
//

  ODA_DRAWENTIRE = $0001;
  ODA_SELECT     = $0002;
  ODA_FOCUS      = $0004;

//
// Owner draw state
//

  ODS_SELECTED     = $0001;
  ODS_GRAYED       = $0002;
  ODS_DISABLED     = $0004;
  ODS_CHECKED      = $0008;
  ODS_FOCUS        = $0010;
  ODS_DEFAULT      = $0020;
  ODS_COMBOBOXEDIT = $1000;
  ODS_HOTLIGHT     = $0040;
  ODS_INACTIVE     = $0080;
  ODS_NOACCEL      = $0100;
  ODS_NOFOCUSRECT  = $0200;

//
// MEASUREITEMSTRUCT for ownerdraw
//

type
  LPMEASUREITEMSTRUCT = ^MEASUREITEMSTRUCT;
  tagMEASUREITEMSTRUCT = record
    CtlType: UINT;
    CtlID: UINT;
    itemID: UINT;
    itemWidth: UINT;
    itemHeight: UINT;
    itemData: ULONG_PTR;
  end;
  MEASUREITEMSTRUCT = tagMEASUREITEMSTRUCT;
  TMeasureItemStruct = MEASUREITEMSTRUCT;
  PMeasureItemStruct = LPMEASUREITEMSTRUCT;

//
// DRAWITEMSTRUCT for ownerdraw
//

  LPDRAWITEMSTRUCT = ^DRAWITEMSTRUCT;
  tagDRAWITEMSTRUCT = record
    CtlType: UINT;
    CtlID: UINT;
    itemID: UINT;
    itemAction: UINT;
    itemState: UINT;
    hwndItem: HWND;
    hDC: HDC;
    rcItem: RECT;
    itemData: ULONG_PTR;
  end;
  DRAWITEMSTRUCT = tagDRAWITEMSTRUCT;
  TDrawItemStruct = DRAWITEMSTRUCT;
  PDrawItemStruct = LPDRAWITEMSTRUCT;

//
// DELETEITEMSTRUCT for ownerdraw
//

  LPDELETEITEMSTRUCT = ^DELETEITEMSTRUCT;
  tagDELETEITEMSTRUCT = record
    CtlType: UINT;
    CtlID: UINT;
    itemID: UINT;
    hwndItem: HWND;
    itemData: ULONG_PTR;
  end;
  DELETEITEMSTRUCT = tagDELETEITEMSTRUCT;
  TDeleteItemStruct = DELETEITEMSTRUCT;
  PDeleteItemStruct = LPDELETEITEMSTRUCT;

//
// COMPAREITEMSTUCT for ownerdraw sorting
//

  LPCOMPAREITEMSTRUCT = ^COMPAREITEMSTRUCT;
  tagCOMPAREITEMSTRUCT = record
    CtlType: UINT;
    CtlID: UINT;
    hwndItem: HWND;
    itemID1: UINT;
    itemData1: ULONG_PTR;
    itemID2: UINT;
    itemData2: ULONG_PTR;
    dwLocaleId: DWORD;
  end;
  COMPAREITEMSTRUCT = tagCOMPAREITEMSTRUCT;
  TCompareItemStruct = COMPAREITEMSTRUCT;
  PCompareItemStruct = LPCOMPAREITEMSTRUCT;

//
// Message Function Templates
//

function GetMessageA(lpMsg: LPMSG; hWnd: HWND; wMsgFilterMin, wMsgFilterMax: UINT): BOOL; stdcall;
function GetMessageW(lpMsg: LPMSG; hWnd: HWND; wMsgFilterMin, wMsgFilterMax: UINT): BOOL; stdcall;

{$IFDEF UNICODE}
function GetMessage(lpMsg: LPMSG; hWnd: HWND; wMsgFilterMin, wMsgFilterMax: UINT): BOOL; stdcall;
{$ELSE}
function GetMessage(lpMsg: LPMSG; hWnd: HWND; wMsgFilterMin, wMsgFilterMax: UINT): BOOL; stdcall;
{$ENDIF}

function TranslateMessage(lpMsg: LPMSG): BOOL; stdcall;

function DispatchMessageA(lpMsg: LPMSG): LRESULT; stdcall;
function DispatchMessageW(lpMsg: LPMSG): LRESULT; stdcall;

{$IFDEF UNICODE}
function DispatchMessage(lpMsg: LPMSG): LRESULT; stdcall;
{$ELSE}
function DispatchMessage(lpMsg: LPMSG): LRESULT; stdcall;
{$ENDIF}

function SetMessageQueue(cMessagesMax: Integer): BOOL; stdcall;

function PeekMessageA(var lpMsg: MSG; hWnd: HWND;
  wMsgFilterMin, wMsgFilterMax, wRemoveMsg: UINT): BOOL; stdcall;
function PeekMessageW(var lpMsg: MSG; hWnd: HWND;
  wMsgFilterMin, wMsgFilterMax, wRemoveMsg: UINT): BOOL; stdcall;

{$IFDEF UNICODE}
function PeekMessage(var lpMsg: MSG; hWnd: HWND;
  wMsgFilterMin, wMsgFilterMax, wRemoveMsg: UINT): BOOL; stdcall;
{$ELSE}
function PeekMessage(var lpMsg: MSG; hWnd: HWND;
  wMsgFilterMin, wMsgFilterMax, wRemoveMsg: UINT): BOOL; stdcall;
{$ENDIF}

//
// Queue status flags for GetQueueStatus() and MsgWaitForMultipleObjects()
//

const
  QS_KEY            = $0001;
  QS_MOUSEMOVE      = $0002;
  QS_MOUSEBUTTON    = $0004;
  QS_POSTMESSAGE    = $0008;
  QS_TIMER          = $0010;
  QS_PAINT          = $0020;
  QS_SENDMESSAGE    = $0040;
  QS_HOTKEY         = $0080;
  QS_ALLPOSTMESSAGE = $0100;
  QS_RAWINPUT       = $0400;

  QS_MOUSE = (QS_MOUSEMOVE or QS_MOUSEBUTTON);

  QS_INPUT = (QS_MOUSE or QS_KEY);

  QS_ALLEVENTS = (QS_INPUT or QS_POSTMESSAGE or QS_TIMER or QS_PAINT or QS_HOTKEY);

  QS_ALLINPUT = (QS_INPUT or QS_POSTMESSAGE or QS_TIMER or QS_PAINT or
    QS_HOTKEY or QS_SENDMESSAGE);

//
// PeekMessage() Options
//

const
  PM_NOREMOVE       = $0000;
  PM_REMOVE         = $0001;
  PM_NOYIELD        = $0002;
  PM_QS_INPUT       = (QS_INPUT shl 16);
  PM_QS_POSTMESSAGE = ((QS_POSTMESSAGE or QS_HOTKEY or QS_TIMER) shl 16);
  PM_QS_PAINT       = (QS_PAINT shl 16);
  PM_QS_SENDMESSAGE = (QS_SENDMESSAGE shl 16);

function RegisterHotKey(hWnd: HWND; id: Integer; fsModifiers, vk: UINT): BOOL; stdcall;

function UnregisterHotKey(hWnd: HWND; id: Integer): BOOL; stdcall;

const
  MOD_ALT     = $0001;
  MOD_CONTROL = $0002;
  MOD_SHIFT   = $0004;
  MOD_WIN     = $0008;

  IDHOT_SNAPWINDOW  = DWORD(-1); // SHIFT-PRINTSCRN
  IDHOT_SNAPDESKTOP = DWORD(-2); // PRINTSCRN

const
  ENDSESSION_LOGOFF = DWORD($80000000);

  EWX_LOGOFF      = 0;
  EWX_SHUTDOWN    = $00000001;
  EWX_REBOOT      = $00000002;
  EWX_FORCE       = $00000004;
  EWX_POWEROFF    = $00000008;
  EWX_FORCEIFHUNG = $00000010;

function ExitWindows(dwReserved: DWORD; uREserved: UINT): BOOL;

function ExitWindowsEx(uFlags: UINT; dwReserved: DWORD): BOOL; stdcall;

function SwapMouseButton(fSwap: BOOL): BOOL; stdcall;

function GetMessagePos: DWORD; stdcall;

function GetMessageTime: LONG; stdcall;

function GetMessageExtraInfo: LPARAM; stdcall;

function SetMessageExtraInfo(lParam: LPARAM): LPARAM; stdcall;

function SendMessageA(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function SendMessageW(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

{$IFDEF UNICODE}
function SendMessage(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
{$ELSE}
function SendMessage(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
{$ENDIF}

function SendMessageTimeoutA(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM;
  fuFlags, uTimeout: UINT; var lpdwResult: DWORD_PTR): LRESULT; stdcall;
function SendMessageTimeoutW(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM;
  fuFlags, uTimeout: UINT; var lpdwResult: DWORD_PTR): LRESULT; stdcall;

{$IFDEF UNICODE}
function SendMessageTimeout(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM;
  fuFlags, uTimeout: UINT; var lpdwResult: DWORD_PTR): LRESULT; stdcall;
{$ELSE}
function SendMessageTimeout(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM;
  fuFlags, uTimeout: UINT; var lpdwResult: DWORD_PTR): LRESULT; stdcall;
{$ENDIF}

function SendNotifyMessageA(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
function SendNotifyMessageW(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;

{$IFDEF UNICODE}
function SendNotifyMessage(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
{$ELSE}
function SendNotifyMessage(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
{$ENDIF}

function SendMessageCallbackA(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM;
  lpResultCallBack: SENDASYNCPROC; dwData: ULONG_PTR): BOOL; stdcall;
function SendMessageCallbackW(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM;
  lpResultCallBack: SENDASYNCPROC; dwData: ULONG_PTR): BOOL; stdcall;

{$IFDEF UNICODE}
function SendMessageCallback(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM;
  lpResultCallBack: SENDASYNCPROC; dwData: ULONG_PTR): BOOL; stdcall;
{$ELSE}
function SendMessageCallback(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM;
  lpResultCallBack: SENDASYNCPROC; dwData: ULONG_PTR): BOOL; stdcall;
{$ENDIF}

type
  BSMINFO = record
    cbSize: UINT;
    hdesk: HDESK;
    hwnd: HWND;
    luid: LUID;
  end;
  PBSMINFO = ^BSMINFO;
  TBsmInfo = BSMINFO;

function BroadcastSystemMessageExA(dwFlags: DWORD; lpwRecipients: LPDWORD; uiMessage: UINT;
  wParam: WPARAM; lParam: LPARAM; pBSMInfo: PBSMINFO): Longint; stdcall;
function BroadcastSystemMessageExW(dwFlags: DWORD; lpwRecipients: LPDWORD; uiMessage: UINT;
  wParam: WPARAM; lParam: LPARAM; pBSMInfo: PBSMINFO): Longint; stdcall;

{$IFDEF UNICODE}
function BroadcastSystemMessageEx(dwFlags: DWORD; lpwRecipients: LPDWORD; uiMessage: UINT;
  wParam: WPARAM; lParam: LPARAM; pBSMInfo: PBSMINFO): Longint; stdcall;
{$ELSE}
function BroadcastSystemMessageEx(dwFlags: DWORD; lpwRecipients: LPDWORD; uiMessage: UINT;
  wParam: WPARAM; lParam: LPARAM; pBSMInfo: PBSMINFO): Longint; stdcall;
{$ENDIF}

function BroadcastSystemMessageA(dwFlags: DWORD; lpdwRecipients: LPDWORD;
  uiMessage: UINT; wParam: WPARAM; lParam: LPARAM): Longint; stdcall;
function BroadcastSystemMessageW(dwFlags: DWORD; lpdwRecipients: LPDWORD;
  uiMessage: UINT; wParam: WPARAM; lParam: LPARAM): Longint; stdcall;

{$IFDEF UNICODE}
function BroadcastSystemMessage(dwFlags: DWORD; lpdwRecipients: LPDWORD;
  uiMessage: UINT; wParam: WPARAM; lParam: LPARAM): Longint; stdcall;
{$ELSE}
function BroadcastSystemMessage(dwFlags: DWORD; lpdwRecipients: LPDWORD;
  uiMessage: UINT; wParam: WPARAM; lParam: LPARAM): Longint; stdcall;
{$ENDIF}

//Broadcast Special Message Recipient list

const
  BSM_ALLCOMPONENTS      = $00000000;
  BSM_VXDS               = $00000001;
  BSM_NETDRIVER          = $00000002;
  BSM_INSTALLABLEDRIVERS = $00000004;
  BSM_APPLICATIONS       = $00000008;
  BSM_ALLDESKTOPS        = $00000010;

//Broadcast Special Message Flags

  BSF_QUERY              = $00000001;
  BSF_IGNORECURRENTTASK  = $00000002;
  BSF_FLUSHDISK          = $00000004;
  BSF_NOHANG             = $00000008;
  BSF_POSTMESSAGE        = $00000010;
  BSF_FORCEIFHUNG        = $00000020;
  BSF_NOTIMEOUTIFNOTHUNG = $00000040;
  BSF_ALLOWSFW           = $00000080;
  BSF_SENDNOTIFYMESSAGE  = $00000100;

  BSF_RETURNHDESK        = $00000200;
  BSF_LUID               = $00000400;

  BROADCAST_QUERY_DENY = $424D5144; // Return this value to deny a query.

// RegisterDeviceNotification

type
  HDEVNOTIFY = PVOID;
  PHDEVNOTIFY = ^HDEVNOTIFY;

const
  DEVICE_NOTIFY_WINDOW_HANDLE  = $00000000;
  DEVICE_NOTIFY_SERVICE_HANDLE = $00000001;
  DEVICE_NOTIFY_ALL_INTERFACE_CLASSES = $00000004;

function RegisterDeviceNotificationA(hRecipient: HANDLE; NotificationFilter: LPVOID;
  Flags: DWORD): HDEVNOTIFY; stdcall;
function RegisterDeviceNotificationW(hRecipient: HANDLE; NotificationFilter: LPVOID;
  Flags: DWORD): HDEVNOTIFY; stdcall;

{$IFDEF UNICODE}
function RegisterDeviceNotification(hRecipient: HANDLE; NotificationFilter: LPVOID;
  Flags: DWORD): HDEVNOTIFY; stdcall;
{$ELSE}
function RegisterDeviceNotification(hRecipient: HANDLE; NotificationFilter: LPVOID;
  Flags: DWORD): HDEVNOTIFY; stdcall;
{$ENDIF}

function UnregisterDeviceNotification(Handle: HDEVNOTIFY): BOOL; stdcall;

function PostMessageA(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
function PostMessageW(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;

{$IFDEF UNICODE}
function PostMessage(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
{$ELSE}
function PostMessage(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
{$ENDIF}

function PostThreadMessageA(idThread: DWORD; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
function PostThreadMessageW(idThread: DWORD; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;

{$IFDEF UNICODE}
function PostThreadMessage(idThread: DWORD; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
{$ELSE}
function PostThreadMessage(idThread: DWORD; Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall;
{$ENDIF}

function PostAppMessageA(idThread: DWORD; wMsg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL;

function PostAppMessageW(idThread: DWORD; wMsg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL;

{$IFDEF UNICODE}
function PostAppMessage(idThread: DWORD; wMsg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL;
{$ELSE}
function PostAppMessage(idThread: DWORD; wMsg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL;
{$ENDIF}

//
// Special HWND value for use with PostMessage() and SendMessage()
//

const
  HWND_BROADCAST = HWND($ffff);

  HWND_MESSAGE = HWND(-3);

function AttachThreadInput(idAttach, idAttachTo: DWORD; fAttach: BOOL): BOOL; stdcall;

function ReplyMessage(lResult: LRESULT): BOOL; stdcall;

function WaitMessage: BOOL; stdcall;

function WaitForInputIdle(hProcess: HANDLE; dwMilliseconds: DWORD): DWORD; stdcall;

function DefWindowProcA(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function DefWindowProcW(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

{$IFDEF UNICODE}
function DefWindowProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
{$ELSE}
function DefWindowProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
{$ENDIF}

procedure PostQuitMessage(nExitCode: Integer); stdcall;

function CallWindowProcA(lpPrevWndFunc: WNDPROC; hWnd: HWND; Msg: UINT;
  wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function CallWindowProcW(lpPrevWndFunc: WNDPROC; hWnd: HWND; Msg: UINT;
  wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

{$IFDEF UNICODE}
function CallWindowProc(lpPrevWndFunc: WNDPROC; hWnd: HWND; Msg: UINT;
  wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
{$ELSE}
function CallWindowProc(lpPrevWndFunc: WNDPROC; hWnd: HWND; Msg: UINT;
  wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
{$ENDIF}

function InSendMessage: BOOL; stdcall;

function InSendMessageEx(lpReserved: LPVOID): DWORD; stdcall;

//
// InSendMessageEx return value
//

const
  ISMEX_NOSEND   = $00000000;
  ISMEX_SEND     = $00000001;
  ISMEX_NOTIFY   = $00000002;
  ISMEX_CALLBACK = $00000004;
  ISMEX_REPLIED  = $00000008;

function GetDoubleClickTime: UINT; stdcall;

function SetDoubleClickTime(uInterval: UINT): BOOL; stdcall;

function RegisterClassA(const lpWndClass: WNDCLASSA): ATOM; stdcall;
function RegisterClassW(const lpWndClass: WNDCLASSW): ATOM; stdcall;

{$IFDEF UNICODE}
function RegisterClass(const lpWndClass: WNDCLASSW): ATOM; stdcall;
{$ELSE}
function RegisterClass(const lpWndClass: WNDCLASSA): ATOM; stdcall;
{$ENDIF}

function UnregisterClassA(lpClassName: LPCSTR; hInstance: HINSTANCE): BOOL; stdcall;
function UnregisterClassW(lpClassName: LPCWSTR; hInstance: HINSTANCE): BOOL; stdcall;

{$IFDEF UNICODE}
function UnregisterClass(lpClassName: LPCWSTR; hInstance: HINSTANCE): BOOL; stdcall;
{$ELSE}
function UnregisterClass(lpClassName: LPCSTR; hInstance: HINSTANCE): BOOL; stdcall;
{$ENDIF}

function GetClassInfoA(hInstance: HINSTANCE; lpClassName: LPCSTR;
  var lpWndClass: WNDCLASSA): BOOL; stdcall;
function GetClassInfoW(hInstance: HINSTANCE; lpClassName: LPCWSTR;
  var lpWndClass: WNDCLASSW): BOOL; stdcall;

{$IFDEF UNICODE}
function GetClassInfo(hInstance: HINSTANCE; lpClassName: LPCWSTR;
  var lpWndClass: WNDCLASSW): BOOL; stdcall;
{$ELSE}
function GetClassInfo(hInstance: HINSTANCE; lpClassName: LPCSTR;
  var lpWndClass: WNDCLASSA): BOOL; stdcall;
{$ENDIF}

function RegisterClassExA(const lpwcx: WNDCLASSEXA): ATOM; stdcall;
function RegisterClassExW(const lpwcx: WNDCLASSEXW): ATOM; stdcall;

{$IFDEF UNICODE}
function RegisterClassEx(const lpwcx: WNDCLASSEXW): ATOM; stdcall;
{$ELSE}
function RegisterClassEx(const lpwcx: WNDCLASSEXA): ATOM; stdcall;
{$ENDIF}

function GetClassInfoExA(hinst: HINSTANCE; lpszClass: LPCSTR; var lpwcx: WNDCLASSEXA): BOOL; stdcall;
function GetClassInfoExW(hinst: HINSTANCE; lpszClass: LPCWSTR; var lpwcx: WNDCLASSEXW): BOOL; stdcall;

{$IFDEF UNICODE}
function GetClassInfoEx(hinst: HINSTANCE; lpszClass: LPCWSTR; var lpwcx: WNDCLASSEXW): BOOL; stdcall;
{$ELSE}
function GetClassInfoEx(hinst: HINSTANCE; lpszClass: LPCSTR; var lpwcx: WNDCLASSEXA): BOOL; stdcall;
{$ENDIF}

const
  CW_USEDEFAULT = Integer($80000000);

//
// Special value for CreateWindow, et al.
//

const
  HWND_DESKTOP = HWND(0);

type
  PREGISTERCLASSNAMEW = function (p: LPCWSTR): LongBool; stdcall;

function CreateWindowExA(dwExStyle: DWORD; lpClassName, lpWindowName: LPCSTR;
  dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: HWND;
  hMenu: HMENU; hInstance: HINSTANCE; lpParam: LPVOID): HWND; stdcall;
function CreateWindowExW(dwExStyle: DWORD; lpClassName, lpWindowName: LPCWSTR;
  dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: HWND;
  hMenu: HMENU; hInstance: HINSTANCE; lpParam: LPVOID): HWND; stdcall;

{$IFDEF UNICODE}
function CreateWindowEx(dwExStyle: DWORD; lpClassName, lpWindowName: LPCWSTR;
  dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: HWND;
  hMenu: HMENU; hInstance: HINSTANCE; lpParam: LPVOID): HWND; stdcall;
{$ELSE}
function CreateWindowEx(dwExStyle: DWORD; lpClassName, lpWindowName: LPCSTR;
  dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: HWND;
  hMenu: HMENU; hInstance: HINSTANCE; lpParam: LPVOID): HWND; stdcall;
{$ENDIF}

function CreateWindowA(lpClassName, lpWindowName: LPCSTR; dwStyle: DWORD;
  x, y, nWidth, nHeight: Integer; hWndParent: HWND; hMenu: HMENU;
  hInstance: HINSTANCE; lpParam: LPVOID): HWND;

function CreateWindowW(lpClassName, lpWindowName: LPCWSTR; dwStyle: DWORD;
  x, y, nWidth, nHeight: Integer; hWndParent: HWND; hMenu: HMENU;
  hInstance: HINSTANCE; lpParam: LPVOID): HWND;

{$IFDEF UNICODE}
function CreateWindow(lpClassName, lpWindowName: LPCWSTR; dwStyle: DWORD;
  x, y, nWidth, nHeight: Integer; hWndParent: HWND; hMenu: HMENU;
  hInstance: HINSTANCE; lpParam: LPVOID): HWND;
{$ELSE}
function CreateWindow(lpClassName, lpWindowName: LPCSTR; dwStyle: DWORD;
  x, y, nWidth, nHeight: Integer; hWndParent: HWND; hMenu: HMENU;
  hInstance: HINSTANCE; lpParam: LPVOID): HWND;
{$ENDIF}

function IsWindow(hWnd: HWND): BOOL; stdcall;

function IsMenu(hMenu: HMENU): BOOL; stdcall;

function IsChild(hWndParent, hWnd: HWND): BOOL; stdcall;

function DestroyWindow(hWnd: HWND): BOOL; stdcall;

function ShowWindow(hWnd: HWND; nCmdShow: Integer): BOOL; stdcall;

function AnimateWindow(hWnd: HWND; dwTime, dwFlags: DWORD): BOOL; stdcall;

function UpdateLayeredWindow(hWnd: HWND; hdcDst: HDC; pptDst: LPPOINT;
  psize: LPSIZE; hdcSrc: HDC; pptSrc: LPPOINT; crKey: COLORREF;
  pblend: LPBLENDFUNCTION; dwFlags: DWORD): BOOL; stdcall;

function GetLayeredWindowAttributes(hwnd: HWND; pcrKey: LPCOLORREF; pbAlpha: LPBYTE;
  pdwFlags: LPWORD): BOOL; stdcall;

const
  PW_CLIENTONLY = $00000001;

function PrintWindow(hwnd: HWND; hdcBlt: HDC; nFlags: UINT): BOOL; stdcall;

function SetLayeredWindowAttributes(hwnd: HWND; crKey: COLORREF; bAlpha: BYTE;
  dwFlags: DWORD): BOOL; stdcall;

const
  LWA_COLORKEY = $00000001;
  LWA_ALPHA    = $00000002;

  ULW_COLORKEY = $00000001;
  ULW_ALPHA    = $00000002;
  ULW_OPAQUE   = $00000004;

function ShowWindowAsync(hWnd: HWND; nCmdShow: Integer): BOOL; stdcall;

function FlashWindow(hWnd: HWND; bInvert: BOOL): BOOL; stdcall;

type
  PFLASH_INFO = ^FLASH_INFO;
  FLASH_INFO = record
    cbSize: UINT;
    hwnd: HWND;
    dwFlags: DWORD;
    uCount: UINT;
    dwTimeout: DWORD;
  end;
  TFlashInfo = FLASH_INFO;
  PFlashInfo = PFLASH_INFO;

function FlashWindowEx(var pfwi: FLASH_INFO): BOOL; stdcall;

const
  FLASHW_STOP      = 0;
  FLASHW_CAPTION   = $00000001;
  FLASHW_TRAY      = $00000002;
  FLASHW_ALL       = (FLASHW_CAPTION or FLASHW_TRAY);
  FLASHW_TIMER     = $00000004;
  FLASHW_TIMERNOFG = $0000000C;

function ShowOwnedPopups(hWnd: HWND; fShow: BOOL): BOOL; stdcall;

function OpenIcon(hWnd: HWND): BOOL; stdcall;

function CloseWindow(hWnd: HWND): BOOL; stdcall;

function MoveWindow(hWnd: HWND; X, Y, nWidth, nHeight: Integer; bRepaint: BOOL): BOOL; stdcall;

function SetWindowPos(hWnd, hWndInsertAfter: HWND; X, Y, cx, cy: Integer;
  uFlags: UINT): BOOL; stdcall;

function GetWindowPlacement(hWnd: HWND; var lpwndpl: WINDOWPLACEMENT): BOOL; stdcall;

function SetWindowPlacement(hWnd: HWND; const lpwndpl: WINDOWPLACEMENT): BOOL; stdcall;

function BeginDeferWindowPos(nNumWindows: Integer): HDWP; stdcall;

function DeferWindowPos(hWinPosInfo: HDWP; hWnd, hWndInsertAfter: HWND;
  x, y, cx, cy: Integer; uFlags: UINT): HDWP; stdcall;

function EndDeferWindowPos(hWinPosInfo: HDWP): BOOL; stdcall;

function IsWindowVisible(hWnd: HWND): BOOL; stdcall;

function IsIconic(hWnd: HWND): BOOL; stdcall;

function AnyPopup: BOOL; stdcall;

function BringWindowToTop(hWnd: HWND): BOOL; stdcall;

function IsZoomed(hWnd: HWND): BOOL; stdcall;

//
// SetWindowPos Flags
//

const
  SWP_NOSIZE         = $0001;
  SWP_NOMOVE         = $0002;
  SWP_NOZORDER       = $0004;
  SWP_NOREDRAW       = $0008;
  SWP_NOACTIVATE     = $0010;
  SWP_FRAMECHANGED   = $0020; // The frame changed: send WM_NCCALCSIZE
  SWP_SHOWWINDOW     = $0040;
  SWP_HIDEWINDOW     = $0080;
  SWP_NOCOPYBITS     = $0100;
  SWP_NOOWNERZORDER  = $0200; // Don't do owner Z ordering
  SWP_NOSENDCHANGING = $0400; // Don't send WM_WINDOWPOSCHANGING

  SWP_DRAWFRAME    = SWP_FRAMECHANGED;
  SWP_NOREPOSITION = SWP_NOOWNERZORDER;

  SWP_DEFERERASE     = $2000;
  SWP_ASYNCWINDOWPOS = $4000;

  HWND_TOP       = HWND(0);
  HWND_BOTTOM    = HWND(1);
  HWND_TOPMOST   = HWND(-1);
  HWND_NOTOPMOST = HWND(-2);

//
// WARNING:
// The following structures must NOT be DWORD padded because they are
// followed by strings, etc that do not have to be DWORD aligned.
//

// #include <pshpack2.h>

//
// original NT 32 bit dialog template:
//

type
  DLGTEMPLATE = packed record
    style: DWORD;
    dwExtendedStyle: DWORD;
    cdit: WORD;
    x: short;
    y: short;
    cx: short;
    cy: short;
  end;
  TDlgTemplate = DLGTEMPLATE;

  LPDLGTEMPLATEA = ^DLGTEMPLATE;
  LPDLGTEMPLATEW = ^DLGTEMPLATE;

  LPCDLGTEMPLATEA = ^DLGTEMPLATE;
  LPCDLGTEMPLATEW = ^DLGTEMPLATE;

{$IFDEF UNICODE}
  LPDLGTEMPLATE = LPDLGTEMPLATEW;
  LPCDLGTEMPLATE = LPCDLGTEMPLATEW;
{$ELSE}
  LPDLGTEMPLATE = LPDLGTEMPLATEA;
  LPCDLGTEMPLATE = LPCDLGTEMPLATEA;
{$ENDIF}

//
// 32 bit Dialog item template.
//

  DLGITEMTEMPLATE = packed record
    style: DWORD;
    dwExtendedStyle: DWORD;
    x: short;
    y: short;
    cx: short;
    cy: short;
    id: WORD;
  end;
  TDlgItemTemplate = DLGITEMTEMPLATE;

  PDLGITEMTEMPLATEA = ^DLGITEMTEMPLATE;
  PDLGITEMTEMPLATEW = ^DLGITEMTEMPLATE;

  LPDLGITEMTEMPLATEA = ^DLGITEMTEMPLATE;
  LPDLGITEMTEMPLATEW = ^DLGITEMTEMPLATE;

{$IFDEF UNICODE}
  PDLGITEMTEMPLATE = PDLGITEMTEMPLATEW;
  LPDLGITEMTEMPLATE = PDLGITEMTEMPLATEW;
{$ELSE}
  PDLGITEMTEMPLATE = PDLGITEMTEMPLATEA;
  LPDLGITEMTEMPLATE = PDLGITEMTEMPLATEA;
{$ENDIF}

// #include <poppack.h> // Resume normal packing//

function CreateDialogParamA(hInstance: HINSTANCE; lpTemplateName: LPCSTR;
  hWndParent: HWND; lpDialogFunc: DLGPROC; dwInitParam: LPARAM): HWND; stdcall;
function CreateDialogParamW(hInstance: HINSTANCE; lpTemplateName: LPCWSTR;
  hWndParent: HWND; lpDialogFunc: DLGPROC; dwInitParam: LPARAM): HWND; stdcall;

{$IFDEF UNICODE}
function CreateDialogParam(hInstance: HINSTANCE; lpTemplateName: LPCWSTR;
  hWndParent: HWND; lpDialogFunc: DLGPROC; dwInitParam: LPARAM): HWND; stdcall;
{$ELSE}
function CreateDialogParam(hInstance: HINSTANCE; lpTemplateName: LPCSTR;
  hWndParent: HWND; lpDialogFunc: DLGPROC; dwInitParam: LPARAM): HWND; stdcall;
{$ENDIF}

function CreateDialogIndirectParamA(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE;
  hWndParent: HWND; lpDialogFunc: DLGPROC; dwInitParam: LPARAM): HWND; stdcall;
function CreateDialogIndirectParamW(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE;
  hWndParent: HWND; lpDialogFunc: DLGPROC; dwInitParam: LPARAM): HWND; stdcall;

{$IFDEF UNICODE}
function CreateDialogIndirectParam(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE;
  hWndParent: HWND; lpDialogFunc: DLGPROC; dwInitParam: LPARAM): HWND; stdcall;
{$ELSE}
function CreateDialogIndirectParam(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE;
  hWndParent: HWND; lpDialogFunc: DLGPROC; dwInitParam: LPARAM): HWND; stdcall;
{$ENDIF}

function CreateDialogA(hInstance: HINSTANCE; lpName: LPCSTR; hWndParent: HWND;
  lpDialogFunc: DLGPROC): HWND;
function CreateDialogW(hInstance: HINSTANCE; lpName: LPCWSTR; hWndParent: HWND;
  lpDialogFunc: DLGPROC): HWND;

{$IFDEF UNICODE}
function CreateDialog(hInstance: HINSTANCE; lpName: LPCWSTR; hWndParent: HWND;
  lpDialogFunc: DLGPROC): HWND;
{$ELSE}
function CreateDialog(hInstance: HINSTANCE; lpName: LPCSTR; hWndParent: HWND;
  lpDialogFunc: DLGPROC): HWND;
{$ENDIF}

function CreateDialogIndirectA(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE;
  hWndParent: HWND; lpDialogFunc: DLGPROC): HWND;
function CreateDialogIndirectW(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE;
  hWndParent: HWND; lpDialogFunc: DLGPROC): HWND;

{$IFDEF UNICODE}
function CreateDialogIndirect(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE;
  hWndParent: HWND; lpDialogFunc: DLGPROC): HWND;
{$ELSE}
function CreateDialogIndirect(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE;
  hWndParent: HWND; lpDialogFunc: DLGPROC): HWND;
{$ENDIF}

function DialogBoxParamA(hInstance: HINSTANCE; lpTemplateName: LPCSTR;
  hWndParent: HWND; lpDialogFunc: DLGPROC; dwInitParam: LPARAM): INT_PTR; stdcall;
function DialogBoxParamW(hInstance: HINSTANCE; lpTemplateName: LPCWSTR;
  hWndParent: HWND; lpDialogFunc: DLGPROC; dwInitParam: LPARAM): INT_PTR; stdcall;

{$IFDEF UNICODE}
function DialogBoxParam(hInstance: HINSTANCE; lpTemplateName: LPCWSTR;
  hWndParent: HWND; lpDialogFunc: DLGPROC; dwInitParam: LPARAM): INT_PTR; stdcall;
{$ELSE}
function DialogBoxParam(hInstance: HINSTANCE; lpTemplateName: LPCSTR;
  hWndParent: HWND; lpDialogFunc: DLGPROC; dwInitParam: LPARAM): INT_PTR; stdcall;
{$ENDIF}

function DialogBoxIndirectParamA(hInstance: HINSTANCE;
  const hDialogTemplate: DLGTEMPLATE; hWndParent: HWND; lpDialogFunc: DLGPROC;
  dwInitParam: LPARAM): INT_PTR; stdcall;
function DialogBoxIndirectParamW(hInstance: HINSTANCE;
  const hDialogTemplate: DLGTEMPLATE; hWndParent: HWND; lpDialogFunc: DLGPROC;
  dwInitParam: LPARAM): INT_PTR; stdcall;

{$IFDEF UNICODE}
function DialogBoxIndirectParam(hInstance: HINSTANCE;
  const hDialogTemplate: DLGTEMPLATE; hWndParent: HWND; lpDialogFunc: DLGPROC;
  dwInitParam: LPARAM): INT_PTR; stdcall;
{$ELSE}
function DialogBoxIndirectParam(hInstance: HINSTANCE;
  const hDialogTemplate: DLGTEMPLATE; hWndParent: HWND; lpDialogFunc: DLGPROC;
  dwInitParam: LPARAM): INT_PTR; stdcall;
{$ENDIF}

function DialogBoxA(hInstance: HINSTANCE; lpTemplate: LPCSTR; hWndParent: HWND;
  lpDialogFunc: DLGPROC): INT_PTR;

function DialogBoxW(hInstance: HINSTANCE; lpTemplate: LPCWSTR; hWndParent: HWND;
  lpDialogFunc: DLGPROC): INT_PTR;

{$IFDEF UNICODE}
function DialogBox(hInstance: HINSTANCE; lpTemplate: LPCWSTR; hWndParent: HWND;
  lpDialogFunc: DLGPROC): INT_PTR;
{$ELSE}
function DialogBox(hInstance: HINSTANCE; lpTemplate: LPCSTR; hWndParent: HWND;
  lpDialogFunc: DLGPROC): INT_PTR;
{$ENDIF}

function DialogBoxIndirectA(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE;
  hWndParent: HWND; lpDialogFunc: DLGPROC): INT_PTR;

function DialogBoxIndirectW(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE;
  hWndParent: HWND; lpDialogFunc: DLGPROC): INT_PTR;

{$IFDEF UNICODE}
function DialogBoxIndirect(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE;
  hWndParent: HWND; lpDialogFunc: DLGPROC): INT_PTR;
{$ELSE}
function DialogBoxIndirect(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE;
  hWndParent: HWND; lpDialogFunc: DLGPROC): INT_PTR;
{$ENDIF}

function EndDialog(hDlg: HWND; nResult: INT_PTR): BOOL; stdcall;

function GetDlgItem(hDlg: HWND; nIDDlgItem: Integer): HWND; stdcall;

function SetDlgItemInt(hDlg: HWND; nIDDlgItem: Integer; uValue: UINT; bSigned: BOOL): BOOL; stdcall;

function GetDlgItemInt(hDlg: HWND; nIDDlgItem: Integer; lpTranslated: LPBOOL;
  bSigned: BOOL): UINT; stdcall;

function SetDlgItemTextA(hDlg: HWND; nIDDlgItem: Integer; lpString: LPCSTR): BOOL; stdcall;
function SetDlgItemTextW(hDlg: HWND; nIDDlgItem: Integer; lpString: LPCWSTR): BOOL; stdcall;

{$IFDEF UNICODE}
function SetDlgItemText(hDlg: HWND; nIDDlgItem: Integer; lpString: LPCWSTR): BOOL; stdcall;
{$ELSE}
function SetDlgItemText(hDlg: HWND; nIDDlgItem: Integer; lpString: LPCSTR): BOOL; stdcall;
{$ENDIF}

function GetDlgItemTextA(hDlg: HWND; nIDDlgItem: Integer; lpString: LPSTR;
  nMaxCount: Integer): UINT; stdcall;
function GetDlgItemTextW(hDlg: HWND; nIDDlgItem: Integer; lpString: LPWSTR;
  nMaxCount: Integer): UINT; stdcall;

{$IFDEF UNICODE}
function GetDlgItemText(hDlg: HWND; nIDDlgItem: Integer; lpString: LPWSTR;
  nMaxCount: Integer): UINT; stdcall;
{$ELSE}
function GetDlgItemText(hDlg: HWND; nIDDlgItem: Integer; lpString: LPSTR;
  nMaxCount: Integer): UINT; stdcall;
{$ENDIF}

function CheckDlgButton(hDlg: HWND; nIDButton: Integer; uCheck: UINT): BOOL; stdcall;

function CheckRadioButton(hDlg: HWND; nIDFirstButton, nIDLastButton: Integer;
  nIDCheckButton: Integer): BOOL; stdcall;

function IsDlgButtonChecked(hDlg: HWND; nIDButton: Integer): UINT; stdcall;

function SendDlgItemMessageA(hDlg: HWND; nIDDlgItem: Integer; Msg: UINT;
  wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function SendDlgItemMessageW(hDlg: HWND; nIDDlgItem: Integer; Msg: UINT;
  wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

{$IFDEF UNICODE}
function SendDlgItemMessage(hDlg: HWND; nIDDlgItem: Integer; Msg: UINT;
  wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
{$ELSE}
function SendDlgItemMessage(hDlg: HWND; nIDDlgItem: Integer; Msg: UINT;
  wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
{$ENDIF}

function GetNextDlgGroupItem(hDlg: HWND; hCtl: HWND; bPrevious: BOOL): HWND; stdcall;

function GetNextDlgTabItem(hDlg: HWND; hCtl: HWND; bPrevious: BOOL): HWND; stdcall;

function GetDlgCtrlID(hWnd: HWND): Integer; stdcall;

function GetDialogBaseUnits: Longint; stdcall;

function DefDlgProcA(hDlg: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function DefDlgProcW(hDlg: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

{$IFDEF UNICODE}
function DefDlgProc(hDlg: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
{$ELSE}
function DefDlgProc(hDlg: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
{$ENDIF}

//
// Window extra byted needed for private dialog classes.
//

const
  DLGWINDOWEXTRA = 30;

function CallMsgFilterA(lpMsg: LPMSG; nCode: Integer): BOOL; stdcall;
function CallMsgFilterW(lpMsg: LPMSG; nCode: Integer): BOOL; stdcall;

{$IFDEF UNICODE}
function CallMsgFilter(lpMsg: LPMSG; nCode: Integer): BOOL; stdcall;
{$ELSE}
function CallMsgFilter(lpMsg: LPMSG; nCode: Integer): BOOL; stdcall;
{$ENDIF}

//
// Clipboard Manager Functions
//

function OpenClipboard(hWndNewOwner: HWND): BOOL; stdcall;

function CloseClipboard: BOOL; stdcall;

function GetClipboardSequenceNumber: DWORD; stdcall;

function GetClipboardOwner: HWND; stdcall;

function SetClipboardViewer(hWndNewViewer: HWND): HWND; stdcall;

function GetClipboardViewer: HWND; stdcall;

function ChangeClipboardChain(hWndRemove, hWndNewNext: HWND): BOOL; stdcall;

function SetClipboardData(uFormat: UINT; hMem: HANDLE): HANDLE; stdcall;

function GetClipboardData(uFormat: UINT): HANDLE; stdcall;

function RegisterClipboardFormatA(lpszFormat: LPCSTR): UINT; stdcall;
function RegisterClipboardFormatW(lpszFormat: LPCWSTR): UINT; stdcall;

{$IFDEF UNICODE}
function RegisterClipboardFormat(lpszFormat: LPCWSTR): UINT; stdcall;
{$ELSE}
function RegisterClipboardFormat(lpszFormat: LPCSTR): UINT; stdcall;
{$ENDIF}

function CountClipboardFormats: Integer; stdcall;

function EnumClipboardFormats(format: UINT): UINT; stdcall;

function GetClipboardFormatNameA(format: UINT; lpszFormatName: LPSTR;
  cchMaxCount: Integer): Integer; stdcall;
function GetClipboardFormatNameW(format: UINT; lpszFormatName: LPWSTR;
  cchMaxCount: Integer): Integer; stdcall;

{$IFDEF UNICODE}
function GetClipboardFormatName(format: UINT; lpszFormatName: LPWSTR;
  cchMaxCount: Integer): Integer; stdcall;
{$ELSE}
function GetClipboardFormatName(format: UINT; lpszFormatName: LPSTR;
  cchMaxCount: Integer): Integer; stdcall;
{$ENDIF}

function EmptyClipboard: BOOL; stdcall;

function IsClipboardFormatAvailable(format: UINT): BOOL; stdcall;

function GetPriorityClipboardFormat(paFormatPriorityList: PUINT; cFormats: Integer): Integer; stdcall;

function GetOpenClipboardWindow: HWND; stdcall;

//
// Character Translation Routines
//

function CharToOemA(lpszSrc: LPCSTR; lpszDst: LPSTR): BOOL; stdcall;
function CharToOemW(lpszSrc: LPCWSTR; lpszDst: LPSTR): BOOL; stdcall;

{$IFDEF UNICODE}
function CharToOem(lpszSrc: LPCWSTR; lpszDst: LPSTR): BOOL; stdcall;
{$ELSE}
function CharToOem(lpszSrc: LPCSTR; lpszDst: LPSTR): BOOL; stdcall;
{$ENDIF}

function OemToCharA(lpszSrc: LPCSTR; lpszDst: LPSTR): BOOL; stdcall;
function OemToCharW(lpszSrc: LPCSTR; lpszDst: LPWSTR): BOOL; stdcall;

{$IFDEF UNICODE}
function OemToChar(lpszSrc: LPCSTR; lpszDst: LPWSTR): BOOL; stdcall;
{$ELSE}
function OemToChar(lpszSrc: LPCSTR; lpszDst: LPSTR): BOOL; stdcall;
{$ENDIF}

function CharToOemBuffA(lpszSrc: LPCSTR; lpszDst: LPSTR; cchDstLength: DWORD): BOOL; stdcall;
function CharToOemBuffW(lpszSrc: LPCWSTR; lpszDst: LPSTR; cchDstLength: DWORD): BOOL; stdcall;

{$IFDEF UNICODE}
function CharToOemBuff(lpszSrc: LPCWSTR; lpszDst: LPSTR; cchDstLength: DWORD): BOOL; stdcall;
{$ELSE}
function CharToOemBuff(lpszSrc: LPCSTR; lpszDst: LPSTR; cchDstLength: DWORD): BOOL; stdcall;
{$ENDIF}

function OemToCharBuffA(lpszSrc: LPCSTR; lpszDst: LPSTR; cchDstLength: DWORD): BOOL; stdcall;
function OemToCharBuffW(lpszSrc: LPCSTR; lpszDst: LPWSTR; cchDstLength: DWORD): BOOL; stdcall;

{$IFDEF UNICODE}
function OemToCharBuff(lpszSrc: LPCSTR; lpszDst: LPWSTR; cchDstLength: DWORD): BOOL; stdcall;
{$ELSE}
function OemToCharBuff(lpszSrc: LPCSTR; lpszDst: LPSTR; cchDstLength: DWORD): BOOL; stdcall;
{$ENDIF}

function CharUpperA(lpsz: LPSTR): LPSTR; stdcall;
function CharUpperW(lpsz: LPWSTR): LPWSTR; stdcall;

{$IFDEF UNICODE}
function CharUpper(lpsz: LPWSTR): LPWSTR; stdcall;
{$ELSE}
function CharUpper(lpsz: LPSTR): LPSTR; stdcall;
{$ENDIF}

function CharUpperBuffA(lpsz: LPSTR; cchLength: DWORD): DWORD; stdcall;
function CharUpperBuffW(lpsz: LPWSTR; cchLength: DWORD): DWORD; stdcall;

{$IFDEF UNICODE}
function CharUpperBuff(lpsz: LPWSTR; cchLength: DWORD): DWORD; stdcall;
{$ELSE}
function CharUpperBuff(lpsz: LPSTR; cchLength: DWORD): DWORD; stdcall;
{$ENDIF}

function CharLowerA(lpsz: LPSTR): LPSTR; stdcall;
function CharLowerW(lpsz: LPWSTR): LPWSTR; stdcall;

{$IFDEF UNICODE}
function CharLower(lpsz: LPWSTR): LPWSTR; stdcall;
{$ELSE}
function CharLower(lpsz: LPSTR): LPSTR; stdcall;
{$ENDIF}

function CharLowerBuffA(lpsz: LPSTR; cchLength: DWORD): DWORD; stdcall;
function CharLowerBuffW(lpsz: LPWSTR; cchLength: DWORD): DWORD; stdcall;

{$IFDEF UNICODE}
function CharLowerBuff(lpsz: LPWSTR; cchLength: DWORD): DWORD; stdcall;
{$ELSE}
function CharLowerBuff(lpsz: LPSTR; cchLength: DWORD): DWORD; stdcall;
{$ENDIF}

function CharNextA(lpsz: LPCSTR): LPSTR; stdcall;
function CharNextW(lpsz: LPCWSTR): LPWSTR; stdcall;

{$IFDEF UNICODE}
function CharNext(lpsz: LPCWSTR): LPWSTR; stdcall;
{$ELSE}
function CharNext(lpsz: LPCSTR): LPSTR; stdcall;
{$ENDIF}

function CharPrevA(lpszStart: LPCSTR; lpszCurrent: LPCSTR): LPSTR; stdcall;
function CharPrevW(lpszStart: LPCWSTR; lpszCurrent: LPCWSTR): LPWSTR; stdcall;

{$IFDEF UNICODE}
function CharPrev(lpszStart: LPCWSTR; lpszCurrent: LPCWSTR): LPWSTR; stdcall;
{$ELSE}
function CharPrev(lpszStart: LPCSTR; lpszCurrent: LPCSTR): LPSTR; stdcall;
{$ENDIF}

function CharNextExA(CodePage: WORD; lpCurrentChar: LPCSTR; dwFlags: DWORD): LPSTR; stdcall;

function CharPrevExA(CodePage: WORD; lpStart, lpCurrentChar: LPCSTR; dwFlags: DWORD): LPSTR; stdcall;

//
// Compatibility defines for character translation routines
//

function AnsiToOem(lpszSrc: LPCSTR; lpszDst: LPSTR): BOOL;

function OemToAnsi(lpszSrc: LPCSTR; lpszDst: LPSTR): BOOL;

function AnsiToOemBuff(lpszSrc: LPCSTR; lpszDst: LPSTR; cchDstLength: DWORD): BOOL;

function OemToAnsiBuff(lpszSrc: LPCSTR; lpszDst: LPSTR; cchDstLength: DWORD): BOOL;

function AnsiUpper(lpsz: LPSTR): LPSTR;

function AnsiUpperBuff(lpsz: LPSTR; cchLength: DWORD): DWORD;

function AnsiLower(lpsz: LPSTR): LPSTR;

function AnsiLowerBuff(lpsz: LPSTR; cchLength: DWORD): DWORD;

function AnsiNext(lpsz: LPCSTR): LPSTR;

function AnsiPrev(lpszStart: LPCSTR; lpszCurrent: LPCSTR): LPSTR;

//
// Language dependent Routines
//

function IsCharAlphaA(ch: CHAR): BOOL; stdcall;
function IsCharAlphaW(ch: WCHAR): BOOL; stdcall;

{$IFDEF UNICODE}
function IsCharAlpha(ch: WCHAR): BOOL; stdcall;
{$ELSE}
function IsCharAlpha(ch: CHAR): BOOL; stdcall;
{$ENDIF}

function IsCharAlphaNumericA(ch: CHAR): BOOL; stdcall;
function IsCharAlphaNumericW(ch: WCHAR): BOOL; stdcall;

{$IFDEF UNICODE}
function IsCharAlphaNumeric(ch: WCHAR): BOOL; stdcall;
{$ELSE}
function IsCharAlphaNumeric(ch: CHAR): BOOL; stdcall;
{$ENDIF}

function IsCharUpperA(ch: CHAR): BOOL; stdcall;
function IsCharUpperW(ch: WCHAR): BOOL; stdcall;

{$IFDEF UNICODE}
function IsCharUpper(ch: WCHAR): BOOL; stdcall;
{$ELSE}
function IsCharUpper(ch: CHAR): BOOL; stdcall;
{$ENDIF}

function IsCharLowerA(ch: CHAR): BOOL; stdcall;
function IsCharLowerW(ch: WCHAR): BOOL; stdcall;

{$IFDEF UNICODE}
function IsCharLower(ch: WCHAR): BOOL; stdcall;
{$ELSE}
function IsCharLower(ch: CHAR): BOOL; stdcall;
{$ENDIF}

function SetFocus(hWnd: HWND): HWND; stdcall;

function GetActiveWindow: HWND; stdcall;

function GetFocus: HWND; stdcall;

function GetKBCodePage: UINT; stdcall;

function GetKeyState(nVirtKey: Integer): SHORT; stdcall;

function GetAsyncKeyState(vKey: Integer): SHORT; stdcall;

function GetKeyboardState(lpKeyState: LPBYTE): BOOL; stdcall;

function SetKeyboardState(lpKeyState: LPBYTE): BOOL; stdcall;

function GetKeyNameTextA(lParam: LONG; lpString: LPSTR; nSize: Integer): Integer; stdcall;
function GetKeyNameTextW(lParam: LONG; lpString: LPWSTR; nSize: Integer): Integer; stdcall;

{$IFDEF UNICODE}
function GetKeyNameText(lParam: LONG; lpString: LPWSTR; nSize: Integer): Integer; stdcall;
{$ELSE}
function GetKeyNameText(lParam: LONG; lpString: LPSTR; nSize: Integer): Integer; stdcall;
{$ENDIF}

function GetKeyboardType(nTypeFlag: Integer): Integer; stdcall;

function ToAscii(uVirtKey, uScanCode: UINT; lpKeyState: PBYTE; lpChar: LPWORD;
  uFlags: UINT): Integer; stdcall;

function ToAsciiEx(uVirtKey, uScanCode: UINT; lpKeyState: PBYTE; lpChar: LPWORD;
  uFlags: UINT; dwhkl: HKL): Integer; stdcall;

function ToUnicode(wVirtKey, wScanCode: UINT; lpKeyState: PBYTE; pwszBuff: LPWSTR;
  cchBuff: Integer; wFlags: UINT): Integer; stdcall;

function OemKeyScan(wOemChar: WORD): DWORD; stdcall;

function VkKeyScanA(ch: CHAR): SHORT; stdcall;
function VkKeyScanW(ch: WCHAR): SHORT; stdcall;

{$IFDEF UNICODE}
function VkKeyScan(ch: WCHAR): SHORT; stdcall;
{$ELSE}
function VkKeyScan(ch: CHAR): SHORT; stdcall;
{$ENDIF}

function VkKeyScanExA(ch: CHAR; dwhkl: HKL): SHORT; stdcall;
function VkKeyScanExW(ch: WCHAR; dwhkl: HKL): SHORT; stdcall;

{$IFDEF UNICODE}
function VkKeyScanEx(ch: WCHAR; dwhkl: HKL): SHORT; stdcall;
{$ELSE}
function VkKeyScanEx(ch: CHAR; dwhkl: HKL): SHORT; stdcall;
{$ENDIF}

const
  KEYEVENTF_EXTENDEDKEY = $0001;
  KEYEVENTF_KEYUP       = $0002;

  KEYEVENTF_UNICODE  = $0004;
  KEYEVENTF_SCANCODE = $0008;

procedure keybd_event(bVk, bScan: BYTE; dwFlags: DWORD; dwExtraInfo: ULONG_PTR); stdcall;

const
  MOUSEEVENTF_MOVE        = $0001; // mouse move
  MOUSEEVENTF_LEFTDOWN    = $0002; // left button down
  MOUSEEVENTF_LEFTUP      = $0004; // left button up
  MOUSEEVENTF_RIGHTDOWN   = $0008; // right button down
  MOUSEEVENTF_RIGHTUP     = $0010; // right button up
  MOUSEEVENTF_MIDDLEDOWN  = $0020; // middle button down
  MOUSEEVENTF_MIDDLEUP    = $0040; // middle button up
  MOUSEEVENTF_XDOWN       = $0080; // x button down
  MOUSEEVENTF_XUP         = $0100; // x button down
  MOUSEEVENTF_WHEEL       = $0800; // wheel button rolled
  MOUSEEVENTF_VIRTUALDESK = $4000; // map to entire virtual desktop
  MOUSEEVENTF_ABSOLUTE    = $8000; // absolute move

procedure mouse_event(dwFlags, dx, dy, dwData: DWORD; dwExtraInfo: ULONG_PTR); stdcall;

type
  LPMOUSEINPUT = ^MOUSEINPUT;
  tagMOUSEINPUT = record
    dx: LONG;
    dy: LONG;
    mouseData: DWORD;
    dwFlags: DWORD;
    time: DWORD;
    dwExtraInfo: ULONG_PTR;
  end;
  MOUSEINPUT = tagMOUSEINPUT;
  TMouseInput = MOUSEINPUT;
  PMouseInput = LPMOUSEINPUT;

  LPKEYBDINPUT = ^KEYBDINPUT;
  tagKEYBDINPUT = record
    wVk: WORD;
    wScan: WORD;
    dwFlags: DWORD;
    time: DWORD;
    dwExtraInfo: ULONG_PTR;
  end;
  KEYBDINPUT = tagKEYBDINPUT;
  TKeybdinput = KEYBDINPUT;
  PKeybdInput = LPKEYBDINPUT;

  LPHARDWAREINPUT = ^HARDWAREINPUT;
  tagHARDWAREINPUT = record
    uMsg: DWORD;
    wParamL: WORD;
    wParamH: WORD;
  end;
  HARDWAREINPUT = tagHARDWAREINPUT;
  THardwareInput = HARDWAREINPUT;
  PHardwareInput = LPHARDWAREINPUT;

const
  INPUT_MOUSE    = 0;
  INPUT_KEYBOARD = 1;
  INPUT_HARDWARE = 2;

type
  LPINPUT = ^INPUT;
  tagINPUT = record
    type_: DWORD;
    case Integer of
      0: (mi: MOUSEINPUT);
      1: (ki: KEYBDINPUT);
      2: (hi: HARDWAREINPUT);
  end;
  INPUT = tagINPUT;
  TInput = INPUT;
  PInput = LPINPUT;

function SendInput(cInputs: UINT; pInputs: LPINPUT; cbSize: Integer): UINT; stdcall;

type
  PLASTINPUTINFO = ^LASTINPUTINFO;
  tagLASTINPUTINFO = record
    cbSize: UINT;
    dwTime: DWORD;
  end;
  LASTINPUTINFO = tagLASTINPUTINFO;
  TLastInputInfo = LASTINPUTINFO;

function GetLastInputInfo(var plii: LASTINPUTINFO): BOOL; stdcall;

function MapVirtualKeyA(uCode, uMapType: UINT): UINT; stdcall;
function MapVirtualKeyW(uCode, uMapType: UINT): UINT; stdcall;

{$IFDEF UNICODE}
function MapVirtualKey(uCode, uMapType: UINT): UINT; stdcall;
{$ELSE}
function MapVirtualKey(uCode, uMapType: UINT): UINT; stdcall;
{$ENDIF}

function MapVirtualKeyExA(uCode, uMapType: UINT; dwhkl: HKL): UINT; stdcall;
function MapVirtualKeyExW(uCode, uMapType: UINT; dwhkl: HKL): UINT; stdcall;

{$IFDEF UNICODE}
function MapVirtualKeyEx(uCode, uMapType: UINT; dwhkl: HKL): UINT; stdcall;
{$ELSE}
function MapVirtualKeyEx(uCode, uMapType: UINT; dwhkl: HKL): UINT; stdcall;
{$ENDIF}

function GetInputState: BOOL; stdcall;

function GetQueueStatus(flags: UINT): DWORD; stdcall;

function GetCapture: HWND; stdcall;

function SetCapture(hWnd: HWND): HWND; stdcall;

function ReleaseCapture: BOOL; stdcall;

function MsgWaitForMultipleObjects(nCount: DWORD; pHandles: PHANDLE;
  fWaitAll: BOOL; dwMilliseconds: DWORD; dwWakeMask: DWORD): DWORD; stdcall;

function MsgWaitForMultipleObjectsEx(nCount: DWORD; pHandles: PHANDLE;
  dwMilliseconds: DWORD; dwWakeMask: DWORD; dwFlags: DWORD): DWORD; stdcall;

const
  MWMO_WAITALL        = $0001;
  MWMO_ALERTABLE      = $0002;
  MWMO_INPUTAVAILABLE = $0004;

//
// Windows Functions
//

function SetTimer(hWnd: HWND; nIDEvent: UINT_PTR; uElapse: UINT;
  lpTimerFunc: TIMERPROC): UINT_PTR; stdcall;

function KillTimer(hWnd: HWND; uIDEvent: UINT_PTR): BOOL; stdcall;

function IsWindowUnicode(hWnd: HWND): BOOL; stdcall;

function EnableWindow(hWnd: HWND; bEnable: BOOL): BOOL; stdcall;

function IsWindowEnabled(hWnd: HWND): BOOL; stdcall;

function LoadAcceleratorsA(hInstance: HINSTANCE; lpTableName: LPCSTR): HACCEL; stdcall;
function LoadAcceleratorsW(hInstance: HINSTANCE; lpTableName: LPCWSTR): HACCEL; stdcall;

{$IFDEF UNICODE}
function LoadAccelerators(hInstance: HINSTANCE; lpTableName: LPCWSTR): HACCEL; stdcall;
{$ELSE}
function LoadAccelerators(hInstance: HINSTANCE; lpTableName: LPCSTR): HACCEL; stdcall;
{$ENDIF}

function CreateAcceleratorTableA(lpaccl: LPACCEL; cEntries: Integer): HACCEL; stdcall;
function CreateAcceleratorTableW(lpaccl: LPACCEL; cEntries: Integer): HACCEL; stdcall;

{$IFDEF UNICODE}
function CreateAcceleratorTable(lpaccl: LPACCEL; cEntries: Integer): HACCEL; stdcall;
{$ELSE}
function CreateAcceleratorTable(lpaccl: LPACCEL; cEntries: Integer): HACCEL; stdcall;
{$ENDIF}

function DestroyAcceleratorTable(hAccel: HACCEL): BOOL; stdcall;

function CopyAcceleratorTableA(hAccelSrc: HACCEL; lpAccelDst: LPACCEL;
  cAccelEntries: Integer): Integer; stdcall;
function CopyAcceleratorTableW(hAccelSrc: HACCEL; lpAccelDst: LPACCEL;
  cAccelEntries: Integer): Integer; stdcall;

{$IFDEF UNICODE}
function CopyAcceleratorTable(hAccelSrc: HACCEL; lpAccelDst: LPACCEL;
  cAccelEntries: Integer): Integer; stdcall;
{$ELSE}
function CopyAcceleratorTable(hAccelSrc: HACCEL; lpAccelDst: LPACCEL;
  cAccelEntries: Integer): Integer; stdcall;
{$ENDIF}

function TranslateAcceleratorA(hWnd: HWND; hAccTable: HACCEL; lpMsg: LPMSG): Integer; stdcall;
function TranslateAcceleratorW(hWnd: HWND; hAccTable: HACCEL; lpMsg: LPMSG): Integer; stdcall;

{$IFDEF UNICODE}
function TranslateAccelerator(hWnd: HWND; hAccTable: HACCEL; lpMsg: LPMSG): Integer; stdcall;
{$ELSE}
function TranslateAccelerator(hWnd: HWND; hAccTable: HACCEL; lpMsg: LPMSG): Integer; stdcall;
{$ENDIF}

//
// GetSystemMetrics() codes
//

const
  SM_CXSCREEN          = 0;
  SM_CYSCREEN          = 1;
  SM_CXVSCROLL         = 2;
  SM_CYHSCROLL         = 3;
  SM_CYCAPTION         = 4;
  SM_CXBORDER          = 5;
  SM_CYBORDER          = 6;
  SM_CXDLGFRAME        = 7;
  SM_CYDLGFRAME        = 8;
  SM_CYVTHUMB          = 9;
  SM_CXHTHUMB          = 10;
  SM_CXICON            = 11;
  SM_CYICON            = 12;
  SM_CXCURSOR          = 13;
  SM_CYCURSOR          = 14;
  SM_CYMENU            = 15;
  SM_CXFULLSCREEN      = 16;
  SM_CYFULLSCREEN      = 17;
  SM_CYKANJIWINDOW     = 18;
  SM_MOUSEPRESENT      = 19;
  SM_CYVSCROLL         = 20;
  SM_CXHSCROLL         = 21;
  SM_DEBUG             = 22;
  SM_SWAPBUTTON        = 23;
  SM_RESERVED1         = 24;
  SM_RESERVED2         = 25;
  SM_RESERVED3         = 26;
  SM_RESERVED4         = 27;
  SM_CXMIN             = 28;
  SM_CYMIN             = 29;
  SM_CXSIZE            = 30;
  SM_CYSIZE            = 31;
  SM_CXFRAME           = 32;
  SM_CYFRAME           = 33;
  SM_CXMINTRACK        = 34;
  SM_CYMINTRACK        = 35;
  SM_CXDOUBLECLK       = 36;
  SM_CYDOUBLECLK       = 37;
  SM_CXICONSPACING     = 38;
  SM_CYICONSPACING     = 39;
  SM_MENUDROPALIGNMENT = 40;
  SM_PENWINDOWS        = 41;
  SM_DBCSENABLED       = 42;
  SM_CMOUSEBUTTONS     = 43;

  SM_CXFIXEDFRAME = SM_CXDLGFRAME; // ;win40 name change
  SM_CYFIXEDFRAME = SM_CYDLGFRAME; // ;win40 name change
  SM_CXSIZEFRAME  = SM_CXFRAME; // ;win40 name change
  SM_CYSIZEFRAME  = SM_CYFRAME; // ;win40 name change

  SM_SECURE       = 44;
  SM_CXEDGE       = 45;
  SM_CYEDGE       = 46;
  SM_CXMINSPACING = 47;
  SM_CYMINSPACING = 48;
  SM_CXSMICON     = 49;
  SM_CYSMICON     = 50;
  SM_CYSMCAPTION  = 51;
  SM_CXSMSIZE     = 52;
  SM_CYSMSIZE     = 53;
  SM_CXMENUSIZE   = 54;
  SM_CYMENUSIZE   = 55;
  SM_ARRANGE      = 56;
  SM_CXMINIMIZED  = 57;
  SM_CYMINIMIZED  = 58;
  SM_CXMAXTRACK   = 59;
  SM_CYMAXTRACK   = 60;
  SM_CXMAXIMIZED  = 61;
  SM_CYMAXIMIZED  = 62;
  SM_NETWORK      = 63;
  SM_CLEANBOOT    = 67;
  SM_CXDRAG       = 68;
  SM_CYDRAG       = 69;
  SM_SHOWSOUNDS = 70;
  SM_CXMENUCHECK    = 71; // Use instead of GetMenuCheckMarkDimensions()!
  SM_CYMENUCHECK    = 72;
  SM_SLOWMACHINE    = 73;
  SM_MIDEASTENABLED = 74;

  SM_MOUSEWHEELPRESENT = 75;
  SM_XVIRTUALSCREEN    = 76;
  SM_YVIRTUALSCREEN    = 77;
  SM_CXVIRTUALSCREEN   = 78;
  SM_CYVIRTUALSCREEN   = 79;
  SM_CMONITORS         = 80;
  SM_SAMEDISPLAYFORMAT = 81;
  SM_IMMENABLED        = 82;
  SM_CXFOCUSBORDER     = 83;
  SM_CYFOCUSBORDER     = 84;

//#if(_WIN32_WINNT >= 0x0501)

  SM_TABLETPC          = 86;
  SM_MEDIACENTER       = 87;

//#endif /* _WIN32_WINNT >= 0x0501 */

{ TODO
#if (WINVER < 0x0500) && (!defined(_WIN32_WINNT) || (_WIN32_WINNT < 0x0400))
#define SM_CMETRICS             76
#elif WINVER == 0x500
#define SM_CMETRICS             83
#else
#define SM_CMETRICS             88
#endif
}

const
  SM_CMETRICS = 76;

  SM_REMOTESESSION = $1000;
  SM_SHUTTINGDOWN  = $2000;
//#if(WINVER >= 0x0501)
  SM_REMOTECONTROL = $2001;
//#endif /* WINVER >= 0x0501 */

function GetSystemMetrics(nIndex: Integer): Integer; stdcall;

function LoadMenuA(hInstance: HINSTANCE; lpMenuName: LPCSTR): HMENU; stdcall;
function LoadMenuW(hInstance: HINSTANCE; lpMenuName: LPCWSTR): HMENU; stdcall;

{$IFDEF UNICODE}
function LoadMenu(hInstance: HINSTANCE; lpMenuName: LPCWSTR): HMENU; stdcall;
{$ELSE}
function LoadMenu(hInstance: HINSTANCE; lpMenuName: LPCSTR): HMENU; stdcall;
{$ENDIF}

function LoadMenuIndirectA(lpMenuTemplate: LPMENUTEMPLATEA): HMENU; stdcall;
function LoadMenuIndirectW(lpMenuTemplate: LPMENUTEMPLATEW): HMENU; stdcall;

{$IFDEF UNICODE}
function LoadMenuIndirect(lpMenuTemplate: LPMENUTEMPLATEW): HMENU; stdcall;
{$ELSE}
function LoadMenuIndirect(lpMenuTemplate: LPMENUTEMPLATEA): HMENU; stdcall;
{$ENDIF}

function GetMenu(hWnd: HWND): HMENU; stdcall;

function SetMenu(hWnd: HWND; hMenu: HMENU): BOOL; stdcall;

function ChangeMenuA(hMenu: HMENU; cmd: UINT; lpszNewItem: LPCSTR;
  cmdInsert: UINT; flags: UINT): BOOL; stdcall;
function ChangeMenuW(hMenu: HMENU; cmd: UINT; lpszNewItem: LPCWSTR;
  cmdInsert: UINT; flags: UINT): BOOL; stdcall;

{$IFDEF UNICODE}
function ChangeMenu(hMenu: HMENU; cmd: UINT; lpszNewItem: LPCWSTR;
  cmdInsert: UINT; flags: UINT): BOOL; stdcall;
{$ELSE}
function ChangeMenu(hMenu: HMENU; cmd: UINT; lpszNewItem: LPCSTR;
  cmdInsert: UINT; flags: UINT): BOOL; stdcall;
{$ENDIF}

function HiliteMenuItem(hWnd: HWND; hMenu: HMENU; uIDHiliteItem: UINT; uHilite: UINT): BOOL; stdcall;

function GetMenuStringA(hMenu: HMENU; uIDItem: UINT; lpString: LPSTR;
  nMaxCount: Integer; uFlag: UINT): Integer; stdcall;
function GetMenuStringW(hMenu: HMENU; uIDItem: UINT; lpString: LPWSTR;
  nMaxCount: Integer; uFlag: UINT): Integer; stdcall;

{$IFDEF UNICODE}
function GetMenuString(hMenu: HMENU; uIDItem: UINT; lpString: LPWSTR;
  nMaxCount: Integer; uFlag: UINT): Integer; stdcall;
{$ELSE}
function GetMenuString(hMenu: HMENU; uIDItem: UINT; lpString: LPSTR;
  nMaxCount: Integer; uFlag: UINT): Integer; stdcall;
{$ENDIF}

function GetMenuState(hMenu: HMENU; uId, uFlags: UINT): UINT; stdcall;

function DrawMenuBar(hWnd: HWND): BOOL; stdcall;

const
  PMB_ACTIVE = $00000001;
  
function GetSystemMenu(hWnd: HWND; bRevert: BOOL): HMENU; stdcall;

function CreateMenu: HMENU; stdcall;

function CreatePopupMenu: HMENU; stdcall;

function DestroyMenu(hMenu: HMENU): BOOL; stdcall;

function CheckMenuItem(hMenu: HMENU; uIDCheckItem, uCheck: UINT): DWORD; stdcall;

function EnableMenuItem(hMenu: HMENU; uIDEnableItem, uEnable: UINT): BOOL; stdcall;

function GetSubMenu(hMenu: HMENU; nPos: Integer): HMENU; stdcall;

function GetMenuItemID(hMenu: HMENU; nPos: Integer): UINT; stdcall;

function GetMenuItemCount(hMenu: HMENU): Integer; stdcall;

function InsertMenuA(hMenu: HMENU; uPosition, uFlags: UINT; uIDNewItem: UINT_PTR;
  lpNewItem: LPCSTR): BOOL; stdcall;
function InsertMenuW(hMenu: HMENU; uPosition, uFlags: UINT; uIDNewItem: UINT_PTR;
  lpNewItem: LPCWSTR): BOOL; stdcall;

{$IFDEF UNICODE}
function InsertMenu(hMenu: HMENU; uPosition, uFlags: UINT; uIDNewItem: UINT_PTR;
  lpNewItem: LPCWSTR): BOOL; stdcall;
{$ELSE}
function InsertMenu(hMenu: HMENU; uPosition, uFlags: UINT; uIDNewItem: UINT_PTR;
  lpNewItem: LPCSTR): BOOL; stdcall;
{$ENDIF}

function AppendMenuA(hMenu: HMENU; uFlags: UINT; uIDNewItem: UINT_PTR;
  lpNewItem: LPCSTR): BOOL; stdcall;
function AppendMenuW(hMenu: HMENU; uFlags: UINT; uIDNewItem: UINT_PTR;
  lpNewItem: LPCWSTR): BOOL; stdcall;

{$IFDEF UNICODE}
function AppendMenu(hMenu: HMENU; uFlags: UINT; uIDNewItem: UINT_PTR;
  lpNewItem: LPCWSTR): BOOL; stdcall;
{$ELSE}
function AppendMenu(hMenu: HMENU; uFlags: UINT; uIDNewItem: UINT_PTR;
  lpNewItem: LPCSTR): BOOL; stdcall;
{$ENDIF}

function ModifyMenuA(hMnu: HMENU; uPosition: UINT; uFlags: UINT;
  uIDNewItem: UINT_PTR; lpNewItem: LPCSTR): BOOL; stdcall;
function ModifyMenuW(hMnu: HMENU; uPosition: UINT; uFlags: UINT;
  uIDNewItem: UINT_PTR; lpNewItem: LPCWSTR): BOOL; stdcall;

{$IFDEF UNICODE}
function ModifyMenu(hMnu: HMENU; uPosition: UINT; uFlags: UINT;
  uIDNewItem: UINT_PTR; lpNewItem: LPCWSTR): BOOL; stdcall;
{$ELSE}
function ModifyMenu(hMnu: HMENU; uPosition: UINT; uFlags: UINT;
  uIDNewItem: UINT_PTR; lpNewItem: LPCSTR): BOOL; stdcall;
{$ENDIF}

function RemoveMenu(hMenu: HMENU; uPosition: UINT; uFlags: UINT): BOOL; stdcall;

function DeleteMenu(hMenu: HMENU; uPosition: UINT; uFlags: UINT): BOOL; stdcall;

function SetMenuItemBitmaps(hMenu: HMENU; uPosition: UINT; uFlags: UINT;
  hBitmapUnchecked: HBITMAP; hBitmapChecked: HBITMAP): BOOL; stdcall;

function GetMenuCheckMarkDimensions: LONG; stdcall;

function TrackPopupMenu(hMenu: HMENU; uFlags: UINT; x: Integer; y: Integer;
  nReserved: Integer; hWnd: HWND; prcRect: LPRECT): BOOL; stdcall;

// return codes for WM_MENUCHAR//

const
  MNC_IGNORE  = 0;
  MNC_CLOSE   = 1;
  MNC_EXECUTE = 2;
  MNC_SELECT  = 3;

type
  LPTPMPARAMS = ^TPMPARAMS;
  tagTPMPARAMS = record
    cbSize: UINT;    // Size of structure
    rcExclude: RECT; // Screen coordinates of rectangle to exclude when positioning
  end;
  TPMPARAMS = tagTPMPARAMS;
  TTPMParams = TPMPARAMS;
  PTPMParams = LPTPMPARAMS;

function TrackPopupMenuEx(hmenu: HMENU; fuflags: UINT; x, y: Integer;
  hwnd: HWND; lptpm: LPTPMPARAMS): BOOL; stdcall;

const
  MNS_NOCHECK     = $80000000;
  MNS_MODELESS    = $40000000;
  MNS_DRAGDROP    = $20000000;
  MNS_AUTODISMISS = $10000000;
  MNS_NOTIFYBYPOS = $08000000;
  MNS_CHECKORBMP  = $04000000;

  MIM_MAXHEIGHT       = $00000001;
  MIM_BACKGROUND      = $00000002;
  MIM_HELPID          = $00000004;
  MIM_MENUDATA        = $00000008;
  MIM_STYLE           = $00000010;
  MIM_APPLYTOSUBMENUS = $80000000;

type
  LPMENUINFO = ^MENUINFO;
  tagMENUINFO = record
    cbSize: DWORD;
    fMask: DWORD;
    dwStyle: DWORD;
    cyMax: UINT;
    hbrBack: HBRUSH;
    dwContextHelpID: DWORD;
    dwMenuData: ULONG_PTR;
  end;
  MENUINFO = tagMENUINFO;
  TMenuinfo = MENUINFO;
  PMenuinfo = LPMENUINFO;

  LPCMENUINFO = ^MENUINFO;

function GetMenuInfo(hmenu: HMENU; var lpcmi: MENUINFO): BOOL; stdcall;

function SetMenuInfo(hemnu: HMENU; const lpcmi: MENUINFO): BOOL; stdcall;

function EndMenu: BOOL; stdcall;

//
// WM_MENUDRAG return values.
//

const
  MND_CONTINUE = 0;
  MND_ENDMENU  = 1;

type
  PMENUGETOBJECTINFO = ^MENUGETOBJECTINFO;
  tagMENUGETOBJECTINFO = record
    dwFlags: DWORD;
    uPos: UINT;
    hmenu: HMENU;
    riid: PVOID;
    pvObj: PVOID;
  end;
  MENUGETOBJECTINFO = tagMENUGETOBJECTINFO;
  TMenuGetObjectInfo = MENUGETOBJECTINFO;

//
// MENUGETOBJECTINFO dwFlags values
//

const
  MNGOF_TOPGAP    = $00000001;
  MNGOF_BOTTOMGAP = $00000002;

//
// WM_MENUGETOBJECT return values
//

  MNGO_NOINTERFACE = $00000000;
  MNGO_NOERROR     = $00000001;

  MIIM_STATE      = $00000001;
  MIIM_ID         = $00000002;
  MIIM_SUBMENU    = $00000004;
  MIIM_CHECKMARKS = $00000008;
  MIIM_TYPE       = $00000010;
  MIIM_DATA       = $00000020;

  MIIM_STRING = $00000040;
  MIIM_BITMAP = $00000080;
  MIIM_FTYPE  = $00000100;

  HBMMENU_CALLBACK        = HBITMAP(-1);
  HBMMENU_SYSTEM          = HBITMAP(1);
  HBMMENU_MBAR_RESTORE    = HBITMAP(2);
  HBMMENU_MBAR_MINIMIZE   = HBITMAP(3);
  HBMMENU_MBAR_CLOSE      = HBITMAP(5);
  HBMMENU_MBAR_CLOSE_D    = HBITMAP(6);
  HBMMENU_MBAR_MINIMIZE_D = HBITMAP(7);
  HBMMENU_POPUP_CLOSE     = HBITMAP(8);
  HBMMENU_POPUP_RESTORE   = HBITMAP(9);
  HBMMENU_POPUP_MAXIMIZE  = HBITMAP(10);
  HBMMENU_POPUP_MINIMIZE  = HBITMAP(11);

type
  LPMENUITEMINFOA = ^MENUITEMINFOA;
  tagMENUITEMINFOA = record
    cbSize: UINT;
    fMask: UINT;
    fType: UINT;            // used if MIIM_TYPE (4.0) or MIIM_FTYPE (>4.0)
    fState: UINT;           // used if MIIM_STATE
    wID: UINT;              // used if MIIM_ID
    hSubMenu: HMENU;        // used if MIIM_SUBMENU
    hbmpChecked: HBITMAP;   // used if MIIM_CHECKMARKS
    hbmpUnchecked: HBITMAP; // used if MIIM_CHECKMARKS
    dwItemData: ULONG_PTR;  // used if MIIM_DATA
    dwTypeData: LPSTR;      // used if MIIM_TYPE (4.0) or MIIM_STRING (>4.0)
    cch: UINT;              // used if MIIM_TYPE (4.0) or MIIM_STRING (>4.0)
    hbmpItem: HBITMAP;      // used if MIIM_BITMAP
  end;
  MENUITEMINFOA = tagMENUITEMINFOA;
  TMenuItemInfoA = MENUITEMINFOA;
  PMenuItemInfoA = LPMENUITEMINFOA;

  LPMENUITEMINFOW = ^MENUITEMINFOW;
  tagMENUITEMINFOW = record
    cbSize: UINT;
    fMask: UINT;
    fType: UINT;            // used if MIIM_TYPE (4.0) or MIIM_FTYPE (>4.0)
    fState: UINT;           // used if MIIM_STATE
    wID: UINT;              // used if MIIM_ID
    hSubMenu: HMENU;        // used if MIIM_SUBMENU
    hbmpChecked: HBITMAP;   // used if MIIM_CHECKMARKS
    hbmpUnchecked: HBITMAP; // used if MIIM_CHECKMARKS
    dwItemData: ULONG_PTR;  // used if MIIM_DATA
    dwTypeData: LPWSTR;     // used if MIIM_TYPE (4.0) or MIIM_STRING (>4.0)
    cch: UINT;              // used if MIIM_TYPE (4.0) or MIIM_STRING (>4.0)
    hbmpItem: HBITMAP;      // used if MIIM_BITMAP
  end;
  MENUITEMINFOW = tagMENUITEMINFOW;
  TMenuItemInfoW = MENUITEMINFOW;
  PMenuItemInfoW = LPMENUITEMINFOW;

  LPCMENUITEMINFOA = ^MENUITEMINFOA;
  LPCMENUITEMINFOW = ^MENUITEMINFOW;

{$IFDEF UNICODE}
  MENUITEMINFO = MENUITEMINFOW;
  LPMENUITEMINFO = LPMENUITEMINFOW;
  TMenuItemInfo = TMenuItemInfoW;
  PMenuItemInfo = PMenuItemInfoW;
  LPCMENUITEMINFO = LPCMENUITEMINFOW;
{$ELSE}
  MENUITEMINFO = MENUITEMINFOA;
  LPMENUITEMINFO = LPMENUITEMINFOA;
  TMenuItemInfo = TMenuItemInfoA;
  PMenuItemInfo = PMenuItemInfoA;
  LPCMENUITEMINFO = LPCMENUITEMINFOA;
{$ENDIF}

function InsertMenuItemA(hMenu: HMENU; uItem: UINT; fByPosition: BOOL;
  const lpmii: MENUITEMINFOA): BOOL; stdcall;
function InsertMenuItemW(hMenu: HMENU; uItem: UINT; fByPosition: BOOL;
  const lpmii: MENUITEMINFOW): BOOL; stdcall;

{$IFDEF UNICODE}
function InsertMenuItem(hMenu: HMENU; uItem: UINT; fByPosition: BOOL;
  const lpmii: MENUITEMINFOW): BOOL; stdcall;
{$ELSE}
function InsertMenuItem(hMenu: HMENU; uItem: UINT; fByPosition: BOOL;
  const lpmii: MENUITEMINFOA): BOOL; stdcall;
{$ENDIF}

function GetMenuItemInfoA(hMenu: HMENU; uItem: UINT; fByPosition: BOOL;
  var lpmii: MENUITEMINFOA): BOOL; stdcall;
function GetMenuItemInfoW(hMenu: HMENU; uItem: UINT; fByPosition: BOOL;
  var lpmii: MENUITEMINFOW): BOOL; stdcall;

{$IFDEF UNICODE}
function GetMenuItemInfo(hMenu: HMENU; uItem: UINT; fByPosition: BOOL;
  var lpmii: MENUITEMINFOW): BOOL; stdcall;
{$ELSE}
function GetMenuItemInfo(hMenu: HMENU; uItem: UINT; fByPosition: BOOL;
  var lpmii: MENUITEMINFOA): BOOL; stdcall;
{$ENDIF}

function SetMenuItemInfoA(hMenu: HMENU; uItem: UINT; fByPosition: BOOL;
  const lpmii: MENUITEMINFOA): BOOL; stdcall;
function SetMenuItemInfoW(hMenu: HMENU; uItem: UINT; fByPosition: BOOL;
  const lpmii: MENUITEMINFOW): BOOL; stdcall;

{$IFDEF UNICODE}
function SetMenuItemInfo(hMenu: HMENU; uItem: UINT; fByPosition: BOOL;
  const lpmii: MENUITEMINFOW): BOOL; stdcall;
{$ELSE}
function SetMenuItemInfo(hMenu: HMENU; uItem: UINT; fByPosition: BOOL;
  const lpmii: MENUITEMINFOA): BOOL; stdcall;
{$ENDIF}

const
  GMDI_USEDISABLED  = $0001;
  GMDI_GOINTOPOPUPS = $0002;

function GetMenuDefaultItem(hMenu: HMENU; fByPos, gmdiFlags: UINT): UINT; stdcall;

function SetMenuDefaultItem(hMenu: HMENU; uItem, fByPos: UINT): BOOL; stdcall;

function GetMenuItemRect(hWnd: HWND; hMenu: HMENU; uItem: UINT; var lprcItem: RECT): BOOL; stdcall;

function MenuItemFromPoint(hWnd: HWND; hMenu: HMENU; ptScreen: POINT): Integer; stdcall;

//
// Flags for TrackPopupMenu
//

const
  TPM_LEFTBUTTON   = $0000;
  TPM_RIGHTBUTTON  = $0002;
  TPM_LEFTALIGN    = $0000;
  TPM_CENTERALIGN  = $0004;
  TPM_RIGHTALIGN   = $0008;
  TPM_TOPALIGN     = $0000;
  TPM_VCENTERALIGN = $0010;
  TPM_BOTTOMALIGN  = $0020;

  TPM_HORIZONTAL      = $0000; // Horz alignment matters more
  TPM_VERTICAL        = $0040; // Vert alignment matters more
  TPM_NONOTIFY        = $0080; // Don't send any notification msgs
  TPM_RETURNCMD       = $0100;
  TPM_RECURSE         = $0001;
  TPM_HORPOSANIMATION = $0400;
  TPM_HORNEGANIMATION = $0800;
  TPM_VERPOSANIMATION = $1000;
  TPM_VERNEGANIMATION = $2000;
  TPM_NOANIMATION     = $4000;
  TPM_LAYOUTRTL       = $8000;
  
//
// Drag-and-drop support
// Obsolete - use OLE instead
//

type
  LPDROPSTRUCT = ^DROPSTRUCT;
  tagDROPSTRUCT = record
    hwndSource: HWND;
    hwndSink: HWND;
    wFmt: DWORD;
    dwData: ULONG_PTR;
    ptDrop: POINT;
    dwControlData: DWORD;
  end;
  DROPSTRUCT = tagDROPSTRUCT;
  TDropStruct = DROPSTRUCT;
  PDropStruct = LPDROPSTRUCT;

const
  DOF_EXECUTABLE = $8001; // wFmt flags
  DOF_DOCUMENT   = $8002;
  DOF_DIRECTORY  = $8003;
  DOF_MULTIPLE   = $8004;
  DOF_PROGMAN    = $0001;
  DOF_SHELLDATA  = $0002;

  DO_DROPFILE  = $454C4946;
  DO_PRINTFILE = $544E5250;

function DragObject(hwnd1, hwnd2: HWND; i: UINT; u: ULONG_PTR; hcursor: HCURSOR): DWORD; stdcall;

function DragDetect(hwnd: HWND; pt: POINT): BOOL; stdcall;

function DrawIcon(hDC: HDC; X, Y: Integer; hIcon: HICON): BOOL; stdcall;

//
// DrawText() Format Flags
//

const
  DT_TOP             = $00000000;
  DT_LEFT            = $00000000;
  DT_CENTER          = $00000001;
  DT_RIGHT           = $00000002;
  DT_VCENTER         = $00000004;
  DT_BOTTOM          = $00000008;
  DT_WORDBREAK       = $00000010;
  DT_SINGLELINE      = $00000020;
  DT_EXPANDTABS      = $00000040;
  DT_TABSTOP         = $00000080;
  DT_NOCLIP          = $00000100;
  DT_EXTERNALLEADING = $00000200;
  DT_CALCRECT        = $00000400;
  DT_NOPREFIX        = $00000800;
  DT_INTERNAL        = $00001000;

  DT_EDITCONTROL          = $00002000;
  DT_PATH_ELLIPSIS        = $00004000;
  DT_END_ELLIPSIS         = $00008000;
  DT_MODIFYSTRING         = $00010000;
  DT_RTLREADING           = $00020000;
  DT_WORD_ELLIPSIS        = $00040000;
  DT_NOFULLWIDTHCHARBREAK = $00080000;
  DT_HIDEPREFIX           = $00100000;
  DT_PREFIXONLY           = $00200000;

type
  LPDRAWTEXTPARAMS = ^DRAWTEXTPARAMS;
  tagDRAWTEXTPARAMS = record
    cbSize: UINT;
    iTabLength: Integer;
    iLeftMargin: Integer;
    iRightMargin: Integer;
    uiLengthDrawn: UINT;
  end;
  DRAWTEXTPARAMS = tagDRAWTEXTPARAMS;
  TDrawTextParams = DRAWTEXTPARAMS;
  PDrawTextParams = LPDRAWTEXTPARAMS;

function DrawTextA(hDC: HDC; lpString: LPCSTR; nCount: Integer;
  var lpRect: RECT; uFormat: UINT): Integer; stdcall;
function DrawTextW(hDC: HDC; lpString: LPCWSTR; nCount: Integer;
  var lpRect: RECT; uFormat: UINT): Integer; stdcall;

{$IFDEF UNICODE}
function DrawText(hDC: HDC; lpString: LPCWSTR; nCount: Integer;
  var lpRect: RECT; uFormat: UINT): Integer; stdcall;
{$ELSE}
function DrawText(hDC: HDC; lpString: LPCSTR; nCount: Integer;
  var lpRect: RECT; uFormat: UINT): Integer; stdcall;
{$ENDIF}

function DrawTextExA(hDc: HDC; lpchText: LPSTR; cchText: Integer;
  var lprc: RECT; dwDTFormat: UINT; lpDTParams: LPDRAWTEXTPARAMS): Integer; stdcall;
function DrawTextExW(hDc: HDC; lpchText: LPWSTR; cchText: Integer;
  var lprc: RECT; dwDTFormat: UINT; lpDTParams: LPDRAWTEXTPARAMS): Integer; stdcall;

{$IFDEF UNICODE}
function DrawTextEx(hDc: HDC; lpchText: LPWSTR; cchText: Integer;
  var lprc: LPRECT; dwDTFormat: UINT; lpDTParams: LPDRAWTEXTPARAMS): Integer; stdcall;
{$ELSE}
function DrawTextEx(hDc: HDC; lpchText: LPSTR; cchText: Integer;
  var lprc: RECT; dwDTFormat: UINT; lpDTParams: LPDRAWTEXTPARAMS): Integer; stdcall;
{$ENDIF}

function GrayStringA(hDC: HDC; hBrush: HBRUSH; lpOutputFunc: GRAYSTRINGPROC;
  lpData: LPARAM; nCount, X, Y, nWidth, nHeight: Integer): BOOL; stdcall;
function GrayStringW(hDC: HDC; hBrush: HBRUSH; lpOutputFunc: GRAYSTRINGPROC;
  lpData: LPARAM; nCount, X, Y, nWidth, nHeight: Integer): BOOL; stdcall;

{$IFDEF UNICODE}
function GrayString(hDC: HDC; hBrush: HBRUSH; lpOutputFunc: GRAYSTRINGPROC;
  lpData: LPARAM; nCount, X, Y, nWidth, nHeight: Integer): BOOL; stdcall;
{$ELSE}
function GrayString(hDC: HDC; hBrush: HBRUSH; lpOutputFunc: GRAYSTRINGPROC;
  lpData: LPARAM; nCount, X, Y, nWidth, nHeight: Integer): BOOL; stdcall;
{$ENDIF}


// Monolithic state-drawing routine//
// Image type//

const
  DST_COMPLEX    = $0000;
  DST_TEXT       = $0001;
  DST_PREFIXTEXT = $0002;
  DST_ICON       = $0003;
  DST_BITMAP     = $0004;

// State type//

  DSS_NORMAL     = $0000;
  DSS_UNION      = $0010; // Gray string appearance
  DSS_DISABLED   = $0020;
  DSS_MONO       = $0080;
  DSS_HIDEPREFIX = $0200;
  DSS_PREFIXONLY = $0400;
  DSS_RIGHT      = $8000;

function DrawStateA(hdc: HDC; hbr: HBRUSH; lputputFunc: DRAWSTATEPROC;
  lData: LPARAM; wData: WPARAM; x, y, cx, cy: Integer; fuFlags: UINT): BOOL; stdcall;
function DrawStateW(hdc: HDC; hbr: HBRUSH; lputputFunc: DRAWSTATEPROC;
  lData: LPARAM; wData: WPARAM; x, y, cx, cy: Integer; fuFlags: UINT): BOOL; stdcall;

{$IFDEF UNICODE}
function DrawState(hdc: HDC; hbr: HBRUSH; lputputFunc: DRAWSTATEPROC;
  lData: LPARAM; wData: WPARAM; x, y, cx, cy: Integer; fuFlags: UINT): BOOL; stdcall;
{$ELSE}
function DrawState(hdc: HDC; hbr: HBRUSH; lputputFunc: DRAWSTATEPROC;
  lData: LPARAM; wData: WPARAM; x, y, cx, cy: Integer; fuFlags: UINT): BOOL; stdcall;
{$ENDIF}

function TabbedTextOutA(hDC: HDC; X, Y: Integer; lpString: LPCSTR; nCount,
  nTabPositions: Integer; lpnTabStopPositions: LPINT; nTabOrigin: Integer): LONG; stdcall;
function TabbedTextOutW(hDC: HDC; X, Y: Integer; lpString: LPCWSTR; nCount,
  nTabPositions: Integer; lpnTabStopPositions: LPINT; nTabOrigin: Integer): LONG; stdcall;

{$IFDEF UNICODE}
function TabbedTextOut(hDC: HDC; X, Y: Integer; lpString: LPCWSTR; nCount,
  nTabPositions: Integer; lpnTabStopPositions: LPINT; nTabOrigin: Integer): LONG; stdcall;
{$ELSE}
function TabbedTextOut(hDC: HDC; X, Y: Integer; lpString: LPCSTR; nCount,
  nTabPositions: Integer; lpnTabStopPositions: LPINT; nTabOrigin: Integer): LONG; stdcall;
{$ENDIF}

function GetTabbedTextExtentA(hDC: HDC; lpString: LPCSTR; nCount,
  nTabPositions: Integer; lpnTabStopPositions: LPINT): DWORD; stdcall;
function GetTabbedTextExtentW(hDC: HDC; lpString: LPCWSTR; nCount,
  nTabPositions: Integer; lpnTabStopPositions: LPINT): DWORD; stdcall;

{$IFDEF UNICODE}
function GetTabbedTextExtent(hDC: HDC; lpString: LPCWSTR; nCount,
  nTabPositions: Integer; lpnTabStopPositions: LPINT): DWORD; stdcall;
{$ELSE}
function GetTabbedTextExtent(hDC: HDC; lpString: LPCSTR; nCount,
  nTabPositions: Integer; lpnTabStopPositions: LPINT): DWORD; stdcall;
{$ENDIF}

function UpdateWindow(hWnd: HWND): BOOL; stdcall;

function SetActiveWindow(hWnd: HWND): HWND; stdcall;

function GetForegroundWindow: HWND; stdcall;

function PaintDesktop(hdc: HDC): BOOL; stdcall;

procedure SwitchToThisWindow(hwnd: HWND; fUnknown: BOOL); stdcall;

function SetForegroundWindow(hWnd: HWND): BOOL; stdcall;

function AllowSetForegroundWindow(dwProcessId: DWORD): BOOL; stdcall;

const
  ASFW_ANY = DWORD(-1);

function LockSetForegroundWindow(uLockCode: UINT): BOOL; stdcall;

const
  LSFW_LOCK   = 1;
  LSFW_UNLOCK = 2;

function WindowFromDC(hDC: HDC): HWND; stdcall;

function GetDC(hWnd: HWND): HDC; stdcall;

function GetDCEx(hWnd: HWND; hrgnClip: HRGN; flags: DWORD): HDC; stdcall;

//
// GetDCEx() flags
//

const
  DCX_WINDOW           = $00000001;
  DCX_CACHE            = $00000002;
  DCX_NORESETATTRS     = $00000004;
  DCX_CLIPCHILDREN     = $00000008;
  DCX_CLIPSIBLINGS     = $00000010;
  DCX_PARENTCLIP       = $00000020;
  DCX_EXCLUDERGN       = $00000040;
  DCX_INTERSECTRGN     = $00000080;
  DCX_EXCLUDEUPDATE    = $00000100;
  DCX_INTERSECTUPDATE  = $00000200;
  DCX_LOCKWINDOWUPDATE = $00000400;

  DCX_VALIDATE = $00200000;

function GetWindowDC(hWnd: HWND): HDC; stdcall;

function ReleaseDC(hWnd: HWND; hDC: HDC): Integer; stdcall;

function BeginPaint(hWnd: HWND; var lpPaint: PAINTSTRUCT): HDC; stdcall;

function EndPaint(hWnd: HWND; const lpPaint: PAINTSTRUCT): BOOL; stdcall;

function GetUpdateRect(hWnd: HWND; var lpRect: RECT; bErase: BOOL): BOOL; stdcall;

function GetUpdateRgn(hWnd: HWND; hRgn: HRGN; bErase: BOOL): Integer; stdcall;

function SetWindowRgn(hWnd: HWND; hRgn: HRGN; bRedraw: BOOL): Integer; stdcall;

function GetWindowRgn(hWnd: HWND; hRgn: HRGN): Integer; stdcall;

function GetWindowRgnBox(hWnd: HWND; var lprc: RECT): Integer; stdcall;

function ExcludeUpdateRgn(hDC: HDC; hWnd: HWND): Integer; stdcall;

function InvalidateRect(hWnd: HWND; lpRect: LPRECT; bErase: BOOL): BOOL; stdcall;

function ValidateRect(hWnd: HWND; lpRect: LPRECT): BOOL; stdcall;

function InvalidateRgn(hWnd: HWND; hRgn: HRGN; bErase: BOOL): BOOL; stdcall;

function ValidateRgn(hWnd: HWND; hRgn: HRGN): BOOL; stdcall;

function RedrawWindow(hWnd: HWND; lprcUpdate: LPRECT; hrgnUpdate: HRGN; flags: UINT): BOOL; stdcall;

//
// RedrawWindow() flags
//

const
  RDW_INVALIDATE    = $0001;
  RDW_INTERNALPAINT = $0002;
  RDW_ERASE         = $0004;

  RDW_VALIDATE        = $0008;
  RDW_NOINTERNALPAINT = $0010;
  RDW_NOERASE         = $0020;

  RDW_NOCHILDREN  = $0040;
  RDW_ALLCHILDREN = $0080;

  RDW_UPDATENOW = $0100;
  RDW_ERASENOW  = $0200;

  RDW_FRAME   = $0400;
  RDW_NOFRAME = $0800;

//
// LockWindowUpdate API
//

function LockWindowUpdate(hWndLock: HWND): BOOL; stdcall;

function ScrollWindow(hWnd: HWND; XAmount, YAmount: Integer; lpRect, lpClipRect: LPRECT): BOOL; stdcall;

function ScrollDC(hDC: HDC; dx, dy: Integer; lprcScroll, lprcClip: LPRECT;
  hrgnUpdate: HRGN; lprcUpdate: LPRECT): BOOL; stdcall;

function ScrollWindowEx(hWnd: HWND; dx, dy: Integer; prcScroll, prcClip: LPRECT;
  hrgnUpdate: HRGN; prcUpdate: LPRECT; flags: UINT): Integer; stdcall;

const
  SW_SCROLLCHILDREN = $0001; // Scroll children within *lprcScroll.
  SW_INVALIDATE     = $0002; // Invalidate after scrolling
  SW_ERASE          = $0004; // If SW_INVALIDATE, don't send WM_ERASEBACKGROUND
  SW_SMOOTHSCROLL   = $0010; // Use smooth scrolling

function SetScrollPos(hWnd: HWND; nBar, nPos: Integer; bRedraw: BOOL): Integer; stdcall;

function GetScrollPos(hWnd: HWND; nBar: Integer): Integer; stdcall;

function SetScrollRange(hWnd: HWND; nBar, nMinPos, nMaxPos: Integer; bRedraw: BOOL): BOOL; stdcall;

function GetScrollRange(hWnd: HWND; nBar: Integer; var lpMinPos, lpMaxPos: Integer): BOOL; stdcall;

function ShowScrollBar(hWnd: HWND; wBar: Integer; bShow: BOOL): BOOL; stdcall;

function EnableScrollBar(hWnd: HWND; wSBflags, wArrows: UINT): BOOL; stdcall;

//
// EnableScrollBar() flags
//

const
  ESB_ENABLE_BOTH  = $0000;
  ESB_DISABLE_BOTH = $0003;

  ESB_DISABLE_LEFT  = $0001;
  ESB_DISABLE_RIGHT = $0002;

  ESB_DISABLE_UP   = $0001;
  ESB_DISABLE_DOWN = $0002;

  ESB_DISABLE_LTUP = ESB_DISABLE_LEFT;
  ESB_DISABLE_RTDN = ESB_DISABLE_RIGHT;

function SetPropA(hWnd: HWND; lpString: LPCSTR; hData: HANDLE): BOOL; stdcall;
function SetPropW(hWnd: HWND; lpString: LPCWSTR; hData: HANDLE): BOOL; stdcall;

{$IFDEF UNICODE}
function SetProp(hWnd: HWND; lpString: LPCWSTR; hData: HANDLE): BOOL; stdcall;
{$ELSE}
function SetProp(hWnd: HWND; lpString: LPCSTR; hData: HANDLE): BOOL; stdcall;
{$ENDIF}

function GetPropA(hWnd: HWND; lpString: LPCSTR): HANDLE; stdcall;
function GetPropW(hWnd: HWND; lpString: LPCWSTR): HANDLE; stdcall;

{$IFDEF UNICODE}
function GetProp(hWnd: HWND; lpString: LPCWSTR): HANDLE; stdcall;
{$ELSE}
function GetProp(hWnd: HWND; lpString: LPCSTR): HANDLE; stdcall;
{$ENDIF}

function RemovePropA(hWnd: HWND; lpString: LPCSTR): HANDLE; stdcall;
function RemovePropW(hWnd: HWND; lpString: LPCWSTR): HANDLE; stdcall;

{$IFDEF UNICODE}
function RemoveProp(hWnd: HWND; lpString: LPCWSTR): HANDLE; stdcall;
{$ELSE}
function RemoveProp(hWnd: HWND; lpString: LPCSTR): HANDLE; stdcall;
{$ENDIF}

function EnumPropsExA(hWnd: HWND; lpEnumFunc: PROPENUMPROCEXA; lParam: LPARAM): Integer; stdcall;
function EnumPropsExW(hWnd: HWND; lpEnumFunc: PROPENUMPROCEXW; lParam: LPARAM): Integer; stdcall;

{$IFDEF UNICODE}
function EnumPropsEx(hWnd: HWND; lpEnumFunc: PROPENUMPROCEXW; lParam: LPARAM): Integer; stdcall;
{$ELSE}
function EnumPropsEx(hWnd: HWND; lpEnumFunc: PROPENUMPROCEXA; lParam: LPARAM): Integer; stdcall;
{$ENDIF}

function EnumPropsA(hWnd: HWND; lpEnumFunc: PROPENUMPROCA): Integer; stdcall;
function EnumPropsW(hWnd: HWND; lpEnumFunc: PROPENUMPROCW): Integer; stdcall;

{$IFDEF UNICODE}
function EnumProps(hWnd: HWND; lpEnumFunc: PROPENUMPROCW): Integer; stdcall;
{$ELSE}
function EnumProps(hWnd: HWND; lpEnumFunc: PROPENUMPROCA): Integer; stdcall;
{$ENDIF}

function SetWindowTextA(hWnd: HWND; lpString: LPCSTR): BOOL; stdcall;
function SetWindowTextW(hWnd: HWND; lpString: LPCWSTR): BOOL; stdcall;

{$IFDEF UNICODE}
function SetWindowText(hWnd: HWND; lpString: LPCWSTR): BOOL; stdcall;
{$ELSE}
function SetWindowText(hWnd: HWND; lpString: LPCSTR): BOOL; stdcall;
{$ENDIF}

function GetWindowTextA(hWnd: HWND; lpString: LPSTR; nMaxCount: Integer): Integer; stdcall;
function GetWindowTextW(hWnd: HWND; lpString: LPWSTR; nMaxCount: Integer): Integer; stdcall;

{$IFDEF UNICODE}
function GetWindowText(hWnd: HWND; lpString: LPWSTR; nMaxCount: Integer): Integer; stdcall;
{$ELSE}
function GetWindowText(hWnd: HWND; lpString: LPSTR; nMaxCount: Integer): Integer; stdcall;
{$ENDIF}

function GetWindowTextLengthA(hWnd: HWND): Integer; stdcall;
function GetWindowTextLengthW(hWnd: HWND): Integer; stdcall;

{$IFDEF UNICODE}
function GetWindowTextLength(hWnd: HWND): Integer; stdcall;
{$ELSE}
function GetWindowTextLength(hWnd: HWND): Integer; stdcall;
{$ENDIF}

function GetClientRect(hWnd: HWND; var lpRect: RECT): BOOL; stdcall;

function GetWindowRect(hWnd: HWND; var lpRect: RECT): BOOL; stdcall;

function AdjustWindowRect(var lpRect: RECT; dwStyle: DWORD; bMenu: BOOL): BOOL; stdcall;

function AdjustWindowRectEx(var lpRect: RECT; dwStyle: DWORD;
  bMenu: BOOL; dwExStyle: DWORD): BOOL; stdcall;

const
  HELPINFO_WINDOW   = $0001;
  HELPINFO_MENUITEM = $0002;

type
  LPHELPINFO = ^HELPINFO;
  tagHELPINFO = record      // Structure pointed to by lParam of WM_HELP//
    cbSize: UINT;           // Size in bytes of this struct //
    iContextType: Integer;  // Either HELPINFO_WINDOW or HELPINFO_MENUITEM//
    iCtrlId: Integer;       // Control Id or a Menu item Id.//
    hItemHandle: HANDLE;    // hWnd of control or hMenu.    //
    dwContextId: DWORD_PTR; // Context Id associated with this item//
    MousePos: POINT;        // Mouse Position in screen co-ordinates//
  end;
  HELPINFO = tagHELPINFO;
  THelpInfo = HELPINFO;
  PHelpInfo = LPHELPINFO;

function SetWindowContextHelpId(hwnd: HWND; dwContextHelpId: DWORD): BOOL; stdcall;

function GetWindowContextHelpId(hwnd: HWND): DWORD; stdcall;

function SetMenuContextHelpId(hmenu: HMENU; dwContextHelpId: DWORD): BOOL; stdcall;

function GetMenuContextHelpId(hmenu: HMENU): DWORD; stdcall;

//
// MessageBox() Flags
//

const
  MB_OK                = $00000000;
  MB_OKCANCEL          = $00000001;
  MB_ABORTRETRYIGNORE  = $00000002;
  MB_YESNOCANCEL       = $00000003;
  MB_YESNO             = $00000004;
  MB_RETRYCANCEL       = $00000005;
  MB_CANCELTRYCONTINUE = $00000006;

  MB_ICONHAND        = $00000010;
  MB_ICONQUESTION    = $00000020;
  MB_ICONEXCLAMATION = $00000030;
  MB_ICONASTERISK    = $00000040;

  MB_USERICON    = $00000080;
  MB_ICONWARNING = MB_ICONEXCLAMATION;
  MB_ICONERROR   = MB_ICONHAND;

  MB_ICONINFORMATION = MB_ICONASTERISK;
  MB_ICONSTOP        = MB_ICONHAND;

  MB_DEFBUTTON1 = $00000000;
  MB_DEFBUTTON2 = $00000100;
  MB_DEFBUTTON3 = $00000200;
  MB_DEFBUTTON4 = $00000300;

  MB_APPLMODAL   = $00000000;
  MB_SYSTEMMODAL = $00001000;
  MB_TASKMODAL   = $00002000;
  MB_HELP        = $00004000; // Help Button

  MB_NOFOCUS              = $00008000;
  MB_SETFOREGROUND        = $00010000;
  MB_DEFAULT_DESKTOP_ONLY = $00020000;

  MB_TOPMOST    = $00040000;
  MB_RIGHT      = $00080000;
  MB_RTLREADING = $00100000;

const
  MB_SERVICE_NOTIFICATION = $00200000;

  MB_TYPEMASK = $0000000F;
  MB_ICONMASK = $000000F0;
  MB_DEFMASK  = $00000F00;
  MB_MODEMASK = $00003000;
  MB_MISCMASK = $0000C000;

function MessageBoxA(hWnd: HWND; lpText, lpCaption: LPCSTR; uType: UINT): Integer; stdcall;
function MessageBoxW(hWnd: HWND; lpText, lpCaption: LPCWSTR; uType: UINT): Integer; stdcall;

{$IFDEF UNICODE}
function MessageBox(hWnd: HWND; lpText, lpCaption: LPCWSTR; uType: UINT): Integer; stdcall;
{$ELSE}
function MessageBox(hWnd: HWND; lpText, lpCaption: LPCSTR; uType: UINT): Integer; stdcall;
{$ENDIF}

function MessageBoxExA(hWnd: HWND; lpText, lpCaption: LPCSTR; uType: UINT;
  wLanguageId: WORD): Integer; stdcall;
function MessageBoxExW(hWnd: HWND; lpText, lpCaption: LPCWSTR; uType: UINT;
  wLanguageId: WORD): Integer; stdcall;

{$IFDEF UNICODE}
function MessageBoxEx(hWnd: HWND; lpText, lpCaption: LPCWSTR; uType: UINT;
  wLanguageId: WORD): Integer; stdcall;
{$ELSE}
function MessageBoxEx(hWnd: HWND; lpText, lpCaption: LPCSTR; uType: UINT;
  wLanguageId: WORD): Integer; stdcall;
{$ENDIF}

type
  MSGBOXCALLBACK = procedure (var lpHelpInfo: HELPINFO); stdcall;
  TMsgBoxCallback = MSGBOXCALLBACK;

  LPMSGBOXPARAMSA = ^MSGBOXPARAMSA;
  tagMSGBOXPARAMSA = record
    cbSize: UINT;
    hwndOwner: HWND;
    hInstance: HINSTANCE;
    lpszText: LPCSTR;
    lpszCaption: LPCSTR;
    dwStyle: DWORD;
    lpszIcon: LPCSTR;
    dwContextHelpId: DWORD_PTR;
    lpfnMsgBoxCallback: MSGBOXCALLBACK;
    dwLanguageId: DWORD;
  end;
  MSGBOXPARAMSA = tagMSGBOXPARAMSA;
  TMsgBoxParamsA = MSGBOXPARAMSA;
  PMsgBoxParamsA = LPMSGBOXPARAMSA;

  LPMSGBOXPARAMSW = ^MSGBOXPARAMSW;
  tagMSGBOXPARAMSW = record
    cbSize: UINT;
    hwndOwner: HWND;
    hInstance: HINSTANCE;
    lpszText: LPCWSTR;
    lpszCaption: LPCWSTR;
    dwStyle: DWORD;
    lpszIcon: LPCWSTR;
    dwContextHelpId: DWORD_PTR;
    lpfnMsgBoxCallback: MSGBOXCALLBACK;
    dwLanguageId: DWORD;
  end;
  MSGBOXPARAMSW = tagMSGBOXPARAMSW;
  TMsgBoxParamsW = MSGBOXPARAMSW;
  PMsgBoxParamsW = LPMSGBOXPARAMSW;

{$IFDEF UNICODE}
  MSGBOXPARAMS = MSGBOXPARAMSW;
  LPMSGBOXPARAMS = LPMSGBOXPARAMSW;
  TMsgBoxParams = TMsgBoxParamsW;
  PMsgBoxParams = PMsgBoxParamsW;
{$ELSE}
  MSGBOXPARAMS = MSGBOXPARAMSA;
  LPMSGBOXPARAMS = LPMSGBOXPARAMSA;
  TMsgBoxParams = TMsgBoxParamsA;
  PMsgBoxParams = PMsgBoxParamsA;
{$ENDIF}

function MessageBoxIndirectA(const lpMsgBoxParams: MSGBOXPARAMSA): Integer; stdcall;
function MessageBoxIndirectW(const lpMsgBoxParams: MSGBOXPARAMSW): Integer; stdcall;

{$IFDEF UNICODE}
function MessageBoxIndirect(const lpMsgBoxParams: MSGBOXPARAMSW): Integer; stdcall;
{$ELSE}
function MessageBoxIndirect(const lpMsgBoxParams: MSGBOXPARAMSA): Integer; stdcall;
{$ENDIF}

function MessageBeep(uType: UINT): BOOL; stdcall;

function ShowCursor(bShow: BOOL): Integer; stdcall;

function SetCursorPos(X, Y: Integer): BOOL; stdcall;

function SetCursor(hCursor: HCURSOR): HCURSOR; stdcall;

function GetCursorPos(var lpPoint: POINT): BOOL; stdcall;

function ClipCursor(lpRect: LPRECT): BOOL; stdcall;

function GetClipCursor(var lpRect: RECT): BOOL; stdcall;

function GetCursor: HCURSOR; stdcall;

function CreateCaret(hWnd: HWND; hBitmap: HBITMAP; nWidth, nHeight: Integer): BOOL; stdcall;

function GetCaretBlinkTime: UINT; stdcall;

function SetCaretBlinkTime(uMSeconds: UINT): BOOL; stdcall;

function DestroyCaret: BOOL; stdcall;

function HideCaret(hWnd: HWND): BOOL; stdcall;

function ShowCaret(hWnd: HWND): BOOL; stdcall;

function SetCaretPos(X, Y: Integer): BOOL; stdcall;

function GetCaretPos(var lpPoint: POINT): BOOL; stdcall;

function ClientToScreen(hWnd: HWND; var lpPoint: POINT): BOOL; stdcall;

function ScreenToClient(hWnd: HWND; var lpPoint: POINT): BOOL; stdcall;

function MapWindowPoints(hWndFrom, hWndTo: HWND; lpPoints: LPPOINT; cPoints: UINT): Integer; stdcall;

function WindowFromPoint(Point: POINT): HWND; stdcall;

function ChildWindowFromPoint(hWndParent: HWND; Point: POINT): HWND; stdcall;

const
  CWP_ALL             = $0000;
  CWP_SKIPINVISIBLE   = $0001;
  CWP_SKIPDISABLED    = $0002;
  CWP_SKIPTRANSPARENT = $0004;

function ChildWindowFromPointEx(hwndParent: HWND; pt: POINT; uFlags: UINT): HWND; stdcall;

//
// Color Types
//

const
  CTLCOLOR_MSGBOX    = 0;
  CTLCOLOR_EDIT      = 1;
  CTLCOLOR_LISTBOX   = 2;
  CTLCOLOR_BTN       = 3;
  CTLCOLOR_DLG       = 4;
  CTLCOLOR_SCROLLBAR = 5;
  CTLCOLOR_STATIC    = 6;
  CTLCOLOR_MAX       = 7;

  COLOR_SCROLLBAR           = 0;
  COLOR_BACKGROUND          = 1;
  COLOR_ACTIVECAPTION       = 2;
  COLOR_INACTIVECAPTION     = 3;
  COLOR_MENU                = 4;
  COLOR_WINDOW              = 5;
  COLOR_WINDOWFRAME         = 6;
  COLOR_MENUTEXT            = 7;
  COLOR_WINDOWTEXT          = 8;
  COLOR_CAPTIONTEXT         = 9;
  COLOR_ACTIVEBORDER        = 10;
  COLOR_INACTIVEBORDER      = 11;
  COLOR_APPWORKSPACE        = 12;
  COLOR_HIGHLIGHT           = 13;
  COLOR_HIGHLIGHTTEXT       = 14;
  COLOR_BTNFACE             = 15;
  COLOR_BTNSHADOW           = 16;
  COLOR_GRAYTEXT            = 17;
  COLOR_BTNTEXT             = 18;
  COLOR_INACTIVECAPTIONTEXT = 19;
  COLOR_BTNHIGHLIGHT        = 20;

  COLOR_3DDKSHADOW = 21;
  COLOR_3DLIGHT    = 22;
  COLOR_INFOTEXT   = 23;
  COLOR_INFOBK     = 24;

  COLOR_HOTLIGHT                = 26;
  COLOR_GRADIENTACTIVECAPTION   = 27;
  COLOR_GRADIENTINACTIVECAPTION = 28;
  COLOR_MENUHILIGHT             = 29;
  COLOR_MENUBAR                 = 30;

  COLOR_DESKTOP     = COLOR_BACKGROUND;
  COLOR_3DFACE      = COLOR_BTNFACE;
  COLOR_3DSHADOW    = COLOR_BTNSHADOW;
  COLOR_3DHIGHLIGHT = COLOR_BTNHIGHLIGHT;
  COLOR_3DHILIGHT   = COLOR_BTNHIGHLIGHT;
  COLOR_BTNHILIGHT  = COLOR_BTNHIGHLIGHT;

function GetSysColor(nIndex: Integer): DWORD; stdcall;

function GetSysColorBrush(nIndex: Integer): HBRUSH; stdcall;

function SetSysColors(cElements: Integer; lpaElements: LPINT;
  lpaRgbValues: LPCOLORREF): BOOL; stdcall;

function DrawFocusRect(hDC: HDC; const lprc: RECT): BOOL; stdcall;

function FillRect(hDC: HDC; const lprc: RECT; hbr: HBRUSH): Integer; stdcall;

function FrameRect(hDC: HDC; const lprc: RECT; hbr: HBRUSH): Integer; stdcall;

function InvertRect(hDC: HDC; const lprc: RECT): BOOL; stdcall;

function SetRect(var lprc: RECT; xLeft, yTop, xRight, yBottom: Integer): BOOL; stdcall;

function SetRectEmpty(var lprc: RECT): BOOL; stdcall;

function CopyRect(var lprcDst: RECT; const lprcSrc: RECT): BOOL; stdcall;

function InflateRect(var lprc: RECT; dx, dy: Integer): BOOL; stdcall;

function IntersectRect(var lprcDst: RECT; const lprcSrc1, lprcSrc2: RECT): BOOL; stdcall;

function UnionRect(var lprcDst: RECT; const lprcSrc1, lprcSrc2: RECT): BOOL; stdcall;

function SubtractRect(var lprcDst: RECT; const lprcSrc1, lprcSrc2: RECT): BOOL; stdcall;

function OffsetRect(var lprc: RECT; dx, dy: Integer): BOOL; stdcall;

function IsRectEmpty(const lprc: RECT): BOOL; stdcall;

function EqualRect(const lprc1, lprc2: RECT): BOOL; stdcall;

function PtInRect(const lprc: RECT; pt: POINT): BOOL; stdcall;

function GetWindowWord(hWnd: HWND; nIndex: Integer): WORD; stdcall;

function SetWindowWord(hWnd: HWND; nIndex: Integer; wNewWord: WORD): WORD; stdcall;

function GetWindowLongA(hWnd: HWND; nIndex: Integer): LONG; stdcall;
function GetWindowLongW(hWnd: HWND; nIndex: Integer): LONG; stdcall;

{$IFDEF UNICODE}
function GetWindowLong(hWnd: HWND; nIndex: Integer): LONG; stdcall;
{$ELSE}
function GetWindowLong(hWnd: HWND; nIndex: Integer): LONG; stdcall;
{$ENDIF}

function SetWindowLongA(hWnd: HWND; nIndex: Integer; dwNewLong: LONG): LONG; stdcall;
function SetWindowLongW(hWnd: HWND; nIndex: Integer; dwNewLong: LONG): LONG; stdcall;

{$IFDEF UNICODE}
function SetWindowLong(hWnd: HWND; nIndex: Integer; dwNewLong: LONG): LONG; stdcall;
{$ELSE}
function SetWindowLong(hWnd: HWND; nIndex: Integer; dwNewLong: LONG): LONG; stdcall;
{$ENDIF}

function GetWindowLongPtrA(hWnd: HWND; nIndex: Integer): LONG_PTR;

function GetWindowLongPtrW(hWnd: HWND; nIndex: Integer): LONG_PTR;

{$IFDEF UNICODE}
function GetWindowLongPtr(hWnd: HWND; nIndex: Integer): LONG_PTR;
{$ELSE}
function GetWindowLongPtr(hWnd: HWND; nIndex: Integer): LONG_PTR;
{$ENDIF}

function SetWindowLongPtrA(hWnd: HWND; nIndex: Integer; dwNewLong: LONG_PTR): LONG_PTR;

function SetWindowLongPtrW(hWnd: HWND; nIndex: Integer; dwNewLong: LONG_PTR): LONG_PTR;

{$IFDEF UNICODE}
function SetWindowLongPtr(hWnd: HWND; nIndex: Integer; dwNewLong: LONG_PTR): LONG_PTR;
{$ELSE}
function SetWindowLongPtr(hWnd: HWND; nIndex: Integer; dwNewLong: LONG_PTR): LONG_PTR;
{$ENDIF}

function GetClassWord(hWnd: HWND; nIndex: Integer): WORD; stdcall;

function SetClassWord(hWnd: HWND; nIndex: Integer; wNewWord: WORD): WORD; stdcall;

function GetClassLongA(hWnd: HWND; nIndex: Integer): DWORD; stdcall;
function GetClassLongW(hWnd: HWND; nIndex: Integer): DWORD; stdcall;

{$IFDEF UNICODE}
function GetClassLong(hWnd: HWND; nIndex: Integer): DWORD; stdcall;
{$ELSE}
function GetClassLong(hWnd: HWND; nIndex: Integer): DWORD; stdcall;
{$ENDIF}

function SetClassLongA(hWnd: HWND; nIndex: Integer; dwNewLong: LONG): DWORD; stdcall;
function SetClassLongW(hWnd: HWND; nIndex: Integer; dwNewLong: LONG): DWORD; stdcall;

{$IFDEF UNICODE}
function SetClassLong(hWnd: HWND; nIndex: Integer; dwNewLong: LONG): DWORD; stdcall;
{$ELSE}
function SetClassLong(hWnd: HWND; nIndex: Integer; dwNewLong: LONG): DWORD; stdcall;
{$ENDIF}

function GetClassLongPtrA(hWnd: HWND; nIndex: Integer): ULONG_PTR;

function GetClassLongPtrW(hWnd: HWND; nIndex: Integer): ULONG_PTR;

{$IFDEF UNICODE}
function GetClassLongPtr(hWnd: HWND; nIndex: Integer): ULONG_PTR;
{$ELSE}
function GetClassLongPtr(hWnd: HWND; nIndex: Integer): ULONG_PTR;
{$ENDIF}

function SetClassLongPtrA(hWnd: HWND; nIndex: Integer; dwNewLong: ULONG_PTR): ULONG_PTR;

function SetClassLongPtrW(hWnd: HWND; nIndex: Integer; dwNewLong: ULONG_PTR): ULONG_PTR;

{$IFDEF UNICODE}
function SetClassLongPtr(hWnd: HWND; nIndex: Integer; dwNewLong: ULONG_PTR): ULONG_PTR;
{$ELSE}
function SetClassLongPtr(hWnd: HWND; nIndex: Integer; dwNewLong: ULONG_PTR): ULONG_PTR;
{$ENDIF}

function GetProcessDefaultLayout(var pdwDefaultLayout: DWORD): BOOL; stdcall;

function SetProcessDefaultLayout(dwDefaultLayout: DWORD): BOOL; stdcall;

function GetDesktopWindow: HWND; stdcall;

function GetParent(hWnd: HWND): HWND; stdcall;

function SetParent(hWndChild, hWndNewParent: HWND): HWND; stdcall;

function EnumChildWindows(hWndParent: HWND; lpEnumFunc: WNDENUMPROC; lParam: LPARAM): BOOL; stdcall;

function FindWindowA(lpClassName, lpWindowName: LPCSTR): HWND; stdcall;
function FindWindowW(lpClassName, lpWindowName: LPCWSTR): HWND; stdcall;

{$IFDEF UNICODE}
function FindWindow(lpClassName, lpWindowName: LPCWSTR): HWND; stdcall;
{$ELSE}
function FindWindow(lpClassName, lpWindowName: LPCSTR): HWND; stdcall;
{$ENDIF}

function FindWindowExA(hwndParent, hwndChildAfter: HWND; lpszClass, lpszWindow: LPCSTR): HWND; stdcall;
function FindWindowExW(hwndParent, hwndChildAfter: HWND; lpszClass, lpszWindow: LPCWSTR): HWND; stdcall;

{$IFDEF UNICODE}
function FindWindowEx(hwndParent, hwndChildAfter: HWND; lpszClass, lpszWindow: LPCWSTR): HWND; stdcall;
{$ELSE}
function FindWindowEx(hwndParent, hwndChildAfter: HWND; lpszClass, lpszWindow: LPCSTR): HWND; stdcall;
{$ENDIF}

function GetShellWindow: HWND; stdcall;

function EnumWindows(lpEnumFunc: WNDENUMPROC; lParam: LPARAM): BOOL; stdcall;

function EnumThreadWindows(dwThreadId: DWORD; lpfn: WNDENUMPROC; lParam: LPARAM): BOOL; stdcall;

function EnumTaskWindows(hTask: HANDLE; lpfn: WNDENUMPROC; lParam: LPARAM): BOOL;

function GetClassNameA(hWnd: HWND; lpClassName: LPSTR; nMaxCount: Integer): Integer; stdcall;
function GetClassNameW(hWnd: HWND; lpClassName: LPWSTR; nMaxCount: Integer): Integer; stdcall;

{$IFDEF UNICODE}
function GetClassName(hWnd: HWND; lpClassName: LPWSTR; nMaxCount: Integer): Integer; stdcall;
{$ELSE}
function GetClassName(hWnd: HWND; lpClassName: LPSTR; nMaxCount: Integer): Integer; stdcall;
{$ENDIF}

function GetTopWindow(hWnd: HWND): HWND; stdcall;

function GetNextWindow(hWnd: HWND; wCmd: UINT): HWND;

function GetWindowThreadProcessId(hWnd: HWND; lpdwProcessId: LPDWORD): DWORD; stdcall;

function IsGUIThread(bConvert: BOOL): BOOL; stdcall;

function GetWindowTask(hWnd: HWND): HANDLE;

function GetLastActivePopup(hWnd: HWND): HWND; stdcall;

//
// GetWindow() Constants
//

const
  GW_HWNDFIRST    = 0;
  GW_HWNDLAST     = 1;
  GW_HWNDNEXT     = 2;
  GW_HWNDPREV     = 3;
  GW_OWNER        = 4;
  GW_CHILD        = 5;
{$IFNDEF WINVER_0500_GREATER} // #if(WINVER <= 0x0400)
  GW_MAX          = 5;
{$ELSE}
  GW_ENABLEDPOPUP = 6;
  GW_MAX          = 6;
{$ENDIF}

function GetWindow(hWnd: HWND; uCmd: UINT): HWND; stdcall;

function SetWindowsHookA(nFilterType: Integer; pfnFilterProc: HOOKPROC): HHOOK; stdcall;
function SetWindowsHookW(nFilterType: Integer; pfnFilterProc: HOOKPROC): HHOOK; stdcall;

{$IFDEF UNICODE}
function SetWindowsHook(nFilterType: Integer; pfnFilterProc: HOOKPROC): HHOOK; stdcall;
{$ELSE}
function SetWindowsHook(nFilterType: Integer; pfnFilterProc: HOOKPROC): HHOOK; stdcall;
{$ENDIF}

function UnhookWindowsHook(nCode: Integer; pfnFilterProc: HOOKPROC): BOOL; stdcall;

function SetWindowsHookExA(idHook: Integer; lpfn: HOOKPROC; hmod: HINSTANCE;
  dwThreadId: DWORD): HHOOK; stdcall;
function SetWindowsHookExW(idHook: Integer; lpfn: HOOKPROC; hmod: HINSTANCE;
  dwThreadId: DWORD): HHOOK; stdcall;

{$IFDEF UNICODE}
function SetWindowsHookEx(idHook: Integer; lpfn: HOOKPROC; hmod: HINSTANCE;
  dwThreadId: DWORD): HHOOK; stdcall;
{$ELSE}
function SetWindowsHookEx(idHook: Integer; lpfn: HOOKPROC; hmod: HINSTANCE;
  dwThreadId: DWORD): HHOOK; stdcall;
{$ENDIF}

function UnhookWindowsHookEx(hhk: HHOOK): BOOL; stdcall;

function CallNextHookEx(hhk: HHOOK; nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

//
// Macros for source-level compatibility with old functions.
//

function DefHookProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM; phhk: LPHHOOK): LRESULT;

// ;win40  -- A lot of MF_* flags have been renamed as MFT_* and MFS_* flags//
//
// Menu flags for Add/Check/EnableMenuItem()
///)

const
  MF_INSERT = $00000000;
  MF_CHANGE = $00000080;
  MF_APPEND = $00000100;
  MF_DELETE = $00000200;
  MF_REMOVE = $00001000;

  MF_BYCOMMAND  = $00000000;
  MF_BYPOSITION = $00000400;

  MF_SEPARATOR = $00000800;

  MF_ENABLED  = $00000000;
  MF_GRAYED   = $00000001;
  MF_DISABLED = $00000002;

  MF_UNCHECKED       = $00000000;
  MF_CHECKED         = $00000008;
  MF_USECHECKBITMAPS = $00000200;

  MF_STRING    = $00000000;
  MF_BITMAP    = $00000004;
  MF_OWNERDRAW = $00000100;

  MF_POPUP        = $00000010;
  MF_MENUBARBREAK = $00000020;
  MF_MENUBREAK    = $00000040;

  MF_UNHILITE = $00000000;
  MF_HILITE   = $00000080;

  MF_DEFAULT      = $00001000;
  MF_SYSMENU      = $00002000;
  MF_HELP         = $00004000;
  MF_RIGHTJUSTIFY = $00004000;

  MF_MOUSESELECT = $00008000;
  MF_END         = $00000080; // Obsolete -- only used by old RES files

  MFT_STRING       = MF_STRING;
  MFT_BITMAP       = MF_BITMAP;
  MFT_MENUBARBREAK = MF_MENUBARBREAK;
  MFT_MENUBREAK    = MF_MENUBREAK;
  MFT_OWNERDRAW    = MF_OWNERDRAW;
  MFT_RADIOCHECK   = $00000200;
  MFT_SEPARATOR    = MF_SEPARATOR;
  MFT_RIGHTORDER   = $00002000;
  MFT_RIGHTJUSTIFY = MF_RIGHTJUSTIFY;

// Menu flags for Add/Check/EnableMenuItem()

  MFS_GRAYED    = $00000003;
  MFS_DISABLED  = MFS_GRAYED;
  MFS_CHECKED   = MF_CHECKED;
  MFS_HILITE    = MF_HILITE;
  MFS_ENABLED   = MF_ENABLED;
  MFS_UNCHECKED = MF_UNCHECKED;
  MFS_UNHILITE  = MF_UNHILITE;
  MFS_DEFAULT   = MF_DEFAULT;

function CheckMenuRadioItem(hmenu: HMENU; idFirst, idLast, idCheck, uFlags: UINT): BOOL; stdcall;

//
// Menu item resource format
//

type
  PMENUITEMTEMPLATEHEADER = ^MENUITEMTEMPLATEHEADER;
  MENUITEMTEMPLATEHEADER = record
    versionNumber: WORD;
    offset: WORD;
  end;
  TMenuItemTemplateHeader = MENUITEMTEMPLATEHEADER;

  PMENUITEMTEMPLATE = ^MENUITEMTEMPLATE; // version 0
  MENUITEMTEMPLATE = record
    mtOption: WORD;
    mtID: WORD;
    mtString: array [0..0] of WCHAR;
  end;
  TMenuItemTemplate = MENUITEMTEMPLATE;

//
// System Menu Command Values
//

const
  SC_SIZE         = $F000;
  SC_MOVE         = $F010;
  SC_MINIMIZE     = $F020;
  SC_MAXIMIZE     = $F030;
  SC_NEXTWINDOW   = $F040;
  SC_PREVWINDOW   = $F050;
  SC_CLOSE        = $F060;
  SC_VSCROLL      = $F070;
  SC_HSCROLL      = $F080;
  SC_MOUSEMENU    = $F090;
  SC_KEYMENU      = $F100;
  SC_ARRANGE      = $F110;
  SC_RESTORE      = $F120;
  SC_TASKLIST     = $F130;
  SC_SCREENSAVE   = $F140;
  SC_HOTKEY       = $F150;
  SC_DEFAULT      = $F160;
  SC_MONITORPOWER = $F170;
  SC_CONTEXTHELP  = $F180;
  SC_SEPARATOR    = $F00F;

//
// Obsolete names
//

const
  SC_ICON = SC_MINIMIZE;
  SC_ZOOM = SC_MAXIMIZE;

//
// Resource Loading Routines
//

function LoadBitmapA(hInstance: HINSTANCE; lpBitmapName: LPCSTR): HBITMAP; stdcall;
function LoadBitmapW(hInstance: HINSTANCE; lpBitmapName: LPCWSTR): HBITMAP; stdcall;

{$IFDEF UNICODE}
function LoadBitmap(hInstance: HINSTANCE; lpBitmapName: LPCWSTR): HBITMAP; stdcall;
{$ELSE}
function LoadBitmap(hInstance: HINSTANCE; lpBitmapName: LPCSTR): HBITMAP; stdcall;
{$ENDIF}

function LoadCursorA(hInstance: HINSTANCE; lpCursorName: LPCSTR): HCURSOR; stdcall;
function LoadCursorW(hInstance: HINSTANCE; lpCursorName: LPCWSTR): HCURSOR; stdcall;

{$IFDEF UNICODE}
function LoadCursor(hInstance: HINSTANCE; lpCursorName: LPCWSTR): HCURSOR; stdcall;
{$ELSE}
function LoadCursor(hInstance: HINSTANCE; lpCursorName: LPCSTR): HCURSOR; stdcall;
{$ENDIF}

function LoadCursorFromFileA(lpFileName: LPCSTR): HCURSOR; stdcall;
function LoadCursorFromFileW(lpFileName: LPCWSTR): HCURSOR; stdcall;

{$IFDEF UNICODE}
function LoadCursorFromFile(lpFileName: LPCWSTR): HCURSOR; stdcall;
{$ELSE}
function LoadCursorFromFile(lpFileName: LPCSTR): HCURSOR; stdcall;
{$ENDIF}

function CreateCursor(hInst: HINSTANCE; xHotSpot, yHotSpot, nWidth, nHeight: Integer;
  pvANDPlane: PVOID; pvXORPlane: PVOID): HCURSOR; stdcall;

function DestroyCursor(hCursor: HCURSOR): BOOL; stdcall;

function CopyCursor(pcur: HCURSOR): HCURSOR;

//
// Standard Cursor IDs
//

const
  IDC_ARROW       = MAKEINTRESOURCE(32512);
  IDC_IBEAM       = MAKEINTRESOURCE(32513);
  IDC_WAIT        = MAKEINTRESOURCE(32514);
  IDC_CROSS       = MAKEINTRESOURCE(32515);
  IDC_UPARROW     = MAKEINTRESOURCE(32516);
  IDC_SIZE        = MAKEINTRESOURCE(32640); // OBSOLETE: use IDC_SIZEALL
  IDC_ICON        = MAKEINTRESOURCE(32641); // OBSOLETE: use IDC_ARROW
  IDC_SIZENWSE    = MAKEINTRESOURCE(32642);
  IDC_SIZENESW    = MAKEINTRESOURCE(32643);
  IDC_SIZEWE      = MAKEINTRESOURCE(32644);
  IDC_SIZENS      = MAKEINTRESOURCE(32645);
  IDC_SIZEALL     = MAKEINTRESOURCE(32646);
  IDC_NO          = MAKEINTRESOURCE(32648); // not in win3.1
  IDC_HAND        = MAKEINTRESOURCE(32649);
  IDC_APPSTARTING = MAKEINTRESOURCE(32650); // not in win3.1
  IDC_HELP        = MAKEINTRESOURCE(32651);

function SetSystemCursor(hcur: HCURSOR; id: DWORD): BOOL; stdcall;

type
  PICONINFO = ^ICONINFO;
  _ICONINFO = record
    fIcon: BOOL;
    xHotspot: DWORD;
    yHotspot: DWORD;
    hbmMask: HBITMAP;
    hbmColor: HBITMAP;
  end;
  ICONINFO = _ICONINFO;
  TIconInfo = ICONINFO;

function LoadIconA(hInstance: HINSTANCE; lpIconName: LPCSTR): HICON; stdcall;
function LoadIconW(hInstance: HINSTANCE; lpIconName: LPCWSTR): HICON; stdcall;

{$IFDEF UNICODE}
function LoadIcon(hInstance: HINSTANCE; lpIconName: LPCWSTR): HICON; stdcall;
{$ELSE}
function LoadIcon(hInstance: HINSTANCE; lpIconName: LPCSTR): HICON; stdcall;
{$ENDIF}

function PrivateExtractIconsA(szFileName: LPCSTR; nIconIndex, cxIcon, cyIcon: Integer; var phicon: HICON;
  var piconid: UINT; nIcons, flags: UINT): UINT; stdcall;
function PrivateExtractIconsW(szFileName: LPCWSTR; nIconIndex, cxIcon, cyIcon: Integer; var phicon: HICON;
  var piconid: UINT; nIcons, flags: UINT): UINT; stdcall;

{$IFDEF UNICODE}
function PrivateExtractIcons(szFileName: LPCWSTR; nIconIndex, cxIcon, cyIcon: Integer; var phicon: HICON;
  var piconid: UINT; nIcons, flags: UINT): UINT; stdcall;
{$ELSE}
function PrivateExtractIcons(szFileName: LPCSTR; nIconIndex, cxIcon, cyIcon: Integer; var phicon: HICON;
  var piconid: UINT; nIcons, flags: UINT): UINT; stdcall;
{$ENDIF}

function CreateIcon(hInstance: HINSTANCE; nWidth, nHeight: Integer; cPlanes,
  cBitsPixel: BYTE; lpbANDbits: LPBYTE; lpbXORbits: LPBYTE): HICON; stdcall;

function DestroyIcon(hIcon: HICON): BOOL; stdcall;

function LookupIconIdFromDirectory(presbits: PBYTE; fIcon: BOOL): Integer; stdcall;

function LookupIconIdFromDirectoryEx(presbits: PBYTE; fIcon: BOOL;
  cxDesired, cyDesired: Integer; Flags: UINT): Integer; stdcall;

function CreateIconFromResource(presbits: PBYTE; dwResSize: DWORD;
  fIcon: BOOL; dwVer: DWORD): HICON; stdcall;

function CreateIconFromResourceEx(presbits: PBYTE; dwResSize: DWORD; fIcon: BOOL;
  dwVer: DWORD; cxDesired, cyDesired: Integer; Flags: UINT): HICON; stdcall;

// Icon/Cursor header//

type
  LPCURSORSHAPE = ^CURSORSHAPE;
  tagCURSORSHAPE = record
    xHotSpot: Integer;
    yHotSpot: Integer;
    cx: Integer;
    cy: Integer;
    cbWidth: Integer;
    Planes: BYTE;
    BitsPixel: BYTE;
  end;
  CURSORSHAPE = tagCURSORSHAPE;
  TCursorShape = CURSORSHAPE;
  PCursorShape = LPCURSORSHAPE;

const
  IMAGE_BITMAP      = 0;
  IMAGE_ICON        = 1;
  IMAGE_CURSOR      = 2;
  IMAGE_ENHMETAFILE = 3;

  LR_DEFAULTCOLOR     = $0000;
  LR_MONOCHROME       = $0001;
  LR_COLOR            = $0002;
  LR_COPYRETURNORG    = $0004;
  LR_COPYDELETEORG    = $0008;
  LR_LOADFROMFILE     = $0010;
  LR_LOADTRANSPARENT  = $0020;
  LR_DEFAULTSIZE      = $0040;
  LR_VGACOLOR         = $0080;
  LR_LOADMAP3DCOLORS  = $1000;
  LR_CREATEDIBSECTION = $2000;
  LR_COPYFROMRESOURCE = $4000;
  LR_SHARED           = $8000;

function LoadImageA(hinst: HINSTANCE; lpszName: LPCSTR; uType: UINT;
  cxDesired, cyDesired: Integer; fuLoad: UINT): HANDLE; stdcall;
function LoadImageW(hinst: HINSTANCE; lpszName: LPCWSTR; uType: UINT;
  cxDesired, cyDesired: Integer; fuLoad: UINT): HANDLE; stdcall;

{$IFDEF UNICODE}
function LoadImage(hinst: HINSTANCE; lpszName: LPCWSTR; uType: UINT;
  cxDesired, cyDesired: Integer; fuLoad: UINT): HANDLE; stdcall;
{$ELSE}
function LoadImage(hinst: HINSTANCE; lpszName: LPCSTR; uType: UINT;
  cxDesired, cyDesired: Integer; fuLoad: UINT): HANDLE; stdcall;
{$ENDIF}

function CopyImage(hinst: HANDLE; lpszName: UINT; cxDesired, cyDesired: Integer;
  fuFlags: UINT): HANDLE; stdcall;

const
  DI_MASK        = $0001;
  DI_IMAGE       = $0002;
  DI_NORMAL      = $0003;
  DI_COMPAT      = $0004;
  DI_DEFAULTSIZE = $0008;
  DI_NOMIRROR    = $0010;

function DrawIconEx(hdc: HDC; xLeft, yTop: Integer; hIcon: HICON;
  cxWidth, cyWidth: Integer; istepIfAniCur: UINT; hbrFlickerFreeDraw: HBRUSH;
  diFlags: UINT): BOOL; stdcall;

function CreateIconIndirect(const piconinfo: ICONINFO): HICON; stdcall;

function CopyIcon(hIcon: HICON): HICON; stdcall;

function GetIconInfo(hIcon: HICON; var piconinfo: ICONINFO): BOOL; stdcall;

const
  RES_ICON   = 1;
  RES_CURSOR = 2;

//
// OEM Resource Ordinal Numbers
//

  OBM_CLOSE    = 32754;
  OBM_UPARROW  = 32753;
  OBM_DNARROW  = 32752;
  OBM_RGARROW  = 32751;
  OBM_LFARROW  = 32750;
  OBM_REDUCE   = 32749;
  OBM_ZOOM     = 32748;
  OBM_RESTORE  = 32747;
  OBM_REDUCED  = 32746;
  OBM_ZOOMD    = 32745;
  OBM_RESTORED = 32744;
  OBM_UPARROWD = 32743;
  OBM_DNARROWD = 32742;
  OBM_RGARROWD = 32741;
  OBM_LFARROWD = 32740;
  OBM_MNARROW  = 32739;
  OBM_COMBO    = 32738;
  OBM_UPARROWI = 32737;
  OBM_DNARROWI = 32736;
  OBM_RGARROWI = 32735;
  OBM_LFARROWI = 32734;

  OBM_OLD_CLOSE   = 32767;
  OBM_SIZE        = 32766;
  OBM_OLD_UPARROW = 32765;
  OBM_OLD_DNARROW = 32764;
  OBM_OLD_RGARROW = 32763;
  OBM_OLD_LFARROW = 32762;
  OBM_BTSIZE      = 32761;
  OBM_CHECK       = 32760;
  OBM_CHECKBOXES  = 32759;
  OBM_BTNCORNERS  = 32758;
  OBM_OLD_REDUCE  = 32757;
  OBM_OLD_ZOOM    = 32756;
  OBM_OLD_RESTORE = 32755;

  OCR_NORMAL      = 32512;
  OCR_IBEAM       = 32513;
  OCR_WAIT        = 32514;
  OCR_CROSS       = 32515;
  OCR_UP          = 32516;
  OCR_SIZE        = 32640; // OBSOLETE: use OCR_SIZEALL
  OCR_ICON        = 32641; // OBSOLETE: use OCR_NORMAL
  OCR_SIZENWSE    = 32642;
  OCR_SIZENESW    = 32643;
  OCR_SIZEWE      = 32644;
  OCR_SIZENS      = 32645;
  OCR_SIZEALL     = 32646;
  OCR_ICOCUR      = 32647; // OBSOLETE: use OIC_WINLOGO
  OCR_NO          = 32648;
  OCR_HAND        = 32649;
  OCR_APPSTARTING = 32650;

  OIC_SAMPLE      = 32512;
  OIC_HAND        = 32513;
  OIC_QUES        = 32514;
  OIC_BANG        = 32515;
  OIC_NOTE        = 32516;
  OIC_WINLOGO     = 32517;
  OIC_WARNING     = OIC_BANG;
  OIC_ERROR       = OIC_HAND;
  OIC_INFORMATION = OIC_NOTE;

  ORD_LANGDRIVER = 1; // The ordinal number for the entry point of language drivers.

//
// Standard Icon IDs
//

  IDI_APPLICATION = MAKEINTRESOURCE(32512);
  IDI_HAND        = MAKEINTRESOURCE(32513);
  IDI_QUESTION    = MAKEINTRESOURCE(32514);
  IDI_EXCLAMATION = MAKEINTRESOURCE(32515);
  IDI_ASTERISK    = MAKEINTRESOURCE(32516);
  IDI_WINLOGO = MAKEINTRESOURCE(32517);

  IDI_WARNING     = IDI_EXCLAMATION;
  IDI_ERROR       = IDI_HAND;
  IDI_INFORMATION = IDI_ASTERISK;

function LoadStringA(hInstance: HINSTANCE; uID: UINT; lpBuffer: LPSTR;
  nBufferMax: Integer): Integer; stdcall;
function LoadStringW(hInstance: HINSTANCE; uID: UINT; lpBuffer: LPWSTR;
  nBufferMax: Integer): Integer; stdcall;

{$IFDEF UNICODE}
function LoadString(hInstance: HINSTANCE; uID: UINT; lpBuffer: LPWSTR;
  nBufferMax: Integer): Integer; stdcall;
{$ELSE}
function LoadString(hInstance: HINSTANCE; uID: UINT; lpBuffer: LPSTR;
  nBufferMax: Integer): Integer; stdcall;
{$ENDIF}

//
// Dialog Box Command IDs
//

const
  IDOK     = 1;
  IDCANCEL = 2;
  IDABORT  = 3;
  IDRETRY  = 4;
  IDIGNORE = 5;
  IDYES    = 6;
  IDNO     = 7;
  IDCLOSE  = 8;
  IDHELP   = 9;

  IDTRYAGAIN = 10;
  IDCONTINUE = 11;

  IDTIMEOUT  = 32000;

//
// Control Manager Structures and Definitions
//

//
// Edit Control Styles
//

  ES_LEFT        = $0000;
  ES_CENTER      = $0001;
  ES_RIGHT       = $0002;
  ES_MULTILINE   = $0004;
  ES_UPPERCASE   = $0008;
  ES_LOWERCASE   = $0010;
  ES_PASSWORD    = $0020;
  ES_AUTOVSCROLL = $0040;
  ES_AUTOHSCROLL = $0080;
  ES_NOHIDESEL   = $0100;
  ES_OEMCONVERT  = $0400;
  ES_READONLY    = $0800;
  ES_WANTRETURN  = $1000;
  ES_NUMBER      = $2000;

//
// Edit Control Notification Codes
//

  EN_SETFOCUS  = $0100;
  EN_KILLFOCUS = $0200;
  EN_CHANGE    = $0300;
  EN_UPDATE    = $0400;
  EN_ERRSPACE  = $0500;
  EN_MAXTEXT   = $0501;
  EN_HSCROLL   = $0601;
  EN_VSCROLL   = $0602;

  EN_ALIGN_LTR_EC = $0700;
  EN_ALIGN_RTL_EC = $0701;

// Edit control EM_SETMARGIN parameters//

  EC_LEFTMARGIN  = $0001;
  EC_RIGHTMARGIN = $0002;
  EC_USEFONTINFO = $ffff;

// wParam of EM_GET/SETIMESTATUS //

  EMSIS_COMPOSITIONSTRING = $0001;

// lParam for EMSIS_COMPOSITIONSTRING //

  EIMES_GETCOMPSTRATONCE         = $0001;
  EIMES_CANCELCOMPSTRINFOCUS     = $0002;
  EIMES_COMPLETECOMPSTRKILLFOCUS = $0004;

//
// Edit Control Messages
//

  EM_GETSEL              = $00B0;
  EM_SETSEL              = $00B1;
  EM_GETRECT             = $00B2;
  EM_SETRECT             = $00B3;
  EM_SETRECTNP           = $00B4;
  EM_SCROLL              = $00B5;
  EM_LINESCROLL          = $00B6;
  EM_SCROLLCARET         = $00B7;
  EM_GETMODIFY           = $00B8;
  EM_SETMODIFY           = $00B9;
  EM_GETLINECOUNT        = $00BA;
  EM_LINEINDEX           = $00BB;
  EM_SETHANDLE           = $00BC;
  EM_GETHANDLE           = $00BD;
  EM_GETTHUMB            = $00BE;
  EM_LINELENGTH          = $00C1;
  EM_REPLACESEL          = $00C2;
  EM_GETLINE             = $00C4;
  EM_LIMITTEXT           = $00C5;
  EM_CANUNDO             = $00C6;
  EM_UNDO                = $00C7;
  EM_FMTLINES            = $00C8;
  EM_LINEFROMCHAR        = $00C9;
  EM_SETTABSTOPS         = $00CB;
  EM_SETPASSWORDCHAR     = $00CC;
  EM_EMPTYUNDOBUFFER     = $00CD;
  EM_GETFIRSTVISIBLELINE = $00CE;
  EM_SETREADONLY         = $00CF;
  EM_SETWORDBREAKPROC    = $00D0;
  EM_GETWORDBREAKPROC    = $00D1;
  EM_GETPASSWORDCHAR     = $00D2;
  EM_SETMARGINS          = $00D3;
  EM_GETMARGINS          = $00D4;
  EM_SETLIMITTEXT        = EM_LIMITTEXT; // ;win40 Name change
  EM_GETLIMITTEXT        = $00D5;
  EM_POSFROMCHAR         = $00D6;
  EM_CHARFROMPOS         = $00D7;

  EM_SETIMESTATUS = $00D8;
  EM_GETIMESTATUS = $00D9;

//
// EDITWORDBREAKPROC code values
//

  WB_LEFT        = 0;
  WB_RIGHT       = 1;
  WB_ISDELIMITER = 2;

//
// Button Control Styles
//

  BS_PUSHBUTTON      = $00000000;
  BS_DEFPUSHBUTTON   = $00000001;
  BS_CHECKBOX        = $00000002;
  BS_AUTOCHECKBOX    = $00000003;
  BS_RADIOBUTTON     = $00000004;
  BS_3STATE          = $00000005;
  BS_AUTO3STATE      = $00000006;
  BS_GROUPBOX        = $00000007;
  BS_USERBUTTON      = $00000008;
  BS_AUTORADIOBUTTON = $00000009;
  BS_PUSHBOX         = $0000000A;
  BS_OWNERDRAW       = $0000000B;
  BS_TYPEMASK        = $0000000F;
  BS_LEFTTEXT        = $00000020;
  BS_TEXT            = $00000000;
  BS_ICON            = $00000040;
  BS_BITMAP          = $00000080;
  BS_LEFT            = $00000100;
  BS_RIGHT           = $00000200;
  BS_CENTER          = $00000300;
  BS_TOP             = $00000400;
  BS_BOTTOM          = $00000800;
  BS_VCENTER         = $00000C00;
  BS_PUSHLIKE        = $00001000;
  BS_MULTILINE       = $00002000;
  BS_NOTIFY          = $00004000;
  BS_FLAT            = $00008000;
  BS_RIGHTBUTTON     = BS_LEFTTEXT;

//
// User Button Notification Codes
//

  BN_CLICKED       = 0;
  BN_PAINT         = 1;
  BN_HILITE        = 2;
  BN_UNHILITE      = 3;
  BN_DISABLE       = 4;
  BN_DOUBLECLICKED = 5;
  BN_PUSHED        = BN_HILITE;
  BN_UNPUSHED      = BN_UNHILITE;
  BN_DBLCLK        = BN_DOUBLECLICKED;
  BN_SETFOCUS      = 6;
  BN_KILLFOCUS     = 7;

//
// Button Control Messages
//

  BM_GETCHECK = $00F0;
  BM_SETCHECK = $00F1;
  BM_GETSTATE = $00F2;
  BM_SETSTATE = $00F3;
  BM_SETSTYLE = $00F4;
  BM_CLICK    = $00F5;
  BM_GETIMAGE = $00F6;
  BM_SETIMAGE = $00F7;

  BST_UNCHECKED     = $0000;
  BST_CHECKED       = $0001;
  BST_INDETERMINATE = $0002;
  BST_PUSHED        = $0004;
  BST_FOCUS         = $0008;

//
// Static Control Constants
//

  SS_LEFT           = $00000000;
  SS_CENTER         = $00000001;
  SS_RIGHT          = $00000002;
  SS_ICON           = $00000003;
  SS_BLACKRECT      = $00000004;
  SS_GRAYRECT       = $00000005;
  SS_WHITERECT      = $00000006;
  SS_BLACKFRAME     = $00000007;
  SS_GRAYFRAME      = $00000008;
  SS_WHITEFRAME     = $00000009;
  SS_USERITEM       = $0000000A;
  SS_SIMPLE         = $0000000B;
  SS_LEFTNOWORDWRAP = $0000000C;
  SS_OWNERDRAW      = $0000000D;
  SS_BITMAP         = $0000000E;
  SS_ENHMETAFILE    = $0000000F;
  SS_ETCHEDHORZ     = $00000010;
  SS_ETCHEDVERT     = $00000011;
  SS_ETCHEDFRAME    = $00000012;
  SS_TYPEMASK       = $0000001F;
  SS_REALSIZECONTROL = $00000040;
  SS_NOPREFIX       = $00000080; // Don't do "&" character translation
  SS_NOTIFY         = $00000100;
  SS_CENTERIMAGE    = $00000200;
  SS_RIGHTJUST      = $00000400;
  SS_REALSIZEIMAGE  = $00000800;
  SS_SUNKEN         = $00001000;
  SS_EDITCONTROL    = $00002000;
  SS_ENDELLIPSIS    = $00004000;
  SS_PATHELLIPSIS   = $00008000;
  SS_WORDELLIPSIS   = $0000C000;
  SS_ELLIPSISMASK   = $0000C000;

//
// Static Control Mesages
//

  STM_SETICON  = $0170;
  STM_GETICON  = $0171;
  STM_SETIMAGE = $0172;
  STM_GETIMAGE = $0173;
  STN_CLICKED  = 0;
  STN_DBLCLK   = 1;
  STN_ENABLE   = 2;
  STN_DISABLE  = 3;
  STM_MSGMAX   = $0174;

//
// Dialog window class
//

  WC_DIALOG = (MAKEINTATOM($8002));

//
// Get/SetWindowWord/Long offsets for use with WC_DIALOG windows
//

  DWL_MSGRESULT = 0;
  DWL_DLGPROC   = 4;
  DWL_USER      = 8;

  DWLP_MSGRESULT = 0;
  DWLP_DLGPROC   = DWLP_MSGRESULT + SizeOf(LRESULT);
  DWLP_USER      = DWLP_DLGPROC + SizeOf(DLGPROC);

//
// Dialog Manager Routines
//

function IsDialogMessageA(hDlg: HWND; const lpMsg: MSG): BOOL; stdcall;
function IsDialogMessageW(hDlg: HWND; const lpMsg: MSG): BOOL; stdcall;

{$IFDEF UNICODE}
function IsDialogMessage(hDlg: HWND; const lpMsg: MSG): BOOL; stdcall;
{$ELSE}
function IsDialogMessage(hDlg: HWND; const lpMsg: MSG): BOOL; stdcall;
{$ENDIF}

function MapDialogRect(hDlg: HWND; var lpRect: RECT): BOOL; stdcall;

function DlgDirListA(hDlg: HWND; lpPathSpec: LPSTR; nIDListBox: Integer;
  nIDStaticPath: Integer; uFileType: UINT): Integer; stdcall;
function DlgDirListW(hDlg: HWND; lpPathSpec: LPWSTR; nIDListBox: Integer;
  nIDStaticPath: Integer; uFileType: UINT): Integer; stdcall;

{$IFDEF UNICODE}
function DlgDirList(hDlg: HWND; lpPathSpec: LPWSTR; nIDListBox: Integer;
  nIDStaticPath: Integer; uFileType: UINT): Integer; stdcall;
{$ELSE}
function DlgDirList(hDlg: HWND; lpPathSpec: LPSTR; nIDListBox: Integer;
  nIDStaticPath: Integer; uFileType: UINT): Integer; stdcall;
{$ENDIF}

//
// DlgDirList, DlgDirListComboBox flags values
//

const
  DDL_READWRITE = $0000;
  DDL_READONLY  = $0001;
  DDL_HIDDEN    = $0002;
  DDL_SYSTEM    = $0004;
  DDL_DIRECTORY = $0010;
  DDL_ARCHIVE   = $0020;

  DDL_POSTMSGS  = $2000;
  DDL_DRIVES    = $4000;
  DDL_EXCLUSIVE = $8000;

function DlgDirSelectExA(hDlg: HWND; lpString: LPSTR; nCount, nIDListBox: Integer): BOOL; stdcall;
function DlgDirSelectExW(hDlg: HWND; lpString: LPWSTR; nCount, nIDListBox: Integer): BOOL; stdcall;

{$IFDEF UNICODE}
function DlgDirSelectEx(hDlg: HWND; lpString: LPWSTR; nCount, nIDListBox: Integer): BOOL; stdcall;
{$ELSE}
function DlgDirSelectEx(hDlg: HWND; lpString: LPSTR; nCount, nIDListBox: Integer): BOOL; stdcall;
{$ENDIF}

function DlgDirListComboBoxA(hDlg: HWND; lpPathSpec: LPSTR; nIDComboBox: Integer;
  nIDStaticPath: Integer; uFiletype: UINT): Integer; stdcall;
function DlgDirListComboBoxW(hDlg: HWND; lpPathSpec: LPWSTR; nIDComboBox: Integer;
  nIDStaticPath: Integer; uFiletype: UINT): Integer; stdcall;

{$IFDEF UNICODE}
function DlgDirListComboBox(hDlg: HWND; lpPathSpec: LPWSTR; nIDComboBox: Integer;
  nIDStaticPath: Integer; uFiletype: UINT): Integer; stdcall;
{$ELSE}
function DlgDirListComboBox(hDlg: HWND; lpPathSpec: LPSTR; nIDComboBox: Integer;
  nIDStaticPath: Integer; uFiletype: UINT): Integer; stdcall;
{$ENDIF}

function DlgDirSelectComboBoxExA(hDlg: HWND; lpString: LPSTR; nCount: Integer;
  nIDComboBox: Integer): BOOL; stdcall;
function DlgDirSelectComboBoxExW(hDlg: HWND; lpString: LPWSTR; nCount: Integer;
  nIDComboBox: Integer): BOOL; stdcall;

{$IFDEF UNICODE}
function DlgDirSelectComboBoxEx(hDlg: HWND; lpString: LPWSTR; nCount: Integer;
  nIDComboBox: Integer): BOOL; stdcall;
{$ELSE}
function DlgDirSelectComboBoxEx(hDlg: HWND; lpString: LPSTR; nCount: Integer;
  nIDComboBox: Integer): BOOL; stdcall;
{$ENDIF}

//
// Dialog Styles
//

const
  DS_ABSALIGN      = $01;
  DS_SYSMODAL      = $02;
  DS_LOCALEDIT     = $20; // Edit items get Local storage.
  DS_SETFONT       = $40; // User specified font for Dlg controls
  DS_MODALFRAME    = $80; // Can be combined with WS_CAPTION
  DS_NOIDLEMSG     = $100; // WM_ENTERIDLE message will not be sent
  DS_SETFOREGROUND = $200; // not in win3.1

  DS_3DLOOK       = $0004;
  DS_FIXEDSYS     = $0008;
  DS_NOFAILCREATE = $0010;
  DS_CONTROL      = $0400;
  DS_CENTER       = $0800;
  DS_CENTERMOUSE  = $1000;
  DS_CONTEXTHELP  = $2000;

  DS_SHELLFONT = (DS_SETFONT or DS_FIXEDSYS);

//#if(_WIN32_WCE >= 0x0500)
  DS_USEPIXELS = $8000;
//#endif

  DM_GETDEFID = (WM_USER+0);
  DM_SETDEFID = (WM_USER+1);

  DM_REPOSITION = (WM_USER+2);

//
// Returned in HIWORD() of DM_GETDEFID result if msg is supported
//

  DC_HASDEFID = $534B;

//
// Dialog Codes
//

  DLGC_WANTARROWS      = $0001; // Control wants arrow keys
  DLGC_WANTTAB         = $0002; // Control wants tab keys
  DLGC_WANTALLKEYS     = $0004; // Control wants all keys
  DLGC_WANTMESSAGE     = $0004; // Pass message to control
  DLGC_HASSETSEL       = $0008; // Understands EM_SETSEL message
  DLGC_DEFPUSHBUTTON   = $0010; // Default pushbutton
  DLGC_UNDEFPUSHBUTTON = $0020; // Non-default pushbutton
  DLGC_RADIOBUTTON     = $0040; // Radio button
  DLGC_WANTCHARS       = $0080; // Want WM_CHAR messages
  DLGC_STATIC          = $0100; // Static item: don't include
  DLGC_BUTTON          = $2000; // Button item: can be checked

  LB_CTLCODE = 0;

//
// Listbox Return Values
//

  LB_OKAY     = 0;
  LB_ERR      = DWORD(-1);
  LB_ERRSPACE = DWORD(-2);

//
//  The idStaticPath parameter to DlgDirList can have the following values
//  ORed if the list box should show other details of the files along with
//  the name of the files;
//
// all other details also will be returned

//
// Listbox Notification Codes
//

  LBN_ERRSPACE  = DWORD(-2);
  LBN_SELCHANGE = 1;
  LBN_DBLCLK    = 2;
  LBN_SELCANCEL = 3;
  LBN_SETFOCUS  = 4;
  LBN_KILLFOCUS = 5;

//
// Listbox messages
//

  LB_ADDSTRING           = $0180;
  LB_INSERTSTRING        = $0181;
  LB_DELETESTRING        = $0182;
  LB_SELITEMRANGEEX      = $0183;
  LB_RESETCONTENT        = $0184;
  LB_SETSEL              = $0185;
  LB_SETCURSEL           = $0186;
  LB_GETSEL              = $0187;
  LB_GETCURSEL           = $0188;
  LB_GETTEXT             = $0189;
  LB_GETTEXTLEN          = $018A;
  LB_GETCOUNT            = $018B;
  LB_SELECTSTRING        = $018C;
  LB_DIR                 = $018D;
  LB_GETTOPINDEX         = $018E;
  LB_FINDSTRING          = $018F;
  LB_GETSELCOUNT         = $0190;
  LB_GETSELITEMS         = $0191;
  LB_SETTABSTOPS         = $0192;
  LB_GETHORIZONTALEXTENT = $0193;
  LB_SETHORIZONTALEXTENT = $0194;
  LB_SETCOLUMNWIDTH      = $0195;
  LB_ADDFILE             = $0196;
  LB_SETTOPINDEX         = $0197;
  LB_GETITEMRECT         = $0198;
  LB_GETITEMDATA         = $0199;
  LB_SETITEMDATA         = $019A;
  LB_SELITEMRANGE        = $019B;
  LB_SETANCHORINDEX      = $019C;
  LB_GETANCHORINDEX      = $019D;
  LB_SETCARETINDEX       = $019E;
  LB_GETCARETINDEX       = $019F;
  LB_SETITEMHEIGHT       = $01A0;
  LB_GETITEMHEIGHT       = $01A1;
  LB_FINDSTRINGEXACT     = $01A2;
  LB_SETLOCALE           = $01A5;
  LB_GETLOCALE           = $01A6;
  LB_SETCOUNT            = $01A7;
  LB_INITSTORAGE   = $01A8;
  LB_ITEMFROMPOINT = $01A9;
  LB_MULTIPLEADDSTRING = $01B1;
  LB_GETLISTBOXINFO    = $01B2;

  LB_MSGMAX = $01B3;

//
// Listbox Styles
//

  LBS_NOTIFY            = $0001;
  LBS_SORT              = $0002;
  LBS_NOREDRAW          = $0004;
  LBS_MULTIPLESEL       = $0008;
  LBS_OWNERDRAWFIXED    = $0010;
  LBS_OWNERDRAWVARIABLE = $0020;
  LBS_HASSTRINGS        = $0040;
  LBS_USETABSTOPS       = $0080;
  LBS_NOINTEGRALHEIGHT  = $0100;
  LBS_MULTICOLUMN       = $0200;
  LBS_WANTKEYBOARDINPUT = $0400;
  LBS_EXTENDEDSEL       = $0800;
  LBS_DISABLENOSCROLL   = $1000;
  LBS_NODATA            = $2000;
  LBS_NOSEL             = $4000;
  LBS_COMBOBOX          = $8000;
  
  LBS_STANDARD          = (LBS_NOTIFY or LBS_SORT or WS_VSCROLL or WS_BORDER);

//
// Combo Box return Values
//

  CB_OKAY     = 0;
  CB_ERR      = DWORD(-1);
  CB_ERRSPACE = DWORD(-2);

//
// Combo Box Notification Codes
//

  CBN_ERRSPACE     = DWORD(-1);
  CBN_SELCHANGE    = 1;
  CBN_DBLCLK       = 2;
  CBN_SETFOCUS     = 3;
  CBN_KILLFOCUS    = 4;
  CBN_EDITCHANGE   = 5;
  CBN_EDITUPDATE   = 6;
  CBN_DROPDOWN     = 7;
  CBN_CLOSEUP      = 8;
  CBN_SELENDOK     = 9;
  CBN_SELENDCANCEL = 10;

//
// Combo Box styles
//

  CBS_SIMPLE            = $0001;
  CBS_DROPDOWN          = $0002;
  CBS_DROPDOWNLIST      = $0003;
  CBS_OWNERDRAWFIXED    = $0010;
  CBS_OWNERDRAWVARIABLE = $0020;
  CBS_AUTOHSCROLL       = $0040;
  CBS_OEMCONVERT        = $0080;
  CBS_SORT              = $0100;
  CBS_HASSTRINGS        = $0200;
  CBS_NOINTEGRALHEIGHT  = $0400;
  CBS_DISABLENOSCROLL   = $0800;
  CBS_UPPERCASE         = $2000;
  CBS_LOWERCASE         = $4000;

//
// Combo Box messages
//

  CB_GETEDITSEL            = $0140;
  CB_LIMITTEXT             = $0141;
  CB_SETEDITSEL            = $0142;
  CB_ADDSTRING             = $0143;
  CB_DELETESTRING          = $0144;
  CB_DIR                   = $0145;
  CB_GETCOUNT              = $0146;
  CB_GETCURSEL             = $0147;
  CB_GETLBTEXT             = $0148;
  CB_GETLBTEXTLEN          = $0149;
  CB_INSERTSTRING          = $014A;
  CB_RESETCONTENT          = $014B;
  CB_FINDSTRING            = $014C;
  CB_SELECTSTRING          = $014D;
  CB_SETCURSEL             = $014E;
  CB_SHOWDROPDOWN          = $014F;
  CB_GETITEMDATA           = $0150;
  CB_SETITEMDATA           = $0151;
  CB_GETDROPPEDCONTROLRECT = $0152;
  CB_SETITEMHEIGHT         = $0153;
  CB_GETITEMHEIGHT         = $0154;
  CB_SETEXTENDEDUI         = $0155;
  CB_GETEXTENDEDUI         = $0156;
  CB_GETDROPPEDSTATE       = $0157;
  CB_FINDSTRINGEXACT       = $0158;
  CB_SETLOCALE             = $0159;
  CB_GETLOCALE             = $015A;
  CB_GETTOPINDEX           = $015b;
  CB_SETTOPINDEX           = $015c;
  CB_GETHORIZONTALEXTENT   = $015d;
  CB_SETHORIZONTALEXTENT   = $015e;
  CB_GETDROPPEDWIDTH       = $015f;
  CB_SETDROPPEDWIDTH       = $0160;
  CB_INITSTORAGE           = $0161;
  CB_MULTIPLEADDSTRING     = $0163;
  CB_GETCOMBOBOXINFO       = $0164;
  CB_MSGMAX = $0165;

//
// Scroll Bar Styles
//

  SBS_HORZ                    = $0000;
  SBS_VERT                    = $0001;
  SBS_TOPALIGN                = $0002;
  SBS_LEFTALIGN               = $0002;
  SBS_BOTTOMALIGN             = $0004;
  SBS_RIGHTALIGN              = $0004;
  SBS_SIZEBOXTOPLEFTALIGN     = $0002;
  SBS_SIZEBOXBOTTOMRIGHTALIGN = $0004;
  SBS_SIZEBOX                 = $0008;
  SBS_SIZEGRIP                = $0010;

//
// Scroll bar messages
//

  SBM_SETPOS         = $00E0; // not in win3.1
  SBM_GETPOS         = $00E1; // not in win3.1
  SBM_SETRANGE       = $00E2; // not in win3.1
  SBM_SETRANGEREDRAW = $00E6; // not in win3.1
  SBM_GETRANGE       = $00E3; // not in win3.1
  SBM_ENABLE_ARROWS  = $00E4; // not in win3.1
  SBM_SETSCROLLINFO  = $00E9;
  SBM_GETSCROLLINFO  = $00EA;
  
  SBM_GETSCROLLBARINFO = $00EB;

  SIF_RANGE           = $0001;
  SIF_PAGE            = $0002;
  SIF_POS             = $0004;
  SIF_DISABLENOSCROLL = $0008;
  SIF_TRACKPOS        = $0010;
  SIF_ALL             = (SIF_RANGE or SIF_PAGE or SIF_POS or SIF_TRACKPOS);

type
  LPSCROLLINFO = ^SCROLLINFO;
  tagSCROLLINFO = record
    cbSize: UINT;
    fMask: UINT;
    nMin: Integer;
    nMax: Integer;
    nPage: UINT;
    nPos: Integer;
    nTrackPos: Integer;
  end;
  SCROLLINFO = tagSCROLLINFO;
  TScrollInfo = SCROLLINFO;
  PScrollInfo = LPSCROLLINFO;

function SetScrollInfo(hwnd: HWND; fnBar: Integer; const lpsi: SCROLLINFO;
  fRedraw: BOOL): Integer; stdcall;

function GetScrollInfo(hwnd: HWND; fnBar: Integer; var lpsi: SCROLLINFO): BOOL; stdcall;

//
// MDI client style bits
//

const
  MDIS_ALLCHILDSTYLES = $0001;

//
// wParam Flags for WM_MDITILE and WM_MDICASCADE messages.
//

const
  MDITILE_VERTICAL     = $0000; // not in win3.1
  MDITILE_HORIZONTAL   = $0001; // not in win3.1
  MDITILE_SKIPDISABLED = $0002; // not in win3.1
  MDITILE_ZORDER       = $0004;

type
  LPMDICREATESTRUCTA = ^MDICREATESTRUCTA;
  tagMDICREATESTRUCTA = record
    szClass: LPCSTR;
    szTitle: LPCSTR;
    hOwner: HANDLE;
    x: Integer;
    y: Integer;
    cx: Integer;
    cy: Integer;
    style: DWORD;
    lParam: LPARAM; // app-defined stuff//
  end;
  MDICREATESTRUCTA = tagMDICREATESTRUCTA;
  TMdiCreateStructA = MDICREATESTRUCTA;
  PMdiCreateStructA = LPMDICREATESTRUCTA;

  LPMDICREATESTRUCTW = ^MDICREATESTRUCTW;
  tagMDICREATESTRUCTW = record
    szClass: LPCWSTR;
    szTitle: LPCWSTR;
    hOwner: HANDLE;
    x: Integer;
    y: Integer;
    cx: Integer;
    cy: Integer;
    style: DWORD;
    lParam: LPARAM; // app-defined stuff//
  end;
  MDICREATESTRUCTW = tagMDICREATESTRUCTW;
  TMdiCreateStructW = MDICREATESTRUCTW;
  PMdiCreateStructW = LPMDICREATESTRUCTW;

{$IFDEF UNICODE}
  MDICREATESTRUCT = MDICREATESTRUCTW;
  LPMDICREATESTRUCT = LPMDICREATESTRUCTW;
  TMdiCreateStruct = TMdiCreateStructW;
  PMdiCreateStruct = PMdiCreateStructW;
{$ELSE}
  MDICREATESTRUCT = MDICREATESTRUCTA;
  LPMDICREATESTRUCT = LPMDICREATESTRUCTA;
  TMdiCreateStruct = TMdiCreateStructA;
  PMdiCreateStruct = PMdiCreateStructA;
{$ENDIF}

  LPCLIENTCREATESTRUCT = ^CLIENTCREATESTRUCT;
  tagCLIENTCREATESTRUCT = record
    hWindowMenu: HANDLE;
    idFirstChild: UINT;
  end;
  CLIENTCREATESTRUCT = tagCLIENTCREATESTRUCT;
  TClientCreateStruct = CLIENTCREATESTRUCT;
  PClientCreateStruct = LPCLIENTCREATESTRUCT;

function DefFrameProcA(hWnd: HWND; hWndMDIClient: HWND; uMsg: UINT;
  wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function DefFrameProcW(hWnd: HWND; hWndMDIClient: HWND; uMsg: UINT;
  wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

{$IFDEF UNICODE}
function DefFrameProc(hWnd: HWND; hWndMDIClient: HWND; uMsg: UINT;
  wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
{$ELSE}
function DefFrameProc(hWnd: HWND; hWndMDIClient: HWND; uMsg: UINT;
  wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
{$ENDIF}

function DefMDIChildProcA(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function DefMDIChildProcW(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

{$IFDEF UNICODE}
function DefMDIChildProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
{$ELSE}
function DefMDIChildProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
{$ENDIF}

function TranslateMDISysAccel(hWndClient: HWND; const lpMsg: MSG): BOOL; stdcall;

function ArrangeIconicWindows(hWnd: HWND): UINT; stdcall;

function CreateMDIWindowA(lpClassName, lpWindowName: LPCSTR; dwStyle: DWORD;
  X, Y, nWidth, nHeight: Integer; hWndParent: HWND; hInstance: HINSTANCE;
  lParam: LPARAM): HWND; stdcall;
function CreateMDIWindowW(lpClassName, lpWindowName: LPCWSTR; dwStyle: DWORD;
  X, Y, nWidth, nHeight: Integer; hWndParent: HWND; hInstance: HINSTANCE;
  lParam: LPARAM): HWND; stdcall;

{$IFDEF UNICODE}
function CreateMDIWindow(lpClassName, lpWindowName: LPCWSTR; dwStyle: DWORD;
  X, Y, nWidth, nHeight: Integer; hWndParent: HWND; hInstance: HINSTANCE;
  lParam: LPARAM): HWND; stdcall;
{$ELSE}
function CreateMDIWindow(lpClassName, lpWindowName: LPCSTR; dwStyle: DWORD;
  X, Y, nWidth, nHeight: Integer; hWndParent: HWND; hInstance: HINSTANCE;
  lParam: LPARAM): HWND; stdcall;
{$ENDIF}

function TileWindows(hwndParent: HWND; wHow: UINT; lpRect: LPRECT; cKids: UINT;
  hwnd: HWND; lpKids: LPHWND): WORD; stdcall;

function CascadeWindows(hwndParent: HWND; wHow: UINT; lpRect: LPRECT;
  cKids: UINT; lpKids: LPHWND): WORD; stdcall;

//***** Help support ********************************************************/

type
  HELPPOLY = DWORD;

  LPMULTIKEYHELPA = ^MULTIKEYHELPA;
  tagMULTIKEYHELPA = record
    mkSize: DWORD;
    mkKeylist: CHAR;
    szKeyphrase: array [0..0] of CHAR;
  end;
  MULTIKEYHELPA = tagMULTIKEYHELPA;
  TMultiKeyHelpA = MULTIKEYHELPA;
  PMultiKeyHelpA = LPMULTIKEYHELPA;

  LPMULTIKEYHELPW = ^MULTIKEYHELPW;
  tagMULTIKEYHELPW = record
    mkSize: DWORD;
    mkKeylist: WCHAR;
    szKeyphrase: array [0..0] of WCHAR;
  end;
  MULTIKEYHELPW = tagMULTIKEYHELPW;
  TMultiKeyHelpW = MULTIKEYHELPW;
  PMultiKeyHelpW = LPMULTIKEYHELPW;

{$IFDEF UNICODE}
  MULTIKEYHELP = MULTIKEYHELPW;
  LPMULTIKEYHELP = LPMULTIKEYHELPW;
  TMultiKeyHelp = TMultiKeyHelpW;
  PMultiKeyHelp = PMultiKeyHelpW;
{$ELSE}
  MULTIKEYHELP = MULTIKEYHELPA;
  LPMULTIKEYHELP = LPMULTIKEYHELPA;
  TMultiKeyHelp = TMultiKeyHelpA;
  PMultiKeyHelp = PMultiKeyHelpA;
{$ENDIF}

  LPHELPWININFOA = ^HELPWININFOA;
  tagHELPWININFOA = record
    wStructSize: Integer;
    x: Integer;
    y: Integer;
    dx: Integer;
    dy: Integer;
    wMax: Integer;
    rgchMember: array [0..1] of CHAR;
  end;
  HELPWININFOA = tagHELPWININFOA;
  THelpWinInfoA = HELPWININFOA;
  PHelpWinInfoA = LPHELPWININFOA;

  LPHELPWININFOW = ^HELPWININFOW;
  tagHELPWININFOW = record
    wStructSize: Integer;
    x: Integer;
    y: Integer;
    dx: Integer;
    dy: Integer;
    wMax: Integer;
    rgchMember: array [0..1] of WCHAR;
  end;
  HELPWININFOW = tagHELPWININFOW;
  THelpWinInfoW = HELPWININFOW;
  PHelpWinInfoW = LPHELPWININFOW;

{$IFDEF UNICODE}
  HELPWININFO = HELPWININFOW;
  LPHELPWININFO = LPHELPWININFOW;
  THelpWinInfo = THelpWinInfoW;
  PHelpWinInfo = PHelpWinInfoW;
{$ELSE}
  HELPWININFO = HELPWININFOA;
  LPHELPWININFO = LPHELPWININFOA;
  THelpWinInfo = THelpWinInfoA;
  PHelpWinInfo = PHelpWinInfoA;
{$ENDIF}

//
// Commands to pass to WinHelp()
//

const
  HELP_CONTEXT      = $0001; // Display topic in ulTopic
  HELP_QUIT         = $0002; // Terminate help
  HELP_INDEX        = $0003; // Display index
  HELP_CONTENTS     = $0003;
  HELP_HELPONHELP   = $0004; // Display help on using help
  HELP_SETINDEX     = $0005; // Set current Index for multi index help
  HELP_SETCONTENTS  = $0005;
  HELP_CONTEXTPOPUP = $0008;
  HELP_FORCEFILE    = $0009;
  HELP_KEY          = $0101; // Display topic for keyword in offabData
  HELP_COMMAND      = $0102;
  HELP_PARTIALKEY   = $0105;
  HELP_MULTIKEY     = $0201;
  HELP_SETWINPOS    = $0203;

  HELP_CONTEXTMENU  = $000a;
  HELP_FINDER       = $000b;
  HELP_WM_HELP      = $000c;
  HELP_SETPOPUP_POS = $000d;

  HELP_TCARD              = $8000;
  HELP_TCARD_DATA         = $0010;
  HELP_TCARD_OTHER_CALLER = $0011;

// These are in winhelp.h in Win95.

  IDH_NO_HELP             = 28440;
  IDH_MISSING_CONTEXT     = 28441; // Control doesn't have matching help context
  IDH_GENERIC_HELP_BUTTON = 28442; // Property sheet help button
  IDH_OK                  = 28443;
  IDH_CANCEL              = 28444;
  IDH_HELP                = 28445;

function WinHelpA(hWndMain: HWND; lpszHelp: LPCSTR; uCommand: UINT; dwData: ULONG_PTR): BOOL; stdcall;
function WinHelpW(hWndMain: HWND; lpszHelp: LPCWSTR; uCommand: UINT; dwData: ULONG_PTR): BOOL; stdcall;

{$IFDEF UNICODE}
function WinHelp(hWndMain: HWND; lpszHelp: LPCWSTR; uCommand: UINT; dwData: ULONG_PTR): BOOL; stdcall;
{$ELSE}
function WinHelp(hWndMain: HWND; lpszHelp: LPCSTR; uCommand: UINT; dwData: ULONG_PTR): BOOL; stdcall;
{$ENDIF}

const
  GR_GDIOBJECTS  = 0; // Count of GDI objects
  GR_USEROBJECTS = 1; // Count of USER objects

function GetGuiResources(hProcess: HANDLE; uiFlags: DWORD): DWORD; stdcall;

//
// Parameter for SystemParametersInfo()
//

const
  SPI_GETBEEP               = 1;
  SPI_SETBEEP               = 2;
  SPI_GETMOUSE              = 3;
  SPI_SETMOUSE              = 4;
  SPI_GETBORDER             = 5;
  SPI_SETBORDER             = 6;
  SPI_GETKEYBOARDSPEED      = 10;
  SPI_SETKEYBOARDSPEED      = 11;
  SPI_LANGDRIVER            = 12;
  SPI_ICONHORIZONTALSPACING = 13;
  SPI_GETSCREENSAVETIMEOUT  = 14;
  SPI_SETSCREENSAVETIMEOUT  = 15;
  SPI_GETSCREENSAVEACTIVE   = 16;
  SPI_SETSCREENSAVEACTIVE   = 17;
  SPI_GETGRIDGRANULARITY    = 18;
  SPI_SETGRIDGRANULARITY    = 19;
  SPI_SETDESKWALLPAPER      = 20;
  SPI_SETDESKPATTERN        = 21;
  SPI_GETKEYBOARDDELAY      = 22;
  SPI_SETKEYBOARDDELAY      = 23;
  SPI_ICONVERTICALSPACING   = 24;
  SPI_GETICONTITLEWRAP      = 25;
  SPI_SETICONTITLEWRAP      = 26;
  SPI_GETMENUDROPALIGNMENT  = 27;
  SPI_SETMENUDROPALIGNMENT  = 28;
  SPI_SETDOUBLECLKWIDTH     = 29;
  SPI_SETDOUBLECLKHEIGHT    = 30;
  SPI_GETICONTITLELOGFONT   = 31;
  SPI_SETDOUBLECLICKTIME    = 32;
  SPI_SETMOUSEBUTTONSWAP    = 33;
  SPI_SETICONTITLELOGFONT   = 34;
  SPI_GETFASTTASKSWITCH     = 35;
  SPI_SETFASTTASKSWITCH     = 36;
  SPI_SETDRAGFULLWINDOWS    = 37;
  SPI_GETDRAGFULLWINDOWS    = 38;
  SPI_GETNONCLIENTMETRICS   = 41;
  SPI_SETNONCLIENTMETRICS   = 42;
  SPI_GETMINIMIZEDMETRICS   = 43;
  SPI_SETMINIMIZEDMETRICS   = 44;
  SPI_GETICONMETRICS        = 45;
  SPI_SETICONMETRICS        = 46;
  SPI_SETWORKAREA           = 47;
  SPI_GETWORKAREA           = 48;
  SPI_SETPENWINDOWS         = 49;

  SPI_GETHIGHCONTRAST       = 66;
  SPI_SETHIGHCONTRAST       = 67;
  SPI_GETKEYBOARDPREF       = 68;
  SPI_SETKEYBOARDPREF       = 69;
  SPI_GETSCREENREADER       = 70;
  SPI_SETSCREENREADER       = 71;
  SPI_GETANIMATION          = 72;
  SPI_SETANIMATION          = 73;
  SPI_GETFONTSMOOTHING      = 74;
  SPI_SETFONTSMOOTHING      = 75;
  SPI_SETDRAGWIDTH          = 76;
  SPI_SETDRAGHEIGHT         = 77;
  SPI_SETHANDHELD           = 78;
  SPI_GETLOWPOWERTIMEOUT    = 79;
  SPI_GETPOWEROFFTIMEOUT    = 80;
  SPI_SETLOWPOWERTIMEOUT    = 81;
  SPI_SETPOWEROFFTIMEOUT    = 82;
  SPI_GETLOWPOWERACTIVE     = 83;
  SPI_GETPOWEROFFACTIVE     = 84;
  SPI_SETLOWPOWERACTIVE     = 85;
  SPI_SETPOWEROFFACTIVE     = 86;
  SPI_SETCURSORS            = 87;
  SPI_SETICONS              = 88;
  SPI_GETDEFAULTINPUTLANG   = 89;
  SPI_SETDEFAULTINPUTLANG   = 90;
  SPI_SETLANGTOGGLE         = 91;
  SPI_GETWINDOWSEXTENSION   = 92;
  SPI_SETMOUSETRAILS        = 93;
  SPI_GETMOUSETRAILS        = 94;
  SPI_SETSCREENSAVERRUNNING = 97;
  SPI_SCREENSAVERRUNNING    = SPI_SETSCREENSAVERRUNNING;
  SPI_GETFILTERKEYS         = 50;
  SPI_SETFILTERKEYS         = 51;
  SPI_GETTOGGLEKEYS         = 52;
  SPI_SETTOGGLEKEYS         = 53;
  SPI_GETMOUSEKEYS          = 54;
  SPI_SETMOUSEKEYS          = 55;
  SPI_GETSHOWSOUNDS         = 56;
  SPI_SETSHOWSOUNDS         = 57;
  SPI_GETSTICKYKEYS         = 58;
  SPI_SETSTICKYKEYS         = 59;
  SPI_GETACCESSTIMEOUT      = 60;
  SPI_SETACCESSTIMEOUT      = 61;
  SPI_GETSERIALKEYS         = 62;
  SPI_SETSERIALKEYS         = 63;
  SPI_GETSOUNDSENTRY        = 64;
  SPI_SETSOUNDSENTRY        = 65;
  SPI_GETSNAPTODEFBUTTON    = 95;
  SPI_SETSNAPTODEFBUTTON    = 96;
  SPI_GETMOUSEHOVERWIDTH    = 98;
  SPI_SETMOUSEHOVERWIDTH    = 99;
  SPI_GETMOUSEHOVERHEIGHT   = 100;
  SPI_SETMOUSEHOVERHEIGHT   = 101;
  SPI_GETMOUSEHOVERTIME     = 102;
  SPI_SETMOUSEHOVERTIME     = 103;
  SPI_GETWHEELSCROLLLINES   = 104;
  SPI_SETWHEELSCROLLLINES   = 105;
  SPI_GETMENUSHOWDELAY      = 106;
  SPI_SETMENUSHOWDELAY      = 107;

  SPI_GETSHOWIMEUI = 110;
  SPI_SETSHOWIMEUI = 111;

  SPI_GETMOUSESPEED         = 112;
  SPI_SETMOUSESPEED         = 113;
  SPI_GETSCREENSAVERRUNNING = 114;
  SPI_GETDESKWALLPAPER      = 115;

  SPI_GETACTIVEWINDOWTRACKING   = $1000;
  SPI_SETACTIVEWINDOWTRACKING   = $1001;
  SPI_GETMENUANIMATION          = $1002;
  SPI_SETMENUANIMATION          = $1003;
  SPI_GETCOMBOBOXANIMATION      = $1004;
  SPI_SETCOMBOBOXANIMATION      = $1005;
  SPI_GETLISTBOXSMOOTHSCROLLING = $1006;
  SPI_SETLISTBOXSMOOTHSCROLLING = $1007;
  SPI_GETGRADIENTCAPTIONS       = $1008;
  SPI_SETGRADIENTCAPTIONS       = $1009;
  SPI_GETKEYBOARDCUES           = $100A;
  SPI_SETKEYBOARDCUES           = $100B;
  SPI_GETMENUUNDERLINES         = SPI_GETKEYBOARDCUES;
  SPI_SETMENUUNDERLINES         = SPI_SETKEYBOARDCUES;
  SPI_GETACTIVEWNDTRKZORDER     = $100C;
  SPI_SETACTIVEWNDTRKZORDER     = $100D;
  SPI_GETHOTTRACKING            = $100E;
  SPI_SETHOTTRACKING            = $100F;
  SPI_GETMENUFADE               = $1012;
  SPI_SETMENUFADE               = $1013;
  SPI_GETSELECTIONFADE          = $1014;
  SPI_SETSELECTIONFADE          = $1015;
  SPI_GETTOOLTIPANIMATION       = $1016;
  SPI_SETTOOLTIPANIMATION       = $1017;
  SPI_GETTOOLTIPFADE            = $1018;
  SPI_SETTOOLTIPFADE            = $1019;
  SPI_GETCURSORSHADOW           = $101A;
  SPI_SETCURSORSHADOW           = $101B;

  SPI_GETMOUSESONAR             = $101C;
  SPI_SETMOUSESONAR             = $101D;
  SPI_GETMOUSECLICKLOCK         = $101E;
  SPI_SETMOUSECLICKLOCK         = $101F;
  SPI_GETMOUSEVANISH            = $1020;
  SPI_SETMOUSEVANISH            = $1021;
  SPI_GETFLATMENU               = $1022;
  SPI_SETFLATMENU               = $1023;
  SPI_GETDROPSHADOW             = $1024;
  SPI_SETDROPSHADOW             = $1025;
  SPI_GETBLOCKSENDINPUTRESETS   = $1026;
  SPI_SETBLOCKSENDINPUTRESETS   = $1027;

  SPI_GETUIEFFECTS = $103E;
  SPI_SETUIEFFECTS = $103F;

  SPI_GETFOREGROUNDLOCKTIMEOUT = $2000;
  SPI_SETFOREGROUNDLOCKTIMEOUT = $2001;
  SPI_GETACTIVEWNDTRKTIMEOUT   = $2002;
  SPI_SETACTIVEWNDTRKTIMEOUT   = $2003;
  SPI_GETFOREGROUNDFLASHCOUNT  = $2004;
  SPI_SETFOREGROUNDFLASHCOUNT  = $2005;
  SPI_GETCARETWIDTH            = $2006;
  SPI_SETCARETWIDTH            = $2007;

  SPI_GETMOUSECLICKLOCKTIME    = $2008;
  SPI_SETMOUSECLICKLOCKTIME    = $2009;
  SPI_GETFONTSMOOTHINGTYPE     = $200A;
  SPI_SETFONTSMOOTHINGTYPE     = $200B;

// constants for SPI_GETFONTSMOOTHINGTYPE and SPI_SETFONTSMOOTHINGTYPE

  FE_FONTSMOOTHINGSTANDARD     = $0001;
  FE_FONTSMOOTHINGCLEARTYPE    = $0002;
  FE_FONTSMOOTHINGDOCKING      = $8000;

  SPI_GETFONTSMOOTHINGCONTRAST = $200C;
  SPI_SETFONTSMOOTHINGCONTRAST = $200D;

  SPI_GETFOCUSBORDERWIDTH      = $200E;
  SPI_SETFOCUSBORDERWIDTH      = $200F;
  SPI_GETFOCUSBORDERHEIGHT     = $2010;
  SPI_SETFOCUSBORDERHEIGHT     = $2011;

  SPI_GETFONTSMOOTHINGORIENTATION = $2012;
  SPI_SETFONTSMOOTHINGORIENTATION = $2013;

// constants for SPI_GETFONTSMOOTHINGORIENTATION and SPI_SETFONTSMOOTHINGORIENTATION:

  FE_FONTSMOOTHINGORIENTATIONBGR = $0000;
  FE_FONTSMOOTHINGORIENTATIONRGB = $0001;

//
// Flags
//

  SPIF_UPDATEINIFILE    = $0001;
  SPIF_SENDWININICHANGE = $0002;
  SPIF_SENDCHANGE       = SPIF_SENDWININICHANGE;

  METRICS_USEDEFAULT = DWORD(-1);

type
  LPNONCLIENTMETRICSA = ^NONCLIENTMETRICSA;
  tagNONCLIENTMETRICSA = record
    cbSize: UINT;
    iBorderWidth: Integer;
    iScrollWidth: Integer;
    iScrollHeight: Integer;
    iCaptionWidth: Integer;
    iCaptionHeight: Integer;
    lfCaptionFont: LOGFONTA;
    iSmCaptionWidth: Integer;
    iSmCaptionHeight: Integer;
    lfSmCaptionFont: LOGFONTA;
    iMenuWidth: Integer;
    iMenuHeight: Integer;
    lfMenuFont: LOGFONTA;
    lfStatusFont: LOGFONTA;
    lfMessageFont: LOGFONTA;
  end;
  NONCLIENTMETRICSA = tagNONCLIENTMETRICSA;
  TNonClientMetricsA = NONCLIENTMETRICSA;
  PNonClientMetricsA = LPNONCLIENTMETRICSA;

  LPNONCLIENTMETRICSW = ^NONCLIENTMETRICSW;
  tagNONCLIENTMETRICSW = record
    cbSize: UINT;
    iBorderWidth: Integer;
    iScrollWidth: Integer;
    iScrollHeight: Integer;
    iCaptionWidth: Integer;
    iCaptionHeight: Integer;
    lfCaptionFont: LOGFONTW;
    iSmCaptionWidth: Integer;
    iSmCaptionHeight: Integer;
    lfSmCaptionFont: LOGFONTW;
    iMenuWidth: Integer;
    iMenuHeight: Integer;
    lfMenuFont: LOGFONTW;
    lfStatusFont: LOGFONTW;
    lfMessageFont: LOGFONTW;
  end;
  NONCLIENTMETRICSW = tagNONCLIENTMETRICSW;
  TNonClientMetricsW = NONCLIENTMETRICSW;
  PNonClientMetricsW = LPNONCLIENTMETRICSW;

{$IFDEF UNICODE}
  NONCLIENTMETRICS = NONCLIENTMETRICSW;
  LPNONCLIENTMETRICS = LPNONCLIENTMETRICSW;
  TNonClientMetrics = TNonClientMetricsW;
  PNonClientMetrics = PNonClientMetricsW;
{$ELSE}
  NONCLIENTMETRICS = NONCLIENTMETRICSA;
  LPNONCLIENTMETRICS = LPNONCLIENTMETRICSA;
  TNonClientMetrics = TNonClientMetricsA;
  PNonClientMetrics = PNonClientMetricsA;
{$ENDIF}

const
  ARW_BOTTOMLEFT  = $0000;
  ARW_BOTTOMRIGHT = $0001;
  ARW_TOPLEFT     = $0002;
  ARW_TOPRIGHT    = $0003;
  ARW_STARTMASK   = $0003;
  ARW_STARTRIGHT  = $0001;
  ARW_STARTTOP    = $0002;

  ARW_LEFT  = $0000;
  ARW_RIGHT = $0000;
  ARW_UP    = $0004;
  ARW_DOWN  = $0004;
  ARW_HIDE  = $0008;

type
  LPMINIMIZEDMETRICS = ^MINIMIZEDMETRICS;
  tagMINIMIZEDMETRICS = record
    cbSize: UINT;
    iWidth: Integer;
    iHorzGap: Integer;
    iVertGap: Integer;
    iArrange: Integer;
  end;
  MINIMIZEDMETRICS = tagMINIMIZEDMETRICS;
  TMinimizedMetrics = MINIMIZEDMETRICS;
  PMinimizedMetrics = LPMINIMIZEDMETRICS;

  LPICONMETRICSA = ^ICONMETRICSA;
  tagICONMETRICSA = record
    cbSize: UINT;
    iHorzSpacing: Integer;
    iVertSpacing: Integer;
    iTitleWrap: Integer;
    lfFont: LOGFONTA;
  end;
  ICONMETRICSA = tagICONMETRICSA;
  TIconMetricsA = ICONMETRICSA;
  PIconMetricsA = LPICONMETRICSA;

  LPICONMETRICSW = ^ICONMETRICSW;
  tagICONMETRICSW = record
    cbSize: UINT;
    iHorzSpacing: Integer;
    iVertSpacing: Integer;
    iTitleWrap: Integer;
    lfFont: LOGFONTW;
  end;
  ICONMETRICSW = tagICONMETRICSW;
  TIconMetricsW = ICONMETRICSW;
  PIconMetricsW = LPICONMETRICSW;

{$IFDEF UNICODE}
  ICONMETRICS = ICONMETRICSW;
  LPICONMETRICS = LPICONMETRICSW;
  TIconMetrics = TIconMetricsW;
  PIconMetrics = PIconMetricsW;
{$ELSE}
  ICONMETRICS = ICONMETRICSA;
  LPICONMETRICS = LPICONMETRICSA;
  TIconMetrics = TIconMetricsA;
  PIconMetrics = PIconMetricsA;
{$ENDIF}

  LPANIMATIONINFO = ^ANIMATIONINFO;
  tagANIMATIONINFO = record
    cbSize: UINT;
    iMinAnimate: Integer;
  end;
  ANIMATIONINFO = tagANIMATIONINFO;
  TAnimationInfo = ANIMATIONINFO;
  PAnimationInfo = LPANIMATIONINFO;

  LPSERIALKEYSA = ^SERIALKEYSA;
  tagSERIALKEYSA = record
    cbSize: UINT;
    dwFlags: DWORD;
    lpszActivePort: LPSTR;
    lpszPort: LPSTR;
    iBaudRate: UINT;
    iPortState: UINT;
    iActive: UINT;
  end;
  SERIALKEYSA = tagSERIALKEYSA;
  TSerialKeysA = SERIALKEYSA;
  PSerialKeysA = LPSERIALKEYSA;

  LPSERIALKEYSW = ^SERIALKEYSW;
  tagSERIALKEYSW = record
    cbSize: UINT;
    dwFlags: DWORD;
    lpszActivePort: LPWSTR;
    lpszPort: LPWSTR;
    iBaudRate: UINT;
    iPortState: UINT;
    iActive: UINT;
  end;
  SERIALKEYSW = tagSERIALKEYSW;
  TSerialKeysW = SERIALKEYSW;
  PSerialKeysW = LPSERIALKEYSW;

{$IFDEF UNICODE}
  SERIALKEYS = SERIALKEYSW;
  LPSERIALKEYS = LPSERIALKEYSW;
  TSerialKeys = TSerialKeysW;
  PSerialKeys = PSerialKeysW;
{$ELSE}
  SERIALKEYS = SERIALKEYSA;
  LPSERIALKEYS = LPSERIALKEYSA;
  TSerialKeys = TSerialKeysA;
  PSerialKeys = PSerialKeysA;
{$ENDIF}

// flags for SERIALKEYS dwFlags field//

const
  SERKF_SERIALKEYSON = $00000001;
  SERKF_AVAILABLE    = $00000002;
  SERKF_INDICATOR    = $00000004;

type
  LPHIGHCONTRASTA = ^HIGHCONTRASTA;
  tagHIGHCONTRASTA = record
    cbSize: UINT;
    dwFlags: DWORD;
    lpszDefaultScheme: LPSTR;
  end;
  HIGHCONTRASTA = tagHIGHCONTRASTA;
  THighContrastA = HIGHCONTRASTA;
  PHighContrastA = LPHIGHCONTRASTA;

  LPHIGHCONTRASTW = ^HIGHCONTRASTW;
  tagHIGHCONTRASTW = record
    cbSize: UINT;
    dwFlags: DWORD;
    lpszDefaultScheme: LPWSTR;
  end;
  HIGHCONTRASTW = tagHIGHCONTRASTW;
  THighContrastW = HIGHCONTRASTW;
  PHighContrastW = LPHIGHCONTRASTW;

{$IFDEF UNICODE}
  HIGHCONTRAST = HIGHCONTRASTW;
  LPHIGHCONTRAST = LPHIGHCONTRASTW;
  THighContrast = THighContrastW;
  PHighContrast = PHighContrastW;  
{$ELSE}
  HIGHCONTRAST = HIGHCONTRASTA;
  LPHIGHCONTRAST = LPHIGHCONTRASTA;
  THighContrast = THighContrastA;
  PHighContrast = PHighContrastA;
{$ENDIF}

// flags for HIGHCONTRAST dwFlags field//

const
  HCF_HIGHCONTRASTON  = $00000001;
  HCF_AVAILABLE       = $00000002;
  HCF_HOTKEYACTIVE    = $00000004;
  HCF_CONFIRMHOTKEY   = $00000008;
  HCF_HOTKEYSOUND     = $00000010;
  HCF_INDICATOR       = $00000020;
  HCF_HOTKEYAVAILABLE = $00000040;

// Flags for ChangeDisplaySettings//

  CDS_UPDATEREGISTRY  = $00000001;
  CDS_TEST            = $00000002;
  CDS_FULLSCREEN      = $00000004;
  CDS_GLOBAL          = $00000008;
  CDS_SET_PRIMARY     = $00000010;
  CDS_VIDEOPARAMETERS = $00000020;
  CDS_RESET           = $40000000;
  CDS_NORESET         = $10000000;

// #include <tvout.h>

// Return values for ChangeDisplaySettings

  DISP_CHANGE_SUCCESSFUL = 0;
  DISP_CHANGE_RESTART    = 1;
  DISP_CHANGE_FAILED     = DWORD(-1);
  DISP_CHANGE_BADMODE    = DWORD(-2);
  DISP_CHANGE_NOTUPDATED = DWORD(-3);
  DISP_CHANGE_BADFLAGS   = DWORD(-4);
  DISP_CHANGE_BADPARAM   = DWORD(-5);
  DISP_CHANGE_BADDUALVIEW = DWORD(-6);

function ChangeDisplaySettingsA(lpDevMode: LPDEVMODEA; dwFlags: DWORD): LONG; stdcall;
function ChangeDisplaySettingsW(lpDevMode: LPDEVMODEW; dwFlags: DWORD): LONG; stdcall;

{$IFDEF UNICODE}
function ChangeDisplaySettings(lpDevMode: LPDEVMODEW; dwFlags: DWORD): LONG; stdcall;
{$ELSE}
function ChangeDisplaySettings(lpDevMode: LPDEVMODEA; dwFlags: DWORD): LONG; stdcall;
{$ENDIF}

function ChangeDisplaySettingsExA(lpszDeviceName: LPCSTR; lpDevMode: LPDEVMODEA;
  hwnd: HWND; dwflags: DWORD; lParam: LPVOID): LONG; stdcall;
function ChangeDisplaySettingsExW(lpszDeviceName: LPCWSTR; lpDevMode: LPDEVMODEW;
  hwnd: HWND; dwflags: DWORD; lParam: LPVOID): LONG; stdcall;

{$IFDEF UNICODE}
function ChangeDisplaySettingsEx(lpszDeviceName: LPCWSTR; lpDevMode: LPDEVMODEW;
  hwnd: HWND; dwflags: DWORD; lParam: LPVOID): LONG; stdcall;
{$ELSE}
function ChangeDisplaySettingsEx(lpszDeviceName: LPCSTR; lpDevMode: LPDEVMODEA;
  hwnd: HWND; dwflags: DWORD; lParam: LPVOID): LONG; stdcall;
{$ENDIF}

const
  ENUM_CURRENT_SETTINGS  = DWORD(-1);
  ENUM_REGISTRY_SETTINGS = DWORD(-2);

function EnumDisplaySettingsA(lpszDeviceName: LPCSTR; iModeNum: DWORD;
  var lpDevMode: DEVMODEA): BOOL; stdcall;
function EnumDisplaySettingsW(lpszDeviceName: LPCWSTR; iModeNum: DWORD;
  var lpDevMode: DEVMODEW): BOOL; stdcall;

{$IFDEF UNICODE}
function EnumDisplaySettings(lpszDeviceName: LPCWSTR; iModeNum: DWORD;
  var lpDevMode: DEVMODEW): BOOL; stdcall;
{$ELSE}
function EnumDisplaySettings(lpszDeviceName: LPCSTR; iModeNum: DWORD;
  var lpDevMode: DEVMODEA): BOOL; stdcall;
{$ENDIF}

function EnumDisplaySettingsExA(lpszDeviceName: LPCSTR; iModeNum: DWORD;
  var lpDevMode: DEVMODEA; dwFlags: DWORD): BOOL; stdcall;
function EnumDisplaySettingsExW(lpszDeviceName: LPCWSTR; iModeNum: DWORD;
  var lpDevMode: DEVMODEW; dwFlags: DWORD): BOOL; stdcall;

{$IFDEF UNICODE}
function EnumDisplaySettingsEx(lpszDeviceName: LPCWSTR; iModeNum: DWORD;
  var lpDevMode: DEVMODEW; dwFlags: DWORD): BOOL; stdcall;
{$ELSE}
function EnumDisplaySettingsEx(lpszDeviceName: LPCSTR; iModeNum: DWORD;
  var lpDevMode: DEVMODEA; dwFlags: DWORD): BOOL; stdcall;
{$ENDIF}

// Flags for EnumDisplaySettingsEx//

const
  EDS_RAWMODE = $00000002;

function EnumDisplayDevicesA(lpDevice: LPCSTR; iDevNum: DWORD;
  var lpDisplayDevice: DISPLAY_DEVICEA; dwFlags: DWORD): BOOL; stdcall;
function EnumDisplayDevicesW(lpDevice: LPCWSTR; iDevNum: DWORD;
  var lpDisplayDevice: DISPLAY_DEVICEW; dwFlags: DWORD): BOOL; stdcall;

{$IFDEF UNICODE}
function EnumDisplayDevices(lpDevice: LPCWSTR; iDevNum: DWORD;
  var lpDisplayDevice: DISPLAY_DEVICEW; dwFlags: DWORD): BOOL; stdcall;
{$ELSE}
function EnumDisplayDevices(lpDevice: LPCSTR; iDevNum: DWORD;
  var lpDisplayDevice: DISPLAY_DEVICEA; dwFlags: DWORD): BOOL; stdcall;
{$ENDIF}

function SystemParametersInfoA(uiAction: UINT; uiParam: UINT;
  pvParam: PVOID; fWinIni: UINT): BOOL; stdcall;
function SystemParametersInfoW(uiAction: UINT; uiParam: UINT;
  pvParam: PVOID; fWinIni: UINT): BOOL; stdcall;

{$IFDEF UNICODE}
function SystemParametersInfo(uiAction: UINT; uiParam: UINT;
  pvParam: PVOID; fWinIni: UINT): BOOL; stdcall;
{$ELSE}
function SystemParametersInfo(uiAction: UINT; uiParam: UINT;
  pvParam: PVOID; fWinIni: UINT): BOOL; stdcall;
{$ENDIF}

//
// Accessibility support
//

type
  LPFILTERKEYS = ^FILTERKEYS;
  tagFILTERKEYS = record
    cbSize: UINT;
    dwFlags: DWORD;
    iWaitMSec: DWORD;   // Acceptance Delay
    iDelayMSec: DWORD;  // Delay Until Repeat
    iRepeatMSec: DWORD; // Repeat Rate
    iBounceMSec: DWORD; // Debounce Time
  end;
  FILTERKEYS = tagFILTERKEYS;
  TFilterKeys = FILTERKEYS;
  PFilterKeys = LPFILTERKEYS;

//
// FILTERKEYS dwFlags field
//

const
  FKF_FILTERKEYSON  = $00000001;
  FKF_AVAILABLE     = $00000002;
  FKF_HOTKEYACTIVE  = $00000004;
  FKF_CONFIRMHOTKEY = $00000008;
  FKF_HOTKEYSOUND   = $00000010;
  FKF_INDICATOR     = $00000020;
  FKF_CLICKON       = $00000040;

type
  LPSTICKYKEYS = ^STICKYKEYS;
  tagSTICKYKEYS = record
    cbSize: UINT;
    dwFlags: DWORD;
  end;
  STICKYKEYS = tagSTICKYKEYS;
  TStickyKeys = STICKYKEYS;
  PStickyKeys = LPSTICKYKEYS;

//
// STICKYKEYS dwFlags field
//

const
  SKF_STICKYKEYSON    = $00000001;
  SKF_AVAILABLE       = $00000002;
  SKF_HOTKEYACTIVE    = $00000004;
  SKF_CONFIRMHOTKEY   = $00000008;
  SKF_HOTKEYSOUND     = $00000010;
  SKF_INDICATOR       = $00000020;
  SKF_AUDIBLEFEEDBACK = $00000040;
  SKF_TRISTATE        = $00000080;
  SKF_TWOKEYSOFF      = $00000100;
  SKF_LALTLATCHED     = $10000000;
  SKF_LCTLLATCHED     = $04000000;
  SKF_LSHIFTLATCHED   = $01000000;
  SKF_RALTLATCHED     = $20000000;
  SKF_RCTLLATCHED     = $08000000;
  SKF_RSHIFTLATCHED   = $02000000;
  SKF_LWINLATCHED     = $40000000;
  SKF_RWINLATCHED     = $80000000;
  SKF_LALTLOCKED      = $00100000;
  SKF_LCTLLOCKED      = $00040000;
  SKF_LSHIFTLOCKED    = $00010000;
  SKF_RALTLOCKED      = $00200000;
  SKF_RCTLLOCKED      = $00080000;
  SKF_RSHIFTLOCKED    = $00020000;
  SKF_LWINLOCKED      = $00400000;
  SKF_RWINLOCKED      = $00800000;

type
  LPMOUSEKEYS = ^MOUSEKEYS;
  tagMOUSEKEYS = record
    cbSize: UINT;
    dwFlags: DWORD;
    iMaxSpeed: DWORD;
    iTimeToMaxSpeed: DWORD;
    iCtrlSpeed: DWORD;
    dwReserved1: DWORD;
    dwReserved2: DWORD;
  end;
  MOUSEKEYS = tagMOUSEKEYS;
  TMouseKeys = MOUSEKEYS;
  PMouseKeys = LPMOUSEKEYS;

//
// MOUSEKEYS dwFlags field
//

const
  MKF_MOUSEKEYSON     = $00000001;
  MKF_AVAILABLE       = $00000002;
  MKF_HOTKEYACTIVE    = $00000004;
  MKF_CONFIRMHOTKEY   = $00000008;
  MKF_HOTKEYSOUND     = $00000010;
  MKF_INDICATOR       = $00000020;
  MKF_MODIFIERS       = $00000040;
  MKF_REPLACENUMBERS  = $00000080;
  MKF_LEFTBUTTONSEL   = $10000000;
  MKF_RIGHTBUTTONSEL  = $20000000;
  MKF_LEFTBUTTONDOWN  = $01000000;
  MKF_RIGHTBUTTONDOWN = $02000000;
  MKF_MOUSEMODE       = $80000000;

type
  LPACCESSTIMEOUT = ^ACCESSTIMEOUT;
  tagACCESSTIMEOUT = record
    cbSize: UINT;
    dwFlags: DWORD;
    iTimeOutMSec: DWORD;
  end;
  ACCESSTIMEOUT = tagACCESSTIMEOUT;
  TAccessTimeout = ACCESSTIMEOUT;
  PAccessTimeout = LPACCESSTIMEOUT;

//
// ACCESSTIMEOUT dwFlags field
//

const
  ATF_TIMEOUTON     = $00000001;
  ATF_ONOFFFEEDBACK = $00000002;

// values for SOUNDSENTRY iFSGrafEffect field//

  SSGF_NONE    = 0;
  SSGF_DISPLAY = 3;

// values for SOUNDSENTRY iFSTextEffect field//

  SSTF_NONE    = 0;
  SSTF_CHARS   = 1;
  SSTF_BORDER  = 2;
  SSTF_DISPLAY = 3;

// values for SOUNDSENTRY iWindowsEffect field//

  SSWF_NONE    = 0;
  SSWF_TITLE   = 1;
  SSWF_WINDOW  = 2;
  SSWF_DISPLAY = 3;
  SSWF_CUSTOM  = 4;

type
  LPSOUNDSENTRYA = ^SOUNDSENTRYA;
  tagSOUNDSENTRYA = record
    cbSize: UINT;
    dwFlags: DWORD;
    iFSTextEffect: DWORD;
    iFSTextEffectMSec: DWORD;
    iFSTextEffectColorBits: DWORD;
    iFSGrafEffect: DWORD;
    iFSGrafEffectMSec: DWORD;
    iFSGrafEffectColor: DWORD;
    iWindowsEffect: DWORD;
    iWindowsEffectMSec: DWORD;
    lpszWindowsEffectDLL: LPSTR;
    iWindowsEffectOrdinal: DWORD;
  end;
  SOUNDSENTRYA = tagSOUNDSENTRYA;
  TSoundsEntryA = SOUNDSENTRYA;
  PSoundsEntryA = LPSOUNDSENTRYA;

  LPSOUNDSENTRYW = ^SOUNDSENTRYW;
  tagSOUNDSENTRYW = record
    cbSize: UINT;
    dwFlags: DWORD;
    iFSTextEffect: DWORD;
    iFSTextEffectMSec: DWORD;
    iFSTextEffectColorBits: DWORD;
    iFSGrafEffect: DWORD;
    iFSGrafEffectMSec: DWORD;
    iFSGrafEffectColor: DWORD;
    iWindowsEffect: DWORD;
    iWindowsEffectMSec: DWORD;
    lpszWindowsEffectDLL: LPWSTR;
    iWindowsEffectOrdinal: DWORD;
  end;
  SOUNDSENTRYW = tagSOUNDSENTRYW;
  TSoundsEntryW = SOUNDSENTRYW;
  PSoundsEntryW = LPSOUNDSENTRYW;

{$IFDEF UNICODE}
  SOUNDSENTRY = SOUNDSENTRYW;
  LPSOUNDSENTRY = LPSOUNDSENTRYW;
  TSoundsEntry = TSoundsEntryW;
  PSoundsEntry = PSoundsEntryW;
{$ELSE}
  SOUNDSENTRY = SOUNDSENTRYA;
  LPSOUNDSENTRY = LPSOUNDSENTRYA;
  TSoundsEntry = TSoundsEntryA;
  PSoundsEntry = PSoundsEntryA;
{$ENDIF}

//
// SOUNDSENTRY dwFlags field
//

const
  SSF_SOUNDSENTRYON = $00000001;
  SSF_AVAILABLE     = $00000002;
  SSF_INDICATOR     = $00000004;

type
  LPTOGGLEKEYS = ^TOGGLEKEYS;
  tagTOGGLEKEYS = record
    cbSize: UINT;
    dwFlags: DWORD;
  end;
  TOGGLEKEYS = tagTOGGLEKEYS;
  TToggleKeys = TOGGLEKEYS;
  PToggleKeys = LPTOGGLEKEYS;

//
// TOGGLEKEYS dwFlags field
//

const
  TKF_TOGGLEKEYSON  = $00000001;
  TKF_AVAILABLE     = $00000002;
  TKF_HOTKEYACTIVE  = $00000004;
  TKF_CONFIRMHOTKEY = $00000008;
  TKF_HOTKEYSOUND   = $00000010;
  TKF_INDICATOR     = $00000020;

//
// Set debug level
//

procedure SetDebugErrorLevel(dwLevel: DWORD); stdcall;

//
// SetLastErrorEx() types.
//

const
  SLE_ERROR      = $00000001;
  SLE_MINORERROR = $00000002;
  SLE_WARNING    = $00000003;

procedure SetLastErrorEx(dwErrCode, dwType: DWORD); stdcall;

function InternalGetWindowText(hWnd: HWND; lpString: LPWSTR; nMaxCount: Integer): Integer; stdcall;

function EndTask(hWnd: HWND; fShutDown, fForce: BOOL): BOOL; stdcall;

//
// Multimonitor API.
//

const
  MONITOR_DEFAULTTONULL    = $00000000;
  MONITOR_DEFAULTTOPRIMARY = $00000001;
  MONITOR_DEFAULTTONEAREST = $00000002;

function MonitorFromPoint(pt: POINT; dwFlags: DWORD): HMONITOR; stdcall;

function MonitorFromRect(const lprc: RECT; dwFlags: DWORD): HMONITOR; stdcall;

function MonitorFromWindow(hwnd: HWND; dwFlags: DWORD): HMONITOR; stdcall;

const
  MONITORINFOF_PRIMARY = $00000001;

  CCHDEVICENAME = 32;

type
  LPMONITORINFO = ^MONITORINFO;
  tagMONITORINFO = record
    cbSize: DWORD;
    rcMonitor: RECT;
    rcWork: RECT;
    dwFlags: DWORD;
  end;
  MONITORINFO = tagMONITORINFO;
  TMonitorInfo = MONITORINFO;
  PMonitorInfo = LPMONITORINFO;

  LPMONITORINFOEXA = ^MONITORINFOEXA;
  tagMONITORINFOEXA = record
    MonitorInfo: MONITORINFO;
    szDevice: array [0..CCHDEVICENAME - 1] of CHAR;
  end;
  MONITORINFOEXA = tagMONITORINFOEXA;
  TMonitorinfoexa = MONITORINFOEXA;
  PMonitorInfoExA = LPMONITORINFOEXA;

  LPMONITORINFOEXW = ^MONITORINFOEXW;
  tagMONITORINFOEXW = record
    MonitorInfo: MONITORINFO;
    szDevice: array [0..CCHDEVICENAME - 1] of WCHAR;
  end;
  MONITORINFOEXW = tagMONITORINFOEXW;
  TMonitorInfoExW = MONITORINFOEXW;
  PMonitorInfoExW = LPMONITORINFOEXW;

{$IFDEF UNICODE}
  MONITORINFOEX = MONITORINFOEXW;
  LPMONITORINFOEX = LPMONITORINFOEXW;
  TMonitorInfoEx = TMonitorInfoExW;
  PMonitorInfoEx = PMonitorInfoExW;
{$ELSE}
  MONITORINFOEX = MONITORINFOEXA;
  LPMONITORINFOEX = LPMONITORINFOEXA;
  TMonitorInfoEx = TMonitorInfoExA;
  PMonitorInfoEx = PMonitorInfoExA;
{$ENDIF}

function GetMonitorInfoA(hMonitor: HMONITOR; pmi: LPMONITORINFO): BOOL; stdcall;
function GetMonitorInfoW(hMonitor: HMONITOR; lpmi: LPMONITORINFO): BOOL; stdcall;

{$IFDEF UNICODE}
function GetMonitorInfo(hMonitor: HMONITOR; lpmi: LPMONITORINFO): BOOL; stdcall;
{$ELSE}
function GetMonitorInfo(hMonitor: HMONITOR; lpmi: LPMONITORINFO): BOOL; stdcall;
{$ENDIF}

type
  MONITORENUMPROC = function (hMonitor: HMONITOR; hdcMonitor: HDC;
    lprcMonitor: LPRECT; dwData: LPARAM): BOOL; stdcall;
  TMonitorEnumProc = MONITORENUMPROC;

function EnumDisplayMonitors(hdc: HDC; lprcClip: LPCRECT;
  lpfnEnum: MONITORENUMPROC; dwData: LPARAM): BOOL; stdcall;

//
// WinEvents - Active Accessibility hooks
//

procedure NotifyWinEvent(event: DWORD; hwnd: HWND; idObject: LONG; idChild: LONG); stdcall;

type
  WINEVENTPROC = procedure (hWinEventHook: HWINEVENTHOOK; event: DWORD; hwnd: HWND;
    idObject, idChild: LONG; idEventThread, dwmsEventTime: DWORD); stdcall;
  TWinEventProc = WINEVENTPROC;

function SetWinEventHook(eventMin: DWORD; eventMax: DWORD;
  hmodWinEventProc: HMODULE; pfnWinEventProc: WINEVENTPROC; idProcess: DWORD;
  idThread: DWORD; dwFlags: DWORD): HWINEVENTHOOK; stdcall;

function IsWinEventHookInstalled(event: DWORD): BOOL; stdcall;

//
// dwFlags for SetWinEventHook
//

const
  WINEVENT_OUTOFCONTEXT   = $0000; // Events are ASYNC
  WINEVENT_SKIPOWNTHREAD  = $0001; // Don't call back for events on installer's thread
  WINEVENT_SKIPOWNPROCESS = $0002; // Don't call back for events on installer's process
  WINEVENT_INCONTEXT      = $0004; // Events are SYNC, this causes your dll to be injected into every process

function UnhookWinEvent(hWinEventHook: HWINEVENTHOOK): BOOL; stdcall;

//
// idObject values for WinEventProc and NotifyWinEvent
//

//
// hwnd + idObject can be used with OLEACC.DLL's OleGetObjectFromWindow()
// to get an interface pointer to the container.  indexChild is the item
// within the container in question.  Setup a VARIANT with vt VT_I4 and
// lVal the indexChild and pass that in to all methods.  Then you
// are raring to go.
//


//
// Common object IDs (cookies, only for sending WM_GETOBJECT to get at the
// thing in question).  Positive IDs are reserved for apps (app specific),
// negative IDs are system things and are global, 0 means "just little old
// me".
//

const
  CHILDID_SELF      = 0;
  INDEXID_OBJECT    = 0;
  INDEXID_CONTAINER = 0;

//
// Reserved IDs for system objects
//

const
  OBJID_WINDOW            = DWORD($00000000);
  OBJID_SYSMENU           = DWORD($FFFFFFFF);
  OBJID_TITLEBAR          = DWORD($FFFFFFFE);
  OBJID_MENU              = DWORD($FFFFFFFD);
  OBJID_CLIENT            = DWORD($FFFFFFFC);
  OBJID_VSCROLL           = DWORD($FFFFFFFB);
  OBJID_HSCROLL           = DWORD($FFFFFFFA);
  OBJID_SIZEGRIP          = DWORD($FFFFFFF9);
  OBJID_CARET             = DWORD($FFFFFFF8);
  OBJID_CURSOR            = DWORD($FFFFFFF7);
  OBJID_ALERT             = DWORD($FFFFFFF6);
  OBJID_SOUND             = DWORD($FFFFFFF5);
  OBJID_QUERYCLASSNAMEIDX = DWORD($FFFFFFF4);
  OBJID_NATIVEOM          = DWORD($FFFFFFF0);

//
// EVENT DEFINITION
//

  EVENT_MIN = $00000001;
  EVENT_MAX = $7FFFFFFF;

//
//  EVENT_SYSTEM_SOUND
//  Sent when a sound is played.  Currently nothing is generating this, we
//  this event when a system sound (for menus, etc) is played.  Apps
//  generate this, if accessible, when a private sound is played.  For
//  example, if Mail plays a "New Mail" sound.
//
//  System Sounds:
//  (Generated by PlaySoundEvent in USER itself)
//      hwnd            is NULL
//      idObject        is OBJID_SOUND
//      idChild         is sound child ID if one
//  App Sounds:
//  (PlaySoundEvent won't generate notification; up to app)
//      hwnd + idObject gets interface pointer to Sound object
//      idChild identifies the sound in question
//  are going to be cleaning up the SOUNDSENTRY feature in the control panel
//  and will use this at that time.  Applications implementing WinEvents
//  are perfectly welcome to use it.  Clients of IAccessible* will simply
//  turn around and get back a non-visual object that describes the sound.
//

  EVENT_SYSTEM_SOUND = $0001;

//
// EVENT_SYSTEM_ALERT
// System Alerts:
// (Generated by MessageBox() calls for example)
//      hwnd            is hwndMessageBox
//      idObject        is OBJID_ALERT
// App Alerts:
// (Generated whenever)
//      hwnd+idObject gets interface pointer to Alert
//

  EVENT_SYSTEM_ALERT = $0002;

//
// EVENT_SYSTEM_FOREGROUND
// Sent when the foreground (active) window changes, even if it is changing
// to another window in the same thread as the previous one.
//      hwnd            is hwndNewForeground
//      idObject        is OBJID_WINDOW
//      idChild    is INDEXID_OBJECT
//

  EVENT_SYSTEM_FOREGROUND = $0003;

//
// Menu
//      hwnd            is window (top level window or popup menu window)
//      idObject        is ID of control (OBJID_MENU, OBJID_SYSMENU, OBJID_SELF for popup)
//      idChild         is CHILDID_SELF

// EVENT_SYSTEM_MENUSTART
// EVENT_SYSTEM_MENUEND
// For MENUSTART, hwnd+idObject+idChild refers to the control with the menu bar,
//  or the control bringing up the context menu.

// Sent when entering into and leaving from menu mode (system, app bar, and
// track popups).
//

  EVENT_SYSTEM_MENUSTART = $0004;
  EVENT_SYSTEM_MENUEND   = $0005;

//
// EVENT_SYSTEM_MENUPOPUPSTART
// EVENT_SYSTEM_MENUPOPUPEND
// Sent when a menu popup comes up and just before it is taken down.  Note
// that for a call to TrackPopupMenu(), a client will see EVENT_SYSTEM_MENUSTART
// followed almost immediately by EVENT_SYSTEM_MENUPOPUPSTART for the popup
// being shown.

// For MENUPOPUP, hwnd+idObject+idChild refers to the NEW popup coming up, not the
// parent item which is hierarchical.  You can get the parent menu/popup by
// asking for the accParent object.
//

  EVENT_SYSTEM_MENUPOPUPSTART = $0006;
  EVENT_SYSTEM_MENUPOPUPEND   = $0007;

//
// EVENT_SYSTEM_CAPTURESTART
// EVENT_SYSTEM_CAPTUREEND
// Sent when a window takes the capture and releases the capture.
//

  EVENT_SYSTEM_CAPTURESTART = $0008;
  EVENT_SYSTEM_CAPTUREEND   = $0009;

//
// Move Size
// EVENT_SYSTEM_MOVESIZESTART
// EVENT_SYSTEM_MOVESIZEEND
// Sent when a window enters and leaves move-size dragging mode.
//

  EVENT_SYSTEM_MOVESIZESTART = $000A;
  EVENT_SYSTEM_MOVESIZEEND   = $000B;

//
// Context Help
// EVENT_SYSTEM_CONTEXTHELPSTART
// EVENT_SYSTEM_CONTEXTHELPEND
// Sent when a window enters and leaves context sensitive help mode.
//

  EVENT_SYSTEM_CONTEXTHELPSTART = $000C;
  EVENT_SYSTEM_CONTEXTHELPEND   = $000D;

//
// Drag & Drop
// EVENT_SYSTEM_DRAGDROPSTART
// EVENT_SYSTEM_DRAGDROPEND
// Send the START notification just before going into drag&drop loop.  Send
// the END notification just after canceling out.
// Note that it is up to apps and OLE to generate this, since the system
// doesn't know.  Like EVENT_SYSTEM_SOUND, it will be a while before this
// is prevalent.
//

  EVENT_SYSTEM_DRAGDROPSTART = $000E;
  EVENT_SYSTEM_DRAGDROPEND   = $000F;

//
// Dialog
// Send the START notification right after the dialog is completely
//  initialized and visible.  Send the END right before the dialog
//  is hidden and goes away.
// EVENT_SYSTEM_DIALOGSTART
// EVENT_SYSTEM_DIALOGEND
//

  EVENT_SYSTEM_DIALOGSTART = $0010;
  EVENT_SYSTEM_DIALOGEND   = $0011;

//
// EVENT_SYSTEM_SCROLLING
// EVENT_SYSTEM_SCROLLINGSTART
// EVENT_SYSTEM_SCROLLINGEND
// Sent when beginning and ending the tracking of a scrollbar in a window,
// and also for scrollbar controls.
//

  EVENT_SYSTEM_SCROLLINGSTART = $0012;
  EVENT_SYSTEM_SCROLLINGEND   = $0013;

//
// Alt-Tab Window
// Send the START notification right after the switch window is initialized
// and visible.  Send the END right before it is hidden and goes away.
// EVENT_SYSTEM_SWITCHSTART
// EVENT_SYSTEM_SWITCHEND
//

  EVENT_SYSTEM_SWITCHSTART = $0014;
  EVENT_SYSTEM_SWITCHEND   = $0015;

//
// EVENT_SYSTEM_MINIMIZESTART
// EVENT_SYSTEM_MINIMIZEEND
// Sent when a window minimizes and just before it restores.
//

  EVENT_SYSTEM_MINIMIZESTART = $0016;
  EVENT_SYSTEM_MINIMIZEEND   = $0017;

  EVENT_CONSOLE_CARET             = $4001;
  EVENT_CONSOLE_UPDATE_REGION     = $4002;
  EVENT_CONSOLE_UPDATE_SIMPLE     = $4003;
  EVENT_CONSOLE_UPDATE_SCROLL     = $4004;
  EVENT_CONSOLE_LAYOUT            = $4005;
  EVENT_CONSOLE_START_APPLICATION = $4006;
  EVENT_CONSOLE_END_APPLICATION   = $4007;

//
// Flags for EVENT_CONSOLE_START/END_APPLICATION.
//

  CONSOLE_APPLICATION_16BIT       = $0001;

//
// Flags for EVENT_CONSOLE_CARET
//

  CONSOLE_CARET_SELECTION         = $0001;
  CONSOLE_CARET_VISIBLE           = $0002;

//
// Object events

// The system AND apps generate these.  The system generates these for
// real windows.  Apps generate these for objects within their window which
// act like a separate control, e.g. an item in a list view.

// When the system generate them, dwParam2 is always WMOBJID_SELF.  When
// apps generate them, apps put the has-meaning-to-the-app-only ID value
// in dwParam2.
// For all events, if you want detailed accessibility information, callers
// should
//      * Call AccessibleObjectFromWindow() with the hwnd, idObject parameters
//          of the event, and IID_IAccessible as the REFIID, to get back an
//          IAccessible* to talk to
//      * Initialize and fill in a VARIANT as VT_I4 with lVal the idChild
//          parameter of the event.
//      * If idChild isn't zero, call get_accChild() in the container to see
//          if the child is an object in its own right.  If so, you will get
//          back an IDispatch* object for the child.  You should release the
//          parent, and call QueryInterface() on the child object to get its
//          IAccessible*.  Then you talk directly to the child.  Otherwise,
//          if get_accChild() returns you nothing, you should continue to
//          use the child VARIANT.  You will ask the container for the properties
//          of the child identified by the VARIANT.  In other words, the
//          child in this case is accessible but not a full-blown object.
//          Like a button on a titlebar which is 'small' and has no children.
//

//
// For all EVENT_OBJECT events,
//      hwnd is the dude to Send the WM_GETOBJECT message to (unless NULL,
//          see above for system things)
//      idObject is the ID of the object that can resolve any queries a
//          client might have.  It's a way to deal with windowless controls,
//          controls that are just drawn on the screen in some larger parent
//          window (like SDM), or standard frame elements of a window.
//      idChild is the piece inside of the object that is affected.  This
//          allows clients to access things that are too small to have full
//          blown objects in their own right.  Like the thumb of a scrollbar.
//          The hwnd/idObject pair gets you to the container, the dude you
//          probably want to talk to most of the time anyway.  The idChild
//          can then be passed into the acc properties to get the name/value
//          of it as needed.

// Example #1:
//      System propagating a listbox selection change
//      EVENT_OBJECT_SELECTION
//          hwnd == listbox hwnd
//          idObject == OBJID_WINDOW
//          idChild == new selected item, or CHILDID_SELF if
//              nothing now selected within container.
//      Word '97 propagating a listbox selection change
//          hwnd == SDM window
//          idObject == SDM ID to get at listbox 'control'
//          idChild == new selected item, or CHILDID_SELF if
//              nothing

// Example #2:
//      System propagating a menu item selection on the menu bar
//      EVENT_OBJECT_SELECTION
//          hwnd == top level window
//          idObject == OBJID_MENU
//          idChild == ID of child menu bar item selected
// *
// Example #3:
//      System propagating a dropdown coming off of said menu bar item
//      EVENT_OBJECT_CREATE
//          hwnd == popup item
//          idObject == OBJID_WINDOW
//          idChild == CHILDID_SELF
//
// Example #4:
//
// For EVENT_OBJECT_REORDER, the object referred to by hwnd/idObject is the
// PARENT container in which the zorder is occurring.  This is because if
// one child is zordering, all of them are changing their relative zorder.
//

  EVENT_OBJECT_CREATE  = $8000; // hwnd + ID + idChild is created item
  EVENT_OBJECT_DESTROY = $8001; // hwnd + ID + idChild is destroyed item
  EVENT_OBJECT_SHOW    = $8002; // hwnd + ID + idChild is shown item
  EVENT_OBJECT_HIDE    = $8003; // hwnd + ID + idChild is hidden item
  EVENT_OBJECT_REORDER = $8004; // hwnd + ID + idChild is parent of zordering children

//
// NOTE:
// Minimize the number of notifications!
//
// When you are hiding a parent object, obviously all child objects are no
// longer visible on screen.  They still have the same "visible" status,
// but are not truly visible.  Hence do not send HIDE notifications for the
// children also.  One implies all.  The same goes for SHOW.
//

  EVENT_OBJECT_FOCUS           = $8005; // hwnd + ID + idChild is focused item
  EVENT_OBJECT_SELECTION       = $8006; // hwnd + ID + idChild is selected item (if only one), or idChild is OBJID_WINDOW if complex
  EVENT_OBJECT_SELECTIONADD    = $8007; // hwnd + ID + idChild is item added
  EVENT_OBJECT_SELECTIONREMOVE = $8008; // hwnd + ID + idChild is item removed
  EVENT_OBJECT_SELECTIONWITHIN = $8009; // hwnd + ID + idChild is parent of changed selected items

//
// NOTES:
// There is only one "focused" child item in a parent.  This is the place
// keystrokes are going at a given moment.  Hence only send a notification
// about where the NEW focus is going.  A NEW item getting the focus already
// implies that the OLD item is losing it.
//
// SELECTION however can be multiple.  Hence the different SELECTION
// notifications.  Here's when to use each:
//
// (1) Send a SELECTION notification in the simple single selection
//     case (like the focus) when the item with the selection is
//     merely moving to a different item within a container.  hwnd + ID
//     is the container control, idChildItem is the new child with the
//     selection.
//
// (2) Send a SELECTIONADD notification when a new item has simply been added
//     to the selection within a container.  This is appropriate when the
//     number of newly selected items is very small.  hwnd + ID is the
//     container control, idChildItem is the new child added to the selection.
//
// (3) Send a SELECTIONREMOVE notification when a new item has simply been
//     removed from the selection within a container.  This is appropriate
//     when the number of newly selected items is very small, just like
//     SELECTIONADD.  hwnd + ID is the container control, idChildItem is the
//     new child removed from the selection.
//
// (4) Send a SELECTIONWITHIN notification when the selected items within a
//     control have changed substantially.  Rather than propagate a large
//     number of changes to reflect removal for some items, addition of
//     others, just tell somebody who cares that a lot happened.  It will
//     be faster an easier for somebody watching to just turn around and
//     query the container control what the new bunch of selected items
//     are.
//

  EVENT_OBJECT_STATECHANGE = $800A; // hwnd + ID + idChild is item w/ state change

//
// Examples of when to send an EVENT_OBJECT_STATECHANGE include
//      * It is being enabled/disabled (USER does for windows)
//      * It is being pressed/released (USER does for buttons)
//      * It is being checked/unchecked (USER does for radio/check buttons)
//

  EVENT_OBJECT_LOCATIONCHANGE = $800B; // hwnd + ID + idChild is moved/sized item

//
// Note:
// A LOCATIONCHANGE is not sent for every child object when the parent
// changes shape/moves.  Send one notification for the topmost object
// that is changing.  For example, if the user resizes a top level window,
// USER will generate a LOCATIONCHANGE for it, but not for the menu bar,
// title bar, scrollbars, etc.  that are also changing shape/moving.
//
// In other words, it only generates LOCATIONCHANGE notifications for
// real windows that are moving/sizing.  It will not generate a LOCATIONCHANGE
// for every non-floating child window when the parent moves (the children are
// logically moving also on screen, but not relative to the parent).
//
// Now, if the app itself resizes child windows as a result of being
// sized, USER will generate LOCATIONCHANGEs for those dudes also because
// it doesn't know better.
//
// Note also that USER will generate LOCATIONCHANGE notifications for two
// non-window sys objects:
//      (1) System caret
//      (2) Cursor
//

  EVENT_OBJECT_NAMECHANGE        = $800C; // hwnd + ID + idChild is item w/ name change
  EVENT_OBJECT_DESCRIPTIONCHANGE = $800D; // hwnd + ID + idChild is item w/ desc change
  EVENT_OBJECT_VALUECHANGE       = $800E; // hwnd + ID + idChild is item w/ value change
  EVENT_OBJECT_PARENTCHANGE      = $800F; // hwnd + ID + idChild is item w/ new parent
  EVENT_OBJECT_HELPCHANGE        = $8010; // hwnd + ID + idChild is item w/ help change
  EVENT_OBJECT_DEFACTIONCHANGE   = $8011; // hwnd + ID + idChild is item w/ def action change
  EVENT_OBJECT_ACCELERATORCHANGE = $8012; // hwnd + ID + idChild is item w/ keybd accel change

//
// Child IDs
//

//
// System Sounds (idChild of system SOUND notification)
//

  SOUND_SYSTEM_STARTUP     = 1;
  SOUND_SYSTEM_SHUTDOWN    = 2;
  SOUND_SYSTEM_BEEP        = 3;
  SOUND_SYSTEM_ERROR       = 4;
  SOUND_SYSTEM_QUESTION    = 5;
  SOUND_SYSTEM_WARNING     = 6;
  SOUND_SYSTEM_INFORMATION = 7;
  SOUND_SYSTEM_MAXIMIZE    = 8;
  SOUND_SYSTEM_MINIMIZE    = 9;
  SOUND_SYSTEM_RESTOREUP   = 10;
  SOUND_SYSTEM_RESTOREDOWN = 11;
  SOUND_SYSTEM_APPSTART    = 12;
  SOUND_SYSTEM_FAULT       = 13;
  SOUND_SYSTEM_APPEND      = 14;
  SOUND_SYSTEM_MENUCOMMAND = 15;
  SOUND_SYSTEM_MENUPOPUP   = 16;
  CSOUND_SYSTEM            = 16;

//
// System Alerts (indexChild of system ALERT notification)
//

  ALERT_SYSTEM_INFORMATIONAL = 1; // MB_INFORMATION
  ALERT_SYSTEM_WARNING       = 2; // MB_WARNING
  ALERT_SYSTEM_ERROR         = 3; // MB_ERROR
  ALERT_SYSTEM_QUERY         = 4; // MB_QUESTION
  ALERT_SYSTEM_CRITICAL      = 5; // HardSysErrBox
  CALERT_SYSTEM              = 6;

type
  LPGUITHREADINFO = ^GUITHREADINFO;
  tagGUITHREADINFO = record
    cbSize: DWORD;
    flags: DWORD;
    hwndActive: HWND;
    hwndFocus: HWND;
    hwndCapture: HWND;
    hwndMenuOwner: HWND;
    hwndMoveSize: HWND;
    hwndCaret: HWND;
    rcCaret: RECT;
  end;
  GUITHREADINFO = tagGUITHREADINFO;
  TGuiThreadInfo = GUITHREADINFO;
  PGuiThreadInfo = LPGUITHREADINFO;

const
  GUI_CARETBLINKING  = $00000001;
  GUI_INMOVESIZE     = $00000002;
  GUI_INMENUMODE     = $00000004;
  GUI_SYSTEMMENUMODE = $00000008;
  GUI_POPUPMENUMODE  = $00000010;
  GUI_16BITTASK      = $00000020;

function GetGUIThreadInfo(idThread: DWORD; var pgui: GUITHREADINFO): BOOL; stdcall;

function GetWindowModuleFileNameA(hwnd: HWND; pszFileName: LPSTR; cchFileNameMax: UINT): UINT; stdcall;
function GetWindowModuleFileNameW(hwnd: HWND; pszFileName: LPWSTR; cchFileNameMax: UINT): UINT; stdcall;

{$IFDEF UNICODE}
function GetWindowModuleFileName(hwnd: HWND; pszFileName: LPWSTR; cchFileNameMax: UINT): UINT; stdcall;
{$ELSE}
function GetWindowModuleFileName(hwnd: HWND; pszFileName: LPSTR; cchFileNameMax: UINT): UINT; stdcall;
{$ENDIF}

const
  STATE_SYSTEM_UNAVAILABLE     = $00000001; // Disabled
  STATE_SYSTEM_SELECTED        = $00000002;
  STATE_SYSTEM_FOCUSED         = $00000004;
  STATE_SYSTEM_PRESSED         = $00000008;
  STATE_SYSTEM_CHECKED         = $00000010;
  STATE_SYSTEM_MIXED           = $00000020; // 3-state checkbox or toolbar button
  STATE_SYSTEM_INDETERMINATE   = STATE_SYSTEM_MIXED;
  STATE_SYSTEM_READONLY        = $00000040;
  STATE_SYSTEM_HOTTRACKED      = $00000080;
  STATE_SYSTEM_DEFAULT         = $00000100;
  STATE_SYSTEM_EXPANDED        = $00000200;
  STATE_SYSTEM_COLLAPSED       = $00000400;
  STATE_SYSTEM_BUSY            = $00000800;
  STATE_SYSTEM_FLOATING        = $00001000; // Children "owned" not "contained" by parent
  STATE_SYSTEM_MARQUEED        = $00002000;
  STATE_SYSTEM_ANIMATED        = $00004000;
  STATE_SYSTEM_INVISIBLE       = $00008000;
  STATE_SYSTEM_OFFSCREEN       = $00010000;
  STATE_SYSTEM_SIZEABLE        = $00020000;
  STATE_SYSTEM_MOVEABLE        = $00040000;
  STATE_SYSTEM_SELFVOICING     = $00080000;
  STATE_SYSTEM_FOCUSABLE       = $00100000;
  STATE_SYSTEM_SELECTABLE      = $00200000;
  STATE_SYSTEM_LINKED          = $00400000;
  STATE_SYSTEM_TRAVERSED       = $00800000;
  STATE_SYSTEM_MULTISELECTABLE = $01000000; // Supports multiple selection
  STATE_SYSTEM_EXTSELECTABLE   = $02000000; // Supports extended selection
  STATE_SYSTEM_ALERT_LOW       = $04000000; // This information is of low priority
  STATE_SYSTEM_ALERT_MEDIUM    = $08000000; // This information is of medium priority
  STATE_SYSTEM_ALERT_HIGH      = $10000000; // This information is of high priority
  STATE_SYSTEM_PROTECTED       = $20000000; // access to this is restricted
  STATE_SYSTEM_VALID           = $3FFFFFFF;

  CCHILDREN_TITLEBAR  = 5;
  CCHILDREN_SCROLLBAR = 5;

//
// Information about the global cursor.
//

type
  LPCURSORINFO = ^CURSORINFO;
  tagCURSORINFO = record
    cbSize: DWORD;
    flags: DWORD;
    hCursor: HCURSOR;
    ptScreenPos: POINT;
  end;
  CURSORINFO = tagCURSORINFO;
  TCursorInfo = CURSORINFO;
  PCursorInfo = LPCURSORINFO;

const
  CURSOR_SHOWING = $00000001;

function GetCursorInfo(var pci: CURSORINFO): BOOL; stdcall;

//
// Window information snapshot
//

type
  LPWINDOWINFO = ^WINDOWINFO;
  tagWINDOWINFO = record
    cbSize: DWORD;
    rcWindow: RECT;
    rcClient: RECT;
    dwStyle: DWORD;
    dwExStyle: DWORD;
    dwWindowStatus: DWORD;
    cxWindowBorders: UINT;
    cyWindowBorders: UINT;
    atomWindowType: ATOM;
    wCreatorVersion: WORD;
  end;
  WINDOWINFO = tagWINDOWINFO;
  TWindowInfo = WINDOWINFO;
  PWindowInfo = LPWINDOWINFO;

const
  WS_ACTIVECAPTION = $0001;

function GetWindowInfo(hwnd: HWND; var pwi: WINDOWINFO): BOOL; stdcall;

//
// Titlebar information.
//

type
  LPTITLEBARINFO = ^TITLEBARINFO;
  tagTITLEBARINFO = record
    cbSize: DWORD;
    rcTitleBar: RECT;
    rgstate: array [0..CCHILDREN_TITLEBAR] of DWORD;
  end;
  TITLEBARINFO = tagTITLEBARINFO;
  TTitleBarInfo = TITLEBARINFO;
  PTitleBarInfo = LPTITLEBARINFO;

function GetTitleBarInfo(hwnd: HWND; var pti: TITLEBARINFO): BOOL; stdcall;

//
// Menubar information
//

type
  LPMENUBARINFO = ^MENUBARINFO;
  tagMENUBARINFO = record
    cbSize: DWORD;
    rcBar: RECT;          // rect of bar, popup, item
    hMenu: HMENU;         // real menu handle of bar, popup
    hwndMenu: HWND;       // hwnd of item submenu if one
    Flags: DWORD;
    // BOOL  fBarFocused:1;  // bar, popup has the focus
    // BOOL  fFocused:1;     // item has the focus
  end;
  MENUBARINFO = tagMENUBARINFO;
  TMenuBarInfo = MENUBARINFO;
  PMenuBarInfo = LPMENUBARINFO;

function GetMenuBarInfo(hwnd: HWND; idObject: LONG; idItem: LONG;
  var pmbi: MENUBARINFO): BOOL; stdcall;

//
// Scrollbar information
//

type
  LPSCROLLBARINFO = ^SCROLLBARINFO;
  tagSCROLLBARINFO = record
    cbSize: DWORD;
    rcScrollBar: RECT;
    dxyLineButton: Integer;
    xyThumbTop: Integer;
    xyThumbBottom: Integer;
    reserved: Integer;
    rgstate: array [0..CCHILDREN_SCROLLBAR] of DWORD;
  end;
  SCROLLBARINFO = tagSCROLLBARINFO;
  TScrollBarInfo = SCROLLBARINFO;
  PScrollBarInfo = LPSCROLLBARINFO;

function GetScrollBarInfo(hwnd: HWND; idObject: LONG; var psbi: SCROLLBARINFO): BOOL; stdcall;

//
// Combobox information
//

type
  LPCOMBOBOXINFO = ^COMBOBOXINFO;
  tagCOMBOBOXINFO = record
    cbSize: DWORD;
    rcItem: RECT;
    rcButton: RECT;
    stateButton: DWORD;
    hwndCombo: HWND;
    hwndItem: HWND;
    hwndList: HWND;
  end;
  COMBOBOXINFO = tagCOMBOBOXINFO;
  TComboBoxInfo = COMBOBOXINFO;
  PComboBoxInfo = LPCOMBOBOXINFO;

function GetComboBoxInfo(hwndCombo: HWND; var pcbi: COMBOBOXINFO): BOOL; stdcall;

//
// The "real" ancestor window
//

const
  GA_PARENT    = 1;
  GA_ROOT      = 2;
  GA_ROOTOWNER = 3;

function GetAncestor(hwnd: HWND; gaFlags: UINT): HWND; stdcall;

//
// This gets the REAL child window at the point.  If it is in the dead
// space of a group box, it will try a sibling behind it.  But static
// fields will get returned.  In other words, it is kind of a cross between
// ChildWindowFromPointEx and WindowFromPoint.
//

function RealChildWindowFromPoint(hwndParent: HWND; ptParentClientCoords: POINT): HWND; stdcall;

//
// This gets the name of the window TYPE, not class.  This allows us to
// recognize ThunderButton32 et al.
//

function RealGetWindowClassA(hwnd: HWND; pszType: LPSTR; cchType: UINT): UINT; stdcall;

//
// This gets the name of the window TYPE, not class.  This allows us to
// recognize ThunderButton32 et al.
//

function RealGetWindowClassW(hwnd: HWND; pszType: LPWSTR; cchType: UINT): UINT; stdcall;

{$IFDEF UNICODE}
function RealGetWindowClass(hwnd: HWND; pszType: LPWSTR; cchType: UINT): UINT; stdcall;
{$ELSE}
function RealGetWindowClass(hwnd: HWND; pszType: LPSTR; cchType: UINT): UINT; stdcall;
{$ENDIF}

//
// Alt-Tab Switch window information.
//

type
  LPALTTABINFO = ^ALTTABINFO;
  tagALTTABINFO = record
    cbSize: DWORD;
    cItems: Integer;
    cColumns: Integer;
    cRows: Integer;
    iColFocus: Integer;
    iRowFocus: Integer;
    cxItem: Integer;
    cyItem: Integer;
    ptStart: POINT;
  end;
  ALTTABINFO = tagALTTABINFO;
  TAltTabInfo = ALTTABINFO;
  PAltTabInfo = LPALTTABINFO;

function GetAltTabInfoA(hwnd: HWND; iItem: Integer; var pati: ALTTABINFO;
  pszItemText: LPSTR; cchItemText: UINT): BOOL; stdcall;
function GetAltTabInfoW(hwnd: HWND; iItem: Integer; var pati: ALTTABINFO;
  pszItemText: LPWSTR; cchItemText: UINT): BOOL; stdcall;

{$IFDEF UNICODE}
function GetAltTabInfo(hwnd: HWND; iItem: Integer; var pati: ALTTABINFO;
  pszItemText: LPWSTR; cchItemText: UINT): BOOL; stdcall;
{$ELSE}
function GetAltTabInfo(hwnd: HWND; iItem: Integer; var pati: ALTTABINFO;
  pszItemText: LPSTR; cchItemText: UINT): BOOL; stdcall;
{$ENDIF}

//
// Listbox information.
// Returns the number of items per row.
//

function GetListBoxInfo(hwnd: HWND): DWORD; stdcall;

function LockWorkStation: BOOL; stdcall;

function UserHandleGrantAccess(hUserHandle, hJob: HANDLE; bGrant: BOOL): BOOL; stdcall;

//
// Raw Input Messages.
//

type
  HRAWINPUT = HANDLE;

//
// WM_INPUT wParam
//

//
// Use this macro to get the input code from wParam.
//

function GET_RAWINPUT_CODE_WPARAM(wParam: WPARAM): DWORD;

//
// The input is in the regular message flow,
// the app is required to call DefWindowProc
// so that the system can perform clean ups.
//

const
  RIM_INPUT       = 0;

//
// The input is sink only. The app is expected
// to behave nicely.
//

  RIM_INPUTSINK   = 1;

//
// Raw Input data header
//

type
  tagRAWINPUTHEADER = record
    dwType: DWORD;
    dwSize: DWORD;
    hDevice: HANDLE;
    wParam: WPARAM;
  end;
  RAWINPUTHEADER = tagRAWINPUTHEADER;
  PRAWINPUTHEADER = ^RAWINPUTHEADER;
  LPRAWINPUTHEADER = ^RAWINPUTHEADER;
  TRawInputHeader = RAWINPUTHEADER;

//
// Type of the raw input
//

const
  RIM_TYPEMOUSE      = 0;
  RIM_TYPEKEYBOARD   = 1;
  RIM_TYPEHID        = 2;

//
// Raw format of the mouse input
//

type
  tagRAWMOUSE = record
    //
    // Indicator flags.
    //
    usFlags: USHORT;

    //
    // The transition state of the mouse buttons.
    //

    union: record
    case Integer of
      0: (
        ulButtons: ULONG);
      1: (
        usButtonFlags: USHORT;
        usButtonData: USHORT);
    end;

    //
    // The raw state of the mouse buttons.
    //
    ulRawButtons: ULONG;

    //
    // The signed relative or absolute motion in the X direction.
    //
    lLastX: LONG;

    //
    // The signed relative or absolute motion in the Y direction.
    //
    lLastY: LONG;

    //
    // Device-specific additional information for the event.
    //
    ulExtraInformation: ULONG;
  end;
  RAWMOUSE = tagRAWMOUSE;
  PRAWMOUSE = ^RAWMOUSE;
  LPRAWMOUSE = ^RAWMOUSE;
  TRawMouse = RAWMOUSE;

//
// Define the mouse button state indicators.
//

const
  RI_MOUSE_LEFT_BUTTON_DOWN   = $0001; // Left Button changed to down.
  RI_MOUSE_LEFT_BUTTON_UP     = $0002; // Left Button changed to up.
  RI_MOUSE_RIGHT_BUTTON_DOWN  = $0004; // Right Button changed to down.
  RI_MOUSE_RIGHT_BUTTON_UP    = $0008; // Right Button changed to up.
  RI_MOUSE_MIDDLE_BUTTON_DOWN = $0010; // Middle Button changed to down.
  RI_MOUSE_MIDDLE_BUTTON_UP   = $0020; // Middle Button changed to up.

  RI_MOUSE_BUTTON_1_DOWN = RI_MOUSE_LEFT_BUTTON_DOWN;
  RI_MOUSE_BUTTON_1_UP   = RI_MOUSE_LEFT_BUTTON_UP;
  RI_MOUSE_BUTTON_2_DOWN = RI_MOUSE_RIGHT_BUTTON_DOWN;
  RI_MOUSE_BUTTON_2_UP   = RI_MOUSE_RIGHT_BUTTON_UP;
  RI_MOUSE_BUTTON_3_DOWN = RI_MOUSE_MIDDLE_BUTTON_DOWN;
  RI_MOUSE_BUTTON_3_UP   = RI_MOUSE_MIDDLE_BUTTON_UP;

  RI_MOUSE_BUTTON_4_DOWN = $0040;
  RI_MOUSE_BUTTON_4_UP   = $0080;
  RI_MOUSE_BUTTON_5_DOWN = $0100;
  RI_MOUSE_BUTTON_5_UP   = $0200;

//
// If usButtonFlags has RI_MOUSE_WHEEL, the wheel delta is stored in usButtonData.
// Take it as a signed value.
//

  RI_MOUSE_WHEEL = $0400;

//
// Define the mouse indicator flags.
//

  MOUSE_MOVE_RELATIVE      = 0;
  MOUSE_MOVE_ABSOLUTE      = 1;
  MOUSE_VIRTUAL_DESKTOP    = $02; // the coordinates are mapped to the virtual desktop
  MOUSE_ATTRIBUTES_CHANGED = $04; // requery for mouse attributes

//
// Raw format of the keyboard input
//

type
  tagRAWKEYBOARD = record
    //
    // The "make" scan code (key depression).
    //
    MakeCode: USHORT;

    //
    // The flags field indicates a "break" (key release) and other
    // miscellaneous scan code information defined in ntddkbd.h.
    //
    Flags: USHORT;

    Reserved: USHORT;

    //
    // Windows message compatible information
    //
    VKey: USHORT;
    Message: UINT;

    //
    // Device-specific additional information for the event.
    //
    ExtraInformation: ULONG;
  end;
  RAWKEYBOARD = tagRAWKEYBOARD;
  PRAWKEYBOARD = ^RAWKEYBOARD;
  LPRAWKEYBOARD = ^RAWKEYBOARD;
  TRawKeyBoard = RAWKEYBOARD;

//
// Define the keyboard overrun MakeCode.
//

const
  KEYBOARD_OVERRUN_MAKE_CODE = $FF;

//
// Define the keyboard input data Flags.
//

  RI_KEY_MAKE            = 0;
  RI_KEY_BREAK           = 1;
  RI_KEY_E0              = 2;
  RI_KEY_E1              = 4;
  RI_KEY_TERMSRV_SET_LED = 8;
  RI_KEY_TERMSRV_SHADOW  = $10;

//
// Raw format of the input from Human Input Devices
//

type
  tagRAWHID = record
    dwSizeHid: DWORD;    // byte size of each report
    dwCount: DWORD;      // number of input packed
    bRawData: array [0..0] of BYTE;
  end;
  RAWHID = tagRAWHID;
  PRAWHID = ^RAWHID;
  LPRAWHID = ^RAWHID;
  TRawHid = RAWHID;

//
// RAWINPUT data structure.
//

  tagRAWINPUT = record
    header: RAWINPUTHEADER;
    case Integer of
      0: (mouse: RAWMOUSE);
      1: (keyboard: RAWKEYBOARD);
      2: (hid: RAWHID);
  end;
  RAWINPUT = tagRAWINPUT;
  PRAWINPUT = ^RAWINPUT;
  LPRAWINPUT = ^RAWINPUT;
  TRawInput = RAWINPUT;

function RAWINPUT_ALIGN(x: Pointer): Pointer;

function NEXTRAWINPUTBLOCK(ptr: PRawInput): PRawInput;

//
// Flags for GetRawInputData
//

const
  RID_INPUT  = $10000003;
  RID_HEADER = $10000005;

function GetRawInputData(hRawInput: HRAWINPUT; uiCommand: UINT; pData: LPVOID;
  var pcbSize: UINT; cbSizeHeader: UINT): UINT; stdcall;

//
// Raw Input Device Information
//

const
  RIDI_PREPARSEDDATA = $20000005;
  RIDI_DEVICENAME    = $20000007; // the return valus is the character length, not the byte size
  RIDI_DEVICEINFO    = $2000000b;

type
  PRID_DEVICE_INFO_MOUSE = ^RID_DEVICE_INFO_MOUSE;
  tagRID_DEVICE_INFO_MOUSE = record
    dwId: DWORD;
    dwNumberOfButtons: DWORD;
    dwSampleRate: DWORD;
  end;
  RID_DEVICE_INFO_MOUSE = tagRID_DEVICE_INFO_MOUSE;
  TRidDeviceInfoMouse = RID_DEVICE_INFO_MOUSE;
  PRidDeviceInfoMouse = PRID_DEVICE_INFO_MOUSE;

  PRID_DEVICE_INFO_KEYBOARD = ^RID_DEVICE_INFO_KEYBOARD;
  tagRID_DEVICE_INFO_KEYBOARD = record
    dwType: DWORD;
    dwSubType: DWORD;
    dwKeyboardMode: DWORD;
    dwNumberOfFunctionKeys: DWORD;
    dwNumberOfIndicators: DWORD;
    dwNumberOfKeysTotal: DWORD;
  end;
  RID_DEVICE_INFO_KEYBOARD = tagRID_DEVICE_INFO_KEYBOARD;
  TRidDeviceInfoKeyboard = RID_DEVICE_INFO_KEYBOARD;
  PRidDeviceInfoKeyboard = PRID_DEVICE_INFO_KEYBOARD;

  PRID_DEVICE_INFO_HID = ^RID_DEVICE_INFO_HID;
  tagRID_DEVICE_INFO_HID = record
    dwVendorId: DWORD;
    dwProductId: DWORD;
    dwVersionNumber: DWORD;
    //
    // Top level collection UsagePage and Usage
    //
    usUsagePage: USHORT;
    usUsage: USHORT;
  end;
  RID_DEVICE_INFO_HID = tagRID_DEVICE_INFO_HID;
  TRidDeviceInfoHid = RID_DEVICE_INFO_HID;
  PRidDeviceInfoHid = PRID_DEVICE_INFO_HID;

  tagRID_DEVICE_INFO = record
    cbSize: DWORD;
    dwType: DWORD;
    case Integer of
    0: (mouse: RID_DEVICE_INFO_MOUSE);
    1: (keyboard: RID_DEVICE_INFO_KEYBOARD);
    2: (hid: RID_DEVICE_INFO_HID);
  end;
  RID_DEVICE_INFO = tagRID_DEVICE_INFO;
  PRID_DEVICE_INFO = ^RID_DEVICE_INFO;
  LPRID_DEVICE_INFO = ^RID_DEVICE_INFO;
  TRidDeviceInfo = RID_DEVICE_INFO;
  PRidDeviceInfo = PRID_DEVICE_INFO;

function GetRawInputDeviceInfoA(hDevice: HANDLE; uiCommand: UINT; pData: LPVOID;
  var pcbSize: UINT): UINT; stdcall;
function GetRawInputDeviceInfoW(hDevice: HANDLE; uiCommand: UINT; pData: LPVOID;
  var pcbSize: UINT): UINT; stdcall;

{$IFDEF UNICODE}
function GetRawInputDeviceInfo(hDevice: HANDLE; uiCommand: UINT; pData: LPVOID;
  var pcbSize: UINT): UINT; stdcall;
{$ELSE}
function GetRawInputDeviceInfo(hDevice: HANDLE; uiCommand: UINT; pData: LPVOID;
  var pcbSize: UINT): UINT; stdcall;
{$ENDIF}

//
// Raw Input Bulk Read: GetRawInputBuffer
//

function GetRawInputBuffer(pData: PRAWINPUT; var pcbSize: UINT; cbSizeHeader: UINT): UINT; stdcall;

//
// Raw Input request APIs
//

type
  LPRAWINPUTDEVICE = ^RAWINPUTDEVICE;
  PRAWINPUTDEVICE = ^RAWINPUTDEVICE;
  tagRAWINPUTDEVICE = record
    usUsagePage: USHORT; // Toplevel collection UsagePage
    usUsage: USHORT;     // Toplevel collection Usage
    dwFlags: DWORD;
    hwndTarget: HWND;    // Target hwnd. NULL = follows keyboard focus
  end;
  RAWINPUTDEVICE = tagRAWINPUTDEVICE;
  TRawInputDevice = RAWINPUTDEVICE;

const
  RIDEV_REMOVE       = $00000001;
  RIDEV_EXCLUDE      = $00000010;
  RIDEV_PAGEONLY     = $00000020;
  RIDEV_NOLEGACY     = $00000030;
  RIDEV_INPUTSINK    = $00000100;
  RIDEV_CAPTUREMOUSE = $00000200; // effective when mouse nolegacy is specified, otherwise it would be an error
  RIDEV_NOHOTKEYS    = $00000200; // effective for keyboard.
  RIDEV_APPKEYS      = $00000400;  // effective for keyboard.
  RIDEV_EXMODEMASK   = $000000F0;

function RIDEV_EXMODE(mode: DWORD): DWORD;

function RegisterRawInputDevices(pRawInputDevices: PRAWINPUTDEVICE;
  uiNumDevices: UINT; cbSize: UINT): BOOL; stdcall;

function GetRegisteredRawInputDevices(pRawInputDevices: PRAWINPUTDEVICE;
  var puiNumDevices: UINT; cbSize: UINT): UINT; stdcall;

type
  PRAWINPUTDEVICELIST = ^RAWINPUTDEVICELIST;
  tagRAWINPUTDEVICELIST = record
    hDevice: HANDLE;
    dwType: DWORD;
  end;
  RAWINPUTDEVICELIST = tagRAWINPUTDEVICELIST;
  TRawInputDeviceList = RAWINPUTDEVICELIST;

function GetRawInputDeviceList(pRawInputDeviceList: PRAWINPUTDEVICELIST; var puiNumDevices: UINT;
  cbSize: UINT): UINT; stdcall;

function DefRawInputProc(paRawInput: PRAWINPUT; nInput: Integer; cbSizeHeader: UINT): LRESULT; stdcall;

implementation

const
  user32 = 'user32.dll';

function IS_INTRESOURCE(wInteger: WORD): BOOL;
begin
  Result := (ULONG_PTR(wInteger) shr 16) = 0;
end;

function GET_WHEEL_DELTA_WPARAM(wParam: WPARAM): SHORT;
begin
  Result := SHORT(HIWORD(wParam));
end;

function GET_KEYSTATE_WPARAM(wParam: WPARAM): Integer;
begin
  Result := LOWORD(wParam);
end;

function GET_NCHITTEST_WPARAM(wParam: WPARAM): Shortint;
begin
  Result := LOWORD(wParam);
end;

function GET_XBUTTON_WPARAM(wParam: WPARAM): Integer;
begin
  Result := HIWORD(wParam);
end;

function GET_APPCOMMAND_LPARAM(lParam: LPARAM): Shortint;
begin
  Result := Shortint(HIWORD(lParam) and not FAPPCOMMAND_MASK);
end;

function GET_DEVICE_LPARAM(lParam: LPARAM): WORD;
begin
  Result := WORD(HIWORD(lParam) and FAPPCOMMAND_MASK);
end;

function GET_MOUSEORKEY_LPARAM(lParam: LPARAM): WORD;
begin
  Result := GET_DEVICE_LPARAM(lParam);
end;

function GET_FLAGS_LPARAM(lParam: LPARAM): Integer;
begin
  Result := LOWORD(lParam);
end;

function GET_KEYSTATE_LPARAM(lParam: LPARAM): Integer;
begin
  Result := GET_FLAGS_LPARAM(lParam);
end;

function MAKEWPARAM(wLow, wHigh: WORD): WPARAM;
begin
  Result := WPARAM(DWORD(MAKELONG(wLow, wHigh)));
end;

function MAKELPARAM(wLow, wHigh: WORD): LPARAM;
begin
  Result := LPARAM(DWORD(MAKELONG(wLow, wHigh)));
end;

function MAKELRESULT(wLow, wHigh: WORD): LRESULT;
begin
  Result := LRESULT(DWORD(MAKELONG(wLow, wHigh)));
end;

function ExitWindows(dwReserved: DWORD; uREserved: UINT): BOOL;
begin
  Result := ExitWindowsEx(EWX_LOGOFF, $FFFFFFFF);
end;

function PostAppMessageA(idThread: DWORD; wMsg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL;
begin
  Result := PostThreadMessageA(idThread, wMsg, wParam, lParam);
end;

function PostAppMessageW(idThread: DWORD; wMsg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL;
begin
  Result := PostThreadMessageW(idThread, wMsg, wParam, lParam);
end;

{$IFDEF UNICODE}
function PostAppMessage(idThread: DWORD; wMsg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL;
begin
  Result := PostThreadMessageW(idThread, wMsg, wParam, lParam);
end;
{$ELSE}
function PostAppMessage(idThread: DWORD; wMsg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL;
begin
  Result := PostThreadMessageA(idThread, wMsg, wParam, lParam);
end;
{$ENDIF}

function CreateWindowA(lpClassName: LPCSTR; lpWindowName: LPCSTR; dwStyle: DWORD;
  x, y, nWidth, nHeight: Integer; hWndParent: HWND; hMenu: HMENU;
  hInstance: HINSTANCE; lpParam: LPVOID): HWND;
begin
  Result := CreateWindowExA(0, lpClassName, lpWindowName, dwStyle, x, y,
    nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam);
end;

function CreateWindowW(lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD;
  x, y, nWidth, nHeight: Integer; hWndParent: HWND; hMenu: HMENU;
  hInstance: HINSTANCE; lpParam: LPVOID): HWND;
begin
  Result := CreateWindowExW(0, lpClassName, lpWindowName, dwStyle, x, y,
    nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam);
end;

{$IFDEF UNICODE}
function CreateWindow(lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD;
  x, y, nWidth, nHeight: Integer; hWndParent: HWND; hMenu: HMENU;
  hInstance: HINSTANCE; lpParam: LPVOID): HWND;
begin
  Result := CreateWindowExW(0, lpClassName, lpWindowName, dwStyle, x, y,
    nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam);
end;
{$ELSE}
function CreateWindow(lpClassName: LPCSTR; lpWindowName: LPCSTR; dwStyle: DWORD;
  x, y, nWidth, nHeight: Integer; hWndParent: HWND; hMenu: HMENU;
  hInstance: HINSTANCE; lpParam: LPVOID): HWND;
begin
  Result := CreateWindowExA(0, lpClassName, lpWindowName, dwStyle, x, y,
    nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam);
end;
{$ENDIF}

function CreateDialogA(hInstance: HINSTANCE; lpName: LPCSTR; hWndParent: HWND; lpDialogFunc: DLGPROC): HWND;
begin
  Result := CreateDialogParamA(hInstance, lpName, hWndParent, lpDialogFunc, 0);
end;

function CreateDialogW(hInstance: HINSTANCE; lpName: LPCWSTR; hWndParent: HWND; lpDialogFunc: DLGPROC): HWND;
begin
  Result := CreateDialogParamW(hInstance, lpName, hWndParent, lpDialogFunc, 0);
end;

{$IFDEF UNICODE}
function CreateDialog(hInstance: HINSTANCE; lpName: LPCWSTR; hWndParent: HWND; lpDialogFunc: DLGPROC): HWND;
begin
  Result := CreateDialogParamW(hInstance, lpName, hWndParent, lpDialogFunc, 0);
end;
{$ELSE}
function CreateDialog(hInstance: HINSTANCE; lpName: LPCSTR; hWndParent: HWND; lpDialogFunc: DLGPROC): HWND;
begin
  Result := CreateDialogParamA(hInstance, lpName, hWndParent, lpDialogFunc, 0);
end;
{$ENDIF}

function CreateDialogIndirectA(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE;
  hWndParent: HWND; lpDialogFunc: DLGPROC): HWND;
begin
  Result := CreateDialogIndirectParamA(hInstance, lpTemplate, hWndParent, lpDialogFunc, 0);
end;

function CreateDialogIndirectW(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE;
  hWndParent: HWND; lpDialogFunc: DLGPROC): HWND;
begin
  Result := CreateDialogIndirectParamW(hInstance, lpTemplate, hWndParent, lpDialogFunc, 0);
end;

{$IFDEF UNICODE}
function CreateDialogIndirect(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE;
  hWndParent: HWND; lpDialogFunc: DLGPROC): HWND;
begin
  Result := CreateDialogIndirectParamW(hInstance, lpTemplate, hWndParent, lpDialogFunc, 0);
end;
{$ELSE}
function CreateDialogIndirect(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE;
  hWndParent: HWND; lpDialogFunc: DLGPROC): HWND;
begin
  Result := CreateDialogIndirectParamA(hInstance, lpTemplate, hWndParent, lpDialogFunc, 0);
end;
{$ENDIF}

function DialogBoxA(hInstance: HINSTANCE; lpTemplate: LPCSTR; hWndParent: HWND; lpDialogFunc: DLGPROC): INT_PTR;
begin
  Result := DialogBoxParamA(hInstance, lpTemplate, hWndParent, lpDialogFunc, 0);
end;

function DialogBoxW(hInstance: HINSTANCE; lpTemplate: LPCWSTR; hWndParent: HWND; lpDialogFunc: DLGPROC): INT_PTR;
begin
  Result := DialogBoxParamW(hInstance, lpTemplate, hWndParent, lpDialogFunc, 0);
end;

{$IFDEF UNICODE}
function DialogBox(hInstance: HINSTANCE; lpTemplate: LPCWSTR; hWndParent: HWND; lpDialogFunc: DLGPROC): INT_PTR;
begin
  Result := DialogBoxParamW(hInstance, lpTemplate, hWndParent, lpDialogFunc, 0);
end;
{$ELSE}
function DialogBox(hInstance: HINSTANCE; lpTemplate: LPCSTR; hWndParent: HWND; lpDialogFunc: DLGPROC): INT_PTR;
begin
  Result := DialogBoxParamA(hInstance, lpTemplate, hWndParent, lpDialogFunc, 0);
end;
{$ENDIF}

function DialogBoxIndirectA(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE; hWndParent: HWND; lpDialogFunc: DLGPROC): INT_PTR;
begin
  Result := DialogBoxIndirectParamA(hInstance, lpTemplate, hWndParent, lpDialogFunc, 0);
end;

function DialogBoxIndirectW(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE; hWndParent: HWND; lpDialogFunc: DLGPROC): INT_PTR;
begin
  Result := DialogBoxIndirectParamW(hInstance, lpTemplate, hWndParent, lpDialogFunc, 0);
end;

{$IFDEF UNICODE}
function DialogBoxIndirect(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE; hWndParent: HWND; lpDialogFunc: DLGPROC): INT_PTR;
begin
  Result := DialogBoxIndirectParamW(hInstance, lpTemplate, hWndParent, lpDialogFunc, 0);
end;
{$ELSE}
function DialogBoxIndirect(hInstance: HINSTANCE; const lpTemplate: DLGTEMPLATE; hWndParent: HWND; lpDialogFunc: DLGPROC): INT_PTR;
begin
  Result := DialogBoxIndirectParamA(hInstance, lpTemplate, hWndParent, lpDialogFunc, 0);
end;
{$ENDIF}

function AnsiToOem(lpszSrc: LPCSTR; lpszDst: LPSTR): BOOL;
begin
  Result := CharToOemA(lpszSrc, lpszDst);
end;

function OemToAnsi(lpszSrc: LPCSTR; lpszDst: LPSTR): BOOL;
begin
  Result := OemToCharA(lpszSrc, lpszDst);
end;

function AnsiToOemBuff(lpszSrc: LPCSTR; lpszDst: LPSTR; cchDstLength: DWORD): BOOL;
begin
  Result := CharToOemBuffA(lpszSrc, lpszDst, cchDstLength);
end;

function OemToAnsiBuff(lpszSrc: LPCSTR; lpszDst: LPSTR; cchDstLength: DWORD): BOOL;
begin
  Result := OemToCharBuffA(lpszSrc, lpszDst, cchDstLength);
end;

function AnsiUpper(lpsz: LPSTR): LPSTR;
begin
  Result := CharUpperA(lpsz);
end;

function AnsiUpperBuff(lpsz: LPSTR; cchLength: DWORD): DWORD;
begin
  Result := CharUpperBuffA(lpsz, cchLength);
end;

function AnsiLower(lpsz: LPSTR): LPSTR;
begin
  Result := CharLowerA(lpsz);
end;

function AnsiLowerBuff(lpsz: LPSTR; cchLength: DWORD): DWORD;
begin
  Result := CharLowerBuffA(lpsz, cchLength);
end;

function AnsiNext(lpsz: LPCSTR): LPSTR;
begin
  Result := CharNextA(lpsz);
end;

function AnsiPrev(lpszStart: LPCSTR; lpszCurrent: LPCSTR): LPSTR;
begin
  Result := CharPrevA(lpszStart, lpszCurrent);
end;

function GetWindowLongPtrA(hWnd: HWND; nIndex: Integer): LONG_PTR;
begin
  Result := GetWindowLongA(hWnd, nIndex);
end;

function GetWindowLongPtrW(hWnd: HWND; nIndex: Integer): LONG_PTR;
begin
  Result := GetWindowLongW(hWnd, nIndex);
end;

{$IFDEF UNICODE}
function GetWindowLongPtr(hWnd: HWND; nIndex: Integer): LONG_PTR;
begin
  Result := GetWindowLongW(hWnd, nIndex);
end;
{$ELSE}
function GetWindowLongPtr(hWnd: HWND; nIndex: Integer): LONG_PTR;
begin
  Result := GetWindowLongA(hWnd, nIndex);
end;
{$ENDIF}

function SetWindowLongPtrA(hWnd: HWND; nIndex: Integer; dwNewLong: LONG_PTR): LONG_PTR;
begin
  Result := SetWindowLongA(hWnd, nIndex, dwNewLong);
end;

function SetWindowLongPtrW(hWnd: HWND; nIndex: Integer; dwNewLong: LONG_PTR): LONG_PTR;
begin
  Result := SetWindowLongW(hWnd, nIndex, dwNewLong);
end;

{$IFDEF UNICODE}
function SetWindowLongPtr(hWnd: HWND; nIndex: Integer; dwNewLong: LONG_PTR): LONG_PTR;
begin
  Result := SetWindowLongW(hWnd, nIndex, dwNewLong);
end;
{$ELSE}
function SetWindowLongPtr(hWnd: HWND; nIndex: Integer; dwNewLong: LONG_PTR): LONG_PTR;
begin
  Result := SetWindowLongA(hWnd, nIndex, dwNewLong);
end;
{$ENDIF}

function GetClassLongPtrA(hWnd: HWND; nIndex: Integer): ULONG_PTR;
begin
  Result := GetClassLongA(hWnd, nIndex);
end;

function GetClassLongPtrW(hWnd: HWND; nIndex: Integer): ULONG_PTR;
begin
  Result := GetClassLongW(hWnd, nIndex);
end;

{$IFDEF UNICODE}
function GetClassLongPtr(hWnd: HWND; nIndex: Integer): ULONG_PTR;
begin
  Result := GetClassLongW(hWnd, nIndex);
end;
{$ELSE}
function GetClassLongPtr(hWnd: HWND; nIndex: Integer): ULONG_PTR;
begin
  Result := GetClassLongA(hWnd, nIndex);
end;
{$ENDIF}

function SetClassLongPtrA(hWnd: HWND; nIndex: Integer; dwNewLong: ULONG_PTR): ULONG_PTR;
begin
  Result := SetClassLongA(hWnd, nIndex, dwNewLong);
end;

function SetClassLongPtrW(hWnd: HWND; nIndex: Integer; dwNewLong: ULONG_PTR): ULONG_PTR;
begin
  Result := SetClassLongW(hWnd, nIndex, dwNewLong);
end;

{$IFDEF UNICODE}
function SetClassLongPtr(hWnd: HWND; nIndex: Integer; dwNewLong: ULONG_PTR): ULONG_PTR;
begin
  Result := SetClassLongW(hWnd, nIndex, dwNewLong);
end;
{$ELSE}
function SetClassLongPtr(hWnd: HWND; nIndex: Integer; dwNewLong: ULONG_PTR): ULONG_PTR;
begin
  Result := SetClassLongA(hWnd, nIndex, dwNewLong);
end;
{$ENDIF}

function EnumTaskWindows(hTask: HANDLE; lpfn: WNDENUMPROC; lParam: LPARAM): BOOL;
begin
  Result := EnumThreadWindows(ULONG(hTask), lpfn, lParam);
end;

function GetNextWindow(hWnd: HWND; wCmd: UINT): HWND;
begin
  Result := GetWindow(hWnd, wCmd);
end;

function GetWindowTask(hWnd: HWND): HANDLE;
begin
  Result := HANDLE(DWORD_PTR(GetWindowThreadProcessId(hWnd, nil)));
end;

function DefHookProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM; phhk: LPHHOOK): LRESULT;
begin
  Result := CallNextHookEx(HHOOK(phhk^), nCode, wParam, lParam);
end;

function CopyCursor(pcur: HCURSOR): HCURSOR;
begin
 Result := HCURSOR(CopyIcon(HICON(pcur)));
end;

function IsHungAppWindow; external user32 name 'IsHungAppWindow';
function wvsprintfA; external user32 name 'wvsprintfA';
function wvsprintfW; external user32 name 'wvsprintfW';
function wvsprintf; external user32 name 'wvsprintf' + AWSuffix;
function wsprintfA; external user32 name 'wsprintfA';
function wsprintfW; external user32 name 'wsprintfW';
function wsprintf; external user32 name 'wsprintf' + AWSuffix;
function LoadKeyboardLayoutA; external user32 name 'LoadKeyboardLayoutA';
function LoadKeyboardLayoutW; external user32 name 'LoadKeyboardLayoutW';
function LoadKeyboardLayout; external user32 name 'LoadKeyboardLayout' + AWSuffix;
function ActivateKeyboardLayout; external user32 name 'ActivateKeyboardLayout';
function ToUnicodeEx; external user32 name 'ToUnicodeEx';
function UnloadKeyboardLayout; external user32 name 'UnloadKeyboardLayout';
function GetKeyboardLayoutNameA; external user32 name 'GetKeyboardLayoutNameA';
function GetKeyboardLayoutNameW; external user32 name 'GetKeyboardLayoutNameW';
function GetKeyboardLayoutName; external user32 name 'GetKeyboardLayoutName' + AWSuffix;
function GetKeyboardLayoutList; external user32 name 'GetKeyboardLayoutList';
function GetKeyboardLayout; external user32 name 'GetKeyboardLayout';
function GetMouseMovePointsEx; external user32 name 'GetMouseMovePointsEx';
function CreateDesktopA; external user32 name 'CreateDesktopA';
function CreateDesktopW; external user32 name 'CreateDesktopW';
function CreateDesktop; external user32 name 'CreateDesktop' + AWSuffix;
function OpenDesktopA; external user32 name 'OpenDesktopA';
function OpenDesktopW; external user32 name 'OpenDesktopW';
function OpenDesktop; external user32 name 'OpenDesktop' + AWSuffix;
function OpenInputDesktop; external user32 name 'OpenInputDesktop';
function EnumDesktopsA; external user32 name 'EnumDesktopsA';
function EnumDesktopsW; external user32 name 'EnumDesktopsW';
function EnumDesktops; external user32 name 'EnumDesktops' + AWSuffix;
function EnumDesktopWindows; external user32 name 'EnumDesktopWindows';
function SwitchDesktop; external user32 name 'SwitchDesktop';
function SetThreadDesktop; external user32 name 'SetThreadDesktop';
function CloseDesktop; external user32 name 'CloseDesktop';
function GetThreadDesktop; external user32 name 'GetThreadDesktop';
function CreateWindowStationA; external user32 name 'CreateWindowStationA';
function CreateWindowStationW; external user32 name 'CreateWindowStationW';
function CreateWindowStation; external user32 name 'CreateWindowStation' + AWSuffix;
function OpenWindowStationA; external user32 name 'OpenWindowStationA';
function OpenWindowStationW; external user32 name 'OpenWindowStationW';
function OpenWindowStation; external user32 name 'OpenWindowStation' + AWSuffix;
function EnumWindowStationsA; external user32 name 'EnumWindowStationsA';
function EnumWindowStationsW; external user32 name 'EnumWindowStationsW';
function EnumWindowStations; external user32 name 'EnumWindowStations' + AWSuffix;
function CloseWindowStation; external user32 name 'CloseWindowStation';
function SetProcessWindowStation; external user32 name 'SetProcessWindowStation';
function GetProcessWindowStation; external user32 name 'GetProcessWindowStation';
function SetUserObjectSecurity; external user32 name 'SetUserObjectSecurity';
function GetUserObjectSecurity; external user32 name 'GetUserObjectSecurity';
function GetUserObjectInformationA; external user32 name 'GetUserObjectInformationA';
function GetUserObjectInformationW; external user32 name 'GetUserObjectInformationW';
function GetUserObjectInformation; external user32 name 'GetUserObjectInformation' + AWSuffix;
function SetUserObjectInformationA; external user32 name 'SetUserObjectInformationA';
function SetUserObjectInformationW; external user32 name 'SetUserObjectInformationW';
function SetUserObjectInformation; external user32 name 'SetUserObjectInformation' + AWSuffix;
function RegisterWindowMessageA; external user32 name 'RegisterWindowMessageA';
function RegisterWindowMessageW; external user32 name 'RegisterWindowMessageW';
function RegisterWindowMessage; external user32 name 'RegisterWindowMessage' + AWSuffix;
function TrackMouseEvent; external user32 name 'TrackMouseEvent';
function DrawEdge; external user32 name 'DrawEdge';
function DrawFrameControl; external user32 name 'DrawFrameControl';
function DrawCaption; external user32 name 'DrawCaption';
function DrawAnimatedRects; external user32 name 'DrawAnimatedRects';
function GetMessageA; external user32 name 'GetMessageA';
function GetMessageW; external user32 name 'GetMessageW';
function GetMessage; external user32 name 'GetMessage' + AWSuffix;
function TranslateMessage; external user32 name 'TranslateMessage';
function DispatchMessageA; external user32 name 'DispatchMessageA';
function DispatchMessageW; external user32 name 'DispatchMessageW';
function DispatchMessage; external user32 name 'DispatchMessage' + AWSuffix;
function SetMessageQueue; external user32 name 'SetMessageQueue';
function PeekMessageA; external user32 name 'PeekMessageA';
function PeekMessageW; external user32 name 'PeekMessageW';
function PeekMessage; external user32 name 'PeekMessage' + AWSuffix;
function RegisterHotKey; external user32 name 'RegisterHotKey';
function UnregisterHotKey; external user32 name 'UnregisterHotKey';
function ExitWindowsEx; external user32 name 'ExitWindowsEx';
function SwapMouseButton; external user32 name 'SwapMouseButton';
function GetMessagePos; external user32 name 'GetMessagePos';
function GetMessageTime; external user32 name 'GetMessageTime';
function GetMessageExtraInfo; external user32 name 'GetMessageExtraInfo';
function SetMessageExtraInfo; external user32 name 'SetMessageExtraInfo';
function SendMessageA; external user32 name 'SendMessageA';
function SendMessageW; external user32 name 'SendMessageW';
function SendMessage; external user32 name 'SendMessage' + AWSuffix;
function SendMessageTimeoutA; external user32 name 'SendMessageTimeoutA';
function SendMessageTimeoutW; external user32 name 'SendMessageTimeoutW';
function SendMessageTimeout; external user32 name 'SendMessageTimeout' + AWSuffix;
function SendNotifyMessageA; external user32 name 'SendNotifyMessageA';
function SendNotifyMessageW; external user32 name 'SendNotifyMessageW';
function SendNotifyMessage; external user32 name 'SendNotifyMessage' + AWSuffix;
function SendMessageCallbackA; external user32 name 'SendMessageCallbackA';
function SendMessageCallbackW; external user32 name 'SendMessageCallbackW';
function SendMessageCallback; external user32 name 'SendMessageCallback' + AWSuffix;
function BroadcastSystemMessageExA; external user32 name 'BroadcastSystemMessageExA';
function BroadcastSystemMessageExW; external user32 name 'BroadcastSystemMessageExW';
function BroadcastSystemMessageEx; external user32 name 'BroadcastSystemMessageEx' + AWSuffix;
function BroadcastSystemMessageA; external user32 name 'BroadcastSystemMessageA';
function BroadcastSystemMessageW; external user32 name 'BroadcastSystemMessageW';
function BroadcastSystemMessage; external user32 name 'BroadcastSystemMessage' + AWSuffix;
function RegisterDeviceNotificationA; external user32 name 'RegisterDeviceNotificationA';
function RegisterDeviceNotificationW; external user32 name 'RegisterDeviceNotificationW';
function RegisterDeviceNotification; external user32 name 'RegisterDeviceNotification' + AWSuffix;
function UnregisterDeviceNotification; external user32 name 'UnregisterDeviceNotification';
function PostMessageA; external user32 name 'PostMessageA';
function PostMessageW; external user32 name 'PostMessageW';
function PostMessage; external user32 name 'PostMessage' + AWSuffix;
function PostThreadMessageA; external user32 name 'PostThreadMessageA';
function PostThreadMessageW; external user32 name 'PostThreadMessageW';
function PostThreadMessage; external user32 name 'PostThreadMessage' + AWSuffix;
function AttachThreadInput; external user32 name 'AttachThreadInput';
function ReplyMessage; external user32 name 'ReplyMessage';
function WaitMessage; external user32 name 'WaitMessage';
function WaitForInputIdle; external user32 name 'WaitForInputIdle';
function DefWindowProcA; external user32 name 'DefWindowProcA';
function DefWindowProcW; external user32 name 'DefWindowProcW';
function DefWindowProc; external user32 name 'DefWindowProc' + AWSuffix;
procedure PostQuitMessage; external user32 name 'PostQuitMessage';
function CallWindowProcA; external user32 name 'CallWindowProcA';
function CallWindowProcW; external user32 name 'CallWindowProcW';
function CallWindowProc; external user32 name 'CallWindowProc' + AWSuffix;
function InSendMessage; external user32 name 'InSendMessage';
function InSendMessageEx; external user32 name 'InSendMessageEx';
function GetDoubleClickTime; external user32 name 'GetDoubleClickTime';
function SetDoubleClickTime; external user32 name 'SetDoubleClickTime';
function RegisterClassA; external user32 name 'RegisterClassA';
function RegisterClassW; external user32 name 'RegisterClassW';
function RegisterClass; external user32 name 'RegisterClass' + AWSuffix;
function UnregisterClassA; external user32 name 'UnregisterClassA';
function UnregisterClassW; external user32 name 'UnregisterClassW';
function UnregisterClass; external user32 name 'UnregisterClass' + AWSuffix;
function GetClassInfoA; external user32 name 'GetClassInfoA';
function GetClassInfoW; external user32 name 'GetClassInfoW';
function GetClassInfo; external user32 name 'GetClassInfo' + AWSuffix;
function RegisterClassExA; external user32 name 'RegisterClassExA';
function RegisterClassExW; external user32 name 'RegisterClassExW';
function RegisterClassEx; external user32 name 'RegisterClassEx' + AWSuffix;
function GetClassInfoExA; external user32 name 'GetClassInfoExA';
function GetClassInfoExW; external user32 name 'GetClassInfoExW';
function GetClassInfoEx; external user32 name 'GetClassInfoEx' + AWSuffix;
function CreateWindowExA; external user32 name 'CreateWindowExA';
function CreateWindowExW; external user32 name 'CreateWindowExW';
function CreateWindowEx; external user32 name 'CreateWindowEx' + AWSuffix;
function IsWindow; external user32 name 'IsWindow';
function IsMenu; external user32 name 'IsMenu';
function IsChild; external user32 name 'IsChild';
function DestroyWindow; external user32 name 'DestroyWindow';
function ShowWindow; external user32 name 'ShowWindow';
function AnimateWindow; external user32 name 'AnimateWindow';
function UpdateLayeredWindow; external user32 name 'UpdateLayeredWindow';
function GetLayeredWindowAttributes; external user32 name 'GetLayeredWindowAttributes';
function PrintWindow; external user32 name 'PrintWindow';
function SetLayeredWindowAttributes; external user32 name 'SetLayeredWindowAttributes';
function ShowWindowAsync; external user32 name 'ShowWindowAsync';
function FlashWindow; external user32 name 'FlashWindow';
function FlashWindowEx; external user32 name 'FlashWindowEx';
function ShowOwnedPopups; external user32 name 'ShowOwnedPopups';
function OpenIcon; external user32 name 'OpenIcon';
function CloseWindow; external user32 name 'CloseWindow';
function MoveWindow; external user32 name 'MoveWindow';
function SetWindowPos; external user32 name 'SetWindowPos';
function GetWindowPlacement; external user32 name 'GetWindowPlacement';
function SetWindowPlacement; external user32 name 'SetWindowPlacement';
function BeginDeferWindowPos; external user32 name 'BeginDeferWindowPos';
function DeferWindowPos; external user32 name 'DeferWindowPos';
function EndDeferWindowPos; external user32 name 'EndDeferWindowPos';
function IsWindowVisible; external user32 name 'IsWindowVisible';
function IsIconic; external user32 name 'IsIconic';
function AnyPopup; external user32 name 'AnyPopup';
function BringWindowToTop; external user32 name 'BringWindowToTop';
function IsZoomed; external user32 name 'IsZoomed';
function CreateDialogParamA; external user32 name 'CreateDialogParamA';
function CreateDialogParamW; external user32 name 'CreateDialogParamW';
function CreateDialogParam; external user32 name 'CreateDialogParam' + AWSuffix;
function CreateDialogIndirectParamA; external user32 name 'CreateDialogIndirectParamA';
function CreateDialogIndirectParamW; external user32 name 'CreateDialogIndirectParamW';
function CreateDialogIndirectParam; external user32 name 'CreateDialogIndirectParam' + AWSuffix;
function DialogBoxParamA; external user32 name 'DialogBoxParamA';
function DialogBoxParamW; external user32 name 'DialogBoxParamW';
function DialogBoxParam; external user32 name 'DialogBoxParam' + AWSuffix;
function DialogBoxIndirectParamA; external user32 name 'DialogBoxIndirectParamA';
function DialogBoxIndirectParamW; external user32 name 'DialogBoxIndirectParamW';
function DialogBoxIndirectParam; external user32 name 'DialogBoxIndirectParam' + AWSuffix;
function EndDialog; external user32 name 'EndDialog';
function GetDlgItem; external user32 name 'GetDlgItem';
function SetDlgItemInt; external user32 name 'SetDlgItemInt';
function GetDlgItemInt; external user32 name 'GetDlgItemInt';
function SetDlgItemTextA; external user32 name 'SetDlgItemTextA';
function SetDlgItemTextW; external user32 name 'SetDlgItemTextW';
function SetDlgItemText; external user32 name 'SetDlgItemText' + AWSuffix;
function GetDlgItemTextA; external user32 name 'GetDlgItemTextA';
function GetDlgItemTextW; external user32 name 'GetDlgItemTextW';
function GetDlgItemText; external user32 name 'GetDlgItemText' + AWSuffix;
function CheckDlgButton; external user32 name 'CheckDlgButton';
function CheckRadioButton; external user32 name 'CheckRadioButton';
function IsDlgButtonChecked; external user32 name 'IsDlgButtonChecked';
function SendDlgItemMessageA; external user32 name 'SendDlgItemMessageA';
function SendDlgItemMessageW; external user32 name 'SendDlgItemMessageW';
function SendDlgItemMessage; external user32 name 'SendDlgItemMessage' + AWSuffix;
function GetNextDlgGroupItem; external user32 name 'GetNextDlgGroupItem';
function GetNextDlgTabItem; external user32 name 'GetNextDlgTabItem';
function GetDlgCtrlID; external user32 name 'GetDlgCtrlID';
function GetDialogBaseUnits; external user32 name 'GetDialogBaseUnits';
function DefDlgProcA; external user32 name 'DefDlgProcA';
function DefDlgProcW; external user32 name 'DefDlgProcW';
function DefDlgProc; external user32 name 'DefDlgProc' + AWSuffix;
function CallMsgFilterA; external user32 name 'CallMsgFilterA';
function CallMsgFilterW; external user32 name 'CallMsgFilterW';
function CallMsgFilter; external user32 name 'CallMsgFilter' + AWSuffix;
function OpenClipboard; external user32 name 'OpenClipboard';
function CloseClipboard; external user32 name 'CloseClipboard';
function GetClipboardSequenceNumber; external user32 name 'GetClipboardSequenceNumber';
function GetClipboardOwner; external user32 name 'GetClipboardOwner';
function SetClipboardViewer; external user32 name 'SetClipboardViewer';
function GetClipboardViewer; external user32 name 'GetClipboardViewer';
function ChangeClipboardChain; external user32 name 'ChangeClipboardChain';
function SetClipboardData; external user32 name 'SetClipboardData';
function GetClipboardData; external user32 name 'GetClipboardData';
function RegisterClipboardFormatA; external user32 name 'RegisterClipboardFormatA';
function RegisterClipboardFormatW; external user32 name 'RegisterClipboardFormatW';
function RegisterClipboardFormat; external user32 name 'RegisterClipboardFormat' + AWSuffix;
function CountClipboardFormats; external user32 name 'CountClipboardFormats';
function EnumClipboardFormats; external user32 name 'EnumClipboardFormats';
function GetClipboardFormatNameA; external user32 name 'GetClipboardFormatNameA';
function GetClipboardFormatNameW; external user32 name 'GetClipboardFormatNameW';
function GetClipboardFormatName; external user32 name 'GetClipboardFormatName' + AWSuffix;
function EmptyClipboard; external user32 name 'EmptyClipboard';
function IsClipboardFormatAvailable; external user32 name 'IsClipboardFormatAvailable';
function GetPriorityClipboardFormat; external user32 name 'GetPriorityClipboardFormat';
function GetOpenClipboardWindow; external user32 name 'GetOpenClipboardWindow';
function CharToOemA; external user32 name 'CharToOemA';
function CharToOemW; external user32 name 'CharToOemW';
function CharToOem; external user32 name 'CharToOem' + AWSuffix;
function OemToCharA; external user32 name 'OemToCharA';
function OemToCharW; external user32 name 'OemToCharW';
function OemToChar; external user32 name 'OemToChar' + AWSuffix;
function CharToOemBuffA; external user32 name 'CharToOemBuffA';
function CharToOemBuffW; external user32 name 'CharToOemBuffW';
function CharToOemBuff; external user32 name 'CharToOemBuff' + AWSuffix;
function OemToCharBuffA; external user32 name 'OemToCharBuffA';
function OemToCharBuffW; external user32 name 'OemToCharBuffW';
function OemToCharBuff; external user32 name 'OemToCharBuff' + AWSuffix;
function CharUpperA; external user32 name 'CharUpperA';
function CharUpperW; external user32 name 'CharUpperW';
function CharUpper; external user32 name 'CharUpper' + AWSuffix;
function CharUpperBuffA; external user32 name 'CharUpperBuffA';
function CharUpperBuffW; external user32 name 'CharUpperBuffW';
function CharUpperBuff; external user32 name 'CharUpperBuff' + AWSuffix;
function CharLowerA; external user32 name 'CharLowerA';
function CharLowerW; external user32 name 'CharLowerW';
function CharLower; external user32 name 'CharLower' + AWSuffix;
function CharLowerBuffA; external user32 name 'CharLowerBuffA';
function CharLowerBuffW; external user32 name 'CharLowerBuffW';
function CharLowerBuff; external user32 name 'CharLowerBuff' + AWSuffix;
function CharNextA; external user32 name 'CharNextA';
function CharNextW; external user32 name 'CharNextW';
function CharNext; external user32 name 'CharNext' + AWSuffix;
function CharPrevA; external user32 name 'CharPrevA';
function CharPrevW; external user32 name 'CharPrevW';
function CharPrev; external user32 name 'CharPrev' + AWSuffix;
function CharNextExA; external user32 name 'CharNextExA';
function CharPrevExA; external user32 name 'CharPrevExA';
function IsCharAlphaA; external user32 name 'IsCharAlphaA';
function IsCharAlphaW; external user32 name 'IsCharAlphaW';
function IsCharAlpha; external user32 name 'IsCharAlpha' + AWSuffix;
function IsCharAlphaNumericA; external user32 name 'IsCharAlphaNumericA';
function IsCharAlphaNumericW; external user32 name 'IsCharAlphaNumericW';
function IsCharAlphaNumeric; external user32 name 'IsCharAlphaNumeric' + AWSuffix;
function IsCharUpperA; external user32 name 'IsCharUpperA';
function IsCharUpperW; external user32 name 'IsCharUpperW';
function IsCharUpper; external user32 name 'IsCharUpper' + AWSuffix;
function IsCharLowerA; external user32 name 'IsCharLowerA';
function IsCharLowerW; external user32 name 'IsCharLowerW';
function IsCharLower; external user32 name 'IsCharLower' + AWSuffix;
function SetFocus; external user32 name 'SetFocus';
function GetActiveWindow; external user32 name 'GetActiveWindow';
function GetFocus; external user32 name 'GetFocus';
function GetKBCodePage; external user32 name 'GetKBCodePage';
function GetKeyState; external user32 name 'GetKeyState';
function GetAsyncKeyState; external user32 name 'GetAsyncKeyState';
function GetKeyboardState; external user32 name 'GetKeyboardState';
function SetKeyboardState; external user32 name 'SetKeyboardState';
function GetKeyNameTextA; external user32 name 'GetKeyNameTextA';
function GetKeyNameTextW; external user32 name 'GetKeyNameTextW';
function GetKeyNameText; external user32 name 'GetKeyNameText' + AWSuffix;
function GetKeyboardType; external user32 name 'GetKeyboardType';
function ToAscii; external user32 name 'ToAscii';
function ToAsciiEx; external user32 name 'ToAsciiEx';
function ToUnicode; external user32 name 'ToUnicode';
function OemKeyScan; external user32 name 'OemKeyScan';
function VkKeyScanA; external user32 name 'VkKeyScanA';
function VkKeyScanW; external user32 name 'VkKeyScanW';
function VkKeyScan; external user32 name 'VkKeyScan' + AWSuffix;
function VkKeyScanExA; external user32 name 'VkKeyScanExA';
function VkKeyScanExW; external user32 name 'VkKeyScanExW';
function VkKeyScanEx; external user32 name 'VkKeyScanEx' + AWSuffix;
procedure keybd_event; external user32 name 'keybd_event';
procedure mouse_event; external user32 name 'mouse_event';
function SendInput; external user32 name 'SendInput';
function GetLastInputInfo; external user32 name 'GetLastInputInfo';
function MapVirtualKeyA; external user32 name 'MapVirtualKeyA';
function MapVirtualKeyW; external user32 name 'MapVirtualKeyW';
function MapVirtualKey; external user32 name 'MapVirtualKey' + AWSuffix;
function MapVirtualKeyExA; external user32 name 'MapVirtualKeyExA';
function MapVirtualKeyExW; external user32 name 'MapVirtualKeyExW';
function MapVirtualKeyEx; external user32 name 'MapVirtualKeyEx' + AWSuffix;
function GetInputState; external user32 name 'GetInputState';
function GetQueueStatus; external user32 name 'GetQueueStatus';
function GetCapture; external user32 name 'GetCapture';
function SetCapture; external user32 name 'SetCapture';
function ReleaseCapture; external user32 name 'ReleaseCapture';
function MsgWaitForMultipleObjects; external user32 name 'MsgWaitForMultipleObjects';
function MsgWaitForMultipleObjectsEx; external user32 name 'MsgWaitForMultipleObjectsEx';
function SetTimer; external user32 name 'SetTimer';
function KillTimer; external user32 name 'KillTimer';
function IsWindowUnicode; external user32 name 'IsWindowUnicode';
function EnableWindow; external user32 name 'EnableWindow';
function IsWindowEnabled; external user32 name 'IsWindowEnabled';
function LoadAcceleratorsA; external user32 name 'LoadAcceleratorsA';
function LoadAcceleratorsW; external user32 name 'LoadAcceleratorsW';
function LoadAccelerators; external user32 name 'LoadAccelerators' + AWSuffix;
function CreateAcceleratorTableA; external user32 name 'CreateAcceleratorTableA';
function CreateAcceleratorTableW; external user32 name 'CreateAcceleratorTableW';
function CreateAcceleratorTable; external user32 name 'CreateAcceleratorTable' + AWSuffix;
function DestroyAcceleratorTable; external user32 name 'DestroyAcceleratorTable';
function CopyAcceleratorTableA; external user32 name 'CopyAcceleratorTableA';
function CopyAcceleratorTableW; external user32 name 'CopyAcceleratorTableW';
function CopyAcceleratorTable; external user32 name 'CopyAcceleratorTable' + AWSuffix;
function TranslateAcceleratorA; external user32 name 'TranslateAcceleratorA';
function TranslateAcceleratorW; external user32 name 'TranslateAcceleratorW';
function TranslateAccelerator; external user32 name 'TranslateAccelerator' + AWSuffix;
function GetSystemMetrics; external user32 name 'GetSystemMetrics';
function LoadMenuA; external user32 name 'LoadMenuA';
function LoadMenuW; external user32 name 'LoadMenuW';
function LoadMenu; external user32 name 'LoadMenu' + AWSuffix;
function LoadMenuIndirectA; external user32 name 'LoadMenuIndirectA';
function LoadMenuIndirectW; external user32 name 'LoadMenuIndirectW';
function LoadMenuIndirect; external user32 name 'LoadMenuIndirect' + AWSuffix;
function GetMenu; external user32 name 'GetMenu';
function SetMenu; external user32 name 'SetMenu';
function ChangeMenuA; external user32 name 'ChangeMenuA';
function ChangeMenuW; external user32 name 'ChangeMenuW';
function ChangeMenu; external user32 name 'ChangeMenu' + AWSuffix;
function HiliteMenuItem; external user32 name 'HiliteMenuItem';
function GetMenuStringA; external user32 name 'GetMenuStringA';
function GetMenuStringW; external user32 name 'GetMenuStringW';
function GetMenuString; external user32 name 'GetMenuString' + AWSuffix;
function GetMenuState; external user32 name 'GetMenuState';
function DrawMenuBar; external user32 name 'DrawMenuBar';
function GetSystemMenu; external user32 name 'GetSystemMenu';
function CreateMenu; external user32 name 'CreateMenu';
function CreatePopupMenu; external user32 name 'CreatePopupMenu';
function DestroyMenu; external user32 name 'DestroyMenu';
function CheckMenuItem; external user32 name 'CheckMenuItem';
function EnableMenuItem; external user32 name 'EnableMenuItem';
function GetSubMenu; external user32 name 'GetSubMenu';
function GetMenuItemID; external user32 name 'GetMenuItemID';
function GetMenuItemCount; external user32 name 'GetMenuItemCount';
function InsertMenuA; external user32 name 'InsertMenuA';
function InsertMenuW; external user32 name 'InsertMenuW';
function InsertMenu; external user32 name 'InsertMenu' + AWSuffix;
function AppendMenuA; external user32 name 'AppendMenuA';
function AppendMenuW; external user32 name 'AppendMenuW';
function AppendMenu; external user32 name 'AppendMenu' + AWSuffix;
function ModifyMenuA; external user32 name 'ModifyMenuA';
function ModifyMenuW; external user32 name 'ModifyMenuW';
function ModifyMenu; external user32 name 'ModifyMenu' + AWSuffix;
function RemoveMenu; external user32 name 'RemoveMenu';
function DeleteMenu; external user32 name 'DeleteMenu';
function SetMenuItemBitmaps; external user32 name 'SetMenuItemBitmaps';
function GetMenuCheckMarkDimensions; external user32 name 'GetMenuCheckMarkDimensions';
function TrackPopupMenu; external user32 name 'TrackPopupMenu';
function TrackPopupMenuEx; external user32 name 'TrackPopupMenuEx';
function GetMenuInfo; external user32 name 'GetMenuInfo';
function SetMenuInfo; external user32 name 'SetMenuInfo';
function EndMenu; external user32 name 'EndMenu';
function InsertMenuItemA; external user32 name 'InsertMenuItemA';
function InsertMenuItemW; external user32 name 'InsertMenuItemW';
function InsertMenuItem; external user32 name 'InsertMenuItem' + AWSuffix;
function GetMenuItemInfoA; external user32 name 'GetMenuItemInfoA';
function GetMenuItemInfoW; external user32 name 'GetMenuItemInfoW';
function GetMenuItemInfo; external user32 name 'GetMenuItemInfo' + AWSuffix;
function SetMenuItemInfoA; external user32 name 'SetMenuItemInfoA';
function SetMenuItemInfoW; external user32 name 'SetMenuItemInfoW';
function SetMenuItemInfo; external user32 name 'SetMenuItemInfo' + AWSuffix;
function GetMenuDefaultItem; external user32 name 'GetMenuDefaultItem';
function SetMenuDefaultItem; external user32 name 'SetMenuDefaultItem';
function GetMenuItemRect; external user32 name 'GetMenuItemRect';
function MenuItemFromPoint; external user32 name 'MenuItemFromPoint';
function DragObject; external user32 name 'DragObject';
function DragDetect; external user32 name 'DragDetect';
function DrawIcon; external user32 name 'DrawIcon';
function DrawTextA; external user32 name 'DrawTextA';
function DrawTextW; external user32 name 'DrawTextW';
function DrawText; external user32 name 'DrawText' + AWSuffix;
function DrawTextExA; external user32 name 'DrawTextExA';
function DrawTextExW; external user32 name 'DrawTextExW';
function DrawTextEx; external user32 name 'DrawTextEx' + AWSuffix;
function GrayStringA; external user32 name 'GrayStringA';
function GrayStringW; external user32 name 'GrayStringW';
function GrayString; external user32 name 'GrayString' + AWSuffix;
function DrawStateA; external user32 name 'DrawStateA';
function DrawStateW; external user32 name 'DrawStateW';
function DrawState; external user32 name 'DrawState' + AWSuffix;
function TabbedTextOutA; external user32 name 'TabbedTextOutA';
function TabbedTextOutW; external user32 name 'TabbedTextOutW';
function TabbedTextOut; external user32 name 'TabbedTextOut' + AWSuffix;
function GetTabbedTextExtentA; external user32 name 'GetTabbedTextExtentA';
function GetTabbedTextExtentW; external user32 name 'GetTabbedTextExtentW';
function GetTabbedTextExtent; external user32 name 'GetTabbedTextExtent' + AWSuffix;
function UpdateWindow; external user32 name 'UpdateWindow';
function SetActiveWindow; external user32 name 'SetActiveWindow';
function GetForegroundWindow; external user32 name 'GetForegroundWindow';
function PaintDesktop; external user32 name 'PaintDesktop';
procedure SwitchToThisWindow; external user32 name 'SwitchToThisWindow';
function SetForegroundWindow; external user32 name 'SetForegroundWindow';
function AllowSetForegroundWindow; external user32 name 'AllowSetForegroundWindow';
function LockSetForegroundWindow; external user32 name 'LockSetForegroundWindow';
function WindowFromDC; external user32 name 'WindowFromDC';
function GetDC; external user32 name 'GetDC';
function GetDCEx; external user32 name 'GetDCEx';
function GetWindowDC; external user32 name 'GetWindowDC';
function ReleaseDC; external user32 name 'ReleaseDC';
function BeginPaint; external user32 name 'BeginPaint';
function EndPaint; external user32 name 'EndPaint';
function GetUpdateRect; external user32 name 'GetUpdateRect';
function GetUpdateRgn; external user32 name 'GetUpdateRgn';
function SetWindowRgn; external user32 name 'SetWindowRgn';
function GetWindowRgn; external user32 name 'GetWindowRgn';
function GetWindowRgnBox; external user32 name 'GetWindowRgnBox';
function ExcludeUpdateRgn; external user32 name 'ExcludeUpdateRgn';
function InvalidateRect; external user32 name 'InvalidateRect';
function ValidateRect; external user32 name 'ValidateRect';
function InvalidateRgn; external user32 name 'InvalidateRgn';
function ValidateRgn; external user32 name 'ValidateRgn';
function RedrawWindow; external user32 name 'RedrawWindow';
function LockWindowUpdate; external user32 name 'LockWindowUpdate';
function ScrollWindow; external user32 name 'ScrollWindow';
function ScrollDC; external user32 name 'ScrollDC';
function ScrollWindowEx; external user32 name 'ScrollWindowEx';
function SetScrollPos; external user32 name 'SetScrollPos';
function GetScrollPos; external user32 name 'GetScrollPos';
function SetScrollRange; external user32 name 'SetScrollRange';
function GetScrollRange; external user32 name 'GetScrollRange';
function ShowScrollBar; external user32 name 'ShowScrollBar';
function EnableScrollBar; external user32 name 'EnableScrollBar';
function SetPropA; external user32 name 'SetPropA';
function SetPropW; external user32 name 'SetPropW';
function SetProp; external user32 name 'SetProp' + AWSuffix;
function GetPropA; external user32 name 'GetPropA';
function GetPropW; external user32 name 'GetPropW';
function GetProp; external user32 name 'GetProp' + AWSuffix;
function RemovePropA; external user32 name 'RemovePropA';
function RemovePropW; external user32 name 'RemovePropW';
function RemoveProp; external user32 name 'RemoveProp' + AWSuffix;
function EnumPropsExA; external user32 name 'EnumPropsExA';
function EnumPropsExW; external user32 name 'EnumPropsExW';
function EnumPropsEx; external user32 name 'EnumPropsEx' + AWSuffix;
function EnumPropsA; external user32 name 'EnumPropsA';
function EnumPropsW; external user32 name 'EnumPropsW';
function EnumProps; external user32 name 'EnumProps' + AWSuffix;
function SetWindowTextA; external user32 name 'SetWindowTextA';
function SetWindowTextW; external user32 name 'SetWindowTextW';
function SetWindowText; external user32 name 'SetWindowText' + AWSuffix;
function GetWindowTextA; external user32 name 'GetWindowTextA';
function GetWindowTextW; external user32 name 'GetWindowTextW';
function GetWindowText; external user32 name 'GetWindowText' + AWSuffix;
function GetWindowTextLengthA; external user32 name 'GetWindowTextLengthA';
function GetWindowTextLengthW; external user32 name 'GetWindowTextLengthW';
function GetWindowTextLength; external user32 name 'GetWindowTextLength' + AWSuffix;
function GetClientRect; external user32 name 'GetClientRect';
function GetWindowRect; external user32 name 'GetWindowRect';
function AdjustWindowRect; external user32 name 'AdjustWindowRect';
function AdjustWindowRectEx; external user32 name 'AdjustWindowRectEx';
function SetWindowContextHelpId; external user32 name 'SetWindowContextHelpId';
function GetWindowContextHelpId; external user32 name 'GetWindowContextHelpId';
function SetMenuContextHelpId; external user32 name 'SetMenuContextHelpId';
function GetMenuContextHelpId; external user32 name 'GetMenuContextHelpId';
function MessageBoxA; external user32 name 'MessageBoxA';
function MessageBoxW; external user32 name 'MessageBoxW';
function MessageBox; external user32 name 'MessageBox' + AWSuffix;
function MessageBoxExA; external user32 name 'MessageBoxExA';
function MessageBoxExW; external user32 name 'MessageBoxExW';
function MessageBoxEx; external user32 name 'MessageBoxEx' + AWSuffix;
function MessageBoxIndirectA; external user32 name 'MessageBoxIndirectA';
function MessageBoxIndirectW; external user32 name 'MessageBoxIndirectW';
function MessageBoxIndirect; external user32 name 'MessageBoxIndirect' + AWSuffix;
function MessageBeep; external user32 name 'MessageBeep';
function ShowCursor; external user32 name 'ShowCursor';
function SetCursorPos; external user32 name 'SetCursorPos';
function SetCursor; external user32 name 'SetCursor';
function GetCursorPos; external user32 name 'GetCursorPos';
function ClipCursor; external user32 name 'ClipCursor';
function GetClipCursor; external user32 name 'GetClipCursor';
function GetCursor; external user32 name 'GetCursor';
function CreateCaret; external user32 name 'CreateCaret';
function GetCaretBlinkTime; external user32 name 'GetCaretBlinkTime';
function SetCaretBlinkTime; external user32 name 'SetCaretBlinkTime';
function DestroyCaret; external user32 name 'DestroyCaret';
function HideCaret; external user32 name 'HideCaret';
function ShowCaret; external user32 name 'ShowCaret';
function SetCaretPos; external user32 name 'SetCaretPos';
function GetCaretPos; external user32 name 'GetCaretPos';
function ClientToScreen; external user32 name 'ClientToScreen';
function ScreenToClient; external user32 name 'ScreenToClient';
function MapWindowPoints; external user32 name 'MapWindowPoints';
function WindowFromPoint; external user32 name 'WindowFromPoint';
function ChildWindowFromPoint; external user32 name 'ChildWindowFromPoint';
function ChildWindowFromPointEx; external user32 name 'ChildWindowFromPointEx';
function GetSysColor; external user32 name 'GetSysColor';
function GetSysColorBrush; external user32 name 'GetSysColorBrush';
function SetSysColors; external user32 name 'SetSysColors';
function DrawFocusRect; external user32 name 'DrawFocusRect';
function FillRect; external user32 name 'FillRect';
function FrameRect; external user32 name 'FrameRect';
function InvertRect; external user32 name 'InvertRect';
function SetRect; external user32 name 'SetRect';
function SetRectEmpty; external user32 name 'SetRectEmpty';
function CopyRect; external user32 name 'CopyRect';
function InflateRect; external user32 name 'InflateRect';
function IntersectRect; external user32 name 'IntersectRect';
function UnionRect; external user32 name 'UnionRect';
function SubtractRect; external user32 name 'SubtractRect';
function OffsetRect; external user32 name 'OffsetRect';
function IsRectEmpty; external user32 name 'IsRectEmpty';
function EqualRect; external user32 name 'EqualRect';
function PtInRect; external user32 name 'PtInRect';
function GetWindowWord; external user32 name 'GetWindowWord';
function SetWindowWord; external user32 name 'SetWindowWord';
function GetWindowLongA; external user32 name 'GetWindowLongA';
function GetWindowLongW; external user32 name 'GetWindowLongW';
function GetWindowLong; external user32 name 'GetWindowLong' + AWSuffix;
function SetWindowLongA; external user32 name 'SetWindowLongA';
function SetWindowLongW; external user32 name 'SetWindowLongW';
function SetWindowLong; external user32 name 'SetWindowLong' + AWSuffix;
function GetClassWord; external user32 name 'GetClassWord';
function SetClassWord; external user32 name 'SetClassWord';
function GetClassLongA; external user32 name 'GetClassLongA';
function GetClassLongW; external user32 name 'GetClassLongW';
function GetClassLong; external user32 name 'GetClassLong' + AWSuffix;
function SetClassLongA; external user32 name 'SetClassLongA';
function SetClassLongW; external user32 name 'SetClassLongW';
function SetClassLong; external user32 name 'SetClassLong' + AWSuffix;
function GetProcessDefaultLayout; external user32 name 'GetProcessDefaultLayout';
function SetProcessDefaultLayout; external user32 name 'SetProcessDefaultLayout';
function GetDesktopWindow; external user32 name 'GetDesktopWindow';
function GetParent; external user32 name 'GetParent';
function SetParent; external user32 name 'SetParent';
function EnumChildWindows; external user32 name 'EnumChildWindows';
function FindWindowA; external user32 name 'FindWindowA';
function FindWindowW; external user32 name 'FindWindowW';
function FindWindow; external user32 name 'FindWindow' + AWSuffix;
function FindWindowExA; external user32 name 'FindWindowExA';
function FindWindowExW; external user32 name 'FindWindowExW';
function FindWindowEx; external user32 name 'FindWindowEx' + AWSuffix;
function GetShellWindow; external user32 name 'GetShellWindow';
function EnumWindows; external user32 name 'EnumWindows';
function EnumThreadWindows; external user32 name 'EnumThreadWindows';
function GetClassNameA; external user32 name 'GetClassNameA';
function GetClassNameW; external user32 name 'GetClassNameW';
function GetClassName; external user32 name 'GetClassName' + AWSuffix;
function GetTopWindow; external user32 name 'GetTopWindow';
function GetWindowThreadProcessId; external user32 name 'GetWindowThreadProcessId';
function IsGUIThread; external user32 name 'IsGUIThread';
function GetLastActivePopup; external user32 name 'GetLastActivePopup';
function GetWindow; external user32 name 'GetWindow';
function SetWindowsHookA; external user32 name 'SetWindowsHookA';
function SetWindowsHookW; external user32 name 'SetWindowsHookW';
function SetWindowsHook; external user32 name 'SetWindowsHook' + AWSuffix;
function UnhookWindowsHook; external user32 name 'UnhookWindowsHook';
function SetWindowsHookExA; external user32 name 'SetWindowsHookExA';
function SetWindowsHookExW; external user32 name 'SetWindowsHookExW';
function SetWindowsHookEx; external user32 name 'SetWindowsHookEx' + AWSuffix;
function UnhookWindowsHookEx; external user32 name 'UnhookWindowsHookEx';
function CallNextHookEx; external user32 name 'CallNextHookEx';
function CheckMenuRadioItem; external user32 name 'CheckMenuRadioItem';
function LoadBitmapA; external user32 name 'LoadBitmapA';
function LoadBitmapW; external user32 name 'LoadBitmapW';
function LoadBitmap; external user32 name 'LoadBitmap' + AWSuffix;
function LoadCursorA; external user32 name 'LoadCursorA';
function LoadCursorW; external user32 name 'LoadCursorW';
function LoadCursor; external user32 name 'LoadCursor' + AWSuffix;
function LoadCursorFromFileA; external user32 name 'LoadCursorFromFileA';
function LoadCursorFromFileW; external user32 name 'LoadCursorFromFileW';
function LoadCursorFromFile; external user32 name 'LoadCursorFromFile' + AWSuffix;
function CreateCursor; external user32 name 'CreateCursor';
function DestroyCursor; external user32 name 'DestroyCursor';
function SetSystemCursor; external user32 name 'SetSystemCursor';
function LoadIconA; external user32 name 'LoadIconA';
function LoadIconW; external user32 name 'LoadIconW';
function LoadIcon; external user32 name 'LoadIcon' + AWSuffix;
function PrivateExtractIconsA; external user32 name 'PrivateExtractIconsA';
function PrivateExtractIconsW; external user32 name 'PrivateExtractIconsW';
function PrivateExtractIcons; external user32 name 'PrivateExtractIcons' + AWSuffix;
function CreateIcon; external user32 name 'CreateIcon';
function DestroyIcon; external user32 name 'DestroyIcon';
function LookupIconIdFromDirectory; external user32 name 'LookupIconIdFromDirectory';
function LookupIconIdFromDirectoryEx; external user32 name 'LookupIconIdFromDirectoryEx';
function CreateIconFromResource; external user32 name 'CreateIconFromResource';
function CreateIconFromResourceEx; external user32 name 'CreateIconFromResourceEx';
function LoadImageA; external user32 name 'LoadImageA';
function LoadImageW; external user32 name 'LoadImageW';
function LoadImage; external user32 name 'LoadImage' + AWSuffix;
function CopyImage; external user32 name 'CopyImage';
function DrawIconEx; external user32 name 'DrawIconEx';
function CreateIconIndirect; external user32 name 'CreateIconIndirect';
function CopyIcon; external user32 name 'CopyIcon';
function GetIconInfo; external user32 name 'GetIconInfo';
function LoadStringA; external user32 name 'LoadStringA';
function LoadStringW; external user32 name 'LoadStringW';
function LoadString; external user32 name 'LoadString' + AWSuffix;
function IsDialogMessageA; external user32 name 'IsDialogMessageA';
function IsDialogMessageW; external user32 name 'IsDialogMessageW';
function IsDialogMessage; external user32 name 'IsDialogMessage' + AWSuffix;
function MapDialogRect; external user32 name 'MapDialogRect';
function DlgDirListA; external user32 name 'DlgDirListA';
function DlgDirListW; external user32 name 'DlgDirListW';
function DlgDirList; external user32 name 'DlgDirList' + AWSuffix;
function DlgDirSelectExA; external user32 name 'DlgDirSelectExA';
function DlgDirSelectExW; external user32 name 'DlgDirSelectExW';
function DlgDirSelectEx; external user32 name 'DlgDirSelectEx' + AWSuffix;
function DlgDirListComboBoxA; external user32 name 'DlgDirListComboBoxA';
function DlgDirListComboBoxW; external user32 name 'DlgDirListComboBoxW';
function DlgDirListComboBox; external user32 name 'DlgDirListComboBox' + AWSuffix;
function DlgDirSelectComboBoxExA; external user32 name 'DlgDirSelectComboBoxExA';
function DlgDirSelectComboBoxExW; external user32 name 'DlgDirSelectComboBoxExW';
function DlgDirSelectComboBoxEx; external user32 name 'DlgDirSelectComboBoxEx' + AWSuffix;
function SetScrollInfo; external user32 name 'SetScrollInfo';
function GetScrollInfo; external user32 name 'GetScrollInfo';
function DefFrameProcA; external user32 name 'DefFrameProcA';
function DefFrameProcW; external user32 name 'DefFrameProcW';
function DefFrameProc; external user32 name 'DefFrameProc' + AWSuffix;
function DefMDIChildProcA; external user32 name 'DefMDIChildProcA';
function DefMDIChildProcW; external user32 name 'DefMDIChildProcW';
function DefMDIChildProc; external user32 name 'DefMDIChildProc' + AWSuffix;
function TranslateMDISysAccel; external user32 name 'TranslateMDISysAccel';
function ArrangeIconicWindows; external user32 name 'ArrangeIconicWindows';
function CreateMDIWindowA; external user32 name 'CreateMDIWindowA';
function CreateMDIWindowW; external user32 name 'CreateMDIWindowW';
function CreateMDIWindow; external user32 name 'CreateMDIWindow' + AWSuffix;
function TileWindows; external user32 name 'TileWindows';
function CascadeWindows; external user32 name 'CascadeWindows';
function WinHelpA; external user32 name 'WinHelpA';
function WinHelpW; external user32 name 'WinHelpW';
function WinHelp; external user32 name 'WinHelp' + AWSuffix;
function GetGuiResources; external user32 name 'GetGuiResources';
function ChangeDisplaySettingsA; external user32 name 'ChangeDisplaySettingsA';
function ChangeDisplaySettingsW; external user32 name 'ChangeDisplaySettingsW';
function ChangeDisplaySettings; external user32 name 'ChangeDisplaySettings' + AWSuffix;
function ChangeDisplaySettingsExA; external user32 name 'ChangeDisplaySettingsExA';
function ChangeDisplaySettingsExW; external user32 name 'ChangeDisplaySettingsExW';
function ChangeDisplaySettingsEx; external user32 name 'ChangeDisplaySettingsEx' + AWSuffix;
function EnumDisplaySettingsA; external user32 name 'EnumDisplaySettingsA';
function EnumDisplaySettingsW; external user32 name 'EnumDisplaySettingsW';
function EnumDisplaySettings; external user32 name 'EnumDisplaySettings' + AWSuffix;
function EnumDisplaySettingsExA; external user32 name 'EnumDisplaySettingsExA';
function EnumDisplaySettingsExW; external user32 name 'EnumDisplaySettingsExW';
function EnumDisplaySettingsEx; external user32 name 'EnumDisplaySettingsEx' + AWSuffix;
function EnumDisplayDevicesA; external user32 name 'EnumDisplayDevicesA';
function EnumDisplayDevicesW; external user32 name 'EnumDisplayDevicesW';
function EnumDisplayDevices; external user32 name 'EnumDisplayDevices' + AWSuffix;
function SystemParametersInfoA; external user32 name 'SystemParametersInfoA';
function SystemParametersInfoW; external user32 name 'SystemParametersInfoW';
function SystemParametersInfo; external user32 name 'SystemParametersInfo' + AWSuffix;
procedure SetDebugErrorLevel; external user32 name 'SetDebugErrorLevel';
procedure SetLastErrorEx; external user32 name 'SetLastErrorEx';
function InternalGetWindowText; external user32 name 'InternalGetWindowText';
function EndTask; external user32 name 'EndTask';
function MonitorFromPoint; external user32 name 'MonitorFromPoint';
function MonitorFromRect; external user32 name 'MonitorFromRect';
function MonitorFromWindow; external user32 name 'MonitorFromWindow';
function GetMonitorInfoA; external user32 name 'GetMonitorInfoA';
function GetMonitorInfoW; external user32 name 'GetMonitorInfoW';
function GetMonitorInfo; external user32 name 'GetMonitorInfo' + AWSuffix;
function EnumDisplayMonitors; external user32 name 'EnumDisplayMonitors';
procedure NotifyWinEvent; external user32 name 'NotifyWinEvent';
function SetWinEventHook; external user32 name 'SetWinEventHook';
function IsWinEventHookInstalled; external user32 name 'IsWinEventHookInstalled';
function UnhookWinEvent; external user32 name 'UnhookWinEvent';
function GetGUIThreadInfo; external user32 name 'GetGUIThreadInfo';
function GetWindowModuleFileNameA; external user32 name 'GetWindowModuleFileNameA';
function GetWindowModuleFileNameW; external user32 name 'GetWindowModuleFileNameW';
function GetWindowModuleFileName; external user32 name 'GetWindowModuleFileName' + AWSuffix;
function GetCursorInfo; external user32 name 'GetCursorInfo';
function GetWindowInfo; external user32 name 'GetWindowInfo';
function GetTitleBarInfo; external user32 name 'GetTitleBarInfo';
function GetMenuBarInfo; external user32 name 'GetMenuBarInfo';
function GetScrollBarInfo; external user32 name 'GetScrollBarInfo';
function GetComboBoxInfo; external user32 name 'GetComboBoxInfo';
function GetAncestor; external user32 name 'GetAncestor';
function RealChildWindowFromPoint; external user32 name 'RealChildWindowFromPoint';
function RealGetWindowClassA; external user32 name 'RealGetWindowClassA';
function RealGetWindowClassW; external user32 name 'RealGetWindowClassW';
function RealGetWindowClass; external user32 name 'RealGetWindowClass' + AWSuffix;
function GetAltTabInfoA; external user32 name 'GetAltTabInfoA';
function GetAltTabInfoW; external user32 name 'GetAltTabInfoW';
function GetAltTabInfo; external user32 name 'GetAltTabInfo' + AWSuffix;
function GetListBoxInfo; external user32 name 'GetListBoxInfo';
function LockWorkStation; external user32 name 'LockWorkStation';
function UserHandleGrantAccess; external user32 name 'UserHandleGrantAccess';

function GET_RAWINPUT_CODE_WPARAM(wParam: WPARAM): DWORD;
begin
  Result := wParam and $ff;
end;

function RAWINPUT_ALIGN(x: Pointer): Pointer;
begin
  Result := Pointer((Integer(x) + SizeOf(DWORD) - 1) and not (SizeOf(DWORD) - 1));
end;

function NEXTRAWINPUTBLOCK(ptr: PRawInput): PRawInput;
begin
  Result := PRAWINPUT(DWORD(RAWINPUT_ALIGN(ptr)) + ptr^.header.dwSize);
end;

function GetRawInputData; external user32 name 'GetRawInputData';
function GetRawInputDeviceInfoA; external user32 name 'GetRawInputDeviceInfoA';
function GetRawInputDeviceInfoW; external user32 name 'GetRawInputDeviceInfoW';
function GetRawInputDeviceInfo; external user32 name 'GetRawInputDeviceInfo' + AWSuffix;
function GetRawInputBuffer; external user32 name 'GetRawInputBuffer';

function RIDEV_EXMODE(mode: DWORD): DWORD;
begin
  Result := mode and RIDEV_EXMODEMASK;
end;

function RegisterRawInputDevices; external user32 name 'RegisterRawInputDevices';
function GetRegisteredRawInputDevices; external user32 name 'GetRegisteredRawInputDevices';
function GetRawInputDeviceList; external user32 name 'GetRawInputDeviceList';
function DefRawInputProc; external user32 name 'DefRawInputProc';

end.