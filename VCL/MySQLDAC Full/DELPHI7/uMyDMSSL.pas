unit uMyDMSSL;
////////////////////////////////////////////////////////////////////////////////
// Varios imports from open ssl dll's
// at a later stage this may import the obj files (for no external dlls)
// currently uses libeay32.dll and ssleay32.dll

interface

{$I mysqlinc.inc}

uses
  sysutils{, Dialogs}; //for debug

{$IFDEF HAVE_SSL}

type
  st_VioSSLConnectorFd = record
    ssl_context_:pointer;
    ssl_method_:pointer;
  end;

  //ssleay32.dll
  TSSL_write = function (s:pointer; var buff;len:longint):longint;cdecl;
  TSSL_read = function (s: pointer; var Buf; len: longint): longint; cdecl;
  TSSL_get_error = function (s:pointer;ret_code:longint):longint;cdecl;
  TSSL_shutdown = function (s:pointer):longint;cdecl;
  TSSL_state = function (s:pointer):longint;cdecl;
  TSSL_free = procedure (s:pointer);cdecl;
  TSSL_load_error_strings = procedure;cdecl;
  TTLSv1_client_method = function: pointer;cdecl;
  TSSL_CTX_new = function (meth:pointer):pointer;cdecl;
  TSSL_CTX_set_cipher_list = function (actx:pointer;const str:pchar):longint;cdecl;
  TSSL_new = function (s:pointer):pointer;cdecl;
  TSSL_clear = function (s:pointer):longint;cdecl;
  TSSL_SESSION_set_timeout = function (s:pointer; t:cardinal):longint;cdecl;
  TSSL_get_session = function (s:pointer):pointer;cdecl;
  TSSL_set_fd = function (s:pointer; fd:longint):longint;cdecl;
  TSSL_set_connect_state = procedure (s:pointer);cdecl;
  TSSL_do_handshake = function (s:pointer):longint;cdecl;
  TSSL_get_peer_certificate = function (s:pointer):pointer;cdecl;
  TSSL_set_session = function (_to:pointer;session:pointer):longint;cdecl;
  TSSL_connect = function (s:pointer):longint;cdecl;
  TSSL_CIPHER_get_name = function (c:pointer):pchar;cdecl;
  TSSL_get_current_cipher = function (s:pointer):pointer;cdecl;
  TSSL_CTX_set_verify = procedure (actx:pointer;mode:longint;acallback:pointer);cdecl;
  TSSL_CTX_load_verify_locations = function (actx:pointer; const CAfile:pchar;const CApath:pchar):longint;cdecl;
  TSSL_CTX_set_default_verify_paths = function (actx:pointer):longint;cdecl;
  TSSL_CTX_use_certificate_file = function (actx:pointer; const afile:pchar; atype:longint):longint;cdecl;
  TSSL_CTX_use_PrivateKey_file = function (actx:pointer; const afile:pchar; atype:longint):longint;cdecl;
  TSSL_CTX_check_private_key = function (actx:pointer):longint;cdecl;
  TSSL_CTX_ctrl = function (actx:pointer;a1:longint;a2:longint; adh:pointer):longint;cdecl;
  //libeay32.dll
  TDH_new = function :pointer;cdecl;
  TDH_free = function (dh:pointer):longint;cdecl;
  TOpenSSL_add_all_algorithms = procedure ;cdecl;
  TBN_bin2bn = function (const s:pointer;len:longint;ret:pointer):pointer;cdecl;
  TX509_get_subject_name = function (a:pointer):pointer;cdecl;
  TX509_NAME_oneline = function (a:pointer;buf:pchar;size:longint):pchar;cdecl;
  TX509_STORE_CTX_get_error_depth = function (actx:pointer):longint;cdecl;
  TX509_STORE_CTX_get_error = function (actx:pointer):longint;cdecl;
  TX509_STORE_CTX_get_current_cert = function (actx:pointer):pointer;cdecl;
  TX509_verify_cert_error_string = function (n:longint):pchar;cdecl;
  TX509_get_issuer_name = function (a:pointer):pointer;cdecl;
  TERR_get_error_line_data = function (const afile:pointer;line:pointer;const data:pointer;flags:pointer):longint;cdecl;
  TERR_error_string = function (e:cardinal;buf:pchar):pchar;cdecl;
  TX509_free = procedure (a:pointer);cdecl;

var
//ssleay32.dll
  SSL_write                        : TSSL_write;
  SSL_read                         : TSSL_read;
  SSL_get_error                    : TSSL_get_error;
  SSL_shutdown                     : TSSL_shutdown;
  SSL_state                        : TSSL_state;
  SSL_free                         : TSSL_free;
  SSL_load_error_strings           : TSSL_load_error_strings;
  TLSv1_client_method              : TTLSv1_client_method;
  SSL_CTX_new                      : TSSL_CTX_new;
  SSL_CTX_set_cipher_list          : TSSL_CTX_set_cipher_list;
  SSL_new                          : TSSL_new;
  SSL_clear                        : TSSL_clear;
  SSL_SESSION_set_timeout          : TSSL_SESSION_set_timeout;
  SSL_get_session                  : TSSL_get_session;
  SSL_set_fd                       : TSSL_set_fd;
  SSL_set_connect_state            : TSSL_set_connect_state;
  SSL_do_handshake                 : TSSL_do_handshake;
  SSL_get_peer_certificate         : TSSL_get_peer_certificate;
  SSL_set_session                  : TSSL_set_session;
  SSL_connect                      : TSSL_connect;
  SSL_CIPHER_get_name              : TSSL_CIPHER_get_name;
  SSL_get_current_cipher           : TSSL_get_current_cipher;
  SSL_CTX_set_verify               : TSSL_CTX_set_verify;
  SSL_CTX_load_verify_locations    : TSSL_CTX_load_verify_locations;
  SSL_CTX_set_default_verify_paths : TSSL_CTX_set_default_verify_paths;
  SSL_CTX_use_certificate_file     : TSSL_CTX_use_certificate_file;
  SSL_CTX_use_PrivateKey_file      : TSSL_CTX_use_PrivateKey_file;
  SSL_CTX_check_private_key        : TSSL_CTX_check_private_key;
  SSL_CTX_ctrl                     : TSSL_CTX_ctrl;
  //libeay32.dll
  DH_new                           : TDH_new;
  DH_free                          : TDH_free;
  OpenSSL_add_all_algorithms       : TOpenSSL_add_all_algorithms;
  BN_bin2bn                        : TBN_bin2bn;
  X509_get_subject_name            : TX509_get_subject_name;
  X509_NAME_oneline                : TX509_NAME_oneline;
  X509_STORE_CTX_get_error_depth   : TX509_STORE_CTX_get_error_depth;
  X509_STORE_CTX_get_error         : TX509_STORE_CTX_get_error;
  X509_STORE_CTX_get_current_cert  : TX509_STORE_CTX_get_current_cert;
  X509_verify_cert_error_string    : TX509_verify_cert_error_string;
  X509_get_issuer_name             : TX509_get_issuer_name;
  ERR_get_error_line_data          : TERR_get_error_line_data;
  ERR_error_string                 : TERR_error_string;
  X509_free                        : TX509_free;
   //
////ssleay32.dll
//function SSL_write(s:pointer; var buff;len:longint):longint;cdecl;external 'ssleay32.dll';
//function SSL_read(s: pointer; var Buf; len: longint): longint; cdecl;external 'ssleay32.dll';
//function SSL_get_error(s:pointer;ret_code:longint):longint;cdecl;external 'ssleay32.dll';
//function SSL_shutdown(s:pointer):longint;cdecl;external 'ssleay32.dll';
//function SSL_state(s:pointer):longint;cdecl;external 'ssleay32.dll';
//procedure SSL_free(s:pointer);cdecl;external 'ssleay32.dll';
//procedure SSL_load_error_strings;cdecl;external 'ssleay32.dll';
//function TLSv1_client_method:pointer;cdecl;external 'ssleay32.dll';
//function SSL_CTX_new(meth:pointer):pointer;cdecl;external 'ssleay32.dll';
//function SSL_CTX_set_cipher_list(actx:pointer;const str:pchar):longint;cdecl;external 'ssleay32.dll';
//function SSL_new(s:pointer):pointer;cdecl;external 'ssleay32.dll';
//function SSL_clear(s:pointer):longint;cdecl;external 'ssleay32.dll';
//function SSL_SESSION_set_timeout(s:pointer; t:cardinal):longint;cdecl;external 'ssleay32.dll';
//function SSL_get_session(s:pointer):pointer;cdecl;external 'ssleay32.dll';
//function SSL_set_fd(s:pointer; fd:longint):longint;cdecl;external 'ssleay32.dll';
//procedure SSL_set_connect_state(s:pointer);cdecl;external 'ssleay32.dll';
//function SSL_do_handshake(s:pointer):longint;cdecl;external 'ssleay32.dll';
//function SSL_get_peer_certificate(s:pointer):pointer;cdecl;external 'ssleay32.dll';
//function SSL_set_session(_to:pointer;session:pointer):longint;cdecl;external 'ssleay32.dll';
//function SSL_connect(s:pointer):longint;cdecl;external 'ssleay32.dll';
//function SSL_CIPHER_get_name(c:pointer):pchar;cdecl;external 'ssleay32.dll';
//function SSL_get_current_cipher(s:pointer):pointer;cdecl;external 'ssleay32.dll';
//procedure SSL_CTX_set_verify(actx:pointer;mode:longint;acallback:pointer);cdecl;external 'ssleay32.dll';
//function SSL_CTX_load_verify_locations(actx:pointer; const CAfile:pchar;const CApath:pchar):longint;cdecl;external 'ssleay32.dll';
//function SSL_CTX_set_default_verify_paths(actx:pointer):longint;cdecl;external 'ssleay32.dll';
//function SSL_CTX_use_certificate_file(actx:pointer; const afile:pchar; atype:longint):longint;cdecl;external 'ssleay32.dll';
//function SSL_CTX_use_PrivateKey_file(actx:pointer; const afile:pchar; atype:longint):longint;cdecl;external 'ssleay32.dll';
//function SSL_CTX_check_private_key(actx:pointer):longint;cdecl;external 'ssleay32.dll';
//function SSL_CTX_ctrl(actx:pointer;a1:longint;a2:longint; adh:pointer):longint;cdecl;external 'ssleay32.dll';
////libeay32.dll
//function DH_new:pointer;cdecl;external 'libeay32.dll';
//function DH_free(dh:pointer):longint;cdecl;external 'libeay32.dll';
//procedure OpenSSL_add_all_algorithms;cdecl;external 'libeay32.dll';
//function BN_bin2bn(const s:pointer;len:longint;ret:pointer):pointer;cdecl;external 'libeay32.dll';
//function X509_get_subject_name(a:pointer):pointer;cdecl;external 'libeay32.dll';
//function X509_NAME_oneline(a:pointer;buf:pchar;size:longint):pchar;cdecl;external 'libeay32.dll';
//function X509_STORE_CTX_get_error_depth(actx:pointer):longint;cdecl;external 'libeay32.dll';
//function X509_STORE_CTX_get_error(actx:pointer):longint;cdecl;external 'libeay32.dll';
//function X509_STORE_CTX_get_current_cert(actx:pointer):pointer;cdecl;external 'libeay32.dll';
//function X509_verify_cert_error_string(n:longint):pchar;cdecl;external 'libeay32.dll';
//function X509_get_issuer_name(a:pointer):pointer;cdecl;external 'libeay32.dll';
//function ERR_get_error_line_data(const afile:pointer;line:pointer;const data:pointer;flags:pointer):longint;cdecl;external 'libeay32.dll';
//function ERR_error_string(e:cardinal;buf:pchar):pchar;cdecl;external 'libeay32.dll';
//procedure X509_free(a:pointer);cdecl;external 'libeay32.dll';

var
  ssl_algorithms_added:boolean = false;
  ssl_error_strings_loaded:boolean = false;

//these are the functions implemented by us
function vio_verify_callback(ok:longint; ctx:pointer):longint;cdecl;
function vio_set_cert_stuff(ctx:pointer; const cert_file:pchar; key_file:pchar):longint;
function get_dh512:pointer;

function LoadSSLLib: boolean;
procedure UnloadSSLLib;
{$ENDIF}

implementation
uses
   Windows;

var
  hSSLeay32Lib: cardinal = 0;
  hLibeay32   : cardinal = 0;

{$IFDEF HAVE_SSL}

{$HINTS OFF}
////////////////////////////////////////////////////////////////////////////////
// the callback for verify on ssl .. we can get errors and details here
// you should remove the showmessages from here
function vio_verify_callback(ok:longint; ctx:pointer):longint;cdecl;
type
  TDummyCTX = record
    pad:array[0..75]of byte;
    error:longint;
    current_cert:pointer;
  end;
var
  buf:array[0..255]of char;
  err_cert:pointer;
  depth, err:longint;
begin
  //get the details
  err_cert:=X509_STORE_CTX_get_current_cert(ctx);
  err:= X509_STORE_CTX_get_error(ctx);
  depth:=X509_STORE_CTX_get_error_depth(ctx);
  X509_NAME_oneline(X509_get_subject_name(err_cert),pchar(@buf),256);
  ok:=1;
  //some more details about the error
  case TDummyCTX(ctx^).error of
    2: //X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT:
        begin
          X509_NAME_oneline(X509_get_issuer_name(TDummyCTX(ctx^).current_cert),buf,256);
          //showmessage('issuer= '+buf);
        end;
    9,13: //X509_V_ERR_CERT_NOT_YET_VALID:
          //X509_V_ERR_ERROR_IN_CERT_NOT_BEFORE_FIELD:
          //DBUG_PRINT("error", ("notBefore"));
          //*ASN1_TIME_print_fp(stderr,X509_get_notBefore(ctx->current_cert));*/
           ;
    10,14: //X509_V_ERR_CERT_HAS_EXPIRED:
            //X509_V_ERR_ERROR_IN_CERT_NOT_AFTER_FIELD:
            //DBUG_PRINT("error", ("notAfter error"));
            //*ASN1_TIME_print_fp(stderr,X509_get_notAfter(ctx->current_cert));*/
            ;
  end;
  result:=ok;
end;
{$HINTS ON}

////////////////////////////////////////////////////////////////////////////////
// sets the cert stuff
function vio_set_cert_stuff(ctx:pointer; const cert_file:pchar; key_file:pchar):longint;
begin
  result:=0;
  if (cert_file <> nil) and (cert_file<>'') then //is there anything to set?
    begin
      //use it
      if (SSL_CTX_use_certificate_file(ctx,cert_file,1{SSL_FILETYPE_PEM}) <= 0) then
        exit;
      if (key_file =nil)or(key_file='') then //do we have any key
        key_file := cert_file;
      //use it
      if (SSL_CTX_use_PrivateKey_file(ctx,key_file, 1{SSL_FILETYPE_PEM}) <= 0) then
        exit;
      //let's check it
      if (SSL_CTX_check_private_key(pointer(ctx^))<>0) then
        exit;
    end;
  result:=1;//no errors
end;

////////////////////////////////////////////////////////////////////////////////
// gets a new dh
function get_dh512:pointer;
const
  dh512_g:array[1..1] of byte = ($02);
  dh512_p: array[1..64] of byte =(
    $DA,$58,$3C,$16,$D9,$85,$22,$89,$D0,$E4,$AF,$75,
    $6F,$4C,$CA,$92,$DD,$4B,$E5,$33,$B8,$04,$FB,$0F,
    $ED,$94,$EF,$9C,$8A,$44,$03,$ED,$57,$46,$50,$D3,
    $69,$99,$DB,$29,$D7,$76,$27,$6B,$A2,$D3,$D4,$12,
    $E2,$18,$F4,$DD,$1E,$08,$4C,$F6,$D8,$00,$3E,$7C,
    $47,$74,$E8,$33);

type
  TDHdummy = record
    pad:longint;
    version:longint;
    p:pointer;
    g:pointer;
    //the others are skipped
  end;
var
  dh:pointer;
begin
  result:=nil;
  dh:=DH_new; //grab a dh
  if (dh= nil) then
    exit;
  TDHdummy(dh^).p:=BN_bin2bn(@dh512_p,sizeof(dh512_p),nil); //set p
  TDHdummy(dh^).g:=BN_bin2bn(@dh512_g,sizeof(dh512_g),nil); //set g
  if ((TDHdummy(dh^).p = nil) or (TDHdummy(dh^).g = nil)) then //any errors?
    begin
      dh_free(dh);
      exit;
    end;
  result:=dh;
end;

function LoadSSLLib: Boolean;

  function GetSSLProc(AModule : Cardinal; ProcName : PChar ) : TFarProc;
  begin
    Result := GetProcAddress(AModule, ProcName );
    if not assigned(Result) then
      {$IFDEF VER130}RaiseLastWin32Error;{$ELSE}RaiseLastOSError;{$ENDIF}
  end;

begin
   Result := False;
   hSSLeay32Lib := LoadLibrary('ssleay32.dll');
   if hSSLeay32Lib = 0 then
      Exit;
   try
     @SSL_write                        := GetSSLProc(hSSLeay32Lib,'SSL_write');
     @SSL_read                         := GetSSLProc(hSSLeay32Lib,'SSL_read');
     @SSL_get_error                    := GetSSLProc(hSSLeay32Lib,'SSL_get_error');
     @SSL_shutdown                     := GetSSLProc(hSSLeay32Lib,'SSL_shutdown');
     @SSL_state                        := GetSSLProc(hSSLeay32Lib,'SSL_state');
     @SSL_free                         := GetSSLProc(hSSLeay32Lib,'SSL_free');
     @SSL_load_error_strings           := GetSSLProc(hSSLeay32Lib,'SSL_load_error_strings');
     @TLSv1_client_method              := GetSSLProc(hSSLeay32Lib,'TLSv1_client_method');
     @SSL_CTX_new                      := GetSSLProc(hSSLeay32Lib,'SSL_CTX_new');
     @SSL_CTX_set_cipher_list          := GetSSLProc(hSSLeay32Lib,'SSL_CTX_set_cipher_list');
     @SSL_new                          := GetSSLProc(hSSLeay32Lib,'SSL_new');
     @SSL_clear                        := GetSSLProc(hSSLeay32Lib,'SSL_clear');
     @SSL_SESSION_set_timeout          := GetSSLProc(hSSLeay32Lib,'SSL_SESSION_set_timeout');
     @SSL_get_session                  := GetSSLProc(hSSLeay32Lib,'SSL_get_session');
     @SSL_set_fd                       := GetSSLProc(hSSLeay32Lib,'SSL_set_fd');
     @SSL_set_connect_state            := GetSSLProc(hSSLeay32Lib,'SSL_set_connect_state');
     @SSL_do_handshake                 := GetSSLProc(hSSLeay32Lib,'SSL_do_handshake');
     @SSL_get_peer_certificate         := GetSSLProc(hSSLeay32Lib,'SSL_get_peer_certificate');
     @SSL_set_session                  := GetSSLProc(hSSLeay32Lib,'SSL_set_session');
     @SSL_connect                      := GetSSLProc(hSSLeay32Lib,'SSL_connect');
     @SSL_CIPHER_get_name              := GetSSLProc(hSSLeay32Lib,'SSL_CIPHER_get_name');
     @SSL_get_current_cipher           := GetSSLProc(hSSLeay32Lib,'SSL_get_current_cipher');
     @SSL_CTX_set_verify               := GetSSLProc(hSSLeay32Lib,'SSL_CTX_set_verify');
     @SSL_CTX_load_verify_locations    := GetSSLProc(hSSLeay32Lib,'SSL_CTX_load_verify_locations');
     @SSL_CTX_set_default_verify_paths := GetSSLProc(hSSLeay32Lib,'SSL_CTX_set_default_verify_paths');
     @SSL_CTX_use_certificate_file     := GetSSLProc(hSSLeay32Lib,'SSL_CTX_use_certificate_file');
     @SSL_CTX_use_PrivateKey_file      := GetSSLProc(hSSLeay32Lib,'SSL_CTX_use_PrivateKey_file');
     @SSL_CTX_check_private_key        := GetSSLProc(hSSLeay32Lib,'SSL_CTX_check_private_key');
     @SSL_CTX_ctrl                     := GetSSLProc(hSSLeay32Lib,'SSL_CTX_ctrl');
     Result := True;
   except
     FreeLibrary(hSSLeay32Lib);
     hSSLeay32Lib:= 0;
     Result := False;
     Exit;
//     raise;
   end;
   hLibeay32 := LoadLibrary('libeay32.dll');
   if hLibeay32 = 0 then
   begin
      FreeLibrary(hSSLeay32Lib);
      hSSLeay32Lib:= 0;
      Result := False;
      Exit;
   end;
   try
     @DH_new                           := GetSSLProc(hLibeay32,'DH_new');
     @DH_free                          := GetSSLProc(hLibeay32,'DH_free');
     @OpenSSL_add_all_algorithms       := GetSSLProc(hLibeay32,'OpenSSL_add_all_algorithms');
     @BN_bin2bn                        := GetSSLProc(hLibeay32,'BN_bin2bn');
     @X509_get_subject_name            := GetSSLProc(hLibeay32,'X509_get_subject_name');
     @X509_NAME_oneline                := GetSSLProc(hLibeay32,'X509_NAME_oneline');
     @X509_STORE_CTX_get_error_depth   := GetSSLProc(hLibeay32,'X509_STORE_CTX_get_error_depth');
     @X509_STORE_CTX_get_error         := GetSSLProc(hLibeay32,'X509_STORE_CTX_get_error');
     @X509_STORE_CTX_get_current_cert  := GetSSLProc(hLibeay32,'X509_STORE_CTX_get_current_cert');
     @X509_verify_cert_error_string    := GetSSLProc(hLibeay32,'X509_verify_cert_error_string');
     @X509_get_issuer_name             := GetSSLProc(hLibeay32,'X509_get_issuer_name');
     @ERR_get_error_line_data          := GetSSLProc(hLibeay32,'ERR_get_error_line_data');
     @ERR_error_string                 := GetSSLProc(hLibeay32,'ERR_error_string');
     @X509_free                        := GetSSLProc(hLibeay32,'X509_free');
     Result := True;
   except
     UnloadSSLLib;
     Result := False;
     Exit;
//     raise;
   end;
end;

procedure UnloadSSLLib;
begin
  if hSSLeay32Lib <> 0 then
     FreeLibrary(hSSLeay32Lib);
  hSSLeay32Lib:= 0;
  if hLibeay32 <> 0 then
     FreeLibrary(hLibeay32);
  hLibeay32:= 0;
end;


{$ENDIF}

Initialization

Finalization
  UnloadSSLLib;
end.

