{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Resources used by the misc package.
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
  @Changes TheSelby, PavkaM
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Bfg.Resources;

interface

const
  EOL = #13#10;

resourcestring
  { Miscleaneous namespace }
  RsStreamInvalidOperation  = 'Tried to perform an invalid stream operation.';
  RsStreamCannotObtainFileHandle = 'Unable to obtain file handle. Reason: %s.';
  RsStreamCannotCreateFileMapping = 'Unable to create file mapping object. Reason: %s.';
  RsStreamCannotFindResource = 'Unable to find resource named "%s".';
  RsStreamCannotViewMapOfFile = 'Unable to view map if file. Reason: %s.';
  RsNilArgument = 'One or more arguments is nil.';
  RsNilArgumentEx = 'Argument %s is nil.';
  
  RsWSAExceptionMessage        = '<WSA> WSA function %s failed - %s';
  RsIoExceptionMessage         = '<IO> IO operation %s failed - %s';
  RsGenExceptionMessage        = '<ERR> %s failed - %s';
  RsWSASocket                  = 'WSASocket';
  RsWSARecv                    = 'WSARecv';
  RsWSASend                    = 'WSASend';
  RsAcceptEx                   = 'AcceptEx';
  RsGetAcceptExSockAddrs       = 'GetAcceptExSockAddrs';
  RsOutOfBounds                = 'Tried to access a list item which is out of bounds. (Index %d)';

implementation
{$IFDEF PROFILE}USES Profint;{$ENDIF}

end.
