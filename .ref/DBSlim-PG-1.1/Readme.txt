//==============================================================================
// Licenced under MOZILLA PUBLIC LICENSE Vers. 1.1, see Licence.txt
// Version 1.1: Tilo Ermlich - www.netzpol.de - 27th February 2008
   - improvement of demo-gui and source code
   - update of all DLLs
   - comments added to source code
   - compiler flag "SQLLOG" added
   - source code translated to english

// Version 1.0: Tilo Ermlich - www.netzpol.de - 1st October 2007
//==============================================================================
{################################################################
Informations for compiling:
Type		Compiler-Flags		Notice
PostgreSQL	PostgreSQL		use it with PostgreSQL
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
globals.pas		global definitions
libpq_fe.pas		interface specific definitions for structures and functions (*JGO: translation of libpq-fe.h)
Licence.txt		MOZILLA PUBLIC LICENSE Vers. 1.1
postgres_ext.pas	general PostgreSQL-definition and objects (*JGO: translation of postgres_ext.h)
prog_db_postgresql.pas	the PostgreSQL-abstraction-layer
prog_global.pas		general routines and functions
Readme.txt		this file
sbrs.dcu		necessary, the compilation of sbrs.pas fails on my system !! (*JGO)
sbrs.pas		program code from JGO*
tail.exe		tail-executable from the UnxUtils updates (unxutils.sourceforge.net)


Libraries
1. DLLs from the MS Windows PostgreSQL-Distribution 8.2.5 (build 7260)
comerr32.dll		COM_ERR - Common Error Handler for MIT Kerberos v5 / GSS distribution, Version 1.3.5
krb5_32.dll		Kerberos v5 - MIT GSS / Kerberos v5 distribution, Version 1.3.5
libiconv-2.dll		LibIconv: convert between character encodings (original from the GnuWin32 project)
libintl-2.dll		GetText: library and tools for native language support (original from the GnuWin32 project)
libpq.dll		PostgreSQL Access Library (8.2.5.7260)

2. DLLs from the MS Windows OpenSSL-Distribution 0.9.8e
libeay32.dll		OpenSSL Shared Library (0.9.8.5 from 0.9.8e)
ssleay32.dll		OpenSSL Shared Library (0.9.8.5 from 0.9.8e)


*JGO: J.G. Owen (http://home.att.net/~owen_labs)
################################################################

PostgreSQL:
CREATE TABLE address
(
  firstname character varying(255),
  lastname character varying(255),
  birthdate date,
  telefon character varying(255)
) 
WITHOUT OIDS;
ALTER TABLE address OWNER TO test;

INSERT INTO address (firstname, lastname, birthdate, telefon) VALUES ('Tim', 'Woolstencroft', '1968-12-31', '0031123345');
################################################################
Tilo Ermlich - 1st October 2007, Hamburg, Germany - www.netzpol.de