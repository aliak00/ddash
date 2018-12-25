/**
    Creates a slice out of arbitrary data
*/
module ddash.utils.slice;

import ddash.common;

/**
    Turns an object in to a slice. This function will not just work on arrays and ranges,
    but also on PODs by converting them in to a single element slice.

    Params:
        value = the value to convert to a slice
        range = the range to convert to a slice

    Since:
        - 0.0.5
*/
auto ref slice(T)(auto ref T value) if (!from!"std.traits".isArray!T && __traits(isPOD, T)) {
    return (&value)[0 .. 1];
}
/// Ditto
auto ref slice(R)(auto ref R range) if (from!"std.range".hasSlicing!R) {
    return range[];
}

///
@("slices ranges and value type")
unittest {
    struct S {
        int data;
    }

    auto a = S(4);
    auto b = [1, 2];

    ubyte[] takeme(void[] v) {
        return cast(ubyte[])v;
    }

    assert(takeme(a.slice) == [4, 0, 0, 0]);
    assert(takeme(b.slice) == [1, 0, 0, 0, 2, 0, 0, 0]);
}
