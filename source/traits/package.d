module traits;

template isKeySubstitutableWith(A, B) {
    enum isKeySubstitutableWith = __traits(compiles, { int[A] aa; aa[B.init] = 0; });
}

unittest {
    struct A {}
    struct B { A a; alias a this; }

    static assert(isKeySubstitutableWith!(A, B));
    static assert(!isKeySubstitutableWith!(B, A));
    static assert(isKeySubstitutableWith!(int, long));
    static assert(!isKeySubstitutableWith!(int, float));
}
