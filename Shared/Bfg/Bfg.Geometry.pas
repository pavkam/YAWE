{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Geometry Related Functionality
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

unit Bfg.Geometry;

interface

uses
  Math,
  SysUtils,
  Bfg.Utils{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

type
  PVector = ^TVector;
  TVector = record
    X: Single;
    Y: Single;
    Z: Single;
    W: Single; { Unused vector component }
  end;

  PMatrix = ^TMatrix;
  TMatrix = array[0..2] of array[0..2] of Single;

  PQuaternion = ^TQuaternion;
  TQuaternion = record
    case Integer of
      0: (
        RealPart: Single;
        ImagPart: array[0..2] of Single;
      );
      1: (
        Vector: TVector;
      );
  end;

  PSphere = ^TSphere;
  TSphere = record
    Center: TVector;
    Radius: Single;
  end;

  PAABB = ^TAABB;
  TAABB = record
    Min: TVector;
    Max: TVector;
  end;

  PSphereTree = ^TSphereTree;
  TSphereTree = record
    Detail: Integer;
    Spheres: PSphere;
  end;

  PAABBTree = ^TAABBTree;
  TAABBTree = record
    Detail: Integer;
    Boxes: PAABB;
  end;

  {$Z4}
  TBoundingVolumeType = (bvtUnknown, bvtSphere, bvtBox, bvtSphereList, bvtBoxList);
  {$Z1}

  PBoundingVolume = ^TBoundingVolume;
  TBoundingVolume = record
    case VolumeType: TBoundingVolumeType of
      bvtSphere: (
        Sphere: PSphere;
      );
      bvtBox: (
        Box: PAABB;
      );
      bvtSphereList: (
        SphereList: PSphereTree;
      );
      bvtBoxList: (
        BoxList: PAABBTree;
      );
      bvtUnknown: (
        Data: Pointer;
      );
  end;

{
  Vector functions

  Includes vector addition, substraction, multiplication (scaling), norm/length
  calculation, cross/dot products calculation, distance calculation and
  normalization.
}

function CreateVector: TVector; overload;
function CreateVector(const X, Y, Z: Single; const W: Single = 0): TVector; overload;
function CreateVector(const Vec: TVector): TVector; overload;

procedure MakeVector(var Res: TVector); overload;
procedure MakeVector(var Res: TVector; const X, Y, Z: Single; const W: Single = 0); overload;
procedure MakeVector(var Res: TVector; const Vec: TVector); overload;

{ VR := V1 + V2 }
procedure VectorAdd(const V1, V2: TVector; var VR: TVector); overload;
{ VR := V + F }
procedure VectorAdd(const V: TVector; const F: Single; var VR: TVector); overload;
{ V1 := V1 + V2 }
procedure AddVector(var V1: TVector; const V2: TVector); overload;
{ V := V + F }
procedure AddVector(var V: TVector; const F: Single); overload;

{ VR := V1 - V2 }
procedure VectorSub(const V1, V2: TVector; var VR: TVector); overload;
{ VR := V - F }
procedure VectorSub(const V: TVector; const F: Single; var VR: TVector); overload;
{ V1 := V1 - V2 }
procedure SubVector(var V1: TVector; const V2: TVector); overload;
{ V := V - F }
procedure SubVector(var V: TVector; const F: Single); overload;
{ Linear interpolation }
procedure VectorLerp(const V1, V2: TVector; const F: Single; var VR: TVector);

{ Calculates the Dot Product of 2 vectors }
function VectorDotProduct(const V1, V2: TVector): Single;
{ Calculates the Cross Product of 2 vectors }
procedure VectorCrossProduct(const V1, V2: TVector; var VR: TVector);

{ Result := Sqrt(x*x+y*y+z*z+w*w) }
function VectorLength(const V: TVector): Single;
{ Result := x*x+y*y+z*z+w*w }
function VectorNorm(const V: TVector): Single;

{ Result = DotProduct(V1, V2) / (Length(V1) * Length(V2)) }
function VectorAngle(const V1, V2: TVector): Single;

{ V := V * F }
procedure ScaleVector(var V: TVector; const F: Single);
{ VR := V * F }
procedure VectorScale(const V: TVector; const F: Single; var VR: TVector);

{ Result := Length(V1) - Length(V2) }
function VectorDistance(const V1, V2: TVector): Single;
{ Result := Norm(V1) - Norm(V2) }
function VectorDistanceSq(const V1, V2: TVector): Single;

function IsVectorDistanceWithin(const V1, V2: TVector; const F: Single): Boolean; inline;

{ Transforms a vector into a unit-length, dividing each component by its length }
procedure NormalizeVector(var V: TVector);
{ Creates an unit-length vector, dividing each component by its length }
procedure VectorNormalize(const V: TVector; var VR: TVector);

{
  Matrix functions

  Includes matrix scaling, determinant calculation, mulitplication,
  transposing and vector transforming.
}

{ Creates a scale matrix }
function CreateScaleMatrix(const V: TVector): TMatrix;
{ Creates a rotation matrix along the given Axis by the given Angle in radians }
function CreateRotationMatrix(Axis: TVector; const Angle: Single): TMatrix;

{ Multiplies two 3x3 matrices }
procedure MatrixMultiply(const M1, M2: TMatrix; var MR: TMatrix);

{ Transforms a vector by multiplying it with a matrix }
procedure VectorTransform(const V: TVector; const M: TMatrix; var VR: TVector);

{ Determinant of a 3x3 matrix }
function MatrixDeterminant(const M: TMatrix): Single;

{ Multiplies all elements of a 3x3 matrix with a factor }
procedure ScaleMatrix(var M: TMatrix; const F: Single);

{ Computes transpose of 3x3 matrix }
procedure TransposeMatrix(var M: TMatrix);

{
  Quaternion functions

  Includes quaternion conjugation, multiplication, to/from points conversion
  and spherical linear interpolation (slerp).
}

{ Creates a quaternion from the given values }
function QuaternionMake(const Imag, Imag2, Imag3, Real: Single): TQuaternion;
{ Returns the conjugate of a quaternion }
function QuaternionConjugate(const Q: TQuaternion): TQuaternion;
{ Returns the magnitude of the quaternion }
function QuaternionMagnitude(const Q: TQuaternion): Single;
{ Normalizes the given quaternion }
procedure NormalizeQuaternion(var Q: TQuaternion);
{ Creates a matrix out of a quaternion }
procedure QuaternionToMatrix(Q: TQuaternion; var M: TMatrix);

{ Constructs a unit quaternion from two points on unit sphere }
function QuaternionFromPoints(const V1, V2: TVector): TQuaternion;
{  Returns quaternion product qL * qR.
   Note: order is important!
   To combine rotations, use the product QuaternionMuliply(qSecond, qFirst),
   which gives the effect of rotating by qFirst then qSecond. }
procedure QuaternionMultiply(const qL, qR: TQuaternion; var qRes: TQuaternion);
{  Spherical linear interpolation of unit quaternions with spins.
   QStart, QEnd - start and end unit quaternions
   T            - interpolation parameter (0 to 1)
   Spin         - number of extra spin rotations to involve }
function QuaternionSlerp(const QStart, QEnd: TQuaternion; Spin: Integer; T: Single): TQuaternion;
{ Converts a unit quaternion into two points on a unit sphere }
procedure QuaternionToPoints(const Q: TQuaternion; var ArcFrom, ArcTo: TVector);

{
  Bounding volume functions

  Functions which create, destroy and intersect various types of bounding volumes.
}

{ Creates a bounding volume from given values }
function CreateSphereVolume(const Center: TVector; const Radius: Single): TBoundingVolume;
function CreateBoxVolume(const Min, Max: TVector): TBoundingVolume;
function CreateSphereTreeVolume(const Centers: array of TVector; const RadiusArr: array of Single): TBoundingVolume;
function CreateBoxTreeVolume(const Mins, Maxs: array of TVector): TBoundingVolume;

{ Deallocates memory used by a bounding volume }
procedure DestroyBoundingVolume(const Vol: TBoundingVolume);

{ Box-box intersection test }
function BoxIntersectsBox(const B1, B2: TAABB): Boolean;
{ Box-sphere intersection test }
function BoxIntersectsSphere(Const B: TAABB; const S: TSphere): Boolean;
{ Multiple box-box intersection tests }
function BoxIntersectsBoxList(const B: TAABB; const BL: TAABBTree): Boolean;
{ Multiple box-sphere intersection tests }
function BoxIntersectsSphereList(const B: TAABB; const SL: TSphereTree): Boolean;
{ Multiple box-sphere intersection tests }
function BoxListIntersectsBoxList(const BL1, BL2: TAABBTree): Boolean;
{ Sphere-sphere intersection test }
function SphereIntersectsSphere(const S1, S2: TSphere): Boolean;
{ Multiple sphere-sphere intersection tests }
function SphereIntersectsSphereList(const S: TSphere; const SL: TSphereTree): Boolean;
{ Multiple sphere-box intersection tests }
function SphereIntersectsBoxList(const S: TSphere; const BL: TAABBTree): Boolean;
{ Multiple sphere-sphere intersection tests }
function SphereListIntersectsSphereList(const SL1, SL2: TSphereTree): Boolean;
{ Multiple sphere-box intersection tests }
function SphereListIntersectsBoxList(const SL: TSphereTree; const BL: TAABBTree): Boolean;
{ Performs an intersection check based on the bounding volume type }
function VolumesIntersect(const Vol1, Vol2: TBoundingVolume): Boolean;

{ Packs a 32-bit float into a 16-bit int. Preserves first 3 decimal places, the
  rest can vary. }
function PackSingle(const F: Single): Word;
{ Unpacks a 32-bit float from a 16-bit int. }
function UnpackSingle(V: Word): Single;

implementation

function CreateVector: TVector;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,667 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result.X := 0;
  Result.Y := 0;
  Result.Z := 0;
  Result.W := 1;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,667; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function CreateVector(const X, Y, Z, W: Single): TVector;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,668 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
  Result.W := W;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,668; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function CreateVector(const Vec: TVector): TVector;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,669 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := Vec;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,669; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure MakeVector(var Res: TVector);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,670 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Res.X := 0;
  Res.Y := 0;
  Res.Z := 0;
  Res.W := 1;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,670; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure MakeVector(var Res: TVector; const X, Y, Z: Single; const W: Single = 0);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,671 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Res.X := X;
  Res.Y := Y;
  Res.Z := Z;
  Res.W := W;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,671; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure MakeVector(var Res: TVector; const Vec: TVector);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,672 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Res := Vec;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,672; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure VectorAdd(const V1, V2: TVector; var VR: TVector);
// EAX contains address of V1
// EDX contains address of V2
// ECX contains the result
asm
  FLD     DWORD PTR [EAX]
  FADD    DWORD PTR [EDX]
  FSTP    DWORD PTR [ECX]
  FLD     DWORD PTR [EAX+4]
  FADD    DWORD PTR [EDX+4]
  FSTP    DWORD PTR [ECX+4]
  FLD     DWORD PTR [EAX+8]
  FADD    DWORD PTR [EDX+8]
  FSTP    DWORD PTR [ECX+8]
end;

procedure VectorAdd(const V: TVector; const F: Single; var VR: TVector);
// EAX contains address of V
// EDX contains VR
// F is on the stack
asm
  FLD     DWORD PTR [EAX]
  FADD    F
  FSTP    DWORD PTR [EDX]
  FLD     DWORD PTR [EAX+4]
  FADD    F
  FSTP    DWORD PTR [EDX+4]
  FLD     DWORD PTR [EAX+8]
  FADD    F
  FSTP    DWORD PTR [EDX+8]
end;

procedure AddVector(var V1: TVector; const V2: TVector);
// EAX contains address of V1
// EDX contains V2
asm
  FLD     DWORD PTR [EAX]
  FADD    DWORD PTR [EDX]
  FSTP    DWORD PTR [EAX]
  FLD     DWORD PTR [EAX+4]
  FADD    DWORD PTR [EDX+4]
  FSTP    DWORD PTR [EAX+4]
  FLD     DWORD PTR [EAX+8]
  FADD    DWORD PTR [EDX+8]
  FSTP    DWORD PTR [EAX+8]
end;

procedure AddVector3DNow(var V1: TVector; const V2: TVector);
// EAX contains address of V1
// EDX contains V2
asm
  MOVQ  MM0, [EAX]
  PFADD MM0, [EDX]
  PFMUL MM0, [EDX]
  MOVQ  [EAX], MM0
  MOVQ  MM1, [EAX+8]
  PFADD MM1, [EDX+8]
  MOVQ  [EAX+8], MM1
  FEMMS
end;

procedure AddVector(var V: TVector; const F: Single);
// EAX contains address of V1
// F is on the stack
asm
  FLD     DWORD PTR [EAX]
  FADD    F
  FSTP    DWORD PTR [EAX]
  FLD     DWORD PTR [EAX+4]
  FADD    F
  FSTP    DWORD PTR [EAX+4]
  FLD     DWORD PTR [EAX+8]
  FADD    F
  FSTP    DWORD PTR [EAX+8]
end;

procedure VectorSub(const V1, V2: TVector; var VR: TVector);
// EAX contains address of V1
// EDX contains address of V2
// ECX contains the result
asm
  FLD     DWORD PTR [EAX]
  FSUB    DWORD PTR [EDX]
  FSTP    DWORD PTR [ECX]
  FLD     DWORD PTR [EAX+4]
  FSUB    DWORD PTR [EDX+4]
  FSTP    DWORD PTR [ECX+4]
  FLD     DWORD PTR [EAX+8]
  FSUB    DWORD PTR [EDX+8]
  FSTP    DWORD PTR [ECX+8]
end;

procedure VectorSub(const V: TVector; const F: Single; var VR: TVector);
// EAX contains address of V
// EDX contains VR
// F is on the stack
asm
  FLD     DWORD PTR [EAX]
  FSUB    F
  FSTP    DWORD PTR [EDX]
  FLD     DWORD PTR [EAX+4]
  FSUB    F
  FSTP    DWORD PTR [EDX+4]
  FLD     DWORD PTR [EAX+8]
  FSUB    F
  FSTP    DWORD PTR [EDX+8]
end;

procedure SubVector3DNow(var V1: TVector; const V2: TVector);
// EAX contains address of V1
// EDX contains V2
asm
  MOVQ  MM0, [EAX]
  PFSUB MM0, [EDX]
  PFMUL MM0, [EDX]
  MOVQ  [EAX], MM0
  MOVQ  MM1, [EAX+8]
  PFSUB MM1, [EDX+8]
  MOVQ  [EAX+8], MM1
  FEMMS
end;

procedure SubVector(var V1: TVector; const V2: TVector);
// EAX contains address of V1
// EDX contains V2
asm
  FLD     DWORD PTR [EAX]
  FSUB    DWORD PTR [EDX]
  FSTP    DWORD PTR [EAX]
  FLD     DWORD PTR [EAX+4]
  FSUB    DWORD PTR [EDX+4]
  FSTP    DWORD PTR [EAX+4]
  FLD     DWORD PTR [EAX+8]
  FSUB    DWORD PTR [EDX+8]
  FSTP    DWORD PTR [EAX+8]
end;

procedure SubVector(var V: TVector; const F: Single);
// EAX contains address of V1
// F is on the stack
asm
  FLD     DWORD PTR [EAX]
  FSUB    F
  FSTP    DWORD PTR [EAX]
  FLD     DWORD PTR [EAX+4]
  FSUB    F
  FSTP    DWORD PTR [EAX+4]
  FLD     DWORD PTR [EAX+8]
  FSUB    F
  FSTP    DWORD PTR [EAX+8]
end;

procedure VectorLerp(const V1, V2: TVector; const F: Single; var VR: TVector);
// EAX contains address of V1
// EDX contains address of V2
// ECX contains address of VR
// F is on the stack
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,673 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  VR.X := V1.X + (V1.X - V2.X) * F;
  VR.Y := V1.Y + (V1.Y - V2.Y) * F;
  VR.Z := V1.X + (V1.Z - V2.Z) * F;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,673; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function VectorDotProduct(const V1, V2: TVector): Single;
// EAX contains address of V1
// EDX contains address of V2
// Result is stored in ST(0)
asm
  FLD     DWORD PTR [EAX]
  FMUL    DWORD PTR [EDX]
  FLD     DWORD PTR [EAX+4]
  FMUL    DWORD PTR [EDX+4]
  FADDP
  FLD     DWORD PTR [EAX+8]
  FMUL    DWORD PTR [EDX+8]
  FADDP
end;

procedure VectorCrossProduct(const V1, V2: TVector; var VR: TVector);
// Temp is necessary because
// either V1 or V2 could also be the result vector
//
// EAX contains address of V1
// EDX contains address of V2
// ECX contains address of VR
var
  Temp: TVector;
asm
  {
    Temp[X] := V1[Y] * V2[Z]-V1[Z] * V2[Y];
    Temp[Y] := V1[Z] * V2[X]-V1[X] * V2[Z];
    Temp[Z] := V1[X] * V2[Y]-V1[Y] * V2[X];
    Result := Temp;
  }

  PUSH    EBX
  LEA     EBX, [Temp]
  FLD     DWORD PTR [EDX+8]
  FLD     DWORD PTR [EDX+4]
  FLD     DWORD PTR [EDX]
  FLD     DWORD PTR [EAX+8]
  FLD     DWORD PTR [EAX+4]
  FLD     DWORD PTR [EAX]
  MOV     [EBX+12], 0

  FLD     ST(1)
  FMUL    ST, ST(6)
  FLD     ST(3)
  FMUL    ST, ST(6)
  FSUBP   ST(1), ST
  FSTP    DWORD PTR [EBX]
  FLD     ST(2)
  FMUL    ST, ST(4)
  FLD     ST(1)
  FMUL    ST, ST(7)
  FSUBP   ST(1), ST
  FSTP    DWORD PTR [EBX+4]
  FLD     ST
  FMUL    ST, ST(5)
  FLD     ST(2)
  FMUL    ST, ST(5)
  FSUBP   ST(1), ST
  FSTP    DWORD PTR [EBX+8]
  FSTP    ST(0)
  FSTP    ST(0)
  FSTP    ST(0)
  FSTP    ST(0)
  FSTP    ST(0)
  FSTP    ST(0)
  MOV     EAX, [EBX]
  MOV     [ECX], EAX
  MOV     EAX, [EBX+4]
  MOV     [ECX+4], EAX
  MOV     EAX, [EBX+8]
  MOV     [ECX+8], EAX
  POP     EBX
end;

function VectorLength(const V: TVector): Single;
// EAX contains address of V
// result is passed in ST(0)
asm
  FLD     DWORD PTR [EAX]
  FMUL    ST, ST
  FLD     DWORD PTR [EAX+4]
  FMUL    ST, ST
  FADDP
  FLD     DWORD PTR [EAX+8]
  FMUL    ST, ST
  FADDP
  FSQRT
end;

function VectorNorm(const V: TVector): Single;
// EAX contains address of V
// result is passed in ST(0)
asm
  FLD     DWORD PTR [EAX];
  FMUL    ST, ST
  FLD     DWORD PTR [EAX+4];
  FMUL    ST, ST
  FADD
  FLD     DWORD PTR [EAX+8];
  FMUL    ST, ST
  FADD
end;

function VectorAngle(const V1, V2: TVector): Single;
// EAX contains address of V1
// EDX contains address of V2
asm
  FLD     DWORD PTR [EAX]
  FLD     ST
  FMUL    ST, ST
  FLD     DWORD PTR [EDX]
  FMUL    ST(2), ST
  FMUL    ST, ST
  FLD     DWORD PTR [EAX + 4]
  FLD     ST
  FMUL    ST, ST
  FADDP   ST(3), ST
  FLD     DWORD PTR [EDX + 4]
  FMUL    ST(1), ST
  FMUL    ST, ST
  FADDP   ST(2), ST
  FADDP   ST(3), ST
  FLD     DWORD PTR [EAX + 8]
  FLD     ST
  FMUL    ST, ST
  FADDP   ST(3), ST
  FLD     DWORD PTR [EDX + 8]
  FMUL    ST(1), ST
  FMUL    ST, ST
  FADDP   ST(2), ST
  FADDP   ST(3), ST
  FMULP
  FSQRT
  FDIVP
end;

procedure ScaleVector3DNow(var V: TVector; const F: Single);
asm
  movd        mm1, [ebp+8]
  punpckldq   mm1, mm1
  movq        mm0, [eax]
  movq        mm2, [eax+8]
  pfmul       mm0, mm1
  pfmul       mm2, mm1
  movq        [eax], mm0
  movq        [eax+8], mm2
  femms
end;

procedure ScaleVector(var V: TVector; const F: Single);
asm
  FLD     DWORD PTR [EAX]
  FMUL    F
  FSTP    DWORD PTR [EAX]
  FLD     DWORD PTR [EAX+4]
  FMUL    F
  FSTP    DWORD PTR [EAX+4]
  FLD     DWORD PTR [EAX+8]
  FMUL    F
  FSTP    DWORD PTR [EAX+8]
end;

procedure VectorScale3DNow(const V: TVector; const F: Single; var VR: TVector);
asm
  movd        mm1, [ebp+8]
  punpckldq   mm1, mm1
  movq        mm0, [eax]
  movq        mm2, [eax+8]
  pfmul       mm0, mm1
  pfmul       mm2, mm1
  movq        [edx], mm0
  movq        [edx+8], mm2
  femms
end;

procedure VectorScale(const V: TVector; const F: Single; var VR: TVector);
asm
  FLD     DWORD PTR [EAX]
  FMUL    F
  FSTP    DWORD PTR [EDX]
  FLD     DWORD PTR [EAX+4]
  FMUL    F
  FSTP    DWORD PTR [EDX+4]
  FLD     DWORD PTR [EAX+8]
  FMUL    F
  FSTP    DWORD PTR [EDX+8]
end;

function VectorDistance(const V1, V2: TVector): Single;
// EAX contains address of v1
// EDX contains highest of v2
// Result  is passed on the stack
asm
  FLD     DWORD PTR [EAX]
  FSUB    DWORD PTR [EDX]
  FMUL    ST, ST
  FLD     DWORD PTR [EAX+4]
  FSUB    DWORD PTR [EDX+4]
  FMUL    ST, ST
  FADD
  FLD     DWORD PTR [EAX+8]
  FSUB    DWORD PTR [EDX+8]
  FMUL    ST, ST
  FADD
  FSQRT
end;

function VectorDistanceSq(const V1, V2: TVector): Single;
// EAX contains address of v1
// EDX contains highest of v2
// Result  is passed on the stack
asm
  FLD     DWORD PTR [EAX]
  FSUB    DWORD PTR [EDX]
  FMUL    ST, ST
  FLD     DWORD PTR [EAX+4]
  FSUB    DWORD PTR [EDX+4]
  FMUL    ST, ST
  FADD
  FLD     DWORD PTR [EAX+8]
  FSUB    DWORD PTR [EDX+8]
  FMUL    ST, ST
  FADD
end;

function IsVectorDistanceWithin(const V1, V2: TVector; const F: Single): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,674 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := VectorDistanceSq(V1, V2) <= F * F;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,674; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure NormalizeVector3DNow(var V: TVector);
asm
  movq        mm0,[eax]
  movd        mm1,[eax+8]
  movq        mm4,mm0
  movq        mm3,mm1
  pfmul       mm0,mm0
  pfmul       mm1,mm1
  pfacc       mm0,mm0
  pfadd       mm0,mm1
  pfrsqrt     mm1,mm0
  movq        mm2,mm1
  pfmul       mm1,mm1
  pfrsqit1    mm1,mm0
  pfrcpit2    mm1,mm2
  punpckldq   mm1,mm1
  pfmul       mm3,mm1
  pfmul       mm4,mm1
  movd        [eax+8],mm3
  movq        [eax],mm4
  femms
end;

procedure NormalizeVector(var V: TVector);
asm
  FLD     DWORD PTR [EAX]
  FMUL    ST, ST
  FLD     DWORD PTR [EAX+4]
  FMUL    ST, ST
  FADD
  FLD     DWORD PTR [EAX+8]
  FMUL    ST, ST
  FADD
  FSQRT
  FLD1
  FDIVR
  FLD     ST
  FMUL    DWORD PTR [EAX]
  FSTP    DWORD PTR [EAX]
  FLD     ST
  FMUL    DWORD PTR [EAX+4]
  FSTP    DWORD PTR [EAX+4]
  FMUL    DWORD PTR [EAX+8]
  FSTP    DWORD PTR [EAX+8]
end;

procedure VectorNormalize3DNow(const V: TVector; var VR: TVector);
asm
  movq        mm0,[eax]
  movd        mm1,[eax+8]
  movq        mm4,mm0
  movq        mm3,mm1
  pfmul       mm0,mm0
  pfmul       mm1,mm1
  pfacc       mm0,mm0
  pfadd       mm0,mm1
  pfrsqrt     mm1,mm0
  movq        mm2,mm1
  pfmul       mm1,mm1
  pfrsqit1    mm1,mm0
  pfrcpit2    mm1,mm2
  punpckldq   mm1,mm1
  pfmul       mm3,mm1
  pfmul       mm4,mm1
  movd        [edx+8],mm3
  movq        [edx],mm4
  femms
end;

procedure VectorNormalize(const V: TVector; var VR: TVector);
asm
  FLD     DWORD PTR [EAX]
  FMUL    ST, ST
  FLD     DWORD PTR [EAX+4]
  FMUL    ST, ST
  FADD
  FLD     DWORD PTR [EAX+8]
  FMUL    ST, ST
  FADD
  FSQRT
  FLD1
  FDIVR
  FLD     ST
  FMUL    DWORD PTR [EAX]
  FSTP    DWORD PTR [EDX]
  FLD     ST
  FMUL    DWORD PTR [EAX+4]
  FSTP    DWORD PTR [EDX+4]
  FMUL    DWORD PTR [EAX+8]
  FSTP    DWORD PTR [EDX+8]
end;

const
  X = 0;
  Y = 1;
  Z = 2;

  IdentityMatrix: TMatrix = (
    (1, 0, 0),
    (0, 1, 0),
    (0, 0, 1)
  );

function CreateScaleMatrix(const V: TVector): TMatrix; register;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,675 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := IdentityMatrix;
  Result[X, X] := V.X;
  Result[Y, Y] := V.Y;
  Result[Z, Z] := V.Z;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,675; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure SinCos(const Theta: Single; var Sine, Cosine: Single);
asm
  FLD     Theta
  FSINCOS
  FSTP    DWORD PTR [EDX]
  FSTP    DWORD PTR [EAX]
end;

function CreateRotationMatrix(Axis: TVector; const Angle: Single): TMatrix; register;
var
  Cosine, Sine, OneMinusCosine: Single;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,676 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  SinCos(Angle, Sine, Cosine);
  OneMinusCosine := 1 - Cosine;
  NormalizeVector(Axis);

  Result[X, X] := (OneMinusCosine * Sqr(Axis.X)) + Cosine;
  Result[X, Y] := (OneMinusCosine * Axis.X * Axis.Y) - (Axis.Z * Sine);
  Result[X, Z] := (OneMinusCosine * Axis.Z * Axis.X) + (Axis.Y * Sine);

  Result[Y, X] := (OneMinusCosine * Axis.X * Axis.Y) + (Axis.Z * Sine);
  Result[Y, Y] := (OneMinusCosine * Sqr(Axis.Y)) + Cosine;
  Result[Y, Z] := (OneMinusCosine * Axis.Y * Axis.Z) - (Axis.X * Sine);

  Result[Z, X] := (OneMinusCosine * Axis.Z * Axis.X) - (Axis.Y * Sine);
  Result[Z, Y] := (OneMinusCosine * Axis.Y * Axis.Z) + (Axis.X * Sine);
  Result[Z, Z] := (OneMinusCosine * Sqr(Axis.Z)) + Cosine;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,676; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure MatrixMultiply3DNow(const M1, M2: TMatrix; var MR: TMatrix);
asm
  xchg        eax, ecx
  movd        mm7,[edx+8]
  movd        mm6,[edx+32]
  punpckldq   mm7,[edx+20]
  movq        mm0,[ecx]
  movd        mm3,[ecx+8]
  movq        mm1,mm0
  pfmul       mm0,mm7
  movq        mm2,mm1
  punpckldq   mm1,mm1
  pfmul       mm1,[edx]
  punpckhdq   mm2,mm2
  pfmul       mm2,[edx+12]
  pfacc       mm0,mm0
  movq        mm4,mm3
  punpckldq   mm3,mm3
  pfmul       mm3,[edx+24]
  pfadd       mm2,mm1
  pfmul       mm4,mm6
  movq        mm5,[ecx+12]
  pfadd       mm2,mm3
  movd        mm3,[ecx+20]
  pfadd       mm4,mm0
  movq        mm1,mm5
  movq        [eax],mm2
  pfmul       mm5,mm7
  movd        [eax+8],mm4
  movq        mm2,mm1
  punpckldq   mm1,mm1
  movq        mm0,[ecx+24]
  pfmul       mm1,[edx]
  punpckhdq   mm2,mm2
  pfmul       mm2,[edx+12]
  pfacc       mm5,mm5
  movq        mm4,mm3
  punpckldq   mm3,mm3
  pfmul       mm3,[edx+24]
  pfadd       mm2,mm1
  pfmul       mm4,mm6
  movq        mm1,mm0
  pfadd       mm2,mm3
  movd        mm3,[ecx+32]
  pfadd       mm4,mm5
  pfmul       mm0,mm7
  movq        [eax+12],mm2
  movq        mm2,mm1
  movd        [eax+20],mm4
  punpckldq   mm1,mm1
  pfmul       mm1,[edx]
  punpckhdq   mm2,mm2
  pfmul       mm2,[edx+12]
  pfacc       mm0,mm0
  pfmul       mm6,mm3
  punpckldq   mm3,mm3
  pfmul       mm3,[edx+24]
  pfadd       mm2,mm1
  pfadd       mm6,mm0
  pfadd       mm2,mm3
  movd        [eax+32],mm6
  movq        [eax+24],mm2
  femms
end;

procedure MatrixMultiply(const M1, M2: TMatrix; var MR: TMatrix);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,677 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  MR[X, X] := M1[X, X] * M2[X, X] + M1[X, Y] * M2[Y, X] + M1[X, Z] * M2[Z, X];
  MR[X, Y] := M1[X, X] * M2[X, Y] + M1[X, Y] * M2[Y, Y] + M1[X, Z] * M2[Z, Y];
  MR[X, Z] := M1[X, X] * M2[X, Z] + M1[X, Y] * M2[Y, Z] + M1[X, Z] * M2[Z, Z];
  MR[Y, X] := M1[Y, X] * M2[X, X] + M1[Y, Y] * M2[Y, X] + M1[Y, Z] * M2[Z, X];
  MR[Y, Y] := M1[Y, X] * M2[X, Y] + M1[Y, Y] * M2[Y, Y] + M1[Y, Z] * M2[Z, Y];
  MR[Y, Z] := M1[Y, X] * M2[X, Z] + M1[Y, Y] * M2[Y, Z] + M1[Y, Z] * M2[Z, Z];
  MR[Z, X] := M1[Z, X] * M2[X, X] + M1[Z, Y] * M2[Y, X] + M1[Z, Z] * M2[Z, X];
  MR[Z, Y] := M1[Z, X] * M2[X, Y] + M1[Z, Y] * M2[Y, Y] + M1[Z, Z] * M2[Z, Y];
  MR[Z, Z] := M1[Z, X] * M2[X, Z] + M1[Z, Y] * M2[Y, Z] + M1[Z, Z] * M2[Z, Z];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,677; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure VectorTransform3DNow(const V: TVector; const M: TMatrix; var VR: TVector);
asm
  movq        mm0,[eax]
  movd        mm1,[eax+8]
  movd        mm4,[edx+8]
  movq        mm3,mm0
  movd        mm2,[edx+32]
  punpckldq   mm0,mm0
  punpckldq   mm4,[edx+20]
  pfmul       mm0,[edx]
  punpckhdq   mm3,mm3
  pfmul       mm2,mm1
  punpckldq   mm1,mm1
  pfmul       mm4,[eax]
  pfmul       mm3,[edx+12]
  pfmul       mm1,[edx+24]
  pfacc       mm4,mm4
  pfadd       mm3,mm0
  pfadd       mm4,mm2
  pfadd       mm3,mm1
  movd        [ecx+8],mm4
  movq        [ecx],mm3
  femms
end;

procedure VectorTransform(const V: TVector; const M: TMatrix; var VR: TVector);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,678 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  VR.X := V.X * M[X, X] + V.Y * M[Y, X] + V.Z * M[Z, X];
  VR.Y := V.X * M[X, Y] + V.Y * M[Y, Y] + V.Z * M[Z, Y];
  VR.Z := V.X * M[X, Z] + V.Y * M[Y, Z] + V.Z * M[Z, Z];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,678; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function MatrixDeterminant(const M: TMatrix): Single;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,679 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result:=  M[X, X] * (M[Y, Y] * M[Z, Z] - M[Z, Y] * M[Y, Z])
          - M[X, Y] * (M[Y, X] * M[Z, Z] - M[Z, X] * M[Y, Z])
          + M[X, Z] * (M[Y, X] * M[Z, Y] - M[Z, X] * M[Y, Y]);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,679; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure ScaleMatrix3DNow(var M: TMatrix; const F: Single);
asm
  movd mm0, F
  punpckldq mm0, mm0
  movq mm1, [EAX]
  movq mm2, [EAX+8]
  movq mm3, [EAX+16]
  pfmul mm1, mm0
  pfmul mm2, mm0
  movq mm4, [EAX+24]
  pfmul mm3, mm0
  movd mm5, [EAX+32]
  movq [EAX], mm1
  movq [EAX+8], mm2
  pfmul mm4, mm0
  pfmul mm5, mm0
  movq [EAX+16], mm3
  movq [EAX+24], mm4
  movd [EAX+32], mm5
  femms
end;

procedure ScaleMatrix(var M: TMatrix; const F: Single);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,680 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  M[X, X] := M[X, X] * F;
  M[X, Y] := M[X, Y] * F;
  M[X, Z] := M[X, Z] * F;
  M[Y, X] := M[Y, X] * F;
  M[Y, Y] := M[Y, Y] * F;
  M[Y, Z] := M[Y, Z] * F;
  M[Z, X] := M[Z, X] * F;
  M[Z, Y] := M[Z, Y] * F;
  M[Z, Z] := M[Z, Z] * F;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,680; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TransposeMatrix(var M: TMatrix);
var
  F: Single;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,681 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  F := M[X, Y];
  M[X, Y] := M[Y, X];
  M[Y, X] := F;
  F := M[X, Z];
  M[X, Z] := M[Z, X];
  M[Z, X] := F;
  F := M[Y, Z];
  M[Y, Z] := M[Z, Y];
  M[Z, Y] := F;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,681; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

const
  IdentityQuaternion: TQuaternion = (
    RealPart: 1;
    ImagPart:(
      0,
      0,
      0
    );
  );

function QuaternionMake(const Imag, Imag2, Imag3, Real: Single): TQuaternion;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,682 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result.ImagPart[0] := Imag;
  Result.ImagPart[1] := Imag2;
  Result.ImagPart[2] := Imag3;
  Result.RealPart := Real;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,682; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function QuaternionConjugate(const Q: TQuaternion): TQuaternion;
// EAX contains address of Q
// EDX contains address of result
asm
  MOV     ECX, [EAX]
  MOV     [EDX], ECX
  FLD     DWORD PTR [EAX+4]
  FCHS
  FSTP    DWORD PTR [EDX+4]
  FLD     DWORD PTR [EAX+8]
  FCHS
  FSTP    DWORD PTR [EDX+8]
  FLD     DWORD PTR [EAX+12]
  FCHS
  FSTP    DWORD PTR [EDX+12]
end;

function QuaternionMagnitude(const Q: TQuaternion): Single;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,683 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := Sqrt(VectorNorm(Q.Vector) + Sqr(Q.RealPart));
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,683; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure NormalizeQuaternion(var Q: TQuaternion);
const
  EPSILON = 1e-30;
var
  M, F: Single;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,684 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  M := QuaternionMagnitude(Q);
  if M > EPSILON then
  begin
    F := 1 / M;
    ScaleVector(Q.Vector, F);
    Q.RealPart := Q.RealPart * F;
  end else Q := IdentityQuaternion;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,684; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure QuaternionToMatrix(Q: TQuaternion; var M: TMatrix);
var
   w, x, y, z, xx, xy, xz, xw, yy, yz, yw, zz, zw: Single;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,685 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
   NormalizeQuaternion(Q);
   w := Q.RealPart;
   x := Q.ImagPart[0];
   y := Q.ImagPart[1];
   z := Q.ImagPart[2];
   xx := x * x;
   xy := x * y;
   xz := x * z;
   xw := x * w;
   yy := y * y;
   yz := y * z;
   yw := y * w;
   zz := z * z;
   zw := z * w;
   M[0, 0] := 1 - 2 * (yy + zz);
   M[1, 0] :=     2 * (xy - zw);
   M[2, 0] :=     2 * (xz + yw);
   M[0, 1] :=     2 * (xy + zw);
   M[1, 1] := 1 - 2 * (xx + zz);
   M[2, 1] :=     2 * (yz - xw);
   M[0, 2] :=     2 * (xz - yw);
   M[1, 2] :=     2 * (yz + xw);
   M[2, 2] := 1 - 2 * (xx + yy);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,685; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function QuaternionFromPoints(const V1, V2: TVector): TQuaternion;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,686 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  VectorCrossProduct(V1, V2, Result.Vector);
  Result.RealPart := Sqrt((VectorDotProduct(V1, V2) + 1) * 0.5);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,686; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure QuaternionMultiply(const qL, qR: TQuaternion; var qRes: TQuaternion);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,687 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  qRes.RealPart := qL.RealPart * qR.RealPart - qL.ImagPart[X] * qR.ImagPart[X] -
                   qL.ImagPart[Y] * qR.ImagPart[Y] - qL.ImagPart[Z] * qR.ImagPart[Z];
  qRes.ImagPart[X] := qL.RealPart * qR.ImagPart[X] + qL.ImagPart[X] * qR.RealPart +
                      qL.ImagPart[Y] * qR.ImagPart[Z] - qL.ImagPart[Z] * qR.ImagPart[Y];
  qRes.ImagPart[Y] := qL.RealPart * qR.ImagPart[Y] + qL.ImagPart[Y] * qR.RealPart +
                      qL.ImagPart[Z] * qR.ImagPart[X] - qL.ImagPart[X] * qR.ImagPart[Z];
  qRes.ImagPart[Z] := qL.RealPart * qR.ImagPart[Z] + qL.ImagPart[Z] * qR.RealPart +
                      qL.ImagPart[X] * qR.ImagPart[Y] - qL.ImagPart[Y] * qR.ImagPart[X];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,687; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function QuaternionSlerp(const QStart, QEnd: TQuaternion; Spin: Integer; T: Single): TQuaternion;
const
  EPSILON = 1e-40;
var
  Beta,                   // complementary interp parameter
  Theta,                  // Angle between A and B
  SinT, CosT,             // sine, cosine of theta
  Phi: Single;            // theta plus spins
  BFlip: Boolean;         // use negativ t?
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,688 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  // cosine theta
  CosT := VectorAngle(QStart.Vector, QEnd.Vector);

  // if QEnd is on opposite hemisphere from QStart, use -QEnd instead
  if CosT < 0 then
  begin
    CosT := -CosT;
    BFlip := True;
  end else BFlip := False;

  // if QEnd is (within precision limits) the same as QStart,
  // just linear interpolate between QStart and QEnd.
  // Can't do spins, since we don't know what direction to spin.

  if (1 - CosT) < EPSILON then
  begin
    Beta := 1 - T;
  end else
  begin
    // normal case
    Theta := ArcCos(CosT);
    Phi := Theta + Spin * Pi;
    SinT := Sin(Theta);
    Beta := Sin(Theta - T * Phi) / SinT;
    T := Sin(T * Phi) / SinT;
  end;

  if BFlip then T := -T;

  // interpolate
  Result.ImagPart[X] := Beta * QStart.ImagPart[X] + T * QEnd.ImagPart[X];
  Result.ImagPart[Y] := Beta * QStart.ImagPart[Y] + T * QEnd.ImagPart[Y];
  Result.ImagPart[Z] := Beta * QStart.ImagPart[Z] + T * QEnd.ImagPart[Z];
  Result.RealPart := Beta * QStart.RealPart + T * QEnd.RealPart;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,688; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure QuaternionToPoints(const Q: TQuaternion; var ArcFrom, ArcTo: TVector);
var
  S: Single;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,689 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  S := Sqrt(Q.ImagPart[X] * Q.ImagPart[X] + Q.ImagPart[Y] * Q.ImagPart[Y]);
  if S = 0 then
  begin
    MakeVector(ArcFrom, 0, 1, 0)
  end else
  begin
    MakeVector(ArcFrom, -Q.ImagPart[Y] / S, Q.ImagPart[X] / S, 0);
  end;
  ArcTo.X := Q.RealPart * ArcFrom.X - Q.ImagPart[Z] * ArcFrom.Y;
  ArcTo.Y := Q.RealPart * ArcFrom.Y + Q.ImagPart[Z] * ArcFrom.X;
  ArcTo.Z := Q.ImagPart[X] * ArcFrom.Y - Q.ImagPart[Y] * ArcFrom.X;
  if Q.RealPart < 0 then
  begin
    MakeVector(ArcFrom, -ArcFrom.X, -ArcFrom.Y, 0);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,689; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function CreateSphereVolume(const Center: TVector; const Radius: Single): TBoundingVolume;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,690 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result.VolumeType := bvtSphere;
  New(Result.Sphere);
  Result.Sphere^.Center := Center;
  Result.Sphere^.Radius := Radius;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,690; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function CreateBoxVolume(const Min, Max: TVector): TBoundingVolume;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,691 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result.VolumeType := bvtBox;
  New(Result.Box);
  Result.Box^.Min := Min;
  Result.Box^.Max := Max;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,691; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function CreateSphereTreeVolume(const Centers: array of TVector; const RadiusArr: array of Single): TBoundingVolume;
var
  I: Integer;
  Tmp: PSphere;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,692 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Assert(High(Centers) = High(RadiusArr));
  Result.VolumeType := bvtSphereList;
  New(Result.SphereList);
  Result.SphereList^.Detail := High(Centers);
  GetMem(Result.SphereList^.Spheres, High(Centers) * SizeOf(TSphere));
  Tmp := Result.SphereList^.Spheres;
  for I := 0 to High(Centers) do
  begin
    Tmp^.Center := Centers[I];
    Tmp^.Radius := RadiusArr[I];
    Inc(Tmp);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,692; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function CreateBoxTreeVolume(const Mins, Maxs: array of TVector): TBoundingVolume;
var
  I: Integer;
  Tmp: PAABB;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,693 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Assert(High(Mins) = High(Maxs));
  Result.VolumeType := bvtBoxList;
  New(Result.BoxList);
  Result.SphereList^.Detail := High(Mins);
  GetMem(Result.BoxList^.Boxes, High(Mins) * SizeOf(TAABB));
  Tmp := Result.BoxList^.Boxes;
  for I := 0 to High(Mins) do
  begin
    Tmp^.Min := Mins[I];
    Tmp^.Max := Maxs[I];
    Inc(Tmp);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,693; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure DestroyBoundingVolume(const Vol: TBoundingVolume);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,694 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Vol.Data = nil then Exit;
  case Vol.VolumeType of
    bvtSphere: Dispose(Vol.Sphere);
    bvtBox: Dispose(Vol.Box);
    bvtSphereList:
    begin
      Dispose(Vol.SphereList^.Spheres);
      Dispose(Vol.SphereList);
    end;
    bvtBoxList:
    begin
      Dispose(Vol.BoxList^.Boxes);
      Dispose(Vol.BoxList);
    end;
  else
    FreeMem(Vol.Data);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,694; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BoxIntersectsBox(const B1, B2: TAABB): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,695 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (B1.Min.X > B2.Max.X) or
     (B1.Min.Y > B2.Max.Y) or
     (B1.Min.Z > B2.Max.Z) or
     (B2.Min.X > B1.Max.X) or
     (B2.Min.Y > B1.Max.Y) or
     (B2.Min.Z > B1.Max.Z) then
  begin
    Result := False;
  end else
  begin
    Result := True;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,695; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BoxIntersectsBoxList(const B: TAABB; const BL: TAABBTree): Boolean;
var
  I: Integer;
  B2: PAABB;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,696 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  B2 := BL.Boxes;
  for I := 0 to BL.Detail -1 do
  begin
    Result := BoxIntersectsBox(B, B2^);
    if Result then Exit;
    Inc(B2);
  end;
  Result := False;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,696; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BoxIntersectsSphere(Const B: TAABB; const S: TSphere): Boolean;
var
  Tmp: Single;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,697 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Tmp := 0;
  if S.Center.X < B.Min.X then
  begin
    Tmp := S.Center.X - B.Min.X;
  end else if S.Center.X <> B.Min.X then
  begin
    Tmp := S.Center.X - B.Max.X;
  end;

  if S.Center.Y < B.Min.Y then
  begin
    Tmp := Tmp + S.Center.Y - B.Min.Y;
  end else if S.Center.Y <> B.Min.Y then
  begin
    Tmp := Tmp + S.Center.Y - B.Max.Y;
  end;

  if S.Center.Z < B.Min.Z then
  begin
    Tmp := Tmp + S.Center.Z - B.Min.Z;
  end else if S.Center.Z <> B.Min.Z then
  begin
    Tmp := Tmp + S.Center.Z - B.Max.Z;
  end;

  Result := Tmp <= S.Radius;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,697; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BoxIntersectsSphereList(const B: TAABB; const SL: TSphereTree): Boolean;
var
  I: Integer;
  S: PSphere;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,698 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  S := SL.Spheres;
  for I := 0 to SL.Detail -1 do
  begin
    Result := BoxIntersectsSphere(B, S^);
    if Result then Exit;
    Inc(S);
  end;
  Result := False;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,698; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function BoxListIntersectsBoxList(const BL1, BL2: TAABBTree): Boolean;
var
  I, J: Integer;
  B1, B2: PAABB;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,699 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  B1 := BL1.Boxes;
  for I := 0 to BL1.Detail -1 do
  begin
    B2 := BL2.Boxes;
    for J := 0 to BL2.Detail -1 do
    begin
      Result := BoxIntersectsBox(B1^, B2^);
      if Result then Exit;
      Inc(B2);
    end;
    Inc(B1);
  end;
  Result := False;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,699; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function SphereIntersectsSphere(const S1, S2: TSphere): Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,700 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := VectorDistanceSq(S1.Center, S2.Center) < Sqr(S1.Radius + S2.Radius);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,700; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function SphereIntersectsSphereList(const S: TSphere; const SL: TSphereTree): Boolean;
var
  I: Integer;
  S2: PSphere;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,701 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  S2 := SL.Spheres;
  for I := 0 to SL.Detail -1 do
  begin
    Result := SphereIntersectsSphere(S, S2^);
    if Result then Exit;
    Inc(S2);
  end;
  Result := False;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,701; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function SphereIntersectsBoxList(const S: TSphere; const BL: TAABBTree): Boolean;
var
  I: Integer;
  B: PAABB;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,702 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  B := BL.Boxes;
  for I := 0 to BL.Detail -1 do
  begin
    Result := BoxIntersectsSphere(B^, S);
    if Result then Exit;
    Inc(B);
  end;
  Result := False;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,702; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function SphereListIntersectsSphereList(const SL1, SL2: TSphereTree): Boolean;
var
  I, J: Integer;
  S1, S2: PSphere;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,703 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  S1 := SL1.Spheres;
  for I := 0 to SL1.Detail -1 do
  begin
    S2 := SL2.Spheres;
    for J := 0 to SL2.Detail -1 do
    begin
      Result := SphereIntersectsSphere(S1^, S2^);
      if Result then Exit;
      Inc(S2);
    end;
    Inc(S1);
  end;
  Result := False;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,703; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function SphereListIntersectsBoxList(const SL: TSphereTree; const BL: TAABBTree): Boolean;
var
  I, J: Integer;
  S: PSphere;
  B: PAABB;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,704 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  S := SL.Spheres;
  for I := 0 to SL.Detail -1 do
  begin
    B := BL.Boxes;
    for J := 0 to BL.Detail -1 do
    begin
      Result := BoxIntersectsSphere(B^, S^);
      if Result then Exit;
      Inc(B);
    end;
    Inc(S);
  end;
  Result := False;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,704; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function VolumesIntersect(const Vol1, Vol2: TBoundingVolume): Boolean;
const
  COLLIDE_NONE                       = -1;

  COLLIDE_SPHERE_SPHERE              = 0;
  COLLIDE_SPHERE_BOX                 = 1;
  COLLIDE_SPHERE_SPHERE_LIST         = 2;
  COLLIDE_SPHERE_BOX_LIST            = 3;

  COLLIDE_BOX_SPHERE                 = 4;
  COLLIDE_BOX_BOX                    = 5;
  COLLIDE_BOX_SPHERE_LIST            = 6;
  COLLIDE_BOX_BOX_LIST               = 7;

  COLLIDE_SPHERE_LIST_SPHERE         = 8;
  COLLIDE_SPHERE_LIST_BOX            = 9;
  COLLIDE_SPHERE_LIST_SPHERE_LIST    = 10;
  COLLIDE_SPHERE_LIST_BOX_LIST       = 11;

  COLLIDE_BOX_LIST_SPHERE            = 12;
  COLLIDE_BOX_LIST_BOX               = 13;
  COLLIDE_BOX_LIST_SPHERE_LIST       = 14;
  COLLIDE_BOX_LIST_BOX_LIST          = 15;

  CollisionTestTable: array[TBoundingVolumeType, TBoundingVolumeType] of Integer = (
    (
      COLLIDE_NONE,
      COLLIDE_NONE,
      COLLIDE_NONE,
      COLLIDE_NONE,
      COLLIDE_NONE
    ),
    (
      COLLIDE_NONE,
      COLLIDE_SPHERE_SPHERE,
      COLLIDE_SPHERE_BOX,
      COLLIDE_SPHERE_SPHERE_LIST,
      COLLIDE_SPHERE_BOX_LIST
    ),
    (
      COLLIDE_NONE,
      COLLIDE_BOX_SPHERE,
      COLLIDE_BOX_BOX,
      COLLIDE_BOX_SPHERE_LIST,
      COLLIDE_BOX_BOX_LIST
    ),
    (
      COLLIDE_NONE,
      COLLIDE_SPHERE_LIST_SPHERE,
      COLLIDE_SPHERE_LIST_BOX,
      COLLIDE_SPHERE_LIST_SPHERE_LIST,
      COLLIDE_SPHERE_LIST_BOX_LIST
    ),
    (
      COLLIDE_NONE,
      COLLIDE_BOX_LIST_SPHERE,
      COLLIDE_BOX_LIST_BOX,
      COLLIDE_BOX_LIST_SPHERE_LIST,
      COLLIDE_BOX_LIST_BOX_LIST
    )
  );
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,705 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Vol1.Data = nil) or (Vol2.Data = nil) then
  begin
    Result := False;
    Exit;
  end;

  case CollisionTestTable[Vol1.VolumeType, Vol2.VolumeType] of
    COLLIDE_SPHERE_SPHERE:
    begin
      Result := SphereIntersectsSphere(Vol1.Sphere^, Vol2.Sphere^);
    end;
    COLLIDE_SPHERE_BOX:
    begin
      Result := BoxIntersectsSphere(Vol2.Box^, Vol1.Sphere^);
    end;
    COLLIDE_SPHERE_SPHERE_LIST:
    begin
      Result := SphereIntersectsSphereList(Vol1.Sphere^, Vol2.SphereList^);
    end;
    COLLIDE_SPHERE_BOX_LIST:
    begin
      Result := SphereIntersectsBoxList(Vol1.Sphere^, Vol2.BoxList^);
    end;

    COLLIDE_BOX_SPHERE:
    begin
      Result := BoxIntersectsSphere(Vol1.Box^, Vol2.Sphere^);
    end;
    COLLIDE_BOX_BOX:
    begin
      Result := BoxIntersectsBox(Vol1.Box^, Vol2.Box^);
    end;
    COLLIDE_BOX_SPHERE_LIST:
    begin
      Result := BoxIntersectsSphereList(Vol1.Box^, Vol2.SphereList^);
    end;
    COLLIDE_BOX_BOX_LIST:
    begin
      Result := BoxIntersectsBoxList(Vol1.Box^, Vol2.BoxList^);
    end;

    COLLIDE_SPHERE_LIST_SPHERE:
    begin
      Result := SphereIntersectsSphereList(Vol2.Sphere^, Vol1.SphereList^);
    end;
    COLLIDE_SPHERE_LIST_BOX:
    begin
      Result := BoxIntersectsSphereList(Vol2.Box^, Vol1.SphereList^);
    end;
    COLLIDE_SPHERE_LIST_SPHERE_LIST:
    begin
      Result := SphereListIntersectsSphereList(Vol1.SphereList^, Vol2.SphereList^);
    end;
    COLLIDE_SPHERE_LIST_BOX_LIST:
    begin
      Result := SphereListIntersectsBoxList(Vol1.SphereList^, Vol2.BoxList^);
    end;

    COLLIDE_BOX_LIST_SPHERE:
    begin
      Result := SphereIntersectsBoxList(Vol2.Sphere^, Vol1.BoxList^);
    end;
    COLLIDE_BOX_LIST_BOX:
    begin
      Result := BoxIntersectsBoxList(Vol2.Box^, Vol1.BoxList^);
    end;
    COLLIDE_BOX_LIST_SPHERE_LIST:
    begin
      Result := SphereListIntersectsBoxList(Vol2.SphereList^, Vol1.BoxList^);
    end;
    COLLIDE_BOX_LIST_BOX_LIST:
    begin
      Result := BoxListIntersectsBoxList(Vol1.BoxList^, Vol2.BoxList^);
    end;
  else
    Result := False;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,705; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function PackSingle(const F: Single): Word;
var
  Value: Longword absolute F;
  T1, T2, T3: Longword;
  T4: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,706 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  T1 := (Value and $80000000) shr 16;
  T2 := Value and $7FFFFFFF;
  if T2 > $47FFEFFF then
  begin
    Result := Word(T1 or $7FFF);
  end else if T2 < $38800000 then
  begin
    T3 := (T2 and $7FFFFF) or $800000;
    T4 := $71 - Integer(T2 shr 23);
    if T4 > $1F then
    begin
      T2 := 0;
    end else
    begin
      T2 := T3 shr Byte(T4);
    end;
    Result := Word(T1 or (((T2 + $0FFF) + ((T2 shr 13) and 1)) shr 13));
  end else
  begin
    Result := Word(T1 or (((T2 + $C8000FFF) + ((T2 shr 13) and 1)) shr 13));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,706; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function UnpackSingle(V: Word): Single;
var
  Value: Longword absolute Result;
  T1, T2: Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,707 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (V and $7FFF) = $7FFF then
  begin
    if (V and $8000) = 0 then
    begin
      Result := Infinity;
    end else
    begin
      Result := NegInfinity;
    end;
  end else if (V and $7C00) = 0 then
  begin
    T1 := V and $03FF;
    if T1 <> 0 then
    begin
      T2 := $FFFFFFF2;
      while (T1 and $0400) = 0 do
      begin
        Dec(T2);
        T1 := T1 shl 1;
      end;
      T1 := T1 and $FFFFFBFF;
      Value := Longword(((Value and $8000) shl 16) or ((T2 + $7F) shl 23) or (T1 shl 13));
    end else
    begin
      Value := Longword((Value and $8000) shl 16);
    end;
  end else
  begin
    Value := Longword(((Longword((V and $8000)) shl 16) or (((((V shr 10) and $1F) - Longword(15)) + $7F) shl 23)) or ((V and $03FF) shl 13));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,707; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

end.
