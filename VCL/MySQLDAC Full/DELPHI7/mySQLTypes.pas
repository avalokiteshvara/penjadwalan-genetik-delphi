{$I mysqldac.inc}
unit mySQLTypes;
{$Z+,T-}
interface

uses Windows, Classes, Winsock,SysUtils,Math,mySQLCP,uMyDMClient, uMyDMCT;

//============================================================================//
//                            Error Categories                                //
//============================================================================//
const
  ERRBASE_NONE                  = 0;      { No error }
  ERRBASE_NOTFOUND              = $2200;  { Object of interest Not Found }
  ERRBASE_INVALIDREQ            = $2700;  { Invalid Request }
  ERRBASE_SEC                   = $2900;  { Access Violation - Security related }
  ERRBASE_IC                    = $2A00;  { Invalid context }
  ERRBASE_QUERY                 = $2E00;  { Query related }
  ERRBASE_CAPABILITY            = $3000;  { Capability not supported }
  ERRBASE_OTHER                 = $3300;  { Miscellaneous }
//=============================================================================//
//                           Error Codes By Category                           //
//=============================================================================//
  ERRCODE_NONE                  = 0;
  DBIERR_NONE                   = (ERRBASE_NONE + ERRCODE_NONE);
  ERRCODE_BOF                   = 1;      { Beginning of Virtual table }
  ERRCODE_EOF                   = 2;      { End of Virtual table }
  ERRCODE_NOCURRREC             = 5;      { No current record }
  ERRCODE_RECNOTFOUND           = 6;      { Record was not found }
  ERRCODE_ENDOFBLOB             = 7;      { End of Blob reached }
  DBIERR_BOF                    = (ERRBASE_NOTFOUND + ERRCODE_BOF);
  DBIERR_EOF                    = (ERRBASE_NOTFOUND + ERRCODE_EOF);
  DBIERR_NOCURRREC              = (ERRBASE_NOTFOUND + ERRCODE_NOCURRREC);
  DBIERR_RECNOTFOUND            = (ERRBASE_NOTFOUND + ERRCODE_RECNOTFOUND);
  DBIERR_ENDOFBLOB              = (ERRBASE_NOTFOUND + ERRCODE_ENDOFBLOB);
  ERRCODE_INVALIDPARAM          = 2;      { Generic invalid parameter }
  ERRCODE_INVALIDHNDL           = 6;      { Invalid handle to the function }
  ERRCODE_NOSUCHINDEX           = 13;     { 0x0d Index does not exist }
  ERRCODE_INVALIDBLOBOFFSET     = 14;     { 0x0e Invalid Offset into the Blob }
  ERRCODE_INVALIDRECSTRUCT      = 19;     { 0x13 Invalid record structure }
  ERRCODE_NOSUCHTABLE           = 40;     { 0x28 No such table }
  ERRCODE_NOSUCHFILTER          = 66;     { 0x42 Filter handle is invalid }
  DBIERR_INVALIDPARAM           = (ERRBASE_INVALIDREQ + ERRCODE_INVALIDPARAM);
  DBIERR_INVALIDHNDL            = (ERRBASE_INVALIDREQ + ERRCODE_INVALIDHNDL);
  DBIERR_NOSUCHINDEX            = (ERRBASE_INVALIDREQ + ERRCODE_NOSUCHINDEX);
  DBIERR_INVALIDBLOBOFFSET      = (ERRBASE_INVALIDREQ + ERRCODE_INVALIDBLOBOFFSET);
  DBIERR_INVALIDRECSTRUCT       = (ERRBASE_INVALIDREQ + ERRCODE_INVALIDRECSTRUCT);
  DBIERR_NOSUCHTABLE            = (ERRBASE_INVALIDREQ + ERRCODE_NOSUCHTABLE);
  DBIERR_NOSUCHFILTER           = (ERRBASE_INVALIDREQ + ERRCODE_NOSUCHFILTER);
{ ERRCAT_SECURITY }
{ =============== }
  ERRCODE_NOTSUFFTABLERIGHTS    = 2;      { Not sufficient table  rights for operation }
  DBIERR_NOTSUFFTABLERIGHTS     = (ERRBASE_SEC + ERRCODE_NOTSUFFTABLERIGHTS);
{ ERRCAT_INVALIDCONTEXT }
{ ===================== }
  ERRCODE_NOTABLOB              = 1;      { Field is not a blob }
  ERRCODE_TABLEREADONLY         = 11;     { 0x0b Table is read only }
  ERRCODE_NOASSOCINDEX          = 12;     { 0x0c No index associated with the cursor }
  DBIERR_NOTABLOB               = (ERRBASE_IC + ERRCODE_NOTABLOB);
  DBIERR_TABLEREADONLY          = (ERRBASE_IC + ERRCODE_TABLEREADONLY);
  DBIERR_NOASSOCINDEX           = (ERRBASE_IC + ERRCODE_NOASSOCINDEX);
{ ERRCAT_NETWORK }
{ ERRCAT_QUERY }
{ ============ }
  DBICODE_QRYEMPTY              = 110;    { 0x6e }
  DBIERR_QRYEMPTY               = (ERRBASE_QUERY+ DBICODE_QRYEMPTY);
{ END_OF_QUERY_MESSAGES }

{ ERRCAT_CAPABILITY }
{ ================= }
  ERRCODE_NOTSUPPORTED          = 1;      { Capability not supported }
  DBIERR_NOTSUPPORTED           = (ERRBASE_CAPABILITY + ERRCODE_NOTSUPPORTED);
{ ERRCAT_OTHER }
{ ============ }
  ERRCODE_UPDATEABORT           = 6;      { Update operation aborted }
  DBIERR_UPDATEABORT            = (ERRBASE_OTHER + ERRCODE_UPDATEABORT);
  
const
    //Field type constants
     FIELD_TYPE_DECIMAL   = 0;
     FIELD_TYPE_TINY      = 1;
     FIELD_TYPE_SHORT     = 2;
     FIELD_TYPE_LONG      = 3;
     FIELD_TYPE_FLOAT     = 4;
     FIELD_TYPE_DOUBLE    = 5;
     FIELD_TYPE_NULL      = 6;
     FIELD_TYPE_TIMESTAMP = 7;
     FIELD_TYPE_LONGLONG  = 8;
     FIELD_TYPE_INT24     = 9;
     FIELD_TYPE_DATE      = 10;
     FIELD_TYPE_TIME      = 11;
     FIELD_TYPE_DATETIME  = 12;
     FIELD_TYPE_YEAR      = 13;
     FIELD_TYPE_NEWDATE   = 14;
     FIELD_TYPE_NEWDECIMAL= 246; //:CN 04/05/2005
     FIELD_TYPE_ENUM      = 247;
     FIELD_TYPE_SET       = 248;
     FIELD_TYPE_TINY_BLOB = 249;
     FIELD_TYPE_MEDIUM_BLOB = 250;
     FIELD_TYPE_LONG_BLOB = 251;
     FIELD_TYPE_BLOB      = 252;
     FIELD_TYPE_VAR_STRING = 253;
     FIELD_TYPE_STRING     = 254;
     FIELD_TYPE_CHAR = FIELD_TYPE_TINY;      // For compability
     FIELD_TYPE_INTERVAL = FIELD_TYPE_ENUM;  // For compability

/////////////////////////////////////////////////////////////////////////////////
//   BDE TYPE                                                                  //
/////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------//
//     DBI types                                                         //
//-----------------------------------------------------------------------//

const
  DBIMAXNAMELEN      = 63;{31;}         { Name limit (table, field etc) }
  DBIMAXFLDSINKEY    = 16;              { Max fields in a key }
  DBIMAXKEYEXPLEN    = 220;             { Max Key expression length }
  DBIMAXEXTLEN       = 3;               { Max file extension len, not incl. dot (excluding zero termination) }
  DBIMAXTBLNAMELEN   = 260;             { Max table name length }
  DBIMAXPATHLEN      = 260;             { Max path+file name len (excluding zero termination) }
  DBIMAXMSGLEN       = 127;             { Max message len }
  DBIMAXVCHKLEN      = 255;             { Max val check len }
  DBIMAXPICTLEN      = 175;             { Max picture len }
  DBIMAXFLDSINSEC    = 256;             { Max fields in security spec }

Type
//============================================================================//
//                             G e n e r a l                                  //
//============================================================================//
  DBIDATE            = Longint;
  TIME               = Longint;
  DBIResult          = Word;         { Function result }
  TypedEnum          = Integer;

  _hDBIObj           = record end;      { Dummy structure to create "typed" handles }
  hDBIObj            = ^_hDBIObj;       { Generic object handle }
  hDBIDb             = ^_hDBIObj;       { Database handle }
  hDBIStmt           = ^_hDBIObj;       { Statement handle ("new query") }
  hDBICur            = ^_hDBIObj;       { Cursor handle }
  hDBIXact           = ^_hDBIObj;       { Transaction handle }
  hDBIFilter         = ^_hDBIObj;       { Filter handle }


{ Handle Pointers }
  phDBIDb            = ^hDBIDb;         { Pointer to Database handle }
  phDBICur           = ^hDBICur;        { Pointer to Cursor handle }


{ typedefs for buffers of various common sizes: }
  DBIPATH            = packed array [0..DBIMAXPATHLEN] of Char; { holds a DOS path }
  DBINAME            = packed array [0..DBIMAXNAMELEN] of Char; { holds a name }
  DBIEXT             = packed array [0..DBIMAXEXTLEN] of Char; { holds an extension EXT }
  DBITBLNAME         = packed array [0..DBIMAXTBLNAMELEN] of Char; { holds a table name }
  DBIKEY             = packed array [0..DBIMAXFLDSINKEY-1] of Word; { holds list of fields in a key }
  DBIKEYEXP          = packed array [0..DBIMAXKEYEXPLEN] of Char; { holds a key expression }
  DBIVCHK            = packed array [0..DBIMAXVCHKLEN] of Byte; { holds a validity check }
  DBIPICT            = packed array [0..DBIMAXPICTLEN] of Char; { holds a picture (Pdox) }
  DBIMSG             = packed array [0..DBIMAXMSGLEN] of Char; { holds an error message }


//============================================================================//
//                         Basic Query Types                                  //
//============================================================================//
  DBIQryLang = (
    qrylangUNKNOWN,                     { UNKNOWN (Error) }
    qrylangQBE,                         { QBE }
    qrylangSQL                          { SQL }
  );


//============================================================================//
//                   General properties  DbiGetProp/DbiSetProp                //
//============================================================================//
{ Cursor properties }
{ General           }

const
  curMAXPROPS        = $00050000;       { ro UINT16   , Number of defined properties }
  curTABLELEVEL      = $00050003;       { ro UINT16   , Table level 1..n }
  curXLTMODE         = $00050005;       { rw XLTMode  , Translate mode }
  curMAXFIELDID      = $0005000F;       { ro UINT16, Max # of field desc }
  curFIELDFULLNAME   = $00050010;       { ro pObjAttrDesc, Object attribute name }
  curFIELDTYPENAME   = $00050011;       { ro pObjTypeDesc, Object Type name }
  curMAKECRACK       = $00050014;       { Create a crack at the current cursor position }
  curFIELDISAUTOINCR = $00050015;       { wo BOOL, Auto increment field }
  curFIELDISDEFAULT  = $00050016;       { wo BOOL, Default field }
  curAUTOREFETCH     = $00050017;       { rw BOOL, Refetch inserted record }

  maxcurPROPS        = 23;              { keep in sync when adding cursor properties }

{ SQL Driver specific }
  curUPDLOCKMODE     = $04050000;       { rw UPDLockMode, Update lock mode }
  curGETHIDDENCOLUMNS= $04050004;       { rw BOOL , Get all selected columns from server. }
{ Delayed Updates Specific. }
  curDELAYUPDDISPLAYOPT   = $05050003;  { rw UINT16, view records }
  curDELAYUPDGETOLDRECORD = $05050004;  { rw BOOL, get un-modified }
  curDELAYUPDNUMUPDATES   = $05050005;  { ro INT32, num of updates }
{ Database properties }
{ General             }
  dbDATABASETYPE     = $00040002;       { ro pDBINAME , Database type }
  dbPARAMFMTQMARK    = $00040004;       { rw BOOL     , Stmt param marker fmt = ? }
  dbUSESCHEMAFILE    = $00040005;       { rw BOOL , for text driver only. }

{ SQL Driver specific }
  dbCOMPRESSARRAYFLDDESC  = $04040011;  { rw BOOL, VARRAY in compressed format, ORACLE 8 specific. }

{ Statement properties }
{ General              }
  stmtUNIDIRECTIONAL = $00060010;       { rw BOOL        Cursor Unidirectional }
  stmtROWCOUNT       = $00060014;       { ro UINT32      Rows effected by a stmt }

{ specific to QBE or local SQL }
  stmtLIVENESS       = $00060021;       { rw LIVENESS    Preference for canned/live answers }
  stmtAUXTBLS        = $00060026;       { rw BOOL        True if QBE to create CHANGED, etc. }
  stmtCANNEDREADONLY = $00060042;       { rw BOOL canned answers are readonly }




//============================================================================//
//                    Transactions                                            //
//============================================================================//
type
  eXILType = (                          { Transaction isolation levels }
    xilDIRTYREAD,                       { Uncommitted changes read }
    xilREADCOMMITTED,                   { Committed changes, no phantoms }
    xilREPEATABLEREAD                   { Full read repeatability }
  );

  eXEnd = (                             { Transaction end control }
    xendCOMMIT,                         { Commit transaction }
    xendCOMMITKEEP,                     { Commit transaction, keep cursors }
    xendABORT                           { Rollback transaction }
  );

  eXState = (                           { Transaction end control }
    xsINACTIVE,                         { Transaction inactive }
    xsACTIVE                            { Transaction active }
  );

  pXInfo = ^XInfo;
  XInfo = packed record
    exState         : eXState;          { xsActive, xsInactive }
    eXIL            : eXILType;         { Xact isolation level }
    uNests          : Word;             { Xact children }
  end;

//============================================================================//
//                    Object types                                            //
//============================================================================//

type
  DBIOBJType = (
    objFILLER,                          { Filler to make next start at 1 }
    objSYSTEM,                          { System object }
    objSESSION,                         { Session object }
    objDRIVER,                          { Driver object }
    objDATABASE,                        { Database object }
    objCURSOR,                          { Cursor object }
    objSTATEMENT,                       { Statement object }
    objCLIENT,                          { Client object }
    objDBSEC,                           { DbSystem object (dBASE only) }
    objREPOSITORY                       { Data Repository object }
  );

  pObjAttrDesc = ^ObjAttrDesc;
  ObjAttrDesc = packed record
    iFldNum    : Word;                  { Field id }
    pszAttributeName : PChar;           { Object attribute name }
  end;

  pObjTypeDesc = ^ObjTypeDesc;
  ObjTypeDesc = packed record
    iFldNum    : Word;                  { Field id }
    szTypeName : DBINAME;               { Object type name }
  end;



//============================================================================//
//                    Cursor properties                                       //
//============================================================================//

type
  DBIShareMode = (                      { Database/Table Share type }
    dbiOPENSHARED,                      { Open shared  (Default) }
    dbiOPENEXCL                         { Open exclusive }
  );

  DBIOpenMode = (                       { Database/Table Access type }
    dbiREADWRITE,                       { Read + Write   (Default) }
    dbiREADONLY                         { Read only }
  );

  DBILockType = (                       { Lock types (Table level) }
    dbiNOLOCK,                          { No lock   (Default) }
    dbiWRITELOCK,                       { Write lock }
    dbiREADLOCK                         { Read lock }
  );

  XLTMode = (                           { Field translate mode }
    xltNONE,                            { No translation  (Physical Types) }
    xltRECORD,                          { Record level translation (not supported) }
    xltFIELD                            { Field level translation (Logical types) }
  );

  pServerColDesc = ^ServerColDesc;
  ServerColDesc = packed record         { Auto increment and Defaults property }
   iFldNum     : Word;                  { Field id }
   bServerCol  : WordBool;              { Auto Increment and Default }
  end;


type
  pCURProps = ^CURProps;
  CURProps = packed record              { Virtual Table properties }
    szName          : DBITBLNAME;       { table name (no extension, if it can be derived) }
    iFNameSize      : Word;             { Full file name size }
    szTableType     : DBINAME;          { Driver type }
    iFields         : Word;             { No of fields in Table }
    iRecSize        : Word;             { Record size (logical record) }
    iRecBufSize     : Word;             { Record size (physical record) }
    iKeySize        : Word;             { Key size }
    iIndexes        : Word;             { Number of indexes }
    iValChecks      : Word;             { Number of val checks }
    iRefIntChecks   : Word;             { Number of Ref Integrity constraints }
    iBookMarkSize   : Word;             { Bookmark size }
    bBookMarkStable : WordBool;         { Stable book marks }
    eOpenMode       : DBIOpenMode;      { ReadOnly / RW }
    eShareMode      : DBIShareMode;     { Excl / Share }
    bIndexed        : WordBool;         { Index is in use }
    iSeqNums        : SmallInt;         { 1: Has Seqnums; 0: Has Record# }
    bSoftDeletes    : WordBool;         { Supports soft deletes }
    bDeletedOn      : WordBool;         { If above, deleted recs seen }
    iRefRange       : Word;             { Not used }
    exltMode        : XLTMode;          { Translate Mode }
    iRestrVersion   : Word;             { Restructure version number }
    bUniDirectional : WordBool;         { Cursor is uni-directional }
    eprvRights      : Word;             { Table  rights }
    Dummy4          : Word;
    iFmlRights      : Word;             { Family rights }
    iPasswords      : Word;             { Number of Aux passwords }
    iCodePage       : Word;             { Codepage (0 if unknown) }
    bProtected      : WordBool;         { Table is protected by password }
    iTblLevel       : Word;             { Driver dependent table level }
    szLangDriver    : DBINAME;          { Language driver name }
    bFieldMap       : WordBool;         { Field map active }
    iBlockSize      : Word;             { Physical file blocksize in K }
    bStrictRefInt   : WordBool;         { Strict referential integrity }
    iFilters        : Word;             { Number of filters }
    bTempTable      : WordBool;         { Table is a temporary table }
    iUnUsed         : packed array [0..15] of Word;
  end;

//Delayed Update Types and Constants }

type
  DBIDelayedUpdCmd = (                  { Op types for Delayed Update cursor }
    dbiDelayedUpdCommit,                { Commit the updates }
    dbiDelayedUpdCancel,                { Rollback the updates }
    dbiDelayedUpdCancelCurrent,         { Cancel the Current Rec Change }
    dbiDelayedUpdPrepare                { Phase1 of 2 phase commit }
  );

//============================================================================//
//                   Record Properties                                        //
//============================================================================//

type
  pRECProps = ^RECProps;
  RECProps = packed record              { Record properties }
    iSeqNum         : Longint;          { When Seq# supported only }
    iPhyRecNum      : Longint;          { When Phy Rec#s supported only }
    iRecStatus      : Word;             { Delayed Updates Record Status }
    bSeqNumChanged  : WordBool;         { Not used }
    bDeleteFlag     : WordBool;         { When soft delete supported only }
  end;

//============================================================================//
//                    Blob parameter descriptor                               //
//============================================================================//

type
  pBLOBParamDesc = ^BLOBParamDesc;
  BLOBParamDesc = packed record
    pBlobBuffer     : Pointer;          { Blob buffer (client) }
    ulBlobLen       : Integer;          { Length of the blob }
    iUnUsed         : packed array[0..3] of Word;
  end;


//============================================================================//
//                    Index descriptor                                        //
//============================================================================//

type
  pIDXDesc = ^IDXDesc;
  IDXDesc = packed record               { Index description }
    szName          : DBITBLNAME;       { Index name }
    iIndexId        : Word;             { Index number }
    szTagName       : DBINAME;          { Tag name (for dBASE) }
    szFormat        : DBINAME;          { Optional format (BTREE, HASH etc) }
    bPrimary        : WordBool;         { True, if primary index }
    bUnique         : WordBool;         { True, if unique keys (TRI-STATE for dBASE) }
    bDescending     : WordBool;         { True, for descending index }
    bMaintained     : WordBool;         { True, if maintained index }
    bSubset         : WordBool;         { True, if subset index }
    bExpIdx         : WordBool;         { True, if expression index }
    iCost           : Word;             { Not used }
    iFldsInKey      : Word;             { Fields in the key (1 for Exp) }
    iKeyLen         : Word;             { Phy Key length in bytes (Key only) }
    bOutofDate      : WordBool;         { True, if index out of date }
    iKeyExpType     : Word;             { Key type of Expression }
    aiKeyFld        : DBIKEY;           { Array of field numbers in key }
    szKeyExp        : DBIKEYEXP;        { Key expression }
    szKeyCond       : DBIKEYEXP;        { Subset condition }
    bCaseInsensitive : WordBool;        { True, if case insensitive index }
    iBlockSize      : Word;             { Block size in bytes }
    iRestrNum       : Word;             { Restructure number }
    abDescending    : packed array [0..DBIMAXFLDSINKEY-1] of WordBool; { TRUE }
    iUnUsed         : packed array [0..15] of Word;
  end;

//============================================================================//
//                             Table / Field Types                            //
//============================================================================//
const
{ Field Types (Logical) }
  fldUNKNOWN         = 0;
  fldZSTRING         = 1;               { Null terminated string }
  fldDATE            = 2;               { Date     (32 bit) }
  fldBLOB            = 3;               { Blob }
  fldBOOL            = 4;               { Boolean  (16 bit) }
  fldINT16           = 5;               { 16 bit signed number }
  fldINT32           = 6;               { 32 bit signed number }
  fldFLOAT           = 7;               { 64 bit floating point }
  fldBCD             = 8;               { BCD }
  fldBYTES           = 9;               { Fixed number of bytes }
  fldTIME            = 10;              { Time        (32 bit) }
  fldTIMESTAMP       = 11;              { Time-stamp  (64 bit) }
  fldUINT16          = 12;              { Unsigned 16 bit integer }
  fldUINT32          = 13;              { Unsigned 32 bit integer }
  fldFLOATIEEE       = 14;              { 80-bit IEEE float }
  fldVARBYTES        = 15;              { Length prefixed var bytes }
  fldLOCKINFO        = 16;              { Look for LOCKINFO typedef }
  fldCURSOR          = 17;              { For Oracle Cursor type }
  fldINT64           = 18;              { 64 bit signed number }
  fldUINT64          = 19;              { Unsigned 64 bit integer }
  fldADT             = 20;              { Abstract datatype (structure) }
  fldARRAY           = 21;              { Array field type }
  fldREF             = 22;              { Reference to ADT }
  fldTABLE           = 23;              { Nested table (reference) }
  {$IFDEF DELPHI_6}
  fldDATETIME        = 24;              { DateTime structure field }

  MAXLOGFLDTYPES     = 25;              { Number of logical fieldtypes }
  {$ELSE}
  MAXLOGFLDTYPES     = 24;              { Number of logical fieldtypes }
  {$ENDIF}


{ Sub Types (Logical) }

{ fldFLOAT subtype }

  fldstMONEY         = 21;              { Money }

{ fldBLOB subtypes }

  fldstMEMO          = 22;              { Text Memo }
  fldstBINARY        = 23;              { Binary data }
  fldstFMTMEMO       = 24;              { Formatted Text }
  fldstOLEOBJ        = 25;              { OLE object (Paradox) }
  fldstGRAPHIC       = 26;              { Graphics object }
  fldstDBSOLEOBJ     = 27;              { dBASE OLE object }
  fldstTYPEDBINARY   = 28;              { Typed Binary data }
  fldstACCOLEOBJ     = 30;              { Access OLE object }
  fldstHMEMO         = 33;              { CLOB }
  fldstHBINARY       = 34;              { BLOB }
  fldstBFILE         = 36;              { BFILE }

{ fldZSTRING subtype }

  fldstPASSWORD      = 1;               { Password }
  fldstFIXED         = 31;              { CHAR type }
  fldstUNICODE       = 32;              { Unicode }

{ fldINT32 subtype }
  fldstAUTOINC       = 29;

{ fldADT subtype }

  fldstADTNestedTable = 35;             { ADT for nested table (has no name) }

{ fldDATE subtype }
  fldstADTDATE       = 37;              { DATE (OCIDate ) with in an ADT }

//============================================================================//
//                    Field descriptor                                        //
//============================================================================//
type
  FLDVchk = (                           { Field Val Check type }
    fldvNOCHECKS,                       { Does not have explicit val checks }
    fldvHASCHECKS,                      { One or more val checks on the field }
    fldvUNKNOWN                         { Dont know at this time }
  );

  FLDRights = (                         { Field Rights }
    fldrREADWRITE,                      { Field can be Read/Written }
    fldrREADONLY,                       { Field is Read only }
    fldrNONE,                           { No Rights on this field }
    fldrUNKNOWN                         { Dont know at this time }
  );

  pFLDDesc = ^FLDDesc;
  FLDDesc = packed record               { Field Descriptor }
    iFldNum         : Word;             { Field number (1..n) }
    szName          : DBINAME;          { Field name }
    iFldType        : Word;             { Field type }
    iSubType        : Word;             { Field subtype (if applicable) }
    iUnits1         : SmallInt;         { Number of Chars, digits etc }
    iUnits2         : SmallInt;         { Decimal places etc. }
    iOffset         : Word;             { Offset in the record (computed) }
    iLen            : Word;             { Length in bytes (computed) }
    iNullOffset     : Word;             { For Null bits (computed) }
    efldvVchk       : FLDVchk;          { Field Has vcheck (computed) }
    efldrRights     : FLDRights;        { Field Rights (computed) }
    bCalcField      : WordBool;         { Is Calculated field (computed) }
    iUnUsed         : packed array [0..1] of Word;
  end;


//============================================================================//
//             Validity check, Referential integrity descriptors              //
//============================================================================//
// Subtypes for Lookup
  LKUPType = (                          { Paradox Lookup type }
    lkupNONE,                           { Has no lookup }
    lkupPRIVATE,                        { Just Current Field + Private }
    lkupALLCORRESP,                     { All Corresponding + No Help }
    lkupHELP,                           { Just Current Fld + Help and Fill }
    lkupALLCORRESPHELP                  { All Corresponging + Help }
  );

  pVCHKDesc = ^VCHKDesc;
  VCHKDesc = packed record              { Val Check structure }
    iFldNum         : Word;             { Field number }
    bRequired       : WordBool;         { If True, value is required }
    bHasMinVal      : WordBool;         { If True, has min value }
    bHasMaxVal      : WordBool;         { If True, has max value }
    bHasDefVal      : WordBool;         { If True, has default value }
    aMinVal         : DBIVCHK;          { Min Value }
    aMaxVal         : DBIVCHK;          { Max Value }
    aDefVal         : DBIVCHK;          { Default value }
    szPict          : DBIPICT;          { Picture string }
    elkupType       : LKUPType;         { Lookup/Fill type }
    szLkupTblName   : DBIPATH;          { Lookup Table name }
  end;

  RINTType = (                          { Ref integrity type }
    rintMASTER,                         { This table is Master }
    rintDEPENDENT                       { This table is Dependent }
  );

  RINTQual = (                          { Ref integrity action/qualifier }
    rintRESTRICT,                       { Prohibit operation }
    rintCASCADE                         { Cascade operation }
  );

  pRINTDesc = ^RINTDesc;
  RINTDesc = packed record              { Ref Integrity Desc }
    iRintNum        : Word;             { Ref integrity number }
    szRintName      : DBINAME;          { A name to tag this integegrity constraint }
    eType           : RINTType;         { Whether master/dependent }
    szTblName       : DBIPATH;          { Other table name }
    eModOp          : RINTQual;         { Modify qualifier }
    eDelOp          : RINTQual;         { Delete qualifier }
    iFldCount       : Word;             { Fields in foreign key }
    aiThisTabFld    : DBIKEY;           { Fields in this table }
    aiOthTabFld     : DBIKEY;           { Fields in other table }
  end;


//============================================================================//
//                    Security descriptor                                     //
//============================================================================//
type
  PRVType = TypedEnum;
const
    prvUNKNOWN   = $FF;                 { Unknown }

type
  pSECDesc = ^SECDesc;
  SECDesc = packed record               { Security description }
    iSecNum         : Word;             { Nbr to identify desc }
    eprvTable       : PrvType;          { Table privileges }
    iFamRights      : Word;             { Family rights }
    szPassword      : DBINAME;          { Null terminated string }
    aprvFld         : packed array [0..DBIMAXFLDSINSEC-1] of PrvType;
                     { Field level privileges (prvNONE/prvREADONLY/prvFULL) }
  end;

//============================================================================//
//                            Miscellaneous                                   //
//============================================================================//

{ Index Id used to open table without a default index (i.e. no order) }
const
  NODEFAULTINDEX     = $FFFF;


//============================================================================//
//                         BookMark compares                                  //
//============================================================================//

type
  PCMPBkMkRslt = ^CMPBkMkRslt;
  CMPBkMkRslt = TypedEnum;
const
    CMPLess           = -1;             { Bkm1 < Bkm2 }
    CMPEql            = 0;              { BookMarks are exactly the same }
    CMPGtr            = 1;              { Bkm1 > Bkm2 }
    CMPKeyEql         = 2;              { Only Bkm1.key_val = Bkm2.key_val }


{============================================================================}
{                             Key searches                                   }
{============================================================================}

type
  DBISearchCond = (                     { Search condition for keys }
    keySEARCHEQ,                        { = }
    keySEARCHGT,                        { > }
    keySEARCHGEQ                        { >= }
  );


//============================================================================//
//                      Create/Restructure descriptor                         //
//============================================================================//
type
  pCROpType          = ^CROpType;
  CROpType = (                          { Create/Restruct Operation type }
    crNOOP,
    crADD,                              { Add a new element. }
    crCOPY,                             { Copy an existing element. }
    crMODIFY,                           { Modify an element. }
    crDROP,                             { Removes an element. }
    crREDO,                             { Reconstruct an element. }
    crTABLE,                            { Not used }
    crGROUP,                            { Not used }
    crFAMILY,                           { Not used }
    crDONE,                             { Used internally }
    crDROPADD                           { Used internally }
  );

  pCRTblDesc         = ^CRTblDesc;
  CRTblDesc = packed record             { Create/Restruct Table descr }
    szTblName       : DBITBLNAME;       { TableName incl. optional path & ext }
    szTblType       : DBINAME;          { Driver type (optional) }
    szErrTblName    : DBIPATH;          { Error Table name (optional) }
    szUserName      : DBINAME;          { User name (if applicable) }
    szPassword      : DBINAME;          { Password (optional) }
    bProtected      : WordBool;         { Master password supplied in szPassword }
    bPack           : WordBool;         { Pack table (restructure only) }
    iFldCount       : Word;             { Number of field defs supplied }
    pecrFldOp       : pCROpType;        { Array of field ops }
    pfldDesc        : pFLDDesc;         { Array of field descriptors }
    iIdxCount       : Word;             { Number of index defs supplied }
    pecrIdxOp       : pCROpType;        { Array of index ops }
    pidxDesc        : PIDXDesc;         { Array of index descriptors }
    iSecRecCount    : Word;             { Number of security defs supplied }
    pecrSecOp       : pCROpType;        { Array of security ops }
    psecDesc        : pSECDesc;         { Array of security descriptors }
    iValChkCount    : Word;             { Number of val checks }
    pecrValChkOp    : pCROpType;        { Array of val check ops }
    pvchkDesc       : pVCHKDesc;        { Array of val check descs }
    iRintCount      : Word;             { Number of ref int specs }
    pecrRintOp      : pCROpType;        { Array of ref int ops }
    printDesc       : pRINTDesc;        { Array of ref int specs }
    iOptParams      : Word;             { Number of optional parameters }
    pfldOptParams   : pFLDDesc;         { Array of field descriptors }
    pOptData        : Pointer;          { Optional parameters }
  end;

//============================================================================//
//                    Filter description                                      //
//============================================================================//

type
  pCANOp = ^CANOp;
  CANOp  = (
    canNOTDEFINED,                      {                                  (*) }
    canISBLANK,                         { CANUnary;  is operand blank.     (*) }
    canNOTBLANK,                        { CANUnary;  is operand not blank. (*) }
    canEQ,                              { CANBinary, CANCompare; equal.    (*) }
    canNE,                              { CANBinary; NOT equal.            (*) }
    canGT,                              { CANBinary; greater than.         (*) }
    canLT,                              { CANBinary; less than.            (*) }
    canGE,                              { CANBinary; greater or equal.     (*) }
    canLE,                              { CANBinary; less or equal.        (*) }
    canNOT,                             { CANUnary; NOT                    (*) }
    canAND,                             { CANBinary; AND                   (*) }
    canOR,                              { CANBinary; OR                    (*) }
    canTUPLE2,                          { CANUnary; Entire record is operand. }
    canFIELD2,                          { CANUnary; operand is field       (*) }
    canCONST2,                          { CANUnary; operand is constant    (*) }
    canMINUS,                           { CANUnary;  minus. }
    canADD,                             { CANBinary; addition. }
    canSUB,                             { CANBinary; subtraction. }
    canMUL,                             { CANBinary; multiplication. }
    canDIV,                             { CANBinary; division. }
    canMOD,                             { CANBinary; modulo division. }
    canREM,                             { CANBinary; remainder of division. }
    canSUM,                             { CANBinary, accumulate sum of. }
    canCOUNT,                           { CANBinary, accumulate count of. }
    canMIN,                             { CANBinary, find minimum of. }
    canMAX,                             { CANBinary, find maximum of. }
    canAVG,                             { CANBinary, find average of. }
    canCONT,                            { CANBinary; provides a link between two }
    canUDF2,                            { CANBinary; invokes a User defined fn }
    canCONTINUE2,                       { CANUnary; Stops evaluating records }
    canLIKE,                            { CANCompare, extended binary compare       (*) }
    canIN,                              { CANBinary field in list of values }
    canLIST2,                           { List of constant values of same type }
    canUPPER,                           { CANUnary: upper case }
    canLOWER,                           { CANUnary: lower case }
    canFUNC2,                           { CANFunc: Function }
    canLISTELEM2,                       { CANListElem: List Element }
    canASSIGN                           { CANBinary: Field assignment }
  );

  NODEClass = (                         { Node Class }
    nodeNULL,                           { Null node                  (*) }
    nodeUNARY,                          { Node is a unary            (*) }
    nodeBINARY,                         { Node is a binary           (*) }
    nodeCOMPARE,                        { Node is a compare          (*) }
    nodeFIELD,                          { Node is a field            (*) }
    nodeCONST,                          { Node is a constant         (*) }
    nodeTUPLE,                          { Node is a record }
    nodeCONTINUE,                       { Node is a continue node    (*) }
    nodeUDF,                            { Node is a UDF node }
    nodeLIST,                           { Node is a LIST node }
    nodeFUNC,                           { Node is a Function node }
    nodeLISTELEM                        { Node is a List Element node }
  );

// NODE definitions including misc data structures //
//-------------------------------------------------//

type
  pCANHdr = ^CANHdr;
  CANHdr = packed record                { Header part common to all     (*) }
    nodeClass       : NODEClass;
    canOp           : CANOp;
  end;

  pCANUnary = ^CANUnary;
  CANUnary = packed record              { Unary Node                    (*) }
    nodeClass       : NODEClass;
    canOp           : CANOp;
    iOperand1       : Word;             { Byte offset of Operand node }
  end;

  pCANBinary = ^CANBinary;
  CANBinary = packed record             { Binary Node                   (*) }
    nodeClass       : NODEClass;
    canOp           : CANOp;
    iOperand1       : Word;             { Byte offset of Op1 }
    iOperand2       : Word;             { Byte offset of Op2 }
  end;

  pCANField = ^CANField;
  CANField = packed record              { Field }
    nodeClass       : NODEClass;
    canOp           : CANOp;
    iFieldNum       : Word;
    iNameOffset     : Word;             { Name offset in Literal pool }
  end;

  pCANConst = ^CANConst;
  CANConst = packed record              { Constant }
    nodeClass       : NODEClass;
    canOp           : CANOp;
    iType           : Word;             { Constant type. }
    iSize           : Word;             { Constant size. (in bytes) }
    iOffset         : Word;             { Offset in the literal pool. }
  end;

  pCANTuple = ^CANTuple;
  CANTuple = packed record              { Tuple (record) }
    nodeClass       : NODEClass;
    canOp           : CANOp;
    iSize           : Word;             { Record size. (in bytes) }
  end;

  pCANContinue = ^CANContinue;
  CANContinue = packed record           { Break Node                    (*) }
    nodeClass       : NODEClass;
    canOp           : CANOp;
    iContOperand    : Word;             { Continue if operand is true. }
  end;

  pCANCompare = ^CANCompare;
  CANCompare = packed record            { Extended compare Node (text fields) (*) }
    nodeClass       : NODEClass;
    canOp           : CANOp;            { canLIKE, canEQ }
    bCaseInsensitive : WordBool;        { 3 val: UNKNOWN = "fastest", "native" }
    iPartialLen     : Word;             { Partial fieldlength (0 is full length) }
    iOperand1       : Word;             { Byte offset of Op1 }
    iOperand2       : Word;             { Byte offset of Op2 }
  end;

  pCANFunc = ^CANFunc;
  CANFunc = packed record               { Function }
    nodeClass       : NODEClass;
    canOp           : CANOp;
    iNameOffset     : Word;             { Name offset in Literal pool }
    iElemOffset     : Word;             { Offset of first List Element in Node pool }
  end;

  pCANListElem = ^CANListElem;
  CANListElem = packed record           { List Element }
    nodeClass       : NODEClass;
    canOp           : CANOp;
    iOffset         : Word;             { Arg offset in Node pool }
    iNextOffset     : Word;             { Offset in Node pool of next ListElem or 0 if end of list }
  end;

  pCANList = ^CANList;
  CANList = packed record           { List of Constants }
    nodeClass       : NODEClass;
    canOp           : CANOp;
    iType           : Word;            { Constant type. }
    iTotalSize      : Word;            { Total list size; }
    iElemSize       : Word;            { Size of each elem for fix-width types }
    iElems          : Word;            { Number of elements in list }
    iOffset         : Word;            { Offset in the literal pool to first elem. }
  end;

  pCANNode = ^CANNode;
  CANNode = packed record
    case Integer of
      0: (canHdr      : CANHdr);
      1: (canUnary    : CANUnary);
      2: (canBinary   : CANBinary);
      3: (canField    : CANField);
      4: (canConst    : CANConst);
      5: (canTuple    : CANTuple);
      6: (canContinue : CANContinue);
      7: (canCompare  : CANCompare);
      8: (canList     : CANList);
      9: (canFunc     : CANFunc);
     10: (canListElem : CANListElem);
  end;

type
  ppCANExpr = ^pCANExpr;
  pCANExpr  = ^CANExpr;
  CANExpr   = packed record             { Expression Tree }
    iVer            : Word;             { Version tag of expression. }
    iTotalSize      : Word;             { Size of this structure }
    iNodes          : Word;             { Number of nodes }
    iNodeStart      : Word;             { Starting offet of Nodes in this }
    iLiteralStart   : Word;             { Starting offset of Literals in this }
  end;

  pfGENFilter = function (
      ulClientData  : Longint;
      pRecBuf       : Pointer;
      iPhyRecNum    : Longint
   ): SmallInt stdcall;

//----------------------------------------------------------------------------//
//   DBI Query related types                                                  //
//----------------------------------------------------------------------------//

  LIVENESS = (
    wantDEFAULT,                        { Default , same as wantCANNED }
    wantLIVE,                           { Want live data even if extra effort (no guarantee) }
    wantCANNED,                         { Want canned data even if extra effort (guaranteed) }
    wantSPEED                           { Let query manager decide, find out afterwards }
  );

//============================================================================//
//                    Table descriptor                                        //
//============================================================================//
type
  pTBLBaseDesc = ^TBLBaseDesc;
  TBLBaseDesc = packed record           { Table description (Base) }
    szName          : DBITBLNAME;       { Table name(No extension or Dir) }
    szFileName      : DBITBLNAME;       { File name }
    szExt           : DBIEXT;           { File extension }
    szType          : DBINAME;          { Driver type }
    dtDate          : DBIDATE;          { Date on the table }
    tmTime          : Time;             { Time on the table }
    iSize           : Longint;          { Size in bytes }
    bView           : WordBool;         { If this a view }
    bSynonym        : WordBool;         { If this is a synonym }
  end;

//============================================================================//
//                                Call Backs                                  //
//============================================================================//
type
  pCBType            = ^CBType;
  CBType = (                            { Call back type }
    cbGENERAL,                          { General purpose }
    cbRESERVED1,
    cbRESERVED2,
    cbINPUTREQ,                         { Input requested }
    cbRESERVED4,
    cbRESERVED5,
    cbBATCHRESULT,                      { Batch processing rslts }
    cbRESERVED7,
    cbRESTRUCTURE,                      { Restructure }
    cbRESERVED9,
    cbRESERVED10,
    cbRESERVED11,
    cbRESERVED12,
    cbRESERVED13,
    cbRESERVED14,
    cbRESERVED15,
    cbRESERVED16,
    cbRESERVED17,
    cbTABLECHANGED,                     { Table changed notification }
    cbRESERVED19,
    cbCANCELQRY,                        { Allow user to cancel Query }
    cbSERVERCALL,                       { Server Call }
    cbRESERVED22,
    cbGENPROGRESS,                      { Generic Progress report. }
    cbDBASELOGIN,                       { dBASE Login }
    cbDELAYEDUPD,                       { Delayed Updates }
    cbFIELDRECALC,                      { Field(s) recalculation }
    cbTRACE,                            { Trace }
    cbDBLOGIN,                          { Database login }
    cbDETACHNOTIFY,                     { DLL Detach Notification }
    cbNBROFCBS                          { Number of cbs }
  );

type
  pCBRType           = ^CBRType;
  CBRType = (                           { Call-back return type }
    cbrUSEDEF,                          { Take default action }
    cbrCONTINUE,                        { Continue }
    cbrABORT,                           { Abort the operation }
    cbrCHKINPUT,                        { Input given }
    cbrYES,                             { Take requested action }
    cbrNO,                              { Do not take requested action }
    cbrPARTIALASSIST,                   { Assist in completing the job }
    cbrSKIP,                            { Skip this operation }
    cbrRETRY                            { Retry this operation }
  );

  ppfDBICallBack = ^pfDBICallBack;
  pfDBICallBack  = function (           { Call-back funtion pntr type }
      ecbType       : CBType;           { Callback type }
      iClientData   : Longint;          { Client callback data }
      CbInfo        : Pointer           { Call back info/Client Input }
   ): CBRType stdcall;

  DelayUpdErrOpType = (                 { type of delayed update object (delayed updates callback) }
    delayupdNONE,
    delayupdMODIFY,
    delayupdINSERT,
    delayupdDELETE
  );

  PDELAYUPDCbDesc = ^DELAYUPDCbDesc;
  DELAYUPDCbDesc = packed record        { delayed updates callback info }
    iErrCode        : DBIResult;
    eDelayUpdOpType : DelayUpdErrOpType;
    iRecBufSize     : Word;             { Record size (physical record) }
    pNewRecBuf      : Pointer;
    pOldRecBuf      : Pointer;
  end;



const
     DELIMITERS           = ' .:;,+-<>/*%^=()[]|&~@#$\`{}!?'#10#13;


/////////////////////////////////////////////////////////////////////////////
//          VARIABLE DEFINITION TYPES                                      //
/////////////////////////////////////////////////////////////////////////////
type
    TFieldArray = array[0..255] of Integer;
    TTrueArray = Set of Char;
    TFalseArray = Set of Char;
/////////////////////////////////////////////////////////////////////////////
//                        TmySQLFilter TYPES AND CONST                     //
/////////////////////////////////////////////////////////////////////////////
type
  TFldType=(FT_UNK,FT_INT,FT_DATETIME,FT_DATE,FT_TIME, FT_CURRENCY,FT_FLOAT,FT_STRING,FT_BOOL);

  StrRec = record
     allocSiz : Longint;
     refCnt   : Longint;
     length   : Longint;
  end;

  PSmallInt = ^SmallInt;
  PWordBool = ^WordBool;

const
   strsz = sizeof(StrRec);

/////////////////////////////////////////////////////////////////////////////
//            INDEX AND PRIMARY KEY DEFINITIONS                            //
/////////////////////////////////////////////////////////////////////////////
Type
  TPropRec = Record
    Prop  : Word;
    Group : Word;
  end;

  MemPtr       = ^MemArray;
  MemArray     = Array[0..$FFFE] of Byte;

  TBlobItem =  Record
    Blob : TMemoryStream;
  end;

  PmySQLBookMark = ^TmySQLBookMark;
  TmySQLBookMark =   Record
    Position     : Int64;//Longint;
  end;

  PFieldStatus = ^TFieldStatus;
  TFieldStatus =  Record
    isNULL  : SmallInt;
    Changed : Bool;
  end;

  TRecordState = (tsNoPos, tsPos, tsFirst, tsLast, tsEmpty, tsClosed);
  TDir = (tdUndefined, tdNext, tdPrev);

  TDBOptions = Record
    User             : String;
    Password         : String;
    DatabaseName     : String;
    Port             : Cardinal;
    Host             : String;
    TimeOut          : Cardinal;
  end;

  TConnectOption = (coCompress,
                    coFoundRows,
                    coIgnoreSpaces,
                    coInteractive,
                    coNoSchema,
                    coODBC,
                    coSSL);
  TConnectOptions = set of TConnectOption;

/////////////////////////////////////////////////////////////////////////////
//            BASE OBJECTS DEFINITIONS                                     //
/////////////////////////////////////////////////////////////////////////////
  {TContainer Object}
  TContainer = Class(TObject)
    Private
      FItems : TList;
    Public
      Constructor Create;
      Destructor Destroy; Override;
      Function At( Index : integer ) : pointer;
      Procedure AtDelete( Index : integer );
      Procedure AtFree( Index : integer );
      Procedure AtInsert( Index: integer; Item : pointer );
      Procedure AtPut( Index : Integer; Item : Pointer );
      Procedure Clear;
      Procedure Delete( Item : Pointer );
      Procedure DeleteAll;
      Procedure Error( Code, Info : Integer );
      Procedure FreeAll;
      Procedure FreeItem( Item : pointer );
      Function Get( AIndex : integer ) : pointer;
      Function GetCount : integer;
      Function IndexOf( Item : pointer ) : integer;
      Procedure Insert( Item : pointer ); Virtual;
      Procedure Pack;
      Procedure Put( AIndex : integer; APointer : pointer );
      Function GetCapacity : Integer;
      Procedure SetCapacity( NewCapacity : Integer );
      Property Count: integer Read  GetCount;
      Property Items[ index : integer ] : pointer Read  Get Write Put;
      Property Capacity : Integer Read  GetCapacity Write SetCapacity;
  end;

  TBaseObject = Class(TObject)
    Protected
      FParent : TObject;
      FContainer: TContainer;
    Public
      Property Container : TContainer  Read  FContainer  Write FContainer;
      Property Parent : TObject  Read  FParent  Write FParent;
      Constructor Create(P : TObject; Container : TContainer);
      Destructor Destroy; Override;
  end;

//////////////////////////////////////////////////////////
//     Constants for Quick search
//////////////////////////////////////////////////////////
const
  ToUpperChars: array[0..255] of Char =
    (#$00,#$01,#$02,#$03,#$04,#$05,#$06,#$07,#$08,#$09,#$0A,#$0B,#$0C,#$0D,#$0E,#$0F,
     #$10,#$11,#$12,#$13,#$14,#$15,#$16,#$17,#$18,#$19,#$1A,#$1B,#$1C,#$1D,#$1E,#$1F,
     #$20,#$21,#$22,#$23,#$24,#$25,#$26,#$27,#$28,#$29,#$2A,#$2B,#$2C,#$2D,#$2E,#$2F,
     #$30,#$31,#$32,#$33,#$34,#$35,#$36,#$37,#$38,#$39,#$3A,#$3B,#$3C,#$3D,#$3E,#$3F,
     #$40,#$41,#$42,#$43,#$44,#$45,#$46,#$47,#$48,#$49,#$4A,#$4B,#$4C,#$4D,#$4E,#$4F,
     #$50,#$51,#$52,#$53,#$54,#$55,#$56,#$57,#$58,#$59,#$5A,#$5B,#$5C,#$5D,#$5E,#$5F,
     #$60,#$41,#$42,#$43,#$44,#$45,#$46,#$47,#$48,#$49,#$4A,#$4B,#$4C,#$4D,#$4E,#$4F,
     #$50,#$51,#$52,#$53,#$54,#$55,#$56,#$57,#$58,#$59,#$5A,#$7B,#$7C,#$7D,#$7E,#$7F,
     #$80,#$81,#$82,#$81,#$84,#$85,#$86,#$87,#$88,#$89,#$8A,#$8B,#$8C,#$8D,#$8E,#$8F,
     #$80,#$91,#$92,#$93,#$94,#$95,#$96,#$97,#$98,#$99,#$8A,#$9B,#$8C,#$8D,#$8E,#$8F,
     #$A0,#$A1,#$A1,#$A3,#$A4,#$A5,#$A6,#$A7,#$A8,#$A9,#$AA,#$AB,#$AC,#$AD,#$AE,#$AF,
     #$B0,#$B1,#$B2,#$B2,#$A5,#$B5,#$B6,#$B7,#$A8,#$B9,#$AA,#$BB,#$A3,#$BD,#$BD,#$AF,
     #$C0,#$C1,#$C2,#$C3,#$C4,#$C5,#$C6,#$C7,#$C8,#$C9,#$CA,#$CB,#$CC,#$CD,#$CE,#$CF,
     #$D0,#$D1,#$D2,#$D3,#$D4,#$D5,#$D6,#$D7,#$D8,#$D9,#$DA,#$DB,#$DC,#$DD,#$DE,#$DF,
     #$C0,#$C1,#$C2,#$C3,#$C4,#$C5,#$C6,#$C7,#$C8,#$C9,#$CA,#$CB,#$CC,#$CD,#$CE,#$CF,
     #$D0,#$D1,#$D2,#$D3,#$D4,#$D5,#$D6,#$D7,#$D8,#$D9,#$DA,#$DB,#$DC,#$DD,#$DE,#$DF);


/////////////////////////////////////////////////////////////////////////////
//                  COMMON FUNCTIONS                                       //
/////////////////////////////////////////////////////////////////////////////
{ SQL Parser }
type
  TSQLToken = (stUnknown, stTableName, stFieldName, stAscending, stDescending, stSelect,
    stFrom, stWhere, stGroupBy, stHaving, stUnion, stPlan, stOrderBy, stForUpdate,
    stEnd, stPredicate, stValue, stIsNull, stIsNotNull, stLike, stAnd, stOr,
    stNumber, stAllFields, stComment, stDistinct, stCreate, stShow, stInsert,stUpdate,stFor,stFunction);

const
  SQLSections = [stSelect, stFrom, stWhere, stGroupBy, stHaving, stUnion,
    stPlan, stOrderBy, stForUpdate, stShow];
  SQLMofify = [stCreate,stInsert,stUpdate];

var
  ServerVersion : Integer;

function GetVerAsInt(AHandle : TMysqlClient): integer;
function NextSQLToken(var p: PChar; out Token: string; CurSection: TSQLToken): TSQLToken;
function GetShow(const SQL: string): Boolean;
function GetTable(Const SQL: string):String;
function GetTableNamePartFromSQL(const SQL: string): string;
function GetSelectPartFromSQL(const SQL: string): string;
function GetWherePartFromSQL(const SQL: string): string;
function GetOrderByPartFromSQL(const SQL: string): string;
//function mysql_reload(_mysql: PMySQL): longint;
function CompareBegin(Str1, Str2: string): Boolean;
function SqlDateToDateTime(Value: string): TDateTime;
function DateTimeToSqlDate(Value: TDateTime; Mode : integer): string;
function SQLTimeStampToDateTime(Value: string): TDateTime;
function StrToSQLFloat(Value: string): Double;
function SQLFloatToStr(Value: Double): string;
function StrToBool(TrueVal : TTrueArray;FalseVal : TFalsearray;Value : String): boolean;
function BoolToStr(I : smallint;boolstr : string):String;
function TimeOf(const ADateTime: TDateTime): TDateTime;
procedure GetToken(var Buffer, Token: string);
Procedure ConvermySQLtoDelphiFieldInfo(Info : PMysql_FieldDef; Count, Offset : Word; pRecBuff : PFLDDesc; pValChk : pVCHKDesc; EnumVal:String; DefVal : PChar);
function GetNumFromSet(ASet,AValue : String):Integer;

//new Reliase
  { ScanStr находит первое вхождение символа Ch в строку S, начиная с символа
  номер StartPos. Возвращает номер найденного символа или ноль, если символ Ch
  в строке S не найден.}
function ScanStr(const S: string; Ch: Char; StartPos: Integer = 1): Integer;
  { TestMask проверяет, удовлетворяет ли строка S маске Mask, предполагая,
  что символы MaskChar из строки Mask могут быть заменены в строке S любыми
  другими символами. При сравнении регистр символов принимается во внимание.
  Если строка S удовлетворяет маске, функция возвращает True, иначе False.
  Например, Q_TestMask('ISBN 5-09-007017-2','ISBN ?-??-??????-?','?') вернет
  значение True. }
function TestMask(const S, Mask: string; MaskChar: Char = 'X'): Boolean;
  { MaskSearch проверяет, удовлетворяет ли строка S маске Mask, предполагая,
  что символы MaskChar из строки Mask могут быть заменены в строке S любыми
  другими символами, а символы WildCard могут быть заменены любым количеством
  других символов. При сравнении большие и маленькие буквы различаются. Символ
  WildCard должен быть отличен от #0. Если строка S удовлетворяет маске,
  функция возвращает True, иначе False. Например, следующий вызов функции
  вернет True: MaskSearch('abc12345_infQ_XL.dat','abc*_???Q_*.d*at'). }
function MaskSearch(const S, Mask: string; MaskChar: Char = '?'; WildCard: Char = '%'): Boolean;
  { MaskISearch аналогична функции MaskSearch, но регистр символов
  не принимается во внимание (большие и маленькие буквы не различаются). }
function MaskISearch(const S, Mask: string; MaskChar: Char = '?'; WildCard: Char = '%'): Boolean;
function SearchLike(const S,Mask: String; CaseSen: Boolean; MaskChar: Char = '?'; WildCard: Char = '%'): Boolean;
function Search(Op1,Op2 : Variant; OEM, CaseSen : Boolean; PartLen: Integer):Boolean;
function GetBDEErrorMessage(ErrorCode : Word):String;


var
  DBCharSet : TConvertChar;

implementation
uses Dialogs,uMyDMHelpers;

/////////////////////////////////////////////////////////////////////////////
//                  IMPLEMENTATION TCONTAINER OBJECT                       //
/////////////////////////////////////////////////////////////////////////////
Constructor TContainer.Create;
begin
  Inherited Create;
  FItems := TList.Create;
end;

Destructor TContainer.Destroy;
begin
  FreeAll;
  FItems.Free;
  Inherited Destroy;
end;

Function TContainer.At(Index : integer) : Pointer;
begin
  Try
    Result := FItems[Index];
  Except
    On E:EListError do Result := nil;
  end;
end;

Procedure TContainer.AtDelete(Index : integer);
begin
  FItems.Delete(Index);
end;

Procedure TContainer.AtFree( Index : integer );
var
  Item : Pointer;
begin
  Item := At(Index);
  if Item <> nil then
  begin
    AtDelete(Index);
    FreeItem(Item);
  end;
end;

Procedure TContainer.AtInsert( Index : integer; Item : pointer );
begin
  FItems.Insert( Index, Item );
end;

Procedure TContainer.AtPut( Index : integer; Item : pointer );
begin
  FItems[ Index ] := Item;
end;

Procedure TContainer.Clear;
begin
  FItems.Clear;
end;

Procedure TContainer.Delete( Item : pointer );
var
  i : Integer;
begin
  i := IndexOf( Item );
  if i <> -1  then  AtDelete(i);
end;

Procedure TContainer.DeleteAll;
begin
  FItems.Clear;
end;

Procedure TContainer.Error( Code, Info : integer );
begin
  Raise EListError.Create( 'Container index out of range' );
end;

Procedure TContainer.FreeAll;
var
  I : integer;
begin
  Try
    for I := Count -1 downto 0 do
      FreeItem(At(I));
  Except
    On EListError do ;
  End;
  FItems.Clear;
end;

Procedure TContainer.FreeItem( Item : pointer );
begin
  If Item <> nil  then TObject(Item).Free;
end;

Function TContainer.Get(AIndex : integer) : pointer;
begin
  Result := FItems[AIndex];
end;

Function TContainer.GetCount: integer;
begin
  Result := FItems.Count;
end;

Function TContainer.IndexOf( Item : pointer ) : integer;
begin
  Result := FItems.IndexOf( Item );
end;

Procedure TContainer.Insert(Item : pointer);
begin
  FItems.Add(Item);
end;

Procedure TContainer.Pack;
begin
  FItems.Pack;
end;

Procedure TContainer.Put( AIndex : integer; APointer : pointer );
begin
  FItems[AIndex] := APointer;
end;

Function TContainer.GetCapacity : Integer;
begin
  Result := FItems.Capacity;
end;

Procedure TContainer.SetCapacity( NewCapacity : Integer );
begin
  FItems.Capacity := NewCapacity;
end;

/////////////////////////////////////////////////////////////////////////////
//                  IMPLEMENTATION TBASEOBJECT OBJECT                      //
/////////////////////////////////////////////////////////////////////////////
Constructor TBaseObject.Create(P : TObject; Container : TContainer);
begin
  Inherited Create;
  FParent    := P;
  FContainer := Container;
  If FContainer <> nil then FContainer.Insert(Self);
end;

Destructor TBaseObject.Destroy;
begin
  If FContainer <> nil then FContainer.Delete(Self);
  Inherited Destroy;
end;

/////////////////////////////////////////////////////////////////////////////
//                  IMPLEMENTATION COMMON FUNCTIONS                        //
/////////////////////////////////////////////////////////////////////////////
function GetVerAsInt(AHandle : TMysqlClient): integer;
var
  S: string;
  i, j: integer;
begin
  S := AHandle.ServerVersion;
  i := 1;
  j := 0;
  while (i <= Length(S)) do
  begin
    if S[i] in ['0'..'9'] then
    begin
      Inc(j);
      Inc(i);
    end else
    begin
      Delete(S, i, 1);
      if j = 1 then
      begin
        Insert('0', S, i - j);
        Inc(i);
      end;
      j := 0;
    end;
  end;
  if S <> '' then
     Result := StrToInt(S) else
     Result := 0;
end;
{ SQL Parser }
function NextSQLToken(var p: PChar; out Token: string; CurSection: TSQLToken): TSQLToken;
var
  DotStart: Boolean;
  BraketCnt : Integer;

  function NextTokenIs(Value: string; var Str: string): Boolean;
  var
    Tmp: PChar;
    S: string;
  begin
    Tmp := p;
    NextSQLToken(Tmp, S, CurSection);
    Result := AnsiCompareText(Value, S) = 0;
    if Result then
    begin
      Str := Str + ' ' + S;
      p := Tmp;
    end;
  end;

  function GetSQLToken(var Str: string): TSQLToken;
  var
    l: PChar;
    s: string;
  begin
    if Length(Str) = 0 then
      Result := stEnd else
    if (Str = '*') and (CurSection = stSelect) then
      Result := stAllFields else
    if DotStart then
      Result := stFieldName else
    if (AnsiCompareText('DISTINCT', Str) = 0) and (CurSection = stSelect) then
      Result := stDistinct else
    if (AnsiCompareText('ASC', Str) = 0) or (AnsiCompareText('ASCENDING', Str) = 0)then
      Result := stAscending else
    if (AnsiCompareText('DESC', Str) = 0) or (AnsiCompareText('DESCENDING', Str) = 0)then
      Result := stDescending else
    if AnsiCompareText('SELECT', Str) = 0 then
      Result := stSelect else
    if AnsiCompareText('SHOW', Str) = 0 then
      Result := stShow else
    if AnsiCompareText('AND', Str) = 0 then
      Result := stAnd else
    if AnsiCompareText('FOR', Str) = 0 then
      Result := stFor else
    if AnsiCompareText('OR', Str) = 0 then
      Result := stOr else
    if AnsiCompareText('LIKE', Str) = 0 then
      Result := stLike else
    if (AnsiCompareText('IS', Str) = 0) then
    begin
      if NextTokenIs('NULL', Str) then
        Result := stIsNull else
      begin
        l := p;
        s := Str;
        if NextTokenIs('NOT', Str) and NextTokenIs('NULL', Str) then
          Result := stIsNotNull else
        begin
          p := l;
          Str := s;
          Result := stValue;
        end;
      end;
    end else
    if AnsiCompareText('FROM', Str) = 0 then
      Result := stFrom else
    if AnsiCompareText('WHERE', Str) = 0 then
      Result := stWhere else
    if (AnsiCompareText('GROUP', Str) = 0) and NextTokenIs('BY', Str) then
      Result := stGroupBy else
    if AnsiCompareText('HAVING', Str) = 0 then
      Result := stHaving else
    if AnsiCompareText('UNION', Str) = 0 then
      Result := stUnion else
    if AnsiCompareText('PLAN', Str) = 0 then
      Result := stPlan else
    if (AnsiCompareText('FOR', Str) = 0) and NextTokenIs('UPDATE', Str) then
      Result := stForUpdate else
    if (AnsiCompareText('ORDER', Str) = 0) and NextTokenIs('BY', Str)  then
      Result := stOrderBy else
    if AnsiCompareText('NULL', Str) = 0 then
      Result := stValue else
    if AnsiCompareText('CREATE', Str) = 0 then
      Result := stCreate else
    if AnsiCompareText('INSERT', Str) = 0 then
      Result := stInsert else
    if AnsiCompareText('UPDATE', Str) = 0 then
      Result := stUpdate else
    if AnsiCompareText('SUBSTRING', Str) = 0 then
      Result := stFunction else
    if AnsiCompareText('TRIM', Str) = 0 then
      Result := stFunction else
    if AnsiCompareText('EXTRACT', Str) = 0 then
      Result := stFunction else
    if CurSection = stFrom then
      Result := stTableName else
      Result := stFieldName;
  end;

var
  TokenStart: PChar;

  procedure StartToken;
  begin
    if not Assigned(TokenStart) then
      TokenStart := p;
  end;

var
  Literal: Char;
  Mark: PChar;
begin
  TokenStart := nil;
  DotStart := False;
  BraketCnt := 0;
  while True do
  begin
    case p^ of
      '"','''','`':
      begin
        StartToken;
        Literal := p^;
        Mark := p;
        repeat Inc(p) until (p^ in [Literal,#0]);
        if p^ = #0 then
        begin
          p := Mark;
          Inc(p);
        end else
        begin
          Inc(p);
          SetString(Token, TokenStart, p - TokenStart);
          Mark := PChar(Token);
          Token := AnsiExtractQuotedStr(Mark, Literal);
          if DotStart then
            Result := stFieldName else
          if p^ = '.' then
            Result := stTableName else
            Result := stValue;
          Exit;
        end;
      end;
      '/':
      begin
        StartToken;
        Inc(p);
        if p^ in ['/','*'] then
        begin
          if p^ = '*' then
          begin
            repeat Inc(p) until (p = #0) or ((p^ = '*') and (p[1] = '/'));
          end else
            while not (p^ in [#0, #10, #13]) do Inc(p);
          SetString(Token, TokenStart, p - TokenStart);
          Result := stComment;
          Exit;
        end;
      end;
      ' ', #10, #13, ',','(',')':
      begin
        if Assigned(TokenStart) then
        begin
          SetString(Token, TokenStart, p - TokenStart);
          Result := GetSQLToken(Token);
          if Result = stFunction then
          begin
              Inc(BraketCnt);
             repeat
                Inc(p);
                if p^ in [')'] then Dec(BraketCnt);
                if p^ in ['('] then Inc(BraketCnt);
             until (p^ in [')']) and (BraketCnt=0);
          end;
          Exit;
        end else
          while (p^ in [' ', #10, #13, ',','(',')']) do Inc(p);
      end;
      '.':
      begin
        if Assigned(TokenStart) then
        begin
          SetString(Token, TokenStart, p - TokenStart);
          Result := stTableName;
          Exit;
        end else
        begin
          DotStart := True;
          Inc(p);
        end;
      end;
      '=','<','>':
      begin
        if not Assigned(TokenStart) then
        begin
          TokenStart := p;
          while p^ in ['=','<','>'] do Inc(p);
          SetString(Token, TokenStart, p - TokenStart);
          Result := stPredicate;
          Exit;
        end;
        Inc(p);
      end;
      '0'..'9':
      begin
        if not Assigned(TokenStart) then
        begin
          TokenStart := p;
          while p^ in ['0'..'9','.'] do Inc(p);
          SetString(Token, TokenStart, p - TokenStart);
          Result := stNumber;
          Exit;
        end else
          Inc(p);
      end;
      #0:
      begin
        if Assigned(TokenStart) then
        begin
          SetString(Token, TokenStart, p - TokenStart);
          Result := GetSQLToken(Token);
          Exit;
        end else
        begin
          Result := stEnd;
          Token := '';
          Exit;
        end;
      end;
    else
      StartToken;
      Inc(p);
    end;
  end;
end;

function GetShow(const SQL: string): Boolean;
var
  Start: PChar;
  Token: string;
  SQLToken, CurSection: TSQLToken;
begin
  Result := false;
  Start := PChar(SQL);
  CurSection := stUnknown;
  repeat
    SQLToken := NextSQLToken(Start, Token, CurSection);
    if SQLToken in [stShow] then Break;
  until SQLToken = stEnd;
  if SQLToken in [stShow] then Result := True;
end;

function GetTable(const SQL: string): String;
var
  Start: PChar;
  Token: string;
  SQLToken, CurSection: TSQLToken;
begin
  Result := '';
  Start := PChar(SQL);
  CurSection := stUnknown;
  repeat
    SQLToken := NextSQLToken(Start, Token, CurSection);
    if SQLToken in SQLSections then CurSection := SQLToken;
    if CurSection = stShow then Exit;
  until SQLToken in [stEnd, stFrom];
  if SQLToken = stFrom then
  begin
    repeat
      SQLToken := NextSQLToken(Start, Token, CurSection);
      if SQLToken in SQLSections then
        CurSection := SQLToken else
        if (SQLToken = stTableName) or (SQLToken = stValue) then
        begin
           if ServerVersion > 32306 then
           begin
              if Pos('`',Token)=0 then
                 Result := '`'+Token+'`' else
                 Result := Token;
           end else
              Result := Token;
           while (Start[0] = '.') and not (SQLToken in [stEnd]) do
           begin
              if Result <> '' then
                 Result := Result+Start[0];
              SQLToken := NextSqlToken(Start, Token, CurSection);
              if ServerVersion > 32306 then
              begin
                 if Pos('`',Token)=0 then
                    Result := Result+'`'+Token+'`' else
                    Result := Result + Token;
              end else
                  Result := Result + Token;
           end;
           Exit;
        end;
    until (CurSection <> stFrom) or (SQLToken in [stEnd, stTableName]);
  end;
end;

function GetTableNamePartFromSQL(const SQL: string): string;
begin
   Result := '';
   if GetShow(SQL) then exit;
   Result := GetTable(SQL);

end;

function GetSelectPartFromSQL(const SQL: string): string;
var
  Start: PChar;
  Token: string;
  SQLToken, CurSection: TSQLToken;
begin
  Result := '';
  Start := PChar(SQL);
  CurSection := stUnknown;
  repeat
    SQLToken := NextSQLToken(Start, Token, CurSection);
    if SQLToken in SQLSections then CurSection := SQLToken;
    Result := Result + Token+' ';
  until SQLToken in [stEnd, stTableName];
  Result := Trim(Result);
end;

function GetWherePartFromSQL(const SQL: string): string;
var
  Start: PChar;
  Token: string;
  SQLToken, CurSection: TSQLToken;
begin
  Result := '';
  Start := PChar(SQL);
  CurSection := stUnknown;
  repeat
    SQLToken := NextSQLToken(Start, Token, CurSection);
    if SQLToken in SQLSections then CurSection := SQLToken;
  until SQLToken in [stEnd, stTableName];
  if SQLToken <> stEnd then
  begin
    repeat
      SQLToken := NextSQLToken(Start, Token, CurSection);
      if SQLToken in SQLSections then CurSection := SQLToken;
      if CurSection in [stGroupBy, stHaving, stUnion,stPlan, stOrderBy, stForUpdate] then Break;
      Result := Result + Token+' ';
    until SQLToken in [stEnd, stGroupBy, stHaving, stUnion, stPlan];
  end;
  Result := Trim(Result);
end;

function GetOrderByPartFromSQL(const SQL: string): string;
var
  Start: PChar;
  Token: string;
  SQLToken, CurSection: TSQLToken;
begin
  Result := '';
  Start := PChar(SQL);
  CurSection := stUnknown;
  repeat
    SQLToken := NextSQLToken(Start, Token, CurSection);
    if SQLToken in SQLSections then CurSection := SQLToken;
  until SQLToken in [stEnd, stOrderBy];
  if SQLToken <> stEnd then
  begin
    Result := Result + Token+' ';
    repeat
      SQLToken := NextSQLToken(Start, Token, CurSection);
      if SQLToken in SQLSections then CurSection := SQLToken;
      Result := Result + Token+' ';
    until SQLToken in [stEnd];
  end;
  Result := Trim(Result);
end;

function CompareBegin(Str1, Str2: string): Boolean;
begin
  if ((Str1 = '') or (Str2 = '')) and (Str1 <> Str2) then
    Result := False  else
    Result := (StrLIComp(PChar(Str1), PChar(Str2), Min(Length(Str1), Length(Str2))) = 0);
end;

function SqlDateToDateTime(Value: string): TDateTime;
var
  Year, Month, Day, Hour, Min, Sec: Integer;
  Temp: string;
begin
  Temp   := Value;
  Result := 0;
  if Length(Temp) >= 10 then
  begin
    Year  := Max(0, StrToIntDef(Copy(Temp,1,4),0));
    Month := Max(0, StrToIntDef(Copy(Temp,6,2),0));
    Day   := Max(0, StrToIntDef(Copy(Temp,9,2),0));

//    Year  := Max(1, StrToIntDef(Copy(Temp,1,4),1));
//    Month := Max(1, StrToIntDef(Copy(Temp,6,2),1));
//    Day   := Max(1, StrToIntDef(Copy(Temp,9,2),1));
    if (Year > 0) and (Month > 0) and (Day > 0)  then
       Result := EncodeDate(Year, Month, Day) else
       Result := 0;
    Temp := Copy(Temp,12,8);
  end;
  if Length(Temp) >= 8 then
  begin
    Hour := StrToIntDef(Copy(Temp,1,2),0);
    Min  := StrToIntDef(Copy(Temp,4,2),0);
    Sec  := StrToIntDef(Copy(Temp,7,2),0);
    Result := Result + EncodeTime(Hour, Min, Sec, 0);
  end;
end;

function DateTimeToSqlDate(Value: TDateTime; Mode: Integer): string;
begin
  Result := '';
  case Mode of
     0: begin
           if Trunc(Value) <> 0 then
              Result := FormatDateTime('yyyy-mm-dd hh:nn:ss', Value) else
              Result := '0000-00-00 00:00:00';
        end;
     1: begin
           if Trunc(Value) <> 0 then
              Result := FormatDateTime('yyyy-mm-dd', Value)  else
              Result := '0000-00-00';
        end;
     2: begin
           if Frac(Value) <> 0 then
           begin
              if Result <> '' then Result := Result + ' ';
              Result := Result + FormatDateTime('hh:nn:ss', Value);
           end else
              Result := '00:00:00';
        end;
  end;
end;

function SQLTimestampToDateTime(Value: string): TDateTime;
var
  Year, Month, Day, Hour, Min, Sec: Integer;
begin
  if Pos('-',Value) > 0 then
  begin
     Year  := Max(1, StrToIntDef(Copy(Value, 1, 4), 1));
     Month := Max(1, StrToIntDef(Copy(Value, 6, 2), 1));
     Day   := Max(1, StrToIntDef(Copy(Value, 9, 2), 1));
     Hour := StrToIntDef(Copy(Value, 12, 2), 0);
     Min  := StrToIntDef(Copy(Value, 15, 2), 0);
     Sec  := StrToIntDef(Copy(Value, 18, 2), 0);
  end else
  begin
     Year  := Max(1, StrToIntDef(Copy(Value, 1, 4), 1));
     Month := Max(1, StrToIntDef(Copy(Value, 5, 2), 1));
     Day   := Max(1, StrToIntDef(Copy(Value, 7, 2), 1));
     Hour := StrToIntDef(Copy(Value, 9, 2), 0);
     Min  := StrToIntDef(Copy(Value, 11, 2), 0);
     Sec  := StrToIntDef(Copy(Value, 13, 2), 0);
  end;
  try
    Result := EncodeDate(Year, Month, Day) + EncodeTime(Hour, Min, Sec, 0);
  except
    Result := 0;
  end;
end;

function StrToSQLFloat(Value: string): Double;
var
  Temp: Char;
begin
  Temp := DecimalSeparator;
  DecimalSeparator := '.';
  if Value <> '' then
    try
      Result := StrToFloat(Value);
    except
      Result := 0;
    end
  else
    Result := 0;
  DecimalSeparator := Temp;
end;

function SQLFloatToStr(Value: Double): string;
var
  Temp: Char;
begin
  Temp := DecimalSeparator;
  DecimalSeparator := '.';
  Result := FloatToStr(Value);
  DecimalSeparator := Temp;
end;

function StrToBool(TrueVal : TTrueArray;FalseVal : TFalsearray;Value : String): boolean;
var
  val : Char;
begin
	if Value='' then//mi
	begin
		Result := false
	end
	else
	begin
		Val := LowerCase(Value)[1];
		if (Val in TrueVal) then Result := True else Result := False;
	end;
end;

function BoolToStr(I : smallint;boolstr : string):String;
begin
   case I of
     0: if (lowercase(boolstr) = 'y,n') or (lowercase(boolstr) = 'n,y') then result := 'n' else result := 'f';
     1: if (lowercase(boolstr) = 't,f') or (lowercase(boolstr) = 'f,t') then result := 't' else result := 'y';
   end;
end;

function TimeOf(const ADateTime: TDateTime): TDateTime;
var
  Hour, Min, Sec, MSec: Word;
begin
   DecodeTime(ADateTime, Hour, Min, Sec, MSec);
   Result := EncodeTime(Hour, Min, Sec, MSec);
end;

procedure GetToken(var Buffer, Token: string);
label ExitProc;
var
  P: Integer;
  Quote: string;
begin
  P := 1;
  Token  := '';
  if Buffer = '' then Exit;
  while Buffer[P] in [' ',#9] do
  begin
    Inc(P);
    if Length(Buffer) < P then  goto ExitProc;
  end;
  if (Pos(Buffer[P],DELIMITERS) <> 0) then
  begin
    Token  := Buffer[P];
    Inc(P);
    goto ExitProc;
  end;
  if Buffer[P] in ['"',''''] then
  begin
    Quote  := Buffer[P];
    Token  := Quote;
    Inc(P);
    while P <= Length(Buffer) do
    begin
      Token := Token + Buffer[P];
      Inc(P);
      if (Buffer[P-1] = Quote) and (Buffer[P-2] <> '\') then  Break;
    end;
  end else
  begin
    while P <= Length(Buffer) do
    begin
      Token := Token + Buffer[P];
      Inc(P);
      if (P > Length(Buffer)) or (Pos(Buffer[P],DELIMITERS) <> 0) or (Buffer[P] in ['"','''']) then Break;
    end;
  end;
ExitProc:
  Delete(Buffer, 1, P-1);
end;


Procedure FieldMapping(FieldType : Word; phSize : Integer; Var BdeType : Word; Var BdeSubType : Word; Var LogSize : Integer; TEXT,UNSIGN,Bool : Boolean);
begin
  BdeType    := fldUNKNOWN;
  BdeSubType := 0;
  LogSize    := 0;
  Case FieldType of
    FIELD_TYPE_TINY,
    FIELD_TYPE_SHORT:   begin
                           {new 29.05.2001}
                           if UNSIGN then
                           begin
                              BDEType := fldUINT16;
                              LogSize := Sizeof(Word);
                           end else
                           begin
                              BDEType := fldINT16;
                              LogSize := Sizeof(SmallInt);
                           end;
                        end;
    FIELD_TYPE_LONG,
    FIELD_TYPE_INT24,
    FIELD_TYPE_YEAR:    begin
                           //new 27.08.2002
                           if UNSIGN then
                           begin
                              BDEType := fldUINT32;
                              LogSize := Sizeof(LongInt);
                           end else
                           begin
                              BDEType := fldINT32;
                              LogSize := Sizeof(LongInt);
                           end;
                        end;
    FIELD_TYPE_LONGLONG:begin
                           BDEType := fldINT64;
                           LogSize := Sizeof(Int64);
                        end;
    FIELD_TYPE_VAR_STRING,
    FIELD_TYPE_STRING:  begin
                           BdeType := fldZSTRING;
                           LogSize   := phSize+1;
                        end;
    FIELD_TYPE_NEWDATE,
    FIELD_TYPE_DATE:    begin
                           BdeType := fldDATE;
                           LogSize := Sizeof(TTimeStamp);
                        end;
    FIELD_TYPE_TIME:    begin
                           BdeType := fldTIME;
                           LogSize := Sizeof(TDateTime);
                        end;
   FIELD_TYPE_TIMESTAMP,
   FIELD_TYPE_DATETIME: begin
                           BdeType := fldTIMESTAMP;
                           LogSize := SizeOf(TTimeStamp);
                        end;
   FIELD_TYPE_DECIMAL,
   FIELD_TYPE_NEWDECIMAL, //:CN 04/05/2005
   FIELD_TYPE_FLOAT,
   FIELD_TYPE_DOUBLE:   begin
                           BdeType := fldFLOAT;
                           LogSize := Sizeof(Double);
                        end;
   FIELD_TYPE_ENUM:     begin
                           if Bool then
                           begin
                              BdeType := fldBOOL;
                              LogSize := SizeOf(SmallInt);
                           end else
                           begin
                              BdeType := fldZSTRING;
                              LogSize := phSize+1;
                           end;
                        end;
   FIELD_TYPE_SET:      begin
                           BdeType := fldZSTRING;
                           LogSize := phSize+1;
                        end;
   FIELD_TYPE_BLOB:     begin
                           BdeType := fldBLOB;
                           LogSize := SizeOf(TBlobItem);
                           if TEXT then
                              BdeSubType := fldstMemo;
                        end;
   FIELD_TYPE_NULL:     begin
                           BdeType := fldZSTRING;
                           LogSize   := phSize+1;
                        end;
  end;
end;

Procedure ConvermySQLtoDelphiFieldInfo(Info : PMysql_FieldDef; Count, Offset : Word; pRecBuff : PFLDDesc; pValChk : pVCHKDesc; EnumVal: String; DefVal : PChar);
var
  LogSize : Integer;
  dataType: Integer;
  dataLen : Integer;
  isText,
  isUnSign,
  isBool  : Boolean;
  enumList : TStringList;
begin
  if Assigned(pRecBuff) then
  begin
    ZeroMemory(pRecBuff, Sizeof(FLDDesc));
    ZeroMemory(pValChk,SizeOf(VCHKDesc));
    with PRecBuff^ do
    begin
      iFldNum  := Count;
      pValChk^.iFldNum := Count;
      dataType := Info^.FieldType;//_type;
      isText := False;
      isBool := False;
      if ISENUM(Info) then
      begin
         EnumList := TStringList.Create;
         try
           enumList.CommaText := enumVal;
           if (enumList.Count = 2) and (Info^.Length = 1) and ((lowercase(enumList[0])[1] in ['t','f','y','n']) and (lowercase(enumList[1])[1] in ['t','f','y','n'])) then
           begin
              dataType := FIELD_TYPE_ENUM;
              isBool := true;
           end;
         finally
           enumList.Free;
         end;
      end;
      if IsUNSIGNED(Info) then
         isUnSign := True else
         isUnSign := False;
      DataLen := Max(Info^.length,Info^.Max_Length);
      if ISSET(Info) then
      begin
          dataType := FIELD_TYPE_SET;
          if Info^.Max_Length > 0 then
             DataLen := Max(Info^.Max_Length, Info^.Length);
      end;
      Info^.FieldType := dataType;
      if IsBLOB(Info) and (Info^.FieldType = FIELD_TYPE_BLOB) and (not IsBINARY(info)) then isTEXT := true;
      //проверка если строка больше чем 255 символов то отдаем ее как мемо поле
      if (DataType in [FIELD_TYPE_VAR_STRING,FIELD_TYPE_STRING]) and (DataLen > 255) then
      begin
         Info^.FieldType := FIELD_TYPE_BLOB;
         dataType := Info^.FieldType;
         isText := True;
      end;
      FieldMapping(dataType,dataLen,iFldType,iSubType,LogSize,isText,IsUnSign,isBool);
      if (dataType in [FIELD_TYPE_DECIMAL,
      FIELD_TYPE_NEWDECIMAL, //:CN 04/05/2005
      FIELD_TYPE_FLOAT, FIELD_TYPE_DOUBLE]) then
      begin
        iUnits1  := 32;
        iUnits2  := Hi(LogSize);
        iLen     := Lo(LogSize);
      end else
      { Изменения внесены в FieldOffset (строки и set),GetRecordSize,FieldMapping  и здесь }
      begin
        if iFldType = fldZSTRING then
           iUnits1  := LogSize-1 else
           iUnits1  := LogSize;
        iUnits2  := 0;
        iLen     := LogSize;
      end;
      if (iFldType in [fldINT32, fldUINT32, fldINT64, fldUINT64]) and IsAUTOINCREMENT(Info) then iSubType := fldstAUTOINC; //:CN 04/05/2005
      iOffset := Offset;
      efldvVchk := fldvUNKNOWN;
      if IsNotNull(Info) then pValChk^.bRequired := True;
      if IsPRIKEY(Info) then pValChk^.bRequired := True;
      if IsUNIQUEKEY(Info) then pValChk^.bRequired := True;

      if DefVal <> nil then pValChk^.bHasDefVal := True;
      StrLCopy( @szName, Info^.name, min(StrLen(Info^.name), SizeOf(szName) - 1) );
      if Info^.Table = nil then
         bCalcField := True;
    end;
  end;
end;


//New Reliase
function ScanStr(const S: string; Ch: Char; StartPos: Integer): Integer;
asm
        TEST    EAX,EAX
        JE      @@qt
        PUSH    EDI
        MOV     EDI,EAX
        LEA     EAX,[ECX-1]
        MOV     ECX,[EDI-4]
        SUB     ECX,EAX
        JLE     @@m1
        PUSH    EDI
        ADD     EDI,EAX
        MOV     EAX,EDX
        POP     EDX
        REPNE   SCASB
        JNE     @@m1
        MOV     EAX,EDI
        SUB     EAX,EDX
        POP     EDI
        RET
@@m1:   POP     EDI
        XOR     EAX,EAX
@@qt:
end;

function TestMask(const S, Mask: string; MaskChar: Char): Boolean;
asm
        TEST    EAX,EAX
        JE      @@qt2
        PUSH    EBX
        TEST    EDX,EDX
        JE      @@qt1
        MOV     EBX,[EAX-4]
        CMP     EBX,[EDX-4]
        JE      @@01
@@qt1:  XOR     EAX,EAX
        POP     EBX
@@qt2:  RET
@@01:   DEC     EBX
        JS      @@07
@@lp:   MOV     CH,BYTE PTR [EDX+EBX]
        CMP     CL,CH
        JNE     @@cm
        DEC     EBX
        JS      @@eq
        MOV     CH,BYTE PTR [EDX+EBX]
        CMP     CL,CH
        JNE     @@cm
        DEC     EBX
        JS      @@eq
        MOV     CH,BYTE PTR [EDX+EBX]
        CMP     CL,CH
        JNE     @@cm
        DEC     EBX
        JS      @@eq
        MOV     CH,BYTE PTR [EDX+EBX]
        CMP     CL,CH
        JNE     @@cm
        DEC     EBX
        JNS     @@lp
@@eq:   MOV     EAX,1
        POP     EBX
        RET
@@cm:   CMP     CH,BYTE PTR [EAX+EBX]
        JNE     @@07
        DEC     EBX
        JNS     @@lp
        MOV     EAX,1
        POP     EBX
        RET
@@07:   XOR     EAX,EAX
        POP     EBX
end;

function MaskISearch(const S, Mask: string; MaskChar, WildCard: Char): Boolean;
label
  99;
var
  L,X,X0,Q: Integer;
  P,P1,B: PChar;
  C: Char;
begin
  X := ScanStr(Mask,WildCard);
  if X = 0 then
  begin
    Result := TestMask(S,Mask,MaskChar);
    Exit;
  end;
  L := Length(S);
  P := Pointer(S);
  Result := False;
  B := Pointer(Mask);
  Q := X-1;
  if L < Q then
    Exit;
  while Q > 0 do
  begin
    C := B^;
    if (C<>MaskChar) and (C<>P^) then
      Exit;
    Dec(Q);
    Inc(B);
    Inc(P);
  end;
  Dec(L,X-1);
  repeat
    X0 := X;
    P1 := P;
    while Mask[X0] = WildCard do
      Inc(X0);
    X := ScanStr(Mask,WildCard,X0);
    if X = 0 then
      Break;
  99:
    P := P1;
    B := @Mask[X0];
    Q := X-X0;
    if L < Q then
      Exit;
    while Q > 0 do
    begin
      C := B^;
      if (C<>MaskChar) and (C<>P^) then
      begin
        Inc(P1);
        Dec(L);
        goto 99;
      end;
      Dec(Q);
      Inc(B);
      Inc(P);
    end;
    Dec(L,X-X0);
  until False;
  X := Length(Mask);
  if L >= X-X0+1 then
  begin
    P := Pointer(S);
    Inc(P,Length(S)-1);
    while X >= X0 do
    begin
      C := Mask[X];
      if (C<>MaskChar) and (C<>P^) then
        Exit;
      Dec(X);
      Dec(P);
    end;
    Result := True;
  end;
end;

function MaskSearch(const S, Mask: string; MaskChar, WildCard: Char): Boolean;
label
  99;
var
  L,X,X0,Q: Integer;
  P,P1,B: PChar;
  C: Char;
begin
  X := ScanStr(Mask,WildCard);
  Result := False;
  if X = 0 then
  begin
    L := Length(Mask);
    if (L>0) and (L=Length(S)) then
    begin
      P := Pointer(S);
      B := Pointer(Mask);
      repeat
        C := B^;
        if (C<>MaskChar) and (C<>P^) and
            (ToUpperChars[Byte(C)]<>ToUpperChars[Byte(P^)]) then
          Exit;
        Dec(L);
        Inc(B);
        Inc(P);
      until L = 0;
      Result := True;
    end;
    Exit;
  end;
  L := Length(S);
  P := Pointer(S);
  B := Pointer(Mask);
  Q := X-1;
  if L < Q then
    Exit;
  while Q > 0 do
  begin
    C := B^;
    if (C<>MaskChar) and (C<>P^) and
        (ToUpperChars[Byte(C)]<>ToUpperChars[Byte(P^)]) then
      Exit;
    Dec(Q);
    Inc(B);
    Inc(P);
  end;
  Dec(L,X-1);
  repeat
    X0 := X;
    P1 := P;
    while Mask[X0] = WildCard do
      Inc(X0);
    X := ScanStr(Mask,WildCard,X0);
    if X = 0 then
      Break;
  99:
    P := P1;
    B := @Mask[X0];
    Q := X-X0;
    if L < Q then
      Exit;
    while Q > 0 do
    begin
      C := B^;
      if (C<>MaskChar) and (C<>P^) and
        (ToUpperChars[Byte(C)]<>ToUpperChars[Byte(P^)]) then
      begin
        Inc(P1);
        Dec(L);
        goto 99;
      end;
      Dec(Q);
      Inc(B);
      Inc(P);
    end;
    Dec(L,X-X0);
  until False;
  X := Length(Mask);
  if L >= X-X0+1 then
  begin
    P := Pointer(S);
    Inc(P,Length(S)-1);
    while X >= X0 do
    begin
      C := Mask[X];
      if (C<>MaskChar) and (C<>P^) and
          (ToUpperChars[Byte(C)]<>ToUpperChars[Byte(P^)]) then
        Exit;
      Dec(X);
      Dec(P);
    end;
    Result := True;
  end;
end;

function SearchLike(const S,Mask: String; CaseSen: Boolean; MaskChar, WildCard: Char): Boolean;
begin
   if CaseSen then
      Result := MaskISearch(S,Mask,MaskChar,WildCard) else
      Result := MaskSearch(S,Mask,MaskChar,WildCard);
end;

function Search(Op1,Op2 : Variant; OEM, CaseSen : Boolean; PartLen: Integer):Boolean;
var
  S1,S2 : String;
begin
   If CaseSen then //case insensitive
   begin
      Op1 := AnsiUpperCase(Op1);
      Op2 := AnsiUpperCase(Op2);
   end;
   S1 := Op1;
   S2 := Op2;
   if OEM then
   begin
      OemToCharBuff(PChar(S1),PChar(S1), Length(S1));
      OemToCharBuff(PChar(S2),PChar(S2), Length(S2));
   end;
   If CaseSen then //case insensitive
   begin
      if PartLen = 0 then
         Result := AnsiStrIComp(PChar(S1),PChar(S2)) = 0 else  // Full len
         Result := AnsiStrLIComp(PChar(S1),PChar(S2),PartLen) = 0; //Part len
   end else
   begin
      if PartLen = 0 then
         Result := AnsiStrComp(PChar(S1),PChar(S2)) = 0 else  // Full len
         Result := AnsiStrLComp(PChar(S1),PChar(S2),PartLen) = 0; //Part len
   end;
end;

function GetBDEErrorMessage(ErrorCode : Word):String;
begin
   case ErrorCode of
      DBIERR_BOF: Result :='At beginning of table.';               //8705
      DBIERR_EOF: Result :='At end of table.';               //8706
      DBIERR_NOCURRREC: Result :='No current record.';         //8709
      DBIERR_RECNOTFOUND: Result :='Could not find record.';       //8710
      DBIERR_ENDOFBLOB: Result :='End of BLOB.';         //8711
      DBIERR_INVALIDPARAM: Result :='Invalid parameter.';      //9986
      DBIERR_INVALIDHNDL: Result :='Invalid handle to the function.';       //9990
      DBIERR_NOSUCHINDEX: Result :='Index does not exist.';       //9997
      DBIERR_INVALIDBLOBOFFSET: Result :='Invalid offset into the BLOB.'; //9998
      DBIERR_INVALIDRECSTRUCT: Result :='Invalid record structure.';  //10003
      DBIERR_NOSUCHTABLE: Result :='Table does not exist.';       //10024
      DBIERR_NOSUCHFILTER: Result :='Filter handle is invalid.';      //10050
      DBIERR_NOTSUFFTABLERIGHTS: Result :='Insufficient table rights for operation. Password required.';//10498
      DBIERR_NOTABLOB: Result :='Field is not a BLOB.';          //10753
      DBIERR_TABLEREADONLY: Result :='Table is read only.';     //10763
      DBIERR_NOASSOCINDEX: Result :='No associated index.';      //10764
      DBIERR_QRYEMPTY: Result :='Query string is empty.';          //11886
      DBIERR_NOTSUPPORTED: Result :='Capability not supported.';      //12289
      DBIERR_UPDATEABORT: Result :='Update aborted.';       //13062
   else
      Result := 'Unknown error';
   end;
end;

function GetNumFromSet(ASet,AValue : String):Integer;
var
  Lst_Set : TStrings;
  Lst_Val : TStrings;
  I,J     : Integer;
begin
  Result := 0;
  Lst_Set := TSTringList.Create;
  Lst_Val := TStringList.Create;
  try
    Lst_Set.CommaText := ASet;
    Lst_Val.CommaText := AValue;
    for I := 0 to Lst_Val.Count-1 do
    begin
       J := Lst_Set.IndexOf(Lst_Val[I]);
       if J <> -1 then
          Result := Result + (1 shl J);
    end;
  finally
    Lst_Set.Free;
    Lst_Val.Free;
  end;
end;


end.
