/**
    Removes elements from a range
*/
module algorithm.pull;

///
unittest {
    int[] arr = [1, 2, 3, 4, 5];
    arr.pull(1, [2, 5]);
    assert(arr == [3, 4]);

    import std.math: ceil;
    double[] farr = [2.1, 1.2];
    assert(farr.pull!ceil([2.3, 3.4]) == [1.2]);

    farr = [2.1, 1.2];
    assert(farr.pull!((a, b) => ceil(a) == ceil(b))([2.3, 3.4]) == [1.2]);

    arr = [1, 2, 3, 4, 5];
    assert(arr.pull!"a == b"(3, 5) == [1, 2, 4]);
}

///
unittest {
    struct A {
        int x;
        int y;
    }

    auto arr = [A(1, 2), A(3, 4), A(5, 6)];
    assert(arr.pullBy!"y"(2, 6) == [A(3, 4)]);
}

import common;

/**
    Removes elements from a range.

    Params:
        range = a mutable range
        values = variables args of ranges and values to pull out
        pred = a unary transoform predicate or binary equality predicate. Defaults to `==`.

    Returns:
        Modified range
*/
ref pull(alias pred = null, Range, Values...)(return ref Range range, Values values)
if (from!"std.range".isInputRange!Range)
{
    return range.pullBase!("", pred)(values);
}

/**
    Removes elements from a range by a publicly visible member variable or property of `ElemntType!Range`

    Params:
        range = a mutable range
        values = variables args of ranges and values to pull out
        member = which member in `ElementType!Range` to pull by
        pred = a unary transform predicate or binary equality predicate. Defaults to `==`.

    Returns:
        Modified range
*/
ref pullBy(string member, alias pred = null, Range, Values...)(return ref Range range, Values values)
if (from!"std.range".isInputRange!Range && member.length)
{
    return range.pullBase!(member, pred)(values);
}

ref pullBase(string member, alias pred, Range, Values...)(return ref Range range, Values values) {
    import std.algorithm: canFind, remove;
    import algorithm: concat;
    import internal: equalityComparator, valueBy;
    alias equal = (a, b) => equalityComparator!pred(a, b);
    auto unwanted = concat(values);
    static if (member == "")
    {
        alias f = (a) => a;
    }
    else
    {
        alias f = (a) => a.valueBy!member;
    }
    range = range.remove!(a => unwanted.canFind!equal(f(a)));
    return range;
}
