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
  @version   2005/09/05   TridenT   Adde  'AllowHtmlInDescription' option
-------------------------------------------------------------------------------}

unit uOptions;

interface

uses
  Classes, SysUtils;

type
  /// OutPut format Styles for the Generated Documentation
  TOutputFormat  = (ofHTML, ofCHM); // ofTEXT, ofPDF
  /// List of keywords for Member visiblity
  TMemberVisibility = (mvPrivate, mvProtected, mvPublic, mvPublished
   , mvAutomated);
  /// Set of Member visibility
  TVisibilitySet = set of TMemberVisibility;
  /// List of member category
  TOutputCategoryList = (ocConstants, ocTypes, ocVariables, ocFunctions
   , ocClasses, ocFields, ocMethods, ocProperties, ocEvents);
  /// Set of member category
  TOutputCategoryListSet = set of TOutputCategoryList;
  /// List of supported TAG recognition
  TTagComment    = (tcINLINE, tcJAVADOC, tcJEDI,tcXMLDoc);
  /// Set of TAG recognition
  TTagCommentSet = set of TTagComment;
  /// List of language supported by the application
  TLanguage      = (lEnglish, lFrench);
  /// Return value for managing project's configuration file
  TRWOptionsError = (oeNoError, oeUnknown, oeIDStartNOK, oeIDEndNOK, oeTechLevelNOK);

  {*----------------------------------------------------------------------------
    Holder for all Options module
    Parser, structure builder, Generator and the DelphiCodeToDoc application
    share this class that contains all options.
  -----------------------------------------------------------------------------}
  TDOCOptions = class(TPersistent)
    // Must be a TPersistent to have published property saved
  private
    FApplicationPath : TFilename;
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
    FDisplayHiddenItems: Boolean; /// Display items defined only in implementation section
    // end properties
    function GetEffectiveOutputFolder: string;
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
    property DisplayHiddenItems : Boolean read FDisplayHiddenItems write FDisplayHiddenItems stored True;
  public
    // Internal options
    ApplicationLanguage: string;  /// ISO language name used in the application
    GeneratorLanguage: string; /// ISO language name used in the doc generated
    procedure SetDefaultValue;
    procedure SetupPaths(DprPath, OutPath : String);

    constructor Create(ApplicationPath : TFilename); virtual;
    destructor Destroy; override;
    property EffectiveOutputFolder: string read GetEffectiveOutputFolder;
  end;

  {*----------------------------------------------------------------------------
    Description of options by short name and name
    Each option need to be describe as follow :
    The name of the property inside the class : pdName_____
    The written Caption of this options in the application : pdCaption_____
    The possibility for the user to modify this option at runtime : TRUE/FALSE
    A notify method to react immediately about a changed value for this option
  -----------------------------------------------------------------------------}
  TPropertyDescription = record
    iName, iCaption: string;
    iReadOnly: boolean;
    iChanged: TNotifyEvent;
  end;

{gnugettext: scan-all text-domain='DCTD_ignore' }
resourcestring
  // Name for Options
  pdNameBoolsAsChecks = 'BoolsAsChecks';
  pdNameName      = 'Name';
  pdNameTitle     = 'Title';
  pdNameSummary   = 'Summary';
  pdNameDescription = 'Description';
  pdNameAuthor    = 'Author';
  pdNameHTMLLink  = 'HTMLlink';
  pdNameCopyright = 'Copyright';
  pdNameRecurseDirectory = 'RecurseDirectory';
  pdNameConditionalDefines = 'ConditionalDefines';
  pdNameCustomHeader = 'CustomHeader';
  pdNameCustomFooter = 'CustomFooter';
  pdNameLanguage  = 'Language';
  pdNameOutputFormat = 'OutputFormat';
  pdNameOutputFolder = 'OutputFolder';
  pdNameVisibilitySet = 'VisibilitySet';
  pdNameTagCommentSet = 'TagCommentSet';
  pdNameLaunchBrowser = 'LaunchBrowser';
  pdNameSortAlpha = 'AlphaSort';
  pdNameWarnEmptyTAG = 'WarnEmptyTAG';
  pdNameHideEmptyTAGSection = 'HideEmptyTAGSection';
  pdNameSkipFirstTAGLine = 'SkipFirstTAGLine';
  pdNameSkipLastTAGLine = 'SkipLastTAGLine';
  pdNameParseImplementationSection = 'ParseImplementationSection';
  pdNameHideEmptyOutputBlock = 'HideEmptyOutputBlock';
  pdNameOutputFilteringCategory = 'OutputFilteringCategory';
  pdNameBracketStarJavaDocCharPrefix = 'BracketStarJavaDocCharPrefix';
  pdNameInLineJavaDocCharPrefix = 'InLineJavaDocCharPrefix';
  pdNameCurlyJavaDocCharPrefix = 'CurlyJavaDocCharPrefix';
  pdNameFilesIncludeList = 'FilesIncludeList';
  pdNameFilesExcludeList = 'FilesExcludeList';
  pdNameAllowHtmlInDescription = 'AllowHtmlInDescription';
  pdNamePropertyCommentFromAssessors = 'PropertyCommentFromAssessors';
  pdNameDisplayHiddenItems = 'DisplayHiddenItems';
  {gnugettext: reset }

  // Caption  for Options
  pdCaptionBoolsAsChecks = 'Bools as Checks';
  pdCaptionName      = 'Project''s Name';
  pdCaptionTitle     = 'Project''s Title';
  pdCaptionSummary   = 'Project''s Summary';
  pdCaptionDescription = 'Project''s Description';
  pdCaptionAuthor    = 'Project''s Author';
  pdCaptionHTMLLink  = 'HTML Link';
  pdCaptionCopyright = 'Author''s Copyright';
  //pdCaptionRootDirectory = 'Root Directory';
  pdCaptionRecurseDirectory = 'Recurse Directory';
  pdCaptionConditionalDefines = 'Conditional Defines';
  pdCaptionCustomHeader = 'Custom Header';
  pdCaptionCustomFooter = 'Custom Footer';
  pdCaptionLanguage  = 'Documentation Language';
  pdCaptionOutputFormat = 'Output Format';
  pdCaptionOutputFolder = 'Output Folder';
  pdCaptionVisibilitySet = 'Member visibility filter';
  pdCaptionTagCommentSet = 'Comment syntax recognition';
  pdCaptionLaunchBrowser = 'Launch Browser after Build?';
  psCaptionSortAlpha = 'Alpha sort of members';
  psCaptionWarnEmptyTAG = 'Warn when TAG are empty';
  pdCaptionHideEmptyTAGSection = 'Hide empty TAG section from report';
  pdCaptionSkipFirstTAGLine = 'Skip first TAG line in comment block';
  pdCaptionSkipLastTAGLine = 'Skip last TAG line in comment block';
  pdCaptionParseImplementationSection = 'Parse Implementation Section';
  pdCaptionBracketStarJavaDocCharPrefix = 'BracketStart Prefix  (*';
  pdCaptionInLineJavaDocCharPrefix = 'Inline Prefix  //';
  pdCaptionCurlyJavaDocCharPrefix = 'Curly Prefix {';
  pdCaptionHideEmptyOutputBlock = 'Hide empty block from report';
  pdCaptionOutputFilteringCategory = 'Output Filtering Category';
  pdCaptionFilesIncludeList = 'Included Files list';
  pdCaptionFilesExcludeList = 'Excluded Files list';
  pdCaptionAllowHtmlInDescription = 'Allow Html in Description';
  pdCaptionPropertyCommentFromAssessors = 'If empty, get Comment from Assessors';
  pdCaptionDisplayHiddenItems = 'Display hidden items (defined in implementation only)';

  // Caption for Custom Category
  ccApplicationOptions = 'Application options';
  ccInputOptions  = 'Input options';
  ccOutputOptions = 'Output options';
  ccJavaDocSupportOptions = 'JavaDoc support options';
  ccJavaDocPrefixOptions = 'JavaDoc Prefix (only one character)';
  ccFilesList = 'Files and folders list';
  ccPropertiesComment = 'Properties comment';

  oeTextNoError      = 'No error';
  oeTextUnknown      = 'Unknown error';
  oeTextIDStartNOK   = 'Starting ID doesn''t match with this application';
  oeTextIDEndNOK     = 'Ending ID doesn''t match with this application';
  oeTextTechLevelNOK = 'The file is not compatible with this application revision';

  L_InsertProjectTitle = 'Insert your project''s title here';
  L_InsertAuthorName = 'Insert author''s name here';
  L_Project1 = 'Project1';
  L_EnterProjectSummary = 'Enter your project''s summary in a single line';
  L_EnterProjectDescription = 'Enter your project''s multilines description';

implementation

uses JclImports;

/// Creates a TDOCOptions reference
constructor TDOCOptions.Create(ApplicationPath : TFileName);
begin
  inherited Create;
  FDescription := TStringList.Create;
  FConditionalDefines := TStringList.Create;
  FFilesIncludeList := TStringList.Create;
  FFilesExcludeList := TStringList.Create;
  FApplicationPath := ApplicationPath;
end;

/// Destroy a TDOCOption reference
destructor TDOCOptions.Destroy;
begin
  FreeAndNil(FFilesIncludeList);
  FreeAndNil(FFilesExcludeList);
  FreeAndNil(FConditionalDefines);
  FreeAndNil(FDescription);
  inherited;
end;

function TDOCOptions.GetEffectiveOutputFolder: string;
begin
  Result := OutputFolder;

  { -- Disable canonical stuff.
  if not PathIsAbsolute(Result) then
    Result := PathCanonicalize(PathAddSeparator(FProjectFolder) + Result);
  }

  Result := PathAddSeparator(Result);
end;

/// Set all options to a default value
procedure TDOCOptions.SetDefaultValue;
begin
  FTitle     := 'YAWE (Yet Another WoW Emulator)';
  FHTMLlink  := 'http://www.assembla.com/wiki/show/YAWE_Public';
  FCopyright := 'YAWE Team';
  FAuthor    := 'YAWE Team';
  FName      := 'YAWE';
  FCustomFooter := 'UNDER CONSTRUCTION';
  FOutputFolder := '--';
  FCustomHeader := 'UNDER CONSTRUCTION';
  FLanguage  := lEnglish;
  FOutputFormat := ofHTML;//ofCHM;

  FConditionalDefines.Add('MSWINDOWS');
  FConditionalDefines.Add('WIN32');
  FConditionalDefines.Add('DELPHI5_UP');

  FSummary   := 'OOP oriented MMOG server with Intel assembler optimizations.';

  FDescription.Add('YAWE Project aims to bring a revolutionary approach to WoW Emulation scene.');
  FDescription.Add('By using High-Level code mixed with assembler optimizations it will bring');
  FDescription.Add('high speed and low latency into WoW Emulation world!');

  FAlphaSort     := True;
  FTagCommentSet := [tcInline, tcJavaDoc];
  FVisibilitySet := [mvPrivate, mvProtected, mvPublic, mvPublished, mvAutomated];
  FBoolsAsChecks := True;
  FRecurseDirectory := True;
  FLaunchBrowser := False;
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
  FDisplayHiddenItems := True;
end;

procedure TDOCOptions.SetupPaths(DprPath, OutPath: String);
begin
 FOutputFolder := OutPath + '\';
 FFilesIncludeList.Add(DprPath);
end;

end.
