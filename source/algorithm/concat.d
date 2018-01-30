/**
    Create a new range concatenating input range/value with any additional ranges and/or values.
*/
module algorithm.concat;

///
unittest {
    import std.range: iota;

    // Concat stuff
    assert([1, 2, 3].concat(4, [5], [6, 7], 8).equal(1.iota(9)));

    // Concat ingle element
    assert([1].concat(2).equal([1, 2]));

    // Implicitly convertible doubles with ints
    assert([1.0].concat([2, 3]).equal([1.0, 2.0, 3.0]));

    // Concat nothing to single value
    assert(1.concat().equal([1]));

    // Concat nothing to range
    assert([1].concat().equal([1]));

    // Concat values to another value
    assert(1.concat(2, 3).equal([1, 2, 3]));

    // Concat ranges or values to another value
    assert(1.concat(2, [3, 4]).equal([1, 2, 3, 4]));

    // Concat strings
    assert("yo".concat("dles").equal("yodles"));

    // Concat stuff to string
    assert("abc".concat(1, 2, 3).equal("abc123"));
}


import common;

/**
    Concats everything together using best effort.

    It will concat as long as there is a common type between all sets of inputs. When an input
    is a range it will use `ElementType` as it's type.

    If the first input is a string, all subsequent inputs are converted to a string as well

    Params:
        values = set of values that share a common type.

    Returns:
        A range of common type or a string if the first value is a string

    Benchmarks:
        Bottom line, concat (which uses a static foreach) is faster than eager and
        recursive approach both with and without .array.

        If you are dealing only with pure strings, however, then appender is your
        friend

        ---
        Benchmarking concat against eager, recursive, and standard lib
        the (array) versions involve a call to .array
        concat single arguments:
          concat:                1 hnsec
          concatRecurse:         5 ms, 921 μs, and 6 hnsecs
          concatEager:           5 ms, 417 μs, and 5 hnsecs
          concat        (array): 1 ms and 372 μs
          concatRecurse (array): 7 ms, 587 μs, and 2 hnsecs
          concatEager   (array): 5 ms, 968 μs, and 2 hnsecs
        concat multiple ranges together
          concat:                1 ms, 491 μs, and 3 hnsecs
          concatRecurse:         2 ms, 195 μs, and 3 hnsecs
          concatEager:           7 ms, 787 μs, and 2 hnsecs
          concat        (array): 3 ms, 174 μs, and 2 hnsecs
          concatRecurse (array): 2 ms, 816 μs, and 7 hnsecs
          concatEager   (array): 6 ms, 838 μs, and 1 hnsec
        concat single args and multiple ranges:
          concat:                1 ms, 858 μs, and 1 hnsec
          concatRecurse:         3 ms, 479 μs, and 2 hnsecs
          concatEager:           7 ms, 374 μs, and 9 hnsecs
          concat        (array): 3 ms, 358 μs, and 5 hnsecs
          concatRecurse (array): 5 ms, 558 μs, and 1 hnsec
          concatEager   (array): 6 ms, 997 μs, and 3 hnsecs
        concat strings and chars:
          concat:                 0 hnsecs
          concatRecurse:          1 ms, 368 μs, and 8 hnsecs
          concat         (array): 4 ms, 238 μs, and 3 hnsecs
          concatRecurse  (array): 5 ms, 77 μs, and 9 hnsecs
        concat strings vs appender and join
          concat:                 0 hnsecs
          join:                   6 ms, 930 μs, and 4 hnsecs
          appender:               3 ms, 186 μs, and 1 hnsec
          concat    (array):      4 ms, 917 μs, and 6 hnsecs
          join      (array):      9 ms, 243 μs, and 7 hnsecs
          appender  (array):      3 ms, 57 μs, and 8 hnsecs
        ---
*/
auto concat(Values...)(Values values) if (from!"utils.traits".areCombinable!Values) {
    import std.range: isInputRange, chain, only;
    import std.traits: isNarrowString, isSomeChar;
    import std.conv: to;

    static if (!Values.length)
    {
        return;
    }
    else static if (Values.length == 1)
    {
        static if (isInputRange!(Values[0]))
        {
            return values[0];
        }
        else
        {
            return only(values[0]);
        }
    }
    else
    {
        alias Head = Values[0];
        alias Rest = Values[1..$];
        static if (isNarrowString!(Head))
        {
            auto link0 = values[0];
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
                else static if (isSomeChar!(Values[I]))
                {
                    import std.range: only;
                    mixin(link(I, q{ only(values[I]) }));
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

unittest {
    import std.array;

    int i = 1;
    double d = 2.2;
    char c = 'c';
    string s = "oo";

    auto a = concat(i, d, c, [i, i]).array;
    assert(a == [i, d, c, i, i]);
    static assert(is(typeof(a) == double[]));

    import std.algorithm: filter;

    assert(concat(i, i, i).equal([i, i, i]));
    assert([i, i].concat([i, i]).equal([i, i, i, i]));
    assert([i, i].filter!"true".concat([i, i], i, i).equal([i, i, i, i, i, i]));
    assert([i, i].concat(d, c, i).equal([i, i, d, c, i]));
    assert(d.concat(i, c, i).equal([d, i, c, i]));
    assert(c.concat(d, i).equal([c, d, i]));
    assert([c, c].concat([d, d], 2).equal("cc2.22.22"));
    assert(s.concat([c, c], c).equal("ooccc"));
    assert(s.concat(s, [s]).equal("oooooo"));
}

unittest {
    import std.algorithm: filter;
    import std.range: only;
    // Make sure if it's a single range the same type is returned
    auto a = [1, 2];
    auto b = [1].filter!"true";
    static assert(is(typeof(concat(a)) == typeof(a)));
    static assert(is(typeof(concat(b)) == typeof(b)));
    static assert(is(typeof(concat(1)) == typeof(only(1))));
}
