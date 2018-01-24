/**
    Create a new range concatenating input range/value with any additional ranges and/or values.
*/
module algorithm.concat;

///
unittest {
    import std.range: iota, array;

    // Concat single elements and ranges
    assert([1, 2, 3].concatTo(4, [5], [6, 7], 8).array == 1.iota(9).array);

    // Concat single element
    assert([1].concatTo(2).array == [1, 2]);

    // Implicitly convertible elements ok
    assert([1.0].concatTo(2).array == [1.0, 2.0]);

    // Implicitly convertible ranges ok
    assert([1.0].concatTo([2, 3]).array == [1.0, 2.0, 3.0]);

    // Concat nothing to single value
    assert(1.concatTo().array == [1]);

    // Concat nothing to range
    assert([1].concatTo().array == [1]);

    // Concat values to another value
    assert(1.concatTo(2, 3).array == [1, 2, 3]);

    // Concat ranges or values to another value
    assert(1.concatTo(2, [3, 4]).array == [1, 2, 3, 4]);

    // Non implicily convertible elements not ok
    static assert(!__traits(compiles, [1].concatTo(1, 2.0)));

    // Non implicily convertible range not ok
    static assert(!__traits(compiles, [1].concatTo(1, [2.0])));
}

import common: from;

/**
    Concats `values` to a `range`. Each value to concatenate with `range` must be either a single
    value that is implicitly convertible to `ElementType!Range` or a range that has element types
    that are implictly convertible

    Params:
        range = an input range
        values = Either a single element or an input range
            which will be concatenated to `range`

    Returns:
        A range
*/
auto concatTo(Range, Values...)(Range range, Values values) if (from!"std.range".isInputRange!Range) {
    import std.range: chain, ElementType, isInputRange;
    static if (Values.length)
    {
        static if (isInputRange!(Values[0]) && is(ElementType!(Values[0]) : ElementType!Range))
        {
            return range
                .chain(values[0])
                .concatTo(values[1..$]);
        }
        else static if (is(Values[0] : ElementType!Range))
        {
            return range
                .chain([values[0]])
                .concatTo(values[1..$]);
        }
        else
        {
            static assert(0, "Cannot concatTo type " ~ Values[0].stringof ~ " to range of " ~ ElementType!Range.stringof);
        }
    }
    else
    {
        return range;
    }
}

/**
    Concats `values` to an initial `value`

    Params:
        value = any value T
        values = Either a single element or an input range
            which will be concatenated to `range`

    Returns:
        A range
*/
auto concatTo(T, Values...)(T value, Values values) if (!from!"std.range".isInputRange!T) {
    import std.range: only;
    return concatTo([value], values);
}

///
unittest {
    import std.array;
    assert(concatTo(1, 2, 3).array == [1, 2, 3]);
}

/**
    Concats every together using best effort.

    It will concat as long as there is common type between all sets of inputs. When an input
    is a range it will use `ElementType` as it's type.

    If the first input is a string, all subsequent inputs are converted to a string as well

    Params:
        values = set of values that share a common type.

    Returns:
        A range of common type or a string if the first value is a string
*/
auto concatAll(Values...)(Values values)
if (!is(from!"std.traits".CommonType!(from!"utils.meta".FlattenRanges!Values) == void))
{
    import std.range: isInputRange, chain, only;
    import std.traits: isNarrowString;
    import std.conv: to;

    static if (!Values.length)
    {
        return;
    }
    else
    {
        alias Head = Values[0];
        alias Rest = Values[1..$];
        static if (isNarrowString!(Head))
        {
            auto link0 = values[0].to!string;
        }
        else
        {
            static if (isInputRange!(Head))
            {
                auto link0 = chain(values[0]);
            }
            else
            {
                auto link0 = only(values[0]);
            }
        }

        // Declare a variable called `linkX` equal to previous link chained with input range
        string link(int i, string range) {
            return "auto link" ~ i.to!string ~ " = link" ~ (i - 1).to!string
                 ~ ".chain(" ~ range ~ ");";
        }

        static foreach (I; 1 .. Values.length)
        {
            static if (isNarrowString!Head)
            {
                static if (isNarrowString!(Values[I]))
                {
                    mixin(link(I, q{ values[I] }));
                }
                else static if (isInputRange!(Values[I]))
                {
                    import algorithm: join;
                    mixin(link(I, q{ values[I].join("") }));
                }
                else
                {
                    mixin(link(I, q{ values[I].to!string }));
                }
            }
            else
            {
                static if (isInputRange!(Values[I]))
                {
                    mixin(link(I, q{ values[I] }));
                }
                else
                {
                    mixin(link(I, q{ only(values[I]) }));
                }
            }
        }
        mixin("return link" ~ (Values.length - 1).to!string ~ ";");
    }
}

///
unittest {
    import std.array;

    int i = 1;
    double d = 2.2;
    char c = 'c';
    string s = "oo";

    auto a = concatAll(i, d, c, [i, i]).array;
    assert(a == [i, d, c, i, i]);
    static assert(is(typeof(a) == double[]));

    import std.algorithm: filter;

    assert(concatAll(i, i, i).array == [i, i, i]);
    assert([i, i].concatAll([i, i]).array == [i, i, i, i]);
    assert([i, i].filter!"true".concatAll([i, i], i, i).array == [i, i, i, i, i, i]);
    assert([i, i].concatAll(d, c, i).array == [i, i, d, c, i]);
    assert(d.concatAll(i, c, i).array == [d, i, c, i]);
    assert(c.concatAll(d, i).array == [c, d, i]);
    assert([c, c].concatAll([d, d], 2).array == "cc2.22.22");
    assert(s.concatAll([c, c], c).array == "ooccc");
    assert(s.concatAll(s, [s]).array == "oooooo");
}
