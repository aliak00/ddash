module algorithm.intersection;

import common: from;

struct Intersection(alias pred, R1, R2) if (from!"std.range".isInputRange!R1 && from!"std.range".isInputRange!R2) {
    import std.range: ElementType;

    R1 r1;
    R2 r2;

    alias E = ElementType!R1;

    private void moveToNextElement() {
        import utils.traits: isBinaryOver, isSortedRange;
        static if (!isBinaryOver!(pred, E) && isSortedRange!R1 && isSortedRange!R2)
        {
            import std.range: ElementType;
            import range: sortingPredicate;
            import utils.traits: isNullType;
            static if (isNullType!pred)
            {
                alias comp = (a, b) => r1.sortingPredicate(a, b);
            }
            else
            {
                alias comp = (a, b) => r1.sortingPredicate(pred(a), pred(b));
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
            import std.range: empty, front, popFront;
            import utils.traits: isUnaryOver, isNullType;
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

            while (!this.r1.empty && !this.r2.canFind!equal(this.r1.front)) {
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

auto intersection(alias pred = null, Range, Rs...)(Range range, Rs values)
if (from!"std.range".isInputRange!Range
    && (from!"utils.traits".isNullType!pred
        || from!"utils.traits".isUnaryOver!(pred, from!"std.range".ElementType!Range)
        || from!"utils.traits".isBinaryOver!(pred, from!"std.range".ElementType!Range)))
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
        import utils.traits: isNullType, isUnaryOver;

        auto combinedValues = values.concat;
        static assert (is(ElementType!(typeof(combinedValues)) : ElementType!Range));

        // import std.algorithm: sort;
        // pragma(msg,
        //     __FUNCTION__,
        //     "\n  pred: ", typeof(pred),
        //     "\n  combinedValues: ", typeof(combinedValues),
        //     "\n  canSortRange: ", is(typeof(range.sort)),
        //     "\n  canSortCombinedValues: ", is(typeof(combinedValues.sort)),
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

        return Intersection!(pred, typeof(r1), typeof(r2))(r1, r2);
    }
}

version (unittest) {
    import std.array;
}

unittest {
    assert([1, 2, 3].intersection([0, 1, 2]).array == [1, 2]);
    assert([1, 2, 3].intersection([1, 2]).array == [1, 2]);
    assert([1, 2, 3].intersection([1], 2).array == [1, 2]);
    assert([1, 2, 3].intersection([1], [3]).array == [1, 3]);
    assert([1, 2, 3].intersection(3).array == [3]);
}

unittest {
    // Implicitly convertible elements ok
    assert([1.0, 2.0].intersection(2).array == [2.0]);

    // Implicitly convertible ranges ok
    assert([1.0, 2.0].intersection([2]).array == [2.0]);

    // Non implicily convertible elements not ok
    static assert(!__traits(compiles, [1].intersection(1.0)));

    // Non implicily convertible range not ok
    static assert(!__traits(compiles, [1].intersection([1.0])));
}

unittest {
    import std.math: ceil;
    assert([2.1, 1.2].intersection!ceil([2.3, 3.4]).array == [2.1]);
    assert([2.1, 1.2].intersection!((a, b) => ceil(a) == ceil(b))([2.3, 3.4]).array == [2.1]);
}

unittest {
    struct A {
        int value;
    }
    assert([A(1), A(2), A(3)].intersection!((a, b) => a.value == b.value)([A(2), A(3)]).array == [A(2), A(3)]);
}
