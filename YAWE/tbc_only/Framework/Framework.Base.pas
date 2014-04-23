{*------------------------------------------------------------------------------
  Basic Types and Definitions Used in YAWE
  This unit provides our own inherited class types and other
  simple types that should be used in the YAWE project.

  Note that only the types defined here should be used across
  YAWE and only a few cases rely on default Delphi data types.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team

  @Author PavkaM
  @Changes Seth
  @Docs PavkaM
-------------------------------------------------------------------------------}

{$I compiler.inc}
unit Framework.Base;

interface

uses
  SysUtils;

  // Forwarding the definitions for cyclic uses
  // Do not remove the following lines to avoid undefined identifier problems

type
  // Basic data types used in the project. We try to maintain a strong defined
  // list of types to avoid type-lenght problems on other possible platforms
  // Also use these types in YAWE when it comes to client-server communication.
  // Do NOT rely on basic types except AnsiString!

{$REGION 'Basic Data Types'}


{*------------------------------------------------------------------------------
Signed 32 Bit Integer
Provides a stable 32 bit signed integer type for usage
across the project.
  
@see UInt32
-------------------------------------------------------------------------------}
  Int32   = Integer;
  
{*------------------------------------------------------------------------------
Signed 16 Bit Integer
Provides a stable 16 bit signed integer type for usage
across the project.
  
@see UInt16
-------------------------------------------------------------------------------}
  Int16   = SmallInt;
  
{*------------------------------------------------------------------------------
Signed 8 Bit Integer
Provides a stable 8 bit signed integer type for usage
across the project.
  
@see UInt8
-------------------------------------------------------------------------------}
  Int8    = ShortInt;
  
{*------------------------------------------------------------------------------
Pointer to a Signed 32 Bit Integer
Provides a pointer to stable 32 bit signed integer type for usage
across the project.
  
@see PUInt32
-------------------------------------------------------------------------------}
  PInt32  = PInteger;
  
{*------------------------------------------------------------------------------
Pointer to a Signed 16 Bit Integer
Provides a pointer to stable 16 bit signed integer type for usage
across the project.
  
@see PUInt16
-------------------------------------------------------------------------------}
  PInt16  = PSmallInt;
  
{*------------------------------------------------------------------------------
Pointer to a Signed 8 Bit Integer
Provides a pointer to stable 8 bit signed integer type for usage
across the project.
  
@see PUInt8
-------------------------------------------------------------------------------}
  PInt8   = PShortInt;
  
{*------------------------------------------------------------------------------
Unsigned 64 Bit Integer
Provides a stable 64 bit unsigned integer type for usage
across the project.
  
Note that this type is mostly a Hack! Delphi doesn't provide an unsigned
Int64 type so we will be using a signed Int64 instead ... until an update comes
to the RTL
-------------------------------------------------------------------------------}
  UInt64  = Int64;
  
{*------------------------------------------------------------------------------
Unsigned 32 Bit Integer
Provides a stable 32 bit unsigned integer type for usage
across the project.
  
@see Int32
-------------------------------------------------------------------------------}
  UInt32  = Longword;
  
{*------------------------------------------------------------------------------
Unsigned 16 Bit Integer
Provides a stable 16 bit unsigned integer type for usage
across the project.
  
@see Int16
-------------------------------------------------------------------------------}
  UInt16  = Word;
  
{*------------------------------------------------------------------------------
Unsigned 8 Bit Integer
Provides a stable 8 bit unsigned integer type for usage
across the project.
  
@see Int8
-------------------------------------------------------------------------------}
  UInt8   = Byte;
  
{*------------------------------------------------------------------------------
Pointer to a Unsigned 64 Bit Integer
Provides a pointer to stable 64 bit unsigned integer type for usage
across the project.
-------------------------------------------------------------------------------}
  PUInt64 = PInt64;
  
{*------------------------------------------------------------------------------
Pointer to a Unsigned 32 Bit Integer
Provides a pointer to stable 32 bit unsigned integer type for usage
across the project.
  
@see PInt32
-------------------------------------------------------------------------------}
  PUInt32 = PLongword;
  
{*------------------------------------------------------------------------------
Pointer to a Unsigned 16 Bit Integer
Provides a pointer to stable 16 bit unsigned integer type for usage
across the project.
  
@see PInt16
-------------------------------------------------------------------------------}
  PUInt16 = PWord;
  
{*------------------------------------------------------------------------------
Pointer to a Unsigned 8 Bit Integer
Provides a pointer to stable 8 bit unsigned integer type for usage
across the project.
  
@see PInt8
-------------------------------------------------------------------------------}
  PUInt8  = PByte;
  
{*------------------------------------------------------------------------------
A Single Precision Float Number
This type is important to be used as the underlying system depends on the actual
bit-width of the float values in use. In case the system will require a wider
type we will simple adapt our Float type.
  
  
@see PFloat
-------------------------------------------------------------------------------}
  Float   = Single;
  
{*------------------------------------------------------------------------------
A "C"-type String
In order to use Win32 routines we require a "C"-type String type. The
solution was to create a type out of PChar.
-------------------------------------------------------------------------------}
  CString = PChar;
  
{*------------------------------------------------------------------------------
Pointer to a Single Precision Float Number
Represents a pointer to the Float type used across the system.
  
@see Float
-------------------------------------------------------------------------------}
  PFloat  = PSingle;

{*------------------------------------------------------------------------------
Base Framework Exception Class
All YAWE exceptions should inherit this class for meaningful error
handling routines. This class should also be used only inside Framework.

For all other modules - there are other alternatives.

@see ECodeException
@see EYaweExceptionClass
-------------------------------------------------------------------------------}
  EFrameworkException = class(Exception);
  ENotImplemented = class(EFrameworkException);
  EUnsupported = class(ENotImplemented);
  
{*------------------------------------------------------------------------------
Code-identified Exception Class
All exceptions relying on a "error code" constant should inherit this class.
It is useful to report an error code in a generalized exception than to have
N exceptions derived from he base class which would identify each code.

It also provides meningful ways for the Console class to debug information.

@see EFrameworkException
@see EYaweExceptionClass
-------------------------------------------------------------------------------}
  ECodeException = class(EFrameworkException)
    protected
      fError: Int32;
    public
      constructor Create(const Msg: String; Error: Int32);
      property Error: Int32 read fError;
  end;
  
{*------------------------------------------------------------------------------
Basic YAWE Exception Class
  
A generic exception that all YAWE sub-systems and module should inherit.
Note that Framework exceptions should not be using this base class.
  
@see EFrameworkException
@see ECodeException
-------------------------------------------------------------------------------}
  EYaweExceptionClass = class of EFrameworkException;

  // Exception Derivatives. Please group them here. If an exception is to be used only inside a module
  // define it there. The exceptions defined here are for global use only.

type

{*------------------------------------------------------------------------------
Socket Error Exception
Identifies a socket operation exception. Should be used in all socket
related errors.

@see EFrameworkException
-------------------------------------------------------------------------------}
  ESocketError = class(EFrameworkException);

{*------------------------------------------------------------------------------
Bad Version Exception
Should issued by all components which rely on some version of a some
component and the actual version doesn't meet the criteria.

@see EFrameworkException
-------------------------------------------------------------------------------}
  EBadVersion = class(EFrameworkException);

{*------------------------------------------------------------------------------
API Not Found Error Exception
Should be issued by components that rely on some given API that is
missing from the currently used OS.

@see EFrameworkException
-------------------------------------------------------------------------------}
  EApiNotFound = class(EFrameworkException);

{*------------------------------------------------------------------------------
API Call Failed Error Exception
Should be issued by any component which performed a API call which failed
or returned invalid results.

@see EFrameworkException
-------------------------------------------------------------------------------}
  EApiCallFailed = class(EFrameworkException);

{*------------------------------------------------------------------------------
File Load Error Exception
Any component which performs file loading that failed should throw this
expection.

@see EFrameworkException
-------------------------------------------------------------------------------}
  EFileLoadError = class(EFrameworkException);

{*------------------------------------------------------------------------------
File Save Error Exception
Any component which performs file saving that failed should throw this
expection.

@see EFrameworkException
-------------------------------------------------------------------------------}
  EFileSaveError = class(EFrameworkException);

{*------------------------------------------------------------------------------
Database Error Exception
Exception appears when the database components failed to perform an operation

@see EFrameworkException
@see Components.DataCore
-------------------------------------------------------------------------------}
  EDatabaseException = class(EFrameworkException);

{*------------------------------------------------------------------------------
Core Operation Failed Exception
Any Core that fails to perform an operation should issue this exception.

@see EFrameworkException
@see Components
-------------------------------------------------------------------------------}
  ECoreOperationFailed = class(EFrameworkException);

{*------------------------------------------------------------------------------
Medium Operation Failed Exception
All medium operations that fail should throw this exception in order to identify
the source of the possible bug or problem.

@see EFrameworkException
@see Components.DataCore.Storage
-------------------------------------------------------------------------------}
  EMediumOperationFailed = class(ECodeException);

  // Constants that should be used in tandem with previously defined Exceptions
  // Please define them all here in order to avoid further confusion.

const
{*------------------------------------------------------------------------------
Medium Operation Failed: Operation Error
Raised by Medium classes when an invalid data/format has been detected upon
processing a medium storage file/location.

@see EMediumOperationFailed
-------------------------------------------------------------------------------}
  MOF_OPT_ERR = 1;

{*------------------------------------------------------------------------------
Medium Operation Failed: Load Error
Raised by Medium classes when an error was caught upon loading te data from the
medium storage.

@see EMediumOperationFailed
-------------------------------------------------------------------------------}
  MOF_LOAD = 2;

{*------------------------------------------------------------------------------
Medium Operation Failed: Save Error
Raised by Medium classes when an error was caught upon saving the data to the
medium storage.

@see EMediumOperationFailed
-------------------------------------------------------------------------------}
  MOF_SAVE = 3;

{*------------------------------------------------------------------------------
Medium Operation Failed: Invalid Medium
Raised by Medium classes when it detects an invalid medium storage as input.

@see EMediumOperationFailed
-------------------------------------------------------------------------------}
  MOF_INV_MED = 4;

  // Constants used by RTTIEx for registration of the RTTI extended infromation.
  // Should be useful in other modules too.

const
{*------------------------------------------------------------------------------
Type Name: Char
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SChar: string             = 'Char';

{*------------------------------------------------------------------------------
Type Name: AnsiChar
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SAnsiChar: string         = 'AnsiChar';

{*------------------------------------------------------------------------------
Type Name: WideChar
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SWideChar: string         = 'WideChar';

{*------------------------------------------------------------------------------
Type Name: Boolean
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SBoolean: string          = 'Boolean';

{*------------------------------------------------------------------------------
Type Name: Int64
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SInt64: string            = 'Int64';

{*------------------------------------------------------------------------------
Type Name: UInt64
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SUInt64: string           = 'UInt64';

{*------------------------------------------------------------------------------
Type Name: QuadWord
A String which identifies a type name which should be used across YAWE
for RTTI support.

Note: It's an alias to Int64.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SQuadword: string         = 'Quadword';

{*------------------------------------------------------------------------------
Type Name: Int32
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SInt32: string            = 'Int32';

{*------------------------------------------------------------------------------
Type Name: UInt32
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SUInt32: string           = 'UInt32';

{*------------------------------------------------------------------------------
Type Name: Integer
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SInteger: string          = 'Integer';

{*------------------------------------------------------------------------------
Type Name: Cardinal
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SCardinal: string         = 'Cardinal';

{*------------------------------------------------------------------------------
Type Name: LongWord
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SLongword: string         = 'Longword';

{*------------------------------------------------------------------------------
Type Name: Int16
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SInt16: string            = 'Int16';

{*------------------------------------------------------------------------------
Type Name: UInt16
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SUInt16: string           = 'UInt16';

{*------------------------------------------------------------------------------
Type Name: SmallInt
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SSmallInt: string         = 'SmallInt';

{*------------------------------------------------------------------------------
Type Name: Word
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SWord: string             = 'Word';

{*------------------------------------------------------------------------------
Type Name: Int8
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SInt8: string             = 'Int8';

{*------------------------------------------------------------------------------
Type Name: UInt8
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SUInt8: string            = 'UInt8';

{*------------------------------------------------------------------------------
Type Name: ShortInt
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SShortInt: string         = 'ShortInt';

{*------------------------------------------------------------------------------
Type Name: Byte
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SByte: string             = 'Byte';

{*------------------------------------------------------------------------------
Type Name: String
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SString: string           = 'String';

{*------------------------------------------------------------------------------
Type Name: AnsiString
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SAnsiString: string       = 'AnsiString';

{*------------------------------------------------------------------------------
Type Name: WideString
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SWideString: string       = 'WideString';

{*------------------------------------------------------------------------------
Type Name: ShortString
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SShortString: string      = 'ShortString';

{*------------------------------------------------------------------------------
Type Name: Single
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SSingle: string           = 'Single';

{*------------------------------------------------------------------------------
Type Name: Double
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SDouble: string           = 'Double';

{*------------------------------------------------------------------------------
Type Name: Extended
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SExtended: string         = 'Extended';

{*------------------------------------------------------------------------------
Type Name: Currency
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SCurrency: string         = 'Currency';

{*------------------------------------------------------------------------------
Type Name: Comp
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SComp: string             = 'Comp';

{*------------------------------------------------------------------------------
Type Name: Float
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SFloat: string            = 'Float';

{*------------------------------------------------------------------------------
Type Name: PChar
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPChar: string            = 'PChar';

{*------------------------------------------------------------------------------
Type Name: PAnsiChar
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPAnsiChar: string        = 'PAnsiChar';

{*------------------------------------------------------------------------------
Type Name: PWideChar
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPWideChar: string        = 'PWideChar';

{*------------------------------------------------------------------------------
Type Name: CString
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SCString: string          = 'CString';

{*------------------------------------------------------------------------------
Type Name: PInt64
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPInt64: string           = 'PInt64';

{*------------------------------------------------------------------------------
Type Name: PUint64
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPUInt64: string          = 'PUInt64';

{*------------------------------------------------------------------------------
Type Name: PInt32
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPInt32: string           = 'PInt32';

{*------------------------------------------------------------------------------
Type Name: PUInt32
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPUInt32: string          = 'PUInt32';

{*------------------------------------------------------------------------------
Type Name: PInteger
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPInteger: string         = 'PInteger';

{*------------------------------------------------------------------------------
Type Name: PCardinal
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPCardinal: string        = 'PCardinal';

{*------------------------------------------------------------------------------
Type Name: PLongWord
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPLongword: string        = 'PLongword';

{*------------------------------------------------------------------------------
Type Name: PInt16
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPInt16: string           = 'PInt16';

{*------------------------------------------------------------------------------
Type Name: PUin16
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPUInt16: string          = 'PUInt16';

{*------------------------------------------------------------------------------
Type Name: PSmallInt
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPSmallInt: string        = 'PSmallInt';

{*------------------------------------------------------------------------------
Type Name: PWord
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPWord: string            = 'PWord';

{*------------------------------------------------------------------------------
Type Name: PInt8
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPInt8: string            = 'PInt8';

{*------------------------------------------------------------------------------
Type Name: PUInt8
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPUInt8: string           = 'PUInt8';

{*------------------------------------------------------------------------------
Type Name: PShortInt
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPShortInt: string        = 'PShortInt';

{*------------------------------------------------------------------------------
Type Name: PByte
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPByte: string            = 'PByte';

{*------------------------------------------------------------------------------
Type Name: PString
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPString: string          = 'PString';

{*------------------------------------------------------------------------------
Type Name: PAnsiString
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPAnsiString: string      = 'PAnsiString';

{*------------------------------------------------------------------------------
Type Name: PWideString
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPWideString: string      = 'PWideString';

{*------------------------------------------------------------------------------
Type Name: PShortString
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPShortString: string     = 'PShortString';

{*------------------------------------------------------------------------------
Type Name: PSingle
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPSingle: string          = 'PSingle';

{*------------------------------------------------------------------------------
Type Name: PDouble
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPDouble: string          = 'PDouble';

{*------------------------------------------------------------------------------
Type Name: PExtended
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPExtended: string        = 'PExtended';

{*------------------------------------------------------------------------------
Type Name: PCurrency
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPCurrency: string        = 'PCurrency';

{*------------------------------------------------------------------------------
Type Name: PComp
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPComp: string            = 'PComp';

{*------------------------------------------------------------------------------
Type Name: PFloat
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  SPFloat: string           = 'PFloat';

{*------------------------------------------------------------------------------
Type Name: TByteArray
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  STByteArr: string         = 'TByteArray';

{*------------------------------------------------------------------------------
Type Name: TWordArray
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  STWordArr: string         = 'TWordArray';

{*------------------------------------------------------------------------------
Type Name: TLongWordArray
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  STLongwordArr: string     = 'TLongwordArray';

{*------------------------------------------------------------------------------
Type Name: TInt64Array
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  STInt64Arr: string        = 'TInt64Array';

{*------------------------------------------------------------------------------
Type Name: TStringArray
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  STStringArr: string       = 'TStringArray';

{*------------------------------------------------------------------------------
Type Name: TSingleArray
A String which identifies a type name which should be used across YAWE
for RTTI support.

@see Framework.TypeRegistry
-------------------------------------------------------------------------------}
  STSingleArr: string       = 'TSingleArray';

  // Include the revision file to keep the track of the global versioning.
  // This file is generated by the SVNBuild tool automatically on each compile

{$I Framework.Revision.rev}

implementation


{*------------------------------------------------------------------------------
Constructs ECodeException

This constructor creates a new ECodeException instance with a given
id code parameter.

@param Msg The String message describing the exception
@param Error An Error code.
-------------------------------------------------------------------------------}
constructor ECodeException.Create(const Msg: String; Error: Int32);
begin
  inherited Create(Msg);
  fError := Error;
end;

end.
