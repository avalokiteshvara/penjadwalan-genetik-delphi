unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, ImgList, BackgroundWorker;

type
  TMainForm = class(TForm)
    BackgroundWorker: TBackgroundWorker;
    InputPanel: TPanel;
    NumberLabel: TLabel;
    NumberEdit: TEdit;
    btnGo: TButton;
    OutputPanel: TPanel;
    ProgressPanel: TPanel;
    btnCancel: TButton;
    ProgressBar: TProgressBar;
    AnimationIcons: TImageList;
    AnimationTimer: TTimer;
    Animation: TImage;
    LatestPrimeLabel: TLabel;
    LatestPrime: TLabel;
    WarningIcon: TImage;
    WarningMessage: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnGoClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure AnimationTimerTimer(Sender: TObject);
    procedure BackgroundWorkerWorkProgress(Worker: TBackgroundWorker;
      PercentDone: Integer);
    procedure BackgroundWorkerWorkFeedback(Worker: TBackgroundWorker;
      FeedbackID, FeedbackValue: Integer);
    procedure BackgroundWorkerWorkComplete(Worker: TBackgroundWorker;
      Cancelled: Boolean);
    procedure BackgroundWorkerWork(Worker: TBackgroundWorker);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    NumbersToCheck: Integer;
    PrimesFound: Integer;
    AnimationFrameIndex: Integer;
    procedure UpdateControls(Working: Boolean);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  AnimationIcons.GetIcon(AnimationFrameIndex, Animation.Picture.Icon);
  UpdateControls(False);
end;

procedure TMainForm.UpdateControls(Working: Boolean);
begin
  NumberEdit.ReadOnly := Working;
  btnGo.Enabled := not Working;
  ProgressPanel.Visible := Working;
  AnimationTimer.Enabled := Working;
  Update;
end;

procedure TMainForm.btnGoClick(Sender: TObject);
begin
  LatestPrime.Caption := '';
  ProgressBar.Position := 0;
  NumbersToCheck := StrToInt(NumberEdit.Text);
  BackgroundWorker.Execute;
  UpdateControls(True)
end;

procedure TMainForm.btnCancelClick(Sender: TObject);
begin
  BackgroundWorker.Cancel;
end;

procedure TMainForm.AnimationTimerTimer(Sender: TObject);
begin
  AnimationFrameIndex := (AnimationFrameIndex + 1) mod AnimationIcons.Count;
  AnimationIcons.GetIcon(AnimationFrameIndex, Animation.Picture.Icon);
  Animation.Update;
end;

procedure TMainForm.BackgroundWorkerWorkProgress(Worker: TBackgroundWorker;
  PercentDone: Integer);
begin
  ProgressBar.Position := PercentDone;
end;

procedure TMainForm.BackgroundWorkerWorkFeedback(Worker: TBackgroundWorker;
  FeedbackID, FeedbackValue: Integer);
begin
  LatestPrime.Caption := IntToStr(FeedbackValue);
  LatestPrime.Update;
end;

procedure TMainForm.BackgroundWorkerWorkComplete(Worker: TBackgroundWorker;
  Cancelled: Boolean);
const
  NoPrimeFound = 'There is no prime number less than %d.';
  OnePrimeFound = 'There is only one prime number less than %d.';
  ManyPrimesFound = 'There are %d prime numbers less than %d.';
begin
  if not Cancelled then
    case PrimesFound of
      0: OutputPanel.Caption := Format(NoPrimeFound, [NumbersToCheck]);
      1: OutputPanel.Caption := Format(OnePrimeFound, [NumbersToCheck]);
    else
      OutputPanel.Caption := Format(ManyPrimesFound, [PrimesFound, NumbersToCheck]);
    end
  else
    OutputPanel.Caption := 'Operation cancelled';
  UpdateControls(False);
end;

procedure TMainForm.BackgroundWorkerWork(Worker: TBackgroundWorker);
var
  N, M: Integer;
  IsPrime: Boolean;
begin
  PrimesFound := 0;
  // Finding prime numbers using a very low tech approach
  for N := 2 to NumbersToCheck - 1 do
  begin
    // if user has requested to cancel operation
    if Worker.CancellationPending then
    begin
      // accept his/her request and exit
      Worker.AcceptCancellation;
      Exit;
    end;
    IsPrime := True;
    for M := 2 to N - 1 do
      if N mod M = 0 then
      begin
        IsPrime := False;
        Break;
      end;
    if IsPrime then
    begin
      Inc(PrimesFound);
      // inform VCL thread about the recent found prime
      Worker.ReportFeedback(PrimesFound, N);
      Sleep(50); // a bit delay, so that you can see how it works!
    end;
    // send progress to VCL thread
    Worker.ReportProgress(MulDiv(N, 100, NumbersToCheck));
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // if background worker is still running
  if BackgroundWorker.IsWorking then
  begin
    // request for cancellation
    BackgroundWorker.Cancel;
    // and wait for its termination
    BackgroundWorker.WaitFor;
  end;
end;

end.
