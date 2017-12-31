module range.concat;

import std.range: isInputRange;

auto concat(R, V...)(R range, V values) if (isInputRange!R) {
    import std.range: chain, ElementType;
    static if (V.length) {
        static if (isInputRange!(V[0])) {
            return range.chain(values[0]).concat(values[1..$]);
        } else static if (is(V[0] : ElementType!R)) {
            return range.chain([values[0]]).concat(values[1..$]);
        } else {
            static assert(0, "Attempted to concat unsupported type: " ~ V[0].stringof);
        }
    } else {
        return range;
    }
}

unittest {
    import std.range: iota, array;
    assert([1, 2, 3].concat(4, [5], [6, 7], 8).array == 1.iota(9).array);
    assert([1.0].concat(2).array == [1.0, 2.0]);
    assert([1.0].concat([2, 3]).array == [1.0, 2.0, 3.0]);
    static assert(!__traits(compiles, [1].concat(2, 3.f)));
}
