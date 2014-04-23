{*------------------------------------------------------------------------------
  Logon Processing Server
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.NetworkCore.Logon;

interface

uses
  Framework.Base,
  Framework.Tick,
  Version,
  Components.IoCore.Sockets,
  Components.NetworkCore.Packet,
  Components.NetworkCore.Patches,
  Components.NetworkCore.Constants,
  Components.DataCore.Types,
  Components.NetworkCore.SRP6,
  Misc.Containers,
  SysUtils,
  Misc.Threads,
  Components;

const
  LogonPacketSizeInHeader = 2;  { Size of body in header }
  ProofPacketKeysInBody = 73;  { Key number in body }

type
  { Logon Packet Structures }
  PLogonPacketManifest = ^YLogonPacketManifest;
  YLogonPacketManifest = packed record
    Command: UInt8;
    Error: UInt8;
  end;

  PLogonResponseManifest = ^YLogonResponseManifest;
  YLogonResponseManifest = packed record
    Command: UInt8;
    Unk0: UInt8;
    Error: UInt8;
  end;

  PLogonPacketHeader = ^YLogonPacketHeader;
  YLogonPacketHeader = packed record
    Manifest: YLogonPacketManifest;
    Size: UInt16;
  end;

  PLogonPacketClient = ^YLogonPacketClient;
  YLogonPacketClient = packed record
    Header: YLogonPacketHeader;
    GameName: array[0..3] of Char;
    VerMajor: UInt8;
    VerMinor: UInt8;
    VerPatch: UInt8;
    VerBuild: UInt16;
    &Platform: array[0..3] of Char;
    OS: array[0..3] of Char;
    Locale: Longword;
    TimeZone: UInt32;
    LocalIP: array[0..3] of UInt8;
    AccLen: UInt8;
  end;

  PLogonPacketServer = ^YLogonPacketServer;
  YLogonPacketServer = packed record
    Manifest: YLogonResponseManifest;
    BValue: array[0..31] of UInt8;
    GLen: UInt8;
    GValue: array[0..0] of UInt8;
    NLen: UInt8;
    NValue: array[0..31] of UInt8;
    SValue: array[0..31] of UInt8;
    Unk1: array[0..15] of UInt8;
    Unk2: UInt8;
  end;

  PProofPacketClient = ^YProofPacketClient;
  YProofPacketClient = packed record
    Command: UInt8;
    AValue: array[0..31] of UInt8;
    M1Value: array[0..19] of UInt8;
    Unk1: array[0..19] of UInt8;
    Unk2: UInt16;
  end;

  PProofPacketServer = ^YProofPacketServer;
  YProofPacketServer = packed record
    Manifest: YLogonPacketManifest;
    M2Value: array[0..19] of UInt8;
    Unk1: UInt32;
    {$IFDEF WOW_TBC}
    Unk2: UInt16;
    {$ENDIF}
  end;

  PRealmPacketClient = ^YRealmPacketClient;
  YRealmPacketClient = packed record
    Command: UInt8;
    Unk1: UInt32;
  end;

  PProofPacketKey = ^YProofPacketKey;
  YProofPacketKey = packed record
    Unk1: UInt16;
    Unk2: UInt32;
    Unk3: array[0..3] of UInt8;
    Unk4: array[0..19] of UInt8;
  end;

  PRealmPacketServerHeader = ^YRealmPacketServerHeader;
  YRealmPacketServerHeader = packed record
    Command: UInt8;  { Useful in NS code }
    Size: UInt16; { Useful! }
  end;

  PXferPacketServer = ^YXferPacketServer;
  YXferPacketServer = packed record
    Command: UInt8;
    TSize: UInt8;
    &Type: array[0..4] of UInt8;
    Size: UInt64;
    MD5: array[0..15] of UInt8;
  end;

  PXferPacketResumeClient = ^YXferPacketResumeClient;
  YXferPacketResumeClient = packed record
    Command: UInt8;
    Size: UInt64;
  end;

type
  YNwLogonSocketManager = class;
  { Logon Socket - Provides basic functionality for managing a Logon Attempt }
  YNwLogonSocket = class(YIoClientSocket)
    private
      fInBuffer: TCircularBuffer;
      fOutBuffer: TCircularBuffer;
      fSRP6: YSrpInstance;
      fSRP6Proof: YSrpProofData;
      fPatch: YNwPatch;
      fPatchHandle: TEventHandle;
      fAcc: string;

      procedure ManageLogonPacket(Packet: YNwPacket);
      procedure ManageProofPacket(Packet: YNwPacket);
      procedure ManageRealmListPacket(Packet: YNwPacket);

      procedure ProcessBuffers;
      procedure ProcessInputBuffer;
      procedure ProcessOutputBuffer;
      procedure SendLogonError(Code: UInt8);
      procedure SendPacket(Packet: YNwPacket); inline; { Destroys the packet itself afterwards }

      procedure TryToUpdateClient(const Locale: string; Build: Int32);
      procedure InitiatePatchTransfer(Packet: YNwPacket);
      procedure ResumePatchTransfer(Packet: YNwPacket);
      procedure AbortPatchTransfer(Packet: YNwPacket);
      procedure AbortTransferThread;
      procedure SendPatch(Event: TEventHandle; TimeDelta: UInt32);
    protected
      procedure Initialize; override;
    public
      destructor Destroy; override;
      property AccountName: string read fAcc;
    end;

  { Logon Manager playes god with it's sockets :) }
  YNwLogonSocketManager = class(YIoSocketServer)
    private
      const
        LOGON_THREAD_COUNT = 1;
        
      var
        fLock: TCriticalSection;
        fLogonSockets: TPtrArrayList;
        fUpdateHandle: TEventHandle;

      procedure UpdateSockets(Event: TEventHandle; TimeDelta: UInt32);
    protected
      class function GetSocketClass: YIoClientSocketClass; override;
    public
      constructor Create;
      destructor Destroy; override;

      procedure OnAccept(Sender: YIoSocketServer; Socket: YIoClientSocket);
      procedure OnRead(Sender: YIoSocketServer; Socket: YIoClientSocket; Data: Pointer; Size: Longword);
      procedure OnClose(Sender: YIoSocketServer; Socket: YIoClientSocket);
    end;

implementation

uses
  Misc.Miscleanous,
  Resources,
  Framework,
  Framework.SocketBase,
  Components.DataCore.Fields,
  Cores,
  Components.NetworkCore.Realm,
  Framework.Configuration,
  Components.DataCore.Storage;

constructor YNwLogonSocketManager.Create;
begin
  inherited Create(LOGON_THREAD_COUNT + SystemConfiguration.IntegerValue['Network', 'ExtraLogonWorkers'],
    1 + SystemConfiguration.IntegerValue['Network', 'ExtraLogonListeners'],
    SystemConfiguration.IntegerValue['Network', 'TimeoutDelay'] * 1000);

  fLock.Init;
  fLogonSockets := TPtrArrayList.Create;

  OnSocketAccept := TSocketAcceptEvent(MakeMethod(@YNwLogonSocketManager.OnAccept, Self));
  OnSocketClose := TSocketDisconnectEvent(MakeMethod(@YNwLogonSocketManager.OnClose, Self));
  OnSocketRead := TSocketReadEvent(MakeMethod(@YNwLogonSocketManager.OnRead, Self));

  fUpdateHandle := SystemTimer.RegisterEvent(UpdateSockets, NETWORK_UPD_INTERVAL,
    TICK_EXECUTE_INFINITE, 'LogonSocketManager_Update_Event');
end;

destructor YNwLogonSocketManager.Destroy;
begin
  fUpdateHandle.Unregister;
  fLogonSockets.Free;
  fLock.Delete;
  
  inherited Destroy;
end;

class function YNwLogonSocketManager.GetSocketClass: YIoClientSocketClass;
begin
  Result := YNwLogonSocket;
end;

{ Most important methods of the Logon manager }
procedure YNwLogonSocketManager.OnAccept(Sender: YIoSocketServer; Socket: YIoClientSocket);
var
  cLogonSocket: YNwLogonSocket;
begin
  cLogonSocket := YNwLogonSocket(Socket);
  fLock.Enter;
  try
    fLogonSockets.Add(Socket);
  finally
    fLock.Leave;
  end;
  IoCore.Console.WriteConnectInfo(cLogonSocket.LocalAddress, cLogonSocket.LocalPort);
end;

procedure YNwLogonSocketManager.OnRead(Sender: YIoSocketServer; Socket: YIoClientSocket;
  Data: Pointer; Size: Longword);
var
  cLogonSocket: YNwLogonSocket;
begin
  cLogonSocket := YNwLogonSocket(Socket);
  cLogonSocket.Lock;
  try
    cLogonSocket.fInBuffer.Write(Data^, Size);
  finally
    cLogonSocket.Unlock;
  end;
end;

procedure YNwLogonSocketManager.OnClose(Sender: YIoSocketServer; Socket: YIoClientSocket);
var
  cLogonSocket: YNwLogonSocket;
  cAcc: YDbAccountEntry;
begin
  cLogonSocket := YNwLogonSocket(Socket);
  cLogonSocket.AbortTransferThread; { Abort sending patch if it's sending ... }

  fLock.Enter;
  try
    fLogonSockets.Remove(Socket);
  finally
    fLock.Leave;
  end;

  { Logging Out Account }
  DataCore.Accounts.LoadEntry(FIELD_ACC_NAME, cLogonSocket.AccountName, cAcc);
  if cAcc <> nil then
  begin
    cAcc.LoggedIn := False; { Get out! }
    DataCore.Accounts.SaveEntry(cAcc);
  end;
  { Disconnect Stuff }
  IoCore.Console.WriteDisconnectInfo(cLogonSocket.LocalAddress, cLogonSocket.LocalPort);
end;

procedure YNwLogonSocketManager.UpdateSockets(Event: TEventHandle;
  TimeDelta: UInt32);
var
  iInt: Int32;
begin
  fLock.Enter;
  try
    for iInt := 0 to fLogonSockets.Size -1 do
    begin
      YNwLogonSocket(fLogonSockets[iInt]).ProcessBuffers;
    end;
  finally
    fLock.Leave;
  end;
end;

procedure YNwLogonSocket.Initialize;
const
  InputBufferSize = 1 shl 16; { 64k Buffer }
  OutputBufferSize = 1 shl 16;
begin
  inherited Initialize;
  fInBuffer := TCircularBuffer.Create(InputBufferSize);
  fOutBuffer := TCircularBuffer.Create(OutputBufferSize);
end;

destructor YNwLogonSocket.Destroy;
begin
  fInBuffer.Free;
  fOutBuffer.Free;
  fPatch.Free;
  inherited Destroy;
end;

procedure YNwLogonSocket.ResumePatchTransfer(Packet: YNwPacket);
begin
  { Creating a new Thread }
  if fPatch.ResumeAt(Packet.ReadUInt64) then
  begin
    { Resume Patch Transfer At }
    InitiatePatchTransfer(Packet);
  end;
end;

procedure YNwLogonSocket.AbortPatchTransfer(Packet: YNwPacket);
begin
  AbortTransferThread;
end;

procedure YNwLogonSocket.AbortTransferThread;
begin
  if fPatchHandle <> nil then
  begin
    fPatchHandle.Unregister;
    fPatchHandle := nil;
    IoCore.Console.WriteLSMessage('Auto-Patch transfer aborted.', Self);
  end;
end;

procedure YNwLogonSocket.InitiatePatchTransfer(Packet: YNwPacket);
begin
  fPatchHandle := SystemTimer.RegisterEvent(SendPatch, PATCH_SEND_DELAY,
    TICK_EXECUTE_INFINITE);
  IoCore.Console.WriteLSMessage('Auto-Patch transfer initiated.', Self);
end;

procedure YNwLogonSocket.SendPatch(Event: TEventHandle; TimeDelta: UInt32);
var
  cBody: YNwPacket;
  iSize: Int32;
begin
  fPatch.ReadChunk;
  if not fPatch.IsChunkAvailable then
  begin
    { File has ended }
    IoCore.Console.WriteLSMessage('Auto-Patch transfer ended.', Self);
    FreeAndNil(fPatch);
    fPatchHandle.Unregister; { Unregister event }
    fPatchHandle := nil;
  end else
  begin
    cBody := YNwPacket.Create;
    try
      cBody.AddUInt8(LS_XFER_DATA);
      iSize := fPatch.GetCurrentChunkSize;
      cBody.AddUInt16(iSize);
      fPatch.AddChunkToBuffer(cBody.GetWritePtrOfSize(iSize)^);
      SendPacket(cBody);
    finally
      cBody.Free;
    end;
  end;
end;

procedure YNwLogonSocket.TryToUpdateClient(const Locale: string; Build: Int32);
var
  cBody: YNwPacket;
  cPatch: YNwPatch;
  iSizePer: Int32;
begin
  if not NetworkCore.Patches.HasPatch(Build, Locale) then
  begin
    SendLogonError(LS_E_WRONG_BUILD_NUMBER);
    Exit;
  end;

  iSizePer := SystemConfiguration.IntegerValue['Data', 'PatchSpeed'];
  if iSizePer = 0 then iSizePer := 2048; { Standard size }
  cPatch := NetworkCore.Patches.RetrievePatch(Build, Locale, iSizePer);
  SendLogonError(LS_E_UPDATE_CLIENT);

  { Sending the Transfer Start }
  cBody := YNwPacket.Create;
  try
    cBody.AddUInt8(LS_XFER_INITIATE);
    cBody.AddUInt8(Length(cPatch.PatchType));
    cBody.AddStringData(cPatch.PatchType);
    cBody.AddUInt64(cPatch.PatchSize);
    cBody.AddStringData(cPatch.PatchMD5);
    SendPacket(cBody);
  finally
    cBody.Free;
  end;
  { Saving the patch class }

  fPatch := cPatch;
end;

procedure YNwLogonSocket.ManageLogonPacket(Packet: YNwPacket);
const
  StatusErrorTable: array[YAccountStatus] of Integer = (
    LS_E_ACCOUNT_FROZEN,
    LS_E_ACCOUNT_CLOSED,
    LS_E_PREORDER_TIME_LIMIT,
    LS_E_SUCCESS
  );
var
  pLogonPkt: PLogonPacketClient;
  pLogonRPkt: PLogonPacketServer;
  sAllowedL: string;
  sMyLocal: string;
  pAcc: PShortString;
  sAccount: string;
  iMaxAllowed: Int32;
  cOutPacket: YNwPacket;
  cAcc: YDbAccountEntry;
begin
  { Set the pointer to the first byte of the packet }
  pLogonPkt := Packet.GetReadPtrOfSize(SizeOf(YLogonPacketClient) - 1);

  { Somebody is trying to hax us! }
  if (pLogonPkt^.AccLen > 16) or { Maximum account length }
     (Packet.Size > MAX_USERNAME_LEN + 1{ Consider #0 (null-terminated) }) or
     (Packet.Size <> SizeOf(YLogonPacketClient) + pLogonPkt^.AccLen) then
  begin
    Disconnect;
  end;

  pAcc := Packet.GetCurrentReadPtr;
  sAccount := UpperCase(pAcc^);

  { Cheking Localization }
  sAllowedL := SystemConfiguration.StringValue['Network', 'AllowedLocales'];

  SetLength(sMyLocal, 4);
  PUInt32(sMyLocal)^ := EndianSwap32(pLogonPkt^.Locale);

  if (Length(sAllowedL) > 0) and (Pos(sMyLocal, sAllowedL) = 0) then
  begin
    SendLogonError(LS_E_WRONG_BUILD_NUMBER);
    Exit;
  end;

  { Checking Build Number }

  if not IsAcceptedBuild(pLogonPkt^.VerBuild) then
  begin
    TryToUpdateClient(sMyLocal, pLogonPkt^.VerBuild); { Trying to update this client }
    Exit;
  end;

  { Checking for account existance }
  DataCore.Accounts.LoadEntry(FIELD_ACC_NAME, sAccount, cAcc);
  if cAcc = nil then
  begin
    if SystemConfiguration.IntegerValue['Realm', 'AutoAccount'] = 0 then
    begin
      SendLogonError(LS_E_NO_ACCOUNT);
      Exit;
    end else
    begin
      { Automatic account creation }
      DataCore.Accounts.CreateEntry(cAcc);
      cAcc.Name := sAccount;
      cAcc.Pass := sAccount;
      cAcc.AutoCreated := True;
      cAcc.Access := aaNormal;
      cAcc.Status := asNormal;
      DataCore.Accounts.SaveEntry(cAcc);
      DataCore.Accounts.LoadEntry(FIELD_ACC_NAME, sAccount, cAcc);
    end;
  end;
  
  { Checking for number of players }
  iMaxAllowed := SystemConfiguration.IntegerValue['Network', 'Players'];

  if (iMaxAllowed > 0) and (NetworkCore.LogonThreads >= iMaxAllowed) then
  begin
    if cAcc.Access = aaNormal then
    begin
      SendLogonError(LS_E_SERVER_FULL);
      DataCore.Accounts.ReleaseEntry(cAcc);
      Exit;
    end;
  end;

  { Checking Account Status }
  if cAcc.Status <> asNormal then
  begin
    SendLogonError(StatusErrorTable[cAcc.Status]);
    DataCore.Accounts.ReleaseEntry(cAcc);
    Exit;
  end;

  { Checking if already logged in }
  if cAcc.LoggedIn then
  begin
    SendLogonError(LS_E_ACCOUNT_IN_USE);
    DataCore.Accounts.ReleaseEntry(cAcc);
    Exit;
  end;

  { That's it. If we got here it means everything is just OK }

  { Initiating SRP6 }
  fAcc := sAccount;
  InitializeSRP6(@fSRP6, UpperCase(sAccount), UpperCase(cAcc.Pass));
  GetProofSRP6Data(@fSRP6, @fSRP6Proof);

  { Sending the packet to the client }
  cOutPacket := YNwPacket.Create;
  try
    pLogonRPkt := cOutPacket.GetWritePtrOfSize(SizeOf(YLogonPacketServer));

    with pLogonRPkt^ do
    begin
      Manifest.Command := LS_AUTH_LOGON_CHALLENGE;
      Manifest.Error := LS_E_SUCCESS;
      Manifest.Unk0 := 0; { Unknown Value }
      Move(fSRP6Proof.B, BValue, SizeOf(BValue));
      GLen := SizeOf(Byte);
      Move(fSRP6Proof.G, GValue, SizeOf(GValue));
      NLen := Length(NValue);
      Move(fSRP6Proof.N, NValue, SizeOf(NValue));
      Move(fSRP6Proof.S, SValue, SizeOf(SValue));
      Move(fSRP6Proof.Unk, Unk1, SizeOf(Unk1));

      Unk2 := 0;   //this is added somehow for 1.11+ as auth packets is 1byte bigger now
    end;

    SendPacket(cOutPacket);
  finally
    cOutPacket.Free;
  end;
  DataCore.Accounts.ReleaseEntry(cAcc);
end;
  
procedure YNwLogonSocket.ManageProofPacket(Packet: YNwPacket);
var
  pProofPkt: PProofPacketClient;
  pProofRPkt: PProofPacketServer;
  pManifest: PLogonPacketManifest;
  cOutPacket: YNwPacket;
  cAcc: YDbAccountEntry;
begin
  { Set the pointer to the first byte of the packet }
  pProofPkt := Packet.GetReadPtrOfSize(SizeOf(YProofPacketClient));

  { Contin9ued SRP6 }
  if ValidateSRP6(@fSRP6, @pProofPkt^.AValue, @pProofPkt^.M1Value, @fSRP6Proof) then
  begin
    cOutPacket := YNwPacket.Create;
    try
      pProofRPkt := cOutPacket.GetWritePtrOfSize(SizeOf(YProofPacketServer));

      with pProofRPkt^ do
      begin
        Manifest.Command := LS_AUTH_LOGON_PROOF;
        Manifest.Error := LS_E_SUCCESS;

        Move(fSRP6Proof.M2, M2Value, Length(M2Value));
        Unk1 := 0; { Unknown }
      end;

      SendPacket(cOutPacket);
    finally
      cOutPacket.Free;
    end;

    DataCore.Accounts.LoadEntry(FIELD_ACC_NAME, fAcc, cAcc);
    { Logging In Account }
    if cAcc <> nil then
    begin
      cAcc.LoggedIn := True; { Whoops, You're in baby :) }
      Move(fSRP6Proof.SS_Hash, Pointer(@cAcc.Hash)^, SizeOf(YAccountHash));
      DataCore.Accounts.SaveEntry(cAcc);
    end;
  end else
  begin
    cOutPacket := YNwPacket.Create;
    try
      pManifest := cOutPacket.GetWritePtrOfSize(SizeOf(YLogonPacketManifest));
      with pManifest^ do
      begin
        Command := LS_AUTH_LOGON_PROOF;
        Error := LS_E_NO_ACCOUNT;
      end;
      SendPacket(cOutPacket);
    finally
      cOutPacket.Free;
    end;
  end;
end;
  
procedure YNwLogonSocket.ManageRealmListPacket(Packet: YNwPacket);
var
  pRealmRPkt: PRealmPacketServerHeader;
  iRlm: Int32;
  iLen: Int32;
  iCount: Int32;
  cOutPacket: YNwPacket;
begin
  cOutPacket := YNwPacket.Create;
  try
    pRealmRPkt := cOutPacket.GetWritePtrOfSize(SizeOf(YRealmPacketServerHeader));
    pRealmRPkt^.Command := LS_REALM_LIST;
    iCount := NetworkCore.Realms.Count;

    iLen := 13 * iCount + 7;
    cOutPacket.JumpUInt32; { Unknown }
    cOutPacket.AddUInt16(iCount); { Realm Count }  //changed realm count to uint16 since 2.0.3 or 2.0.5

    for iRlm := 0 to iCount - 1 do
    begin
      with NetworkCore.Realms.Realms[iRlm] do
      begin
        cOutPacket.AddUInt8(RealmIcon);
        cOutPacket.AddUInt8(RealmColor);     //since 2.0.6 it is UInt8
        cOutPacket.JumpUInt8;     //Unknown value! Either RealmColor is back UInt16 or this is a new value for realms
        cOutPacket.AddString(RealmName);
        cOutPacket.AddString(RealmAddr);
        cOutPacket.AddFloat(RealmPpl);               //06 81 35 40
        cOutPacket.AddUInt8(RealmChars[fAcc]);
        cOutPacket.AddUInt8(RealmTZone);
        cOutPacket.JumpUInt16; { Realms Separator }  //since 2.0.6 it is UInt16 and not UInt8...
        Inc(iLen, Length(RealmName) + Length(RealmAddr));
      end;
    end;

    cOutPacket.JumpUInt8;   { Realmlist terminator }

    pRealmRPkt^.Size := iLen;

    SendPacket(cOutPacket);
  finally
    cOutPacket.Free;
  end;
end;

procedure YNwLogonSocket.ProcessBuffers;
begin
  Lock;
  try
    ProcessInputBuffer;
    ProcessOutputBuffer;
  finally
    Unlock;
  end;
end;

procedure YNwLogonSocket.ProcessInputBuffer;
var
  cInPkt: YNwPacket;
  iCmd: UInt8;
  tHdr: YLogonPacketClient;
begin
  repeat
    if fInBuffer.ReadAvail = 0 then Exit;

    iCmd := PByte(fInBuffer[fInBuffer.ReadPosition])^;

    case iCmd of
      LS_AUTH_LOGON_CHALLENGE:
      begin
        { Make sure the whole packet has been received }
        if fInBuffer.ReadAvail >= SizeOf(YLogonPacketClient) then
        begin
          fInBuffer.Read(tHdr, SizeOf(YLogonPacketClient));
          if fInBuffer.ReadAvail >= tHdr.AccLen then
          begin
            cInPkt := YNwPacket.Create(tHdr.AccLen + SizeOf(tHdr));
            try
              Move(tHdr, cInPkt.Storage[0], SizeOf(tHdr));
              fInBuffer.Read(cInPkt.Storage[SizeOf(tHdr)], tHdr.AccLen);
              cInPkt.WritePos := cInPkt.Size;
              ManageLogonPacket(cInPkt);
              //IoCore.Console.WriteReceivedPacketSize(cInPkt);
            finally
              cInPkt.Free;
            end;
          end else Exit;
        end else Exit;
      end;
      LS_AUTH_LOGON_PROOF:
      begin
        { Make sure the whole packet has been received }
        if fInBuffer.ReadAvail >= SizeOf(YProofPacketClient) then
        begin
          cInPkt := YNwPacket.Create(SizeOf(YProofPacketClient));
          try
            fInBuffer.Read(cInPkt.Storage[0], SizeOf(YProofPacketClient));
            cInPkt.WritePos := cInPkt.Size;
            ManageProofPacket(cInPkt);
          finally
            cInPkt.Free;
          end;
        end else Exit;
      end;
      LS_REALM_LIST:
      begin
        { Make sure the whole packet has been received }
        if fInBuffer.ReadAvail >= SizeOf(YRealmPacketClient) then
        begin
          cInPkt := YNwPacket.Create(SizeOf(YRealmPacketClient));
          try
            fInBuffer.Read(cInPkt.Storage[0], SizeOf(YRealmPacketClient));
            cInPkt.WritePos := cInPkt.Size;
            ManageRealmlistPacket(cInPkt);
          finally
            cInPkt.Free;
          end;
        end else Exit;
      end;
      LS_XFER_ACCEPT:
      begin
        if fInBuffer.ReadAvail >= 1 then
        begin
          cInPkt := YNwPacket.Create(1);
          try
            fInBuffer.Read(cInPkt.Storage[0], 1);
            cInPkt.WritePos := cInPkt.Size;
            InitiatePatchTransfer(cInPkt);
          finally
            cInPkt.Free;
          end;
        end else Exit;
      end;
      LS_XFER_CANCEL:
      begin
        if fInBuffer.ReadAvail >= 1 then
        begin
          cInPkt := YNwPacket.Create(1);
          try
            fInBuffer.Read(cInPkt.Storage[0], 1);
            cInPkt.WritePos := cInPkt.Size;
            AbortPatchTransfer(cInPkt);
          finally
            cInPkt.Free;
          end;
        end else Exit;
      end;
      LS_XFER_RESUME:
      begin
        { Make sure the whole packet has been received }
        if fInBuffer.ReadAvail >= SizeOf(YXferPacketResumeClient) then
        begin
          cInPkt := YNwPacket.Create(SizeOf(YXferPacketResumeClient));
          try
            fInBuffer.Read(cInPkt.Storage[0], SizeOf(YXferPacketResumeClient));
            cInPkt.WritePos := cInPkt.Size;
            ResumePatchTransfer(cInPkt);
          finally
            cInPkt.Free;
          end;
        end else Exit;
      end;
    else
      begin
        { An invalid packet has arrived, maybe some DDoS-er? }
        fInBuffer.Clear;
        IoCore.Console.WriteLSErrorMessage(RsInvalidPacketMsg, iCmd, Self);
        Disconnect;
        Exit;
      end;
    end;
  until False;
end;

procedure YNwLogonSocket.ProcessOutputBuffer;
begin
  if fOutBuffer.ReadAvail = 0 then Exit;

  Owner.SendData(Self, fOutBuffer[fOutBuffer.ReadPosition]^, fOutBuffer.ReadAvail);
  fOutBuffer.ReadPosition := fOutBuffer.ReadPosition + fOutBuffer.ReadAvail;
end;

procedure YNwLogonSocket.SendLogonError(Code: UInt8);
var
  pManifest: PLogonResponseManifest;
  cPacket: YNwPacket;
begin
  cPacket := YNwPacket.Create;
  try
    pManifest := cPacket.GetWritePtrOfSize(SizeOf(YLogonResponseManifest));
    with pManifest^ do
    begin
      Command := LS_AUTH_LOGON_CHALLENGE;
      Error := Code;
      Unk0 := 0; { Unknown }
    end;

    SendPacket(cPacket);
  finally
    cPacket.Free;
  end;
end;

procedure YNwLogonSocket.SendPacket(Packet: YNwPacket);
begin
  Lock;
  try
    fOutBuffer.Write(Packet.Storage[0], Packet.WritePos);
  finally
    Unlock;
  end;
end;

end.
