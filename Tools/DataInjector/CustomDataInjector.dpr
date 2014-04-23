{
  This file is a part of YAWE Project. (c) 2006 YAWE Project.
  Unauthorized distribution of this file is strictly prohibited.

  Collection of various algorithms, mostly sorting.


  Initial Developers: Seth
}

program CustomDataInjector;

uses
  API.Win.Types,
  API.Win.NtCommon,
  API.WIn.Kernel,
  Classes,
  SysUtils,
  DataInjector in 'DataInjector.pas';

const
  DebugFileName = 'DataInjector.err';

procedure OutputError(const Msg: string);
const
  CRLF = #13#10;
var
  H: Integer;
  Info: TByHandleFileInformation;
  Buf: Pointer;
  PC: PChar;
  Date: string;
  MsgLen: Integer;
  DateLen: Integer;
  WriteCount: Integer;
begin
  Date := StringReplace(DateTimeToStr(Now), '. ', '-', [rfReplaceAll]);
  Date := Date + ': ';
  DateLen := Length(Date);
  if not FileExists(DebugFileName) then
  begin
    H := FileCreate(DebugFileName);
    if H = -1 then Exit;
  end else
  begin
    H := FileOpen(DebugFileName, fmOpenReadWrite);
    if H = -1 then Exit;
  end;
  MsgLen := Length(Msg);
  GetFileInformationByHandle(H, @Info);
  if Integer(Info.nFileSizeLow) + MsgLen + DateLen + 2 > $1000 then
  begin
    GetMem(Buf, Info.nFileSizeLow);
    FileRead(H, Buf^, Info.nFileSizeLow);
    PC := Buf;
    WriteCount := Info.nFileSizeLow;
    Inc(Info.nFileSizeLow, MsgLen + DateLen + 2);
    while ((PC^ <> #13) or (Integer(Info.nFileSizeLow) > $1000)) and
          (Integer(PC) - Integer(Buf) <> WriteCount) do
    begin
      Inc(PC);
      Dec(Info.nFileSizeLow);
    end;
    if PC^ = #13 then Inc(PC, 2);
    Dec(WriteCount, Integer(PC) - Integer(Buf));
    FileSeek(H, 0, Integer(soBeginning));
    FileWrite(H, PC^, WriteCount);
    FreeMem(Buf);
  end else
  begin
    FileSeek(H, 0, Integer(soEnd));
  end;
  FileWrite(H, Pointer(Date)^, DateLen);
  FileWrite(H, Pointer(Msg)^, MsgLen);
  FileWrite(H, CRLF[1], 2);
  SetEndOfFile(H);
  FileClose(H);
end;

var
  MemStream: TMemoryStream;
  Target: string;
  DataSource: string;
  ResourceName: string;
  Options: array of string;
  I: Integer;
  Properties: TDataProperties;

function OptionSpecified(const OptIdent: string): Boolean;
var
  I: Integer;
begin
  for I := 0 to Length(Options) -1 do
  begin
    if Options[I] = OptIdent then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

function DataPropertiesFromOptions: TDataProperties;
var
  I: Integer;
begin
  Result := [];
  for I := 0 to Length(Options) -1 do
  begin
    if Options[I] = '-R' then
    begin
      Include(Result, dpReadable);
    end else if Options[I] = '-W' then
    begin
      Include(Result, dpWritable);
    end else if Options[I] = '-E' then
    begin
      Include(Result, dpExecutable);
    end else if Options[I] = '-I' then
    begin
      Include(Result, dpInitialized);
    end else if Options[I] = '-U' then
    begin
      Exclude(Result, dpInitialized);
    end else if Options[I] = '-D' then
    begin
      Include(Result, dpDiscardable);
    end else if Options[I] = '-S' then
    begin
      Include(Result, dpShareable);
    end;
  end;
  if Result = [] then Result := dpDefault;
end;

begin
  if ParamCount >= 3 then
  begin
    MemStream := TMemoryStream.Create;
    try
      Target := ParamStr(1);
      if FileExists(Target) then
      begin
        DataSource := ParamStr(2);
        if FileExists(DataSource) then
        begin
          ResourceName := ParamStr(3);
          SetLength(Options, ParamCount - 3);
          for I := 4 to ParamCount do
          begin
            Options[I-4] := ParamStr(I);
          end;
          if Length(ResourceName) < 9 then
          begin
            try
              MemStream.LoadFromFile(DataSource);
              Properties := DataPropertiesFromOptions;
              case InjectDataIntoExecutable(Target, MemStream.Memory, MemStream.Size,
                ResourceName, Properties) of
                -2: OutputError('Target executable already contains debug info.');
                -1: OutputError('Target is not a valid PE executable.');
                 0: OutputError('Data was injected successfully into the target executable.');
              end;
            except
             OutputError('Data injection failed because of an exception.');
            end;
          end else OutputError('Resource name too long.');
        end else OutputError('Debug file does not exist.');
      end else OutputError('Target executable does not exist.');
    finally
      MemStream.Free;
    end;
  end else OutputError('Target executable not specified.');
end.
