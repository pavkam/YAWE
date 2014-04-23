{
  This file is a part of YAWE Project. (c) 2006 YAWE Project.
  Unauthorized distribution of this file is strictly prohibited.

  Collection of various algorithms, mostly sorting.


  Initial Developers: Seth
}

unit DataInjector;

interface

type
  TDataProperty = (dpReadable, dpWritable, dpInitialized, dpDiscardable, dpShareable,
    dpExecutable);
  TDataProperties = set of TDataProperty;

const
  dpDefault = [dpReadable, dpInitialized];

function InjectDataIntoExecutable(const ExecutableFileName: string; Data: Pointer; DataSize: Integer;
  const ResourceName: string; const Properties: TDataProperties = dpDefault): Integer;

implementation

uses
  API.Win.Types,
  API.Win.NtCommon,
  API.Win.Kernel,
  Classes,
  SysUtils;

function DivMod(Dividend, Divisor: Integer; out Remainder: Integer): Integer;
asm
  PUSH  EBX
  MOV   EBX, EDX
  CDQ
  IDIV  EBX
  MOV   [ECX], EDX
  POP   EBX
end;

procedure RoundUpToAlignment(var Value: Longword; Alignment: Longword);
var
  Res, Rem: Longword;
begin
  Res := DivMod(Value, Alignment, Integer(Rem));
  if Rem <> 0 then Value := (Res + 1) * Alignment;
end;

function PeMapImgNtHeaders(const BaseAddress: Pointer): PImageNtHeaders32;
begin
  Result := nil;
  if IsBadReadPtr(BaseAddress, SizeOf(TImageDosHeader)) then Exit;
  if (PImageDosHeader(BaseAddress)^.e_magic <> IMAGE_DOS_SIGNATURE) or
    (PImageDosHeader(BaseAddress)^.e_lfanew = 0) then Exit;
  Result := PImageNtHeaders32(DWORD(BaseAddress) + DWORD(PImageDosHeader(BaseAddress)^.e_lfanew));
  if IsBadReadPtr(Result, SizeOf(TImageNtHeaders32)) or
    (Result^.Signature <> IMAGE_NT_SIGNATURE) then
  begin
    Result := nil;
  end;
end;

function PeMapImgSections(NtHeaders: PImageNtHeaders32): PImageSectionHeader;
begin
  if NtHeaders = nil then
  begin
    Result := nil;
  end else
  begin
    Result := PImageSectionHeader(DWORD(@NtHeaders^.OptionalHeader) +
      NtHeaders^.FileHeader.SizeOfOptionalHeader);
  end;
end;

function PeMapImgFindSection(NtHeaders: PImageNtHeaders32; const SectionName: string): PImageSectionHeader;
var
  Header: PImageSectionHeader;
  I: Integer;
  P: PChar;
begin
  Result := nil;
  if NtHeaders <> nil then
  begin
    P := PChar(SectionName);
    Header := PeMapImgSections(NtHeaders);
    with NtHeaders^ do
    begin
      for I := 1 to FileHeader.NumberOfSections do
      begin
        if StrLComp(PChar(@Header^.Name), P, IMAGE_SIZEOF_SHORT_NAME) = 0 then
        begin
          Result := Header;
          Break;
        end else Inc(Header);
      end;
    end;
  end;
end;

function InjectDataIntoExecutable(const ExecutableFileName: string; Data: Pointer; DataSize: Integer;
  const ResourceName: string; const Properties: TDataProperties): Integer;
const
  CharacteristicsTable: array[TDataProperty] of Longword = (
    IMAGE_SCN_MEM_READ,
    IMAGE_SCN_MEM_WRITE,
    IMAGE_SCN_CNT_INITIALIZED_DATA,
    IMAGE_SCN_MEM_DISCARDABLE,
    IMAGE_SCN_MEM_SHARED,
    IMAGE_SCN_MEM_EXECUTE
  );
var
  ImageStream: TMemoryStream;
  NtHeaders: PImageNtHeaders32;
  Sections, LastSection, NewSection, OldSection: PImageSectionHeader;
  VirtualAlignedSize: Longword;
  DataProp: TDataProperty;
  Characteristics: Longword;
  NeedFill: Integer;
  Size: Integer;
begin
  Result := 0;
  ImageStream := TMemoryStream.Create;
  try
    ImageStream.LoadFromFile(ExecutableFileName);

    NtHeaders := PeMapImgNtHeaders(ImageStream.Memory);
    if NtHeaders = nil then
    begin
      Result := -1;
      Exit;
    end;

    if PeMapImgFindSection(NtHeaders, ResourceName) <> nil then
    begin
      Result := -2;
      Exit;
    end;

    Sections := PeMapImgSections(NtHeaders);

    LastSection := Sections;
    Inc(LastSection, NtHeaders^.FileHeader.NumberOfSections - 1);
    NewSection := LastSection;
    Inc(NewSection);
    Inc(NtHeaders^.FileHeader.NumberOfSections);
    FillChar(NewSection^, SizeOf(TImageSectionHeader), 0);
    NewSection^.VirtualAddress := LastSection^.VirtualAddress + LastSection^.Misc.VirtualSize;
    RoundUpToAlignment(NewSection^.VirtualAddress, NtHeaders^.OptionalHeader.SectionAlignment);
    NewSection^.PointerToRawData := LastSection^.PointerToRawData + LastSection^.SizeOfRawData;
    RoundUpToAlignment(NewSection^.PointerToRawData, NtHeaders^.OptionalHeader.FileAlignment);
    StrPLCopy(PChar(@NewSection^.Name), ResourceName, IMAGE_SIZEOF_SHORT_NAME);
    Characteristics := 0;

    for DataProp in Properties do
    begin
      Characteristics := Characteristics or CharacteristicsTable[DataProp];
    end;

    NewSection^.Characteristics := Characteristics;
    VirtualAlignedSize := DataSize;
    RoundUpToAlignment(VirtualAlignedSize, NtHeaders^.OptionalHeader.SectionAlignment);
    NewSection^.Misc.VirtualSize := VirtualAlignedSize;
    Inc(NtHeaders^.OptionalHeader.SizeOfImage, VirtualAlignedSize);
    NewSection^.SizeOfRawData := DataSize;
    RoundUpToAlignment(NewSection^.SizeOfRawData, NtHeaders^.OptionalHeader.FileAlignment);
    Inc(NtHeaders^.OptionalHeader.SizeOfInitializedData, NewSection^.SizeOfRawData);
    NeedFill := Integer(NewSection^.SizeOfRawData) - DataSize;
    ImageStream.Seek(NewSection^.PointerToRawData, soBeginning);
    ImageStream.Write(Data^, DataSize);
    ImageStream.Size := ImageStream.Size + NeedFill;

    ImageStream.SaveToFile(ExecutableFileName);
  finally
    ImageStream.Free;
  end;
end;

end.
