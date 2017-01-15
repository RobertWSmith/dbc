// Written in the D programming language.
module dbc.sql;

debug import std.stdio;

debug import std.traits;

debug import std.string;

import dbc.sqltypes;

import std.conv : to;

import etc.c.odbc.sql;

pragma(lib, "odbc32");

class OdbcException : Exception
{
    this(HandleType type, handle_t handle, string file = __FILE__,
            uint line = __LINE__, Throwable next = null)
    {
        debug import std.stdio;

        string message;
        string temp;
        foreach (diag; ExtractError(type, handle))
        {
            if (message.length > 0)
                message ~= '\n';
            temp = diag.toString;

            debug writeln(temp);

            message ~= temp;
        }
        super(message, file, line, next);
    }
}

bool checkAllocated(handle_t handle)
{
    return (handle !is cast(handle_t) null);
}

enum SqlReturn : return_t
{
    Success = SQL_SUCCESS,
    SuccessWithInfo = SQL_SUCCESS_WITH_INFO,
    Error = SQL_ERROR,
    InvalidHandle = SQL_INVALID_HANDLE,
    NoData = SQL_NO_DATA,
    NeedData = SQL_NEED_DATA,
    StillExecuting = SQL_STILL_EXECUTING,
}

//void checkSucceeded(T)(T rc)
//{
//    if (succeeded(rc))
//    {
//        throw new Exception();
//    }
//}

bool succeeded(T : SqlReturn)(T rc)
{
    import std.conv : to;

    debug writefln("called `succeeded` value: %s", rc);

    return SQL_SUCCEEDED(to!SQLRETURN(rc));
}

bool succeeded(T : SQLRETURN)(T rc)
{
    return succeeded(rc.to!SqlReturn);
}

enum HandleType : smallint_t
{
    Connection = SQL_HANDLE_DBC,
    Description = SQL_HANDLE_DESC,
    Environment = SQL_HANDLE_ENV,
    Statement = SQL_HANDLE_STMT,
}

struct Diagnostics
{
    smallint_t record;
    int_t native_error;
    string_t sql_state;
    string_t message_text;

    this(smallint_t record, int_t native_error, char_t* state, char_t* message)
    {
        this.record = record;
        this.native_error = native_error;
        this.sql_state = str_conv(state);
        this.message_text = str_conv(message);
    }

    @property string_t toString()
    {
        import std.string : format;

        return format("[%s] %s Native Error: %s", this.sql_state,
                this.message_text, this.native_error);
    }
}

Diagnostics[] ExtractError(HandleType handleType, handle_t handle)
{
    debug writeln("called `ExtractError`");
    Diagnostics[] output;
    smallint_t i = 1;
    int_t nativeError = 0;
    char_t[6 + 1] state;
    char_t[256 + 1] message;
    return_t rc = SQL_SUCCESS;

    while (true)
    {
        state[] = '\0';
        message[] = '\0';
        rc = SQLGetDiagRec(handleType.to!smallint_t, handle, i, state.ptr,
                &nativeError, message.ptr, message.sizeof.to!smallint_t, cast(smallint_t*) null);
        if (succeeded(rc))
            output ~= Diagnostics(i, nativeError, state.ptr, message.ptr);
        else
            break;

        i++;
    }
    return output;
}

void AllocHandle(HandleType handleType, handle_t inputHandle, handle_t* outputHandle)
{
    debug writefln("called `AllocHandle` w/ HandleType: %s", handleType);

    if (!succeeded(SQLAllocHandle(handleType.to!smallint_t, inputHandle, outputHandle)))
    {
        throw new OdbcException(handleType, &outputHandle);
    }
}

void FreeHandle(HandleType handleType, handle_t handle)
{
    debug writefln("called `FreeHandle` w/ HandleType: %s", handleType);
    if (checkAllocated(handle))
    {
        SQLRETURN rc;
        switch (handleType)
        {
        default:
            break;

        case HandleType.Connection:
            rc = SQLDisconnect(handle);
            debug
            {
                if (!succeeded(rc))
                    foreach (e; ExtractError(handleType, handle))
                        writeln(e.toString);
            }
            break;
        }

        rc = SQLFreeHandle(handleType.to!smallint_t, handle);
        debug
        {
            if (!succeeded(rc) && (rc != SQL_INVALID_HANDLE))
            {
                foreach (e; ExtractError(handleType, handle))
                    writeln(e.toString);
            }
            // throw new OdbcException(handleType, handle);
        }
    }
}

unittest
{
    HandleType typ = HandleType.Environment;
    handle_t handle = SQL_NULL_HANDLE;
    assert(handle == SQL_NULL_HANDLE, "If the handle isn't null, we have an issue");

    AllocHandle(typ, SQL_NULL_HANDLE, &handle);
    assert(handle != SQL_NULL_HANDLE, "Handle must be set to not null after `AllocHandle`");

    FreeHandle(typ, handle);
}

handle_t SetAttribute(HandleType handleType, handle_t handle, int_t attribute,
        pointer_t value_ptr, int_t buffer_length)
{
    debug string line = format("called `SetAttribute` w/ HandleType: %s", handleType);

    SQLRETURN rc;
    final switch (handleType)
    {
    case HandleType.Connection:
        debug line ~= format(" function: `%s`",
                fullyQualifiedName!SQLSetConnectAttr);
        rc = SQLSetConnectAttr(handle, attribute, value_ptr, buffer_length);
        break;

    case HandleType.Description:
        break;

    case HandleType.Environment:
        debug line ~= format(" function: `%s`",
                fullyQualifiedName!SQLSetEnvAttr);
        rc = SQLSetEnvAttr(handle, attribute, value_ptr, buffer_length);
        break;

    case HandleType.Statement:
        debug line ~= format(" function: `%s`",
                fullyQualifiedName!SQLSetStmtAttr);
        rc = SQLSetStmtAttr(handle, attribute, value_ptr, buffer_length);
        break;
    }

    debug writeln(line);

    if (!succeeded(rc))
    {
        throw new OdbcException(handleType, handle);
    }
    return handle;
}

handle_t GetAttribute(HandleType handleType, handle_t handle, int_t attribute,
        pointer_t value_ptr, int_t buffer_length, int_t* string_length_ptr)
{
    debug string line = format("called `GetAttribute` w/ HandleType: %s", handleType);

    SQLRETURN rc;
    final switch (handleType)
    {
    case HandleType.Connection:
        rc = SQLGetConnectAttr(handle, attribute,
                value_ptr, buffer_length, string_length_ptr);
        break;

    case HandleType.Description:
        break;

    case HandleType.Environment:
        rc = SQLGetEnvAttr(handle, attribute,
                value_ptr, buffer_length, string_length_ptr);
        break;

    case HandleType.Statement:
        rc = SQLGetStmtAttr(handle, attribute, value_ptr,
                buffer_length, string_length_ptr);
        break;
    }

    if (!succeeded(rc))
    {
        throw new OdbcException(handleType, handle);
    }
    return handle;
}

unittest
{
    import etc.c.odbc.sqlext : SQL_ATTR_ODBC_VERSION, SQL_OV_ODBC3;

    HandleType typ = HandleType.Environment;
    handle_t handle = SQL_NULL_HANDLE;
    assert(handle == SQL_NULL_HANDLE, "If the handle isn't null, we have an issue");

    AllocHandle(typ, SQL_NULL_HANDLE, &handle);
    assert(handle != SQL_NULL_HANDLE, "Handle must be set to not null after `AllocHandle`");

    SetAttribute(typ, handle, cast(int_t) SQL_ATTR_ODBC_VERSION, cast(pointer_t) SQL_OV_ODBC3, 0);

    int_t odbc_version;
    GetAttribute(typ, handle, cast(int_t) SQL_ATTR_ODBC_VERSION, &odbc_version, 0, null);

    assert(odbc_version == cast(int_t) SQL_OV_ODBC3,
            "Must be able to set and get same value from call to `SetAttribute` and `GetAttribute`");

    FreeHandle(typ, handle);
}

handle_t GetInfo(handle_t connectionHandle, usmallint_t infoType,
        pointer_t infoValuePtr, smallint_t bufferLength, smallint_t* stringLengthPtr)
{
    debug writefln("calling `GetInfo`");
    if (!succeeded(SQLGetInfo(connectionHandle, infoType, infoValuePtr,
            bufferLength, stringLengthPtr)))
    {
        throw new OdbcException(HandleType.Connection, connectionHandle);
    }
    return connectionHandle;
}

char_t[] str_conv(string_t input)
{
    import std.string : toStringz;
    import std.conv : to;

    return to!(char_t[])(toStringz(input));
}

string_t str_conv(char_t* input)
{
    import std.string : fromStringz;
    import std.conv : to;

    return to!string_t(fromStringz(input));
}

struct SqlDriver
{
    string_t driver;
    string_t attributes;

    this(char_t* drv, char_t* attr)
    {
        this.driver = str_conv(drv);
        this.attributes = str_conv(attr);
    }

    @property string_t toString()
    {
        import std.string : format;

        return format("%s %s", this.driver, this.attributes);
    }
}

SqlDriver[] Drivers(handle_t environmentHandle)
{
    debug writeln("called `Drivers`");
    import etc.c.odbc.sqlext : SQLDrivers;

    SqlDriver[] output;
    SQLRETURN rc = SQL_SUCCESS;
    usmallint_t direction = SQL_FETCH_FIRST;

    char_t[128 + 1] driver;
    smallint_t driver_len = driver.length - 1;

    char_t[1024 + 1] attributes;
    smallint_t attributes_len = attributes.length - 1;

    while (rc != SQL_NO_DATA)
    {
        driver[] = '\0';
        attributes[] = '\0';

        rc = SQLDrivers(environmentHandle, direction, driver.ptr, driver_len,
                null, attributes.ptr, attributes_len, null);

        if (!(succeeded(rc) || (rc == SQL_NO_DATA)))
        {
            throw new OdbcException(HandleType.Environment, environmentHandle);
        }

        if (rc != SQL_NO_DATA)
            output ~= SqlDriver(driver.ptr, attributes.ptr);
        else
            break;

        direction = SQL_FETCH_NEXT;
    }
    return output;
}

unittest
{
    import std.stdio : writeln;
    import etc.c.odbc.sqlext : SQL_ATTR_ODBC_VERSION, SQL_OV_ODBC3;

    HandleType typ = HandleType.Environment;
    handle_t handle = SQL_NULL_HANDLE;

    AllocHandle(typ, SQL_NULL_HANDLE, &handle);
    SetAttribute(typ, handle, cast(int_t) SQL_ATTR_ODBC_VERSION, cast(pointer_t) SQL_OV_ODBC3, 0);

    SqlDriver[] drivers = Drivers(handle);
    assert(drivers.length > 0);

    FreeHandle(typ, handle);
}

struct SqlDataSource
{
    string_t server_name;
    string_t description;
    this(char_t* server, char_t* descr)
    {
        this.server_name = str_conv(server);
        this.description = str_conv(descr);
    }

    @property string_t toString()
    {
        import std.string : format;

        return format("%s %s", this.server_name, this.description);
    }
}

enum ReturnDataSources
{
    All,
    User,
    System
}

SqlDataSource[] DataSources(handle_t environmentHandle,
        ReturnDataSources dataSources = ReturnDataSources.All)
{
    debug writefln("called `DataSources` dataSources: %s", dataSources);
    import etc.c.odbc.sqlext : SQL_FETCH_FIRST_USER, SQL_FETCH_FIRST_SYSTEM;

    SqlDataSource[] output;
    SQLRETURN rc;
    usmallint_t direction;

    char_t[128 + 1] server;
    smallint_t server_len = (server.length - 1);

    char_t[1024 + 1] description;
    smallint_t description_len = (description.length - 1);

    switch (dataSources)
    {
    default:
    case ReturnDataSources.All:
        direction = SQL_FETCH_FIRST;
        break;
    case ReturnDataSources.User:
        direction = SQL_FETCH_FIRST_USER;
        break;
    case ReturnDataSources.System:
        direction = SQL_FETCH_FIRST_SYSTEM;
        break;
    }

    while (rc != SQL_NO_DATA)
    {
        server[] = '\0';
        description[] = '\0';
        rc = SQLDataSources(environmentHandle, direction, server.ptr,
                server_len, null, description.ptr, description_len, null);

        if (!(succeeded(rc) || (rc == SQL_NO_DATA)))
        {
            throw new OdbcException(HandleType.Environment, environmentHandle);
        }

        if (rc != SQL_NO_DATA)
            output ~= SqlDataSource(server.ptr, description.ptr);
        else
            break;
        direction = SQL_FETCH_NEXT;
    }
    return output;
}

unittest
{
    import std.stdio : writeln;
    import etc.c.odbc.sqlext : SQL_ATTR_ODBC_VERSION, SQL_OV_ODBC3;

    HandleType typ = HandleType.Environment;
    handle_t handle = SQL_NULL_HANDLE;

    AllocHandle(typ, SQL_NULL_HANDLE, &handle);
    SetAttribute(typ, handle, cast(int_t) SQL_ATTR_ODBC_VERSION, cast(pointer_t) SQL_OV_ODBC3, 0);

    SqlDataSource[] all_data_sources = DataSources(handle, ReturnDataSources.All);
    assert(all_data_sources.length >= 0);

    SqlDataSource[] user_data_sources = DataSources(handle, ReturnDataSources.User);
    assert(all_data_sources.length >= 0);

    SqlDataSource[] system_data_sources = DataSources(handle, ReturnDataSources.System);
    assert(all_data_sources.length >= 0);

    FreeHandle(typ, handle);
}

handle_t Connect(handle_t connectionHandle, string_t serverName,
        string_t userName, string_t authentication)
{
    alias sql_func = SQLConnect;
    debug writefln("called `Connect` w/ function: %s args: %s %s %s",
            fullyQualifiedName!sql_func, serverName, userName, authentication);

    char_t[] server = str_conv(serverName);
    char_t[] user = str_conv(userName);
    char_t[] auth = str_conv(authentication);

    if (!succeeded(sql_func(connectionHandle, server.ptr, SQL_NTS, user.ptr,
            SQL_NTS, auth.ptr, SQL_NTS)))
    {
        throw new OdbcException(HandleType.Connection, connectionHandle);
    }
    return connectionHandle;
}

handle_t Connect(handle_t connectionHandle, string_t connectionString)
{
    import etc.c.odbc.sqlext : SQLDriverConnect, SQL_DRIVER_COMPLETE;

    alias sql_func = SQLDriverConnect;
    debug writefln("called `Connect` w/ function: %s arg: %s",
            fullyQualifiedName!sql_func, connectionString);

    char_t[] cstr = str_conv(connectionString);
    if (!succeeded(sql_func(connectionHandle, cast(pointer_t) null, cstr.ptr,
            SQL_NTS, cast(char_t*) null, 0, cast(smallint_t*) null, SQL_DRIVER_COMPLETE)))
    {
        throw new OdbcException(HandleType.Connection, connectionHandle);
    }
    return connectionHandle;
}

handle_t Disconnect(handle_t connectionHandle)
{
    debug writeln("called `Disconnect`");
    SQLRETURN rc = SQLDisconnect(connectionHandle);
    debug
    {
        if (!succeeded(rc))
        {
            foreach (e; ExtractError(HandleType.Connection, connectionHandle))
                writefln(e.toString);
        }
    }
    return connectionHandle;
}

handle_t BindColumn(handle_t statementHandle, usmallint_t columnNbr, smallint_t targetType,
        pointer_t targetValuePtr, int_t bufferLength = 0, int_t* strLen_or_IndPtr = null)
{
    debug writefln("called `BindColumn` columnNbr: %s", columnNbr);
    if (!succeeded(SQLBindCol(statementHandle, columnNbr, targetType,
            targetValuePtr, bufferLength, strLen_or_IndPtr)))
    {
        throw new OdbcException(HandleType.Statement, statementHandle);
    }
    return statementHandle;
}

handle_t BindParameter(handle_t statementHandle, usmallint_t parameterNbr,
        smallint_t inputOutputType, smallint_t valueType, smallint_t parameterType,
        usmallint_t columnSize, smallint_t decimalDigits, pointer_t parameterValuePtr,
        int_t bufferLength = 0, int_t* strLen_Or_IndPtr = null)
{
    debug writefln("called `BindParameter` parameterNbr: %s", parameterNbr);
    import etc.c.odbc.sqlext : SQLBindParameter;

    if (!succeeded(SQLBindParameter(statementHandle, parameterNbr, inputOutputType, valueType, parameterType,
            columnSize, decimalDigits, parameterValuePtr, bufferLength, strLen_Or_IndPtr)))
    {
        throw new OdbcException(HandleType.Statement, statementHandle);
    }
    return statementHandle;
}

handle_t ExecuteDirect(handle_t statementHandle, string_t statementText)
{
    debug writefln("called `ExecuteDirect` statementText: %s", statementText);
    char_t[] stmt = str_conv(statementText);
    if (!succeeded(SQLExecDirect(statementHandle, stmt.ptr, SQL_NTS)))
    {
        throw new OdbcException(HandleType.Statement, statementHandle);
    }
    return statementHandle;
}

handle_t Execute(handle_t statementHandle)
{
    debug writeln("called `Execute`");
    if (!succeeded(SQLExecute(statementHandle)))
    {
        throw new OdbcException(HandleType.Statement, statementHandle);
    }
    return statementHandle;
}

enum CompletionType : smallint_t
{
    Commit = SQL_COMMIT,
    Rollback = SQL_ROLLBACK,
}

handle_t EndTransaction(HandleType handleType, handle_t handle,
        CompletionType completionType = CompletionType.Commit)
{
    debug writefln("called `EndTransaction` handleType: %s completionType: %s",
            handleType, completionType);
    assert(handleType == HandleType.Environment || handleType == HandleType.Connection);

    if (!succeeded(SQLEndTran(handleType.to!SQLSMALLINT, handle, completionType.to!SQLSMALLINT)))
    {
        throw new OdbcException(handleType, handle);
    }
    return handle;
}

handle_t CloseCursor(handle_t statementHandle)
{
    debug writeln("called `CloseCursor`");
    if (!succeeded(SQLCloseCursor(statementHandle)))
    {
        throw new OdbcException(HandleType.Statement, statementHandle);
    }
    return statementHandle;
}

handle_t Cancel(handle_t statementHandle)
{
    debug writeln("called `Cancel`");

    if (!succeeded(SQLCancel(statementHandle)))
    {
        throw new OdbcException(HandleType.Statement, statementHandle);
    }
    return statementHandle;
}

handle_t Prepare(handle_t statementHandle, string_t statementText)
{
    debug writefln("called `Prepare` statementText: %s", statementText);
    char_t[] stmt = str_conv(statementText);
    if (!succeeded(SQLPrepare(statementHandle, stmt.ptr, SQL_NTS)))
    {
        throw new OdbcException(HandleType.Statement, statementHandle);
    }
    return statementHandle;
}

enum FetchOrientation : smallint_t
{
    Next = SQL_FETCH_NEXT,
    Prior = SQL_FETCH_PRIOR,
    First = SQL_FETCH_FIRST,
    Last = SQL_FETCH_LAST,
    Absolute = SQL_FETCH_ABSOLUTE,
    Relative = SQL_FETCH_RELATIVE, // Bookmark = SQL_FETCH_BOOKMARK,
}

handle_t Fetch(handle_t statementHandle)
{
    debug writeln("called `Fetch`");
    if (!succeeded(SQLFetch(statementHandle)))
    {
        throw new OdbcException(HandleType.Statement, statementHandle);
    }
    return statementHandle;
}

handle_t FetchScroll(handle_t statementHandle,
        FetchOrientation fetchOrientation = FetchOrientation.Next, int_t offset = 0)
{
    debug writefln("called `FetchScroll` fetchOrientation: %s offset: %s", fetchOrientation, offset);
    if (!succeeded(SQLFetchScroll(statementHandle, fetchOrientation.to!smallint_t, offset)))
    {
        throw new OdbcException(HandleType.Statement, statementHandle);
    }
    return statementHandle;
}

handle_t ExtendedFetch(handle_t statementHandle, FetchOrientation fetchOrientation = FetchOrientation.Next,
        int_t offset = 0, usmallint_t* rowCountPtr = null, usmallint_t* rowStatusArray = null)
{
    import etc.c.odbc.sqlext : SQLExtendedFetch;

    debug writefln("called `ExtendedFetch` fetchOrientation: %s offset: %s",
            fetchOrientation, offset);
    if (!succeeded(SQLExtendedFetch(statementHandle,
            fetchOrientation.to!usmallint_t, offset, rowCountPtr, rowStatusArray)))
    {
        throw new OdbcException(HandleType.Statement, statementHandle);
    }
    return statementHandle;
}

handle_t SetCursorName(handle_t statementHandle, string_t cursorName)
{
    debug writefln("called `SetCursorName` cursorName: %s", cursorName);
    char_t[] name = str_conv(cursorName);
    if (!succeeded(SQLSetCursorName(statementHandle, name.ptr, SQL_NTS)))
    {
        throw new OdbcException(HandleType.Statement, statementHandle);
    }
    return statementHandle;
}

handle_t GetCursorName(handle_t statementHandle, ref string_t cursorName)
{
    debug writeln("called `GetCursorName`");
    char_t[1024 + 1] name;
    smallint_t len = name.length - 1;
    if (!succeeded(SQLGetCursorName(statementHandle, name.ptr, len, null)))
    {
        throw new OdbcException(HandleType.Statement, statementHandle);
    }
    cursorName = str_conv(name.ptr);
    return statementHandle;
}

handle_t NumResultCols(handle_t statementHandle, smallint_t* columnCountPtr)
{
    debug writeln("called `NumResultCols`");
    if (!succeeded(SQLNumResultCols(statementHandle, columnCountPtr)))
    {
        throw new OdbcException(HandleType.Statement, statementHandle);
    }
    return statementHandle;
}

handle_t NumParams(handle_t statementHandle, smallint_t* parameterCountPtr)
{
    debug writeln("called `NumParams`");
    import etc.c.odbc.sqlext : SQLNumParams;

    if (!succeeded(SQLNumParams(statementHandle, parameterCountPtr)))
    {
        throw new OdbcException(HandleType.Statement, statementHandle);
    }
    return statementHandle;
}

handle_t RowCount(handle_t statementHandle, int_t* rowCountPtr)
{
    debug writeln("called `RowCount`");
    if (!succeeded(SQLRowCount(statementHandle, rowCountPtr)))
    {
        throw new OdbcException(HandleType.Statement, statementHandle);
    }
    return statementHandle;
}

handle_t GetTypeInfo(handle_t statementHandle, smallint_t dataType)
{
    debug writeln("called `GetTypeInfo`");
    if (!succeeded(SQLGetTypeInfo(statementHandle, dataType)))
    {
        throw new OdbcException(HandleType.Statement, statementHandle);
    }
    return statementHandle;
}
