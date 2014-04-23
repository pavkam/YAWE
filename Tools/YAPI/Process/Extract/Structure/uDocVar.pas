{*------------------------------------------------------------------------------
  Base class to represent variables in Delphi language
  The structure builder will create these objects from the parser informations.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @Version   2006/12/01   TridenT   Extracted from Structure.pas file
-------------------------------------------------------------------------------}

unit uDocVar;

interface

uses
  Windows, SysUtils, Classes, Contnrs,
  uOptions, uDocMember;

type
  
  /// Specialized TDOCTemplate class for Class structure
  TDOCVar = class(TDOCMember)
  public
    function CategoryType: TOutputCategoryList; override;
    function GetTemplateName : string; override;
  end;

implementation

//uses

/// Check if template item is required in the output documentation.
function TDOCVar.CategoryType: TOutputCategoryList;
begin
  Result:=ocVariables;
end;

function TDOCVar.GetTemplateName: string;
begin
  Result := 'Variable';
end;

end.
