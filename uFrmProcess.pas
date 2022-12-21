unit uFrmProcess;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Grids, DBGrids, Spin, DBCtrls, uHelper, uType,
  BackgroundWorker, uGenetik, DB, mySQLDbTables, AppEvnts;

type
  TFrmProcess = class(TForm)
    grp1: TGroupBox;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    txtJumlahPopulasi: TEdit;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    numCrossover: TSpinEdit;
    numMutasi: TSpinEdit;
    dtGridView: TDBGrid;
    lv: TListView;
    lblPosition: TLabel;
    btnStop: TButton;
    btnProses: TButton;
    btn3: TButton;
    txtIterasi: TEdit;
    cmbSemester: TComboBox;
    cmbTahunAkademik: TComboBox;
    worker: TBackgroundWorker;
    ProgressBar1: TProgressBar;
    lblRata2Fitness: TLabel;
    DataSource1: TDataSource;
    mySQLQuery1: TmySQLQuery;
    ApplicationEvents1: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure btnProsesClick(Sender: TObject);
    procedure workerWork(Worker: TBackgroundWorker);
    procedure workerWorkFeedback(Worker: TBackgroundWorker; FeedbackID,
      FeedbackValue: Integer);
    procedure workerWorkProgress(Worker: TBackgroundWorker;
      PercentDone: Integer);
    procedure btnStopClick(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure workerWorkComplete(Worker: TBackgroundWorker;
      Cancelled: Boolean);
    procedure btn3Click(Sender: TObject);
  private
    { Private declarations }

    _fitnessAfterMutation: TArrayOfSingle;
    _found: Boolean;

    _kodeJumat: Integer;
    _kodeDhuhur: Integer;
    _rangeJumat: TArrayOfInteger;
    _maxIterasi: Integer;
    _jadwalKuliah: T2DArrayOfInteger;
    _populasi: Integer;
    fitnessAfterMutation: TArrayOfSingle;

    _genetik: TClassGenetik;

    procedure DisableAllParamComponent(disable: Boolean);
    procedure UpdateUI(i: Integer;
      fitnessAfterMutation: TArrayOfSingle; found: Boolean);
  public
    { Public declarations }
  end;

var
  FrmProcess: TFrmProcess;

implementation

{$R *.dfm}

uses
  uDM, uSaveToXL, uEnc;

const
  ganjil = 1;
  genap = 0;

procedure TFrmProcess.FormCreate(Sender: TObject);
var
  arry: TStringDynArray;
  i: Integer;
  strInput: string;
begin
  txtJumlahPopulasi.Text := INIReadString('genetik', 'populasi', '');
  numCrossover.Text := INIReadString('genetik', 'crossover', '');
  numMutasi.Text := INIReadString('genetik', 'mutasi', '');
  txtIterasi.Text := INIReadString('genetik', 'max_iterasi', '');

  _kodeJumat := StrToInt(INIReadString('genetik', 'kode_jumat', ''));
  _kodeDhuhur := StrToInt(INIReadString('genetik', 'kode_dhuhur', ''));
  arry := Explode('-', INIReadString('genetik', 'range_jumat', ''));

  //convert string[] to int[]
  if (Length(arry)) > 0 then
  begin
    SetLength(_rangeJumat, Length(arry));
    for i := 0 to Length(arry) - 1 do
      _rangeJumat[i] := StrToInt(arry[i]);
  end;

  strInput := 'Irup Exlog Mdgzdo eb nludqd.dydornlwhvkydud@jpdlo.frp';
  decrypt(strInput, 3);
  FrmProcess.Caption := strInput;

end;

procedure TFrmProcess.btnProsesClick(Sender: TObject);
var
  jenisSemester: Integer;
  tahunAkademik: string;

  crossOver: Single;
  mutasi: Single;

begin
  if cmbSemester.Text = 'GANJIL' then
    jenisSemester := ganjil
  else
    jenisSemester := genap;

  tahunAkademik := cmbTahunAkademik.Text;
  _populasi := StrToInt(txtJumlahPopulasi.Text);

  if _populasi mod 2 <> 0 then
  begin
    MessageDlg('Populasi harus kelipatan 2', mtError, [mbOK], 0);
    Exit;
  end;

  crossOver := StrToFloat(numCrossover.Text);
  mutasi := StrToFloat(numMutasi.Text);
  _maxIterasi := StrToInt(txtIterasi.Text);

  _genetik := TClassGenetik.Create(jenisSemester, tahunAkademik, _populasi,
    crossOver, mutasi, _kodeJumat, _rangeJumat, _kodeDhuhur);

  _genetik.AmbilData();
  _genetik.Inisialisasi;

  if not worker.IsWorking then
  begin
    worker.Execute;
    btnProses.Enabled := False;
    DisableAllParamComponent(True);
    btnStop.Enabled := True;
  end;

end;

procedure TFrmProcess.DisableAllParamComponent(disable: Boolean);
begin
  cmbSemester.Enabled := not disable;
  cmbTahunAkademik.Enabled := not disable;
  txtJumlahPopulasi.Enabled := not disable;
  numCrossover.Enabled := not disable;
  numMutasi.Enabled := not disable;
  txtIterasi.Enabled := not disable;
end;

procedure TFrmProcess.UpdateUI(i: Integer; fitnessAfterMutation:
  TArrayOfSingle; found: Boolean);
begin
  Self._fitnessAfterMutation := fitnessAfterMutation;
  Self._found := found;

  worker.ReportFeedback(i, i);
  worker.ReportProgress(MulDiv(i, 100, _maxIterasi));
end;

procedure TFrmProcess.workerWork(Worker: TBackgroundWorker);
var
  i, j: Integer;
  fitness: TArrayOfSingle;

begin
  for i := 0 to _maxIterasi - 1 do
  begin
    if worker.CancellationPending then
    begin
      worker.AcceptCancellation;
      Break;
    end;

    fitness := _genetik.HitungFitness();
    _genetik.Seleksi(fitness);
    _genetik.StartCrossOver();

    fitnessAfterMutation := _genetik.Mutasi();

    for j := 0 to Length(fitnessAfterMutation) do
    begin
      if (AlmostEquals(fitnessAfterMutation[j], 1.0, 0)) then
      begin
        _jadwalKuliah := _genetik.GetIndividu(j);
        UpdateUI(i, fitnessAfterMutation, True);
        _genetik.WriteLog2Disk();
        //btnStop.Click;
        Worker.Cancel;
        //Worker.WaitFor;
        Exit;
      end;
    end;
    UpdateUI(i, fitnessAfterMutation, False);
  end;

  //MessageDlg('Solusi TIDAK ditemukan', mtInformation, [mbOK], 0);
  _genetik.WriteLog2Disk();
end;

procedure TFrmProcess.workerWorkFeedback(Worker: TBackgroundWorker;
  FeedbackID, FeedbackValue: Integer);
var
  Rata2Fitness: Single;
  itm: TListItem;
  j, k: Integer;
begin
  lblPosition.Caption := Format('Generasi ke %d', [FeedbackValue]);
  rata2Fitness := 0;
  lv.DoubleBuffered := True;

  lv.Items.BeginUpdate;
  lv.Items.Clear;
  for j := 0 to _populasi - 1 do
  begin
    itm := lv.Items.Add;
    itm.Caption := IntToStr(j + 1);
    itm.SubItems.Add(FloatToStr(fitnessAfterMutation[j]));
    Rata2Fitness := Rata2Fitness + fitnessAfterMutation[j];
  end;
  lv.Items.EndUpdate;

  lblRata2Fitness.Caption := Format('Rata-rata Fitness: %f', [rata2Fitness /
    _populasi]);

  if Self._found then
  begin
    btnStop.Caption := 'Please Wait...';
    dm.ExecSQL('TRUNCATE TABLE jadwal_kuliah', [], dm.mySQLQuery1);

    for k := 0 to High(_jadwalKuliah) do
    begin
      DM.ExecSQL('INSERT INTO jadwal_kuliah(kode_pengampu,kode_jam,kode_hari,kode_ruang) VALUES(%d,%d,%d,%d)',
        [_jadwalKuliah[k, 0],
        _jadwalKuliah[k, 1],
          _jadwalKuliah[k, 2],
          _jadwalKuliah[k, 3]], dm.mySQLQuery1);
    end;

    mySQLQuery1.Close;
    mySQLQuery1.SQL.Text :=
      'SELECT  e.nama as Hari,' +
      '        Concat_WS(''-'',  concat(''('', g.kode),' +
      '		                       concat((SELECT kode ' +
      '								                   FROM jam ' +
      '										               WHERE kode = (SELECT jm.kode ' +
      '										                             FROM jam jm ' +
      '															                   WHERE MID(jm.range_jam,1,5) = MID(g.range_jam,1,5)) + (c.sks - 1)),'')'')) as SESI,' +
      '        Concat_WS(''-'', MID(g.range_jam,1,5),' +
      '                        (SELECT MID(range_jam,7,5) ' +
      '                         FROM jam ' +
      '                         WHERE kode = (SELECT jm.kode ' +
      '                                       FROM jam jm ' +
      '                                       WHERE MID(jm.range_jam,1,5) = MID(g.range_jam,1,5)) + (c.sks - 1))) as `Jam Kuliah`,' +
      '         c.nama as `Nama MK`,' +
      '         c.sks as SKS,' +
      '         c.semester as Smstr,' +
      '         b.kelas as Kelas,' +
      '         d.nama as Dosen,' +
      '         f.nama as Ruang ' +
      'FROM jadwal_kuliah a ' +
      'LEFT JOIN pengampu b ' +
      'ON a.kode_pengampu = b.kode ' +
      'LEFT JOIN mata_kuliah c ' +
      'ON b.kode_mk = c.kode ' +
      'LEFT JOIN dosen d ' +
      'ON b.kode_dosen = d.kode ' +
      'LEFT JOIN hari e ' +
      'ON a.kode_hari = e.kode ' +
      'LEFT JOIN ruang f ' +
      'ON a.kode_ruang = f.kode ' +
      'LEFT JOIN jam g ' +
      'ON a.kode_jam = g.kode ' +
      'order by e.nama desc,`Jam Kuliah` asc;';
    mySQLQuery1.Open;

    ExportToExcel(dtGridView.DataSource.DataSet, ExtractFilePath(Application.ExeName) + 'report.xlsx');
    MessageDlg('Solusi Ditemukan'#13 + 'Report disimpan di report.xlsx', mtInformation, [mbOK], 0);

    btnProses.Enabled := True;
    DisableAllParamComponent(False);
    btnStop.Enabled := False;
    btnStop.Caption := 'STOP';
  end;

  if (FeedbackValue = _maxIterasi - 1) then
  begin
    btnProses.Enabled := true;
    DisableAllParamComponent(false);
    btnStop.Enabled := false;
  end;

end;

procedure TFrmProcess.workerWorkProgress(Worker: TBackgroundWorker;
  PercentDone: Integer);
begin
  ProgressBar1.Position := PercentDone;
end;

procedure TFrmProcess.btnStopClick(Sender: TObject);
begin
  if worker.IsWorking then
  begin
    btnStop.Caption := 'Please Wait...';
    worker.Cancel;
    worker.WaitFor;
  end;
  btnProses.Enabled := True;
  DisableAllParamComponent(False);
  btnStop.Enabled := False;
end;

procedure TFrmProcess.ApplicationEvents1Message(var Msg: tagMSG;
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

procedure TFrmProcess.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // if background worker is still running
  if worker.IsWorking then
  begin
    // request for cancellation
    worker.Cancel;
    // and wait for its termination
    worker.WaitFor;
  end;
end;

procedure TFrmProcess.workerWorkComplete(Worker: TBackgroundWorker;
  Cancelled: Boolean);
begin
  btnStop.Caption := 'STOP';
end;

procedure TFrmProcess.btn3Click(Sender: TObject);
begin
  Close;
end;

end.

