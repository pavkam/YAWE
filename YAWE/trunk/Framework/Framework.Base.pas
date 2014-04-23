{*------------------------------------------------------------------------------
  Basic Types and Definitions Used in YAWE
  This unit provides our own inherited class types and other
  simple types that should be used in the YAWE project.

  Note that only the types defined here should be used across
  YAWE and only a few cases rely on default Delphi data types.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team

  @Author PavkaM
  @Changes Seth
  @Docs PavkaM
-------------------------------------------------------------------------------}

{$I compiler.inc}
unit Framework.Base;

interface

{$REGION 'Uses Clause'}
uses
  SysUtils;
{$ENDREGION}

  // Forwarding the definitions for cyclic uses
  // Do not remove the following lines to avoid undefined identifier problems

{$REGION 'Fowarded Definitions'}
type

{$M+}
  TBaseObject = class;
{$M-}
  TBaseInterfacedObject = class;
  TBaseReferencedObject = class;

{$ENDREGION}

  // Basic data types used in the project. We try to maintain a strong defined
  // list of types to avoid type-lenght problems on other possible patforms
  // Also use these types in the YAWE. Do NOT rely on basic types except String!

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
  

{$ENDREGION}

  // Class types and Callback definitions used acroos framework and the whole
  // YAWE project!

{$REGION 'Class And Callback Definitions'}


{*------------------------------------------------------------------------------
Enumeration Callback Method.
This type defines a method callback which should be used in YAWE's internal
routines upon enumerating Object type values in a list. For each item in a
given list the following callback will be issued.
-------------------------------------------------------------------------------}
  YEnumerationCallback = procedure(Instance: TObject) of object;
  
{$M+}
{*------------------------------------------------------------------------------
Base YAWE Class
All YAWE non-interfaced objects inherit from this base class. This class
is mostly a wrapper around TObject and provides some extensions optimized
for multiple instantiating of this class.

@see TBaseInterfacedObject
@see TBaseReferencedObject
-------------------------------------------------------------------------------}
  TBaseObject = class(TObject)
    protected
      class procedure InitInstanceBlock(Block: Pointer; Count: Int32);
          
      class procedure InitInstanceBlockEx(Block: Pointer; Count: Int32;
        Callback: YEnumerationCallback);
  
      class procedure CleanupInstanceBlock(Block: Pointer; Count: Int32;
        InvokeDestructor: Boolean);
  
      class procedure CleanupInstanceBlockEx(Block: Pointer; Count: Int32;
        InvokeDestructor: Boolean; Callback: YEnumerationCallback);
    public
      procedure Cleanup;
  
      class procedure AllocateInstanceArray(var Buffer: Pointer; Count: Int32);
  
      class procedure AllocateInstanceArrayEx(var Buffer: Pointer; Count: Int32;
        Callback: YEnumerationCallback);
  
      class procedure FreeInstanceArray(var Buffer: Pointer; InvokeDestructor: Boolean);
  
      class procedure FreeInstanceArrayEx(var Buffer: Pointer; InvokeDestructor: Boolean;
        Callback: YEnumerationCallback);
  
      class procedure ClearInstanceArray(Buffer: Pointer; InvokeDestructor: Boolean);
  
      class procedure ClearInstanceArrayEx(Buffer: Pointer; InvokeDestructor: Boolean;
        Callback: YEnumerationCallback);

      class function ImplementsInterface(const IID: TGUID): Boolean;
  end;
{$M-}
  
{*------------------------------------------------------------------------------
Base YAWE Class (For Reference-Counted Objects)
All YAWE objects inherit from this base class. All classes which require
reference counting should use this class.
  
@see TBaseObject
@see TBaseInterfacedObject
-------------------------------------------------------------------------------}
  TBaseReferencedObject = class(TBaseObject, IInterface)
    private
      fReference: Int32;
    public
      function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
      function _AddRef: Int32; stdcall;
      function _Release: Int32; stdcall;
      property RefCount: Int32 read FReference;
  end;
  
{*------------------------------------------------------------------------------
Base YAWE Class (For Interfaced Objects)
All YAWE interfaced objects inherit from this base class. Note that
this class DOESN'T provide reference counting and should only be used
for using interfaces as an abstract code divisation layer!
  
@see TBaseObject
@see TBaseReferencedObject
-------------------------------------------------------------------------------}
  TBaseInterfacedObject = class(TBaseObject, IInterface)
    public
      function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
      function _AddRef: Int32; stdcall;
      function _Release: Int32; stdcall;
  end;

// TODO... repair
  THandleBaseClass = class of THandleBase;
  
{*------------------------------------------------------------------------------
YAWE Handle Class
This class is mostly a stub and should be inherited in modules requiring
handle support. All extended Handle classes should define their own extension
methods which should perform certain operations but instead
marshal the requests to the Manager which relies on those.
  
A Handle would also store some specific private data which would provide
meaningful information for the manager class which uses them.
  
@see YEventHandle
@see YThreadHandle
@see YLogHandle
-------------------------------------------------------------------------------}
  THandleBase = class(TBaseReferencedObject)
    public
      constructor Create; virtual;
  end;
  
{*------------------------------------------------------------------------------
Base Framework Exception Class
All YAWE exceptions should inherit this class for meaningful error
handling routines. This class should also be used only inside Framework.
  
For all other modules - there are other alternatives.
  
@see ECodeException
@see EYaweExceptionClass
-------------------------------------------------------------------------------}
  EFrameworkException = class(Exception);
  
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

{$ENDREGION}

  // Exception Derivatives. Please group them here. If an exception is to be used only inside a module
  // define it there. The exceptions defined here are for global use only.

{$REGION 'Exception Definitions'}
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

{$ENDREGION}

  // Constants that should be used in tandem with previously defined Exceptions
  // Please define them all here in order to avoid further confusion.

{$REGION 'EMediumOperationFailed Exception Types'}

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

{$ENDREGION}

  // Constants used by RTTIEx for registration of the RTTI extended infromation.
  // Should be useful in other modules too.

{$REGION 'Type Name Constants'}

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

{$ENDREGION}

  // Include the revision file to keep the track of the global versioning.
  // This file is generated by the SVNBuild tool automatically on each compile

{$I Framework.Revision.rev}

implementation

{$REGION 'Uses Clause'}
uses
  Misc.Threads;
{$ENDREGION}

{$REGION 'Internal Type Defintions'}

type
{*------------------------------------------------------------------------------
Pointer to an Instance Block Header
Type defines a pointer to the block header record. This pointer is used
to retreive block header info.

@see YObject
-------------------------------------------------------------------------------}
  PObjectBlockHeader = ^YObjectBlockHeader;

{*------------------------------------------------------------------------------
Instance Block Header
Used in YObject for allocation of multiple instances of the object. Contains the
number of objects in the instance block array.

@see YObject
-------------------------------------------------------------------------------}
  YObjectBlockHeader = record
    NumOfObjects: Integer;
  end;

{$ENDREGION}

{$REGION 'TBaseObject Implementation'}

{*------------------------------------------------------------------------------
Cleanup TBaseObject Instance
It's basically a destructor but should be used in block instantiation cases. In
all other cases use Free or Destroy.
-------------------------------------------------------------------------------}
procedure TBaseObject.Cleanup;
asm
  MOV   ECX, [EAX]
  XOR   DL, DL
  JMP   [ECX] + VMTOFFSET TObject.Destroy
end;

// TODO... repair
class function TBaseObject.ImplementsInterface(const IID: TGUID): Boolean;
begin
  Result := GetInterfaceEntry(IID) <> nil;
end;

{*------------------------------------------------------------------------------
Creates More Instances For a Given Class
This internal method creates a number of instances for the specified class
type.

Note that this function creates a number of instances in an already allocated
buffer!

@param Block A Pointer to a memory location where to store newly created instances.
@param Count The count of object instances to create.
-------------------------------------------------------------------------------}
class procedure TBaseObject.InitInstanceBlock(Block: Pointer; Count: Int32);
var
  Size: Integer;
  I: Integer;
begin
  /// Retreive the instance size of this class. InstanceSize - defined in TObject
  Size := InstanceSize;

  /// Loop "Count" number of times
  for I := 0 to Count - 1 do
  begin
    /// Instantiate an instance into a given memory block. InitInstance - defined in TObject
    InitInstance(Block);

    /// Increase the pointer with the size of instance
    Inc(PByte(Block), Size);
  end;
end;


{*------------------------------------------------------------------------------
Creates More Instances For a Given Class (Extended)
This internal method creates a number of instances for the specified class
type. For each new Instance created it calls a given Callback method.

Note that this function creates a number of instances in an already allocated
buffer!

@param Block A Pointer to a memory location where to store newly created instances.
@param Count The count of object instances to create.
@param Callback The callback method to be called for each inatance created.
-------------------------------------------------------------------------------}
class procedure TBaseObject.InitInstanceBlockEx(Block: Pointer; Count: Int32; Callback: YEnumerationCallback);
var
  Size: Integer;
  I: Integer;
begin
  /// Retreive the instance size of this class. InstanceSize - defined in TObject
  Size := InstanceSize;

  /// Loop "Count" number of times
  for I := 0 to Count -1 do
  begin
    /// Instantiate an instance into a given memory block. InitInstance - defined in TObject
    InitInstance(Block);

    /// Call athe callback method with the given parameter
    Callback(Block);

    /// Increase the pointer with the size of instance
    Inc(PByte(Block), Size);
  end;
end;


{*------------------------------------------------------------------------------
Cleans Up a Given Block of Objects.
This static method acts like a mass destructor on a given Block of
instances of the same class.

@param Block A Pointer to a memory location where are stored created instances.
@param Count The count of object instances in the block.
@param InvokeDestructor Specifies whether to call the destructor for each created instance.
-------------------------------------------------------------------------------}
class procedure TBaseObject.CleanupInstanceBlock(Block: Pointer; Count: Int32; InvokeDestructor: Boolean);
var
  Size: Integer;
  I: Integer;
begin
  /// Retreive the instance size of this class. InstanceSize - defined in TObject
  Size := InstanceSize;

  /// Loop "Count" number of times
  for I := 0 to Count -1 do
  begin
    try
      /// Cleanup the instance memory - defined in TObject
      TBaseObject(Block).CleanupInstance;

      /// In case of InvokeDestructor = true, call the destructor for this object
      if InvokeDestructor then
         TBaseObject(Block).Cleanup;

      /// Increase the pointer with the size of instance
      Inc(PByte(Block), Size);
    except
      Writeln(I);
    end;
  end;
end;


{*------------------------------------------------------------------------------
Cleans Up a Given Block of Objects (Extended).
This static method acts like a mass destructor on a given Block of
instances of the same class. For each object destroyed it call a given
callback method. The callback is called before destroying!

@param Block A Pointer to a memory location where are stored created instances.
@param Count The count of object instances in the block.
@param InvokeDestructor Specifies whether to call the destructor for each created instance.
@param Callback The method to call upon destruction of an object instance.
-------------------------------------------------------------------------------}
class procedure TBaseObject.CleanupInstanceBlockEx(Block: Pointer; Count: Int32; InvokeDestructor: Boolean; Callback: YEnumerationCallback);
var
  Size: Integer;
  I: Integer;
begin
  /// Retreive the instance size of this class. InstanceSize - defined in TObject
  Size := InstanceSize;

  /// Loop "Count" number of times
  for I := 0 to Count -1 do
  begin
    /// Call the method with reported object.
    Callback(Block);

    /// Cleanup the instance memory - defined in TObject
    TBaseObject(Block).CleanupInstance;

    /// In case of InvokeDestructor = true, call the destructor for this object
    if InvokeDestructor then
       TBaseObject(Block).Cleanup;

    /// Increase the pointer with the size of instance
    Inc(PByte(Block), Size);
  end;
end;

{*------------------------------------------------------------------------------
Creates an Array of Instances For a Given Class
This static method acts like a mass allocator. It will create a number
of object instances into the given buffer.

This memthod will allocate the memory to the Buffer in the following manner:
[BlockHeader (A Int32 with the count of instances in the Buffer)]
...
<Instance 0>
...
<Instance N>

@param Buffer A Pointer to a memory location where to store created instances.
@param Count The count of object instances in the buffer.
-------------------------------------------------------------------------------}
class procedure TBaseObject.AllocateInstanceArray(var Buffer: Pointer; Count: Int32);
var
  Size: Integer;
begin
  /// Retreive the instance size of this class. InstanceSize - defined in TObject
  Size := InstanceSize;

  /// Allocate the required amount of memory for the allocation process.
  /// This includes a Block header and then the memory for instances
  GetMem(Buffer, (Size * Count) + SizeOf(YObjectBlockHeader));

  /// Insert the number of Intences into the block header
  PObjectBlockHeader(Buffer)^.NumOfObjects := Count;

  /// Move the Pointer + Block Header and pass the
  /// pointer to the allocation method
  Inc(PByte(Buffer), SizeOf(YObjectBlockHeader));
  InitInstanceBlock(Buffer, Count);
end;

{*------------------------------------------------------------------------------
Creates an Array of Instances For a Given Class (Extended)
This static method acts like a mass allocator. It will create a number
of object instances into the given buffer. For each new Instance created
a given callback will be called.

This memthod will allocate the memory to the Buffer in the following manner:
[BlockHeader (A Int32 with the count of instances in the Buffer)]
...
<Instance 0>
...
<Instance N>

@param Buffer A Pointer to a memory location where to store created instances.
@param Count The count of object instances in the buffer.
@param Callback The method to call with each object instance created.
-------------------------------------------------------------------------------}
class procedure TBaseObject.AllocateInstanceArrayEx(var Buffer: Pointer; Count: Int32; Callback: YEnumerationCallback);
var
  Size: Integer;
begin
  if @Callback = nil then
  begin
    /// If no callback was specied, call the simple Alloation Method
    AllocateInstanceArray(Buffer, Count);
  end else
  begin
    /// Retreive the instance size of this class. InstanceSize - defined in TObject
    Size := InstanceSize;

    /// Allocate the required amount of memory for the allocation process.
    /// This includes a Block header and then the memory for instances
    GetMem(Buffer, (Size * Count) + SizeOf(YObjectBlockHeader));

    /// Insert the number of Intences into the block header
    PObjectBlockHeader(Buffer)^.NumOfObjects := Count;

    /// Move the Pointer + Block Header and pass the
    /// pointer to the allocation method
    Inc(PByte(Buffer), SizeOf(YObjectBlockHeader));
    InitInstanceBlockEx(Buffer, Count, Callback);
  end;
end;


{*------------------------------------------------------------------------------
Destroys an Array of Object Instances
This static method will invoke some internal methods for TBaseObject and
destroy all instances in the given Buffer, deallocate the memory.
Optionally it can call each instance's destructor.

@param Buffer A Pointer to a memory location where to store created instances.
@param InvokeDestructor Specifies if destructors will be called for each instance.
-------------------------------------------------------------------------------}
class procedure TBaseObject.FreeInstanceArray(var Buffer: Pointer; InvokeDestructor: Boolean);
var
  Local: PObjectBlockHeader;
begin
  /// Extract the Header from the Buffer. Header contains the number of instances
  /// contained in this buffer.
  Local := Pointer(Longword(Buffer) - SizeOf(YObjectBlockHeader));

  /// Invoke private CleanupInstanceBlock to actually destroy the instances
  CleanupInstanceBlock(Buffer, Local^.NumOfObjects, InvokeDestructor);

  /// Free the given memory and set it's pointer to nil.
  FreeMem(Local);
  Buffer := nil;
end;

{*------------------------------------------------------------------------------
Destroys an Array of Object Instances (Extended)
This static method will invoke some internal methods for TBaseObject and
destroy all instances in the given Buffer, deallocate the memory.
Optionally it can call each instance's destructor.
For each instance destroyed a callback method will be called.

@param Buffer A Pointer to a memory location where to store created instances.
@param InvokeDestructor Specifies if destructors will be called for each instance.
@param Callback The method to call with each object instance destroyed.
-------------------------------------------------------------------------------}
class procedure TBaseObject.FreeInstanceArrayEx(var Buffer: Pointer; InvokeDestructor: Boolean; Callback: YEnumerationCallback);
var
  Local: PObjectBlockHeader;
begin
  /// If callback was nil call the simple FreeInstanceArray method
  if @Callback = nil then
  begin
    FreeInstanceArray(Buffer, InvokeDestructor);
  end else
  begin
    /// Extract the Header from the Buffer. Header contains the number of instances
    /// contained in this buffer.
    Local := Pointer(Longword(Buffer) - SizeOf(YObjectBlockHeader));

    /// Invoke private CleanupInstanceBlockEx to actually destroy the instances
    CleanupInstanceBlockEx(Buffer, Local^.NumOfObjects, InvokeDestructor, Callback);

    /// Free the given memory and set it's pointer to nil.
    FreeMem(Local);
    Buffer := nil;
  end;
end;

{*------------------------------------------------------------------------------
Clears an Array of Object Instances
This static method will invoke some internal methods for TBaseObject and
destroy all instances in the given Buffer. Note that this method
will NOT deallocate the buffer.
Optionally it can call each instance's destructor.

@param Buffer A Pointer to a memory location where to store created instances.
@param InvokeDestructor Specifies if destructors will be called for each instance.
-------------------------------------------------------------------------------}
class procedure TBaseObject.ClearInstanceArray(Buffer: Pointer; InvokeDestructor: Boolean);
var
  Local: PObjectBlockHeader;
begin
  /// Find out the Block header
  Local := Pointer(Integer(Buffer) - SizeOf(YObjectBlockHeader));

  /// Cleanup the instances located in this buffer using CleanupInstanceBlock
  CleanupInstanceBlock(Buffer, Local^.NumOfObjects, InvokeDestructor);
end;

{*------------------------------------------------------------------------------
Clears an Array of Object Instances (Extended)
This static method will invoke some internal methods for TBaseObject and
destroy all instances in the given Buffer. Note that this method
will NOT deallocate the buffer. For each Instance destroyed it will
call the given Callback.
Optionally it can call each instance's destructor.

@param Buffer A Pointer to a memory location where to store created instances.
@param InvokeDestructor Specifies if destructors will be called for each instance.
-------------------------------------------------------------------------------}
class procedure TBaseObject.ClearInstanceArrayEx(Buffer: Pointer; InvokeDestructor: Boolean; Callback: YEnumerationCallback);
var
  Local: PObjectBlockHeader;
begin
  /// If the callback was nil, call the simple method ClearInstanceArray
  if @Callback = nil then
  begin
    ClearInstanceArray(Buffer, InvokeDestructor);
  end else
  begin
    /// Find out the Block header
    Local := Pointer(Integer(Buffer) - SizeOf(YObjectBlockHeader));

    /// Cleanup the instances located in this buffer using CleanupInstanceBlockEx
    CleanupInstanceBlockEx(Buffer, Local^.NumOfObjects, InvokeDestructor, Callback);
  end;
end;

{$ENDREGION}


{$REGION 'TBaseReferencedObject Implementation'}

{*------------------------------------------------------------------------------
Query Object For a Given Interface.
Method implements IUnknown interface's QueryInterface method wich checks if
the object implements a given interface.

@param IID Interface GUID to probe for.
@param Obj Output information required for probing.
@return Probe result
-------------------------------------------------------------------------------}
function TBaseReferencedObject.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  /// Use TObject's GetInterface method for probing
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;


{*------------------------------------------------------------------------------
Increase Reference Count

This method gets called automatically by Delphi internals when an object is
created (using interfaces)

@return The new reference count
-------------------------------------------------------------------------------}
function TBaseReferencedObject._AddRef: Int32;
begin
  /// Use Atomic operations to perform increase operations.
  Result := AtomicInc(@fReference);
end;


{*------------------------------------------------------------------------------
Decrease Reference Count

This method gets called automatically by Delphi internals when an object reference
count is decreased.

@return The new reference count
-------------------------------------------------------------------------------}
function TBaseReferencedObject._Release: Int32;
begin
  /// Use Atomic operations to perform decrease operations.
  Result := AtomicDec(@fReference);

  /// If reference count reaches zero, invoke destructor!
  if Result = 0 then Destroy;
end;

{$ENDREGION}


{$REGION 'TBaseInterfacedObject Implementation'}

{*------------------------------------------------------------------------------
Increase Reference Count

This method gets called automatically by Delphi internals when an object is
created (using interfaces).

Note that TBaseInterfacedObject doesn't support Reference Counting!

@return The new reference count
-------------------------------------------------------------------------------}
function TBaseInterfacedObject._AddRef: Int32;
begin
  Result := -1; { No reference counting - be careful }
end;


{*------------------------------------------------------------------------------
Decrease Reference Count

This method gets called automatically by Delphi internals when an object reference
count is decreased.

Note that YInterfacedObject doesn't support Reference Counting!

@return The new reference count
-------------------------------------------------------------------------------}
function TBaseInterfacedObject._Release: Int32;
begin
  Result := -1; { No reference counting - be careful }
end;


{*------------------------------------------------------------------------------
Query Object For a Given Interface.
Method implements IUnknown interface's QueryInterface method wich checks if
the object implements a given interface.

@param IID Interface GUID to probe for.
@param Obj Output information required for probing.
@return Probe result
-------------------------------------------------------------------------------}
function TBaseInterfacedObject.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

{$ENDREGION}


{$REGION 'ECodeException Implementation'}

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

{$ENDREGION}


{$REGION 'THandleBase Implementation'}

{*------------------------------------------------------------------------------
Constructs THandleBase

This is a virtual Constructor.
-------------------------------------------------------------------------------}
constructor THandleBase.Create;
begin
  { nothing }
end;

{$ENDREGION}

end.
