program dbslim;

uses
  Forms,
  demo in 'demo.pas' {main},
  globals in 'globals.pas',
  prog_global in 'prog_global.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tmain, main);
  Application.Run;
end.
