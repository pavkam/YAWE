{*------------------------------------------------------------------------------
  Base class to represent methods in Delphi language
  The structure builder will create these objects from the parser informations.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @Version   2006/12/01   TridenT   Extracted from Structure.pas file
-------------------------------------------------------------------------------}

unit uDocMethod;

interface

uses
  Windows, SysUtils, Classes, Contnrs,
  TAGComment, uOptions, uDocTemplate, uDocMember, uDocParameter;

type
  /// List of all Binding method Keyword
  TMethodBind    = (mtStatic, mtDynamic, mtVirtual, mtAbstract);
  /// Set of all Binding method Keyword
  TMethodBindSet = set of TMethodBind;
  /// List of all method type Keyword
  TMethodType    = (mtProcedure, mtFunction, mtConstructor, mtDestructor);
  /// List of all method directive keyword (Delphi2005 and dotNET supported)
  TMethodDirectives = (mdExternal, mdPascal, mdSafecall, mdAbstract,
   mdAutomated, mdFar, mdStdcall, mdAssembler, mdInline, mdForward,
   mdVirtual, mdCdecl, mdMessage, mdName, mdRegister, mdDispId,
   mdNear, mdDynamic, mdExport, mdOverride, mdResident, mdLocal, mdOverload,
   mdReintroduce, mdDeprecated, mdLibrary, mdPlatform, mdStatic, mdFinal, mdUnsafe);
  /// Set of all method directive keyword
  TMethodDirectivesSet = set of TMethodDirectives;


  /// Specialized TDOCMember class for Method structure with parameter support
  TDOCMethod = class(TDOCMember)
  private
    Parameters: TDOCParameterList; /// List of parameters in the method
    FOverloadID: WORD; /// Unique ID for overload methods
  protected
    function GetOverloadID: WORD;
    function BuildIdString : string;
  public
    MethodType: TMethodType; /// Internal type of method (constructor, procedure, etc...)
    MethodDirectiveSet: TMethodDirectivesSet; /// Set of directive used in the method
    MethodBind: TMethodBind; /// Binding method
    property ParameterList: TDOCParameterList read Parameters write Parameters;
    property OverloadID : WORD read GetOverloadID;
    constructor Create(const st: string; const rp: TDocTemplate); override;
    destructor Destroy; override;
    function CategoryType: TOutputCategoryList; override;
    function BuildPathName: string; override;
    function GetFileName : string;override;
    function BuildRelativePathName: string; override;
    function GetTemplateName : string; override;
    procedure UpdateTagCoverage; override;
    class function ComputeOverloadID(const IdString : string) : WORD;
  end;

  /// List of TDOCMethod
  TDOCMethodList   = class(TDOCTemplateList)
  public
    function FindItemById(const Id : WORD): TDOCTemplate;
  end;

{gnugettext: scan-all text-domain='DCTD_ignore' }
const
  /// Name of the method type
  MethodeTypeName: array[low(TMethodType)..High(TMethodType)] of string =
    ('Procedure', 'Function', 'Constructor', 'Destructor');  // Constant comment

{gnugettext: reset }

implementation

uses
  JclImports;

{*------------------------------------------------------------------------------
  Call Create to instantiate a TDOCMethod object at runtime.
  Create allocates memory, and then initializes its properties.
  Generally, The owner of this item call create and add the reference in a list

  @param  st  Name of the new Method (mainly its identifier)
  @param  rp  Related logical parent and owner, generally the class it depend
-------------------------------------------------------------------------------}
constructor TDOCMethod.Create(const st: string; const rp: TDocTemplate);
begin
  inherited;
  FOverloadID := 0;
  Parameters := CreateDocTemplateList(TDOCParameterList);
end;

///  Destroys of an instance of a TDOCMethod object
destructor TDOCMethod.Destroy;
begin
  FreeAndNil(Parameters);
  inherited;
end;

/// Build Pathname with CRC inside !
function TDOCMethod.BuildPathName: string;
var
  tmpPathName: string;
begin
  tmpPathName:=inherited BuildPathName;
  Result:=tmpPathName;
end;

/// Build Relative Pathname with CRC inside !
function TDOCMethod.BuildRelativePathName: string;
var
  tmpPathName: string;
begin
  tmpPathName:=inherited BuildRelativePathName;
  Result:=tmpPathName;
end;

{*------------------------------------------------------------------------------
  Check if template item is required in the output documentation.
  @return Category list for a method
-------------------------------------------------------------------------------}
function TDOCMethod.CategoryType: TOutputCategoryList;
begin
  Result:=ocMethods;
end;

function TDOCMethod.GetFileName: string;
var
  tmpName : string;
begin
  tmpName := inherited GetFileName;
  Result:=tmpName+'_'+IntToHex(GetOverloadId,4);
end;

{*------------------------------------------------------------------------------
  Get the unique identifier for this overload function
  @return Unique ID CRC based on declaration (function name, parameters, return)
------------------------------------------------------------------------------*}
function TDOCMethod.GetOverloadID: WORD;
begin
  if FOverloadID <> 0 then Result := FOverloadID
  else
  begin
    Result := ComputeOverloadID(BuildIdString());
    FOverloadID := Result;
  end;
end;

function TDOCMethod.GetTemplateName: string;
begin
  Result := 'Method';
end;


procedure TDOCMethod.UpdateTagCoverage;
var
  IndexParam : integer;
begin
  inherited;
  for IndexParam := 0 to Parameters.Count - 1 do
  begin
    // Method must have a @param TAG for each parameter
    CheckTagCoverage(dtParamTAG, Parameters.Items[IndexParam].Name);  //dtParamTAG
  end;
  // Check also return value for function
  if(self.MethodType = mtFunction) then
   CheckTagCoverage(dtReturnTAG);
end;

{*------------------------------------------------------------------------------
  Build the unique identification string for this method
  It contains information from the declarative part :
   - method name, parameters type, return type,
  @return ResultDescription
------------------------------------------------------------------------------*}
function TDOCMethod.BuildIdString: string;
var
  MethodIdentification : string;
  IndexParam : integer;
begin
  // Add method name
  MethodIdentification := self.name + '(';
  for IndexParam := 0 to Parameters.Count - 1 do
  begin
    if(IndexParam > 0) then MethodIdentification := MethodIdentification + ';';
    // Add parameter name
    MethodIdentification := MethodIdentification + Parameters.Items[IndexParam].Name;
    // Add parameter type
    MethodIdentification := MethodIdentification + ':' + Parameters.Items[IndexParam].RelatedType;
  end;
  MethodIdentification := MethodIdentification + ')';
  // Add function return ?
  Result := UpperCase(MethodIdentification);
end;

class function TDOCMethod.ComputeOverloadID(const IdString : string) : WORD;
var
  pba:PByteArray;
begin
  pba:=PByteArray(@IdString[1]);
  Result:= JclImports.CRC16(pba[0],Length(IdString),0);
end;

{ TDOCMethodList }

function TDOCMethodList.FindItemById(const Id: WORD): TDOCTemplate;
var
  Tmp :  TDOCMethod;
  Index: integer;
begin
  Result := nil;
  Index  := 1;
  while ((Index <= Count) and (Result = nil)) do
  begin
    Tmp := Items[Index - 1] as TDOCMethod;
    if Assigned(Tmp) then
    begin
      if Tmp.GetOverloadID = Id then
      begin
        Result := Tmp
      end
    end;
    Inc(Index);
  end;
end;

end.
