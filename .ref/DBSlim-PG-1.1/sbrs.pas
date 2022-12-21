unit Sbrs;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms,
Controls, Buttons, StdCtrls, ExtCtrls, Dialogs, Gauges;

const

{these characters should be defined in sbrs.pas because they're
general-purpose ASCII.}

Stx {: char} = chr(2);
Etx {: char} = chr(3);
Eot {: char} = chr(4);
Ack {: char} = chr(6);
Lf  {: char} = chr(10);
Cr  {: char} = chr(13);
{Ff  = chr(12); }
Del {: char} = #127;


crlf : string = CR+LF {chr(13)+chr(10)};

LNEND : string = CR+LF;

kilobyte = 1024;

  BIT0 =  (1) ;
  BIT1 =  (2) ;
  BIT2 =  (4) ;
  BIT3 =  (8) ;
  BIT4 =  (16) ;
  BIT5 =  (32) ;
  BIT6 =  (64) ;
  BIT7 =  (128) ;
  BIT8 =  (256) ;
  BIT9 =  (512) ;
  BIT10 =  (1024) ;
  BIT11 =  (2048) ;
  BIT12 =  (4096) ;
  BIT13 =  (8192) ;
  BIT14 =  (16384) ;
  BIT15 =  (32768) ;
  BIT16 =  (65536) ;
  BIT17 =  (131072) ;
  BIT18 =  (262144) ;
  BIT19 =  (524288) ;
  BIT20 =  (1048576) ;
  BIT21 =  (2097152) ;
  BIT22 =  (4194304) ;
  BIT23 =  (8388608) ;
  BIT24 =  (16777216) ;
  BIT25 =  (33554432) ;
  BIT26 =  (67108864) ;
  BIT27 =  (134217728) ;
  BIT28 =  (268435456) ;
  BIT29 =  (536870912) ;
  BIT30 =  (1073741824) ;


type
TICKTIME = record
  waitfor,oldcount: longint;
end;

const

{a value to assign to a ticktime variable so that when
delayed is called with it, it will return as time-up.
see at least lcxcomm.}
dzero : TICKTIME = (
  waitfor:0;
  oldcount:0;
);



procedure quickbeep;
function contexthelp(number:integer):boolean;
function helpoid(sHELPJUNK:pchar):boolean;
procedure hglass;
procedure dcursor;
function findhelp(form: Tform):boolean;
procedure fixdirectory;
{ procedure finalsbrs; }
procedure deslash(var what:string);
function formatint(value:longint; size:integer):string;
function formathex(value:longint; size:integer):string;
function formatstring(s:string; size:integer; flushright:boolean=false):string;
function isdigit(c:char):boolean;
function isspace(c:char):boolean;
function ischar(c:char):boolean;
function isprint(c:char):boolean;
function hextoint(s:string):longint;
procedure intrange(low, high:integer; var what:integer);
procedure wordrange(low, high:word; var what:word);
procedure longrange(low,high:longint; var what:longint);
function hprintf(handle:integer; const TheFormat:string; const Args: array of
const):integer;
function hgets(handle:integer; var dst:string):boolean;
procedure tokenate(const s:string);
function tokenhget(handle:integer):boolean;
function boolstring(what:boolean):string;
function jgoStrToInt(const S: string): Longint;
function jgoi(const S: string; const start, count:integer):longint;
function spaces(count:integer):string;
procedure flip(var what:boolean);
function delineend(s:string):string;
function unline(s:string):string;
function extractname(const s:string):string;
function despace(const s:string):string;
function ipos(substr:string; index:integer; s:string):integer;
procedure removecharacter(var s:string; where:integer);
procedure addcharacter(var s:string; where:integer; what:char);

{ if count<>0, then initialize hung count; if 0, then return true if
counted down.}
function hung(count:integer):boolean;

function pixelbits:integer;
function lowest(one, two:integer):integer;
procedure switchint(var one, two: integer);
{procedure switchcase(var key:char);}
procedure makeupper(var key:char);
{ returns true if user answers yes. }
function usuref(
const TheFormat: string;
const Args:array of const):boolean;
function usure(s:string):boolean;

procedure errorf(
const TheFormat: string;
const Args:array of const); overload;
procedure errorf(
const TheFormat: string); overload;

function es(s:string; i:integer):char;
{used to be emptyspace}
procedure infof(
const TheFormat: string;
const Args:array of const);
function commaoid(s:string):string;
procedure colonoid(var s:string; var x:longint);
function ualphan(s:string):string;
procedure editselect(edit:tedit);
procedure replacechar(old,new:char; var dst:string);
function htell(handle:integer):longint;
function hrewind(handle:integer):boolean; {returns good if it worked.}
function firstselected(listbox:Tlistbox):integer;
function isdefault(s:string):boolean;
function hexoid(s:string):longint;
function lastchar(s:string):string;
{returns value of first number in a string, i.e. "unit12" returns 12.}
function firstnumber(s:string):integer;
function uncontrol(var s:string):boolean;
function delayed(var t:TICKTIME; howlong: longint):boolean;
procedure mswait(ms: longint);
function getCDslash:string;
procedure cwdize(var s:string);

function mutoid(s:string):boolean;
{returns true if another mutex with string exists.}

procedure nfree(var what:Tobject);
procedure fontsize(s:string; f:Tfont; var width, height:integer);
function unquote(s:string):string;
function quotate(s:string):string;
procedure notimpl;
function quoteword(s:string):string;

function safe_format(
const TheFormat: string;
const Args:array of const):string;

{var
printerheld:boolean; }

const
TOKENCOUNT = 30;
TokenSize = 20;

var
tokenarray : array[1..TOKENCOUNT] of string;
tokens : integer;
tokenstr:string;    { the original string. }

implementation

uses SysUtils {vkeys, } ;


{--------------------------------------------------------------}
procedure quickbeep;
begin
  messagebeep($FFFF);
end;

function contexthelp(number:integer):boolean;
begin
  hglass;
  result :=
  Application.helpcommand(
  HELP_CONTEXT,
  number
  );
  dcursor;
end;

function helpoid(sHELPJUNK:pchar):boolean;
begin
  hglass;
  result :=
  Application.helpcommand(
  HELP_PARTIALKEY,
  longint(sHELPJUNK)
  );
  dcursor;
end;

{-----------------------------------------------------------}
procedure hglass;
begin
  screen.cursor := crHourGlass;
end;

procedure dcursor;
begin
  screen.cursor := crDefault;
end;

{-----------------------------------------------------------}

function itsinside(where:Tpoint; acontrol:TWinControl):
boolean;
begin
  result :=
  (where.x > acontrol.left) and
  (where.x < (acontrol.left+acontrol.width) ) and

  (where.y > acontrol.top) and
  (where.y < (acontrol.top + acontrol.height) );
end;

function TwinControlAtPos(where: Tpoint;
form:Tcomponent):TWinControl;
var
index : longint;
begin

  for index := 0 to
  form.componentcount-1 do begin
    if (form.components[index] is TWinControl)
    then begin
      result :=
      form.components[index] as TWinControl;
      if itsinside(where,result) then
      exit;
    end;
  end;

  result := nil;
end;

{Return a help context for the control, or if
no such, 0, or if acontrol is nil, 0.

Delphi documentation lies about presence of
helpcontext so we will cut 'n' try.
//so I found a chart on page 114,
*Developing Custom Delphi Components*, Konopka,
Coriolis, 1996 which seems to be helpful. I.e., a
TWinControl seems the most primitive thing with a
helpcontext. }

function TwinHelpContext(acontrol:TWinControl):
longint;
begin
  if (acontrol <> nil) then begin
    result := acontrol.helpcontext;
    exit;
  end;
  result := 0;
end;

function findhelp(form: Tform):boolean;
var
CurPos: Tpoint;
acontext : longint;

{column, row:integer; }

begin
  result := false;

  GetCursorPos(CurPos);
  CurPos := form.ScreenToClient(CurPos);

  acontext :=
  TwinHelpContext(
  TwinControlAtPos(CurPos,form as Tcomponent)
  );

  if (acontext <> 0) then begin
    result := true;
    contexthelp(acontext);
{    contexthelp(51); }
  end;

end;


{---------------------
HERE'S HOW IT'S USED:

procedure Twjnetform.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key=vk_F1) then begin
    if (findhelp(wjnetform)) then begin

    [the form's key preview property must be true for this
    to work; but I thought I tried that six or seven times
    and it still didn't work. What *doesn't* seem to make
    a difference:
      form's showhint; it's false. IN WHRP it's true so.
      Application.HintPause := 1500;  // no diff
      Application.OnShowHint := DoShowHint; //nope.
    ]

      Key := 0;
    end;
  end;

end;

----------------------}

{-----------------------------------------}
procedure deslash(var what:string);
var i:integer;
begin
  i := length(what);
  if
//  what[i]='\'
  es(what,i)='\'
  then begin
{   what[0] := char(i - 1);  { they don't have a function! }
    setlength(what,i-1);
  end;
end;

procedure slash(var what:string);
begin
  deslash(what);
  what := what + '\';
end;

procedure eslash(var what:string);
begin
  if length(what)>0 then
  slash(what);
end;




procedure fixdirectory;
const
done : boolean = false;
var
directory:string;
begin
  if done then
  exit;

  done := true;
{ ExpandFileName ParamStr }
  directory := ExtractFilePath(ParamStr(0));
  deslash(directory);
  { I think win3.1 aka dos6 whatever doesn't like
  the trailing slash? }
  try
    chdir(directory)
  except
    messagedlg(
    'Unscheduled error: chdir(' +
    directory +
    ') failed; sorry.',
    mtError,[mbOK],0);
  end;
  { try and use current directory. }
end;

{------------------------------------------------------------------------}

function formatint(value:longint; size:integer):string;
var i:integer;
begin
  result := format('%*d',[size,value]);
  for i := 1 to length(result) do begin
    if result[i]=' ' then
    result[i] := '0';
  end;
end;

function formathex(value:longint; size:integer):string;
var i:integer;
begin
  result := format('%*x',[size,value]);
  for i := 1 to length(result) do begin
    if result[i]=' ' then
    result[i] := '0';
  end;
end;

{---------------------------------------------------------------}
function isdigit(c:char):boolean;
begin
  result := false;
  case c of
    '0'..'9': result := true;
  end;
end;


{---------------------------------------------------------------}
function hextoint(s:string):longint;
var
i, anumber:integer;
begin
  result := 0;
  anumber := 0;

  for i:=1 to length(s) do begin
    case s[i] of
      '0'..'9': anumber := ord(s[i])-ord('0');
      'A'..'F': anumber := ord(s[i])-ord('A')+10;
      'a'..'f': anumber := ord(s[i])-ord('a')+10;
      else exit; {exit function at non-hex, i.e. like JgoStrToInt.}
    end;

    result := result*16;
    inc(result,anumber);
  end;
end;

{---------------------------------------------------------------}
procedure intrange(low, high:integer; var what:integer);
begin
  if (what < low) then what := low;
  if (what > high) then what := high;
end;

procedure wordrange(low, high:word; var what:word);
begin
  if (what < low) then what := low;
  if (what > high) then what := high;
end;

procedure longrange(low,high:longint; var what:longint);
begin
  if (what < low) then what := low;
  if (what > high) then what := high;
end;

{--------------------------------------------------------------}
function boolstring(what:boolean):string;
begin
  if (what) then
  result := 'true'
  else
  result := 'false';
end;




{--------------------------------------------------------------}
{$ifdef SMALLISH}
function hprintf(handle:integer;
const TheFormat:string;
const Args: array of const):integer;
var
s:string;
p : array[0..257] of char;
count:integer;
begin

{
function StrPCopy(Dest: PChar; Source: string): PChar;
}
  result := -1;
  try
    s := format(Theformat,args);
    count := length(s);
    StrPCopy(p,s);
    result := FileWrite(handle,p,count);
    if result<>count then
    result := -1;
  except
  end;
end;
{$endif}

{****************************************************************************
this is the BIG version.
function StrPLCopy(Dest: PChar; const Source: string; MaxLen: Cardinal): PChar;
****************************************************************************}

type brokenprintf_exception = class(EStreamError);

function hprintf(handle:integer;
const TheFormat:string;
const Args: array of const):integer; overload;

const
ARSIZE = $200;

var
s:string;
slength:integer;

count:integer;
p : array[0..ARSIZE+5] of char;

begin

{
function StrPCopy(Dest: PChar; Source: string): PChar;
}
  result := -1;


  try
    s := safe_format(Theformat,args);
    slength := length(s);

    while true do begin
      count := length(s);

      if count>ARSIZE then
      count := ARSIZE;

      if count=0 then
      break;

      StrPLCopy(p,s,count);
      s := copy(s,count+1,slength);

      result := FileWrite(handle,p,count);
      if result<>count then
      raise
      brokenprintf_exception.Create('hprintf result<>count failure');
    end;
    {this is the good end.}
    result := slength;
  except
    on e: exception do
    Errorf(e.message);
  end;

end;

function hprintf(handle:integer; const TheFormat:string):integer;
overload;
begin
  result := hprintf(handle,TheFormat,[0]);
end;


{--------------------------------------------------------------}
function isspace(c:char):boolean;
begin
  result := false;
  case c of
    ' ', chr(9), chr(10), chr(13): result := true;
  end;
end;

function ischar(c:char):boolean;
begin
  result := not isspace(c);
end;

function isprint(c:char):boolean;
begin
  if c < ' ' then
  result := false
  else
  result := ischar(c);
end;

function despace(const s:string):string;
var
i:integer;
begin
  result := '';
  for i:=1 to length(s) do begin
    if not isspace(s[i]) then
    result := result + s[i];
  end;
end;

function ualphan(s:string):string;
var
i:integer;
begin
  result := '';
  for i:=1 to length(s) do begin
    case s[i] of
      'a'..'z','A'..'Z','0'..'9':
      result := result + UpCase(s[i]);
    end;
  end;
end;




{--------------------------------------------------------------}
{function FileRead(Handle: Integer; var Buffer; Count: Longint): Longint;}

function hgets(handle:integer; var dst:string):boolean;
var
c:char;
begin
  result := true;

  dst := '';

  while true do begin
    if FileRead(handle,c,1)<>1 then begin
      result := false;
      break;
    end;

    case c of
{stupid compiler doesn't like Cr constant !? }
      {Cr} chr(13): break;
      {LF} chr(10): ;       { throw away now. }
    else
      dst := dst+c;
      if (length(dst) >= 500) then
      break;
    end;
  end;
end;

function hrewind(handle:integer):boolean; {returns good if it worked.}
begin
  result :=
  (FileSeek(Handle, 0,0 )<> -1);
end;

function htell(handle:integer):longint;
begin
  result :=
  FileSeek(Handle,0,1);
end;

procedure tokenate(const s:string);
var
i:integer;
c:char;

state : (spaces, characters);

begin

  for i := low(tokenarray) to high(tokenarray) do
  tokenarray[i] := '';

  state := spaces;

  tokens := low(tokenarray)-1;  { pre decrement. }

  for i := 1 to length(s) do begin
    c := s[i];
    case state of
      spaces: begin
        if ischar(c) then begin
          state := characters;

          inc(tokens);
          tokenarray[tokens] := c;  {1st character.}

        end;
      end;

      characters: begin
        if isspace(c) then begin

          if tokens >= high(tokenarray) then
          break;

          state := spaces;

        end
        else
        tokenarray[tokens] := tokenarray[tokens]+c;
      end;
    end;
  end;

end;


{ tries to get a string from the handle, and then tokenates it,
leaving the results in the tokenarray, and the tokencount in tokens.
}

function tokenhget(handle:integer):boolean;
begin
  result := false;

  while true do begin

    if not hgets(handle,tokenstr) then
    exit;

    if (length(tokenstr)<1) or
    (tokenstr[1]=';') then
    continue;             { dump empty, comments }

    tokenate(tokenstr);
    break;
  end;

  result :=true;

end;

{-------------------------------------------------------------}

{same as StrToInt but doesn't crash at empty etc.}
function jgoStrToInt(const S: string): Longint;
var
i: integer;
minus : boolean;
r : longint;
begin
  r := 0;
  minus := false;

  for i := 1 to length(S) do begin
    case S[i] of
      ' ': ;  { throw away leading spaces }

      '0'..'9':
      r := (r * 10) + (ord(S[i])-ord('0'));

      '-':
      minus := true;

    else break;
    end
  end;

  result := r;

  if (minus) then
  result := -result;
end;


function jgoi(const S: string; const start, count:integer):longint;
begin
  result :=
  JgoStrToInt(copy(s,start,count));
end;


function spaces(count:integer):string;
begin
  result := '';
  while count>0 do begin
    result := result + ' ';
    dec(count);
  end;
end;

procedure flip(var what:boolean);
begin
  what := not what;
end;


{remove the last line end.}
function delineend(s:string):string;
var
count: integer;
begin
  count := length(s);
  if (count >= 2) and (s[count-1]=CR) then
  result := copy(s,1,count-2)
  else
  result := s;
end;

{remove bunches of last line ends}
function unline(s:string):string;
var
i:integer;
begin
  for i := 1 to 5 do
  s := delineend(s);
  result := s;
end;

function extractname(const s:string):string;
var
i:integer;
begin
  result := extractFileName(s);
  i := pos('.',result);
  if i>0 then
  result := copy(result,1,i-1);

end;


{return position in s of substr, but starting at index. 0 if not
there.}
function ipos(substr:string; index:integer; s:string):integer;
begin
  result := pos(substr,copy(s,index,255));
  if (result>0) then
  inc(result,index-1);
end;

{--------------------------------------------------------------}
procedure removecharacter(var s:string; where:integer);
begin
  if where>1 then
  s := copy(s,1,where-1)+copy(s,where+1,255)
  else
  s := copy(s,2,255);
end;

function hung(count:integer):boolean;
const
hungcount : integer = 0;
begin
  result := false;

  if count > 0 then
  hungcount := count
  else if hungcount=0 then
  result := true
  else begin
    dec(hungcount);
    if hungcount=0 then
    result := true;
  end;
end;

function pixelbits:integer;
var
ahandle : HDC;
begin
  ahandle:= CreateCompatibleDC(0);
  result := GetDeviceCaps(ahandle,BITSPIXEL);
  DeleteDC(ahandle);
end;

function lowest(one, two:integer):integer;
begin
  if (one < two) then
  result := one
  else
  result := two;
end;

procedure switchint(var one, two: integer);
var t : integer;
begin
  t := one;
  one := two;
  two := t;
end;

{
procedure switchcase(var key:char);
var
x:integer;
begin
  x := ord(key);
  case key of
    'A'..'Z': key := chr(x+$20);
    'a'..'z': key := chr(x-$20);
  end;
end;
}

procedure makeupper(var key:char);
var
x:integer;
begin
  x := ord(key);
  case key of
{    'A'..'Z': key := chr(x+$20);      }
    'a'..'z': key := chr(x-$20);
  end;
end;


function usure(s:string):boolean;
begin
  result :=
  MessageDlg(s,mtConfirmation,[mbYes,mbNo],0)
  = mrYES;
end;

procedure errorf(
const TheFormat: string;
const Args:array of const);
begin
  MessageDlg(format(Theformat,args),mtError,[mbOK],0);
end;

procedure errorf(
const TheFormat: string); overload;
begin
  errorf(TheFormat,[0]);
end;


procedure infof(
const TheFormat: string;
const Args:array of const);
begin
  MessageDlg(format(Theformat,args),mtInformation,[mbOK],0);
end;

function usuref(
const TheFormat: string;
const Args:array of const):boolean;
begin
  result := usure(format(Theformat,args));
end;

{ returns s[i], but if that's empty, returns chr$(0). }
function es(s:string; i:integer):char;
begin
  if length(s)<i then
  result := chr(0)
  else
  result := s[i];
end;

{advance the string to the next comma argument}
function commaoid(s:string):string;
var
i:integer;
begin
  i := pos(',',s);
  if i > 0 then
  result := copy(s,i+1,500)
  else
  result := '';
end;

{ a utility procedure that extracts a value after a colon. If
s is "1234:45:987", colonoid will change s to "45:987" and set
x to 45. }
procedure colonoid(var s:string; var x:longint);
var i:integer;
begin
  i := pos(':',s);
  if i > 0 then begin
    s := copy(s,i+1,500);
    x := jgoStrToInt(s);
  end;
end;

procedure editselect(edit:TEdit);
begin
  edit.SelStart := 0;
  edit.SelLength := length(edit.text);
end;

procedure replacechar(old,new:char; var dst:string);
var
i:integer;
begin
  for i:=1 to length(dst) do begin
    if dst[i]=old then
    dst[i] := new;
  end;
end;


function firstselected(listbox:Tlistbox):integer;
var
i:integer;
begin
  result := 0;
  for i:=0 to listbox.items.count-1 do begin
    if listbox.selected[i] then begin
      result := i;
      exit;
    end;
  end;
end;

function isdefault(s:string):boolean;
begin
  result :=
  (CompareText('DEFAULT',s)=0);
end;

function hexoid(s:string):longint;
begin
  if ( (length(s)>0) and (s[1]='$') ) then
  result := HexToInt(copy(s,2,500))
  else
  result := JgoStrToInt(s);
end;

{ called like
nfree(Tobject(bingo)); }

procedure nfree(var what:Tobject);
begin
  what.free;
  what := nil;
end;

function lastchar(s:string):string;
var
len:integer;
begin
  len := length(s);
  if len > 0 then
  result := s[len]
  else
  result := '';
end;

function firstnumber(s:string):integer;
var
i:integer;
begin
  result := 0;
  for i:= 1 to length(s) do begin
    if isdigit(s[i]) then begin
      result := JgoStrToInt(copy(s,i,500));
      exit;
    end;
  end;
end;

{***********************************************************************
removes control characters from s. Returns true if any such.
***********************************************************************}
function uncontrol(var s:string):boolean;
var
i:integer;
begin
  i := 1;
  result := false;

  while i <= length(s) do
  if (ord(s[i])<32) or (ord(s[i])>126) then begin
    s := copy(s,1,i-1)+copy(s,i+1,10000);
    result := true;
  end else
  inc(i);

end;

{****************************************************************************
if howlong, set wait to howlong. If 0, return YES if previous wait is
timed-out. Should be in ticks.// No u idiot in ms.
****************************************************************************}

function delayed(var t:TICKTIME; howlong: longint):boolean;
var
msnow : longint;
begin
  msnow := GetTickCount;  { that's a ms function. }

{ the allgorithm laughs at rollover, so don't need this...
  if (msnow <0) then begin
    result := true;
    exit;
  end;

Actually I suspect i could've just left it in there the way it is // right!
Except won't this stupid Pascal flag an error when it rolls-ver? Let's see.
//no. The way to do it is do the operation in the DLL of course. That's
why I have it. // well actuallly in the event is turned-out I *didn't* need
the DLL. sigh.
}

  if (howlong>0) then begin
    if (howlong < 60) then
    howlong := 60;
    t.oldcount := msnow;
    t.waitfor := howlong;
    result := false;
    exit;
  end;

  result :=
  (msnow-t.oldcount)
  >= t.waitfor;
end;

procedure mswait(ms: longint);
const
waiting:boolean = false;
var
t : TICKTIME;
begin
  if waiting then
  exit;

  waiting := true;
  if ms > 10000 then
  ms := 10000;

  delayed(t,ms);
  while not delayed(t,0) do
  begin
    application.processmessages;
  end;
  waiting := false;
end;


function getCDslash:string;
begin
  result := getCurrentDir;
  slash(result); //it might be d:\.
end;



procedure cwdize(var s:string);

begin

  if (length(s)>0) and (pos('\',s)=0)
  and (pos(':',s)=0) then
//  s := getCurrentDir+'\'+s;
  s := getCDslash+s;

end;


{returns true if another mutex with string exists. Or something.}

function mutoid(s:string):boolean;
var
  hMutex: Thandle;
begin
  HMutex := CreateMutex(nil,False,Pchar(s));

  result :=
  WaitForSingleObject(hMutex,0) = wait_Timeout;

end;

procedure fontsize(s:string; f:Tfont; var width, height:integer);
var
image : Timage;
begin
  image := Timage .create(nil);
  image.canvas.font := f;
  width := image.canvas.textwidth(s);
  height := image.canvas.textheight(s);
  image.free;

{this seemed to work Thursday, October 18, 2001 12:24 pm.
Tcanvas by itself "can't draw". // But note I couldn't use this
number to correctly decide how much junk would fit in a window by
dividing into height stormy weather. see lcx server.pas.}

end;

procedure addcharacter(var s:string; where:integer; what:char);
begin
  s :=
  copy(s,1,where-1)+
  what+
  copy(s,where,10000);
end;



{remove enclosing quotes.}
function unquote(s:string):string;
var
i:integer;
begin
  result := s;
  if es(result,1)='"' then
  result := copy(result,2,10000);

  if lastchar(result)='"' then
  result := copy(result,1,length(result)-1);

  while true do begin
    i := pos('""',result);

    if i<1 then
    exit;

    removecharacter(result,i);
  end;

end;

{fix quotes and add enclosing quotes.}
function quotate(s:string):string;
var
i:integer;
begin
  result := s;

  i := 1;

  while i <= length(result) do begin
    if result[i]='"' then begin
      addcharacter(result,i,'"');
      inc(i,2);
    end else
    inc(i);
  end;

  result := '"' + result + '"';

end;

procedure notimpl;
begin
  errorf('Sorry; feature not implemented',[0]);
end;

{****************************************************************************
*If* the first character is a ", return the string without the enclosing
quotes. Otherwise, if the character is a non-blank, return the initial word.
Else return empty string. Note that this is double-quote, for use probably
with ini files or who knows.
****************************************************************************}

function quoteword(s:string):string;
var
i:integer;
begin
  result := '';

  if es(s,1)='"' then begin
    i := 2;
    while i<=length(s) do begin
      if s[i]='"' then begin
        if es(s,i+1)='"' then begin
          inc(i);
        end else
        exit; {with result == string.}
      end;

      result := result + s[i];
      inc(i);
    end;
    exit; {unterminated quote. Whatever.}
  end;

  if isspace(es(s,1)) then
  exit; {with empty result.}

  i := 1;

  while i<=length(s) do begin
    if isspace(s[i]) then
    exit;

    result := result+s[i];
    inc(i);
  end;

  {no space at end of word. Fall thru with result==word.}

end;


function safe_format(
const TheFormat: string;
const Args:array of const):string;
begin
  try
    result := format(Theformat,args);
  except
    on e: exception do
    result :=
    format('Format() error in program!'+LNEND+'Error:'+LNEND+'%s'+LNEND+
    'Format:'+LNEND+'%s',[e.message,TheFormat]);
  end;
end;

function formatstring(s:string; size:integer; flushright:boolean=false):string;
begin
  result := s;
  if length(result)>size then
  exit;

  while (length(result)<size) do
  if flushright then
  result := ' '+result
  else
  result := result+' ';

end;


{****************************************************************************
Wed 4/06/2005 6:25 pm. This is a do-nothing program that fixes
NTDLL.DbgBreakPoint in Delphi 5 running under XP (SP2 although I think it's
all the XPs and NTs and who knows). Seems Microsoft left a breakpoint in a
DLL, so when you run a Delphi 5 program in the Delphi environment, it
starts-off by opening the CPU (assembly-language) window at a "ret". If you
use the arrow to up a bit you'll see you're at this code:

  ntdll.DbgBreakPoint:
  7C901230              int 3
  7C901231              ret         <---- you are here.

This is fairly frightening the first time it happens, but it was really quite
harmless although fairly annoying. Note that the program won't do this unless
it's in the IDE. To stop it, you can run PatchINT3 below from initialization
as shown -- written by a kindly german I found at
www.delphipraxis.net/post164845.html (I used google xlation). I fixed the
numerous punctuation errors -- and there are other copies of this thing in
slightly different forms and languages around the web, so who knows who wrote
the original. ...

Sadly this has to be in the program you're debugging; i.e., after you run
this, some *other* Delphi 5 debug IDE session will still break with the
breakpoint -- or who knows....

I still suspect there's some way to do this "normally"; I had high hopes for
EXCEPTION_BREAKPOINT $80000003 -- but I "added" it to the Delphi 5 exceptions
(tools / debugger options / OS exceptions / add button, with every combination
of the check boxes) with absolutely no effect.

Note the "$ifopt D+" will suppress the code if you compile a release version
with the debug info off, as the comment indicates. This will run outside the
IDE without annoyances.

RANDOM MUSINGS

Finally note that very simple programs -- like this one for instance -- will
*never* invoke the ntdll.dbgbreakpoint; I assume it has something to do with
particular controls, which are wrappers of / call Microsoft controls, which in
turn call the ntdll.dbgbreakpoint which is, I gather, an entry point
specifically for the purpose of invoking the debugger. Perhaps the usux code
does this under provocation from the Borland code; more likely, it's "just
normal" and the usux tools handle the thing properly, as do later Borland
tools (Delphi 6, 7) after sacrifice of first child presumably....

****************************************************************************}

{$ifopt D+}  {If compiled with "project / options / compiler / debug info off"
the PatchINT3 code disappears. After changing the option, I had to go "project
/ build" to make it "take".}

procedure PatchINT3;
var
NOP: Byte;
NTDLL: THandle;
BytesWritten: DWORD;
ADDRESS: Pointer;
begin
  if DebugHook=0 then
  exit;


  if Win32Platform <> VER_PLATFORM_WIN32_NT then
  exit;

  NTDLL := GetModuleHandle('NTDLL.DLL');

  if NTDLL = 0 then
  exit;

  ADDRESS := GetProcAddress(NTDLL, 'DbgBreakPoint');
  if ADDRESS = nil then
  exit;

//  showmessage('PatchINT3');

  try
    if Char(Address^) <> #$CC
    then exit;

    NOP := $90;

    if WriteProcessMemory(GetCurrentProcess,ADDRESS,@NOP, 1,BytesWritten) and
    (BytesWritten = 1) then
    FlushInstructionCache(GetCurrentProcess, ADDRESS, 1);

  except
      // DO emergency panic if you lake at EAccessViolation here, it is
      // perfectly harmless!
    on EAccessViolation DO;
  else raise;
  end;

end ;
{$endif}

initialization

{$ifopt D+} {only compiled if debug info on.}
PatchInt3;
{$endif}


end.
