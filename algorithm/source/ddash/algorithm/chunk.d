/**
    Creates a range consisting of chunks of another range

    Differences_between:
        <li>$(LINK2 https://dlang.org/library/std/range/chunks.html, phobos.std.range.chunk) - treats `0` as a valid chunk size
        <li>$(LINK2 https://lodash.com/docs/4.17.5#chunk, lodash.chunks) - none intended
*/
module ddash.algorithm.chunk;

///
unittest {
    assert([1, 2, 3].chunk(0).equal((int[][]).init));
    assert([1, 2, 3].chunk(1).equal([[1], [2], [3]]));
}

import ddash.algorithm.internal.common;

/**
    Creates a range of ranges of length `size`. If the range can't be split evenly,
    the final `chunk`` will be the remaining elements.

    Params:
        range = An input range
        size = chunk size

    Returns:
        Range of chunks

    Since:
        0.1.0
*/
auto chunk(Range)(Range range, size_t size) if (from!"std.range".isInputRange!Range) {
    import std.range: chunks, takeNone;
    if (size) {
        return range.chunks(size);
    } else {
        return range.chunks(1).takeNone;
    }
}
