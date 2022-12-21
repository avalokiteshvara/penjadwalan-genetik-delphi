unit MyDBLookupComboBox;

interface

uses
  SysUtils, Classes, Controls, DBCtrls;

type
  TMyDBLookupComboBox = class(TDBLookupComboBox)
  private
    { Private declarations }
    FOnChange: TNotifyEvent;
  protected
    { Protected declarations }
    procedure KeyValueChanged; override;
  public
    { Public declarations }
  published
    { Published declarations }
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

procedure Register;

implementation

procedure TMyDBLookupComboBox.KeyValueChanged;
begin
  inherited;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure Register;
begin
  RegisterComponents('Samples', [TMyDBLookupComboBox]);
end;

end.

