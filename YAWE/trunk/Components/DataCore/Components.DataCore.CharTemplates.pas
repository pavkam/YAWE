{*------------------------------------------------------------------------------
  The Character Template Store.

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
unit Components.DataCore.CharTemplates;

interface

uses
  Framework.Base,
  Components.DataCore.Fields,
  Components.DataCore.Storage,
  Components.Shared,
  Components.DataCore.Types,
  Components.GameCore.Constants,
  Misc.Containers,
  SysUtils;

type
  YDbCharTemplateStore = class(TBaseObject)
    private
      fStorage: YDbStorageMedium;
    public
      procedure SelectMedium(cStorage: YDbStorageMedium);
      procedure UpdateTemplate(cTemplate, cBy: YDbCharTemplate);
      function CombineTemplate(iRace: YGameRace; iClass: YGameClass): YDbCharTemplate;
      property Medium: YDbStorageMedium read fStorage;
    end;

implementation

uses
  Framework,
  Misc.Miscleanous,
  Misc.Resources;

procedure YDbCharTemplateStore.SelectMedium(cStorage: YDbStorageMedium);
begin
  fStorage := cStorage;
end;

procedure YDbCharTemplateStore.UpdateTemplate(cTemplate, cBy: YDbCharTemplate);
var
  iY, iLen: Int32;
begin
  AssignIfZero(@cTemplate.Map, cBy.Map);
  AssignIfZero(@cTemplate.Zone, cBy.Zone);
  AssignIfZero(@cTemplate.StartingX, cBy.StartingX);
  AssignIfZero(@cTemplate.StartingY, cBy.StartingY);
  AssignIfZero(@cTemplate.StartingZ, cBy.StartingZ);
  AssignIfZero(@cTemplate.StartingAngle, cBy.StartingAngle);

  cTemplate.InitialStrength := cTemplate.InitialStrength + cBy.InitialStrength;
  cTemplate.InitialAgility := cTemplate.InitialAgility + cBy.InitialAgility;
  cTemplate.InitialStamina := cTemplate.InitialStamina + cBy.InitialStamina;
  cTemplate.InitialIntellect := cTemplate.InitialIntellect + cBy.InitialIntellect;
  cTemplate.InitialSpirit := cTemplate.InitialSpirit + cBy.InitialSpirit;

  AssignIfZero(@cTemplate.MaleBodyModel, cBy.MaleBodyModel);
  AssignIfZero(@cTemplate.FemaleBodyModel, cBy.FemaleBodyModel);
  AssignIfZero(@cTemplate.BodySize, cBy.BodySize);
  AssignIfZero(@cTemplate.PowerType, cBy.PowerType);

  cTemplate.BasePower := cTemplate.BasePower + cBy.BasePower;
  cTemplate.BaseHealth := cTemplate.BaseHealth + cBy.BaseHealth;

  iLen := Length(cTemplate.SkillData);
  cTemplate.SetSkillDataLength(iLen + Length(cBy.SkillData));
  for iY := 0 to Length(cBy.SkillData) -1 do
  begin
    cTemplate.SkillData[iLen+iY] := cBy.SkillData[iY];
  end;

  iLen := Length(cTemplate.ItemData);
  cTemplate.SetItemDataLength(iLen + Length(cBy.ItemData));
  for iY := 0 to Length(cBy.ItemData) -1 do
  begin
    cTemplate.ItemData[iLen+iY] := cBy.ItemData[iY];
  end;

  iLen := Length(cTemplate.Spells);
  cTemplate.SetSpellsLength(iLen + Length(cBy.Spells));
  for iY := 0 to Length(cBy.Spells) -1 do
  begin
    cTemplate.Spells[iLen+iY] := cBy.Spells[iY];
  end;

  iLen := Length(cTemplate.ActionButtons);
  cTemplate.SetActionButtonsLength(iLen + Length(cBy.ActionButtons));
  for iY := 0 to Length(cBy.ActionButtons) -1 do
  begin
    cTemplate.ActionButtons[iLen+iY] := cBy.ActionButtons[iY];
  end;

  AssignIfZero(@cTemplate.AttackTimeLo, cBy.AttackTimeLo);
  AssignIfZero(@cTemplate.AttackTimeHi, cBy.AttackTimeHi);
  AssignIfZero(@cTemplate.AttackPower, cBy.AttackPower);

  cTemplate.BaseDamageLo := cTemplate.BaseDamageLo + cBy.BaseDamageLo;
  cTemplate.BaseDamageHi := cTemplate.BaseDamageHi + cBy.BaseDamageHi;
end;

function YDbCharTemplateStore.CombineTemplate(iRace: YGameRace; iClass: YGameClass): YDbCharTemplate;
var
  aClassTemplates: array of YDbCharTemplate;
  sRace: string;
  iX: Int32;
begin
  fStorage.LoadEntry(FIELD_CT_RACE, RaceToString(iRace), Result);
  fStorage.LoadEntryList(FIELD_CT_CLASS, ClassToString(iClass), YDbSerializables(aClassTemplates));

  Result.Race := RaceToString(iRace);
  Result.PlayerClass := ClassToString(iClass);

  for iX := 0 to Length(aClassTemplates) -1 do
  begin
    sRace := aClassTemplates[iX].Race;
    if (sRace = '') or StringsEqualNoCase(sRace, Result.Race) then
    begin
      UpdateTemplate(Result, aClassTemplates[iX]);
    end;
  end;

  fStorage.ReleaseEntryList(YDbSerializables(aClassTemplates));

  if Result.BodySize = 0 then Result.BodySize := 1;
end;

end.


