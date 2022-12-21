unit uDM;

interface

uses
  SysUtils, Classes, mySQLDbTables, DB, Forms, Dialogs, Windows;

type
  TDM = class(TDataModule)
    mySQLDatabase1: TmySQLDatabase;
    mySQLQuery1: TmySQLQuery;
    mySQLTable1: TmySQLTable;
    mySQLQuery2: TmySQLQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    {*database connecttion setting*}
    sDBServer,
      sDBUser,
      sDBPassword,
      sDBName: string;
    iDBPort: Integer;

    procedure ErrorHandle(ErrorClass, ErrorMSG, ErrorSQL, sPesan: string);
    function ExecSQL(const sSQL: string; const Args: array of const; oQuery:
      TmySQLQuery; sPesan: string = ''): Boolean;
    function ValidSQLString(sSQL: string): string;
    function OpenConnection: boolean;

  end;

var
  DM: TDM;

implementation

{$R *.dfm}

uses
  uHelper;

procedure TDM.ErrorHandle(ErrorClass, ErrorMSG, ErrorSQL, sPesan: string);
var
  F: TextFile;
  FileHandle: integer;
begin
  ShortDateFormat := 'dd-mm-yyyy';
  if not FileExists(ExtractFilePath(Application.ExeName) +
    '\errorlogs\' + sDBName + '_' + DateToStr(NOW) + '.txt') then
  begin
    FileHandle := FileCreate(ExtractFilePath(Application.ExeName) +
      '\errorlogs\' + sDBName + '_' + DateToStr(NOW) + '.txt');
    FileClose(FileHandle);
  end;
  AssignFile(F, ExtractFilePath(Application.ExeName) +
    '\errorlogs\' + sDBName + '_' + DateToStr(NOW) + '.txt');
  Append(F);
  Writeln(F, '$Tanggal Error  : ' + DateTimeToStr(NOW));
  Writeln(F, '$Error Class    : ', ErrorClass);
  WriteLn(F, '$Error Message  : ');
  WriteLn(F, ErrorMSG);
  WriteLn(F, '$Pesan          :', sPesan);
  Writeln(F, '$SQL Text       :');
  WriteLn(F, ErrorSQL);
  WriteLn(F, ' ');
  WriteLn(F,
    '******************************************************************');
  WriteLn(F, ' ');
  CloseFile(F);

  MessageDlg(
    'Kami mohon maaf, namun sepertinya Aplikasi mengalami Error'#13#10 +
    'ERROR    : '#13#10 + ErrorMSG + #13#10 +
    'DateTime : ' + DateTimeToStr(NOW) + #13#10 +
    'FileKeteranganError : ' + sDBName + '_' + DateToStr(NOW) +
    '.txt (tersimpan di folder errorlogs)' + #13#10 +
    'Mohon kirimkan / serahkan FileKeteranganError ke:' + #13#10 +
    'Administrator Aplikasi atau TEAM DEVELOPER', mtError, [mbOK], 0);
end;

function TDM.OpenConnection: boolean;
begin
  mySQLDatabase1.Connected := False;
  mySQLDatabase1.Host := sDBServer;
  mySQLDatabase1.Username := sDBUser;
  mySQLDatabase1.UserPassword := sDBPassword;
  mySQLDatabase1.DatabaseName := sDBName;
  mySQLDatabase1.Port := iDBPort;
  Result := true;
  try
    mySQLDatabase1.Connected := True;
  except
    on E: Exception do
    begin
      Application.MessageBox(PChar(E.Message +
        #13#13'Ada masalah dengan setting koneksi DB anda'#13 +
        'Mohon periksa file config.ini'#13 +
        'Aplikasi tidak dapat dilanjutkan'), 'Error',
        MB_OK + MB_ICONSTOP);
      Result := False;
    end;
  end;
end;

function TDM.ExecSQL(const sSQL: string; const Args: array of const;
  oQuery: TmySQLQuery; sPesan: string): Boolean;
var
  bActive: Boolean;
begin
  if oQuery = nil then
    oQuery := mySQLQuery1;

  with oQuery do
  begin
    Close;
    if Length(Args) = 0 then
      SQL.Text := ValidSQLString(sSQL)
    else
      SQL.Text := ValidSQLString(Format(sSQL, Args));

    bActive := True;

    try
      mySQLDatabase1.StartTransaction;
      if (UpperCase(Copy(SQL.Text, 1, 4)) = 'SELE') then
      begin
        Open;
        bActive := (Active and not oQuery.IsEmpty);
        mySQLDatabase1.Commit;
      end
      else
      begin
        ExecSQL;
        mySQLDatabase1.Commit;
      end;
    except
      on E: Exception do
      begin
        mySQLDatabase1.Rollback;
        ShortDateFormat := 'dd-mm-yyyy';
        ErrorHandle(E.ClassName, E.Message, SQL.Text, sPesan);
        bActive := False;
      end;
    end;
  end;
  Result := bActive;
end;

function TDM.ValidSQLString(sSQL: string): string;
begin
  Result := StringReplace(StringReplace(StringReplace(sSQL, '""', '""',
    [rfReplaceAll, rfIgnoreCase]), #39, #39 + #39,
    [rfReplaceAll, rfIgnoreCase]), '"', #39, [rfReplaceAll, rfIgnoreCase]);
end;

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  mySQLDatabase1.Connected := False;

  sDBServer := INIReadString('Database', 'server', '');
  iDBPort := StrToInt(INIReadString('Database', 'port', '3306'));
  sDBUser := INIReadString('Database', 'user', '');
  sDBPassword := INIReadString('Database', 'password', '');
  sDBName := INIReadString('Database', 'database', '');
end;

end.

