module range.withfront;

import std.range: isInputRange, ElementType;

auto withFront(alias fun, Range)(Range r) if (isInputRange!Range) {
    import std.range: empty, front;
    import optional: some, no;
    alias R = typeof(fun(ElementType!Range.init));
    static if (is(R == void)) {
        if (!r.empty) {
            some(fun(r.front));
        }
    } else {
        return r.empty ? no!R : some(fun(r.front));
    }
}

unittest {
    import optional: some, none;
    assert((int[]).init.withFront!(a => a * a) == none);
    assert([3].withFront!(a => a * a) == some(9));
}
