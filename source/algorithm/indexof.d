module algorithm.indexof;

import common: from;

auto indexOf(Range, T)(Range range, T value, size_t fromIndex = 0) if (from!"std.range".isInputRange!Range) {
    import std.range: drop;
    import phobos: countUntil;
    import range: withFront;
    return range
        .drop(fromIndex)
        .countUntil(value)
        .withFront!(a => a + fromIndex);
}

unittest {
    import optional;
    assert([1, 2, 1, 2].indexOf(2) == some(1));
    assert([1, 2, 1, 2].indexOf(2, 2) == some(3));
    assert([1, 2, 1, 2].indexOf(3) == none);
}
