module range.ifback;

import common: from;

auto ifBack(Range)(Range range) if (from!"std.range".isBidirectionalRange!Range) {
    import std.range: ElementType, empty, back;
    import optional: no, some;
    return range.empty ? no!(ElementType!Range) : some(range.back);
}

unittest {
    assert((int[]).init.ifBack.empty == true);
    assert([1, 2].ifBack.front == 2);
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

    assert((A[]).init.ifBack.f == none);
    assert([A(3), A(5)].ifBack.f == some(5));
}
