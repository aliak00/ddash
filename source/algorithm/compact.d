module algorithm.compact;

import common: from;

auto compact(Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.algorithm: filter;
    import utils: isTruthy;
    return range
        .filter!isTruthy;
}

unittest {
    import std.array;
    import optional: no, some;
    assert([0, 1, 2, 0, 3].compact.array == [1, 2, 3]);
    assert([[1], [], [2]].compact.array == [[1], [2]]);
    assert([some(2), no!int].compact.array == [some(2)]);
}

auto compactBy(string member, Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.algorithm: filter;
    import std.range: ElementType;
    import utils: isTruthy;
    alias E = ElementType!Range;
    static assert(__traits(hasMember, E, member), E.stringof ~ " has no member " ~ member);
    static assert(
        __traits(getProtection, __traits(getMember, E, member)) == "public",
        E.stringof ~ "." ~ member ~ " is not public"
    );
    alias m = (a) => mixin("a." ~ member);
    return range
        .filter!(a => m(a).isTruthy);
}

unittest {
    import std.array;
    struct A {
        int x;
        private int y;
    }
    assert([A(3, 2), A(0, 1)].compactBy!"x".array == [A(3, 2)]);
    assert(__traits(compiles, [A(3, 2)].compactBy!"y") == false);
    assert(__traits(compiles, [A(3, 2)].compactBy!"z") == false);
}
