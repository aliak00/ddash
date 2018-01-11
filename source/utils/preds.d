module utils.preds;

import std.traits;
import std.functional;

template isUnary(alias pred) {
    static if (is(typeof(pred) : string))
    {
        enum isUnary = is(typeof(unaryFun!pred(0)));
    }
    else static if (is(Parameters!pred F) && F.length == 1)
    {
        enum isUnary = true;
    }
    else
    {
        enum isUnary = false;
    }
}

template isBinary(alias pred) {
    static if (is(typeof(pred) : string))
    {
        enum isBinary = !isUnary!pred && is(typeof(binaryFun!pred(0, 0)));
    }
    else static if (is(Parameters!pred F) && F.length == 2)
    {
        enum isBinary = true;
    }
    else
    {
        enum isBinary = false;
    }
}

bool isNAry(alias pred, int arity)() {
    static if (is(Parameters!pred F) && F.length == arity)
    {
        return true;
    }
    else
    {
        return false;
    }
}

unittest {
    int v;
    void f0() {}
    void f1(int a) {}
    void f2(int a, int b) {}

    static assert(isUnary!"a" == true);
    static assert(isUnary!"a > a" == true);
    static assert(isUnary!"a > b" == false);

    static assert(isUnary!v == false);
    static assert(isUnary!f0 == false);
    static assert(isUnary!f1 == true);
    static assert(isUnary!f2 == false);

    static assert(isBinary!"a" == false);
    static assert(isBinary!"a > a" == false);
    static assert(isBinary!"a > b" == true);

    static assert(isBinary!v == false);
    static assert(isBinary!f0 == false);
    static assert(isBinary!f1 == false);
    static assert(isBinary!f2 == true);

    static assert(isNAry!(f0, 0) == true);
    static assert(isNAry!(f0, 1) == false);
    static assert(isNAry!(f1, 0) == false);
    static assert(isNAry!(f1, 1) == true);
    static assert(isNAry!(f2, 1) == false);
    static assert(isNAry!(f2, 2) == true);
}
