{*------------------------------------------------------------------------------
  Types used in the Components.DataCore.WorldData namespace.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.DataCore.WorldData.Types;

interface

uses
  Misc.Miscleanous,
  Misc.Classes,
  Classes,
  Math;

const
  BlizzMapName              =   'World\Maps\%s\%s_%d_%d.adt';

  FILE_VER_MAJOR            =   1;
  FILE_VER_MINOR            =   0;
  FILE_VER_REVISION         =   1;
  FILE_VER_BUILD            =   3;
  FILE_VER_FULL             =   (FILE_VER_MAJOR) or (FILE_VER_MINOR shl 8) or (FILE_VER_REVISION shl 16) or (FILE_VER_BUILD shl 24);

  TILES_PER_MAP             =   64;
  CELLS_PER_TILE            =   16;
  VERTICES_PER_CELL         =   8;
  HEIGHT_RES                =   256;
  LIQUID_RES                =   CELLS_PER_TILE * VERTICES_PER_CELL;
  TILE_SIZE                 =   533.333;
  CELL_SIZE                 =   TILE_SIZE / CELLS_PER_TILE;
  UNIT_SIZE                 =   CELL_SIZE / VERTICES_PER_CELL;
  UNIT_SIZE_REC             =   1 / UNIT_SIZE;
  ZERO_POINT                =   32 * TILE_SIZE;
  NO_LIQUID                 =   NaN; { Not a number }
  HEIGHT_POINT_DISTANCE     =   TILE_SIZE / HEIGHT_RES;
  LIQUID_POINT_DISTANCE     =   TILE_SIZE / LIQUID_RES;

  NULL = $00000000; { Null chunk, invalid }
  // T-prefix stands for terrain-data file
  TVER = (Ord('T') shl 24) or (Ord('V') shl 16) or (Ord('E') shl 8) or Ord('R'); // Version info
  THDR = (Ord('T') shl 24) or (Ord('H') shl 16) or (Ord('D') shl 8) or Ord('R'); // Terrain file header
  TSTR = (Ord('T') shl 24) or (Ord('S') shl 16) or (Ord('T') shl 8) or Ord('R'); // String table
  TSTI = (Ord('T') shl 24) or (Ord('S') shl 16) or (Ord('T') shl 8) or Ord('I'); // String table indices
  TMHO = (Ord('T') shl 24) or (Ord('M') shl 16) or (Ord('H') shl 8) or Ord('O'); // Map header offsets
  TMAP = (Ord('T') shl 24) or (Ord('M') shl 16) or (Ord('A') shl 8) or Ord('P'); // Map header
  TMBM = (Ord('T') shl 24) or (Ord('M') shl 16) or (Ord('B') shl 8) or Ord('M'); // Map block mask
  TMBO = (Ord('T') shl 24) or (Ord('M') shl 16) or (Ord('B') shl 8) or Ord('O'); // Map block offsets
  TTIL = (Ord('T') shl 24) or (Ord('T') shl 16) or (Ord('I') shl 8) or Ord('L'); // Tile data
  TWMR = (Ord('T') shl 24) or (Ord('W') shl 16) or (Ord('M') shl 8) or Ord('R'); // WMO reference

const
  WDX_E_OK = 0;
  WDX_E_UNIMPL = -1;
  WDX_E_ERROR = 1;
  WDX_E_INVALID_ARGS = 2;
  WDX_E_MPQ_ERROR = 3;

type
  PVersionChunk = ^TVersionChunk;
  TVersionChunk = packed record
    Version: TVersion;
  end;

  PFileHeaderChunk = ^TFileHeaderChunk;
  TFileHeaderChunk = packed record
    GlobalFlags: Longword;
    NumberOfStrings: Longword;
    OffsetOfStrings: Longword;
    NumberOfStringIndices: Longword;
    OffsetOfStringIndices: Longword;
    NumberOfMaps: Longword;
    Reserved: array[0..7] of Longword;
  end;

  TMapFlag = (mfTerrain, mfWmoOnly);
  TMapFlags = set of TMapFlag;

  PMapHeaderChunk = ^TMapHeaderChunk;
  TMapHeaderChunk = packed record
    MapId: Longword;
    Flags: TMapFlags;
    {$IF SizeOf(TMapFlags) < 4}
    Fill: array[0..3 - SizeOf(TMapFlags)] of Byte;
    {$IFEND}
    NameIndex: Longword;
    NumOfBlocks: Longword;
    Borders: TRect;
  end;

  PBlockMaskChunk = ^TBlockMaskChunk;
  TBlockMaskChunk = packed record
    BlockMask: array[0..(TILES_PER_MAP * TILES_PER_MAP div 8)-1] of Byte;
  end;

  PBlockOffsetsChunk = ^TBlockOffsetsChunk;
  TBlockOffsetsChunk = packed record
    BlockOffsets: array[0..TILES_PER_MAP-1, 0..TILES_PER_MAP-1] of Longword;
  end;

  PMapEntryInfo = ^TMapEntryInfo;
  TMapEntryInfo = packed record
    Id: Longword;
    Offset: Longword;
  end;

  TMapCellFlag = (mcfShadowMap, mcfImpassable, mcfRiver, mcfOcean, mcfLava);
  TMapCellFlags = set of TMapCellFlag;

  PTileChunk = ^TTileChunk;
  TTileChunk = packed record
    Flags: Longword;
    X: Longword;
    Y: Longword;
    Borders: TRect;
    HeightData: array[0..HEIGHT_RES-1, 0..HEIGHT_RES-1] of Single;
    LiquidData: array[0..LIQUID_RES-1, 0..LIQUID_RES-1] of Single;
    AreaIds: array[0..CELLS_PER_TILE-1, 0..CELLS_PER_TILE-1] of Longword;
    ZoneIds: array[0..CELLS_PER_TILE-1, 0..CELLS_PER_TILE-1] of Longword;
    AreaFlags: array[0..CELLS_PER_TILE-1, 0..CELLS_PER_TILE-1] of Word;
    ZoneLevels: array[0..CELLS_PER_TILE-1, 0..CELLS_PER_TILE-1] of Byte;
    CellFlags: array[0..CELLS_PER_TILE-1, 0..CELLS_PER_TILE-1] of TMapCellFlags;
  end;

  PCompressedTileChunk = ^TCompressedTileChunk;
  TCompressedTileChunk = packed record
    Flags: Longword;
    X: Longword;
    Y: Longword;
    TileData: array[0..SizeOf(TTileChunk)-SizeOf(TChunkInfo)+((SizeOf(TTileChunk)-SizeOf(TChunkInfo)) div 8)+256-1] of Byte;
    { Formula for worst-case UCL compression size, see Ucl.Core.pas, function ucl_output_block_size
      MaxSize is 369762 Bytes
    }
  end;

implementation

end.
