{$I compiler.inc}
unit Bfg.Containers.HashMapsEx;

interface

uses
  SysUtils,
  Bfg.Utils,
  Classes;

type
  TKeyType = type Integer;
  TValueType = type TObject;

  PKeyTypeValueTypePair = ^TKeyTypeValueTypePair;
  TKeyTypeValueTypePair = record
    Key: TKeyType;
    Value: TValueType;
  end;

  TKeyTypeValueTypeHashMap = class(TObject)
    private
      const
        ENTRY_BATCH_ARR_SIZE_EXPONENT = 4;
        ENTRIES_PER_BATCH = 1 shl ENTRY_BATCH_ARR_SIZE_EXPONENT;

      type
        PHashEntry = ^THashEntry;
        THashEntry = packed record
          HKey: TKeyType;
          HValue: TValueType;
        end;

        PHashEntryBatch = ^THashEntryBatch;
        THashEntryBatch = packed record
          Count: Byte;
          Pad: array[0..2] of Byte;
          Entries: array[0..ENTRIES_PER_BATCH-1] of THashEntry; { 16 entries per batch }
        end;

        THashEntryBatchDynArray = array of THashEntryBatch;

      var
        FEntryBatches: THashEntryBatchDynArray;
        FEntryBatchesOccupied: TByteDynArray; { Bit array, for quick bit lookups }
        FBuckets: array of Integer;

        FEntryBatchCapacity: Integer;
        FEntryBatchCount: Integer;
        FEntryCount: Integer;
        FEntryCountMax: Integer;
        FBucketCapacity: Integer;
        FMask: Longword;

        FEntryBatchOccupiedLow: Integer;
        FEntryBatchOccupiedHigh: Integer;

        FRehashLoadFactor: Single;
        FOwnsItems: Boolean;
    protected
      procedure Rehash(OldCapacity: Integer;
        const OldBatchesOccupied: TByteDynArray); virtual;
        
      procedure FreeItem(var Item); virtual;

      procedure SetEntryBatchCapacity(NewCapacity: Integer);
      procedure SetCapacity(NewCapacity: Integer);
      procedure SetRehashLoadFactor(const NewRehashLoadFactor: Single);

      function IsEntryBatchOccupied(Index: Integer): Boolean; inline;

      function LookupConsecutiveEmptyEntryBatches(Count: Integer; out Index: Integer): PHashEntryBatch;

      procedure InsertPairComplex(var Bucket: Integer; const Key: Integer;
        const Value: TValueType);

      procedure InsertPair(var Bucket: Integer; const Key: TKeyType;
        const Value: TValueType);

      procedure InsertPairAsm(var Bucket: Integer; const Pair: THashEntry);
    public
      constructor Create(Capacity: Integer; OwnsItems: Boolean;
        const RehashLoadFactor: Single = 0.85);

      destructor Destroy; override;

      function GetMemoryUsageInBytes: Longword;

      function Remove(const Key: TKeyType; out Value: TValueType): Boolean;
      procedure Delete(const Key: TKeyType);

      function GetValue(const Key: TKeyType; out Value: TValueType): Boolean; overload;
      function GetValue(const Key: TKeyType): TValueType; overload;
      function SetValue(const Key: TKeyType; const Value: TValueType; out PreviousValue: TValueType): Boolean; overload;
      procedure SetValue(const Key: TKeyType; const Value: TValueType); overload;

      function GetKeys(var Keys: array of TKeyType): Integer;
      function GetValues(var Values: array of TValueType): Integer;
      function GetKeyValuePairs(var Pairs: array of TKeyTypeValueTypePair): Integer;

      property Count: Integer read FEntryCount;
      property Capacity: Integer read FBucketCapacity write SetCapacity;
      property OwnsItems: Boolean read FOwnsItems write FOwnsItems;
      property RehashLoadFactor: Single read FRehashLoadFactor write SetRehashLoadFactor;
  end;

implementation

uses
  Math,
  Bfg.SystemInfo;

type
  PFastLookupRec = ^TFastLookupRec;
  TFastLookupRec = packed record
    RelOffs: array[0..7] of ShortInt;
    Count: ShortInt;
  end;

const
  FastIndexLookup: array[Byte] of TFastLookupRec = (
    (RelOffs: (0, 0, 0, 0, 0, 0, 0, 0); Count: 0),
    (RelOffs: (0, 0, 0, 0, 0, 0, 0, 0); Count: 1),
    (RelOffs: (1, 0, 0, 0, 0, 0, 0, 0); Count: 1),
    (RelOffs: (0, 1, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (2, 0, 0, 0, 0, 0, 0, 0); Count: 1),
    (RelOffs: (0, 2, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (1, 2, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 1, 2, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (3, 0, 0, 0, 0, 0, 0, 0); Count: 1),
    (RelOffs: (0, 3, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (1, 3, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 1, 3, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (2, 3, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 2, 3, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (1, 2, 3, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 1, 2, 3, 0, 0, 0, 0); Count: 4),
    (RelOffs: (4, 0, 0, 0, 0, 0, 0, 0); Count: 1),
    (RelOffs: (0, 4, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (1, 4, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 1, 4, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (2, 4, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 2, 4, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (1, 2, 4, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 1, 2, 4, 0, 0, 0, 0); Count: 4),
    (RelOffs: (3, 4, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 3, 4, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (1, 3, 4, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 1, 3, 4, 0, 0, 0, 0); Count: 4),
    (RelOffs: (2, 3, 4, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 2, 3, 4, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 2, 3, 4, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 2, 3, 4, 0, 0, 0); Count: 5),
    (RelOffs: (5, 0, 0, 0, 0, 0, 0, 0); Count: 1),
    (RelOffs: (0, 5, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (1, 5, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 1, 5, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (2, 5, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 2, 5, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (1, 2, 5, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 1, 2, 5, 0, 0, 0, 0); Count: 4),
    (RelOffs: (3, 5, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 3, 5, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (1, 3, 5, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 1, 3, 5, 0, 0, 0, 0); Count: 4),
    (RelOffs: (2, 3, 5, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 2, 3, 5, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 2, 3, 5, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 2, 3, 5, 0, 0, 0); Count: 5),
    (RelOffs: (4, 5, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 4, 5, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (1, 4, 5, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 1, 4, 5, 0, 0, 0, 0); Count: 4),
    (RelOffs: (2, 4, 5, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 2, 4, 5, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 2, 4, 5, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 2, 4, 5, 0, 0, 0); Count: 5),
    (RelOffs: (3, 4, 5, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 3, 4, 5, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 3, 4, 5, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 3, 4, 5, 0, 0, 0); Count: 5),
    (RelOffs: (2, 3, 4, 5, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 2, 3, 4, 5, 0, 0, 0); Count: 5),
    (RelOffs: (1, 2, 3, 4, 5, 0, 0, 0); Count: 5),
    (RelOffs: (0, 1, 2, 3, 4, 5, 0, 0); Count: 6),
    (RelOffs: (6, 0, 0, 0, 0, 0, 0, 0); Count: 1),
    (RelOffs: (0, 6, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (1, 6, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 1, 6, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (2, 6, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 2, 6, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (1, 2, 6, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 1, 2, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (3, 6, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 3, 6, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (1, 3, 6, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 1, 3, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (2, 3, 6, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 2, 3, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 2, 3, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 2, 3, 6, 0, 0, 0); Count: 5),
    (RelOffs: (4, 6, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 4, 6, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (1, 4, 6, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 1, 4, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (2, 4, 6, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 2, 4, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 2, 4, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 2, 4, 6, 0, 0, 0); Count: 5),
    (RelOffs: (3, 4, 6, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 3, 4, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 3, 4, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 3, 4, 6, 0, 0, 0); Count: 5),
    (RelOffs: (2, 3, 4, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 2, 3, 4, 6, 0, 0, 0); Count: 5),
    (RelOffs: (1, 2, 3, 4, 6, 0, 0, 0); Count: 5),
    (RelOffs: (0, 1, 2, 3, 4, 6, 0, 0); Count: 6),
    (RelOffs: (5, 6, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 5, 6, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (1, 5, 6, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 1, 5, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (2, 5, 6, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 2, 5, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 2, 5, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 2, 5, 6, 0, 0, 0); Count: 5),
    (RelOffs: (3, 5, 6, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 3, 5, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 3, 5, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 3, 5, 6, 0, 0, 0); Count: 5),
    (RelOffs: (2, 3, 5, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 2, 3, 5, 6, 0, 0, 0); Count: 5),
    (RelOffs: (1, 2, 3, 5, 6, 0, 0, 0); Count: 5),
    (RelOffs: (0, 1, 2, 3, 5, 6, 0, 0); Count: 6),
    (RelOffs: (4, 5, 6, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 4, 5, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 4, 5, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 4, 5, 6, 0, 0, 0); Count: 5),
    (RelOffs: (2, 4, 5, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 2, 4, 5, 6, 0, 0, 0); Count: 5),
    (RelOffs: (1, 2, 4, 5, 6, 0, 0, 0); Count: 5),
    (RelOffs: (0, 1, 2, 4, 5, 6, 0, 0); Count: 6),
    (RelOffs: (3, 4, 5, 6, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 3, 4, 5, 6, 0, 0, 0); Count: 5),
    (RelOffs: (1, 3, 4, 5, 6, 0, 0, 0); Count: 5),
    (RelOffs: (0, 1, 3, 4, 5, 6, 0, 0); Count: 6),
    (RelOffs: (2, 3, 4, 5, 6, 0, 0, 0); Count: 5),
    (RelOffs: (0, 2, 3, 4, 5, 6, 0, 0); Count: 6),
    (RelOffs: (1, 2, 3, 4, 5, 6, 0, 0); Count: 6),
    (RelOffs: (0, 1, 2, 3, 4, 5, 6, 0); Count: 7),
    (RelOffs: (7, 0, 0, 0, 0, 0, 0, 0); Count: 1),
    (RelOffs: (0, 7, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (1, 7, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 1, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (2, 7, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 2, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (1, 2, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 1, 2, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (3, 7, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 3, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (1, 3, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 1, 3, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (2, 3, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 2, 3, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 2, 3, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 2, 3, 7, 0, 0, 0); Count: 5),
    (RelOffs: (4, 7, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 4, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (1, 4, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 1, 4, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (2, 4, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 2, 4, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 2, 4, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 2, 4, 7, 0, 0, 0); Count: 5),
    (RelOffs: (3, 4, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 3, 4, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 3, 4, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 3, 4, 7, 0, 0, 0); Count: 5),
    (RelOffs: (2, 3, 4, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 2, 3, 4, 7, 0, 0, 0); Count: 5),
    (RelOffs: (1, 2, 3, 4, 7, 0, 0, 0); Count: 5),
    (RelOffs: (0, 1, 2, 3, 4, 7, 0, 0); Count: 6),
    (RelOffs: (5, 7, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 5, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (1, 5, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 1, 5, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (2, 5, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 2, 5, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 2, 5, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 2, 5, 7, 0, 0, 0); Count: 5),
    (RelOffs: (3, 5, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 3, 5, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 3, 5, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 3, 5, 7, 0, 0, 0); Count: 5),
    (RelOffs: (2, 3, 5, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 2, 3, 5, 7, 0, 0, 0); Count: 5),
    (RelOffs: (1, 2, 3, 5, 7, 0, 0, 0); Count: 5),
    (RelOffs: (0, 1, 2, 3, 5, 7, 0, 0); Count: 6),
    (RelOffs: (4, 5, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 4, 5, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 4, 5, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 4, 5, 7, 0, 0, 0); Count: 5),
    (RelOffs: (2, 4, 5, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 2, 4, 5, 7, 0, 0, 0); Count: 5),
    (RelOffs: (1, 2, 4, 5, 7, 0, 0, 0); Count: 5),
    (RelOffs: (0, 1, 2, 4, 5, 7, 0, 0); Count: 6),
    (RelOffs: (3, 4, 5, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 3, 4, 5, 7, 0, 0, 0); Count: 5),
    (RelOffs: (1, 3, 4, 5, 7, 0, 0, 0); Count: 5),
    (RelOffs: (0, 1, 3, 4, 5, 7, 0, 0); Count: 6),
    (RelOffs: (2, 3, 4, 5, 7, 0, 0, 0); Count: 5),
    (RelOffs: (0, 2, 3, 4, 5, 7, 0, 0); Count: 6),
    (RelOffs: (1, 2, 3, 4, 5, 7, 0, 0); Count: 6),
    (RelOffs: (0, 1, 2, 3, 4, 5, 7, 0); Count: 7),
    (RelOffs: (6, 7, 0, 0, 0, 0, 0, 0); Count: 2),
    (RelOffs: (0, 6, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (1, 6, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 1, 6, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (2, 6, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 2, 6, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 2, 6, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 2, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (3, 6, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 3, 6, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 3, 6, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 3, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (2, 3, 6, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 2, 3, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (1, 2, 3, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (0, 1, 2, 3, 6, 7, 0, 0); Count: 6),
    (RelOffs: (4, 6, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 4, 6, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 4, 6, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 4, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (2, 4, 6, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 2, 4, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (1, 2, 4, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (0, 1, 2, 4, 6, 7, 0, 0); Count: 6),
    (RelOffs: (3, 4, 6, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 3, 4, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (1, 3, 4, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (0, 1, 3, 4, 6, 7, 0, 0); Count: 6),
    (RelOffs: (2, 3, 4, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (0, 2, 3, 4, 6, 7, 0, 0); Count: 6),
    (RelOffs: (1, 2, 3, 4, 6, 7, 0, 0); Count: 6),
    (RelOffs: (0, 1, 2, 3, 4, 6, 7, 0); Count: 7),
    (RelOffs: (5, 6, 7, 0, 0, 0, 0, 0); Count: 3),
    (RelOffs: (0, 5, 6, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (1, 5, 6, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 1, 5, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (2, 5, 6, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 2, 5, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (1, 2, 5, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (0, 1, 2, 5, 6, 7, 0, 0); Count: 6),
    (RelOffs: (3, 5, 6, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 3, 5, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (1, 3, 5, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (0, 1, 3, 5, 6, 7, 0, 0); Count: 6),
    (RelOffs: (2, 3, 5, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (0, 2, 3, 5, 6, 7, 0, 0); Count: 6),
    (RelOffs: (1, 2, 3, 5, 6, 7, 0, 0); Count: 6),
    (RelOffs: (0, 1, 2, 3, 5, 6, 7, 0); Count: 7),
    (RelOffs: (4, 5, 6, 7, 0, 0, 0, 0); Count: 4),
    (RelOffs: (0, 4, 5, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (1, 4, 5, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (0, 1, 4, 5, 6, 7, 0, 0); Count: 6),
    (RelOffs: (2, 4, 5, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (0, 2, 4, 5, 6, 7, 0, 0); Count: 6),
    (RelOffs: (1, 2, 4, 5, 6, 7, 0, 0); Count: 6),
    (RelOffs: (0, 1, 2, 4, 5, 6, 7, 0); Count: 7),
    (RelOffs: (3, 4, 5, 6, 7, 0, 0, 0); Count: 5),
    (RelOffs: (0, 3, 4, 5, 6, 7, 0, 0); Count: 6),
    (RelOffs: (1, 3, 4, 5, 6, 7, 0, 0); Count: 6),
    (RelOffs: (0, 1, 3, 4, 5, 6, 7, 0); Count: 7),
    (RelOffs: (2, 3, 4, 5, 6, 7, 0, 0); Count: 6),
    (RelOffs: (0, 2, 3, 4, 5, 6, 7, 0); Count: 7),
    (RelOffs: (1, 2, 3, 4, 5, 6, 7, 0); Count: 7),
    (RelOffs: (0, 1, 2, 3, 4, 5, 6, 7); Count: 8)
  );

{ TKeyTypeValueType }

constructor TKeyTypeValueTypeHashMap.Create(Capacity: Integer; OwnsItems: Boolean;
  const RehashLoadFactor: Single);
begin
  inherited Create;
  
  if Capacity <= 0 then
  begin
    Capacity := 128;
  end else
  begin
    Capacity := NextPowerOf2(Capacity);
  end;

  FEntryBatchOccupiedHigh := -1;
  FEntryBatchOccupiedLow := $7FFFFFFF;
  FOwnsItems := OwnsItems;
  FRehashLoadFactor := RehashLoadFactor;
  SetCapacity(Capacity);
  SetEntryBatchCapacity(128);
end;

destructor TKeyTypeValueTypeHashMap.Destroy;
var
  I, J: Integer;
begin
  if OwnsItems then
  begin
    for I := 0 to FEntryBatchCapacity -1 do
    begin
      if IsEntryBatchOccupied(I) then
      begin
        for J := 0 to (FEntryBatches[I].Count and $7F) -1 do
        begin
          FreeItem(FEntryBatches[I].Entries[J].HValue);
        end;
      end;
    end;
  end;

  inherited Destroy;
end;

procedure TKeyTypeValueTypeHashMap.FreeItem(var Item);
begin
  TObject(Item).Free;
end;

function TKeyTypeValueTypeHashMap.GetKeys(var Keys: array of TKeyType): Integer;
var
  I: Integer;
  C: Integer;
  J: Integer;
  L: PFastLookupRec;
  Data: PByte;
  P: PByte;
  RawBitArrayValue: Byte;
begin
(*
  if Length(Keys) < FEntryCount then System.Error(reRangeError);
  Result := 0;

  if (FEntryValidLowest = -1) or (FEntryValidHighest = -1) then Exit;
  Data := @FEntryValidArray[FEntryValidLowest shr 3];

  for I := FEntryValidLowest shr 3 to FEntryValidHighest shr 3 do
  begin
    RawBitArrayValue := Data^;
    if RawBitArrayValue = 0 then Continue;
    C := I * 8;
    L := @FastIndexLookup[RawBitArrayValue];
    P := @L^.RelOffs[0];
    for J := 0 to L^.Count -1 do
    begin
      Keys[Result] := FEntries[C + P^].HashKey;
      Inc(Result);
      Inc(P);
    end;
    Inc(Data);
  end;
*)
end;

function TKeyTypeValueTypeHashMap.GetValues(var Values: array of TValueType): Integer;
var
  I: Integer;
  C: Integer;
  J: Integer;
  L: PFastLookupRec;
  Data: PByte;
  P: PByte;
  RawBitArrayValue: Byte;
begin
(*
  if Length(Values) < FEntryCount then System.Error(reRangeError);
  Result := 0;

  if (FEntryValidLowest = -1) or (FEntryValidHighest = -1) then Exit;
  Data := @FEntryValidArray[FEntryValidLowest shr 3];

  for I := FEntryValidLowest shr 3 to FEntryValidHighest shr 3 do
  begin
    RawBitArrayValue := Data^;
    if RawBitArrayValue = 0 then Continue;
    C := I * 8;
    L := @FastIndexLookup[RawBitArrayValue];
    P := @L^.RelOffs[0];
    for J := 0 to L^.Count -1 do
    begin
      Values[Result] := FEntries[C + P^].HashValue;
      Inc(Result);
      Inc(P);
    end;
    Inc(Data);
  end;
*)
end;

function TKeyTypeValueTypeHashMap.GetKeyValuePairs(var Pairs: array of TKeyTypeValueTypePair): Integer;
var
  I: Integer;
  C: Integer;
  J: Integer;
  L: PFastLookupRec;
  Data: PByte;
  P: PByte;
  RawBitArrayValue: Byte;
begin
  if Length(Pairs) < FEntryCount then System.Error(reRangeError);
  Result := 0;

(*
  if (FEntryValidLowest = -1) or (FEntryValidHighest = -1) then Exit;
  Data := @FEntryValidArray[FEntryValidLowest shr 3];

  for I := FEntryValidLowest shr 3 to FEntryValidHighest shr 3 do
  begin
    RawBitArrayValue := Data^;
    if RawBitArrayValue = 0 then Continue;
    C := I * 8;
    L := @FastIndexLookup[RawBitArrayValue];
    P := @L^.RelOffs[0];
    for J := 0 to L^.Count -1 do
    begin
      with Pairs[Result], FEntries[C + P^] do
      begin
        Key := HKey;
        Value := HValue;
      end;
      Inc(Result);
      Inc(P);
    end;
    Inc(Data);
  end;
*)
end;

function TKeyTypeValueTypeHashMap.GetMemoryUsageInBytes: Longword;
var
  I: Integer;
begin
(*
  Result := InstanceSize + ((SizeOf(Integer) * 4) + Length(FEntries) * SizeOf(THashEntry)) +
    Length(FEntryValidArray);
  for I := 0 to FCapacity -1 do
  begin
    if Length(FBuckets[I].Indices) <> 0 then
    begin
      Inc(Result, SizeOf(THashBucket) + SizeOf(Integer) * 2 + Length(FBuckets[I].Indices) * SizeOf(Integer));
    end else
    begin
      Inc(Result, SizeOf(THashBucket));
    end;
  end;
*)
  Result := InstanceSize;
end;

function TKeyTypeValueTypeHashMap.LookupConsecutiveEmptyEntryBatches(Count: Integer;
  out Index: Integer): PHashEntryBatch;
begin
  Result := nil;
  Index := -1;
end;

procedure TKeyTypeValueTypeHashMap.InsertPair(var Bucket: Integer;
  const Key: TKeyType; const Value: TValueType);
var
  I: Integer;
  Batch: PHashEntryBatch;
  Pair: THashEntry;
begin
  Pair.HKey := Key;
  Pair.HValue := Value;
  InsertPairAsm(Bucket, Pair);
(*
  if Bucket = -1 then
  begin
    // Look for a vacant entry in front at back
    if FEntryBatchOccupiedHigh = -1 then FEntryBatchOccupiedHigh := 0;
    I := ResetBitScanForward(FEntryBatchesOccupied, FEntryBatchOccupiedHigh,
      FEntryBatchCapacity - 1);

    if I = -1 then
    begin
      // Look for a vacant entry in front
      I := ResetBitScanForward(FEntryBatchesOccupied, 0, FEntryBatchOccupiedLow);
      if I = -1 then
      begin
        // No vacant entries, let's allocate some
        I := FEntryBatchCount;
        SetEntryBatchCapacity(FEntryBatchCapacity * 2);
      end;
    end;
  
    Batch := @FEntryBatches[I];
    Bucket := I;
    // Update low/high markers
    if I > FEntryBatchOccupiedHigh then FEntryBatchOccupiedHigh := I;
    if I < FEntryBatchOccupiedLow then FEntryBatchOccupiedLow := I;

    // Now fill up the entry batch
    Inc(FEntryCount);
    Inc(FEntryBatchCount);
    SetBit(FEntryBatchesOccupied, I);
    with Batch^ do
    begin
      Count := 1;
      with Entries[0] do
      begin
        HKey := Key;
        HValue := Value;
      end;
    end;
  end else
  begin
    InsertPairComplex(Bucket, Key, Value);
  end;
*)
end;

procedure TKeyTypeValueTypeHashMap.InsertPairAsm(var Bucket: Integer;
  const Pair: THashEntry);
//  EAX = Self
//  EDX = Bucket (PInteger)
//  ECX = Pair (PHashEntry)
asm
  CMP    DWORD PTR [EDX], -1
  JNE    @@CallComplex

  PUSH   EDX // [ESP+20] Bucket
  PUSH   ECX // [ESP+16] Pair
  PUSH   EBX // [ESP+12]
  PUSH   ESI // [ESP+8]
  PUSH   EDI // [ESP+4]
  PUSH   EBP // [ESP]

  MOV    ESI, EAX
  XOR    EAX, EAX

  {
    I := ResetBitScanForward(FEntryBatchesOccupied, FEntryBatchOccupiedHigh,
      FEntryBatchCapacity - 1);
  }
  MOV    EDI, [ESI].TKeyTypeValueTypeHashMap.FEntryBatchCapacity
  MOV    EDX, [ESI].TKeyTypeValueTypeHashMap.FEntryBatchOccupiedHigh
  MOV    EBX, [ESI].TKeyTypeValueTypeHashMap.FEntryBatchesOccupied
  CMP    EDX, -1
  MOV    ECX, EDI
  CMOVE  EDX, EAX
  DEC    ECX
  MOV    EAX, EBX
  { EAX = FEntryBatchesValid, EDX = FEntryBatchCountHigh, ECX = FEntryBatchCapacity -1 }
  CALL   ResetBitScanForward

  CMP    EAX, -1
  JNE    @@Found

  {
    I := ResetBitScanForward(FEntryBatchesOccupied, 0, FEntryBatchOccupiedLow);
  }
  MOV    ECX, [ESI].TKeyTypeValueTypeHashMap.FEntryBatchOccupiedLow
  XOR    EDX, EDX
  MOV    EAX, EBX
  { EAX = FEntryBatchesValid, EDX = 0, ECX = FEntryBatchOccupiedLow }
  CALL   ResetBitScanForward

  CMP    EAX, -1
  JNE    @@Found

  {
    I := FEntryBatchCount;
    SetEntryBatchCapacity(FEntryBatchCapacity * 2);
    Inc(FEntryBatchCount);
  }

  // Must preserve EAX (I), ESI(Self) and EBX(FEntryBatchesOccupied), everything else can be modified
  MOV   EBP, [ESI].TKeyTypeValueTypeHashMap.FEntryBatchCount
  ADD   EDI, EDI
  MOV   EAX, ESI
  MOV   EDX, EDI
  CALL  TKeyTypeValueTypeHashMap.SetEntryBatchCapacity

  MOV   EAX, EBP
@@Found:

  // EAX -> I, ESI - Self
  MOV    EDI, EAX
  XOR    EDX, EDX
  MOV    ECX, [ESI].TKeyTypeValueTypeHashMap.FEntryBatches
  IMUL   EAX, TYPE THashEntryBatch
  INC    [ESI].TKeyTypeValueTypeHashMap.FEntryCount // Inc(FEntryCount);
  INC    [ESI].TKeyTypeValueTypeHashMap.FEntryBatchCount // Inc(FEntryBatchCount);
  MOV    EDX, [ESP+20]
  LEA    ECX, [ECX+EAX] // Bucket := @FEntryBatches[I]
  MOV    [EDX], EDI // Bucket := I
  BTS    [EBX], EDI // SetBit(FEntryBatchesOccupied, I);
  MOV    EDX, [ESP+16]
  {
    if I > FEntryBatchOccupiedHigh then FEntryBatchOccupiedHigh := I;
  }
  CMP    EDI, [ESI].TKeyTypeValueTypeHashMap.FEntryBatchOccupiedHigh
  JNG    @@Skip1
  MOV    [ESI].TKeyTypeValueTypeHashMap.FEntryBatchOccupiedHigh, EDI
@@Skip1:

  {
    if I < FEntryBatchOccupiedLow then FEntryBatchOccupiedLow := I;
  }
  CMP    EDI, [ESI].TKeyTypeValueTypeHashMap.FEntryBatchOccupiedLow
  JNL    @@Skip2
  MOV    [ESI].TKeyTypeValueTypeHashMap.FEntryBatchOccupiedLow, EDI
@@Skip2:

  {
    with Batch^ do
    begin
      Count := 1;
      with Entries[0] do
      begin
        HKey := Key;
        HValue := Value;
      end;
    end;
  }

  MOV   EAX, [EDX].THashEntry.HKey
  MOV   EDX, [EDX].THashEntry.HValue
  MOV   [ECX].THashEntryBatch.Count, 1
  MOV   [ECX].THashEntryBatch.Entries[0].THashEntry.HKey, EAX
  MOV   [ECX].THashEntryBatch.Entries[0].THashEntry.HValue, EDX

  POP    EBP
  POP    EDI
  POP    ESI
  POP    EBX
  ADD    ESP, 8
  RET
@@CallComplex:
  PUSH   [ECX].THashEntry.HValue
  MOV    ECX, [ECX].THashEntry.HKey
  CALL    InsertPairComplex
end;

procedure TKeyTypeValueTypeHashMap.InsertPairComplex(var Bucket: Integer;
  const Key: Integer; const Value: TValueType);
var
  I: Integer;
  J: Integer;
  Batch: PHashEntryBatch;
  BatchCount: Integer;
  BIndex: Integer;
  C: Byte;
label
  __GrabEntryBatch, __AllocEntryBatch;
begin
  BIndex := Bucket;
  Batch := @FEntryBatches[BIndex];
  C := Batch^.Count;

  if (C and $80) = 0 then
  begin
    if C <> ENTRIES_PER_BATCH then
    begin
      // Some entries empty
      __GrabEntryBatch:
      with Batch^ do
      begin
        with Entries[C] do
        begin
          HKey := Key;
          HValue := Value;
        end;
        Inc(Count);
      end;

      Inc(FEntryCount);
    end else
    begin
      I := BIndex + 1;
      BatchCount := 1;

      // No entries empty
      __AllocEntryBatch:
      Batch^.Count := Batch^.Count or $80;
      if IsEntryBatchOccupied(I) then
      begin
        // We cannot grow in a linear manner, we must find a slot big enough
        Batch := LookupConsecutiveEmptyEntryBatches(BatchCount + 1, J);

        ResetBits(@FEntryBatchesOccupied[0], I, I + BatchCount); // Mark as empty
        SetBits(@FEntryBatchesOccupied[1], J, J + BatchCount); // Mark as occupied
        Move(FEntryBatches[I], Batch^, BatchCount * SizeOf(THashEntryBatch));
        {$IFDEF DEBUG_ON}
        FillChar(FEntryBatches[I], BatchCount * SizeOf(THashEntryBatch), 0);
        {$ENDIF}
        Inc(Batch, BatchCount);
        Bucket := J;
      end else
      begin
        // The best case, we'll just occupy next entry
        Inc(Batch);
        Inc(FEntryCount);
        SetBit(FEntryBatchesOccupied, I);
        with Batch^ do
        begin
          Count := 1;
          with Entries[0] do
          begin
            HKey := Key;
            HValue := Value;
          end;
        end;
      end;
    end;
  end else
  begin
    // Loop till last entry reached
    BatchCount := 0;
    repeat
      Inc(Batch);
      Inc(BatchCount);
      C := Batch^.Count;
    until (C and $80) = 0;

    C := C and $7F;
    if C <> ENTRIES_PER_BATCH then goto __GrabEntryBatch;

    Inc(I);
    // This is gonna hurt -> we must find BatchCount consecutive empty batches
    goto __AllocEntryBatch;
  end;
end;

function TKeyTypeValueTypeHashMap.GetValue(const Key: TKeyType;
  out Value: TValueType): Boolean;
var
  BIndex: Integer;
  Batch: PHashEntryBatch;
  Entry: PHashEntry;
  Temp: PHashEntry;
  I: Integer;
  C: Integer;
begin
  BIndex := FBuckets[HashLong(Longword(Key)) and FMask];
  if BIndex <> -1 then
  begin
    Batch := @FEntryBatches[BIndex];
    repeat
      C := Batch^.Count;
      Entry := @Batch^.Entries[0];
      for I := 0 to (C and $7F) -1 do
      begin
        if Entry^.HKey = Key then
        begin
          Value := Entry^.HValue;
          Result := True;
          Exit;
        end;
        Inc(Entry);
      end;
      Inc(Batch);
    until (C and $80000000) = 0;
  end;

  Result := False;
  Value := nil;
end;

function TKeyTypeValueTypeHashMap.GetValue(const Key: TKeyType): TValueType;
var
  BIndex: Integer;
  Batch: PHashEntryBatch;
  Temp: PHashEntry;
  I: Integer;
  C: Integer;
begin
  BIndex := FBuckets[HashLong(Longword(Key)) and FMask];
  if BIndex <> -1 then
  begin
    Batch := @FEntryBatches[BIndex];
    repeat
      with Batch^ do
      begin
        C := Batch^.Count;
        for I := 0 to (C and $7F) -1 do
        begin
          if Batch^.Entries[I].HKey = Key then
          begin
            Result := Batch^.Entries[I].HValue;
            Exit;
          end;
        end;
      end;
      Inc(Batch);
    until (C and $80000000) = 0;
  end;

  Result := nil;
end;

function TKeyTypeValueTypeHashMap.IsEntryBatchOccupied(Index: Integer): Boolean;
begin
  Result := GetBit(FEntryBatchesOccupied, Index);
end;

procedure TKeyTypeValueTypeHashMap.Rehash(OldCapacity: Integer;
  const OldBatchesOccupied: TByteDynArray);
var
  I, J: Integer;
  BatchCopies: THashEntryBatchDynArray;
  Pair: THashEntry;
begin
  for I := 0 to OldCapacity -1 do
  begin
    FBuckets[I] := -1;
  end;

  BatchCopies := Copy(FEntryBatches, 1, Length(FEntryBatches));
  FillChar(FEntryBatches[0], Length(FEntryBatches) * SizeOf(THashEntryBatch), 0);

  for I := 0 to (Length(OldBatchesOccupied) shl 3) -1 do
  begin
    if GetBit(@OldBatchesOccupied[0], I) then
    begin
      for J := 0 to Integer(BatchCopies[I].Count and $7F) -1 do
      begin
        Pair := BatchCopies[I].Entries[J];
        InsertPairAsm(FBuckets[HashLong(Longword((Pair.HKey))) and FMask], Pair);
      end;
    end;
  end;
end;

function TKeyTypeValueTypeHashMap.Remove(const Key: TKeyType;
  out Value: TValueType): Boolean;
(*
var
  Temp: PHashEntry;
  Bucket: PHashBucket;
  Hash: Longword;
  I: Integer;
  J: Integer;
  B: ShortInt;
begin
  Result := False;
  Hash := HashLong(Longword(Key)) and FMask;

  Bucket := @FBuckets[Hash];
  for I := 0 to Length(Bucket^.Indices) -1 do
  begin
    J := Bucket^.Indices[I];
    Temp := @FEntries[J];
    if Temp^.HashKey = Key then
    begin
      Result := True;
      Value := Temp^.HashValue;
      ResetBit(FEntryValidArray, J);
      Bucket^.Indices[Length(Bucket^.Indices)-1] := Bucket^.Indices[J];

      if J = FEntryValidHighest then
      begin
        B := FastIndexLookup[FEntryValidArray[J shr 3]].Count;
        Dec(FEntryValidHighest);
        if FEntryValidHighest < FEntryValidLowest then
        begin
          FEntryValidHighest := -1;
        end else if B <= 1 then
        begin
          FEntryValidHighest := SetBitScanBackward(FEntryValidArray, 0, FEntryValidHighest);
        end;
      end else if J = FEntryValidLowest then
      begin
        B := FastIndexLookup[FEntryValidArray[J shr 3]].Count;
        Inc(FEntryValidLowest);
        if FEntryValidLowest > FEntryValidHighest then
        begin
          FEntryValidLowest := -1;
        end else if B <= 1 then
        begin
          FEntryValidLowest := SetBitScanForward(FEntryValidArray, FEntryValidLowest, FEntryCapacity -1);
        end;
      end;

      Exit;
    end;
  end;

  Value := nil;
*)
begin
end;

procedure TKeyTypeValueTypeHashMap.Delete(const Key: TKeyType);
var
  V: TValueType;
begin
  if Remove(Key, V) and FOwnsItems then FreeItem(V);
end;

procedure TKeyTypeValueTypeHashMap.SetCapacity(NewCapacity: Integer);
var
  Save: Integer;
  SavedBitArray: TByteDynArray;
  DoRehash: Boolean;
begin
  DoRehash := FBucketCapacity <> 0;

  if NewCapacity <= 0 then
  begin
    NewCapacity := 128;
  end else
  begin
    NewCapacity := NextPowerOf2(NewCapacity);
  end;

  Save := FBucketCapacity;
  FBucketCapacity := NewCapacity;
  FMask := NewCapacity - 1;
  FEntryCountMax := Ceil32(FRehashLoadFactor * NewCapacity);
  SetLength(FBuckets, NewCapacity);
  FillChar(FBuckets[Save], (NewCapacity - Save) * SizeOf(Integer), -1);

  if DoRehash then
  begin
    SavedBitArray := Copy(FEntryBatchesOccupied, 1, Length(FEntryBatchesOccupied));
    FillChar(FEntryBatchesOccupied[0], Length(FEntryBatchesOccupied), 0);
    Rehash(Save, SavedBitArray);
  end else FillChar(FEntryBatchesOccupied[0], Length(FEntryBatchesOccupied), 0);
end;

procedure TKeyTypeValueTypeHashMap.SetEntryBatchCapacity(NewCapacity: Integer);
var
  OldArrayByteSize: Integer;
  OldBitArray: TByteDynArray;
begin
  FEntryBatchCapacity := NewCapacity;
  OldArrayByteSize := Length(FEntryBatchesOccupied);
  SetLength(FEntryBatchesOccupied, DivModPowerOf2Inc(NewCapacity, 3));
  SetLength(FEntryBatches, NewCapacity);
  if Length(FEntryBatchesOccupied) > OldArrayByteSize then
  begin
    FillChar(FEntryBatchesOccupied[OldArrayByteSize],
      Length(FEntryBatchesOccupied) - OldArrayByteSize, 0);
  end;
end;

procedure TKeyTypeValueTypeHashMap.SetRehashLoadFactor(const NewRehashLoadFactor: Single);
begin
  if NewRehashLoadFactor <= 0 then Exit;

  FRehashLoadFactor := NewRehashLoadFactor;
  FEntryCountMax := Ceil32(FBucketCapacity * NewRehashLoadFactor);

  if FEntryCount >= FEntryCountMax then
  begin
    SetCapacity(FBucketCapacity + FBucketCapacity shr 1);
  end;
end;

procedure TKeyTypeValueTypeHashMap.SetValue(const Key: TKeyType; const Value: TValueType);
var
  Pair: THashEntry;
  BIndex: Integer;
  Batch: PHashEntryBatch;
  Entry: PHashEntry;
  Temp: PHashEntry;
  I: Integer;
  J: Integer;
  C: Integer;
begin
  if FEntryCount >= FEntryCountMax then SetCapacity(FBucketCapacity + FBucketCapacity shr 1);
  J := HashLong(Longword(Key)) and FMask;

  BIndex := FBuckets[J];
  if BIndex <> -1 then
  begin
    Batch := @FEntryBatches[BIndex];
    repeat
      C := Batch^.Count;
      Entry := @Batch^.Entries[0];
      for I := 0 to Integer(C and $7F) -1 do
      begin
        if Entry^.HKey = Key then
        begin
          Entry^.HValue := Value;
          Exit;
        end;
        Inc(Entry);
      end;
      Inc(Batch);
    until (C and $80000000) = 0;
  end;

  Pair.HKey := Key;
  Pair.HValue := Value;
  InsertPairAsm(FBuckets[J], Pair);
end;

function TKeyTypeValueTypeHashMap.SetValue(const Key: TKeyType; const Value: TValueType;
  out PreviousValue: TValueType): Boolean;
var
  BIndex: Integer;
  Batch: PHashEntryBatch;
  Entry: PHashEntry;
  Temp: PHashEntry;
  I: Integer;
  J: Integer;
  C: Integer;
begin
  if FEntryCount >= FEntryCountMax then SetCapacity(FBucketCapacity + FBucketCapacity shr 1);
  J := HashLong(Longword(Key)) and FMask;

  BIndex := FBuckets[J];
  if BIndex <> -1 then
  begin
    Batch := @FEntryBatches[BIndex];
    repeat
      C := Batch^.Count;
      Entry := @Batch^.Entries[0];
      for I := 0 to Integer(C and $7F) -1 do
      begin
        if Entry^.HKey = Key then
        begin
          PreviousValue := Entry^.HValue;
          Entry^.HValue := Value;
          Result := True;
          Exit;
        end;
        Inc(Entry);
      end;
      Inc(Batch);
    until (C and $80000000) = 0;
  end;

  InsertPair(FBuckets[J], Key, Value);
  Result := False;
  PreviousValue := nil;
end;

end.
