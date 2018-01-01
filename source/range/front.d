module range.front;

import std.range: isInputRange, ElementType;

auto front(Range, T)(Range r, lazy T defaultValue) if (isInputRange!Range && is(T : ElementType!Range)) {
    import std.range: empty, front;
    return r.empty ? defaultValue : r.front;
}

unittest {
    assert((int[]).init.front(7) == 7);
    assert([1].front(3) == 1);
}
