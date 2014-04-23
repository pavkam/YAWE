{*------------------------------------------------------------------------------
  Represents a namespace. (c) PavkaM
-------------------------------------------------------------------------------}

unit uDocNamespace;
interface

uses
  Windows, SysUtils, Classes, Contnrs, TAGComment, uOptions,
  uDocTemplate, uDocUnit;

type

  /// Specialized TDOCTemplate class for Program structure
  TDOCNamespace = class(TDOCTemplate)
  private
    IncludeUnits : TDOCUseUnitList; /// List of TDOCUseUnits
  public
    property IncludeUnitList: TDOCUseUnitList read IncludeUnits write IncludeUnits;

    constructor Create(const st: string; const rp: TDocTemplate); override;
    destructor Destroy; override;
    function GetTemplateName : string; override;
  end;

implementation

{*------------------------------------------------------------------------------
  Call Create to instantiate a TDOCProgram object at runtime.
  Create allocates memory, and then initializes its properties.
  Generally, The owner of this item call create and add the reference in a list
  @param  st  Name of the new Program (mainly its identifier)
  @param  rp  Related logical parent and owner, generally the global Structure
-------------------------------------------------------------------------------}
constructor TDOCNamespace.Create(const st: string; const rp: TDocTemplate);
begin
  inherited;
  IncludeUnits := CreateDocTemplateList(TDOCTemplateList);
end;

/// Destroy the TDOCProgram instance
destructor TDOCNamespace.Destroy;
begin
  FreeAndNil(IncludeUnits);
  inherited;
end;

function TDOCNamespace.GetTemplateName: string;
begin
  Result := 'Namespace';
end;

end.
