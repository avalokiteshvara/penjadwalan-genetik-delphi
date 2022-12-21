unit fuMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DBCtrls, Grids, DBGrids, DB, mySQLDbTables,
  MySqlSSHDatabase;

type
  TfmMain = class(TForm)
    lbTables: TListBox;
    Label1: TLabel;
    dbgData: TDBGrid;
    dbnData: TDBNavigator;
    Label2: TLabel;
    buConnect: TButton;
    buDisconnect: TButton;
    buClose: TButton;
    DataSource1: TDataSource;
    MySSHDB: TMySSHDatabase;
    mySQLT: TmySQLTable;
    procedure buCloseClick(Sender: TObject);
    procedure buConnectClick(Sender: TObject);
    procedure buDisconnectClick(Sender: TObject);
    procedure lbTablesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation
uses fuLogin;

{$R *.dfm}

procedure TfmMain.buCloseClick(Sender: TObject);
begin
   Close;
end;


procedure TfmMain.buConnectClick(Sender: TObject);
begin
   if ShowConnectDlg(MySSHDB) then
   begin
      try
        MySSHDB.Connected := true;
        Screen.Cursor := crSQLWait;
        MySSHDB.GetTableNames('',lbTables.Items);
        Screen.Cursor := crDefault;
        buConnect.Enabled := False;
        buDisconnect.Enabled := True;
      except
        on E:Exception do
        begin
           Application.MessageBox(PChar(E.Message), 'Connection fault',
           MB_OK or MB_ICONINFORMATION);
        end;
      end;
   end;
end;

procedure TfmMain.buDisconnectClick(Sender: TObject);
begin
   MySSHDB.Close;
   buConnect.Enabled := True;
   buDisConnect.Enabled := False;
   lbTables.Clear;
end;

procedure TfmMain.lbTablesClick(Sender: TObject);
begin
   if lbTables.ItemIndex = -1 then Exit;
   mySQLT.Close;
   MySQLT.TableName := lbTables.Items[lbTables.ItemIndex];
   MySQLT.Open;
end;

end.
