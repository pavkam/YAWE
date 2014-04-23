{*------------------------------------------------------------------------------
  DynamicObject Implementation
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}
                                          
{$I compiler.inc}
unit Components.GameCore.WowDynamicObject;
interface

uses
  Framework.Base,
  Components.GameCore.UpdateFields,
  Components.GameCore.WowMobile;

type
  YGaDynamicObject = class(YGaMobile)
    protected
      class function GetObjectType: Int32; override;
      class function GetOpenObjectType: YWowObjectType; override;
  end;

implementation

{ YOpenDynamicObject }

class function YGaDynamicObject.GetObjectType: Int32;
begin
  Result := UPDATEFLAG_DYNAMICOBJECT;
end;

class function YGaDynamicObject.GetOpenObjectType: YWowObjectType;
begin
  Result := otDynamicObject;
end;

end.
