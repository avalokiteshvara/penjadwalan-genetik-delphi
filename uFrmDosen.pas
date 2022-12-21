unit uFrmDosen;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, mySQLDbTables, Grids, DBGrids, StdCtrls, AppEvnts;

type
  TFrmDosen = class(TForm)
    GroupBox1: TGroupBox;
    btnBaru: TButton;
    btnBatal: TButton;
    btnSimpan: TButton;
    txtKode: TEdit;
    txtNIDN: TEdit;
    txtNama: TEdit;
    txtAlamat: TEdit;
    txtTelp: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    DBGrid1: TDBGrid;
    btnTutup: TButton;
    DataSource1: TDataSource;
    mySQLQuery1: TmySQLQuery;
    ApplicationEvents1: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure btnBaruClick(Sender: TObject);
    procedure btnSimpanClick(Sender: TObject);
    procedure DBGrid1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure btnBatalClick(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure btnTutupClick(Sender: TObject);
  private
    { Private declarations }
    _selectedKode: Integer;
    procedure LoadData;
    procedure SetEnabledOnBtn(btnNewEnable, btnCancelEnable,
      btnSaveEnable: Boolean);
  public
    { Public declarations }
  end;

var
  FrmDosen: TFrmDosen;

implementation

{$R *.dfm}

uses
  uDM, uHelper;

procedure TFrmDosen.FormCreate(Sender: TObject);
begin
  _selectedKode := -1;
  LoadData();
  SetEnabledOnBtn(True, False, False);
end;

procedure TFrmDosen.LoadData();
begin
  ClearTextBox(Self);
  DM.ExecSQL(
    'SELECT kode,'#13 +
    '       nidn as NIDN,'#13 +
    '       nama as Nama,'#13 +
    '       alamat as Alamat,'#13 +
    '       telp as Telp '#13 +
    'FROM dosen ORDER BY kode', [], mySQLQuery1);
end;

procedure TFrmDosen.SetEnabledOnBtn(btnNewEnable, btnCancelEnable, btnSaveEnable: Boolean);
begin
  btnBaru.Enabled := btnNewEnable;
  btnBatal.Enabled := btnCancelEnable;
  btnSimpan.Enabled := btnSaveEnable;
  SetReadOnlyOnTextBox(Self, not btnNewEnable);
end;

procedure TFrmDosen.btnBaruClick(Sender: TObject);
begin
  ClearTextBox(Self);
  SetEnabledOnBtn(False, True, true);
  _selectedKode := -1;
end;

procedure TFrmDosen.btnSimpanClick(Sender: TObject);
var
  chek: string;
  q, q_1: string;
begin
  if (Trim(txtKode.Text) = '') or (Trim(txtNIDN.Text) = '') or (Trim(txtNama.Text) = '') then
  begin
    MessageDlg('Data Belum Lengkap', mtWarning, [mbOK], 0);
    Exit;
  end;

  if _selectedKode <> -1 then
  begin
    //update data
    chek := Format(
      'SELECT CAST(COUNT(*) AS CHAR(1)) ' +
      'FROM dosen ' +
      'WHERE (kode=%d OR nidn="%s") AND kode <> %d',
      [StrToInt(txtKode.Text), txtNama.Text, _selectedKode]);

    DM.ExecSQL(chek, [], dm.mySQLQuery1);
    if DM.mySQLQuery1.Fields[0].AsInteger <> 0 then
    begin
      MessageDlg('Kode Atau NIDN ini sudah ada!', mtWarning, [mbOK], 0);
      Exit;
    end;

    q := Format(
      'UPDATE dosen '#13 +
      'SET kode = %d,'#13 +
      '    nidn = "%s",'#13 +
      '    nama = "%s",'#13 +
      '    alamat = "%s",'#13 +
      '    telp = "%s" '#13 +
      'WHERE kode = %d',
      [StrToInt(txtKode.Text), txtNIDN.Text,
      txtNama.Text, txtAlamat.Text,
        txtTelp.Text, _selectedkode]);
    dm.ExecSQL(q, [], dm.mySQLQuery1);

    //update waktu_tidak_bersedia
    q_1 := Format(
      'UPDATE waktu_tidak_bersedia '#13 +
      'SET kode_dosen = %d '#13 +
      'WHERE kode_dosen = %d', [StrToInt(txtKode.Text), _selectedkode]);
    dm.ExecSQL(q_1, [], dm.mySQLQuery1);
  end
  else
  begin
    //add new data
    chek := Format(
      'SELECT CAST(COUNT(*) AS CHAR(1)) ' +
      'FROM dosen ' +
      'WHERE (kode=%d OR nidn="%s")',
      [StrToInt(txtKode.Text), txtNIDN.Text]);

    DM.ExecSQL(chek, [], dm.mySQLQuery1);
    if DM.mySQLQuery1.Fields[0].AsInteger <> 0 then
    begin
      MessageDlg('Kode Atau NIDN ini sudah ada!', mtWarning, [mbOK], 0);
      Exit;
    end;

    q := Format(
      'INSERT INTO dosen(kode,nidn,nama,alamat,telp) '#13 +
      'VALUES(%d,"%s","%s","%s","%s")',
      [StrToInt(txtKode.Text), txtNIDN.Text,
      txtNama.Text, txtAlamat.Text,
        txtTelp.Text]);

    dm.ExecSQL(q, [], dm.mySQLQuery1);

  end;
  //set to "-1" agar disign sebagai databaru
  _selectedKode := -1;

  ClearTextBox(Self);
  SetEnabledOnBtn(True, False, False);
  LoadData();
end;

procedure TFrmDosen.DBGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  q: string;
begin
  if Key = VK_DELETE then
  begin
    if DBGrid1.DataSource.DataSet.IsEmpty then
      Exit;

    if MessageDlg('Yakin ingin menghapus data ini?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      //delete dosen
      q := Format('DELETE FROM dosen WHERE kode = %d', [StrToInt(DBGrid1.DataSource.DataSet['kode'])]);
      DM.ExecSQL(q, [], dm.mySQLQuery1);

      //delete pengampu
      q := Format('DELETE FROM pengampu WHERE kode_dosen = %d',
        [StrToInt(DBGrid1.DataSource.DataSet['kode'])]);
      DM.ExecSQL(q, [], dm.mySQLQuery1);
    end;
    btnBatal.Click();
    LoadData();
  end;

end;

procedure TFrmDosen.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin

end;

//How to correctly use the mouse wheel in TDBGrid
//http://delphi.about.com/cs/adptips2002/a/bltip1102_3.htm

procedure TFrmDosen.ApplicationEvents1Message(var Msg: tagMSG;
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

procedure TFrmDosen.btnBatalClick(Sender: TObject);
begin
  ClearTextBox(Self);
  SetEnabledOnBtn(true, false, false);
end;

procedure TFrmDosen.DBGrid1CellClick(Column: TColumn);
begin
  SetEnabledOnBtn(False, True, True);
  _selectedKode := StrToInt(DBGrid1.DataSource.DataSet['kode']);

  txtKode.Text := DBGrid1.DataSource.DataSet['kode'];
  txtNIDN.Text := DBGrid1.DataSource.DataSet['NIDN'];
  txtNama.Text := DBGrid1.DataSource.DataSet['nama'];
  txtAlamat.Text := DBGrid1.DataSource.DataSet['Alamat'];
  txtTelp.Text := DBGrid1.DataSource.DataSet['Telp'];
end;

procedure TFrmDosen.btnTutupClick(Sender: TObject);
begin
  Close;
end;

end.

