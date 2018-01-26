/**
    Provides a number of helper traits that are used for meta programming purposes
*/
module utils.traits;

import common: from;

/// Trus if B can be used as an associated array key in place of A.
template isKeySubstitutableWith(A, B) {
    enum isKeySubstitutableWith = __traits(compiles, { int[A] aa; aa[B.init] = 0; });
}

///
unittest {
    struct A {}
    struct B { A a; alias a this; }

    static assert(isKeySubstitutableWith!(A, B));
    static assert(!isKeySubstitutableWith!(B, A));
    static assert(isKeySubstitutableWith!(int, long));
    static assert(!isKeySubstitutableWith!(int, float));
}

/// Trus if a is of type null
template isNullType(alias a) {
    enum isNullType = is(typeof(a) == typeof(null));
}

///
unittest {
    int a;
    int *b = null;
    struct C {}
    C c;
    void f() {}
    static assert(isNullType!null);
    static assert(isNullType!a == false);
    static assert(isNullType!b == false);
    static assert(isNullType!c == false);
    static assert(isNullType!f == false);
}

/// Trus if pred is a unary function over T
template isUnaryOver(alias pred, T...) {
    import std.functional: unaryFun;
    enum isUnaryOver = T.length == 1 && is(typeof(unaryFun!pred(T.init)));
}

///
unittest {
    int v;
    void f0() {}
    void f1(int a) {}
    void f2(int a, int b) {}

    static assert(isUnaryOver!("a", int) == true);
    static assert(isUnaryOver!("a > a", int) == true);
    static assert(isUnaryOver!("a > b", int) == false);
    static assert(isUnaryOver!(null, int) == false);
    static assert(isUnaryOver!((a => a), int) == true);
    static assert(isUnaryOver!((a, b) => a + b, int) == false);

    static assert(isUnaryOver!(v, int) == false);
    static assert(isUnaryOver!(f0, int) == false);
    static assert(isUnaryOver!(f1, int) == true);
    static assert(isUnaryOver!(f2, int) == false);

    import std.math: ceil;
    static assert(isUnaryOver!(ceil, double) == true);
}

/// True if pred is a binary function of (T, U) or (T, T)
template isBinaryOver(alias pred, T...) {
    import std.functional: binaryFun;
    static if (T.length == 1) {
        enum isBinaryOver = !isUnaryOver!(pred, T) && isBinaryOver!(pred, T, T);
    } else {
        enum isBinaryOver = is(typeof(binaryFun!pred(T[0].init, T[1].init)));
    }
}

///
unittest {
    int v;
    void f0() {}
    void f1(int a) {}
    void f2(int a, int b) {}

    static assert(isBinaryOver!("a", int) == false);
    static assert(isBinaryOver!("a > a", int) == false);
    static assert(isBinaryOver!("a > b", int) == true);
    static assert(isBinaryOver!(null, int) == false);
    static assert(isBinaryOver!((a => a), int) == false);
    static assert(isBinaryOver!((a, b) => a + b, int) == true);

    static assert(isBinaryOver!(v, int) == false);
    static assert(isBinaryOver!(f0, int) == false);
    static assert(isBinaryOver!(f1, int) == false);
    static assert(isBinaryOver!(f2, int) == true);
}

/// Trus if T is a SortedRange
bool isSortedRange(R)() {
    import std.range: SortedRange;
    return is(R : SortedRange!U, U...);
}

///
unittest {
    import std.algorithm: sort;
    import std.range: assumeSorted;
    static assert(isSortedRange!(typeof([0, 1, 2])) == false);
    static assert(isSortedRange!(typeof([0, 1, 2].sort)) == true);
    static assert(isSortedRange!(typeof([0, 1, 2].assumeSorted)) == true);
}

/// Returns a list of member functions of T
template MemberFunctions(T) {
    import std.traits: isFunction;
    auto MemberFunctions() {
        string[] memberFunctions;
        foreach (member; __traits(allMembers, T)) {
            static if (is(typeof(mixin("T." ~ member)) F))
                if (isFunction!F) {
                    memberFunctions ~= member;
                }
        }
        return memberFunctions;
    }
}

///
unittest {
    struct A {
        void opCall() {}
        void g() {}
    }

    struct B {
        int m;
        A a;
        alias a this;
        void f() {}
    }

    static assert(MemberFunctions!B == ["f"]);
}

/// Finds the CommonType of a list of ranges
template CommonTypeOfRanges(Rs...) if (from!"std.meta".allSatisfy!(from!"std.range".isInputRange, Rs)) {
    import std.traits: CommonType;
    import std.meta: staticMap;
    import std.range: ElementType;
    alias CommonTypeOfRanges = CommonType!(staticMap!(ElementType, Rs));
}

///
unittest {
    auto a = [1, 2];
    auto b = [1.0, 2.0];
    static assert(is(CommonTypeOfRanges!(typeof(a), typeof(b)) == double));
}
