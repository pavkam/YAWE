{*------------------------------------------------------------------------------
  SVN Build Extractor
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU General Public License (GPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author PavkaM
------------------------------------------------------------------------------}

program SVNBuild;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Registry,
  Windows,
  Classes;

function AskUser(const sDefault, sQuestion : String) : String;
var
 sEnter : string;
begin
 Write( sQuestion + ' (' + sDefault + '): ');
 Readln(sEnter);

 if sEnter = '' then
    Result := sDefault
    else
    Result := sEnter;
end;

function AskUserDirectory(const sPath, sQuestion : String) : String;
begin
 Writeln('---------------------------------------------------');
 while True do
 begin
   Result := AskUser(sPath, sQuestion);
   if DirectoryExists(Result) then
      Break;

   Writeln('Invalid Path specified! Please re-enter!');
 end;
 Writeln(sQuestion + ' is ' + Result);
end;

function StringIsIdent(const sName : String) : Boolean;
Var
 I : Integer;
begin
 Result := False;

 { At least one letter! }
 if sName = '' then
    Exit;

 { First character must not be a digit }
 if sName[1] in ['0'..'9'] then
    Exit;

 { Must contain valid characters all along }
 for I := 1 to Length(sName) do
     if not (sName[I] in ['0' .. '9', 'a' .. 'z', 'A' .. 'Z', '_']) then
     Exit;

 Result := True;
end;

function AskUserName(const sDefUser, sQuestion : String) : String;
begin
 Writeln('---------------------------------------------------');
 while True do
 begin
   Result := AskUser(sDefUser, sQuestion);

   if StringIsIdent(Result) then
      break;

   Writeln('Invalid Name specified! Please re-enter!');
 end;

 Writeln(sQuestion + ' is ' + Result);
end;

procedure NotifyUserDirectory(const sPath, sWhat : String);
begin
 Writeln(sWhat + ' is ' + sPath);
end;

function ExtractFilePathNoDelim(const sPath : String) : String;
begin
 Result := SysUtils.ExtractFilePath(sPath);
 if Result <> '' then
    if Result[Length(Result)] = '\' then
       Delete(Result, Length(Result), 1);
end;

procedure CreateUserMark(const sPath, sUser : String);
Var
 fOut : TextFile;
begin
 AssignFile(fOut, sPath);

 {$I-}
 Rewrite(fOut);
 {$I+}
 if IOResult <> 0 then
    Exit;

 Write(fOut, sUser + '<');
 CloseFile(fOut);
end;

function LoadUserMark(const sPath : String) : String;
Var
 fIn : TextFile;
begin
 Result := '';
 
 AssignFile(fIn, sPath);

 {$I-}
 Reset(fIn);
 {$I+}
 if IOResult <> 0 then
    Exit;

 ReadLn(fIn, Result);
 CloseFile(fIn);

 if Pos('<', Result) > 0 then
    Delete(Result, Pos('<', Result), Length(Result));
end;

function InsertNameIfNeeded(const sRevFileName, sName : String) : Boolean;
var
 sRevFile  : TStrings;
 i         : Integer;

 iMarkLine,
  iSumLine : Integer;

  sLine    : String;
  sSumLine : String;
begin
 Result := False;
 sRevFile := TStringList.Create();

 { Load file }
 try
  sRevFile.LoadFromFile(sRevFileName);
 except
  sRevFile.Free();
  Exit;
 end;

 { Search for the user-mark part, the sum part and if the username is present }
 iMarkLine := sRevFile.Count;
 iSumLine  := iMarkLine + 1;
 sSumLine  := 'BuildCount = 0;';

 for I := 0 to sRevFile.Count - 1 do
 begin
  sLine := UpperCase(sRevFile[I]);

  if Pos('{*BUILDS*}', sLine) > 0 then
     iMarkLine := I;

  if Pos('BUILDCOUNT =', sLine) > 0 then
  begin
   iSumLine := I;
   sSumLine := sRevFile[I];
  end;

  if Pos('{<USR-' + UpperCase(sName) + '>}', sLine) > 0 then
     begin
      { Already added .. just exit }
      Result := False;

      sRevFile.Free();
      Exit;
     end;
 end;

 { Prepare the file if it's not yet "formatted" }

 if iMarkLine = sRevFile.Count then
 begin
  sRevFile.Add('{*BUILDS*}');
  sRevFile.Add('');
 end;

 { Update Sum statement }
 i := Pos(' = ', sSumLine) + 3;
 Insert(sName + '_Builds + ', sSumLine, i);
 sRevFile[iSumLine] := sSumLine;

 { add the user-mark }
 sRevFile.Insert(iMarkLine + 1, sName + '_Builds = {<USR-' + sName + '>}000{</USR-' + sName + '>};');

 { Save file }
 try
  sRevFile.SaveToFile(sRevFileName);
 except
  sRevFile.Free();
  Exit;
 end;

 Result := True;
 sRevFile.Free();
end;

procedure InstallBDSHook(const sVer : String);
var
 sCurrentDir          : String;
 sRootDir             : String;
 sSVNDir              : String;

 sProjectPath         : String;
 sRlToolPath,
  sRlSvnPath,
   sRlRevisionPath,
    sRlUserMarkPath   : String;

 sGenCmd              : String;
 
 regMy                : TRegistry;
 sName                : String;
begin
 Writeln('Installing SVN Build Tool into BDS ' + sVer + ' ...');

 { Extract the directory the svn tool is located in }
 sCurrentDir := AskUserDirectory(ExtractFilePathNoDelim(ParamStr(0)), 'Tool Directory');

 { Locate the root .svn path }
 sSVNDir := AskUserDirectory(ExtractFilePathNoDelim(sCurrentDir) + '\.svn', 'SVN Root Directory');
 sRootDir := ExtractFilePathNoDelim(sSVNDir);

 { Locate the project's path }
 sProjectPath := AskUserDirectory(sRootDir + '\YAWE\trunk', 'YAWE Trunk/ Directory');

 { Generate relative path }
 sRlToolPath := '$PROJECTPATH\' + ExtractRelativePath(sProjectPath + '\.', sCurrentDir) + '\' + ExtractFileName(ParamStr(0));
 sRlSvnPath := '$PROJECTPATH\' + ExtractRelativePath(sProjectPath + '\.', sSVNDir) + '\entries';
 sRlRevisionPath := '$PROJECTPATH\Framework\Framework.Revision.rev';
 sRlUserMarkPath := '$PROJECTPATH\Framework\usermark.txt';

 Writeln('---------------------------------------------------');
 
 NotifyUserDirectory(sRlToolPath, 'Relative Tool Path');
 NotifyUserDirectory(sRlSvnPath, 'Relative SVN Root Path');
 NotifyUserDirectory(sRlRevisionPath, 'Relative Revision Unit Path');
 NotifyUserDirectory(sRlUserMarkPath, 'Relative Usermark Path');

 Writeln;
 Writeln('Installing BDS Registry entries ...');

 regMy := TRegistry.Create();
 regMy.RootKey := HKEY_CURRENT_USER;

 regMy.DeleteKey('Software\Borland\BDS\'+sVer+'\Tools\RevisionExtractor');
 if not regMy.OpenKey('Software\Borland\BDS\'+sVer+'\Tools\RevisionExtractor', True) then
 begin
  Writeln('Cannot complete operation! Exiting!');
  Halt(1);
 end;

 sGenCmd := '"' + sRlToolPath + '" ' + sRlSvnPath + ' ' + sRlRevisionPath + ' ' + sRlUserMarkPath;

 regMy.WriteString('Command', sGenCmd);
 regMy.WriteString('DefaultExt', '*.rev');
 regMy.WriteString('Filter', '<None>');
 regMy.WriteString('GeneratedExt', '');
 regMy.WriteString('Linker', '0');
 regMy.WriteString('OtherExt', '');
 regMy.WriteString('Title', 'RevisionExtractor');
 regMy.CloseKey();
 regMy.Free();
 
 Writeln;
 Writeln('Configuring your SVN revision account ...');

 { Try to load old usermaks }
 sName := LoadUserMark(sRootDir + '\YAWE\trunk\Framework\usermark.txt');
 if sName = '' then
    LoadUserMark(sRootDir + '\YAWE\stable\Framework\usermark.txt');
 if sName = '' then
    LoadUserMark(sRootDir + '\YAWE\experimental\Framework\usermark.txt');

 if not StringIsIdent(sName) then
    sName := '<None>';

 sName := AskUserName(sName, 'Your Project Nickname');

 { Generate usermark entries }
 CreateUserMark(sRootDir + '\YAWE\trunk\Framework\usermark.txt', sName);
 CreateUserMark(sRootDir + '\YAWE\stable\Framework\usermark.txt', sName);
 CreateUserMark(sRootDir + '\YAWE\experimental\Framework\usermark.txt', sName);

 Writeln('Registered you User/Mark to SVN Build system.');

 { Add user to build count numbering! }
 if InsertNameIfNeeded(sRootDir + '\YAWE\trunk\Framework\Framework.Revision.rev', sName) then
    Writeln('Configured Trunk/ branch for new user name!')
    else
    Writeln('Branch Trunk/ already contains user name!');

 if InsertNameIfNeeded(sRootDir + '\YAWE\stable\Framework\Framework.Revision.rev', sName) then
    Writeln('Configured Stable/ branch for new user name!')
    else
    Writeln('Branch Stable/ already contains user name!');

 if InsertNameIfNeeded(sRootDir + '\YAWE\experimental\Framework\Framework.Revision.rev', sName) then
    Writeln('Configured Experimental/ branch for new user name!')
    else
    Writeln('Branch Experimental/ already contains user name!');

 Writeln;
 Writeln('---------------------------------------------------');
 Writeln('Installation Complete! Restart BDS and that''s all ;). Press ENTER to close.');

 ReadLn;
end;

procedure HaltMe(iCode: Integer; const sReason: string);
begin
  Halt(iCode);
end;

var
  sSVNFile: string;
  sBuildFile: string;
  sOutFile: string;

  cStream: TFileStream;
  sBlock: string;
  iEntry: Integer;

  sSearch: string;
  iRevision: Integer;
  iSkip    : Integer;

  iRevBegin: Integer;
  iRevEnd: Integer;

  sRevBegin: string;
  sRevEnd: string;

  sTemp: string;
begin
  { Simple tool to find out the SVN revision number and builds }

  { Install the BDS registry options }
  if ParamCount() = 0 then
     InstallBDSHook('4.0');

  sSVNFile   := '';
  sOutFile   := '';
  sBuildFile := '';
  sTemp      := '';
  iRevision  := 0;

  for iEntry := 1 to ParamCount() do
  begin
    sTemp := sTemp + ParamStr(iEntry);

    if FileExists( sTemp ) then
    begin
      if sSVNFile = '' then
        sSVNFile := sTemp
      else
        if sOutFile = '' then
          sOutFile := sTemp
        else
          if sBuildFile = '' then
            sBuildFile := sTemp;
      sTemp := '';
    end else sTemp := sTemp + ' ';
  end;

  if not FileExists(sSVNFile) then HaltMe(1, sSVNFile + ' doesn''t exist !'); { Exit Error Code }
  if not FileExists(sOutFile) then HaltMe(1, sOutFile + ' doesn''t exist !'); { Exit Error Code }
  if not FileExists(sBuildFile) then HaltMe(1, sBuildFile + ' doesn''t exist !'); { Exit Error Code }

  cStream := nil;

  try
    cStream := TFileStream.Create(sSVNFile, fmOpenRead);
  except
    on Exception do HaltMe(1, 'Can''t open SVN file!'); { Exit Error Code }
  end;

  SetLength(sBlock, cStream.Size);
  cStream.Read(sBlock[1], cStream.Size);

  cStream.Destroy;

  sSearch := 'revision="';
  iEntry := Pos(sSearch, sBlock);

  if iEntry = 0 then
  begin
   { Maybe new TortoiseSVN format? }
   iSkip   := 0;
   sSearch := '';
   for iEntry := 1 to Length(sBlock) do
   begin
     if sBlock[iEntry] = #10 then
     begin
      Inc(iSkip);
      if (iSkip = 4) then
         break;
     end else
     if iSkip = 3 then
     begin
      sSearch := sSearch + sBlock[iEntry];
     end;
   end;

   { sSearch should contain the revision number }

   try
     iRevision := StrToInt( sSearch );
   except
     on Exception do HaltMe(1, 'Unrecognized SVN format!'); { Exit Error Code }
   end;

  end else
  begin
    {It's old SVN format}
    Delete(sBlock, 1, iEntry + Length(sSearch) - 1);

    iEntry := Pos('"', sBlock);
    if iEntry = 0 then HaltMe(1, 'No " In SVN file left!'); { Exit Error Code }

    try
      iRevision := StrToInt(Copy(sBlock, 1, iEntry - 1));
    except
      on Exception do HaltMe(1, 'Invalid revision!'); { Exit Error Code }
    end;
    
  end;


  { Let's get the user id }

  try
    cStream := TFileStream.Create(sBuildFile, fmOpenRead);
  except
    on Exception do HaltMe(1, 'Can''t open user id File!'); { Exit Error Code }
  end;

  SetLength(sBlock, cStream.Size);
  cStream.Read(sBlock[1], cStream.Size);
  cStream.Destroy;

  { sBlock now contains the user id }
  sTemp := Copy(sBlock, 1, Pos('<', sBlock) - 1);

  { Now try to read the output file }

  try
    cStream := TFileStream.Create(sOutFile, fmOpenRead);
  except
    on Exception do HaltMe(1, 'Can''t open Out File!'); { Exit Error Code }
  end;

  SetLength(sBlock, cStream.Size);
  cStream.Read(sBlock[1], cStream.Size);
  cStream.Destroy;

  sRevBegin := '{<REV>}';
  sRevEnd   := '{</REV>}';

  iRevBegin := Pos(sRevBegin, sBlock);
  iRevEnd   := Pos(sRevEnd, sBlock);

  if (iRevBegin * iRevEnd) = 0 then HaltMe(1, 'No revision marks!'); { Exit Error Code }

  Delete(sBlock, iRevBegin + Length(sRevBegin), iRevEnd - iRevBegin - Length(sRevBegin));
  Insert(IntToStr(iRevision), sBlock, iRevBegin + Length(sRevBegin) );


  { Add build for the user }

  sRevBegin := '{<USR-' + sTemp+'>}';
  sRevEnd   := '{</USR-' + sTemp+'>}';

  iRevBegin := Pos(sRevBegin, sBlock);
  iRevEnd   := Pos(sRevEnd, sBlock);

  if (iRevBegin * iRevEnd) = 0 then HaltMe(1, 'No build marks for user!'); { Exit Error Code }

  sTemp := Copy(sBlock, iRevBegin + Length(sRevBegin), iRevEnd - iRevBegin - Length(sRevBegin));
  Delete(sBlock, iRevBegin + Length(sRevBegin), iRevEnd - iRevBegin - Length(sRevBegin));

  try
    Insert(IntToStr(StrToInt(sTemp) + 1), sBlock, iRevBegin + Length(sRevBegin));
  except
    on Exception do;
  end;


  { Now try to save the output file }

  try
    cStream := TFileStream.Create(sOutFile, fmCreate);
  except
    on Exception do HaltMe(1, 'Can''t create out file!'); { Exit Error Code }
  end;

  try
    cStream.Write(sBlock[1], Length(sBlock));
    cStream.Destroy;
  except
    on Exception do HaltMe(1, 'Can''t save out file!'); { Exit Error Code }
  end;
end.
