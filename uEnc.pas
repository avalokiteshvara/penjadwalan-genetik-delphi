unit uEnc;

interface

procedure encrypt(var message: string; key: integer);
procedure decrypt(var message: string; key: integer);

implementation

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls;

procedure encrypt(var message: string; key: integer);
var
  i: integer;
begin
  for i := 1 to length(message) do
    case message[i] of
      'A'..'Z': message[i] := chr(ord('A') + (ord(message[i]) - ord('A') + key) mod 26);
      'a'..'z': message[i] := chr(ord('a') + (ord(message[i]) - ord('a') + key) mod 26);
    end;
end;

procedure decrypt(var message: string; key: integer);
var
  i: integer;
begin
  for i := 1 to length(message) do
    case message[i] of
      'A'..'Z': message[i] := chr(ord('A') + (ord(message[i]) - ord('A') - key + 26) mod 26);
      'a'..'z': message[i] := chr(ord('a') + (ord(message[i]) - ord('a') - key + 26) mod 26);
    end;
end;

end.

