{*------------------------------------------------------------------------------
  Base class to represent (method's) parameters in Delphi language
  The structure builder will create these objects from the parser informations.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @Version   2006/12/01   TridenT   Extracted from Structure.pas file
-------------------------------------------------------------------------------}

unit uDocParameter;

interface

uses
  Windows, SysUtils, Classes, Contnrs,
  uDocTemplate;

type
  // TODO 2 -oTridenT -cEnhancement : Add var and const keyword
  /// Specialized TDOCTemplate class for Parameter structure
  TDOCParameter = class(TDOCTemplate)
    function GetTemplateName : string; override;
    procedure UpdateTagCoverage; override;
  end;

implementation

function TDOCParameter.GetTemplateName: string;
begin
  Result := 'Parameter';
end;

procedure TDOCParameter.UpdateTagCoverage;
begin
  // Parameters don't have description, they are describe with the
  // @param tag in methods or functions.
  // Do not even call inherited method
  //inherited;

end;

end.
