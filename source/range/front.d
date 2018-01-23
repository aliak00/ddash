/// Provides acces to front of a range
module range.front;

import common: from;

/**
    Retrieves the front of a range or a default value
*/
auto front(Range, T)(Range range, lazy T defaultValue)
if (from!"std.range".isInputRange!Range && is(T : from!"std.range".ElementType!Range)) {
    import std.range: empty, front;
    return range.empty ? defaultValue : range.front;
}

///
unittest {
    assert((int[]).init.front(7) == 7);
    assert([1].front(3) == 1);
}

/**
    Takes a unary function that is called on front of range if it is there
*/
auto withFront(alias fun, Range)(Range range) if (from!"std.range".isInputRange!Range) {
    import std.range: empty, front, ElementType;
    alias R = typeof(fun(ElementType!Range.init));
    static if (is(R == void))
    {
        import optional: some;
        if (!range.empty) {
            some(fun(range.front));
        }
    }
    else
    {
        import optional: some, no;
        return range.empty ? no!R : some(fun(range.front));
    }
}

///
unittest {
    import optional: some, none;
    assert((int[]).init.withFront!(a => a * a) == none);
    assert([3].withFront!(a => a * a) == some(9));
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

    assert((A[]).init.maybeFront.f == none);
    assert([A(3), A(5)].maybeFront.f == some(3));
}

