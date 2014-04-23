{*------------------------------------------------------------------------------
  Guild System.

  - Basic Code.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Morpheus
  @TODO Runtime DB loading / saving

------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.GameCore.Guilds;

interface

uses
  Framework.Base,
  Components.GameCore.WowPlayer,
  Components.NetworkCore.Packet,
  BFG.Containers;

const
  { Rights }
    RIGHT_EMPTY                = $00040;
    RIGHT_CHAT_LISTEN          = $00041;
    RIGHT_CHAT_SPEAK           = $00042;
    RIGHT_OFFICER_CHAT_LISTEN  = $00044;
    RIGHT_OFFICER_CHAT_SPEAK   = $00048;
    RIGHT_PROMOTE              = $000C0;
    RIGHT_DEMOTE               = $00140;
    RIGHT_INVITE               = $00050;
    RIGHT_REMOVE               = $00060;
    RIGHT_SET_MOTD             = $01040;
    RIGHT_SET_INFO             = $F0E40;
    RIGHT_SET_PLAYER_NOTE      = $02040;
    RIGHT_SET_OFFICER_NOTE     = $08040;
    RIGHT_VIEW_OFFICER_NOTE    = $04040;
    RIGHT_ALL                  = $FFFFF;

  { Events }
    EVENT_PROMOTION       = 0;
    EVENT_DEMOTION        = 1;
    EVENT_MOTD            = 2;
    EVENT_JOINED          = 3;
    EVENT_LEFT            = 4;
    EVENT_REMOVED         = 5;
    EVENT_LEADER_IS       = 6;
    EVENT_LEADER_CHANGED  = 7;
    EVENT_DISBANDED       = 8;
    EVENT_TABARDCHANGE    = 9;
    EVENT_SIGNED_ON       = 12;
    EVENT_SIGNED_OFF      = 13;

  { Command Types }
    TYPE_CREATE  = $00;
    TYPE_INVITE  = $01;
    TYPE_QUIT    = $03;
    TYPE_FOUNDER = 14;

  { Invite Results }
    INV_SENT                             = 0;
    INV_INTERNAL                         = 1;
    INV_PERMISSION                       = 8;
    INV_NOT_IN_GUILD                     = 9;
    INV_ALLREADY_IN_GUILD                = 2;
    INV_ALLREADY_INVITED_TO_GUILD        = 4;
    INV_PLAYER_ALLREADY_IN_GUILD         = 3;
    INV_PLAYER_ALLREADY_INVITED_TO_GUILD = 5;
    INV_PLAYER_NOT_IN_YOUR_GUILD         = 8;
    INV_PLAYER_NOT_FOUND                 = 11;
    INV_PLAYER_NOT_ALLIED                = 12;
    INV_PLAYER_RANK_HIGH                 = 13;
    INV_PLAYER_RANK_LOW                  = 14;
  { Founder }
    FOU_NEW_GUILD                        = 0;
  { Quit }
    QUI_MUST_PROMOTE_TO_LEADER           = 8;
    QUI_NO_MORE_IN_GUILD                 = 0;
    QUI_PLAYER_NOT_IN_YOUR_GUILD             = 10;
Type

  YRankInfo = record
    Name: String;
    Rights: UInt32;
  end;

  PMemberInfo = ^YMemberInfo;
  { @SEE
   YMemberInfo basic struture
    - Player points to online data
        will be used for sending packets, level and zone since roster will send the current level and zone
    - Rest of the fields are used for offline data and will be updated only by Signedoff event
    - Account field is used by GINFO command since we have to calc accounts number;
  }

  YMemberInfo = record
    GUID: Uint64;
    Name: String[10];
    Account: String;
    Rank, Level, &Class: UInt8;
    Zone: UInt32;
    Time: Float;
    PlayerNote, OfficerNote: String;
    Player: YGaPlayer;
  end;

  B_Type = (B_Event, B_Roster, B_Officer ,B_Chat); { Broadcast type }

  YGaGuild = class(TBaseObject)
    private
      fId: UInt32; { Guild real id }
      fName: String; // Guild Name
      fMOTD: String; // Guild MOTD
      fINFO: String; // Guild INFO
      fLeader: PMemberInfo; {@SEE Will point to our leader YMemberInfo}
      fRanks: array[0..9] of YRankInfo;
      fRanksSize: UInt8;
      fAccountsSize: UInt32;
      fMembers: TPtrArrayList;
      fEmblemStyle: UInt8;
      fEmblemColor: UInt8;
      fDate: TDateTime;

      { Loaders}
      fLoad: Boolean;

      { Saved Packets }
      RosterPkt: YNwServerPacket;
      QueryPKt: YNwServerPacket;

      function IsAccountExists(Const cAcc: String):Boolean;
      function CheckRights(cPlayer: YGaPlayer; Right: UInt32):Boolean;
      function CheckSides(cPlayer, iPlayer: YGaPlayer): Boolean;
      procedure PerformIDUpdate(Const Player: String);
      procedure PerformRankUpdate(Const Player: String; Rank: UInt8);
      procedure CreateDefaultRanks;
      procedure ReportCommandResult(cPlayer: YGaPlayer; &Type, Error: Uint32; Data: String);
    protected
      function FindPlayerByName(Const Player: String):UInt32;
      function GetGuildMember(Index: Int32): YMemberInfo;
      procedure BroadCastToGuild(Pkt: YNwServerPacket; Select: B_Type);
      procedure PrepareRosterPacket;
      procedure PrepareQueryPacket;
    public
      property LOAD: Boolean read fLoad;
      property ID: UInt32 read fId;
      property Members[Index: Int32]: YMemberInfo read GetGuildMember;// write SetGuildMember;
      function AddMember(Member: YGaPlayer; Rank:UInt8):PMemberInfo;
      procedure DelMember(Member: UInt32);

      procedure CreateRank(cPlayer: YGaPlayer; rName: String);
      procedure RemoveRank(cPlayer: YGaPlayer);
      procedure ChangeRank(cPlayer: YGaPlayer; rId: UInt8; rRights: UInt32; Const rName: String);

      procedure Sign(cPlayer: YGaPlayer; Select: UInt8);

      procedure Leader(cPlayer: YGaPlayer; Const lName:String);
      procedure Invite(cPlayer: YGaPlayer; Const iName:String);
      procedure Accept(cPlayer: YGaPlayer);
      procedure Remove(cPlayer: YGaPlayer; Const Name: String);
      procedure Leave(cPlayer: YGaPlayer);

      procedure Note(cPlayer: YGaPlayer; Select: UInt8; Const Name, Note: String);
      procedure MOTD(cPlayer: YGaPlayer; Const MOTD: String);
      procedure UNK(cPlayer: YGaPlayer; Const INFO: String);
      procedure INFO(cPlayer: YGaPlayer);

      procedure Query(cPlayer: YGaPlayer);
      procedure Roster(cPlayer: YGaPlayer);
      procedure Disband(cPlayer: YGaPlayer);

      procedure Promote(cPlayer: YGaPlayer; Const Name: String);
      procedure Demote(cPlayer: YGaPlayer; Const Name: String);

      procedure SayToGuild(cPlayer: YGaPlayer; Pkt: YNwServerPacket);
      procedure SayToOfficer(cPlayer: YGaPlayer; Pkt: YNwServerPacket);

      procedure SaveToDB;

      constructor Create(Leader: YGaPlayer; ID: UInt32; Name: String);overload;
      //constructor Create(Entry: YDbGuildEntry);overload;
      destructor Destroy; override;
    end;

implementation

uses
  Cores,
  Main,
  Components.Shared,
  Components.GameCore,
  Components.DataCore.Fields,
  Components.GameCore.Session,
  Components.DataCore.Types,
  Components.NetworkCore.Opcodes,
  Components.GameCore.UpdateFields,
  Misc.Miscleanous,
  SysUtils;

function YGaGuild.IsAccountExists(const cAcc: string):Boolean;
{*
  Providing account search.
*}
var
  i: UInt32;
begin
  Result := False;
  if fMembers.Size > 0 then
    for I := 0 to fMembers.Size - 1 do
      if Members[i].Account = cAcc then
      begin
        Result := true;
        Break;
      end;
end;

function YGaGuild.CheckRights;
begin
if (fRanks[cPlayer.Guild.Rank].Rights and Right) >= Right then
  Result := True
else
  Result := False;
end;

function YGaGuild.CheckSides;
begin
  { @Param returns true if the players are on the same side }
  if (IsHorde(cPlayer.Stats.race) and IsHorde(iPlayer.Stats.race)) or (IsAlliance(cPlayer.Stats.race) and IsAlliance(iPlayer.Stats.race)) then
    Result := True
  else
    Result := False;
end;

procedure YGaGuild.PerformIDUpdate;
{*
  PerformIDUpdate procedure provides RUN-TME DB update for PLAYER_GUILDID
*}
var
  cPlr: YDbPlayerEntry;
begin
  DataCore.Characters.LoadEntry(FIELD_PLI_CHAR_NAME, Player, cPlr);
  if cPlr <> nil then
  begin
    cPlr.UpdateData[PLAYER_GUILDID] := 0;
    DataCore.Characters.SaveEntry(cPlr);
  end;
end;

procedure YGaGuild.PerformRankUpdate;
{*
  PerformRankUpdate procedure provides RUN-TME DB update for PLAYER_GUILDRANK
*}
var
  cPlr: YDbPlayerEntry;
begin
  DataCore.Characters.LoadEntry(FIELD_PLI_CHAR_NAME, Player, cPlr);
  if cPlr <> nil then
  begin
    cPlr.UpdateData[PLAYER_GUILDRANK] := Rank;
    DataCore.Characters.SaveEntry(cPlr);
  end;
end;

procedure YGaGuild.CreateDefaultRanks;
begin
  { Defualt wow ranks }

  fRanks[0].Name := 'Guild Master';
  fRanks[0].Rights := RIGHT_ALL;

  fRanks[1].Name := 'Officer';
  fRanks[1].Rights := RIGHT_ALL;

  fRanks[2].Name := 'Veteran';
  fRanks[2].Rights := RIGHT_CHAT_LISTEN or RIGHT_CHAT_SPEAK;

  fRanks[3].Name := 'Member';
  fRanks[3].Rights := RIGHT_CHAT_LISTEN or RIGHT_CHAT_SPEAK;

  fRanks[4].Name := 'Initiate';
  fRanks[4].Rights := RIGHT_CHAT_LISTEN or RIGHT_CHAT_SPEAK;

  fRanksSize := 5;
end;

procedure YGaGuild.ReportCommandResult;
var
  cOutPkt: YNwServerPacket;
begin
  cOutPkt := YNwServerPacket.Initialize(SMSG_GUILD_COMMAND_RESULT);
  try
    CoutPkt.AddUInt32(&Type);
    if Data = #0 then
      cOutPkt.AddUInt8(0)
    else
      cOutPkt.AddString(Data);
    CoutPkt.AddUInt32(Error);
  finally
    cPlayer.SendPacket(cOutPkt);
    cOutPkt.Free;
  end;
end;

function YGaGuild.FindPlayerByName;
var i:UInt32;
begin
  Result := $FFFF;
  for i := 0 to fMembers.Size-1 do
    if Lowercase(Members[i].Name)  = Lowercase(Player) then
    begin
      Result := i;
      Break;
    end;
end;

function YGaGuild.GetGuildMember;
begin
  Result := PMemberInfo(fMembers[index])^;
end;

procedure YGaGuild.BroadCastToGuild;
{*
  BroadcastToGuild procedure provides broadcasting packets to online players with rights checking.
  @SEE CheckRights();
*}
var
  I : Int32;
begin
  case Select of
  B_EVENT:
  begin
    for i := 0 to fMembers.Size-1 do
      if Members[i].Player <> Nil then
         Members[i].Player.SendPacket(Pkt);
  end;
  B_CHAT:
  begin
    for i := 0 to fMembers.Size-1 do
      if Members[i].Player <> Nil then
        if CheckRights(Members[i].Player, RIGHT_CHAT_LISTEN) then
          Members[i].Player.SendPacket(Pkt);
  end;
  B_OFFICER:
  begin
    for i := 0 to fMembers.Size-1 do
      if Members[i].Player <> Nil then
        if CheckRights(Members[i].Player, RIGHT_OFFICER_CHAT_LISTEN) then
          Members[i].Player.SendPacket(Pkt);
  end;
  B_ROSTER:
  begin
    for i := 0 to fMembers.Size-1 do
      if Members[i].Player <> Nil then
        Members[i].Player.SendPacket(RosterPkt);
  end;
  end;
end;

procedure YGaGuild.PrepareRosterPacket;
var
  i: Int32;
begin
  RosterPkt := YNwServerPacket.Initialize(SMSG_GUILD_ROSTER);

  RosterPkt.AddUInt32(fMembers.Size);

  RosterPkt.AddString(fMOTD);
  RosterPkt.AddString(fINFO);

  RosterPkt.AddUInt32(fRanksSize);  { Ranks size }

  for i := 0 to fRanksSize-1 do
    RosterPkt.AddUInt32(fRanks[i].Rights);

  for i := 0 to fMembers.Size-1 do
    if Members[i].Player <> Nil then
    begin
      {Online}
      RosterPkt.AddUInt64(Members[i].GUID);
      RosterPkt.AddUInt8(1);
      RosterPkt.AddString(Members[i].Name);
      RosterPkt.AddUInt32(Members[i].Rank);
      RosterPkt.AddUInt8(Members[i].Player.Stats.Level);
      RosterPkt.AddUInt8(Members[i].&Class);
      RosterPkt.AddUInt32(Members[i].Player.Position.ZoneId);
      RosterPkt.AddString(Members[i].PlayerNote);
      RosterPkt.AddString(Members[i].OfficerNote);
    end
    else
    begin
      {Offline}
      RosterPkt.AddUInt64(Members[i].GUID);
      RosterPkt.AddUInt8(0);
      RosterPkt.AddString(Members[i].Name);
      RosterPkt.AddUInt32(Members[i].Rank);
      RosterPkt.AddUInt8(Members[i].Level);
      RosterPkt.AddUInt8(Members[i].&Class);
      RosterPkt.AddUInt32(Members[i].Zone);
      RosterPkt.AddFloat(Members[i].Time); {@TODO Test}
      RosterPkt.AddString(Members[i].PlayerNote);
      RosterPkt.AddString(Members[i].OfficerNote);
    end;
end;

procedure YGaGuild.PrepareQueryPacket;
var
  i: Int32;
begin
  QueryPkt := YNwServerPacket.Initialize(SMSG_GUILD_QUERY_RESPONSE);
  QueryPkt.AddUInt32(fID);
  QueryPkt.AddString(fName);
  for I := 0 to 9 do
    if i > fRanksSize-1 then
      QueryPkt.AddString('Unused')
    else
      QueryPkt.AddString(fRanks[i].name);
  QueryPkt.AddUInt32(fEmblemStyle);
  QueryPkt.AddUInt32(fEmblemColor);
  QueryPkt.AddUInt32(0);
  QueryPkt.AddUInt32(0);
end;

function YGaGuild.AddMember;
{*
  Add member function provides member creation.
    - First, updating the accounts number that is by /ginfo event
    - Secound addding member to fMembers DB.
    - Last, updating guild roster.
  @SEE IsAccountExists, PrepareRosterPacket, fMembers
*}
var
  nGuildMember:  PMemberInfo;
begin
  { Update accounts size }
  if not IsAccountExists(Member.Account) then Inc(fAccountsSize);
  { Add to members list }
  New(nGuildMember);

  nGuildMember^.GUID := Member.GUIDFull;
  nGuildMember^.Name := Member.Name;
  nGuildMember^.Account := Member.Account;
  nGuildMember^.Rank := Rank;
  nGuildMember^.&Class := ClassToInteger(Member.Stats.&Class);
  nGuildMember^.Player := Member;

  fMembers.Add(nGuildMember);

  PrepareRosterPacket;

  Result := nGuildMember;
end;

procedure YGaGuild.DelMember;
{*
  Delmember procedure provides member deletion.
  - Member deletion from fMembers.
  - Notifying event if is member online (You are no longer member of)
  - Updaing Accounds number.
  - Updating Roster.
  - RUN-TIME DB Update, if member is online by cPlayer, if not by PerformIDUpdate. that is needed for cases like when player was kicked out of guild while he was offline
  @SEE PerformIDUpdate, PrepareRosterPacket, IsAccountExists, fMembers.
*}
var
  cPlayer: YGaPlayer;
  cAcc: String;
begin
  cPlayer := Members[Member].Player;
  cAcc := Members[Member].Account;
  if cPlayer <> nil then { Player is online, then report no more in guild }
  begin
    cPlayer.Guild.ID := 0;
    cPlayer.Guild.Rank := 0;
    cPlayer.Guild.Inv := 0;
    cPlayer.Guild.Entry := nil;
    ReportCommandResult(cPlayer, TYPE_QUIT, QUI_NO_MORE_IN_GUILD, fName)
  end
  else
    PerformIDUpdate(Members[Member].Name);
  Dispose(fMembers[Member]);
  fMembers.Remove(Member);
  { update accounts size }
  if not IsAccountExists(cAcc) then Dec(fAccountsSize);
  PrepareRosterPacket;
end;

procedure YGaGuild.CreateRank(cPlayer: YGaPlayer; rName: String);
begin
  if not (fRanksSize = 10) then
  begin
    fRanks[fRanksSize].Name := rName;
    fRanks[fRanksSize].Rights := RIGHT_CHAT_LISTEN or RIGHT_CHAT_SPEAK;
    Inc(fRanksSize);
    PrepareQueryPacket;
    PrepareRosterPacket;
    Query(cPlayer);
    Roster(cPlayer);
  end;
end;

procedure YGaGuild.RemoveRank(cPlayer: YGaPlayer);
begin
  if fRanksSize > 5 then
  begin
    fRanks[fRanksSize].Name := #0;
    fRanks[fRanksSize].Rights := 0;
    Dec(fRanksSize);
    PrepareQueryPacket;
    PrepareRosterPacket;
    Query(cPlayer);
    Roster(cPlayer);
  end;
end;

procedure YGaGuild.ChangeRank;
begin
  if rId <= fRanksSize then
  begin
    fRanks[rId].Name := rName;
    fRanks[rId].Rights := rRights;
    PrepareQueryPacket;
    PrepareRosterPacket;
    Query(cPlayer);
    Roster(cPlayer);
  end;
end;

procedure YGaGuild.Sign(cPlayer: YGaPlayer; Select: UInt8);
var
  cOutPkt: YNwServerPacket;
  Pos: UInt32;
begin
  Pos := FindPlayerByName(cPlayer.Name);
  if Select = 1 then
  begin
    cOutPkt := YNwServerPacket.Initialize(SMSG_GUILD_EVENT);
    try
      CoutPkt.AddUInt8(EVENT_MOTD);
      CoutPkt.AddUInt8(1);
      CoutPkt.AddString(fMOTD);
    finally
      cPlayer.SendPacket(CoutPkt);
      cOutPkt.Free;
    end;
  end;
  cOutPkt := YNwServerPacket.Initialize(SMSG_GUILD_EVENT);
  try
    if Select = 1 then
    begin
      { Player signed on, send motd update his online fields}
      CoutPkt.AddUInt8(EVENT_SIGNED_ON);
      PMemberInfo(fMembers[Pos])^.Player := cPlayer;
    end
    else
    begin
      { Player signed off, update his offline fields }
      PMemberInfo(fMembers[Pos])^.Level := cPlayer.Stats.Level;
      PMemberInfo(fMembers[Pos])^.Zone := cPlayer.Position.ZoneId;
      PMemberInfo(fMembers[Pos])^.Time := Now ();
      PMemberInfo(fMembers[Pos])^.Player := Nil;
      { setup event}
      CoutPkt.AddUInt8(EVENT_SIGNED_OFF);
    end;
    CoutPkt.AddUInt8(1);
    CoutPkt.AddString(cPlayer.Name);
    CoutPkt.AddUInt8(0);
    CoutPkt.AddUInt8(0);
    CoutPkt.AddUInt8(0);
    { Uppdate roster }
    PrepareRosterPacket;
  finally
    BroadCastToGuild(cOutPkt, B_EVENT);
    cOutPkt.Free;
  end;
end;

procedure YGaGuild.Leader;
var
  Pos: UInt32;
  cOutPkt: YNwServerPacket;
  Obj: YGaPlayer;
begin
  if cPlayer.GUIDFull <> fLeader^.GUID then
    ReportCommandResult(cPlayer, TYPE_INVITE, INV_PERMISSION, #0)
  else
  if Lowercase(lName)= Lowercase(fLeader^.Name) then { Trying to promote my self ? }
    ReportCommandResult(cPlayer, TYPE_INVITE, INV_PLAYER_NOT_FOUND, lName)
  else
  begin
    Pos := FindPlayerByName(lName);
    if Pos = $FFFF then
    case GameCore.FindPlayerByName(lName, Obj) of
      lrOnline: ReportCommandResult(cPlayer, TYPE_INVITE, INV_PLAYER_NOT_IN_YOUR_GUILD, lName);
      lrOffline, lrNonExistant: ReportCommandResult(cPlayer, TYPE_INVITE, INV_PLAYER_NOT_FOUND, lName);
    end
    else
    begin
      cOutPkt := YNwServerPacket.Initialize(SMSG_GUILD_EVENT);
      try
        CoutPkt.AddUInt8(EVENT_LEADER_CHANGED);
        CoutPkt.AddUInt8(2);
        CoutPkt.AddString(fLeader.Name);
        CoutPkt.AddString(lName);
        BroadCastToGuild(cOutPkt, B_EVENT);
      finally
        cOutPkt.Free;
      end;
      { Alright, change leaders status
      1. Old leader is given rank 4
      }
      fLeader^.Rank := 4;
      if fLeader^.Player <> nil then
        fLeader^.Player.Guild.Rank := 4;
      {2. finally setup new leader`s status }
      fLeader := fMembers[Pos];
      fLeader^.Rank := 0;
      if fLeader^.Player <> nil then
      begin
        fLeader^.Player.Guild.Rank := 0;
        Query(fLeader^.Player);
      end
      else
        PerformRankUpdate(fLeader^.Name, 0);
    end;
  end;
end;

Procedure YGaGuild.Invite;
var
 iPlayer: YGaPlayer;
 cOutPkt: YNwServerPacket;
begin
  if not CheckRights(cPlayer, RIGHT_INVITE) then
    ReportCommandResult(cPlayer, TYPE_INVITE, INV_PERMISSION, #0) { Do i have the rights to invite }
  else
  case GameCore.FindPlayerByName(iName, iPlayer) of {Check if there is such player }
  lrOnline:
  begin
    if not CheckSides(cPlayer, iPlayer) then { hostile ? }
      ReportCommandResult(cPlayer, TYPE_INVITE, INV_PLAYER_NOT_ALLIED, iName)
    else
    if iPlayer.Guild.ID <> 0 then { Is he in guild ? }
      ReportCommandResult(cPlayer, TYPE_INVITE, INV_PLAYER_ALLREADY_IN_GUILD, iName)
    else
    if iPlayer.Guild.Inv <> 0 then { player has been allready invited to some guild ? }
      ReportCommandResult(cPlayer, TYPE_INVITE, INV_PLAYER_ALLREADY_INVITED_TO_GUILD, iName)
    else
    begin
      ReportCommandResult(cPlayer, TYPE_INVITE, INV_SENT, iName); { Player has been invited to your guild }
      iPlayer.Guild.Inv := fId;
      cOutPkt := YNwServerPacket.Initialize(SMSG_GUILD_INVITE); { send invition }
      try
        cOutPkt.AddString(cPlayer.name);
        cOutPkt.AddString(fName);
        iPlayer.SendPacket(cOutPkt);
      finally
        cOutPkt.Free;
      end;
    end;
  end;
  lrOffline, lrNonExistant: ReportCommandResult(cPlayer, TYPE_INVITE, INV_PLAYER_NOT_FOUND, iName);
end;
end;

Procedure YGaGuild.Accept;
var
  cOutPkt: YNwServerPacket;
begin
  if cPlayer.Guild.Inv <> 0 then
  begin
    Query(cPlayer);
    cPlayer.Guild.Inv := 0;
    cPlayer.Guild.Rank := 4;
    cPlayer.Guild.Entry := GameCore.Guilds[fId];
    cPlayer.Guild.ID := fId;

    cOutPkt := YNwServerPacket.Initialize(SMSG_GUILD_EVENT);
    try
      cOutPkt.AddUInt8(EVENT_MOTD);
      cOutPkt.AddUInt8(1);
      cOutPkt.AddString(fMOTD);
    finally
      cPlayer.SendPacket(cOutPkt);
      cOutPkt.Free;
    end;

    AddMember(cPlayer, 4);

    cOutPkt := YNwServerPacket.Initialize(SMSG_GUILD_EVENT);
    try
      cOutPkt.AddUInt8(EVENT_JOINED);
      cOutPkt.AddUInt8(1);
      cOutPkt.AddString(cPlayer.Name);
    finally
      BroadCastToGuild(cOutPkt, B_EVENT); {@ X has joined the guild }
      cOutPkt.Free;
    end;
  end;
end;

procedure YGaGuild.Remove;
Var
  Pos: UInt32;
  Obj: YGaPlayer;
  cOutPkt: YNwServerPacket;
begin
  if not CheckRights(cPlayer, RIGHT_REMOVE) then
    ReportCommandResult(cPlayer, TYPE_INVITE, INV_PERMISSION, #0)
  else
  begin
    Pos := FindPlayerByName(Name);
    if Pos = $FFFF then
    case GameCore.FindPlayerByName(Name, Obj) of
      lrOnline: ReportCommandResult(cPlayer, TYPE_QUIT, QUI_PLAYER_NOT_IN_YOUR_GUILD, Name);
      lrOffline, lrNonExistant: ReportCommandResult(cPlayer, TYPE_QUIT, INV_PLAYER_NOT_FOUND, Name);
    end
    else
    if (Members[Pos].GUID = fLeader^.GUID) and (cPlayer.GUIDFull = fLeader^.GUID) then
      if fMembers.Size > 1 then
        ReportCommandResult(cPlayer, TYPE_QUIT, QUI_MUST_PROMOTE_TO_LEADER, #0)
      else
        Disband(cPlayer)
    else
    if (Members[Pos].Rank <= cPlayer.Guild.Rank) and not (Members[Pos].GUID = cPlayer.GUIDFull) then
      ReportCommandResult(cPlayer, TYPE_INVITE, INV_PERMISSION, #0)
    else
    begin
      { delete & report }
      DelMember(Pos);
      { report to guild members }
      cOutPkt := YNwServerPacket.Initialize(SMSG_GUILD_EVENT);
      try
        CoutPkt.AddUInt8(EVENT_REMOVED);
        CoutPkt.AddUInt8(2);
        CoutPkt.AddString(Name);
        CoutPkt.AddString(cPlayer.Name);
      finally
        BroadCastToGuild(cOutPkt, B_EVENT);
        cOutPkt.Free;
      end;
    end;
  end;
end;

Procedure YGaGuild.Leave;
var
  cOutPkt: YNwServerPacket;
begin
  if cPlayer.GUIDFull = fLeader^.GUID then
    if fMembers.Size > 1 then
      ReportCommandResult(cPlayer, TYPE_QUIT, QUI_MUST_PROMOTE_TO_LEADER, #0)
    else
      Disband(cPlayer)
  else
  begin
    { Delete and report to member }
    DelMember(FindPlayerByName(cPlayer.Name));
    { Report to guild }
    cOutPkt := YNwServerPacket.Initialize(SMSG_GUILD_EVENT);
    try
      CoutPkt.AddUInt8(EVENT_LEFT);
      CoutPkt.AddUInt8(1);
      CoutPkt.AddString(cPlayer.Name);
      BroadCastToGuild(cOutPkt, B_EVENT);
    finally
      cOutPkt.Free;
    end;
  end;
end;

procedure YGaGuild.Note;
begin
  case select of
    1:
      {Public note}
      if not CheckRights(cPlayer, RIGHT_SET_PLAYER_NOTE) then
        ReportCommandResult(cPlayer, TYPE_INVITE, INV_PERMISSION, #0)
        else
        begin
          PMemberInfo(fMembers[FindPlayerByName(Name)])^.PlayerNote := Note;
          PrepareRosterPacket;
          Roster(cPlayer);
        end;
    2:
      {Officer note}
      if not CheckRights(cPlayer, RIGHT_SET_OFFICER_NOTE) then
        ReportCommandResult(cPlayer, TYPE_INVITE, INV_PERMISSION, #0)
        else
        begin
          PMemberInfo(fMembers[FindPlayerByName(Name)])^.OfficerNote := Note;
          PrepareRosterPacket;
          Roster(cPlayer);
        end;
  end;
end;

procedure YGaGuild.MOTD;
var
  cOutPkt: YNwServerPacket;
begin
  if not CheckRights(cPlayer, RIGHT_SET_MOTD) then
     ReportCommandResult(cPlayer, TYPE_INVITE, INV_PERMISSION, #0)
  else
  begin
    fMOTD := MOTD;
    cOutPkt := YNwServerPacket.Initialize(SMSG_GUILD_EVENT);
    try
      CoutPkt.AddUInt8(EVENT_MOTD);
      CoutPkt.AddUInt8(1);
      CoutPkt.AddString(MOTD);
    finally
      BroadCastToGuild(cOutPkt, B_EVENT);
      cOutPkt.Free;
    end;
  end;
end;

procedure YGaGuild.UNK;
begin
  if not CheckRights(cPlayer, RIGHT_SET_INFO) then
     ReportCommandResult(cPlayer, TYPE_INVITE, INV_PERMISSION, #0)
  else
  begin
    fInfo := INFO;
    PrepareRosterPacket;
    Roster(cPlayer);
  end;
end;

procedure YGaGuild.INFO;
var
  cOutPkt: YNwServerPacket;
  Day, Month, Year: UInt16;
begin
  cOutPkt := YNwServerPacket.Initialize(SMSG_GUILD_INFO);
  try
    DecodeDate(fDate, Year, Month, Day);
    CoutPkt.AddString(fName);
    CoutPkt.AddUInt32(Month);
    CoutPkt.AddUInt32(Day);
    CoutPkt.AddUInt32(Year);
    CoutPkt.AddUInt32(fMembers.Size);
    CoutPkt.AddUInt32(fAccountsSize);
  finally
    cPlayer.SendPacket(cOutPkt);
    cOutPkt.Free;
  end;
end;

procedure YGaGuild.Query(cPlayer: YGaPlayer);
begin
{*
  Query event provides basic information on the guild to worldwide players.
  - Due to the fact query can be requested simultaneously by hunders of clients that are not event part of the guild
    i have decided to save the packet and update it only on changes, that will improve server efficiency.
    @SEE PrepareQueryPacket
*}
  cPlayer.SendPacket(QueryPkt);
end;

procedure YGaGuild.Roster(cPlayer: YGaPlayer);
begin
  cPlayer.SendPacket(RosterPkt);
end;

procedure YGaGuild.Disband;
var
  cOutPkt: YNwServerPacket;
  I: UInt32;
  dPlayer: YGaPlayer;
begin
  if cPlayer.GUIDFull <> fLeader^.GUID then
    ReportCommandResult(cPlayer, TYPE_INVITE, INV_PERMISSION, #0)
  else
  begin
    { Report to guild }
    cOutPkt := YNwServerPacket.Initialize(SMSG_GUILD_EVENT);
    try
      CoutPkt.AddUInt8(EVENT_DISBANDED);
      CoutPkt.AddUInt8(0);
      BroadCastToGuild(cOutPkt, B_EVENT);
    finally
      cOutPkt.Free;
    end;
    { delete all members & report you are no more in guild }
    for I := 0 to fMembers.Size-1 do
    begin
      dPlayer := PMemberInfo(fMembers[0])^.Player;
      if dPlayer <> Nil then
      begin
        { Online members only }
        Dispose(fMembers[0]);
        fMembers.Remove(0);
        dPlayer.Guild.ID := 0;
        dPlayer.Guild.Rank := 0;
        dPlayer.Guild.Inv := 0;
        dPlayer.Guild.Entry := nil;
        ReportCommandResult(dPlayer, TYPE_QUIT, QUI_NO_MORE_IN_GUILD, fName)
      end
      else
        PerformIDUpdate(PMemberInfo(fMembers[0]).Name);
    end;
    { Destory class and free objects }
    Destroy;
  end;
end;

procedure YGaGuild.Promote;
var
  Pos: UInt32;
  cOutPkt: YNwServerPacket;
  Obj: YGaPlayer;
begin
  if not CheckRights(cPlayer, RIGHT_PROMOTE) then
    ReportCommandResult(cPlayer, TYPE_INVITE, INV_PERMISSION, #0)
  else
  begin
    Pos := FindPlayerByName(Name);
    if Pos = $FFFF then
    case GameCore.FindPlayerByName(Name, Obj) of
      lrOnline: ReportCommandResult(cPlayer, TYPE_INVITE, INV_PLAYER_NOT_IN_YOUR_GUILD, Name);
      lrOffline, lrNonExistant: ReportCommandResult(cPlayer, TYPE_INVITE, INV_PLAYER_NOT_FOUND, Name);
    end
    else
    begin
      if Members[Pos].Rank <= 1 then
        ReportCommandResult(cPlayer, TYPE_INVITE, INV_PLAYER_RANK_HIGH, Name)
      else
      if ((Members[Pos].Rank-1) <= cPlayer.Guild.Rank) then
        ReportCommandResult(cPlayer, TYPE_INVITE, INV_PERMISSION, #0)
      else
      begin
        Dec(PMemberInfo(fMembers[Pos])^.Rank);
        if Members[Pos].Player <> nil then
          Members[Pos].Player.Guild.Rank := Members[Pos].Rank
        else
          PerformRankUpdate(Members[Pos].Name, Members[Pos].Rank);
        PrepareRosterPacket;
        cOutPkt := YNwServerPacket.Initialize(SMSG_GUILD_EVENT);
        try
          CoutPkt.AddUInt8(EVENT_PROMOTION);
          CoutPkt.AddUInt8(3);
          CoutPkt.AddString(cPlayer.Name);
          CoutPkt.AddString(Name);
          CoutPkt.AddString(fRanks[Members[Pos].Rank].Name);
          BroadCastToGuild(cOutPkt, B_EVENT);
        finally
          cOutPkt.Free;
        end;
      end;
    end;
  end;
end;

procedure YGaGuild.Demote ;
var
  Pos: UInt32;
  cOutPkt: YNwServerPacket;
  Obj: YGaPlayer;
begin
  if not CheckRights(cPlayer, RIGHT_DEMOTE) then
    ReportCommandResult(cPlayer, TYPE_INVITE, INV_PERMISSION, #0)
  else
  begin
    Pos := FindPlayerByName(Name);
    if Pos = $FFFF then
    case GameCore.FindPlayerByName(Name, Obj) of
      lrOnline: ReportCommandResult(cPlayer, TYPE_INVITE, INV_PLAYER_NOT_IN_YOUR_GUILD, Name);
      lrOffline, lrNonExistant: ReportCommandResult(cPlayer, TYPE_INVITE, INV_PLAYER_NOT_FOUND, Name);
    end
    else
    begin
      if (Members[Pos].Rank >= fRanksSize-1) or (Members[Pos].Rank = 0) then  {1. Low Rank, 2. Leader case }
        ReportCommandResult(cPlayer, TYPE_INVITE, INV_PLAYER_RANK_LOW, Name)
      else
      if cPlayer.Guild.Rank >= Members[Pos].Rank then
        ReportCommandResult(cPlayer, TYPE_INVITE, INV_PERMISSION, #0)
      else
      begin
        Inc(PMemberInfo(fMembers[Pos])^.Rank);
        if Members[Pos].Player <> Nil then
          Members[Pos].Player.Guild.Rank := Members[Pos].Rank
        else
          PerformRankUpdate(Members[Pos].Name, Members[Pos].Rank);
        PrepareRosterPacket;
        cOutPkt := YNwServerPacket.Initialize(SMSG_GUILD_EVENT);
        try
          CoutPkt.AddUInt8(EVENT_DEMOTION);
          CoutPkt.AddUInt8(3);
          CoutPkt.AddString(cPlayer.Name);
          CoutPkt.AddString(Name);
          CoutPkt.AddString(fRanks[Members[Pos].Rank].Name);
          BroadCastToGuild(cOutPkt, B_EVENT);
        finally
          cOutPkt.Free;
        end;
      end;
    end;
  end;
end;

procedure YGaGuild.SayToGuild(cPlayer: YGaPlayer; Pkt: YNwServerPacket);
begin
  {@TODO Catch}
  if CheckRights(cPlayer,RIGHT_CHAT_SPEAK) then
    BroadCastToGuild(Pkt, B_CHAT)
  else
    ReportCommandResult(cPlayer, TYPE_INVITE, INV_PERMISSION, #0)
end;

procedure YGaGuild.SayToOfficer(cPlayer: YGaPlayer; Pkt: YNwServerPacket);
begin
  {@TODO Catch}
  if CheckRights(cPlayer, RIGHT_OFFICER_CHAT_SPEAK) then
    BroadCastToGuild(Pkt, B_Officer)
  else
    ReportCommandResult(cPlayer, TYPE_INVITE, INV_PERMISSION, #0)
end;

procedure YGaGuild.SaveToDB;
begin
 { Nothing }
end;

constructor YGaGuild.Create(Leader: YGaPlayer; ID: UInt32; Name: String);
begin
  { creates new guild from ashes }
  CreateDefaultRanks;
  fId := Id;
  fName := Name;
  fMOTD := 'YAWE Guild Creator';
  fINFO := 'Test';
  fEmblemStyle := 0;
  fEmblemColor := 0;
  fAccountsSize := 0;
  fDate := Now();

  fMembers := TPtrArrayList.Create;

  fLeader := AddMember(Leader, 0);

  PrepareQueryPacket;

  ReportCommandResult(Leader, TYPE_FOUNDER, FOU_NEW_GUILD, Name);

  fLoad := True;
end;

destructor YGaGuild.Destroy;
begin
  fMembers.Free;
  RosterPkt.Free;
  QueryPkt.Free;
  GameCore.DeleteGuild(fID);
  { @TODO Clear run time Db }
end;


end.
