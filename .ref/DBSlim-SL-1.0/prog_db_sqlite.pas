unit prog_db_sqlite;

// #############################################################################
// #############################################################################
// Licenced under MOZILLA PUBLIC LICENSE Vers. 1.1, see Licence.txt
// Tilo Ermlich - www.netzpol.de - 27th February 2008
// #############################################################################
// #############################################################################

interface
        uses
        globals, SysUtils, Dialogs, StdCtrls, Messages, WinProcs, Grids,
        Graphics, clipbrd, passqlite, MkSqLite3, Variants, Classes;
        
        function numsplit(zahl, flag:String):String;
        function mySubDate(datestr, intervall: String): String;
        function myPath(path: String): String;
        function myIntervall(intervall: String): String;
        function myNow(): String;
        function myNrConcat(field1, field2: String):String;
        function myDateFormat(column, format: String):String;
        procedure sql_command(SQLString: string; Msg: Boolean);
        procedure sql_select_row(SQLString: string; var myarray: TMyArray);
        procedure sql_select_col(SQLString: string; var myarray: TMyArray);
        procedure sql_select_sg(SQLString: string; var SQLGrid: TStringGrid; myarray: TMyArray);
        procedure sql_select_mh_sg(SQLString: string; var SQLGrid: TStringGrid);
        procedure sql_select_oh_sg(SQLString: string; var SQLGrid: TStringGrid);
        procedure sql_select_matrix(SQLString: string; var sqlrow: integer; var sqlcol: integer; var matrix: TMyMatrix);
        function sql_fill_listbox(SQLString: String; list_box : TListBox) : Boolean;
        function sql_count(SQLString: String) : Integer;
        function parseout(sSrc: string ): string;

        var SQLiteDBx:tmksqlite;

implementation

uses prog_global;

// #############################################################################
//
// #############################################################################
function numsplit(zahl, flag:String):String;
var azahl: TStringList;
begin
  if flag = 'v' then begin
    //zahl:='-12345,6789';
    azahl:=split(zahl,',',true,false);
    if (azahl.count = 0) then result := '0'
    else result := azahl[0];
  end;

  if flag = 'n' then begin
    //zahl:='-12345,6789';
    azahl:=split(zahl,',',true,false);
    if (azahl.count = 0) or (azahl.count = 1) then result := '0'
    else result := azahl[1];
  end;

end;


// #############################################################################
//
// #############################################################################
function mySubDate(datestr, intervall: String): String;
begin
//date('yyyy-mm-dd', '-30 DAY', 'localtime'):
result:='DATE(''' + datestr + ''', ''-' + intervall + ''',''LOCALTIME'')';
end;


// #############################################################################
//
// #############################################################################
function myPath(path: String): String;
begin
//Main_Form.frame_formular.dokuvorl.Text:
result:=path;
end;


// #############################################################################
//
// #############################################################################
function myIntervall(intervall: String): String;
begin
//datetime('now', '-1 year', 'localtime'):
result:='datetime(''now'', ''' + intervall + ''',''localtime'')';
end;


// #############################################################################
//
// #############################################################################
function myNow(): String;
begin
//datetime('now','localtime'):
result:='datetime(''now'', ''localtime'')';
end;


// #############################################################################
//
// #############################################################################
function myNrConcat(field1, field2: String):String;
begin
//a.auftrgnr || '-' || a.zusatznr:
result:= field1 + ' || ''-'' || ' + field2;
end;


// #############################################################################
//
// #############################################################################
function myDateFormat(column, format: String):String;
begin
//strftime('%d.%m.%Y', datum):
result:='strftime(''' + format + ''', ' + column + ')';
end;


// #############################################################################
// parseout: Substitutes the tag --- back to dummy integer -1
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
// sql_command
// #############################################################################
procedure sql_command(SQLString: string; Msg: Boolean);
// Parsing muß in der jeweiligen prog_Datei vorgenommen werden
// var SQLiteRS:IMksqlStmt;
begin
  {$IfDef SQLLOG}
  writeLog('sql_command: ' + SQLString);
  Clipboard.AsText :='sql_command: ' + SQLString;
  {$EndIf}
  SQLiteDBx.execCmd(SQLString);
{
    if Msg then begin
        if (PQresultStatus(res) = PGRES_COMMAND_OK) then
                begin
                MessageBox(0,'            Vorgang erfolgreich!', NetzpMessage, MB_OK);
                test:=true;
                end
        else
                MessageBox(0,'           Vorgang fehlgeschlagen!', NetzpMessage, MB_OK);
    end;
}
end;


// #############################################################################
// sql_select_row
// #############################################################################
procedure sql_select_row(SQLString: string; var myarray: TMyArray);
// Parsing ok
var
SQLiteRS:IMksqlStmt;
j, numcol:integer;
label ENDNESS;
begin
  {$IfDef SQLLOG}
  writeLog('sql_select_row: ' + SQLString);
  Clipboard.AsText :='sql_select_row: ' + SQLString;  
  {$EndIf}
  { TODO -otermlich : Ad-Hoc-Methode wg. meta_id = '---' bei leeren SGs }
  SQLString:=parse_metaid(SQLString);

  SQLiteRS:=SQLiteDBx.exec(SQLString);
  numcol:= SQLiteRS.fieldCount;

  //showmessage(SQLString + ', SQLiteRS.rowCount:' + inttostr(SQLiteRS.rowCount));

  // SQLiteRS.rowCount = -1: kein Ergebnis, SQLiteRS.rowCount > 0: ein Ergebnis
  if SQLiteRS.rowCount > 0 then begin
      SetLength(myarray,numcol +1);
      for j := 0 to numcol - 1 do
        if numcol <> 0 then myarray[j]:= parseout(varTostr(SQLiteRS[j]))
        else myarray[j]:= '---';

  end else begin
  SetLength(myarray, 100);
  // for j := 0 to 99 do myarray[j] := '-- kein Eintrag --'
  for j := 0 to 99 do myarray[j] := '---'
  end;


end;


// #############################################################################
// sql_select_col
// #############################################################################
procedure sql_select_col(SQLString: string; var myarray: TMyArray);
// Parsing ok
var
SQLiteRS:IMksqlStmt;
i, numrow:integer;

begin
  {$IfDef SQLLOG}
  writeLog('sql_select_col: ' + SQLString);  
  Clipboard.AsText :='sql_select_col: ' + SQLString;
  {$EndIf}

  SQLiteRS:=SQLiteDBx.exec(SQLString);
  numrow:= SQLiteRS.rowCount;

  if numrow = -1 then numrow:= 0;

  SetLength(myarray,numrow + 1);

  if numrow > 0 then
    for i := 1 to numrow do begin
    myarray[i]:= parseout(varTostr(SQLiteRS[0]));
    SQLiteRS.next
    end else myarray[0]:= '-';

end;


// #############################################################################
// sql_select_sg
// #############################################################################
procedure sql_select_sg(SQLString: string; var SQLGrid: TStringGrid; myarray: TMyArray);
  { TODO : 1. Zeile wird nicht mit angezeigt }

// Parsing ok
var
SQLiteRS:IMksqlStmt;
i,j, numcol, numrow:integer;
begin
  {$IfDef SQLLOG}
  writeLog('sql_select_sg: ' + SQLString);
  Clipboard.AsText :='sql_select_sg: ' + SQLString;
  {$EndIf}

  SQLiteRS:=SQLiteDBx.exec(SQLString);
  numcol:= SQLiteRS.fieldCount;
  numrow:= SQLiteRS.rowCount;

  SQLGrid.ColCount:= numcol;
  SQLGrid.RowCount:= numrow + 1;

      for j := 0 to numcol -1 do SQLGrid.Cells[j, 0] := parseout(myarray[j]);

      // for i := 1 to numrow -1 do begin
      for i := 1 to numrow do begin
        for j := 0 to numcol -1 do SQLGrid.Cells[j, i]:= parseout(varTostr(SQLiteRS[j]));
      SQLiteRS.next;  
      end;

      if numrow > 1 then begin
        SQLGrid.FixedRows:=1;
        SQLGrid.FixedColor:= clBtnFace;
      end;

      if numrow = -1 then begin
        SQLGrid.RowCount:=2;
        SQLGrid.FixedRows:=1;
        // for j := 0 to numcol - 1 do SQLGrid.Cells[j, 1]:= '---';
        SQLGrid.Cells[0, 1]:= '-1'; // meta_id
        for j := 1 to numcol - 1 do SQLGrid.Cells[j, 1]:= '---';
      end;

end;


// #############################################################################
// sql_select_mh_sg
// #############################################################################
procedure sql_select_mh_sg(SQLString: string; var SQLGrid: TStringGrid);
// Parsing ok
var
SQLiteRS:IMksqlStmt;
i,j, numcol, numrow:integer;
begin
  {$IfDef SQLLOG}
  writeLog('sql_select_mh_sg: ' + SQLString);
  Clipboard.AsText :='sql_select_mh_sg: ' + SQLString;
  {$EndIf}

  SQLiteRS:=SQLiteDBx.exec(SQLString);
  numcol:= SQLiteRS.fieldCount;
  numrow:= SQLiteRS.rowCount;

  SQLGrid.ColCount:= numcol;
  SQLGrid.RowCount:= numrow;

      if numrow = -1 then begin
        SQLGrid.Cells[0, 0]:= '-1'; // meta_id
        for j := 1 to numcol - 1 do SQLGrid.Cells[j, 0]:= '---'
      end;

  for i := 0 to numrow - 1 do begin
    for j := 0 to numcol - 1 do SQLGrid.Cells[j, i]:= parseout(varTostr(SQLiteRS[j]));
  SQLiteRS.next;
  end;
end;


// #############################################################################
// sql_select_oh_sg
// #############################################################################
procedure sql_select_oh_sg(SQLString: string; var SQLGrid: TStringGrid);
// Parsing ok
var
i,j, numcol, numrow:integer;
SQLiteRS:IMksqlStmt;
begin
    {$IfDef SQLLOG}
     writeLog('sql_select_oh_sg: ' + SQLString);    
     Clipboard.AsText :='sql_select_oh_sg: ' + SQLString;
    {$EndIf}

     SQLiteRS:=SQLiteDBx.exec(SQLString);
      numcol:= SQLiteRS.fieldCount;
      numrow:= SQLiteRS.rowCount;

      SQLGrid.ColCount:= numcol;

        if numrow = -1 then begin
            SQLGrid.Cells[0, 1]:= '-1'; // meta_id
            SQLGrid.RowCount:= numrow + 3;
            for j := 1 to numcol - 1 do SQLGrid.Cells[j, 1]:= '---';
        end else begin
            SQLGrid.RowCount:= numrow + 1;
            for i := 0 to numrow - 1 do begin
                for j := 0 to numcol -1 do
                    SQLGrid.Cells[j, (i + 1)]:= parseout(varTostr(SQLiteRS[j]));
                SQLiteRS.next;
            end;
        end;
end;


// #############################################################################
// sql_select_matrix: Fills a matrix (array of arrays) with results of a
// SQL statement
// #############################################################################
procedure sql_select_matrix(SQLString: string; var sqlrow: integer; var sqlcol: integer; var matrix: TMyMatrix);
// Parsing ok
var
SQLiteRS:IMksqlStmt;
i,j, numcol, numrow:integer;

begin
  {$IfDef SQLLOG}
  writeLog('sql_select_matrix: ' + SQLString);
  Clipboard.AsText :='sql_select_matrix: ' + SQLString;
  {$EndIf}

  SQLiteRS:=SQLiteDBx.exec(SQLString);
  numcol:= SQLiteRS.fieldCount;
  numrow:= SQLiteRS.rowCount;

  sqlcol:= numcol;
  sqlrow:= numrow;
  if numrow > 0 then begin
    SetLength(matrix,numrow,numcol);

    for i := 0 to numrow - 1 do begin
      for j := 0 to numcol - 1 do matrix[i,j]:= parseout(varTostr(SQLiteRS[j]));
      SQLiteRS.next
    end;
  end else begin
    sqlcol:= 0;
    sqlrow:= 0;
    matrix:=nil;
  end;
end;


// #############################################################################
// sql_fill_listbox: Fills a ListBox with results of a SQL statement, gives
// back true for filled result set otherwise false
// #############################################################################
function sql_fill_listbox(SQLString: String; list_box : TListBox) : Boolean;
// Parsing ok
var
SQLiteRS:IMksqlStmt;
i, numrow:integer;
begin
  {$IfDef SQLLOG}
  writeLog('sql_fill_listbox, ' + list_box.Name + ': ' + SQLString);
  Clipboard.AsText :='sql_fill_listbox, ' + list_box.Name + ': ' + SQLString;
  {$EndIf}

  SQLiteRS:=SQLiteDBx.exec(SQLString);
  numrow:= SQLiteRS.rowCount + 1;
  list_box.Clear;

  for i := 1 to numrow -1 do begin
    list_box.Items.Add(parseout(varTostr(SQLiteRS[0])));
    SQLiteRS.next;
  end;
  sql_fill_listbox := true;
  
end;


// #############################################################################
// sql_count: Counts the number of results for a given SQL string
// #############################################################################
function sql_count(SQLString: String) : Integer;
// Parsing ok
var
SQLiteRS:IMksqlStmt;
count:integer;
begin
  {$IfDef SQLLOG}
  writeLog('sql_count: ' + SQLString);
  Clipboard.AsText :='sql_count: ' + SQLString;
  {$EndIf}
  SQLiteRS:=SQLiteDBx.exec(SQLString);
  count:=SQLiteRS.rowCount;
  if count < 1 then sql_count := 0 else sql_count := count;

end;


// #############################################################################
// parseout: Substitutes the tag $apos; back to '
// #############################################################################
function parseout(sSrc: string ): string;
var
  nPos: integer;
begin
  nPos        := Pos( '$apos;', sSrc );
  while(nPos > 0)do
  begin
    Delete( sSrc, nPos, 6 );
    Insert( '''', sSrc, nPos );
    nPos := Pos( '$apos;', sSrc );
  end;
  Result := sSrc;
end;

// #############################################################################
// initialization: creates the connection
// #############################################################################
initialization
{$IfDef SQLite}
SQLiteDBx := TMkSqlite.create(nil);
SQLiteDBx.dbName:='demo.s3db';
SQLiteDBx.open;
{$EndIf}
end.
