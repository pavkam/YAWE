{*------------------------------------------------------------------------------
  World ( Realm ) Server.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth, TheSelby
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.NetworkCore.World;

interface

uses
  Framework.Base,
  Version,
  Framework.Tick,
  Components.IoCore.Sockets,
  Components.DataCore,
  Components.DataCore.Types,
  Components.GameCore.Session,
  Components.NetworkCore.Packet,
  Components.NetworkCore.HdrXor,
  Components.NetworkCore.Constants,
  Components.NetworkCore.Opcodes,
  Components.NetworkCore.SRP6,
  Components.Interfaces,
  Bfg.Compression,
  Bfg.Containers,
  Bfg.Utils,
  Bfg.Threads,
  SysUtils;

type
  YNwWorldSocketManager = class;

  { Provides connection with client ... etc }
  YNwWorldSocket = class(YIoClientSocket, ISocketInterface)
    private
      FHdrXorData: YEncryptionContext;
      FRecvBuffer: TCircularBuffer;
      FSendBuffer: TCircularBuffer;
      FSession: YGaSession;
      FQueueId: Integer;
      FSeed: UInt32;
      FAccount: IAccountEntry;
      FAddons: TIntfArrayList;
      FCurrentInPkt: YNwClientPacket;

      procedure ProcessInputBuffer;
      procedure ProcessOutputBuffer;
      procedure ProcessBuffers;

      { Interface Imported Methods }
      procedure SessionSendPacket(Pkt: YNwServerPacket); inline;
      procedure SessionSetAuthKey(const Hash: YAccountHash); inline;
      procedure SessionSetQueuePosition(NewPos: Integer); inline;
      function SessionGetQueuePosition: Integer; inline;
      procedure ISocketInterface.SessionDisconnect = Disconnect;
      procedure SessionForceFlushBuffers;
      procedure UpdateQueuePosition(Pos: Integer); inline;

      procedure InitiateAuthSession; { Initiates Auth Session }
      procedure HandleAuthResponse(InPkt: YNwClientPacket);
      { Client Auth Response }
      procedure HandleClientPing(InPkt: YNwClientPacket);
      procedure HandleAUnk206Opcode(InPkt: YNwClientPacket);
      { Ping event  }
      procedure SendAuthResponse(ErrorCode: Int32; WaitQueueId: Int32 = 0);
      procedure SendAddonInformation;
      function ValidateAddOns(InPkt: YNwPacket): Boolean;
      procedure ProcessOpcode(InPkt: YNwClientPacket; Opcode: UInt32);

      procedure ISocketInterface.QueueLockAcquire = Lock;
      procedure ISocketInterface.QueueLockRelease = Unlock;
    protected
      procedure Initialize; override;
    public
      destructor Destroy; override;

      property Session: YGaSession read FSession;
    end;

  YNwWorldSocketManager = class(YIoSocketServer)
    private
      const
        WORLD_THREAD_COUNT = 3;

      var
        FUpdateHandle: TEventHandle;
        FWorldSockets: TPtrArrayList;
        FQueueIdHigh: Integer;
        FLock: TCriticalSection;
        
    protected
      class function GetSocketClass: YIoClientSocketClass; override;
      procedure RegisterWorldSocket(Socket: YNwWorldSocket);
      procedure UnregisterWorldSocket(Socket: YNwWorldSocket);
      procedure ProcessPackets(Event: TEventHandle; TimeDelta: UInt32);
    public
      constructor Create;
      destructor Destroy; override;
      
      function GetSocketByAccount(const AccName: WideString): YNwWorldSocket;
      procedure OnAccept(Sender: YIoSocketServer; Socket: YIoClientSocket);
      procedure OnRead(Sender: YIoSocketServer; Socket: YIoClientSocket; Data: Pointer; Size: Integer);
      procedure OnClose(Sender: YIoSocketServer; Socket: YIoClientSocket);
    end;

implementation

uses
  Cores,
  Bfg.Resources,
  Framework.SocketBase,
  Framework;

{ YNwWorldSocketManager }

constructor YNwWorldSocketManager.Create;
begin
  inherited Create(WORLD_THREAD_COUNT + SysConf.ReadInteger('Network', 'ExtraRealmWorkers', 0),
    1 + SysConf.ReadInteger('Network', 'ExtraRealmListeners', 0),
    SysConf.ReadInteger('Network', 'TimeoutDelay', 0) * 1000);
  FWorldSockets := TPtrArrayList.Create(512);
  FLock.Init;

  OnSocketAccept := TSocketAcceptEvent(MakeMethod(@YNwWorldSocketManager.OnAccept, Self));
  OnSocketClose := TSocketDisconnectEvent(MakeMethod(@YNwWorldSocketManager.OnClose, Self));
  OnSocketRead := TSocketReadEvent(MakeMethod(@YNwWorldSocketManager.OnRead, Self));

  FUpdateHandle := SysEventMgr.RegisterEvent(ProcessPackets, NETWORK_UPD_INTERVAL,
    TICK_EXECUTE_INFINITE, 'WorldSocketManager_Update_Event');
end;

destructor YNwWorldSocketManager.Destroy;
begin
  FUpdateHandle.Unregister;
  FWorldSockets.Free;
  FLock.Delete;
  inherited Destroy;
end;

class function YNwWorldSocketManager.GetSocketClass: YIoClientSocketClass;
begin
  Result := YNwWorldSocket;
end;

function YNwWorldSocketManager.GetSocketByAccount(const AccName: WideString): YNwWorldSocket;
var
  I: Integer;
begin
  FLock.Enter;
  try
    for I := 0 to FWorldSockets.Size - 1 do
    begin
      Result := FWorldSockets[I];
      if StringsEqual(Result.FAccount.Name, AccName) then Exit;
    end;
  finally
    FLock.Leave;
  end;
  Result := nil;
end;

procedure YNwWorldSocketManager.RegisterWorldSocket(Socket: YNwWorldSocket);
begin
  FLock.Enter;
  try
    FWorldSockets.Add(Socket);
  finally
    FLock.Leave;
  end;
  AtomicInc(@FQueueIdHigh);
  Socket.FQueueId := FQueueIdHigh;
end;

procedure YNwWorldSocketManager.UnregisterWorldSocket(Socket: YNwWorldSocket);
var
  I: Integer;
  PosNow: Integer;
  Temp: YNwWorldSocket;
begin
  PosNow := Socket.FQueueId;
  if PosNow = FQueueIdHigh then
  begin
    AtomicDec(@FQueueIdHigh);
  end else
  begin
    { Update the waiting queue }
    for I := 0 to FWorldSockets.Size - 1 do
    begin
      Temp := FWorldSockets.Items[I];
      if Temp.FQueueId > PosNow then
      begin
        if Temp.FQueueId = FQueueIdHigh then AtomicDec(@FQueueIdHigh);
        { Update Queue Position for each Session }
        Dec(Temp.FQueueId);
        Temp.UpdateQueuePosition(Temp.FQueueId); { If Position == 0 will send OK as Auth }
      end;
    end;
  end;
end;

procedure YNwWorldSocketManager.ProcessPackets(Event: TEventHandle; TimeDelta: UInt32);
var
  I: Integer;
begin
  FLock.Enter;
  try
    for I := 0 to FWorldSockets.Size - 1 do
    begin
      YNwWorldSocket(FWorldSockets.Items[I]).ProcessBuffers;
    end;
  finally
    FLock.Leave;
  end;
end;

procedure YNwWorldSocketManager.OnAccept(Sender: YIoSocketServer; Socket: YIoClientSocket);
var
  WorldSocket: YNwWorldSocket;
begin
  WorldSocket := YNwWorldSocket(Socket);
  IoCore.Console.WriteConnectInfoWS(WorldSocket.LocalAddress, WorldSocket.LocalPort);
  RegisterWorldSocket(WorldSocket);
  WorldSocket.InitiateAuthSession;
end;

procedure YNwWorldSocketManager.OnRead(Sender: YIoSocketServer; Socket: YIoClientSocket;
  Data: Pointer; Size: Integer);
var
  WorldSocket: YNwWorldSocket;
begin
  WorldSocket := YNwWorldSocket(Socket);
  WorldSocket.Lock;
  try
    WorldSocket.FRecvBuffer.Write(Data^, Size);
  finally
    WorldSocket.Unlock;
  end;
end;

procedure YNwWorldSocketManager.OnClose(Sender: YIoSocketServer; Socket: YIoClientSocket);
var
  WorldSocket: YNwWorldSocket;
begin
  WorldSocket := YNwWorldSocket(Socket);
  FLock.Enter;
  try
    FWorldSockets.Remove(WorldSocket);
    UnregisterWorldSocket(WorldSocket);
  finally
    FLock.Leave;
  end;
  IoCore.Console.WriteDisconnectInfoWS(WorldSocket.LocalAddress, WorldSocket.LocalPort);
end;

{ YNwWorldSocket }

const
  BlizzardAddonSignature = $4C1C776D;

procedure YNwWorldSocket.HandleAuthResponse(InPkt: YNwClientPacket);
type
  PAuthDigest = ^YAuthDigest;
  YAuthDigest = array[0..19] of Byte;
var
  DigestPtr: PAuthDigest;
  ClientSeed: Longword;
  AccountName: WideString;
  MaxAllowed: Integer;
  ExpSize: Integer;
  Child: YNwPacket;
  Data: Pointer;
  Hash: YAccountHash;
  LookupRes: ILookupResult;
begin
  InPkt.Skip(8); { unknown }
  AccountName := InPkt.ReadString;
  ClientSeed := InPkt.ReadUInt32;
  DigestPtr := InPkt.GetReadPtrOfSize(20); { SHA1 Digest from client }

  DataCore.Accounts.LookupEntryListW('Name', AccountName, False, LookupRes,
    False);

  if not Assigned(LookupRes) then
  begin
    SessionForceFlushBuffers; { Send all data }
    Disconnect; { Signal disconnect the client }
    Exit;
  end;

  LookupRes.GetData(FAccount, 1);

  { Help for RE Sniffer to gain the key faster. Win32, debug dependant code }
  {$IFDEF DBG_SNIFFER}
  PostSnifferData(atoh(sAccountName), cAcc.Hash);
  {$ENDIF}

  { Apply Encryption Key }
  Hash := FAccount.Hash;
  SessionSetAuthKey(Hash);

  { Checking Account Status }
  case FAccount.Status of
    asLocked, asBanned, asPayNotify:
    begin
      SendAuthResponse(AUTH_REJECT);
      SessionForceFlushBuffers; { Send all data }
      Disconnect; { Signal disconnect the client }
      Exit;
    end;
  end;

  (*
  if Assigned(NetworkCore.WorldServer.GetSocketByAccount(AccountName)) then
  begin
    { Another user with the same account is already logged in }
    SendAuthResponse(AUTH_ALREADY_LOGGING_IN);
    SessionForceFlushBuffers; { Send all data }
    Disconnect; { Signal disconnect the client }
    Exit;
  end;
  *)

  if not CheckAuthDigest(ClientSeed, FSeed, @Hash[0], DigestPtr, AccountName) then
  begin
    { It seems that the password and/or account provided are incorrect }
    SendAuthResponse(AUTH_FAILED {AUTH_BAD_SERVER_PROOF});
    SessionForceFlushBuffers; { Send all data }
    Disconnect; { Signal disconnect the client }
    Exit;
  end;

  MaxAllowed := SysConf.ReadInteger('Network', 'Players', 0);

  if (MaxAllowed > 0) and (NetworkCore.RealmThreads >= MaxAllowed) then
  begin
    if FAccount.Access = aaNormal then
    begin
      SendAuthResponse(AUTH_WAIT_QUEUE, SessionGetQueuePosition);
      Exit;
    end;
  end;

  SessionSetQueuePosition(0); { Wait not needed! Reset }
  { Check for AddOns }
  ExpSize := InPkt.ReadUInt32; { Size of the expected compressed block }

  Child := YNwPacket.Create;
  try
    Data := Decompress(InPkt.GetCurrentReadPtr, InPkt.WritePos - InPkt.ReadPos,
      ExpSize);
    try
      Child.AddStruct(Data^, ExpSize);
    finally
      FreeMem(Data, ExpSize);
    end;

    ValidateAddOns(Child);
  finally
    Child.Free;
  end;

    { Let's see if Scripting accepts the user }
    //iAccept := cDataCore.Scripting.AcceptUser(sAccountName);
    //if iAccept <> AUTH_OK then
    //begin
    //  { Scripting returned an account error }
    //  SendAuthResponse(iAccept);
    //  fSocketLink.SessionForceFlushBuffers; { Send all data }
    //  fSocketLink.SessionDisconnect; { Signal disconnect the client }
    //  Exit;
    //end;

  { Creating an GameCore object }
  FSession := YGaSession.Create;
  FSession.Socket := Self; { Use the same packet data tunnel as NetworkCore for GameCore }
  FSession.Account := FAccount.Name;
  GameCore.AddSession(FSession); { Plug the session into the world }
  SendAuthResponse(AUTH_OK);
end;

procedure YNwWorldSocket.HandleClientPing(InPkt: YNwClientPacket);
var
  PongPkt: YNwServerPacket;
begin
  PongPkt := YNwServerPacket.Initialize(SMSG_PONG, 4);
  try
    PongPkt.AddUInt32(InPkt.ReadUInt32); { Sending the PONG Value }
    SessionSendPacket(PongPkt);
  finally
    PongPkt.Free;
  end;
end;

procedure YNwWorldSocket.HandleAUnk206Opcode(InPkt: YNwClientPacket);
var
  UnkValue: UInt32;
  OutPkt: YNwServerPacket;
begin
  UnkValue := InPkt.ReadUInt32;

  OutPkt := YNwServerPacket.Initialize(SMSG_NEW_WOW_TO_TBC_OPC_REALM);
  OutPkt.AddUInt32(UnkValue);
  OutPkt.JumpUInt32();
  OutPkt.AddString('01/01/01');

  SessionSendPacket(OutPkt);
end;

procedure YNwWorldSocket.Initialize;
const
  InputBufferSize = 1 shl 16; { 64k Buffer }
  OutputBufferSize = 1 shl 16;
begin
  FRecvBuffer := TCircularBuffer.Create(InputBufferSize);
  FSendBuffer := TCircularBuffer.Create(OutputBufferSize);
  FAddons := TIntfArrayList.Create;
end;

procedure YNwWorldSocket.InitiateAuthSession;
var
  OutPkt: YNwServerPacket;
begin
  { Selects the internal Seed Number and returns it to the client }
  FSeed := Random(-1);
  OutPkt := YNwServerPacket.Initialize(SMSG_AUTH_CHALLENGE, 4);
  try
    OutPkt.AddUInt32(FSeed);
    SessionSendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;
end;

destructor YNwWorldSocket.Destroy;
begin
  FRecvBuffer.Free;
  FSendBuffer.Free;
  FAddons.Free;
  FreeAndNil(FCurrentInPkt);
  if Assigned(FSession) then
  begin
    GameCore.RemoveSession(FSession);
    FSession.Free;
  end;
  inherited Destroy;
end;

procedure YNwWorldSocket.ProcessBuffers;
begin
  Lock;
  try
    ProcessInputBuffer;
    ProcessOutputBuffer;
  finally
    Unlock;
  end;
end;

procedure YNwWorldSocket.ProcessInputBuffer;
var
  PktHeader: YWorldClientHeader;
  HdrPtr: PWorldClientHeader;
  Size: UInt16;
begin
  if FRecvBuffer.ReadAvail = 0 then Exit;

  repeat
    try
      if FCurrentInPkt = nil then
      begin
        if FRecvBuffer.ReadAvail < SizeOf(YWorldClientHeader) then Exit;
        FRecvBuffer.Read(PktHeader, SizeOf(PktHeader));
        HdrXorDecrypt(FHdrXorData, @PktHeader);
        Size := EndianSwap16(PktHeader.Size) + 2;
        FCurrentInPkt := YNwClientPacket.Create(Size);
        Move(PktHeader, FCurrentInPkt.Storage[0], SizeOf(YWorldClientHeader));
        Dec(Size, SizeOf(YWorldClientHeader));
        HdrPtr := @PktHeader;
      end else
      begin
        HdrPtr := FCurrentInPkt.Header;
        Size := FCurrentInPkt.Size - SizeOf(YWorldClientHeader);
      end;

      if not FHdrXorData.KeyValid then
      begin
        if (HdrPtr^.Opcode <> CMSG_AUTH_SESSION) and
           (HdrPtr^.Opcode <> CMSG_PING) then
        begin
          FRecvBuffer.Clear;
          Disconnect;
          Exit;
        end;
      end;

      if FRecvBuffer.ReadAvail >= Size then
      begin
        FRecvBuffer.Read(FCurrentInPkt.Storage[SizeOf(YWorldClientHeader)], Size);
        try
          FCurrentInPkt.WritePos := FCurrentInPkt.Size;
          ProcessOpCode(FCurrentInPkt, FCurrentInPkt.Header^.Opcode);
        finally
          FreeAndNil(FCurrentInPkt);
        end;
      end else Exit;
    except
      FreeAndNil(FCurrentInPkt);
      raise;
    end;
  until False;
end;

procedure YNwWorldSocket.ProcessOpcode(InPkt: YNwClientPacket; Opcode: UInt32);
var
  Handled: Boolean;
begin
  { NetworkCore Handlers }
  case Opcode of
    CMSG_AUTH_SESSION:
    begin
      if not FHdrXorData.KeyValid then
      begin
        HandleAuthResponse(InPkt);
        Handled := True;
      end else
      begin
        { Invalid, must be sent only once }
        Disconnect;
        Handled := False;
      end;
    end;
    CMSG_PING:
    begin
      HandleClientPing(InPkt);
      Handled := True;
    end;
    CMSG_NEW_WOW_TO_TBC_OPC_REALM:
    begin
      HandleAUnk206Opcode(InPkt);
      Handled := True;
    end
  else
    if Assigned(FSession) then
    begin
      Handled := FSession.DispatchOpcode(InPkt, Opcode); { Let GameCore deal with those }
    end else Handled := False;
  end;

  IoCore.Console.WriteOpcodeCall(Self, GetOpcodeName(Opcode), Opcode, Handled); { Write it quicky :) }
end;

procedure YNwWorldSocket.ProcessOutputBuffer;
begin
  if FSendBuffer.ReadAvail = 0 then Exit;

  Owner.SendData(Self, FSendBuffer[FSendBuffer.ReadPosition]^, FSendBuffer.ReadAvail);
  FSendBuffer.ReadPosition := FSendBuffer.ReadPosition + FSendBuffer.ReadAvail;
end;

procedure YNwWorldSocket.SessionSetAuthKey(const Hash: YAccountHash);
begin
  { Setting the encryption Key }
  Move(Hash, FHdrXorData.Key, KEY_SIZE);
  FHdrXorData.KeyValid := True;
end;

procedure YNwWorldSocket.SessionSendPacket(Pkt: YNwServerPacket);
begin
  Lock;
  try
    Pkt.Finalize(FHdrXorData, FSendBuffer);
    IoCore.Console.WriteWSSentPacketSize(Pkt);
  finally
    Unlock;
  end;
end;

function YNwWorldSocket.SessionGetQueuePosition: Integer;
begin
  { Returns current position in the wait queue}
  Result := FQueueId;
end;

procedure YNwWorldSocket.SessionSetQueuePosition(NewPos: Integer);
begin
  { Sets current queue to }
  FQueueId := NewPos;
end;

procedure YNwWorldSocket.UpdateQueuePosition(Pos: Integer);
begin
  if Pos = 0 then
  begin
    { This user has a slot now. }
    SendAuthResponse(AUTH_OK);
  end else
  begin
    { More waiting ahead ... }
    SendAuthResponse(AUTH_WAIT_QUEUE, Pos);
  end;
end;

procedure YNwWorldSocket.SendAddonInformation;
var
  OutPkt: YNwServerPacket;
begin
  OutPkt := YNwServerPacket.Initialize(SMSG_ADDON_INFORMATION, 0);
  try
    SessionSendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;
end;

procedure YNwWorldSocket.SendAuthResponse(ErrorCode, WaitQueueId: Int32);
type
  PAuthOkStruct = ^YAuthOkStruct;
  YAuthOkStruct = packed record
    Unk1: UInt32;
    Unk2: UInt32;
    Unk3: UInt8;
    IsTbcAccount: Boolean;
  end;
const
  AuthOkData: YAuthOkStruct = (
    Unk1: $FF4C1D10;
    Unk2: $42;
    Unk3: 0;
    IsTbcAccount: False;
  );
var
  OutPkt: YNwServerPacket;
begin
  { Sends the error code back to client }
  OutPkt := YNwServerPacket.Initialize(SMSG_AUTH_RESPONSE);
  try
    OutPkt.AddUInt8(ErrorCode);

    case ErrorCode of
      AUTH_OK: OutPkt.AddStruct(AuthOkData, SizeOf(AuthOkData));
      AUTH_WAIT_QUEUE: OutPkt.AddUInt32(WaitQueueId);
    end;

    SessionSendPacket(OutPkt);
    SendAddonInformation;
  finally
    OutPkt.Free;
  end;
end;

function YNwWorldSocket.ValidateAddOns(InPkt: YNwPacket): boolean;
var
  Size: Int32;
  Addon: IAddonEntry;
  AddonId: UInt32;
  AddonName: WideString;
  LookupRes: ILookupResult;
begin
  Size := InPkt.Size;

  while Size - Integer(InPkt.ReadPos) > 0 do
  begin
    AddonName := InPkt.ReadString; { Addon Name }
    InPkt.Skip(1); { Enabled or not, anyway it doesn't matter as only blizz addons are sent via this packet }
    AddonId := InPkt.ReadUInt32; { ProviderID or CRC }
    InPkt.Skip(4); { Unknown - almost all the times this was 0 }

    DataCore.Addons.LookupEntryListW('Name', AddonName, False, LookupRes);
    if not Assigned(LookupRes) then
    begin
      DataCore.Addons.CreateEntry(Addon);
      try
        Addon.Name := AddonName;
        Addon.CRC32 := AddonId;
        Addon.Enabled := True;
      finally
        DataCore.Addons.SaveEntry(Addon);
      end;
    end;
  end;

  Result := True;
end;

procedure YNwWorldSocket.SessionForceFlushBuffers;
begin
  Lock;
  try
    ProcessOutputBuffer;
  finally
    Unlock;
  end;
end;

end.
