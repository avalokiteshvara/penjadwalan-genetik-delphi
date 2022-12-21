unit demo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ShellApi;

type
  Tmain = class(TForm)
    StringGrid1: TStringGrid;
    GroupBox1: TGroupBox;
    b_insert: TButton;
    firstname: TEdit;
    lastname: TEdit;
    birthdate: TEdit;
    telefon: TEdit;
    b_delete: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    GroupBox2: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    e_host: TEdit;
    e_database: TEdit;
    e_user: TEdit;
    e_password: TEdit;
    b_initialize: TButton;
    procedure b_insertClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure b_deleteClick(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
    procedure b_initializeClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  main: Tmain;

implementation
uses
  {$IfDef PostgreSQL} prog_db_postgresql, {$EndIf}
  {$IfDef SQLite} prog_db_sqlite, {$EndIf}

  prog_global, globals;

{$R *.dfm}

procedure init_db();
var   pf : string;
      argv : array[0..4] of pchar;
begin
  {$IfDef PostgreSQL}
  DBHost:=main.e_host.Text;
  DBName:=main.e_database.Text;  
  DBUser:=main.e_user.Text;
  DBPass:=main.e_password.Text;

  pg_ConnParms := 'host=''' + DBHost + ''' user=''' + DBUser + ''' dbname=''' + DBName + ''' password=''' + DBPass + '''';
  {$EndIf}
end;

procedure Tmain.b_insertClick(Sender: TObject);
begin
qs:='insert into address values (''' +
firstname.Text + ''', ''' + lastname.Text + ''', ''' +
birthdate.Text + ''', ''' + telefon.Text  + ''');';
sql_command(qs,true);
qs:='select firstname, lastname, birthdate, telefon from address;';
sql_select_oh_sg(qs, StringGrid1);
end;

procedure Tmain.FormActivate(Sender: TObject);
begin
StringGrid1.Cells[0,0]:='Firstname';
StringGrid1.Cells[1,0]:='Lastname';
StringGrid1.Cells[2,0]:='Birthdate';
StringGrid1.Cells[3,0]:='Telefon';
end;

procedure Tmain.b_deleteClick(Sender: TObject);
begin
qs:='delete from address where (' +
'firstname = ''' + StringGrid1.Cells[0,row] +
''' and lastname = ''' + StringGrid1.Cells[1,row] +
''' and birthdate = ''' + date_max(StringGrid1.Cells[2,row]) +
''' and telefon = ''' + StringGrid1.Cells[3,row]  + ''');';
sql_command(qs,true);
qs:='select firstname, lastname, birthdate, telefon from address;';
sql_select_oh_sg(qs, StringGrid1);
end;

procedure Tmain.StringGrid1Click(Sender: TObject);
begin
row:=StringGrid1.Row;
end;

procedure Tmain.b_initializeClick(Sender: TObject);
var hwnd: THandle;
begin
init_db();
  {$IfDef SQLLOG}
  DeleteFile(pChar(ExtractFilePath(ParamStr(0)) + LOGFILE));
  WriteLog('Start: ' + timetostr(Time));
  ShellExecute(hwnd, 'open', 'tail.exe','-f ' + LOGFILE,nil, SW_SHOWNORMAL);
  {$EndIf}
qs:='select firstname, lastname, birthdate, telefon from address;';
sql_select_oh_sg(qs, StringGrid1);
row:=0;
end;

end.
