{$DEFINE SHOW_LOG}
unit uGenetik;

interface

uses
  uType;

type
  TClassGenetik = class
  private
    _jenisSemster: Integer;
    _tahunAkademik: string;
    _populasi: Integer;
    _crossOver: Single;
    _mutasi: Single;

    _matakuliah: TArrayOfInteger;
    _individu: T3DArrayOfInteger;
    _sks: TArrayOfInteger; //sks terikat pada tabel pengampu
    _dosen: TArrayOfInteger; //dosen terikat pada tabel pengampu

    _jam: TArrayOfInteger;
    _hari: TArrayOfInteger;
    _iDosen: TArrayOfInteger;

    //waktu keinginan dosen
    _waktuDosen: T2DArrayOfString;

    _jenisMK: TArrayOfString; //reguler or praktikum

    _ruangLaboratorium: TArrayOfInteger;
    _ruangReguler: TArrayOfInteger;

    _log: string;
    _logAmbilData: string;
    _logInisialisasi: string;

    _induk: TArrayOfInteger;

    _kodeJumat: Integer;
    _rangeJumat: TArrayOfInteger;

    _kodeDhuhur: Integer;

    function CekFitness(indv: Integer): Single;

  public
    constructor Create(jenisSemester: Integer; tahunAkademik: string; populasi:
      Integer; crossOver: Single; mutasi: Single; kodeJumat: Integer;
      rangeJumat: TArrayOfInteger; kodeDhuhur: Integer);

    function HitungFitness(): TArrayOfSingle;
    procedure Seleksi(fitness: TArrayOfSingle);
    procedure StartCrossOver;
    function Mutasi: TArrayOfSingle;
    function GetIndividu(indv: Integer): T2DArrayOfInteger;
    procedure AmbilData;
    procedure WriteLog2Disk;
    procedure Inisialisasi;

  end;

implementation

uses
  uDM, SysUtils, uHelper, Dialogs, uRandom, Math;

const
  Praktikum = 'PRAKTIKUM';
  Teori = 'TEORI';
  Laboratorium = 'LABORATORIUM';

constructor TClassGenetik.Create(jenisSemester: Integer; tahunAkademik: string;
  populasi: Integer; crossOver: Single; mutasi: Single; kodeJumat: Integer;
  rangeJumat: TArrayOfInteger; kodeDhuhur: Integer);
begin
  Self._jenisSemster := jenisSemester;
  Self._tahunAkademik := tahunAkademik;
  Self._populasi := populasi;
  Self._crossOver := crossOver;
  Self._mutasi := mutasi;
  Self._kodeJumat := kodeJumat;
  Self._rangeJumat := rangeJumat;
  Self._kodeDhuhur := kodeDhuhur;
end;

procedure TClassGenetik.AmbilData();
var
  rCountA, rCountB, rCountC, rCountD, rCountE, rCountF: Integer;
  i: Integer;
begin
{$IFDEF SHOW_LOG}
  ShortDateFormat := 'dd-mm-yyyy';
  _logAmbilData := _logAmbilData +
    Format('===========================["%s"] => Ambil Data....',
    [DateToStr(NOW)]);
{$ENDIF}

  //Fill  Array of mata kuliah and SKS Variables

  DM.mySQLQuery1.Close;
  DM.mySQLQuery1.SQL.Text :=
    'SELECT a.kode,b.sks,a.kode_dosen,b.jenis ' +
    'FROM pengampu a ' +
    'LEFT JOIN mata_kuliah b ON a.kode_mk = b.kode ' +
    'WHERE b.semester%2 =' + IntToStr(Self._jenisSemster) +
    '      AND a.tahun_akademik = ' + QuotedStr(Self._tahunAkademik);
  DM.mySQLQuery1.Open;

  rCountA := dm.mySQLQuery1.RecordCount;
  SetLength(_matakuliah, rCountA);
  SetLength(_sks, rCountA);
  SetLength(_dosen, rCountA);
  SetLength(_jenisMK, rCountA);

  i := 0;
  while not dm.mySQLQuery1.Eof do
  begin
    _matakuliah[i] := dm.mySQLQuery1.Fields[0].AsInteger;
    _sks[i] := DM.mySQLQuery1.Fields[1].AsInteger;
    _dosen[i] := DM.mySQLQuery1.Fields[2].AsInteger;
    _jenisMK[i] := DM.mySQLQuery1.Fields[3].AsString;

    dm.mySQLQuery1.Next;
    Inc(i);
  end;

  //Fill Array of Jam Variables
  DM.ExecSQL('SELECT kode FROM jam', [], dm.mySQLQuery1);
  rCountB := dm.mySQLQuery1.RecordCount;
  SetLength(_jam, rCountB);
  i := 0;
  while not dm.mySQLQuery1.Eof do
  begin
    _jam[i] := DM.mySQLQuery1.Fields[0].AsInteger;

    dm.mySQLQuery1.Next;
    Inc(i);
  end;

  //Fill Array of Hari Variables
  DM.ExecSQL('SELECT kode FROM hari WHERE aktif ="%s"', ['True'],
    dm.mySQLQuery1);
  rCountC := dm.mySQLQuery1.RecordCount;
  SetLength(_hari, rCountC);
  i := 0;
  while not dm.mySQLQuery1.Eof do
  begin
    _hari[i] := DM.mySQLQuery1.Fields[0].AsInteger;

    dm.mySQLQuery1.Next;
    Inc(i);
  end;

  //Fill Array of Data Ruang Reguler
  DM.ExecSQL('SELECT kode FROM ruang WHERE jenis ="%s"', [Teori],
    dm.mySQLQuery1);
  rCountD := dm.mySQLQuery1.RecordCount;
  SetLength(_ruangReguler, rCountD);
  i := 0;
  while not dm.mySQLQuery1.Eof do
  begin
    _ruangReguler[i] := DM.mySQLQuery1.Fields[0].AsInteger;

    dm.mySQLQuery1.Next;
    Inc(i);
  end;

  //Fill Array of Data Ruang Lab
  DM.ExecSQL('SELECT kode FROM ruang WHERE jenis ="%s"', [Laboratorium],
    dm.mySQLQuery1);
  rCountE := dm.mySQLQuery1.RecordCount;
  SetLength(_ruangLaboratorium, rCountE);
  i := 0;
  while not dm.mySQLQuery1.Eof do
  begin
    _ruangLaboratorium[i] := DM.mySQLQuery1.Fields[0].AsInteger;

    dm.mySQLQuery1.Next;
    Inc(i);
  end;

  //fill waktu dosen tidak bersedia
  DM.mySQLQuery1.Close;
  DM.mySQLQuery1.SQL.Text :=
    'SELECT kode_dosen,CONCAT_WS('':'',kode_hari,kode_jam) FROM waktu_tidak_bersedia';
  DM.mySQLQuery1.Open;

  rCountF := dm.mySQLQuery1.RecordCount;

  SetLength(_waktuDosen, rCountF, 2);
  SetLength(_iDosen, rCountF);

  i := 0;
  while not dm.mySQLQuery1.Eof do
  begin
    //    _ruangLaboratorium[i] := DM.mySQLQuery1.Fields[0].AsInteger;
    _iDosen[i] := DM.mySQLQuery1.Fields[0].AsInteger;
    _waktuDosen[i, 0] := DM.mySQLQuery1.Fields[0].AsString;
    _waktuDosen[i, 1] := DM.mySQLQuery1.Fields[1].AsString;

    dm.mySQLQuery1.Next;
    Inc(i);
  end;

{$IFDEF SHOW_LOG}
  _logAmbilData := _logAmbilData +
    Format('Jumlah MataKuliah:%d'#13 +
    'Jumlah Jam:%d'#13 + 'Jumlah Hari:%d'#13 +
    'Jumlah Ruang:%d'#13, [rCountA, rCountB, rCountC, rCountD + rCountE]);
{$ENDIF}

end;

procedure TClassGenetik.WriteLog2Disk();
var
  F: TextFile;
begin
  AssignFile(F, 'log.txt');
  Rewrite(F);
  Writeln(F, _logAmbilData);
  Writeln(F, _logInisialisasi);
  Writeln(F, _log);
  CloseFile(F);
end;

procedure TClassGenetik.Inisialisasi();
var
  i, j: Integer;
begin
  try
    Randomize;
    SetLength(_individu, _populasi, Length(_matakuliah), 4);
{$IFDEF SHOW_LOG}
    ShortDateFormat := 'dd-mm-yyyy';
    _logInisialisasi := _logInisialisasi +
      Format('===========================["%s"] => Ambil Nilai Parameter....'#13,
      [DateToStr(NOW)]);

    _logInisialisasi := _logInisialisasi + Format('Populasi:%d'#13 +
      'CrossOver:%f'#13 + 'Mutasi:%f'#13, [_populasi, _crossOver, _mutasi]);
{$ENDIF}

    for i := 0 to _populasi - 1 do
    begin
{$IFDEF SHOW_LOG}
      ShortDateFormat := 'dd-mm-yyyy';
      _logInisialisasi := _logInisialisasi +
        Format(#13#13#13'["%s"] Individu ke - %d', [DateToStr(NOW), (i + 1)]);
{$ENDIF}
      //k := Length(_matakuliah);
      //ShowMessage(IntToStr(High(_mataKuliah)));
      for j := 0 to High(_matakuliah) do
      begin
        //Perulangan untuk pembangkitan jadwal
        _individu[i, j, 0] := j; // Penentuan matakuliah dan kelas

        if _sks[j] = 1 then // Penentuan jam secara acak ketika 1 sks
          _individu[i, j, 1] := Random(Length(_jam));

        if _sks[j] = 2 then // Penentuan jam secara acak ketika 1 sks
          _individu[i, j, 1] := Random(Length(_jam) - 1);

        if _sks[j] = 3 then // Penentuan jam secara acak ketika 1 sks
          _individu[i, j, 1] := Random(Length(_jam) - 2);

        if _sks[j] = 4 then // Penentuan jam secara acak ketika 1 sks
          _individu[i, j, 1] := Random(Length(_jam) - 3);

        _individu[i, j, 2] := Random(Length(_hari));
        // Penentuan hari secara acak

        if _jenisMK[j] = Teori then
          _individu[i, j, 3] := _ruangReguler[Random(Length(_ruangReguler))]
        else
          _individu[i, j, 3] :=
            _ruangReguler[Random(Length(_ruangLaboratorium))];

{$IFDEF SHOW_LOG}
        _logInisialisasi := _logInisialisasi +
          Format(#13'Kromosom %d = %d,%d,%d,%d',
          [j + 1, _matakuliah[_individu[i, j, 0]], _jam[_individu[i, j, 1]],
          _hari[_individu[i, j, 2]], _individu[i, j, 3]]);
{$ENDIF}

      end;

    end;
  except
    on E: Exception do
    begin
      MessageDlg('procedure TClassGenetik.Inisialisasi();', mtError, [mbOK], 0);
    end;
  end;
end;

function TClassGenetik.CekFitness(indv: Integer): Single;
var
  penalty1, penalty2, penalty3, penalty4, penalty5: Single;
  i, j: Integer;
  hariJam: TStringDynArray;
begin
  penalty1 := 0;
  penalty2 := 0;
  penalty3 := 0;
  penalty4 := 0;
  penalty5 := 0;

  //  try

  for i := 0 to High(_matakuliah) do
  begin
    for j := 0 to High(_matakuliah) do
      //1.bentrok ruang dan waktu dan 3.bentrok dosen
    begin
      //ketika pemasaran matakuliah sama, maka langsung ke perulangan berikutnya
      if i = j then
        Continue;

      //Ketika jam,hari dan ruangnya sama, maka penalty + satu
      if (_individu[indv, i, 1] = _individu[indv, j, 1]) and
        (_individu[indv, i, 2] = _individu[indv, j, 2]) and
        (_individu[indv, i, 3] = _individu[indv, j, 3]) then
      begin
{$IFDEF SHOW_LOG}
        _log := _log + Format(#13'HardConstraint[1#A] => Individu ke- %d',
          [indv + 1]);

        _log := _log +
          Format(#13'Kromosom %d [%d,%d,%d,%d] == Kromosom %d [%d,%d,%d,%d]',
          [(i + 1), _mataKuliah[_individu[indv, i, 0]],
          _jam[_individu[indv, i, 1]], _hari[_individu[indv, i, 2]],
            _individu[indv, i, 3], (j + 1), _mataKuliah[_individu[indv, j,
            0]],
            _jam[_individu[indv, j, 1]], _hari[_individu[indv, j, 2]],
            _individu[indv, j, 3]]);
{$ENDIF}
        penalty1 := penalty1 + 1;
      end;

      //Ketika sks lebih dari 1,
      //hari dan ruang sama, dan
      //jam kedua sama dengan jam pertama matakuliah yang lain, maka penalty + 1

      if (_sks[i] >= 2) then
      begin
        if ((_individu[indv, i, 1] + 1 = _individu[indv, j, 1]) and
          (_individu[indv, i, 2] = _individu[indv, j, 2]) and
          (_individu[indv, i, 3] = _individu[indv, j, 3])) then
        begin
{$IFDEF SHOW_LOG}
          _log := _log + Format(#13'HardConstraint[1#B] => Individu ke- %d',
            [indv + 1]);

          _log := _log +
            Format(#13'Kromosom %d [%d,%d,%d,%d][SKS=%d] == Kromosom %d [%d,%d,%d,%d][SKS=%d]', [
            (i + 1), _mataKuliah[_individu[indv, i, 0]],
              _jam[_individu[indv, i, 1]], _hari[_individu[indv, i, 2]],
              _individu[indv, i, 3], _sks[1], (j + 1),
              _mataKuliah[_individu[indv, j, 0]], _jam[_individu[indv, j, 1]],
              _hari[_individu[indv, j, 2]], _individu[indv, j, 3], _sks[j]
              ]);
{$ENDIF}
          penalty1 := penalty1 + 1;
        end;
      end;

      //Ketika sks lebih dari 2,
      //hari dan ruang sama dan
      //jam ketiga sama dengan jam pertama matakuliah yang lain, maka penalty + 1
      if (_sks[i] >= 3) then
      begin
        if ((_individu[indv, i, 1] + 2 = _individu[indv, j, 1]) and
          (_individu[indv, i, 2] = _individu[indv, j, 2]) and
          (_individu[indv, i, 3] = _individu[indv, j, 3])) then
        begin
{$IFDEF SHOW_LOG}
          _log := _log + Format(#13'HardConstraint[1#B] => Individu ke- %d',
            [indv + 1]);

          _log := _log +
            Format(#13'Kromosom %d [%d,%d,%d,%d][SKS=%d] == Kromosom %d [%d,%d,%d,%d][SKS=%d]', [
            (i + 1), _mataKuliah[_individu[indv, i, 0]],
              _jam[_individu[indv, i, 1]], _hari[_individu[indv, i, 2]],
              _individu[indv, i, 3], _sks[1], (j + 1),
              _mataKuliah[_individu[indv, j, 0]], _jam[_individu[indv, j, 1]],
              _hari[_individu[indv, j, 2]], _individu[indv, j, 3], _sks[j]
              ]);
{$ENDIF}
          penalty1 := penalty1 + 1;
        end;
      end;

      //Ketika sks lebih dari 3,
      //hari dan ruang sama dan
      //jam ketiga sama dengan jam pertama matakuliah yang lain, maka penalty + 1
      if (_sks[i] >= 4) then
      begin
        if ((_individu[indv, i, 1] + 3 = _individu[indv, j, 1]) and
          (_individu[indv, i, 2] = _individu[indv, j, 2]) and
          (_individu[indv, i, 3] = _individu[indv, j, 3])) then
        begin
{$IFDEF SHOW_LOG}
          _log := _log + Format(#13'HardConstraint[1#B] => Individu ke- %d',
            [indv + 1]);

          _log := _log +
            Format(#13'Kromosom %d [%d,%d,%d,%d][SKS=%d] == Kromosom %d [%d,%d,%d,%d][SKS=%d]', [
            (i + 1), _mataKuliah[_individu[indv, i, 0]],
              _jam[_individu[indv, i, 1]], _hari[_individu[indv, i, 2]],
              _individu[indv, i, 3], _sks[1], (j + 1),
              _mataKuliah[_individu[indv, j, 0]], _jam[_individu[indv, j, 1]],
              _hari[_individu[indv, j, 2]], _individu[indv, j, 3], _sks[j]
              ]);
{$ENDIF}
          penalty1 := penalty1 + 1;
        end;
      end;

      //______________________BENTROK DOSEN
      if (//ketika jam sama
        (_individu[indv, i, 1] = _individu[indv, j, 1]) and
        //dan hari sama
        (_individu[indv, i, 2] = _individu[indv, j, 2]) and
        //dan dosennya sama
        (_dosen[i] = _dosen[j])) then
      begin
        //maka...
{$IFDEF SHOW_LOG}
        _log := _log + Format(#13'HardConstraint[3#A] => Individu ke- %d',
          [indv + 1]);

        _log := _log +
          Format('Kromosom %d [%d,%d,%d,%d][SKS = %d][DOSEN = %d] == Kromosom %d [%d,%d,%d,%d][][SKS = %d][DOSEN=%d]',
          [
          (i + 1), _mataKuliah[_individu[indv, i, 0]],
            _jam[_individu[indv, i, 1]], _hari[_individu[indv, i, 2]],
            _individu[indv, i, 3], _sks[1], _dosen[i], (j + 1),
            _mataKuliah[_individu[indv, j, 0]], _jam[_individu[indv, j, 1]],
            _hari[_individu[indv, j, 2]], _individu[indv, j, 3], _sks[j],
            _dosen[j]]);
{$ENDIF}
        penalty3 := penalty3 + 1;
      end;

      if (//jika lebih dari 1 SKS
        _sks[i] >= 2) then
      begin
        if (//jam ke-2 == dengan jam ke-1 mk yang lain
          ((_individu[indv, i, 1] + 1) = (_individu[indv, j, 1])) and
          //dan hari sama
          ((_individu[indv, i, 2]) = (_individu[indv, j, 2])) and
          //dan dosen sama
          (_dosen[i] = _dosen[j])) then
        begin
          //maka...
{$IFDEF SHOW_LOG}
          _log := _log + Format(#13'HardConstraint[3#B] => Individu ke- %d',
            [indv + 1]);

          _log := _log +
            Format('Kromosom %d [%d,%d,%d,%d][SKS = %d][DOSEN = %d] == Kromosom %d [%d,%d,%d,%d][][SKS = %d][DOSEN=%d]',
            [
            (i + 1), _mataKuliah[_individu[indv, i, 0]],
              _jam[_individu[indv, i, 1]], _hari[_individu[indv, i, 2]],
              _individu[indv, i, 3], _sks[1], _dosen[i], (j + 1),
              _mataKuliah[_individu[indv, j, 0]], _jam[_individu[indv, j, 1]],
              _hari[_individu[indv, j, 2]], _individu[indv, j, 3], _sks[j],
              _dosen[j]]);
{$ENDIF}
          penalty3 := penalty3 + 1;
        end;
      end;

      if (//jika lebih dari 2 SKS
        _sks[i] >= 3) then
      begin
        if (//jam ke-2 == dengan jam ke-1 mk yang lain
          ((_individu[indv, i, 1] + 2) = (_individu[indv, j, 1])) and
          //dan hari sama
          ((_individu[indv, i, 2]) = (_individu[indv, j, 2])) and
          //dan dosen sama
          (_dosen[i] = _dosen[j])) then
        begin
          //maka...
{$IFDEF SHOW_LOG}
          _log := _log + Format(#13'HardConstraint[3#B] => Individu ke- %d',
            [indv + 1]);

          _log := _log +
            Format('Kromosom %d [%d,%d,%d,%d][SKS = %d][DOSEN = %d] == Kromosom %d [%d,%d,%d,%d][][SKS = %d][DOSEN=%d]',
            [
            (i + 1), _mataKuliah[_individu[indv, i, 0]],
              _jam[_individu[indv, i, 1]], _hari[_individu[indv, i, 2]],
              _individu[indv, i, 3], _sks[1], _dosen[i], (j + 1),
              _mataKuliah[_individu[indv, j, 0]], _jam[_individu[indv, j, 1]],
              _hari[_individu[indv, j, 2]], _individu[indv, j, 3], _sks[j],
              _dosen[j]]);
{$ENDIF}
          penalty3 := penalty3 + 1;
        end;
      end;

      if (//jika lebih dari 3 SKS
        _sks[i] >= 4) then
      begin
        if (//jam ke-2 == dengan jam ke-1 mk yang lain
          ((_individu[indv, i, 1] + 3) = (_individu[indv, j, 1])) and
          //dan hari sama
          ((_individu[indv, i, 2]) = (_individu[indv, j, 2])) and
          //dan dosen sama
          (_dosen[i] = _dosen[j])) then
        begin
          //maka...
{$IFDEF SHOW_LOG}
          _log := _log + Format(#13'HardConstraint[3#B] => Individu ke- %d',
            [indv + 1]);

          _log := _log +
            Format('Kromosom %d [%d,%d,%d,%d][SKS = %d][DOSEN = %d] == Kromosom %d [%d,%d,%d,%d][][SKS = %d][DOSEN=%d]',
            [(i + 1), _mataKuliah[_individu[indv, i, 0]],
            _jam[_individu[indv, i, 1]], _hari[_individu[indv, i, 2]],
              _individu[indv, i, 3], _sks[1], _dosen[i], (j + 1),
              _mataKuliah[_individu[indv, j, 0]], _jam[_individu[indv, j, 1]],
              _hari[_individu[indv, j, 2]], _individu[indv, j, 3], _sks[j],
              _dosen[j]]);
{$ENDIF}
          penalty3 := penalty3 + 1;
        end;
      end;
    end; //end 1.bentrok ruang dan waktu dan 3.bentrok dosen

    //_______________Bentrok sholat Jumat
    if (_individu[indv, i, 2] + 1 = (_kodeJumat)) then //2.bentrok sholat jumat
    begin
      if (_sks[i] = (1)) then
      begin
        if ((_individu[indv, i, 1] = (_rangeJumat[0] - 1)) or
          (_individu[indv, i, 1] = (_rangeJumat[1] - 1)) or
          (_individu[indv, i, 1] = (_rangeJumat[2] - 1))) then
        begin
{$IFDEF SHOW_LOG}
          _log := _log +
            Format(#13'HardConstraint[2#SKS = 1] => Individu ke-%d ',
            [indv + 1]);

          _log := _log + Format('Kromosom %d [%d,%d,%d,%d]',
            [(i + 1),
            _mataKuliah[_individu[indv, i, 0]],
              _jam[_individu[indv, i, 1]],
              _hari[_individu[indv, i, 2]],
              _individu[indv, i, 3]]);
{$ENDIF}
          penalty2 := penalty2 + 1;
        end;
      end;

      if (_sks[i] = (2)) then
      begin
        if (
          (_individu[indv, i, 1] = (_rangeJumat[0] - 2)) or
          (_individu[indv, i, 1] = (_rangeJumat[0] - 1)) or
          (_individu[indv, i, 1] = (_rangeJumat[1] - 1)) or
          (_individu[indv, i, 1] = (_rangeJumat[2] - 1))
          ) then
        begin
{$IFDEF SHOW_LOG}
          _log := _log +
            Format(#13'HardConstraint[2#SKS = 2] => Individu ke-%d ',
            [indv + 1]);

          _log := _log + Format('Kromosom %d [%d,%d,%d,%d]',
            [(i + 1),
            _mataKuliah[_individu[indv, i, 0]],
              _jam[_individu[indv, i, 1]],
              _hari[_individu[indv, i, 2]],
              _individu[indv, i, 3]]);
{$ENDIF}
          penalty2 := penalty2 + 1;
        end;
      end;

      if (_sks[i] = (3)) then
      begin
        if (
          (_individu[indv, i, 1] = (_rangeJumat[0] - 3)) or
          (_individu[indv, i, 1] = (_rangeJumat[0] - 2)) or
          (_individu[indv, i, 1] = (_rangeJumat[0] - 1)) or
          (_individu[indv, i, 1] = (_rangeJumat[1] - 1)) or
          (_individu[indv, i, 1] = (_rangeJumat[2] - 1))
          ) then
        begin
{$IFDEF SHOW_LOG}
          _log := _log +
            Format(#13'HardConstraint[2#SKS = 3] => Individu ke-%d ',
            [indv + 1]);

          _log := _log + Format('Kromosom %d [%d,%d,%d,%d]',
            [(i + 1),
            _mataKuliah[_individu[indv, i, 0]],
              _jam[_individu[indv, i, 1]],
              _hari[_individu[indv, i, 2]],
              _individu[indv, i, 3]]);
{$ENDIF}
          penalty2 := penalty2 + 1;
        end;
      end;

      if (_sks[i] = (4)) then
      begin
        if (
          (_individu[indv, i, 1] = (_rangeJumat[0] - 4)) or
          (_individu[indv, i, 1] = (_rangeJumat[0] - 3)) or
          (_individu[indv, i, 1] = (_rangeJumat[0] - 2)) or
          (_individu[indv, i, 1] = (_rangeJumat[0] - 1)) or
          (_individu[indv, i, 1] = (_rangeJumat[1] - 1)) or
          (_individu[indv, i, 1] = (_rangeJumat[2] - 1))
          ) then
        begin
{$IFDEF SHOW_LOG}
          _log := _log +
            Format(#13'HardConstraint[2#SKS = 4] => Individu ke-%d ',
            [indv + 1]);

          _log := _log + Format('Kromosom %d [%d,%d,%d,%d]',
            [(i + 1),
            _mataKuliah[_individu[indv, i, 0]],
              _jam[_individu[indv, i, 1]],
              _hari[_individu[indv, i, 2]],
              _individu[indv, i, 3]]);
{$ENDIF}
          penalty2 := penalty2 + 1;
        end;
      end;

    end; // end Bentrok sholat Jumat

    //_______________Bentrok dengan Waktu Keinginan Dosen
    for j := 0 to High(_iDosen) do
    begin
      if (_dosen[i] = _iDosen[j]) then
      begin
        //ShowMessage(_waktuDosen[j, i]);
        //strTest := _waktuDosen[0, 5];
        hariJam := Explode(':', _waktuDosen[j, 1]);
        if (
          (IntToStr(_jam[_individu[indv, i, 1]]) = hariJam[1]) and
          (IntToStr(_hari[_individu[indv, i, 2]]) = hariJam[0])
          ) then
        begin
{$IFDEF SHOW_LOG}
          _log := _log +
            Format(#13'HardConstraint[4] => Individu ke %d Kromosom %d [%d,%d,%d,%d][Dosen = %d]',
            [(indv + 1),
            (i + 1),
              _mataKuliah[_individu[indv, i, 0]],
              _jam[_individu[indv, i, 1]],
              _hari[_individu[indv, i, 2]],
              _individu[indv, i, 3], _iDosen[j]]);
{$ENDIF}
          penalty4 := penalty4 + 1;
        end;
      end;
    end;

    //_______________Bentrok waktu dhuhur

    if (_individu[indv, i, 1] = (_kodeDhuhur - 1)) then
    begin
{$IFDEF SHOW_LOG}
      _log := _log +
        Format(#13'HardConstraint[5] => Individu ke %d Kromosom %d [%d,%d,%d,%d][Dosen = %d]',
        [(indv + 1),
        (i + 1),
          _mataKuliah[_individu[indv, i, 0]],
          _jam[_individu[indv, i, 1]],
          _hari[_individu[indv, i, 2]],
          _individu[indv, i, 3],
          _dosen[i]]);
{$ENDIF}
      penalty5 := penalty5 + 1;
    end;
  end;

{$IFDEF SHOW_LOG}
  _log := _log + Format(#13'Penalty Individu ke %d => %f ',
    [(indv + 1), (penalty1 + penalty2 + penalty3 + penalty4 + penalty5)]);
{$ENDIF}
  Result := 1 / (1 + (penalty1 + penalty2 + penalty3 + penalty4 + penalty5));
  
end;

function TClassGenetik.HitungFitness(): TArrayOfSingle;
var
  fitness: TArrayOfSingle;
  sort: array of string;
  indv: Integer;
  i: Integer;
  swapped: Boolean;
  strI, strJ: TStringDynArray;
  fitI, fitJ: Single;
  sTmp: string;
begin
  try
    //hard constraint
    //1.bentrok ruang dan waktu
    //2.bentrok sholat jumat
    //3.bentrok dosen
    //4.bentrok keinginan waktu dosen
    //5.bentrok waktu dhuhur
    //=>6.praktikum harus pada ruang lab {telah ditetapkan dari awal perandoman
    //    bahwa jika praktikum harus ada pada LAB dan mata kuliah reguler harus
    //    pada kelas reguler

    _log := EmptyStr;
    SetLength(fitness, _populasi);
{$IFDEF SHOW_LOG}
    _log := _log + #13#13'=========================== HITUNG FITNESS';
    _log := _log +
      #13'Rule:'#13 +
      'Hard Constraint:'#13 +
      '[1] => Bentrok ruang dan Waktu'#13 +
      '[1#A] => jam,hari dan ruangnya sama'#13 +
      '[1#B] => sks lebih dari 1 + hari dan ruang sama + jam kedua sama dengan jam pertama matakuliah yang lain'#13 +
      '[1#C] => sks lebih dari 2 + hari dan ruang sama + jam ketiga sama dengan jam pertama matakuliah yang lain'#13 +
      '[1#D] => sks lebih dari 3 + hari dan ruang sama + jam keempat sama dengan jam pertama matakuliah yang lain'#13 +
      '[2] => Bentrok sholat jumat'#13 +
      '[2#SKS = 1] => sks = 1'#13 +
      '[2#SKS = 2] => sks = 2'#13 +
      '[2#SKS = 3] => sks = 3'#13 +
      '[2#SKS = 4] => sks = 4'#13 +
      '[3] => Bentrok Dosen'#13 +
      '[3#SKS = 1] => sks = 1'#13 +
      '[3#SKS = 2] => sks = 2'#13 +
      '[3#SKS = 3] => sks = 3'#13 +
      '[3#SKS = 4] => sks = 4'#13 +
      '[4] => bentrok keinginan waktu dosen'#13;
{$ENDIF}

    for indv := 0 to _populasi - 1 do
    begin
      //Cek Fitness
      fitness[indv] := CekFitness(indv);
{$IFDEF SHOW_LOG}
      _log := _log + Format(#13'Fitness Individu ke %d => %f '#13,
        [(indv + 1), fitness[indv]]);
{$ENDIF}
    end;

    //~~~~~buble sort~~~~~~
    SetLength(sort, _populasi);
    //fill the data

{$IFDEF SHOW_LOG}
    _log := _log +
      #13'Review Penalty dan Fitness: (Best Fitness => Worst Fitness)';
{$ENDIF}

    for i := 0 to _populasi - 1 do
    begin
      sort[i] := Format(#13'Individu %d => Fitness %f ',
        [(i + 1), fitness[i]]);
    end;

    try
      swapped := True;
      while (swapped) do
      begin
        swapped := false;
        for i := 0 to (_populasi - 2) do
        begin
          strI := Explode('.', sort[i]);
          fitI := StrToFloat(Format('0.%s', [strI[1]]));

          strJ := Explode('.', sort[i + 1]);
          fitJ := StrToFloat(Format('0.%s', [strI[1]]));

          if (fitI < fitJ) then
          begin
            sTmp := sort[i];
            sort[i] := sort[i + 1];
            sort[i + 1] := sTmp;
            swapped := true;
          end;
        end;
      end;
    except
      MessageDlg('Kemungkinan data tidak ada untuk Tahun Akademik dan Semester yang terpilih!', mtError, [mbYes], 0);
    end;

{$IFDEF SHOW_LOG}
    for i := 0 to _populasi - 1 do
    begin
      _log := _log + sort[i];
    end;
{$ENDIF}
    Result := fitness;
  except
    on E: Exception do
    begin
      MessageDlg('function TClassGenetik.HitungFitness(): TArrayOfSingle;',
        mtError, [mbOK], 0);
    end;
  end;
end;

procedure TClassGenetik.Seleksi(fitness: TArrayOfSingle);
var
  jumlah: Integer;
  rank: TArrayOfInteger;
  i, j: Integer;
  target: Integer;
  cek: Integer;
begin
  try
    jumlah := 0;
    SetLength(rank, _populasi);
    SetLength(_induk, _populasi);
{$IFDEF SHOW_LOG}
    _log := _log + #13#13;
{$ENDIF}

    for i := 0 to _populasi - 1 do
    begin
      //proses ranking berdasarkan nilai fitness
      rank[i] := 1;
      for j := 0 to _populasi - 1 do
      begin
        //ketika nilai fitness jadwal sekarang lebih dari nilai fitness jadwal yang lain,
         //ranking + 1;
         //if (i == j) continue;

        if (fitness[i] > fitness[j]) then
        begin
          rank[i] := rank[i] + 1;
        end;

      end;
{$IFDEF SHOW_LOG}
      _log := _log + Format('Ranking individu %d = %d '#13, [(i + 1), rank[i]]);
{$ENDIF}
      jumlah := jumlah + rank[i];
    end;

{$IFDEF SHOW_LOG}
    _log := _log + Format('[jumlah:%d] ', [jumlah]);
{$ENDIF}

    Randomize;
{$IFDEF SHOW_LOG}
    _log := _log + #13#13'Proses Seleksi: '#13 + 'Induk terpilih: ';
{$ENDIF}

    for i := 0 to High(_induk) do
    begin
      //proses seleksi berdasarkan ranking yang telah dibuat
      //int nexRandom = random.Next(1, jumlah);
      //random = new Random(nexRandom);
      target := Random(jumlah);
      cek := 0;
      for j := 0 to High(rank) do
      begin
        cek := cek + rank[j];
        if (cek >= target) then
        begin
          _induk[i] := j;
{$IFDEF SHOW_LOG}
          _log := _log + Format('Individu %d', [(j + 1)]);
{$ENDIF}
          Break;
        end;
      end;
    end;
  except
    on E: Exception do
    begin
      MessageDlg('procedure TClassGenetik.Seleksi(fitness: TArrayOfSingle);',
        mtError, [mbOK], 0);
    end;
  end;
end;

procedure TClassGenetik.StartCrossOver();
var
  individuBaru: T3DArrayOfInteger;
  i, j, k: Integer;
  a, b: Integer;
  cr: Double;
  //_random: TRandom;
begin
  try
{$IFDEF SHOW_LOG}
    _log := _log +
      Format(#13#13'===========================PROSES CROSSOVER / PINDAH SILANG (CrossOver values = %f)', [_crossOver]);
{$ENDIF}
    SetLength(individuBaru, _populasi, Length(_matakuliah), 4);
    Randomize; //line:796

    i := 0;
    while i < (_populasi - 1) do //perulangan untuk jadwal yang terpilih
    begin
      b := 0;
      //_random := TRandom.Create(RandomRange(1, 1000));
      cr := Random; //_random.NextDouble();

      if cr < _crossOver then
      begin
        //ketika nilai random kurang dari nilai probabilitas pertukaran
        //maka jadwal mengalami pertukaran
        a := Random(Length(_matakuliah) - 1);
        while (b <= a) do
        begin
          b := Random(Length(_matakuliah));
        end;

        //penentuan jadwal baru dari awal sampai titik pertama
        for j := 0 to (a - 1) do
        begin
          for k := 0 to 3 do
          begin
            individuBaru[i, j, k] := _individu[_induk[i], j, k];
            individuBaru[i + 1, j, k] := _individu[_induk[i + 1], j, k];
          end;
        end;

        //Penentuan jadwal baru dai titik pertama sampai titik kedua
        for j := a to (b - 1) do
        begin
          for k := 0 to 3 do
          begin
            individuBaru[i, j, k] := _individu[_induk[i + 1], j, k];
            individuBaru[i + 1, j, k] := _individu[_induk[i], j, k];
          end;
        end;

        //penentuan jadwal baru dari titik kedua sampai akhir
        for j := b to High(_matakuliah) do
        begin
          for k := 0 to 3 do
          begin
            individuBaru[i, j, k] := _individu[_induk[i + 1], j, k];
            individuBaru[i + 1, j, k] := _individu[_induk[i], j, k];
          end;
        end;
{$IFDEF SHOW_LOG}
        _log := _log +
          Format(#13#13'Nilai Random = %f, maka CrossOver terjadi antara induk %d dengan induk %d pada titik %d dan titik %d',
          [cr,
          (i + 1),
            (i + 2),
            (a + 1),
            (b + 1)]);
{$ENDIF}
      end
      else
      begin
        //Ketika nilai random lebih dari nilai probabilitas pertukaran, maka jadwal baru sama dengan jadwal terpilih
        for j := 0 to High(_matakuliah) do
        begin
          for k := 0 to 3 do
          begin
            individuBaru[i, j, k] := _individu[_induk[i], j, k];
            individuBaru[i + 1, j, k] := _individu[_induk[i + 1], j, k];
          end;
        end;
{$IFDEF SHOW_LOG}
        _log := _log +
          Format(#13#13'Nilai random = %f, maka CrossOver TIDAK TERJADI antara induk %d dengan induk %d',
          [cr, (i + 1), (i + 2)]);
{$ENDIF}
      end;
      Inc(i, 2);
    end;

    //tampilkan individu baru
{$IFDEF SHOW_LOG}
    for i := 0 to _populasi - 1 do
    begin
      _log := _log +
        Format(#13#13'["%s"] => Individu Baru Ke-%d #MK,JAM,HARI,RUANG',
        [DateToStr(Now), (i + 1)]);

      for j := 0 to High(_matakuliah) do
      begin
        _log := _log + #13'Kromosom  ' + IntToStr(j + 1) + ' = ' +
          IntToStr(_mataKuliah[individuBaru[i, j, 0]]) + ',' +
          IntToStr(_jam[individuBaru[i, j, 1]]) + ',' +
          IntToStr(_hari[individuBaru[i, j, 2]]) + ',' +
          IntToStr(individuBaru[i, j, 3]);
      end;
    end;
{$ENDIF}
    SetLength(_individu, _populasi, Length(_matakuliah), 4);
    // _individu := Copy(individuBaru, 0, MaxInt);
    _individu := Copy(individuBaru, Low(individuBaru), Length(individuBaru));
  except
    on E: Exception do
    begin
      MessageDlg('procedure TClassGenetik.StartCrossOver();', mtError, [mbOK],
        0);
    end;
  end;
end;

function TClassGenetik.Mutasi(): TArrayOfSingle;
var
  fitness: TArrayOfSingle;
  i: Integer;
  r: Double;
  //_random: TRandom;
  msg: string;
  krom: Integer;
begin
  try
    SetLength(fitness, _populasi);

{$IFDEF SHOW_LOG}
    _log := _log +
      #13#13'===========================PROSES MUTASI / PENGGANTIAN KOMPONEN PENJADWALAN SECARA ACAK:';
{$ENDIF}

    Randomize;

    //proses perandoman atau penggantian komponen untuk tiap jadwal baru
    for i := 0 to (_populasi - 1) do
    begin
      //_random := TRandom.Create(RandomRange(1, 1000));
      r := Random; //.NextDouble();
{$IFDEF SHOW_LOG}
      msg := 'TIDAK terjadi mutasi';
{$ENDIF}
      //Ketika nilai random kurang dari nilai probalitas Mutasi,
      //maka terjadi penggantian komponen
      if (r < _mutasi) then
      begin
        //Penentuan pada matakuliah dan kelas yang mana yang akan dirandomkan atau diganti
        krom := Random(Length(_matakuliah));

        case _sks[krom] of
          1: _individu[i, krom, 1] := Random(Length(_jam));
          2: _individu[i, krom, 1] := Random(Length(_jam) - 1);
          3: _individu[i, krom, 1] := Random(Length(_jam) - 2);
          4: _individu[i, krom, 1] := Random(Length(_jam) - 3);
        end;

        //Proses penggantian hari
        _individu[i, krom, 2] := random(Length(_hari));

        if (_jenisMK[krom] = teori) then
          _individu[i, krom, 3] := _ruangReguler[Random(Length(_ruangReguler))]
        else
          _individu[i, krom, 3] :=
            _ruangLaboratorium[Random(Length(_ruangLaboratorium))];
{$IFDEF SHOW_LOG}
        msg := Format('terjadi mutasi, pada kromosom ke %d', [(krom + 1)]);
{$ENDIF}
      end;
      fitness[i] := CekFitness(i);
{$IFDEF SHOW_LOG}
      _log := _log +
        Format('Individu %d: Nilai Random = %f, maka "%s" (Fitness = %f)'#13#13,
        [(i + 1), r, msg, fitness[i]]);
{$ENDIF}
    end;
    Result := fitness;
  except
    on E: Exception do
    begin
      MessageDlg('function TClassGenetik.Mutasi(): TArrayOfSingle;', mtError,
        [mbOK], 0);
    end;
  end;
end;

function TClassGenetik.GetIndividu(indv: Integer): T2DArrayOfInteger;
var
  individuSolusi: T2DArrayOfInteger;
  j: Integer;
begin
  SetLength(individuSolusi, Length(_matakuliah), 4);
  for j := 0 to High(_matakuliah) do
  begin
    individuSolusi[j, 0] := _mataKuliah[_individu[indv, j, 0]];
    individuSolusi[j, 1] := _jam[_individu[indv, j, 1]];
    individuSolusi[j, 2] := _hari[_individu[indv, j, 2]];
    individuSolusi[j, 3] := _individu[indv, j, 3]
  end;
  Result := individuSolusi;
end;

end.

