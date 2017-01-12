// Written in the D programming language.
/**
Objects and Enums which manage and manipulate ODBC Environment handles.
 */

module dbc.environment;

debug import std.stdio;

import dbc.sqltypes;
import dbc.sql;

import std.conv : to;
import std.stdint : int32_t;

import etc.c.odbc.sqlext;

enum EnvironmentAttributes : int_t
{
    OdbcVersion = SQL_ATTR_ODBC_VERSION,
    ConnectionPooling = SQL_ATTR_CONNECTION_POOLING,
    ConnectionPoolMatch = SQL_ATTR_CP_MATCH,
}

enum OdbcVersion : int_t
{
    v3 = 3UL, // SQL_OV_ODBC3, // 3UL
    v2 = 2UL, // SQL_OV_ODBC2, // 2UL
    v3_80 = 380UL, // SQL_OV_ODBC3_80, // 380UL
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
struct Environment
{
    public enum HandleType handle_type = HandleType.Environment;
    public handle_t handle = cast(handle_t) null_handle;

    this(OdbcVersion ver)
    {
        this.handle = cast(handle_t) null_handle;
    }

    ~this()
    {
        this.free();
    }

    /**
     * Confirms if the environment handle is allocated.
     */
    public @property bool isAllocated()
    {
        return checkAllocated(this.handle);
    }

    /**
     * Allocated environment handle, attempting to free handle first in order
     * to ensure that existing handles aren't left dangling.
     */
    public void allocate()
    {
        import etc.c.odbc.sqlext : SQL_ATTR_ODBC_VERSION, SQL_OV_ODBC3;

        this.free();
        AllocHandle(this.handle_type, cast(handle_t) null_handle, &this.handle);
    }

    public void free()
    {
        FreeHandle(this.handle_type, this.handle);
    }

    public void setAttribute(EnvironmentAttributes attr, pointer_t value_ptr,
            int_t buffer_length = 0)
    {
        debug writefln("`setAttribute` called with EnvironmentAttributes: %s", attr);
        SetAttribute(this.handle_type, this.handle, attr.to!int_t, value_ptr, buffer_length);
    }

    public void getAttribute(EnvironmentAttributes attr, pointer_t value_ptr,
            int_t buffer_length = 0, int_t* string_length_ptr = null)
    {
        debug writefln("`getAttribute` called with EnvironmentAttributes: %s", attr);
        GetAttribute(this.handle_type, this.handle, attr.to!int_t, value_ptr,
                buffer_length, string_length_ptr);
    }

    private @property void odbcVersion(OdbcVersion input)
    {
        debug writefln("`odbcVersion` input property called with OdbcVersion: %s", input);

        int_t value = input.to!int_t;
        debug writefln("`odbcVersion` input property called with OdbcVersion (converted value): %s", value);
        this.setAttribute(EnvironmentAttributes.OdbcVersion, &value);
    }

    public @property OdbcVersion odbcVersion()
    {
        int_t value;
        this.getAttribute(EnvironmentAttributes.OdbcVersion, &value);
        return value.to!OdbcVersion;
    }
}

Environment environment()
{
    Environment output = Environment(OdbcVersion.v3);
    output.allocate();
    output.odbcVersion = OdbcVersion.v3;
    return output;
}

unittest
{
    Environment env = environment();

    assert(env.isAllocated, "Environment should be allocated upon construction.");
}
