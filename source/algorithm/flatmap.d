module algorithm.flatmap;

import std.range: isInputRange;

version (unittest) {
    import std.array;
}

auto flatMap(alias fun, Range)(Range r) if (isInputRange!Range) {
    import std.algorithm: map, filter;
    import std.range: ElementType;
    import std.traits: isPointer, isArray;
    import optional: isOptional;
    alias E = ElementType!Range;
    static if (isOptional!E) {
        import optional: isSome;
        return r.filter!isSome.map!(a => a.front).map!(fun);
    } else static if (isPointer!E) {
        return r.filter!(a => a !is null).map!(a => *a).map!(fun);
    } else static if (isArray!E) {
        return r.filter!(a => a.length).map!(fun);
    } else {
        return r.map!(fun);
    }
}

unittest {
    import optional: optional;
    auto optionalArray = [
        optional!int,
        optional(3),
        optional!int,
        optional(7),
    ];
    assert(optionalArray.flatMap!(a => a).array == [3, 7]);
}

unittest {
    auto intArray = [
        3,
        7,
    ];
    assert(intArray.flatMap!(a => a).array == [3, 7]);
}

unittest {
    auto intPointerArray = [
        (new int(3)),
        null,
        (new int(7)),
        null,
    ];
    assert(intPointerArray.flatMap!(a => a).array == [3, 7]);
}

unittest {
    auto intArrayOfArrays = [
        [3],
        [],
        [7],
        [],
    ];
    assert(intArrayOfArrays.flatMap!(a => a).array == [[3], [7]]);
}
