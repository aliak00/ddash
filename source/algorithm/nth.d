/**
    Gets the element at index n of a range
*/
module algorithm.nth;

import common;

///
unittest {
    import optional: some, none;
    assert([1, 2].nthOr(1) == 2);
    assert((int[]).init.nthOr(1, 9) == 9);
    assert((int[]).init.nthOr(1) == 0);

    assert([1, 2].nth(1) == some(2));
    assert((int[]).init.nth(1) == none);

    assert([1, 2, 3].nth!(Yes.wrap)(10) == some(2));
}

/**
    Gets the element at index n of array or a default value if not found

    Params:
        wrap = If `Yes.wrap`, then we wrap around the edge, else not
        range = an input range
        n = which element to return
        defaultValue = value to return if range is empty

    Returns
        The value at the nth index of range or defaultValue i not found

    Since:
        0.1.0
*/
auto nthOr(
    from!"std.typecons".Flag!"wrap" wrap = from!"std.typecons".No.wrap,
    Range,
    T,
)(
    Range range,
    size_t n,
    lazy T defaultValue = from!"std.range".ElementType!Range.init,
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

/**
    Gets the element at index n of array if found, else `none`.

    Params:
        wrap = If `Yes.wrap`, then we wrap around the edge, else not
        range = an input range
        n = which element to return

    Returns
        The value at the nth index of range or defaultValue i not found

    Since:
        0.1.0
*/
auto nth(
    from!"std.typecons".Flag!"wrap" wrap = from!"std.typecons".No.wrap,
    Range,
)(
    Range range,
    size_t n,
)
if (from!"std.range".isInputRange!Range)
{

    import std.range: empty, walkLength, isRandomAccessRange, ElementType;
    import std.typecons: Yes;
    import optional: no, some;

    alias T = ElementType!Range;

    if (range.empty) {
        return no!T;
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
        return some(get(n % length));
    }
    else
    {
        if (n >= length) {
            return no!T;
        }
        return some(get(n));
    }
}

unittest {
    import std.algorithm: filter;
    import optional: some, none;
    assert([1, 2].nth(1) == some(2));
    assert([1, 2].filter!"true".nth(1) == some(2));
    assert((int[]).init.nth(1) == none);
    assert([1, 2].nth!(No.wrap)(2) == none);
    assert([1, 2].nth!(Yes.wrap)(2) == some(1));
}

/// Returns `optional` front of range
alias first = from!"range".maybeFront;

///
unittest {
    import optional: some, none;
    assert([1, 2].first == some(1));
    assert((int[]).init.first == none);
}

/// Returns `optional` end of range
alias last = from!"range".maybeBack;

///
unittest {
    import optional: some, none;
    assert([1, 2].last == some(2));
    assert((int[]).init.last == none);
}
