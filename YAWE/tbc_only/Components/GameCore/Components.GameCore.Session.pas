{*------------------------------------------------------------------------------
  GameCore's Session.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth, TheSelby, BigBoss, Morpheus.
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.Session;

interface

uses
  SysUtils,
  Bfg.Utils,
  Bfg.Containers,
  Bfg.Resources,
  Bfg.Geometry,
  Framework.Base,
  Framework.Tick,
  Version,
  Components.NetworkCore.Packet,
  Components.Shared,
  Components.Interfaces,
  Components.NetworkCore.Opcodes,
  Components.NetworkCore.Constants,
  Components.GameCore.WowObject,
  Components.GameCore.WowMobile,
  Components.GameCore.WowCreature,
  Components.GameCore.WowPlayer,
  Components.GameCore.WowItem,
  Components.GameCore.UpdateFields,
  Components.GameCore.Constants,
  Components.GameCore.Types,
  Components.IoCore.Console,
  Components.DataCore.Types;

type
  { OpenSession represents the "mini-world" that a player lives in }
  YGaSession = class(TInterfacedObject, ISessionInterface)
    private
      FAccountName: WideString;
      FRealmName: WideString;
      FLogoutTimerHandle: TEventHandle;
      FSocket: ISocketInterface;
      FActivePlayer: YGaPlayer;
      FHandle: TEventHandle;

      { Sends a packet to XCore }
      procedure SendPacket(Pkt: YNwServerPacket); inline;

      { All Game Handling Opcodes }
      procedure HandleNoAction(InPkt: YNwClientPacket);
      procedure HandleCharEnumOpcode(InPkt: YNwClientPacket);
      procedure HandleCharCreateOpcode(InPkt: YNwClientPacket);
      procedure HandleCharDeleteOpcode(InPkt: YNwClientPacket);
      procedure HandleCharLoginOpcode(InPkt: YNwClientPacket);
      procedure HandleNameQuery(InPkt: YNwClientPacket);
      procedure HandleItemNameQuery(InPkt: YNwClientPacket);
      procedure HandleItemQuerySingle(InPkt: YNwClientPacket);
      procedure HandleCreatureQuery(InPkt: YNwClientPacket);
      procedure HandleSheathedOpcode(InPkt: YNwClientPacket);
      procedure HandleTimeQuery(InPkt: YNwClientPacket);
      procedure HandleNextMailTimeQuery(InPkt: YNwClientPacket);
      procedure LogoutManipulation(InPkt: YNwClientPacket);
      procedure TutorialManipulation(InPkt: YNwClientPacket);
      procedure ChatManipulation(InPkt: YNwClientPacket);
      procedure HandleChannelJoin(InPkt: YNwClientPacket);
      procedure HandleChannelLeave(InPkt: YNwClientPacket);
      procedure HandleChannelListRequest(InPkt: YNwClientPacket);
      procedure HandleChannelPasswordSet(InPkt: YNwClientPacket);
      procedure HandleChannelOwnerSet(InPkt: YNwClientPacket);
      procedure HandleChannelOwnerGet(InPkt: YNwClientPacket);
      procedure HandleChannelPromote(InPkt: YNwClientPacket);
      procedure HandleChannelDepromote(InPkt: YNwClientPacket);
      procedure HandleChannelMute(InPkt: YNwClientPacket);
      procedure HandleChannelUnmute(InPkt: YNwClientPacket);
      procedure HandleChannelSendInvitiation(InPkt: YNwClientPacket);
      procedure HandleChannelKick(InPkt: YNwClientPacket);
      procedure HandleChannelBan(InPkt: YNwClientPacket);
      procedure HandleChannelUnban(InPkt: YNwClientPacket);
      procedure HandleChannelToggleAnnounce(InPkt: YNwClientPacket);
      procedure HandleChannelToggleModerated(InPkt: YNwClientPacket);
      procedure HandleMovement(InPkt: YNwClientPacket);
      procedure HandleStandStateChange(InPkt: YNwClientPacket);
      procedure HandleSetSelection(InPkt: YNwClientPacket);
      procedure HandleSwapInvItem(InPkt: YNwClientPacket);
      procedure HandleSwapItem(InPkt: YNwClientPacket);
      procedure HandleAutoEquipItem(InPkt: YNwClientPacket);
      procedure HandleAutoStoreBagItem(InPkt: YNwClientPacket);
      procedure HandleSetAmmo(InPkt: YNwClientPacket);
      procedure HandleSplitItem(InPkt: YNwClientPacket);
      procedure HandleUseItem(InPkt: YNwClientPacket);
      procedure HandleDestroyItem(InPkt: YNwClientPacket);
      procedure HandleInitiateTrade(InPkt: YNwClientPacket);
      procedure HandleBeginTrade(InPkt: YNwClientPacket);
      procedure HandleBusyTrade(InPkt: YNwClientPacket);
      procedure HandleIgnoreTrade(InPkt: YNwClientPacket);
      procedure HandleAcceptTrade(InPkt: YNwClientPacket);
      procedure HandleUnAcceptTrade(InPkt: YNwClientPacket);
      procedure HandleCancelTrade(InPkt: YNwClientPacket);
      procedure HandleSetTradeItem(InPkt: YNwClientPacket);
      procedure HandleClearTradeItem(InPkt: YNwClientPacket);
      procedure HandleSetTradeGold(InPkt: YNwClientPacket);
      procedure HandleMoveWorldPortACK(InPkt: YNwClientPacket);
      procedure HandleGossipHello(InPkt: YNwClientPacket);
      procedure HandleGossipSelectionOption(InPkt: YNwClientPacket);
      procedure HandleNPCTextQuery(InPkt: YNwClientPacket);
      procedure HandleQuestGiverStatusQuery(InPkt: YNwClientPacket);
      procedure HandleQuestGiverHello(InPkt: YNwClientPacket);
      procedure HandleQuestGiverQueryQuest(InPkt: YNwClientPacket);
      procedure HandleQuestGiverQuestAutoLaunch(InPkt: YNwClientPacket);
      procedure HandleQuestGiverAcceptQuest(InPkt: YNwClientPacket);
      procedure HandleQuestGiverCompleteQuest(InPkt: YNwClientPacket);
      procedure HandleQuestGiverRequestReward(InPkt: YNwClientPacket);
      procedure HandleQuestGiverChooseReward(InPkt: YNwClientPacket);
      procedure HandleQuestGiverCancel(InPkt: YNwClientPacket);
      procedure HandleQuestQuery(InPkt: YNwClientPacket);
      procedure HandleQuestLogSwapQuest(InPkt: YNwClientPacket);
      procedure HandleQuestLogRemoveQuest(InPkt: YNwClientPacket);
      procedure HandleQuestConfirmAccept(InPkt: YNwClientPacket);
      procedure HandlePageTextQuery(InPkt: YNwClientPacket);
      procedure HandlePushQuestToParty(InPkt: YNwClientPacket);
      procedure HandleAreaTrigger(InPkt: YNwClientPacket);

      procedure SessionLogOut(Event: TEventHandle; TimeDelta: UInt32);
      function CheckCharValidity(const Name: WideString; PlayerClass: YGameClass;
        PlayerRace: YGameRace): Boolean;
      procedure SendCharOperationCode(Error: UInt8);
      { Needed for player }
      function GetRealmName: WideString;
      function GetAccount: WideString;
      procedure SetAccount(const Acc: WideString);
    public
      constructor Create; 
      destructor Destroy; override;

      { Opcode Dispatcher. Returns True for Handled }
      function DispatchOpcode(InPkt: YNwClientPacket; OpCode: Longword): Boolean;

      { Timer }
      procedure SessionTimer(Event: TEventHandle; TimeDelta: UInt32);

      procedure BufferLockAcquire;
      procedure BufferLockRelease;

      procedure SendCloseGossip;
      procedure SendCompleteQuest(GUID: UInt64; QuestID: UInt32);
      procedure SendGossipMenu(Cr: YGaCreature; GUID: UInt64);
      procedure SendQuestDetails(GUID: UInt64; QuestID: UInt32);
      procedure SendQuestList(QuestGiver: YGaCreature; GUID: UInt64);
      procedure SendQuestReward(GUID: UInt64; QuestID: UInt32);
      
      { External Visibility }
      property Account: WideString read FAccountName write SetAccount;
      property RealmName: WideString read FRealmName write FRealmName;
      property Socket: ISocketInterface read FSocket write FSocket;
    end;

implementation

uses
  Main,
  Math,
  MMSystem,
  Framework,
  Cores,
  Components.GameCore,
  Components.GameCore.Channel,
  Components.GameCore.CommandHandler,
  Components.GameCore.WowUnit,
  Components.GameCore.PacketBuilders,
  Components.GameCore.Area,
  Components.DataCore;

{$G-}

var
  Handlers: array of Pointer;
  OpcodeMax: Longword;

procedure RegisterOpcodeHandler(MethodPtr: Pointer; Opcode: Longword);
begin
  if Longword(Length(Handlers)) <= Opcode then SetLength(Handlers, Opcode + 1);
  Handlers[Opcode] := MethodPtr;
end;

{$IFNDEF ASM_OPTIMIZATIONS}
{ Delphi implementation }
function CallOpcodeHandler(Session: YGaSession; InPkt: YNwClientPacket; Opcode: Longword): Boolean;
type
  YOpcodeHandler = procedure(Session: YGaSession; Packet: YNwClientPacket);
var
  Handler: YOpcodeHandler;
begin
  if Opcode < OpcodeMax then
  begin
    Handler := Handlers[Opcode];
    if Assigned(Handler) then
    begin
      Handler(Session, InPkt);
      Result := True;
    end else Result := False;
  end else Result := False;
end;

{$ELSE}
{ Asm implementation }
function CallOpcodeHandler(Session: YGaSession; InPkt: YNwClientPacket; Opcode: Longword): Boolean;
asm
  { EAX = Session }
  { EDX = InPkt }
  { ECX = Opcode }
  CMP   ECX, OpcodeMax                  { Compare the opcode to table length }
  JAE   @@NoHandler                     { Opcode exceeds table length }
  PUSH  EBX
  MOV   EBX, [Handlers]                 { Get the contents of the array }
  MOV   ECX, [EBX+ECX*4]                { Get the handler }
  TEST  ECX, ECX                        { Test it for nil }
  JZ    @@NoHandler                     { Handler not yet implemented }
  CALL  ECX                             { Call the handler - args are in the correct order }
  { EAX = cSession }
  { EDX = cPkt }
  { ECX = Handler }
  MOV   AL, 1                           { Result := True }
  POP   EBX
  RET                                   { Exit }
@@NoHandler:
  XOR   AL, AL                          { Result := False }
end;
{$ENDIF}

procedure YGaSession.HandleCharCreateOpcode(InPkt: YNwClientPacket);
type
  { The structure we know the packet contains staticly after the client's account name }
  PPlayerCreateInfo = ^TPlayerCreateInfo;
  TPlayerCreateInfo = packed record
    Race: YGameRace;
    &Class: YGameClass;
    Gender: YGameGender;
    Skin: UInt8;
    Face: UInt8;
    HairStyle: UInt8;
    HairColor: UInt8;
    FacialHair: UInt8;
  end;
var
  Player: YGaPlayer;
  PlayerName: WideString;
  PlayerCreateInfo: PPlayerCreateInfo;
begin
  { Read the account name first }
  PlayerName := InPkt.ReadString;

  PlayerCreateInfo := InPkt.GetCurrentReadPtr;
  { I may use GetCurrentReadPtr, because I won't be reading any more data }
  { Whoala, I didn't copy even one byte and have access to data I need }

  if not CheckCharValidity(PlayerName, PlayerCreateInfo^.&Class, PlayerCreateInfo^.Race) then Exit;

  GameCore.CreateObject(otPlayer, Player);
  try
    { Initialization of Data from Request }
    with PlayerCreateInfo^ do
    begin
      Player.Account := Account;
      Player.Stats.Level := 0; { Char just created }
      Player.Name := PlayerName;
      Player.Skin := Skin;
      Player.Face := Face;
      Player.HairStyle := HairStyle;
      Player.HairColor := HairColor;
      Player.FacialHair := FacialHair;

      { Adding Template Data }
      Player.CreateFromTemplate(DataCore.PlayerTemplates, &Class, Race, Gender);
    end;
    
    Player.SaveToDataBase;
  finally
    Player.Free;
  end;

  SendCharOperationCode(CHAR_OPERATION_SUCCESS);
end;

procedure YGaSession.HandleCharDeleteOpcode(InPkt: YNwClientPacket);
var
  GUIDPtr: PObjectGuid;
  PlayerDbEntry: IPlayerEntry;
  I: Integer;
  Id: Longword;
begin
  GUIDPtr := InPkt.GetCurrentReadPtr;

  DataCore.Players.LookupEntry(GUIDPtr^.Longs[0], PlayerDbEntry);
  try
    if PlayerDbEntry = nil then
    begin
      SendCharOperationCode(CHAR_DELETE_FAILED);
      Exit;
    end;

    { Load the player info }
    for I := 0 to ITEMS_END do
    begin
      (*
      if cPlr.EquippedItems[iIdx] <> 0 then
      begin
        { If slot GUID <> 0 }
        DataCore.Items.DeleteEntry(cPlr.EquippedItems[iIdx]);
        { then delete that item from the DB as well }
      end;
      *)
    end;
  finally
    Id := PlayerDbEntry.UniqueID;
    DataCore.Players.ReleaseEntry(PlayerDbEntry);
    { Finally delete the char itself }
    DataCore.Players.DeleteEntry(Id);

    SendCharOperationCode(CHAR_OPERATION_SUCCESS);
  end;
end;

procedure YGaSession.HandleCharEnumOpcode(InPkt: YNwClientPacket);
var
  EntryList: array of IPlayerEntry;
  OutPkt: YNwServerPacket;
  I, J: Int32;
  Player: IPlayerEntry;
  Item: IItemEntry;
  Temp: IItemTemplateEntry;
  LookupRes: ILookupResult;

  (*
  function ExtractUInt8(Plr: YDbPlayerEntry; Index: UInt32; BytePos: UInt8): UInt8; inline;
  begin
    Result := LongRec(Plr.UpdateData[Index]).Bytes[BytePos];
  end;

  function ExtractUInt32(Plr: YDbPlayerEntry; Index: UInt32): UInt32; inline;
  begin
    Result := Plr.UpdateData[Index];
  end;
  *)
begin
  DataCore.Players.LookupEntryListW('AccountName', FAccountName, False, LookupRes);
  if Assigned(LookupRes) then
  begin
    SetLength(EntryList, LookupRes.EntryCount);
    LookupRes.GetData(EntryList[0], Length(EntryList));
  end;

  OutPkt := YNwServerPacket.Initialize(SMSG_CHAR_ENUM);
  try
    { Character Count }
    OutPkt.AddUInt8(Length(EntryList));

    for I := 0 to Length(EntryList) - 1 do
    begin
      Player := EntryList[I];

      OutPkt.AddUInt32(Player.UniqueId);
      OutPkt.AddUInt32(0);
      OutPkt.AddString(Player.Name);

      OutPkt.AddUInt8(1);
      OutPkt.AddUInt8(1);
      OutPkt.AddUInt8(1);
      //OutPkt.AddUInt8(Player.GameRace);
      //OutPkt.AddUInt8(Player.GameClass);
      //OutPkt.AddUInt8(Player.Gender);

      { Visual Aspects }
      OutPkt.AddUInt8(0);
      OutPkt.AddUInt8(0);
      OutPkt.AddUInt8(0);
      OutPkt.AddUInt8(0);
      OutPkt.AddUInt8(0);
      //OutPkt.AddUInt8(Player.VisualSkin);
      //OutPkt.AddUInt8(Player.VisualFace);
      //OutPkt.AddUInt8(Player.VisualHairStyle);
      //OutPkt.AddUInt8(Player.VisualHairColor);
      //OutPkt.AddUInt8(Player.VisualFacialHair);

      //OutPkt.AddUInt8(Player.Level);
      OutPkt.AddUInt8(1);
      OutPkt.AddUInt32(Player.ZoneId);
      OutPkt.AddUInt32(Player.MapId);

      OutPkt.AddFloat(Player.X);
      OutPkt.AddFloat(Player.Y);
      OutPkt.AddFloat(Player.Z);

      OutPkt.AddUInt32(0);
      //OutPkt.AddUInt32(ExtractUInt32(Player, PLAYER_GUILDID));
      OutPkt.AddUInt32(1);

      OutPkt.AddUInt8(Player.Rested);
      OutPkt.AddUInt32(0); { Pet ID }
      OutPkt.AddUInt32(0); { Pet level }
      OutPkt.AddUInt32(0); { Pet family }

      for J := 0 to EQUIPMENT_SLOT_END + 1 do
      begin
        OutPkt.Jump(5);
        (*
        if Player.EquippedItems[J] <> 0 then
        begin
          DataCore.Items.LoadEntryInt(Player.EquippedItems[J], Item);
          if Item <> nil then
          begin
            DataCore.ItemTemplates.LoadEntryInt(Item.Entry, Temp);
            if Temp <> nil then
            begin
              OutPkt.AddUInt32(Temp.ModelId);
              OutPkt.AddUInt8(UInt8(Temp.InventoryType));
            end else OutPkt.Jump(5);
            DataCore.ItemTemplates.ReleaseEntry(Temp);
          end else OutPkt.Jump(5);
        end else OutPkt.Jump(5);
        *)
      end;
    end;

    SendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;
end;

procedure YGaSession.HandleCharLoginOpcode(InPkt: YNwClientPacket);
type
  PDayTime = ^YDayTime;
  YDayTime = record
    Hours: UInt32;
    Minutes: UInt32;
  end;

  function GetPackedTime: Longword;
  var
    TimeNow: YDayTime;
  begin
    TimeNow.Hours := DivModU(DateTimeToTimeStamp(Now).Time div 60000, 60, TimeNow.Minutes);
    Result := (TimeNow.Hours shl 6) + TimeNow.Minutes;
  end;
const
  WelcomeMsg =
    'Visit us at http://www.emupedia.com or http://yawe.mcheats.net!' + #13#10 +
    'Please report all errors you find to help us make this software better.' + #13#10 +
    'Before reporting errors check the changelog for working things.' + #13#10 +
    'We are open to discussions and suggestions on IRC, server irc.emupedia.com, channel #YAWE.';
  NiceDay =
    'Have a nice day!';
  SetPass =
    'Your account has been autocreated - it is a good idea to change your password.'+ #13#10 +
    'Use this command: .setpass "password" (without quotes)';
var
  GuidPtr: PObjectGuid;
  OutPkt: YNwServerPacket;
  MOTD, RealmName: string;
  Acc: IAccountEntry;
  Cinematic, I, BaseIndex: UInt32;
  LookupRes: ILookupResult;
begin
  { Get the GUID of the player to login }
  GuidPtr := InPkt.GetCurrentReadPtr;

  FActivePlayer.Free; { If not nil, then free }

  GameCore.CreateObject(otPlayer, FActivePlayer, True);
  FActivePlayer.Session := Self;
  FActivePlayer.GUIDLo := GuidPtr^.Longs[0];
  FActivePlayer.GUIDHi := GuidPtr^.Longs[1];
  FActivePlayer.LoadFromDataBase;

  { Now send all required data to this player }

  {$IFDEF WOW_TBC}
  OutPkt := YNwServerPacket.Initialize(CMSG_DUNGEON_DIFFICULTY);
  OutPkt.Jump(4);
  OutPkt.AddUInt8(1);
  OutPkt.Jump(7);
  SendPacket(OutPkt);

  OutPkt := YNwServerPacket.Initialize(SMSG_LOGIN_VERIFY_WORLD);
  OutPkt.Jump(20);
  SendPacket(OutPkt);
  {$ENDIF}

  OutPkt := YNwServerPacket.Initialize(SMSG_ACCOUNT_DATA_MD5);
  try
    {$IFNDEF WOW_TBC}
    OutPkt.Jump(80);
    {$ENDIF}
    {$IFDEF WOW_TBC}
    OutPkt.Jump(128);
    {$ENDIF}
    SendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;

  {$IFDEF WOW_TBC}
  OutPkt := YNwServerPacket.Initialize(SMSG_BROADCAST_MSG);
  OutPkt.AddUInt32(6);
  OutPkt.AddString(PatchNotesBroadcast);
  SendPacket(OutPkt);
  {$ENDIF}

  OutPkt := YNwServerPacket.Initialize(SMSG_SET_REST_START);
  try
    OutPkt.Jump(4);
    SendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;

  OutPkt := YNwServerPacket.Initialize(SMSG_BINDPOINTUPDATE);
  try
    OutPkt.AddStruct(FActivePlayer.Vector, 12); { Ignore orientation }
    OutPkt.AddUInt32(FActivePlayer.MapId);
    OutPkt.AddUInt32(FActivePlayer.ZoneId);
    SendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;

  OutPkt := YNwServerPacket.Initialize(SMSG_INITIAL_SPELLS);
  try
    OutPkt.AddUInt8(0);
    OutPkt.AddUInt16(0);
    SendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;

  OutPkt := YNwServerPacket.Initialize(SMSG_LOGIN_SETTIMESPEED);
  try
    OutPkt.AddUInt32(GetPackedTime);
    OutPkt.AddFloat(0.017);
    SendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;

  OutPkt := YNwServerPacket.Initialize(SMSG_INITIALIZE_FACTIONS);
  try
    OutPkt.AddUInt32($40);
    //for iX := 1 to 64 do begin cOutPkt.AddUInt8(0); cOutPkt.AddUInt32(0); end;
    OutPkt.Jump(320);
    SendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;

  // Tutorials

  FActivePlayer.TutSendTutorialsStatus;

  //CINEMATIC implementation
   
  if FActivePlayer.Stats.Level = 0 then
  begin
    FActivePlayer.Stats.Level := 1;
    FActivePlayer.SetUInt32(PLAYER_XP, 0);
    FActivePlayer.SetUInt32(PLAYER_NEXT_LEVEL_XP, 400);
    FActivePlayer.SetUInt8(PLAYER_BYTES_3, 0, UInt8(FActivePlayer.Stats.Gender));
    { This is set not to display that faction bar}

    Cinematic := GetCinematicByRace(FActivePlayer.Stats.Race);
    if Cinematic <> 0 then
    begin
      OutPkt := YNwServerPacket.Initialize(SMSG_TRIGGER_CINEMATIC);
      try
        OutPkt.AddUInt32(Cinematic);
        SendPacket(OutPkt);
      finally
        OutPkt.Free;
      end;
    end;
    FActivePlayer.SaveToDatabase;
  end;

  { Plug player into world }
  FActivePlayer.ChangeWorldState(wscAdd);
  MOTD := SysConf.ReadStringN('Realm', 'MOTD', 'Welcome!');
  RealmName := SysConf.ReadStringN('Realm', 'Name', 'Custom Realm');

  if RealmName = '' then RealmName := 'Unknown Realm name';
  FActivePlayer.InRealmName := RealmName;

  if MOTD = '' then MOTD := '{$VER}';
  MOTD := StringReplace(MOTD, '{$VER}', ProgramVersion, [rfReplaceAll]);
  MOTD := StringReplace(MOTD, '{$RLM}', RealmName, [rfReplaceAll]);

  FActivePlayer.SendSystemMessage(MOTD);
  FActivePlayer.SendSystemMessageColored(WelcomeMsg, MSG_COLOR_LIME);
  FActivePlayer.SendSystemMessageColored(NiceDay, MSG_COLOR_CORAL);

  { Player has just autocreated this account, ask him to change his password }
  DataCore.Accounts.LookupEntryListW('Name', FAccountName, False, LookupRes);
  try
    if Assigned(LookupRes) and (LookupRes.GetData(Acc, 1) <> 0) and Acc.AutoCreated then
    begin
      FActivePlayer.SendSystemMessageColored(SetPass, MSG_COLOR_WHITE);
    end;
  finally
    DataCore.Accounts.ReleaseEntry(Acc);
  end;

  //FActivePlayer.ActionBtns.SendActionButtons;

  {
  for I := 0 to QUEST_LOG_COUNT - 1 do
  begin
    with FActivePlayer.Quests.ActiveQuests do
    begin
      BaseIndex := PLAYER_QUEST_LOG_1_1 + I * 3;
      FActivePlayer.SetUInt32(BaseIndex, Quests[I].Id);
      FActivePlayer.SetUInt32(BaseIndex + 1, Quests[I].KillObjectives[0]);
      FActivePlayer.SetUInt32(BaseIndex + 2, Quests[I].KillObjectives[1]);
    end;
  end;
  }

  {$IFDEF EXPERIMENTAL}
  OutPkt := YNwServerPacket.Initialize(SMSG_MOVE_UNLOCK_MOVEMENT);
  OutPkt.JumpUInt32;
  SendPacket(OutPkt);


  FActivePlayer.SendRootValue(PLAYER_MOVEMENT_UNLOCKED);
  FActivePlayer.SendUnroot();
  {$ENDIF}
end;

function YGaSession.CheckCharValidity(const Name: WideString; PlayerClass: YGameClass;
  PlayerRace: YGameRace): Boolean;
var
  EntryList: array of IPlayerEntry;
  C: Int32;
  CCount: Int32;
  CRace: YGameRace;
  Plr: IPlayerEntry;
  LookupRes: ILookupResult;
label
  __Exit;
begin
  Result := False;

  if Name = '' then
  begin
    SendCharOperationCode(CHAR_HAS_NO_NAME);
    Exit;
  end;

  if Length(Name) < 2 then
  begin
    SendCharOperationCode(CHAR_AT_LEAST_2);
    Exit;
  end;

  if Length(Name) > 12 then
  begin
    SendCharOperationCode(CHAR_AT_MOST_12);
    Exit;
  end;

  for C := 1 to Length(Name) do
  begin
    if not (Name[C] in ['A'..'Z', 'a'..'z']) then
    begin
      SendCharOperationCode(CHAR_ONLY_LETTERS);
      Exit;
    end;
  end;

  if UpperCase(SysConf.ReadStringN('Realm', 'Type')) = 'PVP' then
  begin
    { This is a PvP realm! Let's see if the user has an account of a different faction }
    DataCore.Players.LookupEntryListW('AccountName', FAccountName,
      False, LookupRes);
    try
      if Assigned(LookupRes) then
      begin
        SetLength(EntryList, LookupRes.EntryCount);
        LookupRes.GetData(EntryList[0], Length(EntryList));
      end;
      
      for C := 0 to Length(EntryList) - 1 do
      begin
        { Extracting the Race from Update Data }
        Plr := EntryList[C];
        //CRace := Plr.GameRace;
        CRace := grHuman;
        { ... }
  
        if FactionDiffers(CRace, PlayerRace) then
        begin
          SendCharOperationCode(CHAR_PVP_SERVER);
          Exit;
        end;
      end;
    finally
      DataCore.Players.ReleaseEntries(EntryList[0], Length(EntryList));
    end;
  end;

  //iCCount := DataCore.Players.CountEntries(FIELD_PLI_CHAR_NAME, Name);
  CCount := 0;

  if CCount > 0 then
  begin
    SendCharOperationCode(CHAR_EXISTS);
    Exit;
  end;

  //iCCount := DataCore.Players.CountEntries(FIELD_PLI_ACCOUNT_NAME, fAccount);
  if CCount >= SysConf.ReadIntegerN('Realm', 'MaxChars') then
  begin
    SendCharOperationCode(CHAR_FULL_LIST);
    Exit;
  end;

  if DataCore.ProfanityList.IndexOf(Name) <> -1 then
  begin
    SendCharOperationCode(CHAR_PROFANITY);
    Exit;
  end else if DataCore.ReservedNameList.IndexOf(Name) <> -1 then
  begin
    SendCharOperationCode(CHAR_NAME_UNAVAILABLE);
    Exit;
  end;

  Result := True;
end;

procedure YGaSession.SendCharOperationCode(Error: UInt8);
var
  OutPkt: YNwServerPacket;
begin
  OutPkt := YNwServerPacket.Initialize(SMSG_CHAR_CREATE);
  try
    OutPkt.AddUInt8(Error);
    SendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;
end;

procedure YGaSession.HandleNameQuery(InPkt: YNwClientPacket);
var
  GuidPtr: PObjectGuid;
  PlayerDbEntry: IPlayerEntry;
  Value: Longword;
  OutPkt: YNwServerPacket;
begin
  GuidPtr := InPkt.GetCurrentReadPtr;

  DataCore.Players.LookupEntry(GuidPtr^.Longs[0], PlayerDbEntry);
  try
    OutPkt := YNwServerPacket.Initialize(SMSG_NAME_QUERY_RESPONSE);
    try
      OutPkt.AddPtrData(GuidPtr, 8);
      if PlayerDbEntry <> nil then
      begin
        OutPkt.AddString(PlayerDbEntry.Name);

        if FActivePlayer.InBattleGround then
        begin
          OutPkt.AddString(FActivePlayer.InRealmName);
        end else
        begin
          OutPkt.JumpUInt8;
        end;

        //Value := PlayerDbEntry.UpdateData[UNIT_FIELD_BYTES_0];
        //OutPkt.AddUInt8(LongRec(Value).Bytes[BYTE_RACE]);
        //OutPkt.AddUInt8(LongRec(Value).Bytes[BYTE_GENDER]);
        //OutPkt.AddUInt8(LongRec(Value).Bytes[BYTE_CLASS]);
      end else
      begin
        OutPkt.AddString('Unknown Player');
        OutPkt.JumpUInt32;      //last byte is to send null realm name (1.12.X+ only)
      end;

      SendPacket(OutPkt);
    finally
      OutPkt.Free;
    end;
  finally
    DataCore.Players.ReleaseEntry(PlayerDbEntry);
  end;
end;

procedure YGaSession.HandleNoAction(InPkt: YNwClientPacket);
begin
  // it's just flood :) God damnit!
end;

procedure YGaSession.HandleItemNameQuery(InPkt: YNwClientPacket);
var
  ItemId: UInt32;
  OutPkt: YNwServerPacket;
  ItemTempDbEntry: IItemTemplateEntry;
begin
  ItemId := InPkt.ReadUInt32;

  DataCore.ItemTemplates.LookupEntry(ItemId, ItemTempDbEntry);
  try
    OutPkt := YNwServerPacket.Initialize(SMSG_ITEM_NAME_QUERY_RESPONSE);
    try
      if not Assigned(ItemTempDbEntry) then
      begin
        OutPkt.AddString(Format('Unknown Item - ID %d', [ItemId]));
        SendPacket(OutPkt);
        Exit;
      end;
  
      if ItemTempDbEntry.Name = '' then
      begin
        OutPkt.AddString(Format('Unknown Item - ID %d', [ItemId]))
      end else
      begin
        OutPkt.AddString(ItemTempDbEntry.Name);
      end;
  
      SendPacket(OutPkt);
    finally
      OutPkt.Free;
    end;
  finally
    DataCore.ItemTemplates.ReleaseEntry(ItemTempDbEntry);
  end;
end;

procedure YGaSession.HandleCreatureQuery(InPkt: YNwClientPacket);
var
  OutPkt: YNwServerPacket;
  CreatureTempDbEntry: YDbCreatureTemplate;
  EntryId: UInt32;
begin
  EntryId := InPkt.ReadUInt32;

  DataCore.CreatureTemplates.LookupEntry(EntryId, CreatureTempDbEntry);
  try
    OutPkt := YNwServerPacket.Initialize(SMSG_CREATURE_QUERY_RESPONSE);
    try
      OutPkt.AddUInt32(EntryId);
  
      if CreatureTempDbEntry <> nil then
      begin
        OutPkt.AddString(CreatureTempDbEntry.EntryName);
        OutPkt.Jump(3);
        OutPkt.AddUInt32(CreatureTempDbEntry.UnitFlags);
        OutPkt.AddUInt32(CreatureTempDbEntry.UnitType);
        OutPkt.AddUInt32(CreatureTempDbEntry.Family);
        OutPkt.AddUInt32(CreatureTempDbEntry.Rank);
        OutPkt.Jump(8);
        OutPkt.AddUInt32(CreatureTempDbEntry.ModelID);
        OutPkt.AddUInt32(CreatureTempDbEntry.Civilian);
        OutPkt.Jump(4);
      end else
      begin
        OutPkt.AddString('Unknown entity');
        OutPkt.Jump(39);
      end;
      SendPacket(OutPkt);
    finally
      OutPkt.Free;
    end;
  finally
    DataCore.CreatureTemplates.ReleaseEntry(CreatureTempDbEntry);
  end;
end;

procedure YGaSession.HandleSheathedOpcode(InPkt: YNwClientPacket);
var
  Sheathed: UInt32;
begin
  Sheathed := InPkt.ReadUInt32;

  case Sheathed of
    SHEATH_MAIN:
    begin
      FActivePlayer.ReSetBit(UNIT_FIELD_BYTES_2, UFB2_SHEATH_RANGED_WEAPONS);
      FActivePlayer.SetBit(UNIT_FIELD_BYTES_2, UFB2_SHEATH_MAIN_WEAPONS);
    end;

    SHEATH_RANGED:
    begin
      FActivePlayer.ReSetBit(UNIT_FIELD_BYTES_2, UFB2_SHEATH_MAIN_WEAPONS);
      FActivePlayer.SetBit(UNIT_FIELD_BYTES_2, UFB2_SHEATH_RANGED_WEAPONS);
    end;

    SHEATH_NONE:
    begin
      FActivePlayer.ReSetBit(UNIT_FIELD_BYTES_2, UFB2_SHEATH_RANGED_WEAPONS);
      FActivePlayer.ReSetBit(UNIT_FIELD_BYTES_2, UFB2_SHEATH_MAIN_WEAPONS);
    end;

    else
      begin
        FActivePlayer.SendSystemMessage(Format('Unknown Sheath code : %d', [Sheathed]));
        //Assert(False, 'UNKNOWN Sheath code. Please inform developers');
      end;
  end;  
end;

procedure YGaSession.HandleItemQuerySingle(InPkt: YNwClientPacket);
var
  EntryId: UInt32;
  OutPkt: YNwServerPacket;
  ItemTempDbEntry: IItemTemplateEntry;
  P: Pointer;
begin
  EntryId := InPkt.ReadUInt32;
  OutPkt := YNwServerPacket.Initialize(SMSG_ITEM_QUERY_SINGLE_RESPONSE);
  try
    DataCore.ItemTemplates.LookupEntry(EntryId, ItemTempDbEntry);
    try
      if ItemTempDbEntry <> nil then
      begin
        P := OutPkt.GetWritePtrOfSize(ItemTempDbEntry.GetInfoBufferRequiredSize);
        ItemTempDbEntry.FillInfoBuffer(P);
      end else
      begin
        OutPkt.AddUInt32(EntryId);
        OutPkt.Jump(456);
        IoCore.Console.WriteMultiple(['Item query failed - entry ', IntToStr(EntryId), ' is not declared'],
          [CLR_ATTENTION, CLR_INFO, CLR_ATTENTION]);
      end;

      SendPacket(OutPkt);
    finally
      DataCore.ItemTemplates.ReleaseEntry(ItemTempDbEntry);
    end;
  finally
    OutPkt.Free;
  end;
end;

procedure YGaSession.HandleTimeQuery(InPkt: YNwClientPacket);
var
  OutPkt: YNwServerPacket;
begin
  OutPkt := YNwServerPacket.Initialize(SMSG_QUERY_TIME_RESPONSE);
  try
    OutPkt.AddUInt32(TimeGetTime);
    SendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;
end;

procedure YGaSession.HandleNextMailTimeQuery(InPkt: YNwClientPacket);
var
  OutPkt: YNwServerPacket;
begin
  { Add mail support in the future }
  OutPkt := YNwServerPacket.Initialize(MSG_QUERY_NEXT_MAIL_TIME);
  try
    //if fLoggedInPlayer.Mail.HasMail then
    //begin
      //cOutPkt.Jump(4);
    //end else
    //begin
      OutPkt.AddUInt32($C7A8C000);
    //end;
    SendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;
end;

procedure YGaSession.TutorialManipulation(InPkt: YNwClientPacket);
var
  Index: UInt32;
begin
  case InPkt.Header^.Opcode of
    CMSG_TUTORIAL_FLAG:
    begin
      Index := InPkt.ReadUInt32;
      FActivePlayer.Tutorials[Index] := True;
    end;
    CMSG_TUTORIAL_CLEAR: FActivePlayer.TutMarkReadAllTutorials;
    CMSG_TUTORIAL_RESET: FActivePlayer.TutMarkUnreadAllTutorials;
  end;
end;

procedure YGaSession.BufferLockAcquire;
begin
  FSocket.QueueLockAcquire;
end;

procedure YGaSession.BufferLockRelease;
begin
  FSocket.QueueLockRelease;
end;

procedure YGaSession.ChatManipulation(InPkt: YNwClientPacket);
const
  Range: array[0..8] of Float = (12.5, 0, 0, 0, 0, 25.0, 0, 0, 25.0);
var
  iType, iLanguage: UInt32;
  iLen: Int32;
  sMessage: string;
  sChannel: string;
  cChannel: YGaChannel;
  sPlayerName: string;
  cPlayer: YGaPlayer;
  cOutPkt: YNwServerPacket;
begin
  iType := InPkt.ReadUInt32;
  iLanguage := InPkt.ReadUInt32;
  case iType of
    CHAT_MSG_SAY, CHAT_MSG_YELL:
    begin
      sMessage := InPkt.ReadString;
      iLen := Length(sMessage);

      if iLen > 1 then
      begin
        { The message must contain at least 2 chars to be considered a command }
        if Components.GameCore.CommandHandler.YGaChatCommands.ProcessChatCommand(FActivePlayer, sMessage) then
        begin
          Exit; { It was a command and it was processed }
        end;
      end;

      FActivePlayer.SendMessageDispatchedInRange(iType, glUniversal, sMessage, '', Range[iType], True);
      //TODO change LANG_UNIVERSAL in iLanguage when the time comes as know the skills are not forking
      //for decoding the messages.
    end;
    CHAT_MSG_CHANNEL:
    begin
      sChannel := InPkt.ReadString;
      sMessage := InPkt.ReadString;
      cChannel := GameCore.GetChannelByName(FActivePlayer, sChannel);
      if cChannel <> nil then
      begin
        cChannel.Say(FActivePlayer, sMessage);
      end else FActivePlayer.SendSystemMessage('Channel "' + sChannel + '" does not exist.');
    end;
    CHAT_MSG_WHISPER:
    begin
      sPlayerName := InPkt.ReadString;
      if StringsEqualNoCase(sPlayerName, FActivePlayer.Name) then
      begin
        FActivePlayer.SendSystemMessage('You cannot whisper to yourself.');
      end else
      begin
        sMessage := InPkt.ReadString;
        case GameCore.FindPlayerByName(sPlayerName, cPlayer) of
          { A char with the specified name does not exist }
          lrNonExistant: FActivePlayer.SendSystemMessage('Player ' + sPlayerName + ' does not exist.');
          { The char exists, but he is not currently online }
          lrOffline: FActivePlayer.SendSystemMessage('Player ' + sPlayerName + ' is currently not online.');
          { The char is currently in the game so he may receive messages }
          lrOnline:
          begin
            iLen := Length(sMessage);
            
            cOutPkt := BuildChatPacket(FActivePlayer, CHAT_MSG_WHISPER, glUniversal,
              Pointer(sMessage), iLen);
            try
              cPlayer.SendPacket(cOutPkt);
            finally
              cOutPkt.Free;
            end;

            cOutPkt := BuildChatPacket(cPlayer, CHAT_MSG_WHISPER_INFORM, glUniversal,
              Pointer(sMessage), iLen);
            try
              SendPacket(cOutPkt);
            finally
              cOutPkt.Free;
            end;
          end;
        end;
      end;
    end;
    CHAT_MSG_EMOTE:
    begin
      sMessage := InPkt.ReadString;
      FActivePlayer.SendMessageDispatchedInRange(iType, glUniversal, sMessage, '', Range[iType], True);
    end;
  end;
end;

procedure YGaSession.HandleChannelJoin(InPkt: YNwClientPacket);
var
  ChanName, ChanPass: string;
begin
  ChanName := InPkt.ReadString;
  ChanPass := InPkt.ReadString;

  GameCore.TryJoinChannel(FActivePlayer, ChanName, ChanPass);
end;

procedure YGaSession.HandleChannelLeave(InPkt: YNwClientPacket);
var
  ChanName: string;
begin
  ChanName := InPkt.ReadString;

  GameCore.LeaveChannel(FActivePlayer, ChanName);
end;

procedure YGaSession.HandleChannelListRequest(InPkt: YNwClientPacket);
var
  ChanName: string;
  Channel: YGaChannel;
begin
  ChanName := InPkt.ReadString;
  Channel := GameCore.GetChannelByName(FActivePlayer, ChanName);
  if Channel <> nil then
  begin
    Channel.ListRequest(FActivePlayer);
  end;
end;

procedure YGaSession.HandleChannelPasswordSet(InPkt: YNwClientPacket);
var
  ChanName: string;
  ChanPass: string;
  Channel: YGaChannel;
begin
  ChanName := InPkt.ReadString;
  ChanPass := InPkt.ReadString;

  Channel := GameCore.GetChannelByName(FActivePlayer, ChanName);
  if Channel <> nil then
  begin
    Channel.ChangePassword(FActivePlayer, ChanPass);
  end;
end;

procedure YGaSession.HandleChannelOwnerSet(InPkt: YNwClientPacket);
var
  ChanName: string;
  PlayerName: string;
  Channel: YGaChannel;
begin
  ChanName := InPkt.ReadString;
  PlayerName := InPkt.ReadString;

  Channel := GameCore.GetChannelByName(FActivePlayer, ChanName);
  if Channel <> nil then
  begin
    Channel.ChangeOwner(FActivePlayer, PlayerName);
  end;
end;

procedure YGaSession.HandleChannelOwnerGet(InPkt: YNwClientPacket);
var
  ChanName: string;
  Channel: YGaChannel;
begin
  ChanName := InPkt.ReadString;

  Channel := GameCore.GetChannelByName(FActivePlayer, ChanName);
  if Channel <> nil then
  begin
    Channel.QueryOwner(FActivePlayer);
  end;
end;

procedure YGaSession.HandleChannelPromote(InPkt: YNwClientPacket);
var
  ChanName: string;
  PlayerName: string;
  Channel: YGaChannel;
begin
  ChanName := InPkt.ReadString;
  PlayerName := InPkt.ReadString;

  Channel := GameCore.GetChannelByName(FActivePlayer, ChanName);
  if Channel <> nil then
  begin
    Channel.ChangeModerateRight(FActivePlayer, PlayerName, True);
  end;
end;

procedure YGaSession.HandleChannelDepromote(InPkt: YNwClientPacket);
var
  ChanName: string;
  PlayerName: string;
  Channel: YGaChannel;
begin
  ChanName := InPkt.ReadString;
  PlayerName := InPkt.ReadString;

  Channel := GameCore.GetChannelByName(FActivePlayer, ChanName);
  if Channel <> nil then
  begin
    Channel.ChangeModerateRight(FActivePlayer, PlayerName, False);
  end;
end;

procedure YGaSession.HandleChannelMute(InPkt: YNwClientPacket);
var
  ChanName: string;
  PlayerName: string;
  Channel: YGaChannel;
begin
  ChanName := InPkt.ReadString;
  PlayerName := InPkt.ReadString;

  Channel := GameCore.GetChannelByName(FActivePlayer, ChanName);
  if Channel <> nil then
  begin
    Channel.ChangeMutedRight(FActivePlayer, PlayerName, True);
  end;
end;

procedure YGaSession.HandleChannelUnmute(InPkt: YNwClientPacket);
var
  ChanName: string;
  ChanPlayer: string;
  Channel: YGaChannel;
begin
  ChanName := InPkt.ReadString;
  ChanPlayer := InPkt.ReadString;

  Channel := GameCore.GetChannelByName(FActivePlayer, ChanName);
  if Channel <> nil then
  begin
    Channel.ChangeMutedRight(FActivePlayer, ChanPlayer, False);
  end;
end;

procedure YGaSession.HandleChannelSendInvitiation(InPkt: YNwClientPacket);
var
  ChanName: string;
  PlayerName: string;
  Channel: YGaChannel;
begin
  ChanName := InPkt.ReadString;
  PlayerName := InPkt.ReadString;

  Channel := GameCore.GetChannelByName(FActivePlayer, ChanName);
  if Channel <> nil then
  begin
    Channel.SendInvitation(FActivePlayer, PlayerName);
  end;
end;

procedure YGaSession.HandleChannelKick(InPkt: YNwClientPacket);
var
  ChanName: string;
  PlayerName: string;
  Channel: YGaChannel;
begin
  ChanName := InPkt.ReadString;
  PlayerName := InPkt.ReadString;

  Channel := GameCore.GetChannelByName(FActivePlayer, ChanName);
  if Channel <> nil then
  begin
    Channel.Kick(FActivePlayer, PlayerName);
  end;
end;

procedure YGaSession.HandleChannelBan(InPkt: YNwClientPacket);
var
  ChanName: string;
  PlayerName: string;
  Channel: YGaChannel;
begin
  ChanName := InPkt.ReadString;
  PlayerName := InPkt.ReadString;

  Channel := GameCore.GetChannelByName(FActivePlayer, ChanName);
  if Channel <> nil then
  begin
    Channel.ChangeBanRight(FActivePlayer, PlayerName, True);
  end;
end;

procedure YGaSession.HandleChannelUnban(InPkt: YNwClientPacket);
var
  ChanName: string;
  PlayerName: string;
  Channel: YGaChannel;
begin
  ChanName := InPkt.ReadString;
  PlayerName := InPkt.ReadString;

  Channel := GameCore.GetChannelByName(FActivePlayer, ChanName);
  if Channel <> nil then
  begin
    Channel.ChangeBanRight(FActivePlayer, PlayerName, False);
  end;
end;

procedure YGaSession.HandleChannelToggleAnnounce(InPkt: YNwClientPacket);
var
  ChanName: string;
  Channel: YGaChannel;
begin
  ChanName := InPkt.ReadString;

  Channel := GameCore.GetChannelByName(FActivePlayer, ChanName);
  if Channel <> nil then
  begin
    Channel.ChangeChannelFlag(FActivePlayer, cfAnnounce, not Channel.IsAnnounce);
  end;
end;

procedure YGaSession.HandleChannelToggleModerated(InPkt: YNwClientPacket);
var
  ChanName: string;
  Channel: YGaChannel;
begin
  ChanName := InPkt.ReadString;
  
  Channel := GameCore.GetChannelByName(FActivePlayer, ChanName);
  if Channel <> nil then
  begin
    Channel.ChangeChannelFlag(FActivePlayer, cfModerated, not Channel.IsModerated);
  end;
end;

type
  PMovementData = ^YMovementData;
  YMovementData = record
    Flags: UInt32;
    Time: UInt32;
    X: Float;
    Y: Float;
    Z: Float;
    Angle: Float;
    case Byte of
      0: (
        GUID: YObjectGuid;
        OffX: Float;
        OffY: Float;
        OffZ: Float;
        OffAngle: Float;
      );
      1: (
        FallTime: UInt32;
        FallUnk: Float;
        FallOffX: Float;
        FallOffY: Float;
        FallOffSpeed: Float;
      );
  end;

procedure YGaSession.HandleMovement(InPkt: YNwClientPacket);
const
  MOVE_FLAG_STOP       = $00000000;
  MOVE_FLAG_FORWARD    = $00000001;
  MOVE_FLAG_BACKWARD   = $00000002;
  MOVE_FLAG_TURN_LEFT  = $00000010;
  MOVE_FLAG_TURN_RIGHT = $00000020;
  MOVE_FLAG_TRANSPORT  = $00000200;
  MOVE_FLAG_JUMP       = $00002000;
  MOVE_FLAG_FALL       = $00004000;
  MOVE_FLAG_SWIM       = $00200000;
  MOVE_FLAG_UNK        = $04000000;
var
  MoveData: PMovementData;
  OutPkt: YNwServerPacket;
  OutPkt2: YNwServerPacket;
  DmgAmount: UInt32;
  Vec: TVector;
begin
  MoveData := InPkt.GetCurrentReadPtr;

  if (MoveData^.Flags and MOVE_FLAG_FALL) <> 0 then
  begin
    if (FActivePlayer.Stats.Health > 0) and (MoveData^.FallTime >= 2000) then
    begin
      { The fall time of 1000 (ms) correspondents to 1.0 sec of falling - that's not much
        but it's a good number for testing purposes. }
      DmgAmount := ((MoveData^.FallTime - 2000) div 100) + 1;
      OutPkt2 := YNwServerPacket.Initialize(SMSG_ENVIRONMENTALDAMAGELOG);
      try
        OutPkt2.AddPtrData(FActivePlayer.GUID, 8);
        OutPkt2.AddUInt8(2);
        OutPkt2.AddUInt32(DmgAmount);
        OutPkt2.Skip(8);
        SendPacket(OutPkt2);
      finally
        OutPkt2.Free;
      end;
    
      if FActivePlayer.Stats.ArmorResist < DmgAmount then    //TODO - it's a test. I hope I will remember to remove it :)
        FActivePlayer.Stats.Health := FActivePlayer.Stats.Health - DmgAmount;
    end;
  end;

  OutPkt := YNwServerPacket.Initialize(InPkt.Header^.Opcode, 9 + InPkt.Size);
  try
    OutPkt.AddPackedGUID(FActivePlayer.GUID);
    OutPkt.AddPtrData(MoveData, InPkt.Size);

    MakeVector(Vec, MoveData^.X, MoveData^.Y, MoveData^.Z);
    GameCore.CheckObjectRellocation(FActivePlayer, Vec, MoveData^.Angle, OutPkt);
  finally
    OutPkt.Free;
  end;

  { TODO -oTheSelby -cMovement : Add water and terain checks, stuff like that... lava checks, etc (when the time for that comes) }
end;

//procedure YOpenSession.HandleMoveTimeSkipped(cPkt: YClientPacket);
//begin
//  Writeln(cPkt.ReadUInt32);
//end;

procedure YGaSession.LogoutManipulation(InPkt: YNwClientPacket);
var
  OutPkt: YNwServerPacket;
begin
  case InPkt.Header^.Opcode of
    CMSG_LOGOUT_REQUEST:
    begin
      FLogoutTimerHandle := SysEventMgr.RegisterEvent(SessionLogOut, 20000,
        TICK_EXECUTE_ONCE, 'GaSession_SessionLogoutRequestTimer');

      FActivePlayer.OrUInt32(UNIT_FIELD_BYTES_1, UNIT_STATE_SIT);
      FActivePlayer.OrUInt32(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_ROOTED);

      OutPkt := YNwServerPacket.Initialize(SMSG_LOGOUT_RESPONSE);
      try
        OutPkt.Jump(5);
        SendPacket(OutPkt);
      finally
        OutPkt.Free;
      end;

      OutPkt := YNwServerPacket.Initialize(SMSG_FORCE_MOVE_ROOT);
      try
        OutPkt.AddPackedGUID(FActivePlayer.GUID);
        OutPkt.AddUInt32(2);
        SendPacket(OutPkt);
      finally
        OutPkt.Free;
      end;
    end;
    CMSG_LOGOUT_CANCEL:
    begin
      if FLogoutTimerHandle <> nil then
      begin
        FLogoutTimerHandle.Unregister;
        FLogoutTimerHandle := nil;

        FActivePlayer.ReplaceUInt32(UNIT_FIELD_BYTES_1, UNIT_STATE_SIT, UNIT_STATE_STAND);
        FActivePlayer.AndNotUInt32(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_ROOTED);

        OutPkt := YNwServerPacket.Initialize(SMSG_FORCE_MOVE_UNROOT);
        try
          OutPkt.AddPackedGUID(FActivePlayer.GUID);
          SendPacket(OutPkt);
        finally
          OutPkt.Free;
        end;

        OutPkt := YNwServerPacket.Initialize(SMSG_LOGOUT_CANCEL_ACK);
        try
          SendPacket(OutPkt);
        finally
          OutPkt.Free;
        end;
      end;
    end;
  end;
end;

procedure YGaSession.HandleStandStateChange(InPkt: YNwClientPacket);
var
  Temp: Longword;
begin
  with FActivePlayer do
  begin
    Temp := GetUInt32(UNIT_FIELD_BYTES_1);
    LongRec(Temp).Bytes[0] := 0;
    SetUInt32(UNIT_FIELD_BYTES_1, Temp or Longword(InPkt.ReadUInt8));
  end;
end;

procedure YGaSession.HandleSetSelection(InPkt: YNwClientPacket);
var
  GuidPtr: PObjectGUID;
begin
  GuidPtr := InPkt.GetCurrentReadPtr;
  FActivePlayer.SetUInt64(UNIT_FIELD_TARGET, GuidPtr^.Full);
end;

  {$REGION 'Items handlers'}
procedure YGaSession.HandleSwapInvItem(InPkt: YNwClientPacket);
var
  iSlotSrc, iSlotDest: UInt8;
begin
  iSlotSrc := InPkt.ReadUInt8;
  iSlotDest := InPkt.ReadUInt8;
  FActivePlayer.EqpInventoryChange(iSlotSrc, iSlotDest);
end;

procedure YGaSession.HandleSwapItem(InPkt: YNwClientPacket);
var
  iSlotSrc, iSlotDest, iBagSrc, iBagDest: UInt8;
begin
  iBagDest := InPkt.ReadUInt8;
  iSlotDest := InPkt.ReadUInt8;
  iBagSrc := InPkt.ReadUInt8;
  iSlotSrc := InPkt.ReadUInt8;
  FActivePlayer.EqpInventoryChange(iSlotSrc, iSlotDest, iBagSrc, iBagDest);
end;

procedure YGaSession.HandleAutoEquipItem(InPkt: YNwClientPacket);
var
  iBagSrc, iSlotSrc: UInt8;
begin
  iBagSrc := InPkt.ReadUInt8;
  iSlotSrc := InPkt.ReadUInt8;
  FActivePlayer.EqpTryEquipItem(iSlotSrc, iBagSrc);
end;

procedure YGaSession.HandleAutoStoreBagItem(InPkt: YNwClientPacket);
var
  iBagSrc, iSlotSrc, iBagDest: UInt8;
begin
  iBagSrc := InPkt.ReadUInt8;
  iSlotSrc := InPkt.ReadUInt8;
  iBagDest := InPkt.ReadUInt8;
  FActivePlayer.EqpAutoStoreItem(iBagSrc, iSlotSrc, iBagDest);
end;

procedure YGaSession.HandleSetAmmo(InPkt: YNwClientPacket);
var
  iAmmo: UInt32;
begin
  iAmmo := InPkt.ReadUInt32;
  FActivePlayer.SetUInt32(PLAYER_AMMO_ID, iAmmo);
end;

procedure YGaSession.HandleSplitItem(InPkt: YNwClientPacket);
var
  iBagSrc, iSlotSrc, iBagDest, iSlotDest, iCount: UInt8;
begin
  iBagSrc := InPkt.ReadUInt8;
  iSlotSrc := InPkt.ReadUInt8;
  iBagDest := InPkt.ReadUInt8;
  iSlotDest := InPkt.ReadUInt8;
  iCount := InPkt.ReadUInt8;
  FActivePlayer.EqpSplitItems(iBagSrc, iSlotSrc, iBagDest, iSlotDest, iCount);
  {TODO 1 -oBIGBOSS -cItems : Send error if SplitCount>ItemCount etc}
end;

procedure YGaSession.HandleUseItem(InPkt: YNwClientPacket);
var
  iBag, iSlot: UInt8;
begin
  iBag := InPkt.ReadUInt8;
  iSlot := InPkt.ReadUInt8;
  FActivePlayer.SendSystemMessage('Item on slot '+IntToStr(iSlot)+'(Bag '+IntToStr(iBag)+') was used');
end;

procedure YGaSession.HandleDestroyItem(InPkt: YNwClientPacket);
var
  iBag, iSlot: UInt8;
begin
  iBag := InPkt.ReadUInt8;
  iSlot := InPkt.ReadUInt8;
  FActivePlayer.EqpDeleteItem(iBag, iSlot, True);
end;

{$ENDREGION}

procedure YGaSession.HandleMoveWorldPortACK(InPkt: YNwClientPacket);
begin
  FActivePlayer.ChangeWorldState(wscEnter);
end;

procedure SendTradeStatus(cPlayer: YGaPlayer; iTradeStatus: UInt8);
var
  OutPkt: YNwServerPacket;
begin
  if cPlayer.TrdTrader = nil then Exit;

  OutPkt := YNwServerPacket.Initialize(SMSG_TRADE_STATUS);
  try
    OutPkt.AddUInt32(iTradeStatus);
    cPlayer.Session.SendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;
end;

procedure UpdateTrade(cPlayer: YGaPlayer);
var
  OutPkt: YNwServerPacket;
  I: Integer;
begin
  if cPlayer.TrdTrader = nil then Exit;

  OutPkt := YNwServerPacket.Initialize(SMSG_TRADE_STATUS_EXTENDED);
  try
    OutPkt.AddUInt8(1);   //??
    OutPkt.AddUInt32(7);  //??
    OutPkt.Jump(4);       //??
    OutPkt.AddUInt32(cPlayer.TrdCopper);
    OutPkt.Jump(4);       //??
    for I := 0 to 7 do with cPlayer.TrdItems[I] do
    begin
      OutPkt.AddUInt8(I);
      if iEntry <> MaxDword then
      begin
        OutPkt.AddUInt32(iEntry);
        OutPkt.Jump(4);   //??
        OutPkt.AddUInt32(iStackCount);
      end else
      begin
        OutPkt.Jump(12);  //??
      end;
      OutPkt.Jump(48);    //??
    end;
    cPlayer.TrdTrader.Session.SendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;
end;

procedure YGaSession.HandleInitiateTrade(InPkt: YNwClientPacket);
var
  OutPkt: YNwServerPacket;
  cOtherTrader: YGaPlayer;
begin
  
  { If you are dead }
  if FActivePlayer.Stats.Health = 0 then
  begin
    SendTradeStatus(FActivePlayer, TRADE_STATUS_YOU_DEAD);
    Exit;
  end;

  { Get the other trader }
  GameCore.FindObjectByGUID(otPlayer, InPkt.ReadUInt64, cOtherTrader);

  { If you try trading with yourself }
  if FActivePlayer = cOtherTrader then
    Exit;

  { If the other trader doesn't exist }
  if cOtherTrader = nil then
  begin
    SendTradeStatus(FActivePlayer, TRADE_STATUS_TRADER_NOT_FOUND);
    Exit;
  end;

  { If the other trader is busy }
  if cOtherTrader.TrdTrader <> nil then
  begin
    SendTradeStatus(FActivePlayer, TRADE_STATUS_BUSY);
    Exit;
  end;

  { If the other trader is dead }
  if cOtherTrader.Stats.Health = 0 then
  begin
    SendTradeStatus(FActivePlayer, TRADE_STATUS_TRADER_DEAD);
    Exit;
  end;

  { Initiate the trade and assign the traders together }
  FActivePlayer.TrdTrader := cOtherTrader;
  cOtherTrader.TrdTrader := FActivePlayer;

  { Sends the packet that say OK for trade }
  OutPkt := YNwServerPacket.Initialize(SMSG_TRADE_STATUS);
  try
    OutPkt.AddUInt32(TRADE_STATUS_OK);
    OutPkt.AddUInt64(FActivePlayer.GUIDLo);
    cOtherTrader.Session.SendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;
end;

procedure YGaSession.HandleBeginTrade(InPkt: YNwClientPacket);
begin
  if not Assigned(FActivePlayer.TrdTrader) then Exit;

  SendTradeStatus(FActivePlayer, TRADE_STATUS_BEGIN);
  SendTradeStatus(FActivePlayer.TrdTrader, TRADE_STATUS_BEGIN);
end;

procedure YGaSession.HandleAcceptTrade(InPkt: YNwClientPacket);
var
  iX, iTMP: Int32;
  cItem1, cItem2: YGaItem;
  cErrorPkt: YNwServerPacket;
  cOther: YGaPlayer;
begin
  if not Assigned(FActivePlayer.TrdTrader) then Exit;

  cOther := FActivePlayer.TrdTrader;
  FActivePlayer.TrdAccept := True;
  SendTradeStatus(FActivePlayer.TrdTrader, TRADE_STATUS_ACCEPT);

  { If both are ready, then let's trade! }
  if cOther.TrdAccept then
  begin
    {TODO 1 -oBIGBOSS -cItems : Send error if not enough space/money/bound etc}

    with FActivePlayer do
    begin
      iTMP := Money - TrdCopper + cOther.TrdCopper;
      if iTMP < 0 then
      begin
        Money := 0;
        Exit;
        //not enough
      end else
      begin
        Money := iTMP;
      end;
      iTMP := cOther.Money - cOther.TrdCopper + TrdCopper;
      if iTMP < 0 then
      begin
        cOther.Money := 0;
        Exit;
        //not enough
      end else
      begin
        cOther.Money := iTMP;
      end;
      SetUInt32(PLAYER_FIELD_COINAGE, Money);
      cOther.SetUInt32(PLAYER_FIELD_COINAGE, cOther.Money);
      for iX := 0 to 5 do
      begin
        if TrdItems[iX].iEntry <> MaxDword then
        begin
          cItem1 := EqpDeleteItem(TrdItems[iX].iBag, TrdItems[iX].iSlot, False);
        end else
          cItem1 := nil;
        if cOther.TrdItems[iX].iEntry <> MaxDword then
        begin
          cItem2 := cOther.EqpDeleteItem(cOther.TrdItems[iX].iBag, cOther.TrdItems[iX].iSlot, False);
        end else
          cItem2 := nil;
        if Assigned(cItem2) then
        begin
          if EqpAssignItem(cItem2) = INV_ERR_INVENTORY_FULL then
          begin
            cErrorPkt := YNwServerPacket.Initialize(SMSG_INVENTORY_CHANGE_FAILURE);
            try
              cErrorPkt.AddUInt8(INV_ERR_INVENTORY_FULL);
              cOther.Session.SendPacket(cErrorPkt);
              SendPacket(cErrorPkt);
            finally
              cErrorPkt.Free;
            end;
          end;
        end;
        if Assigned(cItem1) then
        begin
          if cOther.EqpAssignItem(cItem1) = INV_ERR_INVENTORY_FULL then
          begin
            cErrorPkt := YNwServerPacket.Initialize(SMSG_INVENTORY_CHANGE_FAILURE);
            try
              cErrorPkt.AddUInt8(INV_ERR_INVENTORY_FULL);
              cOther.Session.SendPacket(cErrorPkt);
              SendPacket(cErrorPkt);
            finally
              cErrorPkt.Free;
            end;
          end;
        end;
      end;
    end;

    SendTradeStatus(cOther, TRADE_STATUS_COMPLETE);
    SendTradeStatus(FActivePlayer, TRADE_STATUS_COMPLETE);

    cOther.TrdReset;
    FActivePlayer.TrdReset;
  end;
end;

procedure YGaSession.HandleUnAcceptTrade(InPkt: YNwClientPacket);
begin
  if not Assigned(FActivePlayer.TrdTrader) then Exit;

  SendTradeStatus(FActivePlayer.TrdTrader, TRADE_STATUS_UNACCEPT);
  FActivePlayer.TrdAccept := False;
  FActivePlayer.TrdTrader.TrdAccept := False;
end;

procedure YGaSession.HandleCancelTrade(InPkt: YNwClientPacket);
begin
  if not Assigned(FActivePlayer.TrdTrader) then Exit;

  SendTradeStatus(FActivePlayer.TrdTrader, TRADE_STATUS_CANCEL);
  SendTradeStatus(FActivePlayer, TRADE_STATUS_CANCEL);

  FActivePlayer.TrdTrader.TrdReset;
  FActivePlayer.TrdReset;
end;

procedure YGaSession.HandleSetTradeItem(InPkt: YNwClientPacket);
var
  iTradeSlot, iBag, iSlot: Byte;
  cItem: YGaItem;
begin
  if not Assigned(FActivePlayer.TrdTrader) then Exit;

  if FActivePlayer.TrdAccept or FActivePlayer.TrdTrader.TrdAccept then
  begin
    SendTradeStatus(FActivePlayer.TrdTrader, TRADE_STATUS_UNACCEPT);
    SendTradeStatus(FActivePlayer, TRADE_STATUS_UNACCEPT);
    FActivePlayer.TrdAccept := False;
    FActivePlayer.TrdTrader.TrdAccept := False;
  end;

  iTradeSlot := InPkt.ReadUInt8;
  iBag := InPkt.ReadUInt8;
  if iBag = BAG_NULL then
  begin
    iSlot := InPkt.ReadUInt8;
    cItem := FActivePlayer.EqpBackpackItems[FActivePlayer.EqpConvertAbsoluteSlotToRelative(iSlot, sctBackpack)];
  end else
  begin
    iSlot := InPkt.ReadUInt8;
    cItem := FActivePlayer.Bags[iBag].Items[iSlot];
  end;
  if cItem = nil then
    Exit;
  FActivePlayer.TrdSetItem(iTradeSlot, iBag, iSlot, cItem.Entry, cItem.StackCount);
  UpdateTrade(FActivePlayer);
end;

procedure YGaSession.HandleClearTradeItem(InPkt: YNwClientPacket);
var
  iTradeSlot: Byte;
begin
  if not Assigned(FActivePlayer.TrdTrader) then Exit;

  if FActivePlayer.TrdAccept or FActivePlayer.TrdTrader.TrdAccept then
  begin
    SendTradeStatus(FActivePlayer.TrdTrader, TRADE_STATUS_UNACCEPT);
    SendTradeStatus(FActivePlayer, TRADE_STATUS_UNACCEPT);
    FActivePlayer.TrdAccept := False;
    FActivePlayer.TrdTrader.TrdAccept := False;
  end;

	iTradeSlot := InPkt.ReadUInt8;
  FActivePlayer.TrdSetItem(iTradeSlot, 0, 0, MaxInt, 0);
  UpdateTrade(FActivePlayer);
end;

procedure YGaSession.HandleSetTradeGold(InPkt: YNwClientPacket);
var
  iCopper: UInt32;
begin
  if not Assigned(FActivePlayer.TrdTrader) then Exit;

  if FActivePlayer.TrdAccept or FActivePlayer.TrdTrader.TrdAccept then
  begin
    SendTradeStatus(FActivePlayer.TrdTrader, TRADE_STATUS_UNACCEPT);
    SendTradeStatus(FActivePlayer, TRADE_STATUS_UNACCEPT);
    FActivePlayer.TrdAccept := False;
    FActivePlayer.TrdTrader.TrdAccept := False;
  end;

  iCopper := InPkt.ReadUInt32;
	if FActivePlayer.TrdCopper <> iCopper then begin
    FActivePlayer.TrdCopper := iCopper;
    UpdateTrade(FActivePlayer);
  end;
end;

procedure YGaSession.HandleBusyTrade(InPkt: YNwClientPacket);
begin
  if not Assigned(FActivePlayer.TrdTrader) then Exit;

  SendTradeStatus(FActivePlayer.TrdTrader, TRADE_STATUS_IGNORE);

  FActivePlayer.TrdTrader.TrdReset;
  FActivePlayer.TrdReset;
end;

procedure YGaSession.HandleIgnoreTrade(InPkt: YNwClientPacket);
begin
  if not Assigned(FActivePlayer.TrdTrader) then Exit;

  SendTradeStatus(FActivePlayer.TrdTrader, TRADE_STATUS_IGNORE);

  FActivePlayer.TrdTrader.TrdReset;
  FActivePlayer.TrdReset;
end;

procedure YGaSession.SendQuestList(QuestGiver: YGaCreature; GUID: UInt64);
begin
(*
var
  cOutPkt: YNwServerPacket;
  iX, iCountPos, iQuestsCount: Int32;
  iQuestID{, iStartQuestsCount, iFinishQuestsCount}: UInt32;
  cQuest: YDbQuestTemplate;
begin
  cOutPkt := YNwServerPacket.Initialize(SMSG_QUESTGIVER_QUEST_LIST);
  try
    with cOutPkt, fLoggedInPlayer.Quests do
    begin
      AddUInt64(GUID);
      AddString(''{cQuestGiver.NpcText});
      AddUInt32({Delay}0);
      AddUInt32({Emote}0);
      //iStartQuestsCount := Length(cQuestGiver.StartQuestList);
      //iFinishQuestsCount := Length(cQuestGiver.FinishQuestList);
      iQuestsCount := 0;
      iCountPos := cOutPkt.Size;
      JumpUInt8;
      //AddUInt8(iStartQuestsCount + iFinishQuestsCount);
      //DIALOG_STATUS_REWARD then DIALOG_STATUS_INCOMPLETE then DIALOG_STATUS_AVAILABLE
      for iX := 0 to Length(QuestGiver.StartQuestList) - 1 do
      begin
        iQuestID := QuestGiver.StartQuestList[iX];
        if not IsAvailable(iQuestId) then
          Continue;
        DataCore.QuestTemplates.LoadEntry(iQuestID, cQuest);
        if not Assigned(cQuest) then
        begin
          fLoggedInPlayer.Chat.SystemMessage('Quest not found :' + IntToStr(iQuestId));
          Continue;
        end;
        AddUInt32(iQuestID);
        AddUInt32(DIALOG_STATUS_AVAILABLE);
        AddUInt32({???}0);
        AddString(cQuest.Name);
        Inc(iQuestsCount);
      end;
      for iX := 0 to Length(QuestGiver.FinishQuestList) - 1 do
      begin
        iQuestID := QuestGiver.FinishQuestList[iX];
        if fLoggedInPlayer.Quests.GetLogId(iQuestId) = - 1 then
          Continue;
        DataCore.QuestTemplates.LoadEntry(iQuestID, cQuest);
        if not Assigned(cQuest) then
        begin
          fLoggedInPlayer.Chat.SystemMessage('Quest not found :' + IntToStr(iQuestId));
          Continue;
        end;
        AddUInt32(iQuestID);
        AddUInt32(GetFinishDialogStatus(GetLogId(QuestGiver.FinishQuestList[iX])));
        AddUInt32({???}0);
        AddString(cQuest.Name);
        Inc(iQuestsCount);
      end;
    end;
    cOutPkt.AddUInt8(iQuestsCount, iCountPos);
    fLoggedInPlayer.Session.SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
  *)
end;

procedure YGaSession.SendQuestDetails(GUID: UInt64; QuestID: UInt32);
begin
(*
var
  iItemID, iEmoteCount: UInt32;
  iX: Int32;
  cOutPkt: YNwServerPacket;
  cObject: YGaMobile;
  cQuest: YDbQuestTemplate;
  cItem: YDbItemTemplate;
begin
  GameCore.FindObjectByGUID(otUnit, GUID, cObject);
  if not Assigned(cObject) then
  begin
    GameCore.FindObjectByGUID(otItem, GUID, cObject);
    if not Assigned(cObject) then
      Exit;
  end;
  DataCore.QuestTemplates.LoadEntry(QuestID, cQuest);
  if not Assigned(cQuest) then
    Exit;
  cOutPkt := YNwServerPacket.Initialize(SMSG_QUESTGIVER_QUEST_DETAILS);
  try
    with cOutPkt do
    begin
      AddUInt64(GUID);
      AddUInt32(QuestID);
      AddString(cQuest.Name);
      AddString(cQuest.Details);
      AddString(cQuest.Objectives);
      AddUInt32({???}0);
      AddUInt32(cQuest.RewardItmChoice.Count);
      for iX := 0 to cQuest.RewardItmChoice.Count - 1 do
      begin
        iItemID := cQuest.RewardItmChoice.Objects[iX].Id;
        DataCore.ItemTemplates.LoadEntry(iItemID, cItem);
        if not Assigned(cItem) then
        begin
          AddUInt32(0);
          AddUInt32(0);
          AddUInt32(0);
          Continue;
        end;
        AddUInt32(iItemID);
        AddUInt32(cQuest.RewardItmChoice.Objects[iX].Count);
        AddUInt32(cItem.ModelId);
      end;
      AddUInt32(cQuest.RewardItem.Count);
      for iX := 0 to cQuest.RewardItem.Count - 1 do
      begin
        iItemID := cQuest.RewardItem.Objects[iX].Id;
        DataCore.ItemTemplates.LoadEntry(iItemID, cItem);
        if not Assigned(cItem) then
        begin
          AddUInt32(0);
          AddUInt32(0);
          AddUInt32(0);
          Continue;
        end;
        AddUInt32(iItemID);
        AddUInt32(cQuest.RewardItem.Objects[iX].Count);
        AddUInt32(cItem.ModelId);
      end;
      AddUInt32(cQuest.MoneyReward);
      AddUInt32(cQuest.LearnSpell);
      AddUInt32({???}0);
      iEmoteCount := 0;
      AddUInt32(iEmoteCount);
      for iX := 0 to iEmoteCount - 1 do
      begin
        AddUInt32(0); //Delay
        AddUInt32(0); //Emote
      end;
    end;
    fLoggedInPlayer.Session.SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
*)
end;

procedure YGaSession.SendQuestReward(GUID: UInt64; QuestID: UInt32);
begin
(*
var
  cOutPkt: YNwServerPacket;
  cQuest: YDbQuestTemplate;
  cItem: YDbItemTemplate;
  iX: Int32;
  iEmoteCount, iItemId: UInt32;
begin
  DataCore.QuestTemplates.LoadEntry(QuestID, cQuest);
  if not Assigned(cQuest) then
    Exit;
  cOutPkt := YNwServerPacket.Initialize(SMSG_QUESTGIVER_OFFER_REWARD);
  try
    with cOutPkt do
    begin
      AddUInt64(GUID);
      AddUInt32(QuestID);
      AddString(cQuest.Name);
      AddString(cQuest.CompleteText);
      AddUInt32(0);//EnableNext???
      iEmoteCount := 0;
      AddUInt32(iEmoteCount);
      for iX := 0 to iEmoteCount - 1 do
      begin
        AddUInt32(0); //Delay
        AddUInt32(0); //Emote
      end;
      AddUInt32(cQuest.RewardItmChoice.Count);
      for iX := 0 to cQuest.RewardItmChoice.Count - 1 do
      begin
        iItemID := cQuest.RewardItmChoice.Objects[iX].Id;
        DataCore.ItemTemplates.LoadEntry(iItemID, cItem);
        if not Assigned(cItem) then
        begin
          AddUInt32(0);
          AddUInt32(0);
          AddUInt32(0);
          Continue;
        end;
        AddUInt32(iItemID);
        AddUInt32(cQuest.RewardItmChoice.Objects[iX].Count);
        AddUInt32(cItem.ModelId);
      end;
      AddUInt32(cQuest.RewardItem.Count);
      for iX := 0 to cQuest.RewardItem.Count - 1 do
      begin
        iItemID := cQuest.RewardItem.Objects[iX].Id;
        DataCore.ItemTemplates.LoadEntry(iItemID, cItem);
        if not Assigned(cItem) then
        begin
          AddUInt32(0);
          AddUInt32(0);
          AddUInt32(0);
          Continue;
        end;
        AddUInt32(iItemID);
        AddUInt32(cQuest.RewardItem.Objects[iX].Count);
        AddUInt32(cItem.ModelId);
      end;
      AddUInt32(cQuest.MoneyReward);
      AddUInt32(cQuest.LearnSpell);
      AddUInt32({???}0);
    end;
    fLoggedInPlayer.Session.SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
*)
end;

procedure YGaSession.SendGossipMenu(Cr: YGaCreature; GUID: UInt64);
begin
(*
var
  cOutPkt: YNwServerPacket;
  iMenuCount, iQuestCount: UInt32;
  iX: Int32;
  cQuest: YDbQuestTemplate;
begin
//nothing displayed :-( strange

  cOutPkt := YNwServerPacket.Initialize(SMSG_GOSSIP_MESSAGE);
  try
    with cOutPkt do
    begin
      AddUInt64(GUID);
      AddUInt32(328); //NPCTextId
      iMenuCount := 2;
      AddUInt32(iMenuCount);
      for iX := 0 to iMenuCount - 1 do
      begin
        AddUInt32(iX);
        AddUInt8(0);//icon
        AddUInt8(0);//coded
        AddString('lol'+IntToStr(iX));//message
      end;
  
      iQuestCount := Length(Cr.StartQuestList);
      AddUInt32(iQuestCount);
      for iX := 0 to iQuestCount - 1 do
      begin
        DataCore.QuestTemplates.LoadEntry(Cr.StartQuestList[iX], cQuest);
        if not Assigned(cQuest) then
          Exit;
        AddUInt32(Cr.StartQuestList[iX]);
        AddUInt32(2);//icon
        AddUInt32(cQuest.QuestLevel);
        AddString(cQuest.Name);
      end;
    end;
    fLoggedInPlayer.Session.SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
*)
end;

procedure YGaSession.SendCloseGossip;
var
  cOutPkt: YNwServerPacket;
begin
  cOutPkt := YNwServerPacket.Initialize(SMSG_GOSSIP_COMPLETE);
  try
    FActivePlayer.Session.SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
end;

procedure YGaSession.SendCompleteQuest(GUID: UInt64; QuestID: UInt32);
begin
(*var
  cOutPkt: YNwServerPacket;
  cQuest: YDbQuestTemplate;
  cItem: YDbItemTemplate;
  iX: Int32;
  iRequiredCount: UInt32;
begin
  with fLoggedInPlayer.Quests do if IsWaitingForReward(GetLogId(QuestID)) then
  begin
    SendQuestReward(GUID, QuestID);
    Exit;
  end;
  DataCore.QuestTemplates.LoadEntry(QuestID, cQuest);
  if not Assigned(cQuest) then
    Exit;
  cOutPkt := YNwServerPacket.Initialize(SMSG_QUESTGIVER_REQUEST_ITEMS);
  try
    with cOutPkt do
    begin
      AddUInt64(GUID);
      AddString(cQuest.Name);
      AddString(cQuest.IncompleteText);
      AddUInt32(0);
      AddUInt32(0);
      AddUInt32(1);//Close on cancel
      AddUInt32(0);//RequiredMoney
      iRequiredCount := Length(cQuest.DeliverObjective.Objects);
      AddUInt32(iRequiredCount);
      for iX := 0 to iRequiredCount - 1 do with cQuest.DeliverObjective.Objects[iX] do
      begin
        DataCore.ItemTemplates.LoadEntry(Id, cItem);
        if not Assigned(cItem) then
        begin
          AddUInt32(0);
          AddUInt32(0);
          AddUInt32(0);
          Continue;
        end;
        AddUInt32(Id);
        AddUInt32(Count);
        AddUInt32(cItem.ModelId);
      end;
      AddUInt32(2);//???
      AddUInt32(3);//Completable
      AddUInt32(4);
      AddUInt32(8);
      AddUInt32(10);
    end;
    fLoggedInPlayer.Session.SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
*)
end;

procedure YGaSession.HandleGossipHello(InPkt: YNwClientPacket);
begin
(*
var
  iGUID: UInt64;
  cCreature: YGaCreature;
begin
  iGUID := InPkt.ReadUInt64;
  GameCore.FindObjectByGUID(otUnit, iGUID, cCreature);
  if not (Assigned(cCreature) and True{SameFaction}) then
  begin
    Exit;
  end;
  SendGossipMenu(cCreature, iGUID);
*)
end;

procedure YGaSession.HandleGossipSelectionOption(InPkt: YNwClientPacket);
begin
  //
end;

procedure YGaSession.HandleNPCTextQuery(InPkt: YNwClientPacket);
begin
  //
end;

procedure YGaSession.HandlePushQuestToParty(InPkt: YNwClientPacket);
begin
  //
end;

procedure YGaSession.HandleQuestGiverStatusQuery(InPkt: YNwClientPacket);
begin
(*
var
  iGUID: UInt64;
  iTest, iStatus: UInt32;
  iX: Int32;
  cOutPkt: YNwServerPacket;
  cQuestGiver: YGaCreature;
begin
  iGUID := InPkt.ReadUInt64;
  GameCore.FindObjectByGUID(otUnit, iGUID, cQuestGiver);
  if not Assigned(cQuestGiver) then
  begin
    GameCore.FindObjectByGUID(otItem, iGUID, cQuestGiver);
    if not Assigned(cQuestGiver) then
      Exit;
  end;
  iStatus := DIALOG_STATUS_NONE;
  with cQuestGiver do if ObjectType = otUnit then
  begin
    for iX := 0 to Length(FinishQuestList) - 1 do with fLoggedInPlayer.Quests do
    begin
      if GetLogId(StartQuestList[iX]) = - 1 then
        Continue;
      iTest := GetFinishDialogStatus(GetLogId(StartQuestList[iX]));
      if iTest = DIALOG_STATUS_REWARD then
      begin
        iStatus := DIALOG_STATUS_REWARD;
        Break;
      end else if iTest <> DIALOG_STATUS_NONE then
        iStatus := iTest;
    end;
    if iStatus <> DIALOG_STATUS_REWARD then
      for iX := 0 to Length(StartQuestList) - 1 do with fLoggedInPlayer.Quests do
      begin
        if IsAvailable(StartQuestList[iX]) then
        begin
          iStatus := DIALOG_STATUS_AVAILABLE;
          Break;
        end;
      end;
  end else if ObjectType = otGameObject{UseFull?} then
  begin
    Writeln('QuestGiverStatusQuery on GameObject');
  end;

  cOutPkt := YNwServerPacket.Initialize(SMSG_QUESTGIVER_STATUS);
  try
    cOutPkt.AddUInt64(iGUID);
    cOutPkt.AddUInt32(iStatus);
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
*)
end;

procedure YGaSession.HandleQuestConfirmAccept(InPkt: YNwClientPacket);
begin
  //
end;

procedure YGaSession.HandlePageTextQuery(InPkt: YNwClientPacket);
begin
(*
var
  iPageId: UInt32;
  cOutPkt: YNwServerPacket;
  //cPage: YPageTemplate;
begin
  iPageId := InPkt.ReadUInt32;
  cOutPkt := YNwServerPacket.Initialize(SMSG_PAGE_TEXT_QUERY_RESPONSE);
  try
    cOutPkt.AddUInt32(iPageId);
    while iPageId <> 0 do
    begin
      //DataCore.PageTemplates.LoadEntry(iPageId, cPage);
      with cOutPkt do {if Assigned(cPage) then
      begin
        AddString(cPage.Text);
        iPageId := cPage.NextPage;
        AddUInt32(iPageId);
      end else}
      begin
        AddString('Item page missing.');
        iPageId := 0;
        AddUInt32(iPageId);
      end;
    end;
    fLoggedInPlayer.Session.SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
*)
end;

procedure YGaSession.HandleQuestGiverAcceptQuest(InPkt: YNwClientPacket);
begin
(*
var
  iGUID: UInt64;
  iQuestId: UInt32;
  cObject: YGaMobile;
begin
  iGUID := InPkt.ReadUInt64;
  GameCore.FindObjectByGUID(otUnit, iGUID, cObject);
  if not Assigned(cObject) then
  begin
    GameCore.FindObjectByGUID(otItem, iGUID, cObject);
    if not Assigned(cObject) then
      Exit
  end;

  iQuestId := InPkt.ReadUInt32;
  fLoggedInPlayer.Quests.Add(iQuestID);
*)
end;

procedure YGaSession.HandleQuestGiverCancel(InPkt: YNwClientPacket);
begin
  //
end;

procedure YGaSession.HandleQuestQuery(InPkt: YNwClientPacket);
begin
(*var
  cOutPkt: YNwServerPacket;
  iQuestID, iX: UInt32;
  cQuest: YDbQuestTemplate;
begin
  {TODO 3 -oBIGBOSS -cQuest : Check if correct fields sent}
  iQuestID := InPkt.ReadUInt32;
  DataCore.QuestTemplates.LoadEntry(iQuestID, cQuest);
  if not Assigned(cQuest) then
    Exit;
  cOutPkt := YNwServerPacket.Initialize(SMSG_QUEST_QUERY_RESPONSE);
  try
    with cOutPkt, cQuest do
    begin
      AddUInt32(iQuestID);
      AddUInt32(ReqLevel);
      AddUInt32(QuestLevel);
      AddUInt32(Category);
      AddUInt32(Complexity);
      AddUInt32(RequiresRace[0]);
      AddUInt32(RequiresRace[1]);
      AddUInt32(RequiresClass[0]);
      AddUInt32(RequiresClass[1]);
      AddUInt32(NextQuest);
      AddUInt32(MoneyReward);
      AddUInt32(LearnSpell);
      AddUInt32(0);
      AddUInt32(0);
      AddUInt32(DescriptiveFlags);
      for iX := 0 to 3 do
      begin
        AddUInt32(RewardItem.Objects[iX].Id);
        AddUInt32(RewardItem.Objects[iX].Count);
      end;
      for iX := 0 to QUEST_OBJECTS_COUNT - 1 do
      begin
        AddUInt32(RewardItmChoice.Objects[iX].Id);
        AddUInt32(RewardItmChoice.Objects[iX].Count);
      end;
      AddUInt32(Location.Area);
      AddFloat(Location.X);
      AddFloat(Location.Y);
      AddFloat(Location.Z);
      AddString(Name);
      AddString(Objectives);
      AddString(Details);
      AddString(EndText);
      for iX := 0 to QUEST_OBJECTS_COUNT - 1 do
      begin
        AddUInt32(KillObjectiveMob.Objects[iX].Id);
        AddUInt32(KillObjectiveMob.Objects[iX].Count);
        AddUInt32(DeliverObjective.Objects[iX].Id);
        AddUInt32(DeliverObjective.Objects[iX].Count);
      end;
      for iX := 0 to QUEST_OBJECTS_COUNT - 1 do
      begin
        AddUInt32(KillObjectiveObj.Objects[iX].Id);   //not sure
        AddUInt32(KillObjectiveObj.Objects[iX].Count);//not sure
      end;
      AddString(ObjectiveText1);  //not sure
      AddString(ObjectiveText2);  //not sure
      AddString(ObjectiveText3);  //not sure
      AddString(ObjectiveText4);  //not sure
    end;
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
*)
end;

procedure YGaSession.HandleQuestGiverChooseReward(InPkt: YNwClientPacket);
begin
(*
var
  bReward: Boolean;
  iGUID: UInt64;
  iX: Int32;
  iQuestId, iRewardItem, iXP: UInt32;
  cOutPkt: YNwServerPacket;
  cObject: YGaCreature;
begin
  iGUID := InPkt.ReadUInt64;
  GameCore.FindObjectByGUID(otUnit, iGUID, cObject);
  if not Assigned(cObject) then
  begin
    Exit;
  end;
  iQuestId := InPkt.ReadUInt32;
  iRewardItem := InPkt.ReadUInt32;
  with fLoggedInPlayer.Quests, ActiveQuestsInfos[GetLogId(iQuestId)].Template do
  begin
    if not IsWaitingForReward(GetLogId(iQuestId)) then
    begin
      SendQuestList(cObject, iGUID);
      Exit;
    end;
    bReward := iRewardItem in [1..QUEST_OBJECTS_COUNT];
    if bReward then
    begin
      if not fLoggedInPlayer.Equip.HasEnoughFreeSlots(RewardItem.Count + 1) then
      begin
        fLoggedInPlayer.Equip.SendInventoryError(INV_ERR_INVENTORY_FULL);
        SendQuestList(cObject, iGUID);
        Exit;
      end;
    end else
    begin
      if not fLoggedInPlayer.Equip.HasEnoughFreeSlots(RewardItem.Count) then
      begin
        fLoggedInPlayer.Equip.SendInventoryError(INV_ERR_INVENTORY_FULL);
        SendQuestList(cObject, iGUID);
        Exit;
      end;
    end;
    {TODO 2 -oBIGBOSS : Consume deliver + add spell}
    cOutPkt := YNwServerPacket.Initialize(SMSG_QUESTGIVER_QUEST_COMPLETE);
    try
      with cOutPkt do
      begin
        if fLoggedInPlayer.Experience.IsRested then
          iXP := ReqLevel * 4
        else
          iXP := ReqLevel * 2; //just for test
        AddUInt32(iQuestId);
        AddUInt32(3);
        AddUInt32(iXP);
        AddUInt32(MoneyReward);
        AddUInt32(RewardItem.Count);
        for iX := 0 to RewardItem.Count - 1 do with RewardItem.Objects[iX] do
        begin
          AddUInt32(Id);
          AddUInt32(Count);
          fLoggedInPlayer.Equip.AddItem(Id, Count, False);
        end;
        if bReward then with RewardItmChoice.Objects[iRewardItem] do
        begin
          {AddUInt32(Id);
          AddUInt32(Count);}
          fLoggedInPlayer.Equip.AddItem(Id, Count, False);
        end{ else
        begin
          AddUInt32(0);
          AddUInt32(0);
        end};
        with fLoggedInPlayer do
        begin
          SetUInt32(PLAYER_FIELD_COINAGE, fLoggedInPlayer.Equip.Money + MoneyReward);
          SetUInt32(PLAYER_XP, fLoggedInPlayer.GetUInt32(PLAYER_XP) + iXP);
        end;
        fLoggedInPlayer.Quests.AddToFinishedQuests(iQuestId);
        fLoggedInPlayer.Session.SendPacket(cOutPkt);
        if NextQuest <> 0 then
          SendQuestDetails(iGUID, NextQuest);
        Remove(GetLogId(iQuestId));
      end;
    finally
      cOutPkt.Free;
    end;
  end;
*)
end;

procedure YGaSession.HandleQuestGiverCompleteQuest(InPkt: YNwClientPacket);
begin
(*
var
  iGUID: UInt64;
  iQuestId: UInt32;
begin
  iGUID := InPkt.ReadUInt64;
  iQuestId := InPkt.ReadUInt32;
  SendCompleteQuest(iGUID, iQuestID);
*)
end;

procedure YGaSession.HandleQuestGiverHello(InPkt: YNwClientPacket);
begin
(*
var
  iGUID: UInt64;
  iX: Int32;
  cQuestGiver: YGaCreature;
begin
  iGUID := InPkt.ReadUInt64;
  GameCore.FindObjectByGUID(otUnit, iGUID, cQuestGiver);
  if not Assigned(cQuestGiver) then
  begin
    Exit;
  end;
  for iX := 0 to Length(cQuestGiver.FinishQuestList) - 1 do with fLoggedInPlayer.Quests do
  begin
    if GetFinishDialogStatus(GetLogId(cQuestGiver.FinishQuestList[iX])) = DIALOG_STATUS_REWARD then
    begin
      SendQuestReward(iGUID, cQuestGiver.FinishQuestList[iX]);
      Exit;
    end;
  end;

  SendQuestList(cQuestGiver, iGUID);
*)
end;

procedure YGaSession.HandleQuestLogRemoveQuest(InPkt: YNwClientPacket);
begin
(*
var
  iQuestLogId: UInt32;
begin
  iQuestLogId := InPkt.ReadUInt8;
  fLoggedInPlayer.Quests.Remove(iQuestLogId);
*)
end;

procedure YGaSession.HandleQuestLogSwapQuest(InPkt: YNwClientPacket);
begin
  //
end;

procedure YGaSession.HandleQuestGiverQueryQuest(InPkt: YNwClientPacket);
begin
(*
var
  iGUID: UInt64;
  iQuestId: UInt32;
begin
  iGUID := InPkt.ReadUInt64;
  iQuestId := InPkt.ReadUInt32;
  SendQuestDetails(iGUID, iQuestId);
*)
end;

procedure YGaSession.HandleQuestGiverQuestAutoLaunch(InPkt: YNwClientPacket);
begin
  //
end;

procedure YGaSession.HandleQuestGiverRequestReward(InPkt: YNwClientPacket);
begin
(*
var
  iGUID: UInt64;
  iQuestId: UInt32;
  cQuestGiver: YGaCreature;
begin
  iGUID := InPkt.ReadUInt64;
  iQuestId := InPkt.ReadUInt32;
  with fLoggedInPlayer.Quests do if IsWaitingForReward(GetLogId(iQuestId)) then
    SendQuestReward(iGUID, iQuestId)
  else
  begin
    GameCore.FindObjectByGUID(otUnit, iGUID, cQuestGiver);
    if not Assigned(cQuestGiver) then
    begin
      Exit;
    end;
    SendQuestList(cQuestGiver, iGUID);
  end;
*)
end;

procedure YGaSession.HandleAreaTrigger(InPkt: YNwClientPacket);
begin
(*
var
  iTriggerId: UInt32;
  iX: Int32;
begin
  iTriggerId := InPkt.ReadUInt32;
  {for iX := 0 to Length(DataCore.ExplorationTriggers) - 1 do
    if DataCore.ExplorationTriggers[iX][0] = iTriggerId then
      fLoggedInPlayer.QuestManager.QuestExploration(DataCore.ExplorationTriggers[iX][1]);
  }
  with fLoggedInPlayer.Quests do for iX := 0 to QUEST_LOG_COUNT - 1 do
    if ActiveQuests.Quests[iX].NeedExplore then
      if ActiveQuestsInfos[iX].Template.ExploreObjective = iTriggerId then
        QuestExploration(ActiveQuests.Quests[iX].Id);
  Writeln('===> AREATRIGGER : ', iTriggerId);
  *)
end;

destructor YGaSession.Destroy;
begin
  { Removing subscription }
  if Assigned(FActivePlayer) then
  begin
    if FLogoutTimerHandle <> nil then
    begin
      FLogoutTimerHandle.Unregister;
      FLogoutTimerHandle := nil;
      FActivePlayer.ReplaceUInt32(UNIT_FIELD_BYTES_1, UNIT_STATE_SIT, UNIT_STATE_STAND);
      FActivePlayer.AndNotUInt32(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_ROOTED);
    end;
    if FActivePlayer.InWorld then FActivePlayer.ChangeWorldState(wscRemove);
    FActivePlayer.Free;
    FActivePlayer := nil;
  end;
  if FHandle <> nil then
  begin
    FHandle.Unregister;
    FHandle := nil;
  end;
  inherited Destroy;
end;

constructor YGaSession.Create;
begin
  inherited Create;
  { Now let's register a Subscription }
  FHandle := SysEventMgr.RegisterEvent(SessionTimer, SESSION_UPD_INTERVAL,
    TICK_EXECUTE_INFINITE, 'GaSession_MainTimer');
end;

procedure YGaSession.SendPacket(Pkt: YNwServerPacket);
begin
  FSocket.SessionSendPacket(Pkt);
end;

procedure YGaSession.SessionLogOut(Event: TEventHandle; TimeDelta: UInt32);
var
  OutPkt: YNwServerPacket;
begin
  with FActivePlayer do
  begin
    ReplaceUInt32(UNIT_FIELD_BYTES_1, UNIT_STATE_SIT, UNIT_STATE_STAND);
    AndNotUInt32(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_ROOTED);
  end;

  OutPkt := YNwServerPacket.Initialize(SMSG_FORCE_MOVE_UNROOT);
  try
    OutPkt.AddPackedGUID(FActivePlayer.GUID);
    SendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;

  OutPkt := YNwServerPacket.Initialize(SMSG_LOGOUT_COMPLETE);
  try
    SendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;
  
  FActivePlayer.ChangeWorldState(wscRemove);
  FLogoutTimerHandle := nil;
end;

procedure YGaSession.SessionTimer(Event: TEventHandle; TimeDelta: UInt32);
begin
  if Assigned(FActivePlayer) then
  begin
    FActivePlayer.PlayerLifeTimer(Event, TimeDelta);
  end;
end;

function YGaSession.DispatchOpcode(InPkt: YNwClientPacket; OpCode: Longword): Boolean;
begin
  Result := CallOpcodeHandler(Self, InPkt, OpCode);
  (*
  if not Result and (fLoggedInPlayer <> nil) then
  begin
    fLoggedInPlayer.Chat.SystemMessage(
      'Client sends Opcode {|c000000FF'+ GetOpcodeName(lwOpCode) +'|r} = [ |cffff0000' +
      itoa(lwOpCode) + '|r ]'
    );
  end;
  *)
end;

procedure YGaSession.SetAccount(const Acc: WideString);
begin
  FAccountName := WideUpperCase(Acc);
end;

function YGaSession.GetAccount: WideString;
begin
  Result := FAccountName;
end;

function YGaSession.GetRealmName: WideString;
begin
  Result := FRealmName;
end;

procedure InitOpcodeTable;
begin
  { Add new opcode handlers here }
  { First argument is a pointer to the handler, second one is the opcode it responds to }
  RegisterOpcodeHandler(@YGaSession.HandleCharCreateOpcode, CMSG_CHAR_CREATE);
  RegisterOpcodeHandler(@YGaSession.HandleCharEnumOpcode, CMSG_CHAR_ENUM);
  RegisterOpcodeHandler(@YGaSession.HandleCharDeleteOpcode, CMSG_CHAR_DELETE);
  RegisterOpcodeHandler(@YGaSession.HandleCharLoginOpcode, CMSG_PLAYER_LOGIN);
  RegisterOpcodeHandler(@YGaSession.HandleNameQuery, CMSG_NAME_QUERY);
  RegisterOpcodeHandler(@YGaSession.HandleItemNameQuery, CMSG_ITEM_NAME_QUERY);
  RegisterOpcodeHandler(@YGaSession.HandleSheathedOpcode, CMSG_SETSHEATHED);
  RegisterOpcodeHandler(@YGaSession.HandleItemQuerySingle, CMSG_ITEM_QUERY_SINGLE);
  RegisterOpcodeHandler(@YGaSession.HandleCreatureQuery, CMSG_CREATURE_QUERY);
  RegisterOpcodeHandler(@YGaSession.HandleTimeQuery, CMSG_QUERY_TIME);
  RegisterOpcodeHandler(@YGaSession.HandleNextMailTimeQuery, MSG_QUERY_NEXT_MAIL_TIME);
  RegisterOpcodeHandler(@YGaSession.TutorialManipulation, CMSG_TUTORIAL_FLAG);
  RegisterOpcodeHandler(@YGaSession.TutorialManipulation, CMSG_TUTORIAL_CLEAR);
  RegisterOpcodeHandler(@YGaSession.TutorialManipulation, CMSG_TUTORIAL_RESET);
  RegisterOpcodeHandler(@YGaSession.ChatManipulation, CMSG_MESSAGECHAT);
  RegisterOpcodeHandler(@YGaSession.LogoutManipulation, CMSG_LOGOUT_REQUEST);
  RegisterOpcodeHandler(@YGaSession.LogoutManipulation, CMSG_LOGOUT_CANCEL);
  RegisterOpcodeHandler(@YGaSession.LogoutManipulation, CMSG_PLAYER_LOGOUT);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_START_FORWARD);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_START_BACKWARD);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_STOP);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_START_STRAFE_LEFT);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_START_STRAFE_RIGHT);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_STOP_STRAFE);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_START_TURN_LEFT);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_START_TURN_RIGHT);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_STOP_TURN);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_SET_FACING);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_HEARTBEAT);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_JUMP);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_SET_PITCH);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_START_PITCH_UP);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_START_PITCH_DOWN);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_STOP_PITCH);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_SET_RUN_MODE);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_SET_WALK_MODE);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_START_SWIM);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_STOP_SWIM);
  RegisterOpcodeHandler(@YGaSession.HandleMovement, MSG_MOVE_FALL_LAND);
  RegisterOpcodeHandler(@YGaSession.HandleChannelJoin, CMSG_JOIN_CHANNEL);
  RegisterOpcodeHandler(@YGaSession.HandleChannelLeave, CMSG_LEAVE_CHANNEL);
  RegisterOpcodeHandler(@YGaSession.HandleChannelListRequest, CMSG_CHANNEL_LIST);
  RegisterOpcodeHandler(@YGaSession.HandleChannelPasswordSet, CMSG_CHANNEL_PASSWORD);
  RegisterOpcodeHandler(@YGaSession.HandleChannelOwnerSet, CMSG_CHANNEL_SET_OWNER);
  RegisterOpcodeHandler(@YGaSession.HandleChannelOwnerGet, CMSG_CHANNEL_OWNER);
  RegisterOpcodeHandler(@YGaSession.HandleChannelPromote, CMSG_CHANNEL_MODERATOR);
  RegisterOpcodeHandler(@YGaSession.HandleChannelDepromote, CMSG_CHANNEL_UNMODERATOR);
  RegisterOpcodeHandler(@YGaSession.HandleChannelMute, CMSG_CHANNEL_MUTE);
  RegisterOpcodeHandler(@YGaSession.HandleChannelUnmute, CMSG_CHANNEL_UNMUTE);
  RegisterOpcodeHandler(@YGaSession.HandleChannelSendInvitiation, CMSG_CHANNEL_INVITE);
  RegisterOpcodeHandler(@YGaSession.HandleChannelKick, CMSG_CHANNEL_KICK);
  RegisterOpcodeHandler(@YGaSession.HandleChannelBan, CMSG_CHANNEL_BAN);
  RegisterOpcodeHandler(@YGaSession.HandleChannelUnban, CMSG_CHANNEL_UNBAN);
  RegisterOpcodeHandler(@YGaSession.HandleChannelToggleAnnounce, CMSG_CHANNEL_ANNOUNCEMENTS);
  RegisterOpcodeHandler(@YGaSession.HandleChannelToggleModerated, CMSG_CHANNEL_MODERATE);
  RegisterOpcodeHandler(@YGaSession.HandleStandStateChange, CMSG_STANDSTATECHANGE);
  RegisterOpcodeHandler(@YGaSession.HandleSetSelection, CMSG_SET_SELECTION);
  RegisterOpcodeHandler(@YGaSession.HandleSwapInvItem, CMSG_SWAP_INV_ITEM);
  RegisterOpcodeHandler(@YGaSession.HandleSwapItem, CMSG_SWAP_ITEM);
  RegisterOpcodeHandler(@YGaSession.HandleAutoEquipItem, CMSG_AUTOEQUIP_ITEM);
  RegisterOpcodeHandler(@YGaSession.HandleAutoStoreBagItem, CMSG_AUTOSTORE_BAG_ITEM);
  RegisterOpcodeHandler(@YGaSession.HandleSetAmmo, CMSG_SET_AMMO);
  RegisterOpcodeHandler(@YGaSession.HandleSplitItem, CMSG_SPLIT_ITEM);
  RegisterOpcodeHandler(@YGaSession.HandleUseItem, CMSG_USE_ITEM);
  RegisterOpcodeHandler(@YGaSession.HandleDestroyItem, CMSG_DESTROYITEM);
  RegisterOpcodeHandler(@YGaSession.HandleInitiateTrade, CMSG_INITIATE_TRADE);
  RegisterOpcodeHandler(@YGaSession.HandleBeginTrade, CMSG_BEGIN_TRADE);
  RegisterOpcodeHandler(@YGaSession.HandleBusyTrade, CMSG_BUSY_TRADE);
  RegisterOpcodeHandler(@YGaSession.HandleIgnoreTrade, CMSG_IGNORE_TRADE);
  RegisterOpcodeHandler(@YGaSession.HandleAcceptTrade, CMSG_ACCEPT_TRADE);
  RegisterOpcodeHandler(@YGaSession.HandleUnAcceptTrade, CMSG_UNACCEPT_TRADE);
  RegisterOpcodeHandler(@YGaSession.HandleCancelTrade, CMSG_CANCEL_TRADE);
  RegisterOpcodeHandler(@YGaSession.HandleSetTradeItem, CMSG_SET_TRADE_ITEM);
  RegisterOpcodeHandler(@YGaSession.HandleClearTradeItem, CMSG_CLEAR_TRADE_ITEM);
  RegisterOpcodeHandler(@YGaSession.HandleSetTradeGold, CMSG_SET_TRADE_GOLD);
  RegisterOpcodeHandler(@YGaSession.HandleGossipHello, CMSG_GOSSIP_HELLO);
  RegisterOpcodeHandler(@YGaSession.HandleGossipSelectionOption, CMSG_GOSSIP_SELECT_OPTION);
  RegisterOpcodeHandler(@YGaSession.HandleNPCTextQuery, CMSG_NPC_TEXT_QUERY);
  RegisterOpcodeHandler(@YGaSession.HandleQuestGiverStatusQuery, CMSG_QUESTGIVER_STATUS_QUERY);
  RegisterOpcodeHandler(@YGaSession.HandleQuestGiverHello, CMSG_QUESTGIVER_HELLO);
  RegisterOpcodeHandler(@YGaSession.HandleQuestGiverQueryQuest, CMSG_QUESTGIVER_QUERY_QUEST);
  RegisterOpcodeHandler(@YGaSession.HandleQuestGiverQuestAutoLaunch, CMSG_QUESTGIVER_QUEST_AUTOLAUNCH);
  RegisterOpcodeHandler(@YGaSession.HandleQuestGiverAcceptQuest, CMSG_QUESTGIVER_ACCEPT_QUEST);
  RegisterOpcodeHandler(@YGaSession.HandleQuestGiverCompleteQuest, CMSG_QUESTGIVER_COMPLETE_QUEST);
  RegisterOpcodeHandler(@YGaSession.HandleQuestGiverRequestReward, CMSG_QUESTGIVER_REQUEST_REWARD);
  RegisterOpcodeHandler(@YGaSession.HandleQuestGiverChooseReward, CMSG_QUESTGIVER_CHOOSE_REWARD);
  RegisterOpcodeHandler(@YGaSession.HandleQuestGiverCancel, CMSG_QUESTGIVER_CANCEL);
  RegisterOpcodeHandler(@YGaSession.HandleQuestQuery, CMSG_QUEST_QUERY);
  RegisterOpcodeHandler(@YGaSession.HandleQuestLogSwapQuest, CMSG_QUESTLOG_SWAP_QUEST);
  RegisterOpcodeHandler(@YGaSession.HandleQuestLogRemoveQuest, CMSG_QUESTLOG_REMOVE_QUEST);
  RegisterOpcodeHandler(@YGaSession.HandleQuestConfirmAccept, CMSG_QUEST_CONFIRM_ACCEPT);
  RegisterOpcodeHandler(@YGaSession.HandlePageTextQuery, CMSG_PAGE_TEXT_QUERY);
  RegisterOpcodeHandler(@YGaSession.HandlePushQuestToParty, CMSG_PUSHQUESTTOPARTY);
  RegisterOpcodeHandler(@YGaSession.HandleAreaTrigger, CMSG_AREATRIGGER);

  RegisterOpcodeHandler(@YGaSession.HandleNoAction, CMSG_MOVE_TIME_SKIPPED);
  RegisterOpcodeHandler(@YGaSession.HandleNoAction, CMSG_NEXT_CINEMATIC_CAMERA);
  RegisterOpcodeHandler(@YGaSession.HandleNoAction, CMSG_COMPLETE_CINEMATIC);
  RegisterOpcodeHandler(@YGaSession.HandleNoAction, CMSG_BATTLEFIELD_STATUS);

  RegisterOpcodeHandler(@YGaSession.HandleMoveWorldPortACK, MSG_MOVE_WORLDPORT_ACK);
end;

initialization
  { Initialize the opcode table }
  InitOpcodeTable;
  OpcodeMax := Length(Handlers);

end.
