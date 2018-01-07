module range.iffront;

import std.range: isInputRange;

auto ifFront(Range)(Range range) if (isInputRange!Range) {
    import std.range: ElementType, empty, front;
    import optional: no, some;
    return range.empty ? no!(ElementType!Range) : some(range.front);
}

unittest {
    import std.algorithm: filter;
    assert([false].filter!"a".ifFront.empty);
}

unittest {
    import std.algorithm: filter;
    import optional: some, none;
    struct A {
        int f() {
            return 7;
        }
    }

    assert((A[]).init.ifFront.f == none);
    assert([A()].ifFront.f == some(7));
}
