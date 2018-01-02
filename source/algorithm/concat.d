module algorithm.concat;

import std.range: isInputRange;

auto concat(Range, Values...)(Range range, Values values) if (isInputRange!Range) {
    import std.range: chain, ElementType;
    static if (Values.length) {
        static if (isInputRange!(Values[0]) && is(ElementType!(Values[0]) : ElementType!Range)) {
            return range.chain(values[0]).concat(values[1..$]);
        } else static if (is(Values[0] : ElementType!Range)) {
            import std.range: only;
            return range.chain(only(values[0])).concat(values[1..$]);
        } else {
            static assert(0, "Attempted to concat type " ~ Values[0].stringof ~ " to range of " ~ ElementType!Range.stringof);
        }
    } else {
        return range;
    }
}

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

    // Non implicily convertible elements not ok
    static assert(!__traits(compiles, [1].concat(1, 2.0)));

    // Non implicily convertible range not ok
    static assert(!__traits(compiles, [1].concat(1, [2.0])));
}
