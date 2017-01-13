// Written in the D programming language.
module dbc.connection;

debug import std.stdio;

import dbc.sqltypes;
import dbc.sql;
import dbc.handle;
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

enum InfoType : usmallint_t
{
    // Driver Information
    ActiveEnvironments = SQL_ACTIVE_ENVIRONMENTS,
    AsyncConnectionFunctions = SQL_ASYNC_DBC_FUNCTIONS,
    AsyncMode = SQL_ASYNC_MODE,
    AsyncNotification = SQL_ASYNC_NOTIFICATION,
    BatchRowCount = SQL_BATCH_ROW_COUNT,
    BatchSupport = SQL_BATCH_SUPPORT,
    DataSourceName = SQL_DATA_SOURCE_NAME,
    DriverAwarePoolingSupported = SQL_DRIVER_AWARE_POOLING_SUPPORTED,
    DriverConnection = SQL_DRIVER_HDBC,
    DriverDescription = SQL_DRIVER_HDESC,
    DriverEnvironment = SQL_DRIVER_HENV,
    DriverLibrary = SQL_DRIVER_HLIB,
    DriverStatement = SQL_DRIVER_HSTMT,
    DriverName = SQL_DRIVER_NAME,
    DriverOdbcVersion = SQL_DRIVER_ODBC_VER,
    DynamicCursorAttributes1 = SQL_DYNAMIC_CURSOR_ATTRIBUTES1,
    DynamicCursorAttributes2 = SQL_DYNAMIC_CURSOR_ATTRIBUTES2,
    ForwardOnlyCursorAttributes1 = SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES1,
    ForwardOnlyCursorAttributes2 = SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES2,
    FileUsage = SQL_FILE_USAGE,
    GetDataExtensions = SQL_GETDATA_EXTENSIONS,
    InfoSchemaViews = SQL_INFO_SCHEMA_VIEWS,
    KeysetCursorAttributes1 = SQL_KEYSET_CURSOR_ATTRIBUTES1,
    KeysetCursorAttributes2 = SQL_KEYSET_CURSOR_ATTRIBUTES2,
    MaxAsyncConcurrentStatements = SQL_MAX_ASYNC_CONCURRENT_STATEMENTS,
    MaxConcurrentActivities = SQL_MAX_CONCURRENT_ACTIVITIES,
    MaxDriverConnections = SQL_MAX_DRIVER_CONNECTIONS,
    OdbcInterfaceConformance = SQL_ODBC_INTERFACE_CONFORMANCE,
    OdbcStandardCLIConformance = SQL_ODBC_STANDARD_CLI_CONFORMANCE,
    OdbcVersion = SQL_ODBC_VER,
    ParameterArrayRowCounts = SQL_PARAM_ARRAY_ROW_COUNTS,
    ParameterArraySelects = SQL_PARAM_ARRAY_SELECTS,
    RowUpdates = SQL_ROW_UPDATES,
    SearchPatternEscape = SQL_SEARCH_PATTERN_ESCAPE,
    ServerName = SQL_SERVER_NAME,
    StaticCursorAttributes1 = SQL_STATIC_CURSOR_ATTRIBUTES1,
    StaticCursorAttributes2 = SQL_STATIC_CURSOR_ATTRIBUTES2,

    // DBMS Product Information
    DatabaseName = SQL_DATABASE_NAME,
    DBMSName = SQL_DBMS_NAME,
    DBMSVersion = SQL_DBMS_VER,

    // Data Source Information
    AccessibleProcedures = SQL_ACCESSIBLE_PROCEDURES,
    AccessibleTables = SQL_ACCESSIBLE_TABLES,
    BookmarkPersistence = SQL_BOOKMARK_PERSISTENCE,
    CatalogTerm = SQL_CATALOG_TERM,
    CollationSequence = SQL_COLLATION_SEQ,
    ConcatenateNullBehavior = SQL_CONCAT_NULL_BEHAVIOR,
    CursorCommitBehavior = SQL_CURSOR_COMMIT_BEHAVIOR,
    CursorRollbackBehavior = SQL_CURSOR_ROLLBACK_BEHAVIOR,
    CursorSensitivity = SQL_CURSOR_SENSITIVITY,
    DataSourceReadOnly = SQL_DATA_SOURCE_READ_ONLY,
    DefaultTransactionIsolation = SQL_DEFAULT_TXN_ISOLATION,
    DescribeParameter = SQL_DESCRIBE_PARAMETER,
    MultipleResultSets = SQL_MULT_RESULT_SETS,
    MultipleActiveTransactions = SQL_MULTIPLE_ACTIVE_TXN,
    NeedLongDataLength = SQL_NEED_LONG_DATA_LEN,
    NullCollation = SQL_NULL_COLLATION,
    ProcedureTerm = SQL_PROCEDURE_TERM,
    SchemaTerm = SQL_SCHEMA_TERM,
    ScrollOptions = SQL_SCROLL_OPTIONS,
    TableTerm = SQL_TABLE_TERM,
    TransactionCapable = SQL_TXN_CAPABLE,
    TransactionIsolationOption = SQL_TXN_ISOLATION_OPTION,
    UserName = SQL_USER_NAME,

}

class Connection : Handle
{
    package Environment _env;

    package this(uint_t login_timeout, OdbcCursors odbc_cursors, uint_t packet_size)
    {
        debug writeln("Begin Connection Constructor.");
        this._env = environment();

        super(HandleType.Connection);
        this.allocate(this._env.handle);

        this.loginTimeout = login_timeout;
        this.odbcCursors = odbc_cursors;
        this.packetSize = packet_size;
        debug writeln("End Connection Constructor.");
    }

    ~this()
    {
        debug writeln("Begin Connection Destructor.");
        this.p_free();
        this._env.p_free();
        debug writeln("End Connection Destructor.");
    }

    public void setAttribute(ConnectionAttributes attr, pointer_t value_ptr, int_t buffer_length = 0)
    {
        this.p_setAttribute(attr.to!int_t, value_ptr, buffer_length);
        // SetAttribute(this.handle_type, this.handle, attr.to!int_t, value_ptr, buffer_length);
    }

    public void getAttribute(ConnectionAttributes attr, pointer_t value_ptr,
            int_t buffer_length = 0, int_t* string_length_ptr = null)
    {
        this.p_getAttribute(attr.to!int_t, value_ptr, buffer_length, string_length_ptr);
        // GetAttribute(this.handleType, this.handle, attr.to!int_t, value_ptr, buffer_length, string_length_ptr);
    }

    public void getInfo(usmallint_t info_type, pointer_t info_value_ptr,
            smallint_t buffer_length = 0, smallint_t* string_length_ptr = null)
    {
        debug writefln("called `getInfo` info_type: %s", info_type);
        GetInfo(this.handle, info_type, info_value_ptr, buffer_length, string_length_ptr);
    }

    public void connect(string_t connection_string)
    {
        debug writefln("called `connect` connection_string: %s", connection_string);
        Connect(this.handle, connection_string);
    }

    public void connect(string_t server_name, string_t user_name, string_t authentication)
    {
        debug writefln("called `connect` server_name: %s user_name: %s authentication: %s",
                server_name, user_name, authentication);
        Connect(this.handle, server_name, user_name, authentication);
    }

    public void disconnect()
    {
        debug writeln("called `disconnect`");
        Disconnect(this.handle);
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
        this.setAttribute(ConnectionAttributes.AsyncEnabled, cast(pointer_t) value);
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
        this.setAttribute(ConnectionAttributes.AutoImportParameterDescription,
                cast(pointer_t) value);
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
        this.setAttribute(ConnectionAttributes.Autocommit, cast(pointer_t) value);
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
        this.getAttribute(ConnectionAttributes.ConnectionTimeout, cast(pointer_t) value);
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
        this.setAttribute(ConnectionAttributes.LoginTimeout, cast(pointer_t) input);
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
        this.setAttribute(ConnectionAttributes.MetadataID, cast(pointer_t) value);
    }

    public @property OdbcCursors odbcCursors()
    {
        ulen_t value;
        this.getAttribute(ConnectionAttributes.OdbcCursors, &value);
        return value.to!OdbcCursors;
    }

    private @property void odbcCursors(OdbcCursors input)
    {
        ulen_t value = input.to!OdbcCursors;
        this.setAttribute(ConnectionAttributes.OdbcCursors, cast(pointer_t) input);
    }

    public @property uint_t packetSize()
    {
        uint_t value;
        this.getAttribute(ConnectionAttributes.PacketSize, &value);
        return value;
    }

    public @property void packetSize(uint_t input)
    {
        this.setAttribute(ConnectionAttributes.PacketSize, cast(pointer_t) input);
    }

    public @property window_t quietMode()
    {
        window_t value;
        this.getAttribute(ConnectionAttributes.QuietMode, &value);
        return value;
    }

    public @property void quietMode(window_t input)
    {
        this.setAttribute(ConnectionAttributes.QuietMode, input);
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
        this.setAttribute(ConnectionAttributes.Trace, cast(pointer_t) value);
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
        int_t value;
        this.getAttribute(ConnectionAttributes.TransactionIsolation, &value);
        return value.to!TransactionIsolation;
    }

    public @property void transactionIsolation(TransactionIsolation input)
    {
        this.setAttribute(ConnectionAttributes.TransactionIsolation, cast(pointer_t) input);
    }
}

Connection connect(uint_t login_timeout = 0,
        OdbcCursors odbc_cursors = OdbcCursors.init, uint_t packet_size = 0)
{
    return new Connection(login_timeout, odbc_cursors, packet_size);
}

Connection connect(string_t connectionString, uint_t login_timeout = 0,
        OdbcCursors odbc_cursors = OdbcCursors.init, uint_t packet_size = 0)
{
    Connection conn = connect(login_timeout, odbc_cursors, packet_size);
    conn.connect(connectionString);
    return conn;
}

Connection connect(string_t serverName, string_t userName = null, string_t authentication = null,
        uint_t login_timeout = 0, OdbcCursors odbc_cursors = OdbcCursors.init, uint_t packet_size = 0)
{
    Connection conn = connect(login_timeout, odbc_cursors, packet_size);
    conn.connect(serverName, userName, authentication);
    return conn;
}

unittest
{
    Connection conn = connect();
    assert(conn.isAllocated);
    conn.destroy();
}
