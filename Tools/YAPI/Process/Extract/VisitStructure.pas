{*------------------------------------------------------------------------------
  Visit interface structure
  The core of the builder. It takes data from the parser, and build class,
  units, and members hierarchy.
  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
-------------------------------------------------------------------------------}
unit VisitStructure;

interface

uses BaseVisitor, Structure, Classes,
     uDocTemplate, uDocMember, uDocMethod, uDocField, uDocClass;

type
  /// Visitor that build the structure from the result of the parser
  TVInterfaceStructure = class(TBaseTreeNodeVisitor)
  private
    mDebug: string; /// Debug message written at the end of the process
    procedure GetClassMethod(const mNode: TObject; const mt: TMethodType);
    function GetIdentList(const idNode: TObject; const idList: TStringList): integer;
    function GetDottedIdentifier(const idNode: TObject): string;
    function GetSingleIdentifier(const idNode: TObject): string;
    procedure GetFormalParameter(const fpNode: TObject);
    procedure GetReturnType(const rtNode: TObject);
    procedure GetPropertySpecifier(const psNode: TObject);
    procedure GetExportedProc(const epNode: TObject);
    procedure GetClassType(const ctNode: TObject);
    procedure GetClassDirectives(const cdNode: TObject);
    function  GetUpperClass(const ctNode: TObject): TDOCClass;
    procedure GetNestedClassInClass(const ctNode: TObject);
    procedure GetInterfaceType(const ctNode: TObject);
    procedure GetClassHeritage(const ceNode: TObject);
    procedure GetClassProperty(const cpNode: TObject);
    procedure GetClassField(const cfNode: TObject);
    procedure GetNestedVarInClass(const nvNode: TObject);
    procedure GetNestedConstInClass(const ncNode: TObject);
    procedure GetUnitVar(const ivNode: TObject);
    procedure GetUnitConst(const icNode: TObject);
    procedure GetMemberVisibility(const mvNode: TObject; const DocMember: TDOCMember);
    procedure UpdateIsClassMember(const mvNode: TObject; const DocMember: TDOCMember);
    procedure GetUnitType(const itNode: TObject);
    procedure GetUseUnit(const uuNode: TObject);
    procedure GetProcedureDirectiveName(const dnNode: TObject);
    procedure FixEmptyInheritance;
    procedure GetUnitName(const unNode: TObject);
    procedure ScanClassForProperties(const DocClass:TDOCClass);
    procedure LinkAssessorsToProperties(const ClassList : TDOCClassList);
    function  IsAuthorisedInImplementation(const pcNode: TObject) : Boolean;
    procedure UpdateHiddenAttribute(const haNode: TObject; const DocTemplate : TDocTemplate);
    procedure AddClassToClassesTree(const ClassList : TDOCCLassList);
  protected
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure PreVisitParseTreeNode(const pcNode: TObject); override;
    procedure PostVisitParseTreeNode(const pcNode: TObject); override;
    function VisitSourceToken(const pcNode: TObject): Boolean; override;
    function FinalSummary(var psMessage: string): boolean; override;
    function IsIncludedInSettings: boolean; override;
    procedure AfterFullVisit; override;
  end;

implementation

uses
  { delphi }
  SysUtils,
  JclImports,
  { JCF  }
  SourceToken, Tokens, ParseTreeNode, ParseTreeNodeType, TokenUtils,
  uDocProject, uOptions, uDocFunction, uDocParameter, uDocVar, uDocType,
  uDocConstant, uDocUseUnit, uDocProperty, uDocInterface, uDocUnit, uDocProgram,
  uDocLibrary;

var
  CurrentUnit:   TDOCUnit = nil;    /// Current Unit in use
  CurrentMethod: TDOCMethod = nil;  /// Current Method in use
  CurrentUseUnit: TDOCUseUnit = nil;  /// Current UseUnit in use
  CurrentProperty: TDOCProperty = nil;  /// Current Property in use

{*------------------------------------------------------------------------------
  Write the final summary of what the class has done after job
  @param    psMessage  String of output messages
  @return   TRUE if succesfull, always TRUE
-------------------------------------------------------------------------------}
function TVInterfaceStructure.FinalSummary(var psMessage: string): boolean;
begin
  //
  psMessage := mDebug;
  Result    := True;
end;

function TVInterfaceStructure.IsAuthorisedInImplementation(
  const pcNode: TObject): Boolean;
var
  lcNode: TParseTreeNode;
begin
  lcNode := TParseTreeNode(pcNode);
  // Following nodes are authorized in implementation :
  // Class, procedure/function, var, const, type, but not nested inside a procedure/function
  // Skip nodes in implementation section nested in procedure or function declaraction
  if lcNode.HasParentNode(ProcedureHeadings) then
  begin
    if lcNode.HasParentNode(nImplementationSection)
     and not lcNode.HasParentNode(ObjectTypes)
      then Result := False
    else Result := True;
  end
  else
  begin
    if lcNode.HasParentNode(nImplementationSection)
     and lcNode.HasParentNode(ProcedureNodes)
      then Result := False
    else Result := True;
  end;
end;

/// Not used
function TVInterfaceStructure.IsIncludedInSettings: boolean;
begin
  Result := True;
end;

{*------------------------------------------------------------------------------
  Get information on the node and add it in the structure
  @param    pcNode  Node currently processed (TParseTreeNode)
  @param    prVisitResult Not used
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.PreVisitParseTreeNode(const pcNode: TObject);
var
  lcNode: TParseTreeNode;
begin
  lcNode := TParseTreeNode(pcNode);
  if IsAuthorisedInImplementation(lcNode) = False then exit;

  case lcNode.NodeType of
    nTypeDecl: GetUnitType(lcNode);
    nConstDecl:
    begin
      if lcNode.HasParentNode(ObjectBodies) then
      begin
       if lcNode.HasParentNode(nConstSection) then GetNestedConstInClass(lcNode);
      end
      else
      if lcNode.HasParentNode(nConstSection) then GetUnitConst(lcNode);
    end;
    nProcedureHeading: GetClassMethod(lcNode, mtProcedure) ;
    nFunctionHeading: GetClassMethod(lcNode, mtFunction) ;
    nConstructorHeading: GetClassMethod(lcNode, mtConstructor);
    nDestructorHeading: GetClassMethod(lcNode, mtDestructor);
    nProperty: GetClassProperty(lcNode);
    nVarDecl:
    begin
      if lcNode.HasParentNode(ObjectBodies) then
      begin
       if lcNode.HasParentNode(nVarSection) then GetNestedVarInClass(lcNode)
       else GetClassField(lcNode)
      end
      else
      if lcNode.HasParentNode(nVarSection) then GetUnitVar(lcNode);
    end;
    nClassHeritage,
    nInterfaceHeritage: GetClassHeritage(lcNode);
    nClassType,
    nObjectType:
    begin
      if lcNode.HasParentNode(ObjectBodies) then GetNestedClassInClass(lcNode)
      else GetClassType(lcNode);
    end;
    nInterfaceType: GetInterfaceType(lcNode);
    nUnitName: GetUnitName(lcNode);
    nUsesItem: GetUseUnit(lcNode);
    nUsesFilename:
    begin
      if lcNode.HasParentNode([nProgram,nLibrary]) then
      begin
        CurrentUseUnit.ExistFileName:=true;
        CurrentuseUnit.FileName:=AnsiDequotedStr(lcNode.FirstSolidLeaf.GetSourceCode,#$27);
      end;
    end;
    nFormalParam: GetFormalParameter(lcNode);
    nFunctionReturnType: GetReturnType(lcNode);
    nPropertySpecifier: GetPropertySpecifier(lcNode);
    nExportedProc: GetExportedProc(lcNode);
    nProcedureDirectiveName: GetProcedureDirectiveName(lcNode);
    nClassDirectiveName: GetClassDirectives(lcNode);
    else
    begin 
    end; // no nothing
  end;
end;


/// Note used - Source Tokens are only LEAF !
function TVInterfaceStructure.VisitSourceToken(const pcNode: TObject): Boolean;
begin
  result:=false;
end;

/// Create and initialize a TVInterfaceStructure object
constructor TVInterfaceStructure.Create;
begin
  inherited;
  HasPreVisit := True;
  HasPostVisit := False;
  HasSourceTokenVisit := False;
  mDebug := '';
end;

/// Not used
procedure TVInterfaceStructure.PostVisitParseTreeNode(const pcNode: TObject);
begin
  //
end;

{*------------------------------------------------------------------------------
  Get an identifier list from anode
  @param   idNode  Node currently processed (TParseTreeNode)
  @param   idList  The StringList to add the identifiers name
-------------------------------------------------------------------------------}
function TVInterfaceStructure.GetIdentList(const idNode: TObject;
  const idList: TStringList): integer;
var
  lcNode:     TParseTreeNode;
  IndexChild: integer;
  tmpIdentifier : string;
begin
  assert(idList <> nil);
  lcNode := TParseTreeNode(idNode);
  assert(lcNode.NodeType = nIdentList);
  for IndexChild := 0 to lcNode.ChildNodeCount - 1 do
  begin
    tmpIdentifier := '';
    if lcNode.ChildNodes[IndexChild].NodeType = nIdentifier then
     tmpIdentifier := lcNode.ChildNodes[IndexChild].FirstSolidLeaf.Describe
    else
     if (lcNode.ChildNodes[IndexChild].NodeType = nDottedIdentifier) then
      tmpIdentifier := GetDottedIdentifier(lcNode.ChildNodes[IndexChild]);
    // Skip empty identifier if Child is comma
    if tmpIdentifier <> '' then idList.Add(tmpIdentifier);
  end;
  Result := idList.Count;
end;

{*------------------------------------------------------------------------------
  Get a dotted identifier list from anode
  @param   idNode  Node currently processed (TParseTreeNode)
  @param   idList  The StringList to add the identifiers name
-------------------------------------------------------------------------------}
function TVInterfaceStructure.GetDottedIdentifier(const idNode: TObject): string;
var
  lcNode:     TParseTreeNode;
  IndexChild: integer;
begin
  lcNode := TParseTreeNode(idNode);
  assert(lcNode.NodeType = nDottedIdentifier);
  Result := '';
  for IndexChild := 0 to lcNode.ChildNodeCount - 1 do
  begin
    if lcNode.ChildNodes[IndexChild].NodeType = nIdentifier then
    begin
      if Result <> '' then
       Result := Result + '.';
       Result := Result + lcNode.ChildNodes[IndexChild].FirstSolidLeaf.Describe;
    end;
  end;
end;

{*------------------------------------------------------------------------------
  Get the method from a class, and all its informations (parameters ...)
  @param   mNode  Node currently processed (TParseTreeNode)
  @param   mt  TMethodType containing the Method type
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetClassMethod(const mNode: TObject;
  const mt: TMethodType);
var
  lcNode:      TParseTreeNode;
  tmpNode:     TParseTreeNode;
  tmpMethod:   TDOCMethod;
  tmpFunction: TDOCFunction;
  ParentClass : TDOCClass;
begin
  lcNode := TParseTreeNode(mNode);
  CurrentMethod:= nil;
  // Procedural type not wanted here !
  if lcNode.HasParentNode(nProcedureType) then exit;
  if lcNode.HasParentNode(ObjectBodies) then
    // method
  begin
    ParentClass := GetUpperClass(lcNode);
    Assert(ParentClass <> nil);
    tmpNode := (lcNode.FirstSolidLeaf as TSOurceToken);
    if tmpNode.Describe = 'CLASS' then
    begin
      // Class method member
    end;
    tmpNode := nil;
    if lcNode.HasChildNode(nIdentifier) then
    begin
      tmpNode := lcNode.GetImmediateChild(nIdentifier).FirstSolidLeaf
    end;
    Assert(tmpNode <> nil);
    tmpMethod := ParentClass.MethodList.New(tmpNode.Describe,ParentClass,TDOCMethod) as TDOCMethod;
    tmpMethod.MethodType := mt;
    // Get method Visibility
    GetMemberVisibility(lcNode, tmpMethod);
    tmpMethod.BodySource := lcNode.GetSourceCode; 
    CurrentMethod := tmpMethod;
  end
  else // Procedure Type
  begin
    if lcNode.HasParentNode(nProcedureType) then
    begin
      // Add Procedural type !
      CurrentMethod := nil;
    end
    else // normal procedure / function
    begin
      Assert(CurrentUnit <> nil);
      if lcNode.HasParentNode(nDeclSection) then
      begin
        if lcNode.HasChildNode(nIdentifier) then
        begin
          tmpNode     := lcNode.GetImmediateChild(nIdentifier).FirstSolidLeaf;
          tmpFunction :=  CurrentUnit.FunctionList.New(tmpNode.Describe,CurrentUnit,TDOCFunction) as TDOCFunction;
          tmpFunction.BodySource := lcNode.GetSourceCode;
          tmpFunction.MethodType := mt;
          CurrentMethod := tmpFunction;
        end
      end;
    end
  end;
end;

{*------------------------------------------------------------------------------
  Get the parameter from a function, and all its informations (type ...)
  Informations will be add to the function
  @param   fpNode  Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetFormalParameter(const fpNode: TObject);
var
  lcNode:     TParseTreeNode;
  tmpParam:   TDOCParameter;
  tmpIdentList: TStringList;
  IndexIdent: integer;
begin
  lcNode := TParseTreeNode(fpNode);

  //if (lcNode.HasParentNode(ObjectBodies)) then
  if (lcNode.HasParentNode(ProcedureHeadings) and (CurrentMethod <> nil)) then
  begin
    Assert(CurrentMethod <> nil);
    tmpIdentList := TStringList.Create;
    GetIdentList(lcNode.GetImmediateChild(nIdentList), tmpIdentList);
    for IndexIdent := 0 to tmpIdentList.Count - 1 do
    begin
      tmpParam := CurrentMethod.ParameterList.New(TmpIdentList.Strings[IndexIdent]
       , CurrentMethod, TDOCParameter) as TDOCParameter;
      tmpParam.BodySource := lcNode.GetSourceCode; //GetSOurceCode(lcNode);
      // Verify if Parameter have a type
      if lcNode.HasChildNode(nType) then
      begin
        tmpParam.RelatedType := GetSingleIdentifier(lcNode.GetImmediateChild(nType));
      end
      else  // Mark as untyped
      begin
        tmpParam.RelatedType := 'Untyped'
      end;
    end;
    FreeAndNil(tmpIdentList);
  end;
end;

{*------------------------------------------------------------------------------
  Get the Type (parent) of a class
  @param   ctNode  The Class Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetClassType(const ctNode: TObject);
var
  lcNode: TParseTreeNode;
  NewClass : TDOCClass;
begin
  lcNode := TParseTreeNode(ctNode);
  // Verify if it is a forward declaration
  if (lcNode.HasChildNode(nClassBody) or lcNode.HasChildNode(nClassHeritage)) then
  begin
    Assert(CurrentUnit <> nil);
    NewClass := CurrentUnit.ClassList.New(lcNode.GetParentNode(
      nTypeDecl).GetImmediateChild(nIdentifier).FirstSolidLeaf.Describe,CurrentUnit,TDOCClass) as TDOCClass;
    CurrentUnit.FlatClassList.Add(NewClass);
    UpdateHiddenAttribute(lcNode, NewClass);
  end;
end;

{*------------------------------------------------------------------------------
  Get the Type (parent) of an interface
  Interface are special class, but no difference by now
  @param   ctNode  The Interface Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetInterfaceType(const ctNode: TObject);
var
  lcNode: TParseTreeNode;
  NewClass : TDOCClass;
begin
  lcNode := TParseTreeNode(ctNode);
  // Verify if it is not just a forward declaration
  if (lcNode.HasChildNode(nInterfaceBody) or lcNode.HasChildNode(
    nInterfaceHeritage) or lcNode.HasChildNode(nInterfaceTypeGuid) ) then
  begin
    Assert(CurrentUnit <> nil);
    NewClass := CurrentUnit.ClassList.New(lcNode.GetParentNode(
      nTypeDecl).GetImmediateChild(nIdentifier).FirstSolidLeaf.Describe,CurrentUnit,TDOCInterface) as TDOCClass;
    CurrentUnit.FlatClassList.Add(NewClass);
    UpdateHiddenAttribute(lcNode, NewClass);
  end;
end;

{*------------------------------------------------------------------------------
  Get the Type (parent) of a function Return value
  @param   rtNode  The Return Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetReturnType(const rtNode: TObject);
var
  lcNode: TParseTreeNode;
begin
  lcNode := TParseTreeNode(rtNode);
  { Must verify if function is not a FunctionType, since CurrentMethod is
    nil in this case }
  if lcNode.HasParentNode(nProcedureType) then exit;
  // Is a method ?
  if lcNode.HasParentNode(ObjectBodies) then
    CurrentMethod.RelatedType := GetSingleIdentifier(lcNode) //.FirstSolidLeaf.Describe
  else
    // Same Thing !!!
    CurrentMethod.RelatedType := GetSingleIdentifier(lcNode); //.FirstSolidLeaf.Describe;
end;

{*------------------------------------------------------------------------------
  Get the Type (parent) of a function Return value
  @param   rtNode  The Return Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetClassHeritage(const ceNode: TObject);
var
  lcNode: TParseTreeNode;
  ParentClass : TDOCClass;
begin
  lcNode := TParseTreeNode(ceNode);
  if lcNode.HasChildNode(nIdentList) then
  begin
    ParentClass := GetUpperClass(ceNode);
    Assert(ParentClass <> nil);
    GetIdentList(lcNode.GetImmediateChild(nIdentList), ParentClass.ClassHierarchyList);
  end;
end;

{*------------------------------------------------------------------------------
  Get the Property description of a class
  @param   cpNode  The Property Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetClassProperty(const cpNode: TObject);
var
  lcNode, tmpNode: TParseTreeNode;
  tmpProperty:     TDOCProperty;
  ParentClass : TDOCClass;
begin
  lcNode := TParseTreeNode(cpNode);
  // from Class declaration ?
  Assert(lcNode.HasParentNode(ObjectBodies) = True);
  ParentClass := GetUpperClass(cpNode);
  Assert(ParentClass <> nil);
  // Get Property Name
  tmpNode     := lcNode.GetImmediateChild(nIdentifier).FirstSolidLeaf;
  tmpProperty := ParentClass.PropertyList.New(tmpNode.Describe,ParentClass,TDOCProperty) as TDOCProperty;
  tmpProperty.BodySource := lcNode.GetSourceCode; //GetSourceCode(lcNode);
  CurrentProperty:=tmpProperty;
  // Get Property Type
  // Verify if Property have a type. Else, type is ancestor's one.
  if lcNode.HasChildNode(nType) then
  begin
    tmpNode := lcNode.GetImmediateChild(nType);
    tmpProperty.RelatedType := GetSingleIdentifier(tmpNode);
  end
  else begin
    tmpProperty.RelatedType := '#Inherited from Parent#'
  end;
  // Get Property Visibility
  GetMemberVisibility(lcNode, tmpProperty);
  UpdateIsClassMember(lcNode, tmpProperty);
end;

{*------------------------------------------------------------------------------
  Get the Field description of a class (name, type, visiblity)
  @param   cfNode  The Field Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetClassField(const cfNode: TObject);
var
  lcNode: TParseTreeNode;
  tmpField: TDOCField;
  tmpIdentList: TStringList;
  IndexIdent: integer;
  ParentClass : TDOCClass;
begin
  lcNode := TParseTreeNode(cfNode);
  ParentClass := GetUpperClass(cfNode);
  assert(ParentClass <> nil);
  tmpIdentList := TStringList.Create;
  GetIdentList(lcNode.GetImmediateChild(nIdentList), tmpIdentList);
  for IndexIdent := 0 to tmpIdentList.Count - 1 do
  begin
    // Get Field Name
    tmpField := ParentClass.FieldList.New(TmpIdentList.Strings[IndexIdent],ParentClass,TDOCField) as TDocField;
    tmpField.BodySource := lcNode.GetSourceCode; //GetSourceCode(lcNode);
    // Get Field Type
    if lcNode.HasChildNode(nType) then
    begin
      tmpField.RelatedType  := GetSingleIdentifier(lcNode.GetImmediateChild(nType)); //lcNode.GetImmediateChild(nType).FirstSolidLeaf.Describe;
    end
    else  // Mark as untyped
    begin
      tmpField.RelatedType := 'Untyped'
    end;
    // Get Field Visibility
    GetMemberVisibility(lcNode, tmpField);
  end;
  FreeAndNil(tmpIdentList);
end;

{*------------------------------------------------------------------------------
  Get the Field description of a class (name, type, visiblity)
  @param   cfNode  The Field Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetNestedVarInClass(const nvNode: TObject);
var
  lcNode: TParseTreeNode;
  tmpVar: TDOCVar;
  tmpIdentList: TStringList;
  IndexIdent: integer;
  ParentClass : TDOCClass;
begin
  lcNode := TParseTreeNode(nvNode);
  ParentClass := GetUpperClass(nvNode);
  assert(ParentClass <> nil);
  // Get IdentList
  tmpIdentList := TStringList.Create;
  GetIdentList(lcNode.GetImmediateChild(nIdentList), tmpIdentList);
  for IndexIdent := 0 to tmpIdentList.Count - 1 do
  begin
    // Get Field Name
    tmpVar := ParentClass.VarList.New(TmpIdentList.Strings[IndexIdent],ParentClass,TDOCVar) as TDOCVar;
    tmpVar.BodySource := lcNode.GetSourceCode; //GetSourceCode(lcNode);
    // Get Field Type
    if lcNode.HasChildNode(nType) then
    begin
      tmpVar.RelatedType  := GetSingleIdentifier(lcNode.GetImmediateChild(nType)); //lcNode.GetImmediateChild(nType).FirstSolidLeaf.Describe;
    end
    else  // Mark as untyped
    begin
      tmpVar.RelatedType := 'Untyped'
    end;
    // Get Field Visibility
    GetMemberVisibility(lcNode, tmpVar);
    UpdateHiddenAttribute(lcNode, tmpVar);
  end;
  FreeAndNil(tmpIdentList);
end;

{*------------------------------------------------------------------------------
  Get the  description of a unit Variable (name, type)
  @param   ivNode  The Var Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetUnitVar(const ivNode: TObject);
var
  lcNode: TParseTreeNode;
  tmpVar: TDOCVar;
begin
  lcNode := TParseTreeNode(ivNode);
  assert(CurrentUnit <> nil);
  tmpVar := CurrentUnit.VarList.New(lcNode.FirstSolidLeaf.Describe,CurrentUnit,TDOCVar) as TDOCVar;
  tmpVar.RelatedType := GetSingleIdentifier(lcNode.GetImmediateChild(nType));
  tmpVar.BodySource := lcNode.GetSourceCode; //GetSourceCode(lcNode);
  UpdateHiddenAttribute(lcNode, tmpVar);
end;


{*------------------------------------------------------------------------------
  Update the Hidden property of a member. TRUE if it is in interface section,
   FALSE if only defined in implememtation
  @param   icNode  The Constant Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.UpdateHiddenAttribute(const haNode: TObject; const DocTemplate : TDocTemplate);
var
  lcNode : TParseTreeNode;
begin
  lcNode := TParseTreeNode(haNode);
  if lcNode.HasParentNode(nImplementationSection) then DocTemplate.Hidden := True
   else DocTemplate.Hidden:= False;
end;

{*------------------------------------------------------------------------------
  Get the description of a unit Constant (name, type, value)
  @param   icNode  The Constant Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetUnitConst(const icNode: TObject);
var
  lcNode, tmpNode: TParseTreeNode;
  tmpConstant:     TDOCConstant;
begin
  lcNode := TParseTreeNode(icNode);
  Assert(CurrentUnit <> nil);
  if lcNode.HasParentNode(nConstSection) then
  begin
    tmpConstant := CurrentUnit.ConstantList.New(lcNode.FirstSolidLeaf.Describe,CurrentUnit,TDOCConstant) as
      TDOCConstant;
    tmpConstant.BodySource := lcNode.GetSourceCode; //GetSourceCode(lcNode);
    if lcNode.HasChildNode(nType) then
    begin
      tmpNode := lcNode.GetImmediateChild(nType);
      tmpConstant.RelatedType:=GetSingleIdentifier(tmpNode);
    end;
    UpdateHiddenAttribute(lcNode, tmpConstant);
  end;
end;

{*------------------------------------------------------------------------------
  Get the visiblity of a member
  @param   mvNode  The Member Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetMemberVisibility(const mvNode: TObject;
  const DocMember: TDOCMember);
var
  lcNode, tmpNode: TParseTreeNode;
begin
  lcNode := TParseTreeNode(mvNode);
  if lcNode.HasParentNode(nClassVisibility) then
  begin
    tmpNode := lcNode.GetParentNode(nClassVisibility).FirstSolidLeaf;
    // if 'strict' visiblity detected, get next visibility name
    if SameText(tmpNode.Describe,'STRICT') then
    begin
     tmpNode:=(tmpNode as TSourceToken).NextSolidToken;
     DocMember.StrictVisibility:=true;
    end
    else DocMember.StrictVisibility:=false;

    DocMember.MemberVisibility :=
      TMemberVisibility(MemberVisibilityName.IndexOf(TmpNode.Describe));
  end
  else begin
    if lcNode.HasParentNode(nInterfaceBody) then
    begin
      DocMember.MemberVisibility := mvPUBLIC
    end
    else     begin
      DocMember.MemberVisibility := mvPUBLISHED
    end
  end;
end;

{*------------------------------------------------------------------------------
  Get the description of a unit Type (name, type, value)
  @param   icNode  The Constant Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetUnitType(const itNode: TObject);
var
  lcNode:  TParseTreeNode;
  tmpType: TDOCType;
begin
  lcNode := TParseTreeNode(itNode);
  assert(CurrentUnit <> nil);
  // Take only true interface type, not Class or other
  // What about records ???
  if lcNode.HasParentNode(nTypeSection) and not lcNode.HasChildNode(nClassType) and
    not lcNode.HasChildNode(nInterfaceType) and not lcNode.HasChildNode(nObjectType) then
  begin
    tmpType := CurrentUnit.TypeList.New(lcNode.GetImmediateChild(
      nIdentifier).FirstSolidLeaf.Describe,CurrentUnit,TDOCType) as TDOCType;
    tmpType.RelatedType := GetSingleIdentifier(lcNode.GetImmediateChild(nType)); //.FirstSolidLeaf.Describe;
    tmpType.BodySource := lcNode.GetSourceCode;
    UpdateHiddenAttribute(lcNode, tmpType);
  end;
end;

/// Special process to execute after the full visit of the Tree
procedure TVInterfaceStructure.AddClassToClassesTree(
  const ClassList: TDOCCLassList);
var
  ClassIndex : integer;
begin
  for ClassIndex := 0 to ClassList.Count - 1 do
  begin
    DocProject.GetStructure.ClassTree.AddDocClass(ClassList.Items[ClassIndex] as TDOCCLass);
  end;
end;

procedure TVInterfaceStructure.AfterFullVisit;
begin
  if assigned(CurrentUnit) then
  begin
    FixEmptyInheritance;
    LinkAssessorsToProperties(CurrentUnit.ClassList);
    AddClassToClassesTree(CurrentUnit.FlatClassList);
  end;
end;

/// Fix empty inheritence for class and interface
procedure TVInterfaceStructure.FixEmptyInheritance;
var
  IndexClass: Integer;
  tmpClass: TDOCClass;
begin
  Assert(Assigned(CurrentUnit));
  for IndexClass:=0 to CurrentUnit.ClassList.Count-1 do
  begin
    tmpClass:= CurrentUnit.ClassList.items[IndexClass] as TDOCClass;
    // If empty list, add ancestor
    if tmpClass.ClassHierarchyList.Count=0 then
     if tmpClass is TDOCInterface then
      tmpClass.ClassHierarchyList.Add('IInterface')
       else tmpClass.ClassHierarchyList.Add('TObject');
  end;
end;

{*------------------------------------------------------------------------------
  Get the use unit in this node
  @param   uuNode  The use unit Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetUseUnit(const uuNode: TObject);
var
  lcNode:  TParseTreeNode;
  UseUnitName : string;
begin
  lcNode := TParseTreeNode(uuNode);
  begin
    // get Uses item only for Program or library
    if lcNode.HasParentNode([nProgram,nLibrary]) then
    begin
      assert(CurrentUnit is TDOCProgram);
      UseUnitName := '';
      if lcNode.HasChildNode(nDottedIdentifier) then
       UseUnitName := GetDottedIdentifier(lcNode.GetImmediateChild(nDottedIdentifier))
      else
      if lcNode.HasChildNode(nIdentifier) then
        UseUnitName := lcNode.GetImmediateChild(nIdentifier).FirstSolidLeaf.Describe;
      if UseUnitName <> '' then
       CurrentUseUnit:=(CurrentUnit as TDOCProgram).UseUnitList.New(
        UseUnitName,CurrentUnit,TDOCUseUnit) as TDOCUseUnit;
      UpdateHiddenAttribute(lcNode, CurrentUseUnit);
    end;
  end;
end;

{*------------------------------------------------------------------------------
  Get the property specifier (read / write) in this node
  @param   psNode  The property Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetPropertySpecifier(const psNode: TObject);
var
  lcNode:  TParseTreeNode;
begin
  lcNode := TParseTreeNode(psNode);
  // Get specifier type
  if lcNode.FirstSolidLeaf.Describe='READ' then
  begin
   CurrentProperty.HasReadSpecifier:=true;
   CurrentProperty.ReadSpecifier:=lcNode.GetImmediateChild(nIdentifier).FirstSolidLeaf.Describe;
  end
  else
  if lcNode.FirstSolidLeaf.Describe='WRITE' then
  begin
   CurrentProperty.HasWriteSpecifier:=true;
   CurrentProperty.WriteSpecifier:=lcNode.GetImmediateChild(nIdentifier).FirstSolidLeaf.Describe;
  end;
end;

{*------------------------------------------------------------------------------
  Get the property specifier (read / write) in this node
  @param   psNode  The property Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetExportedProc(const epNode: TObject);
var
  lcNode:  TParseTreeNode;
begin
  lcNode := TParseTreeNode(epNode);
  if lcNode.HasParentNode(nExports) then
  begin
    // Exports are present in Program, unit, or library
    if lcNode.HasChildNode(nIdentifier) then CurrentUnit.ExportsList.Add(
      lcNode.GetImmediateChild(nIdentifier).FirstSolidLeaf.Describe);
  end;
end;

{*------------------------------------------------------------------------------
  Get an identifier or a list of identifier into a single string
  @param   idNode  The identifier Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
function TVInterfaceStructure.GetSingleIdentifier(
  const idNode: TObject): string;
var
  lcNode:  TParseTreeNode;
begin
  lcNode := TParseTreeNode(idNode);
  if(lcNode.NodeType = nDottedIdentifier) then result:=GetDottedIdentifier(idNode)
  else
  begin
    if(lcNode.HasChildNode(nDottedIdentifier,1)) then
     result:=GetDottedIdentifier(lcNode.GetImmediateChild(nDottedIdentifier))
    else Result:=lcNode.FirstSolidLeaf.Describe;
  end;
end;

{*------------------------------------------------------------------------------
  Get a class constant in this node
  @param   ncNode  The constant Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetNestedConstInClass(
  const ncNode: TObject);
var
  lcNode, tmpNode: TParseTreeNode;
  tmpConstant:     TDOCConstant;
  ParentClass : TDOCClass;
begin
  lcNode := TParseTreeNode(ncNode);
  ParentClass := GetUpperClass(ncNode);
  Assert(ParentClass <> nil);
  //if lcNode.HasParentNode(nConstSection) then
  begin
    tmpConstant := ParentClass.ConstantList.New(lcNode.FirstSolidLeaf.Describe,ParentClass,TDOCConstant) as
      TDOCConstant;
    tmpConstant.BodySource := lcNode.GetSourceCode;
    if lcNode.HasChildNode(nType) then
    begin
      tmpNode := lcNode.GetImmediateChild(nType);
      tmpConstant.RelatedType := GetSingleIdentifier(tmpNode);
    end;
    // Get Field Visibility
    GetMemberVisibility(lcNode, tmpConstant);
    UpdateHiddenAttribute(lcNode, tmpConstant);
  end;
end;

{*------------------------------------------------------------------------------
  Get a class (in another class) in this node
  @param   ctNode  The innner Class Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetNestedClassInClass(
  const ctNode: TObject);
var
  lcNode: TParseTreeNode;
  ParentClass: TDOCClass;
  NewClass : TDOCClass;
begin
  lcNode := TParseTreeNode(ctNode);
  assert(lcNode.HasParentNode(nTypeDecl));
  // Verify if it is a forward declaration
  if (lcNode.HasChildNode(nClassBody) or lcNode.HasChildNode(nClassHeritage)) then
  begin
    ParentClass := GetUpperClass(lcNode.GetParentNode(nTypeDecl).Parent);
    Assert(ParentClass <> nil);
    NewClass := ParentClass.ClassList.New(lcNode.GetParentNode(
      nTypeDecl).GetImmediateChild(nIdentifier).FirstSolidLeaf.Describe,ParentClass,TDOCClass) as TDOCClass;
    CurrentUnit.FlatClassList.Add(NewClass);
    GetMemberVisibility(ctNode, NewClass);
    UpdateHiddenAttribute(lcNode, NewClass);
  end;
end;

{*------------------------------------------------------------------------------
  Get the upper class containing this node
  @param   ctNode  The upper Class Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
function TVInterfaceStructure.GetUpperClass(
  const ctNode: TObject): TDOCClass;
var
  lcNode: TParseTreeNode;
  tmpClassName: string;
begin
  lcNode := TParseTreeNode(ctNode);
  if lcNode.HasParentNode(ObjectBodies) or lcNode.HasParentNode(ObjectTypes) then
  begin
   tmpClassName := lcNode.GetParentNode(nTypeDecl).GetImmediateChild(nIdentifier).FirstSolidLeaf.Describe;
   Result := CurrentUnit.FlatClassList.FindItemByName(tmpClassName) as TDOCClass;
  end
  else Result := nil;
end;

/// Destroy an instance of TVInterfaceStructure
destructor TVInterfaceStructure.Destroy;
begin
  inherited;
end;

{*------------------------------------------------------------------------------
  Get the procedure directive name in this node
  @param   dnNode  The directive Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetProcedureDirectiveName(const dnNode: TObject);
 // Add a directive to current method
 procedure AddDirective(const Directive: TMethodDirectives);
 begin
  CurrentMethod.MethodDirectiveSet := CurrentMethod.MethodDirectiveSet + [Directive];
 end;

var
  lcNode: TParseTreeNode;
  lcToken : TSourceToken;
begin
  lcNode := TParseTreeNode(dnNode);
  // Test if CurrentMethod is assigned because of Function type !
  if assigned(CurrentMethod) then
  begin
    //tmpDirectiveName := UpperCase(lcNode.FirstSolidLeaf.Describe);
    lcToken := (lcNode.FirstSolidLeaf as TSourceToken);
    case lcToken.TokenType of
      //ttExternal:
      //ttPascal:
      //ttSafecall:
      ttAbstract: AddDirective(mdAbstract);
      ttAutomated: AddDirective(mdAutomated);
      //ttFar:
      //ttStdcall:
      //ttAssembler:
      //ttInline:
      //ttForward:
      ttVirtual: AddDirective(mdVirtual);
      //ttCdecl:
      //ttMessage:
      //ttName:
      //ttRegister:
      //ttDispId:
      //ttNear:
      ttDynamic: AddDirective(mdVirtual);
      //ttExport:
      ttOverride: AddDirective(mdOverride);
      //ttResident:
      //ttLocal:
      ttOverload:  AddDirective(mdOverload);
      //ttReintroduce:
      //ttDeprecated:
      //ttLibrary:
      //ttPlatform:
      ttStatic: AddDirective(mdStatic);
      ttFinal: AddDirective(mdFinal);
      ttUnsafe: AddDirective(mdUnsafe);
    end;
  end;
end;

{*------------------------------------------------------------------------------
  Get the class directive name in this node
  @param   cdNode  The class Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetClassDirectives(const cdNode: TObject);
 // Add a directive to current method
var
  lcNode: TParseTreeNode;
  lcToken : TSourceToken;
  tmpClass: TDOCClass;
 procedure AddClassDirective(const Directive: TClassDirectives);
 begin
  tmpClass.ClassDirectivesSet := tmpClass.ClassDirectivesSet + [Directive];
 end;

begin
  lcNode := TParseTreeNode(cdNode);
  tmpClass := GetUpperClass(lcNode);
  assert(assigned(tmpClass));
  lcToken := (lcNode.FirstSolidLeaf as TSourceToken);
  case lcToken.TokenType of
    ttAbstract: AddClassDirective(cdAbstract);
    ttSealed: AddClassDirective(cdSealed);
    ttHelper: AddClassDirective(cdHelper);
  end;

end;

{*------------------------------------------------------------------------------
  Get the unit name in this node
  @param   unNode  The unit Node currently processed (TParseTreeNode)
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.GetUnitName(const unNode: TObject);
var
  lcNode: TParseTreeNode;
  NewUnitName : string;
begin
  lcNode := TParseTreeNode(unNode);
  NewUnitName:=GetSingleIdentifier(lcNode);
    
  if lcNode.HasParentNode(nUnit) then
   CurrentUnit := DocProject.GetStructure.UnitList.New(NewUnitName,
    DocProject.GetStructure,TDOCUnit) as TDOCUnit
  else
  if lcNode.HasParentNode(nProgram) then
   CurrentUnit := DocProject.GetStructure.UnitList.New(NewUnitName,
   DocProject.GetStructure,TDOCProgram) as TDOCProgram
  else
  if lcNode.HasParentNode(nLibrary) then
   CurrentUnit := DocProject.GetStructure.UnitList.New(NewUnitName,
   DocProject.GetStructure, TDOCLibrary) as TDOCLibrary;
  assert(assigned(CurrentUnit));
  if assigned(CurrentUnit) then
  begin
    CurrentUnit.Filename:=ExtractFileName(DocProject.CheckingFilename);
    if (CurrentUnit is TDOCProgram) then DocProject.GetStructure.SetProgram(CurrentUnit as TDOCProgram);
  end;
end;

{*------------------------------------------------------------------------------
  Scan a class and try to link properties and accessor
  @param   DocClass  The class to process
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.ScanClassForProperties(const DocClass:TDOCClass);
type
  TAssessorType = (atRead, atWrite);
var
  IndexProperty : integer;
  tmpDocProperty: TDOCProperty;
  // Get Assessor by searching in Field list, var list and method list
  function GetAssessor(const AssessorName: string) : TDOCTemplate;
  begin
    assert(assigned(DocClass));
    result:= DocClass.FieldList.FindItemByName(AssessorName);
    if not assigned(result) then
     result:= DocClass.VarList.FindItemByName(AssessorName);
    if not assigned(result) then
     result:= DocClass.MethodList.FindItemByName(AssessorName);
  end;
  // Link assessor to property
  procedure LinkAssessor(const AssessorName: string; const AssessorType : TAssessorType);
  var
    DocAssessor : TDOCTemplate;
  begin
    DocAssessor:=GetAssessor(AssessorName);
    if assigned(DocAssessor) then
    begin
      if AssessorType = atRead then tmpDocProperty.ReadAssessor := DocAssessor
      else if AssessorType = atWrite then tmpDocProperty.WriteAssessor := DocAssessor;
    end;
  end;

begin
  for IndexProperty:=0 to DocClass.PropertyList.Count-1 do
  begin
    tmpDocProperty:=DocClass.PropertyList.Items[IndexProperty] as TDOCProperty;
    // test if Read or write specifier is a field
    if tmpDocProperty.HasReadSpecifier then
     LinkAssessor(tmpDocProperty.ReadSpecifier,atRead);
    if tmpDocProperty.HasWriteSpecifier then
     LinkAssessor(tmpDocProperty.WriteSpecifier,atWrite);
  end;

end;

{*------------------------------------------------------------------------------
  Find and Link assessors for a list of class
  @param   ClassList  The class list to process
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.LinkAssessorsToProperties(const ClassList : TDOCClassList);
var
  IndexClass : integer;
  tmpDocClass : TDOCClass;
begin
  for IndexClass:=0 to ClassList.Count-1 do
  begin
    tmpDocClass := ClassList.Items[IndexClass] as TDOCClass;
    ScanClassForProperties(tmpDocClass);
    // Scan nested class
    LinkAssessorsToProperties(tmpDocClass.ClassList);
  end;
end;

{*------------------------------------------------------------------------------
  Detect if a member is a "class" member
  @param   mvNode  The member node to process
  @param   DocMember the member to inspect
-------------------------------------------------------------------------------}
procedure TVInterfaceStructure.UpdateIsClassMember(const mvNode: TObject;
  const DocMember: TDOCMember);
var
  lcNode : TParseTreeNode;
begin
  lcNode := TParseTreeNode(mvNode);

  if TSourceToken(lcNode.NextLeafNode).TokenType = ttClass then
   DocMember.IsClassMember := TRUE
  else DocMember.IsClassMember := FALSE;

end;

end.
