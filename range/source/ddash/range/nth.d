/**
    Gets the element at index n of a range
*/
module ddash.range.nth;

///
@("module example")
unittest {
    import ddash.utils.optional: some, none;
    import ddash.range: frontOr;
    assert([1, 2].nth(1).frontOr(1) == 2);
    assert((int[]).init.nth(1).frontOr(9) == 9);

    assert([1, 2].nth(1) == some(2));
    assert((int[]).init.nth(1) == none);

    assert([1, 2, 3].nth!(Yes.wrap)(10) == some(2));
}

import ddash.common;

/**
    Gets the element at index n of array if found, else `none`.

    Params:
        wrap = If `Yes.wrap`, then we wrap around the edge, else not
        range = an input range
        n = which element to return

    Returns
        The value at the nth index of range or defaultValue i not found

    Since:
        0.0.1
*/
auto nth(
    from.std.typecons.Flag!"wrap" wrap = from.std.typecons.No.wrap,
    Range,
)(
    Range range,
    size_t n,
)
if (from.std.range.isInputRange!Range)
{
    import std.range: empty, walkLength, isRandomAccessRange, ElementType;
    import std.typecons: Yes;
    import ddash.utils.optional: no, some;

    alias T = ElementType!Range;

    if (range.empty) {
        return no!T;
    }
    auto length = range.walkLength;
    static if (isRandomAccessRange!Range) {
        alias get = a => range[a];
    } else {
        import std.range: dropExactly;
        alias get = a => range
            .dropExactly(a)
            .front;
    }

    static if (wrap == Yes.wrap) {
        return some!T(get(n % length));
    } else {
        if (n >= length) {
            return no!T;
        }
        return some!T(get(n));
    }
}

@("nth works with filter and optional ranges")
unittest {
    import std.algorithm: filter;
    import ddash.utils.optional: some, none;
    assert([1, 2].nth(1) == some(2));
    assert([1, 2].filter!"true".nth(1) == some(2));
    assert((int[]).init.nth(1) == none);
    assert([1, 2].nth!(No.wrap)(2) == none);
    assert([1, 2].nth!(Yes.wrap)(2) == some(1));
}

@("compiles with array of const")
unittest {
    const(string)[] args = [];
    static assert(__traits(compiles, { args.nth(0); }));
}

/**
    Returns `optional` front of range

    Since:
        - 0.0.1
*/
alias first = from.ddash.range.maybeFront;

///
@("first example")
unittest {
    import ddash.utils.optional: some, none;
    assert([1, 2].first == some(1));
    assert((int[]).init.first == none);
}

/**
    Returns `optional` end of range

    Since:
        - 0.0.1
*/
alias last = from.ddash.range.maybeBack;

///
@("last returns optional")
unittest {
    import ddash.utils.optional: some, none;
    assert([1, 2].last == some(2));
    assert((int[]).init.last == none);
}
