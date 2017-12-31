module range.compact;

import std.range: isInputRange;

auto compact(Range)(Range r) if (isInputRange!Range) {
    import std.algorithm: filter;
    import utils: isTruthy;
    return r.filter!isTruthy;
}

unittest {
    import std.array;
    import optional: no, some;
    assert([0, 1, 2, 0, 3].compact.array == [1, 2, 3]);
    assert([[1], [], [2]].compact.array == [[1], [2]]);
    assert([some(2), no!int].compact.array == [some(2)]);
}
