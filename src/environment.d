// Written in the D programming language.
/**
Objects and Enums which manage and manipulate ODBC Environment handles.
 */

module dbc.environment;

debug import std.stdio;

import dbc.sqltypes;
import dbc.sql;
import dbc.handle;

import std.conv : to;
import std.stdint : int32_t;

import etc.c.odbc.sql;
import etc.c.odbc.sqlext;

enum EnvironmentAttributes : int_t
{
    OdbcVersion = SQL_ATTR_ODBC_VERSION,
    ConnectionPooling = SQL_ATTR_CONNECTION_POOLING,
    ConnectionPoolMatch = SQL_ATTR_CP_MATCH,
    OutputNullTerminatedStrings = SQL_ATTR_OUTPUT_NTS,
}

enum OdbcVersion : int_t
{
    v3 = SQL_OV_ODBC3.to!int_t, // 3UL
    v2 = SQL_OV_ODBC2.to!int_t, // 2UL
    v3_80 = 380UL.to!int_t, // SQL_OV_ODBC3_80
}

enum ConnectionPooling : uint_t
{
    Off = SQL_CP_OFF,
    OnePerDriver = SQL_CP_ONE_PER_DRIVER,
    OnePerEnvironment = SQL_CP_ONE_PER_HENV,
}

enum ConnectionPoolMatch : uint_t
{
    Strict = SQL_CP_STRICT_MATCH,
    Relaxed = SQL_CP_RELAXED_MATCH,
}

/**
Implements an ODBC Environment handle and associated manipulation functions and
properties. 
 */
class Environment : Handle
{
    this()
    {
        debug writeln("Begin Environment Constructor.");
        super(HandleType.Environment);
        debug writeln("End Environment Constructor.");
    }

    package void setAttribute(EnvironmentAttributes attr, pointer_t value_ptr,
            int_t buffer_length = 0)
    {
        debug writefln("`setAttribute` called with EnvironmentAttributes: %s isAllocated: %s",
                attr, this.isAllocated);
        this.p_setAttribute(attr.to!int_t, value_ptr, buffer_length);
        // SetAttribute(this.handle_type, this.handle, attr.to!int_t, value_ptr, buffer_length);
    }

    package void getAttribute(EnvironmentAttributes attr, pointer_t value_ptr,
            int_t buffer_length = 0, int_t* string_length_ptr = null)
    {
        debug writefln("`getAttribute` called with EnvironmentAttributes: %s isAllocated: %s",
                attr, this.isAllocated);
        this.p_getAttribute(attr.to!int_t, value_ptr, buffer_length, string_length_ptr);
        // GetAttribute(this.handle_type, this.handle, attr.to!int_t, value_ptr, buffer_length, string_length_ptr);
    }

    public @property OdbcVersion odbcVersion()
    {
        int_t value;
        this.getAttribute(EnvironmentAttributes.OdbcVersion, &value);
        return value.to!OdbcVersion;
    }

    package @property void odbcVersion(OdbcVersion input)
    {
        int_t value = input.to!int_t;

        debug writefln("`odbcVersion` input property called with OdbcVersion: %s Converted value: %s",
                input, value);

        this.setAttribute(EnvironmentAttributes.OdbcVersion, cast(pointer_t) value);
    }

    public @property bool ouputNullTerminatedStrings()
    {
        int_t value;
        this.getAttribute(EnvironmentAttributes.OutputNullTerminatedStrings, &value);
        return (value == SQL_TRUE);
    }

    public @property void outputNullTerminatedStrings(bool input)
    {
        int_t value = input ? SQL_TRUE : SQL_FALSE;
        this.setAttribute(EnvironmentAttributes.OutputNullTerminatedStrings, cast(pointer_t) value);
    }

    public @property ConnectionPoolMatch connectionPoolMatch()
    {
        SQLUINTEGER value;
        this.getAttribute(EnvironmentAttributes.ConnectionPoolMatch, &value);
        return value.to!ConnectionPoolMatch;
    }

    public @property void connectionPoolMatch(ConnectionPoolMatch input)
    {
        SQLUINTEGER value = input.to!SQLUINTEGER;
        this.setAttribute(EnvironmentAttributes.ConnectionPoolMatch, cast(pointer_t) value);
    }

    public @property ConnectionPooling connectionPooling()
    {
        SQLUINTEGER value;
        this.getAttribute(EnvironmentAttributes.ConnectionPooling, &value);
        return value.to!ConnectionPooling;
    }

    public @property void connectionPooling(ConnectionPooling input)
    {
        uint_t value = input.to!uint_t;
        this.setAttribute(EnvironmentAttributes.ConnectionPooling, cast(pointer_t) input);
    }
}

Environment environment()
{
    Environment output = new Environment();
    output.allocate();
    output.odbcVersion = OdbcVersion.v3;
    return output;
}

unittest
{
    Environment env = environment();

    assert(env.isAllocated, "Environment should be allocated upon construction.");
}
