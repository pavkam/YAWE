{*------------------------------------------------------------------------------
  In-Game Channels Support
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}
{$I compiler.inc}
unit Components.GameCore.Channel;

interface

uses
  Framework.Base,
  Components.NetworkCore.Packet,
  Components.GameCore.WowObject,
  Components.GameCore.WowPlayer,
  Misc.Miscleanous,
  Misc.Containers;

const
  CHN_NOTIFY_JOINED       = 0;
  CHN_NOTIFY_LEFT         = 1;
  CHN_NOTIFY_SELF_JOINED  = 2;
  CHN_NOTIFY_SELF_LEFT    = 3;
  CHN_NOTIFY_WRONG_PASS   = 4;
  CHN_NOTIFY_SELF_OFFLINE = 5;
  CHN_NOTIFY_NOT_MOD      = 6;
  CHN_NOTIFY_SET_PASS     = 7;
  CHN_NOTIFY_OWNER_CHANGE = 8;
  CHN_NOTIFY_OFFLINE      = 9;
  CHN_NOTIFY_NOT_OWNER    = 10;
  CHN_NOTIFY_WHO_OWNER    = 11;
  CHN_NOTIFY_MODE_CHANGE  = 12;
  CHN_NOTIFY_ANNOUNCE_E   = 13;
  CHN_NOTIFY_ANNOUNCE_D   = 14;
  CHN_NOTIFY_MODERATE_E   = 15;
  CHN_NOTIFY_MODERATE_D   = 16;
  CHN_NOTIFY_SILENCED     = 17;
  CHN_NOTIFY_KICKED       = 18;
  CHN_NOTIFY_BANNED       = 19;
  CHN_NOTIFY_BAN_PLAYER   = 20;
  CHN_NOTIFY_UNBAN_PLAYER = 21;
  { Is 22 unused ? }
  CHN_NOTIFY_ALREADY_IN   = 23;
  CHN_NOTIFY_INVITER      = 24;
  CHN_NOTIFY_WRONG_SIDE   = 25;
  { Is 26-28 unusued ? }
  CHN_NOTIFY_INVITEE      = 29;

  CHN_RIGHT_CHANGE_MOD    = 2;
  CHN_RIGHT_CHANGE_VOICE  = 4;

type
  YChannelRight = (crMod, crMuted);
  YChannelRights = set of YChannelRight;

  YChannelFlag = (cfAnnounce, cfModerated, cfStatic);
  YChannelFlags = set of YChannelFlag;

  PChannelPlayerInfo = ^YChannelPlayerInfo;
  YChannelPlayerInfo = record
    Player: YGaPlayer;
    Rights: YChannelRights;
  end;

  YGaChannel = class(TBaseObject)
    protected
      fName: string;
      fPassword: string;
      fOwner: YGaPlayer;
      fListeners: TPtrPtrHashMap;
      { Maybe there's a better idea than just have a separate "banned" container }
      fBanned: TIntArrayList;
      fChannelFlags: YChannelFlags;

      { Inlined methods }
      function IsPlayerOn(cPlayer: YGaPlayer): Boolean; overload; inline;
      function IsPlayerOn(const sName: string; var cPlayer: YGaPlayer): Int32; overload; inline;
      function IsPlayerModerator(cPlayer: YGaPlayer): Boolean; inline;
      function IsPlayerBanned(cPlayer: YGaPlayer): Boolean; inline;
      function IsPlayerMuted(cPlayer: YGaPlayer): Boolean; inline;
      function GetListenerCount: Int32; inline;

      { Internal packet methods }
      function PrepareChannelPacket(ChatPktType: UInt8): YNwServerPacket; inline;
      function GetObjectCount: Int32;

      procedure AddPlayer(cPlayer: YGaPlayer);
      procedure RemovePlayer(cPlayer: YGaPlayer);
    public
      constructor Create; 
      destructor Destroy; override;

      procedure DispatchPacketToAll(cPacket: YNwServerPacket);
      
      procedure SetChannelData(const sChannelName: string; const sPassword: string = '';
        aFlags: YChannelFlags = [cfAnnounce]; cOwner: YGaPlayer = nil);

      function Join(cPlayer: YGaPlayer; const sPassword: string = ''): Boolean;
      function Leave(cPlayer: YGaPlayer; bOnGameExit: Boolean = False): Boolean;
      procedure ListRequest(cPlayer: YGaPlayer);
      procedure SendInvitation(cPlayer: YGaPlayer; const sInvitee: string);
      procedure Say(cPlayer: YGaPlayer; const sMessage: string);
      procedure Kick(cPlayer: YGaPlayer; const sTarget: string);
      procedure ChangePassword(cPlayer: YGaPlayer; const sNewPass: string);

      procedure ChangeBanRight(cPlayer: YGaPlayer; const sTarget: string; bAdd: Boolean);
      procedure ChangeModerateRight(cPlayer: YGaPlayer; const sTarget: string; bAdd: Boolean);
      procedure ChangeMutedRight(cPlayer: YGaPlayer; const sTarget: string; bAdd: Boolean);
      procedure ChangeOwner(cPlayer: YGaPlayer; const sNewOwner: string);
      procedure QueryOwner(cPlayer: YGaPlayer);

      procedure ChangeChannelFlag(cPlayer: YGaPlayer; iFlag: YChannelFlag; bAdd: Boolean);

      function IsModerated: Boolean; inline;
      function IsAnnounce: Boolean; inline;
      function IsStatic: Boolean; inline;
      
      property Name: string read fName;
      property Password: string read fPassword;
      property Owner: YGaPlayer read fOwner;
      property ListenerCount: Int32 read GetObjectCount;
  end;

implementation

uses
  Framework,
  Cores,
  Components.GameCore,
  Components.Shared,
  Components.GameCore.Constants,
  Components.GameCore.PacketBuilders,
  Components.DataCore.Types,
  Components.NetworkCore.Opcodes;

{ YChannel }

function YGaChannel.IsPlayerOn(cPlayer: YGaPlayer): Boolean;
begin
  Result := fListeners.ContainsKey(cPlayer);
end;

function YGaChannel.IsPlayerOn(const sName: string; var cPlayer: YGaPlayer): Int32;
begin
  Result := Int32(GameCore.FindPlayerByName(sName, cPlayer));
  if Result = 0 then
  begin
    if not IsPlayerOn(cPlayer) then Result := 3;
  end;
end;

function YGaChannel.PrepareChannelPacket(ChatPktType: UInt8): YNwServerPacket;
begin
  Result := YNwServerPacket.Initialize(SMSG_CHANNEL_NOTIFY);
  Result.AddUInt8(ChatPktType);
  Result.AddString(fName);
end;

procedure YGaChannel.Say(cPlayer: YGaPlayer; const sMessage: string);
var
  pInfo: PChannelPlayerInfo;
  cOutPkt: YNwServerPacket;
begin
  pInfo := fListeners.GetValue(cPlayer);
  if pInfo = nil then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_SELF_OFFLINE);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end else
  begin
    if crMuted in pInfo^.Rights then
    begin
      cOutPkt := PrepareChannelPacket(CHN_NOTIFY_SILENCED);
      try
        cPlayer.SendPacket(cOutPkt);
      finally
        cOutPkt.Free;
      end;
    end else if (cfModerated in fChannelFlags) and not (crMod in pInfo^.Rights) then
    begin
      cOutPkt := PrepareChannelPacket(CHN_NOTIFY_NOT_MOD);
      try
        cPlayer.SendPacket(cOutPkt);
      finally
        cOutPkt.Free;
      end;
    end else
    begin
      cOutPkt := BuildChatPacket(cPlayer, CHAT_MSG_CHANNEL, glUniversal, @sMessage[1],
        Length(sMessage), fName);
      try
        DispatchPacketToAll(cOutPkt);
      finally
        cOutPkt.Free;
      end;
    end;
  end;
end;

procedure YGaChannel.DispatchPacketToAll(cPacket: YNwServerPacket);
var
  Itr: IPtrIterator;
begin
  Itr := fListeners.KeySet;
  while Itr.HasNext do
  begin
    YGaPlayer(Itr.Next).SendPacket(cPacket);
  end;
end;

procedure YGaChannel.SetChannelData(const sChannelName, sPassword: string;
  aFlags: YChannelFlags; cOwner: YGaPlayer);
begin
  fName := sChannelName;
  fPassword := sPassword;
  fChannelFlags := aFlags;
  fOwner := cOwner;
end;

procedure YGaChannel.SendInvitation(cPlayer: YGaPlayer; const sInvitee: string);
var
  cOutPkt: YNwServerPacket;
  cInvitee: YGaPlayer;
begin
  if not IsPlayerOn(cPlayer) then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_SELF_OFFLINE);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end else
  begin
    if GameCore.FindPlayerByName(sInvitee, cInvitee) = lrOnline then
    begin
      if IsPlayerOn(cInvitee) then
      begin
        cOutPkt := PrepareChannelPacket(CHN_NOTIFY_ALREADY_IN);
        try
          cOutPkt.AddString(sInvitee);
          cPlayer.SendPacket(cOutPkt);
        finally
          cOutPkt.Free;
        end;
      end else
      begin
        cOutPkt := PrepareChannelPacket(CHN_NOTIFY_INVITER);
        try
          cOutPkt.AddPtrData(cPlayer.GUID, 8);
          cInvitee.SendPacket(cOutPkt);
        finally
          cOutPkt.Free;
        end;

        cOutPkt := PrepareChannelPacket(CHN_NOTIFY_INVITEE);
        try
          cOutPkt.AddString(sInvitee);
          cPlayer.SendPacket(cOutPkt);
        finally
          cOutPkt.Free;
        end;
      end;
    end else
    begin
      cOutPkt := PrepareChannelPacket(CHN_NOTIFY_OFFLINE);
      try
        cOutPkt.AddString(sInvitee);
        cPlayer.SendPacket(cOutPkt);
      finally
        cOutPkt.Free;
      end;
    end;
  end;
end;

const
  ResTable: array[Boolean, Boolean] of Int32 = (
    (0, 1),
    (-1, 0)
  );

procedure YGaChannel.AddPlayer(cPlayer: YGaPlayer);
var
  pInfo: PChannelPlayerInfo;
  cOutPkt: YNwServerPacket;
begin
  if IsAnnounce then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_JOINED);
    try
      cOutPkt.AddPtrData(cPlayer.GUID, 8);
      DispatchPacketToAll(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end;

  New(pInfo);
  pInfo^.Player := cPlayer;
  pInfo^.Rights := [];
  fListeners.PutValue(cPlayer, pInfo);
end;

procedure YGaChannel.ChangeBanRight(cPlayer: YGaPlayer; const sTarget: string; bAdd: Boolean);
var
  cTarget: YGaPlayer;
  cOutPkt: YNwServerPacket;
  iRes: Int32;
begin
  if not IsPlayerOn(cPlayer) then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_SELF_OFFLINE);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end else if IsPlayerOn(sTarget, cTarget) < 0 then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_OFFLINE);
    try
      cOutPkt.AddString(sTarget);
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end else if IsPlayerModerator(cPlayer) then
  begin
    iRes := ResTable[bAdd, fBanned.IndexOf(cTarget.GUIDLo) <> -1];
    if iRes <> 0 then
    begin
      if iRes = -1 then
      begin
        fBanned.Add(cTarget.GUIDLo);
        cOutPkt := PrepareChannelPacket(CHN_NOTIFY_BAN_PLAYER);
      end else
      begin
        fBanned.Remove(cTarget.GUIDLo);
        cOutPkt := PrepareChannelPacket(CHN_NOTIFY_UNBAN_PLAYER);
      end;
      try
        cOutPkt.AddPtrData(cTarget.GUID, 8);
        cOutPkt.AddPtrData(cPlayer.GUID, 8);
        DispatchPacketToAll(cOutPkt);
      finally
        cOutPkt.Free;
      end;
      if iRes = 1 then cTarget.Chat.SystemMessage('You were unbanned from channel ' + fName + '.');
    end;
  end else
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_NOT_MOD);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end;
end;

procedure YGaChannel.ChangeChannelFlag(cPlayer: YGaPlayer; iFlag: YChannelFlag; bAdd: Boolean);
const
  TypeTable: array[YChannelFlag, Boolean] of UInt8 = (
    (CHN_NOTIFY_ANNOUNCE_D, CHN_NOTIFY_ANNOUNCE_E),
    (CHN_NOTIFY_MODERATE_D, CHN_NOTIFY_MODERATE_E),
    (0, 0)
  );
var
  cOutPkt: YNwServerPacket;
  iRes: Int32;
begin
  if not IsPlayerOn(cPlayer) then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_SELF_OFFLINE);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end else if IsPlayerModerator(cPlayer) then
  begin
    iRes := ResTable[bAdd, iFlag in fChannelFlags];
    if iRes <> 0 then
    begin
      if iRes = -1 then
      begin
        cOutPkt := PrepareChannelPacket(TypeTable[iFlag, True]);
      end else
      begin
        cOutPkt := PrepareChannelPacket(TypeTable[iFlag, False]);
      end;
      try
        cOutPkt.AddPtrData(cPlayer.GUID, 8);
        DispatchPacketToAll(cOutPkt);
      finally
        cOutPkt.Free;
      end;
    end;
  end else
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_NOT_MOD);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end;
end;

procedure YGaChannel.ChangeModerateRight(cPlayer: YGaPlayer; const sTarget: string; bAdd: Boolean);
var
  cTarget: YGaPlayer;
  cOutPkt: YNwServerPacket;
  pInfo: PChannelPlayerInfo;
  iRes: Int32;
begin
  if not IsPlayerOn(cPlayer) then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_SELF_OFFLINE);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end else if IsPlayerOn(sTarget, cTarget) < 0 then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_OFFLINE);
    try
      cOutPkt.AddString(sTarget);
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end else if IsPlayerModerator(cPlayer) then
  begin
    pInfo := fListeners.GetValue(cTarget);
    iRes := ResTable[bAdd, crMod in pInfo^.Rights];
    if iRes <> 0 then
    begin
      { First byte after the GUID indicates which right was removed,
        the second one which was added }
      cOutPkt := PrepareChannelPacket(CHN_NOTIFY_MODE_CHANGE);
      try
        cOutPkt.AddPtrData(cTarget.GUID, 8);
        if iRes = -1 then
        begin
          Include(pInfo^.Rights, crMod);
          cOutPkt.AddUInt8(0);
          cOutPkt.AddUInt8(CHN_RIGHT_CHANGE_MOD);
        end else
        begin
          Exclude(pInfo^.Rights, crMod);
          cOutPkt.AddUInt8(CHN_RIGHT_CHANGE_MOD);
          cOutPkt.AddUInt8(0);
        end;
        DispatchPacketToAll(cOutPkt);
      finally
        cOutPkt.Free;
      end;
    end;
  end else
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_NOT_MOD);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end;
end;

procedure YGaChannel.ChangeMutedRight(cPlayer: YGaPlayer; const sTarget: string; bAdd: Boolean);
var
  cTarget: YGaPlayer;
  cOutPkt: YNwServerPacket;
  pInfo: PChannelPlayerInfo;
  iRes: Int32;
begin
  if not IsPlayerOn(cPlayer) then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_SELF_OFFLINE);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end else if IsPlayerOn(sTarget, cTarget) < 0 then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_OFFLINE);
    try
      cOutPkt.AddString(sTarget);
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end else if IsPlayerModerator(cPlayer) then
  begin
    pInfo := fListeners.GetValue(cTarget);
    iRes := ResTable[bAdd, crMuted in pInfo^.Rights];
    if iRes <> 0 then
    begin
      { First byte after the GUID indicates which right was removed,
        the second one which was added }
      cOutPkt := PrepareChannelPacket(CHN_NOTIFY_MODE_CHANGE);
      try
        cOutPkt.AddPtrData(cTarget.GUID, 8);
        if iRes = -1 then
        begin
          Include(pInfo^.Rights, crMuted);
          cOutPkt.AddUInt8(0);
          cOutPkt.AddUInt8(CHN_RIGHT_CHANGE_VOICE);
        end else
        begin
          Exclude(pInfo^.Rights, crMuted);
          cOutPkt.AddUInt8(CHN_RIGHT_CHANGE_VOICE);
          cOutPkt.AddUInt8(0);
        end;
        DispatchPacketToAll(cOutPkt);
      finally
        cOutPkt.Free;
      end;
    end;
  end else
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_NOT_MOD);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end;
end;

procedure YGaChannel.ChangeOwner(cPlayer: YGaPlayer; const sNewOwner: string);
var
  cTarget: YGaPlayer;
  pInfo: PChannelPlayerInfo;
  cOutPkt: YNwServerPacket;
begin
  if not IsPlayerOn(cPlayer) then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_SELF_OFFLINE);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end else if (cPlayer = fOwner) then//or (cPlayer.Security >= aaGm) then
  begin
    if not IsStatic then
    begin
      if IsPlayerOn(sNewOwner, cTarget) = 0 then
      begin
        fOwner := cTarget;
        pInfo := fListeners.GetValue(cTarget);
        Include(pInfo^.Rights, crMod);
        cOutPkt := PrepareChannelPacket(CHN_NOTIFY_OWNER_CHANGE);
        try
          cOutPkt.AddPtrData(cTarget.GUID, 8);
          DispatchPacketToAll(cOutPkt);
        finally
          cOutPkt.Free;
        end;
      end else
      begin
        cOutPkt := PrepareChannelPacket(CHN_NOTIFY_OFFLINE);
        try
          cOutPkt.AddString(sNewOwner);
          cPlayer.SendPacket(cOutPkt);
        finally
          cOutPkt.Free;
        end;
      end;
    end else cPlayer.Chat.SystemMessage('A static channel cannot have an owner.');
  end else
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_NOT_OWNER);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end;
end;

procedure YGaChannel.QueryOwner(cPlayer: YGaPlayer);
var
  cOutPkt: YNwServerPacket;
  sName: string;
begin
  if not IsPlayerOn(cPlayer) then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_SELF_OFFLINE);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end else
  begin
    if IsStatic then
    begin
      sName := 'No owner';
    end else
    begin
      sName := fOwner.Name;
    end;
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_WHO_OWNER);
    try
      cOutPkt.AddString(sName);
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end;
end;

procedure YGaChannel.RemovePlayer(cPlayer: YGaPlayer);
var
  pInfo: PChannelPlayerInfo;
  cOutPkt: YNwServerPacket;
begin
  pInfo := fListeners.Remove(cPlayer);
  if pInfo <> nil then
  begin
    Dispose(pInfo);
    if IsAnnounce then
    begin
      cOutPkt := PrepareChannelPacket(CHN_NOTIFY_LEFT);
      try
        cOutPkt.AddPtrData(cPlayer.GUID, 8);
        DispatchPacketToAll(cOutPkt);
      finally
        cOutPkt.Free;
      end;
    end;
  end;
end;

procedure YGaChannel.ChangePassword(cPlayer: YGaPlayer; const sNewPass: string);
var
  cOutPkt: YNwServerPacket;
begin
  if not IsPlayerOn(cPlayer) then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_SELF_OFFLINE);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end else if IsPlayerModerator(cPlayer) then
  begin
    fPassword := sNewPass;
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_SET_PASS);
    try
      cOutPkt.AddPtrData(cPlayer.GUID, 8);
      DispatchPacketToAll(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end else
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_NOT_MOD);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end;
end;

function YGaChannel.GetListenerCount: Int32;
begin
  Result := fListeners.Size;
end;

function YGaChannel.GetObjectCount: Int32;
begin
  Result := fListeners.Size;
end;

function YGaChannel.IsAnnounce: Boolean;
begin
  Result := cfAnnounce in fChannelFlags;
end;

function YGaChannel.IsStatic: Boolean;
begin
  Result := cfStatic in fChannelFlags;
end;

function YGaChannel.IsModerated: Boolean;
begin
  Result := cfModerated in fChannelFlags;
end;

function YGaChannel.IsPlayerBanned(cPlayer: YGaPlayer): Boolean;
begin
  Result := fBanned.Contains(cPlayer.GUIDLo);
end;

function YGaChannel.IsPlayerModerator(cPlayer: YGaPlayer): Boolean;
var
  pInfo: PChannelPlayerInfo;
begin
  if False then//cPlayer.Security >= aaGm then
  begin
    Result := True;
  end else
  begin
    pInfo := fListeners.GetValue(cPlayer);
    if pInfo <> nil then
    begin
      Result := crMod in pInfo^.Rights;
    end else
    begin
      Result := False;
    end;
  end;
end;

function YGaChannel.IsPlayerMuted(cPlayer: YGaPlayer): Boolean;
var
  pInfo: PChannelPlayerInfo;
begin
  pInfo := fListeners.GetValue(cPlayer);
  if pInfo <> nil then
  begin
    Result := crMuted in pInfo^.Rights;
  end else
  begin
    Result := False;
  end;
end;

function YGaChannel.Join(cPlayer: YGaPlayer; const sPassword: string = ''): Boolean;
var
  cOutPkt: YNwServerPacket;
begin
  if IsPlayerOn(cPlayer) then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_ALREADY_IN);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
    Result := False;
  end else if IsPlayerBanned(cPlayer) then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_BANNED);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
    Result := False;
  end else if sPassword <> fPassword then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_WRONG_PASS);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
    Result := False;
  end else
  begin
    AddPlayer(cPlayer);
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_SELF_JOINED);
    try
      cOutPkt.AddPtrData(cPlayer.GUID, 8);
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
    Result := True;
  end;
end;

procedure YGaChannel.Kick(cPlayer: YGaPlayer; const sTarget: string);
var
  cTarget: YGaPlayer;
  cOutPkt: YNwServerPacket;
begin
  if not IsPlayerOn(cPlayer) then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_SELF_OFFLINE);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end else if IsPlayerOn(sTarget, cTarget) < 0 then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_OFFLINE);
    try
      cOutPkt.AddString(sTarget);
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end else if IsPlayerModerator(cPlayer) then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_KICKED);
    try
      cOutPkt.AddPtrData(cPlayer.GUID, 8);
      cOutPkt.AddPtrData(cTarget.GUID, 8);
      DispatchPacketToAll(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end else
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_NOT_MOD);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end;
end;

function YGaChannel.Leave(cPlayer: YGaPlayer; bOnGameExit: Boolean = False): Boolean;
var
  cOutPkt: YNwServerPacket;
begin
  if not IsPlayerOn(cPlayer) then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_SELF_OFFLINE);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
    Result := False;
  end else
  begin
    RemovePlayer(cPlayer);

    if not bOnGameExit then
    begin
      cOutPkt := PrepareChannelPacket(CHN_NOTIFY_SELF_LEFT);
      try
        cPlayer.SendPacket(cOutPkt);
      finally
        cOutPkt.Free;
      end;
    end;
    Result := True;
  end;
end;

procedure YGaChannel.ListRequest(cPlayer: YGaPlayer);
var
  cOutPkt: YNwServerPacket;
  ifItr: IPtrIterator;
  pInfo: PChannelPlayerInfo;
  bMode: UInt8;
begin
  if not IsPlayerOn(cPlayer) then
  begin
    cOutPkt := PrepareChannelPacket(CHN_NOTIFY_SELF_OFFLINE);
    try
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end else
  begin
    cOutPkt := YNwServerPacket.Initialize(SMSG_CHANNEL_LIST);
    try
      cOutPkt.AddUInt8(3); { $03 ??? }
      cOutPkt.AddUInt32(fListeners.Size);
      ifItr := fListeners.Values;
      while ifItr.HasNext do
      begin
        pInfo := ifItr.Next;
        cOutPkt.AddPtrData(pInfo^.Player.GUID, 8);
        bMode := 0;
        if IsPlayerModerator(pInfo^.Player) then bMode := CHN_RIGHT_CHANGE_MOD;
        if IsPlayerMuted(pInfo^.Player) then bMode := bMode or CHN_RIGHT_CHANGE_VOICE;
        cOutPkt.AddUInt8(bMode);
      end;
      cPlayer.SendPacket(cOutPkt);
    finally
      cOutPkt.Free;
    end;
  end;
end;

destructor YGaChannel.Destroy;
var
  ifItr: IPtrIterator;
begin
  ifItr := fListeners.Values;
  while ifItr.HasNext do
  begin
    Dispose(PChannelPlayerInfo(ifItr.Next));
  end;
  fListeners.Free;
  fBanned.Free;
  inherited Destroy;
end;

constructor YGaChannel.Create;
begin
  inherited Create;
  fListeners := TPtrPtrHashMap.Create(128);
  fBanned := TIntArrayList.Create(32);
end;

end.
