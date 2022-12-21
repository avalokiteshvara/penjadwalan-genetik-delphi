// LightWeight Delphi Library For MySQL.
// Copyright (C) 2008 Miroslav Marchev (http://blog.ieti.eu/)

// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

unit MySQLDirect;

interface

uses Windows;

// -------------------------------------------------------------------------- //
// -------------------------------------------------------------------------- //
// -------------------------------------------------------------------------- //

type
  PMYSQL            = Pointer;  // Structure Not Needed
  PMYSQL_RES        = Pointer;  // Structure Not Needed
  MYSQL_ROW         = ^PChar;   // Better Than Fixed Array

  PMYSQL_FIELD = ^MYSQL_FIELD;
  MYSQL_FIELD = record
    name:             PChar;    // Name Of Column
    org_name:         PChar;    // Original Column Name, If An Alias
    table:            PChar;    // Table Of Column If Column Was A Field
    org_table:        PChar;    // Original Table Name If Table Was An Alias
    db:               PChar;    // Database For Table
    catalog:          PChar;    // Catalog For Table
    def:              PChar;    // Default Value (Set By 'mysql_list_fields')
    length:           LongWord; // Width Of Column
    max_length:       LongWord; // Max Width Of Selected Set
    name_length:      Cardinal;
    org_name_length:  Cardinal;
    table_length:     Cardinal;
    org_table_length: Cardinal;
    db_length:        Cardinal;
    catalog_length:   Cardinal;
    def_length:       Cardinal;
    flags:            Cardinal; // Div Flags
    decimals:         Cardinal; // Number Of Decimals In Field
    charsetnr:        Cardinal; // Character Set
    _type:            Cardinal; // Type Of Field. See 'mysql_com.h' For Types
  end;

// -------------------------------------------------------------------------- //
// -------------------------------------------------------------------------- //
// -------------------------------------------------------------------------- //

const
  LIB_MYSQL               = 'libmysql.dll';

  FUN_MYSQL_ERR_NO        = 'mysql_errno';
  FUN_MYSQL_ERROR         = 'mysql_error';
  FUN_MYSQL_SQL_STATE     = 'mysql_sqlstate';
  FUN_MYSQL_INIT          = 'mysql_init';
  FUN_MYSQL_OPTIONS       = 'mysql_options';
  FUN_MYSQL_REAL_CONNECT  = 'mysql_real_connect';
  FUN_MYSQL_CLOSE         = 'mysql_close';
  FUN_MYSQL_PING          = 'mysql_ping';
  FUN_MYSQL_REAL_QUERY    = 'mysql_real_query';
  FUN_MYSQL_AFFECTED_ROWS = 'mysql_affected_rows';
  FUN_MYSQL_NUM_ROWS      = 'mysql_num_rows';
  FUN_MYSQL_INSERT_ID     = 'mysql_insert_id';
  FUN_MYSQL_ESCAPE_STRING = 'mysql_escape_string';
  FUN_MYSQL_HEX_STRING    = 'mysql_hex_string';
  FUN_MYSQL_STORE_RESULT  = 'mysql_store_result';
  FUN_MYSQL_FREE_RESULT   = 'mysql_free_result';
  FUN_MYSQL_FETCH_ROW     = 'mysql_fetch_row';
  FUN_MYSQL_DATA_SEEK     = 'mysql_data_seek';
  FUN_MYSQL_FETCH_LENGTHS = 'mysql_fetch_lengths';
  FUN_MYSQL_NUM_FIELDS    = 'mysql_num_fields';
  FUN_MYSQL_FETCH_FIELDS  = 'mysql_fetch_fields';

const
  MYSQL_OPT_RECONNECT     = 20; // Attempt Auto Reconnect
  MYSQL_OPT_COMPRESS      = 1;  // Use Compress Protocol

type
  TMySqlErrNo = function(mysql: PMYSQL): Cardinal; stdcall;
  TMySqlError = function(mysql: PMYSQL): PChar; stdcall;
  TMySqlSqlState = function(mysql: PMYSQL): PChar; stdcall;
  TMySqlInit = function(mysql: PMYSQL): PMYSQL; stdcall;
  TMySqlOptions = function(mysql: PMYSQL; option: Cardinal; arg: PChar): Integer; stdcall;
  TMySqlRealConnect = function(mysql: PMYSQL; host, user, passwd, db: PChar;
    port: Cardinal; unix_socket: PChar; client_flag: LongWord): PMYSQL; stdcall;
  TMySqlClose = procedure(mysql: PMYSQL); stdcall;
  TMySqlPing = function(mysql: PMYSQL): Integer; stdcall;
  TMySqlRealQuery = function(mysql: PMYSQL; stmt_str: PChar; length: LongWord): Integer; stdcall;
  TMySqlAffectedRows = function(mysql: PMYSQL): Int64; stdcall;
  TMySqlNumRows = function(result: PMYSQL_RES): Int64; stdcall;
  TMySqlInsertId = function(mysql: PMYSQL): Int64; stdcall;
  TMySqlEscapeString = function(_to, from: PChar; length: LongWord): LongWord; stdcall;
  TMySqlHexString = function(_to, from: PChar; length: LongWord): LongWord; stdcall;
  TMySqlStoreResult = function(mysql: PMYSQL): PMYSQL_RES; stdcall;
  TMySqlFreeResult = procedure(result: PMYSQL_RES); stdcall;
  TMySqlFetchRow = function(result: PMYSQL_RES): MYSQL_ROW; stdcall;
  TMySqlDataSeek = procedure(result: PMYSQL_RES; offset: Int64); stdcall;
  TMySqlFetchLengths = function(result: PMYSQL_RES): PLongWord; stdcall;
  TMySqlNumFields = function(result: PMYSQL_RES): Cardinal; stdcall;
  TMySqlFetchFields = function(result: PMYSQL_RES): PMYSQL_FIELD; stdcall;

// -------------------------------------------------------------------------- //
// -------------------------------------------------------------------------- //
// -------------------------------------------------------------------------- //

const
  DEF_HOST     = 'localhost';              // Default Host
  DEF_PORT     = 3306;                     // Default Port
  DEF_ERROR    = 'Unknown MySQL Error...'; // Default Error String
  DEF_NO_CONN  = -1;                       // Default Error Result
  DEF_STATE    = '00000';                  // Default SQL State
  DEF_NO_STR   = '';                       // Default Error String
  DEF_FAIL     = 'Failed';                 // For No Connection Errors
  DEF_NO_ERR   = 0;                        // No Error Everything Good

  ERR_FORMAT_S = '%s | %s';                // Exception Format
  ERR_FORMAT_D = '%d (#%s) - %s';          // MySQL Error Format
  ERR_INIT     = 'Could Not Init';
  ERR_CONN     = 'Connection Closed';
  HEX_FORMAT   = '0x%s';                   // 0xHEX_STRING Format

// -------------------------------------------------------------------------- //
// -------------------------------------------------------------------------- //
// -------------------------------------------------------------------------- //

type
  PCacheItem = ^TCacheItem;
  TCacheItem = record
    CacheName : string;
    CacheIdx  : Integer;
  end;

type
  TMySQLConnection = class(TObject)
  private
    // Connection
    FServerHost: string;
    FServerPort: Cardinal;
    FDBSchema: string;
    FUserName: string;
    FPassword: string;
    FConnection: PMYSQL;
    // Query
    FQueryResult: PMYSQL_RES;
    FResultRow: MYSQL_ROW;
    FResultLenghts: PLongWord;
    FFieldNames: array of string;
    FFieldCache: array of PCacheItem;
    // Other
    FTag: Integer;

    // Error Handling
    function GetError: string;
    // Query Helper
    procedure GetFieldNames;
    function GetFieldIndex(const FieldName: string): Integer;
    function GetFieldValue(const FieldName: string): string;
    // Used Fields Cache
    function GetCacheIndex(const FieldName: string): Integer;
    procedure AddToFieldCache(const FieldName: string; FieldIndex: Integer);
    procedure ClearFieldCache;
  public
    constructor Create(const ServerHost: string; ServerPort: Cardinal;
      const DBSchema, UserName, Password: string);
    destructor Destroy; override;

    // Keeps Pool ConnectionId
    property Tag: Integer read FTag write FTag;

    // Connection Manage
    procedure OpenConnection(OptCompress: Boolean = False);
    procedure CloseConnection;
    function Connected: Boolean;
    function Spawn: TMySQLConnection;

    // Execute Query
    procedure ExecuteQuery(const SQLCommand: string);
    function RowsAffected: Int64;
    function LastInsertId: Int64;
    // Select Query
    procedure OpenQuery(const SQLCommand: string);
    procedure CloseQuery;
    function First: Boolean;
    function Next: Boolean;
    function Eof: Boolean;
    // Query Result
    function FieldByName(const FieldName: string): string;
    function FieldByNameInt(const FieldName: string): Integer;
  end;

// Other Routines
function MySqlEscapeString(const InputStr: string; ToHex: Boolean = False): string;
function MyCopyString(DataPtr: Pointer; DataLen: Cardinal; var ResultStr: string;
  const ResultDef: string = DEF_NO_STR): Boolean;

// Loader Routines
procedure InitLib;
procedure FreeLib;

function LoadLib(var LibHandle: THandle; const LibName: string): Boolean;
function LoadFunc(LibHandle: THandle; var FuncPtr: FARPROC; const FuncName: string): Boolean;
procedure ReleaseLib(var LibHandle: THandle);

var
  // Is MySQL Init Properly
  IsMySQLOk: Boolean = False;

  // MySQL Library Handle
  MySQLHandle: THandle = 0;

  // Loaded Procedures
  mysql_errno: TMySqlErrNo = nil;
  mysql_error: TMySqlError = nil;
  mysql_sqlstate: TMySqlSqlState = nil;
  mysql_init: TMySqlInit = nil;
  mysql_options: TMySqlOptions = nil;
  mysql_real_connect: TMySqlRealConnect = nil;
  mysql_close: TMySqlClose = nil;
  mysql_ping: TMySqlPing = nil;
  mysql_real_query: TMySqlRealQuery = nil;
  mysql_affected_rows: TMySqlAffectedRows = nil;
  mysql_num_rows: TMySqlNumRows = nil;
  mysql_insert_id: TMySqlInsertId = nil;
  mysql_escape_string: TMySqlEscapeString = nil;
  mysql_hex_string: TMySqlHexString = nil;
  mysql_store_result: TMySqlStoreResult = nil;
  mysql_free_result: TMySqlFreeResult = nil;
  mysql_fetch_row: TMySqlFetchRow = nil;
  mysql_data_seek: TMySqlDataSeek = nil;
  mysql_fetch_lengths: TMySqlFetchLengths = nil;
  mysql_num_fields: TMySqlNumFields = nil;
  mysql_fetch_fields: TMySqlFetchFields = nil;

implementation

uses SysUtils;

{ MySQLConnection }

constructor TMySQLConnection.Create(const ServerHost: string; ServerPort: Cardinal;
  const DBSchema, UserName, Password: string);
begin
  inherited Create;

  // Connection
  if (Length(Trim(ServerHost)) > 0) then
    FServerHost := ServerHost
  else
    FServerHost := DEF_HOST;

  if (ServerPort > 0) then
    FServerPort := ServerPort
  else
    FServerPort := DEF_PORT;

  FDBSchema := DBSchema;
  FUserName := UserName;
  FPassword := Password;

  FConnection := nil;

  // Query
  FQueryResult := nil;
  FResultRow := nil;
  FResultLenghts := nil;
  // Clear Field Cache
  ClearFieldCache;

  // Keeps Pool ConnectionId
  FTag := DEF_NO_CONN;
end;

destructor TMySQLConnection.Destroy;
begin
  // Close Connection If Open
  // Close Query Too
  CloseConnection;

  inherited Destroy;
end;

// Connection Manage
procedure TMySQLConnection.OpenConnection(OptCompress: Boolean = False);
var
  MyErrorMsg : string;
  MyBool     : Byte;
  ConnCheck  : PMYSQL;

begin
  // MySQLLib Not Init Properly...
  if (IsMySQLOk = False) then
  begin
    // Just To Be Sure
    CloseConnection;

    // Throw Exception
    raise Exception.CreateFmt(ERR_FORMAT_S, [ERR_INIT, LIB_MYSQL]);
  end;

  if Assigned(FConnection) then
  begin
    // Check Connection Still Open
    // Reuse If Already Open
    if (Connected = False) then
    begin
      // Get Error Before Connection Close
      MyErrorMsg := GetError;

      // Connection Is Dead
      CloseConnection;

      // Throw Exception
      raise Exception.CreateFmt(ERR_FORMAT_S, [FUN_MYSQL_PING, MyErrorMsg]);
    end;
  end
  else
  begin
    // Just To Be Sure
    CloseConnection;

    // No Connection
    FConnection := mysql_init(nil);
    if Assigned(FConnection) then
    begin
      // Set To False
      MyBool := 0;

      // Do Not ReConnect. Connection Is Closed On Every Error
      // No Need To Check Result. Older Versions Off By Default
      mysql_options(FConnection, MYSQL_OPT_RECONNECT, @MyBool);

      // OFF By Default
      if OptCompress then
      begin
        // Use Compress Protocol. Good For Big Remote Resultset
        // Param Ignored For This Option
        mysql_options(FConnection, MYSQL_OPT_COMPRESS, @MyBool);
      end;

      // Connect To MySQL Server
      ConnCheck := mysql_real_connect(FConnection, PChar(FServerHost),
        PChar(FUserName), PChar(FPassword), PChar(FDBSchema), FServerPort, nil, 0);
      // Do Not NIL FConnection On Fail
      // Must Free Connection Pointer
      if (Assigned(ConnCheck) = False) then
      begin
        // Get Error Before Connection Close
        MyErrorMsg := GetError;

        // Just To Be Sure
        CloseConnection;

        // Throw Exception
        raise Exception.CreateFmt(ERR_FORMAT_S, [FUN_MYSQL_REAL_CONNECT, MyErrorMsg]);
      end;
    end
    else
    begin
      // Just To Be Sure
      CloseConnection;

      // Throw Exception
      raise Exception.CreateFmt(ERR_FORMAT_S, [FUN_MYSQL_INIT, DEF_FAIL]);
    end;
  end;
end;

procedure TMySQLConnection.CloseConnection;
begin
  try
    // Close Open Queries
    // Free Client Resources
    CloseQuery;

    try
      if Assigned(FConnection) then
      begin
        // Close Connection To Server
        mysql_close(FConnection);
      end;
    finally
      FConnection := nil;
    end;
  except
    // Bad Connection
  end;
end;

function TMySQLConnection.Connected: Boolean;
begin
  // Check Connection Still Open
  if Assigned(FConnection) then
    Result := (mysql_ping(FConnection) = DEF_NO_ERR)
  else
    Result := False;
end;

function TMySQLConnection.Spawn: TMySQLConnection;
begin
  // Make Copy Of Connection
  Result := TMySQLConnection.Create(FServerHost, FServerPort, FDBSchema, FUserName, FPassword);
end;

// Execute Query
procedure TMySQLConnection.ExecuteQuery(const SQLCommand: string);
begin
  if Assigned(FConnection) then
  begin
    // Close Query If Open
    CloseQuery;

    // Execute Statement
    if (mysql_real_query(FConnection, PChar(SQLCommand), Length(SQLCommand)) <> DEF_NO_ERR) then
    begin
      // Just To Be Sure
      CloseQuery;

      // Throw Exception
      raise Exception.CreateFmt(ERR_FORMAT_S, [FUN_MYSQL_REAL_QUERY, GetError]);
    end;
  end
  else
  begin
    // Just To Be Sure
    CloseQuery;

    // Throw Exception
    raise Exception.CreateFmt(ERR_FORMAT_S, [ERR_CONN, DEF_FAIL]);
  end;
end;

function TMySQLConnection.RowsAffected: Int64;
begin
  Result := DEF_NO_CONN;

  // Get Number Of Affected/Returned Rows By Query
  if Assigned(FConnection) then
  begin
    // Get Only If Executed Good
    if (mysql_errno(FConnection) = DEF_NO_ERR) then
    begin
      // Call Right Function Depending On SQL Type
      if Assigned(FQueryResult) then
        Result := mysql_num_rows(FQueryResult)
      else
        Result := mysql_affected_rows(FConnection);
    end;
  end;
end;

function TMySQLConnection.LastInsertId: Int64;
begin
  Result := DEF_NO_CONN;

  // Get Last Auto Increment Value
  // Generated By Current Connection
  if Assigned(FConnection) then
  begin
    // If Previous Query Executed Good Get The Insert Id
    // On Error Function Result Undefined No Neeed To Call
    if (mysql_errno(FConnection) = DEF_NO_ERR) then
    begin
      Result := mysql_insert_id(FConnection);
    end;
  end;
end;

// Select Query
procedure TMySQLConnection.OpenQuery(const SQLCommand: string);
begin
  if Assigned(FConnection) then
  begin
    // !!! CloseQuery Is Called !!!
    // !!! In ExecuteQuery      !!!
    ExecuteQuery(SQLCommand);

    // Get All Records Returned
    // Prevent COMMANDS_OUT_OF_SYNC Errors
    FQueryResult := mysql_store_result(FConnection);
    if Assigned(FQueryResult) then
    begin
      // Errors Are Reset After Success
      // Sometimes There Is Error And Result
      if (mysql_errno(FConnection) = DEF_NO_ERR) then
      begin
        // Cache Query Filed Names
        GetFieldNames;
      end
      else
      begin
        // Just To Be Sure
        CloseQuery;

        // Throw Exception
        raise Exception.CreateFmt(ERR_FORMAT_S, [FUN_MYSQL_STORE_RESULT, GetError]);
      end;
    end
    else
    begin
      // Just To Be Sure
      CloseQuery;

      // Throw Exception
      raise Exception.CreateFmt(ERR_FORMAT_S, [FUN_MYSQL_STORE_RESULT, GetError]);
    end;
  end
  else
  begin
    // Just To Be Sure
    CloseQuery;

    // Throw Exception
    raise Exception.CreateFmt(ERR_FORMAT_S, [ERR_CONN, DEF_FAIL]);
  end;
end;

procedure TMySQLConnection.CloseQuery;
begin
  try
    try
      if Assigned(FQueryResult) then
      begin
        // Free Fetched Rows
        mysql_free_result(FQueryResult);
      end;
    finally
      FQueryResult := nil;
      FResultRow := nil;
      FResultLenghts := nil;
      // Clear Field Cache
      ClearFieldCache;
    end;
  except
    // Bad Query
  end;
end;

function TMySQLConnection.Next: Boolean;
begin
  Result := False;

  if Assigned(FQueryResult) then
  begin
    // Get Single Record
    FResultRow := mysql_fetch_row(FQueryResult);
    // Get Record Data Values Lenghts
    FResultLenghts := mysql_fetch_lengths(FQueryResult);
    // Check Valid
    Result := (Eof = False);
  end;
end;

function TMySQLConnection.First: Boolean;
begin
  Result := False;

  if Assigned(FQueryResult) then
  begin
    // Position To First Row
    mysql_data_seek(FQueryResult, 0);
    // Fetch Result Row
    Result := Next;
  end;
end;

function TMySQLConnection.Eof: Boolean;
begin
  // Routine mysql_eof Deprecated
  if Assigned(FResultRow) and Assigned(FResultLenghts) then
    Result := False
  else
    Result := True;
end;

// Query Result
function TMySQLConnection.FieldByName(const FieldName: string): string;
begin
  Result := GetFieldValue(FieldName);
end;

function TMySQLConnection.FieldByNameInt(const FieldName: string): Integer;
begin
  // Return Default Value On Error
  Result := StrToIntDef(GetFieldValue(FieldName), DEF_NO_CONN);
end;

// Query Helper
procedure TMySQLConnection.GetFieldNames;
var
  FieldCount : Cardinal;
  Fields     : PMYSQL_FIELD;
  i          : Cardinal;

begin
  if Assigned(FQueryResult) then
  begin
    // Get Query Field Count
    FieldCount := mysql_num_fields(FQueryResult);
    // Get Fields Array
    Fields := mysql_fetch_fields(FQueryResult);
    // Check Fields Retrieved
    if (Assigned(Fields) = True) and (FieldCount > 0) then
    begin
      // Resize Array
      SetLength(FFieldNames, FieldCount);
      // Cycle All Items
      for i := Low(FFieldNames) to High(FFieldNames) do
      begin
        // Transfer Names To Array
        MyCopyString(Fields^.name, Fields^.name_length, FFieldNames[i]);

        // GoTo To Next Field Record
        Inc(Fields);
      end;
    end;
  end;
end;

function TMySQLConnection.GetFieldIndex(const FieldName: string): Integer;
var
  i         : Integer;
  FieldDest : string;

begin
  // Get From Cache
  Result := GetCacheIndex(FieldName);
  // Chech Exists In Cache
  if (Result = DEF_NO_CONN) then
  begin
    // Field Names Cached To Speed Up
    for i := Low(FFieldNames) to High(FFieldNames) do
    begin
      // Cycle Fields Array
      FieldDest := FFieldNames[i];

      // Hope Compare Is Fast Enought
      if AnsiSameText(FieldName, FieldDest) then
      begin
        // Add Field To Cache
        AddToFieldCache(FieldName, i);
        // Return Index
        Result := i;
        // Leave Loop Field Found
        Break;
      end;
    end;
  end;
end;

function TMySQLConnection.GetFieldValue(const FieldName: string): string;
var
  FieldIndex : Integer;
  DataRow    : MYSQL_ROW;
  DataLen    : PLongWord;

begin
  Result := DEF_NO_STR;

  // Check Row Retrieved
  if (Eof = False) then
  begin
    // Keep Original Pointers Unmodified
    DataRow := FResultRow;
    DataLen := FResultLenghts;

    FieldIndex := GetFieldIndex(FieldName);
    if (FieldIndex <> DEF_NO_CONN) then
    begin
      // Goto Needed Field
      Inc(DataRow, FieldIndex);
      Inc(DataLen, FieldIndex);

      // Copy Field Value
      MyCopyString(DataRow^, DataLen^, Result);
    end;
  end;
end;

// Used Fields Cache
procedure TMySQLConnection.AddToFieldCache(const FieldName: string; FieldIndex: Integer);
var
  CacheItem: PCacheItem;

begin
  try
    // Create Item
    New(CacheItem);
    // Just To Be Sure
    if Assigned(CacheItem) then
    begin
      // Populate Cache Item
      CacheItem^.CacheName := FieldName;
      CacheItem^.CacheIdx := FieldIndex;
      // Resize Array
      SetLength(FFieldCache, High(FFieldCache) + 2);
      // Attach Item
      FFieldCache[High(FFieldCache)] := CacheItem;
    end;
  except
    //
  end;
end;

procedure TMySQLConnection.ClearFieldCache;
var
  i         : Integer;
  CacheItem : PCacheItem;

begin
  try
    // Dispose Items
    for i := Low(FFieldCache) to High(FFieldCache) do
    begin
      CacheItem := FFieldCache[i];
      if Assigned(CacheItem) then
      begin
        Dispose(CacheItem);
      end;
    end;

    // Clear Arrays
    SetLength(FFieldCache, 0);
    SetLength(FFieldNames, 0);
  except
    //
  end;
end;

function TMySQLConnection.GetCacheIndex(const FieldName: string): Integer;
var
  i         : Integer;
  CacheItem : PCacheItem;

begin
  Result := DEF_NO_CONN;

  // Field Names Cached To Speed Up
  for i := Low(FFieldCache) to High(FFieldCache) do
  begin
    CacheItem := FFieldCache[i];
    // Check Valid
    if Assigned(CacheItem) then
    begin
      // Hope Compare Is Fast Enought
      if AnsiSameText(FieldName, CacheItem^.CacheName) then
      begin
        // Return Cached Index
        Result := CacheItem^.CacheIdx;
        // Leave Loop Field Found
        Break;
      end;
    end;
  end;
end;

// Error Handling
function TMySQLConnection.GetError: string;
var
  ErrorNumber  : Cardinal;
  PErrorState  : PChar;
  ErrorState   : string;
  PErrorString : PChar;
  ErrorString  : string;

begin
  // Set Default Values
  ErrorString := DEF_ERROR;
  ErrorNumber := DEF_NO_ERR;
  ErrorState  := DEF_STATE;

  // Return Formatted Error Message
  if Assigned(FConnection) then
  begin
    // Retrieve Error Number
    ErrorNumber := mysql_errno(FConnection);

    // Retrieve MYSQL Error
    PErrorString := mysql_error(FConnection);
    // Copy Error Data
    MyCopyString(PErrorString, StrLen(PErrorString), ErrorString, DEF_ERROR);

    // Retrieve SQL State
    PErrorState := mysql_sqlstate(FConnection);
    // Copy Error Data
    MyCopyString(PErrorState, StrLen(PErrorState), ErrorState, DEF_STATE);
  end;

  // !!! Error Code DbExpress Return IN ErrorState !!!
  // !!! ErrorNumber <> ErrorState                 !!!
  Result := Format(ERR_FORMAT_D, [ErrorNumber, ErrorState, ErrorString]);
end;

// Other Routines
function MySqlEscapeString(const InputStr: string; ToHex: Boolean = False): string;
var
  InputLen  : LongWord;
  OutputLen : LongWord;
  OutputBuf : PChar;
  OutputVal : string;

begin
  Result := DEF_NO_STR;

  // Check MySqlLib Loaded
  if IsMySQLOk then
  begin
    InputLen := Length(InputStr);
    if (InputLen > 0) then
    begin
      // Get Working Buffer
      OutputBuf := AllocMem((InputLen + 1) * 2);
      try
        // Convert Data According To Flag
        if ToHex then
          OutputLen := mysql_hex_string(OutputBuf, PChar(InputStr), InputLen)
        else
          OutputLen := mysql_escape_string(OutputBuf, PChar(InputStr), InputLen);

        // Copy Buffer To String
        if MyCopyString(OutputBuf, OutputLen, OutputVal) then
        begin
          // Return Correct Value
          // To Be Decoded Format 0xHEX_STRING
          if ToHex then
            Result := Format(HEX_FORMAT, [OutputVal])
          else
            Result := OutputVal;
        end;
      finally
        // Free Buffer
        FreeMem(OutputBuf);
      end;
    end;
  end;
end;

function MyCopyString(DataPtr: Pointer; DataLen: Cardinal; var ResultStr: string;
  const ResultDef: string = DEF_NO_STR): Boolean;
begin
  try
    // Reset Values
    Result := False;
    ResultStr := ResultDef;

    // Check Input Data
    if (Assigned(DataPtr) = True) and (DataLen > 0) then
    begin
      // Resize String
      SetLength(ResultStr, DataLen);
      // Copy Data To String
      Move(DataPtr^, Pointer(ResultStr)^, DataLen);
      // Set Success
      Result := True;
    end;
  except
    // Reset Values
    Result := False;
    ResultStr := ResultDef;
  end;
end;

// Library Initialization
function LoadLib(var LibHandle: THandle; const LibName: string): Boolean;
begin
  LibHandle := 0;

  LibHandle := LoadLibrary(PChar(LibName));
  Result := (LibHandle <> 0);
end;

function LoadFunc(LibHandle: THandle; var FuncPtr: FARPROC;
  const FuncName: string): Boolean;
begin
  FuncPtr := nil;
  Result := False;

  if (LibHandle <> 0) then
  begin
    FuncPtr := GetProcAddress(LibHandle, PChar(FuncName));
    Result := Assigned(FuncPtr);
  end;
end;

procedure ReleaseLib(var LibHandle: THandle);
begin
  if (LibHandle <> 0) then
  begin
    FreeLibrary(LibHandle);
    LibHandle := 0;
  end;
end;

procedure InitLib;
begin
  try
    IsMySQLOk := False;

    if (LoadLib(MySQLHandle, LIB_MYSQL) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_errno, FUN_MYSQL_ERR_NO) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_error, FUN_MYSQL_ERROR) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_sqlstate, FUN_MYSQL_SQL_STATE) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_init, FUN_MYSQL_INIT) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_options, FUN_MYSQL_OPTIONS) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_real_connect, FUN_MYSQL_REAL_CONNECT) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_close, FUN_MYSQL_CLOSE) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_ping, FUN_MYSQL_PING) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_real_query, FUN_MYSQL_REAL_QUERY) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_affected_rows, FUN_MYSQL_AFFECTED_ROWS) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_num_rows, FUN_MYSQL_NUM_ROWS) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_insert_id, FUN_MYSQL_INSERT_ID) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_escape_string, FUN_MYSQL_ESCAPE_STRING) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_hex_string, FUN_MYSQL_HEX_STRING) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_store_result, FUN_MYSQL_STORE_RESULT) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_free_result, FUN_MYSQL_FREE_RESULT) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_fetch_row, FUN_MYSQL_FETCH_ROW) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_data_seek, FUN_MYSQL_DATA_SEEK) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_fetch_lengths, FUN_MYSQL_FETCH_LENGTHS) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_num_fields, FUN_MYSQL_NUM_FIELDS) = False) then Exit;
    if (LoadFunc(MySQLHandle, @mysql_fetch_fields, FUN_MYSQL_FETCH_FIELDS) = False) then Exit;

    IsMySQLOk := True;
  except
    IsMySQLOk := False;
  end;
end;

procedure FreeLib;
begin
  IsMySQLOk := False;

  mysql_errno := nil;
  mysql_error := nil;
  mysql_sqlstate := nil;
  mysql_init := nil;
  mysql_options := nil;
  mysql_real_connect := nil;
  mysql_close := nil;
  mysql_ping := nil;
  mysql_real_query := nil;
  mysql_affected_rows := nil;
  mysql_num_rows := nil;
  mysql_insert_id := nil;
  mysql_escape_string := nil;
  mysql_hex_string := nil;
  mysql_store_result := nil;
  mysql_free_result := nil;
  mysql_fetch_row := nil;
  mysql_data_seek := nil;
  mysql_fetch_lengths := nil;
  mysql_num_fields := nil;
  mysql_fetch_fields := nil;

  ReleaseLib(MySQLHandle);
end;

initialization
  // Get Library Init Status
  InitLib;

finalization
  // Detach From Library
  FreeLib;

end.
