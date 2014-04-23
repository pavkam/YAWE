{*------------------------------------------------------------------------------
  GameCore's Session.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth, TheSelby, BigBoss, Morpheus
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.Session;

interface

uses
  SysUtils,
  Misc.Miscleanous,
  Misc.Containers,
  Misc.Resources,
  Misc.Geometry,
  Framework.Base,
  Framework.Tick,
  Version,
  Components.DataCore.Fields,
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
  Components.GameCore.Guilds,
  Components.GameCore.UpdateFields,
  Components.GameCore.Constants,
  Components.IoCore.Console,
  Components.DataCore.Types;

type
  { OpenSession represents the "mini-world" that a player lives in }
  YGaSession = class(TBaseInterfacedObject, ISessionInterface)
    private
      fAccount: string;
      fInThisRealm: string;
      fLogoutTimerHandle: TEventHandle;
      fSocket: ISocketInterface;
      fLoggedInPlayer: YGaPlayer;
      fHandle: TEventHandle;

      { Sends a packet to XCore }
      procedure SendPacket(Pkt: YNwServerPacket); inline;

      { Send a packet to player }
      procedure ReportNotInGuild;

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

      procedure HandleGuildQUERY(InPkt: YNwClientPacket);
      procedure HandleGuildROSTER(InPkt: YNwClientPacket);
      procedure HandleGuildINVITE(InPkt: YNwClientPacket);
      procedure HandleGuildACCEPT(InPkt: YNwClientPacket);
      procedure HandleGuildDECINE(InPkt: YNwClientPacket);
      procedure HandleGuildNOTE(InPkt: YNwClientPacket);
      procedure HandleGuildMOTD(InPkt: YNwClientPacket);
      procedure HandleGuildRANK(InPkt: YNwClientPacket);
      procedure HandleGuildPROMOTE(InPkt: YNwClientPacket);
      procedure HandleGuildDEMOTE(InPkt: YNwClientPacket);
      procedure HandleGuildINFO(InPkt: YNwClientPacket);
      procedure HandleGuildLEAVE(InPkt: YNwClientPacket);
      procedure HandleGuildREMOVE(InPkt: YNwClientPacket);
      procedure HandleGuildDISBAND(InPkt: YNwClientPacket);
      procedure HandleGuildLEADER(InPkt: YNwClientPacket);
      procedure HandleGuildUNK(InPkt: YNwClientPacket);

      procedure SessionLogOut(Event: TEventHandle; TimeDelta: UInt32);
      function CheckCharValidity(const Name: string; PlayerClass: YGameClass;
        PlayerRace: YGameRace): Boolean;
      procedure SendCharOperationCode(Error: UInt8);
      { Needed for player }
      function GetRealmName: string;
      function GetAccount: string;
      procedure SetAccount(const Acc: string);
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
      property Account: string read fAccount write SetAccount;
      property RealmName: string read fInThisRealm write fInThisRealm;
      property Socket: ISocketInterface read fSocket write fSocket;
    end;

implementation

uses
  Main,
  Math,
  MMSystem,
  Framework,
  Cores,
  Components.DataCore.CharTemplates,
  Components.GameCore.Channel,
  Components.GameCore.WowUnit,
  Components.GameCore.PacketBuilders,
  Components.GameCore.Area,
  Components.DataCore;

var
  Handlers: array of Pointer;
  OpcodeMax: Longword;

procedure RegisterOpcodeHandler(pMethodPtr: Pointer; lwOpcode: Longword);
begin
  if Longword(Length(Handlers)) <= lwOpcode then SetLength(Handlers, lwOpcode + 1);
  Handlers[lwOpcode] := pMethodPtr;
end;

{$IFNDEF ASM_OPTIMIZATIONS}
{ Delphi implementation }
function CallOpcodeHandler(cSession: YOpenSession; cPkt: YClientPacket; lwOpcode: Longword): Boolean;
type
  YOpcodeHandler = procedure(cPacket: YClientPacket) of object;
var
  pHandler: YOpcodeHandler;
begin
  if lwOpcode < OpcodeMax then
  begin
    if Handlers[lwOpcode] <> nil then
    begin
      with TMethod(pHandler) do
      begin
        Code := Handlers[lwOpcode];
        Data := cSession;
      end;
      pHandler(cPkt);
      Result := True;
    end else Result := False;
  end else Result := False;
end;

{$ELSE}
{ Asm implementation }
function CallOpcodeHandler(cSession: YGaSession; cPkt: YNwClientPacket; lwOpcode: Longword): Boolean;
asm
  PUSH  EBX
  { EAX = cSession }
  { EDX = cPkt }
  { ECX = lwOpcode }
  CMP   ECX, OpcodeMax                  { Compare the opcode to table length }
  JAE   @@NoHandler                     { Opcode exceeds table length }
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
  POP   EBX
end;
{$ENDIF}

procedure YGaSession.HandleCharCreateOpcode(InPkt: YNwClientPacket);
type
  { The structure we know the packet contains staticly after the client's account name }
  PPlayerData = ^YPlayerData;
  YPlayerData = packed record
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
  cPlayer: YGaPlayer;
  sName: string;
  pPlayerLook: PPlayerData;
begin
  { Read the account name first }
  sName := InPkt.ReadString;

  pPlayerLook := InPkt.GetCurrentReadPtr;
  { I may use GetCurrentReadPtr, because I won't be reading any more data }
  { Whoala, I didn't copy even one byte and have access to data I need }

  if not CheckCharValidity(sName, pPlayerLook^.&Class, pPlayerLook^.Race) then
  begin
    Exit;
  end;

  cPlayer := YGaPlayer(GameCore.CreateObject(otPlayer));
  try
    cPlayer.Session := Self;

    { Initialization of Data from Request }
    with pPlayerLook^ do
    begin
      cPlayer.Stats.Level := 0; { Char just created }
      cPlayer.Name := sName;
      cPlayer.Skin := Skin;
      cPlayer.Face := Face;
      cPlayer.HairStyle := HairStyle;
      cPlayer.HairColor := HairColor;
      cPlayer.FacialHair := FacialHair;

      { Adding Template Data }
      cPlayer.CreateFromTemplate(DataCore.CharTemplates, &Class, Race, Gender);
    end;
    cPlayer.SaveToDataBase;
  finally
    cPlayer.Free;
  end;

  SendCharOperationCode(CHAR_OPERATION_SUCCESS);
end;

procedure YGaSession.HandleCharDeleteOpcode(InPkt: YNwClientPacket);
var
  pGuid: PObjectGuid;
  cPlr: YDbPlayerEntry;
  iIdx: Int32;
begin
  pGuid := InPkt.GetCurrentReadPtr;

  DataCore.Characters.LoadEntry(pGuid^.Longs[0], cPlr);
  if cPlr = nil then
  begin
    SendCharOperationCode(CHAR_DELETE_FAILED);
    Exit;
  end;
  { Load the player info }
  for iIdx := 0 to ITEMS_END do
  begin
    if cPlr.EquippedItems[iIdx] <> 0 then
    begin
      { If slot GUID <> 0 }
      DataCore.Items.DeleteEntry(cPlr.EquippedItems[iIdx]);
      { then delete that item from the DB as well }
    end;
  end;
  DataCore.Characters.DeleteEntry(cPlr.UniqueID);
  { Finally delete the char itself }

  SendCharOperationCode(CHAR_OPERATION_SUCCESS);
end;

procedure YGaSession.HandleCharEnumOpcode(InPkt: YNwClientPacket);
var
  aList: array of YDbPlayerEntry;
  cOutPkt: YNwServerPacket;
  iX, iY: Int32;
  cPlayer: YDbPlayerEntry;
  cItem: YDbItemEntry;
  cTemp: YDbItemTemplate;

  function ExtractUInt8(cPlr: YDbPlayerEntry; iIndex: UInt32; iPos: UInt8): UInt8; inline;
  begin
    Result := LongRec(cPlr.UpdateData[iIndex]).Bytes[iPos];
  end;

  function ExtractUInt32(cPlr: YDbPlayerEntry; iIndex: UInt32): UInt32; inline;
  begin
    Result := cPlr.UpdateData[iIndex];
  end;
begin
  DataCore.Characters.LoadEntryList(FIELD_PLI_ACCOUNT_NAME, fAccount, YDbSerializables(aList));
  cOutPkt := YNwServerPacket.Initialize(SMSG_CHAR_ENUM);
  try
    { Character Count }
    cOutPkt.AddUInt8(Length(aList));
  
    for iX := 0 to Length(aList) - 1 do
    begin
      cPlayer := aList[iX];
  
      cOutPkt.AddUInt32(cPlayer.UpdateData[OBJECT_FIELD_GUID]);
      cOutPkt.AddUInt32(cPlayer.UpdateData[OBJECT_FIELD_GUID+1]);
      cOutPkt.AddString(cPlayer.CharName);
  
      cOutPkt.AddUInt8(ExtractUInt8(cPlayer, UNIT_FIELD_BYTES_0, BYTE_RACE));
      cOutPkt.AddUInt8(ExtractUInt8(cPlayer, UNIT_FIELD_BYTES_0, BYTE_CLASS));
      cOutPkt.AddUInt8(ExtractUInt8(cPlayer, UNIT_FIELD_BYTES_0, BYTE_GENDER));
  
      { Visual Aspects }
      cOutPkt.AddUInt8(ExtractUInt8(cPlayer, PLAYER_BYTES, BYTE_SKIN));
      cOutPkt.AddUInt8(ExtractUInt8(cPlayer, PLAYER_BYTES, BYTE_FACE));
      cOutPkt.AddUInt8(ExtractUInt8(cPlayer, PLAYER_BYTES, BYTE_HSTYLE));
      cOutPkt.AddUInt8(ExtractUInt8(cPlayer, PLAYER_BYTES, BYTE_HCOLOR));
      cOutPkt.AddUInt8(ExtractUInt8(cPlayer, PLAYER_BYTES_2, BYTE_FHAIR));
  
      cOutPkt.AddUInt8(ExtractUInt32(cPlayer, UNIT_FIELD_LEVEL));
      cOutPkt.AddUInt32(cPlayer.ZoneId);
      cOutPkt.AddUInt32(cPlayer.MapId);
  
      cOutPkt.AddFloat(cPlayer.PosX);
      cOutPkt.AddFloat(cPlayer.PosY);
      cOutPkt.AddFloat(cPlayer.PosZ);

      {
      @OLD:
      cOutPkt.AddUInt32(ExtractUInt32(cPlayer, PLAYER_GUILDID));
      cOutPkt.AddUInt32(ExtractUInt32(cPlayer, PLAYER_GUILDRANK));

      @NEW: Not sure if its correct.
      }
      cOutPkt.AddUInt32(ExtractUInt32(cPlayer, PLAYER_GUILDID));
      cOutPkt.AddUInt8(0);
      cOutPkt.AddUInt8(ExtractUInt32(cPlayer, PLAYER_GUILDRANK));
      cOutPkt.AddUInt8(0);
      cOutPkt.AddUInt8(0);

      cOutPkt.AddUInt8(cPlayer.Rested);
      cOutPkt.AddUInt32(0); { Pet ID }
      cOutPkt.AddUInt32(0); { Pet level }
      cOutPkt.AddUInt32(0); { Pet family }
  
      for iY := 0 to EQUIPMENT_SLOT_END + 1 do
      begin
        if cPlayer.EquippedItems[iY] <> 0 then
        begin
          DataCore.Items.LoadEntry(cPlayer.EquippedItems[iY], cItem);
          if cItem <> nil then
          begin
            DataCore.ItemTemplates.LoadEntry(cItem.Entry, cTemp);
            if cTemp <> nil then
            begin
              cOutPkt.AddUInt32(cTemp.ModelId);
              cOutPkt.AddUInt8(UInt8(cTemp.InventoryType));
            end else cOutPkt.Jump(5);
            DataCore.ItemTemplates.ReleaseEntry(cTemp);
          end else cOutPkt.Jump(5);
        end else cOutPkt.Jump(5);
      end;
    end;
  
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
    DataCore.Characters.ReleaseEntryList(YDbSerializables(aList));
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
    tTime: YDayTime;
  begin
    tTime.Hours := DivModU(DateTimeToTimeStamp(Now).Time div 60000, 60, tTime.Minutes);
    Result := (tTime.Hours shl 6) + tTime.Minutes;
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
  pGuid: PObjectGuid;
  cOutPkt: YNwServerPacket;
  sMOTD, sRealmName: string;
  cAcc: YDbAccountEntry;
  iCinematic, iX, iBaseIndex: UInt32;
  cGuild: YGaGuild;
begin
  { Get the GUID of the player to login }
  pGuid := InPkt.GetCurrentReadPtr;

  fLoggedInPlayer.Free; { If not nil, then free }

  fLoggedInPlayer := YGaPlayer(GameCore.CreateObject(otPlayer, True));
  fLoggedInPlayer.Session := Self;
  fLoggedInPlayer.GUIDLo := pGuid^.Longs[0];
  fLoggedInPlayer.GUIDHi := pGuid^.Longs[1];
  fLoggedInPlayer.LoadFromDataBase;

  { Now send all required data to this player }

  {$IFDEF WOW_TBC}
  cOutPkt := YServerPacket.Initialize(SMSG_WOW_TBC_AUTH_INFO);
  try
    cOutPkt.Jump(4);
    cOutPkt.AddUInt8(1);
    cOutPkt.Jump(7);
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;

  cOutPkt := YServerPacket.Initialize(SMSG_LOGIN_VERIFY_WORLD);
  try
    cOutPkt.Jump(20);
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
  {$ENDIF}

  cOutPkt := YNwServerPacket.Initialize(SMSG_ACCOUNT_DATA_MD5);
  try
    {$IFNDEF WOW_TBC}
    cOutPkt.Jump(80);
    {$ENDIF}
    {$IFDEF WOW_TBC}
    cOutPkt.Jump(128);
    {$ENDIF}
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;

  {$IFDEF WOW_TBC}
  cOutPkt := YServerPacket.Initialize(SMSG_WOW_TBC_UNK);
  try
    cOutPkt.Jump(4);
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
  {$ENDIF}

  cOutPkt := YNwServerPacket.Initialize(SMSG_SET_REST_START);
  try
    cOutPkt.Jump(4);
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;

  cOutPkt := YNwServerPacket.Initialize(SMSG_BINDPOINTUPDATE);
  try
    cOutPkt.AddStruct(fLoggedInPlayer.Position.Vector, 12); { Ignore orientation }
    cOutPkt.AddUInt32(fLoggedInPlayer.Position.MapId);
    cOutPkt.AddUInt32(fLoggedInPlayer.Position.ZoneId);
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;

  cOutPkt := YNwServerPacket.Initialize(SMSG_INITIAL_SPELLS);
  try
    cOutPkt.AddUInt8(0);
    cOutPkt.AddUInt16(0);
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;

  cOutPkt := YNwServerPacket.Initialize(SMSG_LOGIN_SETTIMESPEED);
  try
    cOutPkt.AddUInt32(GetPackedTime);
    cOutPkt.AddFloat(0.017);
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;

  cOutPkt := YNwServerPacket.Initialize(SMSG_INITIALIZE_FACTIONS);
  try
    cOutPkt.AddUInt32($40);
    //for iX := 1 to 64 do begin cOutPkt.AddUInt8(0); cOutPkt.AddUInt32(0); end;
    cOutPkt.Jump(320);
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;

  // Tutorials

  fLoggedInPlayer.Tutorials.SendTutorialsStatus;

  //CINEMATIC implementation
   
  if fLoggedInPlayer.Stats.Level = 0 then
  begin
    fLoggedInPlayer.Stats.Level := 1;
    fLoggedInPlayer.SetUInt32(PLAYER_XP, 0);
    fLoggedInPlayer.SetUInt32(PLAYER_NEXT_LEVEL_XP, 400);
    fLoggedInPlayer.SetUInt8(PLAYER_BYTES_3, 0, UInt8(fLoggedInPlayer.Stats.Gender));
    { This is set not to display that faction bar}

    iCinematic := GetCinematicByRace(fLoggedInPlayer.Stats.Race);
    if iCinematic <> 0 then
    begin
      cOutPkt := YNwServerPacket.Initialize(SMSG_TRIGGER_CINEMATIC);
      try
        cOutPkt.AddUInt32(iCinematic);
        SendPacket(cOutPkt);
      finally
        cOutPkt.Free;
      end;
    end;
    fLoggedInPlayer.SaveToDatabase;
  end;

  { Plug player into world }
  fLoggedInPlayer.ChangeWorldState(wscAdd);
  sMOTD := SystemConfiguration.StringValue['Realm', 'MOTD'];
  sRealmName := SystemConfiguration.StringValue['Realm', 'Name'];

  if sRealmName = '' then sRealmName := 'Unknown Realm name';
  fLoggedInPlayer.InRealmName := sRealmName;

  if sMOTD = '' then sMOTD := '{$VER}';
  sMOTD := StringReplace(sMOTD, '{$VER}', ProgramVersion, [rfReplaceAll]);
  sMOTD := StringReplace(sMOTD, '{$RLM}', sRealmName, [rfReplaceAll]);

  fLoggedInPlayer.Chat.SystemMessage(sMOTD);
  fLoggedInPlayer.Chat.SystemMessageColored(WelcomeMsg, MSG_COLOR_LIME);
  fLoggedInPlayer.Chat.SystemMessageColored(NiceDay, MSG_COLOR_CORAL);

  { Player has just autocreated this account, ask him to change his password }
  DataCore.Accounts.LoadEntry(FIELD_ACC_NAME, fAccount, cAcc);
  if cAcc.AutoCreated then
  begin
    fLoggedInPlayer.Chat.SystemMessageColored(SetPass, MSG_COLOR_WHITE);
  end;
  DataCore.Accounts.ReleaseEntry(cAcc);

  fLoggedInPlayer.ActionBtns.SendActionButtons;

  { Guild Part }

  if fLoggedInPlayer.Guild.ID <> 0 then  { Player has guild id saved }
  begin
    cGuild := GameCore.Guilds[fLoggedInPlayer.Guild.ID];
    fLoggedInPlayer.Guild.Entry := cGuild;
    cGuild.Sign(fLoggedInPlayer, 1);
  end;
      
  for iX := 0 to QUEST_LOG_COUNT - 1 do
  begin
    with fLoggedInPlayer.Quests.ActiveQuests do
    begin
      iBaseIndex := PLAYER_QUEST_LOG_1_1 + iX * 3;
      fLoggedInPlayer.SetUInt32(iBaseIndex, Quests[iX].Id);
      fLoggedInPlayer.SetUInt32(iBaseIndex + 1, Quests[iX].KillObjectives[0]);
      fLoggedInPlayer.SetUInt32(iBaseIndex + 2, Quests[iX].KillObjectives[1]);
    end;
  end;
end;

function YGaSession.CheckCharValidity(const Name: string; PlayerClass: YGameClass;
  PlayerRace: YGameRace): Boolean;
var
  aChars: array of YDbPlayerEntry;
  iC: Int32;
  iCCount: Int32;
  iCRace: YGameRace;
  cPlr: YDbPlayerEntry;
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

  for iC := 1 to Length(Name) do
  begin
    if not (Name[iC] in ['A'..'Z', 'a'..'z']) then
    begin
      SendCharOperationCode(CHAR_ONLY_LETTERS);
      Exit;
    end;
  end;

  if UpperCase(SystemConfiguration.StringValue['Realm', 'Type']) = 'PVP' then
  begin
    { This is a PvP realm! Let's see if the user has an account of a different faction }
    DataCore.Characters.LoadEntryList(FIELD_PLI_ACCOUNT_NAME, fAccount, YDbSerializables(aChars));
    for iC := 0 to Length(aChars) - 1 do
    begin

      { Extracting the Race from Update Data }
      cPlr := aChars[iC];
      iCRace := YGameRace(LongRec(cPlr.UpdateData[UNIT_FIELD_BYTES_0]).Bytes[BYTE_RACE]);
      { ... }

      if FactionDiffers(iCRace, PlayerRace) then
      begin
        SendCharOperationCode(CHAR_PVP_SERVER);
        DataCore.Characters.ReleaseEntryList(YDbSerializables(aChars));
        Exit;
      end;
    end;
    DataCore.Characters.ReleaseEntryList(YDbSerializables(aChars));
  end;

  iCCount := DataCore.Characters.CountEntries(FIELD_PLI_CHAR_NAME, Name);

  if iCCount > 0 then
  begin
    SendCharOperationCode(CHAR_EXISTS);
    Exit;
  end;

  iCCount := DataCore.Characters.CountEntries(FIELD_PLI_ACCOUNT_NAME, fAccount);
  if iCCount >= SystemConfiguration.GetIntegerValue('Realm', 'MaxChars') then
  begin
    SendCharOperationCode(CHAR_FULL_LIST);
    Exit;
  end;

  if DataCore.ProfanityList.IndexOf(Name) <> -1 then
  begin
    SendCharOperationCode(CHAR_PROFANITY);
    Exit;
  end else if DataCore.ReservedNamesList.IndexOf(Name) <> -1 then
  begin
    SendCharOperationCode(CHAR_NAME_UNAVAILABLE);
    Exit;
  end;

  Result := True;
end;

procedure YGaSession.SendCharOperationCode(Error: UInt8);
var
  cOutPkt: YNwServerPacket;
begin
  cOutPkt := YNwServerPacket.Initialize(SMSG_CHAR_CREATE);
  try
    cOutPkt.AddUInt8(Error);
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
end;

procedure YGaSession.HandleNameQuery(InPkt: YNwClientPacket);
var
  pGuid: PObjectGuid;
  cPlr: YDbPlayerEntry;
  lwData: Longword;
  cOutPkt: YNwServerPacket;
begin
  pGuid := InPkt.GetCurrentReadPtr;

  DataCore.Characters.LoadEntry(pGUID^.Longs[0], cPlr);

  cOutPkt := YNwServerPacket.Initialize(SMSG_NAME_QUERY_RESPONSE);
  try
    cOutPkt.AddPtrData(pGuid, 8);
    if cPlr <> nil then
    begin
      cOutPkt.AddString(cPlr.CharName);

      if fLoggedInPlayer.InBattleGround then
      begin
        cOutPkt.AddString(fLoggedInPlayer.InRealmName);
      end else
      begin
        cOutPkt.JumpUInt8;
      end;

      lwData := cPlr.UpdateData[UNIT_FIELD_BYTES_0];
      cOutPkt.AddUInt8(LongRec(lwData).Bytes[BYTE_RACE]);
      cOutPkt.AddUInt8(LongRec(lwData).Bytes[BYTE_GENDER]);
      cOutPkt.AddUInt8(LongRec(lwData).Bytes[BYTE_CLASS]);
    end else
    begin
      cOutPkt.AddString('Unknown Player');
      cOutPkt.JumpUInt32;      //last byte is to send null realm name (1.12.X+ only)
    end;

    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
end;

procedure YGaSession.HandleNoAction(InPkt: YNwClientPacket);
begin
  // it's just flood :) God damnit!
end;

procedure YGaSession.HandleItemNameQuery(InPkt: YNwClientPacket);
var
  iItemId: UInt32;
  cOutPkt: YNwServerPacket;
  cItem: YDbItemTemplate;
begin
  iItemId := InPkt.ReadUInt32;

  DataCore.ItemTemplates.LoadEntry(iItemId, cItem);
  cOutPkt := YNwServerPacket.Initialize(SMSG_ITEM_NAME_QUERY_RESPONSE);
  try
    if not Assigned(cItem) then
    begin
      cOutPkt.AddString(Format('Unknown Item - ID %d', [iItemId]));
      SendPacket(cOutPkt);
      Exit;
    end;

    if cItem.Name = '' then
    begin
      cOutPkt.AddString(Format('Unknown Item - ID %d', [iItemId]))
    end else
    begin
      cOutPkt.AddString(cItem.Name);
    end;

    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
end;

procedure YGaSession.HandleCreatureQuery(InPkt: YNwClientPacket);
var
  cOutPkt: YNwServerPacket;
  cCrTemplate: YDbCreatureTemplate;
  iEntry: UInt32;
begin
  iEntry := InPkt.ReadUInt32;

  DataCore.CreatureTemplates.LoadEntry(iEntry, cCrTemplate);
  cOutPkt := YNwServerPacket.Initialize(SMSG_CREATURE_QUERY_RESPONSE);
  try
    cOutPkt.AddUInt32(iEntry);

    if cCrTemplate <> nil then
    begin
      cOutPkt.AddString(cCrTemplate.EntryName);
      cOutPkt.Jump(3);
      cOutPkt.AddUInt32(cCrTemplate.UnitFlags);
      cOutPkt.AddUInt32(cCrTemplate.UnitType);
      cOutPkt.AddUInt32(cCrTemplate.Family);
      cOutPkt.AddUInt32(cCrTemplate.Rank);
      cOutPkt.Jump(8);
      cOutPkt.AddUInt32(cCrTemplate.TextureID);
      cOutPkt.AddUInt32(cCrTemplate.Civilian);
      cOutPkt.Jump(4);
    end else
    begin
      cOutPkt.AddString('Unknown entity');
      cOutPkt.Jump(39);
    end;
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
end;

procedure YGaSession.HandleSheathedOpcode(InPkt: YNwClientPacket);
var
  iSheathed: UInt32;
begin
  iSheathed := InPkt.ReadUInt32;

  case iSheathed of
    SHEATH_MAIN:
    begin
      fLoggedInPlayer.ReSetBit(UNIT_FIELD_BYTES_2, UFB2_SHEATH_RANGED_WEAPONS);
      fLoggedInPlayer.SetBit(UNIT_FIELD_BYTES_2, UFB2_SHEATH_MAIN_WEAPONS);
    end;

    SHEATH_RANGED:
    begin
      fLoggedInPlayer.ReSetBit(UNIT_FIELD_BYTES_2, UFB2_SHEATH_MAIN_WEAPONS);
      fLoggedInPlayer.SetBit(UNIT_FIELD_BYTES_2, UFB2_SHEATH_RANGED_WEAPONS);
    end;

    SHEATH_NONE:
    begin
      fLoggedInPlayer.ReSetBit(UNIT_FIELD_BYTES_2, UFB2_SHEATH_RANGED_WEAPONS);
      fLoggedInPlayer.ReSetBit(UNIT_FIELD_BYTES_2, UFB2_SHEATH_MAIN_WEAPONS);
    end;

    else
      begin
        fLoggedInPlayer.Chat.SystemMessage(Format('Unknown Sheath code : %d', [iSheathed]));
        //Assert(False, 'UNKNOWN Sheath code. Please inform developers');
      end;
  end;  
end;

procedure YGaSession.HandleItemQuerySingle(InPkt: YNwClientPacket);
var
  iEntryId: UInt32;
  cOutPkt: YNwServerPacket;
  cTemplate: YDbItemTemplate;
begin
  iEntryId := InPkt.ReadUInt32;
  cOutPkt := YNwServerPacket.Initialize(SMSG_ITEM_QUERY_SINGLE_RESPONSE);
  try
    DataCore.ItemTemplates.LoadEntry(iEntryId, cTemplate);

    if cTemplate <> nil then
    begin
      cTemplate.FillItemTemplateInfoBuffer(cOutPkt);
    end else
    begin
      cOutPkt.AddUInt32(iEntryId);
      cOutPkt.Jump(456);
      IoCore.Console.WriteMultiple(['Item query failed - entry ', IntToStr(iEntryId), ' is not declared'],
        [CLR_ATTENTION, CLR_INFO, CLR_ATTENTION]);
    end;

    DataCore.ItemTemplates.ReleaseEntry(cTemplate);
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
end;

procedure YGaSession.HandleTimeQuery(InPkt: YNwClientPacket);
var
  cOutPkt: YNwServerPacket;
begin
  cOutPkt := YNwServerPacket.Initialize(SMSG_QUERY_TIME_RESPONSE);
  try
    cOutPkt.AddUInt32(TimeGetTime);
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
end;

procedure YGaSession.HandleNextMailTimeQuery(InPkt: YNwClientPacket);
var
  cOutPkt: YNwServerPacket;
begin
  { Add mail support in the future }
  cOutPkt := YNwServerPacket.Initialize(MSG_QUERY_NEXT_MAIL_TIME);
  try
    //if fLoggedInPlayer.Mail.HasMail then
    //begin
      //cOutPkt.Jump(4);
    //end else
    //begin
      cOutPkt.AddUInt32($C7A8C000);
    //end;
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
end;

procedure YGaSession.TutorialManipulation(InPkt: YNwClientPacket);
var
  iIndex: UInt32;
begin
  case InPkt.Header^.Opcode of
    CMSG_TUTORIAL_FLAG:
    begin
      iIndex := InPkt.ReadUInt32;
      fLoggedInPlayer.Tutorials.Tutorials[iIndex] := True;
    end;
    CMSG_TUTORIAL_CLEAR: fLoggedInPlayer.Tutorials.MarkReadAllTutorials;
    CMSG_TUTORIAL_RESET: fLoggedInPlayer.Tutorials.MarkUnreadAllTutorials;
  end;
end;

procedure YGaSession.BufferLockAcquire;
begin
  fSocket.QueueLockAcquire;
end;

procedure YGaSession.BufferLockRelease;
begin
  fSocket.QueueLockRelease;
end;

procedure YGaSession.ChatManipulation(InPkt: YNwClientPacket);
begin
  fLoggedInPlayer.Chat.HandleChatMessage(InPkt);
end;

procedure YGaSession.HandleChannelJoin(InPkt: YNwClientPacket);
var
  sName, sPass: string;
begin
  sName := InPkt.ReadString;
  sPass := InPkt.ReadString;

  GameCore.TryJoinChannel(fLoggedInPlayer, sName, sPass);
end;

procedure YGaSession.HandleChannelLeave(InPkt: YNwClientPacket);
var
  sName: string;
begin
  sName := InPkt.ReadString;
  GameCore.LeaveChannel(fLoggedInPlayer, sName);
end;

procedure YGaSession.HandleChannelListRequest(InPkt: YNwClientPacket);
var
  sName: string;
  cChannel: YGaChannel;
begin
  sName := InPkt.ReadString;
  cChannel := GameCore.GetChannelByName(fLoggedInPlayer, sName);
  if cChannel <> nil then
  begin
    cChannel.ListRequest(fLoggedInPlayer);
  end;
end;

procedure YGaSession.HandleChannelPasswordSet(InPkt: YNwClientPacket);
var
  sName: string;
  sPass: string;
  cChannel: YGaChannel;
begin
  sName := InPkt.ReadString;
  sPass := InPkt.ReadString;

  cChannel := GameCore.GetChannelByName(fLoggedInPlayer, sName);
  if cChannel <> nil then
  begin
    cChannel.ChangePassword(fLoggedInPlayer, sPass);
  end;
end;

procedure YGaSession.HandleChannelOwnerSet(InPkt: YNwClientPacket);
var
  sName: string;
  sPlayer: string;
  cChannel: YGaChannel;
begin
  sName := InPkt.ReadString;
  sPlayer := InPkt.ReadString;

  cChannel := GameCore.GetChannelByName(fLoggedInPlayer, sName);
  if cChannel <> nil then
  begin
    cChannel.ChangeOwner(fLoggedInPlayer, sPlayer);
  end;
end;

procedure YGaSession.HandleChannelOwnerGet(InPkt: YNwClientPacket);
var
  sName: string;
  cChannel: YGaChannel;
begin
  sName := InPkt.ReadString;

  cChannel := GameCore.GetChannelByName(fLoggedInPlayer, sName);
  if cChannel <> nil then
  begin
    cChannel.QueryOwner(fLoggedInPlayer);
  end;
end;

procedure YGaSession.HandleChannelPromote(InPkt: YNwClientPacket);
var
  sName: string;
  sPlayer: string;
  cChannel: YGaChannel;
begin
  sName := InPkt.ReadString;
  sPlayer := InPkt.ReadString;

  cChannel := GameCore.GetChannelByName(fLoggedInPlayer, sName);
  if cChannel <> nil then
  begin
    cChannel.ChangeModerateRight(fLoggedInPlayer, sPlayer, True);
  end;
end;

procedure YGaSession.HandleChannelDepromote(InPkt: YNwClientPacket);
var
  sName: string;
  sPlayer: string;
  cChannel: YGaChannel;
begin
  sName := InPkt.ReadString;
  sPlayer := InPkt.ReadString;

  cChannel := GameCore.GetChannelByName(fLoggedInPlayer, sName);
  if cChannel <> nil then
  begin
    cChannel.ChangeModerateRight(fLoggedInPlayer, sPlayer, False);
  end;
end;

procedure YGaSession.HandleChannelMute(InPkt: YNwClientPacket);
var
  sName: string;
  sPlayer: string;
  cChannel: YGaChannel;
begin
  sName := InPkt.ReadString;
  sPlayer := InPkt.ReadString;

  cChannel := GameCore.GetChannelByName(fLoggedInPlayer, sName);
  if cChannel <> nil then
  begin
    cChannel.ChangeMutedRight(fLoggedInPlayer, sPlayer, True);
  end;
end;

procedure YGaSession.HandleChannelUnmute(InPkt: YNwClientPacket);
var
  sName: string;
  sPlayer: string;
  cChannel: YGaChannel;
begin
  sName := InPkt.ReadString;
  sPlayer := InPkt.ReadString;

  cChannel := GameCore.GetChannelByName(fLoggedInPlayer, sName);
  if cChannel <> nil then
  begin
    cChannel.ChangeMutedRight(fLoggedInPlayer, sPlayer, False);
  end;
end;

procedure YGaSession.HandleChannelSendInvitiation(InPkt: YNwClientPacket);
var
  sName: string;
  sPlayer: string;
  cChannel: YGaChannel;
begin
  sName := InPkt.ReadString;
  sPlayer := InPkt.ReadString;

  cChannel := GameCore.GetChannelByName(fLoggedInPlayer, sName);
  if cChannel <> nil then
  begin
    cChannel.SendInvitation(fLoggedInPlayer, sPlayer);
  end;
end;

procedure YGaSession.HandleChannelKick(InPkt: YNwClientPacket);
var
  sName: string;
  sPlayer: string;
  cChannel: YGaChannel;
begin
  sName := InPkt.ReadString;
  sPlayer := InPkt.ReadString;

  cChannel := GameCore.GetChannelByName(fLoggedInPlayer, sName);
  if cChannel <> nil then
  begin
    cChannel.Kick(fLoggedInPlayer, sPlayer);
  end;
end;

procedure YGaSession.HandleChannelBan(InPkt: YNwClientPacket);
var
  sName: string;
  sPlayer: string;
  cChannel: YGaChannel;
begin
  sName := InPkt.ReadString;
  sPlayer := InPkt.ReadString;

  cChannel := GameCore.GetChannelByName(fLoggedInPlayer, sName);
  if cChannel <> nil then
  begin
    cChannel.ChangeBanRight(fLoggedInPlayer, sPlayer, True);
  end;
end;

procedure YGaSession.HandleChannelUnban(InPkt: YNwClientPacket);
var
  sName: string;
  sPlayer: string;
  cChannel: YGaChannel;
begin
  sName := InPkt.ReadString;
  sPlayer := InPkt.ReadString;

  cChannel := GameCore.GetChannelByName(fLoggedInPlayer, sName);
  if cChannel <> nil then
  begin
    cChannel.ChangeBanRight(fLoggedInPlayer, sPlayer, False);
  end;
end;

procedure YGaSession.HandleChannelToggleAnnounce(InPkt: YNwClientPacket);
var
  sName: string;
  cChannel: YGaChannel;
begin
  sName := InPkt.ReadString;

  cChannel := GameCore.GetChannelByName(fLoggedInPlayer, sName);
  if cChannel <> nil then
  begin
    cChannel.ChangeChannelFlag(fLoggedInPlayer, cfAnnounce, not cChannel.IsAnnounce);
  end;
end;

procedure YGaSession.HandleChannelToggleModerated(InPkt: YNwClientPacket);
var
  sName: string;
  cChannel: YGaChannel;
begin
  sName := InPkt.ReadString;
  
  cChannel := GameCore.GetChannelByName(fLoggedInPlayer, sName);
  if cChannel <> nil then
  begin
    cChannel.ChangeChannelFlag(fLoggedInPlayer, cfModerated, not cChannel.IsModerated);
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
  pMoveData: PMovementData;
  cOutPkt: YNwServerPacket;
  cOutPkt2: YNwServerPacket;
  lwDmg: UInt32;
  tVec: TVector;
begin
  pMoveData := InPkt.GetCurrentReadPtr;

  if (pMoveData^.Flags and MOVE_FLAG_FALL) <> 0 then
  begin
    if (fLoggedInPlayer.Stats.Health > 0) and (pMoveData^.FallTime >= 2000) then
    begin
      { The fall time of 1000 (ms) correspondents to 1.0 sec of falling - that's not much
        but it's a good number for testing purposes. }
      lwDmg := ((pMoveData^.FallTime - 2000) div 100) + 1;
      cOutPkt2 := YNwServerPacket.Initialize(SMSG_ENVIRONMENTALDAMAGELOG);
      try
        cOutPkt2.AddPtrData(fLoggedInPlayer.GUID, 8);
        cOutPkt2.AddUInt8(2);
        cOutPkt2.AddUInt32(lwDmg);
        cOutPkt2.Skip(8);
        SendPacket(cOutPkt2);
      finally
        cOutPkt2.Free;
      end;
    
      if fLoggedInPlayer.Stats.ArmorResist < lwDmg then    //TODO - it's a test. I hope I will remember to remove it :)
        fLoggedInPlayer.Stats.Health := fLoggedInPlayer.Stats.Health - lwDmg;
    end;
  end;

  cOutPkt := YNwServerPacket.Initialize(InPkt.Header^.Opcode, 9 + InPkt.Size);
  try
    cOutPkt.AddPackedGUID(fLoggedInPlayer.GUID);
    cOutPkt.AddPtrData(pMoveData, InPkt.Size);

    MakeVector(tVec, pMoveData^.X, pMoveData^.Y, pMoveData^.Z);
    GameCore.CheckObjectRellocation(fLoggedInPlayer, tVec, pMoveData^.Angle, cOutPkt);
  finally
    cOutPkt.Free;
  end;

  { TODO -oTheSelby -cMovement : Add water and terain checks, stuff like that... lava checks, etc (when the time for that comes) }
end;

//procedure YOpenSession.HandleMoveTimeSkipped(cPkt: YClientPacket);
//begin
//  Writeln(cPkt.ReadUInt32);
//end;

procedure YGaSession.LogoutManipulation(InPkt: YNwClientPacket);
var
  cOutPacket: YNwServerPacket;
begin
  case InPkt.Header^.Opcode of
    CMSG_LOGOUT_REQUEST:
    begin
      fLogoutTimerHandle := SystemTimer.RegisterEvent(SessionLogOut, 20000,
        TICK_EXECUTE_ONCE, 'GaSession_SessionLogoutRequestTimer');

      fLoggedInPlayer.OrUInt32(UNIT_FIELD_BYTES_1, UNIT_STATE_SIT);
      fLoggedInPlayer.OrUInt32(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_ROOTED);

      cOutPacket := YNwServerPacket.Initialize(SMSG_LOGOUT_RESPONSE);
      try
        cOutPacket.Jump(5);
        SendPacket(cOutPacket);
      finally
        cOutPacket.Free;
      end;

      cOutPacket := YNwServerPacket.Initialize(SMSG_FORCE_MOVE_ROOT);
      try
        cOutPacket.AddPackedGUID(fLoggedInPlayer.GUID);
        cOutPacket.AddUInt32(2);
        SendPacket(cOutPacket);
      finally
        cOutPacket.Free;
      end;
    end;
    CMSG_LOGOUT_CANCEL:
    begin
      if fLogoutTimerHandle <> nil then
      begin
        fLogoutTimerHandle.Unregister;
        fLogoutTimerHandle := nil;

        fLoggedInPlayer.ReplaceUInt32(UNIT_FIELD_BYTES_1, UNIT_STATE_SIT, UNIT_STATE_STAND);
        fLoggedInPlayer.AndNotUInt32(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_ROOTED);

        cOutPacket := YNwServerPacket.Initialize(SMSG_FORCE_MOVE_UNROOT);
        try
          cOutPacket.AddPackedGUID(fLoggedInPlayer.GUID);
          SendPacket(cOutPacket);
        finally
          cOutPacket.Free;
        end;

        cOutPacket := YNwServerPacket.Initialize(SMSG_LOGOUT_CANCEL_ACK);
        try
          SendPacket(cOutPacket);
        finally
          cOutPacket.Free;
        end;
      end;
    end;
  end;
end;

procedure YGaSession.HandleStandStateChange(InPkt: YNwClientPacket);
var
  lwTemp: Longword;
begin
  with fLoggedInPlayer do
  begin
    lwTemp := GetUInt32(UNIT_FIELD_BYTES_1);
    LongRec(lwTemp).Bytes[0] := 0;
    SetUInt32(UNIT_FIELD_BYTES_1, lwTemp or Longword(InPkt.ReadUInt8));
  end;
end;

procedure YGaSession.HandleSetSelection(InPkt: YNwClientPacket);
var
  pGUID: PObjectGUID;
begin
  pGUID := InPkt.GetCurrentReadPtr;
  fLoggedInPlayer.SetUInt64(UNIT_FIELD_TARGET, pGUID^.Full);
end;

  {$REGION 'Items handlers'}
procedure YGaSession.HandleSwapInvItem(InPkt: YNwClientPacket);
var
  iSlotSrc, iSlotDest: UInt8;
begin
  iSlotSrc := InPkt.ReadUInt8;
  iSlotDest := InPkt.ReadUInt8;
  fLoggedInPlayer.Equip.InventoryChange(iSlotSrc, iSlotDest);
end;

procedure YGaSession.HandleSwapItem(InPkt: YNwClientPacket);
var
  iSlotSrc, iSlotDest, iBagSrc, iBagDest: UInt8;
begin
  iBagDest := InPkt.ReadUInt8;
  iSlotDest := InPkt.ReadUInt8;
  iBagSrc := InPkt.ReadUInt8;
  iSlotSrc := InPkt.ReadUInt8;
  fLoggedInPlayer.Equip.InventoryChange(iSlotSrc, iSlotDest, iBagSrc, iBagDest);
end;

procedure YGaSession.HandleAutoEquipItem(InPkt: YNwClientPacket);
var
  iBagSrc, iSlotSrc: UInt8;
begin
  iBagSrc := InPkt.ReadUInt8;
  iSlotSrc := InPkt.ReadUInt8;
  fLoggedInPlayer.Equip.TryEquipItem(iSlotSrc, iBagSrc);
end;

procedure YGaSession.HandleAutoStoreBagItem(InPkt: YNwClientPacket);
var
  iBagSrc, iSlotSrc, iBagDest: UInt8;
begin
  iBagSrc := InPkt.ReadUInt8;
  iSlotSrc := InPkt.ReadUInt8;
  iBagDest := InPkt.ReadUInt8;
  fLoggedInPlayer.Equip.AutoStoreItem(iBagSrc, iSlotSrc, iBagDest);
end;

procedure YGaSession.HandleSetAmmo(InPkt: YNwClientPacket);
var
  iAmmo: UInt32;
begin
  iAmmo := InPkt.ReadUInt32;
  fLoggedInPlayer.SetUInt32(PLAYER_AMMO_ID, iAmmo);
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
  fLoggedInPlayer.Equip.SplitItems(iBagSrc, iSlotSrc, iBagDest, iSlotDest, iCount);
  {TODO 1 -oBIGBOSS -cItems : Send error if SplitCount>ItemCount etc}
end;

procedure YGaSession.HandleUseItem(InPkt: YNwClientPacket);
var
  iBag, iSlot: UInt8;
begin
  iBag := InPkt.ReadUInt8;
  iSlot := InPkt.ReadUInt8;
  fLoggedInPlayer.Chat.SystemMessage('Item on slot '+IntToStr(iSlot)+'(Bag '+IntToStr(iBag)+') was used');
end;

procedure YGaSession.HandleDestroyItem(InPkt: YNwClientPacket);
var
  iBag, iSlot: UInt8;
begin
  iBag := InPkt.ReadUInt8;
  iSlot := InPkt.ReadUInt8;
  fLoggedInPlayer.Equip.DeleteItem(iBag, iSlot, True);
end;

{$ENDREGION}

procedure YGaSession.HandleMoveWorldPortACK(InPkt: YNwClientPacket);
begin
  fLoggedInPlayer.ChangeWorldState(wscEnter);
end;

procedure SendTradeStatus(cPlayer: YGaPlayer; iTradeStatus: UInt8);
var
  OutPkt: YNwServerPacket;
begin
  if cPlayer.Trade.Trader = nil then Exit;
    
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
  iX: Integer;
begin
  if cPlayer.Trade.Trader = nil then Exit;

  OutPkt := YNwServerPacket.Initialize(SMSG_TRADE_STATUS_EXTENDED);
  try
    OutPkt.AddUInt8(1);   //??
    OutPkt.AddUInt32(7);  //??
    OutPkt.Jump(4);       //??
    OutPkt.AddUInt32(cPlayer.Trade.Copper);
    OutPkt.Jump(4);       //??
    for iX := 0 to 7 do with cPlayer.Trade.Items[iX] do
    begin
      OutPkt.AddUInt8(iX);
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
    cPlayer.Trade.Trader.Session.SendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;
end;

procedure YGaSession.HandleInitiateTrade(InPkt: YNwClientPacket);
var
  cOutPacket: YNwServerPacket;
  cOtherTrader: YGaPlayer;
begin
  
  { If you are dead }
  if fLoggedInPlayer.Stats.Health = 0 then
  begin
    SendTradeStatus(fLoggedInPlayer, TRADE_STATUS_YOU_DEAD);
    Exit;
  end;

  { Get the other trader }
  GameCore.FindObjectByGUID(otPlayer, InPkt.ReadUInt64, cOtherTrader);

  { If you try trading with yourself }
  if fLoggedInPlayer = cOtherTrader then
    Exit;

  { If the other trader doesn't exist }
  if cOtherTrader = nil then
  begin
    SendTradeStatus(fLoggedInPlayer, TRADE_STATUS_TRADER_NOT_FOUND);
    Exit;
  end;

  { If the other trader is busy }
  if cOtherTrader.Trade.Trader <> nil then
  begin
    SendTradeStatus(fLoggedInPlayer, TRADE_STATUS_BUSY);
    Exit;
  end;

  { If the other trader is dead }
  if cOtherTrader.Stats.Health = 0 then
  begin
    SendTradeStatus(fLoggedInPlayer, TRADE_STATUS_TRADER_DEAD);
    Exit;
  end;

  { Initiate the trade and assign the traders together }
  fLoggedInPlayer.Trade.Trader := cOtherTrader;
  cOtherTrader.Trade.Trader := fLoggedInPlayer;

  { Sends the packet that say OK for trade }
  cOutPacket := YNwServerPacket.Initialize(SMSG_TRADE_STATUS);
  try
    cOutPacket.AddUInt32(TRADE_STATUS_OK);
    cOutPacket.AddUInt64(fLoggedInPlayer.GUIDLo);
    cOtherTrader.Session.SendPacket(cOutPacket);
  finally
    cOutPacket.Free;
  end;
end;

procedure YGaSession.HandleBeginTrade(InPkt: YNwClientPacket);
begin
  if not Assigned(fLoggedInPlayer.Trade.Trader) then Exit;

  SendTradeStatus(fLoggedInPlayer, TRADE_STATUS_BEGIN);
  SendTradeStatus(fLoggedInPlayer.Trade.Trader, TRADE_STATUS_BEGIN);
end;

procedure YGaSession.HandleAcceptTrade(InPkt: YNwClientPacket);
var
  iX, iTMP: Int32;
  cItem1, cItem2: YGaItem;
  cErrorPkt: YNwServerPacket;
  cOther: YGaPlayer;
begin
  if not Assigned(fLoggedInPlayer.Trade.Trader) then Exit;

  cOther := fLoggedInPlayer.Trade.Trader;
  fLoggedInPlayer.Trade.Accept := True;
  SendTradeStatus(fLoggedInPlayer.Trade.Trader, TRADE_STATUS_ACCEPT);

  { If both are ready, then let's trade! }
  if cOther.Trade.Accept then
  begin
    {TODO 1 -oBIGBOSS -cItems : Send error if not enough space/money/bound etc}

    with fLoggedInPlayer do
    begin
      iTMP := Equip.Money - Trade.Copper + cOther.Trade.Copper;
      if iTMP < 0 then
      begin
        Equip.Money := 0;
        Exit;
        //not enough
      end else
      begin
        Equip.Money := iTMP;
      end;
      iTMP := cOther.Equip.Money - cOther.Trade.Copper + Trade.Copper;
      if iTMP < 0 then
      begin
        cOther.Equip.Money := 0;
        Exit;
        //not enough
      end else
      begin
        cOther.Equip.Money := iTMP;
      end;
      SetUInt32(PLAYER_FIELD_COINAGE, Equip.Money);
      cOther.SetUInt32(PLAYER_FIELD_COINAGE, cOther.Equip.Money);
      for iX := 0 to 5 do
      begin
        if Trade.Items[iX].iEntry <> MaxDword then
        begin
          cItem1 := Equip.DeleteItem(Trade.Items[iX].iBag, Trade.Items[iX].iSlot, False);
        end else
          cItem1 := nil;
        if cOther.Trade.Items[iX].iEntry <> MaxDword then
        begin
          cItem2 := cOther.Equip.DeleteItem(cOther.Trade.Items[iX].iBag, cOther.Trade.Items[iX].iSlot, False);
        end else
          cItem2 := nil;
        if Assigned(cItem2) then
        begin
          if Equip.AssignItem(cItem2) = INV_ERR_INVENTORY_FULL then
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
          if cOther.Equip.AssignItem(cItem1) = INV_ERR_INVENTORY_FULL then
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
    SendTradeStatus(fLoggedInPlayer, TRADE_STATUS_COMPLETE);

    cOther.Trade.Reset;
    fLoggedInPlayer.Trade.Reset;
  end;
end;

procedure YGaSession.HandleUnAcceptTrade(InPkt: YNwClientPacket);
begin
  if not Assigned(fLoggedInPlayer.Trade.Trader) then Exit;

  SendTradeStatus(fLoggedInPlayer.Trade.Trader, TRADE_STATUS_UNACCEPT);
  fLoggedInPlayer.Trade.Accept := False;
  fLoggedInPlayer.Trade.Trader.Trade.Accept := False;
end;

procedure YGaSession.HandleCancelTrade(InPkt: YNwClientPacket);
begin
  if not Assigned(fLoggedInPlayer.Trade) then Exit;
  if not Assigned(fLoggedInPlayer.Trade.Trader) then Exit;

  SendTradeStatus(fLoggedInPlayer.Trade.Trader, TRADE_STATUS_CANCEL);
  SendTradeStatus(fLoggedInPlayer, TRADE_STATUS_CANCEL);

  fLoggedInPlayer.Trade.Trader.Trade.Reset;
  fLoggedInPlayer.Trade.Reset;
end;

procedure YGaSession.HandleSetTradeItem(InPkt: YNwClientPacket);
var
  iTradeSlot, iBag, iSlot: Byte;
  cItem: YGaItem;
begin
  if not Assigned(fLoggedInPlayer.Trade.Trader) then Exit;

  if fLoggedInPlayer.Trade.Accept or fLoggedInPlayer.Trade.Trader.Trade.Accept then
  begin
    SendTradeStatus(fLoggedInPlayer.Trade.Trader, TRADE_STATUS_UNACCEPT);
    SendTradeStatus(fLoggedInPlayer, TRADE_STATUS_UNACCEPT);
    fLoggedInPlayer.Trade.Accept := False;
    fLoggedInPlayer.Trade.Trader.Trade.Accept := False;
  end;

  iTradeSlot := InPkt.ReadUInt8;
  iBag := InPkt.ReadUInt8;
  if iBag = BAG_NULL then
  begin
    iSlot := InPkt.ReadUInt8;
    cItem := fLoggedInPlayer.Equip.BackpackItems[ConvertAbsoluteSlotToRelative(iSlot, sctBackpack)];
  end else
  begin
    iSlot := InPkt.ReadUInt8;
    cItem := fLoggedInPlayer.Equip.Bags[iBag].Items[iSlot];
  end;
  if cItem = nil then
    Exit;
  fLoggedInPlayer.Trade.SetItem(iTradeSlot, iBag, iSlot, cItem.Entry, cItem.StackCount);
  UpdateTrade(fLoggedInPlayer);
end;

procedure YGaSession.HandleClearTradeItem(InPkt: YNwClientPacket);
var
  iTradeSlot: Byte;
begin
  if not Assigned(fLoggedInPlayer.Trade.Trader) then Exit;

  if fLoggedInPlayer.Trade.Accept or fLoggedInPlayer.Trade.Trader.Trade.Accept then
  begin
    SendTradeStatus(fLoggedInPlayer.Trade.Trader, TRADE_STATUS_UNACCEPT);
    SendTradeStatus(fLoggedInPlayer, TRADE_STATUS_UNACCEPT);
    fLoggedInPlayer.Trade.Accept := False;
    fLoggedInPlayer.Trade.Trader.Trade.Accept := False;
  end;

	iTradeSlot := InPkt.ReadUInt8;
  fLoggedInPlayer.Trade.SetItem(iTradeSlot, 0, 0, MaxInt, 0);
  UpdateTrade(fLoggedInPlayer);
end;

procedure YGaSession.HandleSetTradeGold(InPkt: YNwClientPacket);
var
  iCopper: UInt32;
begin
  if not Assigned(fLoggedInPlayer.Trade.Trader) then Exit;

  if fLoggedInPlayer.Trade.Accept or fLoggedInPlayer.Trade.Trader.Trade.Accept then
  begin
    SendTradeStatus(fLoggedInPlayer.Trade.Trader, TRADE_STATUS_UNACCEPT);
    SendTradeStatus(fLoggedInPlayer, TRADE_STATUS_UNACCEPT);
    fLoggedInPlayer.Trade.Accept := False;
    fLoggedInPlayer.Trade.Trader.Trade.Accept := False;
  end;

  iCopper := InPkt.ReadUInt32;
	if fLoggedInPlayer.Trade.Copper <> iCopper then begin
    fLoggedInPlayer.Trade.Copper := iCopper;
    UpdateTrade(fLoggedInPlayer);
  end;
end;

procedure YGaSession.HandleBusyTrade(InPkt: YNwClientPacket);
begin
  if not Assigned(fLoggedInPlayer.Trade.Trader) then Exit;

  SendTradeStatus(fLoggedInPlayer.Trade.Trader, TRADE_STATUS_IGNORE);

  fLoggedInPlayer.Trade.Trader.Trade.Reset;
  fLoggedInPlayer.Trade.Reset;
end;

procedure YGaSession.HandleIgnoreTrade(InPkt: YNwClientPacket);
begin
  if not Assigned(fLoggedInPlayer.Trade.Trader) then Exit;

  SendTradeStatus(fLoggedInPlayer.Trade.Trader, TRADE_STATUS_IGNORE);

  fLoggedInPlayer.Trade.Trader.Trade.Reset;
  fLoggedInPlayer.Trade.Reset;
end;

procedure YGaSession.SendQuestList(QuestGiver: YGaCreature; GUID: UInt64);
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
end;

procedure YGaSession.SendQuestDetails(GUID: UInt64; QuestID: UInt32);
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
end;

procedure YGaSession.SendQuestReward(GUID: UInt64; QuestID: UInt32);
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
end;

procedure YGaSession.SendGossipMenu(Cr: YGaCreature; GUID: UInt64);
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
end;

procedure YGaSession.SendCloseGossip;
var
  cOutPkt: YNwServerPacket;
begin
  cOutPkt := YNwServerPacket.Initialize(SMSG_GOSSIP_COMPLETE);
  try
    fLoggedInPlayer.Session.SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
end;

procedure YGaSession.SendCompleteQuest(GUID: UInt64; QuestID: UInt32);
var
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
end;

procedure YGaSession.HandleGossipHello(InPkt: YNwClientPacket);
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
end;

procedure YGaSession.HandleQuestConfirmAccept(InPkt: YNwClientPacket);
begin
  //
end;

procedure YGaSession.HandlePageTextQuery(InPkt: YNwClientPacket);
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
end;

procedure YGaSession.HandleQuestGiverAcceptQuest(InPkt: YNwClientPacket);
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
end;

procedure YGaSession.HandleQuestGiverCancel(InPkt: YNwClientPacket);
begin
  //
end;

procedure YGaSession.HandleQuestQuery(InPkt: YNwClientPacket);
var
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
end;

procedure YGaSession.HandleQuestGiverChooseReward(InPkt: YNwClientPacket);
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
end;

procedure YGaSession.HandleQuestGiverCompleteQuest(InPkt: YNwClientPacket);
var
  iGUID: UInt64;
  iQuestId: UInt32;
begin
  iGUID := InPkt.ReadUInt64;
  iQuestId := InPkt.ReadUInt32;
  SendCompleteQuest(iGUID, iQuestID);
end;

procedure YGaSession.HandleQuestGiverHello(InPkt: YNwClientPacket);
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
end;

procedure YGaSession.HandleQuestLogRemoveQuest(InPkt: YNwClientPacket);
var
  iQuestLogId: UInt32;
begin
  iQuestLogId := InPkt.ReadUInt8;
  fLoggedInPlayer.Quests.Remove(iQuestLogId);
end;

procedure YGaSession.HandleQuestLogSwapQuest(InPkt: YNwClientPacket);
begin
  //
end;

procedure YGaSession.HandleQuestGiverQueryQuest(InPkt: YNwClientPacket);
var
  iGUID: UInt64;
  iQuestId: UInt32;
begin
  iGUID := InPkt.ReadUInt64;
  iQuestId := InPkt.ReadUInt32;
  SendQuestDetails(iGUID, iQuestId);
end;

procedure YGaSession.HandleQuestGiverQuestAutoLaunch(InPkt: YNwClientPacket);
begin
  //
end;

procedure YGaSession.HandleQuestGiverRequestReward(InPkt: YNwClientPacket);
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
end;

procedure YGaSession.HandleAreaTrigger(InPkt: YNwClientPacket);
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
end;

destructor YGaSession.Destroy;
begin
  { Removing subscription }
  if Assigned(fLoggedInPlayer) then
  begin
    if fLogoutTimerHandle <> nil then
    begin
      fLogoutTimerHandle.Unregister;
      fLogoutTimerHandle := nil;
      fLoggedInPlayer.ReplaceUInt32(UNIT_FIELD_BYTES_1, UNIT_STATE_SIT, UNIT_STATE_STAND);
      fLoggedInPlayer.AndNotUInt32(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_ROOTED);
    end;
    if fLoggedInPlayer.InWorld then fLoggedInPlayer.ChangeWorldState(wscRemove);
    fLoggedInPlayer.Free;
    fLoggedInPlayer := nil;
  end;
  if fHandle <> nil then
  begin
    fHandle.Unregister;
    fHandle := nil;
  end;
  inherited Destroy;
end;

constructor YGaSession.Create;
begin
  inherited Create;
  { Now let's register a Subscription }
  fHandle := SystemTimer.RegisterEvent(SessionTimer, SESSION_UPD_INTERVAL,
    TICK_EXECUTE_INFINITE, 'GaSession_MainTimer');
end;

procedure YGaSession.SendPacket(Pkt: YNwServerPacket);
begin
  fSocket.SessionSendPacket(Pkt);
end;

procedure YGaSession.SessionLogOut(Event: TEventHandle; TimeDelta: UInt32);
var
  cOutPkt: YNwServerPacket;
begin
  with fLoggedInPlayer do
  begin
    ReplaceUInt32(UNIT_FIELD_BYTES_1, UNIT_STATE_SIT, UNIT_STATE_STAND);
    AndNotUInt32(UNIT_FIELD_FLAGS, UNIT_FIELD_FLAG_ROOTED);
  end;

  cOutPkt := YNwServerPacket.Initialize(SMSG_FORCE_MOVE_UNROOT);
  try
    cOutPkt.AddPackedGUID(fLoggedInPlayer.GUID);
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;

  if fLoggedInPlayer.Guild.Entry <> nil then
    YGaGuild(fLoggedInPlayer.Guild.Entry).Sign(fLoggedInPlayer, 2);

  cOutPkt := YNwServerPacket.Initialize(SMSG_LOGOUT_COMPLETE);
  try
    SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
  
  fLoggedInPlayer.ChangeWorldState(wscRemove);
  fLogoutTimerHandle := nil;
end;

procedure YGaSession.SessionTimer(Event: TEventHandle; TimeDelta: UInt32);
begin
  if Assigned(fLoggedInPlayer) then
  begin
    fLoggedInPlayer.PlayerLifeTimer(Event, TimeDelta);
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

procedure YGaSession.SetAccount(const Acc: string);
begin
  fAccount := UpperCase(Acc);
end;

function YGaSession.GetAccount: string;
begin
  Result := fAccount;
end;

function YGaSession.GetRealmName: string;
begin
  Result := fInThisRealm;
end;

procedure YGaSession.ReportNotInGuild;
var
  cOutPkt: YNwServerPacket;
begin
  cOutPkt := YNwServerPacket.Initialize(SMSG_GUILD_COMMAND_RESULT);
  try
    CoutPkt.AddUInt32(1);
    cOutPkt.AddUInt8(0);
    CoutPkt.AddUInt32(9);
    fLoggedInPlayer.SendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
end;

procedure YGaSession.HandleGuildQUERY(InPkt: YNwClientPacket);
var
  Guild: YGaGuild;
begin
  Guild := GameCore.Guilds[InPkt.ReadUInt32];
  if Guild <> nil then
    Guild.Query(fLoggedInPlayer);
end;

procedure YGaSession.HandleGuildROSTER(InPkt: YNwClientPacket);
begin
  if fLoggedInPlayer.Guild.Entry <> nil then
    YGaGuild(fLoggedInPlayer.Guild.Entry).Roster(fLoggedInPlayer)
  else
    ReportNotInGuild;
end;

procedure YGaSession.HandleGuildINVITE(InPkt: YNwClientPacket);
begin
  if fLoggedInPlayer.Guild.Entry <> nil then
    YGaGuild(fLoggedInPlayer.Guild.Entry).Invite(fLoggedInPlayer, InPkt.ReadString)
  else
    ReportNotInGuild;
end;

procedure YGaSession.HandleGuildACCEPT(InPkt: YNwClientPacket);
var
  Guild: YGaGuild;
begin
  Guild := GameCore.Guilds[fLoggedInPlayer.Guild.Inv];
  if Guild <> nil then
    Guild.Accept(fLoggedInPlayer);
end;

procedure YGaSession.HandleGuildNOTE(InPkt: YNwClientPacket);
begin
  if fLoggedInPlayer.Guild.Entry <> nil then
    case InPkt.Header^.Opcode of
      CMSG_GUILD_SET_PUBLIC_NOTE : YGaGuild(fLoggedInPlayer.Guild.Entry).Note(fLoggedInPlayer, 1, InPkt.ReadString, InPkt.ReadString);
      CMSG_GUILD_SET_OFFICER_NOTE: YGaGuild(fLoggedInPlayer.Guild.Entry).Note(fLoggedInPlayer, 2, InPkt.ReadString, InPkt.ReadString);
    end
  else
    ReportNotInGuild;
end;

procedure YGaSession.HandleGuildMOTD(InPkt: YNwClientPacket);
begin
  if fLoggedInPlayer.Guild.Entry <> nil then
    YGaGuild(fLoggedInPlayer.Guild.Entry).MOTD(fLoggedInPlayer, InPkt.ReadString)
  else
    ReportNotInGuild;
end;

procedure YGaSession.HandleGuildDECINE(InPkt: YNwClientPacket);
begin
  fLoggedInPlayer.Guild.Inv := 0;
end;

procedure YGaSession.HandleGuildRANK(InPkt: YNwClientPacket);
begin
  if fLoggedInPlayer.Guild.Entry <> nil then
  case InPkt.Header^.Opcode of
    CMSG_GUILD_RANK    : YGaGuild(fLoggedInPlayer.Guild.Entry).ChangeRank(fLoggedInPlayer, InPkt.ReadUInt32, InPkt.ReadUInt32, InPkt.ReadString);
    CMSG_GUILD_ADD_RANK: YGaGuild(fLoggedInPlayer.Guild.Entry).CreateRank(fLoggedInPlayer, InPkt.ReadString);
    CMSG_GUILD_DEL_RANK: YGaGuild(fLoggedInPlayer.Guild.Entry).RemoveRank(fLoggedInPlayer);
  end
  else
    ReportNotInGuild;
end;

procedure YGaSession.HandleGuildPROMOTE(InPkt: YNwClientPacket);
begin
  if fLoggedInPlayer.Guild.Entry <> nil then
    YGaGuild(fLoggedInPlayer.Guild.Entry).PROMOTE(fLoggedInPlayer, InPkt.ReadString)
  else
    ReportNotInGuild;
end;

procedure YGaSession.HandleGuildDEMOTE(InPkt: YNwClientPacket);
begin
  if fLoggedInPlayer.Guild.Entry <> nil then
    YGaGuild(fLoggedInPlayer.Guild.Entry).DEMOTE(fLoggedInPlayer, InPkt.ReadString)
  else
    ReportNotInGuild;
end;

procedure YGaSession.HandleGuildINFO(InPkt: YNwClientPacket);
begin
  if fLoggedInPlayer.Guild.Entry <> nil then
    YGaGuild(fLoggedInPlayer.Guild.Entry).INFO(fLoggedInPlayer)
  else
    ReportNotInGuild;
end;

procedure YGaSession.HandleGuildLEAVE(InPkt: YNwClientPacket);
begin
  if fLoggedInPlayer.Guild.Entry <> nil then
    YGaGuild(fLoggedInPlayer.Guild.Entry).Leave(fLoggedInPlayer)
  else
    ReportNotInGuild;
end;

procedure YGaSession.HandleGuildREMOVE(InPkt: YNwClientPacket);
begin
  if fLoggedInPlayer.Guild.Entry <> nil then
    YGaGuild(fLoggedInPlayer.Guild.Entry).Remove(fLoggedInPlayer, InPkt.ReadString)
  else
    ReportNotInGuild;
end;

procedure YGaSession.HandleGuildDISBAND(InPkt: YNwClientPacket);
begin
  if fLoggedInPlayer.Guild.Entry <> nil then
    YGaGuild(fLoggedInPlayer.Guild.Entry).Disband(fLoggedInPlayer)
  else
    ReportNotInGuild;
end;

procedure YGaSession.HandleGuildLeader(InPkt: YNwClientPacket);
begin
  if fLoggedInPlayer.Guild.Entry <> nil then
    YGaGuild(fLoggedInPlayer.Guild.Entry).Leader(fLoggedInPlayer, InPkt.ReadString)
  else
    ReportNotInGuild;
end;

procedure YGaSession.HandleGuildUNK(InPkt: YNwClientPacket);
begin
  if fLoggedInPlayer.Guild.Entry <> nil then
    YGaGuild(fLoggedInPlayer.Guild.Entry).UNK(fLoggedInPlayer, InPkt.ReadString)
  else
    ReportNotInGuild;
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

  RegisterOpcodeHandler(@YGaSession.HandleGuildQUERY, CMSG_GUILD_QUERY);
  RegisterOpcodeHandler(@YGaSession.HandleGuildROSTER, CMSG_GUILD_ROSTER);
  RegisterOpcodeHandler(@YGaSession.HandleGuildINVITE, CMSG_GUILD_INVITE);
  RegisterOpcodeHandler(@YGaSession.HandleGuildACCEPT, CMSG_GUILD_ACCEPT);
  RegisterOpcodeHandler(@YGaSession.HandleGuildDECINE, CMSG_GUILD_DECLINE);
  RegisterOpcodeHandler(@YGaSession.HandleGuildNOTE, CMSG_GUILD_SET_PUBLIC_NOTE);
  RegisterOpcodeHandler(@YGaSession.HandleGuildNOTE, CMSG_GUILD_SET_OFFICER_NOTE);
  RegisterOpcodeHandler(@YGaSession.HandleGuildMOTD, CMSG_GUILD_MOTD);
  RegisterOpcodeHandler(@YGaSession.HandleGuildRANK, CMSG_GUILD_RANK);
  RegisterOpcodeHandler(@YGaSession.HandleGuildRANK, CMSG_GUILD_ADD_RANK);
  RegisterOpcodeHandler(@YGaSession.HandleGuildRANK, CMSG_GUILD_DEL_RANK);
  RegisterOpcodeHandler(@YGaSession.HandleGuildPROMOTE, CMSG_GUILD_PROMOTE);
  RegisterOpcodeHandler(@YGaSession.HandleGuildDEMOTE, CMSG_GUILD_DEMOTE);
  RegisterOpcodeHandler(@YGaSession.HandleGuildINFO, CMSG_GUILD_INFO);
  RegisterOpcodeHandler(@YGaSession.HandleGuildLEAVE, CMSG_GUILD_LEAVE);
  RegisterOpcodeHandler(@YGaSession.HandleGuildREMOVE, CMSG_GUILD_REMOVE);
  RegisterOpcodeHandler(@YGaSession.HandleGuildDISBAND, CMSG_GUILD_DISBAND);
  RegisterOpcodeHandler(@YGaSession.HandleGuildLEADER, CMSG_GUILD_LEADER);

  RegisterOpcodeHandler(@YGaSession.HandleGuildUNK, MSG_UNK_OPCODE_1);

  RegisterOpcodeHandler(@YGaSession.HandleMoveWorldPortACK, MSG_MOVE_WORLDPORT_ACK);
end;

initialization
  { Initialize the opcode table }
  InitOpcodeTable;
  OpcodeMax := Length(Handlers);

end.
