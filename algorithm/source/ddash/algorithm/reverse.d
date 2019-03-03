/**
    Reverses the range by mutating it
*/
module ddash.algorithm.reverse;

///
@("Module example")
unittest {
    auto arr = [1, 2, 3, 4];
    arr.reverse;
    assert(arr.equal([4, 3, 2, 1]));
}

import ddash.common;

/**
    Reverses elements in a range

    Params:
        range = the range to reverse

    Since:
        0.0.1
*/
void reverse(Range)(ref Range range)
if (from.std.range.isBidirectionalRange!Range
    && !from.std.range.isRandomAccessRange!Range
    && from.std.range.hasSwappableElements!Range
    || (from.std.range.isRandomAccessRange!Range && from.std.range.hasLength!Range))
{
    import std.algorithm: reverse;
    range.reverse;
}
