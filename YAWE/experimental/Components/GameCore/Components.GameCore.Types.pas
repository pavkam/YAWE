{*------------------------------------------------------------------------------
  Types to be used all over the GameCore (possibly ExtensionCore).

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
unit Components.GameCore.Types;

interface

uses
  Misc.Miscleanous,
  Framework.System.Base;

type
  PObjectGuid = ^YObjectGuid;
  YObjectGuid = type TQuadwordRec;
  
  PPositionVector = ^YPositionVector;
  YPositionVector = packed record
    case Boolean of
      True: (Data: array[0..15] of UInt8);
      False: (X, Y, Z, Angle: Float);
  end;

  PZoneData = ^YZoneData;
  YZoneData = packed record
    case Boolean of
      True: (Data: array[0..7] of UInt8);
      False: (MapId, Zone: UInt32);
  end;

  PSpeedData = ^YSpeedData;
  YSpeedData = packed record
    case Boolean of
      True: (Data: array[0..23] of UInt8);
      False: (WalkSpeed, RunSpeed, BackSwimSpeed,
              SwimSpeed, BackWalkSpeed, TurnRate: Float);
  end;

  PWorldPosition = ^YWorldPosition;
  YWorldPosition = record
    Vector: YPositionVector;
    Location: YZoneData;
  end;

  PMovementData = ^YMovementData;
  YMovementData = record
    Position: YWorldPosition;
    Speed: YSpeedData;
  end;

  ColorCode = type PChar;

implementation

end.
