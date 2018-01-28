/**
    Excludes values from a range

    The `pred` defaults to null. If a unary predicate is passed in, then a transformation
    will be appled to each element before comparing. If a binary predicate is passed in, it
    will determine equality of elements.

    If `pred` is null or unary, and the range is sortable or is sorted, an optimized linear
    algorithm will be used instead using the `range.sortingpredicate` of `range`
*/
module algorithm.difference;

///
unittest {
    assert([1, 2, 3].difference([1], 3).array == [2]);

    import std.math: ceil;
    assert([2.1, 1.2].difference!ceil([2.3, 3.4]).array == [1.2]);
    assert([2.1, 1.2].difference!((a, b) => ceil(a) == ceil(b))([2.3, 3.4]).array == [1.2]);

    struct A {
        int value;
    }

    assert([A(1), A(2), A(3)].difference!((a, b) => a.value == b.value)([A(2), A(3)]).array == [A(1)]);
}

import common;

struct Difference(alias pred, R1, R2) if (from!"std.range".isInputRange!R1 && from!"std.range".isInputRange!R2) {
    import std.range: ElementType;

    R1 r1;
    R2 r2;

    alias E = ElementType!R1;

    private void moveToNextElement() {
        import utils.traits: isBinaryOver, isSortedRange, isNullType;
        import std.range: empty, front, popFront;
        static if (!isBinaryOver!(pred, E) && isSortedRange!R1 && isSortedRange!R2)
        {
            import range: sortingPredicate;
            static if (isNullType!pred)
            {
                alias comp = (a, b) => r1.sortingPredicate(a, b);
            }
            else
            {
                alias comp = (a, b) => r1.sortingPredicate(pred(a), pred(b));
            }

            while (!this.r1.empty) {
                if (this.r2.empty || comp(this.r1.front, this.r2.front)) break;
                if (comp(this.r2.front, this.r1.front)) {
                    this.r2.popFront();
                } else {
                    this.r1.popFront();
                    this.r2.popFront();
                }
            }
        }
        else
        {
            import std.algorithm: canFind;
            import utils.traits: isUnaryOver;
            static if (isNullType!pred)
            {
                alias equal = (a, b) => a == b;
            }
            else static if (isUnaryOver!(pred, E))
            {
                alias equal = (a, b) => pred(a) == pred(b);
            }
            else
            {
                alias equal = (a, b) => pred(a, b);
            }

            while (!this.r1.empty && this.r2.canFind!equal(this.r1.front)) {
                this.r1.popFront;
            }
        }
    }

    this(R1 r1, R2 r2) {
        this.r1 = r1;
        this.r2 = r2;
        this.moveToNextElement;
    }

    bool empty() @property {
        import std.range: empty;
        return this.r1.empty;
    }
    auto front() @property {
        import std.range: front;
        return this.r1.front;
    }
    void popFront() {
        import std.range: popFront;
        this.r1.popFront;
        this.moveToNextElement;
    }
}

/**
    Ditto

    Params:
        pred = unary transformation or binary comparator
        range = the range to inspect
        values = ranges or single values to exclude

    Returns:
        New array of filtered results. If `Rs` is empty, then `range` is returned
*/
auto difference(alias pred = null, Range, Rs...)(Range range, Rs values)
if (from!"std.range".isInputRange!Range
    && (from!"utils.traits".isNullType!pred
        || from!"utils.traits".isUnaryOver!(pred, from!"std.range".ElementType!Range)
        || from!"utils.traits".isBinaryOver!(pred, from!"std.range".ElementType!Range)))
{
    static if (!Rs.length)
    {
        return range;
    }
    else
    {
        import std.range: ElementType;
        import algorithm: concat;
        import utils.traits: isNullType, isUnaryOver;

        auto combinedValues = values.concat;
        static assert (is(ElementType!(typeof(combinedValues)) : ElementType!Range));

        // import std.algorithm: sort;
        // import utils.traits: isSortedRange;
        // pragma(msg,
        //     __FUNCTION__,
        //     "\n  pred: ", typeof(pred),
        //     "\n  combinedValues: ", typeof(combinedValues),
        //     "\n  canSortRange: ", is(typeof(range.sort)),
        //     "\n  canSortCombinedValues: ", is(typeof(combinedValues.sort)),
        //     "\n  r1Sorted: ", isSortedRange!Range,
        //     "\n  r2Sorted: ", isSortedRange!(typeof(combinedValues)),
        // );
        static if (isNullType!pred || isUnaryOver!(pred, ElementType!Range))
        {
            import std.algorithm: sort;
            static if (is(typeof(range.sort)))
            {
                auto r1 = range.sort;
            }
            else
            {
                auto r1 = range;
            }

            static if (is(typeof(combinedValues.sort)))
            {
                auto r2 = combinedValues.sort;
            }
            else
            {
                auto r2 = combinedValues;
            }
        }
        else
        {
            auto r1 = range;
            auto r2 = combinedValues;
        }

        return Difference!(pred, typeof(r1), typeof(r2))(r1, r2);
    }
}

version (unittest) {
    import std.array;
}

unittest {
    assert([1, 2, 3].difference([0, 1, 2]).array == [3]);
    assert([1, 2, 3].difference([1, 2]).array == [3]);
    assert([1, 2, 3].difference([1], 2).array == [3]);
    assert([1, 2, 3].difference([1], [3]).array == [2]);
    assert([1, 2, 3].difference(3).array == [1, 2]);
}

unittest {
    // Implicitly convertible elements ok
    assert([1.0, 2.0].difference(2).array == [1.0]);

    // Implicitly convertible ranges ok
    assert([1.0, 2.0].difference([2]).array == [1.0]);

    // Non implicily convertible elements not ok
    static assert(!__traits(compiles, [1].difference(1.0)));

    // Non implicily convertible range not ok
    static assert(!__traits(compiles, [1].difference([1.0])));
}

unittest {
    import std.math: ceil;
    assert([2.1, 1.2].difference!ceil([2.3, 3.4]).array == [1.2]);
    assert([2.1, 1.2].difference!((a, b) => ceil(a) == ceil(b))([2.3, 3.4]).array == [1.2]);
}

unittest {
    struct A {
        int value;
    }
    assert([A(1), A(2), A(3)].difference!((a, b) => a.value == b.value)([A(2), A(3)]).array == [A(1)]);
}
