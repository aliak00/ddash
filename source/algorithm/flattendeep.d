/**
    Flattens range recursively
*/
module algorithm.flattendeep;

///
unittest {
    import std.array;
    import optional;
    assert([[[1]], [[]], [[2], [3]], [[4]]].flattenDeep.array == [1, 2, 3, 4]);
    assert([some(some(3)), no!(Optional!int), some(some(2))].flattenDeep.array == [3, 2]);
}

import common: from;

/**
    Flattens range recursively. Elements that are not truthy will be removed
    and other elements will be derefed

    Params:
        range = an input range

    Returns:
        A flattened range

    See_also:
        `utils.istruthy`
        <br>`utils.deref`
*/
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
