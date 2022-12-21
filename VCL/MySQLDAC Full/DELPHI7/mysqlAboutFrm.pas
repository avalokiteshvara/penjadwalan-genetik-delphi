unit mysqlAboutFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type          
  TMySQLAboutComp = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    VersionLabel: TLabel;
    Bevel1: TBevel;
    Label5: TLabel;
    Image1: TImage;
    RegLabel: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
  private
    { Private declarations }
    FVersion : string;
    FCompName : String;
    FRegister : String;
  public
    { Public declarations }
    property Version: string   read FVersion   write FVersion;
    property CompName :string read FCompName write FCompname;
    property RegVersion :string read FRegister write FRegister;
  end;

var
  MySQLAboutComp: TMySQLAboutComp;

implementation
uses ShellAPI;

{$R *.DFM}

procedure TMySQLAboutComp.FormCreate(Sender: TObject);
begin
  FVersion := '';
  FCompName := '';
  FRegister:='';
end;

procedure TMySQLAboutComp.SpeedButton1Click(Sender: TObject);
{var
   S : String;}
begin
  {Send e-mail}
  {S := 'mailto:support.mysqldac@microolap.com?Subject=Letter from ABOUT OF DAC4MySQL '+VersionLabel.Caption+'&BODY=Dear authors! ';
  S :=  StringReplace(S, ' ', '%20', [rfReplaceAll, rfIgnoreCase]);
  ShellExecute(0,'Open',PChar(S),nil,nil,SW_SHOW);
  }
	{Go to web}
	ShellExecute(0,'Open','http://www.microolap.com/support/ticket_edit.php',nil,nil,SW_SHOW);
end;

procedure TMySQLAboutComp.SpeedButton2Click(Sender: TObject);
begin
	{Go to web}
	ShellExecute(0,'Open','http://www.microolap.com/products/dac/mysqldac.htm',nil,nil,SW_SHOW);
end;

procedure TMySQLAboutComp.SpeedButton3Click(Sender: TObject);
begin
   ShellExecute(0,'Open','http://www.microolap.com/products/dac/mysqldac.htm#order',nil,nil,SW_SHOW);
end;

end.
