module algorithm.pull;

import common;

ref pull(Range, Values...)(return ref Range range, Values values) {
    import std.algorithm: canFind, remove;
    import algorithm: concat;
    range = range.remove!(a => values.concat.canFind(a));
    return range;
}

unittest {
    int[] arr = [1, 2, 3, 4, 5];
    arr.pull(1, [2, 5]);
    assert(arr == [3, 4]);
}
