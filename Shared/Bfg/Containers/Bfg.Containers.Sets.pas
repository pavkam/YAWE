{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Array Sets.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright JEDI Team
  @Author JEDI Team
  @Changes Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Bfg.Containers.Sets;

interface

uses
  Bfg.Containers.Interfaces,
  Bfg.Containers.ArrayList{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

type
  TStrArraySet = class(TStrArrayList, IStrCollection, IStrSet, ICloneable)
    protected
      function Add(const AString: string): Boolean;
      procedure AddAll(const ACollection: IStrCollection);
    public
    { IStrSet }
      procedure Intersect(const ACollection: IStrCollection);
      procedure Subtract(const ACollection: IStrCollection);
      procedure Union(const ACollection: IStrCollection);
    end;

  TIntArraySet = class(TIntArrayList, IIntCollection, IIntSet, ICloneable)
    protected
      function Add(AInt: Integer): Boolean;
      procedure AddAll(const ACollection: IIntCollection);
    public
    { IIntSet }
      procedure Intersect(const ACollection: IIntCollection);
      procedure Subtract(const ACollection: IIntCollection);
      procedure Union(const ACollection: IIntCollection);
    end;

  TPtrArraySet = class(TPtrArrayList, IPtrCollection, IPtrSet, ICloneable)
    protected
      function Add(APtr: Pointer): Boolean;
      procedure AddAll(const ACollection: IPtrCollection);
    public
    { IPtrSet }
      procedure Intersect(const ACollection: IPtrCollection);
      procedure Subtract(const ACollection: IPtrCollection);
      procedure Union(const ACollection: IPtrCollection);
    end;

  TArraySet = class(TArrayList, ICollection, ISet, ICloneable)
    protected
      function Add(AObject: TObject): Boolean;
      procedure AddAll(const ACollection: ICollection);
    public
    { ISet }
      procedure Intersect(const ACollection: ICollection);
      procedure Subtract(const ACollection: ICollection);
      procedure Union(const ACollection: ICollection);
    end;

  TIntfArraySet = class(TIntfArrayList, IIntfCollection, IIntfSet, ICloneable)
    protected
      function Add(const AInterface: IInterface): Boolean;
      procedure AddAll(const ACollection: IIntfCollection);
    public
    { IIntfSet }
      procedure Intersect(const ACollection: IIntfCollection);
      procedure Subtract(const ACollection: IIntfCollection);
      procedure Union(const ACollection: IIntfCollection);
    end;

implementation

{ TStrArraySet }

function TStrArraySet.Add(const AString: string): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2199 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if Contains(AString) then Exit;
  inherited Add(AString);
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2199; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArraySet.AddAll(const ACollection: IStrCollection);
var
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2200 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2200; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArraySet.Intersect(const ACollection: IStrCollection);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2201 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  RetainAll(ACollection);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2201; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArraySet.Subtract(const ACollection: IStrCollection);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2202 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  RemoveAll(ACollection);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2202; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrArraySet.Union(const ACollection: IStrCollection);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2203 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  AddAll(ACollection);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2203; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TIntArraySet }

function TIntArraySet.Add(AInt: Integer): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2204 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if Contains(AInt) then Exit;
  inherited Add(AInt);
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2204; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntArraySet.AddAll(const ACollection: IIntCollection);
var
  It: IIntIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2205 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2205; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntArraySet.Intersect(const ACollection: IIntCollection);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2206 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  RetainAll(ACollection);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2206; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntArraySet.Subtract(const ACollection: IIntCollection);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2207 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  RemoveAll(ACollection);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2207; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntArraySet.Union(const ACollection: IIntCollection);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2208 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  AddAll(ACollection);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2208; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TPtrArraySet }

function TPtrArraySet.Add(APtr: Pointer): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2209 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if Contains(APtr) then Exit;
  inherited Add(APtr);
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2209; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrArraySet.AddAll(const ACollection: IPtrCollection);
var
  It: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2210 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2210; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrArraySet.Intersect(const ACollection: IPtrCollection);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2211 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  RetainAll(ACollection);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2211; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrArraySet.Subtract(const ACollection: IPtrCollection);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2212 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  RemoveAll(ACollection);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2212; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrArraySet.Union(const ACollection: IPtrCollection);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2213 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  AddAll(ACollection);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2213; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TArraySet }

function TArraySet.Add(AObject: TObject): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2214 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if Contains(AObject) then Exit;
  inherited Add(AObject);
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2214; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArraySet.AddAll(const ACollection: ICollection);
var
  It: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2215 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2215; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArraySet.Intersect(const ACollection: ICollection);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2216 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  RetainAll(ACollection);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2216; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArraySet.Subtract(const ACollection: ICollection);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2217 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  RemoveAll(ACollection);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2217; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TArraySet.Union(const ACollection: ICollection);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2218 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  AddAll(ACollection);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2218; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

{ TIntfArraySet }

function TIntfArraySet.Add(const AInterface: IInterface): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2219 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if Contains(AInterface) then Exit;
  inherited Add(AInterface);
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2219; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfArraySet.AddAll(const ACollection: IIntfCollection);
var
  It: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2220 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2220; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfArraySet.Intersect(const ACollection: IIntfCollection);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2221 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  RetainAll(ACollection);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2221; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfArraySet.Subtract(const ACollection: IIntfCollection);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2222 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  RemoveAll(ACollection);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2222; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfArraySet.Union(const ACollection: IIntfCollection);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2223 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  AddAll(ACollection);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2223; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

end.
