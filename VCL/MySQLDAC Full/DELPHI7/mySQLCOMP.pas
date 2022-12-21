{$I mysqldac.inc}
unit mySQLCOMP;

interface

Uses Windows,Messages,SysUtils,Classes, Graphics, Controls,Forms, Dialogs,
     {$IFDEF DELPHI_6}DesignIntf,DesignEditors {$ELSE}DsgnIntf{$ENDIF},
     Db,mySQLFldLinks,mySQLDbTables,MySQLupdsqled,MySQLMacroQuery,MySQLMigrator,
     MySQLMonitor,MySQLBatch,MySQLDump,MySQLTools;

type
    TAboutProperty = class(TPropertyEditor)
    Public
      procedure Edit; override;
      function  GetAttributes: TPropertyAttributes; override;
      function  GetValue: string; override;
    end;

    TmySQLTableNamePropertyEditor =  Class(TStringProperty)
    Public
      Function  GetAttributes: TPropertyAttributes; Override;
      Procedure GetValueList(List: TStrings);
      Procedure GetValues(Proc: TGetStrProc); Override;
    end;

    TmySQLIndexNamePropertyEditor =  Class(TStringProperty)
    Public
      Function  GetAttributes: TPropertyAttributes; Override;
      Procedure GetValueList(List: TStrings);
      Procedure GetValues(Proc: TGetStrProc); Override;
  end;


  TmySQLIndexFieldNamesPropertyEditor = Class(TStringProperty)
    Public
      Function  GetAttributes: TPropertyAttributes; Override;
      Procedure GetValueList(List: TStrings);
      Procedure GetValues(Proc: TGetStrProc); Override;
  end;

  { TmySQLTableFieldLinkProperty }
  TmySQLTableFieldLinkProperty = class(TmySQLFieldLinkProperty)
  private
    FTable: TmySQLTable;
  protected
    procedure GetFieldNamesForIndex(List: TStrings); override;
    function GetIndexBased: Boolean; override;
    function GetIndexDefs: TIndexDefs; override;
    function GetIndexFieldNames: string; override;
    function GetIndexName: string; override;
    function GetMasterFields: string; override;
    procedure SetIndexFieldNames(const Value: string); override;
    procedure SetIndexName(const Value: string); override;
    procedure SetMasterFields(const Value: string); override;
  public
    property IndexBased: Boolean read GetIndexBased;
    property IndexDefs: TIndexDefs read GetIndexDefs;
    property IndexFieldNames: string read GetIndexFieldNames write SetIndexFieldNames;
    property IndexName: string read GetIndexName write SetIndexName;
    property MasterFields: string read GetMasterFields write SetMasterFields;
    procedure Edit; override;
  end;

  TmySQLDataSourcePropertyEditor =  Class(TComponentProperty)
  Private
    FCheckProc: TGetStrProc;
    Procedure CheckComponent( const Value : string );
  Public
    Procedure GetValues(Proc: TGetStrProc); override;
  end;

  TMySQLDatabaseEditor = class(TComponentEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

  TMySQLUpdateSQLEditor = class(TComponentEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

Procedure Register;
Procedure RegisterPropertyEditors;

implementation
{$R DBPRO.DCR}

Uses {$IFNDEF DELPHI_4}BDEConst{$ELSE}DsnDBCst{$ENDIF},TypInfo,mySQLAboutFrm,mySQLConnFrm;

type
  TMigrateExecutePropertyEditor = class(TPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
  end;

procedure TMigrateExecutePropertyEditor.Edit;
begin
   TBDE2MySQLDAC(GetComponent(0)).Migrate;
end;

function TMigrateExecutePropertyEditor.GetAttributes: TPropertyAttributes;
begin
   Result := [paDialog, paReadOnly];
end;

function TMigrateExecutePropertyEditor.GetValue: string;
begin
   Result := 'Press to Migrate...';
end;

function GetPropertyValue(Instance: TPersistent; const PropName: string): TPersistent;
var
  PropInfo: PPropInfo;
begin
  Result := nil;
  PropInfo := TypInfo.GetPropInfo(Instance.ClassInfo, PropName);
  if (PropInfo <> nil) and (PropInfo^.PropType^.Kind = tkClass) then
    Result := TObject(GetOrdProp(Instance, PropInfo)) as TPersistent;
end;

function GetIndexDefs(Component: TPersistent): TIndexDefs;
var
  DataSet: TDataSet;
begin
  DataSet := Component as TDataSet;
  Result := GetPropertyValue(DataSet, 'IndexDefs') as TIndexDefs;
  if Assigned(Result) then
  begin
    Result.Updated := False;
    Result.Update;
  end;
end;

{About Property}
function TAboutProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly]
end;

procedure TAboutProperty.Edit;
begin
  with TMySQLAboutComp.Create(Application) do
  try
    VersionLabel.Caption := 'V.'+mySQLDBTables.Version;
    {$IFDEF TRIAL}
    RegLabel.Caption := 'Trial version.';
    {$ELSE}
    RegLabel.Caption := 'Registered version.';
    {$ENDIF}
    Label1.Caption := GetComponent(0).ClassName;
    ShowModal;
  finally
    Free;
  end;
end;

function TAboutProperty.GetValue: string;
begin
  Result := 'About...';
end;

{mySQLTableName}
Function TmySQLTableNamePropertyEditor.GetAttributes : TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paMultiSelect];
end;

Procedure TmySQLTableNamePropertyEditor.GetValues(Proc: TGetStrProc);
var
  I      : Integer;
  Values : TStringList;
begin
  Values := TStringList.Create;
  Try
    GetValueList(Values);
    for I := 0 to Values.Count - 1 do  Proc(Values[I]);
  Finally
    Values.Free;
  end;
end;

Procedure TmySQLTableNamePropertyEditor.GetValueList(List: TStrings);
var
  Table: TmySQLTable;
begin
  Table := GetComponent(0) as TmySQLTable;
  if Table.Database = nil then raise EDatabaseError.Create('Database property is not set');
  Table.Database.GetTableNames('',List, True);
end;

{TmySQLIndexName}
Function TmySQLIndexNamePropertyEditor.GetAttributes : TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paMultiSelect];
end;

Procedure TmySQLIndexNamePropertyEditor.GetValues(Proc: TGetStrProc);
var
  I      : Integer;
  Values : TStringList;
begin
  Values := TStringList.Create;
  Try
    GetValueList( Values );
    for I := 0 to Values.Count - 1 do Proc(Values[I]);
  Finally
    Values.Free;
  end;
end;

Procedure TmySQLIndexNamePropertyEditor.GetValueList(List : TStrings);
begin
  (GetComponent(0) as TmySQLTable).GetIndexNames(List);
end;

{TmySQLIndexFieldNamesPropertyEditor}
Function TmySQLIndexFieldNamesPropertyEditor.GetAttributes : TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paMultiSelect];
end;

Procedure TmySQLIndexFieldNamesPropertyEditor.GetValues(Proc: TGetStrProc);
var
  I      : Integer;
  Values : TStringList;
begin
  Values := TStringList.Create;
  Try
    GetValueList(Values);
    for I := 0 to Values.Count-1 do Proc(Values[I]);
  Finally
    Values.Free;
  end;
end;

Procedure TmySQLIndexFieldNamesPropertyEditor.GetValueList( List : TStrings );
var
  I: Integer;
  IndexDefs: TIndexDefs;
begin
  IndexDefs := GetIndexDefs(GetComponent(0));
  for I := 0 to IndexDefs.Count - 1 do
    with IndexDefs[I] do
      if (Options * [ixExpression, ixDescending] = []) and (Fields <> '') then List.Add(Fields);
end;

{ TmySQLTableFieldLinkProperty }
procedure TmySQLTableFieldLinkProperty.Edit;
var
  Table: TmySQLTable;
begin
  Table := DataSet as TmySQLTable;
  FTable := TmySQLTable.Create(nil);
  try
    FTable.Database := Table.Database;
    FTable.TableName := Table.TableName;
    if Table.IndexFieldNames <> '' then
      FTable.IndexFieldNames := Table.IndexFieldNames else
      FTable.IndexName := Table.IndexName;
    FTable.MasterFields := Table.MasterFields;
    FTable.Open;
    inherited Edit;
    if Changed then
    begin
      Table.MasterFields := FTable.MasterFields;
      if FTable.IndexFieldNames <> '' then
        Table.IndexFieldNames := FTable.IndexFieldNames else
        Table.IndexName := FTable.IndexName;
    end;
  finally
    FTable.Free;
  end;
end;

procedure TmySQLTableFieldLinkProperty.GetFieldNamesForIndex(List: TStrings);
var
  i: Integer;
begin
  for i := 0 to FTable.IndexFieldCount - 1 do
    List.Add(FTable.IndexFields[i].FieldName);
end;

function TmySQLTableFieldLinkProperty.GetIndexBased: Boolean;
begin
  Result := {$IFDEF DELPHI_4} not True{$ELSE}not IProviderSupport(FTable).PSIsSQLBased{$ENDIF};
end;

function TmySQLTableFieldLinkProperty.GetIndexDefs: TIndexDefs;
begin
  Result := FTable.IndexDefs;
end;

function TmySQLTableFieldLinkProperty.GetIndexFieldNames: string;
begin
  Result := FTable.IndexFieldNames;
end;

function TmySQLTableFieldLinkProperty.GetIndexName: string;
begin
  Result := FTable.IndexName;
end;

function TmySQLTableFieldLinkProperty.GetMasterFields: string;
begin
  Result := FTable.MasterFields;
end;

procedure TmySQLTableFieldLinkProperty.SetIndexFieldNames(const Value: string);
begin
  FTable.IndexFieldNames := Value;
end;

procedure TmySQLTableFieldLinkProperty.SetIndexName(const Value: string);
begin
  if Value = 'Primary' then
    FTable.IndexName := '' else
    FTable.IndexName := Value;
end;

procedure TmySQLTableFieldLinkProperty.SetMasterFields(const Value: string);
begin
  FTable.MasterFields := Value;
end;

{mySQLDataSource}
Procedure TmySQLDataSourcePropertyEditor.CheckComponent( const Value : string );
var
  J: Integer;
  DataSource: TDataSource;
begin
  DataSource := TDataSource( Designer.GetComponent(Value ) );
  for J := 0 to Pred( PropCount ) do
    if TDataSet( GetComponent( J ) ).IsLinkedTo( DataSource ) then
      Exit;
  FCheckProc( Value );
end;

Procedure TmySQLDataSourcePropertyEditor.GetValues( Proc : TGetStrProc );
begin
  FCheckProc := Proc;
  Inherited GetValues( CheckComponent );
end;

{MySQLDatabase Editor}
procedure TMySQLDatabaseEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: if EditDatabase(TMySQLDatabase(Component)) then Designer.Modified;
  end;
end;

function TMySQLDatabaseEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'TMySQLDatabase Editor...';
  end;
end;

function TMySQLDatabaseEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure TMySQLUpdateSQLEditor.ExecuteVerb(Index: Integer);
begin
  if EditMySQLUpdateSQL(TMySQLUpdateSQL(Component)) then Designer.Modified;
end;

function TMySQLUpdateSQLEditor.GetVerb(Index: Integer): string;
begin
  Result := '&MySQLUpdateSQL Editor...';
end;

function TMySQLUpdateSQLEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;



Procedure RegisterPropertyEditors;
begin
    RegisterPropertyEditor(TypeInfo(TFileName),TmySQLTable,'TableName',TmySQLTableNamePropertyEditor);
    RegisterPropertyEditor(TypeInfo(string),TmySQLTable,'IndexName',TmySQLIndexNamePropertyEditor);
    RegisterPropertyEditor(TypeInfo(string),TmySQLTable,'IndexFieldNames',TmySQLIndexFieldNamesPropertyEditor);
    RegisterPropertyEditor(TypeInfo(TDataSource),TmySQLTable,'MasterSource',TmySQLDataSourcePropertyEditor);
    RegisterPropertyEditor(TypeInfo(string),TmySQLTable,'MasterFields',TmysqlTableFieldLinkProperty);
    RegisterPropertyEditor(TypeInfo(TmySQLDACAbout),nil,'',TAboutProperty);
    RegisterPropertyEditor(TypeInfo(Boolean), TBDE2MySQLDAC, 'Execute', TMigrateExecutePropertyEditor);
end;

procedure Register;
begin
  RegisterComponents('DAC for mySQL™',[TmySQLDatabase,TmySQLTable,TmySQLQuery,TmySQLUpdateSQL,
                                  TMySQLMacroQuery,TBDE2MySQLDAC,TMySQLBatchExecute,TMySQLMonitor,
                                  TMySQLDump,TMySQLTools] );
  RegisterComponentEditor(TMySQLDatabase, TMySQLDatabaseEditor);
  RegisterComponentEditor(TMySQLUpdateSQL,TMySQLUpdateSQLEditor);
  RegisterPropertyEditors;
end;

end.

