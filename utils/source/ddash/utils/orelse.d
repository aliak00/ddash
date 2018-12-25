/**
    Gets the value or else something else
*/
module ddash.utils.orelse;

import ddash.common;

private enum IsNullable(T) = from!"bolts.traits".isNullable!T;
// This is xor on nullable because if both of them are nullable then the IsNullable candidate will be used.
// This is becuase a range can also be nullable (e.g. string)
private enum BothRangeAndXorNullable(R, U) = from!"std.range".isInputRange!R && from!"std.range".isInputRange!U && (IsNullable!U ^ IsNullable!R);
private enum RangeAndElementOf(R, T) = from!"std.range".isInputRange!R && is(T : from!"std.range".ElementType!R);

/**
    Retrieves the value if it is a valid value else it will retrieve the `elseValue`. Instead of
    an `elseValue` and `elsePred` can be passes as an alias lambda parameter

    Params:
        val = the value to resolve
        elseValue = the value to get if `val` cannot be resolved
        elsePred = the perdicate to call if `val` cannot be resolved

    Returns:
        $(LI If `val` is nullable and null, then it will return the `elseValue`, else `val`)
        $(LI If `val` is a range and empty, and `elseValue` is a compatible range,
            then `elseValue` range will be returned, else `val`)
        $(LI If `val` is a range and empty, and `elseValue` is an `ElementType!Range`,
            then `elseValue` will be returned, else `val.front`)

    Since:
        - 0.0.2
*/
auto ref T orElse(alias elsePred, T)(auto ref T val) if (IsNullable!T && is(T == typeof(elsePred()))) {
    if (val is null) {
        return elsePred();
    }
    return val;
}

/// Ditto
auto ref T orElse(T)(auto ref T val, lazy T elseValue) if (IsNullable!T) {
    return val.orElse!elseValue;
}

/// Ditto
auto orElse(alias elsePred, R)(auto ref R range) if (BothRangeAndXorNullable!(R, typeof(elsePred()))) {
    import std.range: choose;
    return choose(range.empty, elsePred(), range);
}
/// Ditto
auto orElse(R, U)(auto ref R range, lazy U elseValue) if (BothRangeAndXorNullable!(R, U)) {
    return range.orElse!elseValue;
}

// Ditto
auto orElse(alias elsePred, R)(auto ref R range) if (RangeAndElementOf!(R, typeof(elsePred()))) {
    return range.empty ? elsePred() : range.front;
}

/// Ditto
auto orElse(R, U)(auto ref R range, lazy U elseValue) if (RangeAndElementOf!(R, U)) {
    return range.orElse!elseValue;
}

///
@("works with ranges, front, and lambdas")
unittest {
    // Get orElse ranges
    assert((int[]).init.orElse([1, 2, 3]).equal([1, 2, 3]));
    assert(([789]).orElse([1, 2, 3]).equal([789]));

    // Get orElse front of ranges
    assert((int[]).init.orElse(3) == 3);
    assert(([789]).orElse(3) == 789);

    // Lambdas
    assert(([789]).orElse!(() => 3) == 789);
    assert(([789]).orElse!(() => [1, 2, 3]).equal([789]));
}

///
@("works with strings")
unittest {
    import std.range;
    assert((cast(string)null).orElse("hi") == "hi");
    assert("yo".orElse("hi") == "yo");
}

@("range to mapped and mapped to range")
unittest {
    import std.algorithm: map;
    auto r0 = [1, 2].orElse([1, 2].map!"a * 2");
    assert(r0.equal([1, 2]));
    auto r1 = (int[]).init.orElse([1, 2].map!"a * 2");
    assert(r1.equal([2, 4]));

    auto r2 = [1, 2].map!"a * 2".orElse([1, 2]);
    assert(r2.equal([2, 4]));
    auto r3 = (int[]).init.map!"a * 2".orElse([1, 2]);
    assert(r3.equal([1, 2]));
}

@("range to front")
unittest {
    assert([1, 2].orElse(3) == 1);
    assert((int[]).init.orElse(3) == 3);
}
