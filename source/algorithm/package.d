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
    $(TD Returns `optional` index of the first element predicate returns true for.)
    )
$(TR
    $(TD `algorithm.findlastindex`)
    $(TD Returns `optional` index of the last element predicate returns true for.)
    )
$(TR
    $(TD $(B `first`))
    $(TD Returns `optional` front of range)
    )
$(TR
    $(TD `algorithm.flatten`)
    $(TD Flattens range a single level deep.)
    )
$(TR
    $(TD `algorithm.flattendeep`)
    $(TD Flattens range recursively)
    )
$(TR
    $(TD $(B `fromPairs`))
    $(TD Returns a newly allocated associative array from a range of key/value tuples)
    )
$(TR
    $(TD $(B `head`))
    $(TD Returns `optional` back of range)
    )
$(TR
    $(TD `algorithm.indexof`)
    $(TD Finds the first element in a range that equals some value)
    )
$(TR
    $(TD $(B `initial`))
    $(TD Gets all but the last element of a range)
    )
$(TR
    $(TD `algorithm.intersection`)
    $(TD Creates a range of unique values that are included in the other given set of values)
    )
$(TR
    $(TD `algorithm.join`)
    $(TD Converts all elements in range into a string separated by separator.)
    )
$(TR
    $(TD `algorithm.lastindexof`)
    $(TD Finds the last element in a range that equals some value)
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
