{*------------------------------------------------------------------------------
  Resources for HTMLGenerator
  All strings to be translate are localized here.
  Parts of HTML Canvas are also written here.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   v0.0     Initial revision
-------------------------------------------------------------------------------}


unit DocGenHTML_Common;

interface

uses Classes;

{gnugettext: scan-all text-domain='DCTD_ignore' }

const
  HTM_FILE_FILTER : string = '*.htm';
  HTML_FILE_EXT: string = '.htm'; /// HTML file extention
  CSS_FILE_EXT: string  = '.css'; /// CSS file extention
  CSS_BASE_FILENAME :string = 'YAPI'; /// CSS base filename (without extention)
  HTML_EOL : string ='<BR>';  /// HTML sign for EndOfLine

{gnugettext: scan-all text-domain='DCTD_Generator' }

resourcestring
  // Word localization
  L_Project        = 'Project';
  L_Summary        = 'Summary';
  L_UnderConstruction = '#UnderConstruction#';
  L_Description    = 'Description';
  L_Todo           = 'Todo';
  L_Author         = 'Author';
  L_Docs           = 'Documentation';
  L_Changes        = 'Additional Changes';
  L_Files          = 'Files';
  L_File           = 'File';
  L_Links          = 'See also';
  L_Unit           = 'Unit';
  L_Version        = 'Version';
  L_Classes        = 'Classes';
  L_Class          = 'Class';
  L_Types          = 'Types';
  L_Type           = 'Type';
  L_Constants      = 'Constants';
  L_Constant       = 'Constant';
  L_Variables      = 'Variables';
  L_Variable       = 'Variable';
  L_Functions      = 'Functions';
  L_Function       = 'Function';
  L_ClassHierarchy = 'Class Hierarchy';
  L_ClassTree      = 'Class Tree';
  L_RelatedUnit    = 'Related Unit';
  L_Parent         = 'Parent';
  L_Members        = 'Members';
  L_Fields         = 'Fields';
  L_Field          = 'Field';
  L_Methods        = 'Methods';
  L_Method         = 'Method';
  L_Properties     = 'Properties';
  L_Property       = 'Property';
  L_Events         = 'Events';
  L_Event          = 'Event';
  L_Symbol         = 'Symbol';
  L_Legend         = 'Legend';
  L_Visibility     = 'Visibility';
  L_Private        = 'Private';
  L_Protected      = 'Protected';
  L_Public         = 'Public';
  L_Published      = 'Published';
  L_Automated      = 'Automated';
  L_Strict         = 'Strict';
  L_Member         = 'Member';
  L_RelatedClass   = 'Related Class';
  L_SourceCode     = 'Source code';
  L_Parameters     = 'Parameters';
  L_Parameter      = 'Parameter';
  L_Return         = 'Return';
  L_Content        = 'Content';
  L_Index          = 'Index';
  L_Previous       = 'Previous';
  L_Next           = 'Next';
  L_Exception      = 'Exception';
  L_AdditionalComment = 'Additionnal Comments';
  L_ReadAccess     = 'Read Access';
  L_WriteAccess    = 'Write Access';
  L_Exports        = 'Exports';

function HTMLGenHead(const Name, Summary,CSSFilename: string): string;
function HTMLGenToolbar(const ProjectName, ContentName, IndexName ,PreviousItemName, NextItemName: string): string;
function HTMLGenSimpleSection(const SectionName, Item: string): string;
function HTMLGenSimpleColoredSection(const SectionName, Item: string): string;
function HTMLGenLinesSectionInit(const SectionName: string): string;
function HTMLGenLinesSectionColoredInit(const SectionName: string): string;
function HTMLGenLinesSectionLine(const Item: string): string;
function HTMLGenLinesSectionLineColored(const Item: string): string;
function HTMLGenLinesSectionEnd: string;
function HTMLGenTableSectionInit(const SectionName, IndexName1, IndexName2: string): string;
function HTMLGenTableSectionLine(const ItemName, ItemDescription: string): string;
function HTMLGenTableSectionEnd: string;
function HTMLGenFooter: string;
function HTMLGenCSS: string;
function HTMLGenMultiSectionInit(const SectionName: string): string;
function HTMLGenMultiSectionEnd: string;
function HTMLBuildLink(const st : string; const Link : string) : string;
function HTMLBuildLinkWithProps(const st : string; const Link, ClassName : string) : string;
function StringsToHTMLStrings(const sl: TStringList; const NoCharEncode:boolean) : string;


implementation

uses
  { delphi }
  SysUtils,
  JclImports;


{gnugettext: scan-all text-domain='DCTD_ignore' }

resourcestring

// HEAD SECTION %ProjectName, %Summary, %CSSFile
HTML_COMMON_HEAD =
 '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'+AnsiLineBreak
+'<html>'+AnsiLineBreak
+'<head>'+AnsiLineBreak
+'<title>%s - %s</title>'+AnsiLineBreak
+'<meta http-equiv="Content-Type" content="text/html">'+AnsiLineBreak
+'<link rel="stylesheet" href="%s" type="text/css">'+AnsiLineBreak
+'</head>'+AnsiLineBreak
+'<body bgcolor="#FFFFFF">'+AnsiLineBreak;

// TOOLBAR SECTION %ProjectName; %ContentName, %IndexName; %PreviousItemName, %NextItemName
HTML_COMMON_TOOLBAR =
 '<table width="100%%" border="0" cellspacing="0" bgcolor="#99CCFF">'+AnsiLineBreak
+'  <tr>'+AnsiLineBreak
+'    <td class="Generated"><b>%s</b></td>'+AnsiLineBreak
+'    <td class="Normal">'+AnsiLineBreak
+'      <div align="center">%s</div>'+AnsiLineBreak
+'    </td>'+AnsiLineBreak
+'    <td class="Normal">'+AnsiLineBreak
+'      <div align="center">%s</div>'+AnsiLineBreak
+'    </td>'+AnsiLineBreak
+'    <td class="Normal">'+AnsiLineBreak
+'      <div align="center">%s</div>'+AnsiLineBreak
+'    </td>'+AnsiLineBreak
+'    <td class="Normal">'+AnsiLineBreak
+'      <div align="center">%s</div>'+AnsiLineBreak
+'    </td>'+AnsiLineBreak
+'  </tr>'+AnsiLineBreak
+'</table><br>'+AnsiLineBreak;

// SIMPLE-LINE SECTION %SectionName; %Item;
HTML_COMMON_SIMPLE_SECTION =
 '<span class="SectionName">%s</span><br>'+AnsiLineBreak
+'<table width="95%%" border="0" cellspacing="0">'+AnsiLineBreak
+'  <tr>'+AnsiLineBreak
+'    <td width="10">&nbsp;</td>'+AnsiLineBreak
+'    <td class="Generated">%s</td>'+AnsiLineBreak
+'  </tr>'+AnsiLineBreak
+'</table>'+AnsiLineBreak
+'<br>'+AnsiLineBreak;

// COMMON LINES SECTION INIT %SectionName
HTML_COMMON_LINES_SECTION_INIT =
 '<span class="SectionName">%s</span><br>'+AnsiLineBreak
+'<table width="95%%" border="0" cellspacing="0">'+AnsiLineBreak;

// Unit description section %SectionName
HTML_COMMON_LINES_COLORED_SECTION_INIT =
 '<span class="SectionName">%s</span><br>'+AnsiLineBreak
+'<table width="95%%" border="0" bgcolor="#FFFFCC" cellspacing="0">'+AnsiLineBreak;


// COMMON LINES SECTION LINE %Item
HTML_COMMON_LINES_SECTION_LINE =
 '  <tr> '+AnsiLineBreak
+'    <td width="10">&nbsp;</td>'+AnsiLineBreak
+'    <td class="Generated"> '+AnsiLineBreak
+'      <span>%s</span>'+AnsiLineBreak
+'    </td>'+AnsiLineBreak
+'  </tr>'+AnsiLineBreak;

// COMMON LINES SECTION COLORED LINE %Item
HTML_COMMON_LINES_SECTION_LINE_COLORED =
 '  <tr> '+AnsiLineBreak
+'    <td width="10">&nbsp;</td>'+AnsiLineBreak
+'    <td bgcolor="#FFFFCC" class="Generated"> '+AnsiLineBreak
+'      <span>%s</span>'+AnsiLineBreak
+'    </td>'+AnsiLineBreak
+'  </tr>'+AnsiLineBreak;

HTML_COMMON_LINES_SECTION_END =
 '</table><br>'+AnsiLineBreak;

// HTML COMMON TABLE SECTION with 2 indexes

// %SectionName% %IndexName1; %IndexName2
HTML_COMMON_TABLE_INIT =
 '<span class="SectionName">%s</span><br>'+AnsiLineBreak
+'<table width="95%%" border="0" cellspacing="0">'+AnsiLineBreak
+'  <tr> '+AnsiLineBreak
+'    <td width="10">&nbsp;</td>'+AnsiLineBreak
+'    <td> '+AnsiLineBreak
+'      <table width="100%%" border="1" cellspacing="0" class="IndexName">'+AnsiLineBreak
+'        <tr bgcolor="#FFFFFF"> '+AnsiLineBreak
+'          <td class="IndexName" width="33%%">%s</td>'+AnsiLineBreak
+'          <td class="IndexName">%s</td>'+AnsiLineBreak
+'        </tr>'+AnsiLineBreak;

// %ItemName; %ItemDescription
HTML_COMMON_TABLE_LINE =
 '        <tr bgcolor="#FFFFFF"> '+AnsiLineBreak
+'          <td class="Generated" width="33%%">%s</td>'+AnsiLineBreak
+'          <td class="Generated">%s</td>'+AnsiLineBreak
+'        </tr>'+AnsiLineBreak;



// no parameter
HTML_COMMON_TABLE_END =
 '      </table>'+AnsiLineBreak
+'    </td>'+AnsiLineBreak
+'  </tr>'+AnsiLineBreak
+ '</table><br>'+AnsiLineBreak;

// Unit description section %SectionName; %Item
HTML_COMMON_SIMPLE_COLORED_SECTION =
 '<span class="SectionName">%s</span><br>'+AnsiLineBreak
+'<table width="95%%" border="0" bgcolor="#FFFFCC" cellspacing="0">'+AnsiLineBreak
+'  <tr>'+AnsiLineBreak
+'    <td width="10" bgcolor="#FFFFFF">&nbsp;</td>'+AnsiLineBreak
+'    <td class="Generated">%s</td>'+AnsiLineBreak
+'  </tr>'+AnsiLineBreak
+'</table><br>'+AnsiLineBreak;

// FOOTER SECTION
HTML_SECTION_FOOTER =
 '<hr width="100%%" align="left">'+AnsiLineBreak
+'<span class="Footer">Created with YAWE API Generator Tool. </span><br>'+AnsiLineBreak
+'<p>&nbsp;</p>'+AnsiLineBreak
+'</body>'+AnsiLineBreak
+'</html>'+AnsiLineBreak;

// MULTI SECTION %SectionName;
HTML_COMMON_MULTI_SECTION_INIT =
 '<span class="SectionName">%s</span><br>'+AnsiLineBreak
+'<table width="100%%" border="0" cellspacing="0">'+AnsiLineBreak
+'  <tr>'+AnsiLineBreak
+'    <td width="10">&nbsp;</td>'+AnsiLineBreak
+'    <td>';

HTML_COMMON_MULTI_END =
 '    </td>'+AnsiLineBreak
+'  </tr>'+AnsiLineBreak
+'</table><br>'+AnsiLineBreak;

HTML_CSS_FILE =
 '.SectionName {  font-weight: bold; color: #000000; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: small}'+AnsiLineBreak
+'.Generated {  color: #227700; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: small; font-style: normal; font-weight: normal}'+AnsiLineBreak
+'.IndexName { font-weight: bold; background-color: #DDDDDD; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: small}'+AnsiLineBreak
+'.Normal {  font-family: Verdana, Arial, Helvetica, sans-serif; font-size: small; font-style: normal; font-weight: normal}'+AnsiLineBreak
+'.Footer { color: #AAAAAA; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: xx-small; font-style: normal; font-weight: normal}'+AnsiLineBreak

+'.VisPrivate { color: #BB0000; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: xx-small; font-style: normal; font-weight: normal}'+AnsiLineBreak
+'.VisProtected { color: #BBAA00; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: xx-small; font-style: normal; font-weight: normal}'+AnsiLineBreak
+'.VisPublic { color: #00AA00; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: xx-small; font-style: normal; font-weight: normal}'+AnsiLineBreak
+'.VisPublished { color: #00AAAA; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: xx-small; font-style: normal; font-weight: normal}'+AnsiLineBreak
+'.VisAutomated { color: #AAAAAA; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: xx-small; font-style: normal; font-weight: normal}'+AnsiLineBreak

+'.SVisPrivate { color: #BB0000; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: xx-small; font-style: normal; font-weight: normal}'+AnsiLineBreak
+'.SVisProtected { color: #BBAA00; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: xx-small; font-style: normal; font-weight: normal}'+AnsiLineBreak
+'.SVisPublic { color: #00AA00; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: xx-small; font-style: normal; font-weight: normal}'+AnsiLineBreak
+'.SVisPublished { color: #00AAAA; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: xx-small; font-style: normal; font-weight: normal}'+AnsiLineBreak
+'.SVisAutomated { color: #AAAAAA; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: xx-small; font-style: normal; font-weight: normal}'+AnsiLineBreak


+'a:hover {  color: #FF0000; text-decoration: underline}'+AnsiLineBreak;


// Label linked to a file %FileName, %Label
HTML_LINKED_LABEL =
 '<a href="%s">%s</a>';

HTML_LINKED_LABEL_WITH_PROPS =
 '<a href="%s" class="%s">%s</a>';

{gnugettext: reset }

function HTMLGenHead(const Name, Summary,CSSFilename: string): string;
begin
  Result := Format(HTML_COMMON_HEAD, [Name,Summary,CSSFilename]);
end;

// TOOLBAR SECTION %ProjectName; %ContentName, %IndexName; %PreviousItemName, %NextItemName
function HTMLGenToolbar(const ProjectName, ContentName, IndexName
 ,PreviousItemName, NextItemName: string): string;
begin
  Result := Format(HTML_COMMON_TOOLBAR, [ProjectName, ContentName, IndexName
 ,PreviousItemName, NextItemName]);
end;

function HTMLGenSimpleSection(const SectionName, Item: string): string;
begin
  Result := Format(HTML_COMMON_SIMPLE_SECTION, [SectionName, Item]);
end;

function HTMLGenLinesSectionInit(const SectionName: string): string;
begin
  Result := Format(HTML_COMMON_LINES_SECTION_INIT, [SectionName]);
end;

function HTMLGenLinesSectionColoredInit(const SectionName: string): string;
begin
  Result := Format(HTML_COMMON_LINES_COLORED_SECTION_INIT, [SectionName]);
end;

function HTMLGenLinesSectionLine(const Item: string): string;
begin
  Result := Format(HTML_COMMON_LINES_SECTION_LINE, [Item]);
end;

function HTMLGenLinesSectionLineColored(const Item: string): string;
begin
  Result := Format(HTML_COMMON_LINES_SECTION_LINE_COLORED, [Item]);
end;

function HTMLGenLinesSectionEnd: string;
begin
  Result := Format(HTML_COMMON_LINES_SECTION_END, []);
end;

function HTMLGenTableSectionInit(const SectionName, IndexName1, IndexName2: string): string;
begin
  Result := Format(HTML_COMMON_TABLE_INIT, [SectionName, IndexName1, IndexName2]);
end;

function HTMLGenTableSectionLine(const ItemName, ItemDescription: string): string;
begin
  Result := Format(HTML_COMMON_TABLE_LINE, [ItemName , ItemDescription]);
end;

function HTMLGenTableSectionEnd: string;
begin
  Result := Format(HTML_COMMON_TABLE_END, []);
end;

function HTMLGenSimpleColoredSection(const SectionName, Item: string): string;
begin
  Result := Format(HTML_COMMON_SIMPLE_COLORED_SECTION, [SectionName, Item]);
end;

function HTMLGenFooter: string;
begin
  Result := Format(HTML_SECTION_FOOTER, []);
end;

function HTMLGenCSS: string;
begin
  Result := HTML_CSS_FILE;
end;


function HTMLGenMultiSectionInit(const SectionName: string): string;
begin
  Result := Format(HTML_COMMON_MULTI_SECTION_INIT, [SectionName]);
end;

function HTMLGenMultiSectionEnd: string;
begin
  Result := Format(HTML_COMMON_MULTI_END, []);
end;


{*------------------------------------------------------------------------------
  Build a link in HTML representation
  @param  st  description of the link (visual part of the link)
  @param  Link  file or reference where the link will lead
  @return HTML string of the hyperlink
 ------------------------------------------------------------------------------}
function HTMLBuildLink(const st : string; const Link : string) : string;
begin
  if Link<>'' then
  begin
    //<a href="LinkedFile.htm">Label</a>
    Result:=Format(HTML_LINKED_LABEL,[Link+HTML_FILE_EXT,st]);
    // Replace Windows file path separator '\' with web path separator '/'
    CharReplace(Result,'\','/');
  end
  else Result := st;
end;

function HTMLBuildLinkWithProps(const st : string; const Link, ClassName : string) : string;
begin
  if Link<>'' then
  begin
    //<a href="LinkedFile.htm">Label</a>
    Result:=Format(HTML_LINKED_LABEL_WITH_PROPS,[Link+HTML_FILE_EXT, ClassName, st]);
    // Replace Windows file path separator '\' with web path separator '/'
    CharReplace(Result,'\','/');
  end
  else Result := st;
end;

function StringsToHTMLStrings(const sl: TStringList; const NoCharEncode:boolean) : string;
var
  IndexLine: integer;
begin
  Result:='';
  if not assigned(sl) then exit;
  for IndexLine:=0 to sl.Count-1 do
  begin
    // Encode line to HTML is asked
    if NoCharEncode then
     Result:=Result+sl.Strings[IndexLine]
    else
     Result:=Result+StringToHtml(sl.Strings[IndexLine]);
    if IndexLine<(sl.Count-1) then Result:=Result+HTML_EOL;
  end;
end;

end.
