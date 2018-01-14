import std.stdio;
import std.functional, std.algorithm, std.range, std.array;

auto f(alias pred)() {
    return is(typeof(pred) == typeof(null));
}
void main() {
    int a;
    int *b;
    pragma(msg, f!(a => a));

    struct A {
        int x = 0;
    }

    [A(1), A(2), A(3)].map!"a.x".array.writeln;
}
