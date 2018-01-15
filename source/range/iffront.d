module range.iffront;

import common: from;

auto ifFront(Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.range: ElementType, empty, front;
    import optional: no, some;
    return range.empty ? no!(ElementType!Range) : some(range.front);
}

unittest {
    assert((int[]).init.ifFront.empty == true);
    assert([1, 2].ifFront.front == 1);
}

unittest {
    import std.algorithm: filter;
    import optional: some, none;
    struct A {
        int x;
        int f() {
            return x;
        }
    }

    assert((A[]).init.ifFront.f == none);
    assert([A(3), A(5)].ifFront.f == some(3));
}
