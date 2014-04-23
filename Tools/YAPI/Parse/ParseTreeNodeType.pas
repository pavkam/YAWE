unit ParseTreeNodeType;

{
  This enumeration describes all of the types of parse tree nodes
  that we are interested in
}

{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is ParseTreeNodeType, released May 2003.
The Initial Developer of the Original Code is Anthony Steele. 
Portions created by Anthony Steele are Copyright (C) 1999-2000 Anthony Steele.
All Rights Reserved. 
Contributor(s): Anthony Steele. 

The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"). you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.mozilla.org/NPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied.
See the License for the specific language governing rights and limitations 
under the License.
------------------------------------------------------------------------------*)
{*)}

interface

type
  { roles that the interior node can play }
  TParseTreeNodeType = (
    nUnknown,
    nLeaf,
    nProgram,
    nUnit,
    nUnitHeader,
    nUnitName,
    nPackage,
    nLibrary,
    nUses,
    nUsesItem,
    nUsesFilename, 	// ADDED By TridenT to get units filename easily
    nRequires,
    nContains,
    nIdentList,
    nIdentifier,
    nDottedIdentifier, 	// TridenT
    nInterfaceSection,
    nImplementationSection,
    nBlock,
    nStatementList,
    nDeclSection,
    nLabelDeclSection,
    nConstSection,
    nConstDecl,
    nTypeSection,
    nTypeDecl,
    nArrayConstant,
    nRecordConstant,
    nRecordFieldConstant,
    nType,
    nRestrictedType,
    nSubrangeType,
    nEnumeratedType,
    nArrayType,
    nRecordType,
    nFieldDeclaration,
    nRecordVariantSection,
    nRecordVariant,
    nSetType,
    nProcedureType,
    nVarSection,
    nVarDecl,
    nAbsoluteVar,
    nVariableInit,
    nDesignator,
    nExpression,
    nTerm,
    nUnaryOp,
    nActualParams,
    nStatement,
    nAssignment,
    nInline,
    nInlineItem,
    nStatementLabel,
    nCompoundStatement,
    nIfCondition,
    nIfBlock,
    nElseBlock,
    nCaseStatement,
    nCaseSelector,
    nCaseLabels,
    nCaseLabel,
    nElseCase,
    nRepeatStatement,
    nWhileStatement,
    nLoopHeaderExpr,
    nBlockHeaderExpr,
    nForStatement,
    nWithStatement,
    nTryAndHandlerBlock,
    nTryBlock,
    nFinallyBlock,
    nExceptBlock,
    nExceptionHandlers,
    nOnExceptionHandler,
    nProcedureDecl,
    nFunctionDecl,
    nConstructorDecl,
    nDestructorDecl,
    nFunctionHeading,
    nProcedureHeading,
    nConstructorHeading,
    nDestructorHeading,
    nFormalParams,
    nFormalParam,
    nFunctionReturnType,
    nProcedureDirectives,
    nProcedureDirectiveName, 	// TridenT
    nExternalDirective,
    nObjectType,
    nInitSection,
    nClassType,
    nClassHeritage,
    nClassBody,
    nClassVisibility,
    nClassDeclarations,
    nClassDirectives, 	// TridenT
    nClassDirectiveName, 	// TridenT
    nProperty,
    nPropertyParameterList,
    nPropertySpecifier,
    nInterfaceType,
    nInterfaceHeritage,
    nInterfaceTypeGuid,
    nInterfaceBody,
    nBracketedQual,
    nAsm,
    nAsmStatement,
    nAsmIdent,
    nASMOpcode,
    nAsmParam,
    nAsmLabel,
    nHintDirectives,
    nPropertyDirective,
    nExports,
    nExportedProc,
    nLiteralString,
    nHashLiteralChar,
    nHatLiteralChar,
    // ADDED By TridenT to manage Comments tokens
	  nCurlyBlock,
    nBracketStarBlock,
    nCommentList,
    nInlineComment,
    nEndOfLineComment,
    nComment,
    nTAGComment,
    nTAGAuthor,
    nTAGChanges,
    nTAGDocs,
    nTAGDescription,
    nTAGVersion,
    nTAGParam,
    nTAGReturn,
    nTAGSee,
    nTAGToDo,
    nTAGThrows,
    nTAGAdditionalComment,
    nTAGUnknown,
    nAttribute
    );

  TParseTreeNodeTypeSet = set of TParseTreeNodeType;

const
  DirectiveNodes: TParseTreeNodeTypeSet    =
    [nProcedureDirectives, nExternalDirective,  nHintDirectives, nPropertyDirective];
  ProcedureNodes: TParseTreeNodeTypeSet    =
    [nProcedureDecl, nFunctionDecl, nConstructorDecl, nDestructorDecl];
  ProcedureHeadings: TParseTreeNodeTypeSet =
    [nFunctionHeading, nProcedureHeading, nConstructorHeading, nDestructorHeading];
  // Added Bry TridenT to handle TAGged comments
  TAGNodes: TParseTreeNodeTypeSet =
    [nTAGAuthor, nTAGChanges, nTAGDocs, nTAGDescription, nTAGVersion, nTAGParam, nTAGReturn,
    nTAGSee, nTAGToDo, nTAGThrows, nTAGAdditionalComment, nTAGUnknown];

  ObjectTypes: TParseTreeNodeTypeSet  = [nObjectType, nClassType, nInterfaceType];
  ObjectBodies: TParseTreeNodeTypeSet = [nClassBody, nInterfaceBody];

  { can declare these at the start of a procedure }
  InProcedureDeclSections: TParseTreeNodeTypeSet =
    [nVarSection, nConstSection, nLabelDeclSection, nTypeSection];

  UsesClauses: TParseTreeNodeTypeSet = [nUses, nRequires, nContains];

  TopOfProgramSections = [nProgram, nPackage, nLibrary];

  TopOfFileSection = [nProgram, nPackage, nLibrary, nUnit];

  { can find these blocks of def/dels outside of anything }
  nTopLevelSections = [nTypeSection, nConstSection, nVarSection,
    nLabelDeclSection, nExports];



function NodeTypeToString(const pe: TParseTreeNodeType): string;

implementation

uses SysUtils;

function NodeTypeToString(const pe: TParseTreeNodeType): string;
begin
  case pe of
    nUnknown:
      Result := 'Unknown';
    nLeaf:
      Result := 'Leaf';
    nProgram:
      Result := 'Program';
    nUnit:
      Result := 'Unit';
    nUnitHeader:
      Result := 'Unit header';
    nUnitName:
      Result := 'Unit name';
    nPackage:
      Result := 'Package';
    nLibrary:
      Result := 'Library';
    nUses:
      Result := 'Uses';
    nUsesItem:
      Result := 'Uses Item';
    // ADDED by TridenT
	nUsesFilename:
      Result := 'Uses Filename';
    nRequires:
      Result := 'Requires';
    nContains:
      Result := 'Contains';
    nIdentList:
      Result := 'ident list';
    nIdentifier:
      Result := 'Identifier';
    nDottedIdentifier:
      Result := 'Dotted Identifier';
    nInterfaceSection:
      Result := 'Interface section';
    nImplementationSection:
      Result := 'Implmentation section';
    nBlock:
      Result := 'Block';
    nStatementList:
      Result := 'Statement list';
    nDeclSection:
      Result := 'Decl section';
    nLabelDeclSection:
      Result := 'Label decl section';
    nConstSection:
      Result := 'const section';
    nConstDecl:
      Result := 'Const decl';
    nTypeSection:
      Result := 'type section';
    nTypeDecl:
      Result := 'Type Decl';
    nArrayConstant:
      Result := 'Array constant';
    nRecordConstant:
      Result := 'Record Constant';
    nRecordFieldConstant:
      Result := 'Field constant';
    nType:
      Result := 'Type';
    nRestrictedType:
      Result := 'Restricted type';
    nSubrangeType:
      Result := 'Subrange type';
    nEnumeratedType:
      Result := 'Enumerated type';
    nArrayType:
      Result := 'Array type';
    nRecordType:
      Result := 'record type';
    nFieldDeclaration:
      Result := 'Field declarations';
    nRecordVariantSection:
      Result := 'Record variant section';
    nRecordVariant:
      Result := 'Record variant';
    nSetType:
      Result := 'Set type';
    nProcedureType:
      Result := 'procedure type';
    nVarSection:
      Result := 'Var section';
    nVarDecl:
      Result := 'Var decl';
    nAbsoluteVar:
      Result := 'Absolute var';
    nVariableInit:
      Result := 'Variable init';
    nDesignator:
      Result := 'Designator';
    nExpression:
      Result := 'Expression';
    nTerm:
      Result := 'Term';
    nUnaryOp:
      Result := 'Unary op';
    nActualParams:
      Result := 'Actual params';
    nStatement:
      Result := 'Statement';
    nAssignment:
      Result := 'Assignment';
    nInline:
      Result := 'Inline';
    nInlineItem:
      Result := 'Inline item';
    nStatementLabel:
      Result := 'Statement label';
    nCompoundStatement:
      Result := 'Compound statement';
    nIfCondition:
      Result := 'If Condition';
    nIfBlock:
      Result := 'If Block';
    nElseBlock:
      Result := 'Else block';
    nCaseStatement:
      Result := 'Case statement';
    nCaseSelector:
      Result := 'Case selector';
    nCaseLabels:
      Result := 'Case labels';
    nCaseLabel:
      Result := 'Case label';
    nElseCase:
      Result := 'else case';
    nRepeatStatement:
      Result := 'Repeat statement';
    nWhileStatement:
      Result := 'While Statement';
    nLoopHeaderExpr:
      Result := 'Loop header expr';
    nBlockHeaderExpr:
      Result := 'Block header expr';
    nForStatement:
      Result := 'For statement';
    nWithStatement:
      Result := 'With statement';
    nTryAndHandlerBlock:
      Result := 'try and handler block';
    nTryBlock:
      Result := 'try block';
    nFinallyBlock:
      Result := 'finally block';
    nExceptBlock:
      Result := 'except block';
    nExceptionHandlers:
      Result := 'Exception handlers';
    nOnExceptionHandler:
      Result := 'On exception handler';
    nProcedureDecl:
      Result := 'Procedure decl';
    nFunctionDecl:
      Result := 'Function Decl';
    nConstructorDecl:
      Result := 'Constructor decl';
    nDestructorDecl:
      Result := 'Destructor decl';
    nFunctionHeading:
      Result := 'Function heading';
    nProcedureHeading:
      Result := 'Procedure Heading';
    nConstructorHeading:
      Result := 'Constructor Heading';
    nDestructorHeading:
      Result := 'Destructor heading';
    nFormalParams:
      Result := 'Formal params';
    nFormalParam:
      Result := 'formal param';
    nFunctionReturnType:
      Result := 'Function Return type';
    nProcedureDirectives:
      Result := 'Procedure directives';
    nProcedureDirectiveName:
      Result := 'Procedure directive name';
    nExternalDirective:
      Result := 'external directive';
    nObjectType:
      Result := 'object type';
    nInitSection:
      Result := 'init section';
    nClassType:
      Result := 'class type';
    nClassHeritage:
      Result := 'class heritage';
    nClassBody:
      Result := 'class body';
    nClassVisibility:
      Result := 'class visiblity';
    nClassDeclarations:
      Result := 'class declarations';
    nClassDirectives:
      Result := 'class directives';
    nClassDirectiveName:
      Result := 'class directive name';
    nProperty:
      Result := 'property';
    nPropertyParameterList:
      Result := 'property param list';
    nPropertySpecifier:
      Result := 'property specifier';
    nInterfaceType:
      Result := 'interface type';
    nInterfaceHeritage:
      Result := 'interface heritage';
    nInterfaceTypeGuid:
      Result := 'interface type guid';
    nInterfaceBody:
      Result := 'interface body';
    nBracketedQual:
      Result := 'bracketed qual';
    nAsm:
      Result := 'asm';
    nAsmStatement:
      Result := 'asm statement';
    nAsmIdent:
      Result := 'asm ident';
    nASMOpcode:
      Result := 'asm opcode';
    nAsmParam:
      Result := 'asm param';
    nAsmLabel:
      Result := 'asm label';
    nHintDirectives:
      Result := 'hint directives';
    nPropertyDirective:
      Result := 'property directive';
    nExports:
      Result := 'exports';
    nExportedProc:
      Result := 'exported proc';
    nCurlyBlock:
      Result := 'Curly Block';
    nBracketStarBlock:
      Result := 'BracketStar Block';
    nCommentList:
      Result := 'Comment List';
    nInlineComment:
      Result := 'Inline Comment';
    nEndOfLineComment:
      Result := 'EndOfLine Comment';
    nComment:
      Result := 'Comment';
    nTAGComment:
      Result := 'TAG Comment';
    nTAGAuthor:
      Result := 'TAG Author';
    nTAGChanges:
      Result := 'TAG Changes';
    nTAGDocs:
      Result := 'TAG Docs';
    nTAGDescription:
      Result := 'TAG Description';
    nTAGVersion:
      Result := 'TAG Version';
    nTAGParam:
      Result := 'TAG Param';
    nTAGReturn:
      Result := 'TAG Return';
    nTAGSee:
      Result := 'TAG See';
    nTAGToDo:
      Result := 'TAG Todo';
    nTAGThrows:
      Result := 'TAG Throws';
    nTAGAdditionalComment:
      Result := 'TAG AdditionalComment';
    nTAGUnknown:
      Result := 'TAG Unknown';
    nLiteralString:
      Result := 'literal string';
    nHashLiteralChar:
      Result := 'hash literal char';
    nHatLiteralChar:
      Result := 'hat literal char';
    nAttribute:
      Result := 'Attribute';
    else
      Result := 'Bad node type ' + IntToStr(Ord(pe));

  end;
end;


end.
