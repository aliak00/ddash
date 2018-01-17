/**
    Creates a new range concatenating input range with any additional ranges and/or values.
*/
module algorithm.concat;

///
unittest {
    import std.range: iota, array;

    // Concat single elements and ranges
    assert([1, 2, 3].concat(4, [5], [6, 7], 8).array == 1.iota(9).array);

    // Concat single element
    assert([1].concat(2).array == [1, 2]);

    // Implicitly convertible elements ok
    assert([1.0].concat(2).array == [1.0, 2.0]);

    // Implicitly convertible ranges ok
    assert([1.0].concat([2, 3]).array == [1.0, 2.0, 3.0]);

    // Concat nothing to single value
    assert(1.concat().array == [1]);

    // Concat nothing to range
    assert([1].concat().array == [1]);

    // Concat values to another value
    assert(1.concat(2, 3).array == [1, 2, 3]);

    // Concat ranges or values to another value
    assert(1.concat(2, [3, 4]).array == [1, 2, 3, 4]);

    // Non implicily convertible elements not ok
    static assert(!__traits(compiles, [1].concat(1, 2.0)));

    // Non implicily convertible range not ok
    static assert(!__traits(compiles, [1].concat(1, [2.0])));
}

import common: from;

/**
    Concat `values` to `range`. Each value to concatenate with `range` must be either a single
    value that is implicitly convertible to `ElementType!Range` or a range that has element types
    that are implictly convertible

    Params:
        range = an input range
        values = Either a single element or an input range
            which will be concatenated to `range`

    Returns:
        A range
*/
auto concat(Range, Values...)(Range range, Values values) if (from!"std.range".isInputRange!Range) {
    import std.range: chain, ElementType, isInputRange;
    static if (Values.length)
    {
        static if (isInputRange!(Values[0]) && is(ElementType!(Values[0]) : ElementType!Range))
        {
            return range
                .chain(values[0])
                .concat(values[1..$]);
        }
        else static if (is(Values[0] : ElementType!Range))
        {
            return range
                .chain([values[0]])
                .concat(values[1..$]);
        }
        else
        {
            static assert(0, "Cannot concat type " ~ Values[0].stringof ~ " to range of " ~ ElementType!Range.stringof);
        }
    }
    else
    {
        return range;
    }
}

/**
    Concat `values` to `value` creating a range

    Params:
        value = any value T
        values = Either a single element or an input range
            which will be concatenated to `range`

    Returns:
        A range
*/
auto concat(T, Values...)(T value, Values values) if (!from!"std.range".isInputRange!T) {
    import std.range: only;
    return concat([value], values);
}

///
unittest {
    import std.array;
    assert(concat(1, 2, 3).array == [1, 2, 3]);
}
