{*------------------------------------------------------------------------------
  Module that centralize all TAG based comments.
  All TAG patterns are describe in this unit.
  JavaDoc is for the moment the only TAG type.
  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   Initial revision
  @Version   2004/09/12   TridenT   Added @throws TAG
  @version   2004/27/10   TridenT   Added @Comment TAG
-------------------------------------------------------------------------------}
unit TagComment;

interface

uses
  Classes, SysUtils, Tokens, Contnrs, ParseTreeNodeType;

type
  TDOCTag = (dtDescriptionTAG, dtAuthorTAG, dtChangesTAG, dtDocsTAG, dtVersionTAG
    , dtTodoTAG, dtParamTAG, dtReturnTAG, dtSeeTAG, dtThrowsTAG
    , dtAdditionalCommentTAG);

  /// The content of a TAG is a multiline text
  TTAGContent = TStringList;

  /// SubTAG is the TAG content and the identifier it is linked
  TSubTAG = class
  private
    FTAGContent: TTAGContent;  /// The multiline description of SubTAG
    FTAGContentID: string;     /// The identifier of SubTAG
  public
    property GetContent: TTAGContent Read FTAGContent;
    constructor Create(const tcID: string);
    destructor Destroy; override;
  end;

  /// Base class for TSubTAG containers
  TSubTAGList = class(TObjectList)
  protected
    function GetItem(const Index: integer): TSubTAG;
    procedure SetItem(const Index: integer; const item: TSubTAG);
  public
    property Items[const Index: integer]: TSubTAG Read GetItem Write SetItem; default;
    function FindItemByName(const st: string): TSubTAG;
    function GetFirst: TSubTAG;
    function GetContent(const st: string): TTAGContent;
    procedure AddSubTAGLine(const msg: string; stID: string);
  end;

  /// Represents a JavaDoc TAG complete description
  TTAGPattern = class
  private
    FSourceCode: string;
    FTAGType: TCommentStyle;
    FTNType: TParseTreeNodeType;
  public
    property SourceCode: string Read FSourcecode;
    property TAGType: TCommentStyle Read FTAGType;
    constructor Create(const sc: string; const tt: TCommentStyle;
      const nt: TParseTreeNodeType);
  end;

  /// List of all JavaDoc TAGs
  TTAGPatternList = class(TObjectList)
  protected
    function GetItem(const Index: integer): TTAGPattern;
    procedure SetItem(const Index: integer; const item: TTAGPattern);
  public
    property Items[const Index: integer]: TTAGPattern Read GetItem Write SetItem;
      default;
    function RegisterTAG(const sc: string; const TAGtype: TCommentStyle;
      const NodeType: TParseTreeNodeType): TTAGPattern;
    function FindItemByName(const st: string): TTAGPattern;
    function FindItemByStyle(const stype: TCommentStyle): TTAGPattern;
    function FindItemByNodeType(const ntype: TParseTreeNodeType): TTAGPattern;
    function FindItemByDocTag(const DocTag: TDocTag): TTAGPattern;
  end;


  /// Description of a TAG type
  TTAGHolderListItem = class
  private
    FTAGItem: TTAGPattern;
    FSubTAGList: TSubTAGList;
  public
    property TAGItem: TTAGPattern Read FTAGItem Write FTAGItem;
    property SubTAGList: TSubTAGList Read FSubTAGList Write FSubTAGList;
    constructor Create(const tp: TTAGPattern);
    destructor Destroy; override;
    procedure AddSubTAG(const msg: string; const stID: string);
    function FindContent(const st: string): TTAGContent;
  end;

  /// TAG Holder for a member (class, function, field ...)
  TTAGHolderList = class(TObjectList)
  private
    function NewTAG(const TAGType: TTAGPattern): TTAGHolderListItem; overload;
    function NewTAG(const NodeType: TParseTreeNodeType): TTAGHolderListItem; overload;
  protected
    function GetItem(const Index: integer): TTAGHolderListItem;
    procedure SetItem(const Index: integer; const item: TTAGHolderListItem);
  public
    property Items[const Index: integer]: TTAGHolderListItem Read GetItem Write SetItem;
      default;
    procedure AddTAG(const msgTAG: string; const NodeType: TParseTreeNodeType;
      const SubID: string{ =''});
    function GetSummary: string;
    function GetContentByStyle(const CommentStyle: TCommentStyle;
      const subID: string = ''): TTAGContent;
    function ExistContentByStyle(const CommentStyle: TCommentStyle;
      const subID: string = ''): boolean;
    function ExistContentByDocTag(const DocTag : TDOCTag; const subID: string = '') : boolean;
    function GetIndexedLineByStyle(const CommentStyle: TCommentStyle;
      Index: integer): string;
    function GetEmptyTAGByStyle(const CommentStyle: TCommentStyle): TTAGContent;
    function FindByType(const CommentStyle: TCommentStyle): TTAGHolderListItem;
    function FindByNodeType(const NodeType: TParseTreeNodeType): TTAGHolderListItem;
    //function GetSubList(const SubList:TObjectList; const CommentStyle : TCommentStyle): TTAGHolderList;
  end;

var
  TAGPatternList: TTAGPatternList;

function ConvertToCommentStyle(dtTag : TDOCTag) : TCommentStyle;

implementation

uses uDocProject,uOptions;
{gnugettext: scan-all text-domain='DCTD_ignore' }
resourcestring
  L_EmptyTAG = ''; //'#No TAG found in source code#';
{gnugettext: reset }

var
  EmptyTAG: TTAGContent;
  OneSpaceEmptyTAG: TTAGContent;

function ConvertToCommentStyle(dtTag : TDOCTag) : TCommentStyle;
begin
  case dtTag of
    dtDescriptionTAG: Result := eDescriptionTAG;
    dtAuthorTAG: Result := eAuthorTAG;
    dtChangesTAG: Result := eChangesTAG;
    dtDocsTAG: Result := eDocsTAG;
    dtVersionTAG: Result := eVersionTAG;
    dtTodoTAG: Result := eTodoTAG;
    dtParamTAG: Result := eParamTAG;
    dtReturnTAG: Result := eReturnTAG;
    dtSeeTAG: Result := eSeeTAG;
    dtThrowsTAG: Result := eThrowsTAG;
    dtAdditionalCommentTAG: Result := eAdditionalCommentTAG;
    else Result := eUnknownTAG;
  end;
end;


procedure TSubTAGList.AddSubTAGLine(const msg: string; stID: string);
var
  tmpSubTAG: TSubTAG;
begin
  // Verify if SubTAG ID already exist
  tmpSubTAG := FindItemByName(stID);
  // if SubTAG doesn't exist, create it !
  if not assigned(tmpSubTAG) then
  begin
    tmpSubTAG := TSubTAG.Create(stID);
    Add(tmpSubTAG);
  end;
  // and then , fill it !
  tmpSubTAG.GetContent.Add(msg)
end;

{*------------------------------------------------------------------------------
  Find a SubTAG reference in the list by its identifier
  @param  st Identifier name of the SubTAG to find
  @return SubTAG reference if successfull, nil otherwise
-------------------------------------------------------------------------------}
function TSubTAGList.FindItemByName(const st: string): TSubTAG;
var
  Tmp:   TSubTAG;
  Index: integer;
begin
  Result := nil;
  Index  := 1;
  while ((Index <= Count) and (Result = nil)) do
  begin
    Tmp := Items[Index - 1];
    if Assigned(Tmp) then
    begin
      if CompareText(Tmp.FTAGContentID, st) = 0 then
      begin
        Result := Tmp
      end
    end;
    Inc(Index);
  end;
end;


function TSubTAGList.GetContent(const st: string): TTAGContent;
var
  tmpFirst: TSubTAG;
begin
  tmpFirst := GetFirst;
  if st = '' then
  begin
    if assigned(tmpFirst) then
    begin
      Result := tmpFirst.GetContent
    end
    else begin
      Result:=nil;
      //Result := EmptyTAG
    end
  end
  else  begin
    if assigned(FindItemByName(st)) then
    begin
      Result := FindItemByName(st).GetContent
    end
    else begin
      Result:=nil;
      //Result := EmptyTAG
    end
  end;
end;

{*------------------------------------------------------------------------------
  Get the reference of the first SubTAG in the Items List
  @return First SubTAG reference if successfull, nil otherwise
-------------------------------------------------------------------------------}
function TSubTAGList.GetFirst: TSubTAG;
begin
  if Count > 0 then
  begin
    Result := GetItem(0) as TSubTAG
  end
  else begin
    Result := nil
  end;
end;

{*------------------------------------------------------------------------------
  Get the reference of the SubTAG specified by its index in the Items List
  @param  index Index in the SubTAG List
  @return SubTAG reference if successfull, nil otherwise
-------------------------------------------------------------------------------}
function TSubTAGList.GetItem(const Index: integer): TSubTAG;
begin
  Result := inherited GetItem(Index) as TSubTAG;
end;

{*------------------------------------------------------------------------------
  Set the SubTAG reference at the  specified index in the Items List
  @param  Index Index in the SubTAG List
  @param  item SubTAG to assign
-------------------------------------------------------------------------------}
procedure TSubTAGList.SetItem(const Index: integer; const item: TSubTAG);
begin
  inherited SetItem(index, item as TObject);
end;

{ TTAGItem }

constructor TTAGPattern.Create(const sc: string; const tt: TCommentStyle;
  const nt: TParseTreeNodeType);
begin
  FSourcecode  := UpperCase(sc);
  FTAGType     := tt;
  FTNType      := nt;
end;

{ TTAGItemList }

function TTAGPatternList.GetItem(const Index: integer): TTAGPattern;
begin
  Result := inherited GetItem(Index) as TTAGPattern;
end;

function TTAGPatternList.RegisterTAG(const sc: string; const TAGtype: TCommentStyle;
  const NodeType: TParseTreeNodeType): TTAGPattern;
begin
  Result := TTAGPattern.Create(sc, TAGType, NodeType);
  Add(Result);
end;

function TTAGPatternList.FindItemByDocTag(const DocTag: TDocTag): TTAGPattern;
begin
  Result := FindItemByStyle(ConvertToCommentStyle(DocTag));
end;

function TTAGPatternList.FindItemByName(const st: string): TTAGPattern;
var
  Tmp:   TTAGPattern;
  Index: integer;
begin
  Result := nil;
  if Count <= 0 then
  begin
    exit
  end;
  Index := 0;
  while ((Index < Count) and (Result = nil)) do
  begin
    Tmp := Items[Index];
    if Assigned(Tmp) then
    begin
      if Tmp.SourceCode = st then
      begin
        Result := Tmp
      end
    end;
    Inc(Index);
  end;
end;

function TTAGPatternList.FindItemByNodeType(const ntype: TParseTreeNodeType):
TTAGPattern;
var
  Tmp:   TTAGPattern;
  Index: integer;
begin
  Result := nil;
  if Count <= 0 then
  begin
    exit
  end;
  Index := 0;
  while ((Index < Count) and (Result = nil)) do
  begin
    Tmp := Items[Index];
    if Assigned(Tmp) then
    begin
      if Tmp.FTNType = ntype then
      begin
        Result := Tmp
      end
    end;
    Inc(Index);
  end;
end;


procedure TTAGPatternList.SetItem(const Index: integer; const item: TTAGPattern);
begin
  inherited SetItem(index, item as TObject);
end;

function TTAGPatternList.FindItemByStyle(const stype: TCommentStyle): TTAGPattern;
var
  Tmp:   TTAGPattern;
  Index: integer;
begin
  Result := nil;
  if Count <= 0 then
  begin
    exit
  end;
  Index := 0;
  while ((Index < Count) and (Result = nil)) do
  begin
    Tmp := Items[Index];
    if Assigned(Tmp) then
    begin
      if Tmp.FTAGType = stype then
      begin
        Result := Tmp
      end
    end;
    Inc(Index);
  end;
end;

{ TTAGHolderListItem }

procedure TTAGHolderListItem.AddSubTAG(const msg, stID: string);
begin
  FSubTAGList.AddSubTAGLine(msg, stID);
end;

constructor TTAGHolderListItem.Create(const tp: TTAGPattern);
begin
  FTAGItem    := tp;
  FSubTAGList := TSubTAGList.Create(True);
end;

destructor TTAGHolderListItem.Destroy;
begin
  FreeAndNil(FSubTAGList);
  FTAGItem := nil;
  inherited;
end;

function TTAGHolderListItem.FindContent(const st: string): TTAGContent;
begin
  Result := FSubTAGList.GetContent(st);
end;

{ TTAGHolderList }

function TTAGHolderList.NewTAG(const TAGType: TTAGPattern): TTAGHolderListItem;
begin
  Result := TTAGHolderListItem.Create(TAGType);
  Add(Result);
end;

function TTAGHolderList.FindByType(const CommentStyle: TCommentStyle):
TTAGHolderListItem;
var
  Tmp:   TTAGHolderListItem;
  Index: integer;
begin
  Result := nil;
  if Count <= 0 then
  begin
    exit
  end;
  Index := 0;
  while ((Index < Count) and (Result = nil)) do
  begin
    Tmp := Items[Index];
    Assert(assigned(Tmp.TAGItem));
    if Assigned(Tmp) then
    begin
      if Tmp.TAGItem.TAGType = CommentStyle then
      begin
        Result := Tmp
      end
    end;
    Inc(Index);
  end;
end;

function TTAGHolderList.GetItem(const Index: integer): TTAGHolderListItem;
begin
  Result := inherited GetItem(Index) as TTAGHolderListItem;
end;

procedure TTAGHolderList.SetItem(const Index: integer; const item: TTAGHolderListItem);
begin
  inherited SetItem(index, item as TObject);
end;

procedure TTAGHolderList.AddTAG(const msgTAG: string;
  const NodeType: TParseTreeNodeType; const SubID: string {=''});
var
  tmpItem: TTAGHolderListItem;
begin
  tmpItem := FindByNodeType(NodeType);
  if not assigned(tmpItem) then
  begin
    tmpItem := NewTAG(NodeType)
  end;
  Assert(assigned(tmpItem));
  tmpItem.AddSubTAG(msgTAG, SubID);
end;

function TTAGHolderList.FindByNodeType(const NodeType: TParseTreeNodeType):
TTAGHolderListItem;
var
  Tmp:   TTAGHolderListItem;
  Index: integer;
begin
  Result := nil;
  if Count <= 0 then
  begin
    exit
  end;
  Index := 0;
  while ((Index < Count) and (Result = nil)) do
  begin
    Tmp := Items[Index];
    Assert(assigned(Tmp.TAGItem));
    if Assigned(Tmp) then
    begin
      if Tmp.TAGItem.FTNType = NodeType then
      begin
        Result := Tmp
      end
    end;
    Inc(Index);
  end;
end;

function TTAGHolderList.NewTAG(const NodeType: TParseTreeNodeType): TTAGHolderListItem;
begin
  Result := TTAGHolderListItem.Create(TAGPatternList.FindItemByNodeType(NodeType));
  Add(Result);
end;


function TTAGHolderList.GetContentByStyle(const CommentStyle: TCommentStyle;
  const subID: string = ''): TTAGContent;
var
  tmpHolderLIstItem: TTAGHolderListItem;
begin
  tmpHolderLIstItem := FindByType(CommentStyle);
  if assigned(tmpHolderLIstItem) then
  begin
    Result := tmpHolderListItem.FindContent(subID)
  end
  else begin
    Result:=GetEmptyTAGByStyle(CommentStyle);
    //Result:=nil;
  end;
end;

function TTAGHolderList.ExistContentByDocTag(const DocTag: TDOCTag; const subID: string = ''): boolean;
begin
  Result := ExistContentByStyle(ConvertToCommentStyle(DocTag), subID);
end;

function TTAGHolderList.ExistContentByStyle(const CommentStyle: TCommentStyle;
  const subID: string = ''): boolean;
var
  tmpHolderLIstItem: TTAGHolderListItem;
begin
  tmpHolderLIstItem := FindByType(CommentStyle);
  if assigned(tmpHolderLIstItem) then Result := true
  else Result:=false;
end;

function TTAGHolderList.GetEmptyTAGByStyle(const CommentStyle: TCommentStyle):
TTAGContent;
begin
  if Docproject.DocOptions.WarnEmptyTAG then Result := EmptyTAG
   else Result:=OneSpaceEmptyTAG;
end;

function TTAGHolderList.GetSummary: string;
var
  tmpHolderLIstItem: TTAGHolderListItem;
  tmpContent: TStringList;
begin
  assert(assigned(DocProject));
  // Initialize if type not existing or empty content
  if Docproject.DocOptions.WarnEmptyTAG then Result := L_EmptyTAG
   else Result:='&nbsp;';
  tmpHolderLIstItem := FindByType(eDescriptionTAG);
  if assigned(tmpHolderLIstItem) then
  begin
    tmpContent := tmpHolderLIstItem.FindContent('');
    if assigned(tmpContent) then
    begin
      if tmpContent.Count > 0 then
      begin
        Result := tmpContent.Strings[0]
      end
    end;
  end;
end;

function TTAGHolderList.GetIndexedLineByStyle(const CommentStyle: TCommentStyle;
  Index: integer): string;
var
  tmpContent: TTAGContent;
begin
  tmpContent := GetContentByStyle(CommentStyle);
  if assigned(tmpContent) then
  begin
    if Index < tmpContent.Count then
    begin
      Result := tmpContent.Strings[Index]
    end
    else begin
      Result := GetEmptyTAGByStyle(CommentStyle).Strings[0]
    end
  end
  else begin
    Result := GetEmptyTAGByStyle(CommentStyle).Strings[0]
  end;
end;

{ TSubTAG }

constructor TSubTAG.Create(const tcID: string);
begin
  FTAGContentID := tcID;
  FTAGContent   := TTAGContent.Create;
end;

destructor TSubTAG.Destroy;
begin
  FreeAndNil(FTAGContent);
  inherited;
end;


initialization
  TAGPatternList := TTAGPatternList.Create(True);
  // Register JavaDoc TAG
  // Default value
  TAGPatternList.RegisterTAG('@DESCRIPTION', eDescriptionTAG, nTAGDescription);
  TAGPatternList.RegisterTAG('@UNKNOWN', eUnknownTAG, nTAGUnknown);
  TAGPatternList.RegisterTAG('@AUTHOR', eAuthorTAG, nTAGAuthor);
  TAGPatternList.RegisterTAG('@CHANGES', eChangesTAG, nTAGChanges);
  TAGPatternList.RegisterTAG('@DOCS', eDocsTAG, nTAGDocs);
  TAGPatternList.RegisterTAG('@VERSION', eVersionTAG, nTAGVersion);
  TAGPatternList.RegisterTAG('@SEE', eSeeTAG, nTAGSee);
  TAGPatternList.RegisterTAG('@PARAM', eParamTAG, nTAGParam);
  TAGPatternList.RegisterTAG('@RETURN', eReturnTAG, nTAGReturn);
  TAGPatternList.RegisterTAG('@TODO', eTodoTAG, nTAGTodo);
  TAGPatternList.RegisterTAG('@THROWS', eThrowsTAG, nTAGThrows);
  TAGPatternList.RegisterTAG('@COMMENT', eAdditionalCommentTAG, nTAGAdditionalComment);
  EmptyTAG := TTAGContent.Create;
  EmptyTAG.Add(L_EmptyTAG);
  OneSpaceEmptyTAG:= TTAGContent.Create;
  OneSpaceEmptyTAG.Add('&nbsp;');

finalization
  FreeAndNil(OneSpaceEmptyTAG);
  FreeAndNil(EmptyTAG);
  FreeAndNil(TAGPatternList);

end.
