{*------------------------------------------------------------------------------
  Sockets Implementation.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.IoCore.Sockets;

interface

uses
  API.Win.Winsock2,
  Framework.SocketBase,
  Framework.Base;

type
  YIoSocketServer = class;

  YIoClientSocketClass = class of YIoClientSocket;
  YIoClientSocket = class(TRawClientSocket)
    private
      fOwner: YIoSocketServer;
    protected
      procedure Initialize; virtual;
    public
      constructor Create(cOwner: YIoSocketServer; iSocket: TSocket; pAddress: PSockAddr);

      property Owner: YIoSocketServer read fOwner;
  end;

  YIoSocketServer = class(TSocketServer)
    protected
      class function GetSocketClass: YIoClientSocketClass; virtual;
      function ConstructSocket(iSocket: Integer; pAddress: PSockAddr): TRawClientSocket; override; final;

      procedure OnErrorInternal(cSender: TSocketServer; const sErrorMsg: string);
    public
      procedure AfterConstruction; override;
  end;

implementation

uses
  Cores,
  Components.IoCore.Console,
  SysUtils,
  Framework;

{ YClientSocket }

constructor YIoClientSocket.Create(cOwner: YIoSocketServer; iSocket: TSocket; pAddress: PSockAddr);
begin
  inherited Create(iSocket, pAddress);
  fOwner := cOwner;
  Initialize;
end;

procedure YIoClientSocket.Initialize;
begin
  { Do nothing }
end;

{ YBaseSocketServer }

procedure YIoSocketServer.AfterConstruction;
begin
  OnSocketError := OnErrorInternal;
end;

function YIoSocketServer.ConstructSocket(iSocket: Integer; pAddress: PSockAddr): TRawClientSocket;
begin
  Result := GetSocketClass.Create(Self, iSocket, pAddress);
end;

class function YIoSocketServer.GetSocketClass: YIoClientSocketClass;
begin
  Result := YIoClientSocket;
end;

procedure YIoSocketServer.OnErrorInternal(cSender: TSocketServer; const sErrorMsg: string);
begin
  IoCore.Console.Writeln(sErrorMsg, CLR_ERR);
end;

end.
