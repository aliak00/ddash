/// Returns `optional` index of the last element predicate returns true for.
module algorithm.findlastindex;

///
unittest {
    import optional: some, none;
    assert([1, 2, 3, 4].findLastIndex!(a => a % 2 == 0) == some(3));
    assert([1, 2, 3, 4].findLastIndex!(a => a == 5) == none);
    assert([1, 2, 3, 4].findLastIndex!(a => a % 2 == 0)(2) == some(1));
}

import common;

/**
    Ditto

    Params:
        pred = unary function that returns true for some element
        range = the input range to search
        fromIndex = which index from the end to start searching from

    Returns:
        `some!size_t` or `none` if no element was found
*/
auto findLastIndex(alias pred, Range)(Range range, size_t fromIndex = 0)
if (from!"std.range".isBidirectionalRange!Range)
{
    import std.range: retro, walkLength;
    import algorithm: findIndex;
    import range: withFront;
    return range
        .retro
        .findIndex!pred(fromIndex)
        .withFront!(a => range.walkLength - a - 1);
}
