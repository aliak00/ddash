/// Returns an `optional` index of an element.
module algorithm.index;

///
unittest {
    import optional: some, none;
    assert([1, 2, 3, 4].index!(a => a % 2 == 0) == some(1));
    assert([1, 2, 3, 4].lastIndex!(a => a % 2 == 0) == some(3));

    assert([1, 2, 3, 4].index!(a => a == 5) == none);

    assert([1, 2, 3, 4].lastIndex!(a => a % 2 == 0)(2) == some(1));
}

import common;

/**
    Returns `optional` index of the first element predicate returns true for.

    Params:
        pred = unary function that returns true for some element
        range = the input range to search
        fromIndex = which index to start searching from

    Returns:
        `some!size_t` or `none` if no element was found
*/
auto index(alias pred, Range)(Range range, size_t fromIndex = 0)
if (from!"std.range".isInputRange!Range
    && from!"bolts.traits".isUnaryOver!(pred, from!"std.range".ElementType!Range) )
{
    import std.range: drop;
    import std.functional: unaryFun;
    import phobos: stdCountUntil = countUntil;
    import optional: some;
    alias fun = unaryFun!pred;
    auto r = range.drop(fromIndex);
    return r.stdCountUntil!((a, b) => fun(a))(r) + fromIndex;
}

///
unittest {
    import optional: some, none;
    assert([1, 2, 3, 4].index!(a => a % 2 == 0) == some(1));
    assert([1, 2, 3, 4].index!(a => a == 5) == none);
    assert([1, 2, 3, 4].index!(a => a % 2 == 0)(2) == some(3));
}

/**
    Returns `optional` index of the last element predicate returns true for.

    Params:
        pred = unary function that returns true for some element
        range = the input range to search
        fromIndex = which index from the end to start searching from

    Returns:
        `some!size_t` or `none` if no element was found
*/
auto lastIndex(alias pred, Range)(Range range, size_t fromIndex = 0)
if (from!"std.range".isBidirectionalRange!Range)
{
    import std.range: retro, walkLength;
    import algorithm: index;
    import range: withFront;
    return range
        .retro
        .index!pred(fromIndex)
        .withFront!(a => range.walkLength - a - 1);
}

///
unittest {
    import optional: some, none;
    assert([1, 2, 3, 4].lastIndex!(a => a % 2 == 0) == some(3));
    assert([1, 2, 3, 4].lastIndex!(a => a == 5) == none);
    assert([1, 2, 3, 4].lastIndex!(a => a % 2 == 0)(2) == some(1));
}
