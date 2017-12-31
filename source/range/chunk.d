module range.chunk;

import std.range: isInputRange;

auto chunk(Range)(Range r, size_t size) if (isInputRange!Range) {
    // TODO: lodash returns a 0 length range if size is zero. Requires a rewrite of the chunks
    // range.
    import std.range: chunks;
    return r.chunks(size);
}

unittest {
    // assert([1, 2, 3].chunk(0).array == (int[]).init);
}
