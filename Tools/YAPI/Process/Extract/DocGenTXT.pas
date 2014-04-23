{*------------------------------------------------------------------------------
  TeXT Generator
  It provides all class and function to build Text files from the structure
   builder. It is mainly used for debug purpose.

  http://dephicodetodoc.sourceforge.net/
  Copyright TridenT 2003 - Under GNU GPL licence

  @Author    TridenT
  @Version   2003/12/01   TridenT   v0.0     Initial revision
-------------------------------------------------------------------------------}

unit DocGenTXT;

interface

uses Windows, SysUtils, Classes, Contnrs, Structure, DocGen;

type
  /// HTML output generator
  TDOCGenTXT = class(TDOCGenerator)
  private
    FGenText: TStringList; /// Output writer component
  protected
    procedure WritePageHeader(const DocItem: TDOCTemplate); override;
    procedure WritePageFooter; override;
    procedure WriteLegend; override;
    procedure WriteProjectSection(const DocProject: TDOCStructure); override;
    procedure WriteUnitSection(const DocUnit: TDOCUnit); override;
    procedure WriteClassSection(const DocClass: TDOCClass); override;
    procedure WriteMemberSection(const DocMember: TDOCMember); override;
    procedure WriteBlankSection; override;
    procedure BeforeBuild(const DocItem: TDOCTemplate); override;
    procedure AfterBuild(const DocItem: TDOCTemplate); override;
    procedure AddLine(const st: string); override;
  public
    function GetOutputFile : TFileName; override;
  end;

implementation

uses uOptions;

const
  /// Symbols for visibility of members
  TMemberVisibilityTxt: array[Low(TMemberVisibility)..High(TMemberVisibility)] of
    char = ('-', '#', '+', '*', 'A');


{*------------------------------------------------------------------------------
  Add a line to the output
  Since every output type have a different way to write the output, the AddLine
  method is overloaded.
  It simply add the text line in the stream.
  @param  st  String to add to the stream
-------------------------------------------------------------------------------}
procedure TDOCGenTXT.AddLine(const st: string);
begin
  FGenText.Add(st);
end;

{*------------------------------------------------------------------------------
  Save TEXT stream since the build is done
  @param  DocItem  TDOCTemplate to save
-------------------------------------------------------------------------------}
procedure TDOCGenTXT.AfterBuild(const DocItem: TDOCTemplate);
begin
  // Close TextFile
  try
    FGenText.SaveToFile(DocOptions.OutputFolder + DocItem.BuildPathName + '.txt');
  finally
    FreeAndNil(FGenText);
  end;
end;

{*------------------------------------------------------------------------------
  Create the TEXT stream before building
  @param  DocItem  TDOCTemplate that will be created
-------------------------------------------------------------------------------}
procedure TDOCGenTXT.BeforeBuild(const DocItem: TDOCTemplate);
begin
  // Create TextFile
  FGenText := TStringList.Create;
end;

/// Add an empty line to the stream
function TDOCGenTXT.GetOutputFile: TFileName;
begin
  //
end;

/// Write a blank section
procedure TDOCGenTXT.WriteBlankSection;
begin
  AddLine('');
end;

{*------------------------------------------------------------------------------
  Build the class section of the documentation
  Write Fields, methods, properties and events
  @param  DocClass  TDOCClass to generate
 ------------------------------------------------------------------------------}
procedure TDOCGenTXT.WriteClassSection(const DocClass: TDOCClass);
var
  IndexMember: integer;
  tmpMember:   TDOCMember;
begin
  AddLine('Class : ' + DocClass.Name);
  WriteBlankSection;
  //AddLine('Class Hierachy');
  //AddLine(' ' + DocClass.ClassHierarchy);
  WriteBlankSection;
  AddLine('Members');
  WriteBlankSection;
  AddLine(Format(' Fields (%d)', [DocClass.FieldsCount]));
  for IndexMember := 0 to DocClass.MembersCount - 1 do
  begin
    tmpMember := DocClass.GetMember(IndexMember) as TDOCMember;
    if tmpMember is TDOCField then
    begin
      AddLine('  ' + TMemberVisibilityTxt[tmpMember.MemberVisibility] + tmpMember.Name)
    end;
  end;
  WriteBlankSection;
  AddLine(Format(' Methods (%d)', [DocClass.MethodsCount]));
  for IndexMember := 0 to DocClass.MembersCount - 1 do
  begin
    tmpMember := DocClass.GetMember(IndexMember) as TDOCMember;
    if tmpMember is TDOCMethod then
    begin
      AddLine('  ' + TMemberVisibilityTxt[tmpMember.MemberVisibility] + tmpMember.Name)
    end;
  end;
  WriteBlankSection;
  AddLine(Format(' Propertys (%d)', [DocClass.PropertysCount]));
  for IndexMember := 0 to DocClass.MembersCount - 1 do
  begin
    tmpMember := DocClass.GetMember(IndexMember) as TDOCMember;
    if tmpMember is TDOCProperty then
    begin
      AddLine('  ' + TMemberVisibilityTxt[tmpMember.MemberVisibility] + tmpMember.Name)
    end;
  end;
  WriteBlankSection;
  AddLine('Related unit : ' + DocClass.GetParentName);
  WriteBlankSection;
  WriteLegend;
  WriteBlankSection;
end;

/// Write Legend - Member visibility symbol - at the end of he document
procedure TDOCGenTXT.WriteLegend;
begin
  AddLine('Legend');
  AddLine(' - Private');
  AddLine(' # Protected');
  AddLine(' + Public');
  AddLine(' * Published');
  AddLine(' A Automated');
end;

{*------------------------------------------------------------------------------
  Build the Member section of the documentation
  Write Fields, methods, properties or events, with parameters if exists
  @param  DocMember  TDOCMember to generate
 ------------------------------------------------------------------------------}
procedure TDOCGenTXT.WriteMemberSection(const DocMember: TDOCMember);
var
  tmpMethod:      TDOCMethod;
  IndexParameter: integer;
begin
  AddLine('Member : ' + DocMember.Name);
  WriteBlankSection;
  AddLine('Visibility : ' + MemberVisibilityName.Strings[integer(
    DocMember.MemberVisibility)]);
  WriteBlankSection;
  AddLine('SourceCode : ');
  if (DocMember is TDOCField) or (DocMember is TDOCProperty) then
  begin
    AddLine('  ' + DocMember.BodySource)
  end
  else    begin
    AddLine('  ' + DocMember.BodySource)
  end;
  WriteBlankSection;

  if (DocMember is TDOCMethod) then
  begin
    tmpMethod := DocMember as TDOCMethod;
    AddLine(Format('Parameters (%d)', [tmpMethod.ParametersCount]));
    for IndexParameter := 0 to tmpMethod.ParametersCount - 1 do
    begin
      AddLine('  ' + tmpMethod.GetParameter(IndexParameter).Name + ' : ' +
        tmpMethod.GetParameter(IndexParameter).RelatedType)
    end;
    //else AddLine(' no parameters');
    WriteBlankSection;

    if tmpMethod.RelatedType <> '' then
    begin
      AddLine('Returns : ');
      Addline(' ' + tmpMethod.RelatedType);
      WriteBlankSection;
    end;
  end;
  AddLine('Related class : ' + DocMember.GetParentName);
  WriteBlankSection;
end;

/// Write documentation Page footer
procedure TDOCGenTXT.WritePageFooter;
begin
  WriteBlankSection;
  AddLine('------------------------------------------');
  AddLine('DelphiCodeToDoc - CopyRight 2003 - TridenT');
end;

/// Write documentation Page header
procedure TDOCGenTXT.WritePageHeader(const DocItem: TDOCTemplate);
begin
  AddLine(FileStructure.Name);
  AddLine('------------------------------------------');
  WriteBlankSection;
end;

{*------------------------------------------------------------------------------
  Build the Project section of the documentation
  Write all files (units) in the projects
  @param  DocStructure  TDOCStructure to generate
 ------------------------------------------------------------------------------}
procedure TDOCGenTXT.WriteProjectSection(const DocProject: TDOCStructure);
var
  nbClass, IndexUnit: integer;
begin
  nbClass := 0;
  for IndexUnit := 0 to DocProject.UnitsCount - 1 do
  begin
    Inc(nbClass, TDOCUnit(DocProject.GetUnit(IndexUnit)).ClassesCount)
  end;

  AddLine('Project : ' + DocProject.Name);
  AddLine(Format(' %d class in %d units.', [nbClass, DocProject.UnitsCount]));
  WriteBlankSection;
end;

{*------------------------------------------------------------------------------
  Build the Unit section of the documentation
  Write all Classes, types, constants, variables, functions in the projects
  @param  DocUnit  TDOCUnit to generate
 ------------------------------------------------------------------------------}
procedure TDOCGenTXT.WriteUnitSection(const DocUnit: TDOCUnit);
var
  IndexItem: integer;
begin
  AddLine('Unit : ' + DocUnit.Name);
  WriteBlankSection;
  AddLine(Format(' Classes (%d)', [DocUnit.ClassesCount]));
  for IndexItem := 0 to DocUnit.ClassesCount - 1 do
  begin
    AddLine('  ' + TDOCClass(DocUnit.GetClass(IndexItem)).Name);
  end;
  WriteBlankSection;
  AddLine(Format(' Types (%d)', [DocUnit.TypeList.Count]));
  for IndexItem := 0 to DocUnit.TypeList.Count - 1 do
  begin
    AddLine('  ' + (DocUnit.TypeList.Items[IndexItem]).Name);
  end;
  WriteBlankSection;
  AddLine(Format(' Constants (%d)', [DocUnit.ConstantList.Count]));
  for IndexItem := 0 to DocUnit.ConstantList.Count - 1 do
  begin
    AddLine('  ' + (DocUnit.ConstantList[IndexItem]).Name);
  end;
  WriteBlankSection;
  AddLine(Format(' Vars (%d)', [DocUnit.VarList.Count]));
  for IndexItem := 0 to DocUnit.VarList.Count - 1 do
  begin
    AddLine('  ' + (DocUnit.VarList.Items[IndexItem]).Name);
  end;
  WriteBlankSection;
  AddLine(Format(' Functions (%d)', [DocUnit.FunctionList.Count]));
  for IndexItem := 0 to DocUnit.FunctionList.Count - 1 do
  begin
    AddLine('  ' + (DocUnit.FunctionList.Items[IndexItem]).Name);
  end;
  WriteBlankSection;
end;

end.
