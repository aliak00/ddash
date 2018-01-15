module range.maybefront;

import common: from;

auto maybeFront(Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.range: ElementType, empty, front;
    import optional: no, some;
    return range.empty ? no!(ElementType!Range) : some(range.front);
}

unittest {
    assert((int[]).init.maybeFront.empty == true);
    assert([1, 2].maybeFront.front == 1);
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

    assert((A[]).init.maybeFront.f == none);
    assert([A(3), A(5)].maybeFront.f == some(3));
}
