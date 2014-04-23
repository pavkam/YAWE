{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is BuildTokenList.pas, released April 2000.
The Initial Developer of the Original Code is Anthony Steele. 
Portions created by Anthony Steele are Copyright (C) 1999-2004 Anthony Steele.
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

unit BuildTokenList;

{ AFS 29 Nov 1999
 converts the input string of chars into a list of tokens
 This is the lexical analysis phase of the parsing
}

interface

uses
  { delphi }
  Windows,
  { local }
  TagComment,
  Tokens, SourceToken, SourceTokenList;

type

  TBuildTokenList = class(TObject)
  private
    { property implementation }
    fsSourceCode: string;

    { woker procs }
    fiCurrentIndex: integer;
    // TridenT - Inside a Curly comment
    FInsideCurlyComment: boolean;
    FInsideBracketStarComment: boolean;
    FInsideSlashComment: boolean;
    FInsideParamTAG: boolean;
    FInsideJavaDoc: boolean;
    FBeginNewLine: Boolean;
    { implementation of GetNextToken }

    procedure SetSourceCode(const Value: string);

    function Current: char;
    function CurrentChars(const piCount: integer): string;
    function ForwardChar(const piOffset: integer): char;
    function ForwardChars(const piOffset, piCount: integer): string;
    function Consume(const piCount: integer = 1): string;
    function EndOfFile: boolean;
    function EndOfFileAfter(const piChars: integer): boolean;

      { implementation of GetNextToken }
    function TryReturn(const pcToken: TSourceToken): boolean;

    function TryCurlyComment(const pcToken: TSourceToken): boolean;
	// TridenT
    function TryDecoratorComment(const pcToken: TSourceToken): boolean;
    function TryInsideCurlyComment(const pcToken: TSourceToken): boolean;
    function TryInsideBracketStarComment(const pcToken: TSourceToken): boolean;
    function TryInsideCurlyEmptyLine(const pcToken: TSourceToken): boolean;
    function TryInsideParamTAG(const pcToken: TSourceToken): boolean;
    function TryClosedCurlyComment(const pcToken: TSourceToken): boolean;
    function TryClosedBracketStarComment(const pcToken: TSourceToken): boolean;
    function TryInsideSlashComment(const pcToken: TSourceToken): boolean;
    function TrySlashComment(const pcToken: TSourceToken): boolean;
    function TryBracketStarComment(const pcToken: TSourceToken): boolean;

    function TryWhiteSpace(const pcToken: TSourceToken): boolean;
    function TryLiteralString(const pcToken: TSourceToken;
      const pcDelimiter: char): boolean;

    function TryNumber(const pcToken: TSourceToken): boolean;
    function TryHexNumber(const pcToken: TSourceToken): boolean;

    function TryDots(const pcToken: TSourceToken): boolean;

    function TryAssign(const pcToken: TSourceToken): boolean;

    function TrySingleCharToken(const pcToken: TSourceToken): boolean;

    function TryPunctuation(const pcToken: TSourceToken): boolean;
    function TryWord(const pcToken: TSourceToken): boolean;

    function GetNextToken: TSourceToken;
    // TridenT - TAG based comment
    function TryJavaDocTAGComment(const pcToken: TSourceToken): boolean;
    function TryAllJavaDocTAG(const pcToken: TSourceToken): boolean;

  protected

  public
    constructor Create;
    destructor Destroy; override;

    function BuildTokenList: TSourceTokenList;

    property SourceCode: string read fsSourceCode write SetSourceCode;
  end;


implementation

uses
 { delphi }
 SysUtils,
 { jcl }
 JclImports,
 { local }
 uDocProject;


const
  codepage_Chinese = 950;

function CheckMultiByte(const pcChar: char): Boolean;
begin
  // TridenT
  //if GetRegSettings.CheckMultiByteChars then
    Result := IsDBCSLeadByte(Byte(pcChar));
    //Result := IsDBCSLeadByteEx(codepage_Chinese, Byte(pcChar));
end;

{ TBuildTokenList }

constructor TBuildTokenList.Create;
begin
  inherited;
  // TridenT - Init 'inside' pointer
  FInsideCurlyComment := False;
  FInsideBracketStarComment := False;
  FInsideSlashComment := False;
  FInsideParamTAG := False;
  FInsideJavaDoc := False;
  FBeginNewLine := true;
  SourceCode := '';
end;

destructor TBuildTokenList.Destroy;
begin
  inherited;
end;

procedure TBuildTokenList.SetSourceCode(const Value: string);
begin
  fsSourceCode := Value;
  // reset the index 
  fiCurrentIndex := 1;
end;

function TBuildTokenList.GetNextToken: TSourceToken;
var
  lcNewToken: TSourceToken;

  procedure DoAllTheTries;
  begin
    // TridenT
    { First, Look inside Curly comment for Tagged comment }
    if FInsideCurlyComment then
      if TryInsideCurlyComment(lcNewToken) then exit;
    { Then, Look inside BracketStar comment for Tagged comment }
    if FInsideBracketStarComment then
      if TryInsideBracketStarComment(lcNewToken) then exit;
    { Look if inside an inline comment }
    if FInsideSlashComment then
      if TryInsideSlashComment(lcNewToken) then exit;
    { first look for return }
    if TryReturn(lcNewToken) then
      exit;
    { comments }
    if TryCurlyComment(lcNewToken) then
      exit;
    if TrySlashComment(lcNewToken) then
      exit;
    if TryBracketStarComment(lcNewToken) then
      exit;
    { the rest }
    if TryWhiteSpace(lcNewToken) then
      exit;
    if TryLiteralString(lcNewToken, AnsiSingleQuote) then
      exit;
    if TryLiteralString(lcNewToken, AnsiDoubleQuote) then
      exit;

    if TryWord(lcNewToken) then
      exit;
    if TryNumber(lcNewToken) then
      exit;
    if TryHexNumber(lcNewToken) then
      exit;

    if TryDots(lcNewToken) then
      exit;

    { attempt assign before colon }
    if TryAssign(lcNewToken) then
      exit;

    if TryPunctuation(lcNewToken) then
      exit;

    if TrySingleCharToken(lcNewToken) then
      exit;

    { default }
    lcNewToken.TokenType  := ttUnknown;
    lcNewToken.SourceCode := Current;
    Consume(1);
  end;

begin
  if EndOfFile then
    Result := nil
  else
  begin
    lcNewToken := TSourceToken.Create;
    DoAllTheTries;

    lcNewToken.WordType := WordTypeOfToken(lcNewToken.TokenType);
    Result := lcNewToken;
  end;
end;

{-------------------------------------------------------------------------------
  worker fns for GetNextComment }

function TBuildTokenList.TryBracketStarComment(const pcToken: TSourceToken): boolean;
var
  liCommentLength: integer;

  procedure MoveToCommentEnd;
  begin
    { comment is ended by *) or by EOF (bad source) }
    while True do
    begin
      if EndOfFileAfter(liCommentLength) then
        break;

      if CheckMultiByte(ForwardChar(liCommentLength)) then
      begin
        liCommentLength := liCommentLength + 2;
        continue;
      end;

      if ForwardChars(liCommentLength, 2) = '*)' then
        break;

      inc(liCommentLength);
    end;

    // include the comment end
    if not EndOfFileAfter(liCommentLength) and (ForwardChars(liCommentLength, 2) = '*)') then
      inc(liCommentLength, 2);
  end;


begin
  Result := False;
  if not (Current = '(') then
    exit;


  if CurrentChars(2) <> '(*' then
    exit;

  { if the comment starts with (*) that is not the end of the comment }
  liCommentLength := 2;

  //MoveToCommentEnd;

  pcToken.TokenType := ttComment;
  pcToken.CommentStyle := eBracketStar;
  pcToken.SourceCode := CurrentChars(liCommentLength);
  Consume(liCommentLength);
  // Test JavaDoc Prefix
  if DocProject.DocOptions.BracketStarJavaDocCharPrefix <> '' then
  begin
    if Current = DocProject.DocOptions.BracketStarJavaDocCharPrefix then
    begin
      FInsideJavaDoc      := True;
      //Reader.BufferLength := 1;
      pcToken.SourceCode  := pcToken.SourceCode + Current;
      Consume(1);
    end
    else begin
      FInsideJavaDoc := False
    end
  end
  else begin
    FInsideJavaDoc := True
  end;

  FInsideBracketStarComment := True;
  
  Result := True;
end;

function TBuildTokenList.TryCurlyComment(const pcToken: TSourceToken): boolean;
var
  liCommentLength: integer;

  procedure MoveToCommentEnd;
  begin
    { comment is ended by close-curly or by EOF (bad source) }
    while True do
    begin
      if EndOfFileAfter(liCommentLength) then
        break;

      if CheckMultiByte(ForwardChar(liCommentLength)) then
      begin
        liCommentLength := liCommentLength + 2;
        continue;
      end;

      if ForwardChar(liCommentLength) = '}' then
        break;

      inc(liCommentLength);
    end;

    { include the closing brace }
    if not EndOfFileAfter(liCommentLength) and (ForwardChars(liCommentLength, 1) = '}') then
      inc(liCommentLength);
  end;

begin
  Result := False;
  if Current <> '{' then
    exit;

  pcToken.TokenType  := ttComment;
  liCommentLength := 1;

  { compiler directive are the comments with a $ just after the open-curly
    this is always the case }
  if ForwardChar(1) = '$' then
  begin
    pcToken.CommentStyle := eCompilerDirective;
    MoveToCommentEnd;
    pcToken.SourceCode := CurrentChars(liCommentLength);
    Consume(liCommentLength);
  end
  else
  begin
    pcToken.CommentStyle := eCurlyBrace;
 
  pcToken.SourceCode := CurrentChars(liCommentLength);
  Consume(liCommentLength);

 // Test JavaDoc Prefix
    if DocProject.DocOptions.CurlyJavaDocCharPrefix <> '' then
    begin
      if Current = DocProject.DocOptions.CurlyJavaDocCharPrefix then
      begin
        FInsideJavaDoc      := True;
        //Reader.BufferLength := 1;
        pcToken.SourceCode  := pcToken.SourceCode + Current;
        Consume(1);
      end
      else FInsideJavaDoc := False;
    end
    else FInsideJavaDoc := True;
    // OpenCurlyBracket
    pcToken.CommentStyle := eCurlyBrace;
    FInsideCurlyComment := True;
    //Result := True;
    FBeginNewLine := False;
  end;
  //MoveToCommentEnd;

  Result := True;
end;

function TBuildTokenList.TrySlashComment(const pcToken: TSourceToken): boolean;
var
  liCommentLength: integer;

  procedure MoveToCommentEnd;
  begin
    { comment is ended by return or by EOF (bad source) }
    while True do
    begin
      if EndOfFileAfter(liCommentLength) then
        break;

      if CheckMultiByte(ForwardChar(liCommentLength)) then
      begin
        liCommentLength := liCommentLength + 2;
        continue;
      end;

      if CharIsReturn(ForwardChar(liCommentLength)) then
        break;

      inc(liCommentLength);
    end;
  end;

begin
  Result := False;
  if Current <> '/' then
    exit;

  { until end of line or file }
  if CurrentChars(2) <> '//' then
    exit;

  liCommentLength := 2;

  //MoveToCommentEnd;

  FInsideSlashComment := True;
  pcToken.TokenType := ttComment;
  pcToken.CommentStyle := eDoubleSlash;
  pcToken.SourceCode := CurrentChars(liCommentLength);
  Consume(liCommentLength);

  // Test JavaDoc Prefix
  if DocProject.DocOptions.InLineJavaDocCharPrefix <> '' then
  begin
    if Current = DocProject.DocOptions.InLineJavaDocCharPrefix then
    begin
      FInsideJavaDoc      := True;
      pcToken.SourceCode  := pcToken.SourceCode + CurrentChars(1);
      Consume(1);
    end
    else
      FInsideJavaDoc := False
  end
  else
    FInsideJavaDoc := True;
  Result := True;
end;


function TBuildTokenList.TryReturn(const pcToken: TSourceToken): boolean;
var
  chNext: char;
begin
  Result := False;
  if not CharIsReturn(Current) then
    exit;

  pcToken.TokenType  := ttReturn;
  pcToken.SourceCode := Current;
  Consume;

  if not EndOfFile then
  begin
    { concat the next return char if it is not the same
      This will recognise <cr><lf> or <lf><cr>, but not <cr><cr> }

    chNext := Current;
    if (CharIsReturn(chNext) = True) and (chNext <> pcToken.SourceCode[1]) then
    begin
      pcToken.SourceCode := pcToken.SourceCode + chNext;
      Consume;
    end;
  end;
  Result := True;
end;

{ complexities like 'Hello'#32'World' and #$12'Foo' are assemlbed in the parser }
function TBuildTokenList.TryLiteralString(const pcToken: TSourceToken;
  const pcDelimiter: char): boolean;
begin
  Result := False;

  if Current = pcDelimiter then
  begin
    Result := True;
    { read the opening ' }
    pcToken.SourceCode := pcToken.SourceCode + Current;
    Consume;

    { read until the close ' }
    repeat
      if Current = #0 then
        break;
      if Current in [AnsiLineFeed, AnsiCarriageReturn] then
        Raise Exception.Create('Unterminated string: ' + pcToken.SourceCode);

      { two quotes in a row are still part of the string }
      if (Current = pcDelimiter) then
      begin
        { two consecutive quote chars inside string, read them }
        if (ForwardChar(1) = pcDelimiter) then
        begin
          pcToken.SourceCode := pcToken.SourceCode + CurrentChars(2);
          Consume(2);
        end
        else
        begin
          { single quote char ends string }
          pcToken.SourceCode := pcToken.SourceCode + Current;
          Consume;
          break;
        end
      end
      else
      begin
        { normal char, read it }
        pcToken.SourceCode := pcToken.SourceCode + Current;
        Consume;
      end;

    until False;

    pcToken.TokenType := ttQuotedLiteralString;
  end;
end;


function TBuildTokenList.TryWord(const pcToken: TSourceToken): boolean;

  function IsWordChar(const ch: char): boolean;
  begin
    Result := CharIsAlpha(ch) or (ch = '_');
  end;

begin
  Result := False;

  if not IsWordChar(Current) then
    exit;

  pcToken.SourceCode := Current;
  Consume;

  { concat any subsequent word chars }
  while IsWordChar(Current) or CharIsDigit(Current) do
  begin
    pcToken.SourceCode := pcToken.SourceCode + Current;
    Consume;
  end;

  { try to recognise the word as built in }
  pcToken.TokenType := TypeOfToken(pcToken.SourceCode);
  if pcToken.TokenType = ttUnknown then
    pcToken.TokenType := ttIdentifier;

  Result := True;
end;

function CharIsWhiteSpaceNoReturn(const ch: AnsiChar): boolean;
begin
  { 7 April 2004 following sf snag 928460 and discussion in newsgroups
    must accept all other chars < 32 as white space }

  // Result := CharIsWhiteSpace(ch) and (ch <> AnsiLineFeed) and (ch <> AnsiCarriageReturn);

  Result := (Ord(ch) <= Ord(AnsiSpace)) and
    (not (ch in [AnsiLineFeed, AnsiCarriageReturn, AnsiNull]));
end;

function TBuildTokenList.TryWhiteSpace(const pcToken: TSourceToken): boolean;
begin
  Result := False;
  if not CharIsWhiteSpaceNoReturn(Current) then
    exit;

  pcToken.TokenType  := ttWhiteSpace;
  pcToken.SourceCode := Current;
  Consume;

  Result := True;

  { concat any subsequent return chars }
  // TridenT - Add EndOfFile test
  if not EndOfFile then
    while CharIsWhiteSpaceNoReturn(Current) do
    begin
      pcToken.SourceCode := pcToken.SourceCode + Current;
      Consume;
      if EndOfFile then exit;
    end;
end;

function TBuildTokenList.TryAssign(const pcToken: TSourceToken): boolean;
begin
  Result := False;

  if Current <> ':' then
    exit;

  if CurrentChars(2) <> ':=' then
    exit;

  pcToken.TokenType := ttAssign;
  pcToken.SourceCode := CurrentChars(2);
  Consume(2);
  
  Result := True;
end;

function TBuildTokenList.TryNumber(const pcToken: TSourceToken): boolean;
var
  lbHasDecimalSep: boolean;
begin
  Result := False;

  { recognise a number -
   they don't start with a '.' but may contain one

   a minus sign in front is considered unary operator not part of the number
   this is bourne out by the compiler considering
    '- 0.3' and -0.3' to be the same value
    and -.3 is not legal at all }

  { first one must be a digit }
  if not CharIsDigit(Current) then
    exit;

  if (Current = '.') or (Current = '-') then
    exit;

  pcToken.TokenType  := ttNumber;
  pcToken.SourceCode := Current;
  Consume;
  lbHasDecimalSep := False;

  { concat any subsequent number chars
    only one decimal seperator allowed

    also NB that two dots can be array range, as in
    var foo = array[1..100] of integer;
    ie one dat = decimal
    two dots = end of number
  }
  while CharIsDigit(Current) or (Current = '.') do
  begin
    // have we got to the dot?
    if (Current = '.') then
    begin
      if CurrentChars(2) = '..' then
        break;

      if lbHasDecimalSep then
        // oops! a second one
        break
      else
        lbHasDecimalSep := True;
    end;

    pcToken.SourceCode := pcToken.SourceCode + Current;
    Consume;
  end;

  { scientific notation suffix, eg 3e2 = 30, 2.1e-3 = 0.0021 }

  { check for a trailing 'e' }
  if Current in ['e', 'E'] then
  begin
    // sci notation mode
    pcToken.SourceCode := pcToken.SourceCode + Current;
    Consume;

    // can be a minus or plus here
    if Current in ['-', '+'] then
    begin
      pcToken.SourceCode := pcToken.SourceCode + Current;
      Consume;
    end;

    { exponent must be integer }
    while CharIsDigit(Current) do
    begin
      pcToken.SourceCode := pcToken.SourceCode + Current;
      Consume;
    end;
  end;

  Result := True;
end;

{ NB: do not localise '.' with DecimalSeperator
  Delphi source code does *not* change for this }
function TBuildTokenList.TryHexNumber(const pcToken: TSourceToken): boolean;
var
  lbHasDecimalSep: boolean;
begin
  Result := False;

  { starts with a $ }
  if Current <> '$' then
    exit;

  pcToken.TokenType  := ttNumber;
  pcToken.SourceCode := Current;
  Consume;
  lbHasDecimalSep := False;

  { concat any subsequent number chars }
  while (Current in AnsiHexDigits) or (Current = '.') do
  begin
    // have we got to the dot?
    if (Current = '.') then
    begin
      if CurrentChars(2) = '..' then
        break;

      if lbHasDecimalSep then
        // oops! a second one
        break
      else
        lbHasDecimalSep := True;
    end;

    pcToken.SourceCode := pcToken.SourceCode + Current;
    Consume;
  end;

  Result := True;
end;

{ try the range '..' operator and object access  '.' operator }
function TBuildTokenList.TryDots(const pcToken: TSourceToken): boolean;
begin
  Result := False;

  if Current <> '.' then
    exit;

  pcToken.SourceCode := Current;
  Consume;

  pcToken.TokenType := ttDot;
  // Added by TRidenT - A DOT can be the last char in the file !
  // if so, it asserts without this test
  if not EndOfFile then
   if Current = '.' then
   begin
     pcToken.TokenType  := ttDoubleDot;
     pcToken.SourceCode := pcToken.SourceCode + Current;
     Consume;
   end;
   //else
   //begin
   //  pcToken.TokenType := ttDot;
   //end;

  Result := True;
end;


function IsPuncChar(const ch: char): boolean;
begin
  Result := False;

  if CharIsWhiteSpace(ch) then
    exit;
  if CharIsAlphaNum(ch) then
    exit;
  if CharIsReturn(ch) then
    exit;

  if CharIsControl(ch) then
    exit;

  Result := True;
end;

function TBuildTokenList.TryPunctuation(const pcToken: TSourceToken): boolean;


  function FollowsPunctuation(const chLast, ch: char): boolean;
  const
    { these have meanings on thier own and should not be recognised as part of the punc.
     e.g '=(' is not a punctation symbol, but 2 of them ( for e.g. in const a=(3);
     simlarly ');' is 2 puncs }
    UnitaryPunctuation: set of char = [
      AnsiSingleQuote, '"', '(', ')', '[', ']', '{',
      '#', '$', '_', ';', '@', '^', ','];

   { these can't have anything following them:
    for e.g, catch the case if a=-1 then ...
      where '=-1' should be read as '=' '-1' not '=-' '1'
      Nothing legitimately comes after '=' AFAIK
      also a:=a*-1;
      q:=q--1; // q equals q minus minus-one. It sucks but it compiles so it must be parsed
      etc }
    SingleChars: set of char = ['=', '+', '-', '*', '/', '\'];

  begin
    Result := False;

    if (chLast in UnitaryPunctuation) or (ch in UnitaryPunctuation) then
      exit;

    if chLast in SingleChars then
      exit;

    { '<' or '<' can only be followed by '<', '>' or '='.
     Beware of "if x<-1" }
    if (chLast in ['<', '>']) and not (ch in ['<', '>', '=']) then
      exit;

    // ':' can be followed by '='
    if (chLast = ':') and (ch <> '=') then
      exit;

    Result := IsPuncChar(ch);
  end;

var
  leWordType:  TWordType;
  leTokenType: TTokenType;
  lcLast:      char;
begin
  Result := False;

  if not IsPuncChar(Current) then
    exit;

  pcToken.TokenType := ttPunctuation;
  lcLast := Current;
  pcToken.SourceCode := lcLast;
  Consume;

  { concat any subsequent punc chars }
  while FollowsPunctuation(lcLast, Current) do
  begin
    lcLast := Current;
    pcToken.SourceCode := pcToken.SourceCode + lcLast;
    Consume;
  end;

  { try to recognise the punctuation as an operator }
  TypeOfToken(pcToken.SourceCode, leWordType, leTokenType);
  if leTokenType <> ttUnknown then
  begin
    pcToken.TokenType := leTokenType;
  end;

  Result := True;
end;

function TBuildTokenList.TrySingleCharToken(const pcToken: TSourceToken): boolean;
begin
  Result := False;

  pcToken.TokenType := TypeOfToken(Current);
  if pcToken.TokenType <> ttUnknown then
  begin
    pcToken.SourceCode := Current;
    Consume;
    Result := True;
  end;
end;

function TBuildTokenList.BuildTokenList: TSourceTokenList;
const
  UPDATE_INTERVAL = 4096; // big incre,ents here, this is fatser than parsing
var
  lcList:    TSourceTokenList;
  lcNew:     TSourceToken;
begin
  Assert(SourceCode <> '');

  lcList    := TSourceTokenList.Create;

  while not EndOfFile do
  begin
    lcNew := GetNextToken;
    lcList.Add(lcNew);
  end;

  Result := lcList;
end;

function TBuildTokenList.Current: char;
begin
   Result := fsSourceCode[fiCurrentIndex];
end;

function TBuildTokenList.CurrentChars(const piCount: integer): string;
begin
  Result := Copy(fsSourceCode, fiCurrentIndex, piCount);
end;

function TBuildTokenList.ForwardChar(const piOffset: integer): char;
begin
  Result := fsSourceCode[fiCurrentIndex + piOffset];
end;

function TBuildTokenList.ForwardChars(const piOffset, piCount: integer): string;
begin
  Result := Copy(fsSourceCode, fiCurrentIndex + piOffset, piCount);
end;


function TBuildTokenList.Consume(const piCount: integer): string;
begin
  inc(fiCurrentIndex, piCount);
end;

function TBuildTokenList.EndOfFile: boolean;
begin
  Result := fiCurrentIndex > Length(fsSourceCode);
end;

function TBuildTokenList.EndOfFileAfter(const piChars: integer): boolean;
begin
  Result := (fiCurrentIndex + piChars) > Length(fsSourceCode);
end;


function TBuildTokenList.TryInsideCurlyComment(const pcToken: TSourceToken): boolean;

  function DoAllInsideCurlyTries(const pcToken: TSourceToken): boolean;
  var
    liCommentLength:integer;
  begin
    Result := True;
    // try JavaDoc TAG only if Prefix recognized
    if FInsideJavaDoc then
    begin
      if TryDecoratorComment(pcToken) then exit;
      if TryJavaDocTAGComment(pcToken) then exit;
      if TryInsideParamTAG(pcToken) then exit;
    end;
    if TryClosedCurlyComment(pcToken) then exit;
    if TryInsideCurlyEmptyLine(pcToken) then exit;
    liCommentLength:=0;
    { default }
    // Strip buffer until Return or Closed Bracket
    while (( not CharIsReturn(ForwardChar(liCommentLength))) and (ForwardChar(liCommentLength) <> '}')) and
      ( not EndOfFile) do
    begin
      // #Riu N. Skip Double-bytes character
      {if Current in LeadBytes then
      begin
        Reader.IncBuffer
      end;
      Reader.IncBuffer;}
      if CheckMultiByte(ForwardChar(liCommentLength)) then inc(liCommentLength,2)
      else inc(liCommentLength,1);
      //Consume(1);
    end;

    pcToken.TokenType := ttComment;
    if FInsideJavaDoc then
    begin
      pcToken.CommentStyle := eContentTAG
    end //eUnknownTAG;
    else      begin
      pcToken.CommentStyle := eStandard
    end;
    pcToken.SourceCode := pcToken.SourceCode + CurrentChars(liCommentLength);
    Consume(liCommentLength);
    Result := True;

    if Current = '}' then
    begin
      // COmment line inside curly terminated by ClosedCurly
      FBeginNewLine := False;
    end
    // Comment line inside curly terminated by EndOfLine
    else
    begin
      FBeginNewLine := True;
    end;

  end;

begin
  Assert(FInsideCurlyComment = True);

  // Skip space before
  // Read until CHAR<>SPACE or EndOfFile
  while CharIsWhiteSpaceNoReturn(Current) and ( not EndOfFile) do
  begin
    Consume;
  end;
  Result := DoAllInsideCurlyTries(pcToken);
end;

function TBuildTokenList.TryDecoratorComment(const pcToken: TSourceToken): boolean;
var
  liLength: integer;
begin
  Result := False;
  if not FBeginNewLine then exit;
  if not (Current = '*') then exit;
  // Decorator can have two types of char after : Space, or EOL
  if (ForwardChar(1)<>' ') and (not CharIsReturn(ForwardChar(1))) then exit;
  // if Last is return, keep return away !
  if CharIsReturn(ForwardChar(1)) then liLength:=1
  else liLength:=2;
  // Decorator detect
  Result := True;
  pcToken.TokenType := ttComment;
  pcToken.CommentStyle := eStandard;
  pcToken.SourceCode := pcToken.SourceCode + CurrentChars(liLength);
  Consume(liLength);
end;




function TBuildTokenList.TryJavaDocTAGComment(const pcToken: TSourceToken): boolean;
begin
  Result := False;
  if not (Current = '@') then exit;

  // TAGComment detect
  Result := True;
  pcToken.TokenType := ttComment;
  pcToken.CommentStyle := eUnknownTAG;

  if TryAllJavaDocTAG(pcToken) then exit;
end;

function TBuildTokenList.TryAllJavaDocTAG(const pcToken: TSourceToken): boolean;
var
  DetectedTAG: TTAGPattern;
  liLength: integer;
begin
  liLength:=0;
  // Extract JavaTAG
  // Strip until space or EndOfLine
  while (( not CharIsReturn(ForwardChar(liLength))) and (ForwardChar(liLength) <> ' ')) and
    ( not EndOfFile) do
  begin
    inc(liLength,1);
  end;

  // To pop EndOfLine or space
  //Reader.DecBuffer;
  pcToken.TokenType := ttComment;
  pcToken.SourceCode := pcToken.SourceCode + CurrentChars(liLength);
  Consume(liLength);
  DetectedTAG := TAGPatternList.FindItemByName(UpperCase(pcToken.SourceCode));
  // Beware of unrecognize TAG !
  if assigned(DetectedTAG) then
  begin
    pcToken.CommentStyle := DetectedTAG.TAGType;
    FInsideParamTAG      := (DetectedTAG.TAGType = eParamTAG);
  end
  else  begin
    pcToken.CommentStyle := eUnknownTAG;
    FInsideParamTAG      := False;
  end;
  Result := True;
end;





function TBuildTokenList.TryClosedCurlyComment(const pcToken: TSourceToken): boolean;
begin
  Result := False;
  if not (Current = '}') then exit;
  // Closed Curly comment detect
  // COmment line inside curly terminated by ClosedCurly
  //Reader.DecBuffer;
  FInsideCurlyComment := False;
  FInsideJavaDoc := False;
  pcToken.TokenType := ttComment;
  pcToken.CommentStyle := eCurlyBrace;
  pcToken.SourceCode := pcToken.SourceCode + CurrentChars(1);
  Consume(1);
  Result := True;
end;



function TBuildTokenList.TryInsideCurlyEmptyLine(const pcToken: TSourceToken): boolean;
var
  chNext: char;
begin
  Result := False;
  if not CharIsReturn(Current) then exit;

  // Return detected (empty line inside Curly)
  pcToken.TokenType := ttComment;
  pcToken.CommentStyle := eReturn;
  {if FInsideJavaDoc then
  begin
    pcToken.CommentStyle := eContentTAG
  end //eUnknownTAG;
  else    begin
    pcToken.CommentStyle := eStandard
  end;}
  pcToken.SourceCode := pcToken.SourceCode + CurrentChars(1);
  Consume(1);
  Result := True;
  
  { concat the next return char if it is not the same
  This will recognise <cr><lf> or <lf><cr>, but not <cr><cr>
  TridenT - Not used for the moment
  }
  if not EndOfFile then
  begin
    chNext := Current;
    if CharIsReturn(chNext) and (chNext <> pcToken.SourceCode[1]) then
    begin
      pcToken.SourceCode := pcToken.SourceCode + chNext;
      Consume(1);
    end;
  end;
  FBeginNewLine := True;
end;

function TBuildTokenList.TryInsideSlashComment(const pcToken: TSourceToken): boolean;
var
  liLength:integer;
begin
  Assert(FInsideSlashComment = True);
  // Skip space before
  // Read until CHAR<>SPACE or EndOfFile
  while CharIsWhiteSpaceNoReturn(Current) and ( not EndOfFile) do
  begin
    Consume(1);
  end;

  liLength:=0;
  // Strip buffer until Return or End of file
  while (( not CharIsReturn(ForwardChar(liLength))) and ( not EndOfFile)) do
  begin
    inc(liLength,1)
  end;

  //if CharIsReturn(Current) then Reader.DecBuffer;
  pcToken.TokenType := ttComment;
  if FInsideJavaDoc then
  begin
    pcToken.CommentStyle := eContentTAG
  end //eUnknownTAG;
  else    begin
    pcToken.CommentStyle := eStandard
  end;
  pcToken.SourceCode := pcToken.SourceCode + CurrentChars(liLength);
  Consume(liLength);
  Result := True;
  FInsideSlashComment := False;
  FInsideJavaDoc := False;
  FBeginNewLine := True;
end;

function TBuildTokenList.TryInsideParamTAG(const pcToken: TSourceToken): boolean;
begin
  Result := False;
  if not FInsideParamTAG then
  begin
    exit
  end;
  // Param TAG Identifier detected
  pcToken.TokenType    := ttComment;
  pcToken.CommentStyle := eParameterIdentifier;

  // Read until CHAR<>SPACE or EndOfFile
  while (Current <> ' ') and ( not EndOfFile) do
  begin
    pcToken.SourceCode := pcToken.SourceCode + CurrentChars(1);
    Consume(1);
  end;

  FInsideParamTAG := False;
  Result := True;
end;

function TBuildTokenList.TryInsideBracketStarComment(
  const pcToken: TSourceToken): boolean;

  function DoAllInsideBracketStarTries(const pcToken: TSourceToken): boolean;
  var
    liCommentLength:integer;
  begin
    Result := True;
    // try JavaDoc TAG only if Prefix recognized
    if FInsideJavaDoc then
    begin
      if TryDecoratorComment(pcToken) then exit;
      if TryJavaDocTAGComment(pcToken) then exit;
      if TryInsideParamTAG(pcToken) then exit;
    end;
    if TryClosedBracketStarComment(pcToken) then exit;
    if TryInsideCurlyEmptyLine(pcToken) then exit;

    liCommentLength := 0;
    { default }
    // Strip buffer until Return or Closed Bracket
    while (( not CharIsReturn(ForwardChar(liCommentLength)) and (ForwardChars(liCommentLength,2)<>'*)')) and
      ( not EndOfFile)) do
    begin
      // #Riu N. Skip Double-bytes character
      {if Reader.Last in LeadBytes then
      begin
        Reader.IncBuffer
      end;
      Reader.IncBuffer;}
      if CheckMultiByte(ForwardChar(liCommentLength)) then inc(liCommentLength,2)
      else inc(liCommentLength,1);
    end;

    if ForwardChars(liCommentLength,2) = '*)' then
    begin
      // COmment line inside curly terminated by ClosedCurly
      //dec(liCommentLength,2);
      //Reader.DecBuffer;
      //Reader.DecBuffer;
      FBeginNewLine := False;
    end
    // Comment line inside curly terminated by EndOfLine
    else begin
      //dec(liCommentLength,1);
      //Reader.DecBuffer;
      FBeginNewLine := True;
    end;

    pcToken.TokenType := ttComment;
    if FInsideJavaDoc then
    begin
      pcToken.CommentStyle := eContentTAG
    end //eUnknownTAG;
    else      begin
      pcToken.CommentStyle := eStandard
    end;
    pcToken.SourceCode := pcToken.SourceCode + CurrentChars(liCommentLength);
    Consume(liCommentLength);
    Result := True;
  end;

begin
  Assert(FInsideBracketStarComment = True);

  // Skip space before
  // Read until CHAR<>SPACE or EndOfFile
  while CharIsWhiteSpaceNoReturn(Current) and ( not EndOfFile) do
  begin
    Consume(1);
  end;

  Result := DoAllInsideBracketStarTries(pcToken);
end;

function TBuildTokenList.TryClosedBracketStarComment(
  const pcToken: TSourceToken): boolean;
begin
  Result := False;
  if not (Current = '*') then exit;
  if ForwardChars(0,2) <> '*)' then exit;

  // Closed BracketStar comment detect
  FInsideBracketStarComment := False;
  FInsideJavaDoc := False;
  pcToken.TokenType := ttComment;
  pcToken.CommentStyle := eBracketStar;
  pcToken.SourceCode := pcToken.SourceCode + CurrentChars(2);
  Consume(2);
  Result := True;
end;

end.
