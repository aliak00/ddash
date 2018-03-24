/// Assigns value to each element of input range range
module algorithm.fill;

///
unittest {
    int[] a = [1, 2, 3];
    a.fill(5);
    assert(a == [5, 5, 5]);

    int[] b = [1, 2, 3, 4, 5];
    b.fill(9, 2, 4);
    assert(b == [1, 2, 9, 9, 5]);

    int[] c = [1, 2, 3, 4, 5];
    c.fill(9, 1, 100);
    assert(c == [1, 9, 9, 9, 9]);
}

import common;

/**
    Fills a range with a value from `startIndex` to `endIndex`

    Params:
        range = mutable input range
        value = which value to fill the range with
        startIndex = at which index to start filling the range
        endIndex = at which index to stop filling the range (this index is not filled)

    Since:
        0.1.0
*/
void fill(Range, T)(ref Range range, auto ref T value, size_t startIndex = 0, size_t endIndex = size_t.max)
if (from!"std.range".isForwardRange!Range
    && is(T : from!"std.range".ElementType!Range)
    && is(typeof(range[] = value)))
{
    import std.algorithm: stdFill = fill;
    import std.range: drop, take, refRange, save;
    refRange(&range)
        .save
        .drop(startIndex)
        .take(endIndex - startIndex)
        .stdFill(value);
}

unittest {
    // Should not compile if range is not reference type
    static assert(!__traits(compiles, [1].fill(3)));

    // Should not compile if range does not have assignable elements
    immutable int[] a = [1, 2];
    static assert(!__traits(compiles, a.fill(3)));
}
