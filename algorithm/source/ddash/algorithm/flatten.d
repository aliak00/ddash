/**
    Flattens a range one level deep by removing non truthy values.
*/
module ddash.algorithm.flatten;

///
unittest {
    auto arrayOfArrays = [[[1]], [[]], [[2], [3]], [[4]]];

    // remove emptys
    assert(arrayOfArrays.flatten.equal([[1], [], [2], [3], [4]]));
    assert([[1], [], [2, 3], [4]].flatten.equal([1, 2, 3, 4]));

    // remove empty all the way down
    assert(arrayOfArrays.flattenDeep.equal([1, 2, 3, 4]));

    import optional;
    assert([some(some(3)), no!(Optional!int), some(some(2))].flattenDeep.equal([3, 2]));
}

import ddash.algorithm.internal.common;

/**
    Flattens a range one level deep by removing anything that's empty

    Params:
        range = an input range

    Returns:
        A flattened range

    Since:
        0.1.0
*/
auto flatten(Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.range: ElementType, isInputRange;
    static if (isInputRange!(ElementType!Range))
    {
        import std.algorithm: joiner;
        return range.joiner;
    }
    else
    {
        return range;
    }
}

unittest {
    assert([[[1]], [[]], [[2], [3]], [[4]]].flatten.equal([[1], [], [2], [3], [4]]));
    assert([[1], [], [2, 3], [4]].flatten.equal([1, 2, 3, 4]));
}

unittest {
    import optional;
    assert([some(3), no!int, some(2)].flatten.equal([3, 2]));
    assert([some(some(3)), no!(Optional!int), some(some(2))].flatten.equal([some(3), some(2)]));
}

/**
    Flattens a range all the way down

    Params:
        range = an input range

    Returns:
        A flattened range

    Since:
        0.1.0
*/
auto flattenDeep(Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.range: ElementType, isInputRange;
    import ddash.algorithm: flatten;
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
