{*------------------------------------------------------------------------------
  Logging Support Classes
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Framework.LogManager;

interface

uses
  API.Win.Types,
  API.Win.Kernel,
  API.Win.User,
  API.Win.CommCtrl,
  Framework.Base,
  Framework.ThreadManager,
  SysUtils,
  Misc.Miscleanous,
  Misc.Containers,
  Classes,
  Misc.Threads;

type
  TLogManager = class;
  TLogHandle = class;
  TLogHandleClass = class of TLogHandle;

  {$Z4}
  YLoggingMode = (lmAsync, lmSync);
  {$Z1}

  TLogHandle = class(THandleBase)
    private
      fOwner: TLogManager;
      fName: string;
      fMaximumSize: Int64;
      fMode: YLoggingMode;
      fFlushLimit: Int32;
      fLock: TCriticalSection;
      fReference: Int32;

      function Reference: Int32; inline;
      function Unreference: Int32; inline;
    protected
      procedure SetFlushLimit(Limit: Int32); virtual; 
      function FormatSeverity(Severity: Int32): string; virtual;

      procedure Close; virtual;

      procedure Lock; inline;
      procedure Unlock; inline;
    public
      constructor Create; override;
      destructor Destroy; override;

      procedure Open; virtual; 

      procedure Write(const Text: string; Severity: Int32 = -1); virtual; abstract;
      procedure WriteFmt(const Text: string; const Args: array of const; Severity: Int32 = -1);
      procedure WriteRes(ResStringRec: PResStringRec; Severity: Int32 = -1);
      procedure WriteResFmt(ResStringRec: PResStringRec; const Args: array of const; Severity: Int32 = -1);

      procedure Flush; virtual; abstract;

      property Name: string read fName;
      property LoggingMode: YLoggingMode read fMode write fMode;
      property FlushLimit: Int32 read fFlushLimit write SetFlushLimit;
  end;

  TTextLogHandle = class(TLogHandle)
    private
      fStringStream: TStringStream;
      fFileStream: TFileStream;
      fLastFlush: Int64;
    protected
      procedure DoWrite(const Text: string; Severity: Int32);
      procedure Close; override;
    public
      constructor Create; override;

      procedure Write(const Text: string; Severity: Int32 = -1); override;

      procedure Open; override;

      procedure Flush; override;
  end;

  TGuiLogHandle = class(TLogHandle)
    private
      class var fWndClassRegistered: Boolean;

      fFirstWrite: Longbool;
    protected
      fWindow: HWND;
      fTreeView: HWND;
      fImgList: HIMAGELIST;

      procedure Close; override;

      procedure DoWrite(const Text: string; Severity: Int32);

      procedure UpdateLog(Text: PChar; Severity: Int32); virtual;
      procedure ClearLog; virtual;
      procedure CreateLogWindow; virtual;

      function WndProc(Msg: Longword; WParam: Longword; LParam: Longword): Longword;

      procedure SetVisible(Value: Boolean); inline;
    public
      constructor Create; override;

      procedure Open; override;

      procedure Write(const Text: string; Severity: Int32 = -1); override;

      procedure Flush; override;

      property Visible: Boolean write SetVisible;
  end;

  TLogAsyncWriteMethod = procedure(const Data: string; Severity: Int32) of object;
  TLogWndCreationMethod = procedure of object;

  TLogManager = class(TBaseObject)
    private
      fLogs: TStrHashMap;
      fLock: TCriticalSection;
      fThread: TThreadHandle;
      fMsgThread: TThreadHandle;
      fWakeUpEvent: TEvent;
      fAsyncRequestQueue: TPtrQueue;
      fWndCreationRequestQueue: TPtrQueue;

      function GetLogCount: Int32;

      procedure EnqueueRequest(Log: TLogHandle; Method: TLogAsyncWriteMethod; const Data: string;
        Severity: Int32);
      procedure EnqueueWndConstruction(Log: TLogHandle; Method: TLogWndCreationMethod);
      procedure ProcessAsyncRequests(Thread: TThreadHandle);
      procedure ProcessGuiMessages(Thread: TThreadHandle);
      procedure SpawnAsyncProcessingThread;
      procedure SpawnMsgProcessingThread;

      procedure Lock; inline;
      procedure Unlock; inline;
    public
      constructor Create;
      destructor Destroy; override;

      function CreateLog(const Name: string; MaximumSize: Int64 = -1;
        LoggingMode: YLoggingMode = lmSync; FlushLimit: Int32 = 0): TLogHandle;

      function CreateLogEx(const Name: string; HandleClass: TLogHandleClass;
        MaximumSize: Int64 = -1; LoggingMode: YLoggingMode = lmSync;
        FlushLimit: Int32 = 0): TLogHandle;

      function OpenLog(const Name: string; OpenAlways: Boolean): TLogHandle;
      
      function OpenLogEx(const Name: string; OpenAlways: Boolean;
        HandleClass: TLogHandleClass): TLogHandle;

      procedure CloseLog(Handle: TLogHandle);

      property LogCount: Int32 read GetLogCount;
  end;

implementation

uses
  Framework;

type
  PAsyncWriteRequest = ^TAsyncWriteRequest;
  TAsyncWriteRequest = record
    Log: TLogHandle;
    Data: string;
    Severity: Int32;
    Method: TLogAsyncWriteMethod;
  end;

  PWndCreationRequest = ^TWndCreationRequest;
  TWndCreationRequest = record
    Log: TLogHandle;
    Method: TLogWndCreationMethod;
  end;

{ TLogManager }

constructor TLogManager.Create;
begin
  inherited Create;
  fLock.Init;
  fLogs := TStrHashMap.Create(False, 64, False);
  fAsyncRequestQueue := TPtrQueue.Create(1024);
  fWndCreationRequestQueue := TPtrQueue.Create;
  fWakeUpEvent.Init(False, False);
end;

destructor TLogManager.Destroy;
var
  ifItr: IIterator;
  cLog: TLogHandle;
begin
  if fThread <> nil then
  begin
    fThread.Terminate;
    fWakeUpEvent.Signal;
    fThread.WaitForEnd(-1);
  end;
  
  if fMsgThread <> nil then
  begin
    PostThreadMessage(fMsgThread.ThreadId, 0, 0, 0);
    fMsgThread.WaitForEnd(-1);
  end;

  ifItr := fLogs.Values;
  while ifItr.HasNext do
  begin
    cLog := TLogHandle(ifItr.Next);
    CloseLog(cLog);
  end;

  fWakeUpEvent.Delete;
  fWndCreationRequestQueue.Free;
  fAsyncRequestQueue.Free;
  fLogs.Free;
  fLock.Delete;
  inherited Destroy;
end;

function TLogManager.CreateLog(const Name: string;
  MaximumSize: Int64; LoggingMode: YLoggingMode; FlushLimit: Int32): TLogHandle;
begin
  Result := CreateLogEx(Name, TTextLogHandle, MaximumSize, LoggingMode, FlushLimit);
end;

function TLogManager.CreateLogEx(const Name: string;
  HandleClass: TLogHandleClass; MaximumSize: Int64; LoggingMode: YLoggingMode;
  FlushLimit: Int32): TLogHandle;
var
  cOldLog: TLogHandle;
begin
  if HandleClass = TLogHandle then
  begin
    raise EInvalidArgument.Create('Unable to create logging handle - YLogHandle class is abstract!');
  end;
  
  Lock;
  try
    cOldLog := TLogHandle(fLogs.Remove(Name));
    if cOldLog <> nil then
    begin
      cOldLog.fReference := 1;
      cOldLog.Free;
    end;

    Result := HandleClass.Create;
    Result.fOwner := Self;
    Result.fName := Name;
    Result.fMaximumSize := MaximumSize;
    Result.fMode := LoggingMode;
    Result.fFlushLimit := FlushLimit;

    fLogs.PutValue(Name, Result);
  finally
    Unlock;
  end;
end;

function TLogManager.OpenLog(const Name: string; OpenAlways: Boolean): TLogHandle;
begin
  Result := OpenLogEx(Name, OpenAlways, TTextLogHandle);
end;

function TLogManager.OpenLogEx(const Name: string; OpenAlways: Boolean;
  HandleClass: TLogHandleClass): TLogHandle;
begin
  Lock;
  try
    Result := TLogHandle(fLogs.GetValue(Name));
    if Result = nil then
    begin
      if OpenAlways then
      begin
        Result := CreateLogEx(Name, HandleClass);
        Result.Open;
      end;
    end else
    begin
      Result.Reference;
    end;
  finally
    Unlock;
  end;
end;

procedure TLogManager.CloseLog(Handle: TLogHandle);
begin
  if Handle = nil then Exit;

  Handle.fReference := 1;
  Handle.Free;
end;

procedure TLogManager.EnqueueRequest(Log: TLogHandle; Method: TLogAsyncWriteMethod; const Data: string;
  Severity: Int32);
var
  pReq: PAsyncWriteRequest;
begin
  Log.Reference;

  New(pReq);
  pReq^.Log := Log;
  pReq^.Data := Data;
  pReq^.Severity := Severity;
  pReq^.Method := Method;
  
  fLock.Enter;
  try
    fAsyncRequestQueue.Enqueue(pReq);
    if fThread = nil then
    begin
      SpawnAsyncProcessingThread;
    end else if fAsyncRequestQueue.Size = 1 then
    begin
      fWakeUpEvent.Signal;
    end;
  finally
    fLock.Leave;
  end;
end;

procedure TLogManager.EnqueueWndConstruction(Log: TLogHandle; Method: TLogWndCreationMethod);
var
  pReq: PWndCreationRequest;
begin
  Log.Reference;
  New(pReq);
  pReq^.Log := Log;
  pReq^.Method := Method;

  fLock.Enter;
  try
    fWndCreationRequestQueue.Enqueue(pReq);
    if fMsgThread = nil then
    begin
      SpawnMsgProcessingThread;
    end;
  finally
    fLock.Leave;
  end;
end;

procedure TLogManager.ProcessAsyncRequests(Thread: TThreadHandle);
var
  pReq: PAsyncWriteRequest;
label
  __Restart;
begin
  __Restart:
  fLock.Enter;
  try
    while not fAsyncRequestQueue.Empty do
    begin
      pReq := fAsyncRequestQueue.Dequeue;
      pReq^.Method(pReq^.Data, pReq^.Severity);
      pReq^.Log.Unreference;
      Dispose(pReq);
    end;
  finally
    fLock.Leave;
  end;

  fWakeUpEvent.WaitFor(-1);
  if Thread.Terminated then goto __Restart;
end;

procedure TLogManager.ProcessGuiMessages(Thread: TThreadHandle);
var
  pReq: PWndCreationRequest;
  tMessage: TMsg;
begin
  FillChar(tMessage, SizeOf(tMessage), 0);
  while not Thread.Terminated do
  begin
    fLock.Enter;
    try
      while not fWndCreationRequestQueue.Empty do
      begin
        pReq := fWndCreationRequestQueue.Dequeue;
        pReq^.Method;
        pReq^.Log.Unreference;
        Dispose(pReq);
      end;
    finally
      fLock.Leave;
    end;
    if GetMessage(@tMessage, 0, 0, 0) then
    begin
      TranslateMessage(@tMessage);
      DispatchMessage(@tMessage);
    end;
  end;
end;

procedure TLogManager.SpawnAsyncProcessingThread;
begin
  fThread := SystemThreadManager.CreateThread(ProcessAsyncRequests, False,
    'Log_Manager_Async_Processor', True);
  fThread.Priority := tpHigher;
end;

procedure TLogManager.SpawnMsgProcessingThread;
begin
  fMsgThread := SystemThreadManager.CreateThread(ProcessGuiMessages, False,
    'Log_Manager_Msg_Processor', True);
  fMsgThread.Priority := tpHigher;
end;

function TLogManager.GetLogCount: Int32;
begin
  Result := fLogs.Size;
end;

procedure TLogManager.Lock;
begin
  fLock.Enter;
end;

procedure TLogManager.Unlock;
begin
  fLock.Leave;
end;

{ TLogHandle }

constructor TLogHandle.Create;
begin
  inherited Create;
  Reference;
  fLock.Init;
end;

destructor TLogHandle.Destroy;
begin
  if Unreference <= 0 then
  begin
    Close;
    fOwner.fLogs.Remove(fName);
    fLock.Delete;
    inherited Destroy;
  end;
end;

function TLogHandle.Reference: Int32;
begin
  Result := Int32(AtomicInc(@fReference));
end;

function TLogHandle.Unreference: Int32;
begin
  Result := Int32(AtomicDec(@fReference));
end;

function TLogHandle.FormatSeverity(Severity: Int32): string;
begin
  case Severity of
    0: Result := 'INFO';
    1: Result := 'WARNING';
    2: Result := 'ERROR';
  else
    Result := 'UNDEFINED';
  end;
end;

procedure TLogHandle.Lock;
begin
  fLock.Enter;
end;

procedure TLogHandle.Unlock;
begin
  fLock.Leave;
end;

procedure TLogHandle.Open;
begin

end;

procedure TLogHandle.Close;
begin
  Flush;
end;

procedure TLogHandle.WriteFmt(const Text: string; const Args: array of const;
  Severity: Int32);
begin
  Write(Format(Text, Args), Severity);
end;

procedure TLogHandle.WriteRes(ResStringRec: PResStringRec; Severity: Int32);
begin
  Write(LoadResString(ResStringRec), Severity);
end;

procedure TLogHandle.WriteResFmt(ResStringRec: PResStringRec;
  const Args: array of const; Severity: Int32);
begin
  Write(Format(LoadResString(ResStringRec), Args), Severity);
end;

procedure TLogHandle.SetFlushLimit(Limit: Int32);
begin
  Lock;
  try
    fFlushLimit := Limit;
  finally
    Unlock;
  end;
end;

{ TTextLogHandle }

procedure TTextLogHandle.Close;
begin
  inherited Close;
  fStringStream.Free;
  fFileStream.Free;
end;

constructor TTextLogHandle.Create;
begin
  inherited Create;
  fStringStream := TStringStream.Create('');
end;

procedure TTextLogHandle.Flush;
var
  iTmp: Int64;
begin
  fFileStream.Position := 0;
  iTmp := fStringStream.Position;
  fStringStream.Position := 0;
  fFileStream.CopyFrom(fStringStream, fStringStream.Size);
  fStringStream.Position := iTmp;
end;

procedure TTextLogHandle.Open;
begin
  fFileStream := TFileStream.Create(fName, fmCreate);
end;

procedure TTextLogHandle.DoWrite(const Text: string; Severity: Int32);
begin
  Lock;
  try
    if Severity > -1 then
    begin
      fStringStream.WriteString(FormatSeverity(Severity) + ' - ');
    end;
    fStringStream.WriteString(Text);
    fStringStream.WriteString(#13#10);
    if fStringStream.Position - fLastFlush >= fFlushLimit then
    begin
      fLastFlush := fStringStream.Position;
      Flush;
    end;
  finally
    Unlock;
  end;
end;

procedure TTextLogHandle.Write(const Text: string; Severity: Int32);
begin
  if fMode = lmSync then
  begin
    DoWrite(Text, Severity);
  end else
  begin
    fOwner.EnqueueRequest(Self, DoWrite, Text, Severity);
  end;
end;

{ TGuiLogHandle }

function GuiWndProc(Window: HWND; Msg, WParam, LParam: Longword): LRESULT; stdcall;
var
  cLogger: TGuiLogHandle;
begin
  cLogger := TGuiLogHandle(GetWindowLong(Window, GWL_USERDATA));
  if cLogger <> nil then
  begin
    Result := cLogger.WndProc(Msg, WParam, LParam);
  end else Result := DefWindowProc(Window, Msg, WParam, LParam);
end;

const
  WM_CUSTOM_START    = WM_USER + $1000;
  
  WM_LOGAPPEND       = WM_CUSTOM_START;
  WM_LOGCLEAR        = WM_CUSTOM_START + 1;

var
  GuiLogClass: TWndClass = (
    style: CS_HREDRAW or CS_VREDRAW or CS_NOCLOSE;
    lpfnWndProc: @GuiWndProc;
    cbClsExtra: 0;
    cbWndExtra: 0;
    hInstance: 0;
    hIcon: 0;
    hCursor: 0;
    hbrBackground: HBRUSH(COLOR_BACKGROUND + 5);
    lpszMenuName: nil;
    lpszClassName: 'YGuiLoggerWindow';
  );

constructor TGuiLogHandle.Create;
var
  tICC: TInitCommonControlsEx;
begin
  inherited Create;

  if AtomicExchange(@fWndClassRegistered, 1) = 0 then
  begin
    tICC.dwICC := ICC_TREEVIEW_CLASSES;
    tICC.dwSize := SizeOf(tICC);
    InitCommonControlsEx(tICC);
    
    GuiLogClass.hIcon := LoadImage(0, IDI_INFORMATION, IMAGE_ICON, 0, 0,
      LR_DEFAULTCOLOR or LR_DEFAULTSIZE or LR_SHARED);

    GuiLogClass.hCursor := LoadImage(0, IDC_ARROW, IMAGE_CURSOR, 0, 0,
      LR_DEFAULTCOLOR or LR_DEFAULTSIZE or LR_SHARED);
      
    API.Win.User.RegisterClass(GuiLogClass);
  end;
  
  fFirstWrite := True;
end;

procedure TGuiLogHandle.Open;
begin
  inherited Open;
  if fMaximumSize = -1 then fMaximumSize := MAXINT;
  if fReference = 1 then
  begin
    fOwner.EnqueueWndConstruction(Self, CreateLogWindow);
  end;
end;

procedure TGuiLogHandle.Close;
begin
  if (fWindow <> 0) and (fWindow <> INVALID_HANDLE_VALUE) then
  begin
    DestroyWindow(fWindow);
  end;

  if (fImgList <> 0) and (fImgList <> INVALID_HANDLE_VALUE) then
  begin
    ImageList_Destroy(fImgList);
  end;
  inherited Close;
end;

procedure TGuiLogHandle.Flush;
begin
  PostMessage(fWindow, WM_LOGCLEAR, 0, 0);
end;

procedure TGuiLogHandle.DoWrite(const Text: string; Severity: Int32);
var
  pSz: PChar;
  cList: TStringList;
  iI: Int32;
begin
  if AtomicExchange(@fFirstWrite, 0) <> 0 then
  begin
    Lock;
    try
      ShowWindowAsync(fWindow, SW_SHOWNOACTIVATE);
      UpdateWindow(fWindow);
    finally
      Unlock;
    end;
  end;

  cList := TStringList.Create;
  try
    cList.SetText(PChar(Text));
    for iI := 0 to cList.Count -1 do
    begin
      GetMem(pSz, Length(cList[iI]) + 1);
      StrPCopy(pSz, cList[iI]);
      PostMessage(fWindow, WM_LOGAPPEND, WPARAM(pSz), LPARAM(Severity));
    end;
  finally
    cList.Free;
  end;
end;

procedure TGuiLogHandle.Write(const Text: string; Severity: Int32 = -1);
begin
  fOwner.EnqueueRequest(Self, DoWrite, Text, Severity);
end;

procedure TGuiLogHandle.SetVisible(Value: Boolean);
begin
  if Value then ShowWindowAsync(fWindow, SW_SHOW) else ShowWindowAsync(fWindow, SW_HIDE);
end;

procedure TGuiLogHandle.CreateLogWindow;
begin
  fImgList := ImageList_Create(16, 16, ILC_COLOR or ILC_MASK, 1, 1);

  ImageList_AddIcon(fImgList, LoadImage(0, IDI_INFORMATION, IMAGE_ICON, 0, 0,
    LR_DEFAULTCOLOR or LR_DEFAULTSIZE or LR_SHARED));

  ImageList_AddIcon(fImgList, LoadImage(0, IDI_EXCLAMATION, IMAGE_ICON, 0, 0,
    LR_DEFAULTCOLOR or LR_DEFAULTSIZE or LR_SHARED));

  ImageList_AddIcon(fImgList, LoadImage(0, IDI_ERROR, IMAGE_ICON, 0, 0,
    LR_DEFAULTCOLOR or LR_DEFAULTSIZE or LR_SHARED));

  fWindow := CreateWindowEx(WS_EX_CONTROLPARENT or WS_EX_OVERLAPPEDWINDOW or WS_EX_APPWINDOW,
    GuiLogClass.lpszClassName, PChar(fName), WS_CAPTION or WS_THICKFRAME or WS_HSCROLL or
    WS_CLIPCHILDREN, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, 600, 400, 0, 0, nil);
  if (fWindow = 0) or (fWindow = INVALID_HANDLE_VALUE) then
  begin
    MessageBox(0, 'Error at window process creation - unable to create parent window!', 'Error', MB_OK);
  end;

  SetWindowLong(fWindow, GWL_USERDATA, Longword(Self));

  fTreeView := CreateWindowEx(0, WC_TREEVIEW, nil, WS_CHILD or WS_VISIBLE or
    WS_BORDER or WS_HSCROLL or WS_VSCROLL or ES_MULTILINE or ES_AUTOHSCROLL or ES_AUTOVSCROLL or ES_READONLY,
    0, 0, 0, 0, fWindow, 0, GetWindowLong(fWindow, GWL_HINSTANCE), nil);
  if (fTreeView = 0) or (fTreeView = INVALID_HANDLE_VALUE) then
  begin
    MessageBox(0, 'Error at window process creation - unable to create tree edit control!', 'Error', MB_OK);
  end;

  TreeView_SetImageList(fTreeView, fImgList, TVSIL_NORMAL);
  UpdateWindow(fWindow);
end;

procedure TGuiLogHandle.UpdateLog(Text: PChar; Severity: Int32);
var
  tMainItem: TTVInsertStruct;
begin
  Lock;
  try
    if TreeView_GetCount(fTreeView) >= fMaximumSize then
    begin
      TreeView_DeleteItem(fTreeView, TreeView_GetRoot(fTreeView));
    end;

    if Severity < 0 then Severity := 0 else
    if Severity > 2 then Severity := 2;

    FillChar(tMainItem, SizeOf(tMainItem), 0);
    tMainItem.hInsertAfter := TVI_LAST;

    tMainItem.itemex.mask := TVIF_TEXT or TVIF_IMAGE or TVIF_SELECTEDIMAGE;
    tMainItem.itemex.stateMask := $FFFFFFFF;
    tMainItem.itemex.iImage := Severity;
    tMainItem.itemex.iSelectedImage := Severity;
    tMainItem.itemex.pszText := Text;
    tMainItem.itemex.cchTextMax := StrLen(Text);

    TreeView_InsertItem(fTreeView, tMainItem);
  finally
    FreeMem(Text);
    Unlock;
  end;
end;

procedure TGuiLogHandle.ClearLog;
begin
  Lock;
  try
    TreeView_DeleteAllItems(fTreeView);
  finally
    Unlock;
  end;
end;

function TGuiLogHandle.WndProc(Msg, WParam, LParam: Longword): Longword;
begin
  case Msg of
    WM_LOGAPPEND:
    begin
      UpdateLog(PChar(WParam), Int32(LParam));
      Result := 0;
    end;
    WM_LOGCLEAR:
    begin
      ClearLog;
      Result := 0;
    end;
    WM_SETFOCUS:
    begin
      UpdateWindow(fWindow);
      SetFocus(fWindow);
      Result := 1;
    end;
    WM_SIZE:
    begin
      MoveWindow(fTreeView, 0, 0, LParam and $FFFF, LParam shr 16, True);
      Result := 0;
    end;
    WM_DESTROY:
    begin
      Result := 0;
    end;
    WM_QUIT:
    begin
      PostQuitMessage(0);
      Result := 1;
    end;
    WM_CLOSE:
    begin
      Result := 0;
    end;
  else
    Result := DefWindowProc(fWindow, Msg, WParam, LParam);
  end;
end;

end.
