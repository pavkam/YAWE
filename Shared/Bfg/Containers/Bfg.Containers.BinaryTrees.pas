{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Binary Tree Manipulation
  
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
unit Bfg.Containers.BinaryTrees;

interface

uses
  SysUtils,
  Bfg.Utils,
  Bfg.Containers.Interfaces,
  Bfg.Algorithm{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

type
  TTreeColor = (tcBlack, tcRed);

  TStrHashFunction = function(const S: string): Integer;

  PIntfBinaryNode = ^TIntfBinaryNode;
  TIntfBinaryNode = record
    Obj: IInterface;
    Left: PIntfBinaryNode;
    Right: PIntfBinaryNode;
    Parent: PIntfBinaryNode;
    Color: TTreeColor;
  end;

  PStrBinaryNode = ^TStrBinaryNode;
  TStrBinaryNode = record
    Str: string;
    Left: PStrBinaryNode;
    Right: PStrBinaryNode;
    Parent: PStrBinaryNode;
    Color: TTreeColor;
  end;

  PStrHashBinaryNode = ^TStrHashBinaryNode;
  TStrHashBinaryNode = record
    Str: string;
    Hash: Integer;
    Left: PStrHashBinaryNode;
    Right: PStrHashBinaryNode;
    Parent: PStrHashBinaryNode;
    Color: TTreeColor;
  end;

  PPtrBinaryNode = ^TPtrBinaryNode;
  TPtrBinaryNode = record
    Ptr: Pointer;
    Left: PPtrBinaryNode;
    Right: PPtrBinaryNode;
    Parent: PPtrBinaryNode;
    Color: TTreeColor;
  end;

  PBinaryNode = ^TBinaryNode;
  TBinaryNode = record
    Obj: TObject;
    Left: PBinaryNode;
    Right: PBinaryNode;
    Parent: PBinaryNode;
    Color: TTreeColor;
  end;

  TIntfBinaryTree = class(TAbstractContainer, IIntfCollection, IIntfTree, ICloneable)
  private
    FComparator: TInterfaceCompare;
    FCount: Integer;
    FRoot: PIntfBinaryNode;
    FTraverseOrder: TTraverseOrder;
    function DoCompare(const I1, I2: IInterface): Integer; inline;
    procedure RotateLeft(Node: PIntfBinaryNode);
    procedure RotateRight(Node: PIntfBinaryNode);
  public
    { IIntfCollection }
    function Add(const AInterface: IInterface): Boolean;
    procedure AddAll(const ACollection: IIntfCollection);
    procedure Clear;
    function Contains(const AInterface: IInterface): Boolean;
    function ContainsAll(const ACollection: IIntfCollection): Boolean;
    function Equals(const ACollection: IIntfCollection): Boolean;
    function First: IIntfIterator;
    function IsEmpty: Boolean;
    function Last: IIntfIterator;
    function Remove(const AInterface: IInterface): Boolean;
    procedure RemoveAll(const ACollection: IIntfCollection);
    procedure RetainAll(const ACollection: IIntfCollection);
    function Size: Integer;
    { IIntfTree }
    function GetTraverseOrder: TTraverseOrder;
    procedure SetTraverseOrder(Value: TTraverseOrder);
    { ICloneable }
    function Clone: TObject;
  public
    constructor Create(AComparator: TInterfaceCompare = nil);
    destructor Destroy; override;
  end;

  TStrBinaryTree = class(TAbstractContainer, IStrCollection, IStrTree, ICloneable)
  private
    FComparator: TStringCompare;
    FCount: Integer;
    FRoot: PStrBinaryNode;
    FTraverseOrder: TTraverseOrder;
    FCaseSensitive: Boolean;
    function DoCompare(const S1, S2: string): Integer; inline;
    procedure RotateLeft(Node: PStrBinaryNode);
    procedure RotateRight(Node: PStrBinaryNode);
  public
    { IStrCollection }
    function Add(const AString: string): Boolean;
    procedure AddAll(const ACollection: IStrCollection);
    procedure Clear;
    function Contains(const AString: string): Boolean;
    function ContainsAll(const ACollection: IStrCollection): Boolean;
    function Equals(const ACollection: IStrCollection): Boolean;
    function First: IStrIterator;
    function IsEmpty: Boolean;
    function Last: IStrIterator;
    function Remove(const AString: string): Boolean;
    procedure RemoveAll(const ACollection: IStrCollection);
    procedure RetainAll(const ACollection: IStrCollection);
    function Size: Integer;
    procedure SetCaseSensitivity(Value: Boolean);
    function GetCaseSensitivity: Boolean;
    { IStrTree }
    function GetTraverseOrder: TTraverseOrder;
    procedure SetTraverseOrder(Value: TTraverseOrder);
    { ICloneable }
    function Clone: TObject;
  public
    constructor Create(AComparator: TStringCompare = nil);
    destructor Destroy; override;
  end;

  THashedStrBinaryTree = class(TAbstractContainer, IStrCollection, IStrTree, ICloneable)
  private
    FHashFunction: TStrHashFunction;
    FCount: Integer;
    FRoot: PStrHashBinaryNode;
    FTraverseOrder: TTraverseOrder;
    FCaseSensitive: Boolean;
    function DoCompare(H1, H2: Integer; const S1, S2: string): Integer; inline;
    function HashStr(const S: string): Integer; inline;
    procedure RotateLeft(Node: PStrHashBinaryNode);
    procedure RotateRight(Node: PStrHashBinaryNode);
  public
    { IStrCollection }
    function Add(const AString: string): Boolean;
    procedure AddAll(const ACollection: IStrCollection);
    procedure Clear;
    function Contains(const AString: string): Boolean;
    function ContainsAll(const ACollection: IStrCollection): Boolean;
    function Equals(const ACollection: IStrCollection): Boolean;
    function First: IStrIterator;
    function IsEmpty: Boolean;
    function Last: IStrIterator;
    function Remove(const AString: string): Boolean;
    procedure RemoveAll(const ACollection: IStrCollection);
    procedure RetainAll(const ACollection: IStrCollection);
    function Size: Integer;
    procedure SetCaseSensitivity(Value: Boolean);
    function GetCaseSensitivity: Boolean;
    { IStrTree }
    function GetTraverseOrder: TTraverseOrder;
    procedure SetTraverseOrder(Value: TTraverseOrder);
    { ICloneable }
    function Clone: TObject;
  public
    constructor Create(AHashFunction: TStrHashFunction = nil);
    destructor Destroy; override;
  end;

  TPtrBinaryTree = class(TAbstractContainer, IPtrCollection, IPtrTree, ICloneable)
  private
    FComparator: TPointerCompare;
    FCount: Integer;
    FRoot: PPtrBinaryNode;
    FTraverseOrder: TTraverseOrder;
    function DoCompare(P1, P2: Pointer): Integer; inline;
    procedure RotateLeft(Node: PPtrBinaryNode);
    procedure RotateRight(Node: PPtrBinaryNode);
  public
    { IPtrCollection }
    function Add(APtr: Pointer): Boolean;
    procedure AddAll(const ACollection: IPtrCollection);
    procedure Clear;
    function Contains(APtr: Pointer): Boolean;
    function ContainsAll(const ACollection: IPtrCollection): Boolean;
    function Equals(const ACollection: IPtrCollection): Boolean;
    function First: IPtrIterator;
    function IsEmpty: Boolean;
    function Last: IPtrIterator;
    function Remove(APtr: Pointer): Boolean;
    procedure RemoveAll(const ACollection: IPtrCollection);
    procedure RetainAll(const ACollection: IPtrCollection);
    function Size: Integer;
    { IPtrTree }
    function GetTraverseOrder: TTraverseOrder;
    procedure SetTraverseOrder(Value: TTraverseOrder);
    { ICloneable }
    function Clone: TObject;
  public
    constructor Create(AComparator: TPointerCompare = nil);
    destructor Destroy; override;
  end;

  TBinaryTree = class(TAbstractContainer, ICollection, ITree,
    ICloneable)
  private
    FComparator: TObjectCompare;
    FCount: Integer;
    FRoot: PBinaryNode;
    FTraverseOrder: TTraverseOrder;
    function DoCompare(O1, O2: TObject): Integer; inline;
    procedure RotateLeft(Node: PBinaryNode);
    procedure RotateRight(Node: PBinaryNode);
  public
    { ICollection }
    function Add(AObject: TObject): Boolean;
    procedure AddAll(const ACollection: ICollection);
    procedure Clear;
    function Contains(AObject: TObject): Boolean;
    function ContainsAll(const ACollection: ICollection): Boolean;
    function Equals(const ACollection: ICollection): Boolean;
    function First: IIterator;
    function IsEmpty: Boolean;
    function Last: IIterator;
    function Remove(AObject: TObject): Boolean;
    procedure RemoveAll(const ACollection: ICollection);
    procedure RetainAll(const ACollection: ICollection);
    function Size: Integer;
    { ITree }
    function GetTraverseOrder: TTraverseOrder;
    procedure SetTraverseOrder(Value: TTraverseOrder);
    { ICloneable }
    function Clone: TObject;
  public
    constructor Create(AComparator: TObjectCompare = nil);
    destructor Destroy; override;
  end;

implementation

uses
  Bfg.Resources;

//=== { TIntfItr } ===========================================================

type
  TIntfItr = class(TAbstractContainer, IIntfIterator)
  private
    FCursor: PIntfBinaryNode;
    FOwnList: TIntfBinaryTree;
    FLastRet: PIntfBinaryNode;
  protected
    { IIntfIterator }
    function GetIntf: IInterface;
    function HasNext: Boolean;
    function HasPrevious: Boolean;
    function Next: IInterface;
    function Previous: IInterface;
  public
    constructor Create(OwnList: TIntfBinaryTree; Start: PIntfBinaryNode);
  end;

constructor TIntfItr.Create(OwnList: TIntfBinaryTree; Start: PIntfBinaryNode);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1463 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FCursor := Start;
  FOwnList := OwnList;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1463; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfItr.GetIntf: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1464 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Obj;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1464; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1465 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor <> nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1465; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1466 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor <> nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1466; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfItr.Next: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1467 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1467; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfItr.Previous: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1468 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1468; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TPreOrderIntfItr } ===================================================

type
  TPreOrderIntfItr = class(TIntfItr, IIntfIterator)
  protected
    { IIntfIterator }
    function Next: IInterface;
    function Previous: IInterface;
  end;

function TPreOrderIntfItr.Next: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1469 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Obj;
  FLastRet := FCursor;
  if FCursor.Left <> nil then
    FCursor := FCursor.Left
  else
  if FCursor.Right <> nil then
    FCursor := FCursor.Right
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and (FCursor.Left <> FLastRet) do // come from Right
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
    while (FCursor <> nil) and (FCursor.Right = nil) do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
    if FCursor <> nil then // not root
      FCursor := FCursor.Right;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1469; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPreOrderIntfItr.Previous: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1470 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Obj;
  FLastRet := FCursor;
  FCursor := FCursor.Parent;
  if (FCursor <> nil) and (FCursor.Left <> FLastRet) then // come from Right
    if FCursor.Left <> nil then
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Left;
      while FCursor.Right <> nil do
      begin
        FLastRet := FCursor;
        FCursor := FCursor.Right;
      end;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1470; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TInOrderIntfItr } ====================================================

type
  TInOrderIntfItr = class(TIntfItr, IIntfIterator)
  protected
    { IIntfIterator }
    function Next: IInterface; 
    function Previous: IInterface;
  end;

function TInOrderIntfItr.Next: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1471 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FCursor.Left <> FLastRet then
    while FCursor.Left <> nil do
      FCursor := FCursor.Left;
  Result := FCursor.Obj;
  FLastRet := FCursor;
  if FCursor.Right <> nil then
    FCursor := FCursor.Right
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and (FCursor.Right = FLastRet) do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1471; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TInOrderIntfItr.Previous: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1472 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Obj;
  FLastRet := FCursor;
  if FCursor.Left <> nil then
  begin
    FCursor := FCursor.Left;
    while FCursor.Right <> nil do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Right;
    end;
  end
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and (FCursor.Right <> FLastRet) do // Come from Left
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1472; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TPostOrderIntfItr } ==================================================

type
  TPostOrderIntfItr = class(TIntfItr, IIntfIterator)
  protected
    { IIntfIterator }
    function Next: IInterface;
    function Previous: IInterface; 
  end;

function TPostOrderIntfItr.Next: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1473 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (FCursor.Left <> FLastRet) and (FCursor.Right <> FLastRet) then
    while FCursor.Left <> nil do
      FCursor := FCursor.Left;
  if (FCursor.Right <> nil) and (FCursor.Right <> FLastRet) then
  begin
    FCursor := FCursor.Right;
    while FCursor.Left <> nil do
      FCursor := FCursor.Left;
    if FCursor.Right <> nil then // particular worst case
      FCursor := FCursor.Right;
  end;
  Result := FCursor.Obj;
  FLastRet := FCursor;
  FCursor := FCursor.Parent;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1473; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPostOrderIntfItr.Previous: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1474 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Obj;
  FLastRet := FCursor;
  if (FCursor.Right <> nil) and (FCursor.Right <> FLastRet) then
    FCursor := FCursor.Right
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and ((FCursor.Left = nil) or (FCursor.Left = FLastRet)) do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
    if FCursor <> nil then // not root
      FCursor := FCursor.Left;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1474; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TStrItr } ============================================================

type
  TStrItr = class(TAbstractContainer, IStrIterator)
  protected
    FCursor: PStrBinaryNode;
    FOwnList: TStrBinaryTree;
    FLastRet: PStrBinaryNode;
    { IStrIterator }
    function GetString: string;
    function HasNext: Boolean;
    function HasPrevious: Boolean;
    function Next: string;
    function Previous: string;
  public
    constructor Create(OwnList: TStrBinaryTree; Start: PStrBinaryNode);
  end;

constructor TStrItr.Create(OwnList: TStrBinaryTree; Start: PStrBinaryNode);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1475 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FCursor := Start;
  FOwnList := OwnList;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1475; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrItr.GetString: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1476 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Str;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1476; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1477 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor <> nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1477; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1478 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor <> nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1478; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrItr.Next: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1479 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1479; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrItr.Previous: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1480 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1480; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TPreOrderStrItr } ====================================================

type
  TPreOrderStrItr = class(TStrItr, IStrIterator)
  protected
    { IStrIterator }
    function Next: string;
    function Previous: string; 
  end;

function TPreOrderStrItr.Next: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1481 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Str;
  FLastRet := FCursor;
  if FCursor.Left <> nil then
    FCursor := FCursor.Left
  else
  if FCursor.Right <> nil then
    FCursor := FCursor.Right
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and (FCursor.Left <> FLastRet) do // come from Right
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
    while (FCursor <> nil) and (FCursor.Right = nil) do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
    if FCursor <> nil then // not root
      FCursor := FCursor.Right;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1481; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPreOrderStrItr.Previous: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1482 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Str;
  FLastRet := FCursor;
  FCursor := FCursor.Parent;
  if (FCursor <> nil) and (FCursor.Left <> FLastRet) then // come from Right
    if FCursor.Left <> nil then
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Left;
      while FCursor.Right <> nil do
      begin
        FLastRet := FCursor;
        FCursor := FCursor.Right;
      end;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1482; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TInOrderStrItr } =====================================================

type
  TInOrderStrItr = class(TStrItr, IStrIterator)
  protected
    { IStrIterator }
    function Next: string;
    function Previous: string;
  end;

function TInOrderStrItr.Next: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1483 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FCursor.Left <> FLastRet then
    while FCursor.Left <> nil do
      FCursor := FCursor.Left;
  Result := FCursor.Str;
  FLastRet := FCursor;
  if FCursor.Right <> nil then
    FCursor := FCursor.Right
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and (FCursor.Right = FLastRet) do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1483; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TInOrderStrItr.Previous: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1484 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Str;
  FLastRet := FCursor;
  if FCursor.Left <> nil then
  begin
    FCursor := FCursor.Left;
    while FCursor.Right <> nil do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Right;
    end;
  end
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and (FCursor.Right <> FLastRet) do // Come from Left
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1484; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TPostOrderStrItr } ===================================================

type
  TPostOrderStrItr = class(TStrItr, IStrIterator)
  protected
    { IStrIterator }
    function Next: string;
    function Previous: string;
  end;

function TPostOrderStrItr.Next: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1485 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (FCursor.Left <> FLastRet) and (FCursor.Right <> FLastRet) then
    while FCursor.Left <> nil do
      FCursor := FCursor.Left;
  if (FCursor.Right <> nil) and (FCursor.Right <> FLastRet) then
  begin
    FCursor := FCursor.Right;
    while FCursor.Left <> nil do
      FCursor := FCursor.Left;
    if FCursor.Right <> nil then // particular worst case
      FCursor := FCursor.Right;
  end;
  Result := FCursor.Str;
  FLastRet := FCursor;
  FCursor := FCursor.Parent;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1485; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPostOrderStrItr.Previous: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1486 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Str;
  FLastRet := FCursor;
  if (FCursor.Right <> nil) and (FCursor.Right <> FLastRet) then
    FCursor := FCursor.Right
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and ((FCursor.Left = nil) or (FCursor.Left = FLastRet)) do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
    if FCursor <> nil then // not root
      FCursor := FCursor.Left;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1486; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TStrHashItr } ============================================================

type
  TStrHashItr = class(TAbstractContainer, IStrIterator)
  protected
    FCursor: PStrHashBinaryNode;
    FOwnList: THashedStrBinaryTree;
    FLastRet: PStrHashBinaryNode;
    { IStrIterator }
    function GetString: string;
    function HasNext: Boolean;
    function HasPrevious: Boolean;
    function Next: string;
    function Previous: string;
  public
    constructor Create(OwnList: THashedStrBinaryTree; Start: PStrHashBinaryNode);
  end;

constructor TStrHashItr.Create(OwnList: THashedStrBinaryTree; Start: PStrHashBinaryNode);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1487 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FCursor := Start;
  FOwnList := OwnList;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1487; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashItr.GetString: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1488 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Str;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1488; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1489 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor <> nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1489; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1490 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor <> nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1490; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashItr.Next: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1491 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1491; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrHashItr.Previous: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1492 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1492; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TPreOrderStrHashItr } ====================================================

type
  TPreOrderStrHashItr = class(TStrHashItr, IStrIterator)
  protected
    { IStrIterator }
    function Next: string;
    function Previous: string;
  end;

function TPreOrderStrHashItr.Next: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1493 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Str;
  FLastRet := FCursor;
  if FCursor.Left <> nil then
    FCursor := FCursor.Left
  else
  if FCursor.Right <> nil then
    FCursor := FCursor.Right
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and (FCursor.Left <> FLastRet) do // come from Right
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
    while (FCursor <> nil) and (FCursor.Right = nil) do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
    if FCursor <> nil then // not root
      FCursor := FCursor.Right;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1493; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPreOrderStrHashItr.Previous: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1494 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Str;
  FLastRet := FCursor;
  FCursor := FCursor.Parent;
  if (FCursor <> nil) and (FCursor.Left <> FLastRet) then // come from Right
    if FCursor.Left <> nil then
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Left;
      while FCursor.Right <> nil do
      begin
        FLastRet := FCursor;
        FCursor := FCursor.Right;
      end;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1494; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TInOrderStrHashItr } =====================================================

type
  TInOrderStrHashItr = class(TStrHashItr, IStrIterator)
  protected
    { IStrIterator }
    function Next: string;
    function Previous: string;
  end;

function TInOrderStrHashItr.Next: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1495 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FCursor.Left <> FLastRet then
    while FCursor.Left <> nil do
      FCursor := FCursor.Left;
  Result := FCursor.Str;
  FLastRet := FCursor;
  if FCursor.Right <> nil then
    FCursor := FCursor.Right
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and (FCursor.Right = FLastRet) do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1495; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TInOrderStrHashItr.Previous: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1496 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Str;
  FLastRet := FCursor;
  if FCursor.Left <> nil then
  begin
    FCursor := FCursor.Left;
    while FCursor.Right <> nil do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Right;
    end;
  end
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and (FCursor.Right <> FLastRet) do // Come from Left
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1496; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TPostOrderStrHashItr } ===================================================

type
  TPostOrderStrHashItr = class(TStrHashItr, IStrIterator)
  protected
    { IStrIterator }
    function Next: string;
    function Previous: string;
  end;

function TPostOrderStrHashItr.Next: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1497 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (FCursor.Left <> FLastRet) and (FCursor.Right <> FLastRet) then
    while FCursor.Left <> nil do
      FCursor := FCursor.Left;
  if (FCursor.Right <> nil) and (FCursor.Right <> FLastRet) then
  begin
    FCursor := FCursor.Right;
    while FCursor.Left <> nil do
      FCursor := FCursor.Left;
    if FCursor.Right <> nil then // particular worst case
      FCursor := FCursor.Right;
  end;
  Result := FCursor.Str;
  FLastRet := FCursor;
  FCursor := FCursor.Parent;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1497; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPostOrderStrHashItr.Previous: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1498 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Str;
  FLastRet := FCursor;
  if (FCursor.Right <> nil) and (FCursor.Right <> FLastRet) then
    FCursor := FCursor.Right
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and ((FCursor.Left = nil) or (FCursor.Left = FLastRet)) do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
    if FCursor <> nil then // not root
      FCursor := FCursor.Left;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1498; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TPtrItr } ===============================================================

type
  TPtrItr = class(TAbstractContainer, IPtrIterator)
  protected
    FCursor: PPtrBinaryNode;
    FOwnList: TPtrBinaryTree;
    FLastRet: PPtrBinaryNode;
    { IPtrIterator }
    function GetPtr: Pointer;
    function HasNext: Boolean;
    function HasPrevious: Boolean;
    function Next: Pointer;
    function Previous: Pointer;
  public
    constructor Create(OwnList: TPtrBinaryTree; Start: PPtrBinaryNode);
  end;

constructor TPtrItr.Create(OwnList: TPtrBinaryTree; Start: PPtrBinaryNode);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1499 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FCursor := Start;
  FOwnList := OwnList;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1499; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrItr.GetPtr: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1500 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Ptr;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1500; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1501 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor <> nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1501; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1502 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor <> nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1502; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrItr.Next: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1503 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil; // overriden in derived class
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1503; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrItr.Previous: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1504 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil; // overriden in derived class
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1504; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TPreOrderPtrItr } =======================================================

type
  TPreOrderPtrItr = class(TPtrItr, IPtrIterator)
  protected
    { IPtrIterator }
    function Next: Pointer;
    function Previous: Pointer;
  end;

function TPreOrderPtrItr.Next: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1505 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Ptr;
  FLastRet := FCursor;
  if FCursor.Left <> nil then
    FCursor := FCursor.Left
  else
  if FCursor.Right <> nil then
    FCursor := FCursor.Right
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and (FCursor.Left <> FLastRet) do // come from Right
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
    while (FCursor <> nil) and (FCursor.Right = nil) do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
    if FCursor <> nil then // not root
      FCursor := FCursor.Right;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1505; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPreOrderPtrItr.Previous: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1506 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Ptr;
  FLastRet := FCursor;
  FCursor := FCursor.Parent;
  if (FCursor <> nil) and (FCursor.Left <> FLastRet) then // come from Right
    if FCursor.Left <> nil then
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Left;
      while FCursor.Right <> nil do
      begin
        FLastRet := FCursor;
        FCursor := FCursor.Right;
      end;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1506; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TInOrderPtrItr } ========================================================

type
  TInOrderPtrItr = class(TPtrItr, IPtrIterator)
  protected
    { IPtrIterator }
    function Next: Pointer;
    function Previous: Pointer;
  end;

function TInOrderPtrItr.Next: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1507 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FCursor.Left <> FLastRet then
    while FCursor.Left <> nil do
      FCursor := FCursor.Left;
  Result := FCursor.Ptr;
  FLastRet := FCursor;
  if FCursor.Right <> nil then
    FCursor := FCursor.Right
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and (FCursor.Right = FLastRet) do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1507; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TInOrderPtrItr.Previous: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1508 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Ptr;
  FLastRet := FCursor;
  if FCursor.Left <> nil then
  begin
    FCursor := FCursor.Left;
    while FCursor.Right <> nil do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Right;
    end;
  end
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and (FCursor.Right <> FLastRet) do // Come from Left
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1508; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TPostOrderPtrItr } ======================================================

type
  TPostOrderPtrItr = class(TPtrItr, IPtrIterator)
  protected
    { IPtrIterator }
    function Next: Pointer;
    function Previous: Pointer;
  end;

function TPostOrderPtrItr.Next: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1509 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (FCursor.Left <> FLastRet) and (FCursor.Right <> FLastRet) then
    while FCursor.Left <> nil do
      FCursor := FCursor.Left;
  if (FCursor.Right <> nil) and (FCursor.Right <> FLastRet) then
  begin
    FCursor := FCursor.Right;
    while FCursor.Left <> nil do
      FCursor := FCursor.Left;
    if FCursor.Right <> nil then // particular worst case
      FCursor := FCursor.Right;
  end;
  Result := FCursor.Ptr;
  FLastRet := FCursor;
  FCursor := FCursor.Parent;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1509; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPostOrderPtrItr.Previous: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1510 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Ptr;
  FLastRet := FCursor;
  if (FCursor.Right <> nil) and (FCursor.Right <> FLastRet) then
    FCursor := FCursor.Right
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and ((FCursor.Left = nil) or (FCursor.Left = FLastRet)) do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
    if FCursor <> nil then // not root
      FCursor := FCursor.Left;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1510; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TItr } ===============================================================

type
  TItr = class(TAbstractContainer, IIterator)
  protected
    FCursor: PBinaryNode;
    FOwnList: TBinaryTree;
    FLastRet: PBinaryNode;
    { IIterator }
    function GetObject: TObject;
    function HasNext: Boolean;
    function HasPrevious: Boolean;
    function Next: TObject;
    function Previous: TObject;
  public
    constructor Create(OwnList: TBinaryTree; Start: PBinaryNode);
  end;

constructor TItr.Create(OwnList: TBinaryTree; Start: PBinaryNode);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1511 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FCursor := Start;
  FOwnList := OwnList;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1511; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TItr.GetObject: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1512 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Obj;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1512; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1513 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor <> nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1513; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1514 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor <> nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1514; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TItr.Next: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1515 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil; // overriden in derived class
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1515; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TItr.Previous: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1516 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil; // overriden in derived class
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1516; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TPreOrderItr } =======================================================

type
  TPreOrderItr = class(TItr, IIterator)
  protected
    { IIterator }
    function Next: TObject;
    function Previous: TObject;
  end;

function TPreOrderItr.Next: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1517 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Obj;
  FLastRet := FCursor;
  if FCursor.Left <> nil then
    FCursor := FCursor.Left
  else
  if FCursor.Right <> nil then
    FCursor := FCursor.Right
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and (FCursor.Left <> FLastRet) do // come from Right
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
    while (FCursor <> nil) and (FCursor.Right = nil) do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
    if FCursor <> nil then // not root
      FCursor := FCursor.Right;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1517; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPreOrderItr.Previous: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1518 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Obj;
  FLastRet := FCursor;
  FCursor := FCursor.Parent;
  if (FCursor <> nil) and (FCursor.Left <> FLastRet) then // come from Right
    if FCursor.Left <> nil then
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Left;
      while FCursor.Right <> nil do
      begin
        FLastRet := FCursor;
        FCursor := FCursor.Right;
      end;
    end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1518; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TInOrderItr } ========================================================

type
  TInOrderItr = class(TItr, IIterator)
  protected
    { IIterator }
    function Next: TObject;
    function Previous: TObject;
  end;

function TInOrderItr.Next: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1519 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FCursor.Left <> FLastRet then
    while FCursor.Left <> nil do
      FCursor := FCursor.Left;
  Result := FCursor.Obj;
  FLastRet := FCursor;
  if FCursor.Right <> nil then
    FCursor := FCursor.Right
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and (FCursor.Right = FLastRet) do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1519; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TInOrderItr.Previous: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1520 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Obj;
  FLastRet := FCursor;
  if FCursor.Left <> nil then
  begin
    FCursor := FCursor.Left;
    while FCursor.Right <> nil do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Right;
    end;
  end
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and (FCursor.Right <> FLastRet) do // Come from Left
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1520; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TPostOrderItr } ======================================================

type
  TPostOrderItr = class(TItr, IIterator)
  protected
    { IIterator }
    function Next: TObject; 
    function Previous: TObject;
  end;

function TPostOrderItr.Next: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1521 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (FCursor.Left <> FLastRet) and (FCursor.Right <> FLastRet) then
    while FCursor.Left <> nil do
      FCursor := FCursor.Left;
  if (FCursor.Right <> nil) and (FCursor.Right <> FLastRet) then
  begin
    FCursor := FCursor.Right;
    while FCursor.Left <> nil do
      FCursor := FCursor.Left;
    if FCursor.Right <> nil then // particular worst case
      FCursor := FCursor.Right;
  end;
  Result := FCursor.Obj;
  FLastRet := FCursor;
  FCursor := FCursor.Parent;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1521; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPostOrderItr.Previous: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1522 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Obj;
  FLastRet := FCursor;
  if (FCursor.Right <> nil) and (FCursor.Right <> FLastRet) then
    FCursor := FCursor.Right
  else
  begin
    FCursor := FCursor.Parent;
    while (FCursor <> nil) and ((FCursor.Left = nil) or (FCursor.Left = FLastRet)) do
    begin
      FLastRet := FCursor;
      FCursor := FCursor.Parent;
    end;
    if FCursor <> nil then // not root
      FCursor := FCursor.Left;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1522; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TIntfBinaryTree } =================================================

constructor TIntfBinaryTree.Create(AComparator: TInterfaceCompare = nil);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1523 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if Assigned(AComparator) then
    FComparator := AComparator;
  FTraverseOrder := toPreOrder;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1523; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TIntfBinaryTree.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1524 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1524; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfBinaryTree.DoCompare(const I1, I2: IInterface): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1525 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Assigned(FComparator) then
  begin
    Result := FComparator(I1, I2);
  end else
  begin
    Result := Integer(Longword(I1) - Longword(I2));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1525; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfBinaryTree.Add(const AInterface: IInterface): Boolean;
var
  NewNode: PIntfBinaryNode;
  Current, Save: PIntfBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1526 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AInterface = nil then
    Exit;
  NewNode := AllocMem(SizeOf(TIntfBinaryNode));
  NewNode.Obj := AInterface;
  // Insert into right place
  Save := nil;
  Current := FRoot;
  while Current <> nil do
  begin
    Save := Current;
    if DoCompare(NewNode.Obj, Current.Obj) < 0 then
      Current := Current.Left
    else
      Current := Current.Right;
  end;
  NewNode.Parent := Save;
  if Save = nil then
    FRoot := NewNode
  else
  if DoCompare(NewNode.Obj, Save.Obj) < 0 then
    Save.Left := NewNode
  else
    Save.Right := NewNode;
  // RB balanced
  NewNode.Color := tcRed;
  while (NewNode <> FRoot) and (NewNode.Parent.Color = tcRed) do
  begin
    if (NewNode.Parent.Parent <> nil) and (NewNode.Parent = NewNode.Parent.Parent.Left) then
    begin
      Current := NewNode.Parent.Parent.Right;
      if Current.Color = tcRed then
      begin
        NewNode.Parent.Color := tcBlack;
        Current.Color := tcBlack;
        NewNode.Parent.Parent.Color := tcRed;
        NewNode := NewNode.Parent.Parent;
      end
      else
      begin
        if NewNode = NewNode.Parent.Right then
        begin
          NewNode := NewNode.Parent;
          RotateLeft(NewNode);
        end;
        NewNode.Parent.Color := tcBlack;
        NewNode.Parent.Parent.Color := tcRed;
        RotateRight(NewNode.Parent.Parent);
      end;
    end
    else
    begin
      if NewNode.Parent.Parent = nil then
        Current := nil
      else
        Current := NewNode.Parent.Parent.Left;
      if (Current <> nil) and (Current.Color = tcRed) then
      begin
        NewNode.Parent.Color := tcBlack;
        Current.Color := tcBlack;
        NewNode.Parent.Parent.Color := tcRed;
        NewNode := NewNode.Parent.Parent;
      end
      else
      begin
        if NewNode = NewNode.Parent.Left then
        begin
          NewNode := NewNode.Parent;
          RotateRight(NewNode);
        end;
        NewNode.Parent.Color := tcBlack;
        if NewNode.Parent.Parent <> nil then
          NewNode.Parent.Parent.Color := tcRed;
        RotateLeft(NewNode.Parent.Parent);
      end;
    end;
  end;
  FRoot.Color := tcBlack;
  Inc(FCount);
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1526; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfBinaryTree.AddAll(const ACollection: IIntfCollection);
var
  It: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1527 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1527; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfBinaryTree.Clear;
var
  Current: PIntfBinaryNode;
  Save: PIntfBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1528 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Current := FRoot;
  while Current <> nil do
  begin
    if Current.Left <> nil then
      Current := Current.Left
    else
    if Current.Right <> nil then
      Current := Current.Right
    else
    begin
      Current.Obj := nil; // Force Release
      if Current.Parent = nil then // Root
      begin
        FreeMem(Current);
        Current := nil;
        FRoot := nil;
      end
      else
      begin
        Save := Current;
        Current := Current.Parent;
        if Save = Current.Right then // True = from Right
        begin
          FreeMem(Save);
          Current.Right := nil;
        end
        else
        begin
          FreeMem(Save);
          Current.Left := nil;
        end
      end;
    end;
  end;
  FCount := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1528; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfBinaryTree.Clone: TObject;
var
  NewTree: TIntfBinaryTree;

  function CloneNode(Node, Parent: PIntfBinaryNode): PIntfBinaryNode;
  begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1529 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
    if Node <> nil then
    begin
      GetMem(Result, SizeOf(TIntfBinaryNode));
      Result.Obj := Node.Obj;
      Result.Color := Node.Color;
      Result.Parent := Parent;
      Result.Left := CloneNode(Node.Left, Result); // recursive call
      Result.Right := CloneNode(Node.Right, Result); // recursive call
    end
    else
      Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1529; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
  end;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1530 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewTree := TIntfBinaryTree.Create(FComparator);
  NewTree.FCount := FCount;
  NewTree.FRoot := CloneNode(FRoot, nil);
  Result := NewTree;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1530; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfBinaryTree.Contains(const AInterface: IInterface): Boolean;
var
  Comp: Integer;
  Current: PIntfBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1531 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AInterface = nil then
    Exit;

  Current := FRoot;
  while Current <> nil do
  begin
    Comp := DoCompare(Current.Obj, AInterface);
    if Comp = 0 then
    begin
      Result := True;
      Break;
    end
    else
    if Comp > 0 then
      Current := Current.Left
    else
      Current := Current.Right;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1531; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfBinaryTree.ContainsAll(const ACollection: IIntfCollection): Boolean;
var
  It: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1532 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := True;
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while Result and It.HasNext do
    Result := Contains(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1532; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfBinaryTree.Equals(const ACollection: IIntfCollection): Boolean;
var
  It, ItSelf: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1533 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then
    Exit;
  if FCount <> ACollection.Size then
    Exit;
  It := ACollection.First;
  ItSelf := First;
  while ItSelf.HasNext do
    if DoCompare(ItSelf.Next, It.Next) <> 0 then
      Exit;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1533; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfBinaryTree.First: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1534 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  case GetTraverseOrder of
    toPreOrder:
      Result := TPreOrderIntfItr.Create(Self, FRoot);
    toOrder:
      Result := TInOrderIntfItr.Create(Self, FRoot);
    toPostOrder:
      Result := TPostOrderIntfItr.Create(Self, FRoot);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1534; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfBinaryTree.GetTraverseOrder: TTraverseOrder;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1535 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FTraverseOrder;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1535; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfBinaryTree.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1536 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1536; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfBinaryTree.Last: IIntfIterator;
var
  Start: PIntfBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1537 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Start := FRoot;
  case FTraverseOrder of
    toPreOrder:
      begin
        if Start <> nil then
          while Start.Right <> nil do
            Start := Start.Right;
        Result := TPreOrderIntfItr.Create(Self, Start);
      end;
    toOrder:
      begin
        if Start <> nil then
          while Start.Right <> nil do
            Start := Start.Right;
        Result := TInOrderIntfItr.Create(Self, Start);
      end;
    toPostOrder:
      Result := TPostOrderIntfItr.Create(Self, Start);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1537; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfBinaryTree.RotateLeft(Node: PIntfBinaryNode);
var
  TempNode: PIntfBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1538 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Node = nil then
    Exit;
  TempNode := Node.Right;
  //  if TempNode = nil then	Exit;
  Node.Right := TempNode.Left;
  if TempNode.Left <> nil then
    TempNode.Left.Parent := Node;
  TempNode.Parent := Node.Parent;
  if Node.Parent = nil then
    FRoot := TempNode
  else
  if Node.Parent.Left = Node then
    Node.Parent.Left := TempNode
  else
    Node.Parent.Right := TempNode;
  TempNode.Left := Node;
  Node.Parent := TempNode;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1538; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfBinaryTree.RotateRight(Node: PIntfBinaryNode);
var
  TempNode: PIntfBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1539 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Node = nil then
    Exit;
  TempNode := Node.Left;
  //  if TempNode = nil then 	Exit;
  Node.Left := TempNode.Right;
  if TempNode.Right <> nil then
    TempNode.Right.Parent := Node;
  TempNode.Parent := Node.Parent;
  if Node.Parent = nil then
    FRoot := TempNode
  else
  if Node.Parent.Right = Node then
    Node.Parent.Right := TempNode
  else
    Node.Parent.Left := TempNode;
  TempNode.Right := Node;
  Node.Parent := TempNode;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1539; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfBinaryTree.Remove(const AInterface: IInterface): Boolean;
var
  Current: PIntfBinaryNode;
  Node: PIntfBinaryNode;
  Save: PIntfBinaryNode;
  Comp: Integer;

  procedure Correction(Node: PIntfBinaryNode);
  var
    TempNode: PIntfBinaryNode;
  begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1540 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
    while (Node <> FRoot) and (Node.Color = tcBlack) do
    begin
      if Node = Node.Parent.Left then
      begin
        TempNode := Node.Parent.Right;
        if TempNode = nil then
        begin
          Node := Node.Parent;
          Continue;
        end;
        if TempNode.Color = tcRed then
        begin
          TempNode.Color := tcBlack;
          Node.Parent.Color := tcRed;
          RotateLeft(Node.Parent);
          TempNode := Node.Parent.Right;
        end;
        if (TempNode.Left <> nil) and (TempNode.Left.Color = tcBlack) and
          (TempNode.Right <> nil) and (TempNode.Right.Color = tcBlack) then
        begin
          TempNode.Color := tcRed;
          Node := Node.Parent;
        end
        else
        begin
          if (TempNode.Right <> nil) and (TempNode.Right.Color = tcBlack) then
          begin
            TempNode.Left.Color := tcBlack;
            TempNode.Color := tcRed;
            RotateRight(TempNode);
            TempNode := Node.Parent.Right;
          end;
          TempNode.Color := Node.Parent.Color;
          Node.Parent.Color := tcBlack;
          if TempNode.Right <> nil then
            TempNode.Right.Color := tcBlack;
          RotateLeft(Node.Parent);
          Node := FRoot;
        end;
      end
      else
      begin
        TempNode := Node.Parent.Left;
        if TempNode = nil then
        begin
          Node := Node.Parent;
          Continue;
        end;
        if TempNode.Color = tcRed then
        begin
          TempNode.Color := tcBlack;
          Node.Parent.Color := tcRed;
          RotateRight(Node.Parent);
          TempNode := Node.Parent.Left;
        end;
        if (TempNode.Left.Color = tcBlack) and (TempNode.Right.Color = tcBlack) then
        begin
          TempNode.Color := tcRed;
          Node := Node.Parent;
        end
        else
        begin
          if TempNode.Left.Color = tcBlack then
          begin
            TempNode.Right.Color := tcBlack;
            TempNode.Color := tcRed;
            RotateLeft(TempNode);
            TempNode := Node.Parent.Left;
          end;
          TempNode.Color := Node.Parent.Color;
          Node.Parent.Color := tcBlack;
          if TempNode.Left <> nil then
            TempNode.Left.Color := tcBlack;
          RotateRight(Node.Parent);
          Node := FRoot;
        end;
      end;
    end;
    Node.Color := tcBlack;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1540; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
  end;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1541 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AInterface = nil then
    Exit;
  // locate AInterface in the tree
  Current := FRoot;
  while Current <> nil do
  begin
    Comp := DoCompare(AInterface, Current.Obj);
    if Comp = 0 then
      Break
    else
    if Comp < 0 then
      Current := Current.Left
    else
      Current := Current.Right;
  end;
  if Current = nil then
    Exit;
  // Remove
  if (Current.Left = nil) or (Current.Right = nil) then
    Save := Current
  else
  begin // Successor in Save
    if Current.Right <> nil then
    begin
      Save := Current.Right;
      while Save.Left <> nil do // Minimum
        Save := Save.Left;
    end
    else
    begin
      Save := Current.Parent;
      while (Save <> nil) and (Current = Save.Right) do
      begin
        Current := Save;
        Save := Save.Parent;
      end;
    end;
  end;
  if Save.Left <> nil then
    Node := Save.Left
  else
    Node := Save.Right;
  if Node <> nil then
  begin
    Node.Parent := Save.Parent;
    if Save.Parent = nil then
      FRoot := Node
    else
    if Save = Save.Parent.Left then
      Save.Parent.Left := Node
    else
      Save.Parent.Right := Node;
    if Save.Color = tcBlack then
      Correction(Node);
  end
  else
  if Save.Parent = nil then
    FRoot := nil
  else
  begin
    if Save.Color = tcBlack then
      Correction(Save);
    if Save.Parent <> nil then
      if Save = Save.Parent.Left then
        Save.Parent.Left := nil
      else
      if Save = Save.Parent.Right then
        Save.Parent.Right := nil
  end;
  FreeMem(Save);
  Dec(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1541; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfBinaryTree.RemoveAll(const ACollection: IIntfCollection);
var
  It: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1542 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Remove(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1542; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfBinaryTree.RetainAll(const ACollection: IIntfCollection);
var
  It: IIntfIterator;
  Val: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1543 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := First;
  while It.HasNext do
  begin
    Val := It.Next;
    if not ACollection.Contains(Val) then
      Remove(Val);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1543; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfBinaryTree.SetTraverseOrder(Value: TTraverseOrder);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1544 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FTraverseOrder := Value;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1544; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfBinaryTree.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1545 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1545; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TStrBinaryTree } ==================================================

constructor TStrBinaryTree.Create(AComparator: TStringCompare = nil);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1546 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if Assigned(AComparator) then
    FComparator := AComparator;
  FTraverseOrder := toPreOrder;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1546; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TStrBinaryTree.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1547 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1547; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrBinaryTree.DoCompare(const S1, S2: string): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1548 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Assigned(FComparator) then
  begin
    Result := FComparator(S1, S2);
  end else
  begin
    if FCaseSensitive then
    begin
      Result := StringsCompare(S1, S2);
    end else
    begin
      Result := StringsCompareNoCase(S1, S2);
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1548; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrBinaryTree.Add(const AString: string): Boolean;
var
  NewNode: PStrBinaryNode;
  Current, Save: PStrBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1549 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AString = '' then
    Exit;
  NewNode := AllocMem(SizeOf(TStrBinaryNode));
  NewNode.Str := AString;
  // Insert into right place
  Save := nil;
  Current := FRoot;
  while Current <> nil do
  begin
    Save := Current;
    if DoCompare(NewNode.Str, Current.Str) < 0 then
      Current := Current.Left
    else
      Current := Current.Right;
  end;
  NewNode.Parent := Save;
  if Save = nil then
    FRoot := NewNode
  else
  if DoCompare(NewNode.Str, Save.Str) < 0 then
    Save.Left := NewNode
  else
    Save.Right := NewNode;
  // RB balanced
  NewNode.Color := tcRed;
  while (NewNode <> FRoot) and (NewNode.Parent.Color = tcRed) do
  begin
    if (NewNode.Parent.Parent <> nil) and (NewNode.Parent = NewNode.Parent.Parent.Left) then
    begin
      Current := NewNode.Parent.Parent.Right;
      if (Current <> nil) and (Current.Color = tcRed) then
      begin
        NewNode.Parent.Color := tcBlack;
        Current.Color := tcBlack;
        NewNode.Parent.Parent.Color := tcRed;
        NewNode := NewNode.Parent.Parent;
      end
      else
      begin
        if NewNode = NewNode.Parent.Right then
        begin
          NewNode := NewNode.Parent;
          RotateLeft(NewNode);
        end;
        NewNode.Parent.Color := tcBlack;
        NewNode.Parent.Parent.Color := tcRed;
        RotateRight(NewNode.Parent.Parent);
      end;
    end
    else
    begin
      if NewNode.Parent.Parent = nil then
        Current := nil
      else
        Current := NewNode.Parent.Parent.Left;
      if (Current <> nil) and (Current.Color = tcRed) then
      begin
        NewNode.Parent.Color := tcBlack;
        Current.Color := tcBlack;
        NewNode.Parent.Parent.Color := tcRed;
        NewNode := NewNode.Parent.Parent;
      end
      else
      begin
        if NewNode = NewNode.Parent.Left then
        begin
          NewNode := NewNode.Parent;
          RotateRight(NewNode);
        end;
        NewNode.Parent.Color := tcBlack;
        if NewNode.Parent.Parent <> nil then
          NewNode.Parent.Parent.Color := tcRed;
        RotateLeft(NewNode.Parent.Parent);
      end;
    end;
  end;
  FRoot.Color := tcBlack;
  Inc(FCount);
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1549; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrBinaryTree.AddAll(const ACollection: IStrCollection);
var
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1550 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1550; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrBinaryTree.Clear;
var
  Current: PStrBinaryNode;
  Save: PStrBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1551 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  // iterative version
  Current := FRoot;
  while Current <> nil do
  begin
    if Current.Left <> nil then
      Current := Current.Left
    else
    if Current.Right <> nil then
      Current := Current.Right
    else
    begin
      Current.Str := ''; // Force Release
      if Current.Parent = nil then // Root
      begin
        FreeMem(Current);
        Current := nil;
        FRoot := nil;
      end
      else
      begin
        Save := Current;
        Current := Current.Parent;
        if Save = Current.Right then // True = from Right
        begin
          FreeMem(Save);
          Current.Right := nil;
        end
        else
        begin
          FreeMem(Save);
          Current.Left := nil;
        end
      end;
    end;
  end;
  FCount := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1551; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrBinaryTree.Clone: TObject;
var
  NewTree: TStrBinaryTree;

  function CloneNode(Node, Parent: PStrBinaryNode): PStrBinaryNode;
  begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1552 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
    if Node <> nil then
    begin
      GetMem(Result, SizeOf(TStrBinaryNode));
      Result.Str := Node.Str;
      Result.Color := Node.Color;
      Result.Parent := Parent;
      Result.Left := CloneNode(Node.Left, Result); // recursive call
      Result.Right := CloneNode(Node.Right, Result); // recursive call
    end
    else
      Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1552; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
  end;

begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1553 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewTree := TStrBinaryTree.Create(FComparator);
  NewTree.FCount := FCount;
  NewTree.FRoot := CloneNode(FRoot, nil);
  Result := NewTree;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1553; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrBinaryTree.Contains(const AString: string): Boolean;
var
  Comp: Integer;
  Current: PStrBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1554 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AString = '' then
    Exit;
  // iterative version
  Current := FRoot;
  while Current <> nil do
  begin
    Comp := DoCompare(Current.Str, AString);
    if Comp = 0 then
    begin
      Result := True;
      Break;
    end
    else
    if Comp > 0 then
      Current := Current.Left
    else
      Current := Current.Right;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1554; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrBinaryTree.ContainsAll(const ACollection: IStrCollection): Boolean;
var
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1555 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := True;
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while Result and It.HasNext do
    Result := Contains(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1555; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrBinaryTree.Equals(const ACollection: IStrCollection): Boolean;
var
  It, ItSelf: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1556 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then
    Exit;
  if FCount <> ACollection.Size then
    Exit;
  It := ACollection.First;
  ItSelf := First;
  while ItSelf.HasNext do
    if DoCompare(ItSelf.Next, It.Next) <> 0 then
      Exit;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1556; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrBinaryTree.First: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1557 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  case GetTraverseOrder of
    toPreOrder:
      Result := TPreOrderStrItr.Create(Self, FRoot);
    toOrder:
      Result := TInOrderStrItr.Create(Self, FRoot);
    toPostOrder:
      Result := TPostOrderStrItr.Create(Self, FRoot);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1557; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrBinaryTree.GetCaseSensitivity: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1558 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCaseSensitive;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1558; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrBinaryTree.GetTraverseOrder: TTraverseOrder;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1559 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FTraverseOrder;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1559; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrBinaryTree.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1560 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1560; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrBinaryTree.Last: IStrIterator;
var
  Start: PStrBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1561 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Start := FRoot;
  case FTraverseOrder of
    toPreOrder:
      begin
        if Start <> nil then
          while Start.Right <> nil do
            Start := Start.Right;
        Result := TPreOrderStrItr.Create(Self, Start);
      end;
    toOrder:
      begin
        if Start <> nil then
          while Start.Right <> nil do
            Start := Start.Right;
        Result := TInOrderStrItr.Create(Self, Start);
      end;
    toPostOrder:
      Result := TPostOrderStrItr.Create(Self, Start);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1561; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrBinaryTree.Remove(const AString: string): Boolean;
var
  Current: PStrBinaryNode;
  Node: PStrBinaryNode;
  Save: PStrBinaryNode;
  Comp: Integer;

  procedure Correction(Node: PStrBinaryNode);
  var
    TempNode: PStrBinaryNode;
  begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1562 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
    while (Node <> FRoot) and (Node.Color = tcBlack) do
    begin
      if Node = Node.Parent.Left then
      begin
        TempNode := Node.Parent.Right;
        if TempNode = nil then
        begin
          Node := Node.Parent;
          Continue;
        end;
        if TempNode.Color = tcRed then
        begin
          TempNode.Color := tcBlack;
          Node.Parent.Color := tcRed;
          RotateLeft(Node.Parent);
          TempNode := Node.Parent.Right;
        end;
        if (TempNode.Left <> nil) and (TempNode.Left.Color = tcBlack) and
          (TempNode.Right <> nil) and (TempNode.Right.Color = tcBlack) then
        begin
          TempNode.Color := tcRed;
          Node := Node.Parent;
        end
        else
        begin
          if (TempNode.Right <> nil) and (TempNode.Right.Color = tcBlack) then
          begin
            TempNode.Left.Color := tcBlack;
            TempNode.Color := tcRed;
            RotateRight(TempNode);
            TempNode := Node.Parent.Right;
          end;
          TempNode.Color := Node.Parent.Color;
          Node.Parent.Color := tcBlack;
          if TempNode.Right <> nil then
            TempNode.Right.Color := tcBlack;
          RotateLeft(Node.Parent);
          Node := FRoot;
        end;
      end
      else
      begin
        TempNode := Node.Parent.Left;
        if TempNode = nil then
        begin
          Node := Node.Parent;
          Continue;
        end;
        if TempNode.Color = tcRed then
        begin
          TempNode.Color := tcBlack;
          Node.Parent.Color := tcRed;
          RotateRight(Node.Parent);
          TempNode := Node.Parent.Left;
        end;
        if (TempNode.Left.Color = tcBlack) and (TempNode.Right.Color = tcBlack) then
        begin
          TempNode.Color := tcRed;
          Node := Node.Parent;
        end
        else
        begin
          if TempNode.Left.Color = tcBlack then
          begin
            TempNode.Right.Color := tcBlack;
            TempNode.Color := tcRed;
            RotateLeft(TempNode);
            TempNode := Node.Parent.Left;
          end;
          TempNode.Color := Node.Parent.Color;
          Node.Parent.Color := tcBlack;
          if TempNode.Left <> nil then
            TempNode.Left.Color := tcBlack;
          RotateRight(Node.Parent);
          Node := FRoot;
        end;
      end
    end;
    Node.Color := tcBlack;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1562; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
  end;

begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1563 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AString = '' then
    Exit;
  // locate AObject in the tree
  Current := FRoot;
  while Current <> nil do
  begin
    Comp := DoCompare(AString, Current.Str);
    if Comp = 0 then
      Break
    else
    if Comp < 0 then
      Current := Current.Left
    else
      Current := Current.Right;
  end;
  if Current = nil then
    Exit;
  // Remove
  if (Current.Left = nil) or (Current.Right = nil) then
    Save := Current
  else
  begin // Successor in Save
    if Current.Right <> nil then
    begin
      Save := Current.Right;
      while Save.Left <> nil do // Minimum
        Save := Save.Left;
    end
    else
    begin
      Save := Current.Parent;
      while (Save <> nil) and (Current = Save.Right) do
      begin
        Current := Save;
        Save := Save.Parent;
      end;
    end;
  end;
  if Save.Left <> nil then
    Node := Save.Left
  else
    Node := Save.Right;
  if Node <> nil then
  begin
    Node.Parent := Save.Parent;
    if Save.Parent = nil then
      FRoot := Node
    else
    if Save = Save.Parent.Left then
      Save.Parent.Left := Node
    else
      Save.Parent.Right := Node;
    if Save.Color = tcBlack then // Correction
      Correction(Node);
  end
  else
  if Save.Parent = nil then
    FRoot := nil
  else
  begin
    if Save.Color = tcBlack then // Correction
      Correction(Save);
    if Save.Parent <> nil then
      if Save = Save.Parent.Left then
        Save.Parent.Left := nil
      else
      if Save = Save.Parent.Right then
        Save.Parent.Right := nil
  end;
  FreeMem(Save);
  Dec(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1563; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrBinaryTree.RemoveAll(const ACollection: IStrCollection);
var
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1564 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Remove(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1564; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrBinaryTree.RetainAll(const ACollection: IStrCollection);
var
  It: IStrIterator;
  S: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1565 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := First;
  while It.HasNext do
  begin
    S := It.Next;
    if not ACollection.Contains(S) then
      Remove(S);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1565; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrBinaryTree.RotateLeft(Node: PStrBinaryNode);
var
  TempNode: PStrBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1566 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Node = nil then
    Exit;
  TempNode := Node.Right;
  //  if TempNode = nil then	Exit;
  Node.Right := TempNode.Left;
  if TempNode.Left <> nil then
    TempNode.Left.Parent := Node;
  TempNode.Parent := Node.Parent;
  if Node.Parent = nil then
    FRoot := TempNode
  else
  if Node.Parent.Left = Node then
    Node.Parent.Left := TempNode
  else
    Node.Parent.Right := TempNode;
  TempNode.Left := Node;
  Node.Parent := TempNode;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1566; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrBinaryTree.RotateRight(Node: PStrBinaryNode);
var
  TempNode: PStrBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1567 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Node = nil then
    Exit;
  TempNode := Node.Left;
  //  if TempNode = nil then 	Exit;
  Node.Left := TempNode.Right;
  if TempNode.Right <> nil then
    TempNode.Right.Parent := Node;
  TempNode.Parent := Node.Parent;
  if Node.Parent = nil then
    FRoot := TempNode
  else
  if Node.Parent.Right = Node then
    Node.Parent.Right := TempNode
  else
    Node.Parent.Left := TempNode;
  TempNode.Right := Node;
  Node.Parent := TempNode;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1567; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrBinaryTree.SetCaseSensitivity(Value: Boolean);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1568 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FCaseSensitive := Value;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1568; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrBinaryTree.SetTraverseOrder(Value: TTraverseOrder);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1569 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FTraverseOrder := Value;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1569; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrBinaryTree.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1570 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1570; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { THashedStrBinaryTree } ==================================================

constructor THashedStrBinaryTree.Create(AHashFunction: TStrHashFunction = nil);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1571 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if Assigned(AHashFunction) then
    FHashFunction := AHashFunction;
  FTraverseOrder := toPreOrder;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1571; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor THashedStrBinaryTree.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1572 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1572; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashedStrBinaryTree.DoCompare(H1, H2: Integer; const S1,
  S2: string): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1573 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := H1 - H2;
  if Result = 0 then
  begin
    if FCaseSensitive then
    begin
      Result := StringsCompare(S1, S2);
    end else
    begin
      Result := StringsCompareNoCase(S1, S2);
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1573; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashedStrBinaryTree.HashStr(const S: string): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1574 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Assigned(FHashFunction) then
  begin
    Result := FHashFunction(S);
  end else
  begin
    if FCaseSensitive then
    begin
      Result := HashData(Pointer(S), Length(S));
    end else
    begin
      Result := HashDataNoCase(Pointer(S), Length(S));
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1574; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashedStrBinaryTree.Add(const AString: string): Boolean;
var
  NewNode: PStrHashBinaryNode;
  Current, Save: PStrHashBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1575 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AString = '' then
    Exit;
  NewNode := AllocMem(SizeOf(TStrHashBinaryNode));
  NewNode.Str := AString;
  NewNode.Hash := HashStr(AString);
  // Insert into right place
  Save := nil;
  Current := FRoot;
  while Current <> nil do
  begin
    Save := Current;
    if NewNode.Hash - Current.Hash < 0 then
      Current := Current.Left
    else
      Current := Current.Right;
  end;
  NewNode.Parent := Save;
  if Save = nil then
    FRoot := NewNode
  else
  if DoCompare(NewNode.Hash, Save.Hash, NewNode.Str, Save.Str) < 0 then
    Save.Left := NewNode
  else
    Save.Right := NewNode;
  // RB balanced
  NewNode.Color := tcRed;
  while (NewNode <> FRoot) and (NewNode.Parent.Color = tcRed) do
  begin
    if (NewNode.Parent.Parent <> nil) and (NewNode.Parent = NewNode.Parent.Parent.Left) then
    begin
      Current := NewNode.Parent.Parent.Right;
      if (Current <> nil) and (Current.Color = tcRed) then
      begin
        NewNode.Parent.Color := tcBlack;
        Current.Color := tcBlack;
        NewNode.Parent.Parent.Color := tcRed;
        NewNode := NewNode.Parent.Parent;
      end
      else
      begin
        if NewNode = NewNode.Parent.Right then
        begin
          NewNode := NewNode.Parent;
          RotateLeft(NewNode);
        end;
        NewNode.Parent.Color := tcBlack;
        NewNode.Parent.Parent.Color := tcRed;
        RotateRight(NewNode.Parent.Parent);
      end;
    end
    else
    begin
      if NewNode.Parent.Parent = nil then
        Current := nil
      else
        Current := NewNode.Parent.Parent.Left;
      if (Current <> nil) and (Current.Color = tcRed) then
      begin
        NewNode.Parent.Color := tcBlack;
        Current.Color := tcBlack;
        NewNode.Parent.Parent.Color := tcRed;
        NewNode := NewNode.Parent.Parent;
      end
      else
      begin
        if NewNode = NewNode.Parent.Left then
        begin
          NewNode := NewNode.Parent;
          RotateRight(NewNode);
        end;
        NewNode.Parent.Color := tcBlack;
        if NewNode.Parent.Parent <> nil then
          NewNode.Parent.Parent.Color := tcRed;
        RotateLeft(NewNode.Parent.Parent);
      end;
    end;
  end;
  FRoot.Color := tcBlack;
  Inc(FCount);
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1575; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashedStrBinaryTree.AddAll(const ACollection: IStrCollection);
var
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1576 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1576; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashedStrBinaryTree.Clear;
var
  Current: PStrHashBinaryNode;
  Save: PStrHashBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1577 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  // iterative version
  Current := FRoot;
  while Current <> nil do
  begin
    if Current.Left <> nil then
      Current := Current.Left
    else
    if Current.Right <> nil then
      Current := Current.Right
    else
    begin
      Current.Str := ''; // Force Release
      Current.Hash := 0;
      if Current.Parent = nil then // Root
      begin
        FreeMem(Current);
        Current := nil;
        FRoot := nil;
      end
      else
      begin
        Save := Current;
        Current := Current.Parent;
        if Save = Current.Right then // True = from Right
        begin
          FreeMem(Save);
          Current.Right := nil;
        end
        else
        begin
          FreeMem(Save);
          Current.Left := nil;
        end
      end;
    end;
  end;
  FCount := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1577; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashedStrBinaryTree.Clone: TObject;
var
  NewTree: THashedStrBinaryTree;

  function CloneNode(Node, Parent: PStrHashBinaryNode): PStrHashBinaryNode;
  begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1578 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
    if Node <> nil then
    begin
      GetMem(Result, SizeOf(TStrHashBinaryNode));
      Result.Str := Node.Str;
      Result.Hash := Node.Hash;
      Result.Color := Node.Color;
      Result.Parent := Parent;
      Result.Left := CloneNode(Node.Left, Result); // recursive call
      Result.Right := CloneNode(Node.Right, Result); // recursive call
    end
    else
      Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1578; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
  end;

begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1579 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewTree := THashedStrBinaryTree.Create(FHashFunction);
  NewTree.FCount := FCount;
  NewTree.FRoot := CloneNode(FRoot, nil);
  Result := NewTree;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1579; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashedStrBinaryTree.Contains(const AString: string): Boolean;
var
  Comp: Integer;
  Current: PStrHashBinaryNode;
  Hash: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1580 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AString = '' then
    Exit;
  Hash := HashStr(AString);
  // iterative version
  Current := FRoot;
  while Current <> nil do
  begin
    Comp := DoCompare(Current.Hash, Hash, Current.Str, AString);
    if Comp = 0 then
    begin
      Result := True;
      Break;
    end
    else
    if Comp > 0 then
      Current := Current.Left
    else
      Current := Current.Right;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1580; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashedStrBinaryTree.ContainsAll(const ACollection: IStrCollection): Boolean;
var
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1581 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := True;
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while Result and It.HasNext do
    Result := Contains(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1581; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashedStrBinaryTree.Equals(const ACollection: IStrCollection): Boolean;
var
  It, ItSelf: IStrIterator;
  H1, H2: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1582 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then
    Exit;
  if FCount <> ACollection.Size then
    Exit;
  It := ACollection.First;
  ItSelf := First;
  while ItSelf.HasNext do
  begin
    H1 := HashStr(ItSelf.Next);
    H2 := HashStr(It.Next);
    if H1 <> H2 then
      Exit;
  end;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1582; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashedStrBinaryTree.First: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1583 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  case GetTraverseOrder of
    toPreOrder:
      Result := TPreOrderStrHashItr.Create(Self, FRoot);
    toOrder:
      Result := TInOrderStrHashItr.Create(Self, FRoot);
    toPostOrder:
      Result := TPostOrderStrHashItr.Create(Self, FRoot);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1583; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashedStrBinaryTree.GetCaseSensitivity: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1584 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCaseSensitive;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1584; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashedStrBinaryTree.GetTraverseOrder: TTraverseOrder;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1585 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FTraverseOrder;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1585; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashedStrBinaryTree.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1586 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1586; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashedStrBinaryTree.Last: IStrIterator;
var
  Start: PStrHashBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1587 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Start := FRoot;
  case FTraverseOrder of
    toPreOrder:
      begin
        if Start <> nil then
          while Start.Right <> nil do
            Start := Start.Right;
        Result := TPreOrderStrHashItr.Create(Self, Start);
      end;
    toOrder:
      begin
        if Start <> nil then
          while Start.Right <> nil do
            Start := Start.Right;
        Result := TInOrderStrHashItr.Create(Self, Start);
      end;
    toPostOrder:
      Result := TPostOrderStrHashItr.Create(Self, Start);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1587; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashedStrBinaryTree.Remove(const AString: string): Boolean;
var
  Current: PStrHashBinaryNode;
  Node: PStrHashBinaryNode;
  Save: PStrHashBinaryNode;
  Hash: Integer;
  Comp: Integer;

  procedure Correction(Node: PStrHashBinaryNode);
  var
    TempNode: PStrHashBinaryNode;
  begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1588 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
    while (Node <> FRoot) and (Node.Color = tcBlack) do
    begin
      if Node = Node.Parent.Left then
      begin
        TempNode := Node.Parent.Right;
        if TempNode = nil then
        begin
          Node := Node.Parent;
          Continue;
        end;
        if TempNode.Color = tcRed then
        begin
          TempNode.Color := tcBlack;
          Node.Parent.Color := tcRed;
          RotateLeft(Node.Parent);
          TempNode := Node.Parent.Right;
        end;
        if (TempNode.Left <> nil) and (TempNode.Left.Color = tcBlack) and
          (TempNode.Right <> nil) and (TempNode.Right.Color = tcBlack) then
        begin
          TempNode.Color := tcRed;
          Node := Node.Parent;
        end
        else
        begin
          if (TempNode.Right <> nil) and (TempNode.Right.Color = tcBlack) then
          begin
            TempNode.Left.Color := tcBlack;
            TempNode.Color := tcRed;
            RotateRight(TempNode);
            TempNode := Node.Parent.Right;
          end;
          TempNode.Color := Node.Parent.Color;
          Node.Parent.Color := tcBlack;
          if TempNode.Right <> nil then
            TempNode.Right.Color := tcBlack;
          RotateLeft(Node.Parent);
          Node := FRoot;
        end;
      end
      else
      begin
        TempNode := Node.Parent.Left;
        if TempNode = nil then
        begin
          Node := Node.Parent;
          Continue;
        end;
        if TempNode.Color = tcRed then
        begin
          TempNode.Color := tcBlack;
          Node.Parent.Color := tcRed;
          RotateRight(Node.Parent);
          TempNode := Node.Parent.Left;
        end;
        if (TempNode.Left.Color = tcBlack) and (TempNode.Right.Color = tcBlack) then
        begin
          TempNode.Color := tcRed;
          Node := Node.Parent;
        end
        else
        begin
          if TempNode.Left.Color = tcBlack then
          begin
            TempNode.Right.Color := tcBlack;
            TempNode.Color := tcRed;
            RotateLeft(TempNode);
            TempNode := Node.Parent.Left;
          end;
          TempNode.Color := Node.Parent.Color;
          Node.Parent.Color := tcBlack;
          if TempNode.Left <> nil then
            TempNode.Left.Color := tcBlack;
          RotateRight(Node.Parent);
          Node := FRoot;
        end;
      end
    end;
    Node.Color := tcBlack;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1588; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
  end;

begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1589 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AString = '' then
    Exit;
  // locate AObject in the tree
  Current := FRoot;
  Hash := HashStr(AString);
  while Current <> nil do
  begin
    Comp := DoCompare(Hash, Current.Hash, AString, Current.Str);
    if Comp = 0 then
      Break
    else
    if Comp < 0 then
      Current := Current.Left
    else
      Current := Current.Right;
  end;
  if Current = nil then
    Exit;
  // Remove
  if (Current.Left = nil) or (Current.Right = nil) then
    Save := Current
  else
  begin // Successor in Save
    if Current.Right <> nil then
    begin
      Save := Current.Right;
      while Save.Left <> nil do // Minimum
        Save := Save.Left;
    end
    else
    begin
      Save := Current.Parent;
      while (Save <> nil) and (Current = Save.Right) do
      begin
        Current := Save;
        Save := Save.Parent;
      end;
    end;
  end;
  if Save.Left <> nil then
    Node := Save.Left
  else
    Node := Save.Right;
  if Node <> nil then
  begin
    Node.Parent := Save.Parent;
    if Save.Parent = nil then
      FRoot := Node
    else
    if Save = Save.Parent.Left then
      Save.Parent.Left := Node
    else
      Save.Parent.Right := Node;
    if Save.Color = tcBlack then // Correction
      Correction(Node);
  end
  else
  if Save.Parent = nil then
    FRoot := nil
  else
  begin
    if Save.Color = tcBlack then // Correction
      Correction(Save);
    if Save.Parent <> nil then
      if Save = Save.Parent.Left then
        Save.Parent.Left := nil
      else
      if Save = Save.Parent.Right then
        Save.Parent.Right := nil
  end;
  FreeMem(Save);
  Dec(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1589; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashedStrBinaryTree.RemoveAll(const ACollection: IStrCollection);
var
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1590 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Remove(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1590; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashedStrBinaryTree.RetainAll(const ACollection: IStrCollection);
var
  It: IStrIterator;
  S: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1591 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := First;
  while It.HasNext do
  begin
    S := It.Next;
    if not ACollection.Contains(S) then
      Remove(S);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1591; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashedStrBinaryTree.RotateLeft(Node: PStrHashBinaryNode);
var
  TempNode: PStrHashBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1592 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Node = nil then
    Exit;
  TempNode := Node.Right;
  //  if TempNode = nil then	Exit;
  Node.Right := TempNode.Left;
  if TempNode.Left <> nil then
    TempNode.Left.Parent := Node;
  TempNode.Parent := Node.Parent;
  if Node.Parent = nil then
    FRoot := TempNode
  else
  if Node.Parent.Left = Node then
    Node.Parent.Left := TempNode
  else
    Node.Parent.Right := TempNode;
  TempNode.Left := Node;
  Node.Parent := TempNode;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1592; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashedStrBinaryTree.RotateRight(Node: PStrHashBinaryNode);
var
  TempNode: PStrHashBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1593 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Node = nil then
    Exit;
  TempNode := Node.Left;
  //  if TempNode = nil then 	Exit;
  Node.Left := TempNode.Right;
  if TempNode.Right <> nil then
    TempNode.Right.Parent := Node;
  TempNode.Parent := Node.Parent;
  if Node.Parent = nil then
    FRoot := TempNode
  else
  if Node.Parent.Right = Node then
    Node.Parent.Right := TempNode
  else
    Node.Parent.Left := TempNode;
  TempNode.Right := Node;
  Node.Parent := TempNode;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1593; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashedStrBinaryTree.SetCaseSensitivity(Value: Boolean);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1594 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FCaseSensitive := Value;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1594; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure THashedStrBinaryTree.SetTraverseOrder(Value: TTraverseOrder);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1595 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FTraverseOrder := Value;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1595; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function THashedStrBinaryTree.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1596 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1596; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TPtrBinaryTree } =====================================================

constructor TPtrBinaryTree.Create(AComparator: TPointerCompare = nil);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1597 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if Assigned(AComparator) then
    FComparator := AComparator;
    
  FTraverseOrder := toPreOrder;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1597; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TPtrBinaryTree.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1598 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1598; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrBinaryTree.DoCompare(P1, P2: Pointer): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1599 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Assigned(FComparator) then
  begin
    Result := FComparator(P1, P2);
  end else
  begin
    Result := Integer(Longword(P1) - Longword(P2));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1599; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrBinaryTree.Add(APtr: Pointer): Boolean;
var
  NewNode: PPtrBinaryNode;
  Current, Save: PPtrBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1600 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if APtr = nil then
    Exit;
  NewNode := AllocMem(SizeOf(TPtrBinaryNode));
  NewNode.Ptr := APtr;
  // Insert into right place
  Save := nil;
  Current := FRoot;
  while Current <> nil do
  begin
    Save := Current;
    if DoCompare(NewNode.Ptr, Current.Ptr) < 0 then
      Current := Current.Left
    else
      Current := Current.Right;
  end;
  NewNode.Parent := Save;
  if Save = nil then
    FRoot := NewNode
  else
  if DoCompare(NewNode.Ptr, Save.Ptr) < 0 then
    Save.Left := NewNode
  else
    Save.Right := NewNode;
  // RB balanced
  NewNode.Color := tcRed;
  while (NewNode <> FRoot) and (NewNode.Parent.Color = tcRed) do
  begin
    if (NewNode.Parent.Parent <> nil) and (NewNode.Parent = NewNode.Parent.Parent.Left) then
    begin
      Current := NewNode.Parent.Parent.Right;
      if (Current <> nil) and (Current.Color = tcRed) then
      begin
        NewNode.Parent.Color := tcBlack;
        Current.Color := tcBlack;
        NewNode.Parent.Parent.Color := tcRed;
        NewNode := NewNode.Parent.Parent;
      end
      else
      begin
        if NewNode = NewNode.Parent.Right then
        begin
          NewNode := NewNode.Parent;
          RotateLeft(NewNode);
        end;
        NewNode.Parent.Color := tcBlack;
        NewNode.Parent.Parent.Color := tcRed;
        RotateRight(NewNode.Parent.Parent);
      end;
    end
    else
    begin
      if NewNode.Parent.Parent = nil then
        Current := nil
      else
        Current := NewNode.Parent.Parent.Left;
      if (Current <> nil) and (Current.Color = tcRed) then
      begin
        NewNode.Parent.Color := tcBlack;
        Current.Color := tcBlack;
        NewNode.Parent.Parent.Color := tcRed;
        NewNode := NewNode.Parent.Parent;
      end
      else
      begin
        if NewNode = NewNode.Parent.Left then
        begin
          NewNode := NewNode.Parent;
          RotateRight(NewNode);
        end;
        NewNode.Parent.Color := tcBlack;
        if NewNode.Parent.Parent <> nil then
          NewNode.Parent.Parent.Color := tcRed;
        RotateLeft(NewNode.Parent.Parent);
      end;
    end;
  end;
  FRoot.Color := tcBlack;
  Inc(FCount);
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1600; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrBinaryTree.AddAll(const ACollection: IPtrCollection);
var
  It: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1601 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1601; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrBinaryTree.Clear;
var
  Current: PPtrBinaryNode;
  Save: PPtrBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1602 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  // iterative version
  Current := FRoot;
  while Current <> nil do
  begin
    if Current.Left <> nil then
      Current := Current.Left
    else
    if Current.Right <> nil then
      Current := Current.Right
    else
    begin
      Current.Ptr := nil; // Force Release
      if Current.Parent = nil then // Root
      begin
        FreeMem(Current);
        Current := nil;
        FRoot := nil;
      end
      else
      begin
        Save := Current;
        Current := Current.Parent;
        if Save = Current.Right then // True = from Right
        begin
          FreeMem(Save);
          Current.Right := nil;
        end
        else
        begin
          FreeMem(Save);
          Current.Left := nil;
        end
      end;
    end;
  end;
  FCount := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1602; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrBinaryTree.Clone: TObject;
var
  NewTree: TPtrBinaryTree;

  function CloneNode(Node, Parent: PPtrBinaryNode): PPtrBinaryNode;
  begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1603 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
    if Node <> nil then
    begin
      GetMem(Result, SizeOf(TPtrBinaryNode));
      Result.Ptr := Node.Ptr;
      Result.Color := Node.Color;
      Result.Parent := Parent;
      Result.Left := CloneNode(Node.Left, Result); // recursive call
      Result.Right := CloneNode(Node.Right, Result); // recursive call
    end
    else
      Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1603; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
  end;

begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1604 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewTree := TPtrBinaryTree.Create(FComparator);
  NewTree.FCount := FCount;
  NewTree.FRoot := CloneNode(FRoot, nil);
  Result := NewTree;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1604; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrBinaryTree.Contains(APtr: Pointer): Boolean;
var
  Comp: Integer;
  Current: PPtrBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1605 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if APtr = nil then
    Exit;
  // iterative version
  Current := FRoot;
  while Current <> nil do
  begin
    Comp := DoCompare(Current.Ptr, APtr);
    if Comp = 0 then
    begin
      Result := True;
      Break;
    end
    else
    if Comp > 0 then
      Current := Current.Left
    else
      Current := Current.Right;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1605; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrBinaryTree.ContainsAll(const ACollection: IPtrCollection): Boolean;
var
  It: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1606 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := True;
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while Result and It.HasNext do
    Result := Contains(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1606; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrBinaryTree.Equals(const ACollection: IPtrCollection): Boolean;
var
  It, ItSelf: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1607 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then
    Exit;
  if FCount <> ACollection.Size then
    Exit;
  It := ACollection.First;
  ItSelf := First;
  while ItSelf.HasNext do
    if DoCompare(ItSelf.Next, It.Next) <> 0 then
      Exit;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1607; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrBinaryTree.First: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1608 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  case GetTraverseOrder of
    toPreOrder:
      Result := TPreOrderPtrItr.Create(Self, FRoot);
    toOrder:
      Result := TInOrderPtrItr.Create(Self, FRoot);
    toPostOrder:
      Result := TPostOrderPtrItr.Create(Self, FRoot);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1608; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrBinaryTree.GetTraverseOrder: TTraverseOrder;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1609 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FTraverseOrder;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1609; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrBinaryTree.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1610 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1610; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrBinaryTree.Last: IPtrIterator;
var
  Start: PPtrBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1611 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Start := FRoot;
  case FTraverseOrder of
    toPreOrder:
      begin
        if Start <> nil then
          while Start.Right <> nil do
            Start := Start.Right;
        Result := TPreOrderPtrItr.Create(Self, Start);
      end;
    toOrder:
      begin
        if Start <> nil then
          while Start.Right <> nil do
            Start := Start.Right;
        Result := TInOrderPtrItr.Create(Self, Start);
      end;
    toPostOrder:
      Result := TPostOrderPtrItr.Create(Self, Start);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1611; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrBinaryTree.Remove(APtr: Pointer): Boolean;
var
  Current: PPtrBinaryNode;
  Node: PPtrBinaryNode;
  Save: PPtrBinaryNode;
  Comp: Integer;

  procedure Correction(Node: PPtrBinaryNode);
  var
    TempNode: PPtrBinaryNode;
  begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1612 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
    while (Node <> FRoot) and (Node.Color = tcBlack) do
    begin
      if Node = Node.Parent.Left then
      begin
        TempNode := Node.Parent.Right;
        if TempNode = nil then
        begin
          Node := Node.Parent;
          Continue;
        end;
        if TempNode.Color = tcRed then
        begin
          TempNode.Color := tcBlack;
          Node.Parent.Color := tcRed;
          RotateLeft(Node.Parent);
          TempNode := Node.Parent.Right;
        end;
        if (TempNode.Left <> nil) and (TempNode.Left.Color = tcBlack) and
          (TempNode.Right <> nil) and (TempNode.Right.Color = tcBlack) then
        begin
          TempNode.Color := tcRed;
          Node := Node.Parent;
        end
        else
        begin
          if (TempNode.Right <> nil) and (TempNode.Right.Color = tcBlack) then
          begin
            TempNode.Left.Color := tcBlack;
            TempNode.Color := tcRed;
            RotateRight(TempNode);
            TempNode := Node.Parent.Right;
          end;
          TempNode.Color := Node.Parent.Color;
          Node.Parent.Color := tcBlack;
          if TempNode.Right <> nil then
            TempNode.Right.Color := tcBlack;
          RotateLeft(Node.Parent);
          Node := FRoot;
        end;
      end
      else
      begin
        TempNode := Node.Parent.Left;
        if TempNode = nil then
        begin
          Node := Node.Parent;
          Continue;
        end;
        if TempNode.Color = tcRed then
        begin
          TempNode.Color := tcBlack;
          Node.Parent.Color := tcRed;
          RotateRight(Node.Parent);
          TempNode := Node.Parent.Left;
        end;
        if (TempNode.Left.Color = tcBlack) and (TempNode.Right.Color = tcBlack) then
        begin
          TempNode.Color := tcRed;
          Node := Node.Parent;
        end
        else
        begin
          if TempNode.Left.Color = tcBlack then
          begin
            TempNode.Right.Color := tcBlack;
            TempNode.Color := tcRed;
            RotateLeft(TempNode);
            TempNode := Node.Parent.Left;
          end;
          TempNode.Color := Node.Parent.Color;
          Node.Parent.Color := tcBlack;
          if TempNode.Left <> nil then
            TempNode.Left.Color := tcBlack;
          RotateRight(Node.Parent);
          Node := FRoot;
        end;
      end
    end;
    Node.Color := tcBlack;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1612; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
  end;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1613 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if APtr = nil then
    Exit;
  // locate AObject in the tree
  Current := FRoot;
  while Current <> nil do
  begin
    Comp := DoCompare(APtr, Current.Ptr);
    if Comp = 0 then
      Break
    else
    if Comp < 0 then
      Current := Current.Left
    else
      Current := Current.Right;
  end;
  if Current = nil then
    Exit;
  // Remove
  if (Current.Left = nil) or (Current.Right = nil) then
    Save := Current
  else
  begin // Successor in Save
    if Current.Right <> nil then
    begin
      Save := Current.Right;
      while Save.Left <> nil do // Minimum
        Save := Save.Left;
    end
    else
    begin
      Save := Current.Parent;
      while (Save <> nil) and (Current = Save.Right) do
      begin
        Current := Save;
        Save := Save.Parent;
      end;
    end;
  end;
  if Save.Left <> nil then
    Node := Save.Left
  else
    Node := Save.Right;
  if Node <> nil then
  begin
    Node.Parent := Save.Parent;
    if Save.Parent = nil then
      FRoot := Node
    else
    if Save = Save.Parent.Left then
      Save.Parent.Left := Node
    else
      Save.Parent.Right := Node;
    if Save.Color = tcBlack then // Correction
      Correction(Node);
  end
  else
  if Save.Parent = nil then
    FRoot := nil
  else
  begin
    if Save.Color = tcBlack then // Correction
      Correction(Save);
    if Save.Parent <> nil then
      if Save = Save.Parent.Left then
        Save.Parent.Left := nil
      else
      if Save = Save.Parent.Right then
        Save.Parent.Right := nil
  end;
  FreeMem(Save);
  Dec(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1613; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrBinaryTree.RemoveAll(const ACollection: IPtrCollection);
var
  It: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1614 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Remove(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1614; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrBinaryTree.RetainAll(const ACollection: IPtrCollection);
var
  It: IPtrIterator;
  P: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1615 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := First;
  while It.HasNext do
  begin
    P := It.Next;
    if not ACollection.Contains(P) then
      Remove(P);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1615; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrBinaryTree.RotateLeft(Node: PPtrBinaryNode);
var
  TempNode: PPtrBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1616 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Node = nil then
    Exit;
  TempNode := Node.Right;
  //  if TempNode = nil then	Exit;
  Node.Right := TempNode.Left;
  if TempNode.Left <> nil then
    TempNode.Left.Parent := Node;
  TempNode.Parent := Node.Parent;
  if Node.Parent = nil then
    FRoot := TempNode
  else
  if Node.Parent.Left = Node then
    Node.Parent.Left := TempNode
  else
    Node.Parent.Right := TempNode;
  TempNode.Left := Node;
  Node.Parent := TempNode;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1616; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrBinaryTree.RotateRight(Node: PPtrBinaryNode);
var
  TempNode: PPtrBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1617 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Node = nil then
    Exit;
  TempNode := Node.Left;
  //  if TempNode = nil then 	Exit;
  Node.Left := TempNode.Right;
  if TempNode.Right <> nil then
    TempNode.Right.Parent := Node;
  TempNode.Parent := Node.Parent;
  if Node.Parent = nil then
    FRoot := TempNode
  else
  if Node.Parent.Right = Node then
    Node.Parent.Right := TempNode
  else
    Node.Parent.Left := TempNode;
  TempNode.Right := Node;
  Node.Parent := TempNode;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1617; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrBinaryTree.SetTraverseOrder(Value: TTraverseOrder);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1618 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FTraverseOrder := Value;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1618; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrBinaryTree.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1619 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1619; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TBinaryTree } =====================================================

constructor TBinaryTree.Create(AComparator: TObjectCompare = nil);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1620 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  if Assigned(AComparator) then
    FComparator := AComparator;
  FTraverseOrder := toPreOrder;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1620; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TBinaryTree.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1621 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1621; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TBinaryTree.DoCompare(O1, O2: TObject): Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1622 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Assigned(FComparator) then
  begin
    Result := FComparator(O1, O2);
  end else
  begin
    Result := Integer(Longword(O1) - Longword(O2));
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1622; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TBinaryTree.Add(AObject: TObject): Boolean;
var
  NewNode: PBinaryNode;
  Current, Save: PBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1623 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AObject = nil then
    Exit;
  NewNode := AllocMem(SizeOf(TBinaryNode));
  NewNode.Obj := AObject;
  // Insert into right place
  Save := nil;
  Current := FRoot;
  while Current <> nil do
  begin
    Save := Current;
    if DoCompare(NewNode.Obj, Current.Obj) < 0 then
      Current := Current.Left
    else
      Current := Current.Right;
  end;
  NewNode.Parent := Save;
  if Save = nil then
    FRoot := NewNode
  else
  if DoCompare(NewNode.Obj, Save.Obj) < 0 then
    Save.Left := NewNode
  else
    Save.Right := NewNode;
  // RB balanced
  NewNode.Color := tcRed;
  while (NewNode <> FRoot) and (NewNode.Parent.Color = tcRed) do
  begin
    if (NewNode.Parent.Parent <> nil) and (NewNode.Parent = NewNode.Parent.Parent.Left) then
    begin
      Current := NewNode.Parent.Parent.Right;
      if Current.Color = tcRed then
      begin
        NewNode.Parent.Color := tcBlack;
        Current.Color := tcBlack;
        NewNode.Parent.Parent.Color := tcRed;
        NewNode := NewNode.Parent.Parent;
      end
      else
      begin
        if NewNode = NewNode.Parent.Right then
        begin
          NewNode := NewNode.Parent;
          RotateLeft(NewNode);
        end;
        NewNode.Parent.Color := tcBlack;
        NewNode.Parent.Parent.Color := tcRed;
        RotateRight(NewNode.Parent.Parent);
      end;
    end
    else
    begin
      if NewNode.Parent.Parent = nil then
        Current := nil
      else
        Current := NewNode.Parent.Parent.Left;
      if (Current <> nil) and (Current.Color = tcRed) then
      begin
        NewNode.Parent.Color := tcBlack;
        Current.Color := tcBlack;
        NewNode.Parent.Parent.Color := tcRed;
        NewNode := NewNode.Parent.Parent;
      end
      else
      begin
        if NewNode = NewNode.Parent.Left then
        begin
          NewNode := NewNode.Parent;
          RotateRight(NewNode);
        end;
        NewNode.Parent.Color := tcBlack;
        if NewNode.Parent.Parent <> nil then
          NewNode.Parent.Parent.Color := tcRed;
        RotateLeft(NewNode.Parent.Parent);
      end;
    end;
  end;
  FRoot.Color := tcBlack;
  Inc(FCount);
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1623; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TBinaryTree.AddAll(const ACollection: ICollection);
var
  It: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1624 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1624; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TBinaryTree.Clear;
var
  Current: PBinaryNode;
  Save: PBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1625 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  // iterative version
  Current := FRoot;
  while Current <> nil do
  begin
    if Current.Left <> nil then
      Current := Current.Left
    else
    if Current.Right <> nil then
      Current := Current.Right
    else
    begin
      Current.Obj := nil; // Force Release
      if Current.Parent = nil then // Root
      begin
        FreeMem(Current);
        Current := nil;
        FRoot := nil;
      end
      else
      begin
        Save := Current;
        Current := Current.Parent;
        if Save = Current.Right then // True = from Right
        begin
          FreeMem(Save);
          Current.Right := nil;
        end
        else
        begin
          FreeMem(Save);
          Current.Left := nil;
        end
      end;
    end;
  end;
  FCount := 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1625; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TBinaryTree.Clone: TObject;
var
  NewTree: TBinaryTree;

  function CloneNode(Node, Parent: PBinaryNode): PBinaryNode;
  begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1626 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
    if Node <> nil then
    begin
      GetMem(Result, SizeOf(TBinaryNode));
      Result.Obj := Node.Obj;
      Result.Color := Node.Color;
      Result.Parent := Parent;
      Result.Left := CloneNode(Node.Left, Result); // recursive call
      Result.Right := CloneNode(Node.Right, Result); // recursive call
    end
    else
      Result := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1626; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
  end;

begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1627 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewTree := TBinaryTree.Create(FComparator);
  NewTree.FCount := FCount;
  NewTree.FRoot := CloneNode(FRoot, nil);
  Result := NewTree;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1627; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TBinaryTree.Contains(AObject: TObject): Boolean;
var
  Comp: Integer;
  Current: PBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1628 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AObject = nil then
    Exit;
  // iterative version
  Current := FRoot;
  while Current <> nil do
  begin
    Comp := DoCompare(Current.Obj, AObject);
    if Comp = 0 then
    begin
      Result := True;
      Break;
    end
    else
    if Comp > 0 then
      Current := Current.Left
    else
      Current := Current.Right;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1628; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TBinaryTree.ContainsAll(const ACollection: ICollection): Boolean;
var
  It: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1629 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := True;
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while Result and It.HasNext do
    Result := Contains(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1629; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TBinaryTree.Equals(const ACollection: ICollection): Boolean;
var
  It, ItSelf: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1630 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then
    Exit;
  if FCount <> ACollection.Size then
    Exit;
  It := ACollection.First;
  ItSelf := First;
  while ItSelf.HasNext do
    if DoCompare(ItSelf.Next, It.Next) <> 0 then
      Exit;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1630; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TBinaryTree.First: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1631 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  case GetTraverseOrder of
    toPreOrder:
      Result := TPreOrderItr.Create(Self, FRoot);
    toOrder:
      Result := TInOrderItr.Create(Self, FRoot);
    toPostOrder:
      Result := TPostOrderItr.Create(Self, FRoot);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1631; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TBinaryTree.GetTraverseOrder: TTraverseOrder;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1632 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FTraverseOrder;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1632; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TBinaryTree.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1633 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1633; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TBinaryTree.Last: IIterator;
var
  Start: PBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1634 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Start := FRoot;
  case FTraverseOrder of
    toPreOrder:
      begin
        if Start <> nil then
          while Start.Right <> nil do
            Start := Start.Right;
        Result := TPreOrderItr.Create(Self, Start);
      end;
    toOrder:
      begin
        if Start <> nil then
          while Start.Right <> nil do
            Start := Start.Right;
        Result := TInOrderItr.Create(Self, Start);
      end;
    toPostOrder:
      Result := TPostOrderItr.Create(Self, Start);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1634; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TBinaryTree.Remove(AObject: TObject): Boolean;
var
  Current: PBinaryNode;
  Node: PBinaryNode;
  Save: PBinaryNode;
  Comp: Integer;

  procedure Correction(Node: PBinaryNode);
  var
    TempNode: PBinaryNode;
  begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1635 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
    while (Node <> FRoot) and (Node.Color = tcBlack) do
    begin
      if Node = Node.Parent.Left then
      begin
        TempNode := Node.Parent.Right;
        if TempNode = nil then
        begin
          Node := Node.Parent;
          Continue;
        end;
        if TempNode.Color = tcRed then
        begin
          TempNode.Color := tcBlack;
          Node.Parent.Color := tcRed;
          RotateLeft(Node.Parent);
          TempNode := Node.Parent.Right;
        end;
        if (TempNode.Left <> nil) and (TempNode.Left.Color = tcBlack) and
          (TempNode.Right <> nil) and (TempNode.Right.Color = tcBlack) then
        begin
          TempNode.Color := tcRed;
          Node := Node.Parent;
        end
        else
        begin
          if (TempNode.Right <> nil) and (TempNode.Right.Color = tcBlack) then
          begin
            TempNode.Left.Color := tcBlack;
            TempNode.Color := tcRed;
            RotateRight(TempNode);
            TempNode := Node.Parent.Right;
          end;
          TempNode.Color := Node.Parent.Color;
          Node.Parent.Color := tcBlack;
          if TempNode.Right <> nil then
            TempNode.Right.Color := tcBlack;
          RotateLeft(Node.Parent);
          Node := FRoot;
        end;
      end
      else
      begin
        TempNode := Node.Parent.Left;
        if TempNode = nil then
        begin
          Node := Node.Parent;
          Continue;
        end;
        if TempNode.Color = tcRed then
        begin
          TempNode.Color := tcBlack;
          Node.Parent.Color := tcRed;
          RotateRight(Node.Parent);
          TempNode := Node.Parent.Left;
        end;
        if (TempNode.Left.Color = tcBlack) and (TempNode.Right.Color = tcBlack) then
        begin
          TempNode.Color := tcRed;
          Node := Node.Parent;
        end
        else
        begin
          if TempNode.Left.Color = tcBlack then
          begin
            TempNode.Right.Color := tcBlack;
            TempNode.Color := tcRed;
            RotateLeft(TempNode);
            TempNode := Node.Parent.Left;
          end;
          TempNode.Color := Node.Parent.Color;
          Node.Parent.Color := tcBlack;
          if TempNode.Left <> nil then
            TempNode.Left.Color := tcBlack;
          RotateRight(Node.Parent);
          Node := FRoot;
        end;
      end
    end;
    Node.Color := tcBlack;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1635; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
  end;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1636 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AObject = nil then
    Exit;
  // locate AObject in the tree
  Current := FRoot;
  while Current <> nil do
  begin
    Comp := DoCompare(AObject, Current.Obj);
    if Comp = 0 then
      Break
    else
    if Comp < 0 then
      Current := Current.Left
    else
      Current := Current.Right;
  end;
  if Current = nil then
    Exit;
  // Remove
  if (Current.Left = nil) or (Current.Right = nil) then
    Save := Current
  else
  begin // Successor in Save
    if Current.Right <> nil then
    begin
      Save := Current.Right;
      while Save.Left <> nil do // Minimum
        Save := Save.Left;
    end
    else
    begin
      Save := Current.Parent;
      while (Save <> nil) and (Current = Save.Right) do
      begin
        Current := Save;
        Save := Save.Parent;
      end;
    end;
  end;
  if Save.Left <> nil then
    Node := Save.Left
  else
    Node := Save.Right;
  if Node <> nil then
  begin
    Node.Parent := Save.Parent;
    if Save.Parent = nil then
      FRoot := Node
    else
    if Save = Save.Parent.Left then
      Save.Parent.Left := Node
    else
      Save.Parent.Right := Node;
    if Save.Color = tcBlack then // Correction
      Correction(Node);
  end
  else
  if Save.Parent = nil then
    FRoot := nil
  else
  begin
    if Save.Color = tcBlack then // Correction
      Correction(Save);
    if Save.Parent <> nil then
      if Save = Save.Parent.Left then
        Save.Parent.Left := nil
      else
      if Save = Save.Parent.Right then
        Save.Parent.Right := nil
  end;
  FreeMem(Save);
  Dec(FCount);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1636; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TBinaryTree.RemoveAll(const ACollection: ICollection);
var
  It: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1637 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Remove(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1637; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TBinaryTree.RetainAll(const ACollection: ICollection);
var
  It: IIterator;
  O: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1638 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := First;
  while It.HasNext do
  begin
    O := It.Next;
    if not ACollection.Contains(O) then
      Remove(O);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1638; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TBinaryTree.RotateLeft(Node: PBinaryNode);
var
  TempNode: PBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1639 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Node = nil then
    Exit;
  TempNode := Node.Right;
  //  if TempNode = nil then	Exit;
  Node.Right := TempNode.Left;
  if TempNode.Left <> nil then
    TempNode.Left.Parent := Node;
  TempNode.Parent := Node.Parent;
  if Node.Parent = nil then
    FRoot := TempNode
  else
  if Node.Parent.Left = Node then
    Node.Parent.Left := TempNode
  else
    Node.Parent.Right := TempNode;
  TempNode.Left := Node;
  Node.Parent := TempNode;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1639; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TBinaryTree.RotateRight(Node: PBinaryNode);
var
  TempNode: PBinaryNode;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1640 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if Node = nil then
    Exit;
  TempNode := Node.Left;
  //  if TempNode = nil then 	Exit;
  Node.Left := TempNode.Right;
  if TempNode.Right <> nil then
    TempNode.Right.Parent := Node;
  TempNode.Parent := Node.Parent;
  if Node.Parent = nil then
    FRoot := TempNode
  else
  if Node.Parent.Right = Node then
    Node.Parent.Right := TempNode
  else
    Node.Parent.Left := TempNode;
  TempNode.Right := Node;
  Node.Parent := TempNode;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1640; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TBinaryTree.SetTraverseOrder(Value: TTraverseOrder);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1641 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FTraverseOrder := Value;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1641; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TBinaryTree.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,1642 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCount;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,1642; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

end.
