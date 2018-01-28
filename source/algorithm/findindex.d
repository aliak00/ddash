/// Returns `optional` index of the first element predicate returns true for.
module algorithm.findindex;

///
unittest {
    import optional: some, none;
    assert([1, 2, 3, 4].findIndex!(a => a % 2 == 0) == some(1));
    assert([1, 2, 3, 4].findIndex!(a => a == 5) == none);
    assert([1, 2, 3, 4].findIndex!(a => a % 2 == 0)(2) == some(3));
}

import common;

/**
    Ditto

    Params:
        pred = unary function that returns true for some element
        range = the input range to search
        fromIndex = which index to start searching from

    Returns:
        `some!size_t` or `none` if no element was found
*/
auto findIndex(alias pred, Range)(Range range, size_t fromIndex = 0)
if (from!"std.range".isInputRange!Range
    && from!"utils.traits".isUnaryOver!(pred, from!"std.range".ElementType!Range) )
{
    import std.range: drop;
    import std.functional: unaryFun;
    import phobos: stdCountUntil = countUntil;
    import optional: some;
    alias fun = unaryFun!pred;
    auto r = range.drop(fromIndex);
    return r.stdCountUntil!((a, b) => fun(a))(r) + fromIndex;
}
