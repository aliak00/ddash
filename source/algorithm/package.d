/**
    Contains a number of algorithms

$(TABLE
$(TR $(TH Module) $(TH Function Name) $(TH Description))
$(TR
    $(TD `algorithm.chunk`)
    $(TD $(DDOX_NAMED_REF algorithm.chunk, `chunk`))
    $(TD Creates an array of elements split into groups the length of size.)
    )
$(TR
    $(TD `algorithm.compact`)
    $(TD
        $(DDOX_NAMED_REF algorithm.compact.compact, `compact`)<br>
        $(DDOX_NAMED_REF algorithm.compact.compactBy, `compactBy`)<br>
        $(DDOX_NAMED_REF algorithm.compact.compactValues, `compactValues`)<br>
        )
    $(TD Creates a range with all falsey values removed.)
    )
$(TR
    $(TD `algorithm.concat`)
    $(TD $(DDOX_NAMED_REF algorithm.concat, `concat`))
    $(TD Concatenate ranges and values together to a new range)
    )
$(TR
    $(TD `algorithm.difference`)
    $(TD
        $(DDOX_NAMED_REF algorithm.difference.difference, `difference`)<br>
        $(DDOX_NAMED_REF algorithm.difference.differenceBy, `differenceBy`)<br>
        )
    $(TD Creates a range of values not included in the other given set of values)
    )
$(TR
    $(TD -)
    $(TD `drop`)
    $(TD Creates a range with `n` elements dropped from the beginning)
    )
$(TR
    $(TD -)
    $(TD `dropRight`)
    $(TD Creates a range with `n` elements dropped from the end)
    )
$(TR
    $(TD `algorithm.droprightwhile`)
    $(TD $(DDOX_NAMED_REF algorithm.droprightwhile, `dropRightWhile`))
    $(TD Elements are dropped from the end until predicate returns false)
    )
$(TR
    $(TD -)
    $(TD `dropWhile`)
    $(TD Elements are dropped from the beginning until predicate returns false)
    )
$(TR
    $(TD `algorithm.equal`)
    $(TD
        $(DDOX_NAMED_REF algorithm.equal.equal, `equal`)<br>
        $(DDOX_NAMED_REF algorithm.equal.equalBy, `equalBy`)<br>
        )
    $(TD Tells you if two things are equal)
    )
$(TR
    $(TD `algorithm.fill`)
    $(TD $(DDOX_NAMED_REF algorithm.fill, `fill`))
    $(TD Assigns value to each element of input range.)
    )
$(TR
    $(TD `algorithm.findindex`)
    $(TD $(DDOX_NAMED_REF algorithm.findindex, `findIndex`))
    $(TD Returns `optional` index of the first element predicate returns true for.)
    )
$(TR
    $(TD `algorithm.findlastindex`)
    $(TD $(DDOX_NAMED_REF algorithm.findlastindex, `findLastIndex`))
    $(TD Returns `optional` index of the last element predicate returns true for.)
    )
$(TR
    $(TD `algorithm.first`)
    $(TD `first`)
    $(TD Returns `optional` front of range)
    )
$(TR
    $(TD `algorithm.flatten`)
    $(TD
        $(DDOX_NAMED_REF algorithm.flatten.flatten, `flatten`)<br>
        $(DDOX_NAMED_REF algorithm.flatten.flattenDeep, `flattenDeep`)<br>
        )
    $(TD Flattens a range by removing $(DDOX_NAMED_REF utils.isFalsey, `falsey`) values)
    )
$(TR
    $(TD `algorithm.frompairs`)
    $(TD $(DDOX_NAMED_REF algorithm.frompairs, `fromPairs`))
    $(TD Returns a newly allocated associative array from a range of key/value tuples)
    )
$(TR
    $(TD -)
    $(TD `last`)
    $(TD Returns `optional` back of range)
    )
$(TR
    $(TD `algorithm.indexof`)
    $(TD $(DDOX_NAMED_REF algorithm.indexof, `indexOf`))
    $(TD Finds the first element in a range that equals some value)
    )
$(TR
    $(TD -)
    $(TD `initial`)
    $(TD Gets all but the last element of a range)
    )
$(TR
    $(TD `algorithm.intersection`)
    $(TD $(DDOX_NAMED_REF algorithm.intersection, `intersection`))
    $(TD Creates a range of unique values that are included in the other given set of values)
    )
$(TR
    $(TD `algorithm.join`)
    $(TD $(DDOX_NAMED_REF algorithm.join, `join`))
    $(TD Converts all elements in range into a string separated by separator.)
    )
$(TR
    $(TD `algorithm.lastindexof`)
    $(TD $(DDOX_NAMED_REF algorithm.lastindexof, `lastIndexOf`))
    $(TD Finds the last element in a range that equals some value)
    )
$(TR
    $(TD `algorithm.nth`)
    $(TD $(DDOX_NAMED_REF algorithm.nth, `nth`))
    $(TD Returns the element at nth index of range)
    )
$(TR
    $(TD `algorithm.pull`)
    $(TD
        $(DDOX_NAMED_REF algorithm.pull.pull, `pull`)<br>
        $(DDOX_NAMED_REF algorithm.pull.pullAt, `pullAt`)<br>
        $(DDOX_NAMED_REF algorithm.pull.pullBy, `pullBy`)<br>
        )
    $(TD Pulls elements out of a range)
    )
$(TR
    $(TD `algorithm.remove`)
    $(TD $(DDOX_NAMED_REF algorithm.remove, `remove`))
    $(TD Removed elements from a range by unary predicate)
    )
$(TR
    $(TD -)
    $(TD `reverse`)
    $(TD Reverses a range in place)
    )
$(TR
    $(TD `algorithm.slice`)
    $(TD $(DDOX_NAMED_REF algorithm.slice, `slice`))
    $(TD Creates a slice of range from start up to, but not including, end)
    )
$(TR
    $(TD `algorithm.sort`)
    $(TD $(DDOX_NAMED_REF algorithm.sort.sortBy, `sortBy`))
    $(TD Provides various ways for sorting a range)
    )
$(TR
    $(TD `algorithm.zip`)
    $(TD $(DDOX_NAMED_REF algorithm.zip.zipEach, `zipEach`))
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
