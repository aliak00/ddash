module internal;

import common;

mixin template propogateInfiniteRange(Range, alias emptyPred) if (from!"std.range".isInputRange!Range) {
    import std.range: isInfinite;
    static if (isInfinite!R)
    {
        enum bool empty = false;
    }
    else
    {
        @property bool empty()
        {
            return emptyPred(this);
        }
    }
}

unittest {
    import std.range: sequence, isInfinite;
    import std.array;
    struct A(R) {
        R src;
        void popFront() { src.popFront(); }
        auto front() { return src.front; }
        mixin propogateInfiniteRange!(R, (self) => self.src.empty);
    }
    auto arr = [1, 2, 3];
    auto ints = sequence!((a, n) => n);
    auto a = A!(typeof(arr))(arr);
    auto b = A!(typeof(ints))(ints);
    static assert(isInfinite!(typeof(a)) == false);
    static assert(isInfinite!(typeof(b)) == true);
}

auto ref valueBy(string member = "", T)(auto ref T value) {
    static if (member != "")
    {
        static assert(__traits(hasMember, T, member), T.stringof ~ " has no member " ~ member);
        static assert(
            __traits(getProtection, __traits(getMember, T, member)) == "public",
            T.stringof ~ "." ~ member ~ " is not public"
        );
        return mixin("value." ~ member);
    }
    else
    {
        return value;
    }
}

unittest {
    struct A {
        int x = 3;
        private int y = 7;
    }

    A a;
    assert(a.valueBy!("x") == 3);
    assert(a.valueBy == a);
    assert(!__traits(compiles, a.valueBy!"y"));
    assert(!__traits(compiles, a.valueBy!"z"));
}

auto ref equalityComparator(alias pred = null, T, U)(auto ref T a, auto ref U b) {
    import utils.traits: isNullType, isUnaryOver;
    static if (isNullType!pred)
    {
        import std.range: isInputRange;
        static if (isInputRange!T && isInputRange!U)
        {
            import std.algorithm: equal;
            return equal(a, b);
        }
        else
        {
            return a == b;
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
        return unaryFun!pred(a) == unaryFun!pred(b);
    }
    else
    {
        import std.functional: binaryFun;
        return binaryFun!pred(a, b);
    }
}

unittest {
    assert(!equalityComparator(2, 4));
    assert( equalityComparator!(a => a % 2 == 0)(2, 4));
    assert( equalityComparator!((a, b) => a != b)(2, 4));
    assert( equalityComparator!q{a % 2 == 0}(2, 4));
    assert( equalityComparator!q{a != b}(2, 4));
    static assert(!__traits(compiles, equalityComparator!(a => a)(1, "hi")));
}
