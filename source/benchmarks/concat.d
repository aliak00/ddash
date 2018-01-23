module benchmarks.concat;

import std.stdio;
import std.datetime.stopwatch: benchmark;

import algorithm.concat;

void profile()() {
    auto r1 = benchmark!(
        () => concat(1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
        () => concatAny(1, 2, 3, 4, 6, 7, 8, 9, 10)
    )(5000);

    writeln("concat singles:");
    writeln("  vanilla:  ", r1[0]);
    writeln("  any:      ", r1[1]);

    auto r2 = benchmark!(
        () => concat([1, 2], [3, 4, 5], [6, 7, 8, 9, 10]),
        () => concatAny([1, 2], [3, 4, 6], [7, 8, 9, 10])
    )(5000);

    writeln("concat ranges:");
    writeln("  vanilla:  ", r2[0]);
    writeln("  any:      ", r2[1]);

    auto r3 = benchmark!(
        () => concat(1, 2, [3, 4, 5], [6, 7, 8, 9, 10]),
        () => concatAny(1, 2, [3, 4, 6], [7, 8, 9, 10])
    )(5000);

    writeln("concat mixed:");
    writeln("  vanilla:  ", r3[0]);
    writeln("  any:      ", r3[1]);
}
