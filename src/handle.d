module dbc.handle;

debug import std.stdio;

import dbc.sql;
import dbc.sqltypes;

abstract class Handle
{
    public static HandleType handleType;
    public handle_t handle;

    this(HandleType handle_type)
    {
        debug writefln("Begin Handle %s Constructor.", handle_type);
        this.handleType = handle_type;
        this.nullify();
        debug writefln("End Handle %s Constructor.", this.handleType);
    }

    ~this()
    {
        debug writeln("Begin Handle Destructor.");
        this.p_free();
        debug writeln("End Handle Destructor.");
    }

    /**
     * Set handle to value which ensures 'isAllocated' property evaluates correctly.
     */
    package final void nullify()
    {
        debug writeln("Called `nullify`");
        if (this.isAllocated)
            throw new Exception("Called nullify on allocated handle.");
        this.handle = cast(handle_t) null_handle;

        // confirm that object is not allocated after calling this function
        assert(!this.isAllocated);
    }

    /**
     * Confirms if the environment handle is allocated.
     */
    public final @property bool isAllocated()
    {
        debug writeln("Called `isAllocated`");
        return checkAllocated(this.handle);
    }

    /**
     * Allocated environment handle, attempting to free handle first in order
     * to ensure that existing handles aren't left dangling.
     */
    package void allocate(handle_t priorHandle = null_handle)
    {
        debug writeln("Called `allocate`");
        AllocHandle(this.handleType, priorHandle, &this.handle);
    }

    package void p_free()
    {
        debug writeln("Called `p_free`");
        FreeHandle(this.handleType, this.handle);
    }

    /**
     * Free environment handle to properly clean up environment.
     */
    package void free()
    {
        debug writeln("Called `free`");
        this.p_free();
        this.nullify();
    }

    /**
     * Unified 'SetAttr' function
     */
    package final void p_setAttribute(int_t attribute, pointer_t value_ptr, int_t buffer_length)
    {
        debug writeln("Called `p_setAttribute`");
        SetAttribute(this.handleType, this.handle, attribute, value_ptr, buffer_length);
    }

    /**
     * Unified 'GetAttr' function
     */
    package final void p_getAttribute(int_t attribute, pointer_t value_ptr,
            int_t buffer_length, int_t* string_length_ptr)
    {
        debug writeln("Called `p_getAttribute`");
        GetAttribute(this.handleType, this.handle, attribute, value_ptr,
                buffer_length, string_length_ptr);
    }
}
