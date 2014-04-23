{*------------------------------------------------------------------------------           
  Framework Objects Collection
  
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
unit Framework;

interface

uses
  Framework.Configuration,
  Framework.ErrorHandler,
  Framework.Tick,
  Framework.OptimizationManager,
  Framework.ThreadManager,
  Framework.LogManager;

{$G-}

var
  SysDbg: TExceptionWatcher;
  SysConf: IConfiguration2;
  SysEventMgr: TTickGenerator;
  SysOptimizer: TOptimizationManager;
  SysThreadMgr: TThreadManager;
  SysLogger: TLogManager;

implementation

end.
