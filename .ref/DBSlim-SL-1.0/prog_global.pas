unit prog_global;

interface
uses Classes, SysUtils;

function Split(const fText: String; const fSep: Char; fTrim: Boolean=false; fQuotes: Boolean=false):TStringList;
function sar(sSrc, sLookFor, sReplaceWith: string ): string;
function date_max(datum:String): String;
function WriteLog(LogString: String): Integer;

implementation
uses globals;

function Split(const fText: String; const fSep: Char; fTrim: Boolean=false; fQuotes: Boolean=false):TStringList;
var vI: Integer;
    vBuffer: String;
    vOn: Boolean;
begin
  Result:=TStringList.Create;
  vBuffer:=''; 
  vOn:=true; 
  for vI:=1 to Length(fText) do 
  begin 
    if (fQuotes and(fText[vI]=fSep)and vOn)or(Not(fQuotes) and (fText[vI]=fSep)) then 
    begin 
      if fTrim then vBuffer:=Trim(vBuffer);
      if vBuffer='' then vBuffer:=fSep; // !!! sonst läuft z.B. split(',**',',') auf einen Hammer... 
      if vBuffer[1]=fSep then 
        vBuffer:=Copy(vBuffer,2,Length(vBuffer)); 
      Result.Add(vBuffer); 
      vBuffer:=''; 
    end; 
    if fQuotes then 
    begin 
      if fText[vI]='"' then 
      begin 
        vOn:=Not(vOn); 
        Continue; 
      end; 
      if (fText[vI]<>fSep)or((fText[vI]=fSep)and(vOn=false)) then 
        vBuffer:=vBuffer+fText[vI]; 
    end else 
      if fText[vI]<>fSep then 
        vBuffer:=vBuffer+fText[vI]; 
  end; 
  if vBuffer<>'' then 
  begin 
    if fTrim then vBuffer:=Trim(vBuffer); 
    Result.Add(vBuffer); 
  end; 
end;

function sar(sSrc, sLookFor, sReplaceWith: string ): string;
//sar( 'this,is,a,test', ',', ' ' ) = 'this is a test'
//sar steht für SearchAndReplace
var
  nPos,
  nLenLookFor : integer;
begin
  nPos        := Pos( sLookFor, sSrc );
  nLenLookFor := Length( sLookFor );
  while(nPos > 0)do
  begin
    Delete( sSrc, nPos, nLenLookFor );
    Insert( sReplaceWith, sSrc, nPos );
    nPos := Pos( sLookFor, sSrc );
  end;
  Result := sSrc;
end;

function date_max(datum:String): String;
begin
if (datum = '') or (datum = '---') then result:='2111-11-11' else result := datum;
end;

function WriteLog(LogString: String): Integer;
var
  f: TextFile;
begin
{$IOChecks OFF}
  AssignFile(f, ExtractFilePath(ParamStr(0))+LOGFILE);
  if FileExists(ExtractFilePath(ParamStr(0))+LOGFILE) then
    Append(f)
  else
    Rewrite(f);
  Writeln(f, LogString);
  CloseFile(f);
  result := GetLastError();
{$IOCHECKS ON}
end;

end.
