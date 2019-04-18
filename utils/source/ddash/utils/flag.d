/**
    Like std.typecons.Flag but without strings
*/
module ddash.utils.flag;

/**
    This can be used like std.typecons.Flag but has a nicer API that doesn't use strings
    or the `Yes.` and `No.` constructs.

    Since:
        0.13.0

    See_Also:
        - https://forum.dlang.org/post/ohrilhjbhddjkkqznlsn@forum.dlang.org
*/
struct Flag {
    private template FlagImpl(string name) {
        // mixin to embetter type name.
        mixin(`struct ` ~ name ~ `{
            bool value;
            alias value this;
            static typeof(this) opAssign(bool value) {
                return typeof(this)(value);
            }
            this(bool value) {
                this.value = value;
            }
        }`);
        mixin("alias FlagImpl = "~name~";");
    }
    alias opDispatch(string name) = Flag.FlagImpl!name;
}

///
@("Example of Flag")
unittest {
    auto f(Flag.closed closed = true) {
        return closed;
    }
    assert( f(Flag.closed = true));
    assert(!f(Flag.closed = false));
}
