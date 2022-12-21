program penjadwalan;

uses
  Forms,
  uFrmMain in 'uFrmMain.pas' {FrmMain},
  uGenetik in 'uGenetik.pas',
  uDM in 'uDM.pas' {DM: TDataModule},
  uHelper in 'uHelper.pas',
  uFrmProcess in 'uFrmProcess.pas' {FrmProcess},
  uRandom in 'uRandom.pas',
  uType in 'uType.pas',
  uSaveToXL in 'uSaveToXL.pas',
  uEnc in 'uEnc.pas',
  uFrmDateTime in 'uFrmDateTime.pas' {FrmDateTime},
  uFrmDosen in 'uFrmDosen.pas' {FrmDosen},
  uFrmMataKuliah in 'uFrmMataKuliah.pas' {FrmMataKuliah},
  uFrmPengampu in 'uFrmPengampu.pas' {FrmPengampu},
  uFrmRuang in 'uFrmRuang.pas' {FrmRuang},
  uFrmWaktuTidakBersedia in 'uFrmWaktuTidakBersedia.pas' {FrmWaktuTidakBersedia};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  if not DM.OpenConnection() then
  begin
    DM.Free;
    Exit;
  end;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.CreateForm(TFrmWaktuTidakBersedia, FrmWaktuTidakBersedia);
  Application.CreateForm(TFrmPengampu, FrmPengampu);
  Application.CreateForm(TFrmDosen, FrmDosen);
  Application.CreateForm(TFrmProcess, FrmProcess);
  Application.CreateForm(TFrmDateTime, FrmDateTime);
  Application.CreateForm(TFrmMataKuliah, FrmMataKuliah);
  Application.CreateForm(TFrmRuang, FrmRuang);
  Application.Run;
end.

