//==============================================================================
// Licenced under MOZILLA PUBLIC LICENSE Vers. 1.1, see Licence.txt
// Version 1.0: Tilo Ermlich - www.netzpol.de - 27th February 2008
//==============================================================================
{################################################################
Informations for compiling:
Type		Compiler-Flags		Notice
SQLite		SQLite			use it with SQLite
opt. Debugging  SQLLOG			use it optional for debugging purposes

################################################################}
Files:
cleanup.bat		Cleans compilation output
dbslim.cfg
dbslim.dof
dbslim.dpr		the Delphi project file
dbslim.exe		compiled version
demo.dfm
demo.pas
demo.log		Log-file if compiler flag "SQLLOG" is enabled 
demo.s3db		sqlite3-database 
globals.pas		global definitions
libsqlite3.pas		sqlite3.dll api interface from LibSQL-project (René Tegel, sourceforge.net/projects/libsql)
libsqlite.pas		libsql.dll api interface from LibSQL-project (René Tegel, sourceforge.net/projects/libsql)
Licence.txt		MOZILLA PUBLIC LICENSE Vers. 1.1
MkSqLite3.pas		from MkSqLite-project (Mike Cariotoglou, www.sqlite.org/contrib)
MkSqLite3Api.pas	from MkSqLite-project (Mike Cariotoglou, www.sqlite.org/contrib)
passql.pas		from LibSQL-project (René Tegel, sourceforge.net/projects/libsql)
passqlite.pas		from LibSQL-project (René Tegel, sourceforge.net/projects/libsql)
prog_db_sqlite.pas	the SQLite-abstraction-layer
prog_global.pas		general routines and functions
Readme.txt		this file
sqlite3.dll		sqlite library from SQLite Administrator (sqliteadmin.orbmu2k.de)
sqlsupport.pas		from LibSQL-project (René Tegel, sourceforge.net/projects/libsql)
tail.exe		tail-executable from the UnxUtils updates (unxutils.sourceforge.net)
utf8util.pas		from LibSQL-project (René Tegel, sourceforge.net/projects/libsql)
################################################################

SQLite:
CREATE TABLE address
(
  firstname character varying(255),
  lastname character varying(255),
  birthdate date,
  telefon character varying(255)
) 

INSERT INTO address (firstname, lastname, birthdate, telefon) VALUES ('Tim', 'Woolstencroft', '1968-12-31', '0031123345');
################################################################
Tilo Ermlich - 27th February 2008, Hamburg, Germany - www.netzpol.de