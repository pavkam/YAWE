{
  This file is a part of YAWE Project. (c) 2006 YAWE Project.
  You can redestribute it under GPLv2 License.

  Based on DelphiCodeToDoc by TridenT which is covered by GPLv2 Licence.

  Initial Developer: Pavkam
}
program YAPI;

{$APPTYPE CONSOLE}
{%TogetherDiagram 'ModelSupport_YAPI\default.txaPackage'}

uses
  SysUtils,
  Classes,
  Converter in 'ReadWrite\Converter.pas',
  CodeReader in 'ReadWrite\CodeReader.pas',
  CodeWriter in 'ReadWrite\CodeWriter.pas',
  StringsReader in 'ReadWrite\StringsReader.pas',
  StringsWriter in 'ReadWrite\StringsWriter.pas',
  StringsConverter in 'ReadWrite\StringsConverter.pas',
  ConvertTypes in 'ReadWrite\ConvertTypes.pas',
  PreProcessorParseTree in 'Parse\PreProcessor\PreProcessorParseTree.pas',
  PreProcessorExpressionTokenise in 'Parse\PreProcessor\PreProcessorExpressionTokenise.pas',
  PreProcessorExpressionTokens in 'Parse\PreProcessor\PreProcessorExpressionTokens.pas',
  PreProcessorExpressionParser in 'Parse\PreProcessor\PreProcessorExpressionParser.pas',
  BuildParseTree in 'Parse\BuildParseTree.pas',
  BuildTokenList in 'Parse\BuildTokenList.pas',
  ParseError in 'Parse\ParseError.pas',
  ParseTreeNode in 'Parse\ParseTreeNode.pas',
  ParseTreeNodeType in 'Parse\ParseTreeNodeType.pas',
  SourceToken in 'Parse\SourceToken.pas',
  SourceTokenList in 'Parse\SourceTokenList.pas',
  TokenUtils in 'Parse\TokenUtils.pas',
  Tokens in 'Parse\Tokens.pas',
  TagComment in 'Parse\TagComment.pas',
  BasicStats in 'Process\Info\BasicStats.pas',
  Structure in 'Process\Extract\Structure.pas',
  VisitStructure in 'Process\Extract\VisitStructure.pas',
  DocGen in 'Process\Extract\DocGen.pas',
  DocGenHTML in 'Process\Extract\DocGenHTML.pas',
  DocGenHTML_Common in 'Process\Extract\DocGenHTML_Common.pas',
  uDocProject in 'Process\Extract\uDocProject.pas',
  VisitComment in 'Process\Extract\VisitComment.pas',
  uOptions in 'Process\Extract\uOptions.pas',
  DocGenCHM_Common in 'Process\Extract\DocGenCHM_Common.pas',
  DocGenCHM in 'Process\Extract\DocGenCHM.pas',
  uOldOptions in 'Process\Extract\uOldOptions.pas',
  RedCon in 'Process\Extract\RedCon.pas',
  uDocTemplate in 'Process\Extract\Structure\uDocTemplate.pas',
  uDocMember in 'Process\Extract\Structure\uDocMember.pas',
  uDocMethod in 'Process\Extract\Structure\uDocMethod.pas',
  uDocParameter in 'Process\Extract\Structure\uDocParameter.pas',
  uDocFunction in 'Process\Extract\Structure\uDocFunction.pas',
  uDocField in 'Process\Extract\Structure\uDocField.pas',
  uDocEvent in 'Process\Extract\Structure\uDocEvent.pas',
  uDocVar in 'Process\Extract\Structure\uDocVar.pas',
  uDocType in 'Process\Extract\Structure\uDocType.pas',
  uDocConstant in 'Process\Extract\Structure\uDocConstant.pas',
  uDocUseUnit in 'Process\Extract\Structure\uDocUseUnit.pas',
  uDocProperty in 'Process\Extract\Structure\uDocProperty.pas',
  uDocClass in 'Process\Extract\Structure\uDocClass.pas',
  uDocInterface in 'Process\Extract\Structure\uDocInterface.pas',
  uDocLibrary in 'Process\Extract\Structure\uDocLibrary.pas',
  uDocProgram in 'Process\Extract\Structure\uDocProgram.pas',
  uDocUnit in 'Process\Extract\Structure\uDocUnit.pas',
  uDocClassTree in 'Process\Extract\Structure\uDocClassTree.pas',
  uDocBaseVisitor in 'Process\Extract\Structure\Visitor\uDocBaseVisitor.pas',
  uDocTagCoverageVisitor in 'Process\Extract\Structure\Visitor\uDocTagCoverageVisitor.pas',
  uDocToNodesVisitor in 'Process\Extract\Structure\Visitor\uDocToNodesVisitor.pas',
  uDocSortVisitor in 'Process\Extract\Structure\Visitor\uDocSortVisitor.pas',
  uDocTagCoverage in 'Process\Extract\Structure\uDocTagCoverage.pas',
  VisitSetXY in 'Process\VisitSetXY.pas',
  BaseVisitor in 'Process\BaseVisitor.pas',
  Nesting in 'Process\Nesting.pas',
  VisitSetNesting in 'Process\VisitSetNesting.pas',
  AllProcesses in 'Process\AllProcesses.pas',
  TreeWalker in 'Process\TreeWalker.pas',
  JcfMiscFunctions in 'Utils\JcfMiscFunctions.pas',
  JcfLog in 'Utils\JcfLog.pas',
  ConsoleStringList in 'Utils\ConsoleStringList.pas',
  JclImports in 'Utils\JclImports.pas',
  uDocNamespace in 'Process\Extract\Structure\uDocNamespace.pas';

var
  sDPRFile: string;
  sOutDir: string;

  slDebugMessages: TStrings;
  slUserMessages: TStrings;

  cBuilder: TDOCProject;
begin
  { Write Copyright notice }
  WriteLn('YAPI - Documentation generator for YAWE project.');
  Writeln('Based on DelphiCodeToDoc by TridenT.');
  WriteLn('Code is covered under GPL license. Use at your own risk.');

  { Check parameters validity }
  if ParamCount <> 2 then
  begin
    WriteLn('Invalid parameter count specified. Usage: YAPI <project_dpr> <out_folder>');
    Readln;
    Exit;
  end;

  sDPRFile := ExpandFileName(ParamStr(1));
  sOutDir := ExpandFileName(ParamStr(2));
  Writeln(sDPRFile);
  { Check validity of parameters }
  if not FileExists(sDPRFile) then
  begin
    WriteLn('Input DPR file is missing! Please specify a valid one!');
    Readln;
    Exit;
  end;
  
  ForceDirectories(sOutDir);

  WriteLn('Start source check ...');

  slDebugMessages := TConsoleStringList.Create;
  slUserMessages := TConsoleStringList.Create;

  cBuilder := TDOCProject.Create;
  try
    cBuilder.DocOptions.SetDefaultValue;
    cBuilder.DocOptions.SetupPaths(sDPRFile, sOutDir);

    cBuilder.DocOptions.FilesExcludeList.Add('Misc.');
    cBuilder.DocOptions.FilesExcludeList.Add('API.');
    cBuilder.DocOptions.FilesExcludeList.Add('.LibInterface');

    cBuilder.SetDestinationMessages(slUserMessages, slDebugMessages);
    cBuilder.State := psNew;
 
    // Stupid piece of code from DTDC ...
    uDocProject.DocProject := cBuilder;

    if not cBuilder.Check then
    begin
      WriteLn('Check failed! Please fix the problem and retry!');
      Readln;
      Exit;
    end;

    WriteLn('Check succeded! Now starting build process ...');

    if not cBuilder.Build then
    begin
      WriteLn('Build Failed! Please fix the problem and retry!');
      Readln;
      Exit;
    end;

    WriteLn('Build succeded!');

  finally
    { Free resources }
    cBuilder.Free;
    slUserMessages.Free;
    slDebugMessages.Free;
  end;
  Readln;
end.
