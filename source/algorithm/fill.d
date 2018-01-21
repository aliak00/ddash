/**
    /// Assigns value to each element of input range range
*/
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

import common: from;

/// Assigns value to each element of input range range
void fill(Range, T)(ref Range range, auto ref T value, size_t start = 0, size_t end = size_t.max)
if (from!"std.range".isInputRange!Range
    && is(T : from!"std.range".ElementType!Range)
    && is(typeof(range[] = value)))
{
    import std.algorithm: stdFill = fill;
    import std.range: drop, take, refRange, save;
    refRange(&range).save.drop(start).take(end - start).stdFill(value);
}

unittest {
    // Should not compile if range is not reference type
    static assert(!__traits(compiles, [1].fill(3)));

    // Should not compile if range does not have assignable elements
    immutable int[] a = [1, 2];
    static assert(!__traits(compiles, a.fill(3)));
}
