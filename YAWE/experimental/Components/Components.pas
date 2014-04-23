{*--------------------------------------------------------------------
  Wraper to YAWE cores
  Containing YBaseCore class that will be the parent for all other cores

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth
  @Docs PavkaM, TheSelby
--------------------------------------------------------------------}

{$I compiler.inc}
unit Components;

interface

{$REGION 'Uses Clause'}
  uses
    Framework.Base;
{$ENDREGION}

type
  {*------------------------------------------------------------------------------
  YBaseCore - The base class to be used in declaring Core Classes
  Contains basic methods for initialization, start and stop
  
  @see YInterfacedObject
  @see Cores
  -------------------------------------------------------------------------------}
  YBaseCore = class(TBaseInterfacedObject)
    protected
      {$REGION 'Private members'}
      procedure CoreInitialize; virtual; abstract;  ///Abstract/Vurtual CoreInitialize. Implemented by children classes
      procedure CoreStart; virtual; abstract;       ///Abstract/Vurtual CoreStart. Implemented by children classes
      procedure CoreStop; virtual; abstract;        ///Abstract/Vurtual CoreStop. Implemented by children classes
      {$ENDREGION}
    public
      {$REGION 'Public members'}
      procedure Initialize;  ///YBaseCore - Initialize
      procedure Start;       ///YBaseCore - Start
      procedure Stop;        ///YBaseCOre - Stop
      {$ENDREGION}
    end;

implementation

{$REGION 'Uses Clause'}
  uses Framework;
{$ENDREGION}

{$REGION 'YBaseCore Methods'}
  procedure YBaseCore.Initialize;
  begin
    CoreInitialize;
  end;
  
  procedure YBaseCore.Start;
  begin
    CoreStart;
  end;
  
  procedure YBaseCore.Stop;
  begin
    CoreStop;
  end;
{$ENDREGION}

end.
