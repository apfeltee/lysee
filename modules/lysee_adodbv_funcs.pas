{==============================================================================}
{     PROJECT: lysee_adodbv_funcs                                              }
{ DESCRIPTION: functions of ADO database verdor                                }
{     CREATED: 2007/07/12                                                      }
{    MODIFIED: 2010/09/01                                                      }
{==============================================================================}
{ Copyright (c) 2008-2010, Li Yun Jie                                          }
{ All rights reserved.                                                         }
{                                                                              }
{ Redistribution and use in source and binary forms, with or without           }
{ modification, are permitted provided that the following conditions are met:  }
{                                                                              }
{ Redistributions of source code must retain the above copyright notice, this  }
{ list of conditions and the following disclaimer.                             }
{                                                                              }
{ Redistributions in binary form must reproduce the above copyright notice,    }
{ this list of conditions and the following disclaimer in the documentation    }
{ and/or other materials provided with the distribution.                       }
{                                                                              }
{ Neither the name of Li Yun Jie nor the names of its contributors may         }
{ be used to endorse or promote products derived from this software without    }
{ specific prior written permission.                                           }
{                                                                              }
{ THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"  }
{ AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE    }
{ IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE   }
{ ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR  }
{ ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL       }
{ DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR   }
{ SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER   }
{ CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT           }
{ LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY    }
{ OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH  }
{ DAMAGE.                                                                      }
{==============================================================================}
{ The Initial Developer of the Original Code is Li Yun Jie (CHINA).            }
{ Portions created by Li Yun Jie are Copyright (C) 2007-2010.                  }
{ All Rights Reserved.                                                         }
{==============================================================================}
{ Contributor(s):                                                              }
{==============================================================================}
unit lysee_adodbv_funcs;

interface

uses
  SysUtils, Classes, Windows, lseu, lse_dbu, ComObj, ADODB;

const
  CSFMT = 'Provider=%s;Persist Security Info=False;User ID=%s;' +
          'Password=%s;Data Source=%s;%s';
  
type
  TVendorType = (dbvODBC, dbvAccess, dbvMSSQL);

  TVendorDB = class(TADOConnection)
  private
    FDB: PLseDB;
    FError: string;
    FRefcount: integer;
    FConnStr: string;
    FUsedDB: string;
    FQuery: TADOQuery;
    FType: TVendorType;
    procedure SetConnStr(const ConnectionStr: string);
    procedure HandleError;
    function ExecSQL(const SQL: string): integer;
  end;

  TVendorDS = class(TADOQuery)
  public
    FDB: PLseDB;
    FDS: PLseDS;
    FError: string;
    FRefcount: integer;
    procedure HandleError;
  end;
  
function vdb_addref(DB: PLseDB): integer;cdecl;
function vdb_release(DB: PLseDB): integer;cdecl;

procedure register_dbv;
procedure register_dbv_odbc;
procedure register_dbv_access;
procedure register_dbv_mssql;

implementation

function get_vds(DS: PLseDS): TVendorDS;
begin
  Result := DS^.ds_object;
  DS^.ds_errno := 0;
  DS^.ds_error := nil;
end;

function get_vdb(DB: PLseDB): TVendorDB;
begin
  Result := DB^.db_object;
  DB^.db_errno := 0;
  DB^.db_error := nil;
end;

// vds -------------------------------------------------------------------------

function vds_addref(DS: PLseDS): integer;cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    vdb_addref(vds.FDB);
    Inc(vds.FRefcount);
    Result := vds.FRefcount;
    if Result = 0 then
    begin
      FreeMem(DS, sizeof(RLseDS));
      FreeAndNil(vds);
    end;
  except
    vds.HandleError;
    Result := 0;
  end;
end;

function vds_release(DS: PLseDS): integer;cdecl;
var
  vds: TVendorDS;
  dbc: PLseDB;
begin
  vds := get_vds(DS);
  try
    dbc := vds.FDB;
    Dec(vds.FRefcount);
    Result := vds.FRefcount;
    if Result = 0 then
    begin
      FreeMem(DS, sizeof(RLseDS));
      FreeAndNil(vds);
    end;
    vdb_release(dbc);
  except
    vds.HandleError;
    Result := vds.FRefcount;
  end;
end;

function vds_count(DS: PLseDS): integer;cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    Result := vds.FieldCount;
  except
    vds.HandleError;
    Result := 0;
  end;
end;

function vds_getfn(DS: PLseDS; index: integer): PLseString;cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    Result := lse_strec_alloc(vds.Fields[index].FieldName);
  except
    vds.HandleError;
    Result := nil;
  end;
end;

function vds_getft(DS: PLseDS; index: integer): integer;cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    Result := __getft(vds.Fields[index]);
  except
    vds.HandleError;
    Result := LSV_VOID;
  end;
end;

function vds_getfi(DS: PLseDS; index: integer): integer;cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    Result := __getfi(vds.Fields[index]);
  except
    vds.HandleError;
    Result := 0;
  end;
end;

function vds_getfs(DS: PLseDS; index: integer): PLseString;cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    Result := lse_strec_alloc(__getfs(vds.Fields[index]));
  except
    vds.HandleError;
    Result := nil;
  end;
end;

function vds_getfd(DS: PLseDS; index: integer): double;cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    Result := __getfd(vds.Fields[index]);
  except
    vds.HandleError;
    Result := 0;
  end;
end;

function vds_getfm(DS: PLseDS; index: integer): currency;cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    Result := __getfm(vds.Fields[index]);
  except
    vds.HandleError;
    Result := 0;
  end;
end;

function vds_getfb(DS: PLseDS; index: integer): integer;cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    Result := Ord(__getfb(vds.Fields[index]));
  except
    vds.HandleError;
    Result := 0;
  end;
end;

function vds_isnull(DS: PLseDS; index: integer): integer;cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    Result := Ord(vds.Fields[index].IsNull);
  except
    vds.HandleError;
    Result := 0;
  end;
end;

function vds_length(DS: PLseDS): integer;cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    Result := vds.RecordCount;
  except
    vds.HandleError;
    Result := 0;
  end;
end;

function vds_bof(DS: PLseDS): integer;cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    Result := Ord(vds.Bof);
  except
    vds.HandleError;
    Result := 0;
  end;
end;

function vds_eof(DS: PLseDS): integer;cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    Result := Ord(vds.Eof);
  except
    vds.HandleError;
    Result := 0;
  end;
end;

procedure vds_seek(DS: PLseDS; Offset, Origin: integer);cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    if Origin in [0, 1, 2] then
    begin
      if Origin = 0 then vds.First else
      if Origin = 2 then vds.Last;
      if Offset <> 0 then
        vds.MoveBy(Offset);
    end;
  except
    vds.HandleError;
  end;
end;

procedure vds_close(DS: PLseDS);cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    vds.Close;
  except
    vds.HandleError;
  end;
end;

function vds_getSQL(DS: PLseDS): PLseString;cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    Result := lse_strec_alloc(vds.SQL.Text);
  except
    vds.HandleError;
    Result := nil;
  end;
end;

procedure vds_setSQL(DS: PLseDS; const SQL: pchar);cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    vds.SQL.Text := SQL;
  except
    vds.HandleError;
  end;
end;

procedure vds_open(DS: PLseDS);cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    vds.Open;
  except
    vds.HandleError;
  end;
end;

function vds_active(DS: PLseDS): integer;cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    Result := Ord(vds.Active);
  except
    vds.HandleError;
    Result := 0;
  end;
end;

function vds_getBMK(DS: PLseDS): pointer;cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    Result := vds.GetBookmark;
  except
    vds.HandleError;
    Result := nil;
  end;
end;

procedure vds_gotoBMK(DS: PLseDS; Bookmark: pointer);cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    vds.GotoBookmark(Bookmark);
  except
    vds.HandleError;
  end;
end;

procedure vds_freeBMK(DS: PLseDS; Bookmark: pointer);cdecl;
var
  vds: TVendorDS;
begin
  vds := get_vds(DS);
  try
    vds.FreeBookmark(Bookmark);
  except
    vds.HandleError;
  end;
end;

// vdb -------------------------------------------------------------------------

function vdb_addref(DB: PLseDB): integer;cdecl;
var
  vdb: TVendorDB;
begin
  vdb := get_vdb(DB);
  try
    Inc(vdb.FRefcount);
    Result := vdb.FRefcount;
    if Result = 0 then
    begin
      FreeMem(DB, sizeof(RLseDB));
      FreeAndNil(vdb);
    end;
  except
    vdb.HandleError;
    Result := -1;
  end;
end;

function vdb_release(DB: PLseDB): integer;cdecl;
var
  vdb: TVendorDB;
begin
  vdb := get_vdb(DB);
  try
    Dec(vdb.FRefcount);
    Result := vdb.FRefcount;
    if Result = 0 then
    begin
      FreeMem(DB, sizeof(RLseDB));
      FreeAndNil(vdb);
    end;
  except
    vdb.HandleError;
    Result := vdb.FRefcount;
  end;
end;

function vdb_getConnStr(DB: PLseDB): PLseString;cdecl;
var
  vdb: TVendorDB;
begin
  vdb := get_vdb(DB);
  try
    Result := lse_strec_alloc(vdb.FConnStr);
  except
    vdb.HandleError;
    Result := nil;
  end;
end;

procedure vdb_setConnStr(DB: PLseDB; const ConnString: pchar);cdecl;
var
  vdb: TVendorDB;
begin
  vdb := get_vdb(DB);
  try
    vdb.SetConnStr(ConnString);
  except
    vdb.HandleError;
  end;
end;

procedure vdb_connect(DB: PLseDB);cdecl;
var
  vdb: TVendorDB;
begin
  vdb := get_vdb(DB);
  try
    vdb.Open;
    try
      if vdb.FType = dbvMSSQL then
        if vdb.FUsedDB <> '' then
          vdb.ExecSQL('USE ' + vdb.FUsedDB);
    except
      vdb.Close;
      raise;
    end;
  except
    vdb.HandleError;
  end;
end;

function vdb_connected(DB: PLseDB): integer;cdecl;
var
  vdb: TVendorDB;
begin
  vdb := get_vdb(DB);
  try
    Result := Ord(vdb.Connected);
  except
    vdb.HandleError;
    Result := 0;
  end;
end;

procedure vdb_disconnect(DB: PLseDB);cdecl;
var
  vdb: TVendorDB;
begin
  vdb := get_vdb(DB);
  try
    if vdb.Connected then
      vdb.Close;
  except
    vdb.HandleError;
  end;
end;

function vdb_dataset(DB: PLseDB): PLseDS;cdecl;
var
  vdb: TVendorDB;
  vds: TVendorDS;
begin
  vdb := get_vdb(DB);
  try
    GetMem(Result, sizeof(RLseDS));
    FillChar(Result^, sizeof(RLseDS), 0);
    Result^.ds_size   := sizeof(RLseDS);
    vds := TVendorDS.Create(vdb);
    vds.Connection := vdb;
    vds.FDB := DB;
    vds.FDS := Result;
    Result^.ds_object   := vds;
    Result^.ds_db       := DB;
    Result^.ds_addref   := vds_addref;
    Result^.ds_release  := vds_release;
    Result^.ds_count    := vds_count;
    Result^.ds_getfn    := vds_getfn;
    Result^.ds_getft    := vds_getft;
    Result^.ds_getfi    := vds_getfi;
    Result^.ds_getfs    := vds_getfs;
    Result^.ds_getfd    := vds_getfd;
    Result^.ds_getfm    := vds_getfm;
    Result^.ds_getfb    := vds_getfb;
    Result^.ds_isnull   := vds_isnull;
    Result^.ds_length   := vds_length;
    Result^.ds_bof      := vds_bof;
    Result^.ds_eof      := vds_eof;
    Result^.ds_seek     := vds_seek;
    Result^.ds_getSQL   := vds_getSQL;
    Result^.ds_setSQL   := vds_setSQL;
    Result^.ds_open     := vds_open;
    Result^.ds_close    := vds_close;
    Result^.ds_active   := vds_active;
    Result^.ds_getBMK   := vds_getBMK;
    Result^.ds_gotoBMK  := vds_gotoBMK;
    Result^.ds_freeBMK  := vds_freeBMK;
  except
    vdb.HandleError;
    Result := nil;
  end;
end;

function vdb_execSQL(DB: PLseDB; const SQL: pchar): integer;cdecl;
var
  vdb: TVendorDB;
begin
  vdb := get_vdb(DB);
  try
    Result := vdb.ExecSQL(SQL);
  except
    vdb.HandleError;
    Result := -1;
  end;
end;

procedure vdb_transact(DB: PLseDB);cdecl;
var
  vdb: TVendorDB;
begin
  vdb := get_vdb(DB);
  try
    vdb.BeginTrans;
  except
    vdb.HandleError;
  end;
end;

function vdb_transacting(DB: PLseDB): integer;cdecl;
var
  vdb: TVendorDB;
begin
  vdb := get_vdb(DB);
  try
    Result := Ord(vdb.InTransaction);
  except
    vdb.HandleError;
    Result := 0;
  end;
end;

procedure vdb_commit(DB: PLseDB);cdecl;
var
  vdb: TVendorDB;
begin
  vdb := get_vdb(DB);
  try
    vdb.CommitTrans;
  except
    vdb.HandleError;
  end;
end;

procedure vdb_rollback(DB: PLseDB);cdecl;
var
  vdb: TVendorDB;
begin
  vdb := get_vdb(DB);
  try
    vdb.RollbackTrans;
  except
    vdb.HandleError;
  end;
end;

function vdb_storedprocs(DB: PLseDB): PLseString;cdecl;
var
  vdb: TVendorDB;
  list: TStrings;
begin
  vdb := get_vdb(DB);
  try
    list := TStringList.Create;
    try
      vdb.GetProcedureNames(list);
      Result := lse_strec_alloc(list.CommaText);
    finally
      list.Free;
    end;
  except
    vdb.HandleError;
    Result := nil;
  end;
end;

function vdb_tables(DB: PLseDB; IncSysTable: integer): PLseString;cdecl;
var
  vdb: TVendorDB;
  list: TStrings;
begin
  vdb := get_vdb(DB);
  try
    list := TStringList.Create;
    try
      vdb.GetTableNames(list, IncSysTable <> 0);
      Result := lse_strec_alloc(list.CommaText);
    finally
      list.Free;
    end;
  except
    vdb.HandleError;
    Result := nil;
  end;
end;

function vdb_fields(DB: PLseDB; const Table: pchar): PLseString;cdecl;
var
  vdb: TVendorDB;
  list: TStrings;
begin
  vdb := get_vdb(DB);
  try
    list := TStringList.Create;
    try
      vdb.GetFieldNames(Table, list);
      Result := lse_strec_alloc(list.CommaText);
    finally
      list.Free;
    end;
  except
    vdb.HandleError;
    Result := nil;
  end;
end;

// register --------------------------------------------------------------------

function vendor_create(VendorType: TVendorType): PLseDB;
var
  vdb: TVendorDB;
begin
  try
    GetMem(Result, sizeof(RLseDB));
    FillChar(Result^, sizeof(RLseDB), 0);
    Result^.db_size       := sizeof(RLseDB);
    vdb := TVendorDB.Create(nil);
    vdb.FDB := Result;
    vdb.FType := VendorType;
    Result^.db_object     := vdb;
    Result^.db_addref     := vdb_addref;
    Result^.db_release    := vdb_release;
    Result^.db_getConnStr := vdb_getConnStr;
    Result^.db_setConnStr := vdb_setConnStr;
    Result^.db_connect    := vdb_connect;
    Result^.db_connected  := vdb_connected;
    Result^.db_disconnect := vdb_disconnect;
    Result^.db_dataset    := vdb_dataset;
    Result^.db_execSQL    := vdb_execSQL;
    Result^.db_transact   := vdb_transact;
    Result^.db_transacting:= vdb_transacting;
    Result^.db_commit     := vdb_commit;
    Result^.db_rollback   := vdb_rollback;
    Result^.db_storedprocs:= vdb_storedprocs;
    Result^.db_tables     := vdb_tables;
    Result^.db_fields     := vdb_fields;
  except
    Result := nil;
  end;
end;

function vdb_odbc_create: PLseDB;cdecl;
begin
  Result := vendor_create(dbvODBC);
end;

function vdb_access_create: PLseDB;cdecl;
begin
  Result := vendor_create(dbvAccess);
end;

function vdb_mssql_create: PLseDB;cdecl;
begin
  Result := vendor_create(dbvMSSQL);
end;

var
  odbc_vendor, access_vendor, mssql_vendor: RLseDBVendor;
  odbc_registered  : boolean = false;
  access_registered: boolean = false;
  mssql_registered : boolean = false;

procedure register_dbv;
begin
  try
    register_dbv_odbc;
    register_dbv_access;
    register_dbv_mssql;
  except
    { safe exit }
  end;
end;

procedure register_dbv_odbc;
begin
  try
    if not odbc_registered then
    begin
      odbc_registered := true;
      odbc_vendor.dv_name  := 'odbc';
      odbc_vendor.dv_desc  := 'ODBC database vendor for lysee';
      odbc_vendor.dv_create:= vdb_odbc_create;
      lse_dbv_register(@odbc_vendor);
    end;
  except
    { safe exit }
  end;
end;

procedure register_dbv_access;
begin
  try
    if not access_registered then
    begin
      access_registered := true;
      access_vendor.dv_name  := 'access';
      access_vendor.dv_desc  := 'Microsoft Access database vendor for lysee';
      access_vendor.dv_create:= vdb_access_create;
      lse_dbv_register(@access_vendor);
    end;
  except
    { safe exit }
  end;
end;

procedure register_dbv_mssql;
begin
  try
    if not mssql_registered then
    begin
      mssql_registered := true;
      mssql_vendor.dv_name  := 'mssql';
      mssql_vendor.dv_desc  := 'Microsoft SQL Server vendor for lysee';
      mssql_vendor.dv_create:= vdb_mssql_create;
      lse_dbv_register(@mssql_vendor);
    end;
  except
    { safe exit }
  end;
end;

{ TVendorDB }

function TVendorDB.ExecSQL(const SQL: string): integer;
begin
  if FQuery = nil then
  begin
    FQuery := TADOQuery.Create(Self);
    FQuery.Connection := Self;
  end;
  FQuery.SQL.Text := SQL;
  try
    Result := FQuery.ExecSQL;
  finally
    FQuery.Close;
  end;
end;

procedure TVendorDB.HandleError;
begin
  if self <> nil then
  begin
    FError := lse_exception_str;
    FDB^.db_errno := 1;
    FDB^.db_error := pchar(FError);
  end;
end;

procedure TVendorDB.SetConnStr(const ConnectionStr: string);
var
  T, U, P, S, M: string;
  L: integer;
  
  procedure set_ODBC;
  begin
    if T = '' then
    begin
      T := S;
      if T = '' then
        lse_error('Target DSN not supplied');
    end;
    ConnectionString := Format(CSFMT, ['MSDASQL.1', U, P, T, M]);
  end;

  procedure set_ACCESS;
  begin
    if T = '' then
    begin
      T := S;
      if T = '' then
        lse_error('Target access file not supplied');
    end;
    U := '';
    ConnectionString := Format(CSFMT, ['Microsoft.Jet.OLEDB.4.0', U, P, T, M]);
  end;

  procedure set_MSSQL;
  begin
    FUsedDB := T;
    if U = '' then U := 'sa';
    if S = '' then S := 'localhost';
    ConnectionString := Format(CSFMT, ['SQLOLEDB.1', U, P, S, M]);
  end;

begin
  FUsedDB := '';
  FConnStr := Trim(ConnectionStr);
  L := Length(FConnStr);
  if (L > 6) and (FConnStr[1] = '[') and (FConnStr[L] = ']') then
  begin
    lse_decode_TUPSP(Copy(FConnStr, 2, L - 2), T, U, P, S, M);
    case FType of
      dbvODBC  : set_ODBC;
      dbvAccess: set_ACCESS;
      dbvMSSQL : set_MSSQL;
    end;
  end
  else lse_error('Invalid connection string: %s', [FConnStr]);
end;

{ TVendorDS }

procedure TVendorDS.HandleError;
begin
  if self <> nil then
  begin
    FError := lse_exception_str;
    FDS^.ds_errno := 1;
    FDS^.ds_error := pchar(FError);
  end;
end;

end.
