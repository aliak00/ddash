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

template isNullType(alias a) {
    enum isNullType = is(typeof(a) == typeof(null));
}

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
