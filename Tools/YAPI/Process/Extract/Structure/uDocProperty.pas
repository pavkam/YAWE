{*------------------------------------------------------------------------------
  Base class to represent properties in Delphi language
  The structure builder will create these objects from the parser informations.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @Version   2006/12/01   TridenT   Extracted from Structure.pas file
-------------------------------------------------------------------------------}

unit uDocProperty;

interface

uses
  Windows, SysUtils, Classes, Contnrs, TAGComment, uOptions,
  uDocTemplate, uDocMember;

type

  /// Specialized TDOCMember class for Property structure
  TDOCProperty = class(TDOCMember)
  private
    FReadAssessor: TDOCTemplate;  /// The Read accessor
    FWriteAssessor: TDOCTemplate; /// The write accessor
  public
    HasReadSpecifier: boolean;  /// Property has Read keyword in declaration
    HasWriteSpecifier: boolean; /// Property has Write keyword in declaration
    ReadSpecifier: string;      /// Text for the read specifier
    WriteSpecifier: string;     /// Text for the write specifier
    property ReadAssessor : TDOCTemplate read FReadAssessor write FReadAssessor;
    property WriteAssessor : TDOCTemplate read FWriteAssessor write FWriteAssessor;
    constructor Create(const st: string; const rp: TDocTemplate); override;
    function CategoryType: TOutputCategoryList; override;
    function GetTemplateName : string; override;
  end;

implementation

//uses

{*------------------------------------------------------------------------------
  Call Create to instantiate a TDOCProperty object at runtime.
  Create allocates memory, and then initializes its properties.
  Generally, The owner of this item call create and add the reference in a list
  @param  st  Name of the new Property (mainly its identifier)
  @param  rp  Related logical parent and owner, generally the Class it depends
-------------------------------------------------------------------------------}
constructor TDOCProperty.Create(const st: string; const rp: TDocTemplate);
begin
  inherited;
  HasReadSpecifier:=false;
  HasWriteSpecifier:=false;
end;

function TDOCProperty.GetTemplateName: string;
begin
  Result := 'Property';
end;

/// Check if template item is required in the output documentation.
function TDOCProperty.CategoryType: TOutputCategoryList;
begin
  Result:=ocProperties;
end;


end.
