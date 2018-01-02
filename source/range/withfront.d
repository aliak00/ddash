module range.withfront;

import std.range: isInputRange, ElementType;

auto withFront(alias fun, Range)(Range range) if (isInputRange!Range) {
    import std.range: empty, front;
    import optional: some, no;
    alias R = typeof(fun(ElementType!Range.init));
    static if (is(R == void)) {
        if (!range.empty) {
            some(fun(range.front));
        }
    } else {
        return range.empty ? no!R : some(fun(range.front));
    }
}

unittest {
    import optional: some, none;
    assert((int[]).init.withFront!(a => a * a) == none);
    assert([3].withFront!(a => a * a) == some(9));
}
