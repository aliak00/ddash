/// Returns `optional` index of the last element predicate returns true for.
module algorithm.findlastindex;

///
unittest {
    import optional: some, none;
    assert([1, 2, 2, 1].findLastIndex(2) == some(2));
    assert([1, 2, 2, 1].findLastIndex(1) == some(3));
    assert([1, 2, 2, 1].findLastIndex(3) == none);
}

import common: from;

/**
    Ditto

    Params:
        pred = comparator
        range = the input range to search
        values = one or more ranges to search through
    Returns:
        `some!int` or `none` if no element was found
*/
auto findLastIndex(alias pred = "a == b", Range, Values...)(Range range, Values values)
if (from!"std.range".isBidirectionalRange!Range)
{
    import std.range: retro, walkLength;
    import algorithm: findIndex;
    import range: withFront;
    return range
        .retro
        .findIndex!pred(values)
        .withFront!(a => range.walkLength - a - 1);
}
