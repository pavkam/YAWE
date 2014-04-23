{*------------------------------------------------------------------------------
  ExtensionCore.
  The heart of the YES extension engine.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
  @Docs TheSelby
-------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.ExtensionCore;

interface

{$REGION 'Uses Clause'}
uses
  Framework.Base,
  Components,
  Components.ExtensionCore.Yes,
  Components.ExtensionCore.Interfaces,
  Misc.PluginSystem,
  Misc.Containers,
  Misc.Miscleanous,
  SysUtils;
{$ENDREGION}

type
  {*------------------------------------------------------------------------------
  Main ExtensionCore class
  -------------------------------------------------------------------------------}
  YExtensionCore = class(YBaseCore)
    private
      {$REGION 'Private members'}

      fYesLib: YExYesManager;   /// YES manager

      procedure OnPluginLoad(Sender: TPluginManager; const PackageName: string);
      procedure OnPluginUnload(Sender: TPluginManager; const PackageName: string);
      {$ENDREGION}
    protected
      {$REGION 'Protected members'}
      procedure CoreInitialize; override;
      procedure CoreStart; override;
      procedure CoreStop; override;
      {$ENDREGION}
    public
      {$REGION 'Public members'}
      {*------------------------------------------------------------------------------
        Provides direct library access (read only)
        @see YExYesManager
      -------------------------------------------------------------------------------}
      property Manager: YExYesManager read fYesLib;
      {$ENDREGION}
  end;

implementation

{$REGION 'Uses Clause'}
  uses
    Components.DataCore.Fields,
    Framework,
    Components.DataCore.Types,
    Cores;
{$ENDREGION}

{$REGION 'YExtensionCore Methods'}
  {*------------------------------------------------------------------------------
    Initializes the extension core
  -------------------------------------------------------------------------------}
  procedure YExtensionCore.CoreInitialize;
  begin
    fYesLib := YExYesManager.Create;
    /// Loading Scripting & Extensions
    IoCore.Console.WriteLoadOf('Scripting & Extensions');
    IoCore.Console.NewLine;
    fYesLib.OnPackageLoad := OnPluginLoad;
    fYesLib.OnPackageUnload := OnPluginUnload;
  
    ///Loads all scripts & extensions found in "YesPluginDir"
    fYesLib.LoadPluginPackages(FileNameToOS(SystemConfiguration.StringValue['Data', 'YesPluginDir']),
      ['*.bpl', '*.dll']);
  
    ///In the case that there are no plugins installed nothing bad happens, but the
    ///user is notified that he has no extension plugins!
    if fYesLib.GetNumberOfPluginPackages = 0 then
    begin
      IoCore.Console.Write(' > ');
      IoCore.Console.WriteFailureWithData('No plugins found');
    end;
  end;
  
  {*------------------------------------------------------------------------------
    Executes when a plugin module is loaded
  
    @param Sender The actual sender (TPluginManager)
    @param PackageName contains the name of the package
    @see TPluginManager
  -------------------------------------------------------------------------------}
  procedure YExtensionCore.OnPluginLoad(Sender: TPluginManager;
    const PackageName: string);
  begin
    ///writes in console the name of the package that was loaded
    IoCore.Console.WritePluginPackageLoad(PackageName);
  end;
  
  {*------------------------------------------------------------------------------
    Executes when a plugin is unloaded
  
    @param Sender The actual sender (TPluginManager)
    @param PackageName contains the name of the package
    @see TPluginManager
  -------------------------------------------------------------------------------}
  procedure YExtensionCore.OnPluginUnload(Sender: TPluginManager;
    const PackageName: string);
  begin
    ///writes in console the name of the package that was unloaded
    IoCore.Console.WritePluginPackageUnload(PackageName);
  end;
  
  {*------------------------------------------------------------------------------
    Starts the ExtensionCore
  -------------------------------------------------------------------------------}
  procedure YExtensionCore.CoreStart;
  begin
    fYesLib.Start;
  end;
  
  {*------------------------------------------------------------------------------
    Stops the ExtensionCore
  -------------------------------------------------------------------------------}
  procedure YExtensionCore.CoreStop;
  begin
    ///stops the extension library
    fYesLib.Stop;
    ///unloads all loaded packages
    fYesLib.UnloadAllPluginPackages;
    fYesLib.Free;
  end;
{$ENDREGION}

end.
