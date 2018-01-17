module algorithm.flattendeep;

import common: from;

auto flattenDeep(Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.range: ElementType, isInputRange;
    import algorithm: flatten;
    static if (isInputRange!(ElementType!Range))
    {
        return range
            .flatten
            .flattenDeep;
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
