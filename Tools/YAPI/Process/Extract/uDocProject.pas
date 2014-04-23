{*------------------------------------------------------------------------------
  Main unit of the process side in the project
  The project, once configured through the TDOCOptions class, can Check, and
  build the output files.
  Project's state is update on each action and can be read with State property
  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
-------------------------------------------------------------------------------}

unit uDocProject;

interface

uses
  Classes, SysUtils, Structure, DocGen, uOptions;

type
  /// State of the project, update on each action
  TProjectState = (psNew, psSaved, psModified);

  TItemTypeToParse = (itFolder, itDPRFile, itPASFile, itOther);

  {*----------------------------------------------------------------------------
    Main Class that manage the Parser, the Structure Builder and the Generator
     to build the Documentation from the source code in the configured format
  -----------------------------------------------------------------------------}
  TDOCProject = class
  private
    FDocOptions: TDOCOptions;  /// project's Options shared with Generator.
    FDocStructure: TDOCStructure; /// Holds the skeleton of the source code
    FFileList: TStringList; /// List of all file that will be processed
    FState: TProjectState;  /// State of the project (New, Checked of Built)
    FisChecked: boolean;    /// Specified if project has already been checked
    FdmUserMessages: TStrings;  /// Reference for writting User messages
    FdmDebugMessages: TStrings; /// Reference for writting Debug messages
    FFileName: TFileName; /// FileName (Not used)
    FOutputMainFileName: TFileName; /// Name of the saved file
    FCheckingFilename: TFilename; /// Name of file currently processing
    function BuildFileList(RootFolder: TFilename): integer;
    function CheckFile(const filename: TFilename): boolean;
    function AnalyseItemType(var ItemFilename: TFilename): TItemTypeToParse;
    procedure SearchForIgnore;
  public
    property DocOptions: TDOCOptions Read FDocOptions Write FDocOptions;
    property OutputMainFileName: TFileName read FOutputMainFileName;
    property State: TProjectState Read FState Write FState;
    property isChecked: boolean Read FisChecked Write FisChecked;
    property FileName: TFileName read FFileName write FFileName;
    property CheckingFilename: TFilename read FCheckingFilename;
    constructor Create;
    destructor Destroy; override;
    function Check: boolean;
    procedure AfterCheck;
    //function ParseFolder: boolean;
    function ParseDPRFile(dprFilename: TFilename): boolean;
    function ParseFileList: boolean;
    function Build: boolean;
    function GetStructure: TDOCStructure;
    procedure SetDestinationMessages(const dmUser, dmDebug: TStrings);
    function PurgeOutputFolder: Boolean;
    procedure ShowStatusMesssage(const psFile, psMessage: string;
     const piY, piX: integer);
  end;

var
  DocProject: TDOCProject;  /// The current project

implementation

uses
  JclImports, DocGenHTML, {StringsConverter} Converter, 
  DocGenHTML_Common, DocGenCHM, StrUtils, windows,DocGenCHM_Common,
  uDocUseUnit, uDocProgram;

resourcestring
  L_ParsingFile = 'Parsing file : %s';
  L_PurgingOutputDirectory = 'Output Directory purged';
  L_NothingToPurge = 'Nothing to purge';
  L_ItemNotFound = 'Included Item not found : %s';
  L_NothingToParse = 'Nothing to parse, list is empty';
  L_IgnoringItem = 'Ignoring item : %s';

const
  DPR_FILE_EXT: string = '.DPR';
  PAS_FILE_EXT: string = '.PAS';
  HTM_FILE_EXT: string = '.HTM';


procedure TDOCProject.ShowStatusMesssage(const psFile, psMessage: string;
  const piY, piX: integer);
var
  lsMessage: string;
begin
  { show the message }
  lsMessage := psMessage;
  if (piX > 0) and (piY > 0) then
    lsMessage := lsMessage + ' near line ' + IntToStr(piY) + ' col ' + IntToStr(piX);
  FdmDebugMessages.Add(lsMessage);

  { scroll into view and check the srollbar }
  {mOutput.CurrentLine := mOutput.Lines.Count - 1;
  if mOutput.Lines.Count > 1 then
    mOutput.ScrollBars := ssVertical
  else
    mOutput.ScrollBars := ssNone;}

  //Application.ProcessMessages;
end;

{*------------------------------------------------------------------------------
  Build the project by creating the output files
  It verify if the project is ready to be build, and then call the Generator
  by the execute method.
  Additionnaly, the project's State is set to psBuilt if successfull
  @return   TRUE if succesfull, FALSE otherwise
-------------------------------------------------------------------------------}
function TDOCProject.Build: boolean;
var
  DocGenerator: TDOCGenerator;
  BuildErrorMsg : string;
begin
  if DocProject.isChecked then
  begin
    // Save Application language
    DocOptions.ApplicationLanguage := 'en';
    DocOptions.GeneratorLanguage := 'en';
    // Create Generator
    case FDocOptions.OutputFormat of
      //ofTEXT: DocGenerator := TDocGenTXT.Create;
      ofHTML: DocGenerator := TDocGenHTML.Create;
      ofCHM: DocGenerator := TDocGenCHM.Create;
    else
      raise Exception.Create('No support for this kind of Generator');
    end; // case
    // verify if it is possible to build the output
    DocGenerator.VerifyCondition(BuildErrorMsg);
    DocGenerator.DocOptions := FDocOptions;
    DocGenerator.MessageStrings := FdmDebugMessages;
    // Change output language (fixed to English for the moment)
    //UseLanguage(DocOptions.GeneratorLanguage);
    try
      try
        // Build
        DocGenerator.Execute(DocProject.FDocStructure);
        FOutputMainFileName:=DocGenerator.GetOutputFile;
        Result := True;
      except
        on E: Exception do
       begin
         FdmDebugMessages.Add(E.message);
         Result := False;
        end;
        else
          Result := False;
      end;
    finally
      FreeAndNil(DocGenerator);
    end;
  end
  else    begin
    Result := False
  end;
end;

{*------------------------------------------------------------------------------
  Test if file is Pascal source file
  Function is defined as JclUtilsFile needs : TFileMatchFunc =
   function(const Attr: Integer; const FileInfo: TSearchRec): Boolean;
  @return TRUE if extension match with '*.pas filter', FALSE otherwise
-------------------------------------------------------------------------------}
function PasMatchFunc(const Attr: Integer; const FileInfo: TSearchRec): Boolean;
const
  PAS_FILE_EXT = '.pas';
begin
  Result := ((Attr and FileInfo.Attr) <> 0)
   and SameText(ExtractFileExt(FileInfo.Name),PAS_FILE_EXT);
end;

{*------------------------------------------------------------------------------
  Build a file list filtered with PAS extension
  Start is the input directory, a,s eventually the sub-directoryes,
  it then add all matching files in the FileList.
  @return   Number of files found if succesfull, -1 otherwise
-------------------------------------------------------------------------------}
function TDOCProject.BuildFileList(RootFolder: TFilename): integer;
const
  PAS_FILE_FILTER : string = '*.pas';
var
  flOptions: TFileListOptions;
begin
  if FDocOptions.RecurseDirectory then
  begin
    flOptions := [flRecursive, flFullNames]
  end
  else     begin
    flOptions := [flFullNames]
  end;
  // $80 must be added because if the file's archive attribute is not set,
  // then FindFirst return [FindoInfo.Attr = 128]  ...
  if AdvBuildFileList(RootFolder + PAS_FILE_FILTER, $80 +
    faReadOnly + faHidden + faSysFile + faArchive, FFileList,{amAny} amCustom,
    flOptions, '', {nil}PasMatchFunc) then
  begin
    Result := FFileList.Count;
  end
  else     begin
    Result := -1
  end;
end;

/// Analyse DPR file to extract units name and path
function TDOCProject.ParseDPRFile(dprFilename: TFilename): boolean;
var
  tmpUseUnit: TDOCUseUnit;
  tmpDocProgram: TDOCProgram;
  IndexUseUnit: integer;
  DocProgramPath: TFileName;
begin
  // parse DPR File
  CheckFile(dprFilename);
  DocProgramPath:=ExtractFilePath(dprFilename);
  // Build file list with uses units
  tmpDocProgram:=FDocStructure.GetProgram as TDOCProgram;
  assert(assigned(tmpDocProgram));
  for IndexUseUnit:=0 to tmpDocProgram.UseUnitList.Count-1 do
  begin
   tmpUseUnit:=tmpDocProgram.UseUnitList.Items[IndexUseUnit] as TDOCUseUnit;
   if tmpUseUnit.ExistFileName then
    if Pos(DriveDelim,tmpUseUnit.FileName)<>0 then
     FFileList.Add(tmpUseUnit.FileName)
    else FFileList.Add(DocProgramPath+tmpUseUnit.FileName);
  end;
  Result:=FFileList.Count>0;
end;

/// Parse file list
function TDOCProject.ParseFileList: boolean;
var
  IndexFile:      integer;
  ProcessedFiles: integer;
begin
  ProcessedFiles     := 0;
  for IndexFile := 0 to FFileList.Count - 1 do
  begin
    // Process message
    if CheckFile(FFileList.Strings[IndexFile]) then
     ProcessedFiles := ProcessedFiles + 1
  end;
  Result := (ProcessedFiles = FFileList.Count);
  // Sort Structure content if option is ON
  if FDocOptions.AlphaSort then
  begin
    FDocStructure.SortContent;
  end;
end;

/// Process Tag coverage after check
procedure TDOCProject.AfterCheck;
begin
  { TODO 1 -oTridenT -cBug : Add name and description to structure }
  FDocStructure.UpdateAllTagCoverage;
end;

function TDOCProject.AnalyseItemType(var ItemFilename: TFilename): TItemTypeToParse;
var
  ProjectDir: string;
  ItemFileDir: string;
begin
  result:=itOther;
  // test if Directory
  if RightStr(ItemFilename,1) = PathDelim then
  begin
    if DirectoryExists(ItemFilename) then result:=itFolder;
  end
  else
  // test if DPR File
  if UpperCase(ExtractFileExt(ItemFilename))=DPR_FILE_EXT then
  begin
    if FileExists(ItemFilename) then result:=itDPRFile;
  end
  // test if PAS file
  else
  if UpperCase(ExtractFileExt(ItemFilename))=PAS_FILE_EXT then
  begin
    if FileExists(ItemFilename) then result:=itPASFile;
  end
  else result:=itOther;

  // If the type could not be determined, then try again by prefixing the
  // project root directory to the filename, if it has no absolute directory
  // part.
  ProjectDir := ExtractFilePath(FileName);
  ItemFileDir := ExtractFilePath(ItemFileName);
  if (result = itOther) and
     (not PathIsAbsolute(ItemFileDir)) then
  begin
    ItemFileName := PathCanonicalize(PathAddSeparator(ProjectDir) + ItemFileName);
    Result := AnalyseItemType(ItemFileName);
  end;
end;

{*------------------------------------------------------------------------------
  Verify if Project can be build
  This is a must before building the project. It checks and parse all files in
  the FileList.
  If successfull, the Projects's state is set to psChecked
  @return     TRUE if succesfull, FALSE otherwise
-------------------------------------------------------------------------------}
function TDOCProject.Check: boolean;
var
  IndexInclude: integer;
  ItemFileName: TFilename;
begin
  // Clear all units
  FDocStructure.Clear;
  FFileList.Clear;
  FDocStructure.Name := FDocOptions.Name;
  // Analyse the Include list
  for IndexInclude:=0 to DocOptions.FilesIncludeList.count-1 do
  begin
    ItemFileName := DocOptions.FilesIncludeList.Strings[IndexInclude];
    case AnalyseItemType(ItemFileName) of
     itFolder: BuildFileList(ItemFileName);
     itDPRFile: ParseDPRFile(ItemFileName);
     itPASFile: FFileList.Add(ItemFileName);
     itOther: FdmDebugMessages.Add(Format(L_ItemNotFound,[ItemFileName]));
    else Raise Exception.CreateFmt('Unknown Item type for '+L_ItemNotFound
     ,[ItemFileName]);
    end;
  end;
  SearchForIgnore;
  if FFileList.Count>0 then Result:=ParseFileList()
  else
  begin
    // DPR file was parsed !
    result:=true;
  end;
  GetStructure.ClassTree.LinkOrphanedChilds;
  FisChecked := Result;
  if Result = True then AfterCheck();
end;

{*------------------------------------------------------------------------------
  Check and parse a delphi source code file
  For the moment, this function always return a successfull value
  @param    filename  File to Check
  @return   TRUE if succesfull, FALSE otherwise
-------------------------------------------------------------------------------}
function TDOCProject.CheckFile(const filename: TFilename): boolean;
var
  fcConverter: TConverter;
begin
  Result := True;
  FdmDebugMessages.Add(Format(L_ParsingFile, [filename]));
  FCheckingFilename:=filename;

  fcConverter := TConverter.Create;
  fcConverter.OnStatusMessage := ShowStatusMesssage;
  fcConverter.InputCode := FileToString(filename);
  try
    fcConverter.Convert;
  except
    Result := False;
  end;

  fcConverter.Clear;
  FreeAndNil(fcConverter);
end;

{*------------------------------------------------------------------------------
  Creates and initializes a TDOCProject
  The project's state is set to psNew after the creation
-------------------------------------------------------------------------------}
constructor TDOCProject.Create;
begin
  inherited;
  FDocOptions := TDOCOptions.Create(ExtractFilePath(ParamStr(0)));
  FDocStructure := TDOCStructure.Create('', nil);
  FDocStructure.DocOptions := FDocOptions;
  FFileList := TStringList.Create;
  FState := psNew;
  FFileName:='';
end;

{*------------------------------------------------------------------------------
  Destroy a TDOCProject reference
  It frees all lists its own
-------------------------------------------------------------------------------}
destructor TDOCProject.Destroy;
begin
  FreeAndNil(FFileList);
  FreeAndNil(FDocStructure);
  FreeAndNil(FDocOptions);
  inherited;
end;

{*------------------------------------------------------------------------------
  Return the Structure of a project
  @return   Structure reference
-------------------------------------------------------------------------------}
function TDOCProject.GetStructure: TDOCStructure;
begin
  Result := FDocStructure;
end;

{*------------------------------------------------------------------------------
  Configure the User output and Debug output to inform about the status
  The TDOCProject class is very separated from the external user interface.
  But in order to inform about the state of the project, it needs to know where
  to display informations. This could be a visual control, or a file or whatever
  containing a TStrings reference to work.

  @param    dmUser  Where User messages will be written
  @param    dmDebug Where Debug messages will be written
-------------------------------------------------------------------------------}
procedure TDOCProject.SetDestinationMessages(const dmUser, dmDebug: TStrings);
begin
  FdmUserMessages  := dmUser;
  FdmDebugMessages := dmDebug;
end;

{*------------------------------------------------------------------------------
  Test if file is HTM source file
  Function is defined as JclUtilsFile needs : TFileMatchFunc =
   function(const Attr: Integer; const FileInfo: TSearchRec): Boolean;
  @return TRUE if extension match with '*.htm filter', FALSE otherwise
-------------------------------------------------------------------------------}
function HtmMatchFunc(const Attr: Integer; const FileInfo: TSearchRec): Boolean;
begin
  Result := ((Attr and FileInfo.Attr) <> 0)
   and SameText(ExtractFileExt(FileInfo.Name),HTML_FILE_EXT);
end;

//TDelTreeProgress = function (const FileName: string; Attr: DWORD): Boolean;
function PurgeProjectFolderProgress(const FileName: string; Attr: DWORD): Boolean;
begin
  // Delete only folders or htm files
  result:=false;
  if Attr and FILE_ATTRIBUTE_DIRECTORY = FILE_ATTRIBUTE_DIRECTORY then result:=true
  else if UpperCase(ExtractFileExt(FileName))=HTM_FILE_EXT then result:=true;
end;

/// Delete to Trash
function TDOCProject.PurgeOutputFolder: Boolean;
var
  HTMLOutputFolder: string;
  DeletedFiles: integer;
begin
  DeletedFiles:=0;
  HTMLOutputFolder:=Docproject.DocOptions.EffectiveOutputFolder+'html\';
  // Delete DCTD CSS File
  if FileDelete(HTMLOutputFolder+'YAPI'+CSS_FILE_EXT,true) then
   inc(DeletedFiles);
  // Delete the project file
  if FileDelete(HTMLOutputFolder+FDocStructure.BuildPathName+HTML_FILE_EXT,true) then
   inc(DeletedFiles);
  // and Delete the entire project directory
  DelTreeEx(HTMLOutputFolder+FDocStructure.BuildPathName+PathDelim,true,PurgeProjectFolderProgress);
  // Delete the hhc, hhk and hhp files
  if FileDelete(Docproject.DocOptions.EffectiveOutputFolder+FDocStructure.BuildPathName
   +HHP_FILE_EXT,true) then inc(DeletedFiles);
  if FileDelete(Docproject.DocOptions.EffectiveOutputFolder+FDocStructure.BuildPathName
   +HHC_FILE_EXT,true) then inc(DeletedFiles);
  if FileDelete(Docproject.DocOptions.EffectiveOutputFolder+FDocStructure.BuildPathName
   +HHK_FILE_EXT,true) then inc(DeletedFiles);
  // Delete the CHM file
  if FileDelete(Docproject.DocOptions.EffectiveOutputFolder+FDocStructure.BuildPathName
   +CHM_FILE_EXT,true) then inc(DeletedFiles);

  if DeletedFiles>0 then
  begin
    FdmUserMessages.Add(L_PurgingOutputDirectory);
    Result:=True;
  end
  else
  begin
    FdmUserMessages.Add(L_NothingToPurge);
    result:=false;
  end;
end;


// Search in generated FileList if some match the ignore list.
procedure TDOCProject.SearchForIgnore;
var
  IndexIgnoreItem: integer;
  IndexFile: integer;
  ContinueIgnoreList: Boolean;
  CurrentFileName: string;
  ExcludeFileName: string;
begin
  // Exit if no exclude filter
  if DocProject.DocOptions.FilesExcludeList.Count=0 then exit;
  // process items in FileList
  IndexFile:=0;
  while(IndexFile<FFileList.Count) do
  begin
    CurrentFileName := FFileList.Strings[IndexFile];

    ContinueIgnoreList:=true;
    IndexIgnoreItem:=0;
    while((IndexIgnoreItem<DocProject.DocOptions.FilesExcludeList.Count)
     and   ContinueIgnoreList) do
    begin
      // tests if path includes one of the ignore list
      ExcludeFileName := DocProject.DocOptions.FilesExcludeList.Strings[IndexIgnoreItem];
      if (AnsiContainsText(CurrentFileName, ExcludeFileName) = True) or
       (IsFileNameMatch(CurrentFileName, ExcludeFileName) = true) then
      begin
        ContinueIgnoreList:=false;
        FdmDebugMessages.Add(Format(L_IgnoringItem,[CurrentFileName]));
        FFileList.Delete(IndexFile);
      end
      else inc(IndexIgnoreItem);
    end;
    // if no ignore found, continue with next item
    if ContinueIgnoreList then inc(IndexFile);
  end;
end;

end.
