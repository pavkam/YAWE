unit BasicStats;

{
  AFS 25 March 03
  Basic stats on the unit
  Proof of concept to do crude code analysis on the unit

  Since it doesn't alter anything and wants to read the entire unit
  it is not a switchable visitor }

{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is BasicStats, released May 2003.
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

uses BaseVisitor;

type
  TBasicStats = class(TBaseTreeNodeVisitor)
  private
    fiTotalTokens, fiTotalChars: integer;

    // tokens can be divided into 3 categories - comments, spaces&rets, code
    fiSpaceTokens, fiCommentTokens, fiSolidTokens: integer;
    fiSpaceChars, fiCommentChars, fiSolidChars: integer;

    fiLines: integer;

    fiConsts, fiTypes, fiClasses, fiInterfaces, fiAllProcs: integer;
    liInterfaceGlobalVars, liGlobalVars: integer;
    fiInterfaceProcs: integer;

  protected
  public
    constructor Create; override;

    procedure PreVisitParseTreeNode(const pcNode: TObject); override;
    function VisitSourceToken(const pcNode: TObject): Boolean; override;
    function FinalSummary(var psMessage: string): boolean; override;

    function IsIncludedInSettings: boolean; override;
  end;

implementation

uses
  { delphi }
  SysUtils,
  JclImports,
  { JCF  }
  SourceToken, Tokens, ParseTreeNode, ParseTreeNodeType, TokenUtils;

function DisplayFloat(const ex: extended): string;
begin
  // use the localised version for display
  Result := FloatToStrF(ex, ffNumber, 9, 2);
end;

function DisplayRatio(const exNum, exDenom: extended): string;
begin
  if exDenom = 0 then
    Result := '-'
  else
    Result := DisplayFloat(exNum / exDenom);
end;

function DisplayPercent(const exNum, exDenom: extended): string;
begin
  if exDenom = 0 then
    Result := '-'
  else
    Result := DisplayFloat(exNum * 100 / exDenom) + '%';
end;



constructor TBasicStats.Create;
begin
  inherited;

  HasPreVisit := True;
  HasPostVisit := False;
  HasSourceTokenVisit := True;
end;

procedure TBasicStats.PreVisitParseTreeNode(const pcNode: TObject);
var
  lcNode: TParseTreeNode;
begin
  lcNode := TParseTreeNode(pcNode);

  case lcNode.NodeType of
    nTypeDecl:
      Inc(fiTypes);
    nConstDecl:
      Inc(fiConsts);
    nClassType:
      Inc(fiClasses);
    nInterfaceType:
      Inc(fiInterfaces);
    else; // no nothing
  end;

  { procedure/fn/constructor/destructor }
  if (lcNode.NodeType in ProcedureNodes) and lcNode.HasChildNode(nBlock) then
    { if it has a block of code under it, it counts as a proc }
    Inc(fiAllProcs);

  { can only export a global procedure or function - not a constructor or destructor
    don't count procs in a class or itnerface def }
  if (lcNode.NodeType in [nFunctionHeading, nProcedureHeading]) and
    lcNode.HasParentNode(nInterfaceSection) and
    ( not lcNode.HasParentNode([nClassType, nInterfaceType, nProcedureType])) then
    Inc(fiInterfaceProcs);

  // find global vars
  if (lcNode.NodeType = nVarDecl) and ( not lcNode.HasParentNode(nClassType)) and
    ( not lcNode.HasParentNode(nblock)) then
  begin

    if lcNode.HasParentNode(nInterfaceSection) then
      liInterfaceGlobalVars := liInterfaceGlobalVars + VarIdentCount(lcNode)
    else
      liGlobalVars := liGlobalVars + VarIdentCount(lcNode);
  end;

end;

function TBasicStats.VisitSourceToken(const pcNode: TObject): Boolean;
var
  lcSourceToken: TSourceToken;
  liLen: integer;
begin
  Result := False;
  lcSourceToken := TSourceToken(pcNode);

  // a file with no returns has one line
  if (fiLines = 0) then
    fiLines := 1;

  Inc(fiTotalTokens);
  liLen := Length(lcSourceToken.SourceCode);
  fiTotalChars := fiTotalChars + liLen;

  case lcSourceToken.TokenType of
    ttComment:
    begin
      Inc(fiCommentTokens);
      fiCommentChars := fiCommentChars + liLen;

      fiLines := fiLines + StrStrCount(lcSourceToken.SourceCode, AnsiLineBreak);
    end;
    ttReturn:
    begin
      Inc(fiLines);
      Inc(fiSpaceTokens);
      fiSpaceChars := fiSpaceChars + liLen;
    end;
    ttWhiteSpace:
    begin
      Inc(fiSpaceTokens);
      fiSpaceChars := fiSpaceChars + liLen;
    end;
    else
    begin
      Inc(fiSolidTokens);
      fiSolidChars := fiSolidChars + liLen;
    end;
  end;
end;

function TBasicStats.FinalSummary(var psMessage: string): boolean;
begin
  Result := True;

  psMessage := AnsiLineBreak + 'Basic numbers and averages: ' + AnsiLineBreak +
    'Unit is ' + IntToStr(fiLines) + ' lines long' + AnsiLineBreak +
    'Unit has ' + IntToStr(fiTotalTokens) + ' tokens in ' +
    IntToStr(fiTotalChars) + ' characters: ' + AnsiLineBreak +
    DisplayRatio(fiTotalChars, fiTotalTokens) + ' chars per token' + AnsiLineBreak +
    DisplayRatio(fiTotalChars, fiLines) + ' chars per line ' + AnsiLineBreak +
    DisplayRatio(fiTotalTokens, fiLines) + ' tokens per line ' +
    AnsiLineBreak + AnsiLineBreak;

  psMessage := psMessage +
    IntToStr(fiCommentTokens) + ' comments in ' + IntToStr(fiCommentChars) +
    ' characters ' + AnsiLineBreak +
    DisplayRatio(fiCommentChars, fiCommentTokens) + ' chars per comment' +
    AnsiLineBreak +
    DisplayPercent(fiCommentChars, fiTotalChars) + ' of chars are comments ' +
    AnsiLineBreak + AnsiLineBreak;

  psMessage := psMessage +
    IntToStr(fiSpaceTokens) + ' spacing and return tokens in ' +
    IntToStr(fiSpaceChars) + ' characters ' + AnsiLineBreak +
    DisplayRatio(fiSpaceChars, fiSpaceTokens) + ' chars per token' + AnsiLineBreak +
    DisplayPercent(fiSpaceChars, fiTotalChars) + ' of chars are spacing ' +
    AnsiLineBreak + AnsiLineBreak;

  psMessage := psMessage +
    IntToStr(fiSolidTokens) + ' solid tokens in ' + IntToStr(fiSolidChars) +
    ' characters ' + AnsiLineBreak +
    DisplayRatio(fiSolidChars, fiSolidTokens) + ' chars per token' + AnsiLineBreak +
    DisplayPercent(fiSolidChars, fiTotalChars) + ' of chars are solid' + AnsiLineBreak +
    DisplayPercent(fiSolidTokens, fiTotalTokens) + ' of tokens are solid' +
    AnsiLineBreak + AnsiLineBreak;

  psMessage := psMessage +
    IntToStr(fiConsts) + ' constants ' + AnsiLineBreak +
    IntToStr(fiTypes) + ' types ' + AnsiLineBreak +
    IntToStr(fiClasses) + ' classes ' + AnsiLineBreak +
    IntToStr(fiInterfaces) + ' interfaces ' + AnsiLineBreak +
    IntToStr(fiAllProcs) + ' procedures ' + AnsiLineBreak + AnsiLineBreak;

  psMessage := psMessage +
    IntToStr(liInterfaceGlobalVars) + ' global vars in interface ' + AnsiLineBreak +
    IntToStr(liGlobalVars) + ' global vars in rest of unit ' + AnsiLineBreak +
    IntToStr(fiInterfaceProcs) + ' procedures in interface ' +
    AnsiLineBreak + AnsiLineBreak;

end;


function TBasicStats.IsIncludedInSettings: boolean;
begin
  Result := true;
end;

end.
