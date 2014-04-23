{*------------------------------------------------------------------------------
  Base class to represent events in Delphi language
  The structure builder will create these objects from the parser informations.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @Version   2006/12/01   TridenT   Extracted from Structure.pas file
-------------------------------------------------------------------------------}

unit uDocEvent;

interface

uses
  Windows, SysUtils, Classes, Contnrs,
  uOptions, uDocMember;

type
  
  /// Specialized TDOCMember class for Event structure
  TDOCEvent = class(TDOCMember)
  public
    function CategoryType: TOutputCategoryList; override;
    function GetTemplateName : string; override;
  end;

implementation

//uses

/// Check if template item is required in the output documentation.
function TDOCEvent.CategoryType: TOutputCategoryList;
begin
  Result:=ocEvents;
end;

function TDOCEvent.GetTemplateName: string;
begin
  Result := 'Event';
end;

end.
