{*------------------------------------------------------------------------------           
  Framework Objects Collection
  
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
unit Framework;

interface

uses
  Framework.Configuration,
  Framework.ErrorHandler,
  Framework.Tick,
  Framework.TypeRegistry,
  Framework.SerializationRegistry,
  Framework.OptimizationManager,
  Framework.ThreadManager,
  Framework.LogManager;

var
  SystemDebugger: TExceptionWatcher;
  SystemConfiguration: TConfiguration;
  SystemTimer: TTickGenerator;
  SystemTypeRegistry: TTypeRegistry;
  SystemSerializationRegistry: TSerializationRegistry;
  SystemOptimizer: TOptimizationManager;
  SystemThreadManager: TThreadManager;
  SystemLogger: TLogManager;

implementation

end.
