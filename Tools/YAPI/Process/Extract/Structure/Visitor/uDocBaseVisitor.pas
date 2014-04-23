{*------------------------------------------------------------------------------
  Base visitor for TDOCTemplate class
  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
-------------------------------------------------------------------------------}
unit uDocBaseVisitor;

interface

uses
  Windows, SysUtils, Classes, Contnrs,
  uDocTemplate;

type

  TDOCBaseVisitor = class
  private
    procedure FVisitDocTemplate(const DocTemplate : TDOCTemplate);
    procedure FVisitAllNestedList(const DocTemplate: TDOCTemplate);
    procedure FVisitDocTemplateList(const DocTemplateList : TDocTemplateList;
     const DocOwnerList : TDOCTemplate);
  protected
    FDeepFirst : boolean;
    procedure AfterFullVisit;virtual;
    procedure BeforeFullVisit;virtual;
    procedure DoVisit(const DocTemplate : TDOCTemplate);overload;virtual;abstract;
    procedure DoVisit(const DocTemplateList : TDOCTemplateList;
     const DocOwnerList : TDOCTemplate);overload;virtual;abstract;
    procedure BeforeVisit(const DocTemplate : TDOCTemplate);overload;virtual;
    procedure BeforeVisit(const DocTemplateList : TDOCTemplateList;
     const DocOwnerList : TDOCTemplate);overload;virtual;
    procedure AfterVisit(const DocTemplate : TDOCTemplate);overload;virtual;
    procedure AfterVisit(const DocTemplateList : TDOCTemplateList;
     const DocOwnerList : TDOCTemplate);overload;virtual;
  public
    constructor Create;virtual;
    destructor Destroy;override;
    procedure Visit(const DocTemplate: TDOCTemplate);overload;
    procedure Visit(const DocTemplateList: TDOCTemplateList;
     const DocOwnerList : TDOCTemplate);overload;
  end;

implementation

procedure TDOCBaseVisitor.AfterFullVisit;
begin
  // Empty
end;

procedure TDOCBaseVisitor.AfterVisit(const DocTemplate: TDOCTemplate);
begin
  // Empty
end;

procedure TDOCBaseVisitor.AfterVisit(const DocTemplateList: TDOCTemplateList;
  const DocOwnerList: TDOCTemplate);
begin
  // Empty
end;

procedure TDOCBaseVisitor.BeforeFullVisit;
begin
  // Empty
end;

procedure TDOCBaseVisitor.BeforeVisit(const DocTemplate: TDOCTemplate);
begin
  // Empty
end;

procedure TDOCBaseVisitor.BeforeVisit(const DocTemplateList: TDOCTemplateList;
  const DocOwnerList: TDOCTemplate);
begin
  // Empty
end;

constructor TDOCBaseVisitor.Create;
begin
  //
  FDeepFirst := False;
end;

destructor TDOCBaseVisitor.Destroy;
begin
  inherited;
end;

procedure TDOCBaseVisitor.Visit(const DocTemplate: TDOCTemplate);
begin
  BeforeFullVisit;
  FVisitDocTemplate(DocTemplate);
  AfterFullVisit;
end;

procedure TDOCBaseVisitor.Visit(const DocTemplateList: TDOCTemplateList;
 const DocOwnerList : TDOCTemplate);
begin
  BeforeFullVisit;
  FVisitDocTemplateList(DocTemplateList, DocOwnerList);
  AfterFullVisit;
end;

procedure TDOCBaseVisitor.FVisitDocTemplate(const DocTemplate: TDOCTemplate);
begin
  assert(assigned(DocTemplate));
  BeforeVisit(DocTemplate);
  // Visit nested before
  if(FDeepFirst = True) then FVisitAllNestedList(DocTemplate);
  // Visit the Template
  DoVisit(DocTemplate);
  // And then nested
  if(FDeepFirst = False) then FVisitAllNestedList(DocTemplate);
  AfterVisit(DocTemplate);
end;

procedure TDOCBaseVisitor.FVisitDocTemplateList(const DocTemplateList: TDocTemplateList;
 const DocOwnerList : TDOCTemplate);
var
  DocTemplateIndex : integer;
begin
    BeforeVisit(DocTemplateList, DocOwnerList);
    if(FDeepFirst = False) then DoVisit(DocTemplateList, DocOwnerList);
    // Apply visitor for all items
    for DocTemplateIndex := 0 to DocTemplateList.Count - 1 do
    begin
      FVisitDocTemplate(DocTemplateList.Items[DocTemplateIndex]);
    end;
    if(FDeepFirst = True) then DoVisit(DocTemplateList, DocOwnerList);
    AfterVisit(DocTemplateList, DocOwnerList);
end;

procedure TDOCBaseVisitor.FVisitAllNestedList(const DocTemplate: TDOCTemplate);
var
  DocTemplateListIndex : integer;
begin
  for DocTemplateListIndex := 0 to DocTemplate.TemplateListList.Count - 1 do
  begin
    FVisitDocTemplateList(DocTemplate.TemplateListList.Items[DocTemplateListIndex] as TDOCTemplateList,
     DocTemplate);
  end;
end;

end.
