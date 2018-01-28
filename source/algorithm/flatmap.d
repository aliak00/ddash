module algorithm.flatmap;

import common;

auto flatMap(alias fun, Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.algorithm: map;
    import algorithm: flatten;
    return range
        .flatten
        .map!(fun);
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
    assert(intArrayOfArrays.flatMap!(a => a).array == [3, 7]);
}
