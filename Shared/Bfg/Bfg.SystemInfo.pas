{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  System Information Retreival
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright JEDI Team, Fastcode project
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Bfg.SystemInfo;

interface

type
  TWindowsVersion =
   (wvUnknown, wvWin95, wvWin95OSR2, wvWin98, wvWin98SE, wvWinME,
    wvWinNT31, wvWinNT35, wvWinNT351, wvWinNT4, wvWin2000, wvWinXP,
    wvWin2003, wvWinXP64, wvWin2003R2, wvWinVista, wvWinLonghorn);

  TSPVersion = Integer;

  TWindowsInfo = record
    Version: TWindowsVersion;
    SP: TSPVersion;
  end;

  {$Z4}
  TCPUVendor = (cvUnknown, cvAMD, cvCentaur, cvCyrix, cvIntel,
    cvTransmeta, cvNexGen, cvRise, cvUMC, cvNSC, cvSiS);
  {$Z1}
  TCPUInstructionSupport = (cisFPU, cisRDTSC, cisCX8, cisSEP, cisCMOV, cisMMX, cisExMMX,
    cisFXSR, cis3DNow, cisEx3DNow, cisSSE, cisSSE2, cisSSE3, cisMONITOR, cisX64, cisCX16,
    cisSSSE3);
  TCPUInstructionSupportSet = set of TCPUInstructionSupport;

  PCpuInfo = ^TCpuInfo;
  TCpuInfo = packed record
    Vendor: TCPUVendor;
    VendorString: string;
    Signature: Longword;
    CpuName: string;
    EffFamily: Byte;
    EffModel: Byte;
    EffModelBasic: Byte;
    CodeL1CacheSize,
    DataL1CacheSize,
    L2CacheSize,
    L3CacheSize: Word;
    InstructionSupport: TCPUInstructionSupportSet;
    InstructionSupportString: string;
  end;

var
  CPUInfo: TCPUInfo;
  PageSize: Longword;
  WindowsInfo: TWindowsInfo;
  OSName: string;
  ProcessorCount: Byte;

//function TotalCpuUsage: Single;
//function CpuUsageForProcess(const ProcName: string): Single;
//function CurrentProcessCpuUsage: Single;

implementation

{$G-}

uses
  API.Win.Kernel,
  API.Win.Types,
  API.Win.NTCommon,
  API.Win.User,
  SysUtils,
  Bfg.Resources{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

const
  FeatureStringIdents: array[TCPUInstructionSupport] of string = (
    'FPU',
    'RDTSC',
    'CX8',
    'SEP',
    'CMOV',
    'MMX',
    'MMX+',
    'FXSR',
    '3DNow!',
    '3DNow!+',
    'SSE',
    'SSE2',
    'SSE3',
    'MONITOR',
    'X64',
    'CX16',
    'SSSE3'
  );

type
  TRegisters = record
    EAX,
    EBX,
    ECX,
    EDX: Longword;
  end;

  TVendorStr = string[12];

  TCpuFeatures =
    ({in EDX}
    cfFPU, cfVME, cfDE, cfPSE, cfRDTSC, cfMSR, cfPAE, cfMCE,
    cfCX8, cfAPIC, cf_d10, cfSEP, cfMTRR, cfPGE, cfMCA, cfCMOV,
    cfPAT, cfPSE36, cfPSN, cfCLFSH, cf_d20, cfDS, cfACPI, cfMMX,
    cfFXSR, cfSSE, cfSSE2, cfSS, cfHTT, cfTM, cfIA_64, cfPBE,
    {in ECX}
    cfSSE3, cf_c1, cf_c2, cfMON, cfDS_CPL, cf_c5, cf_c6, cfEIST,
    cfTM2, cfSSSE3, cfCID, cf_c11, cf_c12, cfCX16, cfxTPR, cf_c15,
    cf_c16, cf_c17, cf_c18, cf_c19, cf_c20, cf_c21, cf_c22, cf_c23,
    cf_c24, cf_c25, cf_c26, cf_c27, cf_c28, cf_c29, cf_c30, cf_c31);
  TCpuFeatureSet = set of TCpuFeatures;

  TCpuExtendedFeatures =
    (cefFPU, cefVME, cefDE, cefPSE, cefTSC, cefMSR, cefPAE, cefMCE,
    cefCX8, cefAPIC, cef_10, cefSEP, cefMTRR, cefPGE, cefMCA, cefCMOV,
    cefPAT, cefPSE36, cef_18, ceMPC, ceNX, cef_21, cefExMMX, cefMMX,
    cefFXSR, cef_25, cef_26, cef_27, cef_28, cefLM, cefEx3DNow, cef3DNow);
  TCpuExtendedFeatureSet = set of TCpuExtendedFeatures;

const
  VendorIDString: array[Low(TCPUVendor)..High(TCPUVendor)] of TVendorStr = (
    'Unknown', 'AuthenticAMD', 'CentaurHauls', 'CyrixInstead',
    'GenuineIntel', 'GenuineTMx86', 'NexGenDriven', 'RiseRiseRise',
    'UMC UMC UMC ', 'Geode by NSC', 'SiS SiS SiS');

  VendorStrings: array[Low(TCPUVendor)..High(TCPUVendor)] of string = (
    'Unknown', 'AMD', 'Centaur (VIA)', 'Cyrix', 'Intel', 'Transmeta',
    'NexGen', 'Rise', 'UMC', 'National Semiconductor', 'SiS');

  {CPU signatures}

  IntelLowestSEPSupportSignature = $633;
  K7DuronA0Signature = $630;
  C3Samuel2EffModel = 7;
  C3EzraEffModel = 8;
  PMBaniasEffModel = 9;
  PMDothanEffModel = $D;
  PMYonahEffModel = $E;
  P3LowestEffModel = 7;

  OSVersionUnk               = 'Windows';
  OSVersionWin95             = 'Windows 95';
  OSVersionWin95OSR2         = 'Windows 95 OSR2';
  OSVersionWin98             = 'Windows 98';
  OSVersionWin98SE           = 'Windows 98 SE';
  OSVersionWinME             = 'Windows ME';
  OSVersionWinNT3            = 'Windows NT 3.%d';
  OSVersionWinNT4            = 'Windows NT 4.%d';
  OSVersionWin2000           = 'Windows 2000';
  OSVersionWinXP             = 'Windows XP';
  OSVersionWin2003           = 'Windows Server 2003';
  OSVersionWin2003R2         = 'Windows Server 2003 "R2"';
  OSVersionWinXP64           = 'Windows XP x64';
  OSVersionWinVista          = 'Windows Vista';
  OSVersionWinLonghorn       = 'Windows Server "Longhorn"';
  OSServicePack              = 'SP %d';

function IsCPUID_Available: Boolean; 
asm
  PUSHFD                 {save EFLAGS to stack}
  POP     EAX            {store EFLAGS in EAX}
  MOV     EDX, EAX       {save in EDX for later testing}
  XOR     EAX, $200000;  {flip ID bit in EFLAGS}
  PUSH    EAX            {save new EFLAGS value on stack}
  POPFD                  {replace current EFLAGS value}
  PUSHFD                 {get new EFLAGS}
  POP     EAX            {store new EFLAGS in EAX}
  XOR     EAX, EDX       {check if ID bit changed}
  JZ      @exit          {no, CPUID not available}
  MOV     EAX, True      {yes, CPUID is available}
@exit:
end;

function IsFPU_Available: Boolean;
var
  _FCW, _FSW: Word;
asm
  MOV     EAX, False     {initialize return register}
  MOV     _FSW, $5A5A    {store a non-zero value}
  FNINIT                 {must use non-wait form}
  FNSTSW  _FSW           {store the status}
  CMP     _FSW, 0        {was the correct status read?}
  JNE     @exit          {no, FPU not available}
  FNSTCW  _FCW           {yes, now save control word}
  MOV     DX, _FCW       {get the control word}
  AND     DX, $103F      {mask the proper status bits}
  CMP     DX, $3F        {is a numeric processor installed?}
  JNE     @exit          {no, FPU not installed}
  MOV     EAX, True      {yes, FPU is installed}
@exit:
end;

procedure GetCPUID(Param: Longword; var Registers: TRegisters);
asm
  PUSH    EBX                         {save affected registers}
  PUSH    EDI
  MOV     EDI, Registers
  XOR     EBX, EBX                    {clear EBX register}
  XOR     ECX, ECX                    {clear ECX register}
  XOR     EDX, EDX                    {clear EDX register}
  CPUID                               {CPUID opcode}
  MOV     [EDI].TRegisters.&EAX, EAX  {save EAX register}
  MOV     [EDI].TRegisters.&EBX, EBX  {save EBX register}
  MOV     [EDI].TRegisters.&ECX, ECX  {save ECX register}
  MOV     [EDI].TRegisters.&EDX, EDX  {save EDX register}
  POP     EDI                         {restore registers}
  POP     EBX
end;

procedure GetCPUVendor;
var
  VendorStr: TVendorStr;
  Registers: TRegisters;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,781 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  {call CPUID function 0}
  GetCPUID(0, Registers);

  {get vendor string}
  SetLength(VendorStr, 12);
  Move(Registers.EBX, VendorStr[1], 4);
  Move(Registers.EDX, VendorStr[5], 4);
  Move(Registers.ECX, VendorStr[9], 4);

  {get CPU vendor from vendor string}
  CPUInfo.Vendor := High(TCPUVendor);
  while (VendorStr <> VendorIDString[CPUInfo.Vendor]) and
    (CPUInfo.Vendor > Low(TCPUVendor)) do
  begin
    Dec(CPUInfo.Vendor);
  end;
  CPUInfo.VendorString := VendorStrings[CPUInfo.Vendor];
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,781; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure GetCPUName;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,782 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  with CPUInfo do
  begin
    if Vendor = cvIntel then
    begin
      case EffFamily of
        4: case EffModel of
           0, 1: CpuName := 'Intel 486 DX';
           2:    CpuName := 'Intel 486 SX';
           3:    CpuName := 'Intel 486 DX/2';
           4:    CpuName := 'Intel 486 SL';
           5:    CpuName := 'Intel 486 SX/2';
           7:    CpuName := 'Intel 486 DX/2-WB';
           8:    CpuName := 'Intel 486 DX/4';
           9:    CpuName := 'Intel 486 DX/4-WB';
         end;
        5: case EffModel of
           0..2: CpuName := 'Intel Pentium';
           4:    CpuName := 'Intel Pentium MMX';
           7:    CpuName := 'Intel Mobile Pentium';
           8:    CpuName := 'Intel Mobile Pentium MMX';
         end;
        6: case EffModel of
           1:  CpuName := 'Intel Pentium Pro';
           3:  CpuName := 'Intel Pentium II [Klamath]';
           5:  CpuName := 'Intel Pentium II [Deschutes]';
           6:  CpuName := 'Intel Celeron [Mendocino]';
           7:  CpuName := 'Intel Pentium III [Katmai]';
           8:  CpuName := 'Intel Pentium III [Coppermine]';
           9:  CpuName := 'Intel Pentium M [Banias]';
           10: CpuName := 'Intel Pentium III Xeon';
           11: CpuName := 'Intel Pentium III';
           13: CpuName := 'Intel Pentium M [Dothan]';
         end;
        15: case EffModel of
            0, 1: CpuName := 'Pentium 4 [Willamette]';
            2:    CpuName := 'Pentium 4 [Northwood]';
            3, 4: CpuName := 'Pentium 4 [Prescott]';
          end;
      end
    end else if Vendor = cvAMD then
    begin
      case EffFamily of
        4: case EffModel of
           3:  CpuName := 'AMD 486 DX/2';
           7:  CpuName := 'AMD 486 DX/2-WB';
           8:  CpuName := 'AMD 486 DX/4';
           9:  CpuName := 'AMD 486 DX/4-WB';
           14: CpuName := 'AMD Am5x86-WT';
           15: CpuName := 'AMD Am5x86-WB';
         end;
        5: case EffModel of
           0:    CpuName := 'AMD K5/SSA5';
           1..3: CpuName := 'AMD K5';
           6, 7: CpuName := 'AMD K6';
           8:    CpuName := 'AMD K6-2';
           9:    CpuName := 'AMD K6-3';
           13:   CpuName := 'AMD K6-2+ / K6-III+';
         end;
        6: case EffModel of
           0..2: CpuName := 'AMD Athlon';
           3:    CpuName := 'AMD Duron';
           4:    CpuName := 'AMD Athlon [Thunderbird]';
           6:    CpuName := 'AMD Athlon [Palamino]';
           7:    CpuName := 'AMD Duron [Morgan]';
           8:    CpuName := 'AMD Athlon [Thoroughbred]';
           10:   CpuName := 'AMD Athlon [Barton]';
         end;
        15: case EffModel of
            4: CpuName := 'AMD Athlon 64';
            5: CpuName := 'AMD Athlon 64 FX / Opteron';
          end;
      end;
    end else CpuName := 'Unknown';
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,782; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure GetCPUFeatures;
{preconditions: 1. maximum CPUID must be at least $00000001
                2. GetCPUVendor must have been called}
var
  Registers: TRegisters;
  CpuFeatures: TCpuFeatureSet;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,783 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  {call CPUID function $00000001}
  GetCPUID($00000001, Registers);

  {get CPU signature}
  CPUInfo.Signature := Registers.EAX;

  {extract effective processor family and model}
  CPUInfo.EffFamily := CPUInfo.Signature and $00000F00 shr 8;
  CPUInfo.EffModel := CPUInfo.Signature and $000000F0 shr 4;
  CPUInfo.EffModelBasic := CPUInfo.EffModel;
  if CPUInfo.EffFamily = $F then
  begin
    CPUInfo.EffFamily := CPUInfo.EffFamily + (CPUInfo.Signature and $0FF00000 shr 20);
    CPUInfo.EffModel := CPUInfo.EffModel + (CPUInfo.Signature and $000F0000 shr 12);
  end;

  GetCPUName;

  {get CPU features}
  Move(Registers.EDX, Int64Rec(CpuFeatures).Lo, 4);
  Move(Registers.ECX, Int64Rec(CpuFeatures).Hi, 4);

  {get instruction support}
  if cfFPU in CpuFeatures then
    Include(CPUInfo.InstructionSupport, cisFPU);
  if cfRDTSC in CpuFeatures then
    Include(CPUInfo.InstructionSupport, cisRDTSC);
  if cfCX8 in CpuFeatures then
    Include(CPUInfo.InstructionSupport, cisCX8);
  if cfSEP in CpuFeatures then
  begin
    Include(CPUInfo.InstructionSupport, cisSEP);
    {for Intel CPUs, qualify the processor family and model to ensure that the
     SYSENTER/SYSEXIT instructions are actually present - see Intel Application
     Note AP-485}
    if (CPUInfo.Vendor = cvIntel) and
      (CPUInfo.Signature and $0FFF3FFF < IntelLowestSEPSupportSignature) then
      Exclude(CPUInfo.InstructionSupport, cisSEP);
  end;
  if cfCMOV in CpuFeatures then
    Include(CPUInfo.InstructionSupport, cisCMOV);
  if cfFXSR in CpuFeatures then
    Include(CPUInfo.InstructionSupport, cisFXSR);
  if cfMMX in CpuFeatures then
    Include(CPUInfo.InstructionSupport, cisMMX);
  if cfSSE in CpuFeatures then
    Include(CPUInfo.InstructionSupport, cisSSE);
  if cfSSE2 in CpuFeatures then
    Include(CPUInfo.InstructionSupport, cisSSE2);
  if cfSSE3 in CpuFeatures then
    Include(CPUInfo.InstructionSupport, cisSSE3);
  if (CPUInfo.Vendor = cvIntel) and (cfMON in CpuFeatures) then
    Include(CPUInfo.InstructionSupport, cisMONITOR);
  if cfCX16 in CpuFeatures then
    Include(CPUInfo.InstructionSupport, cisCX16);
  if cfSSSE3 in CPuFeatures then
    Include(CPUInfo.InstructionSupport, cisSSSE3);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,783; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure GetCPUExtendedFeatures;
{preconditions: maximum extended CPUID >= $80000001}
var
  Registers: TRegisters;
  CpuExFeatures: TCpuExtendedFeatureSet;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,784 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  {call CPUID function $80000001}
  GetCPUID($80000001, Registers);

  {get CPU extended features}
  CPUExFeatures := TCPUExtendedFeatureSet(Registers.EDX);

  {get instruction support}
  if cefLM in CpuExFeatures then
    Include(CPUInfo.InstructionSupport, cisX64);
  if cefExMMX in CpuExFeatures then
    Include(CPUInfo.InstructionSupport, cisExMMX);
  if cefEx3DNow in CpuExFeatures then
    Include(CPUInfo.InstructionSupport, cisEx3DNow);
  if cef3DNow in CpuExFeatures then
    Include(CPUInfo.InstructionSupport, cis3DNow);
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,784; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure GetProcessorCacheInfo;
{preconditions: 1. maximum CPUID must be at least $00000002
                2. GetCPUVendor must have been called}
type
  TConfigDescriptor = packed array[0..15] of Byte;
var
  Registers: TRegisters;
  I, J: Integer;
  QueryCount: Byte;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,785 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  {call CPUID function 2}
  GetCPUID($00000002, Registers);
  QueryCount := Registers.EAX and $FF;
  for I := 1 to QueryCount do
  begin
    for J := 1 to 15 do
    begin
      with CPUInfo do
      begin
        {decode configuration descriptor byte}
        case TConfigDescriptor(Registers)[J] of
          $06: CodeL1CacheSize := 8;
          $08: CodeL1CacheSize := 16;
          $0A: DataL1CacheSize := 8;
          $0C: DataL1CacheSize := 16;
          $22: L3CacheSize := 512;
          $23: L3CacheSize := 1024;
          $25: L3CacheSize := 2048;
          $29: L3CacheSize := 4096;
          $2C: DataL1CacheSize := 32;
          $30: CodeL1CacheSize := 32;
          $39: L2CacheSize := 128;
          $3B: L2CacheSize := 128;
          $3C: L2CacheSize := 256;
          $40: {no 2nd-level cache or, if processor contains a valid 2nd-level
                cache, no 3rd-level cache}
            if L2CacheSize <> 0 then
              L3CacheSize := 0;
          $41: L2CacheSize := 128;
          $42: L2CacheSize := 256;
          $43: L2CacheSize := 512;
          $44: L2CacheSize := 1024;
          $45: L2CacheSize := 2048;
          $60: DataL1CacheSize := 16;
          $66: DataL1CacheSize := 8;
          $67: DataL1CacheSize := 16;
          $68: DataL1CacheSize := 32;
          $70: if not (CPUInfo.Vendor in [cvCyrix, cvNSC]) then
              CodeL1CacheSize := 12; {K micro-ops}
          $71: CodeL1CacheSize := 16; {K micro-ops}
          $72: CodeL1CacheSize := 32; {K micro-ops}
          $78: L2CacheSize := 1024;
          $79: L2CacheSize := 128;
          $7A: L2CacheSize := 256;
          $7B: L2CacheSize := 512;
          $7C: L2CacheSize := 1024;
          $7D: L2CacheSize := 2048;
          $7F: L2CacheSize := 512;
          $80: if CPUInfo.Vendor in [cvCyrix, cvNSC] then
            begin {Cyrix and NSC only - 16 KB unified L1 cache}
              CodeL1CacheSize := 8;
              DataL1CacheSize := 8;
            end;
          $82: L2CacheSize := 256;
          $83: L2CacheSize := 512;
          $84: L2CacheSize := 1024;
          $85: L2CacheSize := 2048;
          $86: L2CacheSize := 512;
          $87: L2CacheSize := 1024;
        end;
      end;
    end;
    if I < QueryCount then
    begin
      GetCPUID(2, Registers);
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,785; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure GetExtendedProcessorCacheInfo;
{preconditions: 1. maximum extended CPUID must be at least $80000006
                2. GetCPUVendor and GetCPUFeatures must have been called}
var
  Registers: TRegisters;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,786 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  {call CPUID function $80000005}
  GetCPUID($80000005, Registers);

  {get L1 cache size}
  {Note: Intel does not support function $80000005 for L1 cache size, so ignore.
         Cyrix returns CPUID function 2 descriptors (already done), so ignore.}
  if not (CPUInfo.Vendor in [cvIntel, cvCyrix]) then
  begin
    CPUInfo.CodeL1CacheSize := Registers.EDX shr 24;
    CPUInfo.DataL1CacheSize := Registers.ECX shr 24;
  end;

  {call CPUID function $80000006}
  GetCPUID($80000006, Registers);

  {get L2 cache size}
  if (CPUInfo.Vendor = cvAMD) and (CPUInfo.Signature and $FFF = K7DuronA0Signature) then
    {workaround for AMD Duron Rev A0 L2 cache size erratum - see AMD Technical
     Note TN-13}
    CPUInfo.L2CacheSize := 64
  else if (CPUInfo.Vendor = cvCentaur) and (CPUInfo.EffFamily = 6) and
    (CPUInfo.EffModel in [C3Samuel2EffModel, C3EzraEffModel]) then
    {handle VIA (Centaur) C3 Samuel 2 and Ezra non-standard encoding}
    CPUInfo.L2CacheSize := Registers.ECX shr 24
  else {standard encoding}
    CPUInfo.L2CacheSize := Registers.ECX shr 16;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,786; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure VerifyOSSupportForXMMRegisters;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,787 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  {try a SSE instruction that operates on XMM registers}
  try
    asm
      ORPS XMM0, XMM0
    end
  except
    begin
      {if it fails, assume that none of the SSE instruction sets are available}
      Exclude(CPUInfo.InstructionSupport, cisSSE);
      Exclude(CPUInfo.InstructionSupport, cisSSE2);
      Exclude(CPUInfo.InstructionSupport, cisSSE3);
      Exclude(CPUInfo.InstructionSupport, cisSSSE3);
    end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,787; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure GetInstructionSupportString;
var
  Feature: TCPUInstructionSupport;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,788 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  CPUInfo.InstructionSupportString := '';
  for Feature in CPUInfo.InstructionSupport do
  begin
    CPUInfo.InstructionSupportString := CPUInfo.InstructionSupportString + ' ' + FeatureStringIdents[Feature];
  end;
  if CPUInfo.InstructionSupportString = '' then
  begin
    CPUInfo.InstructionSupportString := 'None';
  end else
  begin
    Delete(CPUInfo.InstructionSupportString, 1, 1);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,788; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure GetCPUInfo;
var
  Registers: TRegisters;
  MaxCPUID: Longword;
  MaxExCPUID: Longword;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,789 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  {initialize - just to be sure}
  FillChar(CPUInfo, SizeOf(CPUInfo), 0);

  try
    if not IsCPUID_Available then
    begin
      if IsFPU_Available then
      begin
        Include(CPUInfo.InstructionSupport, cisFPU);
      end;
    end else
    begin
      {get maximum CPUID input value}
      GetCPUID($00000000, Registers);
      MaxCPUID := Registers.EAX;

      {get CPU vendor - Max CPUID will always be >= 0}
      GetCPUVendor;

      {get CPU features if available}
      if MaxCPUID >= $00000001 then
        GetCPUFeatures;

      {get cache info if available}
      if MaxCPUID >= $00000002 then
        GetProcessorCacheInfo;

      {get maximum extended CPUID input value}
      GetCPUID($80000000, Registers);
      MaxExCPUID := Registers.EAX;

      {get CPU extended features if available}
      if MaxExCPUID >= $80000001 then
        GetCPUExtendedFeatures;

      {verify operating system support for XMM registers}
      if cisSSE in CPUInfo.InstructionSupport then
        VerifyOSSupportForXMMRegisters;

      {get extended cache features if available}
      {Note: ignore processors that only report L1 cache info,
             i.e. have a MaxExCPUID = $80000005}
      if MaxExCPUID >= $80000006 then
        GetExtendedProcessorCacheInfo;
    end;

    GetInstructionSupportString;
  except
      {silent exception - should not occur, just ignore}
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,789; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure GetWindowsInfo(var Info: TWindowsInfo);
var
  TrimmedWin32CSDVersion: string;
  OSVersionInfoEx: TOSVersionInfoEx;
const
  SM_SERVERR2 = 89;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,790 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  FillChar(OSVersionInfoEx, SizeOf(OSVersionInfoEx), 0);
  OSVersionInfoEx.dwOSVersionInfoSize := SizeOf(OSVersionInfoEx);
  GetVersionEx(@OSVersionInfoEx);
  Info.Version := wvUnknown;
  Info.SP := 0;
  TrimmedWin32CSDVersion := Trim(OSVersionInfoEx.szCSDVersion);
  case OSVersionInfoEx.dwPlatformId of
    VER_PLATFORM_WIN32_WINDOWS:
      case OSVersionInfoEx.dwMinorVersion of
        0..9:
          if (TrimmedWin32CSDVersion = 'B') or (TrimmedWin32CSDVersion = 'C') then
            Info.Version := wvWin95OSR2
          else
            Info.Version := wvWin95;
        10..89:
          if TrimmedWin32CSDVersion = 'A' then
            Info.Version := wvWin98SE
          else
            Info.Version := wvWin98;
        90:
          Info.Version := wvWinME;
      end;
    VER_PLATFORM_WIN32_NT:
      case OSVersionInfoEx.dwMajorVersion of
        3:
          case OSVersionInfoEx.dwMinorVersion of
            1:
              Info.Version := wvWinNT31;
            5:
              Info.Version := wvWinNT35;
            51:
              Info.Version := wvWinNT351;
          end;
        4:
          Info.Version := wvWinNT4;
        5:
        begin
          Info.SP := OSVersionInfoEx.wServicePackMajor;
          case OSVersionInfoEx.dwMinorVersion of
            0:
              Info.Version := wvWin2000;
            1:
              Info.Version := wvWinXP;
            2:
              begin
                OSVersionInfoEx.dwOSVersionInfoSize := SizeOf(OSVersionInfoEx);
                if GetSystemMetrics(SM_SERVERR2) <> 0 then
                  Info.Version := wvWin2003R2
                else if OSVersionInfoEx.wProductType = $0000001 then
                  Info.Version := wvWinXP64
                else
                  Info.Version := wvWin2003;
              end;
          end;
        end;
        6:
        begin
          Info.SP := OSVersionInfoEx.wServicePackMajor;
          if OSVersionInfoEx.dwMinorVersion = 0 then
          begin
            OSVersionInfoEx.dwOSVersionInfoSize := SizeOf(OSVersionInfoEx);
            if GetVersionEx(@OSVersionInfoEx) and (OSVersionInfoEx.wProductType = $0000001) then
              Info.Version := wvWinVista
            else
              Info.Version := wvWinLonghorn;
          end;
        end;
      end;
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,790; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

function GetWindowsVersionString: string;
var
  InfoEx: TOSVersionInfoEx;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,791 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  InfoEx.dwOSVersionInfoSize := SizeOf(InfoEx);
  GetVersionEx(@InfoEx);
  case WindowsInfo.Version of
    wvWin95:
      Result := OSVersionWin95;
    wvWin95OSR2:
      Result := OSVersionWin95OSR2;
    wvWin98:
      Result := OSVersionWin98;
    wvWin98SE:
      Result := OSVersionWin98SE;
    wvWinME:
      Result := OSVersionWinME;
    wvWinNT31, wvWinNT35, wvWinNT351:
      Result := Format(OSVersionWinNT3, [InfoEx.dwMinorVersion]);
    wvWinNT4:
      Result := Format(OSVersionWinNT4, [InfoEx.dwMinorVersion]);
    wvWin2000:
      Result := OSVersionWin2000;
    wvWinXP:
      Result := OSVersionWinXP;
    wvWin2003:
      Result := OSVersionWin2003;
    wvWin2003R2:
      Result := OSVersionWin2003R2;
    wvWinXP64:
      Result := OSVersionWinXP64;
    wvWinLonghorn:
      Result := OSVersionWinLonghorn;
    wvWinVista:
      Result := OSVersionWinVista;
  else
    Result := OSVersionUnk;
  end;

  if WindowsInfo.SP > 0 then
  begin
    Result := Result + ' ' + Format(OSServicePack, [WindowsInfo.SP]);
  end;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,791; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

procedure FillSystemInfo;
var
  SysInfo: TSystemInfo;
  KernelHandle: HMODULE;
  IsWow64Process: function(hProcess: THandle; Wow64Process: PBOOL): BOOL; stdcall;
  GetNativeSystemInfo: procedure(lpSystemInfo: PSystemInfo); stdcall;
  Is32on64: Boolean;
begin
{$IFDEF PROFILE}asm DW 310FH; call Profint.ProfStop; end; Try; asm mov edx,792 or $7D9E0000; xor eax,eax; call Profint.ProfEnter; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; {$ENDIF}
  KernelHandle := SafeLoadLibrary(kernel32);
  @IsWow64Process := GetProcAddress(KernelHandle, 'IsWow64Process');
  if Assigned(IsWow64Process) and
     IsWow64Process(GetCurrentProcess, @Is32on64) and
     Is32on64 then
  begin
    @GetNativeSystemInfo := GetProcAddress(KernelHandle, 'GetNativeSystemInfo');
    GetNativeSystemInfo(@SysInfo);
  end else
  begin
    GetSystemInfo(@SysInfo);
  end;
  ProcessorCount := SysInfo.dwNumberOfProcessors;
  PageSize := SysInfo.dwPageSize;
  GetWindowsInfo(WindowsInfo);
  OSName := GetWindowsVersionString;
  FreeLibrary(KernelHandle);
  GetCPUInfo;
{$IFDEF PROFILE}finally; asm DW 310FH; mov ecx,792; call Profint.ProfExit; mov ecx,eax; DW 310FH; add[ecx].0,eax; adc[ecx].4,edx; end; end; {$ENDIF}
end;

initialization
  FillSystemInfo;

end.
