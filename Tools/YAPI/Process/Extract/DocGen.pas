{*------------------------------------------------------------------------------
  Base of all Generator
  The Generator component build a formatted file with the data from the
  extractor. All Generator will descend from the TDOCGenerator describe in this
  unit.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   v0.0     Initial revision
  @Todo      Rewrite the TDocGenerator class with a Visitor pattern !
-------------------------------------------------------------------------------}

unit DocGen;

interface

uses Windows, SysUtils, Classes, Contnrs, Structure, uOptions, uDocTemplate,
     uDocMember, uDocClass, uDocUnit, uDocClassTree;

type
  /// Generic documentation generator class
  TDOCGenerator = class
  protected
    PreviousItem: TDOCTemplate; /// Previous Item already generated
    NextItem: TDOCTemplate; /// Next Item that will be generated
    FileStructure: TDOCStructure; /// The project Structure - Shared object !

    procedure WritePageHeader(const DocItem: TDOCTemplate); virtual; abstract;
    procedure WritePageFooter; virtual; abstract;
    procedure WriteLegend; virtual; abstract;
    procedure WriteProjectSection(const DocStructure: TDOCStructure); virtual; abstract;
    procedure WriteUnitSection(const DocUnit: TDOCUnit); virtual; abstract;
    procedure WriteClassSection(const DocClass: TDOCClass); virtual; abstract;
    procedure WriteMemberSection(const DocMember: TDOCMember); virtual; abstract;
    procedure WriteVTFCSection(const DocVTFC: TDOCTemplate); virtual; abstract;
    procedure WriteBlankSection; virtual; abstract;
    procedure WriteClassHierarchy(const ClassHierarchy: TDOCClassesTree); virtual; abstract;
    procedure BeforeBuild(const DocItem: TDOCTemplate); virtual; abstract;
    procedure AfterBuild(const DocItem: TDOCTemplate); virtual; abstract;
    procedure AddLine(const st: string); virtual; abstract;
  private
    FDocOptions: TDOCOptions; /// Project's Options - Shared Component !
    FMessageStrings: TStrings;  /// Message holder
    procedure BuildProjectView;
    procedure BuildClassHierarchyView;
    procedure BuildUnitsView;
    procedure BuildVTFCView(const VTFCPartialList: TDOCTemplateList);
    procedure BuildClassesView(const ClassPartialList: TDOCTemplateList);
    procedure BuildClassMembersView(const DocClass : TDOCClass);
    procedure WriteCopyrightSection;
    procedure BuildMembersView(const MemberPartialList: TDOCTemplateList);
  public
    property DocOptions: TDOCOptions Read FDocOptions Write FDocOptions;
    property MessageStrings: TStrings Read FMessageStrings Write FMessageStrings;
    function Execute(const ds: TDOCStructure): TDOCError; virtual;
    function VerifyCondition(out ErrorMessage: string): boolean;virtual;
    procedure SendStatusMessage(const stMessage: string);
    function FindNextMember(const PartialMemberList: TDOCTemplateList;
     const IndexMember:Integer):TDOCMember;
    function FindPreviousMember(const PartialMemberList: TDOCTemplateList;
     const IndexMember:Integer):TDOCMember;
    function GetOutputFile : TFileName; virtual; abstract;
    function EvaluateItemDisplay(const DocItem : TDOCTemplate) : Boolean;
  end;

implementation

resourcestring
  rsGeneratingUnit = 'Generating Unit : %s';

{ TDOCGenerator }

{*------------------------------------------------------------------------------
  Build the project view
  This will write the page Header, the project section, the page footer and then
   add the copyright.
 ------------------------------------------------------------------------------}
procedure TDOCGenerator.BuildProjectView;
begin
  BeforeBuild(FileStructure);
  WritePageHeader(FileStructure);
  PreviousItem := nil;
  NextItem     := nil;
  WriteProjectSection(FileStructure);
  WritePageFooter;
  WriteCopyrightSection;
  AfterBuild(FileStructure);
end;

{*------------------------------------------------------------------------------
  Build the units view
  This will write, for all the units, the page Header, the unit section, the
   page footer and then add the copyright.
 ------------------------------------------------------------------------------}
procedure TDOCGenerator.BuildUnitsView;
var
  IndexUnit: integer;
  tmpUnit:   TDOCUnit;
begin
  for IndexUnit := 0 to FileStructure.UnitList.Count - 1 do
  begin
    tmpUnit := FileStructure.UnitList[IndexUnit] as TDOCUnit;
    if IndexUnit < (FileStructure.UnitList.Count - 1) then
    begin
      NextItem := FileStructure.UnitList[IndexUnit + 1]
    end
    else begin
      NextItem := nil
    end;
    if IndexUnit > 0 then
    begin
      PreviousItem := FileStructure.UnitList[IndexUnit - 1]
    end
    else begin
      PreviousItem := nil
    end;
    BeforeBuild(tmpUnit);
    WritePageHeader(tmpUnit);
    WriteUnitSection(tmpUnit);
    WritePageFooter;
    WriteCopyrightSection;
    AfterBuild(tmpUnit);
  end;
end;

{*------------------------------------------------------------------------------
  Build the classes view
  This will write the page Header, the class section, the page footer and then
   add the copyright.
 ------------------------------------------------------------------------------}
procedure TDOCGenerator.BuildClassesView(const ClassPartialList: TDOCTemplateList);
var
  IndexClass: integer;
  tmpClass:   TDOCClass;
begin
  BuildMembersView(ClassPartialList);
  for IndexClass := 0 to ClassPartialList.Count - 1 do
  begin
    tmpClass := ClassPartialList.Items[IndexClass] as TDOCClass;
    BuildClassMembersView(tmpClass);
  end;
end;

{*------------------------------------------------------------------------------
  Find Next Member in the Class corresponding with Filter options (visiblity)
  @param ParentClass  The member's class where to find next item
  @param IndexMember The actual index of member in the class members list
  @return   TDOCMember if succesfull found, NIL otherwise
-------------------------------------------------------------------------------}
function TDOCGenerator.FindNextMember(const PartialMemberList: TDOCTemplateList;
 const IndexMember:Integer):TDOCMember;
var
  IndexNextMember: integer;
  tmpDocMember : TDOCMember;
begin
  IndexNextMember:= IndexMember+1;
  Result:=nil;
  while (IndexNextMember < PartialMemberList.Count) and (Result=nil) do
  begin
    tmpDocMember := PartialMemberList.Items[IndexNextMember] as TDOCMember;
    if EvaluateItemDisplay(tmpDocMember) then
      Result := PartialMemberList.Items[IndexNextMember] as TDocMember;
    Inc(IndexNextMember);
  end;
end;

{*------------------------------------------------------------------------------
  Find Previous Member in the Class corresponding with Filter options (visiblity)
  @param ParentClass  The member's class where to find next item
  @param IndexMember The actual index of member in the class members list
  @return   TDOCMember if succesfull found, NIL otherwise
-------------------------------------------------------------------------------}
function TDOCGenerator.FindPreviousMember(const PartialMemberList: TDOCTemplateList;
 const IndexMember:Integer):TDOCMember;
var
  IndexPreviousMember: integer;
  tmpDocMember : TDOCMember;
begin
  IndexPreviousMember:= IndexMember-1;
  Result:=nil;
  while (IndexPreviousMember >=0 ) and (Result=nil) do
  begin
    tmpDocMember := PartialMemberList.Items[IndexPreviousMember] as TDOCMember;
    if EvaluateItemDisplay(tmpDocMember) then
     Result := PartialMemberList.Items[IndexPreviousMember] as TDocMember;
    Dec(IndexPreviousMember);
  end;
end;

{*------------------------------------------------------------------------------
  Build the members view
  This will write the page Header, the member section, the page footer and then
   add the copyright.
 ------------------------------------------------------------------------------}
procedure TDOCGenerator.BuildMembersView(const MemberPartialList: TDOCTemplateList);
var
  IndexMember: integer;
  tmpMember:   TDOCMember;
begin
  assert(assigned(MemberPartialList));
  for IndexMember := 0 to MemberPartialList.count - 1 do
  begin
    tmpMember := MemberPartialList.Items[IndexMember] as TDOCMember;
    {if tmpMember.CategoryType in DocOptions.OutputFilteringCategory then
    // Filter member by visibility option
    if (tmpMember.MemberVisibility in DocOptions.VisibilitySet)
     and not (not DocOptions.DisplayHiddenItems and tmpMember.Hidden) then}
    if EvaluateItemDisplay(tmpMember) then
    begin
      NextItem:=FindNextMember(MemberPartialList,IndexMember);
      PreviousItem := FindPreviousMember(MemberPartialList, IndexMember);
      BeforeBuild(tmpMember);
      WritePageHeader(tmpMember);
      {#Trident# GENERATE An Exception!!! }
      if tmpMember is TDocClass then
      begin
        WriteClassSection(tmpMember as TDOCClass);
      end
      else WriteMemberSection(tmpMember);
      WritePageFooter;
      WriteCopyrightSection;
      AfterBuild(tmpMember);
    end;
  end;
end;

{*------------------------------------------------------------------------------
  Execute the generator by building the documentation
  The generator will build all the view (projects, units, classes, members ...)
   considering the overloaded methods for the different type of output.
  @param  ds  TDOCStructure project
  @return     TDOCError, 0 if succesfull (for the moment, always return 0)
-------------------------------------------------------------------------------}
function TDOCGenerator.EvaluateItemDisplay(const DocItem: TDOCTemplate): Boolean;
begin
  Result := (DocItem.CategoryType in DocOptions.OutputFilteringCategory)
   and not (not DocOptions.DisplayHiddenItems and DocItem.Hidden);
  if DocItem is TDocMember then
  begin
    // Filter member by visibility option
    Result := Result and ((DocItem as TDocMember).MemberVisibility in DocOptions.VisibilitySet);
  end;
end;

function TDOCGenerator.Execute(const ds: TDOCStructure): TDOCError;
var
  tmpUnit: TDOCUnit;
  IndexUnit: integer;
begin
  assert(assigned(ds));
  assert(assigned(DocOptions));
  // Build output directory if not exists
  if not DirectoryExists(DocOptions.EffectiveOutputFolder) then
   ForceDirectories(DocOptions.EffectiveOutputFolder);
  FileStructure := ds;
  BuildProjectView;
  BuildClassHierarchyView;
  BuildUnitsView;
  for IndexUnit := 0 to FileStructure.UnitList.Count - 1 do
  begin
    tmpUnit := FileStructure.UnitList[IndexUnit] as TDOCUnit;
    Assert(assigned(tmpUnit));
    // Send Debug Message
    // Must change language BEFORE the Format function !!!
    SendStatusMessage(Format(rsGeneratingUnit, [tmpUnit.Name]));
    
    BuildVTFCView(tmpUnit.ConstantList);
    BuildVTFCView(tmpUnit.TypeList);
    BuildVTFCView(tmpUnit.VarList);
    BuildVTFCView(tmpUnit.FunctionList);
    BuildClassesView(tmpUnit.ClassList);
  end;
  Result := 0;
end;

{*------------------------------------------------------------------------------
  Write the copyright section
  Not used for the moment, always overloaded by different output classes
-------------------------------------------------------------------------------}
procedure TDOCGenerator.WriteCopyrightSection;
begin
  //AddLine('-------------------------');
  //AddLine('Copyright 2003 - TridenT ');
end;


{*------------------------------------------------------------------------------
  Build the Variables, Types, Functions and Constants (VTFC) view
  This will write the page Header, the VTCF section, the page footer and then
   add the copyright.
-------------------------------------------------------------------------------}
procedure TDOCGenerator.BuildVTFCView(const VTFCPartialList: TDOCTemplateList);
var
  IndexVTFC: integer;
  tmpVTFC:   TDOCTemplate;
begin
  for IndexVTFC := 0 to VTFCPartialList.Count - 1 do
  begin
    tmpVTFC := VTFCPartialList.Items[IndexVTFC];
    // Filter unattended items
    if EvaluateItemDisplay(tmpVTFC) then
    begin
      // Update next and previous item
      NextItem:=FindNextMember(VTFCPartialList,IndexVTFC);
      PreviousItem := FindPreviousMember(VTFCPartialList, IndexVTFC);
      BeforeBuild(tmpVTFC);
      WritePageHeader(tmpVTFC);
      WriteVTFCSection(tmpVTFC);
      WritePageFooter;
      WriteCopyrightSection;
      AfterBuild(tmpVTFC);
    end;
  end;
end;

{*------------------------------------------------------------------------------
  Send a message reflecting the status of the operations in progress
  @param    stMessage  string to display
-------------------------------------------------------------------------------}
procedure TDOCGenerator.SendStatusMessage(const stMessage: string);
begin
  if assigned(FMessageStrings) then
  begin
    //gnuGetText.UseLanguage(DocOptions.ApplicationLanguage);
    FMessageStrings.Add(stMessage);
    //gnuGetText.UseLanguage(DocOptions.GeneratorLanguage);
  end;
end;

{*------------------------------------------------------------------------------
  Verify initial conditions before building the project
  @param    ErrorMessage  string with error message if any
  @return   TRUE if confition OK, FALSE otherwise, see ErrorMessage string
-------------------------------------------------------------------------------}
function TDOCGenerator.VerifyCondition(out ErrorMessage: string): boolean;
begin
  Result:=true;
  ErrorMessage:='';
end;

procedure TDOCGenerator.BuildClassHierarchyView;
begin
  BeforeBuild(FileStructure.ClassTree);
  WritePageHeader(FileStructure.ClassTree);
  PreviousItem := nil;
  NextItem     := nil;
  WriteClassHierarchy(FileStructure.ClassTree);
  WritePageFooter;
  WriteCopyrightSection;
  AfterBuild(FileStructure.ClassTree);
end;

procedure TDOCGenerator.BuildClassMembersView(const DocClass: TDOCClass);
begin
  BuildMembersView(DocClass.FieldList);
  BuildMembersView(DocClass.PropertyList);
  BuildMembersView(DocClass.MethodList);
  BuildMembersView(DocClass.EventList);
  BuildMembersView(DocClass.VarList);
  BuildMembersView(DocClass.ConstantList);
  // Build nested Class
  BuildClassesView(DocClass.ClassList);
  // Inserted below! BuildMembersView(DocClass.ClassList);
end;

end.
