module ddash.common.valueby;

package(ddash) auto ref valueBy(string memberName = "", T)(auto ref T value) {
    static if (memberName != "") {
        import bolts: member;
        static assert(
            member!(T, memberName).protection == "public",
            "Member " ~ memberName ~ " for type " ~ T.stringof ~ " not publicly accessible"
        );
        return mixin("value." ~ memberName);
    } else {
        return value;
    }
}

@("Returns correct by-member value")
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
