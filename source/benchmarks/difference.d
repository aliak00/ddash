module benchmarks.difference;

import std.stdio;
import std.algorithm: sort;
import std.array;
import std.datetime.stopwatch: benchmark;
import std.random: uniform;
import std.range: generate, take, assumeSorted;

import algorithm: difference;

void diff(R1, R2)(R1 r1, R2 r2) {
    auto r = r1.difference(r2).array;
}

void profile() {
    static foreach (count; [4, 8, 16, 20, 50, 100, 1000]) {{
        alias randoms = generate!(() => uniform(0, count));

        auto sortableR1 = randoms.take(count).array;
        auto sortableR2 = randoms.take(count).array;

        auto sortedR1 = sortableR1.dup.sort.array.assumeSorted;
        auto sortedR2 = sortableR2.dup.sort.array.assumeSorted;

        auto unnsortableR1 = sortableR1.idup;
        auto unnsortableR2 = sortableR2.idup;

        alias fSorted = () => diff(sortedR1, sortedR2);
        alias fSortable = () => diff(sortableR1, sortableR2);
        alias fUnsortable = () => diff(unnsortableR1, unnsortableR2);

        auto r = benchmark!(fSorted, fSortable, fUnsortable)(5000);
        writeln("count: ", count);
        writeln("  sorted:     ", r[0]);
        writeln("  sortable:   ", r[1]);
        writeln("  unsortable: ", r[2]);
    }}
}
