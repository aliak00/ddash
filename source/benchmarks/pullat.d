module benchmarks.pullat;

void profile()() {
    import algorithm: pullAt;

    import std.stdio;
    import std.datetime.stopwatch: benchmark;
    import std.range: iota, generate, take, enumerate;
    import std.meta: AliasSeq, aliasSeqOf;
    import std.algorithm: sort, canFind, filter, map;
    import std.random: uniform;
    import std.array;

    enum count = 20;

    alias randoms = generate!(() => uniform(0, count));

    auto numbers = randoms.take(count);

    alias SingleIndices = aliasSeqOf!((count / 2).iota);
    auto indices = randoms.take(count / 2).array;
    auto sortedIndices = indices.array.sort;

    writeln("Benchmarking pullAt against filter/canFind:");
    writeln("  numbers: ", numbers);
    writeln("  indices: ", indices);

    alias stdExclude = (numbers, indicies) => numbers.array.sort.enumerate.filter!(a => !indicies.canFind(a[0])).map!(a => a[1]);
    alias stdExcludeSorted = (numbers, indicies) => numbers.enumerate.filter!(a => !indicies.contains(a[0])).map!(a => a[1]);
    auto r1 = benchmark!(
        () => numbers.pullAt(SingleIndices),
        () => numbers.pullAt(indices),
        () => numbers.pullAt(sortedIndices),
        () => stdExclude(numbers, indices),
        () => stdExcludeSorted(numbers, sortedIndices),
    )(10000);

    writeln("pullAt: ");
    writeln("  single args:    ", r1[0]);
    writeln("  single range:   ", r1[1]);
    writeln("  sorted range:   ", r1[2]);
    writeln("  canFind range:  ", r1[3]);
    writeln("  canFind sorted: ", r1[4]);

    auto r2 = benchmark!(
        () => numbers.pullAt(SingleIndices).array,
        () => numbers.pullAt(indices).array,
        () => numbers.pullAt(sortedIndices).array,
        () => stdExclude(numbers, indices).array,
        () => stdExcludeSorted(numbers, sortedIndices).array,
    )(10000);

    writeln("pullAt (with .array): ");
    writeln("  single args:    ", r2[0]);
    writeln("  single range:   ", r2[1]);
    writeln("  sorted range:   ", r2[2]);
    writeln("  canFind range:  ", r2[3]);
    writeln("  canFind sorted: ", r2[4]);
}
