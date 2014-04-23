{*------------------------------------------------------------------------------
  Shared Include File
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth, TheSelby
------------------------------------------------------------------------------}

{ Define our internal compile defs }
{$DEFINE EXPERIMENTAL}
{$DEFINE ASM_OPTIMIZATIONS}
{$DEFINE DEBUG_BUILD}
{$DEFINE DEBUG_SPLINE_MOVEMENT}

{ Enable Inlining of functions }
{$INLINE ON}

{ Win32 specific defines }
{$IFDEF MSWINDOWS}
  {.$SETPEFLAGS IMAGE_FILE_LARGE_ADDRESS_AWARE}
{$ENDIF}

{ If debug build defined, enable all sorts of options }
{$IFDEF DEBUG_BUILD}
  {$D+}
  {$I+}
  {$Y+}
  {$L+}
  {$DEFINE DEBUG_SPLINE_MOVEMENT}
{$ELSE}
  {$D-}
  {$I-}
  {$Y-}
  {$L-}
{$ENDIF}
