unit uFrmWaktuTidakBersedia;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, mySQLDbTables, DBCtrls, Grids, DBGrids, ComCtrls,
  MyDBLookupComboBox;

type
  TFrmWaktuTidakBersedia = class(TForm)
    GroupBox1: TGroupBox;
    mySQLQueryDosen: TmySQLQuery;
    DataSourceDosen: TDataSource;
    Label1: TLabel;
    btnSimpan: TButton;
    lv: TListView;
    mySQLQueryHari: TmySQLQuery;
    mySQLQueryJam: TmySQLQuery;
    mySQLQueryTidakBersedia: TmySQLQuery;
    cmbDosen: TMyDBLookupComboBox;
    btn3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure cmbDosenChange(Sender: TObject);
    procedure btnSimpanClick(Sender: TObject);
    procedure btn3Click(Sender: TObject);
  private
    procedure LoadDtDosen;
    procedure LoadWaktuTidakBersedia(kode_dosen: Integer);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmWaktuTidakBersedia: TFrmWaktuTidakBersedia;

implementation

{$R *.dfm}

uses
  uDM;

procedure TFrmWaktuTidakBersedia.LoadDtDosen();
var
  q: string;
begin
  //load mata kuliah
  mySQLQueryDosen.Close;
  q := 'SELECT kode,nama FROM dosen ORDER BY nama';
  mySQLQueryDosen.SQL.Text := q;
  mySQLQueryDosen.Open;

  cmbDosen.ListField := 'nama';
  cmbDosen.KeyField := 'kode';
end;

procedure TFrmWaktuTidakBersedia.LoadWaktuTidakBersedia(kode_dosen: Integer);
var
  qHari, qJam, qTidakBersedia: string;
  //i, j, k: Integer;
  itm: TListItem;
begin

  qHari :=
    'SELECT nama,kode '#13 +
    'FROM hari '#13 +
    'WHERE aktif = True'#13 +
    'ORDER BY kode';
  DM.ExecSQL(qHari, [], mySQLQueryHari);

  qJam := 'SELECT range_jam,kode FROM jam ORDER BY kode';
  DM.ExecSQL(qJam, [], mySQLQueryJam);

  qTidakBersedia :=
    'SELECT kode_hari,kode_jam '#13 +
    'FROM waktu_tidak_bersedia '#13 +
    'WHERE kode_dosen = ' + IntToStr(kode_dosen);
  DM.ExecSQL(qTidakBersedia, [], mySQLQueryTidakBersedia);

  lv.Items.BeginUpdate;
  lv.Items.Clear;

  mySQLQueryHari.First;
  while not mySQLQueryHari.Eof do
  begin
    mySQLQueryJam.First;
    while not mySQLQueryJam.Eof do
    begin
      itm := lv.Items.Add;

      mySQLQueryTidakBersedia.First;
      while not mySQLQueryTidakBersedia.Eof do
      begin
        if (mySQLQueryHari.Fields[1].AsInteger = mySQLQueryTidakBersedia.Fields[0].AsInteger) and
          (mySQLQueryJam.Fields[1].AsInteger = mySQLQueryTidakBersedia.Fields[1].AsInteger) then
          itm.Checked := True;

        mySQLQueryTidakBersedia.Next;
      end;

      itm.SubItems.Add(mySQLQueryHari.Fields[0].AsString);
      itm.SubItems.Add(mySQLQueryJam.Fields[0].AsString);
      itm.SubItems.Add(IntToStr(mySQLQueryHari.Fields[1].AsInteger));
      itm.SubItems.Add(IntToStr(mySQLQueryJam.Fields[1].AsInteger));
      mySQLQueryJam.Next;
    end;

    mySQLQueryHari.Next;
  end;
  lv.Items.EndUpdate;
end;

procedure TFrmWaktuTidakBersedia.FormCreate(Sender: TObject);
begin
  LoadDtDosen;
end;

procedure TFrmWaktuTidakBersedia.cmbDosenChange(Sender: TObject);
begin
  if cmbDosen.KeyValue <> null then
    LoadWaktuTidakBersedia(cmbDosen.KeyValue);
end;

procedure TFrmWaktuTidakBersedia.btnSimpanClick(Sender: TObject);
var
  kodeDosen: Integer;
  i: Integer;
  item: TListItem;
  kodeHari, KodeJam: Integer;
  q: string;
begin
  kodeDosen := 0;
  if cmbDosen.KeyValue <> null then
    kodeDosen := StrToInt(cmbDosen.KeyValue);

  DM.ExecSQL('DELETE FROM waktu_tidak_bersedia WHERE kode_dosen =' + IntToStr(kodeDosen), [],
    DM.mySQLQuery1);

  for i := 0 to lv.Items.Count - 1 do
  begin
    if lv.Items[i].Checked = True then
    begin
      item := lv.Items.Item[i];
      //ShowMessage(item.SubItems[0]);
      kodeHari := StrToInt(item.SubItems[2]);
      KodeJam := StrToInt(item.SubItems[3]);

      q := Format(
        'INSERT INTO waktu_tidak_bersedia(kode_dosen,kode_hari, kode_jam) '#13 +
        'VALUES (%d,%d,%d)', [kodeDosen, kodeHari, KodeJam]);
      DM.ExecSQL(q, [], DM.mySQLQuery1);
    end;
  end;
  MessageDlg('Data telah tersimpan', mtInformation, [mbOK], 0);
end;

procedure TFrmWaktuTidakBersedia.btn3Click(Sender: TObject);
begin
  Close;
end;

end.

