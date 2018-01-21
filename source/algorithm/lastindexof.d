/// Finds the last element in a range that equals some value
module algorithm.lastindexof;

///
unittest {
    import optional;
    assert([1, 2, 1, 2].lastIndexOf(2) == some(3));
    assert([1, 2, 1, 2].lastIndexOf(2, 2) == some(1));
    assert([1, 2, 1, 2].lastIndexOf(3) == none);
}

import common: from;

/**
    Ditto

    Params:
        range = an input range
        value = value to search for
        fromIndex = which index counting backwards to start searching from

    Returns:
        An `optional!T`
*/
auto lastIndexOf(Range, T)(Range range, T value, size_t fromIndex = 0) if (from!"std.range".isBidirectionalRange!Range) {
    import std.range: retro, walkLength;
    import algorithm: indexOf;
    import range: withFront;
    return range
        .retro
        .indexOf(value, fromIndex)
        .withFront!(a => range.walkLength - a - 1);
}
