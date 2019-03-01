/**
    Compacts a range
*/
module ddash.algorithm.compact;

///
@("Module example")
unittest {
    import ddash.utils: isFalsey, no, some;

    // compact falsy values
    assert([0, 1, 2, 0, 3].compact!isFalsey.equal([1, 2, 3]));

    // compact empty arrays
    assert([[1], [], [2]].compact!isFalsey.equal([[1], [2]]));

    // compact optionals
    assert([some(2), no!int].compact!isFalsey.equal([some(2)]));

    class C {
        int i;
        this(int i) { this.i = i; }
    }

    import std.algorithm: map;
    auto arr = [new C(1), null, new C(2), null];
    assert(arr.compact.map!"a.i".equal([1, 2]));

    struct A {
        int x;
    }

    // compact by a object member
    assert([A(7), A(0)].compactBy!("x", isFalsey).equal([A(7)]));

    // compact an associative array
    auto aa = ["a": 1, "b": 0, "c": 2];
    assert(aa.compactValues!isFalsey == ["a": 1, "c": 2]);
}

import ddash.common;

/**
    Compacts a range

    Params:
        pred = a unary predicate that returns true if value should be compacted
        range = an input range

    Returns:
        compacted range

    Since:
        0.0.1
*/
auto compact(alias pred = null, Range)(Range range) if (from!"std.range".isInputRange!Range) {
    return compactBase!("", pred)(range);
}

///
@("Unary predicate example")
unittest {
    import ddash.utils: isFalsey, no, some;
    assert([0, 1, 2, 0, 3].compact!(isFalsey).equal([1, 2, 3]));
    assert([[1], [], [2]].compact!isFalsey.equal([[1], [2]]));
    assert([some(2), no!int].compact!isFalsey.equal([some(2)]));

    class C {
        int i;
        this(int i) { this.i = i; }
    }

    import std.algorithm: map;
    auto arr = [new C(1), null, new C(2), null];
    assert(arr.compact.map!(a => a.i).equal([1, 2]));
}

/**
    Compacts a range by a publicly visible member variable or property of `ElemntType!Range`

    Params:
        member = which member in `ElementType!Range` to compact by
        pred = a unary predicate that returns true if value should be compacted
        range = an input range

    Returns:
        compacted range

    Since:
        0.0.1
*/
auto compactBy(string member, alias pred = null, Range)(Range range) if (from!"std.range".isInputRange!Range) {
    return compactBase!(member, pred)(range);
}

///
@("By-member example")
unittest {
    import ddash.utils: isFalsey;
    struct A {
        int x;
        private int y;
    }
    assert([A(3, 2), A(0, 1)].compactBy!("x", isFalsey).equal([A(3, 2)]));
    assert(!__traits(compiles, [A(3, 2)].compactBy!("y", isFalsey)));
    assert(!__traits(compiles, [A(3, 2)].compactBy!("z", isFalsey)));
    assert(!__traits(compiles, [A(3, 2)].compactBy!("", isFalsey)));
}

/**
    Compacts an associative array by its values

    Params:
        pred = a unary predicate that returns true if value should be compacted
        aa = compacted associated array

    Returns:
        compacted associtive array

    Since:
        0.0.1
*/
auto compactValues(alias pred = null, T, U)(T[U] aa) {
    import std.array: byPair, assocArray;
    return aa
        .byPair
        .compactBy!("value", pred)
        .assocArray;
}

///
@("AA example")
unittest {
    import ddash.utils: isFalsey;
    auto aa = ["a": 1, "b": 0, "c": 2];
    assert(aa.compactValues!isFalsey == ["a": 1, "c": 2]);
}

/**
    Compacts a list of values

    Params:
        values = list of values that share a common type

    Returns:
        Compacted array of values cast to common type T

    Since:
        0.0.1
*/
auto compact(alias pred = null, Values...)(Values values) if (!is(from!"std.traits".CommonType!Values == void)) {
    import ddash.algorithm: concat;
    return concat(values)
        .compactBase!("", pred);
}

///
@("Compile-time sequence example")
unittest {
    import ddash.utils: isFalsey;
    auto a = compact!isFalsey(1, 0, 2, 0, 3);
    auto b = compact!isFalsey(1, 0, 2.0, 0, 3);

    assert(a.equal([1, 2, 3]));
    assert(b.equal([1, 2, 3]));

    static assert(is(typeof(a.array) == int[]));
    static assert(is(typeof(b.array) == double[]));
}

private auto compactBase(string member, alias pred = null, Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.algorithm: filter;
    import bolts: isNullType, isUnaryOver;
    import ddash.common.valueby;
    import std.range: ElementType;

    alias E = ElementType!Range;

    static if (isNullType!pred) {
        import bolts: isNullable;
        static assert(
            isNullable!E,
            "Cannot compact non-nullable type `" ~ E.stringof ~ "'",
        );
        alias fun = (a) => valueBy!member(a) !is null;
    } else static if (isUnaryOver!(pred, typeof(valueBy!member(E.init)))) {
        alias fun = a => !pred(valueBy!member(a));
    } else {
        static assert(0, "predicate must either be null or bool function(" ~ E.stringof ~ ")");
    }

    return range.filter!fun;
}
