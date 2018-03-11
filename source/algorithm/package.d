/**
    Contains a number of algorithms

$(TABLE
$(TR $(TH Function Name) $(TH Description))
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.chunk, `chunk`))
    $(TD Creates an array of elements split into groups the length of size.)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.compact, `compact`))
    $(TD Creates a range with all falsey values removed.)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.concat, `concat`))
    $(TD Concatenate ranges and values together to a new range)
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
    $(TD $(DDOX_NAMED_REF algorithm.droprightwhile, `dropRightWhile`))
    $(TD Elements are dropped from the end until predicate returns false)
    )
$(TR
    $(TD `dropWhile`)
    $(TD Elements are dropped from the beginning until predicate returns false)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.equal, `equal`))
    $(TD Tells you if two things are equal)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.fill, `fill`))
    $(TD Assigns value to each element of input range.)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.findindex, `findIndex`))
    $(TD Returns `optional` index of the first element predicate returns true for.)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.findlastindex, `findLastIndex`))
    $(TD Returns `optional` index of the last element predicate returns true for.)
    )
$(TR
    $(TD `first`)
    $(TD Returns `optional` front of range)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.flatten, `flatten`))
    $(TD Flattens a range by removing $(DDOX_NAMED_REF utils.isFalsey, `falsey`) values)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.frompairs, `fromPairs`))
    $(TD Returns a newly allocated associative array from a range of key/value tuples)
    )
$(TR
    $(TD `last`)
    $(TD Returns `optional` back of range)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.indexof, `indexOf`))
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
    $(TD $(DDOX_NAMED_REF algorithm.lastindexof, `lastIndexOf`))
    $(TD Finds the last element in a range that equals some value)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.nth, `nth`))
    $(TD Returns the element at nth index of range)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.pull, `pull`))
    $(TD Pulls elements out of a range)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.remove, `remove`))
    $(TD Removed elements from a range by unary predicate)
    )
$(TR
    $(TD `reverse`)
    $(TD Reverses a range in place)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.slice, `slice`))
    $(TD Creates a slice of range from start up to, but not including, end)
    )
$(TR
    $(TD $(DDOX_NAMED_REF algorithm.zip, `zip`))
    $(TD Zips up ranges together)
    )
)
*/
module algorithm;

import common;

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
    auto dropWhile(alias pred, Range)(Range range) if (from!"std.range".isInputRange!Range) {
        import std.algorithm: until;
        import std.functional: not;
        return range.until!(not!pred);
    }

    ///
    unittest {
        import std.array;
        assert([1, 2, 3, 4].dropWhile!(a => a < 3).array == [1, 2]);
    }

    import algorithm.equal;
    import algorithm.fill;
    import algorithm.findindex;
    import algorithm.findlastindex;

    /// Returns `optional` front of range
    alias first = from!"range".maybeFront;

    ///
    unittest {
        import optional: some, none;
        assert([1, 2].first == some(1));
        assert((int[]).init.first == none);
    }

    import algorithm.flatten;
    import algorithm.frompairs;
    import algorithm.indexof;

    /// Gets all but the last element of a range
    alias initial = (range) => from!"std.range".dropBack(range, 1);

    ///
    unittest {
        import std.array;
        assert([1, 2, 3, 4].initial.array == [1, 2, 3]);
    }

    import algorithm.intersection;
    import algorithm.join;

    /// Returns `optional` end of range
    alias last = from!"range".maybeBack;

    ///
    unittest {
        import optional: some, none;
        assert([1, 2].last == some(2));
        assert((int[]).init.last == none);
    }

    import algorithm.lastindexof;
    import algorithm.nth;
    import algorithm.pull;
    import algorithm.remove;

    /// Reverses the range by mutating it
    void reverse(Range)(ref Range range)
    if (from!"std.range".isBidirectionalRange!Range
        && !from!"std.range".isRandomAccessRange!Range
        && from!"std.range".hasSwappableElements!Range
        || (from!"std.range".isRandomAccessRange!Range && from!"std.range".hasLength!Range))
    {
        import std.algorithm: reverse;
        range.reverse;
    }

    ///
    unittest {
        auto arr = [1, 2, 3, 4];
        arr.reverse;
        assert(arr.equal([4, 3, 2, 1]));
    }

    import algorithm.slice;
    import algorithm.zip;
}
