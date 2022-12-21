unit globals;

interface
type
  TMyArray = array of string;
  TMyMatrix = array of array of string;

var
  qs: string;      // Query-String
  DBHost, DBUser, DBPass, DBName: string;
  pg_ConnParms : string;
  row: integer;

const pg_ClientEncoding = 'LATIN1';
const NetzpMessage = 'Demo - Message';
const LOGFILE = 'demo.log';

implementation

end.
