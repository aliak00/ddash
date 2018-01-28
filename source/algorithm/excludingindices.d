/**
    Creates a range with elements at given indices excluded
*/
module algorithm.excludingindices;

///
unittest {
    assert([1, 2, 3, 4].excludingIndices(1, 2, 3).equal([1]));
    assert([1, 2, 3, 4].excludingIndices(0, 3).equal([2, 3]));
    assert([1, 2, 3, 4].excludingIndices(0, 5).equal([2, 3, 4]));
    assert([1, 2, 3, 4].excludingIndices([2, 1]).equal([1, 4]));
    assert([1, 2, 3, 4].excludingIndices([2, 1, 0, 3]).empty);
}

import common;

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
        $(LI single args: `excludingIndices(8, 16, 14...)`)
        $(LI single range: `excludingIndices([8, 16, 14...])`)
        $(LI sorted range: `excludingIndices([8, 16, 14...].sort)`)
        $(LI canFind range: `indices.filter!(canFind)`)
        $(LI canFind sorted: `indices.sort.filter!(canFind)`)
        ---
        Benchmarking excludingIndices against filter/canFind:
          numbers: [12, 11, 1, 9, 11, 4, 1, 4, 2, 7, 16, 8, 8, 9, 6, 15, 9, 0, 15, 2]
          indices: [8, 16, 14, 11, 0, 16, 12, 10, 15, 17]
        excludingIndices:
          single args:    3 ms, 885 μs, and 6 hnsecs
          single range:   1 ms and 610 μs
          sorted range:   185 μs and 2 hnsecs
          canFind range:  5 ms and 547 μs
          canFind sorted: 4 hnsecs
        excludingIndices (with .array):
          single args:    8 ms, 765 μs, and 8 hnsecs
          single range:   6 ms, 823 μs, and 8 hnsecs
          sorted range:   6 ms, 571 μs, and 2 hnsecs
          canFind range:  10 ms, 479 μs, and 2 hnsecs
          canFind sorted: 9 ms, 330 μs, and 5 hnsecs
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
