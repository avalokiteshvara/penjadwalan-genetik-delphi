unit prog_db_postgresql;

// #############################################################################
// #############################################################################
// Licenced under MOZILLA PUBLIC LICENSE Vers. 1.1, see licence.txt
// Tilo Ermlich - www.netzpol.de - 1st October 2007
// #############################################################################
// #############################################################################

interface
uses
  globals, SysUtils, Dialogs, StrUtils, Classes, Controls,
  StdCtrls, Messages, WinProcs, Grids, Graphics, clipbrd, libpq_fe, sbrs;

  function myIfNull:String;
  function myLimit(offset,rows: Integer):String;
  function myRound(field:String;d:Integer):String;
  function myWhere:String;
  function myLike:String;
  function mySubDate(datestr, intervall: String): String;
  function myIntervall(intervall: String): String;
  function numsplit(zahl, flag:String):String;
  function myDateFormat(column, format: String):String;
  function myPath(path: String): String;
  function myNow(): String;
  function myNumber(field:String;d:Integer):String;  
  function myNrConcat(field1, field2: String):String;
  procedure sql_array_command(SQLArray: TMyArray; Msg: Boolean);  
  procedure sql_command(SQLString: string; Msg: Boolean);
  procedure sql_select_row(SQLString: string; var myarray: TMyArray);
  procedure sql_select_col(SQLString: string; var myarray: TMyArray);
  procedure sql_select_sg(SQLString: string; var SQLGrid: TStringGrid; myarray: TMyArray);
  procedure sql_select_mh_sg(SQLString: string; var SQLGrid: TStringGrid; limit: string='0');
  procedure sql_select_oh_sg(SQLString: string; var SQLGrid: TStringGrid);
  procedure sql_arrayselect_oh_sg(SQLArray: TMyArray; var SQLGrid: TStringGrid);
  procedure sql_arrayselect_matrix(SQLArray: TMyArray; var sqlrow: integer; var sqlcol: integer; var matrix: TMyMatrix);
  procedure sql_select_matrix(SQLString: string; var sqlrow: integer; var sqlcol: integer; var matrix: TMyMatrix);
  function sql_fill_listbox(SQLString: String; list_box : TListBox) : Boolean;
  function sql_count(SQLString: String) : Integer;
  function parseout(sSrc: string ): string;

implementation
uses prog_global;

// #############################################################################
// myIfNull: encapsulates an if-null-decision, i.e. '... sum(' + myIfNull + '(a.value + b.value,a.value)) ...'
// #############################################################################
function myIfNull:String;
begin
result:='coalesce';
end;


// #############################################################################
// myLimit: encapsulates a limit for result sets
// #############################################################################
function myLimit(offset,rows: Integer):String;
begin
result:='limit ' + inttostr(rows) + ' offset ' + inttostr(offset);
end;


// #############################################################################
// myRound: encapsulates rounding, i.e. 'select ' + myRound('value',2) + ' ...'
// #############################################################################
function myRound(field:String;d:Integer):String;
begin
result:='round(cast(' + field + ' as numeric),' + inttostr(d) + ')';
end;


// #############################################################################
// myWhere: encapsulates an everytime matching where-condition, useful for building dynamic statements
// building dynymic statements, i.e. 'select * from address where ' + myWhere + ' ...'
// #############################################################################
function myWhere:String;
begin
result:='true';
end;


// #############################################################################
// myLike: encapsulates the like-clause,
// i.e. 'select * from address where name ' + myLike + ' ''%' + string + '%'' order by name;';
// #############################################################################
function myLike:String;
begin
result:='ilike';
end;


// #############################################################################
// mySubDate: encapsulates date substraction, i.e. 'select ' + mySubDate('2007-07-07', '30 DAY');
// #############################################################################
function mySubDate(datestr, intervall: String): String;
begin
//MySQL: date_sub("yyyy-mm-dd", interval 30 day):
//MySQL: result:='DATE_SUB(''' + datestr + ''', INTERVALL ' + intervall + ')';
//PostgreSQL: date('2007-07-07') - interval '30 days'
result:= 'date(''' + datestr + ''') - interval ''' + intervall + '''';
end;


// #############################################################################
// myIntervall: encapsulates date substraction from now,
// i.e. 'select ... where (thedate >= ' + myIntervall('1 year') + ') and ...'
// #############################################################################
function myIntervall(intervall: String): String;
begin
//now() - interval 1 year:
result:='now() - interval ''' + intervall + '''';
end;


// #############################################################################
// numsplit: function for separating a floating point by the point,
// numsplit('-12345.6789',v) = '-12345', numsplit('-12345.6789',n) = '6789'
// #############################################################################
function numsplit(zahl, flag:String):String;
var azahl: TStringList;
begin
  if flag = 'v' then begin
    azahl:=split(zahl,'.',true,false);
    if (azahl.count = 0) then result := '0'
    else result := azahl[0];
  end;

  if flag = 'n' then begin
    azahl:=split(zahl,'.',true,false);
    if (azahl.count = 0) or (azahl.count = 1) then result := '0'
    else result := azahl[1];
  end;
end;


// #############################################################################
// myDateFormat: encapsulates date formating,
// i.e. 'select name, ' + myDateFormat('birthdate', '%d.%m.%Y') + ', ...'
// #############################################################################
function myDateFormat(column, format: String):String;
begin
//date_format(datum, "%d.%m.%Y"):
//MySQL: result:='date_format(' + column + ', ''' + format + ''')';
result:='to_char(' + column + ', ''DD.MM.YYYY'')';
//result:='replace(to_char(' + column + ', ''DD.MM.YYYY''),''01.01.1970'',''00.00.0000'')';
end;


// #############################################################################
// myPath: encapsulates representation of directory paths,
// i.e. 'select * from documents where pfad = ' + myPath('\DocPlace\Products\') + ' ...'
// #############################################################################
function myPath(path: String): String;
begin
//AnsiReplaceStr(Main_Form.frame_formular.dokuvorl.Text, '\', '\\'):
result:= 'E''' + AnsiReplaceStr(path, '\', '\\');
end;


// #############################################################################
// myNow: encapsulates the now-statement,
// i.e. 'update table set date = ' + myNow() + ' where ...'
// #############################################################################
function myNow(): String;
begin
//now():
result:='now()';
end;


// #############################################################################
// myNumber: encapsulates number formating,
// i.e. 'select product, ' + myNumber('amount',3) + ' ...'
// #############################################################################
function myNumber(field:String;d:Integer):String;
var format: String;
begin
//MySQL: replace(replace(replace(format(field,d),',','&t;'),'.',','),'&t;','.'): 1,004,234.22 -> 1.004.234,22
//MySQL: result:= 'replace(replace(replace(format(' + field + ',' + d + '),'','',''&t;''),''.'','',''),''&t;'',''.'')';

case d of
  1: format := '''FM999G999G999G990D099999''';
  2: format := '''FM999G999G999G990D009999''';
  3: format := '''FM999G999G999G990D000999''';
  4: format := '''FM999G999G999G990D000099''';
  5: format := '''FM999G999G999G990D000009''';
else
end;

result:='to_char(round(cast(' + field + ' as numeric),' + inttostr(d) + '), ' + format + ')';
end;


// #############################################################################
// myNrConcat: special function for concating numbers
// #############################################################################
function myNrConcat(field1, field2: String):String;
begin
//MySQL: concat(a.auftrgnr, "-", a.zusatznr):
//result:='concat(' + field1 + ', ''-'',' + field2 + ')';
result := field1 + '|| ''-'' ||' + field2;
end;


// #############################################################################
// db_errorf: special function from J.G. Owen for formating exception messages
// #############################################################################
procedure db_errorf(const TheFormat: string; const Args:array of const; SQLString: string);
var s:string;
begin
  s := format(TheFormat,Args);
  uncontrol(s); //they have \ns in there silly children.
  errorf('%s',[s]);     //don't let %s in messages blow-up format.

 {$IfDef SQLLOG} Clipboard.AsText :=SQLString; {$EndIf}
end;


// #############################################################################
// parseout: special function substituting the tag --- back to dummy integer -1
// #############################################################################
function parse_metaid(sSrc: string ): string;
var
  nPos: integer;
begin
  nPos        := Pos( '---', sSrc );
  while(nPos > 0)do
  begin
    Delete( sSrc, nPos, 3 );
    Insert( '-1', sSrc, nPos );
    nPos := Pos( '---', sSrc );
  end;
  Result := sSrc;
end;

// #############################################################################
// sql_array_command: sql-procedure for sending multitple sql-statements to the database
// while the connection is hold
// #############################################################################
procedure sql_array_command(SQLArray: TMyArray; Msg: Boolean);
//Parsing for ', etc. must be implemented in program code
var  conn:p_PGconn;
     res : p_PGresult;
     test: boolean;
     exce: string;
     k: integer;
label ENDNESS;
begin
  k:=1;
  test:=false;
  res:=nil;
  conn := PQconnectdb(PCHAR(pg_ConnParms));
  PQsetClientEncoding(conn, pChar(pg_ClientEncoding));
  exce := 'Connection to database failed';
  if (PQstatus(conn)<>CONNECTION_OK) then goto ENDNESS;

  try
  for k := 1 to length(SQLArray) do begin
    SQLArray[k-1]:=sar(SQLArray[k-1],'-- Selection --','-1');
    SQLArray[k-1]:=sar(SQLArray[k-1],'-- No Result --','-1');
    {$IfDef SQLLOG}
    writeLog('sql_array_command: ' + SQLArray[k-1]);
    Clipboard.AsText :='sql_array_command: ' + SQLArray[k-1];
    {$EndIf}

    exce := 'Command ''' + SQLArray[k-1] + ''' failed';
    PQclear(res);
    res := PQexec(conn,pChar(SQLArray[k-1]));
  end;
//=========================================================
    if Msg then begin
        if (PQresultStatus(res) = PGRES_COMMAND_OK) then
                begin
                MessageBox(0,'            Operation successful!', NetzpMessage, MB_OK);
                test:=true;
                end
        else
                MessageBox(0,'           Operation failed!', NetzpMessage, MB_OK);
    end;
  finally
  end;
//=========================================================
  ENDNESS:
  if not test then db_errorf('%s: %s',[exce,PQerrorMessage(conn)],SQLArray[k-1]);
  if res <> nil then PQclear(res);
  PQfinish(conn);
end;


// #############################################################################
// sql_command: the basic sql-procedure for excecution of database commands
// #############################################################################
procedure sql_command(SQLString: string; Msg: Boolean);
//Parsing for ', etc. must be implemented in program code
var  conn:p_PGconn;
     res : p_PGresult;
     test: boolean;
     exce: string;
label ENDNESS;
begin
  SQLString:=sar(SQLString,'-- Selection --','-1');
  //SQLString:=sar(SQLString,'-- No Result --','-1');

  {$IfDef SQLLOG}
  writeLog('sql_command: ' + SQLString);
  Clipboard.AsText :='sql_command: ' + SQLString;
  {$EndIf}

  test:=false;
  res:=nil;
  conn := PQconnectdb(PCHAR(pg_ConnParms));
  PQsetClientEncoding(conn, pChar(pg_ClientEncoding));
  exce := 'Connection to database failed';
  if (PQstatus(conn)<>CONNECTION_OK) then goto ENDNESS;

  try
  exce := 'Command ''' + SQLString + ''' failed';
  PQclear(res);
  res := PQexec(conn,pChar(SQLString));
//=========================================================
  if (PQresultStatus(res) = PGRES_COMMAND_OK)  then begin
    test:=true;
    if Msg then MessageBox(0,'Operation successful!', NetzpMessage, MB_OK);
  end;

  finally
  end;

//=========================================================
  ENDNESS:
  if not test then db_errorf('%s: %s',[exce,PQerrorMessage(conn)],SQLString);
  if res <> nil then PQclear(res);
  PQfinish(conn);
end;


// #############################################################################
// sql_select_row: the basic sql-procedure for selecting a row and loading the
// result into a dynamic array called by reference
// #############################################################################
procedure sql_select_row(SQLString: string; var myarray: TMyArray);
// Parsing for ' implemented here
var
conn:p_PGconn;
res : p_PGresult;
test: boolean;
exce: string;
j, numcol:integer;
label ENDNESS;
begin
  {$IfDef SQLLOG}
  writeLog('sql_select_row: ' + SQLString);
  Clipboard.AsText :='sql_select_row: ' + SQLString;  
  {$EndIf}

  test:=false;
  res:=nil;
  conn := PQconnectdb(PCHAR(pg_ConnParms));
  PQsetClientEncoding(conn, pChar(pg_ClientEncoding));
  exce := 'Connection to database failed';
  if (PQstatus(conn)<>CONNECTION_OK) then
  goto ENDNESS;

  SQLString:=parse_metaid(SQLString);

  try
  exce := 'Command ''' + SQLString + ''' failed';
  PQclear(res);
  res := PQexec(conn,pChar(SQLString));
//=========================================================
if (PQresultStatus(res) = PGRES_TUPLES_OK) then begin
  test:=true;
  if res <> nil then begin
  //=========================================================
      numcol:= PQnfields(res);
      SetLength(myarray,numcol + 1);
      for j := 0 to numcol - 1 do
        if PQntuples(res) <> 0 then myarray[j]:= parseout(PQgetvalue(res,0,j))
        else myarray[j]:= '---';
  //=========================================================
  end else begin
  SetLength(myarray, 100);
  for j := 0 to 99 do myarray[j] := '-- No Result --'
  end;
end;
  finally
  end;
//=========================================================
  ENDNESS:
  if not test then db_errorf('%s: %s',[exce,PQerrorMessage(conn)],SQLString);
  if res <> nil then PQclear(res);
  PQfinish(conn);
end;


// #############################################################################
// sql_select_col: the basic sql-procedure for selecting a column and loading
// the result into a dynamic array called by reference
// #############################################################################
procedure sql_select_col(SQLString: string; var myarray: TMyArray);
// Parsing for ' implemented here
var
conn:p_PGconn;
res : p_PGresult;
test: boolean;
exce: string;
i, numrow:integer;
label ENDNESS;
begin
  {$IfDef SQLLOG}
  writeLog('sql_select_col: ' + SQLString);  
  Clipboard.AsText :='sql_select_col: ' + SQLString;
  {$EndIf}
  
  test:=false;
  res:=nil;
  conn := PQconnectdb(PCHAR(pg_ConnParms));
  PQsetClientEncoding(conn, pChar(pg_ClientEncoding));
  exce := 'Connection to database failed';
  if (PQstatus(conn)<>CONNECTION_OK) then
  goto ENDNESS;

  try
  exce := 'Command ''' + SQLString + ''' failed';
  PQclear(res);
  res := PQexec(conn,pChar(SQLString));
  //=========================================================
  if (PQresultStatus(res) = PGRES_TUPLES_OK) then begin
    test:=true;
    //=========================================================
    if res <> nil then begin
      numrow:= PQntuples(res) + 1;
      SetLength(myarray,numrow);

      if numrow > 1 then
        for i := 1 to numrow - 1 do myarray[i]:= parseout(PQgetvalue(res,i - 1,0))
      else begin
        SetLength(myarray, 2);
        myarray[1]:= '---';
      end
    end else begin
      SetLength(myarray, 2);
      myarray[1] := '-- No Result --'
    end;
    //=========================================================
  end;
  //=========================================================

  finally
  end;

  ENDNESS:
  if not test then db_errorf('%s: %s',[exce,PQerrorMessage(conn)],SQLString);
  if res<>nil then PQclear(res);
  PQfinish(conn);
end;


// #############################################################################
// sql_select_sg: sql-procedure for fetching a result set and loading it into
// a string grid called by reference, i.e. useful for string grids WITHOUT column headers
// #############################################################################
procedure sql_select_sg(SQLString: string; var SQLGrid: TStringGrid; myarray: TMyArray);
// Parsing for ' implemented here
var
conn:p_PGconn;
res : p_PGresult;
test: boolean;
exce: string;
i,j, numcol, numrow:integer;
label ENDNESS;
begin
  {$IfDef SQLLOG}
  writeLog('sql_select_sg: ' + SQLString);
  Clipboard.AsText :='sql_select_sg: ' + SQLString;
  {$EndIf}

  test:=false;
  res:=nil;
  conn := PQconnectdb(PCHAR(pg_ConnParms));
  PQsetClientEncoding(conn, pChar(pg_ClientEncoding));
  exce := 'Connection to database failed';
  if (PQstatus(conn)<>CONNECTION_OK) then
  goto ENDNESS;

  try
  exce := 'Command ''' + SQLString + ''' failed';
  PQclear(res);
  res := PQexec(conn,pChar(SQLString));
//=========================================================
if (PQresultStatus(res) = PGRES_TUPLES_OK) then
  begin
    test:=true;
    if res <> nil then begin
    //=========================================================
      numcol:= PQnfields(res);
      numrow:= PQntuples(res) + 1;

      SQLGrid.ColCount:= numcol;
      SQLGrid.RowCount:= numrow;

      for j := 0 to numcol -1 do SQLGrid.Cells[j, 0] := parseout(myarray[j]);

      for i := 1 to numrow do
        for j := 0 to numcol -1 do SQLGrid.Cells[j, i]:= parseout(PQgetvalue(res,i - 1,j));

      if numrow > 1 then begin
        SQLGrid.FixedRows:=1;
        SQLGrid.FixedColor:= clBtnFace;
      end;

      if numrow = 1 then begin
        SQLGrid.RowCount:=2;
        SQLGrid.FixedRows:=1;
        for j := 0 to numcol - 1 do SQLGrid.Cells[j, 1]:= '---';
      end;
  //=========================================================
  end;
end;
  finally
  end;
//=========================================================
  ENDNESS:
  if not test then db_errorf('%s: %s',[exce,PQerrorMessage(conn)],SQLString);
  if res<>nil then PQclear(res);
  PQfinish(conn);
end;


// #############################################################################
// sql_select_mh_sg: sql-procedure for fetching a result set and loading it into
// a string grid called by reference, i.e. useful for string grids WITH column headers
// which should be filled with the first row of the result set
// #############################################################################
procedure sql_select_mh_sg(SQLString: string; var SQLGrid: TStringGrid; limit: string='0');
// Parsing for ' implemented here
var
conn:p_PGconn;
res : p_PGresult;
test: boolean;
exce: string;
i,j, numcol, numrow:integer;
label ENDNESS;
begin
  if limit <> '0' then SQLString := SQLString + ' limit ' + limit + ';';

  {$IfDef SQLLOG}
  writeLog('sql_select_mh_sg: ' + SQLString);
  Clipboard.AsText :='sql_select_mh_sg: ' + SQLString;
  {$EndIf}

  test:=false;
  res := nil;
  conn := PQconnectdb(PCHAR(pg_ConnParms));
  PQsetClientEncoding(conn, pChar(pg_ClientEncoding));
  exce := 'Connection to database failed';
  if (PQstatus(conn)<>CONNECTION_OK) then goto ENDNESS;

try
  exce := 'Command ''' + SQLString + ''' failed';
  PQclear(res);
  res := PQexec(conn,pChar(SQLString));
//=========================================================
if (PQresultStatus(res) = PGRES_TUPLES_OK) then
  begin
    test:=true;
    if res <> nil then begin
    //=========================================================
      numcol:= PQnfields(res);
      numrow:= PQntuples(res);
      SQLGrid.ColCount:= numcol;
      SQLGrid.RowCount:= numrow;

      if numrow = 0 then
        for j := 0 to numcol - 1 do SQLGrid.Cells[j, 0]:= '---';

      for i := 0 to numrow - 1 do
        for j := 0 to numcol - 1 do SQLGrid.Cells[j, i]:= parseout(PQgetvalue(res,i,j));
    //=========================================================
  end;
end;

  finally
  end;
//=========================================================

  ENDNESS:
  if not test then db_errorf('%s: %s',[exce,PQerrorMessage(conn)],SQLString);
  if res <> nil then PQclear(res);
  PQfinish(conn);
end;


// #############################################################################
// sql_select_oh_sg: sql-procedure for fetching a result set and loading it into
// a string grid called by reference, i.e. useful for string grids WITH column headers
// which should NOT be filled with the first row of the result set
// #############################################################################
procedure sql_select_oh_sg(SQLString: string; var SQLGrid: TStringGrid);
// Parsing for ' implemented here
var
conn:p_PGconn;
res : p_PGresult;
test: boolean;
exce: string;
i,j, numcol, numrow:integer;
label ENDNESS;
begin
  {$IfDef SQLLOG}
  writeLog('sql_select_oh_sg: ' + SQLString);
  Clipboard.AsText :='sql_select_oh_sg: ' + SQLString;
  {$EndIf}

  test:=false;
  res := nil;
  conn := PQconnectdb(PCHAR(pg_ConnParms));
  PQsetClientEncoding(conn, pChar(pg_ClientEncoding));
  exce := 'Connection to database failed';
  if (PQstatus(conn)<>CONNECTION_OK) then goto ENDNESS;

try
  exce := 'Command ''' + SQLString + ''' failed';
  PQclear(res);
  res := PQexec(conn,pChar(SQLString));
//=========================================================
if (PQresultStatus(res) = PGRES_TUPLES_OK) then
  begin
    test:=true;
    if res <> nil then begin
      //=========================================================
      numcol:= PQnfields(res);
      numrow:= PQntuples(res);
      SQLGrid.ColCount:= numcol;

        if numrow = 0 then begin
            SQLGrid.RowCount:= numrow + 2;
            for j := 0 to numcol - 1 do begin
                SQLGrid.Cells[j, 1]:= '---';
            end;
        end else begin
            SQLGrid.RowCount:= numrow + 1;
            for i := 0 to numrow - 1 do begin
                for j := 0 to numcol -1 do
                    SQLGrid.Cells[j, (i + 1)]:= parseout(PQgetvalue(res,i,j));
            end;
        end;
      //=========================================================
  end;
end;

  finally
  end;
//=========================================================

  ENDNESS:
  if not test then db_errorf('%s: %s',[exce,PQerrorMessage(conn)],SQLString);
  if res <> nil then PQclear(res);
  PQfinish(conn);
end;


// #############################################################################
// sql_arrayselect_oh_sg: sql-procedure for fetching a result set by multiple
// sql-commands while the connection is hold and then loading it into a string grid
// called by reference, i.e. useful with temporary tables and for string grids
// WITH column headers which should NOT be filled with the first row of the result set
// #############################################################################
procedure sql_arrayselect_oh_sg(SQLArray: TMyArray; var SQLGrid: TStringGrid);
// Parsing for ' implemented here
var
conn:p_PGconn;
res : p_PGresult;
test: boolean;
exce: string;
i, j, k, numcol, numrow:integer;
label ENDNESS;
begin
  k := 1;
  test:=false;
  res := nil;
  conn := PQconnectdb(PCHAR(pg_ConnParms));
  PQsetClientEncoding(conn, pChar(pg_ClientEncoding));
  exce := 'Connection to database failed';
  if (PQstatus(conn)<>CONNECTION_OK) then goto ENDNESS;

try
for k := 1 to length(SQLArray) do begin
  {$IfDef SQLLOG}
  writeLog('sql_arrayselect_matrix_oh_sg: ' + SQLArray[k-1]);
  Clipboard.AsText :='sql_arrayselect_matrix_oh_sg: ' + SQLArray[k-1];
  {$EndIf}

  exce := 'Command ''' + SQLArray[k-1] + ''' failed';
  PQclear(res);
  res := PQexec(conn,pChar(SQLArray[k-1]));

  //if (PQresultStatus(res) <> PGRES_TUPLES_OK) then goto ENDNESS;
end;

//=========================================================
if (PQresultStatus(res) = PGRES_TUPLES_OK) then
  begin
    test:=true;
    if res <> nil then begin
    //=========================================================
      numcol:= PQnfields(res);
      numrow:= PQntuples(res);

      SQLGrid.ColCount:= numcol;


      if numrow = 0 then begin
          SQLGrid.RowCount:= numrow + 2;
          for j := 0 to numcol - 1 do SQLGrid.Cells[j, 1]:= '---';
      end else begin
          SQLGrid.RowCount:= numrow + 1;
          for i := 0 to numrow - 1 do
              for j := 0 to numcol - 1 do SQLGrid.Cells[j, (i + 1)]:= parseout(PQgetvalue(res,i,j));
      end;
    //=========================================================
  end;
end;

  finally
  end;
//=========================================================

  ENDNESS:
  if not test then db_errorf('%s: %s',[exce,PQerrorMessage(conn)],SQLArray[k-1]);
  if res <> nil then PQclear(res);
  PQfinish(conn);
end;


// #############################################################################
// sql_arrayselect_matrix: sql-procedure for fetching a result set by multiple
// sql-commands while the connection is hold and then loading it into a dynamic matrix
// called by reference, i.e. useful with temporary tables and for result sets which should
// by used in another way (MS Excel export)
// #############################################################################
procedure sql_arrayselect_matrix(SQLArray: TMyArray; var sqlrow: integer; var sqlcol: integer; var matrix: TMyMatrix);
// Parsing for ' implemented here
var
conn:p_PGconn;
res : p_PGresult;
test: boolean;
exce: string;
i, j, k, numcol, numrow:integer;
label ENDNESS;
begin
  k:=1;
  test:=false;
  res := nil;
  conn := PQconnectdb(PCHAR(pg_ConnParms));
  PQsetClientEncoding(conn, pChar(pg_ClientEncoding));
  exce := 'Connection to database failed';
  if (PQstatus(conn)<>CONNECTION_OK) then goto ENDNESS;

try
for k := 1 to length(SQLArray) do begin
  {$IfDef SQLLOG}
  writeLog('sql_arrayselect_matrix: ' + SQLArray[k-1]);
  Clipboard.AsText :='sql_arrayselect_matrix: ' + SQLArray[k-1];
  {$EndIf}

  exce := 'Command ''' + SQLArray[k-1] + ''' failed';
  PQclear(res);
  res := PQexec(conn,pChar(SQLArray[k-1]));

end;

//=========================================================
if (PQresultStatus(res) = PGRES_TUPLES_OK) then
  begin
    test:=true;
    if res <> nil then begin
    //=========================================================
      numcol:= PQnfields(res);
      numrow:= PQntuples(res);

      sqlcol:= numcol;
      sqlrow:= numrow;
      SetLength(matrix,numrow,numcol);

      for i := 0 to numrow - 1 do
        for j := 0 to numcol - 1 do matrix[i,j]:= parseout(PQgetvalue(res,i,j));
    //=========================================================
  end;
end;

  finally
  end;
//=========================================================

  ENDNESS:
  if not test then db_errorf('%s: %s',[exce,PQerrorMessage(conn)],SQLArray[k-1]);
  if res <> nil then PQclear(res);
  PQfinish(conn);
end;


// #############################################################################
// sql_select_matrix: sql-procedure for fetching a result set and loading it into
// a dynamic matrix called by reference, i.e. useful for result sets which should
// by used in another way (MS Excel export)
// #############################################################################
procedure sql_select_matrix(SQLString: string; var sqlrow: integer; var sqlcol: integer; var matrix: TMyMatrix);
// Parsing for ' implemented here
var
conn:p_PGconn;
res : p_PGresult;
test: boolean;
exce: string;
i,j, numcol, numrow:integer;
label ENDNESS;
begin
  {$IfDef SQLLOG}
  writeLog('sql_select_matrix: ' + SQLString);
  Clipboard.AsText :='sql_select_matrix: ' + SQLString;
  {$EndIf}
  
  test:=false;
  res := nil;
  conn := PQconnectdb(PCHAR(pg_ConnParms));
  PQsetClientEncoding(conn, pChar(pg_ClientEncoding));
  exce := 'Connection to database failed';
  if (PQstatus(conn)<>CONNECTION_OK) then goto ENDNESS;

try
  exce := 'Command ''' + SQLString + ''' failed';
  PQclear(res);
  res := PQexec(conn,pChar(SQLString));
//=========================================================
if (PQresultStatus(res) = PGRES_TUPLES_OK) then
  begin
    test:=true;
    if res <> nil then begin
    //=========================================================
      numcol:= PQnfields(res);
      numrow:= PQntuples(res);

      sqlcol:= numcol;
      sqlrow:= numrow;
      SetLength(matrix,numrow,numcol);

      for i := 0 to numrow - 1 do
        for j := 0 to numcol - 1 do matrix[i,j]:= parseout(PQgetvalue(res,i,j));
    //=========================================================
  end;
end;

  finally
  end;
//=========================================================

  ENDNESS:
  if not test then db_errorf('%s: %s',[exce,PQerrorMessage(conn)],SQLString);
  if res <> nil then PQclear(res);
  PQfinish(conn);
end;


// #############################################################################
// sql_fill_listbox: sql-procedure, fills a ListBox with results of a SQL statement,
// gives back true for filled result set otherwise false
// #############################################################################
function sql_fill_listbox(SQLString: String; list_box : TListBox) : Boolean;
// Parsing for ' implemented here
var
conn:p_PGconn;
res : p_PGresult;
test: boolean;
exce: string;
i, numrow:integer;
label ENDNESS;
begin
  {$IfDef SQLLOG}
  writeLog('sql_fill_listbox, ' + list_box.Name + ': ' + SQLString);
  Clipboard.AsText :='sql_fill_listbox, ' + list_box.Name + ': ' + SQLString;
  {$EndIf}

  sql_fill_listbox := false;
  test:=false;
  res:=nil;
  conn := PQconnectdb(PCHAR(pg_ConnParms));
  PQsetClientEncoding(conn, pChar(pg_ClientEncoding));
  exce := 'Connection to database failed';
  if (PQstatus(conn)<>CONNECTION_OK) then
  goto ENDNESS;

  try
  exce := 'Command ''' + SQLString + ''' failed';
  PQclear(res);
  res := PQexec(conn,pChar(SQLString));
//=========================================================
if (PQresultStatus(res) = PGRES_TUPLES_OK) then begin
  test:=true;
  if res <> nil then begin
  //=========================================================

    list_box.Clear;
     
    numrow:= PQntuples(res) + 1;
    for i := 1 to numrow -1 do list_box.Items.Add(parseout(PQgetvalue(res,i,0)));
    sql_fill_listbox := true;
  //=========================================================
  end;
end;
  finally
  end;
//=========================================================
  ENDNESS:
  if not test then db_errorf('%s: %s',[exce,PQerrorMessage(conn)],SQLString);
  if res<>nil then PQclear(res);
  PQfinish(conn);
end;


// #############################################################################
// sql_count: sql-procedure, counts the number of results for a given SQL string
// #############################################################################
function sql_count(SQLString: String) : Integer;
// Parsing for ' implemented here
var
conn:p_PGconn;
res : p_PGresult;
test: boolean;
exce: string;
i, numrow, count:integer;
label ENDNESS;

begin
  {$IfDef SQLLOG}
  writeLog('sql_count: ' + SQLString);
  Clipboard.AsText :='sql_count: ' + SQLString;
  {$EndIf}
  
  count:= 0;

  test:=false;
  res:=nil;
  conn := PQconnectdb(PCHAR(pg_ConnParms));
  PQsetClientEncoding(conn, pChar(pg_ClientEncoding));
  exce := 'Connection to database failed';
  if (PQstatus(conn)<>CONNECTION_OK) then
  goto ENDNESS;

  try
  exce := 'Command ''' + SQLString + ''' failed';
  PQclear(res);
  res := PQexec(conn,pChar(SQLString));
//=========================================================
if (PQresultStatus(res) = PGRES_TUPLES_OK) then begin
  test:=true;
  if res <> nil then begin
  //=========================================================
  count:= PQntuples(res);
  //=========================================================
  end;
end;
  finally
  end;
//=========================================================
  ENDNESS:
  if not test then db_errorf('%s: %s',[exce,PQerrorMessage(conn)],SQLString);
  if res<>nil then PQclear(res);
  PQfinish(conn);
  sql_count := count;
end;


// #############################################################################
// parseout: special function which substitutes the tag $apos; back to '
// #############################################################################
function parseout(sSrc: string ): string;
begin
  Result := sar(sar(sSrc,
           '11.11.2111','00.00.0000'),
           '$apos;','''');
end;

end.
