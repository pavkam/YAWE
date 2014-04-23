{
  This file is a part of YAWE Project. (c) 2006 YAWE Project.
  Unauthorized distribution of this file is strictly prohibited.


  Initial Developer: Seth
}

program MapToBdmf;
uses
  Windows,
  SysUtils,
  MapHelp.LibInterface in '..\..\Vendor\MapHelp32\MapHelp.LibInterface.pas';

const
  DebugFileName = 'MapToBdmf.err';

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
  GetFileInformationByHandle(H, Info);
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
    FileSeek(H, 0, 0);
    FileWrite(H, PC^, WriteCount);
    FreeMem(Buf);
  end else
  begin
    FileSeek(H, 0, 2);
  end;
  FileWrite(H, Pointer(Date)^, DateLen);
  FileWrite(H, Pointer(Msg)^, MsgLen);
  FileWrite(H, CRLF[1], 2);
  SetEndOfFile(H);
  FileClose(H);
end;

var
  Result: Integer;

begin
  if ParamCount >= 1 then
  begin
    if ParamCount = 1 then
    begin
      Result := MapConvert(PChar(ParamStr(1)), nil, MID_MAP, MID_BDMF, 0);
      if Result = MAP_ERR_OK then
      begin
        OutputError('Conversion was successful.');
      end else
      begin
        OutputError(Format('Conversion failed, reason - %s (%d).', [MapFormatError(Result), Result]));
      end;
    end else
    begin
      Result := MapConvert(PChar(ParamStr(1)), PChar(ParamStr(2)), MID_MAP, MID_BDMF, 0);
      if Result = MAP_ERR_OK then
      begin
        OutputError('Conversion was successful.');
      end else
      begin
        OutputError(Format('Conversion failed, reason - %s (%d).', [MapFormatError(Result), Result]));
      end;
    end;
  end else OutputError('Target MAP file was not specified.');
end.
