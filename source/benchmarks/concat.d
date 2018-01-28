module benchmarks.concat;

import common;
//
// An concatEager version of concat just for testing. Tests in release show that this is
// never faster in any case.
//
// It is usually faster in debug builds though.
//
// This verison is limited in that it does not do narrow strings
//
private template concatEager(Values...)
if ((!is(from!"std.traits".CommonType!(from!"utils.meta".FlattenRanges!Values) == void)
    && !from!"std.meta".anySatisfy!(from!"std.traits".isNarrowString, Values))
        || Values.length == 0)
{
    import std.range: isInputRange;
    import std.traits: CommonType;
    import utils.meta: FlattenRanges;

    alias T = CommonType!(FlattenRanges!Values);

    auto concatEager(Values values) {
        T[] array;
        static foreach (i; 0 .. Values.length)
        {
            static if (isInputRange!(Values[i]))
            {
                import std.conv: to;
                array ~= values[i].to!(T[]);
            }
            else
            {
                array ~= values[i];
            }
        }
        return array;
    }
}

unittest {
    auto a = concatEager(1, 2.0, 'c', [3, 4]);
    assert(a == [1, 2, 99, 3, 4]);
    static assert(is(typeof(a) == double[]));

    // Narrow strings not supported
    static assert(!__traits(compiles, concatEager(1, "str")));
}

//
// concats a a value or range TO another range recursively
//
auto concatRecurse(Range, Values...)(Range range, Values values) if (from!"std.range".isInputRange!Range) {
    import std.range: chain, ElementType, isInputRange;
    static if (Values.length)
    {
        static if (isInputRange!(Values[0]) && is(ElementType!(Values[0]) : ElementType!Range))
        {
            return range
                .chain(values[0])
                .concatRecurse(values[1..$]);
        }
        else static if (is(Values[0] : ElementType!Range))
        {
            return range
                .chain([values[0]])
                .concatRecurse(values[1..$]);
        }
        else
        {
            static assert(0, "Cannot concatRecurse type " ~ Values[0].stringof ~ " to range of " ~ ElementType!Range.stringof);
        }
    }
    else
    {
        return range;
    }
}

auto concatRecurse(T, Values...)(T value, Values values) if (!from!"std.range".isInputRange!T) {
    import std.range: only;
    return concatRecurse([value], values);
}

unittest {
    import std.range: iota, array;
    assert([1, 2, 3].concatRecurse(4, [5], [6, 7], 8).array == 1.iota(9).array);
    assert([1].concatRecurse(2).array == [1, 2]);
    assert([1.0].concatRecurse(2).array == [1.0, 2.0]);
    assert([1.0].concatRecurse([2, 3]).array == [1.0, 2.0, 3.0]);
    assert(1.concatRecurse().array == [1]);
    assert([1].concatRecurse().array == [1]);
    assert(1.concatRecurse(2, 3).array == [1, 2, 3]);
    assert(1.concatRecurse(2, [3, 4]).array == [1, 2, 3, 4]);
}

void profile()() {
    import algorithm.concat;

    import std.array;
    import std.stdio;
    import std.datetime.stopwatch: benchmark;
    import std.range: iota;
    import std.meta: AliasSeq, aliasSeqOf;

    writeln("Benchmarking concat against eager, recursive, and standard lib");
    writeln("the (array) versions involve a call to .array");

    alias SingleArgs = aliasSeqOf!(10.iota);
    auto r1 = benchmark!(
        () => cast(void)concat(SingleArgs),
        () => concatRecurse(SingleArgs),
        () => concatEager(SingleArgs),
        () => concat(SingleArgs).array,
        () => concatRecurse(SingleArgs).array,
        () => concatEager(SingleArgs).array
    )(10000);

    writeln("concat single arguments:");
    writeln("  concat:                ", r1[0]);
    writeln("  concatRecurse:         ", r1[1]);
    writeln("  concatEager:           ", r1[2]);
    writeln("  concat        (array): ", r1[3]);
    writeln("  concatRecurse (array): ", r1[4]);
    writeln("  concatEager   (array): ", r1[5]);

    alias RangeArgs = AliasSeq!(1.iota.array, 3.iota.array, 10.iota.array);
    auto r2 = benchmark!(
        () => cast(void)concat(RangeArgs),
        () => concatRecurse(RangeArgs),
        () => concatEager(RangeArgs),
        () => concat(RangeArgs).array,
        () => concatRecurse(RangeArgs).array,
        () => concatEager(RangeArgs).array
    )(10000);

    writeln("concat multiple ranges together");
    writeln("  concat:                ", r2[0]);
    writeln("  concatRecurse:         ", r2[1]);
    writeln("  concatEager:           ", r2[2]);
    writeln("  concat        (array): ", r2[3]);
    writeln("  concatRecurse (array): ", r2[4]);
    writeln("  concatEager   (array): ", r2[5]);

    alias MixedArgs = AliasSeq!(1, 2, 3, 1.iota.array, 3.iota.array, 10.iota.array);
    auto r3 = benchmark!(
        () => cast(void)concat(MixedArgs),
        () => concatRecurse(MixedArgs),
        () => concatEager(MixedArgs),
        () => concat(MixedArgs).array,
        () => concatRecurse(MixedArgs).array,
        () => concatEager(MixedArgs).array
    )(10000);

    writeln("concat single args and multiple ranges:");
    writeln("  concat:                ", r3[0]);
    writeln("  concatRecurse:         ", r3[1]);
    writeln("  concatEager:           ", r3[2]);
    writeln("  concat        (array): ", r3[3]);
    writeln("  concatRecurse (array): ", r3[4]);
    writeln("  concatEager   (array): ", r3[5]);

    alias StringArgs = AliasSeq!("hello ", "world", "!", 'c', 'c');
    auto r4 = benchmark!(
        () => cast(void)concat(StringArgs),
        () => concatRecurse(StringArgs),
        () => concat(StringArgs).array,
        () => concatRecurse(StringArgs).array,
    )(10000);

    writeln("concat strings and chars:");
    writeln("  concat:                 ", r4[0]);
    writeln("  concatRecurse:          ", r4[1]);
    writeln("  concat         (array): ", r4[2]);
    writeln("  concatRecurse  (array): ", r4[3]);

    import algorithm: join;
    alias OnlyStrings = AliasSeq!("hello ", "world", "!", "'c'", "'c'");

    auto useAppender(string[] strings) {
        import std.array: appender;
        auto ap = appender!string;
        foreach (str; strings) {
            ap.put(str);
        }
        return ap;
    }
    auto r5 = benchmark!(
        () => cast(void)concat(OnlyStrings),
        () => join([OnlyStrings], ""),
        () => useAppender([OnlyStrings]),
        () => concat(OnlyStrings).array,
        () => join([OnlyStrings], "").array,
        () => useAppender([OnlyStrings]).data,
    )(10000);

    writeln("concat strings vs appender and join");
    writeln("  concat:                 ", r5[0]);
    writeln("  join:                   ", r5[1]);
    writeln("  appender:               ", r5[2]);
    writeln("  concat    (array):      ", r5[3]);
    writeln("  join      (array):      ", r5[4]);
    writeln("  appender  (array):      ", r5[5]);
}
