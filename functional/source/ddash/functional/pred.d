/**
    Contains types that determine the semantics of predicates
*/
module ddash.functional.pred;

///
@("module example")
unittest {
    static struct S(alias pred) {
        auto f(int a, int b) {
            static if (isEq!pred) {
                return pred(a, b);
            } else static if (isLt!pred) {
                return !pred(a, b) && !pred(b, a);
            } else {
                import std.functional: binaryFun;
                return binaryFun!pred(a, b);
            }
        }
    }

    alias A = S!(eq!((a, b) => a == b));
    alias B = S!(lt!((a, b) => a < b));

    assert( A().f(1, 1));
    assert( B().f(1, 1));
    assert(!A().f(2, 1));
    assert(!B().f(2, 1));

    static bool feq(int a, int b) { return a == b; }
    static bool flt(int a, int b) { return a < b; }

    alias C = S!(eq!feq);
    alias D = S!(lt!flt);

    assert( C().f(1, 1));
    assert( D().f(1, 1));
    assert(!C().f(1, 2));
    assert(!D().f(1, 2));

    assert(S!"a == b"().f(1, 1));
}

/**
    Used to signify that `pred` is an equality predicate.

    It must be a function over two arguments that returns a boolean if they are equal
*/
struct eq(alias pred) {
    alias eq = pred;
    static auto ref opCall(T, U)(auto ref T a, auto ref U b) { return pred(a, b); }
}

/// Is true if `pred` is an `eq`
template isEq(alias pred) {
    static if (is(pred : eq!p, p...)) {
        enum isEq = true;
    } else {
        enum isEq = false;
    }
}

/**
    Used to signify that `pred` is a less than predicate

    It must be a function over two arguments that returns a boolean if arg1 < argb
*/
struct lt(alias pred) {
    alias lt = pred;
    static auto ref opCall(T, U)(auto ref T a, auto ref U b) { return pred(a, b); }
}

/// Is true if `pred` is an `lt`
template isLt(alias pred) {
    static if (is(pred : lt!p, p...)) {
        enum isLt = true;
    } else {
        enum isLt = false;
    }
}

@("traits correctly identity eq and lt")
unittest {
    alias plt = lt!((a, b) => a < b);
    alias peq = eq!((a, b) => a == b);

    static assert( isEq!peq);
    static assert(!isEq!plt);
    static assert( isLt!plt);
    static assert(!isLt!peq);

    assert( plt(1, 2));
    assert(!plt(1, 1));
    assert(!plt(2, 1));

    assert(!peq(2, 1));
    assert(!peq(1, 2));
    assert( peq(1, 1));
}
