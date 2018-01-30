/**
    Creates a range consisting of chunks of another range
*/
module algorithm.chunk;

///
unittest {
    assert([1, 2, 3].chunk(0).equal((int[][]).init));
    assert([1, 2, 3].chunk(1).equal([[1], [2], [3]]));
}

import common;

/**
    Creates a range of ranges of length `size`. If the range can't be split evenly,
    the final `chunk`` will be the remaining elements.

    Params:
        range = An input range
        size = chunk size

    Returns:
        Range of chunks
*/
auto chunk(Range)(Range range, size_t size) if (from!"std.range".isInputRange!Range) {
    import std.range: chunks, takeNone;
    if (size) {
        return range.chunks(size);
    } else {
        return range.chunks(1).takeNone;
    }
}
