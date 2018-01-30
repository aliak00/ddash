/**
    Removes elements from a range
*/
module algorithm.pull;

///
unittest {
    int[] arr = [1, 2, 3, 4, 5];
    arr.pull(1, [2, 5]);
    assert(arr == [3, 4]);
}

import common;

/**
    Removes elements from a range.

    Params:
        range = a mutable range
        values = variables args of ranges and values to pull out

    Returns:
        Modified range
*/
ref pull(Range, Values...)(return ref Range range, Values values) {
    import std.algorithm: canFind, remove;
    import algorithm: concat;
    range = range.remove!(a => values.concat.canFind(a));
    return range;
}
