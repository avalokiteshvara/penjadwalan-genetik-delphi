unit uFrmPengampu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DBCtrls, Grids, DBGrids, DB, mySQLDbTables, AppEvnts;

type
  TFrmPengampu = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    cmbSemester: TComboBox;
    cmbTahunAkademik: TComboBox;
    txtKelas: TEdit;
    btnBaru: TButton;
    btnBatal: TButton;
    btnSimpan: TButton;
    dtGridView: TDBGrid;
    mySQLQuery1: TmySQLQuery;
    DataSource1: TDataSource;
    cmbMataKuliah: TDBLookupComboBox;
    mySQLQueryCmdMK: TmySQLQuery;
    DataSourceCmbMK: TDataSource;
    cmbDosen: TDBLookupComboBox;
    DataSourceDosen: TDataSource;
    mySQLQueryDosen: TmySQLQuery;
    ApplicationEvents1: TApplicationEvents;
    btn3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure SetEnabledOnBtn(btnNewEnable, btnCancelEnable, btnSaveEnable: Boolean);
    procedure btnBaruClick(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure btnSimpanClick(Sender: TObject);
    procedure btnBatalClick(Sender: TObject);
    procedure dtGridViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dtGridViewCellClick(Column: TColumn);
    procedure btn3Click(Sender: TObject);
    procedure cmbSemesterChange(Sender: TObject);
    procedure cmbTahunAkademikChange(Sender: TObject);
  private
    procedure LoadData(tipe: Integer);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPengampu: TFrmPengampu;
  _selectedKode: Integer;

implementation

{$R *.dfm}

uses
  uDM, uHelper;

const
  GENAP = 0;
  GANJIL = 1;

procedure TFrmPengampu.LoadData(tipe: Integer);
var
  q, q_1, q_2: string;
begin
  ClearTextBox(self);

  mySQLQuery1.Close;
  q :=
    'SELECT a.kode as Kode,'#13 +
    '       b.kode as `Kode MK`, '#13 +
    '       b.nama as `Nama MK`,'#13 +
    '       c.kode as `Kode Dosen`,'#13 +
    '       c.nama as  `Nama Dosen`,'#13 +
    '       a.kelas as Kelas,'#13 +
    '       a.tahun_akademik as `Tahun Akademik` '#13 +
    'FROM pengampu a '#13 +
    'LEFT JOIN mata_kuliah b '#13 +
    'ON a.kode_mk = b.kode '#13 +
    'LEFT JOIN dosen c '#13 +
    'ON a.kode_dosen = c.kode '#13 +
    'WHERE b.semester%2=' + IntToStr(tipe) +
    '      AND a.tahun_akademik = ' + QuotedStr(cmbTahunAkademik.Text) + ''#13 +
    'ORDER BY b.nama,a.kelas';

  mySQLQuery1.SQL.Text := q;
  mySQLQuery1.Open;

  dtGridView.Columns[0].Visible := False;
  dtGridView.Columns[1].Visible := False;
  dtGridView.Columns[3].Visible := False;

  //load dosen
  mySQLQueryCmdMK.Close;
  q_1 :=
    'SELECT kode,nama '#13 +
    'FROM mata_kuliah '#13 +
    'WHERE semester%2= ' + IntToStr(tipe) + ''#13 +
    'ORDER BY nama';

  mySQLQueryCmdMK.SQL.Text := q_1;
  mySQLQueryCmdMK.Open;
  cmbMataKuliah.ListField := 'nama';
  cmbMataKuliah.KeyField := 'kode';

  //load mata kuliah
  mySQLQueryDosen.Close;
  q_2 := 'SELECT kode,nama FROM dosen ORDER BY nama';
  mySQLQueryDosen.SQL.Text := q_2;
  mySQLQueryDosen.Open;

  cmbDosen.ListField := 'nama';
  cmbDosen.KeyField := 'kode';

end;

procedure TFrmPengampu.SetEnabledOnBtn(btnNewEnable, btnCancelEnable, btnSaveEnable: Boolean);
begin
  btnBaru.Enabled := btnNewEnable;
  btnBatal.Enabled := btnCancelEnable;
  btnSimpan.Enabled := btnSaveEnable;
  cmbDosen.Enabled := btnSaveEnable;
  cmbMataKuliah.Enabled := btnSaveEnable;
  //cmbTahunAkademik.Enabled := btnSaveEnable;
  //cmbSemester.Enabled := btnSaveEnable;

  SetReadOnlyOnTextBox(self, not btnNewEnable);
end;

procedure TFrmPengampu.btnBaruClick(Sender: TObject);
begin
  ClearTextBox(Self);
  SetEnabledOnBtn(false, true, true);
  _selectedkode := -1;
end;

procedure TFrmPengampu.ApplicationEvents1Message(var Msg: tagMSG;
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

procedure TFrmPengampu.btnSimpanClick(Sender: TObject);
var
  kodeMK: Integer;
  kodeDosen: Integer;
  check: string;
  q: string;
begin
  if Trim(txtKelas.Text) = '' then
  begin
    MessageDlg('Data belum lengkap', mtWarning, [mbOK], 0);
    Exit;
  end;
  kodeMK := cmbMataKuliah.KeyValue;
  kodeDosen := cmbDosen.KeyValue;

  if _selectedKode <> -1 then
  begin
    //update data

    check := Format(
      'SELECT CAST(COUNT(*) AS CHAR(1)) '#13 +
      'FROM pengampu '#13 +
      'WHERE kode_mk=%d AND '#13 +
      '      kode_dosen=%d AND '#13 +
      '      kelas = "%s" AND '#13 +
      '      tahun_akademik="%s" '#13 +
      '      AND kode <> %d',
      [kodeMK, kodeDosen, txtKelas.Text, cmbTahunAkademik.Text, _selectedkode]);

    DM.ExecSQL(check, [], dm.mySQLQuery1);
    if DM.mySQLQuery1.Fields[0].AsInteger <> 0 then
    begin
      MessageDlg('Data ini sudah ada!', mtWarning, [mbOK], 0);
      Exit;
    end;

    q := Format(
      'UPDATE pengampu '#13 +
      'SET kode_mk = %d,'#13 +
      '    kode_dosen = %d,'#13 +
      '    kelas = "%s",'#13 +
      '    tahun_akademik = "%s" '#13 +
      'WHERE kode = %d ',
      [kodeMK, kodeDosen, txtKelas.Text, cmbTahunAkademik.Text, _selectedkode]);
    dm.ExecSQL(q, [], DM.mySQLQuery1);
  end
  else
  begin
    //new data
    check := Format('SELECT CAST(COUNT(*) AS CHAR(1)) '#13 +
      'FROM pengampu '#13 +
      'WHERE kode_mk=%d AND '#13 +
      '      kode_dosen=%d AND '#13 +
      '      kelas = "%s" AND '#13 +
      '      tahun_akademik="%s"',
      [kodeMK, kodeDosen, txtKelas.Text, cmbTahunAkademik.Text]);

    DM.ExecSQL(check, [], dm.mySQLQuery1);
    if DM.mySQLQuery1.Fields[0].AsInteger <> 0 then
    begin
      MessageDlg('Data ini sudah ada!', mtWarning, [mbOK], 0);
      Exit;
    end;

    q := Format(
      'INSERT INTO pengampu(kode_mk,kode_dosen,kelas,tahun_akademik) '#13 +
      'VALUES(%d,%d,"%s","%s")',
      [kodeMK, kodeDosen, txtKelas.Text, cmbTahunAkademik.Text]);

    DM.ExecSQL(q, [], DM.mySQLQuery1);
  end;

  _selectedkode := -1; //set to "-1" agar disign sebagai databaru

  ClearTextBox(Self);
  SetEnabledOnBtn(true, false, false);

  if cmbSemester.Text = 'GANJIL' then
    LoadData(GANJIL)
  else
    LoadData(GENAP);

end;

procedure TFrmPengampu.FormCreate(Sender: TObject);
begin
  if cmbSemester.Text = 'GANJIL' then
    LoadData(GANJIL)
  else
    LoadData(GENAP);
  SetEnabledOnBtn(True, False, False);
end;

procedure TFrmPengampu.btnBatalClick(Sender: TObject);
begin
  ClearTextBox(Self);
  SetEnabledOnBtn(true, false, false);
end;

procedure TFrmPengampu.dtGridViewKeyDown(Sender: TObject; var Key: Word;
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
      q := Format('DELETE FROM pengampu WHERE kode = %d',
        [StrToInt(dtGridView.DataSource.DataSet['kode'])]);
      DM.ExecSQL(q, [], dm.mySQLQuery1);
    end;

    btnBatal.Click();

    if cmbSemester.Text = 'GANJIL' then
      LoadData(GANJIL)
    else
      LoadData(GENAP);
  end;
end;

procedure TFrmPengampu.dtGridViewCellClick(Column: TColumn);
begin
  SetEnabledOnBtn(false, true, true);

  _selectedkode := StrToInt(dtGridView.DataSource.DataSet['kode']);
  cmbMataKuliah.KeyValue := dtGridView.DataSource.DataSet['Kode MK'];
  cmbDosen.KeyValue := dtGridView.DataSource.DataSet['Kode Dosen'];
  txtKelas.Text := dtGridView.DataSource.DataSet['Kelas'];
  cmbTahunAkademik.Text := dtGridView.DataSource.DataSet['Tahun Akademik'];
end;

procedure TFrmPengampu.btn3Click(Sender: TObject);
begin
  Close;
end;

procedure TFrmPengampu.cmbSemesterChange(Sender: TObject);
begin
  if cmbSemester.Text = 'GANJIL' then
    LoadData(GANJIL)
  else
    LoadData(GENAP);
end;

procedure TFrmPengampu.cmbTahunAkademikChange(Sender: TObject);
begin
  if cmbSemester.Text = 'GANJIL' then
    LoadData(GANJIL)
  else
    LoadData(GENAP);
end;

end.

