{*------------------------------------------------------------------------------
  Create the structure of source code component from the result of the Parser
  All tools used by the Builder are in this unit.
  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   v0.0     Initial revision
-------------------------------------------------------------------------------}

unit Structure;

interface

uses Windows, SysUtils, Classes, Contnrs, uOptions, TAGComment,
  uDocTemplate, uDocMember, uDocProgram, uDocClassTree;

type
  /// Error result for the application
  TDOCError      = integer;

  /// Specialized TDOCTemplate class for the whole structure itself
  TDOCStructure = class(TDOCTemplate)
  private
    Units: TDOCUnitList;      /// List of all units in the structure
    FDOCOptions: TDOCOptions; /// All Options. Beware! Shared Component.
    FProgram: TDOCProgram;    /// Program (DPR file) associate with structure (also a unit)
    FClassTree : TDOCClassesTree; /// All classes in a tree
  public
    property UnitList: TDOCUnitList read Units write Units;
    property DocOptions: TDOCOptions Read FDOCOptions Write FDOCOptions;
    property ClassTree: TDOCClassesTree Read FClassTree Write FClassTree;
    constructor Create(const st: string; const rp: TDocTemplate); override;
    destructor Destroy; override;
    procedure SetProgram(const DocProgram:TDOCProgram);
    function GetProgram: TDOCTemplate;
    procedure UpdateAllTagCoverage;
    procedure SortContent;
    procedure Clear;
    function GetTemplateName : string; override;
    //procedure FillTagDetail(const ATreeNode : TTreeNode; const ATextEdit : TObject);
  end;



implementation

uses
  JclImports,
  uDocUnit, uDocClass, uDocToNodesVisitor, uDocTagCoverageVisitor, uDocSortVisitor,
  uDocTagCoverage;

{*------------------------------------------------------------------------------
  Link the Program (Delphi DPR) to the structure.
  @param  DocProgram TDOCProgram to link to the current structure
-------------------------------------------------------------------------------}
procedure TDOCStructure.SetProgram(const DocProgram:TDOCProgram);
begin
  if assigned(FProgram) then raise Exception.Create('Program already exists')
  else
  begin
    FProgram := DocProgram;
  end;
end;

{*------------------------------------------------------------------------------
  Return the linked Program (Delphi DPR)
  @result  TDOCProgram linked to the current structure
-------------------------------------------------------------------------------}
function TDOCStructure.GetProgram: TDOCTemplate;
begin
  result:=FProgram;
end;

function TDOCStructure.GetTemplateName: string;
begin
  Result := 'Project Structure';
end;

/// Clear all units from the structure
procedure TDOCStructure.Clear;
begin
  Units.Clear;
  ClassTree.Clear;
  // FProgram was freed before as unit !
  FProgram := nil;
end;


{*------------------------------------------------------------------------------
  Call Create to instantiate a TDOCStructure object at runtime.
  Create allocates memory, and then initializes its properties.
  Generally, there is only one reference per application.
  @param  st  Name of the new Strcutre (mainly its identifier)
  @param  rp  Related logical parent and owner, generally a null value !
-------------------------------------------------------------------------------}
constructor TDOCStructure.Create(const st: string; const rp: TDocTemplate);
begin
  inherited;
  Name := 'Project1';
  Units := CreateDocTemplateList(TDOCUnitList);
  FProgram:=nil;
  FClassTree := TDOCClassesTree.Create('_ClassHierarchy',nil);
end;

///  Destroys of an instance of a TDOCStructure object and free its content
destructor TDOCStructure.Destroy;
begin
  FreeAndNil(Units);
  FreeAndNil(FClassTree);
  inherited;
end;

(*
procedure TDOCStructure.FillTagDetail(const ATreeNode : TTreeNode; const ATextEdit : TObject);
const
  ST_TAGS_STATISTICS : string = '  Checked [%d],  Documented [%d],  Missing [%d]' + AnsiLineBreak;
  ST_TAG_DETAIL : string = 'TAG [%s] : %s' + AnsiLineBreak;
  ST_TAG_VERIFY_RESULT : array [False..True] of string = ('Missing','Documented');
var
  JvRichEdit : TJvRichEdit;
  DocTemplate : TDOCTemplate;
  CheckedTagItem : TCheckedTagItem;
  Stats : TTagCoverageItem;
  IndexCheckedTag : Integer;
  TagCaption : string;
  //CurrentFont : TFont;
  CurrentColor : TColor;
begin
  if ATextEdit is TJvRichEdit then
  begin
    DocTemplate := TDOCTemplate(ATreeNode.Data);
    JvRichEdit := ATextEdit as TJvRichEdit;
    JvRichEdit.Clear;
    // Add Template name and name of selected item
    JvRichEdit.AddFormatText(DocTemplate.GetTemplateName + ' : ' + DocTemplate.Name
     + AnsiLineBreak, [fsBold]);
    // Display Total statistics
    JvRichEdit.AddFormatText('Total TAGs:',[fsUnderline]);
    Stats := DocTemplate.TagCoverageHolder.TotalStats;
    JvRichEdit.AddFormatText(Format(ST_TAGS_STATISTICS,[Stats.EvaluatedCount,
     Stats.DocumentedCount, Stats.EvaluatedCount - Stats.DocumentedCount]),[]);
    // Display Childs statistics
    JvRichEdit.AddFormatText('Childs TAGs:',[fsUnderline]);
    Stats := DocTemplate.TagCoverageHolder.ChildsStats;
    JvRichEdit.AddFormatText(Format(ST_TAGS_STATISTICS,[Stats.EvaluatedCount,
     Stats.DocumentedCount, Stats.EvaluatedCount - Stats.DocumentedCount]),[]);
    // Display its TAG statistics
    Stats := DocTemplate.TagCoverageHolder.SelfStats;
    JvRichEdit.AddFormatText('Self TAGs:',[fsUnderline]);
    JvRichEdit.AddFormatText(Format(ST_TAGS_STATISTICS,[Stats.EvaluatedCount,
     Stats.DocumentedCount, Stats.EvaluatedCount - Stats.DocumentedCount]),[]);
    // Display each tag with result
    for IndexCheckedTag := 0 to DocTemplate.TagCoverageHolder.CheckedTagList.Count - 1 do
    begin
      CheckedTagItem := DocTemplate.TagCoverageHolder.CheckedTagList.Items[IndexCheckedTag] as TCheckedTagItem;
      TagCaption := TAGPatternList.FindItemByDocTag(CheckedTagItem.DocTag).SourceCode;
      if(CheckedTagItem.subID <> '') then
       TagCaption := TagCaption + ' ' + CheckedTagItem.subID;
      if(CheckedTagItem.bIsDocumented = False) then CurrentColor := clRed
       else CurrentColor := clBlue;
      JvRichEdit.AddFormatText(Format(ST_TAG_DETAIL,[TagCaption,
        ST_TAG_VERIFY_RESULT[CheckedTagItem.bIsDocumented]]),[], '',CurrentColor,0);
    end;
  end;
end;
 *)
/// Sort all DocTemplate element of lists in alphabetical order
procedure TDOCStructure.SortContent;
var
  DocSortVisitor : TDOCSortVisitor;
begin
  DocSortVisitor := TDOCSortVisitor.Create;
  DocSortVisitor.Visit(self);
  FreeAndNil(DocSortVisitor);
end;

procedure TDOCStructure.UpdateAllTagCoverage;
var
  DocVisitor : TDOCTagCoverageVisitor;
begin
  //
  DocVisitor := TDOCTagCoverageVisitor.Create;
  try
    DocVisitor.Visit(Self);
  finally
    FreeAndNil(DocVisitor);
  end;
end;

end.
