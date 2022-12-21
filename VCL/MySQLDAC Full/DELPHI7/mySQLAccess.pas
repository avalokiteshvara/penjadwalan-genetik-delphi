{$I mysqldac.inc}
unit mySQLAccess;

{$I mysqlinc.inc}
Interface

Uses Classes, SysUtils, Windows, Db,mySQLTypes,
	  Math,DbCommon,mySQLCP{$IFDEF DELPHI_6},Variants{$ENDIF},
	  uMyDMClient, uMyDMCT,uMyDMHelpers;

Type
  {Forward declaration}
  TNativeConnect = class;

{****************************************************************************}
{                        Error handler                                       }
{****************************************************************************}
  EmySQLException =  Class(EAbort)
    Private
      FmySQL : TNativeConnect;
      FmySQLErrorCode : Word;
      FBDEErrorCode : Word;
      FBDE          : Boolean;
      FmySQLErrorMsg : String;
      Function GetNativeErrorMsg : String;
    Public
      Constructor CreateBDE(ECode : Word);
      constructor CreateBDEMsg(ECode : Word; Const EMessage : ShortString);
      Constructor Create(mySQL : TNativeConnect);
      Constructor CreateMsg(mySQL : TNativeConnect; Const ErrorMsg : String );
      property mySQLErrorCode : word read FmySQLErrorCode;
      property mySQLErrorMsg : String read GetNativeErrorMsg;
      property BDEErrorCode : Word read FBDEErrorCode;
      property BDEErrors : Boolean read FBDE;
  end;


{****************************************************************************}
{                       TNativeConnect                                       }
{****************************************************************************}
  TNativeConnect = Class(TObject)
  private
    FHandle: TMysqlClient; 
    FOptions: TConnectOptions;
    FSSL_Key  : String;
    FSSL_Cert : String;
    function GetMultiThreaded: boolean;
    procedure SetMultiThreaded(const Value: boolean);
  Protected
    FTransState : eXState;  { Transaction end control xsActive, xsInactive }
    FTransLevel : eXILType;  { Transaction isolation levels }
    FStrtStmt   : Integer;
  Public
    Tables : TContainer; {List of Tables}
    FLoggin : Boolean; {Loggin flag}
    FInTrans  : Boolean;   {In Transaction flag}
    DBOptions : TDBOptions; {Connection parameters}
    Constructor Create(ConnOptions : TConnectOptions);
    Destructor  Destroy; Override;
    procedure ProcessDBParams(Params : TStrings);
    Procedure InternalConnect; {Login to database}
    Procedure InternalDisconnect; {Logout from database}
    procedure CheckResult; {Check result last operation}
    Function GetErrorCode: word; {Get error code}
	 Function GetErrorText: String; {Get Error text}
    Function Success: Boolean;
    function GetClientInfo: string;
    function GetServerStat: string;
    function GetHostInfo: string;
    function GetProtoInfo: Cardinal;
    function GetServerInfo: string;
    procedure Kill(PID: Integer);
    procedure SelectDB(DBName : PChar);
    function Ping : integer;
    function Shutdown: integer;
    Procedure TableList(pszWild : PChar; Views: Boolean; List : TStrings);
    procedure DatabaseList(pszWild : PChar; List : TStrings);
    Procedure OpenTable(pszTableName: PChar;pszIndexName: PChar;iIndexId: Word;
                        eOpenMode: DBIOpenMode;eShareMode: DBIShareMode;var hCursor: hDBICur;Offset,Limit : Integer);
    Procedure QueryAlloc(var hStmt: hDBIStmt);
    Procedure QueryPrepare(var hStmt: hDBIStmt;Query : PChar);
    procedure BeginTran(eXIL: eXILType; var hXact: hDBIXact);
    procedure EndTran(hXact : hDBIXact; eEnd : eXEnd);
    procedure GetTranInfo(hXact : hDBIXact; pxInfo : pXInfo);
    Procedure QExecDirect(eQryLang : DBIQryLang; pszQuery : PChar; phCur: phDBICur; var AffectedRows : LongInt);
    Procedure TableLoaded(pszTableName : PChar; Var T : TObject);
    Procedure GetCursorForTable(pszTableName: PChar;  var hCursor: hDBICur);
    procedure OpenFieldList(pszTableName: PChar;pszDriverType: PChar;bPhyTypes: Bool;var hCur: hDBICur);
    Procedure OpenIndexList(pszTableName: PChar;pszDriverType: PChar;var hCur: hDBICur);
    function GetCharSet: TConvertChar;
    procedure EmptyTable(hCursor : hDBICur; pszTableName : PChar);
    procedure TableExists(pszTableName : PChar);
	 Procedure AddIndex(hCursor: hDBICur; pszTableName: PChar; pszDriverType: PChar; var IdxDesc: IDXDesc; pszKeyviolName: PChar);
    Procedure DeleteIndex(hCursor: hDBICur; pszTableName: PChar; pszDriverType: PChar; pszIndexName: PChar; pszIndexTagName: PChar; iIndexId: Word);
    Procedure CreateTable(bOverWrite: Bool; var crTblDsc: CRTblDesc);
	 property Handle : TMysqlClient read FHandle write FHandle;
    property MultiThreaded: boolean read GetMultiThreaded write SetMultiThreaded;
    property SSLKey : string read FSSL_Key write FSSL_Key;
    property SSLCert : string read FSSL_Cert write FSSL_Cert;
  end;


  {SQL MySQLEngine}
  TmySQLEngine =  Class(TBaseObject)
    Private
      FCursor: hDBICur;
      FDatabase: hDBIDb;
      FNativeStatus: Integer;
      FNativeMsg : String;
      FStatement: hDBIStmt;
      FMT: boolean;
      FSSL_Key  : String;
      FSSL_Cert : String;
      Function GetCursor : hDBICur;
      Procedure SetCursor(H : hDBICur);
      Function GetDatabase: hDBIDb;
      Procedure SetDatabase(H : hDBIDb);
      Function GetStatement: hDBIStmt;
      Procedure SetStatement(H : hDBIStmt);
    Public
		property MultiThreaded:boolean read FMT write FMT;
      property SSLKey : string read FSSL_Key write FSSL_Key;
      property SSLCert : string read FSSL_Cert write FSSL_Cert;
      Constructor Create(P : TObject; Container : TContainer);
      Destructor Destroy; Override;
      Property Status: Integer Read  FNativeStatus;
      Property MessageStatus : String read FNativeMsg;
      Property Database: hDBIDb Read  GetDatabase Write SetDatabase;
      Property Cursor: hDBICur Read  GetCursor Write SetCursor;
      Property Statement: hDBIStmt Read  GetStatement Write SetStatement;
      function IsSqlBased(hDb: hDBIDB): Boolean;
      function OpenDatabase(ConnOptions : TConnectOptions; Params : TStrings; var hDb: hDBIDb): DBIResult;
      function CloseDatabase(var hDb : hDBIDb) : DBIResult;
      function OpenTable(hDb: hDBIDb;pszTableName: PChar;pszDriverType: PChar;pszIndexName: PChar;pszIndexTagName : PChar;
               iIndexId: Word;eOpenMode: DBIOpenMode;eShareMode: DBIShareMode;exltMode: XLTMode;bUniDirectional : Bool;pOptParams: Pointer;var hCursor: hDBICur;offset,Limit : Integer): DBIResult;
      function OpenTableList(hDb: hDBIDb; pszWild: PChar; Views : Boolean; List : TStrings): DBIResult;
      function SetToBookMark(hCur: hDBICur; pBookMark : Pointer) : DBIResult;
      function CompareBookMarks(hCur: hDBICur; pBookMark1, pBookMark2 : Pointer;var CmpBkmkResult : CmpBkmkRslt): DBIResult;
      function GetNextRecord(hCursor: hDBICur;eLock: DBILockType;pRecBuff: Pointer;pRecProps: pRECProps): DBIResult;
      function CloseCursor(hCursor: hDBICur): DBIResult;
      function PutField(hCursor: hDBICur;FieldNo: Word;PRecord: Pointer;pSrc: Pointer): DBIResult;
      function OpenBlob(hCursor: hDBICur;PRecord: Pointer;FieldNo: Word;eOpenMode: DBIOpenMode): DBIResult;
      function GetBlobSize(hCursor: hDBICur;PRecord: Pointer;FieldNo: Word;var iSize: Longint): DBIResult;
      function GetBlob(hCursor: hDBICur;PRecord: Pointer;FieldNo: Word;iOffSet: Longint;iLen: Longint;pDest: Pointer;var iRead: Longint): DBIResult;
      function PutBlob(hCursor : hDBICur; PRecord : Pointer; FieldNo : Word; iOffSet : Longint; iLen : Longint; pSrc : Pointer): DBIResult;
      function TruncateBlob(hCursor: hDBICur;PRecord: Pointer;FieldNo: Word;iLen: Longint): DBIResult;
      function FreeBlob(hCursor: hDBICur;PRecord: Pointer;FieldNo: Word): DBIResult;
      function BeginTran(hDb: hDBIDb; eXIL: eXILType; var hXact: hDBIXact): DBIResult;
		function EndTran(hDb: hDBIDb; hXact: hDBIXact; eEnd : eXEnd): DBIResult;
      function GetTranInfo(hDb: hDBIDb;hXact: hDBIXact; pxInfo: pXInfo): DBIResult;
      function GetEngProp(hObj: hDBIObj;iProp: Longint;PropValue: Pointer;iMaxLen: Word;var iLen: Word): DBIResult;
      function SetEngProp(hObj: hDBIObj;iProp: Longint;PropValue: Longint): DBIResult;
      function GetVchkDesc(hCursor: hDBICur;iValSeqNo: Word;pvalDesc: pVCHKDesc): DBIResult;
      function GetCursorProps(hCursor: hDBICur;var curProps: CURProps): DBIResult;
      function GetObjFromObj(Source: hDBIObj; eObjType: DBIOBJType; var hObj: hDBIObj): DBIResult;
      function GetFieldDescs(hCursor: hDBICur;pfldDesc: pFLDDesc): DBIResult;
      function SetToBegin(hCursor: hDBICur): DBIResult;
      function SetToEnd(hCursor: hDBICur): DBIResult;
      function RelRecordLock(hCursor: hDBICur;bAll: Bool): DBIResult;
      function InitRecord(hCursor: hDBICur;PRecord: Pointer ): DBIResult;
      function CheckBuffer(hCursor: hDBICur;PRecord: Pointer ): DBIResult; //:CN 29/05/2005
      function InsertRecord(hCursor: hDBICur;eLock: DBILockType;PRecord: Pointer): DBIResult;
      function AppendRecord(hCursor: hDBICur;PRecord:Pointer): DBIResult;
      function ModifyRecord(hCursor: hDBICur;OldRecord,PRecord:Pointer;bFreeLock: Bool): DBIResult;
      function DeleteRecord(hCursor: hDBICur;PRecord:Pointer): DBIResult;
      function SettoSeqNo(hCursor: hDBICur;iSeqNo: Longint): DBIResult;
      function GetPriorRecord(hCursor: hDBICur;eLock:DBILockType;PRecord: Pointer;pRecProps: pRECProps): DBIResult;
      function GetRecord(hCursor: hDBICur;eLock: DBILockType;PRecord: Pointer;pRecProps: pRECProps): DBIResult;
      function GetBookMark(hCur: hDBICur;pBookMark: Pointer): DBIResult;
      function GetRecordCount(hCursor: hDBICur;Var iRecCount: Longint): DBIResult;
      function ForceReread(hCursor: hDBICur): DBIResult;
      function ForceRecordReread(hCursor: hDBICur; pRecBuff: Pointer): DBIResult;
      function GetField(hCursor: hDBICur;FieldNo: Word;PRecord: Pointer;pDest: Pointer;var bBlank: Bool): DBIResult;
      function AnsiToNative(pNativeStr: PChar;pAnsiStr: PChar;iLen: LongInt;var bDataLoss : Bool): DBIResult;
      function NativeToAnsi(pAnsiStr: PChar;pNativeStr: PChar;iLen: LongInt;var bDataLoss : Bool): DBIResult;
      function AddFilter(hCursor: hDBICur;iClientData: Longint;iPriority: Word;bCanAbort: Bool;pcanExpr: pCANExpr;pfFilter: pfGENFilter;var hFilter: hDBIFilter): DBIResult;
		function DropFilter(hCursor: hDBICur;hFilter: hDBIFilter): DBIResult;
      function ActivateFilter(hCursor: hDBICur;hFilter: hDBIFilter): DBIResult;
      function DeactivateFilter(hCursor: hDBICur;hFilter: hDBIFilter): DBIResult;
      function GetErrorEntry(uEntry: Word;var ulNativeError: Longint;pszError: PChar): DBIResult;
      function GetErrorString(rslt: DBIResult;ErrorMsg: String): DBIResult;
      function QExecDirect(hDb: hDBIDb;eQryLang: DBIQryLang; pszQuery: PChar; phCur: phDBICur; var AffectedRows : LongInt): DBIResult;
      function QAlloc(hDb: hDBIDb;eQryLang: DBIQryLang;var hStmt: hDBIStmt): DBIResult;
      function QPrepare(hStmt: hDBIStmt;pszQuery: PChar): DBIResult;
      function QExec(hStmt: hDBIStmt;phCur: phDBICur): DBIResult;
      function QFree(var hStmt: hDBIStmt): DBIResult;
      function QuerySetParams(hStmt: hDBIStmt;Params : TParams; SQLText : String): DBIResult;
      function CheckError : DBIResult;
      function GetClientInfo(var ClientInfo: String): DBIResult;
      function GetServerStat(hDb: hDBIDb;var ServerStat: string):DBIResult;
      function GetHostInfo(hDb: hDBIDb;var HostInfo: string):DBIResult;
      function GetProtoInfo(hDb: hDBIDb;var ProtoInfo: Cardinal):DBIResult;
      function GetServerInfo(hDb: hDBIDb;var ServerInfo: string):DBIResult;
      function GetDatabases(hDb: hDBIdb; pszWild: PChar; List : TStrings):DBIResult;
      function SelectDb(hDb:hDBIdb; pszDbName : PChar): DBIResult;
      function GetCharacterSet(hDb : hDBIDb; var CharSet : TConvertChar):DBIResult;
      function Ping(hDb:hDBIdb; var Status : Integer):DBIResult;
      function Kill(hDb:hDBIdb;PID: Integer):DBIResult;
      function ShutDown(hDb:hDBIdb; var Status : Integer):DBIResult;  // ptook
      function OpenFieldList(hDb: hDBIDb;pszTableName: PChar;pszDriverType: PChar;bPhyTypes: Bool;var hCur: hDBICur): DBIResult;
      function OpenIndexList(hDb: hDBIDb;pszTableName: PChar;pszDriverType: PChar;var hCur: hDBICur): DBIResult;
      function EmptyTable(hDb: hDBIDb; hCursor : hDBICur; pszTableName : PChar; pszDriverType : PChar): DBIResult;
      function SetRange(hCursor : hDBICur;bKeyItself: Bool;iFields1: Word;iLen1: Word;pKey1: Pointer;bKey1Incl: Bool;
                        iFields2: Word;iLen2: Word;pKey2: Pointer;bKey2Incl: Bool): DBIResult;
		function ResetRange(hCursor : hDBICur) : DBIResult;
      function SwitchToIndex(hCursor : hDBICur; pszIndexName, pszTagName : PChar; iIndexId : Word; bCurrRec : Bool) : DBIResult;
      function ExtractKey(hCursor: hDBICur;PRecord: Pointer;pKeyBuf: Pointer): DBIResult;
      function GetRecordForKey(hCursor: hDBICur; bDirectKey: Bool; iFields: Word; iLen: Word; pKey: Pointer; pRecBuff: Pointer): DBIResult;
      function AddIndex(hDb: hDBIDb;hCursor: hDBICur;pszTableName: PChar;pszDriverType: PChar;var IdxDesc: IDXDesc;pszKeyviolName: PChar): DBIResult;
      function DeleteIndex(hDb: hDBIDb;hCursor: hDBICur;pszTableName: PChar;pszDriverType: PChar;pszIndexName: PChar;pszIndexTagName: PChar;iIndexId: Word): DBIResult;
      function GetIndexDesc(hCursor: hDBICur;iIndexSeqNo: Word;var idxDesc: IDXDesc): DBIResult;
      function GetIndexDescs(hCursor: hDBICur;idxDesc: PIDXDesc): DBIResult;
      function TranslateRecordStructure(pszSrcDriverType: PChar; iFlds: Word; pfldsSrc: pFLDDesc; pszDstDriverType: PChar; pszLangDriver: PChar;pfldsDst: pFLDDesc; bCreatable: Bool): DBIResult;
      function TableExists(hDb: hDBIDb; pszTableName: PChar): DBIResult;
      function CreateTable(hDb: hDBIDb; bOverWrite: Bool; var crTblDsc: CRTblDesc): DBIResult;
      function AcqTableLock(hCursor: hDBICur; eLockType: DBILockType): DBIResult;
      function RelTableLock(hCursor: hDBICur; bAll: Bool; eLockType: DBILockType): DBIResult;
      function SetToKey(hCursor: hDBICur;eSearchCond: DBISearchCond;bDirectKey: Bool;iFields: Word;iLen: Word;pBuff: Pointer): DBIResult;
      function CloneCursor(hCurSrc: hDBICur;bReadOnly: Bool;bUniDirectional: Bool;var   hCurNew: hDBICur): DBIResult;
      function SetToCursor(hDest, hSrc : hDBICur) : DBIResult;
      function GetLastInsertID(hCursor : hDBICur; var ID : Int64) : DBIResult;
      function GetLastInsertID_Stmt(hStmt: hDBIStmt; var ID : Int64) : DBIResult;
      function ReadBlock(hCursor : hDBICur; var iRecords : Longint; pBuf : Pointer): DBIResult;
      function WriteBlock(hCursor : hDBICur; var iRecords : Longint; pBuf : Pointer): DBIResult;
      {added by pasha_golub 11.07.05}
      function GetFieldValueFromBuffer(hCursor: hDBICur; PRecord: Pointer; AFieldName: string; var AValue: string; var AFieldType: word): DBIResult;
    end;

  /////////////////////////////////////////////////////////
  //               Forward declaration                   //
  /////////////////////////////////////////////////////////
  TNativeDataSet = Class;
  TMySqlOpenMode = (omUse, omStore);
  //////////////////////////////////////////////////////////
  //Class       : TmySQLField
  //Description : mySQL Field Description
  //////////////////////////////////////////////////////////
  TmySQLField = Class(TCollectionItem)
    Private
      FDesc      : FldDesc;
      FValCheck  : VCHKDesc;
      FBuffer    : Pointer;
      FData      : Pointer;
      FStatus    : PFieldStatus;
      FEnum_Val  : string;
      FLocalSize : LongInt;
      Function GetLocalType : Word;
      Procedure SetLocalType(S : Word);
      Function GetFieldName : String;
      Procedure SetFieldName(Const Value : String);
      Procedure SetBuffer(PRecord : Pointer);
      Function GetChanged : Boolean;
      Procedure SetChanged(Flag : Boolean);
      Function GetNull : Boolean;
      Procedure SetNull(Flag : Boolean);
    Public
      Constructor CreateField(Owner : TCollection; P : pFldDesc;P1 :pVCHKDesc; FNum, LType: Word; LSize : LongInt; enum_val : string);
      function FieldValue: PChar;
      Property Buffer : Pointer Read FBuffer Write SetBuffer;
      Property Data : Pointer Read FData;
		Property DataOffset : Word Read  FDesc.iOffset Write  FDesc.iOffset;
      Property Description : FLDDesc Read FDesc Write FDesc;
      Property ValCheck : VCHKDesc Read FValCheck Write FValCheck;
      Property FieldChanged : Boolean Read GetChanged Write SetChanged;
      Property FieldNull : Boolean Read GetNull Write SetNull;
      Property FieldStatus : PFieldStatus Read FStatus;
      Property NullOffset : Word Read FDesc.iNullOffset Write FDesc.iNullOffset;
    Published
      Property FieldNumber  : Word     Read FDesc.iFldNum Write FDesc.iFldNum;
      Property FieldName    : String   Read GetFieldName Write SetFieldName;
      Property FieldType    : Word     Read FDesc.iFldType Write  FDesc.iFldType;
      Property FieldSubType : Word     Read FDesc.iSubType Write  FDesc.iSubType;
      Property FieldUnits1  : SmallInt Read FDesc.iUnits1 Write  FDesc.iUnits1;
      Property FieldUnits2  : SmallInt Read FDesc.iUnits2 Write  FDesc.iUnits2;
      Property FieldLength  : Word     Read FDesc.iLen Write  FDesc.iLen;
      Property NativeType   : Word     Read GetLocalType Write  SetLocalType;
      Property NativeSize   : LongInt  Read FLocalSize Write  FLocalSize;
      property Enum_Value   : string   read FEnum_val write FEnum_val;
  end;

  //////////////////////////////////////////////////////////
  //Class       : TmySQLFields
  //Description : List mySQL Fields for current cursor
  //////////////////////////////////////////////////////////
   TmySQLFields = Class(TCollection)
    Private
      FTable : TNativeDataSet;
      Function GetField(Index : Integer) : TmySQLField;
	 Public
      Constructor Create(Table : TNativeDataSet);
      Property Field[Index : Integer] : TmySQLField Read  GetField; Default;
      Procedure SetFields(PRecord : Pointer);
      Function FieldNumberFromName(SearchName : PChar) : Integer;
  end;

  //////////////////////////////////////////////////////////
  //Class       : TmySQLIndex
  //Description : mySQL Index Description
  //////////////////////////////////////////////////////////
  TmySQLIndex = Class(TCollectionItem)
    Private
      FDesc      : IDXDesc;
      Function GetIndexName : String;
      Procedure SetIndexName(Const Value : String);
    Public
      Constructor CreateIndex(Owner : TCollection; P : pIDXDesc);
      Property Description : IDXDesc Read FDesc Write FDesc;
    Published
      Property IndexNumber : Word Read FDesc.iIndexID Write FDesc.iIndexID;
      Property IndexName   : String Read GetIndexName Write SetIndexName;
      Property Primary     : WordBool Read FDesc.bPrimary Write FDesc.bPrimary;
      Property Unique      : WordBool Read FDesc.bUnique Write FDesc.bUnique;
      Property Descending  : WordBool Read FDesc.bDescending Write FDesc.bDescending;
      Property FldsInKey   : Word Read FDesc.iFldsInKey Write  FDesc.iFldsInKey;
      Property KeyLen      : Word Read FDesc.iKeyLen Write FDesc.iKeyLen;
      Property BlockSize   : Word Read FDesc.iBlockSize Write FDesc.iBlockSize;
  end;

  //////////////////////////////////////////////////////////
  //Class       : TmySQLIndexes
  //Description : List mySQL Indexes for current cursor
  //////////////////////////////////////////////////////////
   TmySQLIndexes = Class(TCollection)
    Private
      FTable : TNativeDataSet;
      Function GetIndex(Index : Integer) : TmySQLIndex;
      function FindByName(Name :String): TmySQLIndex;
    Public
      Constructor Create(Table : TNativeDataSet);
      Property mIndex[Index : Integer] : TmySQLIndex Read  GetIndex; Default;
      Procedure SetIndex(Name,Fields : String;aPrimary,aUnique,aDesc : Boolean);
      Function FieldNumberFromName(SearchName : PChar) : Integer;
  end;

  //////////////////////////////////////////////////////////
  //Class       : TmySQLFilter
  //Description : Filtered object
  //////////////////////////////////////////////////////////
  TmySQLFilter = class(TObject)
  protected
    Function PerformCANOp(AOperator : CANOp; AOp1, AOp2 : Variant) : Variant;
    Function PerformCanConst(ANode : PCANConst; ValuesStart : Pointer; Var FldType : TFldType) : Variant;
//    function TimeOf(const ADateTime: TDateTime): TDateTime;
  private
	 FDataSet    : TNativeDataSet;
    FExpression : pCANExpr;
    FActive     : Bool;
    FExprSize   : Word;
    FRecBuff    : Pointer;
    FPfFilter   : pfGENFilter;
    FClientData : Longint;
    Function GetNodeStart : Integer;
    Function GetNodeByOffset(AOffSet : Integer) : PCanNode;
    Function UnaryNode(ANode : PCANUnary) : Variant;
    Function BinaryNode(ANode : PCANBinary) : Variant;
    Function CompareNode(ANode : PCANCompare) : Variant;
    Function FieldNode(ANode : pCANField) : Variant;
    Function GetNodeValue(AOffSet : Integer) : Variant;
    Function CalcExpression(ANode : PCanNode) : Variant;
    function GetLiteralPtr(AOffset : Word):Pointer;
    function ListOfValues(ANode : pCANListElem): Variant;
    Function PerformLikeCompare(Const Value, Mask : String; CaseSen : Boolean) : Boolean;
    Function PerformInCompare(AOp1, AOp2 : Variant) : Boolean;
    Property NodeStart : Integer     Read GetNodeStart;
  public
    Constructor Create(Owner : TNativeDataSet; AClientData : Longint; Exp : pCANExpr; pfFilt : pfGENFilter);
    Destructor Destroy; Override;
    Function GetFilterResult(PRecord : Pointer) : Variant;
    Property Active : Bool Read  FActive  Write FActive;
  end;

  //////////////////////////////////////////////////////////
  //Class       : TNativeDataSet
  //Description : Base class for All Objects
  //////////////////////////////////////////////////////////
    TNativeDataSet = Class(TObject)
    Protected
      FRecNo        : LongInt; {Record Nomber}
      FOpenMode     : TMySqlOpenMode; {Query open mode}
      FOMode        : DBIOpenMode;  {Open mode}
      FRecordCount  : LongInt; {Record count}
      FStatement    : TMysqlResult; {Handle mySQL Cursor }

      FStatementChanged : Boolean; { Set to TRUE when FStatement is renewed }

      FFilters      : TContainer; {Filters list}
      FFilterActive : Boolean;  {is Active filter for Query }
      FReFetch      : Boolean;  {Batch Insert allows}
      FFieldDescs   : TmySQLFields;
      FIndexDescs   : TmySQLIndexes;
      FKeyNumber    : SmallInt;
      FIndexName    : DBITBLNAME;
      FPrimaryKeyNumber: SmallInt;
      FGetKeyDesc   : Boolean;
      FKeyDesc      : IDXDesc;
      Ranges        : Boolean;
      FRecSize      : Integer;
      FConnect      : TNativeConnect;
      FOpen         : Boolean; {is Active Query}
      FAffectedRows : LongInt; {Affected Rows}
		FLastInsertID : Int64; {Last Inserted ID}
      FBookOfs        : Integer;
      FRecordState    : TRecordState;
      FLastDir        : TDir;
      FCurrentBuffer  : Pointer;
      FInternalBuffer : Pointer;
      FIsLocked       : Boolean;
      FReRead         : Boolean;
      OrderClause     : TStrings;
      RangeClause     : TStrings;
      StandartClause  : TStrings;
      LimitClause     : TStrings;
      AutoReExec      : Boolean;
      FBaseDesc       : TBLBaseDesc;
      FLimit          : Integer;
      FOffset         : Integer;
      MasterCursor    : Pointer;
      FContainer      : TContainer;
      //////////////////////////////////////////////////////////
      //            PROTECTED METHODS                         //
      //////////////////////////////////////////////////////////
      Procedure SetInternalBuffer(Buffer : Pointer);
      Function GetInternalBuffer: Pointer;
      Function GetCurrentBuffer: Pointer;
      Procedure SetCurrentBuffer(PRecord : Pointer);
      Procedure SetBufferAddress(P : Pointer);
      Procedure SetKeyNumber(newValue: SmallInt);
      Function FieldOffset(iField: Integer): Word;
		Function GetBookMarkSize: Integer;
      Function GetIndexCount: Integer;
      Procedure SetBufBookmark;
      Function GetRecordNumber : Longint;
      function GetRecCount: LongInt;
      Procedure InitFieldDescs;
      Procedure CheckFilter(PRecord : Pointer);
      Procedure FirstRecord; virtual;
      Procedure LastRecord;
      Procedure NextRecord;
      Procedure PrevRecord;
      Procedure CurrentRecord(RecNo : LongInt);
      Procedure GetWorkRecord(eLock : DBILockType; PRecord : Pointer);
      Procedure GetRecordNo(var iRecNo : Longint);
      Procedure LockRecord(eLock : DBILockType);
      Function FilteredRecord(PRecord : Pointer) :  Boolean;
      Procedure UpdateFilterStatus;
      function FieldCount : Integer;
      Procedure InternalReadBuffer;
      Function GetTableName: PChar;
      Procedure SetTableName(Name : PChar);
      function CheckUniqueKey(var KeyNumber : integer): Boolean;      
      procedure GetKeys(Unique: Boolean;var FieldList: TFieldArray; var FieldCount: Integer);
      function GetDeleteSQL(Table: string; PRecord: Pointer): string;
      function GetInsertSQL(Table: string; PRecord: Pointer): string;
      function GetUpdateSQL(Table: string; OldRecord,PRecord: Pointer): String;
      function InternaENUM_SET_Value(TableName,FieldName:String):string;
      function InternalGetDefault(TableName,FieldName:String):Pchar;
		function FieldVal(FieldNo: Integer; FieldPtr : Pointer; DoubleQuote : Boolean):String;
      function GetStatementChanged: Boolean;
      //////////////////////////////////////////////////////////
      //            MYSQL FIELD PARAMS                        //
      //////////////////////////////////////////////////////////
      function FieldName(FieldNum: Integer): ShortString;
      function FieldIndex(FieldName: ShortString): Integer;
      function FieldSize(FieldNum: Integer): LongInt;
      function FieldMaxSize(FieldNum: Integer): LongInt;
      function FieldType(FieldNum: Integer): Integer;
      function FieldIsNull(FieldNum: Integer): Boolean;
      function Field(FieldNum: Integer): string;
      function FieldBuffer(FieldNum: Integer): PChar;
      function FieldByName(FieldName: ShortString): string;
      function FieldDecimals(FieldNum: Integer): Integer;
      function  GetSQLClause: PChar;
      Function GetBufferSize : Word; Virtual;
      Function GetWorkBufferSize : Word; virtual;
      Procedure GetNativeDesc(FieldNo : Integer;P : pFldDesc; P1: pVCHKDesc; Var LocType: Word; var LocSize : LongInt; var EnumValue : String);
      Procedure NativeToDelphi(P: TmySQLField;PRecord: Pointer; pDest: Pointer; var bBlank: Bool);
      Procedure DelphiToNative(P: TmySQLField;PRecord: Pointer;pSrc: Pointer);
      procedure CheckParam(Exp : Boolean;BDECODE : Word);
      Function GetRecordSize: Integer;
      Function GetFieldInfo(Index : Integer) : PMYSQL_FIELDDEF;
      Procedure ReOpenTable;
      Procedure ClearIndexInfo;
      function GetRecNo:Longint;
     private
		Property KeyNumber: SmallInt Read FKeyNumber Write SetKeyNumber;
      Property RecordNumber : LongInt Read GetRecordNumber;
      property RecordCount : LongInt Read GetRecCount;
      Property Fields : TmySQLFields Read  FFieldDescs;
      Property RecordSize : Integer read GetRecordSize;
      Property FieldInfo[Index: Integer]:PMYSQL_FIELDDEF Read GetFieldInfo;
      Property BufferAddress : Pointer Write SetBufferAddress;
      Property CurrentBuffer : Pointer Read  GetCurrentBuffer Write SetCurrentBuffer;
      Property InternalBuffer : Pointer Read  GetInternalBuffer Write SetInternalBuffer;
      Property IndexCount : Integer Read  GetIndexCount;
    Public
      SQLQuery : String;
      isQuery  : Boolean;
      Constructor Create(mySQL : TNativeConnect; Container : TContainer; Name, IndexName : PChar;Index : Word;Offset,Limit : Integer);
      Destructor Destroy; Override;
      Procedure CompareBookMarks(pBookMark1, pBookMark2 : Pointer; var CmpBkmkResult : CmpBkmkRslt);
      Procedure GetBookMark(P : Pointer);
      procedure Execute;
      procedure InternalOpen(asql_stmt : PChar);
      procedure OpenTable;
//      procedure ShowIndexes(TableName: ShortString);
      Procedure GetField(FieldNo : Word; PRecord : Pointer; pDest : Pointer; var bBlank : Bool);
      Procedure PutField(FieldNo: Word;PRecord : Pointer; PSrc:Pointer);
      procedure CloseTable;
      procedure GetVchkDesc(iValSeqNo: Word;pvalDesc: pVCHKDesc);
      Procedure GetCursorProps(var curProps : CURProps);
      Procedure GetFieldDescs(pFDesc : pFLDDesc);
      Procedure GetRecordCount(Var iRecCount : Longint); virtual;
		Procedure LoadProperties(pRecProps : pRECProps);
      Procedure GetNextRecord(eLock : DBILockType; PRecord : Pointer; pRecProps : pRECProps); Virtual;
      Procedure SetToBookmark(P : Pointer); virtual;
      Procedure GetRecord(eLock : DBILockType; PRecord : Pointer; pRecProps : pRECProps);
      Procedure GetPriorRecord(eLock : DBILockType; PRecord : Pointer; pRecProps : pRECProps);
      Procedure AddFilter(iClientData: Longint;iPriority: Word;bCanAbort: Bool;pcanExpr: pCANExpr;pfFilter: pfGENFilter; var hFilter : hDBIFilter);
      Procedure DropFilter(hFilter: hDBIFilter);
      Procedure ActivateFilter(hFilter : hDBIFilter);
      Procedure DeactivateFilter(hFilter : hDBIFilter);
      Procedure GetProp(iProp: Longint;PropValue: Pointer;iMaxLen: Word;var iLen: Word);
      Procedure SetProp(iProp: Longint; PropValue : Longint);
      procedure SetToBegin; Virtual;
      procedure SetToEnd;
      Procedure ForceReread;
      Procedure ForceRecordReread(pRecBuff: Pointer);
      Procedure InitRecord(PRecord : Pointer);
      Procedure InsertRecord(eLock : DBILockType; PRecord : Pointer);
      Procedure AppendRecord(PRecord : Pointer);
      Procedure ModifyRecord(OldRecord,PRecord : Pointer; bFreeLock : Bool);
      Procedure DeleteRecord(PRecord : Pointer);
      procedure SetToRecord(RecNo : LongInt);
      procedure OpenBlob(PRecord: Pointer;FieldNo: Word;eOpenMode: DBIOpenMode);
      Procedure FreeBlob(PRecord: Pointer;FieldNo: Word);
      Procedure GetBlobSize(PRecord : Pointer; FieldNo : Word; var iSize : Longint);
      Procedure GetBlob(PRecord : Pointer; FieldNo : Word; iOffSet : Longint; iLen : Longint; pDest : Pointer; var iRead : Longint);
      Procedure PutBlob(PRecord: Pointer;FieldNo: Word;iOffSet: Longint;iLen: Longint; pSrc : Pointer);
      Procedure TruncateBlob(PRecord : Pointer; FieldNo : Word; iLen : Longint);
      procedure QuerySetParams(Params : TParams; SQLText : String);
		Procedure RelRecordLock(bAll: Bool);
      Procedure ExtractKey(PRecord: Pointer;pKeyBuf: Pointer);
      Procedure GetRecordForKey(bDirectKey: Bool; iFields: Word; iLen: Word; pKey: Pointer; pRecBuff: Pointer);
      Procedure GetIndexDesc(iIndexSeqNo : Word; var idxDesc : IDXDesc);
      Procedure GetIndexDescs(Desc : PIDXDesc);
      Procedure SetRange(bKeyItself : Bool; iFields1 : Word; iLen1 : Word; pKey1 : Pointer;
                bKey1Incl : Bool; iFields2 : Word; iLen2 : Word; pKey2 : Pointer; bKey2Incl : Bool);
      Procedure ResetRange;
      Procedure SwitchToIndex(pszIndexName : PChar; pszTagName : PChar; iIndexId : Word; bCurrRec : Bool);
      procedure SettoSeqNo(iSeqNo: Longint);
      procedure EmptyTable;
      Procedure AddIndex(var IdxDesc: IDXDesc; pszKeyviolName : PChar);
      Procedure DeleteIndex(pszIndexName: PChar; pszIndexTagName: PChar; iIndexId: Word);
      Procedure AcqTableLock(eLockType: DBILockType);
      Procedure RelTableLock(bAll: Bool;eLockType: DBILockType);
      Procedure	SetToKey(eSearchCond: DBISearchCond; bDirectKey: Bool;iFields: Word;iLen: Word;pBuff: Pointer);
      procedure Clone(bReadOnly: Bool;bUniDirectional: Bool;var hCurNew: hDBICur);
      procedure SetToCursor(hDest : hDBICur);
      function GetLastInsertID: Int64;
      Procedure ReadBlock(var iRecords : Longint; pBuf : Pointer);
      Procedure WriteBlock(var iRecords : Longint; pBuf : Pointer);

      function SetRowPosition(iFields : Integer; LID : Int64; pRecBuffer : Pointer):Boolean;
		function FieldValueFromBuffer(PRecord: Pointer; AFieldName: string; var AFieldType: word): string;

		procedure SortBy(FieldNames : string);//mi
      
      property OpenMode: TMySqlOpenMode read FOpenMode write FOpenMode;
		Property RecordState: TRecordState  Read  FRecordState Write FRecordState;
      Property TableName : PChar Read  GetTableName Write SetTableName;
      property RecordNo : LongInt read GetRecNo;
      Property BookMarkSize : Integer Read  GetBookMarkSize;
      Property Connect : TNativeConnect read FConnect;
      property Offset  : Integer Read FOffset;
      property Limit   : integer Read FLimit;

      property IsLocked: boolean read FIsLocked write FIsLocked;
      
      Property  StatementChanged : Boolean Read GetStatementChanged;
 end;

 TIndexList = Class(TNativeDataSet)
 Private
    Descs     : Pointer;
    Items     : Word;
    Position  : Word;
 Public
    Constructor Create(mySQL : TNativeConnect; D : Pointer; TotalCount : Word);
    Destructor Destroy; Override;
    Procedure SetToBegin; Override;
    Procedure GetNextRecord(eLock: DBILockType;PRecord: Pointer;pRecProps: pRECProps); Override;
    Function GetBufferSize : Word; Override;
    Function GetWorkBufferSize : Word; Override;
    Procedure SetToBookmark(P : Pointer); override;
    Procedure GetRecordCount(Var iRecCount : Longint); override;
 end;

 TFieldList = Class(TIndexList)
 Public
	 Function GetBufferSize : Word; Override;
 end;

function GetFldName(AFld : TmySQLField):String;
Function AdjustNativeField(iField : TmySQLField; Src, Dest : Pointer; Var Blank : Bool) : Word;
Function AdjustDelphiField(iField : TmySQLField; Src, Dest : Pointer) : Word;
Procedure mySQLException(mySQL : TNativeConnect);
Procedure mySQLExceptionMsg(mySQL : TNativeConnect; Const ErrorMsg : String );

function BDETOMySQLStr(Field : TmySQLField): String;
function BDETOMySQLIdxStr(Index : TmySQLIndex;Flds : TMySQLFields): String;
function SQLCreateIdxStr(Index : TmySQLIndex;TableName : String;Flds : TMySQLFields): String;


Implementation

Uses Dialogs,Forms,MySQLMonitor, uMyDMSSL;


{**************************************************************************}
{                     Utility Objects                                      }
{**************************************************************************}

function GetFldName(AFld : TmySQLField):String;
begin
	if ServerVersion > 32306 then
      Result := '`'+AFld.FieldName+'`' else
      Result := AFld.FieldName;
end;

Function AdjustNativeField(iField :TmySQLField;Src,Dest: Pointer; Var Blank : Bool): Word;
begin
  Result := 0;
  if PChar(Src)^ = #0 then
  begin
    Blank  := True;
    Exit;
  end;
  Blank := False;
  Inc(PChar(Src));
  Case iField.NativeType of
    FIELD_TYPE_TINY:     SmallInt(Dest^) := SmallInt(Src^);
    FIELD_TYPE_SHORT:    SmallInt(Dest^) := SmallInt(Src^);
    FIELD_TYPE_INT24:    longInt(Dest^) := LongInt(Src^);
    FIELD_TYPE_LONG:     LongInt(Dest^) := LongInt(Src^);
    FIELD_TYPE_LONGLONG: Int64(Dest^) := Int64(Src^);
    FIELD_TYPE_YEAR:     LongInt(Dest^):= LongInt(Src^);
    FIELD_TYPE_SET,
    FIELD_TYPE_VAR_STRING,
    FIELD_TYPE_STRING:   StrLCopy(Dest,Src,iField.NativeSize);
    FIELD_TYPE_DATE,
    FIELD_TYPE_NEWDATE:  begin
                            try
                              LongInt(Dest^) := DateTimeToTimeStamp(TDateTime(Src^)).Date;
                            except
                              Result := 1;
                            end;
                         end;
    FIELD_TYPE_TIME:     begin
                            try
                              LongInt(Dest^) := MSecsToTimeStamp(TDateTime(Src^)* MSecsPerDay).Time;
                            except
                              Result := 1;
                            end;
                         end;
    FIELD_TYPE_TIMESTAMP,
    FIELD_TYPE_DATETIME: begin
                            try
                              TDateTime(Dest^):= TimeStampToMSecs(DateTimeToTimeStamp(TDateTime(Src^)));
                            except
                              Result:=1;
                            end;
                         end;

    FIELD_TYPE_FLOAT,
    FIELD_TYPE_DOUBLE:  Double(Dest^) := Double(Src^);
    FIELD_TYPE_DECIMAL: Double(Dest^) := Double(Src^);
    FIELD_TYPE_NEWDECIMAL: Double(Dest^) := Double(Src^); //:CN 04/05/2005
    FIELD_TYPE_ENUM:    begin
                           if iField.NativeSize = 2{1} then
                              SmallInt(Dest^) := Byte(Src^) else
                              StrLCopy(Dest,Src,iField.NativeSize);
                        end;
  else
    Result := 1;
  end;
  If Result <> 0 then Blank  := TRUE;
end;

Function AdjustDelphiField(iField:TmySQLField; Src, Dest : Pointer) : Word;
var
     TimeStamp: TTimeStamp;
begin
  ZeroMemory(Dest,iField.FieldLength);
  PChar(Dest)^:=#1;
  Inc(PChar(Dest),1);
  Result:=0;
  Case iField.NativeType of
      FIELD_TYPE_TINY:     SmallInt(Dest^) := SmallInt(Src^);
      FIELD_TYPE_SHORT:    SmallInt(Dest^) := SmallInt(Src^);
      FIELD_TYPE_INT24:    longInt(Dest^) := LongInt(Src^);
      FIELD_TYPE_LONG:     LongInt(Dest^) := LongInt(Src^);
      FIELD_TYPE_LONGLONG: Int64(Dest^) := Int64(Src^);
      FIELD_TYPE_YEAR:     LongInt(Dest^):= LongInt(Src^);
      FIELD_TYPE_SET,
      FIELD_TYPE_VAR_STRING,
      FIELD_TYPE_STRING:   StrLCopy(Dest,Src,iField.NativeSize);
      FIELD_TYPE_DATE,
      FIELD_TYPE_NEWDATE:  begin
                             try
                                TimeStamp.Date := LongInt(Src^);
                                TimeStamp.Time := 0;
                                TDateTime(Dest^) := TimeStampToDateTime(TimeStamp);
                             except
                                Result := 1;
                             end;
                           end;
      FIELD_TYPE_TIME:     begin
                             try
                               TimeStamp.Time := LongInt(Src^);
                               TimeStamp.Date := DateDelta;
                               TDateTime(Dest^) := TimeStampToDateTime(TimeStamp);
                             except
                               Result := 1;
                             end;
                           end;
      FIELD_TYPE_TIMESTAMP,
      FIELD_TYPE_DATETIME: begin
                              try
                                TDateTime(Dest^):= TimeStampToDateTime(MSecsToTimeStamp(Double(Src^)));
                              except
                                Result:=1;
                              end;
                           end;
      FIELD_TYPE_FLOAT,
      FIELD_TYPE_DOUBLE:  Double(Dest^) := Double(Src^);
      FIELD_TYPE_DECIMAL: Double(Dest^) := Double(Src^);
      FIELD_TYPE_NEWDECIMAL: Double(Dest^) := Double(Src^); //:CN 04/05/2005
      FIELD_TYPE_ENUM:    begin
                             if iField.NativeSize = 2{1} then
                                SmallInt(Dest^) := Byte(Src^) else
                                StrLCopy(Dest,Src,iField.NativeSize);
                          end;
  else
      Result := 1;
  end;
  If Result = 1 then
  begin
    ZeroMemory(Dest, iField.FieldLength);
    Result := 0;
  end;
end;

Procedure mySQLException(mySQL : TNativeConnect);
begin
  Raise EmySQLException.Create(mySQL);
end;

Procedure mySQLExceptionMsg(mySQL : TNativeConnect; Const ErrorMsg : String );
begin
  Raise EmySQLException.CreateMsg(mySQL, ErrorMsg );
end;

function BDETOMySQLStr(Field : TMySQLField): String;
var
  isAutoInc: Boolean;
begin
    Result :='';
    isAutoInc := false;
    case Field.FieldType of
      fldZString  : Result := Format('`%s` CHAR(%s)',[Field.FieldName,IntToStr(Field.FieldUnits1)]);
      fldDATE     : Result := Format('`%s` DATE',[Field.FieldName]);
      fldBLOB     : begin
                       if Field.FieldSubType = fldstMEMO then
                          Result := Format('`%s` BLOB',[Field.FieldName]) else
                          Result := Format('`%s` TEXT',[Field.FieldName]);
                    end;
      fldBOOL     : Result := Format('`%s` ENUM(''Y'',''N'')',[Field.FieldName]);
      fldINT16    : Result := Format('`%s` SMALLINT',[Field.FieldName]);
      fldINT32    : begin
                       if Field.FieldSubType = fldstAUTOINC then
                          isAutoInc := True;
                       Result := Format('`%s` INTEGER',[Field.FieldName]);
                    end;
      fldFLOAT    : Result := Format('`%s` FLOAT(%s,%s)',[Field.FieldName,IntToStr(Field.FieldUnits1),IntToStr(Field.FieldUnits2)]);
      fldBCD      : Result := Format('`%s` DECIMAL(%s,%s)',[Field.FieldName,IntToStr(Field.FieldUnits1),IntToStr(Field.FieldUnits2)]);
      fldTIME     : Result := Format('`%s` TIME',[Field.FieldName]);
      fldTIMESTAMP: Result := Format('`%s` DATETIME',[Field.FieldName]);
      fldUINT16   : Result := Format('`%s` SMALLINT UNSIGNED',[Field.FieldName]);
      fldUINT32   : Result := Format('`%s` INTEGER UNSIGNED',[Field.FieldName]);
      fldINT64    : Result := Format('`%s` BIGINT',[Field.FieldName]);
    end;
    if Field.ValCheck.bRequired then
       Result := Result+' NOT NULL' else
       Result := Result+' NULL';
    if isAutoInc then Result := Result+' AUTO_INCREMENT';
end;

function BDETOMySQLIdxStr(Index : TmySQLIndex;Flds : TMySQLFields): String;

function GetFieldList:String;
var
  I : Integer;
  S : String;
begin
  S :='';
  for I :=0 to Index.FldsInKey-1 do
  begin
     S := S+ Flds.Field[Index.Description.aiKeyFld[I]].FieldName;
     if I < Index.FldsInKey-1 then S := S+',';
  end;
  Result := S;
end;

begin
    result := '';
    if Index.Primary then
       Result := Format('PRIMARY KEY (%s)',[GetFieldList]) else
       if Index.Unique then
          Result := Format('UNIQUE INDEX `%s` (%s)',[Index.IndexName,GetFieldList]) else
          Result := Format('INDEX `%s` (%s)',[Index.IndexName,GetFieldList]);
end;

function SQLCreateIdxStr(Index : TmySQLIndex;TableName : String;Flds : TMySQLFields): String;

function GetFieldList:String;
var
  I : Integer;
  S : String;
begin
  S :='';
  for I :=0 to Index.FldsInKey-1 do
  begin
     S := S+ Flds.Field[Index.Description.aiKeyFld[I]].FieldName;
     if I < Index.FldsInKey-1 then S := S+',';
  end;
  Result := S;
end;

begin
    result := '';
    if Index.Unique then
       Result := Format('CREATE UNIQUE INDEX `%s` ON %s (%s)',[Index.IndexName,TableName,GetFieldList]) else
       Result := Format('CREATE INDEX %s ON `%s` (%s)',[Index.IndexName,TableName,GetFieldList]);
end;

{******************************************************************************}
{                            EmySQLError                                        *}
{******************************************************************************}
Constructor EmySQLException.CreateBDE(ECode : Word);
begin
  FBDEErrorCode := ECode;
  FBDE := True;
  Inherited Create('');
end;

Constructor EmySQLException.CreateBDEMsg(ECode : Word; Const EMessage : ShortString);
begin
  FmySQLErrorMsg  := EMessage;
  CreateBDE(ECode);
end;

Constructor EmySQLException.Create(mySQL : TNativeConnect);
begin
  FmySQL := mySQL;
  FmySQLErrorCode := mySQL.GetErrorCode;
  FmySQLErrorMsg  := mySQL.GetErrorText;
  if FmySQLErrorCode > 0 then FBDEERRORCode := DBIERR_INVALIDPARAM;
  Inherited Create(FmySQLErrorMsg);
end;

Constructor EmySQLException.CreateMsg(mySQL : TNativeConnect; Const ErrorMsg : String );
begin
  Create(mySQL);
  FmySQLErrorMsg := ErrorMsg;
  FBDEERRORCode :=1001;
end;

Function EmySQLException.GetNativeErrorMsg : String;
begin
  Result := FmySQLErrorMsg;
end;

{******************************************************************************}
{                            TNativeConnect                                   *}
{******************************************************************************}
Constructor TNativeConnect.Create(ConnOptions : TConnectOptions);
begin
  Inherited Create;
  Tables    := TContainer.Create;
  FLoggin  := False;
  FOptions := ConnOptions;
  Handle:=TMysqlClient.Create;
end;

Destructor TNativeConnect.Destroy;
begin
  Tables.Free;
  InternalDisconnect;
  Inherited Destroy;
end;

procedure TNativeConnect.ProcessDBParams(Params : TStrings);
begin
    DBOptions.User :=Params.Values['UID'];
    DBOptions.Password := Params.Values['PWD'];
    DBOptions.DatabaseName := Params.Values['DatabaseName'];
    DBOptions.Port :=  StrToInt(Params.Values['Port']);
    DBOptions.Host := Params.Values['Host'];
    if DBOptions.Host = '' then
       DBOptions.Host := 'localhost';
    if Params.Values['TIMEOUT'] = '' then
       DBOptions.TimeOut := 30 else
       DBOptions.TimeOut := StrToInt(Params.Values['TIMEOUT']);
end;

Procedure TNativeConnect.InternalConnect;
var
	Opt : Integer;
begin
  if not FLoggIn then
	 begin
	  Handle.ConnectTimeout := DBOptions.Timeout;
	  Handle.UseSSL := coSSL in FOptions;
	  Handle.SSLKey := SSLKey;
	  Handle.SSLCert := SSLCert;
	  Opt := 0;
     if coSSL in FOptions then
        Opt := Opt or CLIENT_SSL;
     if coCompress in FOptions then
        Opt := Opt or CLIENT_COMPRESS;
     if coFoundRows in FOptions then
        Opt := Opt or CLIENT_FOUND_ROWS;
     if coIgnoreSpaces in FOptions then
        Opt := Opt or CLIENT_IGNORE_SPACE;
     if coInteractive in FOptions then
        Opt := Opt or CLIENT_INTERACTIVE;
     if coNoSchema in FOptions then
        Opt := Opt or CLIENT_NO_SCHEMA;
     if coODBC in FOptions then
        Opt := Opt or CLIENT_ODBC;
     if Handle.UseSSL then
     begin
        if not LoadSSLLib then
           raise EmySQLException.CreateMsg(self,'Error load SSL Library');
	  end;

	  Opt := Opt or CLIENT_MULTI_STATEMENTS;
	  Opt := Opt or CLIENT_MULTI_RESULTS;

	  Handle.connect(DBOptions.Host,DBOptions.User, DBOptions.Password, DBOptions.DatabaseName,
						  DBOptions.Port, '', true, Opt);
	  MonitorHook.DBConnect(Self, (GetErrorCode = 0));
     CheckResult;
     FLoggIn := True;
     ServerVersion := GetVerAsInt(Handle);
  end;
end;

Procedure TNativeConnect.InternalDisconnect;
begin
  if FLoggin then
  begin
     FreeAndNil(FHandle);
     FLoggin := False;
     MonitorHook.DBDisconnect(Self);
  end;
end;

Function TNativeConnect.GetErrorCode: Word;
begin
   Result := Handle.LastErrorNo;
end;

Function TNativeConnect.GetErrorText: String;
begin
  result:= Handle.LastError;
end;

Function TNativeConnect.Success: Boolean;
begin
   Result:= Handle.LastErrorNo = 0;
end;

function TNativeConnect.GetClientInfo: string;
begin
   Result := MYSQL_SERVER_VERSION;
end;

function TNativeConnect.GetServerStat: string;
begin
   Result := Handle.stat;
end;

function TNativeConnect.GetHostInfo: string;
begin
  Result := Handle.Info;
end;

function TNativeConnect.GetProtoInfo: Cardinal;
begin
  Result := Handle.ProtocolVersion;
end;

function TNativeConnect.GetServerInfo: string;
begin
  Result := Handle.ServerVersion;
end;

procedure TNativeConnect.Kill(PID: Integer);
begin
   Handle.kill(PID);
   CheckResult;
end;

procedure TNativeConnect.SelectDB(DBName : PChar);
begin
   Handle.select_db(DBName);
   CheckResult;
end;

function TNativeConnect.Ping : integer;
begin
  Result := Integer(Handle.ping);
end;

function TNativeConnect.Shutdown: integer;
begin
  Result := Integer(Handle.shutdown);
end;

Procedure TNativeConnect.CheckResult;
begin
   if GetErrorCode <> 0 then
    raise EmySQLException.CreateMsg(self,GetErrorText);
end;

Procedure TNativeConnect.TableList(pszWild: PChar; Views: Boolean; List: TStrings);
var
   I : LongInt;
   A : Boolean;
   Stmt : TMysqlResult;
   SQL : string;
begin
  InternalConnect;
  List.Clear;
  SQL := 'SHOW TABLES';
  if (pszWild <> nil) then
     SQL := SQL + ' LIKE ''' + string(pszWild) + '''';
  Stmt := FHandle.query(SQL,True,A);
  if A then
  begin
     if Assigned(Stmt) then
     begin
        For I := 1 to Stmt.RowsCount do
        begin
           if ServerVersion = 50001 then
           begin
              if SameText(Stmt.FieldValue(1), 'VIEW') then
              begin
                 if Views then
                    List.Add(Stmt.FieldValue(0));
              end else
                 List.Add(Stmt.FieldValue(0));
           end else
              List.Add(Stmt.FieldValue(0));
           Stmt.Next;
        end;
     end;
  end else CheckResult;
  if Stmt <> nil then
     Stmt.Free;
end;

procedure TNativeConnect.DatabaseList(pszWild : PChar; List :TStrings);
var
   I : LongInt;
   A : Boolean;
   Stmt : TMysqlResult;
   SQL : string;
begin
  InternalConnect;
  List.Clear;
  SQL := 'SHOW DATABASES';
  if (pszWild <> nil) then
     SQL := SQL + ' LIKE ''' + string(pszWild) + '''';
  Stmt := FHandle.query(SQL,True,A);
  if A then
  begin
     if Assigned(Stmt) then
     begin
        For I := 1 to Stmt.RowsCount do
        begin
            List.Add(Stmt.FieldValue(0));
            Stmt.Next;
        end;
     end;
  end else CheckResult;
  if Stmt <> nil then
     Stmt.Free;
end;

Procedure TNativeConnect.OpenTable(pszTableName: PChar;pszIndexName: PChar;iIndexId: Word;
                                   eOpenMode: DBIOpenMode;eShareMode: DBIShareMode;var hCursor: hDBICur; Offset,Limit : integer);
begin
  InternalConnect;
  hCursor := hDBICur(TNativeDataSet.Create(Self, Tables,pszTableName, pszIndexName, iIndexId,Offset,Limit));
  TNativeDataSet(hCursor).OpenTable;
end;

Procedure TNativeConnect.QueryAlloc(var hStmt: hDBIStmt);
begin
    hStmt := hDBIStmt(TNativeDataSet.Create(Self, nil,nil, nil, 0,0,-1));
end;

Procedure TNativeConnect.QueryPrepare(var hStmt: hDBIStmt;Query : PChar);
begin
   TNativeDataSet(hStmt).SQLQuery := Query;
   TNativeDataSet(hStmt).isQuery := True;
   MonitorHook.SQLPrepare(TNativeDataSet(hStmt));
end;

procedure TNativeConnect.BeginTran(eXIL: eXILType; var hXact: hDBIXact);
var
   a : boolean;
   res : TMysqlResult;
begin
  if FTransState <> xsActive then
  begin
    hXact := hDBIXact(Self);
    FTransState := xsActive;
    FTransLevel := eXIL;
    res:=FHandle.query('BEGIN',false,a);
    if res <> nil then
       res.free;
    MonitorHook.TRStart(Self, a);   // ptook
  end
end;

procedure TNativeConnect.EndTran(hXact : hDBIXact; eEnd : eXEnd);
var
   a : boolean;
   res : TMysqlResult;
begin
  if eEnd = xendCommit then
  begin
     res:=FHandle.query('COMMIT',false,a);
     MonitorHook.TRCommit(Self, a);     // ptook
  end else
  begin
     res:=FHandle.query('ROLLBACK',false,a);
     MonitorHook.TRRollback(Self, a);   // ptook
  end;
  if res <> nil then
     res.free;
  FTransState := xsInactive;
end;

procedure TNativeConnect.GetTranInfo(hXact : hDBIXact; pxInfo : pXInfo);
begin
  ZeroMemory(pxInfo, Sizeof(pxInfo^));
  pxInfo^.eXState := FTransState;
  pxInfo^.eXIL    := FTransLevel;
end;

Procedure TNativeConnect.QExecDirect(eQryLang : DBIQryLang; pszQuery : PChar; phCur: phDBICur; var AffectedRows : LongInt);
var
  A : Boolean;
begin
  if not FLoggin then  Exit;
  Handle.query(pszQuery,True,a);
  MonitorHook.SQLExecute(Self, pszQuery, a);      // ptook
  if a then
     AffectedRows := Handle.AffectedRows;
  CheckResult;
end;

Procedure TNativeConnect.TableLoaded(pszTableName : PChar; Var T : TObject);
var
  i : Integer;
begin
   If pszTableName = nil then
      Raise EMySQLException.CreateBDE(DBIERR_INVALIDPARAM);
   if not (Tables.Count > 0) then
      Raise EMySQLException.CreateBDE(DBIERR_INVALIDPARAM);
   for i := 0 to Tables.Count-1 do
   begin
      T := Tables.Items[i];
      if (T <> nil) and (StrIComp(pszTableName, TNativeDataSet(T).TableName) = 0) then
         Exit;
   end;
   Raise EMySQLException.CreateBDEMsg(DBIERR_NOSUCHTABLE, pszTableName);
end;

Procedure TNativeConnect.GetCursorForTable(pszTableName: PChar; var hCursor: hDBICur);
var
  SearchTmp : DBIPATH;
begin
  StrLCopy( @SearchTmp, pszTableName, SizeOf(SearchTmp)-1);
  TableLoaded(@SearchTmp, TObject(hCursor));
end;

Procedure TNativeConnect.OpenFieldList(pszTableName: PChar;pszDriverType: PChar;bPhyTypes: Bool;var hCur: hDBICur);
var
  P : TNativeDataSet;

Procedure ProcessTable;
var
    Items : Word;
    Descs : Pointer;
begin
    Items := P.FieldCount;
    if Items > 0 then
    begin
      Descs := AllocMem(Items * Sizeof(FLDDesc));
      Try
        P.GetFieldDescs(pFLDDesc(Descs));
        hCur := hDBICur(TFieldList.Create(Self,Descs,Items));
      Finally
        FreeMem(Descs, Items * Sizeof(FLDDesc));
      end;
    end;
end;

begin
    hCur := nil;
    Try
      GetCursorForTable(pszTableName, hDBICur(P));
      ProcessTable;
    Except
      on E:EMySQLException do
      begin
         OpenTable(pszTableName, nil, 0, dbiREADONLY, dbiOPENSHARED,hDBICur(P),0,0{-1});
         ProcessTable;
         P.CloseTable;
         P.Free;
         P := nil;
      end;
    end;
    if hCur = nil then
       hCur := hDBICur(TFieldList.Create(Self, nil, 0));
end;

Procedure TNativeConnect.OpenIndexList(pszTableName: PChar;pszDriverType: PChar;var hCur: hDBICur);
var
  P     : hDBICur;
  Ind   : TIndexList;

  Procedure ProcessTable;
  var
    Items : Word;
    Descs : Pointer;
  begin
    Descs := nil;
    Items := TNativeDataset(P).IndexCount;
    Try
      if Items > 0 then
      begin
        Descs := AllocMem(Items * Sizeof(idxDesc));
        TNativeDataSet(P).GetIndexDescs(PIDXDesc(Descs));
      end else
        Descs := nil;
      Ind  := TIndexList.Create(Self,Descs, Items);
      hCur := hDBICur(Ind);
    Finally
      if Descs<>nil then
         FreeMem(Descs, Items * Sizeof(idxDesc));
    end;
  end;

  Procedure OpenAndProcessTable;
  begin
    OpenTable(pszTableName, NIL,0, dbiREADONLY, dbiOPENSHARED, P,0,0{-1});
    Try
      ProcessTable;
      TNativeDataSet(P).CloseTable;
    Finally
      TNativeDataSet(P).Free;
    end;
  end;

begin
  hCur := nil;
  Try
    GetCursorForTable(pszTableName, hDBICur(P));
    if TNativeDataSet(P).RecordState <> tsClosed then
       ProcessTable else
      OpenAndProcessTable;
  Except
    On E:EmySQLException do
       OpenAndProcessTable;
  end;
end;

function TNativeConnect.GetCharSet: TConvertChar;
var
   I : LongInt;
   A : Boolean;
   Stmt : TMysqlResult;
   S,S1 : String;
   sVar : String;
begin
  Stmt := FHandle.query('SHOW VARIABLES',True,A);
  if A then
  begin
     if Assigned(Stmt) then
     begin
        //Получаем character set бд
        For I := 1 to Stmt.RowsCount do
        begin
            if ServerVersion < 40101 then     //v 2.3.1 VIC
               sVar := 'character_set' else
               sVar := 'character_set_database';
            if lowercase(Stmt.FieldValue(0)) = sVar then
            begin
               S := Stmt.FieldValue(1);
               Break;
            end;
            Stmt.Next;
        end;
        //Получаем character set сервера
        if ServerVersion >= 40101 then     //v 2.3.1 VIC
        begin
            Stmt.First;
            For I := 1 to Stmt.RowsCount do
            begin
              sVar := 'character_set_server';
              if lowercase(Stmt.FieldValue(0)) = sVar then
              begin
                 S1 := Stmt.FieldValue(1);
                 Break;
              end;
              Stmt.Next;
            end;
            if not SameText(S,S1) then
               FHandle.query(Format('SET CHARACTER SET %s',[S]),True,A);
        end;
     end;
  end else CheckResult;
  if Stmt <> nil then
     Stmt.Free;
  result := GetCPfromName(S);
end;

procedure TNativeConnect.EmptyTable(hCursor : hDBICur; pszTableName : PChar);
var
  isNotOpen : Boolean;
begin
  isNotOpen := not Assigned(hCursor);
  if isNotOpen then
    OpenTable(pszTableName,nil,0,dbiREADWRITE,dbiOPENEXCL,hCursor,0,-1);
  Try
    TNativeDataSet(hCursor).EmptyTable;
  Finally
    If isNotOpen then
      TNativeDataSet(hCursor).Free;
  end;
end;

procedure TNativeConnect.TableExists(pszTableName : PChar);
var
   List : TStrings;
   I : Integer;
   Found : Boolean;
begin
   Found := False;
   List := TStringList.Create;
   try
     TableList(nil,True,List); //NEW :VIC 2.11.2004
     for I:=0 to List.Count-1 do
     begin
         Found := (StrIComp(pszTableName, PChar(List[I]))=0);
         if Found then break;
     end;
   finally
     List.Free;
   end;
   if not Found then
      Raise EMySQLException.CreateBDEMsg(DBIERR_NOSUCHTABLE, pszTableName);
end;

Procedure TNativeConnect.CreateTable(bOverWrite: Bool; var crTblDsc: CRTblDesc);
var
   a : boolean;

function CreateSQLForCreateTable:String;
var
  Fld : String;
  SQLList : TStrings;
  I : Integer;
  VCHK : pVCHKDesc;
  MySQLFlds : TMySQLFields;
  MySQLIdxs : TMySQLIndexes;
begin
  MySQLFlds := TmySQLFields.Create(nil);
  MySQLIdxs := TmySQLIndexes.Create(nil);
  SQLList := TStringList.Create;
  for I := 1 to crTblDsc.iFldCount do
  begin
     if (crTblDsc.iValChkCount > 0) and (crTblDsc.iValChkCount >= I) then
      begin
         VCHK := crTblDsc.pvchkDesc;
         if VCHK.iFldNum <> I then VCHK := nil;
      end else VCHK := nil;
      TmySQLField.CreateField(MySQLFlds,crTblDsc.pfldDesc,VCHK, i, 0, 0,'');
      Inc(crTblDsc.pfldDesc);
      if crTblDsc.iValChkCount > 0 then
         if crTblDsc.iValChkCount > I then
            Inc(CrTblDsc.pvchkDesc);
  end;
  for I := 1 to crTblDsc.iIdxCount do
  begin
      TmySQLIndex.CreateIndex(MySQLIdxs,crTblDsc.pidxDesc);
      Inc(crTblDsc.pidxDesc);
  end;
  try
    Result := Format('CREATE TABLE `%s` ( ',[crTblDsc.szTblName]);
    for I := 1 to MySQLFlds.Count do
    begin
       Fld := BDETOMySQLStr(MySQLFlds[I]);
       SQLList.Add(Fld);
    end;
    for I := 1 to MySQLIdxs.Count do
    begin
       Fld := BDETOMySQLIdxStr(MySQLIdxs[I],MySQLFlds);
       SQLList.Add(Fld);
    end;
    for I:= 0 to SQLList.Count-1 do
    begin
        Result := Result+SQLList[I];
        if I < SQLList.Count-1 then Result := Result+', ';
    end;
    Result := Result+')';
  finally
     SQLList.Free;
  end;
  MySQLIdxs.Free;
  MySQLFlds.Free;
end;

begin
   FHandle.query(CreateSQLForCreateTable,false,a);
   CheckResult;
end;

Procedure TNativeConnect.AddIndex(hCursor: hDBICur; pszTableName: PChar; pszDriverType: PChar; var IdxDesc: IDXDesc; pszKeyviolName: PChar);
var
  NDS : TNativeDataSet;
begin
  If Assigned(hCursor) then
    NDS := TNativeDataSet(hCursor) else
    OpenTable(pszTableName,nil,IdxDesc.iIndexId,dbiREADWRITE,dbiOPENEXCL,hDBICur(NDS),0,-1);
  Try
    NDS.AddIndex(idxDesc,pszKeyViolName);
  Finally
    If not Assigned(hCursor) then NDS.Free;
  end;
end;

Procedure TNativeConnect.DeleteIndex(hCursor: hDBICur; pszTableName: PChar; pszDriverType: PChar; pszIndexName: PChar; pszIndexTagName: PChar; iIndexId: Word);
var
  NDS : TNativeDataSet;
begin
  If Assigned(hCursor) then
    NDS := TNativeDataSet(hCursor) else
    OpenTable(pszTableName, pszIndexName, iIndexId,dbiREADWRITE,dbiOPENEXCL,hDBICur(NDS),0,-1);
  Try
    NDS.DeleteIndex(pszIndexName, pszIndexTagName, iIndexID);
  Finally
    If not Assigned(hCursor) then NDS.Free;
  end;
end;

function TNativeConnect.GetMultiThreaded: boolean;
begin
  result:=FHandle.MultiThreaded;
end;

procedure TNativeConnect.SetMultiThreaded(const Value: boolean);
begin
  FHandle.MultiThreaded:=Value;
end;


//////////////////////////////////////////////////////////
//Constructor : TmySQLField.CreateField
//Description : constructor CreateNewField
//////////////////////////////////////////////////////////
//Input       : Owner: TCollection
//              P: pFldDesc
//              FNum: Word
//              LType: Word
//              LSize: Word
//////////////////////////////////////////////////////////
Constructor TmySQLField.CreateField(Owner : TCollection; P : pFldDesc; P1 : pVCHKDesc; FNum, LType: Word; LSize : LongInt; enum_val : string);
var
  K : Integer;
  S : String;
begin
  Create(Owner);
  Move(P^, FDesc, SizeOf(FldDesc));
  if P1 <> nil then
     Move(P1^,FValCheck,SizeOf(VCHKDesc));
  FieldNumber := FNum;
  NativeType   := LType;
  NativeSize   := LSize;
  S := Enum_val;
  k := 1;
  while k <= Length(S) do
    if S[k] in [{',',}''''] then
       delete(S,K,1) else inc(K);
  Enum_Value   := S;
end;

Function TmySQLField.GetFieldName : String;
begin
  Result := StrPas(FDesc.szName);
end;

Procedure TmySQLField.SetFieldName(Const Value : String);
begin
  StrPCopy(@FDesc.szName, Copy(Value,1,SizeOf(FDesc.szName)-1));
end;

Procedure TmySQLField.SetBuffer(PRecord : Pointer);
begin
  FBuffer := PRecord;
  if FBuffer <> nil then
  begin
    FData := FBuffer;
    Inc(PChar(FData), FDesc.iOffset);
    If FDesc.INullOffset > 0 then
    begin
      FStatus := FBuffer;
      Inc(PChar(FStatus), FDesc.iNullOffset);
    end else
      FStatus := NIL;
  end else
  begin
    FData := nil;
    FStatus := nil;
  end;
end;

Function TmySQLField.GetNull : Boolean;
begin
  If FStatus <> nil then Result := TFieldStatus(FStatus^).isNULL = -1 else  Result := FALSE;
end;

Procedure TmySQLField.SetNull( Flag : Boolean );
Const
  VALUES : Array[ Boolean ] of SmallInt = ( 0, -1 );
begin
  If FStatus <> nil then  FStatus^.isNULL := VALUES[ Flag ];
end;

Function TmySQLField.GetChanged : Boolean;
begin
  if FStatus <> nil then  Result := TFieldStatus(FStatus^).Changed else Result := TRUE;
end;

Procedure TmySQLField.SetChanged(Flag : Boolean);
begin
  If FStatus <> nil then TFieldStatus(FStatus^).Changed := Flag;
end;

Function TmySQLField.GetLocalType : Word;
begin
  Result := FDesc.iUnused[0];
end;

Procedure TmySQLField.SetLocalType(S : Word);
begin
  FDesc.iUnused[0] := S;
end;

function TmySQLField.FieldValue: PChar;
begin
   Result := PChar(FData)+FieldNumber-1;
end;

Constructor TmySQLFields.Create(Table : TNativeDataSet);
begin
  Inherited Create(TmySQLField);
  FTable := Table;
end;


Function TmySQLFields.GetField(Index : Integer) : TmySQLField;
var
  LocType : Word;
  LocSize : LongInt;
  Desc    : FldDesc;
  ValCheck : VCHKDesc;
  eval    : string;
begin
  if ( Count >= Index ) and ( Index > 0 ) then
    Result := TmySQLField(Items[Index-1]) else
  begin
    if not ((Index > 0) and (FTable <> nil)) then raise EmySQLException.CreateBDE(DBIERR_INVALIDRECSTRUCT);
    FTable.GetNativeDesc(Index, @Desc,@ValCheck, LocType, LocSize, eval);
    Result := TmySQLField.CreateField(Self, @Desc, @ValCheck, Index, LocType, LocSize,eval);
  end;
end;

Procedure TmySQLFields.SetFields(PRecord : Pointer);
var
  i : Word;
begin
  For i := 1 to Count do
  begin
    With Field[i] do
    begin
      Buffer     := PRecord;
      FieldChanged := FALSE;
      FieldNull       := TRUE;
    end;
  end;
end;

Function TmySQLFields.FieldNumberFromName(SearchName : PChar) : Integer;
var
  I   : Integer;
begin
  Result := 0;
  For i := 1 to Count do
  begin
    With GetField( i ) do
    begin
      if (StrIComp(SearchName, PChar(FieldName)) = 0) then
      begin
        Result := Integer(FieldNumber);
        Exit;
      end;
    end;
  end;
end;

//////////////////////////////////////////////////////////
//Constructor : TmySQLIndex.CreateIndex
//Description : constructor CreateIndex
//////////////////////////////////////////////////////////
//Input       : Owner: TCollection
//              P: pIDXDesc
//////////////////////////////////////////////////////////
Constructor TmySQLIndex.CreateIndex(Owner : TCollection; P : pIDXDesc);
begin
  Create(Owner);
  Move(P^, FDesc, SizeOf(IDXDesc));
end;

Function TmySQLIndex.GetIndexName : String;
begin
  Result := StrPas(FDesc.szName);
end;

Procedure TmySQLIndex.SetIndexName(Const Value : String);
begin
  StrPCopy(@FDesc.szName, Copy(Value,1,SizeOf(FDesc.szName)-1));
end;

Constructor TmySQLIndexes.Create(Table : TNativeDataSet);
begin
  Inherited Create(TmySQLIndex);
  FTable := Table;
end;

Function TmySQLIndexes.GetIndex(Index : Integer) : TmySQLIndex;
begin
  Result := nil;
  if ( Count >= Index ) and ( Index > 0 ) then Result := TmySQLIndex(Items[Index-1]);
end;

function TmySQLIndexes.FindByName(Name :String): TmySQLIndex;
var
  I : Integer;
begin
  Result := nil;
  for i := 0 to Count-1 do
  begin
     if (CompareText(TmySQLIndex(Items[I]).IndexName, Name) = 0) then
     begin
        Result := TmySQLIndex(Items[I]);
        Exit;
     end;
  end;
end;

Procedure TmySQLIndexes.SetIndex(Name,Fields : String;aPrimary,aUnique,aDesc : Boolean);
var
  Item : TmySQLIndex;
  I,K : Integer;
  FldLen : Word;
begin
  if aPrimary then
  begin
     Item := FindByName('');
     if not Assigned(Item) then
     begin
        Item := TmySQLIndex(Add);
        Item.IndexNumber := Item.Index+1;
     end;
  end else
  begin
     Item := FindByName(Name);
     if not Assigned(Item) then
     begin
        Item := TmySQLIndex(Add);
        Item.IndexNumber := Item.Index+1;
     end;
  end;
  if aPrimary then
     Item.IndexName := '' else
     Item.IndexName := Name;
  Item.Primary := aPrimary;
  Item.Unique := aUnique;
  Item.Descending := aDesc;
  Item.FDesc.bMaintained := True;
  I :=FieldNumberFromName(PChar(Fields));
  FldLen := FTable.FFieldDescs.GetField(I).FieldLength;
  Item.FldsInKey := Item.FldsInKey+1;
  Item.BlockSize := Item.BlockSize+FldLen;
  Item.KeyLen := Item.BlockSize+Item.FldsInKey;
  K :=Item.FldsInKey;
  Item.FDesc.aiKeyFld[K-1] := I;
end;

Function TmySQLIndexes.FieldNumberFromName( SearchName : PChar ) : Integer;
var
  I   : Integer;
begin
  Result := 0;
  if FTable.FFieldDescs.Count = 0 then FTable.InitFieldDescs;
  For i := 1 to FTable.FFieldDescs.Count do
  begin
    With FTable.FFieldDescs.GetField(i) do
    begin
      if (StrIComp(SearchName, PChar(FieldName))= 0) then
      begin
        Result := Integer(FieldNumber);
        Exit;
      end;
    end;
  end;
end;

//////////////////////////////////////////////////////////
//Description : TmySQLFilter impementation
//////////////////////////////////////////////////////////
Constructor TmySQLFilter.Create(Owner : TNativeDataSet; AClientData : Longint; Exp : pCANExpr;pfFilt : pfGENFilter);
begin
  Inherited Create;
  FDataset := Owner;
  FClientData  := AClientData;
  if Assigned(Exp) then
  begin
    FExprSize := CANExpr(Exp^).iTotalSize;
    If FExprSize > 0 then
    begin
      GetMem(FExpression, FExprSize);
      If Assigned(FExpression) then Move(Exp^, FExpression^, FExprSize);
    end;
  end;
  FPfFilter:= pfFilt;
  FActive:= FALSE;
end;

Destructor TmySQLFilter.Destroy;
begin
  If (FExprSize > 0) and Assigned(FExpression) then FreeMem(FExpression, FExprSize);
  Inherited Destroy;
end;

Function TmySQLFilter.GetFilterResult(PRecord : Pointer) : Variant;
var
   I : Integer;
begin
  if FActive then
  begin
     FRecBuff := PRecord;
     if Assigned(FpfFilter) then
     begin
        i := 0;
        try
          i := FpfFilter(FClientData, FRecBuff, Longint(0));
        finally
          result := i <> 0;
        end;
     end else
     begin
        if Assigned(FExpression) then
        begin
           Try
             Result := CalcExpression(GetNodeByOffset(NodeStart));
             if Result = Null then Result := False;
           except
             Result := FALSE;
           end;
        end;
     end;
  end else Result := False;
end;

function TmySQLFilter.GetLiteralPtr(AOffset: Word):Pointer;
var
  i : word;
begin
  i := CANExpr(FExpression^).iLiteralStart + AOffset;
  Result := @MemPtr(FExpression)^[i];
end;

Function TmySQLFilter.GetNodeStart : Integer;
begin
  Result := FExpression.iNodeStart;
end;

Function TmySQLFilter.GetNodeByOffset(AOffSet : Integer) : PCanNode;
begin
    Result := pCanNode(Integer(FExpression)+AOffset);
end;

Function TmySQLFilter.CalcExpression(ANode : PCanNode) : Variant;
Var
  FldType : TFldType;
begin
  Case pCanHdr(ANode).nodeClass Of
    MySQLTypes.nodeUNARY    : Result := UnaryNode(pCANUnary(ANode));
    MySQLTypes.nodeBINARY   : Result := BinaryNode(pCANBinary(ANode));
    MySQLTypes.nodeCOMPARE  : Result := CompareNode(pCANCompare(ANode));
    MySQLTypes.nodeFIELD    : Result := FieldNode(pCANField(ANode));
    MySQLTypes.nodeCONST    : Result := PerformCanConst(PCANConst(ANode),GetLiteralPtr(PCANConst(ANode).iOffset){Pointer(Integer(FExpression) + LiteralStart)},FldType);
    MySQLTypes.nodeLISTELEM : Result := ListOfValues(pCANListElem(ANode));
  else
    result := Null;
  End;
end;

Function TMySQLFilter.ListOfValues(ANode : pCANListElem) : Variant;
Var
  I          : Integer;
  CurNode    : pCANListElem;
begin
  CurNode := ANode;
  I := 0;
  While True Do
  begin
    Inc(I);
    If CurNode^.iNextOffset = 0 Then break;
    CurNode := pCanListElem(GetNodeByOffset(NodeStart + CurNode^.iNextOffset));
  end;
  Result := varArrayCreate([1, I], varVariant);
  I := 1;
  While True Do
  begin
    Result[ I ] := CalcExpression(PCanNode(GetNodeByOffset(NodeStart + ANode^.iOffset)));
    If ANode^.iNextOffset = 0 Then break;
    ANode := pCanListElem(GetNodeByOffset(NodeStart + ANode^.iNextOffset));
    Inc(I);
  end;
end;

Function TmySQLFilter.PerformLikeCompare(Const Value, Mask : String; CaseSen : Boolean) : Boolean;
begin
   Result := SearchLike(Value,Mask,not CaseSen);
end;

Function TmySQLFilter.PerformInCompare(AOp1, AOp2 : Variant) : Boolean;
Var
  Save   : Variant;
  I, Top : Integer;
begin
  If varType(AOp1) = varArray then
  begin
    Save := AOp2;
    AOp2 := AOp1;
    AOp1 := Save;
  end;
  Result := True;
  Top := VarArrayHighBound(AOp2, 1);
  For I := VarArrayLowBound(AOp2, 1) to Top do
    If AOp1 = AOp2[I] then Exit;
  Result := False;
end;

Function TmySQLFilter.UnaryNode( ANode : PCANUnary ) : Variant;
begin
  With ANode^ Do Result := PerformCANOp(canOp, GetNodeValue(iOperand1), UnAssigned);
end;

function TmySQLFilter.BinaryNode(ANode : PCANBinary) : Variant;
begin
  With ANode^ Do  Result := PerformCANOp(canOp, GetNodeValue(iOperand1), GetNodeValue(iOperand2));
end;

Function TmySQLFilter.CompareNode(ANode : PCANCompare) : Variant;
Var
  Op1, Op2 : Variant;
begin
   Op1 := GetNodeValue(Anode^.iOperand1);
   Op2 := GetNodeValue(Anode^.iOperand2);
   If varIsNull(Op1) Or varIsEmpty(Op1) Then Op1 := '';
   If varIsNull(Op2) Or varIsEmpty(Op2) Then Op2 := '';
   if ANode.canOp = canLike then
      Result := PerformLikeCompare(Op1,Op2, ANode^.bCaseInsensitive) else
   begin
      Result := Search(Op1,Op2, (GetClientCP<>DBCharSet), Anode^.bCaseInsensitive, Anode^.iPartialLen);
      If Anode^.canOp = canNE Then  Result := Not Result;
   end;

end;

Function TmySQLFilter.FieldNode(ANode : pCANField) : Variant;
Var
  Field     : TmySQLField;
  blank     : bool;
  Dest      :  Array[0..255] of Char;
  TimeStamp : TTimeStamp;
  DateD     : Double;
begin
  Result := Null;
  Field := FDataset.Fields[ANode.iFieldNum];
  FDataSet.NativeToDelphi(Field,FrecBuff,@Dest,blank);
  if blank then Exit; // VIC
  case Field.FieldType of
    fldINT16: Result := PSmallInt(@Dest)^;
    fldUINT16:Result := PWord(@Dest)^;
    fldINT32: Result := PLongInt(@Dest)^;
    fldUINT32:Result := PLongInt(@Dest)^;
    fldFLOAT: Result := PDouble(@Dest)^;
    fldZSTRING: Result := uMyDMHelpers.EscapeStr(StrPas(@Dest));
    fldBOOL : Result := PWordBool(@Dest)^;
    fldDATE : begin
                 DWORD(TimeStamp.Date) := PDWORD(@Dest)^;
                 TimeStamp.Time := 0;
                 Result := SysUtils.Time+Trunc(TimeStampToDateTime(TimeStamp) + 1E-11);
              end;
    fldTIME : begin
                 DWORD(TimeStamp.Time) := PDWORD(@Dest)^;
                 TimeStamp.Date := 0;
                 Result := SysUtils.Date+TimeOf(TimeStampToDateTime(TimeStamp));
              end;
    fldTIMESTAMP : begin
                     DateD := PDouble(@Dest)^;
                     Result := TimeStampToDateTime(MSecsToTimeStamp(DateD));
                    end;
  else Result := NULL;
  end;
end;

Function TmySQLFilter.GetNodeValue(AOffSet : Integer) : Variant;
begin
  Result := CalcExpression(GetNodeByOffset(NodeStart + AOffset));
end;

Function TmySQLFilter.PerformCANOp(AOperator : CANOp; AOp1, AOp2 : Variant) : Variant;
begin
  Case AOperator of
    canNOTDEFINED : Result := Null;
    canISBLANK    : Result := VarIsNull(AOp1);
    canNOTBLANK   : Result := not VarIsNull(AOp1);
    canNOT        : Result := not AOp1;
    canEQ         : Result := AOp1 = AOp2;
    canNE         : Result := AOp1 <> AOp2;
    canGT         : Result := AOp1 > AOp2;
    canLT         : Result := AOp1 < AOp2;
    canGE         : Result := AOp1 >= AOp2;
    canLE         : Result := AOp1 <= AOp2;
    canAND        : Result := AOp1 and AOp2;
    canOR         : Result := AOp1 or AOp2;
    canMinus      : Result := -AOp1;
    canADD        : Result := AOp1+AOp2;
    canSUB        : Result := AOp1-AOp2;
    canMUL        : Result := AOp1*AOp2;
    canDIV        : Result := AOp1 /  AOp2;
    canMOD        : Result := AOp1 mod AOp2;
    canREM        : Result := AOp1 mod AOp2;
    canSUM        : Result := Null;
    canCONT       : Result := Null;
    canLike       : Result := PerformLikeCompare(AOp1,AOp2,True);
    canIN         : Result := PerformInCompare(AOp1,AOp2);
    canUPPER      : Result := AnsiUpperCase(AOp1);
    canLOWER      : Result := AnsiLowerCase(AOp1);
    canASSIGN     : Result := VarIsNull(AOp1);
    Else Result := Null;
  end;
end;

Function TmySQLFilter.PerformCanConst(ANode:PCANConst; ValuesStart : Pointer; Var FldType : TFldType) : Variant;

Function _PerformCanConst( ANode : PCANConst; ValuePtr : Pointer; Var FldType : TFldType) : Variant;
Var
  Offs      : Integer;
  TimeStamp : TTimeStamp;
  DateData  : Double;
  S:String;
begin
  With ANode^ Do
  begin
    Offs := Integer(ValuePtr);
    FldType := FT_UNK;
    Result := Null;
    Case iType Of
      fldZSTRING   : begin
                       S:=PChar(Offs);
                       Result := uMyDMHelpers.EscapeStr(S); 
                       FldType := FT_STRING;
                     end;
      fldDATE      : begin
                       DWORD( TimeStamp.Date ) := PDWORD( Offs )^;
                       TimeStamp.Time := 0;
                       Result := SysUtils.Time+ Trunc(TimeStampToDateTime(TimeStamp) + 1E-11);
                       FldType := FT_DATE;
                     end;
      fldBOOL      : begin
                       Result := PWordBool( Offs )^;
                       FldType := FT_BOOL;
                     end;

      fldINT16     : begin
                       Result := PSmallInt( Offs )^;
                       FldType := FT_INT;
                     end;
      fldINT32     : begin
                       Result := PInteger( Offs )^;
                       FldType := FT_INT;
                     end;
      fldFLOAT     : begin
                       Result := PDouble( Offs )^;
                       FldType := FT_FLOAT;
                     end;
      fldTIME      : begin
                       DWORD( TimeStamp.Time ) := PDWORD( Offs )^;
                       TimeStamp.Date := 0;
                       Result := SysUtils.Date+TimeOf(TimeStampToDateTime( TimeStamp ));
                       FldType := FT_TIME;
                     end;

      fldTIMESTAMP : begin
                       DateData := PDouble( Offs )^;
                       Result := TimeStampToDateTime( MSecsToTimeStamp( DateData ) );
                       FldType := FT_DATETIME;
                     end;
      fldUINT16    : begin
                       Result := PWord( Offs )^;
                       FldType := FT_INT;
                     end;
      fldUINT32    : begin
                       Result := PInteger( Offs )^;
                       FldType := FT_INT;
                     end;
    end;
  end;
end;
begin
  Result:=_PerformCanConst(ANode,ValuesStart,FldType);
end;

//function TmySQLFilter.TimeOf(const ADateTime: TDateTime): TDateTime;
//var
//  Hour, Min, Sec, MSec: Word;
//begin
//  DecodeTime(ADateTime, Hour, Min, Sec, MSec);
//  Result := EncodeTime(Hour, Min, Sec, MSec);
//end;


//////////////////////////////////////////////////////////
//Constructor : TNativeDataSet.Create
//Description : TNativeDataSet Object Constructor Create
//////////////////////////////////////////////////////////
//Input       : MySQL: TNativeConnect
//              Container: TContainer
//              Name: PChar
//              IndexName: PChar
//              Index: Word
//              Offset: Integer
//              Limit: Integer
//////////////////////////////////////////////////////////
Constructor TNativeDataSet.Create(mySQL : TNativeConnect; Container : TContainer; Name, IndexName : PChar; Index : Word;Offset,Limit : Integer);
begin
  Inherited Create;
  FContainer := Container;
  If FContainer <> nil then
     FContainer.Insert(Self);
  FOpenMode := omStore;
  FStatement := nil;
  FFilters    := TContainer.Create;
  If IndexName <> nil then StrLCopy(@FIndexName, IndexName,SizeOf(DBITBLNAME)-1);
  FFieldDescs := TmySQLFields.Create(Self);
  FIndexDescs := TmySQLIndexes.Create(Self);
  FKeyNumber               := 0;
  FPrimaryKeyNumber        := 0;
  AutoReExec     := True;
  FConnect := mySQL;
  FOpen := False;
  FRecSize:=-1;
  FLimit := Limit;
  FOffset := Offset;
  FLastInsertID     := 0;
  StandartClause := TStringList.Create;
  OrderClause := TStringList.Create;
  RangeClause := TStringList.Create;
  LimitClause := TStringList.Create;
  TableName  := Name;
  MasterCursor      := nil;
  isQuery := False;
end;

Destructor TNativeDataSet.Destroy;
begin
  MasterCursor      := nil;
  CloseTable;
  ClearIndexInfo;
  if StandartClause <> nil then
     StandartClause.Free;
  if OrderClause <> nil then
     OrderClause.Free;
  if RangeClause <> nil then
     RangeClause.Free;
  if limitClause <> nil then
     limitClause.Free;
  FIndexDescs.Free;
  FFieldDescs.Free;
  FFilters.Free;
  If FContainer <> nil then
     FContainer.Delete(Self);
  Inherited Destroy;
end;

//////////////////////////////////////////////////////////
//            PROTECTED METHODS                         //
//////////////////////////////////////////////////////////
Procedure TNativeDataSet.SetBufferAddress(P : Pointer);
begin
  FCurrentBuffer  := P;
end;

Procedure TNativeDataSet.SetInternalBuffer(Buffer : Pointer);
begin
  BufferAddress := Buffer;
  FCurrentBuffer := Buffer;
end;

Function TNativeDataSet.GetInternalBuffer : Pointer;
begin
  Result := FInternalBuffer;
end;

Procedure TNativeDataSet.SetCurrentBuffer(PRecord : Pointer);
begin
  FCurrentBuffer := PRecord;
end;

Function TNativeDataSet.GetCurrentBuffer : Pointer;
begin
  Result := FCurrentBuffer;
end;

function TNativeDataSet.FieldOffset(iField: Integer): Word;
var
   i: SmallInt;
begin
   Result:=0;
   If not ((iField>=1) or (iField<=FieldCount)) then Raise EmySQLException.CreateBDE(DBIERR_INVALIDPARAM);
   Dec(iField);
   Dec(iField);
   for i:=0 to iField do
   begin
     case FieldType(I) of
       FIELD_TYPE_TINY,
       FIELD_TYPE_SHORT: Inc(Result,SizeOf(SmallInt));
       FIELD_TYPE_LONG,
       FIELD_TYPE_INT24,
       FIELD_TYPE_YEAR: Inc(Result,SizeOf(LongInt));
       FIELD_TYPE_DATE,
		 FIELD_TYPE_TIME: Inc(Result,SizeOf(TDateTime));
       FIELD_TYPE_LONGLONG : Inc(Result,SizeOf(Int64));
       FIELD_TYPE_DATETIME,
       FIELD_TYPE_TIMESTAMP: Inc(Result,SizeOf(TDateTime));
       FIELD_TYPE_DECIMAL,
       FIELD_TYPE_NEWDECIMAL, //:CN 04/05/2005
       FIELD_TYPE_FLOAT,
       FIELD_TYPE_DOUBLE : Inc(Result,SizeOf(Double));
       FIELD_TYPE_ENUM: Inc(Result,SizeOf(SmallInt));
       FIELD_TYPE_SET : Inc(Result,FieldMaxSize(I)+1);
       FIELD_TYPE_BLOB : Inc(Result,SizeOf(TBlobItem));
     else
       Inc(Result,FieldMaxSize(I){+1});
     end;
   end;
end;

Function TNativeDataSet.GetBookMarkSize : Integer;
begin
  Result := Sizeof(TmySQLBookMark);
end;

Procedure TNativeDataSet.SetBufBookmark;
Var
  Buffer : Pointer;
begin
  If (CurrentBuffer <> nil) and (FBookOfs > 0) then
  begin
    Buffer := CurrentBuffer;
    Inc(LongInt(Buffer), FBookOfs);
    GetBookMark(Buffer);
  end;
end;

Function TNativeDataSet.GetRecordNumber: Longint;
begin
  if Assigned(FStatement) then
     Result := FStatement.RecNo else
     Result := -1;
end;

function TNativeDataSet.GetRecCount: LongInt;
begin
  if FStatement = nil then Result := 0
  else Result := FStatement.RowsCount;
end;

Procedure TNativeDataSet.CheckFilter(PRecord : Pointer);
var
  P    : Pointer;
  B    : Boolean;
begin
  if PRecord <> nil then
  begin
    if FFilterActive then
      While not FilteredRecord(PRecord) do
      begin
        InternalBuffer := PRecord;
        if FLastDir <> tdPrev then NextRecord else PrevRecord;
      end;
  end else
  begin
     if FFilterActive then
     begin
        GetMem(P,GetWorkBufferSize);
        ZeroMemory(P,GetWorkBufferSize);
        try
          InternalBuffer := P;
          InternalReadBuffer;
          B := FilteredRecord(P);
          While not B do
          begin
             InternalBuffer := P;
             if FLastDir <> tdPrev then NextRecord else PrevRecord;
             B := FilteredRecord(P);
          end;
        finally
          FreeMem(P,GetWorkBufferSize);
//          P := nil;//mi:for preventing hint
        end;
     end;
  end;
end;

Procedure TNativeDataSet.FirstRecord;
begin
  if (OpenMode = omStore) and Assigned(FStatement) then
  begin
     FStatement.First;
     if FStatement.EOF then raise EmySQLException.CreateBDE(DBIERR_BOF);
     SetBufBookmark;
     InternalReadBuffer;
     MonitorHook.SQLFetch(Self);
  end else
     FConnect.CheckResult;
end;

Procedure TNativeDataSet.LastRecord;
begin
  if (OpenMode = omStore) and Assigned(FStatement) then
  begin
     FStatement.Last;
     if FStatement.BOF then raise EmySQLException.CreateBDE(DBIERR_EOF);
     SetBufBookmark;
     InternalReadBuffer;
     MonitorHook.SQLFetch(Self);
  end else
     FConnect.CheckResult;
end;

Procedure TNativeDataSet.NextRecord;
begin
  if (OpenMode = omStore) and Assigned(FStatement) then
  begin
     FStatement.Next;
     if FStatement.EOF then raise EmySQLException.CreateBDE(DBIERR_EOF);
     SetBufBookmark;
     InternalReadBuffer;
     MonitorHook.SQLFetch(Self);
  end else
    FConnect.CheckResult;
end;

Procedure TNativeDataSet.PrevRecord;
begin
  if (OpenMode = omStore) and Assigned(FStatement) then
  begin
     FStatement.Prior;
     if FStatement.BOF then raise EmySQLException.CreateBDE(DBIERR_BOF);
     SetBufBookmark;
     InternalReadBuffer;
     MonitorHook.SQLFetch(Self);
  end else
     FConnect.CheckResult;
end;

Procedure TNativeDataSet.CurrentRecord(RecNo : Longint);
begin
  if (OpenMode = omStore) and Assigned(FStatement) then
  begin
    FStatement.RecNo:= RecNo;
    if FStatement.BOF then raise EmySQLException.CreateBDE(DBIERR_BOF);
    if FStatement.EOF then raise EmySQLException.CreateBDE(DBIERR_EOF);
    SetBufBookmark;
    InternalReadBuffer;
  end else
    FConnect.CheckResult;
end;

Procedure TNativeDataSet.GetWorkRecord(eLock: DBILockType;PRecord: Pointer);
var
  P : TmySQLBookMark;
begin
  GetBookMark( @P );
  CheckParam(@P=nil,DBIERR_INVALIDPARAM);
  InternalBuffer := PRecord;
  try
    If not FIsLocked then
    begin
      SetToBookMark(@P);
      if eLock = dbiWRITELOCK then LockRecord(eLock);
      RecordState := tsPos;
    end;
  finally
  end;
end;

Procedure TNativeDataSet.GetRecordNo(var iRecNo: Longint);
begin
  iRecNo := RecordNumber;
end;

Procedure TNativeDataSet.LockRecord(eLock : DBILockType);
begin
  FIsLocked := (eLock <> dbiNOLOCK);
end;

Function TNativeDataSet.FilteredRecord(PRecord : Pointer) :  Boolean;
var
  P    : TmySQLFilter;
  I    : Integer;
begin
  Result := TRUE;
  If FFilterActive then
  begin
    For i := 0 to FFilters.Count-1 do
    begin
      P := FFilters.Items[i];
      if P.Active and not P.GetFilterResult(PRecord) then
      begin
        Result := FALSE;
        Exit;
      end;
    end;
  end;
end;

Procedure TNativeDataSet.UpdateFilterStatus;
Var
  P : TmySQLFilter;
  I : Integer;
begin
  For i := 0 to FFilters.Count-1 do
  begin
    P := FFilters.Items[i];
	 If (P <> NIL) and (P.Active) then
    begin
      FFilterActive := TRUE;
      Exit;
    end;
  end;
  FFilterActive := FALSE;
end;

Procedure TNativeDataSet.NativeToDelphi(P: TmySQLField;PRecord: Pointer;pDest: Pointer;var bBlank: Bool);
begin
  CheckParam(PRecord=nil,DBIERR_INVALIDPARAM);
  P.Buffer := PRecord;
  bBlank   := P.FieldNull;
  if not bBlank and (pDest <> nil) then AdjustNativeField(P,P.FieldValue,pDest,bBlank);
end;

Procedure TNativeDataSet.DelphiToNative(P: TmySQLField;PRecord: Pointer;pSrc: Pointer);
begin
  If pSrc <> nil then AdjustDelphiField(P,pSrc,PChar(P.Data)+P.FieldNumber-1);
end;

procedure TNativeDataSet.CheckParam(Exp : Boolean;BDECODE : Word);
begin
   If Exp then Raise EmySQLException.CreateBDE(BDECODE);
end;

/////////////////////////////////////////////////////////////////////
//                       PUBLIC METHODS                            //
/////////////////////////////////////////////////////////////////////
Procedure TNativeDataSet.GetRecord(eLock: DBILockType;PRecord: Pointer;pRecProps: pRECProps);
begin
  InternalBuffer := PRecord;
  Case RecordState of
    tsPos:
      begin
        GetWorkRecord(eLock,PRecord);
        Try
          CheckFilter(PRecord);
        Except
          On E:EmySQLException do
			 begin
            if FReRead then
            begin
              FReRead := FALSE;
              RecordState  := tsNoPos;
              GetNextRecord( eLock, PRecord, pRecProps );
            end
            else
            begin
              If eLock = dbiWRITELOCK then FIsLocked := FALSE;
              Raise;
            end;
          end;
        end;
          if pRecProps <> nil then
          begin
             if Assigned(FStatement) then
             begin
                pRecProps^.iPhyRecNum := FStatement.RecNo+1;
                pRecProps^.iSeqNum := FStatement.RecNo+1;
             end;
          end;
      end;
    tsFirst: Raise EmySQLException.CreateBDE(DBIERR_EOF);
    tsLast: Raise EmySQLException.CreateBDE(DBIERR_BOF);
    tsEmpty:
      begin
        Try
          GetNextRecord( eLock, PRecord, pRecProps );
        Except
          On E:EmySQLException do
          begin
            Try
              GetPriorRecord( eLock, PRecord, pRecProps );
            Except
              On E:EmySQLException do
              begin
                RecordState  := tsNoPos;
                GetNextRecord( eLock, PRecord, pRecProps );
              end;
            end;
			 end;
        end;
      end;
    else Raise EmySQLException.CreateBDE(DBIERR_NOCURRREC);
  end;
end;

Procedure TNativeDataSet.LoadProperties( pRecProps : pRECProps );
begin
end;

Procedure TNativeDataSet.GetNextRecord(eLock: DBILockType;PRecord: Pointer;pRecProps: pRECProps);
begin
  FLastDir     := tdNext;
  InternalBuffer := PRecord;
  Case RecordState of
    tsPos,
    tsEmpty: NextRecord;
    tsFirst,
    tsNoPos: FirstRecord;
  else Raise EmySQLException.CreateBDE(DBIERR_EOF);
  end;
  CheckFilter(PRecord);
  if eLock <> dbiNOLOCK then GetRecord(eLock, PRecord, pRecProps);
  if pRecProps <> nil then
  begin
     if Assigned(FStatement) then
     begin
        pRecProps^.iPhyRecNum := FStatement.RecNo+1;
        pRecProps^.iSeqNum := FStatement.RecNo+1;
     end;
  end;
  RecordState := tsPos;
end;

Procedure TNativeDataSet.GetPriorRecord(eLock: DBILockType;PRecord: Pointer;pRecProps: pRECProps);
begin
  FLastDir     := tdPrev;
  InternalBuffer := PRecord;
  Case RecordState of
    tsPos,
	 tsEmpty: PrevRecord;
    tsLast,
    tsNoPos: LastRecord;
  else Raise EmySQLException.CreateBDE(DBIERR_BOF);
  end;
  CheckFilter(PRecord);
  if eLock <> dbiNOLOCK then GetRecord(eLock, PRecord, pRecProps);
  if pRecProps <> nil then
  begin
     pRecProps^.iPhyRecNum := FStatement.RecNo+1;
     pRecProps^.iSeqNum := FStatement.RecNo+1;
  end;
  RecordState := tsPos;
end;

Procedure TNativeDataSet.AddFilter(iClientData: Longint;iPriority: Word;bCanAbort: Bool;pcanExpr: pCANExpr;pfFilter: pfGENFilter;var hFilter: hDBIFilter);
var
  P : TmySQLFilter;
begin
  P := TmySQLFilter.Create(Self,iClientData,pcanExpr,pfFilter);
  FFilters.Insert(P);
  UpdateFilterStatus;
  hFilter := hDBIFilter(P);
end;

Procedure TNativeDataSet.DropFilter(hFilter: hDBIFilter);
var
  Count : Integer;
begin
  if hFilter = NIL then FFilters.FreeAll else
  begin
    Count := FFilters.Count;
    FFilters.Delete(hFilter);
    If Count <> FFilters.Count then
    begin
      TmySQLFilter(hFilter).Free;
      UpdateFilterStatus;
    end;
  end;
end;

Procedure TNativeDataSet.ActivateFilter(hFilter: hDBIFilter);
var
  i     : Integer;
  P     : TmySQLFilter;
  Found : Boolean;
begin
  Found := FALSE;
  For i := 0 to FFilters.Count-1 do
  begin
    P := FFilters.Items[i];
    If (hFilter = nil) or (hFilter = hDBIFilter(P)) then
    begin
      P.Active      := TRUE;
      FFilterActive := TRUE;
      Found         := TRUE;
    end;
  end;
  If not Found and (hFilter <> nil) then EmySQLException.CreateBDE(DBIERR_NOSUCHFILTER);
end;

Procedure TNativeDataSet.DeactivateFilter(hFilter: hDBIFilter);
var
  i : Integer;
  P : TmySQLFilter;
begin
  if hFilter = nil then
  begin
    For i := 0 to FFilters.Count-1 do
    begin
      P := FFilters.Items[i];
      P.Active := FALSE;
    end;
    FFilterActive := FALSE;
  end else
  begin
    if TmySQLFilter( hFilter ).Active then
    begin
      TmySQLFilter( hFilter ).Active := FALSE;
      UpdateFilterStatus;
    end;
  end;
end;

procedure TNativeDataSet.SetToRecord(RecNo : LongInt);
begin
  if RecNo < 0 then
  begin
     Try
       if RecordState <> tsEmpty then CurrentRecord(RecNo);
     Except
     end;
  end
  else
     if RecordState <> tsEmpty then CurrentRecord(RecNo);
end;

Procedure TNativeDataSet.SetToBookmark(P : Pointer);
begin
  CheckParam(P=nil,DBIERR_INVALIDPARAM);
  if TmySQLBookMark(P^).Position >= 0   then
  begin
     FRecno := TmySQLBookMark(P^).Position-1;
     if RecordState <> tsEmpty then
        SetToRecord(TmySQLBookMark(P^).Position) else
        begin //Insert
           SetToRecord(TmySQLBookMark(P^).Position);
        end;
  end else FirstRecord;
  RecordState := tsPos;
end;

Procedure TNativeDataSet.GetRecordCount( Var iRecCount : Longint );
var
  P      : Pointer;
  Buff   : Pointer;
  Marked : Boolean;
begin
   if not FFilterActive then
      iRecCount := RecordCount else
   begin
      iRecCount := 0;
      GetMem(Buff, GetWorkBufferSize);
		try
        GetMem(P, BookMarkSize);
        try
          try
            GetBookMark(P);
            Marked := true;
          except
            On E:EMySQLexception do
               Marked := false;
          end;
          SetToBegin;
          try
            repeat
                GetNextRecord(dbiNOLOCK, Buff, nil);
                Inc(iRecCount);
                if (iRecCount Mod 16) = 0 then
                   Application.ProcessMessages;
            until false;
          except
            On E:EMySQLException do;
          end;
          If Marked then
             SetToBookMark(P) else
             SetToBegin;
        finally
          FreeMem(P, BookMarkSize);
        end;
      finally
        FreeMem(Buff, GetWorkBufferSize);
      end;
   end;
end;

// Declare GetStatementChanged function
function TNativeDataSet.GetStatementChanged : Boolean;
begin
  Result := (FStatement = nil) or FStatementChanged;
  FStatementChanged := False;
end;

procedure TNativeDataSet.InternalOpen(asql_stmt : PChar);
var
  a        : boolean;
  frstm    : boolean;
begin
   frstm := false;
   if SQLQuery = '' then
   begin
      if StandartClause.Count > 0  then
      begin
         asql_stmt := GetSQLClause;
         frstm := true;
      end else
         Raise EmySQLException.CreateBDE(DBIERR_QRYEMPTY);
   end else
      asql_stmt := PChar(SQLQuery);
   if OpenMode = omStore then
      FStatement:=FConnect.Handle.query(asql_stmt,True,a) else
      FStatement:=FConnect.Handle.query(asql_stmt,False,a);
   FStatementChanged := True;
   MonitorHook.SQLExecute(Self, a);          // ptook
   if frstm then
      StrDispose(asql_stmt);
   if a then
   begin
      if Assigned(FStatement) then
      begin
          FOpen := True;
      end else
         FConnect.CheckResult;
   end else FConnect.CheckResult;
end;

procedure TNativeDataSet.OpenTable;
var
  sql_stmt : PChar;
begin
  if FOpen then CloseTable;
  sql_stmt :=nil;
  Try
    if (StandartClause.Count = 0) and (SQLQuery = '') then
    begin
		if ServerVersion > 32306 then
         StandartClause.Add(Format('Select * from `%s`',[TableName])) else
         StandartClause.Add(Format('Select * from %s',[TableName]));
      if FOpen then ClearIndexInfo;
      limitClause.Add('limit 0');
      InternalOpen(sql_stmt);
      //очищаем limit
      limitClause.Clear;
      //Устанавливаем Limit и Offset
      if (FLimit > -1) or (FOffset > 0) then
         LimitClause.Add(Format('limit %s, %s',[IntToStr(FOffset),IntToStr(FLimit)]));
      //Обработка индексов
      if IndexCount > 0 then
      begin
         if FPrimaryKeyNumber = 0 then FPrimaryKeyNumber := 1;
         SwitchToIndex(FIndexName, nil, 0, False );
      end else
         InternalOpen(sql_stmt);
      Exit;
    end;
    InternalOpen(sql_stmt);
    if KeyNumber = 0 then
    begin
       if FPrimaryKeyNumber <> 0 then
          GetIndexDesc(FPrimaryKeyNumber, FKeyDesc) else
          begin
             if IndexCount > 0 then
             begin
                if FPrimaryKeyNumber > 0 then
                   FKeyDesc := FIndexDescs.mIndex[FPrimaryKeyNumber].Description else
                   FKeyDesc := FIndexDescs.mIndex[1].Description;
             end;
          end;
    end;
  Finally
    if SQLQuery = '' then StrDispose(sql_stmt);
  end;
end;

Procedure TNativeDataSet.ReOpenTable;
var
	sql_stmt : PChar;
begin
   if FOpen then CloseTable;
   sql_stmt :=nil;
   try
     InternalOpen(sql_stmt);
   finally
     if SQLQuery = '' then StrDispose(sql_stmt);
   end;
end;


Procedure TNativeDataSet.GetField(FieldNo: Word;PRecord: Pointer;pDest: Pointer;var bBlank: Bool);
var
  T    : TmySQLField;
begin
  CheckParam(PRecord=nil,DBIERR_INVALIDPARAM);
  T := FFieldDescs[FieldNo];
  T.Buffer := PRecord;
  If Assigned(pDest) then
     NativeToDelphi(T, PRecord, pDest, bBlank) else  bBlank := T.FieldNull;
end;

Procedure TNativeDataSet.PutField(FieldNo: Word;PRecord: Pointer;pSrc: Pointer);
var
  T : TmySQLField;
begin
  CheckParam(PRecord=nil,DBIERR_INVALIDPARAM);
  T := FFieldDescs[FieldNo];
  T.Buffer := PRecord;
  DelphiToNative(T, PRecord, pSrc);
  T.FieldChanged := TRUE;
  T.FieldNull := pSrc = nil;
end;

procedure TNativeDataSet.CloseTable;
begin
  FOpen := False;
  isQuery := False;
  FAffectedRows := 0;
//VIC
  If FContainer <> nil then
     FContainer.Delete(Self);
//VIC
  if FStatement <> nil then
     FStatement.Free;
  FStatement := nil;
end;

Procedure TNativeDataSet.GetBookMark( P : Pointer );
begin
  ZeroMemory(P, BookMarkSize );
  With TmySQLBookMark(P^) do
    Position:= RecordNumber;
end;

procedure TNativeDataSet.GetVchkDesc(iValSeqNo: Word;pvalDesc: pVCHKDesc);
var
  M : pVCHKDesc;
begin
  M  := pValDesc;
  Move(Fields[iValSeqNo].ValCheck, M^, SizeOf(VCHKDesc));
end;

Procedure TNativeDataSet.GetCursorProps( var curProps : CURProps );
begin
  ZeroMemory(@curProps, SizeOf(curProps));
  With curProps do
  begin
    iFields := FieldCount;
    iRecSize  := RecordSize;
    iRecBufSize := GetWorkBufferSize;                     { Record size (physical record) }
    iValChecks      := FieldCount;
    iBookMarkSize   := BookMarkSize;                      { Bookmark size }
    bBookMarkStable := False;                             { Stable book marks }
    eOpenMode       := FOMode;                            { ReadOnly / RW }
    iSeqNums        := 1;                                 { 1: Has Seqnums; 0: Has Record# }
    exltMode        := xltNONE;                           { Translate Mode }
    bUniDirectional := True;                              { Cursor is uni-directional }
    eprvRights      := prvUNKNOWN;                        { Table  rights }
    iFilters        := FFilters.Count;                    { Number of Filters }
    if isQuery then
	 begin
       iIndexes     := 0;
       iKeySize     := 0;
    end else
    begin
       iIndexes     := IndexCount;
       iKeySize     := FKeyDesc.iKeyLen;                  { Key size }
    end;
    bSoftDeletes    := False;
  end;
end;

Procedure TNativeDataSet.GetFieldDescs(pFDesc : pFLDDesc);
var
  i : Integer;
  M : pFldDesc;
begin
  M  := pFDesc;
  For i := 1 to FieldCount do
  begin
    Move(Fields[i].Description, M^, SizeOf(FldDesc));
    Inc(M);
  end;
end;

procedure TNativeDataSet.Execute;
var
  a : boolean;
begin
  if FOpen then CloseTable;
  FAffectedRows := 0;
  FStatement := nil;
  if not Assigned(FConnect) or not (FConnect.FLoggin) then  Exit;
  FConnect.Handle.query(SQLQuery,True,a);
  MonitorHook.SQLExecute(Self, a);         // ptook
  if a then
  begin
     FAffectedRows := FConnect.Handle.AffectedRows;
     FLastInsertID := FConnect.Handle.LastInsertId;
  end;
  FConnect.CheckResult;
  SQLQuery := '';
end;

function TNativeDataset.FieldCount: Integer;
begin
  if FStatement = nil then Result := 0
  else Result := FStatement.FieldsCount;
end;

Function TNativeDataSet.GetRecordSize: Integer;
var
   I, Size: Integer;
begin
   Size:=0;
   Result:=0;
   if FRecSize=-1 then
   begin
      if FStatement = nil then exit;
      For i:=0 to FieldCount-1 do
         Inc(Size,FieldMaxSize(I));
      Inc(Size,FieldCount);
      FRecSize:=Size;
      Result:=Size;
   end else  Result:=FRecSize;
end;

function TNativeDataSet.FieldName(FieldNum: Integer): ShortString;
var
  Field: PMYSQL_FIELDDEF;
begin
  Result := '';
  if FStatement <> nil then
  begin
    Field :=FStatement.FieldDef(FieldNum);
    if Field <> nil then
      Result := Field.name;
  end;
end;

function TNativeDataSet.FieldIndex(FieldName: ShortString): Integer;
var
  I, P: Integer;
  Name, Num: string;
begin
  Result := -1;
  if FieldCount = 0 then Exit;
  for I := 0 to FieldCount-1 do
    if FieldName = Self.FieldName(I) then
    begin
      Result := I;
      Break;
    end;
  if Result <> -1 then Exit;
  Name := '';
  Num  := '';
  P := LastDelimiter('_', FieldName);
  if P > 0 then
  begin
    Name := Copy(FieldName, 1, P-1);
    Num  := Copy(FieldName, P+1, 10);
  end else   Exit;
  P := StrToIntDef(Num, 0) + 1;
  if P <= 1 then Exit;
  for I := 0 to FieldCount-1 do
  begin
    if Name = Self.FieldName(I) then Dec(P);
    if P = 0 then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

function TNativeDataSet.FieldSize(FieldNum: Integer): LongInt;
begin
   if (FStatement = nil) or (FieldNum >= FieldCount) then
      Result := 0 else
   begin
      FStatement.HasLengths := true;
      Result  := FStatement.FieldLenght(FieldNum);
  end;
end;

function TNativeDataSet.FieldMaxSize(FieldNum: Integer): LongInt;
var
  Field: PMYSQL_FIELDDEF;
begin
  Result := 0;
  if FStatement <> nil then
  begin
    Field := FStatement.FieldDef(FieldNum);
    if Field <> nil then
    begin
       if ISBLOB(Field) then
          Result := 4 else
        case Field.FieldType of
           FIELD_TYPE_TINY,
           FIELD_TYPE_SHORT:     Result := SizeOf(SmallInt);
           FIELD_TYPE_LONG,
           FIELD_TYPE_INT24,
           FIELD_TYPE_YEAR:      Result := SizeOf(LongInt);
           FIELD_TYPE_DATE,
           FIELD_TYPE_TIME:      Result := SizeOf(TDateTime);
           FIELD_TYPE_LONGLONG : Result := SizeOf(Int64);
           FIELD_TYPE_DATETIME,
           FIELD_TYPE_TIMESTAMP: Result := SizeOf(TDateTime);
           FIELD_TYPE_DECIMAL,
           FIELD_TYPE_NEWDECIMAL, //:CN 04/05/2005
           FIELD_TYPE_FLOAT,
           FIELD_TYPE_DOUBLE :   Result := SizeOf(Double);
           FIELD_TYPE_ENUM:      Result := SizeOf(SmallInt);
           FIELD_TYPE_SET :      Result := Max(Field.max_length, Field.length);
        else
           Result := Max(Field.max_length, Field.length)+1;
        end;
    end;
  end;
end;

function TNativeDataSet.FieldDecimals(FieldNum: Integer): Integer;
var
  Field: PMYSQL_FIELDDEF;
begin
  Result := 0;
  if FStatement <> nil then
  begin
    Field := FStatement.FieldDef(FieldNum);
    if Field <> nil then
      Result := Field.decimals;
  end;
end;

function TNativeDataSet.Field(FieldNum: Integer): string;
var
  Length : LongInt;
begin
  Result := '';
  if FStatement = nil then Exit;
  FStatement.HasLengths:=true;
  Length  := FStatement.FieldLenght(FieldNum);
  SetString(Result,FStatement.FieldValue(FieldNum), Length);
end;

function TNativeDataSet.FieldByName(FieldName: ShortString): string;
begin
  Result := Field(FieldIndex(FieldName));
end;

function TNativeDataSet.FieldIsNull(FieldNum: Integer): Boolean;
begin
  Result := FieldBuffer(FieldNum) = nil;
end;

function TNativeDataSet.FieldBuffer(FieldNum: Integer): PChar;
begin
  Result := nil;
  if FStatement = nil then Exit;
  Result := FStatement.FieldValue(FieldNum);
end;

function TNativeDataSet.FieldType(FieldNum: Integer): Integer;
var
  Field: PMYSQL_FIELDDEF;
begin
   Result := 0;
   if FStatement <> nil then
   begin
      Field := FStatement.FieldDef(FieldNum);
      if Field <> nil then
         Result := Field.FieldType;
   end;
end;

Function TNativeDataSet.GetFieldInfo(Index : Integer) : PMYSQL_FIELDDEF;
var
  Field: PMYSQL_FIELDDEF;
begin
   Result := nil;
   if FStatement <> nil then
   begin
      Field := FStatement.FieldDef(Index);
      if Field <> nil then
         Result := Field;
   end;
end;

function TNativeDataSet.FieldVal(FieldNo: Integer; FieldPtr : Pointer; DoubleQuote : Boolean):String;
var
   Field : TMySQLField;
   Blank : Bool;
   Buff  : array[0..255] of Char;
   TimeStamp : TTimeStamp;
   DateD : Double;
begin
   Result := '';
   Field := Fields[FieldNo];
   AdjustNativeField(Field,FieldPtr,@Buff,Blank);
   if Blank then Exit;
   case Field.FieldType of
      fldINT16: Result :=  IntToStr(PSmallInt(@Buff)^);
      fldUINT16: Result := IntToStr(PWord(@Buff)^);
      fldINT32: Result := IntToStr(PLongInt(@Buff)^);
      fldUINT32: Result := IntToStr(PLongInt(@Buff)^);
      fldINT64: Result := IntToStr(PInt64(@Buff)^);
		fldFLOAT: Result := SQLFloatToStr(PDouble(@Buff)^);
      fldZSTRING: if DoubleQuote then
                     Result := ''''+uMyDMHelpers.EscapeStr(StrPas(@Buff))+'''' else
                     Result := ''+uMyDMHelpers.EscapeStr(StrPas(@Buff))+'';
      fldBOOL:  if  DoubleQuote then
                    Result := ''''+BoolToStr(PSmallInt(@Buff)^,Field.FEnum_Val)+'''' else
                    Result := ''+uMyDMHelpers.EscapeStr(StrPas(@Buff))+'';
      fldDATE : begin
                   DWORD(TimeStamp.Date) := PDWORD(@Buff)^;
                   TimeStamp.Time := 0;
                   if DoubleQuote then
                      Result := ''''+DateTimeToSqlDate(SysUtils.Time+Trunc(TimeStampToDateTime(TimeStamp) + 1E-11),1)+'''' else
                      Result := ''+DateTimeToSqlDate(SysUtils.Time+Trunc(TimeStampToDateTime(TimeStamp) + 1E-11),1)+'';
                end;
      fldTIME : begin
                   DWORD(TimeStamp.Time) := PDWORD(@Buff)^;
                   TimeStamp.Date := DateDelta;
                   if DoubleQuote then
                      Result := ''''+DateTimeToSqlDate(SysUtils.Date+TimeOf(TimeStampToDateTime(TimeStamp)),2)+'''' else
                      Result := ''+DateTimeToSqlDate(SysUtils.Date+TimeOf(TimeStampToDateTime(TimeStamp)),2)+'';
                end;
  {$IFDEF DELPHI_6}
  fldDATETIME : begin
                    DateD := PDouble(@Buff)^;
                    if DoubleQuote then
                       Result := ''''+DateTimeToSqlDate(TimeStampToDateTime(MSecsToTimeStamp(DateD)),0)+'''' else
                       Result := ''+DateTimeToSqlDate(TimeStampToDateTime(MSecsToTimeStamp(DateD)),0)+'';
                 end;
  {$ENDIF}
  fldTIMESTAMP : begin
                    DateD := PDouble(@Buff)^;
                    if DoubleQuote then
                       Result := ''''+DateTimeToSqlDate(TimeStampToDateTime(MSecsToTimeStamp(DateD)),0)+'''' else
                       Result := ''+DateTimeToSqlDate(TimeStampToDateTime(MSecsToTimeStamp(DateD)),0)+'';
                 end;
   else
      Result := '';
   end;
end;

Procedure TNativeDataSet.GetNativeDesc(FieldNo : Integer;P : pFldDesc;P1 : pVCHKDesc; Var LocType: Word; Var LocSize : LongInt; var EnumValue : String);
var
  Fld : PMYSQL_FIELDDEF;
  S : PChar;
begin
  if Assigned(P) then
  begin
    CheckParam(not (FieldNo <= FieldCount),DBIERR_INVALIDRECSTRUCT);
    FLD := FieldInfo[FieldNo-1];
    CheckParam(FLD=nil,DBIERR_INVALIDRECSTRUCT);
    if ISENUM(FLD) or ISSET(FLD) then
       EnumValue := InternaENUM_SET_Value(StrPas(FLD.Table),StrPas(FLD.Name));
    if ISNOTNULL(FLD) then
       S := InternalGetDefault(StrPas(FLD.Table),StrPas(FLD.Name)) else
       S := nil;//''; //NICK
    ConvermySQLtoDelphiFieldInfo(FLD, FieldNo, FieldOffset(FieldNo), P,P1,EnumValue, S);
    LocType := FieldType(FieldNo-1);
    if ISBLOB(FLD) then
       LocSize := Max(FLD.max_length, FLD.length) else
       LocSize := FieldMaxSize(FieldNo-1);
  end;
end;

{$HINTS OFF}
function TNativeDataSet.InternalGetDefault(TableName,FieldName:String):PChar;
var
  Stmt : TMysqlResult;
  Sql_stmt : String;
  A : Boolean;
begin
  Result :=nil; //''; NICK
  if TableName = '' then Exit;
  Sql_Stmt := Format('DESCRIBE %s ''%s''',[TableName,FieldName]);
  Stmt := FConnect.Handle.query(SQL_Stmt,True,A);
  if A then
  begin
     Stmt.First;
     Result := Stmt.FieldValue(4);
  end;
  if Stmt <> nil then
     Stmt.Free;
  Stmt := nil;
end;

function TNativeDataSet.InternaENUM_SET_Value(TableName,FieldName:String):string;
var
  Stmt : TMysqlResult;
  Sql_stmt : String;
  S : String;
  A : Boolean;
begin
  Result :='';
  if TableName = '' then Exit;
  Sql_Stmt := Format('DESCRIBE %s ''%s''',[TableName,FieldName]);
  Stmt := FConnect.Handle.query(SQL_Stmt,True,A);
  if A then
  begin
     Stmt.First;
     S := Stmt.FieldValue(1);
     Delete(S,1,Pos('(',S));
     S := Copy(S,1,Pos(')',S)-1);
     Result := StringReplace(S,'''','',[rfReplaceAll, rfIgnoreCase]);
  end;
  if Stmt <> nil then
     Stmt.Free;
  Stmt := nil;
end;
{$HINTS ON}


Procedure TNativeDataSet.InitFieldDescs;
var
  i         : Integer;
  FldInfo   : FLDDesc;
  ValCheck  : VCHKDesc;
  LocalType,NullOffset,RecSize: Word;
  LocalSize : LongInt;
  eval      : string;
begin
   Fields.Clear;
   For i := 1 to FieldCount do
   begin
      try
		  GetNativeDesc(i, @FldInfo,@ValCheck, LocalType, LocalSize,eval);
        TmySQLField.CreateField(Fields, @FldInfo, @ValCheck, i, LocalType, LocalSize,eval);
      except
        raise;
      end;
   end;
   RecSize  := RecordSize;
   NullOffset := RecSize;
   For i := 1 to Fields.Count do
   begin
      Fields[i].NullOffset := NullOffset;
      Inc(NullOffset, SizeOf(TFieldStatus));
   end;
end;

Function TNativeDataSet.GetBufferSize : Word;
begin
  if FFieldDescs.Count = 0 then InitFieldDescs;
  Result := RecordSize;
end;

Function TNativeDataSet.GetWorkBufferSize : Word;
begin
  Result := GetBufferSize;
  Inc(Result, Succ(FFieldDescs.Count * SizeOf(TFieldStatus)));
  FBookOfs := Result;
  If FBookOfs > 0 then Inc(Result, BookMarkSize);
end;

Procedure TNativeDataSet.GetProp(iProp: Longint;PropValue: Pointer;iMaxLen: Word;var iLen: Word);
begin
  iLen := 0;
  Case TPropRec( iProp ).Prop of
    Word( curMAXPROPS ): begin
                            iLen := SizeOf(Word);
                            Word(PropValue^) := maxCurProps;
                         end;
    Word( curXLTMODE ):  begin
                            iLen := SizeOf(xltMODE);
                            xltMODE( PropValue^ ) := xltNONE;
                         end;
	 Word(curMAXFIELDID): begin
                            iLen := iMaxLen;
                            Integer( PropValue^ ) := FFieldDescs.Count;
                         end;
    Word(stmtROWCOUNT):  begin
                            iLen := SizeOf(Integer);
                            Integer(PropValue^) := FAffectedRows;
                         end;
    Word(curAUTOREFETCH):begin
                            iLen := SizeOf(Boolean);
                            Boolean(PropValue^) := FReFetch;
                         end;
  end;
end;

Procedure TNativeDataSet.SetProp(iProp: Longint; PropValue: Longint);
begin
  Case TPropRec( iProp ).Prop of
  Word(curMAKECRACK): RecordState := tsEmpty;
  Word(stmtLIVENESS): begin
                         if PropValue = 1 then
                            FOMode := dbiReadWrite else
                            FOMode := dbiREADONLY;
                      end;
  Word(curAUTOREFETCH): FReFetch := PropValue = 1;
  end;
end;

Procedure TNativeDataSet.SetToBegin;
begin
  RecordState  := tsFirst;
end;

Procedure TNativeDataSet.SetToEnd;
begin
  RecordState  := tsLast;
end;

{$HINTS OFF}
Procedure TNativeDataSet.InternalReadBuffer;
var
  i, size: Integer;
  MaxSize : Integer;
  T: TmySQLField;
  origBuffer: Pointer;
  Data : pointer;
  FldVal : String;
begin
   T := nil;
   if assigned(FCurrentBuffer) then
   begin
       MaxSize:=0;
       for i:=0 to FieldCount-1 do
       begin
          if FieldType(I) <> FIELD_TYPE_BLOB then
             if FieldMaxSize(I) > MaxSize then MaxSize:=FieldMaxSize(I);
       end;
       GetMem(Data,MaxSize+1);
       origBuffer:=FCurrentBuffer;
       for i:=0 to FieldCount-1 do
       begin
          if Fields.Count>=i then
          begin
             T := Fields[i+1];
             T.Buffer  := origBuffer;
             T.FieldChanged := FALSE;
             T.FieldNull    := FieldIsNull(I);
          end;
          size:=T.FieldLength;
          if T.FieldNull then ZeroMemory(FCurrentBuffer,size)
          else
          begin
             FldVal := String(FieldBuffer(I));
             case T.NativeType of
              FIELD_TYPE_TINY,
      	      FIELD_TYPE_SHORT : SmallInt(Data^) := SmallInt(StrToInt(FldVal));
	            FIELD_TYPE_INT24,
              FIELD_TYPE_YEAR,
	            FIELD_TYPE_LONG : LongInt(Data^) := LongInt(StrToInt(FldVal));
	            FIELD_TYPE_LONGLONG : Int64(Data^) := StrToInt64(FldVal);
              FIELD_TYPE_SET,
              FIELD_TYPE_VAR_STRING,
					 FIELD_TYPE_STRING: StrCopy(PChar(Data),FieldBuffer(I));
	            FIELD_TYPE_NEWDATE,
              FIELD_TYPE_DATE:   TDateTime(Data^) := SQLDateToDateTime(FldVal);
              FIELD_TYPE_TIME:   TDateTime(Data^) := SQLDateToDateTime(FldVal);
              FIELD_TYPE_TIMESTAMP: TDateTime(Data^) :=SQLTimeStampToDateTime(FldVal);
              FIELD_TYPE_DATETIME: TDateTime(Data^) :=SQLDateToDateTime(FldVal);
              FIELD_TYPE_DECIMAL,
              FIELD_TYPE_NEWDECIMAL, //:CN 04/05/2005
              FIELD_TYPE_FLOAT,
              FIELD_TYPE_DOUBLE:   Double(Data^) :=StrToSQLFloat(FldVal);
              FIELD_TYPE_ENUM:      if Size = SizeOf(SmallInt) then
                                       SmallInt(Data^) := SmallInt(StrToBool(['y','t'],['n','f'],FldVal)) else
                                       StrCopy(PChar(Data),FieldBuffer(I));
              FIELD_TYPE_BLOB:      begin
                                        size := SizeOf(TBlobItem);
                                        ZeroMemory(FCurrentBuffer, size);
                                        Inc(PChar(FCurrentBuffer)); //Null byte allocate
                                        Inc(PChar(FCurrentBuffer),size); //Pointer allocate
                                        continue;
                                    end;
             end;
             move(Data^,(PChar(FCurrentBuffer)+1)^,size);
             PChar(FCurrentBuffer)^:=#1; {null indicator 1=Data 0=null}
            end;
          Inc(PChar(FCurrentBuffer),size+1); {plus 1 for null byte}
       end;                                
       FreeMem(Data,MaxSize+1);
       Data := nil;
       FCurrentBuffer:=nil;
   end;
end;
{$HINTS ON}

//procedure TNativeDataset.ShowIndexes(TableName: ShortString);
//var
//  A : Boolean;
//begin
//  if FOpen then CloseTable;
//  SQLQuery := 'SHOW INDEX FROM ' + TableName;
//  FAffectedRows := 0;
////  FOpen := False;
//  FStatement:=FConnect.Handle.query(SQLQuery,True,a);
//  if a then
//  begin
//    if Assigned(FStatement) then
//    begin
//       FOpen := True;
//    end else FConnect.CheckResult;
//  end else FConnect.CheckResult;
//end;

Procedure TNativeDataSet.ForceReread;
var
   RN : LongInt;
begin
  FReRead := TRUE;
  RN := RecordNumber;
  ReOpenTable;
  if RN >= RecordCount then
     RN := RecordCount;
  RecordState := tsPos;
  try
    SettoSeqNo(RN+1);
  except
  end;
end;

Procedure TNativeDataSet.ForceRecordReread(pRecBuff: Pointer);
begin
  ForceReread;
  GetRecord(dbiNOLOCK,pRecBuff, NIL);
end;

Procedure TNativeDataSet.CompareBookMarks( pBookMark1, pBookMark2 : Pointer; var CmpBkmkResult : CmpBkmkRslt );

  function cmp2Values(val1, val2: LongInt): CmpBkmkRslt;
  begin
     if val1=val2 then result:=CMPEql else
     if val1 < val2 then result:=CMPLess else
        result:=CMPGtr;
  end;

begin
  CheckParam(pBookMark1=nil,DBIERR_INVALIDPARAM);
  CheckParam(pBookMark2=nil,DBIERR_INVALIDPARAM);
  If (TmySQLBookMark(pBookMark1^).Position <> -1) then
    CmpBkMkResult:=cmp2Values( TmySQLBookMark(pBookMark1^).Position, TmySQLBookMark(pBookMark2^).Position) else
    CmpBkMkResult := CMPGtr;
end;

Procedure TNativeDataSet.InitRecord(PRecord : Pointer);
begin
  If PRecord = nil then Raise EmySQLException.CreateBDE(DBIERR_INVALIDPARAM);
  ZeroMemory(PRecord, GetWorkBufferSize);
  FFieldDescs.SetFields(PRecord);
  CurrentBuffer := PRecord;
end;

function TNativeDataSet.CheckUniqueKey(var KeyNumber : integer): Boolean;
var
  I: Integer;
  Item : TmySQLIndex;
begin
  Result := False;
  for I := 1 to FindexDescs.Count do
  begin
    Item := FIndexDescs.mIndex[I];
    if Item.Primary or Item.Unique then
    begin
        Result := True;
        KeyNumber := I;
        Break;
    end;
  end;
end;

procedure TNativeDataSet.GetKeys(Unique: Boolean; var FieldList: TFieldArray; var FieldCount: Integer);
var
  I, N: Integer;
  Item : TmySQLIndex;
  Fld  : TmySQLField;
begin
  N := -1;
  FieldCount := 0;
  //Search for PrimaryKey
  for I := 1 to FindexDescs.Count do
  begin
    Item := FIndexDescs.mIndex[I];
    if Item.Primary then
    begin
       N := I;
       Break;
    end;
  end;
  if N = -1 then
     //Primary key not found.
     //Search for Unique Key
     for I := 1 to FindexDescs.Count do
     begin
        Item := FIndexDescs.mIndex[I];
        if Item.Unique then
        begin
           N := I;
           break;
        end;
     end;
  if N >= 0 then
  begin
    Item := FindexDescs.mIndex[N];
    for I := 0 to Item.FldsInKey-1 do
    begin
       FieldList[FieldCount] := Item.FDesc.aiKeyFld[I];
       Inc(FieldCount);
    end;
  end
  else
  if not Unique then
  begin
     for I := 1 to FFieldDescs.Count do
    begin
      Fld := FFieldDescs.Field[I];
      if not(Fld.FieldType in [fldBlob]) then
      begin
        if Fld.FDesc.bCalcField then continue;
		  FieldList[FieldCount] := I;
        Inc(FieldCount);
      end;
    end;
  end;
end;

function TNativeDataSet.GetDeleteSQL(Table: string; PRecord: Pointer): string;
var
  I          : Integer;
  FieldList  : TFieldArray;
  FieldCount : Integer;
  Fld        : TmySQLField;
  Src        : Pointer;
  FldDefs    : PMYSQL_FIELDDEF;

function StrValue(P : Pointer):String;
var
   Buffer : PChar;
   SZ : Integer;
   S : String;
begin
    Result := '';
    if P <> nil then
    begin
      SZ := StrLen(PChar(P));  //Get Length
      GetMem(Buffer, SZ+1);    //Allocate Buffer Size+1 for null char
      ZeroMemory(Buffer,SZ+1);  // Zero Buffer
      Move(P^,Buffer^,SZ+1);   //Move From P to Buffer size = SZ+1
      SetString(S,Buffer,SZ);  //Set String
      Result := EscapeStr(S);  // Escape string
      FreeMem(Buffer, SZ+1);
    end;
end;

begin
  Result := '';
  GetKeys(False, FieldList, FieldCount);
  for I := 0 to FieldCount-1 do
  begin
    Fld := FFieldDescs.Field[FieldList[I]];
	 Fld.Buffer:= PRecord;
    Src := Fld.FieldValue;
    Inc(PChar(Src));
    if Result <> '' then  Result := Result + ' AND ';
    if Fld.FieldNull then
    begin
       FldDefs := GetFieldInfo(Fld.FieldNumber-1);
       if FldDefs <> nil then
          if IsNotNull(FldDefs) then
             Result := Result +GetFldName(Fld) + '=''''' else
             Result := Result +GetFldName(Fld) + ' IS NULL';
    end else
       case Fld.FieldType of
         fldINT16:   Result := Result + GetFldName(Fld) + '=' + IntToStr(SmallInt(Src^));
         fldUINT16:  Result := Result + GetFldName(Fld) + '=' + IntToStr(Word(Src^));
         fldINT32:   Result := Result + GetFldName(Fld) + '=' + IntToStr(LongInt(Src^));
         fldUINT32:  Result := Result + GetFldName(Fld) + '=' + IntToStr(LongInt(Src^));
         fldINT64:   Result := Result + GetFldName(Fld) + '=' + IntToStr(Int64(Src^));
         fldFloat:   Result := Result + GetFldName(Fld) + '=' + SQLFloatToStr(Double(Src^));
         fldZSTRING: Result := Result + GetFldName(Fld) + '=' + ''''+StrValue(Src)+'''';
         fldDate:    Result := Result + GetFldName(Fld) + '='''+ DateTimeToSqlDate(TDateTime(Src^),1)+ '''';
         fldTime:    Result := Result + GetFldName(Fld) + '='''+ DateTimeToSqlDate(TDateTime(Src^),2)+ '''';
        fldTIMESTAMP:Result := Result + GetFldName(Fld) + '='''+ DateTimeToSqlDate(TDateTime(Src^),0)+ '''';
         fldBool:    Result := Result + GetFldName(Fld) + '=' + ''''+BoolToStr(SmallInt(Src^),Fld.FEnum_Val)+'''';
       end;
  end;
  if Result <> '' then  Result := 'DELETE FROM ' + Table + ' WHERE ' + Result;
end;

function TNativeDataSet.GetInsertSQL(Table: string; PRecord: Pointer): string;
var
  I      : Integer;
  Fld    : TmySQLField;
  Src    : Pointer;
  Fields : String;
  Values : String;

function StrValue(P : Pointer):String;
var
   Buffer : PChar;
   SZ : Integer;
	S :  String;
begin
    Result := '';
    if P <> nil then
    begin
      SZ := StrLen(PChar(P));
      GetMem(Buffer, SZ+1);
      ZeroMemory(Buffer,SZ+1);
      Move(P^,Buffer^,SZ+1);
      SetString(S,Buffer,SZ);
      Result := EscapeStr(S);
      FreeMem(Buffer, SZ+1);
    end;
end;

function BlobValue(P : Pointer):String;
var
   Buffer : PChar;
   SZ : Integer;
   S  : String;
begin
    Result := '';
    if TBlobItem(P^).Blob <> nil then
    begin
      if TBlobItem(P^).Blob.Size = 0 then exit;
      SZ := TBlobItem(P^).Blob.Size;
      if SZ > FLD.NativeSize then  mySQLExceptionMsg(FConnect,'Image size exceeds maximum blob field size');
      GetMem(Buffer, SZ);
      ZeroMemory(Buffer,SZ);
      TBlobItem(P^).Blob.Seek(0,0);
      TBlobItem(P^).Blob.Read(Buffer^, SZ);
      SetString(S,Buffer,SZ);
      Result := EscapeStr(S);
      FreeMem(Buffer, SZ);
    end;
end;

begin
  Result := '';
  Fields := '';
  for I := 1 to FFieldDescs.Count do
  begin
    Fld := FFieldDescs.Field[I];
    Fld.Buffer:= PRecord;
    if Fld.FieldNull then continue;
    Src := Fld.FieldValue;
    Inc(PChar(Src));
    Fields := Fields + Fld.FieldName+', ';
    case Fld.FieldType of
         fldINT16:   Values := Values + IntToStr(SmallInt(Src^))+', ';
         fldUINT16:  Values := Values + IntToStr(Word(Src^))+', ';
         fldINT32:   Values := Values + IntToStr(LongInt(Src^))+', ';
         fldUINT32:  Values := Values + IntToStr(LongInt(Src^))+', ';
         fldINT64:   Values := Values + IntToStr(Int64(Src^))+', ';
         fldFloat:   Values := Values + SQLFloatToStr(Double(Src^))+', ';
         fldZSTRING: if Fld.NativeType = FIELD_TYPE_SET then
                        Values := Values + IntToStr(GetNumFromSet(Fld.Enum_Value,StrValue(Src)))+', ' else
                        Values := Values + ''''+StrValue(Src)+''''+', ';
         fldBLOB:    Values := Values + '''' + BlobValue(Src)+ ''''+', ';
         fldDate:    Values := Values + ''''+ DateTimeToSqlDate(TDateTime(Src^),1)+ ''''+', ';
         fldTime:    Values := Values + ''''+ DateTimeToSqlDate(TDateTime(Src^),2)+ ''''+', ';
         fldTIMESTAMP:Values := Values + ''''+ DateTimeToSqlDate(TDateTime(Src^),0)+ ''''+', ';
         fldBool:    Values := Values + ''''+BoolToStr(SmallInt(Src^),Fld.FEnum_Val)+''''+', ';
    end;
  end;
  Delete(Fields,Length(Fields)-1,2);
  Delete(Values,Length(Values)-1,2);
  if (Fields <> '') and (Values <> '') then
     Result := 'INSERT INTO ' + Table + ' (' + Fields + ') VALUES ('+Values+')';
end;

function TNativeDataSet.GetUpdateSQL(Table: string; OldRecord,PRecord: Pointer): String;
var
  I          : Integer;
  Fld        : TmySQLField;
  Src        : Pointer;
  Where      : String;
  Values     : String;

function StrValue(P : Pointer):String;
var
   Buffer : PChar;
	SZ : Integer;
   S  : String;
begin
    Result := '';
    if P <> nil then
    begin
      SZ := StrLen(PChar(P));
      GetMem(Buffer, SZ+1);
      ZeroMemory(Buffer,SZ+1);
      Move(P^,Buffer^,SZ+1);
      SetString(S,Buffer,SZ);
      Result := EscapeStr(S);
      FreeMem(Buffer, SZ+1);
    end;
end;

function BlobValue(P : Pointer):String;
var
   Buffer : PChar;
   SZ : Integer;
   S : String;
begin
    Result := '';
    if TBlobItem(P^).Blob <> nil then
    begin
      if TBlobItem(P^).Blob.Size = 0 then exit;
      SZ := TBlobItem(P^).Blob.Size;
      if SZ > FLD.NativeSize then  mySQLExceptionMsg(FConnect,'Image size exceeds maximum blob field size');
      GetMem(Buffer, SZ);
      ZeroMemory(Buffer,SZ);
      TBlobItem(P^).Blob.Seek(0,0);
      TBlobItem(P^).Blob.Read(Buffer^, SZ);
      SetString(S,Buffer,SZ);
      Result := EscapeStr(S);
      FreeMem(Buffer, SZ);
    end;
end;

function GetWHERE(P : Pointer) : String;
var
  I          : Integer;
  FieldList  : TFieldArray;
  FieldCount : Integer;
  Fld        : TmySQLField;
  Src        : Pointer;
  Where      : String;
  FldDefs    : PMYSQL_FIELDDEF;
begin
  Result := '';
  GetKeys(False, FieldList, FieldCount);
  Where := '';
  for I := 0 to FieldCount-1 do
  begin
    Fld := FFieldDescs.Field[FieldList[I]];
    Fld.Buffer:= P;
    Src := Fld.FieldValue;
    Inc(PChar(Src));
    if Where <> '' then  Where := Where+' AND ';
    if Fld.FieldNull then
    begin
       FldDefs := GetFieldInfo(Fld.FieldNumber-1);
       if FldDefs <> nil then
          if IsNotNull(FldDefs) then
             Where := Where +GetFldName(Fld)+ '=''''' else
             Where := Where +GetFldName(Fld)+ ' IS NULL' else
    end else
       case Fld.FieldType of
         fldINT16:    Where := Where + GetFldName(Fld) + '=' + IntToStr(SmallInt(Src^));
         fldUINT16:   Where := Where + GetFldName(Fld) + '=' + IntToStr(Word(Src^));
         fldINT32:    Where := Where + GetFldName(Fld) + '=' + IntToStr(LongInt(Src^));
         fldUINT32:   Where := Where + GetFldName(Fld) + '=' + IntToStr(LongInt(Src^));
         fldINT64:    Where := Where + GetFldName(Fld) + '=' + IntToStr(Int64(Src^));
         fldFloat:    Where := Where + GetFldName(Fld) + '=' + SQLFloatToStr(Double(Src^));
         fldZSTRING:  Where := Where + GetFldName(Fld) + '=' + ''''+StrValue(Src)+'''';
         fldDate:     Where := Where + GetFldName(Fld) + '='''+ DateTimeToSqlDate(TDateTime(Src^),1)+ '''';
         fldTime:     Where := Where + GetFldName(Fld) + '='''+ DateTimeToSqlDate(TDateTime(Src^),2)+ '''';
         fldTIMESTAMP:Where := Where + GetFldName(Fld) + '='''+ DateTimeToSqlDate(TDateTime(Src^),0)+ '''';
         fldBool:     Where := Where + GetFldName(Fld) + '=' + ''''+BoolToStr(SmallInt(Src^), Fld.FEnum_Val)+'''';
       end;
  end;
  if Where <> '' then
     Result := ' WHERE '+Where else
	  Result := '';

end;

begin
  Result :='';
  Where := GetWhere(OldRecord);
  for I := 1 to FFieldDescs.Count do
  begin
    Fld := FFieldDescs.Field[I];
    Fld.Buffer:= PRecord;
    if not Fld.FieldChanged then continue;
    Src := Fld.FieldValue;
    Inc(PChar(Src));
    case Fld.FieldType of
         fldINT16:   begin
                        if Fld.FieldNull then
                           Values := Values+GetFldName(Fld)+'=NULL, ' else
                           Values := Values+GetFldName(Fld)+'='+IntToStr(SmallInt(Src^))+', ';
                     end;
         fldUINT16:  begin
                        if Fld.FieldNull then
                           Values := Values+GetFldName(Fld)+'=NULL, ' else
                           Values := Values+GetFldName(Fld)+'='+IntToStr(Word(Src^))+', ';
                     end;

         fldINT32:   begin
                        if Fld.FieldNull then
                           Values := Values+GetFldName(Fld)+'=NULL, ' else
                           Values := Values+GetFldName(Fld)+'=' + IntToStr(LongInt(Src^))+', ';
                     end;
         fldUINT32:  begin
                        if Fld.FieldNull then
                           Values := Values+GetFldName(Fld)+'=NULL, ' else
                           Values := Values+GetFldName(Fld)+'=' + IntToStr(LongInt(Src^))+', ';
                     end;
         fldINT64:   begin
                        if Fld.FieldNull then
                           Values := Values+GetFldName(Fld)+'=NULL, ' else
                           Values := Values+GetFldName(Fld)+'=' + IntToStr(Int64(Src^))+', ';
                     end;
			fldFloat:   begin
                        if Fld.FieldNull then
                           Values := Values+GetFldName(Fld)+'=NULL, ' else
                           Values := Values+GetFldName(Fld)+'=' + SQLFloatToStr(Double(Src^))+', ';
                     end;
         fldBLOB:    begin
                        if Fld.FieldNull then
                           Values := Values+GetFldName(Fld)+'=NULL, ' else
                           Values := Values+GetFldName(Fld)+'=' + '''' + BlobValue(Src)+ ''''+', ';
                     end;
         fldZSTRING: begin
                        if Fld.FieldNull then
                           Values := Values+GetFldName(Fld)+'=NULL, ' else
                           if Fld.NativeType = FIELD_TYPE_SET then
                              Values := Values+GetFldName(Fld)+'=' + IntToStr(GetNumFromSet(Fld.Enum_Value,StrValue(Src)))+', ' else
                              Values := Values+GetFldName(Fld)+'=' + ''''+StrValue(Src)+''''+', ';
                     end;
         fldDate:    begin
                        if Fld.FieldNull then
                           Values := Values+GetFldName(Fld)+'=NULL, ' else
                           Values := Values+GetFldName(Fld)+'=' + ''''+ DateTimeToSqlDate(TDateTime(Src^),1)+ ''''+', ';
                     end;
         fldTime:    begin
                        if Fld.FieldNull then
                           Values := Values+GetFldName(Fld)+'=NULL, ' else
                           Values := Values+GetFldName(Fld)+'=' + ''''+ DateTimeToSqlDate(TDateTime(Src^),2)+ ''''+', ';
                     end;
         fldTIMESTAMP:begin
                        if Fld.FieldNull then
                           Values := Values+GetFldName(Fld)+'=NULL, ' else
                           Values := Values+GetFldName(Fld)+'=' + ''''+ DateTimeToSqlDate(TDateTime(Src^),0)+ ''''+', ';
                      end;
         fldBool:     begin
                        if Fld.FieldNull then
                           Values := Values+GetFldName(Fld)+'=NULL, ' else
                           Values := Values + GetFldName(Fld) + '=' + ''''+BoolToStr(SmallInt(Src^),Fld.FEnum_Val)+''''+', ';
                      end;
    end;
  end;
  Delete(VALUES,Length(Values)-1,2);
  if VALUES <> '' then
	  Result := 'UPDATE ' + Table + ' SET '+Trim(VALUES)+Where else
     Result := '';
end;

Procedure TNativeDataSet.AppendRecord (PRecord : Pointer);
begin
  InsertRecord(dbiNOLOCK, PRecord);
end;

Procedure TNativeDataSet.InsertRecord( eLock : DBILockType; PRecord : Pointer );
var
  SQL : String;
  ATable : String;
  KN : Integer;
  A : Boolean;
  oldFlag : Boolean;
begin
  KN := -1;
  if FOMode = dbiREADONLY then
     Raise EMySQLException.CreateBDE(DBIERR_TABLEREADONLY);
  CheckUniqueKey(KN);
  if SQLQuery <> '' then
     ATable := GetTable(SQLQuery) else
     ATable := TableName;
  SQL := GetINSERTSQL(ATable,PRecord);
  try
    if Sql <> '' then
    begin
       FConnect.Handle.query(SQL,True,a);
       if a then
       begin
          FAffectedRows := FConnect.Handle.AffectedRows;
          FLastInsertID := FConnect.Handle.LastInsertId;
       end;
       FConnect.CheckResult;
       RecordState := tsEmpty;
    end;
  except
    FReFetch := False;
    raise;
  end;
  if not FReFetch then
  begin
     oldFlag := isQuery;
     ReOpenTable;
     isQuery := oldFlag;
     RecordState := tsPos;
     try
       if not SetRowPosition(KN,FLastInsertID,PRecord) then
          SettoSeqNo(RecordCount);
     except
     end;
  end;
  FIsLocked := FALSE;
end;

Procedure TNativeDataSet.ModifyRecord(OldRecord,PRecord : Pointer; bFreeLock : Bool);
var
  SQL : String;
  ATable : String;
  KN : Integer;
  A : Boolean;
  oldFlag : Boolean;
begin
  KN := -1;
  if FOMode = dbiREADONLY then
      Raise EMySQLException.CreateBDE(DBIERR_TABLEREADONLY);
  CheckUniqueKey(KN);
  if SQLQuery <> '' then
     ATable := GetTable(SQLQuery) else
     ATable := TableName;
  SQL :=Trim(GetUpdateSQL(ATable,OldRecord,PRecord));
  try
    if Sql <> '' then
    begin
       FConnect.Handle.query(SQL,True,a);
       if a then
          FAffectedRows := FConnect.Handle.AffectedRows;
       FConnect.CheckResult;
    end;
  except
    FReFetch := False;
	 raise;
  end;
  if FAffectedRows > 0 then
  begin
     if not FReFetch then
     begin
        oldFlag := isQuery;
        ReOpenTable;
        isQuery := oldFlag;
        try
          if not SetRowPosition(KN,0,PRecord) then
             SettoSeqNo(FRecNo+1);
        except
        end;
     end;
  end;
  FIsLocked := FALSE;
end;

Procedure TNativeDataSet.DeleteRecord(PRecord : Pointer);
var
  SQL : String;
  ATable : String;
  RN : LongInt;
  KN : Integer;
  A : Boolean;
begin
  KN := -1;
  if FOMode = dbiREADONLY then
      Raise EMySQLException.CreateBDE(DBIERR_TABLEREADONLY);
  CheckUniqueKey(KN);
  if SQLQuery <> '' then
     ATable := GetTable(SQLQuery) else
     ATable := TableName;
  SQL :=GetDeleteSQL(ATable,PRecord);
  if Sql <> '' then
  begin
       FConnect.Handle.query(SQL,True,a);
       if a then
          FAffectedRows := FConnect.Handle.AffectedRows;
       FConnect.CheckResult;
		RecordState := tsEmpty;
  end;
  if not FReFetch then
  begin
     RN := RecordNumber;
     ReOpenTable;
     if RN >= RecordCount then
        RN := RecordCount-1;
     RecordState := tsPos;
     try
       SettoSeqNo(RN+1);
     except
     end;
  end;
  FIsLocked := FALSE;
end;

Function TNativeDataSet.GetTableName : PChar;
begin
  Result := @FBaseDesc.szName;
end;

Procedure TNativeDataSet.SetTableName(Name : PChar);
begin
  If Assigned(Name) then
    With FBaseDesc Do StrLCopy(@szName,Name,SizeOf(szName)-1);
end;

function TNativeDataSet.GetSQLClause: PChar;
var
  BufLen: Word;
  StrEnd: PChar;
  StrBuf: array[0..1024] of Char;

Procedure SetBufLen(Strings : TStrings);
var
  i : Integer;
begin
    for i := 0 to Strings.Count-1 do
     Inc(BufLen, Succ(Length(Strings[I])));
end;

Procedure CopyToBuffer(Strings : TStrings);
var
   i : Integer;
begin
    for i := 0 to Strings.Count-1 do
    begin
      StrPCopy( StrBuf, Strings[I]);
      StrEnd := StrECopy(StrEnd, StrBuf);
      StrEnd := StrECopy(StrEnd, ' ');
    end;
end;

begin
  BufLen     := 1;
  SetBufLen(StandartClause);
  SetBufLen(RangeClause);
  SetBufLen(OrderClause);
  SetBufLen(limitClause);
  Result := StrAlloc(BufLen);
  try
    StrEnd := Result;
    CopyToBuffer(StandartClause);
    CopyToBuffer(RangeClause);
    CopyToBuffer(OrderClause);
    CopyToBuffer(limitClause);
  except
    StrDispose(Result);
    Raise;
  end;
end;

Function TNativeDataSet.GetIndexCount : Integer;
var
//  IndexTable :TNativeDataSet;
  i: Integer;
  ATableName : String;
  aPrim,aUniq,aSort : Boolean;
  //New
  Stmt : TmySQLResult;
  S    : String;
  A    : Boolean;
begin
  Result :=0;
  if FIndexDescs.Count = 0 then
  begin
    if SQLQuery <> ''then
       ATableName := GetTable(SQLQuery)  else
       ATableName := TableName;
    if ATableName = '' then Exit;
    if ServerVersion > 32306 then
    begin
       if Pos('`',ATableName)=0 then
          ATableName := '`'+ATableName+'`';
    end;
    S := Format('SHOW INDEX FROM %s',[ATableName]);
    Stmt:= FConnect.Handle.query(S,True,a);
    if a then
    begin
       if Assigned(Stmt) then
       begin
          Stmt.First;
          for I := 0 to Stmt.RowsCount-1 do
          begin
              try
                aPrim := False;
                if Stmt.FieldValue(1) = '0' then
                begin
                   if CompareBegin(Stmt.FieldValue(2),'PRIMARY') then
                   begin
                      aPrim := true;
                      if FPrimaryKeyNumber = 0 then FPrimaryKeyNumber := I;
                   end;
                   aUniq := True;
                end else
                begin
                   aPrim := False;
                   aUniq := False;
                end;
                if Stmt.FieldValue(5) = 'A' then aSort := False else aSort := True;
                FIndexDescs.SetIndex(Stmt.FieldValue(2),Stmt.FieldValue(4),aPrim,aUniq,aSort);
                Stmt.Next;
				  except
              end;
          end;
       end else FConnect.CheckResult;
    end;// else FConnect.CheckResult;
    if Stmt <> nil then
       Stmt.Free;
  end;
  Result := FIndexDescs.Count;
end;

Procedure TNativeDataSet.OpenBlob(PRecord: Pointer;FieldNo: Word;eOpenMode: DBIOpenMode);
var
  Field : TmySQLField;
begin
  Field := Fields[FieldNo];
  CheckParam(Field.FieldType <> fldBLOB,DBIERR_NOTABLOB);
end;

Procedure TNativeDataSet.FreeBlob(PRecord: Pointer;FieldNo: Word);
Var
  Field : TmySQLField;
  Buff : Pointer;
begin
  Field := Fields[FieldNo];
  CheckParam(Field.FieldType <> fldBLOB,DBIERR_NOTABLOB);
  Field.Buffer := PRecord;
  if not Field.FieldNull then
  begin
    Buff := Field.FieldValue;
    if PChar(Buff)^=#1 then
    begin
       Inc(Pchar(Buff));
       if TBlobItem(Buff^).Blob <> nil then
       begin
          TBlobItem(Buff^).Blob.Free;
          TBlobItem(Buff^).Blob := nil;
       end;
    end;
  end;
end;

Procedure TNativeDataSet.GetBlobSize(PRecord : Pointer; FieldNo : Word; var iSize : Longint);
Var
  Field : TmySQLField;
  Buff : Pointer;
begin
  Field := Fields[FieldNo];
  CheckParam(Field.FieldType <> fldBLOB,DBIERR_NOTABLOB);
  Field.Buffer := PRecord;
  if not Field.FieldNULL then
  begin
      Buff := Field.FieldValue;
      if PChar(Buff)^=#1 then
      begin
         Inc(Pchar(Buff));
         iSize := TBlobItem(Buff^).Blob.Size;
      end else
      begin
         if FieldBuffer(FieldNo-1) = nil then
            iSize := 0 else
            try
              iSize := StrBufSize(FieldBuffer(FieldNo-1))-1;
            except
              iSize := 0;
            end;
      end;
  end else iSize := 0;
end;

Procedure TNativeDataSet.GetBlob(PRecord: Pointer; FieldNo: Word;
  iOffSet: Longint; iLen: Longint; pDest: Pointer;  var iRead : Longint);

var
  Field : TmySQLField;

  Function BlobGet(ColumnNumber: Integer; Offset,Length: LongInt; buff,Dest: pointer): LongInt;
  var
    I : LongInt;
  begin
     if PChar(buff)^ = #1 then
     begin
		  Inc(PChar(buff));
        with TBlobItem(buff^) do
        begin
           Blob.Seek(Offset, 0);
           Result := Blob.Read(Dest^, Length);
        end;
     end else
     begin
        Move(PChar(FieldBuffer(ColumnNumber-1)+Offset)^,Dest^,Length);
        I := StrBufSize(FieldBuffer(ColumnNumber-1))-1;
        if (Offset + Length >= I) then
           Result := I - Offset else
           Result := Length;
     end;
  end;

begin //TNativeDataSet.GetBlob
  iRead  := 0;
  If Assigned(pDest) and (iLen > 0) then
  begin
    Field := Fields[FieldNo];
    CheckParam(Field.FieldType <> fldBLOB,DBIERR_NOTABLOB);
    Field.Buffer := PRecord;
    if not Field.FieldNull then
      iRead := BlobGet(FieldNo, iOffset, iLen, Pchar(Field.Data)+Field.FieldNumber-1, pDest);
  end;
end;

Procedure TNativeDataSet.PutBlob(PRecord: Pointer;FieldNo: Word;iOffSet: Longint;iLen: Longint; pSrc : Pointer);
var
  Field : TmySQLField;

Procedure BlobPut(ColumnNumber: Integer; Offset, Length : LongInt; pSrc, buff :Pointer);
begin
  if PChar(buff)^ = #0 then
  begin
    PChar(buff)^ := #1;
    Inc(PChar(buff));
    TBlobItem(buff^).Blob := TMemoryStream.Create;
  end else
    Inc(PChar(buff));
  with TBlobItem(buff^) do
  begin
    Blob.Seek(Offset, 0);
    If Length > 0 then
      Blob.Write(pSrc^, Length) else
      if Offset = 0 then Blob.Clear;
  end;
end;

begin
  Field := Fields[FieldNo];
  CheckParam(Field.FieldType <> fldBLOB,DBIERR_NOTABLOB);
  Field.Buffer := PRecord;
  BlobPut(FieldNo, iOffset, iLen, pSrc, Pchar(Field.Data) + Field.FieldNumber-1);
  Field.FieldChanged := True;
  Field.FieldNull := (iOffset + iLen = 0);
end;

Procedure TNativeDataSet.TruncateBlob(PRecord : Pointer; FieldNo : Word; iLen : Longint);
begin
   PutBlob(PRecord, FieldNo, 0, iLen, nil);
end;

procedure TNativeDataSet.QuerySetParams(Params : TParams; SQLText : String);
var
  Token, Temp, Value: string;
  ParamValue: Variant;
  FldType : TFieldType;

function StrValue(P : String):String;
var
   Buffer : PChar;
   SZ : Integer;
   S : String;
begin
    Result := '';
    if P <> '' then
    begin
      SZ := Length(P);  //Get Length
      GetMem(Buffer, SZ);    //Allocate Buffer Size+1 for null char
      ZeroMemory(Buffer,SZ);  // Zero Buffer
		Move(PChar(P)^,Buffer^,SZ);   //Move From P to Buffer size = SZ+1
      SetString(S,Buffer,SZ);  //Set String
      Result := EscapeStr(S);  // Escape string
      FreeMem(Buffer, SZ);
    end;
end;

begin
  Temp := '';
  while SQLText <> '' do
  begin
    if (Temp <> '') and (SQLText[1] in [' ',#9]) then Temp := Temp + ' ';
    GetToken(SQLText, Token);
    if Token = ':' then
    begin
      GetToken(SQLText, Token);
      if (Token <> '') and (Token[1] = '[') then
      begin
         if Token[Length(Token)] = ']' then
            Token := Copy(Token, 2, Length(Token)-2) else
            Token := Copy(Token, 2, Length(Token)-1);
      end else
      if (Token <> '') and (Token[1] in ['"','''']) then
      begin
         if Token[1] = Token[Length(Token)] then
            Token := Copy(Token, 2, Length(Token)-2) else
            Token := Copy(Token, 2, Length(Token)-1);
      end;
      FldType := Params.ParamByName(Token).DataType;
      ParamValue := Params.ParamValues[Token];
      case VarType(ParamValue) of
         varEmpty,
         varNull     : Value := 'NULL';
         varSmallint,
         varInteger,
         varByte     : Value := IntToStr(ParamValue);
         varSingle,
         varDouble,
         varCurrency : Value := SQLFloatToStr(VarAsType(ParamValue, varDouble));
         varDate     : begin
                          case FldType of
									 ftDate     : Value := '''' + DateTimeToSqlDate(ParamValue,1) + '''';
                            ftTime     : Value := '''' + DateTimeToSqlDate(ParamValue,2) + '''';
                            ftDateTime : Value := '''' + DateTimeToSqlDate(ParamValue,0) + '''';
                          end;
                       end;
         varBoolean  : if ParamValue then Value := '''Y''' else Value := '''N''';
      else
         begin
            if FldType = ftBlob then
                 Value := Params.ParamByName(Token).AsString else
                 Value := VarAsType(ParamValue, varString);
            Value := '''' + StrValue(Value) + '''';
         end;
      end;
      Temp := Temp + Value;
    end else
      Temp := Temp + Token;
  end;
  SQLQuery := Trim(Temp);
end;

Procedure TNativeDataSet.RelRecordLock(bAll: Bool);
begin
  FIsLocked := FALSE;
end;

Procedure TNativeDataSet.ExtractKey(PRecord: Pointer;pKeyBuf: Pointer);
var
  i : Word;
  MKey    : PChar;
  Field   : TmySQLField;
  bBlank  : bool;
  Buffer  : Array[0..255] of Char;
  iFields : Word;
begin
  if not Assigned(PRecord) then PRecord := CurrentBuffer;
  ZeroMemory(pKeyBuf, FKeyDesc.iKeyLen);
  MKey := pKeyBuf;
  iFields := FKeyDesc.iFldsinKey;
  For i := 0 to iFields-1 do
  begin
	 Field := Fields[FKeyDesc.aiKeyFld[i]];
    NativeToDelphi(Field, PRecord, @Buffer, bBlank);
   if not bBlank then  AdjustDelphiField(Field,@Buffer, MKey);
   if bBlank then ZeroMemory(MKey, Field.FieldLength);
   Inc(MKey, Succ(Field.FieldLength));
  end;
end;

function TNativeDataSet.SetRowPosition(iFields : Integer; LID : Int64; pRecBuffer : Pointer):Boolean;
var
  FldNo : Integer;
  Field : TMySQLField;
  Item : TmySQLIndex;
  R   : Longint;
  I   : Integer;
  Flds  : array of Integer;
  SFlds : array of String;
  K     : Integer;

//  function FieldVal(FieldNo: Integer; FieldPtr : Pointer):String;
//  var
//     Field : TMySQLField;
//     Blank : Bool;
//     Buff  : array[0..255] of Char;
//     TimeStamp : TTimeStamp;
//     DateD : Double;
//  begin
//     Result := '';
//     Field := Fields[FieldNo];
//     AdjustNativeField(Field,FieldPtr,@Buff,Blank);
//     if Blank then Exit;
//     case Field.FieldType of
//        fldINT16: Result :=  IntToStr(PSmallInt(@Buff)^);
//        fldUINT16: Result := IntToStr(PWord(@Buff)^);
//        fldINT32: Result := IntToStr(PLongInt(@Buff)^);
//       fldUINT32: Result := IntToStr(PLongInt(@Buff)^);
//        fldINT64: Result := IntToStr(PInt64(@Buff)^);
//        fldFLOAT: Result := SQLFloatToStr(PDouble(@Buff)^);
//        fldZSTRING: Result := ''+Trim(uMyDMHelpers.EscapeStr(StrPas(@Buff)))+'';
//        fldBOOL:  Result := ''+BoolToStr(PSmallInt(@Buff)^,Field.FEnum_Val)+'';
//        fldDATE : begin
//                     DWORD(TimeStamp.Date) := PDWORD(@Buff)^;
//                     TimeStamp.Time := 0;
//                     Result := ''+DateTimeToSqlDate(SysUtils.Time+Trunc(TimeStampToDateTime(TimeStamp) + 1E-11),1)+'';
//                  end;
//        fldTIME : begin
//                     DWORD(TimeStamp.Time) := PDWORD(@Buff)^;
//                     TimeStamp.Date := DateDelta;
//                     Result := ''+DateTimeToSqlDate(SysUtils.Date+TimeOf(TimeStampToDateTime(TimeStamp)),2)+'';
//                  end;
//    {$IFDEF DELPHI_6}
//    fldDATETIME : begin
//                      DateD := PDouble(@Buff)^;
//                      Result := ''+DateTimeToSqlDate(TimeStampToDateTime(MSecsToTimeStamp(DateD)),0)+'';
//                   end;
//    {$ENDIF}
//    fldTIMESTAMP : begin
//                      DateD := PDouble(@Buff)^;
//                      Result := ''+DateTimeToSqlDate(TimeStampToDateTime(MSecsToTimeStamp(DateD)),0)+'';
//                   end;
//     else
//        Result := '';
//     end;
//  end;

var
  SS : String;

begin
   if isQuery then iFields := -1;
   if iFields = -1 then
   begin
      K := 1;
      for I := 0 to Fields.Count-1 do
      begin
         Field := Fields[I+1];
         Field.Buffer := pRecBuffer;
         if (Field.FieldType = fldBLOB) or (Field.Description.bCalcField)
             or Field.FieldNull or (Field.NativeType = FIELD_TYPE_TIMESTAMP) then Continue;
         SetLength(Flds,K);
         SetLength(SFlds,K);
         Flds[K-1] := I;
			if (Field.FieldSubType = fldstAUTOINC) and (LID > 0) then
            SFlds[K-1] := IntToStr(LID) else
            SFlds[K-1] := FieldVal(I+1, Field.FieldValue, False);
         Inc(K);
      end;
   end else
   begin
      Item := FIndexDescs.mIndex[iFields];
      SetLength(Flds,Item.Description.iFldsInKey);
      SetLength(SFlds,Item.Description.iFldsInKey);
      for I := 0 to Item.Description.iFldsInKey-1 do
      begin
         FldNo := Item.Description.aiKeyFld[I];
         Field := Fields[FldNo];
         Flds[I] := FldNo-1;
         Field.Buffer := pRecBuffer;
         SS := FieldVal(FldNo, Field.FieldValue, False);
         if SS = '' then
         begin
            if (Field.FieldSubType = fldstAUTOINC) and (LID > 0) then
            SS := IntToStr(LID);
         end;
         SFlds[I] := SS;
      end;
   end;
   FStatement.First;
   R := FStatement.findrows(Flds,SFlds,True,0);
   Result := R <> -1;
   if Result then
      SettoSeqNo(R+1);
end;

Procedure TNativeDataSet.GetRecordForKey(bDirectKey: Bool; iFields: Word; iLen: Word; pKey: Pointer; pRecBuff: Pointer);



  procedure SetToLookupKey;
  var
    FieldPtr : Pointer;
    FldNo : Integer;
    Len : Integer;
	 R   : Longint;
    I   : Integer;
    Field : TMySQLField;
    S : String;
    Flds  : array of Integer;
    SFlds : array of String;
  begin
     S := '';
     Len := 0;
{//old variant
	  SetLength(Flds,iFields);
	  SetLength(SFlds,iFields);
	  for I := 0 to iFields-1 do
	  begin
		  FldNo := FKeyDesc.aiKeyFld[I];
		  Field := Fields[FKeyDesc.aiKeyFld[I]];
		  Flds[I] := FldNo-1;
		  if bDirectKey then
		  begin
			  FieldPtr := pKey;
			  Inc(PChar(FieldPtr),Len + i);
			  SFlds[I] := FieldVal(FldNo, FieldPtr, False);
			  Inc(Len, Field.FieldLength);
		  end else
		  begin
			  Field.Buffer := pKey;
			  SFlds[I] := FieldVal(FldNo, Field.FieldValue, False);
		  end;
	  end;}

      if bDirectKey then
      begin
         SetLength(Flds,FKeyDesc.iFldsinKey);
         SetLength(SFlds,FKeyDesc.iFldsinKey);
         for I := 0 to FKeyDesc.iFldsinKey-1 do
         begin
              FldNo := FKeyDesc.aiKeyFld[I];
              Field := Fields[FKeyDesc.aiKeyFld[I]];
              Flds[I] := FldNo-1;
              FieldPtr := pKey;
              Inc(PChar(FieldPtr),Len + i);
				  SFlds[I] := FieldVal(FldNo, FieldPtr, False);
				  Inc(Len, Field.FieldLength);
		  end;
		end else
		begin
				 SetLength(Flds,iFields);
				 SetLength(SFlds,iFields);
				 for I := 0 to iFields-1 do
				 begin
					 FldNo := FKeyDesc.aiKeyFld[I];
					 Field := Fields[FKeyDesc.aiKeyFld[I]];
                Flds[I] := FldNo-1;
					 Field.Buffer := pKey;
					 SFlds[I] := FieldVal(FldNo, Field.FieldValue, False);
				 end;
		end;

	  FStatement.First;
	  R := FStatement.findrows(Flds,SFlds,True,iLen);
	  CheckParam(R=-1 ,DBIERR_RECNOTFOUND);
	  SettoSeqNo(R+1);
  end;

  procedure SetToMasterKey;
  var
    FieldPtr : Pointer;
    FldNo : Integer;
    Len : Integer;
    R   : Longint;
    I   : Integer;
    Field : TMySQLField;
    S : String;
    Flds  : array of Integer;
    SFlds : array of String;
  begin
     S := '';
     Len := 0;
     //Fit buffer size to fields quatity in Master and lookup cursors indexes (index fields indexes are used)
     SetLength(Flds,TNativeDataSet(MasterCursor).FKeyDesc.iFldsInKey + iFields);
     //Fit buffer size to fields quatity in Master and lookup cursors indexes (index fields values are used)
     SetLength(SFlds,TNativeDataSet(MasterCursor).FKeyDesc.iFldsInKey + iFields);
	  //Set search values for lookup cursor
     for I := 0 to iFields-1 do
     begin
        FldNo := FKeyDesc.aiKeyFld[I];
        Field := Fields[FKeyDesc.aiKeyFld[I]];
        Flds[I] := FldNo-1;
        if bDirectKey then
        begin
           FieldPtr := pKey;
           Inc(PChar(FieldPtr),Len + i);
           SFlds[I] := FieldVal(FldNo, FieldPtr, False);
           Inc(Len, Field.FieldLength);
        end else
        begin
           Field.Buffer := pKey;
           SFlds[I] := FieldVal(FldNo, Field.FieldValue, False);
        end;
     end;
     //Set search values for master cursor
     for I := 0 to  TNativeDataSet(MasterCursor).FKeyDesc.iFldsInKey-1 do
     begin
        FldNo := TNativeDataSet(MasterCursor).FKeyDesc.aiKeyFld[I];
        Field := TNativeDataSet(MasterCursor).Fields[FldNo];
        Flds[iFields+I] := FldNo-1;
        if bDirectKey then
        begin
           FieldPtr := pKey;
           Inc(PChar(FieldPtr),Len + i);
           SFlds[iFields+I] := S+FieldVal(FldNo, FieldPtr, False);
           Inc(Len, Field.FieldLength);
        end else
        begin
           Field.Buffer := pKey;
           SFlds[iFields+i] := FieldVal(FldNo, Field.FieldValue, False);
        end;
     end;

     TNativeDataSet(MasterCursor).FStatement.First;
     R := TNativeDataSet(MasterCursor).FStatement.findrows(Flds,SFlds,True,iLen);
     CheckParam(R=-1 ,DBIERR_RECNOTFOUND);
     TNativeDataSet(MasterCursor).SettoSeqNo(R+1);
  end;

begin
   SetToLookupKey;
   if MasterCursor<> nil then
      SetToMasterKey;
end;

Procedure TNativeDataSet.GetIndexDesc(iIndexSeqNo: Word; var idxDesc: IDXDesc);
begin
  CheckParam(isQuery ,DBIERR_NOASSOCINDEX);
  CheckParam(not(IndexCount > 0) ,DBIERR_NOASSOCINDEX);
  ZeroMemory(@idxDesc, Sizeof(idxDesc));
  If (iIndexSeqNo = 0) and not FGetKeyDesc then
     if KeyNumber <> 0 then iIndexSeqNo := KeyNumber;
  if iIndexSeqNo = 0 then iIndexSeqNo := 1;
  CheckParam(FIndexDescs.mIndex[iIndexSeqNo] = nil,DBIERR_NOSUCHINDEX);
  idxDesc := FIndexDescs.mIndex[iIndexSeqNo].Description;
end;

Procedure TNativeDataSet.GetIndexDescs(Desc: PIDXDesc);
var
  Props : CURProps;
  i     : Word;
  P     : Pointer;
begin
  GetCursorProps(Props);
  If Props.iIndexes > 0 then
  begin
    FGetKeyDesc := TRUE;
    Try
      P := Pointer(Desc);
      for i := 1 to Props.iIndexes do
      begin
        ZeroMemory(P, SizeOf(IDXDesc));
        GetIndexDesc(i, IDXDesc(P^));
        Inc(LongInt(P), SizeOf(IDXDesc));
      end;
    Finally
      FGetKeyDesc := FALSE;
    end;
  end;
end;

Procedure TNativeDataSet.SwitchToIndex( pszIndexName, pszTagName : PChar;iIndexId : Word; bCurrRec : Bool);

Procedure ParseIndexName(pszIndexName: PChar;Var iIndexId : Word;pszTrueName  : PChar);
var
  S     : ShortString;
  Found : Boolean;
  Desc  : IDXDesc;
begin
  Found := False;
  If ( pszIndexName <> NIL ) then s := StrPas( pszIndexName ) else  s := '';
  FGetKeyDesc := TRUE;
  try
     iIndexId := 1;
     Repeat
       GetIndexDesc ( iIndexId, Desc );
       If strLcomp(Desc.szName,pszIndexName,pred(sizeof(Desc.szName)))=0 then
       begin
         Found := TRUE;
         break;
       end;
       Inc(iIndexId);
     Until Found;
     If Found and ( iIndexId > 0 )  and ( pszTrueName <> NIL ) then
       StrLCopy(pszTrueName, @Desc.szName, DBIMAXNAMELEN );
  finally
    FGetKeyDesc := False;
  end;
end;

begin
  FIsLocked := FALSE;
  CheckParam(pszIndexName=nil,DBIERR_INVALIDPARAM);
  if FFieldDescs.Count = 0 then InitFieldDescs;
  if Strlen(pszIndexName) > 0 then
    ParseIndexName(pszIndexName, iIndexId, nil) else
    begin
      if FPrimaryKeyNumber >= 1 then iIndexId:=FPrimaryKeyNumber;
    end;
  try
    if Ranges then ResetRange;
    KeyNumber := iIndexId;
  finally
    AutoReExec := True;
  end;
  GetIndexDesc(iIndexId, FKeyDesc);
end;

Procedure TNativeDataSet.ResetRange;
begin
  RangeClause.Clear;
  if Ranges then ReOpenTable;
  Ranges := False;
end;

Procedure TNativeDataSet.SetRange(bKeyItself: Bool;
               iFields1: Word;iLen1: Word;pKey1: Pointer;bKey1Incl: Bool;
               iFields2: Word;iLen2: Word;pKey2: Pointer;bKey2Incl: Bool);

function FieldVal(FieldNo: Integer; FieldPtr : Pointer):String;
var
   Field : TMySQLField;
   TimeStamp : TTimeStamp;
   DateD : Double;
begin
   Result := '';
   Field := Fields[FieldNo];
   case Field.FieldType of
      fldINT16: Result :=  IntToStr(PSmallInt(FieldPtr)^);
      fldUINT16: Result := IntToStr(PWord(FieldPtr)^);
      fldINT32: Result := IntToStr(PLongInt(FieldPtr)^);
      fldUINT32: Result := IntToStr(PLongInt(FieldPtr)^);
      fldINT64: Result := IntToStr(PInt64(FieldPtr)^);
      fldFLOAT: Result := SQLFloatToStr(PDouble(FieldPtr)^);
      fldZSTRING: Result := ''''+uMyDMHelpers.EscapeStr(StrPas(FieldPtr))+'''';
      fldBOOL:  Result := ''''+BoolToStr(PSmallInt(FieldPtr)^,Field.FEnum_Val)+'''';
      fldDATE : begin
                   DWORD(TimeStamp.Date) := PDWORD(FieldPtr)^;
                   TimeStamp.Time := 0;
                   Result := ''''+DateTimeToSqlDate(SysUtils.Time+Trunc(TimeStampToDateTime(TimeStamp) + 1E-11),1)+'''';
					 end;
      fldTIME : begin
                   DWORD(TimeStamp.Time) := PDWORD(FieldPtr)^;
                   TimeStamp.Date := DateDelta;
                   Result := ''''+DateTimeToSqlDate(SysUtils.Date+TimeOf(TimeStampToDateTime(TimeStamp)),2)+'''';
                end;
  {$IFDEF DELPHI_6}
  fldDATETIME : begin
                    DateD := PDouble(FieldPtr)^;
                    Result := ''''+DateTimeToSqlDate(TimeStampToDateTime(MSecsToTimeStamp(DateD)),0)+'''';
                 end;
  {$ENDIF}
  fldTIMESTAMP : begin
                    DateD := PDouble(FieldPtr)^;
                    Result := ''''+DateTimeToSqlDate(TimeStampToDateTime(MSecsToTimeStamp(DateD)),0)+'''';
                 end;
   else
      Result := '';
   end;
end;

Procedure CreateRangeClause(First : Boolean; bKeyItself: Bool;iFields: Word;iLen: Word; pKey: Pointer; bKeyIncl: Bool);
var
  i         : integer;
  Field     : TmySQLField;
  WHERE     : ShortString;
  FldVal    : ShortString;
  bBlank    : bool;
  Buff : Array[0..255] of Char;
  CurBuffer : PChar;
begin
    WHERE := '';
    CurBuffer:=PChar(pKey);
    For i := 0 to iFields-1 do
    begin
      Field := Fields[FKeyDesc.aiKeyFld[i]];
      if bKeyItself then
        AdjustNativeField(Field, CurBuffer,@Buff, bBlank) else
        NativeToDelphi(Field, CurBuffer, @Buff, bBlank);
      Inc(CurBuffer,Field.FieldLength+1);
      if RangeClause.Count > 0  then WHERE := 'and ' else WHERE := 'where ';
		WHERE := WHERE + Field.FieldName;
      if bKeyIncl then
      begin
        if First then WHERE := WHERE + '>=' else WHERE := WHERE + '<=';
      end else
      begin
        if First then WHERE := WHERE + '>' else WHERE := WHERE + '<';
      end;
      FldVal := FieldVal(Field.FieldNumber, @Buff);
      WHERE := WHERE + Trim(FldVal);
      RangeClause.Add(WHERE);
    end;
end;

begin
  Try
    RangeClause.Clear;
    Ranges := True;
    CreateRangeClause(True,bKeyItself, iFields1, iLen1, pKey1, bKey1Incl);
    CreateRangeClause(False,bKeyItself, iFields2, iLen2, pKey2, bKey2Incl);
    ReOpenTable;
  except
    ResetRange;
  end;
end;

Procedure TNativeDataSet.SetKeyNumber( newValue : SmallInt );
var
  x,y : Integer;
  Ind : TmySQLIndex;

function GetOrderByStr(Idx : TMySQLIndex; index : integer) : String;
var
   B : Boolean;
begin
   result := '';
   B := idx.Descending;
   Result := StrPas(FieldInfo[idx.FDesc.aiKeyFld[index]-1]^.Name);
   if B then
      Result := Result +' DESC';
end;

begin
  if newValue <> FKeyNumber then
  begin
    OrderClause.Clear;
    if  newValue <= IndexCount then
    begin
      OrderClause.Add('ORDER BY ');
      Ind := FIndexDescs.mIndex[newValue];
      y := ind.FDesc.iFldsInKey-1;
      for x := 0 to y-1 do
          OrderClause.Add(GetOrderByStr(Ind, x) + ',');
      OrderClause.Add(GetOrderByStr(Ind, y));
    end;
    FKeyNumber := newValue;
    ReOpenTable;
  end;
end;

Procedure TNativeDataSet.ClearIndexInfo;
begin
  if FIndexDescs.Count > 0  then
     FIndexDescs.Clear;
  FKeyNumber        := 0;
  FPrimaryKeyNumber := 0;
end;

procedure TNativeDataSet.SettoSeqNo(iSeqNo: Longint);
begin
  if iSeqNo <= 0 then
     FRecNo := 0 else
     FRecNo := iSeqNo-1;
  CurrentRecord(FRecNo);
end;

procedure TNativeDataSet.EmptyTable;
var
  S : String;
  A : Boolean;
begin
  S := Format('TRUNCATE TABLE %s',[TableName]);
  FAffectedRows := 0;
  if not Assigned(FConnect) or not (FConnect.FLoggin) then  Exit;
  FConnect.Handle.Query(S,True,A);
  FConnect.CheckResult;
end;

Procedure TNativeDataSet.AddIndex(var IdxDesc: IDXDesc; pszKeyviolName : PChar);
var
  A : Boolean;

 function CreateSQLForAddIndex: String;
 var
   Fld : String;
   MySQLIdxs : TMySQLIndexes;
 begin
   Result := '';
   MySQLIdxs := TmySQLIndexes.Create(nil);
   TmySQLIndex.CreateIndex(MySQLIdxs,@IdxDesc);
   Fld := SQLCreateIdxStr(MySQLIdxs[1],TableName,Fields);
   Result := Result+Fld;
   MySQLIdxs.Free;
 end;

begin
  if not Assigned(FConnect) or not (FConnect.FLoggin) then  Exit;
  FConnect.Handle.query(CreateSQLForAddIndex,True,A);
  FConnect.CheckResult;
end;

Procedure TNativeDataSet.DeleteIndex(pszIndexName: PChar; pszIndexTagName: PChar; iIndexId: Word);
var
  A : Boolean;
begin
  if not Assigned(FConnect) or not (FConnect.FLoggin) then  Exit;
  FConnect.Handle.query(Format('DROP INDEX %s ON %s',[pszIndexName,TableName]),True,A);
  FConnect.CheckResult;
end;

Procedure TNativeDataSet.AcqTableLock(eLockType: DBILockType);
var
  pszLOCK : String;
  A : Boolean;
begin
  if not Assigned(FConnect) or not (FConnect.FLoggin) then  Exit;
  if eLockType = dbiWRITELOCK then
     pszLOCK := 'WRITE' else
     pszLOCK := 'READ';
  FConnect.Handle.query(Format('LOCK TABLES %s %s',[TableName, pszLOCK]),True,A);
  FConnect.CheckResult;
end;

Procedure TNativeDataSet.RelTableLock(bAll: Bool; eLockType: DBILockType);
var
  A : Boolean;
begin
  if not Assigned(FConnect) or not (FConnect.FLoggin) then  Exit;
  FConnect.Handle.query('UNLOCK TABLES',True,A);
  FConnect.CheckResult;
end;

{$HINTS OFF}
Procedure TNativeDataSet.SetToKey(eSearchCond: DBISearchCond; bDirectKey: Bool;iFields: Word;iLen: Word;pBuff: Pointer);
var
  FldNo : Integer;
  Field : TMySQLField;
  Item  : TMySQLIndex;
  R : LongInt;
  I : Integer;
  Flds  : array of integer;
  SFlds : array of String;
  K : Integer;

begin
   Item := FIndexDescs.mIndex[iFields];
   SetLength(Flds,Item.Description.iFldsInKey);
   SetLength(SFlds,Item.Description.iFldsInKey);
   for I :=0 to Item.Description.iFldsInKey-1 do
   begin
      FldNo := Item.Description.aiKeyFld[I];
      Field := Fields[FldNo];
      Flds[i] := FldNo-1;
      SFlds[I] := FieldVal(Field.FieldNumber,Field.FieldValue, False);
	end;
   FStatement.First;
   R := FStatement.findrows(Flds,SFlds,True,ilen);
   if (R <> -1) then
      SetToSeqNo(R+1) else
      SetToSeqNo(RecordCount);
end;
{$HINTS ON}

procedure TNativeDataSet.Clone(bReadOnly : Bool; bUniDirectional : Bool; var hCurNew : hDBICur);
begin
  if FConnect = nil then EmySQLException.CreateBDE(DBIERR_INVALIDHNDL);
  TNativeConnect(FConnect).OpenTable(TableName,FIndexName,0,FOMode,dbiOPENSHARED,hCurNew,0,-1);
  TNativeDataSet(hCurNew).MasterCursor := Self;
end;

Procedure TNativeDataSet.SetToCursor(hDest : hDBICur);
var
  M : Pointer;
begin
  if hDest = nil then EmySQLException.CreateBDE(DBIERR_INVALIDHNDL);
  M := AllocMem(BookMarkSize);
  Try
    if MasterCursor = nil then
    begin
       GetBookMark(M);
       TNativeDataSet(hDest).SetToBookMark(M);
    end;
  Finally
    FreeMem(M, BookMarkSize);
  end;
end;

function TNativeDataSet.GetLastInsertID: Int64;
begin
   Result := FLastInsertId;
end;

function TNativeDataSet.GetRecNo: LongInt;
begin
   Result := -1;
	if Assigned(FStatement) then
      Result := FStatement.RecNo;
end;

Procedure TNativeDataSet.ReadBlock(var iRecords : Longint; pBuf : Pointer);
var
  M     : MemPtr;
  i     : Word;
  Limit : longint;
begin
  Limit     := iRecords;
  iRecords  := 0;
  CheckParam(pBuf= nil,DBIERR_INVALIDPARAM);
  M := pBuf;
  i := 0;
  Repeat
    GetNextRecord(dbiNOLOCK, @M^[ i ], NIL);
    Inc(iRecords);
    if iRecords >= Limit then
      Break else
      Inc(i,GetWorkBufferSize);
  until False;
end;


Procedure TNativeDataSet.WriteBlock(var iRecords : Longint; pBuf : Pointer);
var
  M     : MemPtr;
  i     : Word;
  Limit : longint;
begin
  Limit     := iRecords;
  iRecords  := 0;
  CheckParam(pBuf= nil,DBIERR_INVALIDPARAM);
  M := pBuf;
  i := 0;
  Repeat
    InsertRecord(dbiNOLOCK, @M^[i]);
    Inc(iRecords);
    if iRecords >= Limit then
      Break else
		Inc(i, GetWorkBufferSize);
  until False;
end;

function TNativeDataSet.FieldValueFromBuffer(PRecord: Pointer;
  AFieldName: string; var AFieldType: word): string;
var
  I    : Integer;
  Fld    : TMySQLField;
  Src    : Pointer;

      function StrValue(P : Pointer):String;
      begin
          Result := '';
          if P <> nil then
             Result := StrPas(PChar(P));
      end;

      function BlobValue(P : Pointer):String;
      var
        Buffer : PChar;
        SZ : Integer;
        S  : String;
      begin
         Result := '';
         if TBlobItem(P^).Blob <> nil then
         begin
            if TBlobItem(P^).Blob.Size = 0 then exit;
            SZ := TBlobItem(P^).Blob.Size;
				if SZ > FLD.NativeSize then  mySQLExceptionMsg(FConnect,'Image size exceeds maximum blob field size');
            GetMem(Buffer, SZ);
            ZeroMemory(Buffer,SZ);
            TBlobItem(P^).Blob.Seek(0,0);
            TBlobItem(P^).Blob.Read(Buffer^, SZ);
            SetString(S,Buffer,SZ);
            Result := EscapeStr(S);
            FreeMem(Buffer, SZ);
         end;
      end;



begin
  Result := '';
  for I := 1 to FFieldDescs.Count do
  begin
    Fld := FFieldDescs.Field[I];
    Fld.Buffer:= PRecord;
    If CompareText(Fld.FieldName, AFieldName)<>0 then Continue;
    AFieldType := Fld.FieldType;
    Src := Fld.FieldValue;
    Inc(PChar(Src));
    If Fld.FieldNull then
     AFieldType := MAXLOGFLDTYPES + 1
      //fieldnull
    else
     begin
       case Fld.FieldType of
           fldBOOL:    Result := BoolToStr(SmallInt(Src^),Fld.FEnum_Val);
           fldINT16:   Result := IntToStr(SmallInt(Src^));
           fldUINT16:  Result := IntToStr(Word(Src^));
           fldINT32:   Result := IntToStr(LongInt(Src^));
           fldUINT32:  Result := IntToStr(LongInt(Src^));
           fldINT64:   Result := IntToStr(Int64(Src^));
           fldFloat:   Result := SQLFloatToStr(Double(Src^));
           fldZSTRING: begin
                          if Fld.NativeType = FIELD_TYPE_SET then
                             Result := IntToStr(GetNumFromSet(Fld.Enum_Value,StrValue(Src))) else
                             Result := StrValue(Src);
                       end;
			  fldBLOB:    Result := BlobValue(Src);
			  fldDate:    Result := DateTimeToSqlDate(TDateTime(Src^),1);
			  fldTime:    Result := DateTimeToSqlDate(TDateTime(Src^),2);
			  fldTIMESTAMP:Result := DateTimeToSqlDate(TDateTime(Src^),0);
		 end; //case
	  end; //else
	  Break;
  end;
//  If Result = '' then
//   raise EPSQLException.CreateMsg(FConnect,Format('Cann''t use field "%s" as updatable!',[AFieldName]));
end;

procedure TNativeDataSet.SortBy(FieldNames: string);//mi
var
	Fields : array of integer;
	a, cnt, i : integer;
	str : string;
	IsReverseOrder : array of boolean;
const
	sAsc : string = ' ASC';
	sDesc : string = ' DESC';
begin
	if Trim(FieldNames) = '' then
		exit;

	cnt := 0;

	for i:=1 to Length(FieldNames) do
	begin
		if FieldNames[i] = ',' then Inc(cnt);//count number of fields

		if FieldNames[i] = #9 then
			FieldNames[i] := ' ';//replace TABs to SPACEs
	end;

	SetLength(Fields, cnt + 1);
	SetLength(IsReverseOrder, cnt + 1);

	i := 0;
	if cnt > 0 then//multi-fields sorting
		while Pos(',', FieldNames) <> 0 do
		begin
			a := Pos(',', FieldNames);
			str := Trim(copy(FieldNames, 1, a - 1));
			Delete(FieldNames, 1, a);

			if AnsiUpperCase(copy(str, Length(str) - Length(sDesc) + 1, Length(sDesc))) = sDesc then
			begin
				IsReverseOrder[i] := true;
				Delete(str, Length(str) - Length(sDesc) + 1, Length(sDesc));
			end
			else if AnsiUpperCase(copy(str, Length(str) - Length(sAsc) + 1, Length(sAsc))) = sAsc then
			begin
				IsReverseOrder[i] := false;
				Delete(str, Length(str) - Length(sAsc) + 1, Length(sAsc));
			end
			else
			begin
				IsReverseOrder[i] := false;
			end;

			a := FieldIndex(Trim(str));//trying to find dield in fields definitions
			if a = -1 then
			begin
				raise Exception.Create('Field ''' + str + ''' is not found in current dataset');
				exit;
			end;
			Fields[i] := a;
			Inc(i);
		end;

	//single field sorting   (or last field sorting)
	str := Trim(FieldNames);

	if AnsiUpperCase(copy(str, Length(str) - Length(sDesc) + 1, Length(sDesc))) = sDesc then
	begin
		IsReverseOrder[i] := true;
		Delete(str, Length(str) - Length(sDesc) + 1, Length(sDesc));
	end
	else if AnsiUpperCase(copy(str, Length(str) - Length(sAsc) + 1, Length(sAsc))) = sAsc then
	begin
		IsReverseOrder[i] := false;
		Delete(str, Length(str) - Length(sAsc) + 1, Length(sAsc));
	end
	else
	begin
		IsReverseOrder[i] := false;
	end;

	a := FieldIndex(Trim(str));//trying to find dield in fields definitions
	if a = -1 then
	begin
		raise Exception.Create('Field ''' + str + ''' is not found in current dataset');
		exit;
	end;
	Fields[i] := a;

	FStatement.SortBy(Fields, IsReverseOrder);
end;

//////////////////////////////////////////////////////////////////////
//          TIndexList Object                                       //
//////////////////////////////////////////////////////////////////////
Constructor TIndexList.Create(mySQL: TNativeConnect; D : Pointer; TotalCount : Word );
var
  MemSize : Cardinal;
begin
  Inherited Create(mySQL, nil,nil, nil, 0,0,-1);
  Items   := TotalCount;
  if D <> nil then
  begin
    MemSize := Items * GetWorkBufferSize;
    GetMem( Descs, MemSize );
    If Descs <> nil then Move( D^, Descs^, MemSize );
  end;
  SetToBegin;
end;

Procedure TIndexList.SetToBegin;
begin
  inherited SetToBegin;
  Position := 0;
end;

Destructor TIndexList.Destroy;
begin
  If Descs <> nil  then
    FreeMem(Descs, Items * GetWorkBufferSize);
  Inherited Destroy;
end;

Procedure TIndexList.GetNextRecord(eLock: DBILockType;PRecord  : Pointer;pRecProps : pRECProps);
var
  P : PChar;
begin
  If Position = Items then raise EmySQLException.CreateBDE(DBIERR_EOF) else
  begin
    P := Descs;
    Inc(P, Position * GetWorkBufferSize);
    Move(P^, PRecord^, GetWorkBufferSize);
    Inc(Position);
  end;
end;

Function TIndexList.GetBufferSize : Word;
begin
  Result := SizeOf(idxDESC);
end;

Function TIndexList.GetWorkBufferSize : Word;
begin
  Result := GetBufferSize;
end;

Procedure TIndexList.SetToBookmark(P : Pointer);
begin
	SetToBegin;
end;

Procedure TIndexList.GetRecordCount( Var iRecCount : Longint );
begin
	iRecCount := Items;
end;

Function TFieldList.GetBufferSize : Word;
begin
  Result := SizeOf(FLDDesc);
end;

{******************************************************************************}
{                           TmySQLEngine                                       }
{******************************************************************************}
Constructor TmySQLEngine.Create(P : TObject; Container : TContainer);
begin
  Inherited Create(P, Container);
  FDatabase := hDBIDb(Self);
  FMT := false;
end;

Destructor TmySQLEngine.Destroy;
begin
  FDatabase := nil;
  Inherited Destroy;
end;

Function TmySQLEngine.GetCursor : hDBICur;
begin
  Result := FCursor;
end;

Procedure TmySQLEngine.SetCursor(H : hDBICur);
begin
  If H = nil then  Raise EmySQLException.CreateBDE(DBIERR_INVALIDHNDL);
  FCursor := H;
end;

Function TmySQLEngine.GetDatabase : hDBIDb;
begin
  Result := FDatabase;
end;

Procedure TmySQLEngine.SetDatabase( H : hDBIDb );
begin
  If H = nil then  Raise EmySQLException.CreateBDE(DBIERR_INVALIDHNDL);
  FDatabase := H;
end;

Function TmySQLEngine.GetStatement : hDBIStmt;
begin
  Result := FStatement;
end;

Procedure TmySQLEngine.SetStatement(H : hDBIStmt);
begin
  If H = nil then  Raise EmySQLException.CreateBDE(DBIERR_INVALIDHNDL);
  FStatement := H;
end;

Function TmySQLEngine.IsSqlBased(hDb : hDBIDB) : Boolean;
begin
  Result   := True;
end;

Function TmySQLEngine.OpenDatabase(ConnOptions : TConnectOptions; Params : TStrings; Var hDb : hDBIDb): DBIResult;
Var
  DB : TNativeConnect;
begin
  try
    Db := TNativeConnect.Create(ConnOptions);
    Db.MultiThreaded:= FMT;
    Db.FSSL_Key := SSLKey;
    Db.SSLCert := SSLCert;
    if Db = nil then Raise EmySQLException.CreateBDE(DBIERR_INVALIDHNDL);
    try
      DB.ProcessDBParams(Params);
      Db.InternalConnect;
    except
      on E: EmySQLException do
      begin
         DB.Free;
         Raise;
      end;
    end;
    hDb := hDBIDb(DB);
    Database := hDb;
    Result := DBIERR_NONE;
  except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.CloseDatabase(var hDb : hDBIDb) : DBIResult;
begin
  Try
    Database := hDb;
    TNativeConnect(hDb).Free;
    hDb := nil;
    FDatabase := nil;
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.OpenTable(hDb: hDBIDb;pszTableName: PChar;pszDriverType: PChar;pszIndexName: PChar;pszIndexTagName : PChar;iIndexId: Word;
         eOpenMode: DBIOpenMode;eShareMode: DBIShareMode;exltMode: XLTMode;bUniDirectional : Bool;pOptParams: Pointer;var hCursor: hDBICur;Offset,Limit : Integer): DBIResult;
begin
  Try
    Database := hDb;
    TNativeConnect(hDb).OpenTable(pszTableName,pszIndexName,iIndexId,eOpenMode,eShareMode,hCursor,Offset,Limit);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.OpenTableList(hDb: hDBIDb;pszWild: PChar; Views : Boolean; List : TStrings): DBIResult;
begin
  Try
    Database := hDb;
    TNativeConnect(hDb).TableList(pszWild, Views, List);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.GetNextRecord(hCursor: hDBICur;eLock: DBILockType;pRecBuff : Pointer;pRecProps: pRECProps): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).GetNextRecord(eLock, pRecBuff, pRecProps);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.SetToBookMark(hCur: hDBICur;pBookMark: Pointer) : DBIResult;
begin
  Try
    TNativeDataSet(hCur).SetToBookMark(pBookMark);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.CompareBookMarks(hCur : hDBICur;pBookMark1,pBookMark2 : Pointer;Var CmpBkmkResult : CmpBkmkRslt): DBIResult;
begin
  Try
    TNativeDataSet(hCur).CompareBookMarks(pBookMark1, pBookMark2, CmpBkmkResult);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.GetRecord (hCursor: hDBICur;eLock: DBILockType;PRecord: Pointer;pRecProps: pRECProps): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).GetRecord(eLock,PRecord,pRecProps);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.GetPriorRecord(hCursor: hDBICur;eLock: DBILockType;PRecord: Pointer;pRecProps: pRECProps): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).GetPriorRecord(eLock,PRecord,pRecProps);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
    If Result = DBIERR_EOF then Result := DBIERR_BOF;
  end;
end;

Function TmySQLEngine.GetBookMark(hCur: hDBICur;pBookMark : Pointer) : DBIResult;
begin
  Try
    Cursor := hCur;
    TNativeDataSet(hCur).GetBookMark(pBookMark);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.GetRecordCount(hCursor : hDBICur;Var iRecCount : Longint) : DBIResult;
begin
  Try
    TNativeDataSet(hCursor).GetRecordCount(iRecCount);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.ForceReread(hCursor: hDBICur): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).ForceReread;
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.ForceRecordReread(hCursor: hDBICur; pRecBuff: Pointer): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).ForceRecordReread(pRecBuff);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;


Function TmySQLEngine.GetField(hCursor: hDBICur;FieldNo: Word;PRecord: Pointer;pDest: Pointer;var bBlank: Bool): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).GetField(FieldNo, PRecord, PDest, bBlank);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.CloseCursor(hCursor : hDBICur) : DBIResult;
begin
  Try
    Cursor := hCursor;
    TNativeDataSet(hCursor).CloseTable;

//???:I was comment it on method QFree I'll be really free
//	 if FStatement = nil then
//		 TNativeDataSet(hCursor).Free;

	 FCursor := nil;
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.PutField(hCursor: hDBICur;FieldNo: Word;PRecord: Pointer;pSrc: Pointer): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).PutField(FieldNo,PRecord,PSrc);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.OpenBlob(hCursor: hDBICur;PRecord: Pointer;FieldNo: Word;eOpenMode: DBIOpenMode): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).OpenBlob(PRecord, FieldNo, eOpenMode);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.GetBlobSize(hCursor: hDBICur;PRecord: Pointer;FieldNo: Word;var iSize: Longint): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).GetBlobSize(PRecord, FieldNo, iSize);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.GetBlob(hCursor: hDBICur;PRecord: Pointer;FieldNo: Word;iOffSet: Longint;iLen: Longint;pDest: Pointer;var iRead: Longint): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).GetBlob(PRecord, FieldNo, iOffset, iLen, pDest, iRead);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.PutBlob(hCursor: hDBICur;PRecord: Pointer;FieldNo: Word;iOffSet: Longint;iLen: Longint;pSrc: Pointer): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).PutBlob(PRecord, FieldNo, iOffset, iLen, pSrc);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.TruncateBlob(hCursor: hDBICur;PRecord: Pointer;FieldNo: Word;iLen: Longint): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).TruncateBlob( PRecord, FieldNo, iLen );
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.FreeBlob(hCursor: hDBICur;PRecord: Pointer;FieldNo: Word): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).FreeBlob(PRecord,FieldNo);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.BeginTran(hDb: hDBIDb; eXIL: eXILType; var hXact: hDBIXact): DBIResult;
begin
  Try
    Database := hDb;
    TNativeConnect(hDb).BeginTran(eXIL, hXact);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.EndTran(hDb: hDBIDb;hXact : hDBIXact; eEnd : eXEnd): DBIResult;
begin
  Try
   Database := hDb;
   TNativeConnect(hDb).EndTran(hXact,eEnd);
   Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.GetTranInfo(hDb : hDBIDb; hXact : hDBIXact; pxInfo : pXInfo): DBIResult;
begin
  Try
    Database := hDb;
    TNativeConnect(hDb).GetTranInfo(hXact,pxInfo);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.GetEngProp(hObj: hDBIObj;iProp: Longint;PropValue: Pointer;iMaxLen: Word;var iLen: Word): DBIResult;
begin
  iLen := 0;
  if Assigned( hObj ) then
  begin
    TNativeDataSet(hObj).GetProp( iProp, PropValue, iMaxLen, iLen );
    Result := DBIERR_NONE;
  end else
    Result := DBIERR_INVALIDPARAM;
end;

Function TmySQLEngine.SetEngProp(hObj: hDBIObj; iProp: Longint; PropValue: Longint): DBIResult;
begin
  Try
    if Assigned(hObj) then
    begin
      TNativeDataSet(hObj).SetProp(iProp, PropValue);
      Result := DBIERR_NONE;
    end else
      Result := DBIERR_INVALIDPARAM;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.GetVchkDesc(hCursor: hDBICur;iValSeqNo: Word;pvalDesc: pVCHKDesc): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).GetVchkDesc(iValSeqNo, pvalDesc);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.GetCursorProps(
  hCursor: hDBICur; var curProps: CURProps): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).GetCursorProps(curProps);
    Result := DBIERR_NONE;
  Except
     Result := CheckError;
  end;
end;

Function TmySQLEngine.GetFieldDescs(hCursor: hDBICur;pfldDesc : pFLDDesc): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).GetFieldDescs(pFldDesc);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.SetToBegin(hCursor : hDBICur) : DBIResult;
begin
  TNativeDataSet(hCursor).SetToBegin;
  Result := DBIERR_NONE;
end;

Function TmySQLEngine.SetToEnd(hCursor : hDBICur) : DBIResult;
begin
  TNativeDataSet(hCursor).SetToEnd;
  Result := DBIERR_NONE;
end;

Function TmySQLEngine.RelRecordLock(hCursor: hDBICur;bAll: Bool): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).RelRecordLock(bAll);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.InitRecord(hCursor: hDBICur;PRecord: Pointer): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).InitRecord(PRecord);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.InsertRecord(hCursor: hDBICur;eLock: DBILockType;PRecord: Pointer): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).InsertRecord(eLock, PRecord);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.AppendRecord(hCursor : hDBICur;PRecord : Pointer): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).AppendRecord(PRecord);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.ModifyRecord(hCursor: hDBICur;OldRecord,PRecord: Pointer;bFreeLock : Bool): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).ModifyRecord(OldRecord,PRecord, bFreeLock);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.DeleteRecord(hCursor: hDBICur;PRecord: Pointer): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).DeleteRecord(PRecord);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

function TmySQLEngine.SetToSeqNo(hCursor: hDBICur;iSeqNo: Longint): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).SettoSeqNo(iSeqNo);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.GetObjFromObj( Source : hDBIObj; eObjType : DBIOBJType; var hObj : hDBIObj ) : DBIResult;
begin
  If ( eObjType = objSESSION ) then
  begin
    Result := DBIERR_NONE;
  end
  else
  begin
    hObj   := nil;
    Result := DBIERR_INVALIDPARAM;
  end;
end;

Function TmySQLEngine.AddFilter(hCursor: hDBICur;iClientData: Longint;iPriority: Word;bCanAbort: Bool;pcanExpr: pCANExpr;
                                pfFilter: pfGENFilter;var hFilter: hDBIFilter): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).AddFilter(iClientData,iPriority, bCanAbort,pcanExpr, pfFilter, hFilter );
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.DropFilter(hCursor: hDBICur;hFilter: hDBIFilter): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).DropFilter(hFilter);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.ActivateFilter(hCursor: hDBICur;hFilter: hDBIFilter): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).ActivateFilter(hFilter);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.DeactivateFilter(hCursor: hDBICur;hFilter: hDBIFilter): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).DeactivateFilter(hFilter);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.AnsiToNative(pNativeStr: PChar;pAnsiStr: PChar;iLen: LongInt;var bDataLoss : Bool): DBIResult;
begin
  Try
    bDataLoss := FALSE;
    Convert(pAnsiStr,pNativeStr,iLen,GetClientCp,DBCharSet);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.NativeToAnsi(pAnsiStr: PChar;pNativeStr: PChar;iLen: LongInt;var bDataLoss : Bool): DBIResult;
begin
  Try
    bDataLoss := FALSE;
    Convert(pNativeStr,pAnsiStr,iLen,DBCharSet,GetClientCp);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.GetErrorEntry(uEntry: Word;var ulNativeError: Longint;pszError: PChar): DBIResult;
Var
  tmp        : String;

  Procedure AddMessage( P : pChar );
  begin
    If ( StrLen( P ) > 0 ) then
      If ( Tmp <> '' ) then
        Tmp := Tmp + #13#10 + StrPas( P ) else
        Tmp := StrPas( P );
  end;

begin
  ulNativeError := -100;
  tmp := 'Error';
  StrLCopy(pszError, pChar(tmp), SizeOf(DBIPATH)- 1);
  Result := 0;
end;

Function TmySQLEngine.GetErrorString(rslt: DBIResult;ErrorMsg: String): DBIResult;
begin
  ErrorMsg := MessageStatus;
  Result := rslt;
end;

Function TmySQLEngine.QExecDirect(hDb : hDBIDb; eQryLang : DBIQryLang; pszQuery: PChar;phCur : phDBICur; var AffectedRows : LongInt): DBIResult;
begin
  Try
    Database := hDb;
    TNativeConnect(hDb).QExecDirect(eQryLang,pszQuery,phCur,AffectedRows);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.QAlloc(hDb: hDBIDb; eQryLang: DBIQryLang;var hStmt: hDBIStmt): DBIResult;
begin
  Try
    Database := hDb;
    TNativeConnect(hDb).QueryAlloc(hStmt);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.QPrepare(hStmt: hDBIStmt;pszQuery: PChar): DBIResult;
begin
  Try
    TNativeConnect(Database).QueryPrepare(hStmt,pszQuery);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.QExec(hStmt: hDBIStmt; phCur : phDBICur): DBIResult;
begin
  Try
    Statement := hStmt;
    if phCur = nil then
    begin
      try
        TNativeDataSet(hStmt).Execute;
        Result := DBIERR_NONE;
      except
        Result := CheckError;
      end
    end
    else
    begin
      TNativeDataSet(hStmt).OpenTable;
      if TNativeDataSet(hStmt).FStatement <> nil then
         phCur^ := hDBICur(hStmt) else
         phCur^ := nil;
      Result := DBIERR_NONE;
	 end;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.QFree(var hStmt : hDBIStmt): DBIResult;
begin
  Try
    if FStatement <> nil then
    begin
       Statement := hStmt;
//       if FCursor <> nil then
			 TNativeDataSet(hStmt).Free;
    end;
    hStmt  := nil;
    FStatement := nil;
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.QuerySetParams(hStmt: hDBIStmt;Params : TParams; SQLText : String): DBIResult;
begin
  Try
    Statement := hStmt;
    TNativeDataSet(hStmt).QuerySetParams(Params,SQLText);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.CheckError : DBIResult;
begin
  If ExceptObject is EmySQLException then
  begin
    if EmySQLException(ExceptObject).BDEErrors then
       Result := EmySQLException(ExceptObject).BDEErrorCode else
    begin
       FNativeStatus := EmySQLException(ExceptObject).mySQLErrorCode;
       Result := 1001;
    end;
    FNativeMsg := EmySQLException(ExceptObject).mySQLErrorMsg;
  end
  else
    Raise ExceptObject;
end;

function TmySQLEngine.GetClientInfo(var ClientInfo : string):DBIResult;
begin
   Try
    ClientInfo := TNativeConnect(Database).GetClientInfo;
    Result := DBIERR_NONE;
   Except
    Result := CheckError;
   end;
end;

function TmySQLEngine.GetServerStat(hDb: hDBIDb;var ServerStat: string):DBIResult;
begin
   Try
    Database := hDb;
    ServerStat := TNativeConnect(hdb).GetServerStat;
    Result := DBIERR_NONE;
   Except
    Result := CheckError;
   end;
end;

function TmySQLEngine.GetHostInfo(hDb: hDBIDb;var HostInfo: string):DBIResult;
begin
   Try
    Database := hDb;
    HostInfo := TNativeConnect(hdb).GetHostInfo;
    Result := DBIERR_NONE;
   Except
    Result := CheckError;
   end;
end;

function TmySQLEngine.GetProtoInfo(hDb: hDBIDb;var ProtoInfo: Cardinal):DBIResult;
begin
   Try
    Database := hDb;
    ProtoInfo := TNativeConnect(hdb).GetProtoInfo;
    Result := DBIERR_NONE;
   Except
    Result := CheckError;
   end;
end;

function TmySQLEngine.GetServerInfo(hDb: hDBIDb;var ServerInfo: string):DBIResult;
begin
   Try
    Database := hDb;
    ServerInfo := TNativeConnect(hdb).GetServerInfo;
    Result := DBIERR_NONE;
   Except
    Result := CheckError;
   end;
end;

function TmySQLEngine.GetDatabases(hDb: hDBIdb; pszWild: PChar; List : TStrings):DBIResult;
begin
  Try
    Database := hDb;
    TNativeConnect(hdb).DatabaseList(pszWild,List);
    Result := DBIERR_NONE;
   Except
    Result := CheckError;
   end;
end;

function TmySQLEngine.SelectDb(hDb:hDBIdb; pszDbName: PChar): DBIResult;
begin
   try
     Database := hDb;
     TNativeConnect(hDb).SelectDB(pszDbName);
     Result := DBIERR_NONE;
   except
     Result := CheckError;
   end;
end;

function TmySQLEngine.GetCharacterSet(hDb : hDBIDb; var CharSet : TConvertChar):DBIResult;
begin
   try
     Database := hDb;
     CharSet := TNativeConnect(hDb).GetCharSet;
     Result := DBIERR_NONE;
   except
     Result := CheckError;
   end;
end;


function TmySQLEngine.Ping(hDb:hDBIdb;var Status : Integer):DBIResult;
begin
   try
     Database := hDb;
     Status := TNativeConnect(hDb).Ping;
     Result := DBIERR_NONE;
   except
     Result := CheckError;
   end;
end;

function TmySQLEngine.ShutDown(hDb:hDBIdb; var Status : Integer):DBIResult;   // ptook
begin
  try
    Database := hDb;
    Status := TNativeConnect(hDb).Shutdown;
    Result := DBIERR_NONE;
  except
    Result := CheckError;
  end;
end;

function TmySQLEngine.Kill(hDb:hDBIdb;PID: Integer):DBIResult;
begin
   try
     Database := hDb;
     TNativeConnect(hDb).Kill(PID);
     Result := DBIERR_NONE;
   except
     Result := CheckError;
   end;
end;

///////////////////////////////////////////////////////////////////////////////
//                  Reserver for TmySQLTable                                 //
///////////////////////////////////////////////////////////////////////////////
Function TmySQLEngine.OpenFieldList(hDb: hDBIDb;pszTableName: PChar;pszDriverType: PChar;bPhyTypes: Bool;var hCur: hDBICur): DBIResult;
begin
  Try
    Database := hDb;
    TNativeConnect(hDb).OpenFieldList(pszTableName, pszDriverType, bPhyTypes, hCur );
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.OpenIndexList(hDb: hDBIDb;pszTableName: PChar;pszDriverType: PChar;var hCur: hDBICur): DBIResult;
begin
  Try
    Database := hDb;
    TNativeConnect(hDb).OpenIndexList(pszTableName, pszDriverType, hCur);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.EmptyTable(hDb: hDBIDb; hCursor : hDBICur; pszTableName : PChar; pszDriverType : PChar): DBIResult;
begin
  Try
    Database := hDb;
    TNativeConnect(hDb).EmptyTable(hCursor,pszTableName);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.SetRange(hCursor: hDBICur;bKeyItself: Bool;iFields1: Word;iLen1: Word;pKey1: Pointer;bKey1Incl: Bool;
                               iFields2: Word;iLen2: Word;pKey2: Pointer;bKey2Incl: Bool): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).SetRange(bKeyItself, iFields1, iLen1, pKey1, bKey1Incl,iFields2, iLen2, pKey2, bKey2Incl);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.ResetRange(hCursor: hDBICur): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).ResetRange;
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.SwitchToIndex(hCursor: hDBICur;pszIndexName,pszTagName: PChar;iIndexId: Word;bCurrRec: Bool): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).SwitchToIndex(pszIndexName, pszTagName, iIndexId, bCurrRec);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.ExtractKey(hCursor: hDBICur;PRecord: Pointer;pKeyBuf: Pointer): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).ExtractKey(PRecord, pKeyBuf);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.GetRecordForKey(hCursor: hDBICur; bDirectKey: Bool; iFields: Word; iLen: Word; pKey: Pointer; pRecBuff: Pointer): DBIResult;
begin
   Try
    TNativeDataSet(hCursor).GetRecordForKey(bDirectKey,iFields,iLen, pKey, pRecBuff);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.AddIndex(hDb: hDBIDb;hCursor: hDBICur;pszTableName: PChar;pszDriverType: PChar;var IdxDesc: IDXDesc;pszKeyviolName : PChar): DBIResult;
begin
  Try
    Database := hDb;
    TNativeConnect(hDB).AddIndex(hCursor, pszTableName, pszDriverType, idxDesc, pszKeyViolName);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.DeleteIndex(hDb: hDBIDb;hCursor: hDBICur;pszTableName: PChar;pszDriverType: PChar;pszIndexName: PChar;pszIndexTagName: PChar;iIndexId: Word): DBIResult;
begin
  Try
    Database := hDb;
    TNativeConnect(hDB).DeleteIndex(hCursor, pszTableName, pszDriverType, pszIndexName, pszIndexTagName, iIndexId);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.GetIndexDesc(hCursor: hDBICur;iIndexSeqNo: Word;var idxDesc: IDXDesc): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).GetIndexDesc(iIndexSeqNo,idxDesc);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.GetIndexDescs(hCursor: hDBICur;idxDesc: PIDXDesc): DBIResult;
begin
  Try
    TNativeDataSet(hCursor).GetIndexDescs(idxDesc);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.TranslateRecordStructure(pszSrcDriverType : PChar;iFlds: Word;pfldsSrc: pFLDDesc;pszDstDriverType: PChar; pszLangDriver: PChar;pfldsDst: pFLDDesc; bCreatable: Bool): DBIResult;
var
  M : pFldDesc;
  I : Integer;
begin
  try
    M  := pfldsDst;
    For i := 1 to iFlds do
    begin
       Move(pfldsSrc^, M^, SizeOf(FldDesc));
       Inc(M);
       Inc(pfldsSrc);
    end;
    Result :=DBIERR_NONE;
  except
    Result := CheckError;
  end;
end;

function TmySQLEngine.TableExists(hDb: hDBIDb; pszTableName: PChar): DBIResult;
begin
   Try
     Database := hDb;
     TNativeConnect(hDb).TableExists(pszTableName);
     Result := DBIERR_NONE;
  Except
     Result := CheckError;
  end;
end;

Function TmySQLEngine.CreateTable(hDb: hDBIDb; bOverWrite: Bool; var crTblDsc: CRTblDesc): DBIResult;
begin
   Try
     Database := hDb;
     TNativeConnect(hDb).CreateTable(bOverwrite, crTblDsc);
     Result := DBIERR_NONE;
  Except
     Result := CheckError;
  end;
end;

function TmySQLEngine.AcqTableLock(hCursor: hDBICur;eLockType: DBILockType): DBIResult;
begin
  Try
    TNativeDataset(hCursor).AcqTableLock(eLockType);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

function TmySQLEngine.RelTableLock(hCursor: hDBICur;bAll: Bool;eLockType: DBILockType): DBIResult;
begin
  Try
    TNativeDataset(hCursor).RelTableLock(bAll, eLockType);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

function TmySQLEngine.SetToKey(hCursor: hDBICur;eSearchCond: DBISearchCond;bDirectKey: Bool;iFields: Word;iLen: Word;pBuff: Pointer): DBIResult;
begin
  Try
    TNativeDataset(hCursor).SetToKey(eSearchCond, bDirectKey, iFields, iLen, pBuff);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

function TmySQLEngine.CloneCursor(hCurSrc: hDBICur;bReadOnly: Bool;bUniDirectional: Bool;var hCurNew: hDBICur): DBIResult;
begin
  Try
    Cursor := hCurSrc;
    TNativeDataset(hCurSrc).Clone(bReadonly, bUniDirectional, hCurNew);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

function TmySQLEngine.SetToCursor(hDest, hSrc : hDBICur) : DBIResult;
begin
  Try
    Cursor := hSrc;
    TNativeDataset(hSrc).SetToCursor(hDest);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

function TmySQLEngine.GetLastInsertID(hCursor : hDBICur; var ID : Int64) : DBIResult;
begin
  Try
    Cursor := hCursor;
    ID := TNativeDataset(hCursor).GetLastInsertID;
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

function TmySQLEngine.GetLastInsertID_Stmt(hStmt: hDBIStmt; var ID : Int64) : DBIResult;
begin
  Try
    Statement := hStmt;
    ID := TNativeDataset(hStmt).GetLastInsertID;
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.ReadBlock(hCursor : hDBICur; var iRecords : Longint; pBuf : Pointer): DBIResult;
begin
  Try
    TNativeDataset(hCursor).ReadBlock(iRecords, pBuf);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

Function TmySQLEngine.WriteBlock(hCursor : hDBICur; var iRecords : Longint; pBuf : Pointer): DBIResult;
begin
  Try
    TNativeDataset(hCursor).WriteBlock(iRecords, pBuf);
    Result := DBIERR_NONE;
  Except
    Result := CheckError;
  end;
end;

//:CN 29/05/2005
function TmySQLEngine.CheckBuffer(hCursor: hDBICur;
  PRecord: Pointer): DBIResult;
begin
  Try
    OutputDebugString(pchar('*** fm2 '+inttohex(integer(TNativeDataSet(hCursor).FCurrentBuffer),8)));
    if TNativeDataSet(hCursor).FCurrentBuffer = PRecord then
      TNativeDataSet(hCursor).FCurrentBuffer:= nil;
	 Result := DBIERR_NONE;
  Except
	 Result := CheckError;
  end;
end;
//:CN 29/05/2005

function TmySQLEngine.GetFieldValueFromBuffer(hCursor: hDBICur;
  PRecord: Pointer; AFieldName: string; var AValue: string; var AFieldType: word): DBIResult;
begin
  Try
	 AValue := TNativeDataSet(hCursor).FieldValueFromBuffer(PRecord, AFieldName, AFieldType);
	 Result := DBIERR_NONE;
  Except
	 Result := CheckError;
  end;
end;

end.
