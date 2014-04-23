{*------------------------------------------------------------------------------
  Sockets implementing the IOCP(I/O Completion Ports) technology.
  Warning! - This unit is a mess, C-style.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Framework.SocketBase;

interface

uses
  API.Win.Winsock2,
  API.Win.Types,
  API.Win.NtStatus,
  API.Win.NtCommon,
  API.Win.NtApi,
  API.Win.Kernel,
  Framework.Base,
  Framework.Tick,
  Framework.ThreadManager,
  Bfg.Utils,
  Bfg.Resources,
  Bfg.Containers,
  Bfg.Threads,
  Bfg.SystemInfo,
  SysUtils;

const
  BANNED_CLEAR_PERIOD = 60000 { ms = 1 min };
  MAX_LOGIN_COUNT = 10;
  MAX_ACCEPTED_CONN_IDLE_TIME = 10; { seconds }
  TIMEOUT_WAIT_MIN = 2500; { sleep time of the timeout detection loop, in ms }

type
  TSocketServer = class;
  TRawClientSocket = class;

  {$Z4}
  TSocketExceptionType = (etWSA, etIo, etCompletionPort);
  {$Z1}

  TSocketErrorFormatRoutine = function(Data: Pointer): string;

  { On Accept event proto }
  TSocketAcceptEvent = procedure(Sender: TSocketServer; Socket: TRawClientSocket) of object;

  { On Read event proto }
  TSocketReadEvent = procedure(Sender: TSocketServer; Socket: TRawClientSocket;
    Data: Pointer; Size: Integer) of object;

  { On Write event proto }
  TSocketWriteEvent = procedure(Sender: TSocketServer; Socket: TRawClientSocket;
    Size: Integer) of object;

  { On Disconnect event proto }
  TSocketDisconnectEvent = procedure(Sender: TSocketServer; Socket: TRawClientSocket) of object;

  { On Error event proto }
  TSocketErrorEvent = procedure(Sender: TSocketServer; const ErrorMsg: string) of object;

  {$Z4}
  TIoOperation = (ioAccept, ioInput, ioOutput, ioInvalid);
  {$Z1}

  PClientContext = ^TClientContext;
  TClientContext = record
    ListEntry: TAtomicListEntry;
    Socket: TSocket;
    Instance: TRawClientSocket;
    IsIdle: Longbool;
    CheckTime: UInt32;
  end;

  PIoBuffer = ^TIoBuffer;
  TIoBuffer = record
    Ov: TOverlapped;
    ListEntry: TAtomicListEntry;
    WSABuf: WSABUF;
    IoType: TIoOperation;
    Transfered: UInt32;
    SocketHandle: TSocket;
    IoBuf: PByteArray;
  end;

  PIpStatusRec = ^TIpStatusRec;
  TIpStatusRec = record
    LogInAttempts: Integer;
    Banned: Boolean; { For alignment }
  end;

  TRawClientSocket = class(TReferencedObject)
    protected
      fSocket: TSocket;
      fAddress: TSockAddr;
      fLock: TCriticalSection;

      function GetLocalAddress: string;
      function GetLocalPort: Integer;
      function GetSocketHandle: Integer;
    public
      constructor Create(Socket: TSocket; Address: PSockAddr); reintroduce;
      destructor Destroy; override;
      procedure Disconnect;

      procedure Lock;
      procedure Unlock;

      property SocketHandle: Integer read GetSocketHandle;
      property LocalAddress: string read GetLocalAddress;
      property LocalPort: Integer read GetLocalPort;
  end;

  TSocketServer = class(TReferencedObject)
    private
      fOnAccept: TSocketAcceptEvent;
      fOnRead: TSocketReadEvent;
      fOnWrite: TSocketWriteEvent;
      fOnClose: TSocketDisconnectEvent;
      fOnError: TSocketErrorEvent;

      fListener: TSocket;
      fListenerAddress: TSockAddrIn;
      fListenerHandleData: TClientContext;

      fAcceptEx: TAcceptEx;
      fGetAcceptExSockAddrs: TGetAcceptExSockAddrs;

      fPermanentlyBanned: TIntArrayList;
      fIpList: TIntPtrHashMap;

      fAcceptedSockets: TIntPtrHashMap;
      fClientCount: Int32;
      fMaxIdleTime: Longword;

      fLock: TCriticalSection;
      fListLock: TCriticalSection;

      fCompletionPort: THandle;
      fAcceptCompletionPort: THandle;
      fTimer: TEventHandle;

      fThreadCount: Integer;
      fIoThreads: Integer;
      fListenerThreads: Integer;

      fTimeoutCheckThread: TThreadHandle;
      fThreads: array of TThreadHandle;

      fTimeoutThreadEvent: TEvent;

      fFreeBufs: TAtomicListHead;
      fFreeContexts: TAtomicListHead;

      fPort: Word;

      function AllocateClientContext(Socket: TSocket): PClientContext;
      procedure ReleaseClientContext(Context: PClientContext);
      function AllocateIoBuffer(Operation: TIoOperation): PIoBuffer;
      procedure ReleaseIoBuffer(Buf: PIoBuffer);

      procedure DisconnectClient(Context: PClientContext;
        FreeInstance: Boolean = True);

      procedure CheckWSAResult(ResStr: PResStringRec; Data: PIoBuffer);

      procedure ClearBannedAndIpLists(Event: TEventHandle; TimeDelta: UInt32);
      procedure ProcessInputRequest(Handle: PClientContext; Io: PIoBuffer;
        Transfered: UInt32);
      procedure ProcessOutputRequest(Handle: PClientContext; Io: PIoBuffer;
        Transfered: UInt32);

      procedure ProcessNetworkIo(Thread: TThreadHandle);
      procedure ProcessAcceptRequests(Thread: TThreadHandle);
      procedure CheckConnectionsForTimeout(Thread: TThreadHandle);

      procedure IssueRead(Socket: TSocket);
      procedure IssueWrite(Socket: TSocket; const Data; Size: Integer);
    protected
      function ConstructSocket(Socket: Integer; Address: PSockAddr): TRawClientSocket; virtual;

      procedure DoOnAccept(Socket: TRawClientSocket); inline;
      procedure DoOnRead(Socket: TRawClientSocket; const Data; Size: Integer); inline;
      procedure DoOnWrite(Socket: TRawClientSocket; Size: Integer); inline;
      procedure DoOnClose(Socket: TRawClientSocket); inline;
      procedure DoOnError(const sErrorMsg: string); inline;
      function GetThreadCount: Integer;
      function GetClientCount: Integer;
    public
      constructor Create(NumOfIoThreads, NumOfListenerThreads, MaxIdleTime: Longword); reintroduce;
      destructor Destroy; override;
      
      procedure AddToPermanentBanList(IP: Longword);
      procedure SendData(Socket: TRawClientSocket; const Data; Size: Integer);
      procedure Start(Port: Word);
      procedure DisconnectAll;

      property ThreadCount: Integer read GetThreadCount;
      property ClientCount: Integer read GetClientCount;
      property LocalPort: Word read fPort;

      property OnSocketAccept: TSocketAcceptEvent read fOnAccept write fOnAccept;
      property OnSocketRead: TSocketReadEvent read fOnRead write fOnRead;
      property OnSocketSend: TSocketWriteEvent read fOnWrite write fOnWrite;
      property OnSocketClose: TSocketDisconnectEvent read fOnClose write fOnClose;
      property OnSocketError: TSocketErrorEvent read fOnError write fOnError;
  end;

implementation

uses
  MMSystem, 
  Framework,
  Framework.Resources;

{ YRawClientSocket }

constructor TRawClientSocket.Create(Socket: TSocket; Address: PSockAddr);
begin
  inherited Create;
  fSocket := Socket;
  if Address <> nil then fAddress := Address^;
  fLock.Init;
end;

destructor TRawClientSocket.Destroy;
begin
  fLock.Delete;
  inherited Destroy;
end;

function TRawClientSocket.GetSocketHandle;
begin
  Result := fSocket;
end;

procedure TRawClientSocket.Lock;
begin
  fLock.Enter;
end;

procedure TRawClientSocket.Unlock;
begin
  fLock.Leave;
end;

function TRawClientSocket.GetLocalAddress: string;
begin
  Result := inet_ntoa(fAddress.sin_addr);
end;

function TRawClientSocket.GetLocalPort: Integer;
begin
  Result := ntohs(fAddress.sin_port);
end;

procedure TRawClientSocket.Disconnect;
begin
  shutdown(fSocket, SD_SEND);
  closesocket(fSocket);
end;

{ YSocketServer }

constructor TSocketServer.Create(NumOfIoThreads, NumOfListenerThreads,
  MaxIdleTime: Longword);
var
  iInt: Int32;
begin
  inherited Create;

  InitializeAtomicSList(@fFreeContexts);
  InitializeAtomicSList(@fFreeBufs);

  fCompletionPort := CreateIoCompletionPort(INVALID_HANDLE_VALUE, 0, 0, fThreadCount);
  if fCompletionPort = INVALID_HANDLE_VALUE then
  begin
    raise EApiCallFailed.CreateResFmt(@RsCreateIoCompletionPort, [SysErrorMessage(GetLastError)]);
  end;

  fAcceptCompletionPort := CreateIoCompletionPort(INVALID_HANDLE_VALUE, 0, 0, 1);
  if fAcceptCompletionPort = INVALID_HANDLE_VALUE then
  begin
    raise EApiCallFailed.CreateResFmt(@RsCreateIoCompletionPort, [SysErrorMessage(GetLastError)]);
  end;

  fLock.Init;
  fListLock.Init;

  fPermanentlyBanned := TIntArrayList.Create(512);
  fIpList := TIntPtrHashMap.Create(512);
  fAcceptedSockets := TIntPtrHashMap.Create(2048);

  fIoThreads := NumOfIoThreads;
  fListenerThreads := NumOfListenerThreads;
  fThreadCount := NumOfIoThreads + NumOfListenerThreads;

  SetLength(fThreads, fThreadCount);

  for iInt := 0 to NumOfIoThreads -1 do
  begin
    fThreads[iInt] := SysThreadMgr.CreateThread(ProcessNetworkIo, True,
      'Network_Io_Thread');
  end;

  for iInt := NumOfIoThreads to fThreadCount -1 do
  begin
    fThreads[iInt] := SysThreadMgr.CreateThread(ProcessAcceptRequests, True,
      'Accept_Io_Thread');
  end;

  fMaxIdleTime := MaxIdleTime;

  fTimeoutThreadEvent.Init(False, False);

  fTimeoutCheckThread := SysThreadMgr.CreateThread(CheckConnectionsForTimeout,
    True, 'Timeout_Check_Thread');

  fListener := WSASocket(AF_INET, SOCK_STREAM, IPPROTO_TCP, nil, 0,
    WSA_FLAG_OVERLAPPED);

  if fListener = INVALID_SOCKET then raise ESocketError.Create(WSAErrorMessage(WSAGetLastError));

  fListenerAddress.sin_family := PF_INET;
  fListenerAddress.sin_addr.S_addr := INADDR_ANY;
  @fAcceptEx := WSAGetExtensionFunctionPointer(fListener, WSAID_ACCEPTEX);
  @fGetAcceptExSockAddrs := WSAGetExtensionFunctionPointer(fListener, WSAID_GETACCEPTEXSOCKADDRS);

  if (@fAcceptEx = nil) then
  begin
    raise EApiNotFound.CreateResFmt(@RsMissingExport, [WINSOCK2_DLL, LoadResString(@RsAcceptEx)]);
  end;
  if (@fGetAcceptExSockAddrs = nil) then
  begin
    raise EApiNotFound.CreateResFmt(@RsMissingExport, [WINSOCK2_DLL, LoadResString(@RsGetAcceptExSockAddrs)]);
  end;

  fListenerHandleData.Socket := fListener;

  if CreateIoCompletionPort(fListener, fAcceptCompletionPort, Longword(@fListenerHandleData),
    0) = 0 then raise EApiCallFailed.CreateResFmt(@RsCreateIoCompletionPort, [SysErrorMessage(GetLastError)]);
end;

destructor TSocketServer.Destroy;
var
  ifItr: IPtrIterator;
  iInt: Int32;
  pCtx: PClientContext;
  pBuf: PIoBuffer;
begin
  closesocket(fListener);
  fTimer.Unregister;

  for iInt := 0 to fIoThreads -1 do
  begin
    PostQueuedCompletionStatus(fCompletionPort, 0, 0, nil);
  end;

  for iInt := 0 to fListenerThreads -1 do
  begin
    PostQueuedCompletionStatus(fAcceptCompletionPort, 0, 0, nil);
  end;
  
  for iInt := 0 to fThreadCount -1 do
  begin
    fThreads[iInt].WaitForEnd(1000);
  end;

  fTimeoutThreadEvent.Signal;
  fTimeoutCheckThread.WaitForEnd(1000);
  
  fTimeoutThreadEvent.Delete;
  CloseHandle(fCompletionPort);
  CloseHandle(fAcceptCompletionPort);

  fLock.Enter;
  fListLock.Enter;
  try
    ifItr := fAcceptedSockets.Values;
    while ifItr.HasNext do
    begin
      DisconnectClient(ifItr.Next);
    end;

    ifItr := fIpList.Values;
    while ifItr.HasNext do
    begin
      FreeMem(ifItr.Next);
    end;
  finally
    fLock.Leave;
    fListLock.Leave;
  end;

  fPermanentlyBanned.Free;
  fIpList.Free;
  fAcceptedSockets.Free;

  fLock.Delete;
  fListLock.Delete;

  pCtx := PClientContext(AtomicPopEntrySList(@fFreeContexts));
  while pCtx <> nil do
  begin
    Dispose(pCtx);
    pCtx := PClientContext(AtomicPopEntrySList(@fFreeContexts));
  end;

  repeat
    pBuf := PIoBuffer(AtomicPopEntrySList(@fFreeBufs));
    if not Assigned(pBuf) then Break;
    Dec(PByte(pBuf), SizeOf(TOverlapped));
    VirtualFree(pBuf^.IoBuf, PageSize, MEM_RELEASE);
    Dispose(pBuf);
  until pBuf = nil;

  inherited Destroy;
end;

procedure TSocketServer.ClearBannedAndIpLists(Event: TEventHandle; TimeDelta: UInt32);
var
  iInt: Integer;
  ifItr: IPtrIterator;
  pIpData: PIpStatusRec;
begin
  fListLock.Enter;
  try
    ifItr := fIpList.Values;
    while ifItr.HasNext do
    begin
      Dispose(PIpStatusRec(ifItr.Next));
    end;

    fIpList.Clear;

    for iInt := 0 to fPermanentlyBanned.Size -1 do
    begin
      New(pIpData);
      pIpData^.LogInAttempts := MAX_LOGIN_COUNT;
      pIpData^.Banned:= True;
      fIpList.PutValue(fPermanentlyBanned.Items[iInt], pIpData);
    end;
  finally
    fListLock.Leave;
  end;
end;

procedure TSocketServer.CheckWSAResult(ResStr: PResStringRec; Data: PIoBuffer);
var
  iError: Longword;
begin
  iError := WSAGetLastError;
  if iError <> WSA_IO_PENDING then
  begin
    ReleaseIoBuffer(Data);
    DoOnError(Format(RsWSAExceptionMessage, [LoadResString(ResStr), WSAErrorMessage(iError)]));
  end;
end;

procedure TSocketServer.IssueRead(Socket: TSocket);
var
  pIoData: PIoBuffer;
  lwFlags: Longword;
begin
  pIoData := AllocateIoBuffer(ioInput);
  { The most important thing is to supply each I/O operation a separate TOverlapped structure }
  { TOverlapped is in this case the TIoBuffer record }
  lwFlags := 0;
  { Flags are always 0 }
  with pIoData^ do
  begin
    { We want to read data so ioType is opInput }
    WSABuf.len := PageSize;
    { We receive any pending data }
    { If there are no threads to process such a request, WSARecv returns WSA_IO_PENDING }
    { That's not of a concern here since it will be automaticly finished later }

    if WSARecv(Socket, @WSABuf, 1, @Transfered, @lwFlags, @Ov, nil) <> 0 then
    begin
      CheckWSAResult(@RsWSARecv, pIoData);
    end;
  end;
end;

procedure TSocketServer.IssueWrite(Socket: TSocket; const Data; Size: Integer);
var
  pIoData: PIoBuffer;
  lwFlags: Longword;
  iBufferMultiple: Integer;
begin
  { The most important thing is to supply each I/O operation a separate TOverlapped structure }
  { TOverlapped is in this case the TIoBuffer record }
  lwFlags := 0;
  { Flags are always 0 }
  if Size <= Integer(PageSize) then
  begin
    pIoData := AllocateIoBuffer(ioOutput);
    with pIoData^ do
    begin
      { We want to send data so ioType is opOutput }
      Move(Data, IoBuf^[0], Size);
      { Copy the data we want to send into the buffer }
      {
        This is needed since WSASend does not guarantee:
          a) it sends all data at once
          b) it sends data as soon as the call is made

        A situation may arise in which all threads are busy to send data and WSAGetLastError
        returns WSA_IO_PENDING. If we'd only pointed the PChar buffer to xData, it would work,
        as long as that data would be valid until the actual I/O operation completes. That's
        a tricky thing to achieve, so we'll rather copy the data. :) }
      WSABuf.len := Size;
      if WSASend(Socket, @WSABuf, 1, @Transfered, lwFlags, @Ov, nil) <> 0 then
      begin
        CheckWSAResult(@RsWSASend, pIoData);
      end;
      { We send any pending data }
      { If there are no threads to process such a request, WSASend returns WSA_IO_PENDING }
      { That's not of a concern here since it will be automaticly finished later }
    end;
  end else
  begin
    { The data we want to send is greater than PageSize, so we must split it and issue 2 or more sends }
    { Other than that, the process is the same }
    iBufferMultiple := 0;
    while Size > Integer(PageSize) do
    begin
      { Send as many BUFFER_SIZE data blocks as possible }
      pIoData := AllocateIoBuffer(ioOutput);
      with pIoData^ do
      begin
        WSABuf.len := PageSize;
        Move(Data, IoBuf^[0], PageSize);
        if WSASend(Socket, @WSABuf, 1, @Transfered, lwFlags, @Ov, nil) <> 0 then
        begin
          CheckWSAResult(@RsWSASend, pIoData);
        end;
      end;
      Dec(Size, PageSize);
      Inc(iBufferMultiple);
    end;

    if Size > 0 then
    begin
      { And finally send the last incomplete block }
      pIoData := AllocateIoBuffer(ioOutput);
      with pIoData^ do
      begin
        WSABuf.len := Size;
        OffsetMove(Data, IoBuf^[0], Size, Integer(PageSize) * iBufferMultiple, 0);
        if WSASend(Socket, @WSABuf, 1, @Transfered, lwFlags, @Ov, nil) <> 0 then
        begin
          CheckWSAResult(@RsWSASend, pIoData);
        end;
      end;
    end;
  end;
end;

function TSocketServer.AllocateIoBuffer(Operation: TIoOperation): PIoBuffer;
begin
  Result := PIoBuffer(AtomicPopEntrySList(@fFreeBufs));
  if Result = nil then
  begin
    Result := AllocMem(SizeOf(TIoBuffer));
    Result^.IoBuf := VirtualAlloc(nil, PageSize, MEM_COMMIT, PAGE_READWRITE);
    if Result^.IoBuf = nil then
    begin
      Result := nil;
      Exit;
    end;
    Result^.WSABuf.buf := PChar(Result^.IoBuf);
  end else
  begin
    Dec(PByte(Result), SizeOf(TOverlapped));
    VirtualAlloc(Result^.IoBuf, PageSize, MEM_COMMIT, PAGE_READWRITE);
  end;
  Result^.IoType := Operation;
end;

function TSocketServer.AllocateClientContext(Socket: TSocket): PClientContext;
begin
  Result := PClientContext(AtomicPopEntrySList(@fFreeContexts));
  if Result = nil then
  begin
    Result := AllocMem(SizeOf(TClientContext));
    Result^.IsIdle := True;
  end;
  Result^.Socket := Socket;
end;

const
  MAX_CONTEXTS_PER_CLIENT = 2;
  MAX_BUFS_PER_CLIENT = 15 * MAX_CONTEXTS_PER_CLIENT;

procedure TSocketServer.ReleaseIoBuffer(Buf: PIoBuffer);
var
  OldHead: PIoBuffer;
  Count: Int32;
begin
  if Buf <> nil then
  begin
    Count := fClientCount;
    if QueryDepthAtomicSList(@fFreeBufs) * Count < Count * MAX_BUFS_PER_CLIENT then
    begin
      FillChar(Buf^.Ov, SizeOf(TOverlapped), 0);
      Buf^.Transfered := 0;
      Buf^.SocketHandle := 0;
      OldHead := PIoBuffer(AtomicPushEntrySList(@fFreeBufs, @Buf^.ListEntry));
      if OldHead <> nil then
      begin
        Dec(PByte(OldHead), SizeOf(TOverlapped));
        VirtualFree(OldHead^.IoBuf, PageSize, MEM_DECOMMIT);
      end;
    end else
    begin
      VirtualFree(Buf^.IoBuf, PageSize, MEM_RELEASE);
      Dispose(Buf);
    end;
  end;
end;

procedure TSocketServer.ReleaseClientContext(Context: PClientContext);
begin
  if Context <> nil then
  begin
    if QueryDepthAtomicSList(@fFreeContexts) < fClientCount * MAX_CONTEXTS_PER_CLIENT then
    begin
      FillChar(Context^, SizeOf(TClientContext), 0);
      AtomicPushEntrySList(@fFreeContexts, PAtomicListEntry(Context));
    end else
    begin
      Dispose(Context);
    end;
  end;
end;

procedure TSocketServer.CheckConnectionsForTimeout(Thread: TThreadHandle);
var
  pHandleData: PClientContext;
  dwConnTime: Longword;
  dwOut: Longword;
  dwNow: Longword;
  ifItr: IPtrIterator;
begin
  dwOut := SizeOf(dwConnTime);

  while fTimeoutThreadEvent.WaitFor(TIMEOUT_WAIT_MIN) <> WAIT_OBJECT_0 do
  begin
    fLock.Enter;
    try
      if fAcceptedSockets.Size <> 0 then
      begin
        dwNow := TimeGetTime;
        ifItr := fAcceptedSockets.Values;
        while ifItr.HasNext do
        begin
          pHandleData := ifItr.Next;
          if pHandleData^.IsIdle then
          begin
            if getsockopt(pHandleData^.Socket, SOL_SOCKET, SO_CONNECT_TIME, @dwConnTime,
              Integer(dwOut)) <> 0 then Continue;
            if dwConnTime >= MAX_ACCEPTED_CONN_IDLE_TIME then
            begin
              pHandleData^.Instance.Disconnect;
            end;
          end else if fMaxIdleTime <> 0 then
          begin
            dwConnTime := GetTimeDifference(dwNow, pHandleData^.CheckTime);
             if dwConnTime >= fMaxIdleTime then
            begin
              pHandleData^.Instance.Disconnect;
            end;
          end;
        end;
      end;
    finally
      fLock.Leave;
    end;
  end;
end;

procedure TSocketServer.ProcessAcceptRequests(Thread: TThreadHandle);
type
  {$Z4}
  YIoCompletionType = (ictSuccessIo, ictConnClosed, ictQuit, ictFailedIo, ictNoDequeue, ictIllegal);
  {$Z1}
const
  IoCompletionTable: array[Boolean, Boolean, Boolean] of YIoCompletionType = (
    (
      (ictNoDequeue, ictNoDequeue),
      (ictFailedIo, ictFailedIo)
    ),
    (
      (ictQuit, ictIllegal),
      (ictSuccessIo, ictSuccessIo)
    )
  );
var
  pHandleData: PClientContext;
  tIoData: TIoBuffer;
  pIoData: PIoBuffer;
  bResult: Boolean;
  lwNumberOfBytesTransfered: Longword;
  iSocket: TSocket;
  iAccepted: TSocket;
  pAddrs: array[0..1] of PSockAddr; { 0 - Local, 1 - Remote }
  lwAddr: Longword;
  pIpData: PIpStatusRec;
label
  __AcceptConn, __DisconnectConn;
begin
  FillChar(tIoData, SizeOf(tIoData), 0);
  pIoData := @tIoData;
  pIoData^.IoBuf := VirtualAlloc(nil, PageSize, MEM_COMMIT, PAGE_READWRITE);
  pIoData^.WSABuf.buf := PChar(pIoData^.IoBuf);
  pIoData^.WSABuf.len := PageSize;
  iSocket := WSASocket(AF_INET, SOCK_STREAM, IPPROTO_TCP, nil, 0, WSA_FLAG_OVERLAPPED);
  pIoData^.SocketHandle := iSocket;

  if not fAcceptEx(fListener, iSocket, pIoData^.WSABuf.buf, 0, PageSize shr 1,
    PageSize shr 1, @pIoData^.Transfered, POverlapped(pIoData)) then
  begin
    CheckWSAResult(@RsAcceptEx, pIoData);
  end;

  while True do
  begin
    pHandleData := nil;
    bResult := GetQueuedCompletionStatus(fAcceptCompletionPort, @lwNumberOfBytesTransfered,
      @pHandleData, POverlapped(pIoData), INFINITE);

    if pHandleData <> nil then iSocket := pHandleData^.Socket else iSocket := INVALID_SOCKET;

    case IoCompletionTable[bResult, pIoData <> nil, lwNumberOfBytesTransfered <> 0] of
      ictSuccessIo:
      begin
        { The listening socket has received a new connection }
        iAccepted := pIoData^.SocketHandle;

        fGetAcceptExSockAddrs(pIoData^.WSABuf.buf, 0, PageSize shr 1,
          PageSize shr 1, pAddrs[0], @pIoData^.Transfered, pAddrs[1],
          @pIoData^.Transfered);

        lwAddr := pAddrs[1]^.sin_addr.S_addr;

        pHandleData := AllocateClientContext(iAccepted);
        if CreateIoCompletionPort(iAccepted, fCompletionPort, Longword(pHandleData),
          fThreadCount) = 0 then
        begin
          { Call the OnError handler }
          DoOnError(Format(RsGenExceptionMessage, [LoadResString(@RsCreateIoCompletionPort),
            SysErrorMessage(GetLastError)]));
          { Sorry fella, but we must disconnect you }
          DisconnectClient(pHandleData);
          ReleaseClientContext(pHandleData);
        end else
        begin
          fListLock.Enter;
          try
            pIpData := fIpList.GetValue(lwAddr);
            if pIpData = nil then
            begin
              New(pIpData);
              pIpData^.LogInAttempts := 1;
              pIpData^.Banned := False;
              fIpList.PutValue(lwAddr, pIpData);
              goto __AcceptConn;
            end else if not pIpData^.Banned then
            begin
              if pIpData^.LogInAttempts < MAX_LOGIN_COUNT then
              begin
                Inc(pIpData^.LogInAttempts);

                __AcceptConn:
                pHandleData^.Instance := ConstructSocket(iAccepted, pAddrs[0]);

                fLock.Enter;
                try
                  fAcceptedSockets.PutValue(iAccepted, pHandleData);
                  AtomicInc(@fClientCount);
                finally
                  fLock.Leave;
                end;

                DoOnAccept(pHandleData^.Instance);

                IssueRead(pHandleData^.Socket);
              end else
              begin
                pIpData^.Banned := True;
                goto __DisconnectConn;
              end;
            end else
            begin
              __DisconnectConn:
              DisconnectClient(pHandleData);
              ReleaseClientContext(pHandleData);
            end;
          finally
            fListLock.Leave;
          end;
        end;

        { We'll reuse pIoData }
        pIoData^.SocketHandle := WSASocket(AF_INET, SOCK_STREAM, IPPROTO_TCP,
          nil, 0, WSA_FLAG_OVERLAPPED);

        if not fAcceptEx(iSocket, pIoData^.SocketHandle, pIoData^.WSABuf.buf, 0,
          PageSize shr 1, PageSize shr 1, @pIoData^.Transfered,
          POverlapped(pIoData)) then
        begin
          CheckWSAResult(@RsAcceptEx, pIoData);
        end;
      end;
      ictQuit: Break;
    end;
  end;
  VirtualFree(tIoData.IoBuf, PageSize, MEM_RELEASE);
end;

procedure TSocketServer.ProcessNetworkIo(Thread: TThreadHandle);
type
  {$Z4}
  YIoCompletionType = (ictSuccessIo, ictConnClosed, ictQuit, ictFailedIo, ictNoDequeue, ictIllegal);
  {$Z1}
const
  { Decision table }
  {                 +---------------------------+---------------------------+
                    |       pIoData = nil       |     pIoData <> nil        |
                    +-------------+-------------+-------------+-------------+
                    | lwBytes = 0 | lwBytes > 0 | lwBytes = 0 | lwBytes > 0 |
  +-----------------+-------------+-------------+-------------+-------------+
  | bResult = False | No Dequeue  | No Dequeue  | Failed I/O  | Failed I/O  |
  +-----------------+-------------+-------------+-------------+-------------+
  | bResult = True  | Quit        | Illegal     | Conn Closed | Success I/O |
  +-----------------+-------------+-------------+-------------+-------------+
  }
  IoCompletionTable: array[Boolean, Boolean, Boolean] of YIoCompletionType = (
    (
      (ictNoDequeue, ictNoDequeue),
      (ictFailedIo, ictFailedIo)
    ),
    (
      (ictQuit, ictIllegal),
      (ictConnClosed, ictSuccessIo)
    )
  );
var
  pHandleData: PClientContext;
  pIoData: PIoBuffer;
  bResult: Boolean;
  lwTransfered: Longword;
  iError: Longword;
  iSocket: TSocket;
label
  __AcceptSequence, __AcceptConn, __DisconnectConn, __ConnClosed;
begin
  while True do
  begin
    pHandleData := nil;
    pIoData := nil;
    bResult := GetQueuedCompletionStatus(fCompletionPort, @lwTransfered,
      @pHandleData, POverlapped(pIoData), INFINITE);

    if pHandleData <> nil then iSocket := pHandleData^.Socket else iSocket := INVALID_SOCKET;

    case IoCompletionTable[bResult, pIoData <> nil, lwTransfered <> 0] of
      ictSuccessIo:
      begin
        { A successful IO operation has ended }
        case pIoData^.IoType of
          ioInput: ProcessInputRequest(pHandleData, pIoData, lwTransfered);
          ioOutput: ProcessOutputRequest(pHandleData, pIoData, lwTransfered);
          { Invalid operation - should not occur }
          ioAccept, ioInvalid: ReleaseIoBuffer(pIoData);
        end;
      end;
      ictConnClosed:
      begin
        __ConnClosed:
        { Client has gracefully disconnected or the server has disconnected the client }
        DoOnClose(pHandleData^.Instance);

        fLock.Enter;
        try
          fAcceptedSockets.Remove(iSocket);
          AtomicDec(@fClientCount);
        finally
          fLock.Leave;
        end;

        DisconnectClient(pHandleData);
        ReleaseClientContext(pHandleData);
        ReleaseIoBuffer(pIoData);
      end;
      ictQuit: Break;
      ictFailedIo:
      begin
        { Socket error occured }
        iError := GetLastError;
        if iError <> ERROR_OPERATION_ABORTED then
        begin
          { This is the most common error and it spams the console. It indicates
            that either the server hasn't closed the socket gracefully or the
            client. It results in socket reuse. }
          if iError <> ERROR_NETNAME_DELETED then
          begin
            { Call the OnError handler }
            DoOnError(Format(RsIoExceptionMessage, [LoadResString(@RsIoFailed),
              SysErrorMessage(iError)]));
          end;
          goto __ConnClosed;
          { Just close the connection, since failed IO means the connection has been forcibly closed }
        end;
        ReleaseIoBuffer(pIoData);
      end;
      ictNoDequeue:
      begin
        { Nothing to dequeue - an internal error has occured }
        { Call the OnError handler }
        DoOnError(Format(RsIoExceptionMessage, [LoadResString(@RsIoNoDequeue),
          SysErrorMessage(GetLastError)]));
      end;
      ictIllegal:
      begin
        { One should never reach this point }
        { Call the OnError handler }
        DoOnError(Format(RsIoExceptionMessage, [LoadResString(@RsIoInvalidOp),
          SysErrorMessage(GetLastError)]));
        Continue;
        { But just in case this happens - skip to another loop }
      end;
    end;
  end;
end;

procedure TSocketServer.ProcessInputRequest(Handle: PClientContext;
  Io: PIoBuffer; Transfered: UInt32);
begin
  AtomicExchange(@Handle^.IsIdle, Longword(False));
  AtomicExchange(@Handle^.CheckTime, TimeGetTime);
  { We received some data - call the OnRead handler }

  DoOnRead(Handle^.Instance, Io^.IoBuf^, Transfered);

  ReleaseIoBuffer(Io);
  IssueRead(Handle^.Socket);
end;

procedure TSocketServer.ProcessOutputRequest(Handle: PClientContext;
  Io: PIoBuffer; Transfered: UInt32);
begin
  { We sent some data - call the OnSend handler }
  DoOnWrite(Handle^.Instance, Transfered);
  ReleaseIoBuffer(Io);
end;

{ YSocketServer }

procedure TSocketServer.DoOnAccept(Socket: TRawClientSocket);
begin
  if Assigned(fOnAccept) then fOnAccept(Self, Socket);
end;

procedure TSocketServer.DoOnClose(Socket: TRawClientSocket);
begin
  if Assigned(fOnClose) then fOnClose(Self, Socket);
end;

procedure TSocketServer.DoOnError(const sErrorMsg: string);
begin
  if Assigned(fOnError) then fOnError(Self, sErrorMsg);
end;

procedure TSocketServer.DoOnRead(Socket: TRawClientSocket;
  const Data; Size: Integer);
begin
  if Assigned(fOnRead) then fOnRead(Self, Socket, @Data, Size);
end;

procedure TSocketServer.DoOnWrite(Socket: TRawClientSocket;
  Size: Integer);
begin
  if Assigned(fOnWrite) then fOnWrite(Self, Socket, Size);
end;

procedure TSocketServer.AddToPermanentBanList(IP: Longword);
var
  pIpData: PIpStatusRec;
begin
  fListLock.Enter;
  try
    fPermanentlyBanned.Add(IP);
    pIpData := fIpList.GetValue(IP);
    if pIpData = nil then
    begin
      New(pIpData);
      fIpList.PutValue(IP, pIpData);
    end;
    pIpData^.LogInAttempts := MAX_LOGIN_COUNT;
    pIpData^.Banned := True;
  finally
    fListLock.Leave;
  end;
end;

procedure TSocketServer.Start(Port: Word);
var
  iInt: Int32;
begin
  fPort := Port;
  fListenerAddress.sin_port := HToNS(Port);

  if bind(fListener, @fListenerAddress, SizeOf(fListenerAddress)) <> 0 then
  begin
    raise ESocketError.Create(WSAErrorMessage(WSAGetLastError));
  end;

  if listen(fListener, SOMAXCONN) <> 0 then
  begin
    raise ESocketError.Create(WSAErrorMessage(WSAGetLastError));
  end;

  for iInt := 0 to Length(fThreads) -1 do
  begin
    fThreads[iInt].Resume;
    { Resume the threads }
  end;

  fTimeoutCheckThread.Resume;

  fTimer := SysEventMgr.RegisterEvent(ClearBannedAndIpLists, BANNED_CLEAR_PERIOD,
    TICK_EXECUTE_INFINITE, 'SocketServer_MainTimer');
end;

procedure TSocketServer.DisconnectAll;
var
  ifItr: IPtrIterator;
begin
  fLock.Enter;
  try
    ifItr := fAcceptedSockets.Values;
    while ifItr.HasNext do
    begin
      DisconnectClient(PClientContext(ifItr.Next));
    end;
  finally
    fLock.Leave;
  end;
end;

procedure TSocketServer.DisconnectClient(Context: PClientContext;
  FreeInstance: Boolean);
begin
  if Context <> nil then
  begin
    if FreeInstance then Context^.Instance.Free;
    Shutdown(Context^.Socket, SD_SEND);
    CancelIo(Context^.Socket);
    CloseSocket(Context^.Socket);
  end;
end;

function TSocketServer.ConstructSocket(Socket: Integer; Address: PSockAddr): TRawClientSocket;
begin
  Result := TRawClientSocket.Create(Socket, Address);
end;

procedure TSocketServer.SendData(Socket: TRawClientSocket; const Data; Size: Integer);
begin
  IssueWrite(Socket.SocketHandle, Data, Size);
  { Just issue a write request }
end;

function TSocketServer.GetThreadCount: Integer;
begin
  Result := fThreadCount;
end;

function TSocketServer.GetClientCount: Integer;
begin
  Result := fClientCount;
end;

end.
