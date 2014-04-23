{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Stacks
  
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
unit Bfg.Containers.Stacks;

interface

uses
  SysUtils,
  Bfg.Utils,
  Bfg.Containers.Interfaces{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

type
  TIntfStack = class(TAbstractContainer, IIntfStack)
  private
    FElements: TIntfDynArray;
    FCount: Integer;
    FCapacity: Integer;
  public
    procedure Grow; virtual;
    { IIntfStack }
    function Contains(const AInterface: IInterface): Boolean;
    function Empty: Boolean;
    function Pop: IInterface;
    procedure Push(const AInterface: IInterface);
    function Size: Integer;
  public
    constructor Create(ACapacity: Integer = 32);
  end;

  TStrStack = class(TAbstractContainer, IStrStack)
  private
    FElements: TStringDynArray;
    FCount: Integer;
    FCapacity: Integer;
  public
    procedure Grow; virtual;
    { IStrStack }
    function Contains(const AString: string): Boolean;
    function Empty: Boolean;
    function Pop: string;
    procedure Push(const AString: string);
    function Size: Integer;
  public
    constructor Create(ACapacity: Integer = 32);
  end;

  TPtrStack = class(TAbstractContainer, IPtrStack)
  private
    FElements: TPointerDynArray;
    FCount: Integer;
    FCapacity: Integer;
  public
    procedure Grow; virtual;
    { IPtrStack }
    function Contains(APtr: Pointer): Boolean;
    function Empty: Boolean;
    function Pop: Pointer;
    procedure Push(APtr: Pointer);
    function Size: Integer;
  public
    constructor Create(ACapacity: Integer = 32);
  end;

  TStack = class(TAbstractContainer, IStack)
  private
    FElements: TObjectDynArray;
    FCount: Integer;
    FCapacity: Integer;
  public
    procedure Grow; virtual;
    { IStack }
    function Contains(AObject: TObject): Boolean;
    function Empty: Boolean;
    function Pop: TObject;
    procedure Push(AObject: TObject);
    function Size: Integer;
  public
    constructor Create(ACapacity: Integer = 32);
  end;

implementation

//=== { TIntfStack } ======================================================

constructor TIntfStack.Create(ACapacity: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2287 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if ACapacity < 0 then
    FCapacity := 0
  else
    FCapacity := ACapacity;
  SetLength(FElements, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2287; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfStack.Contains(const AInterface: IInterface): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2288 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AInterface = nil then
    Exit;
  for I := 0 to FCount - 1 do
    if FElements[I] = AInterface then
    begin
      Result := True;
      Break;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2288; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfStack.Empty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2289 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2289; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfStack.Grow;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2290 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FCapacity > 64 then
    FCapacity := FCapacity + FCapacity div 4
  else
    FCapacity := FCapacity * 4;
  SetLength(FElements, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2290; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfStack.Pop: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2291 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FCount = 0 then
    Exit;
  Dec(FCount);
  Result := FElements[FCount];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2291; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfStack.Push(const AInterface: IInterface);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2292 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AInterface = nil then
    Exit;
  if FCount = FCapacity then
    Grow;
  FElements[FCount] := AInterface;
  Inc(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2292; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfStack.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2293 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2293; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TStrStack } =======================================================

constructor TStrStack.Create(ACapacity: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2294 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if ACapacity < 0 then
    FCapacity := 0
  else
    FCapacity := ACapacity;
  SetLength(FElements, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2294; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrStack.Contains(const AString: string): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2295 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AString = '' then
    Exit;
  for I := 0 to FCount - 1 do
    if FElements[I] = AString then
    begin
      Result := True;
      Exit;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2295; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrStack.Empty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2296 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2296; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrStack.Grow;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2297 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FCapacity > 64 then
    FCapacity := FCapacity + FCapacity div 4
  else
    FCapacity := FCapacity * 4;
  SetLength(FElements, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2297; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrStack.Pop: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2298 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FCount = 0 then
    Exit;
  Dec(FCount);
  Result := FElements[FCount];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2298; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrStack.Push(const AString: string);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2299 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AString = '' then
    Exit;
  if FCount = FCapacity then
    Grow;
  FElements[FCount] := AString;
  Inc(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2299; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrStack.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2300 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2300; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TPtrStack } ==========================================================

constructor TPtrStack.Create(ACapacity: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2301 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if ACapacity < 0 then
    FCapacity := 0
  else
    FCapacity := ACapacity;
  SetLength(FElements, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2301; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrStack.Contains(APtr: Pointer): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2302 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if APtr = nil then
    Exit;
  for I := 0 to FCount - 1 do
    if FElements[I] = APtr then
    begin
      Result := True;
      Break;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2302; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrStack.Empty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2303 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2303; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrStack.Grow;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2304 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FCapacity > 64 then
    FCapacity := FCapacity + FCapacity div 4
  else
    FCapacity := FCapacity * 4;
  SetLength(FElements, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2304; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrStack.Pop: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2305 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  if FCount = 0 then
    Exit;
  Dec(FCount);
  Result := FElements[FCount];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2305; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrStack.Push(APtr: Pointer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2306 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if APtr = nil then
    Exit;
  if FCount = FCapacity then
    Grow;
  FElements[FCount] := APtr;
  Inc(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2306; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrStack.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2307 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2307; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TStack } ==========================================================

constructor TStack.Create(ACapacity: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2308 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if ACapacity < 0 then
    FCapacity := 0
  else
    FCapacity := ACapacity;
  SetLength(FElements, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2308; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStack.Contains(AObject: TObject): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2309 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AObject = nil then
    Exit;
  for I := 0 to FCount - 1 do
    if FElements[I] = AObject then
    begin
      Result := True;
      Break;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2309; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStack.Empty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2310 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2310; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStack.Grow;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2311 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FCapacity > 64 then
    FCapacity := FCapacity + FCapacity div 4
  else
    FCapacity := FCapacity * 4;
  SetLength(FElements, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2311; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStack.Pop: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2312 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  if FCount = 0 then
    Exit;
  Dec(FCount);
  Result := FElements[FCount];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2312; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStack.Push(AObject: TObject);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2313 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AObject = nil then
    Exit;
  if FCount = FCapacity then
    Grow;
  FElements[FCount] := AObject;
  Inc(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2313; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStack.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2314 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2314; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

end.
