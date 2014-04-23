{*------------------------------------------------------------------------------
  IPC Pipes and Communication
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}
unit Framework.IpcBase;

interface

uses
  API.Win.Types,
  API.Win.NtCommon,
  API.Win.Kernel,
  Framework.Base,
  Framework.ThreadManager,
  SysUtils,
  Misc.Containers,
  Misc.Miscleanous,
  Misc.Threads;

const
  PIPE_BUF_SIZE  = 8192;
  PIPE_TIMEOUT   = 1000;

type
  TIpcServer = class;
  TIpcClient = class;

  {$Z4}
  TPipeOperation = (poRead, poWrite);
  {$Z1}

  PPerPipeData = ^TPerPipeData;
  TPerPipeData = record
    Ov: TOverlapped;
    Server: TIpcServer;
    Pipe: THandle;
    Buffer: array[0..PIPE_BUF_SIZE-1] of Byte;
    case Operation: TPipeOperation of
      poRead: (
        ReadSize: UInt32;
      );
      poWrite: (
        WriteSize: UInt32;
      );
  end;

  TIpcErrorEvent = procedure(Sender: TIpcServer; Client: Int32; Error: UInt32) of object;
  TIpcDisconnectEvent = procedure(Sender: TIpcServer; Client: Int32) of object;
  TIpcConnectEvent = procedure(Sender: TIpcServer; Client: Int32) of object;
  TIpcSendEvent = procedure(Sender: TIpcServer; Client: Int32; const Data; Size: Int32) of object;
  TIpcRecvEvent = procedure(Sender: TIpcServer; Client: Int32; Size: Int32) of object;

  TIpcServer = class(TBaseInterfacedObject)
    private
      fConnectEvent: THandle;
      fThread: TThreadHandle;
      fPipes: TIntPtrHashMap;
      fLock: TCriticalSection;
      fName: string;

      fOnError: TIpcErrorEvent;
      fOnConnect: TIpcConnectEvent;
      fOnDisconnect: TIpcDisconnectEvent;
      fOnRecv: TIpcRecvEvent;
      fOnSend: TIpcSendEvent;

      function CreatePipeAndAwaitConnection(var Ov: TOverlapped; out Pipe: THandle): Boolean;
      procedure IssuePipeRead(PipeData: PPerPipeData; Error: UInt32;
        BytesWritten: UInt32);
      procedure IssuePipeWrite(PipeData: PPerPipeData; Error: UInt32;
        BytesRead: UInt32);

      procedure DisconnectPipe(PipeData: PPerPipeData; Remove: Boolean = True);

      procedure ServePipeRequests(Thread: TThreadHandle);

      procedure DoOnConnect(Client: Int32);
      procedure DoOnDisconnect(Client: Int32);
      procedure DoOnError(Client: Int32; Error: UInt32);
      procedure DoOnRecv(Client: Int32);
      procedure DoOnSend(Client: Int32; Size: Int32);
    public
      constructor Create(const PipeName: string);
      destructor Destroy; override;

      procedure Start;

      property OnConnect: TIpcConnectEvent read fOnConnect write fOnConnect;
      property OnDisconnect: TIpcDisconnectEvent read fOnDisconnect write fOnDisconnect;
      property OnReceive: TIpcRecvEvent read fOnRecv write fOnRecv;
      property OnSend: TIpcSendEvent read fOnSend write fOnSend;
      property OnError: TIpcErrorEvent read fOnError write fOnError;
  end;

  TIpcClient = class(TBaseInterfacedObject)
    private
      fPipe: THandle;
      fThread: TThreadHandle;

      procedure InitiateComm(Thread: TThreadHandle);
    public
      constructor Create;
      destructor Destroy; override;
  end;

implementation

uses
  Framework;

procedure WriteCallback(Error, Transfered: UInt32; const Data: TPerPipeData); stdcall;
begin
  Data.Server.IssuePipeWrite(@Data, Error, Transfered);
end;

procedure ReadCallback(Error, Transfered: UInt32; const Data: TPerPipeData); stdcall;
begin
  Data.Server.IssuePipeRead(@Data, Error, Transfered);
end;

constructor TIpcServer.Create(const PipeName: string);
begin
  inherited Create;

  fLock.Init;
  fPipes := TIntPtrHashMap.Create(512);
  fName := PipeName;
  if Pos('\\.\pipe\', fName) <> 1 then fName := '\\.\pipe\' + fName;

  fConnectEvent := CreateEvent(nil, True, True, nil);

  fThread := SystemThreadManager.CreateThread(ServePipeRequests, True,
    'Ipc_Pipe_Server_Thread', True);
end;

destructor TIpcServer.Destroy;
var
  ifItr: IPtrIterator;
begin
  SetEvent(fConnectEvent);
  fThread.Terminate;
  fThread.WaitForEnd(-1);
  CloseHandle(fConnectEvent);

  ifItr := fPipes.Values;
  while ifItr.HasNext do
  begin
    DisconnectPipe(ifItr.Next, False);
  end;

  fPipes.Free;
  fLock.Delete;
  inherited Destroy;
end;

procedure TIpcServer.Start;
begin
  fThread.Resume;
end;

procedure TIpcServer.DisconnectPipe(PipeData: PPerPipeData; Remove: Boolean);
begin
  if Remove then
  begin
    fLock.Enter;
    try
      fPipes.Remove(PipeData.Pipe);
    finally
      fLock.Leave;
    end;
  end;

  DisconnectNamedPipe(PipeData^.Pipe);
  CloseHandle(PipeData^.Pipe);
  Dispose(PipeData);
end;

procedure TIpcServer.DoOnConnect(Client: Int32);
begin
  if Assigned(fOnConnect) then fOnConnect(Self, Client);
end;

procedure TIpcServer.DoOnDisconnect(Client: Int32);
begin
  if Assigned(fOnDisconnect) then fOnDisconnect(Self, Client);
end;

procedure TIpcServer.DoOnError(Client: Int32; Error: UInt32);
begin
  if Assigned(fOnError) then fOnError(Self, Client, Error);
end;

procedure TIpcServer.DoOnRecv(Client: Int32);
begin

end;

procedure TIpcServer.DoOnSend(Client, Size: Int32);
begin

end;

function TIpcServer.CreatePipeAndAwaitConnection(var Ov: TOverlapped; out Pipe: THandle): Boolean;
begin
  Pipe := CreateNamedPipe(PChar(fName), PIPE_ACCESS_DUPLEX or
    FILE_FLAG_OVERLAPPED, PIPE_READMODE_MESSAGE or PIPE_TYPE_MESSAGE or PIPE_WAIT,
    PIPE_UNLIMITED_INSTANCES, PIPE_BUF_SIZE, PIPE_BUF_SIZE, PIPE_TIMEOUT, nil);

  ConnectNamedPipe(Pipe, @Ov);
  case GetLastError of
    ERROR_IO_PENDING: Result := True;
    ERROR_PIPE_CONNECTED:
    begin
      Result := False;
      SetEvent(Ov.hEvent);
    end;
  else
    Result := False;
  end;
end;

procedure TIpcServer.IssuePipeRead(PipeData: PPerPipeData; Error,
  BytesWritten: UInt32);
var
  bDisc: Boolean;
begin
  if (Error = 0) and (PipeData^.WriteSize = BytesWritten) then
  begin
    bDisc := not ReadFileEx(PipeData^.Pipe, @PipeData^.Buffer[0], PIPE_BUF_SIZE,
      @PipeData^.Ov, @WriteCallback);
  end else bDisc := True;

  if bDisc then
  begin
    DisconnectPipe(PipeData);
  end;
end;

procedure TIpcServer.IssuePipeWrite(PipeData: PPerPipeData; Error,
  BytesRead: UInt32);
var
  bDisc: Boolean;
begin
  if (Error = 0) and (BytesRead > 0) then
  begin
    bDisc := not WriteFileEx(PipeData^.Pipe, @PipeData^.Buffer, PipeData^.WriteSize,
      @PipeData^.Ov, @ReadCallback);
  end else bDisc := True;

  if bDisc then
  begin
    DisconnectPipe(PipeData);
  end;
end;

procedure TIpcServer.ServePipeRequests(Thread: TThreadHandle);
var
  tOv: TOverlapped;
  iRes: UInt32;
  lwTransfered: UInt32;
  hPipe: THandle;
  pPipeData: PPerPipeData;
  bPendingIO: Boolean;
  bSuccess: Boolean;
begin
  FillChar(tOv, SizeOf(tOv), 0);
  lwTransfered := 0;
  tOv.hEvent := fConnectEvent;

  bPendingIO := CreatePipeAndAwaitConnection(tOv, hPipe);

  while not Thread.Terminated do
  begin
    iRes := WaitForSingleObjectEx(fConnectEvent, INFINITE, True);

    case iRes of
      WAIT_OBJECT_0:
      begin
        if bPendingIO then
        begin
          bSuccess := GetOverlappedResult(hPipe, @tOv, @lwTransfered, False);
          if not bSuccess then
          begin
            if GetLastError = ERROR_IO_INCOMPLETE then Continue; { Forced event signal }
            Writeln('Error');
          end;
        end;

        pPipeData := AllocMem(SizeOf(TPerPipeData));
        pPipeData^.Pipe := hPipe;
        pPipeData^.Server := Self;

        fLock.Enter;
        try
          fPipes.PutValue(hPipe, pPipeData);
        finally
          fLock.Leave;
        end;

        IssuePipeRead(pPipeData, 0, 0);
        bPendingIO := CreatePipeAndAwaitConnection(tOv, hPipe);
      end;
      WAIT_IO_COMPLETION: Continue;
    else
      Writeln('Error');
    end;
  end;
end;

{ YIoIpcClient }

constructor TIpcClient.Create;
begin
  inherited Create;
  fThread := SystemThreadManager.CreateThread(InitiateComm, False, 'Ipc_Client_Thread', False);
end;

destructor TIpcClient.Destroy;
begin
  fThread.Terminate;
  fThread.WaitForEnd(-1);
  inherited Destroy;
end;

procedure TIpcClient.InitiateComm(Thread: TThreadHandle);
var
  iMode: UInt32;
  tBuf: array[0..4095] of Byte;
  iRead: Int32;
label
  __Restart;
begin
  __Restart:
  while not Thread.Terminated do
  begin
    fPipe := CreateFile('\\.\pipe\Yawe_Ipc_Server', GENERIC_READ or GENERIC_WRITE,
      0, nil, OPEN_EXISTING, 0, 0);

    if fPipe <> INVALID_HANDLE_VALUE then Break;

    if GetLastError <> ERROR_PIPE_BUSY then Continue;

    WaitNamedPipe('\\.\pipe\YAWE_Ipc_Server', 10000);
  end;

  iMode := PIPE_READMODE_MESSAGE or PIPE_WAIT;
  SetNamedPipeHandleState(fPipe, @iMode, nil, nil);

  while not Thread.Terminated do
  begin
    if not ReadFile(fPipe, @tBuf, SizeOf(tBuf), @iRead, nil) then
    begin
      CloseHandle(fPipe);
      if GetLastError = ERROR_PIPE_NOT_CONNECTED then Break;
      goto __Restart;
    end;
  end;

  CloseHandle(fPipe);
end;

end.
