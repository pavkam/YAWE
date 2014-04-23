{*------------------------------------------------------------------------------
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Bfg.Classes;

interface

uses
  SysUtils,
  Bfg.Threads,
  Bfg.Containers,
  Bfg.Utils,
  Bfg.Strings,
  Classes;

type
  TStreamClass = class of TStream;

  { The base wrapper type which takes a TStream descendant and optionally frees
    it on destruction. Various specific structure readers/writers and encryption
    or compression stream wrappers can be made utilizing this class. }

  TStreamWrapper = class(TObject)
    private
      FStream: TStream;
      FFreeOwnedStream: Longbool;
    protected
      function GetPosition: Int64; inline;
      function GetSize: Int64; inline;
      procedure SetPosition(const Position: Int64); inline;
      procedure SetSize(const Size: Int64); inline;
    public
      constructor Create(Stream: TStream; FreeOwnedStream: Boolean = True); overload;
      constructor Create(const FileName: string; Mode: Longword); overload;
      constructor Create(const FileName: WideString; Mode: Longword); overload;
      constructor Create(Buf: Pointer; Size: Integer); overload;
      destructor Destroy; override;

      function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; inline;

      property Stream: TStream read FStream write FStream;
      property FreeOwnedStream: Longbool read FFreeOwnedStream write FFreeOwnedStream;

      property Position: Int64 read GetPosition write SetPosition;
  end;

  TStreamReader = class(TStreamWrapper)
    public
      function Read(var Buffer; Count: Longint): Longint; inline;
      procedure ReadBuffer(var Buffer; Count: Longint); inline;

      property Size: Int64 read GetSize;
  end;

  TStreamWriter = class(TStreamWrapper)
    public
      function Write(const Buffer; Count: Longint): Longint; inline;
      procedure WriteBuffer(const Buffer; Count: Longint); inline;

      property Size: Int64 read GetSize write SetSize;
  end;

  TReuseableMemoryStream = class(TMemoryStream)
    private
      FFreeMemory: Longbool;
    protected
      function Realloc(var NewCapacity: Longint): Pointer; override;
    public
      constructor Create; overload;
      constructor Create(InitialCapacity: Integer); overload;
      constructor Create(Buf: Pointer; Size: Integer; FreeMemory: Boolean); overload;

      destructor Destroy; override;

      property Capacity;
      property FreeMemory: Longbool read FFreeMemory write FFreeMemory;
  end;

  PChunkInfo = ^TChunkInfo;
  TChunkInfo = record
    Ident: Longword;
    Size: Longword;
  end;

  { Reader class for binary files with chunky structure }
  TChunkReader = class(TStreamReader)
    private
      FCurrent: TChunkInfo;
      FCurrentChunkEnd: Int64;
    public
      function FetchNextChunk: Boolean;
      procedure SkipCurrentChunk;
      function ReadChunk(var Info: TChunkInfo; Buffer: Pointer; Size: Integer): Boolean;
      function ReadChunkData(Buffer: Pointer; Size: Integer): Boolean;
      function ReadChunkDataMax(Buffer: Pointer; Size: Integer): Boolean;
      property CurrentChunkIdent: Longword read FCurrent.Ident;
      property CurrentChunkSize: Longword read FCurrent.Size;
  end;

  { Writer class for binary files with chunky structure }
  TChunkWriter = class(TStreamWriter)
    public
      procedure WriteEmptyChunk(Ident: Longword; Size: Integer);
      procedure WriteEmptyChunkAligned(Ident: Longword; Size: Integer; Alignment: Integer);
      procedure WriteChunk(Ident: Longword; Data: Pointer; Size: Integer);
      procedure WriteChunkAligned(Ident: Longword; Data: Pointer; Size: Integer; Alignment: Integer);
      procedure WriteChunkData(Data: Pointer; Size: Integer);
  end;

  TFileMappingStream = class(TCustomMemoryStream)
    private
      FFileHandle: THandle;
      FMapping: THandle;
    protected
      procedure Close; virtual;
      procedure SetSize(const NewSize: Int64); override;
    public
      constructor Create(const FileName, MappingName: string; Mode: Longword;
        RaiseExceptions: Boolean = False); overload;

      constructor Create(const FileName, MappingName: WideString; Mode: Longword;
        RaiseExceptions: Boolean = False); overload;

      destructor Destroy; override;

      function Write(const Buffer; Count: Integer): Integer; override;
  end;

  TMemoryPool = class(TObject)
    private
      type
        PBufferHeader = ^TBufferHeader;
        TBufferHeader = record
          Signature: Longword;
          Index: Integer;
        end;

        PSegment = ^TSegment;
        TSegment = record
          Signature: Longword;
          FreeBufs: Integer;
          BitMask: PByteArray;
          Buffers: PBufferHeader;
          {
            BitMask: array[0..(n div 8)-1] of Byte;
            Data: array[0..n-1] of TBufferHeader;
          }
        end;

        PSegmentRange = ^TSegmentRange;
        TSegmentRange = record
          RangeStart: Pointer;
          RangeEnd: Pointer;
        end;
      var
        FSegmentCount: Integer;
        FSegmentSize: Integer;
        FSegmentFillBytes: Integer;
        FBufferFillBytes: Integer;
        FFreeBuffers: Integer;
        FStartingSegments: Integer;
        FBufferSize: Integer;
        FBuffersInSegment: Integer;
        FLock: TCriticalSection;

        FSegments: TPtrArrayList;
        FBufferPointers: TPtrArrayList;

        FDeletionCandidate: PSegment;
        FDeletionLimit: Integer;

        FTotalAllocated: Integer;
        FTotalFree: Integer;
        FOverhead: Integer;

        FThreadSafe: Longbool;
        FUseOSApi: Longbool;
        FOSProtectFlags: Longword;

      function PoolAllocMem: Pointer; inline;
      procedure PoolFreeMem(P: Pointer); inline;
      procedure AllocateSegment;
      procedure FreeSegment(Segment: PSegment);
      function PointerFromPool(P: Pointer): Boolean;
    public
      constructor Create(BufferSize, BuffersInSegment, StartingSegmentCount: Integer;
        const DeletionRatio: Single = 0.33333; ThreadSafe: Boolean = True;
        UseOperatingSystemAPIs: Boolean = False; ProtectionFlags: Longword = 0);

      destructor Destroy; override;

      procedure GetPoolInfo(out AllocatedTotal, FreeTotal, Overhead: Integer);

      function Allocate: Pointer;
      procedure FreePtr(P: Pointer);
  end;

  TBitArray = class(TObject)
    private
      FBuffer: TByteDynArray;
      FCount: Integer;
      FCapacity: Integer;
      FBitSeg: Integer;
      FIndices: TIntegerDynArray;
      FCompressed: Boolean;

      class procedure CompressBits(const Src: TByteDynArray; out Dst: TByteDynArray);
      class procedure DecompressBits(const Src: TByteDynArray; out Dst: TByteDynArray;
        MaxLen: Integer = -1);

      procedure Compress;
      procedure Decompress;

      procedure Grow;

      function GetBit(Index: Integer): Boolean;
      function GetBitCompressed(Index: Integer): Boolean;
      procedure SetCompressed(Value: Boolean);
      procedure SetBit(Index: Integer; Value: Boolean);
      procedure SetBitCompressed(Index: Integer; Value: Boolean);
      procedure SetCount(NewCount: Integer);
    public
      constructor Create(Capacity: Integer = 16); overload;
      constructor Create(Source: TBitArray); overload;
      constructor Create(Buf: Pointer; Size: Integer); overload;

      property Bits[Index: Integer]: Boolean read GetBit write SetBit;
      property Count: Integer read FCount write SetCount;
      property Compressed: Boolean read FCompressed write SetCompressed;
  end;

  TWideFileStream = class(THandleStream)
    private
      FFileName: WideString;
    public
      constructor Create(const AFileName: WideString; Mode: Word); overload;
      constructor Create(const AFileName: WideString; Mode: Word; Rights: Cardinal); overload;

      destructor Destroy; override;

      property FileName: WideString read FFileName;
  end;

  TCachedStream = class(TStream)
    private
      FInnerStream: TStream;

      FPosition: Int64;
      FSize: Int64;

      FReadCache: array of Byte;
      FReadCacheSize: Integer;
      FReadCacheFilled: Integer;
      FReadCachePos: Integer;

      FWriteCache: array of Byte;
      FWriteCacheSize: Integer;
      FWriteCacheFilled: Integer;

      FFlushPending: Boolean;
      FOwnsStream: Boolean;
    protected
      procedure FlushWriteBuffer; virtual;

      function GetSize: Int64; override;
      procedure SetSize(NewSize: Longint); override;
      procedure SetSize(const NewSize: Int64); override;

      property FlushPending: Boolean read FFlushPending write FFlushPending;
    public
      constructor Create(DataSource: TStream; ReadCacheSize: Integer = -1;
        WriteCacheSize: Integer = -1; OwnsStream: Boolean = True);
        
      destructor Destroy; override;

      function Read(var Buffer; Count: Longint): Longint; override;
      function Write(const Buffer; Count: Longint): Longint; override;
      function Seek(Offset: Longint; Origin: Word): Longint; override;
      function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;

      property InnerStream: TStream read FInnerStream;
      property ReadCacheSize: Integer read FReadCacheSize;
      property WriteCacheSize: Integer read FWriteCacheSize;
      property OwnsStream: Boolean read FOwnsStream write FOwnsStream;
  end;

implementation

uses
  Math,
  RTLConsts,
  API.Win.Types,
  API.Win.Kernel,
  API.Win.NtCommon,
  Bfg.Unicode,
  Bfg.Resources;

const
  MaxBufSize = $F000;

{ TStreamWrapper }

constructor TStreamWrapper.Create(Stream: TStream; FreeOwnedStream: Boolean);
begin
  inherited Create;
  FStream := Stream;
  FFreeOwnedStream := FreeOwnedStream;
end;

constructor TStreamWrapper.Create(const FileName: string; Mode: Longword);
begin
  inherited Create;
  FStream := TCachedStream.Create(TFileStream.Create(FileName, Mode));
  FFreeOwnedStream := True;
end;

constructor TStreamWrapper.Create(Buf: Pointer; Size: Integer);
var
  MS: TMemoryStream;
begin
  inherited Create;
  MS := TMemoryStream.Create;
  MS.WriteBuffer(Buf, Size);
  FStream := MS;
  FFreeOwnedStream := True;
end;

constructor TStreamWrapper.Create(const FileName: WideString; Mode: Longword);
begin
  inherited Create;
  FStream := TCachedStream.Create(TWideFileStream.Create(FileName, Mode));
  FFreeOwnedStream := True;
end;

destructor TStreamWrapper.Destroy;
begin
  if FFreeOwnedStream then FStream.Free;
  inherited Destroy;
end;

function TStreamWrapper.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  Result := FStream.Seek(Offset, Origin);
end;

function TStreamWrapper.GetPosition: Int64;
begin
  Result := FStream.Position;
end;

function TStreamWrapper.GetSize: Int64;
begin
  Result := FStream.Size;
end;

procedure TStreamWrapper.SetPosition(const Position: Int64);
begin
  FStream.Position := Position;
end;

procedure TStreamWrapper.SetSize(const Size: Int64);
begin
  FStream.Size := Size;
end;

{ TStreamReader }

function TStreamReader.Read(var Buffer; Count: Longint): Longint;
begin
  Result := FStream.Read(Buffer, Count);
end;

procedure TStreamReader.ReadBuffer(var Buffer; Count: Longint);
begin
  FStream.ReadBuffer(Buffer, Count);
end;

{ TStreamWriter }

function TStreamWriter.Write(const Buffer; Count: Longint): Longint;
begin
  Result := FStream.Write(Buffer, Count);
end;

procedure TStreamWriter.WriteBuffer(const Buffer; Count: Longint);
begin
  FStream.WriteBuffer(Buffer, Count);
end;

{ TReuseableMemoryStream }

constructor TReuseableMemoryStream.Create;
begin
  inherited Create;
end;

constructor TReuseableMemoryStream.Create(InitialCapacity: Integer);
begin
  inherited Create;
  if Capacity > 0 then Self.Capacity := InitialCapacity;
end;

constructor TReuseableMemoryStream.Create(Buf: Pointer; Size: Integer; FreeMemory: Boolean);
begin
  inherited Create;
  SetPointer(Buf, Size);
end;

destructor TReuseableMemoryStream.Destroy;
begin
  if FFreeMemory then FreeMem(Memory);
  inherited Destroy;
end;

function TReuseableMemoryStream.Realloc(var NewCapacity: Integer): Pointer;
begin
  if NewCapacity <= Capacity then
  begin
    Result := Memory;
    NewCapacity := Capacity;
  end else Result := inherited Realloc(NewCapacity);
end;

{ TChunkReader }

function TChunkReader.FetchNextChunk: Boolean;
begin
  Result := FStream.Read(FCurrent, SizeOf(FCurrent)) = SizeOf(FCurrent);
  FCurrentChunkEnd := FStream.Position + FCurrent.Size;
end;

function TChunkReader.ReadChunk(var Info: TChunkInfo; Buffer: Pointer;
  Size: Integer): Boolean;
begin
  Result := FetchNextChunk;
  if Result then
  begin
    Info := FCurrent;
    Result := ReadChunkData(Buffer, Size);
  end;
end;

function TChunkReader.ReadChunkData(Buffer: Pointer; Size: Integer): Boolean;
begin
  Result := FStream.Read(Buffer^, Size) = Size;
end;

function TChunkReader.ReadChunkDataMax(Buffer: Pointer; Size: Integer): Boolean;
begin
  if Integer(FCurrent.Size) < Size then
  begin
    FStream.Seek(FCurrentChunkEnd, soBeginning);
    Result := False;
  end else
  begin
    Result := FStream.Read(Buffer^, Size) = Size;
    if Result then
    begin
      SkipCurrentChunk;
    end;
  end;
end;

procedure TChunkReader.SkipCurrentChunk;
begin
  if FCurrentChunkEnd > Size then FStream.Seek(0, soEnd) else FStream.Seek(FCurrentChunkEnd, soBeginning);
end;

{ TChunkWriter }

procedure TChunkWriter.WriteChunk(Ident: Longword; Data: Pointer;
  Size: Integer);
var
  Chunk: TChunkInfo;
begin
  Chunk.Ident := Ident;
  Chunk.Size := Size;
  FStream.Write(Chunk, SizeOf(Chunk));
  if Data <> nil then FStream.Write(Data^, Size);
end;

procedure TChunkWriter.WriteChunkAligned(Ident: Longword; Data: Pointer; Size,
  Alignment: Integer);
var
  Chunk: TChunkInfo;
begin
  Chunk.Ident := Ident;
  Chunk.Size := ForceAlignment(Size, Alignment);
  FStream.Write(Chunk, SizeOf(Chunk));
  FStream.Write(Data^, Size);
  FStream.Seek(Chunk.Size - Longword(Size), soCurrent);
end;

procedure TChunkWriter.WriteChunkData(Data: Pointer; Size: Integer);
begin
  FStream.Write(Data^, Size);
end;

procedure TChunkWriter.WriteEmptyChunk(Ident: Longword; Size: Integer);
var
  Chunk: TChunkInfo;
begin
  Chunk.Ident := Ident;
  Chunk.Size := Size;
  FStream.Write(Chunk, SizeOf(Chunk));
  FStream.Seek(Size, soCurrent);
end;

procedure TChunkWriter.WriteEmptyChunkAligned(Ident: Longword; Size,
  Alignment: Integer);
var
  Chunk: TChunkInfo;
begin
  Chunk.Ident := Ident;
  Chunk.Size := ForceAlignment(Size, Alignment);
  FStream.Write(Chunk, SizeOf(Chunk));
  FStream.Seek(Chunk.Size, soCurrent);
end;

{ TFileMappingStream }

constructor TFileMappingStream.Create(const FileName, MappingName: string; Mode: Longword;
  RaiseExceptions: Boolean = False);
var
  Protect, Access, Size: DWORD;
  BaseAddress: Pointer;
begin
  inherited Create;
  FFileHandle := THandle(FileOpen(FileName, FileMode));
  if FFileHandle = INVALID_HANDLE_VALUE then
  begin
    if RaiseExceptions then
    begin
      raise EStreamError.CreateResFmt(@RsStreamCannotObtainFileHandle,
        [SysErrorMessage(GetLastError)]);
    end else Exit;
  end;
  if (FileMode and $0F) = fmOpenReadWrite then
  begin
    Protect := PAGE_WRITECOPY;
    Access := FILE_MAP_COPY;
  end else
  begin
    Protect := PAGE_READONLY;
    Access := FILE_MAP_READ;
  end;
  FMapping := CreateFileMapping(FFileHandle, nil, Protect, 0, 0, PChar(MappingName));
  if FMapping = 0 then
  begin
    Close;
    if RaiseExceptions then
    begin
      raise EStreamError.CreateRes(@RsStreamCannotCreateFileMapping);
    end else Exit;
  end;
  BaseAddress := MapViewOfFile(FMapping, Access, 0, 0, 0);
  if BaseAddress = nil then
  begin
    Close;
    if RaiseExceptions then
    begin
      raise EStreamError.CreateRes(@RsStreamCannotViewMapOfFile);
    end else Exit;
  end;
  Size := GetFileSize(FFileHandle, nil);
  if Size = DWORD(-1) then
  begin
    UnMapViewOfFile(BaseAddress);
    Close;
    if RaiseExceptions then
    begin
      raise EStreamError.CreateRes(@RsStreamCannotViewMapOfFile);
    end else Exit;
  end;
  SetPointer(BaseAddress, Size);
end;

constructor TFileMappingStream.Create(const FileName, MappingName: WideString;
  Mode: Longword; RaiseExceptions: Boolean);
var
  Protect, Access, Size: DWORD;
  BaseAddress: Pointer;
begin
  inherited Create;
  FFileHandle := THandle(FileOpen(FileName, FileMode));
  if FFileHandle = INVALID_HANDLE_VALUE then
  begin
    if RaiseExceptions then
    begin
      raise EStreamError.CreateResFmt(@RsStreamCannotObtainFileHandle,
        [SysErrorMessage(GetLastError)]);
    end else Exit;
  end;
  if (FileMode and $0F) = fmOpenReadWrite then
  begin
    Protect := PAGE_WRITECOPY;
    Access := FILE_MAP_COPY;
  end else
  begin
    Protect := PAGE_READONLY;
    Access := FILE_MAP_READ;
  end;
  FMapping := CreateFileMappingW(FFileHandle, nil, Protect, 0, 0, PWideChar(MappingName));
  if FMapping = 0 then
  begin
    Close;
    if RaiseExceptions then
    begin
      raise EStreamError.CreateRes(@RsStreamCannotCreateFileMapping);
    end else Exit;
  end;
  BaseAddress := MapViewOfFile(FMapping, Access, 0, 0, 0);
  if BaseAddress = nil then
  begin
    Close;
    if RaiseExceptions then
    begin
      raise EStreamError.CreateRes(@RsStreamCannotViewMapOfFile);
    end else Exit;
  end;
  Size := GetFileSize(FFileHandle, nil);
  if Size = DWORD(-1) then
  begin
    UnMapViewOfFile(BaseAddress);
    Close;
    if RaiseExceptions then
    begin
      raise EStreamError.CreateRes(@RsStreamCannotViewMapOfFile);
    end else Exit;
  end;
  SetPointer(BaseAddress, Size);
end;

destructor TFileMappingStream.Destroy;
begin
  Close;
  inherited Destroy;
end;

procedure TFileMappingStream.Close;
begin
  if Memory <> nil then
  begin
    UnMapViewOfFile(Memory);
    SetPointer(nil, 0);
  end;
  if FMapping <> 0 then
  begin
    CloseHandle(FMapping);
    FMapping := 0;
  end;
  if FFileHandle <> INVALID_HANDLE_VALUE then
  begin
    FileClose(FFileHandle);
    FFileHandle := INVALID_HANDLE_VALUE;
  end;
end;

function TFileMappingStream.Write(const Buffer; Count: Integer): Integer;
begin
  Result := 0;
  if (Size - Position) >= Count then
  begin
    Move(Buffer, Pointer(Longword(Memory) + Longword(Position))^, Count);
    Position := Position + Count;
    Result := Count;
  end;
end;

procedure TFileMappingStream.SetSize(const NewSize: Int64);
begin
  raise EStreamError.CreateRes(@RsStreamInvalidOperation);
end;

{ TMemoryPool }

const
  BUF_SIGNATURE = $62756673; //'bufs';
  SEG_SIGNATURE = $73656773; //'segs';

function CompareSegments(S1, S2: TMemoryPool.PSegment): Integer;
begin
  Result := S1^.FreeBufs - S2^.FreeBufs;
  if Result = 0 then Result := Integer(S1) - Integer(S2);
end;

constructor TMemoryPool.Create(BufferSize, BuffersInSegment, StartingSegmentCount: Integer;
  const DeletionRatio: Single; ThreadSafe, UseOperatingSystemAPIs: Boolean; ProtectionFlags: Longword);
var
  I, J: Integer;
begin
  inherited Create;

  Assert(BufferSize > 0);
  Assert(BuffersInSegment > 0);
  Assert(StartingSegmentCount > -1);
  Assert(Sign(DeletionRatio) = 1);

  FBufferSize := ForceAlignment(BufferSize, 4);
  FBufferFillBytes := FBufferSize - BufferSize;
  FBuffersInSegment := BuffersInSegment;
  FStartingSegments := StartingSegmentCount;
  FDeletionLimit := Floor32(DeletionRatio * BuffersInSegment);
  I := DivModPowerOf2Inc(FBuffersInSegment, 3);
  J := ForceAlignment(I, 4);
  FSegmentFillBytes := J - I;
  FSegmentSize := SizeOf(TSegment) + J + ((FBufferSize +
    SizeOf(TBufferHeader)) * FBuffersInSegment);
  FThreadSafe := ThreadSafe;
  FUseOSApi := UseOperatingSystemAPIs;
  FOSProtectFlags := ProtectionFlags;

  FSegments := TPtrArrayList.Create;
  FBufferPointers := TPtrArrayList.Create(FStartingSegments * 
    FBuffersInSegment);

  if ThreadSafe then FLock.Init;

  for I := 0 to FStartingSegments -1 do
  begin
    AllocateSegment;
  end;
end;

destructor TMemoryPool.Destroy;
var
  I: Integer;
begin
  for I := 0 to FSegments.Size -1 do
  begin
    FreeSegment(FSegments[I]);
  end;

  FSegments.Free;
  FBufferPointers.Free;
  
  if FThreadSafe then FLock.Delete;

  inherited Destroy;
end;

function TMemoryPool.PointerFromPool(P: Pointer): Boolean;
begin
  Result := FBufferPointers.IndexOf(Pointer(Longword(P) - 8)) <> -1;
end;

function TMemoryPool.PoolAllocMem: Pointer;
begin
  if FUseOSAPI then
  begin
    Result := VirtualAlloc(nil, FSegmentSize, MEM_COMMIT, FOSProtectFlags);
  end else
  begin
    Result := AllocMem(FSegmentSize);
  end;
end;

procedure TMemoryPool.PoolFreeMem(P: Pointer);
begin
  if FUseOSAPI then
  begin
    VirtualFree(P, FSegmentSize, MEM_RELEASE);
  end else
  begin
    FreeMem(P);
  end;
end;

procedure TMemoryPool.GetPoolInfo(out AllocatedTotal: Integer;
  out FreeTotal: Integer; out Overhead: Integer);
begin
  AllocatedTotal := FTotalAllocated;
  FreeTotal := FTotalFree;
  Overhead := FOverhead;
end;

procedure TMemoryPool.AllocateSegment;
var
  Segment: PSegment;
  I: Integer;
  P: PBufferHeader;
begin
  AtomicAdd(@FTotalAllocated, FSegmentSize);
  AtomicAdd(@FTotalFree, FBufferSize * FBuffersInSegment);
  AtomicAdd(@FOverhead, FSegmentSize - ((FBufferSize - FBufferFillBytes) * FBuffersInSegment));

  Segment := PoolAllocMem;
  Segment^.Signature := SEG_SIGNATURE;
  Segment^.FreeBufs := FBuffersInSegment;
  Segment^.BitMask := Pointer(Longword(Segment) + SizeOf(TSegment));
  Segment^.Buffers := Pointer(Longword(Segment) + SizeOf(TSegment) +
    Longword(DivModPowerOf2Inc(FBuffersInSegment, 3)) + Longword(FSegmentFillBytes));

  SetBits(Segment^.BitMask, 0, FBuffersInSegment - 1);

  FBufferPointers.Sorted := False;
  P := Segment^.Buffers;

  for I := 0 to FBuffersInSegment -1 do
  begin
    P^.Signature := BUF_SIGNATURE;
    P^.Index := I;
    FBufferPointers.Add(P);
    Inc(PByte(P), SizeOf(TBufferHeader) + FBufferSize);
  end;

  FBufferPointers.Sorted := True;

  AtomicAdd(@FFreeBuffers, FBuffersInSegment);
  AtomicInc(@FSegmentCount);

  FSegments.Add(Segment);
  FSegments.CustomSort(@CompareSegments);
end;

procedure TMemoryPool.FreeSegment(Segment: PSegment);
begin
  Assert(Segment <> nil);
  Assert(Segment^.FreeBufs = FBuffersInSegment);
  Assert(Segment^.Signature = SEG_SIGNATURE);

  PoolFreeMem(Segment);
end;

function TMemoryPool.Allocate: Pointer;
var
  Segment: PSegment;
  Buf: PBufferHeader;
  I: Integer;
begin
  if FThreadSafe then FLock.Enter;
  try
    if FFreeBuffers = 0 then
    begin
      if FDeletionCandidate <> nil then
      begin
        { we'll reuse the deletion candidate }
        FSegments.Insert(0, FDeletionCandidate);
        FDeletionCandidate := nil;
        AtomicAdd(@FFreeBuffers, FBuffersInSegment);
        AtomicInc(@FSegmentCount);
      end else AllocateSegment;
    end;

    Assert(FFreeBuffers <> 0);

    Segment := FSegments[0];

    Assert(Segment^.Signature = SEG_SIGNATURE);

    I := SetBitScanForward(Segment^.BitMask, 0, FBuffersInSegment - 1);
    Buf := Pointer(Longword(Segment^.Buffers) + Longword(I) * (SizeOf(TBufferHeader) + 
      Longword(FBufferSize)));
    Assert(Buf^.Signature = BUF_SIGNATURE);
    AtomicDec(@Segment^.FreeBufs);
    ResetBit(@Segment^.BitMask, I);
    AtomicDec(@FFreeBuffers);

    if Segment^.FreeBufs = 0 then FSegments.CustomSort(@CompareSegments);

    Result := Pointer(Longword(Buf) + SizeOf(TBufferHeader));
  finally
    if FThreadSafe then FLock.Leave;
  end;
end;

procedure TMemoryPool.FreePtr(P: Pointer);
var
  Segment: PSegment;
  Buf: PBufferHeader;
begin
  Assert(P <> nil);
  Assert(PointerFromPool(P));

  if FThreadSafe then FLock.Enter;
  try
    Buf := PBufferHeader(Longword(P) - 8);
    Assert(Buf^.Signature = BUF_SIGNATURE);

    Segment := Pointer(Buf);

    Dec(PByte(Segment), FSegmentSize - ((FBuffersInSegment - Buf^.Index) *
      (SizeOf(TBufferHeader) + FBufferSize)));

    Assert(Segment^.Signature = SEG_SIGNATURE);
    SetBit(Segment^.BitMask, Buf^.Index);
    AtomicInc(@Segment^.FreeBufs);
    AtomicInc(@FFreeBuffers);

    if (FDeletionCandidate = nil) and (Segment^.FreeBufs = FBuffersInSegment) and
       (FSegmentCount > FStartingSegments) then
    begin
      FDeletionCandidate := Segment;
      FSegments.Remove(FDeletionCandidate);
      AtomicDec(@FSegmentCount);
      AtomicSub(@FFreeBuffers, FBuffersInSegment);
    end; 

    if (FDeletionCandidate <> nil) and (FFreeBuffers >= FDeletionLimit) then
    begin
      FreeSegment(FDeletionCandidate);
      FDeletionCandidate := nil;
    end;
  finally
    if FThreadSafe then FLock.Leave;
  end;
end;

{ TBitArray }

const
  COMPRESS_COUNT  = MAXWORD;
  COMPRESS_SIZE   = SizeOf(Word);

constructor TBitArray.Create(Capacity: Integer);
begin
  inherited Create;
  SetLength(FBuffer, ForceAlignment(Capacity, 16));
end;

constructor TBitArray.Create(Source: TBitArray);
begin
  Create(Source.FCapacity);
  FBuffer := Source.FBuffer;
  FIndices := Source.FIndices;
  FCompressed := Source.FCompressed;
  FCount := Source.FCount;
  FBitSeg := Source.FBitSeg;
end;

constructor TBitArray.Create(Buf: Pointer; Size: Integer);
begin
  Create(ForceAlignment(Size, 16));
  FCount := Size;
  Move(Buf^, FBuffer[0], Size);
end;

function TBitArray.GetBit(Index: Integer): Boolean;
begin
  if not FCompressed then
  begin
    if (Index > -1) and (Index < FCount) then
    begin
      asm
        MOV EDX, Index
        MOV EAX, [Self].TBitArray.FBuffer
        BT [EAX], EDX
        SETC Result
      end;
    end;
  end else Result := GetBitCompressed(Index);
end;

(*
	int nDesLen = 0, nDesByte = nBit/8;
	if(nSrcLen > 0)
	{
		int nByte = 1, nRunLength = 0;
		while(nByte < nSrcLen)
			if(src[nByte] == 0 || src[nByte] == 0xff)
			{
				nRunLength = *(COMPRESS_TYPE* )(src+nByte+1);
				if(nDesLen+nRunLength > nDesByte)
					return src[nByte] == 0xff;
				nDesLen += nRunLength;
				nByte += COMPRESS_SIZE+1;
			}
			else
			{
				if(nDesLen++ == nDesByte)
					return GetBit(src+nByte, nBit&7);
				nByte++;
			}
	}
	return false;

*)

function TBitArray.GetBitCompressed(Index: Integer): Boolean;
var
  DstLen: Integer;
  SrcLen: Integer;
  ByteLen: Integer;
  RunLen: Integer;
  DstByte: Integer;
  P: Pointer;
begin
  if FCount <> 0 then
  begin
    DstLen := 0;
    DstByte := Index div 8;
    SrcLen := FCount;
    ByteLen := 1;
    while ByteLen < SrcLen do
    begin
      if (FBuffer[ByteLen] = 0) or (FBuffer[ByteLen] = $FF) then
      begin
        RunLen := PWord(@FBuffer[ByteLen+1])^;
        if DstLen + RunLen > DstByte then
        begin
          Result := FBuffer[ByteLen] = $FF;
          Exit;
        end;
        Inc(DstLen, RunLen);
        Inc(ByteLen, COMPRESS_SIZE + 1);
      end else
      begin
        if DstLen = DstByte then
        begin
          P := @FBuffer[ByteLen];
          asm
            MOV EDX, Index
            MOV EAX, P
            AND EDX, 7
            BT [EAX], EDX
            SETC Result
          end;
          Exit;
        end else
        begin
          Inc(DstLen);
          Inc(ByteLen);
        end;
      end;
    end;
  end;
  Result := False;
end;

procedure TBitArray.Grow;
begin
  if FCapacity = 0 then
  begin
    FCapacity := 16
  end else
  begin
    Inc(FCapacity, FCapacity shr 2);
  end;
  SetLength(FBuffer, FCapacity);
end;

procedure TBitArray.SetCompressed(Value: Boolean);
begin
  if Value <> FCompressed then
  begin
    FCompressed := Value;
    if Value then Compress else Decompress;
  end;
end;

procedure TBitArray.SetBit(Index: Integer; Value: Boolean);
begin
  if not FCompressed then
  begin
    if (Index > -1) and (Index < FCount) then
    begin
      if Value then
      begin
        asm
          MOV EDX, Index
          MOV EAX, [Self].TBitArray.FBuffer
          BTS [EAX], EDX
        end;
      end else
      begin
        asm
          MOV EDX, Index
          MOV EAX, [Self].TBitArray.FBuffer
          BTR [EAX], EDX
        end;
      end;
    end;
  end else SetBitCompressed(Index, Value);
end;

procedure TBitArray.SetBitCompressed(Index: Integer; Value: Boolean);
begin
end;

procedure TBitArray.SetCount(NewCount: Integer);
begin
  FCount := NewCount;
  while FCount > FCapacity do Grow;
end;

class procedure TBitArray.CompressBits(const Src: TByteDynArray;
  out Dst: TByteDynArray);
var
  Len: Integer;
  DstLen: Integer;
  SrcLen: Integer;
  RunLen: Integer;
  ByteLen: Integer;
  BT: Byte;
begin
  DstLen := 1;
  SrcLen := Length(Src);
  while (SrcLen <> 0) and (Src[SrcLen-1] = 0) do Dec(SrcLen);

  if SrcLen = 0 then
  begin
    Dst := nil;
    Exit;
  end;

  Len := SrcLen;
  SetLength(Dst, Len);
  ByteLen := 1;
  Dst[0] := 1;
  while ByteLen < SrcLen do
  begin
    if DstLen + 5 > Len then
    begin
      Inc(Len, 1024);
      SetLength(Dst, Len);
    end;

    BT := Src[ByteLen];
    Dst[DstLen] := BT;
    Inc(ByteLen);
    Inc(DstLen);

    if (BT = 0) or (BT = $FF) then
    begin
      RunLen := 1;
      while (RunLen < COMPRESS_COUNT) and (ByteLen < SrcLen) and
            (Src[ByteLen] = BT) do
      begin
        Inc(RunLen);
        Inc(ByteLen);
      end;

      PWord(@Dst[DstLen])^ := RunLen;
      Inc(DstLen, COMPRESS_SIZE);
    end;
  end;
end;

class procedure TBitArray.DecompressBits(const Src: TByteDynArray;
  out Dst: TByteDynArray; MaxLen: Integer);
var
  SrcLen: Integer;
  DstLen: Integer;
  RunLen: Integer;
  ByteLen: Integer;
  Len: Integer;
  BT: Byte;
begin
  SrcLen := Length(Src);
  if SrcLen = 0 then Exit;

  DstLen := 0;
  Len := SrcLen;
  ByteLen := 1;
  SetLength(Dst, Len);
  while (ByteLen < SrcLen) and ((MaxLen = -1) or (DstLen < MaxLen)) do
  begin
    if (Src[ByteLen] = 0) or (Src[ByteLen] = $FF) then
    begin
      BT := Src[ByteLen];
      Inc(ByteLen);
      RunLen := PWord(@Src[ByteLen])^;
      if DstLen + RunLen + 10 >= Len then
      begin
        Len := DstLen + RunLen + 1024;
        SetLength(Dst, Len);
      end;

      if BT = 0 then
      begin
        FillChar(Dst[DstLen], BT, RunLen);
      end;
      Inc(DstLen, RunLen);
    end else
    begin
      if DstLen + 10 >= Len then
      begin
        Len := DstLen + 1024;
        SetLength(Dst, Len);
      end;
      Dst[DstLen] := Src[ByteLen];
      Inc(DstLen);
      Inc(ByteLen);
    end;
  end;
  SetLength(Dst, DstLen);
end;

procedure TBitArray.Compress;
var
  OutBuf: TByteDynArray;
begin
  CompressBits(FBuffer, OutBuf);
  FBuffer := OutBuf;
  FCount := Length(FBuffer);
end;

procedure TBitArray.Decompress;
var
  OutBuf: TByteDynArray;
begin
  DecompressBits(FBuffer, OutBuf);
  FBuffer := OutBuf;
  FCount := Length(FBuffer);
end;

{ TWideFileStream }

constructor TWideFileStream.Create(const AFileName: WideString; Mode: Word);
begin
{$IFDEF MSWINDOWS}
  Create(AFilename, Mode, 0);
{$ELSE}
  Create(AFilename, Mode, FileAccessRights);
{$ENDIF}
end;

constructor TWideFileStream.Create(const AFileName: WideString; Mode: Word;
  Rights: Cardinal);
begin
  if Mode = fmCreate then
  begin
    inherited Create(WideFileCreate(AFileName, Rights));
    if FHandle < 0 then
      raise EFCreateError.CreateResFmt(@SFCreateErrorEx, [WideExpandFileName(AFileName), SysErrorMessage(GetLastError)]);
  end else
  begin
    inherited Create(WideFileOpen(AFileName, Mode));
    if FHandle < 0 then
      raise EFOpenError.CreateResFmt(@SFOpenErrorEx, [WideExpandFileName(AFileName), SysErrorMessage(GetLastError)]);
  end;
  FFileName := AFileName;
end;

destructor TWideFileStream.Destroy;
begin
  CloseHandle(FHandle);
  inherited Destroy;
end;

{ TCachedStream }

constructor TCachedStream.Create(DataSource: TStream; ReadCacheSize,
  WriteCacheSize: Integer; OwnsStream: Boolean);
begin
  FInnerStream := DataSource;

  if ReadCacheSize < 0 then ReadCacheSize := 8192;
  if WriteCacheSize < 0 then WriteCacheSize := 8192;

  SetLength(FReadCache, ReadCacheSize);
  FReadCacheSize := ReadCacheSize;
  SetLength(FWriteCache, WriteCacheSize);
  FWriteCacheSize := WriteCacheSize;

  FOwnsStream := OwnsStream;
end;

destructor TCachedStream.Destroy;
begin
  if FFlushPending then FlushWriteBuffer;
  if FOwnsStream then FInnerStream.Free;

  inherited Destroy;
end;

procedure TCachedStream.FlushWriteBuffer;
begin
  FInnerStream.Write(FWriteCache[0], FWriteCacheFilled);
  FWriteCacheFilled := 0;
  FFlushPending := False;
end;

function TCachedStream.GetSize: Int64;
begin
  Result := FSize;
end;

function TCachedStream.Read(var Buffer; Count: Integer): Longint;
var
  I: Integer;
  P: PByte absolute Buffer;
begin
  if Count <= 0 then
  begin
    Result := 0;
    Exit;
  end;
  
  if FFlushPending then FlushWriteBuffer;

  I := FReadCacheFilled - FReadCachePos;
  if I >= Count then
  begin
    Move(FReadCache[FReadCachePos], Buffer, Count);
    Inc(FReadCachePos, Count);
    Inc(FPosition, Count);
    Result := Count;
  end else if FReadCacheSize <> 0 then
  begin
    Move(FReadCache[FReadCachePos], Buffer, I);
    Inc(P, I);
    Dec(Count, I);
    Result := I;
    FReadCacheFilled := FInnerStream.Read(FReadCache[0], FReadCacheSize);
    I := Min(Count, FReadCacheFilled);
    Move(FReadCache[0], P^, I);
    FReadCachePos := I;
    Inc(Result, I);
    Inc(FPosition, Result);
  end else
  begin
    Result := FInnerStream.Read(Buffer, Count);
    Inc(FPosition, Result);
  end;
end;

function TCachedStream.Write(const Buffer; Count: Integer): Longint;
begin
  if Count <= 0 then
  begin
    Result := 0;
    Exit;
  end;

  if FWriteCacheFilled + Count <= FWriteCacheSize then
  begin
    Move(Buffer, FWriteCache[FWriteCacheFilled], Count);
    Inc(FWriteCacheFilled, Count);
    FFlushPending := True;
    Result := Count;
  end else
  begin
    if FFlushPending then FlushWriteBuffer;
    Result := FInnerStream.Write(Buffer, Count);
  end;

  Inc(FPosition, Result);
  if FPosition > FSize then FSize := FPosition;
end;

function TCachedStream.Seek(Offset: Integer; Origin: Word): Longint;
begin
  if (Offset = 0) and (Origin = soFromCurrent) then
  begin
    Result := FPosition;
  end else
  begin
    if FFlushPending then FlushWriteBuffer;
    Result := FInnerStream.Seek(Offset, Origin);
    FPosition := Result;
    // Read cache will get thrashed
    FReadCacheFilled := 0;
    FReadCachePos := 0;
  end;
end;

function TCachedStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  if (Offset = 0) and (Origin = soCurrent) then
  begin
    Result := FPosition;
  end else
  begin
    if FFlushPending then FlushWriteBuffer;
    Result := FInnerStream.Seek(Offset, Origin);
    FPosition := Result;
  end;
end;

procedure TCachedStream.SetSize(NewSize: Integer);
begin
  if FFlushPending then FlushWriteBuffer;
  FInnerStream.Size := NewSize;
  FSize := FInnerStream.Size;
end;

procedure TCachedStream.SetSize(const NewSize: Int64);
begin
  if FFlushPending then FlushWriteBuffer;
  FInnerStream.Size := NewSize;
  FSize := FInnerStream.Size;
end;

end.
