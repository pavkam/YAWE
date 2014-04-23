{*------------------------------------------------------------------------------
  Public YAWE Extension Library
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

library ucl32;

{$R *.res}

uses
  Ucl.Export in 'Ucl.Export.pas',
  Ucl.Core in 'Import\Ucl.Core.pas';

exports
  UclInit,
  UclInitEx,
  UclCompressBuf,
  UclCompressBuf2,
  UclCompressBufEx,
  UclCompressBufEx2,
  UclDecompressBuf,
  UclDecompressBuf2,
  UclCompressStr,
  UclCompressStrEx,
  UclDecompressStr,
  UclGetCompressionBufferOverhead,
  UclGetLastError,
  UclSetLastError,
  UclFormatUclError,
  UclGetVersion,
  UclGetVersionString,
  UclGetBuildDate;

begin
end.
