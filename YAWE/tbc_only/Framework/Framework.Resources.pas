{*------------------------------------------------------------------------------
  Resources used by the framework.
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author Seth
  @Changes TheSelby, PavkaM
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Framework.Resources;

interface

resourcestring
  RsIoFailed                   = 'IO failed packet';
  RsIoNoDequeue                = 'IO could not dequeue a completion packet';
  RsIoInvalidOp                = 'IO illegal operation';
  RsNoTypeProcessingCallback   = 'No type processing callback was registered for %s, field %s.';
  RsOptimizerInvalidArgs = 'One of the args passed to the optimalizer routine was 0 or nil.';
  RsOptimizerCapabilitiesCollision = 'A function with the same or with a subset of the given required CPU capabilities has been already registered.';
  RsCreateIoCompletionPort     = 'CreateIoCompletionPort failed: %s';
  RsMissingExport              = 'Library %s misses export %s."';

implementation

end.
