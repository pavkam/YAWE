{*------------------------------------------------------------------------------
  Base class to represent types in Delphi language
  The structure builder will create these objects from the parser informations.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @Version   2006/12/01   TridenT   Extracted from Structure.pas file
-------------------------------------------------------------------------------}

unit uDocType;

interface

uses
  Windows, SysUtils, Classes, Contnrs, 
  TAGComment, uOptions,
  uDocMember;

type
  /// Specialized TDOCTemplate class for Type structure
  TDOCType = class(TDOCMember)
  public
    function CategoryType: TOutputCategoryList; override;
    function GetTemplateName : string; override;
  end;

implementation

/// Check if template item is required in the output documentation.
function TDOCType.CategoryType: TOutputCategoryList;
begin
  Result:=ocTypes;
end;

function TDOCType.GetTemplateName: string;
begin
  Result := 'Type';
end;

end.
