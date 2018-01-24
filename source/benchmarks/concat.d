module benchmarks.concat;

import std.stdio;
import std.datetime.stopwatch: benchmark;

import algorithm.concat;
import std.array;

import common: from;
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

void profile()() {

    import std.range: iota;
    import std.meta: AliasSeq, aliasSeqOf;
    import std.typecons;

    alias SingleArgs = aliasSeqOf!(10.iota);
    auto r1 = benchmark!(
        () => concatTo(SingleArgs),
        () => cast(void)concatAll(SingleArgs),
        () => concatEager(SingleArgs),
        () => concatTo(SingleArgs).array,
        () => concatAll(SingleArgs).array,
        () => concatEager(SingleArgs).array
    )(10000);

    writeln("concat singles:");
    writeln("  concatTo              ", r1[0]);
    writeln("  concatAll:            ", r1[1]);
    writeln("  concatEager:          ", r1[2]);
    writeln("  concatTo     (array): ", r1[3]);
    writeln("  concatAll    (array): ", r1[4]);
    writeln("  concatEager  (array): ", r1[5]);

    alias RangeArgs = AliasSeq!(1.iota.array, 3.iota.array, 10.iota.array);
    auto r2 = benchmark!(
        () => concatTo(RangeArgs),
        () => cast(void)concatAll(RangeArgs),
        () => concatEager(RangeArgs),
        () => concatTo(RangeArgs).array,
        () => concatAll(RangeArgs).array,
        () => concatEager(RangeArgs).array
    )(10000);

    writeln("concat ranges:");
    writeln("  concatTo              ", r2[0]);
    writeln("  concatAll:            ", r2[1]);
    writeln("  concatEager:          ", r2[2]);
    writeln("  concatTo     (array): ", r2[3]);
    writeln("  concatAll    (array): ", r2[4]);
    writeln("  concatEager  (array): ", r2[5]);

    alias MixedArgs = AliasSeq!(1, 2, 3, 1.iota.array, 3.iota.array, 10.iota.array);
    auto r3 = benchmark!(
        () => concatTo(MixedArgs),
        () => cast(void)concatAll(MixedArgs),
        () => concatEager(MixedArgs),
        () => concatTo(MixedArgs).array,
        () => concatAll(MixedArgs).array,
        () => concatEager(MixedArgs).array
    )(10000);

    writeln("concat mixed:");
    writeln("  concatTo              ", r3[0]);
    writeln("  concatAll:            ", r3[1]);
    writeln("  concatEager:          ", r3[2]);
    writeln("  concatTo     (array): ", r3[3]);
    writeln("  concatAll    (array): ", r3[4]);
    writeln("  concatEager  (array): ", r3[5]);

    alias StringArgs = AliasSeq!("hello ", "world", "!", 'c', 'c');
    auto r4 = benchmark!(
        () => concatTo(StringArgs),
        () => cast(void)concatAll(StringArgs),
        () => concatTo(StringArgs).array,
        () => concatAll(StringArgs).array,
    )(10000);

    writeln("concat string:");
    writeln("  concatTo             ", r4[0]);
    writeln("  concatAll:           ", r4[1]);
    writeln("  concatTo    (array): ", r4[2]);
    writeln("  concatAll   (array): ", r4[2]);
}
