/// Drops elements on end of range while predicate is true
module algorithm.droprightwhile;

///
unittest {
    import std.array;
    assert([1, 2, 3, 4].dropRightWhile!(a => a > 2).array == [1, 2]);
}

import common;

/**
    Ditto

    Params:
        pred = comparator
        range = input range

    Returns:
        new range
*/
auto dropRightWhile(alias pred, Range)(Range range) if (from!"std.range".isBidirectionalRange!Range) {
    import std.functional: unaryFun;
    import std.range: empty, back, popBack;
    while (!range.empty && unaryFun!pred(range.back)) range.popBack;
    return range;
}
