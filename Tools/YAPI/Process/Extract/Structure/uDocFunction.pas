{*------------------------------------------------------------------------------
  Base class to represent functions in Delphi language
  The structure builder will create these objects from the parser informations.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @Version   2006/12/01   TridenT   Extracted from Structure.pas file
-------------------------------------------------------------------------------}

unit uDocFunction;

interface

uses
  Windows, SysUtils, Classes, Contnrs,
  uOptions, uDocMethod;

type
  TDOCFunctionList = TDOCMethodList;   /// List of TDOCFunction
  ///
  /// Specialized TDOCTemplate class for Function structure
  TDOCFunction = class(TDOCMethod) //class(TDocTemplate);
  public
    function CategoryType: TOutputCategoryList; override;
    function GetTemplateName : string; override;
  end;

implementation

//uses

/// Check if template item is required in the output documentation.
function TDOCFunction.CategoryType: TOutputCategoryList;
begin
  Result:=ocFunctions;
end;

function TDOCFunction.GetTemplateName: string;
begin
  Result := 'Function';
end;

end.
