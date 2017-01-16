// Written in the D programming language.
module dbc.sqltypes;

import std.stdint;

import etc.c.odbc.sqltypes;

// api type aliases
alias handle_t = SQLHANDLE;
alias pointer_t = SQLPOINTER;
alias window_t = SQLPOINTER;

enum handle_t null_handle = cast(SQLHANDLE) 0L;

alias return_t = SQLRETURN;

alias bookmark_t = BOOKMARK;
alias varbookmark_t = ubyte;
alias guid_t = SQLGUID;
// api type aliases

// character and strings
alias char_t = SQLCHAR;
alias schar_t = SQLSCHAR;
alias varchar_t = SQLVARCHAR;

alias wchar_t = SQLWCHAR;
alias tchar_t = SQLTCHAR;

alias string_t = immutable(char_t)[];
// character and strings

// date and time
alias date_t = SQLDATE;
alias date_struct_t = SQL_DATE_STRUCT;

alias time_t = SQLTIME;
alias time_struct_t = SQL_TIME_STRUCT;

alias timestamp_t = SQLTIMESTAMP;
alias timestamp_struct_t = SQL_TIMESTAMP_STRUCT;

alias interval_struct_t = SQL_INTERVAL_STRUCT;
// date and time

// integral
alias tinyint_t = int8_t;
alias utinyint_t = uint8_t;

alias smallint_t = int16_t;
alias usmallint_t = uint16_t;

alias int_t = int32_t;
alias uint_t = uint32_t;

alias bigint_t = int64_t;
alias ubigint_t = uint64_t;

version (X86_64)
{
    alias len_t = int64_t;
    alias ulen_t = uint64_t;
    alias setposirow_t = ulen_t;
}
else
{
    alias len_t = int_t;
    alias ulen_t = uint_t;
    alias setposirow_t = usmallint_t;
}
// integral

// floating point
alias real_t = SQLREAL;
alias float_t = SQLFLOAT;
alias double_t = SQLDOUBLE;
alias decimal_t = SQLDECIMAL;
alias numeric_t = SQLNUMERIC;
alias numeric_struct_t = SQL_NUMERIC_STRUCT;
// floating point
