module range.chunk;

import std.range: isInputRange;

auto chunk(Range)(Range r, size_t size) if (isInputRange!Range) {
    import std.range: chunks, takeNone;
    if (size) {
        return r.chunks(size);
    } else {
        return r.chunks(1).takeNone;
    }
}

unittest {
    import std.array;
    assert([1, 2, 3].chunk(0).array == (int[][]).init);
    assert([1, 2, 3].chunk(1).array == [[1], [2], [3]]);
}
