{*------------------------------------------------------------------------------
  Base class to represent fields in Delphi language
  The structure builder will create these objects from the parser informations.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @Version   2006/12/01   TridenT   Extracted from Structure.pas file
-------------------------------------------------------------------------------}

unit uDocField;

interface

uses
  Windows, SysUtils, Classes, Contnrs,
  uOptions, uDocMember;

type
  
  /// Specialized TDOCMember class for Field structure
  TDOCField = class(TDOCMember)
  public
    function CategoryType: TOutputCategoryList; override;
    function GetTemplateName : string; override;
  end;

implementation

//uses

/// Check if template item is required in the output documentation.
function TDOCField.CategoryType: TOutputCategoryList;
begin
  Result:=ocFields;
end;

function TDOCField.GetTemplateName: string;
begin
  Result := 'Field';
end;

end.
