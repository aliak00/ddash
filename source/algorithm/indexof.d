/**
    Finds the first element in a range that equals some value
*/
module algorithm.indexof;

///
unittest {
    import optional;
    assert([1, 2, 1, 2].indexOf(2) == some(1));
    assert([1, 2, 1, 2].indexOf(2, 2) == some(3));
    assert([1, 2, 1, 2].indexOf(3) == none);
}

import common: from;

/**
    Finds the first element in a range that equals some value

    Params:
        range = an input range
        value = value to search for
        fromIndex = which index to start searching from

    Returns:
        An `optional!T`
*/
auto indexOf(Range, T)(Range range, T value, size_t fromIndex = 0) if (from!"std.range".isInputRange!Range) {
    import std.range: drop;
    import phobos: countUntil;
    import range: withFront;
    return range
        .drop(fromIndex)
        .countUntil(value)
        .withFront!(a => a + fromIndex);
}
