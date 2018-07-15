/**
    Provides methods for accessing the front of a range
*/
module ddash.range.front;

///
unittest {
    import std.algorithm: filter;
    import std.range: iota, takeNone, drop;
    import optional: some, none;
    auto evens = 10.iota.filter!"a % 2 == 0".drop(2);
    assert(evens.withFront!"a" == some(4));
    assert(evens.takeNone.maybeFront == none);
    assert(evens.takeNone.frontOr(100) == 100);
}

import ddash.range.internal.common;

/**
    Retrieves the front of a range or a default value
*/
auto frontOr(Range, T)(Range range, lazy T defaultValue)
if (from!"std.range".isInputRange!Range && is(T : from!"std.range".ElementType!Range)) {
    import std.range: empty, front;
    return range.empty ? defaultValue : range.front;
}

///
unittest {
    assert((int[]).init.frontOr(7) == 7);
    assert([1, 2].frontOr(3) == 1);
}

/**
    Takes a unary function that is called on front of range if it is there
*/
auto withFront(alias fun, Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.range: empty, front, ElementType;
    import std.functional: unaryFun;
    alias f = unaryFun!fun;
    alias R = typeof(f(ElementType!Range.init));
    static if (is(R == void))
    {
        import optional: some;
        if (!range.empty) {
            some(f(range.front));
        }
    }
    else
    {
        import optional: some, no;
        return range.empty ? no!R : some(f(range.front));
    }
}

///
unittest {
    import optional: some, none;
    assert((int[]).init.withFront!(a => a * a) == none);
    assert([3, 2].withFront!(a => a * a) == some(9));
    assert([3, 2].withFront!"a + 1" == some(4));
}

/**
    Returns an `Optional` of the front of a range
*/
auto maybeFront(Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.range: ElementType, empty, front;
    import optional: no, some;
    return range.empty ? no!(ElementType!Range) : some(range.front);
}

///
unittest {
    assert((int[]).init.maybeFront.empty == true);
    assert([1, 2].maybeFront.front == 1);
}

///
unittest {
    import std.algorithm: filter;
    import optional: some, none;
    struct A {
        int x;
        int f() {
            return x;
        }
    }

    assert((A[]).init.maybeFront.dispatch.f == none);
    assert([A(3), A(5)].maybeFront.dispatch.f == some(3));
}
