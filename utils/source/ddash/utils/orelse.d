/**
    Gets the value or else something else
*/
module ddash.utils.orelse;

import ddash.common;

/**
    Retrieves the value if it is a valid value else it will retrieve the else value

    Since:
        - 0.0.2
*/
auto ref T orElse(T)(auto ref T val, lazy T elseValue) if (from!"bolts.traits".isNullable!T) {
    if (val is null) {
        return elseValue;
    }
    return val;
}

/// Ditto
auto orElse(R, U)(auto ref R range, lazy U elseValue)
if (from!"std.range".isInputRange!R && from!"std.range".isInputRange!U && !is(R == U)) {
    import std.range: choose;
    return choose(range.empty, elseValue, range);
}

///
unittest {
    assert((int[]).init.orElse([1, 2, 3]).equal([1, 2, 3]));
    assert(([789]).orElse([1, 2, 3]).equal([789]));
}

///
unittest {
    assert((cast(string)null).orElse("hi") == "hi");
    assert("yo".orElse("hi") == "yo");
}

unittest {
    import std.algorithm: map;
    auto r0 = [1, 2].orElse([1, 2].map!"a * 2");
    assert(r0.equal([1, 2]));
    auto r1 = (int[]).init.orElse([1, 2].map!"a * 2");
    assert(r1.equal([2, 4]));
}
