{*------------------------------------------------------------------------------
  Base class to represent units in Delphi language
  The structure builder will create these objects from the parser informations.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @Version   2006/12/01   TridenT   Extracted from Structure.pas file
-------------------------------------------------------------------------------}

unit uDocUnit;

interface

uses
  Windows, SysUtils, Classes, Contnrs, TAGComment, uOptions,
  uDocTemplate;
  
type

  /// Specialized TDOCTemplate class for Unit structure
  TDOCUnit = class(TDOCTemplate)
  private
    FFileName: TFilename;     /// Related Filename of the unit, generaly 'UnitName.pas' or 'ProgName.dpr'
    Classes: TDOCClassList; /// List of TDOCClasses
    Types: TDOCTypeList;  /// List of TDOCTypes
    Constants: TDOCConstantList;  /// oList f TDOCConst
    Vars: TDOCVarList;    /// List of TDOCInterface
    Functions: TDOCTemplateList; /// List of TDOCFunction
    FFlatClasses : TDOCClassList; /// Flat classes representation for this unit
    FExportsList: TStringList;  /// List of exported functions (appears in Unit, Program or Library)
  public
    property Filename: TFilename read FFilename write FFilename;
    property VarList : TDOCVarList read Vars write Vars;
    property TypeList : TDOCTypeList read Types write Types;
    property ConstantList : TDOCConstantList read Constants write Constants;
    property FunctionList : TDOCTemplateList read Functions write Functions;
    property ClassList : TDOCClassList read Classes write Classes;
    property FlatClassList : TDOCClassList read FFlatClasses write FFlatClasses;
    property ExportsList: TStringList Read FExportsList write FExportsList;
    constructor Create(const st: string; const rp: TDocTemplate); override;
    destructor Destroy; override;
    function GetTemplateName : string; override;
  end;
  
implementation

uses
  uDocClass, uDocFunction;

{*------------------------------------------------------------------------------
  Call Create to instantiate a TDOCUnit object at runtime.
  Create allocates memory, and then initializes its properties.
  Generally, The owner of this item call create and add the reference in a list

  @param  st  Name of the new Unit (mainly its identifier)
  @param  rp  Related logical parent and owner, generally the Structure it self
-------------------------------------------------------------------------------}
constructor TDOCUnit.Create(const st: string; const rp: TDocTemplate);
begin
  inherited;
  Classes   := CreateDocTemplateList(TDOCClassList);
  Constants := CreateDocTemplateList(TDOCConstantList);
  Types     := CreateDocTemplateList(TDOCTypeList);
  Vars      := CreateDocTemplateList(TDOCVarList);
  Functions := CreateDocTemplateList(TDOCFunctionList) as TDOCFunctionList;
  FFlatClasses := TDOCClassList.Create(False);
  FExportsList:=TStringList.Create;
end;

///  Destroys of an instance of a TDOCUnit object
destructor TDOCUnit.Destroy;
begin
  FreeAndNil(FExportsList);
  FreeAndNil(FFlatClasses);
  FreeAndNil(Classes);
  FreeAndNil(Constants);
  FreeAndNil(Types);
  FreeAndNil(Vars);
  FreeAndNil(Functions);
  inherited;
end;

function TDOCUnit.GetTemplateName: string;
begin
  Result := 'Unit';
end;

end.
