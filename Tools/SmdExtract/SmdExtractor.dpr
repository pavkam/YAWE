program SmdExtractor;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  API.Win.NtCommon,
  API.Win.Kernel,
  API.Win.Types,
  Wdx.LibInterface in '..\..\Vendor\Wdx32\Wdx.LibInterface.pas';

procedure AdtExtractionCallback(Dummy: Pointer; Data: Pointer;
  NotificationType: TWdxNotificationType);
var
  MapData: PAdtMapData;
begin
  if NotificationType = wntNewMap then
  begin
    MapData := PAdtMapData(Data);
    Writeln('Extracting map ', MapData^.Name, '(', MapData^.Id, ')');
  end;
end;

procedure ExtractorMain;
var
  Res: Integer;
  Size: Integer;
  Target: string;
  Options: TAdtExtractionOptions;
  C: Char;
begin
  Options := [];
  if ParamCount > 0 then
  begin
    Target := ExtractFilePath(ParamStr(1));
    if not DirectoryExists(Target) then
    begin
      Writeln('Invalid source directory specified.');
      Writeln('Use registry to search for the data path? (Y/N)');
      Readln(C);
      if C in ['Y', 'y'] then
      begin
        SetLength(Target, MAX_PATH + 1);
        Size := MAX_PATH + 1;
        Wdx.LibInterface.WdxGetWoWDataPath(PChar(Target), @Size);
        SetLength(Target, Size - 1);
      end else Exit;
    end;
  end else
  begin
    SetLength(Target, MAX_PATH + 1);
    Size := MAX_PATH + 1;
    Wdx.LibInterface.WdxGetWoWDataPath(PChar(Target), @Size);
    SetLength(Target, Size - 1);
  end;

  if FindCmdLineSwitch('C', True) then
  begin
    Include(Options, aeoCompressed);
  end;

  Writeln('Press enter to start extraction.');
  Readln;

  Res := Wdx.LibInterface.WdxExtractAdtInfo('terrain.smd', PChar(Target));
  if Res = WDX_E_OK then
  begin
    Writeln('Extraction has been finished successfully');
  end else
  begin
    Writeln('Extraction failed with code ', Res);
  end;
  Readln;
end;

begin
  ExtractorMain;
end.
