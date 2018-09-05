module ddash.common.valueby;

auto ref valueBy(string member = "", T)(auto ref T value) {
    static if (member != "") {
        import bolts: hasMember;
        static assert(
            hasMember!(T, member).withProtection!"public",
            "Member " ~ name ~ " for type " ~ T.stringof ~ " not publicly accessible"
        );
        return mixin("value." ~ member);
    } else {
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
