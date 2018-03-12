/// Drops elements from a range
module algorithm.drop;

///
unittest {
    assert([1, 2, 3, 4].drop.array == [2, 3, 4]);
    assert([1, 2, 3, 4].dropRight.array == [1, 2, 3]);
    assert([1, 2, 3, 4].dropWhile!(a => a < 3).array == [3, 4]);
    assert([1, 2, 3, 4].dropRightWhile!(a => a > 2).equal([1, 2]));

}

import common;


/**
    Drops n elements from beginning of range

    Params:
        range = input range
        n = number of elements to drop

    Returns:
        new range
*/
auto drop(Range)(Range range, size_t n = 1) if (from!"std.range".isInputRange!Range) {
    import std.range: stdDrop = drop;
    return range.stdDrop(n);
}

///
unittest {
    import std.array;
    assert([1, 2, 3].drop.equal([2, 3]));
}

/**
    Drops n elements from end of range

    Params:
        range = input range
        n = number of elements to drop

    Returns:
        new range
*/
auto dropRight(Range)(Range range, size_t n = 1) if (from!"std.range".isBidirectionalRange!Range) {
    import std.range: stdDropBack = dropBack;
    return range.stdDropBack(n);
}

///
unittest {
    import std.array;
    assert([1, 2, 3].dropRight.equal([1, 2]));
}

/**
    Drops elements from beginnig of range while predicate is true

    Params:
        pred = comparator
        range = input range

    Returns:
        new range
*/
auto dropWhile(alias pred, Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.functional: unaryFun;
    import std.range: empty, back, popBack;
    while (!range.empty && unaryFun!pred(range.front)) range.popFront;
    return range;
}

///
unittest {
    import std.array;
    assert([1, 2, 3, 4].dropWhile!(a => a < 3).equal([3, 4]));
}

/**
    Drops elements from end of range while predicate is true

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
