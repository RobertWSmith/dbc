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

//<<<<<<< HEAD
//enum InfoType : usmallint_t
//{
//    // Driver Information
//    ActiveEnvironments = SQL_ACTIVE_ENVIRONMENTS,
//    AsyncConnectionFunctions = SQL_ASYNC_DBC_FUNCTIONS,
//    AsyncMode = SQL_ASYNC_MODE,
//    AsyncNotification = SQL_ASYNC_NOTIFICATION,
//    BatchRowCount = SQL_BATCH_ROW_COUNT,
//    BatchSupport = SQL_BATCH_SUPPORT,
//    DataSourceName = SQL_DATA_SOURCE_NAME,
//    DriverAwarePoolingSupported = SQL_DRIVER_AWARE_POOLING_SUPPORTED,
//    DriverConnection = SQL_DRIVER_HDBC,
//    DriverDescription = SQL_DRIVER_HDESC,
//    DriverEnvironment = SQL_DRIVER_HENV,
//    DriverLibrary = SQL_DRIVER_HLIB,
//    DriverStatement = SQL_DRIVER_HSTMT,
//    DriverName = SQL_DRIVER_NAME,
//    DriverOdbcVersion = SQL_DRIVER_ODBC_VER,
//    DynamicCursorAttributes1 = SQL_DYNAMIC_CURSOR_ATTRIBUTES1,
//    DynamicCursorAttributes2 = SQL_DYNAMIC_CURSOR_ATTRIBUTES2,
//    ForwardOnlyCursorAttributes1 = SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES1,
//    ForwardOnlyCursorAttributes2 = SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES2,
//    FileUsage = SQL_FILE_USAGE,
//    GetDataExtensions = SQL_GETDATA_EXTENSIONS,
//    InfoSchemaViews = SQL_INFO_SCHEMA_VIEWS,
//    KeysetCursorAttributes1 = SQL_KEYSET_CURSOR_ATTRIBUTES1,
//    KeysetCursorAttributes2 = SQL_KEYSET_CURSOR_ATTRIBUTES2,
//    MaxAsyncConcurrentStatements = SQL_MAX_ASYNC_CONCURRENT_STATEMENTS,
//    MaxConcurrentActivities = SQL_MAX_CONCURRENT_ACTIVITIES,
//    MaxDriverConnections = SQL_MAX_DRIVER_CONNECTIONS,
//    OdbcInterfaceConformance = SQL_ODBC_INTERFACE_CONFORMANCE,
//    OdbcStandardCLIConformance = SQL_ODBC_STANDARD_CLI_CONFORMANCE,
//    OdbcVersion = SQL_ODBC_VER,
//    ParameterArrayRowCounts = SQL_PARAM_ARRAY_ROW_COUNTS,
//    ParameterArraySelects = SQL_PARAM_ARRAY_SELECTS,
//    RowUpdates = SQL_ROW_UPDATES,
//    SearchPatternEscape = SQL_SEARCH_PATTERN_ESCAPE,
//    ServerName = SQL_SERVER_NAME,
//    StaticCursorAttributes1 = SQL_STATIC_CURSOR_ATTRIBUTES1,
//    StaticCursorAttributes2 = SQL_STATIC_CURSOR_ATTRIBUTES2,
//
//    // DBMS Product Information
//    DatabaseName = SQL_DATABASE_NAME,
//    DBMSName = SQL_DBMS_NAME,
//    DBMSVersion = SQL_DBMS_VER,
//
//    // Data Source Information
//    AccessibleProcedures = SQL_ACCESSIBLE_PROCEDURES,
//    AccessibleTables = SQL_ACCESSIBLE_TABLES,
//    BookmarkPersistence = SQL_BOOKMARK_PERSISTENCE,
//    CatalogTerm = SQL_CATALOG_TERM,
//    CollationSequence = SQL_COLLATION_SEQ,
//    ConcatenateNullBehavior = SQL_CONCAT_NULL_BEHAVIOR,
//    CursorCommitBehavior = SQL_CURSOR_COMMIT_BEHAVIOR,
//    CursorRollbackBehavior = SQL_CURSOR_ROLLBACK_BEHAVIOR,
//    CursorSensitivity = SQL_CURSOR_SENSITIVITY,
//    DataSourceReadOnly = SQL_DATA_SOURCE_READ_ONLY,
//    DefaultTransactionIsolation = SQL_DEFAULT_TXN_ISOLATION,
//    DescribeParameter = SQL_DESCRIBE_PARAMETER,
//    MultipleResultSets = SQL_MULT_RESULT_SETS,
//    MultipleActiveTransactions = SQL_MULTIPLE_ACTIVE_TXN,
//    NeedLongDataLength = SQL_NEED_LONG_DATA_LEN,
//    NullCollation = SQL_NULL_COLLATION,
//    ProcedureTerm = SQL_PROCEDURE_TERM,
//    SchemaTerm = SQL_SCHEMA_TERM,
//    ScrollOptions = SQL_SCROLL_OPTIONS,
//    TableTerm = SQL_TABLE_TERM,
//    TransactionCapable = SQL_TXN_CAPABLE,
//    TransactionIsolationOption = SQL_TXN_ISOLATION_OPTION,
//    UserName = SQL_USER_NAME,
//
//}
//
//=======

// dfmt off
enum InfoType : usmallint_t
{
    // all procedures from SQLProcedurs are executable by user
    // bool from char_t 'Y'
    AccessibleProcedures = SQL_ACCESSIBLE_PROCEDURES,

    // all tables from SQLTables user has 'select' privileges
    // bool from char_t 'Y'
    AccessibleTables = SQL_ACCESSIBLE_TABLES,

    // maximum number of environments driver can support 
    // usmallint_t, zero if undefined
    ActiveEnvironments = SQL_ACTIVE_ENVIRONMENTS,

    // aggregate function bitmask defining what can be supported
    // uint_t to AggregateFunctions[]
    AggregateFunctions = SQL_AGGREGATE_FUNCTIONS,

    // alter domain statement bitmask, return of 0 means alter domain not supported
    // uint_t
    AlterDomain = SQL_ALTER_DOMAIN,

    // alter table statement bitmask
    // uint_t
    AlterTable = SQL_ALTER_TABLE,

    //    // indicates if drivre can execute functions asynchronously on the connection handle
    //    // uint_t to bool (SQL_ASYNC_DBC_CAPABLE == true)
    //    AsyncConnectionFunctions = SQL_ASYNC_DBC_FUNCTIONS,

    // the level of asynchronous support in the driver
    // uint_t to AsyncMode enum
    AsyncMode = SQL_ASYNC_MODE,

    //    // asynchronous notification support
    //    // uint_t to bool (SQL_ASYNC_NOTIFICATION_CAPABLE == true)
    //    AsyncNotification = SQL_ASYNC_NOTIFICATION,

    // bitmask that enumerates the behavior of the driver with respect to the availability of row counts
    // uint_t to BatchRowCount[]
    BatchRowCount = SQL_BATCH_ROW_COUNT,

    // driver's support for batches bitmask
    // uint_t to BatchSupport[]
    BatchSupport = SQL_BATCH_SUPPORT,

    // bookmark persistence support bitmask
    // uint_t to BookmarkPersistence[]
    BookmarkPersistence = 82, // SQL_BOOKMARK_PERSISTENCE,

    // position of the catalog in a qualifiied table name
    // usmallint_t to CatalogLocation
    CatalogLocation = SQL_CATALOG_LOCATION,

    // indicator if the server supports catalog names
    // char_t to bool ('Y' == true)
    SupportsCatalogName = SQL_CATALOG_NAME,
    
    // character string which represents the separator between a catalog name 
    //    and the following element
    CatalogNameSeparator = SQL_CATALOG_NAME_SEPARATOR,

    // character string representing the data source vendor's term for a catalog
    CatalogTerm = SQL_CATALOG_TERM,
    
    // statements where catalogs can be used bitmask
    // uint_t to CatalogUsage[]
    CatalogUsage = SQL_CATALOG_USAGE,

    // character string for the name of the default collation sequence (character set)
    // if unknown, empty string
    CollationSequence = SQL_COLLATION_SEQ,
    
    // indicates if the driver supports using an `AS` clause to provide an alternative column name
    // char_t to bool ('Y' == true)
    SupportsColumnAlias = 87, // SQL_COLUMN_ALIAS,

    // the data source null concatenation handling behavior bitmask
    // usmallint_t to ConcatenateNullBehavior
    ConcatenateNullBehavior = 22, // SQL_CONCAT_NULL_BEHAVIOR,
    
    // Conversions supported by the data source
    // uint_t to DataSourceConversions[]
    ConvertBigint = 53, // SQL_CONVERT_BIGINT,
    ConvertBinary = 54, // SQL_CONVERT_BINARY,
    ConvertChar = 56, // SQL_CONVERT_CHAR,
    ConvertGUID = 173, // SQL_CONVERT_GUID,
    ConvertDate = 57, // SQL_CONVERT_DATE,
    ConvertDecimal = 58, // SQL_CONVERT_DECIMAL,
    ConvertDouble = 59, // SQL_CONVERT_DOUBLE,
    ConvertFloat = 60, // SQL_CONVERT_FLOAT,
    ConvertInteger = 61, // SQL_CONVERT_INTEGER,
    ConvertIntervalYearMonth = SQL_CONVERT_INTERVAL_YEAR_MONTH,
    ConvertIntervalDayTime = SQL_CONVERT_INTERVAL_DAY_TIME,
    ConvertLongVarbinary = 71, // SQL_CONVERT_LONGVARBINARY,
    ConvertLongVarchar = 62, // SQL_CONVERT_LONGVARCHAR,
    ConvertNumeric = 63, // SQL_CONVERT_NUMERIC,
    ConvertReal = 64, // SQL_CONVERT_REAL,
    ConvertSmallint = 65, //SQL_CONVERT_SMALLINT,
    ConvertTime = 66, // SQL_CONVERT_TIME,
    ConvertTimestamp = 67, // SQL_CONVERT_TIMESTAMP,
    ConvertTinyint = 68, // SQL_CONVERT_TINYINT,
    ConvertVarbinary = 69, // SQL_CONVERT_VARBINARY,
    ConvertVarchar = 70, // SQL_CONVERT_VARCHAR,
    
    // convert functions supported by the driver and data source
    // uint_t to ConvertFunctions[]
    ConvertFunctions = 48, // SQL_CONVERT_FUNCTIONS,
    
    // indicates whether table correlation names are supported
    // usmallint_t to SupportsCorrelationName
    SupportsCorrelationName = 74, // SQL_CORRELATION_NAME,
    
    // indicates `create assertion` statement support for the data source
    // uint_t to SupportsCreateAssertion
    SupportsCreateAssertion = SQL_CREATE_ASSERTION,
    
    // indicates `create character set` statements support bitmask
    // uint_t to SupportsCreateCharacterSet
    SupportsCreateCharacterSet = SQL_CREATE_CHARACTER_SET,
    
    // indicates `create collation` statement clasues
    // uint_t bitmask
    SupportsCreateCollation = SQL_CREATE_COLLATION,
    
    SupportsCreateDomain = SQL_CREATE_DOMAIN,
    SupportsCreateSchema = SQL_CREATE_SCHEMA,
    SupportsCreateTable = SQL_CREATE_TABLE,
    SupportsCreateTranslation = SQL_CREATE_TRANSLATION,
    SupportsCreateView = SQL_CREATE_VIEW,
    
    // indicates how `commit` operation affects cursors and prepared statements in the data source
    // usmallint_t to CursorCommitBehavior
    CursorCommitBehavior = SQL_CURSOR_COMMIT_BEHAVIOR,
    
    // indicates support for cursor sensitivity
    // uint_t to CursorSensitivity
    CursorSensitivity = SQL_CURSOR_SENSITIVITY,
    
    // character string returning the data source name
    DataSourceName = SQL_DATA_SOURCE_NAME,
    
    // indicates if the data source is set to read only
    // char_t to bool ('Y' == true)
    DataSourceReadOnly = SQL_DATA_SOURCE_READ_ONLY,
    
    // character string indicating the current database in use
    DatabaseName = SQL_DATABASE_NAME,
    
    // indicates datetime literals supported by the data source
    // uint_t bitmask
    DatetimeLiterals = SQL_DATETIME_LITERALS,
    
    // character string of the DBMS product name
    DBMSName = SQL_DBMS_NAME,
    
    // DDL index creation and dropping support bitmask
    // uint_t
    DDLIndex = SQL_DDL_INDEX,
    
    // uint_t to TransactionIsolation
    DefaultTransactionIsolation = SQL_DEFAULT_TXN_ISOLATION,
    
    // indicates support for parameter descriptions
    // char_t to bool ('Y' == true)
    SupportsDescribeParameter = SQL_DESCRIBE_PARAMETER,
    
    // character string of the driver manager version
    DriverManagerVersion = SQL_DM_VER,
    
//    // indicates if driver supports driver-aware pooling
//    // uint_t bitmask
//    DriverAwarePoolingSupported = SQL_DRIVER_AWARE_POOLING_SUPPORTED,
    
    // character string with the file name of the driver being used to access the data source
    DriverName = SQL_DRIVER_NAME,
    
    // character string indicating the driver's ODBC version
    DriverODBCVersion = SQL_DRIVER_ODBC_VER,
    
    // character string indicating the driver version
    DriverVersion = SQL_DRIVER_VER,
    
    // indicates `drop assertion` statement support
    DropAssertion = SQL_DROP_ASSERTION,
    
    DropCharacterSet = SQL_DROP_CHARACTER_SET,
    DropCollation = SQL_DROP_COLLATION,
    DropDomain = SQL_DROP_DOMAIN,
    DropSchema = SQL_DROP_SCHEMA,
    DropTable = SQL_DROP_TABLE,
    DropTranslation = SQL_DROP_TRANSLATION,
    DropView = SQL_DROP_VIEW,
    
    DynamicCursorAttributes1 = SQL_DYNAMIC_CURSOR_ATTRIBUTES1,
    DynamicCursorAttributes2 = SQL_DYNAMIC_CURSOR_ATTRIBUTES2,
    
    // char_t to bool ('Y' == true)
    ExpressionsInOrderBy = SQL_EXPRESSIONS_IN_ORDERBY,
    
    // indicates how single-tier driver directly treats files in a data source
    // usmallint_t to FileUsage
    FileUsage = SQL_FILE_USAGE,
    
    ForwardOnlyCursorAttributes1 = SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES1,
    ForwardOnlyCursorAttributes2 = SQL_FORWARD_ONLY_CURSOR_ATTRIBUTES2,
    
    // indicates supported extensions to `SQLGetData`
    // uint_t to GetDataExtensions[]
    GetDataExtensions = SQL_GETDATA_EXTENSIONS,
    
    // indicates relationship between `group by` columns nd the nonaggregated columns in the select list
    // usmallint_t to GroupBy
    GroupBy = SQL_GROUP_BY,
    
    // usmallint_t to IdentifierCase
    IdentifierCase = SQL_IDENTIFIER_CASE,
    
    // character indicating the quoting character used for identifiers
    IdentifierQuoteChar = SQL_IDENTIFIER_QUOTE_CHAR,
    
    // indicates `create index` statement supported keywords
    IndexKeywords = SQL_INDEX_KEYWORDS,
    
    // indicates the views in the `information_schema` which are supported by the driver
    // uint_t bitmask
    InformationSchemaViews = SQL_INFO_SCHEMA_VIEWS,
    
    // indicates support for `insert` statements
    // uint_t bitmask
    InsertStatement = SQL_INSERT_STATEMENT,
    
    // indivates support for the integrity enhancement facility
    // char_t to bool ('Y' == true)
    Integrity = SQL_INTEGRITY,
    
    KeysetCursorAttributes1 = SQL_KEYSET_CURSOR_ATTRIBUTES1,
    KeysetCursorAttributes2 = SQL_KEYSET_CURSOR_ATTRIBUTES2,
    
    // character string with a comma separated list of data source specific keywords
    // represents reserved keywords
    Keywords = SQL_KEYWORDS,
    
    // supports an escape character for the % or _ characters in a `like` clause
    LikeEscapeClause = SQL_LIKE_ESCAPE_CLAUSE,
    
    // uint_t
    MaxAsyncConcurrentActivities = SQL_MAX_ASYNC_CONCURRENT_STATEMENTS,
    
    // uint_t
    MaxBinaryLiteralLength = SQL_MAX_BINARY_LITERAL_LEN,
    
    // usmallint_t
    MaxCatalogNameLength = SQL_MAX_CATALOG_NAME_LEN,
    
    // uint_t
    MaxCharLiteralLength = SQL_MAX_CHAR_LITERAL_LEN,
    
    // usmallint_t
    MaxColumnNameLength = SQL_MAX_COLUMN_NAME_LEN,
    
    // usmallint_t
    MaxColumnsInGroupBy = SQL_MAX_COLUMNS_IN_GROUP_BY,
    
    // usmallint_t
    MaxColumnsInIndex = SQL_MAX_COLUMNS_IN_INDEX,
    
    // usmallint_t
    MaxColumnsInOrderBy = SQL_MAX_COLUMNS_IN_ORDER_BY,
    
    // usmallint_t
    MaxColumnsInSelect = SQL_MAX_COLUMNS_IN_SELECT,
    
    // usmallint_t
    MaxColumnsInTable = SQL_MAX_COLUMNS_IN_TABLE,
    
    // usmallint_t
    MaxConcurrentActivities = SQL_MAX_CONCURRENT_ACTIVITIES,
    
    // usmallint_t
    MaxCursorNameLength = SQL_MAX_CURSOR_NAME_LEN,
    
    // usmallint_t
    MaxDriverConnections = SQL_MAX_DRIVER_CONNECTIONS,
    
    // usmallint_t
    MaxIdentifierLength = SQL_MAX_IDENTIFIER_LEN,
    
    // usmallint_t
    MaxIndexSize = SQL_MAX_INDEX_SIZE,
    
    // usmallint_t
    MaxProcedureNameLength = SQL_MAX_PROCEDURE_NAME_LEN,
    
    // uint_t
    MaxRowSize = SQL_MAX_ROW_SIZE,
    
    // char_t to bool ('Y' == true)
    MaxRowSizeIncludesLong = SQL_MAX_ROW_SIZE_INCLUDES_LONG,
    
    // usmallint_t
    MaxSchemaNameLength = SQL_MAX_SCHEMA_NAME_LEN,
    
    // uint_t
    MaxStatementLength = SQL_MAX_STATEMENT_LEN,
    
    // usmallint_t
    MaxTableNameLength = SQL_MAX_TABLE_NAME_LEN,
    
    // usmallint_t
    MaxTablesInSelect = SQL_MAX_TABLES_IN_SELECT,
    
    // usmallint_t
    MaxUserNameLength = SQL_MAX_USER_NAME_LEN,
    
    // char_t to bool ('Y' == true)
    SupportsMultipleResultSets = SQL_MULT_RESULT_SETS,
    
    // char_t to bool ('Y' == true)
    SupportsMulitpleActiveTransactions = SQL_MULTIPLE_ACTIVE_TXN,
    
    // char_t to bool ('Y' == true)
    NeedsLongDataLength = SQL_NEED_LONG_DATA_LEN,
    
    // usmallint_t to bool (SQL_NNC_NON_NULL == true)
    SupportsNotNullColumns = SQL_NON_NULLABLE_COLUMNS,
    
    // usmallint_t 
    NullCollationSort = SQL_NULL_COLLATION,
}
// dfmt on

enum AggregateFunctions : uint_t
{
    All = SQL_AF_ALL,
    Average = SQL_AF_AVG,
    Count = SQL_AF_COUNT,
    Distinct = SQL_AF_DISTINCT,
    Max = SQL_AF_MAX,
    Min = SQL_AF_MIN,
    Sum = SQL_AF_SUM,
}

enum AlterDomain : uint_t
{
    AddDomainConstraint = SQL_AD_ADD_DOMAIN_CONSTRAINT,
    AddDomainDefault = SQL_AD_ADD_DOMAIN_DEFAULT,
    AddConstraintDeferrable = SQL_AD_ADD_CONSTRAINT_DEFERRABLE,
    AddConstraintNonDeferrable = SQL_AD_ADD_CONSTRAINT_NON_DEFERRABLE,
    AddConstraintInitiallyDeferred = SQL_AD_ADD_CONSTRAINT_INITIALLY_DEFERRED,
    AddConstraintInitiallyImmediate = SQL_AD_ADD_CONSTRAINT_INITIALLY_IMMEDIATE,
    ConstraintNameDefinition = SQL_AD_CONSTRAINT_NAME_DEFINITION,
    DropDomainConstraint = SQL_AD_DROP_DOMAIN_CONSTRAINT,
    DropDomainDefault = SQL_AD_DROP_DOMAIN_DEFAULT,
}

enum AlterTable : uint_t
{
    AddColumnCollation = SQL_AT_ADD_COLUMN_COLLATION,
    AddColumnDefault = SQL_AT_ADD_COLUMN_DEFAULT,
    AddColumnSingle = SQL_AT_ADD_COLUMN_SINGLE,
    AddConstraint = SQL_AT_ADD_CONSTRAINT,
    AddTableConstraint = SQL_AT_ADD_TABLE_CONSTRAINT,
    ConstraintNameDefinition = SQL_AT_CONSTRAINT_NAME_DEFINITION,
    DropColumnCascade = SQL_AT_DROP_COLUMN_CASCADE,
    DropColumnDefault = SQL_AT_DROP_COLUMN_DEFAULT,
    DropColumnRestrict = SQL_AT_DROP_COLUMN_RESTRICT,
    DropTableConstraintCascade = SQL_AT_DROP_TABLE_CONSTRAINT_CASCADE,
    DropTableConstraintRestrict = SQL_AT_DROP_TABLE_CONSTRAINT_RESTRICT,
    SetColumnDefault = SQL_AT_SET_COLUMN_DEFAULT,
    ConstraintInitiallyDeferred = SQL_AT_CONSTRAINT_INITIALLY_DEFERRED,
    ConstraintInitiallyImmediate = SQL_AT_CONSTRAINT_INITIALLY_IMMEDIATE,
    ConstraintDeferrable = SQL_AT_CONSTRAINT_DEFERRABLE,
    ConstraintNonDeferrable = SQL_AT_CONSTRAINT_NON_DEFERRABLE,
}

enum AsyncMode : uint_t
{
    None = 0, // SQL_AM_NONE.to!uint_t,
    Connection = 1, // SQL_AM_CONNECTION.to!uint_t,
    Statement = 2, // SQL_AM_STATEMENT.to!uint_t,
}

enum BatchRowCount : uint_t
{
    RolledUp = SQL_BRC_ROLLED_UP,
    Procedures = SQL_BRC_PROCEDURES,
    Explicit = SQL_BRC_EXPLICIT,
}

enum BatchSupport : uint_t
{
    SelectExplicit = SQL_BS_SELECT_EXPLICIT,
    RowCountExplicit = SQL_BS_ROW_COUNT_EXPLICIT,
    SelectProcedures = SQL_BS_SELECT_PROC,
    RowCountProcedures = SQL_BS_ROW_COUNT_PROC,
}

enum BookmarkPersistence : uint_t
{
    Close = SQL_BP_CLOSE,
    Delete = SQL_BP_DELETE,
    Drop = SQL_BP_DROP,
    Transaction = SQL_BP_TRANSACTION,
    Update = SQL_BP_UPDATE,
    OtherStatement = SQL_BP_OTHER_HSTMT,
}

enum CatalogLocation : usmallint_t
{
    Start = SQL_CL_START,
    End = SQL_CL_END,
}

enum CatalogUsage : uint_t
{
    NotSupported = 0,
    DataManiupulationStatements = SQL_CU_DML_STATEMENTS,
    ProcedureInvocation = SQL_CU_PROCEDURE_INVOCATION,
    TableDefinition = SQL_CU_TABLE_DEFINITION,
    IndexDefinition = SQL_CU_INDEX_DEFINITION,
    PrivilegeDefintion = SQL_CU_PRIVILEGE_DEFINITION,
}

enum ConcatenateNullBehavior : usmallint_t
{
    Null = SQL_CB_NULL,
    NonNull = SQL_CB_NON_NULL,
}

enum DataSourceConversions : int_t
{
    Char = SQL_CVT_CHAR,
    BigInt = SQL_CVT_BIGINT,
    Binary = SQL_CVT_BINARY,
    Bit = SQL_CVT_BIT,
    Date = SQL_CVT_DATE,
    Decimal = SQL_CVT_DECIMAL,
    Double = SQL_CVT_DOUBLE,
    Float = SQL_CVT_FLOAT,
    Integer = SQL_CVT_INTEGER,
    IntervalYearMonth = SQL_CVT_INTERVAL_YEAR_MONTH,
    IntervalDayTime = SQL_CVT_INTERVAL_DAY_TIME,
    LongVarbinary = SQL_CVT_LONGVARBINARY,
    LongVarchar = SQL_CVT_LONGVARCHAR,
    Numeric = SQL_CVT_NUMERIC,
    Real = SQL_CVT_REAL,
    Smallint = SQL_CVT_SMALLINT,
    Time = SQL_CVT_TIME,
    Timestamp = SQL_CVT_TIMESTAMP,
    Tinyint = SQL_CVT_TINYINT,
    Varbinary = SQL_CVT_VARBINARY,
    Varchar = SQL_CVT_VARCHAR,
    Wchar = SQL_CVT_WCHAR,
    Wlongvarchar = SQL_CVT_WLONGVARCHAR,
    Wvarchar = SQL_CVT_WVARCHAR,
    GUID = 0x01000000UL, // SQL_CVT_GUID,
}

enum ConvertFunctions : uint_t
{
    Cast = SQL_FN_CVT_CAST,
    Convert = SQL_FN_CVT_CONVERT,
}

enum SupportsCorrelationName : usmallint_t
{
    None = SQL_CN_NONE,
    Different = SQL_CN_DIFFERENT,
    Any = SQL_CN_ANY,
}

enum SupportsCreateAssertion : uint_t
{
    NotSupported = 0,
    ConstraintInitiallyDeferred = SQL_CA_CONSTRAINT_INITIALLY_DEFERRED,
    ConstraintInitiallyImmediate = SQL_CA_CONSTRAINT_INITIALLY_IMMEDIATE,
    ConstraintDeferrable = SQL_CA_CONSTRAINT_DEFERRABLE,
    ConstraintNonDeferrable = SQL_CA_CONSTRAINT_NON_DEFERRABLE,
}

enum SupportsCreateCharacterSet : uint_t
{
    NotSupported = 0,
    CreateCharacterSet = SQL_CCS_CREATE_CHARACTER_SET,
    CollateClause = SQL_CCS_COLLATE_CLAUSE,
    LimitedCollation = SQL_CCS_LIMITED_COLLATION,
}

enum CursorCommitBehavior : usmallint_t
{
    Delete = SQL_CB_DELETE,
    Close = SQL_CB_CLOSE,
    Preserve = SQL_CB_PRESERVE,
}

enum CursorSensitivity : uint_t
{
    Insensitive = SQL_INSENSITIVE,
    Unspecified = SQL_UNSPECIFIED,
    Sensitive = SQL_SENSITIVE,
}

enum FileUsage : usmallint_t
{
    NotSupported = SQL_FILE_NOT_SUPPORTED,
    Table = SQL_FILE_TABLE,
    Catalog = SQL_FILE_CATALOG,
}

enum GetDataExtensions : uint_t
{
    AnyColumn = SQL_GD_ANY_COLUMNS,
    AnyOrder = SQL_GD_ANY_ORDER,
    Block = SQL_GD_BLOCK,
    Bound = SQL_GD_BOUND,
    OutputParameters = SQL_GD_OUTPUT_PARAMS,
}

enum GroupBy : usmallint_t
{
    Collate = SQL_GB_COLLATE,
    NotSupported = SQL_GB_NOT_SUPPORTED,
    GroupByEqualsSelect = SQL_GB_GROUP_BY_EQUALS_SELECT,
    GroupByContainsSelect = SQL_GB_GROUP_BY_CONTAINS_SELECT,
    NoRelation = SQL_GB_NO_RELATION,
}

enum IdentifierCase : usmallint_t
{
    Upper = SQL_IC_UPPER,
    Lower = SQL_IC_LOWER,
    Sensitive = SQL_IC_SENSITIVE,
    Mixed = SQL_IC_MIXED,
}

//enum SupportsNotNullColumns : usmallint_t
//{
//    AllColumnsNullable = SQL_NNC_NULL, // all columns must be nullable
//    NonNull = SQL_NNC_NON_NULL, // columns cannot be nullable (supports `not null` column constraint)
//}

// >>>  >>>  > origin / work - 2017 - 01 - 12
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
