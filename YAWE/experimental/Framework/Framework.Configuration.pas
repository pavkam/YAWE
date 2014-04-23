{*------------------------------------------------------------------------------
  Configuration File Reader.

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
unit Framework.Configuration;

interface

uses
  SysUtils,
  Misc.Containers,
  Framework.Base;

type
  TConfiguration = class(TBaseInterfacedObject)
    private
      fFileName: string;
      fConfValues: TStrPtrHashMap;
    public
      constructor Create(const FileName: string); reintroduce;
      destructor Destroy; override;
      procedure Load;

      procedure SetDefaultValue(const Section, Index: string; Value: Int32); overload;
      procedure SetDefaultValue(const Section, Index: string; const Value: Float); overload;
      procedure SetDefaultValue(const Section, Index: string; const Value: string); overload;

      function GetIntegerValue(const Section, Index: string): Int32;
      function GetStringValue(const Section, Index: string): string;
      function GetFloatValue(const Section, Index: string): Float;

      property StringValue[const Section, Index: string]: string read GetStringValue;
      property IntegerValue[const Section, Index: string]: Int32 read GetIntegerValue;
      property FloatValue[const Section, Index: string]: Float read GetFloatValue;
      property FileName: string read fFileName;
    end;

implementation

uses
  Classes,
  Misc.Resources,
  Misc.Miscleanous;

type
  PConfValue = ^YConfValue;
  YConfValue = record
    Name: string;
    Section: string;
    case &Type: UInt8 of
      0: (
        Int: Int32;
      );
      1: (
        Flt: Float;
      );
      2: (
        Str: PString;
      );
  end;

{ YConfiguration }

constructor TConfiguration.Create(const FileName: string);
begin
  inherited Create;
  fConfValues := TStrPtrHashMap.Create(True, 32);
  fFileName := FileNameToOS(FileName);
end;

destructor TConfiguration.Destroy;
var
  ifItr: IPtrIterator;
  pDef: PConfValue;
begin
  ifItr := fConfValues.Values;
  while ifItr.HasNext do
  begin
    pDef := ifItr.Next;
    if pDef^.&Type = 2 then Dispose(pDef^.Str);
    Dispose(pDef);
  end;

  fConfValues.Destroy;
  inherited Destroy;
end;

function TConfiguration.GetIntegerValue(const Section, Index: string): Int32;
var
  pDef: PConfValue;
begin
  pDef := fConfValues.GetValue(Uppercase(Section + '.' + Index));
  if pDef <> nil then
  begin
    case pDef^.&Type of
      0: Result := pDef^.Int;
      1: Result := Trunc32(pDef^.Flt);
      2: Result := StrToIntDef(pDef^.Str^, 0);
    else
      Result := 0;
    end;
  end else Result := 0;
end;

function TConfiguration.GetFloatValue(const Section, Index: string): Float;
var
  pDef: PConfValue;
begin
  pDef := fConfValues.GetValue(Uppercase(Section + '.' + Index));
  if pDef <> nil then
  begin
    case pDef^.&Type of
      0: Result := pDef^.Int;
      1: Result := pDef^.Flt;
      2: Result := atof(pDef^.Str^);
    else
      Result := 0;
    end;
  end else Result := 0;
end;

function TConfiguration.GetStringValue(const Section, Index: string): string;
var
  pDef: PConfValue;
begin
  pDef := fConfValues.GetValue(Uppercase(Section + '.' + Index));
  if pDef <> nil then
  begin
    case pDef^.&Type of
      0: Result := IntToStr(pDef.Int);
      1: Result := ftoa(pDef^.Flt);
      2: Result := pDef^.Str^;
    else
      Result := '';
    end;
  end else Result := '';
end;

procedure TConfiguration.Load;
var
  cTemp: TStringList;
  iPx: Int32;
  sLine: string;
  sTp: string;
  sVar: string;
  sSect: string;
  sTemp: string;
  pDef: PConfValue;
begin
  cTemp := TStringList.Create;
  try
    cTemp.LoadFromFile(fFileName);
  
    if cTemp.Count > 0 then
    begin
      for sLine in cTemp do
      begin
        sTp := sLine;
        if Length(sTp) < 3 then Continue; { Not a X = Y line and not a [X] also }
        iPx := CharPos(';', sTp);
        if iPx > 0 then Delete(sTp, iPx, Length(sTp));
        iPx := CharPos('=', sTp);
  
        if iPx > 0 then
        begin
          sVar := UpperCase(Trim(Copy(sTp, 1, iPx - 1)));
          Delete(sTp, 1, iPx);
          sTp := Trim(sTp);
          sTemp := sSect + '.' + sVar;
          pDef := fConfValues.GetValue(sTemp);
          if pDef = nil then
          begin
            New(pDef);
            pDef^.Name := sVar;
            pDef^.Section := sSect;
            pDef^.&Type := 2;
            New(pDef^.Str);
            pDef^.Str^ := sTp;
            fConfValues.PutValue(sTemp, pDef);
          end else
          begin
            case pDef^.&Type of
              0: TryStrToInt(sTp, pDef^.Int);
              1: TextBufToFloat(PChar(sTp), pDef^.Flt);
              2: pDef^.Str^ := sTp;
            end;
          end;
          Continue;
        end;
  
        sTp := Trim(sTp);
        iPx := CharPos('[', sTp);
  
        if iPx = 1 then
        begin
          iPx := CharPos(']', sTp);
          if iPx = 0 then Continue;
          sSect := UpperCase(Trim(Copy(sTp, 2, iPx - 2)));
        end;
      end;
    end;
  finally
    cTemp.Free;
  end;
end;

procedure TConfiguration.SetDefaultValue(const Section, Index: string;
  Value: Int32);
var
  pDef: PConfValue;
  sTemp: string;
begin
  sTemp := Uppercase(Section + '.' + Index);
  if not fConfValues.ContainsKey(sTemp) then
  begin
    New(pDef);
    pDef^.Name := Index;
    pDef^.Section := Section;
    pDef^.&Type := 0;
    pDef^.Int := Value;
    fConfValues.PutValue(sTemp, pDef);
  end;
end;

procedure TConfiguration.SetDefaultValue(const Section, Index: string;
  const Value: Float);
var
  pDef: PConfValue;
  sTemp: string;
begin
  sTemp := Uppercase(Section + '.' + Index);
  if not fConfValues.ContainsKey(sTemp) then
  begin
    New(pDef);
    pDef^.Name := Index;
    pDef^.Section := Section;
    pDef^.&Type := 1;
    pDef^.Flt := Value;
    fConfValues.PutValue(sTemp, pDef);
  end;
end;

procedure TConfiguration.SetDefaultValue(const Section, Index,
  Value: string);
var
  pDef: PConfValue;
  sTemp: string;
begin
  sTemp := Uppercase(Section + '.' + Index);
  if not fConfValues.ContainsKey(sTemp) then
  begin
    New(pDef);
    pDef^.Name := Index;
    pDef^.Section := Section;
    pDef^.&Type := 2;
    New(pDef^.Str);
    pDef^.Str^ := Value;
    fConfValues.PutValue(sTemp, pDef);
  end;
end;

end.
