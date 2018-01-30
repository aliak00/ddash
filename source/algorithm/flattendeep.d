/// Like $(DDOX_NAMED_REF algorithm.flatten, `flatten`) except it's recursive
module algorithm.flattendeep;

///
unittest {
    import optional;
    assert([[[1]], [[]], [[2], [3]], [[4]]].flattenDeep.equal([1, 2, 3, 4]));
    assert([some(some(3)), no!(Optional!int), some(some(2))].flattenDeep.equal([3, 2]));
}

import common;

/// Like flatten except it's recursive
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
