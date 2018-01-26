module benchmarks.excludingindices;

void profile()() {
    import algorithm: excludingIndices;

    import std.stdio;
    import std.datetime.stopwatch: benchmark;
    import std.range: iota, generate, take;
    import std.meta: AliasSeq, aliasSeqOf;
    import std.algorithm: sort, canFind, filter;
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

    auto r1 = benchmark!(
        () => numbers.excludingIndices(SingleIndices),
        () => numbers.excludingIndices(indices),
        () => numbers.excludingIndices(sortedIndices),
        () => numbers.filter!(a => indices.canFind(a)),
        () => numbers.filter!(a => sortedIndices.canFind(a)),
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
        () => numbers.filter!(a => indices.canFind(a)).array,
        () => numbers.filter!(a => sortedIndices.canFind(a)).array,
    )(10000);

    writeln("excludingIndices (with .array): ");
    writeln("  single args:    ", r2[0]);
    writeln("  single range:   ", r2[1]);
    writeln("  sorted range:   ", r2[2]);
    writeln("  canFind range:  ", r2[3]);
    writeln("  canFind sorted: ", r2[4]);
}
