{*------------------------------------------------------------------------------
  Base visitor for TDOCTemplate class
  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
-------------------------------------------------------------------------------}
unit uDocToNodesVisitor;

interface

uses
  Windows, SysUtils, Classes, Contnrs,
  uDocBaseVisitor, uDocTemplate;

type
  { TODO 2 -oTridenT -cEnhancement : Add filter on nodes to visit, add a ContinueVisit boolean in DocTemplateList }
  TDOCToNodesVisitor = class(TDOCBaseVisitor)
  private
    DocTemplateNodes : TObject; // TTreeNodes
    DocTemplateStack : TObjectStack;
  protected
    procedure BeforeFullVisit;override;
    procedure DoVisit(const DocTemplate : TDOCTemplate);override;
    procedure DoVisit(const DocTemplateList : TDOCTemplateList;
     const DocOwnerList : TDOCTemplate);override;
  public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

uses
  uDocParameter;

{ TDOCVisitor }

{**
 * @throw Custom visitor exception
 *}
procedure TDOCToNodesVisitor.BeforeFullVisit;
begin
  //
  if not assigned (DocTemplateNodes) then
   Exception.Create('DocTemplateNodes not assigned');
end;

constructor TDOCToNodesVisitor.Create;
begin
  FDeepFirst := False;
  DocTemplateNodes := nil;
  DocTemplateStack := TObjectStack.Create;
end;

destructor TDOCToNodesVisitor.Destroy;
begin
  //
  DocTemplateStack.Free;
  inherited;
end;

procedure TDOCToNodesVisitor.DoVisit(const DocTemplateList: TDOCTemplateList;
 const DocOwnerList : TDOCTemplate);
begin
  // Nothing
end;

procedure TDOCToNodesVisitor.DoVisit(const DocTemplate: TDOCTemplate);
var
  //DocNodes : TTreeNodes;
  //Parent : TTreeNode;
  //NewNode : TTreeNode;
  NewText : string;
  SelfRatio, TotalRatio : Double;
begin
  // Skip parameters !
  if(DocTemplate is TDOCParameter) then exit;

  //DocNodes := DocTemplateNodes as TTreeNodes;
  // Get parent
  //repeat
  //  Parent := nil;
  //  if DocTemplateStack.Count > 0 then Parent := DocTemplateStack.Peek as TTreeNode;
  //  if assigned(Parent) then
  //  begin
 //     if ((Parent as TTreeNode).Data <> DocTemplate.RelatedParent) then
 //     begin
 //      DocTemplateStack.Pop as TTreeNode;
 //      Parent := nil;
 //     end;
 //   end;
  //until((DocTemplateStack.Count = 0) or assigned(Parent));
  SelfRatio := DocTemplate.TagCoverageHolder.SelfStats.GetDocumentedTagRatio;
  TotalRatio := DocTemplate.TagCoverageHolder.TotalStats.GetDocumentedTagRatio;
  NewText := Format('%s %s (Self = %.1f%%  Total = %.1f%%)',[DocTemplate.GetTemplateName,
   DocTemplate.Name, SelfRatio, TotalRatio ]);
  //NewNode := DocNodes.AddChildObject(Parent, NewText, DocTemplate);
  //DocTemplateStack.Push(NewNode);
end;

end.
