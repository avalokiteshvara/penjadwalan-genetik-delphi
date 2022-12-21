unit uFrmDateTime;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, mySQLDbTables, Grids, DBGrids, AppEvnts;

type
  TFrmDateTime = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    txtKodeHari: TEdit;
    Label2: TLabel;
    txtNamaHari: TEdit;
    btnBaruHari: TButton;
    btnBatalHari: TButton;
    btnSimpanHari: TButton;
    dtGridViewHari: TDBGrid;
    DataSource1: TDataSource;
    mySQLQueryHari: TmySQLQuery;
    GroupBox2: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    txtKodeJam: TEdit;
    txtRangeJam: TEdit;
    btnBaruJam: TButton;
    btnBatalJam: TButton;
    btnSimpanJam: TButton;
    dtGridViewJam: TDBGrid;
    Label5: TLabel;
    DataSource2: TDataSource;
    mySQLQueryJam: TmySQLQuery;
    ApplicationEvents1: TApplicationEvents;
    btn3: TButton;
    procedure btnBaruHariClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnBaruJamClick(Sender: TObject);
    procedure btnSimpanHariClick(Sender: TObject);
    procedure btnSimpanJamClick(Sender: TObject);
    procedure dtGridViewHariKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dtGridViewJamKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnBatalHariClick(Sender: TObject);
    procedure btnBatalJamClick(Sender: TObject);
    procedure dtGridViewHariCellClick(Column: TColumn);
    procedure dtGridViewJamCellClick(Column: TColumn);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure btn3Click(Sender: TObject);
  private
    procedure ClearTxt(tipe: Integer);
    procedure LoadData(tipe: Integer);
    procedure SetEnabledOnBtn(tipe: Integer; btnNewEnable, btnCancelEnable,
      btnSaveEnable: Boolean);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmDateTime: TFrmDateTime;
  _selectedKodeHr: Integer;
  _selectedKodeJm: Integer;
implementation

{$R *.dfm}

uses
  uDM;

const
  HARI = 0;
  JAM = 1;
  SEMUA = 2;

procedure TFrmDateTime.ClearTxt(tipe: Integer);
begin
  if tipe = HARI then
  begin
    txtKodeHari.Clear;
    txtNamaHari.Clear;
  end
  else
  begin
    txtKodeJam.Clear;
    txtRangeJam.Clear;
  end;
end;

procedure TFrmDateTime.LoadData(tipe: Integer);
begin
  if tipe = HARI then
  begin
    ClearTxt(HARI);
    DM.ExecSQL('SELECT kode,nama as hari,aktif FROM hari', [], mySQLQueryHari);
    dtGridViewHari.Columns[2].Visible := False;
  end
  else
  begin
    ClearTxt(JAM);
    DM.ExecSQL('SELECT * FROM jam ORDER BY kode', [], mySQLQueryJam);
    dtGridViewHari.Columns[2].Visible := False;
  end;

end;

procedure TFrmDateTime.SetEnabledOnBtn(tipe: Integer; btnNewEnable, btnCancelEnable, btnSaveEnable: Boolean);
begin
  case tipe of
    HARI:
      begin
        btnBaruHari.Enabled := btnNewEnable;
        txtKodeHari.ReadOnly := btnNewEnable;
        txtNamaHari.ReadOnly := btnNewEnable;

        btnBatalHari.Enabled := btnCancelEnable;
        btnSimpanHari.Enabled := btnSaveEnable;
        //cbAktif.Enabled := btnSaveEnable;
      end;
    JAM:
      begin
        btnBaruJam.Enabled := btnNewEnable;
        txtKodeJam.ReadOnly := btnNewEnable;
        txtRangeJam.ReadOnly := btnNewEnable;

        btnBatalJam.Enabled := btnCancelEnable;
        btnSimpanJam.Enabled := btnSaveEnable;
      end;
    SEMUA:
      begin
        btnBaruHari.Enabled := btnNewEnable;
        btnBatalHari.Enabled := btnCancelEnable;
        btnBatalJam.Enabled := btnCancelEnable;

        btnSimpanHari.Enabled := btnCancelEnable;
        btnSimpanJam.Enabled := btnSaveEnable;

        //cbAktif.Enabled = btnSaveEnable;

        txtKodeHari.ReadOnly := btnNewEnable;
        txtNamaHari.ReadOnly := btnNewEnable;
        btnBaruJam.Enabled := btnNewEnable;
        txtKodeJam.ReadOnly := btnNewEnable;
        txtRangeJam.ReadOnly := btnNewEnable;

      end;
  end;
end;

procedure TFrmDateTime.btnBaruHariClick(Sender: TObject);
begin
  ClearTxt(HARI);
  SetEnabledOnBtn(HARI, False, True, true);
  _selectedKodeHr := -1;
end;

procedure TFrmDateTime.FormCreate(Sender: TObject);
begin
  _selectedKodeHr := -1;
  _selectedKodeJm := -1;
  LoadData(HARI);
  LoadData(JAM);
  SetEnabledOnBtn(SEMUA, True, False, False);
end;

procedure TFrmDateTime.btnBaruJamClick(Sender: TObject);
begin
  ClearTxt(JAM);
  SetEnabledOnBtn(JAM, false, true, true);
  _selectedkodeJm := -1;
end;

procedure TFrmDateTime.btnSimpanHariClick(Sender: TObject);
var
  check: string;
  q: string;
begin
  if (Trim(txtKodeHari.Text) = '') or (Trim(txtNamaHari.Text) = '') then
  begin
    MessageDlg('Data Belum Lengkap', mtInformation, [mbOK], 0);
    Exit;
  end;

  if _selectedKodeHr <> -1 then
  begin
    //update data
    check :=
      Format(
      'SELECT CAST(COUNT(*) AS CHAR(1)) '#13 +
      'FROM hari '#13 +
      'WHERE (kode=%d OR nama="%s") AND kode <> %d',
      [StrToInt(txtKodeHari.Text), txtNamaHari.Text, _selectedkodeHr]);

    DM.ExecSQL(check, [], dm.mySQLQuery1);
    if DM.mySQLQuery1.Fields[0].AsInteger <> 0 then
    begin
      MessageDlg('Kode Atau Nama ini sudah ada!', mtWarning, [mbOK], 0);
      Exit;
    end;

    q := Format(
      'UPDATE hari '#13 +
      'SET kode = %d,'#13 +
      '    nama = "%s",'#13 +
      '    aktif = "%s"'#13 +
      'WHERE kode = %d',
      [StrToInt(txtKodeHari.Text),
      txtNamaHari.Text,
        'True',
        _selectedkodeHr]);

    DM.ExecSQL(q, [], DM.mySQLQuery1);

    //update waktu_tidak_bersedia

    q := Format(
      'UPDATE waktu_tidak_bersedia '#13 +
      'SET kode_hari = %d '#13 +
      'WHERE kode_hari = %d', [
      StrToInt(txtKodeHari.Text),
        _selectedkodeHr]);
    DM.ExecSQL(q, [], DM.mySQLQuery1);
  end
  else
  begin
    //new data

    check := Format(
      'SELECT CAST(COUNT(*) AS CHAR(1)) '#13 +
      'FROM hari '#13 +
      'WHERE kode="%s" OR nama="%s"',
      [txtKodeHari.Text, txtNamaHari.Text]);

    DM.ExecSQL(check, [], dm.mySQLQuery1);
    if DM.mySQLQuery1.Fields[0].AsInteger <> 0 then
    begin
      MessageDlg('Kode Atau Nama ini sudah ada!', mtWarning, [mbOK], 0);
      Exit;
    end;

    q := Format(
      'INSERT INTO hari(kode,nama,aktif) '#13 +
      'VALUES(%d,"%s","%s")',
      [StrToInt(txtKodeHari.Text),
      txtNamaHari.Text,
        'True']);
    DM.ExecSQL(q, [], DM.mySQLQuery1);
  end;
  //set to "-1" agar disign sebagai databaru
  _selectedKodeHr := -1;

  txtKodeHari.Clear();
  txtNamaHari.Clear();
  SetEnabledOnBtn(HARI, true, false, false);
  LoadData(HARI);
end;

procedure TFrmDateTime.btnSimpanJamClick(Sender: TObject);
var
  check: string;
  q: string;
begin
  if Trim(txtKodeJam.Text) = '' then
  begin
    MessageDlg('Data Belum Lengkap', mtWarning, [mbOK], 0);
    Exit;
  end;

  if _selectedKodeJm <> -1 then
  begin
    //update data
    Check := Format(
      'SELECT CAST(COUNT(*) AS CHAR(1)) '#13 +
      'FROM jam '#13 +
      'WHERE kode = %d and kode <> %d ',
      [StrToInt(txtKodeJam.Text), _selectedkodeJm]);

    DM.ExecSQL(check, [], dm.mySQLQuery1);
    if DM.mySQLQuery1.Fields[0].AsInteger <> 0 then
    begin
      MessageDlg('Kode ini sudah ada!', mtWarning, [mbOK], 0);
      Exit;
    end;

    //update jam
    q := Format(
      'UPDATE jam '#13 +
      'SET kode = %d, '#13 +
      '    range_jam = "%s" '#13 +
      'WHERE kode = %d',
      [StrToInt(txtKodeJam.Text),
      txtRangeJam.Text,
        _selectedkodeJm]);
    DM.ExecSQL(q, [], DM.mySQLQuery1);

    //update waktu_tidak_bersedia

    q := Format(
      'UPDATE waktu_tidak_bersedia '#13 +
      'SET kode_jam = %d '#13 +
      'WHERE kode_jam = %d',
      [StrToInt(txtKodeJam.Text),
      _selectedkodeJm]);
    DM.ExecSQL(q, [], DM.mySQLQuery1);

  end
  else
  begin
    //new data
    Check := Format(
      'SELECT CAST(COUNT(*) AS CHAR(1)) '#13 +
      'FROM jam '#13 +
      'WHERE kode = %d',
      [StrToInt(txtKodeJam.Text)]);

    DM.ExecSQL(check, [], dm.mySQLQuery1);
    if DM.mySQLQuery1.Fields[0].AsInteger <> 0 then
    begin
      MessageDlg('Kode ini sudah ada!', mtWarning, [mbOK], 0);
      Exit;
    end;

    q := Format(
      'INSERT INTO jam(kode,range_jam) ' +
      'VALUES(%d,"%s")',
      [StrToInt(txtKodeJam.Text),
      txtRangeJam.Text]);
    DM.ExecSQL(q, [], DM.mySQLQuery1);
  end;

  _selectedkodeJm := -1; //set to "-1" agar disign sebagai databaru

  txtKodeJam.Clear();
  txtRangeJam.Clear();
  SetEnabledOnBtn(JAM, true, false, false);
  LoadData(JAM);
end;

procedure TFrmDateTime.dtGridViewHariKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  q: string;
begin
  if Key = VK_DELETE then
  begin
    if dtGridViewHari.DataSource.DataSet.IsEmpty then
      Exit;

    if MessageDlg('Yakin ingin menghapus data ini?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      //delete hari
      q := Format('DELETE FROM hari WHERE kode = %d', [StrToInt(dtGridViewHari.DataSource.DataSet['kode'])]);
      DM.ExecSQL(q, [], dm.mySQLQuery1);

      //delete hari dari waktu tidak bersedia
      q := Format('DELETE FROM waktu_tidak_bersedia WHERE kode_hari = %d',
        [StrToInt(dtGridViewHari.DataSource.DataSet['kode'])]);
      DM.ExecSQL(q, [], dm.mySQLQuery1);
    end;
    btnBatalHari.Click;
    LoadData(HARI);
  end;
end;

procedure TFrmDateTime.dtGridViewJamKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  q: string;
begin
  if Key = VK_DELETE then
  begin
    if dtGridViewJam.DataSource.DataSet.IsEmpty then
      Exit;

    if MessageDlg('Yakin ingin menghapus data ini?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      //delete jam
      q := Format('DELETE FROM jam WHERE kode = %d', [StrToInt(dtGridViewJam.DataSource.DataSet['kode'])]);
      DM.ExecSQL(q, [], dm.mySQLQuery1);

      //delete jam dari waktu tidak bersedia
      q := Format('DELETE FROM waktu_tidak_bersedia WHERE kode_jam = %d',
        [StrToInt(dtGridViewJam.DataSource.DataSet['kode'])]);
      DM.ExecSQL(q, [], dm.mySQLQuery1);
    end;
    btnBatalJam.Click;
    LoadData(JAM);
  end;
end;

procedure TFrmDateTime.btnBatalHariClick(Sender: TObject);
begin
  ClearTxt(HARI);
  SetEnabledOnBtn(HARI, true, false, false);
end;

procedure TFrmDateTime.btnBatalJamClick(Sender: TObject);
begin
  ClearTxt(JAM);
  SetEnabledOnBtn(JAM, true, false, false);
end;

procedure TFrmDateTime.dtGridViewHariCellClick(Column: TColumn);
begin
  SetEnabledOnBtn(HARI, false, true, true);
  _selectedkodeHr := StrToInt(dtGridViewHari.DataSource.DataSet['kode']);
  txtKodeHari.Text := dtGridViewHari.DataSource.DataSet['kode'];
  txtNamaHari.Text := dtGridViewHari.DataSource.DataSet['hari'];
end;

procedure TFrmDateTime.dtGridViewJamCellClick(Column: TColumn);
begin
  SetEnabledOnBtn(JAM, false, true, true);
  _selectedkodeJm := StrToInt(dtGridViewJam.DataSource.DataSet['kode']);
  txtKodeJam.Text := dtGridViewJam.DataSource.DataSet['kode'];
  txtRangeJam.Text := dtGridViewJam.DataSource.DataSet['range_jam'];
end;

procedure TFrmDateTime.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
var
  i: SmallInt;
begin
  if Msg.message = WM_MOUSEWHEEL then
  begin
    Msg.message := WM_KEYDOWN;
    Msg.lParam := 0;
    i := HiWord(Msg.wParam);
    if i > 0 then
      Msg.wParam := VK_UP
    else
      Msg.wParam := VK_DOWN;

    Handled := False;
  end;
end;

procedure TFrmDateTime.btn3Click(Sender: TObject);
begin
  Close;
end;

end.

