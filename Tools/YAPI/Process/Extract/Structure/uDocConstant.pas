{*------------------------------------------------------------------------------
  Base class to represent constants in Delphi language
  The structure builder will create these objects from the parser informations.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @Version   2006/12/01   TridenT   Extracted from Structure.pas file
-------------------------------------------------------------------------------}

unit uDocConstant;

interface

uses
  Windows, SysUtils, Classes, Contnrs, 
  TAGComment, uOptions,
  uDocMember;

type
  
  /// Specialized TDOCTemplate class for Constant structure
  TDOCConstant = class(TDOCMember)
  public
    function CategoryType: TOutputCategoryList; override;
    function GetTemplateName : string; override;
  end;

implementation

/// Check if template item is required in the output documentation.
function TDOCConstant.CategoryType: TOutputCategoryList;
begin
  Result:=ocConstants;
end;

function TDOCConstant.GetTemplateName: string;
begin
  Result := 'Constant';
end;

end.
