unit AllProcesses;

{ all warnings put together }

{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is AllProcesses, released May 2003.
The Initial Developer of the Original Code is Anthony Steele. 
Portions created by Anthony Steele are Copyright (C) 1999-2000 Anthony Steele.
All Rights Reserved. 
Contributor(s): Anthony Steele. 

The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"). you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.mozilla.org/NPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied.
See the License for the specific language governing rights and limitations 
under the License.
------------------------------------------------------------------------------*)
{*)}

interface

uses
  { delphi } Classes,
  ParseTreeNode, BaseVisitor, ConvertTypes, TreeWalker;

type

  TAllProcesses = class(TObject)
  private
    fcTreeWalker: TTreeWalker;

    fcOnMessages: TStatusMessageProc;
    fcRoot: TParseTreeNode;

    procedure ApplyVisitorType(const pcVisitorType: TTreeNodeVisitorType); overload;
    procedure ApplyVisitorType(const pcVisitorType: TTreeNodeVisitorType;
      const pcFollowSet: array of TTreeNodeVisitorType); overload;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Execute(const pcRoot: TParseTreeNode);

    property OnMessage: TStatusMessageProc Read fcOnMessages Write fcOnMessages;
  end;

implementation

uses
  { delphi }
  SysUtils,
  { local }
   VisitSetXY,
  BasicStats,
  VisitStructure,
  VisitComment;

constructor TAllProcesses.Create;
begin
  inherited;
  fcOnMessages := nil;
  fcTreeWalker := TTreeWalker.Create;
end;


destructor TAllProcesses.Destroy;
begin
  FreeAndNil(fcTreeWalker);
  inherited;
end;

procedure TAllProcesses.ApplyVisitorType(const pcVisitorType: TTreeNodeVisitorType);
begin
  ApplyVisitorType(pcVisitorType, []);
end;

{ the idea behind the follow set is that
  several processes are often used after a main one.
  e.g. after the linebreaker, redo the VisitSetXY and the RemoveEmptySpace
  if the main process doesn't fire due to settings, or makes no changes,
  can save time by omitting the cleanup
  }
procedure TAllProcesses.ApplyVisitorType(const pcVisitorType: TTreeNodeVisitorType;
  const pcFollowSet: array of TTreeNodeVisitorType);
var
  lc {, lcFollow}: TBaseTreeNodeVisitor;
  lsMessage: string;
  //liLoop: integer;
begin
  Assert(fcRoot <> nil);

  lc := pcVisitorType.Create;
  try
    if lc.IsIncludedInSettings then
    begin
      fcTreeWalker.Visit(fcRoot, lc);
      //if (lc is TWarning) then
      // (lc as TWarning).OnWarning := OnMessage;
      lc.AfterFullVisit;
      // TridenT - No need to send final summary

      if lc.FinalSummary(lsMessage) then
      begin
        if lsMessage <> '' then
          OnMessage('', lsMessage, -1, -1);
      end;
    end;
  finally
    lc.Free;
  end;
end;

procedure TAllProcesses.Execute(const pcRoot: TParseTreeNode);
begin
  Assert(pcRoot <> nil);
  fcRoot := pcRoot;
  ApplyVisitorType(TVInterfaceStructure);
  ApplyVisitorType(TVInterfaceComment);
end;


end.
