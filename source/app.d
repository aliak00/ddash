import std.stdio;
import std.typecons;
import std.algorithm;
import std.functional;

import algorithm;

void f(alias fun = "a")() {
    static if (is(typeof(unaryFun!fun(3))))
    {
        unaryFun!fun(3);
    }
    else
    {
        unaryFun!fun(3, 2);
    }
}

void a(int a) {
    writeln(a);
}

void b(int a, int b) {
    writeln(a, b);
}

void main() {
    struct A {
        int value;
    }
    A(3).hashOf.writeln;


    f!a;
}
