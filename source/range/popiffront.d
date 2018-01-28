module range.popiffront;

import common;

auto popIfFront(Range)(auto ref Range range) if (from!"std.range".isInputRange!Range) {
    import std.range: empty, popFront;
    if (!range.empty) {
        range.popFront;
    }
    return range;
}

unittest {
    import std.array;
    // Test with rvalues
    auto r0 = (int[]).init;
    auto r1 = [1];
    auto r2 = [1, 2];

    assert(r0.popIfFront.array == []);
    assert(r1.popIfFront.array == []);
    assert(r2.popIfFront.array == [2]);

    assert(r0.array == []);
    assert(r1.array == []);
    assert(r2.array == [2]);

    // Ensure lvalues work
    assert((int[]).init.popIfFront.array == []);
    assert([1, 2].popIfFront.array == [2]);
}
