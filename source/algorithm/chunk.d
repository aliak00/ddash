/**
    Creates an array of elements split into groups the length of size. If array can't be split evenly,
    the final chunk will be the remaining elements.
*/
module algorithm.chunk;

///
unittest {
    assert([1, 2, 3].chunk(0).equal((int[][]).init));
    assert([1, 2, 3].chunk(1).equal([[1], [2], [3]]));
}

import common;

/**
    Ditto

    Params:
        range = An input range
        size = chunk size

    Returns:
        range of chunks
*/
auto chunk(Range)(Range range, size_t size) if (from!"std.range".isInputRange!Range) {
    import std.range: chunks, takeNone;
    if (size) {
        return range.chunks(size);
    } else {
        return range.chunks(1).takeNone;
    }
}
