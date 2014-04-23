{*------------------------------------------------------------------------------
  Realm Object.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Components.NetworkCore.Realm;

interface

uses
  Framework.Base,
  Version,
  Bfg.Containers,
  SysUtils,
  Components;

type
  { Realm Types }
  YRealmType = (rtPvP, rtRP, rtRPPvP, rtPvE);

  { Base Realm Type
    Will derive into InternalRealm or other
    types we can use.
  }
  YNwBaseRealm = class(TInterfacedObject)
    private
      fRealmType: YRealmType;
      fMaxPopulation: Int32;
      fTimeZone: UInt8;
      fServer: string;
      fPort: Int32;
      fName: string;
      function GetRAddr: string;
      function GetRColor: UInt8;
      function GetRIcon: UInt32;
      function GetRName: string;
      function GetRPpl: Float;
      function GetRZone: UInt8;
      function GetRChars(const Index: String): UInt8;
    protected
      function GetRealmPopulation: Int32; virtual; abstract;
      function GetRealmChars(const sAccName: string): Int32; virtual; abstract;
    public
      property RealmIcon: UInt32 read GetRIcon;
      property RealmColor: UInt8 read GetRColor;
      property RealmPpl: Float read GetRPpl;
      property RealmChars[const Index: string]: UInt8  read GetRChars;
      property RealmTZone: UInt8 read GetRZone;
      property RealmName: string read GetRName;
      property RealmAddr: string read GetRAddr;
    end;

  { Internal realm gets initialized upon
    creation.
  }
  YNwInternalRealm = class(YNwBaseRealm)
    protected
      function GetRealmPopulation: Int32; override;
      function GetRealmChars(const sAccName: string): Int32; override;
    public
      constructor Create;
    end;

  { The Realm List Object }
  YNwRealmList = class(TObject)
    private
      fList: TPtrArrayList;
      function GetRealmCount: Int32;
      function GetRealmObject(Index: Int32): YNwBaseRealm;
    public
      constructor Create; 
      destructor Destroy; override;
      procedure Clear;
      procedure Add(cRealm: YNwBaseRealm);
      property Realms[Index: Int32]: YNwBaseRealm read GetRealmObject;
      property Count: Int32 read GetRealmCount;
    end;

implementation

uses
  Framework,
  Cores,
  TypInfo,
  Bfg.TypInfoEx,
  Bfg.Resources,
  Bfg.Utils;

{ YBaseRealm }

function YNwBaseRealm.GetRAddr: string;
begin
  Result := fServer + ':' + itoa(fPort);
end;


function YNwBaseRealm.GetRChars(const Index: string): UInt8;
begin
  Result := GetRealmChars(Index);
end;

function YNwBaseRealm.GetRColor: UInt8;
var
  iPop: Int32;
  fDivf: Single;
begin
  iPop := GetRealmPopulation;

  if iPop = -1 then
  begin
    Result := 2; { Realm Offline }
    Exit;
  end;

  fDivf := iPop;
  fDivf := (fDivf / fMaxPopulation);

  if (fDivf < 0.4) then
  begin
    Result := 0; { Low Population }
    Exit;
  end;

  Result := 1; { High/Medium Population }
end;

function YNwBaseRealm.GetRIcon: UInt32;
begin
  case fRealmType of
    rtPvP    : Result := 1; { PvP }
    rtRP     : Result := 6; { RP }
    rtRPPvP  : Result := 8; { RPPvP }
    rtPvE    : Result := 0; { Normal }
  else
    Result := 0;
  end;
end;

function YNwBaseRealm.GetRName: string;
begin
  Result := fName;
end;

function YNwBaseRealm.GetRPpl: Float;
var
  iPop: Int32;
  fDivf: Single;
begin
  iPop := GetRealmPopulation;

  if iPop = -1 then
  begin
    Result := 0.1; { Realm Offline, Low Population }
    Exit;
  end;

  fDivf := iPop;
  fDivf := (fDivf / fMaxPopulation);

  if (fDivf < 0.3) then
  begin
    Result := 0.5; { Low Population }
    Exit;
  end;

  if (fDivf < 0.7) then
  begin
    Result := 1.0; { Medium Population }
    Exit;
  end;

  Result := 1.5; { High Population }
end;

function YNwBaseRealm.GetRZone: UInt8;
begin
  Result := fTimeZone;
end;

{ YInternalRealm }

function YNwInternalRealm.GetRealmChars(const sAccName: String): Int32;
begin
  Result := 0;
  //Result := DataCore.Player.CountEntries(FIELD_ACC_NAME, sAccName);
end;

function YNwInternalRealm.GetRealmPopulation: Int32;
begin
  Result := NetworkCore.RealmThreads;
  { Internal World-Server }
end;

constructor YNwInternalRealm.Create;
  function ConvertRealmTypeToEnum(const sRType: string): YRealmType; inline;
  const
    Prefix = 'rt';
  begin
    Result := YRealmType(GetEnumValue(TypeInfo(YRealmType), Prefix + sRType));
  end;
var
  sRType: string;
begin
  inherited Create;
  sRType := SysConf.ReadStringN('Realm', 'Type');

  fRealmType := ConvertRealmTypeToEnum(sRType);

  fMaxPopulation := SysConf.ReadIntegerN('Network', 'Players');
  if fMaxPopulation = 0 then fMaxPopulation := $FFFF; { A big number }

  fTimeZone := SysConf.ReadIntegerN('Realm', 'TimeZone');  //0; { U.S. TimeZone }

  fServer := SysConf.ReadStringN('Network', 'RealmAddress');
  if fServer = '' then fServer := 'localhost'; { Default to this host }

  fPort := SysConf.ReadIntegerN('Network', 'RealmPort');
  if fPort = 0 then fPort := 3725; { Default Realm Port }

  fName := SysConf.ReadStringN('Realm', 'Name');
  if fName = '' then fName := ProgramName; { Default to our name :) }
end;

{ YRealmList }

procedure YNwRealmList.Add(cRealm: YNwBaseRealm);
begin
  fList.Add(cRealm);
end;

procedure YNwRealmList.Clear;
var
  iI: Int32;
  cRealm: YNwBaseRealm;
begin
  for iI := 0 to Count - 1 do
  begin
    cRealm := fList.Items[iI];
    cRealm.Free;
  end;

  fList.Clear;
end;

function YNwRealmList.GetRealmCount: Int32;
begin
  Result := fList.Size;
end;

function YNwRealmList.GetRealmObject(Index: Int32): YNwBaseRealm;
begin
  Result := fList.Items[Index];
end;

destructor YNwRealmList.Destroy;
begin
  Clear;
  fList.Free;
  inherited Destroy;
end;

constructor YNwRealmList.Create;
begin
  inherited Create;
  fList := TPtrArrayList.Create;
end;

end.
