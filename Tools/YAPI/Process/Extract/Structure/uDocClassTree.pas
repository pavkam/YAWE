{*------------------------------------------------------------------------------
  Create the tree with all classes from the structure builder
  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2006/10/17   TridenT   Initial revision
-------------------------------------------------------------------------------}
unit uDocClassTree;

interface

uses
  // System uses
  Windows, SysUtils, Classes, Contnrs,
  // Project uses
  uDocTemplate, uDocClass;

type
  TDOCClassNode = class; // Forward

  /// Iterator event (callback)
  TIterateClassNodes = procedure(const CurrentClassNodeNode : TDOCClassNode) of object;

  /// A node representing a class and containing link to TDOCClass
  TDOCClassNode = class(TObjectList)
  private
    FName : string; /// Name of class node
    FNestedLevel : integer; /// Nested level of node (0 if no parent)
    FParentNode : TDOCClassNode; /// Parent's node
  protected
    // TODO 3 -oTridenT -cEnhancement : Add DeepFirst option ?
    procedure DoIterate;
    class var FIterateEvent : TIterateClassNodes; /// DO NOT ADD THINGS AFTER (ClassVar)
  public
    DocClassLink : TDOCClass; /// Link to the TDOCClass object
    property Name : string read FName;
    property NestedLevel : integer read FNestedLevel;
    property ParentNode : TDOCClassNode read FParentNode;
    constructor Create(const AParentNode : TDOCClassNode; const AName : string);overload;
    procedure ChangeParent(const AOldParent : TDOCClassNode; const ANewParent : TDOCClassNode);
    function FindItemByName(const ClassName : string) : TDOCClassNode;
  end;

  /// Tree with all classes linked childs/ancestors
  TDOCClassesTree = class(TDOCTemplate)
  private
    FRootNode : TDOCClassNode; /// Root node of hte tree
    FNodeTObject : TDOCClassNode; /// TObject node
    FNodeOrphanClass : TDOCClassNode; /// Orphan classes 'root' node
  protected
    function AddChild(const Parent : TDOCClassNode; const Name : string) : TDOCClassNode;
    function GetCount: integer;
    procedure ChangeParentNode(const ANode : TDOCClassNode; const NewParent : TDOCClassNode);
    function LinkOrphanedChildsOnePass : integer;
  public
    property NodeTObject : TDOCClassNode read FNodeTObject;
    property NodeOrphanClass : TDOCClassNode read FNodeOrphanClass;
    property Count : integer read GetCount;
    constructor Create(const st: string; const rp: TDocTemplate);override;
    procedure AddDocClass(const DocClass : TDOCClass);
    function FindNodeByName(const ClassName : string) : TDOCClassNode;
    function FindClassByName(const ClassName : string) : TDOCClass;
    procedure LinkOrphanedChilds;
    procedure Clear;
    procedure Iterate(const IterateEvent : TIterateClassNodes);
  end;

implementation

{ TDOCClassesTree }

{*------------------------------------------------------------------------------
  Create and add a child to the tree
  @param Parent   Parent of this item
  @param Name   Child name
  @return Return the newly created node
------------------------------------------------------------------------------*}
function TDOCClassesTree.AddChild(const Parent: TDOCClassNode;
  const Name: string): TDOCClassNode;
begin
  Result := TDOCClassNode.Create(Parent, Name);
  if assigned(Parent) then Parent.Add(Result)
  else FRootNode.Add(Result);
end;

{*------------------------------------------------------------------------------
  Create a node representing the class parameter and Add it to the ClassesTree
  If perent is not found inside the tree (further call), ths item will be added
   under the 'Orphans' node
  @param DocClass   TDOCClass object to add
------------------------------------------------------------------------------*}
procedure TDOCClassesTree.AddDocClass(const DocClass: TDOCClass);
var
  ClassAncestorNode : TDOCClassNode;
  NewClassNode : TDOCClassNode;
  AncestorClassName : string;
begin
  // Get ancestor' name
  AncestorClassName := DocClass.FirstAncestorName;
  // Find if ancestor name already exists
  ClassAncestorNode := FindNodeByName(AncestorClassName);
  if not assigned(ClassAncestorNode) then ClassAncestorNode := NodeOrphanClass;
  // if so, add class to ancestor childs
  // else, add ancestor with child
  NewClassNode := AddChild(ClassAncestorNode, DocClass.Name);
  NewClassNode.DocClassLink := DocClass;
end;

{*------------------------------------------------------------------------------
  Change parent for the parameter node
  @param ANode   Node to change parent
  @param NewParent   New parent to link this node
------------------------------------------------------------------------------*}
procedure TDOCClassesTree.ChangeParentNode(const ANode,
  NewParent: TDOCClassNode);
var
  OldParentNode : TDOCClassNode;
begin
  OldParentNode := ANode.ParentNode;
  NewParent.Add(ANode);
  // Old node is extracted (not removed!!!) without freeing it.
  OldParentNode.Extract(ANode);
  ANode.ChangeParent(OldParentNode, NewParent);
end;

/// Clear the Tree
procedure TDOCClassesTree.Clear;
begin
  FNodeTObject.Clear;
  FNodeOrphanClass.Clear;
end;

constructor TDOCClassesTree.Create(const st: string; const rp: TDocTemplate);
begin
  inherited;
  FRootNode := TDOCClassNode.Create(nil, '#ROOT#');
  FNodeTObject := AddChild(nil,'TObject') as TDOCClassNode;
  FNodeTObject.DocClassLink := nil;
  FNodeTObject := AddChild(nil,'IInterface') as TDOCClassNode;
  FNodeTObject.DocClassLink := nil;
  FNodeOrphanClass := AddChild(nil,'#OrphanClass#') as TDOCClassNode;
  FNodeTObject.DocClassLink := nil;  
end;

{*------------------------------------------------------------------------------
  Search a class by its name
  @param ClassName   Name of the class to search
  @return TDOCClass object if class found, nil otherwise
------------------------------------------------------------------------------*}
function TDOCClassesTree.FindClassByName(const ClassName: string): TDOCClass;
var
  FoundClassNode : TDOCClassNode;
begin
  FoundClassNode := FindNodeByName(ClassName);
  if assigned(FoundClassNode) then Result := FoundClassNode.DocClassLink
  else Result := nil;
end;

{*------------------------------------------------------------------------------
  Find an specific class node by its name
  @param ClassName   Name of the class to search
  @return TDOCClassNode object if node found, nil otherwise
------------------------------------------------------------------------------*}
function TDOCClassesTree.FindNodeByName(
  const ClassName: string): TDOCClassNode;
var
  ChildIndex : integer;
  bItemFound : Boolean;
  ChildNode : TDOCClassNode;
begin
  ChildIndex := 0;
  bItemFound := False;
  Result := nil;

  while((ChildIndex < Count) and (bItemFound = False)) do
  begin
    // Search inside child
    ChildNode := FRootNode.Items[ChildIndex] as TDOCClassNode;
    Result := ChildNode.FindItemByName(ClassName);
    if assigned(Result) then bItemFound := True;
    Inc(ChildIndex);
  end;
end;

/// Return the number of direct child nodes
function TDOCClassesTree.GetCount: integer;
begin
  Result := FRootNode.Count;
end;

{*------------------------------------------------------------------------------
  Iterate all nodes with a specific event
  @param IterateEvent   Event to apply to each node
------------------------------------------------------------------------------*}
procedure TDOCClassesTree.Iterate(const IterateEvent: TIterateClassNodes);
begin
  if assigned(IterateEvent) then
  begin
    TDOCClassNode.FIterateEvent := IterateEvent;
    FRootNode.DoIterate;
    TDOCClassNode.FIterateEvent := nil;
  end;
end;

/// Link all orphaned childs if possible
procedure TDOCClassesTree.LinkOrphanedChilds;
var
  ChildNodeMoved : integer;
begin
  repeat
    ChildNodeMoved := LinkOrphanedChildsOnePass;
  until(ChildNodeMoved = 0);
end;

{*------------------------------------------------------------------------------
  Do one flat-pass to link orphans node
  @return Number of orphans newly linked
------------------------------------------------------------------------------*}
function TDOCClassesTree.LinkOrphanedChildsOnePass: integer;
var
  ClassNodeRelinked : integer;
  OrphanClassNode : TDOCClassNode;
  ParentClassNode : TDOCClassNode;
  ImmediateChildIndex : integer;
begin
  ClassNodeRelinked := 0;
  ImmediateChildIndex := 0;
  // Get first orphan child
  while(ImmediateChildIndex < NodeOrphanClass.Count) do
  begin
    // Search inside root
    OrphanClassNode := NodeOrphanClass.Items[ImmediateChildIndex] as TDOCClassNode;
    assert(assigned(OrphanClassNode.DocClassLink));
    ParentClassNode := FRootNode.FindItemByName(OrphanClassNode.DocClassLink.FirstAncestorName);
    // if found, link this new child
    if assigned(ParentClassNode) then
    begin
      // Add this child to Parent
      // Delete child from old parent
      ChangeParentNode(OrphanClassNode, ParentClassNode);
      Inc(ClassNodeRelinked);
    end
    else
    begin
      // continue with another
      Inc(ImmediateChildIndex);
    end;
  end;
  Result := ClassNodeRelinked;
end;

{ TDOCClassNode }

{*------------------------------------------------------------------------------
  Change the parent of a node
  @param AOldParent   Old parent
  @param ANewParent   New parent
------------------------------------------------------------------------------*}
procedure TDOCClassNode.ChangeParent(const AOldParent,
  ANewParent: TDOCClassNode);
begin
  FParentNode := ANewParent;
  if assigned(FParentNode) then FNestedLevel := FParentNode.NestedLevel + 1
  else FNestedLevel := 0;
end;

/// Iterate a node and childs
procedure TDOCClassNode.DoIterate;
var
  ChildIndex : Integer;
  ChildNode : TDocClassNode;
begin
  if assigned(FIterateEvent) then FIterateEvent(self);
  for ChildIndex := 0 to Count - 1 do
  begin
    // Search inside child
    ChildNode := Items[ChildIndex] as TDOCClassNode;
    ChildNode.DoIterate;
  end;
end;

{*------------------------------------------------------------------------------
  Create a new class node and assign parent
  @param AParentNode   Parent of this new node
  @param AName   Name
------------------------------------------------------------------------------*}
constructor TDOCClassNode.Create(const AParentNode : TDOCClassNode; const AName : string);
begin
  self.Create(True);
  FName := AName;
  DocClassLink := nil;
  FParentNode := AParentNode;
  if assigned(FParentNode) then FNestedLevel := FParentNode.NestedLevel + 1
  else FNestedLevel := 0;
end;

// TODO -oTridenT -cRefactoring : Merge it this DocTemplateList ?
{*------------------------------------------------------------------------------
  Find item in the tree by its name
  @param ClassName   Name of class node to search
  @return TDOCClassNode object if found, nil otherwise  
------------------------------------------------------------------------------*}
function TDOCClassNode.FindItemByName(
  const ClassName: string): TDOCClassNode;
var
  ChildIndex : integer;
  bItemFound : Boolean;
  ChildNode : TDOCClassNode;
begin
  ChildIndex := 0;
  bItemFound := False;
  Result := nil;

  if SameText(Self.Name, ClassName) then
  begin
    Result := Self;
    bItemFound := True;
  end;
  
  while((ChildIndex < Count) and (bItemFound = False)) do
  begin
    // Search inside child
    ChildNode := self.Items[ChildIndex] as TDOCClassNode;
    Result := ChildNode.FindItemByName(ClassName);
    if Result<>nil then bItemFound := True;
    Inc(ChildIndex);
  end;
end;

end.
