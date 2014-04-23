{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Linked Lists
  
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
unit Bfg.Containers.LinkedLists;

interface

uses
  SysUtils,
  Bfg.Utils,
  Bfg.Containers.Interfaces{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

type
  PIntfLinkedListItem = ^TIntfLinkedListItem;
  TIntfLinkedListItem = record
    Obj: IInterface;
    Next: PIntfLinkedListItem;
  end;

  PStrLinkedListItem = ^TStrLinkedListItem;
  TStrLinkedListItem = record
    Str: string;
    Next: PStrLinkedListItem;
  end;

  PPtrLinkedListItem = ^TPtrLinkedListItem;
  TPtrLinkedListItem = record
    Ptr: Pointer;
    Next: PPtrLinkedListItem;
  end;

  PLinkedListItem = ^TLinkedListItem;
  TLinkedListItem = record
    Obj: TObject;
    Next: PLinkedListItem;
  end;

  TIntfLinkedList = class(TAbstractContainer, IIntfCollection, ICloneable)
  private
    FStart: PIntfLinkedListItem;
    FEnd: PIntfLinkedListItem;
    FSize: Integer;
  public
    procedure AddFirst(const AInterface: IInterface);
    { IIntfCollection }
    function Add(const AInterface: IInterface): Boolean; overload;
    procedure AddAll(const ACollection: IIntfCollection); overload;
    procedure Clear;
    function Contains(const AInterface: IInterface): Boolean;
    function ContainsAll(const ACollection: IIntfCollection): Boolean;
    function Equals(const ACollection: IIntfCollection): Boolean;
    function First: IIntfIterator;
    function IsEmpty: Boolean;
    function Last: IIntfIterator;
    function Remove(const AInterface: IInterface): Boolean; overload;
    procedure RemoveAll(const ACollection: IIntfCollection);
    procedure RetainAll(const ACollection: IIntfCollection);
    function Size: Integer;
    { IIntfList }
    procedure Insert(Index: Integer; const AInterface: IInterface); overload;
    procedure InsertAll(Index: Integer; const ACollection: IIntfCollection); overload;
    function GetIntf(Index: Integer): IInterface;
    function IndexOf(const AInterface: IInterface): Integer;
    function LastIndexOf(const AInterface: IInterface): Integer;
    function Remove(Index: Integer): IInterface; overload;
    procedure SetIntf(Index: Integer; const AInterface: IInterface);
    { ICloneable }
    function Clone: TObject;
  public
    constructor Create(const ACollection: IIntfCollection = nil);
    destructor Destroy; override;
  end;

  //Daniele Teti 02/03/2005
  TStrLinkedList = class(TAbstractContainer, IStrCollection, ICloneable)
  private
    FStart: PStrLinkedListItem;
    FEnd: PStrLinkedListItem;
    FSize: Integer;
    FCaseSensitive: Boolean;
  public
    procedure AddFirst(const AString: string);
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
    function Remove(const AString: string): Boolean; overload;
    procedure RemoveAll(const ACollection: IStrCollection);
    procedure RetainAll(const ACollection: IStrCollection);
    function Size: Integer;
    procedure SetCaseSensitivity(Value: Boolean);
    function GetCaseSensitivity: Boolean;
    { IStrList }
    procedure Insert(Index: Integer; const AString: string);
    procedure InsertAll(Index: Integer; const ACollection: IStrCollection);
    function GetString(Index: Integer): string;
    function IndexOf(const AString: string): Integer;
    function LastIndexOf(const AString: string): Integer;
    function Remove(Index: Integer): string; overload;
    procedure SetString(Index: Integer; const AString: string);
    { ICloneable }
    function Clone: TObject;
  public
    constructor Create(const ACollection: IStrCollection = nil);
    destructor Destroy; override;
  end;

  TPtrLinkedList = class(TAbstractContainer, IPtrCollection, ICloneable)
  private
    FStart: PPtrLinkedListItem;
    FEnd: PPtrLinkedListItem;
    FSize: Integer;
  public
    procedure AddFirst(APtr: Pointer);
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
    function Remove(APtr: Pointer): Boolean; overload;
    procedure RemoveAll(const ACollection: IPtrCollection);
    procedure RetainAll(const ACollection: IPtrCollection);
    function Size: Integer;
    { IPtrList }
    procedure Insert(Index: Integer; APtr: Pointer);
    procedure InsertAll(Index: Integer; const ACollection: IPtrCollection);
    function GetPtr(Index: Integer): Pointer;
    function IndexOf(APtr: Pointer): Integer;
    function LastIndexOf(APtr: Pointer): Integer;
    function Remove(Index: Integer): Pointer; overload;
    procedure SetPtr(Index: Integer; APtr: Pointer);
    { ICloneable }
    function Clone: TObject;
  public
    constructor Create(const ACollection: IPtrCollection = nil);
    destructor Destroy; override;
  end;

  TLinkedList = class(TAbstractContainer, ICollection, ICloneable)
  private
    FStart: PLinkedListItem;
    FEnd: PLinkedListItem;
    FSize: Integer;
    FOwnsObjects: Boolean;
  protected
    procedure FreeObject(var AObject: TObject);
  public
    procedure AddFirst(AObject: TObject);
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
    function Remove(AObject: TObject): Boolean; overload;
    procedure RemoveAll(const ACollection: ICollection);
    procedure RetainAll(const ACollection: ICollection);
    function Size: Integer;
    { IList }
    procedure Insert(Index: Integer; AObject: TObject);
    procedure InsertAll(Index: Integer; const ACollection: ICollection);
    function GetObject(Index: Integer): TObject;
    function IndexOf(AObject: TObject): Integer;
    function LastIndexOf(AObject: TObject): Integer;
    function Remove(Index: Integer): TObject; overload;
    procedure SetObject(Index: Integer; AObject: TObject);
    { ICloneable }
    function Clone: TObject;
  public
    constructor Create(const ACollection: ICollection = nil; AOwnsObjects: Boolean = True);
    destructor Destroy; override;
    property OwnsObjects: Boolean read FOwnsObjects;
  end;

implementation

uses
  Bfg.Resources;

//=== { TIntfItr } ===========================================================

type
  TIntfItr = class(TAbstractContainer, IIntfIterator)
  private
    FCursor: PIntfLinkedListItem;
    FOwnList: TIntfLinkedList;
    FLastRet: PIntfLinkedListItem;
    FSize: Integer;
  protected
    { IIntfIterator }
    function GetIntf: IInterface;
    function HasNext: Boolean;
    function HasPrevious: Boolean;
    function Next: IInterface;
    function Previous: IInterface;
  public
    constructor Create(OwnList: TIntfLinkedList; Start: PIntfLinkedListItem);
  end;

constructor TIntfItr.Create(OwnList: TIntfLinkedList; Start: PIntfLinkedListItem);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2052 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FCursor := Start;
  FOwnList := OwnList;
  FSize := FOwnList.Size;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2052; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfItr.GetIntf: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2053 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Obj;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2053; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2054 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor <> nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2054; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2055 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  raise ECallUnimplemented.Create('The container type is unidirectional!');
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2055; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfItr.Next: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2056 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Obj;
  FLastRet := FCursor;
  FCursor := FCursor.Next;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2056; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfItr.Previous: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2057 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  raise ECallUnimplemented.Create('The container type is unidirectional!');
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2057; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TStrItr } ============================================================

type
  TStrItr = class(TAbstractContainer, IStrIterator)
  private
    FCursor: PStrLinkedListItem;
    FOwnList: TStrLinkedList;
    FLastRet: PStrLinkedListItem;
    FSize: Integer;
  protected
    { IStrIterator }
    function GetString: string;
    function HasNext: Boolean;
    function HasPrevious: Boolean;
    function Next: string;
    function Previous: string;
  public
    constructor Create(OwnList: TStrLinkedList; Start: PStrLinkedListItem);
  end;

constructor TStrItr.Create(OwnList: TStrLinkedList; Start: PStrLinkedListItem);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2058 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FCursor := Start;
  FOwnList := OwnList;
  FSize := FOwnList.Size;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2058; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrItr.GetString: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2059 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Str;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2059; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2060 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor <> nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2060; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2061 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  raise ECallUnimplemented.Create('The container type is unidirectional!');
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2061; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrItr.Next: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2062 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Str;
  FLastRet := FCursor;
  FCursor := FCursor.Next;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2062; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrItr.Previous: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2063 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  raise ECallUnimplemented.Create('The container type is unidirectional!');
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2063; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TItr } ===============================================================

type
  TPtrItr = class(TAbstractContainer, IPtrIterator)
  private
    FCursor: PPtrLinkedListItem;
    FOwnList: TPtrLinkedList;
    FLastRet: PPtrLinkedListItem;
    FSize: Integer;
  public
    { IPtrIterator }
    function GetPtr: Pointer;
    function HasNext: Boolean;
    function HasPrevious: Boolean;
    function Next: Pointer;
    function Previous: Pointer;
  public
    constructor Create(OwnList: TPtrLinkedList; Start: PPtrLinkedListItem);
  end;

constructor TPtrItr.Create(OwnList: TPtrLinkedList; Start: PPtrLinkedListItem);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2064 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FCursor := Start;
  FOwnList := OwnList;
  FSize := FOwnList.Size;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2064; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrItr.GetPtr: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2065 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Ptr;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2065; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2066 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor <> nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2066; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2067 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  raise ECallUnimplemented.Create('The container type is unidirectional!');
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2067; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrItr.Next: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2068 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Ptr;
  FLastRet := FCursor;
  FCursor := FCursor.Next;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2068; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrItr.Previous: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2069 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  raise ECallUnimplemented.Create('The container type is unidirectional!');
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2069; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TItr } ===============================================================

type
  TItr = class(TAbstractContainer, IIterator)
  private
    FCursor: PLinkedListItem;
    FOwnList: TLinkedList;
    FLastRet: PLinkedListItem;
    FSize: Integer;
  public
    { IIterator }
    function GetObject: TObject;
    function HasNext: Boolean;
    function HasPrevious: Boolean;
    function Next: TObject;
    function Previous: TObject;
  public
    constructor Create(OwnList: TLinkedList; Start: PLinkedListItem);
  end;

constructor TItr.Create(OwnList: TLinkedList; Start: PLinkedListItem);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2070 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FCursor := Start;
  FOwnList := OwnList;
  FSize := FOwnList.Size;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2070; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TItr.GetObject: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2071 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Obj;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2071; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TItr.HasNext: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2072 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor <> nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2072; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TItr.HasPrevious: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2073 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  raise ECallUnimplemented.Create('The container type is unidirectional!');
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2073; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TItr.Next: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2074 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCursor.Obj;
  FLastRet := FCursor;
  FCursor := FCursor.Next;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2074; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TItr.Previous: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2075 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  raise ECallUnimplemented.Create('The container type is unidirectional!');
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2075; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TIntfLinkedList } =================================================

constructor TIntfLinkedList.Create(const ACollection: IIntfCollection = nil);
var
  It: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2076 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FStart := nil;
  FEnd := nil;
  FSize := 0;
  if ACollection <> nil then
  begin
    It := ACollection.First;
    while It.HasNext do
      Add(It.Next);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2076; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TIntfLinkedList.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2077 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2077; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfLinkedList.Insert(Index: Integer; const AInterface: IInterface);
var
  I: Integer;
  Current: PIntfLinkedListItem;
  NewItem: PIntfLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2078 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index > FSize) then
    raise EOutOfBounds.CreateRes(@RsOutOfBounds);
  if AInterface = nil then
    Exit;
  if FStart = nil then
  begin
    AddFirst(AInterface);
    Exit;
  end;
  New(NewItem);
  NewItem.Obj := AInterface;
  if Index = 0 then
  begin
    NewItem.Next := FStart;
    FStart := NewItem;
    Inc(FSize);
  end
  else
  begin
    Current := FStart;
    I := 0;
    while (Current <> nil) and (I <> Index) do
      Current := Current.Next;
    NewItem.Next := Current.Next;
    Current.Next := NewItem;
    Inc(FSize);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2078; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfLinkedList.Add(const AInterface: IInterface): Boolean;
var
  NewItem: PIntfLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2079 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AInterface = nil then
    Exit;
  Result := True;
  if FStart = nil then
  begin
    AddFirst(AInterface);
    Exit;
  end;
  New(NewItem);
  NewItem.Obj := AInterface;
  NewItem.Next := nil;
  FEnd.Next := NewItem;
  FEnd := NewItem;
  Inc(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2079; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfLinkedList.AddAll(const ACollection: IIntfCollection);
var
  It: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2080 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2080; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfLinkedList.InsertAll(Index: Integer; const ACollection: IIntfCollection);
var
  I: Integer;
  It: IIntfIterator;
  Current: PIntfLinkedListItem;
  NewItem: PIntfLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2081 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index > FSize) then
    raise EOutOfBounds.CreateRes(@RsOutOfBounds);

  if ACollection = nil then
    Exit;
  It := ACollection.First;
  // (rom) is this a bug? Only one element added.
  if (FStart = nil) and It.HasNext then
  begin
    AddFirst(It.Next);
    Exit;
  end;
  Current := FStart;
  I := 0;
  while (Current <> nil) and (I <> Index) do
    Current := Current.Next;
  while It.HasNext do
  begin
    New(NewItem);
    NewItem.Obj := It.Next;
    if Index = 0 then
    begin
      NewItem.Next := FStart;
      FStart := NewItem;
      Inc(FSize);
    end
    else
    begin
      NewItem.Next := Current.Next;
      Current.Next := NewItem;
      Inc(FSize);
    end;
    Inc(Index);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2081; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfLinkedList.AddFirst(const AInterface: IInterface);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2082 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  New(FStart);
  FStart.Obj := AInterface;
  FStart.Next := nil;
  FEnd := FStart;
  Inc(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2082; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfLinkedList.Clear;
var
  I: Integer;
  Old, Current: PIntfLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2083 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    Current.Obj := nil;
    Old := Current;
    Current := Current.Next;
    Dispose(Old);
  end;
  FSize := 0;

  //Daniele Teti 27/12/2004
  FStart := nil;
  FEnd := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2083; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfLinkedList.Clone: TObject;
var
  NewList: TIntfLinkedList;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2084 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewList := TIntfLinkedList.Create;
  NewList.AddAll(Self);
  Result := NewList;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2084; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfLinkedList.Contains(const AInterface: IInterface): Boolean;
var
  I: Integer;
  Current: PIntfLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2085 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AInterface = nil then
    Exit;
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    if Current.Obj = AInterface then
    begin
      Result := True;
      Exit;
    end;
    Current := Current.Next;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2085; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfLinkedList.ContainsAll(const ACollection: IIntfCollection): Boolean;
var
  It: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2086 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := True;
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while Result and It.HasNext do
  Result := contains(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2086; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfLinkedList.Equals(const ACollection: IIntfCollection): Boolean;
var
  It, ItSelf: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2087 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then
    Exit;
  if FSize <> ACollection.Size then
    Exit;
  It := ACollection.First;
  ItSelf := First;
  while ItSelf.HasNext do
    if ItSelf.Next <> It.Next then
      Exit;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2087; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfLinkedList.GetIntf(Index: Integer): IInterface;
var
  I: Integer;
  Current: PIntfLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2088 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  if FStart = nil then
    Exit;
  Current := FStart;
  for I := 0 to Index - 1 do
    Current := Current.Next;
  Result := Current.Obj;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2088; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfLinkedList.IndexOf(const AInterface: IInterface): Integer;
var
  I: Integer;
  Current: PIntfLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2089 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if AInterface = nil then
    Exit;
  if FStart = nil then
    Exit;
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    if Current.Obj = AInterface then
    begin
      Result := I;
      Break;
    end;
    Current := Current.Next;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2089; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfLinkedList.First: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2090 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TIntfItr.Create(Self, FStart);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2090; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfLinkedList.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2091 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSize = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2091; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfLinkedList.Last: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2092 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TIntfItr.Create(Self, FStart);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2092; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfLinkedList.LastIndexOf(const AInterface: IInterface): Integer;
var
  I: Integer;
  Current: PIntfLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2093 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if AInterface = nil then
    Exit;
  if FStart = nil then
    Exit;
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    if Current.Obj = AInterface then
      Result := I;
    Current := Current.Next;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2093; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfLinkedList.Remove(const AInterface: IInterface): Boolean;
var
  I: Integer;
  Old, Current: PIntfLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2094 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AInterface = nil then
    Exit;
  if FStart = nil then
    Exit;
  Old := nil;
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    if Current.Obj = AInterface then
    begin
      Current.Obj := nil;
      if Old <> nil then
      begin
        Old.Next := Current.Next;
        if Old.Next = nil then
          FEnd := Old;
      end
      else
        FStart := Current.Next;
      Dispose(Current);
      Dec(FSize);
      Result := True;
      Exit;
    end;
    Old := Current;
    Current := Current.Next;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2094; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfLinkedList.Remove(Index: Integer): IInterface;
var
  I: Integer;
  Old, Current: PIntfLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2095 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  if FStart = nil then
    Exit;
  Old := nil;
  Current := FStart;
  for I := 0 to Index - 1 do
  begin
    Old := Current;
    Current := Current.Next;
  end;
  Current.Obj := nil;
  if Old <> nil then
  begin
    Old.Next := Current.Next;
    if Old.Next = nil then
      FEnd := Old;
  end
  else
    FStart := Current.Next;
  Dispose(Current);
  Dec(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2095; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfLinkedList.RemoveAll(const ACollection: IIntfCollection);
var
  It: IIntfIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2096 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Remove(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2096; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfLinkedList.RetainAll(const ACollection: IIntfCollection);
var
  It: IIntfIterator;
  I: IInterface;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2097 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := First;
  while It.HasNext do
  begin
    I := It.Next;
    if not ACollection.Contains(I) then
      Remove(I);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2097; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TIntfLinkedList.SetIntf(Index: Integer; const AInterface: IInterface);
var
  I: Integer;
  Current: PIntfLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2098 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FStart = nil then
    Exit;
  Current := FStart;
  for I := 0 to Index - 1 do
    Current := Current.Next;
  Current.Obj := AInterface;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2098; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TIntfLinkedList.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2099 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2099; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TStrLinkedList } ==================================================

constructor TStrLinkedList.Create(const ACollection: IStrCollection = nil);
var
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2100 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FStart := nil;
  FEnd := nil;
  FSize := 0;
  if ACollection <> nil then
  begin
    It := ACollection.First;
    while It.HasNext do
      Add(It.Next);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2100; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TStrLinkedList.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2101 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2101; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrLinkedList.Insert(Index: Integer; const AString: string);
var
  I: Integer;
  Current: PStrLinkedListItem;
  NewItem: PStrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2102 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index > FSize) then
    raise EOutOfBounds.CreateRes(@RsOutOfBounds);

  if AString = '' then
    Exit;
  if FStart = nil then
  begin
    AddFirst(AString);
    Exit;
  end;
  New(NewItem);
  NewItem.Str := AString;
  if Index = 0 then
  begin
    NewItem.Next := FStart;
    FStart := NewItem;
    Inc(FSize);
  end
  else
  begin
    Current := FStart;
    I := 0;
    while (Current <> nil) and (I <> Index) do
      Current := Current.Next;
    NewItem.Next := Current.Next;
    Current.Next := NewItem;
    Inc(FSize);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2102; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrLinkedList.Add(const AString: string): Boolean;
var
  NewItem: PStrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2103 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AString = '' then
    Exit;
  Result := True;
  if FStart = nil then
  begin
    AddFirst(AString);
    Exit;
  end;
  New(NewItem);
  NewItem.Str := AString;
  NewItem.Next := nil;
  FEnd.Next := NewItem;
  FEnd := NewItem;
  Inc(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2103; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrLinkedList.AddAll(const ACollection: IStrCollection);
var
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2104 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2104; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrLinkedList.InsertAll(Index: Integer; const ACollection: IStrCollection);
var
  I: Integer;
  It: IStrIterator;
  Current: PStrLinkedListItem;
  NewItem: PStrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2105 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;

  if (Index < 0) or (Index >= FSize) then
    raise EOutOfBounds.CreateRes(@RsOutOfBounds);

  It := ACollection.First;
  // (rom) is this a bug? Only one element added.
  if (FStart = nil) and It.HasNext then
  begin
    AddFirst(It.Next);
    //Exit;  //Daniele Teti
  end;
  Current := FStart;
  I := 0;
  while (Current <> nil) and (I <> Index) do
  begin
    Current := Current.Next;
    inc(I);
  end;
  while It.HasNext do
  begin
    New(NewItem);
    NewItem.Str := It.Next;
    if Index = 0 then
    begin
      NewItem.Next := FStart;
      FStart := NewItem;
      Inc(FSize);
    end
    else
    begin
      NewItem.Next := Current.Next;
      Current.Next := NewItem;
      Inc(FSize);
    end;
    Inc(Index);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2105; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrLinkedList.AddFirst(const AString: string);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2106 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  New(FStart);
  FStart.Str := AString;
  FStart.Next := nil;
  FEnd := FStart;
  Inc(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2106; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrLinkedList.Clear;
var
  I: Integer;
  Old, Current: PStrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2107 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    Current.Str := '';
    Old := Current;
    Current := Current.Next;
    Dispose(Old);
  end;
  FSize := 0;

  //Daniele Teti 27/12/2004
  FStart := nil;
  FEnd := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2107; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrLinkedList.Clone: TObject;
var
  NewList: TStrLinkedList;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2108 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewList := TStrLinkedList.Create;
  NewList.AddAll(Self);
  Result := NewList;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2108; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrLinkedList.Contains(const AString: string): Boolean;
var
  I: Integer;
  Current: PStrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2109 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AString = '' then
    Exit;
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    if Current.Str = AString then
    begin
      Result := True;
      Exit;
    end;
    Current := Current.Next;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2109; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrLinkedList.ContainsAll(const ACollection: IStrCollection): Boolean;
var
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2110 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := True;
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while Result and It.HasNext do
  Result := contains(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2110; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrLinkedList.Equals(const ACollection: IStrCollection): Boolean;
var
  It, ItSelf: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2111 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then
    Exit;
  if FSize <> ACollection.Size then
    Exit;
  It := ACollection.First;
  ItSelf := First;
  while ItSelf.HasNext do
    if ItSelf.Next <> It.Next then
      Exit;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2111; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrLinkedList.First: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2112 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TStrItr.Create(Self, FStart);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2112; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrLinkedList.GetCaseSensitivity: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2113 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FCaseSensitive;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2113; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrLinkedList.GetString(Index: Integer): string;
var
  I: Integer;
  Current: PStrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2114 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := '';
  if FStart = nil then
    Exit;
  Current := FStart;
  for I := 0 to Index - 1 do
    Current := Current.Next;
  Result := Current.Str;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2114; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrLinkedList.IndexOf(const AString: string): Integer;
var
  I: Integer;
  Current: PStrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2115 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if AString = '' then
    Exit;
  if FStart = nil then
    Exit;
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    if Current.Str = AString then
    begin
      Result := I;
      Break;
    end;
    Current := Current.Next;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2115; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrLinkedList.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2116 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSize = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2116; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrLinkedList.Last: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2117 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TStrItr.Create(Self, FStart);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2117; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrLinkedList.LastIndexOf(const AString: string): Integer;
var
  I: Integer;
  Current: PStrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2118 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if AString = '' then
    Exit;
  if FStart = nil then
    Exit;
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    if Current.Str = AString then
      Result := I;
    Current := Current.Next;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2118; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrLinkedList.Remove(Index: Integer): string;
var
  I: Integer;
  Old, Current: PStrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2119 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := '';
  if FStart = nil then
    Exit;
  Old := nil;
  Current := FStart;
  for I := 0 to Index - 1 do
  begin
    Old := Current;
    Current := Current.Next;
  end;
  Current.Str := '';
  if Old <> nil then
  begin
    Old.Next := Current.Next;
    if Old.Next = nil then
      FEnd := Old;
  end
  else
    FStart := Current.Next;
  Dispose(Current);
  Dec(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2119; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrLinkedList.Remove(const AString: string): Boolean;
var
  I: Integer;
  Old, Current: PStrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2120 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AString = '' then
    Exit;
  if FStart = nil then
    Exit;
  Old := nil;
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    if Current.Str = AString then
    begin
      Current.Str := '';
      if Old <> nil then
      begin
        Old.Next := Current.Next;
        if Old.Next = nil then
          FEnd := Old;
      end
      else
        FStart := Current.Next;
      Dispose(Current);
      Dec(FSize);
      Result := True;
      Exit;
    end;
    Old := Current;
    Current := Current.Next;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2120; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrLinkedList.RemoveAll(const ACollection: IStrCollection);
var
  It: IStrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2121 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Remove(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2121; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrLinkedList.RetainAll(const ACollection: IStrCollection);
var
  It: IStrIterator;
  S: string;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2122 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := First;
  while It.HasNext do
  begin
    S := It.Next;
    if not ACollection.Contains(S) then
      Remove(S);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2122; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrLinkedList.SetCaseSensitivity(Value: Boolean);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2123 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FCaseSensitive := Value;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2123; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TStrLinkedList.SetString(Index: Integer; const AString: string);
var
  I: Integer;
  Current: PStrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2124 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FStart = nil then
    Exit;
  Current := FStart;
  for I := 0 to Index - 1 do
    Current := Current.Next;
  Current.Str := AString;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2124; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TStrLinkedList.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2125 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2125; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TPtrLinkedList } =====================================================

constructor TPtrLinkedList.Create(const ACollection: IPtrCollection = nil);
var
  It: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2126 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FStart := nil;
  FEnd := nil;
  FSize := 0;
  if ACollection <> nil then
  begin
    It := ACollection.First;
    while It.HasNext do
      Add(It.Next);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2126; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TPtrLinkedList.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2127 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2127; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrLinkedList.Insert(Index: Integer; APtr: Pointer);
var
  I: Integer;
  Current: PPtrLinkedListItem;
  NewItem: PPtrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2128 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index > FSize) then
    raise EOutOfBounds.CreateRes(@RsOutOfBounds);
  if APtr = nil then
    Exit;
  if FStart = nil then
  begin
    AddFirst(APtr);
    Exit;
  end;
  New(NewItem);
  NewItem.Ptr := APtr;
  if Index = 0 then
  begin
    NewItem.Next := FStart;
    FStart := NewItem;
    Inc(FSize);
  end
  else
  begin
    Current := FStart;
    for I := 0 to Index - 2 do
      Current := Current.Next;
    NewItem.Next := Current.Next;
    Current.Next := NewItem;
    Inc(FSize);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2128; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrLinkedList.Add(APtr: Pointer): Boolean;
var
  NewItem: PPtrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2129 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if APtr = nil then
    Exit;
  Result := True;
  if FStart = nil then
  begin
    AddFirst(APtr);
    Exit;
  end;
  New(NewItem);
  NewItem.Ptr := APtr;
  NewItem.Next := nil;
  FEnd.Next := NewItem;
  FEnd := NewItem;
  Inc(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2129; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrLinkedList.AddAll(const ACollection: IPtrCollection);
var
  It: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2130 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2130; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrLinkedList.InsertAll(Index: Integer; const ACollection: IPtrCollection);
var
  I: Integer;
  It: IPtrIterator;
  Current: PPtrLinkedListItem;
  NewItem: PPtrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2131 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index > FSize) then
    raise EOutOfBounds.CreateRes(@RsOutOfBounds);
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  // (rom) is this a bug? Only one element added.
  if (FStart = nil) and It.HasNext then
  begin
    AddFirst(It.Next);
    Exit;
  end;
  Current := FStart;
  I := 0;
  while (Current <> nil) and (I <> Index) do
    Current := Current.Next;
  while It.HasNext do
  begin
    New(NewItem);
    NewItem.Ptr := It.Next;
    if Index = 0 then
    begin
      NewItem.Next := FStart;
      FStart := NewItem;
      Inc(FSize);
    end
    else
    begin
      NewItem.Next := Current.Next;
      Current.Next := NewItem;
      Inc(FSize);
    end;
    Inc(Index);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2131; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrLinkedList.AddFirst(APtr: Pointer);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2132 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  New(FStart);
  FStart.Ptr := APtr;
  FStart.Next := nil;
  FEnd := FStart;
  Inc(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2132; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrLinkedList.Clear;
var
  I: Integer;
  Old, Current: PPtrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2133 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    Old := Current;
    Current := Current.Next;
    Dispose(Old);
  end;
  FSize := 0;

  //Daniele Teti 27/12/2004
  FStart := nil;
  FEnd := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2133; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrLinkedList.Clone: TObject;
var
  NewList: TPtrLinkedList;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2134 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewList := TPtrLinkedList.Create;
  NewList.AddAll(Self);
  Result := NewList;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2134; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrLinkedList.Contains(APtr: Pointer): Boolean;
var
  I: Integer;
  Current: PPtrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2135 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if APtr = nil then
    Exit;
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    if Current.Ptr = APtr then
    begin
      Result := True;
      Break;
    end;
    Current := Current.Next;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2135; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrLinkedList.ContainsAll(const ACollection: IPtrCollection): Boolean;
var
  It: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2136 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := True;
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while Result and It.HasNext do
  Result := contains(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2136; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrLinkedList.Equals(const ACollection: IPtrCollection): Boolean;
var
  It, ItSelf: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2137 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then
    Exit;
  if FSize <> ACollection.Size then
    Exit;
  It := ACollection.First;
  ItSelf := First;
  while ItSelf.HasNext do
    if ItSelf.Next <> It.Next then
      Exit;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2137; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrLinkedList.GetPtr(Index: Integer): Pointer;
var
  I: Integer;
  Current: PPtrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2138 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  if FStart = nil then
    Exit;
  Current := FStart;
  for I := 0 to Index - 1 do
    Current := Current.Next;
  Result := Current.Ptr;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2138; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrLinkedList.IndexOf(APtr: Pointer): Integer;
var
  I: Integer;
  Current: PPtrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2139 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if APtr = nil then
    Exit;
  if FStart = nil then
    Exit;
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    if Current.Ptr = APtr then
    begin
      Result := I;
      Break;
    end;
    Current := Current.Next;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2139; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrLinkedList.First: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2140 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TPtrItr.Create(Self, FStart);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2140; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrLinkedList.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2141 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSize = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2141; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrLinkedList.Last: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2142 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TPtrItr.Create(Self, FStart);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2142; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrLinkedList.LastIndexOf(APtr: Pointer): Integer;
var
  I: Integer;
  Current: PPtrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2143 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if APtr = nil then
    Exit;
  if FStart = nil then
    Exit;
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    if Current.Ptr = APtr then
      Result := I;
    Current := Current.Next;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2143; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrLinkedList.Remove(APtr: Pointer): Boolean;
var
  I: Integer;
  Old, Current: PPtrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2144 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if APtr = nil then
    Exit;
  if FStart = nil then
    Exit;
  Old := nil;
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    if Current.Ptr = APtr then
    begin
      if Old <> nil then
      begin
        Old.Next := Current.Next;
        if Old.Next = nil then
          FEnd := Old;
      end
      else
        FStart := Current.Next;
        Dispose(Current);
      Dec(FSize);
      Result := True;
      Exit;
    end;
    Old := Current;
    Current := Current.Next;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2144; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrLinkedList.Remove(Index: Integer): Pointer;
var
  I: Integer;
  Old, Current: PPtrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2145 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  if FStart = nil then
    Exit;
  Old := nil;
  Current := FStart;
  for I := 0 to Index - 1 do
  begin
    Old := Current;
    Current := Current.Next;
  end;
  if Old <> nil then
  begin
    Old.Next := Current.Next;
    if Old.Next = nil then
      FEnd := Old;
  end
  else
    FStart := Current.Next;
  Dispose(Current);
  Dec(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2145; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrLinkedList.RemoveAll(const ACollection: IPtrCollection);
var
  It: IPtrIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2146 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Remove(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2146; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrLinkedList.RetainAll(const ACollection: IPtrCollection);
var
  It: IPtrIterator;
  P: Pointer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2147 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := First;
  while It.HasNext do
  begin
    P := It.Next;
    if not ACollection.Contains(P) then
      Remove(P);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2147; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TPtrLinkedList.SetPtr(Index: Integer; APtr: Pointer);
var
  I: Integer;
  Current: PPtrLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2148 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FStart = nil then
    Exit;
  Current := FStart;
  for I := 0 to Index - 1 do
    Current := Current.Next;
  Current.Ptr := APtr;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2148; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TPtrLinkedList.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2149 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2149; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

//=== { TLinkedList } =====================================================

constructor TLinkedList.Create(const ACollection: ICollection = nil; AOwnsObjects: Boolean = True);
var
  It: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2150 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  inherited Create;
  FStart := nil;
  FEnd := nil;
  FSize := 0;
  FOwnsObjects := AOwnsObjects;
  if ACollection <> nil then
  begin
    It := ACollection.First;
    while It.HasNext do
      Add(It.Next);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2150; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

destructor TLinkedList.Destroy;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2151 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Clear;
  inherited Destroy;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2151; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TLinkedList.Insert(Index: Integer; AObject: TObject);
var
  I: Integer;
  Current: PLinkedListItem;
  NewItem: PLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2152 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index > FSize) then
    raise EOutOfBounds.CreateRes(@RsOutOfBounds);
  if AObject = nil then
    Exit;
  if FStart = nil then
  begin
    AddFirst(AObject);
    Exit;
  end;
  New(NewItem);
  NewItem.Obj := AObject;
  if Index = 0 then
  begin
    NewItem.Next := FStart;
    FStart := NewItem;
    Inc(FSize);
  end
  else
  begin
    Current := FStart;
    for I := 0 to Index - 2 do
      Current := Current.Next;
    NewItem.Next := Current.Next;
    Current.Next := NewItem;
    Inc(FSize);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2152; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TLinkedList.Add(AObject: TObject): Boolean;
var
  NewItem: PLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2153 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AObject = nil then
    Exit;
  Result := True;
  if FStart = nil then
  begin
    AddFirst(AObject);
    Exit;
  end;
  New(NewItem);
  NewItem.Obj := AObject;
  NewItem.Next := nil;
  FEnd.Next := NewItem;
  FEnd := NewItem;
  Inc(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2153; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TLinkedList.AddAll(const ACollection: ICollection);
var
  It: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2154 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Add(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2154; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TLinkedList.InsertAll(Index: Integer; const ACollection: ICollection);
var
  I: Integer;
  It: IIterator;
  Current: PLinkedListItem;
  NewItem: PLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2155 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if (Index < 0) or (Index > FSize) then
    raise EOutOfBounds.CreateRes(@RsOutOfBounds);
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  // (rom) is this a bug? Only one element added.
  if (FStart = nil) and It.HasNext then
  begin
    AddFirst(It.Next);
    Exit;
  end;
  Current := FStart;
  I := 0;
  while (Current <> nil) and (I <> Index) do
    Current := Current.Next;
  while It.HasNext do
  begin
    New(NewItem);
    NewItem.Obj := It.Next;
    if Index = 0 then
    begin
      NewItem.Next := FStart;
      FStart := NewItem;
      Inc(FSize);
    end
    else
    begin
      NewItem.Next := Current.Next;
      Current.Next := NewItem;
      Inc(FSize);
    end;
    Inc(Index);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2155; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TLinkedList.AddFirst(AObject: TObject);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2156 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  New(FStart);
  FStart.Obj := AObject;
  FStart.Next := nil;
  FEnd := FStart;
  Inc(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2156; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TLinkedList.Clear;
var
  I: Integer;
  Old, Current: PLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2157 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    FreeObject(Current.Obj);        // (outchy) Fixed Memory Leak
    //Current.Obj := nil;
    Old := Current;
    Current := Current.Next;
    Dispose(Old);
  end;
  FSize := 0;

  //Daniele Teti 27/12/2004
  FStart := nil;
  FEnd := nil;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2157; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TLinkedList.Clone: TObject;
var
  NewList: TLinkedList;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2158 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  NewList := TLinkedList.Create;
  NewList.AddAll(Self);
  Result := NewList;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2158; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TLinkedList.Contains(AObject: TObject): Boolean;
var
  I: Integer;
  Current: PLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2159 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AObject = nil then
    Exit;
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    if Current.Obj = AObject then
    begin
      Result := True;
      Break;
    end;
    Current := Current.Next;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2159; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TLinkedList.ContainsAll(const ACollection: ICollection): Boolean;
var
  It: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2160 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := True;
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while Result and It.HasNext do
  Result := contains(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2160; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TLinkedList.Equals(const ACollection: ICollection): Boolean;
var
  It, ItSelf: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2161 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if ACollection = nil then
    Exit;
  if FSize <> ACollection.Size then
    Exit;
  It := ACollection.First;
  ItSelf := First;
  while ItSelf.HasNext do
    if ItSelf.Next <> It.Next then
      Exit;
  Result := True;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2161; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TLinkedList.FreeObject(var AObject: TObject);
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2162 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FOwnsObjects then
    FreeAndNil(AObject);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2162; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TLinkedList.GetObject(Index: Integer): TObject;
var
  I: Integer;
  Current: PLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2163 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  if FStart = nil then
    Exit;
  Current := FStart;
  for I := 0 to Index - 1 do
    Current := Current.Next;
  Result := Current.Obj;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2163; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TLinkedList.IndexOf(AObject: TObject): Integer;
var
  I: Integer;
  Current: PLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2164 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if AObject = nil then
    Exit;
  if FStart = nil then
    Exit;
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    if Current.Obj = AObject then
    begin
      Result := I;
      Break;
    end;
    Current := Current.Next;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2164; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TLinkedList.First: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2165 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TItr.Create(Self, FStart);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2165; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TLinkedList.IsEmpty: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2166 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSize = 0;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2166; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TLinkedList.Last: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2167 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := TItr.Create(Self, FStart);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2167; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TLinkedList.LastIndexOf(AObject: TObject): Integer;
var
  I: Integer;
  Current: PLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2168 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := -1;
  if AObject = nil then
    Exit;
  if FStart = nil then
    Exit;
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    if Current.Obj = AObject then
      Result := I;
    Current := Current.Next;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2168; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TLinkedList.Remove(AObject: TObject): Boolean;
var
  I: Integer;
  Old, Current: PLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2169 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := False;
  if AObject = nil then
    Exit;
  if FStart = nil then
    Exit;
  Old := nil;
  Current := FStart;
  for I := 0 to FSize - 1 do
  begin
    if Current.Obj = AObject then
    begin
      FreeObject(Current.Obj);
      if Old <> nil then
      begin
        Old.Next := Current.Next;
        if Old.Next = nil then
          FEnd := Old;
      end
      else
        FStart := Current.Next;
        Dispose(Current);
      Dec(FSize);
      Result := True;
      Exit;
    end;
    Old := Current;
    Current := Current.Next;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2169; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TLinkedList.Remove(Index: Integer): TObject;
var
  I: Integer;
  Old, Current: PLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2170 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := nil;
  if FStart = nil then
    Exit;
  Old := nil;
  Current := FStart;
  for I := 0 to Index - 1 do
  begin
    Old := Current;
    Current := Current.Next;
  end;
  FreeObject(Current.Obj);
  if Old <> nil then
  begin
    Old.Next := Current.Next;
    if Old.Next = nil then
      FEnd := Old;
  end
  else
    FStart := Current.Next;
  Dispose(Current);
  Dec(FSize);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2170; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TLinkedList.RemoveAll(const ACollection: ICollection);
var
  It: IIterator;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2171 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := ACollection.First;
  while It.HasNext do
    Remove(It.Next);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2171; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TLinkedList.RetainAll(const ACollection: ICollection);
var
  It: IIterator;
  O: TObject;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2172 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if ACollection = nil then
    Exit;
  It := First;
  while It.HasNext do
  begin
    O := It.Next;
    if not ACollection.Contains(O) then
      Remove(O);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2172; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure TLinkedList.SetObject(Index: Integer; AObject: TObject);
var
  I: Integer;
  Current: PLinkedListItem;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2173 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  if FStart = nil then
    Exit;
  Current := FStart;
  for I := 0 to Index - 1 do
    Current := Current.Next;
  Current.Obj := AObject;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2173; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function TLinkedList.Size: Integer;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,2174 or $7D9E0000; mov eax,self; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  Result := FSize;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,2174; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

end.
