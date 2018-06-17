/**
    Reverses the range by mutating it
*/
module ddash.algorithm.reverse;

///
unittest {
    auto arr = [1, 2, 3, 4];
    arr.reverse;
    assert(arr.equal([4, 3, 2, 1]));
}

import ddash.algorithm.internal.common;

/**
    Reverses elements in a range

    Params:
        range = the range to reverse

    Since:
        0.1.0
*/
void reverse(Range)(ref Range range)
if (from!"std.range".isBidirectionalRange!Range
    && !from!"std.range".isRandomAccessRange!Range
    && from!"std.range".hasSwappableElements!Range
    || (from!"std.range".isRandomAccessRange!Range && from!"std.range".hasLength!Range))
{
    import std.algorithm: reverse;
    range.reverse;
}
