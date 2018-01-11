module algorithm.intersection;

import std.range: isInputRange;
import std.stdio;

struct Intersection(alias pred = "a", R1, R2) if (isInputRange!R1 && isInputRange!R2) {
    import std.range: ElementType;
    import std.functional: unaryFun, binaryFun;

    enum isUnary = is(typeof(unaryFun!pred(ElementType!R1.init)));
    static if (isUnary)
    {
        alias transform = unaryFun!pred;
        alias compare = binaryFun!"a == b";
    }
    else
    {
        alias transform = unaryFun!"a";
        alias compare = binaryFun!pred;
    }

    R1 r1;
    R2 r2;

    alias equal = (a, b) => compare(transform(a), transform(b));

    private void moveToNextElement() {
        import std.traits: TemplateOf;
        import std.range: SortedRange;
        enum r1Sorted = is(R1: SortedRange!T, T...);
        enum r2Sorted = is(R2: SortedRange!U, U...);
        static if (r1Sorted && r2Sorted)
        {
            while (this.r2.empty && !this.r1.empty) {
                this.r1.popFront;
            }
            while (!this.r1.empty && !this.r2.empty) {
                if (equal(this.r1.front, this.r2.front)) {
                    this.r2.popFront;
                    break;
                }
                this.r1.popFront;
            }
        }
        else static if (r2Sorted)
        {
            // TODO: This path is not tested in any of the unittests
            while (!this.r1.empty && this.r2.contains!notEqual(this.r1.front)) {
                this.r1.popFront;
            }
        }
        else
        {
            import std.algorithm: canFind;
            import std.range: empty, front, popFront;
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

auto intersection(alias pred = "a", Range, Values...)(Range range, Values values) if (isInputRange!Range) {
    import std.range: ElementType, SortedRange;
    import std.algorithm: sort;
    import std.traits: TemplateOf;
    import algorithm: concat;
    static if (Values.length)
    {
        static if (isInputRange!(Values[0]) && is(ElementType!(Values[0]) : ElementType!Range))
        {
            auto other = values[0].concat(values[1..$]);
        }
        else static if (is(Values[0] : ElementType!Range))
        {
            auto other = [values[0]].concat(values[1..$]);
        }
        else
        {
            static assert(0, "Cannot find intersection between type " ~ Values[0].stringof ~ " and range of " ~ ElementType!Range.stringof);
        }

        enum r1Sorted = is(typeof(range): SortedRange!T, T...);
        enum r2Sorted = is(typeof(other): SortedRange!U, U...);
        enum canSortR1 = is(typeof(sort(range)));
        enum canSortR2 = is(typeof(sort(other)));

        // debug {
        //     pragma(msg,
        //         __FUNCTION__, ":\n  => ",
        //             typeof(range), " ", typeof(other), "\n  => ",
        //             "sorted:   ", r1Sorted, " ", r2Sorted, "\n  => ",
        //             "sortable: ", canSortR1, " ", canSortR2);
        // }

        static if (r1Sorted || !canSortR2)
        {
            auto r1 = range;
        }
        else
        {
            auto r1 = range.sort;
        }

        static if (r2Sorted || !canSortR2)
        {
            auto r2 = other;
        }
        else
        {
            auto r2 = other.sort;
        }

        return Intersection!(pred, typeof(r1), typeof(r2))(r1, r2);
    }
    else
    {
        import range: takeNone;
        return range.takeNone;
    }
}

version (unittest) {
    import std.array;
}

unittest {
    // assert([1, 2, 3].intersection([0, 1, 2]).array == [1, 2]);
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
