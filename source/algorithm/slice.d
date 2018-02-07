/**
    Returns a slice of a range
*/
module algorithm.slice;

///
unittest {
    assert([1, 2, 3, 4, 5].slice(1).equal([2, 3, 4, 5]));
    assert([1, 2, 3, 4, 5].slice(0, 0).empty);
    assert([1, 2, 3, 4, 5].slice(1, 3).equal([2, 3]));
    assert([1, 2, 3, 4, 5].slice(0, -2).equal([1, 2, 3]));
}

import common;

/**
    Returns a slice of range from start up to, but not including, end

    If end is not provided the whole rest of the range is implied. And if
    end is a negative number then it's translated to `range.length - abs(end)`.`

    Params:
        range = the input range to slice
        start = at which index to start the slice
        end = which index to end the slice
*/
auto slice(Range)(Range range, size_t start, int end) {
    import std.range: drop, take, takeNone, walkLength;
    if (!end) {
        return range.takeNone;
    }
    size_t absoluteEnd = end;
    if (end < 0) {
        absoluteEnd = range.walkLength + end;
    }
    return range.drop(start).take(absoluteEnd - start);
}

/// Ditto
auto slice(Range)(Range range, size_t start) {
    import std.range: drop;
    return range.drop(start);
}
