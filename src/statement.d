module dbc.statement;

debug import std.stdio;

import dbc.sqltypes;
import dbc.sql;
import dbc.handle;
import dbc.connection;

import std.stdint;
import std.conv : to;

import etc.c.odbc.sql;
import etc.c.odbc.sqlext;

class Statement : Handle
{
    this(Connection conn)
    {
        debug writeln("Begin Statement Constructor.");
        super(HandleType.Statement);

        this.allocate(conn.handle);
        debug writeln("End Statement Constructor.");
    }

    void tables(string_t catalog_name, string_t schema_name,
            string_t table_name, string_t table_type)
    {
        Tables(this.handle, catalog_name, schema_name, table_name, table_type);
    }

    void columns()
    {
    }

}
