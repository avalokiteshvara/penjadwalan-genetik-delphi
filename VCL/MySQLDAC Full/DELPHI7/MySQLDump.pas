{$I mysqldac.inc}
unit MySQLDump;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  MySQLDBTables,MySQLTypes,MySQLAccess, uMyDMClient,Db;

type
  TOnProcess = procedure (Sender: TObject;Table:string;Percent : Integer) of object;
  TOnDataProcess = procedure (Sender : TObject; Percent : Integer) of object;
  TDumpOption = (dStructure,dData,dAll);


  TMySQLDump = class(TComponent)
  private
    { Private declarations }
    FAbout      : TmySQLDACAbout;
    FDatabase   : TMySQLDatabase;
    FTableList  : TStrings;
    FDropObject : Boolean;
    FUseCreateDb: Boolean;
    FSQLFile    : TFileName;
    F           : TextFile;
    FDumpOption : TDumpOption;
    FDelimiter  : String;
    FExtInsert  : Boolean;
    FAddLocks   : Boolean;
    FDisableKeys: Boolean;
    FOnProcess  : TOnProcess;
    FOnDataProcess: TOnDataProcess;
    FonFinish   : TNotifyEvent;
    FRewriteFile: boolean;
    FIncludeHeader: boolean;      // ptook
    procedure SetDatabase(const Value : TMySQLDatabase);
    procedure SetSQLFile(const Value : TFileName);
    procedure SetTableList(const Value : TStrings);
    procedure SetDumpOption(const Value : TDumpOption);
    procedure SetDropObject(const Value : Boolean);
    procedure SetUseCreateDB(const Value : Boolean);
    procedure SetDelimiter(const Value : String);
    procedure SetExtInsert(const Value : Boolean);
    procedure SetAddLocks(const Value : Boolean);
    procedure SetDisableKeys(const Value : Boolean);
  protected
    { Protected declarations }
    Procedure Notification( AComponent: TComponent; Operation: TOperation ); Override;
    procedure WriteHeader(Host,DBName,SrvVer : String);
    procedure Init_dumping(Database : String);
    procedure GetTableStructure(Table :String);
    procedure GetTableData(Table : String);
    procedure GetTableStructureData(Table : String);
    procedure UnloadDb;
  public
    { Public declarations }
    Constructor Create(Owner : TComponent); override;
    destructor Destroy; override;
    function Execute: Boolean;
  published
    { Published declarations }
    property About : TmySQLDACAbout read FAbout write FAbout;
    property Database   : TMySQLDatabase read FDatabase write SetDatabase;
    property DumpOption : TDumpOption read FDumpOption write SetDumpOption default dStructure;
    property SQLFile    : TFileName read FSQLFile Write SetSQLFile;
    property DropObject : Boolean read FDropObject write SetDropObject default True;
    property TableList  : TStrings read FTableList write SetTableList;
    property UseCreateDb: Boolean read FUseCreateDb write SetUseCreateDB default True;
    property Delimiter  : String read FDelimiter write SetDelimiter;
    property ExtInsert  : Boolean read FExtInsert write SetExtInsert default False;
    property AddLocks   : Boolean read FAddLocks write SetAddLocks default True;
    property DisableKeys: Boolean read FDisableKeys write SetDisableKeys default False;
    property RewriteFile: boolean read FRewriteFile write FRewriteFile default True;    // ptook
    property IncludeHeader: boolean read FIncludeHeader write FIncludeHeader default True;  // ptook

    property OnProcess  : TOnProcess read FOnProcess write FOnProcess;
    property OnDataProcess : TOnDataProcess read FOnDataProcess write FOnDataProcess;
    property OnFinish   : TNotifyEvent read FonFinish write FonFinish;
  end;


const
    DUMP_VERSION = '1.1';

implementation
uses uMyDMHelpers;

function StrValue(S : PChar; ASize : Integer):String;
var
   Buffer : PChar;
   St : String;
begin
    Result := '';
    if S <> nil then
    begin
      GetMem(Buffer, ASize+1);
      ZeroMemory(Buffer,ASize+1);
      Move(S^,Buffer^,ASize+1);
      SetString(St,Buffer,ASize);
      Result := EscapeStr(St);
      FreeMem(Buffer, ASize+1);
    end else
    Result := 'NULL';
end;

Constructor TMySQLDump.Create(Owner : TComponent);
begin
  inherited Create(Owner);
  FTableList := TStringList.Create;
  FDropObject := True;
  FUseCreateDb := True;
  FDumpOption := dStructure;
  FDelimiter := ';';
  FExtInsert := False;
  FAddLocks := True;
  FDisableKeys := False;
  FRewriteFile := True;   // ptook
  FIncludeHeader := True; // ptook
end;

destructor TMySQLDump.Destroy;
begin
  FTableList.Free;
  inherited Destroy;
end;

Procedure TMySQLDump.Notification( AComponent: TComponent; Operation: TOperation );
begin
  Inherited Notification( AComponent, Operation );
end;

procedure TMySQLDump.SetDatabase(const Value : TMySQLDatabase);
begin
   if Value <> FDatabase then
      FDatabase := Value;
end;

procedure TMySQLDump.SetSQLFile(const Value : TFileName);
begin
   if FSQLFile <> Value then
      FSQLFile := Value;
end;

procedure TMySQLDump.SetTableList(const Value : TStrings);
begin
   FTableList.Assign(Value);
end;

procedure TMySQLDump.SetDumpOption(const Value :TDumpOption);
begin
   if FDumpOption <> Value then
      FDumpOption := Value;
end;

procedure TMySQLDump.SetDropObject(const Value : Boolean);
begin
   if FDropObject <> Value then
      FDropObject := Value;
end;

procedure TMySQLDump.SetUseCreateDB(const Value : Boolean);
begin
   if FUseCreateDB <> Value then
      FUseCreateDB := Value;
end;

procedure TMySQLDump.SetDelimiter(const Value : String);
begin
   if FDelimiter <> Value then
      FDelimiter := Value;
end;

procedure TMySQLDump.SetExtInsert(const Value : Boolean);
begin
   if FExtInsert <> Value then
      FExtInsert := Value;
end;

procedure TMySQLDump.SetAddLocks(const Value : Boolean);
begin
   if FAddLocks <> Value then
      FAddLocks := Value;
end;

procedure TMySQLDump.SetDisableKeys(const Value : Boolean);
begin
   if FDisableKeys <> Value then
      FDisableKeys := Value;
end;

procedure TMySQLDump.WriteHeader(Host,DBName,SrvVer : String);
begin
  WriteLn(F,Format('--  MySQL Database Dump %s',[DUMP_VERSION]));
  WriteLn(F,Format('--  Host: %s    Database: %s',[Host,DBName]));
  WriteLn(F,Format('--  Server version %s',[SrvVer]));
  WriteLn(F,'--');
  WriteLn(F,Format('--  Dump database %s on %s',[DBName,DateTimeToStr(Now)]));
  WriteLn(F,'--');
  WriteLn(F,'');
end;

procedure TMySQLDump.Init_dumping(Database : String);
begin
   if FUseCreateDb then
   begin
      WriteLn(F,Format('CREATE DATABASE /*!32312 IF NOT EXISTS*/ %s%s',[Database,FDelimiter]));
      WriteLn(F,Format('USE %s%s'+#13#10,[Database,FDelimiter]));
   end;
end;

procedure TMySQLDump.GetTableStructure(Table :String);
var
  SQL : String;
  Res : TMysqlResult;
  A   : Boolean;
begin
   Res := TMySQLClient(TNativeConnect(FDatabase.Handle).Handle).query(Format('SHOW CREATE TABLE %s',[Table]),True, A);
   SQL := Res.FieldValue(1);
   Res.Free;
   WriteLn(F,'--');
   WriteLn(F,Format('--  Table structure for table "%s"',[Table]));
   WriteLn(F,'--');
   if FDropObject then WriteLn(F,Format('DROP TABLE IF EXISTS %s%s'+#13#10,[Table,FDelimiter]));
   WriteLn(F,SQL+FDelimiter+#13#10);
end;

procedure TMySQLDump.GetTableData(Table : String);
var
   Ins_tmp : String;
   I,Rows : Integer;
   S1 : String;
   Percent : Integer;
   A : Boolean;
   Res : TMysqlResult;
begin
  Res := TMySQLClient(TNativeConnect(FDatabase.Handle).Handle).query(Format('select * from %s',[Table]),True, A);
  Rows := res.RowsCount;
  if Rows = 0 then
  begin
     Res.Free;
     Exit;
  end;
  if FDisableKeys then
     WriteLn(F,Format('/*!40000 ALTER TABLE %s DISABLE KEYS */%s',[Table, FDelimiter]));
  WriteLn(F,'--');
  WriteLn(F,Format('--  Table data for table "%s". Record count - %s ',[Table,IntToStr(Rows)]));
  WriteLn(F,'--');
  if FAddLocks then
     WriteLn(F,Format('LOCK TABLES %s WRITE%s',[Table,FDelimiter]));
  WriteLn(F,'');

  ins_tmp := Format('INSERT INTO %s VALUES',[Table]);
  // Added for ExtendInsert support
  if ExtInsert and not (Res.RowsCount =0) then
     Write(F,Ins_tmp);
  // End modification
  while not Res.Eof do
  begin
     S1:='';
     Res.FetchLengths;
     for I := 0 to Res.FieldsCount-2 do
     begin
        if Res.FieldValue(I) = nil then
           S1 := S1 +'NULL'+',' else
           begin
              if isBLOB(Res.FieldDef(I)) or (Res.FieldDef(I).FieldType in [FIELD_TYPE_VAR_STRING, FIELD_TYPE_STRING])  then
                 S1 := S1 + ''''+StrValue(Res.FieldValue(I),Res.FieldLenght(I))+''','else
                 begin
                    if Res.FieldDef(I).FieldType in [FIELD_TYPE_TIMESTAMP, FIELD_TYPE_DATE, FIELD_TYPE_TIME, FIELD_TYPE_DATETIME] then
                       S1 := S1 + ''''+Res.FieldValue(I)+''',' else
                       S1 := S1 + Res.FieldValue(I)+',';
                 end;
           end;
     end;
     if Res.FieldValue(Res.FieldsCount-1) = nil then
        S1 := S1 +'NULL' else
        begin
           if isBLOB(Res.FieldDef(Res.FieldsCount-1)) or (Res.FieldDef(Res.FieldsCount-1).FieldType in [FIELD_TYPE_VAR_STRING, FIELD_TYPE_STRING])  then
               S1 := S1 + ''''+StrValue(Res.FieldValue(Res.FieldsCount-1),Res.FieldLenght(Res.FieldsCount-1))+'''' else
               begin
                  if Res.FieldDef(Res.FieldsCount-1).FieldType in [FIELD_TYPE_TIMESTAMP, FIELD_TYPE_DATE, FIELD_TYPE_TIME, FIELD_TYPE_DATETIME] then
                     S1 := S1 + ''''+Res.FieldValue(Res.FieldsCount-1)+'''' else
                     S1 := S1 + Res.FieldValue(Res.FieldsCount-1);
               end;
        end;
     // Added for ExtendInsert support
     if Not ExtInsert then
     begin
        S1 := Format('%s (%s)%s',[ins_tmp,S1,FDelimiter]);
        WriteLn(F,S1);
     end else
     begin
        if Res.RecNo = 0 then
           S1 := Format('(%s)',[S1]) else
           S1 := Format(',(%s)',[S1]);
        Write(F, S1);
     end;
     // End modification
     if Assigned(FonDataProcess) then
     begin
        Percent := Trunc(Res.RecNo*100/(Rows-1));
        FOnDataProcess(Self, Percent);
        Application.ProcessMessages;
     end;
     Res.Next;
  end;
  // Added for ExtendInsert support
  if ExtInsert and not (Res.RowsCount =0) then
  begin
     S1 := FDelimiter;
     WriteLn(F,S1);
  end;
  Res.Free;
  WriteLn(F,'');
  // End modification
  if FDisableKeys then
     WriteLn(F,Format('/*!40000 ALTER TABLE %s ENABLE KEYS */%s',[Table,FDelimiter]));
  WriteLn(F,'');
  if FAddLocks then
     WriteLn(F,Format('UNLOCK TABLES%s',[FDelimiter]));
  WriteLn(F,'');
end;

procedure TMySQLDump.GetTableStructureData(Table : String);
begin
   GetTableStructure(Table);
   GetTableData(Table);
end;

procedure TMySQLDump.UnloadDb;
var
   I : Integer;
   Percent : Integer;
begin
   AssignFile(F,FSQLFile);
   if FRewriteFile then
     Rewrite(F)
   else Append(F);
   FDatabase.Connected := True;
   if FIncludeHeader then
    WriteHeader(FDatabase.Host,FDatabase.DatabaseName,FDatabase.GetServerInfo);
   Init_dumping(FDatabase.DatabaseName);
   for I :=0 to FTableList.Count-1 do
   begin
      FDatabase.Execute(Format('LOCK TABLES %s READ',[FTableList[I]]));
      if Assigned(FonProcess) then
      begin
         Percent := Trunc((I+1)*100 / FTableList.Count);
         FOnProcess(Self, FTableList[I],Percent);
         Application.ProcessMessages;
      end;
      case FDumpOption of
          dStructure : GetTableStructure(FTableList[I]);
          dData      : GetTableData(FTableList[I]);
          dAll       : GetTableStructureData(FTableList[I]);
      end;
      FDatabase.Execute('UNLOCK TABLES');
   end;
   CloseFile(F);
end;

function TMySQLDump.Execute: Boolean;
begin
   Result := False;
   if FDatabase = nil then Exit;
   if FSQLFile = '' then
      FSQLFile := FDatabase.DatabaseName+'.sql';
   try
     UnloadDB;
     Result := True;
     if Assigned(FonFinish) then FonFinish(Self);
   except
     Raise;
   end;
end;

end.




