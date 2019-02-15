/**
    Provides methods for accessing the back of a range
*/
module ddash.range.back;

///
@("module example")
unittest {
    import std.algorithm: filter;
    import std.range: iota, takeNone, array;
    import ddash.utils: some, none;
    auto evens = 10.iota.filter!"a % 2 == 0".array;
    assert(evens.withBack!"a" == some(8));
    assert(evens.takeNone.maybeBack == none);
    assert(evens.takeNone.backOr(100) == 100);
}

import ddash.common;

private enum isBidirectionalRangeAndElementConvertibleTo(Range, T) = from!"std.range".isBidirectionalRange!Range && is(T : from!"std.range".ElementType!Range);

/**
    Retrieves the back of a range or a default value

    Params:
        range = the range to get the back of
        defaultValue = the lazy var to return if the range has no back
        defaultFunc = function to call that returns a value if there is no back

    Since:
        - 0.0.1
*/
auto backOr(Range, T)(Range range, lazy T defaultValue) if (isBidirectionalRangeAndElementConvertibleTo!(Range, T)) {
    return range.backOr!defaultValue;
}

/// Ditto
auto backOr(alias defaultFunc, Range)(Range range) if (isBidirectionalRangeAndElementConvertibleTo!(Range, typeof(defaultFunc()))) {
    import std.range: empty, front;
    return range.empty ? defaultFunc() : range.back;
}

///
@("backOr example")
unittest {
    assert((int[]).init.backOr(7) == 7);
    assert([1, 2].backOr(3) == 2);
}

@("backOr with lambda")
unittest {
    assert((int[]).init.backOr!(() => 7) == 7);
    assert([1, 2].backOr!(() => 3) == 2);
}

/**
    Takes a unary function that is called on back of range if it is there

    Since:
        - 0.0.1
*/
auto withBack(alias fun, Range)(Range range) if (from!"std.range".isBidirectionalRange!Range) {
    import std.range: empty, back, ElementType;
    import std.functional: unaryFun;
    import ddash.utils.optional: some, no;

    alias f = unaryFun!fun;
    alias R = typeof(f(ElementType!Range.init));

    static if (is(R == void)){
        if (!range.empty) {
            f(range.front);
        }
    } else {
        return range.empty ? no!R : some(f(range.back));
    }
}

///
@("withBack example")
unittest {
    import ddash.utils.optional: some, none;
    assert((int[]).init.withBack!(a => a * a) == none);
    assert([3, 2].withBack!(a => a * a) == some(4));
    assert([3, 5].withBack!"a + 1" == some(6));
}

/**
    Returns an `Optional` of the back of range

    Since:
        - 0.0.1
*/
auto maybeBack(Range)(Range range) if (from!"std.range".isBidirectionalRange!Range) {
    import std.range: ElementType, empty, back;
    import ddash.utils.optional: no, some;
    return range.empty ? no!(ElementType!Range) : some!(ElementType!Range)(range.back);
}

///
@("maybeBack example")
unittest {
    assert((int[]).init.maybeBack.empty == true);
    assert([1, 2].maybeBack.front == 2);
}

@("maybeBack compiles with array of const")
unittest {
    const(string)[] args = [];
    static assert(__traits(compiles, { args.maybeBack; }));
}

///
@("maybeBack with optional.dispatch")
unittest {
    import std.algorithm: filter;
    import ddash.utils.optional: some, none, dispatch;
    struct A {
        int x;
        int f() {
            return x;
        }
    }

    assert((A[]).init.maybeBack.dispatch.f == none);
    assert([A(3), A(5)].maybeBack.dispatch.f == some(5));
}
