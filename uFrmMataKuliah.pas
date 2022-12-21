unit uFrmMataKuliah;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, mySQLDbTables, Grids, DBGrids, AppEvnts;

type
  TFrmMataKuliah = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    txtKode: TEdit;
    txtNama: TEdit;
    txtSKS: TEdit;
    txtSemester: TEdit;
    cmbKategori: TComboBox;
    btnBaru: TButton;
    btnBatal: TButton;
    btnSimpan: TButton;
    dtGridView: TDBGrid;
    btnTutup: TButton;
    mySQLQuery1: TmySQLQuery;
    DataSource1: TDataSource;
    ApplicationEvents1: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure btnBaruClick(Sender: TObject);
    procedure btnSimpanClick(Sender: TObject);
    procedure btnBatalClick(Sender: TObject);
    procedure dtGridViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dtGridViewCellClick(Column: TColumn);
    procedure btnTutupClick(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
  private
    procedure LoadData;
    procedure SetEnabledOnBtn(btnNewEnable, btnCancelEnable,
      btnSaveEnable: Boolean);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMataKuliah: TFrmMataKuliah;
  _selectedkode: Integer;
implementation

{$R *.dfm}

uses
  uDM, uHelper;

procedure TFrmMataKuliah.LoadData();
var
  q: string;
begin
  ClearTextBox(Self);
  q :=
    'SELECT kode as id,'#13 +
    '       kode_mk as Kode,'#13 +
    '       nama as Nama,'#13 +
    '       sks as SKS,'#13 +
    '       semester as Semester,'#13 +
    '       aktif as Aktif,'#13 +
    '       jenis as Jenis '#13 +
    'FROM mata_kuliah ORDER BY nama';
  DM.ExecSQL(q, [], mySQLQuery1);
  dtGridView.Columns[0].Visible := false;
  dtGridView.Columns[5].Visible := false;
end;

procedure TFrmMataKuliah.SetEnabledOnBtn(btnNewEnable, btnCancelEnable, btnSaveEnable: Boolean);
begin
  btnBaru.Enabled := btnNewEnable;
  btnBatal.Enabled := btnCancelEnable;
  btnSimpan.Enabled := btnSaveEnable;
  cmbKategori.Enabled := btnSaveEnable;
  //  cbAktif.Enabled := btnSaveEnable;
  SetReadOnlyOnTextBox(self, not btnNewEnable);
end;

procedure TFrmMataKuliah.FormCreate(Sender: TObject);
begin
  LoadData();
  SetEnabledOnBtn(true, false, false);
  _selectedkode := -1;
end;

procedure TFrmMataKuliah.btnBaruClick(Sender: TObject);
begin
  ClearTextBox(Self);
  SetEnabledOnBtn(false, true, true);
  _selectedkode := -1;
end;

procedure TFrmMataKuliah.btnSimpanClick(Sender: TObject);
var
  _sks: Integer;
  _semester: Integer;
  check: string;
  q: string;
begin
  if (Trim(txtKode.Text) = '') or (Trim(txtNama.Text) = '') or
    (Trim(txtSKS.Text) = '') or (Trim(txtSemester.Text) = '') then
  begin
    MessageDlg('Data Belum Lengkap', mtWarning, [mbOK], 0);
    Exit;
  end;

  _sks := StrToInt(txtSKS.Text);
  _semester := StrToInt(txtSemester.Text);

  if _selectedkode <> -1 then
  begin
    //update data
    check := Format(
      'SELECT CAST(COUNT(*) AS CHAR(1)) '#13 +
      'FROM mata_kuliah '#13 +
      'WHERE (kode_mk="%s" OR nama="%s") AND kode <> %d',
      [txtKode.Text, txtNama.Text, _selectedkode]);

    DM.ExecSQL(check, [], dm.mySQLQuery1);
    if DM.mySQLQuery1.Fields[0].AsInteger <> 0 then
    begin
      MessageDlg('Kode Atau Nama ini sudah ada!', mtWarning, [mbOK], 0);
      Exit;
    end;

    q := Format(
      'UPDATE mata_kuliah '#13 +
      'set kode_mk = "%s", '#13 +
      '    nama = "%s", '#13 +
      '    sks = %d, '#13 +
      '    semester = %d,'#13 +
      '    aktif ="%s",'#13 +
      '    jenis = "%s" '#13 +
      'where kode = %d',
      [txtKode.Text, txtNama.Text, _sks, _semester, 'True', cmbKategori.Text, _selectedkode]);
    DM.ExecSQL(q, [], DM.mySQLQuery1);
  end
  else
  begin
    //new data
    check := Format(
      'SELECT CAST(COUNT(*) AS CHAR(1)) '#13 +
      'FROM mata_kuliah '#13 +
      'WHERE (kode_mk="%s" OR nama="%s")',
      [txtKode.Text, txtNama.Text]);

    DM.ExecSQL(check, [], dm.mySQLQuery1);
    if DM.mySQLQuery1.Fields[0].AsInteger <> 0 then
    begin
      MessageDlg('Kode Atau Nama ini sudah ada!', mtWarning, [mbOK], 0);
      Exit;
    end;

    q := Format(
      'INSERT INTO mata_kuliah(kode_mk,nama,sks,semester,aktif,jenis) '#13 +
      'VALUES("%s","%s",%d,%d,"%s","%s")',
      [txtKode.Text, txtNama.Text, _sks, _semester, 'True', cmbKategori.Text]);

    DM.ExecSQL(q, [], DM.mySQLQuery1);
  end;

  _selectedkode := -1; //set to "-1" agar disign sebagai databaru

  ClearTextBox(Self);
  SetEnabledOnBtn(true, false, false);
  LoadData();  
end;

procedure TFrmMataKuliah.btnBatalClick(Sender: TObject);
begin
  ClearTextBox(Self);
  SetEnabledOnBtn(true, false, false);
end;

procedure TFrmMataKuliah.dtGridViewKeyDown(Sender: TObject; var Key: Word;
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
      //delete mata_kuliah
      q := Format('DELETE FROM mata_kuliah where kode = %d',
        [StrToInt(dtGridView.DataSource.DataSet['id'])]);
      DM.ExecSQL(q, [], dm.mySQLQuery1);

      //delete pengampu
      q := Format('DELETE FROM pengampu where kode_mk = %d',
        [StrToInt(dtGridView.DataSource.DataSet['kode'])]);
      DM.ExecSQL(q, [], dm.mySQLQuery1);
    end;
    btnBatal.Click();
    LoadData();
  end;

end;

procedure TFrmMataKuliah.dtGridViewCellClick(Column: TColumn);
begin
  SetEnabledOnBtn(false, true, true);
  _selectedkode := StrToInt(dtGridView.DataSource.DataSet['id']);
  txtKode.Text := dtGridView.DataSource.DataSet['Kode'];
  txtNama.Text := dtGridView.DataSource.DataSet['Nama'];
  txtSKS.Text := dtGridView.DataSource.DataSet['SKS'];
  txtSemester.Text := dtGridView.DataSource.DataSet['Semester'];
  cmbKategori.Text := dtGridView.DataSource.DataSet['Jenis']
end;

procedure TFrmMataKuliah.btnTutupClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmMataKuliah.ApplicationEvents1Message(var Msg: tagMSG;
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

end.

