{*------------------------------------------------------------------------------
  Shared Win32 API Header File
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright JEDI Team
  @Author JEDI Team
  @Changes Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
{$I windefines.inc}
{$DEFINE WIN2K}
unit API.Win.NtApi platform;

interface

{$WEAKPACKAGEUNIT}

uses
  API.Win.Types,
  API.Win.NtCommon,
  API.Win.NtStatus,
  API.Win.Kernel;

type
  _CLIENT_ID = record
    UniqueProcess: HANDLE;
    UniqueThread: HANDLE;
  end;
  CLIENT_ID = _CLIENT_ID;
  PCLIENT_ID = ^CLIENT_ID;
  TClientID = CLIENT_ID;
  PClientID = ^TClientID;

  KPRIORITY = LONG;

  _KWAIT_REASON = (
    Executive,
    FreePage,
    PageIn,
    PoolAllocation,
    DelayExecution,
    Suspended,
    UserRequest,
    WrExecutive,
    WrFreePage,
    WrPageIn,
    WrPoolAllocation,
    WrDelayExecution,
    WrSuspended,
    WrUserRequest,
    WrEventPair,
    WrQueue,
    WrLpcReceive,
    WrLpcReply,
    WrVirtualMemory,
    WrPageOut,
    WrRendezvous,
    Spare2,
    Spare3,
    Spare4,
    Spare5,
    Spare6,
    WrKernel,
    MaximumWaitReason);
  KWAIT_REASON = _KWAIT_REASON;
  TKWaitReason = KWAIT_REASON;

  _VM_COUNTERS = record
    PeakVirtualSize: SIZE_T;
    VirtualSize: SIZE_T;
    PageFaultCount: ULONG;
    PeakWorkingSetSize: SIZE_T;
    WorkingSetSize: SIZE_T;
    QuotaPeakPagedPoolUsage: SIZE_T;
    QuotaPagedPoolUsage: SIZE_T;
    QuotaPeakNonPagedPoolUsage: SIZE_T;
    QuotaNonPagedPoolUsage: SIZE_T;
    PagefileUsage: SIZE_T;
    PeakPagefileUsage: SIZE_T;
  end;
  VM_COUNTERS = _VM_COUNTERS;
  PVM_COUNTERS = ^VM_COUNTERS;
  TVmCounters = VM_COUNTERS;
  PVmCounters = ^TVmCounters;

const
  NonPagedPool = 0;
  PagedPool = 1;
  NonPagedPoolMustSucceed = 2;
  DontUseThisType = 3;
  NonPagedPoolCacheAligned = 4;
  PagedPoolCacheAligned = 5;
  NonPagedPoolCacheAlignedMustS = 6;
  MaxPoolType = 7;
  NonPagedPoolSession = 32;
  PagedPoolSession = NonPagedPoolSession + 1;
  NonPagedPoolMustSucceedSession = PagedPoolSession + 1;
  DontUseThisTypeSession = NonPagedPoolMustSucceedSession + 1;
  NonPagedPoolCacheAlignedSession = DontUseThisTypeSession + 1;
  PagedPoolCacheAlignedSession = NonPagedPoolCacheAlignedSession + 1;
  NonPagedPoolCacheAlignedMustSSession = PagedPoolCacheAlignedSession + 1;

type
  POOL_TYPE = NonPagedPool..NonPagedPoolCacheAlignedMustSSession;

  _IO_STATUS_BLOCK = record
    //union {
    Status: NTSTATUS;
    //    PVOID Pointer;
    //}
    Information: ULONG_PTR;
  end;
  IO_STATUS_BLOCK = _IO_STATUS_BLOCK;
  PIO_STATUS_BLOCK = ^IO_STATUS_BLOCK;
  TIoStatusBlock = IO_STATUS_BLOCK;
  PIoStatusBlock = ^TIoStatusBlock;

const
  ViewShare = 1;
  ViewUnmap = 2;

type
  SECTION_INHERIT = ViewShare..ViewUnmap;

  _THREADINFOCLASS = (
    ThreadBasicInformation,
    ThreadTimes,
    ThreadPriority,
    ThreadBasePriority,
    ThreadAffinityMask,
    ThreadImpersonationToken,
    ThreadDescriptorTableEntry,
    ThreadEnableAlignmentFaultFixup,
    ThreadEventPair_Reusable,
    ThreadQuerySetWin32StartAddress,
    ThreadZeroTlsCell,
    ThreadPerformanceCount,
    ThreadAmILastThread,
    ThreadIdealProcessor,
    ThreadPriorityBoost,
    ThreadSetTlsArrayAddress,
    ThreadIsIoPending,
    ThreadHideFromDebugger,
    ThreadBreakOnTermination, // was added in XP - used by RtlSetThreadIsCritical()
    MaxThreadInfoClass);
  THREADINFOCLASS = _THREADINFOCLASS;
  THREAD_INFORMATION_CLASS = THREADINFOCLASS;
  TThreadInfoClass = THREADINFOCLASS;

  KAFFINITY = ULONG;
  PKAFFINITY = ^KAFFINITY;

  PKNORMAL_ROUTINE = procedure(NormalContext, SystemArgument1, SystemArgument2: PVOID); stdcall;

  _PROCESSINFOCLASS = (
    ProcessBasicInformation,
    ProcessQuotaLimits,
    ProcessIoCounters,
    ProcessVmCounters,
    ProcessTimes,
    ProcessBasePriority,
    ProcessRaisePriority,
    ProcessDebugPort,
    ProcessExceptionPort,
    ProcessAccessToken,
    ProcessLdtInformation,
    ProcessLdtSize,
    ProcessDefaultHardErrorMode,
    ProcessIoPortHandlers, // Note: this is kernel mode only
    ProcessPooledUsageAndLimits,
    ProcessWorkingSetWatch,
    ProcessUserModeIOPL,
    ProcessEnableAlignmentFaultFixup,
    ProcessPriorityClass,
    ProcessWx86Information,
    ProcessHandleCount,
    ProcessAffinityMask,
    ProcessPriorityBoost,
    ProcessDeviceMap,
    ProcessSessionInformation,
    ProcessForegroundInformation,
    ProcessWow64Information, // = 26
    ProcessImageFileName, // added after W2K
    ProcessLUIDDeviceMapsEnabled,
    ProcessBreakOnTermination, // used by RtlSetProcessIsCritical()
    ProcessDebugObjectHandle,
    ProcessDebugFlags,
    ProcessHandleTracing,
    MaxProcessInfoClass);
  PROCESSINFOCLASS = _PROCESSINFOCLASS;
  PROCESS_INFORMATION_CLASS = PROCESSINFOCLASS;
  TProcessInfoClass = PROCESSINFOCLASS;

  _KPROFILE_SOURCE = (
    ProfileTime,
    ProfileAlignmentFixup,
    ProfileTotalIssues,
    ProfilePipelineDry,
    ProfileLoadInstructions,
    ProfilePipelineFrozen,
    ProfileBranchInstructions,
    ProfileTotalNonissues,
    ProfileDcacheMisses,
    ProfileIcacheMisses,
    ProfileCacheMisses,
    ProfileBranchMispredictions,
    ProfileStoreInstructions,
    ProfileFpInstructions,
    ProfileIntegerInstructions,
    Profile2Issue,
    Profile3Issue,
    Profile4Issue,
    ProfileSpecialInstructions,
    ProfileTotalCycles,
    ProfileIcacheIssues,
    ProfileDcacheAccesses,
    ProfileMemoryBarrierCycles,
    ProfileLoadLinkedIssues,
    ProfileMaximum);
  KPROFILE_SOURCE = _KPROFILE_SOURCE;
  TKProfileSource = KPROFILE_SOURCE;

  PIO_APC_ROUTINE = procedure(ApcContext: PVOID; IoStatusBlock: PIO_STATUS_BLOCK; Reserved: ULONG); stdcall;

  _FILE_FULL_EA_INFORMATION = record
    NextEntryOffset: ULONG;
    Flags: UCHAR;
    EaNameLength: UCHAR;
    EaValueLength: USHORT;
    EaName: array[0..0] of CHAR;
  end;
  FILE_FULL_EA_INFORMATION = _FILE_FULL_EA_INFORMATION;
  PFILE_FULL_EA_INFORMATION = ^FILE_FULL_EA_INFORMATION;
  TFileFullEaInformation = FILE_FULL_EA_INFORMATION;
  PFileFullEaInformation = ^TFileFullEaInformation;

  _FSINFOCLASS = (
    FileFsFiller0,
    FileFsVolumeInformation, // 1
    FileFsLabelInformation, // 2
    FileFsSizeInformation, // 3
    FileFsDeviceInformation, // 4
    FileFsAttributeInformation, // 5
    FileFsControlInformation, // 6
    FileFsFullSizeInformation, // 7
    FileFsObjectIdInformation, // 8
    FileFsMaximumInformation);
  FS_INFORMATION_CLASS = _FSINFOCLASS;
  PFS_INFORMATION_CLASS = ^FS_INFORMATION_CLASS;
  TFsInformationClass = FS_INFORMATION_CLASS;
  PFsInformationClass = ^TFsInformationClass;

  UUID = GUID;

  _FILE_BASIC_INFORMATION = record
    CreationTime: LARGE_INTEGER;
    LastAccessTime: LARGE_INTEGER;
    LastWriteTime: LARGE_INTEGER;
    ChangeTime: LARGE_INTEGER;
    FileAttributes: ULONG;
  end;
  FILE_BASIC_INFORMATION = _FILE_BASIC_INFORMATION;
  PFILE_BASIC_INFORMATION = ^FILE_BASIC_INFORMATION;
  TFileBasicInformation = FILE_BASIC_INFORMATION;
  PFileBasicInformation = ^TFileBasicInformation;

  _FILE_NETWORK_OPEN_INFORMATION = record
    CreationTime: LARGE_INTEGER;
    LastAccessTime: LARGE_INTEGER;
    LastWriteTime: LARGE_INTEGER;
    ChangeTime: LARGE_INTEGER;
    AllocationSize: LARGE_INTEGER;
    EndOfFile: LARGE_INTEGER;
    FileAttributes: ULONG;
  end;
  FILE_NETWORK_OPEN_INFORMATION = _FILE_NETWORK_OPEN_INFORMATION;
  PFILE_NETWORK_OPEN_INFORMATION = ^FILE_NETWORK_OPEN_INFORMATION;
  TFileNetworkOpenInformation = FILE_NETWORK_OPEN_INFORMATION;
  PFileNetworkOpenInformation = ^TFileNetworkOpenInformation;

  _FILE_INFORMATION_CLASS = (
    FileFiller0,
    FileDirectoryInformation, // 1
    FileFullDirectoryInformation, // 2
    FileBothDirectoryInformation, // 3
    FileBasicInformation, // 4  wdm
    FileStandardInformation, // 5  wdm
    FileInternalInformation, // 6
    FileEaInformation, // 7
    FileAccessInformation, // 8
    FileNameInformation, // 9
    FileRenameInformation, // 10
    FileLinkInformation, // 11
    FileNamesInformation, // 12
    FileDispositionInformation, // 13
    FilePositionInformation, // 14 wdm
    FileFullEaInformation, // 15
    FileModeInformation, // 16
    FileAlignmentInformation, // 17
    FileAllInformation, // 18
    FileAllocationInformation, // 19
    FileEndOfFileInformation, // 20 wdm
    FileAlternateNameInformation, // 21
    FileStreamInformation, // 22
    FilePipeInformation, // 23
    FilePipeLocalInformation, // 24
    FilePipeRemoteInformation, // 25
    FileMailslotQueryInformation, // 26
    FileMailslotSetInformation, // 27
    FileCompressionInformation, // 28
    FileObjectIdInformation, // 29
    FileCompletionInformation, // 30
    FileMoveClusterInformation, // 31
    FileQuotaInformation, // 32
    FileReparsePointInformation, // 33
    FileNetworkOpenInformation, // 34
    FileAttributeTagInformation, // 35
    FileTrackingInformation, // 36
    FileMaximumInformation);
  FILE_INFORMATION_CLASS = _FILE_INFORMATION_CLASS;
  PFILE_INFORMATION_CLASS = ^FILE_INFORMATION_CLASS;
  TFileInformationClass = FILE_INFORMATION_CLASS;
  PFileInformationClass = ^TFileInformationClass;

  _FILE_STANDARD_INFORMATION = record
    AllocationSize: LARGE_INTEGER;
    EndOfFile: LARGE_INTEGER;
    NumberOfLinks: ULONG;
    DeletePending: ByteBool;
    Directory: ByteBool;
  end;
  FILE_STANDARD_INFORMATION = _FILE_STANDARD_INFORMATION;
  PFILE_STANDARD_INFORMATION = ^FILE_STANDARD_INFORMATION;
  TFileStandardInformation = FILE_STANDARD_INFORMATION;
  PFileStandardInformation = ^TFileStandardInformation;

  _FILE_POSITION_INFORMATION = record
    CurrentByteOffset: LARGE_INTEGER;
  end;
  FILE_POSITION_INFORMATION = _FILE_POSITION_INFORMATION;
  PFILE_POSITION_INFORMATION = ^FILE_POSITION_INFORMATION;
  TFilePositionInformation = FILE_POSITION_INFORMATION;
  PFilePositionInformation = ^TFilePositionInformation;

  _FILE_ALIGNMENT_INFORMATION = record
    AlignmentRequirement: ULONG;
  end;
  FILE_ALIGNMENT_INFORMATION = _FILE_ALIGNMENT_INFORMATION;
  PFILE_ALIGNMENT_INFORMATION = ^FILE_ALIGNMENT_INFORMATION;
  TFileAlignmentInformation = FILE_ALIGNMENT_INFORMATION;
  PFileAlignmentInformation = ^TFileAlignmentInformation;

  _KEY_SET_INFORMATION_CLASS = (KeyWriteTimeInformation);
  KEY_SET_INFORMATION_CLASS = _KEY_SET_INFORMATION_CLASS;

  _KEY_INFORMATION_CLASS = (
    KeyBasicInformation,
    KeyNodeInformation,
    KeyFullInformation,
    KeyNameInformation);
  KEY_INFORMATION_CLASS = _KEY_INFORMATION_CLASS;
  TKeyInformationClass = KEY_INFORMATION_CLASS;

  _KEY_VALUE_INFORMATION_CLASS = (
    KeyValueBasicInformation,
    KeyValueFullInformation,
    KeyValuePartialInformation,
    KeyValueFullInformationAlign64,
    KeyValuePartialInformationAlign64);
  KEY_VALUE_INFORMATION_CLASS = _KEY_VALUE_INFORMATION_CLASS;
  TKeyValueInformationClass = KEY_VALUE_INFORMATION_CLASS;

  _KEY_VALUE_ENTRY = record
    ValueName: PUNICODE_STRING;
    DataLength: ULONG;
    DataOffset: ULONG;
    Type_: ULONG;
  end;
  KEY_VALUE_ENTRY = _KEY_VALUE_ENTRY;
  PKEY_VALUE_ENTRY = ^KEY_VALUE_ENTRY;
  TKeyValueEntry = KEY_VALUE_ENTRY;
  PKeyValueEntry = ^TKeyValueEntry;

  _DEVICE_POWER_STATE = (
    PowerDeviceUnspecified,
    PowerDeviceD0,
    PowerDeviceD1,
    PowerDeviceD2,
    PowerDeviceD3,
    PowerDeviceMaximum);
  DEVICE_POWER_STATE = _DEVICE_POWER_STATE;
  PDEVICE_POWER_STATE = ^DEVICE_POWER_STATE;
  TDevicePowerState = DEVICE_POWER_STATE;

  POWER_ACTION = (
    PowerActionNone,
    PowerActionReserved,
    PowerActionSleep,
    PowerActionHibernate,
    PowerActionShutdown,
    PowerActionShutdownReset,
    PowerActionShutdownOff,
    PowerActionWarmEject);
  PPOWER_ACTION = ^POWER_ACTION;
  TPowerAction = POWER_ACTION;

  _SYSTEM_POWER_STATE = (
    PowerSystemUnspecified,
    PowerSystemWorking,
    PowerSystemSleeping1,
    PowerSystemSleeping2,
    PowerSystemSleeping3,
    PowerSystemHibernate,
    PowerSystemShutdown,
    PowerSystemMaximum);
  SYSTEM_POWER_STATE = _SYSTEM_POWER_STATE;
  PSYSTEM_POWER_STATE = ^SYSTEM_POWER_STATE;
  TSystemPowerState = SYSTEM_POWER_STATE;

  POWER_INFORMATION_LEVEL = (
    SystemPowerPolicyAc,
    SystemPowerPolicyDc,
    VerifySystemPolicyAc,
    VerifySystemPolicyDc,
    SystemPowerCapabilities,
    SystemBatteryState,
    SystemPowerStateHandler,
    ProcessorStateHandler,
    SystemPowerPolicyCurrent,
    AdministratorPowerPolicy,
    SystemReserveHiberFile,
    ProcessorInformation,
    SystemPowerInformation);
  TPowerInformationLevel = POWER_INFORMATION_LEVEL;

  _RTL_RANGE = record
    // The start of the range
    Start: ULONGLONG; // Read only
    // The end of the range
    End_: ULONGLONG; // Read only
    // Data the user passed in when they created the range
    UserData: PVOID; // Read/Write
    // The owner of the range
    Owner: PVOID; // Read/Write
    // User defined flags the user specified when they created the range
    Attributes: UCHAR; // Read/Write
    // Flags (RTL_RANGE_*)
    Flags: UCHAR; // Read only
  end;
  RTL_RANGE = _RTL_RANGE;
  PRTL_RANGE = ^RTL_RANGE;
  TRtlRange = RTL_RANGE;
  PRtlRange = ^TRtlRange;

const
  RTL_RANGE_SHARED = $01;
  RTL_RANGE_CONFLICT = $02;

type
  _RTL_RANGE_LIST = record
    // The list of ranges
    ListHead: LIST_ENTRY;
    // These always come in useful
    Flags: ULONG; // use RANGE_LIST_FLAG_*
    // The number of entries in the list
    Count: ULONG;
    // Every time an add/delete operation is performed on the list this is
    // incremented.  It is checked during iteration to ensure that the list
    // hasn't changed between GetFirst/GetNext or GetNext/GetNext calls
    Stamp: ULONG;
  end;
  RTL_RANGE_LIST = _RTL_RANGE_LIST;
  PRTL_RANGE_LIST = ^RTL_RANGE_LIST;
  TRtlRangeList = RTL_RANGE_LIST;
  PRtlRangeList = ^TRtlRangeList;

  _RANGE_LIST_ITERATOR = record
    RangeListHead: PLIST_ENTRY;
    MergedHead: PLIST_ENTRY;
    Current: PVOID;
    Stamp: ULONG;
  end;
  RTL_RANGE_LIST_ITERATOR = _RANGE_LIST_ITERATOR;
  PRTL_RANGE_LIST_ITERATOR = ^RTL_RANGE_LIST_ITERATOR;
  TRtlRangeListIterator = RTL_RANGE_LIST_ITERATOR;
  PRtlRangeListIterator = ^TRtlRangeListIterator;

// End of NTDDK.H

//==============================================================================
// NT System Services
//==============================================================================

type
  _SYSTEM_INFORMATION_CLASS = (
    SystemBasicInformation,
    SystemProcessorInformation,
    SystemPerformanceInformation,
    SystemTimeOfDayInformation,
    SystemNotImplemented1,
    SystemProcessesAndThreadsInformation,
    SystemCallCounts,
    SystemConfigurationInformation,
    SystemProcessorTimes,
    SystemGlobalFlag,
    SystemNotImplemented2,
    SystemModuleInformation,
    SystemLockInformation,
    SystemNotImplemented3,
    SystemNotImplemented4,
    SystemNotImplemented5,
    SystemHandleInformation,
    SystemObjectInformation,
    SystemPagefileInformation,
    SystemInstructionEmulationCounts,
    SystemInvalidInfoClass1,
    SystemCacheInformation,
    SystemPoolTagInformation,
    SystemProcessorStatistics,
    SystemDpcInformation,
    SystemNotImplemented6,
    SystemLoadImage,
    SystemUnloadImage,
    SystemTimeAdjustment,
    SystemNotImplemented7,
    SystemNotImplemented8,
    SystemNotImplemented9,
    SystemCrashDumpInformation,
    SystemExceptionInformation,
    SystemCrashDumpStateInformation,
    SystemKernelDebuggerInformation,
    SystemContextSwitchInformation,
    SystemRegistryQuotaInformation,
    SystemLoadAndCallImage,
    SystemPrioritySeparation,
    SystemNotImplemented10,
    SystemNotImplemented11,
    SystemInvalidInfoClass2,
    SystemInvalidInfoClass3,
    SystemTimeZoneInformation,
    SystemLookasideInformation,
    SystemSetTimeSlipEvent,
    SystemCreateSession,
    SystemDeleteSession,
    SystemInvalidInfoClass4,
    SystemRangeStartInformation,
    SystemVerifierInformation,
    SystemAddVerifier,
    SystemSessionProcessesInformation);
  SYSTEM_INFORMATION_CLASS = _SYSTEM_INFORMATION_CLASS;
  TSystemInformationClass = SYSTEM_INFORMATION_CLASS;

type
  _SYSTEM_BASIC_INFORMATION = record // Information Class 0
    Unknown: ULONG;
    MaximumIncrement: ULONG;
    PhysicalPageSize: ULONG;
    NumberOfPhysicalPages: ULONG;
    LowestPhysicalPage: ULONG;
    HighestPhysicalPage: ULONG;
    AllocationGranularity: ULONG;
    LowestUserAddress: ULONG;
    HighestUserAddress: ULONG;
    ActiveProcessors: ULONG;
    NumberProcessors: UCHAR;
  end;
  SYSTEM_BASIC_INFORMATION = _SYSTEM_BASIC_INFORMATION;
  PSYSTEM_BASIC_INFORMATION = ^SYSTEM_BASIC_INFORMATION;
  TSystemBasicInformation = SYSTEM_BASIC_INFORMATION;
  PSystemBasicInformation = ^TSystemBasicInformation;

  _SYSTEM_PROCESSOR_INFORMATION = record // Information Class 1
    ProcessorArchitecture: USHORT;
    ProcessorLevel: USHORT;
    ProcessorRevision: USHORT;
    Unknown: USHORT;
    FeatureBits: ULONG;
  end;
  SYSTEM_PROCESSOR_INFORMATION = _SYSTEM_PROCESSOR_INFORMATION;
  PSYSTEM_PROCESSOR_INFORMATION = ^SYSTEM_PROCESSOR_INFORMATION;
  TSystemProcessorInformation = SYSTEM_PROCESSOR_INFORMATION;
  PSystemProcessorInformation = ^TSystemProcessorInformation;

  _SYSTEM_PERFORMANCE_INFORMATION = record // Information Class 2
    IdleTime: LARGE_INTEGER;
    ReadTransferCount: LARGE_INTEGER;
    WriteTransferCount: LARGE_INTEGER;
    OtherTransferCount: LARGE_INTEGER;
    ReadOperationCount: ULONG;
    WriteOperationCount: ULONG;
    OtherOperationCount: ULONG;
    AvailablePages: ULONG;
    TotalCommittedPages: ULONG;
    TotalCommitLimit: ULONG;
    PeakCommitment: ULONG;
    PageFaults: ULONG;
    WriteCopyFaults: ULONG;
    TransistionFaults: ULONG;
    Reserved1: ULONG;
    DemandZeroFaults: ULONG;
    PagesRead: ULONG;
    PageReadIos: ULONG;
    Reserved2: array[0..1] of ULONG;
    PagefilePagesWritten: ULONG;
    PagefilePageWriteIos: ULONG;
    MappedFilePagesWritten: ULONG;
    MappedFilePageWriteIos: ULONG;
    PagedPoolUsage: ULONG;
    NonPagedPoolUsage: ULONG;
    PagedPoolAllocs: ULONG;
    PagedPoolFrees: ULONG;
    NonPagedPoolAllocs: ULONG;
    NonPagedPoolFrees: ULONG;
    TotalFreeSystemPtes: ULONG;
    SystemCodePage: ULONG;
    TotalSystemDriverPages: ULONG;
    TotalSystemCodePages: ULONG;
    SmallNonPagedLookasideListAllocateHits: ULONG;
    SmallPagedLookasideListAllocateHits: ULONG;
    Reserved3: ULONG;
    MmSystemCachePage: ULONG;
    PagedPoolPage: ULONG;
    SystemDriverPage: ULONG;
    FastReadNoWait: ULONG;
    FastReadWait: ULONG;
    FastReadResourceMiss: ULONG;
    FastReadNotPossible: ULONG;
    FastMdlReadNoWait: ULONG;
    FastMdlReadWait: ULONG;
    FastMdlReadResourceMiss: ULONG;
    FastMdlReadNotPossible: ULONG;
    MapDataNoWait: ULONG;
    MapDataWait: ULONG;
    MapDataNoWaitMiss: ULONG;
    MapDataWaitMiss: ULONG;
    PinMappedDataCount: ULONG;
    PinReadNoWait: ULONG;
    PinReadWait: ULONG;
    PinReadNoWaitMiss: ULONG;
    PinReadWaitMiss: ULONG;
    CopyReadNoWait: ULONG;
    CopyReadWait: ULONG;
    CopyReadNoWaitMiss: ULONG;
    CopyReadWaitMiss: ULONG;
    MdlReadNoWait: ULONG;
    MdlReadWait: ULONG;
    MdlReadNoWaitMiss: ULONG;
    MdlReadWaitMiss: ULONG;
    ReadAheadIos: ULONG;
    LazyWriteIos: ULONG;
    LazyWritePages: ULONG;
    DataFlushes: ULONG;
    DataPages: ULONG;
    ContextSwitches: ULONG;
    FirstLevelTbFills: ULONG;
    SecondLevelTbFills: ULONG;
    SystemCalls: ULONG;
  end;
  SYSTEM_PERFORMANCE_INFORMATION = _SYSTEM_PERFORMANCE_INFORMATION;
  PSYSTEM_PERFORMANCE_INFORMATION = ^SYSTEM_PERFORMANCE_INFORMATION;
  TSystemPerformanceInformation = SYSTEM_PERFORMANCE_INFORMATION;
  PSystemPerformanceInformation = ^TSystemPerformanceInformation;

  _SYSTEM_TIME_OF_DAY_INFORMATION = record // Information Class 3
    BootTime: LARGE_INTEGER;
    CurrentTime: LARGE_INTEGER;
    TimeZoneBias: LARGE_INTEGER;
    CurrentTimeZoneId: ULONG;
  end;
  SYSTEM_TIME_OF_DAY_INFORMATION = _SYSTEM_TIME_OF_DAY_INFORMATION;
  PSYSTEM_TIME_OF_DAY_INFORMATION = ^SYSTEM_TIME_OF_DAY_INFORMATION;
  TSystemTimeOfDayInformation = SYSTEM_TIME_OF_DAY_INFORMATION;
  PSystemTimeOfDayInformation = ^TSystemTimeOfDayInformation;

  _IO_COUNTERSEX = record
    ReadOperationCount: LARGE_INTEGER;
    WriteOperationCount: LARGE_INTEGER;
    OtherOperationCount: LARGE_INTEGER;
    ReadTransferCount: LARGE_INTEGER;
    WriteTransferCount: LARGE_INTEGER;
    OtherTransferCount: LARGE_INTEGER;
  end;
  IO_COUNTERSEX = _IO_COUNTERSEX;
  PIO_COUNTERSEX = ^IO_COUNTERSEX;
  TIoCountersEx = IO_COUNTERSEX;
  PIoCountersEx = ^TIoCountersEx;

  THREAD_STATE = (
    StateInitialized,
    StateReady,
    StateRunning,
    StateStandby,
    StateTerminated,
    StateWait,
    StateTransition,
    StateUnknown);
  TThreadState = THREAD_STATE;

  _SYSTEM_THREADS = record
    KernelTime: LARGE_INTEGER;
    UserTime: LARGE_INTEGER;
    CreateTime: LARGE_INTEGER;
    WaitTime: ULONG;
    StartAddress: PVOID;
    ClientId: CLIENT_ID;
    Priority: KPRIORITY;
    BasePriority: KPRIORITY;
    ContextSwitchCount: ULONG;
    State: THREAD_STATE;
    WaitReason: KWAIT_REASON;
  end;
  SYSTEM_THREADS = _SYSTEM_THREADS;
  PSYSTEM_THREADS = ^SYSTEM_THREADS;
  TSystemThreads = SYSTEM_THREADS;
  PSystemThreads = PSYSTEM_THREADS;

  _SYSTEM_PROCESSES = record // Information Class 5
    NextEntryDelta: ULONG;
    ThreadCount: ULONG;
    Reserved1: array[0..5] of ULONG;
    CreateTime: LARGE_INTEGER;
    UserTime: LARGE_INTEGER;
    KernelTime: LARGE_INTEGER;
    ProcessName: UNICODE_STRING;
    BasePriority: KPRIORITY;
    ProcessId: ULONG;
    InheritedFromProcessId: ULONG;
    HandleCount: ULONG;
    // next two were Reserved2: array [0..1] of ULONG; thanks to Nico Bendlin
    SessionId: ULONG;
    Reserved2: ULONG;
    VmCounters: VM_COUNTERS;
    PrivatePageCount: ULONG;
    IoCounters: IO_COUNTERSEX; // Windows 2000 only
    Threads: array[0..0] of SYSTEM_THREADS;
  end;
  SYSTEM_PROCESSES = _SYSTEM_PROCESSES;
  PSYSTEM_PROCESSES = ^SYSTEM_PROCESSES;
  TSystemProcesses = SYSTEM_PROCESSES;
  PSystemProcesses = PSYSTEM_PROCESSES;

  _SYSTEM_CALLS_INFORMATION = record // Information Class 6
    Size: ULONG;
    NumberOfDescriptorTables: ULONG;
    NumberOfRoutinesInTable: array[0..0] of ULONG;
    // ULONG CallCounts[];
  end;
  SYSTEM_CALLS_INFORMATION = _SYSTEM_CALLS_INFORMATION;
  PSYSTEM_CALLS_INFORMATION = ^SYSTEM_CALLS_INFORMATION;
  TSystemCallsInformation = SYSTEM_CALLS_INFORMATION;
  PSystemCallsInformation = ^TSystemCallsInformation;

  _SYSTEM_CONFIGURATION_INFORMATION = record // Information Class 7
    DiskCount: ULONG;
    FloppyCount: ULONG;
    CdRomCount: ULONG;
    TapeCount: ULONG;
    SerialCount: ULONG;
    ParallelCount: ULONG;
  end;
  SYSTEM_CONFIGURATION_INFORMATION = _SYSTEM_CONFIGURATION_INFORMATION;
  PSYSTEM_CONFIGURATION_INFORMATION = ^SYSTEM_CONFIGURATION_INFORMATION;
  TSystemConfigurationInformation = SYSTEM_CONFIGURATION_INFORMATION;
  PSystemConfigurationInformation = ^TSystemConfigurationInformation;

  _SYSTEM_PROCESSOR_TIMES = record // Information Class 8
    IdleTime: LARGE_INTEGER;
    KernelTime: LARGE_INTEGER;
    UserTime: LARGE_INTEGER;
    DpcTime: LARGE_INTEGER;
    InterruptTime: LARGE_INTEGER;
    InterruptCount: ULONG;
  end;
  SYSTEM_PROCESSOR_TIMES = _SYSTEM_PROCESSOR_TIMES;
  PSYSTEM_PROCESSOR_TIMES = ^SYSTEM_PROCESSOR_TIMES;
  TSystemProcessorTimes = SYSTEM_PROCESSOR_TIMES;
  PSystemProcessorTimes = ^TSystemProcessorTimes;

  _SYSTEM_GLOBAL_FLAG = record // Information Class 9
    GlobalFlag: ULONG;
  end;
  SYSTEM_GLOBAL_FLAG = _SYSTEM_GLOBAL_FLAG;
  PSYSTEM_GLOBAL_FLAG = ^SYSTEM_GLOBAL_FLAG;
  TSystemGlobalFlag = SYSTEM_GLOBAL_FLAG;
  PSystemGlobalFlag = ^TSystemGlobalFlag;

  _SYSTEM_MODULE_INFORMATION = record // Information Class 11
    Reserved: array[0..1] of ULONG;
    Base: PVOID;
    Size: ULONG;
    Flags: ULONG;
    Index: USHORT;
    Unknown: USHORT;
    LoadCount: USHORT;
    ModuleNameOffset: USHORT;
    ImageName: array[0..255] of CHAR;
  end;
  SYSTEM_MODULE_INFORMATION = _SYSTEM_MODULE_INFORMATION;
  PSYSTEM_MODULE_INFORMATION = ^SYSTEM_MODULE_INFORMATION;
  TSystemModuleInformation = SYSTEM_MODULE_INFORMATION;
  PSystemModuleInformation = PSYSTEM_MODULE_INFORMATION;

  PSYSTEM_MODULE_INFORMATION_ARRAY = ^SYSTEM_MODULE_INFORMATION_ARRAY;
  SYSTEM_MODULE_INFORMATION_ARRAY = record
    Count: ULONG;
    Information: array[0..MAXWORD-1] of SYSTEM_MODULE_INFORMATION;
  end;

  _SYSTEM_LOCK_INFORMATION = record // Information Class 12
    Address: PVOID;
    Type_: USHORT;
    Reserved1: USHORT;
    ExclusiveOwnerThreadId: ULONG;
    ActiveCount: ULONG;
    ContentionCount: ULONG;
    Reserved2: array[0..1] of ULONG;
    NumberOfSharedWaiters: ULONG;
    NumberOfExclusiveWaiters: ULONG;
  end;
  SYSTEM_LOCK_INFORMATION = _SYSTEM_LOCK_INFORMATION;
  PSYSTEM_LOCK_INFORMATION = ^SYSTEM_LOCK_INFORMATION;
  TSystemLockInformation = SYSTEM_LOCK_INFORMATION;
  PSystemLockInformation = ^TSystemLockInformation;

  _SYSTEM_HANDLE_INFORMATION = record // Information Class 16
    ProcessId: ULONG;
    ObjectTypeNumber: UCHAR;
    Flags: UCHAR; // 0x01 = PROTECT_FROM_CLOSE, 0x02 = INHERIT
    Handle: USHORT;
    Object_: PVOID;
    GrantedAccess: ACCESS_MASK;
  end;
  SYSTEM_HANDLE_INFORMATION = _SYSTEM_HANDLE_INFORMATION;
  PSYSTEM_HANDLE_INFORMATION = ^SYSTEM_HANDLE_INFORMATION;
  TSystemHandleInformation = SYSTEM_HANDLE_INFORMATION;
  PSystemHandleInformation = ^TSystemHandleInformation;

  _SYSTEM_OBJECT_TYPE_INFORMATION = record // Information Class 17
    NextEntryOffset: ULONG;
    ObjectCount: ULONG;
    HandleCount: ULONG;
    TypeNumber: ULONG;
    InvalidAttributes: ULONG;
    GenericMapping: GENERIC_MAPPING;
    ValidAccessMask: ACCESS_MASK;
    PoolType: POOL_TYPE;
    Unknown: UCHAR;
    Name: UNICODE_STRING;
  end;
  SYSTEM_OBJECT_TYPE_INFORMATION = _SYSTEM_OBJECT_TYPE_INFORMATION;
  PSYSTEM_OBJECT_TYPE_INFORMATION = ^SYSTEM_OBJECT_TYPE_INFORMATION;
  TSystemObjectTypeInformation = SYSTEM_OBJECT_TYPE_INFORMATION;
  PSystemObjectTypeInformation = ^TSystemObjectTypeInformation;

  _SYSTEM_OBJECT_INFORMATION = record
    NextEntryOffset: ULONG;
    Object_: PVOID;
    CreatorProcessId: ULONG;
    Unknown: USHORT;
    Flags: USHORT;
    PointerCount: ULONG;
    HandleCount: ULONG;
    PagedPoolUsage: ULONG;
    NonPagedPoolUsage: ULONG;
    ExclusiveProcessId: ULONG;
    SecurityDescriptor: PSECURITY_DESCRIPTOR;
    Name: UNICODE_STRING;
  end;
  SYSTEM_OBJECT_INFORMATION = _SYSTEM_OBJECT_INFORMATION;
  PSYSTEM_OBJECT_INFORMATION = ^SYSTEM_OBJECT_INFORMATION;
  TSystemObjectInformation = SYSTEM_OBJECT_INFORMATION;
  PSystemObjectInformation = ^TSystemObjectInformation;

  _SYSTEM_PAGEFILE_INFORMATION = record // Information Class 18
    NextEntryOffset: ULONG;
    CurrentSize: ULONG;
    TotalUsed: ULONG;
    PeakUsed: ULONG;
    FileName: UNICODE_STRING;
  end;
  SYSTEM_PAGEFILE_INFORMATION = _SYSTEM_PAGEFILE_INFORMATION;
  PSYSTEM_PAGEFILE_INFORMATION = ^SYSTEM_PAGEFILE_INFORMATION;
  TSystemPageFileInformation = SYSTEM_PAGEFILE_INFORMATION;
  PSystemPageFileInformation = PSYSTEM_PAGEFILE_INFORMATION;

  _SYSTEM_INSTRUCTION_EMULATION_INFORMATION = record // Info Class 19
    GenericInvalidOpcode: ULONG;
    TwoByteOpcode: ULONG;
    ESprefix: ULONG;
    CSprefix: ULONG;
    SSprefix: ULONG;
    DSprefix: ULONG;
    FSPrefix: ULONG;
    GSprefix: ULONG;
    OPER32prefix: ULONG;
    ADDR32prefix: ULONG;
    INSB: ULONG;
    INSW: ULONG;
    OUTSB: ULONG;
    OUTSW: ULONG;
    PUSHFD: ULONG;
    POPFD: ULONG;
    INTnn: ULONG;
    INTO: ULONG;
    IRETD: ULONG;
    FloatingPointOpcode: ULONG;
    INBimm: ULONG;
    INWimm: ULONG;
    OUTBimm: ULONG;
    OUTWimm: ULONG;
    INB: ULONG;
    INW: ULONG;
    OUTB: ULONG;
    OUTW: ULONG;
    LOCKprefix: ULONG;
    REPNEprefix: ULONG;
    REPprefix: ULONG;
    CLI: ULONG;
    STI: ULONG;
    HLT: ULONG;
  end;
  SYSTEM_INSTRUCTION_EMULATION_INFORMATION = _SYSTEM_INSTRUCTION_EMULATION_INFORMATION;
  PSYSTEM_INSTRUCTION_EMULATION_INFORMATION = ^SYSTEM_INSTRUCTION_EMULATION_INFORMATION;
  TSystemInstructionEmulationInformation = SYSTEM_INSTRUCTION_EMULATION_INFORMATION;
  PSystemInstructionEmulationInformation = ^TSystemInstructionEmulationInformation;

  _SYSTEM_CACHE_INFORMATION = record // Information Class 21
    SystemCacheWsSize: ULONG;
    SystemCacheWsPeakSize: ULONG;
    SystemCacheWsFaults: ULONG;
    SystemCacheWsMinimum: ULONG;
    SystemCacheWsMaximum: ULONG;
    TransitionSharedPages: ULONG;
    TransitionSharedPagesPeak: ULONG;
    Reserved: array[0..1] of ULONG;
  end;
  SYSTEM_CACHE_INFORMATION = _SYSTEM_CACHE_INFORMATION;
  PSYSTEM_CACHE_INFORMATION = ^SYSTEM_CACHE_INFORMATION;
  TSystemCacheInformation = SYSTEM_CACHE_INFORMATION;
  PSystemCacheInformation = ^TSystemCacheInformation;

  _SYSTEM_POOL_TAG_INFORMATION = record // Information Class 22
    Tag: array[0..3] of CHAR;
    PagedPoolAllocs: ULONG;
    PagedPoolFrees: ULONG;
    PagedPoolUsage: ULONG;
    NonPagedPoolAllocs: ULONG;
    NonPagedPoolFrees: ULONG;
    NonPagedPoolUsage: ULONG;
  end;
  SYSTEM_POOL_TAG_INFORMATION = _SYSTEM_POOL_TAG_INFORMATION;
  PSYSTEM_POOL_TAG_INFORMATION = ^SYSTEM_POOL_TAG_INFORMATION;
  TSystemPoolTagInformation = SYSTEM_POOL_TAG_INFORMATION;
  PSystemPoolTagInformation = ^TSystemPoolTagInformation;

  _SYSTEM_PROCESSOR_STATISTICS = record // Information Class 23
    ContextSwitches: ULONG;
    DpcCount: ULONG;
    DpcRequestRate: ULONG;
    TimeIncrement: ULONG;
    DpcBypassCount: ULONG;
    ApcBypassCount: ULONG;
  end;
  SYSTEM_PROCESSOR_STATISTICS = _SYSTEM_PROCESSOR_STATISTICS;
  PSYSTEM_PROCESSOR_STATISTICS = ^SYSTEM_PROCESSOR_STATISTICS;
  TSystemProcessorStatistics = SYSTEM_PROCESSOR_STATISTICS;
  PSystemProcessorStatistics = ^TSystemProcessorStatistics;

  _SYSTEM_DPC_INFORMATION = record // Information Class 24
    Reserved: ULONG;
    MaximumDpcQueueDepth: ULONG;
    MinimumDpcRate: ULONG;
    AdjustDpcThreshold: ULONG;
    IdealDpcRate: ULONG;
  end;
  SYSTEM_DPC_INFORMATION = _SYSTEM_DPC_INFORMATION;
  PSYSTEM_DPC_INFORMATION = ^SYSTEM_DPC_INFORMATION;
  TSystemDpcInformation = SYSTEM_DPC_INFORMATION;
  PSystemDpcInformation = ^TSystemDpcInformation;

  _SYSTEM_LOAD_IMAGE = record // Information Class 26
    ModuleName: UNICODE_STRING;
    ModuleBase: PVOID;
    Unknown: PVOID;
    EntryPoint: PVOID;
    ExportDirectory: PVOID;
  end;
  SYSTEM_LOAD_IMAGE = _SYSTEM_LOAD_IMAGE;
  PSYSTEM_LOAD_IMAGE = ^SYSTEM_LOAD_IMAGE;
  TSystemLoadImage = SYSTEM_LOAD_IMAGE;
  PSystemLoadImage = ^TSystemLoadImage;

  _SYSTEM_UNLOAD_IMAGE = record // Information Class 27
    ModuleBase: PVOID;
  end;
  SYSTEM_UNLOAD_IMAGE = _SYSTEM_UNLOAD_IMAGE;
  PSYSTEM_UNLOAD_IMAGE = ^SYSTEM_UNLOAD_IMAGE;
  TSystemUnloadImage = SYSTEM_UNLOAD_IMAGE;
  PSystemUnloadImage = ^TSystemUnloadImage;

  _SYSTEM_QUERY_TIME_ADJUSTMENT = record // Information Class 28
    TimeAdjustment: ULONG;
    MaximumIncrement: ULONG;
    TimeSynchronization: ByteBool;
  end;
  SYSTEM_QUERY_TIME_ADJUSTMENT = _SYSTEM_QUERY_TIME_ADJUSTMENT;
  PSYSTEM_QUERY_TIME_ADJUSTMENT = ^SYSTEM_QUERY_TIME_ADJUSTMENT;
  TSystemQueryTimeAdjustment = SYSTEM_QUERY_TIME_ADJUSTMENT;
  PSystemQueryTimeAdjustment = ^TSystemQueryTimeAdjustment;

  _SYSTEM_SET_TIME_ADJUSTMENT = record // Information Class 28
    TimeAdjustment: ULONG;
    TimeSynchronization: ByteBool;
  end;
  SYSTEM_SET_TIME_ADJUSTMENT = _SYSTEM_SET_TIME_ADJUSTMENT;
  PSYSTEM_SET_TIME_ADJUSTMENT = ^SYSTEM_SET_TIME_ADJUSTMENT;
  TSystemSetTimeAdjustment = SYSTEM_SET_TIME_ADJUSTMENT;
  PSystemSetTimeAdjustment = ^TSystemSetTimeAdjustment;

  _SYSTEM_CRASH_DUMP_INFORMATION = record // Information Class 32
    CrashDumpSectionHandle: HANDLE;
    Unknown: HANDLE; // Windows 2000 only
  end;
  SYSTEM_CRASH_DUMP_INFORMATION = _SYSTEM_CRASH_DUMP_INFORMATION;
  PSYSTEM_CRASH_DUMP_INFORMATION = ^SYSTEM_CRASH_DUMP_INFORMATION;
  TSystemCrashDumpInformation = SYSTEM_CRASH_DUMP_INFORMATION;
  PSystemCrashDumpInformation = ^TSystemCrashDumpInformation;

  _SYSTEM_EXCEPTION_INFORMATION = record // Information Class 33
    AlignmentFixupCount: ULONG;
    ExceptionDispatchCount: ULONG;
    FloatingEmulationCount: ULONG;
    Reserved: ULONG;
  end;
  SYSTEM_EXCEPTION_INFORMATION = _SYSTEM_EXCEPTION_INFORMATION;
  PSYSTEM_EXCEPTION_INFORMATION = ^SYSTEM_EXCEPTION_INFORMATION;
  TSystemExceptionInformation = SYSTEM_EXCEPTION_INFORMATION;
  PSystemExceptionInformation = ^TSystemExceptionInformation;

  _SYSTEM_CRASH_STATE_INFORMATION = record // Information Class 34
    ValidCrashDump: ULONG;
    Unknown: ULONG; // Windows 2000 only
  end;
  SYSTEM_CRASH_STATE_INFORMATION = _SYSTEM_CRASH_STATE_INFORMATION;
  PSYSTEM_CRASH_STATE_INFORMATION = ^SYSTEM_CRASH_STATE_INFORMATION;
  TSystemCrashStateInformation = SYSTEM_CRASH_STATE_INFORMATION;
  PSystemCrashStateInformation = ^TSystemCrashStateInformation;

  _SYSTEM_KERNEL_DEBUGGER_INFORMATION = record // Information Class 35
    DebuggerEnabled: ByteBool;
    DebuggerNotPresent: ByteBool;
  end;
  SYSTEM_KERNEL_DEBUGGER_INFORMATION = _SYSTEM_KERNEL_DEBUGGER_INFORMATION;
  PSYSTEM_KERNEL_DEBUGGER_INFORMATION = ^SYSTEM_KERNEL_DEBUGGER_INFORMATION;
  TSystemKernelDebuggerInformation = SYSTEM_KERNEL_DEBUGGER_INFORMATION;
  PSystemKernelDebuggerInformation = ^TSystemKernelDebuggerInformation;

  _SYSTEM_CONTEXT_SWITCH_INFORMATION = record // Information Class 36
    ContextSwitches: ULONG;
    ContextSwitchCounters: array[0..10] of ULONG;
  end;
  SYSTEM_CONTEXT_SWITCH_INFORMATION = _SYSTEM_CONTEXT_SWITCH_INFORMATION;
  PSYSTEM_CONTEXT_SWITCH_INFORMATION = ^SYSTEM_CONTEXT_SWITCH_INFORMATION;
  TSystemContextSwitchInformation = SYSTEM_CONTEXT_SWITCH_INFORMATION;
  PSystemContextSwitchInformation = ^TSystemContextSwitchInformation;

  _SYSTEM_REGISTRY_QUOTA_INFORMATION = record // Information Class 37
    RegistryQuota: ULONG;
    RegistryQuotaInUse: ULONG;
    PagedPoolSize: ULONG;
  end;
  SYSTEM_REGISTRY_QUOTA_INFORMATION = _SYSTEM_REGISTRY_QUOTA_INFORMATION;
  PSYSTEM_REGISTRY_QUOTA_INFORMATION = ^SYSTEM_REGISTRY_QUOTA_INFORMATION;
  TSystemRegistryQuotaInformation = SYSTEM_REGISTRY_QUOTA_INFORMATION;
  PSystemRegistryQuotaInformation = ^TSystemRegistryQuotaInformation;

  _SYSTEM_LOAD_AND_CALL_IMAGE = record // Information Class 38
    ModuleName: UNICODE_STRING;
  end;
  SYSTEM_LOAD_AND_CALL_IMAGE = _SYSTEM_LOAD_AND_CALL_IMAGE;
  PSYSTEM_LOAD_AND_CALL_IMAGE = ^SYSTEM_LOAD_AND_CALL_IMAGE;
  TSystemLoadAndCallImage = SYSTEM_LOAD_AND_CALL_IMAGE;
  PSystemLoadAndCallImage = ^TSystemLoadAndCallImage;

  _SYSTEM_PRIORITY_SEPARATION = record // Information Class 39
    PrioritySeparation: ULONG;
  end;
  SYSTEM_PRIORITY_SEPARATION = _SYSTEM_PRIORITY_SEPARATION;
  PSYSTEM_PRIORITY_SEPARATION = ^SYSTEM_PRIORITY_SEPARATION;
  TSystemPrioritySeparation = SYSTEM_PRIORITY_SEPARATION;
  PSystemPrioritySeparation = ^TSystemPrioritySeparation;

  _SYSTEM_TIME_ZONE_INFORMATION = record // Information Class 44
    Bias: LONG;
    StandardName: array[0..31] of WCHAR;
    StandardDate: SYSTEMTIME;
    StandardBias: LONG;
    DaylightName: array[0..31] of WCHAR;
    DaylightDate: SYSTEMTIME;
    DaylightBias: LONG;
  end;
  SYSTEM_TIME_ZONE_INFORMATION = _SYSTEM_TIME_ZONE_INFORMATION;
  PSYSTEM_TIME_ZONE_INFORMATION = ^SYSTEM_TIME_ZONE_INFORMATION;
  TSystemTimeZoneInformation = SYSTEM_TIME_ZONE_INFORMATION;
  PSystemTimeZoneInformation = ^TSystemTimeZoneInformation;

  _SYSTEM_LOOKASIDE_INFORMATION = record // Information Class 45
    Depth: USHORT;
    MaximumDepth: USHORT;
    TotalAllocates: ULONG;
    AllocateMisses: ULONG;
    TotalFrees: ULONG;
    FreeMisses: ULONG;
    Type_: POOL_TYPE;
    Tag: ULONG;
    Size: ULONG;
  end;
  SYSTEM_LOOKASIDE_INFORMATION = _SYSTEM_LOOKASIDE_INFORMATION;
  PSYSTEM_LOOKASIDE_INFORMATION = ^SYSTEM_LOOKASIDE_INFORMATION;
  TSystemLookAsideInformation = SYSTEM_LOOKASIDE_INFORMATION;
  PSystemLookAsideInformation = ^TSystemLookAsideInformation;

  _SYSTEM_SET_TIME_SLIP_EVENT = record // Information Class 46
    TimeSlipEvent: HANDLE;
  end;
  SYSTEM_SET_TIME_SLIP_EVENT = _SYSTEM_SET_TIME_SLIP_EVENT;
  PSYSTEM_SET_TIME_SLIP_EVENT = ^SYSTEM_SET_TIME_SLIP_EVENT;
  TSystemSetTimeSlipEvent = SYSTEM_SET_TIME_SLIP_EVENT;
  PSystemSetTimeSlipEvent = ^TSystemSetTimeSlipEvent;

  _SYSTEM_CREATE_SESSION = record // Information Class 47
    Session: ULONG;
  end;
  SYSTEM_CREATE_SESSION = _SYSTEM_CREATE_SESSION;
  PSYSTEM_CREATE_SESSION = ^SYSTEM_CREATE_SESSION;
  TSystemCreateSession = SYSTEM_CREATE_SESSION;
  PSystemCreateSession = ^TSystemCreateSession;

  _SYSTEM_DELETE_SESSION = record // Information Class 48
    Session: ULONG;
  end;
  SYSTEM_DELETE_SESSION = _SYSTEM_DELETE_SESSION;
  PSYSTEM_DELETE_SESSION = ^SYSTEM_DELETE_SESSION;
  TSystemDeleteSession = SYSTEM_DELETE_SESSION;
  PSystemDeleteSession = ^TSystemDeleteSession;

  _SYSTEM_RANGE_START_INFORMATION = record // Information Class 50
    SystemRangeStart: PVOID;
  end;
  SYSTEM_RANGE_START_INFORMATION = _SYSTEM_RANGE_START_INFORMATION;
  PSYSTEM_RANGE_START_INFORMATION = ^SYSTEM_RANGE_START_INFORMATION;
  TSystemRangeStartInformation = SYSTEM_RANGE_START_INFORMATION;
  PSystemRangeStartInformation = ^TSystemRangeStartInformation;

  _SYSTEM_POOL_BLOCK = record
    Allocated: ByteBool;
    Unknown: USHORT;
    Size: ULONG;
    Tag: array[0..3] of CHAR;
  end;
  SYSTEM_POOL_BLOCK = _SYSTEM_POOL_BLOCK;
  PSYSTEM_POOL_BLOCK = ^SYSTEM_POOL_BLOCK;
  TSystemPoolBlock = SYSTEM_POOL_BLOCK;
  PSystemPoolBlock = ^TSystemPoolBlock;

  _SYSTEM_POOL_BLOCKS_INFORMATION = record // Info Classes 14 and 15
    PoolSize: ULONG;
    PoolBase: PVOID;
    Unknown: USHORT;
    NumberOfBlocks: ULONG;
    PoolBlocks: array[0..0] of SYSTEM_POOL_BLOCK;
  end;
  SYSTEM_POOL_BLOCKS_INFORMATION = _SYSTEM_POOL_BLOCKS_INFORMATION;
  PSYSTEM_POOL_BLOCKS_INFORMATION = ^SYSTEM_POOL_BLOCKS_INFORMATION;
  TSystemPoolBlocksInformation = SYSTEM_POOL_BLOCKS_INFORMATION;
  PSystemPoolBlocksInformation = ^TSystemPoolBlocksInformation;

  _SYSTEM_MEMORY_USAGE = record
    Name: PVOID;
    Valid: USHORT;
    Standby: USHORT;
    Modified: USHORT;
    PageTables: USHORT;
  end;
  SYSTEM_MEMORY_USAGE = _SYSTEM_MEMORY_USAGE;
  PSYSTEM_MEMORY_USAGE = ^SYSTEM_MEMORY_USAGE;
  TSystemMemoryUsage = SYSTEM_MEMORY_USAGE;
  PSystemMemoryUsage = ^TSystemMemoryUsage;

  _SYSTEM_MEMORY_USAGE_INFORMATION = record // Info Classes 25 and 29
    Reserved: ULONG;
    EndOfData: PVOID;
    MemoryUsage: array[0..0] of SYSTEM_MEMORY_USAGE;
  end;
  SYSTEM_MEMORY_USAGE_INFORMATION = _SYSTEM_MEMORY_USAGE_INFORMATION;
  PSYSTEM_MEMORY_USAGE_INFORMATION = ^SYSTEM_MEMORY_USAGE_INFORMATION;
  TSystemMemoryUsageInformation = SYSTEM_MEMORY_USAGE_INFORMATION;
  PSystemMemoryUsageInformation = ^TSystemMemoryUsageInformation;

type
  _SHUTDOWN_ACTION = (
    ShutdownNoReboot,
    ShutdownReboot,
    ShutdownPowerOff);
  SHUTDOWN_ACTION = _SHUTDOWN_ACTION;
  TShutdownAction = SHUTDOWN_ACTION;

type
  _DEBUG_CONTROL_CODE = (
    DebugFiller0,
    DebugGetTraceInformation,
    DebugSetInternalBreakpoint,
    DebugSetSpecialCall,
    DebugClearSpecialCalls,
    DebugQuerySpecialCalls,
    DebugDbgBreakPoint);
  DEBUG_CONTROL_CODE = _DEBUG_CONTROL_CODE;
  TDebugControlCode = DEBUG_CONTROL_CODE;

type
  _OBJECT_INFORMATION_CLASS = (
    ObjectBasicInformation,
    ObjectNameInformation,
    ObjectTypeInformation,
    ObjectAllTypesInformation,
    ObjectHandleInformation);
  OBJECT_INFORMATION_CLASS = _OBJECT_INFORMATION_CLASS;
  TObjectInformationClass = OBJECT_INFORMATION_CLASS;

type
  _OBJECT_BASIC_INFORMATION = record // Information Class 0
    Attributes: ULONG;
    GrantedAccess: ACCESS_MASK;
    HandleCount: ULONG;
    PointerCount: ULONG;
    PagedPoolUsage: ULONG;
    NonPagedPoolUsage: ULONG;
    Reserved: array[0..2] of ULONG;
    NameInformationLength: ULONG;
    TypeInformationLength: ULONG;
    SecurityDescriptorLength: ULONG;
    CreateTime: LARGE_INTEGER;
  end;
  OBJECT_BASIC_INFORMATION = _OBJECT_BASIC_INFORMATION;
  POBJECT_BASIC_INFORMATION = ^OBJECT_BASIC_INFORMATION;
  TObjectBasicInformation = OBJECT_BASIC_INFORMATION;
  PObjectBasicInformation = ^TObjectBasicInformation;

  _OBJECT_TYPE_INFORMATION = record // Information Class 2
    Name: UNICODE_STRING;
    ObjectCount: ULONG;
    HandleCount: ULONG;
    Reserved1: array[0..3] of ULONG;
    PeakObjectCount: ULONG;
    PeakHandleCount: ULONG;
    Reserved2: array[0..3] of ULONG;
    InvalidAttributes: ULONG;
    GenericMapping: GENERIC_MAPPING;
    ValidAccess: ULONG;
    Unknown: UCHAR;
    MaintainHandleDatabase: ByteBool;
    Reserved3: array[0..1] of UCHAR;
    PoolType: POOL_TYPE;
    PagedPoolUsage: ULONG;
    NonPagedPoolUsage: ULONG;
  end;
  OBJECT_TYPE_INFORMATION = _OBJECT_TYPE_INFORMATION;
  POBJECT_TYPE_INFORMATION = ^OBJECT_TYPE_INFORMATION;
  TObjectTypeInformation = OBJECT_TYPE_INFORMATION;
  PObjectTypeInformation = ^TObjectTypeInformation;

  _OBJECT_ALL_TYPES_INFORMATION = record // Information Class 3
    NumberOfTypes: ULONG;
    TypeInformation: OBJECT_TYPE_INFORMATION;
  end;
  OBJECT_ALL_TYPES_INFORMATION = _OBJECT_ALL_TYPES_INFORMATION;
  POBJECT_ALL_TYPES_INFORMATION = ^OBJECT_ALL_TYPES_INFORMATION;
  TObjectAllTypesInformation = OBJECT_ALL_TYPES_INFORMATION;
  PObjectAllTypesInformation = ^TObjectAllTypesInformation;

  _OBJECT_HANDLE_ATTRIBUTE_INFORMATION = record // Information Class 4
    Inherit: ByteBool;
    ProtectFromClose: ByteBool;
  end;
  OBJECT_HANDLE_ATTRIBUTE_INFORMATION = _OBJECT_HANDLE_ATTRIBUTE_INFORMATION;
  POBJECT_HANDLE_ATTRIBUTE_INFORMATION = ^OBJECT_HANDLE_ATTRIBUTE_INFORMATION;
  TObjectHandleAttributeInformation = OBJECT_HANDLE_ATTRIBUTE_INFORMATION;
  PObjectHandleAttributeInformation = ^TObjectHandleAttributeInformation;

type
  _DIRECTORY_BASIC_INFORMATION = record
    ObjectName: UNICODE_STRING;
    ObjectTypeName: UNICODE_STRING;
  end;
  DIRECTORY_BASIC_INFORMATION = _DIRECTORY_BASIC_INFORMATION;
  PDIRECTORY_BASIC_INFORMATION = ^DIRECTORY_BASIC_INFORMATION;
  TDirectoryBasicInformation = DIRECTORY_BASIC_INFORMATION;
  PDirectoryBasicInformation = ^TDirectoryBasicInformation;

type
  _MEMORY_INFORMATION_CLASS = (
    MemoryBasicInformation,
    MemoryWorkingSetList,
    MemorySectionName,
    MemoryBasicVlmInformation);
  MEMORY_INFORMATION_CLASS = _MEMORY_INFORMATION_CLASS;
  TMemoryInformationClass = MEMORY_INFORMATION_CLASS;
  PMemoryInformationClass = ^TMemoryInformationClass;

type
  _MEMORY_BASIC_INFORMATION = record // Information Class 0
    BaseAddress: PVOID;
    AllocationBase: PVOID;
    AllocationProtect: ULONG;
    RegionSize: ULONG;
    State: ULONG;
    Protect: ULONG;
    Type_: ULONG;
  end;
  MEMORY_BASIC_INFORMATION = _MEMORY_BASIC_INFORMATION;
  PMEMORY_BASIC_INFORMATION = ^MEMORY_BASIC_INFORMATION;
  TMemoryBasicInformation = MEMORY_BASIC_INFORMATION;
  PMemoryBasicInformation = ^TMemoryBasicInformation;

  _MEMORY_WORKING_SET_LIST = record // Information Class 1
    NumberOfPages: ULONG;
    WorkingSetList: array[0..0] of ULONG;
  end;
  MEMORY_WORKING_SET_LIST = _MEMORY_WORKING_SET_LIST;
  PMEMORY_WORKING_SET_LIST = ^MEMORY_WORKING_SET_LIST;
  TMemoryWorkingSetList = MEMORY_WORKING_SET_LIST;
  PMemoryWorkingSetList = ^TMemoryWorkingSetList;

  _MEMORY_SECTION_NAME = record // Information Class 2
    SectionFileName: UNICODE_STRING;
  end;
  MEMORY_SECTION_NAME = _MEMORY_SECTION_NAME;
  PMEMORY_SECTION_NAME = ^MEMORY_SECTION_NAME;
  TMemorySectionName = MEMORY_SECTION_NAME;
  PMemorySectionName = ^TMemorySectionName;

type
  _SECTION_INFORMATION_CLASS = (
    SectionBasicInformation,
    SectionImageInformation);
  SECTION_INFORMATION_CLASS = _SECTION_INFORMATION_CLASS;
  TSectionInformationClass = SECTION_INFORMATION_CLASS;

type
  _SECTION_BASIC_INFORMATION = record // Information Class 0
    BaseAddress: PVOID;
    Attributes: ULONG;
    Size: LARGE_INTEGER;
  end;
  SECTION_BASIC_INFORMATION = _SECTION_BASIC_INFORMATION;
  PSECTION_BASIC_INFORMATION = ^SECTION_BASIC_INFORMATION;
  TSectionBasicInformation = SECTION_BASIC_INFORMATION;
  PSectionBasicInformation = ^TSectionBasicInformation;

  _SECTION_IMAGE_INFORMATION = record // Information Class 1
    EntryPoint: PVOID;
    Unknown1: ULONG;
    StackReserve: ULONG;
    StackCommit: ULONG;
    Subsystem: ULONG;
    MinorSubsystemVersion: USHORT;
    MajorSubsystemVersion: USHORT;
    Unknown2: ULONG;
    Characteristics: ULONG;
    ImageNumber: USHORT;
    Executable: ByteBool;
    Unknown3: UCHAR;
    Unknown4: array[0..2] of ULONG;
  end;
  SECTION_IMAGE_INFORMATION = _SECTION_IMAGE_INFORMATION;
  PSECTION_IMAGE_INFORMATION = ^SECTION_IMAGE_INFORMATION;
  TSectionImageInformation = SECTION_IMAGE_INFORMATION;
  PSectionImageInformation = TSectionImageInformation;

type
  _USER_STACK = record
    FixedStackBase: PVOID;
    FixedStackLimit: PVOID;
    ExpandableStackBase: PVOID;
    ExpandableStackLimit: PVOID;
    ExpandableStackBottom: PVOID;
  end;
  USER_STACK = _USER_STACK;
  PUSER_STACK = ^USER_STACK;
  TUserStack = USER_STACK;
  PUserStack = ^TUserStack;

type
  _THREAD_BASIC_INFORMATION = record // Information Class 0
    ExitStatus: NTSTATUS;
    TebBaseAddress: PNT_TIB;
    ClientId: CLIENT_ID;
    AffinityMask: KAFFINITY;
    Priority: KPRIORITY;
    BasePriority: KPRIORITY;
  end;
  THREAD_BASIC_INFORMATION = _THREAD_BASIC_INFORMATION;
  PTHREAD_BASIC_INFORMATION = ^THREAD_BASIC_INFORMATION;
  TThreadBasicInformation = THREAD_BASIC_INFORMATION;
  PThreadBasicInformation = ^TThreadBasicInformation;

type
  _PROCESS_PRIORITY_CLASS = record // Information Class 18
    Foreground: ByteBool;
    PriorityClass: UCHAR;
  end;
  PROCESS_PRIORITY_CLASS = _PROCESS_PRIORITY_CLASS;
  PPROCESS_PRIORITY_CLASS = ^PROCESS_PRIORITY_CLASS;
  TProcessPriorityClass = PROCESS_PRIORITY_CLASS;
  PProcessPriorityClass = ^TProcessPriorityClass;

  _RTL_PROCESS_INFORMATION = record
    Size: ULONG;
    hProcess: HANDLE;
    hThread: HANDLE;
    ClientId: CLIENT_ID;
    ImageInfo: SECTION_IMAGE_INFORMATION;
  end;
  RTL_PROCESS_INFORMATION = _RTL_PROCESS_INFORMATION;
  PRTL_PROCESS_INFORMATION = ^RTL_PROCESS_INFORMATION;
  TRtlProcessInformation = RTL_PROCESS_INFORMATION;
  PRtlProcessInformation = ^RTL_PROCESS_INFORMATION;

const
  PDI_MODULES = $01;
  PDI_BACKTRACE = $02;
  PDI_HEAPS = $04;
  PDI_HEAP_TAGS = $08;
  PDI_HEAP_BLOCKS = $10;
  PDI_LOCKS = $20;

type
  _DEBUG_MODULE_INFORMATION = record // c.f. SYSTEM_MODULE_INFORMATION
    Reserved: array[0..1] of ULONG;
    Base: PVOID;
    Size: ULONG;
    Flags: ULONG;
    Index: USHORT;
    Unknown: USHORT;
    LoadCount: USHORT;
    ModuleNameOffset: USHORT;
    ImageName: array[0..255] of CHAR;
  end;
  DEBUG_MODULE_INFORMATION = _DEBUG_MODULE_INFORMATION;
  PDEBUG_MODULE_INFORMATION = ^DEBUG_MODULE_INFORMATION;
  TDebugModuleInformation = DEBUG_MODULE_INFORMATION;
  PDebugModuleInformation = ^TDebugModuleInformation;

  PDEBUG_MODULE_INFORMATION_ARRAY = ^DEBUG_MODULE_INFORMATION_ARRAY;
  DEBUG_MODULE_INFORMATION_ARRAY = record
    Count: ULONG;
    Information: array[0..MAXWORD-1] of DEBUG_MODULE_INFORMATION;
  end;

  _DEBUG_HEAP_INFORMATION = record
    Base: ULONG;
    Flags: ULONG;
    Granularity: USHORT;
    Unknown: USHORT;
    Allocated: ULONG;
    Committed: ULONG;
    TagCount: ULONG;
    BlockCount: ULONG;
    Reserved: array[0..6] of ULONG;
    Tags: PVOID;
    Blocks: PVOID;
  end;
  DEBUG_HEAP_INFORMATION = _DEBUG_HEAP_INFORMATION;
  PDEBUG_HEAP_INFORMATION = ^DEBUG_HEAP_INFORMATION;
  TDebugHeapInformation = DEBUG_HEAP_INFORMATION;
  PDebugHeapInformation = ^TDebugHeapInformation;

  PDEBUG_HEAP_INFORMATION_ARRAY = ^DEBUG_HEAP_INFORMATION_ARRAY;
  DEBUG_HEAP_INFORMATION_ARRAY = record
    Count: ULONG;
    Information: array[0..MAXWORD-1] of DEBUG_HEAP_INFORMATION;
  end;

  _DEBUG_LOCK_INFORMATION = record // c.f. SYSTEM_LOCK_INFORMATION
    Address: PVOID;
    Type_: USHORT;
    CreatorBackTraceIndex: USHORT;
    OwnerThreadId: ULONG;
    ActiveCount: ULONG;
    ContentionCount: ULONG;
    EntryCount: ULONG;
    RecursionCount: ULONG;
    NumberOfSharedWaiters: ULONG;
    NumberOfExclusiveWaiters: ULONG;
  end;
  DEBUG_LOCK_INFORMATION = _DEBUG_LOCK_INFORMATION;
  PDEBUG_LOCK_INFORMATION = ^DEBUG_LOCK_INFORMATION;
  TDebugLockInformation = DEBUG_LOCK_INFORMATION;
  PDebugLockInformation = ^TDebugLockInformation;

  PDEBUG_LOCK_INFORMATION_ARRAY = ^DEBUG_LOCK_INFORMATION_ARRAY;
  DEBUG_LOCK_INFORMATION_ARRAY = record
    Count: ULONG;
    Information: array[0..MAXWORD-1] of DEBUG_LOCK_INFORMATION;
  end;

type
  _DEBUG_BUFFER = record
    SectionHandle: HANDLE;
    SectionBase: PVOID;
    RemoteSectionBase: PVOID;
    SectionBaseDelta: ULONG;
    EventPairHandle: HANDLE;
    Unknown: array[0..1] of ULONG;
    RemoteThreadHandle: HANDLE;
    InfoClassMask: ULONG;
    SizeOfInfo: ULONG;
    AllocatedSize: ULONG;
    SectionSize: ULONG;
    ModuleInformation: PDEBUG_MODULE_INFORMATION_ARRAY;
    BackTraceInformation: PVOID;
    HeapInformation: PDEBUG_HEAP_INFORMATION_ARRAY;
    LockInformation: PDEBUG_LOCK_INFORMATION_ARRAY;
    Reserved: array[0..7] of PVOID;
  end;
  DEBUG_BUFFER = _DEBUG_BUFFER;
  PDEBUG_BUFFER = ^DEBUG_BUFFER;
  TDebugBuffer = DEBUG_BUFFER;
  PDebugBuffer = ^TDebugBuffer;

type
  PTIMER_APC_ROUTINE = procedure(TimerContext: PVOID; TimerLowValue: ULONG; TimerHighValue: LONG); stdcall;

type
  _TIMER_INFORMATION_CLASS = (TimerBasicInformation);
  TIMER_INFORMATION_CLASS = _TIMER_INFORMATION_CLASS;
  TTimerInformationClass = TIMER_INFORMATION_CLASS;

type
  _TIMER_BASIC_INFORMATION = record
    TimeRemaining: LARGE_INTEGER;
    SignalState: ByteBool;
  end;
  TIMER_BASIC_INFORMATION = _TIMER_BASIC_INFORMATION;
  PTIMER_BASIC_INFORMATION = ^TIMER_BASIC_INFORMATION;
  TTimerBasicInformation = TIMER_BASIC_INFORMATION;
  PTimerBasicInformation = ^TTimerBasicInformation;

type
  _EVENT_INFORMATION_CLASS = (EventBasicInformation);
  EVENT_INFORMATION_CLASS = _EVENT_INFORMATION_CLASS;
  TEventInformationClass = EVENT_INFORMATION_CLASS;

type
  _EVENT_BASIC_INFORMATION = record
    EventType: EVENT_TYPE;
    SignalState: LONG;
  end;
  EVENT_BASIC_INFORMATION = _EVENT_BASIC_INFORMATION;
  PEVENT_BASIC_INFORMATION = ^EVENT_BASIC_INFORMATION;
  TEventBasicInformation = EVENT_BASIC_INFORMATION;
  PEventBasicInformation = ^TEventBasicInformation;

type
  _SEMAPHORE_INFORMATION_CLASS = (SemaphoreBasicInformation);
  SEMAPHORE_INFORMATION_CLASS = _SEMAPHORE_INFORMATION_CLASS;
  TSemaphoreInformationClass = SEMAPHORE_INFORMATION_CLASS;

type
  _SEMAPHORE_BASIC_INFORMATION = record
    CurrentCount: LONG;
    MaximumCount: LONG;
  end;
  SEMAPHORE_BASIC_INFORMATION = _SEMAPHORE_BASIC_INFORMATION;
  PSEMAPHORE_BASIC_INFORMATION = ^SEMAPHORE_BASIC_INFORMATION;
  TSemaphoreBasicInformation = SEMAPHORE_BASIC_INFORMATION;

type
  _MUTANT_INFORMATION_CLASS = (MutantBasicInformation);
  MUTANT_INFORMATION_CLASS = _MUTANT_INFORMATION_CLASS;
  TMutantInformationClass = MUTANT_INFORMATION_CLASS;

type
  _MUTANT_BASIC_INFORMATION = record
    SignalState: LONG;
    Owned: ByteBool;
    Abandoned: ByteBool;
  end;
  MUTANT_BASIC_INFORMATION = _MUTANT_BASIC_INFORMATION;
  PMUTANT_BASIC_INFORMATION = ^MUTANT_BASIC_INFORMATION;
  TMutantBasicInformation = MUTANT_BASIC_INFORMATION;
  PMutantBasicInformation = ^TMutantBasicInformation;

type
  _IO_COMPLETION_INFORMATION_CLASS = (IoCompletionBasicInformation);
  IO_COMPLETION_INFORMATION_CLASS = _IO_COMPLETION_INFORMATION_CLASS;
  TIoCompletionInformationClass = IO_COMPLETION_INFORMATION_CLASS;

type
  _IO_COMPLETION_BASIC_INFORMATION = record
    SignalState: LONG;
  end;
  IO_COMPLETION_BASIC_INFORMATION = _IO_COMPLETION_BASIC_INFORMATION;
  PIO_COMPLETION_BASIC_INFORMATION = ^IO_COMPLETION_BASIC_INFORMATION;
  TIoCompletionBasicInformation = IO_COMPLETION_BASIC_INFORMATION;
  PIoCompletionBasicInformation = ^TIoCompletionBasicInformation;

type
  _PORT_MESSAGE = record
    DataSize: USHORT;
    MessageSize: USHORT;
    MessageType: USHORT;
    VirtualRangesOffset: USHORT;
    ClientId: CLIENT_ID;
    MessageId: ULONG;
    SectionSize: ULONG;
    // UCHAR Data[];
  end;
  PORT_MESSAGE = _PORT_MESSAGE;
  PPORT_MESSAGE = ^PORT_MESSAGE;
  TPortMessage = PORT_MESSAGE;
  PPortMessage = ^TPortMessage;

  _LPC_TYPE = (
    LPC_NEW_MESSAGE, // A new message
    LPC_REQUEST, // A request message
    LPC_REPLY, // A reply to a request message
    LPC_DATAGRAM, //
    LPC_LOST_REPLY, //
    LPC_PORT_CLOSED, // Sent when port is deleted
    LPC_CLIENT_DIED, // Messages to thread termination ports
    LPC_EXCEPTION, // Messages to thread exception port
    LPC_DEBUG_EVENT, // Messages to thread debug port
    LPC_ERROR_EVENT, // Used by ZwRaiseHardError
    LPC_CONNECTION_REQUEST); // Used by ZwConnectPort
  LPC_TYPE = _LPC_TYPE;
  TLpcType = LPC_TYPE;

  _PORT_SECTION_WRITE = record
    Length: ULONG;
    SectionHandle: HANDLE;
    SectionOffset: ULONG;
    ViewSize: ULONG;
    ViewBase: PVOID;
    TargetViewBase: PVOID;
  end;
  PORT_SECTION_WRITE = _PORT_SECTION_WRITE;
  PPORT_SECTION_WRITE = ^PORT_SECTION_WRITE;
  TPortSectionWrite = PORT_SECTION_WRITE;
  PPortSectionWrite = ^TPortSectionWrite;

  _PORT_SECTION_READ = record
    Length: ULONG;
    ViewSize: ULONG;
    ViewBase: ULONG;
  end;
  PORT_SECTION_READ = _PORT_SECTION_READ;
  PPORT_SECTION_READ = ^PORT_SECTION_READ;
  TPortSectionRead = PORT_SECTION_READ;
  PPortSectionRead = ^TPortSectionRead;

type
  _PORT_INFORMATION_CLASS = (PortBasicInformation);
  PORT_INFORMATION_CLASS = _PORT_INFORMATION_CLASS;
  TPortInformationClass = PORT_INFORMATION_CLASS;


type
  _PORT_BASIC_INFORMATION = record
  end;
  PORT_BASIC_INFORMATION = _PORT_BASIC_INFORMATION;
  PPORT_BASIC_INFORMATION = ^PORT_BASIC_INFORMATION;
  TPortBasicInformation = PORT_BASIC_INFORMATION;
  PPortBasicInformation = ^TPortBasicInformation;

type
  _FILE_GET_EA_INFORMATION = record
    NextEntryOffset: ULONG;
    EaNameLength: UCHAR;
    EaName: array[0..0] of CHAR;
  end;
  FILE_GET_EA_INFORMATION = _FILE_GET_EA_INFORMATION;
  PFILE_GET_EA_INFORMATION = ^FILE_GET_EA_INFORMATION;
  TFileGetEaInformation = FILE_GET_EA_INFORMATION;
  PFileGetEaInformation = ^TFileGetEaInformation;

type
  _FILE_FS_VOLUME_INFORMATION = record
    VolumeCreationTime: LARGE_INTEGER;
    VolumeSerialNumber: ULONG;
    VolumeLabelLength: ULONG;
    Unknown: UCHAR;
    VolumeLabel: array[0..0] of WCHAR;
  end;
  FILE_FS_VOLUME_INFORMATION = _FILE_FS_VOLUME_INFORMATION;
  PFILE_FS_VOLUME_INFORMATION = ^FILE_FS_VOLUME_INFORMATION;
  TFileFsVolumeInformation = FILE_FS_VOLUME_INFORMATION;
  PFileFsVolumeInformation = ^TFileFsVolumeInformation;

  _FILE_FS_LABEL_INFORMATION = record
    VolumeLabelLength: ULONG;
    VolumeLabel: WCHAR;
  end;
  FILE_FS_LABEL_INFORMATION = _FILE_FS_LABEL_INFORMATION;
  PFILE_FS_LABEL_INFORMATION = ^FILE_FS_LABEL_INFORMATION;
  TFileFsLabelInformation = FILE_FS_LABEL_INFORMATION;
  PFileFsLabelInformation = ^TFileFsLabelInformation;

  _FILE_FS_SIZE_INFORMATION = record
    TotalAllocationUnits: LARGE_INTEGER;
    AvailableAllocationUnits: LARGE_INTEGER;
    SectorsPerAllocationUnit: ULONG;
    BytesPerSector: ULONG;
  end;
  FILE_FS_SIZE_INFORMATION = _FILE_FS_SIZE_INFORMATION;
  PFILE_FS_SIZE_INFORMATION = ^FILE_FS_SIZE_INFORMATION;
  TFileFsSizeInformation = FILE_FS_SIZE_INFORMATION;
  PFileFsSizeInformation = ^TFileFsSizeInformation;

  _FILE_FS_ATTRIBUTE_INFORMATION = record
    FileSystemFlags: ULONG;
    MaximumComponentNameLength: ULONG;
    FileSystemNameLength: ULONG;
    FileSystemName: array[0..0] of WCHAR
  end;
  FILE_FS_ATTRIBUTE_INFORMATION = _FILE_FS_ATTRIBUTE_INFORMATION;
  PFILE_FS_ATTRIBUTE_INFORMATION = ^FILE_FS_ATTRIBUTE_INFORMATION;
  TFileFsAttributeInformation = FILE_FS_ATTRIBUTE_INFORMATION;
  PFileFsAttributeInformation = ^TFileFsAttributeInformation;

  _FILE_FS_CONTROL_INFORMATION = record
    Reserved: array[0..2] of LARGE_INTEGER;
    DefaultQuotaThreshold: LARGE_INTEGER;
    DefaultQuotaLimit: LARGE_INTEGER;
    QuotaFlags: ULONG;
  end;
  FILE_FS_CONTROL_INFORMATION = _FILE_FS_CONTROL_INFORMATION;
  PFILE_FS_CONTROL_INFORMATION = ^FILE_FS_CONTROL_INFORMATION;
  TFileFsControlInformation = FILE_FS_CONTROL_INFORMATION;
  PFileFsControlInformation = ^TFileFsControlInformation;

  _FILE_FS_FULL_SIZE_INFORMATION = record
    TotalQuotaAllocationUnits: LARGE_INTEGER;
    AvailableQuotaAllocationUnits: LARGE_INTEGER;
    AvailableAllocationUnits: LARGE_INTEGER;
    SectorsPerAllocationUnit: ULONG;
    BytesPerSector: ULONG;
  end;
  FILE_FS_FULL_SIZE_INFORMATION = _FILE_FS_FULL_SIZE_INFORMATION;
  PFILE_FS_FULL_SIZE_INFORMATION = ^FILE_FS_FULL_SIZE_INFORMATION;
  TFileFsFullSizeInformation = FILE_FS_FULL_SIZE_INFORMATION;
  PFileFsFullSizeInformation = ^TFileFsFullSizeInformation;

  _FILE_FS_OBJECT_ID_INFORMATION = record
    VolumeObjectId: UUID;
    VolumeObjectIdExtendedInfo: array[0..11] of ULONG;
  end;
  FILE_FS_OBJECT_ID_INFORMATION = _FILE_FS_OBJECT_ID_INFORMATION;
  PFILE_FS_OBJECT_ID_INFORMATION = ^FILE_FS_OBJECT_ID_INFORMATION;
  TFileFsObjectIdInformation = FILE_FS_OBJECT_ID_INFORMATION;
  PFileFsObjectIdInformation = ^TFileFsObjectIdInformation;

  _FILE_USER_QUOTA_INFORMATION = record
    NextEntryOffset: ULONG;
    SidLength: ULONG;
    ChangeTime: LARGE_INTEGER;
    QuotaUsed: LARGE_INTEGER;
    QuotaThreshold: LARGE_INTEGER;
    QuotaLimit: LARGE_INTEGER;
    Sid: array[0..0] of SID;
  end;
  FILE_USER_QUOTA_INFORMATION = _FILE_USER_QUOTA_INFORMATION;
  PFILE_USER_QUOTA_INFORMATION = ^FILE_USER_QUOTA_INFORMATION;
  TFileUserQuotaInformation = FILE_USER_QUOTA_INFORMATION;
  PFileUserQuotaInformation = ^TFileUserQuotaInformation;

  _FILE_QUOTA_LIST_INFORMATION = record
    NextEntryOffset: ULONG;
    SidLength: ULONG;
    Sid: array[0..0] of SID;
  end;
  FILE_QUOTA_LIST_INFORMATION = _FILE_QUOTA_LIST_INFORMATION;
  PFILE_QUOTA_LIST_INFORMATION = ^FILE_QUOTA_LIST_INFORMATION;
  TFileQuotaListInformation = FILE_QUOTA_LIST_INFORMATION;
  PFileQuotaListInformation = ^TFileQuotaListInformation;

type
  _FILE_DIRECTORY_INFORMATION = record // Information Class 1
    NextEntryOffset: ULONG;
    Unknown: ULONG;
    CreationTime: LARGE_INTEGER;
    LastAccessTime: LARGE_INTEGER;
    LastWriteTime: LARGE_INTEGER;
    ChangeTime: LARGE_INTEGER;
    EndOfFile: LARGE_INTEGER;
    AllocationSize: LARGE_INTEGER;
    FileAttributes: ULONG;
    FileNameLength: ULONG;
    FileName: array[0..0] of WCHAR
  end;
  FILE_DIRECTORY_INFORMATION = _FILE_DIRECTORY_INFORMATION;
  PFILE_DIRECTORY_INFORMATION = ^FILE_DIRECTORY_INFORMATION;
  TFileDirectoryInformation = FILE_DIRECTORY_INFORMATION;
  PFileDirectoryInformation = ^TFileDirectoryInformation;

  _FILE_FULL_DIRECTORY_INFORMATION = record // Information Class 2
    NextEntryOffset: ULONG;
    Unknown: ULONG;
    CreationTime: LARGE_INTEGER;
    LastAccessTime: LARGE_INTEGER;
    LastWriteTime: LARGE_INTEGER;
    ChangeTime: LARGE_INTEGER;
    EndOfFile: LARGE_INTEGER;
    AllocationSize: LARGE_INTEGER;
    FileAttributes: ULONG;
    FileNameLength: ULONG;
    EaInformationLength: ULONG;
    FileName: array[0..0] of WCHAR
  end;
  FILE_FULL_DIRECTORY_INFORMATION = _FILE_FULL_DIRECTORY_INFORMATION;
  PFILE_FULL_DIRECTORY_INFORMATION = ^FILE_FULL_DIRECTORY_INFORMATION;
  TFileFullDirectoryInformation = FILE_FULL_DIRECTORY_INFORMATION;
  PFileFullDirectoryInformation = ^TFileFullDirectoryInformation;

  _FILE_BOTH_DIRECTORY_INFORMATION = record // Information Class 3
    NextEntryOffset: ULONG;
    Unknown: ULONG;
    CreationTime: LARGE_INTEGER;
    LastAccessTime: LARGE_INTEGER;
    LastWriteTime: LARGE_INTEGER;
    ChangeTime: LARGE_INTEGER;
    EndOfFile: LARGE_INTEGER;
    AllocationSize: LARGE_INTEGER;
    FileAttributes: ULONG;
    FileNameLength: ULONG;
    EaInformationLength: ULONG;
    AlternateNameLength: UCHAR;
    AlternateName: array[0..11] of WCHAR;
    FileName: array[0..0] of WCHAR;
  end;
  FILE_BOTH_DIRECTORY_INFORMATION = _FILE_BOTH_DIRECTORY_INFORMATION;
  PFILE_BOTH_DIRECTORY_INFORMATION = ^FILE_BOTH_DIRECTORY_INFORMATION;
  TFileBothDirectoryInformation = FILE_BOTH_DIRECTORY_INFORMATION;
  PFileBothDirectoryInformation = ^TFileBothDirectoryInformation;

  _FILE_INTERNAL_INFORMATION = record // Information Class 6
    FileId: LARGE_INTEGER;
  end;
  FILE_INTERNAL_INFORMATION = _FILE_INTERNAL_INFORMATION;
  PFILE_INTERNAL_INFORMATION = ^FILE_INTERNAL_INFORMATION;
  TFileInternalInformation = FILE_INTERNAL_INFORMATION;
  PFileInternalInformation = ^TFileInternalInformation;

  _FILE_EA_INFORMATION = record // Information Class 7
    EaInformationLength: ULONG;
  end;
  FILE_EA_INFORMATION = _FILE_EA_INFORMATION;
  PFILE_EA_INFORMATION = ^FILE_EA_INFORMATION;
  TFileEaInformation = FILE_EA_INFORMATION;
  PFileEaInformation = ^TFileEaInformation;

  _FILE_ACCESS_INFORMATION = record // Information Class 8
    GrantedAccess: ACCESS_MASK;
  end;
  FILE_ACCESS_INFORMATION = _FILE_ACCESS_INFORMATION;
  PFILE_ACCESS_INFORMATION = ^FILE_ACCESS_INFORMATION;
  TFileAccessInformation = FILE_ACCESS_INFORMATION;
  PFileAccessInformation = ^TFileAccessInformation;

  _FILE_NAME_INFORMATION = record // Information Classes 9 and 21
    FileNameLength: ULONG;
    FileName: array[0..0] of WCHAR;
  end;
  FILE_NAME_INFORMATION = _FILE_NAME_INFORMATION;
  PFILE_NAME_INFORMATION = ^FILE_NAME_INFORMATION;
  FILE_ALTERNATE_NAME_INFORMATION = _FILE_NAME_INFORMATION;
  PFILE_ALTERNATE_NAME_INFORMATION = ^FILE_ALTERNATE_NAME_INFORMATION;
  TFileNameInformation = FILE_NAME_INFORMATION;
  PFileNameInformation = ^TFileNameInformation;

  _FILE_LINK_RENAME_INFORMATION = record // Info Classes 10 and 11
    ReplaceIfExists: ByteBool;
    RootDirectory: HANDLE;
    FileNameLength: ULONG;
    FileName: array[0..0] of WCHAR;
  end;
  FILE_LINK_INFORMATION = _FILE_LINK_RENAME_INFORMATION;
  PFILE_LINK_INFORMATION = ^FILE_LINK_INFORMATION;
  FILE_RENAME_INFORMATION = _FILE_LINK_RENAME_INFORMATION;
  PFILE_RENAME_INFORMATION = ^FILE_RENAME_INFORMATION;
  TFileLinkInformation = FILE_LINK_INFORMATION;
  PFileLinkInformation = ^TFileLinkInformation;

  _FILE_NAMES_INFORMATION = record // Information Class 12
    NextEntryOffset: ULONG;
    Unknown: ULONG;
    FileNameLength: ULONG;
    FileName: array[0..0] of WCHAR;
  end;
  FILE_NAMES_INFORMATION = _FILE_NAMES_INFORMATION;
  PFILE_NAMES_INFORMATION = ^FILE_NAMES_INFORMATION;
  TFileNamesInformation = FILE_NAMES_INFORMATION;
  PFileNamesInformation = ^TFileNamesInformation;

  _FILE_MODE_INFORMATION = record // Information Class 16
    Mode: ULONG;
  end;
  FILE_MODE_INFORMATION = _FILE_MODE_INFORMATION;
  PFILE_MODE_INFORMATION = ^FILE_MODE_INFORMATION;
  TFileModeInformation = FILE_MODE_INFORMATION;
  PFileModeInformation = ^TFileModeInformation;

  _FILE_ALL_INFORMATION = record // Information Class 18
    BasicInformation: FILE_BASIC_INFORMATION;
    StandardInformation: FILE_STANDARD_INFORMATION;
    InternalInformation: FILE_INTERNAL_INFORMATION;
    EaInformation: FILE_EA_INFORMATION;
    AccessInformation: FILE_ACCESS_INFORMATION;
    PositionInformation: FILE_POSITION_INFORMATION;
    ModeInformation: FILE_MODE_INFORMATION;
    AlignmentInformation: FILE_ALIGNMENT_INFORMATION;
    NameInformation: FILE_NAME_INFORMATION;
  end;
  FILE_ALL_INFORMATION = _FILE_ALL_INFORMATION;
  PFILE_ALL_INFORMATION = ^FILE_ALL_INFORMATION;
  TFileAllInformation = FILE_ALL_INFORMATION;
  PFileAllInformation = ^TFileAllInformation;

  _FILE_ALLOCATION_INFORMATION = record // Information Class 19
    AllocationSize: LARGE_INTEGER;
  end;
  FILE_ALLOCATION_INFORMATION = _FILE_ALLOCATION_INFORMATION;
  PFILE_ALLOCATION_INFORMATION = ^FILE_ALLOCATION_INFORMATION;
  TFileAllocationInformation = FILE_ALLOCATION_INFORMATION;
  PFileAllocationInformation = ^TFileAllocationInformation;

  _FILE_STREAM_INFORMATION = record // Information Class 22
    NextEntryOffset: ULONG;
    StreamNameLength: ULONG;
    EndOfStream: LARGE_INTEGER;
    AllocationSize: LARGE_INTEGER;
    StreamName: array[0..0] of WCHAR;
  end;
  FILE_STREAM_INFORMATION = _FILE_STREAM_INFORMATION;
  PFILE_STREAM_INFORMATION = ^FILE_STREAM_INFORMATION;
  TFileStreamInformation = FILE_STREAM_INFORMATION;
  PFileStreamInformation = ^TFileStreamInformation;

  _FILE_PIPE_INFORMATION = record // Information Class 23
    ReadModeMessage: ULONG;
    WaitModeBlocking: ULONG;
  end;
  FILE_PIPE_INFORMATION = _FILE_PIPE_INFORMATION;
  PFILE_PIPE_INFORMATION = ^FILE_PIPE_INFORMATION;
  TFilePipeInformation = FILE_PIPE_INFORMATION;
  PFilePipeInformation = ^TFilePipeInformation;

  _FILE_PIPE_LOCAL_INFORMATION = record // Information Class 24
    MessageType: ULONG;
    Unknown1: ULONG;
    MaxInstances: ULONG;
    CurInstances: ULONG;
    InBufferSize: ULONG;
    Unknown2: ULONG;
    OutBufferSize: ULONG;
    Unknown3: array[0..1] of ULONG;
    ServerEnd: ULONG;
  end;
  FILE_PIPE_LOCAL_INFORMATION = _FILE_PIPE_LOCAL_INFORMATION;
  PFILE_PIPE_LOCAL_INFORMATION = ^FILE_PIPE_LOCAL_INFORMATION;
  TFilePipeLocalInformation = FILE_PIPE_LOCAL_INFORMATION;
  PFilePipeLocalInformation = ^TFilePipeLocalInformation;

  _FILE_PIPE_REMOTE_INFORMATION = record // Information Class 25
    CollectDataTimeout: LARGE_INTEGER;
    MaxCollectionCount: ULONG;
  end;
  FILE_PIPE_REMOTE_INFORMATION = _FILE_PIPE_REMOTE_INFORMATION;
  PFILE_PIPE_REMOTE_INFORMATION = ^FILE_PIPE_REMOTE_INFORMATION;
  TFilePipeRemoteInformation = FILE_PIPE_REMOTE_INFORMATION;
  PFilePipeRemoteInformation = ^TFilePipeRemoteInformation;

  _FILE_MAILSLOT_QUERY_INFORMATION = record // Information Class 26
    MaxMessageSize: ULONG;
    Unknown: ULONG;
    NextSize: ULONG;
    MessageCount: ULONG;
    ReadTimeout: LARGE_INTEGER;
  end;
  FILE_MAILSLOT_QUERY_INFORMATION = _FILE_MAILSLOT_QUERY_INFORMATION;
  PFILE_MAILSLOT_QUERY_INFORMATION = ^FILE_MAILSLOT_QUERY_INFORMATION;
  TFileMailslotQueryInformation = FILE_MAILSLOT_QUERY_INFORMATION;
  PFileMailslotQueryInformation = ^TFileMailslotQueryInformation;

  _FILE_MAILSLOT_SET_INFORMATION = record // Information Class 27
    ReadTimeout: LARGE_INTEGER;
  end;
  FILE_MAILSLOT_SET_INFORMATION = _FILE_MAILSLOT_SET_INFORMATION;
  PFILE_MAILSLOT_SET_INFORMATION = ^FILE_MAILSLOT_SET_INFORMATION;
  TFileMailslotSetInformation = FILE_MAILSLOT_SET_INFORMATION;
  PFileMailslotSetInformation = ^TFileMailslotSetInformation;

  _FILE_COMPRESSION_INFORMATION = record // Information Class 28
    CompressedSize: LARGE_INTEGER;
    CompressionFormat: USHORT;
    CompressionUnitShift: UCHAR;
    Unknown: UCHAR;
    ClusterSizeShift: UCHAR;
  end;
  FILE_COMPRESSION_INFORMATION = _FILE_COMPRESSION_INFORMATION;
  PFILE_COMPRESSION_INFORMATION = ^FILE_COMPRESSION_INFORMATION;
  TFileCompressionInformation = FILE_COMPRESSION_INFORMATION;
  PFileCompressionInformation = ^TFileCompressionInformation;

  _FILE_COMPLETION_INFORMATION = record // Information Class 30
    IoCompletionHandle: HANDLE;
    CompletionKey: ULONG;
  end;
  FILE_COMPLETION_INFORMATION = _FILE_COMPLETION_INFORMATION;
  PFILE_COMPLETION_INFORMATION = ^FILE_COMPLETION_INFORMATION;
  TFileCompletionInformation = FILE_COMPLETION_INFORMATION;
  PFileCompletionInformation = ^TFileCompletionInformation;

type
  PEXECUTION_STATE = ^EXECUTION_STATE;
  PExecutionState = PEXECUTION_STATE;


type
  PLANGID = ^LANGID;
type
  _ATOM_INFORMATION_CLASS = (AtomBasicInformation, AtomListInformation);
  ATOM_INFORMATION_CLASS = _ATOM_INFORMATION_CLASS;
  TAtomInformationClass = ATOM_INFORMATION_CLASS;

type
  _ATOM_BASIC_INFORMATION = record
    ReferenceCount: USHORT;
    Pinned: USHORT;
    NameLength: USHORT;
    Name: array[0..0] of WCHAR;
  end;
  ATOM_BASIC_INFORMATION = _ATOM_BASIC_INFORMATION;
  PATOM_BASIC_INFORMATION = ^ATOM_BASIC_INFORMATION;
  TAtomBasicInformation = ATOM_BASIC_INFORMATION;
  PAtomBasicInformation = ^TAtomBasicInformation;

  _ATOM_LIST_INFORMATION = record
    NumberOfAtoms: ULONG;
    Atoms: array[0..0] of ATOM;
  end;
  ATOM_LIST_INFORMATION = _ATOM_LIST_INFORMATION;
  PATOM_LIST_INFORMATION = ^ATOM_LIST_INFORMATION;
  TAtomListInformation = ATOM_LIST_INFORMATION;
  PAtomListInformation = ^TAtomListInformation;

//==============================================================================
// NTFS on disk structure structures
//==============================================================================

type
  _NTFS_RECORD_HEADER = record
    Type_: ULONG;
    UsaOffset: USHORT;
    UsaCount: USHORT;
    Usn: USN;
  end;
  NTFS_RECORD_HEADER = _NTFS_RECORD_HEADER;
  PNTFS_RECORD_HEADER = ^NTFS_RECORD_HEADER;
  TNtfsRecordHeader = NTFS_RECORD_HEADER;
  PNtfsRecordHeader = ^TNtfsRecordHeader;

  _FILE_RECORD_HEADER = record
    Ntfs: NTFS_RECORD_HEADER;
    SequenceNumber: USHORT;
    LinkCount: USHORT;
    AttributesOffset: USHORT;
    Flags: USHORT; // 0x0001 = InUse, 0x0002 = Directory
    BytesInUse: ULONG;
    BytesAllocated: ULONG;
    BaseFileRecord: ULONGLONG;
    NextAttributeNumber: USHORT;
  end;
  FILE_RECORD_HEADER = _FILE_RECORD_HEADER;
  PFILE_RECORD_HEADER = ^FILE_RECORD_HEADER;
  TFileRecordHeader = FILE_RECORD_HEADER;
  PFileRecordHeader = ^TFileRecordHeader;

const
  AttributeStandardInformation = $10;
  AttributeAttributeList = $20;
  AttributeFileName = $30;
  AttributeObjectId = $40;
  AttributeSecurityDescriptor = $50;
  AttributeVolumeName = $60;
  AttributeVolumeInformation = $70;
  AttributeData = $80;
  AttributeIndexRoot = $90;
  AttributeIndexAllocation = $A0;
  AttributeBitmap = $B0;
  AttributeReparsePoint = $C0;
  AttributeEAInformation = $D0;
  AttributeEA = $E0;
  AttributePropertySet = $F0;
  AttributeLoggedUtilityStream = $100;

type
  ATTRIBUTE_TYPE = AttributeStandardInformation..AttributeLoggedUtilityStream;
  PATTRIBUTE_TYPE = ^ATTRIBUTE_TYPE;
  TAttributeType = ATTRIBUTE_TYPE;

  _ATTRIBUTE = record
    AttributeType: ATTRIBUTE_TYPE;
    Length: ULONG;
    Nonresident: ByteBool;
    NameLength: UCHAR;
    NameOffset: USHORT;
    Flags: USHORT; // 0x0001 = Compressed
    AttributeNumber: USHORT;
  end;
  ATTRIBUTE = _ATTRIBUTE;
  PATTRIBUTE = ^ATTRIBUTE;
  TAttribute = ATTRIBUTE;

  _RESIDENT_ATTRIBUTE = record
    Attribute: ATTRIBUTE;
    ValueLength: ULONG;
    ValueOffset: USHORT;
    Flags: USHORT; // 0x0001 = Indexed
  end;
  RESIDENT_ATTRIBUTE = _RESIDENT_ATTRIBUTE;
  PRESIDENT_ATTRIBUTE = ^RESIDENT_ATTRIBUTE;
  TResidentAttribute = RESIDENT_ATTRIBUTE;
  PResidentAttribute = ^TResidentAttribute;

  _NONRESIDENT_ATTRIBUTE = record
    Attribute: ATTRIBUTE;
    LowVcn: ULONGLONG;
    HighVcn: ULONGLONG;
    RunArrayOffset: USHORT;
    CompressionUnit: UCHAR;
    AlignmentOrReserved: array[0..4] of UCHAR;
    AllocatedSize: ULONGLONG;
    DataSize: ULONGLONG;
    InitializedSize: ULONGLONG;
    CompressedSize: ULONGLONG; // Only when compressed
  end;
  NONRESIDENT_ATTRIBUTE = _NONRESIDENT_ATTRIBUTE;
  PNONRESIDENT_ATTRIBUTE = ^NONRESIDENT_ATTRIBUTE;
  TNonResidentAttribute = NONRESIDENT_ATTRIBUTE;
  PNonResidentAttribute = ^TNonResidentAttribute;

  _STANDARD_INFORMATION = record
    CreationTime: ULONGLONG;
    ChangeTime: ULONGLONG;
    LastWriteTime: ULONGLONG;
    LastAccessTime: ULONGLONG;
    FileAttributes: ULONG;
    AlignmentOrReservedOrUnknown: array[0..2] of ULONG;
    QuotaId: ULONG; // NTFS 3.0 only
    SecurityId: ULONG; // NTFS 3.0 only
    QuotaCharge: ULONGLONG; // NTFS 3.0 only
    Usn: USN; // NTFS 3.0 only
  end;
  STANDARD_INFORMATION = _STANDARD_INFORMATION;
  PSTANDARD_INFORMATION = ^STANDARD_INFORMATION;
  TStandardInformation = STANDARD_INFORMATION;
  PStandardInformation = ^TStandardInformation;

  _ATTRIBUTE_LIST = record
    AttributeType: ATTRIBUTE_TYPE;
    Length: USHORT;
    NameLength: UCHAR;
    NameOffset: UCHAR;
    LowVcn: ULONGLONG;
    FileReferenceNumber: ULONGLONG;
    AttributeNumber: USHORT;
    AlignmentOrReserved: array[0..2] of USHORT;
  end;
  ATTRIBUTE_LIST = _ATTRIBUTE_LIST;
  PATTRIBUTE_LIST = ^ATTRIBUTE_LIST;
  TAttributeList = ATTRIBUTE_LIST;
  PAttributeList = ^TAttributeList;

  _FILENAME_ATTRIBUTE = record
    DirectoryFileReferenceNumber: ULONGLONG;
    CreationTime: ULONGLONG; // Saved when filename last changed
    ChangeTime: ULONGLONG; // ditto
    LastWriteTime: ULONGLONG; // ditto
    LastAccessTime: ULONGLONG; // ditto
    AllocatedSize: ULONGLONG; // ditto
    DataSize: ULONGLONG; // ditto
    FileAttributes: ULONG; // ditto
    AlignmentOrReserved: ULONG;
    NameLength: UCHAR;
    NameType: UCHAR; // 0x01 = Long, 0x02 = Short
    Name: array[0..0] of UCHAR;
  end;
  FILENAME_ATTRIBUTE = _FILENAME_ATTRIBUTE;
  PFILENAME_ATTRIBUTE = ^FILENAME_ATTRIBUTE;
  TFilenameAttribute = FILENAME_ATTRIBUTE;
  PFilenameAttribute = ^TFilenameAttribute;

  _OBJECTID_ATTRIBUTE = record
    ObjectId: GUID;
    case Integer of
      0: (
        BirthVolumeId: GUID;
        BirthObjectId: GUID;
        DomainId: GUID);
      1: (
        ExtendedInfo: array[0..47] of UCHAR
        );
  end;
  OBJECTID_ATTRIBUTE = _OBJECTID_ATTRIBUTE;
  POBJECTID_ATTRIBUTE = ^OBJECTID_ATTRIBUTE;
  TObjectIdAttribute = OBJECTID_ATTRIBUTE;
  PObjectIdAttribute = ^TObjectIdAttribute;

  _VOLUME_INFORMATION = record
    Unknown: array[0..1] of ULONG;
    MajorVersion: UCHAR;
    MinorVersion: UCHAR;
    Flags: USHORT;
  end;
  VOLUME_INFORMATION = _VOLUME_INFORMATION;
  PVOLUME_INFORMATION = ^VOLUME_INFORMATION;
  TVolumeInformation = VOLUME_INFORMATION;
  PVolumeInformation = ^TVolumeInformation;

  _DIRECTORY_INDEX = record
    EntriesOffset: ULONG;
    IndexBlockLength: ULONG;
    AllocatedSize: ULONG;
    Flags: ULONG; // 0x00 = Small directory, 0x01 = Large directory
  end;
  DIRECTORY_INDEX = _DIRECTORY_INDEX;
  PDIRECTORY_INDEX = ^DIRECTORY_INDEX;
  TDirectoryIndex = DIRECTORY_INDEX;
  PDirectoryIndex = ^TDirectoryIndex;

  _DIRECTORY_ENTRY = record
    FileReferenceNumber: ULONGLONG;
    Length: USHORT;
    AttributeLength: USHORT;
    Flags: ULONG; // 0x01 = Has trailing VCN, 0x02 = Last entry
    // FILENAME_ATTRIBUTE Name;
    // ULONGLONG Vcn;       // VCN in IndexAllocation of earlier entries
  end;
  DIRECTORY_ENTRY = _DIRECTORY_ENTRY;
  PDIRECTORY_ENTRY = ^DIRECTORY_ENTRY;
  TDirectoryEntry = DIRECTORY_ENTRY;
  PDirectoryEntry = ^TDirectoryEntry;

  _INDEX_ROOT = record
    Type_: ATTRIBUTE_TYPE;
    CollationRule: ULONG;
    BytesPerIndexBlock: ULONG;
    ClustersPerIndexBlock: ULONG;
    DirectoryIndex: DIRECTORY_INDEX;
  end;
  INDEX_ROOT = _INDEX_ROOT;
  PINDEX_ROOT = ^INDEX_ROOT;
  TIndexRoot = INDEX_ROOT;
  PIndexRoot = ^TIndexRoot;

  _INDEX_BLOCK_HEADER = record
    Ntfs: NTFS_RECORD_HEADER;
    IndexBlockVcn: ULONGLONG;
    DirectoryIndex: DIRECTORY_INDEX;
  end;
  INDEX_BLOCK_HEADER = _INDEX_BLOCK_HEADER;
  PINDEX_BLOCK_HEADER = ^INDEX_BLOCK_HEADER;
  TIndexBlockHeader = _INDEX_BLOCK_HEADER;
  PIndexBlockHeader = ^TIndexBlockHeader;

  _REPARSE_POINT = record
    ReparseTag: ULONG;
    ReparseDataLength: USHORT;
    Reserved: USHORT;
    ReparseData: array[0..0] of UCHAR;
  end;
  REPARSE_POINT = _REPARSE_POINT;
  PREPARSE_POINT = ^REPARSE_POINT;
  TReparsePoint = REPARSE_POINT;
  PReparsePoint = ^TReparsePoint;

  _EA_INFORMATION = record
    EaLength: ULONG;
    EaQueryLength: ULONG;
  end;
  EA_INFORMATION = _EA_INFORMATION;
  PEA_INFORMATION = ^EA_INFORMATION;
  TEaInformation = EA_INFORMATION;
  PEaInformation = ^TEaInformation;

  _EA_ATTRIBUTE = record
    NextEntryOffset: ULONG;
    Flags: UCHAR;
    EaNameLength: UCHAR;
    EaValueLength: USHORT;
    EaName: array[0..0] of CHAR;
    // UCHAR EaData[];
  end;
  EA_ATTRIBUTE = _EA_ATTRIBUTE;
  PEA_ATTRIBUTE = ^EA_ATTRIBUTE;
  TEaAttribute = EA_ATTRIBUTE;
  PEaAttribute = ^TEaAttribute;

  _ATTRIBUTE_DEFINITION = record
    AttributeName: array[0..63] of WCHAR;
    AttributeNumber: ULONG;
    Unknown: array[0..1] of ULONG;
    Flags: ULONG;
    MinimumSize: ULONGLONG;
    MaximumSize: ULONGLONG;
  end;
  ATTRIBUTE_DEFINITION = _ATTRIBUTE_DEFINITION;
  PATTRIBUTE_DEFINITION = ^ATTRIBUTE_DEFINITION;
  TAttributeDefinition = ATTRIBUTE_DEFINITION;
  PAttributeDefinition = ^TAttributeDefinition;

  _BOOT_BLOCK = record
    Jump: array[0..2] of UCHAR;
    Format: array[0..7] of UCHAR;
    BytesPerSector: USHORT;
    SectorsPerCluster: UCHAR;
    BootSectors: USHORT;
    Mbz1: UCHAR;
    Mbz2: USHORT;
    Reserved1: USHORT;
    MediaType: UCHAR;
    Mbz3: USHORT;
    SectorsPerTrack: USHORT;
    NumberOfHeads: USHORT;
    PartitionOffset: ULONG;
    Reserved2: array[0..1] of ULONG;
    TotalSectors: ULONGLONG;
    MftStartLcn: ULONGLONG;
    Mft2StartLcn: ULONGLONG;
    ClustersPerFileRecord: ULONG;
    ClustersPerIndexBlock: ULONG;
    VolumeSerialNumber: ULONGLONG;
    Code: array[0..$1AD] of UCHAR;
    BootSignature: USHORT;
  end;
  BOOT_BLOCK = _BOOT_BLOCK;
  PBOOT_BLOCK = ^BOOT_BLOCK;
  TBootBlock = BOOT_BLOCK;
  PBootBlock = ^TBootBlock;

const
  DBG_STATUS_CONTROL_C = 1;
  DBG_STATUS_SYSRQ = 2;
  DBG_STATUS_BUGCHECK_FIRST = 3;
  DBG_STATUS_BUGCHECK_SECOND = 4;
  DBG_STATUS_FATAL = 5;
  DBG_STATUS_DEBUG_CONTROL = 6;

//function DbgPrint(Format: PCH; ...): ULONG; cdecl;
//function DbgPrintReturnControlC(Format: PCH; ...): ULONG; cdecl;

//==============================================================================
// Runtime Library
//==============================================================================

const
  RTL_RANGE_LIST_ADD_IF_CONFLICT = $00000001;
  RTL_RANGE_LIST_ADD_SHARED = $00000002;

const
  RTL_RANGE_LIST_SHARED_OK = $00000001;
  RTL_RANGE_LIST_NULL_CONFLICT_OK = $00000002;

type
  PRTL_CONFLICT_RANGE_CALLBACK = function(Context: PVOID; Range: PRTL_RANGE): ByteBool; stdcall;

type
  _OSVERSIONINFOW = record
    dwOSVersionInfoSize: ULONG;
    dwMajorVersion: ULONG;
    dwMinorVersion: ULONG;
    dwBuildNumber: ULONG;
    dwPlatformId: ULONG;
    szCSDVersion: array[0..127] of WCHAR; // Maintenance string for PSS usage
  end;
  OSVERSIONINFOW = _OSVERSIONINFOW;
  POSVERSIONINFOW = ^OSVERSIONINFOW;
  LPOSVERSIONINFOW = ^OSVERSIONINFOW;
  RTL_OSVERSIONINFOW = OSVERSIONINFOW;
  PRTL_OSVERSIONINFOW = ^OSVERSIONINFOW;

  TOsVersionInfoW = OSVERSIONINFOW;
  //POsVersionInfoW = ^TOsVersionInfoW;

  OSVERSIONINFO = OSVERSIONINFOW;
  POSVERSIONINFO = POSVERSIONINFOW;
  LPOSVERSIONINFO = LPOSVERSIONINFOW;

const
  VER_PLATFORM_WIN32s = 0;
  VER_PLATFORM_WIN32_WINDOWS = 1;
  VER_PLATFORM_WIN32_NT = 2;

type
  _RTL_BITMAP = record
    SizeOfBitMap: ULONG; // Number of bits in bit map
    Buffer: PULONG; // Pointer to the bit map itself
  end;
  RTL_BITMAP = _RTL_BITMAP;
  PRTL_BITMAP = ^RTL_BITMAP;
  TRtlBitmap = RTL_BITMAP;
  PRtlBitmap = ^TRtlBitmap;

const
  RTL_REGISTRY_ABSOLUTE = 0; // Path is a full path
  RTL_REGISTRY_SERVICES = 1; // \Registry\Machine\System\CurrentControlSet\Services
  RTL_REGISTRY_CONTROL = 2; // \Registry\Machine\System\CurrentControlSet\Control
  RTL_REGISTRY_WINDOWS_NT = 3; // \Registry\Machine\Software\Microsoft\Windows NT\CurrentVersion
  RTL_REGISTRY_DEVICEMAP = 4; // \Registry\Machine\Hardware\DeviceMap
  RTL_REGISTRY_USER = 5; // \Registry\User\CurrentUser
  RTL_REGISTRY_MAXIMUM = 6;
  RTL_REGISTRY_HANDLE = $40000000; // Low order bits are registry handle
  RTL_REGISTRY_OPTIONAL = $80000000; // Indicates the key node is optional

type
  _TIME_FIELDS = record
    Year: CSHORT; // range [1601...]
    Month: CSHORT; // range [1..12]
    Day: CSHORT; // range [1..31]
    Hour: CSHORT; // range [0..23]
    Minute: CSHORT; // range [0..59]
    Second: CSHORT; // range [0..59]
    Milliseconds: CSHORT; // range [0..999]
    Weekday: CSHORT; // range [0..6] == [Sunday..Saturday]
  end;
  TIME_FIELDS = _TIME_FIELDS;
  PTIME_FIELDS = ^TIME_FIELDS;
  TTimeFields = TIME_FIELDS;
  PTimeFields = ^TTimeFields;

type
  _OSVERSIONINFOEXW = record
    dwOSVersionInfoSize: ULONG;
    dwMajorVersion: ULONG;
    dwMinorVersion: ULONG;
    dwBuildNumber: ULONG;
    dwPlatformId: ULONG;
    szCSDVersion: array[0..127] of WCHAR; // Maintenance string for PSS usage
    wServicePackMajor: USHORT;
    wServicePackMinor: USHORT;
    wSuiteMask: USHORT;
    wProductType: UCHAR;
    wReserved: UCHAR;
  end;
  OSVERSIONINFOEXW = _OSVERSIONINFOEXW;
  POSVERSIONINFOEXW = ^OSVERSIONINFOEXW;
  LPOSVERSIONINFOEXW = ^OSVERSIONINFOEXW;
  RTL_OSVERSIONINFOEXW = OSVERSIONINFOEXW;
  PRTL_OSVERSIONINFOEXW = ^OSVERSIONINFOEXW;

  TOsVersionInfoExW = OSVERSIONINFOEXW;
  //POsVersionInfoExW = ^TOsVersionInfoExW;

  OSVERSIONINFOEX = OSVERSIONINFOEXW;
  POSVERSIONINFOEX = POSVERSIONINFOEXW;
  LPOSVERSIONINFOEX = LPOSVERSIONINFOEXW;

//
// RtlVerifyVersionInfo() conditions
//

const
  VER_EQUAL = 1;
  VER_GREATER = 2;
  VER_GREATER_EQUAL = 3;
  VER_LESS = 4;
  VER_LESS_EQUAL = 5;
  VER_AND = 6;
  VER_OR = 7;

  VER_CONDITION_MASK = 7;
  VER_NUM_BITS_PER_CONDITION_MASK = 3;

//
// RtlVerifyVersionInfo() type mask bits
//

  VER_MINORVERSION = $0000001;
  VER_MAJORVERSION = $0000002;
  VER_BUILDNUMBER = $0000004;
  VER_PLATFORMID = $0000008;
  VER_SERVICEPACKMINOR = $0000010;
  VER_SERVICEPACKMAJOR = $0000020;
  VER_SUITENAME = $0000040;
  VER_PRODUCT_TYPE = $0000080;

//
// RtlVerifyVersionInfo() os product type values
//

  VER_NT_WORKSTATION = $0000001;
  VER_NT_DOMAIN_CONTROLLER = $0000002;
  VER_NT_SERVER = $0000003;

//
// Related constant(s) for RtlDetermineDosPathNameType_U()
//
  INVALID_PATH = 0;
  UNC_PATH = 1;
  ABSOLUTE_DRIVE_PATH = 2;
  RELATIVE_DRIVE_PATH = 3;
  ABSOLUTE_PATH = 4;
  RELATIVE_PATH = 5;
  DEVICE_PATH = 6;
  UNC_DOT_PATH = 7;

type
  PRTL_QUERY_REGISTRY_ROUTINE = function(ValueName: PWSTR; ValueType: ULONG;
    ValueData: PVOID; ValueLength: ULONG; Context, EntryContext: PVOID): NTSTATUS; stdcall;

  _RTL_QUERY_REGISTRY_TABLE = record
    QueryRoutine: PRTL_QUERY_REGISTRY_ROUTINE;
    Flags: ULONG;
    Name: PWSTR;
    EntryContext: PVOID;
    DefaultType: ULONG;
    DefaultData: PVOID;
    DefaultLength: ULONG;
  end;
  RTL_QUERY_REGISTRY_TABLE = _RTL_QUERY_REGISTRY_TABLE;
  PRTL_QUERY_REGISTRY_TABLE = ^RTL_QUERY_REGISTRY_TABLE;
  TRtlQueryRegistryTable = RTL_QUERY_REGISTRY_TABLE;
  PRtlQueryRegistryTable = ^TRtlQueryRegistryTable;

  REFGUID = ^GUID;
  TRefGuid = REFGUID;

const
  // Should be defined, but isn't
  HEAP_ZERO_MEMORY = $00000008;

type
// =================================================================
// PROCESS ENVIRONMENT BLOCK (PEB)
// =================================================================

// Verified in XP using WinDbg
  _LDR_DATA_TABLE_ENTRY = record // not packed!
    case Integer of
  (*   *)0: (
  (*000*)InLoadOrderLinks: LIST_ENTRY
        );
  (*   *)1: (
  (*000*)InMemoryOrderLinks: LIST_ENTRY
        );
  (*   *)2: (
  (*000*)InInitializationOrderLinks: LIST_ENTRY;
  (*008*)DllBase: PVOID;
  (*00c*)EntryPoint: PVOID;
  (*010*)SizeOfImage: ULONG;
  (*014*)FullDllName: UNICODE_STRING;
  (*01c*)BaseDllName: UNICODE_STRING;
  (*024*)Flags: ULONG;
  (*028*)LoadCount: USHORT;
  (*02a*)TlsIndex: USHORT;
  (*02c*)HashLinks: LIST_ENTRY;
  (*034*)SectionPointer: PVOID;
  (*038*)CheckSum: ULONG;
  (*03C*)TimeDateStamp: ULONG;
  (*040*)LoadedImports: PVOID;
  (*044*)EntryPointActivationContext: PVOID; // PACTIVATION_CONTEXT
  (*048*)PatchInformation: PVOID;
        )
  end;
  LDR_DATA_TABLE_ENTRY = _LDR_DATA_TABLE_ENTRY;
  PLDR_DATA_TABLE_ENTRY = ^_LDR_DATA_TABLE_ENTRY;
  PPLDR_DATA_TABLE_ENTRY = ^PLDR_DATA_TABLE_ENTRY;
  TLdrDataTableEntry = _LDR_DATA_TABLE_ENTRY;
  PLdrDataTableEntry = ^_LDR_DATA_TABLE_ENTRY;

// Verified in XP using WinDbg
  _PEB_LDR_DATA = record // not packed!
  (*000*)Length: ULONG;
  (*004*)Initialized: BOOLEAN;
  (*008*)SsHandle: PVOID;
  (*00c*)InLoadOrderModuleList: LIST_ENTRY;
  (*014*)InMemoryOrderModuleList: LIST_ENTRY;
  (*01c*)InInitializationOrderModuleList: LIST_ENTRY;
  (*024*)EntryInProgress: PVOID;
  end;
  PEB_LDR_DATA = _PEB_LDR_DATA;
  PPEB_LDR_DATA = ^_PEB_LDR_DATA;
  PPPEB_LDR_DATA = ^PPEB_LDR_DATA;
  TPebLdrData = _PEB_LDR_DATA;
  PPebLdrData = ^_PEB_LDR_DATA;

// Verified in XP using WinDbg
  _RTL_DRIVE_LETTER_CURDIR = record // not packed!
  (*000*)Flags: USHORT;
  (*002*)Length: USHORT;
  (*004*)TimeStamp: ULONG;
  (*008*)DosPath: _STRING;
  end;
  RTL_DRIVE_LETTER_CURDIR = _RTL_DRIVE_LETTER_CURDIR;
  PRTL_DRIVE_LETTER_CURDIR = ^_RTL_DRIVE_LETTER_CURDIR;
  PPRTL_DRIVE_LETTER_CURDIR = ^PRTL_DRIVE_LETTER_CURDIR;
  TRtlDriveLetterCurdir = _RTL_DRIVE_LETTER_CURDIR;
  PRtlDriveLetterCurdir = ^_RTL_DRIVE_LETTER_CURDIR;

  _CURDIR = record // not packed!
  (*000*)DosPath: UNICODE_STRING;
  (*008*)Handle: HANDLE;
  end;
  CURDIR = _CURDIR;
  PCURDIR = ^_CURDIR;
  PPCURDIR = ^PCURDIR;
  TCurdir = _CURDIR;
// PCurdir = ^_CURDIR; // <--- Pascal is case-insensitive

// Verified in XP using WinDbg
  _RTL_USER_PROCESS_PARAMETERS = record // not packed!
  (*000*)MaximumLength: ULONG;
  (*004*)Length: ULONG;
  (*008*)Flags: ULONG; // Bit 0: all pointers normalized
  (*00c*)DebugFlags: ULONG;
  (*010*)ConsoleHandle: HANDLE;
  (*014*)ConsoleFlags: ULONG;
  (*018*)StandardInput: HANDLE;
  (*01c*)StandardOutput: HANDLE;
  (*020*)StandardError: HANDLE;
  (*024*)CurrentDirectory: CURDIR;
  (*030*)DllPath: UNICODE_STRING;
  (*038*)ImagePathName: UNICODE_STRING;
  (*040*)CommandLine: UNICODE_STRING;
  (*048*)Environment: PVOID;
  (*04c*)StartingX: ULONG;
  (*050*)StartingY: ULONG;
  (*054*)CountX: ULONG;
  (*058*)CountY: ULONG;
  (*05c*)CountCharsX: ULONG;
  (*060*)CountCharsY: ULONG;
  (*064*)FillAttribute: ULONG;
  (*068*)WindowFlags: ULONG;
  (*06c*)ShowWindowFlags: ULONG;
  (*070*)WindowTitle: UNICODE_STRING;
  (*078*)DesktopInfo: UNICODE_STRING;
  (*080*)ShellInfo: UNICODE_STRING;
  (*088*)RuntimeData: UNICODE_STRING;
  (*090*)CurrentDirectories: array[0..31] of RTL_DRIVE_LETTER_CURDIR;
  end;
  RTL_USER_PROCESS_PARAMETERS = _RTL_USER_PROCESS_PARAMETERS;
  PRTL_USER_PROCESS_PARAMETERS = ^_RTL_USER_PROCESS_PARAMETERS;
  PPRTL_USER_PROCESS_PARAMETERS = ^PRTL_USER_PROCESS_PARAMETERS;
  TRtlUserProcessParameters = _RTL_USER_PROCESS_PARAMETERS;
  PRtlUserProcessParameters = ^_RTL_USER_PROCESS_PARAMETERS;
  TProcessParameters = _RTL_USER_PROCESS_PARAMETERS;
  PProcessParameters = ^_RTL_USER_PROCESS_PARAMETERS;

  _SYSTEM_STRINGS = record // not packed!
  (*000*)SystemRoot: UNICODE_STRING; // %SystemRoot%
  (*008*)System32Root: UNICODE_STRING; // %SystemRoot%\System32
  (*010*)BaseNamedObjects: UNICODE_STRING; // \BaseNamedObjects
  end;
  SYSTEM_STRINGS = _SYSTEM_STRINGS;
  PSYSTEM_STRINGS = ^_SYSTEM_STRINGS;
  PPSYSTEM_STRINGS = ^PSYSTEM_STRINGS;
  TSystemStrings = _SYSTEM_STRINGS;
  PSystemStrings = ^_SYSTEM_STRINGS;

// Verified in XP using WinDbg
  _TEXT_INFO = record // not packed!
  (*000*)Reserved: PVOID;
  (*004*)SystemStrings: PSYSTEM_STRINGS;
  end;
  TEXT_INFO = _TEXT_INFO;
  PTEXT_INFO = ^_TEXT_INFO;
  PPTEXT_INFO = ^PTEXT_INFO;
  TTextInfo = _TEXT_INFO;
  PTextInfo = ^_TEXT_INFO;

// Verified in XP using WinDbg
  PPEB_FREE_BLOCK = ^_PEB_FREE_BLOCK;
  _PEB_FREE_BLOCK = record // not packed!
  (*000*)Next: PPEB_FREE_BLOCK;
  (*004*)Size: ULONG;
  end;
  PEB_FREE_BLOCK = _PEB_FREE_BLOCK;
  PPPEB_FREE_BLOCK = ^PPEB_FREE_BLOCK;
  TPebFreeBlock = _PEB_FREE_BLOCK;
  PPebFreeBlock = ^_PEB_FREE_BLOCK;

// Verified in W2K, WXP and W2K3 using WinDbg
  _PEB_W2K = packed record // packed!
  (*000*)InheritedAddressSpace: BOOLEAN;
  (*001*)ReadImageFileExecOptions: BOOLEAN;
  (*002*)BeingDebugged: BOOLEAN;
  (*003*)SpareBool: BOOLEAN;
  (*004*)Mutant: PVOID;
  (*008*)ImageBaseAddress: PVOID;
  (*00c*)Ldr: PPEB_LDR_DATA;
  (*010*)ProcessParameters: PRTL_USER_PROCESS_PARAMETERS;
  (*014*)SubSystemData: PVOID;
  (*018*)ProcessHeap: PVOID;
  (*01c*)FastPebLock: PRTL_CRITICAL_SECTION;
  (*020*)FastPebLockRoutine: PVOID; // RtlEnterCriticalSection
  (*024*)FastPebUnlockRoutine: PVOID; // RtlLeaveCriticalSection
  (*028*)EnvironmentUpdateCount: ULONG;
  (*02c*)KernelCallbackTable: PPVOID; // List of callback functions
  (*030*)SystemReserved: array[0..0] of ULONG;
  (*034*)d034: ULONG;
  (*038*)FreeList: PPEB_FREE_BLOCK;
  (*03c*)TlsExpansionCounter: ULONG;
  (*040*)TlsBitmap: PVOID; // ntdll!TlsBitMap of type PRTL_BITMAP
  (*044*)TlsBitmapBits: array[0..1] of ULONG; // 64 bits
  (*04c*)ReadOnlySharedMemoryBase: PVOID;
  (*050*)ReadOnlySharedMemoryHeap: PVOID;
  (*054*)ReadOnlyStaticServerData: PTEXT_INFO;
  (*058*)AnsiCodePageData: PVOID;
  (*05c*)OemCodePageData: PVOID;
  (*060*)UnicodeCaseTableData: PVOID;
  (*064*)NumberOfProcessors: ULONG;
  (*068*)NtGlobalFlag: ULONG;
  (*06C*)Unknown01: ULONG; // Padding or something
  (*070*)CriticalSectionTimeout: LARGE_INTEGER;
  (*078*)HeapSegmentReserve: ULONG;
  (*07c*)HeapSegmentCommit: ULONG;
  (*080*)HeapDeCommitTotalFreeThreshold: ULONG;
  (*084*)HeapDeCommitFreeBlockThreshold: ULONG;
  (*088*)NumberOfHeaps: ULONG;
  (*08c*)MaximumNumberOfHeaps: ULONG;
  (*090*)ProcessHeaps: PPVOID;
  (*094*)GdiSharedHandleTable: PPVOID;
  (*098*)ProcessStarterHelper: PVOID;
  (*09c*)GdiDCAttributeList: ULONG;
  (*0a0*)LoaderLock: PCRITICAL_SECTION;
  (*0a4*)OSMajorVersion: ULONG;
  (*0a8*)OSMinorVersion: ULONG;
  (*0ac*)OSBuildNumber: USHORT;
  (*0ae*)OSCSDVersion: USHORT;
  (*0b0*)OSPlatformId: ULONG;
  (*0b4*)ImageSubsystem: ULONG;
  (*0b8*)ImageSubsystemMajorVersion: ULONG;
  (*0bc*)ImageSubsystemMinorVersion: ULONG;
  (*0c0*)ImageProcessAffinityMask: ULONG;
  (*0c4*)GdiHandleBuffer: array[0..33] of HANDLE;
  (*14c*)PostProcessInitRoutine: PVOID;
  (*150*)TlsExpansionBitmap: PVOID;
  (*154*)TlsExpansionBitmapBits: array[0..31] of ULONG;
  (*1d4*)SessionId: ULONG;
  // Windows 2000
  (*1d8*)AppCompatInfo: PVOID;
  (*1dc*)CSDVersion: UNICODE_STRING;
  end;

// Verified in W2K, WXP and W2K3 using WinDbg
  _PEB_WXP = packed record // packed!
  (*000*)InheritedAddressSpace: BOOLEAN;
  (*001*)ReadImageFileExecOptions: BOOLEAN;
  (*002*)BeingDebugged: BOOLEAN;
  (*003*)SpareBool: BOOLEAN;
  (*004*)Mutant: PVOID;
  (*008*)ImageBaseAddress: PVOID;
  (*00c*)Ldr: PPEB_LDR_DATA;
  (*010*)ProcessParameters: PRTL_USER_PROCESS_PARAMETERS;
  (*014*)SubSystemData: PVOID;
  (*018*)ProcessHeap: PVOID;
  (*01c*)FastPebLock: PRTL_CRITICAL_SECTION;
  (*020*)FastPebLockRoutine: PVOID; // RtlEnterCriticalSection
  (*024*)FastPebUnlockRoutine: PVOID; // RtlLeaveCriticalSection
  (*028*)EnvironmentUpdateCount: ULONG;
  (*02c*)KernelCallbackTable: PPVOID; // List of callback functions
  (*030*)SystemReserved: array[0..0] of ULONG;
  (*034*)AtlThunkSListPtr32: PVOID; // (Windows XP)
  (*038*)FreeList: PPEB_FREE_BLOCK;
  (*03c*)TlsExpansionCounter: ULONG;
  (*040*)TlsBitmap: PVOID; // ntdll!TlsBitMap of type PRTL_BITMAP
  (*044*)TlsBitmapBits: array[0..1] of ULONG; // 64 bits
  (*04c*)ReadOnlySharedMemoryBase: PVOID;
  (*050*)ReadOnlySharedMemoryHeap: PVOID;
  (*054*)ReadOnlyStaticServerData: PTEXT_INFO;
  (*058*)AnsiCodePageData: PVOID;
  (*05c*)OemCodePageData: PVOID;
  (*060*)UnicodeCaseTableData: PVOID;
  (*064*)NumberOfProcessors: ULONG;
  (*068*)NtGlobalFlag: ULONG;
  (*06C*)Unknown01: ULONG; // Padding or something
  (*070*)CriticalSectionTimeout: LARGE_INTEGER;
  (*078*)HeapSegmentReserve: ULONG;
  (*07c*)HeapSegmentCommit: ULONG;
  (*080*)HeapDeCommitTotalFreeThreshold: ULONG;
  (*084*)HeapDeCommitFreeBlockThreshold: ULONG;
  (*088*)NumberOfHeaps: ULONG;
  (*08c*)MaximumNumberOfHeaps: ULONG;
  (*090*)ProcessHeaps: PPVOID;
  (*094*)GdiSharedHandleTable: PPVOID;
  (*098*)ProcessStarterHelper: PVOID;
  (*09c*)GdiDCAttributeList: ULONG;
  (*0a0*)LoaderLock: PCRITICAL_SECTION;
  (*0a4*)OSMajorVersion: ULONG;
  (*0a8*)OSMinorVersion: ULONG;
  (*0ac*)OSBuildNumber: USHORT;
  (*0ae*)OSCSDVersion: USHORT;
  (*0b0*)OSPlatformId: ULONG;
  (*0b4*)ImageSubsystem: ULONG;
  (*0b8*)ImageSubsystemMajorVersion: ULONG;
  (*0bc*)ImageSubsystemMinorVersion: ULONG;
  (*0c0*)ImageProcessAffinityMask: ULONG;
  (*0c4*)GdiHandleBuffer: array[0..33] of HANDLE;
  (*14c*)PostProcessInitRoutine: PVOID;
  (*150*)TlsExpansionBitmap: PVOID;
  (*154*)TlsExpansionBitmapBits: array[0..31] of ULONG;
  (*1d4*)SessionId: ULONG;
  // Windows XP
  (*1d8*)AppCompatFlags: ULARGE_INTEGER;
  (*1e0*)AppCompatFlagsUser: ULARGE_INTEGER;
  (*1e8*)pShimData: PVOID;
  (*1ec*)AppCompatInfo: PVOID;
  (*1f0*)CSDVersion: UNICODE_STRING;
  (*1f8*)ActivationContextData: PVOID; // PACTIVATION_CONTEXT_DATA
  (*1fc*)ProcessAssemblyStorageMap: PVOID; // PASSEMBLY_STORAGE_MAP
  (*200*)SystemDefaultActivationContextData: PVOID; // PACTIVATION_CONTEXT_DATA
  (*204*)SystemAssemblyStorageMap: PVOID; // PASSEMBLY_STORAGE_MAP
  (*208*)MinimumStackCommit: ULONG;
  end;

// Verified in W2K, WXP and W2K3 using WinDbg
  _PEB_2K3 = packed record // packed!
  (*000*)InheritedAddressSpace: BOOLEAN;
  (*001*)ReadImageFileExecOptions: BOOLEAN;
  (*002*)BeingDebugged: BOOLEAN;
  (*003*)SpareBool: BOOLEAN;
  (*004*)Mutant: PVOID;
  (*008*)ImageBaseAddress: PVOID;
  (*00c*)Ldr: PPEB_LDR_DATA;
  (*010*)ProcessParameters: PRTL_USER_PROCESS_PARAMETERS;
  (*014*)SubSystemData: PVOID;
  (*018*)ProcessHeap: PVOID;
  (*01c*)FastPebLock: PRTL_CRITICAL_SECTION;
  (*020*)FastPebLockRoutine: PVOID; // RtlEnterCriticalSection
  (*024*)FastPebUnlockRoutine: PVOID; // RtlLeaveCriticalSection
  (*028*)EnvironmentUpdateCount: ULONG;
  (*02c*)KernelCallbackTable: PPVOID; // List of callback functions
  (*030*)SystemReserved: array[0..0] of ULONG;
  (*034*)ExecuteOptions: ULONG; // 2 Bits used (Windows 2003)
  (*038*)FreeList: PPEB_FREE_BLOCK;
  (*03c*)TlsExpansionCounter: ULONG;
  (*040*)TlsBitmap: PVOID; // ntdll!TlsBitMap of type PRTL_BITMAP
  (*044*)TlsBitmapBits: array[0..1] of ULONG; // 64 bits
  (*04c*)ReadOnlySharedMemoryBase: PVOID;
  (*050*)ReadOnlySharedMemoryHeap: PVOID;
  (*054*)ReadOnlyStaticServerData: PTEXT_INFO;
  (*058*)AnsiCodePageData: PVOID;
  (*05c*)OemCodePageData: PVOID;
  (*060*)UnicodeCaseTableData: PVOID;
  (*064*)NumberOfProcessors: ULONG;
  (*068*)NtGlobalFlag: ULONG;
  (*06C*)Unknown01: ULONG; // Padding or something
  (*070*)CriticalSectionTimeout: LARGE_INTEGER;
  (*078*)HeapSegmentReserve: ULONG;
  (*07c*)HeapSegmentCommit: ULONG;
  (*080*)HeapDeCommitTotalFreeThreshold: ULONG;
  (*084*)HeapDeCommitFreeBlockThreshold: ULONG;
  (*088*)NumberOfHeaps: ULONG;
  (*08c*)MaximumNumberOfHeaps: ULONG;
  (*090*)ProcessHeaps: PPVOID;
  (*094*)GdiSharedHandleTable: PPVOID;
  (*098*)ProcessStarterHelper: PVOID;
  (*09c*)GdiDCAttributeList: ULONG;
  (*0a0*)LoaderLock: PCRITICAL_SECTION;
  (*0a4*)OSMajorVersion: ULONG;
  (*0a8*)OSMinorVersion: ULONG;
  (*0ac*)OSBuildNumber: USHORT;
  (*0ae*)OSCSDVersion: USHORT;
  (*0b0*)OSPlatformId: ULONG;
  (*0b4*)ImageSubsystem: ULONG;
  (*0b8*)ImageSubsystemMajorVersion: ULONG;
  (*0bc*)ImageSubsystemMinorVersion: ULONG;
  (*0c0*)ImageProcessAffinityMask: ULONG;
  (*0c4*)GdiHandleBuffer: array[0..33] of HANDLE;
  (*14c*)PostProcessInitRoutine: PVOID;
  (*150*)TlsExpansionBitmap: PVOID;
  (*154*)TlsExpansionBitmapBits: array[0..31] of ULONG;
  (*1d4*)SessionId: ULONG;
  // Windows XP
  (*1d8*)AppCompatFlags: ULARGE_INTEGER;
  (*1e0*)AppCompatFlagsUser: ULARGE_INTEGER;
  (*1e8*)pShimData: PVOID;
  (*1ec*)AppCompatInfo: PVOID;
  (*1f0*)CSDVersion: UNICODE_STRING;
  (*1f8*)ActivationContextData: PVOID; // PACTIVATION_CONTEXT_DATA
  (*1fc*)ProcessAssemblyStorageMap: PVOID; // PASSEMBLY_STORAGE_MAP
  (*200*)SystemDefaultActivationContextData: PVOID; // PACTIVATION_CONTEXT_DATA
  (*204*)SystemAssemblyStorageMap: PVOID; // PASSEMBLY_STORAGE_MAP
  (*208*)MinimumStackCommit: ULONG;
  // New members in Windows 2003
  (*20c*)FlsCallback: PPVOID;
  (*210*)FlsListHead: LIST_ENTRY;
  (*218*)FlsBitmap: PVOID;
  (*21c*)FlsBitmapBits: array[0..3] of ULONG;
  (*22c*)FlsHighIndex: ULONG;
  end;

{$IFDEF WINNT4}
  _PEB = _PEB_W2K; // Exact layout for NT4 unknown
{$ENDIF}

{$IFDEF WIN2K}
  _PEB = _PEB_W2K;
{$ENDIF}

{$IFDEF WINXP}
  _PEB = _PEB_WXP;
{$ENDIF}

{$IFDEF WIN2K3}
  _PEB = _PEB_2K3;
{$ENDIF}

  PEB = _PEB;
  PPEB = ^_PEB;
  PPPEB = ^PPEB;

  _PROCESS_BASIC_INFORMATION = record
    ExitStatus: NTSTATUS;
    PebBaseAddress: PPEB;
    AffinityMask: ULONG;
    BasePriority: KPRIORITY;
    UniqueProcessId: ULONG;
    InheritedFromUniqueProcessId: ULONG;
  end;
  PROCESS_BASIC_INFORMATION = _PROCESS_BASIC_INFORMATION;
  PPROCESS_BASIC_INFORMATION = ^PROCESS_BASIC_INFORMATION;
  TProcessBasicInformation = PROCESS_BASIC_INFORMATION;
  PProcessBasicInformation = PPROCESS_BASIC_INFORMATION;

// =================================================================
// THREAD ENVIRONMENT BLOCK (TEB)
// =================================================================

  PNT_TIB = ^_NT_TIB;
  _NT_TIB = record
    ExceptionList: Pointer; // ^_EXCEPTION_REGISTRATION_RECORD
    StackBase,
      StackLimit,
      SubSystemTib: Pointer;
    case Integer of
      0: (
        FiberData: Pointer
        );
      1: (
        Version: ULONG;
        ArbitraryUserPointer: Pointer;
        Self: PNT_TIB;
        )
  end;
  NT_TIB = _NT_TIB;
  PPNT_TIB = ^PNT_TIB;

  tagACTCTX = record // not packed!
  (*000*)cbSize: ULONG;
  (*004*)dwFlags: DWORD;
  (*008*)lpSource: LPCWSTR;
  (*00C*)wProcessorArchitecture: USHORT;
  (*00E*)wLangId: LANGID;
  (*010*)lpAssemblyDirectory: LPCTSTR;
  (*014*)lpResourceName: LPCTSTR;
  (*018*)lpApplicationName: LPCTSTR;
  (*01C*)hModule: HMODULE;
  end;
  ACTCTX = tagACTCTX;
  PACTCTX = ^tagACTCTX;
  ACTIVATION_CONTEXT = tagACTCTX;
  PACTIVATION_CONTEXT = ^tagACTCTX;
  PPACTIVATION_CONTEXT = ^PACTIVATION_CONTEXT;

  PRTL_ACTIVATION_CONTEXT_STACK_FRAME = ^_RTL_ACTIVATION_CONTEXT_STACK_FRAME;
  _RTL_ACTIVATION_CONTEXT_STACK_FRAME = record // not packed!
  (*000*)Previous: PRTL_ACTIVATION_CONTEXT_STACK_FRAME;
  (*004*)ActivationContext: PACTIVATION_CONTEXT;
  (*008*)Flags: ULONG;
  end;
  RTL_ACTIVATION_CONTEXT_STACK_FRAME = _RTL_ACTIVATION_CONTEXT_STACK_FRAME;
  PPRTL_ACTIVATION_CONTEXT_STACK_FRAME = ^PRTL_ACTIVATION_CONTEXT_STACK_FRAME;

// Verified in XP using WinDbg
  _ACTIVATION_CONTEXT_STACK = record // not packed!
  (*000*)Flags: ULONG;
  (*004*)NextCookieSequenceNumber: ULONG;
  (*008*)ActiveFrame: PRTL_ACTIVATION_CONTEXT_STACK_FRAME;
  (*00c*)FrameListCache: LIST_ENTRY;
  end;
  ACTIVATION_CONTEXT_STACK = _ACTIVATION_CONTEXT_STACK;
  PACTIVATION_CONTEXT_STACK = ^_ACTIVATION_CONTEXT_STACK;
  PPACTIVATION_CONTEXT_STACK = ^PACTIVATION_CONTEXT_STACK;

// Verified in XP using WinDbg
  _GDI_TEB_BATCH = record // not packed!
  (*000*)Offset: ULONG;
  (*004*)HDC: HANDLE;
  (*008*)Buffer: array[0..309] of ULONG;
  end;
  GDI_TEB_BATCH = _GDI_TEB_BATCH;
  PGDI_TEB_BATCH = ^_GDI_TEB_BATCH;
  PPGDI_TEB_BATCH = ^PGDI_TEB_BATCH;

// Verified in XP using WinDbg
  _Wx86ThreadState = packed record // packed!
  (*000*)CallBx86Eip: PULONG;
  (*004*)DeallocationCpu: PVOID;
  (*008*)UseKnownWx86Dll: BOOLEAN;
  (*009*)OleStubInvoked: CHAR;
  end;
  Wx86ThreadState = _Wx86ThreadState;
  PWx86ThreadState = ^_Wx86ThreadState;
  PPWx86ThreadState = ^PWx86ThreadState;

// Verified in XP using WinDbg
  _TEB_ACTIVE_FRAME_CONTEXT = record // not packed!
  (*000*)Flags: ULONG;
  (*004*)FrameName: PCHAR;
  end;
  TEB_ACTIVE_FRAME_CONTEXT = _TEB_ACTIVE_FRAME_CONTEXT;
  PTEB_ACTIVE_FRAME_CONTEXT = ^_TEB_ACTIVE_FRAME_CONTEXT;
  PPTEB_ACTIVE_FRAME_CONTEXT = ^PTEB_ACTIVE_FRAME_CONTEXT;

// Verified in XP using WinDbg
  PTEB_ACTIVE_FRAME = ^_TEB_ACTIVE_FRAME;
  _TEB_ACTIVE_FRAME = record // not packed!
  (*000*)Flags: ULONG;
  (*004*)Previous: PTEB_ACTIVE_FRAME;
  (*008*)Context: PTEB_ACTIVE_FRAME_CONTEXT;
  end;
  TEB_ACTIVE_FRAME = _TEB_ACTIVE_FRAME;
  PPTEB_ACTIVE_FRAME = ^PTEB_ACTIVE_FRAME;

// Verified in W2K, WXP and W2K3 using WinDbg
  _TEB = record // not packed!
  (*000*)NtTib: NT_TIB;
  (*01c*)EnvironmentPointer: PVOID;
  (*020*)ClientId: CLIENT_ID;
  (*028*)ActiveRpcHandle: PVOID;
  (*02c*)ThreadLocalStoragePointer: PVOID;
  (*030*)Peb: PPEB;
  (*034*)LastErrorValue: ULONG;
  (*038*)CountOfOwnedCriticalSections: ULONG;
  (*03c*)CsrClientThread: PVOID;
  (*040*)Win32ThreadInfo: PVOID;
  (*044*)User32Reserved: array[0..25] of ULONG;
  (*0ac*)UserReserved: array[0..4] of ULONG;
  (*0c0*)WOW32Reserved: PVOID;
  (*0c4*)CurrentLocale: LCID;
  (*0c8*)FpSoftwareStatusRegister: ULONG;
  (*0cc*)SystemReserved1: array[0..53] of PVOID;
  (*1a4*)ExceptionCode: LONG;
  (*1a8*)ActivationContextStack: ACTIVATION_CONTEXT_STACK;
  (*1bc*)SpareBytes1: array[0..23] of UCHAR;
  (*1d4*)GdiTebBatch: GDI_TEB_BATCH;
  (*6b4*)RealClientId: CLIENT_ID;
  (*6bc*)GdiCachedProcessHandle: PVOID;
  (*6c0*)GdiClientPID: ULONG;
  (*6c4*)GdiClientTID: ULONG;
  (*6c8*)GdiThreadLocalInfo: PVOID;
  (*6cc*)Win32ClientInfo: array[0..61] of ULONG;
  (*7c4*)glDispatchTable: array[0..232] of PVOID;
  (*b68*)glReserved1: array[0..28] of ULONG;
  (*bdc*)glReserved2: PVOID;
  (*be0*)glSectionInfo: PVOID;
  (*be4*)glSection: PVOID;
  (*be8*)glTable: PVOID;
  (*bec*)glCurrentRC: PVOID;
  (*bf0*)glContext: PVOID;
  (*bf4*)LastStatusValue: ULONG;
  (*bf8*)StaticUnicodeString: UNICODE_STRING;
  (*c00*)StaticUnicodeBuffer: array[0..MAX_PATH] of WCHAR;
  (*e0a*)Padding: USHORT;
  (*e0c*)DeallocationStack: PVOID;
  (*e10*)TlsSlots: array[0..63] of PVOID;
  (*f10*)TlsLinks: LIST_ENTRY;
  (*f18*)Vdm: PVOID;
  (*f1c*)ReservedForNtRpc: PVOID;
  (*f20*)DbgSsReserved: array[0..1] of PVOID;
    case Integer of
  (*   *)0: (
  (*f28*)HardErrorMode: ULONG // (Windows 2003)
        );
  (*   *)1: (
  (*f28*)HardErrorsAreDisabled: ULONG; // (Windows XP)
  (*f2c*)Instrumentation: array[0..15] of PVOID;
  (*f6c*)WinSockData: PVOID;
  (*f70*)GdiBatchCount: ULONG;
  (*f74*)InDbgPrint: BOOLEAN;
  (*f75*)FreeStackOnTermination: BOOLEAN;
  (*f76*)HasFiberData: BOOLEAN;
  (*f77*)IdealProcessor: BOOLEAN;
  (*f78*)Spare3: ULONG;
  (*f7c*)ReservedForPerf: PVOID;
  (*f80*)ReservedForOle: PVOID;
  (*f84*)WaitingOnLoaderLock: PVOID;
  (*f88*)Wx86Thread: Wx86ThreadState;
  (*f94*)TlsExpansionSlots: PPVOID;
  (*f98*)ImpersonationLocale: LCID;
  (*f9c*)IsImpersonating: ULONG;
  (*fa0*)NlsCache: PVOID;
  (*fa4*)pShimData: PVOID;
  (*fa8*)HeapVirtualAffinity: ULONG;
  (*fac*)CurrentTransactionHandle: PVOID;
  (*fb0*)ActiveFrame: PTEB_ACTIVE_FRAME;
        case Integer of
          0: (
  (*fb4*)SafeThunkCall: BOOLEAN; // Before Windows 2003
  (*fb5*)BooleanSpare: array[0..2] of BOOLEAN // Before Windows 2003
            );
          1: (
  (*fb4*)FlsData: PVOID; // Starting with Windows 2003
            )
          )
  end;
  TEB = _TEB;
  PTEB = ^_TEB;
  PPTEB = ^PTEB;

type
  _OBJECT_NAME_INFORMATION = record
    Name: UNICODE_STRING;
  end;
  OBJECT_NAME_INFORMATION = _OBJECT_NAME_INFORMATION;
  POBJECT_NAME_INFORMATION = ^OBJECT_NAME_INFORMATION;
  TObjectNameInformation = OBJECT_NAME_INFORMATION;
  PObjectNameInformation = ^OBJECT_NAME_INFORMATION;

const
  NtCurrentProcess = HANDLE(-1);
  NtCurrentThread = HANDLE(-2);

// Object Manager specific stuff
  OBJ_NAME_PATH_SEPARATOR = '\';

// Object Manager Object Type Specific Access Rights.
  OBJECT_TYPE_CREATE = $0001;
  OBJECT_TYPE_ALL_ACCESS = STANDARD_RIGHTS_REQUIRED or $1;

// Object Manager Directory Specific Access Rights.
  DIRECTORY_QUERY = $0001;
  DIRECTORY_TRAVERSE = $0002;
  DIRECTORY_CREATE_OBJECT = $0004;
  DIRECTORY_CREATE_SUBDIRECTORY = $0008;
  DIRECTORY_ALL_ACCESS = STANDARD_RIGHTS_REQUIRED or $F;

// Object Manager Symbolic Link Specific Access Rights.
  SYMBOLIC_LINK_QUERY = $0001;
  SYMBOLIC_LINK_ALL_ACCESS = STANDARD_RIGHTS_REQUIRED or $1;

  DUPLICATE_CLOSE_SOURCE = $00000001;
  DUPLICATE_SAME_ACCESS = $00000002;
  DUPLICATE_SAME_ATTRIBUTES = $00000004;

//
// Define the access check value for any access
//
//
// The FILE_READ_ACCESS and FILE_WRITE_ACCESS constants are also defined in
// ntioapi.h as FILE_READ_DATA and FILE_WRITE_DATA. The values for these
// constants *MUST* always be in sync.
//
//
// FILE_SPECIAL_ACCESS is checked by the NT I/O system the same as FILE_ANY_ACCESS.
// The file systems, however, may add additional access checks for I/O and FS controls
// that use this value.
//

  FILE_ANY_ACCESS = 0;
  FILE_SPECIAL_ACCESS = FILE_ANY_ACCESS;
  FILE_READ_ACCESS = $0001; // file & pipe
  FILE_WRITE_ACCESS = $0002; // file & pipe

//
// Define share access rights to files and directories
//
  FILE_SHARE_READ = $00000001; // JwaWinNT.pas
  FILE_SHARE_WRITE = $00000002; // JwaWinNT.pas
  FILE_SHARE_DELETE = $00000004; // JwaWinNT.pas
  FILE_SHARE_VALID_FLAGS = $00000007;

//
// Define the file attributes values
//
// Note:  = $00000008 is reserved for use for the old DOS VOLID (volume ID)
//        and is therefore not considered valid in NT.
//
// Note:  = $00000010 is reserved for use for the old DOS SUBDIRECTORY flag
//        and is therefore not considered valid in NT.  This flag has
//        been disassociated with file attributes since the other flags are
//        protected with READ_ and WRITE_ATTRIBUTES access to the file.
//
// Note:  Note also that the order of these flags is set to allow both the
//        FAT and the Pinball File Systems to directly set the attributes
//        flags in attributes words without having to pick each flag out
//        individually.  The order of these flags should not be changed!
//

  FILE_ATTRIBUTE_READONLY = $00000001; 
  FILE_ATTRIBUTE_HIDDEN = $00000002; 
  FILE_ATTRIBUTE_SYSTEM = $00000004; 
//OLD DOS VOLID                               = $00000008

  FILE_ATTRIBUTE_DIRECTORY = $00000010; 
  FILE_ATTRIBUTE_ARCHIVE = $00000020; 
  FILE_ATTRIBUTE_DEVICE = $00000040; 
  FILE_ATTRIBUTE_NORMAL = $00000080; 

  FILE_ATTRIBUTE_TEMPORARY = $00000100; 
  FILE_ATTRIBUTE_SPARSE_FILE = $00000200; 
  FILE_ATTRIBUTE_REPARSE_POINT = $00000400; 
  FILE_ATTRIBUTE_COMPRESSED = $00000800; 

  FILE_ATTRIBUTE_OFFLINE = $00001000; 
  FILE_ATTRIBUTE_NOT_CONTENT_INDEXED = $00002000; 
  FILE_ATTRIBUTE_ENCRYPTED = $00004000;

//
//  This definition is old and will disappear shortly
//

  FILE_ATTRIBUTE_VALID_FLAGS = $00007FB7;
  FILE_ATTRIBUTE_VALID_SET_FLAGS = $000031A7;

//
// Define the create disposition values
//

  FILE_SUPERSEDE = $00000000;
  FILE_OPEN = $00000001;
  FILE_CREATE = $00000002;
  FILE_OPEN_IF = $00000003;
  FILE_OVERWRITE = $00000004;
  FILE_OVERWRITE_IF = $00000005;
  FILE_MAXIMUM_DISPOSITION = $00000005;

//
// Define the create/open option flags
//

  FILE_DIRECTORY_FILE = $00000001;
  FILE_WRITE_THROUGH = $00000002;
  FILE_SEQUENTIAL_ONLY = $00000004;
  FILE_NO_INTERMEDIATE_BUFFERING = $00000008;

  FILE_SYNCHRONOUS_IO_ALERT = $00000010;
  FILE_SYNCHRONOUS_IO_NONALERT = $00000020;
  FILE_NON_DIRECTORY_FILE = $00000040;
  FILE_CREATE_TREE_CONNECTION = $00000080;

  FILE_COMPLETE_IF_OPLOCKED = $00000100;
  FILE_NO_EA_KNOWLEDGE = $00000200;
  FILE_OPEN_FOR_RECOVERY = $00000400;
  FILE_RANDOM_ACCESS = $00000800;

  FILE_DELETE_ON_CLOSE = $00001000;
  FILE_OPEN_BY_FILE_ID = $00002000;
  FILE_OPEN_FOR_BACKUP_INTENT = $00004000;
  FILE_NO_COMPRESSION = $00008000;

  FILE_RESERVE_OPFILTER = $00100000;
  FILE_OPEN_REPARSE_POINT = $00200000;
  FILE_OPEN_NO_RECALL = $00400000;
  FILE_OPEN_FOR_FREE_SPACE_QUERY = $00800000;

  FILE_COPY_STRUCTURED_STORAGE = $00000041;
  FILE_STRUCTURED_STORAGE = $00000441;

  FILE_VALID_OPTION_FLAGS = $00FFFFFF;
  FILE_VALID_PIPE_OPTION_FLAGS = $00000032;
  FILE_VALID_MAILSLOT_OPTION_FLAGS = $00000032;
  FILE_VALID_SET_FLAGS = $00000036;

//
// Define the I/O status information return values for NtCreateFile/NtOpenFile
//

  FILE_SUPERSEDED = $00000000;
  FILE_OPENED = $00000001;
  FILE_CREATED = $00000002;
  FILE_OVERWRITTEN = $00000003;
  FILE_EXISTS = $00000004;
  FILE_DOES_NOT_EXIST = $00000005;

//
// Define special ByteOffset parameters for read and write operations
//

  FILE_WRITE_TO_END_OF_FILE = $FFFFFFFF;
  FILE_USE_FILE_POINTER_POSITION = $FFFFFFFE;

//
// Define alignment requirement values
//

  FILE_BYTE_ALIGNMENT = $00000000;
  FILE_WORD_ALIGNMENT = $00000001;
  FILE_LONG_ALIGNMENT = $00000003;
  FILE_QUAD_ALIGNMENT = $00000007;
  FILE_OCTA_ALIGNMENT = $0000000F;
  FILE_32_BYTE_ALIGNMENT = $0000001F;
  FILE_64_BYTE_ALIGNMENT = $0000003F;
  FILE_128_BYTE_ALIGNMENT = $0000007F;
  FILE_256_BYTE_ALIGNMENT = $000000FF;
  FILE_512_BYTE_ALIGNMENT = $000001FF;

//
// Define the maximum length of a filename string
//

  MAXIMUM_FILENAME_LENGTH = 256;

//
// Define the various device characteristics flags
//

  FILE_REMOVABLE_MEDIA = $00000001;
  FILE_READ_ONLY_DEVICE = $00000002;
  FILE_FLOPPY_DISKETTE = $00000004;
  FILE_WRITE_ONCE_MEDIA = $00000008;
  FILE_REMOTE_DEVICE = $00000010;
  FILE_DEVICE_IS_MOUNTED = $00000020;
  FILE_VIRTUAL_VOLUME = $00000040;
  FILE_AUTOGENERATED_DEVICE_NAME = $00000080;
  FILE_DEVICE_SECURE_OPEN = $00000100;

//
// Define kernel debugger print prototypes and macros.
//
// N.B. The following function cannot be directly imported because there are
//      a few places in the source tree where this function is redefined.
//
//procedure DbgBreakPoint(); stdcall;
//procedure DbgUserBreakPoint(); stdcall;
//procedure DbgBreakPointWithStatus(Status: ULONG); stdcall;

//// BEGIN: Reverse function forwarders and custom functions
//// Using Kernel32 function with same functionality for macros and "future version" functions
(* Compatibility: All *)
procedure RtlCopyMemory(
  Destination: PVOID;
  Source: PVOID;
  Length: SIZE_T
  ); stdcall; // Own replacement function

(* XREF: see GetLastError()! *)
(* Compatibility: All *)
// This functions was introduced with Windows XP. The Kernel32 version
// is a function forwarder for this function.
function RtlGetLastWin32Error(): DWORD; external 'kernel32.dll' name 'GetLastError'; // imported as kernel32!GetLastError

(* XREF: see SetLastError()! *)
(* Compatibility: All *)
// This functions was introduced with Windows XP. The Kernel32 version
// is a function forwarder for this function.
procedure RtlSetLastWin32Error(dwErrCode: DWORD); external 'kernel32.dll' name 'SetLastError'; // imported as kernel32!SetLastError

// Own function to retrieve the process's heap handle
(* XREF: see GetProcessHeap()! *)
(* Compatibility: All *)
function NtpGetProcessHeap(): HANDLE;

// Own function to retrieve the thread environment block (TEB) pointer
(* Compatibility: All *)
function NtpCurrentTeb(): PTEB;

// Own function to retrieve the process environment block (PEB) pointer
(* Compatibility: All *)
function RtlpGetCurrentPeb(): PPEB;

// No FASTCALL directive exists in Delphi so we write our own versions ...
// Own function to swap bytes in 16bit values
function RtlUshortByteSwap(Source: USHORT): USHORT;

// Own function to swap bytes in 32bit values
function RtlUlongByteSwap(Source: ULONG): ULONG;

// Own function to swap bytes in 64bit values
function RtlUlonglongByteSwap(Source: ULONGLONG): ULONGLONG;

// Resembles the RtlValidateUnicodeString() function available from Windows XP
// on exactly as it is on this OS version, except for the calling convention.
function RtlpValidateUnicodeString(dwMustBeNull: DWORD; UnicodeString: PUNICODE_STRING): NTSTATUS;

// Resembles the RtlValidateUnicodeString() function available from Windows XP
// on, but does not require the first parameter which anyway must be zero.
function RtlpValidateUnicodeString2(UnicodeString: PUNICODE_STRING): NTSTATUS;

//// END  : Reverse function forwarders and custom functions

//// BEGIN: Function prototypes
// Compatibility: WXP, 2K3
function  CsrGetProcessId(): DWORD; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  DbgQueryDebugFilterState(
    ComponentId : ULONG;
    Level : ULONG
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  DbgSetDebugFilterState(
    ComponentId : ULONG;
    Level : ULONG;
    State : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Unknown return value, maybe NTSTATUS?
// Compatibility: NT4, W2K, WXP, 2K3
function  KiRaiseUserExceptionDispatcher(): ULONG; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  LdrAccessResource(
    hModule : HANDLE;
    ResourceDataEntry : PIMAGE_RESOURCE_DATA_ENTRY;
    Address : PPVOID;
    dwSize : PULONG
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  LdrAlternateResourcesEnabled(): BOOLEAN; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  LdrDisableThreadCalloutsForDll(
    hModule : HANDLE
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to GetModuleHandle() from Kernel32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  LdrGetDllHandle(
    pwPath : PWORD;
    pReserved : PVOID;
    pusPath : PUNICODE_STRING;
    var phModule : HANDLE
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to GetProcAddress() from Kernel32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  LdrGetProcedureAddress(
    hModule : HANDLE;
    dwOrdinal : ULONG;
    psName : PSTRING;
    var pProcedure : PVOID
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to LoadLibrary() from Kernel32.dll. Refer
// to the PSDK for additional information. Usually the same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  LdrLoadDll(
    pwPath : PWORD;
    pdwFlags : PDWORD;
    pusPath : PUNICODE_STRING;
    var phModule : HANDLE
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  LdrQueryImageFileExecutionOptions(
    pusImagePath : PUNICODE_STRING;
    pwOptionName : PWORD;
    dwRequestedType : DWORD;
    pData : PVOID;
    dwSize : DWORD;
    pdwSize : PDWORD
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  LdrQueryProcessModuleInformation(
    psmi : PSYSTEM_MODULE_INFORMATION;
    dwSize : DWORD;
    pdwSize : PDWORD
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to TerminateProcess() from Kernel32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure LdrShutdownProcess(); stdcall; external ntdll;

// This function is very similar to TerminateThread() from Kernel32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure LdrShutdownThread(); stdcall; external ntdll;

// This function is very similar to FreeLibrary() from Kernel32.dll. Refer
// to the PSDK for additional information. Usually the same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  LdrUnloadDll(
    hModule : HANDLE
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtAcceptConnectPort(
    PortHandle : PHANDLE;
    PortIdentifier : ULONG;
    Message : PPORT_MESSAGE;
    Accept : BOOLEAN;
    WriteSection : PPORT_SECTION_WRITE;
    ReadSection : PPORT_SECTION_READ
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAcceptConnectPort(PortHandle: PHANDLE; PortIdentifier: ULONG; Message: PPORT_MESSAGE; Accept: BOOLEAN; WriteSection: PPORT_SECTION_WRITE; ReadSection: PPORT_SECTION_READ): NTSTATUS; stdcall; external ntdll;
   

// This function is very similar to AccessCheck() from Advapi32.dll. Refer
// to the PSDK for additional information. Usually the same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtAccessCheck(
    SecurityDescriptor : PSECURITY_DESCRIPTOR;
    TokenHandle : HANDLE;
    DesiredAccess : ACCESS_MASK;
    GenericMapping : PGENERIC_MAPPING;
    PrivilegeSet : PPRIVILEGE_SET;
    PrivilegeSetLength : PULONG;
    GrantedAccess : PACCESS_MASK;
    AccessStatus : PBOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAccessCheck(SecurityDescriptor: PSECURITY_DESCRIPTOR; TokenHandle: HANDLE; DesiredAccess: ACCESS_MASK; GenericMapping: PGENERIC_MAPPING; PrivilegeSet: PPRIVILEGE_SET; PrivilegeSetLength: PULONG; GrantedAccess: PACCESS_MASK;
    AccessStatus: PBOOLEAN): NTSTATUS; stdcall; external ntdll;

// This function is very similar to AccessCheckAndAuditAlarm() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtAccessCheckAndAuditAlarm(
    SubsystemName : PUNICODE_STRING;
    HandleId : PVOID;
    ObjectTypeName : PUNICODE_STRING;
    ObjectName : PUNICODE_STRING;
    SecurityDescriptor : PSECURITY_DESCRIPTOR;
    DesiredAccess : ACCESS_MASK;
    GenericMapping : PGENERIC_MAPPING;
    ObjectCreation : BOOLEAN;
    GrantedAccess : PACCESS_MASK;
    AccessStatus : PBOOLEAN;
    GenerateOnClose : PBOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAccessCheckAndAuditAlarm(SubsystemName: PUNICODE_STRING; HandleId: PVOID; ObjectTypeName: PUNICODE_STRING; ObjectName: PUNICODE_STRING; SecurityDescriptor: PSECURITY_DESCRIPTOR; DesiredAccess: ACCESS_MASK;
    GenericMapping: PGENERIC_MAPPING; ObjectCreation: BOOLEAN; GrantedAccess: PACCESS_MASK; AccessStatus: PBOOLEAN; GenerateOnClose: PBOOLEAN): NTSTATUS; stdcall; external ntdll;

// This function is very similar to AccessCheckByType() from Advapi32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: W2K, WXP, 2K3
function  NtAccessCheckByType(
    SecurityDescriptor : PSECURITY_DESCRIPTOR;
    PrincipalSelfSid : PSID;
    TokenHandle : HANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectTypeList : POBJECT_TYPE_LIST;
    ObjectTypeListLength : ULONG;
    GenericMapping : PGENERIC_MAPPING;
    PrivilegeSet : PPRIVILEGE_SET;
    PrivilegeSetLength : PULONG;
    GrantedAccess : PACCESS_MASK;
    AccessStatus : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAccessCheckByType(SecurityDescriptor: PSECURITY_DESCRIPTOR; PrincipalSelfSid: PSID; TokenHandle: HANDLE; DesiredAccess: ACCESS_MASK; ObjectTypeList: POBJECT_TYPE_LIST; ObjectTypeListLength: ULONG;
    GenericMapping: PGENERIC_MAPPING; PrivilegeSet: PPRIVILEGE_SET; PrivilegeSetLength: PULONG; GrantedAccess: PACCESS_MASK; AccessStatus: PULONG): NTSTATUS; stdcall; external ntdll;

// This function is very similar to AccessCheckByTypeAndAuditAlarm() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: W2K, WXP, 2K3
function  NtAccessCheckByTypeAndAuditAlarm(
    SubsystemName : PUNICODE_STRING;
    HandleId : PVOID;
    ObjectTypeName : PUNICODE_STRING;
    ObjectName : PUNICODE_STRING;
    SecurityDescriptor : PSECURITY_DESCRIPTOR;
    PrincipalSelfSid : PSID;
    DesiredAccess : ACCESS_MASK;
    AuditType : AUDIT_EVENT_TYPE;
    Flags : ULONG;
    ObjectTypeList : POBJECT_TYPE_LIST;
    ObjectTypeListLength : ULONG;
    GenericMapping : PGENERIC_MAPPING;
    ObjectCreation : BOOLEAN;
    GrantedAccess : PACCESS_MASK;
    AccessStatus : PULONG;
    GenerateOnClose : PBOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAccessCheckByTypeAndAuditAlarm(SubsystemName: PUNICODE_STRING; HandleId: PVOID; ObjectTypeName: PUNICODE_STRING; ObjectName: PUNICODE_STRING; SecurityDescriptor: PSECURITY_DESCRIPTOR; PrincipalSelfSid: PSID;
    DesiredAccess: ACCESS_MASK; AuditType: AUDIT_EVENT_TYPE; Flags: ULONG; ObjectTypeList: POBJECT_TYPE_LIST; ObjectTypeListLength: ULONG; GenericMapping: PGENERIC_MAPPING; ObjectCreation: BOOLEAN; GrantedAccess: PACCESS_MASK;
    AccessStatus: PULONG; GenerateOnClose: PBOOLEAN): NTSTATUS; stdcall; external ntdll;

// This function is very similar to AccessCheckByTypeResultList() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: W2K, WXP, 2K3
function  NtAccessCheckByTypeResultList(
    SecurityDescriptor : PSECURITY_DESCRIPTOR;
    PrincipalSelfSid : PSID;
    TokenHandle : HANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectTypeList : POBJECT_TYPE_LIST;
    ObjectTypeListLength : ULONG;
    GenericMapping : PGENERIC_MAPPING;
    PrivilegeSet : PPRIVILEGE_SET;
    PrivilegeSetLength : PULONG;
    GrantedAccessList : PACCESS_MASK;
    AccessStatusList : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAccessCheckByTypeResultList(SecurityDescriptor: PSECURITY_DESCRIPTOR; PrincipalSelfSid: PSID; TokenHandle: HANDLE; DesiredAccess: ACCESS_MASK; ObjectTypeList: POBJECT_TYPE_LIST; ObjectTypeListLength: ULONG;
    GenericMapping: PGENERIC_MAPPING; PrivilegeSet: PPRIVILEGE_SET; PrivilegeSetLength: PULONG; GrantedAccessList: PACCESS_MASK; AccessStatusList: PULONG): NTSTATUS; stdcall; external ntdll;

// This function is very similar to
// AccessCheckByTypeResultListAndAuditAlarm() from Advapi32.dll. Refer to
// the PSDK for additional information. Usually the same flags apply.
// Compatibility: W2K, WXP, 2K3
function  NtAccessCheckByTypeResultListAndAuditAlarm(
    SubsystemName : PUNICODE_STRING;
    HandleId : PVOID;
    ObjectTypeName : PUNICODE_STRING;
    ObjectName : PUNICODE_STRING;
    SecurityDescriptor : PSECURITY_DESCRIPTOR;
    PrincipalSelfSid : PSID;
    DesiredAccess : ACCESS_MASK;
    AuditType : AUDIT_EVENT_TYPE;
    Flags : ULONG;
    ObjectTypeList : POBJECT_TYPE_LIST;
    ObjectTypeListLength : ULONG;
    GenericMapping : PGENERIC_MAPPING;
    ObjectCreation : BOOLEAN;
    GrantedAccessList : PACCESS_MASK;
    AccessStatusList : PULONG;
    GenerateOnClose : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAccessCheckByTypeResultListAndAuditAlarm(SubsystemName: PUNICODE_STRING; HandleId: PVOID; ObjectTypeName: PUNICODE_STRING; ObjectName: PUNICODE_STRING; SecurityDescriptor: PSECURITY_DESCRIPTOR; PrincipalSelfSid: PSID;
    DesiredAccess: ACCESS_MASK; AuditType: AUDIT_EVENT_TYPE; Flags: ULONG; ObjectTypeList: POBJECT_TYPE_LIST; ObjectTypeListLength: ULONG; GenericMapping: PGENERIC_MAPPING; ObjectCreation: BOOLEAN; GrantedAccessList: PACCESS_MASK;
    AccessStatusList: PULONG; GenerateOnClose: PULONG): NTSTATUS; stdcall; external ntdll;

// This function is very similar to
// AccessCheckByTypeResultListAndAuditAlarmByHandle() from Advapi32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: W2K, WXP, 2K3
function  NtAccessCheckByTypeResultListAndAuditAlarmByHandle(
    SubsystemName : PUNICODE_STRING;
    HandleId : PVOID;
    TokenHandle : HANDLE;
    ObjectTypeName : PUNICODE_STRING;
    ObjectName : PUNICODE_STRING;
    SecurityDescriptor : PSECURITY_DESCRIPTOR;
    PrincipalSelfSid : PSID;
    DesiredAccess : ACCESS_MASK;
    AuditType : AUDIT_EVENT_TYPE;
    Flags : ULONG;
    ObjectTypeList : POBJECT_TYPE_LIST;
    ObjectTypeListLength : ULONG;
    GenericMapping : PGENERIC_MAPPING;
    ObjectCreation : BOOLEAN;
    GrantedAccessList : PACCESS_MASK;
    AccessStatusList : PULONG;
    GenerateOnClose : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAccessCheckByTypeResultListAndAuditAlarmByHandle(SubsystemName: PUNICODE_STRING; HandleId: PVOID; TokenHandle: HANDLE; ObjectTypeName: PUNICODE_STRING; ObjectName: PUNICODE_STRING; SecurityDescriptor: PSECURITY_DESCRIPTOR;
    PrincipalSelfSid: PSID; DesiredAccess: ACCESS_MASK; AuditType: AUDIT_EVENT_TYPE; Flags: ULONG; ObjectTypeList: POBJECT_TYPE_LIST; ObjectTypeListLength: ULONG; GenericMapping: PGENERIC_MAPPING; ObjectCreation: BOOLEAN;
    GrantedAccessList: PACCESS_MASK; AccessStatusList: PULONG; GenerateOnClose: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT4, W2K, WXP, 2K3
function  NtAddAtom(
    Str : PWSTR;
    StringLength : ULONG;
    Atom : PUSHORT
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAddAtom(Str: PWSTR; StringLength: ULONG; Atom: PUSHORT): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtAdjustGroupsToken(
    TokenHandle : HANDLE;
    ResetToDefault : BOOLEAN;
    NewState : PTOKEN_GROUPS;
    BufferLength : ULONG;
    PreviousState : PTOKEN_GROUPS;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAdjustGroupsToken(TokenHandle: HANDLE; ResetToDefault: BOOLEAN; NewState: PTOKEN_GROUPS; BufferLength: ULONG; PreviousState: PTOKEN_GROUPS; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtAdjustPrivilegesToken(
    TokenHandle : HANDLE;
    DisableAllPrivileges : BOOLEAN;
    NewState : PTOKEN_PRIVILEGES;
    BufferLength : ULONG;
    PreviousState : PTOKEN_PRIVILEGES;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAdjustPrivilegesToken(TokenHandle: HANDLE; DisableAllPrivileges: BOOLEAN; NewState: PTOKEN_PRIVILEGES; BufferLength: ULONG; PreviousState: PTOKEN_PRIVILEGES; ReturnLength: PULONG): NTSTATUS; stdcall;
    external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtAlertResumeThread(
    ThreadHandle : HANDLE;
    PreviousSuspendCount : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAlertResumeThread(ThreadHandle: HANDLE; PreviousSuspendCount: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtAlertThread(
    ThreadHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAlertThread(ThreadHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtAllocateLocallyUniqueId(
    Luid : PLUID
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAllocateLocallyUniqueId(Luid: PLUID): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtAllocateUserPhysicalPages(
    ProcessHandle : HANDLE;
    NumberOfPages : PULONG;
    PageFrameNumbers : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAllocateUserPhysicalPages(ProcessHandle: HANDLE; NumberOfPages: PULONG; PageFrameNumbers: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtAllocateUuids(
    UuidLastTimeAllocated : PLARGE_INTEGER;
    UuidDeltaTime : PULONG;
    UuidSequenceNumber : PULONG;
    UuidSeed : PUCHAR
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAllocateUuids(UuidLastTimeAllocated: PLARGE_INTEGER; UuidDeltaTime: PULONG; UuidSequenceNumber: PULONG; UuidSeed: PUCHAR): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtAllocateVirtualMemory(
    ProcessHandle : HANDLE;
    BaseAddress : PPVOID;
    ZeroBits : ULONG;
    AllocationSize : PULONG;
    AllocationType : ULONG;
    Protect : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAllocateVirtualMemory(ProcessHandle: HANDLE; BaseAddress: PPVOID; ZeroBits: ULONG; AllocationSize: PULONG; AllocationType: ULONG; Protect: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtAreMappedFilesTheSame(
    Address1 : PVOID;
    Address2 : PVOID
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAreMappedFilesTheSame(Address1: PVOID; Address2: PVOID): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtAssignProcessToJobObject(
    JobHandle : HANDLE;
    ProcessHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwAssignProcessToJobObject(JobHandle: HANDLE; ProcessHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCallbackReturn(
    Result_ : PVOID;
    ResultLength : ULONG;
    Status : NTSTATUS
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCallbackReturn(Result_: PVOID; ResultLength: ULONG; Status: NTSTATUS): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtCancelDeviceWakeupRequest(
    DeviceHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCancelDeviceWakeupRequest(DeviceHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCancelIoFile(
    FileHandle : HANDLE;
    IoStatusBlock : PIO_STATUS_BLOCK
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCancelIoFile(FileHandle: HANDLE; IoStatusBlock: PIO_STATUS_BLOCK): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCancelTimer(
    TimerHandle : HANDLE;
    PreviousState : PBOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCancelTimer(TimerHandle: HANDLE; PreviousState: PBOOLEAN): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtClearEvent(
    EventHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwClearEvent(EventHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// This function is very similar to CloseHandle() from Kernel32.dll. Refer
// to the PSDK for additional information. Usually the same flags apply.
// Documented in the DDK as ZwClose().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtClose(
    Handle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwClose(Handle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCloseObjectAuditAlarm(
    SubsystemName : PUNICODE_STRING;
    HandleId : PVOID;
    GenerateOnClose : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCloseObjectAuditAlarm(SubsystemName: PUNICODE_STRING; HandleId: PVOID; GenerateOnClose: BOOLEAN): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCompleteConnectPort(
    PortHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCompleteConnectPort(PortHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtConnectPort(
    PortHandle : PHANDLE;
    PortName : PUNICODE_STRING;
    SecurityQos : PSECURITY_QUALITY_OF_SERVICE;
    WriteSection : PPORT_SECTION_WRITE;
    ReadSection : PPORT_SECTION_READ;
    MaxMessageSize : PULONG;
    ConnectData : PVOID;
    ConnectDataLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwConnectPort(PortHandle: PHANDLE; PortName: PUNICODE_STRING; SecurityQos: PSECURITY_QUALITY_OF_SERVICE; WriteSection: PPORT_SECTION_WRITE; ReadSection: PPORT_SECTION_READ; MaxMessageSize: PULONG; ConnectData: PVOID;
    ConnectDataLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtContinue(
    Context : PCONTEXT;
    TestAlert : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwContinue(Context: PCONTEXT; TestAlert: BOOLEAN): NTSTATUS; stdcall; external ntdll;

// Returns STATUS_NOT_IMPLEMENTED. Only MS knows the intention behind this.
// 
// !!!DO NOT USE!!!
// Compatibility: NT4, W2K
function  NtCreateChannel(
    ChannelHandle : PHANDLE;
    ObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateChannel(ChannelHandle: PHANDLE; ObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwCreateDirectoryObject().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreateDirectoryObject(
    DirectoryHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateDirectoryObject(DirectoryHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreateEvent(
    EventHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    EventType : EVENT_TYPE;
    InitialState : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateEvent(EventHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES; EventType: EVENT_TYPE; InitialState: BOOLEAN): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreateEventPair(
    EventPairHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateEventPair(EventPairHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwCreateFile().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreateFile(
    FileHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    IoStatusBlock : PIO_STATUS_BLOCK;
    AllocationSize : PLARGE_INTEGER;
    FileAttributes : ULONG;
    ShareAccess : ULONG;
    CreateDisposition : ULONG;
    CreateOptions : ULONG;
    EaBuffer : PVOID;
    EaLength : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateFile(FileHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES; IoStatusBlock: PIO_STATUS_BLOCK; AllocationSize: PLARGE_INTEGER; FileAttributes: ULONG; ShareAccess: ULONG;
    CreateDisposition: ULONG; CreateOptions: ULONG; EaBuffer: PVOID; EaLength: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreateIoCompletion(
    IoCompletionHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    NumberOfConcurrentThreads : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateIoCompletion(IoCompletionHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES; NumberOfConcurrentThreads: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtCreateJobObject(
    JobHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateJobObject(JobHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwCreateKey().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreateKey(
    KeyHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    TitleIndex : ULONG;
    Class_ : PUNICODE_STRING;
    CreateOptions : ULONG;
    Disposition : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateKey(KeyHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES; TitleIndex: ULONG; Class_: PUNICODE_STRING; CreateOptions: ULONG; Disposition: PULONG): NTSTATUS; stdcall;
    external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreateMailslotFile(
    FileHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    IoStatusBlock : PIO_STATUS_BLOCK;
    CreateOptions : ULONG;
    Unknown : ULONG;
    MaxMessageSize : ULONG;
    ReadTimeout : PLARGE_INTEGER
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateMailslotFile(FileHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES; IoStatusBlock: PIO_STATUS_BLOCK; CreateOptions: ULONG; Unknown: ULONG; MaxMessageSize: ULONG;
    ReadTimeout: PLARGE_INTEGER): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreateMutant(
    MutantHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    InitialOwner : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateMutant(MutantHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES; InitialOwner: BOOLEAN): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreateNamedPipeFile(
    FileHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    IoStatusBlock : PIO_STATUS_BLOCK;
    ShareAccess : ULONG;
    CreateDisposition : ULONG;
    CreateOptions : ULONG;
    TypeMessage : BOOLEAN;
    ReadmodeMessage : BOOLEAN;
    Nonblocking : BOOLEAN;
    MaxInstances : ULONG;
    InBufferSize : ULONG;
    OutBufferSize : ULONG;
    DefaultTimeout : PLARGE_INTEGER
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateNamedPipeFile(FileHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES; IoStatusBlock: PIO_STATUS_BLOCK; ShareAccess: ULONG; CreateDisposition: ULONG; CreateOptions: ULONG;
    TypeMessage: BOOLEAN; ReadmodeMessage: BOOLEAN; Nonblocking: BOOLEAN; MaxInstances: ULONG; InBufferSize: ULONG; OutBufferSize: ULONG; DefaultTimeout: PLARGE_INTEGER): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreatePagingFile(
    FileName : PUNICODE_STRING;
    InitialSize : PULARGE_INTEGER;
    MaximumSize : PULARGE_INTEGER;
    Reserved : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreatePagingFile(FileName: PUNICODE_STRING; InitialSize: PULARGE_INTEGER; MaximumSize: PULARGE_INTEGER; Reserved: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreatePort(
    PortHandle : PHANDLE;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    MaxDataSize : ULONG;
    MaxMessageSize : ULONG;
    Reserved : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreatePort(PortHandle: PHANDLE; ObjectAttributes: POBJECT_ATTRIBUTES; MaxDataSize: ULONG; MaxMessageSize: ULONG; Reserved: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreateProcess(
    ProcessHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    InheritFromProcessHandle : HANDLE;
    InheritHandles : BOOLEAN;
    SectionHandle : HANDLE;
    DebugPort : HANDLE;
    ExceptionPort : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateProcess(ProcessHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES; InheritFromProcessHandle: HANDLE; InheritHandles: BOOLEAN; SectionHandle: HANDLE; DebugPort: HANDLE;
    ExceptionPort: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreateProfile(
    ProfileHandle : PHANDLE;
    ProcessHandle : HANDLE;
    Base : PVOID;
    Size : ULONG;
    BucketShift : ULONG;
    Buffer : PULONG;
    BufferLength : ULONG;
    Source : KPROFILE_SOURCE;
    ProcessorMask : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateProfile(ProfileHandle: PHANDLE; ProcessHandle: HANDLE; Base: PVOID; Size: ULONG; BucketShift: ULONG; Buffer: PULONG; BufferLength: ULONG; Source: KPROFILE_SOURCE; ProcessorMask: ULONG): NTSTATUS; stdcall;
    external ntdll;

// Documented in the DDK as ZwCreateSection().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreateSection(
    SectionHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    SectionSize : PLARGE_INTEGER;
    Protect : ULONG;
    Attributes : ULONG;
    FileHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateSection(SectionHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES; SectionSize: PLARGE_INTEGER; Protect: ULONG; Attributes: ULONG; FileHandle: HANDLE): NTSTATUS; stdcall;
    external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreateSemaphore(
    SemaphoreHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    InitialCount : LONG;
    MaximumCount : LONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateSemaphore(SemaphoreHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES; InitialCount: LONG; MaximumCount: LONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreateSymbolicLinkObject(
    SymbolicLinkHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    TargetName : PUNICODE_STRING
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateSymbolicLinkObject(SymbolicLinkHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES; TargetName: PUNICODE_STRING): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreateThread(
    ThreadHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    ProcessHandle : HANDLE;
    ClientId : PCLIENT_ID;
    ThreadContext : PCONTEXT;
    UserStack : PUSER_STACK;
    CreateSuspended : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateThread(ThreadHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES; ProcessHandle: HANDLE; ClientId: PCLIENT_ID; ThreadContext: PCONTEXT; UserStack: PUSER_STACK;
    CreateSuspended: BOOLEAN): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreateTimer(
    TimerHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    TimerType : TIMER_TYPE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateTimer(TimerHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES; TimerType: TIMER_TYPE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCreateToken(
    TokenHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    Type_ : TOKEN_TYPE;
    AuthenticationId : PLUID;
    ExpirationTime : PLARGE_INTEGER;
    User : PTOKEN_USER;
    Groups : PTOKEN_GROUPS;
    Privileges : PTOKEN_PRIVILEGES;
    Owner : PTOKEN_OWNER;
    PrimaryGroup : PTOKEN_PRIMARY_GROUP;
    DefaultDacl : PTOKEN_DEFAULT_DACL;
    Source : PTOKEN_SOURCE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateToken(TokenHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES; Type_: TOKEN_TYPE; AuthenticationId: PLUID; ExpirationTime: PLARGE_INTEGER; User: PTOKEN_USER; Groups: PTOKEN_GROUPS;
    Privileges: PTOKEN_PRIVILEGES; Owner: PTOKEN_OWNER; PrimaryGroup: PTOKEN_PRIMARY_GROUP; DefaultDacl: PTOKEN_DEFAULT_DACL; Source: PTOKEN_SOURCE): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtCreateWaitablePort(
    PortHandle : PHANDLE;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    MaxDataSize : ULONG;
    MaxMessageSize : ULONG;
    Reserved : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwCreateWaitablePort(PortHandle: PHANDLE; ObjectAttributes: POBJECT_ATTRIBUTES; MaxDataSize: ULONG; MaxMessageSize: ULONG; Reserved: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtCurrentTeb(): PTEB; stdcall; external ntdll;
function  ZwCurrentTeb(): PTEB; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  NtDebugActiveProcess(
    hProcess : HANDLE;
    hDebugObject : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwDebugActiveProcess(hProcess: HANDLE; hDebugObject: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtDelayExecution(
    Alertable : BOOLEAN;
    Interval : PLARGE_INTEGER
  ): NTSTATUS; stdcall; external ntdll;
function  ZwDelayExecution(Alertable: BOOLEAN; Interval: PLARGE_INTEGER): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT4, W2K, WXP, 2K3
function  NtDeleteAtom(
    Atom : USHORT
  ): NTSTATUS; stdcall; external ntdll;
function  ZwDeleteAtom(Atom: USHORT): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtDeleteFile(
    ObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwDeleteFile(ObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwDeleteKey().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtDeleteKey(
    KeyHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwDeleteKey(KeyHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT4, W2K, WXP, 2K3
function  NtDeleteObjectAuditAlarm(
    SubsystemName : PUNICODE_STRING;
    HandleId : PVOID;
    GenerateOnClose : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwDeleteObjectAuditAlarm(SubsystemName: PUNICODE_STRING; HandleId: PVOID; GenerateOnClose: BOOLEAN): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtDeleteValueKey(
    KeyHandle : HANDLE;
    ValueName : PUNICODE_STRING
  ): NTSTATUS; stdcall; external ntdll;
function  ZwDeleteValueKey(KeyHandle: HANDLE; ValueName: PUNICODE_STRING): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtDeviceIoControlFile(
    FileHandle : HANDLE;
    Event : HANDLE;
    ApcRoutine : PIO_APC_ROUTINE;
    ApcContext : PVOID;
    IoStatusBlock : PIO_STATUS_BLOCK;
    IoControlCode : ULONG;
    InputBuffer : PVOID;
    InputBufferLength : ULONG;
    OutputBuffer : PVOID;
    OutputBufferLength : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwDeviceIoControlFile(FileHandle: HANDLE; Event: HANDLE; ApcRoutine: PIO_APC_ROUTINE; ApcContext: PVOID; IoStatusBlock: PIO_STATUS_BLOCK; IoControlCode: ULONG; InputBuffer: PVOID; InputBufferLength: ULONG; OutputBuffer: PVOID;
    OutputBufferLength: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtDisplayString(
    Str : PUNICODE_STRING
  ): NTSTATUS; stdcall; external ntdll;
function  ZwDisplayString(Str: PUNICODE_STRING): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtDuplicateObject(
    SourceProcessHandle : HANDLE;
    SourceHandle : HANDLE;
    TargetProcessHandle : HANDLE;
    TargetHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    Attributes : ULONG;
    Options : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwDuplicateObject(SourceProcessHandle: HANDLE; SourceHandle: HANDLE; TargetProcessHandle: HANDLE; TargetHandle: PHANDLE; DesiredAccess: ACCESS_MASK; Attributes: ULONG; Options: ULONG): NTSTATUS; stdcall;
    external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtDuplicateToken(
    ExistingTokenHandle : HANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    EffectiveOnly : BOOLEAN;
    TokenType : TOKEN_TYPE;
    NewTokenHandle : PHANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwDuplicateToken(ExistingTokenHandle: HANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES; EffectiveOnly: BOOLEAN; TokenType: TOKEN_TYPE; NewTokenHandle: PHANDLE): NTSTATUS; stdcall;
    external ntdll;

// Documented in the DDK as ZwEnumerateKey().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtEnumerateKey(
    KeyHandle : HANDLE;
    Index : ULONG;
    KeyInformationClass : KEY_INFORMATION_CLASS;
    KeyInformation : PVOID;
    KeyInformationLength : ULONG;
    ResultLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwEnumerateKey(KeyHandle: HANDLE; Index: ULONG; KeyInformationClass: KEY_INFORMATION_CLASS; KeyInformation: PVOID; KeyInformationLength: ULONG; ResultLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwEnumerateValueKey().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtEnumerateValueKey(
    KeyHandle : HANDLE;
    Index : ULONG;
    KeyValueInformationClass : KEY_VALUE_INFORMATION_CLASS;
    KeyValueInformation : PVOID;
    KeyValueInformationLength : ULONG;
    ResultLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwEnumerateValueKey(KeyHandle: HANDLE; Index: ULONG; KeyValueInformationClass: KEY_VALUE_INFORMATION_CLASS; KeyValueInformation: PVOID; KeyValueInformationLength: ULONG; ResultLength: PULONG): NTSTATUS; stdcall;
    external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtExtendSection(
    SectionHandle : HANDLE;
    SectionSize : PLARGE_INTEGER
  ): NTSTATUS; stdcall; external ntdll;
function  ZwExtendSection(SectionHandle: HANDLE; SectionSize: PLARGE_INTEGER): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtFilterToken(
    ExistingTokenHandle : HANDLE;
    Flags : ULONG;
    SidsToDisable : PTOKEN_GROUPS;
    PrivilegesToDelete : PTOKEN_PRIVILEGES;
    SidsToRestricted : PTOKEN_GROUPS;
    NewTokenHandle : PHANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwFilterToken(ExistingTokenHandle: HANDLE; Flags: ULONG; SidsToDisable: PTOKEN_GROUPS; PrivilegesToDelete: PTOKEN_PRIVILEGES; SidsToRestricted: PTOKEN_GROUPS; NewTokenHandle: PHANDLE): NTSTATUS; stdcall;
    external ntdll;

// Compatibility: NT4, W2K, WXP, 2K3
function  NtFindAtom(
    Str : PWSTR;
    StringLength : ULONG;
    Atom : PUSHORT
  ): NTSTATUS; stdcall; external ntdll;
function  ZwFindAtom(Str: PWSTR; StringLength: ULONG; Atom: PUSHORT): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtFlushBuffersFile(
    FileHandle : HANDLE;
    IoStatusBlock : PIO_STATUS_BLOCK
  ): NTSTATUS; stdcall; external ntdll;
function  ZwFlushBuffersFile(FileHandle: HANDLE; IoStatusBlock: PIO_STATUS_BLOCK): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtFlushInstructionCache(
    ProcessHandle : HANDLE;
    BaseAddress : PVOID;
    FlushSize : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwFlushInstructionCache(ProcessHandle: HANDLE; BaseAddress: PVOID; FlushSize: ULONG): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwFlushKey().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtFlushKey(
    KeyHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwFlushKey(KeyHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtFlushVirtualMemory(
    ProcessHandle : HANDLE;
    BaseAddress : PPVOID;
    FlushSize : PULONG;
    IoStatusBlock : PIO_STATUS_BLOCK
  ): NTSTATUS; stdcall; external ntdll;
function  ZwFlushVirtualMemory(ProcessHandle: HANDLE; BaseAddress: PPVOID; FlushSize: PULONG; IoStatusBlock: PIO_STATUS_BLOCK): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtFlushWriteBuffer(): NTSTATUS; stdcall; external ntdll;
function  ZwFlushWriteBuffer(): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtFreeUserPhysicalPages(
    ProcessHandle : HANDLE;
    NumberOfPages : PULONG;
    PageFrameNumbers : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwFreeUserPhysicalPages(ProcessHandle: HANDLE; NumberOfPages: PULONG; PageFrameNumbers: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtFreeVirtualMemory(
    ProcessHandle : HANDLE;
    BaseAddress : PPVOID;
    FreeSize : PULONG;
    FreeType : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwFreeVirtualMemory(ProcessHandle: HANDLE; BaseAddress: PPVOID; FreeSize: PULONG; FreeType: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtFsControlFile(
    FileHandle : HANDLE;
    Event : HANDLE;
    ApcRoutine : PIO_APC_ROUTINE;
    ApcContext : PVOID;
    IoStatusBlock : PIO_STATUS_BLOCK;
    FsControlCode : ULONG;
    InputBuffer : PVOID;
    InputBufferLength : ULONG;
    OutputBuffer : PVOID;
    OutputBufferLength : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwFsControlFile(FileHandle: HANDLE; Event: HANDLE; ApcRoutine: PIO_APC_ROUTINE; ApcContext: PVOID; IoStatusBlock: PIO_STATUS_BLOCK; FsControlCode: ULONG; InputBuffer: PVOID; InputBufferLength: ULONG; OutputBuffer: PVOID;
    OutputBufferLength: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtGetContextThread(
    ThreadHandle : HANDLE;
    Context : PCONTEXT
  ): NTSTATUS; stdcall; external ntdll;
function  ZwGetContextThread(ThreadHandle: HANDLE; Context: PCONTEXT): NTSTATUS; stdcall; external ntdll;

// Compatibility: 2K3
function  NtGetCurrentProcessorNumber(): ULONG; stdcall; external ntdll;
function  ZwGetCurrentProcessorNumber(): ULONG; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtGetDevicePowerState(
    DeviceHandle : HANDLE;
    DevicePowerState : PDEVICE_POWER_STATE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwGetDevicePowerState(DeviceHandle: HANDLE; DevicePowerState: PDEVICE_POWER_STATE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtGetPlugPlayEvent(
    Reserved1 : ULONG;
    Reserved2 : ULONG;
    Buffer : PVOID;
    BufferLength : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwGetPlugPlayEvent(Reserved1: ULONG; Reserved2: ULONG; Buffer: PVOID; BufferLength: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, 2K3
function  NtGetTickCount(): ULONG; stdcall; external ntdll;
function  ZwGetTickCount(): ULONG; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtGetWriteWatch(
    ProcessHandle : HANDLE;
    Flags : ULONG;
    BaseAddress : PVOID;
    RegionSize : ULONG;
    Buffer : PULONG;
    BufferEntries : PULONG;
    Granularity : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwGetWriteWatch(ProcessHandle: HANDLE; Flags: ULONG; BaseAddress: PVOID; RegionSize: ULONG; Buffer: PULONG; BufferEntries: PULONG; Granularity: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtImpersonateAnonymousToken(
    ThreadHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwImpersonateAnonymousToken(ThreadHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtImpersonateClientOfPort(
    PortHandle : HANDLE;
    Message : PPORT_MESSAGE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwImpersonateClientOfPort(PortHandle: HANDLE; Message: PPORT_MESSAGE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtImpersonateThread(
    ThreadHandle : HANDLE;
    TargetThreadHandle : HANDLE;
    SecurityQos : PSECURITY_QUALITY_OF_SERVICE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwImpersonateThread(ThreadHandle: HANDLE; TargetThreadHandle: HANDLE; SecurityQos: PSECURITY_QUALITY_OF_SERVICE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtInitializeRegistry(
    Setup : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwInitializeRegistry(Setup: BOOLEAN): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtInitiatePowerAction(
    SystemAction : POWER_ACTION;
    MinSystemState : SYSTEM_POWER_STATE;
    Flags : ULONG;
    Asynchronous : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwInitiatePowerAction(SystemAction: POWER_ACTION; MinSystemState: SYSTEM_POWER_STATE; Flags: ULONG; Asynchronous: BOOLEAN): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtIsSystemResumeAutomatic(): BOOLEAN; stdcall; external ntdll;
function  ZwIsSystemResumeAutomatic(): BOOLEAN; stdcall; external ntdll;

// Returns STATUS_NOT_IMPLEMENTED. Only MS knows the intention behind this.
// 
// !!!DO NOT USE!!!
// Compatibility: NT4, W2K
function  NtListenChannel(
    x : PVOID;
    y : PVOID
  ): NTSTATUS; stdcall; external ntdll;
function  ZwListenChannel(x: PVOID; y: PVOID): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtListenPort(
    PortHandle : HANDLE;
    Message : PPORT_MESSAGE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwListenPort(PortHandle: HANDLE; Message: PPORT_MESSAGE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtLoadDriver(
    DriverServiceName : PUNICODE_STRING
  ): NTSTATUS; stdcall; external ntdll;
function  ZwLoadDriver(DriverServiceName: PUNICODE_STRING): NTSTATUS; stdcall; external ntdll;

// Relates to RegLoadKey().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtLoadKey(
    KeyObjectAttributes : POBJECT_ATTRIBUTES;
    FileObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwLoadKey(KeyObjectAttributes: POBJECT_ATTRIBUTES; FileObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Relates to RegLoadKey().
// Compatibility: NT4, W2K, WXP, 2K3
function  NtLoadKey2(
    KeyObjectAttributes : POBJECT_ATTRIBUTES;
    FileObjectAttributes : POBJECT_ATTRIBUTES;
    Flags : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwLoadKey2(KeyObjectAttributes: POBJECT_ATTRIBUTES; FileObjectAttributes: POBJECT_ATTRIBUTES; Flags: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtLockFile(
    FileHandle : HANDLE;
    Event : HANDLE;
    ApcRoutine : PIO_APC_ROUTINE;
    ApcContext : PVOID;
    IoStatusBlock : PIO_STATUS_BLOCK;
    LockOffset : PULARGE_INTEGER;
    LockLength : PULARGE_INTEGER;
    Key : ULONG;
    FailImmediately : BOOLEAN;
    ExclusiveLock : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwLockFile(FileHandle: HANDLE; Event: HANDLE; ApcRoutine: PIO_APC_ROUTINE; ApcContext: PVOID; IoStatusBlock: PIO_STATUS_BLOCK; LockOffset: PULARGE_INTEGER; LockLength: PULARGE_INTEGER; Key: ULONG; FailImmediately: BOOLEAN;
    ExclusiveLock: BOOLEAN): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtLockVirtualMemory(
    ProcessHandle : HANDLE;
    BaseAddress : PPVOID;
    LockSize : PULONG;
    LockType : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwLockVirtualMemory(ProcessHandle: HANDLE; BaseAddress: PPVOID; LockSize: PULONG; LockType: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  NtMakePermanentObject(
    Handle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwMakePermanentObject(Handle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwMakeTemporaryObject().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtMakeTemporaryObject(
    Handle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwMakeTemporaryObject(Handle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtMapUserPhysicalPages(
    BaseAddress : PVOID;
    NumberOfPages : PULONG;
    PageFrameNumbers : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwMapUserPhysicalPages(BaseAddress: PVOID; NumberOfPages: PULONG; PageFrameNumbers: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtMapUserPhysicalPagesScatter(
    BaseAddresses : PPVOID;
    NumberOfPages : PULONG;
    PageFrameNumbers : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwMapUserPhysicalPagesScatter(BaseAddresses: PPVOID; NumberOfPages: PULONG; PageFrameNumbers: PULONG): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwMapViewOfSection().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtMapViewOfSection(
    SectionHandle : HANDLE;
    ProcessHandle : HANDLE;
    BaseAddress : PPVOID;
    ZeroBits : ULONG;
    CommitSize : ULONG;
    SectionOffset : PLARGE_INTEGER;
    ViewSize : PULONG;
    InheritDisposition : SECTION_INHERIT;
    AllocationType : ULONG;
    Protect : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwMapViewOfSection(SectionHandle: HANDLE; ProcessHandle: HANDLE; BaseAddress: PPVOID; ZeroBits: ULONG; CommitSize: ULONG; SectionOffset: PLARGE_INTEGER; ViewSize: PULONG; InheritDisposition: SECTION_INHERIT; AllocationType: ULONG;
    Protect: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtNotifyChangeDirectoryFile(
    FileHandle : HANDLE;
    Event : HANDLE;
    ApcRoutine : PIO_APC_ROUTINE;
    ApcContext : PVOID;
    IoStatusBlock : PIO_STATUS_BLOCK;
    Buffer : PFILE_NOTIFY_INFORMATION;
    BufferLength : ULONG;
    NotifyFilter : ULONG;
    WatchSubtree : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwNotifyChangeDirectoryFile(FileHandle: HANDLE; Event: HANDLE; ApcRoutine: PIO_APC_ROUTINE; ApcContext: PVOID; IoStatusBlock: PIO_STATUS_BLOCK; Buffer: PFILE_NOTIFY_INFORMATION; BufferLength: ULONG; NotifyFilter: ULONG;
    WatchSubtree: BOOLEAN): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtNotifyChangeKey(
    KeyHandle : HANDLE;
    EventHandle : HANDLE;
    ApcRoutine : PIO_APC_ROUTINE;
    ApcContext : PVOID;
    IoStatusBlock : PIO_STATUS_BLOCK;
    NotifyFilter : ULONG;
    WatchSubtree : BOOLEAN;
    Buffer : PVOID;
    BufferLength : ULONG;
    Asynchronous : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwNotifyChangeKey(KeyHandle: HANDLE; EventHandle: HANDLE; ApcRoutine: PIO_APC_ROUTINE; ApcContext: PVOID; IoStatusBlock: PIO_STATUS_BLOCK; NotifyFilter: ULONG; WatchSubtree: BOOLEAN; Buffer: PVOID; BufferLength: ULONG;
    Asynchronous: BOOLEAN): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtNotifyChangeMultipleKeys(
    KeyHandle : HANDLE;
    Flags : ULONG;
    KeyObjectAttributes : POBJECT_ATTRIBUTES;
    EventHandle : HANDLE;
    ApcRoutine : PIO_APC_ROUTINE;
    ApcContext : PVOID;
    IoStatusBlock : PIO_STATUS_BLOCK;
    NotifyFilter : ULONG;
    WatchSubtree : BOOLEAN;
    Buffer : PVOID;
    BufferLength : ULONG;
    Asynchronous : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwNotifyChangeMultipleKeys(KeyHandle: HANDLE; Flags: ULONG; KeyObjectAttributes: POBJECT_ATTRIBUTES; EventHandle: HANDLE; ApcRoutine: PIO_APC_ROUTINE; ApcContext: PVOID; IoStatusBlock: PIO_STATUS_BLOCK; NotifyFilter: ULONG;
    WatchSubtree: BOOLEAN; Buffer: PVOID; BufferLength: ULONG; Asynchronous: BOOLEAN): NTSTATUS; stdcall; external ntdll;

// Returns STATUS_NOT_IMPLEMENTED. Only MS knows the intention behind this.
// 
// !!!DO NOT USE!!!
// Compatibility: NT4, W2K
function  NtOpenChannel(
    ChannelHandle : PHANDLE;
    ObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwOpenChannel(ChannelHandle: PHANDLE; ObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtOpenDirectoryObject(
    DirectoryHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwOpenDirectoryObject(DirectoryHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtOpenEvent(
    EventHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwOpenEvent(EventHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtOpenEventPair(
    EventPairHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwOpenEventPair(EventPairHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwOpenFile().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtOpenFile(
    FileHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    IoStatusBlock : PIO_STATUS_BLOCK;
    ShareAccess : ULONG;
    OpenOptions : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwOpenFile(FileHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES; IoStatusBlock: PIO_STATUS_BLOCK; ShareAccess: ULONG; OpenOptions: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtOpenIoCompletion(
    IoCompletionHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwOpenIoCompletion(IoCompletionHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtOpenJobObject(
    JobHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwOpenJobObject(JobHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwOpenKey().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtOpenKey(
    KeyHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwOpenKey(KeyHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtOpenMutant(
    MutantHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwOpenMutant(MutantHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtOpenObjectAuditAlarm(
    SubsystemName : PUNICODE_STRING;
    HandleId : PPVOID;
    ObjectTypeName : PUNICODE_STRING;
    ObjectName : PUNICODE_STRING;
    SecurityDescriptor : PSECURITY_DESCRIPTOR;
    TokenHandle : HANDLE;
    DesiredAccess : ACCESS_MASK;
    GrantedAccess : ACCESS_MASK;
    Privileges : PPRIVILEGE_SET;
    ObjectCreation : BOOLEAN;
    AccessGranted : BOOLEAN;
    GenerateOnClose : PBOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwOpenObjectAuditAlarm(SubsystemName: PUNICODE_STRING; HandleId: PPVOID; ObjectTypeName: PUNICODE_STRING; ObjectName: PUNICODE_STRING; SecurityDescriptor: PSECURITY_DESCRIPTOR; TokenHandle: HANDLE; DesiredAccess: ACCESS_MASK;
    GrantedAccess: ACCESS_MASK; Privileges: PPRIVILEGE_SET; ObjectCreation: BOOLEAN; AccessGranted: BOOLEAN; GenerateOnClose: PBOOLEAN): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtOpenProcess(
    ProcessHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    ClientId : PCLIENT_ID
  ): NTSTATUS; stdcall; external ntdll;
function  ZwOpenProcess(ProcessHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES; ClientId: PCLIENT_ID): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtOpenProcessToken(
    ProcessHandle : HANDLE;
    DesiredAccess : ACCESS_MASK;
    TokenHandle : PHANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwOpenProcessToken(ProcessHandle: HANDLE; DesiredAccess: ACCESS_MASK; TokenHandle: PHANDLE): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwOpenSection().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtOpenSection(
    SectionHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwOpenSection(SectionHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtOpenSemaphore(
    SemaphoreHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwOpenSemaphore(SemaphoreHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwOpenSymbolicLinkObject().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtOpenSymbolicLinkObject(
    SymbolicLinkHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwOpenSymbolicLinkObject(SymbolicLinkHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtOpenThread(
    ThreadHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    ClientId : PCLIENT_ID
  ): NTSTATUS; stdcall; external ntdll;
function  ZwOpenThread(ThreadHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES; ClientId: PCLIENT_ID): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtOpenThreadToken(
    ThreadHandle : HANDLE;
    DesiredAccess : ACCESS_MASK;
    OpenAsSelf : BOOLEAN;
    TokenHandle : PHANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwOpenThreadToken(ThreadHandle: HANDLE; DesiredAccess: ACCESS_MASK; OpenAsSelf: BOOLEAN; TokenHandle: PHANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtOpenTimer(
    TimerHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwOpenTimer(TimerHandle: PHANDLE; DesiredAccess: ACCESS_MASK; ObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtPlugPlayControl(
    ControlCode : ULONG;
    Buffer : PVOID;
    BufferLength : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwPlugPlayControl(ControlCode: ULONG; Buffer: PVOID; BufferLength: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtPowerInformation(
    PowerInformationLevel : POWER_INFORMATION_LEVEL;
    InputBuffer : PVOID;
    InputBufferLength : ULONG;
    OutputBuffer : PVOID;
    OutputBufferLength : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwPowerInformation(PowerInformationLevel: POWER_INFORMATION_LEVEL; InputBuffer: PVOID; InputBufferLength: ULONG; OutputBuffer: PVOID; OutputBufferLength: ULONG): NTSTATUS; stdcall; external ntdll;

// This function is very similar to PrivilegeCheck() from Advapi32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtPrivilegeCheck(
    TokenHandle : HANDLE;
    RequiredPrivileges : PPRIVILEGE_SET;
    Result_ : PBOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwPrivilegeCheck(TokenHandle: HANDLE; RequiredPrivileges: PPRIVILEGE_SET; Result_: PBOOLEAN): NTSTATUS; stdcall; external ntdll;

// This function is very similar to PrivilegedServiceAuditAlarm() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtPrivilegedServiceAuditAlarm(
    SubsystemName : PUNICODE_STRING;
    ServiceName : PUNICODE_STRING;
    TokenHandle : HANDLE;
    Privileges : PPRIVILEGE_SET;
    AccessGranted : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwPrivilegedServiceAuditAlarm(SubsystemName: PUNICODE_STRING; ServiceName: PUNICODE_STRING; TokenHandle: HANDLE; Privileges: PPRIVILEGE_SET; AccessGranted: BOOLEAN): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtPrivilegeObjectAuditAlarm(
    SubsystemName : PUNICODE_STRING;
    HandleId : PVOID;
    TokenHandle : HANDLE;
    DesiredAccess : ACCESS_MASK;
    Privileges : PPRIVILEGE_SET;
    AccessGranted : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwPrivilegeObjectAuditAlarm(SubsystemName: PUNICODE_STRING; HandleId: PVOID; TokenHandle: HANDLE; DesiredAccess: ACCESS_MASK; Privileges: PPRIVILEGE_SET; AccessGranted: BOOLEAN): NTSTATUS; stdcall; external ntdll;
   

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtProtectVirtualMemory(
    ProcessHandle : HANDLE;
    BaseAddress : PPVOID;
    ProtectSize : PULONG;
    NewProtect : ULONG;
    OldProtect : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwProtectVirtualMemory(ProcessHandle: HANDLE; BaseAddress: PPVOID; ProtectSize: PULONG; NewProtect: ULONG; OldProtect: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtPulseEvent(
    EventHandle : HANDLE;
    PreviousState : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwPulseEvent(EventHandle: HANDLE; PreviousState: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryAttributesFile(
    ObjectAttributes : POBJECT_ATTRIBUTES;
    FileInformation : PFILE_BASIC_INFORMATION
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryAttributesFile(ObjectAttributes: POBJECT_ATTRIBUTES; FileInformation: PFILE_BASIC_INFORMATION): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryDefaultLocale(
    ThreadOrSystem : BOOLEAN;
    Locale : PLCID
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryDefaultLocale(ThreadOrSystem: BOOLEAN; Locale: PLCID): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtQueryDefaultUILanguage(
    LanguageId : PLANGID
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryDefaultUILanguage(LanguageId: PLANGID): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryDirectoryFile(
    FileHandle : HANDLE;
    Event : HANDLE;
    ApcRoutine : PIO_APC_ROUTINE;
    ApcContext : PVOID;
    IoStatusBlock : PIO_STATUS_BLOCK;
    FileInformation : PVOID;
    FileInformationLength : ULONG;
    FileInformationClass : FILE_INFORMATION_CLASS;
    ReturnSingleEntry : BOOLEAN;
    FileName : PUNICODE_STRING;
    RestartScan : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryDirectoryFile(FileHandle: HANDLE; Event: HANDLE; ApcRoutine: PIO_APC_ROUTINE; ApcContext: PVOID; IoStatusBlock: PIO_STATUS_BLOCK; FileInformation: PVOID; FileInformationLength: ULONG;
    FileInformationClass: FILE_INFORMATION_CLASS; ReturnSingleEntry: BOOLEAN; FileName: PUNICODE_STRING; RestartScan: BOOLEAN): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryDirectoryObject(
    DirectoryHandle : HANDLE;
    Buffer : PVOID;
    BufferLength : ULONG;
    ReturnSingleEntry : BOOLEAN;
    RestartScan : BOOLEAN;
    Context : PULONG;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryDirectoryObject(DirectoryHandle: HANDLE; Buffer: PVOID; BufferLength: ULONG; ReturnSingleEntry: BOOLEAN; RestartScan: BOOLEAN; Context: PULONG; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;
   

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryEaFile(
    FileHandle : HANDLE;
    IoStatusBlock : PIO_STATUS_BLOCK;
    Buffer : PFILE_FULL_EA_INFORMATION;
    BufferLength : ULONG;
    ReturnSingleEntry : BOOLEAN;
    EaList : PFILE_GET_EA_INFORMATION;
    EaListLength : ULONG;
    EaIndex : PULONG;
    RestartScan : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryEaFile(FileHandle: HANDLE; IoStatusBlock: PIO_STATUS_BLOCK; Buffer: PFILE_FULL_EA_INFORMATION; BufferLength: ULONG; ReturnSingleEntry: BOOLEAN; EaList: PFILE_GET_EA_INFORMATION; EaListLength: ULONG; EaIndex: PULONG;
    RestartScan: BOOLEAN): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryEvent(
    EventHandle : HANDLE;
    EventInformationClass : EVENT_INFORMATION_CLASS;
    EventInformation : PVOID;
    EventInformationLength : ULONG;
    ResultLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryEvent(EventHandle: HANDLE; EventInformationClass: EVENT_INFORMATION_CLASS; EventInformation: PVOID; EventInformationLength: ULONG; ResultLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT4, W2K, WXP, 2K3
function  NtQueryFullAttributesFile(
    ObjectAttributes : POBJECT_ATTRIBUTES;
    FileInformation : PFILE_NETWORK_OPEN_INFORMATION
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryFullAttributesFile(ObjectAttributes: POBJECT_ATTRIBUTES; FileInformation: PFILE_NETWORK_OPEN_INFORMATION): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT4, W2K, WXP, 2K3
function  NtQueryInformationAtom(
    Atom : USHORT;
    AtomInformationClass : ATOM_INFORMATION_CLASS;
    AtomInformation : PVOID;
    AtomInformationLength : ULONG;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryInformationAtom(Atom: USHORT; AtomInformationClass: ATOM_INFORMATION_CLASS; AtomInformation: PVOID; AtomInformationLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwQueryInformationFile().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryInformationFile(
    FileHandle : HANDLE;
    IoStatusBlock : PIO_STATUS_BLOCK;
    FileInformation : PVOID;
    FileInformationLength : ULONG;
    FileInformationClass : FILE_INFORMATION_CLASS
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryInformationFile(FileHandle: HANDLE; IoStatusBlock: PIO_STATUS_BLOCK; FileInformation: PVOID; FileInformationLength: ULONG; FileInformationClass: FILE_INFORMATION_CLASS): NTSTATUS; stdcall; external ntdll;
   

// Compatibility: W2K, WXP, 2K3
function  NtQueryInformationJobObject(
    JobHandle : HANDLE;
    JobInformationClass : JOBOBJECTINFOCLASS;
    JobInformation : PVOID;
    JobInformationLength : ULONG;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryInformationJobObject(JobHandle: HANDLE; JobInformationClass: JOBOBJECTINFOCLASS; JobInformation: PVOID; JobInformationLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryInformationPort(
    PortHandle : HANDLE;
    PortInformationClass : PORT_INFORMATION_CLASS;
    PortInformation : PVOID;
    PortInformationLength : ULONG;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryInformationPort(PortHandle: HANDLE; PortInformationClass: PORT_INFORMATION_CLASS; PortInformation: PVOID; PortInformationLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryInformationProcess(
    ProcessHandle : HANDLE;
    ProcessInformationClass : PROCESSINFOCLASS;
    ProcessInformation : PVOID;
    ProcessInformationLength : ULONG;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryInformationProcess(ProcessHandle: HANDLE; ProcessInformationClass: PROCESSINFOCLASS; ProcessInformation: PVOID; ProcessInformationLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;
   

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryInformationThread(
    ThreadHandle : HANDLE;
    ThreadInformationClass : THREADINFOCLASS;
    ThreadInformation : PVOID;
    ThreadInformationLength : ULONG;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryInformationThread(ThreadHandle: HANDLE; ThreadInformationClass: THREADINFOCLASS; ThreadInformation: PVOID; ThreadInformationLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryInformationToken(
    TokenHandle : HANDLE;
    TokenInformationClass : TOKEN_INFORMATION_CLASS;
    TokenInformation : PVOID;
    TokenInformationLength : ULONG;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryInformationToken(TokenHandle: HANDLE; TokenInformationClass: TOKEN_INFORMATION_CLASS; TokenInformation: PVOID; TokenInformationLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtQueryInstallUILanguage(
    LanguageId : PLANGID
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryInstallUILanguage(LanguageId: PLANGID): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryIntervalProfile(
    Source : KPROFILE_SOURCE;
    Interval : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryIntervalProfile(Source: KPROFILE_SOURCE; Interval: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryIoCompletion(
    IoCompletionHandle : HANDLE;
    IoCompletionInformationClass : IO_COMPLETION_INFORMATION_CLASS;
    IoCompletionInformation : PVOID;
    IoCompletionInformationLength : ULONG;
    ResultLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryIoCompletion(IoCompletionHandle: HANDLE; IoCompletionInformationClass: IO_COMPLETION_INFORMATION_CLASS; IoCompletionInformation: PVOID; IoCompletionInformationLength: ULONG; ResultLength: PULONG): NTSTATUS; stdcall;
    external ntdll;

// Documented in the DDK as ZwQueryKey().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryKey(
    KeyHandle : HANDLE;
    KeyInformationClass : KEY_INFORMATION_CLASS;
    KeyInformation : PVOID;
    KeyInformationLength : ULONG;
    ResultLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryKey(KeyHandle: HANDLE; KeyInformationClass: KEY_INFORMATION_CLASS; KeyInformation: PVOID; KeyInformationLength: ULONG; ResultLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT4, W2K, WXP, 2K3
function  NtQueryMultipleValueKey(
    KeyHandle : HANDLE;
    ValueList : PKEY_VALUE_ENTRY;
    NumberOfValues : ULONG;
    Buffer : PVOID;
    Length : PULONG;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryMultipleValueKey(KeyHandle: HANDLE; ValueList: PKEY_VALUE_ENTRY; NumberOfValues: ULONG; Buffer: PVOID; Length: PULONG; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryMutant(
    MutantHandle : HANDLE;
    MutantInformationClass : MUTANT_INFORMATION_CLASS;
    MutantInformation : PVOID;
    MutantInformationLength : ULONG;
    ResultLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryMutant(MutantHandle: HANDLE; MutantInformationClass: MUTANT_INFORMATION_CLASS; MutantInformation: PVOID; MutantInformationLength: ULONG; ResultLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryObject(
    ObjectHandle : HANDLE;
    ObjectInformationClass : OBJECT_INFORMATION_CLASS;
    ObjectInformation : PVOID;
    ObjectInformationLength : ULONG;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryObject(ObjectHandle: HANDLE; ObjectInformationClass: OBJECT_INFORMATION_CLASS; ObjectInformation: PVOID; ObjectInformationLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtQueryOpenSubKeys(
    KeyObjectAttributes : POBJECT_ATTRIBUTES;
    NumberOfKey : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryOpenSubKeys(KeyObjectAttributes: POBJECT_ATTRIBUTES; NumberOfKey: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryPerformanceCounter(
    PerformanceCount : PLARGE_INTEGER;
    PerformanceFrequency : PLARGE_INTEGER
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryPerformanceCounter(PerformanceCount: PLARGE_INTEGER; PerformanceFrequency: PLARGE_INTEGER): NTSTATUS; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  NtQueryPortInformationProcess(): ULONG; stdcall; external ntdll;
function  ZwQueryPortInformationProcess(): ULONG; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtQueryQuotaInformationFile(
    FileHandle : HANDLE;
    IoStatusBlock : PIO_STATUS_BLOCK;
    Buffer : PFILE_USER_QUOTA_INFORMATION;
    BufferLength : ULONG;
    ReturnSingleEntry : BOOLEAN;
    QuotaList : PFILE_QUOTA_LIST_INFORMATION;
    QuotaListLength : ULONG;
    ResumeSid : PSID;
    RestartScan : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryQuotaInformationFile(FileHandle: HANDLE; IoStatusBlock: PIO_STATUS_BLOCK; Buffer: PFILE_USER_QUOTA_INFORMATION; BufferLength: ULONG; ReturnSingleEntry: BOOLEAN; QuotaList: PFILE_QUOTA_LIST_INFORMATION;
    QuotaListLength: ULONG; ResumeSid: PSID; RestartScan: BOOLEAN): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQuerySection(
    SectionHandle : HANDLE;
    SectionInformationClass : SECTION_INFORMATION_CLASS;
    SectionInformation : PVOID;
    SectionInformationLength : ULONG;
    ResultLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQuerySection(SectionHandle: HANDLE; SectionInformationClass: SECTION_INFORMATION_CLASS; SectionInformation: PVOID; SectionInformationLength: ULONG; ResultLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQuerySecurityObject(
    Handle : HANDLE;
    RequestedInformation : SECURITY_INFORMATION;
    SecurityDescriptor : PSECURITY_DESCRIPTOR;
    SecurityDescriptorLength : ULONG;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQuerySecurityObject(Handle: HANDLE; RequestedInformation: SECURITY_INFORMATION; SecurityDescriptor: PSECURITY_DESCRIPTOR; SecurityDescriptorLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;
   

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQuerySemaphore(
    SemaphoreHandle : HANDLE;
    SemaphoreInformationClass : SEMAPHORE_INFORMATION_CLASS;
    SemaphoreInformation : PVOID;
    SemaphoreInformationLength : ULONG;
    ResultLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQuerySemaphore(SemaphoreHandle: HANDLE; SemaphoreInformationClass: SEMAPHORE_INFORMATION_CLASS; SemaphoreInformation: PVOID; SemaphoreInformationLength: ULONG; ResultLength: PULONG): NTSTATUS; stdcall;
    external ntdll;

// Documented in the DDK as ZwQuerySymbolicLinkObject().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQuerySymbolicLinkObject(
    SymbolicLinkHandle : HANDLE;
    TargetName : PUNICODE_STRING;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQuerySymbolicLinkObject(SymbolicLinkHandle: HANDLE; TargetName: PUNICODE_STRING; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQuerySystemEnvironmentValue(
    Name : PUNICODE_STRING;
    Value : PVOID;
    ValueLength : ULONG;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQuerySystemEnvironmentValue(Name: PUNICODE_STRING; Value: PVOID; ValueLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQuerySystemInformation(
    SystemInformationClass : SYSTEM_INFORMATION_CLASS;
    SystemInformation : PVOID;
    SystemInformationLength : ULONG;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQuerySystemInformation(SystemInformationClass: SYSTEM_INFORMATION_CLASS; SystemInformation: PVOID; SystemInformationLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQuerySystemTime(
    CurrentTime : PLARGE_INTEGER
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQuerySystemTime(CurrentTime: PLARGE_INTEGER): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryTimer(
    TimerHandle : HANDLE;
    TimerInformationClass : TIMER_INFORMATION_CLASS;
    TimerInformation : PVOID;
    TimerInformationLength : ULONG;
    ResultLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryTimer(TimerHandle: HANDLE; TimerInformationClass: TIMER_INFORMATION_CLASS; TimerInformation: PVOID; TimerInformationLength: ULONG; ResultLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryTimerResolution(
    CoarsestResolution : PULONG;
    FinestResolution : PULONG;
    ActualResolution : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryTimerResolution(CoarsestResolution: PULONG; FinestResolution: PULONG; ActualResolution: PULONG): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwQueryValueKey().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryValueKey(
    KeyHandle : HANDLE;
    ValueName : PUNICODE_STRING;
    KeyValueInformationClass : KEY_VALUE_INFORMATION_CLASS;
    KeyValueInformation : PVOID;
    KeyValueInformationLength : ULONG;
    ResultLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryValueKey(KeyHandle: HANDLE; ValueName: PUNICODE_STRING; KeyValueInformationClass: KEY_VALUE_INFORMATION_CLASS; KeyValueInformation: PVOID; KeyValueInformationLength: ULONG; ResultLength: PULONG): NTSTATUS; stdcall;
    external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryVirtualMemory(
    ProcessHandle : HANDLE;
    BaseAddress : PVOID;
    MemoryInformationClass : MEMORY_INFORMATION_CLASS;
    MemoryInformation : PVOID;
    MemoryInformationLength : ULONG;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryVirtualMemory(ProcessHandle: HANDLE; BaseAddress: PVOID; MemoryInformationClass: MEMORY_INFORMATION_CLASS; MemoryInformation: PVOID; MemoryInformationLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall;
    external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtQueryVolumeInformationFile(
    FileHandle : HANDLE;
    IoStatusBlock : PIO_STATUS_BLOCK;
    VolumeInformation : PVOID;
    VolumeInformationLength : ULONG;
    VolumeInformationClass : FS_INFORMATION_CLASS
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueryVolumeInformationFile(FileHandle: HANDLE; IoStatusBlock: PIO_STATUS_BLOCK; VolumeInformation: PVOID; VolumeInformationLength: ULONG; VolumeInformationClass: FS_INFORMATION_CLASS): NTSTATUS; stdcall;
    external ntdll;

// Compatibility: NT4, W2K, WXP, 2K3
function  NtQueueApcThread(
    ThreadHandle : HANDLE;
    ApcRoutine : PKNORMAL_ROUTINE;
    ApcContext : PVOID;
    Argument1 : PVOID;
    Argument2 : PVOID
  ): NTSTATUS; stdcall; external ntdll;
function  ZwQueueApcThread(ThreadHandle: HANDLE; ApcRoutine: PKNORMAL_ROUTINE; ApcContext: PVOID; Argument1: PVOID; Argument2: PVOID): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtRaiseException(
    ExceptionRecord : PEXCEPTION_RECORD;
    Context : PCONTEXT;
    SearchFrames : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwRaiseException(ExceptionRecord: PEXCEPTION_RECORD; Context: PCONTEXT; SearchFrames: BOOLEAN): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtRaiseHardError(
    Status : NTSTATUS;
    NumberOfArguments : ULONG;
    StringArgumentsMask : ULONG;
    Arguments : PULONG;
    MessageBoxType : ULONG;
    MessageBoxResult : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwRaiseHardError(Status: NTSTATUS; NumberOfArguments: ULONG; StringArgumentsMask: ULONG; Arguments: PULONG; MessageBoxType: ULONG; MessageBoxResult: PULONG): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwReadFile().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtReadFile(
    FileHandle : HANDLE;
    Event : HANDLE;
    ApcRoutine : PIO_APC_ROUTINE;
    ApcContext : PVOID;
    IoStatusBlock : PIO_STATUS_BLOCK;
    Buffer : PVOID;
    Length : ULONG;
    ByteOffset : PLARGE_INTEGER;
    Key : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwReadFile(FileHandle: HANDLE; Event: HANDLE; ApcRoutine: PIO_APC_ROUTINE; ApcContext: PVOID; IoStatusBlock: PIO_STATUS_BLOCK; Buffer: PVOID; Length: ULONG; ByteOffset: PLARGE_INTEGER; Key: PULONG): NTSTATUS; stdcall;
    external ntdll;

// Compatibility: NT4, W2K, WXP, 2K3
function  NtReadFileScatter(
    FileHandle : HANDLE;
    Event : HANDLE;
    ApcRoutine : PIO_APC_ROUTINE;
    ApcContext : PVOID;
    IoStatusBlock : PIO_STATUS_BLOCK;
    Buffer : PFILE_SEGMENT_ELEMENT;
    Length : ULONG;
    ByteOffset : PLARGE_INTEGER;
    Key : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwReadFileScatter(FileHandle: HANDLE; Event: HANDLE; ApcRoutine: PIO_APC_ROUTINE; ApcContext: PVOID; IoStatusBlock: PIO_STATUS_BLOCK; Buffer: PFILE_SEGMENT_ELEMENT; Length: ULONG; ByteOffset: PLARGE_INTEGER;
    Key: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtReadRequestData(
    PortHandle : HANDLE;
    Message : PPORT_MESSAGE;
    Index : ULONG;
    Buffer : PVOID;
    BufferLength : ULONG;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwReadRequestData(PortHandle: HANDLE; Message: PPORT_MESSAGE; Index: ULONG; Buffer: PVOID; BufferLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtReadVirtualMemory(
    ProcessHandle : HANDLE;
    BaseAddress : PVOID;
    Buffer : PVOID;
    BufferLength : ULONG;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwReadVirtualMemory(ProcessHandle: HANDLE; BaseAddress: PVOID; Buffer: PVOID; BufferLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtRegisterThreadTerminatePort(
    PortHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwRegisterThreadTerminatePort(PortHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtReleaseMutant(
    MutantHandle : HANDLE;
    PreviousState : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwReleaseMutant(MutantHandle: HANDLE; PreviousState: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtReleaseSemaphore(
    SemaphoreHandle : HANDLE;
    ReleaseCount : LONG;
    PreviousCount : PLONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwReleaseSemaphore(SemaphoreHandle: HANDLE; ReleaseCount: LONG; PreviousCount: PLONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtRemoveIoCompletion(
    IoCompletionHandle : HANDLE;
    CompletionKey : PULONG;
    CompletionValue : PULONG;
    IoStatusBlock : PIO_STATUS_BLOCK;
    Timeout : PLARGE_INTEGER
  ): NTSTATUS; stdcall; external ntdll;
function  ZwRemoveIoCompletion(IoCompletionHandle: HANDLE; CompletionKey: PULONG; CompletionValue: PULONG; IoStatusBlock: PIO_STATUS_BLOCK; Timeout: PLARGE_INTEGER): NTSTATUS; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  NtRemoveProcessDebug(
    hProcess : HANDLE;
    hDebugObject : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwRemoveProcessDebug(hProcess: HANDLE; hDebugObject: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtReplaceKey(
    NewFileObjectAttributes : POBJECT_ATTRIBUTES;
    KeyHandle : HANDLE;
    OldFileObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwReplaceKey(NewFileObjectAttributes: POBJECT_ATTRIBUTES; KeyHandle: HANDLE; OldFileObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtReplyPort(
    PortHandle : HANDLE;
    ReplyMessage : PPORT_MESSAGE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwReplyPort(PortHandle: HANDLE; ReplyMessage: PPORT_MESSAGE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtReplyWaitReceivePort(
    PortHandle : HANDLE;
    PortIdentifier : PULONG;
    ReplyMessage : PPORT_MESSAGE;
    Message : PPORT_MESSAGE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwReplyWaitReceivePort(PortHandle: HANDLE; PortIdentifier: PULONG; ReplyMessage: PPORT_MESSAGE; Message: PPORT_MESSAGE): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtReplyWaitReceivePortEx(
    PortHandle : HANDLE;
    PortIdentifier : PULONG;
    ReplyMessage : PPORT_MESSAGE;
    Message : PPORT_MESSAGE;
    Timeout : PLARGE_INTEGER
  ): NTSTATUS; stdcall; external ntdll;
function  ZwReplyWaitReceivePortEx(PortHandle: HANDLE; PortIdentifier: PULONG; ReplyMessage: PPORT_MESSAGE; Message: PPORT_MESSAGE; Timeout: PLARGE_INTEGER): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtReplyWaitReplyPort(
    PortHandle : HANDLE;
    ReplyMessage : PPORT_MESSAGE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwReplyWaitReplyPort(PortHandle: HANDLE; ReplyMessage: PPORT_MESSAGE): NTSTATUS; stdcall; external ntdll;

// Returns STATUS_NOT_IMPLEMENTED. Only MS knows the intention behind this.
// 
// !!!DO NOT USE!!!
// Compatibility: NT4, W2K
function  NtReplyWaitSendChannel(
    x : PVOID;
    y : PVOID;
    z : PVOID
  ): NTSTATUS; stdcall; external ntdll;
function  ZwReplyWaitSendChannel(x: PVOID; y: PVOID; z: PVOID): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtRequestDeviceWakeup(
    DeviceHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwRequestDeviceWakeup(DeviceHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtRequestPort(
    PortHandle : HANDLE;
    RequestMessage : PPORT_MESSAGE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwRequestPort(PortHandle: HANDLE; RequestMessage: PPORT_MESSAGE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtRequestWaitReplyPort(
    PortHandle : HANDLE;
    RequestMessage : PPORT_MESSAGE;
    ReplyMessage : PPORT_MESSAGE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwRequestWaitReplyPort(PortHandle: HANDLE; RequestMessage: PPORT_MESSAGE; ReplyMessage: PPORT_MESSAGE): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtRequestWakeupLatency(
    Latency : LATENCY_TIME
  ): NTSTATUS; stdcall; external ntdll;
function  ZwRequestWakeupLatency(Latency: LATENCY_TIME): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtResetEvent(
    EventHandle : HANDLE;
    PreviousState : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwResetEvent(EventHandle: HANDLE; PreviousState: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtResetWriteWatch(
    ProcessHandle : HANDLE;
    BaseAddress : PVOID;
    RegionSize : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwResetWriteWatch(ProcessHandle: HANDLE; BaseAddress: PVOID; RegionSize: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtRestoreKey(
    KeyHandle : HANDLE;
    FileHandle : HANDLE;
    Flags : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwRestoreKey(KeyHandle: HANDLE; FileHandle: HANDLE; Flags: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  NtResumeProcess(
    hProcess : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwResumeProcess(hProcess: HANDLE): NTSTATUS; stdcall; external ntdll;

// This function is very similar to ResumeThread() from Kernel32.dll. Refer
// to the PSDK for additional information. Usually the same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtResumeThread(
    hThread : HANDLE;
    dwResumeCount : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwResumeThread(hThread: HANDLE; dwResumeCount: PULONG): NTSTATUS; stdcall; external ntdll;

// Relates to RegSaveKey().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSaveKey(
    KeyHandle : HANDLE;
    FileHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSaveKey(KeyHandle: HANDLE; FileHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Relates to RegSaveKeyEx().
// Compatibility: WXP, 2K3
function  NtSaveKeyEx(
    KeyHandle : HANDLE;
    FileHandle : HANDLE;
    Flags : DWORD
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSaveKeyEx(KeyHandle: HANDLE; FileHandle: HANDLE; Flags: DWORD): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtSaveMergedKeys(
    KeyHandle1 : HANDLE;
    KeyHandle2 : HANDLE;
    FileHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSaveMergedKeys(KeyHandle1: HANDLE; KeyHandle2: HANDLE; FileHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtSecureConnectPort(
    PortHandle : PHANDLE;
    PortName : PUNICODE_STRING;
    SecurityQos : PSECURITY_QUALITY_OF_SERVICE;
    WriteSection : PPORT_SECTION_WRITE;
    ServerSid : PSID;
    ReadSection : PPORT_SECTION_READ;
    MaxMessageSize : PULONG;
    ConnectData : PVOID;
    ConnectDataLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSecureConnectPort(PortHandle: PHANDLE; PortName: PUNICODE_STRING; SecurityQos: PSECURITY_QUALITY_OF_SERVICE; WriteSection: PPORT_SECTION_WRITE; ServerSid: PSID; ReadSection: PPORT_SECTION_READ; MaxMessageSize: PULONG;
    ConnectData: PVOID; ConnectDataLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Returns STATUS_NOT_IMPLEMENTED. Only MS knows the intention behind this.
// 
// !!!DO NOT USE!!!
// Compatibility: NT4, W2K
function  NtSendWaitReplyChannel(
    x : PVOID;
    y : PVOID;
    z : PVOID;
    z2 : PVOID
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSendWaitReplyChannel(x: PVOID; y: PVOID; z: PVOID; z2: PVOID): NTSTATUS; stdcall; external ntdll;

// Returns STATUS_NOT_IMPLEMENTED. Only MS knows the intention behind this.
// 
// !!!DO NOT USE!!!
// Compatibility: NT4, W2K
function  NtSetContextChannel(
    x : PVOID
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetContextChannel(x: PVOID): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetContextThread(
    ThreadHandle : HANDLE;
    Context : PCONTEXT
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetContextThread(ThreadHandle: HANDLE; Context: PCONTEXT): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetDefaultHardErrorPort(
    PortHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetDefaultHardErrorPort(PortHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetDefaultLocale(
    ThreadOrSystem : BOOLEAN;
    Locale : LCID
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetDefaultLocale(ThreadOrSystem: BOOLEAN; Locale: LCID): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtSetDefaultUILanguage(
    LanguageId : LANGID
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetDefaultUILanguage(LanguageId: LANGID): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetEaFile(
    FileHandle : HANDLE;
    IoStatusBlock : PIO_STATUS_BLOCK;
    Buffer : PFILE_FULL_EA_INFORMATION;
    BufferLength : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetEaFile(FileHandle: HANDLE; IoStatusBlock: PIO_STATUS_BLOCK; Buffer: PFILE_FULL_EA_INFORMATION; BufferLength: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetEvent(
    EventHandle : HANDLE;
    PreviousState : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetEvent(EventHandle: HANDLE; PreviousState: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetHighEventPair(
    EventPairHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetHighEventPair(EventPairHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetHighWaitLowEventPair(
    EventPairHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetHighWaitLowEventPair(EventPairHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4
function  NtSetHighWaitLowThread(): NTSTATUS; stdcall; external ntdll;
function  ZwSetHighWaitLowThread(): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwSetInformationFile().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetInformationFile(
    FileHandle : HANDLE;
    IoStatusBlock : PIO_STATUS_BLOCK;
    FileInformation : PVOID;
    FileInformationLength : ULONG;
    FileInformationClass : FILE_INFORMATION_CLASS
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetInformationFile(FileHandle: HANDLE; IoStatusBlock: PIO_STATUS_BLOCK; FileInformation: PVOID; FileInformationLength: ULONG; FileInformationClass: FILE_INFORMATION_CLASS): NTSTATUS; stdcall; external ntdll;
   

// Compatibility: W2K, WXP, 2K3
function  NtSetInformationJobObject(
    JobHandle : HANDLE;
    JobInformationClass : JOBOBJECTINFOCLASS;
    JobInformation : PVOID;
    JobInformationLength : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetInformationJobObject(JobHandle: HANDLE; JobInformationClass: JOBOBJECTINFOCLASS; JobInformation: PVOID; JobInformationLength: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetInformationKey(
    KeyHandle : HANDLE;
    KeyInformationClass : KEY_SET_INFORMATION_CLASS;
    KeyInformation : PVOID;
    KeyInformationLength : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetInformationKey(KeyHandle: HANDLE; KeyInformationClass: KEY_SET_INFORMATION_CLASS; KeyInformation: PVOID; KeyInformationLength: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetInformationObject(
    ObjectHandle : HANDLE;
    ObjectInformationClass : OBJECT_INFORMATION_CLASS;
    ObjectInformation : PVOID;
    ObjectInformationLength : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetInformationObject(ObjectHandle: HANDLE; ObjectInformationClass: OBJECT_INFORMATION_CLASS; ObjectInformation: PVOID; ObjectInformationLength: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetInformationProcess(
    ProcessHandle : HANDLE;
    ProcessInformationClass : PROCESSINFOCLASS;
    ProcessInformation : PVOID;
    ProcessInformationLength : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetInformationProcess(ProcessHandle: HANDLE; ProcessInformationClass: PROCESSINFOCLASS; ProcessInformation: PVOID; ProcessInformationLength: ULONG): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwSetInformationThread().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetInformationThread(
    ThreadHandle : HANDLE;
    ThreadInformationClass : THREADINFOCLASS;
    ThreadInformation : PVOID;
    ThreadInformationLength : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetInformationThread(ThreadHandle: HANDLE; ThreadInformationClass: THREADINFOCLASS; ThreadInformation: PVOID; ThreadInformationLength: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetInformationToken(
    TokenHandle : HANDLE;
    TokenInformationClass : TOKEN_INFORMATION_CLASS;
    TokenInformation : PVOID;
    TokenInformationLength : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetInformationToken(TokenHandle: HANDLE; TokenInformationClass: TOKEN_INFORMATION_CLASS; TokenInformation: PVOID; TokenInformationLength: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetIntervalProfile(
    Interval : ULONG;
    Source : KPROFILE_SOURCE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetIntervalProfile(Interval: ULONG; Source: KPROFILE_SOURCE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetIoCompletion(
    IoCompletionHandle : HANDLE;
    CompletionKey : ULONG;
    CompletionValue : ULONG;
    Status : NTSTATUS;
    Information : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetIoCompletion(IoCompletionHandle: HANDLE; CompletionKey: ULONG; CompletionValue: ULONG; Status: NTSTATUS; Information: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetLdtEntries(
    Selector1 : ULONG;
    LdtEntry1 : LDT_ENTRY;
    Selector2 : ULONG;
    LdtEntry2 : LDT_ENTRY
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetLdtEntries(Selector1: ULONG; LdtEntry1: LDT_ENTRY; Selector2: ULONG; LdtEntry2: LDT_ENTRY): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetLowEventPair(
    EventPairHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetLowEventPair(EventPairHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetLowWaitHighEventPair(
    EventPairHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetLowWaitHighEventPair(EventPairHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4
function  NtSetLowWaitHighThread(): NTSTATUS; stdcall; external ntdll;
function  ZwSetLowWaitHighThread(): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtSetQuotaInformationFile(
    FileHandle : HANDLE;
    IoStatusBlock : PIO_STATUS_BLOCK;
    Buffer : PFILE_USER_QUOTA_INFORMATION;
    BufferLength : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetQuotaInformationFile(FileHandle: HANDLE; IoStatusBlock: PIO_STATUS_BLOCK; Buffer: PFILE_USER_QUOTA_INFORMATION; BufferLength: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetSecurityObject(
    Handle : HANDLE;
    SecurityInformation : SECURITY_INFORMATION;
    SecurityDescriptor : PSECURITY_DESCRIPTOR
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetSecurityObject(Handle: HANDLE; SecurityInformation: SECURITY_INFORMATION; SecurityDescriptor: PSECURITY_DESCRIPTOR): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetSystemEnvironmentValue(
    Name : PUNICODE_STRING;
    Value : PUNICODE_STRING
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetSystemEnvironmentValue(Name: PUNICODE_STRING; Value: PUNICODE_STRING): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetSystemInformation(
    SystemInformationClass : SYSTEM_INFORMATION_CLASS;
    SystemInformation : PVOID;
    SystemInformationLength : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetSystemInformation(SystemInformationClass: SYSTEM_INFORMATION_CLASS; SystemInformation: PVOID; SystemInformationLength: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetSystemPowerState(
    SystemAction : POWER_ACTION;
    MinSystemState : SYSTEM_POWER_STATE;
    Flags : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetSystemPowerState(SystemAction: POWER_ACTION; MinSystemState: SYSTEM_POWER_STATE; Flags: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetSystemTime(
    NewTime : PLARGE_INTEGER;
    OldTime : PLARGE_INTEGER
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetSystemTime(NewTime: PLARGE_INTEGER; OldTime: PLARGE_INTEGER): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtSetThreadExecutionState(
    ExecutionState : EXECUTION_STATE;
    PreviousExecutionState : PEXECUTION_STATE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetThreadExecutionState(ExecutionState: EXECUTION_STATE; PreviousExecutionState: PEXECUTION_STATE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetTimer(
    TimerHandle : HANDLE;
    DueTime : PLARGE_INTEGER;
    TimerApcRoutine : PTIMER_APC_ROUTINE;
    TimerContext : PVOID;
    Resume : BOOLEAN;
    Period : LONG;
    PreviousState : PBOOLEAN
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetTimer(TimerHandle: HANDLE; DueTime: PLARGE_INTEGER; TimerApcRoutine: PTIMER_APC_ROUTINE; TimerContext: PVOID; Resume: BOOLEAN; Period: LONG; PreviousState: PBOOLEAN): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetTimerResolution(
    RequestedResolution : ULONG;
    Set_ : BOOLEAN;
    ActualResolution : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetTimerResolution(RequestedResolution: ULONG; Set_: BOOLEAN; ActualResolution: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtSetUuidSeed(
    UuidSeed : PUCHAR
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetUuidSeed(UuidSeed: PUCHAR): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwSetValueKey().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetValueKey(
    KeyHandle : HANDLE;
    ValueName : PUNICODE_STRING;
    TitleIndex : ULONG;
    Type_ : ULONG;
    Data : PVOID;
    DataSize : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetValueKey(KeyHandle: HANDLE; ValueName: PUNICODE_STRING; TitleIndex: ULONG; Type_: ULONG; Data: PVOID; DataSize: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSetVolumeInformationFile(
    FileHandle : HANDLE;
    IoStatusBlock : PIO_STATUS_BLOCK;
    Buffer : PVOID;
    BufferLength : ULONG;
    VolumeInformationClass : FS_INFORMATION_CLASS
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSetVolumeInformationFile(FileHandle: HANDLE; IoStatusBlock: PIO_STATUS_BLOCK; Buffer: PVOID; BufferLength: ULONG; VolumeInformationClass: FS_INFORMATION_CLASS): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtShutdownSystem(
    Action : SHUTDOWN_ACTION
  ): NTSTATUS; stdcall; external ntdll;
function  ZwShutdownSystem(Action: SHUTDOWN_ACTION): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT4, W2K, WXP, 2K3
function  NtSignalAndWaitForSingleObject(
    HandleToSignal : HANDLE;
    HandleToWait : HANDLE;
    Alertable : BOOLEAN;
    Timeout : PLARGE_INTEGER
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSignalAndWaitForSingleObject(HandleToSignal: HANDLE; HandleToWait: HANDLE; Alertable: BOOLEAN; Timeout: PLARGE_INTEGER): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtStartProfile(
    ProfileHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwStartProfile(ProfileHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtStopProfile(
    ProfileHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwStopProfile(ProfileHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  NtSuspendProcess(
    hProcess : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSuspendProcess(hProcess: HANDLE): NTSTATUS; stdcall; external ntdll;

// This function is very similar to SuspendThread() from Kernel32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSuspendThread(
    hThread : HANDLE;
    dwLastResumeCount : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSuspendThread(hThread: HANDLE; dwLastResumeCount: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtSystemDebugControl(
    ControlCode : DEBUG_CONTROL_CODE;
    InputBuffer : PVOID;
    InputBufferLength : ULONG;
    OutputBuffer : PVOID;
    OutputBufferLength : ULONG;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwSystemDebugControl(ControlCode: DEBUG_CONTROL_CODE; InputBuffer: PVOID; InputBufferLength: ULONG; OutputBuffer: PVOID; OutputBufferLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  NtTerminateJobObject(
    JobHandle : HANDLE;
    ExitStatus : NTSTATUS
  ): NTSTATUS; stdcall; external ntdll;
function  ZwTerminateJobObject(JobHandle: HANDLE; ExitStatus: NTSTATUS): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtTerminateProcess(
    ProcessHandle : HANDLE;
    ExitStatus : NTSTATUS
  ): NTSTATUS; stdcall; external ntdll;
function  ZwTerminateProcess(ProcessHandle: HANDLE; ExitStatus: NTSTATUS): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtTerminateThread(
    ThreadHandle : HANDLE;
    ExitStatus : NTSTATUS
  ): NTSTATUS; stdcall; external ntdll;
function  ZwTerminateThread(ThreadHandle: HANDLE; ExitStatus: NTSTATUS): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtTestAlert(): NTSTATUS; stdcall; external ntdll;
function  ZwTestAlert(): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtUnloadDriver(
    DriverServiceName : PUNICODE_STRING
  ): NTSTATUS; stdcall; external ntdll;
function  ZwUnloadDriver(DriverServiceName: PUNICODE_STRING): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtUnloadKey(
    KeyObjectAttributes : POBJECT_ATTRIBUTES
  ): NTSTATUS; stdcall; external ntdll;
function  ZwUnloadKey(KeyObjectAttributes: POBJECT_ATTRIBUTES): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtUnlockFile(
    FileHandle : HANDLE;
    IoStatusBlock : PIO_STATUS_BLOCK;
    LockOffset : PULARGE_INTEGER;
    LockLength : PULARGE_INTEGER;
    Key : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwUnlockFile(FileHandle: HANDLE; IoStatusBlock: PIO_STATUS_BLOCK; LockOffset: PULARGE_INTEGER; LockLength: PULARGE_INTEGER; Key: ULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtUnlockVirtualMemory(
    ProcessHandle : HANDLE;
    BaseAddress : PPVOID;
    LockSize : PULONG;
    LockType : ULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwUnlockVirtualMemory(ProcessHandle: HANDLE; BaseAddress: PPVOID; LockSize: PULONG; LockType: ULONG): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwUnmapViewOfSection().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtUnmapViewOfSection(
    ProcessHandle : HANDLE;
    BaseAddress : PVOID
  ): NTSTATUS; stdcall; external ntdll;
function  ZwUnmapViewOfSection(ProcessHandle: HANDLE; BaseAddress: PVOID): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtVdmControl(
    ControlCode : ULONG;
    ControlData : PVOID
  ): NTSTATUS; stdcall; external ntdll;
function  ZwVdmControl(ControlCode: ULONG; ControlData: PVOID): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3
function  NtW32Call(
    RoutineIndex : ULONG;
    Argument : PVOID;
    ArgumentLength : ULONG;
    Result_ : PPVOID;
    ResultLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwW32Call(RoutineIndex: ULONG; Argument: PVOID; ArgumentLength: ULONG; Result_: PPVOID; ResultLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtWaitForMultipleObjects(
    HandleCount : ULONG;
    Handles : PHANDLE;
    WaitType : WAIT_TYPE;
    Alertable : BOOLEAN;
    Timeout : PLARGE_INTEGER
  ): NTSTATUS; stdcall; external ntdll;
function  ZwWaitForMultipleObjects(HandleCount: ULONG; Handles: PHANDLE; WaitType: WAIT_TYPE; Alertable: BOOLEAN; Timeout: PLARGE_INTEGER): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtWaitForSingleObject(
    Handle : HANDLE;
    Alertable : BOOLEAN;
    Timeout : PLARGE_INTEGER
  ): NTSTATUS; stdcall; external ntdll;
function  ZwWaitForSingleObject(Handle: HANDLE; Alertable: BOOLEAN; Timeout: PLARGE_INTEGER): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtWaitHighEventPair(
    EventPairHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwWaitHighEventPair(EventPairHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtWaitLowEventPair(
    EventPairHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;
function  ZwWaitLowEventPair(EventPairHandle: HANDLE): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK as ZwWriteFile().
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtWriteFile(
    FileHandle : HANDLE;
    Event : HANDLE;
    ApcRoutine : PIO_APC_ROUTINE;
    ApcContext : PVOID;
    IoStatusBlock : PIO_STATUS_BLOCK;
    Buffer : PVOID;
    Length : ULONG;
    ByteOffset : PLARGE_INTEGER;
    Key : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwWriteFile(FileHandle: HANDLE; Event: HANDLE; ApcRoutine: PIO_APC_ROUTINE; ApcContext: PVOID; IoStatusBlock: PIO_STATUS_BLOCK; Buffer: PVOID; Length: ULONG; ByteOffset: PLARGE_INTEGER; Key: PULONG): NTSTATUS; stdcall;
    external ntdll;

// Compatibility: NT4, W2K, WXP, 2K3
function  NtWriteFileGather(
    FileHandle : HANDLE;
    Event : HANDLE;
    ApcRoutine : PIO_APC_ROUTINE;
    ApcContext : PVOID;
    IoStatusBlock : PIO_STATUS_BLOCK;
    Buffer : PFILE_SEGMENT_ELEMENT;
    Length : ULONG;
    ByteOffset : PLARGE_INTEGER;
    Key : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwWriteFileGather(FileHandle: HANDLE; Event: HANDLE; ApcRoutine: PIO_APC_ROUTINE; ApcContext: PVOID; IoStatusBlock: PIO_STATUS_BLOCK; Buffer: PFILE_SEGMENT_ELEMENT; Length: ULONG; ByteOffset: PLARGE_INTEGER;
    Key: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtWriteRequestData(
    PortHandle : HANDLE;
    Message : PPORT_MESSAGE;
    Index : ULONG;
    Buffer : PVOID;
    BufferLength : ULONG;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwWriteRequestData(PortHandle: HANDLE; Message: PPORT_MESSAGE; Index: ULONG; Buffer: PVOID; BufferLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  NtWriteVirtualMemory(
    ProcessHandle : HANDLE;
    BaseAddress : PVOID;
    Buffer : PVOID;
    BufferLength : ULONG;
    ReturnLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;
function  ZwWriteVirtualMemory(ProcessHandle: HANDLE; BaseAddress: PVOID; Buffer: PVOID; BufferLength: ULONG; ReturnLength: PULONG): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT4, W2K, WXP, 2K3
function  NtYieldExecution(): NTSTATUS; stdcall; external ntdll;
function  ZwYieldExecution(): NTSTATUS; stdcall; external ntdll;

// This function is very similar to MakeSelfRelativeSD() from Advapi32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAbsoluteToSelfRelativeSD(
    pAbsoluteSD : PSECURITY_DESCRIPTOR;
    pSelfRelativeSD : PSECURITY_DESCRIPTOR;
    lpdwBufferLength : LPDWORD
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlAcquirePebLock(); stdcall; external ntdll;

// This function is very similar to AddAccessAllowedAce() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAddAccessAllowedAce(
    pAcl : PACL;
    dwAceRevision : DWORD;
    AccessMask : ACCESS_MASK;
    pSid : PSID
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to AddAccessAllowedAceEx() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: W2K, WXP, 2K3
function  RtlAddAccessAllowedAceEx(
    pAcl : PACL;
    dwAceRevision : DWORD;
    AceFlags : DWORD;
    AccessMask : ACCESS_MASK;
    pSid : PSID
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to AddAccessDeniedAce() from Advapi32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAddAccessDeniedAce(
    pAcl : PACL;
    dwAceRevision : DWORD;
    AccessMask : ACCESS_MASK;
    pSid : PSID
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to AddAccessDeniedAceEx() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: W2K, WXP, 2K3
function  RtlAddAccessDeniedAceEx(
    pAcl : PACL;
    dwAceRevision : DWORD;
    AceFlags : DWORD;
    AccessMask : ACCESS_MASK;
    pSid : PSID
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to AddAce() from Advapi32.dll. Refer to
// the PSDK for additional information. Usually the same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAddAce(
    pAcl : PACL;
    dwAceRevision : DWORD;
    dwStartingAceIndex : DWORD;
    pAceList : PVOID;
    nAceListLength : DWORD
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to AddAuditAccessAce() from Advapi32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAddAuditAccessAce(
    pAcl : PACL;
    dwAceRevision : DWORD;
    AccessMask : ACCESS_MASK;
    pSid : PSID;
    bAuditSuccess : BOOLEAN;
    bAuditFailure : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to AddAuditAccessAceEx() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: W2K, WXP, 2K3
function  RtlAddAuditAccessAceEx(
    pAcl : PACL;
    dwAceRevision : DWORD;
    AceFlags : DWORD;
    AccessMask : ACCESS_MASK;
    pSid : PSID;
    bAuditSuccess : BOOLEAN;
    bAuditFailure : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP
function  RtlAddRange(
    RangeList : PRTL_RANGE_LIST;
    Start : ULONGLONG;
    End_ : ULONGLONG;
    Attributes : UCHAR;
    Flags : ULONG;
    UserData : PVOID;
    Owner : PVOID
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  RtlAddVectoredExceptionHandler(
    FirstHandler : ULONG;
    VectoredHandler : PVECTORED_EXCEPTION_HANDLER
  ): PVOID; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAdjustPrivilege(
    Privilege : ULONG;
    Enable : BOOLEAN;
    CurrentThread : BOOLEAN;
    Enabled : PBOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to AllocateAndInitializeSid() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAllocateAndInitializeSid(
    pIdentifierAuthority : PSID_IDENTIFIER_AUTHORITY;
    SubAuthorityCount : BYTE;
    nSubAuthority0 : DWORD;
    nSubAuthority1 : DWORD;
    nSubAuthority2 : DWORD;
    nSubAuthority3 : DWORD;
    nSubAuthority4 : DWORD;
    nSubAuthority5 : DWORD;
    nSubAuthority6 : DWORD;
    nSubAuthority7 : DWORD;
    var pSid : PSID
  ): BOOL; stdcall; external ntdll;

// The function HeapAlloc() from Kernel32.dll is an export forwarder to
// this function. This means you can refer to the documentation of
// HeapAlloc()!
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAllocateHeap(
    hHeap : HANDLE;
    dwFlags : ULONG;
    Size : ULONG
  ): PVOID; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAnsiCharToUnicodeChar(
    AnsiChar : CHAR
  ): WCHAR; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAnsiStringToUnicodeSize(
    AnsiString : PANSI_STRING
  ): ULONG; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAnsiStringToUnicodeString(
    DestinationString : PUNICODE_STRING;
    SourceString : PANSI_STRING;
    AllocateDestinationString : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAppendAsciizToString(
    DestinationString : PSTRING;
    AppendThisString : LPCSTR
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAppendStringToString(
    DestinationString : PSTRING;
    AppendThisString : PSTRING
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAppendUnicodeStringToString(
    DestinationString : PUNICODE_STRING;
    SourceString : PUNICODE_STRING
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAppendUnicodeToString(
    Destination : PUNICODE_STRING;
    Source : LPCWSTR
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to AreAllAccessesGranted() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAreAllAccessesGranted(
    GrantedAccess : ACCESS_MASK;
    WantedAccess : ACCESS_MASK
  ): BOOLEAN; stdcall; external ntdll;

// This function is very similar to AreAnyAccessesGranted() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAreAnyAccessesGranted(
    GrantedAccess : ACCESS_MASK;
    WantedAccess : ACCESS_MASK
  ): BOOLEAN; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAreBitsClear(
    BitMapHeader : PRTL_BITMAP;
    StartingIndex : ULONG;
    Length : ULONG
  ): BOOLEAN; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlAreBitsSet(
    BitMapHeader : PRTL_BITMAP;
    StartingIndex : ULONG;
    Length : ULONG
  ): BOOLEAN; stdcall; external ntdll;

// Mentioned in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlAssert(
    FailedAssertion : PVOID;
    FileName : PVOID;
    LineNumber : ULONG;
    Message : PCHAR
  ); stdcall; external ntdll;

// The function RtlCaptureContext() from Kernel32.dll is an export
// forwarder to this function. This means you can refer to the
// documentation of RtlCaptureContext()!
// Compatibility: WXP, 2K3
procedure RtlCaptureContext(
    ContextRecord : PCONTEXT
  ); stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCharToInteger(
    Str : PCSZ;
    Base : ULONG;
    Value : PULONG
  ): NTSTATUS; stdcall; external ntdll;

// Somehow internally used.
// Compatibility: W2K, WXP, 2K3
procedure RtlCheckForOrphanedCriticalSections(
    hThread : HANDLE
  ); stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCheckRegistryKey(
    RelativeTo : ULONG;
    Path : PWSTR
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlClearAllBits(
    BitMapHeader : PRTL_BITMAP
  ); stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlClearBits(
    BitMapHeader : PRTL_BITMAP;
    StartingIndex : ULONG;
    NumberToClear : ULONG
  ); stdcall; external ntdll;

// This function is very similar to HeapCompact() from Kernel32.dll. Refer
// to the PSDK for additional information. Usually the same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCompactHeap(
    hHeap : HANDLE;
    dwFlags : ULONG
  ): ULONG; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCompareMemory(
    Source1 : PVOID;
    Source2 : PVOID;
    Length : SIZE_T
  ): SIZE_T; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCompareMemoryUlong(
    Source : PVOID;
    Length : ULONG;
    Value : ULONG
  ): ULONG; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCompareString(
    String1 : PSTRING;
    String2 : PSTRING;
    CaseInsensitive : BOOLEAN
  ): LONG; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCompareUnicodeString(
    String1 : PUNICODE_STRING;
    String2 : PUNICODE_STRING;
    CaseInsensitive : BOOLEAN
  ): LONG; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlConvertLongToLargeInteger(
    SignedInteger : LONG
  ): LARGE_INTEGER; stdcall; external ntdll;

// This function is very similar to ConvertSidToStringSid() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlConvertSidToUnicodeString(
    UnicodeString : PUNICODE_STRING;
    Sid : PSID;
    AllocateDestinationString : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlConvertUlongToLargeInteger(
    UnsignedInteger : ULONG
  ): LARGE_INTEGER; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlCopyLuid(
    Destination : PLUID;
    Source : PLUID
  ); stdcall; external ntdll;

// Compatibility: W2K, WXP
function  RtlCopyRangeList(
    CopyRangeList : PRTL_RANGE_LIST;
    RangeList : PRTL_RANGE_LIST
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCopySecurityDescriptor(
    Source : PSECURITY_DESCRIPTOR;
    var Destination : PSECURITY_DESCRIPTOR
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to CopySid() from Advapi32.dll. Refer to
// the PSDK for additional information. Usually the same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCopySid(
    DestinationLength : ULONG;
    Destination : PSID;
    Source : PSID
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlCopyString(
    DestinationString : PSTRING;
    SourceString : PSTRING
  ); stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlCopyUnicodeString(
    DestinationString : PUNICODE_STRING;
    SourceString : PUNICODE_STRING
  ); stdcall; external ntdll;

// This function is very similar to InitializeAcl() from Advapi32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCreateAcl(
    pAcl : PACL;
    nAclLength : DWORD;
    dwAclRevision : DWORD
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to HeapCreate() from Kernel32.dll. Refer
// to the PSDK for additional information. Usually the same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCreateHeap(
    dwOptions : ULONG;
    Base : PVOID;
    dwMaximumSize : SIZE_T;
    dwInitialSize : SIZE_T;
    UnknownOptional1 : PVOID;
    UnknownOptional2 : PVOID
  ): HANDLE; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCreateProcessParameters(
    ProcessParameters : PPRTL_USER_PROCESS_PARAMETERS;
    ImageFile : PUNICODE_STRING;
    DllPath : PUNICODE_STRING;
    CurrentDirectory : PUNICODE_STRING;
    CommandLine : PUNICODE_STRING;
    CreationFlags : ULONG;
    WindowTitle : PUNICODE_STRING;
    Desktop : PUNICODE_STRING;
    Reserved : PUNICODE_STRING;
    Reserved2 : PUNICODE_STRING
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCreateQueryDebugBuffer(
    Size : ULONG;
    EventPair : BOOLEAN
  ): PDEBUG_BUFFER; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCreateRegistryKey(
    RelativeTo : ULONG;
    Path : PWSTR
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCreateSecurityDescriptor(
    SecurityDescriptor : PSECURITY_DESCRIPTOR;
    Revision : ULONG
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCreateUnicodeString(
    DestinationString : PUNICODE_STRING;
    SourceString : PWSTR
  ): BOOLEAN; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCreateUnicodeStringFromAsciiz(
    DestinationString : PUNICODE_STRING;
    SourceString : PCHAR
  ): BOOLEAN; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCreateUserProcess(
    ImageFileName : PUNICODE_STRING;
    Attributes : ULONG;
    ProcessParameters : PRTL_USER_PROCESS_PARAMETERS;
    ProcessSecurityDescriptor : PSECURITY_DESCRIPTOR;
    ThreadSecurityDescriptor : PSECURITY_DESCRIPTOR;
    ParentProcess : HANDLE;
    InheritHandles : BOOLEAN;
    DebugPort : HANDLE;
    ExceptionPort : HANDLE;
    ProcessInfo : PRTL_PROCESS_INFORMATION
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCreateUserThread(
    hProcess : HANDLE;
    SecurityDescriptor : PSECURITY_DESCRIPTOR;
    CreateSuspended : BOOLEAN;
    StackZeroBits : ULONG;
    StackReserve : ULONG;
    StackCommit : ULONG;
    lpStartAddress : PTHREAD_START_ROUTINE;
    lpParameter : PVOID;
    phThread : PHANDLE;
    ClientId : PCLIENT_ID
  ): NTSTATUS; stdcall; external ntdll;

// #->REVIEW LAST PARAMETER
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlCutoverTimeToSystemTime(
    TargetTimeFields : PTIME_FIELDS;
    Time : PLARGE_INTEGER;
    CurrentTime : PLARGE_INTEGER;
    bUnknown : BOOLEAN
  ): BOOLEAN; stdcall; external ntdll;

// This function is very similar to DeleteAce() from Advapi32.dll. Refer to
// the PSDK for additional information. Usually the same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlDeleteAce(
    pAcl : PACL;
    dwAceIndex : DWORD
  ): NTSTATUS; stdcall; external ntdll;

// The function DeleteCriticalSection() from Kernel32.dll is an export
// forwarder to this function. This means you can refer to the
// documentation of DeleteCriticalSection()!
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlDeleteCriticalSection(
    lpCriticalSection : PRTL_CRITICAL_SECTION
  ); stdcall; external ntdll;

// Compatibility: W2K, WXP
function  RtlDeleteOwnersRanges(
    RangeList : PRTL_RANGE_LIST;
    Owner : PVOID
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP
function  RtlDeleteRange(
    RangeList : PRTL_RANGE_LIST;
    Start : ULONGLONG;
    End_ : ULONGLONG;
    Owner : PVOID
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlDeleteRegistryValue(
    RelativeTo : ULONG;
    Path : LPCWSTR;
    ValueName : LPCWSTR
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlDeNormalizeProcessParams(
    ProcessParameters : PRTL_USER_PROCESS_PARAMETERS
  ): PRTL_USER_PROCESS_PARAMETERS; stdcall; external ntdll;

// This function is very similar to HeapDestroy() from Kernel32.dll. Refer
// to the PSDK for additional information. Usually the same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlDestroyHeap(
    HeapHandle : HANDLE
  ): HANDLE; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlDestroyProcessParameters(
    ProcessParameters : PRTL_USER_PROCESS_PARAMETERS
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlDestroyQueryDebugBuffer(
    DebugBuffer : PDEBUG_BUFFER
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlDetermineDosPathNameType_U(
    wcsPathNameType : PWSTR
  ): ULONG; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  RtlDnsHostNameToComputerName(
    ComputerName : PUNICODE_STRING;
    DnsName : PUNICODE_STRING;
    AllocateComputerNameString : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlDoesFileExists_U(
    FileName : PWSTR
  ): BOOLEAN; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlDosPathNameToNtPathName_U(
    DosName : PWSTR;
    var NtName : UNICODE_STRING;
    DosFilePath : PPWSTR;
    NtFilePath : PUNICODE_STRING
  ): BOOLEAN; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlDosSearchPath_U(
    SearchPath : PWSTR;
    Name : PWSTR;
    Ext : PWSTR;
    cbBuf : ULONG;
    Buffer : PWSTR;
    var Shortname : PWSTR
  ): ULONG; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  RtlDowncaseUnicodeChar(
    Source : WCHAR
  ): WCHAR; stdcall; external ntdll;

// Compatibility: NT4, W2K, WXP, 2K3
function  RtlDowncaseUnicodeString(
    DestinationString : PUNICODE_STRING;
    SourceString : PUNICODE_STRING;
    AllocateDestinationString : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// #->REVIEW First parameter must be 0..3, but details have to be
// investigated!!!
// Compatibility: WXP, 2K3
function  RtlDuplicateUnicodeString(
    AddTerminatingZero : ULONG;
    Source : PUNICODE_STRING;
    Destination : PUNICODE_STRING
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
procedure RtlEnableEarlyCriticalSectionEventCreation(); stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlEnlargedIntegerMultiply(
    Multiplicand : LONG;
    Multiplier : LONG
  ): LARGE_INTEGER; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlEnlargedUnsignedDivide(
    Dividend : ULARGE_INTEGER;
    Divisor : ULONG;
    Remainder : PULONG
  ): ULONG; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlEnlargedUnsignedMultiply(
    Multiplicand : ULONG;
    Multiplier : ULONG
  ): LARGE_INTEGER; stdcall; external ntdll;

// The function EnterCriticalSection() from Kernel32.dll is an export
// forwarder to this function. This means you can refer to the
// documentation of EnterCriticalSection()!
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlEnterCriticalSection(
    lpCriticalSection : PRTL_CRITICAL_SECTION
  ); stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlEqualComputerName(
    String1 : PUNICODE_STRING;
    String2 : PUNICODE_STRING
  ): BOOLEAN; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlEqualDomainName(
    String1 : PUNICODE_STRING;
    String2 : PUNICODE_STRING
  ): BOOLEAN; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlEqualLuid(
    Luid1 : PLUID;
    Luid2 : PLUID
  ): BOOLEAN; stdcall; external ntdll;

// This function is very similar to EqualPrefixSid() from Advapi32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlEqualPrefixSid(
    pSid1 : PSID;
    pSid2 : PSID
  ): BOOLEAN; stdcall; external ntdll;

// This function is very similar to EqualSid() from Advapi32.dll. Refer to
// the PSDK for additional information. Usually the same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlEqualSid(
    pSid1 : PSID;
    pSid2 : PSID
  ): BOOLEAN; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlEqualString(
    String1 : PSTRING;
    String2 : PSTRING;
    CaseInsensitive : BOOLEAN
  ): BOOLEAN; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlEqualUnicodeString(
    String1 : PUNICODE_STRING;
    String2 : PUNICODE_STRING;
    CaseInsensitive : BOOLEAN
  ): BOOLEAN; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlEraseUnicodeString(
    Str : PUNICODE_STRING
  ); stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlExpandEnvironmentStrings_U(
    Environment : PVOID;
    Source : PUNICODE_STRING;
    Destination : PUNICODE_STRING;
    ReturnedLength : PULONG
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlExtendedIntegerMultiply(
    Multiplicand : LARGE_INTEGER;
    Multiplier : LONG
  ): LARGE_INTEGER; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlExtendedLargeIntegerDivide(
    Dividend : LARGE_INTEGER;
    Divisor : ULONG;
    Remainder : PULONG
  ): LARGE_INTEGER; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlExtendedMagicDivide(
    Dividend : LARGE_INTEGER;
    MagicDivisor : LARGE_INTEGER;
    ShiftCount : CCHAR
  ): LARGE_INTEGER; stdcall; external ntdll;

// The function RtlFillMemory() from Kernel32.dll is an export forwarder to
// this function. This means you can refer to the documentation of
// RtlFillMemory()!
// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlFillMemory(
    Destination : PVOID;
    Length : SIZE_T;
    Fill : UCHAR
  ); stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlFillMemoryUlong(
    Destination : PVOID;
    Length : ULONG;
    Fill : ULONG
  ); stdcall; external ntdll;

// Finds characters out of the set contained in CharactersToFind inside
// UnicodeString - description of flags will follow. Only the lower 3 bits
// are valid!!!
// Compatibility: WXP, 2K3
function  RtlFindCharInUnicodeString(
    dwFlags : ULONG;
    UnicodeString : PUNICODE_STRING;
    CharactersToFind : PUNICODE_STRING;
    Positions : PUSHORT
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlFindClearBits(
    BitMapHeader : PRTL_BITMAP;
    NumberToFind : ULONG;
    HintIndex : ULONG
  ): ULONG; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlFindClearBitsAndSet(
    BitMapHeader : PRTL_BITMAP;
    NumberToFind : ULONG;
    HintIndex : ULONG
  ): ULONG; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: W2K, WXP, 2K3
function  RtlFindLastBackwardRunClear(
    BitMapHeader : PRTL_BITMAP;
    FromIndex : ULONG;
    StartingRunIndex : PULONG
  ): ULONG; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: W2K, WXP, 2K3
function  RtlFindLeastSignificantBit(
    Set_ : ULONGLONG
  ): CCHAR; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlFindLongestRunClear(
    BitMapHeader : PRTL_BITMAP;
    StartingIndex : PULONG
  ): ULONG; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  RtlFindMostSignificantBit(
    Set_ : ULONGLONG
  ): CCHAR; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: W2K, WXP, 2K3
function  RtlFindNextForwardRunClear(
    BitMapHeader : PRTL_BITMAP;
    FromIndex : ULONG;
    StartingRunIndex : PULONG
  ): ULONG; stdcall; external ntdll;

// Compatibility: W2K, WXP
function  RtlFindRange(
    RangeList : PRTL_RANGE_LIST;
    Minimum : ULONGLONG;
    Maximum : ULONGLONG;
    Length : ULONG;
    Alignment : ULONG;
    Flags : ULONG;
    AttributeAvailableMask : UCHAR;
    Context : PVOID;
    Callback : PRTL_CONFLICT_RANGE_CALLBACK;
    Start : PULONGLONG
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlFindSetBits(
    BitMapHeader : PRTL_BITMAP;
    NumberToFind : ULONG;
    HintIndex : ULONG
  ): ULONG; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlFindSetBitsAndClear(
    BitMapHeader : PRTL_BITMAP;
    NumberToFind : ULONG;
    HintIndex : ULONG
  ): ULONG; stdcall; external ntdll;

// This function is very similar to FindFirstFreeAce() from Advapi32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlFirstFreeAce(
    pAcl : PACL;
    var pAce : PVOID
  ): BOOLEAN; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlFormatCurrentUserKeyPath(
    CurrentUserKeyPath : PUNICODE_STRING
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlFreeAnsiString(
    AnsiString : PANSI_STRING
  ); stdcall; external ntdll;

// The function HeapFree() from Kernel32.dll is an export forwarder to this
// function. This means you can refer to the documentation of HeapFree()!
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlFreeHeap(
    hHeap : HANDLE;
    dwFlags : ULONG;
    MemoryPointer : PVOID
  ): BOOLEAN; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlFreeOemString(
    OemString : POEM_STRING
  ); stdcall; external ntdll;

// Compatibility: W2K, WXP
procedure RtlFreeRangeList(
    RangeList : PRTL_RANGE_LIST
  ); stdcall; external ntdll;

// This function is very similar to FreeSid() from Advapi32.dll. Refer to
// the PSDK for additional information. Usually the same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlFreeSid(
    pSid : PSID
  ): PVOID; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlFreeUnicodeString(
    UnicodeString : PUNICODE_STRING
  ); stdcall; external ntdll;

// This function is very similar to GetAce() from Advapi32.dll. Refer to
// the PSDK for additional information. Usually the same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlGetAce(
    pAcl : PACL;
    dwAceIndex : DWORD;
    var pAce : PVOID
  ): NTSTATUS; stdcall; external ntdll;

// Mentioned in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlGetCallersAddress(
    CallersAddress : PPVOID;
    CallersCaller : PPVOID
  ); stdcall; external ntdll;

// This function is very similar to GetSecurityDescriptorControl() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlGetControlSecurityDescriptor(
    pSecurityDescriptor : PSECURITY_DESCRIPTOR;
    var Control : SECURITY_DESCRIPTOR_CONTROL;
    var dwRevision : DWORD
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlGetCurrentDirectory_U(
    MaximumLength : ULONG;
    Buffer : PWSTR
  ): ULONG; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  RtlGetCurrentPeb(): PPEB; stdcall; external ntdll;

// This function is very similar to GetSecurityDescriptorDacl() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlGetDaclSecurityDescriptor(
    pSecurityDescriptor : PSECURITY_DESCRIPTOR;
    var bDaclPresent : BOOLEAN;
    var Dacl : PACL;
    var bDaclDefaulted : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP
function  RtlGetFirstRange(
    RangeList : PRTL_RANGE_LIST;
    Iterator : PRTL_RANGE_LIST_ITERATOR;
    var Range : PRTL_RANGE
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlGetFullPathName_U(
    DosName : PWSTR;
    Size : ULONG;
    Buf : PWSTR;
    var Shortname : PWSTR
  ): ULONG; stdcall; external ntdll;

// This function is very similar to GetSecurityDescriptorGroup() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlGetGroupSecurityDescriptor(
    pSecurityDescriptor : PSECURITY_DESCRIPTOR;
    var pGroup : PSID;
    var bGroupDefaulted : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  RtlGetLastNtStatus(): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlGetLongestNtPathLength(): ULONG; stdcall; external ntdll;

// Compatibility: W2K, WXP
function  RtlGetNextRange(
    Iterator : PRTL_RANGE_LIST_ITERATOR;
    var Range : PRTL_RANGE;
    MoveForwards : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlGetNtGlobalFlags(): ULONG; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlGetNtProductType(
    var ProductType : ULONG
  ): BOOLEAN; stdcall; external ntdll;

// #->REVIEW LAST PARAMETER
// Compatibility: WXP, 2K3
procedure RtlGetNtVersionNumbers(
    var dwMajorVersion : ULONG;
    var dwMinorVersion : ULONG;
    UnknownCanBeNull : PDWORD
  ); stdcall; external ntdll;

// This function is very similar to GetSecurityDescriptorOwner() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlGetOwnerSecurityDescriptor(
    pSecurityDescriptor : PSECURITY_DESCRIPTOR;
    var pOwner : PSID;
    var OwnerDefaulted : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to GetProcessHeaps() from Kernel32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlGetProcessHeaps(
    ArraySize : ULONG;
    HeapArray : PHANDLE
  ): ULONG; stdcall; external ntdll;

// This function is very similar to GetSecurityDescriptorSacl() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlGetSaclSecurityDescriptor(
    pSecurityDescriptor : PSECURITY_DESCRIPTOR;
    var bSaclPresent : BOOLEAN;
    var Sacl : PACL;
    var bSaclDefaulted : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to GetVersionEx() from Kernel32.dll. Refer
// to the PSDK for additional information. Usually the same flags apply.
// Documented in the DDK.
// Compatibility: W2K, WXP, 2K3
function  RtlGetVersion(
    lpVersionInformation : PRTL_OSVERSIONINFOW
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: W2K, WXP, 2K3
function  RtlGUIDFromString(
    GuidString : PUNICODE_STRING;
    Guid : LPGUID
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to GetSidIdentifierAuthority() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlIdentifierAuthoritySid(
    Sid : PSID
  ): PSID_IDENTIFIER_AUTHORITY; stdcall; external ntdll;

// This function is very similar to ImageDirectoryEntryToData() from
// Dbghelp.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlImageDirectoryEntryToData(
    ImageBase : HMODULE;
    MappedAsImage : BOOLEAN;
    DirectoryEntry : USHORT;
    Size : PULONG
  ): PVOID; stdcall; external ntdll;

// This function is very similar to ImageNtHeader() from Dbghelp.dll. Refer
// to the PSDK for additional information. Usually the same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlImageNtHeader(
    ImageBase : HMODULE
  ): PIMAGE_NT_HEADERS; stdcall; external ntdll;

// This function is very similar to ImageNtHeader() from Dbghelp.dll. Refer
// to the PSDK for additional information. Usually the same flags apply.
// With dwFlags equal 1 it shows the same behavior as RtlImageNtHeader()
// Compatibility: 2K3
function  RtlImageNtHeaderEx(
    dwFlags : DWORD;
    ImageBase : HMODULE
  ): PIMAGE_NT_HEADERS; stdcall; external ntdll;

// This function is very similar to ImageRvaToSection() from Dbghelp.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT4, W2K, WXP, 2K3
function  RtlImageRvaToSection(
    NtHeaders : PIMAGE_NT_HEADERS;
    ImageBase : HMODULE;
    Rva : ULONG
  ): PIMAGE_SECTION_HEADER; stdcall; external ntdll;

// This function is very similar to ImageRvaToVa() from Dbghelp.dll. Refer
// to the PSDK for additional information. Usually the same flags apply.
// Compatibility: NT4, W2K, WXP, 2K3
function  RtlImageRvaToVa(
    NtHeaders : PIMAGE_NT_HEADERS;
    ImageBase : HMODULE;
    Rva : ULONG;
    var LastRvaSection : PIMAGE_SECTION_HEADER
  ): PVOID; stdcall; external ntdll;

// This function is very similar to ImpersonateSelf() from Advapi32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlImpersonateSelf(
    ImpersonationLevel : SECURITY_IMPERSONATION_LEVEL
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlInitAnsiString(
    DestinationString : PANSI_STRING;
    SourceString : PCSZ
  ); stdcall; external ntdll;

// Compatibility: 2K3
function  RtlInitAnsiStringEx(
    DestinationString : PANSI_STRING;
    SourceString : PCSZ
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlInitializeBitMap(
    BitMapHeader : PRTL_BITMAP;
    BitMapBuffer : PULONG;
    SizeOfBitMap : ULONG
  ); stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlInitializeCriticalSection(
    lpCriticalSection : PRTL_CRITICAL_SECTION
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT4, W2K, WXP, 2K3
function  RtlInitializeCriticalSectionAndSpinCount(
    lpCriticalSection : PRTL_CRITICAL_SECTION;
    dwSpinCount : ULONG
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP
procedure RtlInitializeRangeList(
    RangeList : PRTL_RANGE_LIST
  ); stdcall; external ntdll;

// This function is very similar to InitializeSid() from Advapi32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlInitializeSid(
    pSid : PSID;
    pIdentifierAuthority : PSID_IDENTIFIER_AUTHORITY;
    nSubAuthorityCount : UCHAR
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: WXP, 2K3
procedure RtlInitializeSListHead(
    ListHead : PSLIST_HEADER
  ); stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlInitString(
    DestinationString : PSTRING;
    SourceString : PCSZ
  ); stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlInitUnicodeString(
    DestinationString : PUNICODE_STRING;
    SourceString : LPCWSTR
  ); stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  RtlInitUnicodeStringEx(
    DestinationString : PUNICODE_STRING;
    SourceString : LPCWSTR
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: W2K, WXP, 2K3
function  RtlInt64ToUnicodeString(
    Value : ULONGLONG;
    Base : ULONG;
    Str : PUNICODE_STRING
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlIntegerToChar(
    Value : ULONG;
    Base : ULONG;
    Length : ULONG;
    Str : PCHAR
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlIntegerToUnicodeString(
    Value : ULONG;
    Base : ULONG;
    Str : PUNICODE_STRING
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  RtlInterlockedFlushSList(
    ListHead : PSLIST_HEADER
  ): PSLIST_ENTRY; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  RtlInterlockedPopEntrySList(
    ListHead : PSLIST_HEADER
  ): PSLIST_ENTRY; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  RtlInterlockedPushEntrySList(
    ListHead : PSLIST_HEADER;
    ListEntry : PSLIST_ENTRY
  ): PSLIST_ENTRY; stdcall; external ntdll;

// Compatibility: W2K, WXP
function  RtlInvertRangeList(
    InvertedRangeList : PRTL_RANGE_LIST;
    RangeList : PRTL_RANGE_LIST
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  RtlIpv4AddressToStringA(
    IP : PULONG;
    Buffer : LPSTR
  ): LPSTR; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  RtlIpv4AddressToStringW(
    IP : PULONG;
    Buffer : LPWSTR
  ): LPWSTR; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlIsDosDeviceName_U(
    TestString : LPCWSTR
  ): ULONG; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlIsNameLegalDOS8Dot3(
    Name : PUNICODE_STRING;
    OemName : POEM_STRING;
    NameContainsSpaces : PBOOLEAN
  ): BOOLEAN; stdcall; external ntdll;

// Compatibility: W2K, WXP
function  RtlIsRangeAvailable(
    RangeList : PRTL_RANGE_LIST;
    Start : ULONGLONG;
    End_ : ULONGLONG;
    Flags : ULONG;
    AttributeAvailableMask : UCHAR;
    Context : PVOID;
    Callback : PRTL_CONFLICT_RANGE_CALLBACK;
    Available : PBOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to IsTextUnicode() from Advapi32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlIsTextUnicode(
    lpBuffer : PVOID;
    cb : Integer;
    lpi : LPINT
  ): BOOLEAN; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlLargeIntegerAdd(
    Addend1 : LARGE_INTEGER;
    Addend2 : LARGE_INTEGER
  ): LARGE_INTEGER; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlLargeIntegerArithmeticShift(
    LargeInteger : LARGE_INTEGER;
    ShiftCount : CCHAR
  ): LARGE_INTEGER; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlLargeIntegerDivide(
    Dividend : LARGE_INTEGER;
    Divisor : LARGE_INTEGER;
    Remainder : PLARGE_INTEGER
  ): LARGE_INTEGER; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlLargeIntegerNegate(
    NegateThis : LARGE_INTEGER
  ): LARGE_INTEGER; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlLargeIntegerShiftLeft(
    LargeInteger : LARGE_INTEGER;
    ShiftCount : CCHAR
  ): LARGE_INTEGER; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlLargeIntegerShiftRight(
    LargeInteger : LARGE_INTEGER;
    ShiftCount : CCHAR
  ): LARGE_INTEGER; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlLargeIntegerSubtract(
    Number : LARGE_INTEGER;
    Subtrahend : LARGE_INTEGER
  ): LARGE_INTEGER; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlLargeIntegerToChar(
    Value : PLARGE_INTEGER;
    Base : ULONG;
    BufferLength : ULONG;
    Buffer : PCHAR
  ): NTSTATUS; stdcall; external ntdll;

// The function LeaveCriticalSection() from Kernel32.dll is an export
// forwarder to this function. This means you can refer to the
// documentation of LeaveCriticalSection()!
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlLeaveCriticalSection(
    lpCriticalSection : PRTL_CRITICAL_SECTION
  ); stdcall; external ntdll;

// This function is very similar to GetSidLengthRequired() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlLengthRequiredSid(
    nSubAuthorityCount : ULONG
  ): ULONG; stdcall; external ntdll;

// This function is very similar to GetSecurityDescriptorLength() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlLengthSecurityDescriptor(
    SecurityDescriptor : PSECURITY_DESCRIPTOR
  ): ULONG; stdcall; external ntdll;

// This function is very similar to GetLengthSid() from Advapi32.dll. Refer
// to the PSDK for additional information. Usually the same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlLengthSid(
    pSid : PSID
  ): ULONG; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlLocalTimeToSystemTime(
    LocalTime : PLARGE_INTEGER;
    SystemTime : PLARGE_INTEGER
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to HeapLock() from Kernel32.dll. Refer to
// the PSDK for additional information. Usually the same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlLockHeap(
    hHeap : PVOID
  ): BOOLEAN; stdcall; external ntdll;

// This function is very similar to MakeSelfRelativeSD() from Advapi32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlMakeSelfRelativeSD(
    pAbsoluteSD : PSECURITY_DESCRIPTOR;
    pSelfRelativeSD : PSECURITY_DESCRIPTOR;
    lpdwBufferLength : LPDWORD
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to MapGenericMask() from Advapi32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlMapGenericMask(
    AccessMask : PACCESS_MASK;
    GenericMapping : PGENERIC_MAPPING
  ); stdcall; external ntdll;

// Maps an error from the security subsystem to a native error status.
// Compatibility: WXP, 2K3
function  RtlMapSecurityErrorToNtStatus(
    SecurityError : DWORD
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP
function  RtlMergeRangeLists(
    MergedRangeList : PRTL_RANGE_LIST;
    RangeList1 : PRTL_RANGE_LIST;
    RangeList2 : PRTL_RANGE_LIST;
    Flags : ULONG
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlMoveMemory(
    Destination : PVOID;
    Source : PVOID;
    Length : SIZE_T
  ); stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlNormalizeProcessParams(
    ProcessParameters : PRTL_USER_PROCESS_PARAMETERS
  ): PRTL_USER_PROCESS_PARAMETERS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlNtStatusToDosError(
    Status : NTSTATUS
  ): ULONG; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  RtlNtStatusToDosErrorNoTeb(
    Status : NTSTATUS
  ): ULONG; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlNumberOfClearBits(
    BitMapHeader : PRTL_BITMAP
  ): ULONG; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlNumberOfSetBits(
    BitMapHeader : PRTL_BITMAP
  ): ULONG; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlOemStringToUnicodeSize(
    AnsiString : POEM_STRING
  ): ULONG; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlOemStringToUnicodeString(
    DestinationString : PUNICODE_STRING;
    SourceString : POEM_STRING;
    AllocateDestinationString : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlOemToUnicodeN(
    UnicodeString : PWSTR;
    UnicodeSize : ULONG;
    var ResultSize : ULONG;
    OemString : PCHAR;
    OemSize : ULONG
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlOpenCurrentUser(
    samDesired : ACCESS_MASK;
    phkResult : PHKEY
  ): NTSTATUS; stdcall; external ntdll;

// Either raises an exception of type STATUS_RESOURCE_NOT_OWNED or returns
// a BOOLEAN value.
// Should perhaps not be called explicitly.
// Compatibility: WXP, 2K3
function  RtlpNotOwnerCriticalSection(
    lpCriticalSection : PRTL_CRITICAL_SECTION
  ): BOOLEAN; stdcall; external ntdll;

// This is a private wrapper for NtCreateKey().
// However, 2 of the parameters are not being used!
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlpNtCreateKey(
    KeyHandle : PHANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    Unused1 : ULONG;
    Unused2 : ULONG;
    Disposition : PULONG
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlpNtEnumerateSubKey(
    KeyHandle : HANDLE;
    SubKeyName : PUNICODE_STRING;
    Index : ULONG;
    Unused1 : ULONG
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to NtCreateKey() from Ntdll.dll. Usually
// the same or similar flags apply.
// This is exactly the same as NtDeleteKey() by now!
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlpNtMakeTemporaryKey(
    KeyHandle : HANDLE
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlpNtOpenKey(
    KeyHandle : HANDLE;
    DesiredAccess : ACCESS_MASK;
    ObjectAttributes : POBJECT_ATTRIBUTES;
    Unused : ULONG
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlpNtQueryValueKey(
    KeyHandle : HANDLE;
    Type_ : PULONG;
    Data : PVOID;
    DataSize : PULONG;
    Unused : ULONG
  ): NTSTATUS; stdcall; external ntdll;

// This is a private wrapper for NtSetValueKey().
// The parameters of TitleIndex and ValueName are not being passed, that is
// empty.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlpNtSetValueKey(
    KeyHandle : HANDLE;
    Type_ : ULONG;
    Data : PVOID;
    DataSize : ULONG
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlPrefixString(
    String1 : PANSI_STRING;
    String2 : PANSI_STRING;
    CaseInsensitive : BOOLEAN
  ): BOOLEAN; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlPrefixUnicodeString(
    String1 : PUNICODE_STRING;
    String2 : PUNICODE_STRING;
    CaseInsensitive : BOOLEAN
  ): BOOLEAN; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  RtlQueryDepthSList(
    ListHead : PSLIST_HEADER
  ): USHORT; stdcall; external ntdll;

// VarValue has to have a buffer assigned big enough to hold the value.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlQueryEnvironmentVariable_U(
    Environment : PVOID;
    VarName : PUNICODE_STRING;
    VarValue : PUNICODE_STRING
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to GetAclInformation() from Advapi32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlQueryInformationAcl(
    pAcl : PACL;
    pAclInformation : PVOID;
    nAclInformationLength : DWORD;
    dwAclInformationClass : ACL_INFORMATION_CLASS
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlQueryProcessDebugInformation(
    ProcessId : ULONG;
    DebugInfoClassMask : ULONG;
    DebugBuffer : PDEBUG_BUFFER
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlQueryRegistryValues(
    RelativeTo : ULONG;
    Path : LPCWSTR;
    QueryTable : PRTL_QUERY_REGISTRY_TABLE;
    Context : PVOID;
    Environment : PVOID
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlRaiseStatus(
    Status : NTSTATUS
  ); stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlRandom(
    Seed : PULONG
  ): ULONG; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  RtlRandomEx(
    Seed : PULONG
  ): ULONG; stdcall; external ntdll;

// The function HeapReAlloc() from Kernel32.dll is an export forwarder to
// this function. This means you can refer to the documentation of
// HeapReAlloc()!
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlReAllocateHeap(
    hHeap : HANDLE;
    dwFlags : ULONG;
    lpMem : PVOID;
    dwBytes : SIZE_T
  ): PVOID; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlReleasePebLock(); stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  RtlRemoveVectoredExceptionHandler(
    VectoredHandlerHandle : PVOID
  ): ULONG; stdcall; external ntdll;

// Compatibility: WXP, 2K3
procedure RtlRestoreLastWin32Error(
    dwErrCode : DWORD
  ); stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlRunDecodeUnicodeString(
    CodeSeed : UCHAR;
    StringToDecode : PUNICODE_STRING
  ); stdcall; external ntdll;

// If CodeSeed == 0 it will be assigned a value by the function. Use this
// very value in a call to RtlRunDecodeUnicodeString()! To decode the
// string afterwards.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlRunEncodeUnicodeString(
    var CodeSeed : UCHAR;
    StringToEncode : PUNICODE_STRING
  ); stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlSecondsSince1970ToTime(
    SecondsSince1970 : ULONG;
    Time : PLARGE_INTEGER
  ); stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlSecondsSince1980ToTime(
    SecondsSince1980 : ULONG;
    Time : PLARGE_INTEGER
  ); stdcall; external ntdll;

// This function is very similar to MakeAbsoluteSD() from Advapi32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlSelfRelativeToAbsoluteSD(
    pSelfRelativeSD : PSECURITY_DESCRIPTOR;
    pAbsoluteSD : PSECURITY_DESCRIPTOR;
    lpdwAbsoluteSDSize : LPDWORD;
    pDacl : PACL;
    lpdwDaclSize : LPDWORD;
    pSacl : PACL;
    lpdwSaclSize : LPDWORD;
    pOwner : PSID;
    lpdwOwnerSize : LPDWORD;
    pPrimaryGroup : PSID;
    lpdwPrimaryGroupSize : LPDWORD
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlSetAllBits(
    BitMapHeader : PRTL_BITMAP
  ); stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlSetBits(
    BitMapHeader : PRTL_BITMAP;
    StartingIndex : ULONG;
    NumberToSet : ULONG
  ); stdcall; external ntdll;

// This function is very similar to SetSecurityDescriptorControl() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: W2K, WXP, 2K3
function  RtlSetControlSecurityDescriptor(
    pSecurityDescriptor : PSECURITY_DESCRIPTOR;
    ControlBitsOfInterest : SECURITY_DESCRIPTOR_CONTROL;
    ControlBitsToSet : SECURITY_DESCRIPTOR_CONTROL
  ): NTSTATUS; stdcall; external ntdll;

// The function SetCriticalSectionSpinCount() from Kernel32.dll is an
// export forwarder to this function. This means you can refer to the
// documentation of SetCriticalSectionSpinCount()!
// Compatibility: NT4, W2K, WXP, 2K3
function  RtlSetCriticalSectionSpinCount(
    lpCriticalSection : PRTL_CRITICAL_SECTION;
    dwSpinCount : ULONG
  ): DWORD; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlSetCurrentDirectory_U(
    NewCurrentDirectory : PUNICODE_STRING
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlSetDaclSecurityDescriptor(
    SecurityDescriptor : PSECURITY_DESCRIPTOR;
    DaclPresent : BOOLEAN;
    Dacl : PACL;
    DaclDefaulted : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlSetGroupSecurityDescriptor(
    pSecurityDescriptor : PSECURITY_DESCRIPTOR;
    pGroup : PSID;
    bGroupDefaulted : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to SetAclInformation() from Advapi32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlSetInformationAcl(
    pAcl : PACL;
    pAclInformation : PVOID;
    nInformationLength : DWORD;
    dwAclInformationClass : ACL_INFORMATION_CLASS
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  RtlSetLastWin32ErrorAndNtStatusFromNtStatus(
    Status : NTSTATUS
  ): ULONG; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlSetOwnerSecurityDescriptor(
    pSecurityDescriptor : PSECURITY_DESCRIPTOR;
    pOwner : PSID;
    bOwnerDefaulted : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  RtlSetProcessIsCritical(
    bIsCritical : BOOLEAN;
    pbOldIsCriticalValue : PBOOLEAN;
    bUnknownCanBeFalse : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to SetSecurityDescriptorSacl() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlSetSaclSecurityDescriptor(
    pSecurityDescriptor : PSECURITY_DESCRIPTOR;
    bSaclPresent : BOOLEAN;
    pSacl : PACL;
    SaclDefaulted : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  RtlSetThreadIsCritical(
    bIsCritical : BOOLEAN;
    pbOldIsCriticalValue : PBOOLEAN;
    bUnknownCanBeFalse : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// The function HeapSize() from Kernel32.dll is an export forwarder to this
// function. This means you can refer to the documentation of HeapSize()!
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlSizeHeap(
    hHeap : HANDLE;
    dwFlags : ULONG;
    lpMem : PVOID
  ): SIZE_T; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: W2K, WXP, 2K3
function  RtlStringFromGUID(
    Guid : REFGUID;
    GuidString : PUNICODE_STRING
  ): NTSTATUS; stdcall; external ntdll;

// This function is very similar to GetSidSubAuthorityCount() from
// Advapi32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlSubAuthorityCountSid(
    pSid : PSID
  ): PUCHAR; stdcall; external ntdll;

// This function is very similar to GetSidSubAuthority() from Advapi32.dll.
// Refer to the PSDK for additional information. Usually the same flags
// apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlSubAuthoritySid(
    pSid : PSID;
    nSubAuthority : DWORD
  ): PDWORD; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlSystemTimeToLocalTime(
    SystemTime : PLARGE_INTEGER;
    LocalTime : PLARGE_INTEGER
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlTimeFieldsToTime(
    TimeFields : PTIME_FIELDS;
    Time : PLARGE_INTEGER
  ): BOOLEAN; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlTimeToElapsedTimeFields(
    Time : PLARGE_INTEGER;
    TimeFields : PTIME_FIELDS
  ); stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlTimeToSecondsSince1970(
    Time : PLARGE_INTEGER;
    ElapsedSeconds : PULONG
  ): BOOLEAN; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlTimeToSecondsSince1980(
    Time : PLARGE_INTEGER;
    ElapsedSeconds : PULONG
  ): BOOLEAN; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlTimeToTimeFields(
    Time : PLARGE_INTEGER;
    TimeFields : PTIME_FIELDS
  ); stdcall; external ntdll;

// The function TryEnterCriticalSection() from Kernel32.dll is an export
// forwarder to this function. This means you can refer to the
// documentation of TryEnterCriticalSection()!
// Compatibility: NT4, W2K, WXP, 2K3
function  RtlTryEnterCriticalSection(
    lpCriticalSection : PRTL_CRITICAL_SECTION
  ): BOOL; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlUnicodeStringToAnsiSize(
    UnicodeString : PUNICODE_STRING
  ): ULONG; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlUnicodeStringToAnsiString(
    DestinationString : PANSI_STRING;
    SourceString : PUNICODE_STRING;
    AllocateDestinationString : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlUnicodeStringToCountedOemString(
    DestinationString : POEM_STRING;
    SourceString : PUNICODE_STRING;
    AllocateDestinationString : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlUnicodeStringToInteger(
    Str : PUNICODE_STRING;
    Base : ULONG;
    Value : PULONG
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlUnicodeStringToOemSize(
    UnicodeString : PUNICODE_STRING
  ): ULONG; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlUnicodeStringToOemString(
    DestinationString : POEM_STRING;
    SourceString : PCUNICODE_STRING;
    AllocateDestinationString : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlUnicodeToMultiByteSize(
    BytesInMultiByteString : PULONG;
    UnicodeString : PWSTR;
    BytesInUnicodeString : ULONG
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlUniform(
    Seed : PULONG
  ): ULONG; stdcall; external ntdll;

// The function RtlUnwind() from Kernel32.dll is an export forwarder to
// this function. This means you can refer to the documentation of
// RtlUnwind()!
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlUnwind(
    TargetFrame : PVOID;
    TargetIp : PVOID;
    ExceptionRecord : PEXCEPTION_RECORD;
    ReturnValue : PVOID
  ); stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlUpcaseUnicodeChar(
    SourceCharacter : WCHAR
  ): WCHAR; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlUpcaseUnicodeString(
    DestinationString : PUNICODE_STRING;
    SourceString : PUNICODE_STRING;
    AllocateDestinationString : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlUpcaseUnicodeStringToAnsiString(
    DestinationString : PSTRING;
    SourceString : PUNICODE_STRING;
    AllocateDestinationString : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlUpcaseUnicodeStringToCountedOemString(
    DestinationString : PSTRING;
    SourceString : PUNICODE_STRING;
    AllocateDestinationString : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlUpcaseUnicodeStringToOemString(
    DestinationString : PSTRING;
    SourceString : PUNICODE_STRING;
    AllocateDestinationString : BOOLEAN
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlUpcaseUnicodeToMultiByteN(
    MbString : PCHAR;
    MbSize : ULONG;
    var ResultSize : ULONG;
    UnicodeString : PWSTR;
    UnicodeSize : ULONG
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlUpcaseUnicodeToOemN(
    OemString : PCHAR;
    OemSize : ULONG;
    var ResultSize : ULONG;
    UnicodeString : PWSTR;
    UnicodeSize : ULONG
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlUpperChar(
    Character : CHAR
  ): CHAR; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlUpperString(
    DestinationString : PSTRING;
    SourceString : PSTRING
  ); stdcall; external ntdll;

// #->REVIEW NUMBER OF PARAMETERS
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlValidAcl(
    Acl : PACL
  ): BOOLEAN; stdcall; external ntdll;

// This function is very similar to HeapValidate() from Kernel32.dll. Refer
// to the PSDK for additional information. Usually the same flags apply.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlValidateHeap(
    hHeap : HANDLE;
    dwFlags : ULONG;
    lpMem : LPCVOID
  ): BOOL; stdcall; external ntdll;

// Compatibility: WXP, 2K3
function  RtlValidateUnicodeString(
    dwMustBeNull : ULONG;
    ValidateThis : PUNICODE_STRING
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: W2K, WXP, 2K3
function  RtlValidRelativeSecurityDescriptor(
    SecurityDescriptorInput : PSECURITY_DESCRIPTOR;
    SecurityDescriptorLength : ULONG;
    RequiredInformation : SECURITY_INFORMATION
  ): BOOLEAN; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlValidSecurityDescriptor(
    SecurityDescriptor : PSECURITY_DESCRIPTOR
  ): BOOLEAN; stdcall; external ntdll;

// #->REVIEW NUMBER OF PARAMETERS; XREF: see IsValidSid()!
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlValidSid(
    pSid : PSID
  ): BOOLEAN; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: W2K, WXP, 2K3
function  RtlVerifyVersionInfo(
    VersionInfo : PRTL_OSVERSIONINFOEXW;
    TypeMask : ULONG;
    ConditionMask : ULONGLONG
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
function  RtlVolumeDeviceToDosName(
    VolumeDeviceObject : PVOID;
    DosName : PUNICODE_STRING
  ): NTSTATUS; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlWriteRegistryValue(
    RelativeTo : ULONG;
    Path : LPCWSTR;
    ValueName : LPCWSTR;
    ValueType : ULONG;
    ValueData : PVOID;
    ValueLength : ULONG
  ): NTSTATUS; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlxAnsiStringToUnicodeSize(
    AnsiString : PANSI_STRING
  ): ULONG; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlxOemStringToUnicodeSize(
    AnsiString : POEM_STRING
  ): ULONG; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlxUnicodeStringToAnsiSize(
    UnicodeString : PUNICODE_STRING
  ): ULONG; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlxUnicodeStringToOemSize(
    UnicodeString : PUNICODE_STRING
  ): ULONG; stdcall; external ntdll;

// Compatibility: NT3, NT4, W2K, WXP, 2K3
function  RtlZeroHeap(
    hHeap : HANDLE;
    dwFlags : ULONG
  ): BOOLEAN; stdcall; external ntdll;

// Documented in the DDK.
// Compatibility: NT3, NT4, W2K, WXP, 2K3
procedure RtlZeroMemory(
    Destination : PVOID;
    Length : SIZE_T
  ); stdcall; external ntdll;

// This function is very similar to VerSetConditionMask() from
// Kernel32.dll. Refer to the PSDK for additional information. Usually the
// same flags apply.
// Compatibility: W2K, WXP, 2K3
function  VerSetConditionMask(
    ConditionMask : ULONGLONG;
    dwTypeMask : DWORD;
    Condition : BYTE
  ): ULONGLONG; stdcall; external ntdll;

//// 810 automatically created prototype entries.
//// END  : Function prototypes

implementation

// This function is actually declared as a macro defined as memcpy()

procedure RtlCopyMemory(Destination: PVOID; Source: PVOID; Length: SIZE_T); stdcall;
begin
  Move(Source^, Destination^, Length);
end;

// Own function to retrieve the process's heap handle

function NtpGetProcessHeap(): HANDLE;
asm
  mov   EAX, FS:[018h]            // EAX now holds the TEB address
  mov   EAX, [EAX+030h]           // TEB+$30 holds the PEB address
  mov   EAX, DWORD PTR [EAX+018h] // PEB+$30 holds the ProcessHeap's handle
end;

// Own function to retrieve the thread environment block (TEB) pointer

function NtpCurrentTeb(): PTEB;
asm
  mov   EAX, FS:[018h]
end;

// Own function to retrieve the process environment block (PEB) pointer

function RtlpGetCurrentPeb(): PPEB;
asm
  mov   EAX, FS:[018h]
  mov   EAX, [EAX+030h]
end;

(* Own function to swap bytes in 16bit values

   The RtlUshortByteSwap routine converts a USHORT from
   little-endian to big-endian, and vice versa. *)

function RtlUshortByteSwap(Source: USHORT): USHORT;
asm
  rol   AX, 08h
end;

(* Own function to swap bytes in 32bit values

   The RtlUlongByteSwap routine converts a ULONG from little-endian to
   big-endian, and vice versa. *)

function RtlUlongByteSwap(Source: ULONG): ULONG;
asm
  // This is not written as mnemonics to be compatible with D4!
  db    0Fh, 0C8h       // "bswap EAX" can only be executed on 486+!!!
(*
// Does the same but perhaps slower ...
                        // Source = $11223344
  rol   AX,  08h        // Source = $11224433
  rol   EAX, 0Fh        // Source = $44331122
  rol   AX,  08h        // Source = $44332211
*)
end;

(* Own function to swap bytes in 64bit values

   The RtlUlonglongByteSwap routine converts a ULONGLONG from
   little-endian to big-endian, and vice versa. *)

function RtlUlonglongByteSwap(Source: ULONGLONG): ULONGLONG;
asm
  mov   EDX, [ESP+08h]  // Get the low part of the ULONGLONG into EDX
  mov   EAX, [ESP+0Ch]  // Get the high part of the ULONGLONG into EAX
  // This is not written as mnemonics to be compatible with D4!
  db    0Fh, 0C8h       // "bswap EAX" can only be executed on 486+!!!
  db    0Fh, 0CAh       // "bswap EDX" can only be executed on 486+!!!
  // High part returns in EDX, low part in EAX
end;

// Resembles the RtlValidateUnicodeString() function available from Windows XP
// on exactly as it is on this OS version, except for the calling convention.

function RtlpValidateUnicodeString(dwMustBeNull: DWORD; UnicodeString: PUNICODE_STRING): NTSTATUS;
begin
  result := STATUS_INVALID_PARAMETER;
  if (dwMustBeNull = 0) then
  begin
    result := STATUS_SUCCESS;
    if (Assigned(UnicodeString)) then
    begin
      result := STATUS_INVALID_PARAMETER;
      if ((UnicodeString^.Length mod 2 = 0) and (UnicodeString^.MaximumLength mod 2 = 0) and (UnicodeString^.Length <= UnicodeString^.MaximumLength)) then
        if ((UnicodeString^.Length > 0) and (UnicodeString^.MaximumLength > 0)) then
          if (Assigned(UnicodeString^.Buffer)) then
            result := STATUS_SUCCESS;
    end;
  end;
end;

// Resembles the RtlValidateUnicodeString() function available from Windows XP
// on, but does not require the first parameter which anyway must be zero.

function RtlpValidateUnicodeString2(UnicodeString: PUNICODE_STRING): NTSTATUS;
begin
  result := STATUS_SUCCESS;
  if (Assigned(UnicodeString)) then
  begin
    result := STATUS_INVALID_PARAMETER;
    if ((UnicodeString^.Length mod 2 = 0) and (UnicodeString^.MaximumLength mod 2 = 0) and (UnicodeString^.Length <= UnicodeString^.MaximumLength)) then
      if ((UnicodeString^.Length > 0) and (UnicodeString^.MaximumLength > 0)) then
        if (Assigned(UnicodeString^.Buffer)) then
          result := STATUS_SUCCESS;
  end;
end;

(*
Function forwarders which are not implemented by this unit
because they are available only on the 64bit editions of
Windows XP and Windows 2003 Server.

[KERNEL32.dll]RtlCaptureContext -> NTDLL.RtlCaptureContext
[KERNEL32.dll]RtlCaptureStackBackTrace -> NTDLL.RtlCaptureStackBackTrace

Usually the Kernel32 functions are documented in the Platform SDK, so knowing
of these function forwarders gives you the chance to find out the prototype of
the respective Native API to which the call is forwarded.

The following usermode Native APIs are not included in this unit:
-----------------------------------------------------------------
CsrAllocateCaptureBuffer [NT3, NT4, W2K, WXP, 2K3]
CsrAllocateMessagePointer [NT3, NT4, W2K, WXP, 2K3]
CsrCaptureMessageBuffer [NT3, NT4, W2K, WXP, 2K3]
CsrCaptureMessageMultiUnicodeStringsInPlace [WXP, 2K3]
CsrCaptureMessageString [NT3, NT4, W2K, WXP, 2K3]
CsrCaptureTimeout [NT3, NT4, W2K, WXP, 2K3]
CsrClientCallServer [NT3, NT4, W2K, WXP, 2K3]
CsrClientConnectToServer [NT3, NT4, W2K, WXP, 2K3]
CsrFreeCaptureBuffer [NT3, NT4, W2K, WXP, 2K3]
CsrIdentifyAlertableThread [NT3, NT4, W2K, WXP, 2K3]
CsrNewThread [NT3, NT4, W2K, WXP, 2K3]
CsrProbeForRead [NT3, NT4, W2K, WXP, 2K3]
CsrProbeForWrite [NT3, NT4, W2K, WXP, 2K3]
CsrSetPriorityClass [NT3, NT4, W2K, WXP, 2K3]
DbgPrintEx [WXP, 2K3]
DbgPrintReturnControlC [W2K, WXP, 2K3]
DbgPrompt [NT3, NT4, W2K, WXP, 2K3]
DbgSsHandleKmApiMsg [NT3, NT4, W2K]
DbgSsInitialize [NT3, NT4, W2K]
DbgUiConnectToDbg [NT3, NT4, W2K, WXP, 2K3]
DbgUiContinue [NT3, NT4, W2K, WXP, 2K3]
DbgUiConvertStateChangeStructure [WXP, 2K3]
DbgUiDebugActiveProcess [WXP, 2K3]
DbgUiGetThreadDebugObject [WXP, 2K3]
DbgUiIssueRemoteBreakin [WXP, 2K3]
DbgUiRemoteBreakin [WXP, 2K3]
DbgUiSetThreadDebugObject [WXP, 2K3]
DbgUiStopDebugging [WXP, 2K3]
DbgUiWaitStateChange [NT3, NT4, W2K, WXP, 2K3]
DbgUserBreakPoint [NT3, NT4, W2K, WXP, 2K3]
EtwControlTraceA [2K3]
EtwControlTraceW [2K3]
EtwCreateTraceInstanceId [2K3]
EtwEnableTrace [2K3]
EtwEnumerateTraceGuids [2K3]
EtwFlushTraceA [2K3]
EtwFlushTraceW [2K3]
EtwGetTraceEnableFlags [2K3]
EtwGetTraceEnableLevel [2K3]
EtwGetTraceLoggerHandle [2K3]
EtwNotificationRegistrationA [2K3]
EtwNotificationRegistrationW [2K3]
EtwQueryAllTracesA [2K3]
EtwQueryAllTracesW [2K3]
EtwQueryTraceA [2K3]
EtwQueryTraceW [2K3]
EtwReceiveNotificationsA [2K3]
EtwReceiveNotificationsW [2K3]
EtwRegisterTraceGuidsA [2K3]
EtwRegisterTraceGuidsW [2K3]
EtwStartTraceA [2K3]
EtwStartTraceW [2K3]
EtwStopTraceA [2K3]
EtwStopTraceW [2K3]
EtwTraceEvent [2K3]
EtwTraceEventInstance [2K3]
EtwTraceMessage [2K3]
EtwTraceMessageVa [2K3]
EtwUnregisterTraceGuids [2K3]
EtwUpdateTraceA [2K3]
EtwUpdateTraceW [2K3]
EtwpGetTraceBuffer [2K3]
EtwpSetHWConfigFunction [2K3]
KiUserApcDispatcher [NT3, NT4, W2K, WXP, 2K3]
KiUserCallbackDispatcher [NT3, NT4, W2K, WXP, 2K3]
KiUserExceptionDispatcher [NT3, NT4, W2K, WXP, 2K3]
LdrAccessOutOfProcessResource [WXP, 2K3]
LdrAddRefDll [WXP, 2K3]
LdrCreateOutOfProcessImage [WXP, 2K3]
LdrDestroyOutOfProcessImage [WXP, 2K3]
LdrEnumResources [NT3, NT4, W2K, WXP, 2K3]
LdrEnumerateLoadedModules [WXP, 2K3]
LdrFindCreateProcessManifest [WXP, 2K3]
LdrFindEntryForAddress [NT3, NT4, W2K, WXP, 2K3]
LdrFindResourceDirectory_U [NT3, NT4, W2K, WXP, 2K3]
LdrFindResourceEx_U [WXP, 2K3]
LdrFindResource_U [NT3, NT4, W2K, WXP, 2K3]
LdrFlushAlternateResourceModules [W2K, WXP, 2K3]
LdrGetDllHandleEx [WXP, 2K3]
LdrHotPatchRoutine [2K3]
LdrInitShimEngineDynamic [WXP, 2K3]
LdrInitializeThunk [NT3, NT4, W2K, WXP, 2K3]
LdrLoadAlternateResourceModule [W2K, WXP, 2K3]
LdrLockLoaderLock [WXP, 2K3]
LdrProcessRelocationBlock [NT3, NT4, W2K, WXP, 2K3]
LdrQueryImageFileExecutionOptionsEx [2K3]
LdrSetAppCompatDllRedirectionCallback [WXP, 2K3]
LdrSetDllManifestProber [WXP, 2K3]
LdrUnloadAlternateResourceModule [W2K, WXP, 2K3]
LdrUnlockLoaderLock [WXP, 2K3]
LdrVerifyImageMatchesChecksum [NT3, NT4, W2K, WXP, 2K3]
NPXEMULATORTABLE [NT3, NT4, W2K]
NlsAnsiCodePage [NT4, W2K, WXP, 2K3]
NlsMbCodePageTag [NT3, NT4, W2K, WXP, 2K3]
NlsMbOemCodePageTag [NT3, NT4, W2K, WXP, 2K3]
NtAddBootEntry [WXP, 2K3]
NtAddDriverEntry [2K3]
NtApphelpCacheControl [2K3]
NtCompactKeys [WXP, 2K3]
NtCompareTokens [WXP, 2K3]
NtCompressKey [WXP, 2K3]
NtCreateDebugObject [WXP, 2K3]
NtCreateJobSet [WXP, 2K3]
NtCreateKeyedEvent [WXP, 2K3]
NtCreateProcessEx [WXP, 2K3]
NtDebugContinue [WXP, 2K3]
NtDeleteBootEntry [WXP, 2K3]
NtDeleteDriverEntry [2K3]
NtEnumerateBootEntries [WXP, 2K3]
NtEnumerateDriverEntries [2K3]
NtEnumerateSystemEnvironmentValuesEx [WXP, 2K3]
NtIsProcessInJob [WXP, 2K3]
NtLoadKeyEx [2K3]
NtLockProductActivationKeys [WXP, 2K3]
NtLockRegistryKey [WXP, 2K3]
NtModifyBootEntry [WXP, 2K3]
NtModifyDriverEntry [2K3]
NtOpenKeyedEvent [WXP, 2K3]
NtOpenProcessTokenEx [WXP, 2K3]
NtOpenThreadTokenEx [WXP, 2K3]
NtQueryBootEntryOrder [WXP, 2K3]
NtQueryBootOptions [WXP, 2K3]
NtQueryDebugFilterState [WXP, 2K3]
NtQueryDriverEntryOrder [2K3]
NtQueryOpenSubKeysEx [2K3]
NtQuerySystemEnvironmentValueEx [WXP, 2K3]
NtReleaseKeyedEvent [WXP, 2K3]
NtRenameKey [WXP, 2K3]
NtSetBootEntryOrder [WXP, 2K3]
NtSetBootOptions [WXP, 2K3]
NtSetDebugFilterState [WXP, 2K3]
NtSetDriverEntryOrder [2K3]
NtSetEventBoostPriority [WXP, 2K3]
NtSetInformationDebugObject [WXP, 2K3]
NtSetSystemEnvironmentValueEx [WXP, 2K3]
NtTraceEvent [WXP, 2K3]
NtTranslateFilePath [WXP, 2K3]
NtUnloadKey2 [2K3]
NtUnloadKeyEx [WXP, 2K3]
NtWaitForDebugEvent [WXP, 2K3]
NtWaitForKeyedEvent [WXP, 2K3]
PfxFindPrefix [NT3, NT4, W2K, WXP, 2K3]
PfxInitialize [NT3, NT4, W2K, WXP, 2K3]
PfxInsertPrefix [NT3, NT4, W2K, WXP, 2K3]
PfxRemovePrefix [NT3, NT4, W2K, WXP, 2K3]
PropertyLengthAsVariant [NT4, W2K, WXP, 2K3]
RestoreEm87Context [NT3, NT4, W2K, WXP, 2K3]
RtlAbortRXact [NT3, NT4, W2K, WXP, 2K3]
RtlAcquireResourceExclusive [NT3, NT4, W2K, WXP, 2K3]
RtlAcquireResourceShared [NT3, NT4, W2K, WXP, 2K3]
RtlActivateActivationContext [WXP, 2K3]
RtlActivateActivationContextEx [WXP, 2K3]
RtlActivateActivationContextUnsafeFast [WXP, 2K3]
RtlAddAccessAllowedObjectAce [W2K, WXP, 2K3]
RtlAddAccessDeniedObjectAce [W2K, WXP, 2K3]
RtlAddActionToRXact [NT3, NT4, W2K, WXP, 2K3]
RtlAddAtomToAtomTable [NT4, W2K, WXP, 2K3]
RtlAddAttributeActionToRXact [NT3, NT4, W2K, WXP, 2K3]
RtlAddAuditAccessObjectAce [W2K, WXP, 2K3]
RtlAddCompoundAce [NT4, W2K, WXP, 2K3]
RtlAddRefActivationContext [WXP, 2K3]
RtlAddRefMemoryStream [WXP, 2K3]
RtlAddressInSectionTable [WXP, 2K3]
RtlAllocateHandle [NT4, W2K, WXP, 2K3]
RtlAppendPathElement [WXP, 2K3]
RtlApplicationVerifierStop [WXP, 2K3]
RtlApplyRXact [NT3, NT4, W2K, WXP, 2K3]
RtlApplyRXactNoFlush [NT3, NT4, W2K, WXP, 2K3]
RtlAssert2 [WXP]
RtlCallbackLpcClient [W2K]
RtlCancelTimer [W2K, WXP, 2K3]
RtlCaptureStackBackTrace [NT3, NT4, W2K, WXP, 2K3]
RtlCaptureStackContext [WXP, 2K3]
RtlCheckProcessParameters [WXP, 2K3]
RtlCloneMemoryStream [WXP, 2K3]
RtlCommitMemoryStream [WXP, 2K3]
RtlCompressBuffer [NT3, NT4, W2K, WXP, 2K3]
RtlComputeCrc32 [WXP, 2K3]
RtlComputeImportTableHash [WXP, 2K3]
RtlComputePrivatizedDllName_U [WXP, 2K3]
RtlConsoleMultiByteToUnicodeN [NT3, NT4, W2K, WXP, 2K3]
RtlConvertExclusiveToShared [NT3, NT4, W2K, WXP, 2K3]
RtlConvertPropertyToVariant [NT4, W2K, WXP, 2K3]
RtlConvertSharedToExclusive [NT3, NT4, W2K, WXP, 2K3]
RtlConvertToAutoInheritSecurityObject [W2K, WXP, 2K3]
RtlConvertUiListToApiList [NT3, NT4, W2K, WXP, 2K3]
RtlConvertVariantToProperty [NT4, W2K, WXP, 2K3]
RtlCopyLuidAndAttributesArray [NT3, NT4, W2K, WXP, 2K3]
RtlCopyMappedMemory [2K3]
RtlCopyMemoryStreamTo [WXP, 2K3]
RtlCopyOutOfProcessMemoryStreamTo [WXP, 2K3]
RtlCopySidAndAttributesArray [NT3, NT4, W2K, WXP, 2K3]
RtlCreateActivationContext [WXP, 2K3]
RtlCreateAndSetSD [NT3, NT4, W2K, WXP, 2K3]
RtlCreateAtomTable [NT4, W2K, WXP, 2K3]
RtlCreateBootStatusDataFile [WXP, 2K3]
RtlCreateEnvironment [NT3, NT4, W2K, WXP, 2K3]
RtlCreateLpcServer [W2K]
RtlCreateSystemVolumeInformationFolder [WXP, 2K3]
RtlCreateTagHeap [NT3, NT4, W2K, WXP, 2K3]
RtlCreateTimer [W2K, WXP, 2K3]
RtlCreateTimerQueue [W2K, WXP, 2K3]
RtlCreateUserSecurityObject [NT3, NT4, W2K, WXP, 2K3]
RtlCustomCPToUnicodeN [NT3, NT4, W2K, WXP, 2K3]
RtlDeactivateActivationContext [WXP, 2K3]
RtlDeactivateActivationContextUnsafeFast [WXP, 2K3]
RtlDebugPrintTimes [W2K, WXP, 2K3]
RtlDecompressBuffer [NT3, NT4, W2K, WXP, 2K3]
RtlDecompressFragment [NT3, NT4, W2K, WXP, 2K3]
RtlDefaultNpAcl [W2K, WXP, 2K3]
RtlDeleteAtomFromAtomTable [NT4, W2K, WXP, 2K3]
RtlDeleteElementGenericTable [NT3, NT4, W2K, WXP, 2K3]
RtlDeleteElementGenericTableAvl [WXP, 2K3]
RtlDeleteNoSplay [NT4, W2K, WXP, 2K3]
RtlDeleteResource [NT3, NT4, W2K, WXP, 2K3]
RtlDeleteSecurityObject [NT3, NT4, W2K, WXP, 2K3]
RtlDeleteTimer [W2K, WXP, 2K3]
RtlDeleteTimerQueue [W2K, WXP, 2K3]
RtlDeleteTimerQueueEx [W2K, WXP, 2K3]
RtlDeregisterWait [W2K, WXP, 2K3]
RtlDeregisterWaitEx [W2K, WXP, 2K3]
RtlDestroyAtomTable [NT4, W2K, WXP, 2K3]
RtlDestroyEnvironment [NT3, NT4, W2K, WXP, 2K3]
RtlDestroyHandleTable [NT4, W2K, WXP, 2K3]
RtlDllShutdownInProgress [WXP, 2K3]
RtlDosApplyFileIsolationRedirection_Ustr [WXP, 2K3]
RtlDosPathNameToRelativeNtPathName_U [2K3]
RtlDosSearchPath_Ustr [WXP, 2K3]
RtlDumpResource [NT3, NT4, W2K, WXP, 2K3]
RtlEmptyAtomTable [NT4, W2K, WXP, 2K3]
RtlEnumProcessHeaps [NT3, NT4, W2K, WXP, 2K3]
RtlEnumerateGenericTable [NT3, NT4, W2K, WXP, 2K3]
RtlEnumerateGenericTableAvl [WXP, 2K3]
RtlEnumerateGenericTableLikeADirectory [WXP, 2K3]
RtlEnumerateGenericTableWithoutSplaying [NT3, NT4, W2K, WXP, 2K3]
RtlEnumerateGenericTableWithoutSplayingAvl [WXP, 2K3]
RtlExitUserThread [WXP, 2K3]
RtlExtendHeap [NT3, NT4, W2K, WXP, 2K3]
RtlFinalReleaseOutOfProcessMemoryStream [WXP, 2K3]
RtlFindActivationContextSectionGuid [WXP, 2K3]
RtlFindActivationContextSectionString [WXP, 2K3]
RtlFindClearRuns [WXP, 2K3]
RtlFindMessage [NT3, NT4, W2K, WXP, 2K3]
RtlFirstEntrySList [WXP, 2K3]
RtlFlushSecureMemoryCache [WXP, 2K3]
RtlFormatMessage [NT3, NT4, W2K, WXP, 2K3]
RtlFreeHandle [NT4, W2K, WXP, 2K3]
RtlFreeThreadActivationContextStack [WXP, 2K3]
RtlFreeUserThreadStack [NT4, W2K, WXP, 2K3]
RtlGenerate8dot3Name [NT3, NT4, W2K, WXP, 2K3]
RtlGetActiveActivationContext [WXP, 2K3]
RtlGetCompressionWorkSpaceSize [NT3, NT4, W2K, WXP, 2K3]
RtlGetElementGenericTable [NT3, NT4, W2K, WXP, 2K3]
RtlGetElementGenericTableAvl [WXP, 2K3]
RtlGetFrame [WXP, 2K3]
RtlGetFullPathName_UstrEx [2K3]
RtlGetLengthWithoutLastFullDosOrNtPathElement [WXP, 2K3]
RtlGetLengthWithoutTrailingPathSeperators [WXP, 2K3]
RtlGetNativeSystemInformation [WXP, 2K3]
RtlGetSecurityDescriptorRMControl [W2K, WXP, 2K3]
RtlGetSetBootStatusData [WXP, 2K3]
RtlGetThreadErrorMode [2K3]
RtlGetUnloadEventTrace [2K3]
RtlGetUserInfoHeap [NT3, NT4, W2K, WXP, 2K3]
RtlHashUnicodeString [WXP, 2K3]
RtlImpersonateLpcClient [W2K]
RtlInitCodePageTable [NT3, NT4, W2K, WXP, 2K3]
RtlInitMemoryStream [WXP, 2K3]
RtlInitNlsTables [NT3, NT4, W2K, WXP, 2K3]
RtlInitOutOfProcessMemoryStream [WXP, 2K3]
RtlInitializeAtomPackage [NT4, W2K, WXP, 2K3]
RtlInitializeContext [NT3, NT4, W2K, WXP, 2K3]
RtlInitializeGenericTable [NT3, NT4, W2K, WXP, 2K3]
RtlInitializeGenericTableAvl [WXP, 2K3]
RtlInitializeHandleTable [NT4, W2K, WXP, 2K3]
RtlInitializeRXact [NT3, NT4, W2K, WXP, 2K3]
RtlInitializeResource [NT3, NT4, W2K, WXP, 2K3]
RtlInsertElementGenericTable [NT3, NT4, W2K, WXP, 2K3]
RtlInsertElementGenericTableAvl [WXP, 2K3]
RtlInsertElementGenericTableFull [2K3]
RtlInsertElementGenericTableFullAvl [2K3]
RtlInterlockedCompareExchange64 [2K3]
RtlInterlockedPushListSList [WXP, 2K3]
RtlIpv4AddressToStringExA [2K3]
RtlIpv4AddressToStringExW [2K3]
RtlIpv4StringToAddressA [WXP, 2K3]
RtlIpv4StringToAddressExA [2K3]
RtlIpv4StringToAddressExW [2K3]
RtlIpv4StringToAddressW [WXP, 2K3]
RtlIpv6AddressToStringA [WXP, 2K3]
RtlIpv6AddressToStringExA [2K3]
RtlIpv6AddressToStringExW [2K3]
RtlIpv6AddressToStringW [WXP, 2K3]
RtlIpv6StringToAddressA [WXP, 2K3]
RtlIpv6StringToAddressExA [2K3]
RtlIpv6StringToAddressExW [2K3]
RtlIpv6StringToAddressW [WXP, 2K3]
RtlIsActivationContextActive [WXP, 2K3]
RtlIsGenericTableEmpty [NT3, NT4, W2K, WXP, 2K3]
RtlIsGenericTableEmptyAvl [WXP, 2K3]
RtlIsThreadWithinLoaderCallout [WXP, 2K3]
RtlIsValidHandle [NT4, W2K, WXP, 2K3]
RtlIsValidIndexHandle [NT4, W2K, WXP, 2K3]
RtlLockBootStatusData [WXP, 2K3]
RtlLockMemoryStreamRegion [WXP, 2K3]
RtlLogStackBackTrace [WXP, 2K3]
RtlLookupAtomInAtomTable [NT4, W2K, WXP, 2K3]
RtlLookupElementGenericTable [NT3, NT4, W2K, WXP, 2K3]
RtlLookupElementGenericTableAvl [WXP, 2K3]
RtlLookupElementGenericTableFull [2K3]
RtlLookupElementGenericTableFullAvl [2K3]
RtlMultiAppendUnicodeStringBuffer [WXP, 2K3]
RtlMultiByteToUnicodeN [NT3, NT4, W2K, WXP, 2K3]
RtlMultiByteToUnicodeSize [NT3, NT4, W2K, WXP, 2K3]
RtlMultipleAllocateHeap [2K3]
RtlMultipleFreeHeap [2K3]
RtlNewInstanceSecurityObject [NT3, NT4, W2K, WXP, 2K3]
RtlNewSecurityGrantedAccess [NT3, NT4, W2K, WXP, 2K3]
RtlNewSecurityObject [NT3, NT4, W2K, WXP, 2K3]
RtlNewSecurityObjectEx [W2K, WXP, 2K3]
RtlNewSecurityObjectWithMultipleInheritance [WXP, 2K3]
RtlNtPathNameToDosPathName [WXP, 2K3]
RtlNumberGenericTableElements [NT3, NT4, W2K, WXP, 2K3]
RtlNumberGenericTableElementsAvl [WXP, 2K3]
RtlPcToFileHeader [NT3, NT4, W2K, WXP, 2K3]
RtlPinAtomInAtomTable [NT4, W2K, WXP, 2K3]
RtlPopFrame [WXP, 2K3]
RtlProtectHeap [NT3, NT4, W2K, WXP, 2K3]
RtlPushFrame [WXP, 2K3]
RtlQueryAtomInAtomTable [NT4, W2K, WXP, 2K3]
RtlQueryHeapInformation [W2K, WXP, 2K3]
RtlQueryInformationActivationContext [WXP, 2K3]
RtlQueryInformationActiveActivationContext [WXP, 2K3]
RtlQueryInterfaceMemoryStream [WXP, 2K3]
RtlQueryProcessBackTraceInformation [NT3, NT4, W2K, WXP, 2K3]
RtlQueryProcessHeapInformation [NT3, NT4, W2K, WXP, 2K3]
RtlQueryProcessLockInformation [NT3, NT4, W2K, WXP, 2K3]
RtlQuerySecurityObject [NT3, NT4, W2K, WXP, 2K3]
RtlQueryTagHeap [NT3, NT4, W2K, WXP, 2K3]
RtlQueryTimeZoneInformation [NT3, NT4, W2K, WXP, 2K3]
RtlQueueApcWow64Thread [WXP, 2K3]
RtlQueueWorkItem [W2K, WXP, 2K3]
RtlRaiseException [NT3, NT4, W2K, WXP, 2K3]
RtlReadMemoryStream [WXP, 2K3]
RtlReadOutOfProcessMemoryStream [WXP, 2K3]
RtlRealPredecessor [NT3, NT4, W2K, WXP, 2K3]
RtlRealSuccessor [NT3, NT4, W2K, WXP, 2K3]
RtlRegisterSecureMemoryCacheCallback [WXP, 2K3]
RtlRegisterWait [W2K, WXP, 2K3]
RtlReleaseActivationContext [WXP, 2K3]
RtlReleaseMemoryStream [WXP, 2K3]
RtlReleaseRelativeName [2K3]
RtlReleaseResource [NT3, NT4, W2K, WXP, 2K3]
RtlRemoteCall [NT3, NT4, W2K, WXP, 2K3]
RtlResetRtlTranslations [NT3, NT4, W2K, WXP, 2K3]
RtlRevertMemoryStream [WXP, 2K3]
RtlSeekMemoryStream [WXP, 2K3]
RtlSelfRelativeToAbsoluteSD2 [W2K, WXP, 2K3]
RtlSetAttributesSecurityDescriptor [NT4, W2K, WXP, 2K3]
RtlSetCurrentEnvironment [NT3, NT4, W2K, WXP, 2K3]
RtlSetEnvironmentStrings [2K3]
RtlSetEnvironmentVariable [NT3, NT4, W2K, WXP, 2K3]
RtlSetHeapInformation [W2K, WXP, 2K3]
RtlSetIoCompletionCallback [W2K, WXP, 2K3]
RtlSetMemoryStreamSize [WXP, 2K3]
RtlSetSecurityDescriptorRMControl [W2K, WXP, 2K3]
RtlSetSecurityObject [NT3, NT4, W2K, WXP, 2K3]
RtlSetSecurityObjectEx [W2K, WXP, 2K3]
RtlSetThreadErrorMode [2K3]
RtlSetThreadPoolStartFunc [W2K, WXP, 2K3]
RtlSetTimeZoneInformation [NT3, NT4, W2K, WXP, 2K3]
RtlSetTimer [W2K, WXP, 2K3]
RtlSetUnicodeCallouts [NT4, W2K, WXP, 2K3]
RtlSetUserFlagsHeap [NT3, NT4, W2K, WXP, 2K3]
RtlSetUserValueHeap [NT3, NT4, W2K, WXP, 2K3]
RtlShutdownLpcServer [W2K]
RtlSplay [NT3, NT4, W2K, WXP, 2K3]
RtlStartRXact [NT3, NT4, W2K, WXP, 2K3]
RtlStatMemoryStream [WXP, 2K3]
RtlSubtreePredecessor [NT3, NT4, W2K, WXP, 2K3]
RtlSubtreeSuccessor [NT3, NT4, W2K, WXP, 2K3]
RtlTraceDatabaseAdd [W2K, WXP, 2K3]
RtlTraceDatabaseCreate [W2K, WXP, 2K3]
RtlTraceDatabaseDestroy [W2K, WXP, 2K3]
RtlTraceDatabaseEnumerate [W2K, WXP, 2K3]
RtlTraceDatabaseFind [W2K, WXP, 2K3]
RtlTraceDatabaseLock [W2K, WXP, 2K3]
RtlTraceDatabaseUnlock [W2K, WXP, 2K3]
RtlTraceDatabaseValidate [W2K, WXP, 2K3]
RtlUnhandledExceptionFilter [WXP, 2K3]
RtlUnhandledExceptionFilter2 [WXP, 2K3]
RtlUnicodeToCustomCPN [NT3, NT4, W2K, WXP, 2K3]
RtlUnicodeToMultiByteN [NT3, NT4, W2K, WXP, 2K3]
RtlUnicodeToOemN [NT3, NT4, W2K, WXP, 2K3]
RtlUnlockBootStatusData [WXP, 2K3]
RtlUnlockHeap [NT3, NT4, W2K, WXP, 2K3]
RtlUnlockMemoryStreamRegion [WXP, 2K3]
RtlUpcaseUnicodeToCustomCPN [NT3, NT4, W2K, WXP, 2K3]
RtlUpdateTimer [W2K, WXP, 2K3]
RtlUsageHeap [NT3, NT4, W2K, WXP, 2K3]
RtlValidateProcessHeaps [NT3, NT4, W2K, WXP, 2K3]
RtlWalkFrameChain [W2K, WXP, 2K3]
RtlWalkHeap [NT3, NT4, W2K, WXP, 2K3]
RtlWow64EnableFsRedirection [2K3]
RtlWriteMemoryStream [WXP, 2K3]
RtlZombifyActivationContext [WXP, 2K3]
RtlpApplyLengthFunction [WXP, 2K3]
RtlpEnsureBufferSize [WXP, 2K3]
RtlpUnWaitCriticalSection [NT3, NT4, W2K, WXP, 2K3]
RtlpWaitForCriticalSection [NT3, NT4, W2K, WXP, 2K3]
SaveEm87Context [NT3, NT4, W2K, WXP, 2K3]
ZwAddBootEntry [WXP, 2K3]
ZwAddDriverEntry [2K3]
ZwApphelpCacheControl [2K3]
ZwCompactKeys [WXP, 2K3]
ZwCompareTokens [WXP, 2K3]
ZwCompressKey [WXP, 2K3]
ZwCreateDebugObject [WXP, 2K3]
ZwCreateJobSet [WXP, 2K3]
ZwCreateKeyedEvent [WXP, 2K3]
ZwCreateProcessEx [WXP, 2K3]
ZwDebugContinue [WXP, 2K3]
ZwDeleteBootEntry [WXP, 2K3]
ZwDeleteDriverEntry [2K3]
ZwEnumerateBootEntries [WXP, 2K3]
ZwEnumerateDriverEntries [2K3]
ZwEnumerateSystemEnvironmentValuesEx [WXP, 2K3]
ZwIsProcessInJob [WXP, 2K3]
ZwLoadKeyEx [2K3]
ZwLockProductActivationKeys [WXP, 2K3]
ZwLockRegistryKey [WXP, 2K3]
ZwModifyBootEntry [WXP, 2K3]
ZwModifyDriverEntry [2K3]
ZwOpenKeyedEvent [WXP, 2K3]
ZwOpenProcessTokenEx [WXP, 2K3]
ZwOpenThreadTokenEx [WXP, 2K3]
ZwQueryBootEntryOrder [WXP, 2K3]
ZwQueryBootOptions [WXP, 2K3]
ZwQueryDebugFilterState [WXP, 2K3]
ZwQueryDriverEntryOrder [2K3]
ZwQueryOpenSubKeysEx [2K3]
ZwQuerySystemEnvironmentValueEx [WXP, 2K3]
ZwReleaseKeyedEvent [WXP, 2K3]
ZwRenameKey [WXP, 2K3]
ZwSetBootEntryOrder [WXP, 2K3]
ZwSetBootOptions [WXP, 2K3]
ZwSetDebugFilterState [WXP, 2K3]
ZwSetDriverEntryOrder [2K3]
ZwSetEventBoostPriority [WXP, 2K3]
ZwSetInformationDebugObject [WXP, 2K3]
ZwSetSystemEnvironmentValueEx [WXP, 2K3]
ZwTraceEvent [WXP, 2K3]
ZwTranslateFilePath [WXP, 2K3]
ZwUnloadKey2 [2K3]
ZwUnloadKeyEx [WXP, 2K3]
ZwWaitForDebugEvent [WXP, 2K3]
ZwWaitForKeyedEvent [WXP, 2K3]

 +  457 (35.90%) not yet declared
 +  816 (64.10%) declared already
 = 1273 (100.00%) relevant functions overall


The following usermode Native APIs are considered deprecated
since they are only available in NT3 or NT4 only or in NT3/NT4
only. Hence they are considered irrelevant. These are:
-----------------------------------------------------------------
CsrAllocateCapturePointer [NT3, NT4]
CsrClientMaxMessage [NT3]
CsrClientSendMessage [NT3]
CsrClientThreadConnect [NT3]
CsrpProcessCallbackRequest [NT3]
NtEnumerateBus [NT3]
NtQueryOleDirectoryFile [NT4]
NtRegisterNewDevice [NT3]
NtReleaseProcessMutant [NT3]
NtWaitForProcessMutant [NT3]
RtlClosePropertySet [NT4]
RtlCompareVariants [NT4]
RtlCreatePropertySet [NT4]
RtlEnumerateProperties [NT4]
RtlFindLongestRunSet [NT3, NT4]
RtlFlushPropertySet [NT4]
RtlGuidToPropertySetName [NT4]
RtlOnMappedStreamEvent [NT4]
RtlPropertySetNameToGuid [NT4]
RtlQueryProperties [NT4]
RtlQueryPropertyNames [NT4]
RtlQueryPropertySet [NT4]
RtlSetProperties [NT4]
RtlSetPropertyNames [NT4]
RtlSetPropertySetClassId [NT4]
RtlpInitializeRtl [NT3]
ZwEnumerateBus [NT3]
ZwQueryOleDirectoryFile [NT4]
ZwRegisterNewDevice [NT3]
ZwReleaseProcessMutant [NT3]
ZwWaitForProcessMutant [NT3]

 = 31 deprecated functions
*)
end.
