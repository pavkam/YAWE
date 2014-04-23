{*------------------------------------------------------------------------------
  Base class to represent use-units in Delphi language
  The structure builder will create these objects from the parser informations.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @Version   2006/12/01   TridenT   Extracted from Structure.pas file
-------------------------------------------------------------------------------}

unit uDocUseUnit;

interface

uses 
  Windows, SysUtils, Classes, Contnrs,
  TAGComment, uOptions,
  uDocTemplate;

type

  /// Specialized TDOCTemplate class for UseUnit structure
  TDOCUseUnit = class(TDocTemplate)
  public
    ExistFileName: Boolean; /// A filename is associated with the use unit's name
    FileName: TFileName;    /// Use unit's filename (eventually with path)
    function GetTemplateName : string; override;
  end;

implementation

//uses

{ TDOCUseUnit }

function TDOCUseUnit.GetTemplateName: string;
begin
  Result := 'UseUnit';
end;

end.
