/**
    Removes elements from a range
*/
module ddash.algorithm.pull;

///
@("Module example 1")
unittest {
    int[] arr = [1, 2, 3, 4, 5];
    arr.pull(1, [2, 5]);
    assert(arr == [3, 4]);

    import std.math: ceil;
    double[] farr = [2.1, 1.2];
    assert(farr.pull!ceil([2.3, 3.4]) == [1.2]);

    farr = [2.1, 1.2];
    assert(farr.pull!((a, b) => ceil(a) == ceil(b))([2.3, 3.4]) == [1.2]);

    arr = [1, 2, 3, 4, 5];
    assert(arr.pull!"a == b - 1"(4, 6) == [1, 2, 4]);
}

///
@("Module example 2")
unittest {
    struct A {
        int x;
        int y;
    }

    auto arr = [A(1, 2), A(3, 4), A(5, 6)];
    assert(arr.pullBy!"y"(2, 6) == [A(3, 4)]);
}

import ddash.common;

/**
    Removes elements from a range.

    Params:
        range = a mutable range
        values = variables args of ranges and values to pull out
        pred = a unary transoform predicate or binary equality predicate. Defaults to `==`.

    Returns:
        Modified range

    Since:
        0.0.1
*/
ref pull(alias pred = null, Range, Values...)(return ref Range range, Values values)
if (from!"std.range".isInputRange!Range)
{
    return range.pullBase!("", pred)(values);
}

/**
    Removes elements from a range by a publicly visible field of `ElemntType!Range`

    Params:
        range = a mutable range
        values = variables args of ranges and values to pull out
        member = which member in `ElementType!Range` to pull by
        pred = a unary transform predicate or binary equality predicate. Defaults to `==`.

    Returns:
        Modified range

    Since:
        0.0.1
*/
ref pullBy(string member, alias pred = null, Range, Values...)(return ref Range range, Values values)
if (from!"std.range".isInputRange!Range)
{
    return range.pullBase!(member, pred)(values);
}

private ref pullBase(string member, alias pred, Range, Values...)(return ref Range range, Values values) {
    import std.algorithm: canFind, remove;
    import ddash.algorithm: concat, equal;
    import ddash.common.valueby;
    // elements from values will be lhs
    alias reverseEqual = (a, b) => equal!pred(b, a);
    auto unwanted = concat(values);
    static if (member == "")
    {
        alias transform = (a) => a;
    }
    else
    {
        alias transform = (a) => a.valueBy!member;
    }
    range = range
        .remove!(a => unwanted
            .canFind!reverseEqual(transform(a))
        );
    return range;
}

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
        $(LI single args: `pullIndices(8, 16, 14...)`)
        $(LI single range: `pullIndices([8, 16, 14...])`)
        $(LI sorted range: `pullIndices([8, 16, 14...].sort)`)
        $(LI canFind range: `indices.filter!(canFind)`)
        $(LI canFind sorted: `indices.sort.filter!(canFind)`)
        ---
        Benchmarking pullIndices against filter/canFind:
          numbers: [12, 11, 1, 9, 11, 4, 1, 4, 2, 7, 16, 8, 8, 9, 6, 15, 9, 0, 15, 2]
          indices: [8, 16, 14, 11, 0, 16, 12, 10, 15, 17]
        pullIndices:
          single args:    3 ms, 885 μs, and 6 hnsecs
          single range:   1 ms and 610 μs
          sorted range:   185 μs and 2 hnsecs
          canFind range:  5 ms and 547 μs
          canFind sorted: 4 hnsecs
        pullIndices (with .array):
          single args:    8 ms, 765 μs, and 8 hnsecs
          single range:   6 ms, 823 μs, and 8 hnsecs
          sorted range:   6 ms, 571 μs, and 2 hnsecs
          canFind range:  10 ms, 479 μs, and 2 hnsecs
          canFind sorted: 9 ms, 330 μs, and 5 hnsecs
        ---

    Since:
        0.0.1
*/
auto pullIndices(Range, Indices...)(Range range, Indices indices)
if (from!"std.range".isInputRange!Range
    && from!"std.meta".allSatisfy!(
        from!"std.traits".isIntegral,
        from!"bolts.meta".Flatten!Indices
    )
) {
    import std.algorithm: sort;
    import std.range: empty, popFront, front, isInputRange;
    import std.array;
    import ddash.algorithm: concat;
    import bolts.range: isSortedRange;

    // If we only have one element or we are a sorted range then there's no need to sort
    static if (Indices.length == 1 && (!isInputRange!(Indices[0]) || isSortedRange!(Indices[0]))) {
        auto normalizedIndices = concat(indices);
    } else {
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

@("pullIndices example")
unittest {
    assert([1, 2, 3, 4].pullIndices(1, 2, 3).equal([1]));
    assert([1, 2, 3, 4].pullIndices(0, 3).equal([2, 3]));
    assert([1, 2, 3, 4].pullIndices(0, 5).equal([2, 3, 4]));
    assert([1, 2, 3, 4].pullIndices([2, 1]).equal([1, 4]));
    assert([1, 2, 3, 4].pullIndices([2, 1, 0, 3]).empty);
}
