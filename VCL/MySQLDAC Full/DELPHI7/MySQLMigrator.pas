{$I mysqldac.inc}
unit MySQLMigrator;

interface
uses Classes, DB, MySQLDBTables, Forms, SysUtils,DBTables;

type

  PDataSetPair = ^TDataSetPair;
  TDataSetPair = record
    OldDataSet,
    NewDataSet: TDataSet;
  end;

  TDataSetList = class(TList)
  private
    function GetDataSetPairs(Index: Integer): PDataSetPair;
    procedure SetDataSetPairs(Index: Integer; Item: PDataSetPair);
    function GetOldDataSets(Index: Integer): TDataSet;
    procedure SetOldDataSets(Index: Integer; Item: TDataSet);
    function GetNewDataSets(Index: Integer): TDataSet;
    procedure SetNewDataSets(Index: Integer; Item: TDataSet);
  public
    function GetPaired(aDataSet: TDataSet): TDataSet;
    function IndexOfOldDataSet(aDataSet: TDataSet): Integer;
    procedure DeletePair(Index: Integer);
    procedure ClearAll;
    destructor Destroy; override;
    property Pairs[Index: Integer]: PDataSetPair read GetDataSetPairs write SetDataSetPairs;
    property OldDataSets[Index: Integer]: TDataSet read GetOldDataSets write SetOldDataSets;
    property NewDataSets[Index: Integer]: TDataSet read GetNewDataSets write SetNewDataSets;
  end;

  TBDE2MySQLDAC = class(TComponent)
  private
    FAbout   : TmySQLDACAbout;
    FMySQLDatabase: TMySQLDatabase;
    FDataSets: TDataSetList;
    FFields: TList;
    FExecute: Boolean;
    function GetDatabase: TMySQLDatabase;
    procedure SetDatabase(Value: TMySQLDatabase);
  protected
    { Common methods }
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure MigrateTables;
    procedure MigrateDataSources;
    procedure UpdateDesignInfo(OldDataSet, NewComponent: TComponent);
    procedure AssignEvents(aDataSet: TMySQLDataSet; OldDataSet: TDataSet);
    procedure AssignFields(OldField, NewField: TField);
    procedure NewDataSetPair(aDataSet: TMySQLDataSet; OldDataSet: TDataSet);
    procedure MoveFields(aDataSet: TMySQLDataSet; OldDataSet: TDataSet);
    procedure AssignLookupFields(OldDataSet: TDataSet);
    procedure CreateMySQLDataSet(aDataSet: TMySQLDataSet; OldDataSet: TDataSet);
    procedure CheckDataSet(OldDataSet: TDataSet);
    function CheckForFree(aComponent: TComponent): boolean;
    procedure GetNeededSQLs(aDataSet: TMySQLDataSet; OldDataSet: TDataSet);
    procedure GetCachedUpdates(aDataSet: TMySQLDataSet; OldDataSet: TDataSet);
    procedure GetNeededUpdateObject(aDataSet: TMySQLDataSet; OldDataSet: TDataSet);
  public
    procedure Migrate; virtual;
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  published
    property About : TmySQLDACAbout read FAbout write FAbout;
    property Database: TMySQLDatabase read GetDatabase write SetDatabase;
    property Execute: Boolean read FExecute write FExecute;
  end;


implementation
uses Dialogs,Controls;

{ TDataSetList }
function TDataSetList.GetDataSetPairs(Index: Integer): PDataSetPair;
begin
  Result := PDataSetPair(Items[Index]);
end;

function TDataSetList.GetNewDataSets(Index: Integer): TDataSet;
begin
  Result := Pairs[Index].NewDataSet;
end;

function TDataSetList.GetOldDataSets(Index: Integer): TDataSet;
begin
  Result := Pairs[Index].OldDataSet;
end;

procedure TDataSetList.SetDataSetPairs(Index: Integer; Item: PDataSetPair);
begin
  Items[Index] := Item;
end;

procedure TDataSetList.SetNewDataSets(Index: Integer; Item: TDataSet);
begin
  Pairs[Index].NewDataSet := Item;
end;

procedure TDataSetList.SetOldDataSets(Index: Integer; Item: TDataSet);
begin
  Pairs[Index].OldDataSet := Item;
end;

function TDataSetList.GetPaired(aDataSet: TDataSet): TDataSet;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count-1 do
    if OldDataSets[I] = aDataSet then
    begin
       Result := NewDataSets[I];
       exit;
    end;
end;

function TDataSetList.IndexOfOldDataSet(aDataSet: TDataSet): Integer;
var Index: Integer;
begin
  Result := -1;
  for Index := 0 to pred(Count) do
    if OldDataSets[Index] = aDataSet then begin
      Result := Index;
      exit;
    end;
end;

procedure TDataSetList.ClearAll;
var Index: Integer;
begin
  for Index := pred(Count) downto 0 do DeletePair(Index);
end;

procedure TDataSetList.DeletePair(Index: Integer);
begin
  FreeMem(PDataSetPair(Items[Index]));
  Delete(Index);
end;

destructor TDataSetList.Destroy;
begin
  ClearAll;
  inherited;
end;

{ TBDE2MySQLDAC }
function TBDE2MySQLDAC.GetDatabase: TMySQLDatabase;
begin
  Result := FMySQLDatabase;
end;

procedure TBDE2MySQLDAC.SetDatabase(Value: TMySQLDatabase);
begin
  FMySQLDatabase := Value;
  if Value <> nil then Value.FreeNotification(Self)
end;


procedure TBDE2MySQLDAC.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (aComponent = FMySQLDatabase) then
     FMySQLDatabase := nil;
end;

procedure TBDE2MySQLDAC.AssignEvents(aDataSet: TMySQLDataSet;
  OldDataSet: TDataSet);
begin
  with OldDataSet do begin
    aDataSet.BeforeOpen     := BeforeOpen;
    aDataSet.AfterOpen      := AfterOpen ;
    aDataSet.BeforeClose    := BeforeClose;
    aDataSet.AfterClose     := AfterClose;
    aDataSet.BeforeInsert   := BeforeInsert;
    aDataSet.AfterInsert    := AfterInsert;
    aDataSet.BeforeEdit     := BeforeEdit;
    aDataSet.AfterEdit      := AfterEdit;
    aDataSet.BeforePost     := BeforePost;
    aDataSet.AfterPost      := AfterPost;
    aDataSet.BeforeCancel   := BeforeCancel;
    aDataSet.AfterCancel    := AfterCancel;
    aDataSet.BeforeDelete   := BeforeDelete;
    aDataSet.AfterDelete    := AfterDelete;
    aDataSet.BeforeScroll   := BeforeScroll;
    aDataSet.AfterScroll    := AfterScroll;
    aDataSet.OnCalcFields   := OnCalcFields;
    aDataSet.OnDeleteError  := OnDeleteError;
    aDataSet.OnEditError    := OnEditError;
    aDataSet.OnFilterRecord := OnFilterRecord;
    aDataSet.OnNewRecord    := OnNewRecord;
    aDataSet.OnPostError    := OnPostError;
    BeforeOpen     := nil;
    AfterOpen      := nil;
    BeforeClose    := nil;
    AfterClose     := nil;
    BeforeInsert   := nil;
    AfterInsert    := nil;
    BeforeEdit     := nil;
    AfterEdit      := nil;
    BeforePost     := nil;
    AfterPost      := nil;
    BeforeCancel   := nil;
    AfterCancel    := nil;
    BeforeDelete   := nil;
    AfterDelete    := nil;
    BeforeScroll   := nil;
    AfterScroll    := nil;
    OnCalcFields   := nil;
    OnDeleteError  := nil;
    OnEditError    := nil;
    OnFilterRecord := nil;
    OnNewRecord    := nil;
    OnPostError    := nil;
  end;
end;

procedure TBDE2MySQLDAC.AssignFields(OldField, NewField: TField);
var
  s: string;
begin
  with OldField do
  begin
    NewField.FieldName    := FieldName;
    NewField.DisplayLabel := DisplayLabel;
    NewField.FieldKind    := FieldKind;
    NewField.EditMask     := EditMask;
    NewField.Alignment    := Alignment;
    NewField.DefaultExpression := DefaultExpression;
    NewField.DisplayWidth := DisplayWidth;
    NewField.Visible      := Visible;
    NewField.KeyFields := KeyFields;
    NewField.LookupCache := LookupCache;
    NewField.LookupDataSet := FDataSets.GetPaired(LookupDataSet);
    NewField.LookupKeyFields := LookupKeyFields;
    NewField.LookupResultField := LookupResultField;
    NewField.OnChange     := OnChange;
    NewField.OnGetText    := OnGetText;
    NewField.OnSetText    := OnSetText;
    NewField.OnValidate   := OnValidate;
    s := Name;
    Name := 'Die_' + Name;
    NewField.Name := s;
  end
end;

procedure TBDE2MySQLDAC.MoveFields(aDataSet: TMySQLDataSet;  OldDataSet: TDataSet);
begin
  if  OldDataSet.DefaultFields then Exit;
  with OldDataSet do
    while FieldCount > 0 do Fields[0].DataSet := aDataSet;
end;

procedure  TBDE2MySQLDAC.UpdateDesignInfo(OldDataSet, NewComponent: TComponent);
begin
  NewComponent.DesignInfo := OldDataSet.DesignInfo;
  OldDataSet.Owner.RemoveComponent(NewComponent);
  OldDataSet.Owner.InsertComponent(NewComponent);
end;

procedure  TBDE2MySQLDAC.CreateMySQLDataSet(aDataSet: TMySQLDataSet; OldDataSet: TDataSet);
var
   Index, NamePos: integer;
   rName1, rName2: string;
begin
    OldDataSet.Close;
    UpdateDesignInfo(OldDataSet, aDataSet);
    aDataSet.DataBase := FMySQLDatabase;
    GetNeededSQLs(aDataSet, OldDataSet);
    AssignEvents(aDataSet, OldDataSet);
    MoveFields  (aDataSet, OldDataSet);
    GetCachedUpdates(aDataSet, OldDataSet);
    OldDataSet.Name := 'Die_' + OldDataSet.Name;
    aDataSet.Name := Copy(OldDataSet.Name, 5, length(OldDataSet.Name));
    for Index := 0 to pred(aDataSet.FieldCount) do
    begin
       rName1 := aDataSet.Fields[Index].Name;
       NamePos := Pos(aDataSet.Name, rName1);
       if NamePos = 1 then
       begin
          rName2 := Copy(rName1, length(aDataSet.Name) + 1, length(rName1));
          NamePos := Pos(aDataSet.Name, rName2);
          if NamePos = 1 then aDataSet.Fields[Index].Name := rName2;
       end;
    end;
    GetNeededUpdateObject(aDataSet, OldDataSet);
end;

procedure  TBDE2MySQLDAC.MigrateDataSources;
var
    FormIndex, CompIndex: Integer;
    DataSource: TDataSource;
    DataSet: TDataSet;
begin
  for FormIndex := 0 to Pred(Screen.FormCount) do
    with Screen.Forms[FormIndex] do
    begin
       if not (csDesigning in ComponentState) then Continue;
       for CompIndex := 0 to Pred(ComponentCount) do
         if (Components[CompIndex] is TDataSource) then
         begin
            DataSource := (Components[CompIndex] as TDataSource);
            DataSet := nil;
            if FDataSets.IndexOfOldDataSet(DataSource.DataSet) <> -1 then
               DataSet := FDataSets.GetPaired(DataSource.DataSet);
            if DataSet <> nil then
               DataSource.DataSet := DataSet;
         end;
    end;
  for FormIndex := 0 to Pred(Screen.DataModuleCount) do
    with Screen.DataModules[FormIndex] do
    begin
       if not (csDesigning in ComponentState) then Continue;
       for CompIndex := 0 to Pred(ComponentCount) do
         if (Components[CompIndex] is TDataSource) then
         begin
            DataSource := (Components[CompIndex] as TDataSource);
            DataSet := nil;
            if FDataSets.IndexOfOldDataSet(DataSource.DataSet) <> -1 then
               DataSet := FDataSets.GetPaired(DataSource.DataSet);
            if DataSet <> nil then
               DataSource.DataSet := DataSet;
         end;
    end;
end;

procedure  TBDE2MySQLDAC.Migrate;
var
  FormIndex, CompIndex: Integer;
begin
  if not Assigned(FMySQLDatabase) then
    raise Exception.Create('Database not assigned');
  Screen.Cursor := crHourGlass;
  try
    MigrateTables;
    MigrateDataSources;
    for FormIndex := 0 to Pred(Screen.DataModuleCount) do
    with Screen.DataModules[FormIndex] do
    begin
      if not (csDesigning in ComponentState) then Continue;
      CompIndex := 0;
      while CompIndex < ComponentCount do
        if not CheckForFree(Components[CompIndex]) then
           Inc(CompIndex) else
           begin
              if (Components[CompIndex] is TDataSet) then
                  AssignLookupFields(Components[CompIndex] as TDataSet);
              Components[CompIndex].Free;
           end;
    end;
    for FormIndex := 0 to Pred(Screen.FormCount) do
    with Screen.Forms[FormIndex] do
    begin
      if not (csDesigning in ComponentState) then Continue;
      CompIndex := 0;
      while CompIndex < ComponentCount do
        if not CheckForFree(Components[CompIndex]) then
           Inc(CompIndex) else
           begin
              if (Components[CompIndex] is TDataSet) then
                 AssignLookupFields(Components[CompIndex] as TDataSet);
              Components[CompIndex].Free;
           end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TBDE2MySQLDAC.MigrateTables;
var
   FormIndex, CompIndex: Integer;
begin
  for FormIndex := 0 to Pred(Screen.FormCount) do
    with Screen.Forms[FormIndex] do
    begin
      if not (csDesigning in ComponentState) then Continue;
      for CompIndex := 0 to Pred(ComponentCount) do
       if (CompIndex <= pred(ComponentCount)) and
          (Components[CompIndex] is TDataSet) then
          CheckDataSet(Components[CompIndex] as TDataSet);
    end;
  for FormIndex := 0 to Pred(Screen.DataModuleCount) do
    with Screen.DataModules[FormIndex] do
    begin
      if not (csDesigning in ComponentState) then Continue;
      for CompIndex := 0 to Pred(ComponentCount) do
       if (CompIndex <= pred(ComponentCount)) and
          (Components[CompIndex] is TDataSet) then
          CheckDataSet(Components[CompIndex] as TDataSet);
    end;
  for CompIndex := 0 to pred(FDataSets.Count) do
    CreateMySQLDataSet(TMySQLDataSet(FDataSets.NewDataSets[CompIndex]),FDataSets.OldDataSets[CompIndex]);
end;

constructor TBDE2MySQLDAC.Create(aOwner: TComponent);
begin
  inherited;
  FDataSets := TDataSetList.Create;
  FFields := TList.Create;
end;

destructor TBDE2MySQLDAC.Destroy;
begin
  FDataSets.Free;
  FFields.Free;
  inherited;
end;

procedure TBDE2MySQLDAC.NewDataSetPair(aDataSet: TMySQLDataSet; OldDataSet: TDataSet);
var
  Pair: PDataSetPair;
begin
   New(Pair);
   Pair.OldDataSet := OldDataSet;
   Pair.NewDataSet := aDataSet;
   FDataSets.Add(Pair);
end;

procedure TBDE2MySQLDAC.AssignLookupFields(OldDataSet: TDataSet);
var
   FormIndex, CompIndex: Integer;
   LinkField: TField;
begin
  for FormIndex := 0 to Pred(Screen.FormCount) do
    with Screen.Forms[FormIndex] do
    begin
      if not (csDesigning in ComponentState) then Continue;
      for CompIndex := 0 to Pred(ComponentCount) do
        if (Components[CompIndex] is TField) then
        begin
          LinkField := (Components[CompIndex] as TField);
          if (LinkField.LookupDataSet = OldDataSet) then
             LinkField.LookupDataSet := FDataSets.GetPaired(OldDataSet);
        end;
    end;
  for FormIndex := 0 to Pred(Screen.DataModuleCount) do
    with Screen.DataModules[FormIndex] do begin
      if not (csDesigning in ComponentState) then Continue;
      for CompIndex := 0 to Pred(ComponentCount) do
        if (Components[CompIndex] is TField) then begin
          LinkField := (Components[CompIndex] as TField);
          if (LinkField.LookupDataSet = OldDataSet) then
             LinkField.LookupDataSet := FDataSets.GetPaired(OldDataSet);
        end;
    end;
end;

procedure TBDE2MySQLDAC.CheckDataSet(OldDataSet: TDataSet);
var
  aDataSet: TMySQLDataSet;
begin
  if (OldDataSet is TQuery) then
  begin
    aDataSet := TMySQLQuery.Create(OldDataSet.Owner);
    NewDataSetPair(aDataSet, OldDataSet);
  end else
  begin
    aDataSet := TMySQLTable.Create(OldDataSet.Owner);
    NewDataSetPair(aDataSet, OldDataSet);
  end;
end;

function TBDE2MySQLDAC.CheckForFree(aComponent: TComponent): boolean;
begin
   Result := (aComponent is TBDEDataSet);
end;

procedure TBDE2MySQLDAC.GetCachedUpdates(aDataSet: TMySQLDataSet; OldDataSet: TDataSet);
begin
   aDataSet.CachedUpdates := TBDEDataSet(OldDataSet).CachedUpdates;
end;

procedure TBDE2MySQLDAC.GetNeededSQLs(aDataSet: TMySQLDataSet; OldDataSet: TDataSet);
begin
  if OldDataSet is TQuery then
    TMySQLQuery(aDataSet).SQL.Assign((OldDataSet as TQuery).SQL) else
    TMySQLTable(aDataSet).TableName := TTable(OldDataSet).TableName;
end;

procedure TBDE2MySQLDAC.GetNeededUpdateObject(aDataSet: TMySQLDataSet; OldDataSet: TDataSet);
begin
  with (OldDataSet as TBDEDataSet) do
    if Assigned(UpdateObject) and (UpdateObject is TUpdateSQL) then
      with (UpdateObject as TUpdateSQL) do
      begin
        TMySQLUpdateSQL(aDataSet).ModifySQL := ModifySQL;
        TMySQLUpdateSQL(aDataSet).InsertSQL := InsertSQL;
        TMySQLUpdateSQL(aDataSet).DeleteSQL := DeleteSQL;
      end;
end;

end.



