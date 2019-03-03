/**
    Provides methods for accessing the front of a range
*/
module ddash.range.front;

///
@("module example")
unittest {
    import std.algorithm: filter;
    import std.range: iota, takeNone, drop;
    import ddash.utils.optional: some, none;
    auto evens = 10.iota.filter!"a % 2 == 0".drop(2);
    assert(evens.withFront!"a" == some(4));
    assert(evens.takeNone.maybeFront == none);
    assert(evens.takeNone.frontOr(100) == 100);
}

import ddash.common;

private enum isInputRangeAndElementConvertibleTo(Range, T) = from.std.range.isInputRange!Range && is(T : from.std.range.ElementType!Range);

/**
    Retrieves the front of a range or a default value

    Params:
        range = the range to get the front of
        defaultValue = the lazy var to return if the range has no front
        defaultFunc = function to call that returns a value if there is no front

    Since:
        - 0.0.1
*/
auto frontOr(Range, T)(Range range, lazy T defaultValue) if (isInputRangeAndElementConvertibleTo!(Range, T)) {
    return range.frontOr!defaultValue;
}

/// Ditto
auto frontOr(alias defaultFunc, Range)(Range range) if (isInputRangeAndElementConvertibleTo!(Range, typeof(defaultFunc()))) {
    import std.range: empty, front;
    return range.empty ? defaultFunc() : range.front;
}

///
@("frontOr example")
unittest {
    assert((int[]).init.frontOr(7) == 7);
    assert([1, 2].frontOr(3) == 1);
}

@("frontOr with lambda")
unittest {
    assert((int[]).init.frontOr!(() => 7) == 7);
    assert([1, 2].frontOr!(() => 3) == 1);
}

/**
    Takes a unary function that is called on front of range if it is there

    Since:
        - 0.0.1
*/
auto withFront(alias fun, Range)(Range range) if (from.std.range.isInputRange!Range) {
    import std.range: empty, front, ElementType;
    import std.functional: unaryFun;
    import ddash.utils.optional: some, no;

    alias f = unaryFun!fun;
    alias R = typeof(f(ElementType!Range.init));

    static if (is(R == void)) {
        if (!range.empty) {
            f(range.front);
        }
    } else {
        return range.empty ? no!R : some(f(range.front));
    }
}

///
@("withFront example")
unittest {
    import ddash.utils.optional: some, none;
    assert((int[]).init.withFront!(a => a * a) == none);
    assert([3, 2].withFront!(a => a * a) == some(9));
    assert([3, 2].withFront!"a + 1" == some(4));
}

/**
    Returns an `Optional` of the front of a range

    Since:
        - 0.0.1
*/
auto maybeFront(Range)(Range range) if (from.std.range.isInputRange!Range) {
    import std.range: ElementType, empty, front;
    import ddash.utils.optional: no, some;
    return range.empty ? no!(ElementType!Range) : some!(ElementType!Range)(range.front);
}

///
@("maybeFront example")
unittest {
    assert((int[]).init.maybeFront.empty == true);
    assert([1, 2].maybeFront.front == 1);
}

@("maybeFront compiles with array of const")
unittest {
    const(string)[] args = [];
    static assert(__traits(compiles, { args.maybeFront; }));
}

///
@("maybeFront with optional.dispatch")
unittest {
    import std.algorithm: filter;
    import ddash.utils.optional: some, none, dispatch;
    struct A {
        int x;
        int f() {
            return x;
        }
    }

    assert((A[]).init.maybeFront.dispatch.f == none);
    assert([A(3), A(5)].maybeFront.dispatch.f == some(3));
}
