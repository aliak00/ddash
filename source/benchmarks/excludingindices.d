module benchmarks.excludingindices;

void profile()() {
    import algorithm: excludingIndices;

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
    auto indices = randoms.take(count / 2);
    auto sortedIndices = indices.array.sort;

    writeln("Benchmarking excludingIndices against filter/canFind:");
    writeln("  numbers: ", numbers);
    writeln("  indices: ", indices);

    alias stdExclude = (numbers, indicies) => numbers.enumerate.filter!(a => !indicies.canFind(a[0])).map!(a => a[1]);
    alias stdExcludeSorted = (numbers, indicies) => numbers.enumerate.filter!(a => !indicies.contains(a[0])).map!(a => a[1]);
    auto r1 = benchmark!(
        () => numbers.excludingIndices(SingleIndices),
        () => numbers.excludingIndices(indices),
        () => numbers.excludingIndices(sortedIndices),
        () => stdExclude(numbers, indices),
        () => stdExcludeSorted(numbers, sortedIndices),
    )(10000);

    writeln("excludingIndices: ");
    writeln("  single args:    ", r1[0]);
    writeln("  single range:   ", r1[1]);
    writeln("  sorted range:   ", r1[2]);
    writeln("  canFind range:  ", r1[3]);
    writeln("  canFind sorted: ", r1[4]);

    auto r2 = benchmark!(
        () => numbers.excludingIndices(SingleIndices).array,
        () => numbers.excludingIndices(indices).array,
        () => numbers.excludingIndices(sortedIndices).array,
        () => stdExclude(numbers, indices).array,
        () => stdExcludeSorted(numbers, sortedIndices).array,
    )(10000);

    writeln("excludingIndices (with .array): ");
    writeln("  single args:    ", r2[0]);
    writeln("  single range:   ", r2[1]);
    writeln("  sorted range:   ", r2[2]);
    writeln("  canFind range:  ", r2[3]);
    writeln("  canFind sorted: ", r2[4]);
}
