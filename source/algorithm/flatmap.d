module algorithm.flatmap;

import std.range: isInputRange;

auto flatMap(alias fun, Range)(Range range) if (isInputRange!Range) {
    import std.algorithm: map, filter;
    import std.range: ElementType;
    import std.traits: isPointer, isArray;
    import optional: isOptional;
    import utils: isTruthy, deref;
    alias E = ElementType!Range;
    static if (isOptional!E || isPointer!E) {
        return range.filter!isTruthy.map!deref.map!(fun);
    } else static if (isArray!E) {
        return range.filter!(a => a.length).map!(fun);
    } else {
        return range.map!(fun);
    }
}

version (unittest) {
    import std.array;
}

unittest {
    import optional: some, no;
    auto optionalArray = [
        no!int,
        some(3),
        no!int,
        some(7),
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
