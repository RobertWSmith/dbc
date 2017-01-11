module dbc.environment;

import dbc.sqltypes;
import dbc.sql;

import std.conv : to;

import etc.c.odbc.sqlext;

enum EnvironmentAttributes : int_t
{
    OdbcVersion = SQL_ATTR_ODBC_VERSION,
    ConnectionPooling = SQL_ATTR_CONNECTION_POOLING,
    ConnectionPoolMatch = SQL_ATTR_CP_MATCH,
}

enum OdbcVersion : int_t
{
    v3 = SQL_OV_ODBC3,
    v2 = SQL_OV_ODBC2,
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

struct Environment
{
    public enum HandleType handle_type = HandleType.Environment;
    package handle_t handle = cast(handle_t) null_handle;

    ~this()
    {
        this.free();
    }

    public @property bool isAllocated()
    {
        return checkAllocated(this.handle);
    }

    public void allocate()
    {
        import etc.c.odbc.sqlext : SQL_ATTR_ODBC_VERSION, SQL_OV_ODBC3;

        this.free();
        AllocHandle(this.handle_type, cast(handle_t) null_handle, &this.handle);

        this.setAttribute(EnvironmentAttributes.OdbcVersion, cast(pointer_t) OdbcVersion.v3);
    }

    public void free()
    {
        FreeHandle(this.handle_type, this.handle);
    }

    public void setAttribute(EnvironmentAttributes attr, pointer_t value_ptr,
            int_t buffer_length = 0)
    {
        SetAttribute(this.handle_type, this.handle, attr.to!int_t, value_ptr, buffer_length);
    }

    public void getAttribute(EnvironmentAttributes attr, pointer_t value_ptr,
            int_t buffer_length = 0, int_t* string_length_ptr = null)
    {
        GetAttribute(this.handle_type, this.handle, attr.to!int_t, value_ptr,
                buffer_length, string_length_ptr);
    }

    private @property void odbcVersion(OdbcVersion input)
    {
        int_t value = input;
        this.setAttribute(EnvironmentAttributes.OdbcVersion, &value);
    }

    public @property OdbcVersion odbcVersion()
    {
        OdbcVersion value;
        this.getAttribute(EnvironmentAttributes.OdbcVersion, &value);
        return value;
    }

}

Environment environment()
{
    Environment output;
    output.allocate();
    return output;
}

unittest
{
    Environment env = environment();

    assert(env.isAllocated, "Environment should be allocated upon construction.");
}
