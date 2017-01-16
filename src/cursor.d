// Written in the D programming language.
module dbc.cursor;

/// ODBC Statement handle object

class Statement : Handle
{
    private Connection _conn;

    this(Connection conn)
    {
        this._conn = conn;
        super(HandleType.Statement);
        this.allocate(this._conn.handle);
    }
}
