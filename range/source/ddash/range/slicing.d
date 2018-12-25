/**
    Returns a slice of a range
*/
module ddash.range.slicing;

///
@("module example")
unittest {
    auto arr = [1, 2, 3, 4, 5];

    assert(arr.slice(1).equal([2, 3, 4, 5]));
    assert(arr.slice(0, 0).empty);
    assert(arr.slice(1, 3).equal([2, 3]));
    assert(arr.slice(0, -2).equal([1, 2, 3]));

    assert(arr.initial.equal([1, 2, 3, 4]));

    assert(arr.tail.equal([2, 3, 4, 5]));
}

import ddash.common;

/**
    Returns a slice of range from start up to, but not including, end

    If end is not provided the whole rest of the range is implied. And if
    end is a negative number then it's translated to `range.length - abs(end)`.`

    Params:
        range = the input range to slice
        start = at which index to start the slice
        end = which index to end the slice

    Returns:
        A range

    Since:
        0.0.1
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

/**
    Gets all but the first element of a range

    Params:
        range = an input range

    Returns:
        A range

    Since:
        0.0.1
*/
alias tail = (range) => from!"std.range".drop(range, 1);

///
@("tail example")
unittest {
    assert((int[]).init.tail.empty);
    assert([1, 2, 3, 4].tail.equal([2, 3, 4]));
}

/**
    Gets all but the last element of a range

    Params:
        range = an input range

    Returns:
        A range

    Since:
        0.0.1
*/
alias initial = (range) => from!"std.range".dropBack(range, 1);

///
@("initial example")
unittest {
    assert((int[]).init.initial.empty);
    assert([1, 2, 3, 4].initial.equal([1, 2, 3]));
}
