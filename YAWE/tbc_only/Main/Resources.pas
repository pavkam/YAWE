{*------------------------------------------------------------------------------
  Resources used by the YAWE server.
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author Seth
  @Changes TheSelby, PavkaM
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Resources;

interface

const
  EOL = #13#10;

resourcestring
  RsCnslWelcome                = 'Welcome to ';
  RsCnslCompiledWith           = 'Compiled with flags: ';
  RsCnslRunningOn              = 'Running on ';
  RsCnslAcceptedBuilds         = 'Accepted client builds: ';
  RsFatal                      = 'Server has encountered an unrecoverable error and must exit now.';
  RsInit                       = 'Initializing ';
  RsInternalError              = ' faced an internal error!';
  RsStartCore                  = ' has been started!';
  RsStopCore                   = ' has been stopped!';
  RsExitMsg                    = 'Press enter to exit.';
  RsLoad                       = ' > Loading ';
  RsLoadSub                    = ' > Initializing ';
  RsLoadSubComp                = '   > Loading ';
  RsSubInfo                    = '   > ';
  RsStartupTime                = 'Startup time: ~';
  RsShutdownTime               = 'Shutdown time: ~';
  RsSeeErrorLog                = 'To help fix this problem send the contents of error.log to the developers.';
  RsMsgPressX1                 = 'You can type ';
  RsMsgPressX2                 = ' to safely stop ';
  RsMsgPressT1                 = 'You may also type ';
  RsMsgPressT2                 = ' to minimize the console into a notification icon.';
  RsLoadingConf                = 'Loading configuration file ... ';
  RsError                      = '[Error]';
  RsSuccess                    = '[Success]';
  RsGrpMgrReqUpd               = '(GroupMgr) - Update Required for ';
  RsNotConsole                 = 'This application is not a console';
  RsListsDiffer                = 'Parameter lengths differ (%d, %d)';
  RsFileErrLoad                = 'Could not open a file.';
  RsFileErrSave                = 'Could not create/overwrite a file.';
  RsFileErrRead                = 'Could not read the file contents.';
  RsFileErrCrpt                = 'Data corruption present.';
  RsFileErrDBCCrpt             = 'The opened file is not a DBC file - possible file corruption.';
  RsFileErrDBCCrpt2            = 'The opened file is not a DBC Definition file - possible file corruption.';
  RsFileErrPcpCrpt             = 'The opened file is not a PCP file - possible file corruption.';
  RsFileErrPcpVerMismatch      = 'Version mismatch occured while opening a PCP file.'; 
  RsFileErrDBCBadFmt           = 'Too many indices defined.';
  RsFileErrDBCNo               = 'DBC file "%s" does not exist.';
  RsFileErrDBCNo2              = 'DBC definition file "%s" does not exist.';
  RsFileErrTTNo                = 'TT file "%s" does not exist.';
  RsFileErrSmdNo               = 'SMD file %s does not exist.'; 
  RsSectionMissing             = 'Section name not specified in options.';
  RsFileErrOp                  = 'File operation error (%s).';
  RsUndefinedError             = 'Undefined error.';
  RsInvalidPacketMsg           = 'Unsupported packet ID: %d received!';
  RsDataCoreLoadErr            = 'Load error!';
  RsDataCoreFileMustExit       = 'Load error! The server will NOT work properly without this database module';
  RsDataCoreFileNotExists      = 'Load error! Autocreating this module on server shutdown';
  RsDataCoreSaveErr            = 'Save error!';
  RsDataCoreBadOpt             = 'Invalid options specified!';
  RsDataCoreUnkMed             = 'Unknown medium type!';
  RsNoTypeProcessingCallback   = 'No type processing callback was registered for %s, field %s.';
  RsUnsupportedMedium          = 'Unsupported medium type: "%s".';
  RsNoMedium                   = 'No medium type specified.';
  RsMapMgrFileDoesNotExist     = 'Map file "%s" cannot be accessed or missing!';
  RsMapMgrCorrupted            = 'Map file "%s" has wrong format!';
  RsMapMgrBadVer               = 'The version [%d.%d] of Map file "%s" is incompatible with this version of YAWE, which requires maps with version [%d.%d]!';
  RsMapMgrUnkErr               = 'Unable to read map file "%s"!';
  RsMapMgrNotLoaded            = 'Map index table not loaded'; 
  RsNetworkCoreLogonInit       = 'Initialization of the Logon Manager failed on port "%d"!';
  RsNetworkCorePatchInit       = 'Initialization of the Patch Manager failed!';
  RsNetworkCoreRealmInit       = 'Initialization of the Realm List failed!';
  RsNetworkCoreWorldInit       = 'Initialization of the World Manager failed on port "%d"!';
  RsNetworkCoreLogonStart      = 'Starting of Logon Manager failed!';
  RsNetworkCoreWorldStart      = 'Starting of World Manager failed!';
  RsNetworkCoreBadKeySize      = 'Invalid key size (%d).';
  RsNetworkCoreErrPatch        = 'Could not load patch "%s".';
  RsExtCoreYesLibErr           = 'Yes lib could not be found or an unexpected error occured.';

  RsErrLogNoDet                = 'No details available.';
  RsErrLogHeader               = 'New log on %s. ' + EOL + EOL;
  RsErrLogSysStart             = 'System exception occured.' + EOL + '%s.' + EOL;
  RsErrLogStart                = 'Exception of class %s occured with message "%s".' + EOL;
  RsErrLogExtraFlags           = 'Internal Flags: %s' + EOL;
  RsErrLogCall                 = 'Exception address located at line %d in file %s.' + EOL;
  RsErrLogStack                = 'Call Stack:';
  RsErrLogNoStack              = 'Call Stack: Empty (No call stack available.)';
  RsErrYAWEInfo                =
    'YAWE Version: %s' + EOL;
  RsErrLogCpuAndOsInfo         =
    'Operating System: %s' + EOL + EOL +
    'CPU Info:' + EOL +
    '  Manufacturer: %s' + EOL +
    '  Name: %s' + EOL +
    '  Extra Characteristics: %s' + EOL +
    '  Number Of Logical Processors: %d' + EOL;
  RsErrLogMemInfo              =
    'Memory Info:' + EOL +
    '  Physical Memory Usage: %d K' + EOL +
    '  Virtual Memory Usage: %d K' + EOL +
    '  Peak Physical Memory Usage: %d K' + EOL +
    '  Peak Virtual Memory Usage: %d K' + EOL;
  SExecuteAccess               = 'Execute';
  RsErrLoadedModules           = 'Loaded Modules:' + EOL;
  RsGetConsoleMode             = 'GetConsoleMode failed: %s';
  RsSetConsoleMode             = 'SetConsoleMode failed: %s';

implementation

end.
