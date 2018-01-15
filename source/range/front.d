module range.front;

import common: from;

auto front(Range, T)(Range range, lazy T defaultValue)
if (from!"std.range".isInputRange!Range && is(T : from!"std.range".ElementType!Range)) {
    import std.range: empty, front;
    return range.empty ? defaultValue : range.front;
}

unittest {
    assert((int[]).init.front(7) == 7);
    assert([1].front(3) == 1);
}
