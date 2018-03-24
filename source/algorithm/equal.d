/**
    Tells you if two things are equal
*/
module algorithm.equal;

///
unittest {
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

///
unittest {
    struct S {
        int x;
        int y;
    }

    auto s1 = S(1, 2);
    auto s2 = S(2, 2);

    assert( equalBy!"y"(s1, s2));
    assert(!equalBy!"x"(s1, s2));

    auto r1 = [s2, s2];
    auto r2 = [s1, s1];

    assert( equalBy!"y"(r1, r2));
    assert(!equalBy!"x"(r1, r2));
}

private import std.algorithm.comparison: equal;

import common;

/**
    Compares two things together

    It can be customized with a unary or binary predicate. If a unary predicate is provided then it acts as
    a transformation that is applies to the elements being compare for equality. If a binary predicate is
    provided then that binary predicate is given the values and must return true or false.

    Params:
        pred = a nullary, unary, or binary predicate
        lhs = left hand side of ==
        rhs = right hand side of ==

    Returns:
        True if successful evaluation of predicates or values equal

    Since:
        0.1.0
*/
bool equal(alias pred = null, T, U)(auto ref T lhs, auto ref U rhs) {
    return equalBase!("", pred)(lhs, rhs);
}

/**
    Compares two things together by comparing a common publicly visible field of T and U.

    It can be customized with a unary or binary predicate. If a unary predicate is provided then it acts as
    a transformation that is applies to the elements being compare for equality. If a binary predicate is
    provided then that binary predicate is given the values and must return true or false.

    Params:
        member = which member in T and U to perform equlity on
        pred = a nullary, unary, or binary predicate
        lhs = left hand side of ==
        rhs = right hand side of ==

    Returns:
        True if successful evaluation of predicates or values equal

    Since:
        0.1.0
*/
bool equalBy(string member, alias pred = null, T, U)(auto ref T lhs, auto ref U rhs)
{
    return equalBase!(member, pred)(lhs, rhs);
}

private bool equalBase(string member, alias pred = null, T, U)(auto ref T lhs, auto ref U rhs) {
    import internal: valueBy;
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
                auto s1 = lhs.walkLength;
                auto s2 = rhs.walkLength;
                return s1 == s2
                    && lhs
                        .zip(rhs)
                        .all!(a => equalBase!(member, pred)(a[0], a[1]));
            }
            else
            {
                static if (member == "")
                    return .equal(lhs, rhs);
                else
                    return .equal!((l, r) => l.valueBy!member == r.valueBy!member)(lhs, rhs);
            }
        }
        else static if (is(typeof(lhs == rhs)))
        {
            return lhs.valueBy!member == rhs.valueBy!member;
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
        return equal(unaryFun!pred(lhs), unaryFun!pred(rhs));
    }
    else static if (isBinaryOver!(pred, T, U))
    {
        import std.functional: binaryFun;
        return binaryFun!pred(lhs, rhs);
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
