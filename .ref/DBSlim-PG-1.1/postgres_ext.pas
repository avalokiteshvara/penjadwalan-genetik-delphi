
unit postgres_ext;

interface

uses Windows;

{-------------------------------------------------------------------------
 *
 * postgres_ext.h
 *
 *       This file contains declarations of things that are visible everywhere
 *    in PostgreSQL *and* are visible to clients of frontend interface libraries.
 *    For example, the Oid type is part of the API of libpq and other libraries.
 *
 *       Declarations which are specific to a particular interface should
 *    go in the header file for that interface (such as libpq-fe.h).  This
 *    file is only for fundamental Postgres declarations.
 *
 *       User-written C functions don't count as "external to Postgres."
 *    Those function much as local modifications to the backend itself, and
 *    use header files that are otherwise internal to Postgres to interface
 *    with the backend.
 *
 * $PostgreSQL: pgsql/src/include/postgres_ext.h,v 1.16 2004/08/29 05:06:55 momjian Exp $
 *
 *-------------------------------------------------------------------------
  }
{
 * Object ID is a fundamental type in Postgres.
  }

type

   Oid = dword;
   p_Oid = ^Oid;

const

   InvalidOid : Oid = 0;

   OID_MAX = high(DWORD) {UINT_MAX};
{ you will need to include <limits.h> to use the above #define  }
{
 * NAMEDATALEN is the max length for system identifiers (e.g. table names,
 * attribute names, function names, etc).  It must be a multiple of
 * sizeof(int) (typically 4).
 *
 * NOTE that databases with different NAMEDATALEN's cannot interoperate!
  }
   NAMEDATALEN = 64;
{
 * Identifiers of error message fields.  Kept here to keep common
 * between frontend and backend, and also to export them to libpq
 * applications.
  }
   PG_DIAG_SEVERITY = 'S';
   PG_DIAG_SQLSTATE = 'C';
   PG_DIAG_MESSAGE_PRIMARY = 'M';
   PG_DIAG_MESSAGE_DETAIL = 'D';
   PG_DIAG_MESSAGE_HINT = 'H';
   PG_DIAG_STATEMENT_POSITION = 'P';
   PG_DIAG_INTERNAL_POSITION = 'p';
   PG_DIAG_INTERNAL_QUERY = 'q';
   PG_DIAG_CONTEXT = 'W';
   PG_DIAG_SOURCE_FILE = 'F';
   PG_DIAG_SOURCE_LINE = 'L';
   PG_DIAG_SOURCE_FUNCTION = 'R';

implementation

end.
