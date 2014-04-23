{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  A very special String List
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Bfg.Containers.StringList;

interface

uses
  Classes{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

type
  TStringDataList = class(TObject)
    private
      fList: TStringList;
    public
      constructor Create; 
      destructor Destroy; override;
      function GetAsString(iIndex: Integer): string; inline;
      function GetAsInteger(iIndex: Integer; out bSuccess: Boolean): Longword; overload; inline;
      function GetAsInteger(iIndex: Integer): Longword; overload; inline;
      function GetAsFloat(iIndex: Integer; out bSuccess: Boolean): Single; overload; inline;
      function GetAsFloat(iIndex: Integer): Single; overload; inline;
      procedure AddAsString(const sStr: string); inline;
      procedure AddAsInteger(iValue: Longword); inline;
      procedure AddAsFloat(const fValue: Single); inline;
      property List: TStringList read fList;
  end;

implementation

uses
  Bfg.Resources,
  Bfg.Utils,
  SysUtils;

{ TStringDataList }

procedure TStringDataList.AddAsFloat(const fValue: Single);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2315 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  fList.Append(ftoa(fValue));
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2315; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStringDataList.AddAsInteger(iValue: Longword);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2316 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  fList.Append(itoa(iValue));
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2316; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStringDataList.AddAsString(const sStr: string);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2317 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  fList.Append(sStr);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2317; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

constructor TStringDataList.Create;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2318 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  fList := TStringList.Create;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2318; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TStringDataList.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2319 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  fList.Free;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2319; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStringDataList.GetAsFloat(iIndex: Integer; out bSuccess: Boolean): Single;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2320 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if iIndex >= fList.Count then
  begin
    bSuccess := False;
    Result := 0;
  end else
  begin
    bSuccess := TryStrToFloat( StringReplace(fList[iIndex], '.', ',', [rfReplaceAll]), Result);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2320; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStringDataList.GetAsInteger(iIndex: Integer; out bSuccess: Boolean): Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2321 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if iIndex >= fList.Count then
  begin
    bSuccess := False;
    Result := 0;
  end else
  begin
    bSuccess := TryStrToInt(fList[iIndex], Integer(Result));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2321; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStringDataList.GetAsString(iIndex: Integer): string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2322 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if iIndex >= fList.Count then Result := '' else Result := fList[iIndex];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2322; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStringDataList.GetAsFloat(iIndex: Integer): Single;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2323 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if iIndex >= fList.Count then Result := 0 else Result := atof(fList[iIndex]);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2323; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStringDataList.GetAsInteger(iIndex: Integer): Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2324 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if iIndex >= fList.Count then Result := 0 else Result := atoi32(fList[iIndex]);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2324; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

end.
