unit uFrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus;

type
  TFrmMain = class(TForm)
    MainMenu1: TMainMenu;
    Aplikasi1: TMenuItem;
    Keluar1: TMenuItem;
    Data1: TMenuItem;
    Dosen1: TMenuItem;
    MataKuliah1: TMenuItem;
    Ruang1: TMenuItem;
    HariJam1: TMenuItem;
    WaktuTidakBersedia1: TMenuItem;
    Pengampu1: TMenuItem;
    ProsesPenjadwalan1: TMenuItem;
    procedure Keluar1Click(Sender: TObject);
    procedure Dosen1Click(Sender: TObject);
    procedure MataKuliah1Click(Sender: TObject);
    procedure Ruang1Click(Sender: TObject);
    procedure HariJam1Click(Sender: TObject);
    procedure WaktuTidakBersedia1Click(Sender: TObject);
    procedure Pengampu1Click(Sender: TObject);
    procedure ProsesPenjadwalan1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

uses uFrmDosen, uFrmMataKuliah, uFrmRuang, uFrmDateTime,
  uFrmWaktuTidakBersedia, uFrmPengampu, uFrmProcess,uEnc;

{$R *.dfm}

procedure ActivateForm(sFormName: string; InstanceClass: TComponentClass; var
  Reference);
begin
  if Application.FindComponent(sFormName) = nil then
    Application.CreateForm(InstanceClass, Reference);
end;

procedure TFrmMain.Keluar1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFrmMain.Dosen1Click(Sender: TObject);
begin
  ActivateForm('FrmDosen', TFrmDosen, FrmDosen);
  FrmDosen.ShowModal;
end;

procedure TFrmMain.MataKuliah1Click(Sender: TObject);
begin
  ActivateForm('FrmMataKuliah', TFrmMataKuliah, FrmMataKuliah);
  FrmMataKuliah.ShowModal;
end;

procedure TFrmMain.Ruang1Click(Sender: TObject);
begin
  ActivateForm('FrmRuang', TFrmRuang, FrmRuang);
  FrmRuang.ShowModal;
end;

procedure TFrmMain.HariJam1Click(Sender: TObject);
begin
  ActivateForm('FrmDateTime', TFrmDateTime, FrmDateTime);
  FrmDateTime.ShowModal;
end;

procedure TFrmMain.WaktuTidakBersedia1Click(Sender: TObject);
begin
  ActivateForm('FrmWaktuTidakBersedia', TFrmWaktuTidakBersedia, FrmWaktuTidakBersedia);
  FrmWaktuTidakBersedia.ShowModal;
end;

procedure TFrmMain.Pengampu1Click(Sender: TObject);
begin
  ActivateForm('FrmPengampu', TFrmPengampu, FrmPengampu);
  FrmPengampu.ShowModal;
end;

procedure TFrmMain.ProsesPenjadwalan1Click(Sender: TObject);
begin
  ActivateForm('FrmProcess', TFrmProcess, FrmProcess);
  FrmProcess.ShowModal;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var
  strInput: string;
begin
  strInput := 'Irup Exlog Mdgzdo eb nludqd.dydornlwhvkydud@jpdlo.frp';
  decrypt(strInput, 3);
  FrmMain.Caption := strInput;
end;

end.

