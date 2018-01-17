/**
    Contains a number of algorithms

$(TABLE
$(TR $(TH Function Name) $(TH Description))
$(TR
    $(TD `algorithm.chunk`)
    $(TD Creates an array of elements split into groups the length of size. If array can't be split evenly,
    the final chunk will be the remaining elements.)
    )
$(TR
    $(TD `algorithm.compact`)
    $(TD Creates a range with all falsey values removed.)
    )
$(TR
    $(TD `algorithm.concat`)
    $(TD Creates a new range concatenating input range with any additional ranges and/or values)
    )
$(TR
    $(TD `algorithm.difference`)
    $(TD Creates a range of values not included in the other given set of values)
    )
$(TR
    $(TD $(B `drop`))
    $(TD Creates a range with `n` elements dropped from the beginning)
    )
$(TR
    $(TD $(B `dropRight`))
    $(TD Creates a range with `n` elements dropped from the end)
    )
$(TR
    $(TD `algorithm.droprightwhile`)
    $(TD Elements are dropped from the end until predicate returns false)
    )
$(TR
    $(TD $(B `dropWhile`))
    $(TD Elements are dropped from the beginning until predicate returns false)
    )
$(TR
    $(TD $(B *`fill`))
    $(TD Assigns value to each element of input range range.)
    )
$(TR
    $(TD $(B `findIndex`))
    $(TD Returns the index of the first element predicate returns true for. Implement as `phobos.countuntil`)
    )
$(TR
    $(TD `algorithm.lastindexof`)
    $(TD Finds last element in range that equals some value)
    )
$(TR
    $(TD `algorithm.intersection`)
    $(TD Creates a range of unique values that are included in the other given set of values)
    )
)

Note: Functions not fully qualified do not have details docs because they are implemented as either
lambas or aliases over exiting function

Note: Functions marked with a `*` need a bit more work before they at least match lodash functionality
*/
module algorithm;

import common: from;

public {
    import algorithm.flatmap;
    import algorithm.chunk;
    import algorithm.compact;
    import algorithm.concat;
    import algorithm.difference;
    import std.range: drop;
    import std.range: dropRight = dropBack;
    import algorithm.droprightwhile;
    alias dropWhile(alias pred) = (range) => from!"std.algorithm".until!(from!"std.functional".not!pred)(range);
    import std.algorithm: fill;
    import phobos: findIndex = countUntil;
    import algorithm.findlastindex;
    alias first = from!"range".maybeFront;
    import algorithm.flatten;
    import algorithm.flattendeep;
    import std.array: fromPairs = assocArray;
    import algorithm.indexof;
    alias initial = (range) => from!"std.range".dropBack(range, 1);
    import algorithm.intersection;
    import algorithm.join;
    alias last = from!"range".maybeBack;
    import algorithm.lastindexof;
}
