unit JclImports;
interface
Uses Windows,
     SysUtils,
     Classes;

type
  EJclError                  = class(Exception);
  EJclStringError            = EJclError;
  Float                      = Double;

  TDelTreeProgress           = function (const FileName: string; Attr: DWORD): Boolean;
  TFileListOption            = (flFullNames, flRecursive, flMaskedSubfolders);
  TFileListOptions           = set of TFileListOption;
  TJclAttributeMatch         = (amAny, amExact, amSubSetOf, amSuperSetOf, amCustom);
  TFileMatchFunc             = function(const Attr: Integer; const FileInfo: TSearchRec): Boolean;
  TFileHandler               = procedure (const FileName: string) of object;
  TFileHandlerEx             = procedure (const Directory: string; const FileInfo: TSearchRec) of object;

  TJclByteArray              = array [0..MaxInt div SizeOf(Byte) - 1] of Byte;
  PJclByteArray              = ^TJclByteArray;

const
  AnsiLineFeed               = AnsiChar(#10);
  AnsiCarriageReturn         = AnsiChar(#13);
  AnsiCrLf                   = AnsiString(#13#10);
  AnsiLineBreak              = AnsiCrLf;
  AnsiSigns                  = ['-', '+'];
  AnsiUppercaseLetters       = ['A'..'Z'];
  AnsiLowercaseLetters       = ['a'..'z'];
  AnsiLetters                = ['A'..'Z', 'a'..'z'];
  AnsiDecDigits              = ['0'..'9'];
  AnsiOctDigits              = ['0'..'7'];
  AnsiHexDigits              = ['0'..'9', 'A'..'F', 'a'..'f'];
  AnsiValidIdentifierLetters = ['0'..'9', 'A'..'Z', 'a'..'z', '_'];
  AnsiHexPrefixPascal        = AnsiString('$');
  AnsiHexPrefixC             = AnsiString('0x');
  AnsiHexPrefix              = AnsiHexPrefixPascal;
  AnsiNull                   = Char(#0);
  AnsiSoh                    = Char(#1);
  AnsiStx                    = Char(#2);
  AnsiEtx                    = Char(#3);
  AnsiEot                    = Char(#4);
  AnsiEnq                    = Char(#5);
  AnsiAck                    = Char(#6);
  AnsiBell                   = Char(#7);
  AnsiBackspace              = Char(#8);
  AnsiTab                    = Char(#9);
  AnsiVerticalTab            = Char(#11);
  AnsiFormFeed               = Char(#12);
  AnsiSo                     = Char(#14);
  AnsiSi                     = Char(#15);
  AnsiDle                    = Char(#16);
  AnsiDc1                    = Char(#17);
  AnsiDc2                    = Char(#18);
  AnsiDc3                    = Char(#19);
  AnsiDc4                    = Char(#20);
  AnsiNak                    = Char(#21);
  AnsiSyn                    = Char(#22);
  AnsiEtb                    = Char(#23);
  AnsiCan                    = Char(#24);
  AnsiEm                     = Char(#25);
  AnsiEndOfFile              = Char(#26);
  AnsiEscape                 = Char(#27);
  AnsiFs                     = Char(#28);
  AnsiGs                     = Char(#29);
  AnsiRs                     = Char(#30);
  AnsiUs                     = Char(#31);
  AnsiComma                  = Char(',');
  AnsiBackslash              = Char('\');
  AnsiForwardSlash           = Char('/');
  AnsiSpace                  = Char(' ');
  AnsiDoubleQuote            = Char('"');
  AnsiSingleQuote            = Char('''');
  AnsiWhiteSpace             = [AnsiTab, AnsiLineFeed, AnsiVerticalTab, AnsiFormFeed, AnsiCarriageReturn, AnsiSpace];


  DriveLetters               = ['a'..'z', 'A'..'Z'];
  PathDevicePrefix           = '\\.\';
  DirDelimiter               = '\';
  DirSeparator               = ';';
  PathUncPrefix              = '\\';

{ JclStrings }
function StrIsAlpha(const S: string): Boolean;
function StrIsAlphaNum(const S: string): Boolean;
function StrEnsureNoPrefix(const Prefix, Text: string): string;
function StrEnsureNoSuffix(const Suffix, Text: string): string;
function StrEnsurePrefix(const Prefix, Text: string): string;
function StrEnsureSuffix(const Suffix, Text: string): string;
function StrLower(const S: string): string;
procedure StrLowerInPlace(var S: string);
procedure StrReplace(var S: string; const Search, Replace: string; Flags: TReplaceFlags = []);
function StrRepeat(const S: string; Count: Integer): string;
function StrCharCount(const S: string; C: Char): Integer;
function StrStrCount(const S, SubS: string): Integer;
function StrFillChar(const C: Char; Count: Integer): string;
function StrFind(const Substr, S: string; const Index: Integer = 1): Integer;
function StrIndex(const S: string; const List: array of string): Integer;
function StrIsOneOf(const S: string; const List: array of string): Boolean;
function StrLastPos(const SubStr, S: string): Integer;
function StrMatches(const Substr, S: string; const Index: Integer = 1): Boolean;
function StrSearch(const Substr, S: string; const Index: Integer = 1): Integer;
function StrAfter(const SubStr, S: string): string;
function StrChopRight(const S: string; N: Integer): string;
function StrLeft(const S: string; Count: Integer): string;
function StrRestOf(const S: string; N: Integer): string;
function StrRight(const S: string; Count: Integer): string;
function CharIsAlpha(const C: Char): Boolean;
function CharIsAlphaNum(const C: Char): Boolean;
function CharIsControl(const C: Char): Boolean;
function CharIsDigit(const C: Char): Boolean;
function CharIsLower(const C: Char): Boolean;
function CharIsReturn(const C: Char): Boolean;
function CharIsUpper(const C: Char): Boolean;
function CharIsWhiteSpace(const C: Char): Boolean;
function CharUpper(const C: Char): Char;
function CharReplace(var S: string; const Search, Replace: Char): Integer;
procedure StrIToStrings(S, Sep: string; const List: TStrings; const AllowEmptyString: Boolean = True);
procedure StrToStrings(S, Sep: string; const List: TStrings; const AllowEmptyString: Boolean = True);
function StringsToStr(const List: TStrings; const Sep: string; const AllowEmptyString: Boolean = True): string;
function FileToString(const FileName: string): AnsiString;
function StrToken(var S: string; Separator: Char): string;
procedure StrTokenToStrings(S: string; Separator: Char; const List: TStrings);


{ JclFileUtils }
function PathAddSeparator(const Path: string): string;
function PathCanonicalize(const Path: string): string;
function PathExtractFileNameNoExt(const Path: string): string;
function PathGetRelativePath(Origin, Destination: string): string;
function PathIsAbsolute(const Path: string): Boolean;
function PathIsDiskDevice(const Path: string): Boolean;
function PathIsUNC(const Path: string): Boolean;
function PathRemoveSeparator(const Path: string): string;
function PathRemoveExtension(const Path: string): string;
function BuildFileList(const Path: string; const Attr: Integer; const List: TStrings): Boolean;
function AdvBuildFileList(const Path: string; const Attr: Integer; const Files: TStrings;
  const AttributeMatch: TJclAttributeMatch = amSuperSetOf; const Options: TFileListOptions = [];
  const SubfoldersMask: string = ''; const FileMatchFunc: TFileMatchFunc = nil): Boolean;
function IsFileNameMatch(FileName: string; const Mask: string; const CaseSensitive: Boolean = False): Boolean;
function DelTreeEx(const Path: string; AbortOnFailure: Boolean; Progress: TDelTreeProgress): Boolean;
function FileDelete(const FileName: string; MoveToTrash : Boolean = False): Boolean;

{ JclSysUtils }
function IsObject(Address: Pointer): Boolean;
function IntToStrZeroPad(Value, Count: Integer): AnsiString;

{JclMath}
function Crc16_P(X: PJclByteArray; N: Integer; Crc: Word = 0): Word;
function Crc16(const X: array of Byte; N: Integer; Crc: Word = 0): Word;
function Crc16_A(const X: array of Byte; Crc: Word = 0): Word;

{ JvStrToHtml }
function StringToHtml(const Value: string): string;
function HtmlToString(const Value: string): string;
function CharToHtml(Ch: Char): string;

implementation

{ JclStrings }

type
  TAnsiStrRec = packed record
    AllocSize: Longint;
    RefCount: Longint;
    Length: Longint;
  end;

const
  AnsiStrRecSize  = SizeOf(TAnsiStrRec);     // size of the string header rec
  AnsiCharCount   = Ord(High(Char)) + 1; // # of chars in one set
  AnsiLoOffset    = AnsiCharCount * 0;       // offset to lower case chars
  AnsiUpOffset    = AnsiCharCount * 1;       // offset to upper case chars
  AnsiReOffset    = AnsiCharCount * 2;       // offset to reverse case chars
  AnsiAlOffset    = 12;                      // offset to AllocSize in StrRec
  AnsiRfOffset    = 8;                       // offset to RefCount in StrRec
  AnsiLnOffset    = 4;                       // offset to Length in StrRec
  AnsiCaseMapSize = AnsiCharCount * 3;       // # of chars is a table

var
  AnsiCaseMap: array [0..AnsiCaseMapSize - 1] of Char; // case mappings
  AnsiCaseMapReady: Boolean = False;         // true if case map exists
  AnsiCharTypes: array [Char] of Word;

function Min(const B1, B2: Integer): Integer;
begin
  if B1 < B2 then
    Result := B1
  else
    Result := B2;
end;

function Max(const B1, B2: Integer): Integer;
begin
  if B1 > B2 then
    Result := B1
  else
    Result := B2;
end;

procedure LoadCharTypes;
var
  CurrChar: Char;
  CurrType: Word;
begin
  for CurrChar := Low(Char) to High(Char) do
  begin
    GetStringTypeExA(LOCALE_USER_DEFAULT, CT_CTYPE1, @CurrChar, SizeOf(Char), CurrType);
    AnsiCharTypes[CurrChar] := CurrType;
  end;
end;

procedure LoadCaseMap;
var
  CurrChar, UpCaseChar, LoCaseChar, ReCaseChar: Char;
begin
  if not AnsiCaseMapReady then
  begin
    for CurrChar := Low(Char) to High(Char) do
    begin
      LoCaseChar := CurrChar;
      UpCaseChar := CurrChar;
      Windows.CharLowerBuff(@LoCaseChar, 1);
      Windows.CharUpperBuff(@UpCaseChar, 1);

      if CharIsUpper(CurrChar) then
        ReCaseChar := LoCaseChar
      else
        if CharIsLower(CurrChar) then
          ReCaseChar := UpCaseChar
        else
          ReCaseChar := CurrChar;
      AnsiCaseMap[Ord(CurrChar) + AnsiLoOffset] := LoCaseChar;
      AnsiCaseMap[Ord(CurrChar) + AnsiUpOffset] := UpCaseChar;
      AnsiCaseMap[Ord(CurrChar) + AnsiReOffset] := ReCaseChar;
    end;
    AnsiCaseMapReady := True;
  end;
end;

procedure StrCase(var Str: string; const Offset: Integer); register; assembler;
asm
        // make sure that the string is not null

        TEST    EAX, EAX
        JZ      @@StrIsNull

        // create unique string if this one is ref-counted

        PUSH    EDX
        CALL    UniqueString
        POP     EDX

        // make sure that the new string is not null

        TEST    EAX, EAX
        JZ      @@StrIsNull

        // get the length, and prepare the counter

        MOV     ECX, [EAX - AnsiStrRecSize].TAnsiStrRec.Length
        DEC     ECX
        JS      @@StrIsNull

        // ebx will hold the case map, esi pointer to Str

        PUSH    EBX
        PUSH    ESI
        PUSH    EDI

        // load case map and prepare variables }

        {$IFDEF PIC}
        LEA     EBX, [EBX][AnsiCaseMap + EDX]
        {$ELSE}
        LEA     EBX, [AnsiCaseMap + EDX]
        {$ENDIF PIC}
        MOV     ESI, EAX
        XOR     EDX, EDX
        XOR     EAX, EAX

@@NextChar:
        // get current char from the string

        MOV     DL, [ESI]

        // get corresponding char from the case map

        MOV     AL, [EBX + EDX]

        // store it back in the string

        MOV     [ESI], AL

        // update the loop counter and check the end of stirng

        DEC     ECX
        JL      @@Done

        // do the same thing with next 3 chars

        MOV     DL, [ESI + 1]
        MOV     AL, [EBX + EDX]
        MOV     [ESI + 1], AL

        DEC     ECX
        JL      @@Done
        MOV     DL, [ESI + 2]
        MOV     AL, [EBX+EDX]
        MOV     [ESI + 2], AL

        DEC     ECX
        JL      @@Done
        MOV     DL, [ESI + 3]
        MOV     AL, [EBX + EDX]
        MOV     [ESI + 3], AL

        // point string to next 4 chars

        ADD     ESI, 4

        // update the loop counter and check the end of stirng

        DEC     ECX
        JGE     @@NextChar

@@Done:
        POP     EDI
        POP     ESI
        POP     EBX

@@StrIsNull:
end;

function StrIsAlpha(const S: string): Boolean;
var
  I: Integer;
begin
  Result := S <> '';
  for I := 1 to Length(S) do
  begin
    if not CharIsAlpha(S[I]) then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

function StrIsAlphaNum(const S: string): Boolean;
var
  I: Integer;
begin
  Result := S <> '';
  for I := 1 to Length(S) do
  begin
    if not CharIsAlphaNum(S[I]) then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

function StrEnsureNoPrefix(const Prefix, Text: string): string;
var
  PrefixLen : Integer;
begin
  PrefixLen := Length(Prefix);
  if Copy(Text, 1, PrefixLen) = Prefix then
    Result := Copy(Text, PrefixLen + 1, Length(Text))
  else
    Result := Text;
end;

function StrEnsureNoSuffix(const Suffix, Text: string): string;
var
  SuffixLen : Integer;
  StrLength : Integer;
begin
  SuffixLen := Length(Suffix);
  StrLength := Length(Text);
  if Copy(Text, StrLength - SuffixLen + 1, SuffixLen) = Suffix then
    Result := Copy(Text, 1, StrLength - SuffixLen)
  else
    Result := Text;
end;

function StrEnsurePrefix(const Prefix, Text: string): string;
var
  PrefixLen: Integer;
begin
  PrefixLen := Length(Prefix);
  if Copy(Text, 1, PrefixLen) = Prefix then
    Result := Text
  else
    Result := Prefix + Text;
end;

function StrEnsureSuffix(const Suffix, Text: string): string;
var
  SuffixLen: Integer;
begin
  SuffixLen := Length(Suffix);
  if Copy(Text, Length(Text) - SuffixLen + 1, SuffixLen) = Suffix then
    Result := Text
  else
    Result := Text + Suffix;
end;

procedure StrLowerInPlace(var S: string);
begin
  StrCase(S, AnsiLoOffset);
end;

function StrLower(const S: string): string;
begin
  Result := S;
  StrLowerInPlace(Result);
end;

function StrRepeat(const S: string; Count: Integer): string;
var
  Len, Index: Integer;
  Dest, Source: PChar;
begin
  Len := Length(S);
  SetLength(Result, Count * Len);
  Dest := PChar(Result);
  Source := PChar(S);
  if Dest <> nil then
    for Index := 0 to Count - 1 do
  begin
    Move(Source^, Dest^, Len*SizeOf(Char));
    Inc(Dest,Len*SizeOf(Char));
  end;
end;

procedure StrReplace(var S: string; const Search, Replace: string; Flags: TReplaceFlags);
var
  SearchStr: string;
  ResultStr: string; { result string }
  SourcePtr: PChar;      { pointer into S of character under examination }
  SourceMatchPtr: PChar; { pointers into S and Search when first character has }
  SearchMatchPtr: PChar; { been matched and we're probing for a complete match }
  ResultPtr: PChar;      { pointer into Result of character being written }
  ResultIndex,
  SearchLength,          { length of search string }
  ReplaceLength,         { length of replace string }
  BufferLength,          { length of temporary result buffer }
  ResultLength: Integer; { length of result string }
  C: Char;               { first character of search string }
  IgnoreCase: Boolean;
begin
  if Search = '' then
    if S = '' then
    begin
      S := Replace;
      Exit;
    end
    else
      raise EJclStringError.Create('@RsBlankSearchString');

  if S <> '' then
  begin
    IgnoreCase := rfIgnoreCase in Flags;
    if IgnoreCase then
      SearchStr := AnsiUpperCase(Search)
    else
      SearchStr := Search;
    { avoid having to call Length() within the loop }
    SearchLength := Length(Search);
    ReplaceLength := Length(Replace);
    ResultLength := Length(S);
    BufferLength := ResultLength;
    SetLength(ResultStr, BufferLength);
    { get pointers to begin of source and result }
    ResultPtr := PChar(ResultStr);
    SourcePtr := PChar(S);
    C := SearchStr[1];
    { while we haven't reached the end of the string }
    while True do
    begin
      { copy characters until we find the first character of the search string }
      if IgnoreCase then
        while (CharUpper(SourcePtr^) <> C) and (SourcePtr^ <> #0) do
        begin
          ResultPtr^ := SourcePtr^;
          Inc(ResultPtr);
          Inc(SourcePtr);
        end
      else
        while (SourcePtr^ <> C) and (SourcePtr^ <> #0) do
        begin
          ResultPtr^ := SourcePtr^;
          Inc(ResultPtr);
          Inc(SourcePtr);
        end;
      { did we find that first character or did we hit the end of the string? }
      if SourcePtr^ = #0 then
        Break
      else
      begin
        { continue comparing, +1 because first character was matched already }
        SourceMatchPtr := SourcePtr + 1;
        SearchMatchPtr := PChar(SearchStr) + 1;
        if IgnoreCase then
          while (CharUpper(SourceMatchPtr^) = SearchMatchPtr^) and (SearchMatchPtr^ <> #0) do
          begin
            Inc(SourceMatchPtr);
            Inc(SearchMatchPtr);
          end
        else
          while (SourceMatchPtr^ = SearchMatchPtr^) and (SearchMatchPtr^ <> #0) do
          begin
            Inc(SourceMatchPtr);
            Inc(SearchMatchPtr);
          end;
        { did we find a complete match? }
        if SearchMatchPtr^ = #0 then
        begin
          // keep track of result length
          Inc(ResultLength, ReplaceLength - SearchLength);
          if ReplaceLength > 0 then
          begin
            // increase buffer size if required
            if ResultLength > BufferLength then
            begin
              BufferLength := ResultLength * 2;
              ResultIndex := ResultPtr - PChar(ResultStr) + 1;
              SetLength(ResultStr, BufferLength);
              ResultPtr := @ResultStr[ResultIndex];
            end;
            { append replace to result and move past the search string in source }
            Move((@Replace[1])^, ResultPtr^, ReplaceLength);
          end;
          Inc(SourcePtr, SearchLength);
          Inc(ResultPtr, ReplaceLength);
          { replace all instances or just one? }
          if not (rfReplaceAll in Flags) then
          begin
            { just one, copy until end of source and break out of loop }
            while SourcePtr^ <> #0 do
            begin
              ResultPtr^ := SourcePtr^;
              Inc(ResultPtr);
              Inc(SourcePtr);
            end;
            Break;
          end;
        end
        else
        begin
          { copy current character and start over with the next }
          ResultPtr^ := SourcePtr^;
          Inc(ResultPtr);
          Inc(SourcePtr);
        end;
      end;
    end;
    { set result length and copy result into S }
    SetLength(ResultStr, ResultLength);
    S := ResultStr;
  end;
end;

function StrCharCount(const S: string; C: Char): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to Length(S) do
    if S[I] = C then
      Inc(Result);
end;

function StrStrCount(const S, SubS: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  if (Length(SubS) > Length(S)) or (Length(SubS) = 0) or (Length(S) = 0) then
    Exit;
  if Length(SubS) = 1 then
  begin
    Result := StrCharCount(S, SubS[1]);
    Exit;
  end;
  I := StrSearch(SubS, S, 1);

  if I > 0 then
    Inc(Result);

  while (I > 0) and (Length(S) > I+Length(SubS)) do
  begin
    I := StrSearch(SubS, S, I+1);

    if I > 0 then
      Inc(Result);
  end
end;

function StrFillChar(const C: Char; Count: Integer): string;
begin
  SetLength(Result, Count);
  if (Count > 0) then
    FillChar(Result[1], Count, Ord(C));
end;

function StrFind(const Substr, S: string; const Index: Integer): Integer; assembler;
const
   SearchChar: Byte = 0;
   NumberOfChars: Integer = 0;
asm
        // if SubStr = '' then  Return := 0;

        TEST    EAX, EAX
        JZ      @@SubstrIsNull

        // if Str = '' then  Return := 0;

        TEST    EDX, EDX
        JZ      @@StrIsNull

        // Index := Index - 1; if Index < 0 then Return := 0;

        DEC     ECX
        JL      @@IndexIsSmall

        // EBX will hold the case table, ESI pointer to Str, EDI pointer
        // to Substr and - # of chars in Substr to compare

        PUSH    EBX
        PUSH    ESI
        PUSH    EDI

        // set the string pointers

        MOV     ESI, EDX
        MOV     EDI, EAX

        // save the Index in EDX

        MOV     EDX, ECX

        // temporary get the length of Substr and Str

        MOV     EBX, [EDI - AnsiStrRecSize].TAnsiStrRec.Length
        MOV     ECX, [ESI - AnsiStrRecSize].TAnsiStrRec.Length

        // save the address of Str to compute the result

        PUSH    ESI

        // dec the length of Substr because the first char is brought out of it

        DEC     EBX
        JS      @@NotFound

        // #positions in Str to look at = Length(Str) - Length(Substr) - Index - 2

        SUB     ECX, EBX
        JLE     @@NotFound

        SUB     ECX, EDX
        JLE     @@NotFound

        // # of chars in Substr to compare

        MOV     NumberOfChars, EBX

        // point Str to Index'th char

        ADD     ESI, EDX

        // load case map into EBX, and clear EAX

        LEA     EBX, AnsiCaseMap
        XOR     EAX, EAX
        XOR     EDX, EDX

        // bring the first char out of the Substr and point Substr to the next char

        MOV     DL, [EDI]
        INC     EDI

        // lower case it

        MOV     DL, [EBX + EDX]
        MOV     SearchChar, DL

        JMP     @@Find

@@FindNext:

        // update the loop counter and check the end of string.
        // if we reached the end, Substr was not found.

        DEC     ECX
        JL      @@NotFound

@@Find:

        // get current char from the string, and point Str to the next one

        MOV     AL, [ESI]
        INC     ESI


        // lower case current char

        MOV     AL, [EBX + EAX]

        // does current char match primary search char? if not, go back to the main loop

        CMP     AL, SearchChar
        JNE     @@FindNext

@@Compare:

        // # of chars in Substr to compare

        MOV     EDX, NumberOfChars

@@CompareNext:

        // dec loop counter and check if we reached the end. If yes then we found it

        DEC     EDX
        JL      @@Found

        // get the chars from Str and Substr, if they are equal then continue comparing

        MOV     AL, [ESI + EDX]
        CMP     AL, [EDI + EDX]
        JE      @@CompareNext

        // otherwise try the reverse case. If they still don't match go back to the Find loop

        MOV     AL, [EBX + EAX + AnsiReOffset]
        CMP     AL, [EDI + EDX]
        JNE     @@FindNext

        // if they matched, continue comparing

        JMP     @@CompareNext

@@Found:
        // we found it, calculate the result

        MOV     EAX, ESI
        POP     ESI
        SUB     EAX, ESI

        POP     EDI
        POP     ESI
        POP     EBX
        RET

@@NotFound:

        // not found it, clear the result

        XOR     EAX, EAX
        POP     ESI
        POP     EDI
        POP     ESI
        POP     EBX
        RET

@@IndexIsSmall:
@@StrIsNull:

        // clear the result

        XOR     EAX, EAX

@@SubstrIsNull:
@@Exit:
end;

function StrIndex(const S: string; const List: array of string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := Low(List) to High(List) do
  begin
    if AnsiSameText(S, List[I]) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function StrIsOneOf(const S: string; const List: array of string): Boolean;
begin
  Result := StrIndex(S, List) > -1;
end;

function StrLastPos(const SubStr, S: string): Integer;
var
  Last, Current: PChar;
begin
  Result := 0;
  Last := nil;
  Current := PChar(S);

  while (Current <> nil) and (Current^ <> #0) do
  begin
    Current := AnsiStrPos(PChar(Current), PChar(SubStr));
    if Current <> nil then
    begin
      Last := Current;
      Inc(Current);
    end;
  end;
  if Last <> nil then
    Result := Abs((Longint(PChar(S)) - Longint(Last)) div SizeOf(Char)) + 1;
end;

function StrMatches(const Substr, S: string; const Index: Integer): Boolean;
var
  StringPtr: PChar;
  PatternPtr: PChar;
  StringRes: PChar;
  PatternRes: PChar;
begin
  if SubStr = '' then
    raise EJclStringError.Create('@RsBlankSearchString');

  Result := SubStr = '*';

  if Result or (S = '') then
    Exit;

  if (Index <= 0) or (Index > Length(S)) then
    raise EJclStringError.Create('@RsArgumentOutOfRange');

  StringPtr := PChar(@S[Index]);
  PatternPtr := PChar(SubStr);
  StringRes := nil;
  PatternRes := nil;

  repeat
    repeat
      case PatternPtr^ of
        #0:
          begin
            Result := StringPtr^ = #0;
            if Result or (StringRes = nil) or (PatternRes = nil) then
              Exit;

            StringPtr := StringRes;
            PatternPtr := PatternRes;
            Break;
          end;
        '*':
          begin
            Inc(PatternPtr);
            PatternRes := PatternPtr;
            Break;
          end;
        '?':
          begin
            if StringPtr^ = #0 then
              Exit;
            Inc(StringPtr);
            Inc(PatternPtr);
          end;
        else
          begin
            if StringPtr^ = #0 then
              Exit;
            if StringPtr^ <> PatternPtr^ then
            begin
              if (StringRes = nil) or (PatternRes = nil) then
                Exit;
              StringPtr := StringRes;
              PatternPtr := PatternRes;
              Break;
            end
            else
            begin
              Inc(StringPtr);
              Inc(PatternPtr);
            end;
          end;
      end;
    until False;

    repeat
      case PatternPtr^ of
        #0:
          begin
            Result := True;
            Exit;
          end;
        '*':
          begin
            Inc(PatternPtr);
            PatternRes := PatternPtr;
          end;
        '?':
          begin
            if StringPtr^ = #0 then
              Exit;
            Inc(StringPtr);
            Inc(PatternPtr);
          end;
        else
          begin
            repeat
              if StringPtr^ = #0 then
                Exit;
              if StringPtr^ = PatternPtr^ then
                Break;
              Inc(StringPtr);
            until False;
            Inc(StringPtr);
            StringRes := StringPtr;
            Inc(PatternPtr);
            Break;
          end;
      end;
    until False;
  until False;
end;

function StrSearch(const Substr, S: string; const Index: Integer): Integer; assembler;
asm
        // make sure that strings are not null

        TEST    EAX, EAX
        JZ      @@SubstrIsNull

        TEST    EDX, EDX
        JZ      @@StrIsNull

        // limit index to satisfy 1 <= index, and dec it

        DEC     ECX
        JL      @@IndexIsSmall

        // ebp will hold # of chars in Substr to compare, esi pointer to Str,
        // edi pointer to Substr, ebx primary search char

        PUSH    EBX
        PUSH    ESI
        PUSH    EDI
        PUSH    EBP

        // set the string pointers

        MOV     ESI, EDX
        MOV     EDI, EAX

        // save the (Index - 1) in edx

        MOV     EDX, ECX

        // save the address of Str to compute the result

        PUSH    ESI

        // temporary get the length of Substr and Str

        MOV     EBX, [EDI-AnsiStrRecSize].TAnsiStrRec.Length
        MOV     ECX, [ESI-AnsiStrRecSize].TAnsiStrRec.Length

        // dec the length of Substr because the first char is brought out of it

        DEC     EBX
        JS      @@NotFound

        // # of positions in Str to look at = Length(Str) - Length(Substr) - Index - 2

        SUB     ECX, EBX
        JLE     @@NotFound

        SUB     ECX, EDX
        JLE     @@NotFound

        // point Str to Index'th char

        ADD     ESI, EDX

        // # of chars in Substr to compare

        MOV     EBP, EBX

        // clear EAX & ECX (working regs)

        XOR     EAX, EAX
        XOR     EBX, EBX

        // bring the first char out of the Substr, and
        // point Substr to the next char

        MOV     BL, [EDI]
        INC     EDI

        // jump into the loop

        JMP     @@Find

@@FindNext:

        // update the loop counter and check the end of string.
        // if we reached the end, Substr was not found.

        DEC     ECX
        JL      @@NotFound

@@Find:

        // get current char from the string, and /point Str to the next one.
        MOV     AL, [ESI]
        INC     ESI

        // does current char match primary search char? if not, go back to the main loop

        CMP     AL, BL
        JNE     @@FindNext

        // otherwise compare SubStr

@@Compare:

        // move # of char to compare into edx, edx will be our compare loop counter.

        MOV     EDX, EBP

@@CompareNext:

        // check if we reached the end of Substr. If yes we found it.

        DEC     EDX
        JL      @@Found

        // get last chars from Str and SubStr and compare them,
        // if they don't match go back to out main loop.

        MOV     AL, [EDI+EDX]
        CMP     AL, [ESI+EDX]
        JNE     @@FindNext

        // if they matched, continue comparing

        JMP     @@CompareNext

@@Found:
        // we found it, calculate the result and exit.

        MOV     EAX, ESI
        POP     ESI
        SUB     EAX, ESI

        POP     EBP
        POP     EDI
        POP     ESI
        POP     EBX
        RET

@@NotFound:
        // not found it, clear result and exit.

        XOR     EAX, EAX
        POP     ESI
        POP     EBP
        POP     EDI
        POP     ESI
        POP     EBX
        RET

@@IndexIsSmall:
@@StrIsNull:
        // clear result and exit.

        XOR     EAX, EAX

@@SubstrIsNull:
@@Exit:
end;

function StrAfter(const SubStr, S: string): string;
var
  P: Integer;
begin
  P := StrFind(SubStr, S, 1); // StrFind is case-insensitive pos
  if P <= 0 then
    Result := ''           // substr not found -> nothing after it
  else
    Result := StrRestOf(S, P + Length(SubStr));
end;

function StrChopRight(const S: string; N: Integer): string;
begin
  Result := Copy(S, 1, Length(S) - N);
end;

function StrLeft(const S: string; Count: Integer): string;
begin
  Result := Copy(S, 1, Count);
end;


function StrRestOf(const S: string; N: Integer ): string;
begin
  Result := Copy(S, N, (Length(S) - N + 1));
end;

function StrRight(const S: string; Count: Integer): string;
begin
  Result := Copy(S, Length(S) - Count + 1, Count);
end;

function CharIsAlpha(const C: Char): Boolean;
begin
  Result := (AnsiCharTypes[C] and C1_ALPHA) <> 0;
end;

function CharIsAlphaNum(const C: Char): Boolean;
begin
  Result := ((AnsiCharTypes[C] and C1_ALPHA) <> 0) or
    ((AnsiCharTypes[C] and C1_DIGIT) <> 0);
end;

function CharIsControl(const C: Char): Boolean;
begin
  Result := (AnsiCharTypes[C] and C1_CNTRL) <> 0;
end;

function CharIsDelete(const C: Char): Boolean;
begin
  Result := (C = #8);
end;

function CharIsDigit(const C: Char): Boolean;
begin
  Result := (AnsiCharTypes[C] and C1_DIGIT) <> 0;
end;

function CharIsLower(const C: Char): Boolean;
begin
  Result := (AnsiCharTypes[C] and C1_LOWER) <> 0;
end;

function CharIsReturn(const C: Char): Boolean;
begin
  Result := (C = AnsiLineFeed) or (C = AnsiCarriageReturn);
end;

function CharIsUpper(const C: Char): Boolean;
begin
  Result := (AnsiCharTypes[C] and C1_UPPER) <> 0;
end;

function CharIsWhiteSpace(const C: Char): Boolean;
begin
  Result := C in AnsiWhiteSpace;
end;

function CharUpper(const C: Char): Char;
begin
  Result := AnsiCaseMap[Ord(C) + AnsiUpOffset];
end;

function CharReplace(var S: string; const Search, Replace: Char): Integer;
var
  P: PChar;
  Index, Len: Integer;
begin
  Result := 0;
  if Search <> Replace then
  begin
    UniqueString(S);
    P := PChar(S);
    Len := Length(S);
    for Index := 0 to Len-1 do
    begin
      if P^ = Search then
      begin
        P^ := Replace;
        Inc(Result);
      end;
      Inc(P);
    end;
  end;
end;

procedure StrToStrings(S, Sep: string; const List: TStrings; const AllowEmptyString: Boolean = True);
var
  I, L: Integer;
  Left: string;
begin
  Assert(List <> nil);
  List.BeginUpdate;
  try
    List.Clear;
    L := Length(Sep);
    I := Pos(Sep, S);
    while I > 0 do
    begin
      Left := StrLeft(S, I - 1);
      if (Left <> '') or AllowEmptyString then
        List.Add(Left);
      Delete(S, 1, I + L - 1);
      I := Pos(Sep, S);
    end;
    if S <> '' then
      List.Add(S);  // Ignore empty strings at the end.
  finally
    List.EndUpdate;
  end;
end;

procedure StrIToStrings(S, Sep: string; const List: TStrings; const AllowEmptyString: Boolean = True);
var
  I, L: Integer;
  LowerCaseStr: string;
  Left: string;
begin
  Assert(List <> nil);
  LowerCaseStr := StrLower(S);
  Sep := StrLower(Sep);
  L := Length(Sep);
  I := Pos(Sep, LowerCaseStr);
  List.BeginUpdate;
  try
    List.Clear;
    while I > 0 do
    begin
      Left := StrLeft(S, I - 1);
      if (Left <> '') or AllowEmptyString then
        List.Add(Left);
      Delete(S, 1, I + L - 1);
      Delete(LowerCaseStr, 1, I + L - 1);
      I := Pos(Sep, LowerCaseStr);
    end;
    if S <> '' then
      List.Add(S);  // Ignore empty strings at the end.
  finally
    List.EndUpdate;
  end;
end;

function StringsToStr(const List: TStrings; const Sep: string; const AllowEmptyString: Boolean): string;
var
  I, L: Integer;
begin
  Result := '';
  for I := 0 to List.Count - 1 do
  begin
    if (List[I] <> '') or AllowEmptyString then
    begin
      // don't combine these into one addition, somehow it hurts performance
      Result := Result + List[I];
      Result := Result + Sep;
    end;
  end;
  // remove terminating separator
  if List.Count <> 0 then
  begin
    L := Length(Sep);
    Delete(Result, Length(Result) - L + 1, L);
  end;
end;

function FileToString(const FileName: string): AnsiString;
var
  fs: TFileStream;
  Len: Integer;
begin
  fs := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    Len := fs.Size;
    SetLength(Result, Len);
    if Len > 0 then
      fs.ReadBuffer(Result[1], Len);
  finally
    fs.Free;
  end;
end;

function StrToken(var S: string; Separator: Char): string;
var
  I: Integer;
begin
  I := Pos(Separator, S);
  if I <> 0 then
  begin
    Result := Copy(S, 1, I - 1);
    Delete(S, 1, I);
  end
  else
  begin
    Result := S;
    S := '';
  end;
end;

procedure StrTokenToStrings(S: string; Separator: Char; const List: TStrings);
var
  Token: string;
begin
  Assert(List <> nil);

  if List = nil then
    Exit;

  List.BeginUpdate;
  try
    List.Clear;
    while S <> '' do
    begin
      Token := StrToken(S, Separator);
      List.Add(Token);
    end;
  finally
    List.EndUpdate;
  end;
end;

{ JclMath }

const
  Crc16Table: array [0..255] of Word = (
    $0000, $1021, $2042, $3063, $4084, $50A5, $60C6, $70E7,
    $8108, $9129, $A14A, $B16B, $C18C, $D1AD, $E1CE, $F1EF,
    $1231, $0210, $3273, $2252, $52B5, $4294, $72F7, $62D6,
    $9339, $8318, $B37B, $A35A, $D3BD, $C39C, $F3FF, $E3DE,
    $2462, $3443, $0420, $1401, $64E6, $74C7, $44A4, $5485,
    $A56A, $B54B, $8528, $9509, $E5EE, $F5CF, $C5AC, $D58D,
    $3653, $2672, $1611, $0630, $76D7, $66F6, $5695, $46B4,
    $B75B, $A77A, $9719, $8738, $F7DF, $E7FE, $D79D, $C7BC,
    $48C4, $58E5, $6886, $78A7, $0840, $1861, $2802, $3823,
    $C9CC, $D9ED, $E98E, $F9AF, $8948, $9969, $A90A, $B92B,
    $5AF5, $4AD4, $7AB7, $6A96, $1A71, $0A50, $3A33, $2A12,
    $DBFD, $CBDC, $FBBF, $EB9E, $9B79, $8B58, $BB3B, $AB1A,
    $6CA6, $7C87, $4CE4, $5CC5, $2C22, $3C03, $0C60, $1C41,
    $EDAE, $FD8F, $CDEC, $DDCD, $AD2A, $BD0B, $8D68, $9D49,
    $7E97, $6EB6, $5ED5, $4EF4, $3E13, $2E32, $1E51, $0E70,
    $FF9F, $EFBE, $DFDD, $CFFC, $BF1B, $AF3A, $9F59, $8F78,
    $9188, $81A9, $B1CA, $A1EB, $D10C, $C12D, $F14E, $E16F,
    $1080, $00A1, $30C2, $20E3, $5004, $4025, $7046, $6067,
    $83B9, $9398, $A3FB, $B3DA, $C33D, $D31C, $E37F, $F35E,
    $02B1, $1290, $22F3, $32D2, $4235, $5214, $6277, $7256,
    $B5EA, $A5CB, $95A8, $8589, $F56E, $E54F, $D52C, $C50D,
    $34E2, $24C3, $14A0, $0481, $7466, $6447, $5424, $4405,
    $A7DB, $B7FA, $8799, $97B8, $E75F, $F77E, $C71D, $D73C,
    $26D3, $36F2, $0691, $16B0, $6657, $7676, $4615, $5634,
    $D94C, $C96D, $F90E, $E92F, $99C8, $89E9, $B98A, $A9AB,
    $5844, $4865, $7806, $6827, $18C0, $08E1, $3882, $28A3,
    $CB7D, $DB5C, $EB3F, $FB1E, $8BF9, $9BD8, $ABBB, $BB9A,
    $4A75, $5A54, $6A37, $7A16, $0AF1, $1AD0, $2AB3, $3A92,
    $FD2E, $ED0F, $DD6C, $CD4D, $BDAA, $AD8B, $9DE8, $8DC9,
    $7C26, $6C07, $5C64, $4C45, $3CA2, $2C83, $1CE0, $0CC1,
    $EF1F, $FF3E, $CF5D, $DF7C, $AF9B, $BFBA, $8FD9, $9FF8,
    $6E17, $7E36, $4E55, $5E74, $2E93, $3EB2, $0ED1, $1EF0
   );
  Crc16Start: Cardinal = $FFFF;

const
  Crc16Bits = 16;
  Crc16Bytes = 2;
  Crc16HighBit = $8000;
  NotCrc16HighBit = $7FFF;

function Crc16_P(X: PJclByteArray; N: Integer; Crc: Word = 0): Word;
var
  I: Integer;
begin
  Result := Crc16Start;
  for I := 0 to N - 1 do // The CRC Bytes are located at the end of the information
    // a 16 bit value shr 8 is a Byte, explictit type conversion to Byte adds an ASM instruction
    Result := Crc16Table[Result shr (CRC16Bits - 8)] xor Word((Result shl 8)) xor X[I];
  for I := 0 to Crc16Bytes - 1 do
  begin
    // a 16 bit value shr 8 is a Byte, explictit type conversion to Byte adds an ASM instruction
    Result := Crc16Table[Result shr (CRC16Bits-8)] xor Word((Result shl 8)) xor (Crc shr (CRC16Bits-8));
    Crc := Word(Crc shl 8);
  end;
end;

function Crc16(const X: array of Byte; N: Integer; Crc: Word = 0): Word;
begin
  Result := Crc16_P(@X, N, Crc);
end;

function Crc16_A(const X: array of Byte; Crc: Word = 0): Word;
begin
  Result := Crc16_P(@X, Length(X), Crc);
end;

{ JclFileUtils }
function PathAddSeparator(const Path: string): string;
begin
  Result := Path;
  if (Path = '') or (AnsiLastChar(Path) <> DirDelimiter) then
     Result := Path + DirDelimiter;
end;

function PathCanonicalize(const Path: string): string;
var
  List: TStringList;
  S: string;
  I, K: Integer;
  IsAbsolute: Boolean;
begin
  I := Pos(':', Path); // for Windows' sake
  K := Pos(DirDelimiter, Path);
  IsAbsolute := K - I = 1;
  if not IsAbsolute then
    K := I;
  if K = 0 then
    S := Path
  else
    S := Copy(Path, K + 1, Length(Path));
  List := TStringList.Create;
  try
    StrIToStrings(S, DirDelimiter, List, False);
    I := 0;
    while I < List.Count do
    begin
      if List[I] = '.' then
        List.Delete(I)
      else
      if (IsAbsolute or (I > 0) and not (List[I-1] = '..')) and (List[I] = '..') then
      begin
        List.Delete(I);
        if I > 0 then
        begin
          Dec(I);
          List.Delete(I);
        end;
      end
      else Inc(I);
    end;
    Result := StringsToStr(List, DirDelimiter, False);
  finally
    List.Free;
  end;
  if K > 0 then
    Result := Copy(Path, 1, K) + Result
  else
  if Result = '' then
    Result := '.';
end;

function PathExtractFileNameNoExt(const Path: string): string;
begin
  Result := PathRemoveExtension(ExtractFileName(Path));
end;

function PathGetRelativePath(Origin, Destination: string): string;
var
  OrigDrive: string;
  DestDrive: string;
  OrigList: TStringList;
  DestList: TStringList;
  DiffIndex: Integer;
  I: Integer;

  function StartsFromRoot(const Path: string): Boolean;
  var
    I: Integer;
  begin
    I := Length(ExtractFileDrive(Path));
    Result := (Length(Path) > I) and (Path[I + 1] = DirDelimiter);
  end;

  function Equal(const Path1, Path2: AnsiString): Boolean;
  begin
    Result := AnsiSameText(Path1, Path2);
  end;

begin
  Origin := PathCanonicalize(Origin);
  Destination := PathCanonicalize(Destination);
  OrigDrive := ExtractFileDrive(Origin);
  DestDrive := ExtractFileDrive(Destination);

  if Equal(Origin, Destination) or (Destination = '') then
    Result := '.'
  else
  if Origin = '' then
    Result := Destination
  else
  if (DestDrive <> '') and ((OrigDrive = '') or ((OrigDrive <> '') and not Equal(OrigDrive, DestDrive))) then
    Result := Destination
  else
  if (OrigDrive <> '') and (Pos(DirDelimiter, Destination) = 1) then
    Result := OrigDrive + Destination  // prepend drive part from Origin
  else
  if StartsFromRoot(Origin) and not StartsFromRoot(Destination) then
    Result := StrEnsureSuffix(DirDelimiter, Origin) +
      StrEnsureNoPrefix(DirDelimiter, Destination)
  else
  begin
    // create a list of paths as separate strings
    OrigList := TStringList.Create;
    DestList := TStringList.Create;
    try
      // NOTE: DO NOT USE DELIMITER AND DELIMITEDTEXT FROM
      // TSTRINGS, THEY WILL SPLIT PATHS WITH SPACES !!!!
      StrToStrings(Origin, DirDelimiter, OrigList);
      StrToStrings(Destination, DirDelimiter, DestList);
      begin
        // find the first directory that is not the same
        DiffIndex := OrigList.Count;
        if DestList.Count < DiffIndex then
          DiffIndex := DestList.Count;
        for I := 0 to DiffIndex - 1 do
          if not Equal(OrigList[I], DestList[I]) then
          begin
            DiffIndex := I;
            Break;
          end;
        Result := StrRepeat('..' + DirDelimiter, OrigList.Count - DiffIndex);
        Result := PathRemoveSeparator(Result);
        for I := DiffIndex to DestList.Count - 1 do
        begin
          if Result <> '' then
            Result := Result + DirDelimiter;
          Result := Result + DestList[i];
        end;
      end;
    finally
      DestList.Free;
      OrigList.Free;
    end;                    
  end;
end;


function PathIsAbsolute(const Path: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  if Path <> '' then
  begin
    if not PathIsUnc(Path) then
    begin
      I := 0;
      if PathIsDiskDevice(Path) then
        I := Length(PathDevicePrefix);
      Result := (Length(Path) > I + 2) and (Path[I + 1] in DriveLetters) and
        (Path[I + 2] = ':') and (Path[I + 3] = DirDelimiter);
    end
    else
      Result := True;
  end;
end;

function PathIsDiskDevice(const Path: string): Boolean;
begin
  Result := Copy(Path, 1, Length(PathDevicePrefix)) = PathDevicePrefix;
end;

function PathIsUNC(const Path: string): Boolean;
const
  cUNCSuffix = '?\UNC';

var
  P: PChar;

  function AbsorbSeparator: Boolean;
  begin
    Result := (P <> nil) and (P^ = DirDelimiter);
    if Result then
      Inc(P);
  end;

  function AbsorbMachineName: Boolean;
  var
    NonDigitFound: Boolean;
  begin
    // a valid machine name is a string composed of the set [a-z, A-Z, 0-9, -, _] but it may not
    // consist entirely out of numbers
    Result := True;
    NonDigitFound := False;
    while (P^ <> #0) and (P^ <> DirDelimiter) do
    begin
      if P^ in ['a'..'z', 'A'..'Z', '-', '_', '.'] then
      begin
        NonDigitFound := True;
        Inc(P);
      end
      else
      if P^ in AnsiDecDigits then
        Inc(P)
      else
      begin
        Result := False;
        Break;
      end;
    end;
    Result := Result and NonDigitFound;
  end;

  function AbsorbShareName: Boolean;
  const
    InvalidCharacters =
      ['<', '>', '?', '/', ',', '*', '+', '=', '[', ']', '|', ':', ';', '"', ''''];
  begin
    // a valid share name is a string composed of a set the set !InvalidCharacters note that a
    // leading '$' is valid (indicates a hidden share)
    Result := True;
    while (P^ <> #0) and (P^ <> DirDelimiter) do
    begin
      if P^ in InvalidCharacters then
      begin
        Result := False;
        Break;
      end;
      Inc(P);
    end;
  end;

begin
  Result := Copy(Path, 1, Length(PathUncPrefix)) = PathUncPrefix;
  if Result then
  begin
    if Copy(Path, 1, Length(PathUncPrefix + cUNCSuffix)) = PathUncPrefix + cUNCSuffix then
      P := @Path[Length(PathUncPrefix + cUNCSuffix)]
    else
    begin
      P := @Path[Length(PathUncPrefix)];
      Result := AbsorbSeparator and AbsorbMachineName;
    end;
    Result := Result and AbsorbSeparator;
    if Result then
    begin
      Result := AbsorbShareName;
      // remaining, if anything, is path and or filename (optional) check those?
    end;
  end;
end;

function PathRemoveSeparator(const Path: string): string;
var
  L: Integer;
begin
  L := Length(Path);
  if (L <> 0) and (AnsiLastChar(Path) = DirDelimiter) then
    Result := Copy(Path, 1, L - 1)
  else
    Result := Path;
end;

function PathRemoveExtension(const Path: string): string;
var
  I: Integer;
begin
  I := LastDelimiter(':.' + DirDelimiter, Path);
  if (I > 0) and (Path[I] = '.') then
    Result := Copy(Path, 1, I - 1)
  else
    Result := Path;
end;

function BuildFileList(const Path: string; const Attr: Integer;
  const List: TStrings): Boolean;
var
  SearchRec: TSearchRec;
  IndexMask: Integer;
  MaskList: TStringList;
  Masks, Directory: string;
begin
  Assert(List <> nil);
  MaskList := TStringList.Create;
  try
    {* extract the Directory *}
    Directory := ExtractFileDir(Path);

    {* files can be searched in the current directory *}
    if Directory <> '' then
    begin
      Directory := PathAddSeparator(Directory);
      {* extract the FileMasks portion out of Path *}
      Masks := StrAfter(Directory, Path);
    end
    else
      Masks := Path;

    {* put the Masks into TStringlist *}
    StrTokenToStrings(Masks, DirSeparator, MaskList);

    {* search all files in the directory *}
    Result := FindFirst(Directory + '*', faAnyFile, SearchRec) = 0;

    List.BeginUpdate;
    try
      while Result do
      begin
        {* if the filename matches any mask then it is added to the list *}
        for IndexMask := 0 to MaskList.Count - 1 do
          if (SearchRec.Name <> '.') and (SearchRec.Name <> '..')
            and ((SearchRec.Attr and Attr) = (SearchRec.Attr and faAnyFile))
            and IsFileNameMatch(SearchRec.Name, MaskList.Strings[IndexMask]) then
        begin
          List.Add(SearchRec.Name);
          Break;
        end;
        
        case FindNext(SearchRec) of
          0 : ;
          ERROR_NO_MORE_FILES :
            Break;
          else
            Result := False;
        end;
      end;
    finally
      SysUtils.FindClose(SearchRec);
      List.EndUpdate;
    end;
  finally
    MaskList.Free;
  end;
end;

function DelTreeEx(const Path: string; AbortOnFailure: Boolean; Progress: TDelTreeProgress): Boolean;
var
  Files: TStringList;
  LPath: string; // writable copy of Path
  FileName: string;
  I: Integer;
  PartialResult: Boolean;
  Attr: DWORD;
begin
  if Path = '' then
  begin
    Result := False;
    Exit;
  end;

  Result := True;
  Files := TStringList.Create;
  try
    LPath := PathRemoveSeparator(Path);
    BuildFileList(LPath + '\*.*', faAnyFile, Files);
    for I := 0 to Files.Count - 1 do
    begin
      FileName := LPath + DirDelimiter + Files[I];
      PartialResult := True;
      // If the current file is itself a directory then recursively delete it
      Attr := GetFileAttributes(PChar(FileName));
      if (Attr <> DWORD(-1)) and ((Attr and FILE_ATTRIBUTE_DIRECTORY) <> 0) then
        PartialResult := DelTreeEx(FileName, AbortOnFailure, Progress)
      else
      begin
        if Assigned(Progress) then
          PartialResult := Progress(FileName, Attr);
        if PartialResult then
        begin
          // Set attributes to normal in case it's a readonly file
          PartialResult := SetFileAttributes(PChar(FileName), FILE_ATTRIBUTE_NORMAL);
          if PartialResult then
            PartialResult := DeleteFile(FileName);
        end;
      end;
      if not PartialResult then
      begin
        Result := False;
        if AbortOnFailure then
          Break;
      end;
    end;
  finally
    FreeAndNil(Files);
  end;
  if Result then
  begin
    // Finally remove the directory itself
    Result := SetFileAttributes(PChar(LPath), FILE_ATTRIBUTE_NORMAL);
    if Result then
    begin
      {$IOCHECKS OFF}
      RmDir(LPath);
      {$IFDEF IOCHECKS_ON}
      {$IOCHECKS ON}
      {$ENDIF IOCHECKS_ON}
      Result := IOResult = 0;
    end;
  end;
end;

function FileDelete(const FileName: string; MoveToTrash : Boolean): Boolean;
begin
 Result := Windows.DeleteFile(PChar(FileName));
end;

function AdvBuildFileList(const Path: string; const Attr: Integer; const Files: TStrings;
  const AttributeMatch: TJclAttributeMatch; const Options: TFileListOptions;
  const SubfoldersMask: string; const FileMatchFunc: TFileMatchFunc): Boolean;
var
  FileMask: string;
  RootDir: string;
  Folders: TStringList;
  CurrentItem: Integer;
  Counter: Integer;
  FindAttr: Integer;

  procedure BuildFolderList;
  var
    FindInfo: TSearchRec;
    Rslt: Integer;
  begin
    Counter := Folders.Count - 1;
    CurrentItem := 0;

    while CurrentItem <= Counter do
    begin
      // searching for subfolders
      Rslt := FindFirst(Folders[CurrentItem] + '*.*', faDirectory, FindInfo);
      try
        while Rslt = 0 do
        begin
          if (FindInfo.Name <> '.') and (FindInfo.Name <> '..') and
            (FindInfo.Attr and faDirectory = faDirectory) then
            Folders.Add(Folders[CurrentItem] + FindInfo.Name + DirDelimiter);

          Rslt := FindNext(FindInfo);
        end;
      finally
        FindClose(FindInfo);
      end;
      Counter := Folders.Count - 1;
      Inc(CurrentItem);
    end;
  end;

  procedure FillFileList(CurrentCounter: Integer);
  var
    FindInfo: TSearchRec;
    Rslt: Integer;
    CurrentFolder: string;
    Matches: Boolean;
  begin
    CurrentFolder := Folders[CurrentCounter];

    Rslt := FindFirst(CurrentFolder + FileMask, FindAttr, FindInfo);

    try
      while Rslt = 0 do
      begin
         Matches := False;

         case AttributeMatch of
           amAny:
             Matches := True;
           amExact:
             Matches := Attr = FindInfo.Attr;
           amSubSetOf:
             Matches := (Attr and FindInfo.Attr) = Attr;
           amSuperSetOf:
             Matches := (Attr and FindInfo.Attr) = FindInfo.Attr;
           amCustom:
             if Assigned(FileMatchFunc) then
               Matches := FileMatchFunc(Attr,  FindInfo);
         end;

         if Matches then
           if flFullNames in Options then
             Files.Add(CurrentFolder + FindInfo.Name)
           else
             Files.Add(FindInfo.Name);

        Rslt := FindNext(FindInfo);
      end;
    finally
      FindClose(FindInfo);
    end;
  end;

begin
  Assert(Assigned(Files));
  FileMask := ExtractFileName(Path);
  RootDir := ExtractFilePath(Path);

  Folders := TStringList.Create;
  Files.BeginUpdate;
  try
    Folders.Add(RootDir);

    case AttributeMatch of
      amExact, amSuperSetOf:
        FindAttr := Attr;
    else
      FindAttr := faAnyFile;
    end;

    // here's the recursive search for nested folders

    if flRecursive in Options then
      BuildFolderList;

    for Counter := 0 to Folders.Count - 1 do
    begin
      if (((flMaskedSubfolders in Options) and (StrMatches(SubfoldersMask,
        Folders[Counter], 1))) or (not (flMaskedSubfolders in Options))) then
          FillFileList(Counter);
    end;
  finally
    Folders.Free;
    Files.EndUpdate;
  end;
  Result := True;
end;

function IsFileNameMatch(FileName: string; const Mask: string;
  const CaseSensitive: Boolean): Boolean;
begin
  Result := True;
  if (Mask = '') or (Mask = '*') or (Mask = '*.*') then
    Exit;
  if Pos('.', FileName) = 0 then
    FileName := FileName + '.';  // file names w/o extension match '*.'

  if CaseSensitive then
    Result := StrMatches(Mask, FileName)
  else

    Result := StrMatches(AnsiUpperCase(Mask), AnsiUpperCase(FileName));
end;

{ JclSysUtils }
function IsObject(Address: Pointer): Boolean; assembler;
asm
        MOV     EAX, [Address]
        CMP     EAX, EAX.vmtSelfPtr
        JNZ     @False
        MOV     Result, True
        JMP     @Exit
@False:
        MOV     Result, False
@Exit:
end;

function IntToStrZeroPad(Value, Count: Integer): AnsiString;
begin
  Result := IntToStr(Value);
  if Length(Result) < Count then
    Result := StrFillChar('0', Count - Length(Result)) + Result;
end;


{ JvStrToHTML }

type
  TJvHtmlCodeRec = packed record
    Ch: Char;
    Html: PChar;
  end;

const
  { References:
      http://www.w3.org/TR/REC-html40/charset.html#h-5.3
      http://www.w3.org/TR/REC-html40/sgml/entities.html#h-24.2.1
      http://www.w3.org/TR/REC-html40/sgml/entities.html#h-24.4.1
  }
  Conversions: array [1..72] of TJvHtmlCodeRec = (
    (Ch: '"'; Html: '&quot;'),
    (Ch: '<'; Html: '&lt;'),
    (Ch: '>'; Html: '&gt;'),
    (Ch: '^'; Html: '&circ;'),
    (Ch: '~'; Html: '&tilde;'),
    (Ch: '£'; Html: '&pound;'),
    (Ch: '§'; Html: '&sect;'),
    (Ch: '°'; Html: '&deg;'),
    (Ch: '²'; Html: '&sup2;'),
    (Ch: '³'; Html: '&sup3;'),
    (Ch: 'µ'; Html: '&micro;'),
    (Ch: '·'; Html: '&middot;'),
    (Ch: '¼'; Html: '&frac14;'),
    (Ch: '½'; Html: '&frac12;'),
    (Ch: '¿'; Html: '&iquest;'),
    (Ch: 'À'; Html: '&Agrave;'),
    (Ch: 'Á'; Html: '&Aacute;'),
    (Ch: 'Â'; Html: '&Acirc;'),
    (Ch: 'Ã'; Html: '&Atilde;'),
    (Ch: 'Ä'; Html: '&Auml;'),
    (Ch: 'Å'; Html: '&Aring;'),
    (Ch: 'Æ'; Html: '&AElig;'),
    (Ch: 'Ç'; Html: '&Ccedil;'),
    (Ch: 'È'; Html: '&Egrave;'),
    (Ch: 'É'; Html: '&Eacute;'),
    (Ch: 'Ê'; Html: '&Ecirc;'),
    (Ch: 'Ë'; Html: '&Euml;'),
    (Ch: 'Ì'; Html: '&Igrave;'),
    (Ch: 'Í'; Html: '&Iacute;'),
    (Ch: 'Î'; Html: '&Icirc;'),
    (Ch: 'Ï'; Html: '&Iuml;'),
    (Ch: 'Ñ'; Html: '&Ntilde;'),
    (Ch: 'Ò'; Html: '&Ograve;'),
    (Ch: 'Ó'; Html: '&Oacute;'),
    (Ch: 'Ô'; Html: '&Ocirc;'),
    (Ch: 'Õ'; Html: '&Otilde;'),
    (Ch: 'Ö'; Html: '&Ouml;'),
    (Ch: 'Ù'; Html: '&Ugrave;'),
    (Ch: 'Ú'; Html: '&Uacute;'),
    (Ch: 'Û'; Html: '&Ucirc;'),
    (Ch: 'Ü'; Html: '&Uuml;'),
    (Ch: 'Ý'; Html: '&Yacute;'),
    (Ch: 'ß'; Html: '&szlig;'),
    (Ch: 'á'; Html: '&aacute;'),
    (Ch: 'à'; Html: '&agrave;'),
    (Ch: 'â'; Html: '&acirc;'),
    (Ch: 'ã'; Html: '&atilde;'),
    (Ch: 'ä'; Html: '&auml;'),
    (Ch: 'å'; Html: '&aring;'),
    (Ch: 'æ'; Html: '&aelig;'),
    (Ch: 'ç'; Html: '&ccedil;'),
    (Ch: 'é'; Html: '&eacute;'),
    (Ch: 'è'; Html: '&egrave;'),
    (Ch: 'ê'; Html: '&ecirc;'),
    (Ch: 'ë'; Html: '&euml;'),
    (Ch: 'ì'; Html: '&igrave;'),
    (Ch: 'í'; Html: '&iacute;'),
    (Ch: 'î'; Html: '&icirc;'),
    (Ch: 'ï'; Html: '&iuml;'),
    (Ch: 'ñ'; Html: '&ntilde;'),
    (Ch: 'ò'; Html: '&ograve;'),
    (Ch: 'ó'; Html: '&oacute;'),
    (Ch: 'ô'; Html: '&ocirc;'),
    (Ch: 'õ'; Html: '&otilde;'),
    (Ch: 'ö'; Html: '&ouml;'),
    (Ch: '÷'; Html: '&divide;'),
    (Ch: 'ù'; Html: '&ugrave;'),
    (Ch: 'ú'; Html: '&uacute;'),
    (Ch: 'û'; Html: '&ucirc;'),
    (Ch: 'ü'; Html: '&uuml;'),
    (Ch: 'ý'; Html: '&yacute;'),
    (Ch: 'ÿ'; Html: '&yuml;')
    );

function StringToHtml(const Value: string): string;
var
  I, J: Integer;
  Len, AddLen, HtmlLen: Integer;
  P: PChar;
  Ch: Char;
begin
  Len := Length(Value);
  // number of chars to add
  AddLen := 0;
  for I := 1 to Len do
    for J := Low(Conversions) to High(Conversions) do
      if Value[I] = Conversions[J].Ch then
      begin
        Inc(AddLen, StrLen(Conversions[J].Html) - 1);
        Break;
      end;

  if AddLen = 0 then
    Result := Value
  else
  begin
    SetLength(Result, Len + AddLen);
    P := Pointer(Result);
    for I := 1 to Len do
    begin
      Ch := Value[I];
      for J := Low(Conversions) to High(Conversions) do
        if Ch = Conversions[J].Ch then
        begin
          HtmlLen := StrLen(Conversions[J].Html);
          Move(Conversions[J].Html[0], P[0], HtmlLen); // Conversions[].Html is a PChar
          Inc(P, HtmlLen);
          Ch := #0;
          Break;
        end;
      if Ch <> #0 then
      begin
        P[0] := Ch;
        Inc(P);
      end;
    end;
  end;
end;

function HtmlToString(const Value: string): string;
var
  I, Index, Len: Integer;
  Start, J: Integer;
  Ch: Char;
  ReplStr: string;
begin
  Len := Length(Value);
  SetLength(Result, Len); // worst case
  Index := 0;
  I := 1;
  while I <= Len do
  begin
    Ch := Value[I];
   // html entitiy
    if Ch = '&' then
    begin
      Start := I;
      Inc(I);
      while (I <= Len) and (Value[I] <> ';') and (I < Start + 20) do
        Inc(I);
      if Value[I] <> ';' then
        I := Start
      else
      begin
        Ch := #0;
        ReplStr := LowerCase(Copy(Value, Start, I - Start + 1));
        for J := Low(Conversions) to High(Conversions) do
          if Conversions[J].Html = ReplStr then
          begin
            Ch := Conversions[J].Ch;
            Break;
          end;

        // if no conversion was found, it may actually be a number
        if Ch = #0 then
        begin
          if StrToIntDef(ReplStr, -1) <> -1 then
          begin
            Ch := Chr(StrToInt(ReplStr));
          end
          else
          begin
            I := Start;
            Ch := Value[I];
          end;
        end;
      end;
    end;

    Inc(I);
    Inc(Index);
    Result[Index] := Ch;
  end;
  if Index <> Len then
    SetLength(Result, Index);
end;

function CharToHtml(Ch: Char): string;
var
  I: Integer;
begin
  for I := Low(Conversions) to High(Conversions) do
    if Conversions[I].Ch = Ch then
    begin
      Result := Conversions[I].Html;
      Exit;
    end;
  Result := Ch;
end;

initialization
  LoadCharTypes;  // this table first
  LoadCaseMap;    // or this function does not work

end.
