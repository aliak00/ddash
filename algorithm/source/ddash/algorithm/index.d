/// Returns an `optional` index of an element.
module ddash.algorithm.index;

///
@("Module example")
unittest {
    import ddash.utils.optional: some, none;

    auto arr1 = [1, 2, 3, 4];

    assert(arr1.indexWhere!(a => a % 2 == 0) == some(1));
    assert(arr1.lastIndexWhere!(a => a % 2 == 0) == some(3));

    assert(arr1.indexWhere!(a => a == 5) == none);
    assert(arr1.lastIndexWhere!(a => a % 2 == 0)(2) == some(1));

    auto arr2 = [1, 2, 1, 2];

    assert(arr2.indexOf(2) == some(1));
}


import ddash.common;

/**
    Returns `optional` index of the first element predicate returns true for.

    Params:
        pred = unary function that returns true for some element
        range = the input range to search
        fromIndex = which index to start searching from

    Returns:
        `some!size_t` or `none` if no element was found

    Since:
        0.0.1
*/
auto indexWhere(alias pred, Range)(Range range, size_t fromIndex = 0)
if (from.std.range.isInputRange!Range
    && from.bolts.traits.isUnaryOver!(pred, from.std.range.ElementType!Range))
{
    import std.range: drop;
    import std.functional: unaryFun;
    import ddash.algorithm.internal: countUntil;
    auto r = range.drop(fromIndex);
    return r.countUntil!((a, b) => unaryFun!pred(a))(r) + fromIndex;
}

///
@("indexWhere example")
unittest {
    import ddash.utils.optional: some, none;
    assert([1, 2, 3, 4].indexWhere!(a => a % 2 == 0) == some(1));
    assert([1, 2, 3, 4].indexWhere!(a => a == 5) == none);
    assert([1, 2, 3, 4].indexWhere!(a => a % 2 == 0)(2) == some(3));
}

/**
    Returns `optional` index of the last element predicate returns true for.

    Params:
        pred = unary function that returns true for some element
        range = the input range to search
        fromIndex = which index from the end to start searching from

    Returns:
        `some!size_t` or `none` if no element was found

    Since:
        0.0.1
*/
auto lastIndexWhere(alias pred, Range)(Range range, size_t fromIndex = 0)
if (from.std.range.isBidirectionalRange!Range
    && from.bolts.traits.isUnaryOver!(pred, from.std.range.ElementType!Range))
{
    import std.range: retro, walkLength;
    import ddash.range: withFront;
    return range
        .retro
        .indexWhere!pred(fromIndex)
        .withFront!(a => range.walkLength - a - 1);
}

///
@("lastIndexWhere example")
unittest {
    import ddash.utils.optional: some, none;
    assert([1, 2, 3, 4].lastIndexWhere!(a => a % 2 == 0) == some(3));
    assert([1, 2, 3, 4].lastIndexWhere!(a => a == 5) == none);
    assert([1, 2, 3, 4].lastIndexWhere!(a => a % 2 == 0)(2) == some(1));
}

/**
    Finds the first element in a range that equals some value

    Params:
        range = an input range
        value = value to search for
        fromIndex = which index to start searching from

    Returns:
        An `Optional!T`

    Since:
        0.0.1
*/
auto indexOf(Range, T)(Range range, T value, size_t fromIndex = 0) if (from.std.range.isInputRange!Range) {
    import std.range: drop;
    import ddash.algorithm.internal: countUntil;
    import ddash.range: withFront;
    return range
        .drop(fromIndex)
        .countUntil(value)
        .withFront!(a => a + fromIndex);
}

///
@("indexOf example")
unittest {
    import ddash.utils: some, none;
    assert([1, 2, 1, 2].indexOf(2) == some(1));
    assert([1, 2, 1, 2].indexOf(2, 2) == some(3));
    assert([1, 2, 1, 2].indexOf(3) == none);
}

/**
    Finds the first element in a range that equals some value

    Params:
        range = an input range
        value = value to search for
        fromIndex = which index from the end to start searching from

    Returns:
        An `optional!T`

    Since:
        0.0.1
*/
auto lastIndexOf(Range, T)(Range range, T value, size_t fromIndex = 0) if (from.std.range.isBidirectionalRange!Range) {
    import std.range: retro, walkLength;
    import ddash.algorithm: indexOf;
    import ddash.range: withFront;
    return range
        .retro
        .indexOf(value, fromIndex)
        .withFront!(a => range.walkLength - a - 1);
}

///
@("lastIndexOf example")
unittest {
    import ddash.utils: some, none;
    assert([1, 2, 1, 2].indexOf(2) == some(1));
    assert([1, 2, 1, 2].indexOf(2, 2) == some(3));
    assert([1, 2, 1, 2].indexOf(3) == none);
}
