unit mySQLConnFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,MySQLDbTables,MySQLTypes;

type
  TConnForm = class(TForm)
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    DBUserID: TEdit;
    DBPasswd: TEdit;
    Label3: TLabel;
    DBName: TEdit;
    Label4: TLabel;
    DBHost: TEdit;
    Label5: TLabel;
    DBPort: TEdit;
    DBLogin: TCheckBox;
    OkBtn: TButton;
    CancelBtn: TButton;
    GroupBox1: TGroupBox;
    CheckBox2: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
  private
    { Private declarations }
    Database: TMySQLDatabase;
    MySQLOpt : TConnectOptions;
    function Edit: Boolean;
    procedure SetOption(Opt :TConnectOptions);
    function  GetOption:TConnectOptions;
  public
    { Public declarations }
    procedure GetDatabaseProperty(Db: TMySQLDatabase);
    procedure SetDatabaseProperty(Db: TMySQLDatabase);
  end;

function EditDatabase(ADatabase: TMySQLDatabase): Boolean;

var
  ConnForm: TConnForm;

implementation

{$R *.DFM}

function EditDatabase(ADatabase: TMySQLDatabase): Boolean;
begin
  with TConnForm.Create(Application) do
  try
    Database := ADatabase;
    Result := Edit;
  finally
    Free;
  end;
end;

function TConnForm.Edit: Boolean;
begin
  GetDatabaseProperty(Database);
  Result := False;
  if ShowModal = mrOk then
  begin
    SetDatabaseProperty(Database);
    Result := True;
  end;
end;

procedure TConnForm.SetOption(Opt :TConnectOptions);
begin
   if coFoundRows in Opt then CheckBox2.Checked := True;
   if coNoSchema in Opt then CheckBox5.Checked := True;
   if coCompress in Opt then CheckBox6.Checked := True;
   if coODBC in Opt then CheckBox7.Checked := True;
   if coIgnoreSpaces in Opt then CheckBox9.Checked := True;
   if coInteractive in Opt then CheckBox10.Checked := True;
   if coSSL in Opt then CheckBox11.Checked := True;
end;

function  TConnForm.GetOption:TConnectOptions;
begin
   Result :=[];
   if CheckBox2.Checked then Include(Result,coFoundRows);
   if CheckBox5.Checked then Include(Result,coNoSchema);
   if CheckBox6.Checked then Include(Result,coCompress);
   if CheckBox7.Checked then Include(Result,coODBC);
   if CheckBox9.Checked then Include(Result,coIgnoreSpaces);
   if CheckBox10.Checked then Include(Result,coInteractive);
   if CheckBox11.Checked then Include(Result,coSSL);
end;

procedure TConnForm.GetDatabaseProperty(Db: TMySQLDatabase);
begin
  DBName.Text := DB.DatabaseName;
  DBUserId.Text := db.UserName;
  DBPasswd.Text := db.UserPassword;
  DBHost.Text := Db.Host;
  DBPort.Text := IntToStr(Db.Port);
  DBLogin.Checked := db.LoginPrompt;
  MySQLOpt := DB.ConnectOptions;
  SetOption(MySQLOpt);
end;

procedure TConnForm.SetDatabaseProperty(Db: TMySQLDatabase);
begin
  DB.DatabaseName := DBName.Text;
  db.UserName := DBUserId.Text;
  db.UserPassword := DBPasswd.Text;
  Db.Host := DBHost.Text;
  Db.Port := StrToInt(DBPort.Text);
  db.LoginPrompt := DBLogin.Checked;
  DB.ConnectOptions := GetOption;
end;

end.

