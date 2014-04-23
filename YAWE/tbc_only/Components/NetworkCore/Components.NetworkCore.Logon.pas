{*------------------------------------------------------------------------------
  Logon Processing Server
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
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
  Components.DataCore,
  Components.DataCore.Types,
  Components.NetworkCore.SRP6,
  Bfg.Containers,
  SysUtils,
  Bfg.Threads,
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
    Unk2: UInt16;
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
      FInBuffer: TCircularBuffer;
      FOutBuffer: TCircularBuffer;
      FSRP6: YSrpInstance;
      FSRP6Proof: YSrpProofData;
      FPatch: YNwPatch;
      FPatchHandle: TEventHandle;
      FAccount: IAccountEntry;

      procedure ManageLogonPacket(InPkt: YNwPacket);
      procedure ManageProofPacket(InPkt: YNwPacket);
      procedure ManageRealmListPacket(InPkt: YNwPacket);

      procedure ProcessBuffers;
      procedure ProcessInputBuffer;
      procedure ProcessOutputBuffer;
      procedure SendLogonError(Code: UInt8);
      procedure SendPacket(OutPkt: YNwPacket); inline; { Destroys the packet itself afterwards }

      procedure TryToUpdateClient(const Locale: WideString; Build: Int32);
      procedure InitiatePatchTransfer(InPkt: YNwPacket);
      procedure ResumePatchTransfer(InPkt: YNwPacket);
      procedure AbortPatchTransfer(InPKt: YNwPacket);
      procedure AbortTransferThread;
      procedure SendPatch(Event: TEventHandle; TimeDelta: UInt32);
    protected
      procedure Initialize; override;
    public
      destructor Destroy; override;
      property Account: IAccountEntry read FAccount;
    end;

  { Logon Manager playes god with it's sockets :) }
  YNwLogonSocketManager = class(YIoSocketServer)
    private
      const
        LOGON_THREAD_COUNT = 1;
        
      var
        FLock: TCriticalSection;
        FLogonSockets: TPtrArrayList;
        FUpdateHandle: TEventHandle;

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
  Bfg.Utils,
  Bfg.Unicode,
  Resources,
  Framework,
  Framework.SocketBase,
  Cores,
  Components.NetworkCore.Realm,
  Framework.Configuration;

constructor YNwLogonSocketManager.Create;
begin
  inherited Create(LOGON_THREAD_COUNT + SysConf.ReadInteger('Network', 'ExtraLogonWorkers', 0),
    1 + SysConf.ReadInteger('Network', 'ExtraLogonListeners', 0),
    SysConf.ReadInteger('Network', 'TimeoutDelay', 0) * 1000);

  FLock.Init;
  FLogonSockets := TPtrArrayList.Create;

  OnSocketAccept := TSocketAcceptEvent(MakeMethod(@YNwLogonSocketManager.OnAccept, Self));
  OnSocketClose := TSocketDisconnectEvent(MakeMethod(@YNwLogonSocketManager.OnClose, Self));
  OnSocketRead := TSocketReadEvent(MakeMethod(@YNwLogonSocketManager.OnRead, Self));

  FUpdateHandle := SysEventMgr.RegisterEvent(UpdateSockets, NETWORK_UPD_INTERVAL,
    TICK_EXECUTE_INFINITE, 'LogonSocketManager_Update_Event');
end;

destructor YNwLogonSocketManager.Destroy;
begin
  FUpdateHandle.Unregister;
  FLogonSockets.Free;
  FLock.Delete;
  
  inherited Destroy;
end;

class function YNwLogonSocketManager.GetSocketClass: YIoClientSocketClass;
begin
  Result := YNwLogonSocket;
end;

{ Most important methods of the Logon manager }
procedure YNwLogonSocketManager.OnAccept(Sender: YIoSocketServer; Socket: YIoClientSocket);
var
  LogonSocket: YNwLogonSocket;
begin
  LogonSocket := YNwLogonSocket(Socket);
  
  FLock.Enter;
  try
    FLogonSockets.Add(Socket);
  finally
    FLock.Leave;
  end;
  
  IoCore.Console.WriteConnectInfo(LogonSocket.LocalAddress, LogonSocket.LocalPort);
end;

procedure YNwLogonSocketManager.OnRead(Sender: YIoSocketServer; Socket: YIoClientSocket;
  Data: Pointer; Size: Longword);
var
  LogonSocket: YNwLogonSocket;
begin
  LogonSocket := YNwLogonSocket(Socket);
  
  LogonSocket.Lock;
  try
    LogonSocket.FInBuffer.Write(Data^, Size);
  finally
    LogonSocket.Unlock;
  end;
end;

procedure YNwLogonSocketManager.OnClose(Sender: YIoSocketServer; Socket: YIoClientSocket);
var
  LogonSocket: YNwLogonSocket;
begin
  LogonSocket := YNwLogonSocket(Socket);
  LogonSocket.AbortTransferThread; { Abort sending patch if it's sending ... }

  FLock.Enter;
  try
    FLogonSockets.Remove(Socket);
  finally
    FLock.Leave;
  end;

  { Logging Out Account }
  if Assigned(LogonSocket.Account) then
  begin
    LogonSocket.Account.LoggedIn := False; { Get out! }
    DataCore.Accounts.SaveEntry(LogonSocket.Account);
  end;
  { Disconnect Stuff }
  IoCore.Console.WriteDisconnectInfo(LogonSocket.LocalAddress, LogonSocket.LocalPort);
end;

procedure YNwLogonSocketManager.UpdateSockets(Event: TEventHandle;
  TimeDelta: UInt32);
var
  I: Integer;
begin
  FLock.Enter;
  try
    for I := 0 to FLogonSockets.Size -1 do
    begin
      YNwLogonSocket(FLogonSockets[I]).ProcessBuffers;
    end;
  finally
    FLock.Leave;
  end;
end;

procedure YNwLogonSocket.Initialize;
const
  InputBufferSize = 1 shl 16; { 64k Buffer }
  OutputBufferSize = 1 shl 16;
begin
  inherited Initialize;
  FInBuffer := TCircularBuffer.Create(InputBufferSize);
  FOutBuffer := TCircularBuffer.Create(OutputBufferSize);
end;

destructor YNwLogonSocket.Destroy;
begin
  FInBuffer.Free;
  FOutBuffer.Free;
  FPatch.Free;
  inherited Destroy;
end;

procedure YNwLogonSocket.ResumePatchTransfer(InPkt: YNwPacket);
begin
  { Creating a new Thread }
  if FPatch.ResumeAt(InPkt.ReadUInt64) then
  begin
    { Resume Patch Transfer At }
    InitiatePatchTransfer(InPkt);
  end;
end;

procedure YNwLogonSocket.AbortPatchTransfer(InPKt: YNwPacket);
begin
  AbortTransferThread;
end;

procedure YNwLogonSocket.AbortTransferThread;
begin
  if FPatchHandle <> nil then
  begin
    FPatchHandle.Unregister;
    FPatchHandle := nil;
    IoCore.Console.WriteLSMessage('Auto-Patch transfer aborted.', Self);
  end;
end;

procedure YNwLogonSocket.InitiatePatchTransfer(InPkt: YNwPacket);
begin
  FPatchHandle := SysEventMgr.RegisterEvent(SendPatch, PATCH_SEND_DELAY,
    TICK_EXECUTE_INFINITE);
  IoCore.Console.WriteLSMessage('Auto-Patch transfer initiated.', Self);
end;

procedure YNwLogonSocket.SendPatch(Event: TEventHandle; TimeDelta: UInt32);
var
  Body: YNwPacket;
  Size: Integer;
begin
  FPatch.ReadChunk;
  if not FPatch.IsChunkAvailable then
  begin
    { File has ended }
    IoCore.Console.WriteLSMessage('Auto-Patch transfer ended.', Self);
    FreeAndNil(FPatch);
    FPatchHandle.Unregister; { Unregister event }
    FPatchHandle := nil;
  end else
  begin
    Body := YNwPacket.Create;
    try
      Body.AddUInt8(LS_XFER_DATA);
      Size := FPatch.GetCurrentChunkSize;
      Body.AddUInt16(Size);
      FPatch.AddChunkToBuffer(Body.GetWritePtrOfSize(Size)^);
      SendPacket(Body);
    finally
      Body.Free;
    end;
  end;
end;

procedure YNwLogonSocket.TryToUpdateClient(const Locale: WideString; Build: Int32);
var
  Body: YNwPacket;
  Patch: YNwPatch;
  SizePer: Integer;
begin
  if not NetworkCore.Patches.HasPatch(Build, Locale) then
  begin
    SendLogonError(LS_E_WRONG_BUILD_NUMBER);
    Exit;
  end;

  SizePer := SysConf.ReadInteger('Data', 'PatchSpeed', 0);
  if SizePer = 0 then SizePer := 2048; { Standard size }
  Patch := NetworkCore.Patches.RetrievePatch(Build, Locale, SizePer);
  SendLogonError(LS_E_UPDATE_CLIENT);

  { Sending the Transfer Start }
  Body := YNwPacket.Create;
  try
    Body.AddUInt8(LS_XFER_INITIATE);
    Body.AddUInt8(Length(Patch.PatchType));
    Body.AddStringData(Patch.PatchType);
    Body.AddUInt64(Patch.PatchSize);
    Body.AddStringData(Patch.PatchMD5);
    SendPacket(Body);
  finally
    Body.Free;
  end;
  { Saving the patch class }

  FPatch := Patch;
end;

procedure YNwLogonSocket.ManageLogonPacket(InPkt: YNwPacket);
const
  StatusErrorTable: array[YAccountStatus] of Integer = (
    LS_E_ACCOUNT_FROZEN,
    LS_E_ACCOUNT_CLOSED,
    LS_E_PREORDER_TIME_LIMIT,
    LS_E_SUCCESS
  );
var
  LogonPkt: PLogonPacketClient;
  LogonRPkt: PLogonPacketServer;
  AllowedLocale: WideString;
  MyLocale: WideString;
  Locale: UInt32;
  AccNamePtr: PShortString;
  AccountName: WideString;
  MaxAllowed: Int32;
  OutPkt: YNwPacket;
  Acc: IAccountEntry;
  LookupRes: ILookupResult;
begin
  { Set the pointer to the first byte of the packet }
  LogonPkt := InPkt.GetReadPtrOfSize(SizeOf(YLogonPacketClient) - 1);

  { Somebody is trying to hax us! }
  if (LogonPkt^.AccLen > 16) or { Maximum account length }
     (InPkt.Size > MAX_USERNAME_LEN + 1{ Consider #0 (null-terminated) }) or
     (InPkt.Size <> SizeOf(YLogonPacketClient) + LogonPkt^.AccLen) then
  begin
    Disconnect;
  end;

  AccNamePtr := InPkt.GetCurrentReadPtr;
  AccountName := UpperCase(AccNamePtr^);

  { Cheking Localization }
  AllowedLocale := SysConf.ReadStringN('Network', 'AllowedLocales', 'enGb enUs');

  SetLength(MyLocale, 4);
  Locale := LogonPkt^.Locale;

  MyLocale[1] := WideChar((Locale shr 24) and $FF);
  MyLocale[2] := WideChar((Locale shr 16) and $FF);
  MyLocale[3] := WideChar((Locale shr 8) and $FF);
  MyLocale[4] := WideChar(Locale and $FF);

  if (Length(AllowedLocale) > 0) and (WidePos(MyLocale, AllowedLocale) = 0) then
  begin
    SendLogonError(LS_E_WRONG_BUILD_NUMBER);
    Exit;
  end;

  { Checking Build Number }

  if not IsAcceptedBuild(LogonPkt^.VerBuild) then
  begin
    TryToUpdateClient(MyLocale, LogonPkt^.VerBuild); { Trying to update this client }
    Exit;
  end;

  { Checking for account existance }
  DataCore.Accounts.LookupEntryListW('Name', AccountName, False, LookupRes, False);

  if not Assigned(LookupRes) then
  begin
    if not SysConf.ReadBoolN('Realm', 'AutoAccount', False) then
    begin
      SendLogonError(LS_E_NO_ACCOUNT);
      Exit;
    end else
    begin
      { Automatic account creation }
      DataCore.Accounts.CreateEntry(Acc);
      try
        Acc.Name := AccountName;
        Acc.Pass := AccountName;
        Acc.AutoCreated := True;
        Acc.Access := aaNormal;
        Acc.Status := asNormal;
      finally
        DataCore.Accounts.SaveEntry(Acc, False);
      end;
    end;
  end else LookupRes.GetData(Acc, 1);
  FAccount := Acc;

  { Checking for number of players }
  MaxAllowed := SysConf.ReadIntegerN('Network', 'Players');

  if (MaxAllowed > 0) and (NetworkCore.LogonThreads >= MaxAllowed) then
  begin
    if Acc.Access = aaNormal then
    begin
      SendLogonError(LS_E_SERVER_FULL);
      Exit;
    end;
  end;

  { Checking Account Status }
  if Acc.Status <> asNormal then
  begin
    SendLogonError(StatusErrorTable[Acc.Status]);
    Exit;
  end;

  { Checking if already logged in }
  if Acc.LoggedIn then
  begin
    SendLogonError(LS_E_ACCOUNT_IN_USE);
    Exit;
  end;

  { That's it. If we got here it means everything is just OK }

  { Initiating SRP6 }
  InitializeSRP6(@FSRP6, AccountName, WideUpperCase(Acc.Pass));
  GetProofSRP6Data(@FSRP6, @FSRP6Proof);

  { Sending the packet to the client }
  OutPkt := YNwPacket.Create;
  try
    LogonRPkt := OutPkt.GetWritePtrOfSize(SizeOf(YLogonPacketServer));

    with LogonRPkt^ do
    begin
      Manifest.Command := LS_AUTH_LOGON_CHALLENGE;
      Manifest.Error := LS_E_SUCCESS;
      Manifest.Unk0 := 0; { Unknown Value }
      Move(FSRP6Proof.B, BValue, SizeOf(BValue));
      GLen := SizeOf(Byte);
      Move(FSRP6Proof.G, GValue, SizeOf(GValue));
      NLen := Length(NValue);
      Move(FSRP6Proof.N, NValue, SizeOf(NValue));
      Move(FSRP6Proof.S, SValue, SizeOf(SValue));
      Move(FSRP6Proof.Unk, Unk1, SizeOf(Unk1));

      Unk2 := 0;   //this is added somehow for 1.11+ as auth packets is 1byte bigger now
    end;

    SendPacket(OutPkt);
  finally
    OutPkt.Free;
  end;
end;
  
procedure YNwLogonSocket.ManageProofPacket(InPkt: YNwPacket);
var
  ProofPkt: PProofPacketClient;
  ProofResponsePkt: PProofPacketServer;
  Manifest: PLogonPacketManifest;
  OutPkt: YNwPacket;
begin
  { Set the pointer to the first byte of the packet }
  ProofPkt := InPkt.GetReadPtrOfSize(SizeOf(YProofPacketClient));

  { Contin9ued SRP6 }
  if Assigned(FAccount) and ValidateSRP6(@FSRP6, @ProofPkt^.AValue, @ProofPkt^.M1Value, @FSRP6Proof) then
  begin
    OutPkt := YNwPacket.Create;
    try
      ProofResponsePkt := OutPkt.GetWritePtrOfSize(SizeOf(YProofPacketServer));

      with ProofResponsePkt^ do
      begin
        Manifest.Command := LS_AUTH_LOGON_PROOF;
        Manifest.Error := LS_E_SUCCESS;

        Move(FSRP6Proof.M2, M2Value, Length(M2Value));
        Unk1 := 0; { Unknown }
      end;

      SendPacket(OutPkt);
    finally
      OutPkt.Free;
    end;

    try
      FAccount.LoggedIn := True; { Whoops, You're in baby :) }
      FAccount.Hash := FSRP6Proof.SS_Hash;
    finally
      DataCore.Accounts.SaveEntry(FAccount, False);
    end;
  end else
  begin
    OutPkt := YNwPacket.Create;
    try
      Manifest := OutPkt.GetWritePtrOfSize(SizeOf(YLogonPacketManifest));
      with Manifest^ do
      begin
        Command := LS_AUTH_LOGON_PROOF;
        Error := LS_E_NO_ACCOUNT;
      end;
      
      SendPacket(OutPkt);
    finally
      OutPkt.Free;
    end;
  end;
end;
  
procedure YNwLogonSocket.ManageRealmListPacket(InPkt: YNwPacket);
var
  RealmRPkt: PRealmPacketServerHeader;
  Rlm: Integer;
  Len: Integer;
  Count: Integer;
  OutPkt: YNwPacket;
begin
  OutPkt := YNwPacket.Create;
  try
    RealmRPkt := OutPkt.GetWritePtrOfSize(SizeOf(YRealmPacketServerHeader));
    RealmRPkt^.Command := LS_REALM_LIST;
    Count := NetworkCore.Realms.Count;

    Len := 13 * Count + 7;
    OutPkt.JumpUInt32; { Unknown }
    OutPkt.AddUInt16(Count); { Realm Count }  //changed realm count to uint16 since 2.0.3 or 2.0.5

    for Rlm := 0 to Count - 1 do
    begin
      with NetworkCore.Realms.Realms[Rlm] do
      begin
        OutPkt.AddUInt8(RealmIcon);
        OutPkt.AddUInt8(RealmColor);     //since 2.0.6 it is UInt8
        OutPkt.JumpUInt8;     //Unknown value! Either RealmColor is back UInt16 or this is a new value for realms
        OutPkt.AddString(RealmName);
        OutPkt.AddString(RealmAddr);
        OutPkt.AddFloat(RealmPpl);               //06 81 35 40
        OutPkt.AddUInt8(RealmChars[FAccount.Name]);
        OutPkt.AddUInt8(RealmTZone);
        OutPkt.JumpUInt16; { Realms Separator }  //since 2.0.6 it is UInt16 and not UInt8...
        Inc(Len, Length(RealmName) + Length(RealmAddr));
      end;
    end;

    OutPkt.JumpUInt8;   { Realmlist terminator }

    RealmRPkt^.Size := Len;

    SendPacket(OutPkt);
  finally
    OutPkt.Free;
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
  InPkt: YNwPacket;
  PktHdr: YLogonPacketClient;
  Cmd: UInt8;
begin
  repeat
    if FInBuffer.ReadAvail = 0 then Exit;

    Cmd := PByte(FInBuffer[FInBuffer.ReadPosition])^;

    case Cmd of
      LS_AUTH_LOGON_CHALLENGE:
      begin
        { Make sure the whole packet has been received }
        if FInBuffer.ReadAvail >= SizeOf(YLogonPacketClient) then
        begin
          FInBuffer.Read(PktHdr, SizeOf(YLogonPacketClient));
          if FInBuffer.ReadAvail >= PktHdr.AccLen then
          begin
            InPkt := YNwPacket.Create(PktHdr.AccLen + SizeOf(PktHdr));
            try
              Move(PktHdr, InPkt.Storage[0], SizeOf(PktHdr));
              FInBuffer.Read(InPkt.Storage[SizeOf(PktHdr)], PktHdr.AccLen);
              InPkt.WritePos := InPkt.Size;
              ManageLogonPacket(InPkt);
              //IoCore.Console.WriteReceivedPacketSize(cInPkt);
            finally
              InPkt.Free;
            end;
          end else Exit;
        end else Exit;
      end;
      LS_AUTH_LOGON_PROOF:
      begin
        { Make sure the whole packet has been received }
        if FInBuffer.ReadAvail >= SizeOf(YProofPacketClient) then
        begin
          InPkt := YNwPacket.Create(SizeOf(YProofPacketClient));
          try
            FInBuffer.Read(InPkt.Storage[0], SizeOf(YProofPacketClient));
            InPkt.WritePos := InPkt.Size;
            ManageProofPacket(InPkt);
          finally
            InPkt.Free;
          end;
        end else Exit;
      end;
      LS_REALM_LIST:
      begin
        { Make sure the whole packet has been received }
        if FInBuffer.ReadAvail >= SizeOf(YRealmPacketClient) then
        begin
          InPkt := YNwPacket.Create(SizeOf(YRealmPacketClient));
          try
            FInBuffer.Read(InPkt.Storage[0], SizeOf(YRealmPacketClient));
            InPkt.WritePos := InPkt.Size;
            ManageRealmlistPacket(InPkt);
          finally
            InPkt.Free;
          end;
        end else Exit;
      end;
      LS_XFER_ACCEPT:
      begin
        if FInBuffer.ReadAvail >= 1 then
        begin
          InPkt := YNwPacket.Create(1);
          try
            FInBuffer.Read(InPkt.Storage[0], 1);
            InPkt.WritePos := InPkt.Size;
            InitiatePatchTransfer(InPkt);
          finally
            InPkt.Free;
          end;
        end else Exit;
      end;
      LS_XFER_CANCEL:
      begin
        if FInBuffer.ReadAvail >= 1 then
        begin
          InPkt := YNwPacket.Create(1);
          try
            FInBuffer.Read(InPkt.Storage[0], 1);
            InPkt.WritePos := InPkt.Size;
            AbortPatchTransfer(InPkt);
          finally
            InPkt.Free;
          end;
        end else Exit;
      end;
      LS_XFER_RESUME:
      begin
        { Make sure the whole packet has been received }
        if FInBuffer.ReadAvail >= SizeOf(YXferPacketResumeClient) then
        begin
          InPkt := YNwPacket.Create(SizeOf(YXferPacketResumeClient));
          try
            FInBuffer.Read(InPkt.Storage[0], SizeOf(YXferPacketResumeClient));
            InPkt.WritePos := InPkt.Size;
            ResumePatchTransfer(InPkt);
          finally
            InPkt.Free;
          end;
        end else Exit;
      end;
    else
      begin
        { An invalid packet has arrived, maybe some DDoS-er? }
        FInBuffer.Clear;
        IoCore.Console.WriteLSErrorMessage(RsInvalidPacketMsg, Cmd, Self);
        Disconnect;
        Exit;
      end;
    end;
  until False;
end;

procedure YNwLogonSocket.ProcessOutputBuffer;
begin
  if FOutBuffer.ReadAvail = 0 then Exit;

  Owner.SendData(Self, FOutBuffer[FOutBuffer.ReadPosition]^, FOutBuffer.ReadAvail);
  FOutBuffer.ReadPosition := FOutBuffer.ReadPosition + FOutBuffer.ReadAvail;
end;

procedure YNwLogonSocket.SendLogonError(Code: UInt8);
var
  Manifest: PLogonResponseManifest;
  Pkt: YNwPacket;
begin
  Pkt := YNwPacket.Create;
  try
    Manifest := Pkt.GetWritePtrOfSize(SizeOf(YLogonResponseManifest));
    with Manifest^ do
    begin
      Command := LS_AUTH_LOGON_CHALLENGE;
      Error := Code;
      Unk0 := 0; { Unknown }
    end;

    SendPacket(Pkt);
  finally
    Pkt.Free;
  end;
end;

procedure YNwLogonSocket.SendPacket(OutPkt: YNwPacket);
begin
  Lock;
  try
    FOutBuffer.Write(OutPkt.Storage[0], OutPkt.WritePos);
  finally
    Unlock;
  end;
end;

end.
