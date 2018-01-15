module range.withfront;

import common: from;

auto withFront(alias fun, Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.range: empty, front, ElementType;
    alias R = typeof(fun(ElementType!Range.init));
    static if (is(R == void))
    {
        import optional: some;
        if (!range.empty) {
            some(fun(range.front));
        }
    }
    else
    {
        import optional: some, no;
        return range.empty ? no!R : some(fun(range.front));
    }
}

unittest {
    import optional: some, none;
    assert((int[]).init.withFront!(a => a * a) == none);
    assert([3].withFront!(a => a * a) == some(9));
}
