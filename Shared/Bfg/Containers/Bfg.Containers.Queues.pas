{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Queues
  
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
unit Bfg.Containers.Queues;

interface

uses
  SysUtils,
  Bfg.Utils,
  Bfg.Containers.Interfaces{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

type
  TIntfQueue = class(TAbstractContainer, IIntfQueue)
  private
    FCapacity: Integer;
    FElements: TIntfDynArray;
    FHead: Integer;
    FTail: Integer;
  public
    { IIntfQueue }
    function Contains(const AInterface: IInterface): Boolean;
    function Dequeue: IInterface;
    function Empty: Boolean;
    procedure Enqueue(const AInterface: IInterface);
    function Size: Integer;
  public
    constructor Create(ACapacity: Integer = 32);
  end;

  TStrQueue = class(TAbstractContainer, IStrQueue)
  private
    FCapacity: Integer;
    FElements: TStringDynArray;
    FHead: Integer;
    FTail: Integer;
  public
    { IStrQueue }
    function Contains(const AString: string): Boolean;
    function Dequeue: string;
    function Empty: Boolean;
    procedure Enqueue(const AString: string);
    function Size: Integer;
  public
    constructor Create(ACapacity: Integer = 32);
  end;

  TPtrQueue = class(TAbstractContainer, IPtrQueue)
  private
    FCapacity: Integer;
    FElements: TPointerDynArray;
    FHead: Integer;
    FTail: Integer;
  public
    { IPtrQueue }
    function Contains(APtr: Pointer): Boolean;
    function Dequeue: Pointer;
    function Empty: Boolean;
    procedure Enqueue(APtr: Pointer);
    function Size: Integer;
  public
    constructor Create(ACapacity: Integer = 32);
  end;

  TQueue = class(TAbstractContainer, IQueue)
  private
    FCapacity: Integer;
    FElements: TObjectDynArray;
    FHead: Integer;
    FTail: Integer;
  public
    { IQueue }
    function Contains(AObject: TObject): Boolean;
    function Dequeue: TObject;
    function Empty: Boolean;
    procedure Enqueue(AObject: TObject);
    function Size: Integer;
  public
    constructor Create(ACapacity: Integer = 32);
  end;

implementation

uses
  Bfg.Resources;

//=== { TIntfQueue } ======================================================

constructor TIntfQueue.Create(ACapacity: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2175 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if ACapacity < 0 then
    FCapacity := 0
  else
    FCapacity := ACapacity;
  SetLength(FElements, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2175; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfQueue.Contains(const AInterface: IInterface): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2176 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AInterface = nil then
    Exit;
  I := FHead;
  while I <> FTail do
  begin
    if FElements[I] = AInterface then
    begin
      Result := True;
      Break;
    end;
    I := (I + 1) mod FCapacity;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2176; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfQueue.Dequeue: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2177 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  if FTail = FHead then
    Exit;
  Result := FElements[FHead];
  FElements[FHead] := nil;
  FHead := (FHead + 1) mod FCapacity;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2177; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfQueue.Empty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2178 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FTail = FHead;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2178; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfQueue.Enqueue(const AInterface: IInterface);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2179 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AInterface = nil then
    Exit;
  FElements[FTail] := AInterface;
  FTail := (FTail + 1) mod FCapacity;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2179; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfQueue.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2180 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FTail - FHead;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2180; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TStrQueue } =======================================================

constructor TStrQueue.Create(ACapacity: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2181 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if ACapacity < 0 then
    FCapacity := 0
  else
    FCapacity := ACapacity;
  SetLength(FElements, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2181; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrQueue.Contains(const AString: string): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2182 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AString = '' then
    Exit;
  I := FHead;
  while I <> FTail do
  begin
    if FElements[I] = AString then
    begin
      Result := True;
      Break;
    end;
    I := (I + 1) mod FCapacity;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2182; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrQueue.Dequeue: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2183 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := '';
  if FTail = FHead then
    Exit;
  Result := FElements[FHead];
  FElements[FHead] := '';
  FHead := (FHead + 1) mod FCapacity;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2183; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrQueue.Empty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2184 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FTail = FHead;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2184; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrQueue.Enqueue(const AString: string);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2185 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AString = '' then
    Exit;
  FElements[FTail] := AString;
  FTail := (FTail + 1) mod FCapacity;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2185; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrQueue.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2186 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FTail - FHead;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2186; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TPtrQueue } ==========================================================

constructor TPtrQueue.Create(ACapacity: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2187 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if ACapacity < 0 then
    FCapacity := 0
  else
    FCapacity := ACapacity;
  SetLength(FElements, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2187; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrQueue.Contains(APtr: Pointer): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2188 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if APtr = nil then
    Exit;
  I := FHead;
  while I <> FTail do
  begin
    if FElements[I] = APtr then
    begin
      Result := True;
      Break;
    end;
    I := (I + 1) mod FCapacity;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2188; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrQueue.Dequeue: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2189 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  if FTail = FHead then
    Exit;
  Result := FElements[FHead];
  FElements[FHead] := nil;
  FHead := (FHead + 1) mod FCapacity;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2189; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrQueue.Empty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2190 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FTail = FHead;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2190; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrQueue.Enqueue(APtr: Pointer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2191 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if APtr = nil then
    Exit;
  FElements[FTail] := APtr;
  FTail := (FTail + 1) mod FCapacity;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2191; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrQueue.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2192 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FTail - FHead;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2192; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TQueue } ==========================================================

constructor TQueue.Create(ACapacity: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2193 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if ACapacity < 0 then
    FCapacity := 0
  else
    FCapacity := ACapacity;
  SetLength(FElements, FCapacity);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2193; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TQueue.Contains(AObject: TObject): Boolean;
var
  I: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2194 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AObject = nil then
    Exit;
  I := FHead;
  while I <> FTail do
  begin
    if FElements[I] = AObject then
    begin
      Result := True;
      Break;
    end;
    I := (I + 1) mod FCapacity;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2194; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TQueue.Dequeue: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2195 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  if FTail = FHead then
    Exit;
  Result := FElements[FHead];
  FElements[FHead] := nil;
  FHead := (FHead + 1) mod FCapacity;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2195; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TQueue.Empty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2196 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FTail = FHead;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2196; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TQueue.Enqueue(AObject: TObject);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2197 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if AObject = nil then
    Exit;
  FElements[FTail] := AObject;
  FTail := (FTail + 1) mod FCapacity;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2197; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TQueue.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2198 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FTail - FHead;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2198; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

end.
