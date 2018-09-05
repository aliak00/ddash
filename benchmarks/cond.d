module benchmarks.cond;

void profile()() {
    import ddash.functional: cond;

    alias lessThanZero = (a) => a < 0;
    alias greaterOrEqualThan10 = (a) => a >= 10;
    alias identity = (a) => a;
    alias negate = (a) => -a;

    alias cond1 = cond!(
        a => a == 1, 42,
        2, a => a * 2,
        3, 999,
        lessThanZero, negate,
        greaterOrEqualThan10, identity,
        a => a * 100,
    );

    auto match2(int a) {
        alias eval1 = (b) => b == 1;
        alias mul2 = (b) => b * 2;
        alias mul100 = (b) => b * 100;
        if (eval1(a)) {
            return 42;
        } else if (a == 2) {
            return mul2(a);
        } else if (a == 3) {
            return 999;
        } else if (lessThanZero(a)) {
            return negate(a);
        } else if (greaterOrEqualThan10(a)) {
            return identity(a);
        } else {
            return mul100(a);
        }
    }
    auto match3(int a) {
        if (a == 1) {
            return 42;
        } else if (a == 2) {
            return a * 2;
        } else if (a == 3) {
            return 999;
        } else if (a < 0) {
            return -1;
        } else if (a >= 10) {
            return a;
        } else {
            return a * 100;
        }
    }

    import std.stdio;
    import std.datetime.stopwatch: benchmark;

    writeln("Benchmarking cond against hand written if/elses");
    auto r = benchmark!(f!match1, f!match2, f!match3)(5_000_000);
    writeln("  cond:          ", r[0]);
    writeln("  hand written 1: ", r[1]);
    writeln("  hand written 2: ", r[2]);
}

auto f(alias g)() {
    g(1);
    g(2);
    g(3);
    g(4);
    g(5);
    g(-3);
    g(11);
    return 0;
}
