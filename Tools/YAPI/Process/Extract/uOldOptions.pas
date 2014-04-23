{*------------------------------------------------------------------------------
  Module that centralize all Options.
  This module contains the TDOCOptions, and all informations for each option :
   Name, Description, Values, translations, etc ...
  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @version   2004/08/06   TridenT   Added 'CommentDecoratorChar' option
  @version   2004/09/04   TridenT   Added 'HideEmptyOutputBlock' option
  @version   2005/09/05   TridenT   Added  'AllowHtmlInDescription' option
-------------------------------------------------------------------------------}

unit uOldOptions;

interface

uses
  Classes, SysUtils, uOptions;

type
  {*----------------------------------------------------------------------------
    Holder for all Options module
    Parser, structure builder, Generator and the DelphiCodeToDoc application
    share this class that contains all options.
  -----------------------------------------------------------------------------}
  TDOCOptions_TL03 = class(TComponent)
    // Must be a TComponent to have published property saved
  private
    //Property Field
    FRecurseDirectory: boolean; /// Search inside sub-directoryes
    FTitle: string; /// Title of the project
    FHTMLlink: string;  /// HTML link to the project page, or author page
    FCopyright: string; /// Copyright of the author
    FAuthor: string;  /// Information about the author (name, email for example)
    FName: string;  /// Name of the project, use as a basename for the output files
    FCustomFooter: TFileName; /// Author's Footer filename insert in each generated files
    FOutputFolder: TFileName; /// Where all output files will be saved
    FCustomHeader: TFileName; /// Author's Header filename insert in each generated files
    //FRootDirectory: TFileName; /// The directory where all sources files will be taken from
    FLanguage: TLanguage; /// Ouput Language of the documentation
    FOutputFormat: TOutputFormat; /// Output format od the documentation
    FConditionalDefines: TStringList; /// List of defines needed to interprete source code
    FSummary: string;  /// Summary of the project (only one line)
    FDescription: TStringList; /// Project's Description, few lines are permitted
    FTagCommentSet: TTagCommentSet; ///  TAG that will be extracted to the documentation
    FVisibilitySet: TVisibilitySet; /// Visibility filter wanted for the output
    FBoolsAsChecks: boolean;  ///  See Checkmarks or boolean expression for options
    FLaunchBrowser: boolean; /// Launch browser at the end of the documentation generation
    FAlphaSort: boolean;  /// Alphabetical sort of the Unit, Class, and member name
    FWarnEmptyTAG: boolean; /// Add a warning message in the documentation if some TAGs are missing
    FHideEmptyTAGSection: boolean;  /// Empty TAG section will be hide
    FSkipFirstTAGLine: boolean; /// Skip first TAG line, that are sometimes decorator
    FSkipLastTAGLine: boolean;  /// Skip last TAG line, that are sometimes decorator
    FParseImplementationSection: boolean; /// Also Parse implementation section (for TAG)
    FBracketStarJavaDocCharPrefix: char; /// JavaDoc Prefix for BracketStar comments
    FInLineJavaDocCharPrefix: char; /// JavaDoc Prefix for Inline comments
    FCurlyJavaDocCharPrefix: char; /// JavaDoc Prefix for Curly comments
    FHideEmptyOutputBlock: boolean; /// Hide any empty output block
    FOutputFilteringCategory : TOutputCategoryListSet; /// Show/Hide some members category
    FFilesIncludeList: TStringList; /// List of included items (files or folders)
    FFilesExcludeList: TStringList; /// List of exluded items (files or folders)
    FAllowHtmlInDescription: boolean; /// Keep description as string or Encode for html
    FPropertyCommentFromAssessors: boolean; /// Get comment from assessors for uncommented properties
  published
    // General options
    // Application Options
    property BoolsAsChecks: boolean Read FBoolsAsChecks Write FBoolsAsChecks stored True;
    property LaunchBrowser: boolean Read FLaunchBrowser Write FLaunchBrowser stored True;
    // Input options
    property Name: string Read FName Write FName stored True;
    property Title: string Read FTitle Write FTitle stored True;
    property Summary: string Read FSummary Write FSummary stored True;
    property Description: TStringList Read FDescription Write FDescription stored True;
    property Author: string Read FAuthor Write FAuthor stored True;
    property HTMLlink: string Read FHTMLlink Write FHTMLlink stored True;
    property Copyright: string Read FCopyright Write FCopyright stored True;
    //property RootDirectory: TFileName
    //  Read FRootDirectory Write FRootDirectory stored True;
    property RecurseDirectory: boolean Read FRecurseDirectory
      Write FRecurseDirectory stored True;
    property ConditionalDefines: TStringList
      Read FConditionalDefines Write FConditionalDefines stored True;
    property ParseImplementationSection: boolean
      Read FParseImplementationSection Write FParseImplementationSection stored True;
    // Output options
    property CustomHeader: TFileName Read FCustomHeader Write FCustomHeader stored True;
    property CustomFooter: TFileName Read FCustomFooter Write FCustomFooter stored True;
    property Language: TLanguage Read FLanguage Write FLanguage stored True;
    property OutputFormat: TOutputFormat
      Read FOutputFormat Write FOutputFormat stored True;
    property OutputFolder: TFileName Read FOutputFolder Write FOutputFolder stored True;
    property VisibilitySet: TVisibilitySet Read FVisibilitySet
      Write FVisibilitySet stored True;
    property TagCommentSet: TTagCommentSet Read FTagCommentSet
      Write FTagCommentSet stored True;
    property AlphaSort: boolean Read FAlphaSort Write FAlphaSort stored True;
    property WarnEmptyTAG: boolean Read FWarnEmptyTAG Write FWarnEmptyTAG stored True;
    property HideEmptyTAGSection: boolean Read FHideEmptyTAGSection
      Write FHideEmptyTAGSection stored True;
    property HideEmptyOutputBlock: boolean Read FHideEmptyOutputBlock
      Write FHideEmptyOutputBlock stored True;
    property OutputFilteringCategory:TOutputCategoryListSet read FOutputFilteringCategory
     write FOutputFilteringCategory stored True;
    // JavaDoc Support
    property SkipFirstTAGLine: boolean Read FSkipFirstTAGLine
      Write FSkipFirstTAGLine stored True;
    property SkipLastTAGLine: boolean Read FSkipLastTAGLine
      Write FSkipLastTAGLine stored True;
    // JavaDoc Prefix
    property InLineJavaDocCharPrefix: char Read FInLineJavaDocCharPrefix
      Write FInLineJavaDocCharPrefix stored True;
    property CurlyJavaDocCharPrefix: char Read FCurlyJavaDocCharPrefix
      Write FCurlyJavaDocCharPrefix stored True;
    property BracketStarJavaDocCharPrefix: char
      Read FBracketStarJavaDocCharPrefix Write FBracketStarJavaDocCharPrefix stored True;
    property FilesIncludeList: TStringList read FFilesIncludeList write FFilesIncludeList stored True;
    property FilesExcludeList: TStringList read FFilesExcludeList write FFilesExcludeList stored True;
    property AllowHtmlInDescription: boolean read FAllowHtmlInDescription write FAllowHtmlInDescription;
    property PropertyCommentFromAssessors: boolean read FPropertyCommentFromAssessors write FPropertyCommentFromAssessors;
  public
    // Internal options
    ApplicationLanguage: string;  /// ISO language name used in the application
    GeneratorLanguage: string; /// ISO language name used in the doc generated
    procedure SetDefaultValue;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function SaveToStream(Stream: TStream): TRWOptionsError;
    function LoadFromStream(Stream: TStream): TRWOptionsError;
    procedure CopyToTL04(DocOptions_TL04 : TDOCOptions);
  end;

const

{*------------------------------------------------------------------------------
  Technical level of saved project's file is the compatibility level of fiels.
  When adding informations to the project file, the TL change to reflect
  an incompatibility

  TL01 : First release
  TL02 : Added description, changed summary from TStringList to string
  TL03 : Added FilesIncludeList and FileExcludeList, Deleted RootDirectory
------------------------------------------------------------------------------*}
  C_OPTIONS_TL03_TECHNICAL_LEVEL: integer = $03;

  {gnugettext: scan-all text-domain='DCTD_ignore' }
  /// STARTING ID in the project file
  C_OPTIONS_IDENTIFICATION_START: string = 'DelphiCodeToDoc Options START';
  /// ENDING ID in the project file
  C_OPTIONS_IDENTIFICATION_END: string   = 'DelphiCodeToDoc Options END';
{gnugettext: reset }

implementation

/// Creates a TDOCOptions reference
constructor TDOCOptions_TL03.Create(AOwner: TComponent);
begin
  inherited;
  FDescription := TStringList.Create;
  FConditionalDefines := TStringList.Create;
  FFilesIncludeList := TStringList.Create;
  FFilesExcludeList := TStringList.Create;
end;

/// Destroy a TDOCOption reference
destructor TDOCOptions_TL03.Destroy;
begin
  FreeAndNil(FFilesIncludeList);
  FreeAndNil(FFilesExcludeList);
  FreeAndNil(FConditionalDefines);
  FreeAndNil(FDescription);
  inherited;
end;

/// Set all options to a default value
procedure TDOCOptions_TL03.SetDefaultValue;
begin
  FTitle     := L_InsertProjectTitle;
  FHTMLlink  := 'http://dephicodetodoc.sf.net (Replace by your webpage for example)';
  FCopyright := 'TridenT - 2003 - Under GNU GPL Licence';
  FAuthor    := L_InsertAuthorName;
  FName      := L_Project1;
  FCustomFooter := 'UNDER CONSTRUCTION';
  FOutputFolder := ExtractFilePath(ParamStr(0))+'out\';
  FCustomHeader := 'UNDER CONSTRUCTION';
  FLanguage  := lEnglish;
  FOutputFormat := ofCHM;//ofCHM;
  FConditionalDefines.Add('MSWINDOWS');
  FConditionalDefines.Add('WIN32');
  FConditionalDefines.Add('DELPHI5_UP');
  FSummary   := L_EnterProjectSummary;
  FDescription.Add(L_EnterProjectDescription);
  FAlphaSort     := True;
  FTagCommentSet := [tcInline, tcJavaDoc];
  FVisibilitySet := [mvPrivate, mvProtected, mvPublic, mvPublished, mvAutomated];
  FBoolsAsChecks := True;
  FRecurseDirectory := True;
  FLaunchBrowser := True;
  FWarnEmptyTAG  := True;
  FHideEmptyTAGSection := False;
  FSkipFirstTAGLine := True;
  FSkipLastTAGLine := True;
  FParseImplementationSection := True;
  FInLineJavaDocCharPrefix := '/';
  FCurlyJavaDocCharPrefix := '*';
  FBracketStarJavaDocCharPrefix := '*';
  FHideEmptyOutputBlock:= True;
  FOutputFilteringCategory := [ocConstants, ocTypes, ocVariables, ocFunctions
   , ocClasses, ocFields, ocMethods, ocProperties, ocEvents];
  FAllowHtmlInDescription := false;
  FPropertyCommentFromAssessors := True;
end;

{*------------------------------------------------------------------------------
  Load Project's Options from a stream
  The startup of the Stream is first verified, then read.
  @param Stream TStream of Project's options.
  @return TRWOptionsError error code.
------------------------------------------------------------------------------*}
function TDOCOptions_TL03.LoadFromStream(Stream: TStream): TRWOptionsError;
var
  OptionsID: PChar;
  OptionsTL: integer;
begin
  OptionsID := StrAlloc(length(C_OPTIONS_IDENTIFICATION_START) + 1);
  Result    := oeIDStartNOK;
  // Load STARTING Identification string
  if Stream.Read(OptionsID^, length(C_OPTIONS_IDENTIFICATION_START)) <>
    length(C_OPTIONS_IDENTIFICATION_START) then
  begin
    exit
  end;
  // Put #0 at end of string
  OptionsID[length(C_OPTIONS_IDENTIFICATION_START)] := #0;
  // Compare START_ID
  if string(OptionsID) <> C_OPTIONS_IDENTIFICATION_START then
  begin
    exit
  end;
  StrDispose(OptionsID);
  Result := oeTechLevelNOK;
  // Load Technical Level
  if Stream.Read(OptionsTL, sizeof(C_OPTIONS_TL03_TECHNICAL_LEVEL)) <>
    sizeof(C_OPTIONS_TL03_TECHNICAL_LEVEL) then
  begin
    exit
  end;
  // Verify Technical level for compatibility
  if OptionsTL <> C_OPTIONS_TL03_TECHNICAL_LEVEL then
  begin
    exit
  end;
  // Load Options propertys
  Stream.ReadComponent(self);
  // Load Ending Identification string
  Result    := oeIDEndNOK;
  OptionsID := StrAlloc(length(C_OPTIONS_IDENTIFICATION_END) + 1);
  if Stream.Read(OptionsID^, length(C_OPTIONS_IDENTIFICATION_END)) <>
    length(C_OPTIONS_IDENTIFICATION_END) then
  begin
    exit
  end;
  // Compare END_ID
  // Put #0 at end of string
  OptionsID[length(C_OPTIONS_IDENTIFICATION_END)] := #0;
  if string(OptionsID) <> C_OPTIONS_IDENTIFICATION_END then
  begin
    exit
  end;
  StrDispose(OptionsID);
  // end
  Result := oeNoError;
end;

{*------------------------------------------------------------------------------
  Save Project's Options to a stream
  Identification strings are written to string, and all options in raw mode.
  @param Stream TStream destination of Project's options
  @return TRWOptionsError error code.
------------------------------------------------------------------------------*}
function TDOCOptions_TL03.SaveToStream(Stream: TStream): TRWOptionsError;
begin
  Result := oeUnknown;
  // Save STARTING Identification string
  if Stream.Write(C_OPTIONS_IDENTIFICATION_START[1], Length(
    C_OPTIONS_IDENTIFICATION_START)) <> Length(C_OPTIONS_IDENTIFICATION_START) then
  begin
    exit
  end;
  // Save Technical Level
  if Stream.Write(C_OPTIONS_TL03_TECHNICAL_LEVEL, sizeof(C_OPTIONS_TL03_TECHNICAL_LEVEL)) <>
    sizeof(C_OPTIONS_TL03_TECHNICAL_LEVEL) then
  begin
    exit
  end;
  // Save Options propertys
  Stream.WriteComponent(self);
  // Save ENDING Identification string
  if Stream.Write(C_OPTIONS_IDENTIFICATION_END[1], Length(
    C_OPTIONS_IDENTIFICATION_END)) <> Length(C_OPTIONS_IDENTIFICATION_END) then
  begin
    exit
  end;
  // End
  Result := oeNoError;
end;

procedure TDOCOptions_TL03.CopyToTL04(DocOptions_TL04: TDOCOptions);
begin
  DocOptions_TL04.Title := FTitle;
  DocOptions_TL04.HTMLlink := FHTMLlink;
  DocOptions_TL04.Copyright := FCopyright;
  DocOptions_TL04.Author := FAuthor;
  DocOptions_TL04.Name := FName;
  DocOptions_TL04.CustomFooter := FCustomFooter;
  DocOptions_TL04.OutputFolder := FOutputFolder;
  DocOptions_TL04.CustomHeader := FCustomHeader;
  DocOptions_TL04.Language := FLanguage;
  DocOptions_TL04.OutputFormat := FOutputFormat;
  DocOptions_TL04.ConditionalDefines.Assign(FConditionalDefines);
  DocOptions_TL04.Summary   := FSummary;
  DocOptions_TL04.Description.assign(FDescription);
  DocOptions_TL04.AlphaSort     := FAlphaSort;
  DocOptions_TL04.TagCommentSet := FTagCommentSet;
  DocOptions_TL04.VisibilitySet := FVisibilitySet;
  DocOptions_TL04.BoolsAsChecks := FBoolsAsChecks;
  DocOptions_TL04.RecurseDirectory := FRecurseDirectory;
  DocOptions_TL04.LaunchBrowser := FLaunchBrowser;
  DocOptions_TL04.WarnEmptyTAG  := FWarnEmptyTAG;
  DocOptions_TL04.HideEmptyTAGSection := FHideEmptyTAGSection;
  DocOptions_TL04.SkipFirstTAGLine := FSkipFirstTAGLine;
  DocOptions_TL04.SkipLastTAGLine := FSkipLastTAGLine;
  DocOptions_TL04.ParseImplementationSection := FParseImplementationSection;
  DocOptions_TL04.InLineJavaDocCharPrefix := FInLineJavaDocCharPrefix;
  DocOptions_TL04.CurlyJavaDocCharPrefix := FCurlyJavaDocCharPrefix;
  DocOptions_TL04.BracketStarJavaDocCharPrefix := FBracketStarJavaDocCharPrefix;
  DocOptions_TL04.HideEmptyOutputBlock:= FHideEmptyOutputBlock;
  DocOptions_TL04.OutputFilteringCategory := FOutputFilteringCategory;
  DocOptions_TL04.AllowHtmlInDescription := FAllowHtmlInDescription;
  DocOptions_TL04.PropertyCommentFromAssessors := FPropertyCommentFromAssessors;
  DocOptions_TL04.FilesIncludeList.Assign(FFilesIncludeList);
  DocOptions_TL04.FilesExcludeList.Assign(FFilesExcludeList);
end;

end.
