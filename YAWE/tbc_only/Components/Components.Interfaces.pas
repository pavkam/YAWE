{*------------------------------------------------------------------------------
  Transmission Interfaces
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author Seth
  @Changes PavkaM
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.Interfaces;

interface

uses
  Framework.Base,
  Components.NetworkCore.Packet,
  Components.DataCore.Types;

type
  ISocketInterface = interface(IInterface)
  ['{99AAFA99-993A-4D9D-B1BF-CCA5E84CCC9D}']
    procedure SessionSendPacket(cPkt: YNwServerPacket);
    procedure SessionSetAuthKey(const aHash: YAccountHash);
    procedure SessionSetQueuePosition(iTo: Int32);
    function SessionGetQueuePosition: Int32;
    procedure SessionDisconnect;
    procedure SessionForceFlushBuffers;
    procedure UpdateQueuePosition(iPos: Int32);
    procedure QueueLockAcquire;
    procedure QueueLockRelease;
  end;

  { Object's Timer Interface }
  ITimerInterface = interface(IInterface)
  ['{3E32BB23-A7D7-49D9-A167-60764336487B}']
    procedure TimerEventReached(iSender, iOpt: Int32; cTmrObj: TObject);
  end;

  { Session Interface }
  ISessionInterface = interface(IInterface)
  ['{E628D8B7-23B9-4167-AFE3-D6961B991832}']
    procedure BufferLockAcquire;
    procedure BufferLockRelease;
    procedure SendPacket(Pkt: YNwServerPacket);
    function GetAccount: WideString;

    property Account: WideString read GetAccount;
  end;

implementation

end.
