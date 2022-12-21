program BWDemo2;

uses
  Forms,
  Main in 'Main.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'BackgroundWorker Demo 2';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
