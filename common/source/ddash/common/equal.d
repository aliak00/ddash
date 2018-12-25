module ddash.common.equal;

private import std.algorithm.comparison: equal;

import ddash.common;

bool equal(alias pred = null, T, U)(auto ref T lhs, auto ref U rhs)
{
    return equalBase!("", pred)(lhs, rhs);
}

bool equalBy(string member, alias pred = null, T, U)(auto ref T lhs, auto ref U rhs)
{
    return equalBase!(member, pred)(lhs, rhs);
}

private bool equalBase(string member, alias pred = null, T, U)(auto ref T lhs, auto ref U rhs) {
    import ddash.common.valueby;
    import bolts.traits: isNullType, isUnaryOver, isBinaryOver;

    static if (isNullType!pred) {
        import std.range: isInputRange;

        static if (isInputRange!T && isInputRange!U) {
            import std.range: ElementType;

            static if (isInputRange!(ElementType!T) && isInputRange!(ElementType!U)) {
                import std.range: zip, walkLength;
                import std.algorithm: all;

                auto s1 = lhs.walkLength;
                auto s2 = rhs.walkLength;

                return s1 == s2
                    && lhs
                        .zip(rhs)
                        .all!(a => equalBase!(member, pred)(a[0], a[1]));

            } else {
                static if (member == "")
                    return .equal(lhs, rhs);
                else
                    return .equal!((l, r) => l.valueBy!member == r.valueBy!member)(lhs, rhs);
            }
        } else static if (is(typeof(lhs == rhs))) {
            return lhs.valueBy!member == rhs.valueBy!member;
        } else {
            static assert(0, "No equality operator for types " ~ T.stringof ~ " and " ~ U.stringof);
        }
    } else static if (isUnaryOver!(pred, T)) {
        import std.traits: CommonType;

        static assert(
            !is(CommonType!(T, U) == void),
            "parameter types " ~ T.stringof ~ " and " ~ U.stringof ~ " are not compatible"
        );

        import std.functional: unaryFun;

        return equal(unaryFun!pred(lhs), unaryFun!pred(rhs));
    } else static if (isBinaryOver!(pred, T, U)) {
        import std.functional: binaryFun;
        import ddash.functional.pred: isLt;

        static if (isLt!pred) {
            return !binaryFun!pred(lhs, rhs) && !binaryFun!pred(rhs, lhs);
        } else {
            return binaryFun!pred(lhs, rhs);
        }
    } else {
        static assert(
            false,
            "pred must be either nullary, unary, or binary."
        );
    }
}

@("Works in general")
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
