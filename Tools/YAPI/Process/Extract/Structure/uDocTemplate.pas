{*------------------------------------------------------------------------------
  Base class to represent all components in Delphi language
  Components are various, Units, classes, const, Vars, fields, methods ...
  The structure builder will create these objects from the parser informations.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @Version   2006/12/01   TridenT   Extracted from Structure.pas file
-------------------------------------------------------------------------------}

unit uDocTemplate;

interface

uses Windows, SysUtils, Classes, Contnrs, TAGComment, uOptions, uDocTagCoverage;

type

  TDOCTemplate = class; // forward declaration
  /// Class factory based on TDOCTemplate
  TDOCTemplateClass = class of TDOCTemplate;
  TDOCTemplateList = class; // forward declaration
  /// Class factory based on TDOCTemplateList
  TDOCTemplateListClass = class of TDOCTemplateList;
  TDOCClassList    = TDOCTemplateList;   /// List of TDOCClass
  TDOCTypeList     = TDOCTemplateList;   /// List of TDOCTypes
  TDOCConstantList = TDOCTemplateList;   /// List of TDOCConst
  TDOCFieldList    = TDOCTemplateList;   /// List of TDOCField
  TDOCPropertyList = TDOCTemplateList;   /// List of TDOCPropertie
  TDOCEventList    = TDOCTemplateList;   /// List of TDOCEvent
  TDOCVarList      = TDOCTemplateList;   /// List of TDOCVar
  TDOCUseUnitList  = TDOCTemplateList;   /// List of TDOCUseUnit
  TDOCUnitList     = TDOCTemplateList;   /// List of TDOCUnit
  TDOCParameterList = TDOCTemplateList;  /// List of TDOCparameters
  TDOCLinkList     = TDOCTemplateList;   /// List of TDOCLinks

  ///  A link to a unit, class or another Maybe replace by an ObjectList with all DocTemplate !
  TDOCLink = class
  private
    Name: string; /// Name of the linked object
    Link: TDOCTemplate; /// Link to the object
  public
    constructor Create(const ln: string);
  end;

  {**
   * Callback event for a temporary 'Visitor'
   * @return TRUE/FALSE depends on specific process
   *}
  TDocCallbackEvent = function : boolean of object;

  /// Base class for Classes, members, ... in the final structure
  TDOCTemplate = class(TObject)
  private
    FRelatedParent: TDocTemplate; /// Logical Parent of this item
    FName: string;  /// Name of the item, often time an identifier
    FTAGHolderList: TTAGHolderList; /// Holder for all item's TAG
    FTagCoverageHolder : TTagCoverageHolder; /// Tags coverage statistics and details
    class var FOnGetEvaluateDisplay : TDocCallbackEvent; /// DO NOT ADD THINGS AFTER (ClassVar)
  protected
    FTemplateListList : TObjectList; /// List of all Template lists
    function CreateDocTemplateList(const DocListClass : TDOCTemplateListClass) : TDOCTemplateList;
    procedure CheckTagCoverage(const DocTag : TDOCTag; const subID: string = '');
  public
    RelatedType: string;  /// TDOCLink;
    Links: TDOCLinkList;  /// of TDOCLinks
    BodySource: string; /// Source code of the expression
    Hidden : Boolean; /// Hidden if defined in implememtation section only
    property TemplateListList : TObjectList read FTemplateListList;
    property TagCoverageHolder : TTagCoverageHolder read FTagCoverageHolder;
    property Name: string Read FName Write FName;
    property TAGHolderList: TTAGHolderList Read FTAGHolderList Write FTAGHolderList;
    property RelatedParent: TDocTemplate read FRelatedParent;
    class property OnEvaluateDisplay: TDocCallbackEvent read FOnGetEvaluateDisplay write FOnGetEvaluateDisplay;
    constructor Create(const st: string; const rp: TDocTemplate); virtual;
    destructor Destroy; override;
    function AddLink(const ln: string): TDOCLink;
    function GetParentName: string;
    function GetFileName : string;virtual;
    function BuildPathName: string; virtual;
    function BuildRelativePathName: string; virtual;
    function CategoryType: TOutputCategoryList; virtual;
    function DoEvaluateDisplay : Boolean;
    procedure UpdateTagCoverage; virtual;
    function GetTemplateName : string;virtual;
  end;

  /// Base class for TDOCTemplate containers (holds TDOCTemplate objects)
  TDOCTemplateList = class(TObjectList)
  protected
    function GetItem(const Index: integer): TDOCTemplate;
    procedure SetItem(const Index: integer; const item: TDOCTemplate);
  public
    property Items[const Index: integer]: TDOCTemplate Read GetItem Write SetItem;
      default;
    function FindItemByName(const st: string): TDOCTemplate;
    function FindNextItemByName(const st: string; ItemStart:TDOCTemplate): TDOCTemplate;
    function NextItem(const Item: TDOCTemplate): TDOCTemplate;
    function PrevItem(const Item: TDOCTemplate): TDOCTemplate;
    function New(const aname: string; const DocParent: TDOCTemplate;
        const DocClass:TDOCTemplateClass): TDOCTemplate;virtual;
    end;

// Forward declaration
function DocTemplateListSortCompare(Item1, Item2: Pointer): integer;

implementation

uses
  StrUtils, JclImports;

{*------------------------------------------------------------------------------
  Comparison function for TDocTemplateList, used for sorting.
  @param Item1 Pointer (must be TDOCtemplate object) to first item to compare
  @param Item2 Pointer (must be TDOCtemplate object) to second item to compare
-------------------------------------------------------------------------------}
function DocTemplateListSortCompare(Item1, Item2: Pointer): integer;
begin
  if((IsObject(Item1) = True) and (IsObject(Item2) = True)) then
   Result := CompareText(TDOCTemplate(Item1).Name, TDOCTemplate(Item2).Name)
  else Result := 0;
end;

/// Add a link to the Link List (NOT USED FOR THE MOMENT)
function TDOCTemplate.AddLink(const ln: string): TDOCLink;
begin
  Result := TDOCLink.Create(ln);
  Links.Add(Result);
end;

{*------------------------------------------------------------------------------
  Verify the filename compatibility (with Windows OS) and fix it if nedded
  Reserved word are :
  CON, COMx (COM1, COM2, ...), LPTx (LPT1, LPT2, ...), NUL, PRN, AUX,
  @param fileInput Input filename to verify
  @return Fixed filename (or same if valid)
 ------------------------------------------------------------------------------}
function ConvertToValidFilename(const fileInput : TFilename) : TFilename;
const
  FSReservedName : array [1..6] of string = ('CON','COM','LPT','NUL','PRN','AUX');
var
  IndexWord : integer;
begin
  // Set result to same value
  Result := fileInput;
  // Limit test to string with no more than 4 characters
  if (Length(fileInput)>4) or (Length(fileInput)<3) then exit;
  for IndexWord := low(FSReservedName) to high(FSReservedName) do
  begin
    if(SameText(LeftStr(fileInput,3),FSReservedName[IndexWord] )) then
    begin
      Result := '_' + Result;
      exit;
    end;
  end;
end;

{*------------------------------------------------------------------------------
  Get the filename of this component
  @return Validated filename
 ------------------------------------------------------------------------------}
function TDOCTemplate.GetFileName: string;
begin
  Result:=ConvertToValidFilename(FName);
end;

{*------------------------------------------------------------------------------
  Build a base filename with all parent's name separated with underscore
  It is mainly used to produce the output filename of this item's documentation.
  @return parent's name concatenation separated with underscore
-------------------------------------------------------------------------------}
function TDOCTemplate.BuildPathName: string;
var
  tmpDT: TDocTemplate;
begin
  Result := GetFileName;
  tmpDT  := self;
  while tmpDT.FRelatedParent <> nil do
  begin
    tmpDT := tmpDT.FRelatedParent;
    insert(tmpDT.GetFileName + PathDelim {'_'}, Result, 1);
  end;
end;

{*------------------------------------------------------------------------------
  Build a base filename with last parent's name separated with underscore
  It is mainly used to produce link between items in documentation.
  @return Last parent's name concatenation separated with path separator
-------------------------------------------------------------------------------}
function TDOCTemplate.BuildRelativePathName: string;
var
  tmpDT: TDocTemplate;
begin
  Result := GetFileName;
  tmpDT  := self;
  if tmpDT.FRelatedParent <> nil then
  begin
    tmpDT := tmpDT.FRelatedParent;
    insert(tmpDT.GetFileName + '/' , Result, 1);
  end;
end;

{*------------------------------------------------------------------------------
  Call Create to instantiate a TDOCTemplate object at runtime.
  Create allocates memory, and then initializes its properties.
  Generaly, The owner of this item call create and add the reference in a list
  @param  st  Name of the new item (mainly its identifier)
  @param  rp  Related logical parent and owner
-------------------------------------------------------------------------------}
constructor TDOCTemplate.Create(const st: string; const rp: TDocTemplate);
begin
  inherited Create;
  FName      := st;
  BodySource := '';
  Links      := TDOCLinkList.Create(False); // links are independants
  FRelatedParent := rp;
  Hidden := False;
  FTemplateListList := TObjectList.Create(False);
  FTAGHolderList := TTAGHolderList.Create(True);
  FTagCoverageHolder := TTagCoverageHolder.Create;
end;

{*------------------------------------------------------------------------------
  Create a TDocTemplate list from factory and add it to the list of this object.
  @param  DocListClass  Class of the list to create
  @return  CReated object with parameter sub-class
-------------------------------------------------------------------------------}
function TDOCTemplate.CreateDocTemplateList(
  const DocListClass: TDOCTemplateListClass): TDOCTemplateList;
begin
  // Create List
  Result := DocListClass.Create(True);
  // Add list to list of TemplateList
  FTemplateListList.Add(Result);
end;

/// Check if template item is required in the output documentation.
function TDOCTemplate.CategoryType: TOutputCategoryList;
begin
  // Just here for override !
  Exception.Create('Should never be called directly!');
  Result:=ocClasses;
end;

{*------------------------------------------------------------------------------
  Check if imperative TAGs are documented.
  @param  DocTag  TAG type to verify
  @param  subID  sub-ID of the item to check (used when Template hold tag for
   other components)
-------------------------------------------------------------------------------}
procedure TDOCTemplate.CheckTagCoverage(const DocTag: TDOCTag; const subID: string = '');
var
  bIsTagExist : Boolean;
begin
  // Verify of TAG is documented
  bIsTagExist := FTAGHolderList.ExistContentByDocTag(DocTag, subID);
  FTagCoverageHolder.AddEvaluation(DocTag, bIsTagExist, subID);
end;

///  Destroys an instance of a TDOCTemplate object
destructor TDOCTemplate.Destroy;
begin
  FreeAndNil(FTagCoverageHolder);
  FreeAndNil(FTemplateListList);
  FreeAndNil(FTAGHolderList);
  FreeAndNil(Links);
  FRelatedParent := nil;
  inherited;
end;

/// Evaluate if the item should be displayed
function TDOCTemplate.DoEvaluateDisplay: Boolean;
begin
  if assigned(FOnGetEvaluateDisplay) then Result := FOnGetEvaluateDisplay
   else Result := True;
end;

{*------------------------------------------------------------------------------
  Return the name of the parent (owner)
  If no parent is assigned, then return the specified value '#NO-PARENT#'
  @return Parent and owner's item
-------------------------------------------------------------------------------}
function TDOCTemplate.GetParentName: string;
begin
  if FRelatedParent <> nil then
   Result := FRelatedParent.Name
  else
    Result := '#NO-PARENT#';
end;


{*------------------------------------------------------------------------------
  Return the name of this template
  @return Template's name
-------------------------------------------------------------------------------}
function TDOCTemplate.GetTemplateName: string;
begin
  Result := '#Unused DocTemplate#';
end;


{*------------------------------------------------------------------------------
  Update the TAG coverage statistics
  For the TDocTemplate generic class, only description of the item is needed.
  This method should be overriden for each other component that need another
   TAG to be describe.
-------------------------------------------------------------------------------}
procedure TDOCTemplate.UpdateTagCoverage;
begin
  // At least, a DocTemplate must have a Description TAG
  CheckTagCoverage(dtDescriptionTAG);  //dtDescriptionTAG
end;

{ TDOCTemplateList }

{*------------------------------------------------------------------------------
  Create a TDOCTemplate based object and add it to this list
  @param aname   Name of new item
  @param DocParent   Parent of the item
  @param DocClass   TDOCTemplate sub-class
  @return TDOCTemplate   The new component (DocTemplate) created
------------------------------------------------------------------------------*}
function TDOCTemplateList.New(const aname: string; const DocParent: TDOCTemplate;
    const DocClass:TDOCTemplateClass): TDOCTemplate;
begin
  Result:= DocClass.Create(aname,DocParent);
  Add(Result);
end;

{*------------------------------------------------------------------------------
  Find a TDOCTemplate reference in the list by its name
  @param  st Name of the item to find
  @return Item reference if successfull, nil otherwise
-------------------------------------------------------------------------------}
function TDOCTemplateList.FindItemByName(const st: string): TDOCTemplate;
var
  Tmp:   TDOCTemplate;
  Index: integer;
begin
  Result := nil;
  Index  := 1;
  while ((Index <= Count) and (Result = nil)) do
  begin
    Tmp := Items[Index - 1];
    if Assigned(Tmp) then
    begin
      //if Tmp.FName = st then
      if SameText(Tmp.FName,st) then
      begin
        Result := Tmp
      end
    end;
    Inc(Index);
  end;
end;

{*------------------------------------------------------------------------------
  Find a TDOCTemplate reference in the list by its name
  @param  st Name of the item to find
  @return Item reference if successfull, nil otherwise
-------------------------------------------------------------------------------}
function TDOCTemplateList.FindNextItemByName(const st: string; ItemStart:TDOCTemplate): TDOCTemplate;
var
  Tmp:   TDOCTemplate;
  Index: integer;
begin
  Result := nil;
  // Exit if no members
  if Count<1 then exit;
  // Start from StartItem parameter of First item
  if ItemStart=nil then tmp:=self.First as TDOCTemplate
  else tmp:=self.NextItem(ItemStart);
  if tmp=nil then exit;

  Index  := self.IndexOf(tmp)+1;
  while ((Index <= Count) and (Result = nil)) do
  begin
    Tmp := Items[Index - 1];
    if Assigned(Tmp) then
      if SameText(Tmp.FName,st) then Result := Tmp;
    Inc(Index);
  end;
end;

{*------------------------------------------------------------------------------
  Get the reference of the DocTemplate specified by its index in the Items List
  @param  index Index in the DocTemplate List
  @return DocTemplate reference if successfull, nil otherwise
-------------------------------------------------------------------------------}
function TDOCTemplateList.GetItem(const Index: integer): TDOCTemplate;
begin
  Result := inherited GetItem(Index) as TDOCTemplate;
end;

{*------------------------------------------------------------------------------
  Get the next DocTemplate item in the DocTemplate List
  @param  Item  Base item to find the next one
  @return DocTemplate Next item reference if successfull, nil otherwise
-------------------------------------------------------------------------------}
function TDOCTemplateList.NextItem(const Item: TDOCTemplate): TDOCTemplate;
var
  Index: integer;
begin
  Index := IndexOf(Item);
  if Index < (Count - 1) then
  begin
    Result := Items[Index + 1]
  end
  else begin
    Result := nil
  end;
end;

{*------------------------------------------------------------------------------
  Get the previous DocTemplate item in the DocTemplate List
  @param  Item  Base item to find the previous one
  @return DocTemplate Previous item reference if successfull, nil otherwise
-------------------------------------------------------------------------------}
function TDOCTemplateList.PrevItem(const Item: TDOCTemplate): TDOCTemplate;
var
  Index: integer;
begin
  Index := IndexOf(Item);
  if Index > 0 then
  begin
    Result := Items[Index - 1]
  end
  else begin
    Result := nil
  end;
end;

{*------------------------------------------------------------------------------
  Set the reference of the DocTemplate specified by its index in the Items List
  @param  index Index in the DocTemplate List
  @param  item  reference of the TDOCTemplate to set
-------------------------------------------------------------------------------}
procedure TDOCTemplateList.SetItem(const Index: integer; const item: TDOCTemplate);
begin
  inherited SetItem(index, item as TObject);
end;

{*------------------------------------------------------------------------------
  Call Create to instantiate a TDOCLink object at runtime.
  Create allocates memory, and then initializes its properties.
  Generally, The owner of this item call create and add the reference in a list
  @param  ln  Name of the new Link (mainly its identifier)
-------------------------------------------------------------------------------}
constructor TDOCLink.Create(const ln: string);
begin
  Name := ln;
  Link := nil;
end;



end.
