module algorithm.flattendeep;

import std.range: isInputRange;

auto flattenDeep(Range)(Range range) if (isInputRange!Range) {
    import std.range: ElementType;
    import algorithm: flatten;
    static if (isInputRange!(ElementType!Range))
    {
        return range.flatten.flattenDeep;
    }
    else
    {
        return range.flatten;
    }
}

unittest {
    import std.array;
    import optional;
    assert([[[1]], [[]], [[2], [3]], [[4]]].flattenDeep.array == [1, 2, 3, 4]);
    assert([some(some(3)), no!(Optional!int), some(some(2))].flattenDeep.array == [3, 2]);
}
