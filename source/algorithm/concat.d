/**
    Create a new range concatenating input range/value with any additional ranges and/or values.
*/
module algorithm.concat;


import common: from;

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
auto concat(Values...)(Values values)
if (!is(from!"std.traits".CommonType!(from!"utils.meta".FlattenRanges!Values) == void))
{
    import std.range: isInputRange, chain, only;
    import std.traits: isNarrowString, isSomeChar;
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

///
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

    assert(concat(i, i, i).array == [i, i, i]);
    assert([i, i].concat([i, i]).array == [i, i, i, i]);
    assert([i, i].filter!"true".concat([i, i], i, i).array == [i, i, i, i, i, i]);
    assert([i, i].concat(d, c, i).array == [i, i, d, c, i]);
    assert(d.concat(i, c, i).array == [d, i, c, i]);
    assert(c.concat(d, i).array == [c, d, i]);
    assert([c, c].concat([d, d], 2).array == "cc2.22.22");
    assert(s.concat([c, c], c).array == "ooccc");
    assert(s.concat(s, [s]).array == "oooooo");
}
