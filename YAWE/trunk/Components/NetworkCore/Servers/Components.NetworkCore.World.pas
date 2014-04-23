{*------------------------------------------------------------------------------
  World ( Realm ) Server.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
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
  Components.DataCore.Types,
  Components.DataCore.Fields,
  Components.GameCore.Session,
  Components.NetworkCore.Packet,
  Components.NetworkCore.HdrXor,
  Components.NetworkCore.Constants,
  Components.NetworkCore.Opcodes,
  Components.NetworkCore.SRP6,
  Components.Interfaces,
  Misc.ZLib,
  Misc.Containers,
  Misc.Miscleanous,
  Misc.Threads,
  SysUtils;

type
  YNwWorldSocketManager = class;

  { Provides connection with client ... etc }
  YNwWorldSocket = class(YIoClientSocket, ISocketInterface)
    private
      fHdrXorData: YEncryptionContext;
      fRecvBuffer: TCircularBuffer;
      fSendBuffer: TCircularBuffer;
      fSession: YGaSession;
      fQueueId: Longword;
      fSeed: UInt32;
      fAccountName: string;
      fAddons: TPtrArrayList;
      fCurrentInPkt: YNwClientPacket;

      procedure ProcessInputBuffer;
      procedure ProcessOutputBuffer;
      procedure ProcessBuffers;

      { Interface Imported Methods }
      procedure SessionSendPacket(cPkt: YNwServerPacket); inline;
      procedure SessionSetAuthKey(const aHash: YAccountHash); inline;
      procedure SessionSetQueuePosition(iTo: Integer); inline;
      function SessionGetQueuePosition: Integer; inline;
      procedure ISocketInterface.SessionDisconnect = Disconnect;
      procedure SessionForceFlushBuffers;
      procedure UpdateQueuePosition(iPos: Integer); inline;

      procedure InitiateAuthSession; { Initiates Auth Session }
      procedure HandleAuthResponse(cPkt: YNwClientPacket);
      { Client Auth Response }
      procedure HandleClientPing(cPkt: YNwClientPacket);
      { Ping event  }
      procedure SendAuthResponse(iErrorCode: Int32; iWQU: Int32 = 0);
      procedure SendAddonInformation;
      function ValidateAddOns(cPkt: YNwPacket): boolean;
      procedure ProcessOpcode(cPkt: YNwClientPacket; lwOpcode: UInt32);

      procedure ISocketInterface.QueueLockAcquire = Lock;
      procedure ISocketInterface.QueueLockRelease = Unlock;
    protected
      procedure Initialize; override;
    public
      destructor Destroy; override;

      property Session: YGaSession read fSession;
    end;

  YNwWorldSocketManager = class(YIoSocketServer)
    private
      const
        WORLD_THREAD_COUNT = 3;

      var
        fUpdateHandle: TEventHandle;
        fWorldSockets: TPtrArrayList;
        fQueueIdHigh: Longword;
        fLock: TCriticalSection;
        
    protected
      class function GetSocketClass: YIoClientSocketClass; override;
      procedure RegisterWorldSocket(cSocket: YNwWorldSocket);
      procedure UnregisterWorldSocket(cSocket: YNwWorldSocket);
      procedure ProcessPackets(Event: TEventHandle; TimeDelta: UInt32);
    public
      constructor Create;
      destructor Destroy; override;
      
      function GetSocketByAccount(const sAccName: string): YNwWorldSocket;
      procedure OnAccept(cSender: YIoSocketServer; cSocket: YIoClientSocket);
      procedure OnRead(cSender: YIoSocketServer; cSocket: YIoClientSocket; pData: Pointer; iSize: Integer);
      procedure OnClose(cSender: YIoSocketServer; cSocket: YIoClientSocket);
    end;

implementation

uses
  Cores,
  Misc.Resources,
  Framework.SocketBase,
  Framework;

{ YNwWorldSocketManager }

constructor YNwWorldSocketManager.Create;
begin
  inherited Create(WORLD_THREAD_COUNT + SystemConfiguration.IntegerValue['Network', 'ExtraRealmWorkers'],
    1 + SystemConfiguration.IntegerValue['Network', 'ExtraRealmListeners'],
    SystemConfiguration.IntegerValue['Network', 'TimeoutDelay'] * 1000);
  fWorldSockets := TPtrArrayList.Create(512);
  fLock.Init;

  OnSocketAccept := TSocketAcceptEvent(MakeMethod(@YNwWorldSocketManager.OnAccept, Self));
  OnSocketClose := TSocketDisconnectEvent(MakeMethod(@YNwWorldSocketManager.OnClose, Self));
  OnSocketRead := TSocketReadEvent(MakeMethod(@YNwWorldSocketManager.OnRead, Self));

  fUpdateHandle := SystemTimer.RegisterEvent(ProcessPackets, NETWORK_UPD_INTERVAL,
    TICK_EXECUTE_INFINITE, 'WorldSocketManager_Update_Event');
end;

destructor YNwWorldSocketManager.Destroy;
begin
  fUpdateHandle.Unregister;
  fWorldSockets.Free;
  fLock.Delete;
  inherited Destroy;
end;

class function YNwWorldSocketManager.GetSocketClass: YIoClientSocketClass;
begin
  Result := YNwWorldSocket;
end;

function YNwWorldSocketManager.GetSocketByAccount(const sAccName: string): YNwWorldSocket;
var
  iIdx: Integer;
begin
  fLock.Enter;
  try
    for iIdx := 0 to fWorldSockets.Size - 1 do
    begin
      { A rare case where we are using iteration instead of a hash map }
      Result := fWorldSockets[iIdx];
      if StringsEqual(Result.fAccountName, sAccName) then Exit;
    end;
  finally
    fLock.Leave;
  end;
  Result := nil;
end;

procedure YNwWorldSocketManager.RegisterWorldSocket(cSocket: YNwWorldSocket);
begin
  fLock.Enter;
  try
    fWorldSockets.Add(cSocket);
  finally
    fLock.Leave;
  end;
  AtomicInc(@fQueueIdHigh);
  cSocket.fQueueId := fQueueIdHigh;
end;

procedure YNwWorldSocketManager.UnregisterWorldSocket(cSocket: YNwWorldSocket);
var
  iIdx: Integer;
  iNow: Longword;
  cTemp: YNwWorldSocket;
begin
  iNow := cSocket.fQueueId;
  if iNow = fQueueIdHigh then
  begin
    AtomicDec(@fQueueIdHigh);
  end else
  begin
    { Update the waiting queue }
    for iIdx := 0 to fWorldSockets.Size - 1 do
    begin
      cTemp := fWorldSockets.Items[iIdx];
      if cTemp.fQueueId > iNow then
      begin
        if cTemp.fQueueId = fQueueIdHigh then AtomicDec(@fQueueIdHigh);
        { Update Queue Position for each Session }
        Dec(cTemp.fQueueId);
        cTemp.UpdateQueuePosition(cTemp.fQueueId); { If Position == 0 will send OK as Auth }
      end;
    end;
  end;
end;

procedure YNwWorldSocketManager.ProcessPackets(Event: TEventHandle; TimeDelta: UInt32);
var
  iX: Integer;
begin
  fLock.Enter;
  try
    for iX := 0 to fWorldSockets.Size - 1 do
    begin
      YNwWorldSocket(fWorldSockets.Items[iX]).ProcessBuffers;
    end;
  finally
    fLock.Leave;
  end;
end;

procedure YNwWorldSocketManager.OnAccept(cSender: YIoSocketServer; cSocket: YIoClientSocket);
var
  cWorldSocket: YNwWorldSocket;
begin
  cWorldSocket := YNwWorldSocket(cSocket);
  IoCore.Console.WriteConnectInfoWS(cWorldSocket.LocalAddress, cWorldSocket.LocalPort);
  RegisterWorldSocket(cWorldSocket);
  cWorldSocket.InitiateAuthSession;
end;

procedure YNwWorldSocketManager.OnRead(cSender: YIoSocketServer; cSocket: YIoClientSocket;
  pData: Pointer; iSize: Integer);
var
  cWorldSocket: YNwWorldSocket;
begin
  cWorldSocket := YNwWorldSocket(cSocket);
  cWorldSocket.Lock;
  try
    cWorldSocket.fRecvBuffer.Write(pData^, iSize);
  finally
    cWorldSocket.Unlock;
  end;
end;

procedure YNwWorldSocketManager.OnClose(cSender: YIoSocketServer; cSocket: YIoClientSocket);
var
  cWorldSocket: YNwWorldSocket;
begin
  cWorldSocket := YNwWorldSocket(cSocket);
  fLock.Enter;
  try
    fWorldSockets.Remove(cWorldSocket);
    UnregisterWorldSocket(cWorldSocket);
  finally
    fLock.Leave;
  end;
  IoCore.Console.WriteDisconnectInfoWS(cWorldSocket.LocalAddress, cWorldSocket.LocalPort);
end;

{ YNwWorldSocket }

const
  BlizzardAddonSignature = $4C1C776D;

procedure YNwWorldSocket.HandleAuthResponse(cPkt: YNwClientPacket);
type
  PAuthDigest = ^YAuthDigest;
  YAuthDigest = array[0..19] of Byte;
var
  pDigest: PAuthDigest;
  iClientSeed: Longword;
  sAccountName: string;
  iMaxAllowed: Int32;
  iExpSize: Int32;
  cChild: YNwPacket;
  pData: Pointer;
  cAcc: YDbAccountEntry;
  pHash: Pointer;
begin
  cPkt.Skip(8); { unknown }
  sAccountName := cPkt.ReadString;
  iClientSeed := cPkt.ReadUInt32;
  pDigest := cPkt.GetReadPtrOfSize(20); { SHA1 Digest from client }

  DataCore.Accounts.LoadEntry(FIELD_ACC_NAME, sAccountName, cAcc);
  if cAcc = nil then
  begin
    SessionForceFlushBuffers; { Send all data }
    Disconnect; { Signal disconnect the client }
    Exit;
  end;

  { Help for RE Sniffer to gain the key faster. Win32, debug dependant code }
  {$IFDEF DBG_SNIFFER}
  PostSnifferData(atoh(sAccountName), cAcc.Hash);
  {$ENDIF}

  { Apply Encryption Key }
  pHash := @cAcc.Hash;
  SessionSetAuthKey(cAcc.Hash);

  { Checking Account Status }
  case cAcc.Status of
    asLocked, asBanned, asPayNotify:
    begin
      SendAuthResponse(AUTH_REJECT);
      SessionForceFlushBuffers; { Send all data }
      Disconnect; { Signal disconnect the client }
      DataCore.Accounts.ReleaseEntry(cAcc);
      Exit;
    end;
  end;

  if Assigned(NetworkCore.WorldServer.GetSocketByAccount(sAccountName)) then
  begin
    { Another user with the same account is already logged in }
    SendAuthResponse(AUTH_ALREADY_LOGGING_IN);
    SessionForceFlushBuffers; { Send all data }
    Disconnect; { Signal disconnect the client }
    DataCore.Accounts.ReleaseEntry(cAcc);
    Exit;
  end;

  if not CheckAuthDigest(iClientSeed, fSeed, pHash, pDigest, sAccountName) then
  begin
    { It seems that the password and/or account provided are incorrect }
    SendAuthResponse(AUTH_FAILED {AUTH_BAD_SERVER_PROOF});
    SessionForceFlushBuffers; { Send all data }
    Disconnect; { Signal disconnect the client }
    DataCore.Accounts.ReleaseEntry(cAcc);
    Exit;
  end;
    
  iMaxAllowed := SystemConfiguration.IntegerValue['Network', 'Players'];

  if (iMaxAllowed > 0) and (NetworkCore.RealmThreads >= iMaxAllowed) then
  begin
    if cAcc.Access = aaNormal then
    begin
      SendAuthResponse(AUTH_WAIT_QUEUE, SessionGetQueuePosition);
      DataCore.Accounts.ReleaseEntry(cAcc);
      Exit;
    end;
  end;

  SessionSetQueuePosition(0); { Wait not needed! Reset }
  { Check for AddOns }
  iExpSize := cPkt.ReadUInt32; { Size of the expected compressed block }

  cChild := YNwPacket.Create;
  try
    pData := Decompress(cPkt.GetCurrentReadPtr, cPkt.WritePos - cPkt.ReadPos,
      iExpSize);
    cChild.AddStruct(pData^, iExpSize);
    FreeMem(pData, iExpSize);

    ValidateAddOns(cChild);
  finally
    cChild.Free;
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

  fAccountName := sAccountName;
  { Creating an GameCore object }
  fSession := YGaSession.Create;
  fSession.Socket := Self; { Use the same packet data tunnel as NetworkCore for GameCore }
  fSession.Account := cAcc.Name;
  GameCore.AddSession(fSession); { Plug the session into the world }
  SendAuthResponse(AUTH_OK);
  DataCore.Accounts.ReleaseEntry(cAcc);
end;

procedure YNwWorldSocket.HandleClientPing(cPkt: YNwClientPacket);
var
  cPong : YNwServerPacket;
begin
  cPong := YNwServerPacket.Initialize(SMSG_PONG, 4);
  try
    cPong.AddUInt32(cPkt.ReadUInt32); { Sending the PONG Value }
    SessionSendPacket(cPong);
  finally
    cPong.Free;
  end;
end;

procedure YNwWorldSocket.Initialize;
const
  InputBufferSize = 1 shl 16; { 64k Buffer }
  OutputBufferSize = 1 shl 16;
begin
  fRecvBuffer := TCircularBuffer.Create(InputBufferSize);
  fSendBuffer := TCircularBuffer.Create(OutputBufferSize);
  fAddons := TPtrArrayList.Create;
end;

procedure YNwWorldSocket.InitiateAuthSession;
var
  cPkt: YNwServerPacket;
begin
  { Selects the internal Seed Number and returns it to the client }
  fSeed := Random(-1);
  cPkt := YNwServerPacket.Initialize(SMSG_AUTH_CHALLENGE, 4);
  try
    cPkt.AddUInt32(fSeed);
    SessionSendPacket(cPkt);
  finally
    cPkt.Free;
  end;
end;

destructor YNwWorldSocket.Destroy;
begin
  fRecvBuffer.Free;
  fSendBuffer.Free;
  fAddons.Free;
  FreeAndNil(fCurrentInPkt);
  if Assigned(fSession) then
  begin
    GameCore.RemoveSession(fSession);  
    fSession.Free;
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
  tPktHeader: YWorldClientHeader;
  pHdr: PWorldClientHeader;
  wSize: UInt16;
begin
  if fRecvBuffer.ReadAvail = 0 then Exit;

  repeat
    try
      if fCurrentInPkt = nil then
      begin
        if fRecvBuffer.ReadAvail < SizeOf(YWorldClientHeader) then Exit;
        fRecvBuffer.Read(tPktHeader, SizeOf(tPktHeader));
        HdrXorDecrypt(fHdrXorData, @tPktHeader);
        wSize := EndianSwap16(tPktHeader.Size) + 2;
        fCurrentInPkt := YNwClientPacket.Create(wSize);
        Move(tPktHeader, fCurrentInPkt.Storage[0], SizeOf(YWorldClientHeader));
        Dec(wSize, SizeOf(YWorldClientHeader));
        pHdr := @tPktHeader;
      end else
      begin
        pHdr := fCurrentInPkt.Header;
        wSize := fCurrentInPkt.Size - SizeOf(YWorldClientHeader);
      end;

      if not fHdrXorData.KeyValid then
      begin
        if (pHdr^.Opcode <> CMSG_AUTH_SESSION) and
           (pHdr^.Opcode <> CMSG_PING) then
        begin
          fRecvBuffer.Clear;
          Disconnect;
          Exit;
        end;
      end;

      if fRecvBuffer.ReadAvail >= wSize then
      begin
        fRecvBuffer.Read(fCurrentInPkt.Storage[SizeOf(YWorldClientHeader)], wSize);
        try
          fCurrentInPkt.WritePos := fCurrentInPkt.Size;
          ProcessOpCode(fCurrentInPkt, fCurrentInPkt.Header^.Opcode);
        finally
          FreeAndNil(fCurrentInPkt);
        end;
      end else Exit;
    except
      FreeAndNil(fCurrentInPkt);
      raise;
    end;
  until False;
end;

procedure YNwWorldSocket.ProcessOpcode(cPkt: YNwClientPacket; lwOpcode: UInt32);
var
  bHandled: Boolean;
begin
  { NetworkCore Handlers }
  case lwOpCode of
    CMSG_AUTH_SESSION:
    begin
      if not fHdrXorData.KeyValid then
      begin
        HandleAuthResponse(cPkt);
        bHandled := True;
      end else
      begin
        { Invalid, must be sent only once }
        Disconnect;
        bHandled := False;
      end;
    end;
    CMSG_PING:
    begin
      HandleClientPing(cPkt);
      bHandled := True;
    end
  else
    if Assigned(fSession) then
    begin
      bHandled := fSession.DispatchOpcode(cPkt, lwOpCode); { Let GameCore deal with those }
    end else bHandled := False;
  end;

  IoCore.Console.WriteOpcodeCall(Self, GetOpcodeName(lwOpCode), lwOpCode, bHandled); { Write it quicky :) }
end;

procedure YNwWorldSocket.ProcessOutputBuffer;
begin
  if fSendBuffer.ReadAvail = 0 then Exit;

  Owner.SendData(Self, fSendBuffer[fSendBuffer.ReadPosition]^, fSendBuffer.ReadAvail);
  fSendBuffer.ReadPosition := fSendBuffer.ReadPosition + fSendBuffer.ReadAvail;
end;

procedure YNwWorldSocket.SessionSetAuthKey(const aHash: YAccountHash);
begin
  { Setting the encryption Key }
  Move(aHash, fHdrXorData.Key, KEY_SIZE);
  fHdrXorData.KeyValid := True;
end;

procedure YNwWorldSocket.SessionSendPacket(cPkt: YNwServerPacket);
begin
  Lock;
  try
    cPkt.Finalize(fHdrXorData, fSendBuffer);
    IoCore.Console.WriteWSSentPacketSize(cPkt);
  finally
    Unlock;
  end;
end;

function YNwWorldSocket.SessionGetQueuePosition: Integer;
begin
  { Returns current position in the wait queue}
  Result := fQueueId;
end;

procedure YNwWorldSocket.SessionSetQueuePosition(iTo: Integer);
begin
  { Sets current queue to }
  fQueueId := iTo;
end;

procedure YNwWorldSocket.UpdateQueuePosition(iPos: Integer);
begin
  if iPos = 0 then
  begin
    { This user has a slot now. }
    SendAuthResponse(AUTH_OK);
  end else
  begin
    { More waiting ahead ... }
    SendAuthResponse(AUTH_WAIT_QUEUE, iPos);
  end;
end;

procedure YNwWorldSocket.SendAddonInformation;
var
  cOutPkt: YNwServerPacket;
begin
  cOutPkt := YNwServerPacket.Initialize(SMSG_ADDON_INFORMATION, 0);
  try
    SessionSendPacket(cOutPkt);
  finally
    cOutPkt.Free;
  end;
end;

procedure YNwWorldSocket.SendAuthResponse(iErrorCode, iWQU: Int32);
type
  PAuthOkStruct = ^YAuthOkStruct;
  YAuthOkStruct = packed record
    Unk1: UInt32;
    Unk2: UInt32;
    Unk3: UInt8;
    {$IFDEF WOW_TBC}
    IsTbcAccount: Boolean;
    {$ENDIF}
  end;
const
  AuthOkData: YAuthOkStruct = (
    Unk1: $FF4C1D10;
    Unk2: $42;
    Unk3: 0;
    {$IFDEF WOW_TBC}
    IsTbcAccount: True;
    {$ENDIF}
  );
var
  cPkt: YNwServerPacket;
begin
  { Sends the error code back to client }
  cPkt := YNwServerPacket.Initialize(SMSG_AUTH_RESPONSE);
  try
    cPkt.AddUInt8(iErrorCode);

    case iErrorCode of
      AUTH_OK: cPkt.AddStruct(AuthOkData, SizeOf(AuthOkData));
      AUTH_WAIT_QUEUE: cPkt.AddUInt32(iWQU);
    end;

    SessionSendPacket(cPkt);
    SendAddonInformation;
  finally
    cPkt.Free;
  end;
end;

function YNwWorldSocket.ValidateAddOns(cPkt: YNwPacket): boolean;
var
  iSize: Int32;
  cAddon: YDbAddonEntry;
  iID: UInt32;
  sName: string;
begin
  iSize := cPkt.Size;
  while iSize - Integer(cPkt.ReadPos) > 0 do
  begin
    sName := cPkt.ReadString; { Addon Name }
    cPkt.Skip(1); { Enabled or not, anyway it doesn't matter as only blizz addons are sent via this packet }
    iID := cPkt.ReadUInt32; { ProviderID or CRC }
    cPkt.Skip(4); { Unknown - almost all the times this was 0 }

    DataCore.Addons.LoadEntry(FIELD_ADDON_NAME, sName, cAddon);
    if cAddon = nil then
    begin
      DataCore.Addons.CreateEntry(cAddon);
    end;
    fAddons.Add(cAddon);
    cAddon.Name := sName;
    cAddon.CRC32 := iID;
    cAddon.Enabled := True;
    DataCore.Addons.SaveEntry(cAddon);
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
