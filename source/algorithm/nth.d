/**
    Gets the element at index n of array. If n is negative, the nth element from the end is returned.
*/
module algorithm.nth;

import common;

///
unittest {
    assert([1, 2].nth(1) == 2);
    assert((int[]).init.nth(1, 9) == 9);
    assert((int[]).init.nth(1) == 0);
}

/**
    Ditto

    Params:
        range = a input range
        n = which element to return
        defaultValue = value to return if range is empty

    Returns
        The value at the nth index of range.
*/
auto nth(Range, T)(Range range, size_t n, lazy T defaultValue = from!"std.range".ElementType!Range.init)
if (from!"std.range".isInputRange!Range && is(T : from!"std.range".ElementType!Range)) {
    import std.range: empty, walkLength, isRandomAccessRange;
    if (range.empty) {
        return defaultValue;
    }
    auto length = range.walkLength;
    static if (isRandomAccessRange!Range)
    {
        return range[n % length];
    }
    else
    {
        import std.range: dropExactly;
        return range
            .dropExactly(n % length)
            .front;
    }
}

unittest {
    import std.algorithm: filter;
    assert([1, 2].nth(1) == 2);
    assert([1, 2].filter!"true".nth(1) == 2);
    assert((int[]).init.nth(1, 9) == 9);
    assert((int[]).init.nth(1) == 0);
}
