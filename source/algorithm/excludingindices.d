/**
    Creates a range with elements at given indices excluded
*/
module algorithm.excludingindices;

///
unittest {
    import std.array;
    assert([1, 2, 3, 4].excludingIndices(1, 2, 3).array == [1]);
    assert([1, 2, 3, 4].excludingIndices(0, 3).array == [2, 3]);
    assert([1, 2, 3, 4].excludingIndices(0, 5).array == [2, 3, 4]);
    assert([1, 2, 3, 4].excludingIndices([2, 1]).array == [1, 4]);
    assert([1, 2, 3, 4].excludingIndices([2, 1, 0, 3]).array == []);
}

import common: from;

/**
    Returns a range excluding the specified indices.

    The indices can be given as a range of indices, or single integral arguments or a mixture of both.
    All index arguments will be $(DDOX_NAMED_REF algorithm.concat, `concat`)ed together and sorted
    before returning a range that then goes through the original range exlusing the resulting concatenation
    of indices.

    The running time is $(B O(n)) if `indices` is a single sorted range or a single index to remove, else
    there's an additional cost of standard sort running time.

    Params:
        range = an input range
        indices = zero or more integral elements or ranges

    Returns:
        A range excluding the supplied indices

    Benchmarks:
        The results compare variations of exclusingIndices with a combination of standard
        filter and canFind. For laziness the standard combination is a bit faster because
        `excludingIndices` does some work to position to the first index and/or sort the
        indices if they are not sorted.

        Overall though, `excludingIndices` is on par or faster (when a `.array`) is involved
        ---
        Benchmarking excludingIndices against filter/canFind:
          numbers: [18, 14, 1, 7, 19, 3, 16, 16, 17, 1, 17, 7, 3, 11, 10, 18, 13, 14, 7, 9]
          indices: [1, 15, 17, 10, 13, 2, 11, 14, 10, 12]
        excludingIndices:
          single args:    3 ms, 447 μs, and 2 hnsecs
          single range:   3 ms and 225 μs
          sorted range:   14 μs and 8 hnsecs
          canFind range:  0 hnsecs
          canFind sorted: 0 hnsecs
        excludingIndices (with .array):
          single args:    8 ms, 518 μs, and 5 hnsecs
          single range:   9 ms, 463 μs, and 2 hnsecs
          sorted range:   6 ms, 828 μs, and 6 hnsecs
          canFind range:  29 ms, 980 μs, and 4 hnsecs
          canFind sorted: 8 ms, 972 μs, and 6 hnsecs
        ---
*/
auto excludingIndices(Range, Indices...)(Range range, Indices indices)
if (from!"std.range".isInputRange!Range
    && from!"std.meta".allSatisfy!(
        from!"std.traits".isIntegral,
        from!"utils.meta".FlattenRanges!Indices
    )
) {
    import std.algorithm: sort;
    import std.range: empty, popFront, front, isInputRange;
    import std.array;
    import algorithm: concat;
    import utils.traits: isSortedRange;

    // If we only have one element or we are a sorted range then there's no need to sort
    static if (Indices.length == 1 && (!isInputRange!(Indices[0]) || isSortedRange!(Indices[0])))
    {
        auto normalizedIndices = concat(indices);
    }
    else
    {
        auto normalizedIndices = concat(indices).array.sort;
    }

    alias I = typeof(normalizedIndices);
    static struct Result {
        Range source;
        I indices;
        size_t currentIndex;
        this(Range r, I i) {
            this.source = r;
            this.indices = i;
            this.moveToNextElement;
        }
        void moveToNextElement() {
            while (!this.source.empty && !this.indices.empty && this.indices.front == this.currentIndex) {
                this.currentIndex++;
                this.source.popFront;
                this.indices.popFront;
            }
        }
        auto ref front() @property {
            return this.source.front;
        }
        bool empty() @property {
            return this.source.empty;
        }
        void popFront() {
            this.currentIndex++;
            this.source.popFront;

            this.moveToNextElement;
        }
    }
    return Result(range, normalizedIndices);
}
