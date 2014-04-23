{*------------------------------------------------------------------------------
  IO Core Definition
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.IoCore;

interface

uses
  Framework.Base,
  Framework.ThreadManager,
  Framework.Tick,
  Framework.IpcBase,
  SysUtils,
  Components.IoCore.Console,
  Components.IoCore.ErrorManager,
  Components;

type
  YIoCore = class(YBaseCore)
    private
      fConsole: YIoConsole;
      fErrorMgr: YIoErrorManager;

      procedure ReportEventRegister(Sender: TTickGenerator; Event: TEventHandle);
      procedure ReportEventUnregister(Sender: TTickGenerator; Event: TEventHandle);
      procedure ReportEventError(Sender: TTickGenerator; Event: TEventHandle; ExcObject: Exception);

      procedure ReportThreadError(Sender: TThreadManager; Thread: TThreadHandle; ExcObject: Exception);
    protected
      procedure CoreInitialize; override;
      procedure CoreStart; override;
      procedure CoreStop; override;
    public
      constructor Create;
      destructor Destroy; override;

      property Console: YIoConsole read fConsole;
  end;

implementation

uses
  Framework;

{ YIoCore }

constructor YIoCore.Create;
begin
  inherited Create;
  fConsole := YIoConsole.Create;
  fErrorMgr := YIoErrorManager.Create('Errors/');
  SystemTimer.OnEventRegister := ReportEventRegister;
  SystemTimer.OnEventUnregister := ReportEventUnregister;
  SystemTimer.OnEventException := ReportEventError;

  SystemThreadManager.OnThreadException := ReportThreadError;
end;

destructor YIoCore.Destroy;
begin
  fErrorMgr.Free;
  fConsole.Free;
  inherited Destroy;
end;

procedure YIoCore.ReportEventError(Sender: TTickGenerator; Event: TEventHandle;
  ExcObject: Exception);
begin
  fConsole.Writeln(Format(' <TIMER>: Exception occured while executing event %s!', [Event.Name]), Red);
end;

procedure YIoCore.ReportEventRegister(Sender: TTickGenerator;
  Event: TEventHandle);
begin
  fConsole.WriteTickRegister(Event);
end;

procedure YIoCore.ReportEventUnregister(Sender: TTickGenerator;
  Event: TEventHandle);
begin
  fConsole.WriteTickUnregister(Event);
end;

procedure YIoCore.ReportThreadError(Sender: TThreadManager;
  Thread: TThreadHandle; ExcObject: Exception);
begin
  fConsole.Writeln(Format(' <THREADMGR>: Thread exception in thread %s!', [Thread.Name]), LightRed);
end;

procedure YIoCore.CoreInitialize;
begin

end;

procedure YIoCore.CoreStart;
begin

end;

procedure YIoCore.CoreStop;
begin

end;

end.
