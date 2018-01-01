module range.iffront;

import std.range: isInputRange;

auto iffront(Range)(Range r) if (isInputRange!Range) {
    import std.range: ElementType, empty, front;
    import optional: no, some;
    return r.empty ? no!(ElementType!Range) : some(r.front);
}

unittest {
    import std.algorithm: filter;
    assert([false].filter!"a".iffront.empty);
}

unittest {
    import std.algorithm: filter;
    import optional: some, none;
    struct A {
        int f() {
            return 7;
        }
    }

    assert((A[]).init.iffront.f == none);
    assert([A()].iffront.f == some(7));
}
