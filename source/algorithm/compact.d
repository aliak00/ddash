module algorithm.compact;

import common: from;

auto compact(Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.algorithm: filter;
    import utils: isTruthy;
    return range.filter!isTruthy;
}

unittest {
    import std.array;
    import optional: no, some;
    assert([0, 1, 2, 0, 3].compact.array == [1, 2, 3]);
    assert([[1], [], [2]].compact.array == [[1], [2]]);
    assert([some(2), no!int].compact.array == [some(2)]);
}
