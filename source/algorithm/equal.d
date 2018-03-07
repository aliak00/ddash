/**
    Tells you if two things are equal
*/
module algorithm.equal;

///
unittest {
    import std.algorithm.comparison: ee = equal;

    // single elements
    assert(!equal(2, 4));

    // unary predicate function applied to elements then compared
    assert( equal!(a => a % 2 == 0)(2, 4));
    assert( equal!q{a % 2 == 0}(2, 4));

    // binary predicate used to compare elements
    assert( equal!((a, b) => a != b)(2, 4));
    assert( equal!q{a != b}(2, 4));

    // compare ranges of ranges of different range types but same value types
    import std.algorithm: map, filter;
    auto r1 = [1, 2, 3].map!"a";
    auto r2 = [1, 2, 3].filter!"true";
    assert( equal([r1], [r2]));

    assert( equal([1, 2, 3], [1, 2, 3]));
    assert( equal([[1], [2], [3]], [[1], [2], [3]]));

    static assert(!__traits(compiles, equal!(a => a)(1, "hi")));
}

import std.algorithm.comparison: equal;

import common;

/**
    Compares two things together

    It can be customized with a unary or binary predicate. If a unary predicate is provided then it acts as
    a transformation that is applies to the elements being compare for equality. If a binary predicate is
    provided then that binary predicate is given the values and must return true or false.

    Params:
        pred = a nullary, unary, or binary predicate

    Returns:
        True if successful evaluation of predicates or values equal
*/
bool equal(alias pred = null, T, U)(auto ref T a, auto ref U b) {
    import bolts.traits: isNullType, isUnaryOver, isBinaryOver;
    static if (isNullType!pred)
    {
        import std.range: isInputRange;
        static if (isInputRange!T && isInputRange!U)
        {
            import std.range: ElementType;
            static if (isInputRange!(ElementType!T) && isInputRange!(ElementType!U))
            {
                import std.range: zip, walkLength;
                import std.algorithm: all;
                auto s1 = a.walkLength;
                auto s2 = b.walkLength;
                return s1 == s2
                    && a
                        .zip(b)
                        .all!(a => .equal(a[0], a[1]));
            }
            else
            {
                return .equal(a, b);
            }
        }
        else static if (is(typeof(a == b)))
        {
            return a == b;
        }
        else
        {
            static assert(0, "No equality operator for types " ~ T.stringof ~ " and " ~ U.stringof);
        }
    }
    else static if (isUnaryOver!(pred, T))
    {
        import std.traits: CommonType;
        static assert(
            !is(CommonType!(T, U) == void),
            "parameter types " ~ T.stringof ~ " and " ~ U.stringof ~ " are not compatible"
        );
        import std.functional: unaryFun;
        return equal(unaryFun!pred(a), unaryFun!pred(b));
    }
    else static if (isBinaryOver!(pred, T, U))
    {
        import std.functional: binaryFun;
        return binaryFun!pred(a, b);
    }
    else
    {
        static assert(
            false,
            "pred must be either nullary, unary, or binary."
        );
    }
}

unittest {
    assert(!equal(2, 4));
    assert( equal!(a => a % 2 == 0)(2, 4));
    assert( equal!((a, b) => a != b)(2, 4));
    assert( equal!q{a % 2 == 0}(2, 4));
    assert( equal!q{a != b}(2, 4));
    assert( equal([1, 2, 3], [1, 2, 3]));
    assert( equal([[1], [2], [3]], [[1], [2], [3]]));
    static assert(!__traits(compiles, equal!(a => a)(1, "hi")));
}

unittest {
    import algorithm.zip: zipEach;
    auto r1 = [[1, 4], [2, 5], [3, 6]];
    auto r2 = [[1, 2, 3], [4, 5, 6]].zipEach;
    assert(equal(r1, r2));
}
