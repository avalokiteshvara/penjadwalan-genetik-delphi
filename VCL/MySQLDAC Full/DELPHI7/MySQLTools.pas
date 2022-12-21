{$I mysqldac.inc}
unit MySQLTools;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  MySQLDBTables, uMyDMClient, MySQLAccess;

type
  TMySQLOperation = (oOptimize, oCheck,oAnalyze,oRepair,oBackup,oRestore);

  TCheckOption = (coQuick,coFast,coMedium,coExtended,coChanged);
  TRepairOption = (roQuick,roExtended);

  TErrorEvent = procedure(TableName,ErrorMessage: String) of object;
  TSuccessEvent = procedure(TableName,Status: String) of object;

  TMySQLTools = class(TComponent)
  private
    { Private declarations }
    FAbout   : TmySQLDACAbout;
    FDatabase : TMySQLDatabase;
    FQuery    : TMySQLQuery;
    FTableList : TStrings;
    FDirectory : String;
    FMySQLOperation : TMySQLOperation;
    FCheckOption : TCheckOption;
    FRepairOption : TRepairOption;
    FOnError: TErrorEvent;
    FOnSuccess: TSuccessEvent;
    procedure SetDatabase(const Value : TMySQLDatabase);
    procedure SetTableList(Const Value : TStrings);
    procedure SetMySQLOperation(const Value : TMySQLOperation);
    procedure SetCheckOption(const Value : TCheckOption);
    procedure SetRepairOption(const Value : TRepairOption);
    procedure SetDirectory(const Value : String);
    procedure SetOnError(const Value: TErrorEvent);
    procedure SetOnSuccess(const Value: TSuccessEvent);
  protected
    { Protected declarations }
    Procedure Notification( AComponent: TComponent; Operation: TOperation ); Override;

    function GetOptimizeSQL: string;
    function GetCheckSQL: string;
    function GetAnalyzeSQL: string;
    function GetRepairSQL: string;
    function GetBackupSQL: string;
    function GetRestoreSQL: string;
  public
    { Public declarations }
    Constructor Create(Owner : TComponent); override;
    destructor Destroy; override;
    function Execute: Boolean;
  published
    { Published declarations }
    property About : TmySQLDACAbout read FAbout write FAbout;
    property Database  : TMySQLDatabase read FDatabase write SetDatabase;
    property TableList : TStrings read FTableList write SetTableList;
    property MySQLOperation : TMySQLOperation read FMySQLOperation write SetMySQLOperation default oCheck;
    property CheckOption : TCheckOption read FCheckOption write SetCheckOption default coQuick;
    property RepairOption : TRepairOption read FRepairOption write SetRepairOption default roQuick;
    property Directory : String read FDirectory Write SetDirectory;
    property OnError: TErrorEvent read FOnError write SetOnError;
    property OnSuccess: TSuccessEvent read FOnSuccess write SetOnSuccess;
  end;

implementation

uses MySQLMonitor;

Constructor TMySQLTools.Create(Owner : TComponent);
begin
  inherited Create(Owner);
  FTableList := TStringList.Create;
  FMySQLOperation := oCheck;
  FCheckOption := coQuick;
  FRepairOption := roQuick;
  FQuery := TMySQLQuery.Create(nil);
end;

destructor TMySQLTools.Destroy;
begin
  if FQuery <> nil then
  begin
     FQuery.Free;
     FQuery := nil;
  end;
  FTableList.Free;
  inherited Destroy;
end;

Procedure TMySQLTools.Notification( AComponent: TComponent; Operation: TOperation );
begin
  Inherited Notification( AComponent, Operation );
  if (Operation = opRemove) and (AComponent = FDatabase) then
     FDatabase := nil;
end;

procedure TMySQLTools.SetDatabase(const Value : TMySQLDatabase);
begin
   if Value <> FDatabase then
      FDatabase := Value;
end;

procedure TMySQLTools.SetTableList(Const Value : TStrings);
begin
   FTableList.Assign(Value);
end;

procedure TMySQLTools.SetMySQLOperation(const Value : TMySQLOperation);
begin
   if FMySQLOperation <> Value then
      FMySQLOperation := Value;
end;

procedure TMySQLTools.SetCheckOption(const Value : TCheckOption);
begin
   if FCheckOption <> Value then
      FCheckOption := Value;
end;

procedure TMySQLTools.SetRepairOption(const Value : TRepairOption);
begin
   if FRepairOption <> Value then
      FRepairOption := Value;
end;

procedure TMySQLTools.SetDirectory(const Value : String);
begin
   if FDirectory <> Value then
      FDirectory := Value;
end;

function TMySQLTools.GetOptimizeSQL: string;
var
  I : Integer;
  S : String;
begin
   S := 'OPTIMIZE TABLE ';
   for I:= 0 to FTableList.Count-2 do
       S := S+FTableList[I]+',';
   S := S+FTableList[FTableList.Count-1];
   Result := S;
end;

function TMySQLTools.GetCheckSQL: string;
var
  I : Integer;
  S : String;
begin
   S := 'CHECK TABLE ';
   for I:= 0 to FTableList.Count-2 do
       S := S+FTableList[I]+',';
   S := S+FTableList[FTableList.Count-1]+' ';
   case FCheckOption of
     coQuick   : S := S+'QUICK';
     coFast    : S := S+'FAST';
     coMedium  : S := S+'MEDIUM';
     coExtended: S := S+'EXTENDED';
     coChanged : S := S+'CHANGED';
   end;
   Result := S;
end;

function TMySQLTools.GetAnalyzeSQL: string;
var
  I : Integer;
  S : String;
begin
   S := 'ANALYZE TABLE ';
   for I:= 0 to FTableList.Count-2 do
       S := S+FTableList[I]+',';
   S := S+FTableList[FTableList.Count-1];
   Result := S;
end;

function TMySQLTools.GetRepairSQL: string;
var
  I : Integer;
  S : String;
begin
   S := 'REPAIR TABLE ';
   for I:= 0 to FTableList.Count-2 do
       S := S+FTableList[I]+',';
   S := S+FTableList[FTableList.Count-1]+' ';
   case FRepairOption of
     roQuick   : S := S+'QUICK';
     roExtended: S := S+'EXTENDED';
   end;
   Result := S;
end;

function TMySQLTools.GetBackupSQL: string;
var
  I : Integer;
  S : String;
begin
   S := 'BACKUP TABLE ';
   for I:= 0 to FTableList.Count-2 do
       S := S+FTableList[I]+',';
   S := S+FTableList[FTableList.Count-1]+' TO ';
   S := S+''''+FDirectory+'''';
   Result := S;
end;

function TMySQLTools.GetRestoreSQL: string;
var
  I : Integer;
  S : String;
begin
   S := 'RESTORE TABLE ';
   for I:= 0 to FTableList.Count-2 do
       S := S+FTableList[I]+', ';
   S := S+FTableList[FTableList.Count-1]+' FROM ';
   S := S+''''+Directory+'''';
   Result := S;
end;

function TMySQLTools.Execute: Boolean;
var
  Query: TMysqlResult;
  a: boolean;
  SQL: string;
begin
   Result := False;
   if FDatabase = nil then Exit;
   if FTableList.Count = 0 then Exit;
   case FMySQLOperation of
     oOptimize : SQL := GetOptimizeSQL;
     oCheck    : SQL := GetCheckSQL;
     oAnalyze  : SQL := GetAnalyzeSQL;
     oRepair   : SQL := GetRepairSQL;
     oBackup   : SQL := GetBackupSQL;
     oRestore  : SQL := GetRestoreSQL;
   end;
   Query := TNativeConnect(FDatabase.Handle).Handle.query(PChar(SQL), True, a);
   try
     if a and Assigned(Query) then begin
       Query.First;
       while not Query.Eof do begin
         if Query.FieldValueByName('msg_type') = 'error' then begin
            if Assigned(FOnError) then FOnError(Query.FieldValueByName('Table'),
             Query.FieldValueByName('msg_text'));
         end else begin
            if Assigned(FOnSuccess) then FOnSuccess(Query.FieldValueByName('Table'),
              Query.FieldValueByName('msg_text'));
         end;
         Query.Next;
       end;
     end;
     MonitorHook.SQLExecute(TNativeConnect(FDatabase.Handle), SQL, a);
   finally
     if Assigned(Query) then Query.Free();
   end;
   Result := True;
end;

procedure TMySQLTools.SetOnError(const Value: TErrorEvent);
begin
  FOnError := Value;
end;

procedure TMySQLTools.SetOnSuccess(const Value: TSuccessEvent);
begin
  FOnSuccess := Value;
end;


end.
