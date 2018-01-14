module utils.preds;

template isUnaryOver(alias pred, T...) {
    import std.functional: unaryFun;
    enum isUnaryOver = T.length == 1 && is(typeof(unaryFun!pred(T.init)));
}

template isBinaryOver(alias pred, T...) {
    import std.functional: binaryFun;
    static if (T.length == 1) {
        enum isBinaryOver = !isUnaryOver!(pred, T) && isBinaryOver!(pred, T, T);
    } else {
        enum isBinaryOver = is(typeof(binaryFun!pred(T[0].init, T[1].init)));
    }
}

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
