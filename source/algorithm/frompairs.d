/**
    Returns a newly allocated associative array from pairs

    This is primarily for `std.typecons.Tuple` type objects and works on a range
    of tuples of size 2. If any other range is given to it, then it will treat
    every pair of elements as a Tuple and do the same thing.

*/
module algorithm.frompairs;

///
unittest {
    import std.typecons;
    assert([tuple(1, 2), tuple(3, 4) ].fromPairs == [1: 2, 3: 4]);
}

import common;

/**
    Ditto

    Params:
        r1 = range of elements to create an associated array out of

    Returns:
        Associative array
*/
auto fromPairs(R1)(R1 r1) if (from!"std.range".isInputRange!R1) {
    import std.range: ElementType;
    import std.typecons: Tuple;
    static if (is(ElementType!R1 : Tuple!Args, Args...) && Args.length == 2)
    {
        import std.array: assocArray;
        return r1.assocArray;
    }
    else
    {
        alias E = ElementType!R1;
        import std.range;
        import std.algorithm;
        return r1.chunks(2).fold!((memo, pair) {
            auto k = pair.front;
            pair.popFront;
            if (!pair.empty) {
                memo[k] = pair.front;
            }
            return memo;
        })((E[E]).init);
    }
}

unittest {
    import std.algorithm: filter;
    import std.typecons;
    assert([1, 2, 3].filter!"true".fromPairs == [1: 2]);
    assert([tuple(1, 2)].fromPairs == [1: 2]);
}
