{*------------------------------------------------------------------------------
  Abstract Object to access database contents.

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
unit Components.DataCore.Storage;

interface

uses
  Misc.Miscleanous,
  Misc.Containers,
  Misc.Algorithm,
  Framework.Base,
  Framework.TypeRegistry,
  Components.DataCore.Fields,
  Components.DataCore.Types,
  Framework.SerializationRegistry;

type
  {
    Storage medium is a semi-abstract class used as a parent to
    all medium types.
  }
  YDbStorageMedium = class;

  YStorageErrorEvent = procedure(cSender: YDbStorageMedium; const sError: string) of object;

  { The main interface for accessing data }
  IStorage = interface(IInterface)
  ['{77DF05B5-001A-4651-83E3-EF84D5B444D2}']
    procedure LoadEntry(const sField: string; iEqualsTo: Int32; out cSerializable); overload;
    procedure LoadEntry(const sField: string; const sEqualsTo: string; out cSerializable); overload;
    procedure LoadEntry(const sField: string; const fEqualsTo: Float; out cSerializable); overload;
    procedure LoadEntry(iIndex: Int32; out cSerializable); overload;

    procedure SaveField(const sField: string; const fValue: Float); overload;
    procedure SaveField(const sField: string; iValue: Int32); overload;
    procedure SaveField(const sField: string; const sValue: string); overload;

    procedure DeleteEntry(iId: UInt32);
    procedure SaveEntry(cEntry: YDbSerializable);
    procedure CreateEntry(out cSerializable; iId: UInt32 = 0);
    procedure ReleaseEntry(cEntry: YDbSerializable);
    procedure ReleaseEntryList(const aEntries: YDbSerializables);

    function CountEntries(const sField: string; iValue: Int32): Int32; overload;
    function CountEntries(const sField: string; const sValue: string): Int32; overload;
    function CountEntries(const sField: string; const fValue: Float): Int32; overload;

    procedure LoadEntryList(const sField: string; iEqualsTo: Int32;
      out aArr: YDbSerializables); overload;
    procedure LoadEntryList(const sField: string; const sEqualsTo: string;
      out aArr: YDbSerializables); overload;
    procedure LoadEntryList(const sField: string; const fEqualsTo: Float;
      out aArr: YDbSerializables); overload;

    function LoadMaxId: UInt32;
    function GetNumberOfElements: Int32;
  end;

  YDbStorageMedium = class(TBaseInterfacedObject, IStorage)
    private
      fOnError: YStorageErrorEvent;
    protected
      fClassType: YDbSerializableClass;
      fClassName: string;
      fClassData: PSerializationData;
      fClassInfo: IClassTypeInfo;
      fClassDataLen: Int32;
      fClassInstSize: Int32;
      fSaveBack: Boolean;
      fName: string; { Descriptive name }
      {
        Medium Specific functions. Those must be implementeded in
        derivates of this class.
      }
      procedure InitializeMedium(const sOptions: string); virtual; abstract;
      procedure InitialLoadMedium; virtual; abstract;
      procedure SaveMedium; virtual; abstract;
      procedure ThreadSafeSaveMedium; virtual; abstract;
      procedure FinalSaveMedium; virtual; abstract;

      function LoadEntryById(iId: UInt32): YDbSerializable; virtual; abstract;
      function LoadEntryMediumInteger(iOffset: Int32; iEqualsTo: Int32): YDbSerializable; virtual; abstract;
      function LoadEntryMediumString(iOffset: Int32; const sEqualsTo: string): YDbSerializable; virtual; abstract;
      function LoadEntryMediumFloat(iOffset: Int32; const fEqualsTo: Float): YDbSerializable; virtual; abstract;

      procedure SaveMassFieldMediumInteger(iOffset: Int32; iValue: Int32); virtual; abstract;
      procedure SaveMassFieldMediumString(iOffset: Int32; const sValue: string); virtual; abstract;
      procedure SaveMassFieldMediumFloat(iOffset: Int32; const fValue: Float); virtual; abstract;

      procedure DeleteEntryMedium(iId: UInt32); virtual; abstract;
      procedure SaveEntryMedium(cEntry: YDbSerializable); virtual; abstract;
      procedure CreateEntryMedium(out cEntry: YDbSerializable; iId: UInt32); virtual; abstract;
      procedure ReleaseEntryMedium(cEntry: YDbSerializable); virtual; abstract;

      function CountEntriesMediumInteger(iOffset: Int32; iValue: Int32): Int32; virtual; abstract;
      function CountEntriesMediumString(iOffset: Int32; const sValue: string): Int32; virtual; abstract;
      function CountEntriesMediumFloat(iOffset: Int32; const fValue: Float): Int32; virtual; abstract;

      procedure LoadEntryListMediumInteger(iOffset: Int32; iEqualsTo: Int32;
        out aArr: YDbSerializables); virtual; abstract;
      procedure LoadEntryListMediumString(iOffset: Int32; const sEqualsTo: string;
        out aArr: YDbSerializables); virtual; abstract;
      procedure LoadEntryListMediumFloat(iOffset: Int32; const fEqualsTo: Float;
        out aArr: YDbSerializables); virtual; abstract;

      function LoadMaxIdMedium: UInt32; virtual; abstract;

      procedure DoOnError(const Error: string); inline;

      procedure InitializeDefaultValues(Instance: TObject);
    public
      procedure Initialize(const Options: string; SaveBack: Boolean;
        ClassType: YDbSerializableClass; const sName: string);
      procedure InitialLoad;
      procedure ThreadSafeSave;
      procedure FinalSave;

      {
       Data manipulation. The following functions will
       call medium specific functions.
      }
      procedure LoadEntry(const sField: string; iEqualsTo: Int32; out cSerializable); overload;
      procedure LoadEntry(const sField: string; const sEqualsTo: string; out cSerializable); overload;
      procedure LoadEntry(const sField: string; const fEqualsTo: Float; out cSerializable); overload;
      procedure LoadEntry(iIndex: Int32; out cSerializable); overload;

      procedure SaveField(const sField: string; const fValue: Float); overload;
      procedure SaveField(const sField: string; iValue: Int32); overload;
      procedure SaveField(const sField: string; const sValue: string); overload;

      procedure DeleteEntry(iId: UInt32);
      procedure SaveEntry(cEntry: YDbSerializable);
      procedure CreateEntry(out cSerializable; iId: UInt32 = 0);
      procedure ReleaseEntry(cEntry: YDbSerializable);
      procedure ReleaseEntryList(const aEntries: YDbSerializables);

      function CountEntries(const sField: string; iValue: Int32): Int32; overload;
      function CountEntries(const sField: string; const sValue: string): Int32; overload;
      function CountEntries(const sField: string; const fValue: Float): Int32; overload;

      procedure LoadEntryList(const sField: string; iEqualsTo: Int32;
        out aArr: YDbSerializables); overload;
      procedure LoadEntryList(const sField: string; const sEqualsTo: string;
        out aArr: YDbSerializables); overload;
      procedure LoadEntryList(const sField: string; const fEqualsTo: Float;
        out aArr: YDbSerializables); overload;

      function LoadMaxId: UInt32;
      function GetNumberOfElements: Int32; virtual; abstract;

      property Items: Int32 read GetNumberOfElements;
      property Name: string read fName;
      
      property OnError: YStorageErrorEvent read fOnError write fOnError;
    end;

implementation

uses
  TypInfo,
  SysUtils,
  Framework;

{ YStorageMedium }

procedure YDbStorageMedium.DoOnError(const Error: string);
begin
  if Assigned(fOnError) then fOnError(Self, Error);
end;

procedure YDbStorageMedium.DeleteEntry(iId: UInt32);
begin
  DeleteEntryMedium(iId);
end;

procedure YDbStorageMedium.FinalSave;
begin
  FinalSaveMedium;
end;

procedure YDbStorageMedium.Initialize(const Options: string; SaveBack: Boolean;
  ClassType: YDbSerializableClass; const sName: string);
begin
  if ClassType = nil then Exit;
  fSaveBack := SaveBack;
  fClassType := ClassType;
  fClassName := ClassType.ClassName;
  fClassInstSize := ClassType.InstanceSize;
  ClassType.RegisterSelf(SystemSerializationRegistry);

  fClassInfo := SystemTypeRegistry.RegisterType(ClassType.ClassInfo) as IClassTypeInfo;
  fClassData := SystemSerializationRegistry.GetTypeDataByName(fClassName);
  fClassDataLen := Length(fClassData^.Data);
  fName := sName;
  InitializeMedium(Options);
end;

procedure YDbStorageMedium.InitializeDefaultValues(Instance: TObject);
var
  I: Int32;
  Prop: IPropertyInfo;
  PropInfo: PPropInfo;
  PropType: TTypeKind;
begin
  for I := 0 to fClassInfo.PropertyCount -1 do
  begin
    Prop := fClassInfo.Properties[I];
    PropInfo := Prop.PropInfo;
    PropType := Prop.PropertyType.RttiType;

    if (PropType in [tkInteger, tkEnumeration, tkSet, tkChar, tkWChar]) and
       (PropInfo^.Default <> Integer($80000000)) then
    begin
      SetOrdProp(Instance, PropInfo, PropInfo^.Default);
    end;
  end;
end;

procedure YDbStorageMedium.InitialLoad;
begin
  InitialLoadMedium;
end;

procedure YDbStorageMedium.LoadEntry(iIndex: Int32; out cSerializable);
begin
  Pointer(cSerializable) := LoadEntryById(iIndex)
end;

procedure YDbStorageMedium.LoadEntry(const sField: string; iEqualsTo: Int32; out cSerializable);
var
  pFieldData: PSerializableFieldData;
begin
  pFieldData := fClassData^.Map.GetValue(sField);
  if pFieldData <> nil then
  begin
    Pointer(cSerializable) := LoadEntryMediumInteger(Int32(pFieldData^.Offset), iEqualsTo);
  end else
  begin
    Pointer(cSerializable) := nil;
  end;
end;

procedure YDbStorageMedium.LoadEntry(const sField, sEqualsTo: string; out cSerializable);
var
  pFieldData: PSerializableFieldData;
begin
  pFieldData := fClassData^.Map.GetValue(sField);
  if pFieldData <> nil then
  begin
    Pointer(cSerializable) := LoadEntryMediumString(Int32(pFieldData^.Offset), sEqualsTo);
  end else
  begin
    Pointer(cSerializable) := nil;
  end;
end;

procedure YDbStorageMedium.LoadEntry(const sField: string; const fEqualsTo: Float; out cSerializable);
var
  pFieldData: PSerializableFieldData;
begin
  pFieldData := fClassData^.Map.GetValue(sField);
  if pFieldData <> nil then
  begin
    Pointer(cSerializable) := LoadEntryMediumFloat(Int32(pFieldData^.Offset), fEqualsTo);
  end else
  begin
    Pointer(cSerializable) := nil;
  end;
end;

procedure YDbStorageMedium.SaveField(const sField: string; const fValue: Float);
var
  pFieldData: PSerializableFieldData;
begin
  pFieldData := fClassData^.Map.GetValue(sField);
  if pFieldData <> nil then
  begin
    SaveMassFieldMediumFloat(Int32(pFieldData^.Offset), fValue);
  end;
end;

procedure YDbStorageMedium.SaveField(const sField: string; iValue: Int32);
var
  pFieldData: PSerializableFieldData;
begin
  pFieldData := fClassData^.Map.GetValue(sField);
  if pFieldData <> nil then
  begin
    SaveMassFieldMediumInteger(Int32(pFieldData^.Offset), iValue);
  end;
end;

procedure YDbStorageMedium.SaveField(const sField: string; const sValue: string);
var
  pFieldData: PSerializableFieldData;
begin
  pFieldData := fClassData^.Map.GetValue(sField);
  if pFieldData <> nil then
  begin
    SaveMassFieldMediumString(Int32(pFieldData^.Offset), sValue);
  end;
end;

procedure YDbStorageMedium.SaveEntry(cEntry: YDbSerializable);
begin
  SaveEntryMedium(cEntry);
end;

procedure YDbStorageMedium.ThreadSafeSave;
begin
  ThreadSafeSaveMedium;
end;

function YDbStorageMedium.CountEntries(const sField: string; iValue: Int32): Int32;
var
  pFieldData: PSerializableFieldData;
begin
  pFieldData := fClassData^.Map.GetValue(sField);
  if pFieldData <> nil then
  begin
    Result := CountEntriesMediumInteger(Int32(pFieldData^.Offset), iValue);
  end else
  begin
    Result := 0;
  end;
end;

function YDbStorageMedium.CountEntries(const sField, sValue: string): Int32;
var
  pFieldData: PSerializableFieldData;
begin
  pFieldData := fClassData^.Map.GetValue(sField);
  if pFieldData <> nil then
  begin
    Result := CountEntriesMediumString(Int32(pFieldData^.Offset), sValue);
  end else
  begin
    Result := 0;
  end;
end;

function YDbStorageMedium.CountEntries(const sField: string; const fValue: Float): Int32;
var
  pFieldData: PSerializableFieldData;
begin
  pFieldData := fClassData^.Map.GetValue(sField);
  if pFieldData <> nil then
  begin
    Result := CountEntriesMediumFloat(Int32(pFieldData^.Offset), fValue);
  end else
  begin
    Result := 0;
  end;
end;

procedure YDbStorageMedium.CreateEntry(out cSerializable; iId: UInt32);
begin
  CreateEntryMedium(YDbSerializable(cSerializable), iId);
end;

procedure YDbStorageMedium.ReleaseEntry(cEntry: YDbSerializable);
begin
  ReleaseEntryMedium(cEntry);
end;

procedure YDbStorageMedium.ReleaseEntryList(const aEntries: YDbSerializables);
var
  iIdx: Int32;
begin
  for iIdx := 0 to High(aEntries) do
  begin
    ReleaseEntryMedium(aEntries[iIdx]);
  end;
end;

procedure YDbStorageMedium.LoadEntryList(const sField: string; iEqualsTo: Int32;
  out aArr: YDbSerializables);
var
  pFieldData: PSerializableFieldData;
begin
  pFieldData := fClassData^.Map.GetValue(sField);
  if pFieldData <> nil then
  begin
    LoadEntryListMediumInteger(pFieldData^.Offset, iEqualsTo, aArr);
  end else
  begin
    aArr := nil;
  end;
end;

procedure YDbStorageMedium.LoadEntryList(const sField, sEqualsTo: string;
  out aArr: YDbSerializables);
var
  pFieldData: PSerializableFieldData;
begin
  pFieldData := fClassData^.Map.GetValue(sField);
  if pFieldData <> nil then
  begin
    LoadEntryListMediumString(pFieldData^.Offset, sEqualsTo, aArr);
  end else
  begin
    aArr := nil;
  end;
end;

procedure YDbStorageMedium.LoadEntryList(const sField: string; const fEqualsTo: Float;
  out aArr: YDbSerializables);
var
  pFieldData: PSerializableFieldData;
begin
  pFieldData := fClassData^.Map.GetValue(sField);
  if pFieldData <> nil then
  begin
    LoadEntryListMediumFloat(pFieldData^.Offset, fEqualsTo, aArr);
  end else
  begin
    aArr := nil;
  end;
end;

function YDbStorageMedium.LoadMaxId: UInt32;
begin
  Result := LoadMaxIdMedium;
end;

end.
