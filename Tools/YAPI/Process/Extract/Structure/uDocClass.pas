{*------------------------------------------------------------------------------
  Base class to represent classes in Delphi language
  The structure builder will create these objects from the parser informations.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @Version   2006/12/01   TridenT   Extracted from Structure.pas file
-------------------------------------------------------------------------------}

unit uDocClass;

interface

uses
  Windows, SysUtils, Classes, Contnrs, TAGComment, uOptions,
  uDocTemplate, uDocMember; //, uDocMethod;

type
  /// List of all class directive keyword (Delphi2005 and dotNET supported)
  TClassDirectives = (cdAbstract, cdSealed, cdHelper);
  /// Set of all class directive keyword
  TClassDirectivesSet = set of TClassDirectives;

  TClassHierarchyList = TStringList;     /// List of Inherited Class and interface
  // TODO 2 -oTridenT -cMissing : Add nested types in class
  /// Specialized TDOCTemplate class for Class structure
  TDOCClass = class(TDOCMember)
  private
    Fields: TDOCFieldList;   /// List of TDOCField
    Propertys: TDOCPropertyList; /// List of TDOCPropertie
    Methods: TDOCTemplateList; /// List of TDOCMethod
    Events: TDOCEventList;   /// List of TDOCEvent
    Vars: TDOCVarList;  /// List of TDOCVar
    Constants: TDOCConstantList; /// List of TDOCConstant
    Classes: TDOCClassList; /// List of TDOCClass
    function GetMembersCount: integer;
    function GetNestedCount: integer;
    function GetFirstAncestorName: string;
  public
    ClassHierarchyList: TClassHierarchyList; /// Mainly parent class and Interfaces
    ClassDirectivesSet : TClassDirectivesSet; /// Set of directive used in the class
    property FieldList: TDOCFieldList read Fields write Fields;
    property PropertyList: TDOCPropertyList read Propertys write Propertys;
    property MethodList: TDOCTemplateList read Methods write Methods;
    property EventList: TDOCEventList read Events write Events;
    property VarList: TDOCVarList read Vars write Vars;
    property ConstantList: TDOCConstantList read Constants write Constants;
    property ClassList: TDOCClassList read Classes write Classes;
    property NestedCount : integer read GetNestedCount;
    property MembersCount : integer read GetMembersCount;
    property FirstAncestorName : string read GetFirstAncestorName;
    constructor Create(const st: string; const rp: TDOCTemplate); override;
    destructor Destroy; override;
    function CategoryType: TOutputCategoryList; override;
    function GetTemplateName : string; override;
  end;

implementation

uses
  uDocMethod;

{*------------------------------------------------------------------------------
  Call Create to instantiate a TDOCCLass object at runtime.
  Create allocates memory, and then initializes its properties.
  Generally, The owner of this item call create and add the reference in a list

  @param  st  Name of the new Class (mainly its identifier)
  @param  rp  Related logical parent and owner, the unit it written into
-------------------------------------------------------------------------------}
constructor TDOCClass.Create(const st: string; const rp: TDocTemplate);
begin
  inherited;
  ClassHierarchyList := TClassHierarchyList.Create;
  ClassDirectivesSet := [];
  Events    := CreateDocTemplateList(TDOCEventList);
  Fields    := CreateDocTemplateList(TDOCFieldList);
  Methods   := CreateDocTemplateList(TDOCMethodList);
  Propertys := CreateDocTemplateList(TDOCPropertyList);
  Vars      := CreateDocTemplateList(TDOCVarList);
  Constants := CreateDocTemplateList(TDOCConstantList);
  Classes   := CreateDocTemplateList(TDOCClassList);
end;

///  Destroys of an instance of a TDOCCLass object
destructor TDOCClass.Destroy;
begin
  FreeAndNil(Classes);
  FreeAndNil(Constants);
  FreeAndNil(Vars);
  FreeAndNil(Events);
  FreeAndNil(Fields);
  FreeAndNil(Methods);
  FreeAndNil(Propertys);
  FreeAndNil(ClassHierarchyList);
  inherited;
end;

/// Check if template item is required in the output documentation.
function TDOCClass.CategoryType: TOutputCategoryList;
begin
  Result:=ocClasses;
end;

/// Return Field, Method, Event and Property count
function TDOCClass.GetFirstAncestorName: string;
begin
  if(ClassHierarchyList.Count > 0) then Result := ClassHierarchyList.Strings[0]
  else Result:='';
end;

/// Return the number of members in this class (Fields, Properties, Methods, Events)
function TDOCClass.GetMembersCount: integer;
begin
  Result := Fields.Count + Propertys.Count + Methods.Count + Events.Count;
end;

/// Return Class, variable, constant count
function TDOCClass.GetNestedCount: integer;
begin
  Result := Constants.Count + Vars.Count + Classes.Count;
end;

function TDOCClass.GetTemplateName: string;
begin
  Result := 'Class';
end;

end.
