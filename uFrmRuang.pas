unit uFrmRuang;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, StdCtrls, DB, mySQLDbTables;

type
  TFrmRuang = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    txtNama: TEdit;
    txtKapasitas: TEdit;
    cmbJenis: TComboBox;
    btnBaru: TButton;
    btnBatal: TButton;
    btnSimpan: TButton;
    dtGridView: TDBGrid;
    DataSource1: TDataSource;
    mySQLQuery1: TmySQLQuery;
    btn3: TButton;
    btnCari: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnSimpanClick(Sender: TObject);
    procedure btnBaruClick(Sender: TObject);
    procedure btnBatalClick(Sender: TObject);
    procedure dtGridViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dtGridViewCellClick(Column: TColumn);
    procedure btn3Click(Sender: TObject);
    procedure btnCariClick(Sender: TObject);
  private
    procedure LoadData;
    procedure SetEnabledOnBtn(btnNewEnable, btnCancelEnable,
      btnSaveEnable: Boolean);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmRuang: TFrmRuang;
  _selectedKode: Integer;
implementation

{$R *.dfm}

uses
  uDM, uHelper;

procedure TFrmRuang.LoadData();
var
  q: string;
begin
  ClearTextBox(Self);
  q := 'SELECT * FROM ruang';
  DM.ExecSQL(q, [], mySQLQuery1);
  dtGridView.Columns[0].Visible := False;
end;

procedure TFrmRuang.SetEnabledOnBtn(btnNewEnable, btnCancelEnable, btnSaveEnable: Boolean);
begin
  btnBaru.Enabled := btnNewEnable;
  btnBatal.Enabled := btnCancelEnable;
  btnSimpan.Enabled := btnSaveEnable;
  cmbJenis.Enabled := btnSaveEnable;

  SetReadOnlyOnTextBox(Self, not btnNewEnable);
end;

procedure TFrmRuang.FormCreate(Sender: TObject);
begin
  _selectedKode := -1;
  LoadData();
  SetEnabledOnBtn(true, false, false);
end;

procedure TFrmRuang.btnSimpanClick(Sender: TObject);
var
  _kapasitas: Integer;
  _check: string;
  q: string;
begin
  if (Trim(txtNama.Text) = '') or (Trim(txtKapasitas.Text) = '') then
  begin
    MessageDlg('Data Belum Lengkap!', mtWarning, [mbOK], 0);
    Exit;
  end;

  _kapasitas := StrToInt(txtKapasitas.Text);

  if _selectedKode <> -1 then
  begin
    _check := Format(
      'SELECT CAST(COUNT(*) AS CHAR(1)) '#13 +
      'FROM ruang '#13 +
      'WHERE nama="%s" AND kode <> %d', [txtNama.Text, _selectedkode]);

    DM.ExecSQL(_check, [], dm.mySQLQuery1);
    if DM.mySQLQuery1.Fields[0].AsInteger <> 0 then
    begin
      MessageDlg('Nama ini sudah ada!', mtWarning, [mbOK], 0);
      Exit;
    end;

    q := Format(
      'UPDATE ruang '#13 +
      'SET nama = "%s",'#13 +
      '    kapasitas = %d, '#13 +
      '    jenis = "%s" '#13 +
      'WHERE kode = %d',
      [txtNama.Text,
      _kapasitas,
        cmbJenis.Text,
        _selectedkode]);
    DM.ExecSQL(q, [], DM.mySQLQuery1);
  end
  else
  begin
    //new data
    _check := Format(
      'SELECT CAST(COUNT(*) AS CHAR(1)) '#13 +
      'FROM ruang '#13 +
      'WHERE nama="%s" ', [txtNama.Text]);

    DM.ExecSQL(_check, [], dm.mySQLQuery1);
    if DM.mySQLQuery1.Fields[0].AsInteger <> 0 then
    begin
      MessageDlg('Nama ini sudah ada!', mtWarning, [mbOK], 0);
      Exit;
    end;

    q := Format(
      'INSERT INTO ruang(nama,kapasitas,jenis) '#13 +
      'VALUES("%s",%d,"%s")',
      [txtNama.Text, _kapasitas, cmbJenis.Text]);
    DM.ExecSQL(q, [], DM.mySQLQuery1);

  end;

  _selectedkode := -1; //set to "-1" agar disign sebagai databaru

  ClearTextBox(Self);
  SetEnabledOnBtn(true, false, false);
  LoadData();
end;

procedure TFrmRuang.btnBaruClick(Sender: TObject);
begin
  ClearTextBox(Self);
  SetEnabledOnBtn(false, true, true);
  _selectedkode := -1;
end;

procedure TFrmRuang.btnBatalClick(Sender: TObject);
begin
  ClearTextBox(Self);
  SetEnabledOnBtn(true, false, false);
end;

procedure TFrmRuang.dtGridViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  q: string;
begin
  if Key = VK_DELETE then
  begin
    if dtGridView.DataSource.DataSet.IsEmpty then
      Exit;

    if MessageDlg('Yakin ingin menghapus data ini?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      //delete pengampu
      q := Format('DELETE FROM ruang where kode = %d',
        [StrToInt(dtGridView.DataSource.DataSet['kode'])]);
      DM.ExecSQL(q, [], dm.mySQLQuery1);
    end;

    btnBatal.Click();
    LoadData();
  end;

end;

procedure TFrmRuang.dtGridViewCellClick(Column: TColumn);
begin
  SetEnabledOnBtn(false, true, true);

  //ruang:kode,nama,kapasitas,jenis
  _selectedkode := StrToInt(dtGridView.DataSource.DataSet['kode']);
  txtNama.Text := dtGridView.DataSource.DataSet['nama'];
  txtKapasitas.Text := dtGridView.DataSource.DataSet['kapasitas'];
  cmbJenis.Text := dtGridView.DataSource.DataSet['jenis'];
end;

procedure TFrmRuang.btn3Click(Sender: TObject);
begin
  Close;
end;

procedure TFrmRuang.btnCariClick(Sender: TObject);
var
  Column:TColumn;
begin
  if dtGridView.DataSource.DataSet.Locate('nama',txtNama.Text,[DB.loCaseInsensitive]) then
  begin
    MessageDlg('Data Ditemukan', mtInformation, [mbOK], 0);
    dtGridView.OnCellClick(Column);
  end
  else
  begin
    MessageDlg('Data TIDAK Ditemukan', mtInformation, [mbOK], 0);
    ClearTextBox(Self);
  end;
end;

end.

