/**
    Creates a range with all falsey values removed.

    See_also:
        `utils.istruthy`
*/
module algorithm.compact;

///
unittest {
    import optional: no, some;

    // compact falsy values
    assert([0, 1, 2, 0, 3].compact.equal([1, 2, 3]));

    // compact empty arrays
    assert([[1], [], [2]].compact.equal([[1], [2]]));

    // compact optionals
    assert([some(2), no!int].compact.equal([some(2)]));

    struct A {
        int x;
    }

    // compact by a object member
    assert([A(7), A(0)].compactBy!"x".equal([A(7)]));

    // compact an associative array
    auto aa = ["a": 1, "b": 0, "c": 2];
    assert(aa.compactValues == ["a": 1, "c": 2]);
}

import common;

/**
    Compacts a range

    Params:
        range = an input range

    Returns:
        compacted range
*/
auto compact(Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.algorithm: filter;
    import utils: isTruthy;
    return range
        .filter!(a => a.isTruthy);
}

///
unittest {
    import optional: no, some;
    assert([0, 1, 2, 0, 3].compact.equal([1, 2, 3]));
    assert([[1], [], [2]].compact.equal([[1], [2]]));
    assert([some(2), no!int].compact.equal([some(2)]));
}

/**
    Compacts a range by a publicly visible member variable or property of `ElemntType!Range`

    Params:
        member = which member in `ElementType!Range` to compact by
        range = an input range

    Returns:
        compacted range
*/
auto compactBy(string member, Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.algorithm: filter;
    import utils: isTruthy;
    import internal: valueBy;
    return range
        .filter!(a => valueBy!member(a).isTruthy);
}

///
unittest {
    struct A {
        int x;
        private int y;
    }
    assert([A(3, 2), A(0, 1)].compactBy!"x".equal([A(3, 2)]));
    assert(!__traits(compiles, [A(3, 2)].compactBy!"y"));
    assert(!__traits(compiles, [A(3, 2)].compactBy!"z"));
    assert(!__traits(compiles, [A(3, 2)].compactBy!""));
}

/**
    Compacts an associative array by its values

    Params:
        aa = compacted associated array

    Returns:
        compacted associtive array
*/
auto compactValues(T, U)(T[U] aa) {
    import std.array: byPair, assocArray;
    return aa
        .byPair
        .compactBy!"value"
        .assocArray;
}

///
unittest {
    auto aa = ["a": 1, "b": 0, "c": 2];
    assert(aa.compactValues == ["a": 1, "c": 2]);
}

/**
    Compacts a list of values

    Params:
        values = list of values that share a common type

    Returns:
        Compacted array of values cast to common type T
*/
template compact(Values...) if (!is(from!"std.traits".CommonType!Values == void)) {
    import std.traits: CommonType;
    import utils: isTruthy;
    alias T = CommonType!Values;
    auto compact(Values values) {
        T[] array;
        static foreach (i; 0 .. Values.length)
        {
            if (isTruthy(values[i])) {
                array ~= cast(T)(values[i]);
            }
        }
        return array;
    }
}

///
unittest {
    auto a = compact(1, 0, 2, 0, 3);
    auto b = compact(1, 0, 2.0, 0, 3);

    assert(a == [1, 2, 3]);
    assert(b == [1, 2, 3]);

    static assert(is(typeof(a) == int[]));
    static assert(is(typeof(b) == double[]));
}
