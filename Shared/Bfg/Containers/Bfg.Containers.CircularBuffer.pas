{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  A special circular buffer for input data storage.

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
unit Bfg.Containers.CircularBuffer;

interface

uses
  Bfg.Utils{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

type
  TCircularBuffer = class(TObject)
    private
      FBuffer: PByteArray;
      FSize: Integer;
      FWritePos: Integer;
      FReadPos: Integer;

      function GetPtr(Index: Integer): Pointer; //inline;
      procedure Grow;

      function GetMaxReadBytes: Integer;
      function GetMaxWriteBytes: Integer;
      procedure SetSize(NewSize: Integer);
    public
      constructor Create(Size: Integer);
      destructor Destroy; override;

      function Write(const Buf; Size: Integer): Boolean;
      function Read(var Buf; Size: Integer): Boolean;
      procedure Clear;

      property WritePosition: Integer read FWritePos write FWritePos;
      property ReadPosition: Integer read FReadPos write FReadPos;
      property Size: Integer read FSize write SetSize;
      property ReadAvail: Integer read GetMaxReadBytes;
      property WriteAvail: Integer read GetMaxWriteBytes;
      property Bytes[Index: Integer]: Pointer read GetPtr; default;
  end;

implementation

uses
  Math;

constructor TCircularBuffer.Create(Size: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1711 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  
  FSize := Size;
  FBuffer := AllocMem(Size);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1711; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TCircularBuffer.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1712 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FreeMem(FBuffer);

  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1712; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TCircularBuffer.Clear;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1713 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FReadPos := 0;
  FWritePos := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1713; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TCircularBuffer.GetMaxReadBytes: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1714 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FReadPos = FWritePos then
  begin
    Result := 0;
  end else if FReadPos < FWritePos then
  begin
    Result := FWritePos - FReadPos;
  end else
  begin
    Result := (FSize - FReadPos) + FWritePos;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1714; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TCircularBuffer.GetMaxWriteBytes: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1715 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FReadPos = FWritePos then
  begin
    Result := FSize;
  end else if FWritePos < FReadPos then
  begin
    Result := FReadPos - FWritePos;
  end else
  begin
    Result := (FSize - FWritePos) + FReadPos;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1715; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TCircularBuffer.GetPtr(Index: Integer): Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1716 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := @FBuffer^[Index];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1716; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TCircularBuffer.Grow;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1717 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Inc(FSize, FSize shr 1);
  ReallocMem(FBuffer, FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1717; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TCircularBuffer.Read(var Buf; Size: Integer): Boolean;
var
  S1, S2: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1718 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Size > GetMaxReadBytes then
  begin
    Result := False;
    Exit;
  end;

  if FReadPos + Size <= FSize then
  begin
    { No wrapping }
    Move(FBuffer^[FReadPos], Buf, Size);
    Inc(FReadPos, Size);
  end else
  begin
    { With wrapping }
    S1 := FSize - FReadPos;
    S2 := Size - S1;

    Move(FBuffer^[FReadPos], Buf, S1);
    Move(FBuffer^[0], PByteArray(@Buf)^[S1], S2);

    FReadPos := S2;
    Grow; { To reduce future wrapping }
  end;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1718; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TCircularBuffer.Write(const Buf; Size: Integer): Boolean;
var
  S1, S2: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1719 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Size >= GetMaxWriteBytes then
  begin
    Result := False;
    Exit;
  end;

  if FWritePos + Size < FSize then
  begin
    { No wrapping }
    Move(Buf, FBuffer^[FWritePos], Size);
    Inc(FWritePos, Size);
  end else
  begin
    { With wrapping }
    S1 := FSize - FWritePos;
    S2 := Size - S1;

    Move(Buf, FBuffer^[FWritePos], S1);
    Move(PByteArray(@Buf)^[S1], FBuffer^[0], S2);

    FWritePos := S2;
    Grow; { To reduce future wrapping }
  end;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1719; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TCircularBuffer.SetSize(NewSize: Integer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1720 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if NewSize <> FSize then
  begin
    ReallocMem(FBuffer, NewSize);
    FSize := NewSize;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1720; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

end.
