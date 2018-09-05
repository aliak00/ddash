/**
    Tells you if two things are equal
*/
module ddash.algorithm.equal;

///
unittest {
    // single elements
    assert(!equal(2, 4));

    // unary predicate function applied to elements then compared
    assert( equal!(a => a % 2 == 0)(2, 4));
    assert( equal!q{a % 2 == 0}(2, 4));

    // binary predicate used to compare elements
    assert(!equal!((a, b) => a == b)(2, 4));
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


import eqmod = ddash.common.equal;

/**
    Compares two things together

    It can be customized with a unary or binary predicate. If a unary predicate is provided then it acts as
    a transformation that is applied to the elements being compared for equality. If a binary predicate is
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
alias equal = eqmod.equal;

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
alias equalBy = eqmod.equalBy;
