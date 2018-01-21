/**
    Contains a number of algorithms

$(TABLE
$(TR $(TH Function Name) $(TH Description))
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.chunk, `chunk`))
    $(TD Creates an array of elements split into groups the length of size. If array can't be split evenly,
    the final chunk will be the remaining elements.)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.compact, `compact`))
    $(TD Creates a range with all falsey values removed.)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.concat, `concat`))
    $(TD Creates a new range concatenating input range with any additional ranges and/or values)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.difference, `difference`))
    $(TD Creates a range of values not included in the other given set of values)
    )
$(TR
    $(TD `drop`)
    $(TD Creates a range with `n` elements dropped from the beginning)
    )
$(TR
    $(TD `dropRight`)
    $(TD Creates a range with `n` elements dropped from the end)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.droprightwhile, `droprightwhile`))
    $(TD Elements are dropped from the end until predicate returns false)
    )
$(TR
    $(TD `dropWhile`)
    $(TD Elements are dropped from the beginning until predicate returns false)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.fill, `fill`))
    $(TD Assigns value to each element of input range.)
    )
$(TR
    $(TD `findIndex`)
    $(TD Returns `optional` index of the first element predicate returns true for.)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.findlastindex, `findlastindex`))
    $(TD Returns `optional` index of the last element predicate returns true for.)
    )
$(TR
    $(TD `first`)
    $(TD Returns `optional` front of range)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.flatten, `flatten`))
    $(TD Flattens range a single level deep.)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.flattendeep, `flattendeep`))
    $(TD Flattens range recursively)
    )
$(TR
    $(TD `fromPairs`)
    $(TD Returns a newly allocated associative array from a range of key/value tuples)
    )
$(TR
    $(TD `head`)
    $(TD Returns `optional` back of range)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.indexof, `indexof`))
    $(TD Finds the first element in a range that equals some value)
    )
$(TR
    $(TD `initial`)
    $(TD Gets all but the last element of a range)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.intersection, `intersection`))
    $(TD Creates a range of unique values that are included in the other given set of values)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.join, `join`))
    $(TD Converts all elements in range into a string separated by separator.)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.lastindexof, `lastindexof`))
    $(TD Finds the last element in a range that equals some value)
    )
)
*/
module algorithm;

import common: from;

public {
    import algorithm.flatmap;
    import algorithm.chunk;
    import algorithm.compact;
    import algorithm.concat;
    import algorithm.difference;

    /// Creates a slice of a range with n elements dropped from the beginning.
    auto drop(Range)(Range r, size_t n = 1) if (from!"std.range".isInputRange!Range) {
        import std.range: stdDrop = drop;
        return r.stdDrop(n);
    }

    ///
    unittest {
        import std.array;
        assert([1, 2, 3].drop.array == [2, 3]);
    }

    /// Creates a slice of range with n elements dropped from the end.
    auto dropRight(Range)(Range r, size_t n = 1) if (from!"std.range".isBidirectionalRange!Range) {
        import std.range: stdDropBack = dropBack;
        return r.stdDropBack(n);
    }

    ///
    unittest {
        import std.array;
        assert([1, 2, 3].dropRight.array == [1, 2]);
    }

    import algorithm.droprightwhile;

    /// Elements are dropped from the beginning until predicate returns false
    alias dropWhile(alias pred) = (range) => from!"std.algorithm".until!(from!"std.functional".not!pred)(range);

    ///
    unittest {
        import std.array;
        assert([1, 2, 3, 4].dropWhile!(a => a < 3).array == [1, 2]);
    }

    import algorithm.fill;

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
