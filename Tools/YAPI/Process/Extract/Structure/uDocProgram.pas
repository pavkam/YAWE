{*------------------------------------------------------------------------------
  Base class to represent program in Delphi language
  The structure builder will create these objects from the parser informations.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @Version   2006/12/01   TridenT   Extracted from Structure.pas file
-------------------------------------------------------------------------------}

unit uDocProgram;

interface

uses
  Windows, SysUtils, Classes, Contnrs, TAGComment, uOptions,
  uDocTemplate, uDocUnit;

type

  /// Specialized TDOCTemplate class for Program structure
  TDOCProgram = class(TDOCUnit)
  private
    UseUnits: TDOCUseUnitList; /// List of TDOCUseUnits
  public
    property UseUnitList: TDOCUseUnitList read UseUnits write UseUnits;
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
constructor TDOCProgram.Create(const st: string; const rp: TDocTemplate);
begin
  inherited;
  UseUnits := CreateDocTemplateList(TDOCTemplateList);
end;

/// Destroy the TDOCProgram instance
destructor TDOCProgram.Destroy;
begin
  FreeAndNil(UseUnits);
  inherited;
end;

function TDOCProgram.GetTemplateName: string;
begin
  Result := 'Program';
end;

end.
