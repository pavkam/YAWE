{*------------------------------------------------------------------------------
  Wdx Interface
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Wdx.LibInterface;

{$WEAKPACKAGEUNIT}

interface

const
  WDX_E_OK = 0;
  WDX_E_UNIMPL = -1;
  WDX_E_ERROR = 1;
  WDX_E_INVALID_ARGS = 2;
  WDX_E_MPQ_ERROR = 3;

type
  TTerrainType = (ttWater, ttLand);

  TAdtExtractionOption = (aeoCompressed);
  TAdtExtractionOptions = set of TAdtExtractionOption;

  TWdxNotificationType = (wntMapCount, wntNewMap, wntNewTile);
  TProgressCallback = procedure(Context: Pointer; Data: Pointer; NotificationType: TWdxNotificationType);

  PAdtMapData = ^TAdtMapData;
  TAdtMapData = record
    Id: Longword;
    Name: PChar;
  end;

  PAdtTileData = ^TAdtTileData;
  TAdtTileData = record
    X: Byte;
    Y: Byte;
    TerrainType: TTerrainType;
    MapName: PChar;
  end;


function WdxGetWoWDataPath(Buf: PChar; Size: PInteger): Integer; cdecl;

function WdxExtractAdtInfo(FileName: PChar; Source: PChar): Integer; cdecl;

function WdxExtractAdtInfoEx(const AFile: string; const ASource: string;
  AOptions: TAdtExtractionOptions; AProgressCallback: TProgressCallback;
  AProgressUserData: Pointer): Integer;

implementation

const
  WdxLib = 'wdx32.dll';

function WdxGetWoWDataPath; external WdxLib name 'WdxGetWoWDataPath';
function WdxExtractAdtInfo; external WdxLib name 'WdxExtractAdtInfo';
function WdxExtractAdtInfoEx; external WdxLib name 'WdxExtractAdtInfoEx';

end.
