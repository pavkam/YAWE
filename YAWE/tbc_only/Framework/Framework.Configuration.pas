

{$I compiler.inc}
unit Framework.Configuration;

interface

uses
  DateUtils,
  Windows;

type
  IConfiguration = interface(IInterface)
  ['{486DA3CA-AA59-4E9F-9DE7-6155B64A90FD}']
    function SectionExists(Section: PWideChar): Boolean; stdcall;
    function EraseSection(Section: PWideChar): Boolean; stdcall;

    function GetSections(ParentSection: PWideChar; Buffer: PWideChar; Size: Integer): Integer; stdcall;
    function GetSectionValues(Section: PWideChar; Buffer: PWideChar; Size: Integer): Integer; stdcall;

    function ReadString(Section, Key, Default, Buffer: PWideChar; Size: Integer): Integer; stdcall;
    function ReadInteger(Section, Key: PWideChar; Default: Int64 = 0): Int64; stdcall;
    function ReadBool(Section, Key: PWideChar; Default: Boolean = False): Boolean; stdcall;
    function ReadFloat(Section, Key: PWideChar; Default: Double = 0): Double; stdcall;
    function ReadBinary(Section, Key: PWideChar; Buffer: Pointer; Size: Integer): Integer; stdcall;

    procedure WriteString(Section, Key, Value: PWideChar); stdcall;
    procedure WriteInteger(Section, Key: PWideChar; Value: Int64); stdcall;
    procedure WriteBool(Section, Key: PWideChar; Value: Boolean); stdcall;
    procedure WriteFloat(Section, Key: PWideChar; Value: Double); stdcall;
    procedure WriteBinary(Section, Key: PWideChar; Buffer: Pointer; Size: Integer); stdcall;

    procedure Load; stdcall;
    procedure Save; stdcall;
  end;

  { N suffix means "native" in this case native to Delphi }
  IConfiguration2 = interface(IConfiguration)
  ['{486DA3CA-AA59-4E9F-FF0A-6155B64A90FD}']
    function SectionExistsN(const Section: WideString): Boolean; 
    function EraseSectionN(const Section: WideString): Boolean;

    function GetSectionsN(const ParentSection: WideString = ''): WideString;
    function GetSectionValuesN(const Section: WideString): WideString;

    function ReadStringN(const Section, Key: WideString; const Default: WideString = ''): WideString;
    function ReadIntegerN(const Section, Key: WideString; const Default: Int64 = 0): Int64;
    function ReadBoolN(const Section, Key: WideString; const Default: Boolean = False): Boolean;
    function ReadFloatN(const Section, Key: WideString; const Default: Double = 0): Double;

    procedure WriteStringN(const Section, Key, Value: WideString);
    procedure WriteIntegerN(const Section, Key: WideString; const Value: Int64);
    procedure WriteBoolN(const Section, Key: WideString; const Value: Boolean);
    procedure WriteFloatN(const Section, Key: WideString; const Value: Double);
  end;

function CreateConfigurationIni(FileName: WideString; out Configuration: IConfiguration): Boolean;
function CreateConfigurationReg(Root: HKEY; const Path: WideString; out Configuration: IConfiguration): Boolean;
function CreateConfigurationXml(FileName: WideString; out Configuration: IConfiguration): Boolean;

implementation

uses
  Classes,
  SysUtils,
  IniFiles,
  Registry,
  WideStrings,
  WideStrUtils,
  XmlDoc,
  XmlIntf,
  Bfg.Utils,
  Bfg.Classes,
  Bfg.Unicode;

type
  TTextConfigFileBase = class(TInterfacedObject)
    protected
      function ReadStr(Section, Key, Default: PWideChar): WideString; inline;
    public
      function SectionExists(Section: PWideChar): Boolean; stdcall;
      function EraseSection(Section: PWideChar): Boolean; stdcall;

      function GetSections(ParentSection: PWideChar; Buffer: PWideChar; Size: Integer): Integer; stdcall;
      function GetSectionValues(Section: PWideChar; Buffer: PWideChar; Size: Integer): Integer; stdcall;

      function SectionExistsN(const Section: WideString): Boolean; virtual; abstract;
      function EraseSectionN(const Section: WideString): Boolean; virtual; abstract;

      function GetSectionsN(const ParentSection: WideString): WideString; virtual; abstract;
      function GetSectionValuesN(const Section: WideString): WideString; virtual; abstract;

      function ReadString(Section, Key, Default, Buffer: PWideChar; Size: Integer): Integer; virtual; stdcall; 
      function ReadInteger(Section, Key: PWideChar; Default: Int64): Int64; virtual; stdcall;
      function ReadBool(Section, Key: PWideChar; Default: Boolean): Boolean; virtual; stdcall;
      function ReadFloat(Section, Key: PWideChar; Default: Double): Double; virtual; stdcall;
      function ReadBinary(Section, Key: PWideChar; Buffer: Pointer; Size: Integer): Integer; virtual; stdcall;

      procedure WriteString(Section, Key, Value: PWideChar); virtual; stdcall; 
      procedure WriteInteger(Section, Key: PWideChar; Value: Int64); virtual; stdcall;
      procedure WriteBool(Section, Key: PWideChar; Value: Boolean); virtual; stdcall;
      procedure WriteFloat(Section, Key: PWideChar; Value: Double); virtual; stdcall;
      procedure WriteBinary(Section, Key: PWideChar; Buffer: Pointer; Size: Integer); virtual; stdcall;

      function ReadStringN(const Section, Key, Default: WideString): WideString; virtual; abstract;
      function ReadIntegerN(const Section, Key: WideString; const Default: Int64): Int64; virtual;
      function ReadBoolN(const Section, Key: WideString; const Default: Boolean): Boolean; virtual;
      function ReadFloatN(const Section, Key: WideString; const Default: Double): Double; virtual;

      procedure WriteStringN(const Section, Key, Value: WideString); virtual; abstract;
      procedure WriteIntegerN(const Section, Key: WideString; const Value: Int64); virtual;
      procedure WriteBoolN(const Section, Key: WideString; const Value: Boolean); virtual;
      procedure WriteFloatN(const Section, Key: WideString; const Value: Double); virtual;
  end;

  TIniConfigFile = class(TTextConfigFileBase, IConfiguration, IConfiguration2)
    private
      FFileName: WideString;
      FSections: TWideStringList;
      FLeading: TWideStringList;
      FChanged: Boolean;

      function FindSectionData(const Section: WideString; Index: PInteger = nil): TWideStringList;
      function GetSectionData(const Section: WideString): TWideStringList;
    public
      constructor Create(const IniFile: WideString);
      destructor Destroy; override;

      function SectionExistsN(const Section: WideString): Boolean; override;
      function EraseSectionN(const Section: WideString): Boolean; override;

      function GetSectionsN(const ParentSection: WideString): WideString; override;
      function GetSectionValuesN(const Section: WideString): WideString; override;

      function ReadStringN(const Section, Key, Default: WideString): WideString; override;
      procedure WriteStringN(const Section, Key, Value: WideString); override;

      procedure Load; stdcall;
      procedure Save; stdcall;
  end;

  TXmlConfigFile = class(TTextConfigFileBase, IConfiguration, IConfiguration2)
    private
      FFileName: WideString;
      FXMLDoc: IXMLDocument;
      FModified: Boolean;

      procedure BrowseToNode(const NodePath: WideString; RootNode: IXMLNode;
        out Node: IXMLNode; CreateNonExistant: Boolean);
    public
      constructor Create(const XmlFile: WideString);

      function SectionExistsN(const Section: WideString): Boolean; override;
      function EraseSectionN(const Section: WideString): Boolean; override;

      function GetSectionsN(const ParentSection: WideString): WideString; override;
      function GetSectionValuesN(const Section: WideString): WideString; override;

      function ReadStringN(const Section, Key, Default: WideString): WideString; override;
      procedure WriteStringN(const Section, Key, Value: WideString); override;

      procedure Load; stdcall;
      procedure Save; stdcall;
  end;

  TRegConfigFile = class(TInterfacedObject, IConfiguration)
    private
      FCurrentKey: HKEY;
      FRootKey: HKEY;
      FCurrentPath: WideString;
      FCloseRootKey: Boolean;
      FAccess: Longword;
      FLazyWrite: Boolean;

      procedure SetRootKey(Value: HKEY);
      procedure ChangeKey(Value: HKey; const Path: WideString);
      function GetBaseKey(Relative: Boolean): HKey;
      function GetData(const Name: WideString; Buffer: Pointer;
        BufSize: Integer; var RegData: TRegDataType): Integer;
      function GetKey(const Key: WideString): HKEY;
      procedure PutData(const Name: WideString; Buffer: Pointer; BufSize: Integer; RegData: TRegDataType);
      procedure SetCurrentKey(Value: HKEY);

      function ReadStr(Section, Key, Default: PWideChar): WideString; inline;
    public
      constructor Create(Root: HKEY; const Path: WideString);
      destructor Destroy; override;

      function SectionExists(Section: PWideChar): Boolean; stdcall;
      function EraseSection(Section: PWideChar): Boolean; stdcall;

      function GetSections(ParentSection, Buffer: PWideChar; Size: Integer): Integer; stdcall;
      function GetSectionValues(Section: PWideChar; Buffer: PWideChar; Size: Integer): Integer; stdcall;

      function ReadString(Section, Key, Default, Buffer: PWideChar; Size: Integer): Integer; stdcall;
      function ReadInteger(Section, Key: PWideChar; Default: Int64): Int64; stdcall;
      function ReadBool(Section, Key: PWideChar; Default: Boolean): Boolean; stdcall;
      function ReadFloat(Section, Key: PWideChar; Default: Double): Double; stdcall;
      function ReadBinary(Section, Key: PWideChar; Buffer: Pointer; Size: Integer): Integer; stdcall;

      procedure WriteString(Section, Key, Value: PWideChar); stdcall;
      procedure WriteInteger(Section, Key: PWideChar; Value: Int64); stdcall;
      procedure WriteBool(Section, Key: PWideChar; Value: Boolean); stdcall;
      procedure WriteFloat(Section, Key: PWideChar; Value: Double); stdcall;
      procedure WriteBinary(Section, Key: PWideChar; Buffer: Pointer; Size: Integer); stdcall;

      procedure Load; stdcall;
      procedure Save; stdcall;
  end;

function CreateConfigurationIni(FileName: WideString; out Configuration: IConfiguration): Boolean;
begin
  if FileName = '' then
  begin
    Configuration := nil;
    Result := False;
    Exit;
  end;
  
  if FileName <> '' then
  begin
    FileName := WideExpandFileName(FileName);
  end;

  Configuration := TIniConfigFile.Create(FileName);
  Result := True;
end;

function CreateConfigurationReg(Root: HKEY; const Path: WideString; out Configuration: IConfiguration): Boolean;
begin
  if (Root <> HKEY_CLASSES_ROOT) and (Root <> HKEY_CURRENT_USER) and
     (Root <> HKEY_LOCAL_MACHINE) and (Root <> HKEY_USERS) and
     (Root <> HKEY_CURRENT_CONFIG) then
  begin
    Configuration := nil;
    Result := False;
    Exit;
  end;

  Configuration := TRegConfigFile.Create(Root, Path);
  Result := True;
end;

function CreateConfigurationXml(FileName: WideString; out Configuration: IConfiguration): Boolean;
begin
  if FileName = '' then
  begin
    Configuration := nil;
    Result := False;
    Exit;
  end;

  if FileName <> '' then
  begin
    FileName := WideExpandFileName(FileName);
  end;

  Configuration := TXmlConfigFile.Create(FileName);
  Result := True;
end;

{ TTextConfigFileBase }

function TTextConfigFileBase.EraseSection(Section: PWideChar): Boolean;
begin
  Result := EraseSectionN(Section);
end;

function TTextConfigFileBase.GetSections(ParentSection, Buffer: PWideChar;
  Size: Integer): Integer;
var
  W: WideString;
begin
  W := GetSectionsN(ParentSection);
  Result := Length(W);
  if Result <> 0 then Inc(Result);

  if Assigned(Buffer) and (Size >= Result) then
  begin
    Move(PWideChar(W)^, Buffer^, Size * SizeOf(WideChar));
    PWideChar(Buffer+Size)^ := #0;
  end;
end;

function TTextConfigFileBase.GetSectionValues(Section, Buffer: PWideChar;
  Size: Integer): Integer;
var
  W: WideString;
begin
  W := GetSectionValuesN(Section);
  Result := Length(W);
  if Result <> 0 then Inc(Result);

  if Assigned(Buffer) and (Size >= Result) then
  begin
    Move(PWideChar(W)^, Buffer^, Size * SizeOf(WideChar));
    PWideChar(Buffer+Size)^ := #0;
  end;
end;

function TTextConfigFileBase.ReadBinary(Section, Key: PWideChar;
  Buffer: Pointer; Size: Integer): Integer;
var
  S: AnsiString;
begin
  S := ReadStr(Section, Key, nil);
  Result := Length(S) shr 1;
  if (Length(S) and 1) <> 0 then Inc(Result);
  if (Result <> 0) and Assigned(Buffer) and (Size >= Result) then
  begin
    Result := HexToBin(PChar(S), Buffer, Size);
  end;
end;

function TTextConfigFileBase.ReadBool(Section, Key: PWideChar;
  Default: Boolean): Boolean;
begin
  Result := WideStrToBoolDef(ReadStr(Section, Key, nil), Default);
end;

function TTextConfigFileBase.ReadBoolN(const Section, Key: WideString;
  const Default: Boolean): Boolean;
begin
  Result := WideStrToBoolDef(ReadStringN(Section, Key, ''), Default);
end;

function TTextConfigFileBase.ReadFloat(Section, Key: PWideChar;
  Default: Double): Double;
begin
  Result := WideStrToFloatDef(ReadStr(Section, Key, nil), Default);
end;

function TTextConfigFileBase.ReadFloatN(const Section, Key: WideString;
  const Default: Double): Double;
begin
  Result := WideStrToFloatDef(ReadStringN(Section, Key, ''), Default);
end;

function TTextConfigFileBase.ReadInteger(Section, Key: PWideChar;
  Default: Int64): Int64;
begin
  Result := WideStrToInt64Def(ReadStr(Section, Key, nil), Default);
end;

function TTextConfigFileBase.ReadIntegerN(const Section, Key: WideString;
  const Default: Int64): Int64;
begin
  Result := WideStrToInt64Def(ReadStringN(Section, Key, ''), Default);
end;

function TTextConfigFileBase.ReadStr(Section, Key,
  Default: PWideChar): WideString;
begin
  SetLength(Result, ReadString(Section, Key, nil, nil, 0) - 1);
  ReadString(Section, Key, nil, PWideChar(Result), Length(Result) + 1);
end;

function TTextConfigFileBase.ReadString(Section, Key, Default,
  Buffer: PWideChar; Size: Integer): Integer;
var
  W: WideString;
begin
  W := ReadStringN(Section, Key, Default);
  Result := Length(W);
  if Result <> 0 then Inc(Result); // Include null-terminator

  if (Result > 0) and Assigned(Buffer) and (Size >= Result) then
  begin
    // Just copy the local to the user-supplied buffer
    Move(PWideChar(W)^, Buffer^, Result * SizeOf(WideChar));
    PWideChar(Buffer+Size)^ := #0;
  end;
end;

function TTextConfigFileBase.SectionExists(Section: PWideChar): Boolean;
begin
  Result := SectionExistsN(Section);
end;

procedure TTextConfigFileBase.WriteBinary(Section, Key: PWideChar;
  Buffer: Pointer; Size: Integer);
var
  S: AnsiString;
begin
  SetLength(S, Size * 2);
  BinToHex(Buffer, PChar(S), Size);
  WriteString(Section, Key, PWideChar(UTF8ToWideString(S)));
end;

procedure TTextConfigFileBase.WriteBool(Section, Key: PWideChar;
  Value: Boolean);
begin
  WriteString(Section, Key, PWideChar(WideString(WideBoolToStr(Value, True))));
end;

procedure TTextConfigFileBase.WriteBoolN(const Section, Key: WideString;
  const Value: Boolean);
begin
  WriteStringN(Section, Key, WideBoolToStr(Value, True));
end;

procedure TTextConfigFileBase.WriteFloat(Section, Key: PWideChar;
  Value: Double);
begin
  WriteString(Section, Key, PWideChar(WideString(WideFloatToStr(Value))));
end;

procedure TTextConfigFileBase.WriteFloatN(const Section, Key: WideString;
  const Value: Double);
begin
  WriteStringN(Section, Key, WideFloatToStr(Value));
end;

procedure TTextConfigFileBase.WriteInteger(Section, Key: PWideChar;
  Value: Int64);
begin
  WriteString(Section, Key, PWideChar(WideString(WideIntToStr(Value))));
end;

procedure TTextConfigFileBase.WriteIntegerN(const Section, Key: WideString;
  const Value: Int64);
begin
  WriteStringN(Section, Key, WideIntToStr(Value));
end;

procedure TTextConfigFileBase.WriteString(Section, Key, Value: PWideChar);
begin
  WriteStringN(Section, Key, Value);
end;

{ TIniConfigFile }

constructor TIniConfigFile.Create(const IniFile: WideString);
begin
  FSections := THashedWideStringList.Create;
  FLeading := TWideStringList.Create;
  FFileName := IniFile;
  FSections.Duplicates := dupIgnore;
end;

destructor TIniConfigFile.Destroy;
var
  I: Integer;
begin
  for I := 0 to FSections.Count - 1 do
  begin
    FSections.Objects[I].Free;
  end;
  FSections.Free;
  FLeading.Free;
  inherited Destroy;
end;

procedure TIniConfigFile.Load;
var
  S: string;
  FileContents: WideString;
  Line: WideString;
  TextTmp: PWideChar;
  TextTmp2: PWideChar;
  TextPtr: PWideChar;
  TextEnd: PWideChar;
  FS: TWideFileStream;
  SectValues: TWideStringList;
  Len: Integer;
  LineLen: Integer;
  I: Integer;
  Value: WideString;
begin
  if WideFileExists(FFileName) then
  begin
    // We lopen the file and read the contents which we expect to be UTF8 encoded
    SectValues := nil;
    
    FS := TWideFileStream.Create(FFileName, fmOpenRead or fmShareDenyWrite);
    try
      SetLength(S, FS.Size);
      FS.Read(Pointer(S)^, FS.Size);
    finally
      FS.Free;
    end;

    // Convert UTF8 encoded file into Wide format
    FileContents := UTF8ToWideString(S);
    S := '';

    TextPtr := PWideChar(FileContents);
    TextEnd := TextPtr + Length(FileContents);

    // Parsing looks complex, yet it is quite simple
    while TextPtr < TextEnd do
    begin
      while (TextPtr^ = #13) or (TextPtr^ = #10) do Inc(TextPtr);
      TextTmp := TextPtr;
      while (TextPtr^ <> #13) and (TextPtr^ <> #10) and (TextPtr^ <> #0) do Inc(TextPtr);

      LineLen := TextPtr - TextTmp;
      if (TextTmp - TextPtr = 1) or (TextTmp^ <> ';') or (PWideChar(TextTmp+1)^ <> ';') then
      begin
        TextTmp2 := TextTmp;
        while TextTmp2 < TextPtr do
        begin
          if TextTmp2^ = ';' then
          begin
            if TextTmp2 + 1 < TextPtr then
            begin
              Inc(TextTmp2);
              if TextTmp2^ = ';' then
              begin
                LineLen := (TextTmp2 - TextTmp) - 1;
                Break;
              end;
            end;
          end;
          Inc(TextTmp2);
        end;

        SetString(Line, TextTmp, LineLen);

        Line := WideTrim(Line);
        Len := Length(Line);

        if Len > 0 then
        begin
          if (Line[1] = '[') and (Line[Len] = ']') then
          begin
            Line := Copy(Line, 2, Len - 2);
            SectValues := GetSectionData(Line);
            Continue;
          end;
          if SectValues <> nil then
          begin
            I := WideCharPos(Line, '=', 1);
            if I < 0 then Continue;

            Value := WideTrimLeft(Copy(Line, I + 1, Len));
            Delete(Line, I, Len);

            SectValues.Add(WideTrimRight(Line) + '=' + Value);
          end;
        end;
      end;

      if SectValues = nil then FLeading.Add(Line);
    end;
  end;
end;

function TIniConfigFile.EraseSectionN(const Section: WideString): Boolean;
var
  SectValues: TWideStringList;
  I: Integer;
begin
  Result := False;
  if Section = '' then Exit;

  // Simple, we lookup the section and delete it by its index if found
  SectValues := FindSectionData(Section, @I);
  if SectValues <> nil then
  begin
    FSections.Delete(I);
    SectValues.Free;
    FChanged := True;
    Result := True;
  end
end;

function TIniConfigFile.FindSectionData(const Section: WideString; Index: PInteger): TWideStringList;
var
  I: Integer;
begin
  I := FSections.IndexOf(Section);
  if I >= 0 then
  begin
    Result := TWideStringList(FSections.Objects[I]);
  end else Result := nil;

  if Index <> nil then Index^ := I;
end;

function TIniConfigFile.GetSectionData(const Section: WideString): TWideStringList;
begin
  Result := FindSectionData(Section);
  if Result = nil then
  begin 
    Result := THashedWideStringList.Create;
    try
      Result.Duplicates := dupIgnore;
      FSections.AddObject(Section, Result);
    except
      Result.Free;
      raise;
    end;
  end;
end;

function TIniConfigFile.GetSectionsN(const ParentSection: WideString): WideString;
begin
  if ParentSection <> '' then raise Exception.Create('Unimplemented');
  Result := FSections.Text;
end;

function TIniConfigFile.GetSectionValuesN(const Section: WideString): WideString;
var
  Values: TWideStringList;
begin
  Values := FindSectionData(Section);
  if Assigned(Values) then
  begin
    Result := Values.Text;
  end else Result := '';
end;

function TIniConfigFile.ReadStringN(const Section, Key,
  Default: WideString): WideString;
var
  SectValues: TWideStringList;
begin
  // Check for bogus arguments
  Result := '';
  if (Section = '') or (Key = '') then Exit;

  // Find the section and afterwards the value, assign it to a local
  SectValues := FindSectionData(Section);
  if SectValues <> nil then
  begin
    if SectValues.Values[Key] <> '' then
    begin
      Result := SectValues.Values[Key];
    end else Result := Default;
  end else Result := Default;
end;

procedure TIniConfigFile.Save;
var
  FS: TWideFileStream;
  I: Integer;
  SectValues: TWideStringList;
  UTF8Text: string;
begin
  if FFileName <> '' then
  begin
    // Open or create config file
    FS := TWideFileStream.Create(FFileName, fmCreate or fmShareDenyWrite);
    try
      // Write leading text if any
      if FLeading.Count <> 0 then
      begin
        UTF8Text := WideStringToUTF8(FLeading.Text) + #13#10;
        FS.Write(Pointer(UTF8Text)^, Length(UTF8Text));
      end;

      // Continue with sections and their values
      for I := 0 to FSections.Count -1 do
      begin
        // All data is converted to UTF8 before written
        UTF8Text := WideStringToUTF8('[' + FSections[I] + ']') + #13#10;
        FS.Write(Pointer(UTF8Text)^, Length(UTF8Text));
        SectValues := TWideStringList(FSections.Objects[i]);
        UTF8Text := WideStringToUTF8(SectValues.Text) + #13#10;
        FS.Write(Pointer(UTF8Text)^, Length(UTF8Text));
      end;
    finally
      FS.Free;
    end;
  end;

  FChanged := False;
end;

function TIniConfigFile.SectionExistsN(const Section: WideString): Boolean;
begin
  if Section <> '' then Result := FindSectionData(Section) <> nil else Result := False;
end;

procedure TIniConfigFile.WriteStringN(const Section, Key, Value: WideString);
var
  SectValues: TWideStringList;
begin
  if (Section = '') or (Key = '') then Exit;

  // We just lookup a section and add a key=value pair to it
  SectValues := GetSectionData(Section);
  if Value <> '' then
  begin
    SectValues.Values[Key] := Value;
    FChanged := True;
  end else
  begin
    SectValues.Delete(SectValues.IndexOfName(Key));
  end;
end;

{ TRegConfigFile }

procedure TRegConfigFile.ChangeKey(Value: HKey; const Path: WideString);
begin

end;

constructor TRegConfigFile.Create(Root: HKEY; const Path: WideString);
begin

end;

destructor TRegConfigFile.Destroy;
begin

  inherited;
end;

function TRegConfigFile.EraseSection(Section: PWideChar): Boolean;
begin

end;

function TRegConfigFile.GetBaseKey(Relative: Boolean): HKey;
begin

end;

function TRegConfigFile.GetData(const Name: WideString; Buffer: Pointer;
  BufSize: Integer; var RegData: TRegDataType): Integer;
begin

end;

function TRegConfigFile.GetKey(const Key: WideString): HKEY;
begin

end;

function TRegConfigFile.GetSections(ParentSection, Buffer: PWideChar; Size: Integer): Integer;
begin

end;

function TRegConfigFile.GetSectionValues(Section, Buffer: PWideChar;
  Size: Integer): Integer;
begin

end;

procedure TRegConfigFile.Load;
begin

end;

procedure TRegConfigFile.PutData(const Name: WideString; Buffer: Pointer;
  BufSize: Integer; RegData: TRegDataType);
begin

end;

function TRegConfigFile.ReadBinary(Section, Key: PWideChar; Buffer: Pointer;
  Size: Integer): Integer;
begin
  Result := 0;
end;

function TRegConfigFile.ReadBool(Section, Key: PWideChar;
  Default: Boolean): Boolean;
begin
  Result := False;
end;

function TRegConfigFile.ReadFloat(Section, Key: PWideChar;
  Default: Double): Double;
begin
  Result := 0;
end;

function TRegConfigFile.ReadInteger(Section, Key: PWideChar;
  Default: Int64): Int64;
begin
  Result := 0;
end;

function TRegConfigFile.ReadStr(Section, Key, Default: PWideChar): WideString;
begin

end;

function TRegConfigFile.ReadString(Section, Key, Default, Buffer: PWideChar;
  Size: Integer): Integer;
begin
  Result := 0;
end;

procedure TRegConfigFile.Save;
begin

end;

function TRegConfigFile.SectionExists(Section: PWideChar): Boolean;
begin

end;

procedure TRegConfigFile.SetCurrentKey(Value: HKEY);
begin

end;

procedure TRegConfigFile.SetRootKey(Value: HKEY);
begin

end;

procedure TRegConfigFile.WriteBinary(Section, Key: PWideChar; Buffer: Pointer;
  Size: Integer);
begin

end;

procedure TRegConfigFile.WriteBool(Section, Key: PWideChar; Value: Boolean);
begin

end;

procedure TRegConfigFile.WriteFloat(Section, Key: PWideChar; Value: Double);
begin

end;

procedure TRegConfigFile.WriteInteger(Section, Key: PWideChar; Value: Int64);
begin

end;

procedure TRegConfigFile.WriteString(Section, Key, Value: PWideChar);
begin

end;

{ TXmlConfigFile }

const
  XMLLayerSeparator = '/';

function NextNodeName(Text: PWideChar; TextEnd: PWideChar; out NodeName: WideString): PWideChar;
var
  Start: PWideChar;
  Temp: WideString;
begin
  Start := Text;
  NodeName := '';
  while Text < TextEnd do
  begin
    if Text^ = XMLLayerSeparator then
    begin
      Inc(Text);
      if (Text^ <> XMLLayerSeparator) or (Text = TextEnd) then
      begin
        SetString(NodeName, Start, Text - Start - 1);
        Result := Text;
        Exit;
      end;
    end;
    Inc(Text);
  end;

  SetString(NodeName, Start, Text - Start);
  Result := Text;
end;

procedure TXmlConfigFile.BrowseToNode(const NodePath: WideString;
  RootNode: IXMLNode; out Node: IXMLNode; CreateNonExistant: Boolean);
var
  NodeName: WideString;
  Text: PWideChar;
  TextEnd: PWideChar;
begin
  Text := PWideChar(NodePath);
  TextEnd := Text + Length(NodePath);
  Node := nil;
  if RootNode = nil then RootNode := FXMLDoc.DocumentElement;

  while (Text < TextEnd) and Assigned(RootNode) do
  begin
    Text := NextNodeName(Text, TextEnd, NodeName);

    Node := RootNode.ChildNodes.FindNode(NodeName);
    if not Assigned(Node) and CreateNonExistant then
    begin
      Node := RootNode.AddChild(NodeName);
    end;
    RootNode := Node;
  end;
end;

constructor TXmlConfigFile.Create(const XmlFile: WideString);
begin
  inherited Create;
  FXMLDoc := TXMLDocument.Create(nil);
  FXMLDoc.Options := [doNodeAutoIndent];
  FFileName := XmlFile;
end;

function TXmlConfigFile.EraseSectionN(const Section: WideString): Boolean;
var
  Node: IXMLNode;
begin
  Node := FXMLDoc.DocumentElement.ChildNodes.FindNode(Section);
  if Assigned(Node) then
  begin
    Result := FXMLDoc.DocumentElement.ChildNodes.Remove(Node) <> -1;
  end else Result := False;
end;

{ "Path" can be formed by embedding dollar signs in the parent section's name.
   If you want to denote a normal dollar sign, you must use 2 dollar signs,
   if you want n-dollar signs you need n+1 dollar signs etc. }
function TXmlConfigFile.GetSectionsN(const ParentSection: WideString): WideString;
var
  I: Integer;
  Root: IXMLNode;
  Node: IXMLNode;
begin
  Result := '';
  if ParentSection <> '' then
  begin
    BrowseToNode(ParentSection, nil, Root, False)
  end else
  begin
    Root := FXMLDoc.DocumentElement;
  end;
  
  if not Assigned(Root) then Exit;
  with Root.ChildNodes do
  begin
    for I := 0 to Count -1 do
    begin
      Node := Get(I);
      Result := Result + sLineBreak + Node.Text;
    end;
  end;
end;

function TXmlConfigFile.GetSectionValuesN(const Section: WideString): WideString;
var
  I: Integer;
  Root: IXMLNode;
  Node: IXMLNode;
begin
  Result := '';
  if Section <> '' then
  begin
    BrowseToNode(Section, nil, Root, False)
  end else
  begin
    Root := FXMLDoc.DocumentElement;
  end;
  
  if not Assigned(Root) then Exit;
  with Root.ChildNodes do
  begin
    for I := 0 to Count -1 do
    begin
      Node := Get(I);
      Result := Result + sLineBreak + Node.NodeName + '=' + Node.Text;
    end;
  end;
end;

procedure TXmlConfigFile.Load;
begin
  if WideFileExists(FFileName) then
  begin
    FXMLDoc.LoadFromFile(FFileName);
  end else
  begin
    FXMLDoc.Active := True;
    FXMLDoc.AddChild('Configuration');
  end;
end;

function TXmlConfigFile.ReadStringN(const Section, Key,
  Default: WideString): WideString;
var
  Node: IXMLNode;
begin
  BrowseToNode(Section, nil, Node, False);
  if Assigned(Node) then
  begin
    Node := Node.ChildNodes.FindNode(Key);
    if Assigned(Node) then
    begin
      Result := Node.Text;
    end else Result := Default;
  end else Result := Default;
end;

procedure TXmlConfigFile.Save;
begin
  if not FModified then Exit;

  FXMLDoc.SaveToFile(FFileName);
  FModified := False;
end;

function TXmlConfigFile.SectionExistsN(const Section: WideString): Boolean;
var
  Node: IXMLNode;
begin
  BrowseToNode(Section, nil, Node, False);
  Result := Assigned(Node);
end;

procedure TXmlConfigFile.WriteStringN(const Section, Key, Value: WideString);
var
  Node: IXMLNode;
  NodeSibling: IXMLNode;
begin
  BrowseToNode(Section, nil, Node, True);
  NodeSibling := Node.ChildNodes.FindNode(Key);
  if not Assigned(NodeSibling) then NodeSibling := Node.AddChild(Key);
  NodeSibling.Text := Value;
  FModified := True;
end;

end.
