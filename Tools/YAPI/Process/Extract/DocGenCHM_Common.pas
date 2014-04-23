{*------------------------------------------------------------------------------
  Resources for CHMGenerator
  All strings to be translate are localized here.
  Parts of CHM Canvas are also written here.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   v0.0     Initial revision
-------------------------------------------------------------------------------}
unit DocGenCHM_Common;

interface

uses
  Classes;

function CHMGenProjectOptions(const ShortName: string): string;
function CHMGenProjectWindows(const ShortName: string): string;
function CHMGenProjectFilesStart: string;
function CHMGenProjectFilesFile(const TemplateName: string): string;
function CHMGenProjectInfoTypesStart: string;

function CHMGenTocLinkedHeading(const Name:string; const FileName:string;const isFolder:Boolean): string;
function CHMGenTocClosingFolder: string;
function CHMGenTocSimpleHeading(const Name:string;const isFolder:Boolean=true): string;
function CHMGenTocHead: string;
function CHMGenTocBodyStart: string;
function CHMGenTocBodyEnd: string;


{gnugettext: scan-all text-domain='DCTD_ignore' }

const
  HTML_INLUDE_PATH = 'html\';
  HHP_FILE_EXT = '.hhp'; /// HHP file extention
  HHC_FILE_EXT = '.hhc'; /// HHC file extention
  HHK_FILE_EXT = '.hhk'; /// HHK file extention
  CHM_FILE_EXT = '.chm'; /// CHM file extention

implementation

uses
  { delphi }
  SysUtils,
  JclImports;

{gnugettext: scan-all text-domain='DCTD_ignore' }

resourcestring

// ------------------------- Project  (*.hhp) canevas   ------------------------


/// OPTIONS section : %CompiledFile, %ContentFile, %DefaultWindow, %DefaultTopic
///  , %IndexFile, %Title
CHM_COMMON_PROJECT_OPTIONS =
 '[OPTIONS]'+AnsiLineBreak
//+'Binary TOC=Yes'+AnsiLineBreak - gets some troubles with option !!!
+'Compatibility=1.1 or later'+AnsiLineBreak
+'Compiled file=%s.chm'+AnsiLineBreak
+'Contents file=%s.hhc'+AnsiLineBreak
+'Default Window=%s'+AnsiLineBreak
+'Default topic='+HTML_INLUDE_PATH+'%s.htm'+AnsiLineBreak
+'Display compile progress=No'+AnsiLineBreak
+'Full-text search=Yes'+AnsiLineBreak
+'Index file=%s.hhk'+AnsiLineBreak
+'Language=0x409 Anglais (États-Unis)'+AnsiLineBreak
+'Title=%s'+AnsiLineBreak;

/// WINDOWS section : %Name, %ContentFile, %IndexFile, %DefaultTopic, %DefaultTopic
CHM_COMMON_PROJECT_WINDOWS =
 '[WINDOWS]'+AnsiLineBreak
+'%s=,"%s.hhc","%s.hhk","'+HTML_INLUDE_PATH+'%s.htm","'+HTML_INLUDE_PATH+'%s.htm",,,,,0x23520,,0x3026,[0,0,1024,768],0x1030000,,,,,,0'+AnsiLineBreak;

/// FILES section
CHM_COMMON_PROJECT_FILES_START =
 '[FILES]'+AnsiLineBreak;

/// each file of FILES section : %TemplateName
CHM_COMMON_PROJECT_FILES_FILE =
 HTML_INLUDE_PATH+'%s.htm';


CHM_COMMON_PROJECT_INFOTYPES_START =
 '[INFOTYPES]'+AnsiLineBreak;


// ------------------------- TOC      (*.hhc)  canevas  ------------------------
/// Simple HEADING section START : %HeadingName
CHM_COMMON_TOC_SIMPLE_HEADING=
 '<LI> <OBJECT type="text/sitemap">'+AnsiLineBreak
+' <param name="Name" value="%s">'+AnsiLineBreak
+'</OBJECT>'+AnsiLineBreak;


/// Linked HEADING section START : %HeadingName, %HeadingLink
CHM_COMMON_TOC_LINKED_HEADING=
 '<LI> <OBJECT type="text/sitemap">'+AnsiLineBreak
+' <param name="Name" value="%s">'+AnsiLineBreak
+' <param name="Local" value="'+HTML_INLUDE_PATH+'%s.htm">'+AnsiLineBreak
+'</OBJECT>'+AnsiLineBreak;

/// Linked HEADING section START : %HeadingName, %HeadingLink
CHM_COMMON_TOC_LINKED_FOLDER=
 '<LI> <OBJECT type="text/sitemap">'+AnsiLineBreak
+' <param name="Name" value="%s">'+AnsiLineBreak
+' <param name="Local" value="'+HTML_INLUDE_PATH+'%s.htm">'+AnsiLineBreak
+' <param name="ImageNumber" value="2">'+AnsiLineBreak
+'</OBJECT>'+AnsiLineBreak;

/// Folder type HEADING
CHM_COMMON_TOC_FOLDER= '<UL>'+AnsiLineBreak;

/// HEADING section END :
CHM_COMMON_TOC_FOLDER_END= '</UL>'+AnsiLineBreak;

/// HEAD section
CHM_COMMON_TOC_HEAD =
 '<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">'+AnsiLineBreak
+'<HTML>'+AnsiLineBreak
+'<HEAD>'+AnsiLineBreak
+'<meta name="GENERATOR" content="Microsoft&reg; HTML Help Workshop 4.1">'+AnsiLineBreak
+'<!-- Sitemap 1.0 -->'+AnsiLineBreak
+'</HEAD>'+AnsiLineBreak;

/// BODY START section :
CHM_COMMON_TOC_BODY_START=
 '<BODY>'+AnsiLineBreak
+'<OBJECT type="text/site properties">'+AnsiLineBreak
+'	<param name="Window Styles" value="0x800227">'+AnsiLineBreak
+'	<param name="ImageType" value="Folder">'+AnsiLineBreak
+'</OBJECT>'+AnsiLineBreak
+'<UL>'+AnsiLineBreak;

/// BODY END section : 
CHM_COMMON_TOC_BODY_END=
 '</UL>'+AnsiLineBreak
+'</BODY>'+AnsiLineBreak
+'</HTML>'+AnsiLineBreak;

// ------------------------- Index    (*.hhk)  canevas  ------------------------


{gnugettext: reset }

// ------------------------- Project  (*.hhp) functions ------------------------

/// Return CHM project's option section
function CHMGenProjectOptions(const ShortName: string): string;
begin
  result:=Format(CHM_COMMON_PROJECT_OPTIONS,[ShortName,ShortName,ShortName
   ,ShortName, ShortName, ShortName]);
end;

/// Return CHM project's windows section
function CHMGenProjectWindows(const ShortName: string): string;
begin
  result:=Format(CHM_COMMON_PROJECT_WINDOWS,[ShortName,ShortName,ShortName,ShortName,ShortName]);
end;

/// Return CHM project's file START section
function CHMGenProjectFilesStart: string;
begin
  result:=CHM_COMMON_PROJECT_FILES_START;
end;

/// Return CHM project's files (one) file section
function CHMGenProjectFilesFile(const TemplateName: string): string;
begin
  result:=Format(CHM_COMMON_PROJECT_FILES_FILE,[TemplateName]);
end;

/// Return CHM project's info types START section
function CHMGenProjectInfoTypesStart: string;
begin
  result:=CHM_COMMON_PROJECT_INFOTYPES_START;
end;

// ------------------------- TOC      (*.hhc) functions ------------------------

/// Return CHM TOC linked heading
function CHMGenTocLinkedHeading(const Name:string; const FileName:string
 ;const isFolder:Boolean): string;
begin
  if isFolder then
    result:=Format(CHM_COMMON_TOC_LINKED_FOLDER,[Name,FileName])+CHM_COMMON_TOC_FOLDER
  else
    result:=Format(CHM_COMMON_TOC_LINKED_HEADING,[Name,FileName]);
end;

/// Return CHM TOC closing folder
function CHMGenTocClosingFolder: string;
begin
  result:=CHM_COMMON_TOC_FOLDER_END;
end;

/// Return CHM TOC simple heading
function CHMGenTocSimpleHeading(const Name:string;const isFolder:Boolean=true): string;
begin
  result:=Format(CHM_COMMON_TOC_SIMPLE_HEADING,[Name]);
  if isFolder then result:=result+CHM_COMMON_TOC_FOLDER;
end;

/// Return CHM TOC head section
function CHMGenTocHead: string;
begin
  result:=CHM_COMMON_TOC_HEAD;
end;

/// Return CHM TOC Body START section
function CHMGenTocBodyStart: string;
begin
  result:=CHM_COMMON_TOC_BODY_START;
end;

/// Return CHM TOC Body END section
function CHMGenTocBodyEnd: string;
begin
  result:=CHM_COMMON_TOC_BODY_END;
end;

// ------------------------- Index    (*.hhk) functions ------------------------


end.
