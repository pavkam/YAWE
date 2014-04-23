{*------------------------------------------------------------------------------
  Base class to represent Libraries in Delphi language
  The structure builder will create these objects from the parser informations.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @Version   2006/12/01   TridenT   Extracted from Structure.pas file
-------------------------------------------------------------------------------}

unit uDocLibrary;

interface

uses
  Windows, SysUtils, Classes, Contnrs, TAGComment, uOptions,
  uDocTemplate, uDocProgram;
  
type
  /// Specialized TDOCTemplate class for Library structure
  TDOCLibrary = class(TDOCProgram)
  public
    constructor Create(const st: string; const rp: TDocTemplate); override;
    destructor Destroy; override;
    function GetTemplateName : string; override;
  end;

implementation

//uses

{*------------------------------------------------------------------------------
  Call Create to instantiate a TDOCLibrary object at runtime.
  Create allocates memory, and then initializes its properties.
  Generally, The owner of this item call create and add the reference in a list
  @param  st  Name of the new Library (mainly its identifier)
  @param  rp  Related logical parent and owner, generally the global Structure
-------------------------------------------------------------------------------}
constructor TDOCLibrary.Create(const st: string; const rp: TDocTemplate);
begin
  inherited;
end;

/// Destroy a TDOCLibrary instance
destructor TDOCLibrary.Destroy;
begin
  inherited;
end;

function TDOCLibrary.GetTemplateName: string;
begin
  Result := 'Library';
end;

end.
