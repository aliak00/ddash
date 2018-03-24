/// Flatmaps a range
module algorithm.flatmap;
import common;

///
unittest {
    auto dup(int n) {
        return [n, n];
    }

    assert([1, 2].flatMap!dup.equal([1, 1, 2, 2]));

    import optional: some, no;

    assert([
        no!int,
        some(3),
        no!int,
        some(7),
    ].flatMap!"a".equal(
        [3, 7]
    ));
}

/**
    Flatmaps a range of elemenents

    Params:
        unaryPred = unary mapping function
        range = an input range

    Returns:
        New range that has been mapped and flattened

    Since:
        0.1.0
*/
auto flatMap(alias unaryPred, Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.algorithm: map;
    import algorithm: flatten;
    return range
        .map!unaryPred
        .flatten;
}

unittest {
    import optional: some, no;
    auto optionalArray = [
        no!int,
        some(3),
        no!int,
        some(7),
    ];
    assert(optionalArray.flatMap!(a => a).equal([3, 7]));
}

unittest {
    auto intArray = [
        3,
        7,
    ];
    assert(intArray.flatMap!(a => a).equal([3, 7]));
}

unittest {
    auto intArrayOfArrays = [
        [3],
        [],
        [7, 8],
        [],
    ];
    assert(intArrayOfArrays.flatMap!(a => a).equal([3, 7, 8]));
}
