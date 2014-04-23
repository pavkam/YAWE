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
unit API.Win.GDI;

interface

{$WEAKPACKAGEUNIT}

uses
  API.Win.NtCommon,
  API.Win.Types;

// Binary raster ops

const
  R2_BLACK       = 1; // 0
  R2_NOTMERGEPEN = 2; // DPon
  R2_MASKNOTPEN  = 3; // DPna
  R2_NOTCOPYPEN  = 4; // PN
  R2_MASKPENNOT  = 5; // PDna
  R2_NOT         = 6; // Dn
  R2_XORPEN      = 7; // DPx
  R2_NOTMASKPEN  = 8; // DPan
  R2_MASKPEN     = 9; // DPa
  R2_NOTXORPEN   = 10; // DPxn
  R2_NOP         = 11; // D
  R2_MERGENOTPEN = 12; // DPno
  R2_COPYPEN     = 13; // P
  R2_MERGEPENNOT = 14; // PDno
  R2_MERGEPEN    = 15; // DPo
  R2_WHITE       = 16; // 1
  R2_LAST        = 16;

// Ternary raster operations

  SRCCOPY     = DWORD($00CC0020); // dest = source
  SRCPAINT    = DWORD($00EE0086); // dest = source OR dest
  SRCAND      = DWORD($008800C6); // dest = source AND dest
  SRCINVERT   = DWORD($00660046); // dest = source XOR dest
  SRCERASE    = DWORD($00440328); // dest = source AND (NOT dest )
  NOTSRCCOPY  = DWORD($00330008); // dest = (NOT source)
  NOTSRCERASE = DWORD($001100A6); // dest = (NOT src) AND (NOT dest)
  MERGECOPY   = DWORD($00C000CA); // dest = (source AND pattern)
  MERGEPAINT  = DWORD($00BB0226); // dest = (NOT source) OR dest
  PATCOPY     = DWORD($00F00021); // dest = pattern
  PATPAINT    = DWORD($00FB0A09); // dest = DPSnoo
  PATINVERT   = DWORD($005A0049); // dest = pattern XOR dest
  DSTINVERT   = DWORD($00550009); // dest = (NOT dest)
  BLACKNESS   = DWORD($00000042); // dest = BLACK
  WHITENESS   = DWORD($00FF0062); // dest = WHITE

  NOMIRRORBITMAP = DWORD($80000000); // Do not Mirror the bitmap in this call
  CAPTUREBLT     = DWORD($40000000); // Include layered windows

// Quaternary raster codes

function MAKEROP4(Fore, Back: DWORD): DWORD;

const
  GDI_ERROR = DWORD($FFFFFFFF);
  HGDI_ERROR = HANDLE($FFFFFFFF);

// Region Flags

  ERROR         = 0;
  NULLREGION    = 1;
  SIMPLEREGION  = 2;
  COMPLEXREGION = 3;
  RGN_ERROR     = ERROR;

// CombineRgn() Styles

  RGN_AND  = 1;
  RGN_OR   = 2;
  RGN_XOR  = 3;
  RGN_DIFF = 4;
  RGN_COPY = 5;
  RGN_MIN  = RGN_AND;
  RGN_MAX  = RGN_COPY;

// StretchBlt() Modes

  BLACKONWHITE      = 1;
  WHITEONBLACK      = 2;
  COLORONCOLOR      = 3;
  HALFTONE          = 4;
  MAXSTRETCHBLTMODE = 4;

// New StretchBlt() Modes

  STRETCH_ANDSCANS    = BLACKONWHITE;
  STRETCH_ORSCANS     = WHITEONBLACK;
  STRETCH_DELETESCANS = COLORONCOLOR;
  STRETCH_HALFTONE    = HALFTONE;

// PolyFill() Modes

  ALTERNATE     = 1;
  WINDING       = 2;
  POLYFILL_LAST = 2;

// Layout Orientation Options

  LAYOUT_RTL                        = $00000001; // Right to left
  LAYOUT_BTT                        = $00000002; // Bottom to top
  LAYOUT_VBH                        = $00000004; // Vertical before horizontal
  LAYOUT_ORIENTATIONMASK            = LAYOUT_RTL or LAYOUT_BTT or LAYOUT_VBH;
  LAYOUT_BITMAPORIENTATIONPRESERVED = $00000008;

// Text Alignment Options

  TA_NOUPDATECP = 0;
  TA_UPDATECP   = 1;

  TA_LEFT   = 0;
  TA_RIGHT  = 2;
  TA_CENTER = 6;

  TA_TOP      = 0;
  TA_BOTTOM   = 8;
  TA_BASELINE = 24;

  TA_RTLREADING = 256;

  TA_MASK       = TA_BASELINE + TA_CENTER + TA_UPDATECP + TA_RTLREADING;

  VTA_BASELINE = TA_BASELINE;
  VTA_LEFT     = TA_BOTTOM;
  VTA_RIGHT    = TA_TOP;
  VTA_CENTER   = TA_CENTER;
  VTA_BOTTOM   = TA_RIGHT;
  VTA_TOP      = TA_LEFT;

  ETO_OPAQUE  = $0002;
  ETO_CLIPPED = $0004;

  ETO_GLYPH_INDEX    = $0010;
  ETO_RTLREADING     = $0080;
  ETO_NUMERICSLOCAL  = $0400;
  ETO_NUMERICSLATIN  = $0800;
  ETO_IGNORELANGUAGE = $1000;

  ETO_PDY = $2000;

  ASPECT_FILTERING = $0001;

// Bounds Accumulation APIs

  DCB_RESET      = $0001;
  DCB_ACCUMULATE = $0002;
  DCB_DIRTY      = DCB_ACCUMULATE;
  DCB_SET        = DCB_RESET or DCB_ACCUMULATE;
  DCB_ENABLE     = $0004;
  DCB_DISABLE    = $0008;

// Metafile Functions

  META_SETBKCOLOR            = $0201;
  META_SETBKMODE             = $0102;
  META_SETMAPMODE            = $0103;
  META_SETROP2               = $0104;
  META_SETRELABS             = $0105;
  META_SETPOLYFILLMODE       = $0106;
  META_SETSTRETCHBLTMODE     = $0107;
  META_SETTEXTCHAREXTRA      = $0108;
  META_SETTEXTCOLOR          = $0209;
  META_SETTEXTJUSTIFICATION  = $020A;
  META_SETWINDOWORG          = $020B;
  META_SETWINDOWEXT          = $020C;
  META_SETVIEWPORTORG        = $020D;
  META_SETVIEWPORTEXT        = $020E;
  META_OFFSETWINDOWORG       = $020F;
  META_SCALEWINDOWEXT        = $0410;
  META_OFFSETVIEWPORTORG     = $0211;
  META_SCALEVIEWPORTEXT      = $0412;
  META_LINETO                = $0213;
  META_MOVETO                = $0214;
  META_EXCLUDECLIPRECT       = $0415;
  META_INTERSECTCLIPRECT     = $0416;
  META_ARC                   = $0817;
  META_ELLIPSE               = $0418;
  META_FLOODFILL             = $0419;
  META_PIE                   = $081A;
  META_RECTANGLE             = $041B;
  META_ROUNDRECT             = $061C;
  META_PATBLT                = $061D;
  META_SAVEDC                = $001E;
  META_SETPIXEL              = $041F;
  META_OFFSETCLIPRGN         = $0220;
  META_TEXTOUT               = $0521;
  META_BITBLT                = $0922;
  META_STRETCHBLT            = $0B23;
  META_POLYGON               = $0324;
  META_POLYLINE              = $0325;
  META_ESCAPE                = $0626;
  META_RESTOREDC             = $0127;
  META_FILLREGION            = $0228;
  META_FRAMEREGION           = $0429;
  META_INVERTREGION          = $012A;
  META_PAINTREGION           = $012B;
  META_SELECTCLIPREGION      = $012C;
  META_SELECTOBJECT          = $012D;
  META_SETTEXTALIGN          = $012E;
  META_CHORD                 = $0830;
  META_SETMAPPERFLAGS        = $0231;
  META_EXTTEXTOUT            = $0a32;
  META_SETDIBTODEV           = $0d33;
  META_SELECTPALETTE         = $0234;
  META_REALIZEPALETTE        = $0035;
  META_ANIMATEPALETTE        = $0436;
  META_SETPALENTRIES         = $0037;
  META_POLYPOLYGON           = $0538;
  META_RESIZEPALETTE         = $0139;
  META_DIBBITBLT             = $0940;
  META_DIBSTRETCHBLT         = $0b41;
  META_DIBCREATEPATTERNBRUSH = $0142;
  META_STRETCHDIB            = $0f43;
  META_EXTFLOODFILL          = $0548;
  META_SETLAYOUT             = $0149;
  META_DELETEOBJECT          = $01f0;
  META_CREATEPALETTE         = $00f7;
  META_CREATEPATTERNBRUSH    = $01F9;
  META_CREATEPENINDIRECT     = $02FA;
  META_CREATEFONTINDIRECT    = $02FB;
  META_CREATEBRUSHINDIRECT   = $02FC;
  META_CREATEREGION          = $06FF;

type
  PDrawPatRect = ^TDrawPatRect;
  _DRAWPATRECT = record
    ptPosition: POINT;
    ptSize: POINT;
    wStyle: WORD;
    wPattern: WORD;
  end;
  DRAWPATRECT = _DRAWPATRECT;
  TDrawPatRect = _DRAWPATRECT;

// GDI Escapes

const
  NEWFRAME           = 1;
  _ABORTDOC          = 2; // Underscore prfix by translator (nameclash)
  NEXTBAND           = 3;
  SETCOLORTABLE      = 4;
  GETCOLORTABLE      = 5;
  FLUSHOUTPUT        = 6;
  DRAFTMODE          = 7;
  QUERYESCSUPPORT    = 8;
  SETABORTPROC_      = 9;  // Underscore prfix by translator (nameclash)
  STARTDOC_          = 10; // Underscore prfix by translator (nameclash)
  ENDDOC_            = 11; // Underscore prfix by translator (nameclash)
  GETPHYSPAGESIZE    = 12;
  GETPRINTINGOFFSET  = 13;
  GETSCALINGFACTOR   = 14;
  MFCOMMENT          = 15;
  GETPENWIDTH        = 16;
  SETCOPYCOUNT       = 17;
  SELECTPAPERSOURCE  = 18;
  DEVICEDATA         = 19;
  PASSTHROUGH        = 19;
  GETTECHNOLGY       = 20;
  GETTECHNOLOGY      = 20;
  SETLINECAP         = 21;
  SETLINEJOIN        = 22;
  SETMITERLIMIT_     = 23; // underscore prefix by translator (nameclash)
  BANDINFO           = 24;
  DRAWPATTERNRECT    = 25;
  GETVECTORPENSIZE   = 26;
  GETVECTORBRUSHSIZE = 27;
  ENABLEDUPLEX       = 28;
  GETSETPAPERBINS    = 29;
  GETSETPRINTORIENT  = 30;
  ENUMPAPERBINS      = 31;
  SETDIBSCALING      = 32;
  EPSPRINTING        = 33;
  ENUMPAPERMETRICS   = 34;
  GETSETPAPERMETRICS = 35;
  POSTSCRIPT_DATA    = 37;
  POSTSCRIPT_IGNORE  = 38;
  MOUSETRAILS        = 39;
  GETDEVICEUNITS     = 42;

  GETEXTENDEDTEXTMETRICS = 256;
  GETEXTENTTABLE         = 257;
  GETPAIRKERNTABLE       = 258;
  GETTRACKKERNTABLE      = 259;
  EXTTEXTOUT_            = 512; // underscore prefix by translator (nameclash)
  GETFACENAME            = 513;
  DOWNLOADFACE           = 514;
  ENABLERELATIVEWIDTHS   = 768;
  ENABLEPAIRKERNING      = 769;
  SETKERNTRACK           = 770;
  SETALLJUSTVALUES       = 771;
  SETCHARSET             = 772;

  STRETCHBLT_ESCAPE       = 2048; // suffix _ESCAPE by translator because of 
                                  // name-clash with StretchBlt function
  METAFILE_DRIVER         = 2049;
  GETSETSCREENPARAMS      = 3072;
  QUERYDIBSUPPORT         = 3073;
  BEGIN_PATH              = 4096;
  CLIP_TO_PATH            = 4097;
  END_PATH                = 4098;
  EXT_DEVICE_CAPS         = 4099;
  RESTORE_CTM             = 4100;
  SAVE_CTM                = 4101;
  SET_ARC_DIRECTION       = 4102;
  SET_BACKGROUND_COLOR    = 4103;
  SET_POLY_MODE           = 4104;
  SET_SCREEN_ANGLE        = 4105;
  SET_SPREAD              = 4106;
  TRANSFORM_CTM           = 4107;
  SET_CLIP_BOX            = 4108;
  SET_BOUNDS              = 4109;
  SET_MIRROR_MODE         = 4110;
  OPENCHANNEL             = 4110;
  DOWNLOADHEADER          = 4111;
  CLOSECHANNEL            = 4112;
  POSTSCRIPT_PASSTHROUGH  = 4115;
  ENCAPSULATED_POSTSCRIPT = 4116;

  POSTSCRIPT_IDENTIFY  = 4117; // new escape for NT5 pscript driver
  POSTSCRIPT_INJECTION = 4118; // new escape for NT5 pscript driver

  CHECKJPEGFORMAT = 4119;
  CHECKPNGFORMAT  = 4120;

  GET_PS_FEATURESETTING = 4121; // new escape for NT5 pscript driver

  SPCLPASSTHROUGH2 = 4568; // new escape for NT5 pscript driver

//
// Parameters for POSTSCRIPT_IDENTIFY escape
//

  PSIDENT_GDICENTRIC = 0;
  PSIDENT_PSCENTRIC  = 1;

//
// Header structure for the input buffer to POSTSCRIPT_INJECTION escape
//

type
  PPsInjectData = ^TPsInjectData;
  _PSINJECTDATA = record
    DataBytes: DWORD;     // number of raw data bytes (NOT including this header)
    InjectionPoint: WORD; // injection point
    PageNumber: WORD;     // page number to apply the injection
                          // Followed by raw data to be injected
  end;
  PSINJECTDATA = _PSINJECTDATA;
  TPsInjectData = _PSINJECTDATA;

//
// Constants for PSINJECTDATA.InjectionPoint field
//

const
  PSINJECT_BEGINSTREAM = 1;
  PSINJECT_PSADOBE     = 2;
  PSINJECT_PAGESATEND  = 3;
  PSINJECT_PAGES       = 4;

  PSINJECT_DOCNEEDEDRES          = 5;
  PSINJECT_DOCSUPPLIEDRES        = 6;
  PSINJECT_PAGEORDER             = 7;
  PSINJECT_ORIENTATION           = 8;
  PSINJECT_BOUNDINGBOX           = 9;
  PSINJECT_DOCUMENTPROCESSCOLORS = 10;

  PSINJECT_COMMENTS                   = 11;
  PSINJECT_BEGINDEFAULTS              = 12;
  PSINJECT_ENDDEFAULTS                = 13;
  PSINJECT_BEGINPROLOG                = 14;
  PSINJECT_ENDPROLOG                  = 15;
  PSINJECT_BEGINSETUP                 = 16;
  PSINJECT_ENDSETUP                   = 17;
  PSINJECT_TRAILER                    = 18;
  PSINJECT_EOF                        = 19;
  PSINJECT_ENDSTREAM                  = 20;
  PSINJECT_DOCUMENTPROCESSCOLORSATEND = 21;

  PSINJECT_PAGENUMBER     = 100;
  PSINJECT_BEGINPAGESETUP = 101;
  PSINJECT_ENDPAGESETUP   = 102;
  PSINJECT_PAGETRAILER    = 103;
  PSINJECT_PLATECOLOR     = 104;

  PSINJECT_SHOWPAGE        = 105;
  PSINJECT_PAGEBBOX        = 106;
  PSINJECT_ENDPAGECOMMENTS = 107;

  PSINJECT_VMSAVE    = 200;
  PSINJECT_VMRESTORE = 201;

//
// Parameter for GET_PS_FEATURESETTING escape
//

  FEATURESETTING_NUP       = 0;
  FEATURESETTING_OUTPUT    = 1;
  FEATURESETTING_PSLEVEL   = 2;
  FEATURESETTING_CUSTPAPER = 3;
  FEATURESETTING_MIRROR    = 4;
  FEATURESETTING_NEGATIVE  = 5;
  FEATURESETTING_PROTOCOL  = 6;

//
// The range of selectors between FEATURESETTING_PRIVATE_BEGIN and
// FEATURESETTING_PRIVATE_END is reserved by Microsoft for private use
//

  FEATURESETTING_PRIVATE_BEGIN = $1000;
  FEATURESETTING_PRIVATE_END   = $1FFF;

//
// Information about output options
//

type
  PPsFeatureOutput = ^TPsFeatureOutput;
  _PSFEATURE_OUTPUT = record
    bPageIndependent: BOOL;
    bSetPageDevice: BOOL;
  end;
  PSFEATURE_OUTPUT = _PSFEATURE_OUTPUT;
  PPSFEATURE_OUTPUT = ^PSFEATURE_OUTPUT;
  TPsFeatureOutput = _PSFEATURE_OUTPUT;

//
// Information about custom paper size
//

  PPsFeatureCustPaper = ^TPsFeatureCustPaper;
  _PSFEATURE_CUSTPAPER = record
    lOrientation: LONG;
    lWidth: LONG;
    lHeight: LONG;
    lWidthOffset: LONG;
    lHeightOffset: LONG;
  end;
  PSFEATURE_CUSTPAPER = _PSFEATURE_CUSTPAPER;
  PPSFEATURE_CUSTPAPER = ^PSFEATURE_CUSTPAPER;
  TPsFeatureCustPaper = _PSFEATURE_CUSTPAPER;

// Value returned for FEATURESETTING_PROTOCOL

const
  PSPROTOCOL_ASCII  = 0;
  PSPROTOCOL_BCP    = 1;
  PSPROTOCOL_TBCP   = 2;
  PSPROTOCOL_BINARY = 3;

// Flag returned from QUERYDIBSUPPORT

  QDI_SETDIBITS   = 1;
  QDI_GETDIBITS   = 2;
  QDI_DIBTOSCREEN = 4;
  QDI_STRETCHDIB  = 8;

// Spooler Error Codes

  SP_NOTREPORTED = $4000;
  SP_ERROR       = DWORD(-1);
  SP_APPABORT    = DWORD(-2);
  SP_USERABORT   = DWORD(-3);
  SP_OUTOFDISK   = DWORD(-4);
  SP_OUTOFMEMORY = DWORD(-5);

  PR_JOBSTATUS = $0000;

// Object Definitions for EnumObjects()

  OBJ_PEN         = 1;
  OBJ_BRUSH       = 2;
  OBJ_DC          = 3;
  OBJ_METADC      = 4;
  OBJ_PAL         = 5;
  OBJ_FONT        = 6;
  OBJ_BITMAP      = 7;
  OBJ_REGION      = 8;
  OBJ_METAFILE    = 9;
  OBJ_MEMDC       = 10;
  OBJ_EXTPEN      = 11;
  OBJ_ENHMETADC   = 12;
  OBJ_ENHMETAFILE = 13;
  OBJ_COLORSPACE  = 14;

// xform stuff

  MWT_IDENTITY      = 1;
  MWT_LEFTMULTIPLY  = 2;
  MWT_RIGHTMULTIPLY = 3;

  MWT_MIN = MWT_IDENTITY;
  MWT_MAX = MWT_RIGHTMULTIPLY;

type
  PXform = ^TXform;
  tagXFORM = record
    eM11: FLOAT;
    eM12: FLOAT;
    eM21: FLOAT;
    eM22: FLOAT;
    eDx: FLOAT;
    eDy: FLOAT;
  end;
  XFORM = tagXFORM;
  LPXFORM = ^XFORM;
  TXform = XFORM;

// Bitmap Header Definition

  PBitmap = ^TBitmap;
  tagBITMAP = record
    bmType: LONG;
    bmWidth: LONG;
    bmHeight: LONG;
    bmWidthBytes: LONG;
    bmPlanes: WORD;
    bmBitsPixel: WORD;
    bmBits: LPVOID;
  end;
  BITMAP = tagBITMAP;
  LPBITMAP = ^BITMAP;
  NPBITMAP = ^BITMAP;
  TBitmap = BITMAP;

// #include <pshpack1.h>

  PRgbTriple = ^TRgbTriple;
  tagRGBTRIPLE = packed record
    rgbtBlue: BYTE;
    rgbtGreen: BYTE;
    rgbtRed: BYTE;
  end;
  RGBTRIPLE = tagRGBTRIPLE;
  TRgbTriple = RGBTRIPLE;

// #include <poppack.h>

  PRgbQuad = ^TRgbQuad;
  tagRGBQUAD = record
    rgbBlue: BYTE;
    rgbGreen: BYTE;
    rgbRed: BYTE;
    rgbReserved: BYTE;
  end;
  RGBQUAD = tagRGBQUAD;
  LPRGBQUAD = ^RGBQUAD;
  TRgbQuad = RGBQUAD;

// Image Color Matching color definitions

const
  CS_ENABLE           = $00000001;
  CS_DISABLE          = $00000002;
  CS_DELETE_TRANSFORM = $00000003;

// Logcolorspace signature

  LCS_SIGNATURE = 'PSOC';

// Logcolorspace lcsType values

  LCS_sRGB                = 'sRGB';
  LCS_WINDOWS_COLOR_SPACE = 'Win '; // Windows default color space

type
  LCSCSTYPE = LONG;

const
  LCS_CALIBRATED_RGB = $00000000;

type
  LCSGAMUTMATCH = LONG;

const
  LCS_GM_BUSINESS         = $00000001;
  LCS_GM_GRAPHICS         = $00000002;
  LCS_GM_IMAGES           = $00000004;
  LCS_GM_ABS_COLORIMETRIC = $00000008;

// ICM Defines for results from CheckColorInGamut()

  CM_OUT_OF_GAMUT = 255;
  CM_IN_GAMUT     = 0;

// UpdateICMRegKey Constants

  ICM_ADDPROFILE          = 1;
  ICM_DELETEPROFILE       = 2;
  ICM_QUERYPROFILE        = 3;
  ICM_SETDEFAULTPROFILE   = 4;
  ICM_REGISTERICMATCHER   = 5;
  ICM_UNREGISTERICMATCHER = 6;
  ICM_QUERYMATCH          = 7;

// Macros to retrieve CMYK values from a COLORREF

function GetKValue(cmyk: COLORREF): BYTE;
function GetYValue(cmyk: COLORREF): BYTE;
function GetMValue(cmyk: COLORREF): BYTE;
function GetCValue(cmyk: COLORREF): BYTE;
function CMYK(c, m, y, k: BYTE): COLORREF;

type
  FXPT16DOT16 = Longint;
  LPFXPT16DOT16 = ^FXPT16DOT16;

  FXPT2DOT30 = Longint;
  LPFXPT2DOT30 = ^FXPT2DOT30;

// ICM Color Definitions
// The following two structures are used for defining RGB's in terms of CIEXYZ.

  PCieXyz = ^TCieXyz;
  tagCIEXYZ = record
    ciexyzX: FXPT2DOT30;
    ciexyzY: FXPT2DOT30;
    ciexyzZ: FXPT2DOT30;
  end;
  CIEXYZ = tagCIEXYZ;
  LPCIEXYZ = ^CIEXYZ;
  TCieXyz = CIEXYZ;

  PCieXyzTriple = ^TCieXyzTriple;
  tagCIEXYZTRIPLE = record
    ciexyzRed: CIEXYZ;
    ciexyzGreen: CIEXYZ;
    ciexyzBlue: CIEXYZ;
  end;
  CIEXYZTRIPLE = tagCIEXYZTRIPLE;
  LPCIEXYZTRIPLE = ^CIEXYZTRIPLE;
  TCieXyzTriple = CIEXYZTRIPLE;

// The next structures the logical color space. Unlike pens and brushes,
// but like palettes, there is only one way to create a LogColorSpace.
// A pointer to it must be passed, its elements can't be pushed as
// arguments.

  PLogColorSpaceA = ^TLogColorSpaceA;
  tagLOGCOLORSPACEA = record
    lcsSignature: DWORD;
    lcsVersion: DWORD;
    lcsSize: DWORD;
    lcsCSType: LCSCSTYPE;
    lcsIntent: LCSGAMUTMATCH;
    lcsEndpoints: CIEXYZTRIPLE;
    lcsGammaRed: DWORD;
    lcsGammaGreen: DWORD;
    lcsGammaBlue: DWORD;
    lcsFilename: array [0..MAX_PATH - 1] of CHAR;
  end;
  LOGCOLORSPACEA = tagLOGCOLORSPACEA;
  LPLOGCOLORSPACEA = ^LOGCOLORSPACEA;
  TLogColorSpaceA = LOGCOLORSPACEA;

  PLogColorSpaceW = ^TLogColorSpaceW;
  tagLOGCOLORSPACEW = record
    lcsSignature: DWORD;
    lcsVersion: DWORD;
    lcsSize: DWORD;
    lcsCSType: LCSCSTYPE;
    lcsIntent: LCSGAMUTMATCH;
    lcsEndpoints: CIEXYZTRIPLE;
    lcsGammaRed: DWORD;
    lcsGammaGreen: DWORD;
    lcsGammaBlue: DWORD;
    lcsFilename: array [0..MAX_PATH - 1] of WCHAR;
  end;
  LOGCOLORSPACEW = tagLOGCOLORSPACEW;
  LPLOGCOLORSPACEW = ^LOGCOLORSPACEW;
  TLogColorSpaceW = LOGCOLORSPACEW;

  {$IFDEF UNICODE}
  LOGCOLORSPACE = LOGCOLORSPACEW;
  LPLOGCOLORSPACE = LPLOGCOLORSPACEW;
  TLogColorSpace = TLogColorSpaceW;
  PLogColorSpace = PLogColorSpaceW;
  {$ELSE}
  LOGCOLORSPACE = LOGCOLORSPACEA;
  LPLOGCOLORSPACE = LPLOGCOLORSPACEA;
  TLogColorSpace = TLogColorSpaceA;
  PLogColorSpace = PLogColorSpaceA;
  {$ENDIF UNICODE}

// structures for defining DIBs

  PBitmapCoreHeader = ^TBitmapCoreHeader;
  tagBITMAPCOREHEADER = record
    bcSize: DWORD;
    bcWidth: WORD;
    bcHeight: WORD;
    bcPlanes: WORD;
    bcBitCount: WORD;
  end;
  BITMAPCOREHEADER = tagBITMAPCOREHEADER;
  LPBITMAPCOREHEADER = ^BITMAPCOREHEADER;
  TBitmapCoreHeader = BITMAPCOREHEADER;

  PBitmapInfoHeader = ^TBitmapInfoHeader;
  tagBITMAPINFOHEADER = record
    biSize: DWORD;
    biWidth: LONG;
    biHeight: LONG;
    biPlanes: WORD;
    biBitCount: WORD;
    biCompression: DWORD;
    biSizeImage: DWORD;
    biXPelsPerMeter: LONG;
    biYPelsPerMeter: LONG;
    biClrUsed: DWORD;
    biClrImportant: DWORD;
  end;
  BITMAPINFOHEADER = tagBITMAPINFOHEADER;
  LPBITMAPINFOHEADER = ^BITMAPINFOHEADER;
  TBitmapInfoHeader = BITMAPINFOHEADER;

  PBitmapV4Header = ^TBitmapV4Header;
  BITMAPV4HEADER = record
    bV4Size: DWORD;
    bV4Width: LONG;
    bV4Height: LONG;
    bV4Planes: WORD;
    bV4BitCount: WORD;
    bV4V4Compression: DWORD;
    bV4SizeImage: DWORD;
    bV4XPelsPerMeter: LONG;
    bV4YPelsPerMeter: LONG;
    bV4ClrUsed: DWORD;
    bV4ClrImportant: DWORD;
    bV4RedMask: DWORD;
    bV4GreenMask: DWORD;
    bV4BlueMask: DWORD;
    bV4AlphaMask: DWORD;
    bV4CSType: DWORD;
    bV4Endpoints: CIEXYZTRIPLE;
    bV4GammaRed: DWORD;
    bV4GammaGreen: DWORD;
    bV4GammaBlue: DWORD;
  end;
  LPBITMAPV4HEADER = ^BITMAPV4HEADER;
  TBitmapV4Header = BITMAPV4HEADER;

  PBitmapV5Header = ^TBitmapV5Header;
  BITMAPV5HEADER = record
    bV5Size: DWORD;
    bV5Width: LONG;
    bV5Height: LONG;
    bV5Planes: WORD;
    bV5BitCount: WORD;
    bV5Compression: DWORD;
    bV5SizeImage: DWORD;
    bV5XPelsPerMeter: LONG;
    bV5YPelsPerMeter: LONG;
    bV5ClrUsed: DWORD;
    bV5ClrImportant: DWORD;
    bV5RedMask: DWORD;
    bV5GreenMask: DWORD;
    bV5BlueMask: DWORD;
    bV5AlphaMask: DWORD;
    bV5CSType: DWORD;
    bV5Endpoints: CIEXYZTRIPLE;
    bV5GammaRed: DWORD;
    bV5GammaGreen: DWORD;
    bV5GammaBlue: DWORD;
    bV5Intent: DWORD;
    bV5ProfileData: DWORD;
    bV5ProfileSize: DWORD;
    bV5Reserved: DWORD;
  end;
  LPBITMAPV5HEADER = ^BITMAPV5HEADER;
  TBitmapV5Header = BITMAPV5HEADER;

// Values for bV5CSType

const
  PROFILE_LINKED   = 'LINK';
  PROFILE_EMBEDDED = 'MBED';

// constants for the biCompression field

  BI_RGB       = 0;
  BI_RLE8      = 1;
  BI_RLE4      = 2;
  BI_BITFIELDS = 3;
  BI_JPEG      = 4;
  BI_PNG       = 5;

type
  PBitmapInfo = ^TBitmapInfo;
  tagBITMAPINFO = record
    bmiHeader: BITMAPINFOHEADER;
    bmiColors: array [0..0] of RGBQUAD;
  end;
  BITMAPINFO = tagBITMAPINFO;
  LPBITMAPINFO = ^BITMAPINFO;
  TBitmapInfo = BITMAPINFO;

  PBitmapCoreInfo = ^TBitmapCoreInfo;
  tagBITMAPCOREINFO = record
    bmciHeader: BITMAPCOREHEADER;
    bmciColors: array [0..0] of RGBTRIPLE;
  end;
  BITMAPCOREINFO = tagBITMAPCOREINFO;
  LPBITMAPCOREINFO = ^BITMAPCOREINFO;
  TBitmapCoreInfo = BITMAPCOREINFO;

// #include <pshpack2.h>

  PBitmapFileHeader = ^TBitmapFileHeader;
  tagBITMAPFILEHEADER = packed record
    bfType: WORD;
    bfSize: DWORD;
    bfReserved1: WORD;
    bfReserved2: WORD;
    bfOffBits: DWORD;
  end;
  BITMAPFILEHEADER = tagBITMAPFILEHEADER;
  LPBITMAPFILEHEADER = ^BITMAPFILEHEADER;
  TBitmapFileHeader = BITMAPFILEHEADER;

// #include <poppack.h>

function MAKEPOINTS(l: DWORD): POINTS;

type
  PFontSignature = ^TFontSignature;
  tagFONTSIGNATURE = record
    fsUsb: array [0..3] of DWORD;
    fsCsb: array [0..1] of DWORD;
  end;
  FONTSIGNATURE = tagFONTSIGNATURE;
  LPFONTSIGNATURE = ^FONTSIGNATURE;
  TFontSignature = FONTSIGNATURE;

  PCharSetInfo = ^TCharSetInfo;
  tagCHARSETINFO = record
    ciCharset: UINT;
    ciACP: UINT;
    fs: FONTSIGNATURE;
  end;
  CHARSETINFO = tagCHARSETINFO;
  LPCHARSETINFO = ^CHARSETINFO;
  NPCHARSETINFO = ^CHARSETINFO;
  TCharSetInfo = CHARSETINFO;

const
  TCI_SRCCHARSET  = 1;
  TCI_SRCCODEPAGE = 2;
  TCI_SRCFONTSIG  = 3;
  TCI_SRCLOCALE   = $1000;

type
  PLocaleSignature = ^TLocaleSignature;
  tagLOCALESIGNATURE = record
    lsUsb: array [0..3] of DWORD;
    lsCsbDefault: array [0..1] of DWORD;
    lsCsbSupported: array [0..1] of DWORD;
  end;
  LOCALESIGNATURE = tagLOCALESIGNATURE;
  LPLOCALESIGNATURE = ^LOCALESIGNATURE;
  TLocaleSignature = LOCALESIGNATURE;

// Clipboard Metafile Picture Structure

  PHandleTable = ^THandleTable;
  tagHANDLETABLE = record
    objectHandle: array [0..0] of HGDIOBJ;
  end;
  HANDLETABLE = tagHANDLETABLE;
  LPHANDLETABLE = ^HANDLETABLE;
  THandleTable = HANDLETABLE;

  PMetaRecord = ^TMetaRecord;
  tagMETARECORD = record
    rdSize: DWORD;
    rdFunction: WORD;
    rdParm: array [0..0] of WORD;
  end;
  METARECORD = tagMETARECORD;
  LPMETARECORD = ^METARECORD;
  TMetaRecord = METARECORD;

  PMetaFilePict = ^TMetaFilePict;
  tagMETAFILEPICT = record
    mm: LONG;
    xExt: LONG;
    yExt: LONG;
    hMF: HMETAFILE;
  end;
  METAFILEPICT = tagMETAFILEPICT;
  LPMETAFILEPICT = ^METAFILEPICT;
  TMetaFilePict = METAFILEPICT;

// #include <pshpack2.h>

  PMetaHeader = ^TMetaHeader;
  tagMETAHEADER = packed record
    mtType: WORD;
    mtHeaderSize: WORD;
    mtVersion: WORD;
    mtSize: DWORD;
    mtNoObjects: WORD;
    mtMaxRecord: DWORD;
    mtNoParameters: WORD;
  end;
  METAHEADER = tagMETAHEADER;
  LPMETAHEADER = ^METAHEADER;
  TMetaHeader = METAHEADER;

// #include <poppack.h>

// Enhanced Metafile structures

  PEnhMetaRecord = ^TEnhMetaRecord;
  tagENHMETARECORD = record
    iType: DWORD; // Record type EMR_XXX
    nSize: DWORD; // Record size in bytes
    dParm: array [0..0] of DWORD; // Parameters
  end;
  ENHMETARECORD = tagENHMETARECORD;
  LPENHMETARECORD = ^ENHMETARECORD;
  TEnhMetaRecord = ENHMETARECORD;

  PEnhMetaHeader = ^TEnhMetaHeader;
  tagENHMETAHEADER = record
    iType: DWORD;              // Record type EMR_HEADER
    nSize: DWORD;              // Record size in bytes.  This may be greater
                               // than the sizeof(ENHMETAHEADER).
    rclBounds: RECTL;          // Inclusive-inclusive bounds in device units
    rclFrame: RECTL;           // Inclusive-inclusive Picture Frame of metafile in .01 mm units
    dSignature: DWORD;         // Signature.  Must be ENHMETA_SIGNATURE.
    nVersion: DWORD;           // Version number
    nBytes: DWORD;             // Size of the metafile in bytes
    nRecords: DWORD;           // Number of records in the metafile
    nHandles: WORD;            // Number of handles in the handle table
                               // Handle index zero is reserved.
    sReserved: WORD;           // Reserved.  Must be zero.
    nDescription: DWORD;       // Number of chars in the unicode description string
                               // This is 0 if there is no description string
    offDescription: DWORD;     // Offset to the metafile description record.
                               // This is 0 if there is no description string
    nPalEntries: DWORD;        // Number of entries in the metafile palette.
    szlDevice: SIZEL;          // Size of the reference device in pels
    szlMillimeters: SIZEL;     // Size of the reference device in millimeters
    cbPixelFormat: DWORD;      // Size of PIXELFORMATDESCRIPTOR information
                               // This is 0 if no pixel format is set
    offPixelFormat: DWORD;     // Offset to PIXELFORMATDESCRIPTOR
                               // This is 0 if no pixel format is set
    bOpenGL: DWORD;            // TRUE if OpenGL commands are present in
                               // the metafile, otherwise FALSE
    szlMicrometers: SIZEL;     // Size of the reference device in micrometers
  end;
  ENHMETAHEADER = tagENHMETAHEADER;
  LPENHMETAHEADER = ^ENHMETAHEADER;
  TEnhMetaHeader = tagENHMETAHEADER;

// tmPitchAndFamily flags

const
  TMPF_FIXED_PITCH = $01;
  TMPF_VECTOR      = $02;
  TMPF_DEVICE      = $08;
  TMPF_TRUETYPE    = $04;

//
// BCHAR definition for APPs
//

type
  {$IFDEF UNICODE}
  BCHAR = WCHAR;
  {$ELSE}
  BCHAR = BYTE;
  {$ENDIF UNICODE}

type
  PTextMetricA = ^TTextMetricA;
  tagTEXTMETRICA = record
    tmHeight: LONG;
    tmAscent: LONG;
    tmDescent: LONG;
    tmInternalLeading: LONG;
    tmExternalLeading: LONG;
    tmAveCharWidth: LONG;
    tmMaxCharWidth: LONG;
    tmWeight: LONG;
    tmOverhang: LONG;
    tmDigitizedAspectX: LONG;
    tmDigitizedAspectY: LONG;
    tmFirstChar: BYTE;
    tmLastChar: BYTE;
    tmDefaultChar: BYTE;
    tmBreakChar: BYTE;
    tmItalic: BYTE;
    tmUnderlined: BYTE;
    tmStruckOut: BYTE;
    tmPitchAndFamily: BYTE;
    tmCharSet: BYTE;
  end;
  TEXTMETRICA = tagTEXTMETRICA;
  LPTEXTMETRICA = ^TEXTMETRICA;
  NPTEXTMETRICA = ^TEXTMETRICA;
  TTextMetricA = TEXTMETRICA;

  PTextMetricW = ^TTextMetricW;
  tagTEXTMETRICW = record
    tmHeight: LONG;
    tmAscent: LONG;
    tmDescent: LONG;
    tmInternalLeading: LONG;
    tmExternalLeading: LONG;
    tmAveCharWidth: LONG;
    tmMaxCharWidth: LONG;
    tmWeight: LONG;
    tmOverhang: LONG;
    tmDigitizedAspectX: LONG;
    tmDigitizedAspectY: LONG;
    tmFirstChar: WCHAR;
    tmLastChar: WCHAR;
    tmDefaultChar: WCHAR;
    tmBreakChar: WCHAR;
    tmItalic: BYTE;
    tmUnderlined: BYTE;
    tmStruckOut: BYTE;
    tmPitchAndFamily: BYTE;
    tmCharSet: BYTE;
  end;
  TEXTMETRICW = tagTEXTMETRICW;
  LPTEXTMETRICW = ^TEXTMETRICW;
  NPTEXTMETRICW = ^TEXTMETRICW;
  TTextMetricW = TEXTMETRICW;

  {$IFDEF UNICODE}
  TEXTMETRIC = TEXTMETRICW;
  PTEXTMETRIC = PTEXTMETRICW;
  NPTEXTMETRIC = NPTEXTMETRICW;
  LPTEXTMETRIC = LPTEXTMETRICW;
  TTextMetric = TTextMetricW;
  {$ELSE}
  TEXTMETRIC = TEXTMETRICA;
  NPTEXTMETRIC = NPTEXTMETRICA;
  LPTEXTMETRIC = LPTEXTMETRICA;
  TTextMetric = TTextMetricA;
  {$ENDIF UNICODE}

// ntmFlags field flags

const
  NTM_REGULAR = $00000040;
  NTM_BOLD    = $00000020;
  NTM_ITALIC  = $00000001;

// new in NT 5.0

  NTM_NONNEGATIVE_AC = $00010000;
  NTM_PS_OPENTYPE    = $00020000;
  NTM_TT_OPENTYPE    = $00040000;
  NTM_MULTIPLEMASTER = $00080000;
  NTM_TYPE1          = $00100000;
  NTM_DSIG           = $00200000;

// #include <pshpack4.h>

type
  PNewTextMetricA = ^TNewTextMetricA;
  tagNEWTEXTMETRICA = record
    tmHeight: LONG;
    tmAscent: LONG;
    tmDescent: LONG;
    tmInternalLeading: LONG;
    tmExternalLeading: LONG;
    tmAveCharWidth: LONG;
    tmMaxCharWidth: LONG;
    tmWeight: LONG;
    tmOverhang: LONG;
    tmDigitizedAspectX: LONG;
    tmDigitizedAspectY: LONG;
    tmFirstChar: BYTE;
    tmLastChar: BYTE;
    tmDefaultChar: BYTE;
    tmBreakChar: BYTE;
    tmItalic: BYTE;
    tmUnderlined: BYTE;
    tmStruckOut: BYTE;
    tmPitchAndFamily: BYTE;
    tmCharSet: BYTE;
    ntmFlags: DWORD;
    ntmSizeEM: UINT;
    ntmCellHeight: UINT;
    ntmAvgWidth: UINT;
  end;
  NEWTEXTMETRICA = tagNEWTEXTMETRICA;
  LPNEWTEXTMETRICA = ^NEWTEXTMETRICA;
  NPNEWTEXTMETRICA = ^NEWTEXTMETRICA;
  TNewTextMetricA = NEWTEXTMETRICA;

  PNewTextMetricW = ^TNewTextMetricW;
  tagNEWTEXTMETRICW = record
    tmHeight: LONG;
    tmAscent: LONG;
    tmDescent: LONG;
    tmInternalLeading: LONG;
    tmExternalLeading: LONG;
    tmAveCharWidth: LONG;
    tmMaxCharWidth: LONG;
    tmWeight: LONG;
    tmOverhang: LONG;
    tmDigitizedAspectX: LONG;
    tmDigitizedAspectY: LONG;
    tmFirstChar: WCHAR;
    tmLastChar: WCHAR;
    tmDefaultChar: WCHAR;
    tmBreakChar: WCHAR;
    tmItalic: BYTE;
    tmUnderlined: BYTE;
    tmStruckOut: BYTE;
    tmPitchAndFamily: BYTE;
    tmCharSet: BYTE;
    ntmFlags: DWORD;
    ntmSizeEM: UINT;
    ntmCellHeight: UINT;
    ntmAvgWidth: UINT;
  end;
  NEWTEXTMETRICW = tagNEWTEXTMETRICW;
  LPNEWTEXTMETRICW = ^NEWTEXTMETRICW;
  NPNEWTEXTMETRICW = ^NEWTEXTMETRICW;
  TNewTextMetricW = NEWTEXTMETRICW;

  {$IFDEF UNICODE}
  NEWTEXTMETRIC = NEWTEXTMETRICW;
  PNEWTEXTMETRIC = PNEWTEXTMETRICW;
  NPNEWTEXTMETRIC = NPNEWTEXTMETRICW;
  LPNEWTEXTMETRIC = LPNEWTEXTMETRICW;
  TNewTextMetric = TNewTextMetricW;
  {$ELSE}
  NEWTEXTMETRIC = NEWTEXTMETRICW;
  PNEWTEXTMETRIC = PNEWTEXTMETRICW;
  NPNEWTEXTMETRIC = NPNEWTEXTMETRICW;
  LPNEWTEXTMETRIC = LPNEWTEXTMETRICW;
  TNewTextMetric = TNewTextMetricW;
  {$ENDIF UNICODE}

// #include <poppack.h>

  PNewTextMetricExA = ^TNewTextMetricExA;
  tagNEWTEXTMETRICEXA = record
    ntmTm: NEWTEXTMETRICA;
    ntmFontSig: FONTSIGNATURE;
  end;
  NEWTEXTMETRICEXA = tagNEWTEXTMETRICEXA;
  TNewTextMetricExA = NEWTEXTMETRICEXA;

  PNewTextMetricExW = ^TNewTextMetricExW;
  tagNEWTEXTMETRICEXW = record
    ntmTm: NEWTEXTMETRICW;
    ntmFontSig: FONTSIGNATURE;
  end;
  NEWTEXTMETRICEXW = tagNEWTEXTMETRICEXW;
  TNewTextMetricExW = NEWTEXTMETRICEXW;

  {$IFDEF UNICODE}
  NEWTEXTMETRICEX = NEWTEXTMETRICEXW;
  TNewTextMetricEx = TNewTextMetricExW;
  PNewTextMetricEx = PNewTextMetricExW;
  {$ELSE}
  NEWTEXTMETRICEX = NEWTEXTMETRICEXA;
  TNewTextMetricEx = TNewTextMetricExA;
  PNewTextMetricEx = PNewTextMetricExA;
  {$ENDIF UNICODE}

// GDI Logical Objects:

// Pel Array

  PPelArray = ^TPelArray;
  tagPELARRAY = record
    paXCount: LONG;
    paYCount: LONG;
    paXExt: LONG;
    paYExt: LONG;
    paRGBs: BYTE;
  end;
  PELARRAY = tagPELARRAY;
  LPPELARRAY = ^PELARRAY;
  TPelArray = PELARRAY;

// Logical Brush (or Pattern)

  PLogBrush = ^TLogBrush;
  tagLOGBRUSH = record
    lbStyle: UINT;
    lbColor: COLORREF;
    lbHatch: ULONG_PTR; // Sundown: lbHatch could hold a HANDLE
  end;
  LOGBRUSH = tagLOGBRUSH;
  LPLOGBRUSH = ^LOGBRUSH;
  NPLOGBRUSH = ^LOGBRUSH;
  TLogBrush = LOGBRUSH;

  PLogBrush32 = ^TLogBrush32;
  tagLOGBRUSH32 = record
    lbStyle: UINT;
    lbColor: COLORREF;
    lbHatch: ULONG;
  end;
  LOGBRUSH32 = tagLOGBRUSH32;
  LPLOGBRUSH32 = ^LOGBRUSH32;
  NPLOGBRUSH32 = ^LOGBRUSH32;
  TLogBrush32 = LOGBRUSH32;

  PATTERN = LOGBRUSH;
  PPATTERN = ^PATTERN;
  LPPATTERN = ^PATTERN;
  NPPATTERN = ^PATTERN;

// Logical Pen

  PLogPen = ^TLogPen;
  tagLOGPEN = record
    lopnStyle: UINT;
    lopnWidth: POINT;
    lopnColor: COLORREF;
  end;
  LOGPEN = tagLOGPEN;
  LPLOGPEN = ^LOGPEN;
  NPLOGPEN = ^LOGPEN;
  TLogPen = LOGPEN;

  PExtLogPen = ^TExtLogPen;
  tagEXTLOGPEN = record
    elpPenStyle: DWORD;
    elpWidth: DWORD;
    elpBrushStyle: UINT;
    elpColor: COLORREF;
    elpHatch: ULONG_PTR; // Sundown: elpHatch could take a HANDLE
    elpNumEntries: DWORD;
    elpStyleEntry: array [0..0] of DWORD;
  end;
  EXTLOGPEN = tagEXTLOGPEN;
  LPEXTLOGPEN = ^EXTLOGPEN;
  NPEXTLOGPEN = ^EXTLOGPEN;
  TExtLogPen = EXTLOGPEN;

  PPaletteEntry = ^TPaletteEntry;
  tagPALETTEENTRY = record
    peRed: BYTE;
    peGreen: BYTE;
    peBlue: BYTE;
    peFlags: BYTE;
  end;
  PALETTEENTRY = tagPALETTEENTRY;
  LPPALETTEENTRY = ^PALETTEENTRY;
  TPaletteEntry = PALETTEENTRY;

// Logical Palette

  PLogPalette = ^TLogPalette;
  tagLOGPALETTE = record
    palVersion: WORD;
    palNumEntries: WORD;
    palPalEntry: array [0..0] of PALETTEENTRY;
  end;
  LOGPALETTE = tagLOGPALETTE;
  LPLOGPALETTE = ^LOGPALETTE;
  NPLOGPALETTE = ^LOGPALETTE;
  TLogPalette = LOGPALETTE;

// Logical Font

const
  LF_FACESIZE = 32;

type
  PLogFontA = ^TLogFontA;
  tagLOGFONTA = record
    lfHeight: LONG;
    lfWidth: LONG;
    lfEscapement: LONG;
    lfOrientation: LONG;
    lfWeight: LONG;
    lfItalic: BYTE;
    lfUnderline: BYTE;
    lfStrikeOut: BYTE;
    lfCharSet: BYTE;
    lfOutPrecision: BYTE;
    lfClipPrecision: BYTE;
    lfQuality: BYTE;
    lfPitchAndFamily: BYTE;
    lfFaceName: array [0..LF_FACESIZE - 1] of CHAR;
  end;
  LOGFONTA = tagLOGFONTA;
  LPLOGFONTA = ^LOGFONTA;
  NPLOGFONTA = ^LOGFONTA;
  TLogFontA = LOGFONTA;

  PLogFontW = ^TLogFontW;
  tagLOGFONTW = record
    lfHeight: LONG;
    lfWidth: LONG;
    lfEscapement: LONG;
    lfOrientation: LONG;
    lfWeight: LONG;
    lfItalic: BYTE;
    lfUnderline: BYTE;
    lfStrikeOut: BYTE;
    lfCharSet: BYTE;
    lfOutPrecision: BYTE;
    lfClipPrecision: BYTE;
    lfQuality: BYTE;
    lfPitchAndFamily: BYTE;
    lfFaceName: array [0..LF_FACESIZE - 1] of WCHAR;
  end;
  LOGFONTW = tagLOGFONTW;
  LPLOGFONTW = ^LOGFONTW;
  NPLOGFONTW = ^LOGFONTW;
  TLogFontW = LOGFONTW;

  {$IFDEF UNICODE}
  LOGFONT = LOGFONTW;
  PLOGFONT = PLOGFONTW;
  NPLOGFONT = NPLOGFONTW;
  LPLOGFONT = LPLOGFONTW;
  TLogFont = TLogFontW;
  {$ELSE}
  LOGFONT = LOGFONTA;
  PLOGFONT = PLOGFONTA;
  NPLOGFONT = NPLOGFONTA;
  LPLOGFONT = LPLOGFONTA;
  TLogFont = TLogFontA;
  {$ENDIF UNICODE}

const
  LF_FULLFACESIZE = 64;

// Structure passed to FONTENUMPROC

type
  PEnumLogFontA = ^TEnumLogFontA;
  tagENUMLOGFONTA = record
    elfLogFont: LOGFONTA;
    elfFullName: array [ 0..LF_FULLFACESIZE - 1] of BYTE;
    elfStyle: array [0..LF_FACESIZE - 1] of BYTE;
  end;
  ENUMLOGFONTA = tagENUMLOGFONTA;
  LPENUMLOGFONTA = ^ENUMLOGFONTA;
  TEnumLogFontA = ENUMLOGFONTA;

// Structure passed to FONTENUMPROC

  PEnumLogFontW = ^TEnumLogFontW;
  tagENUMLOGFONTW = record
    elfLogFont: LOGFONTW;
    elfFullName: array [0..LF_FULLFACESIZE - 1] of WCHAR;
    elfStyle: array [0..LF_FACESIZE - 1] of WCHAR;
  end;
  ENUMLOGFONTW = tagENUMLOGFONTW;
  LPENUMLOGFONTW = ^ENUMLOGFONTW;
  TEnumLogFontW = ENUMLOGFONTW;

  {$IFDEF UNICODE}
  ENUMLOGFONT = ENUMLOGFONTW;
  LPENUMLOGFONT = LPENUMLOGFONTW;
  TEnumLogFont = TEnumLogFontW;
  PEnumLogFont = PEnumLogFontW;
  {$ELSE}
  ENUMLOGFONT = ENUMLOGFONTA;
  LPENUMLOGFONT = LPENUMLOGFONTA;
  TEnumLogFont = TEnumLogFontA;
  PEnumLogFont = PEnumLogFontA;
  {$ENDIF UNICODE}

  PEnumLogFontExA = ^TEnumLogFontExA;
  tagENUMLOGFONTEXA = record
    elfLogFont: LOGFONTA;
    elfFullName: array [0..LF_FULLFACESIZE - 1] of BYTE;
    elfStyle: array [0..LF_FACESIZE - 1] of BYTE;
    elfScript: array [0..LF_FACESIZE - 1] of BYTE;
  end;
  ENUMLOGFONTEXA = tagENUMLOGFONTEXA;
  LPENUMLOGFONTEXA = ^ENUMLOGFONTEXA;
  TEnumLogFontExA = ENUMLOGFONTEXA;

  PEnumLogFontExW = ^TEnumLogFontExW;
  tagENUMLOGFONTEXW = record
    elfLogFont: LOGFONTW;
    elfFullName: array [0..LF_FULLFACESIZE - 1] of WCHAR;
    elfStyle: array [0..LF_FACESIZE - 1] of WCHAR;
    elfScript: array [0..LF_FACESIZE - 1] of WCHAR;
  end;
  ENUMLOGFONTEXW = tagENUMLOGFONTEXW;
  LPENUMLOGFONTEXW = ^ENUMLOGFONTEXW;
  TEnumLogFontExW = ENUMLOGFONTEXW;

  {$IFDEF UNICODE}
  ENUMLOGFONTEX = ENUMLOGFONTEXW;
  LPENUMLOGFONTEX = LPENUMLOGFONTEXW;
  TEnumLogFontEx = TEnumLogFontExW;
  PEnumLogFontEx = PEnumLogFontExW;
  {$ELSE}
  ENUMLOGFONTEX = ENUMLOGFONTEXA;
  LPENUMLOGFONTEX = LPENUMLOGFONTEXA;
  TEnumLogFontEx = TEnumLogFontExA;
  PEnumLogFontEx = PEnumLogFontExA;
  {$ENDIF UNICODE}

const
  OUT_DEFAULT_PRECIS        = 0;
  OUT_STRING_PRECIS         = 1;
  OUT_CHARACTER_PRECIS      = 2;
  OUT_STROKE_PRECIS         = 3;
  OUT_TT_PRECIS             = 4;
  OUT_DEVICE_PRECIS         = 5;
  OUT_RASTER_PRECIS         = 6;
  OUT_TT_ONLY_PRECIS        = 7;
  OUT_OUTLINE_PRECIS        = 8;
  OUT_SCREEN_OUTLINE_PRECIS = 9;
  OUT_PS_ONLY_PRECIS        = 10;

  CLIP_DEFAULT_PRECIS   = 0;
  CLIP_CHARACTER_PRECIS = 1;
  CLIP_STROKE_PRECIS    = 2;
  CLIP_MASK             = $f;
  CLIP_LH_ANGLES        = 1 shl 4;
  CLIP_TT_ALWAYS        = 2 shl 4;
  CLIP_DFA_DISABLE      = 4 shl 4;
  CLIP_EMBEDDED         = 8 shl 4;

  DEFAULT_QUALITY        = 0;
  DRAFT_QUALITY          = 1;
  PROOF_QUALITY          = 2;
  NONANTIALIASED_QUALITY = 3;
  ANTIALIASED_QUALITY    = 4;
  CLEARTYPE_QUALITY      = 5;

//#if (_WIN32_WINNT >= 0x0501)
  CLEARTYPE_NATURAL_QUALITY = 6;
//#endif

  DEFAULT_PITCH  = 0;
  FIXED_PITCH    = 1;
  VARIABLE_PITCH = 2;
  MONO_FONT      = 8;

  ANSI_CHARSET        = 0;
  DEFAULT_CHARSET     = 1;
  SYMBOL_CHARSET      = 2;
  SHIFTJIS_CHARSET    = 128;
  HANGEUL_CHARSET     = 129;
  HANGUL_CHARSET      = 129;
  GB2312_CHARSET      = 134;
  CHINESEBIG5_CHARSET = 136;
  OEM_CHARSET         = 255;
  JOHAB_CHARSET       = 130;
  HEBREW_CHARSET      = 177;
  ARABIC_CHARSET      = 178;
  GREEK_CHARSET       = 161;
  TURKISH_CHARSET     = 162;
  VIETNAMESE_CHARSET  = 163;
  THAI_CHARSET        = 222;
  EASTEUROPE_CHARSET  = 238;
  RUSSIAN_CHARSET     = 204;

  MAC_CHARSET    = 77;
  BALTIC_CHARSET = 186;

  FS_LATIN1      = $00000001;
  FS_LATIN2      = $00000002;
  FS_CYRILLIC    = $00000004;
  FS_GREEK       = $00000008;
  FS_TURKISH     = $00000010;
  FS_HEBREW      = $00000020;
  FS_ARABIC      = $00000040;
  FS_BALTIC      = $00000080;
  FS_VIETNAMESE  = $00000100;
  FS_THAI        = $00010000;
  FS_JISJAPAN    = $00020000;
  FS_CHINESESIMP = $00040000;
  FS_WANSUNG     = $00080000;
  FS_CHINESETRAD = $00100000;
  FS_JOHAB       = $00200000;
  FS_SYMBOL      = $80000000;

// Font Families

  FF_DONTCARE   = 0 shl 4; // Don't care or don't know.
  FF_ROMAN      = 1 shl 4; // Variable stroke width, serifed.
                             // Times Roman, Century Schoolbook, etc.
  FF_SWISS      = 2 shl 4; // Variable stroke width, sans-serifed.
                             // Helvetica, Swiss, etc.
  FF_MODERN     = 3 shl 4; // Constant stroke width, serifed or sans-serifed.
                             // Pica, Elite, Courier, etc.
  FF_SCRIPT     = 4 shl 4; // Cursive, etc.
  FF_DECORATIVE = 5 shl 4; // Old English, etc.

// Font Weights

  FW_DONTCARE   = 0;
  FW_THIN       = 100;
  FW_EXTRALIGHT = 200;
  FW_LIGHT      = 300;
  FW_NORMAL     = 400;
  FW_MEDIUM     = 500;
  FW_SEMIBOLD   = 600;
  FW_BOLD       = 700;
  FW_EXTRABOLD  = 800;
  FW_HEAVY      = 900;

  FW_ULTRALIGHT = FW_EXTRALIGHT;
  FW_REGULAR    = FW_NORMAL;
  FW_DEMIBOLD   = FW_SEMIBOLD;
  FW_ULTRABOLD  = FW_EXTRABOLD;
  FW_BLACK      = FW_HEAVY;

  PANOSE_COUNT              = 10;
  PAN_FAMILYTYPE_INDEX      = 0;
  PAN_SERIFSTYLE_INDEX      = 1;
  PAN_WEIGHT_INDEX          = 2;
  PAN_PROPORTION_INDEX      = 3;
  PAN_CONTRAST_INDEX        = 4;
  PAN_STROKEVARIATION_INDEX = 5;
  PAN_ARMSTYLE_INDEX        = 6;
  PAN_LETTERFORM_INDEX      = 7;
  PAN_MIDLINE_INDEX         = 8;
  PAN_XHEIGHT_INDEX         = 9;

  PAN_CULTURE_LATIN = 0;

type
  PPanose = ^TPanose;
  tagPANOSE = record
    bFamilyType: BYTE;
    bSerifStyle: BYTE;
    bWeight: BYTE;
    bProportion: BYTE;
    bContrast: BYTE;
    bStrokeVariation: BYTE;
    bArmStyle: BYTE;
    bLetterform: BYTE;
    bMidline: BYTE;
    bXHeight: BYTE;
  end;
  PANOSE = tagPANOSE;
  LPPANOSE = ^PANOSE;
  TPanose = PANOSE;

const
  PAN_ANY    = 0; // Any
  PAN_NO_FIT = 1; // No Fit

  PAN_FAMILY_TEXT_DISPLAY = 2; // Text and Display
  PAN_FAMILY_SCRIPT       = 3; // Script
  PAN_FAMILY_DECORATIVE   = 4; // Decorative
  PAN_FAMILY_PICTORIAL    = 5; // Pictorial

  PAN_SERIF_COVE               = 2; // Cove
  PAN_SERIF_OBTUSE_COVE        = 3; // Obtuse Cove
  PAN_SERIF_SQUARE_COVE        = 4; // Square Cove
  PAN_SERIF_OBTUSE_SQUARE_COVE = 5; // Obtuse Square Cove
  PAN_SERIF_SQUARE             = 6; // Square
  PAN_SERIF_THIN               = 7; // Thin
  PAN_SERIF_BONE               = 8; // Bone
  PAN_SERIF_EXAGGERATED        = 9; // Exaggerated
  PAN_SERIF_TRIANGLE           = 10; // Triangle
  PAN_SERIF_NORMAL_SANS        = 11; // Normal Sans
  PAN_SERIF_OBTUSE_SANS        = 12; // Obtuse Sans
  PAN_SERIF_PERP_SANS          = 13; // Prep Sans
  PAN_SERIF_FLARED             = 14; // Flared
  PAN_SERIF_ROUNDED            = 15; // Rounded

  PAN_WEIGHT_VERY_LIGHT = 2; // Very Light
  PAN_WEIGHT_LIGHT      = 3; // Light
  PAN_WEIGHT_THIN       = 4; // Thin
  PAN_WEIGHT_BOOK       = 5; // Book
  PAN_WEIGHT_MEDIUM     = 6; // Medium
  PAN_WEIGHT_DEMI       = 7; // Demi
  PAN_WEIGHT_BOLD       = 8; // Bold
  PAN_WEIGHT_HEAVY      = 9; // Heavy
  PAN_WEIGHT_BLACK      = 10; // Black
  PAN_WEIGHT_NORD       = 11; // Nord

  PAN_PROP_OLD_STYLE      = 2; // Old Style
  PAN_PROP_MODERN         = 3; // Modern
  PAN_PROP_EVEN_WIDTH     = 4; // Even Width
  PAN_PROP_EXPANDED       = 5; // Expanded
  PAN_PROP_CONDENSED      = 6; // Condensed
  PAN_PROP_VERY_EXPANDED  = 7; // Very Expanded
  PAN_PROP_VERY_CONDENSED = 8; // Very Condensed
  PAN_PROP_MONOSPACED     = 9; // Monospaced

  PAN_CONTRAST_NONE        = 2; // None
  PAN_CONTRAST_VERY_LOW    = 3; // Very Low
  PAN_CONTRAST_LOW         = 4; // Low
  PAN_CONTRAST_MEDIUM_LOW  = 5; // Medium Low
  PAN_CONTRAST_MEDIUM      = 6; // Medium
  PAN_CONTRAST_MEDIUM_HIGH = 7; // Mediim High
  PAN_CONTRAST_HIGH        = 8; // High
  PAN_CONTRAST_VERY_HIGH   = 9; // Very High

  PAN_STROKE_GRADUAL_DIAG = 2; // Gradual/Diagonal
  PAN_STROKE_GRADUAL_TRAN = 3; // Gradual/Transitional
  PAN_STROKE_GRADUAL_VERT = 4; // Gradual/Vertical
  PAN_STROKE_GRADUAL_HORZ = 5; // Gradual/Horizontal
  PAN_STROKE_RAPID_VERT   = 6; // Rapid/Vertical
  PAN_STROKE_RAPID_HORZ   = 7; // Rapid/Horizontal
  PAN_STROKE_INSTANT_VERT = 8; // Instant/Vertical

  PAN_STRAIGHT_ARMS_HORZ         = 2; // Straight Arms/Horizontal
  PAN_STRAIGHT_ARMS_WEDGE        = 3; // Straight Arms/Wedge
  PAN_STRAIGHT_ARMS_VERT         = 4; // Straight Arms/Vertical
  PAN_STRAIGHT_ARMS_SINGLE_SERIF = 5; // Straight Arms/Single-Serif
  PAN_STRAIGHT_ARMS_DOUBLE_SERIF = 6; // Straight Arms/Double-Serif
  PAN_BENT_ARMS_HORZ             = 7; // Non-Straight Arms/Horizontal
  PAN_BENT_ARMS_WEDGE            = 8; // Non-Straight Arms/Wedge
  PAN_BENT_ARMS_VERT             = 9; // Non-Straight Arms/Vertical
  PAN_BENT_ARMS_SINGLE_SERIF     = 10; // Non-Straight Arms/Single-Serif
  PAN_BENT_ARMS_DOUBLE_SERIF     = 11; // Non-Straight Arms/Double-Serif

  PAN_LETT_NORMAL_CONTACT     = 2; // Normal/Contact
  PAN_LETT_NORMAL_WEIGHTED    = 3; // Normal/Weighted
  PAN_LETT_NORMAL_BOXED       = 4; // Normal/Boxed
  PAN_LETT_NORMAL_FLATTENED   = 5; // Normal/Flattened
  PAN_LETT_NORMAL_ROUNDED     = 6; // Normal/Rounded
  PAN_LETT_NORMAL_OFF_CENTER  = 7; // Normal/Off Center
  PAN_LETT_NORMAL_SQUARE      = 8; // Normal/Square
  PAN_LETT_OBLIQUE_CONTACT    = 9; // Oblique/Contact
  PAN_LETT_OBLIQUE_WEIGHTED   = 10; // Oblique/Weighted
  PAN_LETT_OBLIQUE_BOXED      = 11; // Oblique/Boxed
  PAN_LETT_OBLIQUE_FLATTENED  = 12; // Oblique/Flattened
  PAN_LETT_OBLIQUE_ROUNDED    = 13; // Oblique/Rounded
  PAN_LETT_OBLIQUE_OFF_CENTER = 14; // Oblique/Off Center
  PAN_LETT_OBLIQUE_SQUARE     = 15; // Oblique/Square

  PAN_MIDLINE_STANDARD_TRIMMED = 2; // Standard/Trimmed
  PAN_MIDLINE_STANDARD_POINTED = 3; // Standard/Pointed
  PAN_MIDLINE_STANDARD_SERIFED = 4; // Standard/Serifed
  PAN_MIDLINE_HIGH_TRIMMED     = 5; // High/Trimmed
  PAN_MIDLINE_HIGH_POINTED     = 6; // High/Pointed
  PAN_MIDLINE_HIGH_SERIFED     = 7; // High/Serifed
  PAN_MIDLINE_CONSTANT_TRIMMED = 8; // Constant/Trimmed
  PAN_MIDLINE_CONSTANT_POINTED = 9; // Constant/Pointed
  PAN_MIDLINE_CONSTANT_SERIFED = 10; // Constant/Serifed
  PAN_MIDLINE_LOW_TRIMMED      = 11; // Low/Trimmed
  PAN_MIDLINE_LOW_POINTED      = 12; // Low/Pointed
  PAN_MIDLINE_LOW_SERIFED      = 13; // Low/Serifed

  PAN_XHEIGHT_CONSTANT_SMALL = 2; // Constant/Small
  PAN_XHEIGHT_CONSTANT_STD   = 3; // Constant/Standard
  PAN_XHEIGHT_CONSTANT_LARGE = 4; // Constant/Large
  PAN_XHEIGHT_DUCKING_SMALL  = 5; // Ducking/Small
  PAN_XHEIGHT_DUCKING_STD    = 6; // Ducking/Standard
  PAN_XHEIGHT_DUCKING_LARGE  = 7; // Ducking/Large

  ELF_VENDOR_SIZE = 4;

// The extended logical font
// An extension of the ENUMLOGFONT

type
  PExtLogFontA = ^TExtLogFontA;
  tagEXTLOGFONTA = record
    elfLogFont: LOGFONTA;
    elfFullName: array [0..LF_FULLFACESIZE - 1] of BYTE;
    elfStyle: array [0..LF_FACESIZE - 1] of BYTE;
    elfVersion: DWORD;
    elfStyleSize: DWORD;
    elfMatch: DWORD;
    elfReserved: DWORD;
    elfVendorId: array [0..ELF_VENDOR_SIZE - 1] of BYTE;
    elfCulture: DWORD;
    elfPanose: PANOSE;
  end;
  EXTLOGFONTA = tagEXTLOGFONTA;
  LPEXTLOGFONTA = ^EXTLOGFONTA;
  NPEXTLOGFONTA = ^EXTLOGFONTA;
  TExtLogFontA = EXTLOGFONTA;

  PExtLogFontW = ^TExtLogFontW;
  tagEXTLOGFONTW = record
    elfLogFont: LOGFONTW;
    elfFullName: array [0..LF_FULLFACESIZE - 1] of WCHAR;
    elfStyle: array [0..LF_FACESIZE - 1] of WCHAR;
    elfVersion: DWORD;
    elfStyleSize: DWORD;
    elfMatch: DWORD;
    elfReserved: DWORD;
    elfVendorId: array [0..ELF_VENDOR_SIZE - 1] of BYTE;
    elfCulture: DWORD;
    elfPanose: PANOSE;
  end;
  EXTLOGFONTW = tagEXTLOGFONTW;
  LPEXTLOGFONTW = ^EXTLOGFONTW;
  NPEXTLOGFONTW = ^EXTLOGFONTW;
  TExtLogFontW = EXTLOGFONTW;

  {$IFDEF UNICODE}
  EXTLOGFONT = EXTLOGFONTW;
  PEXTLOGFONT = PEXTLOGFONTW;
  NPEXTLOGFONT = NPEXTLOGFONTW;
  LPEXTLOGFONT = LPEXTLOGFONTW;
  TExtLogFont = TExtLogFontW;
  {$ELSE}
  EXTLOGFONT = EXTLOGFONTA;
  PEXTLOGFONT = PEXTLOGFONTA;
  NPEXTLOGFONT = NPEXTLOGFONTA;
  LPEXTLOGFONT = LPEXTLOGFONTA;
  TExtLogFont = TExtLogFontA;
  {$ENDIF UNICODE}

const
  ELF_VERSION       = 0;
  ELF_CULTURE_LATIN = 0;

// EnumFonts Masks

  RASTER_FONTTYPE   = $0001;
  DEVICE_FONTTYPE   = $002;
  TRUETYPE_FONTTYPE = $004;

function RGB(r, g, b: BYTE): COLORREF;
function PALETTERGB(r, g, b: BYTE): COLORREF;
function PALETTEINDEX(i: WORD): COLORREF;

// palette entry flags

const
  PC_RESERVED   = $01; // palette index used for animation
  PC_EXPLICIT   = $02; // palette index is explicit to device
  PC_NOCOLLAPSE = $04; // do not match color to system palette

function GetRValue(rgb: COLORREF): BYTE;
function GetGValue(rgb: COLORREF): BYTE;
function GetBValue(rgb: COLORREF): BYTE;

// Background Modes

const
  TRANSPARENT = 1;
  OPAQUE      = 2;
  BKMODE_LAST = 2;

// Graphics Modes

  GM_COMPATIBLE = 1;
  GM_ADVANCED   = 2;
  GM_LAST       = 2;

// PolyDraw and GetPath point types

  PT_CLOSEFIGURE = $01;
  PT_LINETO      = $02;
  PT_BEZIERTO    = $04;
  PT_MOVETO      = $06;

// Mapping Modes

  MM_TEXT        = 1;
  MM_LOMETRIC    = 2;
  MM_HIMETRIC    = 3;
  MM_LOENGLISH   = 4;
  MM_HIENGLISH   = 5;
  MM_TWIPS       = 6;
  MM_ISOTROPIC   = 7;
  MM_ANISOTROPIC = 8;

// Min and Max Mapping Mode values

  MM_MIN            = MM_TEXT;
  MM_MAX            = MM_ANISOTROPIC;
  MM_MAX_FIXEDSCALE = MM_TWIPS;

// Coordinate Modes

  ABSOLUTE = 1;
  RELATIVE = 2;

// Stock Logical Objects

  WHITE_BRUSH         = 0;
  LTGRAY_BRUSH        = 1;
  GRAY_BRUSH          = 2;
  DKGRAY_BRUSH        = 3;
  BLACK_BRUSH         = 4;
  NULL_BRUSH          = 5;
  HOLLOW_BRUSH        = NULL_BRUSH;
  WHITE_PEN           = 6;
  BLACK_PEN           = 7;
  NULL_PEN            = 8;
  OEM_FIXED_FONT      = 10;
  ANSI_FIXED_FONT     = 11;
  ANSI_VAR_FONT       = 12;
  SYSTEM_FONT         = 13;
  DEVICE_DEFAULT_FONT = 14;
  DEFAULT_PALETTE     = 15;
  SYSTEM_FIXED_FONT   = 16;

  DEFAULT_GUI_FONT = 17;

  DC_BRUSH = 18;
  DC_PEN   = 19;
  
  STOCK_LAST = 19;

  CLR_INVALID = DWORD($FFFFFFFF);

// Brush Styles

  BS_SOLID         = 0;
  BS_NULL          = 1;
  BS_HOLLOW        = BS_NULL;
  BS_HATCHED       = 2;
  BS_PATTERN       = 3;
  BS_INDEXED       = 4;
  BS_DIBPATTERN    = 5;
  BS_DIBPATTERNPT  = 6;
  BS_PATTERN8X8    = 7;
  BS_DIBPATTERN8X8 = 8;
  BS_MONOPATTERN   = 9;

// Hatch Styles

  HS_HORIZONTAL = 0; // -----
  HS_VERTICAL   = 1; // |||||
  HS_FDIAGONAL  = 2; // \\\\\
  HS_BDIAGONAL  = 3; // /////
  HS_CROSS      = 4; // +++++
  HS_DIAGCROSS  = 5; // xxxxx

// Pen Styles

  PS_SOLID       = 0;
  PS_DASH        = 1; // -------
  PS_DOT         = 2; // .......
  PS_DASHDOT     = 3; // _._._._
  PS_DASHDOTDOT  = 4; // _.._.._
  PS_NULL        = 5;
  PS_INSIDEFRAME = 6;
  PS_USERSTYLE   = 7;
  PS_ALTERNATE   = 8;
  PS_STYLE_MASK  = $0000000F;

  PS_ENDCAP_ROUND  = $00000000;
  PS_ENDCAP_SQUARE = $00000100;
  PS_ENDCAP_FLAT   = $00000200;
  PS_ENDCAP_MASK   = $00000F00;

  PS_JOIN_ROUND = $00000000;
  PS_JOIN_BEVEL = $00001000;
  PS_JOIN_MITER = $00002000;
  PS_JOIN_MASK  = $0000F000;

  PS_COSMETIC  = $00000000;
  PS_GEOMETRIC = $00010000;
  PS_TYPE_MASK = $000F0000;

  AD_COUNTERCLOCKWISE = 1;
  AD_CLOCKWISE        = 2;

// Device Parameters for GetDeviceCaps()

  DRIVERVERSION = 0; // Device driver version
  TECHNOLOGY    = 2; // Device classification
  HORZSIZE      = 4; // Horizontal size in millimeters
  VERTSIZE      = 6; // Vertical size in millimeters
  HORZRES       = 8; // Horizontal width in pixels
  VERTRES       = 10; // Vertical height in pixels
  BITSPIXEL     = 12; // Number of bits per pixel
  PLANES        = 14; // Number of planes
  NUMBRUSHES    = 16; // Number of brushes the device has
  NUMPENS       = 18; // Number of pens the device has
  NUMMARKERS    = 20; // Number of markers the device has
  NUMFONTS      = 22; // Number of fonts the device has
  NUMCOLORS     = 24; // Number of colors the device supports
  PDEVICESIZE   = 26; // Size required for device descriptor
  CURVECAPS     = 28; // Curve capabilities
  LINECAPS      = 30; // Line capabilities
  POLYGONALCAPS = 32; // Polygonal capabilities
  TEXTCAPS      = 34; // Text capabilities
  CLIPCAPS      = 36; // Clipping capabilities
  RASTERCAPS    = 38; // Bitblt capabilities
  ASPECTX       = 40; // Length of the X leg
  ASPECTY       = 42; // Length of the Y leg
  ASPECTXY      = 44; // Length of the hypotenuse

  LOGPIXELSX = 88; // Logical pixels/inch in X
  LOGPIXELSY = 90; // Logical pixels/inch in Y

  SIZEPALETTE = 104; // Number of entries in physical palette
  NUMRESERVED = 106; // Number of reserved entries in palette
  COLORRES    = 108; // Actual color resolution

// Printing related DeviceCaps. These replace the appropriate Escapes

  PHYSICALWIDTH   = 110; // Physical Width in device units
  PHYSICALHEIGHT  = 111; // Physical Height in device units
  PHYSICALOFFSETX = 112; // Physical Printable Area x margin
  PHYSICALOFFSETY = 113; // Physical Printable Area y margin
  SCALINGFACTORX  = 114; // Scaling factor x
  SCALINGFACTORY  = 115; // Scaling factor y

// Display driver specific

  VREFRESH = 116;       // Current vertical refresh rate of the
                        // display device (for displays only) in Hz
  DESKTOPVERTRES = 117; // Horizontal width of entire desktop in
                        // pixels
  DESKTOPHORZRES = 118; // Vertical height of entire desktop in
                        // pixels
  BLTALIGNMENT = 119;   // Preferred blt alignment

  SHADEBLENDCAPS = 120; // Shading and blending caps
  COLORMGMTCAPS  = 121; // Color Management caps

// Device Capability Masks:

// Device Technologies

  DT_PLOTTER    = 0; // Vector plotter
  DT_RASDISPLAY = 1; // Raster display
  DT_RASPRINTER = 2; // Raster printer
  DT_RASCAMERA  = 3; // Raster camera
  DT_CHARSTREAM = 4; // Character-stream, PLP
  DT_METAFILE   = 5; // Metafile, VDM
  DT_DISPFILE   = 6; // Display-file

// Curve Capabilities

  CC_NONE       = 0; // Curves not supported
  CC_CIRCLES    = 1; // Can do circles
  CC_PIE        = 2; // Can do pie wedges
  CC_CHORD      = 4; // Can do chord arcs
  CC_ELLIPSES   = 8; // Can do ellipese
  CC_WIDE       = 16; // Can do wide lines
  CC_STYLED     = 32; // Can do styled lines
  CC_WIDESTYLED = 64; // Can do wide styled lines
  CC_INTERIORS  = 128; // Can do interiors
  CC_ROUNDRECT  = 256;

// Line Capabilities

  LC_NONE       = 0; // Lines not supported
  LC_POLYLINE   = 2; // Can do polylines
  LC_MARKER     = 4; // Can do markers
  LC_POLYMARKER = 8; // Can do polymarkers
  LC_WIDE       = 16; // Can do wide lines
  LC_STYLED     = 32; // Can do styled lines
  LC_WIDESTYLED = 64; // Can do wide styled lines
  LC_INTERIORS  = 128; // Can do interiors

// Polygonal Capabilities

  PC_NONE        = 0; // Polygonals not supported
  PC_POLYGON     = 1; // Can do polygons
  PC_RECTANGLE   = 2; // Can do rectangles
  PC_WINDPOLYGON = 4; // Can do winding polygons
  PC_TRAPEZOID   = 4; // Can do trapezoids
  PC_SCANLINE    = 8; // Can do scanlines
  PC_WIDE        = 16; // Can do wide borders
  PC_STYLED      = 32; // Can do styled borders
  PC_WIDESTYLED  = 64; // Can do wide styled borders
  PC_INTERIORS   = 128; // Can do interiors
  PC_POLYPOLYGON = 256; // Can do polypolygons
  PC_PATHS       = 512; // Can do paths

// Clipping Capabilities

  CP_NONE      = 0; // No clipping of output
  CP_RECTANGLE = 1; // Output clipped to rects
  CP_REGION    = 2; // obsolete

// Text Capabilities

  TC_OP_CHARACTER = $00000001; // Can do OutputPrecision   CHARACTER
  TC_OP_STROKE    = $00000002; // Can do OutputPrecision   STROKE
  TC_CP_STROKE    = $00000004; // Can do ClipPrecision     STROKE
  TC_CR_90        = $00000008; // Can do CharRotAbility    90
  TC_CR_ANY       = $00000010; // Can do CharRotAbility    ANY
  TC_SF_X_YINDEP  = $00000020; // Can do ScaleFreedom      X_YINDEPENDENT
  TC_SA_DOUBLE    = $00000040; // Can do ScaleAbility      DOUBLE
  TC_SA_INTEGER   = $00000080; // Can do ScaleAbility      INTEGER
  TC_SA_CONTIN    = $00000100; // Can do ScaleAbility      CONTINUOUS
  TC_EA_DOUBLE    = $00000200; // Can do EmboldenAbility   DOUBLE
  TC_IA_ABLE      = $00000400; // Can do ItalisizeAbility  ABLE
  TC_UA_ABLE      = $00000800; // Can do UnderlineAbility  ABLE
  TC_SO_ABLE      = $00001000; // Can do StrikeOutAbility  ABLE
  TC_RA_ABLE      = $00002000; // Can do RasterFontAble    ABLE
  TC_VA_ABLE      = $00004000; // Can do VectorFontAble    ABLE
  TC_RESERVED     = $00008000;
  TC_SCROLLBLT    = $00010000; // Don't do text scroll with blt

// Raster Capabilities

  RC_BITBLT       = 1; // Can do standard BLT.
  RC_BANDING      = 2; // Device requires banding support
  RC_SCALING      = 4; // Device requires scaling support
  RC_BITMAP64     = 8; // Device can support >64K bitmap
  RC_GDI20_OUTPUT = $0010; // has 2.0 output calls
  RC_GDI20_STATE  = $0020;
  RC_SAVEBITMAP   = $0040;
  RC_DI_BITMAP    = $0080; // supports DIB to memory
  RC_PALETTE      = $0100; // supports a palette
  RC_DIBTODEV     = $0200; // supports DIBitsToDevice
  RC_BIGFONT      = $0400; // supports >64K fonts
  RC_STRETCHBLT   = $0800; // supports StretchBlt
  RC_FLOODFILL    = $1000; // supports FloodFill
  RC_STRETCHDIB   = $2000; // supports StretchDIBits
  RC_OP_DX_OUTPUT = $4000;
  RC_DEVBITS      = $8000;

// Shading and blending caps

  SB_NONE          = $00000000;
  SB_CONST_ALPHA   = $00000001;
  SB_PIXEL_ALPHA   = $00000002;
  SB_PREMULT_ALPHA = $00000004;

  SB_GRAD_RECT = $00000010;
  SB_GRAD_TRI  = $00000020;

// Color Management caps

  CM_NONE       = $00000000;
  CM_DEVICE_ICM = $00000001;
  CM_GAMMA_RAMP = $00000002;
  CM_CMYK_COLOR = $00000004;

// DIB color table identifiers

  DIB_RGB_COLORS = 0; // color table in RGBs
  DIB_PAL_COLORS = 1; // color table in palette indices

// constants for Get/SetSystemPaletteUse()

  SYSPAL_ERROR       = 0;
  SYSPAL_STATIC      = 1;
  SYSPAL_NOSTATIC    = 2;
  SYSPAL_NOSTATIC256 = 3;

// constants for CreateDIBitmap

  CBM_INIT = $04; // initialize bitmap

// ExtFloodFill style flags

  FLOODFILLBORDER  = 0;
  FLOODFILLSURFACE = 1;

// size of a device name string

  CCHDEVICENAME = 32;

// size of a form name string

  CCHFORMNAME = 32;

type
  TDmDisplayFlagsUnion = record
    case Integer of
      0: (
        dmDisplayFlags: DWORD);
      1: (
        dmNup: DWORD);
  end;

  _devicemodeA = record
    dmDeviceName: array [0..CCHDEVICENAME - 1] of BYTE;
    dmSpecVersion: WORD;
    dmDriverVersion: WORD;
    dmSize: WORD;
    dmDriverExtra: WORD;
    dmFields: DWORD;
    union1: record
    case Integer of
      // printer only fields
      0: (
        dmOrientation: Smallint;
        dmPaperSize: Smallint;
        dmPaperLength: Smallint;
        dmPaperWidth: Smallint;
        dmScale: Smallint;
        dmCopies: Smallint;
        dmDefaultSource: Smallint;
        dmPrintQuality: Smallint);
      // display only fields
      1: (
        dmPosition: POINTL;
        dmDisplayOrientation: DWORD;
        dmDisplayFixedOutput: DWORD);
    end;
    dmColor: Shortint;
    dmDuplex: Shortint;
    dmYResolution: Shortint;
    dmTTOption: Shortint;
    dmCollate: Shortint;
    dmFormName: array [0..CCHFORMNAME - 1] of BYTE;
    dmLogPixels: WORD;
    dmBitsPerPel: DWORD;
    dmPelsWidth: DWORD;
    dmPelsHeight: DWORD;
    dmDisplayFlags: TDmDisplayFlagsUnion;
    dmDisplayFrequency: DWORD;
    dmICMMethod: DWORD;
    dmICMIntent: DWORD;
    dmMediaType: DWORD;
    dmDitherType: DWORD;
    dmReserved1: DWORD;
    dmReserved2: DWORD;
    dmPanningWidth: DWORD;
    dmPanningHeight: DWORD;
  end;
  DEVMODEA = _devicemodeA;
  PDEVMODEA = ^DEVMODEA;
  LPDEVMODEA = ^DEVMODEA;
  NPDEVMODEA = ^DEVMODEA;
  TDevModeA = _devicemodeA;

  _devicemodeW = record
    dmDeviceName: array [0..CCHDEVICENAME - 1] of WCHAR;
    dmSpecVersion: WORD;
    dmDriverVersion: WORD;
    dmSize: WORD;
    dmDriverExtra: WORD;
    dmFields: DWORD;
    union1: record
    case Integer of
      // printer only fields
      0: (
        dmOrientation: Smallint;
        dmPaperSize: Smallint;
        dmPaperLength: Smallint;
        dmPaperWidth: Smallint;
        dmScale: Smallint;
        dmCopies: Smallint;
        dmDefaultSource: Smallint;
        dmPrintQuality: Smallint);
      // display only fields
      1: (
        dmPosition: POINTL;
        dmDisplayOrientation: DWORD;
        dmDisplayFixedOutput: DWORD);
    end;
    dmColor: Shortint;
    dmDuplex: Shortint;
    dmYResolution: Shortint;
    dmTTOption: Shortint;
    dmCollate: Shortint;
    dmFormName: array [0..CCHFORMNAME - 1] of WCHAR;
    dmLogPixels: WORD;
    dmBitsPerPel: DWORD;
    dmPelsWidth: DWORD;
    dmPelsHeight: DWORD;
    dmDiusplayFlags: TDmDisplayFlagsUnion;
    dmDisplayFrequency: DWORD;
    dmICMMethod: DWORD;
    dmICMIntent: DWORD;
    dmMediaType: DWORD;
    dmDitherType: DWORD;
    dmReserved1: DWORD;
    dmReserved2: DWORD;
    dmPanningWidth: DWORD;
    dmPanningHeight: DWORD;
  end;
  DEVMODEW = _devicemodeW;
  PDEVMODEW = ^DEVMODEW;
  LPDEVMODEW = ^DEVMODEW;
  NPDEVMODEW = ^DEVMODEW;
  TDevModeW = _devicemodeW;

  {$IFDEF UNICODE}
  DEVMODE = DEVMODEW;
  PDEVMODE = PDEVMODEW;
  NPDEVMODE = NPDEVMODEW;
  LPDEVMODE = LPDEVMODEW;
  TDevMode = TDevModeW;
  {$ELSE}
  DEVMODE = DEVMODEA;
  PDEVMODE = PDEVMODEA;
  NPDEVMODE = NPDEVMODEA;
  LPDEVMODE = LPDEVMODEA;
  TDevMode = TDevModeA;
  {$ENDIF UNICODE}

// current version of specification

const
  DM_SPECVERSION = $0401;

// field selection bits

const
  DM_ORIENTATION      = $00000001;
  DM_PAPERSIZE        = $00000002;
  DM_PAPERLENGTH      = $00000004;
  DM_PAPERWIDTH       = $00000008;
  DM_SCALE            = $00000010;
  DM_POSITION         = $00000020;
  DM_NUP              = $00000040;
//#if(WINVER >= 0x0501)
  DM_DISPLAYORIENTATION = $00000080;
//#endif /* WINVER >= 0x0501 */
  DM_COPIES           = $00000100;
  DM_DEFAULTSOURCE    = $00000200;
  DM_PRINTQUALITY     = $00000400;
  DM_COLOR            = $00000800;
  DM_DUPLEX           = $00001000;
  DM_YRESOLUTION      = $00002000;
  DM_TTOPTION         = $00004000;
  DM_COLLATE          = $00008000;
  DM_FORMNAME         = $00010000;
  DM_LOGPIXELS        = $00020000;
  DM_BITSPERPEL       = $00040000;
  DM_PELSWIDTH        = $00080000;
  DM_PELSHEIGHT       = $00100000;
  DM_DISPLAYFLAGS     = $00200000;
  DM_DISPLAYFREQUENCY = $00400000;
  DM_ICMMETHOD        = $00800000;
  DM_ICMINTENT        = $01000000;
  DM_MEDIATYPE        = $02000000;
  DM_DITHERTYPE       = $04000000;
  DM_PANNINGWIDTH     = $08000000;
  DM_PANNINGHEIGHT    = $10000000;
//#if(WINVER >= 0x0501)
  DM_DISPLAYFIXEDOUTPUT = $20000000;
//#endif /* WINVER >= 0x0501 */

// orientation selections

  DMORIENT_PORTRAIT  = 1;
  DMORIENT_LANDSCAPE = 2;

// paper selections

  DMPAPER_LETTER                  = 1; // Letter 8 1/2 x 11 in
  DMPAPER_FIRST                   = DMPAPER_LETTER;
  DMPAPER_LETTERSMALL             = 2; // Letter Small 8 1/2 x 11 in
  DMPAPER_TABLOID                 = 3; // Tabloid 11 x 17 in
  DMPAPER_LEDGER                  = 4; // Ledger 17 x 11 in
  DMPAPER_LEGAL                   = 5; // Legal 8 1/2 x 14 in
  DMPAPER_STATEMENT               = 6; // Statement 5 1/2 x 8 1/2 in
  DMPAPER_EXECUTIVE               = 7; // Executive 7 1/4 x 10 1/2 in
  DMPAPER_A3                      = 8; // A3 297 x 420 mm
  DMPAPER_A4                      = 9; // A4 210 x 297 mm
  DMPAPER_A4SMALL                 = 10; // A4 Small 210 x 297 mm
  DMPAPER_A5                      = 11; // A5 148 x 210 mm
  DMPAPER_B4                      = 12; // B4 (JIS) 250 x 354
  DMPAPER_B5                      = 13; // B5 (JIS) 182 x 257 mm
  DMPAPER_FOLIO                   = 14; // Folio 8 1/2 x 13 in
  DMPAPER_QUARTO                  = 15; // Quarto 215 x 275 mm
  DMPAPER_10X14                   = 16; // 10x14 in
  DMPAPER_11X17                   = 17; // 11x17 in
  DMPAPER_NOTE                    = 18; // Note 8 1/2 x 11 in
  DMPAPER_ENV_9                   = 19; // Envelope #9 3 7/8 x 8 7/8
  DMPAPER_ENV_10                  = 20; // Envelope #10 4 1/8 x 9 1/2
  DMPAPER_ENV_11                  = 21; // Envelope #11 4 1/2 x 10 3/8
  DMPAPER_ENV_12                  = 22; // Envelope #12 4 \276 x 11
  DMPAPER_ENV_14                  = 23; // Envelope #14 5 x 11 1/2
  DMPAPER_CSHEET                  = 24; // C size sheet
  DMPAPER_DSHEET                  = 25; // D size sheet
  DMPAPER_ESHEET                  = 26; // E size sheet
  DMPAPER_ENV_DL                  = 27; // Envelope DL 110 x 220mm
  DMPAPER_ENV_C5                  = 28; // Envelope C5 162 x 229 mm
  DMPAPER_ENV_C3                  = 29; // Envelope C3  324 x 458 mm
  DMPAPER_ENV_C4                  = 30; // Envelope C4  229 x 324 mm
  DMPAPER_ENV_C6                  = 31; // Envelope C6  114 x 162 mm
  DMPAPER_ENV_C65                 = 32; // Envelope C65 114 x 229 mm
  DMPAPER_ENV_B4                  = 33; // Envelope B4  250 x 353 mm
  DMPAPER_ENV_B5                  = 34; // Envelope B5  176 x 250 mm
  DMPAPER_ENV_B6                  = 35; // Envelope B6  176 x 125 mm
  DMPAPER_ENV_ITALY               = 36; // Envelope 110 x 230 mm
  DMPAPER_ENV_MONARCH             = 37; // Envelope Monarch 3.875 x 7.5 in
  DMPAPER_ENV_PERSONAL            = 38; // 6 3/4 Envelope 3 5/8 x 6 1/2 in
  DMPAPER_FANFOLD_US              = 39; // US Std Fanfold 14 7/8 x 11 in
  DMPAPER_FANFOLD_STD_GERMAN      = 40; // German Std Fanfold 8 1/2 x 12 in
  DMPAPER_FANFOLD_LGL_GERMAN      = 41; // German Legal Fanfold 8 1/2 x 13 in
  DMPAPER_ISO_B4                  = 42; // B4 (ISO) 250 x 353 mm
  DMPAPER_JAPANESE_POSTCARD       = 43; // Japanese Postcard 100 x 148 mm
  DMPAPER_9X11                    = 44; // 9 x 11 in
  DMPAPER_10X11                   = 45; // 10 x 11 in
  DMPAPER_15X11                   = 46; // 15 x 11 in
  DMPAPER_ENV_INVITE              = 47; // Envelope Invite 220 x 220 mm
  DMPAPER_RESERVED_48             = 48; // RESERVED--DO NOT USE
  DMPAPER_RESERVED_49             = 49; // RESERVED--DO NOT USE
  DMPAPER_LETTER_EXTRA            = 50; // Letter Extra 9 \275 x 12 in
  DMPAPER_LEGAL_EXTRA             = 51; // Legal Extra 9 \275 x 15 in
  DMPAPER_TABLOID_EXTRA           = 52; // Tabloid Extra 11.69 x 18 in
  DMPAPER_A4_EXTRA                = 53; // A4 Extra 9.27 x 12.69 in
  DMPAPER_LETTER_TRANSVERSE       = 54; // Letter Transverse 8 \275 x 11 in
  DMPAPER_A4_TRANSVERSE           = 55; // A4 Transverse 210 x 297 mm
  DMPAPER_LETTER_EXTRA_TRANSVERSE = 56; // Letter Extra Transverse 9\275 x 12 in
  DMPAPER_A_PLUS                  = 57; // SuperA/SuperA/A4 227 x 356 mm
  DMPAPER_B_PLUS                  = 58; // SuperB/SuperB/A3 305 x 487 mm
  DMPAPER_LETTER_PLUS             = 59; // Letter Plus 8.5 x 12.69 in
  DMPAPER_A4_PLUS                 = 60; // A4 Plus 210 x 330 mm
  DMPAPER_A5_TRANSVERSE           = 61; // A5 Transverse 148 x 210 mm
  DMPAPER_B5_TRANSVERSE           = 62; // B5 (JIS) Transverse 182 x 257 mm
  DMPAPER_A3_EXTRA                = 63; // A3 Extra 322 x 445 mm
  DMPAPER_A5_EXTRA                = 64; // A5 Extra 174 x 235 mm
  DMPAPER_B5_EXTRA                = 65; // B5 (ISO) Extra 201 x 276 mm
  DMPAPER_A2                      = 66; // A2 420 x 594 mm
  DMPAPER_A3_TRANSVERSE           = 67; // A3 Transverse 297 x 420 mm
  DMPAPER_A3_EXTRA_TRANSVERSE     = 68; // A3 Extra Transverse 322 x 445 mm

  DMPAPER_DBL_JAPANESE_POSTCARD         = 69; // Japanese Double Postcard 200 x 148 mm
  DMPAPER_A6                            = 70; // A6 105 x 148 mm
  DMPAPER_JENV_KAKU2                    = 71; // Japanese Envelope Kaku #2
  DMPAPER_JENV_KAKU3                    = 72; // Japanese Envelope Kaku #3
  DMPAPER_JENV_CHOU3                    = 73; // Japanese Envelope Chou #3
  DMPAPER_JENV_CHOU4                    = 74; // Japanese Envelope Chou #4
  DMPAPER_LETTER_ROTATED                = 75; // Letter Rotated 11 x 8 1/2 11 in
  DMPAPER_A3_ROTATED                    = 76; // A3 Rotated 420 x 297 mm
  DMPAPER_A4_ROTATED                    = 77; // A4 Rotated 297 x 210 mm
  DMPAPER_A5_ROTATED                    = 78; // A5 Rotated 210 x 148 mm
  DMPAPER_B4_JIS_ROTATED                = 79; // B4 (JIS) Rotated 364 x 257 mm
  DMPAPER_B5_JIS_ROTATED                = 80; // B5 (JIS) Rotated 257 x 182 mm
  DMPAPER_JAPANESE_POSTCARD_ROTATED     = 81; // Japanese Postcard Rotated 148 x 100 mm
  DMPAPER_DBL_JAPANESE_POSTCARD_ROTATED = 82; // Double Japanese Postcard Rotated 148 x 200 mm
  DMPAPER_A6_ROTATED                    = 83; // A6 Rotated 148 x 105 mm
  DMPAPER_JENV_KAKU2_ROTATED            = 84; // Japanese Envelope Kaku #2 Rotated
  DMPAPER_JENV_KAKU3_ROTATED            = 85; // Japanese Envelope Kaku #3 Rotated
  DMPAPER_JENV_CHOU3_ROTATED            = 86; // Japanese Envelope Chou #3 Rotated
  DMPAPER_JENV_CHOU4_ROTATED            = 87; // Japanese Envelope Chou #4 Rotated
  DMPAPER_B6_JIS                        = 88; // B6 (JIS) 128 x 182 mm
  DMPAPER_B6_JIS_ROTATED                = 89; // B6 (JIS) Rotated 182 x 128 mm
  DMPAPER_12X11                         = 90; // 12 x 11 in
  DMPAPER_JENV_YOU4                     = 91; // Japanese Envelope You #4
  DMPAPER_JENV_YOU4_ROTATED             = 92; // Japanese Envelope You #4 Rotated
  DMPAPER_P16K                          = 93; // PRC 16K 146 x 215 mm
  DMPAPER_P32K                          = 94; // PRC 32K 97 x 151 mm
  DMPAPER_P32KBIG                       = 95; // PRC 32K(Big) 97 x 151 mm
  DMPAPER_PENV_1                        = 96; // PRC Envelope #1 102 x 165 mm
  DMPAPER_PENV_2                        = 97; // PRC Envelope #2 102 x 176 mm
  DMPAPER_PENV_3                        = 98; // PRC Envelope #3 125 x 176 mm
  DMPAPER_PENV_4                        = 99; // PRC Envelope #4 110 x 208 mm
  DMPAPER_PENV_5                        = 100; // PRC Envelope #5 110 x 220 mm
  DMPAPER_PENV_6                        = 101; // PRC Envelope #6 120 x 230 mm
  DMPAPER_PENV_7                        = 102; // PRC Envelope #7 160 x 230 mm
  DMPAPER_PENV_8                        = 103; // PRC Envelope #8 120 x 309 mm
  DMPAPER_PENV_9                        = 104; // PRC Envelope #9 229 x 324 mm
  DMPAPER_PENV_10                       = 105; // PRC Envelope #10 324 x 458 mm
  DMPAPER_P16K_ROTATED                  = 106; // PRC 16K Rotated
  DMPAPER_P32K_ROTATED                  = 107; // PRC 32K Rotated
  DMPAPER_P32KBIG_ROTATED               = 108; // PRC 32K(Big) Rotated
  DMPAPER_PENV_1_ROTATED                = 109; // PRC Envelope #1 Rotated 165 x 102 mm
  DMPAPER_PENV_2_ROTATED                = 110; // PRC Envelope #2 Rotated 176 x 102 mm
  DMPAPER_PENV_3_ROTATED                = 111; // PRC Envelope #3 Rotated 176 x 125 mm
  DMPAPER_PENV_4_ROTATED                = 112; // PRC Envelope #4 Rotated 208 x 110 mm
  DMPAPER_PENV_5_ROTATED                = 113; // PRC Envelope #5 Rotated 220 x 110 mm
  DMPAPER_PENV_6_ROTATED                = 114; // PRC Envelope #6 Rotated 230 x 120 mm
  DMPAPER_PENV_7_ROTATED                = 115; // PRC Envelope #7 Rotated 230 x 160 mm
  DMPAPER_PENV_8_ROTATED                = 116; // PRC Envelope #8 Rotated 309 x 120 mm
  DMPAPER_PENV_9_ROTATED                = 117; // PRC Envelope #9 Rotated 324 x 229 mm
  DMPAPER_PENV_10_ROTATED               = 118; // PRC Envelope #10 Rotated 458 x 324 mm

  DMPAPER_LAST = DMPAPER_PENV_10_ROTATED;

  DMPAPER_USER = 256;

// bin selections

  DMBIN_UPPER         = 1;
  DMBIN_FIRST         = DMBIN_UPPER;
  DMBIN_ONLYONE       = 1;
  DMBIN_LOWER         = 2;
  DMBIN_MIDDLE        = 3;
  DMBIN_MANUAL        = 4;
  DMBIN_ENVELOPE      = 5;
  DMBIN_ENVMANUAL     = 6;
  DMBIN_AUTO          = 7;
  DMBIN_TRACTOR       = 8;
  DMBIN_SMALLFMT      = 9;
  DMBIN_LARGEFMT      = 10;
  DMBIN_LARGECAPACITY = 11;
  DMBIN_CASSETTE      = 14;
  DMBIN_FORMSOURCE    = 15;
  DMBIN_LAST          = DMBIN_FORMSOURCE;

  DMBIN_USER = 256; // device specific bins start here

// print qualities

  DMRES_DRAFT  = DWORD(-1);
  DMRES_LOW    = DWORD(-2);
  DMRES_MEDIUM = DWORD(-3);
  DMRES_HIGH   = DWORD(-4);

// color enable/disable for color printers

  DMCOLOR_MONOCHROME = 1;
  DMCOLOR_COLOR      = 2;

// duplex enable

  DMDUP_SIMPLEX    = 1;
  DMDUP_VERTICAL   = 2;
  DMDUP_HORIZONTAL = 3;

// TrueType options

  DMTT_BITMAP           = 1; // print TT fonts as graphics
  DMTT_DOWNLOAD         = 2; // download TT fonts as soft fonts
  DMTT_SUBDEV           = 3; // substitute device fonts for TT fonts
  DMTT_DOWNLOAD_OUTLINE = 4; // download TT fonts as outline soft fonts

// Collation selections

  DMCOLLATE_FALSE = 0;
  DMCOLLATE_TRUE  = 1;

//#if(WINVER >= 0x0501)

// DEVMODE dmDisplayOrientation specifiations

  DMDO_DEFAULT   = 0;
  DMDO_90        = 1;
  DMDO_180       = 2;
  DMDO_270       = 3;

// DEVMODE dmDisplayFixedOutput specifiations

  DMDFO_DEFAULT  = 0;
  DMDFO_STRETCH  = 1;
  DMDFO_CENTER   = 2;

//#endif /* WINVER >= 0x0501 */

// DEVMODE dmDisplayFlags flags

// #define DM_GRAYSCALE            0x00000001 /* This flag is no longer valid */
// #define DM_INTERLACED           0x00000002 /* This flag is no longer valid */

  DMDISPLAYFLAGS_TEXTMODE = $00000004;

// dmNup , multiple logical page per physical page options

  DMNUP_SYSTEM = 1;
  DMNUP_ONEUP  = 2;

// ICM methods

  DMICMMETHOD_NONE   = 1; // ICM disabled
  DMICMMETHOD_SYSTEM = 2; // ICM handled by system
  DMICMMETHOD_DRIVER = 3; // ICM handled by driver
  DMICMMETHOD_DEVICE = 4; // ICM handled by device

  DMICMMETHOD_USER = 256; // Device-specific methods start here

// ICM Intents

  DMICM_SATURATE         = 1; // Maximize color saturation
  DMICM_CONTRAST         = 2; // Maximize color contrast
  DMICM_COLORIMETRIC     = 3; // Use specific color metric
  DMICM_ABS_COLORIMETRIC = 4; // Use specific color metric

  DMICM_USER = 256; // Device-specific intents start here

// Media types

  DMMEDIA_STANDARD     = 1; // Standard paper
  DMMEDIA_TRANSPARENCY = 2; // Transparency
  DMMEDIA_GLOSSY       = 3; // Glossy paper

  DMMEDIA_USER = 256; // Device-specific media start here

// Dither types

  DMDITHER_NONE           = 1; // No dithering
  DMDITHER_COARSE         = 2; // Dither with a coarse brush
  DMDITHER_FINE           = 3; // Dither with a fine brush
  DMDITHER_LINEART        = 4; // LineArt dithering
  DMDITHER_ERRORDIFFUSION = 5; // LineArt dithering
  DMDITHER_RESERVED6      = 6; // LineArt dithering
  DMDITHER_RESERVED7      = 7; // LineArt dithering
  DMDITHER_RESERVED8      = 8; // LineArt dithering
  DMDITHER_RESERVED9      = 9; // LineArt dithering
  DMDITHER_GRAYSCALE      = 10; // Device does grayscaling

  DMDITHER_USER = 256; // Device-specific dithers start here

type
  PDisplayDeviceA = ^TDisplayDeviceA;
  _DISPLAY_DEVICEA = record
    cb: DWORD;
    DeviceName: array [0..32 - 1] of CHAR;
    DeviceString: array [0..128 - 1] of CHAR;
    StateFlags: DWORD;
    DeviceID: array [0..128 - 1] of CHAR;
    DeviceKey: array [0..128 - 1] of CHAR;
  end;
  DISPLAY_DEVICEA = _DISPLAY_DEVICEA;
  LPDISPLAY_DEVICEA = ^DISPLAY_DEVICEA;
  PDISPLAY_DEVICEA = ^DISPLAY_DEVICEA;
  TDisplayDeviceA = _DISPLAY_DEVICEA;

  PDisplayDeviceW = ^TDisplayDeviceW;
  _DISPLAY_DEVICEW = record
    cb: DWORD;
    DeviceName: array [0..32 - 1] of WCHAR;
    DeviceString: array [0..128 - 1] of WCHAR;
    StateFlags: DWORD;
    DeviceID: array [0..128 - 1] of WCHAR;
    DeviceKey: array [0..128 - 1] of WCHAR;
  end;
  DISPLAY_DEVICEW = _DISPLAY_DEVICEW;
  LPDISPLAY_DEVICEW = ^DISPLAY_DEVICEW;
  PDISPLAY_DEVICEW = ^DISPLAY_DEVICEW;
  TDisplayDeviceW = _DISPLAY_DEVICEW;

  {$IFDEF UNICODE}
  DISPLAY_DEVICE = DISPLAY_DEVICEW;
  PDISPLAY_DEVICE = PDISPLAY_DEVICEW;
  LPDISPLAY_DEVICE = LPDISPLAY_DEVICEW;
  TDisplayDevice = TDisplayDeviceW;
  PDisplayDevice = PDisplayDeviceW;
  {$ELSE}
  DISPLAY_DEVICE = DISPLAY_DEVICEA;
  PDISPLAY_DEVICE = PDISPLAY_DEVICEA;
  LPDISPLAY_DEVICE = LPDISPLAY_DEVICEA;
  TDisplayDevice = TDisplayDeviceA;
  PDisplayDevice = PDisplayDeviceA;
  {$ENDIF UNICODE}

const
  DISPLAY_DEVICE_ATTACHED_TO_DESKTOP = $00000001;
  DISPLAY_DEVICE_MULTI_DRIVER        = $00000002;
  DISPLAY_DEVICE_PRIMARY_DEVICE      = $00000004;
  DISPLAY_DEVICE_MIRRORING_DRIVER    = $00000008;
  DISPLAY_DEVICE_VGA_COMPATIBLE      = $00000010;
  DISPLAY_DEVICE_REMOVABLE           = $00000020;
  DISPLAY_DEVICE_MODESPRUNED         = $08000000;
  DISPLAY_DEVICE_REMOTE              = $04000000;
  DISPLAY_DEVICE_DISCONNECT          = $02000000;

// Child device state

  DISPLAY_DEVICE_ACTIVE              = $00000001;
  DISPLAY_DEVICE_ATTACHED            = $00000002;

// GetRegionData/ExtCreateRegion

  RDH_RECTANGLES = 1;

type
  PRgnDataHeader = ^TRgnDataHeader;
  _RGNDATAHEADER = record
    dwSize: DWORD;
    iType: DWORD;
    nCount: DWORD;
    nRgnSize: DWORD;
    rcBound: RECT;
  end;
  RGNDATAHEADER = _RGNDATAHEADER;
  TRgnDataHeader = _RGNDATAHEADER;

  PRgnData = ^TRgnData;
  _RGNDATA = record
    rdh: RGNDATAHEADER;
    Buffer: array [0..0] of Char;
  end;
  RGNDATA = _RGNDATA;
  LPRGNDATA = ^RGNDATA;
  NPRGNDATA = ^RGNDATA;
  TRgnData = _RGNDATA;

// for GetRandomRgn

const
  SYSRGN = 4;

type
  PAbc = ^TAbc;
  _ABC = record
    abcA: Integer;
    abcB: UINT;
    abcC: Integer;
  end;
  ABC = _ABC;
  LPABC = ^ABC;
  NPABC = ^ABC;
  TAbc = _ABC;

  PAbcFloat = ^TAbcFloat;
  _ABCFLOAT = record
    abcfA: FLOAT;
    abcfB: FLOAT;
    abcfC: FLOAT;
  end;
  ABCFLOAT = _ABCFLOAT;
  LPABCFLOAT = ^ABCFLOAT;
  NPABCFLOAT = ^ABCFLOAT;
  TAbcFloat = _ABCFLOAT;

  POutlineTextMetricA = ^TOutlineTextMetricA;
  _OUTLINETEXTMETRICA = record
    otmSize: UINT;
    otmTextMetrics: TEXTMETRICA;
    otmFiller: BYTE;
    otmPanoseNumber: PANOSE;
    otmfsSelection: UINT;
    otmfsType: UINT;
    otmsCharSlopeRise: Integer;
    otmsCharSlopeRun: Integer;
    otmItalicAngle: Integer;
    otmEMSquare: UINT;
    otmAscent: Integer;
    otmDescent: Integer;
    otmLineGap: UINT;
    otmsCapEmHeight: UINT;
    otmsXHeight: UINT;
    otmrcFontBox: RECT;
    otmMacAscent: Integer;
    otmMacDescent: Integer;
    otmMacLineGap: UINT;
    otmusMinimumPPEM: UINT;
    otmptSubscriptSize: POINT;
    otmptSubscriptOffset: POINT;
    otmptSuperscriptSize: POINT;
    otmptSuperscriptOffset: POINT;
    otmsStrikeoutSize: UINT;
    otmsStrikeoutPosition: Integer;
    otmsUnderscoreSize: Integer;
    otmsUnderscorePosition: Integer;
    otmpFamilyName: PSTR;
    otmpFaceName: PSTR;
    otmpStyleName: PSTR;
    otmpFullName: PSTR;
  end;
  OUTLINETEXTMETRICA = _OUTLINETEXTMETRICA;
  LPOUTLINETEXTMETRICA = ^OUTLINETEXTMETRICA;
  NPOUTLINETEXTMETRICA = ^OUTLINETEXTMETRICA;
  TOutlineTextMetricA = _OUTLINETEXTMETRICA;

  POutlineTextMetricW = ^TOutlineTextMetricW;
  _OUTLINETEXTMETRICW = record
    otmSize: UINT;
    otmTextMetrics: TEXTMETRICW;
    otmFiller: BYTE;
    otmPanoseNumber: PANOSE;
    otmfsSelection: UINT;
    otmfsType: UINT;
    otmsCharSlopeRise: Integer;
    otmsCharSlopeRun: Integer;
    otmItalicAngle: Integer;
    otmEMSquare: UINT;
    otmAscent: Integer;
    otmDescent: Integer;
    otmLineGap: UINT;
    otmsCapEmHeight: UINT;
    otmsXHeight: UINT;
    otmrcFontBox: RECT;
    otmMacAscent: Integer;
    otmMacDescent: Integer;
    otmMacLineGap: UINT;
    otmusMinimumPPEM: UINT;
    otmptSubscriptSize: POINT;
    otmptSubscriptOffset: POINT;
    otmptSuperscriptSize: POINT;
    otmptSuperscriptOffset: POINT;
    otmsStrikeoutSize: UINT;
    otmsStrikeoutPosition: Integer;
    otmsUnderscoreSize: Integer;
    otmsUnderscorePosition: Integer;
    otmpFamilyName: PSTR;
    otmpFaceName: PSTR;
    otmpStyleName: PSTR;
    otmpFullName: PSTR;
  end;
  OUTLINETEXTMETRICW = _OUTLINETEXTMETRICW;
  LPOUTLINETEXTMETRICW = ^OUTLINETEXTMETRICW;
  NPOUTLINETEXTMETRICW = ^OUTLINETEXTMETRICW;
  TOutlineTextMetricW = _OUTLINETEXTMETRICW;

  {$IFDEF UNICODE}
  OUTLINETEXTMETRIC = OUTLINETEXTMETRICW;
  POUTLINETEXTMETRIC = POUTLINETEXTMETRICW;
  NPOUTLINETEXTMETRIC = NPOUTLINETEXTMETRICW;
  LPOUTLINETEXTMETRIC = LPOUTLINETEXTMETRICW;
  TOutlineTextMetric = TOutlineTextMetricW;
  {$ELSE}
  OUTLINETEXTMETRIC = OUTLINETEXTMETRICA;
  POUTLINETEXTMETRIC = POUTLINETEXTMETRICA;
  NPOUTLINETEXTMETRIC = NPOUTLINETEXTMETRICA;
  LPOUTLINETEXTMETRIC = LPOUTLINETEXTMETRICA;
  TOutlineTextMetric = TOutlineTextMetricA;
  {$ENDIF UNICODE}

  PPolytextA = ^TPolytextA;
  tagPOLYTEXTA = record
    x: Integer;
    y: Integer;
    n: UINT;
    lpstr: LPCSTR;
    uiFlags: UINT;
    rcl: RECT;
    pdx: PINT;
  end;
  POLYTEXTA = tagPOLYTEXTA;
  LPPOLYTEXTA = ^POLYTEXTA;
  NPPOLYTEXTA = ^POLYTEXTA;
  TPolytextA = POLYTEXTA;

  PPolytextW = ^TPolytextW;
  tagPOLYTEXTW = record
    x: Integer;
    y: Integer;
    n: UINT;
    lpstr: LPCWSTR;
    uiFlags: UINT;
    rcl: RECT;
    pdx: PINT;
  end;
  POLYTEXTW = tagPOLYTEXTW;
  LPPOLYTEXTW = ^POLYTEXTW;
  NPPOLYTEXTW = ^POLYTEXTW;
  TPolytextW = POLYTEXTW;

  {$IFDEF UNICODE}
  POLYTEXT = POLYTEXTW;
  PPOLYTEXT = PPOLYTEXTW;
  NPPOLYTEXT = NPPOLYTEXTW;
  LPPOLYTEXT = LPPOLYTEXTW;
  TPolyText = TPolyTextW;
  {$ELSE}
  POLYTEXT = POLYTEXTA;
  PPOLYTEXT = PPOLYTEXTA;
  NPPOLYTEXT = NPPOLYTEXTA;
  LPPOLYTEXT = LPPOLYTEXTA;
  TPolyText = TPolyTextA;
  {$ENDIF UNICODE}

  PFixed = ^TFixed;
  _FIXED = record
    fract: WORD;
    value: short;
  end;
  FIXED = _FIXED;
  TFixed = _FIXED;

  PMat2 = ^TMat2;
  _MAT2 = record
    eM11: FIXED;
    eM12: FIXED;
    eM21: FIXED;
    eM22: FIXED;
  end;
  MAT2 = _MAT2;
  LPMAT2 = ^MAT2;
  TMat2 = _MAT2;

  PGlyphMetrics = ^TGlyphMetrics;
  _GLYPHMETRICS = record
    gmBlackBoxX: UINT;
    gmBlackBoxY: UINT;
    gmptGlyphOrigin: POINT;
    gmCellIncX: short;
    gmCellIncY: short;
  end;
  GLYPHMETRICS = _GLYPHMETRICS;
  LPGLYPHMETRICS = ^GLYPHMETRICS;
  TGlyphMetrics = _GLYPHMETRICS;

//  GetGlyphOutline constants

const
  GGO_METRICS = 0;
  GGO_BITMAP  = 1;
  GGO_NATIVE  = 2;
  GGO_BEZIER  = 3;

  GGO_GRAY2_BITMAP = 4;
  GGO_GRAY4_BITMAP = 5;
  GGO_GRAY8_BITMAP = 6;
  GGO_GLYPH_INDEX  = $0080;

  GGO_UNHINTED = $0100;

  TT_POLYGON_TYPE = 24;

  TT_PRIM_LINE    = 1;
  TT_PRIM_QSPLINE = 2;
  TT_PRIM_CSPLINE = 3;

type
  PPointFx = ^TPointFx;
  tagPOINTFX = record
    x: FIXED;
    y: FIXED;
  end;
  POINTFX = tagPOINTFX;
  LPPOINTFX = ^POINTFX;
  TPointFx = POINTFX;

  PTtPolyCurve = ^TTtPolyCurve;
  tagTTPOLYCURVE = record
    wType: WORD;
    cpfx: WORD;
    apfx: array [0..0] of POINTFX;
  end;
  TTPOLYCURVE = tagTTPOLYCURVE;
  LPTTPOLYCURVE = ^TTPOLYCURVE;
  TTtPolyCurve = TTPOLYCURVE;

  PTtPolygonHeader = ^TTtPolygonHeader;
  tagTTPOLYGONHEADER = record
    cb: DWORD;
    dwType: DWORD;
    pfxStart: POINTFX;
  end;
  TTPOLYGONHEADER = tagTTPOLYGONHEADER;
  LPTTPOLYGONHEADER = ^TTPOLYGONHEADER;
  TTtPolygonHeader = TTPOLYGONHEADER;

const
  GCP_DBCS       = $0001;
  GCP_REORDER    = $0002;
  GCP_USEKERNING = $0008;
  GCP_GLYPHSHAPE = $0010;
  GCP_LIGATE     = $0020;
////#define GCP_GLYPHINDEXING  0x0080
  GCP_DIACRITIC = $0100;
  GCP_KASHIDA   = $0400;
  GCP_ERROR     = $8000;
  FLI_MASK      = $103B;

  GCP_JUSTIFY = $00010000;
////#define GCP_NODIACRITICS   0x00020000L
  FLI_GLYPHS          = $00040000;
  GCP_CLASSIN         = $00080000;
  GCP_MAXEXTENT       = $00100000;
  GCP_JUSTIFYIN       = $00200000;
  GCP_DISPLAYZWG      = $00400000;
  GCP_SYMSWAPOFF      = $00800000;
  GCP_NUMERICOVERRIDE = $01000000;
  GCP_NEUTRALOVERRIDE = $02000000;
  GCP_NUMERICSLATIN   = $04000000;
  GCP_NUMERICSLOCAL   = $08000000;

  GCPCLASS_LATIN                  = 1;
  GCPCLASS_HEBREW                 = 2;
  GCPCLASS_ARABIC                 = 2;
  GCPCLASS_NEUTRAL                = 3;
  GCPCLASS_LOCALNUMBER            = 4;
  GCPCLASS_LATINNUMBER            = 5;
  GCPCLASS_LATINNUMERICTERMINATOR = 6;
  GCPCLASS_LATINNUMERICSEPARATOR  = 7;
  GCPCLASS_NUMERICSEPARATOR       = 8;
  GCPCLASS_PREBOUNDLTR            = $80;
  GCPCLASS_PREBOUNDRTL            = $40;
  GCPCLASS_POSTBOUNDLTR           = $20;
  GCPCLASS_POSTBOUNDRTL           = $10;

  GCPGLYPH_LINKBEFORE = $8000;
  GCPGLYPH_LINKAFTER  = $4000;

type
  PGcpResultsA = ^TGcpResultsA;
  tagGCP_RESULTSA = record
    lStructSize: DWORD;
    lpOutString: LPSTR;
    lpOrder: LPUINT;
    lpDx: PINT;
    lpCaretPos: PINT;
    lpClass: LPSTR;
    lpGlyphs: LPWSTR;
    nGlyphs: UINT;
    nMaxFit: Integer;
  end;
  GCP_RESULTSA = tagGCP_RESULTSA;
  LPGCP_RESULTSA = ^GCP_RESULTSA;
  TGcpResultsA = GCP_RESULTSA;

  PGcpResultsW = ^TGcpResultsW;
  tagGCP_RESULTSW = record
    lStructSize: DWORD;
    lpOutString: LPWSTR;
    lpOrder: LPUINT;
    lpDx: PINT;
    lpCaretPos: PINT;
    lpClass: LPSTR;
    lpGlyphs: LPWSTR;
    nGlyphs: UINT;
    nMaxFit: Integer;
  end;
  GCP_RESULTSW = tagGCP_RESULTSW;
  LPGCP_RESULTSW = ^GCP_RESULTSW;
  TGcpResultsW = GCP_RESULTSW;

  {$IFDEF UNICODE}
  GCP_RESULTS = GCP_RESULTSW;
  LPGCP_RESULTS = LPGCP_RESULTSW;
  TGcpResults = TGcpResultsW;
  PGcpResults = PGcpResultsW;
  {$ELSE}
  GCP_RESULTS = GCP_RESULTSA;
  LPGCP_RESULTS = LPGCP_RESULTSA;
  TGcpResults = TGcpResultsA;
  PGcpResults = PGcpResultsA;
  {$ENDIF UNICODE}

  PRasterizerStatus = ^TRasterizerStatus;
  _RASTERIZER_STATUS = record
    nSize: short;
    wFlags: short;
    nLanguageID: short;
  end;
  RASTERIZER_STATUS = _RASTERIZER_STATUS;
  LPRASTERIZER_STATUS = ^RASTERIZER_STATUS;
  TRasterizerStatus = _RASTERIZER_STATUS;

// bits defined in wFlags of RASTERIZER_STATUS

const
  TT_AVAILABLE = $0001;
  TT_ENABLED   = $0002;

// Pixel format descriptor

type
  PPixelFormatDescriptor = ^TPixelFormatDescriptor;
  tagPIXELFORMATDESCRIPTOR = record
    nSize: WORD;
    nVersion: WORD;
    dwFlags: DWORD;
    iPixelType: BYTE;
    cColorBits: BYTE;
    cRedBits: BYTE;
    cRedShift: BYTE;
    cGreenBits: BYTE;
    cGreenShift: BYTE;
    cBlueBits: BYTE;
    cBlueShift: BYTE;
    cAlphaBits: BYTE;
    cAlphaShift: BYTE;
    cAccumBits: BYTE;
    cAccumRedBits: BYTE;
    cAccumGreenBits: BYTE;
    cAccumBlueBits: BYTE;
    cAccumAlphaBits: BYTE;
    cDepthBits: BYTE;
    cStencilBits: BYTE;
    cAuxBuffers: BYTE;
    iLayerType: BYTE;
    bReserved: BYTE;
    dwLayerMask: DWORD;
    dwVisibleMask: DWORD;
    dwDamageMask: DWORD;
  end;
  PIXELFORMATDESCRIPTOR = tagPIXELFORMATDESCRIPTOR;
  LPPIXELFORMATDESCRIPTOR = ^PIXELFORMATDESCRIPTOR;
  TPixelFormatDescriptor = PIXELFORMATDESCRIPTOR;

// pixel types

const
  PFD_TYPE_RGBA       = 0;
  PFD_TYPE_COLORINDEX = 1;

// layer types

  PFD_MAIN_PLANE     = 0;
  PFD_OVERLAY_PLANE  = 1;
  PFD_UNDERLAY_PLANE = DWORD(-1);

// PIXELFORMATDESCRIPTOR flags

  PFD_DOUBLEBUFFER        = $00000001;
  PFD_STEREO              = $00000002;
  PFD_DRAW_TO_WINDOW      = $00000004;
  PFD_DRAW_TO_BITMAP      = $00000008;
  PFD_SUPPORT_GDI         = $00000010;
  PFD_SUPPORT_OPENGL      = $00000020;
  PFD_GENERIC_FORMAT      = $00000040;
  PFD_NEED_PALETTE        = $00000080;
  PFD_NEED_SYSTEM_PALETTE = $00000100;
  PFD_SWAP_EXCHANGE       = $00000200;
  PFD_SWAP_COPY           = $00000400;
  PFD_SWAP_LAYER_BUFFERS  = $00000800;
  PFD_GENERIC_ACCELERATED = $00001000;
  PFD_SUPPORT_DIRECTDRAW  = $00002000;

// PIXELFORMATDESCRIPTOR flags for use in ChoosePixelFormat only

  PFD_DEPTH_DONTCARE        = DWORD($20000000);
  PFD_DOUBLEBUFFER_DONTCARE = DWORD($40000000);
  PFD_STEREO_DONTCARE       = DWORD($80000000);

type
  OLDFONTENUMPROCA = function(lpelf: LPLOGFONTA; lpntm: LPTEXTMETRICA; FontType: DWORD; lParam: LPARAM): Integer; stdcall;
  OLDFONTENUMPROCW = function(lpelf: LPLOGFONTW; lpntm: LPTEXTMETRICW; FontType: DWORD; lParam: LPARAM): Integer; stdcall;
  OLDFONTENUMPROC = function(lpelf: LPLOGFONT; lpntm: LPTEXTMETRIC; FontType: DWORD; lParam: LPARAM): Integer; stdcall;

  FONTENUMPROCA = OLDFONTENUMPROCA;
  FONTENUMPROCW = OLDFONTENUMPROCW;
  FONTENUMPROC = OLDFONTENUMPROC;

  GOBJENUMPROC = function(lpLogObject: LPVOID; lpData: LPARAM): Integer; stdcall;
  LINEDDAPROC = procedure(X, Y: Integer; lpData: LPARAM); stdcall;

function AddFontResourceA(lpszFileName: LPCSTR): Integer; stdcall;
function AddFontResourceW(lpszFileName: LPCWSTR): Integer; stdcall;
function AddFontResource(lpszFileName: LPCTSTR): Integer; stdcall;

function AnimatePalette(hPal: HPALETTE; iStartIndex: UINT; cEntries: UINT; ppe: PPALETTEENTRY): BOOL; stdcall;
function Arc(hdc: HDC; nLeftRect, nTopRect, nRightRect, nBottomRect, nxStartArc, nyStartArc, nXEndArc, nYEndArc: Integer): BOOL; stdcall;
function BitBlt(hdcDEst: HDC; nXDest, nYDest, nWidth, nHeight: Integer; hdcSrc: HDC; nXSrc, nYSrc: Integer; dwRop: DWORD): BOOL; stdcall;
function CancelDC(hdc: HDC): BOOL; stdcall;
function Chord(hdc: HDC; nLeftRect, nTopRect, nRightRect, nBottomRect, nXRadial1, nYRadial1, nXRadial2, nYRadial2: Integer): BOOL; stdcall;
function ChoosePixelFormat(hdc: HDC; const ppfd: PIXELFORMATDESCRIPTOR): Integer; stdcall;
function CloseMetaFile(hdc: HDC): HMETAFILE; stdcall;
function CombineRgn(hrgnDest, hrgnSrc1, hrgnSrc2: HRGN; fnCombineMode: Integer): Integer; stdcall;
function CopyMetaFileA(hmfSrc: HMETAFILE; lpszFile: LPCSTR): HMETAFILE; stdcall;
function CopyMetaFileW(hmfSrc: HMETAFILE; lpszFile: LPCWSTR): HMETAFILE; stdcall;
function CopyMetaFile(hmfSrc: HMETAFILE; lpszFile: LPCTSTR): HMETAFILE; stdcall;
function CreateBitmap(nWidth, nHeight: Integer; Cplanes, cBitsPerPel: UINT; lpvBits: PVOID): HBITMAP; stdcall;
function CreateBitmapIndirect(const lpbm: BITMAP): HBITMAP; stdcall;
function CreateBrushIndirect(const lplb: LOGBRUSH): HBRUSH; stdcall;
function CreateCompatibleBitmap(hdc: HDC; nWidth, nHeight: Integer): HBITMAP; stdcall;
function CreateDiscardableBitmap(hdc: HDC; nWidth, nHeight: Integer): HBITMAP; stdcall;
function CreateCompatibleDC(hdc: HDC): HDC; stdcall;
function CreateDCA(lpszDriver, lpszDevice, lpszOutput: LPCSTR; lpInitData: LPDEVMODEA): HDC; stdcall;
function CreateDCW(lpszDriver, lpszDevice, lpszOutput: LPCWSTR; lpInitData: LPDEVMODEW): HDC; stdcall;
function CreateDC(lpszDriver, lpszDevice, lpszOutput: LPCTSTR; lpInitData: LPDEVMODE): HDC; stdcall;
function CreateDIBitmap(hdc: HDC; const lpbmih: BITMAPINFOHEADER; fdwInit: DWORD; lpbInit: PVOID; const lpbmi: BITMAPINFO; fuUsage: UINT): HBITMAP; stdcall;
function CreateDIBPatternBrush(hglbDIBPacked: HGLOBAL; fuColorSpec: UINT): HBRUSH; stdcall;
function CreateDIBPatternBrushPt(lpPackedDIB: PVOID; iUsage: UINT): HBRUSH; stdcall;
function CreateEllipticRgn(nLeftRect, nTopRect, nRightRect, nBottomRect: Integer): HRGN; stdcall;
function CreateEllipticRgnIndirect(const lprc: RECT): HRGN; stdcall;
function CreateFontIndirectA(const lplf: LOGFONTA): HFONT; stdcall;
function CreateFontIndirectW(const lplf: LOGFONTW): HFONT; stdcall;
function CreateFontIndirect(const lplf: LOGFONT): HFONT; stdcall;
function CreateFontA(nHeight, nWidth, nEscapement, nOrientation, fnWeight: Integer; fdwItalic, fdwUnderline, fdwStrikeOut, fdwCharSet, fdwOutputPrecision, fdwClipPrecision, fdwQuality, fdwPitchAndFamily: DWORD; lpszFace: LPCSTR): HFONT; stdcall;
function CreateFontW(nHeight, nWidth, nEscapement, nOrientation, fnWeight: Integer; fdwItalic, fdwUnderline, fdwStrikeOut, fdwCharSet, fdwOutputPrecision, fdwClipPrecision, fdwQuality, fdwPitchAndFamily: DWORD; lpszFace: LPCWSTR): HFONT; stdcall;
function CreateFont(nHeight, nWidth, nEscapement, nOrientation, fnWeight: Integer; fdwItalic, fdwUnderline, fdwStrikeOut, fdwCharSet, fdwOutputPrecision, fdwClipPrecision, fdwQuality, fdwPitchAndFamily: DWORD; lpszFace: LPCTSTR): HFONT; stdcall;
function CreateHatchBrush(fnStyle: Integer; clrref: COLORREF): HBRUSH; stdcall;
function CreateICA(lpszDriver, lpszDevice, lpszOutput: LPCSTR; lpdvmInit: LPDEVMODEA): HDC; stdcall;
function CreateICW(lpszDriver, lpszDevice, lpszOutput: LPCWSTR; lpdvmInit: LPDEVMODEW): HDC; stdcall;
function CreateIC(lpszDriver, lpszDevice, lpszOutput: LPCWSTR; lpdvmInit: LPDEVMODE): HDC; stdcall;
function CreateMetaFileA(lpszFile: LPCSTR): HDC; stdcall;
function CreateMetaFileW(lpszFile: LPCWSTR): HDC; stdcall;
function CreateMetaFile(lpszFile: LPCTSTR): HDC; stdcall;
function CreatePalette(const lplgpl: LOGPALETTE): HPALETTE; stdcall;
function CreatePen(fnPenStyle, nWidth: Integer; crColor: COLORREF): HPEN; stdcall;
function CreatePenIndirect(const lplgpn: LOGPEN): HPEN; stdcall;
function CreatePolyPolygonRgn(lppt: LPPOINT; lpPolyCounts: LPINT; nCount, fnPolyFillMode: Integer): HRGN; stdcall;
function CreatePatternBrush(hbmp: HBITMAP): HBRUSH; stdcall;
function CreateRectRgn(nLeftRect, nTopRect, nRightRect, nBottomRect: Integer): HRGN; stdcall;
function CreateRectRgnIndirect(const lprc: RECT): HRGN; stdcall;
function CreateRoundRectRgn(nLeftRect, nTopRect, nRightRect, nBottomRect, nWidthEllipse, nHeightEllipse: Integer): HRGN; stdcall;
function CreateScalableFontResourceA(fdwHidden: DWORD; lpszFontRes, lpszFontFile, lpszCurrentPath: LPCSTR): BOOL; stdcall;
function CreateScalableFontResourceW(fdwHidden: DWORD; lpszFontRes, lpszFontFile, lpszCurrentPath: LPCWSTR): BOOL; stdcall;
function CreateScalableFontResource(fdwHidden: DWORD; lpszFontRes, lpszFontFile, lpszCurrentPath: LPCTSTR): BOOL; stdcall;
function CreateSolidBrush(crColor: COLORREF): HBRUSH; stdcall;
function DeleteDC(hdc: HDC): BOOL; stdcall;
function DeleteMetaFile(hmf: HMETAFILE): BOOL; stdcall;
function DeleteObject(hObject: HGDIOBJ): BOOL; stdcall;
function DescribePixelFormat(hdc: HDC; iPixelFormat: Integer; nBytes: UINT; ppfd: LPPIXELFORMATDESCRIPTOR): Integer; stdcall;

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

  DC_FIELDS            = 1;
  DC_PAPERS            = 2;
  DC_PAPERSIZE         = 3;
  DC_MINEXTENT         = 4;
  DC_MAXEXTENT         = 5;
  DC_BINS              = 6;
  DC_DUPLEX            = 7;
  DC_SIZE              = 8;
  DC_EXTRA             = 9;
  DC_VERSION           = 10;
  DC_DRIVER            = 11;
  DC_BINNAMES          = 12;
  DC_ENUMRESOLUTIONS   = 13;
  DC_FILEDEPENDENCIES  = 14;
  DC_TRUETYPE          = 15;
  DC_PAPERNAMES        = 16;
  DC_ORIENTATION       = 17;
  DC_COPIES            = 18;
  DC_BINADJUST         = 19;
  DC_EMF_COMPLIANT     = 20;
  DC_DATATYPE_PRODUCED = 21;
  DC_COLLATE           = 22;
  DC_MANUFACTURER      = 23;
  DC_MODEL             = 24;

  DC_PERSONALITY    = 25;
  DC_PRINTRATE      = 26;
  DC_PRINTRATEUNIT  = 27;
  PRINTRATEUNIT_PPM = 1;
  PRINTRATEUNIT_CPS = 2;
  PRINTRATEUNIT_LPM = 3;
  PRINTRATEUNIT_IPM = 4;
  DC_PRINTERMEM     = 28;
  DC_MEDIAREADY     = 29;
  DC_STAPLE         = 30;
  DC_PRINTRATEPPM   = 31;
  DC_COLORDEVICE    = 32;
  DC_NUP            = 33;
  DC_MEDIATYPENAMES = 34;
  DC_MEDIATYPES     = 35;

// bit fields of the return value (DWORD) for DC_TRUETYPE

  DCTT_BITMAP           = $0000001;
  DCTT_DOWNLOAD         = $0000002;
  DCTT_SUBDEV           = $0000004;
  DCTT_DOWNLOAD_OUTLINE = $0000008;

// return values for DC_BINADJUST

  DCBA_FACEUPNONE     = $0000;
  DCBA_FACEUPCENTER   = $0001;
  DCBA_FACEUPLEFT     = $0002;
  DCBA_FACEUPRIGHT    = $0003;
  DCBA_FACEDOWNNONE   = $0100;
  DCBA_FACEDOWNCENTER = $0101;
  DCBA_FACEDOWNLEFT   = $0102;
  DCBA_FACEDOWNRIGHT  = $0103;

function DeviceCapabilitiesA(pDevice, pPort: LPCSTR; fwCapability: WORD; pOutput: LPSTR; pDevMode: LPDEVMODEA): Integer; stdcall;
function DeviceCapabilitiesW(pDevice, pPort: LPCWSTR; fwCapability: WORD; pOutput: LPWSTR; pDevMode: LPDEVMODEW): Integer; stdcall;
function DeviceCapabilities(pDevice, pPort: LPCTSTR; fwCapability: WORD; pOutput: LPTSTR; pDevMode: LPDEVMODE): Integer; stdcall;
function DrawEscape(hdc: HDC; nEscape, cbInput: Integer; lpszInData: LPCSTR): Integer; stdcall;
function Ellipse(hdc: HDC; nLeftRect, nTopRect, nRightRect, nBottomRect: Integer): BOOL; stdcall;
function EnumFontFamiliesExA(hdc: HDC; lpLogFont: LPLOGFONTA; lpEnumFontFamExProc: FONTENUMPROCA; lParam: LPARAM; dwFlags: DWORD): Integer; stdcall;
function EnumFontFamiliesExW(hdc: HDC; lpLogFont: LPLOGFONTW; lpEnumFontFamExProc: FONTENUMPROCW; lParam: LPARAM; dwFlags: DWORD): Integer; stdcall;
function EnumFontFamiliesEx(hdc: HDC; lpLogFont: LPLOGFONT; lpEnumFontFamExProc: FONTENUMPROC; lParam: LPARAM; dwFlags: DWORD): Integer; stdcall;

function EnumFontFamiliesA(hdc: HDC; lpszFamily: LPCSTR; lpEnumFontFamProc: FONTENUMPROCA; lParam: LPARAM): Integer; stdcall;
function EnumFontFamiliesW(hdc: HDC; lpszFamily: LPCWSTR; lpEnumFontFamProc: FONTENUMPROCW; lParam: LPARAM): Integer; stdcall;
function EnumFontFamilies(hdc: HDC; lpszFamily: LPCTSTR; lpEnumFontFamProc: FONTENUMPROC; lParam: LPARAM): Integer; stdcall;

function EnumFontsA(hdc: HDC; lpFaceName: LPCSTR; lpFontFunc: FONTENUMPROCA; lParam: LPARAM): Integer; stdcall;
function EnumFontsW(hdc: HDC; lpFaceName: LPCWSTR; lpFontFunc: FONTENUMPROCW; lParam: LPARAM): Integer; stdcall;
function EnumFonts(hdc: HDC; lpFaceName: LPCTSTR; lpFontFunc: FONTENUMPROC; lParam: LPARAM): Integer; stdcall;

function EnumObjects(hdc: HDC; mObjectType: Integer; lpObjectFunc: GOBJENUMPROC; lParam: LPARAM): Integer; stdcall;

function EqualRgn(hSrcRgn1, hSrcRgn2: HRGN): BOOL; stdcall;
function Escape(hdc: HDC; nEscape, cbInput: Integer; lpvInData: LPCSTR; lpvOutData: LPVOID): Integer; stdcall;
function ExtEscape(hdc: HDC; nEscape, cbInput: Integer; lpszInData: LPCSTR; cbOutput: Integer; lpszOutData: LPSTR): Integer; stdcall;
function ExcludeClipRect(hdc: HDC; nLeftRect, nTopRect, nRightRect, nBottomRect: Integer): Integer; stdcall;
function ExtCreateRegion(lpXForm: LPXFORM; nCount: DWORD; lpRgnData: LPRGNDATA): HRGN; stdcall;
function ExtFloodFill(hdc: HDC; nXStart, nYStart: Integer; crColor: COLORREF; fuFillType: UINT): BOOL; stdcall;
function FillRgn(hdc: HDC; hrgn: HRGN; hbr: HBRUSH): BOOL; stdcall;
function FloodFill(hdc: HDC; nXStart, nYStart: Integer; crFill: COLORREF): BOOL; stdcall;
function FrameRgn(hdc: HDC; hrgn: HRGN; hbr: HBRUSH; nWidth, nHeight: Integer): BOOL; stdcall;
function GetROP2(hdc: HDC): Integer; stdcall;
function GetAspectRatioFilterEx(hdc: HDC; var lpAspectRatio: TSize): BOOL; stdcall;
function GetBkColor(hdc: HDC): COLORREF; stdcall;

function GetDCBrushColor(hdc: HDC): COLORREF; stdcall;
function GetDCPenColor(hdc: HDC): COLORREF; stdcall;

function GetBkMode(hdc: HDC): Integer; stdcall;
function GetBitmapBits(hbmp: HBITMAP; cbBuffer: LONG; lpvBits: LPVOID): LONG; stdcall;
function GetBitmapDimensionEx(hBitmap: HBITMAP; var lpDimension: TSize): BOOL; stdcall;
function GetBoundsRect(hdc: HDC; var lprcBounds: RECT; flags: UINT): UINT; stdcall;

function GetBrushOrgEx(hdc: HDC; var lppt: POINT): BOOL; stdcall;

function GetCharWidthA(hdc: HDC; iFirstChar, iLastChar: UINT; lpBuffer: LPINT): BOOL; stdcall;
function GetCharWidthW(hdc: HDC; iFirstChar, iLastChar: UINT; lpBuffer: LPINT): BOOL; stdcall;
function GetCharWidth(hdc: HDC; iFirstChar, iLastChar: UINT; lpBuffer: LPINT): BOOL; stdcall;
function GetCharWidth32A(hdc: HDC; iFirstChar, iLastChar: UINT; lpBuffer: LPINT): BOOL; stdcall;
function GetCharWidth32W(hdc: HDC; iFirstChar, iLastChar: UINT; lpBuffer: LPINT): BOOL; stdcall;
function GetCharWidth32(hdc: HDC; iFirstChar, iLastChar: UINT; lpBuffer: LPINT): BOOL; stdcall;
function GetCharWidthFloatA(hdc: HDC; iFirstChar, iLastChar: UINT; pxBuffer: PFLOAT): BOOL; stdcall;
function GetCharWidthFloatW(hdc: HDC; iFirstChar, iLastChar: UINT; pxBuffer: PFLOAT): BOOL; stdcall;
function GetCharWidthFloat(hdc: HDC; iFirstChar, iLastChar: UINT; pxBuffer: PFLOAT): BOOL; stdcall;
function GetCharABCWidthsA(hdc: HDC; uFirstChar, uLastChar: UINT; lpAbc: LPABC): BOOL; stdcall;
function GetCharABCWidthsW(hdc: HDC; uFirstChar, uLastChar: UINT; lpAbc: LPABC): BOOL; stdcall;
function GetCharABCWidths(hdc: HDC; uFirstChar, uLastChar: UINT; lpAbc: LPABC): BOOL; stdcall;
function GetCharABCWidthsFloatA(hdc: HDC; iFirstChar, iLastChar: UINT; lpAbcF: LPABCFLOAT): BOOL; stdcall;
function GetCharABCWidthsFloatW(hdc: HDC; iFirstChar, iLastChar: UINT; lpAbcF: LPABCFLOAT): BOOL; stdcall;
function GetCharABCWidthsFloat(hdc: HDC; iFirstChar, iLastChar: UINT; lpAbcF: LPABCFLOAT): BOOL; stdcall;

function GetClipBox(hdc: HDC; var lprc: RECT): Integer; stdcall;
function GetClipRgn(hdc: HDC; hrgn: HRGN): Integer; stdcall;
function GetMetaRgn(hdc: HDC; hrgn: HRGN): Integer; stdcall;
function GetCurrentObject(hdc: HDC; uObjectType: UINT): HGDIOBJ; stdcall;
function GetCurrentPositionEx(hdc: HDC; var lpPoint: POINT): BOOL; stdcall;
function GetDeviceCaps(hdc: HDC; nIndex: Integer): Integer; stdcall;
function GetDIBits(hdc: HDC; hbmp: HBITMAP; uStartScan, cScanLines: UINT; lpvBits: LPVOID; var lpbi: BITMAPINFO; uUsage: UINT): Integer; stdcall;
function GetFontData(hdc: HDC; dwTable, dwOffset: DWORD; lpvBuffer: LPVOID; cbData: DWORD): DWORD; stdcall;
function GetGlyphOutlineA(hdc: HDC; uChar, uFormat: UINT; var lpgm: GLYPHMETRICS; cbBuffer: DWORD; lpvBuffer: LPVOID; const lpMat2: MAT2): DWORD; stdcall;
function GetGlyphOutlineW(hdc: HDC; uChar, uFormat: UINT; var lpgm: GLYPHMETRICS; cbBuffer: DWORD; lpvBuffer: LPVOID; const lpMat2: MAT2): DWORD; stdcall;
function GetGlyphOutline(hdc: HDC; uChar, uFormat: UINT; var lpgm: GLYPHMETRICS; cbBuffer: DWORD; lpvBuffer: LPVOID; const lpMat2: MAT2): DWORD; stdcall;
function GetGraphicsMode(hdc: HDC): Integer; stdcall;
function GetMapMode(hdc: HDC): Integer; stdcall;
function GetMetaFileBitsEx(hmf: HMETAFILE; nSize: UINT; lpvData: LPVOID): UINT; stdcall;
function GetMetaFileA(lpszMetaFile: LPCSTR): HMETAFILE; stdcall;
function GetMetaFileW(lpszMetaFile: LPCWSTR): HMETAFILE; stdcall;
function GetMetaFile(lpszMetaFile: LPCTSTR): HMETAFILE; stdcall;
function GetNearestColor(hdc: HDC; crColor: COLORREF): COLORREF; stdcall;
function GetNearestPaletteIndex(hPal: HPALETTE; crColor: COLORREF): UINT; stdcall;
function GetObjectType(h: HGDIOBJ): DWORD; stdcall;

function GetOutlineTextMetricsA(hdc: HDC; cbData: UINT; lpOTM: LPOUTLINETEXTMETRICA): UINT; stdcall;
function GetOutlineTextMetricsW(hdc: HDC; cbData: UINT; lpOTM: LPOUTLINETEXTMETRICW): UINT; stdcall;
function GetOutlineTextMetrics(hdc: HDC; cbData: UINT; lpOTM: LPOUTLINETEXTMETRIC): UINT; stdcall;
function GetPaletteEntries(hPal: HPALETTE; iStartIndex, nEntries: UINT; lppe: LPPALETTEENTRY): UINT; stdcall;
function GetPixel(hdc: HDC; nXPos, nYPos: Integer): COLORREF; stdcall;
function GetPixelFormat(hdc: HDC): Integer; stdcall;
function GetPolyFillMode(hdc: HDC): Integer; stdcall;
function GetRasterizerCaps(var lprs: RASTERIZER_STATUS; cb: UINT): BOOL; stdcall;
function GetRandomRgn(hdc: HDC; hrgn: HRGN; iNum: Integer): Integer; stdcall;
function GetRegionData(hrgn: HRGN; dwCount: DWORD; lpRgnData: LPRGNDATA): DWORD; stdcall;
function GetRgnBox(hrgn: HRGN; var lprc: RECT): Integer; stdcall;
function GetStockObject(fnObject: Integer): HGDIOBJ; stdcall;
function GetStretchBltMode(hdc: HDC): Integer; stdcall;
function GetSystemPaletteEntries(hdc: HDC; iStartIndex, nEntries: UINT; lppe: LPPALETTEENTRY): UINT; stdcall;
function GetSystemPaletteUse(hdc: HDC): UINT; stdcall;
function GetTextCharacterExtra(hdc: HDC): Integer; stdcall;
function GetTextAlign(hdc: HDC): UINT; stdcall;
function GetTextColor(hdc: HDC): COLORREF; stdcall;

function GetTextExtentPointA(hdc: HDC; lpString: LPCSTR; cbString: Integer; var Size: TSize): BOOL; stdcall;
function GetTextExtentPointW(hdc: HDC; lpString: LPCWSTR; cbString: Integer; var Size: TSize): BOOL; stdcall;
function GetTextExtentPoint(hdc: HDC; lpString: LPCTSTR; cbString: Integer; var Size: TSize): BOOL; stdcall;
function GetTextExtentPoint32A(hdc: HDC; lpString: LPCSTR; cbString: Integer; var Size: TSize): BOOL; stdcall;
function GetTextExtentPoint32W(hdc: HDC; lpString: LPCWSTR; cbString: Integer; var Size: TSize): BOOL; stdcall;
function GetTextExtentPoint32(hdc: HDC; lpString: LPCTSTR; cbString: Integer; var Size: TSize): BOOL; stdcall;
function GetTextExtentExPointA(hdc: HDC; lpszStr: LPCSTR; cchString, nMaxExtend: Integer; lpnFit, alpDx: LPINT; var lpSize: TSize): BOOL; stdcall;
function GetTextExtentExPointW(hdc: HDC; lpszStr: LPCWSTR; cchString, nMaxExtend: Integer; lpnFit, alpDx: LPINT; var lpSize: TSize): BOOL; stdcall;
function GetTextExtentExPoint(hdc: HDC; lpszStr: LPCTSTR; cchString, nMaxExtend: Integer; lpnFit, alpDx: LPINT; var lpSize: TSize): BOOL; stdcall;
function GetTextCharset(hdc: HDC): Integer; stdcall;
function GetTextCharsetInfo(hdc: HDC; lpSig: LPFONTSIGNATURE; dwFlags: DWORD): Integer; stdcall;
function TranslateCharsetInfo(lpSrc: LPDWORD; lpCs: LPCHARSETINFO; dwFlags: DWORD): BOOL; stdcall;
function GetFontLanguageInfo(hdc: HDC): DWORD; stdcall;
function GetCharacterPlacementA(hdc: HDC; lpString: LPCSTR; nCount, nMaxExtend: Integer; var lpResults: GCP_RESULTSA; dwFlags: DWORD): DWORD; stdcall;
function GetCharacterPlacementW(hdc: HDC; lpString: LPCWSTR; nCount, nMaxExtend: Integer; var lpResults: GCP_RESULTSW; dwFlags: DWORD): DWORD; stdcall;
function GetCharacterPlacement(hdc: HDC; lpString: LPCTSTR; nCount, nMaxExtend: Integer; var lpResults: GCP_RESULTS; dwFlags: DWORD): DWORD; stdcall;

type
  PWcRange = ^TWcRange;
  tagWCRANGE = record
    wcLow: WCHAR;
    cGlyphs: USHORT;
  end;
  WCRANGE = tagWCRANGE;
  LPWCRANGE = ^WCRANGE;
  TWcRange = WCRANGE;

  PGlyphSet = ^TGlyphSet;
  tagGLYPHSET = record
    cbThis: DWORD;
    flAccel: DWORD;
    cGlyphsSupported: DWORD;
    cRanges: DWORD;
    ranges: array [0..0] of WCRANGE;
  end;
  GLYPHSET = tagGLYPHSET;
  LPGLYPHSET = ^GLYPHSET;
  TGlyphSet = GLYPHSET;

// flAccel flags for the GLYPHSET structure above

const
  GS_8BIT_INDICES = $00000001;

// flags for GetGlyphIndices

  GGI_MARK_NONEXISTING_GLYPHS = $0001;

function GetFontUnicodeRanges(hdc: HDC; lpgs: LPGLYPHSET): DWORD; stdcall;

function GetGlyphIndicesA(hdc: HDC; lpstr: LPCSTR; c: Integer; pgi: LPWORD; fl: DWORD): DWORD; stdcall;
function GetGlyphIndicesW(hdc: HDC; lpstr: LPCWSTR; c: Integer; pgi: LPWORD; fl: DWORD): DWORD; stdcall;
function GetGlyphIndices(hdc: HDC; lpstr: LPCTSTR; c: Integer; pgi: LPWORD; fl: DWORD): DWORD; stdcall;

function GetTextExtentPointI(hdc: HDC; pgiIn: LPWORD; cgi: Integer; lpSize: LPSIZE): BOOL; stdcall;
function GetTextExtentExPointI(hdc: HDC; pgiIn: LPWORD; cgi, nMaxExtend: Integer;
  lpnFit, alpDx: LPINT; lpSize: LPSIZE): BOOL; stdcall;
function GetCharWidthI(hdc: HDC; giFirst, cgi: UINT; pgi: LPWORD; lpBuffer: LPINT): BOOL; stdcall;
function GetCharABCWidthsI(hdc: HDC; giFirst, cgi: UINT; pgi: LPWORD; lpAbc: LPABC): BOOL; stdcall;

const
  STAMP_DESIGNVECTOR = $8000000 + Ord('d') + (Ord('v') shl 8);
  STAMP_AXESLIST     = $8000000 + Ord('a') + (Ord('l') shl 8);
  MM_MAX_NUMAXES     = 16;

type
  PDesignVector = ^TDesignVector;
  tagDESIGNVECTOR = record
    dvReserved: DWORD;
    dvNumAxes: DWORD;
    dvValues: array [0..MM_MAX_NUMAXES - 1] of LONG;
  end;
  DESIGNVECTOR = tagDESIGNVECTOR;
  LPDESIGNVECTOR = ^DESIGNVECTOR;
  TDesignVector = DESIGNVECTOR;

function AddFontResourceExA(lpszFilename: LPCSTR; fl: DWORD; pdv: PVOID): Integer; stdcall;
function AddFontResourceExW(lpszFilename: LPCWSTR; fl: DWORD; pdv: PVOID): Integer; stdcall;
function AddFontResourceEx(lpszFilename: LPCTSTR; fl: DWORD; pdv: PVOID): Integer; stdcall;

function RemoveFontResourceExA(lpFilename: LPCSTR; fl: DWORD; pdv: PVOID): BOOL; stdcall;
function RemoveFontResourceExW(lpFilename: LPCWSTR; fl: DWORD; pdv: PVOID): BOOL; stdcall;
function RemoveFontResourceEx(lpFilename: LPCTSTR; fl: DWORD; pdv: PVOID): BOOL; stdcall;

function AddFontMemResourceEx(pbFont: PVOID; cbFont: DWORD; pdv: PVOID; pcFonts: LPDWORD): HANDLE; stdcall;
function RemoveFontMemResourceEx(fh: HANDLE): BOOL; stdcall;

const
  FR_PRIVATE    = $10;
  FR_NOT_ENUM   = $20;

// The actual size of the DESIGNVECTOR and ENUMLOGFONTEXDV structures
// is determined by dvNumAxes,
// MM_MAX_NUMAXES only detemines the maximal size allowed

const
  MM_MAX_AXES_NAMELEN = 16;

type
  PAxisInfoA = ^TAxisInfoA;
  tagAXISINFOA = record
    axMinValue: LONG;
    axMaxValue: LONG;
    axAxisName: array [0..MM_MAX_AXES_NAMELEN - 1] of BYTE;
  end;
  AXISINFOA = tagAXISINFOA;
  LPAXISINFOA = ^AXISINFOA;
  TAxisInfoA = AXISINFOA;

  PAxisInfoW = ^TAxisInfoW;
  tagAXISINFOW = record
    axMinValue: LONG;
    axMaxValue: LONG;
    axAxisName: array [0..MM_MAX_AXES_NAMELEN - 1] of WCHAR;
  end;
  AXISINFOW = tagAXISINFOW;
  LPAXISINFOW = ^AXISINFOW;
  TAxisInfoW = AXISINFOW;

  {$IFDEF UNICODE}
  AXISINFO = AXISINFOW;
  PAXISINFO = PAXISINFOW;
  LPAXISINFO = LPAXISINFOW;
  TAxisInfo = TAxisInfoW;
  {$ELSE}
  AXISINFO = AXISINFOA;
  PAXISINFO = PAXISINFOA;
  LPAXISINFO = LPAXISINFOA;
  TAxisInfo = TAxisInfoA;
  {$ENDIF UNICODE}

  PAxesListA = ^TAxesListA;
  tagAXESLISTA = record
    axlReserved: DWORD;
    axlNumAxes: DWORD;
    axlAxisInfo: array [0..MM_MAX_NUMAXES - 1] of AXISINFOA;
  end;
  AXESLISTA = tagAXESLISTA;
  LPAXESLISTA = ^AXESLISTA;
  TAxesListA = tagAXESLISTA;

  PAxesListW = ^TAxesListW;
  tagAXESLISTW = record
    axlReserved: DWORD;
    axlNumAxes: DWORD;
    axlAxisInfo: array [0..MM_MAX_NUMAXES - 1] of AXISINFOW;
  end;
  AXESLISTW = tagAXESLISTW;
  LPAXESLISTW = ^AXESLISTW;
  TAxesListW = tagAXESLISTW;

  {$IFDEF UNICODE}
  AXESLIST = AXESLISTW;
  PAXESLIST = PAXESLISTW;
  LPAXESLIST = LPAXESLISTW;
  TAxesList = TAxesListW;
  {$ELSE}
  AXESLIST = AXESLISTA;
  PAXESLIST = PAXESLISTA;
  LPAXESLIST = LPAXESLISTA;
  TAxesList = TAxesListA;
  {$ENDIF UNICODE}

// The actual size of the AXESLIST and ENUMTEXTMETRIC structure is
// determined by axlNumAxes,
// MM_MAX_NUMAXES only detemines the maximal size allowed

  PEnumLogFontExDVA = ^TEnumLogFontExDVA;
  tagENUMLOGFONTEXDVA = record
    elfEnumLogfontEx: ENUMLOGFONTEXA;
    elfDesignVector: DESIGNVECTOR;
  end;
  ENUMLOGFONTEXDVA = tagENUMLOGFONTEXDVA;
  LPENUMLOGFONTEXDVA = ^ENUMLOGFONTEXDVA;
  TEnumLogFontExDVA = tagENUMLOGFONTEXDVA;

  PEnumLogFontExDVW = ^TEnumLogFontExDVW;
  tagENUMLOGFONTEXDVW = record
    elfEnumLogfontEx: ENUMLOGFONTEXW;
    elfDesignVector: DESIGNVECTOR;
  end;
  ENUMLOGFONTEXDVW = tagENUMLOGFONTEXDVW;
  LPENUMLOGFONTEXDVW = ^ENUMLOGFONTEXDVW;
  TEnumLogFontExDVW = tagENUMLOGFONTEXDVW;

  {$IFDEF UNICODE}
  ENUMLOGFONTEXDV = ENUMLOGFONTEXDVW;
  PENUMLOGFONTEXDV = PENUMLOGFONTEXDVW;
  LPENUMLOGFONTEXDV = LPENUMLOGFONTEXDVW;
  TEnumLogFontExDV = TEnumLogFontExDVW;
  {$ELSE}
  ENUMLOGFONTEXDV = ENUMLOGFONTEXDVA;
  PENUMLOGFONTEXDV = PENUMLOGFONTEXDVA;
  LPENUMLOGFONTEXDV = LPENUMLOGFONTEXDVA;
  TEnumLogFontExDV = TEnumLogFontExDVA;
  {$ENDIF UNICODE}

function CreateFontIndirectExA(penumlfex: LPENUMLOGFONTEXDVA): HFONT; stdcall;
function CreateFontIndirectExW(penumlfex: LPENUMLOGFONTEXDVW): HFONT; stdcall;
function CreateFontIndirectEx(penumlfex: LPENUMLOGFONTEXDV): HFONT; stdcall;

type
  PEnumTextMetricA = ^TEnumTextMetricA;
  tagENUMTEXTMETRICA = record
    etmNewTextMetricEx: NEWTEXTMETRICEXA;
    etmAxesList: AXESLISTA;
  end;
  ENUMTEXTMETRICA = tagENUMTEXTMETRICA;
  LPENUMTEXTMETRICA = ^ENUMTEXTMETRICA;
  TEnumTextMetricA = tagENUMTEXTMETRICA;

  PEnumTextMetricW = ^TEnumTextMetricW;
  tagENUMTEXTMETRICW = record
    etmNewTextMetricEx: NEWTEXTMETRICEXW;
    etmAxesList: AXESLISTW;
  end;
  ENUMTEXTMETRICW = tagENUMTEXTMETRICW;
  LPENUMTEXTMETRICW = ^ENUMTEXTMETRICW;
  TEnumTextMetricW = tagENUMTEXTMETRICW;

  {$IFDEF UNICODE}
  ENUMTEXTMETRIC = ENUMTEXTMETRICW;
  PENUMTEXTMETRIC = PENUMTEXTMETRICW;
  LPENUMTEXTMETRIC = LPENUMTEXTMETRICW;
  TEnumTextMetric = TEnumTextMetricW;
  {$ELSE}
  ENUMTEXTMETRIC = ENUMTEXTMETRICA;
  PENUMTEXTMETRIC = PENUMTEXTMETRICA;
  LPENUMTEXTMETRIC = LPENUMTEXTMETRICA;
  TEnumTextMetric = TEnumTextMetricA;
  {$ENDIF UNICODE}

function GetViewportExtEx(hdc: HDC; var lpSize: TSize): BOOL; stdcall;
function GetViewportOrgEx(hdc: HDC; var lpPoint: POINT): BOOL; stdcall;
function GetWindowExtEx(hdc: HDC; var lpSize: TSize): BOOL; stdcall;
function GetWindowOrgEx(hdc: HDC; var lpPoint: POINT): BOOL; stdcall;

function IntersectClipRect(hdc: HDC; nLeftRect, nTopRect, nRightRect, nBottomRect: Integer): Integer; stdcall;
function InvertRgn(hdc: HDC; hrgn: HRGN): BOOL; stdcall;
function LineDDA(nXStart, nYStart, nXEnd, nYEnd: Integer; lpLineFunc: LINEDDAPROC; lpData: LPARAM): BOOL; stdcall;
function LineTo(hdc: HDC; nXEnd, nYEnd: Integer): BOOL; stdcall;
function MaskBlt(hdc: HDC; nXDest, nYDest, nWidth, nHeight: Integer; hdcSrc: HDC; nXSrc, nYSrc: Integer; hbmMask: HBITMAP; xMask, yMask: Integer; dwRop: DWORD): BOOL; stdcall;
function PlgBlt(hdc: HDC; lpPoint: LPPOINT; hdcSrc: HDC; nXSrc, nYSrc, nWidth, nHeight: Integer; hbmMask: HBITMAP; xMask, yMask: Integer): BOOL; stdcall;

function OffsetClipRgn(hdc: HDC; nXOffset, nYOffset: Integer): Integer; stdcall;
function OffsetRgn(hrgn: HRGN; nXOffset, nYOffset: Integer): Integer; stdcall;
function PatBlt(hdc: HDC; nXLeft, nYLeft, nWidth, nHeight: Integer; dwRop: DWORD): BOOL; stdcall;
function Pie(hdc: HDC; nLeftRect, nTopRect, nRightRect, nBottomRect, nXRadial1, nYRadial1, nXRadial2, nYRadial2: Integer): BOOL; stdcall;
function PlayMetaFile(hdc: HDC; hmf: HMETAFILE): BOOL; stdcall;
function PaintRgn(hdc: HDC; hrgn: HRGN): BOOL; stdcall;
function PolyPolygon(hdc: HDC; lpPoints: LPPOINT; lpPolyCounts: LPINT; nCount: Integer): BOOL; stdcall;
function PtInRegion(hrgn: HRGN; X, Y: Integer): BOOL; stdcall;
function PtVisible(hdc: HDC; X, Y: Integer): BOOL; stdcall;
function RectInRegion(hrgn: HRGN; const lprc: RECT): BOOL; stdcall;
function RectVisible(hdc: HDC; const lprc: RECT): BOOL; stdcall;
function Rectangle(hdc: HDC; nLeftRect, nTopRect, nRightRect, nBottomRect: Integer): BOOL; stdcall;
function RestoreDC(hdc: HDC; nSavedDc: Integer): BOOL; stdcall;
function ResetDCA(hdc: HDC; const lpInitData: DEVMODEA): HDC; stdcall;
function ResetDCW(hdc: HDC; const lpInitData: DEVMODEW): HDC; stdcall;
function ResetDC(hdc: HDC; const lpInitData: DEVMODE): HDC; stdcall;
function RealizePalette(hdc: HDC): UINT; stdcall;
function RemoveFontResourceA(lpFileName: LPCSTR): BOOL; stdcall;
function RemoveFontResourceW(lpFileName: LPCWSTR): BOOL; stdcall;
function RemoveFontResource(lpFileName: LPCTSTR): BOOL; stdcall;
function RoundRect(hdc: HDC; nLeftRect, nTopRect, nRightRect, nBottomRect, nWidth, nHeight: Integer): BOOL; stdcall;
function ResizePalette(hPal: HPALETTE; nEntries: UINT): BOOL; stdcall;
function SaveDC(hdc: HDC): Integer; stdcall;
function SelectClipRgn(hdc: HDC; hrgn: HRGN): Integer; stdcall;
function ExtSelectClipRgn(hdc: HDC; hrgn: HRGN; fnMode: Integer): Integer; stdcall;
function SetMetaRgn(hdc: HDC): Integer; stdcall;
function SelectObject(hdc: HDC; hgdiobj: HGDIOBJ): HGDIOBJ; stdcall;
function SelectPalette(hdc: HDC; hpal: HPALETTE; nForceBackground: BOOL): HPALETTE; stdcall;
function SetBkColor(hdc: HDC; crColor: COLORREF): COLORREF; stdcall;

function SetDCBrushColor(hdc: HDC; crColor: COLORREF): COLORREF; stdcall;
function SetDCPenColor(hdc: HDC; crColor: COLORREF): COLORREF; stdcall;

function SetBkMode(hdc: HDC; iBlMode: Integer): Integer; stdcall;
function SetBitmapBits(hbmp: HBITMAP; cBytes: DWORD; lpBits: LPVOID): LONG; stdcall;

function SetBoundsRect(hdc: HDC; lprcBounds: LPRECT; flags: UINT): UINT; stdcall;
function SetDIBits(hdc: HDC; hbmp: HBITMAP; uStartScan, cScanLines: UINT; lpvBits: LPVOID; const lpbmi: BITMAPINFO; fuColorUse: UINT): Integer; stdcall;
function SetDIBitsToDevice(hdc: HDC; xDest, yDest: Integer; dwWidth, dwHeight: DWORD; XSrc, YSrc: Integer; uStartScan, cScanLines: UINT; lpvBits: LPVOID; const lpbmi: BITMAPINFO; fuColorUse: UINT): Integer; stdcall;
function SetMapperFlags(hdc: HDC; dwFlag: DWORD): DWORD; stdcall;
function SetGraphicsMode(hdc: HDC; iMode: Integer): Integer; stdcall;
function SetMapMode(hdc: HDC; fnMapMode: Integer): Integer; stdcall;

function SetLayout(hdc: HDC; dwLayOut: DWORD): DWORD; stdcall;
function GetLayout(hdc: HDC): DWORD; stdcall;

function SetMetaFileBitsEx(nSize: UINT; lpData: LPBYTE): HMETAFILE; stdcall;
function SetPaletteEntries(hPal: HPALETTE; cStart, nEntries: UINT; lppe: LPPALETTEENTRY): UINT; stdcall;
function SetPixel(hdc: HDC; X, Y: Integer; crColor: COLORREF): COLORREF; stdcall;
function SetPixelV(hdc: HDC; X, Y: Integer; crColor: COLORREF): BOOL; stdcall;
function SetPixelFormat(hdc: HDC; iPixelFormat: Integer; const ppfd: PIXELFORMATDESCRIPTOR): BOOL; stdcall;
function SetPolyFillMode(hdc: HDC; iPolyFillMode: Integer): Integer; stdcall;
function StretchBlt(hdc: HDC; nXOriginDest, nYOriginDest, nWidthDest, nHeightDest: Integer; hdcSrc: HDC; nXOriginSrc, nYOriginSrc, nWidthSrc, nHeightSrc: Integer; dwRop: DWORD): BOOL; stdcall;
function SetRectRgn(hrgn: HRGN; nLeftRect, nTopRect, nRightRect, nBottomRect: Integer): BOOL; stdcall;
function StretchDIBits(hdc: HDC; XDest, YDest, nDestWidth, nYDestHeight, XSrc, YSrc, nSrcWidth, nSrcHeight: Integer; lpBits: LPVOID; const lpBitsInfo: BITMAPINFO; iUsage: UINT; dwRop: DWORD): Integer; stdcall;
function SetROP2(hdc: HDC; fnDrawMode: Integer): Integer; stdcall;
function SetStretchBltMode(hdc: HDC; iStretchMode: Integer): Integer; stdcall;
function SetSystemPaletteUse(hdc: HDC; uUsage: UINT): UINT; stdcall;
function SetTextCharacterExtra(hdc: HDC; nCharExtra: Integer): Integer; stdcall;
function SetTextColor(hdc: HDC; crColor: COLORREF): COLORREF; stdcall;
function SetTextAlign(hdc: HDC; fMode: UINT): UINT; stdcall;
function SetTextJustification(hdc: HDC; nBreakExtra, nBreakCount: Integer): BOOL; stdcall;
function UpdateColors(hdc: HDC): BOOL; stdcall;

//
// image blt
//

type
  COLOR16 = USHORT;

  PTriVertex = ^TTriVertex;
  _TRIVERTEX = record
    x: LONG;
    y: LONG;
    Red: COLOR16;
    Green: COLOR16;
    Blue: COLOR16;
    Alpha: COLOR16;
  end;
  TRIVERTEX = _TRIVERTEX;
  LPTRIVERTEX = ^TRIVERTEX;
  TTriVertex = _TRIVERTEX;

  PGradientTriangle = ^TGradientTriangle;
  _GRADIENT_TRIANGLE = record
    Vertex1: ULONG;
    Vertex2: ULONG;
    Vertex3: ULONG;
  end;
  GRADIENT_TRIANGLE = _GRADIENT_TRIANGLE;
  LPGRADIENT_TRIANGLE = ^GRADIENT_TRIANGLE;
  PGRADIENT_TRIANGLE = ^GRADIENT_TRIANGLE;
  TGradientTriangle = _GRADIENT_TRIANGLE;

  PGradientRect = ^TGradientRect;
  _GRADIENT_RECT = record
    UpperLeft: ULONG;
    LowerRight: ULONG;
  end;
  GRADIENT_RECT = _GRADIENT_RECT;
  LPGRADIENT_RECT = ^GRADIENT_RECT;
  PGRADIENT_RECT = ^GRADIENT_RECT;
  TGradientRect = _GRADIENT_RECT;

  PBlendFunction = ^TBlendFunction;
  _BLENDFUNCTION = record
    BlendOp: BYTE;
    BlendFlags: BYTE;
    SourceConstantAlpha: BYTE;
    AlphaFormat: BYTE;
  end;
  BLENDFUNCTION = _BLENDFUNCTION;
  LPBLENDFUNCTION = ^BLENDFUNCTION;
  TBlendFunction = _BLENDFUNCTION;

//
// currentlly defined blend function
//

const
  AC_SRC_OVER = $00;

//
// alpha format flags
//

  AC_SRC_ALPHA = $01;

function AlphaBlend(hdcDest: HDC; nXOriginDest, nYOriginDest, nWidthDest,
  nHeightDest: Integer; hdcSrc: HDC; nXOriginSrc, nYOriginSrc, nWidthSrc,
  nHeightSrc: Integer; blendFunction: BLENDFUNCTION): BOOL; stdcall;

function TransparentBlt(hdcSrc: HDC; nXOriginSrc, nYOriginSrc, nWidthSrc,
  nHeightSrc: Integer; hdcDest: HDC; nXOriginDest, nYOriginDest, nWidthDest,
  nHeightDest: Integer; blendFunction: BLENDFUNCTION): BOOL; stdcall;

//
// gradient drawing modes
//

const
  GRADIENT_FILL_RECT_H   = $00000000;
  GRADIENT_FILL_RECT_V   = $00000001;
  GRADIENT_FILL_TRIANGLE = $00000002;
  GRADIENT_FILL_OP_FLAG  = $000000ff;

function GradientFill(hdc: HDC; pVertex: PTRIVERTEX; dwNumVertex: ULONG; pMesh: PVOID; dwNumMesh, dwMode: ULONG): BOOL; stdcall;
function PlayMetaFileRecord(hdc: HDC; lpHandleTable: LPHANDLETABLE; lpMetaRecord: LPMETARECORD; nHandles: UINT): BOOL; stdcall;

type
  MFENUMPROC = function(hdc: HDC; lpHTable: LPHANDLETABLE; lpMFR: LPMETARECORD; nObj: Integer; lpClientData: LPARAM): Integer; stdcall;

function EnumMetaFile(hdc: HDC; hemf: HMETAFILE; lpMetaFunc: MFENUMPROC; lParam: LPARAM): BOOL; stdcall;

type
  ENHMFENUMPROC = function(hdc: HDC; lpHTable: LPHANDLETABLE; lpEMFR: LPENHMETARECORD; nObj: Integer; lpData: LPARAM): Integer; stdcall;

// Enhanced Metafile Function Declarations

function CloseEnhMetaFile(hdc: HDC): HENHMETAFILE; stdcall;
function CopyEnhMetaFileA(hemfSrc: HENHMETAFILE; lpszFile: LPCSTR): HENHMETAFILE; stdcall;
function CopyEnhMetaFileW(hemfSrc: HENHMETAFILE; lpszFile: LPCWSTR): HENHMETAFILE; stdcall;
function CopyEnhMetaFile(hemfSrc: HENHMETAFILE; lpszFile: LPCTSTR): HENHMETAFILE; stdcall;
function CreateEnhMetaFileA(hdcRef: HDC; lpFileName: LPCSTR; const lpRect: RECT; lpDescription: LPCSTR): HDC; stdcall;
function CreateEnhMetaFileW(hdcRef: HDC; lpFileName: LPCWSTR; const lpRect: RECT; lpDescription: LPCWSTR): HDC; stdcall;
function CreateEnhMetaFile(hdcRef: HDC; lpFileName: LPCTSTR; const lpRect: RECT; lpDescription: LPCTSTR): HDC; stdcall;

function DeleteEnhMetaFile(hemf: HENHMETAFILE): BOOL; stdcall;
function EnumEnhMetaFile(hdc: HDC; hemf: HENHMETAFILE; lpEnhMetaFunc: ENHMFENUMPROC; lpData: LPVOID; const lpRect: RECT): BOOL; stdcall;
function GetEnhMetaFileA(lpszMetaFile: LPCSTR): HENHMETAFILE; stdcall;
function GetEnhMetaFileW(lpszMetaFile: LPCWSTR): HENHMETAFILE; stdcall;
function GetEnhMetaFile(lpszMetaFile: LPCTSTR): HENHMETAFILE; stdcall;
function GetEnhMetaFileBits(hemf: HENHMETAFILE; cbBuffer: UINT; lpBuffer: LPBYTE): UINT; stdcall;
function GetEnhMetaFileDescriptionA(hemf: HENHMETAFILE; cchBuffer: UINT; lpszDescription: LPSTR): UINT; stdcall;
function GetEnhMetaFileDescriptionW(hemf: HENHMETAFILE; cchBuffer: UINT; lpszDescription: LPWSTR): UINT; stdcall;
function GetEnhMetaFileDescription(hemf: HENHMETAFILE; cchBuffer: UINT; lpszDescription: LPTSTR): UINT; stdcall;
function GetEnhMetaFileHeader(hemf: HENHMETAFILE; cbBuffer: UINT; lpemh: LPENHMETAHEADER ): UINT; stdcall;
function GetEnhMetaFilePaletteEntries(hemf: HENHMETAFILE; cEntries: UINT; lppe: LPPALETTEENTRY ): UINT; stdcall;
function GetEnhMetaFilePixelFormat(hemf: HENHMETAFILE; cbBuffer: UINT; var ppfd: PIXELFORMATDESCRIPTOR): UINT; stdcall;
function GetWinMetaFileBits(hemf: HENHMETAFILE; cbBuffer: UINT; lpbBuffer: LPBYTE; fnMapMode: Integer; hdcRef: HDC): UINT; stdcall;
function PlayEnhMetaFile(hdc: HDC; hemf: HENHMETAFILE; const lpRect: RECT): BOOL; stdcall;
function PlayEnhMetaFileRecord(hdc: HDC; lpHandleTable: LPHANDLETABLE; lpEnhMetaRecord: LPENHMETARECORD; nHandles: UINT): BOOL; stdcall;
function SetEnhMetaFileBits(cbBuffer: UINT; lpData: LPBYTE): HENHMETAFILE; stdcall;
function SetWinMetaFileBits(cbBuffer: UINT; lpbBuffer: LPBYTE; hdcRef: HDC; const lpmfp: METAFILEPICT): HENHMETAFILE; stdcall;
function GdiComment(hdc: HDC; cbSize: UINT; lpData: LPBYTE): BOOL; stdcall;

function GetTextMetricsA(hdc: HDC; var lptm: TEXTMETRICA): BOOL; stdcall;
function GetTextMetricsW(hdc: HDC; var lptm: TEXTMETRICW): BOOL; stdcall;
function GetTextMetrics(hdc: HDC; var lptm: TEXTMETRIC): BOOL; stdcall;

// new GDI

type
  PDibSection = ^TDibSection;
  tagDIBSECTION = record
    dsBm: BITMAP;
    dsBmih: BITMAPINFOHEADER;
    dsBitfields: array [0..2] of DWORD;
    dshSection: HANDLE;
    dsOffset: DWORD;
  end;
  DIBSECTION = tagDIBSECTION;
  LPDIBSECTION = ^DIBSECTION;
  TDibSection = DIBSECTION;

function AngleArc(hdc: HDC; X, Y: Integer; dwRadius: DWORD; eStartAngle, eSweepAngle: FLOAT): BOOL; stdcall;
function PolyPolyline(hdc: HDC; lppt: LPPOINT; lpdwPolyPoints: LPDWORD; cCount: DWORD): BOOL; stdcall;
function GetWorldTransform(hdc: HDC; lpXform: LPXFORM): BOOL; stdcall;
function SetWorldTransform(hdc: HDC; lpXform: LPXFORM): BOOL; stdcall;
function ModifyWorldTransform(hdc: HDC; lpXform: LPXFORM; iMode: DWORD): BOOL; stdcall;
function CombineTransform(lpxformResult, lpXform1, lpXform2: LPXFORM): BOOL; stdcall;
function CreateDIBSection(hdc: HDC; pbmi: LPBITMAPINFO; iUsage: UINT;
  ppvBits: PPVOID; hSection: HANDLE; dwOffset: DWORD): HBITMAP; stdcall;
function GetDIBColorTable(hdc: HDC; uStartIndex, cEntries: UINT; pColors: PRGBQUAD): UINT; stdcall;
function SetDIBColorTable(hdc: HDC; uStartIndex, cEntries: UINT; pColors: PRGBQUAD): UINT; stdcall;

// Flags value for COLORADJUSTMENT

const
  CA_NEGATIVE   = $0001;
  CA_LOG_FILTER = $0002;

// IlluminantIndex values

  ILLUMINANT_DEVICE_DEFAULT = 0;
  ILLUMINANT_A              = 1;
  ILLUMINANT_B              = 2;
  ILLUMINANT_C              = 3;
  ILLUMINANT_D50            = 4;
  ILLUMINANT_D55            = 5;
  ILLUMINANT_D65            = 6;
  ILLUMINANT_D75            = 7;
  ILLUMINANT_F2             = 8;
  ILLUMINANT_MAX_INDEX      = ILLUMINANT_F2;

  ILLUMINANT_TUNGSTEN    = ILLUMINANT_A;
  ILLUMINANT_DAYLIGHT    = ILLUMINANT_C;
  ILLUMINANT_FLUORESCENT = ILLUMINANT_F2;
  ILLUMINANT_NTSC        = ILLUMINANT_C;

// Min and max for RedGamma, GreenGamma, BlueGamma

  RGB_GAMMA_MIN = WORD(02500);
  RGB_GAMMA_MAX = WORD(65000);

// Min and max for ReferenceBlack and ReferenceWhite

  REFERENCE_WHITE_MIN = WORD(6000);
  REFERENCE_WHITE_MAX = WORD(10000);
  REFERENCE_BLACK_MIN = WORD(0);
  REFERENCE_BLACK_MAX = WORD(4000);

// Min and max for Contrast, Brightness, Colorfulness, RedGreenTint

  COLOR_ADJ_MIN = SHORT(-100);
  COLOR_ADJ_MAX = SHORT(100);

type
  PColorAdjustment = ^TColorAdjustment;
  tagCOLORADJUSTMENT = record
    caSize: WORD;
    caFlags: WORD;
    caIlluminantIndex: WORD;
    caRedGamma: WORD;
    caGreenGamma: WORD;
    caBlueGamma: WORD;
    caReferenceBlack: WORD;
    caReferenceWhite: WORD;
    caContrast: SHORT;
    caBrightness: SHORT;
    caColorfulness: SHORT;
    caRedGreenTint: SHORT;
  end;
  COLORADJUSTMENT = tagCOLORADJUSTMENT;
  LPCOLORADJUSTMENT = ^COLORADJUSTMENT;
  TColorAdjustment = COLORADJUSTMENT;

function SetColorAdjustment(hdc: HDC; lpca: LPCOLORADJUSTMENT): BOOL; stdcall;
function GetColorAdjustment(hdc: HDC; lpca: LPCOLORADJUSTMENT): BOOL; stdcall;
function CreateHalftonePalette(hdc: HDC): HPALETTE; stdcall;

type
  ABORTPROC = function(hdc: HDC; iError: Integer): BOOL; stdcall;

  PDocInfoA = ^TDocInfoA;
  _DOCINFOA = record
    cbSize: Integer;
    lpszDocName: LPCSTR;
    lpszOutput: LPCSTR;
    lpszDatatype: LPCSTR;
    fwType: DWORD;
  end;
  DOCINFOA = _DOCINFOA;
  LPDOCINFOA = ^DOCINFOA;
  TDocInfoA = _DOCINFOA;

  PDocInfoW = ^TDocInfoW;
  _DOCINFOW = record
    cbSize: Integer;
    lpszDocName: LPCWSTR;
    lpszOutput: LPCWSTR;
    lpszDatatype: LPCWSTR;
    fwType: DWORD;
  end;
  DOCINFOW = _DOCINFOW;
  LPDOCINFOW = ^DOCINFOW;
  TDocInfoW = _DOCINFOW;

  {$IFDEF UNICODE}
  DOCINFO = DOCINFOW;
  LPDOCINFO = LPDOCINFOW;
  TDocInfo = TDocInfoW;
  PDocInfo = PDocInfoW;
  {$ELSE}
  DOCINFO = DOCINFOA;
  LPDOCINFO = LPDOCINFOA;
  TDocInfo = TDocInfoA;
  PDocInfo = PDocInfoA;
  {$ENDIF UNICODE}

const
  DI_APPBANDING            = $00000001;
  DI_ROPS_READ_DESTINATION = $00000002;

function StartDocA(hdc: HDC; const lpdi: DOCINFOA): Integer; stdcall;
function StartDocW(hdc: HDC; const lpdi: DOCINFOW): Integer; stdcall;
function StartDoc(hdc: HDC; const lpdi: DOCINFO): Integer; stdcall;
function EndDoc(dc: HDC): Integer; stdcall;
function StartPage(dc: HDC): Integer; stdcall;
function EndPage(dc: HDC): Integer; stdcall;
function AbortDoc(dc: HDC): Integer; stdcall;
function SetAbortProc(dc: HDC; lpAbortProc: ABORTPROC): Integer; stdcall;

function AbortPath(hdc: HDC): BOOL; stdcall;
function ArcTo(hdc: HDC; nLeftRect, nTopRect, nRightRect, nBottomRect, nXRadial1, nYRadial1, nXRadial2, nYRadial2: Integer): BOOL; stdcall;
function BeginPath(hdc: HDC): BOOL; stdcall;
function CloseFigure(hdc: HDC): BOOL; stdcall;
function EndPath(hdc: HDC): BOOL; stdcall;
function FillPath(hdc: HDC): BOOL; stdcall;
function FlattenPath(hdc: HDC): BOOL; stdcall;
function GetPath(hdc: HDC; lpPoints: LPPOINT; lpTypes: LPBYTE; nSize: Integer): Integer; stdcall;
function PathToRegion(hdc: HDC): HRGN; stdcall;
function PolyDraw(hdc: HDC; lppt: LPPOINT; lpbTypes: LPBYTE; cCount: Integer): BOOL; stdcall;
function SelectClipPath(hdc: HDC; iMode: Integer): BOOL; stdcall;
function SetArcDirection(hdc: HDC; ArcDirection: Integer): Integer; stdcall;
function SetMiterLimit(hdc: HDC; eNewLimit: FLOAT; peOldLimit: PFLOAT): BOOL; stdcall;
function StrokeAndFillPath(hdc: HDC): BOOL; stdcall;
function StrokePath(hdc: HDC): BOOL; stdcall;
function WidenPath(hdc: HDC): BOOL; stdcall;
function ExtCreatePen(dwPenStyle, dwWidth: DWORD; const lplb: LOGBRUSH; dwStyleCount: DWORD; lpStyle: DWORD): HPEN; stdcall;
function GetMiterLimit(hdc: HDC; var peLimit: FLOAT): BOOL; stdcall;
function GetArcDirection(hdc: HDC): Integer; stdcall;

function GetObjectA(hgdiobj: HGDIOBJ; cbBuffer: Integer; lpvObject: LPVOID): Integer; stdcall;
function GetObjectW(hgdiobj: HGDIOBJ; cbBuffer: Integer; lpvObject: LPVOID): Integer; stdcall;
function GetObject(hgdiobj: HGDIOBJ; cbBuffer: Integer; lpvObject: LPVOID): Integer; stdcall;
function MoveToEx(hdc: HDC; X, Y: Integer; lpPoint: LPPOINT): BOOL; stdcall;
function TextOutA(hdc: HDC; nXStart, nYStart: Integer; lpString: LPCSTR; cbString: Integer): BOOL; stdcall;
function TextOutW(hdc: HDC; nXStart, nYStart: Integer; lpString: LPCWSTR; cbString: Integer): BOOL; stdcall;
function TextOut(hdc: HDC; nXStart, nYStart: Integer; lpString: LPCTSTR; cbString: Integer): BOOL; stdcall;
function ExtTextOutA(hdc: HDC; X, Y: Integer; fuOptions: UINT; lprc: LPRECT; lpString: LPCSTR; cbCount: UINT; lpDx: LPINT): BOOL; stdcall;
function ExtTextOutW(hdc: HDC; X, Y: Integer; fuOptions: UINT; lprc: LPRECT; lpString: LPCWSTR; cbCount: UINT; lpDx: LPINT): BOOL; stdcall;
function ExtTextOut(hdc: HDC; X, Y: Integer; fuOptions: UINT; lprc: LPRECT; lpString: LPCTSTR; cbCount: UINT; lpDx: LPINT): BOOL; stdcall;
function PolyTextOutA(hdc: HDC; pptxt: LPPOLYTEXTA; cStrings: Integer): BOOL; stdcall;
function PolyTextOutW(hdc: HDC; pptxt: LPPOLYTEXTW; cStrings: Integer): BOOL; stdcall;
function PolyTextOut(hdc: HDC; pptxt: LPPOLYTEXT; cStrings: Integer): BOOL; stdcall;

function CreatePolygonRgn(lppt: LPPOINT; cPoints, fnPolyFillMode: Integer): HRGN; stdcall;
function DPtoLP(hdc: HDC; lpPoints: LPPOINT; nCount: Integer): BOOL; stdcall;
function LPtoDP(hdc: HDC; lpPoints: LPPOINT; nCount: Integer): BOOL; stdcall;
function Polygon(hdc: HDC; lpPoints: LPPOINT; nCount: Integer): BOOL; stdcall;
function Polyline(hdc: HDC; lppt: LPPOINT; nCount: Integer): BOOL; stdcall;

function PolyBezier(hdc: HDC; lppt: LPPOINT; cPoints: DWORD): BOOL; stdcall;
function PolyBezierTo(hdc: HDC; lppt: LPPOINT; cCount: DWORD): BOOL; stdcall;
function PolylineTo(hdc: HDC; lppt: LPPOINT; cCount: DWORD): BOOL; stdcall;

function SetViewportExtEx(hdc: HDC; nXExtend, nYExtend: Integer; lpSize: LPSIZE): BOOL; stdcall;
function SetViewportOrgEx(hdc: HDC; X, Y: Integer; lpPoint: LPPOINT): BOOL; stdcall;
function SetWindowExtEx(hdc: HDC; nXExtend, nYExtend: Integer; lpSize: LPSIZE): BOOL; stdcall;
function SetWindowOrgEx(hdc: HDC; X, Y: Integer; lpPoint: LPPOINT): BOOL; stdcall;

function OffsetViewportOrgEx(hdc: HDC; nXOffset, nYOffset: Integer; lpPoint: LPPOINT): BOOL; stdcall;
function OffsetWindowOrgEx(hdc: HDC; nXOffset, nYOffset: Integer; lpPoint: LPPOINT): BOOL; stdcall;
function ScaleViewportExtEx(hdc: HDC; Xnum, Xdenom, Ynum, Ydenom: Integer; lpSize: LPSIZE): BOOL; stdcall;
function ScaleWindowExtEx(hdc: HDC; Xnum, Xdenom, Ynum, Ydenom: Integer; lpSize: LPSIZE): BOOL; stdcall;
function SetBitmapDimensionEx(hBitmap: HBITMAP; nWidth, nHeight: Integer; lpSize: LPSIZE): BOOL; stdcall;
function SetBrushOrgEx(hdc: HDC; nXOrg, nYOrg: Integer; lppt: LPPOINT): BOOL; stdcall;

function GetTextFaceA(hdc: HDC; nCount: Integer; lpFaceName: LPSTR): Integer; stdcall;
function GetTextFaceW(hdc: HDC; nCount: Integer; lpFaceName: LPWSTR): Integer; stdcall;
function GetTextFace(hdc: HDC; nCount: Integer; lpFaceName: LPTSTR): Integer; stdcall;

const
  FONTMAPPER_MAX = 10;

type
  PKerningPair = ^TKerningPair;
  tagKERNINGPAIR = record
    wFirst: WORD;
    wSecond: WORD;
    iKernAmount: Integer;
  end;
  KERNINGPAIR = tagKERNINGPAIR;
  LPKERNINGPAIR = ^KERNINGPAIR;
  TKerningPair = KERNINGPAIR;

function GetKerningPairsA(hDc: HDC; nNumPairs: DWORD; lpkrnpair: LPKERNINGPAIR): DWORD; stdcall;
function GetKerningPairsW(hDc: HDC; nNumPairs: DWORD; lpkrnpair: LPKERNINGPAIR): DWORD; stdcall;
function GetKerningPairs(hDc: HDC; nNumPairs: DWORD; lpkrnpair: LPKERNINGPAIR): DWORD; stdcall;

function GetDCOrgEx(hdc: HDC; lpPoint: LPPOINT): BOOL; stdcall;
function FixBrushOrgEx(hDc: HDC; I1, I2: Integer; lpPoint: LPPOINT): BOOL; stdcall;
function UnrealizeObject(hgdiobj: HGDIOBJ): BOOL; stdcall;

function GdiFlush: BOOL; stdcall;
function GdiSetBatchLimit(dwLimit: DWORD): DWORD; stdcall;
function GdiGetBatchLimit: DWORD; stdcall;

const
  ICM_OFF            = 1;
  ICM_ON             = 2;
  ICM_QUERY          = 3;
  ICM_DONE_OUTSIDEDC = 4;

type
  ICMENUMPROCA = function(lpszFileName: LPSTR; lParam: LPARAM): Integer; stdcall;
  ICMENUMPROCW = function(lpszFileName: LPWSTR; lParam: LPARAM): Integer; stdcall;
  ICMENUMPROC = function(lpszFileName: LPTSTR; lParam: LPARAM): Integer; stdcall;

function SetICMMode(hDc: HDC; iEnableICM: Integer): Integer; stdcall;
function CheckColorsInGamut(hDc: HDC; lpRGBTriples, lpBuffer: LPVOID; nCount: DWORD): BOOL; stdcall;
function GetColorSpace(hDc: HDC): HCOLORSPACE; stdcall;

function GetLogColorSpaceA(hColorSpace: HCOLORSPACE; lpBuffer: LPLOGCOLORSPACEA; nSize: DWORD): BOOL; stdcall;
function GetLogColorSpaceW(hColorSpace: HCOLORSPACE; lpBuffer: LPLOGCOLORSPACEW; nSize: DWORD): BOOL; stdcall;
function GetLogColorSpace(hColorSpace: HCOLORSPACE; lpBuffer: LPLOGCOLORSPACE; nSize: DWORD): BOOL; stdcall;

function CreateColorSpaceA(lpLogColorSpace: LPLOGCOLORSPACEA): HCOLORSPACE; stdcall;
function CreateColorSpaceW(lpLogColorSpace: LPLOGCOLORSPACEW): HCOLORSPACE; stdcall;
function CreateColorSpace(lpLogColorSpace: LPLOGCOLORSPACE): HCOLORSPACE; stdcall;

function SetColorSpace(hDc: HDC; hColorSpace: HCOLORSPACE): HCOLORSPACE; stdcall;
function DeleteColorSpace(hColorSpace: HCOLORSPACE): BOOL; stdcall;
function GetICMProfileA(hDc: HDC; lpcbName: LPDWORD; lpszFilename: LPSTR): BOOL; stdcall;
function GetICMProfileW(hDc: HDC; lpcbName: LPDWORD; lpszFilename: LPWSTR): BOOL; stdcall;
function GetICMProfile(hDc: HDC; lpcbName: LPDWORD; lpszFilename: LPTSTR): BOOL; stdcall;

function SetICMProfileA(hDc: HDC; lpFileName: LPSTR): BOOL; stdcall;
function SetICMProfileW(hDc: HDC; lpFileName: LPWSTR): BOOL; stdcall;
function SetICMProfile(hDc: HDC; lpFileName: LPTSTR): BOOL; stdcall;

function GetDeviceGammaRamp(hDc: HDC; lpRamp: LPVOID): BOOL; stdcall;
function SetDeviceGammaRamp(hDc: HDC; lpRamp: LPVOID): BOOL; stdcall;
function ColorMatchToTarget(hDc, hdcTarget: HDC; uiAction: DWORD): BOOL; stdcall;

function EnumICMProfilesA(hDc: HDC; lpEnumProc: ICMENUMPROCA; lParam: LPARAM): Integer; stdcall;
function EnumICMProfilesW(hDc: HDC; lpEnumProc: ICMENUMPROCW; lParam: LPARAM): Integer; stdcall;
function EnumICMProfiles(hDc: HDC; lpEnumProc: ICMENUMPROC; lParam: LPARAM): Integer; stdcall;

function UpdateICMRegKeyA(dwReserved: DWORD; lpszCMID, lpszFileName: LPSTR; nCommand: UINT): BOOL; stdcall;
function UpdateICMRegKeyW(dwReserved: DWORD; lpszCMID, lpszFileName: LPWSTR; nCommand: UINT): BOOL; stdcall;
function UpdateICMRegKey(dwReserved: DWORD; lpszCMID, lpszFileName: LPTSTR; nCommand: UINT): BOOL; stdcall;

function ColorCorrectPalette(hDc: HDC; hColorPalette: HPALETTE; dwFirstEntry, dwNumOfEntries: DWORD): BOOL; stdcall;

// Enhanced metafile constants.

const
  ENHMETA_SIGNATURE = $464D4520;

// Stock object flag used in the object handle index in the enhanced
// metafile records.
// E.g. The object handle index (META_STOCK_OBJECT | BLACK_BRUSH)
// represents the stock object BLACK_BRUSH.

  ENHMETA_STOCK_OBJECT = DWORD($80000000);

// Enhanced metafile record types.

  EMR_HEADER               = 1;
  EMR_POLYBEZIER           = 2;
  EMR_POLYGON              = 3;
  EMR_POLYLINE             = 4;
  EMR_POLYBEZIERTO         = 5;
  EMR_POLYLINETO           = 6;
  EMR_POLYPOLYLINE         = 7;
  EMR_POLYPOLYGON          = 8;
  EMR_SETWINDOWEXTEX       = 9;
  EMR_SETWINDOWORGEX       = 10;
  EMR_SETVIEWPORTEXTEX     = 11;
  EMR_SETVIEWPORTORGEX     = 12;
  EMR_SETBRUSHORGEX        = 13;
  EMR_EOF                  = 14;
  EMR_SETPIXELV            = 15;
  EMR_SETMAPPERFLAGS       = 16;
  EMR_SETMAPMODE           = 17;
  EMR_SETBKMODE            = 18;
  EMR_SETPOLYFILLMODE      = 19;
  EMR_SETROP2              = 20;
  EMR_SETSTRETCHBLTMODE    = 21;
  EMR_SETTEXTALIGN         = 22;
  EMR_SETCOLORADJUSTMENT   = 23;
  EMR_SETTEXTCOLOR         = 24;
  EMR_SETBKCOLOR           = 25;
  EMR_OFFSETCLIPRGN        = 26;
  EMR_MOVETOEX             = 27;
  EMR_SETMETARGN           = 28;
  EMR_EXCLUDECLIPRECT      = 29;
  EMR_INTERSECTCLIPRECT    = 30;
  EMR_SCALEVIEWPORTEXTEX   = 31;
  EMR_SCALEWINDOWEXTEX     = 32;
  EMR_SAVEDC               = 33;
  EMR_RESTOREDC            = 34;
  EMR_SETWORLDTRANSFORM    = 35;
  EMR_MODIFYWORLDTRANSFORM = 36;
  EMR_SELECTOBJECT         = 37;
  EMR_CREATEPEN            = 38;
  EMR_CREATEBRUSHINDIRECT  = 39;
  EMR_DELETEOBJECT         = 40;
  EMR_ANGLEARC             = 41;
  EMR_ELLIPSE              = 42;
  EMR_RECTANGLE            = 43;
  EMR_ROUNDRECT            = 44;
  EMR_ARC                  = 45;
  EMR_CHORD                = 46;
  EMR_PIE                  = 47;
  EMR_SELECTPALETTE        = 48;
  EMR_CREATEPALETTE        = 49;
  EMR_SETPALETTEENTRIES    = 50;
  EMR_RESIZEPALETTE        = 51;
  EMR_REALIZEPALETTE       = 52;
  EMR_EXTFLOODFILL         = 53;
  EMR_LINETO               = 54;
  EMR_ARCTO                = 55;
  EMR_POLYDRAW             = 56;
  EMR_SETARCDIRECTION      = 57;
  EMR_SETMITERLIMIT        = 58;
  EMR_BEGINPATH            = 59;
  EMR_ENDPATH              = 60;
  EMR_CLOSEFIGURE          = 61;
  EMR_FILLPATH             = 62;
  EMR_STROKEANDFILLPATH    = 63;
  EMR_STROKEPATH           = 64;
  EMR_FLATTENPATH          = 65;
  EMR_WIDENPATH            = 66;
  EMR_SELECTCLIPPATH       = 67;
  EMR_ABORTPATH            = 68;

  EMR_GDICOMMENT              = 70;
  EMR_FILLRGN                 = 71;
  EMR_FRAMERGN                = 72;
  EMR_INVERTRGN               = 73;
  EMR_PAINTRGN                = 74;
  EMR_EXTSELECTCLIPRGN        = 75;
  EMR_BITBLT                  = 76;
  EMR_STRETCHBLT              = 77;
  EMR_MASKBLT                 = 78;
  EMR_PLGBLT                  = 79;
  EMR_SETDIBITSTODEVICE       = 80;
  EMR_STRETCHDIBITS           = 81;
  EMR_EXTCREATEFONTINDIRECTW  = 82;
  EMR_EXTTEXTOUTA             = 83;
  EMR_EXTTEXTOUTW             = 84;
  EMR_POLYBEZIER16            = 85;
  EMR_POLYGON16               = 86;
  EMR_POLYLINE16              = 87;
  EMR_POLYBEZIERTO16          = 88;
  EMR_POLYLINETO16            = 89;
  EMR_POLYPOLYLINE16          = 90;
  EMR_POLYPOLYGON16           = 91;
  EMR_POLYDRAW16              = 92;
  EMR_CREATEMONOBRUSH         = 93;
  EMR_CREATEDIBPATTERNBRUSHPT = 94;
  EMR_EXTCREATEPEN            = 95;
  EMR_POLYTEXTOUTA            = 96;
  EMR_POLYTEXTOUTW            = 97;

  EMR_SETICMMODE       = 98;
  EMR_CREATECOLORSPACE = 99;
  EMR_SETCOLORSPACE    = 100;
  EMR_DELETECOLORSPACE = 101;
  EMR_GLSRECORD        = 102;
  EMR_GLSBOUNDEDRECORD = 103;
  EMR_PIXELFORMAT      = 104;

  EMR_RESERVED_105        = 105;
  EMR_RESERVED_106        = 106;
  EMR_RESERVED_107        = 107;
  EMR_RESERVED_108        = 108;
  EMR_RESERVED_109        = 109;
  EMR_RESERVED_110        = 110;
  EMR_COLORCORRECTPALETTE = 111;
  EMR_SETICMPROFILEA      = 112;
  EMR_SETICMPROFILEW      = 113;
  EMR_ALPHABLEND          = 114;
  EMR_SETLAYOUT           = 115;
  EMR_TRANSPARENTBLT      = 116;
  EMR_RESERVED_117        = 117;
  EMR_GRADIENTFILL        = 118;
  EMR_RESERVED_119        = 119;
  EMR_RESERVED_120        = 120;
  EMR_COLORMATCHTOTARGETW = 121;
  EMR_CREATECOLORSPACEW   = 122;
  
  EMR_MIN = 1;
  EMR_MAX = 122;

// Base record type for the enhanced metafile.

type
  PEmr = ^TEmr;
  tagEMR = record
    iType: DWORD; // Enhanced metafile record type
    nSize: DWORD; // Length of the record in bytes.
                  // This must be a multiple of 4.
  end;
  EMR = tagEMR;
  TEmr = EMR;

// Base text record type for the enhanced metafile.

  PEmrText = ^TEmrText;
  tagEMRTEXT = record
    ptlReference: POINTL;
    nChars: DWORD;
    offString: DWORD; // Offset to the string
    fOptions: DWORD;
    rcl: RECTL;
    offDx: DWORD; // Offset to the inter-character spacing array.
    // This is always given.
  end;
  EMRTEXT = tagEMRTEXT;
  TEmrText = EMRTEXT;

// Record structures for the enhanced metafile.

  PAbortPath = ^TAbortPath;
  tagABORTPATH = record
    emr: EMR;
  end;
  TAbortPath = tagABORTPATH;
  EMRABORTPATH = tagABORTPATH;
  PEMRABORTPATH = ^EMRABORTPATH;
  EMRBEGINPATH = tagABORTPATH;
  PEMRBEGINPATH = ^EMRBEGINPATH;
  EMRENDPATH = tagABORTPATH;
  PEMRENDPATH = ^EMRENDPATH;
  EMRCLOSEFIGURE = tagABORTPATH;
  PEMRCLOSEFIGURE = ^EMRCLOSEFIGURE;
  EMRFLATTENPATH = tagABORTPATH;
  PEMRFLATTENPATH = ^EMRFLATTENPATH;
  EMRWIDENPATH = tagABORTPATH;
  PEMRWIDENPATH = ^EMRWIDENPATH;
  EMRSETMETARGN = tagABORTPATH;
  PEMRSETMETARGN = ^EMRSETMETARGN;
  EMRSAVEDC = tagABORTPATH;
  PEMRSAVEDC = ^EMRSAVEDC;
  EMRREALIZEPALETTE = tagABORTPATH;
  PEMRREALIZEPALETTE = ^EMRREALIZEPALETTE;

  PEmrSelectClipPath = ^TEmrSelectClipPath;
  tagEMRSELECTCLIPPATH = record
    emr: EMR;
    iMode: DWORD;
  end;
  EMRSELECTCLIPPATH = tagEMRSELECTCLIPPATH;
  LPEMRSELECTCLIPPATH = ^EMRSELECTCLIPPATH;
  TEmrSelectClipPath = EMRSELECTCLIPPATH;

  EMRSETBKMODE = tagEMRSELECTCLIPPATH;
  PEMRSETBKMODE = ^EMRSETBKMODE;
  EMRSETMAPMODE = tagEMRSELECTCLIPPATH;
  PEMRSETMAPMODE = ^EMRSETMAPMODE;
  EMRSETLAYOUT = tagEMRSELECTCLIPPATH;
  PEMRSETLAYOUT = ^EMRSETLAYOUT;
  EMRSETPOLYFILLMODE = tagEMRSELECTCLIPPATH;
  PEMRSETPOLYFILLMODE = EMRSETPOLYFILLMODE;
  EMRSETROP2 = tagEMRSELECTCLIPPATH;
  PEMRSETROP2 = ^EMRSETROP2;
  EMRSETSTRETCHBLTMODE = tagEMRSELECTCLIPPATH;
  PEMRSETSTRETCHBLTMODE = ^EMRSETSTRETCHBLTMODE;
  EMRSETICMMODE = tagEMRSELECTCLIPPATH;
  PEMRSETICMMODE = ^EMRSETICMMODE;
  EMRSETTEXTALIGN = tagEMRSELECTCLIPPATH;
  PEMRSETTEXTALIGN = ^EMRSETTEXTALIGN;

  PEmrSetMiterLimit = ^TEmrSetMiterLimit;
  tagEMRSETMITERLIMIT = record
    emr: EMR;
    eMiterLimit: FLOAT;
  end;
  EMRSETMITERLIMIT = tagEMRSETMITERLIMIT;
  TEmrSetMiterLimit = EMRSETMITERLIMIT;

  PEmrRestoreDc = ^TEmrRestoreDc;
  tagEMRRESTOREDC = record
    emr: EMR;
    iRelative: LONG; // Specifies a relative instance
  end;
  EMRRESTOREDC = tagEMRRESTOREDC;
  TEmrRestoreDc = EMRRESTOREDC;

  PEmrSetArcDirection = ^TEmrSetArcDirection;
  tagEMRSETARCDIRECTION = record
    emr: EMR;
    iArcDirection: DWORD; // Specifies the arc direction in the
    // advanced graphics mode.
  end;
  EMRSETARCDIRECTION = tagEMRSETARCDIRECTION;
  TEmrSetArcDirection = EMRSETARCDIRECTION;

  PEmrSetMapperFlags = ^TEmrSetMapperFlags;
  tagEMRSETMAPPERFLAGS = record
    emr: EMR;
    dwFlags: DWORD;
  end;
  EMRSETMAPPERFLAGS = tagEMRSETMAPPERFLAGS;
  TEmrSetMapperFlags = EMRSETMAPPERFLAGS;

  PEmrSetTextColor = ^TEmrSetTextColor;
  tagEMRSETTEXTCOLOR = record
    emr: EMR;
    crColor: COLORREF;
  end;
  EMRSETTEXTCOLOR = tagEMRSETTEXTCOLOR;
  EMRSETBKCOLOR = tagEMRSETTEXTCOLOR;
  PEMRSETBKCOLOR = ^EMRSETTEXTCOLOR;
  TEmrSetTextColor = EMRSETTEXTCOLOR;

  PEmrSelectObject = ^TEmrSelectObject;
  tagEMRSELECTOBJECT = record
    emr: EMR;
    ihObject: DWORD; // Object handle index
  end;
  EMRSELECTOBJECT = tagEMRSELECTOBJECT;
  EMRDELETEOBJECT = tagEMRSELECTOBJECT;
  PEMRDELETEOBJECT = ^EMRDELETEOBJECT;
  TEmrSelectObject = EMRSELECTOBJECT;

  PEmrSelectPalette = ^TEmrSelectPalette;
  tagEMRSELECTPALETTE = record
    emr: EMR;
    ihPal: DWORD; // Palette handle index, background mode only
  end;
  EMRSELECTPALETTE = tagEMRSELECTPALETTE;
  TEmrSelectPalette = EMRSELECTPALETTE;

  PEmrResizePalette = ^TEmrResizePalette;
  tagEMRRESIZEPALETTE = record
    emr: EMR;
    ihPal: DWORD; // Palette handle index
    cEntries: DWORD;
  end;
  EMRRESIZEPALETTE = tagEMRRESIZEPALETTE;
  TEmrResizePalette = EMRRESIZEPALETTE;

  PEmrSetPaletteEntries = ^TEmrSetPaletteEntries;
  tagEMRSETPALETTEENTRIES = record
    emr: EMR;
    ihPal: DWORD; // Palette handle index
    iStart: DWORD;
    cEntries: DWORD;
    aPalEntries: array [0..0] of PALETTEENTRY; // The peFlags fields do not contain any flags
  end;
  EMRSETPALETTEENTRIES = tagEMRSETPALETTEENTRIES;
  TEmrSetPaletteEntries = EMRSETPALETTEENTRIES;

  PEmrSetColorAdjustment = ^TEmrSetColorAdjustment;
  tagEMRSETCOLORADJUSTMENT = record
    emr: EMR;
    ColorAdjustment: COLORADJUSTMENT;
  end;
  EMRSETCOLORADJUSTMENT = tagEMRSETCOLORADJUSTMENT;
  TEmrSetColorAdjustment = EMRSETCOLORADJUSTMENT;

  PEmrGdiComment = ^TEmrGdiComment;
  tagEMRGDICOMMENT = record
    emr: EMR;
    cbData: DWORD; // Size of data in bytes
    Data: array [0..0] of BYTE;
  end;
  EMRGDICOMMENT = tagEMRGDICOMMENT;
  TEmrGdiComment = EMRGDICOMMENT;

  PEmrEof = ^TEmrEof;
  tagEMREOF = record
    emr: EMR;
    nPalEntries: DWORD; // Number of palette entries
    offPalEntries: DWORD; // Offset to the palette entries
    nSizeLast: DWORD; // Same as nSize and must be the last DWORD
    // of the record.  The palette entries,
    // if exist, precede this field.
  end;
  EMREOF = tagEMREOF;
  TEmrEof = EMREOF;

  PEmrLineTo = ^TEmrLineTo;
  tagEMRLINETO = record
    emr: EMR;
    ptl: POINTL;
  end;
  EMRLINETO = tagEMRLINETO;
  EMRMOVETOEX = tagEMRLINETO;
  PEMRMOVETOEX = ^EMRMOVETOEX;
  TEmrLineTo = EMRLINETO;

  PEmrOffsetClipRgn = ^TEmrOffsetClipRgn;
  tagEMROFFSETCLIPRGN = record
    emr: EMR;
    ptlOffset: POINTL;
  end;
  EMROFFSETCLIPRGN = tagEMROFFSETCLIPRGN;
  TEmrOffsetClipRgn = EMROFFSETCLIPRGN;

  PEmrFillPath = ^TEmrFillPath;
  tagEMRFILLPATH = record
    emr: EMR;
    rclBounds: RECTL; // Inclusive-inclusive bounds in device units
  end;
  EMRFILLPATH = tagEMRFILLPATH;
  EMRSTROKEANDFILLPATH = tagEMRFILLPATH;
  PEMRSTROKEANDFILLPATH = ^EMRSTROKEANDFILLPATH;
  EMRSTROKEPATH = tagEMRFILLPATH;
  PEMRSTROKEPATH = ^EMRSTROKEPATH;
  TEmrFillPath = EMRFILLPATH;

  PEmrExcludeClipRect = ^TEmrExcludeClipRect;
  tagEMREXCLUDECLIPRECT = record
    emr: EMR;
    rclClip: RECTL;
  end;
  EMREXCLUDECLIPRECT = tagEMREXCLUDECLIPRECT;
  EMRINTERSECTCLIPRECT = tagEMREXCLUDECLIPRECT;
  PEMRINTERSECTCLIPRECT = ^EMRINTERSECTCLIPRECT;
  TEmrExcludeClipRect = EMREXCLUDECLIPRECT;

  PEmrSetViewPortOrgEx = ^TEmrSetViewPortOrgEx;
  tagEMRSETVIEWPORTORGEX = record
    emr: EMR;
    ptlOrigin: POINTL;
  end;
  EMRSETVIEWPORTORGEX = tagEMRSETVIEWPORTORGEX;
  EMRSETWINDOWORGEX = tagEMRSETVIEWPORTORGEX;
  PEMRSETWINDOWORGEX = ^EMRSETWINDOWORGEX;
  EMRSETBRUSHORGEX = tagEMRSETVIEWPORTORGEX;
  PEMRSETBRUSHORGEX = ^EMRSETBRUSHORGEX;
  TEmrSetViewPortOrgEx = EMRSETVIEWPORTORGEX;

  PEmrSetViewPortExtEx = ^TEmrSetViewPortExtEx;
  tagEMRSETVIEWPORTEXTEX = record
    emr: EMR;
    szlExtent: SIZEL;
  end;
  EMRSETVIEWPORTEXTEX = tagEMRSETVIEWPORTEXTEX;
  EMRSETWINDOWEXTEX = tagEMRSETVIEWPORTEXTEX;
  TEmrSetViewPortExtEx = EMRSETVIEWPORTEXTEX;

  PEmrScaleViewPortExtEx = ^TEmrScaleViewPortExtEx;
  tagEMRSCALEVIEWPORTEXTEX = record
    emr: EMR;
    xNum: LONG;
    xDenom: LONG;
    yNum: LONG;
    yDenom: LONG;
  end;
  EMRSCALEVIEWPORTEXTEX = tagEMRSCALEVIEWPORTEXTEX;
  EMRSCALEWINDOWEXTEX = tagEMRSCALEVIEWPORTEXTEX;
  PEMRSCALEWINDOWEXTEX = ^EMRSCALEWINDOWEXTEX;
  TEmrScaleViewPortExtEx = EMRSCALEVIEWPORTEXTEX;

  PEmrSetWorldTransform = ^TEmrSetWorldTransform;
  tagEMRSETWORLDTRANSFORM = record
    emr: EMR;
    xform: XFORM;
  end;
  EMRSETWORLDTRANSFORM = tagEMRSETWORLDTRANSFORM;
  TEmrSetWorldTransform = EMRSETWORLDTRANSFORM;

  PEmrModifyWorldTransform = ^TEmrModifyWorldTransform;
  tagEMRMODIFYWORLDTRANSFORM = record
    emr: EMR;
    xform: XFORM;
    iMode: DWORD;
  end;
  EMRMODIFYWORLDTRANSFORM = tagEMRMODIFYWORLDTRANSFORM;
  TEmrModifyWorldTransform = EMRMODIFYWORLDTRANSFORM;

  PEmrSetPixelV = ^TEmrSetPixelV;
  tagEMRSETPIXELV = record
    emr: EMR;
    ptlPixel: POINTL;
    crColor: COLORREF;
  end;
  EMRSETPIXELV = tagEMRSETPIXELV;
  TEmrSetPixelV = EMRSETPIXELV;

  PEmrExtFloodFill = ^TEmrExtFloodFill;
  tagEMREXTFLOODFILL = record
    emr: EMR;
    ptlStart: POINTL;
    crColor: COLORREF;
    iMode: DWORD;
  end;
  EMREXTFLOODFILL = tagEMREXTFLOODFILL;
  TEmrExtFloodFill = EMREXTFLOODFILL;

  PEmrEllipse = ^TEmrEllipse;
  tagEMRELLIPSE = record
    emr: EMR;
    rclBox: RECTL; // Inclusive-inclusive bounding rectangle
  end;
  EMRELLIPSE = tagEMRELLIPSE;
  EMRRECTANGLE = tagEMRELLIPSE;
  PEMRRECTANGLE = ^EMRRECTANGLE;
  TEmrEllipse = EMRELLIPSE;

  PEmrRoundRect = ^TEmrRoundRect;
  tagEMRROUNDRECT = record
    emr: EMR;
    rclBox: RECTL; // Inclusive-inclusive bounding rectangle
    szlCorner: SIZEL;
  end;
  EMRROUNDRECT = tagEMRROUNDRECT;
  TEmrRoundRect = EMRROUNDRECT;

  PEmrArc = ^TEmrArc;
  tagEMRARC = record
    emr: EMR;
    rclBox: RECTL; // Inclusive-inclusive bounding rectangle
    ptlStart: POINTL;
    ptlEnd: POINTL;
  end;
  EMRARC = tagEMRARC;
  EMRARCTO = tagEMRARC;
  PEMRARCTO = ^EMRARCTO;
  EMRCHORD = tagEMRARC;
  PEMRCHORD = ^EMRCHORD;
  EMRPIE = tagEMRARC;
  PEMRPIE = ^EMRPIE;
  TEmrArc = EMRARC;

  PEmrAngleArc = ^TEmrAngleArc;
  tagEMRANGLEARC = record
    emr: EMR;
    ptlCenter: POINTL;
    nRadius: DWORD;
    eStartAngle: FLOAT;
    eSweepAngle: FLOAT;
  end;
  EMRANGLEARC = tagEMRANGLEARC;
  TEmrAngleArc = EMRANGLEARC;

  PEmrPolyline = ^TEmrPolyline;
  tagEMRPOLYLINE = record
    emr: EMR;
    rclBounds: RECTL; // Inclusive-inclusive bounds in device units
    cptl: DWORD;
    aptl: array [0..0] of POINTL;
  end;
  EMRPOLYLINE = tagEMRPOLYLINE;
  EMRPOLYBEZIER = tagEMRPOLYLINE;
  PEMRPOLYBEZIER = ^EMRPOLYBEZIER;
  EMRPOLYGON = tagEMRPOLYLINE;
  PEMRPOLYGON = ^EMRPOLYGON;
  EMRPOLYBEZIERTO = tagEMRPOLYLINE;
  PEMRPOLYBEZIERTO = ^EMRPOLYBEZIERTO;
  EMRPOLYLINETO = tagEMRPOLYLINE;
  PEMRPOLYLINETO = ^EMRPOLYLINETO;
  TEmrPolyline = EMRPOLYLINE;

  PEmrPolyline16 = ^TEmrPolyline16;
  tagEMRPOLYLINE16 = record
    emr: EMR;
    rclBounds: RECTL; // Inclusive-inclusive bounds in device units
    cpts: DWORD;
    apts: array [0..0] of POINTS;
  end;
  EMRPOLYLINE16 = tagEMRPOLYLINE16;
  EMRPOLYBEZIER16 = tagEMRPOLYLINE16;
  PEMRPOLYBEZIER16 = ^EMRPOLYBEZIER16;
  EMRPOLYGON16 = tagEMRPOLYLINE16;
  PEMRPOLYGON16 = ^EMRPOLYGON16;
  EMRPOLYBEZIERTO16 = tagEMRPOLYLINE16;
  PEMRPOLYBEZIERTO16 = ^EMRPOLYBEZIERTO16;
  EMRPOLYLINETO16 = tagEMRPOLYLINE16;
  PEMRPOLYLINETO16 = ^EMRPOLYLINETO16;
  TEmrPolyline16 = EMRPOLYLINE16;

  PEmrPolyDraw = ^TEmrPolyDraw;
  tagEMRPOLYDRAW = record
    emr: EMR;
    rclBounds: RECTL; // Inclusive-inclusive bounds in device units
    cptl: DWORD; // Number of points
    aptl: array [0..0] of POINTL; // Array of points
    abTypes: array [0..0] of BYTE; // Array of point types
  end;
  EMRPOLYDRAW = tagEMRPOLYDRAW;
  TEmrPolyDraw = EMRPOLYDRAW;

  PEmrPolyDraw16 = ^TEmrPolyDraw16;
  tagEMRPOLYDRAW16 = record
    emr: EMR;
    rclBounds: RECTL; // Inclusive-inclusive bounds in device units
    cpts: DWORD; // Number of points
    apts: array [0..0] of POINTS; // Array of points
    abTypes: array [0..0] of BYTE; // Array of point types
  end;
  EMRPOLYDRAW16 = tagEMRPOLYDRAW16;
  TEmrPolyDraw16 = EMRPOLYDRAW16;

  PEmrPolyPolyline = ^TEmrPolyPolyline;
  tagEMRPOLYPOLYLINE = record
    emr: EMR;
    rclBounds: RECTL; // Inclusive-inclusive bounds in device units
    nPolys: DWORD; // Number of polys
    cptl: DWORD; // Total number of points in all polys
    aPolyCounts: array [0..0] of DWORD; // Array of point counts for each poly
    aptl: array [0..0] of POINTL; // Array of points
  end;
  EMRPOLYPOLYLINE = tagEMRPOLYPOLYLINE;
  EMRPOLYPOLYGON = tagEMRPOLYPOLYLINE;
  TEmrPolyPolyline = EMRPOLYPOLYLINE;

  PEmrPolyPolyline16 = ^TEmrPolyPolyline16;
  tagEMRPOLYPOLYLINE16 = record
    emr: EMR;
    rclBounds: RECTL; // Inclusive-inclusive bounds in device units
    nPolys: DWORD; // Number of polys
    cpts: DWORD; // Total number of points in all polys
    aPolyCounts: array [0..0] of DWORD; // Array of point counts for each poly
    apts: array [0..0] of POINTS; // Array of points
  end;
  EMRPOLYPOLYLINE16 = tagEMRPOLYPOLYLINE16;
  EMRPOLYPOLYGON16 = tagEMRPOLYPOLYLINE16;
  PEMRPOLYPOLYGON16 = ^EMRPOLYPOLYGON16;
  TEmrPolyPolyline16 = EMRPOLYPOLYLINE16;

  PEmrInvertRgn = ^TEmrInvertRgn;
  tagEMRINVERTRGN = record
    emr: EMR;
    rclBounds: RECTL; // Inclusive-inclusive bounds in device units
    cbRgnData: DWORD; // Size of region data in bytes
    RgnData: array [0..0] of BYTE;
  end;
  EMRINVERTRGN = tagEMRINVERTRGN;
  EMRPAINTRGN = tagEMRINVERTRGN;
  TEmrInvertRgn = EMRINVERTRGN;

  PEmrFillRgn = ^TEmrFillRgn;
  tagEMRFILLRGN = record
    emr: EMR;
    rclBounds: RECTL; // Inclusive-inclusive bounds in device units
    cbRgnData: DWORD; // Size of region data in bytes
    ihBrush: DWORD; // Brush handle index
    RgnData: array [0..0] of BYTE;
  end;
  EMRFILLRGN = tagEMRFILLRGN;
  TEmrFillRgn = EMRFILLRGN;

  PEmrFrameRgn = ^TEmrFrameRgn;
  tagEMRFRAMERGN = record
    emr: EMR;
    rclBounds: RECTL; // Inclusive-inclusive bounds in device units
    cbRgnData: DWORD; // Size of region data in bytes
    ihBrush: DWORD; // Brush handle index
    szlStroke: SIZEL;
    RgnData: array [0..0] of BYTE;
  end;
  EMRFRAMERGN = tagEMRFRAMERGN;
  TEmrFrameRgn = EMRFRAMERGN;

  PEmrExtSelectClipRgn = ^TEmrExtSelectClipRgn;
  tagEMREXTSELECTCLIPRGN = record
    emr: EMR;
    cbRgnData: DWORD; // Size of region data in bytes
    iMode: DWORD;
    RgnData: array [0..0] of BYTE;
  end;
  EMREXTSELECTCLIPRGN = tagEMREXTSELECTCLIPRGN;
  TEmrExtSelectClipRgn = EMREXTSELECTCLIPRGN;

  PEmrExtTextOutA = ^TEmrExtTextOutA;
  tagEMREXTTEXTOUTA = record
    emr: EMR;
    rclBounds: RECTL;     // Inclusive-inclusive bounds in device units
    iGraphicsMode: DWORD; // Current graphics mode
    exScale: FLOAT;       // X and Y scales from Page units to .01mm units
    eyScale: FLOAT;       // if graphics mode is GM_COMPATIBLE.
    emrtext: EMRTEXT;     // This is followed by the string and spacing array
  end;
  EMREXTTEXTOUTA = tagEMREXTTEXTOUTA;
  EMREXTTEXTOUTW = tagEMREXTTEXTOUTA;
  PEMREXTTEXTOUTW = ^EMREXTTEXTOUTW;
  TEmrExtTextOutA = EMREXTTEXTOUTA;

  PEmrPolyTextOutA = ^TEmrPolyTextOutA;
  tagEMRPOLYTEXTOUTA = record
    emr: EMR;
    rclBounds: RECTL; // Inclusive-inclusive bounds in device units
    iGraphicsMode: DWORD; // Current graphics mode
    exScale: FLOAT; // X and Y scales from Page units to .01mm units
    eyScale: FLOAT; // if graphics mode is GM_COMPATIBLE.
    cStrings: LONG;
    aemrtext: array [0..0] of EMRTEXT; // Array of EMRTEXT structures.  This is
    // followed by the strings and spacing arrays.
  end;
  EMRPOLYTEXTOUTA = tagEMRPOLYTEXTOUTA;
  EMRPOLYTEXTOUTW = tagEMRPOLYTEXTOUTA;
  PEMRPOLYTEXTOUTW = ^EMRPOLYTEXTOUTW;
  TEmrPolyTextOutA = EMRPOLYTEXTOUTA;

  PEmrBitBlt = ^TEmrBitBlt;
  tagEMRBITBLT = record
    emr: EMR;
    rclBounds: RECTL; // Inclusive-inclusive bounds in device units
    xDest: LONG;
    yDest: LONG;
    cxDest: LONG;
    cyDest: LONG;
    dwRop: DWORD;
    xSrc: LONG;
    ySrc: LONG;
    xformSrc: XFORM; // Source DC transform
    crBkColorSrc: COLORREF; // Source DC BkColor in RGB
    iUsageSrc: DWORD; // Source bitmap info color table usage
    // (DIB_RGB_COLORS)
    offBmiSrc: DWORD; // Offset to the source BITMAPINFO structure
    cbBmiSrc: DWORD; // Size of the source BITMAPINFO structure
    offBitsSrc: DWORD; // Offset to the source bitmap bits
    cbBitsSrc: DWORD; // Size of the source bitmap bits
  end;
  EMRBITBLT = tagEMRBITBLT;
  TEmrBitBlt = EMRBITBLT;

  PEmrStretchBlt = ^TEmrStretchBlt;
  tagEMRSTRETCHBLT = record
    emr: EMR;
    rclBounds: RECTL; // Inclusive-inclusive bounds in device units
    xDest: LONG;
    yDest: LONG;
    cxDest: LONG;
    cyDest: LONG;
    dwRop: DWORD;
    xSrc: LONG;
    ySrc: LONG;
    xformSrc: XFORM; // Source DC transform
    crBkColorSrc: COLORREF; // Source DC BkColor in RGB
    iUsageSrc: DWORD; // Source bitmap info color table usage
    // (DIB_RGB_COLORS)
    offBmiSrc: DWORD; // Offset to the source BITMAPINFO structure
    cbBmiSrc: DWORD; // Size of the source BITMAPINFO structure
    offBitsSrc: DWORD; // Offset to the source bitmap bits
    cbBitsSrc: DWORD; // Size of the source bitmap bits
    cxSrc: LONG;
    cySrc: LONG;
  end;
  EMRSTRETCHBLT = tagEMRSTRETCHBLT;
  TEmrStretchBlt = EMRSTRETCHBLT;

  PEmrMaskBlt = ^TEmrMaskBlt;
  tagEMRMASKBLT = record
    emr: EMR;
    rclBounds: RECTL; // Inclusive-inclusive bounds in device units
    xDest: LONG;
    yDest: LONG;
    cxDest: LONG;
    cyDest: LONG;
    dwRop: DWORD;
    xSrc: LONG;
    ySrc: LONG;
    xformSrc: XFORM; // Source DC transform
    crBkColorSrc: COLORREF; // Source DC BkColor in RGB
    iUsageSrc: DWORD; // Source bitmap info color table usage
    // (DIB_RGB_COLORS)
    offBmiSrc: DWORD; // Offset to the source BITMAPINFO structure
    cbBmiSrc: DWORD; // Size of the source BITMAPINFO structure
    offBitsSrc: DWORD; // Offset to the source bitmap bits
    cbBitsSrc: DWORD; // Size of the source bitmap bits
    xMask: LONG;
    yMask: LONG;
    iUsageMask: DWORD; // Mask bitmap info color table usage
    offBmiMask: DWORD; // Offset to the mask BITMAPINFO structure if any
    cbBmiMask: DWORD; // Size of the mask BITMAPINFO structure if any
    offBitsMask: DWORD; // Offset to the mask bitmap bits if any
    cbBitsMask: DWORD; // Size of the mask bitmap bits if any
  end;
  EMRMASKBLT = tagEMRMASKBLT;
  TEmrMaskBlt = EMRMASKBLT;

  PEmrPlgBlt = ^TEmrPlgBlt;
  tagEMRPLGBLT = record
    emr: EMR;
    rclBounds: RECTL; // Inclusive-inclusive bounds in device units
    aptlDest: array[0..2] of POINTL;
    xSrc: LONG;
    ySrc: LONG;
    cxSrc: LONG;
    cySrc: LONG;
    xformSrc: XFORM; // Source DC transform
    crBkColorSrc: COLORREF; // Source DC BkColor in RGB
    iUsageSrc: DWORD; // Source bitmap info color table usage
    // (DIB_RGB_COLORS)
    offBmiSrc: DWORD; // Offset to the source BITMAPINFO structure
    cbBmiSrc: DWORD; // Size of the source BITMAPINFO structure
    offBitsSrc: DWORD; // Offset to the source bitmap bits
    cbBitsSrc: DWORD; // Size of the source bitmap bits
    xMask: LONG;
    yMask: LONG;
    iUsageMask: DWORD; // Mask bitmap info color table usage
    offBmiMask: DWORD; // Offset to the mask BITMAPINFO structure if any
    cbBmiMask: DWORD; // Size of the mask BITMAPINFO structure if any
    offBitsMask: DWORD; // Offset to the mask bitmap bits if any
    cbBitsMask: DWORD; // Size of the mask bitmap bits if any
  end;
  EMRPLGBLT = tagEMRPLGBLT;
  TEmrPlgBlt = EMRPLGBLT;

  PEmrSetDiBitsToDevice = ^TEmrSetDiBitsToDevice;
  tagEMRSETDIBITSTODEVICE = record
    emr: EMR;
    rclBounds: RECTL; // Inclusive-inclusive bounds in device units
    xDest: LONG;
    yDest: LONG;
    xSrc: LONG;
    ySrc: LONG;
    cxSrc: LONG;
    cySrc: LONG;
    offBmiSrc: DWORD; // Offset to the source BITMAPINFO structure
    cbBmiSrc: DWORD; // Size of the source BITMAPINFO structure
    offBitsSrc: DWORD; // Offset to the source bitmap bits
    cbBitsSrc: DWORD; // Size of the source bitmap bits
    iUsageSrc: DWORD; // Source bitmap info color table usage
    iStartScan: DWORD;
    cScans: DWORD;
  end;
  EMRSETDIBITSTODEVICE = tagEMRSETDIBITSTODEVICE;
  TEmrSetDiBitsToDevice = EMRSETDIBITSTODEVICE;

  PEmrStretchDiBits = ^TEmrStretchDiBits;
  tagEMRSTRETCHDIBITS = record
    emr: EMR;
    rclBounds: RECTL; // Inclusive-inclusive bounds in device units
    xDest: LONG;
    yDest: LONG;
    xSrc: LONG;
    ySrc: LONG;
    cxSrc: LONG;
    cySrc: LONG;
    offBmiSrc: DWORD; // Offset to the source BITMAPINFO structure
    cbBmiSrc: DWORD; // Size of the source BITMAPINFO structure
    offBitsSrc: DWORD; // Offset to the source bitmap bits
    cbBitsSrc: DWORD; // Size of the source bitmap bits
    iUsageSrc: DWORD; // Source bitmap info color table usage
    dwRop: DWORD;
    cxDest: LONG;
    cyDest: LONG;
  end;
  EMRSTRETCHDIBITS = tagEMRSTRETCHDIBITS;
  TEmrStretchDiBits = EMRSTRETCHDIBITS;

  PEmrExtCreateFontIndirectW = ^TEmrExtCreateFontIndirectW;
  tagEMREXTCREATEFONTINDIRECTW = record
    emr: EMR;
    ihFont: DWORD; // Font handle index
    elfw: EXTLOGFONTW;
  end;
  EMREXTCREATEFONTINDIRECTW = tagEMREXTCREATEFONTINDIRECTW;
  TEmrExtCreateFontIndirectW = EMREXTCREATEFONTINDIRECTW;

  PEmrCreatePalette = ^TEmrCreatePalette;
  tagEMRCREATEPALETTE = record
    emr: EMR;
    ihPal: DWORD; // Palette handle index
    lgpl: LOGPALETTE; // The peFlags fields in the palette entries
    // do not contain any flags
  end;
  EMRCREATEPALETTE = tagEMRCREATEPALETTE;
  TEmrCreatePalette = EMRCREATEPALETTE;

  PEmrCreatePen = ^TEmrCreatePen;
  tagEMRCREATEPEN = record
    emr: EMR;
    ihPen: DWORD; // Pen handle index
    lopn: LOGPEN;
  end;
  EMRCREATEPEN = tagEMRCREATEPEN;
  TEmrCreatePen = EMRCREATEPEN;

  PEmrExtCreatePen = ^TEmrExtCreatePen;
  tagEMREXTCREATEPEN = record
    emr: EMR;
    ihPen: DWORD; // Pen handle index
    offBmi: DWORD; // Offset to the BITMAPINFO structure if any
    cbBmi: DWORD; // Size of the BITMAPINFO structure if any
    // The bitmap info is followed by the bitmap
    // bits to form a packed DIB.
    offBits: DWORD; // Offset to the brush bitmap bits if any
    cbBits: DWORD; // Size of the brush bitmap bits if any
    elp: EXTLOGPEN; // The extended pen with the style array.
  end;
  EMREXTCREATEPEN = tagEMREXTCREATEPEN;
  TEmrExtCreatePen = EMREXTCREATEPEN;

  PEmrCreateBrushIndirect = ^TEmrCreateBrushIndirect;
  tagEMRCREATEBRUSHINDIRECT = record
    emr: EMR;
    ihBrush: DWORD; // Brush handle index
    lb: LOGBRUSH32; // The style must be BS_SOLID, BS_HOLLOW,
    // BS_NULL or BS_HATCHED.
  end;
  EMRCREATEBRUSHINDIRECT = tagEMRCREATEBRUSHINDIRECT;
  TEmrCreateBrushIndirect = EMRCREATEBRUSHINDIRECT;

  PEmrCreateMonoBrush = ^TEmrCreateMonoBrush;
  tagEMRCREATEMONOBRUSH = record
    emr: EMR;
    ihBrush: DWORD; // Brush handle index
    iUsage: DWORD; // Bitmap info color table usage
    offBmi: DWORD; // Offset to the BITMAPINFO structure
    cbBmi: DWORD; // Size of the BITMAPINFO structure
    offBits: DWORD; // Offset to the bitmap bits
    cbBits: DWORD; // Size of the bitmap bits
  end;
  EMRCREATEMONOBRUSH = tagEMRCREATEMONOBRUSH;
  TEmrCreateMonoBrush = EMRCREATEMONOBRUSH;

  PEmrCreateDibPatternBrushPt = ^TEmrCreateDibPatternBrushPt;
  tagEMRCREATEDIBPATTERNBRUSHPT = record
    emr: EMR;
    ihBrush: DWORD; // Brush handle index
    iUsage: DWORD; // Bitmap info color table usage
    offBmi: DWORD; // Offset to the BITMAPINFO structure
    cbBmi: DWORD; // Size of the BITMAPINFO structure
    // The bitmap info is followed by the bitmap
    // bits to form a packed DIB.
    offBits: DWORD; // Offset to the bitmap bits
    cbBits: DWORD; // Size of the bitmap bits
  end;
  EMRCREATEDIBPATTERNBRUSHPT = tagEMRCREATEDIBPATTERNBRUSHPT;
  TEmrCreateDibPatternBrushPt = EMRCREATEDIBPATTERNBRUSHPT;

  PEmrFormat = ^TEmrFormat;
  tagEMRFORMAT = record
    dSignature: DWORD; // Format signature, e.g. ENHMETA_SIGNATURE.
    nVersion: DWORD; // Format version number.
    cbData: DWORD; // Size of data in bytes.
    offData: DWORD; // Offset to data from GDICOMMENT_IDENTIFIER.
    // It must begin at a DWORD offset.
  end;
  EMRFORMAT = tagEMRFORMAT;
  TEmrFormat = EMRFORMAT;

  PEmrGlsRecord = ^TEmrGlsRecord;
  tagEMRGLSRECORD = record
    emr: EMR;
    cbData: DWORD; // Size of data in bytes
    Data: array [0..0] of BYTE;
  end;
  EMRGLSRECORD = tagEMRGLSRECORD;
  TEmrGlsRecord = EMRGLSRECORD;

  PEmrGlsBoundedRecord = ^TEmrGlsBoundedRecord;
  tagEMRGLSBOUNDEDRECORD = record
    emr: EMR;
    rclBounds: RECTL; // Bounds in recording coordinates
    cbData: DWORD; // Size of data in bytes
    Data: array [0..0] of BYTE;
  end;
  EMRGLSBOUNDEDRECORD = tagEMRGLSBOUNDEDRECORD;
  TEmrGlsBoundedRecord = EMRGLSBOUNDEDRECORD;

  PEmrPixelFormat = ^TEmrPixelFormat;
  tagEMRPIXELFORMAT = record
    emr: EMR;
    pfd: PIXELFORMATDESCRIPTOR;
  end;
  EMRPIXELFORMAT = tagEMRPIXELFORMAT;
  TEmrPixelFormat = EMRPIXELFORMAT;

  PEmrCreateColorSpace = ^TEmrCreateColorSpace;
  tagEMRCREATECOLORSPACE = record
    emr: EMR;
    ihCS: DWORD; // ColorSpace handle index
    lcs: LOGCOLORSPACEA; // Ansi version of LOGCOLORSPACE
  end;
  EMRCREATECOLORSPACE = tagEMRCREATECOLORSPACE;
  TEmrCreateColorSpace = EMRCREATECOLORSPACE;

  PEmrSetColorSpace = ^TEmrSetColorSpace;
  tagEMRSETCOLORSPACE = record
    emr: EMR;
    ihCS: DWORD; // ColorSpace handle index
  end;
  EMRSETCOLORSPACE = tagEMRSETCOLORSPACE;
  EMRSELECTCOLORSPACE = tagEMRSETCOLORSPACE;
  PEMRSELECTCOLORSPACE = ^EMRSELECTCOLORSPACE;
  EMRDELETECOLORSPACE = tagEMRSETCOLORSPACE;
  PEMRDELETECOLORSPACE = ^EMRDELETECOLORSPACE;
  TEmrSetColorSpace = EMRSETCOLORSPACE;

  PEmrExtEscape = ^TEmrExtEscape;
  tagEMREXTESCAPE = record
    emr: EMR;
    iEscape: INT; // Escape code
    cbEscData: INT; // Size of escape data
    EscData: array [0..0] of BYTE; // Escape data
  end;
  EMREXTESCAPE = tagEMREXTESCAPE;
  EMRDRAWESCAPE = tagEMREXTESCAPE;
  PEMRDRAWESCAPE = ^EMRDRAWESCAPE;
  TEmrExtEscape = EMREXTESCAPE;

  PEmrNamedEscape = ^TEmrNamedEscape;
  tagEMRNAMEDESCAPE = record
    emr: EMR;
    iEscape: INT; // Escape code
    cbDriver: INT; // Size of driver name
    cbEscData: INT; // Size of escape data
    EscData: array [0..0] of BYTE; // Driver name and Escape data
  end;
  EMRNAMEDESCAPE = tagEMRNAMEDESCAPE;
  TEmrNamedEscape = EMRNAMEDESCAPE;

const
  SETICMPROFILE_EMBEDED = $00000001;

type
  PEmrSetIcmProfile = ^TEmrSetIcmProfile;
  tagEMRSETICMPROFILE = record
    emr: EMR;
    dwFlags: DWORD; // flags
    cbName: DWORD; // Size of desired profile name
    cbData: DWORD; // Size of raw profile data if attached
    Data: array [0..0] of BYTE; // Array size is cbName + cbData
  end;
  EMRSETICMPROFILE = tagEMRSETICMPROFILE;
  EMRSETICMPROFILEA = tagEMRSETICMPROFILE;
  PEMRSETICMPROFILEA = ^EMRSETICMPROFILEA;
  EMRSETICMPROFILEW = tagEMRSETICMPROFILE;
  PEMRSETICMPROFILEW = ^EMRSETICMPROFILEW;
  TEmrSetIcmProfile = EMRSETICMPROFILE;

const
  CREATECOLORSPACE_EMBEDED = $00000001;

type
  PEmrCreateColorSpaceW = ^TEmrCreateColorSpaceW;
  tagEMRCREATECOLORSPACEW = record
    emr: EMR;
    ihCS: DWORD; // ColorSpace handle index
    lcs: LOGCOLORSPACEW; // Unicode version of logical color space structure
    dwFlags: DWORD; // flags
    cbData: DWORD; // size of raw source profile data if attached
    Data: array [0..0] of BYTE; // Array size is cbData
  end;
  EMRCREATECOLORSPACEW = tagEMRCREATECOLORSPACEW;
  TEmrCreateColorSpaceW = EMRCREATECOLORSPACEW;

const
  COLORMATCHTOTARGET_EMBEDED = $00000001;

type
  PColorMatchToTarget = ^TColorMatchToTarget;
  tagCOLORMATCHTOTARGET = record
    emr: EMR;
    dwAction: DWORD;  // CS_ENABLE, CS_DISABLE or CS_DELETE_TRANSFORM
    dwFlags: DWORD;   // flags
    cbName: DWORD;    // Size of desired target profile name
    cbData: DWORD;    // Size of raw target profile data if attached
    Data: array [0..0] of BYTE; // Array size is cbName + cbData
  end;
  //COLORMATCHTOTARGET = tagCOLORMATCHTOTARGET;
  TColorMatchToTarget = tagCOLORMATCHTOTARGET;

  PColorCorrectPalette = ^TColorCorrectPalette;
  tagCOLORCORRECTPALETTE = record
    emr: EMR;
    ihPalette: DWORD;   // Palette handle index
    nFirstEntry: DWORD; // Index of first entry to correct
    nPalEntries: DWORD; // Number of palette entries to correct
    nReserved: DWORD;   // Reserved
  end;
  //COLORCORRECTPALETTE = tagCOLORCORRECTPALETTE;
  TColorCorrectPalette = tagCOLORCORRECTPALETTE;

  PEmrAlphaBlend = ^TEmrAlphaBlend;
  tagEMRALPHABLEND = record
    emr: EMR;
    rclBounds: RECTL;       // Inclusive-inclusive bounds in device units
    xDest: LONG;
    yDest: LONG;
    cxDest: LONG;
    cyDest: LONG;
    dwRop: DWORD;
    xSrc: LONG;
    ySrc: LONG;
    xformSrc: XFORM;        // Source DC transform
    crBkColorSrc: COLORREF; // Source DC BkColor in RGB
    iUsageSrc: DWORD;       // Source bitmap info color table usage (DIB_RGB_COLORS)
    offBmiSrc: DWORD;       // Offset to the source BITMAPINFO structure
    cbBmiSrc: DWORD;        // Size of the source BITMAPINFO structure
    offBitsSrc: DWORD;      // Offset to the source bitmap bits
    cbBitsSrc: DWORD;       // Size of the source bitmap bits
    cxSrc: LONG;
    cySrc: LONG;
  end;
  EMRALPHABLEND = tagEMRALPHABLEND;
  TEmrAlphaBlend = EMRALPHABLEND;

  PEmrGradientFill = ^TEmrGradientFill;
  tagEMRGRADIENTFILL = record
    emr: EMR;
    rclBounds: RECTL; // Inclusive-inclusive bounds in device units
    nVer: DWORD;
    nTri: DWORD;
    ulMode: ULONG;
    Ver: array [0..0] of TRIVERTEX;
  end;
  EMRGRADIENTFILL = tagEMRGRADIENTFILL;
  TEmrGradientFill = EMRGRADIENTFILL;

  PEmrTransparentBlt = ^TEmrTransparentBlt;
  tagEMRTRANSPARENTBLT = record
    emr: EMR;
    rclBounds: RECTL;       // Inclusive-inclusive bounds in device units
    xDest: LONG;
    yDest: LONG;
    cxDest: LONG;
    cyDest: LONG;
    dwRop: DWORD;
    xSrc: LONG;
    ySrc: LONG;
    xformSrc: XFORM;        // Source DC transform
    crBkColorSrc: COLORREF; // Source DC BkColor in RGB
    iUsageSrc: DWORD;       // Source bitmap info color table usage
                            // (DIB_RGB_COLORS)
    offBmiSrc: DWORD;       // Offset to the source BITMAPINFO structure
    cbBmiSrc: DWORD;        // Size of the source BITMAPINFO structure
    offBitsSrc: DWORD;      // Offset to the source bitmap bits
    cbBitsSrc: DWORD;       // Size of the source bitmap bits
    cxSrc: LONG;
    cySrc: LONG;
  end;
  EMRTRANSPARENTBLT = tagEMRTRANSPARENTBLT;
  TEmrTransparentBlt = EMRTRANSPARENTBLT;

const
  GDICOMMENT_IDENTIFIER       = $43494447;
  GDICOMMENT_WINDOWS_METAFILE = DWORD($80000001);
  GDICOMMENT_BEGINGROUP       = $00000002;
  GDICOMMENT_ENDGROUP         = $00000003;
  GDICOMMENT_MULTIFORMATS     = $40000004;
  EPS_SIGNATURE               = $46535045;
  GDICOMMENT_UNICODE_STRING   = $00000040;
  GDICOMMENT_UNICODE_END      = $00000080;

// OpenGL wgl prototypes

function wglCopyContext(hglrcSrc, hglrcDest: HGLRC; mask: UINT): BOOL; stdcall;
function wglCreateContext(hdc: HDC): HGLRC; stdcall;
function wglCreateLayerContext(hdc: HDC; iLayerPlane: Integer): HGLRC; stdcall;
function wglDeleteContext(hglrc: HGLRC): BOOL; stdcall;
function wglGetCurrentContext: HGLRC; stdcall;
function wglGetCurrentDC: HDC; stdcall;
function wglGetProcAddress(lpszProc: LPCSTR): PROC; stdcall;
function wglMakeCurrent(hdc: HDC; hglrc: HGLRC): BOOL; stdcall;
function wglShareLists(hglrc1, hglrc2: HGLRC): BOOL; stdcall;

function wglUseFontBitmapsA(hdc: HDC; first, count, listBase: DWORD): BOOL; stdcall;
function wglUseFontBitmapsW(hdc: HDC; first, count, listBase: DWORD): BOOL; stdcall;
function wglUseFontBitmaps(hdc: HDC; first, count, listBase: DWORD): BOOL; stdcall;

function SwapBuffers(hdc: HDC): BOOL; stdcall;

type
  PPointFloat = ^TPointFloat;
  _POINTFLOAT = record
    x: FLOAT;
    y: FLOAT;
  end;
  POINTFLOAT = _POINTFLOAT;
  TPointFloat = _POINTFLOAT;

  PGlyphMetricsFloat = ^TGlyphMetricsFloat;
  _GLYPHMETRICSFLOAT = record
    gmfBlackBoxX: FLOAT;
    gmfBlackBoxY: FLOAT;
    gmfptGlyphOrigin: POINTFLOAT;
    gmfCellIncX: FLOAT;
    gmfCellIncY: FLOAT;
  end;
  GLYPHMETRICSFLOAT = _GLYPHMETRICSFLOAT;
  LPGLYPHMETRICSFLOAT = ^GLYPHMETRICSFLOAT;
  TGlyphMetricsFloat = _GLYPHMETRICSFLOAT;

const
  WGL_FONT_LINES    = 0;
  WGL_FONT_POLYGONS = 1;

function wglUseFontOutlinesA(hdc: HDC; first, count, listBase: DWORD; deviation,
  extrusion: FLOAT; format: Integer; lpgmf: LPGLYPHMETRICSFLOAT): BOOL; stdcall;
function wglUseFontOutlinesW(hdc: HDC; first, count, listBase: DWORD; deviation,
  extrusion: FLOAT; format: Integer; lpgmf: LPGLYPHMETRICSFLOAT): BOOL; stdcall;
function wglUseFontOutlines(hdc: HDC; first, count, listBase: DWORD; deviation,
  extrusion: FLOAT; format: Integer; lpgmf: LPGLYPHMETRICSFLOAT): BOOL; stdcall;

// Layer plane descriptor

type
  PLayerPlaneDescriptor = ^TLayerPlaneDescriptor;
  tagLAYERPLANEDESCRIPTOR = record
    nSize: WORD;
    nVersion: WORD;
    dwFlags: DWORD;
    iPixelType: BYTE;
    cColorBits: BYTE;
    cRedBits: BYTE;
    cRedShift: BYTE;
    cGreenBits: BYTE;
    cGreenShift: BYTE;
    cBlueBits: BYTE;
    cBlueShift: BYTE;
    cAlphaBits: BYTE;
    cAlphaShift: BYTE;
    cAccumBits: BYTE;
    cAccumRedBits: BYTE;
    cAccumGreenBits: BYTE;
    cAccumBlueBits: BYTE;
    cAccumAlphaBits: BYTE;
    cDepthBits: BYTE;
    cStencilBits: BYTE;
    cAuxBuffers: BYTE;
    iLayerPlane: BYTE;
    bReserved: BYTE;
    crTransparent: COLORREF;
  end;
  LAYERPLANEDESCRIPTOR = tagLAYERPLANEDESCRIPTOR;
  LPLAYERPLANEDESCRIPTOR = ^LAYERPLANEDESCRIPTOR;
  TLayerPlaneDescriptor = LAYERPLANEDESCRIPTOR;

// LAYERPLANEDESCRIPTOR flags

const
  LPD_DOUBLEBUFFER   = $00000001;
  LPD_STEREO         = $00000002;
  LPD_SUPPORT_GDI    = $00000010;
  LPD_SUPPORT_OPENGL = $00000020;
  LPD_SHARE_DEPTH    = $00000040;
  LPD_SHARE_STENCIL  = $00000080;
  LPD_SHARE_ACCUM    = $00000100;
  LPD_SWAP_EXCHANGE  = $00000200;
  LPD_SWAP_COPY      = $00000400;
  LPD_TRANSPARENT    = $00001000;

  LPD_TYPE_RGBA       = 0;
  LPD_TYPE_COLORINDEX = 1;

// wglSwapLayerBuffers flags

  WGL_SWAP_MAIN_PLANE = $00000001;
  WGL_SWAP_OVERLAY1   = $00000002;
  WGL_SWAP_OVERLAY2   = $00000004;
  WGL_SWAP_OVERLAY3   = $00000008;
  WGL_SWAP_OVERLAY4   = $00000010;
  WGL_SWAP_OVERLAY5   = $00000020;
  WGL_SWAP_OVERLAY6   = $00000040;
  WGL_SWAP_OVERLAY7   = $00000080;
  WGL_SWAP_OVERLAY8   = $00000100;
  WGL_SWAP_OVERLAY9   = $00000200;
  WGL_SWAP_OVERLAY10  = $00000400;
  WGL_SWAP_OVERLAY11  = $00000800;
  WGL_SWAP_OVERLAY12  = $00001000;
  WGL_SWAP_OVERLAY13  = $00002000;
  WGL_SWAP_OVERLAY14  = $00004000;
  WGL_SWAP_OVERLAY15  = $00008000;
  WGL_SWAP_UNDERLAY1  = $00010000;
  WGL_SWAP_UNDERLAY2  = $00020000;
  WGL_SWAP_UNDERLAY3  = $00040000;
  WGL_SWAP_UNDERLAY4  = $00080000;
  WGL_SWAP_UNDERLAY5  = $00100000;
  WGL_SWAP_UNDERLAY6  = $00200000;
  WGL_SWAP_UNDERLAY7  = $00400000;
  WGL_SWAP_UNDERLAY8  = $00800000;
  WGL_SWAP_UNDERLAY9  = $01000000;
  WGL_SWAP_UNDERLAY10 = $02000000;
  WGL_SWAP_UNDERLAY11 = $04000000;
  WGL_SWAP_UNDERLAY12 = $08000000;
  WGL_SWAP_UNDERLAY13 = $10000000;
  WGL_SWAP_UNDERLAY14 = $20000000;
  WGL_SWAP_UNDERLAY15 = $40000000;

function wglDescribeLayerPlane(hdc: HDC; iPixelFormat, iLayerPlane: Integer;
  nBytes: UINT; plpd: LPLAYERPLANEDESCRIPTOR): BOOL; stdcall;
function wglSetLayerPaletteEntries(hdc: HDC; iLayerPlane, iStart, cEntries: Integer;
  pcr: LPCOLORREF): Integer; stdcall;
function wglGetLayerPaletteEntries(hdc: HDC; iLayerPlane, iStart, cEntries: Integer;
  pcr: LPCOLORREF): Integer; stdcall;
function wglRealizeLayerPalette(hdc: HDC; iLayerPlane: Integer; bRealize: BOOL): BOOL; stdcall;
function wglSwapLayerBuffers(hdc: HDC; fuPlanes: UINT): BOOL; stdcall;

type
  PWglSwap = ^TWglSwap;
  _WGLSWAP = record
    hdc: HDC;
    uiFlags: UINT;
  end;
  WGLSWAP = _WGLSWAP;
  LPWGLSWAP = ^WGLSWAP;
  TWglSwap = _WGLSWAP;

const
  WGL_SWAPMULTIPLE_MAX = 16;

function wglSwapMultipleBuffers(fuCount: UINT; lpBuffers: LPWGLSWAP): DWORD; stdcall;

implementation

function MAKEROP4(Fore, Back: DWORD): DWORD;
begin
  Result := ((Back shl 8) and DWORD($FF000000)) or Fore;
end;

function GetKValue(cmyk: COLORREF): BYTE;
begin
  Result := BYTE(cmyk);
end;

function GetYValue(cmyk: COLORREF): BYTE;
begin
  Result := BYTE(cmyk shr 8);
end;

function GetMValue(cmyk: COLORREF): BYTE;
begin
  Result := BYTE(cmyk shr 16);
end;

function GetCValue(cmyk: COLORREF): BYTE;
begin
  Result := BYTE(cmyk shr 24);
end;

function CMYK(c, m, y, k: BYTE): COLORREF;
begin
  Result := COLORREF(k or (y shl 8) or (m shl 16) or (c shl 24));
end;

function MAKEPOINTS(l: DWORD): POINTS;
begin
  Result.x := LOWORD(l);
  Result.y := HIWORD(l);  
end;

function RGB(r, g, b: BYTE): COLORREF;
begin
  Result := COLORREF(r or (g shl 8) or (b shl 16));
end;

function PALETTERGB(r, g, b: BYTE): COLORREF;
begin
  Result := $02000000 or RGB(r, g, b);
end;

function PALETTEINDEX(i: WORD): COLORREF;
begin
  Result := COLORREF($01000000 or DWORD(i));
end;

function GetRValue(rgb: COLORREF): BYTE;
begin
  Result := BYTE(RGB);
end;

function GetGValue(rgb: COLORREF): BYTE;
begin
  Result := BYTE(rgb shr 8);
end;

function GetBValue(rgb: COLORREF): BYTE;
begin
  Result := BYTE(rgb shr 16);
end;

function AddFontResourceA; external gdi32 name 'AddFontResourceA';
function AddFontResourceW; external gdi32 name 'AddFontResourceW';
function AddFontResource; external gdi32 name 'AddFontResource' + AWSuffix;
function AnimatePalette; external gdi32 name 'AnimatePalette';
function Arc; external gdi32 name 'Arc';
function BitBlt; external gdi32 name 'BitBlt';
function CancelDC; external gdi32 name 'CancelDC';
function Chord; external gdi32 name 'Chord';
function ChoosePixelFormat; external gdi32 name 'ChoosePixelFormat';
function CloseMetaFile; external gdi32 name 'CloseMetaFile';
function CombineRgn; external gdi32 name 'CombineRgn';
function CopyMetaFileA; external gdi32 name 'CopyMetaFileA';
function CopyMetaFileW; external gdi32 name 'CopyMetaFileW';
function CopyMetaFile; external gdi32 name 'CopyMetaFile' + AWSuffix;
function CreateBitmap; external gdi32 name 'CreateBitmap';
function CreateBitmapIndirect; external gdi32 name 'CreateBitmapIndirect';
function CreateBrushIndirect; external gdi32 name 'CreateBrushIndirect';
function CreateCompatibleBitmap; external gdi32 name 'CreateCompatibleBitmap';
function CreateDiscardableBitmap; external gdi32 name 'CreateDiscardableBitmap';
function CreateCompatibleDC; external gdi32 name 'CreateCompatibleDC';
function CreateDCA; external gdi32 name 'CreateDCA';
function CreateDCW; external gdi32 name 'CreateDCW';
function CreateDC; external gdi32 name 'CreateDC' + AWSuffix;
function CreateDIBitmap; external gdi32 name 'CreateDIBitmap';
function CreateDIBPatternBrush; external gdi32 name 'CreateDIBPatternBrush';
function CreateDIBPatternBrushPt; external gdi32 name 'CreateDIBPatternBrushPt';
function CreateEllipticRgn; external gdi32 name 'CreateEllipticRgn';
function CreateEllipticRgnIndirect; external gdi32 name 'CreateEllipticRgnIndirect';
function CreateFontIndirectA; external gdi32 name 'CreateFontIndirectA';
function CreateFontIndirectW; external gdi32 name 'CreateFontIndirectW';
function CreateFontIndirect; external gdi32 name 'CreateFontIndirect' + AWSuffix;
function CreateFontA; external gdi32 name 'CreateFontA';
function CreateFontW; external gdi32 name 'CreateFontW';
function CreateFont; external gdi32 name 'CreateFont' + AWSuffix;
function CreateHatchBrush; external gdi32 name 'CreateHatchBrush';
function CreateICA; external gdi32 name 'CreateICA';
function CreateICW; external gdi32 name 'CreateICW';
function CreateIC; external gdi32 name 'CreateIC' + AWSuffix;
function CreateMetaFileA; external gdi32 name 'CreateMetaFileA';
function CreateMetaFileW; external gdi32 name 'CreateMetaFileW';
function CreateMetaFile; external gdi32 name 'CreateMetaFile' + AWSuffix;
function CreatePalette; external gdi32 name 'CreatePalette';
function CreatePen; external gdi32 name 'CreatePen';
function CreatePenIndirect; external gdi32 name 'CreatePenIndirect';
function CreatePolyPolygonRgn; external gdi32 name 'CreatePolyPolygonRgn';
function CreatePatternBrush; external gdi32 name 'CreatePatternBrush';
function CreateRectRgn; external gdi32 name 'CreateRectRgn';
function CreateRectRgnIndirect; external gdi32 name 'CreateRectRgnIndirect';
function CreateRoundRectRgn; external gdi32 name 'CreateRoundRectRgn';
function CreateScalableFontResourceA; external gdi32 name 'CreateScalableFontResourceA';
function CreateScalableFontResourceW; external gdi32 name 'CreateScalableFontResourceW';
function CreateScalableFontResource; external gdi32 name 'CreateScalableFontResource' + AWSuffix;
function CreateSolidBrush; external gdi32 name 'CreateSolidBrush';
function DeleteDC; external gdi32 name 'DeleteDC';
function DeleteMetaFile; external gdi32 name 'DeleteMetaFile';
function DeleteObject; external gdi32 name 'DeleteObject';
function DescribePixelFormat; external gdi32 name 'DescribePixelFormat';
function DeviceCapabilitiesA; external winspool32 name 'DeviceCapabilitiesA';
function DeviceCapabilitiesW; external winspool32 name 'DeviceCapabilitiesW';
function DeviceCapabilities; external winspool32 name 'DeviceCapabilities' + AWSuffix;
function DrawEscape; external gdi32 name 'DrawEscape';
function Ellipse; external gdi32 name 'Ellipse';
function EnumFontFamiliesExA; external gdi32 name 'EnumFontFamiliesExA';
function EnumFontFamiliesExW; external gdi32 name 'EnumFontFamiliesExW';
function EnumFontFamiliesEx; external gdi32 name 'EnumFontFamiliesEx' + AWSuffix;
function EnumFontFamiliesA; external gdi32 name 'EnumFontFamiliesA';
function EnumFontFamiliesW; external gdi32 name 'EnumFontFamiliesW';
function EnumFontFamilies; external gdi32 name 'EnumFontFamilies' + AWSuffix;
function EnumFontsA; external gdi32 name 'EnumFontsA';
function EnumFontsW; external gdi32 name 'EnumFontsW';
function EnumFonts; external gdi32 name 'EnumFonts' + AWSuffix;
function EnumObjects; external gdi32 name 'EnumObjects';
function EqualRgn; external gdi32 name 'EqualRgn';
function Escape; external gdi32 name 'Escape';
function ExtEscape; external gdi32 name 'ExtEscape';
function ExcludeClipRect; external gdi32 name 'ExcludeClipRect';
function ExtCreateRegion; external gdi32 name 'ExtCreateRegion';
function ExtFloodFill; external gdi32 name 'ExtFloodFill';
function FillRgn; external gdi32 name 'FillRgn';
function FloodFill; external gdi32 name 'FloodFill';
function FrameRgn; external gdi32 name 'FrameRgn';
function GetROP2; external gdi32 name 'GetROP2';
function GetAspectRatioFilterEx; external gdi32 name 'GetAspectRatioFilterEx';
function GetBkColor; external gdi32 name 'GetBkColor';
function GetDCBrushColor; external gdi32 name 'GetDCBrushColor';
function GetDCPenColor; external gdi32 name 'GetDCPenColor';
function GetBkMode; external gdi32 name 'GetBkMode';
function GetBitmapBits; external gdi32 name 'GetBitmapBits';
function GetBitmapDimensionEx; external gdi32 name 'GetBitmapDimensionEx';
function GetBoundsRect; external gdi32 name 'GetBoundsRect';
function GetBrushOrgEx; external gdi32 name 'GetBrushOrgEx';
function GetCharWidthA; external gdi32 name 'GetCharWidthA';
function GetCharWidthW; external gdi32 name 'GetCharWidthW';
function GetCharWidth; external gdi32 name 'GetCharWidth' + AWSuffix;
function GetCharWidth32A; external gdi32 name 'GetCharWidth32A';
function GetCharWidth32W; external gdi32 name 'GetCharWidth32W';
function GetCharWidth32; external gdi32 name 'GetCharWidth32' + AWSuffix;
function GetCharWidthFloatA; external gdi32 name 'GetCharWidthFloatA';
function GetCharWidthFloatW; external gdi32 name 'GetCharWidthFloatW';
function GetCharWidthFloat; external gdi32 name 'GetCharWidthFloat' + AWSuffix;
function GetCharABCWidthsA; external gdi32 name 'GetCharABCWidthsA';
function GetCharABCWidthsW; external gdi32 name 'GetCharABCWidthsW';
function GetCharABCWidths; external gdi32 name 'GetCharABCWidths' + AWSuffix;
function GetCharABCWidthsFloatA; external gdi32 name 'GetCharABCWidthsFloatA';
function GetCharABCWidthsFloatW; external gdi32 name 'GetCharABCWidthsFloatW';
function GetCharABCWidthsFloat; external gdi32 name 'GetCharABCWidthsFloat' + AWSuffix;
function GetClipBox; external gdi32 name 'GetClipBox';
function GetClipRgn; external gdi32 name 'GetClipRgn';
function GetMetaRgn; external gdi32 name 'GetMetaRgn';
function GetCurrentObject; external gdi32 name 'GetCurrentObject';
function GetCurrentPositionEx; external gdi32 name 'GetCurrentPositionEx';
function GetDeviceCaps; external gdi32 name 'GetDeviceCaps';
function GetDIBits; external gdi32 name 'GetDIBits';
function GetFontData; external gdi32 name 'GetFontData';
function GetGlyphOutlineA; external gdi32 name 'GetGlyphOutlineA';
function GetGlyphOutlineW; external gdi32 name 'GetGlyphOutlineW';
function GetGlyphOutline; external gdi32 name 'GetGlyphOutline' + AWSuffix;
function GetGraphicsMode; external gdi32 name 'GetGraphicsMode';
function GetMapMode; external gdi32 name 'GetMapMode';
function GetMetaFileBitsEx; external gdi32 name 'GetMetaFileBitsEx';
function GetMetaFileA; external gdi32 name 'GetMetaFileA';
function GetMetaFileW; external gdi32 name 'GetMetaFileW';
function GetMetaFile; external gdi32 name 'GetMetaFile' + AWSuffix;
function GetNearestColor; external gdi32 name 'GetNearestColor';
function GetNearestPaletteIndex; external gdi32 name 'GetNearestPaletteIndex';
function GetObjectType; external gdi32 name 'GetObjectType';
function GetOutlineTextMetricsA; external gdi32 name 'GetOutlineTextMetricsA';
function GetOutlineTextMetricsW; external gdi32 name 'GetOutlineTextMetricsW';
function GetOutlineTextMetrics; external gdi32 name 'GetOutlineTextMetrics' + AWSuffix;
function GetPaletteEntries; external gdi32 name 'GetPaletteEntries';
function GetPixel; external gdi32 name 'GetPixel';
function GetPixelFormat; external gdi32 name 'GetPixelFormat';
function GetPolyFillMode; external gdi32 name 'GetPolyFillMode';
function GetRasterizerCaps; external gdi32 name 'GetRasterizerCaps';
function GetRandomRgn; external gdi32 name 'GetRandomRgn';
function GetRegionData; external gdi32 name 'GetRegionData';
function GetRgnBox; external gdi32 name 'GetRgnBox';
function GetStockObject; external gdi32 name 'GetStockObject';
function GetStretchBltMode; external gdi32 name 'GetStretchBltMode';
function GetSystemPaletteEntries; external gdi32 name 'GetSystemPaletteEntries';
function GetSystemPaletteUse; external gdi32 name 'GetSystemPaletteUse';
function GetTextCharacterExtra; external gdi32 name 'GetTextCharacterExtra';
function GetTextAlign; external gdi32 name 'GetTextAlign';
function GetTextColor; external gdi32 name 'GetTextColor';
function GetTextExtentPointA; external gdi32 name 'GetTextExtentPointA';
function GetTextExtentPointW; external gdi32 name 'GetTextExtentPointW';
function GetTextExtentPoint; external gdi32 name 'GetTextExtentPoint' + AWSuffix;
function GetTextExtentPoint32A; external gdi32 name 'GetTextExtentPoint32A';
function GetTextExtentPoint32W; external gdi32 name 'GetTextExtentPoint32W';
function GetTextExtentPoint32; external gdi32 name 'GetTextExtentPoint32' + AWSuffix;
function GetTextExtentExPointA; external gdi32 name 'GetTextExtentExPointA';
function GetTextExtentExPointW; external gdi32 name 'GetTextExtentExPointW';
function GetTextExtentExPoint; external gdi32 name 'GetTextExtentExPoint' + AWSuffix;
function GetTextCharset; external gdi32 name 'GetTextCharset';
function GetTextCharsetInfo; external gdi32 name 'GetTextCharsetInfo';
function TranslateCharsetInfo; external gdi32 name 'TranslateCharsetInfo';
function GetFontLanguageInfo; external gdi32 name 'GetFontLanguageInfo';
function GetCharacterPlacementA; external gdi32 name 'GetCharacterPlacementA';
function GetCharacterPlacementW; external gdi32 name 'GetCharacterPlacementW';
function GetCharacterPlacement; external gdi32 name 'GetCharacterPlacement' + AWSuffix;
function GetFontUnicodeRanges; external gdi32 name 'GetFontUnicodeRanges';
function GetGlyphIndicesA; external gdi32 name 'GetGlyphIndicesA';
function GetGlyphIndicesW; external gdi32 name 'GetGlyphIndicesW';
function GetGlyphIndices; external gdi32 name 'GetGlyphIndices' + AWSuffix;
function GetTextExtentPointI; external gdi32 name 'GetTextExtentPointI';
function GetTextExtentExPointI; external gdi32 name 'GetTextExtentExPointI';
function GetCharWidthI; external gdi32 name 'GetCharWidthI';
function GetCharABCWidthsI; external gdi32 name 'GetCharABCWidthsI';
function AddFontResourceExA; external gdi32 name 'AddFontResourceExA';
function AddFontResourceExW; external gdi32 name 'AddFontResourceExW';
function AddFontResourceEx; external gdi32 name 'AddFontResourceEx' + AWSuffix;
function RemoveFontResourceExA; external gdi32 name 'RemoveFontResourceExA';
function RemoveFontResourceExW; external gdi32 name 'RemoveFontResourceExW';
function RemoveFontResourceEx; external gdi32 name 'RemoveFontResourceEx' + AWSuffix;
function AddFontMemResourceEx; external gdi32 name 'AddFontMemResourceEx';
function RemoveFontMemResourceEx; external gdi32 name 'RemoveFontMemResourceEx';
function CreateFontIndirectExA; external gdi32 name 'CreateFontIndirectExA';
function CreateFontIndirectExW; external gdi32 name 'CreateFontIndirectExW';
function CreateFontIndirectEx; external gdi32 name 'CreateFontIndirectEx' + AWSuffix;
function GetViewportExtEx; external gdi32 name 'GetViewportExtEx';
function GetViewportOrgEx; external gdi32 name 'GetViewportOrgEx';
function GetWindowExtEx; external gdi32 name 'GetWindowExtEx';
function GetWindowOrgEx; external gdi32 name 'GetWindowOrgEx';
function IntersectClipRect; external gdi32 name 'IntersectClipRect';
function InvertRgn; external gdi32 name 'InvertRgn';
function LineDDA; external gdi32 name 'LineDDA';
function LineTo; external gdi32 name 'LineTo';
function MaskBlt; external gdi32 name 'MaskBlt';
function PlgBlt; external gdi32 name 'PlgBlt';
function OffsetClipRgn; external gdi32 name 'OffsetClipRgn';
function OffsetRgn; external gdi32 name 'OffsetRgn';
function PatBlt; external gdi32 name 'PatBlt';
function Pie; external gdi32 name 'Pie';
function PlayMetaFile; external gdi32 name 'PlayMetaFile';
function PaintRgn; external gdi32 name 'PaintRgn';
function PolyPolygon; external gdi32 name 'PolyPolygon';
function PtInRegion; external gdi32 name 'PtInRegion';
function PtVisible; external gdi32 name 'PtVisible';
function RectInRegion; external gdi32 name 'RectInRegion';
function RectVisible; external gdi32 name 'RectVisible';
function Rectangle; external gdi32 name 'Rectangle';
function RestoreDC; external gdi32 name 'RestoreDC';
function ResetDCA; external gdi32 name 'ResetDCA';
function ResetDCW; external gdi32 name 'ResetDCW';
function ResetDC; external gdi32 name 'ResetDC' + AWSuffix;
function RealizePalette; external gdi32 name 'RealizePalette';
function RemoveFontResourceA; external gdi32 name 'RemoveFontResourceA';
function RemoveFontResourceW; external gdi32 name 'RemoveFontResourceW';
function RemoveFontResource; external gdi32 name 'RemoveFontResource' + AWSuffix;
function RoundRect; external gdi32 name 'RoundRect';
function ResizePalette; external gdi32 name 'ResizePalette';
function SaveDC; external gdi32 name 'SaveDC';
function SelectClipRgn; external gdi32 name 'SelectClipRgn';
function ExtSelectClipRgn; external gdi32 name 'ExtSelectClipRgn';
function SetMetaRgn; external gdi32 name 'SetMetaRgn';
function SelectObject; external gdi32 name 'SelectObject';
function SelectPalette; external gdi32 name 'SelectPalette';
function SetBkColor; external gdi32 name 'SetBkColor';
function SetDCBrushColor; external gdi32 name 'SetDCBrushColor';
function SetDCPenColor; external gdi32 name 'SetDCPenColor';
function SetBkMode; external gdi32 name 'SetBkMode';
function SetBitmapBits; external gdi32 name 'SetBitmapBits';
function SetBoundsRect; external gdi32 name 'SetBoundsRect';
function SetDIBits; external gdi32 name 'SetDIBits';
function SetDIBitsToDevice; external gdi32 name 'SetDIBitsToDevice';
function SetMapperFlags; external gdi32 name 'SetMapperFlags';
function SetGraphicsMode; external gdi32 name 'SetGraphicsMode';
function SetMapMode; external gdi32 name 'SetMapMode';
function SetLayout; external gdi32 name 'SetLayout';
function GetLayout; external gdi32 name 'GetLayout';
function SetMetaFileBitsEx; external gdi32 name 'SetMetaFileBitsEx';
function SetPaletteEntries; external gdi32 name 'SetPaletteEntries';
function SetPixel; external gdi32 name 'SetPixel';
function SetPixelV; external gdi32 name 'SetPixelV';
function SetPixelFormat; external gdi32 name 'SetPixelFormat';
function SetPolyFillMode; external gdi32 name 'SetPolyFillMode';
function StretchBlt; external gdi32 name 'StretchBlt';
function SetRectRgn; external gdi32 name 'SetRectRgn';
function StretchDIBits; external gdi32 name 'StretchDIBits';
function SetROP2; external gdi32 name 'SetROP2';
function SetStretchBltMode; external gdi32 name 'SetStretchBltMode';
function SetSystemPaletteUse; external gdi32 name 'SetSystemPaletteUse';
function SetTextCharacterExtra; external gdi32 name 'SetTextCharacterExtra';
function SetTextColor; external gdi32 name 'SetTextColor';
function SetTextAlign; external gdi32 name 'SetTextAlign';
function SetTextJustification; external gdi32 name 'SetTextJustification';
function UpdateColors; external gdi32 name 'UpdateColors';
function AlphaBlend; external msimg32 name 'AlphaBlend';
function TransparentBlt; external msimg32 name 'TransparentBlt';
function GradientFill; external msimg32 name 'GradientFill';
function PlayMetaFileRecord; external gdi32 name 'PlayMetaFileRecord';
function EnumMetaFile; external gdi32 name 'EnumMetaFile';
function CloseEnhMetaFile; external gdi32 name 'CloseEnhMetaFile';
function CopyEnhMetaFileA; external gdi32 name 'CopyEnhMetaFileA';
function CopyEnhMetaFileW; external gdi32 name 'CopyEnhMetaFileW';
function CopyEnhMetaFile; external gdi32 name 'CopyEnhMetaFile' + AWSuffix;
function CreateEnhMetaFileA; external gdi32 name 'CreateEnhMetaFileA';
function CreateEnhMetaFileW; external gdi32 name 'CreateEnhMetaFileW';
function CreateEnhMetaFile; external gdi32 name 'CreateEnhMetaFile' + AWSuffix;
function DeleteEnhMetaFile; external gdi32 name 'DeleteEnhMetaFile';
function EnumEnhMetaFile; external gdi32 name 'EnumEnhMetaFile';
function GetEnhMetaFileA; external gdi32 name 'GetEnhMetaFileA';
function GetEnhMetaFileW; external gdi32 name 'GetEnhMetaFileW';
function GetEnhMetaFile; external gdi32 name 'GetEnhMetaFile' + AWSuffix;
function GetEnhMetaFileBits; external gdi32 name 'GetEnhMetaFileBits';
function GetEnhMetaFileDescriptionA; external gdi32 name 'GetEnhMetaFileDescriptionA';
function GetEnhMetaFileDescriptionW; external gdi32 name 'GetEnhMetaFileDescriptionW';
function GetEnhMetaFileDescription; external gdi32 name 'GetEnhMetaFileDescription' + AWSuffix;
function GetEnhMetaFileHeader; external gdi32 name 'GetEnhMetaFileHeader';
function GetEnhMetaFilePaletteEntries; external gdi32 name 'GetEnhMetaFilePaletteEntries';
function GetEnhMetaFilePixelFormat; external gdi32 name 'GetEnhMetaFilePixelFormat';
function GetWinMetaFileBits; external gdi32 name 'GetWinMetaFileBits';
function PlayEnhMetaFile; external gdi32 name 'PlayEnhMetaFile';
function PlayEnhMetaFileRecord; external gdi32 name 'PlayEnhMetaFileRecord';
function SetEnhMetaFileBits; external gdi32 name 'SetEnhMetaFileBits';
function SetWinMetaFileBits; external gdi32 name 'SetWinMetaFileBits';
function GdiComment; external gdi32 name 'GdiComment';
function GetTextMetricsA; external gdi32 name 'GetTextMetricsA';
function GetTextMetricsW; external gdi32 name 'GetTextMetricsW';
function GetTextMetrics; external gdi32 name 'GetTextMetrics' + AWSuffix;
function AngleArc; external gdi32 name 'AngleArc';
function PolyPolyline; external gdi32 name 'PolyPolyline';
function GetWorldTransform; external gdi32 name 'GetWorldTransform';
function SetWorldTransform; external gdi32 name 'SetWorldTransform';
function ModifyWorldTransform; external gdi32 name 'ModifyWorldTransform';
function CombineTransform; external gdi32 name 'CombineTransform';
function CreateDIBSection; external gdi32 name 'CreateDIBSection';
function GetDIBColorTable; external gdi32 name 'GetDIBColorTable';
function SetDIBColorTable; external gdi32 name 'SetDIBColorTable';
function SetColorAdjustment; external gdi32 name 'SetColorAdjustment';
function GetColorAdjustment; external gdi32 name 'GetColorAdjustment';
function CreateHalftonePalette; external gdi32 name 'CreateHalftonePalette';
function StartDocA; external gdi32 name 'StartDocA';
function StartDocW; external gdi32 name 'StartDocW';
function StartDoc; external gdi32 name 'StartDoc' + AWSuffix;
function EndDoc; external gdi32 name 'EndDoc';
function StartPage; external gdi32 name 'StartPage';
function EndPage; external gdi32 name 'EndPage';
function AbortDoc; external gdi32 name 'AbortDoc';
function SetAbortProc; external gdi32 name 'SetAbortProc';
function AbortPath; external gdi32 name 'AbortPath';
function ArcTo; external gdi32 name 'ArcTo';
function BeginPath; external gdi32 name 'BeginPath';
function CloseFigure; external gdi32 name 'CloseFigure';
function EndPath; external gdi32 name 'EndPath';
function FillPath; external gdi32 name 'FillPath';
function FlattenPath; external gdi32 name 'FlattenPath';
function GetPath; external gdi32 name 'GetPath';
function PathToRegion; external gdi32 name 'PathToRegion';
function PolyDraw; external gdi32 name 'PolyDraw';
function SelectClipPath; external gdi32 name 'SelectClipPath';
function SetArcDirection; external gdi32 name 'SetArcDirection';
function SetMiterLimit; external gdi32 name 'SetMiterLimit';
function StrokeAndFillPath; external gdi32 name 'StrokeAndFillPath';
function StrokePath; external gdi32 name 'StrokePath';
function WidenPath; external gdi32 name 'WidenPath';
function ExtCreatePen; external gdi32 name 'ExtCreatePen';
function GetMiterLimit; external gdi32 name 'GetMiterLimit';
function GetArcDirection; external gdi32 name 'GetArcDirection';
function GetObjectA; external gdi32 name 'GetObjectA';
function GetObjectW; external gdi32 name 'GetObjectW';
function GetObject; external gdi32 name 'GetObject' + AWSuffix;
function MoveToEx; external gdi32 name 'MoveToEx';
function TextOutA; external gdi32 name 'TextOutA';
function TextOutW; external gdi32 name 'TextOutW';
function TextOut; external gdi32 name 'TextOut' + AWSuffix;
function ExtTextOutA; external gdi32 name 'ExtTextOutA';
function ExtTextOutW; external gdi32 name 'ExtTextOutW';
function ExtTextOut; external gdi32 name 'ExtTextOut' + AWSuffix;
function PolyTextOutA; external gdi32 name 'PolyTextOutA';
function PolyTextOutW; external gdi32 name 'PolyTextOutW';
function PolyTextOut; external gdi32 name 'PolyTextOut' + AWSuffix;
function CreatePolygonRgn; external gdi32 name 'CreatePolygonRgn';
function DPtoLP; external gdi32 name 'DPtoLP';
function LPtoDP; external gdi32 name 'LPtoDP';
function Polygon; external gdi32 name 'Polygon';
function Polyline; external gdi32 name 'Polyline';
function PolyBezier; external gdi32 name 'PolyBezier';
function PolyBezierTo; external gdi32 name 'PolyBezierTo';
function PolylineTo; external gdi32 name 'PolylineTo';
function SetViewportExtEx; external gdi32 name 'SetViewportExtEx';
function SetViewportOrgEx; external gdi32 name 'SetViewportOrgEx';
function SetWindowExtEx; external gdi32 name 'SetWindowExtEx';
function SetWindowOrgEx; external gdi32 name 'SetWindowOrgEx';
function OffsetViewportOrgEx; external gdi32 name 'OffsetViewportOrgEx';
function OffsetWindowOrgEx; external gdi32 name 'OffsetWindowOrgEx';
function ScaleViewportExtEx; external gdi32 name 'ScaleViewportExtEx';
function ScaleWindowExtEx; external gdi32 name 'ScaleWindowExtEx';
function SetBitmapDimensionEx; external gdi32 name 'SetBitmapDimensionEx';
function SetBrushOrgEx; external gdi32 name 'SetBrushOrgEx';
function GetTextFaceA; external gdi32 name 'GetTextFaceA';
function GetTextFaceW; external gdi32 name 'GetTextFaceW';
function GetTextFace; external gdi32 name 'GetTextFace' + AWSuffix;
function GetKerningPairsA; external gdi32 name 'GetKerningPairsA';
function GetKerningPairsW; external gdi32 name 'GetKerningPairsW';
function GetKerningPairs; external gdi32 name 'GetKerningPairs' + AWSuffix;
function GetDCOrgEx; external gdi32 name 'GetDCOrgEx';
function FixBrushOrgEx; external gdi32 name 'FixBrushOrgEx';
function UnrealizeObject; external gdi32 name 'UnrealizeObject';
function GdiFlush; external gdi32 name 'GdiFlush';
function GdiSetBatchLimit; external gdi32 name 'GdiSetBatchLimit';
function GdiGetBatchLimit; external gdi32 name 'GdiGetBatchLimit';
function SetICMMode; external gdi32 name 'SetICMMode';
function CheckColorsInGamut; external gdi32 name 'CheckColorsInGamut';
function GetColorSpace; external gdi32 name 'GetColorSpace';
function GetLogColorSpaceA; external gdi32 name 'GetLogColorSpaceA';
function GetLogColorSpaceW; external gdi32 name 'GetLogColorSpaceW';
function GetLogColorSpace; external gdi32 name 'GetLogColorSpace' + AWSuffix;
function CreateColorSpaceA; external gdi32 name 'CreateColorSpaceA';
function CreateColorSpaceW; external gdi32 name 'CreateColorSpaceW';
function CreateColorSpace; external gdi32 name 'CreateColorSpace' + AWSuffix;
function SetColorSpace; external gdi32 name 'SetColorSpace';
function DeleteColorSpace; external gdi32 name 'DeleteColorSpace';
function GetICMProfileA; external gdi32 name 'GetICMProfileA';
function GetICMProfileW; external gdi32 name 'GetICMProfileW';
function GetICMProfile; external gdi32 name 'GetICMProfile' + AWSuffix;
function SetICMProfileA; external gdi32 name 'SetICMProfileA';
function SetICMProfileW; external gdi32 name 'SetICMProfileW';
function SetICMProfile; external gdi32 name 'SetICMProfile' + AWSuffix;
function GetDeviceGammaRamp; external gdi32 name 'GetDeviceGammaRamp';
function SetDeviceGammaRamp; external gdi32 name 'SetDeviceGammaRamp';
function ColorMatchToTarget; external gdi32 name 'ColorMatchToTarget';
function EnumICMProfilesA; external gdi32 name 'EnumICMProfilesA';
function EnumICMProfilesW; external gdi32 name 'EnumICMProfilesW';
function EnumICMProfiles; external gdi32 name 'EnumICMProfiles' + AWSuffix;
function UpdateICMRegKeyA; external gdi32 name 'UpdateICMRegKeyA';
function UpdateICMRegKeyW; external gdi32 name 'UpdateICMRegKeyW';
function UpdateICMRegKey; external gdi32 name 'UpdateICMRegKey' + AWSuffix;
function ColorCorrectPalette; external gdi32 name 'ColorCorrectPalette';
function wglCopyContext; external opengl32 name 'wglCopyContext';
function wglCreateContext; external opengl32 name 'wglCreateContext';
function wglCreateLayerContext; external opengl32 name 'wglCreateLayerContext';
function wglDeleteContext; external opengl32 name 'wglDeleteContext';
function wglGetCurrentContext; external opengl32 name 'wglGetCurrentContext';
function wglGetCurrentDC; external opengl32 name 'wglGetCurrentDC';
function wglGetProcAddress; external opengl32 name 'wglGetProcAddress';
function wglMakeCurrent; external opengl32 name 'wglMakeCurrent';
function wglShareLists; external opengl32 name 'wglShareLists';
function wglUseFontBitmapsA; external opengl32 name 'wglUseFontBitmapsA';
function wglUseFontBitmapsW; external opengl32 name 'wglUseFontBitmapsW';
function wglUseFontBitmaps; external opengl32 name 'wglUseFontBitmaps' + AWSuffix;
function SwapBuffers; external opengl32 name 'SwapBuffers';
function wglUseFontOutlinesA; external opengl32 name 'wglUseFontOutlinesA';
function wglUseFontOutlinesW; external opengl32 name 'wglUseFontOutlinesW';
function wglUseFontOutlines; external opengl32 name 'wglUseFontOutlines' + AWSuffix;
function wglDescribeLayerPlane; external opengl32 name 'wglDescribeLayerPlane';
function wglSetLayerPaletteEntries; external opengl32 name 'wglSetLayerPaletteEntries';
function wglGetLayerPaletteEntries; external opengl32 name 'wglGetLayerPaletteEntries';
function wglRealizeLayerPalette; external opengl32 name 'wglRealizeLayerPalette';
function wglSwapLayerBuffers; external opengl32 name 'wglSwapLayerBuffers';
function wglSwapMultipleBuffers; external opengl32 name 'wglSwapMultipleBuffers';

end.
