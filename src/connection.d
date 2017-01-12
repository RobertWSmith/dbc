module dbc.connection;

import dbc.sqltypes;
import dbc.sql;
import dbc.environment;

import std.stdint;
import std.conv : to;

import etc.c.odbc.sql;
import etc.c.odbc.sqlext;

enum ConnectionAttributes : int_t
{
    AccessMode = SQL_ATTR_ACCESS_MODE,
    //AsyncConnectionEvent = SQL_ATTR_ASYNC_DBC_EVENT,
    //AsyncConnectionsFunctionsEnable = SQL_ATTR_ASYNC_DBC_FUNCTIONS_ENABLE,
    //AsyncConnectionPCallback = SQL_ATTR_ASYNC_DBC_PCALLBACK,
    //AsyncConnectionPContext = SQL_ATTR_ASYNC_DBC_PCONTEXT,
    AsyncEnabled = SQL_ATTR_ASYNC_ENABLE,
    AutoImportParameterDescription = SQL_ATTR_AUTO_IPD,
    Autocommit = SQL_ATTR_AUTOCOMMIT,

    ConnectionDead = SQL_ATTR_CONNECTION_DEAD,
    ConnectionTimeout = SQL_ATTR_CONNECTION_TIMEOUT,
    CurrentCatalog = SQL_ATTR_CURRENT_CATALOG,
    //ConnectionInfoToken = SQL_ATTR_DBC_INFO_TOKEN,

    //EnlistInDistributedTransactions = SQL_ATTR_ENLIST_IN_DTC,

    LoginTimeout = SQL_ATTR_LOGIN_TIMEOUT,

    MetadataID = SQL_ATTR_METADATA_ID,

    OdbcCursors = SQL_ATTR_ODBC_CURSORS,

    PacketSize = SQL_ATTR_PACKET_SIZE,

    QuietMode = SQL_ATTR_QUIET_MODE,

    Trace = SQL_ATTR_TRACE,
    Tracefile = SQL_ATTR_TRACEFILE,
    TranslateLib = SQL_ATTR_TRANSLATE_LIB,
    TranslateOption = SQL_ATTR_TRANSLATE_OPTION,
    TransactionIsolation = SQL_ATTR_TXN_ISOLATION,
}

enum AccessMode : uint_t
{
    ReadWrite = SQL_MODE_READ_WRITE, // Default
    ReadOnly = SQL_MODE_READ_ONLY,
}

enum OdbcCursors : ulen_t
{
    UseDriver = SQL_CUR_USE_DRIVER,
    UseIfNeeded = SQL_CUR_USE_IF_NEEDED,
    UseODBC = SQL_CUR_USE_ODBC,
}

enum TransactionIsolation : uint_t
{
    ReadUncommitted = SQL_TXN_READ_UNCOMMITTED,
    ReadCommitted = SQL_TXN_READ_COMMITTED,
    RepeatableRead = SQL_TXN_REPEATABLE_READ,
    Serializable = SQL_TXN_SERIALIZABLE,
}

struct Connection
{
    public enum HandleType handle_type = HandleType.Connection;
    package handle_t handle = cast(handle_t) null_handle;
    public Environment _env;

    this(uint_t login_timeout, OdbcCursors odbc_cursors, uint_t packet_size)
    {
        this._env = environment();

        this.allocate();
        this.loginTimeout = login_timeout;
        this.odbcCursors = odbc_cursors;
        this.packetSize = packet_size;
    }

    ~this()
    {
        this.free();
    }

    public void allocate()
    {
        import etc.c.odbc.sqlext : SQL_ATTR_ODBC_VERSION, SQL_OV_ODBC3;

        this._env.allocate();

        this.free();
        AllocHandle(this.handle_type, this._env.handle, &handle);
    }

    public void free()
    {
        FreeHandle(this.handle_type, this.handle);
        this._env.free();
    }

    public void setAttribute(ConnectionAttributes attr, pointer_t value_ptr, int_t buffer_length = 0)
    {
        SetAttribute(this.handle_type, this.handle, attr.to!int_t, value_ptr, buffer_length);
    }

    public void getAttribute(ConnectionAttributes attr, pointer_t value_ptr,
            int_t buffer_length = 0, int_t* string_length_ptr = null)
    {
        GetAttribute(this.handle_type, this.handle, attr.to!int_t, value_ptr,
                buffer_length, string_length_ptr);
    }

    public @property AccessMode accessMode()
    {
        AccessMode value;
        this.getAttribute(ConnectionAttributes.AccessMode, &value);
        return value;
    }

    public @property void accessMode(AccessMode input)
    {
        this.setAttribute(ConnectionAttributes.AccessMode, cast(pointer_t) input);
    }

    public @property bool asyncEnabled()
    {
        ulen_t value;
        this.getAttribute(ConnectionAttributes.AsyncEnabled, &value);
        return value == SQL_ASYNC_ENABLE_ON;
    }

    public @property void asyncEnabled(bool input)
    {
        ulen_t value = input ? SQL_ASYNC_ENABLE_ON : SQL_ASYNC_ENABLE_OFF;
        this.setAttribute(ConnectionAttributes.AsyncEnabled, &value);
    }

    public @property bool autoImportParameterDescription()
    {
        uint_t value;
        this.getAttribute(ConnectionAttributes.AutoImportParameterDescription, &value);
        return (value == SQL_TRUE);
    }

    public @property void autoImportParameterDescription(bool input)
    {
        uint_t value = input ? SQL_TRUE : SQL_FALSE;
        this.setAttribute(ConnectionAttributes.AutoImportParameterDescription, &value);
    }

    public @property bool autocommit()
    {
        uint_t value;
        this.getAttribute(ConnectionAttributes.Autocommit, &value);
        return (value == SQL_AUTOCOMMIT_ON);
    }

    public @property void autocommit(bool input)
    {
        uint_t value = input ? SQL_AUTOCOMMIT_ON : SQL_AUTOCOMMIT_OFF;
        this.setAttribute(ConnectionAttributes.Autocommit, &value);
    }

    public @property bool connectionDead()
    {
        uint_t value;
        this.getAttribute(ConnectionAttributes.ConnectionDead, &value);
        return (value == SQL_CD_TRUE);
    }

    public @property uint_t connectionTimeout()
    {
        uint_t value;
        this.getAttribute(ConnectionAttributes.ConnectionTimeout, &value);
        return value;
    }

    public @property void connectionTimeout(uint_t input)
    {
        this.setAttribute(ConnectionAttributes.ConnectionTimeout, &input);
    }

    public @property string_t currentCatalog()
    {
        char_t[1024 + 1] value;

        this.getAttribute(ConnectionAttributes.CurrentCatalog, value.ptr,
                to!int_t(value.length - 1));
        return str_conv(value.ptr);
    }

    public @property void currentCatalog(string_t input)
    {
        char_t[] value = str_conv(input);
        this.setAttribute(ConnectionAttributes.CurrentCatalog, value.ptr, SQL_NTS);
    }

    public @property uint_t loginTimeout()
    {
        uint_t value;
        this.getAttribute(ConnectionAttributes.LoginTimeout, &value);
        return value;
    }

    private @property void loginTimeout(uint_t input)
    {
        this.setAttribute(ConnectionAttributes.LoginTimeout, &input);
    }

    public @property bool metadataID()
    {
        uint_t value;
        this.getAttribute(ConnectionAttributes.MetadataID, &value);
        return (value == SQL_TRUE);
    }

    public @property void metadataID(bool input)
    {
        uint_t value = input ? SQL_TRUE : SQL_FALSE;
        this.setAttribute(ConnectionAttributes.MetadataID, &value);
    }

    public @property OdbcCursors odbcCursors()
    {
        OdbcCursors value;
        this.getAttribute(ConnectionAttributes.OdbcCursors, &value);
        return value;
    }

    private @property void odbcCursors(OdbcCursors input)
    {
        this.setAttribute(ConnectionAttributes.OdbcCursors, &input);
    }

    public @property uint_t packetSize()
    {
        uint_t value;
        this.getAttribute(ConnectionAttributes.PacketSize, &value);
        return value;
    }

    public @property void packetSize(uint_t input)
    {
        this.setAttribute(ConnectionAttributes.PacketSize, &input);
    }

    public @property window_t quietMode()
    {
        window_t value;
        this.getAttribute(ConnectionAttributes.QuietMode, &value);
        return value;
    }

    public @property void quietMode(window_t input)
    {
        this.setAttribute(ConnectionAttributes.QuietMode, &input);
    }

    public @property bool trace()
    {
        uint_t value;
        this.getAttribute(ConnectionAttributes.Trace, &value);
        return (value == SQL_OPT_TRACE_ON);
    }

    public @property void trace(bool input)
    {
        uint_t value = input ? SQL_OPT_TRACE_ON : SQL_OPT_TRACE_OFF;
        this.setAttribute(ConnectionAttributes.Trace, &value);
    }

    public @property string_t tracefile()
    {
        char_t[1024 + 1] value;
        this.getAttribute(ConnectionAttributes.Tracefile, value.ptr, value.length - 1);
        return str_conv(value.ptr);
    }

    public @property void tracefile(string_t input)
    {
        char_t[] value = str_conv(input);
        this.setAttribute(ConnectionAttributes.Tracefile, value.ptr, SQL_NTS);
    }

    public @property TransactionIsolation transactionIsolation()
    {
        TransactionIsolation value;
        this.getAttribute(ConnectionAttributes.TransactionIsolation, &value);
        return value;
    }

    public @property void transactionIsolation(TransactionIsolation input)
    {
        this.setAttribute(ConnectionAttributes.TransactionIsolation, &input);
    }

}
