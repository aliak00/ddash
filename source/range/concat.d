module range.concat;

import std.range: isInputRange;

auto concat(R, V...)(R range, V values) if (isInputRange!R) {
    import std.range: chain, ElementType;
    static if (V.length) {
        static if (isInputRange!(V[0]) && is(ElementType!(V[0]) : ElementType!R)) {
            return range.chain(values[0]).concat(values[1..$]);
        } else static if (is(V[0] : ElementType!R)) {
            return range.chain([values[0]]).concat(values[1..$]);
        } else {
            static assert(0, "Attempted to concat type " ~ V[0].stringof ~ " to range of " ~ ElementType!R.stringof);
        }
    } else {
        return range;
    }
}

unittest {
    import std.range: iota, array;
    // Concat single elements and ranges
    assert([1, 2, 3].concat(4, [5], [6, 7], 8).array == 1.iota(9).array);
    // Implicitly convertible elements ok
    assert([1.0].concat(2).array == [1.0, 2.0]);
    // Implicitly convertible ranges ok
    assert([1.0].concat([2, 3]).array == [1.0, 2.0, 3.0]);
    // Non implicily convertible elements not ok
    static assert(!__traits(compiles, [1].concat(1, 2.0)));
    // Non implicily convertible range not ok
    static assert(!__traits(compiles, [1].concat(1, [2.0])));
}
