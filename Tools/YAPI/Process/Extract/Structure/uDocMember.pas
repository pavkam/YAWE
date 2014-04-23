{*------------------------------------------------------------------------------
  Base class to represent generic member in Delphi language
  The structure builder will create these objects from the parser informations.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @Version   2006/12/01   TridenT   Extracted from Structure.pas file
-------------------------------------------------------------------------------}

unit uDocMember;

interface

uses Windows, SysUtils, Classes, Contnrs
  , uOptions, uDocTemplate;

type
  
  /// Specialized TDOCTemplate class for Member structure
  TDOCMember = class(TDOCTemplate)
  public
    MemberVisibility: TMemberVisibility; /// Visibility of the Member
    StrictVisibility: Boolean; /// Strict visibility (apply only for private and public)
    IsClassMember: Boolean; /// Is it an object member or a class member
    constructor Create(const st: string; const rp: TDocTemplate); override;
    function GetTemplateName : string; override;
  end;

var
  /// List of Named visibility for Member used in members list
  MemberVisibilityName: TStringList;

{gnugettext: scan-all text-domain='DCTD_ignore' }
const
  /// Symbol of all member visiblity
  MemberVisibilitySymbol: array[low(TMemberVisibility)..High(TMemberVisibility)]
    of string = ('-', '#', '+', '*', 'A');
  MemberVisibilityClass: array[low(TMemberVisibility)..High(TMemberVisibility)]
    of string = ('VisPrivate', 'VisProtected', 'VisPublic', 'VisPublished', 'VisAutomated');

  StrictVisibilitySymbol : string = 'S';
{gnugettext: reset }

implementation

constructor TDOCMember.Create(const st: string; const rp: TDocTemplate);
begin
  inherited;
  MemberVisibility := mvPublic;
end;

function TDOCMember.GetTemplateName: string;
begin
  Result := '#Unused DocMember#';
end;

initialization
  // Add member visibility text name in a StringList
  MemberVisibilityName := TStringList.Create;
  MemberVisibilityName.Add('PRIVATE');
  MemberVisibilityName.Add('PROTECTED');
  MemberVisibilityName.Add('PUBLIC');
  MemberVisibilityName.Add('PUBLISHED');
  MemberVisibilityName.Add('AUTOMATED');

finalization
  FreeAndNil(MemberVisibilityName);
  
end.
