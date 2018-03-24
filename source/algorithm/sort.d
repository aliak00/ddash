/**
    sorts stuff
*/
module algorithm.sort;

import common;

/**
    Sorts a range using the standard library sort by a publicly visible member variable or property of `ElemntType!Range`

    Since:
        0.1.0
*/
auto sortBy(string member, alias less = "a < b", Range)(Range range) {
    import std.algorithm: stdSort = sort;
    import std.functional: binaryFun;
    import internal: valueBy;
    return range.stdSort!((a, b) => binaryFun!less(valueBy!member(a), valueBy!member(b)));
}

///
unittest {
    struct A {
        int i;
    }
    auto a = [A(3), A(1), A(2)];
    assert(a.sortBy!"i".equal([A(1), A(2), A(3)]));
}
