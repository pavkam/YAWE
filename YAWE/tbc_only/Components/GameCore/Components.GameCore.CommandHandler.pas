{*------------------------------------------------------------------------------
  Chat command handler.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author Seth
  @Changes Morpheus
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.CommandHandler;

interface

uses
  Framework.Base,
  Components.Interfaces,
  Components.DataCore.Types,
  Components.GameCore.WowPlayer,
  SysUtils,
  Classes,
  Bfg.Utils,
  Bfg.Containers,
  Bfg.Classes;

const
  PARAMS_NONE: array[0..1] of UInt32 = (0, 0);
  PARAMS_UNLIMITED: array[0..1] of UInt32 = (0, MaxInt);


type
  YCommandCallResult = (ccrNotFound, ccrBadParamCount, ccrBadParamType, ccrAccessDenied,
    ccrDisabled, ccrUnspecifiedError, ccrRootCommand, ccrOk, ccrSupressMsg);
  { Types of possible command results - used by the chat manager }

  YGaCommandHandlerTable = class;

  YFmtCommandCallback = function(Context: Pointer; Table: YGaCommandHandlerTable;
    Params: TStringDataList): YCommandCallResult;

  YCommandCallback = function(Context: Pointer; Table: YGaCommandHandlerTable;
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

  YGaCommandHandlerTable = class(TInterfacedObject, ICommandHandler)
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

  YGaChatCommands = class
  public
    class procedure Initialize;static;
    class function ProcessChatCommand(Sender: YGaPlayer; var sCommand: string): Boolean;static;
    class function CommandHelp(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandList(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandSyntax(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandOnline(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandAdd(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandSetSpeed(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandSave(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandGPS(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandTeleport(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandLevelUp(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandMorph(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandDeMorph(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandShowMount(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandHideMount(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandTeleportTo(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandBroadcast(Sender: YGaPlayer; Table: YGaCommandHandlerTable; const Args: string): YCommandCallResult;static;
    class function CommandCreateNode(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandDeleteNode(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandNodeAddSpawn(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandNodeRemSpawn(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandSetUnitFlagBits(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandUnSetUnitFlagBits(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandTestUnitFlagBits(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandSetPass(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandQueryHeight(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandDisableCommand(Sender: YGaPlayer; Table: YGaCommandHandlerTable; const Args: string): YCommandCallResult;static;
    class function CommandEnableCommand(Sender: YGaPlayer; Table: YGaCommandHandlerTable; const Args: string): YCommandCallResult;static;
    class function CommandKill(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandStartMovement(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;

   { Debug command handlers }
    class function CommandDbgSetUpdateFieldI(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandDbgSetUpdateFieldF(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandDbgEquipmeWithItems(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandDbgSuicide(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandDbgHealSelf(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
    class function CommandDbgHonor(Sender: YGaPlayer; Table: YGaCommandHandlerTable; Params: TStringDataList): YCommandCallResult;static;
  end;

implementation

uses
  Cores,
  Bfg.Geometry,
  Components.GameCore,
  Components.Shared,
  Components.GameCore.Constants,
  Components.GameCore.UpdateFields,
  Components.GameCore.WowMobile,
  Components.GameCore.WowCreature,
  Components.GameCore.Nodes,
  Components.NetworkCore.Packet,
  Components.NetworkCore.OpCodes,
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

class procedure YGaChatCommands.Initialize;
const
  { Basic syntax definition }
  SEP = ' ';
  S_NO = '(No parameters expected)';
  S_INT = '<Integer>';
  S_STR = '<String>';
  S_FLT = '<Float>';
  S_INT_O = '[Integer]';
  S_STR_O = '[String]';
  S_FLT_O = '[Float]';
  S_MULT = 'N';

  { All help context put here! }
  HELP_CTX_NONE = 'There is no information available on this command, please consult the administrators.';
  HELP_CTX_HELP = 'Shows more detailed description of commands specified.';
  HELP_CTX_LIST = 'Lists all avaiable commands for your account level.';
  HELP_CTX_SYNTAX = 'Displays the syntax for the specified commands.';
  HELP_CTX_ONLINE = 'Shows you the total number of players online.';
  HELP_CTX_ADD = 'Adds an item or more into your bag.';
  HELP_CTX_SETSPEED = 'Sets your speed to a new constant. Use ".setspeed default" to set its default value';
  HELP_CTX_HONOR = 'Simulates that you killed some oponent with random option like level difference, his rank, etc';
  HELP_CTX_EQUIPME = 'Equips you with some hardcoded items, usually for test purposes.';
  HELP_CTX_SUICIDE = 'Drops your health to 1, almost killing you.';
  HELP_CTX_HEAL = 'Heals yourself for X damage.';
  HELP_CTX_MEUPDI = 'Changes an integer update field. WARNING: Developer only!';
  HELP_CTX_MEUPDF = 'Changes a float update field. WARNING: Developer only!';
  HELP_CTX_SETBIT = 'Sets a specified bit in a value set [UFF, UNF, PB, PB2, PB3, PFB, PFB2, UFB1, UFB2]. WARNING: Developer only!';
  HELP_CTX_UNSETBIT = 'Unsets a specified bit in a value set [UFF, UNF, PB, PB2, PB3, PFB, PFB2, UFB1, UFB2]. WARNING: Developer only!';
  HELP_CTX_TESTBIT = 'Tests a specified bit in a value set [UFF, UNF, PB, PB2, PB3, PFB, PFB2, UFB1, UFB2]. WARNING: Developer only!';
  HELP_CTX_DISCMD = 'Disables a command which can be enabled using .ENCMD.';
  HELP_CTX_ENCMD = 'Enables a previously disabled command using .DISCMD.';
  HELP_CTX_SAVE =
    'Saves the whole DB to disk. Optional parameter specifies if the server save ' +
    'timer should be refreshed (by default yes).';
  HELP_CTX_WARP = 'Teleports you to a desired location (Map, X, Y, Z).';
  HELP_CTX_GPS = 'Shows you the current location (Map and X, Y, Z coordinates).';
  HELP_CTX_LEVELUP = 'Adds you one or more levels.';
  HELP_CTX_MORPH = 'Turns you into model specified.';
  HELP_CTX_DEMORPH = 'Turns you into your original model.';
  HELP_CTX_SHOWMOUNT = 'Graphicly mounts you on mount model you specify.';
  HELP_CTX_HIDEMOUNT = 'Graphicly dismounts you from a mount.';
  HELP_CTX_WARPTO = 'Teleports you to a player. (name is case IN-sensitive)';
  HELP_CTX_BROADCAST = 'Displays a message to all players. Message must be enclosed with quotes(").';
  HELP_CTX_CLOAK = 'Hides you before all other players. (untested)';
  HELP_CTX_UNCLOAK = 'Makes you visible again before all other players. (untested)';

  HELP_CTX_NEWNODE =
    'Creates a node at your location and returns you its ID. You may use this ID ' +
    'to change the properties of this new node.';
  HELP_CTX_DELNODE =
    'Deletes a node specified by index. The node is automaticly unregistered/unlinked and spawns ' +
    'are removed.';
  HELP_CTX_ADDSPAWN =
    'Adds a new spawn entry to the specified node. Returns the ID ' +
    'of this entry in spawn''s entry table. You may use this ID to change or remove this entry.';
  HELP_CTX_REMSPAWN =
    'Removes a spawn entry identified by spawn entry table id.';
  HELP_CTX_SETPASS =
    'Sets or Resets yout account password.';
  HELP_CTX_HEIGHTQUERY =
    'Queries the height of a specified point or of your position. WARNING: Developer only!';
  HELP_CTX_KILL = 'Kills the selected creature.';
  HELP_CTX_SET_TP = 'Set a TP place';
  HELP_CTX_LIST_TP = 'Go to a TP place';
  HELP_CTX_GO_TP = 'Lists all TP places';
  HELP_CTX_REM_TP = 'Remove a TP place';
  { Concreate command syntaxes }
  SYN_HELP = S_MULT + S_STR_O;
  SYN_LIST = S_NO;
  SYN_HONOR = S_NO;
  SYN_EQUIPME = S_NO;
  SYN_SYNTAX = S_MULT + S_STR_O;
  SYN_ONLINE = S_NO;
  SYN_ADD = S_INT + SEP + S_INT_O;
  SYN_SETSPEED = S_INT;
  SYN_SUICIDE = S_NO;
  SYN_HEAL = S_INT;
  SYN_MOVE = S_FLT + SEP + S_FLT;
  SYN_MEUPDI = S_INT + SEP + S_INT;
  SYN_MEUPDF = S_INT + SEP + S_FLT;
  SYN_UBIT = S_INT + SEP + S_INT;
  SYN_DISCMD = S_STR;
  SYN_ENCMD = S_STR;
  SYN_SAVE = S_INT_O;
  SYN_WARP = S_INT + SEP + S_FLT + SEP + S_FLT + SEP + S_FLT;
  SYN_GPS = S_NO;
  SYN_LEVELUP = S_INT_O;
  SYN_MORPH = S_NO;
  SYN_DEMORPH = S_NO;
  SYN_SHOWMOUNT = S_INT;
  SYN_HIDEMOUNT = S_NO;
  SYN_WARPTO = S_STR;
  SYN_BROADCAST = S_STR + SEP + S_INT_O;
  SYN_CLOAK = S_NO;
  SYN_UNCLOAK = S_NO;
  SYN_NEWNODE = S_NO;
  SYN_DELNODE = S_INT_O;
  SYN_ADDSPAWN = S_INT_O + SEP + S_INT + SEP + S_FLT + SEP + S_FLT + SEP + S_INT + SEP + S_INT;
  SYN_REMSPAWN = S_INT_O + SEP + S_INT;
  SYN_SETPASS = S_STR;
  SYN_HEIGHTQUERY = S_INT_O + SEP + S_FLT_O + SEP + S_FLT_O;
  SYN_KILL = S_NO;
  SYN_SET_TP = S_STR;
  SYN_GO_TP = S_STR;
  SYN_LIST_TP = S_NO;
  SYN_REM_TP = S_STR;
begin
  { Root command declarations put here! }
  GameCore.CommandHandler.AddRootCommand(['SET'], HELP_CTX_NONE);
  GameCore.CommandHandler.AddRootCommand(['GET'], HELP_CTX_NONE);
  GameCore.CommandHandler.AddRootCommand(['ADD'], HELP_CTX_NONE);
  GameCore.CommandHandler.AddRootCommand(['REM'], HELP_CTX_NONE);

  { Concrete command declarations put here! }
  GameCore.CommandHandler.AddCommandHandler(['HELP'], @YGaChatCommands.CommandHelp, PARAMS_UNLIMITED, HELP_CTX_HELP, SYN_HELP, []);
  GameCore.CommandHandler.AddCommandHandler(['LIST'], @YGaChatCommands.CommandList, PARAMS_NONE, HELP_CTX_LIST, SYN_LIST, []);
  GameCore.CommandHandler.AddCommandHandler(['SYNTAX'], @YGaChatCommands.CommandSyntax, PARAMS_UNLIMITED, HELP_CTX_SYNTAX, SYN_SYNTAX, []);
  GameCore.CommandHandler.AddCommandHandler(['ONLINE'], @YGaChatCommands.CommandOnline, PARAMS_NONE, HELP_CTX_ONLINE, SYN_ONLINE, []);
  GameCore.CommandHandler.AddCommandHandler(['HONOR'], @YGaChatCommands.CommandDbgHonor, PARAMS_NONE, HELP_CTX_HONOR, SYN_HONOR, []);
  GameCore.CommandHandler.AddCommandHandler(['SUICIDE'], @YGaChatCommands.CommandDbgSuicide, PARAMS_NONE, HELP_CTX_SUICIDE, SYN_SUICIDE, []);
  GameCore.CommandHandler.AddCommandHandler(['HEAL'], @YGaChatCommands.CommandDbgHealSelf, [1, 1], HELP_CTX_HEAL, SYN_HEAL, []);
  GameCore.CommandHandler.AddCommandHandler(['SAVE'], @YGaChatCommands.CommandSave, [0, 1], HELP_CTX_SAVE, SYN_SAVE, []);

  GameCore.CommandHandler.AddCommandHandler(['ADD', 'ITEM'], @YGaChatCommands.CommandAdd, [1, 2], HELP_CTX_ADD, SYN_ADD, []);
  GameCore.CommandHandler.AddCommandHandler(['SET', 'SPEED'], @YGaChatCommands.CommandSetSpeed, [0, 1], HELP_CTX_SETSPEED, SYN_SETSPEED, []);
  GameCore.CommandHandler.AddCommandHandler(['SET', 'PASS'], @YGaChatCommands.CommandSetPass,[1, 1], HELP_CTX_SETPASS, SYN_SETPASS, []);
  GameCore.CommandHandler.AddCommandHandler(['ADD', 'NODE'], @YGaChatCommands.CommandCreateNode, PARAMS_NONE, HELP_CTX_NEWNODE, SYN_NEWNODE, []);
  GameCore.CommandHandler.AddCommandHandler(['REM', 'NODE'], @YGaChatCommands.CommandDeleteNode, [1, 1], HELP_CTX_DELNODE, SYN_DELNODE, []);
  GameCore.CommandHandler.AddCommandHandler(['ADD', 'SPAWN'], @YGaChatCommands.CommandNodeAddSpawn, [5, 6], HELP_CTX_ADDSPAWN, SYN_ADDSPAWN, []);
  GameCore.CommandHandler.AddCommandHandler(['REM', 'SPAWN'], @YGaChatCommands.CommandNodeRemSpawn, [2, 2], HELP_CTX_REMSPAWN, SYN_REMSPAWN, []);
  GameCore.CommandHandler.AddCommandHandler(['GET', 'Z'], @YGaChatCommands.CommandQueryHeight, [0, 3], HELP_CTX_HEIGHTQUERY, SYN_HEIGHTQUERY, []);

  GameCore.CommandHandler.AddCommandHandler(['WARP'], @YGaChatCommands.CommandTeleport, [4, 4], HELP_CTX_WARP, SYN_WARP, []);
  GameCore.CommandHandler.AddCommandHandler(['WARPTO'], @YGaChatCommands.CommandTeleportTo,[1, 1], HELP_CTX_WARPTO, SYN_WARPTO, []);
  GameCore.CommandHandler.AddCommandHandler(['GPS'], @YGaChatCommands.CommandGPS, PARAMS_NONE, HELP_CTX_GPS, SYN_GPS, []);
  GameCore.CommandHandler.AddCommandHandler(['LEVELUP'], @YGaChatCommands.CommandLevelUp, [0, 1], HELP_CTX_LEVELUP, SYN_LEVELUP, []);
  GameCore.CommandHandler.AddCommandHandler(['MORPH'], @YGaChatCommands.CommandMorph, [1, 1], HELP_CTX_MORPH, SYN_MORPH, []);
  GameCore.CommandHandler.AddCommandHandler(['DEMORPH'], @YGaChatCommands.CommandDeMorph, PARAMS_NONE, HELP_CTX_DEMORPH, SYN_DEMORPH, []);
  GameCore.CommandHandler.AddCommandHandler(['SHOWMOUNT'], @YGaChatCommands.CommandShowMount, [1, 1], HELP_CTX_SHOWMOUNT, SYN_SHOWMOUNT, []);
  GameCore.CommandHandler.AddCommandHandler(['HIDEMOUNT'], @YGaChatCommands.CommandHideMount, PARAMS_NONE, HELP_CTX_HIDEMOUNT, SYN_HIDEMOUNT, []);
  //GameCore.CommandHandler.AddCommandHandler('BROADCAST', CommandBroadcast, [1, 1], HELP_CTX_BROADCAST, SYN_BROADCAST, []);
  //GameCore.CommandHandler.AddCommandHandler('CLOAK', CommandMakeInvisible, PARAMS_NONE, HELP_CTX_CLOAK, SYN_CLOAK, []);
  //GameCore.CommandHandler.AddCommandHandler('UNCLOAK', CommandMakeVisible, PARAMS_NONE, HELP_CTX_UNCLOAK, SYN_UNCLOAK, []);
  GameCore.CommandHandler.AddCommandHandler(['EQUIPME'], @YGaChatCommands.CommandDbgEquipmeWithItems, PARAMS_NONE, HELP_CTX_EQUIPME, SYN_EQUIPME, []);
  //GameCore.CommandHandler.AddCommandHandler(['MOVEME'], CommandDebugMove, [2, 2], HELP_CTX_NONE, SYN_MOVE, []);
  GameCore.CommandHandler.AddCommandHandler(['MEUPDI'], @YGaChatCommands.CommandDbgSetUpdateFieldI, [2, 2], HELP_CTX_MEUPDI, SYN_MEUPDI, []);
  GameCore.CommandHandler.AddCommandHandler(['MEUPDF'], @YGaChatCommands.CommandDbgSetUpdateFieldF, [2, 2], HELP_CTX_MEUPDF, SYN_MEUPDF, []);
  GameCore.CommandHandler.AddCommandHandler(['SETBIT'], @YGaChatCommands.CommandSetUnitFlagBits, [2, 2], HELP_CTX_SETBIT, SYN_UBIT, []);
  GameCore.CommandHandler.AddCommandHandler(['UNSETBIT'], @YGaChatCommands.CommandUnSetUnitFlagBits, [2, 2], HELP_CTX_UNSETBIT, SYN_UBIT, []);
  GameCore.CommandHandler.AddCommandHandler(['TESTBIT'], @YGaChatCommands.CommandTestUnitFlagBits, [2, 2], HELP_CTX_TESTBIT, SYN_UBIT, []);
  GameCore.CommandHandler.AddCommandHandlerRaw(['DISCMD'], @YGaChatCommands.CommandDisableCommand, [1, 1], HELP_CTX_DISCMD, SYN_DISCMD, []);
  GameCore.CommandHandler.AddCommandHandlerRaw(['ENCMD'], @YGaChatCommands.CommandEnableCommand, [1, 1], HELP_CTX_ENCMD, SYN_ENCMD, []);
  GameCore.CommandHandler.AddCommandHandler(['KILL'], @YGaChatCommands.CommandKill, PARAMS_NONE, HELP_CTX_KILL, SYN_KILL, []);
  //GameCore.CommandHandler.AddCommandHandler(['SET', 'TP'], @YGaChatCommands.CommandSetTp, [1, 1], HELP_CTX_SET_TP, SYN_SET_TP, []);
  //GameCore.CommandHandler.AddCommandHandler(['GOTP'], @YGaChatCommands.CommandGoTP, [1, 1], HELP_CTX_GO_TP, SYN_GO_TP, []);
  //GameCore.CommandHandler.AddCommandHandler(['LISTTP'], @YGaChatCommands.CommandListTP, PARAMS_NONE, HELP_CTX_LIST_TP, SYN_LIST_TP, []);
  //GameCore.CommandHandler.AddCommandHandler(['REM', 'TP'], @YGaChatCommands.CommandRemTP, [1, 1], HELP_CTX_REM_TP, SYN_REM_TP, []);
  GameCore.CommandHandler.AddCommandHandler(['MOVETARGET'], @YGaChatCommands.CommandStartMovement, PARAMS_NONE, HELP_CTX_NONE, S_NO, []);
end;

class function YGaChatCommands.ProcessChatCommand(Sender: YGaPlayer; var sCommand: string): Boolean;
const
  ReplyTable: array[YCommandCallResult] of string = (
    'Specified command does not exist.',
    'Invalid parameter count. Please read the manual.',
    'Invalid parameter type. Please read the manual.',
    'You are not allowed to use this command.',
    'This command has been disabld.',
    'Unspecified error occured. Command hasn''t been executed.',
    'The command you specified is a root command and it cannot work without a subcommand.',
    'Command has been executed.',
    ''
  );
var
  iResult: YCommandCallResult;
begin
  if sCommand[1] = '.' then
  begin
    iResult := GameCore.CommandHandler.CallCommandHandler(sCommand, nil, Sender);
    Sender.SendSystemMessage(ReplyTable[iResult]);

    Result := True;
  end else Result := False;
end;

class function YGaChatCommands.CommandAdd(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  iItem, iAmount: Int32;
begin
  iItem := Params.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  if Params.List.Count = 1 then
  begin
    iAmount := 1;
  end else
  begin
    iAmount := Params.GetAsInteger(1, bSuccess);
    if not bSuccess then
    begin
      Result := ccrBadParamType;
      Exit;
    end;
  end;

  Sender.EqpAddItem(iItem, IAmount, True);

  Result := ccrSupressMsg;
end;

class function YGaChatCommands.CommandBroadcast(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  const Args: string): YCommandCallResult;
begin
  Result := ccrSupressMsg;
end;

class function YGaChatCommands.CommandCreateNode(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  pVect: PVector;
begin
  pVect := @Sender.Vector;
  Sender.SendSystemMessage('Node created. ID: ' +
    itoa(GameCore.NodeManager.CreateNode(pVect^.X, pVect^.Y, pVect^.Z,
    Sender.MapId).Id));
  Result := ccrSupressMsg;
end;

class function YGaChatCommands.CommandDbgEquipmeWithItems(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
begin
  Sender.EqpDeleteItem(BAG_NULL, EQUIP_SLOT_MAIN_HAND, True);
  Sender.EqpInsertItem(EQUIP_SLOT_MAIN_HAND, 1);
  Sender.EqpDeleteItem(BAG_NULL, EQUIP_SLOT_RANGED_WEAPON, True);
  Sender.EqpInsertItem(EQUIP_SLOT_RANGED_WEAPON, 6469);
  Sender.EqpDeleteItem(BAG_NULL, EQUIP_SLOT_OFF_HAND, True);
  Sender.EqpInsertItem(EQUIP_SLOT_OFF_HAND, 8135);
  Sender.EqpDeleteItem(BAG_NULL, EQUIP_SLOT_CHEST, True);
  Sender.EqpInsertItem(EQUIP_SLOT_CHEST, 12422);
  Sender.EqpDeleteItem(BAG_NULL, EQUIP_SLOT_BOOTS, True);
  Sender.EqpInsertItem(EQUIP_SLOT_BOOTS, 12426);
  Sender.EqpDeleteItem(BAG_NULL, EQUIP_SLOT_PANTS, True);
  Sender.EqpInsertItem(EQUIP_SLOT_PANTS, 12429);
  Sender.EqpDeleteItem(BAG_NULL, EQUIP_SLOT_BELT, True);
  Sender.EqpInsertItem(EQUIP_SLOT_BELT, 12424);
  Sender.EqpDeleteItem(BAG_NULL, EQUIP_SLOT_WRIST, True);
  Sender.EqpInsertItem(EQUIP_SLOT_WRIST, 12425);
  Sender.EqpDeleteItem(BAG_NULL, EQUIP_SLOT_HEAD, True);
  Sender.EqpInsertItem(EQUIP_SLOT_HEAD, 12427);
  Sender.EqpDeleteItem(BAG_NULL, EQUIP_SLOT_SHOULDERS, True);
  Sender.EqpInsertItem(EQUIP_SLOT_SHOULDERS, 12428);
  Sender.EqpDeleteItem(BAG_NULL, EQUIP_SLOT_SHIRT, True);
  Sender.EqpInsertItem(EQUIP_SLOT_SHIRT, 14617);
  Sender.EqpDeleteItem(BAG_NULL, EQUIP_SLOT_FINGER_1, True);
  Sender.EqpInsertItem(EQUIP_SLOT_FINGER_1, 862);
  Sender.EqpDeleteItem(BAG_NULL, EQUIP_SLOT_FINGER_2, True);
  Sender.EqpInsertItem(EQUIP_SLOT_FINGER_2, 862);
  Sender.EqpDeleteItem(BAG_NULL, EQUIP_SLOT_TRINKET_1, True);
  Sender.EqpInsertItem(EQUIP_SLOT_TRINKET_1, 744);
  Sender.EqpDeleteItem(BAG_NULL, EQUIP_SLOT_TRINKET_2, True);
  Sender.EqpInsertItem(EQUIP_SLOT_TRINKET_2, 744);

  Result := ccrSupressMsg;
end;

class function YGaChatCommands.CommandDbgHealSelf(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  iAmount: Int32;
  lwCurrHealth: Longword;
begin
  if StringsEqualNoCase(Params.GetAsString(0), 'FULL') then
  begin
    Sender.Stats.Health := Sender.Stats.MaxHealth;
    Result := ccrOk;
    Exit;
  end;
  iAmount := Params.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;
  lwCurrHealth := Sender.Stats.Health;
  if lwCurrHealth < Sender.Stats.MaxHealth then
  begin
    Inc(lwCurrHealth, iAmount);
    if lwCurrHealth > Sender.Stats.MaxHealth then
      Sender.Stats.Health := Sender.Stats.MaxHealth
    else
      Sender.Stats.Health := lwCurrHealth;
  end;
  Result := ccrOk;
end;

class function YGaChatCommands.CommandDbgHonor(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
begin
  //This will simulate that you killed some random options oponents
  //to test honor actually! 

  //Sender.Honor.IncreaseSessionKills(Random(9), Random(10), Random(10), Random(500), Random(99), Random(100), True);

  Result := ccrOk;
end;

class function YGaChatCommands.CommandDbgSetUpdateFieldF(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  iIndex: Int32;
  fValue: Float;
begin
  iIndex := Params.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  fValue := Params.GetAsFloat(1, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  Sender.SetFloat(iIndex, fValue);
  Result := ccrOk;
end;

class function YGaChatCommands.CommandDbgSetUpdateFieldI(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  iIndex: Int32;
  iValue: Int32;
begin
  iIndex := Params.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  iValue := Params.GetAsInteger(1, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  Sender.SetUInt32(iIndex, iValue);
  Result := ccrOk;
end;

class function YGaChatCommands.CommandDbgSuicide(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
begin
  if Sender.Stats.Health > 1 then Sender.Stats.Health := 1;
  Result := ccrOk;
end;

class function YGaChatCommands.CommandDeleteNode(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  iId: Uint32;
  bSuccess: Boolean;
begin
  iId := Params.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  bSuccess := GameCore.NodeManager.DeleteNode(GameCore.NodeManager.Nodes[iId]);
  if bSuccess then
  begin
    Sender.SendSystemMessage('Node ' + itoa(iId) + ' deleted.');
  end else
  begin
    Sender.SendSystemMessage('Node ' + itoa(iId) + ' does not exist.');
  end;
  Result := ccrSupressMsg;
end;

class function YGaChatCommands.CommandDeMorph(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
begin
  Sender.SetUInt32(UNIT_FIELD_DISPLAYID, Sender.GetUInt32(UNIT_FIELD_NATIVEDISPLAYID));

  Result := ccrOk;
end;

class function YGaChatCommands.CommandDisableCommand(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  const Args: string): YCommandCallResult;
var
  aPath: TStringDynArray;
begin
  aPath := StringSplit(Args);
  if Table.DisableCommandHandler(aPath) then
  begin
    Result := ccrOk;
  end else Result := ccrNotFound;
end;

class function YGaChatCommands.CommandEnableCommand(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  const Args: string): YCommandCallResult;
var
  aPath: TStringDynArray;
begin
  aPath := StringSplit(Args);
  if Table.EnableCommandHandler(aPath) then
  begin
    Result := ccrOk;
  end else Result := ccrNotFound;
end;

class function YGaChatCommands.CommandGPS(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
const
  GpsMsg = 'GPS: Map = %d, X = %f, Y = %f, Z = %f, Angle = %f';
var
  tPos: TVector;
  fAngle: Float;
  iMap: UInt32;
begin
  tPos := Sender.Vector;
  fAngle := Sender.Angle;
  iMap := Sender.MapId;

  Sender.SendSystemMessage(Format(GpsMsg, [iMap, tPos.X, tPos.Y, tPos.Z, fAngle]));
  Result := ccrSupressMsg;
end;

class function YGaChatCommands.CommandHelp(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  //iAccess: YAccountAccess;
  pCmd: PCommandData;
  sMsg: string;
  iInt: Int32;
begin
  if Params.List.Count = 0 then
  begin
    Sender.SendSystemMessage(Table.GetCommandHelpContext(['HELP']));
  end else if (Params.List.Count = 1) and StringsEqualNoCase(Params.GetAsString(0), 'ALL') then
  begin
    //iAccess := cPlayer.Security;
    for iInt := 0 to Table.CommandList.Count -1 do
    begin
      sMsg := Table.CommandList[iInt];
      pCmd := PCommandData(Table.CommandList.Objects[iInt]);
      //if iAccess >= pCmd^.AccessLevel then
      //begin
        sMsg := '.' + sMsg + ' - ' + pCmd^.HelpContext;
        Sender.SendSystemMessage(sMsg);
      //end;
    end;
  end else
  begin
    for iInt := 0 to Params.List.Count -1 do
    begin
      sMsg := Params.GetAsString(iInt);
      if Table.CommandExists(sMsg) then
      begin
        Sender.SendSystemMessage('.' + sMsg + ' - ' + Table.GetCommandHelpContext(sMsg));
      end;
    end;
  end;
  Result := ccrSupressMsg;
end;

class function YGaChatCommands.CommandHideMount(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
begin
  Sender.SetUInt32(UNIT_FIELD_MOUNTDISPLAYID, 0);

  Result := ccrOk;
end;

class function YGaChatCommands.CommandKill(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  iGUID: UInt64;
  cObject: YGaMobile;
begin
  iGUID := Sender.GetUInt64(UNIT_FIELD_TARGET);
  GameCore.FindObjectByGUID(otUnit, iGUID, cObject);
  if not Assigned(cObject) then
  begin
    Result := ccrUnspecifiedError;
    Exit;
  end;
  //Sender.Quests.UpdateKillObject(cObject.Entry, iGUID);
  Result := ccrOk;
end;

class function YGaChatCommands.CommandLevelUp(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  iLvl: UInt32;
  bSuccess: Boolean;
begin
  if Params.List.Count = 1 then
  begin
    iLvl := Params.GetAsInteger(0, bSuccess);
    if not bSuccess then
    begin
      Result := ccrBadParamType;
      Exit;
    end;
  end else iLvl := Sender.Stats.Level + 1;
  Sender.Stats.Level := iLvl;
  Result := ccrOk;
end;

class function YGaChatCommands.CommandList(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  iInt: Int32;
  pCmd: PCommandData;
  //iAccess: YAccountAccess;
begin
  //iAccess := cPlayer.Security;
  Sender.SendSystemMessage('Available commands:');
  for iInt := 0 to Table.CommandList.Count -1 do
  begin
    pCmd := PCommandData(Table.CommandList.Objects[iInt]);
    Sender.SendSystemMessage('.' + pCmd^.Name);
  end;
  Result := ccrSupressMsg;
end;

class function YGaChatCommands.CommandMorph(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  iModel: UInt32;
begin
  iModel := Params.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  Sender.SetUInt32(UNIT_FIELD_DISPLAYID, iModel);

  Result := ccrOk;
end;

class function YGaChatCommands.CommandNodeAddSpawn(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  iId: UInt32;
  iOutId: UInt32;
  tSpawnEntry: YNodeSpawnInfo;
  ifNode: INode;
  ifSpawnContext: ISpawnNodeContext;
begin
  iId := Params.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  tSpawnEntry.EntryId := Params.GetAsInteger(1, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  tSpawnEntry.DistanceMin := Params.GetAsFloat(2, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  tSpawnEntry.DistanceMax := Params.GetAsFloat(3, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  tSpawnEntry.DelayMin := Params.GetAsInteger(4, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  tSpawnEntry.DelayMax := Params.GetAsInteger(5, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  tSpawnEntry.EntryType := otUnit;

  ifNode := GameCore.NodeManager.Nodes[iId];
  if Assigned(ifNode) then
  begin
    ifSpawnContext := ifNode.FindContextByInterface(ISpawnNodeContext) as ISpawnNodeContext;
    if not Assigned(ifSpawnContext) then
    begin
      ifSpawnContext := GameCore.NodeManager.CreateSpawnContext(ifNode);
    end;

    iOutId := 0;
    ifSpawnContext.AddSpawnEntry(tSpawnEntry);
    Sender.SendSystemMessage('Spawn entry added. Id of this entry in node entry table: ' +
      itoa(iOutId));
  end else
  begin
    Sender.SendSystemMessage('Node ' + itoa(iId) + ' does not exist.');
  end;
  
  Result := ccrSupressMsg;
end;

class function YGaChatCommands.CommandNodeRemSpawn(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  iId: UInt32;
  iTableId: UInt32;
  ifNode: INode;
  ifSpawnContext: ISpawnNodeContext;
begin
  iId := Params.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  iTableId := Params.GetAsInteger(1, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  ifNode := GameCore.NodeManager.Nodes[iId];
  if Assigned(ifNode) then
  begin
    ifSpawnContext := ifNode.FindContextByInterface(ISpawnNodeContext) as ISpawnNodeContext;
    if Assigned(ifSpawnContext) then
    begin
      ifSpawnContext.RemoveSpawnEntry(iTableId);
      Sender.SendSystemMessage('Spawn entry ' + itoa(iTableId) + ' removed.');
    end else
    begin
      Sender.SendSystemMessage('Spawn entry ' + itoa(iTableId) + ' not found.');
    end;
  end else
  begin
    Sender.SendSystemMessage('Node ' + itoa(iId) + ' does not exist.');
  end;

  Result := ccrSupressMsg;
end;

class function YGaChatCommands.CommandOnline(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  iPlayerCount: Int32;
begin
  iPlayerCount := GameCore.SessionCount;
  if iPlayerCount <> 1 then
  begin
    Sender.SendSystemMessage('There are ' + IntToStr(GameCore.SessionCount) + ' players online.');
  end else
  begin
    Sender.SendSystemMessage('There is 1 player online.');
  end;
  Result := ccrSupressMsg;
end;

class function YGaChatCommands.CommandQueryHeight(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  iMap: UInt32;
  fX, fY: Float;
  fZ: Float;
  bSuccess: Boolean;
begin
  if Params.List.Count = 0 then
  begin
    with Sender do
    begin
      if GameCore.TerrainManager.QueryHeightAt(MapId, X, Y, fZ) then
      begin
        Sender.SendSystemMessage(Format('The height at your position is: %f', [fz]));
      end else
      begin
        Sender.SendSystemMessage('The height data could not be queried. Either the .ymf file is not present or you''re standing in a non-existing tile (client-wise).');
      end;
    end;
    Result := ccrSupressMsg;
  end else if Params.List.Count > 1 then
  begin
    if Params.List.Count = 3 then
    begin
      iMap := Params.GetAsInteger(0, bSuccess);
      if not bSuccess then
      begin
        Result := ccrBadParamType;
        Exit;
      end;

      fX := Params.GetAsFloat(1, bSuccess);
      if not bSuccess then
      begin
        Result := ccrBadParamType;
        Exit;
      end;

      fY := Params.GetAsFloat(2, bSuccess);
      if not bSuccess then
      begin
        Result := ccrBadParamType;
        Exit;
      end;
    end else
    begin
      fX := Params.GetAsFloat(0, bSuccess);
      if not bSuccess then
      begin
        Result := ccrBadParamType;
        Exit;
      end;

      fY := Params.GetAsFloat(1, bSuccess);
      if not bSuccess then
      begin
        Result := ccrBadParamType;
        Exit;
      end;
      iMap := Sender.MapId;
    end;

    if GameCore.TerrainManager.QueryHeightAt(iMap, fX, fY, fZ) then
    begin
      Sender.SendSystemMessage(Format('The height at [MAP_%d, %f, %f] is: %f', [iMap, fX, fY, fZ]));
    end else
    begin
      Sender.SendSystemMessage('The height data could not be queried. Either the .ymf file is not present or the point you have chosen is in a non-existing tile (client-wise).');
    end;
    Result := ccrSupressMsg;
  end else
  begin
    Result := ccrBadParamCount;
    Exit;
  end;
end;

class function YGaChatCommands.CommandSave(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  iRefreshTimer: Int32;
  bSuccess: Boolean;
begin
  iRefreshTimer := 1;
  if Params.List.Count > 0 then
  begin
    iRefreshTimer := Params.GetAsInteger(0, bSuccess);
    if not bSuccess or not (iRefreshTimer in [0..1]) then
    begin
      Result := ccrBadParamType;
      Exit;
    end;
  end;

  DataCore.FullSave(Boolean(iRefreshTimer));
  Sender.SendSystemMessage('DB save in progress...');
  Result := ccrSupressMsg;
end;

class function YGaChatCommands.CommandSetPass(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  sPass: string;
  cAcc: YDbAccountEntry;
begin
  if Params.List.Count <> 1 then
  begin
    Result := ccrBadParamCount;
    Exit;
  end;

  sPass := Params.GetAsString(0);
  if sPass = '' then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  //DataCore.Accounts.LoadEntry(FIELD_ACC_NAME, Sender.Account, cAcc);
  cAcc.Pass := sPass;
  cAcc.AutoCreated := False;
  //DataCore.Accounts.SaveEntry(cAcc);
  Sender.SendSystemMessage('Command .setpass executed.' + #13#10 + 'New password is: ' + sPass);
  Result := ccrSupressMsg;
end;

class function YGaChatCommands.CommandSetSpeed(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  fBaseSpeed: Float;
  bSuccess: Boolean;
  aOutPkts: array[0..1] of YNwServerPacket;
begin
  fBaseSpeed := Params.GetAsFloat(0, bSuccess) / 7;
  if not bSuccess then
  begin
    if StringsEqualNoCase(Params.GetAsString(0), 'DEFAULT') then
    begin
      fBaseSpeed := 7.5 / 7;
    end else
    begin
      Result := ccrBadParamType;
      Exit;
    end;
  end;

  with Sender do
  begin
    RunSpeed := SPEED_RUN * fBaseSpeed;
    BackSwimSpeed := SPEED_BACKSWIM * fBaseSpeed;
    SwimSpeed := SPEED_SWIM * fBaseSpeed;

    aOutPkts[0] := YNwServerPacket.Initialize(SMSG_FORCE_RUN_SPEED_CHANGE);
    aOutPkts[1] := YNwServerPacket.Initialize(SMSG_FORCE_SWIM_SPEED_CHANGE);
    try
      aOutPkts[0].AddPackedGUID(Sender.GUID);
      aOutPkts[0].AddUInt32(0);
      aOutPkts[0].AddFloat(RunSpeed);

      aOutPkts[1].AddPackedGUID(Sender.GUID);
      aOutPkts[1].AddUInt32(0);
      aOutPkts[1].AddFloat(SwimSpeed);

      Sender.SendPacketSetInRange(aOutPkts, VIEW_DISTANCE, True, True);

    finally
      aOutPkts[0].Free;
      aOutPkts[1].Free;
    end;
  end;
  Result := ccrOk;
end;

class function YGaChatCommands.CommandSetUnitFlagBits(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  sFlags: string;
  iBit: UInt32;
  iFlags: UInt32;
label
  __BadParam;
begin
  iBit := Params.GetAsInteger(1, bSuccess);

  if not bSuccess or (iBit > 31) then
  begin
    goto __BadParam;
  end;

  sFlags := Params.GetAsString(0);

  if StringsEqualNoCase(sFlags, 'UFF') then iFlags := UNIT_FIELD_FLAGS
  else if StringsEqualNoCase(sFlags, 'UNF') then iFlags := UNIT_NPC_FLAGS
  else if StringsEqualNoCase(sFlags, 'PB') then iFlags := PLAYER_BYTES
  else if StringsEqualNoCase(sFlags, 'PB1') then iFlags := PLAYER_BYTES_2
  else if StringsEqualNoCase(sFlags, 'PB2') then iFlags := PLAYER_BYTES_3
  else if StringsEqualNoCase(sFlags, 'PFB') then iFlags := PLAYER_FIELD_BYTES
  else if StringsEqualNoCase(sFlags, 'PFB2') then iFlags := PLAYER_FIELD_BYTES2
  else if StringsEqualNoCase(sFlags, 'UFB1') then iFlags := UNIT_FIELD_BYTES_1
  else if StringsEqualNoCase(sFlags, 'UFB2') then iFlags := UNIT_FIELD_BYTES_2
  else iFlags := StrToIntDef(sFlags, 0);

  if iFlags <= 0 then
  begin
    __BadParam:
    Result := ccrBadParamType;
    Exit;
  end;

  Sender.SetBit(iFlags, iBit);
  Result := ccrOk;
end;

class function YGaChatCommands.CommandShowMount(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  iModel: UInt32;
begin
  iModel := Params.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  Sender.SetUInt32(UNIT_FIELD_MOUNTDISPLAYID, iModel);

  Result := ccrOk;
end;

class function YGaChatCommands.CommandStartMovement(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  tGuid: YObjectGuid;
  cMob: YGaMobile;
  cCr: YGaCreature;
  tVec: TVector;
begin
  tGuid := YObjectGuid(Sender.GetUInt64(UNIT_FIELD_TARGET));
  if GameCore.FindObjectByGUID(tGuid.Hi, tGuid.Lo, cMob) then
  begin
    if cMob.InheritsFrom(YGaCreature) then
    begin
      cCr := YGaCreature(cMob);
      VectorAdd(cCr.Vector, 5, tVec);

      if not GameCore.TerrainManager.QueryHeightAt(cCr.MapId, tVec.X, tVec.Y, tVec.Z) then
      begin
        tVec.Z := cCr.Z;
      end;
      
      cCr.StartMovement(tVec, False);
      Result := ccrOk;
    end else
    begin
      Sender.SendSystemMessage('Invalid selection.');
      Result := ccrSupressMsg;
    end;
  end else
  begin
    Sender.SendSystemMessage('You have no selection.');
    Result := ccrSupressMsg;
  end;
end;

class function YGaChatCommands.CommandSyntax(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
const
  SYN_LEGEND =
    'Syntax description legend:' + #13#10 +
    'Integer - expects a number' + #13#10 +
    'String - expects a string' + #13#10 +
    'Float - expects a number or a float' + #13#10 +
    '<> - needed parameter' + #13#10 +
    '[] - optional parameter' + #13#10 +
    'N[] - variable number of optional parameters';
var
  iInt: Int32;
  pCmd: PCommandData;
begin
  if Params.List.Count = 0 then
  begin
    Sender.SendSystemMessage(SYN_LEGEND);
  end else
  begin
    for iInt := 0 to Params.List.Count -1 do
    begin
      pCmd := Table.GetCommandData([Params.GetAsString(iInt)]);
      if pCmd <> nil then
      begin
        Sender.SendSystemMessage(pCmd^.Name + ' - ' + pCmd^.Syntax);
      end;
    end;
  end;
  Result := ccrSupressMsg;
end;

class function YGaChatCommands.CommandTeleport(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  iMap: UInt32;
  fX, fY, fZ: Float;
  bSuccess: Boolean;
begin
  iMap := Params.GetAsInteger(0, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  fX := Params.GetAsFloat(1, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  fY := Params.GetAsFloat(2, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  fZ := Params.GetAsFloat(3, bSuccess);
  if not bSuccess then
  begin
    Result := ccrBadParamType;
    Exit;
  end;

  Sender.DoTeleport(iMap, fX, fY, fZ);

  Result := ccrOk;
end;

class function YGaChatCommands.CommandTeleportTo(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  sName: string;
  cTeleportTo: YGaPlayer;
begin
  sName := Params.GetAsString(0);
  case GameCore.FindPlayerByName(sName, cTeleportTo) of
    lrNonExistant:
    begin
      Sender.SendSystemMessage('Player does not exist.');
      Result := ccrSupressMsg;
    end;
    lrOffline:
    begin
      Sender.SendSystemMessage('Player is not online.');
      Result := ccrSupressMsg;
    end;
    lrOnline:
    begin
      with cTeleportTo do
      begin
        Sender.DoTeleport(MapId, X, Y, Z);
      end;

      Result := ccrOk;
    end;
  else
    Result := ccrOk;
  end;
end;

class function YGaChatCommands.CommandTestUnitFlagBits(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  sFlags: string;
  iBit: UInt32;
  iFlags: UInt32;
label
  __BadParam;
begin
  iBit := Params.GetAsInteger(1, bSuccess);
  
  if not bSuccess or (iBit > 31) then
  begin
    goto __BadParam;
  end;

  sFlags := Params.GetAsString(0);

  if StringsEqualNoCase(sFlags, 'UFF') then iFlags := UNIT_FIELD_FLAGS
  else if StringsEqualNoCase(sFlags, 'UNF') then iFlags := UNIT_NPC_FLAGS
  else if StringsEqualNoCase(sFlags, 'PB') then iFlags := PLAYER_BYTES
  else if StringsEqualNoCase(sFlags, 'PB1') then iFlags := PLAYER_BYTES_2
  else if StringsEqualNoCase(sFlags, 'PB2') then iFlags := PLAYER_BYTES_3
  else if StringsEqualNoCase(sFlags, 'PFB') then iFlags := PLAYER_FIELD_BYTES
  else if StringsEqualNoCase(sFlags, 'PFB2') then iFlags := PLAYER_FIELD_BYTES2
  else if StringsEqualNoCase(sFlags, 'UFB1') then iFlags := UNIT_FIELD_BYTES_1
  else if StringsEqualNoCase(sFlags, 'UFB2') then iFlags := UNIT_FIELD_BYTES_2
  else iFlags := StrToIntDef(sFlags, 0);

  if iFlags <= 0 then
  begin
    __BadParam:
    Result := ccrBadParamType;
    Exit;
  end;

  Sender.SendSystemMessage('Tested bit ' + itoa(iBit) + '. The result is ' +
    BoolToStr(Sender.TestBit(iFlags, iBit)));

  Result := ccrOk;
end;

class function YGaChatCommands.CommandUnSetUnitFlagBits(Sender: YGaPlayer; Table: YGaCommandHandlerTable;
  Params: TStringDataList): YCommandCallResult;
var
  bSuccess: Boolean;
  sFlags: string;
  iBit: UInt32;
  iFlags: UInt32;
label
  __BadParam;
begin
  iBit := Params.GetAsInteger(1, bSuccess);
  
  if not bSuccess or (iBit > 31) then
  begin
    goto __BadParam;
  end;

  sFlags := Params.GetAsString(0);

  if StringsEqualNoCase(sFlags, 'UFF') then iFlags := UNIT_FIELD_FLAGS
  else if StringsEqualNoCase(sFlags, 'UNF') then iFlags := UNIT_NPC_FLAGS
  else if StringsEqualNoCase(sFlags, 'PB') then iFlags := PLAYER_BYTES
  else if StringsEqualNoCase(sFlags, 'PB1') then iFlags := PLAYER_BYTES_2
  else if StringsEqualNoCase(sFlags, 'PB2') then iFlags := PLAYER_BYTES_3
  else if StringsEqualNoCase(sFlags, 'PFB') then iFlags := PLAYER_FIELD_BYTES
  else if StringsEqualNoCase(sFlags, 'PFB2') then iFlags := PLAYER_FIELD_BYTES2
  else if StringsEqualNoCase(sFlags, 'UFB1') then iFlags := UNIT_FIELD_BYTES_1
  else if StringsEqualNoCase(sFlags, 'UFB2') then iFlags := UNIT_FIELD_BYTES_2
  else iFlags := StrToIntDef(sFlags, 0);

  if iFlags <= 0 then
  begin
    __BadParam:
    Result := ccrBadParamType;
    Exit;
  end;

  Sender.ResetBit(iFlags, iBit);
  Result := ccrOk;
end;

end.
