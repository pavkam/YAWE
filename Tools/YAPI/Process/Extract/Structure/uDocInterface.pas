{*------------------------------------------------------------------------------
  Base class to represent interfaces in Delphi language
  The structure builder will create these objects from the parser informations.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @Version   2006/12/01   TridenT   Extracted from Structure.pas file
-------------------------------------------------------------------------------}

unit uDocInterface;

interface

uses
  Windows, SysUtils, Classes, Contnrs, TAGComment, uOptions,
  uDocClass;

type

  /// Specialized TDOCClass for Interface structure
  TDOCInterface = class(TDOCClass)
  public
    function CategoryType: TOutputCategoryList; override;
    function GetTemplateName : string; override;
  end;

implementation

//uses

/// Check if template item is required in the output documentation.
function TDOCInterface.CategoryType: TOutputCategoryList;
begin
  Result:=ocClasses;
end;


function TDOCInterface.GetTemplateName: string;
begin
  Result := 'Interface';
end;

end.
