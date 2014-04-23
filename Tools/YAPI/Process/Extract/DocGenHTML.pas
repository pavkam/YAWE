{*------------------------------------------------------------------------------
  HTML Generator
  It provides all classes and functions to build HTML files from the structure
   builder.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   v0.0     Initial revision
  @TODO      Link must be built by the HTMLGenerator and not the HTML canvas
-------------------------------------------------------------------------------}


unit DocGenHTML;

interface

uses Windows, SysUtils, Classes, Contnrs, Structure, DocGen, Tokens
  , uDocTemplate, uDocMember, uDocMethod, uDocClass, uDocUnit, uDocClassTree, uDocProgram;

type
  /// HTML output generator
  TDOCGenHTML = class(TDOCGenerator)
  private
    FGenHTML: TStringList; /// Output writer component
    FHtmlOutputFolder : TFileName; /// Output folder to store HTML page
    FCSSFilename: TFilename;
    function GetHTMLMemberVisibility(dm: TDOCTemplate): string;
    function GetHTMLMemberVisibilityClass(dm: TDOCTemplate): string;
    function GetHTMLIndex(const DocItem: TDOCTemplate): string;
    function GetClassTree(const DocItem: TDOCTemplate): string;
    procedure AddToolBar(const DocItem: TDOCTemplate);
    function GetRelativePathToParent(const DocItem: TDOCTemplate) : string;
    function GetRelativePathToItem(const DocItem, DocLink: TDOCTemplate): string;
    procedure IterateClassNode(const CurrentClassNodeNode : TDOCClassNode);

    procedure WriteSeeLinks(DocMember : TDOCTemplate);
    procedure WriteComponentTable(const DocStructure: TDOCStructure; const Title, ComponentName : String); overload;
    procedure WriteComponentTable(const DocStructure: TDOCStructure; const Title, ComponentName : String; ExcludeNames: array of String); overload;
  protected
    procedure WritePageHeader(const DocItem: TDOCTemplate); override;
    procedure WritePageFooter; override;
    procedure WriteLegend; override;
    procedure WriteProjectSection(const DocStructure: TDOCStructure); override;
    procedure WriteClassHierarchy(const ClassHierarchy: TDOCClassesTree); override;
    procedure WriteUnitSection(const DocUnit: TDOCUnit); override;
    procedure WriteClassSection(const DocClass: TDOCClass); override;
    procedure WriteMemberSection(const DocMember: TDOCMember); override;
    procedure WriteVTFCSection(const DocVTFC: TDOCTemplate); override;
    procedure WriteBlankSection; override;
    procedure BeforeBuild(const DocItem: TDOCTemplate); override;
    procedure AfterBuild(const DocItem: TDOCTemplate); override;
    procedure AddLine(const st: string); override;
    procedure WriteTAGSection(const TAGType: TCommentStyle;
      const DocItem: TDOCTemplate; const SectionName: string);
    procedure WriteSimpleTAGSection(const TAGType: TCommentStyle;
      const DocItem: TDOCTemplate; const SectionName: string);
    procedure WriteReturnTAGSection(const DOCMethod: TDOCMethod);
    procedure WriteMemberVisibilityText(const DocMember: TDOCMember);
  public
    function Execute(const ds: TDOCStructure): TDOCError; override;
    function GetOutputFile : TFileName; override; 
  end;

implementation

uses
  JclImports,
  DocGenHTML_Common, uOptions, uDocFunction, uDocProperty, uDocLibrary;

{ TDOCGenHTML }

{*------------------------------------------------------------------------------
  Add a line to the output
  Since every output type have a different way to write the output, the AddLine
  method is overloaded.
  It simply add the HTML in the stream.
  @param  st  String to add to the stream
-------------------------------------------------------------------------------}
procedure TDOCGenHTML.AddLine(const st: string);
begin
  FGenHTML.Add(st);
end;

///  Add the toolbar to the HTML page
procedure TDOCGenHTML.AddToolBar(const DocItem: TDOCTemplate);
var
  PrevLink, NextLink: string;
begin
  if assigned(PreviousItem) then
  begin
    PrevLink := HTMLBuildLink(Format('%s (%s)', [L_Previous, PreviousItem.Name]),
      PreviousItem.GetFileName)
  end
  else begin
    PrevLink := L_Previous
  end;
  if assigned(NextItem) then
  begin
    NextLink := HTMLBuildLink(Format('%s (%s)', [L_Next, NextItem.Name]), NextItem.GetFileName)
  end
  else begin
    NextLink := L_Next
  end;

  AddLine(HTMLGenToolbar(FileStructure.BuildPathName, GetClassTree(DocItem),
    GetHTMLIndex(DocItem), PrevLink, NextLink));
end;

{*------------------------------------------------------------------------------
  Save HTML stream since the build is done
  @param  DocItem  TDOCTemplate to save
-------------------------------------------------------------------------------}
procedure TDOCGenHTML.AfterBuild(const DocItem: TDOCTemplate);
var
  HTMLFileName: TFilename;
begin
  // Close HTMLFile
  HTMLFileName:=FHtmlOutputFolder + DocItem.BuildPathName + HTML_FILE_EXT;
  try
    ForceDirectories(ExtractFilepath(HTMLFileName));
    FGenHTML.SaveToFile(HTMLFileName);
  finally
    FreeAndNil(FGenHTML);
  end;
end;

{*------------------------------------------------------------------------------
  Create the HTML stream before building
  @param  DocItem  TDOCTemplate that will be created
-------------------------------------------------------------------------------}
procedure TDOCGenHTML.BeforeBuild(const DocItem: TDOCTemplate);
begin
  // Create TextFile
  FGenHTML := TStringList.Create;
end;

{*------------------------------------------------------------------------------
  Execute the HTML generator by building the documentation
  The generator will build all the view (projects, units, classes, members ...)
   considering the overloaded methods for the different type of output.
  It will also build the CSS file
  @param  ds  TDOCStructure project
  @return     TDOCError, 0 if succesfull (for the moment, always return 0)
-------------------------------------------------------------------------------}
function TDOCGenHTML.Execute(const ds: TDOCStructure): TDOCError;
var
  CSSFile: TStringList;
begin
  FHtmlOutputFolder:=DocOptions.EffectiveOutputFolder+'html'+PathDelim;
  // Build 'html' output directory if not exists
  if not DirectoryExists(FHtmlOutputFolder) then
   ForceDirectories(FHtmlOutputFolder);

  CSSFile := TStringList.Create;
  CSSFile.Add(HTMLGenCSS);
  try
    FCSSFilename := FHtmlOutputFolder + CSS_BASE_FILENAME + CSS_FILE_EXT;
    CSSFile.SaveToFile(FCSSFilename);
  finally
    FreeAndNil(CSSFile);
  end;

  Result := inherited Execute(ds);
end;

{*------------------------------------------------------------------------------
  Build the Index documentation section
  @return     String containing the HTML section of Index
-------------------------------------------------------------------------------}
function TDOCGenHTML.GetHTMLIndex(const DocItem: TDOCTemplate): string;
var
  RelativeIndexFile: TFilename;
begin
  RelativeIndexFile:=PathGetRelativePath(ExtractFilePath(
   FHtmlOutputFolder + DocItem.BuildPathName + HTML_FILE_EXT)
   ,FHtmlOutputFolder)+PathDelim+FileStructure.BuildPathName;
  Result := HTMLBuildLink(L_Index, RelativeIndexFile);
end;

{*------------------------------------------------------------------------------
  Build the Index documentation section
  @return     String containing the HTML section of Index
-------------------------------------------------------------------------------}
function TDOCGenHTML.GetClassTree(const DocItem: TDOCTemplate): string;
var
  RelativeIndexFile: TFilename;
begin
  RelativeIndexFile:=PathGetRelativePath(ExtractFilePath(
   FHtmlOutputFolder + DocItem.BuildPathName + HTML_FILE_EXT)
   ,FHtmlOutputFolder)+PathDelim+FileStructure.ClassTree.BuildPathName;
  Result := HTMLBuildLink(L_ClassTree, RelativeIndexFile);
end;

{*------------------------------------------------------------------------------
  Build the HTML member visibility symbols
  @param  dm  TDOCTemplate to take visiblity
  @return     String containing the HTML representation of member visibility
-------------------------------------------------------------------------------}
function TDOCGenHTML.GetHTMLMemberVisibility(dm: TDOCTemplate): string;
var
  tmpVisibility : string;
begin
  Assert(dm is TDOCMember);
  tmpVisibility := MemberVisibilitySymbol[TDOCMember(dm).MemberVisibility];
  if TDOCMember(dm).StrictVisibility then
   tmpVisibility := StrictVisibilitySymbol + tmpVisibility;
  Result := '  (' + tmpVisibility + ')';
end;

function TDOCGenHTML.GetHTMLMemberVisibilityClass(dm: TDOCTemplate): string;
var
  tmpVisibility : string;
begin
  Assert(dm is TDOCMember);
  tmpVisibility := MemberVisibilityClass[TDOCMember(dm).MemberVisibility];
  
  if TDOCMember(dm).StrictVisibility then
   tmpVisibility := StrictVisibilitySymbol + tmpVisibility;

  Result := tmpVisibility;
end;

/// Build an HTML blank line
procedure TDOCGenHTML.WriteBlankSection;
begin
  AddLine('');
end;

{*------------------------------------------------------------------------------
  Build the class section of the documentation
  Write Fields, methods, properties and events
  @param  DocClass  TDOCClass to generate
 ------------------------------------------------------------------------------}
procedure TDOCGenHTML.WriteClassHierarchy(
  const ClassHierarchy: TDOCClassesTree);
begin
  // TOOLBAR SECTION
  AddToolBar(ClassHierarchy);
  // DUMMY SECTION
  //AddLine(HTMLGenSimpleSection(L_ClassHierarchy, ClassHierarchy.Name));
  // CLASS HIERARCHY SECTION
  AddLine(HTMLGenLinesSectionInit(L_ClassHierarchy));
  ClassHierarchy.Iterate(IterateClassNode);
  AddLine(HTMLGenLinesSectionEnd());
  // LINKS SECTION
  AddLine(HTMLGenSimpleSection(L_Links, L_UnderConstruction));
  // TOOLBAR SECTION
  AddToolBar(ClassHierarchy);
end;

procedure TDOCGenHTML.IterateClassNode(const CurrentClassNodeNode : TDOCClassNode);
var
  RightAlignement : string;
  Index : integer;
begin
  RightAlignement := '';
  for Index := 0 to CurrentClassNodeNode.NestedLevel - 1 do
  begin
    RightAlignement := RightAlignement + '&nbsp&nbsp';
  end;
  RightAlignement := RightAlignement + ' * ';
  if(assigned(CurrentClassNodeNode.DocClassLink)) then
  begin
    AddLine(HTMLGenLinesSectionLine(RightAlignement +
     HTMLBuildLink(CurrentClassNodeNode.Name,
     CurrentClassNodeNode.DocClassLink.BuildPathName)));
  end
  else
  begin
    AddLine(HTMLGenLinesSectionLine(CurrentClassNodeNode.Name));
  end;

end;


function FindSeeLink(thisDocMember : TDOCTemplate; seeThis: String) : TDOCTemplate;
Var
 asClass  : TDOCClass;
 asUnit   : TDOCUnit;
 I        : Integer;
begin
  Result := nil;
  
 // Check to see if this member is what we need!
 if (UpperCase(thisDocMember.Name) = UpperCase(seeThis)) then
     begin Result := thisDocMember; Exit; End;
     
 if thisDocMember is TDOCMember then
    begin
     Result := nil; Exit;
    end; // Nothing here!

 if thisDocMember is TDOCClass then
    begin
     asClass := thisDocMember as TDOCClass;

     // Nope ... Continue searching in it's members
     for I := 0 to asClass.FieldList.Count - 1 do
     begin
       Result := FindSeeLink(asClass.FieldList.Items[I], seeThis);
       // Maybe we found something there?
       if Result <> nil then
          Exit;
     end;

     for I := 0 to asClass.PropertyList.Count - 1 do
     begin
       Result := FindSeeLink(asClass.PropertyList.Items[I], seeThis);
       // Maybe we found something there?
       if Result <> nil then
          Exit;
     end;

     for I := 0 to asClass.MethodList.Count - 1 do
     begin
       Result := FindSeeLink(asClass.MethodList.Items[I], seeThis);
       // Maybe we found something there?
       if Result <> nil then
          Exit;
     end;

     for I := 0 to asClass.EventList.Count - 1 do
     begin
       Result := FindSeeLink(asClass.EventList.Items[I], seeThis);
       // Maybe we found something there?
       if Result <> nil then
          Exit;
     end;

     for I := 0 to asClass.VarList.Count - 1 do
     begin
       Result := FindSeeLink(asClass.VarList.Items[I], seeThis);
       // Maybe we found something there?
       if Result <> nil then
          Exit;
     end;

     for I := 0 to asClass.ConstantList.Count - 1 do
     begin
       Result := FindSeeLink(asClass.ConstantList.Items[I], seeThis);
       // Maybe we found something there?
       if Result <> nil then
          Exit;
     end;

     for I := 0 to asClass.ClassList.Count - 1 do
     begin
       Result := FindSeeLink(asClass.ClassList.Items[I], seeThis);
       // Maybe we found something there?
       if Result <> nil then
          Exit;
     end;

     // Nothing found ... bad
     Exit;
    end;

 if thisDocMember is TDOCUnit then
     begin
       asUnit := thisDocMember as TDOCUnit;

       // Nope ... Continue searching in it's members
       for I := 0 to asUnit.VarList.Count - 1 do
       begin
         Result := FindSeeLink(asUnit.VarList.Items[I], seeThis);
         // Maybe we found something there?
         if Result <> nil then
            Exit;
       end;

       for I := 0 to asUnit.TypeList.Count - 1 do
       begin
         Result := FindSeeLink(asUnit.TypeList.Items[I], seeThis);
         // Maybe we found something there?
         if Result <> nil then
            Exit;
       end;

       for I := 0 to asUnit.ConstantList.Count - 1 do
       begin
         Result := FindSeeLink(asUnit.ConstantList.Items[I], seeThis);
         // Maybe we found something there?
         if Result <> nil then
            Exit;
       end;

       for I := 0 to asUnit.FunctionList.Count - 1 do
       begin
         Result := FindSeeLink(asUnit.FunctionList.Items[I], seeThis);
         // Maybe we found something there?
         if Result <> nil then
            Exit;
       end;

       for I := 0 to asUnit.FlatClassList.Count - 1 do
       begin
         Result := FindSeeLink(asUnit.FlatClassList.Items[I], seeThis);
         // Maybe we found something there?
         if Result <> nil then
            Exit;
       end;

       // Nothing ....
       Exit;
     end;


end;

function FindSeeLinkStart(thisDoc : TDOCGenHTML; thisDocMember: TDOCTemplate; seeThis: String) : String;
var
 i : Integer;
 lnkRes : TDOCTemplate;
begin
 for I := 0 to thisDoc.FileStructure.UnitList.Count - 1 do
     begin
       lnkRes := FindSeeLink(thisDoc.FileStructure.UnitList.Items[I], seeThis);

       if lnkRes <> nil then
       begin
         Result := thisDoc.GetRelativePathToItem(thisDocMember, lnkRes);
         Exit;
       end;
     end;

 Result := '';
end;

function TryFindSeeLink(thisDoc : TDOCGenHTML; thisDocMember: TDOCTemplate; seeThis: String) : String;
begin
 Result := FindSeeLinkStart(thisDoc, thisDocMember, seeThis);

 if Result <> '' then
    Result := HTMLBuildLink(seeThis, Result) else
    Result := seeThis;
end;

procedure TDOCGenHTML.WriteClassSection(const DocClass: TDOCClass);
var
  IndexMember,IndexItem: integer;

function ClassHierarchyListToString(const DocClass: TDOCClass; CHList : TClassHierarchyList): string;
var
  Index: Integer;
  stLink : String;
begin
  Result:='';
  For Index:=0 to CHList.Count-1 do
  begin
   if Index<>0 then Result := Result + ', ';

   stLink :=  FindSeeLinkStart(Self, DocClass, CHList.Strings[Index]);

   if stLink <> '' then
      Result := Result + HTMLBuildLink(CHList.Strings[Index], stLink) else
      Result := Result + CHList.Strings[Index];
  end;
end;

begin
  // TOOLBAR SECTION
  AddToolBar(DocClass);
  // CLASS SECTION
  AddLine(HTMLGenSimpleSection(L_Class, DocClass.Name));
  // HIERARCHY SECTION
  AddLine(HTMLGenSimpleSection(L_ClassHierarchy, ClassHierarchyListToString(DocClass, DocClass.ClassHierarchyList)));
  // RELATED UNIT  SECTION
  AddLine(HTMLGenSimpleSection(L_Parent,HTMLBuildLink(DocClass.GetParentName,
   GetRelativePathToParent(DocClass))));
  // DESCRIPTION SECTION
  WriteTAGSection(eDescriptionTAG, DocClass, L_Description);
  // TODO SECTION
  WriteSimpleTAGSection(eTodoTAG, DocClass, L_Todo);
  // ---------- START Cutted From Unit ------------------------------
  // CONSTANTS SECTION
  if ocConstants in DocOptions.OutputFilteringCategory then
  if not DocOptions.HideEmptyOutputBlock or (DocClass.ConstantList.Count>0) then
  begin
  AddLine(HTMLGenTableSectionInit(L_Constants, L_Constant, L_Description));
  for IndexItem := 0 to DocClass.ConstantList.Count - 1 do
  begin
    AddLine(HTMLGenTableSectionLine(
      HTMLBuildLinkWithProps(DocClass.ConstantList.Items[IndexItem].Name,
       DocClass.ConstantList.Items[IndexItem].BuildRelativePathName,
       GetHTMLMemberVisibilityClass(DocClass.ConstantList.Items[IndexItem])),
       DocClass.ConstantList.Items[IndexItem].TAGHolderList.GetSummary));
  end;
  AddLine(HTMLGenTableSectionEnd);
  end;
  // VARIABLES SECTION
  if ocVariables in DocOptions.OutputFilteringCategory then
  if not DocOptions.HideEmptyOutputBlock or (DocClass.VarList.Count>0) then
  begin
  AddLine(HTMLGenTableSectionInit(L_Variables, L_Variable, L_Description));
  for IndexItem := 0 to DocClass.VarList.Count - 1 do
  begin
    AddLine(HTMLGenTableSectionLine(
      HTMLBuildLinkWithProps(DocClass.VarList.Items[IndexItem].Name,
       DocClass.VarList.Items[IndexItem].BuildRelativePathName,
       GetHTMLMemberVisibilityClass(DocClass.VarList.Items[IndexItem])),
       DocClass.VarList.Items[IndexItem].TAGHolderList.GetSummary));
  end;
  AddLine(HTMLGenTableSectionEnd);
  end;
  // CLASSES SECTION
  if ocClasses in DocOptions.OutputFilteringCategory then
  if not DocOptions.HideEmptyOutputBlock or (DocClass.ClassList.Count>0) then
  begin
  AddLine(HTMLGenTableSectionInit(L_Classes, L_Class, L_Description));
  for IndexItem := 0 to DocClass.ClassList.Count - 1 do
  begin
    AddLine(HTMLGenTableSectionLine(
      HTMLBuildLink(TDOCClass(DocClass.ClassList.Items[IndexItem]).Name,
      DocClass.ClassList.Items[IndexItem].BuildRelativePathName),
      DocClass.ClassList.Items[IndexItem].TAGHolderList.GetSummary));
  end;
  AddLine(HTMLGenTableSectionEnd);
  end;
  // ---------- END Cutted From Unit ------------------------------
  // START OF MEMBERS MULTI SECTION
  if not DocOptions.HideEmptyOutputBlock or (DocClass.MembersCount>0) then
  begin
    AddLine(HTMLGenMultiSectionInit(L_Members));
    //   FIELDS SECTION
    if ocFields in DocOptions.OutputFilteringCategory then
     if not DocOptions.HideEmptyOutputBlock or (DocClass.FieldList.Count>0) then
     begin
      AddLine(HTMLGenTableSectionInit(L_Fields, L_Field, L_Description));
      for IndexMember := 0 to DocClass.FieldList.Count - 1 do
      begin
        if TDOCMember(DocClass.FieldList.Items[IndexMember]).MemberVisibility in
         DocOptions.VisibilitySet then
        begin
          AddLine(HTMLGenTableSectionLine(HTMLBuildLinkWithProps(DocClass.FieldList.Items[IndexMember].Name,
           DocClass.FieldList.Items[IndexMember].BuildRelativePathName,
           GetHTMLMemberVisibilityClass(DocClass.FieldList.Items[IndexMember])),
           DocClass.FieldList.Items[IndexMember].TAGHolderList.GetSummary))
        end;
      end;
      AddLine(HTMLGenTableSectionEnd);
     end;
    //   METHODS SECTION
    if ocMethods in DocOptions.OutputFilteringCategory then
     if not DocOptions.HideEmptyOutputBlock or (DocClass.MethodList.Count>0) then
     begin
      AddLine(HTMLGenTableSectionInit(L_Methods, L_Method, L_Description));
      for IndexMember := 0 to DocClass.MethodList.Count - 1 do
      begin
        if TDOCMember(DocClass.MethodList.Items[IndexMember]).MemberVisibility in
         DocOptions.VisibilitySet then
        begin
          AddLine(HTMLGenTableSectionLine(HTMLBuildLinkWithProps(DocClass.MethodList.Items[IndexMember].Name,
           DocClass.MethodList.Items[IndexMember].BuildRelativePathName,
           GetHTMLMemberVisibilityClass(DocClass.MethodList.Items[IndexMember]))
           , DocClass.MethodList.Items[IndexMember].TAGHolderList.GetSummary))
        end;
      end;
      AddLine(HTMLGenTableSectionEnd);
     end;
    //   PROPERTYS SECTION
    if ocProperties in DocOptions.OutputFilteringCategory then
    if not DocOptions.HideEmptyOutputBlock or (DocClass.PropertyList.Count>0) then
    begin
    AddLine(HTMLGenTableSectionInit(L_Properties, L_Property, L_Description));
    for IndexMember := 0 to DocClass.PropertyList.Count - 1 do
    begin
      if TDOCMember(DocClass.PropertyList.Items[IndexMember]).MemberVisibility in
       DocOptions.VisibilitySet then
      begin
        AddLine(HTMLGenTableSectionLine(HTMLBuildLinkWithProps(DocClass.PropertyList.Items[
         IndexMember].Name, DocClass.PropertyList.Items[IndexMember].BuildRelativePathName,
         GetHTMLMemberVisibilityClass(DocClass.PropertyList.Items[IndexMember]))
         ,DocClass.PropertyList.Items[IndexMember].TAGHolderList.GetSummary ))
      end;
    end;
    AddLine(HTMLGenTableSectionEnd);
    end;
    //   EVENTS SECTION
    if ocEvents in DocOptions.OutputFilteringCategory then
    if not DocOptions.HideEmptyOutputBlock or (DocClass.EventList.Count>0) then
    begin
    AddLine(HTMLGenTableSectionInit(L_Events, L_Event, L_Description));
    for IndexMember := 0 to DocClass.EventList.Count - 1 do
    begin
      if TDOCMember(DocClass.EventList.Items[IndexMember]).MemberVisibility in
       DocOptions.VisibilitySet then
      begin
        AddLine(HTMLGenTableSectionLine(HTMLBuildLinkWithProps(DocClass.EventList.Items[IndexMember].Name,
         DocClass.EventList.Items[IndexMember].BuildRelativePathName,
         GetHTMLMemberVisibilityClass(DocClass.EventList.Items[IndexMember])), L_UnderConstruction))
      end;
    end;
    AddLine(HTMLGenTableSectionEnd);
    end;
  end; // DocClass.MembersCount>0
  // END OF MEMBERS MULTI SECTION
  AddLine(HTMLGenMultiSectionEnd);
  
  // LEGEND SECTION
  //WriteLegend;

  // Add Links
  WriteSeeLinks(DocClass);

  // TOOLBAR SECTION
  AddToolBar(DocClass);
end;

procedure TDOCGenHTML.WriteComponentTable(const DocStructure: TDOCStructure; const Title, ComponentName: String; ExcludeNames: array of String);
Var
 Relative : String;
 IndexUnit, ExcUnit : Integer;
 IsHit : Boolean;
begin
  AddLine(HTMLGenTableSectionInit(Title, L_File, L_Description));
  for IndexUnit := 0 to DocStructure.UnitList.Count - 1 do
  begin
    Relative := DocStructure.UnitList[IndexUnit].BuildRelativePathName;

    if (Pos(UpperCase(ComponentName), UpperCase(Relative)) = 0) and (ComponentName <> '') then
       Continue;

    IsHit := False;
    
    for ExcUnit := 0 to Length(ExcludeNames) - 1 do
        if Pos(UpperCase(ExcludeNames[ExcUnit]), UpperCase(Relative)) <> 0 then
           begin IsHit := True; Break; end;

    if IsHit then
       Continue;

    AddLine(HTMLGenTableSectionLine(
      HTMLBuildLink(DocStructure.UnitList[IndexUnit].Name,
      Relative),
      DocStructure.UnitList[IndexUnit].TAGHolderList.GetSummary));
  end;
  AddLine(HTMLGenTableSectionEnd);
end;

procedure TDOCGenHTML.WriteComponentTable(const DocStructure: TDOCStructure; const Title, ComponentName : String);
Var
 Relative : String;
 IndexUnit : Integer;
begin
  AddLine(HTMLGenTableSectionInit(Title, L_File, L_Description));
  for IndexUnit := 0 to DocStructure.UnitList.Count - 1 do
  begin
    Relative := DocStructure.UnitList[IndexUnit].BuildRelativePathName;
    
    if (Pos(UpperCase(ComponentName), UpperCase(Relative)) = 0) and (ComponentName <> '') then
       Continue;

    AddLine(HTMLGenTableSectionLine(
      HTMLBuildLink(DocStructure.UnitList[IndexUnit].Name,
      Relative),
      DocStructure.UnitList[IndexUnit].TAGHolderList.GetSummary));
  end;
  AddLine(HTMLGenTableSectionEnd);
end;

/// Write Legend - Member visibility symbol - at the end of he document
procedure TDOCGenHTML.WriteLegend;
begin
  // LEGEND SECTION
  AddLine(HTMLGenTableSectionInit(L_Legend, L_Symbol, L_Visibility));
  AddLine(HTMLGenTableSectionLine(MemberVisibilitySymbol[mvPrivate], L_Private));
  AddLine(HTMLGenTableSectionLine(MemberVisibilitySymbol[mvProtected], L_Protected));
  AddLine(HTMLGenTableSectionLine(MemberVisibilitySymbol[mvPublic], L_Public));
  AddLine(HTMLGenTableSectionLine(MemberVisibilitySymbol[mvPublished], L_Published));
  AddLine(HTMLGenTableSectionLine(MemberVisibilitySymbol[mvAutomated], L_Automated));
  AddLine(HTMLGenTableSectionLine(StrictVisibilitySymbol, L_Strict));
  AddLine(HTMLGenTableSectionEnd);
end;

{*------------------------------------------------------------------------------
  Write in HTML doc the member visibility in text format.
  It handles the case where member has STRICT visibility keyword.
  @param  DocMember  TDOCMember to generate visibility
 ------------------------------------------------------------------------------}
procedure TDOCGenHTML.WriteMemberVisibilityText(const DocMember: TDOCMember);
var
  tmpVisibility : string;
begin
  tmpVisibility := MemberVisibilityName.Strings[integer(DocMember.MemberVisibility)];

  if DocMember.StrictVisibility then
   tmpVisibility := 'STRICT '+ tmpVisibility;

  AddLine(HTMLGenSimpleSection(L_Visibility, tmpVisibility));
end;



{*------------------------------------------------------------------------------
  Build the Member section of the documentation
  Write Fields, methods, properties or events, with parameters if exists
  @param  DocMember  TDOCMember to generate
 ------------------------------------------------------------------------------}
procedure TDOCGenHTML.WriteMemberSection(const DocMember: TDOCMember);
var
  tmpMethod:      TDOCMethod;
  tmpProperty: TDOCProperty;
  IndexParameter: integer;
begin
  // TOOLBAR SECTION
  AddToolBar(DocMember);
  // MEMBER SECTION
  AddLine(HTMLGenSimpleSection(L_Member, DocMember.Name));
  // VISIBILITY SECTION
  WriteMemberVisibilityText(DocMember);
  // RELATED CLASS SECTION
  AddLine(HTMLGenSimpleSection(L_RelatedClass,HTMLBuildLink(DocMember.GetParentName,
   GetRelativePathToParent(DocMember))));
  // DESCRIPTION SECTION
  WriteTAGSection(eDescriptionTAG, DocMember, L_Description);
  // TODO SECTION
  WriteSimpleTAGSection(eTodoTAG, DocMember, L_Todo);
  // EXCEPTION SECTION
  if (DocMember is TDOCMethod) then
   WriteSimpleTAGSection(eThrowsTAG, DocMember, L_Exception);
  // ADDITIONNAL COMMENT SECTION
  if (DocMember is TDOCMethod) then
   WriteSimpleTAGSection(eAdditionalCommentTAG, DocMember, L_AdditionalComment);
  // SOURCECODE SECTION
  //AddLine(HTMLGenSimpleSection(L_SourceCode, DocMember.BodySource));

  if (DocMember is TDOCMethod) then
  begin
    // PARAMETERS SECTION
    AddLine(HTMLGenTableSectionInit(L_Parameters, L_Parameter, L_Description));
    tmpMethod := DocMember as TDOCMethod;
    for IndexParameter := 0 to tmpMethod.ParameterList.Count - 1 do
    begin
      AddLine(HTMLGenTableSectionLine(tmpMethod.ParameterList[IndexParameter].Name +
        ' : ' + TryFindSeeLink(Self, DocMember, tmpMethod.ParameterList[IndexParameter].RelatedType),
        StringsToHTMLStrings(tmpMethod.TAGHolderList.GetContentByStyle(
        eParamTAG, tmpMethod.ParameterList[IndexParameter].Name),DocOptions.AllowHtmlInDescription)));
    end;
    AddLine(HTMLGenTableSectionEnd);
    // RETURN SECTION
    if tmpMethod.RelatedType <> '' then WriteReturnTAGSection(tmpMethod);
  end;
  // PROPERTY SECTION
  if (DocMember is TDOCProperty) then
  begin
    // Read/Write Access SECTION
    tmpProperty:=DocMember as TDOCProperty;
    if tmpProperty.HasReadSpecifier then
      AddLine(HTMLGenSimpleSection(L_ReadAccess, HTMLBuildLink(
       tmpProperty.ReadSpecifier,GetRelativePathToItem(tmpProperty, tmpProperty.ReadAssessor) )));
    if tmpProperty.HasWriteSpecifier then
      AddLine(HTMLGenSimpleSection(L_WriteAccess, HTMLBuildLink(
       tmpProperty.WriteSpecifier,GetRelativePathToItem(tmpProperty, tmpProperty.WriteAssessor) )));
  end;

  // LINKS SECTION
  WriteSeeLinks(DocMember);

  // TOOLBAR SECTION
  AddToolBar(DocMember);
end;

/// Write documentation Page footer
procedure TDOCGenHTML.WritePageFooter;
begin
  AddLine(HTMLGenFooter);
end;

/// Write documentation Page header
procedure TDOCGenHTML.WritePageHeader(const DocItem: TDOCTemplate);
var
  CSSRelativeFile: String;
begin
  CSSRelativeFile:=PathGetRelativePath(ExtractFilePath(
   FHtmlOutputFolder + DocItem.BuildPathName + HTML_FILE_EXT)
   ,FHtmlOutputFolder)+PathDelim+  CSS_BASE_FILENAME+CSS_FILE_EXT;
  // Replace Windows file path separator '\' with web path separator '/'
  CharReplace(CSSRelativeFile,'\','/');
  // HEADER SECTION - Add CSSFilename !
  AddLine(HTMLGenHead(DocOptions.Name,DocOptions.Summary,CSSRelativeFile));
end;

{*------------------------------------------------------------------------------
  Build the Project section of the documentation
  Write all files (units) in the projects
  @param  DocStructure  TDOCStructure to generate
 ------------------------------------------------------------------------------}
procedure TDOCGenHTML.WriteProjectSection(const DocStructure: TDOCStructure);
begin
  // TOOLBAR SECTION
  AddToolBar(DocStructure);
  // PROJECT SECTION
  AddLine(HTMLGenSimpleSection(L_Project, DocStructure.Name));
  // SUMMARY SECTION
  AddLine(HTMLGenSimpleSection(L_Summary, DocStructure.DocOptions.Summary));
  // DESCRIPTION SECTION
  AddLine(HTMLGenSimpleColoredSection(L_Description,
    StringsToHTMLStrings(DocStructure.DocOptions.Description,DocOptions.AllowHtmlInDescription)));
  // AUTHOR SECTION
  AddLine(HTMLGenSimpleSection(L_Author, DocStructure.DocOptions.Author));
  // FILES/UNITS SECTION


  AddLine(HTMLGenSimpleColoredSection('Basic Modules', 'The support modules for usage in the server.'));

  WriteComponentTable(DocStructure, 'Main Units', '', ['Components', 'Framework']);
  WriteComponentTable(DocStructure, 'Framework', 'Framework');

  AddLine(HTMLGenSimpleColoredSection('Server Cores', 'All game functionality is split between the five Cores.'));

  WriteComponentTable(DocStructure, 'Core Management Units', 'Components', ['Components.ExtensionCore', 'Components.GameCore', 'Components.NetworkCore', 'Components.DataCore', 'Components.IOCore']);
  WriteComponentTable(DocStructure, 'Game', 'Components.GameCore');
  WriteComponentTable(DocStructure, 'Network', 'Components.NetworkCore');
  WriteComponentTable(DocStructure, 'Data', 'Components.DataCore');
  WriteComponentTable(DocStructure, 'Extension', 'Components.ExtensionCore');
  WriteComponentTable(DocStructure, 'I/O', 'Components.IOCore');

  // TOOLBAR SECTION
  AddToolBar(DocStructure);
end;

{*------------------------------------------------------------------------------
  Build a colored TAG section of a Template
  @param  TAGType  TCommentStyle to search
  @param  DocItem  TDOCTemplate holding the TAG
  @param  SectionName string containing the name of the section
 ------------------------------------------------------------------------------}
procedure TDOCGenHTML.WriteTAGSection(const TAGType: TCommentStyle;
  const DocItem: TDOCTemplate; const SectionName: string);
var
  TAGStrings: TStringList;
begin
  if not DocItem.TAGHolderList.ExistContentByStyle(TAGType) then
  begin
    // Exit if TAG is empty and Options is ON
    if DocOptions.HideEmptyTAGSection then exit;
    if TAGType in OPTIONAL_TAG_COMMENT then exit;
  end;
  TAGStrings := DocItem.TAGHolderList.GetContentByStyle(TAGType);

  begin
    AddLine(HTMLGenLinesSectionInit(SectionName));
    AddLine(HTMLGenLinesSectionLineColored(StringsToHTMLStrings(TAGStrings,DocOptions.AllowHtmlInDescription)));
    AddLine(HTMLGenLinesSectionEnd);
  end;
end;

procedure TDOCGenHTML.WriteSeeLinks(DocMember: TDOCTemplate);
var
 List  : TStringList;
 I     : Integer;
 StLnk : String;
begin
  if DocMember.TAGHolderList.ExistContentByStyle(eSeeTAG) then
  begin
   List := DocMember.TAGHolderList.GetContentByStyle(eSeeTAG);
   //WriteSimpleTAGSection(eDescriptionTAG, DocUnit, L_Description);
   AddLine(HTMLGenLinesSectionInit(L_Links));

   for I := 0 to List.Count - 1 do
       begin
        StLnk := FindSeeLinkStart(Self, DocMember, List[I]);

        if StLnk = '' then
           AddLine(HTMLGenLinesSectionLine(List[I])) else
           AddLine(HTMLGenLinesSectionLine(HTMLBuildLink(List[I], StLnk)));

       end;

   AddLine(HTMLGenLinesSectionEnd());
  end;
end;

{*------------------------------------------------------------------------------
  Build a simple TAG section (no color) from a Template
  @param  TAGType  TCommentStyle to search
  @param  DocItem  TDOCTemplate holding the TAG
  @param  SectionName string containing the name of the section
 ------------------------------------------------------------------------------}
procedure TDOCGenHTML.WriteSimpleTAGSection(const TAGType: TCommentStyle;
  const DocItem: TDOCTemplate; const SectionName: string);
var
  TAGStrings: TStringList;
begin
  if not DocItem.TAGHolderList.ExistContentByStyle(TAGType) then
  begin
    // Exit if TAG is empty and Options is ON
    if DocOptions.HideEmptyTAGSection then exit;
    // Always hide optional TAG if empty, because it is optional !
    if TAGType in OPTIONAL_TAG_COMMENT then exit;
  end;
  TAGStrings := DocItem.TAGHolderList.GetContentByStyle(TAGType);
  AddLine(HTMLGenSimpleColoredSection(SectionName, StringsToHTMLStrings(TAGStrings,DocOptions.AllowHtmlInDescription)));
end;

{*------------------------------------------------------------------------------
  Build the specific @return TAG section from a Method
  @param  DOCMethod  TDOCMethod holding the TAG
 ------------------------------------------------------------------------------}
procedure TDOCGenHTML.WriteReturnTAGSection(const DOCMethod: TDOCMethod);
var
  TAGStrings: TStringList;
begin
  if not DOCMethod.TAGHolderList.ExistContentByStyle(eReturnTAG) then
  begin
    // Exit if TAG is empty and Options is ON
    if DocOptions.HideEmptyTAGSection then exit;
  end;
  TAGStrings := DOCMethod.TAGHolderList.GetContentByStyle(eReturnTAG);
  AddLine(HTMLGenTableSectionInit(L_Return, L_Types, L_Description));
  AddLine(HTMLGenTableSectionLine(TryFindSeeLink(Self, DOCMethod, DOCMethod.RelatedType),
    StringsToHTMLStrings(TAGStrings,DocOptions.AllowHtmlInDescription)));
  AddLine(HTMLGenTableSectionEnd);
end;

{*------------------------------------------------------------------------------
  Build the Unit section of the documentation
  Write all Classes, types, constants, variables, functions in the projects
  @param  DocUnit  TDOCUnit to generate
 ------------------------------------------------------------------------------}
procedure TDOCGenHTML.WriteUnitSection(const DocUnit: TDOCUnit);
var
  IndexItem: integer;
begin
  // TOOLBAR SECTION
  AddToolBar(DocUnit);
  // UNIT SECTION
  AddLine(HTMLGenSimpleSection(L_Unit, DocUnit.Name));
  // DESCRIPTION SECTION
  WriteSimpleTAGSection(eDescriptionTAG, DocUnit, L_Description);
  // TODO SECTION
  WriteSimpleTAGSection(eTodoTAG, DocUnit, L_Todo);
  // AUTHOR SECTION
  if DocUnit.TAGHolderList.ExistContentByStyle(eAuthorTAG) then
     WriteTAGSection(eAuthorTAG, DocUnit, L_Author);
  // CHANGES SECTION
  if DocUnit.TAGHolderList.ExistContentByStyle(eChangesTAG) then
     WriteTAGSection(eChangesTAG, DocUnit, L_Changes);

  // DOCS SECTION
  if DocUnit.TAGHolderList.ExistContentByStyle(eDocsTAG) then
     WriteTAGSection(eDocsTAG, DocUnit, L_Docs);

  // REVISION SECTION
  if DocUnit.TAGHolderList.ExistContentByStyle(eVersionTAG) then
     WriteTAGSection(eVersionTAG, DocUnit, L_Version);

  // AdditionnalComment SECTION
  if DocUnit.TAGHolderList.ExistContentByStyle(eAdditionalCommentTAG) then
     WriteSimpleTAGSection(eAdditionalCommentTAG, DocUnit, L_AdditionalComment);
  // CLASSES SECTION
  if ocClasses in DocOptions.OutputFilteringCategory then
  if not DocOptions.HideEmptyOutputBlock or (DocUnit.ClassList.Count>0) then
  begin
  AddLine(HTMLGenTableSectionInit(L_Classes, L_Class, L_Description));
  for IndexItem := 0 to DocUnit.ClassList.Count - 1 do
   //if not (not DocOptions.DisplayHiddenItems and DocUnit.ClassList.Items[IndexItem].Hidden) then
    if EvaluateItemDisplay(DocUnit.ClassList.Items[IndexItem]) then
    begin
      AddLine(HTMLGenTableSectionLine(
        HTMLBuildLink(TDOCClass(DocUnit.ClassList.Items[IndexItem]).Name,
        DocUnit.ClassList.Items[IndexItem].BuildRelativePathName),
        DocUnit.ClassList.Items[IndexItem].TAGHolderList.GetSummary));
    end;
  AddLine(HTMLGenTableSectionEnd);
  end;
  // TYPES SECTION
  if ocTypes in DocOptions.OutputFilteringCategory then
  if not DocOptions.HideEmptyOutputBlock or (DocUnit.TypeList.Count>0) then
  begin
  AddLine(HTMLGenTableSectionInit(L_Types, L_Type, L_Description));
  for IndexItem := 0 to DocUnit.TypeList.Count - 1 do
   if EvaluateItemDisplay(DocUnit.TypeList.Items[IndexItem]) then
    begin
      AddLine(HTMLGenTableSectionLine(
        HTMLBuildLink(DocUnit.TypeList.Items[IndexItem].Name, DocUnit.TypeList.Items[
        IndexItem].BuildRelativePathName), DocUnit.TypeList.Items[IndexItem].TAGHolderList.GetSummary));
    end;
  AddLine(HTMLGenTableSectionEnd);
  end;
  // CONSTANTS SECTION
  if ocConstants in DocOptions.OutputFilteringCategory then
  if not DocOptions.HideEmptyOutputBlock or (DocUnit.ConstantList.Count>0) then
  begin
  AddLine(HTMLGenTableSectionInit(L_Constants, L_Constant, L_Description));
  for IndexItem := 0 to DocUnit.ConstantList.Count - 1 do
   //if not (not DocOptions.DisplayHiddenItems and DocUnit.ConstantList.Items[IndexItem].Hidden) then
   if EvaluateItemDisplay(DocUnit.ConstantList.Items[IndexItem]) then
    begin
      AddLine(HTMLGenTableSectionLine(
        HTMLBuildLink(DocUnit.ConstantList.Items[IndexItem].Name, DocUnit.ConstantList.Items[IndexItem].BuildRelativePathName),
        DocUnit.ConstantList.Items[IndexItem].TAGHolderList.GetSummary));
    end;
  AddLine(HTMLGenTableSectionEnd);
  end;
  // VARIABLES SECTION
  if ocVariables in DocOptions.OutputFilteringCategory then
  if not DocOptions.HideEmptyOutputBlock or (DocUnit.VarList.Count>0) then
  begin
  AddLine(HTMLGenTableSectionInit(L_Variables, L_Variable, L_Description));
  for IndexItem := 0 to DocUnit.VarList.Count - 1 do
//   if not (not DocOptions.DisplayHiddenItems and DocUnit.VarList.Items[IndexItem].Hidden) then
   if EvaluateItemDisplay(DocUnit.VarList.Items[IndexItem]) then
    begin
      AddLine(HTMLGenTableSectionLine(
        HTMLBuildLink(DocUnit.VarList.Items[IndexItem].Name,
         DocUnit.VarList.Items[IndexItem].BuildRelativePathName),
         DocUnit.VarList.Items[IndexItem].TAGHolderList.GetSummary));
    end;
  AddLine(HTMLGenTableSectionEnd);
  end;
  // FUNCTIONS SECTION
  if ocFunctions in DocOptions.OutputFilteringCategory then
  if not DocOptions.HideEmptyOutputBlock or (DocUnit.FunctionList.Count>0) then
  begin
  AddLine(HTMLGenTableSectionInit(L_Functions, L_Function, L_Description));
  for IndexItem := 0 to DocUnit.FunctionList.Count - 1 do
//   if not (not DocOptions.DisplayHiddenItems and DocUnit.FunctionList.Items[IndexItem].Hidden) then
   if EvaluateItemDisplay(DocUnit.FunctionList.Items[IndexItem]) then
    begin
      AddLine(HTMLGenTableSectionLine(
        HTMLBuildLink(DocUnit.FunctionList.Items[IndexItem].Name, DocUnit.FunctionList.Items[IndexItem].BuildRelativePathName),
        DocUnit.FunctionList.Items[IndexItem].TAGHolderList.GetSummary));
    end;
  AddLine(HTMLGenTableSectionEnd);
  end;
  // EXPORTS SECTION
  if DocUnit.ExportsList.Count > 0 then
  begin
    Addline(HTMLGenLinesSectionInit(L_Exports));
    for IndexItem:=0 to DocUnit.ExportsList.Count-1 do
     Addline(HTMLGenLinesSectionLine(DocUnit.ExportsList.Strings[IndexItem]));
    Addline(HTMLGenLinesSectionEnd);
  end;

  // LINKS SECTION
  WriteSeeLinks(DocUnit);
  
  // TOOLBAR SECTION
  AddToolBar(DocUnit);
end;

{*------------------------------------------------------------------------------
  Build the Variable, Type, Function or Constant section of the documentation
  Write also parameters if exists (for function)
  @param  DocVTFC  TDOCTemplate to generate
 ------------------------------------------------------------------------------}
procedure TDOCGenHTML.WriteVTFCSection(const DocVTFC: TDOCTemplate);
var
  tmpFunction:    TDOCFunction;
  IndexParameter: integer;
begin
  // TOOLBAR SECTION
  AddToolBar(DocVTFC);
  // MEMBER SECTION
  AddLine(HTMLGenSimpleSection(L_Member, DocVTFC.Name));
  // PARENT SECTION
  AddLine(HTMLGenSimpleSection(L_Parent,HTMLBuildLink(DocVTFC.GetParentName,
   GetRelativePathToParent(DocVTFC))));
  //AddLine(HTMLGenSimpleSection(L_Parent, DocVTFC.GetParentName));
  // DESCRIPTION SECTION
  WriteTAGSection(eDescriptionTAG, DocVTFC, L_Description);
  // TODO SECTION
  WriteSimpleTAGSection(eTodoTAG, DocVTFC, L_Todo);
  // EXCEPTION SECTION
  if (DocVTFC is TDOCFunction) then
   WriteSimpleTAGSection(eThrowsTAG, DocVTFC, L_Exception);
  // AdditionnalComment SECTION
  if (DocVTFC is TDOCFunction) then
   WriteSimpleTAGSection(eAdditionalCommentTAG, DocVTFC, L_AdditionalComment);
  // SOURCECODE SECTION
  AddLine(HTMLGenSimpleSection(L_SourceCode, DocVTFC.BodySource));
  if (DocVTFC is TDOCFunction) then
  begin
    // PARAMETERS SECTION
    AddLine(HTMLGenTableSectionInit(L_Parameters, L_Parameter, L_Description));
    tmpFunction := DocVTFC as TDOCFunction;
    for IndexParameter := 0 to tmpFunction.ParameterList.Count - 1 do
    begin
      AddLine(HTMLGenTableSectionLine(tmpFunction.ParameterList[IndexParameter].Name +
        ' : ' + tmpFunction.ParameterList[IndexParameter].RelatedType,
        StringsToHTMLStrings(tmpFunction.TAGHolderList.GetContentByStyle(
        eParamTAG, tmpFunction.ParameterList[IndexParameter].Name),DocOptions.AllowHtmlInDescription)));
    end;
    AddLine(HTMLGenTableSectionEnd);
    if tmpFunction.RelatedType <> '' then
    begin
      // RETURN SECTION
      WriteReturnTAGSection(tmpFunction);
    end;
  end;

  // LINKS SECTION
  WriteSeeLinks(DocVTFC);

  // TOOLBAR SECTION
  AddToolBar(DocVTFC);
end;

/// Return the name of the main generated file from Generator
function TDOCGenHTML.GetOutputFile: TFileName;
begin
  result := FHtmlOutputFolder + FileStructure.BuildPathName + HTML_FILE_EXT;
end;

function TDOCGenHTML.GetRelativePathToParent(const DocItem: TDOCTemplate): string;
begin
  // parent is always ../[ParentsName]
  Result:= '../'+DocItem.RelatedParent.Name;
  { Result:=PathGetRelativePath(ExtractFilePath(
   FHtmlOutputFolder + DocItem.BuildPathName + HTML_FILE_EXT)
   ,ExtractFilePath(FHtmlOutputFolder + DocItem.RelatedParent.BuildPathName + HTML_FILE_EXT))
   +PathDelim+DocItem.RelatedParent.Name;
    }
end;

function TDOCGenHTML.GetRelativePathToItem(const DocItem, DocLink: TDOCTemplate): string;
begin
  assert(assigned(DocItem));
  if assigned(DocLink) then
  begin
   Result:=PathGetRelativePath(ExtractFilePath(
   FHtmlOutputFolder + DocItem.BuildPathName + HTML_FILE_EXT)
   ,ExtractFilePath(FHtmlOutputFolder + DocLink.BuildPathName + HTML_FILE_EXT))
   +PathDelim + DocLink.GetFileName;
  end
  else Result:= '';
end;

end.
