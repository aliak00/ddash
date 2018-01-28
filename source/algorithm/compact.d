/**
    Creates a range with all falsey values removed.

    See_also:
        `utils.istruthy`
*/
module algorithm.compact;

///
unittest {
    import optional: no, some;
    assert([0, 1, 2, 0, 3].compact.equal([1, 2, 3]));
    assert([[1], [], [2]].compact.equal([[1], [2]]));
    assert([some(2), no!int].compact.equal([some(2)]));
}

import common;

private auto compactBase(string member = "", Range)(Range range) {
    import std.algorithm: filter;
    import std.range: ElementType;
    import utils: isTruthy;
    alias E = ElementType!Range;
    static if (member != "")
    {
        static assert(__traits(hasMember, E, member), E.stringof ~ " has no member " ~ member);
        static assert(
            __traits(getProtection, __traits(getMember, E, member)) == "public",
            E.stringof ~ "." ~ member ~ " is not public"
        );
        alias m = (a) => mixin("a." ~ member);
    }
    else
    {
        alias m = (a) => a;
    }
    return range
        .filter!(a => m(a).isTruthy);
}

/**
    Compacts a range

    Params:
        range = an input range

    Returns:
        compacted range
*/
auto compact(Range)(Range range) if (from!"std.range".isInputRange!Range) {
    return compactBase(range);
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
auto compactBy(string member, Range)(Range range) if (from!"std.range".isInputRange!Range && member.length) {
    return compactBase!(member)(range);
}

///
unittest {
    import std.array;
    struct A {
        int x;
        private int y;
    }
    assert([A(3, 2), A(0, 1)].compactBy!"x".array == [A(3, 2)]);
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
