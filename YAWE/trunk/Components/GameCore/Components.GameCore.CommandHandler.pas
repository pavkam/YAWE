{*------------------------------------------------------------------------------
  Chat command handler.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.CommandHandler;

interface

uses
  Framework.Base,
  Components.Interfaces,
  Components.DataCore.Types,
  SysUtils,
  Classes,
  Misc.Containers,
  Misc.Miscleanous;

const
  PARAMS_NONE: array[0..1] of UInt32 = (0, 0);
  PARAMS_UNLIMITED: array[0..1] of UInt32 = (0, MaxInt);


type
  YCommandCallResult = (ccrNotFound, ccrBadParamCount, ccrBadParamType, ccrAccessDenied,
    ccrDisabled, ccrUnspecifiedError, ccrRootCommand, ccrOk, ccrSupressMsg);
  { Types of possible command results - used by the chat manager }

  YGaCommandHandlerTable = class;

  YFmtCommandCallback = function(Context: Pointer; Sender: YGaCommandHandlerTable;
    Params: TStringDataList): YCommandCallResult;

  YCommandCallback = function(Context: Pointer; Sender: YGaCommandHandlerTable;
    const Params: string): YCommandCallResult;

  {$Z4}
  YCommandType = (ctNormal, ctRoot);
  {$Z1}

  PCommandData = ^YCommandData;
  YCommandDataArray = array of PCommandData;
  
  YCommandData = record
    FullName: string; { Fully qualified name }
    Name: string; { Name }
    HelpContext: string; { Description }
    CmdType: YCommandType;
    RequiredPrivs: TCharDynArray;
    ParamBounds: array[0..1] of UInt32; { Min and Max count of params }
    Syntax: string; { Optional syntax description }
    Enabled: Boolean; { Are we enabled? }
    ChildCommands: YCommandDataArray; { Child commands list }
    case FormatArguments: Longbool of
      False: (CallbackRaw: YCommandCallback); { Callback }
      True: (CallbackFmt: YFmtCommandCallback);
  end;

  PListCategoryInfo = ^YListCategoryInfo;
  YListCategoryInfo = record
    Description: string;
    Commands: array of string;
  end;

  ICommandHandler = interface(IInterface)
  ['{E2F3DA10-E6F0-430C-8764-C66DF924E7C2}']
    function AddCommandHandlerRaw(const Path: array of string; Callback: YCommandCallback;
      const ParamCountRange: array of UInt32; const HelpContext: string;
      const Syntax: string; const RequiredPrivs: array of Char): Boolean;

    function AddCommandHandler(const Path: array of string; Callback: YFmtCommandCallback;
      const ParamCountRange: array of UInt32; const HelpContext: string;
      const Syntax: string; const RequiredPrivs: array of Char): Boolean;

    function AddRootCommand(const Path: array of string; const HelpContext: string): Boolean;

    function CommandExists(const Ident: string): Boolean;
    function GetCommandHelpContext(const Path: array of string): string;
    function GetCommandSyntax(const Path: array of string): string;
  end;

  YGaCommandHandlerTable = class(TBaseInterfacedObject, ICommandHandler)
    private
      fCommands: TStrPtrHashMap;
      fCommandNamesList: TStringList;
      fMaximumDepth: Integer;
      fListCategories: TStrPtrHashMap;

      function MakeFullyQualifiedName(const Path: array of string): string;
      function PriviledgeCheck(const P1: TCharDynArray; const P2: TCharDynArray): Boolean;
    public
      constructor Create; 
      destructor Destroy; override;

      { Creates and adds a new command handler with the specified params. If the
        function succeeds and a new handler is created, the function returns True.
        If a handler with the specified name already exists, the function returns
        False. The Path argument specifies the list of "parent" commands in case
        this command should be a child command of a root command.}
      function AddCommandHandlerRaw(const Path: array of string; Callback: YCommandCallback;
        const ParamCountRange: array of UInt32; const HelpContext: string;
        const Syntax: string; const RequiredPrivs: array of Char): Boolean;

      function AddCommandHandler(const Path: array of string; Callback: YFmtCommandCallback;
        const ParamCountRange: array of UInt32; const HelpContext: string;
        const Syntax: string; const RequiredPrivs: array of Char): Boolean;

      { Creates a new root command and optionaly assigns it an info string. A root
        command cannot be executed directly, instead it may hold child commands
        (which themselves can be root commands) and transfer control to them if
        they are encountered. }
      function AddRootCommand(const Path: array of string; const HelpContext: string): Boolean;

      { Temporarily disables a command handler specified by the Path paramater.
        If the handler cannot be found or it is already disabled, the function
        returns false. }
      function DisableCommandHandler(const Path: array of string): Boolean;

      { Enables a previously disabled handler. If the handler cannot be found or
        it is already enabled, the function returns false. }
      function EnableCommandHandler(const Path: array of string): Boolean;

      function CallCommandHandler(var Args: string; const Privs: TCharDynArray;
        Context: Pointer): YCommandCallResult;

      function CommandExists(const Ident: string): Boolean;

      function GetCommandHelpContext(const Path: array of string): string;
      function GetCommandSyntax(const Path: array of string): string;
      function GetCommandData(const Path: array of string): PCommandData;
      property CommandList: TStringList read fCommandNamesList;
  end;

implementation

uses
  Math;

{ YGaCommandHandlerTable }

constructor YGaCommandHandlerTable.Create;
begin
  inherited Create;
  fCommands := TStrPtrHashMap.Create(False, 128);
  fListCategories := TStrPtrHashMap.Create(False, 32);
  fCommandNamesList := TStringList.Create;
  fCommandNamesList.Sorted := True;
end;

destructor YGaCommandHandlerTable.Destroy;
var
  iIdx: Int32;
  pData: PCommandData;
begin
  for iIdx := 0 to fCommandNamesList.Count -1 do
  begin
    pData := Pointer(fCommandNamesList.Objects[iIdx]);
    Dispose(pData);
  end;

  fCommandNamesList.Free;
  fListCategories.Free;
  fCommands.Free;
  inherited Destroy;
end;

function YGaCommandHandlerTable.PriviledgeCheck(const P1: TCharDynArray;
  const P2: TCharDynArray): Boolean;
var
  I: Integer;
  PT1, PT2: TCharDynArray;
begin
  Result := True;

  if Length(P2) = 0 then Exit;

  if Length(P1) >= Length(P2) then
  begin
    PT1 := P1;
    PT2 := P2;
  end else
  begin
    PT1 := P2;
    PT2 := P1;
  end;

  for I := 0 to Length(PT2) -1 do
  begin
    if CharPos(PT2[I], string(PT1)) = 0 then
    begin
      Result := False;
      Exit;
    end;
  end;

end;

function YGaCommandHandlerTable.AddCommandHandlerRaw(const Path: array of string;
  Callback: YCommandCallback; const ParamCountRange: array of UInt32;
  const HelpContext: string; const Syntax: string;
  const RequiredPrivs: array of Char): Boolean;
var
  pCommand: PCommandData;
  pRoot: PCommandData;
  pTemp: PCommandData;
  sIdent: string;
  sLookupName: string;
  iLen: Int32;
  iIdx: Int32;
  iInt: Int32;
begin
  iLen := Length(Path);
  if iLen = 0 then
  begin
    Result := False;
    Exit;
  end;

  if Length(ParamCountRange) <> 2 then
  begin
    Result := False;
    Exit;
  end;

  sIdent := Path[High(Path)];

  if iLen > 1 then
  begin
    pRoot := fCommands.GetValue(Path[0]);
    if (pRoot = nil) or (pRoot^.CmdType = ctNormal) then
    begin
      Result := False;
      Exit;
    end;

    sLookupName := pRoot^.Name;

    if iLen > 2 then
    begin
      for iIdx := 1 to High(Path) -1 do
      begin
        pTemp := pRoot;
        for iInt := 0 to Length(pRoot^.ChildCommands) -1 do
        begin
          if Assigned(pRoot^.ChildCommands[iInt]) then
          begin
            if (pRoot^.CmdType = ctRoot) and (pRoot^.ChildCommands[iInt]^.Name = Path[iIdx]) then
            begin
              pRoot := pRoot^.ChildCommands[iInt];
              Break;
            end;
          end;
        end;
        if pTemp = pRoot then
        begin
          Result := False;
          Exit;
        end else
        begin
          sLookupName := sLookupName + '@' + pRoot^.Name;
        end;
      end;
    end;

    sLookupName := sLookupName + '@' + sIdent;
  end else
  begin
    pRoot := nil;
    sLookupName := sIdent;
  end;

  pCommand := AllocMem(SizeOf(YCommandData));
  with pCommand^ do
  begin
    FullName := MakeFullyQualifiedName(Path);
    Name := sIdent;
    CmdType := ctNormal;
    CallbackRaw := Callback;
    FormatArguments := False;
    RequiredPrivs := RequiredPrivs;
    ParamBounds[0] := ParamCountRange[0];
    ParamBounds[1] := ParamCountRange[1];
    HelpContext := HelpContext;
    Syntax := Syntax;
    Enabled := True;
  end;

  fMaximumDepth := Max(fMaximumDepth, Length(Path));
  fCommands.PutValue(sLookupName, pCommand);
  fCommandNamesList.AddObject(sLookupName, TObject(pCommand));

  if pRoot <> nil then
  begin
    iInt := Length(pRoot^.ChildCommands);
    SetLength(pRoot^.ChildCommands, iInt + 1);
    pRoot^.ChildCommands[iInt] := pCommand;
  end;

  Result := True;
end;

function YGaCommandHandlerTable.AddCommandHandler(const Path: array of string;
  Callback: YFmtCommandCallback; const ParamCountRange: array of UInt32;
  const HelpContext, Syntax: string;
  const RequiredPrivs: array of Char): Boolean;
var
  pCommand: PCommandData;
  pRoot: PCommandData;
  pTemp: PCommandData;
  sIdent: string;
  sLookupName: string;
  iLen: Int32;
  iIdx: Int32;
  iInt: Int32;
begin
  iLen := Length(Path);
  if iLen = 0 then
  begin
    Result := False;
    Exit;
  end;

  if Length(ParamCountRange) <> 2 then
  begin
    Result := False;
    Exit;
  end;

  sIdent := Path[High(Path)];

  if iLen > 1 then
  begin
    pRoot := fCommands.GetValue(Path[0]);
    if (pRoot = nil) or (pRoot^.CmdType = ctNormal) then
    begin
      Result := False;
      Exit;
    end;

    sLookupName := pRoot^.Name;

    if iLen > 2 then
    begin
      for iIdx := 1 to High(Path) -1 do
      begin
        pTemp := pRoot;
        for iInt := 0 to Length(pRoot^.ChildCommands) -1 do
        begin
          if Assigned(pRoot^.ChildCommands[iInt]) then
          begin
            if (pRoot^.CmdType = ctRoot) and (pRoot^.ChildCommands[iInt]^.Name = Path[iIdx]) then
            begin
              pRoot := pRoot^.ChildCommands[iInt];
              Break;
            end;
          end;
        end;
        if pTemp = pRoot then
        begin
          Result := False;
          Exit;
        end else
        begin
          sLookupName := sLookupName + '@' + pRoot^.Name;
        end;
      end;
    end;

    sLookupName := sLookupName + '@' + sIdent;
  end else
  begin
    pRoot := nil;
    sLookupName := sIdent;
  end;

  pCommand := AllocMem(SizeOf(YCommandData));
  with pCommand^ do
  begin
    FullName := MakeFullyQualifiedName(Path);
    Name := sIdent;
    CmdType := ctNormal;
    CallbackFmt := Callback;
    FormatArguments := True;
    RequiredPrivs := RequiredPrivs;
    ParamBounds[0] := ParamCountRange[0];
    ParamBounds[1] := ParamCountRange[1];
    HelpContext := HelpContext;
    Syntax := Syntax;
    Enabled := True;
  end;

  fMaximumDepth := Max(fMaximumDepth, Length(Path));
  fCommands.PutValue(sLookupName, pCommand);
  fCommandNamesList.AddObject(sLookupName, TObject(pCommand));

  if pRoot <> nil then
  begin
    iInt := Length(pRoot^.ChildCommands);
    SetLength(pRoot^.ChildCommands, iInt + 1);
    pRoot^.ChildCommands[iInt] := pCommand;
  end;

  Result := True;
end;

function YGaCommandHandlerTable.AddRootCommand(const Path: array of string;
  const HelpContext: string): Boolean;
var
  pCommand: PCommandData;
  pRoot: PCommandData;
  pTemp: PCommandData;
  sIdent: string;
  sLookupName: string;
  iLen: Int32;
  iIdx: Int32;
  iInt: Int32;
begin
  iLen := Length(Path);
  if iLen = 0 then
  begin
    Result := False;
    Exit;
  end;

  sIdent := Path[High(Path)];

  if iLen > 1 then
  begin
    pRoot := fCommands.GetValue(Path[0]);
    if (pRoot = nil) or (pRoot^.CmdType = ctNormal) then
    begin
      Result := False;
      Exit;
    end;

    sLookupName := pRoot^.Name;

    if iLen > 2 then
    begin
      for iIdx := 1 to High(Path) -1 do
      begin
        pTemp := pRoot;
        for iInt := 0 to Length(pRoot^.ChildCommands) -1 do
        begin
          if Assigned(pRoot^.ChildCommands[iInt]) then
          begin
            if (pRoot^.CmdType = ctRoot) and (pRoot^.ChildCommands[iInt]^.Name = Path[iIdx]) then
            begin
              pRoot := pRoot^.ChildCommands[iInt];
              Break;
            end;
          end;
        end;
        if pTemp = pRoot then
        begin
          Result := False;
          Exit;
        end else
        begin
          sLookupName := sLookupName + '@' + pRoot^.Name;
        end;
      end;
    end;

    sLookupName := sLookupName + '@' + sIdent;
  end else
  begin
    pRoot := nil;
    sLookupName := sIdent;
  end;

  pCommand := AllocMem(SizeOf(YCommandData));
  with pCommand^ do
  begin
    HelpContext := HelpContext;
    FullName := MakeFullyQualifiedName(Path);
    Name := sIdent;
    CmdType := ctRoot;
  end;

  fMaximumDepth := Max(fMaximumDepth, Length(Path));
  fCommands.PutValue(sLookupName, pCommand);
  fCommandNamesList.AddObject(sLookupName, TObject(pCommand));

  if pRoot <> nil then
  begin
    iInt := Length(pRoot^.ChildCommands);
    SetLength(pRoot^.ChildCommands, iInt + 1);
    pRoot^.ChildCommands[iInt] := pCommand;
  end;

  Result := True;
end;

function YGaCommandHandlerTable.DisableCommandHandler(const Path: array of string): Boolean;
var
  pData: PCommandData;
begin
  pData := GetCommandData(Path);
  if pData = nil then
  begin
    Result := False;
  end else if pData^.Enabled then
  begin
    pData^.Enabled := False;
    Result := True;
  end else Result := False;
end;

function YGaCommandHandlerTable.EnableCommandHandler(const Path: array of string): Boolean;
var
  pData: PCommandData;
begin
  pData := GetCommandData(Path);
  if pData = nil then
  begin
    Result := False;
  end else if not pData^.Enabled then
  begin
    pData^.Enabled := True;
    Result := True;
  end else Result := False;
end;

function YGaCommandHandlerTable.GetCommandData(const Path: array of string): PCommandData;
var
  iIdx: Int32;
  sName: string;
begin
  sName := Path[0];
  Result := fCommands.GetValue(sName);
  if (Result = nil) or ((Length(Path) > 1) and (Result^.CmdType = ctNormal)) then
  begin
    Result := nil;
    Exit;
  end;

  for iIdx := 1 to High(Path) do
  begin
    sName := sName + '@';
    Result := fCommands.GetValue(sName + Path[iIdx]);
    if (Result <> nil) and (Result^.CmdType = ctRoot) then
    begin
      sName := sName + Result^.Name;
    end else
    begin
      Result := nil;
      Exit;
    end;
  end;
end;

function YGaCommandHandlerTable.GetCommandHelpContext(const Path: array of string): string;
var
  pData: PCommandData;
begin
  pData := GetCommandData(Path);
  if pData = nil then
  begin
    Result := 'There is no information available about this command, please consult the administrators.';
  end else
  begin
    Result := pData^.HelpContext;
  end;
end;

function YGaCommandHandlerTable.GetCommandSyntax(const Path: array of string): string;
var
  pData: PCommandData;
begin
  pData := GetCommandData(Path);
  if (pData = nil) or (pData^.CmdType = ctRoot) then
  begin
    Result := 'There is no syntax description provided for this command.';
  end else
  begin
    Result := pData^.Syntax;
  end;
end;

function YGaCommandHandlerTable.MakeFullyQualifiedName(
  const Path: array of string): string;
var
  iIdx: Int32;
begin
  if Length(Path) = 0 then
  begin
    Result := '';
    Exit;
  end;

  Result := Path[0];
  for iIdx := 1 to High(Path) do
  begin
    Result := Result + '@' + Path[iIdx];
  end;
end;

function YGaCommandHandlerTable.CallCommandHandler(var Args: string;
  const Privs: TCharDynArray; Context: Pointer): YCommandCallResult;
var
  pData: PCommandData;
  pTemp: PCommandData;
  lwCount: UInt32;
  iDepth: Int32;
  iInt: Int32;
  aArgs: TStringDynArray;
  cList: TStringDataList;
begin
  Delete(Args, 1, 1); { Remove the DOT }
  aArgs := StringSplit(Args);
  pTemp := fCommands.GetValue(aArgs[0]);
  if pTemp = nil then
  begin
    Result := ccrNotFound;
    Exit;
  end;

  pData := pTemp;
  iDepth := 1;

  while (pTemp^.CmdType = ctRoot) and (iDepth < fMaximumDepth) do
  begin
    pTemp := fCommands.GetValue(pTemp^.Name + '@' + aArgs[iDepth]);
    Inc(iDepth);
    if (pTemp = nil) then
      Break
    else
      pData := pTemp;
  end;

  if pData = nil then
  begin
    Result := ccrNotFound;
    Exit;
  end;

  if pData^.CmdType = ctRoot then
  begin
    Result := ccrRootCommand;
    Exit;
  end;

  with pData^ do
  begin
    { Found the command we're looking for }
    if Enabled then
    begin
      { And it's enabled }
      if PriviledgeCheck(Privs, RequiredPrivs) then
      begin
        { Our access level is high enough }
        lwCount := Longword(Length(aArgs) - iDepth);
        if (lwCount >= ParamBounds[0]) and (lwCount <= ParamBounds[1]) then
        begin
          { Param count is ok }
          if FormatArguments then
          begin
            cList := TStringDataList.Create;
            try
              for iInt := iDepth to High(aArgs) do
              begin
                cList.List.Append(aArgs[iInt]);
              end;
              Result := CallbackFmt(Context, Self, cList);
            finally
              cList.Free;
            end;
          end else
          begin
            Delete(Args, 1, CharPos(' ', Args));
            Result := CallbackRaw(Context, Self, Args);
          end;
          { Execute the callback and get the result }
        end else Result := ccrBadParamCount;
      end else Result := ccrAccessDenied;
    end else Result := ccrDisabled;
  end;
end;

function YGaCommandHandlerTable.CommandExists(const Ident: string): Boolean;
begin
  Result := fCommands.ContainsKey(Ident);
end;

end.
