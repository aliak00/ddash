/**
    Gets the element at index n of a range
*/
module algorithm.nth;

import common;

///
unittest {
    assert([1, 2].nthOr(1) == 2);
    assert((int[]).init.nthOr(1, 9) == 9);
    assert((int[]).init.nthOr(1) == 0);
}

/**
    Gets the element at index n of array. If n is negative, the nth element from the end is returned.

    Params:
        wrap = If `Yes.wrap`, then we wrap around the edge, else not
        range = an input range
        n = which element to return
        defaultValue = value to return if range is empty

    Returns
        The value at the nth index of range or defaultValue i not found
*/
auto nthOr(
    from!"std.typecons".Flag!"wrap" wrap = from!"std.typecons".No.wrap,
    Range,
    T
)(
    Range range,
    size_t n,
    lazy T defaultValue = from!"std.range".ElementType!Range.init
)
if (from!"std.range".isInputRange!Range && is(T : from!"std.range".ElementType!Range))
{
    import std.range: empty, walkLength, isRandomAccessRange;
    import std.typecons: Yes;
    if (range.empty) {
        return defaultValue;
    }
    auto length = range.walkLength;
    static if (isRandomAccessRange!Range)
    {
        alias get = a => range[a];
    }
    else
    {
        import std.range: dropExactly;
        alias get = a => range
            .dropExactly(a)
            .front;
    }

    static if (wrap == Yes.wrap)
    {
        return get(n % length);
    }
    else
    {
        if (n >= length) {
            return defaultValue;
        }
        return get(n);
    }
}

unittest {
    import std.algorithm: filter;
    assert([1, 2].nthOr(1) == 2);
    assert([1, 2].filter!"true".nthOr(1) == 2);
    assert((int[]).init.nthOr(1, 9) == 9);
    assert((int[]).init.nthOr(1) == 0);
    assert([1, 2].nthOr!(No.wrap)(2, 9) == 9);
    assert([1, 2].nthOr!(Yes.wrap)(2, 9) == 1);
}
