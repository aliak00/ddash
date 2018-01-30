/**
    Flattens a range one level deep by removing non truthy values.

    See_also:
        `utils.istruthy`
*/
module algorithm.flatten;

///
unittest {
    assert([[[1]], [[]], [[2], [3]], [[4]]].flatten.equal([[1], [], [2], [3], [4]]));
    assert([[1], [], [2, 3], [4]].flatten.equal([1, 2, 3, 4]));
}

import common;

/**
    Flattens a range one level deep by removing non truthy values.

    Params:
        range = an input range

    Returns:
        A flattened range

    See_also:
        `utils.istruthy`
        <br>`utils.deref`
*/
auto flatten(Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.range: ElementType, isInputRange;
    import std.traits: isPointer;
    import optional: isOptional;
    alias E = ElementType!Range;
    static if (isOptional!E || isPointer!E)
    {
        import std.algorithm: map, filter;
        import utils: isTruthy, deref;
        return range
            .filter!isTruthy
            .map!deref;
    }
    else static if (isInputRange!E)
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
