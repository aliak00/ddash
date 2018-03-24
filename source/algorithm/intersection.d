/**
    Creates a range of unique values that are included in all given ranges
*/
module algorithm.intersection;

///
unittest {
    assert([1, 2, 3].intersection([1], 3).equal([1, 3]));

    import std.math: ceil;
    assert([2.1, 1.2].intersection!ceil([2.3, 3.4]).equal([2.1]));
    assert([2.1, 1.2].intersection!((a, b) => ceil(a) == ceil(b))([2.3, 3.4]).equal([2.1]));

    struct A {
        int value;
    }
    assert([A(1), A(2), A(3)].intersection!((a, b) => a.value == b.value)([A(2), A(3)]).equal([A(2), A(3)]));
}

import common;

struct Intersection(alias pred, R1, R2) if (from!"std.range".isInputRange!R1 && from!"std.range".isInputRange!R2) {
    import std.range: ElementType;

    R1 r1;
    R2 r2;

    alias E = ElementType!R1;

    private void moveToNextElement() {
        import bolts.traits: isBinaryOver, isNullType;
        import bolts.range: isSortedRange;
        import std.range: empty, front, popFront;
        static if (!isBinaryOver!(pred, E) && isSortedRange!R1 && isSortedRange!R2)
        {
            import bolts.range: sortingPredicate;
            static if (isNullType!pred)
            {
                alias comp = (a, b) => sortingPredicate!R1(a, b);
            }
            else
            {
                alias comp = (a, b) => sortingPredicate!R1(pred(a), pred(b));
            }

            while (!this.r1.empty && !this.r2.empty) {
                if (comp(this.r1.front, this.r2.front)) {
                    this.r1.popFront;
                } else if (comp(this.r2.front, this.r1.front)) {
                    this.r2.popFront;
                } else {
                    break;
                }
            }
        }
        else
        {
            import std.algorithm: canFind;
            import algorithm: equal;
            alias eq = (a, b) => equal!pred(a, b);
            while (!this.r1.empty && !this.r2.canFind!eq(this.r1.front)) {
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
        return this.r1.empty || this.r2.empty;
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
    Creates a range of unique values that are included in all given ranges

    The `pred` defaults to null. If a unary predicate is passed in, then a transformation
    will be appled to each element before comparing. If a binary predicate is passed in, it
    will determine equality of elements.

    If `pred` is null or unary, and the range is sortable or is sorted, an optimized linear
    algorithm will be used instead using the range's
    $(DDOX_NAMED_REF range.sortingpredicate, `sorting predicate`).

    Params:
        pred = unary transformation or binary comparator
        range = the range to inspect
        values = ranges or single values to exclude

    Returns:
        New array of filtered results. If `Rs` is empty, then empty `range` is returned

    Since:
        0.1.0
*/
auto intersection(alias pred = null, Range, Rs...)(Range range, Rs values)
if (from!"std.range".isInputRange!Range
    && (from!"bolts.traits".isNullType!pred
        || from!"bolts.traits".isUnaryOver!(pred, from!"std.range".ElementType!Range)
        || from!"bolts.traits".isBinaryOver!(pred, from!"std.range".ElementType!Range)))
{
    static if (!Rs.length)
    {
        import std.range: takeNone;
        return range.takeNone;
    }
    else
    {
        import std.range: ElementType;
        import algorithm: concat;
        import bolts.traits: isNullType, isUnaryOver;

        auto combinedValues = values.concat;
        static assert (is(ElementType!(typeof(combinedValues)) : ElementType!Range));

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

        return Intersection!(pred, typeof(r1), typeof(r2))(r1, r2);
    }
}

unittest {
    assert([1, 2, 3].intersection([0, 1, 2]).equal([1, 2]));
    assert([1, 2, 3].intersection([1, 2]).equal([1, 2]));
    assert([1, 2, 3].intersection([1], 2).equal([1, 2]));
    assert([1, 2, 3].intersection([1], [3]).equal([1, 3]));
    assert([1, 2, 3].intersection(3).equal([3]));
}

unittest {
    // Implicitly convertible elements ok
    assert([1.0, 2.0].intersection(2).equal([2.0]));

    // Implicitly convertible ranges ok
    assert([1.0, 2.0].intersection([2]).equal([2.0]));

    // Non implicily convertible elements not ok
    static assert(!__traits(compiles, [1].intersection(1.0)));

    // Non implicily convertible range not ok
    static assert(!__traits(compiles, [1].intersection([1.0])));
}

unittest {
    import std.math: ceil;
    assert([2.1, 1.2].intersection!ceil([2.3, 3.4]).equal([2.1]));
    assert([2.1, 1.2].intersection!((a, b) => ceil(a) == ceil(b))([2.3, 3.4]).equal([2.1]));
}

unittest {
    struct A {
        int value;
    }
    assert([A(1), A(2), A(3)].intersection!((a, b) => a.value == b.value)([A(2), A(3)]).equal([A(2), A(3)]));
}
