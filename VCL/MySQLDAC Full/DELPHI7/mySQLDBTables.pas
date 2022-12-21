{$I mysqldac.inc}
unit mySQLDbTables;

{$R-,T-,H+,X+}
Interface

Uses  Windows, SysUtils, Graphics, Classes, Controls, Db, DBCommon,  mySQLAccess, SMIntf,
      {$IFDEF DELPHI_6}Variants,{$ENDIF} mySQLTypes,mySQLCP,uMyDMCT;
      
const
    VERSION = '2.4.0 (9911)';

{ TDBDataSet flags }          
  dbfOpened     = 0;
  dbfPrepared   = 1;
  dbfExecSQL    = 2;
  dbfTable      = 3;
  dbfFieldList  = 4;
  dbfIndexList  = 5;
  dbfStoredProc = 6;
  dbfExecProc   = 7;
  dbfProcDesc   = 8;
  dbfDatabase   = 9;
  dbfProvider   = 10;

{ FieldType Mappings }

const
  FldTypeMap: TFieldMap = (
    fldUNKNOWN, fldZSTRING, fldINT16, fldINT32, fldUINT16, fldBOOL,
    fldFLOAT, fldFLOAT, fldBCD, fldDATE, fldTIME, fldTIMESTAMP, fldBYTES,
    fldVARBYTES, fldINT32, fldBLOB, fldBLOB, fldBLOB, fldBLOB, fldBLOB,
    fldBLOB, fldBLOB, fldCURSOR, fldZSTRING, fldZSTRING, fldINT64, fldADT,
    fldArray, fldREF, fldTABLE, fldBLOB, fldBLOB, fldUNKNOWN, fldUNKNOWN,
    fldUNKNOWN, fldZSTRING{$IFDEF DELPHI_6}, fldDATETIME,fldBCD{$ENDIF});

  FldSubTypeMap: array[TFieldType] of Word = (
    0, 0, 0, 0, 0, 0, 0, fldstMONEY, 0, 0, 0, 0, 0, 0, fldstAUTOINC,
    fldstBINARY, fldstMEMO, fldstGRAPHIC, fldstFMTMEMO, fldstOLEOBJ,
    fldstDBSOLEOBJ, fldstTYPEDBINARY, 0, fldstFIXED, fldstUNICODE,
    0, 0, 0, 0, 0, fldstHBINARY, fldstHMEMO, 0, 0, 0, 0{$IFDEF DELPHI_6} , 0, 0{$ENDIF});

  DataTypeMap: array[0..MAXLOGFLDTYPES - 1] of TFieldType = (
    ftUnknown, ftString, ftDate, ftBlob, ftBoolean, ftSmallint,
    ftInteger, ftFloat, ftBCD, ftBytes, ftTime, ftDateTime,
    ftWord, ftInteger, ftUnknown, ftVarBytes, ftUnknown, ftUnknown,
    ftLargeInt, ftLargeInt, ftADT, ftArray, ftReference, ftDataSet
    {$IFDEF DELPHI_6},ftTimeStamp{$ENDIF});

  BlobTypeMap: array[fldstMEMO..fldstBFILE] of TFieldType = (
    ftMemo, ftBlob, ftFmtMemo, ftParadoxOle, ftGraphic, ftDBaseOle,
    ftTypedBinary, ftBlob, ftBlob, ftBlob, ftBlob, ftOraClob, ftOraBlob,
    ftBlob, ftBlob);
    
type
  TmySQLDACAbout = Class
  end;


  { Forward declarations }
  TmySQLDatabase      = Class;
  TmySQLParams        = TParams;
  TmySQLParam         = TParam;
  TmySQLDatabaseClass = Class of TmySQLDatabase;
  TmySQLDataSet       = Class;
  TmySQLTable         = Class;
  TmySQLTableClass    = Class of TmySQLTable;
  TmySQLQuery         = Class;
  TmySQLQueryClass    = Class of TmySQLQuery;

  { Exception Classes }
  EmySQLDatabaseError =  Class(EDatabaseError)
    Private
      FErrorCode: Word;
    Public
      constructor Create(Engine : TmySQLEngine; ErrorCode: Word);
      destructor Destroy; Override;
      property ErrorCode: Word read FErrorCode;
  end;

  ENoResultSet = class(EDatabaseError);

  TDBFlags = set of 0..15;

  TTransIsolation = (tiDirtyRead, tiReadCommitted, tiRepeatableRead);
  
  TBaseDatabaseLoginEvent = Procedure(Database: TmySQLDatabase; LoginParams: TStrings) of object;

  TConnectionFailureEvent = procedure(Connection : TMySQLDatabase; Error : String) of Object;

  TmySQLDatabase =  Class(TCustomConnection)
  Private
      FAbout   : TmySQLDACAbout;
      FTransIsolation: TTransIsolation;
      FKeepConnection: Boolean; //AutoStop

      FDatabaseName: String; //DatabaseName
      FUserName : String; //Username
      FUserPassword : String; //UserPassword
      FPort : Cardinal; //Port
      FHost : String;
      FConnectOptions : TConnectOptions;
      FEngine : TmySQLEngine; //SQL Engine
      FTemporary: Boolean;
      FAcquiredHandle: Boolean;
      FPseudoIndexes: Boolean;
      FHandleShared: Boolean;
      FExclusive: Boolean;
      FReadOnly: Boolean;
      FRefCount: Integer;
      FHandle: HDBIDB;
      FParams: TStrings;
      FStmtList: TList;
      FOnLogin: TBaseDatabaseLoginEvent;
      FOnConnectionFailure : TConnectionFailureEvent;
      FTimeOut : Cardinal;
      FMT: boolean;
      FSSL_Key  : String;
      FSSL_Cert : String;
      FCheckIfActiveOnParamChange: boolean;   // ptook
      Procedure CheckActive;
      Procedure CheckInactive;
      Procedure CheckDatabase(var Password: String);
      Procedure ClearStatements;
      Procedure EndTransaction(TransEnd: EXEnd);
      Function GetInTransaction: Boolean;
      Procedure Login(LoginParams: TStrings);
      Procedure ParamsChanging(Sender: TObject);
      Procedure SetDatabaseFlags;
      Procedure SetDatabaseName(const Value: String);
      Procedure SetUserName(const Value: String);
      Procedure SetUserPassword(const Value: String);
      Procedure SetServerPort(const Value: Cardinal);
      procedure SetMT( const Value : Boolean);
      procedure SetHost(const Value : String);
      Procedure SetKeepConnection(Value: Boolean);
      procedure SetTimeOut(const Value : Cardinal);
      Procedure SetExclusive(Value: Boolean);
      Procedure SetHandle(Value: HDBIDB);
      procedure SetParams(Value: TStrings);
      Procedure SetReadOnly(Value: Boolean);
      Procedure SetSSLKey(const Value : String);
      Procedure SetSSLCert(const Value : String);
    Protected
      Procedure CloseDatabaseHandle;
      procedure CloseDatabase;
      Procedure DoConnect; override;
      Procedure DoDisconnect; override;
      Function GetConnected: Boolean; override;
      Function GetDataSet(Index: Integer): TmySQLDataSet; reintroduce;
      Procedure Loaded; Override;
      Procedure Notification(AComponent: TComponent; Operation: TOperation); Override;
      Procedure InitEngine; //Init SQL Engine
      Procedure AddDatabase(Value : TmySQLDatabase);
      Procedure RemoveDatabase(Value : TmySQLDatabase);
      property CheckIfActiveOnParamChange: boolean read FCheckIfActiveOnParamChange write FCheckIfActiveOnParamChange;    // ptook
    Public
      constructor Create(AOwner: TComponent); Override;
      destructor Destroy; Override;
      Function  Engine : TmySQLEngine;
      Procedure ApplyUpdates(const DataSets: array of TmySQLDataSet);
      Procedure CloseDataSets;
      Function Execute(const SQL: string; Params: TParams = nil; Cache: Boolean = FALSE): Integer;
      Procedure Commit;
      Procedure Rollback;
      Procedure StartTransaction;
      function GetClientInfo: string;
      function GetServerStat: string;
      function GetHostInfo: string;
      function GetProtoInfo: Cardinal;
      function GetServerInfo: string;
      procedure SelectDB(DBName : String);
      function GetCharSet: TConvertChar;
      function Ping : Integer;
      function Shutdown: integer;     // ptook
      procedure Kill(PID : Integer);

      procedure GetDatabases(Pattern: String;List : TStrings);
      Procedure GetTableNames(Pattern: String; List: TStrings; Views: Boolean = False);
      procedure GetFieldNames(const TableName : String; List : TStrings);

      property DataSets[Index: Integer]: TmySQLDataSet read GetDataSet;
      property Handle: HDBIDB read FHandle write SetHandle;
      property InTransaction: Boolean read GetInTransaction;
      property Temporary: Boolean read FTemporary write FTemporary;
    Published
      property About : TmySQLDACAbout read FAbout write FAbout;
      property Connected;
      {Set DataBaseParams}
      property DatabaseName: String read FDatabaseName write SetDatabaseName;
      property UserName : String read FUserName write SetUserName;
      property UserPassword : String read FUserPassword write SetUserPassword;
      property Port : Cardinal read FPort write SetServerPort default MYSQL_PORT;
      property Host : String read FHost write SetHost;
      property ConnectOptions : TConnectOptions read FConnectOptions write FConnectOptions;
      property KeepConnection: Boolean read FKeepConnection write SetKeepConnection default TRUE;
      property ConnectionTimeout : Cardinal read FTimeout write SetTimeout default 30;
      {End DataBaseParams}
      property Exclusive: Boolean read FExclusive write SetExclusive default FALSE;
      property HandleShared: Boolean read FHandleShared write FHandleShared default FALSE;
      property LoginPrompt;
      property Params: TStrings read FParams write SetParams;
      property ReadOnly: Boolean read FReadOnly write SetReadOnly default FALSE;
      property TransIsolation: TTransIsolation read FTransIsolation write FTransIsolation default tiReadCommitted;
      property AfterConnect;
      property AfterDisconnect;
      property BeforeConnect;
      property BeforeDisconnect;
      property MultiThreaded: boolean read FMT write SetMT default False;
      property SSLKey : string read FSSL_Key write SetSSLKey;
      property SSLCert : string read FSSL_Cert write SetSSLCert;
      property OnLogin: TBaseDatabaseLoginEvent read FOnLogin write FOnLogin;
      property OnConnectionFailure : TConnectionFailureEvent read FOnConnectionFailure write FOnConnectionFailure;
  end;

  TFieldDescList = array of FLDDesc;

  { TLocale }

  TLocale = Pointer;


  TRecNoStatus = (rnDbase, rnParadox, rnNotSupported);

  TmySQLSQLUpdateObject = class(TComponent)
  protected
     Function GetDataSet: TmySQLDataSet; Virtual; Abstract;
     Procedure SetDataSet(ADataSet: TmySQLDataSet); Virtual; Abstract;
     Procedure Apply(UpdateKind: TUpdateKind); Virtual; Abstract;
     Function GetSQL(UpdateKind: TUpdateKind): TStrings; virtual; abstract;
     property DataSet: TmySQLDataSet read GetDataSet write SetDataSet;
  end;

   TKeyIndex = (kiLookup, kiRangeStart, kiRangeEnd, kiCurRangeStart,
    kiCurRangeEnd, kiSave);

   PKeyBuffer = ^TKeyBuffer;
   TKeyBuffer = packed record
     Modified: Boolean;
     Exclusive: Boolean;
     FieldCount: Integer;
   end;

   PRecInfo = ^TRecInfo;
   TRecInfo = packed record
      RecordNumber: Longint;
      UpdateStatus: TUpdateStatus;
      BookmarkFlag: TBookmarkFlag;
   end;

  TBlobDataArray = array of TBlobData;


 TmySQLDataSet = Class(TDataSet)
  Private
    FHandle: HDBICur;  //cursor handle
    FRecProps: RecProps; //Record properties
    FStmtHandle: HDBIStmt; //Statement handle
    FExprFilter: HDBIFilter; //Filter expression
    FFuncFilter: HDBIFilter; // filter function
    FFilterBuffer: PChar; // filter buffer
    FIndexFieldMap: DBIKey; //Index field map
    FExpIndex: Boolean;
    FCaseInsIndex: Boolean;
    FCachedUpdates: Boolean;
    FInUpdateCallback: Boolean;
    FCanModify: Boolean;
    FCacheBlobs: Boolean;
    FKeySize: Word;
    FUpdateCBBuf: PDELAYUPDCbDesc;
    FKeyBuffers: array[TKeyIndex] of PKeyBuffer;
    FKeyBuffer: PKeyBuffer;
    FRecNoStatus: TRecNoStatus;
    FIndexFieldCount: Integer;
    FRecordSize: Word;
    FBookmarkOfs: Word;
    FRecInfoOfs: Word;
    FBlobCacheOfs: Word;
    FRecBufSize: Word;
    FBlockBufSize: Integer;
    FBlockBufOfs: Integer;
    FBlockBufCount: Integer;
    FBlockReadCount: Integer;
    FLastParentPos: Integer;
    FBlockReadBuf: PChar;
    FOldBuffer : PChar;
    FParentDataSet: TmySQLDataSet;
    FUpdateObject: TmySQLSQLUpdateObject;
    FOnUpdateError: TUpdateErrorEvent;
    FOnUpdateRecord: TUpdateRecordEvent;
    FAutoRefresh: Boolean;
    FDBFlags: TDBFlags;
    FUpdateMode: TUpdateMode;
    FDatabase: TmySQLDatabase;
    FAllowSequenced : Boolean;
    FSortFieldNames: string;
    Procedure ClearBlobCache(Buffer: PChar);
    Function GetActiveRecBuf(var RecBuf: PChar): Boolean;
    Function GetBlobData(Field: TField; Buffer: PChar): TBlobData;
    Function GetOldRecord: PChar;
    Procedure InitBufferPointers(GetProps: Boolean);
    Function RecordFilter(RecBuf: Pointer; RecNo: Integer): Smallint; stdcall;
    Procedure SetBlobData(Field: TField; Buffer: PChar; Value: TBlobData);
    Function GetDBHandle: HDBIDB;
    Procedure SetUpdateMode(const Value: TUpdateMode);
    Procedure SetAutoRefresh(const Value: Boolean);
    procedure SetDatabase(Value : TmySQLDatabase);
    function GetDatabase:TMySQLDatabase;
    Procedure SetupAutoRefresh;
    procedure SetSortFieldNames(const Value: string);
  protected
      { IProviderSupport }
      Procedure PSEndTransaction(Commit: Boolean); override;
      Function PSExecuteStatement(const ASQL: string; AParams: TParams;
        ResultSet: Pointer = nil): Integer; override;
      Procedure PSGetAttributes(List: TList); override;
      Function PSGetQuoteChar: string; override;
      Function PSInTransaction: Boolean; override;
      Function PSIsSQLBased: Boolean; override;
      Function PSIsSQLSupported: Boolean; override;
      Procedure PSStartTransaction; override;
      Procedure PSReset; override;
      Function PSGetUpdateException(E: Exception; Prev: EUpdateError): EUpdateError; override;
    Function  Engine : TmySQLEngine; Virtual; Abstract;
    Procedure Notification(AComponent: TComponent; Operation: TOperation); Override;
    Procedure ActivateFilters;
    Procedure AddFieldDesc(FieldDescs: TFieldDescList; var DescNo: Integer;
      var FieldID: Integer; RequiredFields: TBits; FieldDefs: TFieldDefs);
    Procedure AllocCachedUpdateBuffers(Allocate: Boolean);
    Procedure AllocKeyBuffers;
    Function  AllocRecordBuffer: PChar; Override;
    Function  CachedUpdateCallBack(CBInfo: Pointer): CBRType;
    Procedure CheckCachedUpdateMode;    
    Procedure CheckSetKeyMode;
    Procedure ClearCalcFields(Buffer: PChar); Override;
    Procedure CloseCursor; Override;
    Procedure CloseBlob(Field: TField); Override;
    Function  CreateExprFilter(const Expr: String;
      Options: TFilterOptions; Priority: Integer): HDBIFilter;
    Function  CreateFuncFilter(FilterFunc: Pointer;
      Priority: Integer): HDBIFilter;
    Function  CreateHandle: HDBICur; Virtual;
    Function  CreateLookupFilter(Fields: TList; const Values: Variant;
      Options: TLocateOptions; Priority: Integer): HDBIFilter;
    Procedure DataEvent(Event: TDataEvent; Info: Longint); Override;
    Procedure DeactivateFilters;
    Procedure DestroyHandle; Virtual;
    Procedure DestroyLookupCursor; Virtual;
    Function  FindRecord(Restart, GoForward: Boolean): Boolean; Override;
    Function  ForceUpdateCallback: Boolean;    
    Procedure FreeKeyBuffers;
    Procedure FreeRecordBuffer(var Buffer: PChar); Override;
    Procedure GetBookmarkData(Buffer: PChar; Data: Pointer); Override;
    Function  GetBookmarkFlag(Buffer: PChar): TBookmarkFlag; Override;
    Function  GetCanModify: Boolean; Override;
    Function  GetFieldFullName(Field: TField): string; override;
    Function  GetIndexField(Index: Integer): TField;
    Function  GetIndexFieldCount: Integer;
    Function  GetIsIndexField(Field: TField): Boolean; Override;
    Function  GetKeyBuffer(KeyIndex: TKeyIndex): PKeyBuffer;
    Function  GetKeyExclusive: Boolean;
    Function  GetKeyFieldCount: Integer;
    Function  GetLookupCursor(const KeyFields: String; CaseInsensitive: Boolean): HDBICur; Virtual;
    Function  GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult; Override;
    Function  GetRecordCount: Integer; Override;
    Function  GetRecNo: Integer; Override;
    Function  GetRecordSize: Word; Override;
    Function  GetStateFieldValue(State: TDataSetState; Field: TField): Variant; Override;
    Procedure GetObjectTypeNames(Fields: TFields);
    Function  GetUpdatesPending: Boolean;
    Function  GetUpdateRecordSet: TUpdateRecordTypes;
    Function  InitKeyBuffer(Buffer: PKeyBuffer): PKeyBuffer;
    Procedure InitRecord(Buffer: PChar); Override;
    Procedure InternalAddRecord(Buffer: Pointer; Append: Boolean); Override;
    Procedure InternalCancel; Override;
    Procedure InternalClose; Override;
    Procedure InternalDelete; Override;
    Procedure InternalEdit; Override;
    Procedure InternalFirst; Override;
    Procedure InternalGotoBookmark(Bookmark: TBookmark); Override;
    Procedure InternalHandleException; Override;
    Procedure InternalInitFieldDefs; Override;
    Procedure InternalInitRecord(Buffer: PChar); Override;
    Procedure InternalInsert; override;
    Procedure InternalLast; Override;
    Procedure InternalOpen; Override;
    Procedure InternalPost; Override;
    Procedure InternalRefresh; Override;
    Procedure InternalSetToRecord(Buffer: PChar); Override;
    Function  IsCursorOpen: Boolean; Override;
    Function  LocateRecord(const KeyFields: String; const KeyValues: Variant;
      Options: TLocateOptions; SyncCursor: Boolean): Boolean; virtual;
    Function  LocateNearestRecord(const KeyFields: String; const KeyValues: Variant;
      Options: TLocateOptions; SyncCursor: Boolean): Word;
    Function  MapsToIndex(Fields: TList; CaseInsensitive: Boolean): Boolean;
    Procedure PostKeyBuffer(Commit: Boolean);
    Procedure PrepareCursor; Virtual;
    Function  ProcessUpdates(UpdCmd: DBIDelayedUpdCmd): Word;
    Function  ResetCursorRange: Boolean;
    Procedure SetBookmarkData(Buffer: PChar; Data: Pointer); Override;
    Procedure SetBookmarkFlag(Buffer: PChar; Value: TBookmarkFlag); Override;
    Procedure SetCachedUpdates(Value: Boolean);
    Function  SetCursorRange: Boolean;
    Procedure SetFieldData(Field: TField; Buffer: Pointer); Override;
    Procedure SetFilterData(const Text: String; Options: TFilterOptions);
    Procedure SetFilterHandle(var Filter: HDBIFilter; Value: HDBIFilter);
    Procedure SetFiltered(Value: Boolean); Override;
    Procedure SetFilterOptions(Value: TFilterOptions); Override;
    Procedure SetFilterText(const Value: String); Override;
    Procedure SetIndexField(Index: Integer; Value: TField);
    Procedure SetKeyBuffer(KeyIndex: TKeyIndex; Clear: Boolean);
    Procedure SetKeyExclusive(Value: Boolean);
    Procedure SetKeyFieldCount(Value: Integer);
    Procedure SetKeyFields(KeyIndex: TKeyIndex; const Values: array of const);
    Procedure SetLinkRanges(MasterFields: TList);
    Procedure SetStateFieldValue(State: TDataSetState; Field: TField; const Value: Variant); Override;
    Procedure SetOnFilterRecord(const Value: TFilterRecordEvent); Override;
    procedure SetOnUpdateError(UpdateEvent: TUpdateErrorEvent);
    Procedure SetRecNo(Value: Integer); Override;
    Procedure SetUpdateRecordSet(RecordTypes: TUpdateRecordTypes);
    Procedure SetUpdateObject(Value: TmySQLSQLUpdateObject);
    Procedure SwitchToIndex(const IndexName, TagName: String);
    Procedure Disconnect; Virtual;
    Procedure OpenCursor(InfoQuery: Boolean); Override;
    Function SetDBFlag(Flag: Integer; Value: Boolean): Boolean; virtual;
    Procedure SetHandle(Value: HDBICur);
    function GetHandle: HDBICur;
    procedure BlockReadNext; override;
    procedure SetBlockReadSize(Value: Integer); override;
    property DBFlags: TDBFlags read FDBFlags;
    property UpdateMode: TUpdateMode read FUpdateMode write SetUpdateMode default upWhereAll;
    property StmtHandle: HDBIStmt read FStmtHandle write FStmtHandle;
  Public
    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; Override;
    Function  CreateBlobStream(Field : TField; Mode : TBlobStreamMode) : TStream; Override;
    Procedure ApplyUpdates;
    Function  BookmarkValid(Bookmark: TBookmark): Boolean; Override;
    Procedure Cancel; Override;
    Procedure CancelUpdates;
    property  CacheBlobs: Boolean read FCacheBlobs write FCacheBlobs default True;
    Function  CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer; Override;
    Procedure CommitUpdates;
    Procedure FetchAll;
    Procedure FlushBuffers;
    Function GetCurrentRecord(Buffer: PChar): Boolean; Override;
    Function GetBlobFieldData(FieldNo: Integer; var Buffer: TBlobByteData): Integer; override;
    Function GetFieldData(Field: TField; Buffer: Pointer): Boolean; overload; override;
    Function GetFieldData(FieldNo: Integer; Buffer: Pointer): Boolean; overload; override;
    Procedure GetIndexInfo;
    Function  Locate(const KeyFields: String; const KeyValues: Variant;
      Options: TLocateOptions): Boolean; Override;
    Function  Lookup(const KeyFields: String; const KeyValues: Variant;
      const ResultFields: String): Variant; Override;
    Function  IsSequenced: Boolean; Override;
    Procedure Post; Override;
    Procedure RevertRecord;
    Function  UpdateStatus: TUpdateStatus; Override;
    Function  Translate(Src, Dest: PChar; ToOem: Boolean) : Integer;  Override;
    Function CheckOpen(Status: Word): Boolean;
    Procedure CloseDatabase(Database: TmySQLDatabase);
	 Procedure GetDatabaseNames(List: TStrings);
	 function GetLastInsertID: Int64; virtual;

	 procedure SortBy(FieldNames : string);//mi

	 property DBHandle: HDBIDB read GetDBHandle;
	 property Handle: HDBICur read GetHandle write SetHandle;
	 property ExpIndex: Boolean read FExpIndex;
	 property KeySize: Word read FKeySize;
	 property UpdateObject: TmySQLSQLUpdateObject read FUpdateObject write SetUpdateObject;
	 property UpdatesPending: Boolean read GetUpdatesPending;
	 property UpdateRecordTypes: TUpdateRecordTypes read GetUpdateRecordSet write SetUpdateRecordSet;
  Published
    property AutoRefresh: Boolean read FAutoRefresh write SetAutoRefresh default FALSE;
    property Database: TmySQLDatabase read GetDatabase write SetDatabase;
    property CachedUpdates: Boolean read FCachedUpdates write SetCachedUpdates default False;
    property AllowSequenced : Boolean read FAllowSequenced Write FAllowSequenced default False; 
    property Filter;
    property Filtered;
    property FilterOptions;
    property OnFilterRecord;
    property Active;
    property AutoCalcFields;
    property ObjectView default FALSE;
    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property BeforeScroll;
    property AfterScroll;
    property BeforeRefresh;
    property AfterRefresh;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnNewRecord;
    property OnPostError;
    property OnUpdateError: TUpdateErrorEvent read FOnUpdateError write SetOnUpdateError;
	 property OnUpdateRecord: TUpdateRecordEvent read FOnUpdateRecord write FOnUpdateRecord;
	 property SortFieldNames : string read FSortFieldNames write SetSortFieldNames;
  end;

//////////////////////////////////////////////////////////
//Class       : TmySQLTable
//Description : TmySQLTable class
//////////////////////////////////////////////////////////
  TMySQLLockType = (mltReadLock, mltWriteLock);
  TTableType = (ttDefault, ttParadox, ttDBase, ttFoxPro, ttASCII);
  TIndexName = type string;

  TIndexDescList = array of IDXDesc;

  TValCheckList = array of VCHKDesc;

  TmySQLTable = Class(TmySQLDataSet)
  Private
    FAbout : TmySQLDACAbout;
    FStoreDefs: Boolean;
    FIndexDefs: TIndexDefs;
    FMasterLink: TMasterDataLink;
    FDefaultIndex: Boolean;
    FExclusive: Boolean;
    FReadOnly: Boolean;
    FFieldsIndex: Boolean;
    FTableName: TFileName;
    FIndexName: TIndexName;
    FLookupHandle: HDBICur;
    FLookupKeyFields: String;
    FTableLevel: Integer;
    FLookupCaseIns: Boolean;
    FNativeTableName: DBITBLNAME;
    FLimit : Integer;
    FOffset : Integer;
    procedure SetLimit(const Value : Integer);
    function GetLimit: integer;
    procedure SetOffset(const Value : Integer);
    function GetOffset: integer;
    Procedure CheckMasterRange;
    Procedure DecodeIndexDesc(const IndexDesc: IDXDesc;
      var Source, Name, FieldExpression, DescFields: string;
      var Options: TIndexOptions);
    Function FieldDefsStored: Boolean;
    Function GetExists: Boolean;
    Function GetIndexFieldNames: String;
    Function GetIndexName: String;
    Procedure GetIndexParams(const IndexName: String; FieldsIndex: Boolean;
      var IndexedName, IndexTag: String);
    Function GetMasterFields: String;
    Function GetTableTypeName: PChar;
    Function GetTableLevel: Integer;
    Function IndexDefsStored: Boolean;
    Procedure MasterChanged(Sender: TObject);
    Procedure MasterDisabled(Sender: TObject);
    Procedure SetDataSource(Value: TDataSource);
    Procedure SetExclusive(Value: Boolean);
    Procedure SetIndexDefs(Value: TIndexDefs);
    Procedure SetIndex(const Value: String; FieldsIndex: Boolean);
    Procedure SetIndexFieldNames(const Value: String);
    Procedure SetIndexName(const Value: String);
    Procedure SetMasterFields(const Value: String);
    Procedure SetReadOnly(Value: Boolean);
    Procedure SetTableLock(LockType: TMySQLLockType; Lock: Boolean);
    Procedure SetTableName(const Value: TFileName);
    function GetTableName: TFileName;
    Procedure UpdateRange;
    function GetBatchModify: Boolean;
    procedure SetBatchModify(const Value : Boolean);
  Protected
    { IProviderSupport }
    Function PSGetDefaultOrder: TIndexDef; override;
    Function PSGetKeyFields: string; override;
    Function PSGetTableName: string; override;
    function PSGetIndexDefs(IndexTypes: TIndexOptions): TIndexDefs; override;
    Procedure PSSetCommandText(const CommandText: string); override;
    Procedure PSSetParams(AParams: TParams); override;
    Function CreateHandle: HDBICur; Override;
    Procedure DataEvent(Event: TDataEvent; Info: Longint); Override;
    Procedure DefChanged(Sender: TObject); override;
    Procedure DestroyHandle; Override;
    Procedure DestroyLookupCursor; Override;
    Procedure DoOnNewRecord; Override;
    Procedure EncodeFieldDesc(var FieldDesc: FLDDesc;
      const Name: string; DataType: TFieldType; Size, Precision: Integer);
    Procedure EncodeIndexDesc(var IndexDesc: IDXDesc;
      const Name, FieldExpression: string; Options: TIndexOptions;
      const DescFields: string = '');
    Function GetCanModify: Boolean; Override;
    Function GetDataSource: TDataSource; Override;
    Function GetHandle(const IndexName, IndexTag: String): HDBICur;
    Function GetLanguageDriverName: String;
    Function GetLookupCursor(const KeyFields: String;
      CaseInsensitive: Boolean): HDBICur; Override;
    Procedure InitFieldDefs; Override;
    Function GetFileName: string;
    Function GetTableType: TTableType;
    Function NativeTableName: PChar;
    Procedure PrepareCursor; Override;
    Procedure UpdateIndexDefs; Override;
    property MasterLink: TMasterDataLink read FMasterLink;
  Public
    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; Override;
    Function  Engine : TmySQLEngine; Override;
    Function  IsSequenced: Boolean; Override;
    Procedure AddIndex(const Name, Fields: string; Options: TIndexOptions; const DescFields: string = '');
    Procedure ApplyRange;
    Procedure CancelRange;
    procedure CreateTable;
    Procedure DeleteIndex(const Name: String);
    Procedure EditKey;
    Procedure EditRangeEnd;
    Procedure EditRangeStart;
    Procedure EmptyTable;
    Function FindKey(const KeyValues: array of const): Boolean;
    Procedure FindNearest(const KeyValues: array of const);
    Procedure GetDetailLinkFields(MasterFields, DetailFields: TList); override;
    Procedure GetIndexNames(List: TStrings);
    Procedure GotoCurrent(Table: TmySQLTable);
    Function GotoKey: Boolean;
    Procedure GotoNearest;
    Procedure LockTable(LockType: TMySQLLockType);
    Procedure SetKey;
    Procedure SetRange(const StartValues, EndValues: array of const);
    Procedure SetRangeEnd;
    Procedure SetRangeStart;
    Procedure UnlockTable;
    property Exists: Boolean read GetExists;
    property IndexFieldCount: Integer read GetIndexFieldCount;
    property IndexFields[Index: Integer]: TField read GetIndexField write SetIndexField;
    property KeyExclusive: Boolean read GetKeyExclusive write SetKeyExclusive;
    property KeyFieldCount: Integer read GetKeyFieldCount write SetKeyFieldCount;
    property TableLevel: Integer read GetTableLevel write FTableLevel;
    property BatchModify : Boolean read GetBatchModify write SetBatchModify default False;
  Published
    property About : TmySQLDACAbout read FAbout write FAbout;
    property DefaultIndex: Boolean read FDefaultIndex write FDefaultIndex default TRUE;
    property Exclusive: Boolean read FExclusive write SetExclusive default FALSE;
    property FieldDefs stored FieldDefsStored;
    property IndexDefs: TIndexDefs read FIndexDefs write SetIndexDefs stored IndexDefsStored;
    property IndexFieldNames: String read GetIndexFieldNames write SetIndexFieldNames;
    property IndexName: String read GetIndexName write SetIndexName;
    property MasterFields: String read GetMasterFields write SetMasterFields;
    property MasterSource: TDataSource read GetDataSource write SetDataSource;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default FALSE;
    property StoreDefs: Boolean read FStoreDefs write FStoreDefs default FALSE;
    property TableName: TFileName read GetTableName write SetTableName;
    property UpdateMode;
    property UpdateObject;
    property Limit : Integer read GetLimit write SetLimit default -1;
    property Offset : Integer read GetOffset write SetOffset default 0;
  end;


//////////////////////////////////////////////////////////
//Class       : TmySQLQuery
//Description : Component TmySQLQuery
//////////////////////////////////////////////////////////
    TmySQLQuery = Class(TmySQLDataSet)
    Private
      FAbout : TmySQLDACAbout;
      FSQL: TStrings;
      FPrepared: Boolean;
      FParams: TmySQLParams;
      FText: String;
      FDataLink: TDataLink;
      FLocal: Boolean;
      FRowsAffected: Integer;
      FLastInsertID: Int64;  //NEW
      FUniDirectional: Boolean;
      FRequestLive: Boolean;
      FSQLBinary: PChar;
      FParamCheck: Boolean;
      FExecSQL: Boolean;
      FCheckRowsAffected: Boolean;
      Function CreateCursor(GenHandle: Boolean): HDBICur;
      Function GetQueryCursor(GenHandle: Boolean): HDBICur;
      Function GetRowsAffected: Integer;
      Function GetLastInsID:Int64; //NEW 2.3.1
      Procedure PrepareSQL(Value: PChar);
      Procedure QueryChanged(Sender: TObject);
      Procedure ReadBinaryData(Stream: TStream);
      Procedure ReadParamData(Reader: TReader);
      Procedure RefreshParams;
      Procedure SetDataSource(Value: TDataSource);
      Procedure SetQuery(Value: TStrings);
      function GetQuery:TStrings;
      Procedure SetParamsList(Value: TmySQLParams);
      function GetParamsList:TMySQLParams;
      Procedure SetParamsFromCursor;
      Procedure SetPrepared(Value: Boolean);
      Procedure SetPrepare(Value: Boolean);
      Procedure WriteBinaryData(Stream: TStream);
      Procedure WriteParamData(Writer: TWriter);
      procedure SetRequestLive(const Value : Boolean);
      function GetRequestLive : Boolean;
    protected
      { IProviderSupport }
      Procedure PSExecute; override;
      Function PSGetDefaultOrder: TIndexDef; override;
      Function PSGetParams: TParams; override;
      Function PSGetTableName: string; override;
      Procedure PSSetCommandText(const CommandText: string); override;
      Procedure PSSetParams(AParams: TParams); override;
      Function CreateHandle: HDBICur; Override;
      Procedure DefineProperties(Filer: TFiler); Override;
      Procedure Disconnect; Override;
      Procedure FreeStatement; virtual;
      Function GetDataSource: TDataSource; Override;
      Function GetParamsCount: Word;
      Function SetDBFlag(Flag: Integer; Value: Boolean): Boolean; override;
      Procedure GetStatementHandle(SQLText: PChar); virtual;
      property DataLink: TDataLink read FDataLink;
    Public
      constructor Create(AOwner: TComponent); Override;
      destructor Destroy; Override;
      Function  Engine : TmySQLEngine; Override;
      Function  IsSequenced: Boolean; Override;
      Procedure ExecSQL;
      Procedure GetDetailLinkFields(MasterFields, DetailFields: TList); override;
      Function ParamByName(const Value: String): TmySQLParam;
      Procedure Prepare;
      Procedure UnPrepare;
      function GetLastInsertID: Int64; override;
      property Prepared: Boolean read FPrepared write SetPrepare;
      property ParamCount: Word read GetParamsCount;
      property Local: Boolean read FLocal;
      property StmtHandle;
      property Text: String read FText;
      property RowsAffected: Integer read GetRowsAffected;
      Property LastInsertID: Int64 read GetLastInsID;
      property SQLBinary: PChar read FSQLBinary write FSQLBinary;
    Published
      property About : TmySQLDACAbout read FAbout write FAbout;
      property DataSource: TDataSource read GetDataSource write SetDataSource;
      property ParamCheck: Boolean read FParamCheck write FParamCheck default TRUE;
      property RequestLive: Boolean read GetRequestLive write SetRequestLive default FALSE;
      property SQL: TStrings read GetQuery write SetQuery;
      property Params: TmySQLParams read GetParamsList write SetParamsList stored FALSE;
      property UniDirectional: Boolean read FUniDirectional write FUniDirectional default FALSE;
      property UpdateMode;
      property UpdateObject;
  end;

  { TmySQLUpdateSQL }

  TRecordChangeCompleteEvent = procedure(DataSet: TMySQLDataSet; const Reason: TUpdateKind) of object;

  TmySQLUpdateSQL = Class(TmySQLSQLUpdateObject)
  Private
    FAbout : TmySQLDACAbout;
	 FDataSet: TmySQLDataSet;
    FQueries: array[TUpdateKind] of TmySQLQuery;
    FSQLText: array[TUpdateKind] of TStrings;
    FRecordChangeCompleteEvent: TRecordChangeCompleteEvent;
    Function GetQuery(UpdateKind: TUpdateKind): TmySQLQuery;
    Function GetSQLIndex(Index: Integer): TStrings;
    Procedure SetSQL(UpdateKind: TUpdateKind; Value: TStrings);
    Procedure SetSQLIndex(Index: Integer; Value: TStrings);
  Protected
    Function GetSQL(UpdateKind: TUpdateKind): TStrings; Override;
    Function GetQueryClass : TmySQLQueryClass;
    Function GetDataSet: TmySQLDataSet; Override;
    Procedure SetDataSet(ADataSet: TmySQLDataSet); Override;
    Procedure SQLChanged(Sender: TObject);
  Public
    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; Override;
    Procedure Apply(UpdateKind: TUpdateKind); Override;
    Procedure ExecSQL(UpdateKind: TUpdateKind);
    Procedure SetParams(UpdateKind: TUpdateKind);
    property DataSet;
    property Query[UpdateKind: TUpdateKind]: TmySQLQuery read GetQuery;
    property SQL[UpdateKind: TUpdateKind]: TStrings read GetSQL write SetSQL;
  Published
    property About : TmySQLDACAbout read FAbout write FAbout;
    property ModifySQL: TStrings index 0 read GetSQLIndex write SetSQLIndex;
    property InsertSQL: TStrings index 1 read GetSQLIndex write SetSQLIndex;
    property DeleteSQL: TStrings index 2 read GetSQLIndex write SetSQLIndex;
    property OnRecordChangeComplete: TRecordChangeCompleteEvent read FRecordChangeCompleteEvent write FRecordChangeCompleteEvent;
  end;

  { TmySQLBlobStream }
  TmySQLBlobStream = Class(TStream)
    Private
      FField: TBlobField;
      FDataSet: TmySQLDataSet;
      FBuffer: PChar;
      FMode: TBlobStreamMode;
      FFieldNo: Integer;
      FOpened: Boolean;
      FModified: Boolean;
      FPosition: Longint;
      FBlobData: TBlobData;
      FCached: Boolean;
      FCacheSize: Longint;
      Function GetBlobSize: Longint;
    Public
      constructor Create(Field: TBlobField; Mode: TBlobStreamMode);
      destructor Destroy; Override;
      Function Engine : TmySQLEngine;
      Function Read(var Buffer; Count: Longint): Longint; Override;
      Function Write(const Buffer; Count: Longint): Longint; Override;
      Function Seek(Offset: Longint; Origin: Word): Longint; Override;
      Procedure Truncate;
  end;


Function SetBoolProp(Engine : TmySQLEngine; const Handle: Pointer; PropName: Integer; Value: Bool) : Boolean;
Procedure Check(Engine : TmySQLEngine; Status: Word);
Function TAnsiToNative(Engine : TmySQLEngine; const AnsiStr: String;
  NativeStr: PChar; MaxLen: Integer): PChar;
Procedure TDbiError(Engine : TmySQLEngine; ErrorCode: Word);

Var
   DBList : TList;

implementation

uses  ActiveX, Forms, DBLogDlg, DBConsts, BDEConst, Dialogs,mysqlAboutFrm;
{$R DB.DCR}

var
  CSNativeToAnsi: TRTLCriticalSection;
  CSAnsiToNative: TRTLCriticalSection;
  TimerID: Word = 0;
  SQLDelay: DWORD = 50;
  StartTime: DWORD = 0;


{ TmySQLQueryDataLink }
type
  TmySQLQueryDataLink =  Class(TDetailDataLink)
    Private
      FQuery: TmySQLQuery;
    Protected
      Procedure ActiveChanged; Override;
      Procedure RecordChanged(Field: TField); Override;
      Function GetDetailDataSet: TDataSet; Override;
      Procedure CheckBrowseMode; Override;
    Public
      constructor Create(AQuery: TmySQLQuery);
  end;



{ Utility routines }
Procedure TAnsiToNativeBuf(Engine : TmySQLEngine; Source, Dest: PChar; Len: Integer);
var
  DataLoss: LongBool;
begin
  if Len > 0 then
  begin
     EnterCriticalSection(CSAnsiToNative);
     try
       Engine.AnsiToNative(Dest, Source, Len, DataLoss);
     finally
       LeaveCriticalSection(CSAnsiToNative);
     end;
  end;
end;


Procedure TNativeToAnsiBuf(Engine : TmySQLEngine; Source, Dest: PChar; Len: Integer);
var
  DataLoss: LongBool;
begin
  if Len > 0 then
  begin
     EnterCriticalSection(CSNativeToAnsi);
     try
       Engine.NativeToAnsi(Dest, Source, Len, DataLoss);
     finally
       LeaveCriticalSection(CSNativeToAnsi);
     end;
  end;
end;


Function TAnsiToNative(Engine : TmySQLEngine; const AnsiStr: String;
  NativeStr: PChar; MaxLen: Integer): PChar;
var
  Len: Integer;
begin
  Len := Length(AnsiStr);
  if Len > MaxLen then Len := MaxLen;
  NativeStr[Len] := #0;
  if Len > 0 then
    TAnsiToNativeBuf(Engine, Pointer(AnsiStr), NativeStr, Len);
  Result := NativeStr;
end;


Procedure TNativeToAnsi(Engine : TmySQLEngine; NativeStr: PChar; var AnsiStr: String);
var
  Len : Integer;
begin
  Len := StrLen(NativeStr);
  SetString(AnsiStr, nil, Len);
  if Len > 0 then
    TNativeToAnsiBuf(Engine, NativeStr, Pointer(AnsiStr), Len);
end;

Procedure TDbiError(Engine : TmySQLEngine; ErrorCode: Word);
begin
  Raise EmySQLDatabaseError.Create(Engine, ErrorCode);
end;

Procedure Check(Engine : TmySQLEngine; Status: Word);
begin
  if Status <> 0 then TDbiError(Engine, Status);
end;


{ Parameter binding routines }
Function GetParamDataSize(Param: TParam): Integer;
begin
  with Param do
    if ((DataType in [ftString, ftFixedChar]) and (Length(VarToStr(Value)) > 255)) or
       (DataType in [ftBlob..ftTypedBinary]) then
      Result := SizeOf(BlobParamDesc)
    else
      Result := GetDataSize;
end;

Procedure GetParamData(Param: TParam; Buffer: Pointer; const DrvLocale: TLocale);

  Function GetNativeStr: PChar;
  begin
    Param.NativeStr := VarToStr(Param.Value);
    Result := PChar(Param.NativeStr);
    if DrvLocale <> nil then
      TAnsiToNativeBuf(DrvLocale, Result, Result, StrLen(Result));
  end;

begin
  with Param do
    if DataType in [ftString, ftFixedChar, ftMemo]  then
    begin
      NativeStr := VarToStr(Value);
      if (Length(NativeStr) > 255) or (DataType = ftMemo) then
      begin
        with BlobParamDesc(Buffer^) do
        begin
          if DrvLocale <> nil then
            TAnsiToNativeBuf(DrvLocale, PChar(NativeStr), PChar(NativeStr), Length(NativeStr));
          pBlobBuffer := PChar(NativeStr);
          ulBlobLen := StrLen(pBlobBuffer);
        end;
      end else
      begin
        if (DrvLocale <> nil) then
          TAnsiToNativeBuf(DrvLocale, PChar(NativeStr), Buffer, Length(NativeStr) + 1) else
          GetData(Buffer);
      end;
    end
    else if (DataType in [ftBlob..ftTypedBinary]) then
    begin
      with BlobParamDesc(Buffer^) do
      begin
        NativeStr := VarToStr(Value);
        ulBlobLen := Length(NativeStr);
        pBlobBuffer := PChar(NativeStr);
      end;
    end else
      GetData(Buffer);
end;


{ Timer callback Function }
Procedure FreeTimer(ForceKill : Boolean = FALSE);
begin
  if (TimerID <> 0) and (ForceKill or (GetTickCount - StartTime > SQLDelay)) then
  begin
    KillTimer(0, TimerID);
    TimerID   := 0;
    StartTime := 0;
    Screen.Cursor := crDefault;
  end;
end;


Function GetIntProp(Engine : TmySQLEngine; const Handle: Pointer; PropName: Integer): Integer;
Var
  Length : Word;
  Value  : Integer;
begin
  Value := 0;
  if (Engine.GetEngProp(HDBIObj(Handle), PropName, @Value, SizeOf(Value), Length) = DBIERR_NONE) then
    Result := Value else
    Result := 0;
end;

Function SetBoolProp(Engine : TmySQLEngine; const Handle: Pointer; PropName: Integer; Value: Bool) : Boolean;
begin
  Result := Engine.SetEngProp(HDBIObj(Handle), PropName, Abs(Integer(Value))) = DBIERR_NONE;
end;

{ EmySQLDatabaseError }
constructor EmySQLDatabaseError.Create(Engine : TmySQLEngine; ErrorCode : Word);

  Function GetErrorString: String;
  var
    Msg1 : String;
    Msg2 : String;
    Err  : Integer;
  begin
    Msg1 := Engine.MessageStatus;
    Err := Engine.Status;
    if (Msg1 <> '') and (Err >0) then  Msg1 := Format('mySQL Error Code: (%s)',[IntToStr(Err)])+#13#10+Msg1 else
    begin
       Msg2 := GetBDEErrorMessage(ErrorCode);
       Msg1 := Format('DBI Error Code: (%s)'+#13#10+'%s '+#13#10+'%s',[IntToStr(ErrorCode),Msg1,Msg2]);
    end;
    Result := Msg1
  end;

begin
  FreeTimer(TRUE);
  FErrorCode := ErrorCode;
  Message := GetErrorString;
  if Message <> '' then
     Message := Copy(Message, 1, Length(Message)) else
     Message := Format('mySQLDAC Interface Error: (%d)',[ErrorCode]);
end;

destructor EmySQLDatabaseError.Destroy;
begin
  Inherited Destroy;
end;


{ TmySQLDatabase }
Procedure TmySQLDatabase.InitEngine;
begin
  Try
    if FEngine = nil then
      begin
        FEngine := TmySQLEngine.Create(nil, nil);
        FEngine.MultiThreaded:=FMT;
        FEngine.SSLKey := SSLKey;
        FEngine.SSLCert := SSLCert;
      end;
  Except
    raise EDatabaseError.Create('Engine not Initialize');
  end;
end;

Procedure TmySQLDatabase.AddDatabase(Value : TmySQLDatabase);
begin
   DBList.Add(Value);
end;

Procedure TmySQLDatabase.RemoveDatabase(Value : TmySQLDatabase);
begin
   while DataSetCount <> 0  do
      TmySQLDataSet(DataSets[DataSetCount - 1]).FDatabase := nil;
   DBList.Remove(Value);
end;

constructor TmySQLDatabase.Create(AOwner : TComponent);
begin
  Inherited Create(AOwner);
  FParams := TStringList.Create;
  TStringList(FParams).OnChanging := ParamsChanging;
  FKeepConnection := TRUE;
  SetServerPort(MYSQL_PORT);
  FTransIsolation := tiReadCommitted;
  SetTimeout(30);
  AddDatabase(Self);
  FMT := False;
  FCheckIfActiveOnParamChange := True;    // ptook
end;

destructor TmySQLDatabase.Destroy;
begin
  Destroying;
  Close;
  RemoveDatabase(Self);
  if FEngine <> nil then FEngine.Free;
  Inherited Destroy;
  FParams.Free;
  FStmtList.Free;
end;


Procedure TmySQLDatabase.ApplyUpdates(const DataSets: array of TmySQLDataSet);
var
  I  : Integer;
  DS : TmySQLDataSet;
begin
  StartTransaction;
  try
    for I := 0 to High(DataSets) do
    begin
      DS := DataSets[I];
      if (DS.Database <> Self) then
        DatabaseError(Format(SUpdateWrongDB, [DS.Name, Name]));
      DataSets[I].ApplyUpdates;
    end;
    Commit;
  except
    Rollback;
    raise;
  end;
  for I := 0 to High(DataSets) do DataSets[I].CommitUpdates;
end;

type
  PStmtInfo = ^TStmtInfo;
  TStmtInfo = packed record
    HashCode: Integer;
    StmtHandle: HDBIStmt;
    SQLText: string;
  end;

Procedure TmySQLDatabase.ClearStatements;
var
  i: Integer;
begin
  if Assigned(FStmtList) then
  begin
    for i := 0 to FStmtList.Count - 1 do
    begin
      Engine.QFree(PStmtInfo(FStmtList[i]).StmtHandle);
      Dispose(PStmtInfo(FStmtList[i]));
    end;
    FStmtList.Clear;
  end;
end;

Function TmySQLDatabase.Execute(const SQL: string; Params: TParams = nil;
  Cache: Boolean = FALSE): Integer;

  Function GetStmtInfo(SQL: PChar): PStmtInfo;

    Function GetHashCode(Str: PChar): Integer;
    var
      Off, Len, Skip, I: Integer;
    begin
      Result := 0;
      Off := 1;
      Len := StrLen(Str);
      if Len < 16 then
        for I := (Len - 1) downto 0 do
        begin
          Result := (Result * 37) + Ord(Str[Off]);
          Inc(Off);
        end else
        begin
        { Only sample some characters }
        Skip := Len div 8;
        I := Len - 1;
        while I >= 0 do
        begin
          Result := (Result * 39) + Ord(Str[Off]);
          Dec(I, Skip);
          Inc(Off, Skip);
        end;
      end;
    end;

  var
    HashCode, i: Integer;
    Info: PStmtInfo;

  begin //GetStmtInfo
    if not Assigned(FStmtList) then FStmtList := TList.Create;
    Result := nil;
    HashCode := GetHashCode(SQL);
    for i := 0 to FStmtList.Count - 1 do
    begin
      Info := PStmtInfo(FStmtList[i]);
      if (Info.HashCode = HashCode) and
         (AnsiStrIComp(PChar(Info.SQLText), SQL) = 0) then
      begin
        Result := Info;
        break;
      end;
    end;
    if not Assigned(Result) then
    begin
      New(Result);
      FStmtList.Add(Result);
      FillChar(Result^, SizeOf(Result^), 0);
      Result.HashCode := HashCode;
    end;
  end;

  Function GetStatementHandle: HDBIStmt;
  var
    Info: PStmtInfo;
    Status: Word;
  begin
    Info   := nil;
    Result := nil;
    if Cache then
    begin
      Info := GetStmtInfo(PChar(SQL));
      Result := Info.StmtHandle;
    end;
    if not Assigned(Result) then
    begin
      Check(Engine, Engine.QAlloc(Handle, qrylangSQL, Result));
      SetBoolProp(Engine, Result, stmtUNIDIRECTIONAL, TRUE);
      while TRUE do
      begin
        Status := Engine.QPrepare(Result, PChar(SQL));
        case Status of
        DBIERR_NONE: break;
        DBIERR_NOTSUFFTABLERIGHTS: TDbiError(Engine, Status);
        end;
      end;
      if Assigned(Info) then
      begin
        Info.SQLText    := SQL;
        Info.StmtHandle := Result;
      end;
    end;
  end;

var
  StmtHandle : HDBIStmt;
  Len        : Word;

begin //TmySQLDatabase.Execute
  StmtHandle := nil;
  Result := 0;
  Open;
  if Assigned(Params) and (Params.Count > 0) then
  begin
    StmtHandle := GetStatementHandle;
    try
      Check(Engine, Engine.QuerySetParams(StmtHandle, Params, SQL));
      Check(Engine, Engine.QExec(StmtHandle, nil));
      Engine.GetEngProp(hDBIObj(StmtHandle), stmtROWCOUNT,@Result, SizeOf(Result),Len);
    finally
      if not Cache then  Engine.QFree(StmtHandle);
    end;
  end else
    Check(Engine, Engine.QExecDirect(Handle, qrylangSQL, PChar(SQL), nil, Result));
end;

Procedure TmySQLDatabase.CheckActive;
begin
  if FHandle = nil then DatabaseError(SDatabaseClosed);
end;

Procedure TmySQLDatabase.CheckInactive;
begin
  if FHandle <> nil then
     if csDesigning in ComponentState then
        Close else
        DatabaseError(SDatabaseOpen, Self);
end;

Procedure TmySQLDatabase.CloseDatabaseHandle;
begin
   Engine.CloseDatabase(FHandle);
end;

procedure TmySQLDatabase.CloseDatabase;
begin
    if FRefCount <> 0 then Dec(FRefCount);
    if (FRefCount = 0) and not KeepConnection then
       if not Temporary then Close else
         if not (csDestroying in ComponentState) then Free;
end;


Procedure TmySQLDatabase.DoDisconnect;
begin
  if FHandle <> nil then
  begin
    ClearStatements;
    CloseDataSets;
    if not FAcquiredHandle then
      CloseDatabaseHandle else
      FAcquiredHandle := FALSE;
    FHandle := nil;
    FRefCount := 0;
  end;
end;

Procedure TmySQLDatabase.CloseDataSets;
begin
  while DataSetCount <> 0  do
    TmySQLDataSet(DataSets[DataSetCount - 1]).Disconnect;
end;

Procedure TmySQLDatabase.Commit;
begin
  CheckActive;
  EndTransaction(xendCOMMIT);
end;

Procedure TmySQLDatabase.Rollback;
begin
  CheckActive;
  EndTransaction(xendABORT);
end;

Procedure TmySQLDatabase.StartTransaction;
var
  TransHandle:  HDBIXAct;
begin
  CheckActive;
  Check(Engine, Engine.BeginTran(FHandle, EXILType(FTransIsolation),TransHandle));
end;

Procedure TmySQLDatabase.EndTransaction(TransEnd : EXEnd);
begin
  Check(Engine, Engine.EndTran(FHandle, nil, TransEnd));
end;

Function TmySQLDatabase.GetConnected: Boolean;
begin
  Result := FHandle <> nil;
end;

Function TmySQLDatabase.GetDataSet(Index : Integer) : TmySQLDataSet;
begin
  Result := inherited GetDataSet(Index) as TmySQLDataSet;
end;

Procedure TmySQLDatabase.SetDatabaseFlags;
var
  Length: Word;
  Buffer: DBINAME;
begin
  Check(Engine, Engine.GetEngProp(HDBIOBJ(FHandle), dbDATABASETYPE, @Buffer, SizeOf(Buffer), Length));
  FPseudoIndexes := FALSE;
end;

Function TmySQLDatabase.GetInTransaction: Boolean;
var
  TranInfo : XInfo;
begin
  Result := (Handle <> nil) and (Engine.GetTranInfo(Handle, nil, @TranInfo) = DBIERR_NONE) and (TranInfo.exState = xsActive);
end;

Procedure TmySQLDatabase.Loaded;
begin
  Inherited Loaded;
  if not StreamedConnected then InitEngine;
end;

Procedure TmySQLDatabase.Notification(AComponent : TComponent; Operation : TOperation);
begin
  Inherited Notification(AComponent, Operation);
end;

Procedure TmySQLDatabase.Login(LoginParams: TStrings);
var
  UserName, Password: String;
begin
  if Assigned(FOnLogin) then FOnLogin(Self, LoginParams) else
  begin
    UserName := LoginParams.Values['UID'];
    if not LoginDialogEx(DatabaseName, UserName, Password, FALSE) then DatabaseErrorFmt(SLoginError, [DatabaseName]);
    LoginParams.Values['UID'] := UserName;
    LoginParams.Values['PWD'] := Password;
  end;
end;

Procedure TmySQLDatabase.CheckDatabase(var Password: String);
var
  DBName: String;
  LoginParams: TStringList;
begin
  Password := '';
  DBName := FDatabaseName;
  if LoginPrompt then
  begin
     LoginParams := TStringList.Create;
     try
       Login(LoginParams);
       Password := LoginParams.Values['PWD'];
       FParams.Values['UID'] := LoginParams.Values['UID'];
       FParams.Values['PWD'] := LoginParams.Values['PWD'];
     finally
       LoginParams.Free;
     end;
  end else
      Password := FParams.Values['PWD'];
end;

Procedure TmySQLDatabase.DoConnect;
const
  OpenModes: array[Boolean] of DbiOpenMode = (dbiReadWrite, dbiReadOnly);
  ShareModes: array[Boolean] of DbiShareMode = (dbiOpenShared, dbiOpenExcl);
var
  DBPassword: String;
  ParamList : TStrings;
  RetCode : Word;

procedure CheckDB;
begin
  ParamList.Assign(FParams);
end;

function GetCP : TConvertChar;
begin
   if (FHandle <> nil) then
      Result := GetCharSet else
      Result := ccUndefine;
end;

begin
  if FHandle = nil then
  begin
    InitEngine;
    try
      try
        CheckDatabase(DBPassword);
        try
          ParamList := TStringList.Create;
          Try
            CheckDB;
            {$IFDEF TRIAL}
            with TMySQLAboutComp.Create(Application) do
            try
              Caption := 'Thank you for trying mySQLDAC';
              VersionLabel.Caption := 'V.'+mySQLDBTables.VERSION;
              Label1.Caption := Self.ClassName;
              RegLabel.Caption := 'Trial version.';
              ShowModal;
            finally
              Free;
            end;
            {$ENDIF}
            FEngine.SSLKey := SSLKey;
            FEngine.SSLCert := SSLCert;
            RetCode := Engine.OpenDatabase(FConnectOptions,ParamList, FHandle);
            if Assigned(FOnConnectionFailure) then
            begin
               if RetCode <> 0 then
               begin
                  FOnConnectionFailure(Self, Engine.MessageStatus);
                  Exit;
               end;
            end else
              Check(Engine, RetCode);
          Finally
             ParamList.Free
          end;
          SetBoolProp(Engine, FHandle, dbUSESCHEMAFILE,        TRUE);
          SetBoolProp(Engine, FHandle, dbPARAMFMTQMARK,        TRUE);
          SetBoolProp(Engine, FHandle, dbCOMPRESSARRAYFLDDESC, TRUE);
          SetDatabaseFlags;
        except
          raise;
        end;
      finally
        DBCharSet := GetCP;
      end;
    finally
    end;
  end;
end;

Procedure TmySQLDatabase.ParamsChanging(Sender: TObject);
begin
  if FCheckIfActiveOnParamChange then CheckInactive;    // ptook
end;

Procedure TmySQLDatabase.SetDatabaseName(const Value : String);
begin
    if csReading in ComponentState then
    begin
       FDatabaseName := Value;
       FParams.Values['DatabaseName'] := FDatabaseName;
    end
    else
    if FDatabaseName <> Value then
    begin
      if FCheckIfActiveOnParamChange then CheckInactive;    // ptook
      FDatabaseName := Value;
      FParams.Values['DatabaseName'] := FDatabaseName;
    end;
end;

Procedure TmySQLDatabase.SetServerPort(const Value : Cardinal);
begin
   if csReading in ComponentState then
    begin
       FPort := Value;
       FParams.Values['Port'] := IntToStr(FPort);
    end
    else
    if FPort <> Value then
    begin
      if FCheckIfActiveOnParamChange then CheckInactive;    // ptook
      FPort := Value;
      FParams.Values['Port'] := IntToStr(FPort);
    end;
end;

procedure TmySQLDatabase.SetMT(const Value : Boolean);
begin
   if FMT <> Value then
      FMT := Value;
end;

procedure TmySQLDatabase.SetSSLKey(const Value : String);
begin
   if FSSL_Key <> Value then
      FSSL_Key := Value;
end;

procedure TmySQLDatabase.SetSSLCert(const Value : String);
begin
   if FSSL_Cert <> Value then
      FSSL_Cert := Value;
end;


Procedure TmySQLDatabase.SetHost(const Value : String);
begin
    if FHost <> Value then
    begin
      if FCheckIfActiveOnParamChange then CheckInactive;    // ptook
      FHost := Value;
      FParams.Values['Host'] := FHost;
    end;
end;

Procedure TmySQLDatabase.SetUserName(const Value : String);
begin
    if FUserName <> Value then
    begin
      if FCheckIfActiveOnParamChange then CheckInactive;    // ptook
      FUserName := Value;
      FParams.Values['UID'] := FUserName;
    end;
end;

Procedure TmySQLDatabase.SetTimeout(const Value : Cardinal);
begin
    if csReading in ComponentState then
    begin
       FTimeout := Value;
       FParams.Values['TIMEOUT'] := IntToStr(FTimeout);
    end
    else
    if FTimeout <> Value then
    begin
      if FCheckIfActiveOnParamChange then CheckInactive;  // ptook
      FTimeout := Value;
      FParams.Values['TIMEOUT'] := IntToStr(FTimeout);
    end;
end;

Procedure TmySQLDatabase.SetUserPassword(const Value : String);
begin
    if FUserPassword <> Value then
    begin
      if FCheckIfActiveOnParamChange then CheckInactive; // ptook
      FUserPassword := Value;
      FParams.Values['PWD'] := FUserPassword;
    end;
end;

Procedure TmySQLDatabase.SetHandle(Value: HDBIDB);
begin
  if Connected then Close;
  if Value <> nil then
  begin
    FHandle := Value;
    SetDatabaseFlags;
    FAcquiredHandle := TRUE;
  end;
end;

Procedure TmySQLDatabase.SetKeepConnection(Value: Boolean);
begin
  if FKeepConnection <> Value  then
    FKeepConnection := Value;
end;

procedure TmySQLDatabase.SetParams(Value: TStrings);
begin
  if FCheckIfActiveOnParamChange then CheckInactive;  // ptook
  FParams.Assign(Value);
end;

Procedure TmySQLDatabase.SetExclusive(Value: Boolean);
begin
  if FCheckIfActiveOnParamChange then CheckInactive;  // ptook
  FExclusive := Value;
end;

Procedure TmySQLDatabase.SetReadOnly(Value: Boolean);
begin
  if FCheckIfActiveOnParamChange then CheckInactive;  // ptook
  FReadOnly := Value;
end;

Function TmySQLDatabase.Engine : TmySQLEngine;
begin
  Result := FEngine;
end;

Procedure TmySQLDatabase.GetTableNames(Pattern: String; List: TStrings; Views: Boolean = False);
var
  WildCard: PChar;
   SPattern: DBITBLNAME;
begin
  List.BeginUpdate;
  try
    if Handle = nil then Connected := True;
    List.Clear;
    WildCard := nil;
    if Pattern <> '' then
      WildCard := TAnsiToNative(Engine, Pattern, SPattern, SizeOf(SPattern)- 1);
    Check(Engine, Engine.OpenTableList(Handle,WildCard, Views, List));
  finally
    List.EndUpdate;
  end;
end;

procedure TMySQLDatabase.GetFieldNames(const TableName : String; List : TStrings);
var
   Cursor: HDBICur;
   Name: string;
   Desc: FLDDesc;
begin
  List.BeginUpdate;
  try
    List.Clear;
    if Tablename = EmptyStr then Exit;
    if Handle = nil then Connected := True;
    if Handle = nil then Exit;
    try
      while not (Engine.OpenFieldList(Handle,PChar(TableName), nil, FALSE, Cursor) = 0) do {Retry};
      try
        while Engine.GetNextRecord(Cursor, dbiNOLOCK, @Desc, nil) = 0 do
          with Desc do
          begin
            TNativeToAnsi(Engine, szName, Name);
            List.Add(Name);
          end;
      finally
        Engine.CloseCursor(Cursor);
      end;
    finally
      CloseDatabase;
    end;
  finally
    List.EndUpdate;
  end;
end;

function TmySQLDatabase.GetClientInfo: string;
begin
   Engine.GetClientInfo(Result);
end;

function TmySQLDatabase.GetServerStat: string;
begin
   if Connected then
      Engine.GetServerStat(Handle,Result) else
      Result := '';
end;

function TmySQLDatabase.GetHostInfo: string;
begin
  if Connected then
    Engine.GetHostInfo(Handle,Result) else
    Result := '';
end;

function TmySQLDatabase.GetProtoInfo: Cardinal;
begin
   if Connected then
      Engine.GetProtoInfo(Handle,Result) else
      Result := 0;
end;

function TmySQLDatabase.GetServerInfo: string;
begin
   if Connected then
      Engine.GetServerInfo(Handle,Result) else
      Result := '';
end;

procedure TmySQLDatabase.SelectDB(DBName : String);
begin
    Check(Engine,Engine.SelectDb(Handle,PChar(DBName)));
end;

function TmySQLDatabase.GetCharSet: TConvertChar;
begin
  if Connected then
    Engine.GetCharacterSet(Handle,Result) else
    result := ccUndefine;
end;

function TmySQLDatabase.Ping : integer;
var
   OldConn : Boolean;
begin
   OldConn := Connected;
   if Handle = nil then Connected := True;
   Engine.Ping(Handle,result);
   Connected := OldConn;
end;

function TmySQLDatabase.Shutdown: integer;    // ptook
begin
  if Handle = nil then Connected := True;
  Engine.Shutdown(Handle, Result);
end;

procedure TmySQLDatabase.Kill(PID : Integer);
begin
    Check(Engine,Engine.Kill(Handle,PID));
end;

procedure TmySQLDatabase.GetDatabases(Pattern: String;List : TStrings);
var
   OldConn : Boolean;
   OldDbName : string;
begin
   OldConn := Connected;
   OldDbName := '';
   if not Connected then
   begin
      OldDbName := DatabaseName;
      DatabaseName := '';
   end;
   if Handle = nil then Connected := True;
   if Pattern <> '' then
      Check(Engine, Engine.GetDatabases(Handle,PChar(Pattern),List)) else
      Check(Engine, Engine.GetDatabases(Handle,nil,List));
   Connected := OldConn;
   if not Connected then
     DatabaseName := OldDbName;
end;



{ TmySQLDataSet }
constructor TmySQLDataSet.Create(AOwner : TComponent);
begin
  Inherited Create(AOwner);
  FCacheBlobs := True;
  NestedDataSetClass := nil;
  FAutoRefresh := FALSE;
  FAllowSequenced := False; 
end;

destructor TmySQLDataSet.Destroy;
begin
  Inherited Destroy;
  if FBlockReadBuf <> nil then
  begin
    FreeMem(FBlockReadBuf);
    FBlockReadBuf := nil;
  end;
  SetUpdateObject(nil);
end;

//////////////////////////////////////////////////////////
//Procedure   : TmySQLDataSet.OpenCursor
//Description : Open cursor
//////////////////////////////////////////////////////////
//Input       : InfoQuery: Boolean
//////////////////////////////////////////////////////////
Procedure TmySQLDataSet.OpenCursor(InfoQuery: Boolean);
begin
  if Database=nil then raise EDatabaseError.Create(Format('(%s) property Database is not set!',[Self.Name]));
  If FHandle = nil then FHandle := CreateHandle;
  if FHandle = nil then
  begin
    FreeTimer(TRUE);
    raise ENoResultSet.Create(SHandleError);
  end;
  SetDBFlag(dbfOpened, TRUE);
  Inherited OpenCursor(InfoQuery);
  SetUpdateMode(FUpdateMode);
  SetupAutoRefresh;
end;

//////////////////////////////////////////////////////////
//Procedure   : TmySQLDataSet.CloseCursor
//Description : Close cursor
//////////////////////////////////////////////////////////
Procedure TmySQLDataSet.CloseCursor;
begin
  Inherited CloseCursor;
  if FHandle <> nil then
  begin
    DestroyHandle;
    FHandle := nil;
  end;
  FParentDataSet := nil;
  SetDBFlag(dbfOpened, FALSE);
end;

//////////////////////////////////////////////////////////
//Function    : TmySQLDataSet.CreateHandle
//Description : Virtual method Create Handle will be overwritten
//              in TmySQLQuery and TmySQLTable
//////////////////////////////////////////////////////////
//Output      : Result: HDBICur
//////////////////////////////////////////////////////////
Function TmySQLDataSet.CreateHandle: HDBICur;
begin
  Result := nil;
end;

Procedure TmySQLDataSet.DestroyHandle;
begin
  Engine.CloseCursor(FHandle);
end;

Procedure TmySQLDataSet.InternalInitFieldDefs;
var
  I, FieldID: Integer;
  FieldDescs: TFieldDescList;
  ValCheckDesc: VCHKDesc;
  RequiredFields: TBits;
  CursorProps: CurProps;
  FldDescCount,
  MaxFieldID,
  HiddenFieldCount: Integer;
begin
  Engine.GetCursorProps(FHandle, CursorProps);
  FldDescCount := CursorProps.iFields;
  HiddenFieldCount := 0;
  if FieldDefs.HiddenFields then
  begin
    if SetBoolProp(Engine, Handle, curGETHIDDENCOLUMNS, TRUE) then
    begin
      Engine.GetCursorProps(FHandle, CursorProps);
      HiddenFieldCount := CursorProps.iFields - FldDescCount;
      FldDescCount := CursorProps.iFields;
    end;
  end;
  RequiredFields := TBits.Create;
  try
    MaxFieldID := GetIntProp(Engine, Handle, curMAXFIELDID);
    if MaxFieldID > 0 then
      RequiredFields.Size := MaxFieldID + 1 else
      RequiredFields.Size := FldDescCount + 1;
    for I := 1 to CursorProps.iValChecks do
    begin
      Engine.GetVChkDesc(FHandle, I, @ValCheckDesc);
      if ValCheckDesc.bRequired and not ValCheckDesc.bHasDefVal then
         RequiredFields[ValCheckDesc.iFldNum] := TRUE;
    end;
    SetLength(FieldDescs, FldDescCount);
    Engine.GetFieldDescs(FHandle, PFLDDesc(FieldDescs));
    FieldID := FieldNoOfs;
    I := FieldID - 1;
    FieldDefs.Clear;
    while (I < FldDescCount) do
      AddFieldDesc(FieldDescs, I, FieldID, RequiredFields, FieldDefs);
    if FieldDefs.HiddenFields then
    begin
      SetBoolProp(Engine, Handle, curGETHIDDENCOLUMNS, FALSE);
      if (HiddenFieldCount > 0) then
        for I := FldDescCount - HiddenFieldCount to Pred(FldDescCount) do
          FieldDefs[ I ].Attributes := FieldDefs[ I ].Attributes + [ faHiddenCol ];
    end;
  finally
    RequiredFields.Free;
  end;
end;

Procedure TmySQLDataSet.GetObjectTypeNames(Fields: TFields);
var
  Len: Word;
  I: Integer;
  TypeDesc: ObjTypeDesc;
  ObjectField: TObjectField;
begin
  for I := 0 to Pred(Fields.Count) do
    if (Fields[ I ] is TObjectField) then
    begin
      ObjectField := TObjectField(Fields[ I ]);
      TypeDesc.iFldNum := ObjectField.FieldNo;
      if (Engine.GetEngProp(hDBIObj(Handle), curFIELDTYPENAME, @TypeDesc,
        SizeOf(TypeDesc), Len) = DBIERR_NONE) and (Len > 0) then
        ObjectField.ObjectType := TypeDesc.szTypeName;
      with ObjectField do
	  begin
        if DataType in [ftADT, ftArray] then
        begin
          if (DataType = ftArray) and SparseArrays and (Fields[ 0 ].DataType = ftADT) then
            GetObjectTypeNames(TObjectField(Fields[ 0 ]).Fields)
          else
            GetObjectTypeNames(Fields);
        end;
      end;
    end
end;

Procedure TmySQLDataSet.InternalOpen;
var
  CursorProps: CurProps;
begin
  Engine.GetCursorProps(FHandle, CursorProps);
  FRecordSize := CursorProps.iRecBufSize;
  BookmarkSize := CursorProps.iBookmarkSize;
  FCanModify := (CursorProps.eOpenMode = dbiReadWrite) and not CursorProps.bTempTable;
  FRecNoStatus := TRecNoStatus(CursorProps.ISeqNums);
  FieldDefs.Updated := FALSE;
  FieldDefs.Update;
  GetIndexInfo;
  if DefaultFields then CreateFields;
  BindFields(TRUE);
  if ObjectView then GetObjectTypeNames(Fields);
  InitBufferPointers(FALSE);
  AllocKeyBuffers;
  Engine.SetToBegin(FHandle);
  PrepareCursor;
  if Filter <> '' then FExprFilter := CreateExprFilter(Filter, FilterOptions, 0);
  if Assigned(OnFilterRecord) then FFuncFilter := CreateFuncFilter(@TmySQLDataSet.RecordFilter, 1);
  if Filtered then ActivateFilters;
  if Trim(FSortFieldNames) <> '' then//mi
	  TNativeDataSet(FHandle).SortBy(FSortFieldNames);
end;

Procedure TmySQLDataSet.InternalClose;
begin
  FFuncFilter := nil;
  FExprFilter := nil;
  FreeKeyBuffers;
  BindFields(FALSE);
  if DefaultFields then DestroyFields;
  FIndexFieldCount := 0;
  FKeySize := 0;
  FExpIndex := FALSE;
  FCaseInsIndex := FALSE;
  FCanModify := FALSE;
end;

Procedure TmySQLDataSet.PrepareCursor;
begin
end;

Function TmySQLDataSet.IsCursorOpen: Boolean;
begin
  Result := Handle <> nil;
end;

Procedure TmySQLDataSet.InternalHandleException;
begin
  Application.HandleException(Self)
end;

////////////////////////////////////////////////////////////
//                Record Functions                        //
////////////////////////////////////////////////////////////
Procedure TmySQLDataSet.InitBufferPointers(GetProps: Boolean);
var
  CursorProps: CurProps;
begin
  if GetProps then
  begin
    Check(Engine, Engine.GetCursorProps(FHandle, CursorProps));
    BookmarkSize := CursorProps.iBookmarkSize;
    FRecordSize  := CursorProps.iRecBufSize;
  end;
  FBlobCacheOfs := FRecordSize   + CalcFieldsSize;
  FRecInfoOfs   := FBlobCacheOfs + BlobFieldCount * SizeOf(Pointer);
  FBookmarkOfs  := FRecInfoOfs   + SizeOf(TRecInfo);
  FRecBufSize   := FBookmarkOfs  + BookmarkSize;
end;

Function TmySQLDataSet.AllocRecordBuffer: PChar;
begin
   Result := AllocMem(FRecBufSize);
end;

Procedure TmySQLDataSet.FreeRecordBuffer(var Buffer : PChar);
begin
  Engine.CheckBuffer(FHandle, Buffer); //:CN 29/05/2005
  ClearBlobCache(Buffer);
  FreeMem(Buffer);
  Buffer := nil;
end;

Procedure TmySQLDataSet.InternalInitRecord(Buffer : PChar);
begin
  Engine.InitRecord(FHandle, Buffer);
end;

Procedure TmySQLDataSet.ClearBlobCache(Buffer : PChar);
var
  I: Integer;
begin
  if FCacheBlobs then
    for I := 0 to BlobFieldCount - 1 do
      TBlobDataArray(Buffer + FBlobCacheOfs)[I] := '';
end;

Procedure TmySQLDataSet.ClearCalcFields(Buffer : PChar);
begin
  FillChar(Buffer[RecordSize], CalcFieldsSize, 0);
end;

Procedure TmySQLDataSet.InitRecord(Buffer : PChar);
begin
  Inherited InitRecord(Buffer);
  ClearBlobCache(Buffer);
  with PRecInfo(Buffer + FRecInfoOfs)^ do
  begin
    UpdateStatus := TUpdateStatus(usInserted);
    BookMarkFlag := bfInserted;
    RecordNumber := -1;
  end;
end;

Function TmySQLDataSet.GetRecord(Buffer: PChar; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
var
  Status: DBIResult;
begin
  case GetMode of
    gmCurrent: Status := Engine.GetRecord(FHandle, dbiNoLock, Buffer, @FRecProps);
    gmNext:    Status := Engine.GetNextRecord(FHandle, dbiNoLock, Buffer, @FRecProps);
    gmPrior:   Status := Engine.GetPriorRecord(FHandle, dbiNoLock, Buffer, @FRecProps);
  else
    Status := DBIERR_NONE;
  end;
  case Status of
    DBIERR_NONE:
      begin
        with PRecInfo(Buffer + FRecInfoOfs)^ do
        begin
          UpdateStatus := TUpdateStatus(FRecProps.iRecStatus);
          BookmarkFlag := bfCurrent;
          case FRecNoStatus of
            rnParadox: RecordNumber := FRecProps.iSeqNum;
            rnDBase: RecordNumber := FRecProps.iPhyRecNum;
          else
            RecordNumber := -1;
          end;
        end;
        ClearBlobCache(Buffer);
        GetCalcFields(Buffer);
        Check(Engine, Engine.GetBookmark(FHandle, Buffer + FBookmarkOfs));
        Result := grOK;
      end;
    DBIERR_BOF: Result := grBOF;
    DBIERR_EOF: Result := grEOF;
  else
    Result := grError;
    if DoCheck then
       Check(Engine, Status);
  end;
end;

Function TmySQLDataSet.GetCurrentRecord(Buffer: PChar): Boolean;
begin
  if not IsEmpty and (GetBookmarkFlag(ActiveBuffer) = bfCurrent) then
  begin
    UpdateCursorPos;
    Result := (Engine.GetRecord(FHandle, dbiNoLock, Buffer, nil) = DBIERR_NONE);
  end else
    Result := FALSE;
end;

Function TmySQLDataSet.GetOldRecord: PChar;
begin
  UpdateCursorPos;
  if SetBoolProp(Engine, Handle, curDELAYUPDGETOLDRECORD, TRUE) then
  try
    AllocCachedUpdateBuffers(True);
    Check(Engine, Engine.GetRecord(FHandle, dbiNoLock, FUpdateCBBuf.pOldRecBuf, nil));
    Result := PChar(FUpdateCBBuf.pOldRecBuf);
    AllocCachedUpdateBuffers(False); 
  finally
    SetBoolProp(Engine, Handle, curDELAYUPDGETOLDRECORD, FALSE);
  end else
    Result := nil;
end;

Procedure TmySQLDataSet.FetchAll;
begin
  if not EOF then
  begin
    CheckBrowseMode;
    Check(Engine, Engine.SetToEnd(Handle));
    Check(Engine, Engine.GetPriorRecord(FHandle, dbiNoLock, nil, nil));
    CursorPosChanged;
  end;
end;

Procedure TmySQLDataSet.FlushBuffers;
begin
  CheckBrowseMode;
end;

Function TmySQLDataSet.GetRecordCount: Integer;
begin
  CheckActive;
  if Engine.GetRecordCount(FHandle, Result) <> DBIERR_NONE then
    Result := -1;
end;

Function TmySQLDataSet.GetRecNo: Integer;
var
  BufPtr: PChar;
begin
  CheckActive;
  if (State = dsCalcFields) then
    BufPtr := CalcBuffer else
    BufPtr := ActiveBuffer;
  Result := PRecInfo(BufPtr + FRecInfoOfs).RecordNumber;
end;

Procedure TmySQLDataSet.SetRecNo(Value : Integer);
begin
  CheckBrowseMode;
  if (FRecNoStatus = rnParadox) and (Value <> RecNo) then
  begin
     if (Engine.SetToSeqNo(Handle, Value) = DBIERR_NONE) then
     Resync([ rmCenter ]);
  end;
end;

Function TmySQLDataSet.GetRecordSize: Word;
begin
  Result := FRecordSize;
end;

Function TmySQLDataSet.GetActiveRecBuf(var RecBuf: PChar): Boolean;
begin
  case State of
    dsBlockRead: RecBuf := FBlockReadBuf + (FBlockBufOfs * FRecordSize);
	 dsBrowse: if IsEmpty then RecBuf := nil else RecBuf := ActiveBuffer;
    dsEdit, dsInsert: RecBuf := ActiveBuffer;
    dsSetKey: RecBuf := PChar(FKeyBuffer) + SizeOf(TKeyBuffer);
    dsCalcFields: RecBuf := CalcBuffer;
    dsFilter: RecBuf := FFilterBuffer;
    dsNewValue: if FInUpdateCallback then
                   RecBuf := FUpdateCBBuf.pNewRecBuf else
                   RecBuf := ActiveBuffer;
    dsOldValue: if FInUpdateCallback then
                   RecBuf := FUpdateCBBuf.pOldRecBuf else
                   RecBuf := GetOldRecord;
  else
    RecBuf := nil;
  end;
  Result := RecBuf <> nil;
end;

Procedure TmySQLDataSet.AddFieldDesc(FieldDescs: TFieldDescList; var DescNo: Integer;
  var FieldID: Integer; RequiredFields: TBits; FieldDefs: TFieldDefs);
var
  FType: TFieldType;
  FSize: Word;
  FRequired: Boolean;
  FPrecision, I: Integer;
  FieldName, FName: string;
  FieldDesc: FLDDesc;
begin
  FieldDesc := FieldDescs[DescNo];
  Inc(DescNo);
  with FieldDesc do
  begin
    TNativeToAnsi(Engine, szName, FieldName);
    I := 0;
    FName := FieldName;
    while FieldDefs.IndexOf(FName) >= 0 do
    begin
      Inc(I);
      FName := Format('%s_%d', [FieldName, I]);
    end;
    if iFldType < MAXLOGFLDTYPES then
      FType := DataTypeMap[iFldType] else
      FType := ftUnknown;
    FSize := 0;
    FPrecision := 0;
    if RequiredFields.Size > FieldID then
      FRequired := RequiredFields[FieldID] else
      FRequired := FALSE;
    case iFldType of
      fldZSTRING, fldBYTES, fldVARBYTES, fldADT, fldArray, fldRef:
        begin
          if iUnits1 = 0 then
            FType := ftUnknown  else
            FSize := iUnits1;
        end;
      fldINT16, fldUINT16:
        if iLen = 1 then
          FType := ftSmallInt else
          if iLen <> 2 then FType := ftUnknown;
      fldINT32, fldUINT32:  //:CN 06/05/2005
        if iSubType = fldstAUTOINC then
        begin
          FType := ftAutoInc;
          FRequired := FALSE;
        end;
      fldINT64, fldUINT64: //:CN 06/05/2005                           
        if iSubType = fldstAUTOINC then
        begin
          FRequired := FALSE;
        end;
      fldFLOAT: if iSubType = fldstMONEY then FType := ftCurrency;
      fldBCD:
        begin
          FSize := Abs(iUnits2);
          FPrecision := iUnits1;
        end;
      fldBLOB:
        begin
          FSize := iUnits1;
          if (iSubType >= fldstMEMO) and (iSubType <= fldstBFILE) then
            FType := BlobTypeMap[iSubType];
        end;
      fldTIMESTAMP
      {$IFDEF DELPHI_6}
      ,fldDATETIME
      {$ENDIF}: begin
                    if iUnUsed[0] = FIELD_TYPE_TIMESTAMP then
                       FRequired := FALSE;
                end;
    end;
    with FieldDefs.AddFieldDef do
    begin
      FieldNo := FieldID;
      Inc(FieldID);
      Name := FName;
      DataType := FType;
      Size := FSize;
      Precision := FPrecision;
      if FRequired then Attributes := [faRequired];
      if efldrRights = fldrREADONLY then Attributes := Attributes + [faReadonly];
      if iSubType = fldstFIXED then
        Attributes := Attributes + [faFixed];
      InternalCalcField := bCalcField;
      case FType of
        ftADT:
          begin
            if (iSubType = fldstADTNestedTable) then
              Attributes := Attributes + [faUnNamed];
            for I := 0 to iUnits1 - 1 do
              AddFieldDesc(FieldDescs, DescNo, FieldID, RequiredFields, ChildDefs);
          end;
        ftArray:
          begin
            I := FieldID;
            StrCat(StrCopy(FieldDescs[DescNo].szName, FieldDesc.szName),'[0]');
            AddFieldDesc(FieldDescs, DescNo, I, RequiredFields, ChildDefs);
            Inc(FieldID, iUnits2);
          end;
      end;
    end;
  end;
end;

Function TmySQLDataSet.GetBlobFieldData(FieldNo: Integer; var Buffer: TBlobByteData): Integer;
var
  RecBuf: PChar;
  Status: DBIResult;
  DoCheck: Boolean;
begin
  Result := 0;
  DoCheck := BlockReadSize = 0;
  if BlockReadSize > 0 then
    RecBuf := FBlockReadBuf + (FBlockBufOfs * FRecordSize) else
    if not GetActiveRecBuf(RecBuf) then Exit;
  Status := Engine.OpenBlob(FHandle, RecBuf, FieldNo, dbiReadOnly);
  if Status <> DBIERR_NONE then Exit;
  try
    Status := Engine.GetBlobSize(FHandle, RecBuf, FieldNo, Result);
    if (Status <> DBIERR_NONE) or (Result = 0) then Exit;
    if Length(Buffer) <= Result then
      SetLength(Buffer, Result + Result div 4);
    Status := Engine.GetBlob(FHandle, RecBuf, FieldNo, 0, Result, Buffer, Result);
  finally
    if Status <> DBIERR_NONE then Result := 0;
    Engine.FreeBlob(FHandle, RecBuf, FieldNo);
    if DoCheck then Check(Engine, Status)
  end;
end;

Function TmySQLDataSet.GetFieldData(FieldNo: Integer; Buffer: Pointer): Boolean;
var
  IsBlank: LongBool;
  RecBuf: PChar;
  Status: DBIResult;
begin
  if BlockReadSize > 0 then
  begin
    Status := Engine.GetField(FHandle, FieldNo, FBlockReadBuf +
      (FBlockBufOfs * FRecordSize), Buffer, IsBlank);
    Result := (Status = DBIERR_NONE) and not IsBlank;
  end
  else
  begin
	 Result := GetActiveRecBuf(RecBuf);
    if Result then
    begin
		Check(Engine, Engine.GetField(FHandle, FieldNo, RecBuf, Buffer, IsBlank));
      Result := not IsBlank;
    end
  end;
end;

Function TmySQLDataSet.GetFieldData(Field: TField; Buffer: Pointer): Boolean;
var
  RecBuf: PChar;
begin
  if Field.FieldNo > 0 then
    Result := GetFieldData(Field.FieldNo, Buffer)
  else
  begin
    if State = dsBlockRead then
    begin
      RecBuf := TempBuffer;
      Result := True;
    end else
      Result := GetActiveRecBuf(RecBuf);
    if Result and (State in [dsBrowse, dsEdit, dsInsert, dsCalcFields, dsBlockRead]) then
    begin
      Inc(RecBuf, FRecordSize + Field.Offset);
      Result := Boolean(RecBuf[0]);
      if Result and (Buffer <> nil) then
        Move(RecBuf[1], Buffer^, Field.DataSize);
    end;
  end;
end;

Procedure TmySQLDataSet.SetFieldData(Field: TField; Buffer: Pointer);
var
  RecBuf: PChar;
begin
  with Field do
  begin
    if not (State in dsWriteModes) then
      DatabaseError(SNotEditing, Self);
    if not (State in dsWriteModes) then
      DatabaseError(SNotEditing, Self);
    if (State = dsSetKey) and ((FieldNo < 0) or (FIndexFieldCount > 0) and
      not IsIndexField) then
        DatabaseErrorFmt(SNotIndexField, [DisplayName], Self);
    GetActiveRecBuf(RecBuf);
    if (FieldNo > 0) then
    begin
      if (State = dsCalcFields) then DatabaseError(SNotEditing);
      if ReadOnly and not (State in [dsSetKey, dsFilter]) then
        DatabaseErrorFmt(SFieldReadOnly, [DisplayName]);
      Validate(Buffer);
      if FieldKind <> fkInternalCalc then
        Check(Engine, Engine.PutField(FHandle, FieldNo, RecBuf, Buffer));
    end
    else {fkCalculated, fkLookup}
    begin
      Inc(RecBuf, FRecordSize + Offset);
      Boolean(RecBuf[0]) := LongBool(Buffer);
      if Boolean(RecBuf[ 0 ]) then
        Move(Buffer^, RecBuf[ 1 ], DataSize);
    end;
    if not (State in [dsCalcFields, dsFilter, dsNewValue]) then
      DataEvent(deFieldChange, Longint(Field));
  end;
end;

Function TmySQLDataSet.GetBlobData(Field : TField; Buffer : PChar) : TBlobData;
begin
  Result := TBlobDataArray(Buffer + FBlobCacheOfs)[Field.Offset];
end;

Procedure TmySQLDataSet.SetBlobData(Field : TField; Buffer : PChar; Value : TBlobData);
begin
  if (Buffer = ActiveBuffer) then
    TBlobDataArray(Buffer + FBlobCacheOfs)[Field.Offset] := Value;
end;

Function TmySQLDataSet.CreateBlobStream(Field : TField; Mode : TBlobStreamMode) : TStream;
begin
  Result := TmySQLBlobStream.Create(Field as TBlobField, Mode);
end;

Procedure TmySQLDataSet.CloseBlob(Field: TField);
begin
  Engine.FreeBlob(Handle, ActiveBuffer, Field.FieldNo);
end;

Function TmySQLDataSet.GetStateFieldValue(State: TDataSetState; Field: TField): Variant;
begin
  CheckCachedUpdateMode;
  Result := Inherited GetStateFieldValue(State, Field);
end;

Procedure TmySQLDataSet.SetStateFieldValue(State: TDataSetState; Field: TField; Const Value: Variant);
begin
  CheckCachedUpdateMode;
  Inherited SetStateFieldValue(State, Field, Value);
end;

Function TmySQLDataSet.Translate(Src, Dest: PChar; ToOem: Boolean) : Integer;
begin
  Result := StrLen(Src);
  if ToOem then
  begin
     if GetClientCP <> DBCharSet then
        TAnsiToNativeBuf(Engine, Src, Dest, Result) else
        Move(Src^,Dest^,StrLen(Src)+1);
  end else
  begin
     if GetClientCP <> DBCharSet then
        TNativeToAnsiBuf(Engine, Src, Dest, Result);
  end;
  if Src <> Dest then Dest[ Result ] := #0;
end;

Function TmySQLDataSet.GetFieldFullName(Field : TField) : string;
var
  Len: Word;
  AttrDesc: ObjAttrDesc;
  Buffer: array[0..1024] of Char;
begin
  if Field.FieldNo > 0  then
  begin
    AttrDesc.iFldNum := Field.FieldNo;
    AttrDesc.pszAttributeName := Buffer;
    Check(Engine, Engine.GetEngProp(HDBIOBJ(Handle), curFIELDFULLNAME, @AttrDesc, SizeOf(Buffer), Len));
    TNativeToAnsi(Engine, Buffer, Result);
  end else
    Result := inherited GetFieldFullName(Field);
end;

Procedure TmySQLDataSet.InternalFirst;
begin
  Check(Engine, Engine.SetToBegin(FHandle));
end;

Procedure TmySQLDataSet.InternalLast;
begin
  Check(Engine, Engine.SetToEnd(FHandle));
end;

Procedure TmySQLDataSet.InternalEdit;
begin
  FOldBuffer := AllocRecordBuffer;
  Move(ActiveBuffer^,FOldBuffer[0],FRecBufSize);
  Check(Engine, Engine.GetRecord(FHandle, dbiNoLock{dbiWriteLock}, ActiveBuffer, nil));
  ClearBlobCache(ActiveBuffer);
end;

Procedure TmySQLDataSet.InternalInsert;
begin
  SetBoolProp(Engine, Handle, curMAKECRACK, TRUE);
  CursorPosChanged;
end;

Procedure TmySQLDataSet.InternalPost;
begin
  {$IFDEF DELPHI_6}
  Inherited;
  {$ENDIF}
  if State = dsEdit then
     Check(Engine, Engine.ModifyRecord(FHandle,FOldBuffer, ActiveBuffer, TRUE)) else
     Check(Engine, Engine.InsertRecord(FHandle, dbiNoLock, ActiveBuffer));
  if assigned(fOldBuffer) then
  begin
     FreeMem(FOldBuffer);
     FOldBuffer := nil;
  end;
end;

Procedure TmySQLDataSet.InternalDelete;
var
  Result: Word;
begin
   Result := Engine.DeleteRecord(FHandle, ActiveBuffer);
   if (Result <> DBIERR_NONE) then Check(Engine, Result);
end;

Function TmySQLDataSet.IsSequenced: Boolean;
begin
  Result := (FRecNoStatus = rnParadox) and (not Filtered);
end;

Function TmySQLDataSet.GetCanModify: Boolean;
begin
  Result := FCanModify or ForceUpdateCallback;;
end;

Procedure TmySQLDataSet.InternalRefresh;
begin
    if (DataSetField <> nil) and (DataSetField.DataType = ftReference) then
       Check(Engine, Engine.ForceRecordReread(FHandle, ActiveBuffer)) else
       Check(Engine, Engine.ForceReread(FHandle));
end;

Procedure TmySQLDataSet.Post;
begin
  Inherited Post;
  if State = dsSetKey then
    PostKeyBuffer(TRUE);
end;

Procedure TmySQLDataSet.Cancel;
begin
  Inherited Cancel;
  if State = dsSetKey then
    PostKeyBuffer(FALSE);
end;

Procedure TmySQLDataSet.InternalCancel;
begin
  If State = dsEdit then
    Engine.RelRecordLock(FHandle, FALSE);
end;

Procedure TmySQLDataSet.InternalAddRecord(Buffer: Pointer; Append: Boolean);
begin
  if Append then
    Check(Engine,Engine.AppendRecord(FHandle,Buffer))  else
    Check(Engine,Engine.InsertRecord(FHandle,dbiNoLock,Buffer));
end;

Procedure TmySQLDataSet.InternalGotoBookmark(Bookmark : TBookmark);
begin
  Check(Engine, Engine.SetToBookmark(FHandle, Bookmark));
end;

Procedure TmySQLDataSet.InternalSetToRecord(Buffer : PChar);
begin
  InternalGotoBookmark(Buffer + FBookmarkOfs);
end;

Function TmySQLDataSet.GetBookmarkFlag(Buffer : PChar) : TBookmarkFlag;
begin
  Result := PRecInfo(Buffer + FRecInfoOfs).BookmarkFlag;
end;

Procedure TmySQLDataSet.SetBookmarkFlag(Buffer : PChar; Value : TBookmarkFlag);
begin
  PRecInfo(Buffer + FRecInfoOfs).BookmarkFlag := Value;
end;

Procedure TmySQLDataSet.GetBookmarkData(Buffer : PChar; Data : Pointer);
begin
  Move(Buffer[ FBookmarkOfs ], Data^, BookmarkSize);
end;

Procedure TmySQLDataSet.SetBookmarkData(Buffer : PChar; Data : Pointer);
begin
  Move(Data^, Buffer[ FBookmarkOfs ], BookmarkSize);
end;

Function TmySQLDataSet.CompareBookmarks(Bookmark1, Bookmark2 : TBookmark) : Integer;
const
  RetCodes: array[Boolean, Boolean] of ShortInt = ((2,CMPLess),(CMPGtr,CMPEql));
begin
  { Check for uninitialized bookmarks }
  Result := RetCodes[Bookmark1 = nil, Bookmark2 = nil];
  if (Result = 2) then
  begin
    if (Handle <> nil) then
      Check(Engine, Engine.CompareBookmarks(Handle, Bookmark1, Bookmark2, Result));
    if (Result = CMPKeyEql) then
      Result := CMPEql;
  end;
end;

Function TmySQLDataSet.BookmarkValid(Bookmark: TBookmark): Boolean;
begin
  Result := (Handle <> nil);
  if Result then
  begin
    CursorPosChanged;
    Result := (Engine.SetToBookmark(FHandle, Bookmark) = DBIERR_NONE) and
      (Engine.GetRecord(FHandle, dbiNOLOCK, nil, nil) = DBIERR_NONE)
  end;
end;

procedure TMySQLDataSet.SetBlockReadSize(Value: Integer);

  function CanBlockRead: Boolean;
  var
    i: Integer;
  begin
    Result := (BufferCount <= 1) and (DataSetField = nil);
    if Result then
      for i := 0 to FieldCount - 1 do
        if (Fields[i].DataType in [ftDataSet, ftReference]) then
        begin
          Result := False;
          break;
        end;
  end;

  procedure FreeBuffer;
  begin
    if FBlockReadBuf <> nil then
    begin
      FreeMem(FBlockReadBuf);
      FBlockReadBuf := nil;
    end;
  end;

const
  DEFBLOCKSIZE  = 64 * 1024;
var
  Size: Integer;
begin
  if Value <> BlockReadSize then
  begin
    if Value > 0 then
    begin
      if EOF or not CanBlockRead then Exit;
      FreeBuffer;
      UpdateCursorPos;
      Engine.SetEngProp(HDBIObj(FHandle), curMAKECRACK, 0);
      if Value = MaxInt then
        Size := DEFBLOCKSIZE else
        Size := Value * FRecordSize;
      FBlockReadBuf := AllocMem(Size);
      FBlockBufSize := Size div FRecordSize;
      FBlockBufOfs := FBlockBufSize; { Force read of data }
      FBlockBufCount := FBlockBufSize;
      FBlockReadCount := 0;
      inherited;
      BlockReadNext;
    end else
    begin
      inherited;
//      CursorPosChanged;
//      Resync([]);
      FreeBuffer;
    end;
  end;
end;

procedure TmySQLDataSet.BlockReadNext;
var
  Status: DbiResult;
begin
  if FBlockBufOfs >= FBlockBufCount - 1 then
  begin
    if FBlockBufCount < FBlockBufSize then Last else
    begin
      Status := Engine.ReadBlock(FHandle, FBlockBufCount, FBlockReadBuf);
      if (Status <> DBIERR_NONE) and (Status <> DBIERR_EOF) then
        Check(Engine,Status);
      if (FBlockBufCount = 0) and (Status = DBIERR_EOF) then Last;
      Inc(FBlockReadCount, FBlockBufCount);
      FBlockBufOfs := 0;
    end
  end else
    Inc(FBlockBufOfs);
  if CalcFieldsSize > 0 then
    GetCalcFields(TempBuffer);
  DataEvent(deDataSetScroll, -1);
end;

Procedure TmySQLDataSet.GetIndexInfo;
var
  IndexDesc: IDXDesc;
begin
  if Engine.GetIndexDesc(FHandle, 0, IndexDesc) = DBIERR_NONE then
  begin
    FExpIndex := IndexDesc.bExpIdx;
    FCaseInsIndex := IndexDesc.bCaseInsensitive;
    if not ExpIndex then
    begin
      FIndexFieldCount := IndexDesc.iFldsInKey;
      FIndexFieldMap := IndexDesc.aiKeyFld;
    end;
    FKeySize := IndexDesc.iKeyLen;
  end;
end;


Procedure TmySQLDataSet.SwitchToIndex(const IndexName, TagName : String);
var
  Status: DBIResult;
begin
  ResetCursorRange;
  UpdateCursorPos;
  Status := Engine.SwitchToIndex(FHandle, PChar(IndexName), PChar(TagName), 0, TRUE);
  if (Status = DBIERR_NOCURRREC) then
    Status := Engine.SwitchToIndex(FHandle, PChar(IndexName), PChar(TagName), 0, FALSE);
  Check(Engine, Status);
  FKeySize := 0;
  FExpIndex := FALSE;
  FCaseInsIndex := FALSE;
  FIndexFieldCount := 0;
  SetBufListSize(0);
  InitBufferPointers(TRUE);
  try
    SetBufListSize(BufferCount + 1);
  except
    SetState(dsInactive);
    CloseCursor;
    raise;
  end;
  GetIndexInfo;
end;

Function TmySQLDataSet.GetIndexField(Index : Integer): TField;
var
  FieldNo: Integer;
begin
  if (Index < 0) or (Index >= FIndexFieldCount) then DatabaseError(SFieldIndexError, Self);
  FieldNo := FIndexFieldMap[Index];
  Result := FieldByNumber(FieldNo);
  if Result = nil then DatabaseErrorFmt(SIndexFieldMissing, [FieldDefs[FieldNo - 1].Name], Self);
end;

Procedure TmySQLDataSet.SetIndexField(Index : Integer; Value : TField);
begin
  GetIndexField(Index).Assign(Value);
end;

Function TmySQLDataSet.GetIndexFieldCount: Integer;
begin
  Result := FIndexFieldCount;
end;

Procedure TmySQLDataSet.AllocKeyBuffers;
var
  KeyIndex: TKeyIndex;
begin
  try
    for KeyIndex := Low(TKeyIndex) to High(TKeyIndex) do
      FKeyBuffers[KeyIndex] := InitKeyBuffer(AllocMem(SizeOf(TKeyBuffer) + FRecordSize));
  except
    FreeKeyBuffers;
    raise;
  end;
end;

Procedure TmySQLDataSet.FreeKeyBuffers;
var
  KeyIndex: TKeyIndex;
begin
  for KeyIndex := Low(TKeyIndex) to High(TKeyIndex) do
    DisposeMem(FKeyBuffers[ KeyIndex ], SizeOf(TKeyBuffer) + FRecordSize);
end;

Function TmySQLDataSet.InitKeyBuffer(Buffer: PKeyBuffer): PKeyBuffer;
begin
  FillChar(Buffer^, SizeOf(TKeyBuffer) + FRecordSize, 0);
  Engine.InitRecord(FHandle, PChar(Buffer) + SizeOf(TKeyBuffer));
  Result := Buffer;
end;

Procedure TmySQLDataSet.CheckSetKeyMode;
begin
  if (State <> dsSetKey) then DatabaseError(SNotEditing, Self);
end;

Function TmySQLDataSet.SetCursorRange: Boolean;
var
  RangeStart, RangeEnd: PKeyBuffer;
  StartKey, EndKey: PChar;
  IndexBuffer: PChar;
  UseStartKey, UseEndKey, UseKey: Boolean;
begin
  Result := FALSE;
  if not (BuffersEqual(FKeyBuffers[kiRangeStart], FKeyBuffers[kiCurRangeStart],SizeOf(TKeyBuffer) + FRecordSize) and
          BuffersEqual(FKeyBuffers[kiRangeEnd], FKeyBuffers[kiCurRangeEnd],SizeOf(TKeyBuffer) + FRecordSize)) then
  begin
    IndexBuffer := AllocMem(KeySize * 2);
    try
      UseStartKey := TRUE;
      UseEndKey := TRUE;
      RangeStart := FKeyBuffers[kiRangeStart];
      if RangeStart.Modified then
      begin
        StartKey := PChar(RangeStart) + SizeOf(TKeyBuffer);
        UseStartKey := Engine.ExtractKey(Handle, StartKey, IndexBuffer) = 0;
      end
      else
        StartKey := nil;
      RangeEnd := FKeyBuffers[kiRangeEnd];
      if RangeEnd.Modified then
      begin
        EndKey := PChar(RangeEnd) + SizeOf(TKeyBuffer);
        UseEndKey := (Engine.ExtractKey(Handle, EndKey, IndexBuffer + KeySize) = 0);
      end
      else
        EndKey := nil;
      UseKey := UseStartKey and UseEndKey;
      if UseKey then
      begin
        if (StartKey <> nil) then
          StartKey := IndexBuffer;
        if (EndKey <> nil) then
          EndKey := IndexBuffer + KeySize;
      end;
      Check(Engine, Engine.SetRange(FHandle, UseKey,
        RangeStart.FieldCount, 0, StartKey, not RangeStart.Exclusive,
        RangeEnd.FieldCount, 0, EndKey, not RangeEnd.Exclusive));
      Move(FKeyBuffers[kiRangeStart]^, FKeyBuffers[kiCurRangeStart]^,
        SizeOf(TKeyBuffer) + FRecordSize);
      Move(FKeyBuffers[kiRangeEnd]^, FKeyBuffers[kiCurRangeEnd]^,
        SizeOf(TKeyBuffer) + FRecordSize);
      DestroyLookupCursor;
      Result := TRUE;
    finally
      FreeMem(IndexBuffer, KeySize * 2);
    end;
  end;
end;

Function TmySQLDataSet.ResetCursorRange: Boolean;
begin
  Result := FALSE;
  if FKeyBuffers[kiCurRangeStart].Modified or
    FKeyBuffers[kiCurRangeEnd].Modified then
  begin
    Check(Engine, Engine.ResetRange(FHandle));
    InitKeyBuffer(FKeyBuffers[kiCurRangeStart]);
    InitKeyBuffer(FKeyBuffers[kiCurRangeEnd]);
    DestroyLookupCursor;
    Result := TRUE;
  end;
end;

Procedure TmySQLDataSet.SetLinkRanges(MasterFields: TList);
var
  I: Integer;
  SaveState: TDataSetState;
begin
  SaveState := SetTempState(dsSetKey);
  try
    FKeyBuffer := InitKeyBuffer(FKeyBuffers[kiRangeStart]);
    FKeyBuffer^.Modified := TRUE;
    for I := 0 to Pred(MasterFields.Count) do
      GetIndexField(I).Assign(TField(MasterFields[I]));
    FKeyBuffer^.FieldCount := MasterFields.Count;
  finally
    RestoreState(SaveState);
  end;
  Move(FKeyBuffers[kiRangeStart]^, FKeyBuffers[kiRangeEnd]^,
    SizeOf(TKeyBuffer) + FRecordSize);
end;

Function TmySQLDataSet.GetKeyBuffer(KeyIndex: TKeyIndex): PKeyBuffer;
begin
  Result := FKeyBuffers[KeyIndex];
end;

Procedure TmySQLDataSet.SetKeyBuffer(KeyIndex: TKeyIndex; Clear: Boolean);
begin
  CheckBrowseMode;
  FKeyBuffer := FKeyBuffers[KeyIndex];
  Move(FKeyBuffer^, FKeyBuffers[kiSave]^, SizeOf(TKeyBuffer) + FRecordSize);
  if Clear then InitKeyBuffer(FKeyBuffer);
  SetState(dsSetKey);
  SetModified(FKeyBuffer.Modified);
  DataEvent(deDataSetChange, 0);
end;

Procedure TmySQLDataSet.PostKeyBuffer(Commit: Boolean);
begin
  DataEvent(deCheckBrowseMode, 0);
  if FKeyBuffer^.FieldCount = 0 then
     FKeyBuffer^.FieldCount := FIndexFieldCount;
  if Commit then
    FKeyBuffer.Modified := Modified
  else
    Move(FKeyBuffers[kiSave]^, FKeyBuffer^, SizeOf(TKeyBuffer) + FRecordSize);
  SetState(dsBrowse);
  DataEvent(deDataSetChange, 0);
end;

Function TmySQLDataSet.GetKeyExclusive: Boolean;
begin
  CheckSetKeyMode;
  Result := FKeyBuffer.Exclusive;
end;

Procedure TmySQLDataSet.SetKeyExclusive(Value: Boolean);
begin
  CheckSetKeyMode;
  FKeyBuffer.Exclusive := Value;
end;

Function TmySQLDataSet.GetKeyFieldCount: Integer;
begin
  CheckSetKeyMode;
  Result := FKeyBuffer.FieldCount;
end;

Procedure TmySQLDataSet.SetKeyFieldCount(Value: Integer);
begin
  CheckSetKeyMode;
  FKeyBuffer.FieldCount := Value;
end;

Procedure TmySQLDataSet.SetKeyFields(KeyIndex: TKeyIndex;
  const Values: array of const);
var
  I: Integer;
  SaveState: TDataSetState;
begin
  if ExpIndex then DatabaseError(SCompositeIndexError, Self);
  if FIndexFieldCount = 0 then DatabaseError(SNoFieldIndexes, Self);
  SaveState := SetTempState(dsSetKey);
  try
    FKeyBuffer := InitKeyBuffer(FKeyBuffers[KeyIndex]);
    for I := 0 to High(Values) do GetIndexField(I).AssignValue(Values[I]);
    FKeyBuffer^.FieldCount := High(Values) + 1;
    FKeyBuffer^.Modified := Modified;
  finally
    RestoreState(SaveState);
  end;
end;

Function TmySQLDataSet.GetIsIndexField(Field: TField): Boolean;
var
  I: Integer;
begin
  if (State = dsSetKey) and (FIndexFieldCount = 0) and FExpIndex then
    Result := True else
  begin
    Result := False;
    with Field do
      if FieldNo > 0 then
        for I := 0 to FIndexFieldCount - 1 do
         if FIndexFieldMap[I] = FieldNo then
          begin
            Result := True;
            Exit;
          end;
  end;
end;

Function TmySQLDataSet.MapsToIndex(Fields: TList; CaseInsensitive: Boolean): Boolean;
var
  I: Integer;
  HasStr : Boolean;
begin
  Result := False;
  HasStr := False;

  for I := 0 to Fields.Count - 1 do
  begin
	 HasStr := TField(Fields[I]).DataType in [ftString, ftFixedChar, ftWideString];
	 if HasStr then break;
  end;

  if (CaseInsensitive <> FCaseInsIndex) and HasStr then Exit;

  if Fields.Count > FIndexFieldCount then Exit;

  for I := 0 to Fields.Count - 1 do
	 if TField(Fields[I]).FieldNo <> Integer(FIndexFieldMap[I]) then  Exit;

  Result := True;
end;

Procedure TmySQLDataSet.Notification(AComponent: TComponent; Operation: TOperation);
begin
  Inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FDatabase) then
  begin
	 Close;
	 FDatabase := nil;
  end;
end;

Procedure TmySQLDataSet.ActivateFilters;
begin
  if FExprFilter <> nil then
  begin
    if Engine.ActivateFilter(FHandle, FExprFilter) <> DBIERR_NONE then
    begin
      Engine.DropFilter(FHandle, FExprFilter);
      FExprFilter := CreateExprFilter(Filter, FilterOptions, 0);
      Check(Engine, Engine.ActivateFilter(FHandle, FExprFilter));
    end;
  end;
  if FFuncFilter <> nil then
  begin
    if (Engine.ActivateFilter(FHandle, FFuncFilter) <> DBIERR_NONE) then
    begin
      Engine.DropFilter(FHandle, FFuncFilter);
      FFuncFilter := CreateFuncFilter(@TmySQLDataSet.RecordFilter, 1);
      Check(Engine, Engine.ActivateFilter(FHandle, FFuncFilter));
    end;
  end;
end;

Procedure TmySQLDataSet.DeactivateFilters;
begin
  if FFuncFilter <> nil then Check(Engine, Engine.DeactivateFilter(FHandle, FFuncFilter));
  if FExprFilter <> nil then Check(Engine, Engine.DeactivateFilter(FHandle, FExprFilter));
end;

Function TmySQLDataSet.CreateExprFilter(const Expr: String;
  Options: TFilterOptions; Priority: Integer): HDBIFilter;
var
  Parser: TExprParser;
begin
  Parser := TExprParser.Create(Self, Expr, Options, [], '', nil, FldTypeMap);
  try
    Check(Engine, Engine.AddFilter(FHandle, 0, Priority, FALSE, PCANExpr(Parser.FilterData), nil, Result));
  finally
    Parser.Free;
  end;
end;

Function TmySQLDataSet.CreateFuncFilter(FilterFunc: Pointer;Priority: Integer): HDBIFilter;
begin
  Check(Engine, Engine.AddFilter(FHandle, Integer(Self), Priority, FALSE, nil, PFGENFilter(FilterFunc), Result));
end;

{$WARNINGS OFF}
Function TmySQLDataSet.CreateLookupFilter(Fields: TList; const Values: Variant;
  Options: TLocateOptions; Priority: Integer): HDBIFilter;
var
  I: Integer;
  Filter: TFilterExpr;
  Expr, Node: PExprNode;
  FilterOptions: TFilterOptions;
begin
  if loCaseInsensitive in Options then
    FilterOptions := [foNoPartialCompare, foCaseInsensitive] else
    FilterOptions := [foNoPartialCompare];
  Filter := TFilterExpr.Create(Self, FilterOptions, [], '', nil, FldTypeMap);
  try
    if Fields.Count = 1 then
    begin
      if VarIsArray(Values) then
        Node := Filter.NewCompareNode(TField(Fields[0]), coEQ, Values[0]) else
        Node := Filter.NewCompareNode(TField(Fields[0]), coEQ, Values);
      Expr := Node;
    end
    else
      for I := 0 to Fields.Count-1 do
      begin
        Node := Filter.NewCompareNode(TField(Fields[I]),coEQ, Values[I]);
        if I = 0 then
          Expr := Node else
          Expr := Filter.NewNode(enOperator,coAND, Unassigned, Expr, Node);
      end;
    if loPartialKey in Options then Node^.FPartial := TRUE;
    Check(Engine, Engine.AddFilter(FHandle, 0, Priority, FALSE, PCANExpr(Filter.GetFilterData(Expr)), nil, Result));
  finally
    Filter.Free;
  end;
end;
{$WARNINGS ON}

Procedure TmySQLDataSet.SetFilterHandle(var Filter: HDBIFilter; Value: HDBIFilter);
begin
  if Filtered then
  begin
    CursorPosChanged;
    DestroyLookupCursor;
    Engine.SetToBegin(FHandle);
    if Filter <> nil then Engine.DropFilter(FHandle, Filter);
    Filter := Value;
    if Filter <> nil then Engine.ActivateFilter(FHandle, Filter);
  end else
  begin
    if Filter <> nil then Engine.DropFilter(FHandle, Filter);
    Filter := Value;
  end;
end;

Procedure TmySQLDataSet.SetFilterData(const Text: String; Options: TFilterOptions);
var
  HFilter: HDBIFilter;
begin
  if Active then
  begin
    CheckBrowseMode;
    if (Filter <> Text) or (FilterOptions <> Options) then
    begin
      if Text <> '' then
        HFilter := CreateExprFilter(Text, Options, 0) else
        HFilter := nil;
      SetFilterHandle(FExprFilter, HFilter);
    end;
  end;
  Inherited SetFilterText(Text);
  Inherited SetFilterOptions(Options);
  if Active and Filtered then First;
end;

Procedure TmySQLDataSet.SetFilterText(const Value: String);
begin
  SetFilterData(Value, FilterOptions);
end;

Procedure TmySQLDataSet.SetFiltered(Value: Boolean);
begin
  if Active then
  begin
    CheckBrowseMode;
    if Filtered <> Value then
    begin
      DestroyLookupCursor;
      Engine.SetToBegin(FHandle);
      if Value then
        ActivateFilters
      else
        DeactivateFilters;
      Inherited SetFiltered(Value);
    end;
    First;
  end else Inherited SetFiltered(Value);
end;

Procedure TmySQLDataSet.SetFilterOptions(Value: TFilterOptions);
begin
  SetFilterData(Filter, Value);
end;

Procedure TmySQLDataSet.SetOnFilterRecord(const Value: TFilterRecordEvent);
var
  Filter: HDBIFilter;
begin
  if Active then
  begin
    CheckBrowseMode;
    if Assigned(OnFilterRecord) <> Assigned(Value) then
    begin
      if Assigned(Value) then
        Filter := CreateFuncFilter(@TmySQLDataSet.RecordFilter, 1)  else
        Filter := nil;
      SetFilterHandle(FFuncFilter, Filter);
    end;
    Inherited SetOnFilterRecord(Value);
    if Filtered then
      First;
  end 
  else
    Inherited SetOnFilterRecord(Value);
end;

Function TmySQLDataSet.FindRecord(Restart, GoForward: Boolean): Boolean;
var
  Status: Word;
begin
  CheckBrowseMode;
  DoBeforeScroll;
  SetFound(FALSE);
  UpdateCursorPos;
  CursorPosChanged;
  if not Filtered then ActivateFilters;
  try
    if GoForward then
    begin
      if Restart then Check(Engine, Engine.SetToBegin(FHandle));
      Status := Engine.GetNextRecord(FHandle, dbiNoLock, nil, nil);
    end
    else
    begin
      if Restart then Check(Engine, Engine.SetToEnd(FHandle));
      Status := Engine.GetPriorRecord(FHandle, dbiNoLock, nil, nil);
    end;
  finally
    if not Filtered then DeactivateFilters;
  end;
  if Status = DBIERR_NONE then
  begin
    Resync([rmExact]);
    SetFound(TRUE);
  end;
  Result := Found;
  if Result then DoAfterScroll;
end;

Function TmySQLDataSet.RecordFilter(RecBuf: Pointer; RecNo: Integer): Smallint;
var
  Accept: Boolean;
  SaveState: TDataSetState;
begin
  SaveState := SetTempState(dsFilter);
  FFilterBuffer := RecBuf;
  try
    Accept := TRUE;
	 OnFilterRecord(Self, Accept);
  except
	 Application.HandleException(Self);
  end;
  RestoreState(SaveState);
  Result := Ord(Accept);
end;

Function TmySQLDataSet.LocateRecord(const KeyFields: String;const KeyValues: Variant;Options: TLocateOptions;SyncCursor: Boolean): Boolean;
var
  I, FieldCount, PartialLength: Integer;
  Buffer: PChar;
  Fields: TList;
  LookupCursor: HDBICur;
  Filter: HDBIFilter;
  Status: DBIResult;
  CaseInsensitive: Boolean;
  CursorWasCloned : boolean;//mi

  {}procedure SetFieldValue(const Fld : TField; const VarValue : Variant);
  {}begin
  {$IFNDEF VER150} // not Delphi 7
  {}  if (Fld is TLargeIntField) then
  {}    TIntegerField(Fld).Value := VarValue
  {}  else
  {$ENDIF}
  {}    Fld.Value := VarValue;
  {}end;

begin
  CheckBrowseMode;
  CursorPosChanged;
  Buffer := TempBuffer;
  Fields := TList.Create;
  try
	 GetFieldList(Fields, KeyFields);
	 CaseInsensitive := loCaseInsensitive in Options;

	 CursorWasCloned := false;
	 
	 if MapsToIndex(Fields, CaseInsensitive) then
	 begin
		  LookupCursor := FHandle;
	 end
	 else
	 begin
		 CursorWasCloned := true;
		 LookupCursor := GetLookupCursor(KeyFields, CaseInsensitive);
	 end;

	 if (LookupCursor <> nil) then
	 begin
		SetTempState(dsFilter);
		FFilterBuffer := Buffer;
		try
		  Engine.InitRecord(LookupCursor, Buffer);
		  FieldCount := Fields.Count;
		  if FieldCount = 1 then
		  begin
				if VarIsArray(KeyValues) then
					SetFieldValue(TField(Fields.First), KeyValues[0]) else
					SetFieldValue(TField(Fields.First), KeyValues);
		  end else
				for I := 0 to FieldCount - 1 do
					 SetFieldValue(TField(Fields[I]), KeyValues[I]);
		  PartialLength := 0;
        if (loPartialKey in Options) and
          (TField(Fields.Last).DataType = ftString) then
        begin
          PartialLength := Length(TField(Fields.Last).AsString);
        end;
        Status := Engine.GetRecordForKey(LookupCursor, False, FieldCount,PartialLength, Buffer, Buffer);
      finally
        RestoreState(dsBrowse);
      end;
      if (Status = DBIERR_NONE) and SyncCursor and(LookupCursor <> FHandle) then
		  Status := Engine.SetToCursor(FHandle, LookupCursor);

		if CursorWasCloned then//mi
		begin
			TNativeDataSet(LookupCursor).CloseTable;
			TNativeDataSet(LookupCursor).Free;
			if ClassName = 'TmySQLTable' then
				TmySQLTable(Self).FLookupHandle := nil;
		end;
    end else
    begin
      Check(Engine,Engine.SetToBegin(FHandle));
      Filter := CreateLookupFilter(Fields, KeyValues, Options, 2);
      Engine.ActivateFilter(FHandle, Filter);
      Status := Engine.GetNextRecord(FHandle, dbiNoLock, Buffer, nil);
      Engine.DropFilter(FHandle, Filter);
    end;
  finally
    Fields.Free;
  end;
  Result := Status = DBIERR_NONE;
end;

{$WARNINGS OFF}
Function TmySQLDataSet.LocateNearestRecord(const KeyFields: String;const KeyValues: Variant;Options: TLocateOptions;SyncCursor: Boolean): Word;
var
  Buffer: PChar;
  Fields: TList;
  Filter: HDBIFilter;
  Status: DBIResult;
  I: Integer;
  Filter1: TFilterExpr;
  Expr, Node: PExprNode;
  FilterOptions: TFilterOptions;

begin
  CheckBrowseMode;
  CursorPosChanged;
  Buffer := TempBuffer;
  Fields := TList.Create;
  try
    GetFieldList(Fields, KeyFields);
    Check(Engine, Engine.SetToBegin(FHandle));
    FilterOptions := [foNoPartialCompare];
    Filter1 := TFilterExpr.Create(Self, FilterOptions, [], '', nil, FldTypeMap);
    try
      if Fields.Count = 1 then
      begin
         if VarIsArray(KeyValues) then
            Node := Filter1.NewCompareNode(TField(Fields[0]),coGE, KeyValues[0]) else
            Node := Filter1.NewCompareNode(TField(Fields[0]),coGE, KeyValues);
         Expr := Node;
      end
      else
        for I := 0 to Fields.Count-1 do
        begin
          Node := Filter1.NewCompareNode(TField(Fields[I]),coGE, KeyValues[I]);
          if I = 0 then
            Expr := Node else
            Expr := Filter1.NewNode(enOperator,coAND, Unassigned, Expr, Node);
        end;
      if loPartialKey in Options then Node^.FPartial := TRUE;
      Check(Engine, Engine.AddFilter(FHandle, 0, 2, FALSE, PCANExpr(Filter1.GetFilterData(Expr)), nil,Filter));
    finally
      Filter1.Free;
    end;
    Engine.ActivateFilter(FHandle, Filter);
    Status := Engine.GetNextRecord(FHandle, dbiNoLock, Buffer, nil);
    Engine.DropFilter(FHandle, Filter);
  finally
    Fields.Free;
  end;
  Result := Status;
end;
{$WARNINGS ON}

Function TmySQLDataSet.Lookup(const KeyFields: String; const KeyValues: Variant;
  const ResultFields: String): Variant;
begin
  Result := Null;
  if LocateRecord(KeyFields, KeyValues, [], FALSE) then
  begin
    SetTempState(dsCalcFields);
    try
      CalculateFields(TempBuffer);
      Result := FieldValues[ResultFields];
    finally
      RestoreState(dsBrowse);
    end;
  end;
end;

Function TmySQLDataSet.Locate(const KeyFields: String;
  const KeyValues: Variant; Options: TLocateOptions): Boolean;
begin
  DoBeforeScroll;
  Result := LocateRecord(KeyFields, KeyValues, Options, TRUE);
  if Result then
  begin
    Resync([rmExact, rmCenter]);
    DoAfterScroll;
  end;
end;

Function TmySQLDataSet.GetLookupCursor(const KeyFields: String; CaseInsensitive: Boolean): HDBICur;
begin
  Result := nil;
end;

Procedure TmySQLDataSet.DestroyLookupCursor;
begin
end;

{ Cached Updates }

Procedure TmySQLDataSet.AllocCachedUpdateBuffers(Allocate: Boolean);
begin
  if Allocate then
  begin
    FUpdateCBBuf := AllocMem(SizeOf(DELAYUPDCbDesc));
    FUpdateCBBuf.pNewRecBuf := AllocMem(FRecBufSize);
    FUpdateCBBuf.pOldRecBuf := AllocMem(FRecBufSize);
    FUpdateCBBuf.iRecBufSize := FRecordSize;
  end else
  begin
    if Assigned(FUpdateCBBuf) then
    begin
      FreeMem(FUpdateCBBuf.pNewRecBuf);
      FreeMem(FUpdateCBBuf.pOldRecBuf);
      DisposeMem(FUpdateCBBuf, SizeOf(DELAYUPDCbDesc));
    end;
  end;
end;

Procedure TMySQLDataSet.CheckCachedUpdateMode;
begin
  if not CachedUpdates then DatabaseError(SNoCachedUpdates, Self);
end;

Function TMySQLDataSet.ForceUpdateCallback: Boolean;
begin
  Result := FCachedUpdates and (Assigned(FOnUpdateRecord) or
    Assigned(FUpdateObject));
end;

Procedure TmySQLDataSet.SetCachedUpdates(Value: Boolean);

  Procedure ReAllocBuffers;
  begin
    FreeFieldBuffers;
    FreeKeyBuffers;
    SetBufListSize(0);
    try
      InitBufferPointers(TRUE);
      SetBufListSize(BufferCount + 1);
      AllocKeyBuffers;
    except
      SetState(dsInactive);
      CloseCursor;
      raise;
    end;
  end;

begin
  if (State = dsInActive) or (csDesigning in ComponentState) then
    FCachedUpdates := Value
  else if FCachedUpdates <> Value then
  begin
    CheckBrowseMode;
    UpdateCursorPos;
    FCachedUpdates := Value;
    ReAllocBuffers;
    AllocCachedUpdateBuffers(Value);
    Resync([]);
  end;
end;

Function TmySQLDataSet.ProcessUpdates(UpdCmd: DBIDelayedUpdCmd): DBIResult;
begin
  CheckCachedUpdateMode;
  UpdateCursorPos;
  Result :=0;
end;

Procedure TmySQLDataSet.ApplyUpdates;
var
  Status: DBIResult;
begin
  if State <> dsBrowse then Post;
  Status := ProcessUpdates(dbiDelayedUpdPrepare);
  if Status <> DBIERR_NONE then
    if Status = DBIERR_UPDATEABORT then SysUtils.Abort
    else TDbiError(Engine, Status);
end;

Procedure TmySQLDataSet.CommitUpdates;
begin
  Check(Engine, ProcessUpdates(dbiDelayedUpdCommit));
  Resync([]);
end;

Procedure TmySQLDataSet.CancelUpdates;
begin
  Cancel;
  ProcessUpdates(dbiDelayedUpdCancel);
  Resync([]);
end;

Procedure TmySQLDataSet.RevertRecord;
var
  Status: Word;
begin
  if State in dsEditModes then Cancel;
  Status := ProcessUpdates(dbiDelayedUpdCancelCurrent);
  if not ((Status = DBIERR_NONE) or (Status = DBIERR_NOTSUPPORTED)) then
    Check(Engine, Status);
  Resync([]);
end;


Function TmySQLDataSet.UpdateStatus: TUpdateStatus;
var
  BufPtr: PChar;
begin
  if CachedUpdates then
  begin
    if State = dsCalcFields then
      BufPtr := CalcBuffer else
      BufPtr := ActiveBuffer;
    Result := PRecInfo(BufPtr + FRecInfoOfs).UpdateStatus;
  end else
    Result := usUnModified;
end;


Function TMySQLDataSet.CachedUpdateCallBack(CBInfo: Pointer): CBRType;
const
  CBRetCode: array[TUpdateAction] of CBRType = (cbrAbort, cbrAbort,
    cbrSkip, cbrRetry, cbrPartialAssist);
var
  UpdateAction: TUpdateAction;
  UpdateKind: TUpdateKind;
begin
  FInUpdateCallBack := TRUE;
  UpdateAction := uaFail;
  UpdateKind := TUpdateKind(ord(FUpdateCBBuf.eDelayUpdOpType)-1);
  try
    if Assigned(FOnUpdateRecord) then
      FOnUpdateRecord(Self, UpdateKind, UpdateAction)
    else
      if Assigned(FUpdateObject) then
      begin
        FUpdateObject.Apply(UpdateKind);
        UpdateAction := uaApplied;
      end
    else
      TDbiError(Engine, FUpdateCBBuf.iErrCode);
  except
    on E: Exception do
    begin
      if E is EMySQLDatabaseError then
        FUpdateCBBuf.iErrCode := EMySQLDatabaseError(E).ErrorCode;
      if (E is EDatabaseError) and Assigned(FOnUpdateError) then
        FOnUpdateError(Self, EDatabaseError(E), UpdateKind, UpdateAction)
      else
      begin
        Application.HandleException(Self);
        UpdateAction := uaAbort;
      end;
    end;
  end;
  Result := CBRetCode[UpdateAction];
  if UpdateAction = uaAbort then FUpdateCBBuf.iErrCode := DBIERR_UPDATEABORT;
  FInUpdateCallBack := FALSE;
end;

Function TmySQLDataSet.GetUpdateRecordSet: TUpdateRecordTypes;
begin
  if Active then
  begin
    CheckCachedUpdateMode;
    Result := TUpdateRecordTypes(Byte(GetIntProp(Engine, FHandle, curDELAYUPDDISPLAYOPT)));
  end
  else
    Result := [];
end;

Procedure TmySQLDataSet.SetUpdateRecordSet(RecordTypes: TUpdateRecordTypes);
begin
  CheckCachedUpdateMode;
  CheckBrowseMode;
  UpdateCursorPos;
  Check(Engine, Engine.SetEngProp(hDbiObj(Handle), curDELAYUPDDISPLAYOPT, Longint(Byte(RecordTypes))));
  Resync([]);
end;


Procedure TmySQLDataSet.SetUpdateObject(Value: TmySQLSQLUpdateObject);
begin
  if Value <> FUpdateObject then
  begin
    if Assigned(FUpdateObject) and (FUpdateObject.DataSet = Self) then
      FUpdateObject.DataSet := nil;
    FUpdateObject := Value;
    if Assigned(FUpdateObject) then
    begin
      { If another dataset already references this updateobject, then
        remove the reference }
      if Assigned(FUpdateObject.DataSet) and
        (FUpdateObject.DataSet <> Self) then
        FUpdateObject.DataSet.UpdateObject := nil;
      FUpdateObject.DataSet := Self;
    end;
  end;
end;

procedure TMySQLDataSet.SetOnUpdateError(UpdateEvent: TUpdateErrorEvent);
begin
  FOnUpdateError := UpdateEvent;
end;


Function TmySQLDataSet.GetUpdatesPending: Boolean;
begin
  Result := GetIntProp(Engine, FHandle, curDELAYUPDNUMUPDATES) > 0;
end;

Procedure TmySQLDataSet.DataEvent(Event: TDataEvent; Info: Integer);

  procedure CheckIfParentScrolled;
  var
    ParentPosition, I: Integer;
  begin
    ParentPosition := 0;
    with FParentDataSet do
     if not IsEmpty then
       for I := 0 to BookmarkSize - 1 do
         ParentPosition := ParentPosition + Byte(ActiveBuffer[FBookmarkOfs+I]);
    if (FLastParentPos = 0) or (ParentPosition <> FLastParentPos) then
    begin
      First;
      FLastParentPos := ParentPosition;
    end
    else
    begin
      UpdateCursorPos;
      Resync([]);
    end;
  end;

begin
  if (Event = deParentScroll) then
    CheckIfParentScrolled;
  inherited DataEvent(Event, Info);
end;

{ TBDEDataSet.IProviderSupport}
Function TmySQLDataSet.PSGetUpdateException(E: Exception; Prev: EUpdateError): EUpdateError;
var
  PrevErr: Integer;
begin
  if E is EmySQLDatabaseError then
  begin
    if Prev <> nil then
      PrevErr := Prev.ErrorCode else
      PrevErr := 0;
    with EmySQLDatabaseError(E) do
      Result := EUpdateError.Create(E.Message, '', ErrorCode, PrevErr, E);
  end
  else
    Result := inherited PSGetUpdateException(E, Prev);
end;

Function TmySQLDataSet.PSIsSQLSupported: Boolean;
begin
  Result := TRUE;
end;

Procedure TmySQLDataSet.PSReset;
begin
  inherited PSReset;
  If Handle <> nil then
    Engine.ForceReread(Handle);
end;

Procedure TmySQLDataSet.SetHandle(Value: HDBICur);
begin
  Close;
  FHandle := Value;
  if Assigned(Value) then
  try
    Open;
  except
    FHandle := nil;
    Raise;
  end;
end;

function TMySQLDataSet.GetHandle: HDBICur;
begin
  Result := FHandle;
end;

Function TmySQLDataSet.CheckOpen(Status: Word): Boolean;
begin
  case Status of
    DBIERR_NONE: Result := TRUE;
    DBIERR_NOTSUFFTABLERIGHTS: Result := FALSE;
  else
    TDbiError(Engine, Status);
    Result := FALSE;
  end;
end;

Procedure TmySQLDataSet.Disconnect;
begin
  Close;
end;

Function TmySQLDataSet.GetDBHandle: HDBIDB;
begin
  if FDatabase <> nil then
  begin
    if FDatabase.Handle = nil then
       FDatabase.Connected := True;
    Result := FDatabase.Handle;
  end
  else
    Result := nil;
end;

Procedure TmySQLDataSet.GetDatabaseNames(List : TStrings);
var
  i     : Integer;
  Names : TStringList;
begin
  Names := TStringList.Create;
  try
    Names.Sorted := TRUE;
    for I := 0 to DBList.Count-1 do
      with TmySQLDatabase(DBList[i]) do Names.Add(DatabaseName);
    List.Assign(Names);
  finally
    Names.Free;
  end;
end;

function TmySQLDataSet.GetLastInsertID: Int64;
begin
   if Handle <> nil then
      Engine.GetLastInsertID(Handle,Result) else
      Result := -1;
end;

Procedure TmySQLDataSet.CloseDatabase(Database: TmySQLDatabase);
begin
  if Assigned(Database) then
    Database.CloseDatabase;
end;

Function TmySQLDataSet.SetDBFlag(Flag: Integer; Value: Boolean): Boolean;
begin
  Result := Flag in DBFlags;
  if Value then
  begin
    if not Result then
    begin
      if FDBFlags = [] then
      begin
        FDatabase.Open;
        Inc(FDatabase.FRefCount);
        FDatabase.RegisterClient(Self);
      end;
      Include(FDBFlags, Flag);
    end;
  end
  else
  begin
    if Result then
    begin
      Exclude(FDBFlags, Flag);
      if FDBFlags = [] then
      begin
        FDatabase.UnRegisterClient(Self);
        CloseDatabase(FDatabase);
      end;
    end;
  end;
end;

Procedure TmySQLDataSet.SetUpdateMode(const Value: TUpdateMode);
begin
  if (FHandle <> nil) and True and CanModify then
    Check(Engine, Engine.SetEngProp(hDbiObj(FHandle), curUPDLOCKMODE, Longint(Value)));
  FUpdateMode := Value;
end;

{ AutoRefresh }
Procedure TmySQLDataSet.SetAutoRefresh(const Value: Boolean);
begin
  CheckInactive;
  FAutoRefresh := Value;
end;

procedure TmySQLDataSet.SetDatabase(Value: TmySQLDatabase);
begin
   if Active then Close;
   try
     if Assigned(FDatabase) then  FDatabase.UnRegisterClient(Self);
     if Assigned(Value) then FDatabase := Value;
   finally
     FDatabase := Value;
   end;
end;

function TmySQLDataSet.GetDatabase: TmySQLDatabase;
begin
   Result := TMySQLDatabase(FDatabase);
end;

Procedure TmySQLDataSet.SetupAutoRefresh;
const
  PropFlags : array[TAutoRefreshFlag] of LongInt = (0, curFIELDISAUTOINCR, curFIELDISDEFAULT);
var
  I       : Integer;
  ColDesc : ServerColDesc;
begin
  for I := 0 to Fields.Count - 1 do
    with Fields[I] do
      if (AutoGenerateValue <> arNone) then
      begin
        ColDesc.iFldNum    := I + 1;
        ColDesc.bServerCol := TRUE;
        Check(Engine, Engine.SetEngProp(hDbiObj(FHandle), PropFlags[ AutoGenerateValue ], LongInt(@ColDesc)));
      end;
end;

{ TmySQLDataSet.IProviderSupport }
Procedure TmySQLDataSet.PSGetAttributes(List : TList);
begin
  inherited PSGetAttributes(List);
end;

Function TmySQLDataSet.PSIsSQLBased: Boolean;
var
  InProvider : Boolean;
begin
  InProvider := SetDBFlag(dbfProvider, TRUE);
  try
    Result := True;
  finally
    SetDBFlag(dbfProvider, InProvider);
  end;
end;

Function TmySQLDataSet.PSGetQuoteChar: String;
begin
  Result := '"';
end;

Function TmySQLDataSet.PSInTransaction: Boolean;
var
  InProvider: Boolean;
begin
  if not Assigned(Database) or not Database.Connected then
    Result := FALSE
  else
  begin
    InProvider := SetDBFlag(dbfProvider, TRUE);
    try
      Result := Database.InTransaction;
    finally
      SetDBFlag(dbfProvider, InProvider);
    end;
  end;
end;

Procedure TmySQLDataSet.PSStartTransaction;
begin
  SetDBFlag(dbfProvider, TRUE);
  try
    if not PSIsSQLBased then
      Database.TransIsolation := tiDirtyRead;
    Database.StartTransaction;
  except
    SetDBFlag(dbfProvider, FALSE);
    Raise;
  end;
end;

Procedure TmySQLDataSet.PSEndTransaction(Commit : Boolean);
const
  EndType: array[Boolean] of eXEnd = (xendABORT, xendCOMMIT);
begin
  try
    Database.ClearStatements;
    Database.EndTransaction(EndType[ Commit ]);
  finally
    SetDBFlag(dbfProvider, FALSE);
  end;
end;

{$WARNINGS OFF}
Function TmySQLDataSet.PSExecuteStatement(const ASQL : string; AParams: TParams;ResultSet: Pointer = nil): Integer;
var
  InProvider: Boolean;
begin
  InProvider := SetDBFlag(dbfProvider, TRUE);
  try
    if Assigned(ResultSet) then
    begin
//      Result := Database.Execute(ASQL, AParams, TRUE);
//      TDataSet(ResultSet^) := TmySQLDataSet.Create(nil);
//      TmySQLDataSet(ResultSet^).SetHandle(Cursor);
    end else
      Result := Database.Execute(ASQL, AParams, TRUE{, nil});
  finally
    SetDBFlag(dbfProvider, InProvider);
  end;
end;
{$WARNINGS ON}

/////////////////////////////////////////////////////////////////
//                    TmySQLQuery                                //
/////////////////////////////////////////////////////////////////
constructor TmySQLQuery.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  FSQL := TStringList.Create;
  TStringList(SQL).OnChange := QueryChanged;
  FParams := TmySQLParams.Create(Self);
  FDataLink := TmySQLQueryDataLink.Create(Self);
  RequestLive := FALSE;
  ParamCheck := TRUE;
  FRowsAffected := -1;
  FLastInsertID := -1;
  CacheBlobs := False;
  SQLBinary := nil;
end;

destructor TmySQLQuery.Destroy;
begin
  Destroying;
  Disconnect;
  SQL.Free;
  FParams.Free;
  FDataLink.Free;
  StrDispose(SQLBinary);
  Inherited Destroy;
end;

Function TmySQLQuery.Engine : TmySQLEngine;
begin
  Result := FDataBase.Engine;
end;

Function TmySQLQuery.IsSequenced: Boolean;
begin
  Result := FAllowSequenced and inherited IsSequenced;
end;

Procedure TmySQLQuery.Disconnect;
begin
  Close;
  UnPrepare;
end;

Procedure TmySQLQuery.SetPrepare(Value: Boolean);
begin
  if Value then
    Prepare else  UnPrepare;
end;

Procedure TmySQLQuery.Prepare;
begin
  SetDBFlag(dbfPrepared, TRUE);
  SetPrepared(TRUE);
end;

Procedure TmySQLQuery.UnPrepare;
begin
  SetPrepared(FALSE);
  SetDBFlag(dbfPrepared, FALSE);
end;

Procedure TmySQLQuery.SetDataSource(Value: TDataSource);
begin
  if IsLinkedTo(Value) then
    DatabaseError(SCircularDataLink, Self);
  FDataLink.DataSource := Value;
end;

Function TmySQLQuery.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

Procedure TmySQLQuery.SetQuery(Value: TStrings);
begin
  if SQL.Text <> Value.Text then
  begin
    Disconnect;
    SQL.BeginUpdate;
    try
      SQL.Assign(Value);
    finally
      SQL.EndUpdate;
    end;
  end;
end;

function TMySQLQuery.GetQuery:TStrings;
begin
   Result := FSQL;
end;

Procedure TmySQLQuery.QueryChanged(Sender: TObject);
var
  List: TmySQLParams;

  function PatchQuery(AText : String):String;
  var
    StartCom,
    EndCom : Integer;
    S : String;
    QLst : TStrings;
    i : Integer;
  begin
     Result := AText;
     S := AText;
     //Replace multiline comment
     StartCom := Pos('/*',S);
     // Test for special comments /*![version] */
     if (StartCom > 0) and (S[StartCom + 2] <> '!') then
     begin
        EndCom := Pos('*/',S)+2;
        System.Delete(S,StartCom,EndCom-StartCom);
     end;
     QLst := TStringList.Create;
     try
       QLst.Text := S;
       //Replace in-line comment --
       I := 0;
       While I < QLst.Count-1 do
       begin
          StartCom := Pos('--',QLst[i]);
          if  StartCom > 0 then
          begin
             S := QLst[I];
             System.Delete(S,StartCom,Length(S));
             QLst[I] := S;
          end else
            inc(I);
       end;
//       //Replace in-line comment #
//       I := 0;
//       While I < QLst.Count-1 do
//       begin
//          StartCom := Pos('#',QLst[i]);
//          if  StartCom > 0 then
//          begin
//             S := QLst[I];
//             System.Delete(S,StartCom,Length(S));
//             QLst[I] := S;
//          end else
//            inc(I);
//       end;
       S := QLst.Text;
     finally
       Qlst.Free;
     end;
     Result := S;
  end;

begin
  if not (csReading in ComponentState) then
  begin
    Disconnect;
    StrDispose(SQLBinary);
    SQLBinary := nil;
    if ParamCheck or (csDesigning in ComponentState) then
    begin
      List := TmySQLParams.Create(Self);
      try
        FText := List.ParseSQL(PatchQuery(SQL.Text), True);
        List.AssignValues(FParams);
        FParams.Clear;
        FParams.Assign(List);
      finally
        List.Free;
      end;
    end else
      FText := SQL.Text;
    DataEvent(dePropertyChange, 0);
  end else
    FText := FParams.ParseSQL(PatchQuery(SQL.Text), False);
end;

Procedure TmySQLQuery.SetParamsList(Value: TmySQLParams);
begin
  FParams.AssignValues(Value);
end;

function TmySQLQuery.GetParamsList:TMySQLParams;
begin
   Result := FParams;
end;

Function TmySQLQuery.GetParamsCount: Word;
begin
  Result := FParams.Count;
end;

Procedure TmySQLQuery.DefineProperties(Filer: TFiler);

  Function WriteData: Boolean;
  begin
    if (Filer.Ancestor <> nil) then
      Result := not FParams.IsEqual(TmySQLQuery(Filer.Ancestor).FParams)
    else
      Result := (FParams.Count > 0);
  end;

begin
  Inherited DefineProperties(Filer);
  Filer.DefineBinaryproperty('Data', ReadBinaryData, WriteBinaryData, SQLBinary <> nil);
  Filer.DefineProperty('ParamData', ReadParamData, WriteParamData, WriteData);
end;

Procedure TmySQLQuery.ReadParamData(Reader: TReader);
begin
  Reader.ReadValue;
  Reader.ReadCollection(FParams);
end;

Procedure TmySQLQuery.WriteParamData(Writer: TWriter);
begin
  Writer.WriteCollection(Params);
end;

Procedure TmySQLQuery.ReadBinaryData(Stream: TStream);
begin
  StrDispose(SQLBinary);
  SQLBinary := StrAlloc(Stream.Size);
  Stream.ReadBuffer(SQLBinary^, Stream.Size);
end;

Procedure TmySQLQuery.WriteBinaryData(Stream: TStream);
begin
  Stream.WriteBuffer(SQLBinary^, StrBufSize(SQLBinary));
end;

procedure TmySQLQuery.SetRequestLive(const Value : Boolean);
begin
   if Value <> FRequestLive then
      FRequestLive := Value;
end;

function TmySQLQuery.GetRequestLive : Boolean;
begin
   Result := FRequestLive;
end;

Procedure TmySQLQuery.SetPrepared(Value: Boolean);
begin
  if Handle <> nil then
    DatabaseError(SDataSetOpen, Self);
  if Value <> Prepared then
  begin
    if Value then
    begin
      FRowsAffected := -1;
      FLastInsertID := -1; //NEW 2.3.1
      FCheckRowsAffected := TRUE;
      if Length(Text) > 1 then
        PrepareSQL(PChar(Text)) else
        DatabaseError(SEmptySQLStatement, Self);
    end else
    begin
      if FCheckRowsAffected then
         FRowsAffected := RowsAffected;
      FLastInsertID:= GetLastInsID; //?????
      FreeStatement;
    end;
    FPrepared := Value;
  end;
end;

Procedure TmySQLQuery.FreeStatement;
var
  Result: DbiResult;
begin
  if StmtHandle <> nil then
  begin
    Result := Engine.QFree(FStmtHandle);
    if not (csDestroying in ComponentState) then
       Check(Engine, Result);
  end;
end;

Procedure TmySQLQuery.SetParamsFromCursor;
var
  I: Integer;
  DataSet: TDataSet;
begin
  if FDataLink.DataSource <> nil then
  begin
    DataSet := FDataLink.DataSource.DataSet;
    if DataSet <> nil then
    begin
      DataSet.FieldDefs.Update;
      for I := 0 to FParams.Count - 1 do
        with FParams[I] do
          if not Bound then
          begin
            AssignField(DataSet.FieldByName(Name));
            Bound := FALSE;
          end;
    end;
  end;
end;

Procedure TmySQLQuery.RefreshParams;
var
  DataSet: TDataSet;
begin
  DisableControls;
  try
    if FDataLink.DataSource <> nil then
    begin
      DataSet := FDataLink.DataSource.DataSet;
      if DataSet <> nil then
        if DataSet.Active and (DataSet.State <> dsSetKey) then
        begin
          Close;
          Open;
        end;
    end;
  finally
    EnableControls;
  end;
end;

Function TmySQLQuery.ParamByName(const Value: String): TmySQLParam;
begin
  Result := FParams.ParamByName(Value);
end;

Function TmySQLQuery.CreateCursor(GenHandle: Boolean): HDBICur;
begin
  if SQL.Count > 0 then
  begin
    FExecSQL := not GenHandle;
    Try
      SetPrepared(TRUE);
    Finally
      FExecSQL := FALSE;
    end;
    if FDataLink.DataSource <> nil then SetParamsFromCursor;
    Result := GetQueryCursor(GenHandle);
  end
  else
  begin
    DatabaseError(SEmptySQLStatement, Self);
    Result := nil;
  end;
  FCheckRowsAffected := (Result = nil);
end;


Function TmySQLQuery.CreateHandle: HDBICur;
begin
  Result := CreateCursor(TRUE)
end;


Procedure TmySQLQuery.ExecSQL;
begin
  CheckInActive;
  if Database=nil then raise EDatabaseError.Create('Property Database not set!');
  SetDBFlag(dbfExecSQL, TRUE);
  try
    CreateCursor(FALSE);
  finally
    SetDBFlag(dbfExecSQL, FALSE);
  end;
end;

Function TmySQLQuery.GetQueryCursor(GenHandle: Boolean): HDBICur;
var
  PCursor: phDBICur;
begin
  Result := nil;
  if GenHandle then
    PCursor := @Result else
    PCursor := nil;
  if FParams.Count > 0 then
      Check(Engine,Engine.QuerySetParams(StmtHandle,Params,SQL.Text));
  Check(Engine, Engine.QExec(StmtHandle, PCursor));
  FLastInsertID := LastInsertID;
end;

Function TmySQLQuery.SetDBFlag(Flag: Integer; Value: Boolean): Boolean;
var
  NewConnection: Boolean;
begin
  if Value then
  begin
    NewConnection := DBFlags = [];
    Result := Inherited SetDBFlag(Flag, Value);
    if not (csReading in ComponentState) and NewConnection then
      FLocal := False;
  end
  else
  begin
    if DBFlags - [Flag] = [] then
      SetPrepared(FALSE);
    Result := Inherited SetDBFlag(Flag, Value);
  end;
end;

Procedure TmySQLQuery.PrepareSQL(Value: PChar);
begin
  GetStatementHandle(Value);
  if not Local then
    SetBoolProp(Engine, StmtHandle, stmtUNIDIRECTIONAL, FUniDirectional);
end;

Procedure TmySQLQuery.GetStatementHandle(SQLText: PChar);
const
  DataType: array[Boolean] of LongInt = (Ord(wantCanned), Ord(wantLive));
var
  DBh : HDBIDB;
begin
  DBh := DBHandle;
  Check(Engine,Engine.QAlloc(DBH, qrylangSQL, FStmtHandle));
  try
    If not FExecSQL then
    begin
      Check(Engine, Engine.SetEngProp(hDbiObj(StmtHandle), stmtLIVENESS,
            DataType[RequestLive and not ForceUpdateCallback]));
    end;
    if Local then
    begin
      SetBoolProp(Engine,StmtHandle,stmtAUXTBLS,FALSE);
      SetBoolProp(Engine,StmtHandle,stmtCANNEDREADONLY,TRUE);
    end;
    while not CheckOpen(Engine.QPrepare(FStmtHandle, SQLText)) do
      {Retry};
  except
    Engine.QFree(FStmtHandle);
    FStmtHandle := nil;
    raise;
  end;
end;

function TmySQLQuery.GetLastInsertID: Int64;
begin
   if Handle <> nil then
      Engine.GetLastInsertID(Handle,Result) else
      Result := FLastInsertID;
end;

Function TmySQLQuery.GetRowsAffected: Integer;
var
  Length: Word;
begin
  if Prepared then
    if Engine.GetEngProp(hDBIObj(StmtHandle), stmtROWCOUNT, @Result, SizeOf(Result), Length) <> 0 then
      Result := -1  else
  else
    Result := FRowsAffected;
end;

Function TmySQLQuery.GetLastInsID: Int64;
begin
  if StmtHandle <> nil then
      Engine.GetLastInsertID_Stmt(StmtHandle,Result) else
      Result := -1;
end;


Procedure TmySQLQuery.GetDetailLinkFields(MasterFields, DetailFields: TList);

  Function AddFieldToList(const FieldName: string; DataSet: TDataSet;
    List: TList): Boolean;
  var
    Field: TField;
  begin
    Field := DataSet.FindField(FieldName);
    if (Field <> nil) then
      List.Add(Field);
    Result := Field <> nil;
  end;

var
  i: Integer;
begin
  MasterFields.Clear;
  DetailFields.Clear;
  if (DataSource <> nil) and (DataSource.DataSet <> nil) then
    for i := 0 to Params.Count - 1 do
      if AddFieldToList(Params[i].Name, DataSource.DataSet, MasterFields) then
        AddFieldToList(Params[i].Name, Self, DetailFields);
end;

{ TmySQLQuery.IProviderSupport }
Function TmySQLQuery.PSGetDefaultOrder: TIndexDef;
begin
  Result := inherited PSGetDefaultOrder;
  if not Assigned(Result) then
    Result := GetIndexForOrderBy(SQL.Text, Self);
end;

Function TmySQLQuery.PSGetParams : TParams;
begin
  Result := Params;
end;

Procedure TmySQLQuery.PSSetParams(AParams : TParams);
begin
  if (AParams.Count <> 0) then
    Params.Assign(AParams);
  Close;
end;

Function TmySQLQuery.PSGetTableName: string;
begin
  Result := GetTableNameFromSQL(SQL.Text);
end;

Procedure TmySQLQuery.PSExecute;
begin
  ExecSQL;
end;

Procedure TmySQLQuery.PSSetCommandText(const CommandText : string);
begin
  if (CommandText <> '') then
	 SQL.Text := CommandText;
end;

procedure TmySQLDataSet.SortBy(FieldNames: string);//mi
begin
	if Active then
	begin
		TNativeDataSet(FHandle).SortBy(FieldNames);
		First;
	end;
end;

procedure TmySQLDataSet.SetSortFieldNames(const Value: string);
begin
	if FSortFieldNames <> Value then
	begin
		FSortFieldNames := Value;
	end;
	SortBy(FSortFieldNames);
end;

{ TmySQLUpdateSQL }
constructor TmySQLUpdateSQL.Create(AOwner: TComponent);
var
  UpdateKind: TUpdateKind;
begin
  Inherited Create(AOwner);
  for UpdateKind := Low(TUpdateKind) to High(TUpdateKind) do
  begin
	 FSQLText[UpdateKind] := TStringList.Create;
	 TStringList(FSQLText[UpdateKind]).OnChange := SQLChanged;
  end;
end;

destructor TmySQLUpdateSQL.Destroy;
var
  UpdateKind: TUpdateKind;
begin
  if Assigned(FDataSet) and (FDataSet.UpdateObject = Self) then
	 FDataSet.UpdateObject := nil;
  for UpdateKind := Low(TUpdateKind) to High(TUpdateKind) do
	 FSQLText[UpdateKind].Free;
  Inherited Destroy;
end;

Procedure TmySQLUpdateSQL.ExecSQL(UpdateKind: TUpdateKind);
var
  RN, RC: integer;
begin
  with Query[UpdateKind] do
  begin
    Prepare;
    ExecSQL;
    if Assigned(FDataSet) then
    begin
       RN := TNativeDataset(FDataset.Handle).RecordNo;
		 TNativeDataset(FDataset.Handle).OpenTable;
		 TNativeDataset(FDataset.Handle).RecordState := tsPos;
       If UpdateKind <> ukDelete then
         TNativeDataset(FDataset.Handle).SetRowPosition(-1,0,FDataset.ActiveBuffer)
       else
         begin
          if Engine.GetRecordCount(FDataset.Handle, RC) <> DBIERR_NONE then
            RC := -1;
          if RN >= RC then
            RN := 0;
          try
           TNativeDataset(FDataset.Handle).SettoSeqNo(RN);
          except
          end;
         end;
       TNativeDataset(FDataset.Handle).IsLocked := False;
    end;
    If Assigned(FRecordChangeCompleteEvent) then
      FRecordChangeCompleteEvent(FDataset,UpdateKind);
  end;
end;

Function TmySQLUpdateSQL.GetQueryClass : TmySQLQueryClass;
begin
  Result := TmySQLQuery;
end;

Function TmySQLUpdateSQL.GetQuery(UpdateKind: TUpdateKind): TmySQLQuery;
begin
  if not Assigned(FQueries[UpdateKind]) then
  begin
    FQueries[UpdateKind] := GetQueryClass.Create(Self);
    FQueries[UpdateKind].SQL.Assign(FSQLText[UpdateKind]);
    if FDataSet is TmySQLDataSet then
       FQueries[UpdateKind].Database := TmySQLDataSet(FDataSet).DataBase;
  end;
  Result := FQueries[UpdateKind];
end;

Function TmySQLUpdateSQL.GetSQL(UpdateKind: TUpdateKind): TStrings;
begin
  Result := FSQLText[UpdateKind];
end;

Function TmySQLUpdateSQL.GetSQLIndex(Index: Integer): TStrings;
begin
  Result := FSQLText[TUpdateKind(Index)];
end;

Function TmySQLUpdateSQL.GetDataSet: TmySQLDataSet;
begin
  Result := FDataSet;
end;

Procedure TmySQLUpdateSQL.SetDataSet(ADataSet: TmySQLDataSet);
begin
  FDataSet := ADataSet;
end;

Procedure TmySQLUpdateSQL.SetSQL(UpdateKind: TUpdateKind; Value: TStrings);
begin
  FSQLText[UpdateKind].Assign(Value);
end;

Procedure TmySQLUpdateSQL.SetSQLIndex(Index: Integer; Value: TStrings);
begin
  SetSQL(TUpdateKind(Index), Value);
end;

Procedure TmySQLUpdateSQL.SQLChanged(Sender: TObject);
var
  UpdateKind: TUpdateKind;
begin
  for UpdateKind := Low(TUpdateKind) to High(TUpdateKind) do
    if Sender = FSQLText[UpdateKind] then
    begin
      if Assigned(FQueries[UpdateKind]) then
      begin
        FQueries[UpdateKind].Params.Clear;
        FQueries[UpdateKind].SQL.Assign(FSQLText[UpdateKind]);
      end;
      Break;
    end;
end;

Procedure TmySQLUpdateSQL.SetParams(UpdateKind: TUpdateKind);
var
  I: Integer;
  Old: Boolean;
  Param: TmySQLParam;
  PName: String;
  Field: TField;
  Value: string;
  FType: word;
begin
  if not Assigned(FDataSet) then Exit;
  with Query[UpdateKind] do
  begin
    for I := 0 to Params.Count - 1 do
    begin
      Param := Params[I];
      PName := Param.Name;
      Old := CompareText(Copy(PName, 1, 4), 'OLD_') = 0;
      if  Old and (UpdateKind in [ukInsert,ukDelete]) then
        DatabaseError(Format(SNoParameterValue,[Param.Name]));
      if Old then System.Delete(PName, 1, 4);
      Field := FDataSet.FindField(PName);
      If Field.IsBlob  then
        DatabaseError(Format(SNoParameterValue,[Param.Name]));
      if not Assigned(Field) then Continue;
      if Old then
        Check(FDataset.Engine,FDataset.Engine.GetFieldValueFromBuffer(FDataset.Handle,FDataset.FOldBuffer,PName, Value, FType)) else
        Check(FDataset.Engine,FDataset.Engine.GetFieldValueFromBuffer(FDataset.Handle,FDataset.ActiveBuffer,PName, Value, Ftype));
      if FType in [0..MAXLOGFLDTYPES] then
       Param.DataType := DataTypeMap[FType]
      else
        Param.DataType := ftADT;
      Param.Value := Value;
    end;
  end;
end;

Procedure TmySQLUpdateSQL.Apply(UpdateKind: TUpdateKind);
begin
  SetParams(UpdateKind);
  ExecSQL(UpdateKind);
end;

///////////////////////////////////////////////////////////////////////////////
//                         TmySQLTable                                       //
///////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
//Constructor : TmySQLTable.Create
//Description : TmySQLTable conponent
//////////////////////////////////////////////////////////
//Input       : AOwner: TComponent
//////////////////////////////////////////////////////////
constructor TmySQLTable.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  FIndexDefs := TIndexDefs.Create(Self);
  FMasterLink := TMasterDataLink.Create(Self);
  FMasterLink.OnMasterChange := MasterChanged;
  FMasterLink.OnMasterDisable := MasterDisabled;
  FDefaultIndex := TRUE;
  CacheBlobs := False;
  FLimit := -1;
  FOffset := 0;
end;

destructor TmySQLTable.Destroy;
begin
  Inherited Destroy;
  FMasterLink.Free;
  FIndexDefs.Free;
end;

function TMySQLTable.GetLimit: Integer;
begin
   Result := FLimit;
end;

procedure TMySQLTable.SetLimit(const Value : Integer);
begin
   If FLimit <> Value then
      FLimit := Value;
end;

function TMySQLTable.GetOffset: Integer;
begin
   Result := FOffset;
end;

procedure TMySQLTable.SetOffset(const Value : Integer);
begin
   If FOffset <> Value then
      FOffset := Value;
end;

Function TmySQLTable.GetHandle(const IndexName, IndexTag: String): HDBICur;
const
  OpenModes: array[Boolean] of DbiOpenMode = (dbiReadWrite, dbiReadOnly);
  ShareModes: array[Boolean] of DbiShareMode = (dbiOpenShared, dbiOpenExcl);
var
  IndexID: Word;
  OpenMode: DbiOpenMode;
  RetCode: Word;
  DBH : HDBIDB;
begin
  Result := nil;
  OpenMode := OpenModes[FReadOnly];
  if DefaultIndex then
    IndexID := 0  else IndexID := NODEFAULTINDEX;
  while TRUE do
  begin
    DBH := DBHandle;
    RetCode := Engine.OpenTable(DBH, NativeTableName, GetTableTypeName,
      PChar(IndexName), PChar(IndexTag), IndexID, OpenMode, ShareModes[FExclusive],
      xltField, FALSE, nil, Result,FOffset,FLimit);
    if RetCode = DBIERR_TABLEREADONLY then
      OpenMode := dbiReadOnly    else
      if CheckOpen(RetCode) then  Break;
  end;
end;

Function TmySQLTable.Engine : TmySQLEngine;
begin
  Result := FDataBase.Engine;
end;

Function TmySQLTable.IsSequenced: Boolean;
begin
  Result := FAllowSequenced and inherited IsSequenced;
end;

Function TmySQLTable.CreateHandle: HDBICur;
var
  IndexName, IndexTag: String;
begin
  if FTableName = '' then  DatabaseError(SNoTableName, Self);
  IndexDefs.Updated := FALSE;
  GetIndexParams(FIndexName, FFieldsIndex, IndexName, IndexTag);
  Result := GetHandle(IndexName, IndexTag);
end;

Function TmySQLTable.GetLanguageDriverName: string;
begin
  Result := '';
end;

Procedure TmySQLTable.PrepareCursor;
begin
  CheckMasterRange;
end;

Procedure TmySQLTable.DefChanged(Sender: TObject);
begin
  StoreDefs := TRUE;
end;

Procedure TmySQLTable.InitFieldDefs;
var
  I, FieldID, FldDescCount: Integer;
  FieldDescs: TFieldDescList;
  FCursor: HDBICur;
  RequiredFields: TBits;
begin
  if FHandle <> nil then InternalInitFieldDefs else
  begin
    SetDBFlag(dbfFieldList, TRUE);
    try
      if (FTableName = '') then  DatabaseError(SNoTableName, Self);
        while not CheckOpen(Engine.OpenFieldList(DBHandle, NativeTableName,
          GetTableTypeName, FALSE, FCursor)) do {Retry};
        try
          Check(Engine, Engine.GetRecordCount(FCursor, FldDescCount));
          SetLength(FieldDescs, FldDescCount);
          { Create an array of field descriptors }
          for I := 0 to FldDescCount - 1 do
            Check(Engine, Engine.GetNextRecord(FCursor, dbiNoLock, @FieldDescs[I], nil));
          { Initialize list of required fields }
          RequiredFields := TBits.Create;
          try
            if FieldDescs[FldDescCount-1].iFldNum > FldDescCount then
              RequiredFields.Size := FieldDescs[FldDescCount-1].iFldNum + 1 else
              RequiredFields.Size := FldDescCount + 1;
            { Initialize the FieldDefs }
            FieldDefs.BeginUpdate;
            try
              FieldDefs.Clear;
              I := 0;
              FieldID := 1;
              while I < FldDescCount do
                AddFieldDesc(FieldDescs, I, FieldID, RequiredFields, FieldDefs);
            finally
              FieldDefs.EndUpdate;
            end;
          finally
            RequiredFields.Free;
          end;
        finally
          Engine.CloseCursor(FCursor);
        end;
    finally
      SetDBFlag(dbfFieldList, FALSE);
    end;
  end;
end;

Procedure TmySQLTable.DestroyHandle;
begin
  DestroyLookupCursor;
  Inherited DestroyHandle;
end;

Procedure TmySQLTable.DecodeIndexDesc(const IndexDesc: IDXDesc;
  var Source, Name, FieldExpression, DescFields: string;
  var Options: TIndexOptions);

  Procedure ConcatField(var FieldList: string; const FieldName: string);
  begin
    if FieldList = '' then
      FieldList := FieldName else
      FieldList := Format('%s;%s', [FieldList, FieldName]);
  end;

var
  IndexOptions: TIndexOptions;
  I: Integer;
  SSource, SName: PChar;
  FieldName: String;
begin
  with IndexDesc do
  begin
    if szTagName[0] = #0 then
    begin
      SName := szName;
      Source := '';
    end
    else
    begin
      SSource := szName;
      SName := szTagName;
      TNativeToAnsi(Engine, SSource, Source);
    end;
    TNativeToAnsi(Engine, SName, Name);
    Name := ExtractFileName(Name);
    Source := ExtractFileName(Source);
    IndexOptions := [];
    if bPrimary then Include(IndexOptions, ixPrimary);
    if bUnique then Include(IndexOptions, ixUnique);
    if bDescending then Include(IndexOptions, ixDescending);
    if bCaseInsensitive then Include(IndexOptions, ixCaseInsensitive);
    if not bMaintained then Include(IndexOptions, ixNonMaintained);
    if bExpIdx then
    begin
      TNativeToAnsi(Engine, szKeyExp, FieldExpression);
      Include(IndexOptions, ixExpression);
    end else
    begin
      FieldExpression := '';
      DescFields := '';
      for I := 0 to iFldsInKey - 1 do
      begin
        FieldName := FieldDefList[aiKeyFld[I] - 1].Name;
        ConcatField(FieldExpression, FieldName);
        if abDescending[I] then
          ConcatField(DescFields, FieldName);
      end;
      if bDescending and (DescFields = FieldExpression) then  DescFields := '';
    end;
    Options := IndexOptions;
  end;
end;

Procedure TmySQLTable.EncodeIndexDesc(var IndexDesc: IDXDesc;
  const Name, FieldExpression: string; Options: TIndexOptions;
  const DescFields: string);

  Function IndexFieldOfs(const FieldName: string): Integer;
  var
    FieldNo: Integer;
  begin
    FieldNo := FieldDefs.Find(FieldName).FieldNo;
    for Result := 0 to IndexDesc.iFldsInKey - 1 do
      if IndexDesc.aiKeyFld[Result] = FieldNo then
        Exit;
    DatabaseErrorFmt(SIndexFieldMissing, [FieldName], Self);
    Result := -1;
  end;

var
  Pos: Integer;
begin
  FillChar(IndexDesc, SizeOf(IndexDesc), 0);
  with IndexDesc do
  begin
    TAnsiToNative(Engine, Name, szName, SizeOf(szName) - 1);
    bPrimary    := ixPrimary in Options;
    bUnique     := ixUnique in Options;
    bDescending := (ixDescending in Options) and (DescFields = '');
    bMaintained := not (ixNonMaintained in Options);
    Word(bCaseInsensitive) := Word(ixCaseInsensitive in Options);
    if ixExpression in Options then
    begin
      bExpIdx := TRUE;
      TAnsiToNative(Engine, FieldExpression, szKeyExp, SizeOf(szKeyExp) - 1);
    end
    else
    begin
      Pos := 1;
      while (Pos <= Length(FieldExpression)) and (iFldsInKey < DBIMAXFLDSINKEY) do
      begin
        aiKeyFld[iFldsInKey] :=
          FieldDefs.Find(ExtractFieldName(FieldExpression, Pos)).FieldNo;
        Inc(iFldsInKey);
      end;
      if (DescFields <> '') then
      begin
        bDescending := TRUE;
        Pos := 1;
        while Pos <= Length(DescFields) do
          abDescending[IndexFieldOfs(ExtractFieldName(DescFields, Pos))] := TRUE;
      end;
    end;
  end;
end;

Procedure TmySQLTable.AddIndex(const Name, Fields: string; Options: TIndexOptions;
  const DescFields: string);
var
  IndexDesc: IDXDesc;
begin
  FieldDefs.Update;
  if Active then
  begin
    EncodeIndexDesc(IndexDesc, Name, Fields, Options, DescFields);
    CheckBrowseMode;
    CursorPosChanged;
    Check(Engine, Engine.AddIndex(DBHandle, Handle, nil, nil, IndexDesc, nil));
  end
  else
  begin
      EncodeIndexDesc(IndexDesc, Name, Fields, Options, DescFields);
    SetDBFlag(dbfTable, TRUE);
    try
      Check(Engine, Engine.AddIndex(DBHandle, nil, NativeTableName, GetTableTypeName, IndexDesc, nil));
    finally
      SetDBFlag(dbfTable, FALSE);
    end;
  end;
  IndexDefs.Updated := FALSE;
end;

Procedure TmySQLTable.DeleteIndex(const Name: String);
var
  IndexName, IndexTag: String;
begin
  if Active then
  begin
    GetIndexParams(Name, FALSE, IndexName, IndexTag);
    CheckBrowseMode;
    Check(Engine, Engine.DeleteIndex(DBHandle, Handle, nil, nil, PChar(IndexName), PChar(IndexTag), 0));
  end
  else
  begin
    GetIndexParams(Name, FALSE, IndexName, IndexTag);
    SetDBFlag(dbfTable, TRUE);
    try
      Check(Engine, Engine.DeleteIndex(DBHandle, nil, NativeTableName, GetTableTypeName,
        PChar(IndexName), PChar(IndexTag), 0));
    finally
      SetDBFlag(dbfTable, FALSE);
    end;
  end;
  FIndexDefs.Updated := FALSE;
end;

Function TmySQLTable.GetIndexFieldNames: String;
begin
    if FFieldsIndex then Result := FIndexName else Result := '';
end;

Function TmySQLTable.GetIndexName: String;
begin
  if FFieldsIndex then Result := '' else Result := FIndexName;
end;

Procedure TmySQLTable.GetIndexNames(List: TStrings);
begin
  IndexDefs.Update;
  if IndexDefs.Count > 0 then 
     IndexDefs.GetItemNames(List);
end;

Procedure TmySQLTable.GetIndexParams(const IndexName: String;
  FieldsIndex: Boolean; var IndexedName, IndexTag: String);
var
  IndexStr: TIndexName;
  SIndexName: DBIMSG;
  SIndexTag: DBIPATH;
begin
  SIndexName[0] := #0;
  SIndexTag[0] := #0;
  if IndexName <> '' then
  begin
    IndexDefs.Update;
    IndexStr := IndexName;
    if FieldsIndex then
       IndexStr := IndexDefs.FindIndexForFields(IndexName).Name;
     TAnsiToNative(Engine, IndexStr, SIndexName, SizeOf(SIndexName) - 1);
  end;
  IndexedName := SIndexName;
  IndexTag := SIndexTag;
end;

Procedure TmySQLTable.SetIndexDefs(Value: TIndexDefs);
begin
  IndexDefs.Assign(Value);
end;

Procedure TmySQLTable.SetIndex(const Value: String; FieldsIndex: Boolean);
var
  IndexName, IndexTag: String;
begin
  if Active then CheckBrowseMode;
  if (FIndexName <> Value) or (FFieldsIndex <> FieldsIndex) then
  begin
    if Active then
    begin
      GetIndexParams(Value, FieldsIndex, IndexName, IndexTag);
      SwitchToIndex(IndexName, IndexTag);
      CheckMasterRange;
    end;
    FIndexName := Value;
    FFieldsIndex := FieldsIndex;
    if Active then Resync([]);
  end;
end;

Procedure TmySQLTable.SetIndexFieldNames(const Value: String);
begin
    SetIndex(Value, Value <> '');
end;

Procedure TmySQLTable.SetIndexName(const Value: String);
begin
  SetIndex(Value, FALSE);
end;

Procedure TmySQLTable.UpdateIndexDefs;
var
  Opts: TIndexOptions;
  IdxName, Src, Flds, DescFlds: string;

  Procedure UpdateFromCursor;
  var
    I: Integer;
    Cursor: HDBICur;
    CursorProps: CurProps;
    IndexDescs: TIndexDescList;
  begin
    if Handle = nil then
       Cursor := GetHandle('', '') else
       Cursor := Handle;
    try
      Engine.GetCursorProps(Cursor, CursorProps);
      if CursorProps.iIndexes > 0 then
      begin
        SetLength(IndexDescs, CursorProps.iIndexes);
        Engine.GetIndexDescs(Cursor, PIDXDesc(IndexDescs));
        for I := 0 to CursorProps.iIndexes - 1 do
        begin
          DecodeIndexDesc(IndexDescs[I], Src, IdxName, Flds, DescFlds, Opts);
          with IndexDefs.AddIndexDef do
          begin
            Name := IdxName;
            Fields := Flds;
            DescFields := DescFlds;
            Options := Opts;
            if Src <> '' then Source := Src;
          end;
        end;
      end;
    finally
      if (Cursor <> nil) and (Cursor <> Handle) then Engine.CloseCursor(Cursor);
    end;
  end;

  Procedure UpdateFromIndexList;
  var
    FCursor: HDBICur;
    IndexDesc: IDXDesc;
  begin
    while not CheckOpen(Engine.OpenIndexList(DBHandle, NativeTableName, GetTableTypeName, FCursor)) do {Retry};
    try
      while Engine.GetNextRecord(FCursor, dbiNoLock, @IndexDesc, nil) = 0 do
        if IndexDesc.bMaintained then
        begin
          DecodeIndexDesc(IndexDesc, Src, IdxName, Flds, DescFlds, Opts);
          with IndexDefs.AddIndexDef do
          begin
            Name := IdxName;
            Fields := Flds;
            DescFields := DescFlds;
            Options := Opts;
          end;
        end;
    finally
      Engine.CloseCursor(FCursor);
    end;
  end;

begin
  Inc(FDatabase.FRefCount);
  SetDBFlag(dbfIndexList, TRUE);
  try
    FieldDefs.Update;
    IndexDefs.Clear;
    if IsCursorOpen then
      UpdateFromCursor else
      UpdateFromIndexList;
  finally
    SetDBFlag(dbfIndexList, FALSE);
  end;
end;

Function TmySQLTable.GetExists: Boolean;
var
  E: Word;
begin
  Result := Active;
  if Result or (TableName = '') then  Exit;
  SetDBFlag(dbfTable, TRUE);
  try
    E := Engine.TableExists(DBHandle, NativeTableName);
    Result := (E = DBIERR_NONE);
  finally
    SetDBFlag(dbfTable, FALSE);
  end;
end;

Function TmySQLTable.FindKey(const KeyValues: array of const): Boolean;
begin
  CheckBrowseMode;
  SetKeyFields(kiLookup, KeyValues);
  Result := GotoKey;
end;

Procedure TmySQLTable.FindNearest(const KeyValues: array of const);
begin
  CheckBrowseMode;
  SetKeyFields(kiLookup, KeyValues);
  GotoNearest;
end;

{$HINTS OFF}
Function TmySQLTable.GotoKey: Boolean;
var
  KeyBuffer: PKeyBuffer;
  IndexBuffer, RecBuffer: PChar;
  UseKey: Boolean;
begin
  CheckBrowseMode;
  DoBeforeScroll;
  CursorPosChanged;
  KeyBuffer := GetKeyBuffer(kiLookup);
  IndexBuffer := AllocMem(KeySize);
  try
    RecBuffer := PChar(KeyBuffer) + SizeOf(TKeyBuffer);
    UseKey := Engine.ExtractKey(Handle, RecBuffer, IndexBuffer) = 0;
    if UseKey then RecBuffer := IndexBuffer;
    Result := Engine.GetRecordForKey(Handle, UseKey, KeyBuffer^.FieldCount, 0, RecBuffer, nil) = 0;
    if Result then Resync([rmExact, rmCenter]);
    if Result then DoAfterScroll;
  finally
    FreeMem(IndexBuffer, KeySize);
  end;
end;

Procedure TmySQLTable.GotoNearest;
var
  SearchCond: DBISearchCond;
  KeyBuffer: PKeyBuffer;
  IndexBuffer, RecBuffer: PChar;
  UseKey: Boolean;
begin
  CheckBrowseMode;
  CursorPosChanged;
  KeyBuffer := GetKeyBuffer(kiLookup);
  if KeyBuffer^.Exclusive then
    SearchCond := keySEARCHGT else
    SearchCond := keySEARCHGEQ;
  IndexBuffer := AllocMem(KeySize);
  try
    RecBuffer := PChar(KeyBuffer) + SizeOf(TKeyBuffer);
    UseKey := Engine.ExtractKey(Handle,RecBuffer,IndexBuffer) = 0;
    if UseKey then RecBuffer := IndexBuffer;
    Check(Engine, Engine.SetToKey(Handle, SearchCond, UseKey, KeyBuffer^.FieldCount, 0,RecBuffer));
       Resync([rmCenter]);
  finally
    FreeMem(IndexBuffer, KeySize);
  end;
end;
{$HINTS ON}

Procedure TmySQLTable.SetKey;
begin
  SetKeyBuffer(kiLookup, True);
end;

Procedure TmySQLTable.EditKey;
begin
  SetKeyBuffer(kiLookup, FALSE);
end;

Procedure TmySQLTable.ApplyRange;
begin
  CheckBrowseMode;
  if SetCursorRange then  First;
end;

Procedure TmySQLTable.CancelRange;
begin
  CheckBrowseMode;
  UpdateCursorPos;
  if ResetCursorRange then   Resync([]);
end;

Procedure TmySQLTable.SetRange(const StartValues, EndValues: array of const);
begin
  CheckBrowseMode;
  SetKeyFields(kiRangeStart, StartValues);
  SetKeyFields(kiRangeEnd, EndValues);
  ApplyRange;
end;

Procedure TmySQLTable.SetRangeEnd;
begin
  SetKeyBuffer(kiRangeEnd, TRUE);
end;

Procedure TmySQLTable.SetRangeStart;
begin
  SetKeyBuffer(kiRangeStart, TRUE);
end;

Procedure TmySQLTable.EditRangeEnd;
begin
  SetKeyBuffer(kiRangeEnd, FALSE);
end;

Procedure TmySQLTable.EditRangeStart;
begin
  SetKeyBuffer(kiRangeStart, FALSE);
end;

Procedure TmySQLTable.UpdateRange;
begin
  SetLinkRanges(FMasterLink.Fields);
end;

function TmySQLTable.GetBatchModify: Boolean;
var
  Len : Word;
begin
   if FHandle <> nil then
      Engine.GetEngProp(hDBIObj(FHandle), curAUTOREFETCH,@Result, SizeOf(Result),Len);
end;

procedure TmySQLTable.SetBatchModify(const Value : Boolean);
begin
   if FHandle = nil then Exit;
   If Value then
      Check(Engine, Engine.SetEngProp(hDbiObj(FHandle),curAUTOREFETCH,LongInt(TRUE))) else
      begin
         Check(Engine, Engine.SetEngProp(hDbiObj(FHandle),curAUTOREFETCH,LongInt(FALSE)));
         Refresh;
      end;
end;

Function TmySQLTable.GetLookupCursor(const KeyFields: String;
  CaseInsensitive: Boolean): HDBICur;
var
  IndexFound, FieldsIndex: Boolean;
  KeyIndexName, IndexName, IndexTag: String;
  KeyIndex: TIndexDef;
begin
  if (KeyFields <> FLookupKeyFields) or
     (CaseInsensitive <> FLookupCaseIns) or
     TNativeDataSet(FHandle).StatementChanged then
  begin
    DestroyLookupCursor;
    IndexFound := FALSE;
    FieldsIndex := FALSE;
    { If a range is active, don't use a lookup cursor }

	 if not FKeyBuffers[kiCurRangeStart].Modified and
		 not FKeyBuffers[kiCurRangeEnd].Modified then
	 begin
		if Database.FPseudoIndexes then
		begin
		  if not CaseInsensitive then
		  begin
			 KeyIndexName := KeyFields;
			 FieldsIndex := TRUE;
			 IndexFound := TRUE;
		  end;
		end else
		begin
		  KeyIndex := IndexDefs.GetIndexForFields(KeyFields, CaseInsensitive);
		  if (KeyIndex <> nil) and
			  (CaseInsensitive = (ixCaseInsensitive in KeyIndex.Options)) then
		  begin
			 KeyIndexName := KeyIndex.Name;
			 FieldsIndex := FALSE;
			 IndexFound := TRUE;
		  end;
		end;

		if IndexFound and (Length(KeyFields) < DBIMAXMSGLEN) then
		begin
		  Check(Engine, Engine.CloneCursor(Handle, True, False, FLookupHandle));
		  GetIndexParams(KeyIndexName, FieldsIndex, IndexName, IndexTag);
		  Check(Engine, Engine.SwitchToIndex(FLookupHandle, PChar(IndexName), PChar(IndexTag), 0, FALSE));
		end;
		
      FLookupKeyFields := KeyFields;
      FLookupCaseIns := CaseInsensitive;
    end;
  end;
  Result := FLookupHandle;
end;

Procedure TmySQLTable.DestroyLookupCursor;
begin
  if FLookupHandle <> nil then
  begin
    Engine.CloseCursor(FLookupHandle);
    FLookupHandle := nil;
    FLookupKeyFields := '';
  end;
end;

Procedure TmySQLTable.GotoCurrent(Table: TmySQLTable);
begin
  CheckBrowseMode;
  Table.CheckBrowseMode;
  if (AnsiCompareText(FDatabase.DatabaseName, Table.Database.DatabaseName) <> 0) or
     (AnsiCompareText(TableName, Table.TableName) <> 0) then  DatabaseError(STableMismatch, Self);
  Table.UpdateCursorPos;
  Check(Engine,Engine.SetToCursor(Handle, Table.Handle));
  DoBeforeScroll;
  Resync([rmExact, rmCenter]);
  DoAfterScroll;
end;

Procedure TmySQLTable.GetDetailLinkFields(MasterFields, DetailFields: TList);
var
  i: Integer;
  Idx: TIndexDef;
begin
  MasterFields.Clear;     
  DetailFields.Clear;
  if (MasterSource <> nil) and (MasterSource.DataSet <> nil) and (Self.MasterFields <> '') then
  begin
    Idx := nil;
    MasterSource.DataSet.GetFieldList(MasterFields, Self.MasterFields);
    UpdateIndexDefs;
    if IndexName <> '' then
      Idx := IndexDefs.Find(IndexName)
    else
      if IndexFieldNames <> '' then
        Idx := IndexDefs.GetIndexForFields(IndexFieldNames, FALSE)
      else
        for i := 0 to IndexDefs.Count - 1 do
          if ixPrimary in IndexDefs[i].Options then
          begin
            Idx := IndexDefs[i];
            break;
          end;
    if Idx <> nil then GetFieldList(DetailFields, Idx.Fields);
  end;
end;

Procedure TmySQLTable.CheckMasterRange;
begin
  if FMasterLink.Active and (FMasterLink.Fields.Count > 0) then
  begin
    SetLinkRanges(FMasterLink.Fields);
    SetCursorRange;
  end;
end;

Procedure TmySQLTable.MasterChanged(Sender: TObject);
begin
  CheckBrowseMode;
  UpdateRange;
  ApplyRange;
end;

Procedure TmySQLTable.MasterDisabled(Sender: TObject);
begin
  CancelRange;
end;

Function TmySQLTable.GetDataSource: TDataSource;
begin
  Result := FMasterLink.DataSource;
end;

Procedure TmySQLTable.SetDataSource(Value: TDataSource);
begin
  if IsLinkedTo(Value) then
    DatabaseError(SCircularDataLink, Self);
  FMasterLink.DataSource := Value;
end;

Function TmySQLTable.GetMasterFields: String;
begin
  Result := FMasterLink.FieldNames;
end;

Procedure TmySQLTable.SetMasterFields(const Value: String);
begin
  FMasterLink.FieldNames := Value;
end;

Procedure TmySQLTable.DoOnNewRecord;
var
  I: Integer;
begin
  if FMasterLink.Active and (FMasterLink.Fields.Count > 0) then
    for I := 0 to Pred(FMasterLink.Fields.Count) do
      IndexFields[I] := TField(FMasterLink.Fields[I]);
  Inherited DoOnNewRecord;
end;

{New 29.05.2001}
procedure TMySQLTable.CreateTable;
var
  IndexDescs: TIndexDescList;
  TableDesc: CRTblDesc;
  FieldDescs: TFieldDescList;
  ValChecks: TValCheckList;
  LvlFldDesc: FLDDesc;
  Level: DBINAME;

  procedure InitTableSettings;
  begin
    FillChar(TableDesc, SizeOf(TableDesc), 0);
    with TableDesc do
    begin
      TAnsiToNative(Engine,TableName,szTblName, SizeOf(szTblName) - 1);
      if FTableLevel > 0 then
      begin
        iOptParams := 1;
        StrCopy(@Level, PChar(IntToStr(FTableLevel)));
        pOptData := @Level;
        StrCopy(LvlFldDesc.szName, 'LEVEL');
        LvlFldDesc.iLen := StrLen(Level) + 1;
        LvlFldDesc.iOffset := 0;
        pfldOptParams :=  @LvlFldDesc;
      end;
    end;
  end;

  procedure InitFieldDescriptors;
  var
    I: Integer;
    TempFieldDescs: TFieldDescList;
  begin
    with TableDesc do
    begin
      InitFieldDefsFromFields;
      iFldCount := FieldDefs.Count;
      SetLength(TempFieldDescs, iFldCount);
      for I := 0 to FieldDefs.Count - 1 do
      with FieldDefs[I] do
      begin
        EncodeFieldDesc(TempFieldDescs[I], Name, DataType, Size, Precision);
        if Required then Inc(iValChkCount);
      end;
      SetLength(FieldDescs, iFldCount);
      pFldDesc := MySQLTypes.PFLDDesc(FieldDescs);
      Check(Engine,Engine.TranslateRecordStructure(nil,iFldCount,MySQLTypes.PFLDDesc(TempFieldDescs),nil,nil,pFLDDesc,False));
    end;
  end;

  procedure InitIndexDescriptors;
  var
    I: Integer;
  begin
    TableDesc.iIdxCount := IndexDefs.Count;
    SetLength(IndexDescs, TableDesc.iIdxCount);
    TableDesc.pIdxDesc := PIDXDesc(IndexDescs);
    for I := 0 to IndexDefs.Count - 1 do
    with IndexDefs[I] do
      EncodeIndexDesc(IndexDescs[I], Name, FieldExpression, Options, DescFields);
  end;

  procedure InitValChecks;
  var
    I, ValCheckNo: Integer;
  begin
    with TableDesc do
    if iValChkCount > 0 then
    begin
      SetLength(ValChecks, iValChkCount);
      ValCheckNo := 0;
      for I := 0 to FieldDefs.Count - 1 do
        if FieldDefs[I].Required then
        begin
          ValChecks[ValCheckNo].iFldNum := I + 1;
          ValChecks[ValCheckNo].bRequired := True;
          Inc(ValCheckNo);
        end;
      pvchkDesc := MySQLTypes.pVCHKDesc(ValChecks);
    end;
  end;

begin
  CheckInactive;
  SetDBFlag(dbfTable, True);
  try
    InitTableSettings;
    InitFieldDescriptors;
    InitIndexDescriptors;
    InitValChecks;
    Check(Engine,Engine.CreateTable(DBHandle, True, TableDesc));
  finally
    SetDBFlag(dbfTable, False);
  end;
end;

Procedure TmySQLTable.EmptyTable;
begin
  if Active then
  begin
    CheckBrowseMode;
    Check(Engine, Engine.EmptyTable(DBHandle, Handle, nil, nil));
    ClearBuffers;
    DataEvent(deDataSetChange, 0);
  end else
  begin
    SetDBFlag(dbfTable, TRUE);
    try
      Check(Engine, Engine.EmptyTable(DBHandle, nil, NativeTableName, GetTableTypeName));
    finally
      SetDBFlag(dbfTable, FALSE);
    end;
  end;
end;

Procedure TmySQLTable.LockTable(LockType: TMySQLLockType);
begin
  SetTableLock(LockType, TRUE);
end;

Procedure TmySQLTable.SetTableLock(LockType: TMySQLLockType; Lock: Boolean);
var
  L: DBILockType;
begin
  CheckActive;
  if LockType = mltReadLock then L := dbiREADLOCK else L := dbiWRITELOCK;
  if Lock then
    Check(Engine, Engine.AcqTableLock(Handle, L)) else
    Check(Engine, Engine.RelTableLock(Handle, False, L));
end;

Procedure TmySQLTable.UnlockTable;
begin
  SetTableLock(mltReadLock, FALSE);
end;

Procedure TmySQLTable.EncodeFieldDesc(var FieldDesc: FLDDesc;
  const Name: string; DataType: TFieldType; Size, Precision: Integer);
begin
  with FieldDesc do
  begin
    TAnsiToNative(Engine, Name, szName, SizeOf(szName) - 1);
    iFldType := FldTypeMap[DataType];
    iSubType := FldSubTypeMap[DataType];
    case DataType of
      ftString, ftFixedChar, ftBytes, ftVarBytes, ftBlob..ftTypedBinary:
        iUnits1 := Size;
      ftBCD:
        begin
          { Default precision is 32, Size = Scale }
          if (Precision > 0) and (Precision <= 32) then
            iUnits1 := Precision
          else
            iUnits1 := 32;
          iUnits2 := Size;
        end;
    end;
  end;
end;

Procedure TmySQLTable.DataEvent(Event: TDataEvent; Info: Longint);
begin
  if Event = depropertyChange then
     IndexDefs.Updated := FALSE;
  Inherited DataEvent(Event, Info);
end;

Function TmySQLTable.GetCanModify: Boolean;
begin
  Result := Inherited GetCanModify and not ReadOnly;
end;

Function TmySQLTable.GetTableTypeName: PChar;
begin
  Result := nil;
end;

Function TmySQLTable.GetTableLevel: Integer;
begin
  if Handle <> nil then
    Result := GetIntProp(Engine, Handle, curTABLELEVEL) else
    Result := FTableLevel;
end;

Function TmySQLTable.FieldDefsStored: Boolean;
begin
  Result := StoreDefs and (FieldDefs.Count > 0);
end;

Function TmySQLTable.IndexDefsStored: Boolean;
begin
  Result := StoreDefs and (IndexDefs.Count > 0);
end;

Function TmySQLTable.GetFileName: string;
var
  FDb: Boolean;
begin
  FDb := SetDBFlag(dbfDatabase, TRUE);
  try
      Result := Result + TableName;
  finally
    SetDBFlag(dbfDatabase, FDb);
  end;
end;

Function TmySQLTable.GetTableType: TTableType;
begin
  Result := ttDefault;
end;

Function TmySQLTable.NativeTableName: PChar;
begin
  Result := PChar(FTableName);
end;

Procedure TmySQLTable.SetExclusive(Value: Boolean);
begin
  CheckInactive;
  FExclusive := Value;
end;

Procedure TmySQLTable.SetReadOnly(Value: Boolean);
begin
  CheckInactive;
  FReadOnly := Value;
end;

Procedure TmySQLTable.SetTableName(const Value: TFileName);
begin
  if csReading in ComponentState then
    FTableName := Value
  else
    if FTableName <> Value then
    begin
      CheckInactive;
      FTableName := Value;
      FNativeTableName[0] := #0;
      DataEvent(dePropertyChange, 0);
    end;
end;

function TmySQLTable.GetTableName: TFileName;
begin
   Result := FTableName;
end;

{ TTable.IProviderSupport }
Function TmySQLTable.PSGetDefaultOrder: TIndexDef;

  Function GetIdx(IdxType : TIndexOption) : TIndexDef;
  var
    i: Integer;
  begin
    Result := nil;
    for i := 0 to IndexDefs.Count - 1 do
      if IdxType in IndexDefs[i].Options then
      try
        Result := IndexDefs[ i ];
        GetFieldList(nil, Result.Fields);
        break;
      except
        Result := nil;
      end;
  end;

var
  DefIdx: TIndexDef;
begin
  DefIdx := nil;
  IndexDefs.Update;
  try
    if (IndexName <> '') then
      DefIdx := IndexDefs.Find(IndexName)
    else
      if (IndexFieldNames <> '') then
        DefIdx := IndexDefs.FindIndexForFields(IndexFieldNames);
    if Assigned(DefIdx) then
      GetFieldList(nil, DefIdx.Fields);
  except
    DefIdx := nil;
  end;
  if not Assigned(DefIdx) then
    DefIdx := GetIdx(ixPrimary);
  if not Assigned(DefIdx) then
    DefIdx := GetIdx(ixUnique);
  if Assigned(DefIdx) then
  begin
    Result := TIndexDef.Create(nil);
    Result.Assign(DefIdx);
  end
  else
    Result := nil;
end;

Function TmySQLTable.PSGetIndexDefs(IndexTypes : TIndexOptions): TIndexDefs;
begin
  Result := GetIndexDefs(IndexDefs, IndexTypes);
end;

Function TmySQLTable.PSGetTableName: string;
begin
  Result := TableName;
end;

Procedure TmySQLTable.PSSetParams(AParams: TParams);

  Procedure AssignFields;
  var
    I: Integer;
  begin
    for I := 0 to AParams.Count - 1 do
      if (AParams[ I ].Name <> '') then
        FieldByName(AParams[ I ].Name).Value := AParams[ I ].Value
      else
        IndexFields[ I ].Value := AParams[ I ].Value;
  end;

begin
  if (AParams.Count > 0) then
  begin
    Open;
    SetRangeStart;
    AssignFields;
    SetRangeEnd;
    AssignFields;
    ApplyRange;
  end
  else
    if Active then
      CancelRange;
  PSReset;
end;

Procedure TmySQLTable.PSSetCommandText(const CommandText : string);
begin
  if CommandText <> '' then
    TableName := CommandText;
end;

Function TmySQLTable.PSGetKeyFields: string;
var
  i, Pos: Integer;
  IndexFound: Boolean;
begin
  Result := inherited PSGetKeyFields;
  if  Result = '' then
  begin
    if not Exists then  Exit;
    IndexFound := FALSE;
    IndexDefs.Update;
    for i := 0 to IndexDefs.Count - 1 do
      if ixUnique in IndexDefs[I].Options then
      begin
        Result := IndexDefs[ I ].Fields;
        IndexFound := (FieldCount = 0);
        if not IndexFound then
        begin
          Pos := 1;
          while (Pos <= Length(Result)) do
          begin
            IndexFound := (FindField(ExtractFieldName(Result, Pos)) <> nil);
            if not IndexFound then
              Break;
          end;
      	end;
        if IndexFound then Break;
      end;
    if not IndexFound then Result := '';
  end;
end;

///////////////////////////////////////////////////////////////////////////////
//                         TmySQLBlobStream                                  //
///////////////////////////////////////////////////////////////////////////////
constructor TmySQLBlobStream.Create(Field: TBlobField; Mode: TBlobStreamMode);
var
  OpenMode: DbiOpenMode;
begin
  FMode := Mode;
  FField := Field;
  FDataSet := FField.DataSet as TmySQLDataSet;
  FFieldNo := FField.FieldNo;
  if not FDataSet.GetActiveRecBuf(FBuffer) then Exit;
  if FDataSet.State = dsFilter then
    DatabaseErrorFmt(SNoFieldAccess, [FField.DisplayName], FDataSet);
  if not FField.Modified then
  begin
    if Mode = bmRead then
    begin
      FCached := FDataSet.FCacheBlobs and (FBuffer = FDataSet.ActiveBuffer) and
        (FField.IsNull or (FDataSet.GetBlobData(FField, FBuffer) <> ''));
      OpenMode := dbiReadOnly;
    end else
    begin
      FDataSet.SetBlobData(FField, FBuffer, '');
      if FField.ReadOnly then DatabaseErrorFmt(SFieldReadOnly,
        [FField.DisplayName], FDataSet);
      if not (FDataSet.State in [dsEdit, dsInsert]) then
        DatabaseError(SNotEditing, FDataSet);
      OpenMode := dbiReadWrite;
    end;
    if not FCached then
    begin
      if FDataSet.State = dsBrowse then
        FDataSet.GetCurrentRecord(FDataSet.ActiveBuffer);
      Check(Engine, Engine.OpenBlob(FDataSet.Handle, FBuffer, FFieldNo, OpenMode));
    end;
  end;
  FOpened := True;
  if Mode = bmWrite then Truncate;
end;

destructor TmySQLBlobStream.Destroy;
begin
  if FOpened then
  begin
    if FModified then FField.Modified := True;
//    if not FField.Modified and not FCached then
    if FField.Modified and not FCached then//mi
		Engine.FreeBlob(FDataSet.Handle, FBuffer, FFieldNo);
  end;
  if FModified then
  try
    FDataSet.DataEvent(deFieldChange, Longint(FField));
  except
    Application.HandleException(Self);
  end;
end;

Function TmySQLBlobStream.Engine : TmySQLEngine;
begin
  Result := FDataSet.Engine;
end;

Function TmySQLBlobStream.Read(var Buffer; Count: Longint): Longint;
var
  Status: DBIResult;
begin
  Result := 0;
  if FOpened then
  begin
    if FCached then
    begin
      if Count > Size - FPosition then
        Result := Size - FPosition else
        Result := Count;
      if Result > 0 then
      begin
        Move(PChar(FDataSet.GetBlobData(FField, FBuffer))[FPosition], Buffer, Result);
        Inc(FPosition, Result);
      end;
    end else
    begin
      Status := Engine.GetBlob(FDataSet.Handle, FBuffer, FFieldNo, FPosition,
        Count, @Buffer, Result);
      case Status of
        DBIERR_NONE, DBIERR_ENDOFBLOB:
          begin
            if FField.Transliterate then
              TNativeToAnsiBuf(Engine, @Buffer, @Buffer, Result);
            if FDataset.FCacheBlobs and (FBuffer = FDataSet.ActiveBuffer) and
              (FMode = bmRead) and not FField.Modified and (FPosition = FCacheSize) then
            begin
              FCacheSize := FPosition + Result;
              SetLength(FBlobData, FCacheSize);
              Move(Buffer, PChar(FBlobData)[FPosition], Result);
              if FCacheSize = Size then
              begin
                FDataSet.SetBlobData(FField, FBuffer, FBlobData);
                FBlobData := '';
                FCached := True;
                Engine.FreeBlob(FDataSet.Handle, FBuffer, FFieldNo);
              end;
            end;
            Inc(FPosition, Result);
          end;
        DBIERR_INVALIDBLOBOFFSET:
          {Nothing};
      else
        TDbiError(Engine, Status);
      end;
    end;
  end;
end;

Function TmySQLBlobStream.Write(const Buffer; Count: Longint): Longint;
var
  Temp: Pointer;
begin
  Result := 0;
  if FOpened then
  begin
    if FField.Transliterate then
    begin
      GetMem(Temp, Count+1);
      try
        TAnsiToNativeBuf(Engine, @Buffer, Temp, Count);
        Check(Engine, Engine.PutBlob(FDataSet.Handle, FBuffer, FFieldNo, FPosition,
          Count, Temp));
      finally
        FreeMem(Temp, Count+1);
      end;
    end else
      Check(Engine, Engine.PutBlob(FDataSet.Handle, FBuffer, FFieldNo, FPosition,
        Count, @Buffer));
    Inc(FPosition, Count);
    Result := Count;
    FModified := True;
    FDataSet.SetBlobData(FField, FBuffer, '');
  end;
end;

Function TmySQLBlobStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  case Origin of
    0: FPosition := Offset;
    1: Inc(FPosition, Offset);
    2: FPosition := GetBlobSize + Offset;
  end;
  Result := FPosition;
end;

Procedure TmySQLBlobStream.Truncate;
begin
  if FOpened then
  begin
    Check(Engine, Engine.TruncateBlob(FDataSet.Handle, FBuffer, FFieldNo, FPosition));
    FModified := True;
    FDataSet.SetBlobData(FField, FBuffer, '');
  end;
end;

Function TmySQLBlobStream.GetBlobSize: Longint;
begin
  Result := 0;
  if FOpened then
    if FCached then
      Result := Length(FDataSet.GetBlobData(FField, FBuffer)) else
      Check(Engine, Engine.GetBlobSize(FDataSet.Handle, FBuffer, FFieldNo, Result));
end;

{ TmySQLQueryDataLink }
constructor TmySQLQueryDataLink.Create(AQuery : TmySQLQuery);
begin
  Inherited Create;
  FQuery := AQuery;
end;

Procedure TmySQLQueryDataLink.ActiveChanged;
begin
  if FQuery.Active then FQuery.RefreshParams;
end;

Function TmySQLQueryDataLink.GetDetailDataSet: TDataSet;
begin
  Result := FQuery;
end;

Procedure TmySQLQueryDataLink.RecordChanged(Field : TField);
begin
  if (Field = nil) and FQuery.Active then FQuery.RefreshParams;
end;

Procedure TmySQLQueryDataLink.CheckBrowseMode;
begin
  if FQuery.Active then  FQuery.CheckBrowseMode;
end;


var
  SaveInitProc: Pointer;
  NeedToUninitialize: Boolean;

Procedure InitDBTables;
begin
  if (SaveInitProc <> nil) then
    TProcedure(SaveInitProc);
  NeedToUninitialize := Succeeded(CoInitialize(nil));
end;

Initialization
  if not IsLibrary then
  begin
    SaveInitProc := InitProc;
    InitProc := @InitDBTables;
  end;
  DBList := TList.Create;
  InitializeCriticalSection(CSNativeToAnsi);
  InitializeCriticalSection(CSAnsiToNative);
finalization
  DeleteCriticalSection(CSAnsiToNative);
  DeleteCriticalSection(CSNativeToAnsi);
  DBList.Free;
  if NeedToUninitialize then  CoUninitialize;
end.


