module dbc.connection;

import dbc.sqltypes;
import dbc.sql;
import dbc.environment;

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

struct Connection
{
    public enum HandleType handle_type = HandleType.Connection;
    package handle_t handle = cast(handle_t) null_handle;
    private Environment _env = environment();

    package @property handle_t environmentHandle()
    {
        this._env.handle;
    }

    public void allocate()
    {
        import etc.c.odbc.sqlext : SQL_ATTR_ODBC_VERSION, SQL_OV_ODBC3;

        this.free();
        AllocHandle(this.handle_type, this.environmentHandle, &handle);
    }

    public void free()
    {
        FreeHandle(this.handle_type, this.handle);
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

    public @property void loginTimeout(uint_t input)
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

    public @property void odbcCursors(OdbcCursors input)
    {
        this.setAttribute(ConnectionAttributes.OdbcCursors, &value);
    }
}
