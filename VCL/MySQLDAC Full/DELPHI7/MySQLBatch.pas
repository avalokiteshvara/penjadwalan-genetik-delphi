unit MySQLBatch;

interface

Uses  Windows, SysUtils, Graphics, Classes, Controls, Db, DBCommon,
      {$IFDEF DELPHI_6}Variants,{$ENDIF}StdVCL, MySQLDBTables,SMIntf;


type
  {TMySQLBatchExecute}
  TMySQLBatchAction = (baFail, baAbort, baIgnore, baContinue);

  TMySQLBatchErrorEvent = procedure(Sender: TObject; E: EMySQLDatabaseError; SQLText : String; StatementNo : Integer) of object;
  TMySQLBatchProcessEvent = procedure(Sender: TObject; SQLText : String; const StatementNo: Integer) of object;
  TMySqlBatchBeforeStatementEvent = procedure(Sender: TObject; SQLText: string; const StatementNo: Integer; var Allow: boolean) of object;                            // ptook
  TMySqlBatchAfterStatementEvent = procedure(Sender: TObject; SQLText: string; const StatementNo, RowsAffected: Integer; const Success: boolean) of object; // ptook

  TTokenType = (ttUnknown, ttComment, ttOperator, ttBrace,ttSeparator, ttEol, ttLF,ttString,ttEof);

  TMySQLParser = class
  protected
    FBuffer: string;
    FBufferPos, FBufferLine, FBufferLen: Integer;
    FDelimiter : String;
    procedure SetBuffer(const Value: string);
    function Parse(var Position, Line: Integer; var Token: string): TTokenType;
    function InternalStart(var Position, Line: Integer; var Token: string): TTokenType;
    function SkipSqlComment(var AToken: string): TTokenType;
    function ParseSqlDelim(var AToken: string): TTokenType;
    function ParseSqlString(var AToken: string): TTokenType;
  public
    constructor Create;
    destructor Destroy; override;
    function GetStatement(var CurrPos, CurrLen, CurrLineNo: Integer): string;
    property Buffer: string read FBuffer write SetBuffer;
    property Delimiter : String read FDelimiter write FDelimiter;

  end;

  TMySQLBatchExecute = class(TComponent)
  private
    FAbout   : TmySQLDACAbout;
    FDatabase: TMySQLDatabase;
    FAffectedRows: LongInt;
    FSql: TStringList;
    FDelimiter : Char;
    FAction    : TMySQLBatchAction;
    FBeforeExecute: TNotifyEvent;
    FAfterExecute: TNotifyEvent;
    FOnBatchError: TMySQLBatchErrorEvent;
    FOnProcess: TMySQLBatchProcessEvent;
    FOnAfterStatement: TMySqlBatchAfterStatementEvent;    // ptook
    FOnBeforeStatement: TMySqlBatchBeforeStatementEvent;  // ptook
    procedure SetSql(Value: TStringList);
    function DoBeforeStatement(const SqlText: string;
      const StatementNo: integer): boolean;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function BatchExecSql(Sql: WideString): LongInt;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure ExecSql;
    property RowsAffected: LongInt read FAffectedRows;
  published
    property About : TmySQLDACAbout read FAbout write FAbout;
    property Action : TMySQLBatchAction read FAction write FAction default baFail;
    property Database: TMySQLDatabase read FDatabase write FDatabase;
    property Sql: TStringList read FSql write SetSql;
    property Delimiter : Char read FDelimiter write FDelimiter default ';';
    property OnBeforeExecute: TNotifyEvent read FBeforeExecute write FBeforeExecute;
    property OnAfterExecute: TNotifyEvent read FAfterExecute write FAfterExecute;
    property OnBatchError: TMySQLBatchErrorEvent read FOnBatchError write FOnBatchError;
    property OnBeforeStatement: TMySqlBatchBeforeStatementEvent read FOnBeforeStatement
      write FOnBeforeStatement;   // ptook
    property OnAfterStatement: TMySqlBatchAfterStatementEvent read FOnAfterStatement
      write FOnAfterStatement;   // ptook
    property OnProcess: TMySQLBatchProcessEvent read FOnProcess write FOnProcess;
  end;



implementation
uses MySQLTypes,Forms;


constructor TMySQLParser.Create;
begin
  inherited;
  FBufferPos := 1;
  FBufferLine := 1;
end;

destructor TMySQLParser.Destroy;
begin
  inherited Destroy;
end;

procedure TMySQLParser.SetBuffer(const Value: string);
begin
  FBuffer := Value;
  FBufferLen := Length(FBuffer);
  FBufferPos := 1;
  FBufferLine := 1;
end;

function TMySQLParser.Parse(var Position, Line: Integer; var Token: string): TTokenType;

 function ParseEx(var APosition, ALine: Integer; var AToken: string): TTokenType;
 begin
    Result := InternalStart(APosition, ALine, AToken);
    if Result <> ttUnknown then Exit;
    Result := SkipSqlComment(AToken);
    if Result <> ttUnknown then Exit;
    Result := ParseSqlDelim(AToken);
    if Result <> ttUnknown then Exit;
    Result := ParseSqlString(AToken);
    if Result <> ttUnknown then Exit;
 end;

begin
  repeat
     Result := ParseEx(Position, Line, Token);
  until not (Result in [ttEol{, ttLF}, ttComment]);
end;


function TMySQLParser.InternalStart(var Position, Line: Integer; var Token: string): TTokenType;
begin
   Result := ttEof;
   Line := FBufferLine;
   Position := FBufferPos;
   Token := '';
   if FBufferPos > FBufferLen then Exit;
   while FBuffer[FBufferPos] in [' ',#9] do
   begin
     Inc(FBufferPos);
     if FBufferPos > FBufferLen then
     begin
       Position := FBufferPos;
       Exit;
     end;
   end;
   Position := FBufferPos;
   Token := FBuffer[FBufferPos];
   Inc(FBufferPos);
   if Token[1] = #10 then
   begin
     Result := ttLF;
     Exit;
   end;
   if Token[1] = #13 then
   begin
     Result := ttEol;
     Inc(FBufferLine);
     Exit;
   end;
   Result := ttUnknown;
end;


function TMySqlParser.GetStatement(var CurrPos, CurrLen, CurrLineNo: Integer): string;
var
  Token: string;
  TokenType : TTokenType;
  TokenLineNo, TokenPos: Integer;

  function AddSpaces: string;
  begin
     Result := '';
     if FBufferPos > FBufferLen then Exit;
     while (FBufferPos <= FBufferLen) and (FBuffer[FBufferPos] in [' ',#9,#10]) do
     begin
        Result := Result + FBuffer[FBufferPos];
        Inc(FBufferPos);
     end;
  end;

begin
  AddSpaces;
  CurrPos := FBufferPos;
  CurrLineNo := FBufferLine;
  Result := '';
  TokenType := Parse(TokenPos, TokenLineNo, Token);
  while TokenType in [ttEol, ttLF] do
        TokenType := Parse(TokenPos, TokenLineNo, Token);
  while (TokenType <> ttEof) and (not (Token = FDelimiter)) do
  begin
    if (TokenType=ttLF) and not (Result[Length(Result)] in [' ', #9]) then
       Result := Result + ' ' else
       if TokenType <> ttComment then
          Result := Result + Token;
    Token := AddSpaces;
    if Token <> '' then
       Result := Result + ' ';
    TokenType := Parse(TokenPos, TokenLineNo, Token);
  end;
  CurrLen := FBufferPos - CurrPos;
end;

function TMySqlParser.ParseSqlDelim(var AToken: string): TTokenType;
var
  Temp, Temp1: Char;
begin
   Result := ttUnknown;
   Temp := AToken[1];
   if Temp in ['{', '}', '(', ')', '[', ']'] then
   begin
      Result := ttBrace;
   end else
   if Temp in [',', ';', ':'] then
   begin
      Result := ttSeparator;
   end else
   if Pos(Temp, '~!#%?|=+-<>/*^@#') > 0 then
   begin
      Result := ttOperator;
      if FBufferPos <= FBufferLen then
         Temp1 := FBuffer[FBufferPos] else
         Temp1 := #0;
      if ((Temp = '>') and (Temp1 = '=')) or ((Temp = '<') and (Temp1 in ['=', '>'])) then
      begin
         AToken := AToken + Temp1;
         Inc(FBufferPos);
      end;
   end;
end;


function TMySqlParser.SkipSqlComment(var AToken: string): TTokenType;

  function SkipInLineComment(var AToken: string): TTokenType;
  var
    Temp: Char;
  begin
     Result := ttComment;
     while FBufferPos <= FBufferLen do
     begin
        Temp := FBuffer[FBufferPos];
        AToken := AToken + Temp;
        Inc(FBufferPos);
        if Temp = #13 then
        begin
           Inc(FBufferLine);
           Break;
        end;
     end;
  end;

  function SkipMultilineComment(var AToken: string): TTokenType;
  var
    Temp, Temp1: Char;
  begin
     Result := ttUnknown;
     if (AToken[1] = '/') and (FBufferPos <= FBufferLen) and (FBuffer[FBufferPos] = '*') then
     begin
        Result := ttComment;
        Temp1 := #0;
        while FBufferPos <= FBufferLen do
        begin
           Temp := FBuffer[FBufferPos];
           AToken := AToken + Temp;
           Inc(FBufferPos);
           if (Temp = '/') and (Temp1 = '*') then
              Break;
           if Temp = #13 then
              Inc(FBufferLine);
           Temp1 := Temp;
        end;
     end
  end;


begin
  if (AToken[1] = '-') and (FBufferPos <= FBufferLen) and (FBuffer[FBufferPos] = '-') then
  begin
     Result := SkipInLineComment(AToken);
     Exit;
  end;
  if AToken[1] = '#' then
  begin
     Result := SkipInLineComment(AToken);
     Exit;
  end;
  Result := SkipMultiLineComment(AToken);
end;


function TMySqlParser.ParseSqlString( var AToken: string): TTokenType;
var
  Temp, Quote: Char;
begin
   Result := ttUnknown;
   if AToken[1] in ['"', ''''] then
   begin
      Result := ttString;
      Quote := AToken[1];
      while FBufferPos <= FBufferLen do
      begin
         Temp := FBuffer[FBufferPos];
         AToken := AToken + Temp;
         Inc(FBufferPos);
         if (Temp = '\') and ((FBufferPos <= FBufferLen)) then
         begin
            AToken := AToken + FBuffer[FBufferPos];
            Inc(FBufferPos);
         end else
         if Temp = Quote then
            Break;
     end;
   end
end;



{TMySQLBatchExecute}
constructor TMySQLBatchExecute.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSql := TStringList.Create;
  FDelimiter := ';';
  FAction := baFail;
end;

destructor  TMySQLBatchExecute.Destroy;
begin
  FSql.Free;
  inherited Destroy;
end;

procedure TMySQLBatchExecute.SetSql(Value: TStringList);
begin
  FSql.Assign(Value);
end;

procedure TMySQLBatchExecute.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = FDatabase) and (Operation = opRemove) then
    FDatabase   := nil;
end;

function TMySQLBatchExecute.BatchExecSql(Sql: WideString): LongInt;
var
  Text: string;
  Parser: TMySQLParser;
  FBatchCurPos, FBatchCurLen, FBatchCurrentLine: Integer;
  StmtNo, StmtRes: Integer;
  StmtSuccess: boolean;
begin
  Parser := TMySQLParser.Create;
  Parser.Delimiter := FDelimiter;
  FBatchCurPos := 0;
  FBatchCurLen := 0;
  FBatchCurrentLine := 1;
  Result := 0;
  try
    Parser.Buffer := Sql;
    StmtNo := 0;
    StmtSuccess := True;
    StmtRes := 0;
    while True do begin
      Text := Parser.GetStatement(FBatchCurPos, FBatchCurLen, FBatchCurrentLine);
      if Text='' then Break;
      try
         Inc(StmtNo);
         StmtSuccess := True;
         // <-- modified by ptook
         if not DoBeforeStatement(Text, StmtNo) then Continue;
         StmtRes := FDatabase.Execute(Text);
         Result := Result + StmtRes;
         if Assigned(FOnProcess) then
            FOnProcess(Self,Text,StmtNo);
         // modified by ptook -->
      except
        on E: EMySQLDatabaseError do
        begin
           if E.Message <> '' then E.Message := E.Message + '. ';
           if Assigned(FOnBatchError) then
              FOnBatchError(Self, E,Text,StmtNo);
           case Action of
             baFail:     raise;
             baAbort:    SysUtils.Abort;
             baContinue: Application.HandleException(Self);
             baIgnore:   ;
           end;
           Text :='';
           StmtSuccess := False;
        end;
      end;
      if Assigned(FOnAfterStatement) then
        FOnAfterStatement(Self, Text, StmtNo, StmtRes, StmtSuccess);
    end;
  finally
    Parser.Free;
  end;
end;

procedure TMySQLBatchExecute.ExecSql;
begin
  if Assigned(FDatabase) then
  begin
    if Assigned(FBeforeExecute) then FBeforeExecute(Self);
    FDatabase.Connected := True;
    FAffectedRows := BatchExecSql(FSql.Text);
    if Assigned(FAfterExecute) then FAfterExecute(Self);
  end else
    DatabaseError('Property Database not set!');
end;

function TMySQLBatchExecute.DoBeforeStatement(const SqlText: string;
  const StatementNo: integer): boolean;
begin
  Result := True;
  if Assigned(FOnBeforeStatement) then FOnBeforeStatement(Self, SqlText, StatementNo, Result);
end;

end.
