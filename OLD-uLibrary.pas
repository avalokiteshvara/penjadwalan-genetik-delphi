unit uLibrary;

interface

uses
  Forms, Classes, Windows, StrUtils, SysUtils, INIFiles,
  ComCtrls, CommCtrl, Printers, Math;

type
  TStringDynArray = array of string;

function Explode(const Separator, S: string; Limit: Integer = 0):
  TStringDynArray;
procedure INIWriteString(Section, Ident, values: string);
function INIReadString(Section, Ident, Default: string): string;
function AlmostEquals(double1, double2, precision: Double): Boolean;

implementation

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

