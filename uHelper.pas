unit uHelper;

interface

uses
  Forms, Classes, Windows, StrUtils, SysUtils, INIFiles,
  ComCtrls, CommCtrl, Printers, Math, StdCtrls, Graphics, DB;

type
  TStringDynArray = array of string;

function Explode(const Separator, S: string; Limit: Integer = 0):
  TStringDynArray;
procedure INIWriteString(Section, Ident, values: string);
function INIReadString(Section, Ident, Default: string): string;
function AlmostEquals(double1, double2, precision: Double): Boolean;
procedure ClearTextBox(Sender: TForm);
procedure SetReadOnlyOnTextBox(Sender: TForm; readOnly: Boolean);
function SearchDBGrid(oDataSet: TDataSet; iCol: Integer; strSearch: string): Boolean;

implementation

function SearchDBGrid(oDataSet: TDataSet; iCol: Integer; strSearch: string): Boolean;
var
  found: Boolean;
begin
  found := False;

  oDataSet.Open;
  oDataSet.First;
  while not oDataSet.Eof do
  begin
    if (LowerCase(oDataSet.Fields[iCol].AsString) = LowerCase(strSearch)) then
    begin
      found := True;
      Break;
    end;
    oDataSet.Next;
  end;
  Result := found;
end;

procedure SetReadOnlyOnTextBox(Sender: TForm; readOnly: Boolean);
var
  i: integer;
begin
  for i := 0 to Sender.ComponentCount - 1 do
  begin
    if (Sender.Components[i].InheritsFrom(TEdit)) then
    begin
      (Sender.Components[i] as TEdit).Enabled := readOnly;
      if readOnly then
        (Sender.Components[i] as TEdit).Color := clWindow
      else
        (Sender.Components[i] as TEdit).Color := clBtnFace;
    end;
  end; // for i
end;

procedure ClearTextBox(Sender: TForm);
var
  i: integer;
begin
  for i := 0 to Sender.ComponentCount - 1 do
  begin
    if (Sender.Components[i].InheritsFrom(TEdit)) then
    begin
      (Sender.Components[i] as TEdit).Clear;
    end;
  end; // for i
end;

function Explode(const Separator, S: string; Limit: Integer = 0):
  TStringDynArray;
var
  SepLen: Integer;
  F, P: PChar;
  ALen, Index: Integer;
begin
  SetLength(Result, 0);
  if (S = '') or (Limit < 0) then
    Exit;
  if Separator = '' then
  begin
    SetLength(Result, 1);
    Result[0] := S;
    Exit;
  end;
  SepLen := Length(Separator);
  ALen := Limit;
  SetLength(Result, ALen);

  Index := 0;
  P := PChar(S);
  while P^ <> #0 do
  begin
    F := P;
    P := StrPos(P, PChar(Separator));
    if (P = nil) or ((Limit > 0) and (Index = Limit - 1)) then
      P := StrEnd(F);
    if Index >= ALen then
    begin
      Inc(ALen, 5);
      SetLength(Result, ALen);
    end;
    SetString(Result[Index], F, P - F);
    Inc(Index);
    if P^ <> #0 then
      Inc(P, SepLen);
  end;
  if Index < ALen then
    SetLength(Result, Index);
end;

procedure INIWriteString(Section, Ident, values: string);
var
  myINI: TIniFile;
begin
  myINI := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'config.ini');
  try
    myINI.WriteString(Section, Ident, values);
  finally
    myINI.Free;
  end;
end;

function INIReadString(Section, Ident, Default: string): string;
var
  myINI: TIniFile;
begin
  myINI := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'config.ini');
  try
    Result := myINI.ReadString(Section, Ident, Default);
  finally
    myINI.Free
  end;
end;

function AlmostEquals(double1, double2, precision: Double): Boolean;
begin
  Result := (Abs(double1 - double2) <= precision);

end;

end.

