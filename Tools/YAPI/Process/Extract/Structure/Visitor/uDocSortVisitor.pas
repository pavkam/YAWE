{*------------------------------------------------------------------------------
  Sort visitor for TDOCTemplate class
  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
-------------------------------------------------------------------------------}
unit uDocSortVisitor;

interface

uses
  Windows, SysUtils, Classes, Contnrs,
  uDocBaseVisitor, uDocTemplate;

type

  TDOCSortVisitor = class(TDOCBaseVisitor)
  protected
    procedure DoVisit(const DocTemplate : TDOCTemplate);override;
    procedure DoVisit(const DocTemplateList : TDOCTemplateList;
     const DocOwnerList : TDOCTemplate);override;
  public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TDOCVisitor }

constructor TDOCSortVisitor.Create;
begin
  FDeepFirst := False;
end;

destructor TDOCSortVisitor.Destroy;
begin
  inherited;
end;

procedure TDOCSortVisitor.DoVisit(const DocTemplateList: TDOCTemplateList;
 const DocOwnerList : TDOCTemplate);
begin
  // What to do with DocTemplate !
  DocTemplateList.Sort(DocTemplateListSortCompare);
end;

procedure TDOCSortVisitor.DoVisit(const DocTemplate: TDOCTemplate);
begin
  // Nothing
end;

end.
